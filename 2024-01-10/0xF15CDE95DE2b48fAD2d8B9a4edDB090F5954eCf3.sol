// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (access/AccessControl.sol)

pragma solidity ^0.8.20;

import {IAccessControl} from "./IAccessControl.sol";
import {Context} from "../utils/Context.sol";
import {ERC165} from "../utils/introspection/ERC165.sol";

/**
 * @dev Contract module that allows children to implement role-based access
 * control mechanisms. This is a lightweight version that doesn't allow enumerating role
 * members except through off-chain means by accessing the contract event logs. Some
 * applications may benefit from on-chain enumerability, for those cases see
 * {AccessControlEnumerable}.
 *
 * Roles are referred to by their `bytes32` identifier. These should be exposed
 * in the external API and be unique. The best way to achieve this is by
 * using `public constant` hash digests:
 *
 * ```solidity
 * bytes32 public constant MY_ROLE = keccak256("MY_ROLE");
 * ```
 *
 * Roles can be used to represent a set of permissions. To restrict access to a
 * function call, use {hasRole}:
 *
 * ```solidity
 * function foo() public {
 *     require(hasRole(MY_ROLE, msg.sender));
 *     ...
 * }
 * ```
 *
 * Roles can be granted and revoked dynamically via the {grantRole} and
 * {revokeRole} functions. Each role has an associated admin role, and only
 * accounts that have a role's admin role can call {grantRole} and {revokeRole}.
 *
 * By default, the admin role for all roles is `DEFAULT_ADMIN_ROLE`, which means
 * that only accounts with this role will be able to grant or revoke other
 * roles. More complex role relationships can be created by using
 * {_setRoleAdmin}.
 *
 * WARNING: The `DEFAULT_ADMIN_ROLE` is also its own admin: it has permission to
 * grant and revoke this role. Extra precautions should be taken to secure
 * accounts that have been granted it. We recommend using {AccessControlDefaultAdminRules}
 * to enforce additional security measures for this role.
 */
