// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (token/ERC20/ERC20.sol)

pragma solidity ^0.8.0;

import "./IERC20.sol";
import "./extensions/IERC20Metadata.sol";
import "../../utils/Context.sol";

/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20PresetMinterPauser}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.openzeppelin.com/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * The default value of {decimals} is 18. To change this, you should override
 * this function so it returns a different value.
 *
 * We have followed general OpenZeppelin Contracts guidelines: functions revert
 * instead returning `false` on failure. This behavior is nonetheless
 * conventional and does not conflict with the expectations of ERC20
 * applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 *
 * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See {IERC20-approve}.
 */
contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * All two of these values are immutable: they can only be set once during
     * construction.
     */
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5.05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the default value returned by this function, unless
     * it's overridden.
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * NOTE: If `amount` is the maximum `uint256`, the allowance is not updated on
     * `transferFrom`. This is semantically equivalent to an infinite approval.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * NOTE: Does not update the allowance if the current allowance
     * is the maximum `uint256`.
     *
     * Requirements:
     *
     * - `from` and `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     * - the caller must have allowance for ``from``'s tokens of at least
     * `amount`.
     */
    function transferFrom(address from, address to, uint256 amount) public virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, allowance(owner, spender) + addedValue);
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        address owner = _msgSender();
        uint256 currentAllowance = allowance(owner, spender);
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    /**
     * @dev Moves `amount` of tokens from `from` to `to`.
     *
     * This internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     */
    function _transfer(address from, address to, uint256 amount) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
            // Overflow not possible: the sum of all balances is capped by totalSupply, and the sum is preserved by
            // decrementing then incrementing.
            _balances[to] += amount;
        }

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        unchecked {
            // Overflow not possible: balance + amount is at most totalSupply + amount, which is checked above.
            _balances[account] += amount;
        }
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
            // Overflow not possible: amount <= accountBalance <= totalSupply.
            _totalSupply -= amount;
        }

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner` s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Updates `owner` s allowance for `spender` based on spent `amount`.
     *
     * Does not update the allowance amount in case of infinite allowance.
     * Revert if not enough allowance is available.
     *
     * Might emit an {Approval} event.
     */
    function _spendAllowance(address owner, address spender, uint256 amount) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }

    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * will be transferred to `to`.
     * - when `from` is zero, `amount` tokens will be minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual {}

    /**
     * @dev Hook that is called after any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * has been transferred to `to`.
     * - when `from` is zero, `amount` tokens have been minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens have been burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(address from, address to, uint256 amount) internal virtual {}
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";

/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
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
pragma solidity ^0.8.0;

contract Consensus {

    uint confirmationsRequired = 3;
    uint constant GRASE_PERIOD = 48 hours;
    address[] public owners;
    
    struct ExecProposal{
        bytes32 uid;
        address to;
        string  func;
        bytes  data;
        uint timestamp;
        uint confirmations;
    }

    
    mapping(bytes32 => ExecProposal) public eps;
    mapping(bytes32 => bool) queue;
    mapping(bytes32 =>mapping(address =>bool)) public confirmations;
    mapping(address => bool) isOwner;

    modifier onlyOwner(){
        require(isOwner[msg.sender],"You are not the owner");
        _;
    }

    modifier onlyConsensus(){
        require(msg.sender == address(this),"Call the consensus function");
        _;
    }

    constructor(address[] memory _owners){
        require(_owners.length >= confirmationsRequired,"Minimum 3 owners");
        for (uint i; i < _owners.length; i++){
            address nextOwner = _owners[i];

            require(!isOwner[nextOwner],"duplicated owner");

            isOwner[nextOwner] = true;
            owners.push(nextOwner);

        }
        
    }

    event queueTx(
        address sender,
        address to,
        string  func,
        bytes  data,
        uint timestamp,
        bytes32 txId
    );

    event discard(bytes32 txId);

    event assignRequired(
        uint256 blockNumber,
        uint8 minConfirm
        );

    event executTx(
        address sender,
        bytes32 txId,
        uint timestamp,
        string func
    );
    //@dev Creating a transaction and adding to the queue for consideration
    function addExecProposal(
        string calldata _func,
        bytes calldata _data
    ) external  onlyOwner returns(bytes32 _txId){
        
        bytes32 txId = txToByte(_func,_data,block.timestamp);
        require(!queue[txId],"allready queue");

        queue[txId] = true;
        confirmations[txId][msg.sender] = true;
        eps[txId] = ExecProposal({
                uid : txId,
                to : address(this),
                func : _func,
                data : _data,
                timestamp : block.timestamp,
                confirmations:1
                });

        emit queueTx(
            msg.sender,
            address(this),
            _func,
            _data,
            block.timestamp,
            txId
        );
        
        return txId;
    }
    //@dev consent to send a transaction
    function confirm(bytes32 _txId) external onlyOwner {
        require(queue[_txId], "not queued!");
        require(!confirmations[_txId][msg.sender], "already confirmed!");

        ExecProposal storage execProposal = eps[_txId];

        execProposal.confirmations++;
        confirmations[_txId][msg.sender] = true;

        if (execProposal.confirmations >= confirmationsRequired){
            execute(_txId);
        }
    }

    //@dev Cancellation of voting on a specific deal
    function cancelConfirmation(bytes32 _txId) external onlyOwner {
        require(confirmations[_txId][msg.sender], "not confirmed!");

        ExecProposal storage execProposal = eps[_txId];
        execProposal.confirmations--;
        confirmations[_txId][msg.sender] = false;

        if(execProposal.confirmations == 0){
            discardExecProposal(_txId);
        }
    }
    //@dev deleted a transaction
    function discardExecProposal(bytes32 _txId) private {
        require(queue[_txId], "not queued");
        
        delete queue[_txId];
        delete eps[_txId];
        for (uint i; i < owners.length;i++){
            confirmations[_txId][owners[i]] = false;
        }

        emit discard(_txId);
    }

    //@dev sending a transaction
    function execute(bytes32 txId) private {
        ExecProposal storage execProposal = eps[txId];

        require(queue[txId], "not queued");
        require(execProposal.timestamp + GRASE_PERIOD > block.timestamp, "Grace period failed");
        require(block.timestamp > execProposal.timestamp, "Error timestamp");
        
        require(
            execProposal.confirmations >= confirmationsRequired,
            "not enough confirmations "
            );

        delete queue[txId];
        

        bytes memory data;
        data = abi.encodePacked(
                    bytes4(keccak256(bytes(execProposal.func))),
                    execProposal.data
        );

        (bool success, ) = address(this).call{value:0}(data);
        
        require(success,"tx error");
        
        emit executTx(msg.sender,txId,execProposal.timestamp,execProposal.func);

        delete eps[txId];

    }

    function txToByte(
        string calldata _func,
        bytes calldata _data,
        uint _timestamp
    ) internal view returns (bytes32 _txId){

        bytes32 txId = keccak256(abi.encode(
            address(this),
            _func,
            _data,
            _timestamp
        ));
        return txId;
    }

    function addOwner(address newOwner) public onlyConsensus{
        require(newOwner != address(0), "Error zero address");
        isOwner[newOwner] = true;
        owners.push(newOwner);
    }

    function delOwner(uint indexOwner) public onlyConsensus {
        uint ownerLength = owners.length;
        require(indexOwner <= ownerLength, "Node index cannot be higher than their number"); // index must be less than or equal to array length
        require(ownerLength -1  >= confirmationsRequired, "error minimal count owner");

        for (uint i = indexOwner; i < ownerLength -1; i++){
            owners[i] = owners[i+1];
        }
        isOwner[owners[indexOwner]] = false;
        delete owners[ownerLength-1];
        owners.pop();
    }

    function assignRequiredConf(uint8 _confReq) public onlyConsensus{
        require(owners.length >= _confReq, "error owners.length < _confReq");
        require(_confReq >= 2, "Minimal confRequire 2");
        
        confirmationsRequired = _confReq;
        emit assignRequired(block.number,_confReq);
    }

    function seeOwners() external view returns(address[] memory){
        return owners;
    }

    function seeMinCofReq() public view returns(uint){
        return confirmationsRequired;
    }


}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "./Consensus.sol";
import "./Vesting.sol";

contract Nodesys is ERC20, Consensus {
                                           
    using EnumerableSet for EnumerableSet.AddressSet;

    EnumerableSet.AddressSet private vestings;

    mapping(address => mapping(address => uint)) private amountLockUser;
    mapping(address => EnumerableSet.AddressSet) internal vestingUsers;

    error needToken(uint256 vestingAmount, uint256 amountGeneral);

    event addVesting(address indexed user, address indexed vesting, uint256 amountLock);
    event except(address indexed from,address indexed to, address vetingFrom, address vestingTo, uint256 amountLockedFrom, uint256 amountLockedTo);

    constructor(address[] memory _owners) ERC20("node.sys", "NYS") Consensus(_owners){
        //_mint(msg.sender,15000000000000000000000000);
    }

    function addAddressToVesting(address[] memory users, uint256[] memory amounts) external onlyConsensus{
        uint256 usersLen = users.length;
        require(usersLen == amounts.length,"The array sizes must be the same");
        Vesting vesting = new Vesting(address(this));
        address vestingAddr = address(vesting);
        
        for(uint i; i < usersLen; i++){

            address user = users[i];
            uint amount = amounts[i];

            vesting.addAddress(address(0), user, amount);
            vestingUsers[user].add(vestingAddr);

            emit addVesting(user, vestingAddr, amount);
        }
        vestings.add(vestingAddr);
    }

    function unlockUsers(address vestingAddr,uint8 percentage) external onlyOwner{
        require(checVestingAddr(vestingAddr),"Such a vesting address does not exist");
        Vesting(vestingAddr).assignRandomAddresses(percentage);
    }

    function unlockAllUsers(address vestingAddr) external onlyOwner{
        require(checVestingAddr(vestingAddr),"Such a vesting address does not exist");
        Vesting(vestingAddr).unlockAll();
    }

    function mint(address to, uint256 amount) external onlyConsensus {
        _mint(to, amount);
    }

    function addException(address _vestingAddr, address _user) external onlyOwner{
        require(_vestingAddr != address(0),"Vesting cannot be a zero address");
        require(_user != address(0),"User cannot be a zero address");
        
        Vesting vesting = Vesting(_vestingAddr);
        
        require(checVestingAddr(_vestingAddr),"Such a vesting address does not exist");

        vesting.addException(_user);
    }

   function _checkTransfer(address _from, address _to, uint256 _amount) internal {
        uint length = vestingUsers[_from].length();

        if(length > 0){
            uint256 totalSumLock;
            //Checking all available vestings
            for(uint i = 0; i < length; i++){
                address vesting = vestingUsers[_from].at(i);
                
                Vesting vest = Vesting(vesting);
                (uint amountLock, bool unlock, bool exclusion) =_allVesting(_from, vesting);
                //If this vesting is unlocked, then we skip the iteration
                if(unlock){
                    continue;
                //In cases where the from address is an exception and it has enough funds to send blocked funds
                }else if(exclusion && amountLock >= _amount){
                    vest.addAddress(_from, _to, _amount);
                    //Checking whether the user has a given vesting address
                    if(!vestingUsers[_to].contains(vesting)){
                        vestingUsers[_to].add(vesting);
                    }
                    super._transfer(_from, _to, _amount);
                    return;
                }
                totalSumLock += amountLock;
            }
            //Checking available funds independent of vesting
            uint256 _amountGeneral = balanceOf(_from) - _amount;
            if(_amountGeneral < totalSumLock){
                revert needToken({
                    vestingAmount: totalSumLock,
                    amountGeneral: _amountGeneral
                });
            }
        }
        super._transfer(_from, _to, _amount);
    }

    function _transfer(address from, address to, uint256 amount) internal override{
        _checkTransfer(from, to, amount);
        
    }

    function seeAddressesVesting() public view returns(address[] memory ){
        uint256 length = vestings.length();
        address[] memory addressesArray = new address[](length);

        for (uint256 i = 0; i < length; i++) {
            addressesArray[i] = vestings.at(i);
        }

        return addressesArray;
    }

    function seeAddressesVestingUser(address _user) public view returns(address[] memory ){
        uint256 length = vestingUsers[_user].length();
        address[] memory addressesArray = new address[](length);

        for (uint256 i = 0; i < length; i++) {
            addressesArray[i] = vestingUsers[_user].at(i);
        }

        return addressesArray;
    }


    function _allVesting(address user, address _vest) internal view returns(uint amountLock, bool unlock, bool exclusion){
        (amountLock, ,exclusion) = Vesting(_vest).userData(user);
        unlock = Vesting(_vest).checkUnlock(user);
    }

    function seeCountUsersBlock(address _vestingAddress) external view returns (uint256){
        return Vesting(_vestingAddress).lenUsersBlock();
    }

    function checVestingAddr(address vesting_address) public view returns (bool){
        return vestings.contains(vesting_address);
    } 
}// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

contract Vesting {

    address immutable nodesys;
    bool private unlock;
    
    struct User{
        uint256 amountLock;
        bool added;
        bool exclusion;
    }

    address[] public indexToAddress;
    mapping(address => User) public userData;
        

    event UnlockAddress(
        address indexed sender
    );
    event UnlockAllUsers(
        uint timestamp
    );
    event Exception(
        address indexed user
    );
    event UserVesting(
        uint256 lengthUsers,
        address indexed user,
        uint blockNumber
    );


    constructor(address _nodesys){
        nodesys = _nodesys;
    }

    modifier Nodesys(){
        require(nodesys == msg.sender,"Only Nodesys smart-contract");
        _;
    }
    

    function addAddress(address sender ,address _newAddress, uint amount) external Nodesys{ 
        User storage user = userData[_newAddress];
        if (sender != address(0)){
            User storage userSender = userData[sender];
            userSender.amountLock -= amount;
        }
        
        if(!user.added) {
            indexToAddress.push(_newAddress);
            user.added = true;
            user.amountLock = amount;

            emit UserVesting(indexToAddress.length, _newAddress, block.number);
        }else{
            user.amountLock += amount;
        }
        
    }

    function getRandom() internal view returns(uint256){
       uint256 random = uint256(keccak256(abi.encodePacked(block.timestamp,block.number)));
       return random;
    }

    function addException(address _user) external Nodesys{
        User storage user = userData[_user];
        require(!unlock, "Vesting is unlocked");
        require(user.added && !user.exclusion,"The user has not been added or is on the exclusion list");
        user.exclusion = true;
        emit Exception(_user);
    }

    function unlockAll() external Nodesys{
        unlock = true;
        emit UnlockAllUsers(block.timestamp);
    }

    function assignRandomAddresses(uint8 percentage) external Nodesys{
        require(percentage <= 100, "Percentage must be <= 100");
        uint256 numAddressesToSetTrue = (indexToAddress.length * percentage) / 100;
        require(numAddressesToSetTrue > 0, "Percentage is too low");
        
        uint256 seed = getRandom();
        while (numAddressesToSetTrue > 0){
            uint256 currentIndex = seed % indexToAddress.length;
            address candidate = indexToAddress[currentIndex];

            numAddressesToSetTrue--;

            delete userData[candidate];
            emit UnlockAddress(candidate);

            indexToAddress[currentIndex] = indexToAddress[indexToAddress.length - 1];
            indexToAddress.pop();

            seed = uint256(keccak256(abi.encodePacked(seed))); // Update the seed
        }

    }

    function checkUnlock(address user) public view returns(bool){
        return unlock ? true: userData[user].amountLock == 0 ;
    }

    function lenUsersBlock() external view returns(uint256){
        return indexToAddress.length;
    }

}