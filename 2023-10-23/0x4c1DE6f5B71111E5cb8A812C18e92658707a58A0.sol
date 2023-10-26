// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (access/AccessControl.sol)

pragma solidity ^0.8.0;

import "./IAccessControl.sol";
import "../utils/Context.sol";
import "../utils/Strings.sol";
import "../utils/introspection/ERC165.sol";

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
 * ```
 * bytes32 public constant MY_ROLE = keccak256("MY_ROLE");
 * ```
 *
 * Roles can be used to represent a set of permissions. To restrict access to a
 * function call, use {hasRole}:
 *
 * ```
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
 * accounts that have been granted it.
 */
abstract contract AccessControl is Context, IAccessControl, ERC165 {
    struct RoleData {
        mapping(address => bool) members;
        bytes32 adminRole;
    }

    mapping(bytes32 => RoleData) private _roles;

    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

    /**
     * @dev Modifier that checks that an account has a specific role. Reverts
     * with a standardized message including the required role.
     *
     * The format of the revert reason is given by the following regular expression:
     *
     *  /^AccessControl: account (0x[0-9a-f]{40}) is missing role (0x[0-9a-f]{64})$/
     *
     * _Available since v4.1._
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
    function hasRole(bytes32 role, address account) public view virtual override returns (bool) {
        return _roles[role].members[account];
    }

    /**
     * @dev Revert with a standard message if `_msgSender()` is missing `role`.
     * Overriding this function changes the behavior of the {onlyRole} modifier.
     *
     * Format of the revert message is described in {_checkRole}.
     *
     * _Available since v4.6._
     */
    function _checkRole(bytes32 role) internal view virtual {
        _checkRole(role, _msgSender());
    }

    /**
     * @dev Revert with a standard message if `account` is missing `role`.
     *
     * The format of the revert reason is given by the following regular expression:
     *
     *  /^AccessControl: account (0x[0-9a-f]{40}) is missing role (0x[0-9a-f]{64})$/
     */
    function _checkRole(bytes32 role, address account) internal view virtual {
        if (!hasRole(role, account)) {
            revert(
                string(
                    abi.encodePacked(
                        "AccessControl: account ",
                        Strings.toHexString(uint160(account), 20),
                        " is missing role ",
                        Strings.toHexString(uint256(role), 32)
                    )
                )
            );
        }
    }

    /**
     * @dev Returns the admin role that controls `role`. See {grantRole} and
     * {revokeRole}.
     *
     * To change a role's admin, use {_setRoleAdmin}.
     */
    function getRoleAdmin(bytes32 role) public view virtual override returns (bytes32) {
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
    function grantRole(bytes32 role, address account) public virtual override onlyRole(getRoleAdmin(role)) {
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
    function revokeRole(bytes32 role, address account) public virtual override onlyRole(getRoleAdmin(role)) {
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
     * - the caller must be `account`.
     *
     * May emit a {RoleRevoked} event.
     */
    function renounceRole(bytes32 role, address account) public virtual override {
        require(account == _msgSender(), "AccessControl: can only renounce roles for self");

        _revokeRole(role, account);
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event. Note that unlike {grantRole}, this function doesn't perform any
     * checks on the calling account.
     *
     * May emit a {RoleGranted} event.
     *
     * [WARNING]
     * ====
     * This function should only be called from the constructor when setting
     * up the initial roles for the system.
     *
     * Using this function in any other way is effectively circumventing the admin
     * system imposed by {AccessControl}.
     * ====
     *
     * NOTE: This function is deprecated in favor of {_grantRole}.
     */
    function _setupRole(bytes32 role, address account) internal virtual {
        _grantRole(role, account);
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
     * @dev Grants `role` to `account`.
     *
     * Internal function without access restriction.
     *
     * May emit a {RoleGranted} event.
     */
    function _grantRole(bytes32 role, address account) internal virtual {
        if (!hasRole(role, account)) {
            _roles[role].members[account] = true;
            emit RoleGranted(role, account, _msgSender());
        }
    }

    /**
     * @dev Revokes `role` from `account`.
     *
     * Internal function without access restriction.
     *
     * May emit a {RoleRevoked} event.
     */
    function _revokeRole(bytes32 role, address account) internal virtual {
        if (hasRole(role, account)) {
            _roles[role].members[account] = false;
            emit RoleRevoked(role, account, _msgSender());
        }
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/IAccessControl.sol)

pragma solidity ^0.8.0;

/**
 * @dev External interface of AccessControl declared to support ERC165 detection.
 */
interface IAccessControl {
    /**
     * @dev Emitted when `newAdminRole` is set as ``role``'s admin role, replacing `previousAdminRole`
     *
     * `DEFAULT_ADMIN_ROLE` is the starting admin for all roles, despite
     * {RoleAdminChanged} not being emitted signaling this.
     *
     * _Available since v3.1._
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
     * - the caller must be `account`.
     */
    function renounceRole(bytes32 role, address account) external;
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
// OpenZeppelin Contracts v4.4.1 (utils/introspection/ERC165.sol)

pragma solidity ^0.8.0;

import "./IERC165.sol";

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
 *
 * Alternatively, {ERC165Storage} provides an easier to use but more expensive implementation.
 */
abstract contract ERC165 is IERC165 {
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/introspection/IERC165.sol)

pragma solidity ^0.8.0;

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
// OpenZeppelin Contracts (last updated v4.7.0) (utils/Strings.sol)

pragma solidity ^0.8.0;

/**
 * @dev String operations.
 */
library Strings {
    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";
    uint8 private constant _ADDRESS_LENGTH = 20;

    /**
     * @dev Converts a `uint256` to its ASCII `string` decimal representation.
     */
    function toString(uint256 value) internal pure returns (string memory) {
        // Inspired by OraclizeAPI's implementation - MIT licence
        // https://github.com/oraclize/ethereum-api/blob/b42146b063c7d6ee1358846c198246239e9360e8/oraclizeAPI_0.4.25.sol

        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation.
     */
    function toHexString(uint256 value) internal pure returns (string memory) {
        if (value == 0) {
            return "0x00";
        }
        uint256 temp = value;
        uint256 length = 0;
        while (temp != 0) {
            length++;
            temp >>= 8;
        }
        return toHexString(value, length);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation with fixed length.
     */
    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _HEX_SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }

    /**
     * @dev Converts an `address` with fixed length of 20 bytes to its not checksummed ASCII `string` hexadecimal representation.
     */
    function toHexString(address addr) internal pure returns (string memory) {
        return toHexString(uint256(uint160(addr)), _ADDRESS_LENGTH);
    }
}
// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.17;

/**
 * @title Mosaic Alpha SimpleDeposit contract
 * @author dlabs.hu / Peter Molnar
 * @dev This contract is for creating and tracing client deposits
 */

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "../helpers/SystemRole.sol";
import "../Interfaces/ISimpleDeposit.sol";
import "../Interfaces/IRegister.sol";
import "../Interfaces/IAffiliate.sol";
import "../Interfaces/IFees.sol";
import "../Interfaces/ISimpleDeposit.sol";
import "../Interfaces/IGovernance.sol";
import "../Governance/Governed.sol";

error Deposit__TransferFailed();

contract SimpleDeposit is Ownable, SystemRole, ReentrancyGuard, ISimpleDeposit, Governed
{
    IERC20 public _stakingToken;
    address public _affiliateContract;
    address public _feesContract;

    uint64 public lockTime = 2592000; //30 * 86400;

    IRegister private _registerContract;

    bool public whitelistingEnabled;

    mapping(address => uint256) private _approvalCount;

    mapping(address => AccountBalances) private accountBalances;

    uint256 public totalDeposits;
    uint256 public totalLocked;

    mapping(address => mapping(address => bool)) private approvedExternalAddresses;


     /**
     * @dev contract owner`s address
     */
    address private _owner;

    /**
     * @dev Constructor function
     */
    constructor(address _tokenAddress, address _governAddress) Ownable() {//address _register, address _affiliate, address _fees, address _governAddress) Ownable() {
        _stakingToken = IERC20(_tokenAddress);
        governanceState.governanceAddress = _governAddress;
    }

    function _selfManageMeBefore() internal override {
        address[] memory slots = IGovernance(governanceState.governanceAddress).read_config_address_slot("Main");
        _affiliateContract = slots[2];
        _feesContract = slots[3];
        _registerContract = IRegister(slots[4]);
        _affiliateContract = slots[2];
        if (_owner != slots[0]) _transferOwnership(slots[0]);
    }

    function _selfManageMeAfter() internal override {}
    function _onBeforeEmergencyChange(bool nextRunning) internal override {}

    /**
     * @dev transfer contract ownership
     */
    function transferOwnership(
        address newOwner
    ) public virtual override(Ownable, SystemRole) Live onlyOwner {
        _owner = newOwner;
        _transferOwnership(newOwner);
    }

    /**
     * @dev Function to change whitelist contract address
     * @param _register Address of whitelist contract
     */
    function changeRegister(address _register) external Live onlyOwner {
        _registerContract = IRegister(_register);
    }

    /**
     * @dev Function to change fees contract address
     * @param _fees Address of the fees contract
     */
    function changeFees(address _fees) external Live onlyOwner {
        _feesContract = _fees;
    }

    /**
     * @dev Function to change affiliate contract address
     * @param _affiliate Address of the affiliate contract
     */
    function changeAffiliate(address _affiliate) external Live onlyOwner {
        _affiliateContract = _affiliate;
    }

    /**
     * @dev Switch to enable/disable whitelisting
     */
    function setWhitelistingEnabled(bool enabled) external Live onlyOwner {
        if (enabled && !whitelistingEnabled) {
            whitelistingEnabled = true;
        } else if (!enabled && whitelistingEnabled) {
            whitelistingEnabled = false;
        }
    }

    function setLockTime(uint64 _time) external onlyOwner Live {
        lockTime = _time;
    }

    function _handleUserStakeChanged(address _user, address _referredBy, uint256 _amount) internal {
        if (_affiliateContract != address(0)) {
            IAffiliate(_affiliateContract).userStakeChanged(_user, _referredBy, _amount);
        }
        if (_feesContract != address(0)) {
            IFees(_feesContract).userStakeChanged(_user, _amount);
        }
    }

    function approveExternalAddress(address _locker) external Live {
        require(_locker != address(0), "Address not allowed");
        if (!_checkExternalAddress(msg.sender, _locker)) {
            approvedExternalAddresses[msg.sender][_locker] = true;
            unchecked{_approvalCount[msg.sender] += 1;}
        }
    }

    function disapproveExternalAddress(address _locker) external Live {
        if(approvedExternalAddresses[msg.sender][_locker] == true){
            approvedExternalAddresses[msg.sender][_locker] = false;
            _approvalCount[msg.sender] -= 1;
        }
    }

    function isApprovedExternalAddress(address _account, address _locker) external view returns (bool isApproved) {
        return _checkExternalAddress(_account, _locker);
    }

    function _checkExternalAddress(address _account, address _locker) internal view returns (bool isApproved) {
        return approvedExternalAddresses[_account][_locker];
    }

    /**
     * @dev Function to Deposit tokens.
     * Transfer tokens from the user to the contract
     * @param _amount Amount of tokens to deposit
     **/
    function deposit(uint256 _amount) external nonReentrant Live {
        _deposit(msg.sender, msg.sender, _amount);
    }

    function depositTo(address _recipient, uint256 _amount) external nonReentrant Live {
        _deposit(msg.sender, _recipient, _amount);
    }

    /**
     * @dev Function to Withdraw tokens.
     * Transfer tokens from the contract to the user
     * @param _amount Amount of tokens to withdraw
     **/

    function withdraw(uint256 _amount) external nonReentrant Live {
        _withdraw(msg.sender, _amount);
    }

    // locks user deposit in the contract - the user calls it
    function userLock(uint256 _amount) external nonReentrant Live {
        _userLock(msg.sender, _amount, address(0));
    }

    // locks user deposit in the contract - the user calls it
    function userLock(uint256 _amount, address _referredBy) external nonReentrant Live {
        _userLock(msg.sender, _amount, _referredBy);
    }

    // unlocks user deposit in the contract - the user calls it, it can ulock user locked funds
    function userUnlock(uint256 _amount) external nonReentrant Live {
        _userUnlock(msg.sender, _amount);
    }

    function depositAndLock(uint256 _amount) external nonReentrant Live {
        _deposit(msg.sender, msg.sender, _amount);
        _userLock(msg.sender, _amount, address(0));
    }

    function depositAndLock(uint256 _amount, address _referredBy) external nonReentrant Live {
        _deposit(msg.sender, msg.sender, _amount);
        _userLock(msg.sender, _amount, _referredBy);
    }

    function unlockAndWithdraw(uint256 _amount) external nonReentrant Live {
        _userUnlock(msg.sender, _amount);
        _withdraw(msg.sender, _amount);
    }

    // locks user deposit in the contract - called by allowed external contracts
    // we can add other params like deadline etc for more complex locks like originally
    function externalLock(address _account, uint256 _amount) external nonReentrant onlyDepositLocker Live {
        _externalLock(msg.sender, _account, _amount);
    }

    // unlocks user deposit in the contract - called by allowed external contracts
    function externalUnlock(address _account, uint256 _amount) external nonReentrant onlyDepositLocker Live {
        _externalUnlock(msg.sender, _account, _amount);
    }

    function getLockTime() external view returns (uint256 time) {
        return lockTime;
    }

    /**
     * @dev Function to get user balance.
     * @param _account Account for balance
     * @return _accountBalance Account Balance
     **/
    function getAccountBalance(
        address _account
    ) external view returns (uint256 _accountBalance) {
        return accountBalances[_account].balance;
    }

    function getAccountBalances(address _account) external view returns (AccountBalances memory _accountBalance) {
        _accountBalance = accountBalances[_account];
        _accountBalance.unlockTimestamp = _accountBalance.lastLockTimestamp + lockTime;
    }

    function getAccountLockedBalanceUnlockTimestamp(address _account) external view returns (uint256 _timestmap) {
        return accountBalances[_account].lastLockTimestamp + lockTime;
    }

    function getWithdrawableAccountLockedBalance(address _account) external view returns (uint256 amount) {
        if (accountBalances[_account].lastLockTimestamp + lockTime > block.timestamp) return 0;
        return accountBalances[_account].lockedBalance;
    }

    function getAccountLockedBalance(
        address _account
    ) external view returns (uint256 _accountBalance) {
        return accountBalances[_account].lockedBalance;
    }
    function getExternalLockedBalance(
        address _account
    ) external view returns (uint256 _accountBalance) {
        return accountBalances[_account].externalLockedBalance;
    }

    // we can add emit
    function _deposit(address _sender, address _user, uint256 _amount) internal {
        require(_amount > 0, "Amount needs to be more then 0!");

        if (whitelistingEnabled == true) {
            require(
                _registerContract.isWhitelisted(_user) == true,
                "Caller is not whitelisted!"
            );
        }

        bool successTransfer = _stakingToken.transferFrom(
            _sender,
            address(this),
            _amount
        );

        if (!successTransfer) {
            revert Deposit__TransferFailed();
        }

        accountBalances[_user].balance = accountBalances[_user].balance + _amount;
        totalDeposits = totalDeposits + _amount;

        emit DepositCreated(_user, _amount, block.timestamp, totalDeposits, accountBalances[_user].balance);
    }

    function _withdraw(address _user,uint256 _amount) internal {
        require(_amount > 0, "Amount needs to be more then 0!");
        require(
            _amount <= (accountBalances[msg.sender].balance),
            "Amount is higher then available balance!"
        );


        accountBalances[msg.sender].balance = accountBalances[msg.sender].balance - _amount;
        totalDeposits = totalDeposits - _amount;

        bool successTransfer = _stakingToken.transfer(_user, _amount);
        if (!successTransfer) {
            revert Deposit__TransferFailed();
        }

        emit DepositWithdrawn(
            _user,
            _amount,
            block.timestamp,
            totalDeposits,
            accountBalances[_user].balance
        );
    }

    function _userLock(address _user, uint256 _amount, address _referredBy) internal {
        require(accountBalances[_user].balance >= _amount, "NOT ENOUGH BALANCE");
        accountBalances[_user].balance -= _amount;
        accountBalances[_user].lockedBalance += _amount;
        accountBalances[_user].lastLockTimestamp = uint64(block.timestamp);
        totalLocked += _amount;
        _handleUserStakeChanged(_user, _referredBy, accountBalances[_user].lockedBalance);

        emit DepositLocked(
            _user,
            _amount,
            block.timestamp,
            block.timestamp + lockTime,
            totalLocked,
            accountBalances[_user].lockedBalance
        );
    }

    function _userUnlock(address _account, uint256 _amount) internal {
        require(accountBalances[_account].lockedBalance >= _amount, "NOT ENOUGH BALANCE"); require(
        accountBalances[_account].lastLockTimestamp + lockTime < uint64(block.timestamp),
            "DEPOSIT LOCKED"
        );
        accountBalances[_account].balance += _amount;
        accountBalances[_account].lockedBalance -= _amount;
        totalLocked -= _amount;
        _handleUserStakeChanged(_account, address(0), accountBalances[_account].lockedBalance);

        emit DepositUnlocked(
            msg.sender,
            _amount,
            block.timestamp,
            totalLocked,
            accountBalances[_account].lockedBalance
        );
    }

    function _externalLock(address _locker, address _account, uint256 _amount) internal {
        require(accountBalances[_account].balance >= _amount, "NOT ENOUGH BALANCE");
        require(_checkExternalAddress(_account, _locker) == true, "Address not approved");
        accountBalances[_account].balance -= _amount;
        accountBalances[_account].externalLockedBalance += _amount;
        emit ExternalLocked(_locker, msg.sender, _amount, uint64(block.timestamp));
    }

    function _externalUnlock(address _locker, address _account, uint256 _amount) internal {
        require(accountBalances[_account].externalLockedBalance >= _amount, "NOT ENOUGH BALANCE");
        require(_checkExternalAddress(_account, _locker) == true, "Address not approved");
        accountBalances[_account].balance += _amount;
        accountBalances[_account].externalLockedBalance -= _amount;
        emit ExternalUnlocked(_locker, msg.sender, _amount, uint64(block.timestamp));
    }
}
// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.17;

