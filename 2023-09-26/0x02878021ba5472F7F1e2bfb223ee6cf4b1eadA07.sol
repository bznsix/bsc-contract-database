// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (access/AccessControlEnumerable.sol)

pragma solidity ^0.8.0;

import "./IAccessControlEnumerableUpgradeable.sol";
import "./AccessControlUpgradeable.sol";
import "../utils/structs/EnumerableSetUpgradeable.sol";
import "../proxy/utils/Initializable.sol";

/**
 * @dev Extension of {AccessControl} that allows enumerating the members of each role.
 */
abstract contract AccessControlEnumerableUpgradeable is Initializable, IAccessControlEnumerableUpgradeable, AccessControlUpgradeable {
    function __AccessControlEnumerable_init() internal onlyInitializing {
    }

    function __AccessControlEnumerable_init_unchained() internal onlyInitializing {
    }
    using EnumerableSetUpgradeable for EnumerableSetUpgradeable.AddressSet;

    mapping(bytes32 => EnumerableSetUpgradeable.AddressSet) private _roleMembers;

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IAccessControlEnumerableUpgradeable).interfaceId || super.supportsInterface(interfaceId);
    }

    /**
     * @dev Returns one of the accounts that have `role`. `index` must be a
     * value between 0 and {getRoleMemberCount}, non-inclusive.
     *
     * Role bearers are not sorted in any particular way, and their ordering may
     * change at any point.
     *
     * WARNING: When using {getRoleMember} and {getRoleMemberCount}, make sure
     * you perform all queries on the same block. See the following
     * https://forum.openzeppelin.com/t/iterating-over-elements-on-enumerableset-in-openzeppelin-contracts/2296[forum post]
     * for more information.
     */
    function getRoleMember(bytes32 role, uint256 index) public view virtual override returns (address) {
        return _roleMembers[role].at(index);
    }

    /**
     * @dev Returns the number of accounts that have `role`. Can be used
     * together with {getRoleMember} to enumerate all bearers of a role.
     */
    function getRoleMemberCount(bytes32 role) public view virtual override returns (uint256) {
        return _roleMembers[role].length();
    }

    /**
     * @dev Overload {_grantRole} to track enumerable memberships
     */
    function _grantRole(bytes32 role, address account) internal virtual override {
        super._grantRole(role, account);
        _roleMembers[role].add(account);
    }

    /**
     * @dev Overload {_revokeRole} to track enumerable memberships
     */
    function _revokeRole(bytes32 role, address account) internal virtual override {
        super._revokeRole(role, account);
        _roleMembers[role].remove(account);
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (access/AccessControl.sol)

pragma solidity ^0.8.0;

import "./IAccessControlUpgradeable.sol";
import "../utils/ContextUpgradeable.sol";
import "../utils/StringsUpgradeable.sol";
import "../utils/introspection/ERC165Upgradeable.sol";
import "../proxy/utils/Initializable.sol";

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
abstract contract AccessControlUpgradeable is Initializable, ContextUpgradeable, IAccessControlUpgradeable, ERC165Upgradeable {
    function __AccessControl_init() internal onlyInitializing {
    }

    function __AccessControl_init_unchained() internal onlyInitializing {
    }
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
        return interfaceId == type(IAccessControlUpgradeable).interfaceId || super.supportsInterface(interfaceId);
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
                        StringsUpgradeable.toHexString(account),
                        " is missing role ",
                        StringsUpgradeable.toHexString(uint256(role), 32)
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

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/IAccessControlEnumerable.sol)

pragma solidity ^0.8.0;

import "./IAccessControlUpgradeable.sol";

/**
 * @dev External interface of AccessControlEnumerable declared to support ERC165 detection.
 */
interface IAccessControlEnumerableUpgradeable is IAccessControlUpgradeable {
    /**
     * @dev Returns one of the accounts that have `role`. `index` must be a
     * value between 0 and {getRoleMemberCount}, non-inclusive.
     *
     * Role bearers are not sorted in any particular way, and their ordering may
     * change at any point.
     *
     * WARNING: When using {getRoleMember} and {getRoleMemberCount}, make sure
     * you perform all queries on the same block. See the following
     * https://forum.openzeppelin.com/t/iterating-over-elements-on-enumerableset-in-openzeppelin-contracts/2296[forum post]
     * for more information.
     */
    function getRoleMember(bytes32 role, uint256 index) external view returns (address);

    /**
     * @dev Returns the number of accounts that have `role`. Can be used
     * together with {getRoleMember} to enumerate all bearers of a role.
     */
    function getRoleMemberCount(bytes32 role) external view returns (uint256);
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/IAccessControl.sol)

pragma solidity ^0.8.0;

/**
 * @dev External interface of AccessControl declared to support ERC165 detection.
 */
interface IAccessControlUpgradeable {
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
// OpenZeppelin Contracts (last updated v4.5.0) (interfaces/draft-IERC1822.sol)

pragma solidity ^0.8.0;

/**
 * @dev ERC1822: Universal Upgradeable Proxy Standard (UUPS) documents a method for upgradeability through a simplified
 * proxy whose upgrades are fully controlled by the current implementation.
 */
interface IERC1822ProxiableUpgradeable {
    /**
     * @dev Returns the storage slot that the proxiable contract assumes is being used to store the implementation
     * address.
     *
     * IMPORTANT: A proxy pointing at a proxiable contract should not be considered proxiable itself, because this risks
     * bricking a proxy that upgrades to it, by delegating to itself until out of gas. Thus it is critical that this
     * function revert if invoked through a proxy.
     */
    function proxiableUUID() external view returns (bytes32);
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (interfaces/IERC1967.sol)

pragma solidity ^0.8.0;

/**
 * @dev ERC-1967: Proxy Storage Slots. This interface contains the events defined in the ERC.
 *
 * _Available since v4.8.3._
 */
interface IERC1967Upgradeable {
    /**
     * @dev Emitted when the implementation is upgraded.
     */
    event Upgraded(address indexed implementation);

    /**
     * @dev Emitted when the admin account has changed.
     */
    event AdminChanged(address previousAdmin, address newAdmin);

    /**
     * @dev Emitted when the beacon is changed.
     */
    event BeaconUpgraded(address indexed beacon);
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (interfaces/IERC20.sol)

pragma solidity ^0.8.0;

import "../token/ERC20/IERC20Upgradeable.sol";
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (proxy/beacon/IBeacon.sol)

pragma solidity ^0.8.0;

/**
 * @dev This is the interface that {BeaconProxy} expects of its beacon.
 */
interface IBeaconUpgradeable {
    /**
     * @dev Must return an address that can be used as a delegate call target.
     *
     * {BeaconProxy} will check that this address is a contract.
     */
    function implementation() external view returns (address);
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (proxy/ERC1967/ERC1967Upgrade.sol)

pragma solidity ^0.8.2;

import "../beacon/IBeaconUpgradeable.sol";
import "../../interfaces/IERC1967Upgradeable.sol";
import "../../interfaces/draft-IERC1822Upgradeable.sol";
import "../../utils/AddressUpgradeable.sol";
import "../../utils/StorageSlotUpgradeable.sol";
import "../utils/Initializable.sol";

/**
 * @dev This abstract contract provides getters and event emitting update functions for
 * https://eips.ethereum.org/EIPS/eip-1967[EIP1967] slots.
 *
 * _Available since v4.1._
 */
abstract contract ERC1967UpgradeUpgradeable is Initializable, IERC1967Upgradeable {
    function __ERC1967Upgrade_init() internal onlyInitializing {
    }

    function __ERC1967Upgrade_init_unchained() internal onlyInitializing {
    }
    // This is the keccak-256 hash of "eip1967.proxy.rollback" subtracted by 1
    bytes32 private constant _ROLLBACK_SLOT = 0x4910fdfa16fed3260ed0e7147f7cc6da11a60208b5b9406d12a635614ffd9143;

    /**
     * @dev Storage slot with the address of the current implementation.
     * This is the keccak-256 hash of "eip1967.proxy.implementation" subtracted by 1, and is
     * validated in the constructor.
     */
    bytes32 internal constant _IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;

    /**
     * @dev Returns the current implementation address.
     */
    function _getImplementation() internal view returns (address) {
        return StorageSlotUpgradeable.getAddressSlot(_IMPLEMENTATION_SLOT).value;
    }

    /**
     * @dev Stores a new address in the EIP1967 implementation slot.
     */
    function _setImplementation(address newImplementation) private {
        require(AddressUpgradeable.isContract(newImplementation), "ERC1967: new implementation is not a contract");
        StorageSlotUpgradeable.getAddressSlot(_IMPLEMENTATION_SLOT).value = newImplementation;
    }

    /**
     * @dev Perform implementation upgrade
     *
     * Emits an {Upgraded} event.
     */
    function _upgradeTo(address newImplementation) internal {
        _setImplementation(newImplementation);
        emit Upgraded(newImplementation);
    }

    /**
     * @dev Perform implementation upgrade with additional setup call.
     *
     * Emits an {Upgraded} event.
     */
    function _upgradeToAndCall(address newImplementation, bytes memory data, bool forceCall) internal {
        _upgradeTo(newImplementation);
        if (data.length > 0 || forceCall) {
            AddressUpgradeable.functionDelegateCall(newImplementation, data);
        }
    }

    /**
     * @dev Perform implementation upgrade with security checks for UUPS proxies, and additional setup call.
     *
     * Emits an {Upgraded} event.
     */
    function _upgradeToAndCallUUPS(address newImplementation, bytes memory data, bool forceCall) internal {
        // Upgrades from old implementations will perform a rollback test. This test requires the new
        // implementation to upgrade back to the old, non-ERC1822 compliant, implementation. Removing
        // this special case will break upgrade paths from old UUPS implementation to new ones.
        if (StorageSlotUpgradeable.getBooleanSlot(_ROLLBACK_SLOT).value) {
            _setImplementation(newImplementation);
        } else {
            try IERC1822ProxiableUpgradeable(newImplementation).proxiableUUID() returns (bytes32 slot) {
                require(slot == _IMPLEMENTATION_SLOT, "ERC1967Upgrade: unsupported proxiableUUID");
            } catch {
                revert("ERC1967Upgrade: new implementation is not UUPS");
            }
            _upgradeToAndCall(newImplementation, data, forceCall);
        }
    }

    /**
     * @dev Storage slot with the admin of the contract.
     * This is the keccak-256 hash of "eip1967.proxy.admin" subtracted by 1, and is
     * validated in the constructor.
     */
    bytes32 internal constant _ADMIN_SLOT = 0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6103;

    /**
     * @dev Returns the current admin.
     */
    function _getAdmin() internal view returns (address) {
        return StorageSlotUpgradeable.getAddressSlot(_ADMIN_SLOT).value;
    }

    /**
     * @dev Stores a new address in the EIP1967 admin slot.
     */
    function _setAdmin(address newAdmin) private {
        require(newAdmin != address(0), "ERC1967: new admin is the zero address");
        StorageSlotUpgradeable.getAddressSlot(_ADMIN_SLOT).value = newAdmin;
    }

    /**
     * @dev Changes the admin of the proxy.
     *
     * Emits an {AdminChanged} event.
     */
    function _changeAdmin(address newAdmin) internal {
        emit AdminChanged(_getAdmin(), newAdmin);
        _setAdmin(newAdmin);
    }

    /**
     * @dev The storage slot of the UpgradeableBeacon contract which defines the implementation for this proxy.
     * This is bytes32(uint256(keccak256('eip1967.proxy.beacon')) - 1)) and is validated in the constructor.
     */
    bytes32 internal constant _BEACON_SLOT = 0xa3f0ad74e5423aebfd80d3ef4346578335a9a72aeaee59ff6cb3582b35133d50;

    /**
     * @dev Returns the current beacon.
     */
    function _getBeacon() internal view returns (address) {
        return StorageSlotUpgradeable.getAddressSlot(_BEACON_SLOT).value;
    }

    /**
     * @dev Stores a new beacon in the EIP1967 beacon slot.
     */
    function _setBeacon(address newBeacon) private {
        require(AddressUpgradeable.isContract(newBeacon), "ERC1967: new beacon is not a contract");
        require(
            AddressUpgradeable.isContract(IBeaconUpgradeable(newBeacon).implementation()),
            "ERC1967: beacon implementation is not a contract"
        );
        StorageSlotUpgradeable.getAddressSlot(_BEACON_SLOT).value = newBeacon;
    }

    /**
     * @dev Perform beacon upgrade with additional setup call. Note: This upgrades the address of the beacon, it does
     * not upgrade the implementation contained in the beacon (see {UpgradeableBeacon-_setImplementation} for that).
     *
     * Emits a {BeaconUpgraded} event.
     */
    function _upgradeBeaconToAndCall(address newBeacon, bytes memory data, bool forceCall) internal {
        _setBeacon(newBeacon);
        emit BeaconUpgraded(newBeacon);
        if (data.length > 0 || forceCall) {
            AddressUpgradeable.functionDelegateCall(IBeaconUpgradeable(newBeacon).implementation(), data);
        }
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[50] private __gap;
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (proxy/utils/Initializable.sol)

pragma solidity ^0.8.2;

import "../../utils/AddressUpgradeable.sol";

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since proxied contracts do not make use of a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 *
 * The initialization functions use a version number. Once a version number is used, it is consumed and cannot be
 * reused. This mechanism prevents re-execution of each "step" but allows the creation of new initialization steps in
 * case an upgrade adds a module that needs to be initialized.
 *
 * For example:
 *
 * [.hljs-theme-light.nopadding]
 * ```solidity
 * contract MyToken is ERC20Upgradeable {
 *     function initialize() initializer public {
 *         __ERC20_init("MyToken", "MTK");
 *     }
 * }
 *
 * contract MyTokenV2 is MyToken, ERC20PermitUpgradeable {
 *     function initializeV2() reinitializer(2) public {
 *         __ERC20Permit_init("MyToken");
 *     }
 * }
 * ```
 *
 * TIP: To avoid leaving the proxy in an uninitialized state, the initializer function should be called as early as
 * possible by providing the encoded function call as the `_data` argument to {ERC1967Proxy-constructor}.
 *
 * CAUTION: When used with inheritance, manual care must be taken to not invoke a parent initializer twice, or to ensure
 * that all initializers are idempotent. This is not verified automatically as constructors are by Solidity.
 *
 * [CAUTION]
 * ====
 * Avoid leaving a contract uninitialized.
 *
 * An uninitialized contract can be taken over by an attacker. This applies to both a proxy and its implementation
 * contract, which may impact the proxy. To prevent the implementation contract from being used, you should invoke
 * the {_disableInitializers} function in the constructor to automatically lock it when it is deployed:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * /// @custom:oz-upgrades-unsafe-allow constructor
 * constructor() {
 *     _disableInitializers();
 * }
 * ```
 * ====
 */
abstract contract Initializable {
    /**
     * @dev Indicates that the contract has been initialized.
     * @custom:oz-retyped-from bool
     */
    uint8 private _initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private _initializing;

    /**
     * @dev Triggered when the contract has been initialized or reinitialized.
     */
    event Initialized(uint8 version);

    /**
     * @dev A modifier that defines a protected initializer function that can be invoked at most once. In its scope,
     * `onlyInitializing` functions can be used to initialize parent contracts.
     *
     * Similar to `reinitializer(1)`, except that functions marked with `initializer` can be nested in the context of a
     * constructor.
     *
     * Emits an {Initialized} event.
     */
    modifier initializer() {
        bool isTopLevelCall = !_initializing;
        require(
            (isTopLevelCall && _initialized < 1) || (!AddressUpgradeable.isContract(address(this)) && _initialized == 1),
            "Initializable: contract is already initialized"
        );
        _initialized = 1;
        if (isTopLevelCall) {
            _initializing = true;
        }
        _;
        if (isTopLevelCall) {
            _initializing = false;
            emit Initialized(1);
        }
    }

    /**
     * @dev A modifier that defines a protected reinitializer function that can be invoked at most once, and only if the
     * contract hasn't been initialized to a greater version before. In its scope, `onlyInitializing` functions can be
     * used to initialize parent contracts.
     *
     * A reinitializer may be used after the original initialization step. This is essential to configure modules that
     * are added through upgrades and that require initialization.
     *
     * When `version` is 1, this modifier is similar to `initializer`, except that functions marked with `reinitializer`
     * cannot be nested. If one is invoked in the context of another, execution will revert.
     *
     * Note that versions can jump in increments greater than 1; this implies that if multiple reinitializers coexist in
     * a contract, executing them in the right order is up to the developer or operator.
     *
     * WARNING: setting the version to 255 will prevent any future reinitialization.
     *
     * Emits an {Initialized} event.
     */
    modifier reinitializer(uint8 version) {
        require(!_initializing && _initialized < version, "Initializable: contract is already initialized");
        _initialized = version;
        _initializing = true;
        _;
        _initializing = false;
        emit Initialized(version);
    }

    /**
     * @dev Modifier to protect an initialization function so that it can only be invoked by functions with the
     * {initializer} and {reinitializer} modifiers, directly or indirectly.
     */
    modifier onlyInitializing() {
        require(_initializing, "Initializable: contract is not initializing");
        _;
    }

    /**
     * @dev Locks the contract, preventing any future reinitialization. This cannot be part of an initializer call.
     * Calling this in the constructor of a contract will prevent that contract from being initialized or reinitialized
     * to any version. It is recommended to use this to lock implementation contracts that are designed to be called
     * through proxies.
     *
     * Emits an {Initialized} event the first time it is successfully executed.
     */
    function _disableInitializers() internal virtual {
        require(!_initializing, "Initializable: contract is initializing");
        if (_initialized != type(uint8).max) {
            _initialized = type(uint8).max;
            emit Initialized(type(uint8).max);
        }
    }

    /**
     * @dev Returns the highest version that has been initialized. See {reinitializer}.
     */
    function _getInitializedVersion() internal view returns (uint8) {
        return _initialized;
    }

    /**
     * @dev Returns `true` if the contract is currently initializing. See {onlyInitializing}.
     */
    function _isInitializing() internal view returns (bool) {
        return _initializing;
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (proxy/utils/UUPSUpgradeable.sol)

pragma solidity ^0.8.0;

import "../../interfaces/draft-IERC1822Upgradeable.sol";
import "../ERC1967/ERC1967UpgradeUpgradeable.sol";
import "./Initializable.sol";

/**
 * @dev An upgradeability mechanism designed for UUPS proxies. The functions included here can perform an upgrade of an
 * {ERC1967Proxy}, when this contract is set as the implementation behind such a proxy.
 *
 * A security mechanism ensures that an upgrade does not turn off upgradeability accidentally, although this risk is
 * reinstated if the upgrade retains upgradeability but removes the security mechanism, e.g. by replacing
 * `UUPSUpgradeable` with a custom implementation of upgrades.
 *
 * The {_authorizeUpgrade} function must be overridden to include access restriction to the upgrade mechanism.
 *
 * _Available since v4.1._
 */
abstract contract UUPSUpgradeable is Initializable, IERC1822ProxiableUpgradeable, ERC1967UpgradeUpgradeable {
    function __UUPSUpgradeable_init() internal onlyInitializing {
    }

    function __UUPSUpgradeable_init_unchained() internal onlyInitializing {
    }
    /// @custom:oz-upgrades-unsafe-allow state-variable-immutable state-variable-assignment
    address private immutable __self = address(this);

    /**
     * @dev Check that the execution is being performed through a delegatecall call and that the execution context is
     * a proxy contract with an implementation (as defined in ERC1967) pointing to self. This should only be the case
     * for UUPS and transparent proxies that are using the current contract as their implementation. Execution of a
     * function through ERC1167 minimal proxies (clones) would not normally pass this test, but is not guaranteed to
     * fail.
     */
    modifier onlyProxy() {
        require(address(this) != __self, "Function must be called through delegatecall");
        require(_getImplementation() == __self, "Function must be called through active proxy");
        _;
    }

    /**
     * @dev Check that the execution is not being performed through a delegate call. This allows a function to be
     * callable on the implementing contract but not through proxies.
     */
    modifier notDelegated() {
        require(address(this) == __self, "UUPSUpgradeable: must not be called through delegatecall");
        _;
    }

    /**
     * @dev Implementation of the ERC1822 {proxiableUUID} function. This returns the storage slot used by the
     * implementation. It is used to validate the implementation's compatibility when performing an upgrade.
     *
     * IMPORTANT: A proxy pointing at a proxiable contract should not be considered proxiable itself, because this risks
     * bricking a proxy that upgrades to it, by delegating to itself until out of gas. Thus it is critical that this
     * function revert if invoked through a proxy. This is guaranteed by the `notDelegated` modifier.
     */
    function proxiableUUID() external view virtual override notDelegated returns (bytes32) {
        return _IMPLEMENTATION_SLOT;
    }

    /**
     * @dev Upgrade the implementation of the proxy to `newImplementation`.
     *
     * Calls {_authorizeUpgrade}.
     *
     * Emits an {Upgraded} event.
     *
     * @custom:oz-upgrades-unsafe-allow-reachable delegatecall
     */
    function upgradeTo(address newImplementation) public virtual onlyProxy {
        _authorizeUpgrade(newImplementation);
        _upgradeToAndCallUUPS(newImplementation, new bytes(0), false);
    }

    /**
     * @dev Upgrade the implementation of the proxy to `newImplementation`, and subsequently execute the function call
     * encoded in `data`.
     *
     * Calls {_authorizeUpgrade}.
     *
     * Emits an {Upgraded} event.
     *
     * @custom:oz-upgrades-unsafe-allow-reachable delegatecall
     */
    function upgradeToAndCall(address newImplementation, bytes memory data) public payable virtual onlyProxy {
        _authorizeUpgrade(newImplementation);
        _upgradeToAndCallUUPS(newImplementation, data, true);
    }

    /**
     * @dev Function that should revert when `msg.sender` is not authorized to upgrade the contract. Called by
     * {upgradeTo} and {upgradeToAndCall}.
     *
     * Normally, this function will use an xref:access.adoc[access control] modifier such as {Ownable-onlyOwner}.
     *
     * ```solidity
     * function _authorizeUpgrade(address) internal override onlyOwner {}
     * ```
     */
    function _authorizeUpgrade(address newImplementation) internal virtual;

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[50] private __gap;
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (token/ERC20/extensions/IERC20Permit.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 Permit extension allowing approvals to be made via signatures, as defined in
 * https://eips.ethereum.org/EIPS/eip-2612[EIP-2612].
 *
 * Adds the {permit} method, which can be used to change an account's ERC20 allowance (see {IERC20-allowance}) by
 * presenting a message signed by the account. By not relying on {IERC20-approve}, the token holder account doesn't
 * need to send a transaction, and thus is not required to hold Ether at all.
 */
interface IERC20PermitUpgradeable {
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
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20Upgradeable {
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
// OpenZeppelin Contracts (last updated v4.9.3) (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.0;

import "../IERC20Upgradeable.sol";
import "../extensions/IERC20PermitUpgradeable.sol";
import "../../../utils/AddressUpgradeable.sol";

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20Upgradeable {
    using AddressUpgradeable for address;

    /**
     * @dev Transfer `value` amount of `token` from the calling contract to `to`. If `token` returns no value,
     * non-reverting calls are assumed to be successful.
     */
    function safeTransfer(IERC20Upgradeable token, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    /**
     * @dev Transfer `value` amount of `token` from `from` to `to`, spending the approval given by `from` to the
     * calling contract. If `token` returns no value, non-reverting calls are assumed to be successful.
     */
    function safeTransferFrom(IERC20Upgradeable token, address from, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(IERC20Upgradeable token, address spender, uint256 value) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    /**
     * @dev Increase the calling contract's allowance toward `spender` by `value`. If `token` returns no value,
     * non-reverting calls are assumed to be successful.
     */
    function safeIncreaseAllowance(IERC20Upgradeable token, address spender, uint256 value) internal {
        uint256 oldAllowance = token.allowance(address(this), spender);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, oldAllowance + value));
    }

    /**
     * @dev Decrease the calling contract's allowance toward `spender` by `value`. If `token` returns no value,
     * non-reverting calls are assumed to be successful.
     */
    function safeDecreaseAllowance(IERC20Upgradeable token, address spender, uint256 value) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, oldAllowance - value));
        }
    }

    /**
     * @dev Set the calling contract's allowance toward `spender` to `value`. If `token` returns no value,
     * non-reverting calls are assumed to be successful. Meant to be used with tokens that require the approval
     * to be set to zero before setting it to a non-zero value, such as USDT.
     */
    function forceApprove(IERC20Upgradeable token, address spender, uint256 value) internal {
        bytes memory approvalCall = abi.encodeWithSelector(token.approve.selector, spender, value);

        if (!_callOptionalReturnBool(token, approvalCall)) {
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, 0));
            _callOptionalReturn(token, approvalCall);
        }
    }

    /**
     * @dev Use a ERC-2612 signature to set the `owner` approval toward `spender` on `token`.
     * Revert on invalid signature.
     */
    function safePermit(
        IERC20PermitUpgradeable token,
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal {
        uint256 nonceBefore = token.nonces(owner);
        token.permit(owner, spender, value, deadline, v, r, s);
        uint256 nonceAfter = token.nonces(owner);
        require(nonceAfter == nonceBefore + 1, "SafeERC20: permit did not succeed");
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20Upgradeable token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address-functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        require(returndata.length == 0 || abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     *
     * This is a variant of {_callOptionalReturn} that silents catches all reverts and returns a bool instead.
     */
    function _callOptionalReturnBool(IERC20Upgradeable token, bytes memory data) private returns (bool) {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We cannot use {Address-functionCall} here since this should return false
        // and not revert is the subcall reverts.

        (bool success, bytes memory returndata) = address(token).call(data);
        return
            success && (returndata.length == 0 || abi.decode(returndata, (bool))) && AddressUpgradeable.isContract(address(token));
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (utils/Address.sol)

pragma solidity ^0.8.1;

/**
 * @dev Collection of functions related to the address type
 */
library AddressUpgradeable {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     *
     * Furthermore, `isContract` will also return true if the target contract within
     * the same transaction is already scheduled for destruction by `SELFDESTRUCT`,
     * which only has an effect at the end of a transaction.
     * ====
     *
     * [IMPORTANT]
     * ====
     * You shouldn't rely on `isContract` to protect against flash loan attacks!
     *
     * Preventing calls from contracts is highly discouraged. It breaks composability, breaks support for smart wallets
     * like Gnosis Safe, and does not provide security since it can be circumvented by calling from a contract
     * constructor.
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.

        return account.code.length > 0;
    }

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
     * https://solidity.readthedocs.io/en/v0.8.0/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verify that a low level call to smart-contract was successful, and revert (either by bubbling
     * the revert reason or using the provided one) in case of unsuccessful call or if target was not a contract.
     *
     * _Available since v4.8._
     */
    function verifyCallResultFromTarget(
        address target,
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        if (success) {
            if (returndata.length == 0) {
                // only check isContract if the call was successful and the return data is empty
                // otherwise we already know that it was a contract
                require(isContract(target), "Address: call to non-contract");
            }
            return returndata;
        } else {
            _revert(returndata, errorMessage);
        }
    }

    /**
     * @dev Tool to verify that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason or using the provided one.
     *
     * _Available since v4.3._
     */
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            _revert(returndata, errorMessage);
        }
    }

    function _revert(bytes memory returndata, string memory errorMessage) private pure {
        // Look for revert reason and bubble it up if present
        if (returndata.length > 0) {
            // The easiest way to bubble the revert reason is using memory via assembly
            /// @solidity memory-safe-assembly
            assembly {
                let returndata_size := mload(returndata)
                revert(add(32, returndata), returndata_size)
            }
        } else {
            revert(errorMessage);
        }
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;
import "../proxy/utils/Initializable.sol";

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
abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal onlyInitializing {
    }

    function __Context_init_unchained() internal onlyInitializing {
    }
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[50] private __gap;
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/introspection/ERC165.sol)

pragma solidity ^0.8.0;

import "./IERC165Upgradeable.sol";
import "../../proxy/utils/Initializable.sol";

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
abstract contract ERC165Upgradeable is Initializable, IERC165Upgradeable {
    function __ERC165_init() internal onlyInitializing {
    }

    function __ERC165_init_unchained() internal onlyInitializing {
    }
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165Upgradeable).interfaceId;
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[50] private __gap;
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
interface IERC165Upgradeable {
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
// OpenZeppelin Contracts (last updated v4.9.0) (utils/math/Math.sol)

pragma solidity ^0.8.0;

/**
 * @dev Standard math utilities missing in the Solidity language.
 */
library MathUpgradeable {
    enum Rounding {
        Down, // Toward negative infinity
        Up, // Toward infinity
        Zero // Toward zero
    }

    /**
     * @dev Returns the largest of two numbers.
     */
    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a > b ? a : b;
    }

    /**
     * @dev Returns the smallest of two numbers.
     */
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    /**
     * @dev Returns the average of two numbers. The result is rounded towards
     * zero.
     */
    function average(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b) / 2 can overflow.
        return (a & b) + (a ^ b) / 2;
    }

    /**
     * @dev Returns the ceiling of the division of two numbers.
     *
     * This differs from standard division with `/` in that it rounds up instead
     * of rounding down.
     */
    function ceilDiv(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b - 1) / b can overflow on addition, so we distribute.
        return a == 0 ? 0 : (a - 1) / b + 1;
    }

    /**
     * @notice Calculates floor(x * y / denominator) with full precision. Throws if result overflows a uint256 or denominator == 0
     * @dev Original credit to Remco Bloemen under MIT license (https://xn--2-umb.com/21/muldiv)
     * with further edits by Uniswap Labs also under MIT license.
     */
    function mulDiv(uint256 x, uint256 y, uint256 denominator) internal pure returns (uint256 result) {
        unchecked {
            // 512-bit multiply [prod1 prod0] = x * y. Compute the product mod 2^256 and mod 2^256 - 1, then use
            // use the Chinese Remainder Theorem to reconstruct the 512 bit result. The result is stored in two 256
            // variables such that product = prod1 * 2^256 + prod0.
            uint256 prod0; // Least significant 256 bits of the product
            uint256 prod1; // Most significant 256 bits of the product
            assembly {
                let mm := mulmod(x, y, not(0))
                prod0 := mul(x, y)
                prod1 := sub(sub(mm, prod0), lt(mm, prod0))
            }

            // Handle non-overflow cases, 256 by 256 division.
            if (prod1 == 0) {
                // Solidity will revert if denominator == 0, unlike the div opcode on its own.
                // The surrounding unchecked block does not change this fact.
                // See https://docs.soliditylang.org/en/latest/control-structures.html#checked-or-unchecked-arithmetic.
                return prod0 / denominator;
            }

            // Make sure the result is less than 2^256. Also prevents denominator == 0.
            require(denominator > prod1, "Math: mulDiv overflow");

            ///////////////////////////////////////////////
            // 512 by 256 division.
            ///////////////////////////////////////////////

            // Make division exact by subtracting the remainder from [prod1 prod0].
            uint256 remainder;
            assembly {
                // Compute remainder using mulmod.
                remainder := mulmod(x, y, denominator)

                // Subtract 256 bit number from 512 bit number.
                prod1 := sub(prod1, gt(remainder, prod0))
                prod0 := sub(prod0, remainder)
            }

            // Factor powers of two out of denominator and compute largest power of two divisor of denominator. Always >= 1.
            // See https://cs.stackexchange.com/q/138556/92363.

            // Does not overflow because the denominator cannot be zero at this stage in the function.
            uint256 twos = denominator & (~denominator + 1);
            assembly {
                // Divide denominator by twos.
                denominator := div(denominator, twos)

                // Divide [prod1 prod0] by twos.
                prod0 := div(prod0, twos)

                // Flip twos such that it is 2^256 / twos. If twos is zero, then it becomes one.
                twos := add(div(sub(0, twos), twos), 1)
            }

            // Shift in bits from prod1 into prod0.
            prod0 |= prod1 * twos;

            // Invert denominator mod 2^256. Now that denominator is an odd number, it has an inverse modulo 2^256 such
            // that denominator * inv = 1 mod 2^256. Compute the inverse by starting with a seed that is correct for
            // four bits. That is, denominator * inv = 1 mod 2^4.
            uint256 inverse = (3 * denominator) ^ 2;

            // Use the Newton-Raphson iteration to improve the precision. Thanks to Hensel's lifting lemma, this also works
            // in modular arithmetic, doubling the correct bits in each step.
            inverse *= 2 - denominator * inverse; // inverse mod 2^8
            inverse *= 2 - denominator * inverse; // inverse mod 2^16
            inverse *= 2 - denominator * inverse; // inverse mod 2^32
            inverse *= 2 - denominator * inverse; // inverse mod 2^64
            inverse *= 2 - denominator * inverse; // inverse mod 2^128
            inverse *= 2 - denominator * inverse; // inverse mod 2^256

            // Because the division is now exact we can divide by multiplying with the modular inverse of denominator.
            // This will give us the correct result modulo 2^256. Since the preconditions guarantee that the outcome is
            // less than 2^256, this is the final result. We don't need to compute the high bits of the result and prod1
            // is no longer required.
            result = prod0 * inverse;
            return result;
        }
    }

    /**
     * @notice Calculates x * y / denominator with full precision, following the selected rounding direction.
     */
    function mulDiv(uint256 x, uint256 y, uint256 denominator, Rounding rounding) internal pure returns (uint256) {
        uint256 result = mulDiv(x, y, denominator);
        if (rounding == Rounding.Up && mulmod(x, y, denominator) > 0) {
            result += 1;
        }
        return result;
    }

    /**
     * @dev Returns the square root of a number. If the number is not a perfect square, the value is rounded down.
     *
     * Inspired by Henry S. Warren, Jr.'s "Hacker's Delight" (Chapter 11).
     */
    function sqrt(uint256 a) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        // For our first guess, we get the biggest power of 2 which is smaller than the square root of the target.
        //
        // We know that the "msb" (most significant bit) of our target number `a` is a power of 2 such that we have
        // `msb(a) <= a < 2*msb(a)`. This value can be written `msb(a)=2**k` with `k=log2(a)`.
        //
        // This can be rewritten `2**log2(a) <= a < 2**(log2(a) + 1)`
        // → `sqrt(2**k) <= sqrt(a) < sqrt(2**(k+1))`
        // → `2**(k/2) <= sqrt(a) < 2**((k+1)/2) <= 2**(k/2 + 1)`
        //
        // Consequently, `2**(log2(a) / 2)` is a good first approximation of `sqrt(a)` with at least 1 correct bit.
        uint256 result = 1 << (log2(a) >> 1);

        // At this point `result` is an estimation with one bit of precision. We know the true value is a uint128,
        // since it is the square root of a uint256. Newton's method converges quadratically (precision doubles at
        // every iteration). We thus need at most 7 iteration to turn our partial result with one bit of precision
        // into the expected uint128 result.
        unchecked {
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            return min(result, a / result);
        }
    }

    /**
     * @notice Calculates sqrt(a), following the selected rounding direction.
     */
    function sqrt(uint256 a, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = sqrt(a);
            return result + (rounding == Rounding.Up && result * result < a ? 1 : 0);
        }
    }

    /**
     * @dev Return the log in base 2, rounded down, of a positive value.
     * Returns 0 if given 0.
     */
    function log2(uint256 value) internal pure returns (uint256) {
        uint256 result = 0;
        unchecked {
            if (value >> 128 > 0) {
                value >>= 128;
                result += 128;
            }
            if (value >> 64 > 0) {
                value >>= 64;
                result += 64;
            }
            if (value >> 32 > 0) {
                value >>= 32;
                result += 32;
            }
            if (value >> 16 > 0) {
                value >>= 16;
                result += 16;
            }
            if (value >> 8 > 0) {
                value >>= 8;
                result += 8;
            }
            if (value >> 4 > 0) {
                value >>= 4;
                result += 4;
            }
            if (value >> 2 > 0) {
                value >>= 2;
                result += 2;
            }
            if (value >> 1 > 0) {
                result += 1;
            }
        }
        return result;
    }

    /**
     * @dev Return the log in base 2, following the selected rounding direction, of a positive value.
     * Returns 0 if given 0.
     */
    function log2(uint256 value, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = log2(value);
            return result + (rounding == Rounding.Up && 1 << result < value ? 1 : 0);
        }
    }

    /**
     * @dev Return the log in base 10, rounded down, of a positive value.
     * Returns 0 if given 0.
     */
    function log10(uint256 value) internal pure returns (uint256) {
        uint256 result = 0;
        unchecked {
            if (value >= 10 ** 64) {
                value /= 10 ** 64;
                result += 64;
            }
            if (value >= 10 ** 32) {
                value /= 10 ** 32;
                result += 32;
            }
            if (value >= 10 ** 16) {
                value /= 10 ** 16;
                result += 16;
            }
            if (value >= 10 ** 8) {
                value /= 10 ** 8;
                result += 8;
            }
            if (value >= 10 ** 4) {
                value /= 10 ** 4;
                result += 4;
            }
            if (value >= 10 ** 2) {
                value /= 10 ** 2;
                result += 2;
            }
            if (value >= 10 ** 1) {
                result += 1;
            }
        }
        return result;
    }

    /**
     * @dev Return the log in base 10, following the selected rounding direction, of a positive value.
     * Returns 0 if given 0.
     */
    function log10(uint256 value, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = log10(value);
            return result + (rounding == Rounding.Up && 10 ** result < value ? 1 : 0);
        }
    }

    /**
     * @dev Return the log in base 256, rounded down, of a positive value.
     * Returns 0 if given 0.
     *
     * Adding one to the result gives the number of pairs of hex symbols needed to represent `value` as a hex string.
     */
    function log256(uint256 value) internal pure returns (uint256) {
        uint256 result = 0;
        unchecked {
            if (value >> 128 > 0) {
                value >>= 128;
                result += 16;
            }
            if (value >> 64 > 0) {
                value >>= 64;
                result += 8;
            }
            if (value >> 32 > 0) {
                value >>= 32;
                result += 4;
            }
            if (value >> 16 > 0) {
                value >>= 16;
                result += 2;
            }
            if (value >> 8 > 0) {
                result += 1;
            }
        }
        return result;
    }

    /**
     * @dev Return the log in base 256, following the selected rounding direction, of a positive value.
     * Returns 0 if given 0.
     */
    function log256(uint256 value, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = log256(value);
            return result + (rounding == Rounding.Up && 1 << (result << 3) < value ? 1 : 0);
        }
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (utils/math/SignedMath.sol)

pragma solidity ^0.8.0;

/**
 * @dev Standard signed math utilities missing in the Solidity language.
 */
library SignedMathUpgradeable {
    /**
     * @dev Returns the largest of two signed numbers.
     */
    function max(int256 a, int256 b) internal pure returns (int256) {
        return a > b ? a : b;
    }

    /**
     * @dev Returns the smallest of two signed numbers.
     */
    function min(int256 a, int256 b) internal pure returns (int256) {
        return a < b ? a : b;
    }

    /**
     * @dev Returns the average of two signed numbers without overflow.
     * The result is rounded towards zero.
     */
    function average(int256 a, int256 b) internal pure returns (int256) {
        // Formula from the book "Hacker's Delight"
        int256 x = (a & b) + ((a ^ b) >> 1);
        return x + (int256(uint256(x) >> 255) & (a ^ b));
    }

    /**
     * @dev Returns the absolute unsigned value of a signed value.
     */
    function abs(int256 n) internal pure returns (uint256) {
        unchecked {
            // must be unchecked in order to support `n = type(int256).min`
            return uint256(n >= 0 ? n : -n);
        }
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (utils/StorageSlot.sol)
// This file was procedurally generated from scripts/generate/templates/StorageSlot.js.

pragma solidity ^0.8.0;

/**
 * @dev Library for reading and writing primitive types to specific storage slots.
 *
 * Storage slots are often used to avoid storage conflict when dealing with upgradeable contracts.
 * This library helps with reading and writing to such slots without the need for inline assembly.
 *
 * The functions in this library return Slot structs that contain a `value` member that can be used to read or write.
 *
 * Example usage to set ERC1967 implementation slot:
 * ```solidity
 * contract ERC1967 {
 *     bytes32 internal constant _IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;
 *
 *     function _getImplementation() internal view returns (address) {
 *         return StorageSlot.getAddressSlot(_IMPLEMENTATION_SLOT).value;
 *     }
 *
 *     function _setImplementation(address newImplementation) internal {
 *         require(Address.isContract(newImplementation), "ERC1967: new implementation is not a contract");
 *         StorageSlot.getAddressSlot(_IMPLEMENTATION_SLOT).value = newImplementation;
 *     }
 * }
 * ```
 *
 * _Available since v4.1 for `address`, `bool`, `bytes32`, `uint256`._
 * _Available since v4.9 for `string`, `bytes`._
 */
library StorageSlotUpgradeable {
    struct AddressSlot {
        address value;
    }

    struct BooleanSlot {
        bool value;
    }

    struct Bytes32Slot {
        bytes32 value;
    }

    struct Uint256Slot {
        uint256 value;
    }

    struct StringSlot {
        string value;
    }

    struct BytesSlot {
        bytes value;
    }

    /**
     * @dev Returns an `AddressSlot` with member `value` located at `slot`.
     */
    function getAddressSlot(bytes32 slot) internal pure returns (AddressSlot storage r) {
        /// @solidity memory-safe-assembly
        assembly {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `BooleanSlot` with member `value` located at `slot`.
     */
    function getBooleanSlot(bytes32 slot) internal pure returns (BooleanSlot storage r) {
        /// @solidity memory-safe-assembly
        assembly {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `Bytes32Slot` with member `value` located at `slot`.
     */
    function getBytes32Slot(bytes32 slot) internal pure returns (Bytes32Slot storage r) {
        /// @solidity memory-safe-assembly
        assembly {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `Uint256Slot` with member `value` located at `slot`.
     */
    function getUint256Slot(bytes32 slot) internal pure returns (Uint256Slot storage r) {
        /// @solidity memory-safe-assembly
        assembly {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `StringSlot` with member `value` located at `slot`.
     */
    function getStringSlot(bytes32 slot) internal pure returns (StringSlot storage r) {
        /// @solidity memory-safe-assembly
        assembly {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `StringSlot` representation of the string storage pointer `store`.
     */
    function getStringSlot(string storage store) internal pure returns (StringSlot storage r) {
        /// @solidity memory-safe-assembly
        assembly {
            r.slot := store.slot
        }
    }

    /**
     * @dev Returns an `BytesSlot` with member `value` located at `slot`.
     */
    function getBytesSlot(bytes32 slot) internal pure returns (BytesSlot storage r) {
        /// @solidity memory-safe-assembly
        assembly {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `BytesSlot` representation of the bytes storage pointer `store`.
     */
    function getBytesSlot(bytes storage store) internal pure returns (BytesSlot storage r) {
        /// @solidity memory-safe-assembly
        assembly {
            r.slot := store.slot
        }
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (utils/Strings.sol)

pragma solidity ^0.8.0;

import "./math/MathUpgradeable.sol";
import "./math/SignedMathUpgradeable.sol";

/**
 * @dev String operations.
 */
library StringsUpgradeable {
    bytes16 private constant _SYMBOLS = "0123456789abcdef";
    uint8 private constant _ADDRESS_LENGTH = 20;

    /**
     * @dev Converts a `uint256` to its ASCII `string` decimal representation.
     */
    function toString(uint256 value) internal pure returns (string memory) {
        unchecked {
            uint256 length = MathUpgradeable.log10(value) + 1;
            string memory buffer = new string(length);
            uint256 ptr;
            /// @solidity memory-safe-assembly
            assembly {
                ptr := add(buffer, add(32, length))
            }
            while (true) {
                ptr--;
                /// @solidity memory-safe-assembly
                assembly {
                    mstore8(ptr, byte(mod(value, 10), _SYMBOLS))
                }
                value /= 10;
                if (value == 0) break;
            }
            return buffer;
        }
    }

    /**
     * @dev Converts a `int256` to its ASCII `string` decimal representation.
     */
    function toString(int256 value) internal pure returns (string memory) {
        return string(abi.encodePacked(value < 0 ? "-" : "", toString(SignedMathUpgradeable.abs(value))));
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation.
     */
    function toHexString(uint256 value) internal pure returns (string memory) {
        unchecked {
            return toHexString(value, MathUpgradeable.log256(value) + 1);
        }
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation with fixed length.
     */
    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _SYMBOLS[value & 0xf];
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

    /**
     * @dev Returns true if the two strings are equal.
     */
    function equal(string memory a, string memory b) internal pure returns (bool) {
        return keccak256(bytes(a)) == keccak256(bytes(b));
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
library EnumerableSetUpgradeable {
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
// OpenZeppelin Contracts (last updated v4.9.0) (access/AccessControl.sol)

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
                        Strings.toHexString(account),
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
// OpenZeppelin Contracts v4.4.1 (interfaces/IERC20Metadata.sol)

pragma solidity ^0.8.0;

import "../token/ERC20/extensions/IERC20Metadata.sol";
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
// OpenZeppelin Contracts (last updated v4.9.0) (token/ERC20/extensions/IERC20Permit.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 Permit extension allowing approvals to be made via signatures, as defined in
 * https://eips.ethereum.org/EIPS/eip-2612[EIP-2612].
 *
 * Adds the {permit} method, which can be used to change an account's ERC20 allowance (see {IERC20-allowance}) by
 * presenting a message signed by the account. By not relying on {IERC20-approve}, the token holder account doesn't
 * need to send a transaction, and thus is not required to hold Ether at all.
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
// OpenZeppelin Contracts (last updated v4.9.3) (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";
import "../extensions/IERC20Permit.sol";
import "../../../utils/Address.sol";

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
     * @dev Transfer `value` amount of `token` from the calling contract to `to`. If `token` returns no value,
     * non-reverting calls are assumed to be successful.
     */
    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    /**
     * @dev Transfer `value` amount of `token` from `from` to `to`, spending the approval given by `from` to the
     * calling contract. If `token` returns no value, non-reverting calls are assumed to be successful.
     */
    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(IERC20 token, address spender, uint256 value) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    /**
     * @dev Increase the calling contract's allowance toward `spender` by `value`. If `token` returns no value,
     * non-reverting calls are assumed to be successful.
     */
    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 oldAllowance = token.allowance(address(this), spender);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, oldAllowance + value));
    }

    /**
     * @dev Decrease the calling contract's allowance toward `spender` by `value`. If `token` returns no value,
     * non-reverting calls are assumed to be successful.
     */
    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, oldAllowance - value));
        }
    }

    /**
     * @dev Set the calling contract's allowance toward `spender` to `value`. If `token` returns no value,
     * non-reverting calls are assumed to be successful. Meant to be used with tokens that require the approval
     * to be set to zero before setting it to a non-zero value, such as USDT.
     */
    function forceApprove(IERC20 token, address spender, uint256 value) internal {
        bytes memory approvalCall = abi.encodeWithSelector(token.approve.selector, spender, value);

        if (!_callOptionalReturnBool(token, approvalCall)) {
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, 0));
            _callOptionalReturn(token, approvalCall);
        }
    }

    /**
     * @dev Use a ERC-2612 signature to set the `owner` approval toward `spender` on `token`.
     * Revert on invalid signature.
     */
    function safePermit(
        IERC20Permit token,
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal {
        uint256 nonceBefore = token.nonces(owner);
        token.permit(owner, spender, value, deadline, v, r, s);
        uint256 nonceAfter = token.nonces(owner);
        require(nonceAfter == nonceBefore + 1, "SafeERC20: permit did not succeed");
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

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        require(returndata.length == 0 || abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
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
        return
            success && (returndata.length == 0 || abi.decode(returndata, (bool))) && Address.isContract(address(token));
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (utils/Address.sol)

pragma solidity ^0.8.1;

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     *
     * Furthermore, `isContract` will also return true if the target contract within
     * the same transaction is already scheduled for destruction by `SELFDESTRUCT`,
     * which only has an effect at the end of a transaction.
     * ====
     *
     * [IMPORTANT]
     * ====
     * You shouldn't rely on `isContract` to protect against flash loan attacks!
     *
     * Preventing calls from contracts is highly discouraged. It breaks composability, breaks support for smart wallets
     * like Gnosis Safe, and does not provide security since it can be circumvented by calling from a contract
     * constructor.
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.

        return account.code.length > 0;
    }

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
     * https://solidity.readthedocs.io/en/v0.8.0/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verify that a low level call to smart-contract was successful, and revert (either by bubbling
     * the revert reason or using the provided one) in case of unsuccessful call or if target was not a contract.
     *
     * _Available since v4.8._
     */
    function verifyCallResultFromTarget(
        address target,
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        if (success) {
            if (returndata.length == 0) {
                // only check isContract if the call was successful and the return data is empty
                // otherwise we already know that it was a contract
                require(isContract(target), "Address: call to non-contract");
            }
            return returndata;
        } else {
            _revert(returndata, errorMessage);
        }
    }

    /**
     * @dev Tool to verify that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason or using the provided one.
     *
     * _Available since v4.3._
     */
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            _revert(returndata, errorMessage);
        }
    }

    function _revert(bytes memory returndata, string memory errorMessage) private pure {
        // Look for revert reason and bubble it up if present
        if (returndata.length > 0) {
            // The easiest way to bubble the revert reason is using memory via assembly
            /// @solidity memory-safe-assembly
            assembly {
                let returndata_size := mload(returndata)
                revert(add(32, returndata), returndata_size)
            }
        } else {
            revert(errorMessage);
        }
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
// OpenZeppelin Contracts (last updated v4.9.0) (utils/cryptography/ECDSA.sol)

pragma solidity ^0.8.0;

import "../Strings.sol";

/**
 * @dev Elliptic Curve Digital Signature Algorithm (ECDSA) operations.
 *
 * These functions can be used to verify that a message was signed by the holder
 * of the private keys of a given address.
 */
library ECDSA {
    enum RecoverError {
        NoError,
        InvalidSignature,
        InvalidSignatureLength,
        InvalidSignatureS,
        InvalidSignatureV // Deprecated in v4.8
    }

    function _throwError(RecoverError error) private pure {
        if (error == RecoverError.NoError) {
            return; // no error: do nothing
        } else if (error == RecoverError.InvalidSignature) {
            revert("ECDSA: invalid signature");
        } else if (error == RecoverError.InvalidSignatureLength) {
            revert("ECDSA: invalid signature length");
        } else if (error == RecoverError.InvalidSignatureS) {
            revert("ECDSA: invalid signature 's' value");
        }
    }

    /**
     * @dev Returns the address that signed a hashed message (`hash`) with
     * `signature` or error string. This address can then be used for verification purposes.
     *
     * The `ecrecover` EVM opcode allows for malleable (non-unique) signatures:
     * this function rejects them by requiring the `s` value to be in the lower
     * half order, and the `v` value to be either 27 or 28.
     *
     * IMPORTANT: `hash` _must_ be the result of a hash operation for the
     * verification to be secure: it is possible to craft signatures that
     * recover to arbitrary addresses for non-hashed data. A safe way to ensure
     * this is by receiving a hash of the original message (which may otherwise
     * be too long), and then calling {toEthSignedMessageHash} on it.
     *
     * Documentation for signature generation:
     * - with https://web3js.readthedocs.io/en/v1.3.4/web3-eth-accounts.html#sign[Web3.js]
     * - with https://docs.ethers.io/v5/api/signer/#Signer-signMessage[ethers]
     *
     * _Available since v4.3._
     */
    function tryRecover(bytes32 hash, bytes memory signature) internal pure returns (address, RecoverError) {
        if (signature.length == 65) {
            bytes32 r;
            bytes32 s;
            uint8 v;
            // ecrecover takes the signature parameters, and the only way to get them
            // currently is to use assembly.
            /// @solidity memory-safe-assembly
            assembly {
                r := mload(add(signature, 0x20))
                s := mload(add(signature, 0x40))
                v := byte(0, mload(add(signature, 0x60)))
            }
            return tryRecover(hash, v, r, s);
        } else {
            return (address(0), RecoverError.InvalidSignatureLength);
        }
    }

    /**
     * @dev Returns the address that signed a hashed message (`hash`) with
     * `signature`. This address can then be used for verification purposes.
     *
     * The `ecrecover` EVM opcode allows for malleable (non-unique) signatures:
     * this function rejects them by requiring the `s` value to be in the lower
     * half order, and the `v` value to be either 27 or 28.
     *
     * IMPORTANT: `hash` _must_ be the result of a hash operation for the
     * verification to be secure: it is possible to craft signatures that
     * recover to arbitrary addresses for non-hashed data. A safe way to ensure
     * this is by receiving a hash of the original message (which may otherwise
     * be too long), and then calling {toEthSignedMessageHash} on it.
     */
    function recover(bytes32 hash, bytes memory signature) internal pure returns (address) {
        (address recovered, RecoverError error) = tryRecover(hash, signature);
        _throwError(error);
        return recovered;
    }

    /**
     * @dev Overload of {ECDSA-tryRecover} that receives the `r` and `vs` short-signature fields separately.
     *
     * See https://eips.ethereum.org/EIPS/eip-2098[EIP-2098 short signatures]
     *
     * _Available since v4.3._
     */
    function tryRecover(bytes32 hash, bytes32 r, bytes32 vs) internal pure returns (address, RecoverError) {
        bytes32 s = vs & bytes32(0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff);
        uint8 v = uint8((uint256(vs) >> 255) + 27);
        return tryRecover(hash, v, r, s);
    }

    /**
     * @dev Overload of {ECDSA-recover} that receives the `r and `vs` short-signature fields separately.
     *
     * _Available since v4.2._
     */
    function recover(bytes32 hash, bytes32 r, bytes32 vs) internal pure returns (address) {
        (address recovered, RecoverError error) = tryRecover(hash, r, vs);
        _throwError(error);
        return recovered;
    }

    /**
     * @dev Overload of {ECDSA-tryRecover} that receives the `v`,
     * `r` and `s` signature fields separately.
     *
     * _Available since v4.3._
     */
    function tryRecover(bytes32 hash, uint8 v, bytes32 r, bytes32 s) internal pure returns (address, RecoverError) {
        // EIP-2 still allows signature malleability for ecrecover(). Remove this possibility and make the signature
        // unique. Appendix F in the Ethereum Yellow paper (https://ethereum.github.io/yellowpaper/paper.pdf), defines
        // the valid range for s in (301): 0 < s < secp256k1n ÷ 2 + 1, and for v in (302): v ∈ {27, 28}. Most
        // signatures from current libraries generate a unique signature with an s-value in the lower half order.
        //
        // If your library generates malleable signatures, such as s-values in the upper range, calculate a new s-value
        // with 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141 - s1 and flip v from 27 to 28 or
        // vice versa. If your library also generates signatures with 0/1 for v instead 27/28, add 27 to v to accept
        // these malleable signatures as well.
        if (uint256(s) > 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0) {
            return (address(0), RecoverError.InvalidSignatureS);
        }

        // If the signature is valid (and not malleable), return the signer address
        address signer = ecrecover(hash, v, r, s);
        if (signer == address(0)) {
            return (address(0), RecoverError.InvalidSignature);
        }

        return (signer, RecoverError.NoError);
    }

    /**
     * @dev Overload of {ECDSA-recover} that receives the `v`,
     * `r` and `s` signature fields separately.
     */
    function recover(bytes32 hash, uint8 v, bytes32 r, bytes32 s) internal pure returns (address) {
        (address recovered, RecoverError error) = tryRecover(hash, v, r, s);
        _throwError(error);
        return recovered;
    }

    /**
     * @dev Returns an Ethereum Signed Message, created from a `hash`. This
     * produces hash corresponding to the one signed with the
     * https://eth.wiki/json-rpc/API#eth_sign[`eth_sign`]
     * JSON-RPC method as part of EIP-191.
     *
     * See {recover}.
     */
    function toEthSignedMessageHash(bytes32 hash) internal pure returns (bytes32 message) {
        // 32 is the length in bytes of hash,
        // enforced by the type signature above
        /// @solidity memory-safe-assembly
        assembly {
            mstore(0x00, "\x19Ethereum Signed Message:\n32")
            mstore(0x1c, hash)
            message := keccak256(0x00, 0x3c)
        }
    }

    /**
     * @dev Returns an Ethereum Signed Message, created from `s`. This
     * produces hash corresponding to the one signed with the
     * https://eth.wiki/json-rpc/API#eth_sign[`eth_sign`]
     * JSON-RPC method as part of EIP-191.
     *
     * See {recover}.
     */
    function toEthSignedMessageHash(bytes memory s) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n", Strings.toString(s.length), s));
    }

    /**
     * @dev Returns an Ethereum Signed Typed Data, created from a
     * `domainSeparator` and a `structHash`. This produces hash corresponding
     * to the one signed with the
     * https://eips.ethereum.org/EIPS/eip-712[`eth_signTypedData`]
     * JSON-RPC method as part of EIP-712.
     *
     * See {recover}.
     */
    function toTypedDataHash(bytes32 domainSeparator, bytes32 structHash) internal pure returns (bytes32 data) {
        /// @solidity memory-safe-assembly
        assembly {
            let ptr := mload(0x40)
            mstore(ptr, "\x19\x01")
            mstore(add(ptr, 0x02), domainSeparator)
            mstore(add(ptr, 0x22), structHash)
            data := keccak256(ptr, 0x42)
        }
    }

    /**
     * @dev Returns an Ethereum Signed Data with intended validator, created from a
     * `validator` and `data` according to the version 0 of EIP-191.
     *
     * See {recover}.
     */
    function toDataWithIntendedValidatorHash(address validator, bytes memory data) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19\x00", validator, data));
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.2) (utils/cryptography/MerkleProof.sol)

pragma solidity ^0.8.0;

/**
 * @dev These functions deal with verification of Merkle Tree proofs.
 *
 * The tree and the proofs can be generated using our
 * https://github.com/OpenZeppelin/merkle-tree[JavaScript library].
 * You will find a quickstart guide in the readme.
 *
 * WARNING: You should avoid using leaf values that are 64 bytes long prior to
 * hashing, or use a hash function other than keccak256 for hashing leaves.
 * This is because the concatenation of a sorted pair of internal nodes in
 * the merkle tree could be reinterpreted as a leaf value.
 * OpenZeppelin's JavaScript library generates merkle trees that are safe
 * against this attack out of the box.
 */
library MerkleProof {
    /**
     * @dev Returns true if a `leaf` can be proved to be a part of a Merkle tree
     * defined by `root`. For this, a `proof` must be provided, containing
     * sibling hashes on the branch from the leaf to the root of the tree. Each
     * pair of leaves and each pair of pre-images are assumed to be sorted.
     */
    function verify(bytes32[] memory proof, bytes32 root, bytes32 leaf) internal pure returns (bool) {
        return processProof(proof, leaf) == root;
    }

    /**
     * @dev Calldata version of {verify}
     *
     * _Available since v4.7._
     */
    function verifyCalldata(bytes32[] calldata proof, bytes32 root, bytes32 leaf) internal pure returns (bool) {
        return processProofCalldata(proof, leaf) == root;
    }

    /**
     * @dev Returns the rebuilt hash obtained by traversing a Merkle tree up
     * from `leaf` using `proof`. A `proof` is valid if and only if the rebuilt
     * hash matches the root of the tree. When processing the proof, the pairs
     * of leafs & pre-images are assumed to be sorted.
     *
     * _Available since v4.4._
     */
    function processProof(bytes32[] memory proof, bytes32 leaf) internal pure returns (bytes32) {
        bytes32 computedHash = leaf;
        for (uint256 i = 0; i < proof.length; i++) {
            computedHash = _hashPair(computedHash, proof[i]);
        }
        return computedHash;
    }

    /**
     * @dev Calldata version of {processProof}
     *
     * _Available since v4.7._
     */
    function processProofCalldata(bytes32[] calldata proof, bytes32 leaf) internal pure returns (bytes32) {
        bytes32 computedHash = leaf;
        for (uint256 i = 0; i < proof.length; i++) {
            computedHash = _hashPair(computedHash, proof[i]);
        }
        return computedHash;
    }

    /**
     * @dev Returns true if the `leaves` can be simultaneously proven to be a part of a merkle tree defined by
     * `root`, according to `proof` and `proofFlags` as described in {processMultiProof}.
     *
     * CAUTION: Not all merkle trees admit multiproofs. See {processMultiProof} for details.
     *
     * _Available since v4.7._
     */
    function multiProofVerify(
        bytes32[] memory proof,
        bool[] memory proofFlags,
        bytes32 root,
        bytes32[] memory leaves
    ) internal pure returns (bool) {
        return processMultiProof(proof, proofFlags, leaves) == root;
    }

    /**
     * @dev Calldata version of {multiProofVerify}
     *
     * CAUTION: Not all merkle trees admit multiproofs. See {processMultiProof} for details.
     *
     * _Available since v4.7._
     */
    function multiProofVerifyCalldata(
        bytes32[] calldata proof,
        bool[] calldata proofFlags,
        bytes32 root,
        bytes32[] memory leaves
    ) internal pure returns (bool) {
        return processMultiProofCalldata(proof, proofFlags, leaves) == root;
    }

    /**
     * @dev Returns the root of a tree reconstructed from `leaves` and sibling nodes in `proof`. The reconstruction
     * proceeds by incrementally reconstructing all inner nodes by combining a leaf/inner node with either another
     * leaf/inner node or a proof sibling node, depending on whether each `proofFlags` item is true or false
     * respectively.
     *
     * CAUTION: Not all merkle trees admit multiproofs. To use multiproofs, it is sufficient to ensure that: 1) the tree
     * is complete (but not necessarily perfect), 2) the leaves to be proven are in the opposite order they are in the
     * tree (i.e., as seen from right to left starting at the deepest layer and continuing at the next layer).
     *
     * _Available since v4.7._
     */
    function processMultiProof(
        bytes32[] memory proof,
        bool[] memory proofFlags,
        bytes32[] memory leaves
    ) internal pure returns (bytes32 merkleRoot) {
        // This function rebuilds the root hash by traversing the tree up from the leaves. The root is rebuilt by
        // consuming and producing values on a queue. The queue starts with the `leaves` array, then goes onto the
        // `hashes` array. At the end of the process, the last hash in the `hashes` array should contain the root of
        // the merkle tree.
        uint256 leavesLen = leaves.length;
        uint256 proofLen = proof.length;
        uint256 totalHashes = proofFlags.length;

        // Check proof validity.
        require(leavesLen + proofLen - 1 == totalHashes, "MerkleProof: invalid multiproof");

        // The xxxPos values are "pointers" to the next value to consume in each array. All accesses are done using
        // `xxx[xxxPos++]`, which return the current value and increment the pointer, thus mimicking a queue's "pop".
        bytes32[] memory hashes = new bytes32[](totalHashes);
        uint256 leafPos = 0;
        uint256 hashPos = 0;
        uint256 proofPos = 0;
        // At each step, we compute the next hash using two values:
        // - a value from the "main queue". If not all leaves have been consumed, we get the next leaf, otherwise we
        //   get the next hash.
        // - depending on the flag, either another value from the "main queue" (merging branches) or an element from the
        //   `proof` array.
        for (uint256 i = 0; i < totalHashes; i++) {
            bytes32 a = leafPos < leavesLen ? leaves[leafPos++] : hashes[hashPos++];
            bytes32 b = proofFlags[i]
                ? (leafPos < leavesLen ? leaves[leafPos++] : hashes[hashPos++])
                : proof[proofPos++];
            hashes[i] = _hashPair(a, b);
        }

        if (totalHashes > 0) {
            require(proofPos == proofLen, "MerkleProof: invalid multiproof");
            unchecked {
                return hashes[totalHashes - 1];
            }
        } else if (leavesLen > 0) {
            return leaves[0];
        } else {
            return proof[0];
        }
    }

    /**
     * @dev Calldata version of {processMultiProof}.
     *
     * CAUTION: Not all merkle trees admit multiproofs. See {processMultiProof} for details.
     *
     * _Available since v4.7._
     */
    function processMultiProofCalldata(
        bytes32[] calldata proof,
        bool[] calldata proofFlags,
        bytes32[] memory leaves
    ) internal pure returns (bytes32 merkleRoot) {
        // This function rebuilds the root hash by traversing the tree up from the leaves. The root is rebuilt by
        // consuming and producing values on a queue. The queue starts with the `leaves` array, then goes onto the
        // `hashes` array. At the end of the process, the last hash in the `hashes` array should contain the root of
        // the merkle tree.
        uint256 leavesLen = leaves.length;
        uint256 proofLen = proof.length;
        uint256 totalHashes = proofFlags.length;

        // Check proof validity.
        require(leavesLen + proofLen - 1 == totalHashes, "MerkleProof: invalid multiproof");

        // The xxxPos values are "pointers" to the next value to consume in each array. All accesses are done using
        // `xxx[xxxPos++]`, which return the current value and increment the pointer, thus mimicking a queue's "pop".
        bytes32[] memory hashes = new bytes32[](totalHashes);
        uint256 leafPos = 0;
        uint256 hashPos = 0;
        uint256 proofPos = 0;
        // At each step, we compute the next hash using two values:
        // - a value from the "main queue". If not all leaves have been consumed, we get the next leaf, otherwise we
        //   get the next hash.
        // - depending on the flag, either another value from the "main queue" (merging branches) or an element from the
        //   `proof` array.
        for (uint256 i = 0; i < totalHashes; i++) {
            bytes32 a = leafPos < leavesLen ? leaves[leafPos++] : hashes[hashPos++];
            bytes32 b = proofFlags[i]
                ? (leafPos < leavesLen ? leaves[leafPos++] : hashes[hashPos++])
                : proof[proofPos++];
            hashes[i] = _hashPair(a, b);
        }

        if (totalHashes > 0) {
            require(proofPos == proofLen, "MerkleProof: invalid multiproof");
            unchecked {
                return hashes[totalHashes - 1];
            }
        } else if (leavesLen > 0) {
            return leaves[0];
        } else {
            return proof[0];
        }
    }

    function _hashPair(bytes32 a, bytes32 b) private pure returns (bytes32) {
        return a < b ? _efficientHash(a, b) : _efficientHash(b, a);
    }

    function _efficientHash(bytes32 a, bytes32 b) private pure returns (bytes32 value) {
        /// @solidity memory-safe-assembly
        assembly {
            mstore(0x00, a)
            mstore(0x20, b)
            value := keccak256(0x00, 0x40)
        }
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
// OpenZeppelin Contracts (last updated v4.9.0) (utils/math/Math.sol)

pragma solidity ^0.8.0;

/**
 * @dev Standard math utilities missing in the Solidity language.
 */
library Math {
    enum Rounding {
        Down, // Toward negative infinity
        Up, // Toward infinity
        Zero // Toward zero
    }

    /**
     * @dev Returns the largest of two numbers.
     */
    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a > b ? a : b;
    }

    /**
     * @dev Returns the smallest of two numbers.
     */
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    /**
     * @dev Returns the average of two numbers. The result is rounded towards
     * zero.
     */
    function average(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b) / 2 can overflow.
        return (a & b) + (a ^ b) / 2;
    }

    /**
     * @dev Returns the ceiling of the division of two numbers.
     *
     * This differs from standard division with `/` in that it rounds up instead
     * of rounding down.
     */
    function ceilDiv(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b - 1) / b can overflow on addition, so we distribute.
        return a == 0 ? 0 : (a - 1) / b + 1;
    }

    /**
     * @notice Calculates floor(x * y / denominator) with full precision. Throws if result overflows a uint256 or denominator == 0
     * @dev Original credit to Remco Bloemen under MIT license (https://xn--2-umb.com/21/muldiv)
     * with further edits by Uniswap Labs also under MIT license.
     */
    function mulDiv(uint256 x, uint256 y, uint256 denominator) internal pure returns (uint256 result) {
        unchecked {
            // 512-bit multiply [prod1 prod0] = x * y. Compute the product mod 2^256 and mod 2^256 - 1, then use
            // use the Chinese Remainder Theorem to reconstruct the 512 bit result. The result is stored in two 256
            // variables such that product = prod1 * 2^256 + prod0.
            uint256 prod0; // Least significant 256 bits of the product
            uint256 prod1; // Most significant 256 bits of the product
            assembly {
                let mm := mulmod(x, y, not(0))
                prod0 := mul(x, y)
                prod1 := sub(sub(mm, prod0), lt(mm, prod0))
            }

            // Handle non-overflow cases, 256 by 256 division.
            if (prod1 == 0) {
                // Solidity will revert if denominator == 0, unlike the div opcode on its own.
                // The surrounding unchecked block does not change this fact.
                // See https://docs.soliditylang.org/en/latest/control-structures.html#checked-or-unchecked-arithmetic.
                return prod0 / denominator;
            }

            // Make sure the result is less than 2^256. Also prevents denominator == 0.
            require(denominator > prod1, "Math: mulDiv overflow");

            ///////////////////////////////////////////////
            // 512 by 256 division.
            ///////////////////////////////////////////////

            // Make division exact by subtracting the remainder from [prod1 prod0].
            uint256 remainder;
            assembly {
                // Compute remainder using mulmod.
                remainder := mulmod(x, y, denominator)

                // Subtract 256 bit number from 512 bit number.
                prod1 := sub(prod1, gt(remainder, prod0))
                prod0 := sub(prod0, remainder)
            }

            // Factor powers of two out of denominator and compute largest power of two divisor of denominator. Always >= 1.
            // See https://cs.stackexchange.com/q/138556/92363.

            // Does not overflow because the denominator cannot be zero at this stage in the function.
            uint256 twos = denominator & (~denominator + 1);
            assembly {
                // Divide denominator by twos.
                denominator := div(denominator, twos)

                // Divide [prod1 prod0] by twos.
                prod0 := div(prod0, twos)

                // Flip twos such that it is 2^256 / twos. If twos is zero, then it becomes one.
                twos := add(div(sub(0, twos), twos), 1)
            }

            // Shift in bits from prod1 into prod0.
            prod0 |= prod1 * twos;

            // Invert denominator mod 2^256. Now that denominator is an odd number, it has an inverse modulo 2^256 such
            // that denominator * inv = 1 mod 2^256. Compute the inverse by starting with a seed that is correct for
            // four bits. That is, denominator * inv = 1 mod 2^4.
            uint256 inverse = (3 * denominator) ^ 2;

            // Use the Newton-Raphson iteration to improve the precision. Thanks to Hensel's lifting lemma, this also works
            // in modular arithmetic, doubling the correct bits in each step.
            inverse *= 2 - denominator * inverse; // inverse mod 2^8
            inverse *= 2 - denominator * inverse; // inverse mod 2^16
            inverse *= 2 - denominator * inverse; // inverse mod 2^32
            inverse *= 2 - denominator * inverse; // inverse mod 2^64
            inverse *= 2 - denominator * inverse; // inverse mod 2^128
            inverse *= 2 - denominator * inverse; // inverse mod 2^256

            // Because the division is now exact we can divide by multiplying with the modular inverse of denominator.
            // This will give us the correct result modulo 2^256. Since the preconditions guarantee that the outcome is
            // less than 2^256, this is the final result. We don't need to compute the high bits of the result and prod1
            // is no longer required.
            result = prod0 * inverse;
            return result;
        }
    }

    /**
     * @notice Calculates x * y / denominator with full precision, following the selected rounding direction.
     */
    function mulDiv(uint256 x, uint256 y, uint256 denominator, Rounding rounding) internal pure returns (uint256) {
        uint256 result = mulDiv(x, y, denominator);
        if (rounding == Rounding.Up && mulmod(x, y, denominator) > 0) {
            result += 1;
        }
        return result;
    }

    /**
     * @dev Returns the square root of a number. If the number is not a perfect square, the value is rounded down.
     *
     * Inspired by Henry S. Warren, Jr.'s "Hacker's Delight" (Chapter 11).
     */
    function sqrt(uint256 a) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        // For our first guess, we get the biggest power of 2 which is smaller than the square root of the target.
        //
        // We know that the "msb" (most significant bit) of our target number `a` is a power of 2 such that we have
        // `msb(a) <= a < 2*msb(a)`. This value can be written `msb(a)=2**k` with `k=log2(a)`.
        //
        // This can be rewritten `2**log2(a) <= a < 2**(log2(a) + 1)`
        // → `sqrt(2**k) <= sqrt(a) < sqrt(2**(k+1))`
        // → `2**(k/2) <= sqrt(a) < 2**((k+1)/2) <= 2**(k/2 + 1)`
        //
        // Consequently, `2**(log2(a) / 2)` is a good first approximation of `sqrt(a)` with at least 1 correct bit.
        uint256 result = 1 << (log2(a) >> 1);

        // At this point `result` is an estimation with one bit of precision. We know the true value is a uint128,
        // since it is the square root of a uint256. Newton's method converges quadratically (precision doubles at
        // every iteration). We thus need at most 7 iteration to turn our partial result with one bit of precision
        // into the expected uint128 result.
        unchecked {
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            return min(result, a / result);
        }
    }

    /**
     * @notice Calculates sqrt(a), following the selected rounding direction.
     */
    function sqrt(uint256 a, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = sqrt(a);
            return result + (rounding == Rounding.Up && result * result < a ? 1 : 0);
        }
    }

    /**
     * @dev Return the log in base 2, rounded down, of a positive value.
     * Returns 0 if given 0.
     */
    function log2(uint256 value) internal pure returns (uint256) {
        uint256 result = 0;
        unchecked {
            if (value >> 128 > 0) {
                value >>= 128;
                result += 128;
            }
            if (value >> 64 > 0) {
                value >>= 64;
                result += 64;
            }
            if (value >> 32 > 0) {
                value >>= 32;
                result += 32;
            }
            if (value >> 16 > 0) {
                value >>= 16;
                result += 16;
            }
            if (value >> 8 > 0) {
                value >>= 8;
                result += 8;
            }
            if (value >> 4 > 0) {
                value >>= 4;
                result += 4;
            }
            if (value >> 2 > 0) {
                value >>= 2;
                result += 2;
            }
            if (value >> 1 > 0) {
                result += 1;
            }
        }
        return result;
    }

    /**
     * @dev Return the log in base 2, following the selected rounding direction, of a positive value.
     * Returns 0 if given 0.
     */
    function log2(uint256 value, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = log2(value);
            return result + (rounding == Rounding.Up && 1 << result < value ? 1 : 0);
        }
    }

    /**
     * @dev Return the log in base 10, rounded down, of a positive value.
     * Returns 0 if given 0.
     */
    function log10(uint256 value) internal pure returns (uint256) {
        uint256 result = 0;
        unchecked {
            if (value >= 10 ** 64) {
                value /= 10 ** 64;
                result += 64;
            }
            if (value >= 10 ** 32) {
                value /= 10 ** 32;
                result += 32;
            }
            if (value >= 10 ** 16) {
                value /= 10 ** 16;
                result += 16;
            }
            if (value >= 10 ** 8) {
                value /= 10 ** 8;
                result += 8;
            }
            if (value >= 10 ** 4) {
                value /= 10 ** 4;
                result += 4;
            }
            if (value >= 10 ** 2) {
                value /= 10 ** 2;
                result += 2;
            }
            if (value >= 10 ** 1) {
                result += 1;
            }
        }
        return result;
    }

    /**
     * @dev Return the log in base 10, following the selected rounding direction, of a positive value.
     * Returns 0 if given 0.
     */
    function log10(uint256 value, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = log10(value);
            return result + (rounding == Rounding.Up && 10 ** result < value ? 1 : 0);
        }
    }

    /**
     * @dev Return the log in base 256, rounded down, of a positive value.
     * Returns 0 if given 0.
     *
     * Adding one to the result gives the number of pairs of hex symbols needed to represent `value` as a hex string.
     */
    function log256(uint256 value) internal pure returns (uint256) {
        uint256 result = 0;
        unchecked {
            if (value >> 128 > 0) {
                value >>= 128;
                result += 16;
            }
            if (value >> 64 > 0) {
                value >>= 64;
                result += 8;
            }
            if (value >> 32 > 0) {
                value >>= 32;
                result += 4;
            }
            if (value >> 16 > 0) {
                value >>= 16;
                result += 2;
            }
            if (value >> 8 > 0) {
                result += 1;
            }
        }
        return result;
    }

    /**
     * @dev Return the log in base 256, following the selected rounding direction, of a positive value.
     * Returns 0 if given 0.
     */
    function log256(uint256 value, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = log256(value);
            return result + (rounding == Rounding.Up && 1 << (result << 3) < value ? 1 : 0);
        }
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (utils/math/SignedMath.sol)

pragma solidity ^0.8.0;

/**
 * @dev Standard signed math utilities missing in the Solidity language.
 */
library SignedMath {
    /**
     * @dev Returns the largest of two signed numbers.
     */
    function max(int256 a, int256 b) internal pure returns (int256) {
        return a > b ? a : b;
    }

    /**
     * @dev Returns the smallest of two signed numbers.
     */
    function min(int256 a, int256 b) internal pure returns (int256) {
        return a < b ? a : b;
    }

    /**
     * @dev Returns the average of two signed numbers without overflow.
     * The result is rounded towards zero.
     */
    function average(int256 a, int256 b) internal pure returns (int256) {
        // Formula from the book "Hacker's Delight"
        int256 x = (a & b) + ((a ^ b) >> 1);
        return x + (int256(uint256(x) >> 255) & (a ^ b));
    }

    /**
     * @dev Returns the absolute unsigned value of a signed value.
     */
    function abs(int256 n) internal pure returns (uint256) {
        unchecked {
            // must be unchecked in order to support `n = type(int256).min`
            return uint256(n >= 0 ? n : -n);
        }
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (utils/Strings.sol)

pragma solidity ^0.8.0;

import "./math/Math.sol";
import "./math/SignedMath.sol";

/**
 * @dev String operations.
 */
library Strings {
    bytes16 private constant _SYMBOLS = "0123456789abcdef";
    uint8 private constant _ADDRESS_LENGTH = 20;

    /**
     * @dev Converts a `uint256` to its ASCII `string` decimal representation.
     */
    function toString(uint256 value) internal pure returns (string memory) {
        unchecked {
            uint256 length = Math.log10(value) + 1;
            string memory buffer = new string(length);
            uint256 ptr;
            /// @solidity memory-safe-assembly
            assembly {
                ptr := add(buffer, add(32, length))
            }
            while (true) {
                ptr--;
                /// @solidity memory-safe-assembly
                assembly {
                    mstore8(ptr, byte(mod(value, 10), _SYMBOLS))
                }
                value /= 10;
                if (value == 0) break;
            }
            return buffer;
        }
    }

    /**
     * @dev Converts a `int256` to its ASCII `string` decimal representation.
     */
    function toString(int256 value) internal pure returns (string memory) {
        return string(abi.encodePacked(value < 0 ? "-" : "", toString(SignedMath.abs(value))));
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation.
     */
    function toHexString(uint256 value) internal pure returns (string memory) {
        unchecked {
            return toHexString(value, Math.log256(value) + 1);
        }
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation with fixed length.
     */
    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _SYMBOLS[value & 0xf];
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

    /**
     * @dev Returns true if the two strings are equal.
     */
    function equal(string memory a, string memory b) internal pure returns (bool) {
        return keccak256(bytes(a)) == keccak256(bytes(b));
    }
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import {UUPSUpgradeable} from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import {ECDSA} from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import {IERC20Upgradeable} from "@openzeppelin/contracts-upgradeable/interfaces/IERC20Upgradeable.sol";
import {SafeERC20Upgradeable} from "@openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol";
import {ForwarderRecipientUpgradeable} from "../forwarder/ForwarderRecipientUpgradeable.sol";
import {IStakingManagerPermissioned} from "../interfaces/IStakingManagerPermissioned.sol";
import {IEpochsManager} from "../interfaces/IEpochsManager.sol";
import {ILendingManager} from "../interfaces/ILendingManager.sol";
import {IRegistrationManager} from "../interfaces/IRegistrationManager.sol";
import {IFeesManager} from "../interfaces/IFeesManager.sol";
import {IGovernanceMessageEmitter} from "../interfaces/external/IGovernanceMessageEmitter.sol";
import {Roles} from "../libraries/Roles.sol";
import {Errors} from "../libraries/Errors.sol";
import {Constants} from "../libraries//Constants.sol";
import {Helpers} from "../libraries/Helpers.sol";

contract RegistrationManager is IRegistrationManager, Initializable, UUPSUpgradeable, ForwarderRecipientUpgradeable {
    using SafeERC20Upgradeable for IERC20Upgradeable;

    mapping(address => Registration) private _sentinelRegistrations;
    mapping(address => address) private _ownersSentinel;

    uint24[] private _sentinelsEpochsTotalStakedAmount;
    mapping(address => uint24[]) private _sentinelsEpochsStakedAmount;

    address public stakingManager;
    address public token;
    address public epochsManager;
    address public lendingManager;

    //v1.1.0
    mapping(address => Registration) private _guardianRegistrations;
    mapping(address => address) private _ownersGuardian;
    mapping(uint16 => uint16) private _epochsTotalNumberOfGuardians;
    mapping(uint16 => mapping(address => uint16)) private _pendingLightResumes;
    mapping(uint16 => mapping(address => uint16)) private _slashes;
    address public feesManager;
    address public governanceMessageEmitter;

    function initialize(
        address _token,
        address _stakingManager,
        address _epochsManager,
        address _lendingManager,
        address _forwarder
    ) public initializer {
        __UUPSUpgradeable_init();
        __AccessControlEnumerable_init();
        __ForwarderRecipientUpgradeable_init(_forwarder);

        _grantRole(DEFAULT_ADMIN_ROLE, _msgSender());
        _grantRole(SET_FORWARDER_ROLE, _msgSender());

        stakingManager = _stakingManager;
        token = _token;
        epochsManager = _epochsManager;
        lendingManager = _lendingManager;

        _sentinelsEpochsTotalStakedAmount = new uint24[](Constants.AVAILABLE_EPOCHS);
    }

    /// @inheritdoc IRegistrationManager
    function getSentinelAddressFromSignature(address owner, bytes calldata signature) public pure returns (address) {
        bytes32 message = ECDSA.toEthSignedMessageHash(keccak256(abi.encodePacked(owner)));
        return ECDSA.recover(message, signature);
    }

    /// @inheritdoc IRegistrationManager
    function guardianRegistration(address guardian) external view returns (Registration memory) {
        return _guardianRegistrations[guardian];
    }

    /// @inheritdoc IRegistrationManager
    function guardianOf(address owner) external view returns (address) {
        return _ownersGuardian[owner];
    }

    /// @inheritdoc IRegistrationManager
    function hardResumeSentinel(uint256 amount, address owner, bytes calldata signature) external {
        uint16 currentEpoch = IEpochsManager(epochsManager).currentEpoch();
        address sentinel = getSentinelAddressFromSignature(owner, signature);

        Registration storage registration = _sentinelRegistrations[sentinel];
        bytes1 registrationKind = registration.kind;
        uint16 registrationEndEpoch = registration.endEpoch;

        if (registrationKind != Constants.REGISTRATION_SENTINEL_STAKING || registrationEndEpoch < currentEpoch) {
            revert Errors.InvalidRegistration();
        }

        if (amount == 0) {
            revert Errors.InvalidAmount();
        }

        uint24 truncatedAmount = Helpers.truncate(amount);
        for (uint16 epoch = currentEpoch; epoch <= registrationEndEpoch; ) {
            _sentinelsEpochsStakedAmount[sentinel][epoch] += truncatedAmount;

            if (
                _sentinelsEpochsStakedAmount[sentinel][epoch] <
                Constants.STAKING_MIN_AMOUT_FOR_SENTINEL_REGISTRATION_TRUNCATED
            ) {
                revert Errors.AmountNotAvailableInEpoch(epoch);
            }

            _sentinelsEpochsTotalStakedAmount[epoch] += truncatedAmount;

            unchecked {
                ++epoch;
            }
        }

        IERC20Upgradeable(token).safeTransferFrom(owner, address(this), amount);
        IERC20Upgradeable(token).approve(stakingManager, amount);
        // NOTE: since this fx will be called by staking sentinels that would want to increase their amount
        // at stake for example after a slashing in order to be resumable, they wont be able to do it
        // if the remaining staking time is less than 7 days in order to avoid abuses.
        IStakingManagerPermissioned(stakingManager).increaseAmount(owner, amount);

        IGovernanceMessageEmitter(governanceMessageEmitter).resumeSentinel(sentinel);
        emit SentinelHardResumed(sentinel);
    }

    /// @inheritdoc IRegistrationManager
    function increaseSentinelRegistrationDuration(uint64 duration) external {
        _increaseSentinelRegistrationDuration(_msgSender(), duration);
    }

    /// @inheritdoc IRegistrationManager
    function increaseSentinelRegistrationDuration(address owner, uint64 duration) external onlyForwarder {
        _increaseSentinelRegistrationDuration(owner, duration);
    }

    /// @inheritdoc IRegistrationManager
    function lightResumeGuardian() external {
        uint16 currentEpoch = IEpochsManager(epochsManager).currentEpoch();
        address guardian = _msgSender();

        Registration storage registration = _guardianRegistrations[guardian];
        uint16 registrationEndEpoch = registration.endEpoch;

        // NOTE: avoid to resume a guardian whose registration is expired or null
        if (registrationEndEpoch < currentEpoch || registrationEndEpoch == 0) {
            revert Errors.InvalidRegistration();
        }

        if (_pendingLightResumes[currentEpoch][guardian] == 0) {
            revert Errors.NotResumable();
        }

        unchecked {
            --_pendingLightResumes[currentEpoch][guardian];
        }

        IGovernanceMessageEmitter(governanceMessageEmitter).resumeGuardian(guardian);
        emit GuardianLightResumed(guardian);
    }

    /// @inheritdoc IRegistrationManager
    function lightResumeSentinel(address owner, bytes calldata signature) external {
        uint16 currentEpoch = IEpochsManager(epochsManager).currentEpoch();
        address sentinel = getSentinelAddressFromSignature(owner, signature);

        Registration storage registration = _sentinelRegistrations[sentinel];
        uint16 registrationEndEpoch = registration.endEpoch;

        // NOTE: avoid to resume a sentinel whose registration is expired or null
        if (registrationEndEpoch < currentEpoch || registrationEndEpoch == 0) {
            revert Errors.InvalidRegistration();
        }

        if (_pendingLightResumes[currentEpoch][sentinel] == 0) {
            revert Errors.NotResumable();
        }

        unchecked {
            --_pendingLightResumes[currentEpoch][sentinel];
        }

        IGovernanceMessageEmitter(governanceMessageEmitter).resumeSentinel(sentinel);
        emit SentinelLightResumed(sentinel);
    }

    /// @inheritdoc IRegistrationManager
    function sentinelRegistration(address sentinel) external view returns (Registration memory) {
        return _sentinelRegistrations[sentinel];
    }

    /// @inheritdoc IRegistrationManager
    function sentinelOf(address owner) external view returns (address) {
        return _ownersSentinel[owner];
    }

    /// @inheritdoc IRegistrationManager
    function sentinelStakedAmountByEpochOf(address sentinel, uint16 epoch) external view returns (uint256) {
        return _sentinelsEpochsStakedAmount[sentinel].length > 0 ? _sentinelsEpochsStakedAmount[sentinel][epoch] : 0;
    }

    /// @inheritdoc IRegistrationManager
    function slashesByEpochOf(uint16 epoch, address actor) external view returns (uint16) {
        return _slashes[epoch][actor];
    }

    /// @inheritdoc IRegistrationManager
    function setFeesManager(address feesManager_) external onlyRole(Roles.SET_FEES_MANAGER_ROLE) {
        feesManager = feesManager_;
    }

    /// @inheritdoc IRegistrationManager
    function setGovernanceMessageEmitter(
        address governanceMessageEmitter_
    ) external onlyRole(Roles.SET_GOVERNANCE_MESSAGE_EMITTER_ROLE) {
        governanceMessageEmitter = governanceMessageEmitter_;
    }

    /// @inheritdoc IRegistrationManager
    function slash(address actor, uint256 amount, address challenger) external onlyRole(Roles.SLASH_ROLE) {
        uint16 currentEpoch = IEpochsManager(epochsManager).currentEpoch();

        Registration storage registration = _sentinelRegistrations[actor];
        address registrationOwner = registration.owner;

        if (registrationOwner == address(0)) {
            registration = _guardianRegistrations[actor];
            registrationOwner = registration.owner;
        }

        unchecked {
            ++_slashes[currentEpoch][actor];
        }

        bytes1 registrationKind = registration.kind;
        if (registrationKind == Constants.REGISTRATION_SENTINEL_STAKING) {
            IStakingManagerPermissioned.Stake memory stake = IStakingManagerPermissioned(stakingManager).stakeOf(
                registrationOwner
            );

            uint256 amountToSlash = amount;
            uint256 stakeAmount = stake.amount;
            if (stakeAmount < amount) {
                amountToSlash = stakeAmount;
            }

            uint16 registrationEndEpoch = registration.endEpoch;
            uint24 truncatedAmount = Helpers.truncate(amountToSlash);

            for (uint16 epoch = currentEpoch; epoch <= registrationEndEpoch; ) {
                _sentinelsEpochsTotalStakedAmount[epoch] -= truncatedAmount;
                _sentinelsEpochsStakedAmount[actor][epoch] -= truncatedAmount;
                unchecked {
                    ++epoch;
                }
            }

            if (stakeAmount - amountToSlash >= Constants.STAKING_MIN_AMOUT_FOR_SENTINEL_REGISTRATION) {
                unchecked {
                    ++_pendingLightResumes[currentEpoch][actor];
                }
            } else {
                // NOTE: in order to avoid to light-resume an hard-slashed sentinel
                _pendingLightResumes[currentEpoch][actor] == 0;
            }

            if (amount > 0) {
                IStakingManagerPermissioned(stakingManager).slash(registrationOwner, amountToSlash, challenger);
            }

            IGovernanceMessageEmitter(governanceMessageEmitter).slashSentinel(actor);
            emit StakingSentinelSlashed(actor, amount);
        } else if (registrationKind == Constants.REGISTRATION_SENTINEL_BORROWING) {
            uint16 actorSlashes = _slashes[currentEpoch][actor];
            if (actorSlashes == Constants.NUMBER_OF_ALLOWED_SLASHES + 1) {
                IFeesManager(feesManager).redirectClaimToChallengerByEpoch(actor, challenger, currentEpoch);

                uint16 registrationEndEpoch = registration.endEpoch;
                for (uint16 epoch = currentEpoch + 1; epoch <= registrationEndEpoch; ) {
                    ILendingManager(lendingManager).release(
                        actor,
                        epoch,
                        Constants.BORROW_AMOUNT_FOR_SENTINEL_REGISTRATION
                    );
                    unchecked {
                        ++epoch;
                    }
                }

                registration.endEpoch = currentEpoch; // NOTE: Registration ends here
                _pendingLightResumes[currentEpoch][actor] = 0;
            } else if (actorSlashes < Constants.NUMBER_OF_ALLOWED_SLASHES + 1) {
                unchecked {
                    ++_pendingLightResumes[currentEpoch][actor];
                }
            } else {
                return;
            }
            IGovernanceMessageEmitter(governanceMessageEmitter).slashSentinel(actor);
            emit BorrowingSentinelSlashed(actor);
        } else if (registrationKind == Constants.REGISTRATION_GUARDIAN) {
            uint16 actorSlashes = _slashes[currentEpoch][actor];
            if (actorSlashes == Constants.NUMBER_OF_ALLOWED_SLASHES + 1) {
                IFeesManager(feesManager).redirectClaimToChallengerByEpoch(actor, challenger, currentEpoch);
                registration.endEpoch = currentEpoch; // NOTE: Registration ends here
                _pendingLightResumes[currentEpoch][actor] = 0;
            } else if (actorSlashes < Constants.NUMBER_OF_ALLOWED_SLASHES + 1) {
                unchecked {
                    ++_pendingLightResumes[currentEpoch][actor];
                }
            } else {
                return;
            }

            IGovernanceMessageEmitter(governanceMessageEmitter).slashGuardian(actor);
            emit GuardianSlashed(actor);
        } else {
            revert Errors.InvalidRegistration();
        }
    }

    /// @inheritdoc IRegistrationManager
    function totalNumberOfGuardiansByEpoch(uint16 epoch) external view returns (uint16) {
        return _epochsTotalNumberOfGuardians[epoch];
    }

    /// @inheritdoc IRegistrationManager
    function totalSentinelStakedAmountByEpoch(uint16 epoch) external view returns (uint256) {
        return _sentinelsEpochsTotalStakedAmount[epoch];
    }

    /// @inheritdoc IRegistrationManager
    function totalSentinelStakedAmountByEpochsRange(
        uint16 startEpoch,
        uint16 endEpoch
    ) external view returns (uint256[] memory) {
        uint256[] memory result = new uint256[]((endEpoch + 1) - startEpoch);
        for (uint16 epoch = startEpoch; epoch <= endEpoch; epoch++) {
            result[epoch - startEpoch] = _sentinelsEpochsTotalStakedAmount[epoch];
        }
        return result;
    }

    /// @inheritdoc IRegistrationManager
    function updateGuardiansRegistrations(
        address[] calldata owners,
        uint16[] calldata numbersOfEpochs,
        address[] calldata guardians
    ) external onlyRole(Roles.UPDATE_GUARDIAN_REGISTRATION_ROLE) {
        for (uint16 i = 0; i < owners.length; ) {
            _updateGuardianRegistration(owners[i], numbersOfEpochs[i], guardians[i]);

            unchecked {
                ++i;
            }
        }
    }

    /// @inheritdoc IRegistrationManager
    function updateGuardianRegistration(
        address owner,
        uint16 numberOfEpochs,
        address guardian
    ) external onlyRole(Roles.UPDATE_GUARDIAN_REGISTRATION_ROLE) {
        _updateGuardianRegistration(owner, numberOfEpochs, guardian);
    }

    /// @inheritdoc IRegistrationManager
    function updateSentinelRegistrationByBorrowing(
        address owner,
        uint16 numberOfEpochs,
        bytes calldata signature
    ) external onlyForwarder {
        _updateSentinelRegistrationByBorrowing(owner, numberOfEpochs, signature);
    }

    /// @inheritdoc IRegistrationManager
    function updateSentinelRegistrationByBorrowing(uint16 numberOfEpochs, bytes calldata signature) external {
        _updateSentinelRegistrationByBorrowing(_msgSender(), numberOfEpochs, signature);
    }

    /// @inheritdoc IRegistrationManager
    function updateSentinelRegistrationByStaking(
        address owner,
        uint256 amount,
        uint64 duration,
        bytes calldata signature
    ) external {
        address sentinel = getSentinelAddressFromSignature(owner, signature);

        // TODO: What does it happen if an user updateSentinelRegistrationByStaking in behalf of someone else using a wrong signature?

        Registration storage registration = _guardianRegistrations[sentinel];
        if (registration.kind != Constants.REGISTRATION_NULL) {
            revert Errors.InvalidRegistration();
        }

        registration = _sentinelRegistrations[sentinel];
        if (registration.kind == Constants.REGISTRATION_SENTINEL_BORROWING) {
            revert Errors.InvalidRegistration();
        }

        IERC20Upgradeable(token).safeTransferFrom(_msgSender(), address(this), amount);
        IERC20Upgradeable(token).approve(stakingManager, amount);
        IStakingManagerPermissioned(stakingManager).stake(owner, amount, duration);

        uint16 currentEpoch = IEpochsManager(epochsManager).currentEpoch();
        uint16 startEpoch = currentEpoch + 1;
        uint16 endEpoch = currentEpoch + uint16(duration / IEpochsManager(epochsManager).epochDuration()) - 1;
        uint16 registrationStartEpoch = registration.startEpoch;
        uint16 registrationEndEpoch = registration.endEpoch;

        if (_sentinelsEpochsStakedAmount[sentinel].length == 0) {
            _sentinelsEpochsStakedAmount[sentinel] = new uint24[](Constants.AVAILABLE_EPOCHS);
        }

        uint24 truncatedAmount = Helpers.truncate(amount);
        for (uint16 epoch = startEpoch; epoch <= endEpoch; ) {
            _sentinelsEpochsStakedAmount[sentinel][epoch] += truncatedAmount;
            if (
                _sentinelsEpochsStakedAmount[sentinel][epoch] <
                Constants.STAKING_MIN_AMOUT_FOR_SENTINEL_REGISTRATION_TRUNCATED
            ) {
                revert Errors.InvalidAmount();
            }

            _sentinelsEpochsTotalStakedAmount[epoch] += truncatedAmount;
            unchecked {
                ++epoch;
            }
        }

        if (startEpoch > registrationEndEpoch) {
            registrationStartEpoch = startEpoch;
        }

        if (endEpoch > registrationEndEpoch) {
            registrationEndEpoch = endEpoch;
        }

        _updateSentinelRegistration(
            sentinel,
            owner,
            registrationStartEpoch,
            registrationEndEpoch,
            Constants.REGISTRATION_SENTINEL_STAKING
        );

        emit SentinelRegistrationUpdated(
            owner,
            startEpoch,
            endEpoch,
            sentinel,
            Constants.REGISTRATION_SENTINEL_STAKING,
            amount
        );
    }

    function _increaseSentinelRegistrationDuration(address owner, uint64 duration) internal {
        address sentinel = _ownersSentinel[owner];
        Registration storage registration = _sentinelRegistrations[sentinel];
        if (registration.kind == Constants.REGISTRATION_SENTINEL_BORROWING) {
            revert Errors.InvalidRegistration();
        }

        uint16 currentEpoch = IEpochsManager(epochsManager).currentEpoch();
        uint256 epochDuration = IEpochsManager(epochsManager).epochDuration();

        IStakingManagerPermissioned(stakingManager).increaseDuration(owner, duration);
        IStakingManagerPermissioned.Stake memory stake = IStakingManagerPermissioned(stakingManager).stakeOf(owner);

        uint64 blockTimestamp = uint64(block.timestamp);
        uint16 startEpoch = currentEpoch + 1;
        // if startDate hasn't just been reset(increasing duration where block.timestamp < oldEndDate) it means that we have to count the epoch next to the current endEpoch one
        uint16 numberOfEpochs = uint16((stake.endDate - blockTimestamp) / epochDuration) -
            (stake.startDate == blockTimestamp ? 1 : 0);
        uint16 endEpoch = uint16(startEpoch + numberOfEpochs - 1);
        uint24 truncatedAmount = Helpers.truncate(stake.amount);

        for (uint16 epoch = startEpoch; epoch <= endEpoch; ) {
            if (_sentinelsEpochsStakedAmount[sentinel][epoch] == 0) {
                _sentinelsEpochsStakedAmount[sentinel][epoch] += truncatedAmount;
                _sentinelsEpochsTotalStakedAmount[epoch] += truncatedAmount;
            }

            unchecked {
                ++epoch;
            }
        }

        if (stake.startDate == blockTimestamp) {
            registration.startEpoch = startEpoch;
        }
        registration.endEpoch = endEpoch;

        emit DurationIncreased(sentinel, endEpoch);
    }

    function _updateGuardianRegistration(address owner, uint16 numberOfEpochs, address guardian) internal {
        if (numberOfEpochs == 0) {
            revert Errors.InvalidNumberOfEpochs(numberOfEpochs);
        }

        Registration storage currentRegistration = _sentinelRegistrations[guardian];
        if (currentRegistration.endEpoch != 0) {
            revert Errors.InvalidRegistration();
        }

        uint16 currentEpoch = IEpochsManager(epochsManager).currentEpoch();
        currentRegistration = _guardianRegistrations[guardian];

        uint16 currentRegistrationEndEpoch = currentRegistration.endEpoch;
        uint16 startEpoch = currentEpoch + 1;
        uint16 endEpoch = startEpoch + numberOfEpochs - 1;

        // NOTE: reset _epochsTotalNumberOfGuardians if the guardian was already registered and if the current epoch is less than the
        // epoch in which the current registration ends.
        if (currentRegistration.owner != address(0) && currentEpoch < currentRegistrationEndEpoch) {
            for (uint16 epoch = startEpoch; epoch <= currentRegistrationEndEpoch; ) {
                unchecked {
                    --_epochsTotalNumberOfGuardians[epoch];
                    ++epoch;
                }
            }
        }

        _ownersGuardian[owner] = guardian;
        _guardianRegistrations[guardian] = Registration(owner, startEpoch, endEpoch, Constants.REGISTRATION_GUARDIAN);

        for (uint16 epoch = startEpoch; epoch <= endEpoch; ) {
            unchecked {
                ++_epochsTotalNumberOfGuardians[epoch];
                ++epoch;
            }
        }

        emit GuardianRegistrationUpdated(owner, startEpoch, endEpoch, guardian, Constants.REGISTRATION_GUARDIAN);
    }

    function _updateSentinelRegistrationByBorrowing(
        address owner,
        uint16 numberOfEpochs,
        bytes calldata signature
    ) internal {
        if (numberOfEpochs == 0) {
            revert Errors.InvalidNumberOfEpochs(numberOfEpochs);
        }

        address sentinel = getSentinelAddressFromSignature(owner, signature);

        Registration storage registration = _guardianRegistrations[sentinel];
        if (registration.kind != Constants.REGISTRATION_NULL) {
            revert Errors.InvalidRegistration();
        }

        registration = _sentinelRegistrations[sentinel];
        if (registration.kind == Constants.REGISTRATION_SENTINEL_STAKING) {
            revert Errors.InvalidRegistration();
        }

        uint16 currentEpoch = IEpochsManager(epochsManager).currentEpoch();
        uint16 currentRegistrationStartEpoch = registration.startEpoch;
        uint16 currentRegistrationEndEpoch = registration.endEpoch;

        uint16 startEpoch = currentEpoch >= currentRegistrationEndEpoch
            ? currentEpoch + 1
            : currentRegistrationEndEpoch + 1;
        uint16 endEpoch = startEpoch + numberOfEpochs - 1;

        for (uint16 epoch = startEpoch; epoch <= endEpoch; ) {
            ILendingManager(lendingManager).borrow(Constants.BORROW_AMOUNT_FOR_SENTINEL_REGISTRATION, epoch, sentinel);
            unchecked {
                ++epoch;
            }
        }

        uint16 effectiveStartEpoch = currentEpoch >= currentRegistrationEndEpoch
            ? startEpoch
            : currentRegistrationStartEpoch;

        _updateSentinelRegistration(
            sentinel,
            owner,
            effectiveStartEpoch,
            endEpoch,
            Constants.REGISTRATION_SENTINEL_BORROWING
        );

        emit SentinelRegistrationUpdated(
            owner,
            effectiveStartEpoch,
            endEpoch,
            sentinel,
            Constants.REGISTRATION_SENTINEL_BORROWING,
            Constants.BORROW_AMOUNT_FOR_SENTINEL_REGISTRATION
        );
    }

    function _updateSentinelRegistration(
        address sentinel,
        address owner,
        uint16 startEpoch,
        uint16 endEpoch,
        bytes1 kind
    ) internal {
        _ownersSentinel[owner] = sentinel;
        _sentinelRegistrations[sentinel] = Registration(owner, startEpoch, endEpoch, kind);
    }

    function _authorizeUpgrade(address) internal override onlyRole(Roles.UPGRADE_ROLE) {}
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import {AccessControlEnumerableUpgradeable} from "@openzeppelin/contracts-upgradeable/access/AccessControlEnumerableUpgradeable.sol";
import {ContextUpgradeable} from "@openzeppelin/contracts-upgradeable/utils/ContextUpgradeable.sol";
import {IForwarderRecipientUpgradeable} from "../interfaces/IForwarderRecipientUpgradeable.sol";

error InvalidForwarder(address caller);

abstract contract ForwarderRecipientUpgradeable is
    IForwarderRecipientUpgradeable,
    Initializable,
    ContextUpgradeable,
    AccessControlEnumerableUpgradeable
{
    address private _forwarder;

    bytes32 public constant SET_FORWARDER_ROLE = keccak256("SET_FORWARDER_ROLE");

    modifier onlyForwarder() {
        address msgSender = _msgSender();
        if (forwarder() != msgSender) {
            revert InvalidForwarder(msgSender);
        }
        _;
    }

    function __ForwarderRecipientUpgradeable_init(address forwarder_) internal onlyInitializing {
        __ForwarderRecipientUpgradeable_init_unchained(forwarder_);
    }

    function __ForwarderRecipientUpgradeable_init_unchained(address forwarder_) internal onlyInitializing {
        _forwarder = forwarder_;
    }

    /// @inheritdoc IForwarderRecipientUpgradeable
    function forwarder() public view virtual returns (address) {
        return _forwarder;
    }

    /// @inheritdoc IForwarderRecipientUpgradeable
    function setForwarder(address forwarder_) public virtual onlyRole(SET_FORWARDER_ROLE) {
        _forwarder = forwarder_;
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

interface IGovernanceMessageEmitter {
    function resumeGuardian(address guardian) external;

    function resumeSentinel(address sentinel) external;

    function slashGuardian(address guardian) external;

    function slashSentinel(address sentinel) external;

    function propagateActors(address[] calldata sentinels, address[] calldata guardians) external;

    function propagateGuardians(address[] calldata guardians) external;

    function propagateSentinels(address[] calldata sentinels) external;
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

/**
 * @title IBaseStakingManager
 * @author pNetwork
 *
 * @notice
 */
interface IBaseStakingManager {
    struct Stake {
        uint256 amount;
        uint64 startDate;
        uint64 endDate;
    }

    /**
     * @dev Emitted when an user increases his stake amount.
     *
     * @param owner The owner
     * @param amount The amount to add to the current one
     */
    event AmountIncreased(address indexed owner, uint256 amount);

    /**
     * @dev Emitted when an user increases his stake duration.
     *
     * @param owner The owner
     * @param duration The staking duration to add to the current one
     */
    event DurationIncreased(address indexed owner, uint64 duration);

    /**
     * @dev Emitted when the max total supply changes
     *
     * @param maxTotalSupply The maximun total supply
     */
    event MaxTotalSupplyChanged(uint256 maxTotalSupply);

    /**
     * @dev Emitted when a staker is slashed
     *
     * @param owner The slashed user
     * @param amount The slashed amount
     * @param receiver The receiver of the released collateral
     */
    event Slashed(address indexed owner, uint256 amount, address indexed receiver);

    /**
     * @dev Emitted when an user stakes some tokens
     *
     * @param receiver The receiver
     * @param amount The staked amount
     * @param duration The staking duration
     */
    event Staked(address indexed receiver, uint256 amount, uint64 duration);

    /**
     * @dev Emitted when an user unstakes some tokens
     *
     * @param owner The Onwer
     * @param amount The unstaked amount
     */
    event Unstaked(address indexed owner, uint256 amount);

    /* @notice Changes the maximun total supply
     *
     * @param maxTotalSupply
     *
     */
    function changeMaxTotalSupply(uint256 maxTotalSupply) external;

    /*
     * @notice Slash a given staker. Burn the corresponding amount of daoPNT and send the collateral (PNT) to the receiver
     *
     * @param owner
     * @param amount
     * @param receiver
     *
     */
    function slash(address owner, uint256 amount, address receiver) external;

    /*
     * @notice Returns the owner's stake data
     *
     * @param owner
     *
     * @return the Stake struct representing the owner's stake data.
     */
    function stakeOf(address owner) external view returns (Stake memory);

    /*
     * @notice Unstake an certain amount of governance token in exchange of the same amount of staked tokens.
     *         If the specified chainId is different than the chain where the DAO is deployed, the function will trigger a pToken redeem.
     *
     * @param amount
     * @param chainId
     *
     */
    function unstake(uint256 amount, bytes4 chainId) external;

    /*
     * @notice Unstake an certain amount of governance token in exchange of the same amount of staked tokens and send them to 'receiver'.
     *         If the specified chainId is different than the chain where the
     *         DAO is deployed, the function will trigger a pToken redeem.
     *
     * @param owner
     * @param amount
     * @param chainId
     *
     */
    function unstake(address owner, uint256 amount, bytes4 chainId) external;
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

/**
 * @title IEpochsManager
 * @author pNetwork
 *
 * @notice
 */
interface IEpochsManager {
    /*
     * @notice Returns the current epoch number.
     *
     * @return uint16 representing the current epoch.
     */
    function currentEpoch() external view returns (uint16);

    /*
     * @notice Returns the epoch duration.
     *
     * @return uint256 representing the epoch duration.
     */
    function epochDuration() external view returns (uint256);

    /*
     * @notice Returns the timestamp at which the first epoch is started
     *
     * @return uint256 representing the timestamp at which the first epoch is started.
     */
    function startFirstEpochTimestamp() external view returns (uint256);
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

/**
 * @title IFeesManager
 * @author pNetwork
 *
 * @notice
 */
interface IFeesManager {
    /**
     * @dev Emitted when a fee claim is redirected to the challenger who succesfully slashed the sentinel.
     *
     * @param sentinel The slashed sentinel
     * @param challenger The challenger
     * @param epoch The epoch
     */
    event ClaimRedirectedToChallenger(address indexed sentinel, address indexed challenger, uint16 indexed epoch);

    /**
     * @dev Emitted when a fee is deposited.
     *
     * @param asset The asset address
     * @param epoch The epoch
     * @param amount The amount
     */
    event FeeDeposited(address indexed asset, uint16 indexed epoch, uint256 amount);

    /**
     * @dev Emitted when an user claims a fee for a given epoch.
     *
     * @param owner The owner addres
     * @param sentinel The sentinel addres
     * @param epoch The epoch
     * @param asset The asset addres
     * @param amount The amount
     */
    event FeeClaimed(
        address indexed owner,
        address indexed sentinel,
        uint16 indexed epoch,
        address asset,
        uint256 amount
    );

    /*
     * @notice Claim a fee for a given asset in a specific epoch.
     *
     * @param owner
     * @param asset
     * @param epoch
     *
     */
    function claimFeeByEpoch(address owner, address asset, uint16 epoch) external;

    /*
     * @notice Claim a fee for a given asset in an epochs range.
     *
     * @param owner
     * @param asset
     * @param startEpoch
     * @param endEpoch
     *
     */
    function claimFeeByEpochsRange(address owner, address asset, uint16 startEpoch, uint16 endEpoch) external;

    /*
     * @notice Indicates the claimable asset fee amount in a specific epoch.
     *
     * @paran sentinel
     * @param asset
     * @param epoch
     *
     * @return uint256 an integer representing the claimable asset fee amount in a specific epoch.
     */
    function claimableFeeByEpochOf(address sentinel, address asset, uint16 epoch) external view returns (uint256);

    /*
     * @notice Indicates the claimable asset fee amount in an epochs range.
     *
     * @paran sentinel
     * @param assets
     * @param startEpoch
     * @param endEpoch
     *
     * @return uint256 an integer representing the claimable asset fee amount in an epochs range.
     */
    function claimableFeesByEpochsRangeOf(
        address sentinel,
        address[] calldata assets,
        uint16 startEpoch,
        uint16 endEpoch
    ) external view returns (uint256[] memory);

    /*
     * @notice returns the addresses of the challengers who are entitled to claim the fees in the event of slashing.
     *
     * @param sentinel
     * @param startEpoch
     * @params endEpoch
     *
     * @return address[] representing the addresses of the challengers who are entitled to claim the fees in the event of slashing.
     */
    function challengerClaimRedirectByEpochsRangeOf(
        address sentinel,
        uint16 startEpoch,
        uint16 endEpoch
    ) external view returns (address[] memory);

    /*
     * @notice returns the address of the challenger who are entitled to claim the fees in the event of slashing.
     *
     * @param sentinel
     * @params epoch
     *
     * @return address[] representing the address of the challenger who are entitled to claim the fees in the event of slashing.
     */
    function challengerClaimRedirectByEpochOf(address sentinel, uint16 epoch) external returns (address);

    /*
     * @notice Deposit an asset fee amount in the current epoch.
     *
     * @param asset
     * @param amount
     *
     */
    function depositFee(address asset, uint256 amount) external;

    /*
     * @notice Indicates the K factor in a specific epoch. The K factor is calculated with the following formula: utilizationRatio^2 + minimumBorrowingFee
     *
     * @param epoch
     *
     * @return uint256 an integer representing the K factor in a specific epoch.
     */
    function kByEpoch(uint16 epoch) external view returns (uint256);

    /*
     * @notice Indicates the K factor in a specific epochs range.
     *
     * @param startEpoch
     * @params endEpoch
     *
     * @return uint256[] an integer representing the K factor in a specific epochs range.
     */
    function kByEpochsRange(uint16 startEpoch, uint16 endEpoch) external view returns (uint256[] memory);

    /*
     * @notice Redirect the fees claiming to the challenger who succesfully slashed the sentinel for a given epoch.
     *         This function potentially allows to be called also for staking sentinel so it is up to who call it (RegistrationManager)
     *         to call it only for the borrowing sentinels.
     *
     * @param sentinel
     * @params challenger
     * @params epoch
     *
     */
    function redirectClaimToChallengerByEpoch(address sentinel, address challenger, uint16 epoch) external;
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

/**
 * @title IForwarderRecipientUpgradeable
 * @author pNetwork
 *
 * @notice
 */
interface IForwarderRecipientUpgradeable {
    /*
     * @notice Returns the forwarder address. This is the address that is allowed to invoke the call if the 'onlyForwarder' modifier is used.
     *
     * @return forwarder address.
     */
    function forwarder() external view returns (address);

    /*
     * @notice Set the forwarder address.
     *
     * @param forwarder_ forwarder address.
     */
    function setForwarder(address forwarder_) external;
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

/**
 * @title ILendingManager
 * @author pNetwork
 *
 * @notice
 */
interface ILendingManager {
    /**
     * @dev Emitted when an user increases his lend position by increasing his lock time within the Staking Manager.
     *
     * @param lender The lender
     * @param endEpoch The new end epoch
     */
    event DurationIncreased(address indexed lender, uint16 endEpoch);

    /**
     * @dev Emitted when the lended amount for a certain epoch increase.
     *
     * @param lender The lender
     * @param startEpoch The start epoch
     * @param endEpoch The end epoch
     * @param amount The amount
     */
    event Lended(address indexed lender, uint256 indexed startEpoch, uint256 indexed endEpoch, uint256 amount);

    /**
     * @dev Emitted when a borrower borrows a certain amount of tokens for a number of epochs.
     *
     * @param borrower The borrower address
     * @param epoch The epoch
     * @param amount The amount
     */
    event Borrowed(address indexed borrower, uint256 indexed epoch, uint256 amount);

    /**
     * @dev Emitted when an reward is claimed
     *
     * @param lender The lender address
     * @param asset The claimed asset address
     * @param epoch The epoch
     * @param amount The amount
     */
    event RewardClaimed(address indexed lender, address indexed asset, uint256 indexed epoch, uint256 amount);

    /**
     * @dev Emitted when an reward is lended
     *
     * @param asset The asset
     * @param epoch The current epoch
     * @param amount The amount
     */
    event RewardDeposited(address indexed asset, uint256 indexed epoch, uint256 amount);

    /**
     * @dev Emitted when a borrower borrow is released.
     *
     * @param borrower The borrower address
     * @param epoch The current epoch
     * @param amount The amount
     */
    event Released(address indexed borrower, uint256 indexed epoch, uint256 amount);

    /*
     * @notice Borrow a certain amount of tokens in a given epoch
     *
     * @param amount
     * @param epoch
     * @param borrower
     *
     */
    function borrow(uint256 amount, uint16 epoch, address borrower) external;

    /*
     * @notice Returns the borrowable amount for the given epoch
     *
     * @param epoch
     *
     * @return uint24 an integer representing the borrowable amount for the given epoch.
     */
    function borrowableAmountByEpoch(uint16 epoch) external view returns (uint24);

    /*
     * @notice Returns the borrowed amount of a given user in a given epoch
     *
     * @param borrower
     * @param epoch
     *
     * @return uint24 an integer representing the borrowed amount of a given user in a given epoch.
     */
    function borrowedAmountByEpochOf(address borrower, uint16 epoch) external view returns (uint24);

    /*
     * @notice Returns the lender's claimable amount for a given asset in a specifich epoch.
     *
     * @param lender
     * @param asset
     * @param epoch
     *
     * @return uint256 an integer representing the lender's claimable value for a given asset in a specifich epoch..
     */
    function claimableRewardsByEpochOf(address lender, address asset, uint16 epoch) external view returns (uint256);

    /*
     * @notice Returns the lender's claimable amount for a set of assets in an epochs range
     *
     * @param lender
     * @param assets
     * @param startEpoch
     * @param endEpoch
     *
     * @return uint256 an integer representing the lender's claimable amount for a set of assets in an epochs range.
     */
    function claimableAssetsAmountByEpochsRangeOf(
        address lender,
        address[] calldata assets,
        uint16 startEpoch,
        uint16 endEpoch
    ) external view returns (uint256[] memory);

    /*
     * @notice Claim the rewards earned by the lender for a given epoch for a given asset.
     *
     * @param asset
     * @param epoch
     *
     */
    function claimRewardByEpoch(address asset, uint16 epoch) external;

    /*
     * @notice Claim the reward earned by the lender in an epochs range for a given asset.
     *
     * @param asset
     * @param startEpoch
     * @param endEpoch
     *
     */
    function claimRewardByEpochsRange(address asset, uint16 startEpoch, uint16 endEpoch) external;

    /*
     * @notice Deposit an reward amount of an asset in a given epoch.
     *
     * @param amount
     * @param asset
     * @param epoch
     *
     */
    function depositReward(address asset, uint16 epoch, uint256 amount) external;

    /*
     * @notice Returns the number of votes and the number of voted votes by a lender. This function is needed
     *         in order to allow the lender to be able to claim the rewards only if he voted to all votes
     *         within an epoch
     *
     * @param lender
     * @param epoch
     *
     * @return (uint256,uint256) representing the total number of votes within an epoch an the number of voted votes by a lender.
     */
    function getLenderVotingStateByEpoch(address lender, uint16 epoch) external returns (uint256, uint256);

    /*
     * @notice Increase the duration of a lending position by increasing the lock time of the staked tokens.
     *
     * @param duration
     *
     */
    function increaseDuration(uint64 duration) external;

    /*
     * @notice Increase the duration of a lending position by increasing the lock time of the staked tokens.
     *         This function is used togheter with onlyForwarder in order to enable cross chain duration increasing
     *
     * @param duration
     *
     */
    function increaseDuration(address lender, uint64 duration) external;

    /*
     * @notice Lend in behalf of lender a certain amount of tokens locked for a given period of time. The lended
     * tokens are forwarded within the StakingManager. This fx is just a proxy fx to the StakingManager.stake that counts
     * how many tokens can be borrowed.
     *
     * @param lender
     * @param amount
     * @param duration
     *
     */
    function lend(address lender, uint256 amount, uint64 duration) external;

    /*
     * @notice Returns the borrowed amount for a given epoch.
     *
     * @param epoch
     *
     * @return uint24 representing an integer representing the borrowed amount for a given epoch.
     */
    function totalBorrowedAmountByEpoch(uint16 epoch) external view returns (uint24);

    /*
     * @notice Returns the borrowed amount in an epochs range.
     *
     * @param startEpoch
     * @param endEpoch
     *
     * @return uint24[] representing an integer representing the borrowed amount in an epochs range.
     */
    function totalBorrowedAmountByEpochsRange(
        uint16 startEpoch,
        uint16 endEpoch
    ) external view returns (uint24[] memory);

    /*
     * @notice Returns the lended amount for a given epoch.
     *
     * @param epoch
     *
     * @return uint256 an integer representing the lended amount for a given epoch.
     */
    function totalLendedAmountByEpoch(uint16 epoch) external view returns (uint24);

    /*
     * @notice Returns the maximum lended amount for the selected epochs.
     *
     * @param startEpoch
     * @param endEpoch
     *
     * @return uint24[] representing an array of integers representing the maximum lended amount for a given epoch.
     */
    function totalLendedAmountByEpochsRange(uint16 startEpoch, uint16 endEpoch) external view returns (uint24[] memory);

    /*
     * @notice Delete the borrower for a given epoch.
     * In order to call it the sender must have the RELEASE_ROLE role.
     *
     * @param borrower
     * @param epoch
     * @param amount
     *
     */
    function release(address borrower, uint16 epoch, uint256 amount) external;

    /*
     * @notice Returns the current total asset reward amount by epoch
     *
     * @param asset
     * @param epoch
     *
     * @return (uint256,uint256) representing the total asset reward amount by epoch.
     */
    function totalAssetRewardAmountByEpoch(address asset, uint16 epoch) external view returns (uint256);

    /*
     * @notice Returns the current total weight for a given epoch. The total weight is the sum of the user weights in a specific epoch.
     *
     * @param asset
     * @param epoch
     *
     * @return uint32 representing the current total weight for a given epoch.
     */
    function totalWeightByEpoch(uint16 epoch) external view returns (uint32);

    /*
     * @notice Returns the current total weight for a given epochs range. The total weight is the sum of the user weights in a specific epochs range.
     *
     * @param asset
     * @param epoch
     *
     * @return uint32 representing the current total weight for a given epochs range.
     */
    function totalWeightByEpochsRange(uint16 startEpoch, uint16 endEpoch) external view returns (uint32[] memory);

    /*
     * @notice Returns the utilization rate (percentage of borrowed tokens compared to the lended ones) in the given epoch
     *
     * @param epoch
     *
     * @return uint24 an integer representing the utilization rate in a given epoch.
     */
    function utilizationRatioByEpoch(uint16 epoch) external view returns (uint24);

    /*
     * @notice Returns the utilization rate (percentage of borrowed tokens compared to the lended ones) given the start end the end epoch
     *
     * @param startEpoch
     * @param endEpoch
     *
     * @return uint24 an integer representing the utilization rate in a given the start end the end epoch.
     */
    function utilizationRatioByEpochsRange(uint16 startEpoch, uint16 endEpoch) external view returns (uint24[] memory);

    /*
     * @notice Returns the user weight in a given epoch. The user weight is calculated with
     * the following formula: lendedAmount * numberOfEpochsLeft in a given epoch
     *
     * @param lender
     * @param epoch
     *
     * @return uint32 an integer representing the user weight in a given epoch.
     */
    function weightByEpochOf(address lender, uint16 epoch) external view returns (uint32);

    /*
     * @notice Returns the user weights in an epochs range. The user weight is calculated with
     * the following formula: lendedAmount * numberOfEpochsLeft in a given epoch
     *
     * @param lender
     * @param epoch
     *
     * @return uint32[] an integer representing the user weights in an epochs range.
     */
    function weightByEpochsRangeOf(
        address lender,
        uint16 startEpoch,
        uint16 endEpoch
    ) external view returns (uint32[] memory);
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

/**
 * @title IRegistrationManager
 * @author pNetwork
 *
 * @notice
 */
interface IRegistrationManager {
    struct Registration {
        address owner;
        uint16 startEpoch;
        uint16 endEpoch;
        bytes1 kind;
    }

    /**
     * @dev Emitted when a borrowing sentinel is slashed.
     *
     * @param sentinel The sentinel
     */
    event BorrowingSentinelSlashed(address indexed sentinel);

    /**
     * @dev Emitted when an user increases his staking sentinel registration position by increasing his lock time within the Staking Manager.
     *
     * @param sentinel The sentinel
     * @param endEpoch The new end epoch
     */
    event DurationIncreased(address indexed sentinel, uint16 endEpoch);

    /**
     * @dev Emitted when a guardian is slashed.
     *
     * @param guardian The guardian
     */
    event GuardianSlashed(address indexed guardian);

    /**
     * @dev Emitted when a guardian is registered.
     *
     * @param owner The sentinel owner
     * @param startEpoch The epoch in which the registration starts
     * @param endEpoch The epoch at which the registration ends
     * @param guardian The sentinel address
     * @param kind The type of registration
     */
    event GuardianRegistrationUpdated(
        address indexed owner,
        uint16 indexed startEpoch,
        uint16 indexed endEpoch,
        address guardian,
        bytes1 kind
    );

    /**
     * @dev Emitted when a guardian is light-resumed.
     *
     * @param guardian The guardian
     */
    event GuardianLightResumed(address indexed guardian);

    /**
     * @dev Emitted when a sentinel registration is completed.
     *
     * @param owner The sentinel owner
     * @param startEpoch The epoch in which the registration starts
     * @param endEpoch The epoch at which the registration ends
     * @param sentinel The sentinel address
     * @param kind The type of registration
     * @param amount The amount used to register a sentinel
     */
    event SentinelRegistrationUpdated(
        address indexed owner,
        uint16 indexed startEpoch,
        uint16 indexed endEpoch,
        address sentinel,
        bytes1 kind,
        uint256 amount
    );

    /**
     * @dev Emitted when a sentinel is hard-resumed.
     *
     * @param sentinel The sentinel
     */
    event SentinelHardResumed(address indexed sentinel);

    /**
     * @dev Emitted when a sentinel is light-resumed.
     *
     * @param sentinel The sentinel
     */
    event SentinelLightResumed(address indexed sentinel);

    /**
     * @dev Emitted when a staking sentinel increased its amount at stake.
     *
     * @param sentinel The sentinel
     */
    event StakedAmountIncreased(address indexed sentinel, uint256 amount);

    /**
     * @dev Emitted when a staking sentinel is slashed.
     *
     * @param sentinel The sentinel
     * @param amount The amount
     */
    event StakingSentinelSlashed(address indexed sentinel, uint256 amount);

    /*
     * @notice Returns the sentinel address given the owner and the signature.
     *
     * @param sentinel
     *
     * @return address representing the address of the sentinel.
     */
    function getSentinelAddressFromSignature(address owner, bytes calldata signature) external pure returns (address);

    /*
     * @notice Returns a guardian registration.
     *
     * @param guardian
     *
     * @return Registration representing the guardian registration.
     */
    function guardianRegistration(address guardian) external view returns (Registration memory);

    /*
     * @notice Returns a guardian by its owner.
     *
     * @param owner
     *
     * @return the guardian.
     */
    function guardianOf(address owner) external view returns (address);

    /*
     * @notice Resume a sentinel that was hard-slashed that means that its amount went below 200k PNT
     *         and its address was removed from the merkle tree. In order to be able to hard-resume a
     *         sentinel, when the function is called, StakingManager.increaseAmount is also called in
     *         order to increase the amount at stake.
     *
     * @param amount
     * @param owner
     * @param signature
     *
     */
    function hardResumeSentinel(uint256 amount, address owner, bytes calldata signature) external;

    /*
     * @notice Increase the duration of a staking sentinel registration.
     *
     * @param duration
     */
    function increaseSentinelRegistrationDuration(uint64 duration) external;

    /*
     * @notice Increase the duration  of a staking sentinel registration. This function is used togheter with
     *         onlyForwarder modifier in order to enable cross chain duration increasing
     *
     * @param owner
     * @param duration
     */
    function increaseSentinelRegistrationDuration(address owner, uint64 duration) external;

    /*
     * @notice Resume a guardian that was light-slashed
     *
     *
     */
    function lightResumeGuardian() external;

    /*
     * @notice Resume a sentinel that was light-slashed
     *
     * @param owner
     * @param signature
     *
     */
    function lightResumeSentinel(address owner, bytes calldata signature) external;

    /*
     * @notice Returns the sentinel of a given owner
     *
     * @param owner
     *
     * @return address representing the address of the sentinel.
     */
    function sentinelOf(address owner) external view returns (address);

    /*
     * @notice Returns the sentinel registration
     *
     * @param sentinel
     *
     * @return address representing the sentinel registration data.
     */
    function sentinelRegistration(address sentinel) external view returns (Registration memory);

    /*
     * @notice Return the staked amount by a sentinel in a given epoch.
     *
     * @param epoch
     *
     * @return uint256 representing staked amount by a sentinel in a given epoch.
     */
    function sentinelStakedAmountByEpochOf(address sentinel, uint16 epoch) external view returns (uint256);

    /*
     * @notice Return the number of times an actor (sentinel or guardian) has been slashed in an epoch.
     *
     * @param epoch
     * @param actor
     *
     * @return uint16 representing the number of times an actor has been slashed in an epoch.
     */
    function slashesByEpochOf(uint16 epoch, address actor) external view returns (uint16);

    /*
     * @notice Set FeesManager
     *
     * @param feesManager
     *
     */
    function setFeesManager(address feesManager) external;

    /*
     * @notice Set GovernanceMessageEmitter
     *
     * @param feesManager
     *
     */
    function setGovernanceMessageEmitter(address governanceMessageEmitter) external;

    /*
     * @notice Slash a sentinel or a guardian. This function is callable only by the PNetworkHub
     *
     * @param actor
     * @param amount
     * @param challenger
     *
     */
    function slash(address actor, uint256 amount, address challenger) external;

    /*
     * @notice Return the total number of guardians in a specific epoch.
     *
     * @param epoch
     *
     * @return uint256 the total number of guardians in a specific epoch.
     */
    function totalNumberOfGuardiansByEpoch(uint16 epoch) external view returns (uint16);

    /*
     * @notice Return the total staked amount by the sentinels in a given epoch.
     *
     * @param epoch
     *
     * @return uint256 representing  total staked amount by the sentinels in a given epoch.
     */
    function totalSentinelStakedAmountByEpoch(uint16 epoch) external view returns (uint256);

    /*
     * @notice Return the total staked amount by the sentinels in a given epochs range.
     *
     * @param epoch
     *
     * @return uint256[] representing  total staked amount by the sentinels in a given epochs range.
     */
    function totalSentinelStakedAmountByEpochsRange(
        uint16 startEpoch,
        uint16 endEpoch
    ) external view returns (uint256[] memory);

    /*
     * @notice Update guardians registrations. UPDATE_GUARDIAN_REGISTRATION_ROLE is needed to call this function
     *
     * @param owners
     * @param numbersOfEpochs
     * @param guardians
     *
     */
    function updateGuardiansRegistrations(
        address[] calldata owners,
        uint16[] calldata numbersOfEpochs,
        address[] calldata guardians
    ) external;

    /*
     * @notice Update a guardian registration. UPDATE_GUARDIAN_REGISTRATION_ROLE is needed to call this function
     *
     * @param owners
     * @param numbersOfEpochs
     * @param guardians
     *
     */
    function updateGuardianRegistration(address owner, uint16 numberOfEpochs, address guardian) external;

    /*
     * @notice Registers/Renew a sentinel by borrowing the specified amount of tokens for a given number of epochs.
     *         This function is used togheter with onlyForwarder.
     *
     * @params owner
     * @param numberOfEpochs
     * @param signature
     *
     */
    function updateSentinelRegistrationByBorrowing(
        address owner,
        uint16 numberOfEpochs,
        bytes calldata signature
    ) external;

    /*
     * @notice Registers/Renew a sentinel by borrowing the specified amount of tokens for a given number of epochs.
     *
     * @param numberOfEpochs
     * @param signature
     *
     */
    function updateSentinelRegistrationByBorrowing(uint16 numberOfEpochs, bytes calldata signature) external;

    /*
     * @notice Registers/Renew a sentinel for a given duration in behalf of owner
     *
     * @param amount
     * @param duration
     * @param signature
     * @param owner
     *
     */
    function updateSentinelRegistrationByStaking(
        address owner,
        uint256 amount,
        uint64 duration,
        bytes calldata signature
    ) external;
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {IBaseStakingManager} from "./IBaseStakingManager.sol";

/**
 * @title IStakingManagerPermissioned
 * @author pNetwork
 *
 * @notice This contract can ONLY be used togheter with LendingManager and RegistrationManager
 *         in order to keep separated the amount staked from the lending, from the sentinels registration
 *         and for voting.
 */
interface IStakingManagerPermissioned is IBaseStakingManager {
    /*
     * @notice Increase the amount at stake.
     *
     * @param owner
     * @param amount
     */
    function increaseAmount(address owner, uint256 amount) external;

    /*
     * @notice Increase the duration of a stake.
     *
     * @param owner
     * @param duration
     */
    function increaseDuration(address owner, uint64 duration) external;

    /*
     * @notice Stake an certain amount of tokens locked for a period of time in behalf of receiver.
     * in exchange of the governance token.
     *
     * @param receiver
     * @param amount
     * @param duration
     */
    function stake(address receiver, uint256 amount, uint64 duration) external;
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

library Constants {
    uint256 public constant BORROW_AMOUNT_FOR_SENTINEL_REGISTRATION = 200000 * 10 ** 18;
    uint256 public constant STAKING_MIN_AMOUT_FOR_SENTINEL_REGISTRATION = 200000 * 10 ** 18;
    uint256 public constant STAKING_MIN_AMOUT_FOR_SENTINEL_REGISTRATION_TRUNCATED = 200000;
    uint256 public constant GUARDIAN_AMOUNT = 10000;
    uint256 public constant AVAILABLE_EPOCHS = 48;
    uint64 public constant MIN_STAKE_DURATION = 604800;
    uint24 public constant DECIMALS_PRECISION = 10 ** 6;
    uint24 public constant MAX_BORROWER_BORROWED_AMOUNT = 200000;
    bytes1 public constant REGISTRATION_NULL = 0x00;
    bytes1 public constant REGISTRATION_SENTINEL_STAKING = 0x01;
    bytes1 public constant REGISTRATION_SENTINEL_BORROWING = 0x02;
    bytes1 public constant REGISTRATION_GUARDIAN = 0x03;
    uint16 public constant NUMBER_OF_ALLOWED_SLASHES = 3;
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

library Errors {
    error InvalidAmount();
    error AmountNotAvailableInEpoch(uint16 epoch);
    error InvalidEpoch();
    error InvalidRegistration();
    error SentinelNotReleasable(address sentinel);
    error NothingToClaim();
    error LendPeriodTooBig();
    error InvalidDuration();
    error UnfinishedStakingPeriod();
    error NothingAtStake();
    error MaxTotalSupplyExceeded();
    error NotPartecipatedInGovernanceAtEpoch(uint16 epoch);
    error GuardianAlreadyRegistered(address guardian);
    error InvalidNumberOfEpochs(uint16 numberOfEpochs);
    error NotResumable();
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

library Helpers {
    function addressToAsciiString(address addr) internal pure returns (string memory) {
        bytes memory s = new bytes(40);
        for (uint256 i = 0; i < 20; i++) {
            bytes1 b = bytes1(uint8(uint256(uint160(addr)) / (2 ** (8 * (19 - i)))));
            bytes1 hi = bytes1(uint8(b) / 16);
            bytes1 lo = bytes1(uint8(b) - 16 * uint8(hi));
            s[2 * i] = char(hi);
            s[2 * i + 1] = char(lo);
        }
        return string(s);
    }

    function char(bytes1 b) internal pure returns (bytes1 c) {
        if (uint8(b) < 10) return bytes1(uint8(b) + 0x30);
        else return bytes1(uint8(b) + 0x57);
    }

    function truncate(uint256 value) internal pure returns (uint24) {
        return uint24((value / 10 ** 18) & 0xFFFFFF);
    }
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

library Roles {
    bytes32 public constant INCREASE_EPOCH_ROLE = keccak256("INCREASE_EPOCH_ROLE");
    bytes32 public constant SET_EPOCH_DURATION_ROLE = keccak256("SET_EPOCH_DURATION_ROLE");
    bytes32 public constant BORROW_ROLE = keccak256("BORROW_ROLE");
    bytes32 public constant RELEASE_ROLE = keccak256("RELEASE_ROLE");
    bytes32 public constant SLASH_ROLE = keccak256("SLASH_ROLE");
    bytes32 public constant STAKE_ROLE = keccak256("STAKE_ROLE");
    bytes32 public constant INCREASE_DURATION_ROLE = keccak256("INCREASE_DURATION_ROLE");
    bytes32 public constant UPGRADE_ROLE = keccak256("UPGRADE_ROLE");
    bytes32 public constant CHANGE_MAX_TOTAL_SUPPLY_ROLE = keccak256("CHANGE_MAX_TOTAL_SUPPLY_ROLE");
    bytes32 public constant UPDATE_GUARDIAN_REGISTRATION_ROLE = keccak256("UPDATE_GUARDIAN_REGISTRATION_ROLE");
    bytes32 public constant REDIRECT_CLAIM_TO_CHALLENGER_BY_EPOCH_ROLE =
        keccak256("REDIRECT_CLAIM_TO_CHALLENGER_BY_EPOCH_ROLE");
    bytes32 public constant SET_FEES_MANAGER_ROLE = keccak256("SET_FEES_MANAGER_ROLE");
    bytes32 public constant SET_GOVERNANCE_MESSAGE_EMITTER_ROLE = keccak256("SET_GOVERNANCE_MESSAGE_EMITTER_ROLE");
    bytes32 public constant INCREASE_AMOUNT_ROLE = keccak256("INCREASE_AMOUNT_ROLE");
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {IEpochsManager} from "@pnetwork-association/dao-v2-contracts/contracts/interfaces/IEpochsManager.sol";

contract EpochsManager is IEpochsManager {
    /// @inheritdoc IEpochsManager
    function currentEpoch() external view returns (uint16) {
        return uint16((block.timestamp - startFirstEpochTimestamp()) / epochDuration());
    }

    /// @inheritdoc IEpochsManager
    function epochDuration() public pure returns (uint256) {
        return 86400; // NOTE: value taken from EpochsManager on Polygon (0x091F2008CCa89114ccbeF2dEa1F3e677B68dF69A)
    }

    /// @inheritdoc IEpochsManager
    function startFirstEpochTimestamp() public pure returns (uint256) {
        return 1694627246; // NOTE: value taken from EpochsManager on Polygon (0x091F2008CCa89114ccbeF2dEa1F3e677B68dF69A)
    }
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

/**
 * @title IRegistrationManager
 * @author pNetwork
 *
 * @notice
 */
interface IRegistrationManager {
    struct Registration {
        address owner;
        uint16 startEpoch;
        uint16 endEpoch;
        bytes1 kind;
    }

    /**
     * @dev Emitted when a borrowing sentinel is slashed.
     *
     * @param sentinel The sentinel
     */
    event BorrowingSentinelSlashed(address indexed sentinel);

    /**
     * @dev Emitted when an user increases his staking sentinel registration position by increasing his lock time within the Staking Manager.
     *
     * @param sentinel The sentinel
     * @param endEpoch The new end epoch
     */
    event DurationIncreased(address indexed sentinel, uint16 endEpoch);

    /**
     * @dev Emitted when a guardian is slashed.
     *
     * @param guardian The guardian
     */
    event GuardianSlashed(address indexed guardian);

    /**
     * @dev Emitted when a guardian is registered.
     *
     * @param owner The sentinel owner
     * @param startEpoch The epoch in which the registration starts
     * @param endEpoch The epoch at which the registration ends
     * @param guardian The sentinel address
     * @param kind The type of registration
     */
    event GuardianRegistrationUpdated(
        address indexed owner,
        uint16 indexed startEpoch,
        uint16 indexed endEpoch,
        address guardian,
        bytes1 kind
    );

    /**
     * @dev Emitted when a guardian is light-resumed.
     *
     * @param guardian The guardian
     */
    event GuardianLightResumed(address indexed guardian);

    /**
     * @dev Emitted when a sentinel registration is completed.
     *
     * @param owner The sentinel owner
     * @param startEpoch The epoch in which the registration starts
     * @param endEpoch The epoch at which the registration ends
     * @param sentinel The sentinel address
     * @param kind The type of registration
     * @param amount The amount used to register a sentinel
     */
    event SentinelRegistrationUpdated(
        address indexed owner,
        uint16 indexed startEpoch,
        uint16 indexed endEpoch,
        address sentinel,
        bytes1 kind,
        uint256 amount
    );

    /**
     * @dev Emitted when a sentinel is hard-resumed.
     *
     * @param sentinel The sentinel
     */
    event SentinelHardResumed(address indexed sentinel);

    /**
     * @dev Emitted when a sentinel is light-resumed.
     *
     * @param sentinel The sentinel
     */
    event SentinelLightResumed(address indexed sentinel);

    /**
     * @dev Emitted when a staking sentinel increased its amount at stake.
     *
     * @param sentinel The sentinel
     */
    event StakedAmountIncreased(address indexed sentinel, uint256 amount);

    /**
     * @dev Emitted when a staking sentinel is slashed.
     *
     * @param sentinel The sentinel
     * @param amount The amount
     */
    event StakingSentinelSlashed(address indexed sentinel, uint256 amount);

    /*
     * @notice Returns the sentinel address given the owner and the signature.
     *
     * @param sentinel
     *
     * @return address representing the address of the sentinel.
     */
    function getSentinelAddressFromSignature(address owner, bytes calldata signature) external pure returns (address);

    /*
     * @notice Returns a guardian registration.
     *
     * @param guardian
     *
     * @return Registration representing the guardian registration.
     */
    function guardianRegistration(address guardian) external view returns (Registration memory);

    /*
     * @notice Returns a guardian by its owner.
     *
     * @param owner
     *
     * @return the guardian.
     */
    function guardianOf(address owner) external view returns (address);

    /*
     * @notice Resume a sentinel that was hard-slashed that means that its amount went below 200k PNT
     *         and its address was removed from the merkle tree. In order to be able to hard-resume a
     *         sentinel, when the function is called, StakingManager.increaseAmount is also called in
     *         order to increase the amount at stake.
     *
     * @param amount
     * @param owner
     * @param signature
     *
     */
    function hardResumeSentinel(uint256 amount, address owner, bytes calldata signature) external;

    /*
     * @notice Increase the duration of a staking sentinel registration.
     *
     * @param duration
     */
    function increaseSentinelRegistrationDuration(uint64 duration) external;

    /*
     * @notice Increase the duration  of a staking sentinel registration. This function is used togheter with
     *         onlyForwarder modifier in order to enable cross chain duration increasing
     *
     * @param owner
     * @param duration
     */
    function increaseSentinelRegistrationDuration(address owner, uint64 duration) external;

    /*
     * @notice Resume a guardian that was light-slashed
     *
     *
     */
    function lightResumeGuardian() external;

    /*
     * @notice Resume a sentinel that was light-slashed
     *
     * @param owner
     * @param signature
     *
     */
    function lightResumeSentinel(address owner, bytes calldata signature) external;

    /*
     * @notice Returns the sentinel of a given owner
     *
     * @param owner
     *
     * @return address representing the address of the sentinel.
     */
    function sentinelOf(address owner) external view returns (address);

    /*
     * @notice Returns the sentinel registration
     *
     * @param sentinel
     *
     * @return address representing the sentinel registration data.
     */
    function sentinelRegistration(address sentinel) external view returns (Registration memory);

    /*
     * @notice Return the staked amount by a sentinel in a given epoch.
     *
     * @param epoch
     *
     * @return uint256 representing staked amount by a sentinel in a given epoch.
     */
    function sentinelStakedAmountByEpochOf(address sentinel, uint16 epoch) external view returns (uint256);

    /*
     * @notice Return the number of times an actor (sentinel or guardian) has been slashed in an epoch.
     *
     * @param epoch
     * @param actor
     *
     * @return uint16 representing the number of times an actor has been slashed in an epoch.
     */
    function slashesByEpochOf(uint16 epoch, address actor) external view returns (uint16);

    /*
     * @notice Set FeesManager
     *
     * @param feesManager
     *
     */
    function setFeesManager(address feesManager) external;

    /*
     * @notice Set GovernanceMessageEmitter
     *
     * @param feesManager
     *
     */
    function setGovernanceMessageEmitter(address governanceMessageEmitter) external;

    /*
     * @notice Slash a sentinel or a guardian. This function is callable only by the PNetworkHub
     *
     * @param actor
     * @param amount
     * @param challenger
     *
     */
    function slash(address actor, uint256 amount, address challenger) external;

    /*
     * @notice Return the total number of guardians in a specific epoch.
     *
     * @param epoch
     *
     * @return uint256 the total number of guardians in a specific epoch.
     */
    function totalNumberOfGuardiansByEpoch(uint16 epoch) external view returns (uint16);

    /*
     * @notice Return the total staked amount by the sentinels in a given epoch.
     *
     * @param epoch
     *
     * @return uint256 representing  total staked amount by the sentinels in a given epoch.
     */
    function totalSentinelStakedAmountByEpoch(uint16 epoch) external view returns (uint256);

    /*
     * @notice Return the total staked amount by the sentinels in a given epochs range.
     *
     * @param epoch
     *
     * @return uint256[] representing  total staked amount by the sentinels in a given epochs range.
     */
    function totalSentinelStakedAmountByEpochsRange(
        uint16 startEpoch,
        uint16 endEpoch
    ) external view returns (uint256[] memory);

    /*
     * @notice Update guardians registrations. UPDATE_GUARDIAN_REGISTRATION_ROLE is needed to call this function
     *
     * @param owners
     * @param numbersOfEpochs
     * @param guardians
     *
     */
    function updateGuardiansRegistrations(
        address[] calldata owners,
        uint16[] calldata numbersOfEpochs,
        address[] calldata guardians
    ) external;

    /*
     * @notice Update a guardian registration. UPDATE_GUARDIAN_REGISTRATION_ROLE is needed to call this function
     *
     * @param owners
     * @param numbersOfEpochs
     * @param guardians
     *
     */
    function updateGuardianRegistration(address owner, uint16 numberOfEpochs, address guardian) external;

    /*
     * @notice Registers/Renew a sentinel by borrowing the specified amount of tokens for a given number of epochs.
     *         This function is used togheter with onlyForwarder.
     *
     * @params owner
     * @param numberOfEpochs
     * @param signature
     *
     */
    function updateSentinelRegistrationByBorrowing(
        address owner,
        uint16 numberOfEpochs,
        bytes calldata signature
    ) external;

    /*
     * @notice Registers/Renew a sentinel by borrowing the specified amount of tokens for a given number of epochs.
     *
     * @param numberOfEpochs
     * @param signature
     *
     */
    function updateSentinelRegistrationByBorrowing(uint16 numberOfEpochs, bytes calldata signature) external;

    /*
     * @notice Registers/Renew a sentinel for a given duration in behalf of owner
     *
     * @param amount
     * @param duration
     * @param signature
     * @param owner
     *
     */
    function updateSentinelRegistrationByStaking(
        address owner,
        uint256 amount,
        uint64 duration,
        bytes calldata signature
    ) external;
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {PToken} from "../core/PToken.sol";
import {IPFactory} from "../interfaces/IPFactory.sol";

contract PFactory is IPFactory, Ownable {
    address public hub;

    function deploy(
        string memory underlyingAssetName,
        string memory underlyingAssetSymbol,
        uint256 underlyingAssetDecimals,
        address underlyingAssetTokenAddress,
        bytes4 underlyingAssetNetworkId
    ) public payable returns (address) {
        address pTokenAddress = address(
            new PToken{salt: hex"0000000000000000000000000000000000000000000000000000000000000000"}(
                underlyingAssetName,
                underlyingAssetSymbol,
                underlyingAssetDecimals,
                underlyingAssetTokenAddress,
                underlyingAssetNetworkId,
                hub
            )
        );

        emit PTokenDeployed(pTokenAddress);
        return pTokenAddress;
    }

    function getBytecode(
        string memory underlyingAssetName,
        string memory underlyingAssetSymbol,
        uint256 underlyingAssetDecimals,
        address underlyingAssetTokenAddress,
        bytes4 underlyingAssetNetworkId
    ) public view returns (bytes memory) {
        bytes memory bytecode = type(PToken).creationCode;

        return
            abi.encodePacked(
                bytecode,
                abi.encode(
                    underlyingAssetName,
                    underlyingAssetSymbol,
                    underlyingAssetDecimals,
                    underlyingAssetTokenAddress,
                    underlyingAssetNetworkId,
                    hub
                )
            );
    }

    function getPTokenAddress(
        string memory underlyingAssetName,
        string memory underlyingAssetSymbol,
        uint256 underlyingAssetDecimals,
        address underlyingAssetTokenAddress,
        bytes4 underlyingAssetNetworkId
    ) public view returns (address) {
        bytes memory bytecode = getBytecode(
            underlyingAssetName,
            underlyingAssetSymbol,
            underlyingAssetDecimals,
            underlyingAssetTokenAddress,
            underlyingAssetNetworkId
        );

        return
            address(
                uint160(
                    uint256(
                        keccak256(
                            abi.encodePacked(
                                bytes1(0xff),
                                address(this),
                                hex"0000000000000000000000000000000000000000000000000000000000000000",
                                keccak256(bytecode)
                            )
                        )
                    )
                )
            );
    }

    function setHub(address hub_) external onlyOwner {
        hub = hub_;
    }
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {ReentrancyGuard} from "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import {IEpochsManager} from "@pnetwork-association/dao-v2-contracts/contracts/interfaces/IEpochsManager.sol";
import {IFeesManager} from "@pnetwork-association/dao-v2-contracts/contracts/interfaces/IFeesManager.sol";
import {MerkleProof} from "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import {ECDSA} from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import {GovernanceMessageHandler} from "../governance/GovernanceMessageHandler.sol";
import {IPToken} from "../interfaces/IPToken.sol";
import {IPFactory} from "../interfaces/IPFactory.sol";
import {IPNetworkHub} from "../interfaces/IPNetworkHub.sol";
import {IPReceiver} from "../interfaces/IPReceiver.sol";
import {Utils} from "../libraries/Utils.sol";
import {Network} from "../libraries/Network.sol";

error OperationAlreadyQueued(IPNetworkHub.Operation operation);
error OperationAlreadyExecuted(IPNetworkHub.Operation operation);
error OperationAlreadyCancelled(IPNetworkHub.Operation operation);
error OperationCancelled(IPNetworkHub.Operation operation);
error OperationNotFound(IPNetworkHub.Operation operation);
error GovernanceOperationAlreadyCancelled(IPNetworkHub.Operation operation);
error GuardianOperationAlreadyCancelled(IPNetworkHub.Operation operation);
error SentinelOperationAlreadyCancelled(IPNetworkHub.Operation operation);
error ChallengePeriodNotTerminated(uint64 startTimestamp, uint64 endTimestamp);
error ChallengePeriodTerminated(uint64 startTimestamp, uint64 endTimestamp);
error InvalidAssetParameters(uint256 assetAmount, address assetTokenAddress);
error InvalidProtocolFeeAssetParameters(uint256 protocolFeeAssetAmount, address protocolFeeAssetTokenAddress);
error InvalidUserOperation();
error NoUserOperation();
error PTokenNotCreated(address pTokenAddress);
error InvalidNetwork(bytes4 networkId);
error NotContract(address addr);
error LockDown();
error InvalidGovernanceMessage(bytes message);
error InvalidLockedAmountChallengePeriod(
    uint256 lockedAmountChallengePeriod,
    uint256 expectedLockedAmountChallengePeriod
);
error CallFailed();
error QueueFull();
error InvalidProtocolFee(IPNetworkHub.Operation operation);
error InvalidNetworkFeeAssetAmount();
error InvalidSentinel(address sentinel);
error InvalidGuardian(address guardian);
error InvalidLockedAmountStartChallenge(uint256 lockedAmountStartChallenge, uint256 expectedLockedAmountStartChallenge);
error InvalidActorStatus(IPNetworkHub.ActorStatus status, IPNetworkHub.ActorStatus expectedStatus);
error InvalidChallengeStatus(IPNetworkHub.ChallengeStatus status, IPNetworkHub.ChallengeStatus expectedStatus);
error NearToEpochEnd();
error ChallengeDurationPassed();
error MaxChallengeDurationNotPassed();
error ChallengeNotFound(IPNetworkHub.Challenge challenge);
error ChallengeDurationMustBeLessOrEqualThanMaxChallengePeriodDuration(
    uint64 challengeDuration,
    uint64 maxChallengePeriodDuration
);
error InvalidEpoch(uint16 epoch);
error Inactive();

contract PNetworkHub is IPNetworkHub, GovernanceMessageHandler, ReentrancyGuard {
    bytes32 public constant GOVERNANCE_MESSAGE_GUARDIANS = keccak256("GOVERNANCE_MESSAGE_GUARDIANS");
    bytes32 public constant GOVERNANCE_MESSAGE_SENTINELS = keccak256("GOVERNANCE_MESSAGE_SENTINELS");
    bytes32 public constant GOVERNANCE_MESSAGE_SLASH_SENTINEL = keccak256("GOVERNANCE_MESSAGE_SLASH_SENTINEL");
    bytes32 public constant GOVERNANCE_MESSAGE_SLASH_GUARDIAN = keccak256("GOVERNANCE_MESSAGE_SLASH_GUARDIAN");
    bytes32 public constant GOVERNANCE_MESSAGE_RESUME_SENTINEL = keccak256("GOVERNANCE_MESSAGE_RESUME_SENTINEL");
    bytes32 public constant GOVERNANCE_MESSAGE_RESUME_GUARDIAN = keccak256("GOVERNANCE_MESSAGE_RESUME_GUARDIAN");
    uint256 public constant FEE_BASIS_POINTS_DIVISOR = 10000;

    mapping(bytes32 => Action) private _operationsRelayerQueueAction;
    mapping(bytes32 => Action) private _operationsGovernanceCancelAction;
    mapping(bytes32 => Action) private _operationsGuardianCancelAction;
    mapping(bytes32 => Action) private _operationsSentinelCancelAction;
    mapping(bytes32 => Action) private _operationsExecuteAction;
    mapping(bytes32 => uint8) private _operationsTotalCancelActions;
    mapping(bytes32 => OperationStatus) private _operationsStatus;
    mapping(uint16 => bytes32) private _epochsSentinelsMerkleRoot;
    mapping(uint16 => bytes32) private _epochsGuardiansMerkleRoot;
    mapping(uint16 => uint16) private _epochsTotalNumberOfSentinels;
    mapping(uint16 => uint16) private _epochsTotalNumberOfGuardians;
    mapping(uint16 => mapping(bytes32 => Challenge)) private _epochsChallenges;
    mapping(uint16 => mapping(bytes32 => ChallengeStatus)) private _epochsChallengesStatus;
    mapping(uint16 => mapping(address => ActorStatus)) private _epochsActorsStatus;
    mapping(uint16 => uint16) private _epochsTotalNumberOfInactiveActors;
    mapping(uint16 => mapping(address => bytes32)) private _epochsActorsPendingChallengeId;

    address public immutable factory;
    address public immutable epochsManager;
    address public immutable feesManager;
    address public immutable slasher;
    uint32 public immutable baseChallengePeriodDuration;
    uint32 public immutable maxChallengePeriodDuration;
    uint16 public immutable kChallengePeriod;
    uint16 public immutable maxOperationsInQueue;
    bytes4 public immutable interimChainNetworkId;
    uint256 public immutable lockedAmountChallengePeriod;
    uint256 public immutable lockedAmountStartChallenge;
    uint64 public immutable challengeDuration;

    uint256 public challengesNonce;
    uint16 public numberOfOperationsInQueue;

    constructor(
        address factory_,
        uint32 baseChallengePeriodDuration_,
        address epochsManager_,
        address feesManager_,
        address telepathyRouter,
        address governanceMessageVerifier,
        address slasher_,
        uint256 lockedAmountChallengePeriod_,
        uint16 kChallengePeriod_,
        uint16 maxOperationsInQueue_,
        bytes4 interimChainNetworkId_,
        uint256 lockedAmountOpenChallenge_,
        uint64 challengeDuration_,
        uint32 expectedSourceChainId
    ) GovernanceMessageHandler(telepathyRouter, governanceMessageVerifier, expectedSourceChainId) {
        // NOTE: see the comment within _checkNearEndOfEpochStartChallenge
        maxChallengePeriodDuration =
            baseChallengePeriodDuration_ +
            ((maxOperationsInQueue_ ** 2) * kChallengePeriod_) -
            kChallengePeriod_;
        if (challengeDuration_ > maxChallengePeriodDuration) {
            revert ChallengeDurationMustBeLessOrEqualThanMaxChallengePeriodDuration(
                challengeDuration_,
                maxChallengePeriodDuration
            );
        }

        factory = factory_;
        epochsManager = epochsManager_;
        feesManager = feesManager_;
        slasher = slasher_;
        baseChallengePeriodDuration = baseChallengePeriodDuration_;
        lockedAmountChallengePeriod = lockedAmountChallengePeriod_;
        kChallengePeriod = kChallengePeriod_;
        maxOperationsInQueue = maxOperationsInQueue_;
        interimChainNetworkId = interimChainNetworkId_;
        lockedAmountStartChallenge = lockedAmountOpenChallenge_;
        challengeDuration = challengeDuration_;
    }

    /// @inheritdoc IPNetworkHub
    function challengeIdOf(Challenge memory challenge) public pure returns (bytes32) {
        return
            sha256(
                abi.encode(challenge)
            );
    }

    /// @inheritdoc IPNetworkHub
    function challengePeriodOf(Operation calldata operation) public view returns (uint64, uint64) {
        bytes32 operationId = operationIdOf(operation);
        OperationStatus operationStatus = _operationsStatus[operationId];
        return _challengePeriodOf(operationId, operationStatus);
    }

    /// @inheritdoc IPNetworkHub
    function claimLockedAmountStartChallenge(Challenge calldata challenge) external {
        bytes32 challengeId = challengeIdOf(challenge);
        uint16 currentEpoch = IEpochsManager(epochsManager).currentEpoch();
        uint16 challengeEpoch = getChallengeEpoch(challenge);

        if (challengeEpoch >= currentEpoch) {
            revert InvalidEpoch(challengeEpoch);
        }

        ChallengeStatus challengeStatus = _epochsChallengesStatus[challengeEpoch][challengeId];
        if (challengeStatus == ChallengeStatus.Null) {
            revert ChallengeNotFound(challenge);
        }

        if (challengeStatus != ChallengeStatus.Pending) {
            revert InvalidChallengeStatus(challengeStatus, ChallengeStatus.Pending);
        }

        _epochsChallengesStatus[challengeEpoch][challengeId] = ChallengeStatus.PartiallyUnsolved;

        (bool sent, ) = challenge.challenger.call{value: lockedAmountStartChallenge}("");
        if (!sent) {
            revert CallFailed();
        }

        emit ChallengePartiallyUnsolved(challenge);
    }

    /// @inheritdoc IPNetworkHub
    function getChallengeEpoch(Challenge calldata challenge) public view returns (uint16) {
        uint256 epochDuration = IEpochsManager(epochsManager).epochDuration();
        uint256 startFirstEpochTimestamp = IEpochsManager(epochsManager).startFirstEpochTimestamp();
        return uint16((challenge.timestamp - startFirstEpochTimestamp) / epochDuration);
    }

    /// @inheritdoc IPNetworkHub
    function getChallengeStatus(Challenge calldata challenge) external view returns (ChallengeStatus) {
        return _epochsChallengesStatus[getChallengeEpoch(challenge)][challengeIdOf(challenge)];
    }

    /// @inheritdoc IPNetworkHub
    function getCurrentActiveActorsAdjustmentDuration() public view returns (uint64) {
        uint16 currentEpoch = IEpochsManager(epochsManager).currentEpoch();
        uint16 activeActors = (_epochsTotalNumberOfSentinels[currentEpoch] +
            _epochsTotalNumberOfGuardians[currentEpoch]) - _epochsTotalNumberOfInactiveActors[currentEpoch];
        return 30 days / ((activeActors ** 5) + 1);
    }

    /// @inheritdoc IPNetworkHub
    function getCurrentChallengePeriodDuration() public view returns (uint64) {
        return getCurrentActiveActorsAdjustmentDuration() + getCurrentQueuedOperationsAdjustmentDuration();
    }

    /// @inheritdoc IPNetworkHub
    function getCurrentQueuedOperationsAdjustmentDuration() public view returns (uint64) {
        uint32 localNumberOfOperationsInQueue = numberOfOperationsInQueue;
        if (localNumberOfOperationsInQueue == 0) return baseChallengePeriodDuration;

        return
            baseChallengePeriodDuration + ((localNumberOfOperationsInQueue ** 2) * kChallengePeriod) - kChallengePeriod;
    }

    /// @inheritdoc IPNetworkHub
    function getGuardiansMerkleRootForEpoch(uint16 epoch) external view returns (bytes32) {
        return _epochsGuardiansMerkleRoot[epoch];
    }

    /// @inheritdoc IPNetworkHub
    function getNetworkId() external view returns (bytes4) {
        return Network.getCurrentNetworkId();
    }

    /// @inheritdoc IPNetworkHub
    function getPendingChallengeIdByEpochOf(uint16 epoch, address actor) external view returns (bytes32) {
        return _epochsActorsPendingChallengeId[epoch][actor];
    }

    /// @inheritdoc IPNetworkHub
    function getSentinelsMerkleRootForEpoch(uint16 epoch) external view returns (bytes32) {
        return _epochsSentinelsMerkleRoot[epoch];
    }

    /// @inheritdoc IPNetworkHub
    function getTotalNumberOfInactiveActorsForCurrentEpoch() external view returns (uint16) {
        return _epochsTotalNumberOfInactiveActors[IEpochsManager(epochsManager).currentEpoch()];
    }

    /// @inheritdoc IPNetworkHub
    function operationIdOf(Operation calldata operation) public pure returns (bytes32) {
        return
            sha256(
                abi.encode(operation)
            );
    }

    /// @inheritdoc IPNetworkHub
    function operationStatusOf(Operation calldata operation) external view returns (OperationStatus) {
        return _operationsStatus[operationIdOf(operation)];
    }

    /// @inheritdoc IPNetworkHub
    function protocolGuardianCancelOperation(Operation calldata operation, bytes32[] calldata proof) external {
        _checkLockDownMode(false);
        address guardian = _msgSender();
        if (!_isGuardian(guardian, proof)) {
            revert InvalidGuardian(guardian);
        }

        _protocolCancelOperation(operation, operationIdOf(operation), guardian, ActorTypes.Guardian);
    }

    /// @inheritdoc IPNetworkHub
    function protocolGovernanceCancelOperation(Operation calldata operation) external {
        // TODO check if msg.sender is governance
        _protocolCancelOperation(operation, operationIdOf(operation), msg.sender, ActorTypes.Governance);
    }

    /// @inheritdoc IPNetworkHub
    function protocolSentinelCancelOperation(
        Operation calldata operation,
        bytes32[] calldata proof,
        bytes calldata signature
    ) external {
        _checkLockDownMode(false);
        bytes32 operationId = operationIdOf(operation);
        address sentinel = ECDSA.recover(ECDSA.toEthSignedMessageHash(operationId), signature);
        if (!_isSentinel(sentinel, proof)) {
            revert InvalidSentinel(sentinel);
        }

        _protocolCancelOperation(operation, operationId, sentinel, ActorTypes.Sentinel);
    }

    /// @inheritdoc IPNetworkHub
    function protocolExecuteOperation(Operation calldata operation) external payable nonReentrant {
        _checkLockDownMode(false);

        bytes32 operationId = operationIdOf(operation);
        OperationStatus operationStatus = _operationsStatus[operationId];
        if (operationStatus == OperationStatus.Executed) {
            revert OperationAlreadyExecuted(operation);
        } else if (operationStatus == OperationStatus.Cancelled) {
            revert OperationAlreadyCancelled(operation);
        } else if (operationStatus == OperationStatus.Null) {
            revert OperationNotFound(operation);
        }

        (uint64 startTimestamp, uint64 endTimestamp) = _challengePeriodOf(operationId, operationStatus);
        if (uint64(block.timestamp) < endTimestamp) {
            revert ChallengePeriodNotTerminated(startTimestamp, endTimestamp);
        }

        address pTokenAddress = IPFactory(factory).getPTokenAddress(
            operation.underlyingAssetName,
            operation.underlyingAssetSymbol,
            operation.underlyingAssetDecimals,
            operation.underlyingAssetTokenAddress,
            operation.underlyingAssetNetworkId
        );

        uint256 effectiveOperationAssetAmount = operation.assetAmount;

        // NOTE: if we are on the interim chain we must take the fee
        if (interimChainNetworkId == Network.getCurrentNetworkId()) {
            effectiveOperationAssetAmount = _takeProtocolFee(operation, pTokenAddress);

            // NOTE: if we are on interim chain but the effective destination chain (forwardDestinationNetworkId) is another one
            // we have to emit an user Operation without protocol fee and with effectiveOperationAssetAmount and forwardDestinationNetworkId as
            // destinationNetworkId in order to proxy the Operation on the destination chain.
            if (
                interimChainNetworkId != operation.forwardDestinationNetworkId &&
                operation.forwardDestinationNetworkId != bytes4(0)
            ) {
                effectiveOperationAssetAmount = _takeNetworkFee(
                    effectiveOperationAssetAmount,
                    operation.networkFeeAssetAmount,
                    operationId,
                    pTokenAddress
                );

                _releaseOperationLockedAmountChallengePeriod(operationId);
                emit UserOperation(
                    gasleft(),
                    operation.originAccount,
                    operation.destinationAccount,
                    operation.forwardDestinationNetworkId,
                    operation.underlyingAssetName,
                    operation.underlyingAssetSymbol,
                    operation.underlyingAssetDecimals,
                    operation.underlyingAssetTokenAddress,
                    operation.underlyingAssetNetworkId,
                    pTokenAddress,
                    effectiveOperationAssetAmount,
                    address(0),
                    0,
                    operation.forwardNetworkFeeAssetAmount,
                    0,
                    bytes4(0),
                    operation.userData,
                    operation.optionsMask,
                    operation.isForProtocol
                );

                emit OperationExecuted(operation);
                return;
            }
        }

        effectiveOperationAssetAmount = _takeNetworkFee(
            effectiveOperationAssetAmount,
            operation.networkFeeAssetAmount,
            operationId,
            pTokenAddress
        );

        // NOTE: Execute the operation on the target blockchain. If destinationNetworkId is equivalent to
        // interimChainNetworkId, then the effectiveOperationAssetAmount would be the result of operation.assetAmount minus
        // the associated fee. However, if destinationNetworkId is not the same as interimChainNetworkId, the effectiveOperationAssetAmount
        // is equivalent to operation.assetAmount. In this case, as the operation originates from the interim chain, the operation.assetAmount
        // doesn't include the fee. This is because when the UserOperation event is triggered, and the interimChainNetworkId
        // does not equal operation.destinationNetworkId, the event contains the effectiveOperationAssetAmount.
        address destinationAddress = Utils.hexStringToAddress(operation.destinationAccount);
        if (effectiveOperationAssetAmount > 0) {
            IPToken(pTokenAddress).protocolMint(destinationAddress, effectiveOperationAssetAmount);

            if (Utils.isBitSet(operation.optionsMask, 0)) {
                if (!Network.isCurrentNetwork(operation.underlyingAssetNetworkId)) {
                    revert InvalidNetwork(operation.underlyingAssetNetworkId);
                }
                IPToken(pTokenAddress).protocolBurn(destinationAddress, effectiveOperationAssetAmount);
            }
        }

        if (operation.userData.length > 0) {
            if (destinationAddress.code.length == 0) revert NotContract(destinationAddress);

            try
                IPReceiver(destinationAddress).receiveUserData(
                    operation.originNetworkId,
                    operation.originAccount,
                    operation.userData
                )
            {} catch {}
        }

        _releaseOperationLockedAmountChallengePeriod(operationId);
        emit OperationExecuted(operation);
    }

    /// @inheritdoc IPNetworkHub
    function protocolQueueOperation(Operation calldata operation) external payable {
        _checkLockDownMode(true);

        if (msg.value != lockedAmountChallengePeriod) {
            revert InvalidLockedAmountChallengePeriod(msg.value, lockedAmountChallengePeriod);
        }

        if (numberOfOperationsInQueue >= maxOperationsInQueue) {
            revert QueueFull();
        }

        bytes32 operationId = operationIdOf(operation);

        OperationStatus operationStatus = _operationsStatus[operationId];
        if (operationStatus == OperationStatus.Executed) {
            revert OperationAlreadyExecuted(operation);
        } else if (operationStatus == OperationStatus.Cancelled) {
            revert OperationAlreadyCancelled(operation);
        } else if (operationStatus == OperationStatus.Queued) {
            revert OperationAlreadyQueued(operation);
        }

        _operationsRelayerQueueAction[operationId] = Action({actor: _msgSender(), timestamp: uint64(block.timestamp)});
        _operationsStatus[operationId] = OperationStatus.Queued;
        unchecked {
            ++numberOfOperationsInQueue;
        }

        emit OperationQueued(operation);
    }

    /// @inheritdoc IPNetworkHub
    function slashByChallenge(Challenge calldata challenge) external {
        bytes32 challengeId = challengeIdOf(challenge);
        uint16 currentEpoch = IEpochsManager(epochsManager).currentEpoch();
        ChallengeStatus challengeStatus = _epochsChallengesStatus[currentEpoch][challengeId];

        // NOTE: avoid to slash by challenges opened in previous epochs
        if (challengeStatus == ChallengeStatus.Null) {
            revert ChallengeNotFound(challenge);
        }

        if (challengeStatus != ChallengeStatus.Pending) {
            revert InvalidChallengeStatus(challengeStatus, ChallengeStatus.Pending);
        }

        if (block.timestamp <= challenge.timestamp + challengeDuration) {
            revert MaxChallengeDurationNotPassed();
        }

        _epochsChallengesStatus[currentEpoch][challengeId] = ChallengeStatus.Unsolved;
        _epochsActorsStatus[currentEpoch][challenge.actor] = ActorStatus.Inactive;
        delete _epochsActorsPendingChallengeId[currentEpoch][challenge.actor];

        (bool sent, ) = challenge.challenger.call{value: lockedAmountStartChallenge}("");
        if (!sent) {
            revert CallFailed();
        }

        unchecked {
            ++_epochsTotalNumberOfInactiveActors[currentEpoch];
        }

        bytes4 currentNetworkId = Network.getCurrentNetworkId();
        if (currentNetworkId == interimChainNetworkId) {
            // NOTE: If a slash happens on the interim chain we can avoid to emit the UserOperation
            //  in order to speed up the slashing process
            IPReceiver(slasher).receiveUserData(
                currentNetworkId,
                Utils.addressToHexString(address(this)),
                abi.encode(challenge.actor, challenge.challenger)
            );
        } else {
            emit UserOperation(
                gasleft(),
                Utils.addressToHexString(address(this)),
                Utils.addressToHexString(slasher),
                interimChainNetworkId,
                "",
                "",
                0,
                address(0),
                bytes4(0),
                address(0),
                0,
                address(0),
                0,
                0,
                0,
                0,
                abi.encode(challenge.actor, challenge.challenger),
                bytes32(0),
                true // isForProtocol
            );
        }

        emit ChallengeUnsolved(challenge);
    }

    /// @inheritdoc IPNetworkHub
    function solveChallengeGuardian(Challenge calldata challenge, bytes32[] calldata proof) external {
        address guardian = _msgSender();
        if (guardian != challenge.actor || !_isGuardian(guardian, proof)) {
            revert InvalidGuardian(guardian);
        }

        _solveChallenge(challenge, challengeIdOf(challenge));
    }

    /// @inheritdoc IPNetworkHub
    function solveChallengeSentinel(
        Challenge calldata challenge,
        bytes32[] calldata proof,
        bytes calldata signature
    ) external {
        bytes32 challengeId = challengeIdOf(challenge);
        address sentinel = ECDSA.recover(ECDSA.toEthSignedMessageHash(challengeId), signature);
        if (sentinel != challenge.actor || !_isSentinel(sentinel, proof)) {
            revert InvalidSentinel(sentinel);
        }

        _solveChallenge(challenge, challengeId);
    }

    /// @inheritdoc IPNetworkHub
    function startChallengeGuardian(address guardian, bytes32[] calldata proof) external payable {
        _checkNearEndOfEpochStartChallenge();
        if (!_isGuardian(guardian, proof)) {
            revert InvalidGuardian(guardian);
        }

        _startChallenge(guardian);
    }

    /// @inheritdoc IPNetworkHub
    function startChallengeSentinel(address sentinel, bytes32[] calldata proof) external payable {
        _checkNearEndOfEpochStartChallenge();
        if (!_isSentinel(sentinel, proof)) {
            revert InvalidSentinel(sentinel);
        }

        _startChallenge(sentinel);
    }

    /// @inheritdoc IPNetworkHub
    function userSend(
        string calldata destinationAccount,
        bytes4 destinationNetworkId,
        string calldata underlyingAssetName,
        string calldata underlyingAssetSymbol,
        uint256 underlyingAssetDecimals,
        address underlyingAssetTokenAddress,
        bytes4 underlyingAssetNetworkId,
        address assetTokenAddress,
        uint256 assetAmount,
        address protocolFeeAssetTokenAddress,
        uint256 protocolFeeAssetAmount,
        uint256 networkFeeAssetAmount,
        uint256 forwardNetworkFeeAssetAmount,
        bytes calldata userData,
        bytes32 optionsMask
    ) external {
        address msgSender = _msgSender();

        if (
            (assetAmount > 0 && assetTokenAddress == address(0)) ||
            (assetAmount == 0 && assetTokenAddress != address(0))
        ) {
            revert InvalidAssetParameters(assetAmount, assetTokenAddress);
        }

        if (networkFeeAssetAmount > assetAmount) {
            revert InvalidNetworkFeeAssetAmount();
        }

        address pTokenAddress = IPFactory(factory).getPTokenAddress(
            underlyingAssetName,
            underlyingAssetSymbol,
            underlyingAssetDecimals,
            underlyingAssetTokenAddress,
            underlyingAssetNetworkId
        );
        if (pTokenAddress.code.length == 0) {
            revert PTokenNotCreated(pTokenAddress);
        }

        bool isCurrentNetwork = Network.isCurrentNetwork(destinationNetworkId);

        // TODO: A user might bypass paying the protocol fee when sending userData, particularly
        // if they dispatch userData with an assetAmount greater than zero. However, if the countervalue of
        // the assetAmount is less than the protocol fee, it implies the user has paid less than the
        // required protocol fee to transmit userData. How can we fix this problem?
        if (assetAmount > 0) {
            if (protocolFeeAssetAmount > 0 || protocolFeeAssetTokenAddress != address(0)) {
                revert InvalidProtocolFeeAssetParameters(protocolFeeAssetAmount, protocolFeeAssetTokenAddress);
            }

            if (underlyingAssetTokenAddress == assetTokenAddress && isCurrentNetwork) {
                IPToken(pTokenAddress).userMint(msgSender, assetAmount);
            } else if (underlyingAssetTokenAddress == assetTokenAddress && !isCurrentNetwork) {
                IPToken(pTokenAddress).userMintAndBurn(msgSender, assetAmount);
            } else if (pTokenAddress == assetTokenAddress && !isCurrentNetwork) {
                IPToken(pTokenAddress).userBurn(msgSender, assetAmount);
            } else {
                revert InvalidUserOperation();
            }
        } else if (userData.length > 0) {
            if (protocolFeeAssetAmount == 0 || protocolFeeAssetTokenAddress == address(0)) {
                revert InvalidProtocolFeeAssetParameters(protocolFeeAssetAmount, protocolFeeAssetTokenAddress);
            }

            if (underlyingAssetTokenAddress == protocolFeeAssetTokenAddress && !isCurrentNetwork) {
                IPToken(pTokenAddress).userMintAndBurn(msgSender, protocolFeeAssetAmount);
            } else if (pTokenAddress == protocolFeeAssetTokenAddress && !isCurrentNetwork) {
                IPToken(pTokenAddress).userBurn(msgSender, protocolFeeAssetAmount);
            } else {
                revert InvalidUserOperation();
            }
        } else {
            revert NoUserOperation();
        }

        emit UserOperation(
            gasleft(),
            Utils.addressToHexString(msgSender),
            destinationAccount,
            interimChainNetworkId,
            underlyingAssetName,
            underlyingAssetSymbol,
            underlyingAssetDecimals,
            underlyingAssetTokenAddress,
            underlyingAssetNetworkId,
            assetTokenAddress,
            // NOTE: pTokens on host chains have always 18 decimals.
            Network.isCurrentNetwork(underlyingAssetNetworkId)
                ? Utils.normalizeAmount(assetAmount, underlyingAssetDecimals, true)
                : assetAmount,
            protocolFeeAssetTokenAddress,
            Network.isCurrentNetwork(underlyingAssetNetworkId)
                ? Utils.normalizeAmount(protocolFeeAssetAmount, underlyingAssetDecimals, true)
                : protocolFeeAssetAmount,
            Network.isCurrentNetwork(underlyingAssetNetworkId)
                ? Utils.normalizeAmount(networkFeeAssetAmount, underlyingAssetDecimals, true)
                : networkFeeAssetAmount,
            Network.isCurrentNetwork(underlyingAssetNetworkId)
                ? Utils.normalizeAmount(forwardNetworkFeeAssetAmount, underlyingAssetDecimals, true)
                : forwardNetworkFeeAssetAmount,
            destinationNetworkId,
            userData,
            optionsMask,
            false // isForProtocol
        );
    }

    function _challengePeriodOf(
        bytes32 operationId,
        OperationStatus operationStatus
    ) internal view returns (uint64, uint64) {
        if (operationStatus != OperationStatus.Queued) return (0, 0);

        Action storage queueAction = _operationsRelayerQueueAction[operationId];
        uint64 startTimestamp = queueAction.timestamp;
        uint64 endTimestamp = startTimestamp + getCurrentChallengePeriodDuration();
        if (_operationsTotalCancelActions[operationId] == 0) {
            return (startTimestamp, endTimestamp);
        }

        if (_operationsGuardianCancelAction[operationId].actor != address(0)) {
            endTimestamp += 5 days;
        }

        if (_operationsSentinelCancelAction[operationId].actor != address(0)) {
            endTimestamp += 5 days;
        }

        return (startTimestamp, endTimestamp);
    }

    function _checkLockDownMode(bool addMaxChallengePeriodDuration) internal view {
        uint16 currentEpoch = IEpochsManager(epochsManager).currentEpoch();
        if (
            _epochsSentinelsMerkleRoot[currentEpoch] == bytes32(0) ||
            _epochsGuardiansMerkleRoot[currentEpoch] == bytes32(0) ||
            _epochsTotalNumberOfInactiveActors[currentEpoch] ==
            _epochsTotalNumberOfSentinels[currentEpoch] + _epochsTotalNumberOfGuardians[currentEpoch]
        ) {
            revert LockDown();
        }

        uint256 epochDuration = IEpochsManager(epochsManager).epochDuration();
        uint256 startFirstEpochTimestamp = IEpochsManager(epochsManager).startFirstEpochTimestamp();
        uint256 currentEpochEndTimestamp = startFirstEpochTimestamp + ((currentEpoch + 1) * epochDuration);

        // If a relayer queues a malicious operation shortly before lockdown mode begins, what happens?
        // When lockdown mode is initiated, both sentinels and guardians lose their ability to cancel operations.
        // Consequently, the malicious operation may be executed immediately after the lockdown period ends,
        // especially if the operation's queue time is significantly shorter than the lockdown duration.
        // To mitigate this risk, operations should not be queued if the max challenge period makes
        // the operation challenge period finish after 1 hour before the end of an epoch.
        if (
            block.timestamp + (addMaxChallengePeriodDuration ? maxChallengePeriodDuration : 0) >=
            currentEpochEndTimestamp - 1 hours
        ) {
            revert LockDown();
        }
    }

    function _checkNearEndOfEpochStartChallenge() internal view {
        uint256 epochDuration = IEpochsManager(epochsManager).epochDuration();
        uint16 currentEpoch = IEpochsManager(epochsManager).currentEpoch();
        uint256 startFirstEpochTimestamp = IEpochsManager(epochsManager).startFirstEpochTimestamp();
        uint256 currentEpochEndTimestamp = startFirstEpochTimestamp + ((currentEpoch + 1) * epochDuration);

        // NOTE: 1 hours = threshold that a guardian/sentinel or challenger has time to resolve the challenge
        // before the epoch ends. Not setting this threshold would mean that it is possible
        // to open a challenge that can be solved an instant before the epoch change causing problems.
        // It is important that the system enters in lockdown mode before stopping to start challenges.
        // In this way we are sure that no malicious operations can be queued when keep alive mechanism is disabled.
        // currentEpochEndTimestamp - 1 hours - challengeDuration <= currentEpochEndTimestamp - 1 hours - maxChallengePeriodDuration
        // challengeDuration <=  maxChallengePeriodDuration
        // challengeDuration <= baseChallengePeriodDuration + (maxOperationsInQueue * maxOperationsInQueue * kChallengePeriod) - kChallengePeriod
        if (block.timestamp + challengeDuration > currentEpochEndTimestamp - 1 hours) {
            revert NearToEpochEnd();
        }
    }

    function _isGuardian(address guardian, bytes32[] calldata proof) internal view returns (bool) {
        return
            MerkleProof.verify(
                proof,
                _epochsGuardiansMerkleRoot[IEpochsManager(epochsManager).currentEpoch()],
                keccak256(abi.encodePacked(guardian))
            );
    }

    function _isSentinel(address sentinel, bytes32[] calldata proof) internal view returns (bool) {
        return true;
        // return
        //     MerkleProof.verify(
        //         proof,
        //         _epochsSentinelsMerkleRoot[IEpochsManager(epochsManager).currentEpoch()],
        //         keccak256(abi.encodePacked(sentinel))
        //     );
    }

    function _maybeCancelPendingChallenge(uint16 epoch, address actor) internal {
        bytes32 pendingChallengeId = _epochsActorsPendingChallengeId[epoch][actor];
        if (pendingChallengeId != bytes32(0)) {
            Challenge storage challenge = _epochsChallenges[epoch][pendingChallengeId];
            delete _epochsActorsPendingChallengeId[epoch][actor];
            _epochsChallengesStatus[epoch][pendingChallengeId] = ChallengeStatus.Cancelled;
            _epochsActorsStatus[epoch][challenge.actor] = ActorStatus.Active; // NOTE: Change Slashed into Active in order to trigger the slash below
            (bool sent, ) = challenge.challenger.call{value: lockedAmountStartChallenge}("");
            if (!sent) {
                revert CallFailed();
            }

            emit ChallengeCancelled(challenge);
        }
    }

    function _onGovernanceMessage(bytes memory message) internal override {
        (bytes32 messageType, bytes memory messageData) = abi.decode(message, (bytes32, bytes));

        if (messageType == GOVERNANCE_MESSAGE_GUARDIANS) {
            (uint16 epoch, uint16 totalNumberOfGuardians, bytes32 guardiansMerkleRoot) = abi.decode(
                messageData,
                (uint16, uint16, bytes32)
            );

            _epochsGuardiansMerkleRoot[epoch] = guardiansMerkleRoot;
            _epochsTotalNumberOfGuardians[epoch] = totalNumberOfGuardians;

            return;
        }

        if (messageType == GOVERNANCE_MESSAGE_SENTINELS) {
            (uint16 epoch, uint16 totalNumberOfSentinels, bytes32 sentinelsMerkleRoot) = abi.decode(
                messageData,
                (uint16, uint16, bytes32)
            );

            _epochsSentinelsMerkleRoot[epoch] = sentinelsMerkleRoot;
            _epochsTotalNumberOfSentinels[epoch] = totalNumberOfSentinels;

            return;
        }

        if (messageType == GOVERNANCE_MESSAGE_SLASH_SENTINEL) {
            (uint16 epoch, address sentinel) = abi.decode(messageData, (uint16, address));
            // NOTE: Consider the scenario where a sentinel's status is 'Challenged', and a GOVERNANCE_MESSAGE_SLASH_SENTINEL is received
            // for the same sentinel before the challenge is resolved or the sentinel is slashed.
            // If a sentinel is already 'Challenged', we should:
            // - cancel the current challenge
            // - set to active the state of the sentinel
            // - send to the challenger the bond
            // - slash it
            _maybeCancelPendingChallenge(epoch, sentinel);

            if (_epochsActorsStatus[epoch][sentinel] == ActorStatus.Active) {
                unchecked {
                    ++_epochsTotalNumberOfInactiveActors[epoch];
                }
                _epochsActorsStatus[epoch][sentinel] = ActorStatus.Inactive;
                emit SentinelSlashed(epoch, sentinel);
            }
            return;
        }

        if (messageType == GOVERNANCE_MESSAGE_SLASH_GUARDIAN) {
            (uint16 epoch, address guardian) = abi.decode(messageData, (uint16, address));
            // NOTE: same comment above
            _maybeCancelPendingChallenge(epoch, guardian);

            if (_epochsActorsStatus[epoch][guardian] == ActorStatus.Active) {
                unchecked {
                    ++_epochsTotalNumberOfInactiveActors[epoch];
                }
                _epochsActorsStatus[epoch][guardian] = ActorStatus.Inactive;
                emit GuardianSlashed(epoch, guardian);
            }
            return;
        }

        if (messageType == GOVERNANCE_MESSAGE_RESUME_SENTINEL) {
            (uint16 epoch, address sentinel) = abi.decode(messageData, (uint16, address));
            if (_epochsActorsStatus[epoch][sentinel] == ActorStatus.Inactive) {
                unchecked {
                    --_epochsTotalNumberOfInactiveActors[epoch];
                }

                _epochsActorsStatus[epoch][sentinel] = ActorStatus.Active;
                emit SentinelResumed(epoch, sentinel);
            }

            return;
        }

        if (messageType == GOVERNANCE_MESSAGE_RESUME_GUARDIAN) {
            (uint16 epoch, address guardian) = abi.decode(messageData, (uint16, address));
            if (_epochsActorsStatus[epoch][guardian] == ActorStatus.Inactive) {
                unchecked {
                    --_epochsTotalNumberOfInactiveActors[epoch];
                }

                _epochsActorsStatus[epoch][guardian] = ActorStatus.Active;
                emit GuardianResumed(epoch, guardian);
            }

            return;
        }

        revert InvalidGovernanceMessage(message);
    }

    function _protocolCancelOperation(
        Operation calldata operation,
        bytes32 operationId,
        address actor,
        ActorTypes actorType
    ) internal {
        uint16 currentEpoch = IEpochsManager(epochsManager).currentEpoch();
        if (_epochsActorsStatus[currentEpoch][actor] == ActorStatus.Inactive) {
            revert Inactive();
        }

        OperationStatus operationStatus = _operationsStatus[operationId];
        if (operationStatus == OperationStatus.Executed) {
            revert OperationAlreadyExecuted(operation);
        } else if (operationStatus == OperationStatus.Cancelled) {
            revert OperationAlreadyCancelled(operation);
        } else if (operationStatus == OperationStatus.Null) {
            revert OperationNotFound(operation);
        }

        (uint64 startTimestamp, uint64 endTimestamp) = _challengePeriodOf(operationId, operationStatus);
        if (uint64(block.timestamp) >= endTimestamp) {
            revert ChallengePeriodTerminated(startTimestamp, endTimestamp);
        }

        Action memory action = Action({actor: _msgSender(), timestamp: uint64(block.timestamp)});
        if (actorType == ActorTypes.Governance) {
            if (_operationsGovernanceCancelAction[operationId].actor != address(0)) {
                revert GovernanceOperationAlreadyCancelled(operation);
            }

            _operationsGovernanceCancelAction[operationId] = action;
            emit GovernanceOperationCancelled(operation);
        }
        if (actorType == ActorTypes.Guardian) {
            if (_operationsGuardianCancelAction[operationId].actor != address(0)) {
                revert GuardianOperationAlreadyCancelled(operation);
            }

            _operationsGuardianCancelAction[operationId] = action;
            emit GuardianOperationCancelled(operation);
        }
        if (actorType == ActorTypes.Sentinel) {
            if (_operationsSentinelCancelAction[operationId].actor != address(0)) {
                revert SentinelOperationAlreadyCancelled(operation);
            }

            _operationsSentinelCancelAction[operationId] = action;
            emit SentinelOperationCancelled(operation);
        }

        unchecked {
            ++_operationsTotalCancelActions[operationId];
        }
        if (_operationsTotalCancelActions[operationId] == 2) {
            unchecked {
                --numberOfOperationsInQueue;
            }
            _operationsStatus[operationId] = OperationStatus.Cancelled;

            // TODO: send the lockedAmountChallengePeriod to the DAO
            (bool sent, ) = address(0).call{value: lockedAmountChallengePeriod}("");
            if (!sent) {
                revert CallFailed();
            }

            emit OperationCancelled(operation);
        }
    }

    function _releaseOperationLockedAmountChallengePeriod(bytes32 operationId) internal {
        _operationsStatus[operationId] = OperationStatus.Executed;
        _operationsExecuteAction[operationId] = Action({actor: _msgSender(), timestamp: uint64(block.timestamp)});

        Action storage queuedAction = _operationsRelayerQueueAction[operationId];
        (bool sent, ) = queuedAction.actor.call{value: lockedAmountChallengePeriod}("");
        if (!sent) {
            revert CallFailed();
        }

        unchecked {
            --numberOfOperationsInQueue;
        }
    }

    function _solveChallenge(Challenge calldata challenge, bytes32 challengeId) internal {
        uint16 currentEpoch = IEpochsManager(epochsManager).currentEpoch();
        ChallengeStatus challengeStatus = _epochsChallengesStatus[currentEpoch][challengeId];

        if (challengeStatus == ChallengeStatus.Null) {
            revert ChallengeNotFound(challenge);
        }

        if (challengeStatus != ChallengeStatus.Pending) {
            revert InvalidChallengeStatus(challengeStatus, ChallengeStatus.Pending);
        }

        if (block.timestamp > challenge.timestamp + challengeDuration) {
            revert ChallengeDurationPassed();
        }

        // TODO: send the lockedAmountStartChallenge to the DAO
        (bool sent, ) = address(0).call{value: lockedAmountStartChallenge}("");
        if (!sent) {
            revert CallFailed();
        }

        _epochsChallengesStatus[currentEpoch][challengeId] = ChallengeStatus.Solved;
        _epochsActorsStatus[currentEpoch][challenge.actor] = ActorStatus.Active;
        delete _epochsActorsPendingChallengeId[currentEpoch][challenge.actor];
        emit ChallengeSolved(challenge);
    }

    function _startChallenge(address actor) internal {
        address challenger = _msgSender();
        uint16 currentEpoch = IEpochsManager(epochsManager).currentEpoch();

        if (msg.value != lockedAmountStartChallenge) {
            revert InvalidLockedAmountStartChallenge(msg.value, lockedAmountStartChallenge);
        }

        ActorStatus actorStatus = _epochsActorsStatus[currentEpoch][actor];
        if (actorStatus != ActorStatus.Active) {
            revert InvalidActorStatus(actorStatus, ActorStatus.Active);
        }

        Challenge memory challenge = Challenge({
            nonce: challengesNonce,
            actor: actor,
            challenger: challenger,
            timestamp: uint64(block.timestamp),
            networkId: Network.getCurrentNetworkId()
        });
        bytes32 challengeId = challengeIdOf(challenge);
        _epochsChallenges[currentEpoch][challengeId] = challenge;
        _epochsChallengesStatus[currentEpoch][challengeId] = ChallengeStatus.Pending;
        _epochsActorsStatus[currentEpoch][actor] = ActorStatus.Challenged;
        _epochsActorsPendingChallengeId[currentEpoch][actor] = challengeId;

        unchecked {
            ++challengesNonce;
        }

        emit ChallengePending(challenge);
    }

    function _takeNetworkFee(
        uint256 operationAmount,
        uint256 operationNetworkFeeAssetAmount,
        bytes32 operationId,
        address pTokenAddress
    ) internal returns (uint256) {
        if (operationNetworkFeeAssetAmount == 0) return operationAmount;

        Action storage queuedAction = _operationsRelayerQueueAction[operationId];

        address queuedActionActor = queuedAction.actor;
        address executedActionActor = _msgSender();
        if (queuedActionActor == executedActionActor) {
            IPToken(pTokenAddress).protocolMint(queuedActionActor, operationNetworkFeeAssetAmount);
            return operationAmount - operationNetworkFeeAssetAmount;
        }

        // NOTE: protocolQueueOperation consumes in avg 117988. protocolExecuteOperation consumes in avg 198928.
        // which results in 37% to networkFeeQueueActor and 63% to networkFeeExecuteActor
        uint256 networkFeeQueueActor = (operationNetworkFeeAssetAmount * 3700) / FEE_BASIS_POINTS_DIVISOR; // 37%
        uint256 networkFeeExecuteActor = (operationNetworkFeeAssetAmount * 6300) / FEE_BASIS_POINTS_DIVISOR; // 63%
        IPToken(pTokenAddress).protocolMint(queuedActionActor, networkFeeQueueActor);
        IPToken(pTokenAddress).protocolMint(executedActionActor, networkFeeExecuteActor);

        return operationAmount - operationNetworkFeeAssetAmount;
    }

    function _takeProtocolFee(Operation calldata operation, address pTokenAddress) internal returns (uint256) {
        if (operation.assetAmount > 0 && operation.userData.length == 0) {
            uint256 feeBps = 20; // 0.2%
            uint256 fee = (operation.assetAmount * feeBps) / FEE_BASIS_POINTS_DIVISOR;
            IPToken(pTokenAddress).protocolMint(address(this), fee);
            IPToken(pTokenAddress).approve(feesManager, fee);
            IFeesManager(feesManager).depositFee(pTokenAddress, fee);
            return operation.assetAmount - fee;
        }
        // TODO: We need to determine how to process the fee when operation.userData.length is greater than zero
        //and operation.assetAmount is also greater than zero. By current design, userData is paid in USDC,
        // but what happens if a user wraps Ethereum, for example, and wants to couple it with a non-null
        //userData during the wrap operation? We must decide which token should be used for the userData fee payment.
        else if (operation.userData.length > 0 && operation.protocolFeeAssetAmount > 0) {
            // Take fee using pTokenAddress and operation.protocolFeeAssetAmount
            IPToken(pTokenAddress).protocolMint(address(this), operation.protocolFeeAssetAmount);
            // TODO: send it to the DAO
            return operation.assetAmount > 0 ? operation.assetAmount - operation.protocolFeeAssetAmount : 0;
        }

        if (operation.isForProtocol) {
            return 0;
        }

        revert InvalidProtocolFee(operation);
    }
}
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import {Network} from "../libraries/Network.sol";
import {IPRegistry} from "../interfaces/IPRegistry.sol";

contract PRegistry is IPRegistry, AccessControl {
    bytes32 public constant ADD_SUPPORTED_NETWORK_ID_ROLE = keccak256("ADD_SUPPORTED_NETWORK_ID_ROLE");

    address[] private _supportedHubs;
    uint32[] private _supportedChainIds;

    mapping(bytes4 => address) _networkIdToHub;

    constructor(address dandelionVoting) {
        _setupRole(ADD_SUPPORTED_NETWORK_ID_ROLE, dandelionVoting);
    }

    // @inheritdoc IPRegistry
    function addProtocolBlockchain(uint32 chainId, address hub) external onlyRole(ADD_SUPPORTED_NETWORK_ID_ROLE) {
        bytes4 networkId = Network.getNetworkIdFromChainId(chainId);
        // TODO: check if hub/chainId has been already pushed
        _supportedHubs.push(hub);
        _supportedChainIds.push(chainId);
        _networkIdToHub[networkId] = hub;
    }

    // @inheritdoc IPRegistry
    function isNetworkIdSupported(bytes4 networkId) public view returns (bool) {
        address hub = _networkIdToHub[networkId];
        return (hub != address(0));
    }

    // @inheritdoc IPRegistry
    function isChainIdSupported(uint32 chainId) external view returns (bool) {
        bytes4 networkId = Network.getNetworkIdFromChainId(chainId);
        return isNetworkIdSupported(networkId);
    }

    // @inheritdoc IPRegistry
    function getHubByNetworkId(bytes4 networkId) external view returns (address) {
        return _networkIdToHub[networkId];
    }

    // @inheritdoc IPRegistry
    function getSupportedHubs() external view returns (address[] memory) {
        return _supportedHubs;
    }

    // @inheritdoc IPRegistry
    function getSupportedChainIds() external view returns (uint32[] memory) {
        return _supportedChainIds;
    }
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {IERC20Metadata} from "@openzeppelin/contracts/interfaces/IERC20Metadata.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {IPToken} from "../interfaces/IPToken.sol";
import {Utils} from "../libraries/Utils.sol";
import {Network} from "../libraries/Network.sol";

error InvalidUnderlyingAssetName(string underlyingAssetName, string expectedUnderlyingAssetName);
error InvalidUnderlyingAssetSymbol(string underlyingAssetSymbol, string expectedUnderlyingAssetSymbol);
error InvalidUnderlyingAssetDecimals(uint256 underlyingAssetDecimals, uint256 expectedUnderlyingAssetDecimals);
error InvalidAssetParameters(uint256 assetAmount, address assetTokenAddress);
error SenderIsNotHub();
error InvalidNetwork(bytes4 networkId);

contract PToken is IPToken, ERC20 {
    using SafeERC20 for IERC20Metadata;

    address public immutable hub;
    address public immutable underlyingAssetTokenAddress;
    bytes4 public immutable underlyingAssetNetworkId;
    uint256 private immutable _underlyingAssetDecimals;

    modifier onlyHub() {
        if (_msgSender() != hub) {
            revert SenderIsNotHub();
        }
        _;
    }

    constructor(
        string memory underlyingAssetName,
        string memory underlyingAssetSymbol,
        uint256 underlyingAssetDecimals,
        address underlyingAssetTokenAddress_,
        bytes4 underlyingAssetNetworkId_,
        address hub_
    ) ERC20(string.concat("p", underlyingAssetName), string.concat("p", underlyingAssetSymbol)) {
        if (Network.isCurrentNetwork(underlyingAssetNetworkId_)) {
            string memory expectedUnderlyingAssetName = IERC20Metadata(underlyingAssetTokenAddress_).name();
            if (
                keccak256(abi.encodePacked(underlyingAssetName)) !=
                keccak256(abi.encodePacked(expectedUnderlyingAssetName))
            ) {
                revert InvalidUnderlyingAssetName(underlyingAssetName, expectedUnderlyingAssetName);
            }

            string memory expectedUnderlyingAssetSymbol = IERC20Metadata(underlyingAssetTokenAddress_).symbol();
            if (
                keccak256(abi.encodePacked(underlyingAssetSymbol)) !=
                keccak256(abi.encodePacked(expectedUnderlyingAssetSymbol))
            ) {
                revert InvalidUnderlyingAssetSymbol(underlyingAssetName, expectedUnderlyingAssetName);
            }

            uint256 expectedUnderliyngAssetDecimals = IERC20Metadata(underlyingAssetTokenAddress_).decimals();
            if (underlyingAssetDecimals != expectedUnderliyngAssetDecimals || expectedUnderliyngAssetDecimals > 18) {
                revert InvalidUnderlyingAssetDecimals(underlyingAssetDecimals, expectedUnderliyngAssetDecimals);
            }
        }

        underlyingAssetNetworkId = underlyingAssetNetworkId_;
        underlyingAssetTokenAddress = underlyingAssetTokenAddress_;
        _underlyingAssetDecimals = underlyingAssetDecimals;
        hub = hub_;
    }

    /// @inheritdoc IPToken
    function burn(uint256 amount) external {
        _burnAndReleaseCollateral(_msgSender(), amount);
    }

    /// @inheritdoc IPToken
    function mint(uint256 amount) external {
        _takeCollateralAndMint(_msgSender(), amount);
    }

    /// @inheritdoc IPToken
    function protocolMint(address account, uint256 amount) external onlyHub {
        _mint(account, amount);
    }

    /// @inheritdoc IPToken
    function protocolBurn(address account, uint256 amount) external onlyHub {
        _burnAndReleaseCollateral(account, amount);
    }

    /// @inheritdoc IPToken
    function userMint(address account, uint256 amount) external onlyHub {
        _takeCollateralAndMint(account, amount);
    }

    /// @inheritdoc IPToken
    function userMintAndBurn(address account, uint256 amount) external onlyHub {
        _takeCollateral(account, amount);
        uint256 normalizedAmount = Utils.normalizeAmount(amount, _underlyingAssetDecimals, true);
        emit Transfer(address(0), account, normalizedAmount);
        emit Transfer(account, address(0), normalizedAmount);
    }

    /// @inheritdoc IPToken
    function userBurn(address account, uint256 amount) external onlyHub {
        _burn(account, amount);
    }

    function _burnAndReleaseCollateral(address account, uint256 amount) internal {
        if (!Network.isCurrentNetwork(underlyingAssetNetworkId)) revert InvalidNetwork(underlyingAssetNetworkId);
        _burn(account, amount);
        IERC20Metadata(underlyingAssetTokenAddress).safeTransfer(
            account,
            Utils.normalizeAmount(amount, _underlyingAssetDecimals, false)
        );
    }

    function _takeCollateral(address account, uint256 amount) internal {
        if (!Network.isCurrentNetwork(underlyingAssetNetworkId)) revert InvalidNetwork(underlyingAssetNetworkId);
        IERC20Metadata(underlyingAssetTokenAddress).safeTransferFrom(account, address(this), amount);
    }

    function _takeCollateralAndMint(address account, uint256 amount) internal {
        _takeCollateral(account, amount);
        _mint(account, Utils.normalizeAmount(amount, _underlyingAssetDecimals, true));
    }
}
// SPDX-License-Identifier: Unlicense

pragma solidity ^0.8.19;

import {Utils} from "../libraries/Utils.sol";
import {IPRegistry} from "../interfaces/IPRegistry.sol";
import {ISlasher} from "../interfaces/ISlasher.sol";
import {IRegistrationManager} from "./IRegistrationManager.sol";

error NotHub(address hub);
error NotSupportedNetworkId(bytes4 originNetworkId);

contract Slasher is ISlasher {
    address public immutable pRegistry;
    address public immutable registrationManager;

    // Quantity of PNT to slash
    uint256 public immutable stakingSentinelAmountToSlash;

    constructor(address pRegistry_, address registrationManager_, uint256 stakingSentinelAmountToSlash_) {
        pRegistry = pRegistry_;
        stakingSentinelAmountToSlash = stakingSentinelAmountToSlash_;
        registrationManager = registrationManager_;
    }

    function receiveUserData(
        bytes4 originNetworkId,
        string calldata originAccount,
        bytes calldata userData
    ) external override {
        address originAccountAddress = Utils.hexStringToAddress(originAccount);

        if (!IPRegistry(pRegistry).isNetworkIdSupported(originNetworkId)) revert NotSupportedNetworkId(originNetworkId);

        address registeredHub = IPRegistry(pRegistry).getHubByNetworkId(originNetworkId);
        if (originAccountAddress != registeredHub) revert NotHub(originAccountAddress);

        (address actor, address challenger) = abi.decode(userData, (address, address));
        IRegistrationManager.Registration memory registration = IRegistrationManager(registrationManager)
            .sentinelRegistration(actor);

        // See file `Constants.sol` in dao-v2-contracts:
        //
        // bytes1 public constant REGISTRATION_SENTINEL_STAKING = 0x01;
        //
        // Borrowing sentinels have nothing at stake, so the slashing
        // quantity will be zero
        uint256 amountToSlash = registration.kind == 0x01 ? stakingSentinelAmountToSlash : 0;
        IRegistrationManager(registrationManager).slash(actor, amountToSlash, challenger);
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {IGovernanceMessageEmitter} from "../interfaces/IGovernanceMessageEmitter.sol";
import {IRegistrationManager} from "@pnetwork-association/dao-v2-contracts/contracts/interfaces/IRegistrationManager.sol";
import {ILendingManager} from "@pnetwork-association/dao-v2-contracts/contracts/interfaces/ILendingManager.sol";
import {IEpochsManager} from "@pnetwork-association/dao-v2-contracts/contracts/interfaces/IEpochsManager.sol";
import {MerkleProof} from "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import {IPRegistry} from "../interfaces/IPRegistry.sol";
import {MerkleTree} from "../libraries/MerkleTree.sol";

error InvalidAmount(uint256 amount, uint256 expectedAmount);
error InvalidGovernanceMessageVerifier(address governanceMessagerVerifier, address expectedGovernanceMessageVerifier);
error InvalidSentinelRegistration(bytes1 kind);
error NotRegistrationManager();
error InvalidNumberOfGuardians(uint16 numberOfGuardians, uint16 expectedNumberOfGuardians);

contract GovernanceMessageEmitter is IGovernanceMessageEmitter {
    bytes32 public constant GOVERNANCE_MESSAGE_SENTINELS = keccak256("GOVERNANCE_MESSAGE_SENTINELS");
    bytes32 public constant GOVERNANCE_MESSAGE_GUARDIANS = keccak256("GOVERNANCE_MESSAGE_GUARDIANS");
    bytes32 public constant GOVERNANCE_MESSAGE_SLASH_SENTINEL = keccak256("GOVERNANCE_MESSAGE_SLASH_SENTINEL");
    bytes32 public constant GOVERNANCE_MESSAGE_SLASH_GUARDIAN = keccak256("GOVERNANCE_MESSAGE_SLASH_GUARDIAN");
    bytes32 public constant GOVERNANCE_MESSAGE_RESUME_SENTINEL = keccak256("GOVERNANCE_MESSAGE_RESUME_SENTINEL");
    bytes32 public constant GOVERNANCE_MESSAGE_RESUME_GUARDIAN = keccak256("GOVERNANCE_MESSAGE_RESUME_GUARDIAN");

    address public immutable registry;
    address public immutable epochsManager;
    address public immutable lendingManager;
    address public immutable registrationManager;

    uint256 public totalNumberOfMessages;

    modifier onlyRegistrationManager() {
        if (msg.sender != registrationManager) {
            revert NotRegistrationManager();
        }

        _;
    }

    constructor(address epochsManager_, address lendingManager_, address registrationManager_, address registry_) {
        registry = registry_;
        epochsManager = epochsManager_;
        lendingManager = lendingManager_;
        registrationManager = registrationManager_;
    }

    /// @inheritdoc IGovernanceMessageEmitter
    function propagateActors(address[] calldata sentinels, address[] calldata guardians) external {
        propagateSentinels(sentinels);
        propagateGuardians(guardians);
    }

    /// @inheritdoc IGovernanceMessageEmitter
    function propagateGuardians(address[] calldata guardians) public {
        uint16 currentEpoch = IEpochsManager(epochsManager).currentEpoch();
        // uint16 totalNumberOfGuardians = IRegistrationManager(registrationManager).totalNumberOfGuardiansByEpoch(
        //     currentEpoch
        // );

        // uint16 numberOfValidGuardians;
        // for (uint16 index = 0; index < guardians; ) {
        //     IRegistrationManager.Registration memory registration = IRegistrationManager(registrationManager)
        //         .guardianRegistration(guardians[index]);

        //     if (registration.kind == 0x03 && currentEpoch >= registration.startEpoch && currentEpoch <= registration.endEpoch) {
        //         unchecked {
        //             ++numberOfValidGuardians;
        //         }
        //     }
        //     unchecked {
        //         ++index;
        //     }
        // }

        // if (totalNumberOfGuardians != numberOfValidGuardians) {
        //     revert InvalidNumberOfGuardians(numberOfValidGuardians, totalNumberOfGuardians);
        // }

        _sendMessage(
            abi.encode(
                GOVERNANCE_MESSAGE_GUARDIANS,
                abi.encode(currentEpoch, guardians.length, MerkleTree.getRoot(_hashAddresses(guardians)))
            )
        );

        emit GuardiansPropagated(currentEpoch, guardians);
    }

    /// @inheritdoc IGovernanceMessageEmitter
    function propagateSentinels(address[] calldata sentinels) public {
        uint16 currentEpoch = IEpochsManager(epochsManager).currentEpoch();
        address[] memory effectiveSentinels = _filterSentinels(sentinels, currentEpoch);

        _sendMessage(
            abi.encode(
                GOVERNANCE_MESSAGE_SENTINELS,
                abi.encode(
                    currentEpoch,
                    effectiveSentinels.length,
                    MerkleTree.getRoot(_hashAddresses(effectiveSentinels))
                )
            )
        );

        emit SentinelsPropagated(currentEpoch, effectiveSentinels);
    }

    /// @inheritdoc IGovernanceMessageEmitter
    function resumeGuardian(address guardian) external onlyRegistrationManager {
        _sendMessage(
            abi.encode(
                GOVERNANCE_MESSAGE_RESUME_GUARDIAN,
                abi.encode(IEpochsManager(epochsManager).currentEpoch(), guardian)
            )
        );
    }

    /// @inheritdoc IGovernanceMessageEmitter
    function resumeSentinel(address sentinel) external onlyRegistrationManager {
        _sendMessage(
            abi.encode(
                GOVERNANCE_MESSAGE_RESUME_SENTINEL,
                abi.encode(IEpochsManager(epochsManager).currentEpoch(), sentinel)
            )
        );
    }

    /// @inheritdoc IGovernanceMessageEmitter
    function slashGuardian(address guardian) external onlyRegistrationManager {
        _sendMessage(
            abi.encode(
                GOVERNANCE_MESSAGE_SLASH_GUARDIAN,
                abi.encode(IEpochsManager(epochsManager).currentEpoch(), guardian)
            )
        );
    }

    /// @inheritdoc IGovernanceMessageEmitter
    function slashSentinel(address sentinel) external onlyRegistrationManager {
        _sendMessage(
            abi.encode(
                GOVERNANCE_MESSAGE_SLASH_SENTINEL,
                abi.encode(IEpochsManager(epochsManager).currentEpoch(), sentinel)
            )
        );
    }

    function _sendMessage(bytes memory message) internal {
        address[] memory hubs = IPRegistry(registry).getSupportedHubs();
        uint32[] memory chainIds = IPRegistry(registry).getSupportedChainIds();

        emit GovernanceMessage(abi.encode(totalNumberOfMessages, chainIds, hubs, message));

        unchecked {
            ++totalNumberOfMessages;
        }
    }

    function _filterSentinels(
        address[] memory sentinels,
        uint16 currentEpoch
    ) internal view returns (address[] memory) {
        uint32 totalBorrowedAmount = ILendingManager(lendingManager).totalBorrowedAmountByEpoch(currentEpoch);
        uint256 totalSentinelStakedAmount = IRegistrationManager(registrationManager).totalSentinelStakedAmountByEpoch(
            currentEpoch
        );
        uint256 totalAmount = totalBorrowedAmount + totalSentinelStakedAmount;
        address[] memory effectiveSentinels = new address[](sentinels.length);
        uint256 cumulativeAmount = 0;

        // NOTE: be sure that totalSentinelStakedAmount + totalBorrowedAmount = cumulativeAmount.
        // There could be also sentinels that has less than 200k PNT because of slashing.
        // These sentinels will be filtered in the next step
        for (uint256 index; index < sentinels.length; ) {
            IRegistrationManager.Registration memory registration = IRegistrationManager(registrationManager)
                .sentinelRegistration(sentinels[index]);

            bytes1 registrationKind = registration.kind;
            if (registrationKind == 0x01) {
                // NOTE: no need to check startEpoch and endEpoch since we are using sentinelStakedAmountByEpochOf
                uint256 amount = IRegistrationManager(registrationManager).sentinelStakedAmountByEpochOf(
                    sentinels[index],
                    currentEpoch
                );
                cumulativeAmount += amount;

                effectiveSentinels[index] = amount >= 200000 ? sentinels[index] : address(0);
            } else if (
                registrationKind == 0x02 &&
                currentEpoch >= registration.startEpoch &&
                currentEpoch <= registration.endEpoch
            ) {
                cumulativeAmount += 200000;
                effectiveSentinels[index] = sentinels[index];
            } else {
                revert InvalidSentinelRegistration(registrationKind);
            }

            unchecked {
                ++index;
            }
        }

        if (totalAmount != cumulativeAmount) {
            revert InvalidAmount(totalAmount, cumulativeAmount);
        }

        return effectiveSentinels;
    }

    function _hashAddresses(address[] memory addresses) internal pure returns (bytes32[] memory) {
        bytes32[] memory data = new bytes32[](addresses.length);
        for (uint256 i = 0; i < addresses.length; i++) {
            data[i] = keccak256(abi.encodePacked(addresses[i]));
        }
        return data;
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Context} from "@openzeppelin/contracts/utils/Context.sol";
import {IGovernanceMessageHandler} from "../interfaces/IGovernanceMessageHandler.sol";
import {ITelepathyHandler} from "../interfaces/external/ITelepathyHandler.sol";

error NotRouter(address sender, address router);
error UnsupportedChainId(uint32 sourceChainId, uint32 expectedSourceChainId);
error InvalidGovernanceMessageVerifier(address governanceMessagerVerifier, address expectedGovernanceMessageVerifier);

abstract contract GovernanceMessageHandler is IGovernanceMessageHandler, Context {
    address public immutable telepathyRouter;
    address public immutable governanceMessageVerifier;
    uint32 public immutable expectedSourceChainId;

    constructor(address telepathyRouter_, address governanceMessageVerifier_, uint32 expectedSourceChainId_) {
        telepathyRouter = telepathyRouter_;
        governanceMessageVerifier = governanceMessageVerifier_;
        expectedSourceChainId = expectedSourceChainId_;
    }

    function handleTelepathy(uint32 sourceChainId, address sourceSender, bytes memory data) external returns (bytes4) {
        // address msgSender = _msgSender();
        // if (msgSender != telepathyRouter) revert NotRouter(msgSender, telepathyRouter);
        // NOTE: we just need to check the address that called the telepathy router (GovernanceMessageVerifier)
        // and not who emitted the event on Polygon since it's the GovernanceMessageVerifier that verifies that
        // a certain event has been emitted by the GovernanceMessageEmitter

        // if (sourceChainId != expectedSourceChainId) {
        //     revert UnsupportedChainId(sourceChainId, expectedSourceChainId);
        // }

        // if (sourceSender != governanceMessageVerifier) {
        //     revert InvalidGovernanceMessageVerifier(sourceSender, governanceMessageVerifier);
        // }

        _onGovernanceMessage(data);

        return ITelepathyHandler.handleTelepathy.selector;
    }

    function _onGovernanceMessage(bytes memory message) internal virtual {}
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {RLPReader} from "solidity-rlp/contracts/RLPReader.sol";
import {IGovernanceMessageVerifier} from "../interfaces/IGovernanceMessageVerifier.sol";
import {IRootChain} from "../interfaces/external/IRootChain.sol";
import {ITelepathyRouter} from "../interfaces/external/ITelepathyRouter.sol";
import {Merkle} from "../libraries/Merkle.sol";
import {MerklePatriciaProof} from "../libraries/MerklePatriciaProof.sol";

error InvalidGovernanceMessageEmitter(address governanceMessageEmitter, address expecteGovernanceMessageEmitter);
error InvalidTopic(bytes32 topic, bytes32 expectedTopic);
error InvalidReceiptsRootMerkleProof();
error InvalidRootHashMerkleProof();
error InvalidHeaderBlock();
error MessageAlreadyProcessed(IGovernanceMessageVerifier.GovernanceMessageProof proof);
error InvalidNonce(uint256 nonce, uint256 expectedNonce);

contract GovernanceMessageVerifier is IGovernanceMessageVerifier {
    address public constant TELEPATHY_ROUTER = 0x41EA857C32c8Cb42EEFa00AF67862eCFf4eB795a;
    address public constant ROOT_CHAIN_ADDRESS = 0x86E4Dc95c7FBdBf52e33D563BbDB00823894C287;
    bytes32 public constant EVENT_SIGNATURE_TOPIC = 0x85aab78efe4e39fd3b313a465f645990e6a1b923f5f5b979957c176e632c5a07; //keccak256(GovernanceMessage(bytes));

    address public immutable governanceMessageEmitter;

    uint256 public totalNumberOfProcessedMessages;
    mapping(bytes32 => bool) _messagesProcessed;

    constructor(address governanceMessageEmitter_) {
        governanceMessageEmitter = governanceMessageEmitter_;
    }

    /// @inheritdoc IGovernanceMessageVerifier
    function isProcessed(GovernanceMessageProof calldata proof) external view returns (bool) {
        return _messagesProcessed[proofIdOf(proof)];
    }

    /// @inheritdoc IGovernanceMessageVerifier
    function proofIdOf(GovernanceMessageProof calldata proof) public pure returns (bytes32) {
        return
            keccak256(
                abi.encode(
                    proof.rootHashProof,
                    proof.rootHashProofIndex,
                    proof.receiptsRoot,
                    proof.blockNumber,
                    proof.blockTimestamp,
                    proof.transactionsRoot,
                    proof.receiptsRootProofPath,
                    proof.receiptsRootProofParentNodes,
                    proof.receipt,
                    proof.logIndex,
                    proof.transactionType,
                    proof.headerBlock
                )
            );
    }

    /// @inheritdoc IGovernanceMessageVerifier
    function verifyAndPropagateMessage(GovernanceMessageProof calldata proof) external {
        bytes32 id = proofIdOf(proof);
        if (_messagesProcessed[id]) {
            revert MessageAlreadyProcessed(proof);
        }
        _messagesProcessed[id] = true;

        // NOTE: handle legacy and eip2718
        RLPReader.RLPItem[] memory receiptData = RLPReader.toList(
            RLPReader.toRlpItem(proof.transactionType == 2 ? proof.receipt[1:] : proof.receipt)
        );
        RLPReader.RLPItem[] memory logs = RLPReader.toList(receiptData[3]);
        RLPReader.RLPItem[] memory log = RLPReader.toList(logs[proof.logIndex]);

        // NOTE: only events emitted from the GovernanceMessageEmitter will be propagated
        address proofGovernanceMessageEmitter = RLPReader.toAddress(log[0]);
        if (governanceMessageEmitter != proofGovernanceMessageEmitter) {
            revert InvalidGovernanceMessageEmitter(proofGovernanceMessageEmitter, governanceMessageEmitter);
        }

        RLPReader.RLPItem[] memory topics = RLPReader.toList(log[1]);
        bytes32 proofTopic = bytes32(RLPReader.toBytes(topics[0]));
        if (EVENT_SIGNATURE_TOPIC != proofTopic) {
            revert InvalidTopic(proofTopic, EVENT_SIGNATURE_TOPIC);
        }

        if (
            !MerklePatriciaProof.verify(
                proof.receipt,
                proof.receiptsRootProofPath,
                proof.receiptsRootProofParentNodes,
                proof.receiptsRoot
            )
        ) {
            revert InvalidReceiptsRootMerkleProof();
        }

        bytes32 blockHash = keccak256(
            abi.encodePacked(proof.blockNumber, proof.blockTimestamp, proof.transactionsRoot, proof.receiptsRoot)
        );

        (bytes32 rootHash, , , , ) = IRootChain(ROOT_CHAIN_ADDRESS).headerBlocks(proof.headerBlock);
        if (rootHash == bytes32(0)) {
            revert InvalidHeaderBlock();
        }

        if (!Merkle.checkMembership(blockHash, proof.rootHashProofIndex, rootHash, proof.rootHashProof)) {
            revert InvalidRootHashMerkleProof();
        }

        bytes memory message = RLPReader.toBytes(log[2]);
        (uint256 nonce, uint32[] memory chainIds, address[] memory hubs, bytes memory data) = abi.decode(
            abi.decode(message, (bytes)),
            (uint256, uint32[], address[], bytes)
        );
        if (nonce != totalNumberOfProcessedMessages) {
            revert InvalidNonce(nonce, totalNumberOfProcessedMessages);
        }
        unchecked {
            ++totalNumberOfProcessedMessages;
        }

        for (uint256 index = 0; index < chainIds.length; ) {
            ITelepathyRouter(TELEPATHY_ROUTER).send(chainIds[index], hubs[index], data);

            unchecked {
                ++index;
            }
        }

        emit GovernanceMessagePropagated(data);
    }
}
pragma solidity ^0.8.19;

interface IRootChain {
    function headerBlocks(uint256 headerBlock) external view returns (bytes32, uint256, uint256, uint256, address);
}
pragma solidity ^0.8.19;

interface ITelepathyHandler {
    function handleTelepathy(uint32 sourceChainId, address sourceSender, bytes memory data) external returns (bytes4);
}
pragma solidity ^0.8.19;

interface ITelepathyRouter {
    function send(
        uint32 destinationChainId,
        address destinationAddress,
        bytes calldata data
    ) external returns (bytes32);
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

/**
 * @title IGovernanceMessageEmitter
 * @author pNetwork
 *
 * @notice
 */

interface IGovernanceMessageEmitter {
    /**
     * @dev Emitted when a governance message must be propagated on the other chains
     *
     * @param data The data
     */
    event GovernanceMessage(bytes data);

    /**
     * @dev Emitted when guardians are emitted.
     *
     * @param epoch The epoch
     * @param guardians The guardians
     */
    event GuardiansPropagated(uint16 indexed epoch, address[] guardians);

    /**
     * @dev Emitted when sentinels are emitted.
     *
     * @param epoch The epoch
     * @param sentinels The sentinels
     */
    event SentinelsPropagated(uint16 indexed epoch, address[] sentinels);

    /*
     * @notice Just call propagateGuardians and propagateSentinels
     *
     * @param sentinels
     * @param guardians
     */
    function propagateActors(address[] calldata sentinels, address[] calldata guardians) external;

    /*
     * @notice Emit a GovernanceMessage event containing the total number of guardians and
     *         the guardians merkle root for the current epoch. This message will be verified by GovernanceMessageVerifier.
     *
     * @param guardians
     */
    function propagateGuardians(address[] calldata guardians) external;

    /*
     * @notice Emit a GovernanceMessage event containing the total number of sentinels, the sentinels merkle root
     *      for the current epoch. This message will be verified by GovernanceMessageVerifier.
     *
     * @param sentinels
     * @param guardians
     */
    function propagateSentinels(address[] calldata sentinels) external;

    /*
     * @notice Emit a GovernanceMessage event containing the address of the resumed guardian
     *
     * @param guardian
     */
    function resumeGuardian(address guardian) external;

    /*
     * @notice Emit a GovernanceMessage event containing the address of the resumed sentinel
     *
     * @param guardian
     */
    function resumeSentinel(address sentinel) external;

    /*
     * @notice Emit a GovernanceMessage event containing the address of the slashed guardian
     *
     * @param guardian
     */
    function slashGuardian(address guardian) external;

    /*
     * @notice Emit a GovernanceMessage event containing the address of the slashed sentinel
     *
     * @param sentinel
     */
    function slashSentinel(address sentinel) external;
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {ITelepathyHandler} from "../interfaces/external/ITelepathyHandler.sol";

/**
 * @title IGovernanceMessageHandler
 * @author pNetwork
 *
 * @notice
 */

interface IGovernanceMessageHandler is ITelepathyHandler {

}
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

/**
 * @title IGovernanceMessageVerifier
 * @author pNetwork
 *
 * @notice
 */

interface IGovernanceMessageVerifier {
    struct GovernanceMessageProof {
        bytes rootHashProof;
        uint256 rootHashProofIndex;
        bytes32 receiptsRoot;
        uint256 blockNumber;
        uint256 blockTimestamp;
        bytes32 transactionsRoot;
        bytes receiptsRootProofPath;
        bytes receiptsRootProofParentNodes;
        bytes receipt;
        uint256 logIndex;
        uint8 transactionType;
        uint256 headerBlock;
    }

    /**
     * @dev Emitted when a governance message is propagated.
     *
     * @param data The governance message
     */
    event GovernanceMessagePropagated(bytes data);

    /*
     * @notice Returns if a message has been processed by providing the proof.
     *
     * @param proof
     *
     * @return bool indicating if the message has been processed or not.
     */
    function isProcessed(GovernanceMessageProof calldata proof) external view returns (bool);

    /*
     * @notice Returns the id of a message proof.
     *
     * @param proof
     *
     * @return bytes32 representing the id of a message proof.
     */
    function proofIdOf(GovernanceMessageProof calldata proof) external pure returns (bytes32);

    /*
     * @notice Verify that a certain event has been emitted on Polygon by the GovernanceMessageEmitter and propagate the message
     *
     * @param proof
     * @param destinationAddresses
     *
     */
    function verifyAndPropagateMessage(GovernanceMessageProof calldata proof) external;
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

/**
 * @title IPFactory
 * @author pNetwork
 *
 * @notice
 */
interface IPFactory {
    event PTokenDeployed(address pTokenAddress);

    function deploy(
        string memory underlyingAssetName,
        string memory underlyingAssetSymbol,
        uint256 underlyingAssetDecimals,
        address underlyingAssetTokenAddress,
        bytes4 underlyingAssetNetworkId
    ) external payable returns (address);

    function getBytecode(
        string memory underlyingAssetName,
        string memory underlyingAssetSymbol,
        uint256 underlyingAssetDecimals,
        address underlyingAssetTokenAddress,
        bytes4 underlyingAssetNetworkId
    ) external view returns (bytes memory);

    function getPTokenAddress(
        string memory underlyingAssetName,
        string memory underlyingAssetSymbol,
        uint256 underlyingAssetDecimals,
        address underlyingAssetTokenAddress,
        bytes4 underlyingAssetNetworkId
    ) external view returns (address);

    function setHub(address _hub) external;
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {IGovernanceMessageHandler} from "./IGovernanceMessageHandler.sol";

/**
 * @title IPNetworkHub
 * @author pNetwork
 *
 * @notice
 */
interface IPNetworkHub is IGovernanceMessageHandler {
    enum ActorTypes {
        Governance,
        Guardian,
        Sentinel
    }

    enum ActorStatus {
        Active,
        Challenged,
        Inactive
    }

    enum ChallengeStatus {
        Null,
        Pending,
        Solved,
        Unsolved,
        PartiallyUnsolved,
        Cancelled
    }

    enum OperationStatus {
        Null,
        Queued,
        Executed,
        Cancelled
    }

    struct Action {
        address actor;
        uint64 timestamp;
    }

    struct Challenge {
        uint256 nonce;
        address actor;
        address challenger;
        uint64 timestamp;
        bytes4 networkId;
    }

    struct Operation {
        bytes32 originBlockHash;
        bytes32 originTransactionHash;
        bytes32 optionsMask;
        uint256 nonce;
        uint256 underlyingAssetDecimals;
        uint256 assetAmount;
        uint256 protocolFeeAssetAmount;
        uint256 networkFeeAssetAmount;
        uint256 forwardNetworkFeeAssetAmount;
        address underlyingAssetTokenAddress;
        bytes4 originNetworkId;
        bytes4 destinationNetworkId;
        bytes4 forwardDestinationNetworkId;
        bytes4 underlyingAssetNetworkId;
        string originAccount;
        string destinationAccount;
        string underlyingAssetName;
        string underlyingAssetSymbol;
        bytes userData;
        bool isForProtocol;
    }

    /**
     * @dev Emitted when a challenge is cancelled.
     *
     * @param challenge The challenge
     */
    event ChallengeCancelled(Challenge challenge);

    /**
     * @dev Emitted when a challenger claims the lockedAmountStartChallenge by providing a challenge.
     *
     * @param challenge The challenge
     */
    event ChallengePartiallyUnsolved(Challenge challenge);

    /**
     * @dev Emitted when a challenge is started.
     *
     * @param challenge The challenge
     */
    event ChallengePending(Challenge challenge);

    /**
     * @dev Emitted when a challenge is solved.
     *
     * @param challenge The challenge
     */
    event ChallengeSolved(Challenge challenge);

    /**
     * @dev Emitted when a challenge is used to slash an actor.
     *
     * @param challenge The challenge
     */
    event ChallengeUnsolved(Challenge challenge);

    /**
     * @dev Emitted when an operation is queued.
     *
     * @param operation The queued operation
     */
    event OperationQueued(Operation operation);

    /**
     * @dev Emitted when an operation is executed.
     *
     * @param operation The executed operation
     */
    event OperationExecuted(Operation operation);

    /**
     * @dev Emitted when an operation is cancelled.
     *
     * @param operation The cancelled operation
     */
    event OperationCancelled(Operation operation);

    /**
     * @dev Emitted when the Governance instruct an cancel action on an operation.
     *
     * @param operation The cancelled operation
     */
    event GovernanceOperationCancelled(Operation operation);

    /**
     * @dev Emitted when a Guardian instruct an cancel action on an operation.
     *
     * @param operation The cancelled operation
     */
    event GuardianOperationCancelled(Operation operation);

    /**
     * @dev Emitted when a guardian is resumed after having being slashed
     *
     * @param epoch The epoch in which the guardian is has been resumed
     * @param guardian The resumed guardian
     */
    event GuardianResumed(uint16 indexed epoch, address indexed guardian);

    /**
     * @dev Emitted when a guardian has been slashed on the interim chain.
     *
     * @param epoch The epoch in which the sentinel has been slashed
     * @param guardian The slashed guardian
     */
    event GuardianSlashed(uint16 indexed epoch, address indexed guardian);

    /**
     * @dev Emitted when a Sentinel instruct an cancel action on an operation.
     *
     * @param operation The cancelled operation
     */
    event SentinelOperationCancelled(Operation operation);

    /**
     * @dev Emitted when a sentinel is resumed after having being slashed
     *
     * @param epoch The epoch in which the sentinel has been resumed
     * @param sentinel The resumed sentinel
     */
    event SentinelResumed(uint16 indexed epoch, address indexed sentinel);

    /**
     * @dev Emitted when a sentinel has been slashed on the interim chain.
     *
     * @param epoch The epoch in which the sentinel has been slashed
     * @param sentinel The slashed sentinel
     */
    event SentinelSlashed(uint16 indexed epoch, address indexed sentinel);

    /**
     * @dev Emitted when an user operation is generated.
     *
     * @param nonce The nonce
     * @param originAccount The account that triggered the user operation
     * @param destinationAccount The account to which the funds will be delivered
     * @param destinationNetworkId The destination network id
     * @param underlyingAssetName The name of the underlying asset
     * @param underlyingAssetSymbol The symbol of the underlying asset
     * @param underlyingAssetDecimals The number of decimals of the underlying asset
     * @param underlyingAssetTokenAddress The address of the underlying asset
     * @param underlyingAssetNetworkId The network id of the underlying asset
     * @param assetTokenAddress The asset token address
     * @param assetAmount The asset mount
     * @param protocolFeeAssetTokenAddress the protocol fee asset token address
     * @param protocolFeeAssetAmount the protocol fee asset amount
     * @param networkFeeAssetAmount the network fee asset amount
     * @param forwardNetworkFeeAssetAmount the forward network fee asset amount
     * @param forwardDestinationNetworkId the protocol fee network id
     * @param userData The user data
     * @param optionsMask The options
     */
    event UserOperation(
        uint256 nonce,
        string originAccount,
        string destinationAccount,
        bytes4 destinationNetworkId,
        string underlyingAssetName,
        string underlyingAssetSymbol,
        uint256 underlyingAssetDecimals,
        address underlyingAssetTokenAddress,
        bytes4 underlyingAssetNetworkId,
        address assetTokenAddress,
        uint256 assetAmount,
        address protocolFeeAssetTokenAddress,
        uint256 protocolFeeAssetAmount,
        uint256 networkFeeAssetAmount,
        uint256 forwardNetworkFeeAssetAmount,
        bytes4 forwardDestinationNetworkId,
        bytes userData,
        bytes32 optionsMask,
        bool isForProtocol
    );

    /*
     * @notice Get the PNetwork network ID where the contract is deployed.
     *
     * @return bytes32 4 bytes representing the network ID
     */
    function getNetworkId() external view returns (bytes4);

    /*
     * @notice Calculates the challenge id.
     *
     * @param challenge
     *
     * @return bytes32 representing the challenge id.
     */
    function challengeIdOf(Challenge memory challenge) external view returns (bytes32);

    /*
     * @notice Calculates the operation challenge period.
     *
     * @param operation
     *
     * @return (uint64, uin64) representing the start and end timestamp of an operation challenge period.
     */
    function challengePeriodOf(Operation calldata operation) external view returns (uint64, uint64);

    /*
     * @notice Offer the possibilty to claim the lockedAmountStartChallenge for a given challenge in a previous epoch in case it happens the following scenario:
     *          - A challenger initiates a challenge against a guardian/sentinel close to an epoch's end (within permissible limits).
     *          - The maxChallengeDuration elapses, disabling the sentinel from resolving the challenge within the currentEpoch.
     *          - The challenger fails to invoke slashByChallenge before the epoch terminates.
     *          - A new epoch initiates.
     *          - Result: lockedAmountStartChallenge STUCK.
     *
     * @param challenge
     *
     */
    function claimLockedAmountStartChallenge(Challenge calldata challenge) external;

    /*
     * @notice Return the epoch in which a challenge was started.
     *
     * @param challenge
     *
     * @return uint16 representing the epoch in which a challenge was started.
     */
    function getChallengeEpoch(Challenge calldata challenge) external view returns (uint16);

    /*
     * @notice Return the status of a challenge.
     *
     * @param challenge
     *
     * @return (ChallengeStatus) representing the challenge status
     */
    function getChallengeStatus(Challenge calldata challenge) external view returns (ChallengeStatus);

    /*
     * @notice Calculates the current active actors duration which is use to secure the system when few there are few active actors.
     *
     * @return uint64 representing the current active actors duration.
     */
    function getCurrentActiveActorsAdjustmentDuration() external view returns (uint64);

    /*
     * @notice Calculates the current challenge period duration considering the number of operations in queue and the total number of active actors.
     *
     * @return uint64 representing the current challenge period duration.
     */
    function getCurrentChallengePeriodDuration() external view returns (uint64);

    /*
     * @notice Calculates the adjustment duration based on the total number of operations in queue.
     *
     * @return uint64 representing the adjustment duration based on the total number of operations in queue.
     */
    function getCurrentQueuedOperationsAdjustmentDuration() external view returns (uint64);

    /*
     * @notice Returns the guardians merkle root for a given epoch.
     *
     * @param epoch
     *
     * @return bytes32 representing the guardians merkle root for a given epoch.
     */
    function getGuardiansMerkleRootForEpoch(uint16 epoch) external view returns (bytes32);

    /*
     * @notice Returns the pending challenge id for an actor in a given epoch.
     *
     * @param epoch
     * @param actor
     *
     * @return bytes32 representing the pending challenge id for an actor in a given epoch.
     */
    function getPendingChallengeIdByEpochOf(uint16 epoch, address actor) external view returns (bytes32);

    /*
     * @notice Returns the sentinels merkle root for a given epoch.
     *
     * @param epoch
     *
     * @return bytes32 representing the sentinels merkle root for a given epoch.
     */
    function getSentinelsMerkleRootForEpoch(uint16 epoch) external view returns (bytes32);

    /*
     * @notice Returns the number of inactive actors for the current epoch.
     *
     *
     * @return bytes32 representing the number of inactive actors for the current epoch.
     */
    function getTotalNumberOfInactiveActorsForCurrentEpoch() external view returns (uint16);

    /*
     * @notice Return the status of an operation.
     *
     * @param operation
     *
     * @return (OperationStatus) the operation status.
     */
    function operationStatusOf(Operation calldata operation) external view returns (OperationStatus);

    /*
     * @notice Calculates the operation id.
     *
     * @param operation
     *
     * @return (bytes32) the operation id.
     */
    function operationIdOf(Operation memory operation) external pure returns (bytes32);

    /*
     * @notice A Guardian instruct a cancel action. If 2 actors agree on it the operation is cancelled.
     *
     * @param operation
     * @param proof
     *
     */
    function protocolGuardianCancelOperation(Operation calldata operation, bytes32[] calldata proof) external;

    /*
     * @notice The Governance instruct a cancel action. If 2 actors agree on it the operation is cancelled.
     *
     * @param operation
     *
     */
    function protocolGovernanceCancelOperation(Operation calldata operation) external;

    /*
     * @notice A Sentinel instruct a cancel action. If 2 actors agree on it the operation is cancelled.
     *
     * @param operation
     * @param proof
     * @param signature
     *
     */
    function protocolSentinelCancelOperation(
        Operation calldata operation,
        bytes32[] calldata proof,
        bytes calldata signature
    ) external;

    /*
     * @notice Execute an operation that has been queued.
     *
     * @param operation
     *
     */
    function protocolExecuteOperation(Operation calldata operation) external payable;

    /*
     * @notice Queue an operation.
     *
     * @param operation
     *
     */
    function protocolQueueOperation(Operation calldata operation) external payable;

    /*
     * @notice Slash a sentinel of a guardians previously challenges if it was not able to solve the challenge in time.
     *
     * @param challenge
     *
     */
    function slashByChallenge(Challenge calldata challenge) external;

    /*
     * @notice Solve a challenge of a guardian and sends the bond (lockedAmountStartChallenge) to the DAO.
     *
     * @param challenge
     * @param proof
     *
     */
    function solveChallengeGuardian(Challenge calldata challenge, bytes32[] calldata proof) external;

    /*
     * @notice Solve a challenge of a sentinel and sends the bond (lockedAmountStartChallenge) to the DAO.
     *
     * @param challenge
     * @param proof
     * @param signature
     *
     */
    function solveChallengeSentinel(
        Challenge calldata challenge,
        bytes32[] calldata proof,
        bytes calldata signature
    ) external;

    /*
     * @notice Start a challenge for a guardian.
     *
     * @param guardian
     * @param proof
     *
     */
    function startChallengeGuardian(address guardian, bytes32[] memory proof) external payable;

    /*
     * @notice Start a challenge for a sentinel.
     *
     * @param sentinel
     * @param proof
     *
     */
    function startChallengeSentinel(address sentinel, bytes32[] memory proof) external payable;

    /*
     * @notice Generate an user operation which will be used by the relayers to be able
     *         to queue this operation on the destination network through the StateNetwork of that chain
     *
     * @param destinationAccount
     * @param destinationNetworkId
     * @param underlyingAssetName
     * @param underlyingAssetSymbol
     * @param underlyingAssetDecimals
     * @param underlyingAssetTokenAddress
     * @param underlyingAssetNetworkId
     * @param assetTokenAddress
     * @param assetAmount
     * @param protocolFeeAssetTokenAddress
     * @param protocolFeeAssetAmount
     * @param networkFeeAssetAmount
     * @param forwardNetworkFeeAssetAmount
     * @param userData
     * @param optionsMask
     */
    function userSend(
        string calldata destinationAccount,
        bytes4 destinationNetworkId,
        string calldata underlyingAssetName,
        string calldata underlyingAssetSymbol,
        uint256 underlyingAssetDecimals,
        address underlyingAssetTokenAddress,
        bytes4 underlyingAssetNetworkId,
        address assetTokenAddress,
        uint256 assetAmount,
        address protocolFeeAssetTokenAddress,
        uint256 protocolFeeAssetAmount,
        uint256 networkFeeAssetAmount,
        uint256 forwardNetworkFeeAssetAmount,
        bytes calldata userData,
        bytes32 optionsMask
    ) external;
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

/**
 * @title IPReceiver
 * @author pNetwork
 *
 * @notice
 */
interface IPReceiver {
    /*
     * @notice Function called when userData.length > 0 within PNetworkHub.protocolExecuteOperation.
     *
     * @param originNetworkId
     * @param originAccount
     * @param userData
     */
    function receiveUserData(bytes4 originNetworkId, string calldata originAccount, bytes calldata userData) external;
}
// SPDX-License-Identifier: MIT

/**
 * Created on 2023-09-15 14:48
 * @summary:
 * @author: mauro
 */
pragma solidity ^0.8.19;

interface IPRegistry {
    /*
     * @dev Add a new entry for the map network ID => hub
     *
     * @param networkId the network ID
     * @param hub pNetwork hub contract address
     */
    function addProtocolBlockchain(uint32 chainId, address hub) external;

    /*
     * @dev Return true if the given network id has been registered on pNetwork
     *
     * @param networkId the network ID
     *
     * @return bool true or false
     */
    function isNetworkIdSupported(bytes4 networkId) external view returns (bool);

    /**
     * @dev Return the supported chain ID
     * @param chainId the chain id
     */
    function isChainIdSupported(uint32 chainId) external view returns (bool);

    /**
     * @dev Return the supported hubs
     */
    function getSupportedHubs() external view returns (address[] memory);

    /**
     * @dev Return the supported chain IDs
     * @return uint32[] the array of supported chain ids
     */
    function getSupportedChainIds() external view returns (uint32[] memory);

    /**
     * @dev Returns the pNetwork hub address for the given network ID
     *
     * @param sourceNetworkId a network ID
     *
     * @return address pNetwork hub address on the given network ID
     */
    function getHubByNetworkId(bytes4 sourceNetworkId) external view returns (address);
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/**
 * @title IPToken
 * @author pNetwork
 *
 * @notice
 */
interface IPToken is IERC20 {
    /*
     * @notice Burn the corresponding `amount` of pToken and release the collateral.
     *
     * @param amount
     */
    function burn(uint256 amount) external;

    /*
     * @notice Take the collateral and mint the corresponding `amount` of pToken to `msg.sender`.
     *
     * @param amount
     */
    function mint(uint256 amount) external;

    /*
     * @notice Mint the corresponding `amount` of pToken through the PNetworkHub to `account`.
     *
     * @param account
     * @param amount
     */
    function protocolMint(address account, uint256 amount) external;

    /*
     * @notice Burn the corresponding `amount` of pToken through the PNetworkHub to `account` and release the collateral.
     *
     * @param account
     * @param amount
     */
    function protocolBurn(address account, uint256 amount) external;

    /*
     * @notice Take the collateral and mint the corresponding `amount` of pToken through the PRouter to `account`.
     *
     * @param account
     * @param amount
     */
    function userMint(address account, uint256 amount) external;

    /*
     * @notice Take the collateral, mint and burn the corresponding `amount` of pToken through the PRouter to `account`.
     *
     * @param account
     * @param amount
     */
    function userMintAndBurn(address account, uint256 amount) external;

    /*
     * @notice Burn the corresponding `amount` of pToken through the PRouter in behalf of `account` and release the.
     *
     * @param account
     * @param amount
     */
    function userBurn(address account, uint256 amount) external;
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {IPReceiver} from "./IPReceiver.sol";

interface ISlasher is IPReceiver {}
// taken here: https://github.com/maticnetwork/contracts/blob/main/contracts/common/lib/Merkle.sol
pragma solidity ^0.8.19;

library Merkle {
    function checkMembership(
        bytes32 leaf,
        uint256 index,
        bytes32 rootHash,
        bytes memory proof
    ) internal pure returns (bool) {
        require(proof.length % 32 == 0, "Invalid proof length");
        uint256 proofHeight = proof.length / 32;
        // Proof of size n means, height of the tree is n+1.
        // In a tree of height n+1, max #leafs possible is 2 ^ n
        require(index < 2 ** proofHeight, "Leaf index is too big");

        bytes32 proofElement;
        bytes32 computedHash = leaf;
        for (uint256 i = 32; i <= proof.length; i += 32) {
            assembly {
                proofElement := mload(add(proof, i))
            }

            if (index % 2 == 0) {
                computedHash = keccak256(abi.encodePacked(computedHash, proofElement));
            } else {
                computedHash = keccak256(abi.encodePacked(proofElement, computedHash));
            }

            index = index / 2;
        }
        return computedHash == rootHash;
    }
}
// taken here: https://github.com/maticnetwork/contracts/blob/main/contracts/common/lib/MerklePatriciaProof.sol

/*
 * @title MerklePatriciaVerifier
 * @author Sam Mayo (sammayo888@gmail.com)
 *
 * @dev Library for verifing merkle patricia proofs.
 */
pragma solidity ^0.8.19;

import {RLPReader} from "solidity-rlp/contracts/RLPReader.sol";

library MerklePatriciaProof {
    /*
     * @dev Verifies a merkle patricia proof.
     * @param value The terminating value in the trie.
     * @param encodedPath The path in the trie leading to value.
     * @param rlpParentNodes The rlp encoded stack of nodes.
     * @param root The root hash of the trie.
     * @return The boolean validity of the proof.
     */
    function verify(
        bytes memory value,
        bytes memory encodedPath,
        bytes memory rlpParentNodes,
        bytes32 root
    ) internal pure returns (bool) {
        RLPReader.RLPItem memory item = RLPReader.toRlpItem(rlpParentNodes);
        RLPReader.RLPItem[] memory parentNodes = RLPReader.toList(item);

        bytes memory currentNode;
        RLPReader.RLPItem[] memory currentNodeList;

        bytes32 nodeKey = root;
        uint256 pathPtr = 0;

        bytes memory path = _getNibbleArray(encodedPath);
        if (path.length == 0) {
            return false;
        }

        for (uint256 i = 0; i < parentNodes.length; i++) {
            if (pathPtr > path.length) {
                return false;
            }

            currentNode = RLPReader.toRlpBytes(parentNodes[i]);
            if (nodeKey != keccak256(currentNode)) {
                return false;
            }
            currentNodeList = RLPReader.toList(parentNodes[i]);

            if (currentNodeList.length == 17) {
                if (pathPtr == path.length) {
                    if (keccak256(RLPReader.toBytes(currentNodeList[16])) == keccak256(value)) {
                        return true;
                    } else {
                        return false;
                    }
                }

                uint8 nextPathNibble = uint8(path[pathPtr]);
                if (nextPathNibble > 16) {
                    return false;
                }

                nodeKey = bytes32(RLPReader.toUintStrict(currentNodeList[nextPathNibble]));
                pathPtr += 1;
            } else if (currentNodeList.length == 2) {
                uint256 traversed = _nibblesToTraverse(RLPReader.toBytes(currentNodeList[0]), path, pathPtr);
                if (pathPtr + traversed == path.length) {
                    //leaf node
                    if (keccak256(RLPReader.toBytes(currentNodeList[1])) == keccak256(value)) {
                        return true;
                    } else {
                        return false;
                    }
                }

                //extension node
                if (traversed == 0) {
                    return false;
                }

                pathPtr += traversed;
                nodeKey = bytes32(RLPReader.toUintStrict(currentNodeList[1]));
            } else {
                return false;
            }
        }
    }

    function _nibblesToTraverse(
        bytes memory encodedPartialPath,
        bytes memory path,
        uint256 pathPtr
    ) private pure returns (uint256) {
        uint256 len;
        // encodedPartialPath has elements that are each two hex characters (1 byte), but partialPath
        // and slicedPath have elements that are each one hex character (1 nibble)
        bytes memory partialPath = _getNibbleArray(encodedPartialPath);
        bytes memory slicedPath = new bytes(partialPath.length);

        // pathPtr counts nibbles in path
        // partialPath.length is a number of nibbles
        for (uint256 i = pathPtr; i < pathPtr + partialPath.length; i++) {
            bytes1 pathNibble = path[i];
            slicedPath[i - pathPtr] = pathNibble;
        }

        if (keccak256(partialPath) == keccak256(slicedPath)) {
            len = partialPath.length;
        } else {
            len = 0;
        }
        return len;
    }

    // bytes b must be hp encoded
    function _getNibbleArray(bytes memory b) private pure returns (bytes memory) {
        bytes memory nibbles;
        if (b.length > 0) {
            uint8 offset;
            uint8 hpNibble = uint8(_getNthNibbleOfBytes(0, b));
            if (hpNibble == 1 || hpNibble == 3) {
                nibbles = new bytes(b.length * 2 - 1);
                bytes1 oddNibble = _getNthNibbleOfBytes(1, b);
                nibbles[0] = oddNibble;
                offset = 1;
            } else {
                nibbles = new bytes(b.length * 2 - 2);
                offset = 0;
            }

            for (uint256 i = offset; i < nibbles.length; i++) {
                nibbles[i] = _getNthNibbleOfBytes(i - offset + 2, b);
            }
        }
        return nibbles;
    }

    function _getNthNibbleOfBytes(uint256 n, bytes memory str) private pure returns (bytes1) {
        return bytes1(n % 2 == 0 ? uint8(str[n / 2]) / 0x10 : uint8(str[n / 2]) % 0x10);
    }
}
pragma solidity ^0.8.19;

import {Math} from "@openzeppelin/contracts/utils/math/Math.sol";

library MerkleTree {
    function getRoot(bytes32[] memory data) internal pure returns (bytes32) {
        uint256 n = data.length;

        if (n == 1) {
            return data[0];
        }

        uint256 j = 0;
        uint256 layer = 0;
        uint256 leaves = Math.log2(n) + 1;
        bytes32[][] memory nodes = new bytes32[][](leaves * (2 * n - 1));

        for (uint256 l = 0; l <= leaves; ) {
            nodes[l] = new bytes32[](2 * n - 1);
            unchecked {
                ++l;
            }
        }

        for (uint256 i = 0; i < data.length; ) {
            nodes[layer][j] = data[i];
            unchecked {
                ++j;
                ++i;
            }
        }

        while (n > 1) {
            uint256 layerNodes = 0;
            uint k = 0;

            for (uint256 i = 0; i < n; i += 2) {
                if (i + 1 == n) {
                    if (n % 2 == 1) {
                        nodes[layer + 1][k] = nodes[layer][n - 1];
                        unchecked {
                            ++j;
                            ++layerNodes;
                        }
                        continue;
                    }
                }

                nodes[layer + 1][k] = _hashPair(nodes[layer][i], nodes[layer][i + 1]);

                unchecked {
                    ++k;
                    layerNodes += 2;
                }
            }

            n = (n / 2) + (layerNodes % 2 == 0 ? 0 : 1);
            unchecked {
                ++layer;
            }
        }

        return nodes[layer][0];
    }

    function _hashPair(bytes32 a, bytes32 b) internal pure returns (bytes32) {
        return a < b ? _efficientHash(a, b) : _efficientHash(b, a);
    }

    function _efficientHash(bytes32 a, bytes32 b) internal pure returns (bytes32 value) {
        assembly {
            mstore(0x00, a)
            mstore(0x20, b)
            value := keccak256(0x00, 0x40)
        }
    }
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

library Network {
    function isCurrentNetwork(bytes4 networkId) internal view returns (bool) {
        return Network.getCurrentNetworkId() == networkId;
    }

    function getNetworkIdFromChainId(uint32 chainId) internal pure returns (bytes4) {
        bytes1 version = 0x01;
        bytes1 networkType = 0x01;
        bytes1 extraData = 0x00;
        return bytes4(sha256(abi.encode(version, networkType, chainId, extraData)));
    }

    function getCurrentNetworkId() internal view returns (bytes4) {
        return getNetworkIdFromChainId(uint32(block.chainid));
    }
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

library Roles {
    bytes32 public constant UPGRADE_ROLE = keccak256("UPGRADE_ROLE");
    bytes32 public constant MINT_ROLE = keccak256("MINT_ROLE");
    bytes32 public constant BURN_ROLE = keccak256("BURN_ROLE");
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";

library Utils {
    function isBitSet(bytes32 data, uint position) internal pure returns (bool) {
        return (uint256(data) & (uint256(1) << position)) != 0;
    }

    function normalizeAmount(uint256 amount, uint256 decimals, bool use) internal pure returns (uint256) {
        uint256 difference = (10 ** (18 - decimals));
        return use ? amount * difference : amount / difference;
    }

    function addressToHexString(address addr) internal pure returns (string memory) {
        return Strings.toHexString(uint256(uint160(addr)), 20);
    }

    function hexStringToAddress(string memory addr) internal pure returns (address) {
        bytes memory tmp = bytes(addr);
        uint160 iaddr = 0;
        uint160 b1;
        uint160 b2;
        for (uint i = 2; i < 2 + 2 * 20; i += 2) {
            iaddr *= 256;
            b1 = uint160(uint8(tmp[i]));
            b2 = uint160(uint8(tmp[i + 1]));
            if ((b1 >= 97) && (b1 <= 102)) {
                b1 -= 87;
            } else if ((b1 >= 65) && (b1 <= 70)) {
                b1 -= 55;
            } else if ((b1 >= 48) && (b1 <= 57)) {
                b1 -= 48;
            }
            if ((b2 >= 97) && (b2 <= 102)) {
                b2 -= 87;
            } else if ((b2 >= 65) && (b2 <= 70)) {
                b2 -= 55;
            } else if ((b2 >= 48) && (b2 <= 57)) {
                b2 -= 48;
            }
            iaddr += (b1 * 16 + b2);
        }
        return address(iaddr);
    }
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {IPReceiver} from "../interfaces/IPReceiver.sol";

abstract contract PReceiver is IPReceiver {
    /// @inheritdoc IPReceiver
    function receiveUserData(
        bytes4 originNetworkId,
        string calldata originAccount,
        bytes calldata userData
    ) external virtual {}
}
// SPDX-License-Identifier: Unlicense

pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@pnetwork-association/dao-v2-contracts/contracts/core/RegistrationManager.sol";

contract Imports {}
// SPDX-License-Identifier: Unlicense

pragma solidity ^0.8.19;

contract MockFeesManager {
    event FeeDeposited(address asset, uint256 amount);

    function depositFee(address asset, uint256 amount) external {
        emit FeeDeposited(asset, amount);
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {IEpochsManager} from "@pnetwork-association/dao-v2-contracts/contracts/interfaces/IEpochsManager.sol";
import {MerkleTree} from "../libraries/MerkleTree.sol";

contract MockGovernanceMessageEmitter {
    bytes32 public constant GOVERNANCE_MESSAGE_SENTINELS = keccak256("GOVERNANCE_MESSAGE_SENTINELS");
    bytes32 public constant GOVERNANCE_MESSAGE_GUARDIANS = keccak256("GOVERNANCE_MESSAGE_GUARDIANS");
    bytes32 public constant GOVERNANCE_MESSAGE_SLASH_SENTINEL = keccak256("GOVERNANCE_MESSAGE_SLASH_SENTINEL");
    bytes32 public constant GOVERNANCE_MESSAGE_SLASH_GUARDIAN = keccak256("GOVERNANCE_MESSAGE_SLASH_GUARDIAN");
    bytes32 public constant GOVERNANCE_MESSAGE_RESUME_SENTINEL = keccak256("GOVERNANCE_MESSAGE_RESUME_SENTINEL");
    bytes32 public constant GOVERNANCE_MESSAGE_RESUME_GUARDIAN = keccak256("GOVERNANCE_MESSAGE_RESUME_GUARDIAN");

    address public immutable epochsManager;

    event GovernanceMessage(bytes data);

    constructor(address epochsManager_) {
        epochsManager = epochsManager_;
    }

    function resumeGuardian(address guardian) external {
        emit GovernanceMessage(
            abi.encode(
                GOVERNANCE_MESSAGE_RESUME_GUARDIAN,
                abi.encode(IEpochsManager(epochsManager).currentEpoch(), guardian)
            )
        );
    }

    function resumeSentinel(address sentinel) external {
        emit GovernanceMessage(
            abi.encode(
                GOVERNANCE_MESSAGE_RESUME_SENTINEL,
                abi.encode(IEpochsManager(epochsManager).currentEpoch(), sentinel)
            )
        );
    }

    function slashGuardian(address guardian) external {
        emit GovernanceMessage(
            abi.encode(
                GOVERNANCE_MESSAGE_SLASH_GUARDIAN,
                abi.encode(IEpochsManager(epochsManager).currentEpoch(), guardian)
            )
        );
    }

    function slashSentinel(address sentinel) external {
        emit GovernanceMessage(
            abi.encode(
                GOVERNANCE_MESSAGE_SLASH_SENTINEL,
                abi.encode(IEpochsManager(epochsManager).currentEpoch(), sentinel)
            )
        );
    }

    function propagateActors(uint16 epoch, address[] calldata sentinels, address[] calldata guardians) external {
        emit GovernanceMessage(
            abi.encode(
                GOVERNANCE_MESSAGE_SENTINELS,
                abi.encode(epoch, sentinels.length, MerkleTree.getRoot(_hashAddresses(sentinels)))
            )
        );

        emit GovernanceMessage(
            abi.encode(
                GOVERNANCE_MESSAGE_GUARDIANS,
                abi.encode(epoch, guardians.length, MerkleTree.getRoot(_hashAddresses(guardians)))
            )
        );
    }

    function _hashAddresses(address[] memory addresses) internal pure returns (bytes32[] memory) {
        bytes32[] memory data = new bytes32[](addresses.length);
        for (uint256 i = 0; i < addresses.length; i++) {
            data[i] = keccak256(abi.encodePacked(addresses[i]));
        }
        return data;
    }
}
// SPDX-License-Identifier: Unlicense

pragma solidity ^0.8.19;

contract MockLendingManager {
    mapping(uint16 => uint24) private _epochsTotalBorrowedAmount;

    constructor() {}

    function totalBorrowedAmountByEpoch(uint16 epoch) external view returns (uint24) {
        return _epochsTotalBorrowedAmount[epoch];
    }

    function increaseTotalBorrowedAmountByEpoch(uint24 amount, uint16 epoch) external {
        _epochsTotalBorrowedAmount[epoch] += amount;
    }
}
// SPDX-License-Identifier: Unlicense

pragma solidity ^0.8.19;

import {IGovernanceMessageEmitter} from "../interfaces/IGovernanceMessageEmitter.sol";

interface IMockLendingManager {
    function increaseTotalBorrowedAmountByEpoch(uint24 amount, uint16 epoch) external;
}

contract MockRegistrationManager {
    struct Registration {
        address owner;
        uint16 startEpoch;
        uint16 endEpoch;
        bytes1 kind;
    }

    event StakingSentinelSlashed(address indexed sentinel, uint256 amount);

    address public immutable lendingManager;

    address public governanceMessageEmitter;

    constructor(address lendingManager_) {
        lendingManager = lendingManager_;
    }

    mapping(address => Registration) private _sentinelRegistrations;
    mapping(uint16 => uint24) private _sentinelsEpochsTotalStakedAmount;
    mapping(address => mapping(uint16 => uint24)) private _sentinelsEpochsStakedAmount;

    function sentinelRegistration(address sentinel) external view returns (Registration memory) {
        return _sentinelRegistrations[sentinel];
    }

    function sentinelStakedAmountByEpochOf(address sentinel, uint16 epoch) external view returns (uint24) {
        return _sentinelsEpochsStakedAmount[sentinel][epoch];
    }

    function totalSentinelStakedAmountByEpoch(uint16 epoch) external view returns (uint24) {
        return _sentinelsEpochsTotalStakedAmount[epoch];
    }

    function addStakingSentinel(
        address sentinel,
        address owner,
        uint16 startEpoch,
        uint16 endEpoch,
        uint24 amount
    ) external {
        _sentinelRegistrations[sentinel] = Registration({
            owner: owner,
            startEpoch: startEpoch,
            endEpoch: endEpoch,
            kind: 0x01
        });

        for (uint16 epoch = startEpoch; epoch <= endEpoch; epoch++) {
            _sentinelsEpochsTotalStakedAmount[epoch] += amount;
            _sentinelsEpochsStakedAmount[sentinel][epoch] += amount;
        }
    }

    function addBorrowingSentinel(address sentinel, address owner, uint16 startEpoch, uint16 endEpoch) external {
        _sentinelRegistrations[sentinel] = Registration({
            owner: owner,
            startEpoch: startEpoch,
            endEpoch: endEpoch,
            kind: 0x02
        });
        for (uint16 epoch = startEpoch; epoch <= endEpoch; epoch++) {
            IMockLendingManager(lendingManager).increaseTotalBorrowedAmountByEpoch(200000, epoch);
        }
    }

    function setGovernanceMessageEmitter(address governanceMessageEmitter_) external {
        governanceMessageEmitter = governanceMessageEmitter_;
    }

    function slash(address actor, uint256 amount, address challenger) external {
        IGovernanceMessageEmitter(governanceMessageEmitter).slashSentinel(actor);
        emit StakingSentinelSlashed(actor, amount);
    }
}
// SPDX-License-Identifier: Unlicense

pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract StandardToken is ERC20 {
    uint8 _decimals;

    constructor(string memory name, string memory symbol, uint8 decimals, uint256 totalSupply) ERC20(name, symbol) {
        _mint(_msgSender(), totalSupply);
        _decimals = decimals;
    }

    function decimals() public view override returns (uint8) {
        return _decimals;
    }
}
// SPDX-License-Identifier: Unlicense

pragma solidity ^0.8.19;

contract TestNotReceiver {}
// SPDX-License-Identifier: Unlicense

pragma solidity ^0.8.19;

import {PReceiver} from "../receiver/PReceiver.sol";

contract TestReceiver is PReceiver {
    event UserDataReceived(bytes4 originNetworkId, string originAccount, bytes userData);

    function receiveUserData(
        bytes4 originNetworkId,
        string calldata originAccount,
        bytes calldata userData
    ) external override {
        emit UserDataReceived(originNetworkId, originAccount, userData);
    }
}
// SPDX-License-Identifier: Apache-2.0

/*
 * @author Hamdi Allam hamdi.allam97@gmail.com
 * Please reach out with any questions or concerns
 */
pragma solidity >=0.5.10 <0.9.0;

library RLPReader {
    uint8 constant STRING_SHORT_START = 0x80;
    uint8 constant STRING_LONG_START = 0xb8;
    uint8 constant LIST_SHORT_START = 0xc0;
    uint8 constant LIST_LONG_START = 0xf8;
    uint8 constant WORD_SIZE = 32;

    struct RLPItem {
        uint256 len;
        uint256 memPtr;
    }

    struct Iterator {
        RLPItem item; // Item that's being iterated over.
        uint256 nextPtr; // Position of the next item in the list.
    }

    /*
     * @dev Returns the next element in the iteration. Reverts if it has not next element.
     * @param self The iterator.
     * @return The next element in the iteration.
     */
    function next(Iterator memory self) internal pure returns (RLPItem memory) {
        require(hasNext(self));

        uint256 ptr = self.nextPtr;
        uint256 itemLength = _itemLength(ptr);
        self.nextPtr = ptr + itemLength;

        return RLPItem(itemLength, ptr);
    }

    /*
     * @dev Returns true if the iteration has more elements.
     * @param self The iterator.
     * @return true if the iteration has more elements.
     */
    function hasNext(Iterator memory self) internal pure returns (bool) {
        RLPItem memory item = self.item;
        return self.nextPtr < item.memPtr + item.len;
    }

    /*
     * @param item RLP encoded bytes
     */
    function toRlpItem(bytes memory item) internal pure returns (RLPItem memory) {
        uint256 memPtr;
        assembly {
            memPtr := add(item, 0x20)
        }

        return RLPItem(item.length, memPtr);
    }

    /*
     * @dev Create an iterator. Reverts if item is not a list.
     * @param self The RLP item.
     * @return An 'Iterator' over the item.
     */
    function iterator(RLPItem memory self) internal pure returns (Iterator memory) {
        require(isList(self));

        uint256 ptr = self.memPtr + _payloadOffset(self.memPtr);
        return Iterator(self, ptr);
    }

    /*
     * @param the RLP item.
     */
    function rlpLen(RLPItem memory item) internal pure returns (uint256) {
        return item.len;
    }

    /*
     * @param the RLP item.
     * @return (memPtr, len) pair: location of the item's payload in memory.
     */
    function payloadLocation(RLPItem memory item) internal pure returns (uint256, uint256) {
        uint256 offset = _payloadOffset(item.memPtr);
        uint256 memPtr = item.memPtr + offset;
        uint256 len = item.len - offset; // data length
        return (memPtr, len);
    }

    /*
     * @param the RLP item.
     */
    function payloadLen(RLPItem memory item) internal pure returns (uint256) {
        (, uint256 len) = payloadLocation(item);
        return len;
    }

    /*
     * @param the RLP item containing the encoded list.
     */
    function toList(RLPItem memory item) internal pure returns (RLPItem[] memory) {
        require(isList(item));

        uint256 items = numItems(item);
        RLPItem[] memory result = new RLPItem[](items);

        uint256 memPtr = item.memPtr + _payloadOffset(item.memPtr);
        uint256 dataLen;
        for (uint256 i = 0; i < items; i++) {
            dataLen = _itemLength(memPtr);
            result[i] = RLPItem(dataLen, memPtr);
            memPtr = memPtr + dataLen;
        }

        return result;
    }

    // @return indicator whether encoded payload is a list. negate this function call for isData.
    function isList(RLPItem memory item) internal pure returns (bool) {
        if (item.len == 0) return false;

        uint8 byte0;
        uint256 memPtr = item.memPtr;
        assembly {
            byte0 := byte(0, mload(memPtr))
        }

        if (byte0 < LIST_SHORT_START) return false;
        return true;
    }

    /*
     * @dev A cheaper version of keccak256(toRlpBytes(item)) that avoids copying memory.
     * @return keccak256 hash of RLP encoded bytes.
     */
    function rlpBytesKeccak256(RLPItem memory item) internal pure returns (bytes32) {
        uint256 ptr = item.memPtr;
        uint256 len = item.len;
        bytes32 result;
        assembly {
            result := keccak256(ptr, len)
        }
        return result;
    }

    /*
     * @dev A cheaper version of keccak256(toBytes(item)) that avoids copying memory.
     * @return keccak256 hash of the item payload.
     */
    function payloadKeccak256(RLPItem memory item) internal pure returns (bytes32) {
        (uint256 memPtr, uint256 len) = payloadLocation(item);
        bytes32 result;
        assembly {
            result := keccak256(memPtr, len)
        }
        return result;
    }

    /** RLPItem conversions into data types **/

    // @returns raw rlp encoding in bytes
    function toRlpBytes(RLPItem memory item) internal pure returns (bytes memory) {
        bytes memory result = new bytes(item.len);
        if (result.length == 0) return result;

        uint256 ptr;
        assembly {
            ptr := add(0x20, result)
        }

        copy(item.memPtr, ptr, item.len);
        return result;
    }

    // any non-zero byte except "0x80" is considered true
    function toBoolean(RLPItem memory item) internal pure returns (bool) {
        require(item.len == 1);
        uint256 result;
        uint256 memPtr = item.memPtr;
        assembly {
            result := byte(0, mload(memPtr))
        }

        // SEE Github Issue #5.
        // Summary: Most commonly used RLP libraries (i.e Geth) will encode
        // "0" as "0x80" instead of as "0". We handle this edge case explicitly
        // here.
        if (result == 0 || result == STRING_SHORT_START) {
            return false;
        } else {
            return true;
        }
    }

    function toAddress(RLPItem memory item) internal pure returns (address) {
        // 1 byte for the length prefix
        require(item.len == 21);

        return address(uint160(toUint(item)));
    }

    function toUint(RLPItem memory item) internal pure returns (uint256) {
        require(item.len > 0 && item.len <= 33);

        (uint256 memPtr, uint256 len) = payloadLocation(item);

        uint256 result;
        assembly {
            result := mload(memPtr)

            // shift to the correct location if neccesary
            if lt(len, 32) {
                result := div(result, exp(256, sub(32, len)))
            }
        }

        return result;
    }

    // enforces 32 byte length
    function toUintStrict(RLPItem memory item) internal pure returns (uint256) {
        // one byte prefix
        require(item.len == 33);

        uint256 result;
        uint256 memPtr = item.memPtr + 1;
        assembly {
            result := mload(memPtr)
        }

        return result;
    }

    function toBytes(RLPItem memory item) internal pure returns (bytes memory) {
        require(item.len > 0);

        (uint256 memPtr, uint256 len) = payloadLocation(item);
        bytes memory result = new bytes(len);

        uint256 destPtr;
        assembly {
            destPtr := add(0x20, result)
        }

        copy(memPtr, destPtr, len);
        return result;
    }

    /*
     * Private Helpers
     */

    // @return number of payload items inside an encoded list.
    function numItems(RLPItem memory item) private pure returns (uint256) {
        if (item.len == 0) return 0;

        uint256 count = 0;
        uint256 currPtr = item.memPtr + _payloadOffset(item.memPtr);
        uint256 endPtr = item.memPtr + item.len;
        while (currPtr < endPtr) {
            currPtr = currPtr + _itemLength(currPtr); // skip over an item
            count++;
        }

        return count;
    }

    // @return entire rlp item byte length
    function _itemLength(uint256 memPtr) private pure returns (uint256) {
        uint256 itemLen;
        uint256 byte0;
        assembly {
            byte0 := byte(0, mload(memPtr))
        }

        if (byte0 < STRING_SHORT_START) {
            itemLen = 1;
        } else if (byte0 < STRING_LONG_START) {
            itemLen = byte0 - STRING_SHORT_START + 1;
        } else if (byte0 < LIST_SHORT_START) {
            assembly {
                let byteLen := sub(byte0, 0xb7) // # of bytes the actual length is
                memPtr := add(memPtr, 1) // skip over the first byte

                /* 32 byte word size */
                let dataLen := div(mload(memPtr), exp(256, sub(32, byteLen))) // right shifting to get the len
                itemLen := add(dataLen, add(byteLen, 1))
            }
        } else if (byte0 < LIST_LONG_START) {
            itemLen = byte0 - LIST_SHORT_START + 1;
        } else {
            assembly {
                let byteLen := sub(byte0, 0xf7)
                memPtr := add(memPtr, 1)

                let dataLen := div(mload(memPtr), exp(256, sub(32, byteLen))) // right shifting to the correct length
                itemLen := add(dataLen, add(byteLen, 1))
            }
        }

        return itemLen;
    }

    // @return number of bytes until the data
    function _payloadOffset(uint256 memPtr) private pure returns (uint256) {
        uint256 byte0;
        assembly {
            byte0 := byte(0, mload(memPtr))
        }

        if (byte0 < STRING_SHORT_START) {
            return 0;
        } else if (byte0 < STRING_LONG_START || (byte0 >= LIST_SHORT_START && byte0 < LIST_LONG_START)) {
            return 1;
        } else if (byte0 < LIST_SHORT_START) {
            // being explicit
            return byte0 - (STRING_LONG_START - 1) + 1;
        } else {
            return byte0 - (LIST_LONG_START - 1) + 1;
        }
    }

    /*
     * @param src Pointer to source
     * @param dest Pointer to destination
     * @param len Amount of memory to copy from the source
     */
    function copy(uint256 src, uint256 dest, uint256 len) private pure {
        if (len == 0) return;

        // copy as many word sizes as possible
        for (; len >= WORD_SIZE; len -= WORD_SIZE) {
            assembly {
                mstore(dest, mload(src))
            }

            src += WORD_SIZE;
            dest += WORD_SIZE;
        }

        if (len > 0) {
            // left over bytes. Mask is used to remove unwanted bytes from the word
            uint256 mask = 256**(WORD_SIZE - len) - 1;
            assembly {
                let srcpart := and(mload(src), not(mask)) // zero out src
                let destpart := and(mload(dest), mask) // retrieve the bytes
                mstore(dest, or(destpart, srcpart))
            }
        }
    }
}
