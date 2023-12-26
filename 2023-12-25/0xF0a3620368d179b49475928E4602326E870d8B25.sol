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
// OpenZeppelin Contracts (last updated v4.7.2) (utils/introspection/ERC165Checker.sol)

pragma solidity ^0.8.0;

import "./IERC165.sol";

/**
 * @dev Library used to query support of an interface declared via {IERC165}.
 *
 * Note that these functions return the actual result of the query: they do not
 * `revert` if an interface is not supported. It is up to the caller to decide
 * what to do in these cases.
 */
library ERC165Checker {
    // As per the EIP-165 spec, no interface should ever match 0xffffffff
    bytes4 private constant _INTERFACE_ID_INVALID = 0xffffffff;

    /**
     * @dev Returns true if `account` supports the {IERC165} interface,
     */
    function supportsERC165(address account) internal view returns (bool) {
        // Any contract that implements ERC165 must explicitly indicate support of
        // InterfaceId_ERC165 and explicitly indicate non-support of InterfaceId_Invalid
        return
            _supportsERC165Interface(account, type(IERC165).interfaceId) &&
            !_supportsERC165Interface(account, _INTERFACE_ID_INVALID);
    }

    /**
     * @dev Returns true if `account` supports the interface defined by
     * `interfaceId`. Support for {IERC165} itself is queried automatically.
     *
     * See {IERC165-supportsInterface}.
     */
    function supportsInterface(address account, bytes4 interfaceId) internal view returns (bool) {
        // query support of both ERC165 as per the spec and support of _interfaceId
        return supportsERC165(account) && _supportsERC165Interface(account, interfaceId);
    }

    /**
     * @dev Returns a boolean array where each value corresponds to the
     * interfaces passed in and whether they're supported or not. This allows
     * you to batch check interfaces for a contract where your expectation
     * is that some interfaces may not be supported.
     *
     * See {IERC165-supportsInterface}.
     *
     * _Available since v3.4._
     */
    function getSupportedInterfaces(address account, bytes4[] memory interfaceIds)
        internal
        view
        returns (bool[] memory)
    {
        // an array of booleans corresponding to interfaceIds and whether they're supported or not
        bool[] memory interfaceIdsSupported = new bool[](interfaceIds.length);

        // query support of ERC165 itself
        if (supportsERC165(account)) {
            // query support of each interface in interfaceIds
            for (uint256 i = 0; i < interfaceIds.length; i++) {
                interfaceIdsSupported[i] = _supportsERC165Interface(account, interfaceIds[i]);
            }
        }

        return interfaceIdsSupported;
    }

    /**
     * @dev Returns true if `account` supports all the interfaces defined in
     * `interfaceIds`. Support for {IERC165} itself is queried automatically.
     *
     * Batch-querying can lead to gas savings by skipping repeated checks for
     * {IERC165} support.
     *
     * See {IERC165-supportsInterface}.
     */
    function supportsAllInterfaces(address account, bytes4[] memory interfaceIds) internal view returns (bool) {
        // query support of ERC165 itself
        if (!supportsERC165(account)) {
            return false;
        }

        // query support of each interface in _interfaceIds
        for (uint256 i = 0; i < interfaceIds.length; i++) {
            if (!_supportsERC165Interface(account, interfaceIds[i])) {
                return false;
            }
        }

        // all interfaces supported
        return true;
    }

    /**
     * @notice Query if a contract implements an interface, does not check ERC165 support
     * @param account The address of the contract to query for support of an interface
     * @param interfaceId The interface identifier, as specified in ERC-165
     * @return true if the contract at account indicates support of the interface with
     * identifier interfaceId, false otherwise
     * @dev Assumes that account contains a contract that supports ERC165, otherwise
     * the behavior of this method is undefined. This precondition can be checked
     * with {supportsERC165}.
     * Interface identification is specified in ERC-165.
     */
    function _supportsERC165Interface(address account, bytes4 interfaceId) private view returns (bool) {
        // prepare call
        bytes memory encodedParams = abi.encodeWithSelector(IERC165.supportsInterface.selector, interfaceId);

        // perform static call
        bool success;
        uint256 returnSize;
        uint256 returnValue;
        assembly {
            success := staticcall(30000, account, add(encodedParams, 0x20), mload(encodedParams), 0x00, 0x20)
            returnSize := returndatasize()
            returnValue := mload(0x00)
        }

        return success && returnSize >= 0x20 && returnValue > 0;
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
// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

interface IERC1155Mintable {
    /**
     * @param _to Address to mint token to
     * @param _tokenId Id of token to mint
     */
    function mintTo(address _to, uint256 _tokenId, uint256 _amount) external;

    /**
     * @param _to Address to mint token to
     * @param _tokenIds Array with token ids to mint
     * @param _amounts Array with token amounts to mint
     */
    function mintBatchTo(address _to, uint256[] calldata _tokenIds, uint256[] calldata _amounts) external;

    /**
     * @param _to Array of addresses to mint token to
     * @param _tokenIds Array of arrays with token ids to mint
     * @param _amounts Array of arrays with token amounts to mint
     */
    function mintBatchToMultiple(
        address[] calldata _to,
        uint256[][] calldata _tokenIds,
        uint256[][] calldata _amounts
    ) external;
}
// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

interface IERC721Mintable {
    /**
     * @param _to Address to mint token to
     * @param _tokenId Id of token to mint
     */
    function mintTo(address _to, uint256 _tokenId) external;

    /**
     * @param _to Address to mint token to
     * @param _tokenIds Array with token ids to mint
     */
    function mintBatchTo(address _to, uint256[] calldata _tokenIds) external;

    /**
     * @param _to Array of addresses to mint tokens to
     * @param _tokenIds Array of arrays with token ids to mint
     */
    function mintBatchToMultiple(address[] calldata _to, uint256[][] calldata _tokenIds) external;
}
// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

import { AccessControl } from "@openzeppelin/contracts/access/AccessControl.sol";

contract DefaultRoles is AccessControl {
    error OnlyOwner(address sender);
    error OnlyAdmin(address sender);
    error OnlyExecutor(address sender);

    error CannotRemoveSelf(address owner);

    error FunctionDisabled(bytes4 functionId);

    bytes32 public constant OWNER_ROLE = keccak256("OWNER_ROLE");
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    bytes32 public constant EXECUTOR_ROLE = keccak256("EXECUTOR_ROLE");

    /**
     *
     * @param owner Address of the owner
     * @param admin Address of the admin
     * @param executors Addresses of the executors
     */
    constructor(address owner, address admin, address[] memory executors) AccessControl() {
        _grantRole(OWNER_ROLE, owner);
        _grantRole(ADMIN_ROLE, admin);
        _addExecutors(executors);
    }

    /**
     *
     * @param owner Address of the owner to add
     */
    function addOwner(address owner) external virtual onlyOwner {
        _addOwner(owner);
    }

    function _addOwner(address owner) internal virtual {
        _grantRole(OWNER_ROLE, owner);
    }

    /**
     *
     * @param owner Address of the owner ro revoke
     */
    function revokeOwner(address owner) external virtual onlyOwner {
        if (owner == _msgSender()) {
            revert CannotRemoveSelf(owner);
        }
        _revokeOwner(owner);
    }

    function _revokeOwner(address owner) internal virtual {
        _revokeRole(OWNER_ROLE, owner);
    }

    /**
     *
     * @param admin Address of the admin to add
     */
    function addAdmin(address admin) external virtual onlyOwner {
        _addAdmin(admin);
    }

    function _addAdmin(address admin) internal virtual {
        _grantRole(ADMIN_ROLE, admin);
    }

    /**
     *
     * @param admin Address of the admin to revoke
     */
    function revokeAdmin(address admin) external virtual onlyOwner {
        _revokeAdmin(admin);
    }

    function _revokeAdmin(address admin) internal virtual {
        _revokeRole(ADMIN_ROLE, admin);
    }

    /**
     *
     * @param executors Addresses of the executors to add
     */
    function addExecutors(address[] calldata executors) external virtual onlyAdmin {
        _addExecutors(executors);
    }

    /**
     *
     * @param executors Addresses of the executors to revoke
     */
    function revokeExecutors(address[] calldata executors) external virtual onlyAdmin {
        for (uint256 i = 0; i < executors.length; i++) {
            _revokeRole(EXECUTOR_ROLE, executors[i]);
        }
    }

    /**
     *
     * @param executors Addresses of the executors to add
     */
    function _addExecutors(address[] memory executors) internal virtual {
        for (uint256 i = 0; i < executors.length; i++) {
            _addExecutor(executors[i]);
        }
    }

    function _addExecutor(address executor) internal virtual {
        _grantRole(EXECUTOR_ROLE, executor);
    }

    /**
     * @inheritdoc AccessControl
     */
    function grantRole(bytes32, address) public virtual override {
        revert FunctionDisabled(AccessControl.grantRole.selector);
    }

    /**
     * @inheritdoc AccessControl
     */
    function revokeRole(bytes32, address) public virtual override {
        revert FunctionDisabled(AccessControl.revokeRole.selector);
    }

    /**
     * @inheritdoc AccessControl
     */
    function renounceRole(bytes32, address) public virtual override {
        revert FunctionDisabled(AccessControl.renounceRole.selector);
    }

    modifier onlyOwner() {
        if (!hasRole(OWNER_ROLE, _msgSender())) {
            revert OnlyOwner(_msgSender());
        }
        _;
    }

    modifier onlyAdmin() {
        if (!hasRole(ADMIN_ROLE, _msgSender())) {
            revert OnlyAdmin(_msgSender());
        }
        _;
    }

    modifier onlyExecutor() {
        if (!hasRole(EXECUTOR_ROLE, _msgSender())) {
            revert OnlyExecutor(_msgSender());
        }
        _;
    }
}
// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

interface IBaseMinter {
    event Minted(address indexed token, address indexed to, uint256 indexed tokenId, uint256 amount);

    error ArrayLengthMismatch();
}
// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

interface IMinter {
    /******************************************************************************/
    /*                   Multiple tokens for multiple receivers                   */
    /******************************************************************************/

    /**
     * @dev Mint multiple tokens for multiple receivers
     * @param token address of the token to mint
     * @param to Addresses of the receivers
     * @param tokenId Array of arrays of token ids to mint
     * @param amounts Amounts of tokens to mint (1-1 mapping with tokenIds), empty for ERC721
     * @param data Data to pass to the minter (currently unused)
     */
    function mint(
        address token,
        address[] calldata to,
        uint256[][] calldata tokenId,
        uint256[][] calldata amounts,
        bytes calldata data
    ) external;

    /**
     * @dev batch mint multiple tokens for multiple receivers
     */
    function batchMint(
        address[] calldata token,
        address[][] calldata to,
        uint256[][][] calldata tokenId,
        uint256[][][] calldata amounts,
        bytes[] calldata data
    ) external;

    /******************************************************************************/
    /*                      Multiple tokens for one receiver                      */
    /******************************************************************************/

    /**
     * @dev Mint multiple tokens for a single receiver
     * @param token address of the token to mint
     * @param to Address of the receiver
     * @param tokenId Array of token ids to mint
     * @param amounts Amounts of tokens to mint (1-1 mapping with tokenIds), empty for ERC721
     * @param data Data to pass to the minter (currently unused)
     */
    function mint(
        address token,
        address to,
        uint256[] calldata tokenId,
        uint256[] calldata amounts,
        bytes calldata data
    ) external;

    /**
     * @dev batch mint multiple tokens for a single receiver
     */
    function batchMint(
        address[] calldata token,
        address[] calldata to,
        uint256[][] calldata tokenId,
        uint256[][] calldata amounts,
        bytes[] calldata data
    ) external;

    /******************************************************************************/
    /*                        One token for each receiver                         */
    /******************************************************************************/

    /**
     * @dev Mint a single token for multiple receivers
     * @param token address of the token to mint
     * @param to Addresses of the receivers
     * @param tokenId Id of the token to mint
     * @param amounts Amounts of tokens to mint (1-1 mapping with tokenIds), empty for ERC721
     * @param data Data to pass to the minter (currently unused)
     */
    function mint(
        address token,
        address[] calldata to,
        uint256[] calldata tokenId,
        uint256[] calldata amounts,
        bytes calldata data
    ) external;

    /**
     * @dev batch mint a single token for multiple receivers
     */
    function batchMint(
        address[] calldata token,
        address[][] calldata to,
        uint256[][] calldata tokenId,
        uint256[][] calldata amounts,
        bytes[] calldata data
    ) external;

    /******************************************************************************/
    /*                         One token for one receiver                         */
    /******************************************************************************/

    /**
     * @dev Mint a single token for a single receiver
     * @param token address of the token to mint
     * @param to Address of the receiver
     * @param tokenId Id of the token to mint
     * @param amount Amount of tokens to mint, 0 for ERC721
     * @param data Data to pass to the minter (currently unused)
     */
    function mint(address token, address to, uint256 tokenId, uint256 amount, bytes calldata data) external;

    /**
     * @dev batch mint a single token for a single receiver
     */
    function batchMint(
        address[] calldata token,
        address[] calldata to,
        uint256[] calldata tokenId,
        uint256[] calldata amounts,
        bytes[] calldata data
    ) external;
}
// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

import "@openzeppelin/contracts/security/Pausable.sol";

import "./interfaces/IMinter.sol";

import "./minters/TokenInfoCache.sol";
import "./minters/ERC721Minter.sol";
import "./minters/ERC1155Minter.sol";

import "../common/utils/DefaultRoles.sol";

contract Minter is Pausable, DefaultRoles, TokenInfoCache, ERC721Minter, ERC1155Minter, IMinter {
    /**
     * @dev Initialize the contract
     * @param owner Address of the owner
     * @param admin Address of the admin
     * @param minters Addresses of the minters
     */
    constructor(
        address owner,
        address admin,
        address[] memory minters
    ) Pausable() DefaultRoles(owner, admin, minters) {}

    /******************************************************************************/
    /*                   Multiple tokens for multiple receivers                   */
    /******************************************************************************/

    /**
     * @inheritdoc IMinter
     */
    function mint(
        address token,
        address[] calldata to,
        uint256[][] calldata tokenId,
        uint256[][] calldata amounts,
        bytes calldata data
    ) external override onlyExecutor whenNotPaused {
        _mint(token, to, tokenId, amounts, data);
    }

    /**
     * @inheritdoc IMinter
     */
    function batchMint(
        address[] calldata token,
        address[][] calldata to,
        uint256[][][] calldata tokenId,
        uint256[][][] calldata amounts,
        bytes[] calldata data
    ) external onlyExecutor whenNotPaused {
        uint256 length = token.length;
        if (length != to.length || length != tokenId.length || length != amounts.length || length != data.length) {
            revert ArrayLengthMismatch();
        }
        for (uint256 i = 0; i < length; i++) {
            _mint(token[i], to[i], tokenId[i], amounts[i], data[i]);
        }
    }

    function _mint(
        address token,
        address[] calldata to,
        uint256[][] calldata tokenId,
        uint256[][] calldata amounts,
        bytes calldata data
    ) internal {
        TokenType tokenType = _determineTokenType(token);
        if (tokenType == TokenType.ERC721) {
            _mintERC721(token, to, tokenId, data);
        }
        if (tokenType == TokenType.ERC1155) {
            _mintERC1155(token, to, tokenId, amounts, data);
        }
    }

    /******************************************************************************/
    /*                      Multiple tokens for one receiver                      */
    /******************************************************************************/

    /**
     * @inheritdoc IMinter
     */
    function mint(
        address token,
        address to,
        uint256[] calldata tokenId,
        uint256[] calldata amounts,
        bytes calldata data
    ) external override onlyExecutor whenNotPaused {
        _mint(token, to, tokenId, amounts, data);
    }

    /**
     * @inheritdoc IMinter
     */
    function batchMint(
        address[] calldata token,
        address[] calldata to,
        uint256[][] calldata tokenId,
        uint256[][] calldata amounts,
        bytes[] calldata data
    ) external onlyExecutor whenNotPaused {
        uint256 length = token.length;
        if (length != to.length || length != tokenId.length || length != amounts.length || length != data.length) {
            revert ArrayLengthMismatch();
        }
        for (uint256 i = 0; i < token.length; i++) {
            _mint(token[i], to[i], tokenId[i], amounts[i], data[i]);
        }
    }

    function _mint(
        address token,
        address to,
        uint256[] calldata tokenId,
        uint256[] calldata amounts,
        bytes calldata data
    ) internal {
        address[] memory to_ = new address[](1);
        to_[0] = to;
        uint256[][] memory tokenId_ = new uint256[][](1);
        tokenId_[0] = tokenId;
        uint256[][] memory amounts_ = new uint256[][](1);
        amounts_[0] = amounts;

        TokenType tokenType = _determineTokenType(token);

        if (tokenType == TokenType.ERC721) {
            _mintERC721(token, to, tokenId, data);
        }
        if (tokenType == TokenType.ERC1155) {
            _mintERC1155(token, to, tokenId, amounts, data);
        }
    }

    /******************************************************************************/
    /*                        One token for each receiver                         */
    /******************************************************************************/

    /**
     * @inheritdoc IMinter
     */
    function mint(
        address token,
        address[] calldata to,
        uint256[] calldata tokenId,
        uint256[] calldata amounts,
        bytes calldata data
    ) external override onlyExecutor whenNotPaused {
        _mint(token, to, tokenId, amounts, data);
    }

    /**
     * @inheritdoc IMinter
     */
    function batchMint(
        address[] calldata token,
        address[][] calldata to,
        uint256[][] calldata tokenId,
        uint256[][] calldata amounts,
        bytes[] calldata data
    ) external onlyExecutor whenNotPaused {
        uint256 length = token.length;
        if (length != to.length || length != tokenId.length || length != amounts.length || length != data.length) {
            revert ArrayLengthMismatch();
        }
        for (uint256 i = 0; i < token.length; i++) {
            _mint(token[i], to[i], tokenId[i], amounts[i], data[i]);
        }
    }

    function _mint(
        address token,
        address[] calldata to,
        uint256[] calldata tokenId,
        uint256[] calldata amounts,
        bytes calldata data
    ) internal {
        TokenType tokenType = _determineTokenType(token);

        if (tokenType == TokenType.ERC721) {
            _mintERC721(token, to, tokenId, data);
        }
        if (tokenType == TokenType.ERC1155) {
            _mintERC1155(token, to, tokenId, amounts, data);
        }
    }

    /******************************************************************************/
    /*                         One token for one receiver                         */
    /******************************************************************************/

    /**
     * @inheritdoc IMinter
     */
    function mint(
        address token,
        address to,
        uint256 tokenId,
        uint256 amount,
        bytes calldata data
    ) external override onlyExecutor whenNotPaused {
        _mint(token, to, tokenId, amount, data);
    }

    /**
     * @inheritdoc IMinter
     */
    function batchMint(
        address[] calldata token,
        address[] calldata to,
        uint256[] calldata tokenId,
        uint256[] calldata amounts,
        bytes[] calldata data
    ) external onlyExecutor whenNotPaused {
        uint256 length = token.length;
        if (length != to.length || length != tokenId.length || length != amounts.length || length != data.length) {
            revert ArrayLengthMismatch();
        }
        for (uint256 i = 0; i < token.length; i++) {
            _mint(token[i], to[i], tokenId[i], amounts[i], data[i]);
        }
    }

    function _mint(address token, address to, uint256 tokenId, uint256 amount, bytes calldata data) internal {
        TokenType tokenType = _determineTokenType(token);

        if (tokenType == TokenType.ERC721) {
            _mintERC721(token, to, tokenId, data);
        }
        if (tokenType == TokenType.ERC1155) {
            _mintERC1155(token, to, tokenId, amount, data);
        }
    }

    /******************************************************************************/
    /*                            PausableUpgradeable                             */
    /******************************************************************************/

    /**
     * @dev Pause the contract
     */
    function pause() external onlyAdmin {
        _pause();
    }

    /**
     * @dev Unpause the contract
     */
    function unpause() external onlyAdmin {
        _unpause();
    }
}
// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

import "../interfaces/IBaseMinter.sol";

import "../../common/tokens/interfaces/IERC1155Mintable.sol";

abstract contract ERC1155Minter is IBaseMinter {
    function _mintERC1155(address token, address to, uint256 tokenId, uint256 amount, bytes calldata) internal {
        emit Minted(token, to, tokenId, amount);

        IERC1155Mintable(token).mintTo(to, tokenId, amount);
    }

    function _mintERC1155(
        address token,
        address to,
        uint256[] calldata tokenId,
        uint256[] calldata amount,
        bytes calldata
    ) internal {
        if (tokenId.length != amount.length) {
            revert ArrayLengthMismatch();
        }

        // Mint tokens
        for (uint256 id = 0; id < tokenId.length; id++) {
            emit Minted(token, to, tokenId[id], amount[id]);
        }

        IERC1155Mintable(token).mintBatchTo(to, tokenId, amount);
    }

    function _mintERC1155(
        address token,
        address[] calldata to,
        uint256[] calldata tokenId,
        uint256[] calldata amount,
        bytes calldata
    ) internal {
        if (to.length != tokenId.length || to.length != amount.length) {
            revert ArrayLengthMismatch();
        }

        uint256[][] memory tokenIds = new uint256[][](to.length);
        uint256[][] memory amounts = new uint256[][](to.length);

        for (uint256 i = 0; i < to.length; i++) {
            tokenIds[i] = new uint256[](1);
            amounts[i] = new uint256[](1);

            tokenIds[i][0] = tokenId[i];
            amounts[i][0] = amount[i];
        }

        // Mint tokens
        for (uint256 id = 0; id < to.length; id++) {
            emit Minted(token, to[id], tokenId[id], amount[id]);
        }

        IERC1155Mintable(token).mintBatchToMultiple(to, tokenIds, amounts);
    }

    /**
     * @dev Function to mint tokens
     * @param token address of the token to mint
     * @param to address of the receivers
     * @param tokenIds ids of the tokens to mint
     * @param amounts amount of tokens to mint
     */
    function _mintERC1155(
        address token,
        address[] calldata to,
        uint256[][] calldata tokenIds,
        uint256[][] calldata amounts,
        bytes calldata
    ) internal {
        if (to.length != tokenIds.length || to.length != amounts.length) {
            revert ArrayLengthMismatch();
        }

        uint256 length = to.length;
        // Mint tokens
        for (uint256 id = 0; id < length; id++) {
            if (tokenIds[id].length != amounts[id].length) {
                revert ArrayLengthMismatch();
            }

            for (uint256 iid = 0; iid < tokenIds.length; iid++) {
                emit Minted(token, to[iid], tokenIds[id][iid], amounts[id][iid]);
            }
        }

        IERC1155Mintable(token).mintBatchToMultiple(to, tokenIds, amounts);
    }
}
// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

import "../../common/tokens/interfaces/IERC721Mintable.sol";

import "../interfaces/IBaseMinter.sol";

abstract contract ERC721Minter is IBaseMinter {
    /**
     * This one is used to mint a single token for a single receiver
     * @param token Address of the token to mint
     * @param to Address of the receiver
     * @param tokenId Id of the token to mint
     */
    function _mintERC721(address token, address to, uint256 tokenId, bytes calldata) internal {
        emit Minted(token, to, tokenId, 1);

        IERC721Mintable(token).mintTo(to, tokenId);
    }

    /**
     * This one is used to mint multiple tokens for a single receiver
     * @param token Address of the token to mint
     * @param to Address of the receiver
     * @param tokenId Id of the token to mint
     */
    function _mintERC721(address token, address to, uint256[] calldata tokenId, bytes calldata) internal {
        for (uint256 id = 0; id < tokenId.length; id++) {
            emit Minted(token, to, tokenId[id], 1);
        }

        IERC721Mintable(token).mintBatchTo(to, tokenId);
    }

    /**
     * This one is used to mint a single token for multiple receivers
     * @param token Address of the token to mint
     * @param to Address of the receiver
     * @param tokenId Id of the token to mint
     */
    function _mintERC721(address token, address[] calldata to, uint256[] calldata tokenId, bytes calldata) internal {
        if (to.length != tokenId.length) {
            revert ArrayLengthMismatch();
        }

        // Mint tokens
        for (uint256 id = 0; id < to.length; id++) {
            emit Minted(token, to[id], tokenId[id], 1);
        }

        for (uint256 id = 0; id < to.length; id++) {
            IERC721Mintable(token).mintTo(to[id], tokenId[id]);
        }
    }

    /**
     * This one is used to mint multiple tokens for multiple receivers
     * @param token Address of the token to mint
     * @param to Address of the receiver
     * @param tokenIds Id of the token to mint
     */
    function _mintERC721(address token, address[] calldata to, uint256[][] calldata tokenIds, bytes calldata) internal {
        if (to.length != tokenIds.length) {
            revert ArrayLengthMismatch();
        }

        for (uint256 id = 0; id < to.length; id++) {
            for (uint256 i = 0; i < tokenIds[id].length; i++) {
                emit Minted(token, to[id], tokenIds[id][i], 1);
            }
        }
        IERC721Mintable(token).mintBatchToMultiple(to, tokenIds);
    }
}
// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

// Import IERC721, IERC1155, and IERC1155Receiver from OpenZeppelin
import "../../common/tokens/interfaces/IERC721Mintable.sol";
import "../../common/tokens/interfaces/IERC1155Mintable.sol";

// Import ERC165Checker from OpenZeppelin
import "@openzeppelin/contracts/utils/introspection/ERC165Checker.sol";

contract TokenInfoCache {
    error NotSupported(address token);

    using ERC165Checker for address;

    enum TokenType {
        None,
        ERC721,
        ERC1155
    }

    mapping(address => TokenType) public tokenTypes;

    function _determineTokenType(address token) internal returns (TokenType) {
        TokenType tokenType = tokenTypes[token];
        if (tokenType == TokenType.None) {
            if (token.supportsInterface(type(IERC721Mintable).interfaceId)) {
                tokenType = TokenType.ERC721;
            } else if (token.supportsInterface(type(IERC1155Mintable).interfaceId)) {
                tokenType = TokenType.ERC1155;
            }
            if (tokenType == TokenType.None) {
                revert NotSupported(token);
            }

            tokenTypes[token] = tokenType;
        }
        return tokenType;
    }
}