/**
 * @title Mosaic Alpha Governance contract
 * @author dlabs.hu
 * @dev This contract is for handling governance and configuration changes
 */

import "../Interfaces/IVault.sol";
import "../Interfaces/IAffiliate.sol";
import "../Interfaces/IGoverned.sol";

contract Governance {

mapping(address => uint256) public curator_proportions;                             // Proportions of the curators
address[] public governedContracts;                                                 // The governed addresses

/* ConfManager system mappings and vars */
mapping(string => config_struct) public Configuration;
mapping(string => config_struct) public invoteConfiguration;
mapping(uint256 => string) public ID_to_name;

mapping(address => uint256) public conf_curator_timer;                           // Last action time by curator for locking
mapping(uint256 => uint256) public conf_votes;                                   // ID to see if threshold is passed
mapping(uint256 => uint256) public conf_time_limit;                              // Actions needs to be triggered in time
uint256 public conf_counter = 6;                                                 // Starting from 6+1, 0-6 are reserved for global config

struct config_struct {
  string name;
  bool Running;
  address govaddr;
  address[] managers;
  bool[] boolslot;
  address[] address_slot;
  uint256[] uint256_slot;
  bytes32[] bytes32_slot;
}

mapping(uint256 => bool) public triggered;                                          // If true, it was triggered before and will be blocked
string constant Core = "Main";                                                               // Core string for consistency

/* Action manager system mappings */
mapping(address => uint256) public action_curator_timer;                            // Last action time by curator for locking
mapping(uint256 => uint256) public action_id_to_vote;                               // ID to see if threshold is passed
mapping(uint256 => uint256) public action_time_limit;                               // Actions needs to be triggered in time
mapping(uint256 => address) public action_can_be_triggered_by;                      // Address which can trigger the action after threshold is passed

/* This is used to store calldata and make it takeable from external contracts.
@dev be careful with this, low level calls can be tricky. */
mapping(uint256 => bytes) public action_id_to_calldata;                             // Mapping actions to relevant calldata.

// Action threshold and time limit, so the community can react to changes
uint256 public action_threshold;                                                    // This threshold needs to be passed for action to happen
uint256 public vote_time_threshold;                                                 // You can only vote once per timer - this is for security and gas optimization
uint256 public vote_conf_time_threshold;                                            // Config

event Transfer_Proportion(uint256 beneficiary_proportion);
event Action_Proposed(uint256 id);
event Action_Support(uint256 id);
event Action_Trigger(uint256 id);
event Config_Proposed(string name);
event Config_Supported(string name);

modifier onlyCurators(){
  require(curator_proportions[msg.sender] > 0, "Not a curator");
  _;
}

// The Governance contract needs to be deployed first, before all
// Max proportions are 100, shared among curators
 constructor(
    address[] memory _curators,
    uint256[] memory _curator_proportions,
    address[] memory _managers
) {
    action_threshold = 30;                                        // Threshold -> from this, configs and actions can be triggered
    vote_time_threshold = 600;                                    // Onc conf change per 10 mins, in v2 we can make it longer
    vote_conf_time_threshold = 0;

    require(_curators.length == _curator_proportions.length, "Curators and proportions length mismatch");

    uint totalProp;
    for (uint256 i = 0; i < _curators.length; i++) {
        curator_proportions[_curators[i]] = _curator_proportions[i];
        totalProp += _curator_proportions[i];
    }

    require(totalProp == 100, "Total proportions must be 100");

    ID_to_name[0] = Core;                                         // Core config init
    core_govAddr_conf(address(this));                             // Global governance address
    core_emergency_conf();                                        // Emergency stop value is enforced to be Running==true from start.
    core_managers_conf(_managers);
}

// Core functions, only used during init
function core_govAddr_conf(address _address) private {
    Configuration[Core].name = Core;
    Configuration[Core].govaddr = _address;}

function core_emergency_conf() private {
    Configuration[Core].Running = true;}

function core_managers_conf(address[] memory _addresses) private {
    Configuration[Core].managers = _addresses;
    address[] storage addGovAddr = Configuration[Core].managers; // Constructor memory -> Storage
    addGovAddr.push(address(this));
    Configuration[Core].managers = addGovAddr;
    }

// Only the addresses on the manager list are allowed to execute
function onlyManagers() internal view {
      bool ok;
          address [] memory tempman =  read_core_managers();
          for (uint i=0; i < tempman.length; i++) {
              if (tempman[i] == msg.sender) {ok = true;}
          }
          if (ok == true){} else {revert("0");} //Not manager*/
}

bool public deployed = false;
function setToDeployed() public returns (bool) {
  onlyManagers();
  deployed = true;
  return deployed;
}

function ActivateDeployedMosaic(
    address _userProfile,
    address _affiliate,
    address _fees,
    address _register,
    address _poolFactory,
    address _feeTo,
    address _swapsContract,
    address _oracle,
    address _deposit,
    address _burner,
    address _booster
) public {
    onlyManagers();
    require(deployed == false, "It is done.");

        Configuration[Core].address_slot.push(msg.sender); //0 owner
        Configuration[Core].address_slot.push(_userProfile); //1
        Configuration[Core].address_slot.push(_affiliate); //2
        Configuration[Core].address_slot.push(_fees); //3
        Configuration[Core].address_slot.push(_register); //4
        Configuration[Core].address_slot.push(_poolFactory); //5
        Configuration[Core].address_slot.push(_feeTo); //6 - duplicate? fees and feeToo are same?
        Configuration[Core].address_slot.push(_swapsContract); //7
        Configuration[Core].address_slot.push(_oracle); //8
        Configuration[Core].address_slot.push(_deposit); //9
        Configuration[Core].address_slot.push(_burner); //10
        Configuration[Core].address_slot.push(_booster); //11

        IAffiliate(_affiliate).selfManageMe();
}

/* Transfer proportion */
function transfer_proportion(address _address, uint256 _amount) external returns (uint256) {
    require(curator_proportions[msg.sender] >= _amount, "Not enough proportions");
    require(block.timestamp >= action_curator_timer[msg.sender] + vote_time_threshold, "Not yet, your votes need to conclude");
    action_curator_timer[msg.sender] = block.timestamp;
    curator_proportions[msg.sender] = curator_proportions[msg.sender] - _amount;
    curator_proportions[_address] = curator_proportions[_address] + _amount;
    emit Transfer_Proportion(curator_proportions[_address]);
    return curator_proportions[_address];
  }

/* Configuration manager */

// Add or update config.
function update_config(string memory _name,
  bool _Running,
  address _govaddr,
  address[] memory _managers,
  bool[] memory _boolslot,
  address[] memory _address_slot,
  uint256[] memory _uint256_slot,
  bytes32[] memory _bytes32_slot
  ) internal returns (string memory){
  Configuration[_name].name = _name;
  Configuration[_name].Running = _Running;
  Configuration[_name].govaddr = _govaddr;
  Configuration[_name].managers = _managers;
  Configuration[_name].boolslot = _boolslot;
  Configuration[_name].address_slot = _address_slot;
  Configuration[_name].uint256_slot = _uint256_slot;
  Configuration[_name].bytes32_slot = _bytes32_slot;
  return _name;
}

// Create temp configuration
function votein_config(string memory _name,
  bool _Running,
  address _govaddr,
  address[] memory _managers,
  bool[] memory _boolslot,
  address[] memory _address_slot,
  uint256[] memory _uint256_slot,
  bytes32[] memory _bytes32_slot
) internal returns (string memory){
  invoteConfiguration[_name].name = _name;
  invoteConfiguration[_name].Running = _Running;
  invoteConfiguration[_name].govaddr = _govaddr;
  invoteConfiguration[_name].managers = _managers;
  invoteConfiguration[_name].boolslot = _boolslot;
  invoteConfiguration[_name].address_slot = _address_slot;
  invoteConfiguration[_name].uint256_slot = _uint256_slot;
  invoteConfiguration[_name].bytes32_slot = _bytes32_slot;
  return _name;
}

// Propose config
function propose_config(
  string memory _name,
  bool _Running,
  address _govaddr,
  address[] memory _managers,
  bool[] memory _boolslot,
  address[] memory _address_slot,
  uint256[] memory _uint256_slot,
  bytes32[] memory _bytes32_slot
) external returns (uint256) {
    require(curator_proportions[msg.sender] > 0, "You are not a curator");
    require(block.timestamp >= conf_curator_timer[msg.sender] + vote_conf_time_threshold, "Curator timer not yet expired");
    conf_counter = conf_counter + 1;
    require(conf_time_limit[conf_counter] == 0, "In progress");
    conf_curator_timer[msg.sender] = block.timestamp;
    conf_time_limit[conf_counter] = block.timestamp + vote_time_threshold;
    conf_votes[conf_counter] = curator_proportions[msg.sender];
    ID_to_name[conf_counter] = _name;
    triggered[conf_counter] = false; // It keep rising, so can't be overwritten from true in past value
    votein_config(
        _name,
        _Running,
        _govaddr,
        _managers,
        _boolslot,
        _address_slot,
        _uint256_slot,
        _bytes32_slot
    );
    emit Config_Proposed(_name);
    return conf_counter;
  }

// Use this with caution!
function propose_core_change(address _govaddr, bool _Running, address[] memory _managers, address[] memory _owners) external returns (uint256) {
    require(curator_proportions[msg.sender] > 0, "You are not a curator");
    require(block.timestamp >= conf_curator_timer[msg.sender] + vote_conf_time_threshold, "Curator timer not yet expired");
    require(conf_time_limit[conf_counter] == 0, "In progress");
    conf_curator_timer[msg.sender] = block.timestamp;
    conf_time_limit[conf_counter] = block.timestamp + vote_time_threshold;
    conf_votes[conf_counter] = curator_proportions[msg.sender];
    ID_to_name[conf_counter] = Core;
    triggered[conf_counter] = false; // It keep rising, so can't be overwritten from true in past value

    invoteConfiguration[Core].name = Core;
    invoteConfiguration[Core].govaddr = _govaddr;
    invoteConfiguration[Core].Running = _Running;
    invoteConfiguration[Core].managers = _managers;
    invoteConfiguration[Core].address_slot = _owners;
    return conf_counter;
}

// ID and name are requested together for supporting a config because of awareness.
function support_config_proposal(uint256 _confCount, string memory _name) external returns (string memory) {
  require(curator_proportions[msg.sender] > 0, "You are not a curator");
  require(block.timestamp >= conf_curator_timer[msg.sender] + vote_conf_time_threshold, "Curator timer not yet expired");
  require(conf_time_limit[_confCount] > block.timestamp, "Timed out");
  require(conf_time_limit[_confCount] != 0, "Not started");
  require(keccak256(abi.encodePacked(ID_to_name[_confCount])) == keccak256(abi.encodePacked(_name)), "You are not aware, Neo.");
  conf_curator_timer[msg.sender] = block.timestamp;
  conf_votes[_confCount] = conf_votes[_confCount] + curator_proportions[msg.sender];
  if (conf_votes[_confCount] >= action_threshold && triggered[_confCount] == false) {
    triggered[_confCount] = true;
    string memory name = ID_to_name[_confCount];
    update_config(
    invoteConfiguration[name].name,
    invoteConfiguration[name].Running,
    invoteConfiguration[name].govaddr,
    invoteConfiguration[name].managers,
    invoteConfiguration[name].boolslot,
    invoteConfiguration[name].address_slot,
    invoteConfiguration[name].uint256_slot,
    invoteConfiguration[name].bytes32_slot
    );

    delete invoteConfiguration[name].name;
    delete invoteConfiguration[name].Running;
    delete invoteConfiguration[name].govaddr;
    delete invoteConfiguration[name].managers;
    delete invoteConfiguration[name].boolslot;
    delete invoteConfiguration[name].address_slot;
    delete invoteConfiguration[name].uint256_slot;
    delete invoteConfiguration[name].bytes32_slot;

    conf_votes[_confCount] = 0;
  }
  emit Config_Supported(_name);
  return Configuration[_name].name = _name;
}

/* Read configurations */

function read_core_Running() public view returns (bool) {return Configuration[Core].Running;}
function read_core_govAddr() public view returns (address) {return Configuration[Core].govaddr;}
function read_core_managers() public view returns (address[] memory) {return Configuration[Core].managers;}
function read_core_owners() public view returns (address[] memory) {return Configuration[Core].address_slot;}

function read_config_Main_addressN(uint256 _n) public view returns (address) {
  return Configuration["Main"].address_slot[_n];
}

// Can't read full because of stack too deep limit
function read_config_core(string memory _name) public view returns (
  string memory,
  bool,
  address,
  address[] memory){
  return (
  Configuration[_name].name,
  Configuration[_name].Running,
  Configuration[_name].govaddr,
  Configuration[_name].managers);}
function read_config_name(string memory _name) public view returns (string memory) {return Configuration[_name].name;}
function read_config_emergencyStatus(string memory _name) public view returns (bool) {return Configuration[_name].Running;}
function read_config_governAddress(string memory _name) public view returns (address) {return Configuration[_name].govaddr;}
function read_config_Managers(string memory _name) public view returns (address[] memory) {return Configuration[_name].managers;}

function read_config_bool_slot(string memory _name) public view returns (bool[] memory) {return Configuration[_name].boolslot;}
function read_config_address_slot(string memory _name) public view returns (address[] memory) {return Configuration[_name].address_slot;}
function read_config_uint256_slot(string memory _name) public view returns (uint256[] memory) {return Configuration[_name].uint256_slot;}
function read_config_bytes32_slot(string memory _name) public view returns (bytes32[] memory) {return Configuration[_name].bytes32_slot;}

function read_config_Managers_batched(string memory _name, uint256[] memory _ids) public view returns (address[] memory) {
    address[] memory result = new address[](_ids.length);
    for (uint256 i = 0; i < _ids.length; i++) {
        result[i] = Configuration[_name].managers[_ids[i]];
    }
    return result;
}

function read_config_bool_slot_batched(string memory _name, uint256[] memory _ids) public view returns (bool[] memory) {
    bool[] memory result = new bool[](_ids.length);
    for (uint256 i = 0; i < _ids.length; i++) {
        result[i] = Configuration[_name].boolslot[_ids[i]];
    }
    return result;
}

function read_config_address_slot_batched(string memory _name, uint256[] memory _ids) public view returns (address[] memory) {
    address[] memory result = new address[](_ids.length);
    for (uint256 i = 0; i < _ids.length; i++) {
        result[i] = Configuration[_name].address_slot[_ids[i]];
    }
    return result;
}

function read_config_uint256_slot_batched(string memory _name, uint256[] memory _ids) public view returns (uint256[] memory) {
    uint256[] memory result = new uint256[](_ids.length);
    for (uint256 i = 0; i < _ids.length; i++) {
        result[i] = Configuration[_name].uint256_slot[_ids[i]];
    }
    return result;
}

function read_config_bytes32_slot_batched(string memory _name, uint256[] memory _ids) public view returns (bytes32[] memory) {
    bytes32[] memory result = new bytes32[](_ids.length);
    for (uint256 i = 0; i < _ids.length; i++) {
        result[i] = Configuration[_name].bytes32_slot[_ids[i]];
    }
    return result;
}


// Read invote configuration
// Can't read full because of stack too deep limit
function read_invoteConfig_core(string calldata _name) public view returns (
  string memory,
  bool,
  address,
  address[] memory){
  return (
  invoteConfiguration[_name].name,
  invoteConfiguration[_name].Running,
  invoteConfiguration[_name].govaddr,
  invoteConfiguration[_name].managers);}
function read_invoteConfig_name(string memory _name) public view returns (string memory) {return invoteConfiguration[_name].name;}
function read_invoteConfig_emergencyStatus(string memory _name) public view returns (bool) {return invoteConfiguration[_name].Running;}
function read_invoteConfig_governAddress(string memory _name) public view returns (address) {return invoteConfiguration[_name].govaddr;}
function read_invoteConfig_Managers(string memory _name) public view returns (address[] memory) {return invoteConfiguration[_name].managers;}
function read_invoteConfig_boolslot(string memory _name) public view returns (bool[] memory) {return invoteConfiguration[_name].boolslot;}
function read_invoteConfig_address_slot(string memory _name) public view returns (address[] memory) {return invoteConfiguration[_name].address_slot;}
function read_invoteConfig_uint256_slot(string memory _name) public view returns (uint256[] memory) {return invoteConfiguration[_name].uint256_slot;}
function read_invoteConfig_bytes32_slot(string memory _name) public view returns (bytes32[] memory) {return invoteConfiguration[_name].bytes32_slot;}


/* Action manager system */

// Propose an action, regardless of which contract/address it resides in
function propose_action(uint256 _id, address _trigger_address, bytes memory _calldata) external returns (uint256) {
    require(curator_proportions[msg.sender] > 0, "You are not a curator");
    require(action_id_to_calldata[_id].length == 0, "Calldata already set");
    require(action_time_limit[_id] == 0, "Create a new one");
    require(block.timestamp >= action_curator_timer[msg.sender] + vote_time_threshold, "Not yet");
    action_curator_timer[msg.sender] = block.timestamp;
    action_time_limit[_id] = block.timestamp + vote_time_threshold;
    action_can_be_triggered_by[_id] = _trigger_address;
    action_id_to_vote[_id] = curator_proportions[msg.sender];
    action_id_to_calldata[_id] = _calldata;
    triggered[_id] = false;
    emit Action_Proposed(_id);
    return _id;
  }

// Support an already submitted action
function support_actions(uint256 _id) external returns (uint256) {
    require(curator_proportions[msg.sender] > 0, "You are not a curator");
    require(block.timestamp >= action_curator_timer[msg.sender] + vote_time_threshold, "Not yet");
    require(action_time_limit[_id] > block.timestamp, "Action timed out");
    action_curator_timer[msg.sender] = block.timestamp;
    action_id_to_vote[_id] = action_id_to_vote[_id] + curator_proportions[msg.sender];
    emit Action_Support(_id);
    return _id;
  }

// Trigger action by allowed smart contract address
// Only returns calldata, does not guarantee execution success! Triggerer is responsible, choose wisely.
function trigger_action(uint256 _id) external returns (bytes memory) {
    require(action_id_to_vote[_id] >= action_threshold, "Threshold not passed");
    require(action_time_limit[_id] > block.timestamp, "Action timed out");
    require(action_can_be_triggered_by[_id] == msg.sender, "You are not the triggerer");
    require(triggered[_id] == false, "Already triggered");
    triggered[_id] = true;
    action_id_to_vote[_id] = 0;
    emit Action_Trigger(_id);
    return action_id_to_calldata[_id];
}

/* Pure function for generating signatures */
function generator(string memory _func) public pure returns (bytes memory) {
        return abi.encodeWithSignature(_func);
    }

/* Execution and mass config updates */

/* Update contracts address list */
function update_All(address [] memory _addresses) external onlyCurators returns (address [] memory) {
  governedContracts = _addresses;
  return governedContracts;
}

/* Update all contracts from address list */
function selfManageMe_All() external onlyCurators {
  for (uint256 i = 0; i < governedContracts.length; i++) {
    _execute_Manage(governedContracts[i]);
  }
}

/* Execute external contract call: selfManageMe() */
function execute_Manage(address _contractA) external onlyCurators {
    _execute_Manage(_contractA);
}

function _execute_Manage(address _contractA) internal {
    require(_contractA != address(this),"You can't call Governance on itself");
    IGoverned(_contractA).selfManageMe();
}

/* Execute external contract call: selfManageMe() */
function execute_batch_Manage(address[] calldata _contracts) external onlyCurators {
  for (uint i; i < _contracts.length; i++) {
    _execute_Manage(_contracts[i]);
  }
}

/* Execute external contract calls with any string */
function execute_ManageBytes(address _contractA, string calldata _call, bytes calldata _data) external onlyCurators {
  _execute_ManageBytes(_contractA, _call, _data);
}

function execute_batch_ManageBytes(address[] calldata _contracts, string[] calldata _calls, bytes[] calldata _datas) external onlyCurators {
  require(_contracts.length == _calls.length, "Governance: _conracts and _calls length does not match");
  require(_calls.length == _datas.length, "Governance: _calls and _datas length does not match");
  for (uint i; i < _contracts.length; i++) {
    _execute_ManageBytes(_contracts[i], _calls[i], _datas[i]);
  }
}

function _execute_ManageBytes(address _contractA, string calldata _call, bytes calldata _data) internal {
  require(_contractA != address(this),"You can't call Governance on itself");
  require(bytes(_call).length == 0 || bytes(_call).length >=3, "provide a valid function specification");

  for (uint256 i = 0; i < bytes(_call).length; i++) {
    require(bytes(_call)[i] != 0x20, "No spaces in fun please");
  }

  bytes4 signature;
  if (bytes(_call).length != 0) {
      signature = (bytes4(keccak256(bytes(_call))));
  } else {
      signature = "";
  }

  (bool success, bytes memory retData) = _contractA.call(abi.encodePacked(signature, _data));
  _evaluateCallReturn(success, retData);
}

/* Execute external contract calls with address array */
function execute_ManageList(address _contractA, string calldata _funcName, address[] calldata address_array) external onlyCurators {
  require(_contractA != address(this),"You can't call Governance on itself");
  (bool success, bytes memory retData) = _contractA.call(abi.encodeWithSignature(_funcName, address_array));
  _evaluateCallReturn(success, retData);
}

/* Update Vault values */
function execute_Vault_update(address _vaultAddress) external onlyCurators {
  IVault(_vaultAddress).selfManageMe();
}

function _evaluateCallReturn(bool success, bytes memory retData) internal pure {
    if (!success) {
      if (retData.length >= 68) {
          bytes memory reason = new bytes(retData.length - 68);
          for (uint i = 0; i < reason.length; i++) {
              reason[i] = retData[i + 68];
          }
          revert(string(reason));
      } else revert("Governance: FAILX");
  }
}
}
// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.17;