abstract contract AccessControl is Context, IAccessControl, ERC165 {
    struct RoleData {
        mapping(address account => bool) hasRole;
        bytes32 adminRole;
    }

    mapping(bytes32 role => RoleData) private _roles;

    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

    /**
     * @dev Modifier that checks that an account has a specific role. Reverts
     * with an {AccessControlUnauthorizedAccount} error including the required role.
     */
    modifier onlyRole(bytes32 role) {
        _checkRole(role);
        _;
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IAccessControl).interfaceId || super.supportsInterface(interfaceId);
    }

    /**
     * @dev Returns `true` if `account` has been granted `role`.
     */
    function hasRole(bytes32 role, address account) public view virtual returns (bool) {
        return _roles[role].hasRole[account];
    }

    /**
     * @dev Reverts with an {AccessControlUnauthorizedAccount} error if `_msgSender()`
     * is missing `role`. Overriding this function changes the behavior of the {onlyRole} modifier.
     */
    function _checkRole(bytes32 role) internal view virtual {
        _checkRole(role, _msgSender());
    }

    /**
     * @dev Reverts with an {AccessControlUnauthorizedAccount} error if `account`
     * is missing `role`.
     */
    function _checkRole(bytes32 role, address account) internal view virtual {
        if (!hasRole(role, account)) {
            revert AccessControlUnauthorizedAccount(account, role);
        }
    }

    /**
     * @dev Returns the admin role that controls `role`. See {grantRole} and
     * {revokeRole}.
     *
     * To change a role's admin, use {_setRoleAdmin}.
     */
    function getRoleAdmin(bytes32 role) public view virtual returns (bytes32) {
        return _roles[role].adminRole;
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     *
     * May emit a {RoleGranted} event.
     */
    function grantRole(bytes32 role, address account) public virtual onlyRole(getRoleAdmin(role)) {
        _grantRole(role, account);
    }

    /**
     * @dev Revokes `role` from `account`.
     *
     * If `account` had been granted `role`, emits a {RoleRevoked} event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     *
     * May emit a {RoleRevoked} event.
     */
    function revokeRole(bytes32 role, address account) public virtual onlyRole(getRoleAdmin(role)) {
        _revokeRole(role, account);
    }

    /**
     * @dev Revokes `role` from the calling account.
     *
     * Roles are often managed via {grantRole} and {revokeRole}: this function's
     * purpose is to provide a mechanism for accounts to lose their privileges
     * if they are compromised (such as when a trusted device is misplaced).
     *
     * If the calling account had been revoked `role`, emits a {RoleRevoked}
     * event.
     *
     * Requirements:
     *
     * - the caller must be `callerConfirmation`.
     *
     * May emit a {RoleRevoked} event.
     */
    function renounceRole(bytes32 role, address callerConfirmation) public virtual {
        if (callerConfirmation != _msgSender()) {
            revert AccessControlBadConfirmation();
        }

        _revokeRole(role, callerConfirmation);
    }

    /**
     * @dev Sets `adminRole` as ``role``'s admin role.
     *
     * Emits a {RoleAdminChanged} event.
     */
    function _setRoleAdmin(bytes32 role, bytes32 adminRole) internal virtual {
        bytes32 previousAdminRole = getRoleAdmin(role);
        _roles[role].adminRole = adminRole;
        emit RoleAdminChanged(role, previousAdminRole, adminRole);
    }

    /**
     * @dev Attempts to grant `role` to `account` and returns a boolean indicating if `role` was granted.
     *
     * Internal function without access restriction.
     *
     * May emit a {RoleGranted} event.
     */
    function _grantRole(bytes32 role, address account) internal virtual returns (bool) {
        if (!hasRole(role, account)) {
            _roles[role].hasRole[account] = true;
            emit RoleGranted(role, account, _msgSender());
            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Attempts to revoke `role` to `account` and returns a boolean indicating if `role` was revoked.
     *
     * Internal function without access restriction.
     *
     * May emit a {RoleRevoked} event.
     */
    function _revokeRole(bytes32 role, address account) internal virtual returns (bool) {
        if (hasRole(role, account)) {
            _roles[role].hasRole[account] = false;
            emit RoleRevoked(role, account, _msgSender());
            return true;
        } else {
            return false;
        }
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (access/IAccessControl.sol)

pragma solidity ^0.8.20;

/**
 * @dev External interface of AccessControl declared to support ERC165 detection.
 */
interface IAccessControl {
    /**
     * @dev The `account` is missing a role.
     */
    error AccessControlUnauthorizedAccount(address account, bytes32 neededRole);

    /**
     * @dev The caller of a function is not the expected one.
     *
     * NOTE: Don't confuse with {AccessControlUnauthorizedAccount}.
     */
    error AccessControlBadConfirmation();

    /**
     * @dev Emitted when `newAdminRole` is set as ``role``'s admin role, replacing `previousAdminRole`
     *
     * `DEFAULT_ADMIN_ROLE` is the starting admin for all roles, despite
     * {RoleAdminChanged} not being emitted signaling this.
     */
    event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole);

    /**
     * @dev Emitted when `account` is granted `role`.
     *
     * `sender` is the account that originated the contract call, an admin role
     * bearer except when using {AccessControl-_setupRole}.
     */
    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);

    /**
     * @dev Emitted when `account` is revoked `role`.
     *
     * `sender` is the account that originated the contract call:
     *   - if using `revokeRole`, it is the admin role bearer
     *   - if using `renounceRole`, it is the role bearer (i.e. `account`)
     */
    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);

    /**
     * @dev Returns `true` if `account` has been granted `role`.
     */
    function hasRole(bytes32 role, address account) external view returns (bool);

    /**
     * @dev Returns the admin role that controls `role`. See {grantRole} and
     * {revokeRole}.
     *
     * To change a role's admin, use {AccessControl-_setRoleAdmin}.
     */
    function getRoleAdmin(bytes32 role) external view returns (bytes32);

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function grantRole(bytes32 role, address account) external;

    /**
     * @dev Revokes `role` from `account`.
     *
     * If `account` had been granted `role`, emits a {RoleRevoked} event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function revokeRole(bytes32 role, address account) external;

    /**
     * @dev Revokes `role` from the calling account.
     *
     * Roles are often managed via {grantRole} and {revokeRole}: this function's
     * purpose is to provide a mechanism for accounts to lose their privileges
     * if they are compromised (such as when a trusted device is misplaced).
     *
     * If the calling account had been granted `role`, emits a {RoleRevoked}
     * event.
     *
     * Requirements:
     *
     * - the caller must be `callerConfirmation`.
     */
    function renounceRole(bytes32 role, address callerConfirmation) external;
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.20;

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
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.1) (utils/Context.sol)

pragma solidity ^0.8.20;

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
// OpenZeppelin Contracts (last updated v5.0.0) (utils/introspection/ERC165.sol)

pragma solidity ^0.8.20;

import {IERC165} from "./IERC165.sol";

/**
 * @dev Implementation of the {IERC165} interface.
 *
 * Contracts that want to implement ERC165 should inherit from this contract and override {supportsInterface} to check
 * for the additional interface id that will be supported. For example:
 *
 * ```solidity
 * function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
 *     return interfaceId == type(MyInterface).interfaceId || super.supportsInterface(interfaceId);
 * }
 * ```
 */
abstract contract ERC165 is IERC165 {
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (utils/introspection/IERC165.sol)

pragma solidity ^0.8.20;

/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
interface IERC165 {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (utils/ReentrancyGuard.sol)

pragma solidity ^0.8.20;

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
    uint256 private constant NOT_ENTERED = 1;
    uint256 private constant ENTERED = 2;

    uint256 private _status;

    /**
     * @dev Unauthorized reentrant call.
     */
    error ReentrancyGuardReentrantCall();

    constructor() {
        _status = NOT_ENTERED;
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
        // On the first call to nonReentrant, _status will be NOT_ENTERED
        if (_status == ENTERED) {
            revert ReentrancyGuardReentrantCall();
        }

        // Any calls to nonReentrant after this point will fail
        _status = ENTERED;
    }

    function _nonReentrantAfter() private {
        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = NOT_ENTERED;
    }

    /**
     * @dev Returns true if the reentrancy guard is currently set to "entered", which indicates there is a
     * `nonReentrant` function in the call stack.
     */
    function _reentrancyGuardEntered() internal view returns (bool) {
        return _status == ENTERED;
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (utils/structs/EnumerableSet.sol)
// This file was procedurally generated from scripts/generate/templates/EnumerableSet.js.

pragma solidity ^0.8.20;

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
// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;
interface IMiner {
    struct User {
        uint invest;
        uint withdraw;
        uint reinvest;
        uint hatcheryMiners;
        uint claimedMiners;
        uint lastHatch;
        uint checkpoint;
        address referrals;
        // uint[1] referrer;
        uint bonus;
        uint amountBNBReferrer;
        uint amountMINERSReferrer;
        uint totalRefDeposits;
    }

    function users(address user) external view returns (User memory);

}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

interface IRetoV2 {
	struct Deposit {
		uint plan;
		uint amount;
		uint withdrawn;
		uint start;
		bool force;
	}

	struct Plan {
		uint percent;
		uint MAX_PROFIT;
	}

	event Paused(address account);
	event Unpaused(address account);
	event Newbie(address user);
	event NewDeposit(address indexed user, uint amount);
	event Withdrawn(address indexed user, uint amount);
	event RefBonus(address indexed referrer, address indexed referral, uint indexed level, uint amount);
	event FeePayed(address indexed user, uint totalAmount);
	event Reinvestment(address indexed user, uint amount);
	event ForceWithdraw(address indexed user, uint amount);

}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "./IRetoV2.sol";
// import "../Resources/IVaultReceiverV2.sol";
// import "../Resources/IVaultV3.sol";

contract RetoV2_State is IRetoV2 {
	address public TOKEN;
	bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
	// 1000 == 100%, 100 == 10%, 10 == 1%, 1 == 0.1%
	uint constant public REFERRAL_LEGNTH = 1;
	uint[REFERRAL_LEGNTH] public REFERRAL_PERCENTS;
	uint constant public INVEST_MIN_AMOUNT = 1 ether;
	// uint constant public INVEST_MAX_AMOUNT = 100 ether;
	uint constant public MIN_WITHDRAW = 1 ether;
	uint constant public PERCENTS_DIVIDER = 1_000;
	uint constant public TIME_STEP = 1 days;
	uint constant public USER_STEP = 7 * TIME_STEP;
	uint constant public FORCE_WITHDRAW_PERCENT = 700;

	uint public initDate;

	uint public totalUsers;
	uint public totalInvested;
	uint public totalWithdrawn;
	uint public totalDeposits;
	uint public totalReinvested;

	// address public twallet;
	address public oWallet;
	address public devFeeWallet;
	address public pWallet;
	address public pWallet2;
	address public mWallet;

	address public devAddress;

	struct User {
		mapping (uint => Deposit) deposits;
		uint totalStake;
		uint depositsLength;
		uint bonus;
		uint reinvest;
		uint totalBonus;
		uint checkpoint;
		uint[1] referrerCount;
		uint[1] referrerBonus;
		uint[1] refTotalInvest;
		address referrer;
		uint license;
	}

	Plan[1] public plans;

	mapping (address => User) public users;
	// lottery data
	uint public MAX_TICKETS_BY_POOL;
	uint public MIN_REWARD_BY_POOL;

	struct Pool {
		uint id;
		// uint currentTicket;
		uint userCount;
		uint totalInvested;
		uint startTime;
		uint duration;
		uint winner;
		uint reward;
		address winerAddress;
		bool isClosed;
	}

	struct UserTicket {
		address userAddress;
		uint id;
		uint poolId;
		uint ticketsCount;
	}

	uint public poolCount;

	mapping(uint => Pool) public pools;
	mapping(uint => mapping(uint => address)) public userPoolByIndex;
	mapping(uint => mapping(address => UserTicket)) public userPool;
	mapping(uint => mapping(address => EnumerableSet.UintSet)) private ticketsByUser;

	struct UserData {
		uint winsCount;
		// uint invested;
		uint reward;
	}

	mapping(address => EnumerableSet.UintSet) internal userWinsPool;
	mapping(address => UserData) public userData;

	uint public minInvest;
	uint public ticketPrice;

	modifier onlyOwner() {
		require(devAddress == msg.sender, "Ownable: caller is not the owner");
		_;
	}

	modifier whenNotPaused() {
		require(initDate > 0, "Pausable: paused");
		_;
	}

	modifier whenPaused() {
		require(initDate == 0, "Pausable: not paused");
		_;
	}

	function unpause() external whenPaused onlyOwner {
		initDate = block.timestamp;
		emit Unpaused(msg.sender);
	}

	function isPaused() external view returns(bool) {
		return (initDate == 0);
	}

	function getMaxprofit(Deposit memory ndeposit) internal view returns(uint) {
		Plan memory plan = plans[ndeposit.plan];
		if(ndeposit.force) {
			return (ndeposit.amount * FORCE_WITHDRAW_PERCENT) / PERCENTS_DIVIDER;
		}
		return (ndeposit.amount * plan.MAX_PROFIT) / PERCENTS_DIVIDER;
	}

	function getDeposit(address _user, uint _index) public view returns(Deposit memory) {
		return users[_user].deposits[_index];
	}

	function getDAte() public view returns(uint) {
		return block.timestamp;
	}

	function getReferrerBonus(address _user) external view returns(uint[REFERRAL_LEGNTH] memory) {
		return users[_user].referrerBonus;
	}

	function getContracDate() public view returns(uint) {
		if(initDate == 0) {
			return block.timestamp;
		}
		return initDate;
	}

	function setPlans() internal {
		plans[0].percent = 5;
		plans[0].MAX_PROFIT = 2000;
	}

	function getUserPlans(address _user) external view returns(Deposit[] memory) {
		User storage user = users[_user];
		Deposit[] memory result = new Deposit[](user.depositsLength);
		for (uint i; i < user.depositsLength; i++) {
			result[i] = user.deposits[i];
		}
		return result;
	}


}
//TODO: DELETE takeToken
// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "./RetoV2_State.sol";
import "./IMiner.sol";

contract RetoV2 is RetoV2_State, AccessControl, ReentrancyGuard {
	using EnumerableSet for EnumerableSet.UintSet;
	// uint constant public MIN_INVEST = 1 ether;
	address public minerAddress;
	address public defWallet;
	address public pWallet3;
	mapping(address => bool) public hasInvested;

	constructor(address _token, address _devFeeWallet, address _defWallet, address _oWallet, address _mWallet, address _pwallet, address _pwallet2, address _pWallet3, address _minerAddress) {
		require(users[_devFeeWallet].referrerCount.length == REFERRAL_LEGNTH, "referral array error");
		_grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(ADMIN_ROLE, msg.sender);
		minerAddress = _minerAddress;
		TOKEN = _token;
		REFERRAL_PERCENTS = [100];
		devAddress = msg.sender;
		devFeeWallet = _devFeeWallet;
		defWallet = _defWallet;
		// twallet = _tWallet;
		oWallet = _oWallet;
		mWallet = _mWallet;
		pWallet = _pwallet;
		pWallet2 = _pwallet2;
		pWallet3 = _pWallet3;
		// MAX_TICKETS_BY_POOL 
		// MIN_REWARD_BY_POOL = 0;
		minInvest = 25 ether;
		poolCount++;
        pools[poolCount] = Pool(1, 0, 0, block.timestamp, 30 * TIME_STEP, 0, 0, address(0), false);
		setPlans();
		emit Paused(msg.sender);
	}

	modifier checkUser_() {
		require(checkUser(msg.sender), "try again later");
		_;
	}

    function setAdmins(address[] memory _admins, bool _isAdmin) external onlyOwner {
        for (uint i = 0; i < _admins.length; i++) {
            if (_isAdmin) {
                grantRole(ADMIN_ROLE, _admins[i]);
            } else {
                revokeRole(ADMIN_ROLE, _admins[i]);
            }
        }
    }

	function checkUser(address _user) public view returns (bool){
		uint check = block.timestamp - (getlastActionDate(users[_user]));
		if(check > USER_STEP) {
			return true;
		}
		return false;
	}

	function invest(address referrer, uint investAmt) external payable nonReentrant whenNotPaused {
		require(investAmt >= INVEST_MIN_AMOUNT, "insufficient deposit");
		// require(investAmt <= INVEST_MAX_AMOUNT, "deposit limit exceeded");
		IERC20(TOKEN).transferFrom(msg.sender, address(this), investAmt);
		investHandler(investAmt, referrer, true);
	}

	function investHandler(uint investAmt, address referrer, bool _withFee) internal {
		uint plan = 0;
		// require(investAmt >= MIN_INVEST, "Zero amount"); 
		require(plan < plans.length, "invalid plan");
		if(_withFee) {
			payFeeInvest(investAmt);
		}

		User storage user = users[msg.sender];

		if (user.depositsLength == 0) {
			user.checkpoint = block.timestamp;
			totalUsers++;
			if (user.referrer == address(0) && users[referrer].depositsLength > 0 && referrer != msg.sender) {
				user.referrer = referrer;
			}
			emit Newbie(msg.sender);
		}
		if(investAmt >= minInvest) {
			uint _poolId = poolCount;
			UserTicket storage userTicket = userPool[_poolId][msg.sender];
			if (userTicket.userAddress == address(0)) {
				userTicket.userAddress = msg.sender;
				pools[_poolId].userCount++;
				userTicket.id = pools[_poolId].userCount;
				userTicket.poolId = _poolId;
				userPoolByIndex[_poolId][userTicket.id] = msg.sender;
			}
		}

		address upline;

		if (user.referrer != address(0)) {
			upline = user.referrer;
		} else {
			upline = defWallet;
		}

		uint _bonus;
		uint _oldWithdraw;
		IMiner.User memory _userMiner;
		if(!hasInvested[msg.sender]) {
			_userMiner = IMiner(minerAddress).users(msg.sender);
			if(_userMiner.withdraw < _userMiner.invest * 2) {
				require(_userMiner.invest > _userMiner.reinvest, "reinvest rest invest");
				_bonus = _userMiner.invest - _userMiner.reinvest;
				_oldWithdraw = _userMiner.withdraw;
			}
			hasInvested[msg.sender] = true;
			if(_userMiner.referrals != address(0)) {
				upline = _userMiner.referrals;
				user.referrer = upline;
			}
		}

		for(uint i; i < REFERRAL_PERCENTS.length; i++) {
			if(upline != address(0)) {
				uint amount = (investAmt * (REFERRAL_PERCENTS[i])) / (PERCENTS_DIVIDER);
				// if(upline == devAddress) {
				transferHandler(upline, amount);
				// }
				// else {
				// 	users[upline].bonus += amount;
				// }
				users[upline].totalBonus += amount;
				if(user.depositsLength == 0)
				users[upline].referrerCount[i] += 1;
				users[upline].referrerBonus[i] += amount;
				users[upline].refTotalInvest[i] += investAmt;
				emit RefBonus(upline, msg.sender, i, amount);
				upline = users[upline].referrer;
				if(upline == address(0)) {
					upline = defWallet;
				}
			} else break;
		}
		require(investAmt + _bonus > 0, "Zero amount");
		Deposit memory newDeposit;
		newDeposit.plan = plan;
		newDeposit.amount = investAmt + _bonus;
		newDeposit.start = block.timestamp;
		newDeposit.withdrawn += _oldWithdraw;
		user.deposits[user.depositsLength] = newDeposit;
		user.depositsLength++;
		user.totalStake += investAmt + _bonus;
		user.license = block.timestamp;

		totalInvested += investAmt + _bonus;
		totalDeposits += 1;
		emit NewDeposit(msg.sender, investAmt);
	}

	function registerInvest() external payable nonReentrant whenNotPaused {
		investHandler(0, defWallet, true);
	}

	function withdraw()  payable external whenNotPaused checkUser_ returns(bool) {
		require(isActive(msg.sender), "Dont is User");
		User storage user = users[msg.sender];

		uint totalAmount;

		for(uint i; i < user.depositsLength; i++) {
			uint dividends;
			Deposit memory deposit = user.deposits[i];

			if(deposit.withdrawn < getMaxprofit(deposit) && deposit.force == false) {
				dividends = calculateDividents(deposit, user, totalAmount);

				if(dividends > 0) {
					user.deposits[i].withdrawn += dividends; // changing of storage data
					totalAmount += dividends;
				}
			}
		}

		require(totalAmount >= MIN_WITHDRAW, "User has no dividends");

		uint referralBonus = user.bonus;
		if(referralBonus > 0) {
			totalAmount += referralBonus;
			delete user.bonus;
		}

		uint contractBalance = getContractBalance();
		if(contractBalance < totalAmount) {
			totalAmount = contractBalance;
		}

		user.checkpoint = block.timestamp;

		totalWithdrawn += totalAmount;
		uint256 fee = payFeeWithdraw(totalAmount);
		uint256 toTransfer = totalAmount - fee;
		transferHandler(msg.sender, toTransfer);
		emit FeePayed(msg.sender, fee);
		emit Withdrawn(msg.sender, totalAmount);
		return true;
	}

	function reinvestment() external  payable  whenNotPaused checkUser_ nonReentrant returns(bool) {
		require(isActive(msg.sender), "Dont is User");
		User storage user = users[msg.sender];
		uint totalDividends;

		for(uint i; i < user.depositsLength; i++) {
			uint dividends;
			Deposit memory deposit = user.deposits[i];

			if(deposit.withdrawn < getMaxprofit(deposit) && deposit.force == false) {
				dividends = calculateDividents(deposit, user, totalDividends);

				if(dividends > 0) {
					user.deposits[i].withdrawn += dividends;
					totalDividends += dividends;
				}
			}
		}

		require(totalDividends > 0, "User has no dividends");

		uint referralBonus = user.bonus;
		if(referralBonus > 0) {
			totalDividends += referralBonus;
			delete user.bonus;
		}

		user.reinvest += totalDividends;
		totalReinvested += totalDividends;
		totalWithdrawn += totalDividends;
		user.checkpoint = block.timestamp;
		// payFeeInvest(totalDividends);
		investHandler(totalDividends, user.referrer, false);
		return true;
	}

	// function forceWithdraw() external whenNotPaused nonReentrant {
	//	 User storage user = users[msg.sender];
	// 	uint totalDividends;
	// 	uint toFee;
	// 	for(uint256 i; i < user.depositsLength; i++) {
	// 		Deposit storage deposit = user.deposits[i];
	// 		if(deposit.force == false) {
	// 			deposit.force = true;
	// 			uint maxProfit = getMaxprofit(deposit);
	// 			if(deposit.withdrawn < maxProfit) {
	// 				uint profit = maxProfit - (deposit.withdrawn);
	// 				deposit.withdrawn = deposit.withdrawn + (profit);
	// 				totalDividends += profit;
	// 				toFee += deposit.amount - profit;
	// 			}
	// 		}

	// 	}
	// 	require(totalDividends > 0, "User has no dividends");
	// 	uint256 contractBalance = getContractBalance();
	// 	if(contractBalance < totalDividends + toFee) {
	// 		totalDividends = contractBalance * (FORCE_WITHDRAW_PERCENT) / (PERCENTS_DIVIDER);
	// 		toFee = contractBalance - totalDividends;
	// 	}
	// 	user.checkpoint = block.timestamp;
	// 	payFees(toFee);
	// 	transferHandler(msg.sender, totalDividends);
	// 	emit FeePayed(msg.sender, toFee);
	// 	emit ForceWithdraw(msg.sender, totalDividends);
	// }

	function getNextUserAssignment(address userAddress) public view returns (uint) {
		uint checkpoint = getlastActionDate(users[userAddress]);
		uint _date = getContracDate();
		if(_date > checkpoint)
			checkpoint = _date;
		return checkpoint + (USER_STEP);
	}

	function getPublicData() external view returns(uint totalUsers_,
		uint totalInvested_,
		uint totalReinvested_,
		uint totalWithdrawn_,
		uint totalDeposits_,
		uint balance_,
		// uint roiBase,
		// uint maxProfit,
		uint minDeposit,
		uint daysFormdeploy
		) {
		totalUsers_ = totalUsers;
		totalInvested_ = totalInvested;
		totalReinvested_ = totalReinvested;
		totalWithdrawn_ = totalWithdrawn;
		totalDeposits_ = totalDeposits;
		balance_ = getContractBalance();
		// roiBase = ROI_BASE;
		// maxProfit = MAX_PROFIT;
		minDeposit = INVEST_MIN_AMOUNT;
		daysFormdeploy = (block.timestamp - (getContracDate())) / (TIME_STEP);
	}

	function getUserData(address userAddress) external view returns(uint totalWithdrawn_,
		uint totalDeposits_,
		// uint totalBonus_,
		uint totalReinvest_,
		uint balance_,
		uint nextAssignment_,
		uint amountOfDeposits,
		uint checkpoint,
		bool isUser_,
		address referrer_,
		uint[REFERRAL_LEGNTH] memory referrerCount_,
		uint[REFERRAL_LEGNTH] memory referrerBonus_,
		uint[REFERRAL_LEGNTH] memory refTotalInvest_
	){
		User storage user = users[userAddress];
		totalWithdrawn_ = getUserTotalWithdrawn(userAddress);
		totalDeposits_ = getUserTotalDeposits(userAddress);
		nextAssignment_ = getNextUserAssignment(userAddress);
		balance_ = getUserDividends(userAddress);
		// totalBonus_ = user.bonus;
		totalReinvest_ = user.reinvest;
		amountOfDeposits = user.depositsLength;

		checkpoint = getlastActionDate(user);
		isUser_ = user.depositsLength > 0;
		referrer_ = user.referrer;
		referrerCount_ = user.referrerCount;
		referrerBonus_= user.referrerBonus;
		refTotalInvest_ = user.refTotalInvest;
	}

	function getContractBalance() public view returns (uint) {
		return IERC20(TOKEN).balanceOf(address(this));
	}

	function getUserDividends(address userAddress) internal view returns (uint) {
		User storage user = users[userAddress];

		uint totalDividends;

		for(uint i; i < user.depositsLength; i++) {

			Deposit memory deposit = users[userAddress].deposits[i];

			if(deposit.withdrawn < getMaxprofit(deposit) && deposit.force == false) {
				uint dividends = calculateDividents(deposit, user, totalDividends);
				totalDividends += dividends;
			}

		}

		return totalDividends;
	}

	function calculateDividents(Deposit memory deposit, User storage user, uint) internal view returns (uint) {
		uint dividends;
		uint depositPercentRate = plans[deposit.plan].percent;

		uint checkDate = getDepsitStartDate(deposit);

		if(checkDate < getlastActionDate(user)) {
			checkDate = getlastActionDate(user);
		}

		dividends = (deposit.amount
		 * (depositPercentRate * (block.timestamp - (checkDate))))
		 / ((PERCENTS_DIVIDER) * (TIME_STEP))
		;


		/*
		if(dividends + _current > userMaxProfit) {
			dividends = userMaxProfit - (_current, "max dividends");
		}
		*/

		if(deposit.withdrawn + (dividends) > getMaxprofit(deposit)) {
			dividends = getMaxprofit(deposit) - (deposit.withdrawn);
		}

		return dividends;

	}

	function isActive(address userAddress) public view returns (bool) {
		User storage user = users[userAddress];

		if (user.depositsLength > 0) {
			if(users[userAddress].deposits[user.depositsLength-1].withdrawn < getMaxprofit(users[userAddress].deposits[user.depositsLength-1])) {
				return true;
			}
		}
		return false;
	}

	function getUserDepositInfo(address userAddress, uint index) external view returns(
		uint plan_,
		uint amount_,
		uint withdrawn_,
		uint timeStart_,
		uint maxProfit
		) {
		Deposit memory deposit = users[userAddress].deposits[index];
		amount_ = deposit.amount;
		plan_ = deposit.plan;
		withdrawn_ = deposit.withdrawn;
		timeStart_= getDepsitStartDate(deposit);
		maxProfit = getMaxprofit(deposit);
	}


	function getUserTotalDeposits(address userAddress) internal view returns(uint) {
		User storage user = users[userAddress];
		uint amount;
		for(uint i; i < user.depositsLength; i++) {
			amount += users[userAddress].deposits[i].amount;
		}
		return amount;
	}

	function getUserTotalWithdrawn(address userAddress) internal view returns(uint) {
		User storage user = users[userAddress];

		uint amount;

		for(uint i; i < user.depositsLength; i++) {
			amount += users[userAddress].deposits[i].withdrawn;
		}
		return amount;
	}

	function getlastActionDate(User storage user) internal view returns(uint) {
		uint checkpoint = user.checkpoint;
		uint _date = getContracDate();
		if(_date > checkpoint)
			checkpoint = _date;
		return checkpoint;
	}

	function isContract(address addr) internal view returns (bool) {
		uint size;
		assembly { size := extcodesize(addr) }
		return size > 0;
	}

	function getDepsitStartDate(Deposit memory ndeposit) private view returns(uint) {
		uint _date = getContracDate();
		if(_date > ndeposit.start) {
			return _date;
		} else {
			return ndeposit.start;
		}
	}

	function transferHandler(address to, uint amount) internal {
		if(amount > getContractBalance()) {
			amount = getContractBalance();
		}
		if(to == defWallet) {
			uint toDev = (amount * 20) / 100;
			uint toPWallet = (amount * 10) / 100;
			// payable(defWallet).transfer(toDev);
			// payable(oWallet).transfer(amount - toDev);
			IERC20(TOKEN).transfer(devFeeWallet, toDev);
			IERC20(TOKEN).transfer(pWallet, toPWallet);
			IERC20(TOKEN).transfer(oWallet, amount - toDev - toPWallet);
		} else {
			// payable(to).transfer(amount);
			IERC20(TOKEN).transfer(to, amount);
		}
	}

	function payFeeInvest(uint amount) internal returns (uint _totalFee) {
		uint toOWallet = (amount * 60) / PERCENTS_DIVIDER;
		uint toDevWallet = (amount * 15) / PERCENTS_DIVIDER;
		uint toMWallet = (amount * 17) / PERCENTS_DIVIDER;
		uint toPWallet = (amount * 4) / PERCENTS_DIVIDER;
		uint toPWallet2 = (amount * 2) / PERCENTS_DIVIDER;
		uint toPWallet3 = (amount * 2) / PERCENTS_DIVIDER;
		transferHandler(oWallet, toOWallet);
		// transferHandler(twallet, toTWallet);
		transferHandler(devFeeWallet, toDevWallet);
		transferHandler(mWallet, toMWallet);
		transferHandler(pWallet, toPWallet);
		transferHandler(pWallet2, toPWallet2);
		transferHandler(pWallet3, toPWallet3);
		_totalFee = toOWallet + toDevWallet + toMWallet + toPWallet + toPWallet2 + toPWallet3;
		emit FeePayed(msg.sender, _totalFee);
		return _totalFee;
	}

	function payFeeWithdraw(uint amount) internal returns (uint _totalFee) {
		uint toOWallet = (amount * 42) / PERCENTS_DIVIDER;
		uint toDevWallet = (amount * 11) / PERCENTS_DIVIDER;
		uint toMWallet = (amount * 11) / PERCENTS_DIVIDER;
		uint toPWallet = (amount * 3) / PERCENTS_DIVIDER;
		uint toPWallet2 = (amount * 2) / PERCENTS_DIVIDER;
		uint toPWallet3 = (amount * 1) / PERCENTS_DIVIDER;
		transferHandler(oWallet, toOWallet);
		// transferHandler(twallet, toTWallet);
		transferHandler(devFeeWallet, toDevWallet);
		transferHandler(mWallet, toMWallet);
		transferHandler(pWallet, toPWallet);
		transferHandler(pWallet2, toPWallet2);
		transferHandler(pWallet3, toPWallet3);
		_totalFee = toOWallet + toDevWallet + toMWallet + toPWallet + toPWallet2 + toPWallet3;
		emit FeePayed(msg.sender, _totalFee);
		return _totalFee;
	}

	// function payBonus() payable nonReentrant whenNotPaused external {
	// 	User storage user = users[msg.sender];
	// 	uint amount = user.bonus;
	// 	uint _totalFee = payFeeWithdraw(amount);
	// 	delete user.bonus;
	// 	transferHandler(payable(msg.sender), amount - _totalFee);
	// }

    modifier onlyAdmin() {
        require(hasRole(ADMIN_ROLE, msg.sender), "Caller is not an admin");
        _;
    }

    function addPool(uint _duration) external onlyAdmin {
        require(pools[poolCount].isClosed == true, "Previous pool is not closed");
        poolCount++;
        pools[poolCount] = Pool(poolCount, 0, 0, block.timestamp, _duration, 0, 0, address(0), false);
    }

    function closePool(uint _poolId, bool _isClosed) external onlyAdmin {
        pools[_poolId].isClosed = _isClosed;
    }

    function editPool(uint _poolId, uint _duration) external onlyAdmin {
        pools[_poolId].duration = _duration;
    }

	function payReward(uint _poolId, uint winner, uint _reward) external onlyAdmin {
        require(_poolId > 0, "Pool ID must be greater than 0");
        require(_poolId <= poolCount, "Pool does not exist");
        require(winner > 0, "Winner must be greater than 0");
        require(winner <= pools[_poolId].userCount, "Winner does not exist");
        Pool memory pool = pools[_poolId];
        // require(pool.startTime + pools[_poolId].duration < block.timestamp, "Pool is not closed");
        require(pool.winner == 0, "Pool is closed");
        // uint reward = pool.reward;
		IERC20(TOKEN).transferFrom(msg.sender, address(this), _reward);
        require(_reward <= IERC20(TOKEN).balanceOf(msg.sender), "Not enough tokens");
		address _winnerWallet = userPoolByIndex[_poolId][winner];
        require(_winnerWallet != address(0), "Winner does not exist 2");
        // require(pool.isClosed == false, "Pool is closed");
		pool.reward = _reward;
        pool.winner = winner;
		pool.winerAddress = _winnerWallet;
        pool.isClosed = true;
        pools[_poolId] = pool;
        userData[_winnerWallet].reward += _reward;
        userData[_winnerWallet].winsCount++;
        userWinsPool[_winnerWallet].add(_poolId);
		users[_winnerWallet].bonus += _reward;
		poolCount++;
        pools[poolCount] = Pool(1, 0, 0, block.timestamp, 30 * TIME_STEP, 0, 0, address(0), false);
        // transferHandler(_winnerWallet, _reward);
        IERC20(TOKEN).transfer(_winnerWallet, _reward);
    }

    function getAllPools() external view returns (Pool[] memory) {
        Pool[] memory poolsArray = new Pool[](poolCount);
        for (uint i = 0; i < poolCount; i++) {
            poolsArray[i] = pools[i + 1];
        }
        return poolsArray;
    }

    function getAllUsersByPool(uint _poolId) external view returns (UserTicket[] memory) {
        UserTicket[] memory _users = new UserTicket[](pools[_poolId].userCount);
        for (uint i = 0; i < pools[_poolId].userCount; i++) {
            _users[i] = userPool[_poolId][userPoolByIndex[_poolId][i + 1]];
        }
        return _users;
    }

    function allWalletsByPool(uint _poolId) external view returns (address[] memory) {
        address[] memory _users = new address[](pools[_poolId].userCount);
        for (uint i = 0; i < pools[_poolId].userCount; i++) {
            _users[i] = userPoolByIndex[_poolId][i + 1];
        }
        return _users;
    }

}
