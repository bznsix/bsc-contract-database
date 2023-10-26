// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

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
        // Position is the index of the value in the `values` array plus 1.
        // Position 0 is used to mean a value is not in the set.
        mapping(bytes32 value => uint256) _positions;
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
            set._positions[value] = set._values.length;
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
        // We cache the value's position to prevent multiple reads from the same storage slot
        uint256 position = set._positions[value];

        if (position != 0) {
            // Equivalent to contains(set, value)
            // To delete an element from the _values array in O(1), we swap the element to delete with the last one in
            // the array, and then remove the last element (sometimes called as 'swap and pop').
            // This modifies the order of the array, as noted in {at}.

            uint256 valueIndex = position - 1;
            uint256 lastIndex = set._values.length - 1;

            if (valueIndex != lastIndex) {
                bytes32 lastValue = set._values[lastIndex];

                // Move the lastValue to the index where the value to delete is
                set._values[valueIndex] = lastValue;
                // Update the tracked position of the lastValue (that was just moved)
                set._positions[lastValue] = position;
            }

            // Delete the slot where the moved value was stored
            set._values.pop();

            // Delete the tracked position for the deleted slot
            delete set._positions[value];

            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function _contains(Set storage set, bytes32 value) private view returns (bool) {
        return set._positions[value] != 0;
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

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev The ETH balance of the account is not enough to perform the operation.
     */
    error AddressInsufficientBalance(address account);

    /**
     * @dev There's no code at `target` (it is not a contract).
     */
    error AddressEmptyCode(address target);

    /**
     * @dev A call to an address target failed. The target may have reverted.
     */
    error FailedInnerCall();

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://consensys.net/diligence/blog/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.8.20/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        if (address(this).balance < amount) {
            revert AddressInsufficientBalance(address(this));
        }

        (bool success, ) = recipient.call{value: amount}("");
        if (!success) {
            revert FailedInnerCall();
        }
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason or custom error, it is bubbled
     * up by this function (like regular Solidity function calls). However, if
     * the call reverted with no returned reason, this function reverts with a
     * {FailedInnerCall} error.
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     */
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        if (address(this).balance < value) {
            revert AddressInsufficientBalance(address(this));
        }
        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResultFromTarget(target, success, returndata);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResultFromTarget(target, success, returndata);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResultFromTarget(target, success, returndata);
    }

    /**
     * @dev Tool to verify that a low level call to smart-contract was successful, and reverts if the target
     * was not a contract or bubbling up the revert reason (falling back to {FailedInnerCall}) in case of an
     * unsuccessful call.
     */
    function verifyCallResultFromTarget(
        address target,
        bool success,
        bytes memory returndata
    ) internal view returns (bytes memory) {
        if (!success) {
            _revert(returndata);
        } else {
            // only check if target is a contract if the call was successful and the return data is empty
            // otherwise we already know that it was a contract
            if (returndata.length == 0 && target.code.length == 0) {
                revert AddressEmptyCode(target);
            }
            return returndata;
        }
    }

    /**
     * @dev Tool to verify that a low level call was successful, and reverts if it wasn't, either by bubbling the
     * revert reason or with a default {FailedInnerCall} error.
     */
    function verifyCallResult(bool success, bytes memory returndata) internal pure returns (bytes memory) {
        if (!success) {
            _revert(returndata);
        } else {
            return returndata;
        }
    }

    /**
     * @dev Reverts with returndata if present. Otherwise reverts with {FailedInnerCall}.
     */
    function _revert(bytes memory returndata) private pure {
        // Look for revert reason and bubble it up if present
        if (returndata.length > 0) {
            // The easiest way to bubble the revert reason is using memory via assembly
            /// @solidity memory-safe-assembly
            assembly {
                let returndata_size := mload(returndata)
                revert(add(32, returndata), returndata_size)
            }
        } else {
            revert FailedInnerCall();
        }
    }
}

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

/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 */
interface IERC20Metadata is IERC20 {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
}