/**
 * @title Mosaic Alpha Governed base contract
 * @author dlabs.hu
 * @dev This contract is base for contracts governed by Governance
 */

import "./Governance.sol";
import "../Interfaces/IGovernance.sol";
import "../Interfaces/IGoverned.sol";

abstract contract Governed is IGoverned {
    GovernanceState internal governanceState;

    constructor() {
      governanceState.running = true;
      governanceState.governanceAddress = address(this);
    }

    function getGovernanceState() public view returns (GovernanceState memory govState) {
      return governanceState;
    }

    // Modifier responsible for checking if emergency stop was triggered, default is Running == true
    modifier Live {
        LiveFun();
        _;
    }

    modifier notLive {
        notLiveFun();
        _;
    }


    error Governed__EmergencyStopped();
    function LiveFun() internal virtual view {
        if (!governanceState.running) revert Governed__EmergencyStopped();
    }

    error Governed__NotStopped();
    function notLiveFun() internal virtual view {
        if (governanceState.running) revert Governed__NotStopped();
    }

    modifier onlyManagers() {
        onlyManagersFun();
        _;
    }

    error Governed__NotManager(address caller);
    function onlyManagersFun() internal virtual view {
        if (!isManagerFun(msg.sender)) revert Governed__NotManager(msg.sender);
    }


    function isManagerFun(address a) internal virtual view returns (bool) {
        if (a == governanceState.governanceAddress) {
            return true;
        }
        for (uint i=0; i < governanceState.managers.length; i++) {
            if (governanceState.managers[i] == a) {
                return true;
            }
        }
        return false;
    }

    function selfManageMe() external virtual {
        onlyManagersFun();
        LiveFun();
        _selfManageMeBefore();
        address governAddress = governanceState.governanceAddress;
        bool nextRunning = IGovernance(governAddress).read_core_Running();
        if (governanceState.running != nextRunning) _onBeforeEmergencyChange(nextRunning);
        governanceState.running = nextRunning;
        governanceState.managers = IGovernance(governAddress).read_core_managers();               // List of managers
        governanceState.governanceAddress = IGovernance(governAddress).read_core_govAddr();
        _selfManageMeAfter();
    }

    function _selfManageMeBefore() internal virtual;
    function _selfManageMeAfter() internal virtual;
    function _onBeforeEmergencyChange(bool nextRunning) internal virtual;
}
// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.17;

