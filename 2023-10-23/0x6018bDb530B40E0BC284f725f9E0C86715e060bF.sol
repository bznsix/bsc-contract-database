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
// OpenZeppelin Contracts (last updated v4.9.0) (utils/Create2.sol)

pragma solidity ^0.8.0;

/**
 * @dev Helper to make usage of the `CREATE2` EVM opcode easier and safer.
 * `CREATE2` can be used to compute in advance the address where a smart
 * contract will be deployed, which allows for interesting new mechanisms known
 * as 'counterfactual interactions'.
 *
 * See the https://eips.ethereum.org/EIPS/eip-1014#motivation[EIP] for more
 * information.
 */
library Create2 {
    /**
     * @dev Deploys a contract using `CREATE2`. The address where the contract
     * will be deployed can be known in advance via {computeAddress}.
     *
     * The bytecode for a contract can be obtained from Solidity with
     * `type(contractName).creationCode`.
     *
     * Requirements:
     *
     * - `bytecode` must not be empty.
     * - `salt` must have not been used for `bytecode` already.
     * - the factory must have a balance of at least `amount`.
     * - if `amount` is non-zero, `bytecode` must have a `payable` constructor.
     */
    function deploy(uint256 amount, bytes32 salt, bytes memory bytecode) internal returns (address addr) {
        require(address(this).balance >= amount, "Create2: insufficient balance");
        require(bytecode.length != 0, "Create2: bytecode length is zero");
        /// @solidity memory-safe-assembly
        assembly {
            addr := create2(amount, add(bytecode, 0x20), mload(bytecode), salt)
        }
        require(addr != address(0), "Create2: Failed on deploy");
    }

    /**
     * @dev Returns the address where a contract will be stored if deployed via {deploy}. Any change in the
     * `bytecodeHash` or `salt` will result in a new destination address.
     */
    function computeAddress(bytes32 salt, bytes32 bytecodeHash) internal view returns (address) {
        return computeAddress(salt, bytecodeHash, address(this));
    }

    /**
     * @dev Returns the address where a contract will be stored if deployed via {deploy} from a contract located at
     * `deployer`. If `deployer` is this contract's address, returns the same value as {computeAddress}.
     */
    function computeAddress(bytes32 salt, bytes32 bytecodeHash, address deployer) internal pure returns (address addr) {
        /// @solidity memory-safe-assembly
        assembly {
            let ptr := mload(0x40) // Get free memory pointer

            // |                   | ↓ ptr ...  ↓ ptr + 0x0B (start) ...  ↓ ptr + 0x20 ...  ↓ ptr + 0x40 ...   |
            // |-------------------|---------------------------------------------------------------------------|
            // | bytecodeHash      |                                                        CCCCCCCCCCCCC...CC |
            // | salt              |                                      BBBBBBBBBBBBB...BB                   |
            // | deployer          | 000000...0000AAAAAAAAAAAAAAAAAAA...AA                                     |
            // | 0xFF              |            FF                                                             |
            // |-------------------|---------------------------------------------------------------------------|
            // | memory            | 000000...00FFAAAAAAAAAAAAAAAAAAA...AABBBBBBBBBBBBB...BBCCCCCCCCCCCCC...CC |
            // | keccak(start, 85) |            ↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑ |

            mstore(add(ptr, 0x40), bytecodeHash)
            mstore(add(ptr, 0x20), salt)
            mstore(ptr, deployer) // Right-aligned with 12 preceding garbage bytes
            let start := add(ptr, 0x0b) // The hashed data starts at the final garbage byte which we will set to 0xff
            mstore8(start, 0xff)
            addr := keccak256(start, 85)
        }
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
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

interface IbnbBeatsV4 {
    function buy(address ref, uint256 amount) external payable;
    function sell() external;
    function reInvest() external;
    function buyWhiteList() external payable;
    function buySecure() external payable;
    function priceSecure() external view returns (uint256);
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;
import "./IUniswapV2Router02.sol";

abstract contract IContractsLibraryStaking {
    function BUSD() external view virtual returns (address);

    function WBNB() external view virtual returns (address);

    function ROUTER() external view virtual returns (IUniswapV2Router01);

    function getBusdToBNBToToken(
        address token,
        uint _amount
    ) external view virtual returns (uint256);

    function getTokensToBNBtoBusd(
        address token,
        uint _amount
    ) external view virtual returns (uint256);

    function getTokensToBnb(
        address token,
        uint _amount
    ) external view virtual returns (uint256);

    function getBnbToTokens(
        address token,
        uint _amount
    ) public view virtual returns (uint256);

    function getTokenToBnbToAltToken(
        address token,
        address altToken,
        uint _amount
    ) public view virtual returns (uint256);

    function getUsdToBnB(uint amount) external view virtual returns (uint256);
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

interface IUniswapV2Router01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);
    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH);
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;
import "./IUniswapV2Router01.sol";

interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;
interface IMinerHandlerV2 {

    struct Contract {
        address wallet;
        address contractAddress;
    }

    struct User {
        address user;
        uint totalInvested;
        uint lastInvestDate;
        uint currentRewardLevel;
        // uint lastRewardLevel;
        uint totalRewardWithdrawn;
        uint lastWithdrawDate;
    }

    struct Bonus {
        uint amount;
        uint totalWithdrawn;
        uint totalWithdrawBnb;
        uint date;
        uint withdrawDate;
        uint unlockDate;
        uint id;
        uint levelReward;
    }

    function getContractData(uint _index) external view returns(Contract memory);

    function contractCount() external view returns (uint256);

    function walletToContract(address _wallet) external view returns (address);
    function contractToWallet(address _contract) external view returns (address);

    function invest(
        address ref,
        uint256 amount
    ) external;

    // function getUserRewardData(address _user) external view returns (User memory, uint _toWithdraw, uint trueLevel,uint[3] memory _withdrawDate, uint[3] memory _withdrawInterval);

    function getDaTe() external view returns (uint);

    function getUser(address _user) external view returns (User memory);
    
    event CreateWallet(address indexed user, address indexed contractAddress, uint contractId);
    // event PairsCreated(bytes32[] indexed salts, uint indexed contractId);
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IVaultFarm {
    function safeTransfer(IERC20 from, address to, uint amount) external;

    function safeTransfer(address _to, uint _value) external;

    function getTokenAddressBalance(address token) external view returns (uint);

    function getTokenBalance(IERC20 token) external view returns (uint);

    function getBalance() external view returns (uint);

    function safeTransferAdmin(address from, address to, uint amount) external;

    function safeTransferAdmin(address _to, uint _value) external;
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/utils/Create2.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "./MinerSlave.sol";
import "./IMinerHandlerV2.sol";
import "./IVaultFarm.sol";
import "../binary/IbnbBeatsV4.sol";
import "../binary/IContractsLibraryStaking.sol";

contract MinerHandlerV2 is
    IMinerHandlerV2,
    ReentrancyGuard
{
    IERC20 internal token;
    IVaultFarm internal vault;
    IContractsLibraryStaking public contractsLibrary;
    Contract[] internal allcontracts;
    address public minerContract;
    // HARDCODED IN MINER CONTRACT
    uint public constant priceWhiteList = 30 ether;
    uint internal constant PERCENT_DIVIDER = 1000;
    uint public constant INVEST_LEVEL_THRESHOLD = 250 ether;
    uint[3] public REWARDS_BY_TYPE = [150 ether, 200 ether, 250 ether];
    uint[3] public REWARDS_BY_TYPE_INTERVAL = [8 * MONTH, 9 * MONTH, 10 * MONTH];
    uint public constant MONTH = 30 days;
    mapping(address => address) public override walletToContract;
    mapping(address => address) public override contractToWallet;
    mapping(address => User) internal users;
    mapping(address => Bonus[]) public bonuses;

    modifier isDeployed() {
        require(
            walletToContract[msg.sender] != address(0),
            "Contract not deployed"
        );
        _;
    }

    constructor(
        address _tokenAddress,
        address _minerContract,
        address _contractsLibrary,
        address _vault
    ) {
        token = IERC20(_tokenAddress);
        minerContract = _minerContract;
        contractsLibrary = IContractsLibraryStaking(_contractsLibrary);
        vault = IVaultFarm(_vault);
    }

    function getUser(address _user) external view override returns (User memory) {
        return users[_user];
    }

    function getUserBonusCount (address _user) external view returns (uint) {
        return bonuses[_user].length;
    }

    function getUserBonus(address _user) external view returns (Bonus[] memory _bonus) {
        _bonus = bonuses[_user];
        for (uint256 index = 0; index < _bonus.length; index++) {
            (uint reward,,uint _level) = getReward(_user, index);
            if(_bonus[index].levelReward == 0) {
                _bonus[index].levelReward = _level;
                _bonus[index].amount = reward;
            }
        }
        return _bonus;
    }

    function getBonusByIndex(address _user, uint _index) external view returns (Bonus memory) {
        return bonuses[_user][_index];
    }

    function getPublicDataHandler()
        external
        view
        returns (
            address _minerContract,
            address _tokenAddress,
            address _vault,
            address _contractsLibrary
        )
    {
        return (
            minerContract,
            address(token),
            address(vault),
            address(contractsLibrary)
        );
    }

    function contractCount() external view override returns (uint256) {
        return allcontracts.length;
    }

    function getContractData(
        uint index
    ) external view override returns (Contract memory) {
        return allcontracts[index];
    }

    function computerSalt(address wallet) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(wallet));
    }

    function deploy(address _user) internal {
        require(
            walletToContract[_user] == address(0),
            "Contract already deployed"
        );
        bytes memory bytecode = getBytecode();
        bytes32 salt = computerSalt(_user);
        address pair = Create2.deploy(0, salt, bytecode);
        require(contractToWallet[pair] == address(0), "Contract already exist");
        ContractSlave(payable(pair)).initialize(
            _user,
            address(token),
            minerContract
        );
        allcontracts.push(Contract(_user, pair));
        walletToContract[_user] = pair;
        // users[_user].constractSlave = pair;
        contractToWallet[pair] = _user;
        emit CreateWallet(_user, pair, allcontracts.length);
    }

    function invest(
        address ref,
        uint256 amount
    ) external override {
        address _user = msg.sender;
        if (walletToContract[_user] == address(0)) {
            deploy(_user);
        }
        User storage user = users[_user];
        if(user.user == address(0)) {
            user.user = _user;
        }
        user.totalInvested += amount;
        uint newInvestLevel = user.totalInvested / INVEST_LEVEL_THRESHOLD;
        if (newInvestLevel > user.currentRewardLevel) {
            uint trueLevel = newInvestLevel - user.currentRewardLevel;
            user.currentRewardLevel = newInvestLevel;
            user.lastInvestDate = block.timestamp;
            for(uint i=0; i < trueLevel; i++) {
                bonuses[_user].push(Bonus(REWARDS_BY_TYPE[0], 0, 0, block.timestamp, 0, block.timestamp + REWARDS_BY_TYPE_INTERVAL[0], bonuses[_user].length, 0));
            }
        }
        address _contract = walletToContract[_user];
        token.transferFrom(msg.sender, _contract, amount);
        ContractSlave(payable(_contract)).buy(ref,amount);
    }

    function sell() external isDeployed {
        ContractSlave(payable(walletToContract[msg.sender])).sell();
    }

    function reInvest() external isDeployed {
        ContractSlave(payable(walletToContract[msg.sender])).reInvest();
    }

    function buyWhiteList() external {
        address _contract = walletToContract[msg.sender];
        require(_contract != address(0), "Contract not deployed");
        uint256 amount = contractsLibrary.getBusdToBNBToToken(
            address(token),
            priceWhiteList
        );
        token.transferFrom(msg.sender, _contract, amount);
        ContractSlave(payable(_contract)).buyWhiteList();
    }

    function buySecure() external {
        address _contract = walletToContract[msg.sender];
        require(_contract != address(0), "Contract not deployed");
        uint256 amount = contractsLibrary.getBusdToBNBToToken(
            address(token),
            IbnbBeatsV4(minerContract).priceSecure()
        );
        token.transferFrom(msg.sender, _contract, amount);
        ContractSlave(payable(_contract)).buySecure();
    }

    function withdraw() external isDeployed {
        ContractSlave(payable(walletToContract[msg.sender])).withdraw();
    }

    function getUserBalance(address wallet) external view returns (uint256) {
        if (walletToContract[wallet] == address(0)) {
            return 0;
        }
        return ContractSlave(payable(walletToContract[wallet])).getBalance();
    }

    function computeAddressBacth(
        bytes32[] calldata salts
    ) external view returns (address[] memory) {
        address[] memory addresses = new address[](salts.length);
        for (uint256 i = 0; i < salts.length; i++) {
            addresses[i] = computeAddress(salts[i]);
        }
        return addresses;
    }

    function computeAddress(bytes32 salt) public view returns (address) {
        return Create2.computeAddress(salt, getBytecodeHash());
    }

    /**
     * @dev Returns the address where a contract will be stored if deployed via {deploy}. Any change in the
     * `bytecodeHash` or `salt` will result in a new destination address.
     */
    function computeAddressV2(
        bytes32 salt,
        bytes32 bytecodeHash
    ) external view returns (address) {
        return Create2.computeAddress(salt, bytecodeHash);
    }

    /**
     * @dev Returns the address where a contract will be stored if deployed via {deploy} from a contract located at
     * `deployer`. If `deployer` is this contract's address, returns the same value as {computeAddress}.
     */
    function computeAddressV3(
        bytes32 salt,
        bytes32 bytecodeHash,
        address deployer
    ) public pure returns (address) {
        return Create2.computeAddress(salt, bytecodeHash, deployer);
    }

    function computeAddressByAddress(
        address wallet
    ) external view returns (address) {
        return computeAddress(computerSalt(wallet));
    }

    function getBytecode() public pure returns (bytes memory) {
        return type(ContractSlave).creationCode;
    }

    function getBytecodeHash() public pure returns (bytes32) {
        bytes32 bytecodeHash = keccak256(getBytecode());
        return bytecodeHash;
    }

    function contractsArray() external view returns (Contract[] memory) {
        return allcontracts;
    }

    function getBalance() external view returns (uint) {
        return address(this).balance;
    }

    function getContractSlaveBalanceBatchByAddress(
        address _token,
        address[] calldata _address
    ) external view returns (uint[] memory) {
        uint[] memory balances = new uint[](_address.length);
        for (uint i = 0; i < _address.length; i++) {
            if (_address[i] != address(0)) {
                if (_token == address(0)) {
                    balances[i] = address(_address[i]).balance;
                } else {
                    balances[i] = IERC20(_token).balanceOf(_address[i]);
                }
            }
        }
        return balances;
    }

    receive() external payable {}

    fallback() external payable {}

    function getHashByCode(string calldata _code) external pure returns (bytes32) {
        return keccak256(abi.encodePacked(_code));
    }

    function getDaTe() external view override returns (uint) {
        return block.timestamp;
    }

    function getReward(address _user, uint _index) public view returns(uint _toWihdraw, bool _canWithdraw, uint _level) {
        // User memory user = users[_user];
        Bonus memory bonus = bonuses[_user][_index];
        uint reward = 0;
        if(bonus.date + REWARDS_BY_TYPE_INTERVAL[2] < block.timestamp) {
            reward = REWARDS_BY_TYPE[2];
            _level = 3;
        } else if(bonus.date + REWARDS_BY_TYPE_INTERVAL[1] < block.timestamp) {
            reward = REWARDS_BY_TYPE[1];
            _level = 2;
        } else if(bonus.date + REWARDS_BY_TYPE_INTERVAL[0] < block.timestamp) {
            reward = REWARDS_BY_TYPE[0];
            _level = 1;
        } else {
            return (bonus.amount, false, 0);
        }
        // if(user.currentRewardLevel > user.lastRewardLevel) {
        //     uint trueLevel = user.currentRewardLevel - user.lastRewardLevel;
        //     uint multiplier = 0;
        //     if(trueLevel > 1) {
        //         multiplier = trueLevel - 1;
        //     }
        //     return reward + (REWARDS_BY_TYPE[0] * trueLevel);
        // }
        return (reward, true, _level);
    }

    // function getUserRewardData(address _user) external view override returns (User memory user, uint _toWithdraw, uint _trueLevel, uint[3] memory _withdrawDate, uint[3] memory _withdrawInterval) {
    //     user = users[_user];
    //     _toWithdraw = getReward(_user);
    //     if(user.currentRewardLevel > user.lastRewardLevel) {
    //         _trueLevel = user.currentRewardLevel - user.lastRewardLevel;
    //     }
    //     _withdrawDate[0] = user.lastInvestDate + REWARDS_BY_TYPE_INTERVAL[0];
    //     _withdrawDate[1] = user.lastInvestDate + REWARDS_BY_TYPE_INTERVAL[1];
    //     _withdrawDate[2] = user.lastInvestDate + REWARDS_BY_TYPE_INTERVAL[2];
    //     if(block.timestamp > _withdrawDate[0]) {
    //         _withdrawInterval[0] = 0;
    //     } else {
    //         _withdrawInterval[0] = _withdrawDate[0] - block.timestamp;
    //     }
    //     if(block.timestamp > _withdrawDate[1]) {
    //         _withdrawInterval[1] = 0;
    //     } else {
    //         _withdrawInterval[1] = _withdrawDate[1] - block.timestamp;
    //     }
    //     if(block.timestamp > _withdrawDate[2]) {
    //         _withdrawInterval[2] = 0;
    //     } else {
    //         _withdrawInterval[2] = _withdrawDate[2] - block.timestamp;
    //     }
    // }

    function withdrawReward(uint _bonusId) external {
        User storage user = users[msg.sender];
        Bonus storage bonus = bonuses[msg.sender][_bonusId];
        (uint reward, bool _canWithdraw, uint _level) = getReward(msg.sender, _bonusId);
        require(reward > 0, "No reward");
        require(_canWithdraw, "Can't withdraw yet");
        uint rewardInTokens = contractsLibrary.getBusdToBNBToToken(address(token), reward);
        require(rewardInTokens <= token.balanceOf(address(vault)), "Not enough vault balance");
        vault.safeTransfer(token, address(this), rewardInTokens);
        swapTokensToBnb(rewardInTokens);
        uint rewardInBnb = address(this).balance;
        require(rewardInBnb > 0, "No reward bnb");
        // user.lastRewardLevel = user.currentRewardLevel;
        require(bonus.totalWithdrawn == 0, "Already withdrawn");
        user.totalRewardWithdrawn += reward;
        user.lastWithdrawDate = block.timestamp;
        bonus.totalWithdrawn += reward;
        bonus.totalWithdrawBnb += rewardInBnb;
        bonus.withdrawDate = block.timestamp;
        bonus.levelReward = _level;
        bonus.amount = reward;
        payable(msg.sender).transfer(rewardInBnb);
    }

    function swapTokensToBnb(uint _amount) internal {
        address[] memory path = new address[](2);
        path[0] = address(token);
        path[1] = contractsLibrary.WBNB();
        token.approve(address(contractsLibrary.ROUTER()), _amount);
        IUniswapV2Router02 ROUTER = IUniswapV2Router02(address(contractsLibrary.ROUTER()));
        ROUTER.swapExactTokensForETHSupportingFeeOnTransferTokens(
            _amount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "../binary/IbnbBeatsV4.sol";

contract ContractSlave {
    address public owner;
    address public contractMaster;
    address public tokenAddress;
    address public minerContract;

    modifier isNotInitialized() {
        require(
            contractMaster == address(0),
            "Contract is already initialized"
        );
        _;
    }

    function initialize(
        address _owner,
        address _tokenAddress,
        address _minerContract
    ) public isNotInitialized {
        contractMaster = msg.sender;
        owner = _owner;
        tokenAddress = _tokenAddress;
        minerContract = _minerContract;
        payable(owner).transfer(address(this).balance);
        IERC20(tokenAddress).transfer(
            owner,
            IERC20(tokenAddress).balanceOf(address(this))
        );
    }

    modifier onlyOwner() {
        require(
            msg.sender == contractMaster,
            "Only owner can call this function"
        );
        _;
    }

    function buy(address ref, uint256 amount) external onlyOwner {
        IERC20(tokenAddress).approve(minerContract, amount);
        IbnbBeatsV4(minerContract).buy(ref, amount);
        IERC20(tokenAddress).transfer(
            owner,
            IERC20(tokenAddress).balanceOf(address(this))
        );
    }

    function sell() external onlyOwner {
        IbnbBeatsV4(minerContract).sell();
        IERC20(tokenAddress).transfer(
            owner,
            IERC20(tokenAddress).balanceOf(address(this))
        );
    }

    function reInvest() external onlyOwner {
        IbnbBeatsV4(minerContract).reInvest();
        IERC20(tokenAddress).transfer(
            owner,
            IERC20(tokenAddress).balanceOf(address(this))
        );
    }

    function buyWhiteList() external payable onlyOwner {
        IERC20(tokenAddress).approve(
            minerContract,
            IERC20(tokenAddress).balanceOf(address(this))
        );
        IbnbBeatsV4(minerContract).buyWhiteList();
        IERC20(tokenAddress).transfer(
            owner,
            IERC20(tokenAddress).balanceOf(address(this))
        );
    }

    function buySecure() external payable onlyOwner {
        IERC20(tokenAddress).approve(
            minerContract,
            IERC20(tokenAddress).balanceOf(address(this))
        );
        IbnbBeatsV4(minerContract).buySecure();
        IERC20(tokenAddress).transfer(
            owner,
            IERC20(tokenAddress).balanceOf(address(this))
        );
    }

    function withdraw() external onlyOwner {
        payable(owner).transfer(address(this).balance);
        IERC20(tokenAddress).transfer(
            owner,
            IERC20(tokenAddress).balanceOf(address(this))
        );
    }

    function getBalance() public view returns (uint) {
        return IERC20(tokenAddress).balanceOf(address(this));
    }

    receive() external payable {}

    fallback() external payable {}
}
