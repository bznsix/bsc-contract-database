// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "@openzeppelin/contracts/access/Ownable.sol";

contract Antidot is Ownable {
    // TYPES //
    struct Stake {
        uint256 stake;
        uint256 notWithdrawn;
        uint256 timestamp;
        address partner;
        uint256 percentage;
        bool    deposited;
    }

    struct ReferralReward {
        uint256 currentAvailableAmount;
        uint256 profit;
        uint256 volume;
        uint256 claimDate;
        bool    claimed;
    }

    struct ReferralUsers {
        address user;
        uint256 lvl;
    }
    // TYPES //

    // STORAGE //
    uint256 constant public hundredPercent = 10 ** 27;
    uint256 constant public referralLvls = 10;
    address constant public zeroAddress = 0x0000000000000000000000000000000000000000;

    uint256 public depositLvls;
    uint256 public minDepositValue;
    uint256 public withdrawFee;
    uint256 public minWithdrawValue;
    uint256 public referralClaimDate;

    bool public depositPause;
    bool public reinvestDepositedPause;
    bool public reinvestReferralPause;
    bool public withdrawDepositedPause;
    bool public withdrawReferralPause;

    uint256[] public depositPercentages;
    uint256[] public depositAmount;
    uint256[referralLvls] public referralPercentages;

    mapping(address => bool) public left;
    mapping(address => Stake) public stake;
    mapping(address => mapping(address => ReferralReward)) public referralReward; // user => invited => referral reward info
    mapping(address => mapping(uint256 => uint256)) public referralLvlRewards; // user => ref lvl => amount
    mapping(address => mapping(address => uint256)) public referralUserRewards; // user => invited up to 'referralLvls' => amount
    mapping(address => ReferralUsers[]) public referralUsers; // user => invited up to 'referralLvls'
    // STORAGE //

    constructor(address _initialPartner) {
        stake[_initialPartner].deposited = true;
    }

    // MODIFIERS //
    modifier depositNotPaused() {
        require(!depositPause, "paused");
        _;
    }

    modifier reinvestDepositedNotPaused() {
        require(!reinvestDepositedPause, "paused");
        _;
    }

    modifier reinvestReferralNotPaused() {
        require(!reinvestReferralPause, "paused");
        _;
    }

    modifier withdrawDepositedNotPaused() {
        require(!withdrawDepositedPause, "paused");
        _;
    }

    modifier withdrawReferralNotPaused() {
        require(!withdrawReferralPause, "paused");
        _;
    }
    // MODIFIERS //

    // MAIN //
    function deposit(address _partner) external payable depositNotPaused {
        require(msg.value >= minDepositValue, "invalidAmount");

        _updateNotWithdrawn();

        Stake memory _senderStake = stake[msg.sender];
        if(!_senderStake.deposited) {
            require(stake[_partner].deposited, "invalidPartner");
            require(_partner != msg.sender, "invalidPartner");

            _senderStake.deposited = true;
            _senderStake.partner = _partner;
            _senderStake.stake += msg.value;
            stake[msg.sender] = _senderStake;
            _traverseTree(msg.sender, _partner, msg.value);
        } else {
            _senderStake.stake += msg.value;
            stake[msg.sender] = _senderStake;
        }
        
        _updatePercentage();
    }

    function reinvestDeposited(uint256 _amount) external reinvestDepositedNotPaused {
        require(_amount > 0, "invalidAmount");

        _updateNotWithdrawn();

        stake[msg.sender].notWithdrawn -= _amount;
        stake[msg.sender].stake += _amount;

        _updatePercentage();
    }

    function reinvestReferral(address[] memory _invited, uint256[] memory amount) external reinvestReferralNotPaused {
        uint256 _invitedLength = _invited.length;
         require(_invitedLength == amount.length, "notEqual");
        uint256 _toReinvest;
        for(uint256 i; i < _invitedLength; i++) {
            ReferralReward memory reward = referralReward[msg.sender][_invited[i]];

            require(!reward.claimed, "alreadyClaimed");
            require(block.timestamp >= reward.claimDate, "notAvailable");
            require(reward.claimDate != 0, "invalidReferral");

            reward.currentAvailableAmount -= amount[i];
            if (reward.currentAvailableAmount == 0) {
                reward.claimed = true;
            }
            _toReinvest += amount[i];
            referralReward[msg.sender][_invited[i]] = reward;
        }

        stake[msg.sender].stake += _toReinvest;
        _updatePercentage();
    }

    function withdrawDeposited(uint256 _amount) external withdrawDepositedNotPaused {
        require(_amount > 0, "zeroAmount");
        require(_amount >= minWithdrawValue, "invalidAmount");
        require(!left[msg.sender], "left");

        _updateNotWithdrawn();

        uint256 _fee = _amount * withdrawFee / hundredPercent;
        stake[msg.sender].notWithdrawn -= _amount;

        payable(owner()).transfer(_fee);
        payable(msg.sender).transfer(_amount - _fee);
    }

    function withdrawReferral(address[] memory _invited, uint256[] memory amount) external withdrawReferralNotPaused {
        require(!left[msg.sender], "left");
        uint256 _invitedLength = _invited.length;
        require(_invitedLength == amount.length, "notEqual");
        uint256 _toWithdraw;
        for(uint256 i; i < _invitedLength; i++) {
            ReferralReward memory reward = referralReward[msg.sender][_invited[i]];

            require(!reward.claimed, "alreadyClaimed");
            require(block.timestamp >= reward.claimDate, "notAvailable");
            require(reward.claimDate != 0, "invalidReferral");

            reward.currentAvailableAmount -= amount[i];
            if (reward.currentAvailableAmount == 0) {
                reward.claimed = true;
            }
            _toWithdraw += amount[i];
            referralReward[msg.sender][_invited[i]] = reward;
        }
        require(_toWithdraw >= minWithdrawValue, "invalidAmount");

        uint256 _fee = _toWithdraw * withdrawFee / hundredPercent;

        payable(owner()).transfer(_fee);
        payable(msg.sender).transfer(_toWithdraw - _fee);
    }

    function _updateNotWithdrawn() private {
        uint256 _pending = getPendingReward(msg.sender);
        stake[msg.sender].timestamp = block.timestamp;
        stake[msg.sender].notWithdrawn += _pending;
    }

    function _traverseTree(address _user, address _partner, uint256 _value) private {
        uint256 _referralClaimDate = referralClaimDate; 
        for (uint256 i; i < referralLvls; i++) {
            if (_partner == zeroAddress) {
                break;
            }
            uint256 _reward = _value * referralPercentages[i] / hundredPercent;

            referralReward[_partner][_user] = ReferralReward(_reward, _reward, _value, block.timestamp + _referralClaimDate, false);
            referralLvlRewards[_partner][i] += _reward;

            if (referralUserRewards[_partner][_user] == 0) {
                referralUsers[_partner].push(ReferralUsers(_user, i));
            }
            referralUserRewards[_partner][_user] += _reward;

            _partner = stake[_partner].partner;
        }
    }

    function _updatePercentage() private {
        uint256 _depositLvls = depositLvls;
        uint256 _stake = stake[msg.sender].stake;
        uint256[] memory _depositAmount = depositAmount;

        for (uint256 i; i < _depositLvls; i++) {
            if (_stake >= _depositAmount[i]) {
                stake[msg.sender].percentage = depositPercentages[i];
                break;
            }
        }
    }
    // MAIN //

    // SETTERS //
    function setDepositLvls(uint256 _newLvls, uint256[] calldata _newAmount, uint256[] calldata _newPercentages) external onlyOwner {
        depositLvls = _newLvls;

        uint256 _currentLength = depositAmount.length;

        if (_currentLength > _newLvls) {
            uint256 _toDelete = _currentLength - _newLvls;
            for (uint256 i; i < _toDelete; i++) {
                depositAmount.pop();
                depositPercentages.pop();
            }
        }

        if (_currentLength < _newLvls) {
            uint256 _toAdd = _newLvls - _currentLength;
            for (uint256 i; i < _toAdd; i++) {
                depositAmount.push(0);
                depositPercentages.push(0);
            }
        }

        setDepositAmount(_newAmount);
        setDepositPercentages(_newPercentages);
    }

    function setMinDepositValue(uint256 _value) external onlyOwner {
        minDepositValue = _value;
    }

    function setWithdrawFee(uint256 _value) external onlyOwner {
        withdrawFee = _value;
    }

    function setMinWithdrawValue(uint256 _value) external onlyOwner {
        minWithdrawValue = _value;
    }

    function setReferralClaimDate(uint256 _value) external onlyOwner {
        referralClaimDate = _value;
    }

    function setDepositPause(bool _value) external onlyOwner {
        depositPause = _value;
    }

    function setReinvestDepositedPause(bool _value) external onlyOwner {
        reinvestDepositedPause = _value;
    }

    function setReinvestReferralPause(bool _value) external onlyOwner {
        reinvestReferralPause = _value;
    }

    function setWithdrawDepositedPause(bool _value) external onlyOwner {
        withdrawDepositedPause = _value;
    }

    function setWithdrawReferralPause(bool _value) external onlyOwner {
        withdrawReferralPause = _value;
    }

    function setDepositPercentages(uint256[] calldata _newPercentages) public onlyOwner {
        uint256 _depositLvls = depositLvls;
        require(_newPercentages.length == _depositLvls, "invalidLength");

        uint256 _limit = _depositLvls - 1;
        for (uint256 i; i < _limit; i++) {
            require(_newPercentages[i] > _newPercentages[i + 1], "invalidPercentages");
            depositPercentages[i] = _newPercentages[i];
        }
        depositPercentages[_limit] = _newPercentages[_limit];

        require(_newPercentages[_limit] != 0, "invalidPercentage");
    }

    function setDepositAmount(uint256[] calldata _newAmoun) public onlyOwner {
        uint256 _depositLvls = depositLvls;
        require(_newAmoun.length == _depositLvls, "invalidLength");

        uint256 _limit = _depositLvls - 1;
        for (uint256 i; i < _limit; i++) {
            require(_newAmoun[i] > _newAmoun[i + 1], "invalidAmount");
            depositAmount[i] = _newAmoun[i];
        }
        depositAmount[_limit] = _newAmoun[_limit];

        require(_newAmoun[_limit] != 0, "invalidAmount");
    }

    function setReferralPercentages(uint256[] calldata _newPercentages) external onlyOwner {
        require(_newPercentages.length == referralLvls, "invalidLength");

        uint256 _limit = referralLvls - 1;
        for (uint256 i; i < _limit; i++) {
            require(_newPercentages[i] > _newPercentages[i + 1], "invalidPercentages");
            referralPercentages[i] = _newPercentages[i];
        }
        referralPercentages[_limit] = _newPercentages[_limit];

        require(_newPercentages[_limit] != 0, "invalidPercentage");
    }

    function setNewPartner(address _user, address _newPartner) external onlyOwner {
        require(_user != zeroAddress, "invalidUser");
        require(_newPartner != zeroAddress, "invalidPartner");
        require(_user != _newPartner, "userIsPartner");
        require(stake[_user].deposited, "userNotDeposited");
        require(stake[_newPartner].deposited, "partnerNotDeposited");

        stake[_user].partner = _newPartner;
    }

    function leave(address[] calldata account, bool[] calldata _left) external onlyOwner {
        require(account.length == _left.length, "invalidLength");
        for (uint256 i; i < account.length; i++) {
            left[account[i]] = _left[i];
        }
    }

    function arbitrageTransfer(uint256 amount) external onlyOwner {
        payable(msg.sender).transfer(amount);
    }
    // SETTERS //

    // GETTERS //
    function getPendingReward(address _account) public view returns(uint256) {
        Stake memory _stake = stake[_account];
        return ((_stake.stake * ((block.timestamp - _stake.timestamp) / 24 hours) * _stake.percentage) / hundredPercent);
    }

    function getReferralUsers(address _account) public view returns(ReferralUsers[] memory) {
        return referralUsers[_account];
    }

    function getReferralUsersLength(address _account) public view returns(uint256) {
        return referralUsers[_account].length;
    }

    function getReferralUsersIndexed(address _account, uint256 _from, uint256 _to) public view returns(ReferralUsers[] memory) {
        ReferralUsers[] memory _info = new ReferralUsers[](_to - _from);

        for(uint256 _index = 0; _from < _to; ++_index) {
            _info[_index] = referralUsers[_account][_from];
            _from++;
        }

        return _info;
    }

    function getDepositPercentages() public view returns(uint256[] memory) {
        return depositPercentages;
    }

    function getDepositPercentagesLength() public view returns(uint256) {
        return depositPercentages.length;
    }

    function getDepositPercentagesIndexed(uint256 _from, uint256 _to) public view returns(uint256[] memory) {
        uint256[] memory _info = new uint256[](_to - _from);

        for(uint256 _index = 0; _from < _to; ++_index) {
            _info[_index] = depositPercentages[_from];
            _from++;
        }

        return _info;
    }

    function getDepositAmount() public view returns(uint256[] memory) {
        return depositAmount;
    }

    function getDepositAmountLength() public view returns(uint256) {
        return depositAmount.length;
    }

    function getDepositAmountIndexed(uint256 _from, uint256 _to) public view returns(uint256[] memory) {
        uint256[] memory _info = new uint256[](_to - _from);

        for(uint256 _index = 0; _from < _to; ++_index) {
            _info[_index] = depositAmount[_from];
            _from++;
        }

        return _info;
    }

    function getReferralPercentages() public view returns(uint256[referralLvls] memory) {
        return referralPercentages;
    }
    // GETTERS //
}// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby disabling any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}
