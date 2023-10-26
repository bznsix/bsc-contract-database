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
// OpenZeppelin Contracts v4.4.1 (utils/Counters.sol)

pragma solidity ^0.8.0;

/**
 * @title Counters
 * @author Matt Condon (@shrugs)
 * @dev Provides counters that can only be incremented, decremented or reset. This can be used e.g. to track the number
 * of elements in a mapping, issuing ERC721 ids, or counting request ids.
 *
 * Include with `using Counters for Counters.Counter;`
 */
library Counters {
    struct Counter {
        // This variable should never be directly accessed by users of the library: interactions must be restricted to
        // the library's function. As of Solidity v0.5.2, this cannot be enforced, though there is a proposal to add
        // this feature: see https://github.com/ethereum/solidity/issues/4637
        uint256 _value; // default: 0
    }

    function current(Counter storage counter) internal view returns (uint256) {
        return counter._value;
    }

    function increment(Counter storage counter) internal {
        unchecked {
            counter._value += 1;
        }
    }

    function decrement(Counter storage counter) internal {
        uint256 value = counter._value;
        require(value > 0, "Counter: decrement overflow");
        unchecked {
            counter._value = value - 1;
        }
    }

    function reset(Counter storage counter) internal {
        counter._value = 0;
    }
}
// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

interface IUserValueStorage  {
    function value(
        string memory field,
        address owner
    ) external view returns (uint);

}
// SPDX-License-Identifier: MIT
pragma solidity >=0.8.17;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

import "./IUserValueStorage.sol";

contract RewardPool is ReentrancyGuard, Ownable {
    event Claimed(uint indexed poolId, address indexed user);
    event Created(uint poolId);

    using Counters for Counters.Counter;

    // private IUserValueStorage userValueStorage;

    // creator could withdraw the token
    struct Pool {
        address creator;
        // 0 if use ETH
        address tokenAddr;
        // pool balance
        uint256 balance;
        /**
         * claimer number limit
         */
        uint256 limit;
        /**
         * reward of each claimer
         */
        uint256 amount;
        // open during the time
        uint256 start;
        uint256 end;
        // validation
        address badgeAddr;
        string[] fields;
        uint threshold;
        Counters.Counter counter;
    }

    Pool[] private pools;
    // Counters.Counter private idCounter;
    // id->user->claimed
    mapping(uint => mapping(address => bool)) claimedAddrs;

    constructor() {}

    function create(
        address tokenAddr_,
        uint256 limit_,
        uint256 amount_,
        uint256 start_,
        uint256 end_,
        address badgeAddr_,
        string[] memory fields_,
        uint threshold_
    ) public payable {
        require(
            limit_ > 0 &&
                amount_ > 0 &&
                start_ > 0 &&
                end_ > start_ &&
                threshold_ > 0 &&
                badgeAddr_ != address(0) &&
                fields_.length > 0,
            "invalid params"
        );
        uint amount = limit_ * amount_;
        if (tokenAddr_ != address(0)) {
            IERC20 token = IERC20(tokenAddr_);
            require(
                token.transferFrom(msg.sender, address(this), amount),
                "fund insufficient"
            );
        } else {
            require(msg.value >= amount, "fund insufficient");
        }

        Pool storage _pool = pools.push();

        _pool.creator = msg.sender;
        _pool.tokenAddr = tokenAddr_;
        _pool.limit = limit_;
        _pool.amount = amount_;
        _pool.start = start_;
        _pool.end = end_;
        _pool.balance = amount;
        _pool.badgeAddr = badgeAddr_;
        _pool.fields = fields_;
        _pool.threshold = threshold_;

        emit Created(pools.length);
    }

    function claim(uint poolId) public nonReentrant {
        require(poolId <= pools.length, "invalid id");
        require(!claimedAddrs[poolId][msg.sender], "claimed");

        uint256 timestamp = block.timestamp;
        Pool storage _pool = pools[poolId - 1];
        require(timestamp >= _pool.start && timestamp <= _pool.end, "closed");
        IUserValueStorage valueStorageImpl = IUserValueStorage(_pool.badgeAddr);
        for (uint i = 0; i < _pool.fields.length; i++) {
            require(
                valueStorageImpl.value(_pool.fields[i], msg.sender) >=
                    _pool.threshold,
                "unauthorized"
            );
        }
        require(_pool.counter.current() < _pool.limit, "limit has been reached");
        require(_pool.balance >= _pool.amount, "insufficient fund");
        if (_pool.tokenAddr != address(0)) {
            IERC20 token = IERC20(_pool.tokenAddr);
            token.transfer(msg.sender, _pool.amount);
        } else {
            payable(msg.sender).transfer(_pool.amount);
        }
        claimedAddrs[poolId][msg.sender] = true;
        _pool.balance -= _pool.amount;
        _pool.counter.increment();

        emit Claimed(poolId, msg.sender);
    }

    function withdraw(uint poolId) public nonReentrant {
        require(poolId <= pools.length, "invalid id");
        uint256 timestamp = block.timestamp;
        Pool storage _pool = pools[poolId - 1];
        require(timestamp > _pool.end, "unclosed");
        require(_pool.creator == msg.sender, "unauthorized");

        if (_pool.tokenAddr != address(0)) {
            IERC20 token = IERC20(_pool.tokenAddr);
            token.transfer(msg.sender, _pool.balance);
        } else {
            payable(msg.sender).transfer(_pool.balance);
        }
    }

    function poolCount() public view returns (uint) {
        return pools.length;
    }

    function pool(uint poolId) public view returns (Pool memory) {
        require(poolId <= pools.length, "invalid id");
        return pools[poolId - 1];
    }

    function claimersCount(uint poolId) public view returns (uint) {
        require(poolId <= pools.length, "invalid id");
        Pool storage _pool = pools[poolId - 1];
        return _pool.counter.current();
    }

    function hasClaimed(uint poolId, address user) public view returns (bool) {
        return claimedAddrs[poolId][user];
    }
}