/**
 * @dev Interface of the ERC20 Permit extension allowing approvals to be made via signatures, as defined in
 * https://eips.ethereum.org/EIPS/eip-2612[EIP-2612].
 *
 * Adds the {permit} method, which can be used to change an account's ERC20 allowance (see {IERC20-allowance}) by
 * presenting a message signed by the account. By not relying on {IERC20-approve}, the token holder account doesn't
 * need to send a transaction, and thus is not required to hold Ether at all.
 *
 * ==== Security Considerations
 *
 * There are two important considerations concerning the use of `permit`. The first is that a valid permit signature
 * expresses an allowance, and it should not be assumed to convey additional meaning. In particular, it should not be
 * considered as an intention to spend the allowance in any specific way. The second is that because permits have
 * built-in replay protection and can be submitted by anyone, they can be frontrun. A protocol that uses permits should
 * take this into consideration and allow a `permit` call to fail. Combining these two aspects, a pattern that may be
 * generally recommended is:
 *
 * ```solidity
 * function doThingWithPermit(..., uint256 value, uint256 deadline, uint8 v, bytes32 r, bytes32 s) public {
 *     try token.permit(msg.sender, address(this), value, deadline, v, r, s) {} catch {}
 *     doThing(..., value);
 * }
 *
 * function doThing(..., uint256 value) public {
 *     token.safeTransferFrom(msg.sender, address(this), value);
 *     ...
 * }
 * ```
 *
 * Observe that: 1) `msg.sender` is used as the owner, leaving no ambiguity as to the signer intent, and 2) the use of
 * `try/catch` allows the permit to fail and makes the code tolerant to frontrunning. (See also
 * {SafeERC20-safeTransferFrom}).
 *
 * Additionally, note that smart contract wallets (such as Argent or Safe) are not able to produce permit signatures, so
 * contracts should have entry points that don't rely on permit.
 */
interface IERC20Permit {
    /**
     * @dev Sets `value` as the allowance of `spender` over ``owner``'s tokens,
     * given ``owner``'s signed approval.
     *
     * IMPORTANT: The same issues {IERC20-approve} has related to transaction
     * ordering also apply here.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `deadline` must be a timestamp in the future.
     * - `v`, `r` and `s` must be a valid `secp256k1` signature from `owner`
     * over the EIP712-formatted function arguments.
     * - the signature must use ``owner``'s current nonce (see {nonces}).
     *
     * For more information on the signature format, see the
     * https://eips.ethereum.org/EIPS/eip-2612#specification[relevant EIP
     * section].
     *
     * CAUTION: See Security Considerations above.
     */
    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    /**
     * @dev Returns the current nonce for `owner`. This value must be
     * included whenever a signature is generated for {permit}.
     *
     * Every successful call to {permit} increases ``owner``'s nonce by one. This
     * prevents a signature from being used multiple times.
     */
    function nonces(address owner) external view returns (uint256);

