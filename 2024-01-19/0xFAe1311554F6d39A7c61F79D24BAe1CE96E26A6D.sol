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
// OpenZeppelin Contracts (last updated v4.7.0) (security/Pausable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

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
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        _requireNotPaused();
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
        _requirePaused();
        _;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns (bool) {
        return _paused;
    }

    /**
     * @dev Throws if the contract is paused.
     */
    function _requireNotPaused() internal view virtual {
        require(!paused(), "Pausable: paused");
    }

    /**
     * @dev Throws if the contract is not paused.
     */
    function _requirePaused() internal view virtual {
        require(paused(), "Pausable: not paused");
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
pragma solidity 0.8.18;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Staking is Ownable, Pausable, ReentrancyGuard {
	address public _stakingToken;

	uint256 public constant ONE_YEAR = 365 days;
	uint256 public constant ANNUAL_PROFIT_MULTIPLIER = 1000;

	struct PoolInfo {
		uint256 apr;
		uint256 tvl;
		uint256 lockingTime;
		bool available;
	}

	struct UserStaking {
		uint256 stakingAmount;
		uint256 stakingTime;
		uint256 lastEarnedTime;
		uint256 earnedAmount;
		uint256 earnDebt;
	}

	mapping(uint256 => PoolInfo) public _poolInfos;

	mapping(address => mapping(uint256 => UserStaking))
		public _userStakingPools;

	event Stake(address indexed account, uint256 poolId, uint256 amount);
	event ClaimReward(
		address indexed account,
		uint256 indexed poolId,
		uint256 amount
	);
	event Withdraw(
		address indexed account,
		uint256 indexed poolId,
		uint256 amount
	);

	constructor(address stakingToken) {
		_stakingToken = stakingToken;

		_poolInfos[0] = PoolInfo({
			apr: 7 * ANNUAL_PROFIT_MULTIPLIER,
			tvl: 0,
			lockingTime: 180 days,
			available: true
		});

		_poolInfos[1] = PoolInfo({
			apr: 10 * ANNUAL_PROFIT_MULTIPLIER,
			tvl: 0,
			lockingTime: 365 days,
			available: true
		});

		_poolInfos[2] = PoolInfo({
			apr: 12 * ANNUAL_PROFIT_MULTIPLIER,
			tvl: 0,
			lockingTime: 540 days,
			available: true
		});
	}

	function stake(
		uint256 pId,
		uint256 amount
	) external payable whenNotPaused nonReentrant returns (bool) {
		PoolInfo memory pool = _poolInfos[pId];
		require(pool.available, "Pool is not available");

		UserStaking memory user = _userStakingPools[_msgSender()][pId];

		if (user.stakingAmount > 0) {
			uint256 earnedAmount = _calculatePendingEarned(_msgSender(), pId);
			user.earnDebt += earnedAmount;
			user.stakingAmount += amount;
			user.lastEarnedTime = block.timestamp;
			_userStakingPools[_msgSender()][pId] = user;
		} else {
			_userStakingPools[_msgSender()][pId] = UserStaking({
				stakingAmount: amount,
				lastEarnedTime: block.timestamp,
				stakingTime: block.timestamp,
				earnedAmount: 0,
				earnDebt: 0
			});
		}

		pool.tvl += amount;
		_poolInfos[pId] = pool;

		IERC20 tokenStakingContract = IERC20(_stakingToken);
		require(
			tokenStakingContract.transferFrom(
				address(_msgSender()),
				address(this),
				amount
			),
			"Can not pay token staking to contract"
		);

		emit Stake(_msgSender(), pId, amount);
		return true;
	}

	function harvest(
		uint256 pId
	) external whenNotPaused nonReentrant returns (bool) {
		UserStaking memory user = _userStakingPools[_msgSender()][pId];

		if (user.stakingAmount == 0) return false;

		uint256 earnedAmount = _calculatePendingEarned(_msgSender(), pId) +
			user.earnDebt;
		if (earnedAmount > 0) {
			IERC20 tokenStakingContract = IERC20(_stakingToken);
			if (tokenStakingContract.balanceOf(address(this)) >= earnedAmount) {
				require(
					tokenStakingContract.transfer(_msgSender(), earnedAmount),
					"Can not pay interest for user"
				);
				user.earnDebt = 0;
				user.earnedAmount += earnedAmount;
				user.lastEarnedTime = block.timestamp;
				_userStakingPools[_msgSender()][pId] = user;
				emit ClaimReward(_msgSender(), pId, earnedAmount);
			}
		}
		return true;
	}

	function leftStaking(
		uint256 pId
	) external whenNotPaused nonReentrant returns (bool) {
		PoolInfo memory pool = _poolInfos[pId];
		UserStaking memory user = _userStakingPools[_msgSender()][pId];

		if (user.stakingAmount == 0) return false;

		uint256 interestAmount = _calculatePendingEarned(_msgSender(), pId) +
			user.earnDebt;
		uint256 totalAmount = user.stakingAmount + interestAmount;
		// withdraw earnly, sub 20%
		if (user.stakingTime + pool.lockingTime > block.timestamp) {
			totalAmount = totalAmount - (totalAmount / 5);
		}
		IERC20 tokenStakingContract = IERC20(_stakingToken);
		if (tokenStakingContract.balanceOf(address(this)) >= totalAmount) {
			require(
				tokenStakingContract.transfer(_msgSender(), totalAmount),
				"Can not pay interest for user"
			);
			user.earnedAmount += interestAmount;
			user.earnDebt = 0;
			user.stakingAmount = 0;
			user.lastEarnedTime = block.timestamp;
			_userStakingPools[_msgSender()][pId] = user;
			emit Withdraw(_msgSender(), pId, totalAmount);
		}
		return true;
	}

	function updatePool(
		uint256 pId,
		uint256 apr,
		uint256 lockingTime,
		bool available
	) external onlyOwner {
		PoolInfo memory pool = _poolInfos[pId];
		if (pool.apr > 0) {
			_poolInfos[pId] = PoolInfo({
				apr: apr,
				lockingTime: lockingTime,
				available: available,
				tvl: pool.tvl
			});
		} else {
			_poolInfos[pId] = PoolInfo({
				apr: apr,
				lockingTime: lockingTime,
				available: available,
				tvl: 0
			});
		}
	}

	function updateContract(address stakingToken) external onlyOwner {
		_stakingToken = stakingToken;
	}

	function pauseContract() external whenNotPaused onlyOwner {
		_pause();
	}

	function unpauseContract() external whenPaused onlyOwner {
		_unpause();
	}

	function withdraw(uint256 amount) external onlyOwner {
		(bool success, ) = payable(_msgSender()).call{ value: amount }("");
		require(success, "CAN_NOT_WITHDRAW");
	}

	function withdrawToken(address token, uint256 amount) external onlyOwner {
		IERC20(token).transfer(_msgSender(), amount);
	}

	function getUserEarnedAmount(
		address account,
		uint256 pId
	) external view returns (uint256) {
		UserStaking memory user = _userStakingPools[account][pId];

		if (user.stakingAmount == 0) return 0;
		return user.earnDebt + _calculatePendingEarned(account, pId);
	}

	function _calculatePendingEarned(
		address account,
		uint256 pId
	) internal view returns (uint256) {
		UserStaking memory user = _userStakingPools[account][pId];
		if (user.stakingAmount > 0) {
			return
				(user.stakingAmount *
					(block.timestamp - user.lastEarnedTime) *
					_poolInfos[pId].apr) /
				ANNUAL_PROFIT_MULTIPLIER /
				ONE_YEAR /
				100;
		}
		return 0;
	}
}