interface ISystemRole {
    function checkSystemAdmin(address _account) external view returns (bool);
    function checkTrader(address _account) external view returns (bool);
    function checkInvestor(address _account) external view returns (bool);
    function checkDepositLocker(address _account) external view returns (bool);
    function checkAdmin(address _account) external view returns (bool);
}// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.17;

/**
 * @title Mosaic Alpha SystemRole contract
 * @author dlabs.hu
 * @dev This contract is base for enumerating roles
 */

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./ISystemRole.sol";

contract SystemRole is AccessControl, Ownable, ISystemRole {
    bytes32 public constant SYSTEM_ADMIN_ROLE = keccak256("SYSTEM_ADMIN_ROLE");
    bytes32 public constant MANAGER_ROLE = keccak256("MANAGER_ROLE");
    bytes32 public constant TRADER_ROLE = keccak256("TRADER_ROLE");
    bytes32 public constant INVESTOR_ROLE = keccak256("INVESTOR_ROLE");
    bytes32 public constant DEPOSIT_LOCKER_ROLE = keccak256("DEPOSIT_LOCKER_ROLE");

    modifier onlyAdmin() {
        require(_isAdmin(_msgSender()), "Ownable: caller is not Admin");
        _;
    }

    modifier onlySystemAdmin() {
        require(_isSystemAdmin(_msgSender()), "Ownable: caller is not SysAdmin");
        _;
    }

    modifier onlyTrader() {
        require(_isTrader(_msgSender()), "Ownable: caller is not Trader");
        _;
    }

    modifier onlyInvestor() {
        require(_isInvestor(_msgSender()), "Ownable: caller is not Investor");
        _;
    }

    modifier onlyDepositLocker() {
        require(_isDepositLocker(_msgSender()), "Ownable: caller is not Deposit Locker");
        _;
    }


    /**
     * @dev contract owner`s address
     */
    address private _owner;

    /**
     * @dev sender address is owner of the contract and gets ADMIN role
     **/
    constructor() {
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
        _owner = msg.sender;
    }

    /**
     * @dev transfer contract ownership
     */
    function transferOwnership(address newOwner) public virtual override onlyOwner {
        _owner = newOwner;
    }

    /**
     * @dev Function can be called by Admin only.
     * Adds SYSTEM_ADMIN role to the address
     * @param _account The address that should get SYSTEM_ADMIN role
     **/
    function addSystemAdmin(address _account) public onlyAdmin {
        _grantRole(SYSTEM_ADMIN_ROLE, _account);
    }

    /**
     * @dev Function can be called by Admin only.
     * Removes SYSTEM_ADMIN role from the address
     * @param _account The address that should be revoked from SYSTEM_ADMIN role
     **/
    function removeSystemAdmin(address _account) public onlyAdmin {
        revokeRole(SYSTEM_ADMIN_ROLE, _account);
    }

    /**
     * @dev Function can be called by Admin only.
     * Adds TRADER role to the address
     * @param _account The address that should get TRADER role
     **/
    function addTrader(address _account) public onlyAdmin {
        _grantRole(TRADER_ROLE, _account);
    }

    /**
     * @dev Function can be called by Admin only.
     * Removes TRADER role from the address
     * @param _account The address that should be revoked TRADER role
     **/
    function removeTrader(address _account) public onlyAdmin {
        revokeRole(TRADER_ROLE, _account);
    }

    /**
     * @dev Function can be called by Admin only.
     * Adds INVESTOR role to the address
     * @param _account The address that should get INVESTOR role
     **/
    function addInvestor(address _account) public onlyAdmin {
        _grantRole(INVESTOR_ROLE, _account);
    }

    /**
     * @dev Function can be called by Admin only.
     * Removes INVESTOR role from the address
     * @param _account The address that should be revoked INVESTOR role
     **/
    function removeInvestor(address _account) public onlyAdmin {
        revokeRole(INVESTOR_ROLE, _account);
    }

    /**
     * @dev Function can be called by Admin only.
     * Adds DEPOSIT_LOCKER role to the address
     * @param _account The address that should get DEPOSIT_LOCKER role
     **/
    function addDepositLocker(address _account) public onlyAdmin {
        _grantRole(DEPOSIT_LOCKER_ROLE, _account);
    }

    /**
     * @dev Function can be called by Admin only.
     * Removes DEPOSIT_LOCKER role from the address
     * @param _account The address that should be revoked DEPOSIT_LOCKER role
     **/
    function removeDepositLocker(address _account) public onlyAdmin {
        revokeRole(DEPOSIT_LOCKER_ROLE, _account);
    }

    /**
     * @dev Function can be called by Admin only.
     * Adds ADMIN role to the address
     * @param _account The address that should get ADMIN role
     **/
    function addAdmin(address _account) public onlyAdmin {
        _setupRole(DEFAULT_ADMIN_ROLE, _account);
    }

    /**
     * @dev Function can be called by Admin only.
     * Removes ADMIN role from the address
     * @param _account The address that should be revoked from ADMIN role
     **/
    function removeAdmin(address _account) public onlyAdmin {
        revokeRole(DEFAULT_ADMIN_ROLE, _account);
    }

    function _isSystemAdmin(address _account) internal view virtual returns (bool) {
        return hasRole(SYSTEM_ADMIN_ROLE, _account);
    }

    function _isTrader(address _account) internal view virtual returns (bool) {
        return hasRole(TRADER_ROLE, _account);
    }

    function _isInvestor(address _account) internal view virtual returns (bool) {
        return hasRole(INVESTOR_ROLE, _account);
    }

    function _isAdmin(address _account) internal view virtual returns (bool) {
        return hasRole(DEFAULT_ADMIN_ROLE, _account);
    }

    function _isDepositLocker(address _account) internal view virtual returns (bool) {
        return hasRole(DEPOSIT_LOCKER_ROLE, _account);
    }

    function checkSystemAdmin(address _account) external view virtual returns (bool) {
        return _isSystemAdmin(_account);
    }

    function checkTrader(address _account) external view virtual returns (bool) {
        return _isTrader(_account);
    }

    function checkInvestor(address _account) external view virtual returns (bool) {
        return _isInvestor(_account);
    }

    function checkDepositLocker(address _account) external view virtual returns (bool) {
        return _isDepositLocker(_account);
    }

    function checkAdmin(address _account) external view virtual returns (bool) {
        return _isAdmin(_account);
    }
}
// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.17;

