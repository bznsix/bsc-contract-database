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
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (security/ReentrancyGuard.sol)

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
        _nonReentrantBefore();
        _;
        _nonReentrantAfter();
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
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (token/ERC20/IERC20.sol)

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
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.4) (utils/Context.sol)

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

    function _contextSuffixLength() internal view virtual returns (uint256) {
        return 0;
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (utils/math/SafeMath.sol)

pragma solidity ^0.8.0;

// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is generally not needed starting with Solidity 0.8, since the compiler
 * now has built in overflow checking.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator.
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {trySub}.
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting with custom message when dividing by zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryMod}.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

/// @title Staking Contract
/// @author Metalogics LTD. For queries contact@metalogics.io
/// @notice Implements the logic for Staking Contract
/// @dev Allows multiple users to stake tokens on multiple pools

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract StakingContract is Ownable, ReentrancyGuard {
    /// @notice APY % can not be a null value
    error InvalidStakeAPY();

    /// @notice Provided unstake fee can not be a null value
    error InvalidUnstakeFee();

    /// @notice Provided staking limit can not be a null value
    error InvalidStakingLimit();

    /// @notice Provided validity period can not be a null value
    error InvalidPoolValidity();

    /// @notice Reward allowance can not be a null value
    error InvalidAllowance();

    /// @notice Pool does not exist for the provided token
    error PoolNotExists();

    /// @notice Pool does not exist for the provided token
    error MinimumStakeAmount();

    /// @notice The staked amount can not be zero value
    error InvalidStakeAmount();

    /// @notice The minimum stake limit can not be zero value
    error InvalidMinStakeLimit();

    /// @notice No amount is staked for particular user
    error NoAmountStaked();

    /// @notice Last claim time should be less than current time
    error StatusAlreadySet();

    /// @notice User already unstaked amount
    error AlreadyUnstaked();

    /// @notice Staking already started
    error StakingStarted();

    /// @notice Staking not started yet
    error StakingNotStarted();

    /// @notice Thrown when provided address is in invalid format
    error InvalidAddress();

    /// @notice Contract using the SafeMath library for uint256 arithmetic operations
    using SafeMath for uint256;

    /// @notice Returns the fee wallet address where deducted fee is stored in wei
    address public feeWallet;

    /// @notice Returns the total count of pool created by admin
    uint256 public poolCount;

    /// @notice Constant variable initialized with the value 100
    uint256 constant HUNDRED = 100;

    /// @member stakedAmount Amount of staked ERC20 tokens in wei
    /// @member stakedTime Time when user staked tokens in block.timestamp
    /// @member lastClaimTime Time when user last claimed earned rewards
    /// @member reward Latest calculated/claimed reward by user
    struct User {
        uint256 stakedAmount;
        uint256 stakedTime;
        uint256 reward;
        bool unstaked;
    }

    /// @member poolName Name of staking token pool in string
    /// @member PID Pool ID
    /// @member stakeAPY The APY% of pool
    /// @member UNSTAKE_FEE Early unstaking fee percentage
    /// @member stakingToken Address of staking token
    /// @member rewardToken Address of rewarding tokens that will be transferred as reward
    /// @member stakingStartTime Staking start time of pool
    /// @member poolValidityPeriod Validity time of pool in block.timestamp for staking
    /// @member totalStakedAmount Total amount of tokens staked into the pool
    /// @member stakingStarted Boolean status for staking started or not
    /// @member unStakingPaused Boolean status for unStaking paused or not
    /// @member poolExists Boolean status for pool existence
    struct Pool {
        string poolName;
        uint256 PID;
        uint256 stakeAPY;
        uint256 UNSTAKE_FEE;
        uint256 minStakingLimit;
        address stakingToken;
        address rewardToken;
        uint256 stakingStartTime;
        uint256 poolValidityPeriod;
        uint256 totalStakedAmount;
        bool stakingStarted;
        bool unStakingPaused;
        bool poolExists;
    }

    /* ========== STORAGE ========== */

    mapping(uint256 => Pool) public pools;
    mapping(address => mapping(uint256 => mapping(uint256 => User)))
        public users;
    mapping(address => mapping(uint256 => uint256)) public stakerindex; // user => pid => stakerIndex

    /* ========== EVENTS ========== */

    event Staked(address indexed user, address indexed token, uint256 amount);
    event UnStaked(address indexed user, address indexed token, uint256 amount);
    event RewardPaid(
        address indexed user,
        address indexed rewardToken,
        uint256 amount
    );
    event PoolAdded(
        string poolName,
        uint256 PID,
        uint256 stakeAPY,
        uint256 earlyUnstakeFee,
        address stakingToken,
        address rewardToken,
        uint256 poolValidityPeriod
    );
    event PoolUpdated(uint256 indexed poolId, uint256 newRewardPercentage);
    event UnstakeFeeUpdated(uint256 indexed poolId, uint256 newUnstakeFee);
    event MinStakeLimitUpdated(
        uint256 indexed poolId,
        uint256 newMinStakeLimit
    );
    event RewardAllowanceAdded(
        uint256 indexed poolId,
        uint256 additionalAllowance
    );
    event Deposit(address indexed sender, uint256 value);

    /* ========== MODIFIERS ========== */

    /// @notice throws exeception when address is invalid
    modifier notNull(address _address) {
        if (_address == address(0)) {
            revert InvalidAddress();
        }
        _;
    }

    /// @notice throws exeception when staking started
    modifier stakingStarted(uint256 poolID) {
        if (pools[poolID].stakingStarted) {
            revert StakingStarted();
        }
        _;
    }

    /// @notice throws exeception when staking not started
    modifier stakingNotStarted(uint256 poolID) {
        if (!pools[poolID].stakingStarted) {
            revert StakingNotStarted();
        }
        _;
    }

    /// @notice throws exeception when unstaking is paused
    modifier whenUnstakingNotPaused(uint256 poolID) {
        require(!pools[poolID].unStakingPaused, "Unstaking is paused");
        _;
    }

    /// @notice throws exeception when pool not exist for provided token address
    modifier poolNotExist(uint256 poolID) {
        Pool storage pool = pools[poolID];
        if (!pool.poolExists) {
            revert PoolNotExists();
        }
        _;
    }

    /// @dev Constructor sets msg.sender as the owner
    constructor() Ownable() {}

    /// @notice Allows to deposit ether
    receive() external payable {
        if (msg.value > 0) emit Deposit(msg.sender, msg.value);
    }

    /// @notice Allow the admin to pause/resume staking for stakers
    /// @param poolID Address of staking token/pool
    /// @param _status Boolean status i.e. true/false
    function pauseStaking(
        uint256 poolID,
        bool _status
    ) external onlyOwner poolNotExist(poolID) {
        Pool storage pool = pools[poolID];
        if (_status == pool.stakingStarted) {
            revert StatusAlreadySet();
        }
        pool.stakingStarted = _status;
    }

    /// @notice Allow the admin to pause/resume unStaking for stakers
    /// @param poolID Pool ID
    /// @param _status Boolean status i.e. true/false
    function pauseUnstaking(uint256 poolID, bool _status) external onlyOwner poolNotExist(poolID) {
        Pool storage pool = pools[poolID];
        if (_status == pool.unStakingPaused) {
            revert StatusAlreadySet();
        }
        pool.unStakingPaused = _status;
    }

    /// @notice Allow the admin to set wallet address for collection of deducted fee
    /// @param _feeWallet Address of wallet address
    function setFeeWallet(
        address _feeWallet
    ) external onlyOwner notNull(_feeWallet) {
        feeWallet = _feeWallet;
    }

    /// @notice Allow users to stake tokens
    /// @param poolID Pool ID
    /// @param amount Amount of ERC20 staking token
    function stake(
        uint256 poolID,
        uint256 amount
    ) public poolNotExist(poolID) stakingNotStarted(poolID) nonReentrant {
        if (amount <= 0) {
            revert InvalidStakeAmount();
        }
        if (amount < pools[poolID].minStakingLimit) {
            revert MinimumStakeAmount();
        }

        Pool storage pool = pools[poolID];
        address stakingToken = pool.stakingToken;
        uint256 userIndex = stakerindex[msg.sender][poolID];
        User storage user = users[msg.sender][poolID][userIndex];

        IERC20(stakingToken).transferFrom(msg.sender, address(this), amount);

        pool.totalStakedAmount += amount;
        user.stakedAmount = amount;
        user.stakedTime = block.timestamp;

        stakerindex[msg.sender][poolID]++;

        emit Staked(msg.sender, stakingToken, amount);
    }

    /// @notice Calculates reward per second for staked amount
    /// @param poolID Pool ID
    /// @param user Staker Address
    /// @param index Staker index
    function calculateRewardPerSecond(
        uint256 poolID,
        address user,
        uint256 index
    ) public view poolNotExist(poolID) returns (uint256) {
        Pool storage pool = pools[poolID];

        uint256 rewardAPY = pool.stakeAPY;
        uint256 poolValidity = pool.poolValidityPeriod;

        return
            users[user][poolID][index]
                .stakedAmount
                .mul(rewardAPY)
                .div(HUNDRED)
                .div(poolValidity);
    }

    /// @notice Allow staker to view earned rewards
    /// @param poolID Pool ID
    /// @param user Staker Address
    /// @param index Staker index
    function getRewards(
        uint256 poolID,
        address user,
        uint256 index,
        uint256 poolValidity
    ) public view returns (uint256) {
        User memory userStorage = users[msg.sender][poolID][index];
        uint256 currentTime = block.timestamp;
        uint256 lastClaimTime = userStorage.stakedTime;

        uint256 compareTime = lastClaimTime.add(poolValidity);
        if (currentTime > compareTime) {
            currentTime = compareTime;
        }

        uint256 elapsedTime = currentTime.sub(lastClaimTime);

        uint256 rewardPerSecond = calculateRewardPerSecond(poolID, user, index);
        uint256 newReward = rewardPerSecond.mul(elapsedTime);

        return newReward;
    }

    /// @notice Transfer earned rewards to user while unstaking
    /// @param poolID Pool ID
    /// @param index Staker index
    function claimRewards(
        uint256 poolID,
        uint256 index
    ) internal poolNotExist(poolID) {
        Pool storage pool = pools[poolID];
        address sender = msg.sender;

        User storage userStorage = users[sender][poolID][index];

        uint256 stakedAmount = userStorage.stakedAmount;
        if (stakedAmount == 0) {
            revert NoAmountStaked();
        }

        uint256 rewardAmount = getRewards(
            poolID,
            sender,
            index,
            pool.poolValidityPeriod
        );
        userStorage.reward = rewardAmount;

        if (rewardAmount > 0) {
            address rewardToken = pool.rewardToken;
            IERC20(rewardToken).transfer(sender, rewardAmount);

            emit RewardPaid(sender, rewardToken, rewardAmount);
        }
    }

    /// @notice Allow staker to unstake the staked amount plus the earned reward
    /// @param poolID Pool ID
    /// @param index Staker index
    function unStake(
        uint256 poolID,
        uint256 index
    )
        external
        poolNotExist(poolID)
        whenUnstakingNotPaused(poolID)
        nonReentrant
    {
        //transfers earned reward tokens
        claimRewards(poolID, index);

        Pool storage pool = pools[poolID];
        User storage user = users[msg.sender][poolID][index];

        bool hasUserUnstaked = user.unstaked;

        if (hasUserUnstaked) {
            revert AlreadyUnstaked();
        }

        uint256 stakedAmount = user.stakedAmount;
        address stakedToken = pool.stakingToken;
        uint256 poolvalidityPeriod = pool.poolValidityPeriod;
        uint256 EarlyUnstakeFee = pool.UNSTAKE_FEE;
        uint256 userPoolValidity = user.stakedTime;

        if (block.timestamp < userPoolValidity.add(poolvalidityPeriod)) {
            uint256 fee = stakedAmount.mul(EarlyUnstakeFee).div(HUNDRED);
            stakedAmount = stakedAmount.sub(fee);

            if (feeWallet != address(0)) {
                IERC20(stakedToken).transfer(feeWallet, fee);
            }
        }

        IERC20(stakedToken).transfer(msg.sender, stakedAmount);

        pool.totalStakedAmount -= stakedAmount;
        user.unstaked = true;

        emit UnStaked(msg.sender, stakedToken, stakedAmount);
    }

    /// @notice Allow admin to create a staking pool
    /// @param stakeAPY The APY% of staking token
    /// @param earlyUnstakeFee Early unStaking deducted fee%
    /// @param minimumStakingLimit Minimunt amount limit to stake per pool
    /// @param stakingToken Address of staking token
    /// @param rewardToken Address of reward token
    /// @param poolValidityPeriod Expiry time of pool in unixtime-stamp
    /// @param allowanceAmount The rewarding token allowance
    function addPool(
        string memory poolName,
        uint256 stakeAPY,
        uint256 earlyUnstakeFee,
        uint256 minimumStakingLimit,
        address stakingToken,
        address rewardToken,
        uint256 poolValidityPeriod,
        uint256 allowanceAmount
    ) public onlyOwner returns (uint256 poolId) {
        if (stakeAPY <= 0) {
            revert InvalidStakeAPY();
        }
        if (allowanceAmount <= 0) {
            revert InvalidAllowance();
        }
        if (earlyUnstakeFee <= 0) {
            revert InvalidUnstakeFee();
        }
        if (minimumStakingLimit <= 0) {
            revert InvalidStakingLimit();
        }
        if (poolValidityPeriod <= 0) {
            revert InvalidPoolValidity();
        }

        poolId = poolCount;

        pools[poolId] = Pool({
            poolName: poolName,
            PID: poolId,
            stakeAPY: stakeAPY,
            UNSTAKE_FEE: earlyUnstakeFee,
            minStakingLimit: minimumStakingLimit,
            stakingToken: stakingToken,
            rewardToken: rewardToken,
            stakingStartTime: block.timestamp,
            poolValidityPeriod: poolValidityPeriod,
            totalStakedAmount: 0,
            stakingStarted: true,
            unStakingPaused: false,
            poolExists: true
        });

        poolCount++;

        // grant allowance to this contract for the rewarding token
        IERC20(rewardToken).transferFrom(
            msg.sender,
            address(this),
            allowanceAmount
        );

        emit PoolAdded(
            poolName,
            poolId,
            stakeAPY,
            earlyUnstakeFee,
            stakingToken,
            rewardToken,
            poolValidityPeriod
        );
    }

    /// @notice Allow admin to update minimum staking tokens limit
    /// @param poolId Pool ID
    /// @param _newLimit Updated minimum staking limit
    function updateMinStakeLimit(
        uint256 poolId,
        uint256 _newLimit
    ) public onlyOwner poolNotExist(poolId) {
        Pool storage pool = pools[poolId];

        if (_newLimit <= 0) {
            revert InvalidMinStakeLimit();
        }

        pool.minStakingLimit = _newLimit;

        emit MinStakeLimitUpdated(poolId, _newLimit);
    }

    /// @notice Allow admin to update a staking pool unstake Fee%
    /// @param poolId Pool ID
    /// @param newUnstakeFee New newUnstakeFee%
    function updateUnStakeFee(
        uint256 poolId,
        uint256 newUnstakeFee
    ) external onlyOwner poolNotExist(poolId) {
        if (newUnstakeFee <= 0) {
            revert InvalidUnstakeFee();
        }

        pools[poolId].UNSTAKE_FEE = newUnstakeFee;

        emit UnstakeFeeUpdated(poolId, newUnstakeFee);
    }

    /// @notice Allow admin to update a staking pool APY%
    /// @param poolId Pool ID
    /// @param newRewardPercentage New APY% of staking token
    function updatePoolAPY(
        uint256 poolId,
        uint256 newRewardPercentage
    ) external onlyOwner poolNotExist(poolId) {
        if (newRewardPercentage <= 0) {
            revert InvalidStakeAPY();
        }

        pools[poolId].stakeAPY = newRewardPercentage;

        emit PoolUpdated(poolId, newRewardPercentage);
    }

    /// @notice Allow admin to add more reward tokens to the pool after pool is created
    /// @param poolId Pool ID
    /// @param additionalAllowance Allowance amount of rewarding tokens
    function addRewardAllowance(
        uint256 poolId,
        uint256 additionalAllowance
    ) external onlyOwner poolNotExist(poolId) {
        if (additionalAllowance <= 0) {
            revert InvalidAllowance();
        }

        Pool storage pool = pools[poolId];

        IERC20(pool.rewardToken).transferFrom(
            msg.sender,
            address(this),
            additionalAllowance
        );

        emit RewardAllowanceAdded(poolId, additionalAllowance);
    }

    /// @notice Allow admin to withdraw reward tokens once the pool expires
    /// @param poolId Pool ID
    /// @param _withdrawAmount Amount of rewarding tokens
    function withdrawRewardAmount(
        uint256 poolId,
        uint256 _withdrawAmount
    ) public onlyOwner poolNotExist(poolId) {
        if (_withdrawAmount <= 0) {
            revert InvalidAllowance();
        }

        Pool storage pool = pools[poolId];

        uint256 contractBalance = IERC20(pool.rewardToken).balanceOf(
            address(this)
        );
        require(
            _withdrawAmount <= contractBalance,
            "Contract: Insufficient reward balance"
        );

        IERC20(pool.rewardToken).transfer(msg.sender, _withdrawAmount);
    }

    /// @notice Returns the token balance of contract
    /// @param token Address of token
    function contractTokenBalance(address token) public view returns (uint256) {
        return IERC20(token).balanceOf(address(this));
    }
}
