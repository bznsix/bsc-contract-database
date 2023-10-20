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
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC721/IERC721Receiver.sol)

pragma solidity ^0.8.0;

/**
 * @title ERC721 token receiver interface
 * @dev Interface for any contract that wants to support safeTransfers
 * from ERC721 asset contracts.
 */
interface IERC721Receiver {
    /**
     * @dev Whenever an {IERC721} `tokenId` token is transferred to this contract via {IERC721-safeTransferFrom}
     * by `operator` from `from`, this function is called.
     *
     * It must return its Solidity selector to confirm the token transfer.
     * If any other value is returned or the interface is not implemented by the recipient, the transfer will be reverted.
     *
     * The selector can be obtained in Solidity with `IERC721Receiver.onERC721Received.selector`.
     */
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
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
// OpenZeppelin Contracts (last updated v4.9.0) (utils/structs/EnumerableSet.sol)
// This file was procedurally generated from scripts/generate/templates/EnumerableSet.js.

pragma solidity ^0.8.0;

/**
 * @dev Library for managing
 * https://en.wikipedia.org/wiki/Set_(abstract_data_type)[sets] of primitive
 * types.
 *
 * Sets have the following properties:
 *
 * - Elements are added, removed, and checked for existence in constant time
 * (O(1)).
 * - Elements are enumerated in O(n). No guarantees are made on the ordering.
 *
 * ```solidity
 * contract Example {
 *     // Add the library methods
 *     using EnumerableSet for EnumerableSet.AddressSet;
 *
 *     // Declare a set state variable
 *     EnumerableSet.AddressSet private mySet;
 * }
 * ```
 *
 * As of v3.3.0, sets of type `bytes32` (`Bytes32Set`), `address` (`AddressSet`)
 * and `uint256` (`UintSet`) are supported.
 *
 * [WARNING]
 * ====
 * Trying to delete such a structure from storage will likely result in data corruption, rendering the structure
 * unusable.
 * See https://github.com/ethereum/solidity/pull/11843[ethereum/solidity#11843] for more info.
 *
 * In order to clean an EnumerableSet, you can either remove all elements one by one or create a fresh instance using an
 * array of EnumerableSet.
 * ====
 */
library EnumerableSet {
    // To implement this library for multiple types with as little code
    // repetition as possible, we write it in terms of a generic Set type with
    // bytes32 values.
    // The Set implementation uses private functions, and user-facing
    // implementations (such as AddressSet) are just wrappers around the
    // underlying Set.
    // This means that we can only create new EnumerableSets for types that fit
    // in bytes32.

    struct Set {
        // Storage of set values
        bytes32[] _values;
        // Position of the value in the `values` array, plus 1 because index 0
        // means a value is not in the set.
        mapping(bytes32 => uint256) _indexes;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function _add(Set storage set, bytes32 value) private returns (bool) {
        if (!_contains(set, value)) {
            set._values.push(value);
            // The value is stored at length-1, but we add 1 to all indexes
            // and use 0 as a sentinel value
            set._indexes[value] = set._values.length;
            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function _remove(Set storage set, bytes32 value) private returns (bool) {
        // We read and store the value's index to prevent multiple reads from the same storage slot
        uint256 valueIndex = set._indexes[value];

        if (valueIndex != 0) {
            // Equivalent to contains(set, value)
            // To delete an element from the _values array in O(1), we swap the element to delete with the last one in
            // the array, and then remove the last element (sometimes called as 'swap and pop').
            // This modifies the order of the array, as noted in {at}.

            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;

            if (lastIndex != toDeleteIndex) {
                bytes32 lastValue = set._values[lastIndex];

                // Move the last value to the index where the value to delete is
                set._values[toDeleteIndex] = lastValue;
                // Update the index for the moved value
                set._indexes[lastValue] = valueIndex; // Replace lastValue's index to valueIndex
            }

            // Delete the slot where the moved value was stored
            set._values.pop();

            // Delete the index for the deleted slot
            delete set._indexes[value];

            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function _contains(Set storage set, bytes32 value) private view returns (bool) {
        return set._indexes[value] != 0;
    }

    /**
     * @dev Returns the number of values on the set. O(1).
     */
    function _length(Set storage set) private view returns (uint256) {
        return set._values.length;
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function _at(Set storage set, uint256 index) private view returns (bytes32) {
        return set._values[index];
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function _values(Set storage set) private view returns (bytes32[] memory) {
        return set._values;
    }

    // Bytes32Set

    struct Bytes32Set {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _add(set._inner, value);
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _remove(set._inner, value);
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(Bytes32Set storage set, bytes32 value) internal view returns (bool) {
        return _contains(set._inner, value);
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(Bytes32Set storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(Bytes32Set storage set, uint256 index) internal view returns (bytes32) {
        return _at(set._inner, index);
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(Bytes32Set storage set) internal view returns (bytes32[] memory) {
        bytes32[] memory store = _values(set._inner);
        bytes32[] memory result;

        /// @solidity memory-safe-assembly
        assembly {
            result := store
        }

        return result;
    }

    // AddressSet

    struct AddressSet {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(AddressSet storage set, address value) internal returns (bool) {
        return _add(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(AddressSet storage set, address value) internal returns (bool) {
        return _remove(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(AddressSet storage set, address value) internal view returns (bool) {
        return _contains(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(AddressSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(AddressSet storage set, uint256 index) internal view returns (address) {
        return address(uint160(uint256(_at(set._inner, index))));
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(AddressSet storage set) internal view returns (address[] memory) {
        bytes32[] memory store = _values(set._inner);
        address[] memory result;

        /// @solidity memory-safe-assembly
        assembly {
            result := store
        }

        return result;
    }

    // UintSet

    struct UintSet {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(UintSet storage set, uint256 value) internal returns (bool) {
        return _add(set._inner, bytes32(value));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(UintSet storage set, uint256 value) internal returns (bool) {
        return _remove(set._inner, bytes32(value));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(UintSet storage set, uint256 value) internal view returns (bool) {
        return _contains(set._inner, bytes32(value));
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(UintSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(UintSet storage set, uint256 index) internal view returns (uint256) {
        return uint256(_at(set._inner, index));
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(UintSet storage set) internal view returns (uint256[] memory) {
        bytes32[] memory store = _values(set._inner);
        uint256[] memory result;

        /// @solidity memory-safe-assembly
        assembly {
            result := store
        }

        return result;
    }
}
// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity >=0.5.0;

/// @title Callback for IUniswapV3PoolActions#swap
/// @notice Any contract that calls IUniswapV3PoolActions#swap must implement this interface
interface IUniswapV3SwapCallback {
    /// @notice Called to `msg.sender` after executing a swap via IUniswapV3Pool#swap.
    /// @dev In the implementation you must pay the pool tokens owed for the swap.
    /// The caller of this method must be checked to be a UniswapV3Pool deployed by the canonical UniswapV3Factory.
    /// amount0Delta and amount1Delta can both be 0 if no tokens were swapped.
    /// @param amount0Delta The amount of token0 that was sent (negative) or must be received (positive) by the pool by
    /// the end of the swap. If positive, the callback must send that amount of token0 to the pool.
    /// @param amount1Delta The amount of token1 that was sent (negative) or must be received (positive) by the pool by
    /// the end of the swap. If positive, the callback must send that amount of token1 to the pool.
    /// @param data Any data passed through by the caller via the IUniswapV3PoolActions#swap call
    function uniswapV3SwapCallback(
        int256 amount0Delta,
        int256 amount1Delta,
        bytes calldata data
    ) external;
}
// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity >=0.7.5;
pragma abicoder v2;

import '@uniswap/v3-core/contracts/interfaces/callback/IUniswapV3SwapCallback.sol';

/// @title Router token swapping functionality
/// @notice Functions for swapping tokens via Uniswap V3
interface ISwapRouter is IUniswapV3SwapCallback {
    struct ExactInputSingleParams {
        address tokenIn;
        address tokenOut;
        uint24 fee;
        address recipient;
        uint256 deadline;
        uint256 amountIn;
        uint256 amountOutMinimum;
        uint160 sqrtPriceLimitX96;
    }

    /// @notice Swaps `amountIn` of one token for as much as possible of another token
    /// @param params The parameters necessary for the swap, encoded as `ExactInputSingleParams` in calldata
    /// @return amountOut The amount of the received token
    function exactInputSingle(ExactInputSingleParams calldata params) external payable returns (uint256 amountOut);

    struct ExactInputParams {
        bytes path;
        address recipient;
        uint256 deadline;
        uint256 amountIn;
        uint256 amountOutMinimum;
    }

    /// @notice Swaps `amountIn` of one token for as much as possible of another along the specified path
    /// @param params The parameters necessary for the multi-hop swap, encoded as `ExactInputParams` in calldata
    /// @return amountOut The amount of the received token
    function exactInput(ExactInputParams calldata params) external payable returns (uint256 amountOut);

    struct ExactOutputSingleParams {
        address tokenIn;
        address tokenOut;
        uint24 fee;
        address recipient;
        uint256 deadline;
        uint256 amountOut;
        uint256 amountInMaximum;
        uint160 sqrtPriceLimitX96;
    }

    /// @notice Swaps as little as possible of one token for `amountOut` of another token
    /// @param params The parameters necessary for the swap, encoded as `ExactOutputSingleParams` in calldata
    /// @return amountIn The amount of the input token
    function exactOutputSingle(ExactOutputSingleParams calldata params) external payable returns (uint256 amountIn);

    struct ExactOutputParams {
        bytes path;
        address recipient;
        uint256 deadline;
        uint256 amountOut;
        uint256 amountInMaximum;
    }

    /// @notice Swaps as little as possible of one token for `amountOut` of another along the specified path (reversed)
    /// @param params The parameters necessary for the multi-hop swap, encoded as `ExactOutputParams` in calldata
    /// @return amountIn The amount of the input token
    function exactOutput(ExactOutputParams calldata params) external payable returns (uint256 amountIn);
}
// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity >=0.6.0;

import '@openzeppelin/contracts/token/ERC20/IERC20.sol';

library TransferHelper {
    /// @notice Transfers tokens from the targeted address to the given destination
    /// @notice Errors with 'STF' if transfer fails
    /// @param token The contract address of the token to be transferred
    /// @param from The originating address from which the tokens will be transferred
    /// @param to The destination address of the transfer
    /// @param value The amount to be transferred
    function safeTransferFrom(
        address token,
        address from,
        address to,
        uint256 value
    ) internal {
        (bool success, bytes memory data) =
            token.call(abi.encodeWithSelector(IERC20.transferFrom.selector, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'STF');
    }

    /// @notice Transfers tokens from msg.sender to a recipient
    /// @dev Errors with ST if transfer fails
    /// @param token The contract address of the token which will be transferred
    /// @param to The recipient of the transfer
    /// @param value The value of the transfer
    function safeTransfer(
        address token,
        address to,
        uint256 value
    ) internal {
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(IERC20.transfer.selector, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'ST');
    }

    /// @notice Approves the stipulated contract to spend the given allowance in the given token
    /// @dev Errors with 'SA' if transfer fails
    /// @param token The contract address of the token to be approved
    /// @param to The target of the approval
    /// @param value The amount of the given token the target will be allowed to spend
    function safeApprove(
        address token,
        address to,
        uint256 value
    ) internal {
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(IERC20.approve.selector, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'SA');
    }

    /// @notice Transfers ETH to the recipient address
    /// @dev Fails with `STE`
    /// @param to The destination of the transfer
    /// @param value The value to be transferred
    function safeTransferETH(address to, uint256 value) internal {
        (bool success, ) = to.call{value: value}(new bytes(0));
        require(success, 'STE');
    }
}
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import "./INonfungiblePositionManager.sol";

/**
 * @title Liquidity Lock Interface (ILiqLockV1)
 * @dev This interface defines the functions and events for managing liquidity locks on the blockchain.
 */
interface ILiqLockV1 {
    /**
     * @dev Emitted when a liquidity lock is created.
     * @param creator The address of the lock creator.
     * @param lockId The unique identifier for the created lock.
     * @param nftId The ID of the NFT representing the lock.
     * @param unlockTimestamp The timestamp when the lock expires.
     * @param owner The address of the lock owner.
     * @param taxCollectionAddress The address where tax is collected.
     * @param referralAddress The address of the referral (if any).
     */
    event LiquidityLockCreated(
        address indexed creator,
        uint256 indexed lockId,
        address nftManager,
        uint256 nftId,
        uint256 unlockTimestamp,
        address owner,
        address taxCollectionAddress,
        address referralAddress
    );

    /**
     * @dev Emitted when taxes are collected from a liquidity lock.
     * @param collector The address of the tax collector.
     * @param lockId The unique identifier for the lock.
     * @param amount0 The amount of token0 collected.
     * @param amount1 The amount of token1 collected.
     */
    event LiquidityFeesCollected(
        address indexed collector,
        uint256 indexed lockId,
        uint256 amount0,
        uint256 amount1
    );

    /**
     * @dev Emitted when the NFT representing liquidity is withdrawn.
     * @param owner The address of the lock owner.
     * @param lockId The unique identifier for the lock.
     */
    event LiquidityNFTWithdrawn(address indexed owner, uint256 indexed lockId);

    /**
     * @dev Emitted when the duration of a lock is extended.
     * @param lockId The unique identifier for the lock.
     * @param newLockTimestamp The new expiration timestamp.
     */
    event LockExtended(uint256 indexed lockId, uint256 newLockTimestamp);

    /**
     * @dev Emitted when the ownership of a lock is transferred.
     * @param lockId The unique identifier for the lock.
     * @param newOwner The address of the new owner.
     */
    event LockOwnershipTransferred(
        uint256 indexed lockId,
        address indexed newOwner
    );
    /**
     * @dev Emitted when the tax collection address for a lock is set.
     * @param lockId The unique identifier for the lock.
     * @param newTaxAddress The new tax collection address.
     */
    event LiquidityFeeCollectionAddressSet(
        uint256 indexed lockId,
        address indexed newTaxAddress
    );

    /**
     * @dev Emitted when the tax amount for the LiqLock contract is updated.
     * @param newLiqLockTaxAmount The new tax amount.
     */
    event LiqLockTaxAmountSet(uint256 indexed newLiqLockTaxAmount);

    /**
     * @dev Emitted when the tax address for the LiqLock contract is updated.
     * @param newLiqLockTaxAddress The new tax address.
     */
    event LiqLockTaxAddressSet(address indexed newLiqLockTaxAddress);

    /**
     * @dev Emitted when the LILO token address is set.
     * @param newLILOTokenAddress The new LILO token address.
     */
    event LILOTokenAddressSet(address indexed newLILOTokenAddress);

    /**
     * @dev Emitted when the swap router address is set.
     * @param newSwapRouterAddress The new swap router address.
     */
    event SwapRouterAddressSet(address indexed newSwapRouterAddress);

    /**
     * @dev Emitted when the WETH9 address is set.
     * @param newWETH9Address The new WETH9 address.
     */
    event WETH9AddressSet(address indexed newWETH9Address);

    /**
     * @dev Emitted when the pool fee is set.
     * @param newPoolFee The new pool fee.
     */
    event PoolFeeSet(uint24 indexed newPoolFee);

    /**
     * @dev Struct representing a liquidity lock.
     * @param nftManager The address of the NFT Manager.
     * @param lockId The unique identifier for the lock.
     * @param nftId The ID of the NFT representing the lock.
     * @param unlockTimestamp The timestamp when the lock expires.
     * @param owner The address of the lock owner.
     * @param taxCollectionAddress The address where tax is collected.
     */
    struct LiqLockLock {
        INonfungiblePositionManager nftManager;
        uint256 lockId;
        uint256 nftId;
        uint256 unlockTimestamp;
        address owner;
        address taxCollectionAddress;
    }

    /**
     * @dev Struct representing creation parameters for a liquidity lock.
     * @param nftManager The address of the NFT Manager.
     * @param nftId The ID of the NFT representing the lock.
     * @param unlockTimestamp The timestamp when the lock expires in seconds.
     * @param owner The address of the lock owner.
     * @param taxCollectionAddress The address where tax will be sent to.
     * @param referralAddress The address of the referral (if any).
     */
    struct LiqLockCreationParams {
        INonfungiblePositionManager nftManager;
        uint256 nftId;
        uint256 unlockTimestamp;
        address owner;
        address taxCollectionAddress;
        address referralAddress;
    }

    /* 
        USER FUNCTIONS
    */

    /**
     * @dev Creates a new liquidity lock.
     * @param lockParams Creation parameters for the liquidity lock.
     * @return lockId Unique identifier for the created lock.
     */
    function createLiquidityLock(
        LiqLockCreationParams calldata lockParams
    ) external payable returns (uint256 lockId);

    /**
     * @dev Collects taxes from a liquidity lock.
     * @param lockId Unique identifier for the lock.
     * @param taxRecipient Address where collected taxes are sent to.
     * @param amountMax0 Maximum amount of token0 to collect.
     * @param amountMax1 Maximum amount of token1 to collect.
     * @return amount0 Amount of token0 collected.
     * @return amount1 Amount of token1 collected.
     */
    function collectLiquidityFees(
        uint256 lockId,
        address taxRecipient,
        uint128 amountMax0,
        uint128 amountMax1
    ) external returns (uint256 amount0, uint256 amount1);

    /**
     * @dev Withdraws liquidity NFT from a lock.
     * @param lockId Unique identifier for the lock.
     */
    function withdrawLiquidityLock(uint256 lockId) external;

    /**
     * @dev Extends the lock duration for a liquidity lock.
     * @param lockId Unique identifier for the lock.
     * @param newLockDuration New duration to extend the lock (in seconds).
     */
    function extendLockDuration(
        uint256 lockId,
        uint256 newLockDuration
    ) external;

    /**
     * @dev Transfers ownership of a liquidity lock to a new owner.
     * @param lockId Unique identifier for the lock.
     * @param newOwner Address of the new owner.
     */
    function transferLockOwnership(uint256 lockId, address newOwner) external;

    /**
     * @dev Sets the fee collection address for a liquidity lock.
     * @param lockId Unique identifier for the lock.
     * @param newTaxAddress New fee collection address.
     */
    function setLiquidityFeeCollectionAddress(
        uint256 lockId,
        address newTaxAddress
    ) external;

    /**
     * @dev Retrieve the unique associated LiqLockLock struct for an NFT.
     * @param nftManager The address of the NFT Manager.
     * @param nftId The ID of the NFT.
     * @return lock The LiqLockLock struct associated with the NFT.
     */
    function getLiqLockLockByNFT(
        INonfungiblePositionManager nftManager,
        uint256 nftId
    ) external view returns (LiqLockLock memory);

    /**
     * @dev Returns an array of LiqLockLock structs owned by the specified address.
     * @param owner The address of the owner to retrieve the locks for.
     * @return locks An array of LiqLockLock structs owned by the specified address.
     */
    function getLickLockLocksByOwner(
        address owner
    ) external view returns (LiqLockLock[] memory locks);

    /* 
        ADMIN FUNCTIONS
    */

    /**
     * @dev Sets the tax amount for the LiqLock contract.
     * @param newTaxAmount New tax amount.
     */
    function setLiqLockTaxAmount(uint256 newTaxAmount) external;

    /**
     * @dev Sets the tax address for the LiqLock contract.
     * @param newTaxAddress New tax address.
     */
    function setLiqLockTaxAddress(address newTaxAddress) external;

    /**
     * @dev Sets the address of the LILO token contract.
     * @param newLILOTokenAddress The address of the new LILO token contract.
     */
    function setLILOTokenAddress(address newLILOTokenAddress) external;

    /**
     * @dev Sets the address of the swap router contract.
     * @param newSwapRouterAddress The address of the new swap router contract.
     */
    function setSwapRouterAddress(address newSwapRouterAddress) external;

    /**
     * @dev Sets the address of the WETH9 contract.
     * @param newWETH9Address The address of the new WETH9 contract.
     */
    function setWETH9Address(address newWETH9Address) external;

    /**
     * @dev Sets the pool fee.
     * @param newPoolFee The new pool fee.
     */
    function setPoolFee(uint24 newPoolFee) external;
}
// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.9;

import "./IPoolInitializer.sol";

interface INonfungiblePositionManager is IPoolInitializer {

    function approve(address to, uint256 tokenId) external;
    
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    struct MintParams {
        address token0;
        address token1;
        uint24 fee;
        int24 tickLower;
        int24 tickUpper;
        uint256 amount0Desired;
        uint256 amount1Desired;
        uint256 amount0Min;
        uint256 amount1Min;
        address recipient;
        uint256 deadline;
    }

    function mint(
        MintParams calldata params
    )
        external
        payable
        returns (
            uint256 tokenId,
            uint128 liquidity,
            uint256 amount0,
            uint256 amount1
        );

    struct Position {
        uint96 nonce;
        address operator;
        address token0;
        address token1;
        uint24 fee;
        int24 tickLower;
        int24 tickUpper;
        uint128 liquidity;
        uint256 feeGrowthInside0LastX128;
        uint256 feeGrowthInside1LastX128;
        uint128 tokensOwed0;
        uint128 tokensOwed1;
    }

    function positions(
        uint256 tokenId
    )
        external
        view
        returns (
            uint96 nonce,
            address operator,
            address token0,
            address token1,
            uint24 fee,
            int24 tickLower,
            int24 tickUpper,
            uint128 liquidity,
            uint256 feeGrowthInside0LastX128,
            uint256 feeGrowthInside1LastX128,
            uint128 tokensOwed0,
            uint128 tokensOwed1
        );

    struct IncreaseLiquidityParams {
        uint256 tokenId;
        uint256 amount0Desired;
        uint256 amount1Desired;
        uint256 amount0Min;
        uint256 amount1Min;
        uint256 deadline;
    }

    /// @notice Increases the amount of liquidity in a position, with tokens paid by the `msg.sender`
    /// @param params tokenId The ID of the token for which liquidity is being increased,
    /// amount0Desired The desired amount of token0 to be spent,
    /// amount1Desired The desired amount of token1 to be spent,
    /// amount0Min The minimum amount of token0 to spend, which serves as a slippage check,
    /// amount1Min The minimum amount of token1 to spend, which serves as a slippage check,
    /// deadline The time by which the transaction must be included to effect the change
    /// @return liquidity The new liquidity amount as a result of the increase
    /// @return amount0 The amount of token0 to acheive resulting liquidity
    /// @return amount1 The amount of token1 to acheive resulting liquidity
    function increaseLiquidity(IncreaseLiquidityParams calldata params)
        external
        payable
        returns (
            uint128 liquidity,
            uint256 amount0,
            uint256 amount1
        );

    struct DecreaseLiquidityParams {
        uint256 tokenId;
        uint128 liquidity;
        uint256 amount0Min;
        uint256 amount1Min;
        uint256 deadline;
    }

    /// @notice Decreases the amount of liquidity in a position and accounts it to the position
    /// @param params tokenId The ID of the token for which liquidity is being decreased,
    /// amount The amount by which liquidity will be decreased,
    /// amount0Min The minimum amount of token0 that should be accounted for the burned liquidity,
    /// amount1Min The minimum amount of token1 that should be accounted for the burned liquidity,
    /// deadline The time by which the transaction must be included to effect the change
    /// @return amount0 The amount of token0 accounted to the position's tokens owed
    /// @return amount1 The amount of token1 accounted to the position's tokens owed
    function decreaseLiquidity(DecreaseLiquidityParams calldata params)
        external
        payable
        returns (uint256 amount0, uint256 amount1);

    struct CollectParams {
        uint256 tokenId;
        address recipient;
        uint128 amount0Max;
        uint128 amount1Max;
    }

    function collect(
        CollectParams calldata params
    ) external payable returns (uint256 amount0, uint256 amount1);

    function factory() external view returns (address);

    function burn(uint256 tokenId) external payable;
}// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity >=0.7.5;
pragma abicoder v2;

/// @title Creates and initializes V3 Pools
/// @notice Provides a method for creating and initializing a pool, if necessary, for bundling with other methods that
/// require the pool to exist.
interface IPoolInitializer {
    /// @notice Creates a new pool if it does not exist, then initializes if not initialized
    /// @dev This method can be bundled with others via IMulticall for the first action (e.g. mint) performed against a pool
    /// @param token0 The contract address of token0 of the pool
    /// @param token1 The contract address of token1 of the pool
    /// @param fee The fee amount of the v3 pool for the specified token pair
    /// @param sqrtPriceX96 The initial square root price of the pool as a Q64.96 value
    /// @return pool Returns the pool address based on the pair of tokens and fee, will return the newly created pool address if necessary
    function createAndInitializePoolIfNecessary(
        address token0,
        address token1,
        uint24 fee,
        uint160 sqrtPriceX96
    ) external payable returns (address pool);
}
// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.19;

import '@openzeppelin/contracts/token/ERC20/IERC20.sol';

/// @title Interface for WETH9
interface IWETH9 is IERC20 {
    /// @notice Deposit ether to get wrapped ether
    function deposit() external payable;

    /// @notice Withdraw wrapped ether to get ether
    function withdraw(uint256) external;
}// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;
pragma abicoder v2;

/**
    Welcome to LiqLockV1!
    This is a smart contract that manages liquidity locks for Uniswap-like V3 LP NFTs.

    LiqLockV1 is a part of the LiqLock (Liquidity Lock) project by LiqLock Team.
    LiqLock Team is a team of blockchain developers who are passionate about the DeFi space and are
    committed to building and maintaining useful DeFi tools and services.
    LiqLock is a community-driven project and we welcome any feedback or suggestions.

    Feel free to reach out to us on:
    - Telegram at https://t.me/liqlock_cc
    - Twitter at https://twitter.com/liqlock_cc
    - Email at contact@liqlock.cc
    
    For more information about LiqLock, please visit https://liqlock.cc
    Check out our whitepaper at https://liqlock.cc/whitepaper
*/

// Import relevant interfaces and contracts
import "./Interfaces/ILiqLockV1.sol";
import "./Interfaces/INonfungiblePositionManager.sol";
import "./Interfaces/IWETH9.sol";
import "../ERC20/Interfaces/ILiLo.sol";

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";

// Import OpenZeppelin's EnumerableSet for managing sets
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

import "@uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol";
import "@uniswap/v3-periphery/contracts/libraries/TransferHelper.sol";

/**
 * @title LiqLockV1
 * @dev A smart contract that manages liquidity locks for Uniswap-like V3 LP NFTs.
 */
contract LiqLockV1 is
    ILiqLockV1,
    Ownable,
    ReentrancyGuard,
    Pausable,
    IERC721Receiver
{
    using EnumerableSet for EnumerableSet.UintSet;

    // Constants and state variables for tax management
    uint256 public TAX_AMOUNT;
    address public TAX_ADDRESS;

    // Constant for permanent lock timestamp
    uint256 public constant PERMANENT_LOCK_TIMESTAMP = type(uint256).max; // 2^256 - 1, maximum value for uint256

    // Mapping to store liquidity lock information
    mapping(uint256 => LiqLockLock) public LIQ_LOCK_LOCKS;

    // Mapping to track liquidity locks by owner
    mapping(address => EnumerableSet.UintSet) LIQ_LOCKS_BY_OWNER;

    // Nonce for generating unique lock IDs
    uint256 public NONCE = 0;

    // Reference to the LILO token contract
    ILiLo public LILO_TOKEN;

    // Reference to the Uniswap V3 Swap Router
    ISwapRouter public SWAP_ROUTER;

    IWETH9 public WETH9;

    uint24 internal POOL_FEE = 10000;

    /**
     * @dev Constructor initializes default tax values.
     */
    constructor(address _liloToken, address _swapRouter, address _weth9) {
        TAX_AMOUNT = 0; // Please read this value from the contract after deployment
        TAX_ADDRESS = msg.sender;
        LILO_TOKEN = ILiLo(_liloToken);
        SWAP_ROUTER = ISwapRouter(_swapRouter);
        WETH9 = IWETH9(_weth9);
    }

    /**
     * @inheritdoc ILiqLockV1
     */
    function createLiquidityLock(
        LiqLockCreationParams calldata lockParams
    ) external payable whenNotPaused nonReentrant returns (uint256 lockId) {
        // Check validity of lock creation parameters
        require(
            lockParams.unlockTimestamp > block.timestamp,
            "LiqLockV1: Unlock timestamp must be in the future"
        );
        require(
            lockParams.unlockTimestamp < 1e10 ||
                lockParams.unlockTimestamp == PERMANENT_LOCK_TIMESTAMP,
            "LiqLockV1: Timestamp must be in seconds and not in milliseconds, or max uint256 value for permanent lock"
        );
        require(
            lockParams.owner != address(0),
            "LiqLockV1: Owner address cannot be 0x0"
        );
        require(
            msg.value == TAX_AMOUNT,
            "LiqLockV1: Paid amount must be equal to TAX_AMOUNT"
        );
        require(
            lockParams.referralAddress != msg.sender,
            "LiqLockV1: Referral cannot be self"
        );

        // Generate a unique lock ID
        lockId = NONCE;
        NONCE++;

        // Store liquidity lock information
        LIQ_LOCK_LOCKS[lockId] = LiqLockLock({
            nftManager: lockParams.nftManager,
            lockId: lockId,
            nftId: lockParams.nftId,
            unlockTimestamp: lockParams.unlockTimestamp,
            owner: lockParams.owner,
            taxCollectionAddress: lockParams.taxCollectionAddress
        });

        // Handle creation tax distribution
        if(TAX_AMOUNT > 0){
            _handleCreationTax(msg.value, lockParams.referralAddress);
        }

        // Transfer the NFT to this contract
        lockParams.nftManager.safeTransferFrom(
            msg.sender,
            address(this),
            lockParams.nftId
        );

        // Track liquidity locks by owner
        bool lockAdditionSuccess = LIQ_LOCKS_BY_OWNER[lockParams.owner].add(
            lockId
        );
        require(
            lockAdditionSuccess,
            "LiqLockV1: Failed to add lock to owner's set of locks"
        );

        // Emit an event to signify lock creation
        emit LiquidityLockCreated(
            msg.sender,
            lockId,
            address(lockParams.nftManager),
            lockParams.nftId,
            lockParams.unlockTimestamp,
            lockParams.owner,
            lockParams.taxCollectionAddress,
            lockParams.referralAddress
        );
    }

    /**
     * @dev Internal function to handle the distribution of creation tax.
     * @param creationTaxReceived The amount of tax received during lock creation.
     * @param referralAddress The address of the referral (if provided).
     */
    function _handleCreationTax(
        uint256 creationTaxReceived,
        address referralAddress
    ) internal {
        // Calculate the portion of tax for LILO token buy and burn
        uint256 creationTaxForLilo = (creationTaxReceived * 33) / 100;
        uint256 creationTaxForDev;
        uint256 creationTaxForReferral;

        //@TODO: Remove this check once LILO token is deployed
        if (address(LILO_TOKEN) != address(0)) {
            // Buy LILO tokens with the tax amount
            _handleLiloBuyBurn(creationTaxForLilo);
        }

        if (referralAddress != address(0)) {
            // If a referral is provided, distribute tax accordingly
            creationTaxForReferral = (creationTaxReceived * 34) / 100;
            creationTaxForDev =
                creationTaxReceived -
                creationTaxForLilo -
                creationTaxForReferral;

            // Send the referral tax to the referral address
            bool referalSuccess = false;
            (referalSuccess, ) = referralAddress.call{
                value: creationTaxForReferral
            }("");
            require(referalSuccess, "LiqLockV1: Failed to send referral tax");

            // Send the dev tax to the dev address
            bool taxSuccess = false;
            (taxSuccess, ) = TAX_ADDRESS.call{value: creationTaxForDev}("");
            require(taxSuccess, "LiqLockV1: Failed to send dev tax");
        } else {
            // If no referral, the entire tax goes to the dev
            creationTaxForDev = creationTaxReceived - creationTaxForLilo;

            // Send the dev tax to the dev address
            bool taxSuccess = false;
            (taxSuccess, ) = TAX_ADDRESS.call{value: creationTaxForDev}("");
            require(taxSuccess, "LiqLockV1: Failed to send dev tax");
        }
    }

    /**
     * @dev Internal function to buy LILO tokens with the tax amount and burn them.
     * @param amountIn The amount of ETH to be spent on LILO tokens.
     */
    function _handleLiloBuyBurn(uint256 amountIn) internal {

        ISwapRouter.ExactInputSingleParams memory liloSwapParams = ISwapRouter
            .ExactInputSingleParams({
                tokenIn: address(WETH9),
                tokenOut: address(LILO_TOKEN),
                fee: POOL_FEE,
                recipient: address(this),
                deadline: block.timestamp,
                amountIn: amountIn,
                amountOutMinimum: 0,
                sqrtPriceLimitX96: 0
            });

        // Deposit WETH9 and approve the swap router
        WETH9.deposit{value: amountIn}();
        TransferHelper.safeApprove(
            address(WETH9),
            address(SWAP_ROUTER),
            amountIn
        );

        // The call to `exactInputSingle` executes the swap.
        uint256 liloAmountOut = SWAP_ROUTER.exactInputSingle(liloSwapParams);

        // Burn the LILO tokens
        LILO_TOKEN.burn(liloAmountOut);
    }

    /**
     * @inheritdoc ILiqLockV1
     */
    function collectLiquidityFees(
        uint256 lockId,
        address taxRecipient,
        uint128 amountMax0,
        uint128 amountMax1
    ) external returns (uint256 amount0, uint256 amount1) {
        // Retrieve the liquidity lock information
        LiqLockLock memory lock = LIQ_LOCK_LOCKS[lockId];
        require(
            lock.owner == msg.sender || lock.taxCollectionAddress == msg.sender,
            "LiqLockV1: Only the owner or tax collector can collect taxes"
        );

        // Collect taxes using the NFT manager contract
        (amount0, amount1) = lock.nftManager.collect(
            INonfungiblePositionManager.CollectParams({
                tokenId: lock.nftId,
                recipient: taxRecipient,
                amount0Max: amountMax0,
                amount1Max: amountMax1
            })
        );

        // Emit an event to signify tax collection
        emit LiquidityFeesCollected(taxRecipient, lockId, amount0, amount1);
    }

    /**
     * @inheritdoc ILiqLockV1
     */
    function withdrawLiquidityLock(uint256 lockId) external {
        // Retrieve the liquidity lock information
        LiqLockLock memory lock = LIQ_LOCK_LOCKS[lockId];
        require(
            lock.owner == msg.sender,
            "LiqLockV1: Only the owner can withdraw the liquidity lock"
        );
        if (lock.unlockTimestamp == PERMANENT_LOCK_TIMESTAMP) {
            revert("LiqLockV1: Permanent lock cannot be withdrawn");
        } else if (lock.unlockTimestamp > block.timestamp) {
            revert("LiqLockV1: Lock is still active");
        }

        // Clean up the lock data
        delete LIQ_LOCK_LOCKS[lockId];

        // Remove the lock from the owner's set of locks
        bool lockDeletionSuccess = LIQ_LOCKS_BY_OWNER[lock.owner].remove(
            lockId
        );
        require(
            lockDeletionSuccess,
            "LiqLockV1: Failed to remove lock from owner's set of locks"
        );

        // Emit an event to signify NFT withdrawal
        emit LiquidityNFTWithdrawn(msg.sender, lockId);

        // Transfer the NFT back to the owner
        lock.nftManager.safeTransferFrom(address(this), msg.sender, lock.nftId);
    }

    /**
     * @inheritdoc ILiqLockV1
     */
    function extendLockDuration(
        uint256 lockId,
        uint256 newLockTimestamp
    ) external {
        // Retrieve the liquidity lock information
        LiqLockLock storage lock = LIQ_LOCK_LOCKS[lockId];
        require(
            lock.owner == msg.sender,
            "LiqLockV1: Only the owner can extend the lock duration"
        );
        require(
            newLockTimestamp > lock.unlockTimestamp,
            "LiqLockV1: Date must be greater than the current unlock timestamp"
        );
        require(
            newLockTimestamp > block.timestamp,
            "LiqLockV1: Unlock timestamp must be in the future"
        );
        require(
            newLockTimestamp < 1e10 ||
                newLockTimestamp == PERMANENT_LOCK_TIMESTAMP,
            "LiqLockV1: Timestamp must be in seconds and not in milliseconds, or max uint256 value for permanent lock"
        );

        // Update the lock's unlock timestamp
        lock.unlockTimestamp = newLockTimestamp;

        // Emit an event to signify lock extension
        emit LockExtended(lockId, newLockTimestamp);
    }

    /**
     * @inheritdoc ILiqLockV1
     */
    function transferLockOwnership(uint256 lockId, address newOwner) external {
        // Retrieve the liquidity lock information
        LiqLockLock storage lock = LIQ_LOCK_LOCKS[lockId];
        require(
            lock.owner == msg.sender,
            "LiqLockV1: Only the owner can transfer the lock ownership"
        );
        require(newOwner != address(0), "LiqLockV1: New owner cannot be 0x0");

        // Remove the lock from the current owner's set of locks
        bool lockDeletionSuccess = LIQ_LOCKS_BY_OWNER[lock.owner].remove(
            lockId
        );
        require(
            lockDeletionSuccess,
            "LiqLockV1: Failed to remove lock from owner's set of locks"
        );

        // Add the lock to the new owner's set of locks
        bool lockAdditionSucess = LIQ_LOCKS_BY_OWNER[newOwner].add(lockId);
        require(
            lockAdditionSucess,
            "LiqLockV1: Failed to add lock to new owner's set of locks"
        );

        emit LockOwnershipTransferred(lockId, newOwner);

        // Update the owner address
        lock.owner = newOwner;
    }

    /**
     * @inheritdoc ILiqLockV1
     */
    function setLiquidityFeeCollectionAddress(
        uint256 lockId,
        address newTaxAddress
    ) external {
        // Retrieve the liquidity lock information
        LiqLockLock storage lock = LIQ_LOCK_LOCKS[lockId];
        require(
            lock.owner == msg.sender,
            "LiqLockV1: Only the owner can set the liquidity fee collection address"
        );

        // Update the tax collection address
        lock.taxCollectionAddress = newTaxAddress;

        // Emit an event to signify the tax address update
        emit LiquidityFeeCollectionAddressSet(lockId, newTaxAddress);
    }

    /**
     * @inheritdoc ILiqLockV1
     */
    function setLiqLockTaxAmount(uint256 newTaxAmount) external onlyOwner {
        TAX_AMOUNT = newTaxAmount;

        // Emit an event to signify the tax amount update
        emit LiqLockTaxAmountSet(newTaxAmount);
    }

    /**
     * @inheritdoc ILiqLockV1
     */
    function setLiqLockTaxAddress(address newTaxAddress) external onlyOwner {
        require(
            newTaxAddress != address(0),
            "LiqLockV1: Tax address cannot be 0x0"
        );
        TAX_ADDRESS = newTaxAddress;

        // Emit an event to signify the tax address update
        emit LiqLockTaxAddressSet(newTaxAddress);
    }

    /**
     * @inheritdoc ILiqLockV1
     */
    function setLILOTokenAddress(
        address newLILOTokenAddress
    ) external onlyOwner {
        LILO_TOKEN = ILiLo(newLILOTokenAddress);

        // Emit an event to signify the LILO token address update
        emit LILOTokenAddressSet(newLILOTokenAddress);
    }

    /**
     * @inheritdoc ILiqLockV1
     */
    function setSwapRouterAddress(
        address newSwapRouterAddress
    ) external onlyOwner {
        require(
            newSwapRouterAddress != address(0),
            "LiqLockV1: Swap router address cannot be 0x0"
        );
        SWAP_ROUTER = ISwapRouter(newSwapRouterAddress);

        // Emit an event to signify the swap router address update
        emit SwapRouterAddressSet(newSwapRouterAddress);
    }

    /**
     * @inheritdoc ILiqLockV1
     */
    function setWETH9Address(address newWETH9Address) external onlyOwner {
        require(
            newWETH9Address != address(0),
            "LiqLockV1: WETH9 address cannot be 0x0"
        );
        WETH9 = IWETH9(newWETH9Address);

        // Emit an event to signify the WETH9 address update
        emit WETH9AddressSet(newWETH9Address);
    }

    /**
     * @inheritdoc ILiqLockV1
     */
     function setPoolFee(uint24 newPoolFee) external onlyOwner {
         POOL_FEE = newPoolFee;

         // Emit an event to signify the pool fee update
         emit PoolFeeSet(newPoolFee);
     }

    /**
     * @inheritdoc IERC721Receiver
     * @dev Overrides the default ERC721 receiver function and returns the selector.
     */
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) public pure override returns (bytes4) {
        return IERC721Receiver.onERC721Received.selector;
    }

    /**
     * @inheritdoc ILiqLockV1
     */
    function getLiqLockLockByNFT(
        INonfungiblePositionManager nftManager,
        uint256 nftId
    ) external view returns (LiqLockLock memory lock) {
        //Lookup through all locks to find the one with the matching NFT
        for (uint256 i = 0; i < NONCE; i++) {
            LiqLockLock memory currentLock = LIQ_LOCK_LOCKS[i];
            if (
                currentLock.nftManager == nftManager &&
                currentLock.nftId == nftId
            ) {
                return currentLock;
            }
        }
        // If no lock is found, return an empty lock
        return
            LiqLockLock({
                nftManager: INonfungiblePositionManager(address(0)),
                lockId: 0,
                nftId: 0,
                unlockTimestamp: 0,
                owner: address(0),
                taxCollectionAddress: address(0)
            });
    }

    /**
     * @inheritdoc ILiqLockV1
     */
    function getLickLockLocksByOwner(
        address lockOwner
    ) external view returns (LiqLockLock[] memory locks) {
        EnumerableSet.UintSet storage ownerLocks = LIQ_LOCKS_BY_OWNER[
            lockOwner
        ];
        uint256 numLocks = ownerLocks.length();
        locks = new LiqLockLock[](numLocks);
        for (uint256 i = 0; i < numLocks; i++) {
            locks[i] = LIQ_LOCK_LOCKS[ownerLocks.at(i)];
        }
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

// Imports erc20 interface
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface ILiLo is IERC20 {
    
    function burn(uint256 amount) external;
}