import "../Interfaces/IUserProfile.sol";
import "../Interfaces/IGoverned.sol";

interface IAffiliate is IGoverned {
    struct AffiliateLevel {
        uint8 rank;
        uint8 commissionLevels; // eligibility for how many levels affiliate comission
        uint16 referralBuyFeeDiscount; // buy fee disccount for the referrals refistering for the user - 10000 = 100%
        uint16 referralCountThreshold; // minimum amount of direct referrals needed for level
        uint16 stakingBonus;
        uint16 conversionRatio;
        uint32 claimLimit; // max comission per month claimable - in usd value, not xe18!
        uint256 kdxStakeThreshold; // minimum amount of kdx stake needed
        uint256 purchaseThreshold; // minimum amount of self basket purchase needed
        uint256 referralPurchaseThreshold; // minimum amount of referral basket purchase needed
        uint256 traderPurchaseThreshold; // minimum amount of user basket purchase (for traders) needed

        string rankName;
    }

    struct AffiliateUserData {
        uint32 affiliateRevision;
        uint32 activeReferralCount;
        uint256 userPurchase;
        uint256 referralPurchase;
        uint256 traderPurchase;
        uint256 kdxStake;
    }

    struct AffiliateConfig {
        uint16 level1RewardShare; // 0..10000. 6000 -> 60% of affiliate rewards go to level 1, 40% to level2
        uint240 activeReferralPurchaseThreshold; // the min amount of (usdt) purchase in wei to consider a referral active
    }

