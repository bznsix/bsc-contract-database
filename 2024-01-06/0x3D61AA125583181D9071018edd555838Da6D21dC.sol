// File: @openzeppelin/contracts@4.7.0/security/ReentrancyGuard.sol


// OpenZeppelin Contracts v4.4.1 (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
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
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}

// File: @openzeppelin/contracts@4.7.0/token/ERC20/IERC20.sol


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

// File: github/tomdef1/Contracts/Staking_ASX_001.sol


// 0.8.19 as deploying on BNB
pragma solidity 0.8.19;

// 4.7.0 as compatible with non PUSH0 chains ie BNB & 0.8.19



// Declaring the contract
contract Staking_ASX_001 is ReentrancyGuard {
    // State variables
    IERC20 public stakingToken;            // Token users will stake
    IERC20 public rewardToken;             // Token users will earn as rewards

    address public owner;                  // Owner of the contract
    uint256 public lockupPeriod;           // Time that must pass before stakers can withdraw
    uint256 public stakingPeriodLength;    // Total length of the staking period
    bool public stakingActive = false;     // Indicates if the staking period is currently active
    uint256 public startTime;              // When the current staking period started
    uint256 public totalStaked;            // Total amount of tokens staked
    uint256 public totalRewards;           // Total amount of rewards to distribute
    uint256 public rewardsDistributed;     // Total rewards distributed so far

    // Mappings
    mapping(address => uint256) public stakes;          // Amount staked by each address
    mapping(address => uint256) public lastStakedTime;  // Last time each address staked
    mapping(address => uint256) public rewards;         // Rewards owed to each address
    mapping(address => bool) public isController;       // Addresses allowed to perform certain restricted actions

    // Events
    event Staked(address indexed user, uint256 amount, uint256 total);
    event Withdrawn(address indexed user, uint256 amount);
    event RewardPaid(address indexed user, uint256 reward);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event StakingPeriodEnded(uint256 remainingRewards);

    // Modifiers
    modifier onlyOwner() {
        require(msg.sender == owner, "Caller is not the owner");
        _;
    }

    modifier onlyController() {
        require(isController[msg.sender], "Caller is not a controller");
        _;
    }

    // Constructor
    constructor(
        uint256 _stakingPeriodLength,
        uint256 _lockupPeriod,
        address _stakingToken,
        address _rewardToken,
        uint256 _totalRewards
    ) {
        owner = msg.sender;                   // Sets the contract deployer as the owner
        stakingPeriodLength = _stakingPeriodLength;
        lockupPeriod = _lockupPeriod;
        stakingToken = IERC20(_stakingToken);
        rewardToken = IERC20(_rewardToken);
        totalRewards = _totalRewards;
    }

    // Functions

    // Starts the staking period
    function start() external onlyOwner {
        require(!stakingActive, "Staking already started");
        stakingActive = true;
        startTime = block.timestamp;
        rewardsDistributed = 0;
    }

    // Allows users to stake tokens
    function stake(uint256 amount) external nonReentrant {
        require(amount > 0, "Cannot stake 0");
        require(stakingToken.transferFrom(msg.sender, address(this), amount), "Stake failed");

        if (stakingActive && stakes[msg.sender] > 0) {
            rewards[msg.sender] += calculateReward(msg.sender);
        }

        stakes[msg.sender] += amount;
        totalStaked += amount;
        lastStakedTime[msg.sender] = block.timestamp;

        emit Staked(msg.sender, amount, stakes[msg.sender]);
    }

    // Allows users to withdraw their staked tokens
    function withdraw(uint256 amount) external nonReentrant {
        require(stakes[msg.sender] >= amount, "Withdrawing more than you have!");
        require(block.timestamp - lastStakedTime[msg.sender] > lockupPeriod, "Lockup period not yet passed");

        if (stakingActive) {
            rewards[msg.sender] += calculateReward(msg.sender);
        }

        stakes[msg.sender] -= amount;
        totalStaked -= amount;
        require(stakingToken.transfer(msg.sender, amount), "Withdraw failed");

        emit Withdrawn(msg.sender, amount);
    }

    // Allows users to claim their rewards
    function claimRewards() external nonReentrant {
        if (stakingActive) {
            rewards[msg.sender] += calculateReward(msg.sender);
        }
        
        uint256 reward = rewards[msg.sender];
        if (reward > 0) {
            rewards[msg.sender] = 0; // Prevent re-entrancy attack
            rewardsDistributed += reward;
            require(rewardToken.transfer(msg.sender, reward), "Reward transfer failed");
            emit RewardPaid(msg.sender, reward);
        }
    }

    // Internal function to calculate rewards
    function calculateReward(address user) internal view returns (uint256) {
        uint256 stakedAmount = stakes[user];
        if (stakedAmount == 0) {
            return 0;
        }
        uint256 timeStaked = stakingActive ? block.timestamp - lastStakedTime[user] : stakingPeriodLength;
        uint256 reward = (stakedAmount * timeStaked * totalRewards) / (totalStaked * stakingPeriodLength);
        return reward;
    }

    // Ends the current staking period and returns any remaining rewards to the owner
    function endStakingPeriod() external onlyOwner {
        require(stakingActive, "Staking is not currently active");
        stakingActive = false;
        uint256 remainingRewards = totalRewards - rewardsDistributed;
        if (remainingRewards > 0) {
            require(rewardToken.transfer(owner, remainingRewards), "Failed to return remaining rewards");
        }
        emit StakingPeriodEnded(remainingRewards);
    }

    // Transfers ownership of the contract to a new owner
    function transferOwnership(address newOwner) external onlyOwner {
        require(newOwner != address(0), "New owner is the zero address");
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }

    // Functions to change constructor perameters after deployment
    // Setter function to change the staking period length
    function setStakingPeriodLength(uint256 newLength) external onlyOwner {
        require(newLength > 0, "Staking period length must be greater than 0");
        stakingPeriodLength = newLength;
    }

    // Setter function to change the lockup period
    function setLockupPeriod(uint256 newLockupPeriod) external onlyOwner {
        require(newLockupPeriod >= 0, "Lockup period cannot be negative");
        lockupPeriod = newLockupPeriod;
    }

    // Setter function to change the staking token
    function setStakingToken(address newStakingToken) external onlyOwner {
        require(newStakingToken != address(0), "Staking token cannot be the zero address");
        stakingToken = IERC20(newStakingToken);
    }

    // Setter function to change the reward token
    function setRewardToken(address newRewardToken) external onlyOwner {
        require(newRewardToken != address(0), "Reward token cannot be the zero address");
        rewardToken = IERC20(newRewardToken);
    }

    // Setter function to change the total rewards
    function setTotalRewards(uint256 newTotalRewards) external onlyOwner {
        require(newTotalRewards >= 0, "Total rewards cannot be negative");
        totalRewards = newTotalRewards;
    }

    // Allows the owner to add a controller
    function addController(address controller) external onlyOwner {
        isController[controller] = true;
    }

    // Allows the owner to remove a controller
    function removeController(address controller) external onlyOwner {
        isController[controller] = false;
    }

    // Read function to get the remaining time of the staking period
    function getTimeLeft() public view returns (uint256) {
        if (stakingActive) {
            uint256 timePassed = block.timestamp - startTime;
            if (timePassed < stakingPeriodLength) {
                return stakingPeriodLength - timePassed;
            } else {
                return 0; // Staking period has ended
            }
        } else {
            return 0; // Staking period is not active
        }
    }

    // Read function to get the rewards earned in the current period by a user
    function getCurrentPeriodRewards(address user) public view returns (uint256) {
        if (stakingActive) {
            return calculateReward(user);
        } else {
            return 0; // No rewards if staking period is not active
        }
    }

    // Read function to get the total rewards earned by a user across all periods
    function getTotalRewardsEarned(address user) public view returns (uint256) {
        return rewards[user] + getCurrentPeriodRewards(user);
    }

    // Read function to get the amount a user is entitled to withdraw
    function getWithdrawableAmount(address user) public view returns (uint256) {
        if (block.timestamp - lastStakedTime[user] > lockupPeriod) {
            return stakes[user];
        } else {
            return 0; // Nothing withdrawable if within the lockup period
        }
    }

    // Read function to get all current staking parameters
    function getStakingParameters() public view returns (
        uint256 _lockupPeriod, 
        uint256 _stakingPeriodLength, 
        uint256 _totalStaked, 
        uint256 _totalRewards, 
        uint256 _rewardsDistributed, 
        bool _stakingActive, 
        uint256 _timeLeft
    ) {
        return (
            lockupPeriod, 
            stakingPeriodLength, 
            totalStaked, 
            totalRewards, 
            rewardsDistributed, 
            stakingActive, 
            getTimeLeft()
        );
    }
}