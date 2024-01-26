// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19;


abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private _NOT_ENTERED;
    uint256 private _ENTERED;

    uint256 private _status;

    constructor() {
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        _nonReentrantBefore();
        _;
        _nonReentrantAfter();
    }

    function initializeGuard() internal {
        _NOT_ENTERED = 1;
        _ENTERED = 2;
        _status = _NOT_ENTERED;

    }

    function _nonReentrantBefore() private {
        // On the first call to nonReentrant, _status will be _NOT_ENTERED
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;
    }

    function _nonReentrantAfter() private {
        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Returns true if the reentrancy guard is currently set to "entered", which indicates there is a
     * `nonReentrant` function in the call stack.
     */
    function _reentrancyGuardEntered() internal view returns (bool) {
        return _status == _ENTERED;
    }
}

interface IERC20 {
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address to, uint256 amount) external returns (bool);

    function allowance(
        address owner,
        address spender
    ) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

interface IERC20Metadata is IERC20 {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

contract Ownable {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    modifier onlyOwner() {
        require(
            _owner == msg.sender,
            "Ownable: only owner can call this function"
        );
        _;
    }

    constructor() {}

    function initilizeOwner() internal {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    function initlizeERC20(
        string memory name_,
        string memory symbol_
    ) internal {
        _name = name_;
        _symbol = symbol_;
    }

    function name() public view virtual override returns (string memory) {
        return _name;
    }

    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    function decimals() public view virtual override returns (uint8) {
        return 8;
    }

    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(
        address account
    ) public view virtual override returns (uint256) {
        return _balances[account];
    }

    function transfer(
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    function allowance(
        address owner,
        address spender
    ) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(
        address spender,
        uint256 amount
    ) public virtual override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    function increaseAllowance(
        address spender,
        uint256 addedValue
    ) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, allowance(owner, spender) + addedValue);
        return true;
    }

    function decreaseAllowance(
        address spender,
        uint256 subtractedValue
    ) public virtual returns (bool) {
        address owner = _msgSender();
        uint256 currentAllowance = allowance(owner, spender);
        require(
            currentAllowance >= subtractedValue,
            "ERC20: decreased allowance below zero"
        );
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        require(
            fromBalance >= amount,
            "ERC20: transfer amount exceeds balance"
        );

        _balances[from] = fromBalance - amount;

        _balances[to] += amount;

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        unchecked {
            _balances[account] += amount;
        }
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal {
        require(
            account != address(0),
            "TLCC: cannot burn from zero address"
        );
        require(
            _balances[account] >= amount,
            "TLCC: Cannot burn more than the account owns"
        );
        _balances[account] = _balances[account] - amount;
        _totalSupply = _totalSupply - amount;
        emit Transfer(account, address(0), amount);
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(
                currentAllowance >= amount,
                "ERC20: insufficient allowance"
            );
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
}

contract TLCC is ERC20, Ownable, ReentrancyGuard {
    constructor() {}

    bool _initilize;
    uint256 private devFee;
    uint256 private MAX_SUPPLY;
    uint256 private minStakeAmount;
    uint256 private maxStakeAmount;
    uint256 private rewardSupply;
    uint256 private totalStakingReward;
    uint256[] private stakingPlans;

    address feeAddress;
    address[] internal stakers;

    struct Stake {
        address _address;
        uint256 _amount;
        uint256 _stakeTime;
        uint256 _unlockTime;
        uint256 _rewardROI;
        uint256 _rewardAmount;
    }

    modifier isInitialize() {
        require(!_initilize, "contract is already initilize");
        _;
    }

    mapping(uint256 plan => uint256 _roi) ROIPlan;
    mapping(address user => uint256 lastIndex) userStakeIndex;
    mapping(address user => mapping(uint256 index => Stake stakeDetails)) userStakeDetails;
    mapping(address owner => bool unique) unique_stakers;

    event NewROI(uint256 _time, uint256 _roi);

    event ChangeFeeAddress(address _address);

    event Staked(
        address _user,
        uint256 _amount,
        uint256 _stakeTime,
        uint256 _unlockTime,
        uint256 _roi
    );

    event WithdrawStake(
        address _address,
        uint256 _amount,
        uint256 _reward,
        uint256 _at
    );

    event FeeTransfer(address _address, uint256 _amount, uint256 _at);

    event RewardMintedForRestake(
        address _address,
        uint256 _rewardAmount,
        uint256 index
    );

    event DevFeeChange(uint256 _from, uint256 _to);
    event ChangeMinStake(uint256 _from, uint256 _to);
    event ChangeMaxStake(uint256 _from, uint256 _to);
    event ChangeROI(uint256 _plan, uint256 _from, uint256 _to);

    function initialize() external isInitialize {
        initlizeERC20("The Love Care Coin", "TLCC");
        initilizeOwner();
        initializeGuard();
        _initilize = true;

        uint256 tSupply = 4_200_000_000 * 10 ** decimals();
        uint256 teamWallet = 840_000_000 * 10 ** decimals();
        uint256 devWallet = 630_000_000 * 10 ** decimals();
        uint256 marketingWallet = 630_000_000 * 10 ** decimals();
        uint256 publicSaleWallet = 840_000_000 * 10 ** decimals();
        totalStakingReward =
            tSupply -
            (teamWallet + devWallet + marketingWallet + publicSaleWallet);
        rewardSupply = totalStakingReward;

        MAX_SUPPLY = tSupply;

        devFee = 5;


        feeAddress = msg.sender;

        ROIPlan[7776000] = 200; // 90 days
        ROIPlan[15552000] = 500; // 180 days
        ROIPlan[23328000] = 800; // 270 days
        ROIPlan[31104000] = 1100; // 360 days

        stakingPlans.push(7776000);
        stakingPlans.push(15552000);
        stakingPlans.push(23328000);
        stakingPlans.push(31104000);

        _mint(0x84C865054F12b9cC06a35411000AbddEaa99Dd8F, teamWallet); // Team Wallet
        _mint(0xcb1D6e0fB85d527723311a8C31B4D2D62323B3b5, devWallet); // Development Wallet
        _mint(0x3FC2fA2c6f8be2Ee1a74CbEB5db7e648ea663bae, marketingWallet); // Marketing Wallet
        _mint(0xE3CfaCB7EAFe9f21f61128BAb4fC42A4C6C49c9B, publicSaleWallet); // Public Sale Wallet

        minStakeAmount = 5000 * (10 ** decimals());
        maxStakeAmount = 1_000_000 * (10 ** decimals());
    }

    // #####################################################################
    // ############################## Admin ################################
    // #####################################################################

    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }

    function burn(address from, uint256 amount) public onlyOwner {
        _burn(from, amount);
    }

    function setMinStakeAmount(uint256 _amount) external onlyOwner {
        uint256 _temp = minStakeAmount;
        minStakeAmount = _amount;
        emit ChangeMinStake(_temp, minStakeAmount);
    }

    function setMaxStakeAmount(uint256 _amount) external onlyOwner {
        uint256 _temp = maxStakeAmount;
        maxStakeAmount = _amount;
        emit ChangeMaxStake(_temp, maxStakeAmount);
    }

    function changeDevFeeAmount(uint256 _amount) external onlyOwner {
        uint256 _temp = devFee;
        devFee = _amount;
        emit DevFeeChange(_temp, devFee);
    }

    function addNewROI(uint256 _days, uint256 _RoI) external onlyOwner {
        require(ROIPlan[_days] == 0, "Plan already Exist");
        ROIPlan[_days] = _RoI;
        stakingPlans.push(_days);
        emit NewROI(_days, _RoI);
    }

    function changeROI(uint256 _days, uint256 _RoI) external onlyOwner {
        require(ROIPlan[_days] != 0, "Plan does not Exist");
        uint256 _temp = ROIPlan[_days];
        ROIPlan[_days] = _RoI;
        emit ChangeROI(_days, _temp, ROIPlan[_days]);
    }

    function changeFeeAddress(address _address) external onlyOwner {
        feeAddress = _address;
        emit ChangeFeeAddress(_address);
    }

    // #####################################################################
    // ############################# Private ###############################
    // #####################################################################

    function _stake(
        uint256 _amount,
        uint256 _plan,
        uint256 index
    ) private returns (bool) {
        uint256 rewardAmount = (_amount * ROIPlan[_plan]) / 10000;

        userStakeDetails[msg.sender][index] = Stake({
            _address: msg.sender,
            _amount: _amount,
            _stakeTime: block.timestamp,
            _unlockTime: block.timestamp + _plan,
            _rewardROI: ROIPlan[_plan],
            _rewardAmount: rewardAmount
        });

        emit Staked(
            msg.sender,
            _amount,
            block.timestamp,
            block.timestamp + _plan,
            ROIPlan[_plan]
        );

        return true;
    }

    function restakeReward(
        uint256 index,
        uint256 _plan,
        bool withReward
    ) private {
        require(ROIPlan[_plan] != 0, "Invalid plan");
        uint256 _amount = userStakeDetails[msg.sender][index]._amount;
        if (withReward) {
            uint256 rewardAmount = userStakeDetails[msg.sender][index]._rewardAmount;
            rewardAmount -= ((rewardAmount * devFee) / 100);
            _amount += rewardAmount;
        }
        _stake(_amount, _plan, index);
    }

    function _calculateStake(
        uint256 index
    ) private view returns (uint256, uint256, uint256) {
        uint256 amount = userStakeDetails[msg.sender][index]._amount;
        uint256 reward = userStakeDetails[msg.sender][index]._rewardAmount;
        uint256 devReward = (reward * devFee) / 100;
        reward -= devReward;
        return (amount, reward, devReward);
    }

    function _withdrawStakeWithZeroReward(uint256 index) private {
        uint256 stakedAmount = userStakeDetails[msg.sender][index]._amount;
        require(stakedAmount > 0, "Staking: Stake is zero");

        delete userStakeDetails[msg.sender][index];

        _transfer(address(this), msg.sender, stakedAmount);

        emit WithdrawStake(msg.sender, stakedAmount, 0, block.timestamp);
    }

    function mintReward(
        uint256 amountStaked,
        uint256 userReward,
        uint256 devReward
    ) private {
        _mint(msg.sender, userReward);
        _mint(feeAddress, devReward);
        _transfer(address(this), msg.sender, amountStaked);
    }

    function reduceRewardSupply(uint amount) private {
        rewardSupply -= amount;
    }

    function mintDevReward(uint256 devReward) private {
        _mint(feeAddress, devReward);
        emit FeeTransfer(msg.sender, devReward, block.timestamp);
    }

    // #####################################################################
    // ############################# External ##############################
    // #####################################################################

    function stake(uint256 _amount, uint256 _plan) external nonReentrant returns (uint256) {
        require(
            _amount >= minStakeAmount && _amount <= maxStakeAmount,
            "TLCC: Invalid Stake Amount"
        );

        require(ROIPlan[_plan] != 0, "TLCC: Invalid plan");

        _transfer(msg.sender, address(this), _amount);

        uint256 index = userStakeIndex[msg.sender];
        bool success = _stake(_amount, _plan, index);
        require(success, "TLCC: Stake Failed");

        userStakeIndex[msg.sender] += 1;

        // this staker will be permenet and it will not be deleted 
        if (!unique_stakers[msg.sender]) {
            stakers.push(msg.sender);
            unique_stakers[msg.sender] = true;
        }

        return index;
    }

    function withdrawStake(
        uint256 index,
        uint256 _plan,
        bool restake,
        bool restakeWithRewardAmount
    ) external nonReentrant returns (bool) {
        require(
            userStakeDetails[msg.sender][index]._amount > 0,
            "TLCC: Invalid Index"
        );

        require(
            userStakeDetails[msg.sender][index]._unlockTime < block.timestamp,
            "TLCC: You can not withdraw or restake at this time for this index"
        );

        uint256 _amountStaked;
        uint256 _devReward;
        uint256 _userReward;

        if (getRemainingReward() > 0) {
            (_amountStaked, _userReward, _devReward) = _calculateStake(index);

            if ((_userReward + _devReward) > 0) {
                if ((_userReward + _devReward) < getRemainingReward()) {
                    reduceRewardSupply(_userReward + _devReward);
                } else {
                    _userReward = getRemainingReward();
                    _devReward = (_userReward * devFee) / 100;
                    _userReward -= _devReward;
                    rewardSupply = 0;
                }
                if (restake) {
                    if (restakeWithRewardAmount) {
                        restakeReward(index, _plan, true);
                        _mint(address(this), _userReward);
                    } else {
                        restakeReward(index, _plan, false);
                        _mint(msg.sender, _userReward);
                    }
                    mintDevReward(_devReward);
                    emit RewardMintedForRestake(
                        msg.sender,
                        _userReward,
                        block.timestamp
                    );
                } else {
                    mintReward(_amountStaked, _userReward, _devReward);

                    delete userStakeDetails[msg.sender][index];

                    emit WithdrawStake(
                        msg.sender,
                        _amountStaked,
                        _userReward,
                        block.timestamp
                    );
                }
            } else {
                require(
                    !restake,
                    "You can not restake this index before you get your reward"
                );
                _transfer(address(this), msg.sender, _amountStaked);
                delete userStakeDetails[msg.sender][index];
            }
        } else {
            require(
                !restake,
                "You can not restake your reward now because reward is empty"
            );
            _withdrawStakeWithZeroReward(index);
        }

        return true;
    }

    // #####################################################################
    // ############################# View ##################################
    // #####################################################################

    function hashStake(
        address _address
    ) external view returns (Stake[] memory) {
        uint256 totalIndexOfUser = userStakeIndex[_address];

        Stake[] memory _staked = new Stake[](totalIndexOfUser);

        for (uint256 i; i < totalIndexOfUser; i++) {
            _staked[i] = userStakeDetails[_address][i];
        }

        return _staked;
    }

    function viewStakedIndex(
        address _address,
        uint256 _index
    ) external view returns (Stake memory) {
        return userStakeDetails[_address][_index];
    }

    function calculateReward(
        uint256 _amount,
        uint256 _plan
    ) external view returns (uint256) {
        return (_amount * ROIPlan[_plan]) / 10000;
    }

    function getStakingPlans() view external returns(uint256[] memory, uint256[] memory) {
        uint256 len = stakingPlans.length;
        uint256[] memory plans = new uint256[](len);
        uint256[] memory roi = new uint256[](len);

        for (uint i = 0; i < len; i++) {
            plans[i] = stakingPlans[i];
            roi[i] = ROIPlan[plans[i]];
        }
        return (plans, roi);
    }


    function getStakers(uint256 _from, uint256 _to) view external returns(address[] memory) {
        uint256 len = (_to - _from) + 1;
        address[] memory _stakers = new address[](len);
        uint256 index = 0; // Initialize index to 0

        for (uint i = _from; i <= _to; i++) {
            _stakers[index] = stakers[i];
            index++; // Increment index for next iteration
        }

        return _stakers;
    }

    function getTotalStakerCount() view external returns(uint256) {
        return stakers.length;
    }

    function getFeeRecevier() view external returns(address) {
        return feeAddress;
    }

    function getAllStakers() view external returns(address[] memory) {
        return stakers;
    }

    function getRemainingReward() public view returns (uint256) {
        return rewardSupply;
    }

    function totalMaxSupply() external view returns (uint256) {
        return MAX_SUPPLY;
    }

    function withdrawBNB() external onlyOwner {
        payable(owner()).transfer(address(this).balance);
    }

    function withdrawToken(address _token, uint256 _amount) external onlyOwner {
        bool success = IERC20(_token).transfer(owner(), _amount);
        require(success, "transfer fail");
    }

    function getMinimumStakingAmount() external view returns (uint256) {
        return minStakeAmount;
    }

    function getMaximumStakingAmount() external view returns (uint256) {
        return maxStakeAmount;
    }

    function getDevFee() external view returns (uint256) {
        return devFee;
    }

    fallback() external payable {}

    receive() external payable {
        payable(owner()).transfer(msg.value);
    }
}