    function getCommissionLevelsForRanks(uint8 rank, uint8 rank2) external view returns (uint8 commissionLevels, uint8 commissionLevels2);

    function getLevelsAndConversionAndClaimLimitForRank(uint8 rank) external view returns (uint8 commissionLevels, uint16 conversionRatio, uint32 claimLimit);

    function getConfig() external view returns (AffiliateConfig memory config);

    // get the number of affiliate levels
    function getLevelCount() external view returns (uint256 count);

    function getLevelDetails(uint256 _idx) external view returns (AffiliateLevel memory level);

    function getAllLevelDetails() external view returns (AffiliateLevel[] memory levels);

    function getAffiliateUserData(address user) external view returns (AffiliateUserData memory data);

    function getUserPurchaseAmount(address user) external view returns (uint256 amount);

    function getReferralPurchaseAmount(address user) external view returns (uint256 amount);

    function userStakeChanged(address user, address referredBy, uint256 kdxAmount) external;

    function registerUserPurchase(address user, address referredBy, address trader, uint256 usdAmount) external;
    function registerUserPurchaseAsTokens(address user, address referredBy, address trader, address[] memory tokens, uint256[] memory tokenAmounts) external;

    event AffiliateConfigUpdated(AffiliateConfig _newConfig, AffiliateConfig config);

}// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.17;

import "../Interfaces/IGoverned.sol";

interface IFees is IGoverned {
    struct MosaicFeeRanges {
        uint16 buyFeeMin;          // 10000 = 100%
        uint16 buyFeeMax;
        uint16 trailingFeeMin;
        uint16 trailingFeeMax;
        uint16 performanceFeeMin;
        uint16 performanceFeeMax;
    }

    struct MosaicFeeDistribution {
        uint16 userBuyFeeDiscountMax;
        uint16 userTrailingFeeDiscountMax;
        uint16 userPerformanceFeeDiscountMax;
        uint16 traderBuyFeeShareMin;          // 10000 = 100%
        uint16 traderBuyFeeShareMax;
        uint16 traderTrailingFeeShareMin;
        uint16 traderTrailingFeeShareMax;
        uint16 traderPerformanceFeeShareMin;
        uint16 traderPerformanceFeeShareMax;
        uint16 affiliateBuyFeeShare;
        uint16 affiliateTrailingFeeShare;
        uint16 affiliatePerformanceFeeShare;
        uint16 affiliateTraderFeeShare;
        uint16 affiliateLevel1RewardShare; // 0..10000. 6000 -> 60% of affiliate rewards go to level 1, 40% to level2
    }

    struct MosaicPlatformFeeShares {
        uint8 executorShare;
        uint8 traderExecutorShare;
        uint8 userExecutorShare;
    }

    struct MosaicUserFeeLevels {
        //slot1
        bool parentsCached;
        uint8 levels;
        uint16 conversionRatio;
        uint32 traderRevenueShareLevel; // 10 ** 9 = 100%
        uint32 userFeeDiscountLevel; // 10 ** 9 = 100%
        address parent;
        // slot2
        address parent2;
        uint32 lastTime;
        uint32 level1xTime;
        uint32 level2xTime;
        // slot3
        uint64 userFeeDiscountLevelxTime;
        uint32 claimLimit;
        uint64 claimLimitxTime;

        //uint48 conversionRatioxTime;
    }

    struct BuyFeeDistribution {
        uint userRebateAmount;
        uint traderAmount;
        uint affiliateAmount;
        // remaining is system fee
    }

    struct TraderFeeDistribution {
        uint traderAmount;
        uint affiliateAmount;
        // remaining is system fee
    }

    struct MosaicPoolFees {
        uint16 buyFee;
        uint16 trailingFee;
        uint16 performanceFee;
    }

    struct PoolFeeStatus {
        uint256 claimableUserFeePerLp;
        uint256 claimableAffiliateL1FeePerLp;
        uint256 claimableAffiliateL2FeePerLp;
        uint128 claimableTotalFixedTraderFee;
        uint128 claimableTotalVariableTraderFee;
        uint128 feesContractSelfBalance;
    }

    struct UserPoolFeeStatus {
        uint32 lastClaimTime;
        uint32 lastLevel1xTime;
        uint32 lastLevel2xTime;
        //uint48 lastConversionRatioxTime;
        uint64 lastUserFeeDiscountLevelxTime;
        uint128 userDirectlyClaimableFee;
       // uint128 userAffiliateClaimableFee;
        uint128 userClaimableFee;
        uint128 userClaimableL1Fee;
        uint128 userClaimableL2Fee;
        uint128 traderClaimableFee;
        // uint128 balance;
        uint128 l1Balance;
        uint128 l2Balance;
        uint256 lastClaimableUserFeePerLp;
        uint256 lastClaimableAffiliateL1FeePerLp;
        uint256 lastClaimableAffiliateL2FeePerLp;
    }

    struct OnBeforeTransferPayload {
        uint128 feesContractBalanceBefore;
        uint128 trailingLpToMint;
        uint128 performanceLpToMint;
    }

    /** HOOKS **/
    /** UserProfile **/
    function userRankChanged(address _user, uint8 _level) external;

    /** Staking **/
    function userStakeChanged(address _user, uint256 _amount) external;

    /** Pool **/
    function allocateBuyFee(address _pool, address _buyer, address _trader, uint _buyFeeAmount) external;
    function allocateTrailingFee(address _pool, address _trader, uint _feeAmount, uint _totalSupplyBefore, address _executor) external;
    function allocatePerformanceFee(address _pool, address _trader, uint _feeAmount, uint _totalSupplyBefore, address _executor) external;
    function onBeforeTransfer(address _pool, address _from, address _to, uint _fromBalanceBefore, uint _toBalanceBefore, uint256 _amount, uint256 _totalSupplyBefore, address _trader, OnBeforeTransferPayload memory payload) external;
    function getFeeRanges() external view returns (MosaicFeeRanges memory fees);
    function getFeeDistribution() external view returns (MosaicFeeDistribution memory fees);
    function getUserFeeLevels(address user) external view returns (MosaicUserFeeLevels memory userFeeLevels);
    function isValidFeeRanges(MosaicFeeRanges calldata ranges) external view returns (bool valid);
    function isValidFeeDistribution(MosaicFeeDistribution calldata distribution) external view returns (bool valid);
    function isValidPoolFees(MosaicPoolFees calldata poolFees) external view returns (bool valid);
    function isValidBuyFee(uint16 fee) external view returns (bool valid);
    function isValidTrailingFee(uint16 fee) external view returns (bool valid);
    function isValidPerformanceFee(uint16 fee) external view returns (bool valid);

    function calculateBuyFeeDistribution(address user, address trader, uint feeAmount, uint16 buyFeeDiscount) external view returns (BuyFeeDistribution memory distribution);
    function calculateTraderFeeDistribution(uint amount) external view returns (TraderFeeDistribution memory distribution);
    function calculateTrailingFeeTraderDistribution(address trader, uint feeAmount) external view returns (uint amount);
    /** GETTERS **/
    // get the fee reduction percentage the user has achieved. 100% = 10 ** 9
    function getUserFeeDiscountLevel(address user) external view returns (uint32 level);

    // get the fee reduction percentage the user has achieved. 100% = 10 ** 9
    function getTraderRevenueShareLevel(address user) external view returns (uint32 level);

    event FeeRangesUpdated(MosaicFeeRanges newRanges, MosaicFeeRanges oldRanges);
    event FeeDistributionUpdated(MosaicFeeDistribution newRanges, MosaicFeeDistribution oldRanges);
    event PlatformFeeSharesUpdated(MosaicPlatformFeeShares newShares, MosaicPlatformFeeShares oldShares);
    event UserFeeLevelsChanged(address indexed user, MosaicUserFeeLevels newLevels);
    event PerformanceFeeAllocated(address pool, uint256 performanceExp);
    event TrailingFeeAllocated(address pool, uint256 trailingExp);
}// SPDX-License-Identifier: MIT LICENSE
pragma solidity ^0.8.17;

interface IGovernance {
    function propose_action(uint256 _id, address _trigger_address, bytes memory _calldata) external returns (uint256) ;
    function support_actions(uint256 _id) external returns (uint256) ;
    function trigger_action(uint256 _id) external returns (bytes memory) ;
    function transfer_proportion(address _address, uint256 _amount) external returns (uint256) ;

    function read_core_Running() external view returns (bool);
    function read_core_govAddr() external view returns (address);
    function read_core_managers() external view returns (address[] memory);
    function read_core_owners() external view returns (address[] memory);

    function read_config_core(string memory _name) external view returns (string memory);
    function read_config_emergencyStatus(string memory _name) external view returns (bool);
    function read_config_governAddress(string memory _name) external view returns (address);
    function read_config_Managers(string memory _name) external view returns (address [] memory);

    function read_config_bool_slot(string memory _name) external view returns (bool[] memory);
    function read_config_address_slot(string memory _name) external view returns (address[] memory);
    function read_config_uint256_slot(string memory _name) external view returns (uint256[] memory);
    function read_config_bytes32_slot(string memory _name) external view returns (bytes32[] memory);

