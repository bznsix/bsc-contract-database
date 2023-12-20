// File: @openzeppelin/contracts/token/ERC20/IERC20.sol

// SPDX-License-Identifier: MIT OR Apache-2.0
// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.20;

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
     * @dev Returns the value of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the value of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves a `value` amount of tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 value) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets a `value` amount of tokens as the allowance of `spender` over the
     * caller's tokens.
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
    function approve(address spender, uint256 value) external returns (bool);

    /**
     * @dev Moves a `value` amount of tokens from `from` to `to` using the
     * allowance mechanism. `value` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address from, address to, uint256 value) external returns (bool);
}

// File: @openzeppelin/contracts/utils/Context.sol

// OpenZeppelin Contracts (last updated v5.0.1) (utils/Context.sol)

pragma solidity ^0.8.20;

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

    function _contextSuffixLength() internal view virtual returns (uint256) {
        return 0;
    }
}

// File: @openzeppelin/contracts/access/Ownable.sol

// OpenZeppelin Contracts (last updated v5.0.0) (access/Ownable.sol)

pragma solidity ^0.8.20;

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * The initial owner is set to the address provided by the deployer. This can
 * later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    /**
     * @dev The caller account is not authorized to perform an operation.
     */
    error OwnableUnauthorizedAccount(address account);

    /**
     * @dev The owner is not a valid owner account. (eg. `address(0)`)
     */
    error OwnableInvalidOwner(address owner);

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the address provided by the deployer as the initial owner.
     */
    constructor(address initialOwner) {
        if (initialOwner == address(0)) {
            revert OwnableInvalidOwner(address(0));
        }
        _transferOwnership(initialOwner);
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
        if (owner() != _msgSender()) {
            revert OwnableUnauthorizedAccount(_msgSender());
        }
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
        if (newOwner == address(0)) {
            revert OwnableInvalidOwner(address(0));
        }
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

// File: contracts/IPancakeRouter01.sol

pragma solidity >=0.6.2;

interface IPancakeRouter01 {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    )
        external
        returns (
            uint256 amountA,
            uint256 amountB,
            uint256 liquidity
        );

    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    )
        external
        payable
        returns (
            uint256 amountToken,
            uint256 amountETH,
            uint256 liquidity
        );

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETH(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountToken, uint256 amountETH);

    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETHWithPermit(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountToken, uint256 amountETH);

    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapTokensForExactTokens(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactETHForTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function swapTokensForExactETH(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactTokensForETH(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapETHForExactTokens(
        uint256 amountOut,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function quote(
        uint256 amountA,
        uint256 reserveA,
        uint256 reserveB
    ) external pure returns (uint256 amountB);

    function getAmountOut(
        uint256 amountIn,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountOut);

    function getAmountIn(
        uint256 amountOut,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountIn);

    function getAmountsOut(uint256 amountIn, address[] calldata path) external view returns (uint256[] memory amounts);

    function getAmountsIn(uint256 amountOut, address[] calldata path) external view returns (uint256[] memory amounts);
}

// File: contracts/IPancakeRouter02.sol

pragma solidity >=0.6.2;

interface IPancakeRouter02 is IPancakeRouter01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountETH);

    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
}

// File: contracts/OutPool.sol

pragma solidity ^0.8.20; 



contract OutPool is Ownable {
    struct UserInfo {
        uint256 currentStakeIndex;
        uint256 purchasedAmount;
        uint256 withdrawalAmount;
        uint256 totalWithdrawn;
        uint256 purchaseTime;
        uint256 withdrawalTime;
        uint256 emergencyWithdrawAmount;
        uint256 emergencyWithdrawTime;
        uint256 totalAdditionalPurchases;
        uint256 lastAdditionalPurchaseTime;
        Stake[] stakes;
    }

    struct Stake {
        uint256 lockupPeriodId;
        uint256 stakeIndex;
        uint256 purchaseTime;
        uint256 amount;
        uint256 additionalAmount;
        uint256 lastAddedTime;
    }

    struct LockupPeriod {
        uint256 id;
        uint256 timeInSeconds;
        uint256 rewardRate;
    }

    Contributor[] public contributors;

    struct Contributor {
        address payable contributorAddress;
        uint256 rewardPercentage; 
    }

    struct RewardData {
        uint256 totalAccumulated;
        mapping(address => uint256) claimedRewards;
    }

    RewardData private rewardData;

    uint256 public purchaseLimit;
    uint256 public rewardPercentage;
    uint256 public additionalPurchaseLimitInBNB;
    uint256 public totalPurchased;
    uint256 public totalPurchaseLimit;

    IERC20 public token;

    constructor(address _tokenAddress, uint256 _purchaseLimit, address _routerAddress) Ownable(msg.sender) {
        token = IERC20(_tokenAddress);
        purchaseLimit = _purchaseLimit;
        pancakeRouter = IPancakeRouter02(_routerAddress);
    }

    IPancakeRouter02 public pancakeRouter;

    mapping(address => UserInfo) public userInfo;
    mapping(uint256 => LockupPeriod) public lockupPeriods;
    mapping(address => uint256) public pendingRewards;

    event LiquidityAdded(uint256 amount);
    event LiquidityReclaimed(uint256 amount, uint256 remainingLiquidity);
    
    function addLiquidity(uint256 tokenAmount) public onlyOwner {
        require(tokenAmount > 0, "Token amount must be greater than zero.");
        require(token.transferFrom(msg.sender, address(this), tokenAmount), "Token transfer failed.");

        emit LiquidityAdded(tokenAmount);
    }
    function getTotalLiquidity() public view returns (uint256) {
        return token.balanceOf(address(this));
    }

    function setTotalPurchaseLimit(uint256 _limit) public onlyOwner {
        totalPurchaseLimit = _limit;
    }

    function setContributors(Contributor[] memory newContributors) public onlyOwner {
        delete contributors;
        for (uint i = 0; i < newContributors.length; i++) {
            contributors.push(newContributors[i]);
        }
    }

    function addLockupPeriod(uint256 _id, uint256 timeInSeconds, uint256 rewardRate) public onlyOwner {
        lockupPeriods[_id] = LockupPeriod({
            id: _id,
            timeInSeconds: timeInSeconds,
            rewardRate: rewardRate
        });
    }

    function reclaimLiquidity(uint256 amount) public onlyOwner {
        uint256 currentLiquidity = getTotalLiquidity();
        require(amount <= currentLiquidity, "Quantity exceeds available liquidity.");
                require(token.transfer(owner(), amount), "Token transfer failed.");

        emit LiquidityReclaimed(amount, currentLiquidity - amount);
    }

    event Purchase(address indexed user, address token, uint256 amount);

    function callStake(uint256 lockupPeriodId, uint256 slippageTolerance) public payable {
        if (msg.sender != owner()) {
            require(!circuitBreaker, "Purchases are currently paused.");
        }
        require(!frozenAccounts[msg.sender], "Account is frozen.");
        require(msg.value > 0, "Need to send BNB");
        require(lockupPeriods[lockupPeriodId].timeInSeconds > 0, "Invalid lockup period");

        address[] memory path = new address[](2);
        path[0] = pancakeRouter.WETH();
        path[1] = address(token);

        uint deadline = block.timestamp + 15;
        uint[] memory amounts = pancakeRouter.getAmountsOut(msg.value, path);
        uint256 tokensEquivalent = amounts[1];
        LockupPeriod memory selectedLockupPeriod = lockupPeriods[lockupPeriodId];
        uint256 rewardForPurchase = (tokensEquivalent * selectedLockupPeriod.rewardRate) / 100;
        uint256 totalRequirement = tokensEquivalent + rewardForPurchase;
        require(token.balanceOf(address(this)) >= totalRequirement, "Purchase exceeds available liquidity with rewards.");

        uint amountOutMin = amounts[1] * (100 - slippageTolerance) / 100;

        pancakeRouter.swapExactETHForTokens{value: msg.value}(
            amountOutMin,
            path,
            address(this),
            deadline
        );

        uint256 tokensBought = amounts[1];
        require(totalPurchased + tokensBought <= totalPurchaseLimit, "Total purchase limit exceeded");

        UserInfo storage user = userInfo[msg.sender];
        user.purchasedAmount += tokensBought; 
        user.purchaseTime = block.timestamp;
        totalPurchased += tokensBought;

        user.stakes.push(Stake({
            lockupPeriodId: lockupPeriodId,
            stakeIndex: user.stakes.length,
            purchaseTime: block.timestamp,
            amount: tokensBought,
            additionalAmount: 0, 
            lastAddedTime: 0   
        }));

        user.currentStakeIndex = user.stakes.length - 1;

        if (contributors.length > 0) {
            for (uint i = 0; i < contributors.length; i++) {
                uint256 rewardAmount = (tokensBought * contributors[i].rewardPercentage) / 10000;
                pendingRewards[contributors[i].contributorAddress] += rewardAmount;
            }
        }

        emit Purchase(msg.sender, address(token), tokensBought);
    }

    function claimRewardsForContributors(address[] calldata contributorAddresses) public onlyOwner {
        for (uint256 i = 0; i < contributorAddresses.length; i++) {
            address contributor = contributorAddresses[i];
            uint256 rewardAmount = getRewardAmount(contributor);
            if (rewardAmount > 0) {
                rewardData.claimedRewards[contributor] += rewardAmount;
                require(token.transfer(contributor, rewardAmount), "Reward transfer failed");
            }
        }
    }
    function accumulateReward(uint256 amount) private {
        rewardData.totalAccumulated += amount;
        for (uint i = 0; i < contributors.length; i++) {
            uint256 contributorShare = (amount * contributors[i].rewardPercentage) / 10000;
            pendingRewards[contributors[i].contributorAddress] += contributorShare;
        }
    }

    function claimRewards() public {
        uint256 rewardAmount = pendingRewards[msg.sender];
        require(rewardAmount > 0, "No rewards to claim");
        pendingRewards[msg.sender] = 0;
        require(token.transfer(msg.sender, rewardAmount), "Reward transfer failed");
    }
    
    function getRewardAmount(address contributorAddress) public view returns (uint256) {
        uint256 totalRewardAmount = rewardData.totalAccumulated;
        uint256 claimed = rewardData.claimedRewards[contributorAddress];

        for (uint i = 0; i < contributors.length; i++) {
            if (contributors[i].contributorAddress == contributorAddress) {
                uint256 contributorRewardPercentage = contributors[i].rewardPercentage;
                uint256 rewardAmount = (totalRewardAmount * contributorRewardPercentage) / 10000 - claimed;
                return rewardAmount;
            }
        }

        return 0;
    }

    function withdraw(uint256 stakeIndex) public {
        require(stakeIndex < userInfo[msg.sender].stakes.length, "Invalid stake index.");

        Stake storage stake = userInfo[msg.sender].stakes[stakeIndex];
        require(stake.amount > 0, "Stake already withdrawn or non-existent.");
        uint256 lockupTime = lockupPeriods[stake.lockupPeriodId].timeInSeconds;
        uint256 startTime = stake.lastAddedTime > 0 ? stake.lastAddedTime : stake.purchaseTime;
        require(block.timestamp >= startTime + lockupTime, "Lockup period not yet elapsed.");

        uint256 reward = (stake.amount * lockupPeriods[stake.lockupPeriodId].rewardRate) / 100;
        uint256 totalAmount = stake.amount + reward;
        require(token.balanceOf(address(this)) >= totalAmount, "Insufficient contract balance for rewards.");

        require(token.transfer(msg.sender, totalAmount), "Token transfer failed.");

        userInfo[msg.sender].totalWithdrawn += totalAmount;
        userInfo[msg.sender].stakes[stakeIndex].amount = 0;
    }

    function emergencyWithdraw(uint256 stakeIndex) public {
        require(stakeIndex < userInfo[msg.sender].stakes.length, "Invalid stake index.");

        Stake storage stake = userInfo[msg.sender].stakes[stakeIndex];
        require(stake.amount > 0, "No funds to withdraw or already withdrawn.");
        uint256 lockupTime = lockupPeriods[stake.lockupPeriodId].timeInSeconds;
        require(block.timestamp < stake.purchaseTime + lockupTime, "Lockup period already elapsed.");
        require(token.transfer(msg.sender, stake.amount), "Token transfer failed.");

        userInfo[msg.sender].emergencyWithdrawAmount += stake.amount;
        userInfo[msg.sender].emergencyWithdrawTime = block.timestamp;
        userInfo[msg.sender].totalWithdrawn += stake.amount;
        stake.amount = 0; 
    }

    function addFundsToStake(uint256 stakeIndex, uint256 lockupPeriodId) public payable {
        require(msg.value <= additionalPurchaseLimitInBNB, "Additional purchase exceeds limit in BNB.");
        require(msg.value > 0, "Amount must be greater than zero.");
        require(stakeIndex < userInfo[msg.sender].stakes.length, "Invalid stake index.");
        Stake storage stake = userInfo[msg.sender].stakes[stakeIndex];
        require(stake.amount > 0, "Stake does not exist or already withdrawn.");
        require(lockupPeriods[lockupPeriodId].timeInSeconds > 0, "Invalid lockup period.");

        uint256 lockupEndTime = stake.purchaseTime + lockupPeriods[stake.lockupPeriodId].timeInSeconds;
        require(block.timestamp < lockupEndTime, "Lockup period already elapsed.");

        uint256 initialBalance = token.balanceOf(address(this));

        address[] memory path = new address[](2);
        path[0] = pancakeRouter.WETH();
        path[1] = address(token);

        uint256 hardcodedSlippageTolerance = 12; 
        uint256 hardcodedDeadline = 15 minutes;

        uint[] memory amounts = pancakeRouter.getAmountsOut(msg.value, path);
        uint256 amountOutMin = amounts[1] * (100 - hardcodedSlippageTolerance) / 100;

        pancakeRouter.swapExactETHForTokens{value: msg.value}(
            amountOutMin,
            path,
            address(this),
            block.timestamp + hardcodedDeadline
        );

        uint256 elapsed = block.timestamp - stake.purchaseTime;
        uint256 accumulatedReward = (stake.amount * lockupPeriods[stake.lockupPeriodId].rewardRate * elapsed) / (lockupPeriods[stake.lockupPeriodId].timeInSeconds * 100);

        uint256 tokensBought = token.balanceOf(address(this)) - initialBalance;

        uint256 newStakeAmount = stake.amount + accumulatedReward + tokensBought;

        stake.amount = newStakeAmount;

        require(totalPurchased + tokensBought <= totalPurchaseLimit, "Total purchase limit exceeded");

        totalPurchased += tokensBought;

        LockupPeriod memory selectedLockupPeriod = lockupPeriods[lockupPeriodId];
        uint256 rewardForAdditionalPurchase = (tokensBought * selectedLockupPeriod.rewardRate) / 100;

        require(token.balanceOf(address(this)) >= newStakeAmount + rewardForAdditionalPurchase, "Purchase and rewards exceed available liquidity.");

        if (contributors.length > 0) {
            for (uint i = 0; i < contributors.length; i++) {
                uint256 rewardAmount = (tokensBought * contributors[i].rewardPercentage) / 10000;
                pendingRewards[contributors[i].contributorAddress] += rewardAmount;
            }
        }

        userInfo[msg.sender].totalAdditionalPurchases += tokensBought;
        userInfo[msg.sender].lastAdditionalPurchaseTime = block.timestamp;

        stake.lastAddedTime = block.timestamp;
        stake.additionalAmount += tokensBought;
        stake.lockupPeriodId = lockupPeriodId;
    }

    function setAdditionalPurchaseLimitInBNB(uint256 _limitInBNB) public onlyOwner {
        additionalPurchaseLimitInBNB = _limitInBNB;
    }

    function getRemainingLockupTime(address userAddress, uint256 stakeIndex) public view returns (uint256) {
        require(stakeIndex < userInfo[userAddress].stakes.length, "Invalid stake index.");
        Stake storage stake = userInfo[userAddress].stakes[stakeIndex];

        uint256 lockupDuration = lockupPeriods[stake.lockupPeriodId].timeInSeconds;
        uint256 startTime = stake.lastAddedTime > 0 ? stake.lastAddedTime : stake.purchaseTime;
        uint256 endTime = startTime + lockupDuration;

        if (block.timestamp >= endTime) {
            return 0; 
        } else {
            return endTime - block.timestamp; 
        }
    }

    bool public circuitBreaker;

    function setBreaker(bool _state) public onlyOwner {
        circuitBreaker = _state;
    }

    mapping(address => bool) private frozenAccounts;

    event AccountFrozen(address indexed user);
    event AccountUnfrozen(address indexed user);

    function freezeWallet(address user) public onlyOwner {
        require(user != address(this), "Cannot freeze the contract address.");
        require(user != owner(), "Cannot freeze the owner's address.");
        require(!frozenAccounts[user], "Account is already frozen.");
        frozenAccounts[user] = true;
        emit AccountFrozen(user);
    }

    function unfreezeWallet(address user) public onlyOwner {
        require(user != address(this), "The contract address should not be considered.");
        require(user != owner(), "The owner's address should not be considered.");
        require(frozenAccounts[user], "Account is already unfrozen.");
        frozenAccounts[user] = false;
        emit AccountUnfrozen(user);
    }

    function getStakeAmount(address userAddress, uint256 stakeIndex) public view returns (uint256) {
        require(stakeIndex < userInfo[userAddress].stakes.length, "Invalid stake index.");

        Stake storage stake = userInfo[userAddress].stakes[stakeIndex];
        return stake.amount + stake.additionalAmount;
    }

    function getAccumulatedReward(address userAddress, uint256 stakeIndex) public view returns (uint256) {
        require(stakeIndex < userInfo[userAddress].stakes.length, "Invalid stake index.");

        Stake storage stake = userInfo[userAddress].stakes[stakeIndex];
        LockupPeriod storage lockupPeriod = lockupPeriods[stake.lockupPeriodId];

        uint256 lastInteractionTime = stake.lastAddedTime > 0 ? stake.lastAddedTime : stake.purchaseTime;
        uint256 elapsedTime = block.timestamp > lastInteractionTime ? block.timestamp - lastInteractionTime : 0;

        uint256 initialReward = (stake.amount * lockupPeriod.rewardRate * elapsedTime) / (lockupPeriod.timeInSeconds * 100);

        uint256 additionalReward = (stake.additionalAmount * lockupPeriod.rewardRate * elapsedTime) / (lockupPeriod.timeInSeconds * 100);

        return initialReward + additionalReward;
    }
}