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
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract CUTStaking is Ownable {
    using SafeMath for uint256;

    enum LockPeriod {
        PERIOD_1_MONTH,
        PERIOD_3_MONTHS,
        PERIOD_6_MONTHS,
        PERIOD_9_MONTHS,
        PERIOD_12_MONTHS,
        PERIOD_24_MONTHS
    }

    struct Pool {
        address poolToken;
        uint256 totalStaked; // Total amount staked in the pool
    }

    struct PeriodInfo {
        uint256 period;
        uint256 apy;
    }

    struct StakeInfo {
        uint256 balance;
        uint256 lastUpdated;
        uint256 unlockTime;
        LockPeriod lockType;
        uint256 positionIndex;
        uint256 apy;
    }

    uint256 constant SECONDS_IN_MONTH = 2629746; // Number of seconds in a month
    IERC20 public immutable rewardToken;

    mapping(address => mapping(uint256 => StakeInfo[])) public stakeInfo;
    mapping(LockPeriod => PeriodInfo) public periodInfos;

    Pool[] public pools;

    event Staked(address indexed user, uint256 amount, uint256 positionIndex, LockPeriod lockType, uint256 unlockAt, uint256 apy);
    event Unstaked(address indexed user, uint256 amount, uint256 positionIndex);
    event TokenWithdraw(address indexed token, uint256 amount);
    event Claimed(address indexed user, uint256 amount);

    constructor(IERC20 _rewardToken) {
        rewardToken = _rewardToken;

        periodInfos[LockPeriod.PERIOD_3_MONTHS] = PeriodInfo(
            SECONDS_IN_MONTH * 3,
            32
        );
        periodInfos[LockPeriod.PERIOD_6_MONTHS] = PeriodInfo(
            SECONDS_IN_MONTH * 6,
            85
        );
        periodInfos[LockPeriod.PERIOD_9_MONTHS] = PeriodInfo(
            SECONDS_IN_MONTH * 9,
            154
        );
        periodInfos[LockPeriod.PERIOD_12_MONTHS] = PeriodInfo(
            SECONDS_IN_MONTH * 12,
            251
        );
        periodInfos[LockPeriod.PERIOD_24_MONTHS] = PeriodInfo(
            SECONDS_IN_MONTH * 24,
            618
        );
    }

    function stake(
        uint256 amount,
        uint256 poolIndex,
        LockPeriod lockPeriod
    ) external {
        require(poolIndex < pools.length, "Invalid pool index");
        require(amount > 0, "Amount must be greater than zero");

        // Transfer ERC20 tokens from user to contract
        require(
            IERC20(pools[poolIndex].poolToken).transferFrom(
                msg.sender,
                address(this),
                amount
            ),
            "Transfer failed"
        );

        // Add a new stake position for the user
        uint256 positionIndex = stakeInfo[msg.sender][poolIndex].length;
        uint256 unlockAt = block.timestamp + periodInfos[lockPeriod].period;
        stakeInfo[msg.sender][poolIndex].push(
            StakeInfo(
                amount,
                block.timestamp,
                unlockAt,
                lockPeriod,
                positionIndex,
                periodInfos[lockPeriod].apy
            )
        );

        // Update pool's total staked amount
        pools[poolIndex].totalStaked = pools[poolIndex].totalStaked.add(amount);

        // Emit Staked event
        emit Staked(msg.sender, amount, positionIndex, lockPeriod, unlockAt, periodInfos[lockPeriod].apy);
    }

    function purchase(
        uint256[] memory amountList,
        address[] memory userList,
        uint256[] memory timestampList,
        uint256 poolIndex,
        LockPeriod lockPeriod
    ) external onlyOwner {
        require(poolIndex < pools.length, "Invalid pool index");
        require(userList.length == amountList.length && userList.length == timestampList.length, "Invalid array matching");
        uint256 amount = 0;

        // Add a new stake position for the user
        for(uint i = 0 ; i < amountList.length ; i ++) {
            uint256 positionIndex = stakeInfo[userList[i]][poolIndex].length;
            uint256 unlockAt = timestampList[i] + periodInfos[lockPeriod].period;
            stakeInfo[userList[i]][poolIndex].push(
                StakeInfo(
                    amountList[i],
                    timestampList[i],
                    unlockAt,
                    lockPeriod,
                    positionIndex,
                    periodInfos[lockPeriod].apy
                )

            );
            emit Staked(userList[i], amountList[i], positionIndex, lockPeriod, unlockAt, periodInfos[lockPeriod].apy);
            amount = amount + amountList[i];
        }

        // Transfer ERC20 tokens from user to contract
        require(
            IERC20(pools[poolIndex].poolToken).transferFrom(
                msg.sender,
                address(this),
                amount
            ),
            "Transfer failed"
        );

        // Update pool's total staked amount
        pools[poolIndex].totalStaked = pools[poolIndex].totalStaked.add(amount);
    }

    function migrate(
        uint256[] memory amountList,
        address[] memory userList,
        uint256[] memory timestampList,
        uint256[] memory unlockAtList,
        uint256[] memory apyList,
        uint256 poolIndex,
        LockPeriod lockPeriod
    ) external onlyOwner {
        require(poolIndex < pools.length, "Invalid pool index");
        require(userList.length == amountList.length && userList.length == timestampList.length && userList.length == unlockAtList.length, "Invalid array matching");
        uint256 amount = 0;

        // Add a new stake position for the user
        for(uint i = 0 ; i < amountList.length ; i ++) {
            uint256 positionIndex = stakeInfo[userList[i]][poolIndex].length;
            stakeInfo[userList[i]][poolIndex].push(
                StakeInfo(
                    amountList[i],
                    timestampList[i],
                    unlockAtList[i],
                    lockPeriod,
                    positionIndex,
                    apyList[i]
                )

            );
            emit Staked(userList[i], amountList[i], positionIndex, lockPeriod, unlockAtList[i], apyList[i]);
            amount = amount + amountList[i];
        }

        // Update pool's total staked amount
        pools[poolIndex].totalStaked = pools[poolIndex].totalStaked.add(amount);
    }

    function unstake(uint256 poolIndex, uint256 positionIndex) external {
        StakeInfo memory stakePosition = stakeInfo[msg.sender][poolIndex][positionIndex];

        require(poolIndex < pools.length, "Invalid pool index");
        require(
            stakePosition.unlockTime <=
                block.timestamp,
            "Time lock not ended yet"
        );
        uint256 balance = stakePosition
            .balance;
        // Calculate the reward based on the staked amount and lock period
        uint256 reward = calculateReward(
            stakePosition
        );

        // Update user's staked amount and lock period
        delete stakeInfo[msg.sender][poolIndex][positionIndex];

        // Update pool's total staked amount
        pools[poolIndex].totalStaked = pools[poolIndex].totalStaked.sub(
            balance
        );

        // Transfer ERC20 tokens and reward to user
        require(
            rewardToken.transfer(msg.sender, reward),
            "Reward Transfer failed"
        );

        require(
            IERC20(pools[poolIndex].poolToken).transfer(msg.sender, balance),
            "Transfer failed"
        );

        // Emit Unstaked event
        emit Unstaked(msg.sender, balance, positionIndex);
    }

    function claim(uint256 poolIndex) external {
        require(poolIndex < pools.length, "Invalid pool index");

        // Calculate the total reward for all positions of the user in the specified pool
        uint256 reward = calculateRewardForUser(msg.sender, poolIndex);

        // Update the last staked timestamp for all positions
        updateLastStakedTimestamp(msg.sender, poolIndex);

        // Transfer ERC20 tokens and reward to the user
        require(rewardToken.transfer(msg.sender, reward), "Transfer failed");

        // Emit Claimed event
        emit Claimed(msg.sender, reward);
    }

    function updateLastStakedTimestamp(
        address user,
        uint256 poolIndex
    ) internal {
        StakeInfo[] storage userStakes = stakeInfo[user][poolIndex];

        for (uint256 i = 0; i < userStakes.length; i++) {
            userStakes[i].lastUpdated = block.timestamp;
        }
    }

    function calculateRewardForUser(
        address user,
        uint256 poolIndex
    ) public view returns (uint256) {
        StakeInfo[] storage userStakes = stakeInfo[user][poolIndex];
        uint256 totalReward;

        for (uint256 i = 0; i < userStakes.length; i++) {
            if(userStakes[i].balance > 0) {
                totalReward = totalReward.add(
                    calculateReward(userStakes[i])
                );
            }
        }

        return totalReward;
    }

    function calculateReward(
        StakeInfo memory userInfo
    ) public view returns (uint256) {
        uint256 rewardAPY = userInfo.apy; // Lock periods are indexed from 0
        uint256 rewardPerToken = uint256(1e18).mul(rewardAPY).div(1000).div(SECONDS_IN_MONTH * 12);
        
        uint256 elapsedTime = block.timestamp.sub(userInfo.lastUpdated);

        uint256 reward = userInfo
            .balance
            .mul(elapsedTime)
            .mul(rewardPerToken)
            .div(1e18);

        return reward;
    }

    function getStakedAmount(
        address user,
        uint256 poolIndex,
        uint256 positionIndex
    ) external view returns (uint256) {
        return stakeInfo[user][poolIndex][positionIndex].balance;
    }

    function getPoolInfo(
        uint256 poolIndex
    ) external view returns (address, uint256) {
        require(poolIndex < pools.length, "Invalid pool index");
        return (
            pools[poolIndex].poolToken,
            pools[poolIndex].totalStaked
        );
    }

    function setRewardAPY(
        uint256 lockPeriod,
        uint256 rewardAPY
    ) external onlyOwner {
        require(lockPeriod >= 0 && lockPeriod < 6, "Invalid lock period");
        periodInfos[LockPeriod(lockPeriod)].apy = rewardAPY;
    }

    function addPool(address token) external onlyOwner {
        pools.push(
            Pool({poolToken: token, totalStaked: 0})
        );
    }

    function tokenWithdraw(IERC20 token) external onlyOwner {
        require(
            token.transfer(owner(), token.balanceOf(address(this))),
            "Transfer failed"
        );
        emit TokenWithdraw(address(token), token.balanceOf(address(this)));
    }
}