    function read_invoteConfig_core(string memory _name) external view returns (string memory);
    function read_invoteConfig_name(string memory _name) external view returns (string memory);
    function read_invoteConfig_emergencyStatus(string memory _name) external view returns (bool);
    function read_invoteConfig_governAddress(string memory _name) external view returns (address);
    function read_invoteConfig_Managers(string memory _name) external view returns (address[] memory);
    function read_invoteConfig_boolslot(string memory _name) external view returns (bool[] memory);
    function read_invoteConfig_address_slot(string memory _name) external view returns (address[] memory);
    function read_invoteConfig_uint256_slot(string memory _name) external view returns (uint256[] memory);
    function read_invoteConfig_bytes32_slot(string memory _name) external view returns (bytes32[] memory);

    function propose_config(string memory _name, bool _bool_val, address _address_val, address[] memory _address_list, uint256 _uint256_val, bytes32 _bytes32_val) external returns (uint256);
    function support_config_proposal(uint256 _confCount, string memory _name) external returns (string memory);
    function generator() external pure returns (bytes memory);
}
// SPDX-License-Identifier: MIT LICENSE
pragma solidity ^0.8.17;

interface IGoverned {
    struct GovernanceState {
      bool running;
      address governanceAddress;
      address[] managers;
    }

    function selfManageMe() external;
}
// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.17;


// trader and pool register + whitelisted user register
interface IRegister {
    function isApprovedPool(uint32 _poolId) external view returns (bool approved);
    function isApprovedPool(address _poolAddr) external view returns (bool approved);
    function isApprovedTrader(address _user) external view returns (bool approved);

    function approvePools(address[] memory _poolIds) external;
    function approvePoolsById(uint32[] memory _poolIds) external;
    function approveTraders(address[] memory _traders) external;

    function revokePools(address[] memory _poolAddrs) external;
    function revokePoolsById(uint32[] memory _poolIds) external;
    function revokeTraders(address[] memory _traders) external;

    function removeWhitelist(address _address) external;
    function removeBlacklist(address _address) external;
    function addWhitelist(address _address) external;
    function addBlacklist(address _address) external;
    function addWhitelistBulk(address[] calldata _address) external;

    function isWhitelisted(address _address) external view returns(bool);
    function isBlacklisted(address _address) external view returns(bool);

    event PoolApproved(uint32 indexed poolId, address indexed poolAddr);
    event PoolRevoked(uint32 indexed poolId, address indexed poolAddr);

    event TraderApproved(address indexed trader);
    event TraderRevoked(address indexed trader);

    event WhitelistAdded(address _address);
    event WhitelistRemoved(address _address);
    event BlacklistAdded(address _address);
    event BlacklistRemoved(address _address);
}
// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.17;

interface ISimpleDeposit {

    struct AccountBalances {
        uint256 balance;
        uint256 lockedBalance;
        uint256 externalLockedBalance;
        uint64 lastLockTimestamp;
        uint64 unlockTimestamp;
    }

    function deposit(uint256 _amount) external;
    function depositTo(address _recipient, uint256 _amount) external;
    function withdraw(uint256 _amount) external;
    function userLock(uint256 _amount, address _referredBy) external;
    function userUnlock(uint256 _amount) external;
    function depositAndLock(uint256 _amount, address _referredBy) external;
    function unlockAndWithdraw(uint256 _amount) external;
    function externalLock(address _account, uint256 _amount) external;
    function externalUnlock(address _account, uint256 _amount) external;


    function getLockTime() external view returns (uint256 time);
    function getAccountBalances(address _account) external view returns (AccountBalances memory _accountBalance);
    function getAccountLockedBalanceUnlockTimestamp(address _account) external view returns (uint256 _timestmap);
    function getWithdrawableAccountLockedBalance(address _account) external view returns (uint256 _amount);
    function getAccountBalance(address _account) external view returns (uint256 _amount);
    function getAccountLockedBalance(address _account) external view returns (uint256 _amount);
    function getExternalLockedBalance(address _account) external view returns (uint256 _amount);

    function approveExternalAddress(address _locker) external;
    function disapproveExternalAddress(address _locker) external;

    // /**
    //  * @dev Events emitted
    //  */
    event DepositCreated(
        address indexed depositOwner,
        uint256 depositAmount,
        uint256 depositTime,
        uint256 totalBalance,
        uint256 clientBalance
    );

    event DepositWithdrawn(
        address indexed depositOwner,
        uint256 depositAmount,
        uint256 withdrawTime,
        uint256 totalBalance,
        uint256 clientBalance
    );

    event DepositLocked(
        address indexed depositOwner,
        uint256 lockAmount,
        uint256 lockTimeStart,
        uint256 lockTimeEnd,
        uint256 totalLocked,
        uint256 clientLocked
    );

    event DepositUnlocked(
        address indexed depositOwner,
        uint256 unlockAmount,
        uint256 unlockTime,
        uint256 totalLocked,
        uint256 clientLocked
    );

    event ExternalLocked(
        address indexed locker,
        address indexed owner,
        uint256 lockAmount,
        uint256 lockTimeStart
    );

    event ExternalUnlocked(
        address indexed locker,
        address indexed owner,
        uint256 unlockAmount,
        uint256 unlockTime
    );
}// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.17;

interface IUserProfile {

    struct UserProfile {                           /// Storage - We map the affiliated person to the affiliated_by person
        bool exists;
        uint8 rank;
        uint8 referredByRank;                       /// Rank of referrer at transaction time
        uint16 buyFeeDiscount;                            /// buy discount - 10000 = 100%
        uint32 referralCount;                          /// Number of referred by referee
        uint32 activeReferralCount;                    /// Number of active users referred by referee
        address referredBy;                            /// Address is referred by this user
        address referredByBefore;                     /// We store the 2nd step here to save gas (no interation needed)
    }

    struct Parent {
        uint8 rank;
        address user;
    }

    // returns the parent of the address
    function getParent(address _user) external view returns (address parent);
    // returns the parent and the parent of the parent of the address
    function getParents(address _user) external view returns (address parent, address parentOfParent);


    // returns user's parents and ranks of parents in 1 call
    function getParentsAndParentRanks(address _user) external view returns (Parent memory parent, Parent memory parent2);
    // returns user's parents and ranks of parents and use rbuy fee discount in 1 call
    function getParentsAndBuyFeeDiscount(address _user) external view returns (Parent memory parent, Parent memory parent2, uint16 discount);
    // returns number of referrals of address
    function getReferralCount(address _user) external view returns (uint32 count);
    // returns number of active referrals of address
    function getActiveReferralCount(address _user) external view returns (uint32 count);

    // returns up to _count referrals of _user
    function getAllReferrals(address _user) external view returns (address[] memory referrals);

    // returns up to _count referrals of _user starting from _index
    function getReferrals(address _user, uint256 _index, uint256 _count) external view returns (address[] memory referrals);

    function getDefaultReferral() external view returns (address defaultReferral);

    // get user information of _user
    function getUser(address _user) external view returns (UserProfile memory user);

    function getUserRank(address _user) external view returns (uint8 rank);

    // returns the total number of registered users
    function getUserCount() external view returns (uint256 count);

    // return true if user exists
    function userExists(address _user) external view returns (bool exists);

    function registerUser(address _user) external;

    function increaseActiveReferralCount(address _user) external;

    function registerUser(address _user, address _referredBy) external;

    function registerUserWoBooster(address _user) external;

    function setUserRank(address _user, uint8 _rank) external;

    // function setDefaultReferral(address _referral) external;

    // events
    event UserRegistered(address user, address referredBy, uint8 referredByRank, uint16 buyFeeDiscount);
}// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "../Interfaces/IGoverned.sol";

interface IVault is IGoverned {

    struct VaultState {
        bool userPoolTrackingDisabled;
        // bool paused;
        bool emergencyMode;
        bool whitelistingEnabled;
        bool flashEnabled;
        uint8 maxPoolTokenCount;
        uint8 feeToProtocol;
        uint8 bidMultiplier;
        uint16 flashFee;
        uint16 swapFee;
        uint16 bidMinDuration;
        uint16 rebalancingMinDuration;
        uint32 emergencyModeTimestamp;
        address feeTo;
    }

    struct PoolState {
        bool poolInitialized;
        bool poolEmergencyMode;
        bool feeless;
        bool boosted;
        uint8 poolTokenCount;
        uint32 emergencyModeTime;
        uint48 lastTrailingTimestamp;
        uint48 lastPerformanceTimestamp;
        uint216 emergencyModeLPs;
        TotalSupplyBase totalSupplyBase;
    }

    function getVaultState() external view returns (VaultState memory _vaultState);


    /************************************************************************************/
    /* Admin functions                                                                  */
    /************************************************************************************/
    // Check if given address is admin or not
    function isAdmin(address _address) external view returns (bool _isAdmin);

    // Add or remove vault admin. Only admin can call this function
    function AddRemoveAdmin(address _address, bool _ShouldBeAdmin) external;// returns (address, bool);

    // Boost or unboost pool. Boosted pools get 100% of their swap fees.
    // For non boosted pools, a part of the swap fees go to the platform.
    // Only admin can call this function
    function AddRemoveBoostedPool(address _address, bool _ShouldBeBoosted) external;// returns (address, bool);


    /************************************************************************************/
    /* Token whitelist                                                                  */
    /************************************************************************************/

    // Only admin can call this function. Only the whitelisted tokens can be added to a Pool
    // If empty: No whitelist, all tokens are allowed
    function setWhitelistedTokens(address[] calldata _tokens, bool[] calldata _whitelisted) external;

    function isTokenWhitelisted(address token) external view returns (bool whitelisted);
    event TokenWhitelistChanged(address indexed token, bool isWhitelisted);

    /************************************************************************************/
    /* Internal Balances                                                                */
    /************************************************************************************/