    /**
     * @dev Returns the domain separator used in the encoding of the signature for {permit}, as defined by {EIP712}.
     */
    // solhint-disable-next-line func-name-mixedcase
    function DOMAIN_SEPARATOR() external view returns (bytes32);
}

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    using Address for address;

    /**
     * @dev An operation with an ERC20 token failed.
     */
    error SafeERC20FailedOperation(address token);

    /**
     * @dev Indicates a failed `decreaseAllowance` request.
     */
    error SafeERC20FailedDecreaseAllowance(address spender, uint256 currentAllowance, uint256 requestedDecrease);

    /**
     * @dev Transfer `value` amount of `token` from the calling contract to `to`. If `token` returns no value,
     * non-reverting calls are assumed to be successful.
     */
    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeCall(token.transfer, (to, value)));
    }

    /**
     * @dev Transfer `value` amount of `token` from `from` to `to`, spending the approval given by `from` to the
     * calling contract. If `token` returns no value, non-reverting calls are assumed to be successful.
     */
    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeCall(token.transferFrom, (from, to, value)));
    }

    /**
     * @dev Increase the calling contract's allowance toward `spender` by `value`. If `token` returns no value,
     * non-reverting calls are assumed to be successful.
     */
    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 oldAllowance = token.allowance(address(this), spender);
        forceApprove(token, spender, oldAllowance + value);
    }

    /**
     * @dev Decrease the calling contract's allowance toward `spender` by `requestedDecrease`. If `token` returns no
     * value, non-reverting calls are assumed to be successful.
     */
    function safeDecreaseAllowance(IERC20 token, address spender, uint256 requestedDecrease) internal {
        unchecked {
            uint256 currentAllowance = token.allowance(address(this), spender);
            if (currentAllowance < requestedDecrease) {
                revert SafeERC20FailedDecreaseAllowance(spender, currentAllowance, requestedDecrease);
            }
            forceApprove(token, spender, currentAllowance - requestedDecrease);
        }
    }

    /**
     * @dev Set the calling contract's allowance toward `spender` to `value`. If `token` returns no value,
     * non-reverting calls are assumed to be successful. Meant to be used with tokens that require the approval
     * to be set to zero before setting it to a non-zero value, such as USDT.
     */
    function forceApprove(IERC20 token, address spender, uint256 value) internal {
        bytes memory approvalCall = abi.encodeCall(token.approve, (spender, value));

        if (!_callOptionalReturnBool(token, approvalCall)) {
            _callOptionalReturn(token, abi.encodeCall(token.approve, (spender, 0)));
            _callOptionalReturn(token, approvalCall);
        }
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address-functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data);
        if (returndata.length != 0 && !abi.decode(returndata, (bool))) {
            revert SafeERC20FailedOperation(address(token));
        }
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     *
     * This is a variant of {_callOptionalReturn} that silents catches all reverts and returns a bool instead.
     */
    function _callOptionalReturnBool(IERC20 token, bytes memory data) private returns (bool) {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We cannot use {Address-functionCall} here since this should return false
        // and not revert is the subcall reverts.

        (bool success, bytes memory returndata) = address(token).call(data);
        return success && (returndata.length == 0 || abi.decode(returndata, (bool))) && address(token).code.length > 0;
    }
}

