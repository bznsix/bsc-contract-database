// File: @openzeppelin/contracts/token/ERC20/IERC20.sol


// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

// File: @openzeppelin/contracts/utils/Context.sol


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

// File: @openzeppelin/contracts/security/Pausable.sol


// OpenZeppelin Contracts v4.4.1 (security/Pausable.sol)

pragma solidity ^0.8.0;


/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
abstract contract Pausable is Context {
    /**
     * @dev Emitted when the pause is triggered by `account`.
     */
    event Paused(address account);

    /**
     * @dev Emitted when the pause is lifted by `account`.
     */
    event Unpaused(address account);

    bool private _paused;

    /**
     * @dev Initializes the contract in unpaused state.
     */
    constructor() {
        _paused = false;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns (bool) {
        return _paused;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        require(!paused(), "Pausable: paused");
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    modifier whenPaused() {
        require(paused(), "Pausable: not paused");
        _;
    }

    /**
     * @dev Triggers stopped state.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    /**
     * @dev Returns to normal state.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
}

// File: @openzeppelin/contracts/access/Ownable.sol


// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

pragma solidity ^0.8.0;


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
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
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

// File: contracts/MiningV6/StakeGFAM_V5.sol


pragma solidity ^0.8.4;



contract StakeGfam is Ownable, Pausable {
    mapping(address => bool) private allowedContracts;

    IERC20 public gfamToken;
    IERC20 public stableToken;
    ITokenTrade public tokenTrade;

    uint public rewardRate;
    uint public commissionRate;
    uint public earningDate;
    uint public earningDay;
    uint public offset;
    uint public minDaysStake;

    uint public stakedTokensAT; //TOTAL FROM START
    uint public stakedTokens;
    uint public stakedTokensRef;
    uint public totaRequestedStableToken; //TOTAL FROM START
    uint public requestedStableTokenNet; //Net
    uint public rewardDistributionPoolAT;//TOTAL FROM START
    uint public rewardDistributionBalancePool; //NET
    uint public referralClaimsBalance;

    mapping(address => Stake[]) public stakes;
    mapping(uint => dayDataStake) public dailyData;
    uint[] public earningDays;
    mapping(uint => uint) public rewardsBalancePerDay;
    mapping(uint => uint) public cumulativeRewardsBalancePerDay;
    mapping(address => uint) public stakesPerUser;

    mapping(address => address) public referrals;
    mapping(address => uint) public referralClaims;
    int public currentStakes = 0;
    uint public stakesAT = 0;
    int public currentStakesRef = 0;
    uint public stakesRefAT = 0;
    bool public allowRef;

    bool public allowStakes = true;
    bool public allowNewStakes = true;
    bool public allowStakeCredits = true;

    uint public imported;

    
    constructor() {
        gfamToken = IERC20(0x772b609D3A8F2Ebe1c1b8F87EBda2e462eC475F8);
        stableToken = IERC20(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56);
        tokenTrade = ITokenTrade(0x103E68d616e921a36161f119EaAD04F9b32dA173);
        rewardRate = 25;
        commissionRate = 10;
        allowRef = true;
        offset = 1;
        minDaysStake = 90;
    }

    struct dayDataStake {
        uint tkns;
        uint goals;
        uint refTkns;
        uint nbr;
        uint refNbr;
        uint reward;
    }
    struct Stake {
        uint initTokenAmount;
        uint initTokenPrice;
        uint stakeValue;
        uint rewardGoal;
        uint startDate;
        uint startDay;
        uint dayIndex;
        uint lastClaimDate;
        uint lastClaimDay;
        uint rewardClaimed;
        bool isCom;
        bool ended;
    }
    struct TokensData {
        uint stakedTokens;
        uint rewardDistributionBalancePool;
        uint requestedStableTokenNet;
        uint totaRequestedStableToken;
        uint referralClaimsBalance;
        uint rewardRate;
        uint commissionRate;
        uint minDaysStake;
        int totalStakes;
        uint stakesAT;
        uint stakesRefAT;
        int currentStakesRef;
    }
    event stakeEvent(address _user, uint _amount, uint _gfamValue);
    event claimEvent(address _user, uint _amount, uint _goal);
    event restakeEvent(address _user, uint _amount, uint _gfamValue);
    event stakeCreditsEvent(address _user, uint _amount, uint _gfamValue);
    
    function allowedToStake(address _user) public view returns (bool){
        if(allowStakes == false){
            return false;
        }else if(allowNewStakes == true){
            return true;
        }else{
            return stakes[_user].length > 0;
        }
    }
    //STAKE
    function stake(address _user,uint _amount,address _referral) external whenNotPaused {
        require(allowedToStake(_user) == true, "New stakes paused");
        if (
            referrals[_user] == address(0) &&
            _referral != _user &&
            _referral != address(0)
        ) {
            referrals[_user] = _referral;
        }
        if (referrals[_user] != address(0) && allowRef) {
            referralClaims[referrals[_user]] +=
                (_amount * commissionRate) /
                100;
            referralClaimsBalance += (_amount * commissionRate) / 100;
        }
        __stake(_user, _amount, false, block.timestamp);
        gfamToken.transferFrom(_user, address(this), _amount);
        emit stakeEvent(_user, _amount, getPrice(_amount));
    }
    function stakeCredits() external whenNotPaused {
        require(allowStakeCredits, "Stake Credits paused");
        uint _amount = referralClaims[msg.sender];
        require(_amount > 0, "Nothing to claim");
        __stake(msg.sender, _amount, true, block.timestamp);
        emit stakeCreditsEvent(
            msg.sender,
            referralClaims[msg.sender],
            (_amount * getPrice(_amount)) / 1e18
        );
        referralClaims[msg.sender] = 0;
        referralClaimsBalance -= _amount;
    }
    function stakeCreditsAdmin(address _user,uint _amount) external onlyOwner {
        require(_amount > 0, "Nothing to stake");
        __stake(_user, _amount, true, block.timestamp);
        emit stakeCreditsEvent(
            _user,
            referralClaims[_user],
            (_amount * getPrice(_amount)) / 1e18
        );
        referralClaims[_user] = 0;
        referralClaimsBalance -= _amount;
    }
    function restake(uint _stakeIndex) external whenNotPaused {
        Stake storage _stake = stakes[msg.sender][_stakeIndex];
        require(_stake.ended, "Stake still active");
        require(_stake.isCom == false, "Only non commission stakes accepted");
        __stake(msg.sender, _stake.initTokenAmount, false, block.timestamp);
        _removeStake(msg.sender, _stakeIndex, _stake.isCom, true);
    }
    function unstake(uint _stakeIndex) external whenNotPaused {
        Stake storage _stake = stakes[msg.sender][_stakeIndex];
        require(
            minDaysStake >=
                (_stake.startDate / 1 days) - (block.timestamp / 1 days),
            "Min Days of stake not reached yet"
        );
        require(_stake.isCom == false, "Commission stakes can not be unstaked");
        _claim(msg.sender, _stakeIndex);
        _removeStake(msg.sender, _stakeIndex, _stake.isCom, false);
    }
    function claim(uint256 _stakeIndex) external whenNotPaused {
        require(_stakeIndex < stakes[msg.sender].length, "Invalid stake index");
        _claim(msg.sender, _stakeIndex);
    }
    function __stake(address _user,uint256 _amountToken,bool _isCom,uint date) internal returns (Stake memory) {
        uint gfamValue = getPrice(_amountToken);
        uint stakeValue = (_amountToken * gfamValue) / 1e18;
        uint goal = (stakeValue * rewardRate) / 100;
        uint _date = date;
        uint _day = date / 1 days;
        uint dayIndex = dailyData[_day].nbr + dailyData[_day].refNbr + 1;
        Stake memory newStake = Stake({
            initTokenAmount: _amountToken,
            initTokenPrice: gfamValue,
            stakeValue: stakeValue,
            rewardGoal: goal,
            startDate: _date,
            startDay: _day,
            dayIndex: dayIndex,
            lastClaimDate: 0,
            lastClaimDay: 0,
            rewardClaimed: 0,
            isCom: _isCom,
            ended: false
        });
        stakes[_user].push(newStake);
        stakesPerUser[_user]++;
        totaRequestedStableToken += goal;
        requestedStableTokenNet += goal;
        if (_isCom) {
            stakesRefAT++;
            currentStakesRef++;
            stakedTokensRef += _amountToken;
            dailyData[_day].refTkns += _amountToken;
            dailyData[_day].goals += goal;
            dailyData[_day].refNbr++;
        } else {
            stakedTokens += _amountToken;
            currentStakes++;
            stakesAT++;
            stakedTokensAT += _amountToken;
            dailyData[_day].tkns += _amountToken;
            dailyData[_day].goals += goal;
            dailyData[_day].nbr++;
        }
        return newStake;
    }
    function _removeStake(address _user,uint _stakeIndex,bool isCom,bool _restake) internal {
        if (stakesPerUser[_user] > 0) stakesPerUser[_user] -= 1;
        if (isCom) {
            currentStakesRef -= 1;
            stakedTokensRef -= stakes[_user][_stakeIndex].initTokenAmount;
        } else {
            currentStakes -= 1;
            stakedTokens -= stakes[_user][_stakeIndex].initTokenAmount;
            if (_restake == false) {
                gfamToken.transfer(
                    _user,
                    stakes[_user][_stakeIndex].initTokenAmount
                );
            }
        }
        requestedStableTokenNet -= (stakes[_user][_stakeIndex].rewardGoal -
            stakes[_user][_stakeIndex].rewardClaimed);
        totaRequestedStableToken -= (stakes[_user][_stakeIndex].rewardGoal -
            stakes[_user][_stakeIndex].rewardClaimed);
        removeItemFromArray(stakes[_user], _stakeIndex);
    }    
    function getStakeRewardPercentGlobal(address _user,uint _stakeIndex) public view returns (uint) {
        if(earningDays.length == 0 || stakes[_user].length == 0){return 0;}
        Stake storage _stake = stakes[_user][_stakeIndex];
        uint earningPoolFromStake = 0;
        if (earningDays.length == 1) {
            if (_stake.startDay < (earningDays[0] + offset)){
                earningPoolFromStake = rewardDistributionBalancePool;
            }
        } else {
            if (_stake.startDay < (earningDays[0] + offset)) {
                earningPoolFromStake += rewardsBalancePerDay[earningDays[0]];
            }
            for (uint i = earningDays.length - 1; i > 0; i--) {
                if (_stake.startDay >= (earningDays[i] + offset)) {
                    break;
                }else{
                    earningPoolFromStake += rewardsBalancePerDay[earningDays[i]];
                }
            }
        }
        uint res;
        if(rewardDistributionBalancePool <= 0 || earningPoolFromStake == 0){
            res = 0;
        }else if(earningPoolFromStake > rewardDistributionBalancePool){
            res = 1e18;
        }else{
            res = (earningPoolFromStake * 1e18) / rewardDistributionBalancePool;
        }
        return res;
    }
    function getAvailableRewarForStake(address _user,uint _stakeIndex) public view returns(uint){
        uint reward; 
        uint _reward =  ((stakes[_user][_stakeIndex].rewardGoal * rewardDistributionPoolAT * getStakeRewardPercentGlobal(_user, _stakeIndex) ) / totaRequestedStableToken) /1e18 ;
        if(_reward >= stakes[_user][_stakeIndex].rewardGoal){
            reward = stakes[_user][_stakeIndex].rewardGoal;
        }else{
            reward = _reward;
        }
        return reward;
    }
    //
    function _claim(address _user, uint _stakeIndex) internal {
        Stake storage _stake = stakes[_user][_stakeIndex];
        uint stakeReward = getAvailableRewarForStake(_user,_stakeIndex);
        uint netReward;
        bool ended = false;
        if (stakeReward >= _stake.rewardGoal) {
            ended = true;
        } 
        netReward = stakeReward - _stake.rewardClaimed;
        _stake.lastClaimDate = block.timestamp;
        _stake.lastClaimDay = block.timestamp / 1 days;
        _stake.rewardClaimed += netReward;
        _stake.ended = ended;
        //GLOBAL
        requestedStableTokenNet -= netReward;
        require(netReward>0, "Nothing to claim");
        //TRANSFER
        require(
            stableToken.balanceOf(address(this)) >= netReward,
            "Not enough stable token"
        );
        stableToken.transfer(_user, netReward);
        if (_stake.isCom && ended) {
            _removeStake(_user, _stakeIndex, _stake.isCom, false);
        }
    }
    function getPrice(uint _amount) public view returns (uint) {
        return tokenTrade.getPrice(_amount);
    }
    function removeItemFromArray(Stake[] storage array,uint256 index) internal {
        require(index < array.length, "Invalid index");
        if (index < array.length - 1) {
            array[index] = array[array.length - 1];
        }
        array.pop();
    }
    function getTokensData() public view returns (TokensData memory) {
        return
            TokensData(
                stakedTokens,
                rewardDistributionBalancePool,
                requestedStableTokenNet,
                totaRequestedStableToken,
                referralClaimsBalance,
                rewardRate,
                commissionRate,
                minDaysStake,
                currentStakes,
                stakesAT,
                stakesRefAT,
                currentStakesRef
            );
    }
    //
    function getUserStakes(address _user) public view returns (Stake[] memory) {
        return stakes[_user];
    }
    function getCurrentDay() public view returns (uint) {
        return block.timestamp / 1 days;
    }
    function addEarningDay(uint _day) internal {
        if(earningDays.length == 0){
            earningDays.push(_day);
        }
        else if (_day > earningDays[earningDays.length - 1]) {
            earningDays.push(_day);
        }
    }
    function getEarningDays() public view returns (uint[] memory) {
        return earningDays;
    }
    function getEarningDaysNbr() public view returns (uint) {
        return earningDays.length;
    }


    //IMPORT
    struct imp_stake {
        address _user;
        address _referral;
        uint _value;
        uint _price;
        uint _date;
        bool _isRefClaim;
    }
    function adm_imp_action(imp_stake[] calldata _items, uint _price, bool _innerPrice) external onlyOwner {
        for (uint i = 0; i < _items.length; i++) {
            uint _amount = _items[i]._value;
            uint price;
            if(_innerPrice == true){
                price = _items[i]._price;
            }else if(_price == 0) {
                price = getPrice(_amount);
            }else{
                price = _price;
            }
            address _user = _items[i]._user;
            address _referral = _items[i]._referral;
            uint _date = _items[i]._date;
            bool _isRefClaim = _items[i]._isRefClaim;
            if (_isRefClaim) {
                _amount = referralClaims[_user];
                if(_amount > 0){
                    __stake(_user, _amount, true, _date);
                    emit stakeCreditsEvent(
                        _user,
                        referralClaims[_user],
                        (_amount * price) / 1e18
                    );
                    referralClaims[_user] = 0;
                    referralClaimsBalance -= _amount;
                }
            } else {
                if (
                    referrals[_user] == address(0) &&
                    _referral != _user &&
                    _referral != address(0)
                ) {
                    referrals[_user] = _referral;
                }
                if (referrals[_user] != address(0) && allowRef) {
                    referralClaims[referrals[_user]] +=
                        (_amount * commissionRate) /
                        100;
                    referralClaimsBalance += (_amount * commissionRate) / 100;
                }
                __stake(_user, _amount, false, _date);
                emit stakeEvent(_user, _amount, getPrice(_amount));
            }
        }
        imported += _items.length;
    }
    function adm_imp_ref_claims(address[] calldata _users) external onlyOwner{
        for (uint i = 0; i < _users.length; i++) {
            address _user = _users[i];
            uint _amount = referralClaims[_user];
            if (_amount > 0) {
                require(_amount > 0, "Nothing to claim");
                __stake(_user, _amount, true, block.timestamp);
                emit stakeCreditsEvent(
                    _user,
                    referralClaims[_user],
                    (_amount * getPrice(_amount)) / 1e18
                );
                referralClaims[_user] = 0;
                referralClaimsBalance -= _amount;
            } 
        }
    }

    
    function adm_remove_stake(address _user,uint _stakeIndex) external onlyOwner{
        _removeStake(_user,_stakeIndex,stakes[_user][_stakeIndex].isCom,false);
    }
    //ADMIN
    function setTokenTradeContract(address _addr) external onlyOwner {
        tokenTrade = ITokenTrade(_addr);
    }
    function setRewardRate(uint _value) external onlyOwner {
        rewardRate = _value;
    }
    function setCommissionRate(uint _value) external onlyOwner {
        commissionRate = _value;
    }
    function setReferral(address _user, address _ref) external onlyOwner {
        referrals[_user] = _ref;
    }
    function setAllowRef(bool _value) external onlyOwner {
        allowRef = _value;
    }
    function setUserRef(address _user, address _ref) external onlyOwner {
        referrals[_user] = _ref;
    }
    function setOffset(uint _value) external onlyOwner {
        offset = _value;
    }
    function setMinDaysStake(uint _value) external onlyOwner {
        minDaysStake = _value;
    }
    function setAllowStakes(bool _value) external onlyOwner {
        allowStakes = _value;
    }
    function setAllowNewStakes(bool _value) external onlyOwner {
        allowNewStakes = _value;
    }
    function setAllowStakeCredits(bool _value) external onlyOwner {
        allowStakeCredits = _value;
    }
    function setStakedTokens(uint _value) external onlyOwner {
        stakedTokens = _value;
    }
    function addToRewardPool(uint _value) external onlyOwner {
        __addToRewardPool(block.timestamp / 1 days,_value);
    }
    function addToRewardPoolDay(uint _day, uint _value) external onlyOwner {
        __addToRewardPool(_day, _value);
    }
    function autoAddToRewardPool(uint _value) external onlyAllowedContract {
        __addToRewardPool(block.timestamp / 1 days,_value);
    }
    function __addToRewardPool(uint _day, uint _value) internal {
        require(_day < 1000000, "invalid day");
        earningDate = _day*1 days;
        earningDay = _day;
        rewardsBalancePerDay[earningDay] +=_value;
        rewardDistributionBalancePool += _value;
        rewardDistributionPoolAT += _value;
        cumulativeRewardsBalancePerDay[earningDay] = rewardDistributionBalancePool;
        addEarningDay(_day);
        dailyData[earningDay].reward += _value;
    }
    function substractFromRewardPool(uint _value) external onlyOwner {
        requestedStableTokenNet -= _value;
    }

    function stableTokenBalance() public view returns (uint) {
        return stableToken.balanceOf(address(this));
    }

    function gfamBalance() public view returns (uint) {
        return gfamToken.balanceOf(address(this));
    }

    function transferAllTokens(address _contract) public onlyOwner {
        gfamToken.transfer(_contract, gfamBalance());
        stableToken.transfer(_contract, stableTokenBalance());
    }
    function withdrawGfam(uint _amount) public onlyOwner {
        gfamToken.transfer(msg.sender, _amount);
    }

    function withdrawStableToken(uint _amount) public onlyOwner {
        stableToken.transfer(msg.sender, _amount);
    }

    function withdrawAllGfam() public onlyOwner {
        gfamToken.transfer(msg.sender, gfamBalance());
    }

    function withdrawAllStableToken() public onlyOwner {
        stableToken.transfer(msg.sender, stableTokenBalance());
    }

    //ALLOW
    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    modifier onlyAllowedContract() {
        require(allowedContracts[msg.sender] == true);
        _;
    }

    function allowContract(address _addr) public onlyOwner {
        allowedContracts[_addr] = true;
    }

    function disallowContract(address _addr) public onlyOwner {
        allowedContracts[_addr] = false;
    }

    
    
}

interface ITokenTrade {
    function getPrice(uint256 _amount) external view returns (uint256);
}