    // Users can deposit tokens into the Vault to have an internal balance in the Mosaic platform.
    // This internal balance can be used to deposit tokens into a Pool (Mint), withdraw tokens from
    // a Pool (Burn), or perform a swap. The internal balance can also be transferred or withdrawn.

    // Get a specific user's internal balance for one given token
    function getInternalBalance(address user, address token) external view returns (uint balance);

    // Get a specific user's internal balances for the given token array
    function getInternalBalances(address user, address[] memory tokens) external view returns (uint[] memory balances);

    // Deposit tokens to the msg.sender's  internal balance
    function depositToInternalBalance(address token, uint amount) external;

    // Deposit tokens to the recipient internal balance
    function depositToInternalBalanceToAddress(address token, address to, uint amount) external;

    // ERC20 token transfer from the message sender's internal balance to their address
    function withdrawFromInternalBalance(address token, uint amount) external;

    // ERC20 token transfer from the message sender's internal balance to the given address
    function withdrawFromInternalBalanceToAddress(address token, address to, uint amount) external;

    // Transfer tokens from the message sender's internal balance to another user's internal balance
    function transferInternalBalance(address token, address to, uint amount) external;

    // Event emitted when user's internal balance changes by delta amount. Positive delta means internal balance increase
    event InternalBalanceChanged(address indexed user, address indexed token, int256 delta);

    /************************************************************************************/
    /* Pool ERC20 helper                                                                */
    /************************************************************************************/

    function transferFromAsTokenContract(address from, address to, uint amount) external returns (bool success);
    function mintAsTokenContract(address to, uint amount) external returns (bool success);
    function burnAsTokenContract(address from, uint amount) external returns (bool success);

    /************************************************************************************/
    /* Pool                                                                             */
    /************************************************************************************/

    struct TotalSupplyBase {
        uint32 timestamp;
        uint224 amount;
    }

    event TotalSupplyBaseChanged(address indexed poolAddr, TotalSupplyBase supplyBase);
    // Each pool should be one of the following based on poolType:
    // 0: REBALANCING: (30% ETH, 30% BTC, 40% MKR). Weight changes gradually in time.
    // 1: NON_REBALANCING: (100 ETH, 5 BTC, 200 MKR). Weight changes gradually in time.
    // 2: DAYTRADE: Non rebalancing pool. Weight changes immediately.

    function tokenInPool(address pool, address token) external view returns (bool inPool);

    function poolIdToAddress(uint32 poolId) external view returns (address poolAddr);

    function poolAddressToId(address poolAddr) external view returns (uint32 poolId);

    // pool calls this to move the pool to zerofee status
    function disableFees() external;

    // Returns the total pool count
    function poolCount() external view returns (uint32 count);

    // Returns a list of pool IDs where the user has assets
    function userJoinedPools(address user) external view returns (uint32[] memory poolIDs);

    // Returns a list of pool the user owns
    function userOwnedPools(address user) external view returns (uint32[] memory poolIDs);

    //Get pool tokens and their balances
    function getPoolTokens(uint32 poolId) external view returns (address[] memory tokens, uint[] memory balances);

    function getPoolTokensByAddr(address poolAddr) external view returns (address[] memory tokens, uint[] memory balances);

    function getPoolTotalSupplyBase(uint32 poolId) external view returns (TotalSupplyBase memory totalSupplyBase);

    function getPoolTotalSupplyBaseByAddr(address poolAddr) external view returns (TotalSupplyBase memory totalSupplyBase);

    // Register a new pool. Pool type can not be changed after the creation. Emits a PoolRegistered event.
    function registerPool(address _poolAddr, address _user, address _referredBy) external returns (uint32 poolId);
    event PoolRegistered(uint32 indexed poolId, address indexed poolAddress);

    // Registers tokens for the Pool. Must be called by the Pool's contract. Emits a TokensRegistered event.
    function registerTokens(address[] memory _tokenList, bool onlyWhitelisted) external;
    event TokensRegistered(uint32 indexed poolId, address[] newTokens);

    // Adds initial liquidity to the pool
    function addInitialLiquidity(uint32 _poolId, address[] memory _tokens, uint[] memory _liquidity, address tokensTo, bool fromInternalBalance) external;
    event InitialLiquidityAdded(uint32 indexed poolId, address user, uint lpTokens, address[] tokens, uint[] amounts);

    // Deegisters tokens for the poolId Pool. Must be called by the Pool's contract.
    // Tokens to be deregistered should have 0 balance. Emits a TokensDeregistered event.
    function deregisterToken(address _tokenAddress, uint _remainingAmount) external;
    event TokensDeregistered(uint32 indexed poolId, address tokenAddress);

    // This function is called when a liquidity provider adds liquidity to the pool.
    // It mints additional liquidity tokens as a reward.
    // If fromInternalBalance is true, the amounts will be deducted from user's internal balance
    function Mint(uint32 poolId, uint LPTokensRequested, uint[] memory amountsMax, address to, address referredBy, bool fromInternalBalance, uint deadline, uint usdValue) external returns (uint[] memory amountsSpent);
    event Minted(uint32 indexed poolId, address txFrom, address user, uint lpTokens, address[] tokens, uint[] amounts, bool fromInternalBalance);

    // This function is called when a liquidity provider removes liquidity from the pool.
    // It burns the liquidity tokens and sends back the tokens as ERC20 transfer.
    // If toInternalBalance is true, the tokens will be deposited to user's internal balance
    function Burn(uint32 poolId, uint LPTokensToBurn, uint[] memory amountsMin, bool toInternalBalance, uint deadline, address from) external returns (uint[] memory amountsReceived);
    event Burned(uint32 indexed poolId, address txFrom, address user, uint lpTokens, address[] tokens, uint[] amounts, bool fromInternalBalance);

    /************************************************************************************/
    /* Swap                                                                             */
    /************************************************************************************/

    // Executes a swap operation on a single Pool. Called by the user
    // If the swap is initiated with givenInOrOut == 1 (i.e., the number of tokens to be sent to the Pool is specified),
    // it returns the amount of tokens taken from the Pool, which should not be less than limit.
    // If the swap is initiated with givenInOrOut == 0 parameter (i.e., the number of tokens to be taken from the Pool is specified),
    // it returns the amount of tokens sent to the Pool, which should not exceed limit.
    // Emits a Swap event
    function swap(address poolAddress, bool givenInOrOut, address tokenIn, address tokenOut, uint amount, bool fromInternalBalance, uint limit, uint64 deadline) external returns (uint calculatedAmount);
    event Swap(uint32 indexed poolId, address indexed tokenIn, address indexed tokenOut, uint amountIn, uint amountOut, address user);

    // Execute a multi-hop token swap between multiple pairs of tokens on their corresponding pools
    // Example: 100 tokenA -> tokenB -> tokenC
    // pools = [pool1, pool2], tokens = [tokenA, tokenB, tokenC], amountIn = 100
    // The returned amount of tokenC should not be less than limit
    function multiSwap(address[] memory pools, address[] memory tokens, uint amountIn, bool fromInternalBalance, uint limit, uint64 deadline) external returns (uint calculatedAmount);

    /************************************************************************************/
    /* Dutch Auction                                                                    */
    /************************************************************************************/
    // Non rebalancing pools (where poolId is not 0) can use Dutch auction to change their
    // balance sheet. A Dutch auction (also called a descending price auction) refers to a
    // type of auction in which an auctioneer starts with a very high price, incrementally
    // lowering the price. User can bid for the entire amount, or just a fraction of that.

    struct AuctionInfo {
        address poolAddress;
        uint32 startsAt;
        uint32 duration;
        uint32 expiration;
        address tokenToSell;
        address tokenToBuy;
        uint startingAmount;
        uint remainingAmount;
        uint startingPrice;
        uint endingPrice;
    }

    // Get total (lifetime) auction count
    function getAuctionCount() external view returns (uint256 auctionCount);

    // Get all information of the given auction
    function getAuctionInfo(uint auctionId) external view returns (AuctionInfo memory);

    // Returns 'true' if the auction is still running and there are tokens available for purchase
    // Returns 'false' if the auction has expired or if all tokens have been sold.
    function isRunning(uint auctionId) external view returns (bool);

    // Called by pool owner. Emits an auctionStarted event
    function startAuction(address tokenToSell, uint amountToSell, address tokenToBuy, uint32 duration, uint32 expiration, uint endingPrice) external returns (uint auctionId);
    event AuctionStarted(uint32 poolId, uint auctionId, AuctionInfo _info);

    // Called by pool owner. Emits an auctionStopped event
    function stopAuction(uint auctionId) external;
    event AuctionStopped(uint auctionId);

    // Get the current price for 'remainingAmount' number of tokens
    function getBidPrice(uint auctionId) external view returns (uint currentPrice, uint remainingAmount);

    // Place a bid for the specified 'auctionId'. Fractional bids are supported, with the 'amount'
    // representing the number of tokens to purchase. The amounts are deducted from and credited to the
    // user's internal balance. If there are insufficient tokens in the user's internal balance, the function reverts.
    // If there are fewer tokens available for the auction than the specified 'amount' and enableLessAmount == 1,
    // the function purchases all remaining tokens (which may be less than the specified amount).
    // If enableLessAmount is set to 0, the function reverts. Emits a 'newBid' event
    function bid(uint auctionId, uint amount, bool enableLessAmount, bool fromInternalBalance, uint deadline) external returns (uint spent);
    event NewBid(uint auctionId, address buyer, uint tokensBought, uint paid, address tokenToBuy, address tokenToSell, uint remainingAmount);

    /************************************************************************************/
    /* Emergency                                                                        */
    /************************************************************************************/
    // Activate emergency mode. Once the contract enters emergency mode, it cannot be reverted or cancelled.
    // Only an admin can call this function.
    function setEmergencyMode() external;

    // Activate emergency mode. Once the contract enters emergency mode, it cannot be reverted or cancelled.
    function setPoolEmergencyMode(address poolAddress) external;
}
