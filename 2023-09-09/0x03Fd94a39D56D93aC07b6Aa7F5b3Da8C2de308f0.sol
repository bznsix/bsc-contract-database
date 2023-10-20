// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract Staking is Ownable, ReentrancyGuard {
    uint256 public constant BASE = 1e24;

    uint256 public immutable rewAmount;
    uint256 public immutable minStake;
    uint256 public immutable maxStake;
    IERC20 public immutable tyz;

    uint256 public rewPerDay; // * BASE
    uint256 public totalStaked;
    uint256 public start;
    uint256 public end;

    PoolInfo public pool;
    mapping(address => UserInfo) public userInfo;

    struct UserInfo {
        uint256 amount;
        uint256 accRew;
        uint256 rewDebt;
    }

    struct PoolInfo {
        uint256 lastUpdateDayTimestamp;
        uint256 accRewPerShare; // * BASE
    }

    constructor(
        address _owner,
        IERC20 _tyz,
        uint256 _rewardAmount,
        uint256 _minStake,
        uint256 _maxStake
    ) {
        require(
            _owner != address(0) && address(_tyz) != address(0),
            "Zero address"
        );
        require(
            _rewardAmount > 0 && _minStake > 0 && _maxStake > _minStake,
            "Wrong params"
        );
        _transferOwnership(_owner);
        tyz = _tyz;
        rewAmount = _rewardAmount;
        minStake = _minStake;
        maxStake = _maxStake;
    }

    /**
     * @notice allow owner initiate staking, transfer rewAmount before call
     * @param _start - timestamp of staking start
     * @param _duration - how many days will the reward be distributed
     */
    function initiate(uint256 _start, uint256 _duration)
        external
        onlyOwner
        nonReentrant
    {
        require(rewPerDay == 0, "Already initiated");
        require(tyz.balanceOf(address(this)) >= rewAmount, "Not enouth reward");
        require(_start > block.timestamp && _duration > 0, "Wrong params");
        rewPerDay = (rewAmount * BASE) / _duration;
        pool = PoolInfo(_start, 0);
        start = _start;
        end = _start + _duration * 1 days;
    }

    /**
     * @notice allow users stake their tyz tokens and increase staked amount
     * @param amount - this amount will be added to user's stake,
     * tokens must be approved for it before call
     */
    function stake(uint256 amount) external nonReentrant {
        require(
            start > 0 &&
                block.timestamp >= start &&
                block.timestamp < end - 1 days,
            "Stake is not available"
        );
        require(amount > 0, "Zero amount");
        updatePool();
        UserInfo storage user = userInfo[_msgSender()];
        if (user.amount > 0) {
            user.accRew +=
                (user.amount * pool.accRewPerShare) /
                BASE -
                user.rewDebt;
        } else {
            require(amount >= minStake, "Less then min stake");
        }
        user.amount += amount;
        require(
            user.amount <= maxStake,
            "More then max stake"
        );
        user.rewDebt = (user.amount * pool.accRewPerShare) / BASE;
        totalStaked += amount;
        require(
            tyz.transferFrom(_msgSender(), address(this), amount),
            "Transfer failed"
        );
    }

    /**
     * @notice allow users withdraw their deposit and rewards,
     * if call before end, user will loose his reward (go to next staking reward pool)
     * user's must collect their deposit within month after the end
     */
    function unstake() external nonReentrant {
        require(block.timestamp <= end + 30 days, "Stake is lost");
        UserInfo memory user = userInfo[_msgSender()];
        require(user.amount > 0, "Zero staked");
        delete userInfo[_msgSender()];
        updatePool();
        totalStaked -= user.amount;
        if (block.timestamp > end) {
            user.amount +=
                (user.amount * pool.accRewPerShare) /
                BASE +
                user.accRew -
                user.rewDebt;
        }
        require(tyz.transfer(_msgSender(), user.amount), "Transfer failed");
    }

    /**
     * @notice allow owner withdraw forgotten deposits after end + month
     * @dev selfdestruct after call
     */
    function claimRestTyz() external onlyOwner nonReentrant {
        require(
            block.timestamp > end + 30 days ||
                (block.timestamp > end && totalStaked == 0),
            "Come back later"
        );
        uint256 balance = tyz.balanceOf(address(this));
        require(balance > 0, "Nothing to claim");
        require(tyz.transfer(_msgSender(), balance), "Transfer failed");
        selfdestruct(payable(_msgSender()));
    }

    /**
     * @return accummulated reward amount for certain user
     */
    function pendingReward(address _user) external view returns (uint256) {
        UserInfo memory user = userInfo[_user];
        uint256 accRew = pool.accRewPerShare;
        if (
            block.timestamp >= pool.lastUpdateDayTimestamp + 1 days &&
            pool.lastUpdateDayTimestamp < end &&
            totalStaked > 0
        ) {
            uint256 multiplier = getMultiplier(
                pool.lastUpdateDayTimestamp,
                block.timestamp
            );
            uint256 reward = multiplier * rewPerDay;
            accRew += (reward) / totalStaked;
        }
        return (user.amount * accRew) / BASE + user.accRew - user.rewDebt;
    }

    /**
     * @return staking - is stake available
     * @return withdraw - is unstake available
     * @return early - is unstake early or not
     */
    function isAvailable()
        external
        view
        returns (
            bool staking,
            bool withdraw,
            bool early
        )
    {
        if (start > 0 && block.timestamp >= start) {
            staking = block.timestamp < end - 1 days;
            withdraw = block.timestamp <= end + 30 days;
            early = block.timestamp <= end;
        }
    }

    /**
     * @notice if there is no one in when reward being distributed,
     * then subsequent rewards will be increased by that amount in total
     */
    function updatePool() internal {
        if (
            block.timestamp <= pool.lastUpdateDayTimestamp ||
            pool.lastUpdateDayTimestamp >= end
        ) {
            return;
        }
        uint256 multiplier = getMultiplier(
            pool.lastUpdateDayTimestamp,
            block.timestamp
        );
        if (multiplier == 0) {
            return;
        }
        uint256 reward = multiplier * rewPerDay;
        pool.lastUpdateDayTimestamp += 1 days * multiplier;
        if (totalStaked == 0) {
            if (pool.lastUpdateDayTimestamp < end) {
                rewPerDay +=
                    reward /
                    ((end - pool.lastUpdateDayTimestamp) / 1 days);
            }
            return;
        }
        pool.accRewPerShare += reward / totalStaked;
    }

    function getMultiplier(uint256 from, uint256 to)
        internal
        view
        returns (uint256)
    {
        return to <= end ? (to - from) / 1 days : (end - from) / 1 days;
    }
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
// SPDX-License-Identifier: MIT
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
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

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