contract SFilFarmTestContract is Ownable {
    using SafeMath for uint256;
    using SafeERC20 for IERC20Metadata;
    using EnumerableSet for EnumerableSet.AddressSet;

    struct UserInfo {
        uint256 depositAmount; 
        uint256 mintAmount;
        DepositRecord[] depositRecord;
    }

    struct DepositRecord {
        uint256 depositTime;
        uint256 lockDuration;
        uint8 computingPower;
        uint256 amount;
        uint256 claimedMintReward;
        uint256 accMintingTokenPerShare;
        bool active;
    }

    struct Package {
        uint256 lockTime;
        uint8 computingPower;
    }

    struct Referral {
        address superiorsAddress;
        EnumerableSet.AddressSet primaryAddress;
        EnumerableSet.AddressSet subordinateAddress; 
    }

    uint256 public accMintingTokenPerShare; 
    uint256 public lastUpdateTime;

    uint256 public avgMiningRewardSharePerSec;
    uint256 public minimumThreshold;
    uint256 public maximumThreshold;
    address public depositToken;
    address public rewardToken;
    address public feeToken;
    bool public emergencyWithdrawSwitch;
    uint256 public totalDepositedAmount;
	uint256 public minDepositAmt;    
	uint256 public maxDepositAmt;
    uint256 public primaryRefferralRewardRate;
    uint256 public secondaryRefferralRewardRate;
    uint256 public redemptionFeeRate;
    uint256 public denominator;
    bool public start;
    address public defaultReferrer; 

    mapping(address => UserInfo) public userInfo;
    mapping(address => uint256) public totalMintedAmount;
    mapping(uint8 => bool) public packageExist;
    mapping(uint8 => Package) public packages;
    mapping(address => Referral) private userReferralInfo;
    mapping(address => uint256) public computedPrimaryAddrMintedAmount;
    mapping(address => uint256) public computedSecondaryAddrMintedAmount;
    mapping(address => uint256) public userClaimedRefferalReward;
    EnumerableSet.AddressSet private depositAddresses;
    EnumerableSet.AddressSet private blacklistUsers;
    EnumerableSet.AddressSet private historicalUsers;

    event Deposit(address indexed user, uint256 amount);
    event Claim(address indexed user, uint256 amount);
    event Withdraw(address indexed user, uint256 amount);
    event EmergencyWithdraw(address indexed user, uint256 amount);
    
    constructor(address initialOwner) Ownable(initialOwner) {
        lastUpdateTime = block.timestamp;
        avgMiningRewardSharePerSec = 752314815;
        minimumThreshold = 100 * 10 ** 18;
        maximumThreshold = 10000 * 10 ** 18;
        setDepositToken(0x388F8Ba05ce519E1330d2eC226eb1faB2140D989);
        setRewardToken(0x0D8Ce2A99Bb6e3B7Db580eD848240e4a0F9aE153);
        setFeeToken(0x388F8Ba05ce519E1330d2eC226eb1faB2140D989);
        setDefaultReferrer(0xFc8cf1f21ab189B46c12CDFE0B2b91105F18e8a6);
        packageExist[1] = true;
        packageExist[2] = true;
        packageExist[3] = true;
        packages[1].lockTime = 86400 * 7;
        packages[1].computingPower = 1;
        packages[2].lockTime = 86400 * 15;
        packages[2].computingPower = 2;
        packages[3].lockTime = 86400 * 30;
        packages[3].computingPower = 3;
        primaryRefferralRewardRate = 300;
        secondaryRefferralRewardRate = 200;
        redemptionFeeRate = 200;
        denominator = 10000;
    }

    function getInterval(uint256 _from, uint256 _to) internal pure returns (uint256) {
        if(_to > _from) {
            return _to.sub(_from);
        } else {
            return 0;
        }
    }

    function pendingMintingReward(address _user) public view returns (uint256 totalPending) {
        UserInfo storage user = userInfo[_user];
        uint256 currentAccMintingTokenPerShare = accMintingTokenPerShare;
        uint256 tokenBalance = IERC20Metadata(depositToken).balanceOf(address(this));
        if (block.timestamp > lastUpdateTime && tokenBalance != 0) {
            uint256 interval = getInterval(lastUpdateTime, block.timestamp);
            uint256 miningReward = interval.mul(avgMiningRewardSharePerSec);
            currentAccMintingTokenPerShare = accMintingTokenPerShare.add(miningReward);
        }
        for (uint256 i = 0; i < user.depositRecord.length; i++) {
            if( user.depositRecord[i].active) {
                uint256 actualAccMintingTokenPerShare = currentAccMintingTokenPerShare.sub(user.depositRecord[i].accMintingTokenPerShare);
                uint256 deservedMintingReward = user.depositRecord[i].amount.mul(actualAccMintingTokenPerShare).mul(user.depositRecord[i].computingPower);
                uint256 pending = deservedMintingReward.div(1 * 10 ** IERC20Metadata(depositToken).decimals()).sub(user.depositRecord[i].claimedMintReward);
                totalPending = totalPending.add(pending);
            }
        }
        return totalPending;
    }

    function update() public {
        if (block.timestamp <= lastUpdateTime) {
            return;
        }
        uint256 tokenBalance = IERC20Metadata(depositToken).balanceOf(address(this));
        if (tokenBalance == 0) {
            lastUpdateTime = block.timestamp;
            return;
        }
        uint256 Interval = getInterval(lastUpdateTime, block.timestamp);
        uint256 miningReward = Interval.mul(avgMiningRewardSharePerSec);
        accMintingTokenPerShare = accMintingTokenPerShare.add(miningReward);
        lastUpdateTime = block.timestamp;
    }

    function getUserPrimaryAddressMintedAmount(address _user) public view returns(uint256 mintedAmounts) {
        uint256 length = userReferralInfo[_user].primaryAddress.length();
        for (uint256 i = 0; i < length; i++) {
            address priAddr = userReferralInfo[_user].primaryAddress.at(i);
            uint256 mintedAmount = pendingMintingReward(priAddr).add(userInfo[priAddr].mintAmount);
            mintedAmounts = mintedAmounts.add(mintedAmount);
        }
    }

    function getUserSubordinateAddressMintedAmount(address _user) public view returns(uint256 mintedAmounts) {
        uint256 length = userReferralInfo[_user].subordinateAddress.length();
        for (uint256 i = 0; i < length; i++) {
            address subAddr = userReferralInfo[_user].subordinateAddress.at(i);
            uint256 mintedAmount = pendingMintingReward(subAddr).add(userInfo[subAddr].mintAmount);
            mintedAmounts = mintedAmounts.add(mintedAmount);
        }
    }

    function getPendingReferralReward(address _user) public view returns(uint256 primaryReferralReward, uint256 secondaryReferralReward, uint256 pendingReferralReward) {
        primaryReferralReward = getUserPrimaryAddressMintedAmount(_user).sub(computedPrimaryAddrMintedAmount[_user]);
        secondaryReferralReward = (getUserSubordinateAddressMintedAmount(_user).sub(computedSecondaryAddrMintedAmount[_user]));
        pendingReferralReward = (primaryReferralReward.mul(primaryRefferralRewardRate).div(denominator)).add((secondaryReferralReward.mul(secondaryRefferralRewardRate).div(denominator)));
    }

    function getUserTotalReferralReward(address _user) public view returns(uint256) {
        (uint256 pendingRefferalReward, ,) = getPendingReferralReward(_user);
        return pendingRefferalReward + userClaimedRefferalReward[_user];
    }

    function claimReferralReward() public {
        (uint256 primaryReferralReward,uint256 secondaryReferralReward, uint256 pendingReferralReward) = getPendingReferralReward(msg.sender);
        require(pendingReferralReward > 0, "You have no referral rewards to claim");
        computedPrimaryAddrMintedAmount[msg.sender] = computedPrimaryAddrMintedAmount[msg.sender].add(primaryReferralReward);
        computedSecondaryAddrMintedAmount[msg.sender] = computedSecondaryAddrMintedAmount[msg.sender].add(secondaryReferralReward);
        safeTokenTransfer(rewardToken, msg.sender, pendingReferralReward);
        userClaimedRefferalReward[msg.sender] += pendingReferralReward;
    }

    function deposit(address referrer, uint8 _packageNum, uint256 _amount) public {
        UserInfo storage user = userInfo[msg.sender];
        require(start, "The contract hasn't started yet");
        require(IERC20Metadata(depositToken).balanceOf(msg.sender) >= _amount, "Your token balance is less than the amount entered");
        require(_amount >= minimumThreshold, "The amount you deposited does not reach the minimum threshold");
        require(_amount <= maximumThreshold, "The amount you pledged has exceeded the maximum threshold");
        require(packageExist[_packageNum], "The package you selected does not exist");
        require(!blacklistUsers.contains(msg.sender), "you are on blacklist");
        update();
        if (referrer != address(0)) {
            address primaryReferrer = userReferralInfo[msg.sender].superiorsAddress;
            if (primaryReferrer != address(0)) {
                require(primaryReferrer == referrer, "You have already bound");
            } else {
                if(referrer != defaultReferrer) {
                    require(referrer != msg.sender, "The recommender cannot be yourself");
                    require(!userReferralInfo[msg.sender].primaryAddress.contains(referrer), "Cannot bind lower-level addresses");
                    require(!userReferralInfo[msg.sender].subordinateAddress.contains(referrer), "Cannot bind lower-level addresses");
                    require(userInfo[referrer].depositAmount > 0, "The recommender has no pledge");
                    userReferralInfo[msg.sender].superiorsAddress = referrer;
                    if(!userReferralInfo[referrer].primaryAddress.contains(msg.sender)) {
                        userReferralInfo[referrer].primaryAddress.add(msg.sender);
                    }
                } else {
                    userReferralInfo[msg.sender].superiorsAddress = defaultReferrer;
                    if(!userReferralInfo[defaultReferrer].primaryAddress.contains(msg.sender)) {
                        userReferralInfo[defaultReferrer].primaryAddress.add(msg.sender);
                    }
                }
                address secondaryReferrer = userReferralInfo[referrer].superiorsAddress;
                if(secondaryReferrer != address(0)) {
                    if(!userReferralInfo[secondaryReferrer].subordinateAddress.contains(msg.sender)) {
                        userReferralInfo[secondaryReferrer].subordinateAddress.add(msg.sender);
                    }
                }
            }
        } else {
            require(referrer != address(0), "you are not invited");
        }
        IERC20Metadata(depositToken).safeTransferFrom(address(msg.sender), address(this), _amount);
        user.depositRecord.push(DepositRecord({
            depositTime: block.timestamp,
            lockDuration: packages[_packageNum].lockTime,
            computingPower: packages[_packageNum].computingPower,
            amount: _amount,
            claimedMintReward: 0,
            accMintingTokenPerShare: accMintingTokenPerShare,
            active: true
        }));
        user.depositAmount = user.depositAmount.add(_amount);
        totalDepositedAmount = totalDepositedAmount.add(_amount);
        if(historicalUsers.length() == 0) {
            minDepositAmt = _amount;
        } else {
            if(_amount < minDepositAmt) {
                minDepositAmt = _amount;
            }
        }
        if(_amount > maxDepositAmt) {
            maxDepositAmt = _amount;
        }
        if(!depositAddresses.contains(msg.sender)) {
            depositAddresses.add(msg.sender);
        }
        if(!historicalUsers.contains(msg.sender)) {
            historicalUsers.add(msg.sender);
        }
        emit Deposit(msg.sender, _amount);
    }

    function claimMintingReward(address _user) internal returns (uint256 totalPending) {
        UserInfo storage user = userInfo[_user];
        for (uint256 i = 0; i < user.depositRecord.length; i++) {
            if(user.depositRecord[i].active) {
                uint256 actualAccMintingTokenPerShare = accMintingTokenPerShare.sub(user.depositRecord[i].accMintingTokenPerShare);
                uint256 deservedMintingReward = user.depositRecord[i].amount.mul(actualAccMintingTokenPerShare).mul(user.depositRecord[i].computingPower);
                uint256 pending = deservedMintingReward.div(1 * 10 ** IERC20Metadata(depositToken).decimals()).sub(user.depositRecord[i].claimedMintReward);
                user.depositRecord[i].claimedMintReward = user.depositRecord[i].claimedMintReward.add(pending);
                totalPending = totalPending.add(pending);
            }
        }
        return totalPending;
    }

    function claim() public {
        UserInfo storage user = userInfo[msg.sender];
        require(user.depositAmount > 0,"You have not deposited any lp");
        require(pendingMintingReward(msg.sender) > 0, "You have no reward minting tokens to claim");
        require(IERC20Metadata(rewardToken).balanceOf(address(this)) >= pendingMintingReward(msg.sender), "The minting token balance of this contract is insufficient"); 
        update();
        uint256 deservedMiningReward = claimMintingReward(msg.sender);
        user.mintAmount = user.mintAmount.add(deservedMiningReward);
        totalMintedAmount[msg.sender] = totalMintedAmount[msg.sender].add(deservedMiningReward);
        safeTokenTransfer(rewardToken, msg.sender, deservedMiningReward);
        emit Claim(msg.sender, deservedMiningReward);
    }

    function withdraw() public {
        UserInfo storage user = userInfo[msg.sender];
        require(user.depositAmount > 0,"You have not deposited any lp");
        require(!blacklistUsers.contains(msg.sender), "You are on blacklist");
        uint256 deservedRedeemableAmount = getTotalRedeemableAmount(msg.sender);
        uint256 redemptionFeeAmount = deservedRedeemableAmount.mul(redemptionFeeRate).div(denominator);
        uint256 redeemableAmount = deservedRedeemableAmount.sub(redemptionFeeAmount);
        require(redeemableAmount > 0, "You have nothing to redeem");
        update();
        if(pendingMintingReward(msg.sender) > 0) {
            require(IERC20Metadata(rewardToken).balanceOf(address(this)) >= pendingMintingReward(msg.sender), "The minting token balance of this contract is insufficient"); 
            uint256 deservedMiningReward = claimMintingReward(msg.sender);
            user.mintAmount = user.mintAmount.add(deservedMiningReward);
            totalMintedAmount[msg.sender] = totalMintedAmount[msg.sender].add(deservedMiningReward);
            safeTokenTransfer(rewardToken, msg.sender, deservedMiningReward);
            emit Claim(msg.sender, deservedMiningReward);
        }
        IERC20Metadata(depositToken).safeTransfer(address(msg.sender), redeemableAmount);
        emit Withdraw(msg.sender, redeemableAmount);
        totalDepositedAmount = totalDepositedAmount.sub(deservedRedeemableAmount);
        user.depositAmount = user.depositAmount.sub(deservedRedeemableAmount);
        deleteWithdrawTX();
        if(user.depositAmount == 0 && depositAddresses.contains(msg.sender)) {
            depositAddresses.remove(msg.sender);
        }
    }

    function emergencyWithdraw() public  {
        UserInfo storage user = userInfo[msg.sender];
        require(emergencyWithdrawSwitch, "Management does not turn on the emergency withdrawal option");
        require(user.depositAmount > 0, "You have not deposited any lp");
        update();
        IERC20Metadata(depositToken).safeTransfer(address(msg.sender), user.depositAmount);
        emit EmergencyWithdraw(msg.sender, user.depositAmount);
        totalDepositedAmount = totalDepositedAmount.sub(user.depositAmount);
        user.depositAmount = 0;
        deleteAllWithdrawTX();
        if(depositAddresses.contains(msg.sender)) {
            depositAddresses.remove(msg.sender);
        }
    }

    function deleteWithdrawTX() private  {
        for (uint256 i = 0; i < userInfo[msg.sender].depositRecord.length; i++) {
            if (userInfo[msg.sender].depositRecord[i].active) {
                if (block.timestamp >= userInfo[msg.sender].depositRecord[i].depositTime + userInfo[msg.sender].depositRecord[i].lockDuration) {
                    userInfo[msg.sender].depositRecord[i].active = false;
                }
            }
        }
    }

    function deleteAllWithdrawTX() private  {
        for (uint256 i = 0; i < userInfo[msg.sender].depositRecord.length; i++) {
            if (userInfo[msg.sender].depositRecord[i].active) {
                userInfo[msg.sender].depositRecord[i].active = false;
            }
        }
    }

    function safeTokenTransfer(address _token, address _to, uint256 _amount) internal {
        uint256 tokenBalance = IERC20Metadata(_token).balanceOf(address(this));
        if (_amount > tokenBalance) {
            IERC20Metadata(_token).transfer(_to, tokenBalance);
        } else {
            IERC20Metadata(_token).transfer( _to, _amount);
        }
    }

    function getUserDepositInfos(address _user) public view returns(DepositRecord[] memory) {
        return userInfo[_user].depositRecord;
    }

    function getUserSuperiorsAddress(address _user) public view returns(address) {
        return userReferralInfo[_user].superiorsAddress;
    }
 
    function getUserPrimaryAddresses(address _user) public view returns(address[] memory) {
        return userReferralInfo[_user].primaryAddress.values();
    }

    function getUserPrimaryAddressesAmount(address _user) public view returns(uint256) {
        return userReferralInfo[_user].primaryAddress.length();
    }

    function getUsersubordinateAddresses(address _user) public view returns(address[] memory) {
        return userReferralInfo[_user].subordinateAddress.values();
    }

    function getUserSubordinateAddressesAmount(address _user) public view returns(uint256) {
        return userReferralInfo[_user].subordinateAddress.length();
    }

    function getAllUserMintedAmount() public view returns(uint256 allUserMintedAmount) {
        uint256 length = historicalUsers.length();
        for (uint i = 0; i < length; i++) {
            address user = historicalUsers.at(i);
            uint256 userMintedAmount = pendingMintingReward(user).add(userInfo[user].mintAmount);
            allUserMintedAmount = allUserMintedAmount.add(userMintedAmount);
        }
    }

    function getTotalRedeemableAmount(address _user) public view returns(uint256 totalRedeemableAmount) {
        for (uint256 i = 0; i < userInfo[_user].depositRecord.length; i++) {
            if (userInfo[_user].depositRecord[i].active) {
                if (block.timestamp >= userInfo[_user].depositRecord[i].depositTime + userInfo[_user].depositRecord[i].lockDuration) {
                    totalRedeemableAmount = totalRedeemableAmount + userInfo[_user].depositRecord[i].amount;
                }
            }
        }
    }

    function getTotalDepositedAmount() public view returns(uint256) {
        return totalDepositedAmount;
    }

    function getBlacklistUsers() public view returns(address[] memory) {
        return blacklistUsers.values();
    }

    function getTotalBlacklistUsersAmount() public view returns(uint256) {
        return blacklistUsers.length();
    }

    function getTotalDepositAddresses() public view returns(address[] memory) {
        return depositAddresses.values();
    }

    function getTotalDepositAddressesAmount() public view returns(uint256) {
        return depositAddresses.length();
    }

    function getTotalHistoricalUsers() public view returns(address[] memory) {
        return historicalUsers.values();
    }

    function getTotalHistoricalUsersAmount() public view returns(uint256) {
        return historicalUsers.length();
    }

    function getMinDepositAmt() public view returns(uint256) {
        return minDepositAmt;
    }

    function getMaxDepositAmt() public view returns(uint256) {
        return maxDepositAmt;
    }

    function getUserTotalDepositAmount(address _user) public view returns(uint256) {
        return userInfo[_user].depositAmount;
    }

    function getUserDirectReferralsNum(address _user) public view returns(uint256) {
        return userReferralInfo[_user].primaryAddress.length();
    }

    function getUserTeamNum(address _user) public view returns(uint256) {
        return userReferralInfo[_user].primaryAddress.length() + userReferralInfo[_user].subordinateAddress.length();
    }

    function getUserPerformance(address _user) public view returns(uint256) {
        return getUserPrimaryAddressMintedAmount(_user) + getUserSubordinateAddressMintedAmount(_user) + totalMintedAmount[_user] + pendingMintingReward(_user);
    }

    function retrieve(address _token) public onlyOwner {
        uint256 tokenBalance = IERC20Metadata(_token).balanceOf(address(this));
        safeTokenTransfer(_token, msg.sender, tokenBalance);
    }

    function setAvgMiningRewardSharePerSec(uint256 _avgMiningRewardSharePerSec) public onlyOwner {
        update();
        avgMiningRewardSharePerSec = _avgMiningRewardSharePerSec;
    }

    function setMinimumThreshold(uint256 _minimumThreshold) public onlyOwner {
        minimumThreshold = _minimumThreshold;
    }

    function setMaximumThreshold(uint256 _maximumThreshold) public onlyOwner {
        maximumThreshold = _maximumThreshold;
    }

    function setDepositToken(address _token) public onlyOwner {
        depositToken = _token;
    }

    function setRewardToken(address _token) public onlyOwner {
        rewardToken = _token;
    }

    function setFeeToken(address _token) public onlyOwner {
        feeToken = _token;
    }

    function setEmergencyWithdrawSwitch(bool _state) public onlyOwner {
        emergencyWithdrawSwitch = _state;
    }

    function addBlacklistUsers(address[] memory array) public onlyOwner {
        for (uint256 i = 0; i < array.length; i++) {
            if(!blacklistUsers.contains(array[i])) {
                blacklistUsers.add(array[i]);
            }
        }
    }

    function removeBlacklistUsers(address[] memory array) public onlyOwner {
        for (uint256 i = 0; i < array.length; i++) {
            if(blacklistUsers.contains(array[i])) {
                blacklistUsers.remove(array[i]);
            }
        }
    }

    function setPackageExistState(uint8 _index, bool _state) public onlyOwner {
        packageExist[_index] = _state;
    }

    function setPackage(uint8 _index, uint256 _lockTime, uint8 _computingPower) public onlyOwner {
        packages[_index].lockTime = _lockTime;
        packages[_index].computingPower = _computingPower;
    }

    function setPrimaryRefferralRewardRate(uint256 _primaryRefferralRewardRate) public onlyOwner {
        primaryRefferralRewardRate = _primaryRefferralRewardRate;
    }

    function setSecondaryRefferralRewardRate(uint256 _secondaryRefferralRewardRate) public onlyOwner {
        secondaryRefferralRewardRate = _secondaryRefferralRewardRate;
    }

    function setDenominator(uint256 _denominator) public onlyOwner {
        denominator = _denominator;
    }

    function setStart(bool _startStatus) public onlyOwner {
        start = _startStatus;
    }

    function setRedemptionFeeRate(uint256 _redemptionFeeRate) public onlyOwner {
        redemptionFeeRate = _redemptionFeeRate;
    }

    function setDefaultReferrer(address _defaultReferrer) public onlyOwner {
        defaultReferrer = _defaultReferrer;
    }
}