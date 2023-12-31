// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract AutomationBase {
  error OnlySimulatedBackend();

  /**
   * @notice method that allows it to be simulated via eth_call by checking that
   * the sender is the zero address.
   */
  function preventExecution() internal view {
    if (tx.origin != address(0)) {
      revert OnlySimulatedBackend();
    }
  }

  /**
   * @notice modifier that allows it to be simulated via eth_call by checking
   * that the sender is the zero address.
   */
  modifier cannotExecute() {
    preventExecution();
    _;
  }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./AutomationBase.sol";
import "./interfaces/AutomationCompatibleInterface.sol";

abstract contract AutomationCompatible is AutomationBase, AutomationCompatibleInterface {}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface AutomationCompatibleInterface {
  /**
   * @notice method that is simulated by the keepers to see if any work actually
   * needs to be performed. This method does does not actually need to be
   * executable, and since it is only ever simulated it can consume lots of gas.
   * @dev To ensure that it is never called, you may want to add the
   * cannotExecute modifier from KeeperBase to your implementation of this
   * method.
   * @param checkData specified in the upkeep registration so it is always the
   * same for a registered upkeep. This can easily be broken down into specific
   * arguments using `abi.decode`, so multiple upkeeps can be registered on the
   * same contract and easily differentiated by the contract.
   * @return upkeepNeeded boolean to indicate whether the keeper should call
   * performUpkeep or not.
   * @return performData bytes that the keeper should call performUpkeep with, if
   * upkeep is needed. If you would like to encode data to decode later, try
   * `abi.encode`.
   */
  function checkUpkeep(bytes calldata checkData) external returns (bool upkeepNeeded, bytes memory performData);

  /**
   * @notice method that is actually executed by the keepers, via the registry.
   * The data returned by the checkUpkeep simulation will be passed into
   * this method to actually be executed.
   * @dev The input to this method should not be trusted, and the caller of the
   * method should not even be restricted to any single registry. Anyone should
   * be able call it, and the input should be validated, there is no guarantee
   * that the data passed in is the performData returned from checkUpkeep. This
   * could happen due to malicious keepers, racing keepers, or simply a state
   * change while the performUpkeep transaction is waiting for confirmation.
   * Always validate the data passed in.
   * @param performData is the data which was passed back from the checkData
   * simulation. If it is encoded, it can easily be decoded into other types by
   * calling `abi.decode`. This data should not be trusted, and should be
   * validated against the contract's current state.
   */
  function performUpkeep(bytes calldata performData) external;
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
// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/ContextUpgradeable.sol";
import "../proxy/utils/Initializable.sol";

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
abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    function __Ownable_init() internal onlyInitializing sphereXGuardInternal(108) {
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal onlyInitializing sphereXGuardInternal(110) {
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
    function renounceOwnership() public virtual onlyOwner sphereXGuardPublic(113, 0x715018a6) {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner sphereXGuardPublic(115, 0xf2fde38b) {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual sphereXGuardInternal(111) {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
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
// SPDX-License-Identifier: UNLICENSED
// (c) SphereX 2023 Terms&Conditions

pragma solidity >=0.5.0;

/**
 * @title Interface for SphereXEngine - defenitions of core functionality
 * @author SphereX Technolegies ltd
 * @notice This interface is imported by SphereXProtected, so that SphereXProtected can call functions from SphereXEngine
 * @dev Full docs of these functions can be found in SphereXEngine
 */
interface ISphereXEngine {
    function sphereXValidatePre(int16 num, address sender, bytes calldata data) external returns (bytes32[] memory);
    function sphereXValidatePost(
        int16 num,
        uint256 gas,
        bytes32[] calldata valuesBefore,
        bytes32[] calldata valuesAfter
    ) external;
    function sphereXValidateInternalPre(int16 num) external returns (bytes32[] memory);
    function sphereXValidateInternalPost(
        int16 num,
        uint256 gas,
        bytes32[] calldata valuesBefore,
        bytes32[] calldata valuesAfter
    ) external;
}
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
// OpenZeppelin Contracts (last updated v4.5.0) (proxy/ERC1967/ERC1967Upgrade.sol)

pragma solidity ^0.8.2;

import "../beacon/IBeaconUpgradeable.sol";
import "../../interfaces/draft-IERC1822Upgradeable.sol";
import "../../utils/AddressUpgradeable.sol";
import "../../utils/StorageSlotUpgradeable.sol";
import "../utils/Initializable.sol";

/**
 * @dev This abstract contract provides getters and event emitting update functions for
 * https://eips.ethereum.org/EIPS/eip-1967[EIP1967] slots.
 *
 * _Available since v4.1._
 *
 * @custom:oz-upgrades-unsafe-allow delegatecall
 */
abstract contract ERC1967UpgradeUpgradeable is Initializable {
    function __ERC1967Upgrade_init() internal onlyInitializing sphereXGuardInternal(50) {}

    function __ERC1967Upgrade_init_unchained() internal onlyInitializing sphereXGuardInternal(52) {}
    // This is the keccak-256 hash of "eip1967.proxy.rollback" subtracted by 1

    bytes32 private constant _ROLLBACK_SLOT = 0x4910fdfa16fed3260ed0e7147f7cc6da11a60208b5b9406d12a635614ffd9143;

    /**
     * @dev Storage slot with the address of the current implementation.
     * This is the keccak-256 hash of "eip1967.proxy.implementation" subtracted by 1, and is
     * validated in the constructor.
     */
    bytes32 internal constant _IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;

    /**
     * @dev Emitted when the implementation is upgraded.
     */
    event Upgraded(address indexed implementation);

    /**
     * @dev Returns the current implementation address.
     */
    function _getImplementation() internal view returns (address) {
        return StorageSlotUpgradeable.getAddressSlot(_IMPLEMENTATION_SLOT).value;
    }

    /**
     * @dev Stores a new address in the EIP1967 implementation slot.
     */
    function _setImplementation(address newImplementation) private sphereXGuardInternal(62) {
        require(AddressUpgradeable.isContract(newImplementation), "ERC1967: new implementation is not a contract");
        StorageSlotUpgradeable.getAddressSlot(_IMPLEMENTATION_SLOT).value = newImplementation;
    }

    /**
     * @dev Perform implementation upgrade
     *
     * Emits an {Upgraded} event.
     */
    function _upgradeTo(address newImplementation) internal sphereXGuardInternal(66) {
        _setImplementation(newImplementation);
        emit Upgraded(newImplementation);
    }

    /**
     * @dev Perform implementation upgrade with additional setup call.
     *
     * Emits an {Upgraded} event.
     */
    function _upgradeToAndCall(address newImplementation, bytes memory data, bool forceCall)
        internal
        sphereXGuardInternal(69)
    {
        _upgradeTo(newImplementation);
        if (data.length > 0 || forceCall) {
            _functionDelegateCall(newImplementation, data);
        }
    }

    /**
     * @dev Perform implementation upgrade with security checks for UUPS proxies, and additional setup call.
     *
     * Emits an {Upgraded} event.
     */
    function _upgradeToAndCallUUPS(address newImplementation, bytes memory data, bool forceCall)
        internal
        sphereXGuardInternal(71)
    {
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
     * @dev Emitted when the admin account has changed.
     */
    event AdminChanged(address previousAdmin, address newAdmin);

    /**
     * @dev Returns the current admin.
     */
    function _getAdmin() internal view returns (address) {
        return StorageSlotUpgradeable.getAddressSlot(_ADMIN_SLOT).value;
    }

    /**
     * @dev Stores a new address in the EIP1967 admin slot.
     */
    function _setAdmin(address newAdmin) private sphereXGuardInternal(58) {
        require(newAdmin != address(0), "ERC1967: new admin is the zero address");
        StorageSlotUpgradeable.getAddressSlot(_ADMIN_SLOT).value = newAdmin;
    }

    /**
     * @dev Changes the admin of the proxy.
     *
     * Emits an {AdminChanged} event.
     */
    function _changeAdmin(address newAdmin) internal sphereXGuardInternal(54) {
        emit AdminChanged(_getAdmin(), newAdmin);
        _setAdmin(newAdmin);
    }

    /**
     * @dev The storage slot of the UpgradeableBeacon contract which defines the implementation for this proxy.
     * This is bytes32(uint256(keccak256('eip1967.proxy.beacon')) - 1)) and is validated in the constructor.
     */
    bytes32 internal constant _BEACON_SLOT = 0xa3f0ad74e5423aebfd80d3ef4346578335a9a72aeaee59ff6cb3582b35133d50;

    /**
     * @dev Emitted when the beacon is upgraded.
     */
    event BeaconUpgraded(address indexed beacon);

    /**
     * @dev Returns the current beacon.
     */
    function _getBeacon() internal view returns (address) {
        return StorageSlotUpgradeable.getAddressSlot(_BEACON_SLOT).value;
    }

    /**
     * @dev Stores a new beacon in the EIP1967 beacon slot.
     */
    function _setBeacon(address newBeacon) private sphereXGuardInternal(60) {
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
    function _upgradeBeaconToAndCall(address newBeacon, bytes memory data, bool forceCall)
        internal
        sphereXGuardInternal(64)
    {
        _setBeacon(newBeacon);
        emit BeaconUpgraded(newBeacon);
        if (data.length > 0 || forceCall) {
            _functionDelegateCall(IBeaconUpgradeable(newBeacon).implementation(), data);
        }
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function _functionDelegateCall(address target, bytes memory data)
        private
        sphereXGuardInternal(56)
        returns (bytes memory)
    {
        require(AddressUpgradeable.isContract(target), "Address: delegate call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return AddressUpgradeable.verifyCallResult(success, returndata, "Address: low-level delegate call failed");
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[50] private __gap;
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.1) (proxy/utils/Initializable.sol)

pragma solidity ^0.8.2;

import "../../utils/AddressUpgradeable.sol";
import "../../SphereXProtected.sol";

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
 * ```
 * contract MyToken is ERC20Upgradeable {
 *     function initialize() initializer public {
 *         __ERC20_init("MyToken", "MTK");
 *     }
 * }
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
abstract contract Initializable is SphereXProtected {
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
    function _disableInitializers() internal virtual sphereXGuardInternal(106) {
        require(!_initializing, "Initializable: contract is initializing");
        if (_initialized < type(uint8).max) {
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
// OpenZeppelin Contracts (last updated v4.8.0) (proxy/utils/UUPSUpgradeable.sol)

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
    function __UUPSUpgradeable_init() internal onlyInitializing sphereXGuardInternal(159) {}

    function __UUPSUpgradeable_init_unchained() internal onlyInitializing sphereXGuardInternal(161) {}
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
     */
    function upgradeTo(address newImplementation) external virtual onlyProxy sphereXGuardExternal(162) {
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
     */
    function upgradeToAndCall(address newImplementation, bytes memory data)
        external
        payable
        virtual
        onlyProxy
        sphereXGuardExternal(164)
    {
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
// SPDX-License-Identifier: UNLICENSED
// (c) SphereX 2023 Terms&Conditions

pragma solidity >=0.5.17;

import "./ISphereXEngine.sol";

/**
 * @title SphereX base Customer contract template
 * @dev notice this is an abstract
 */
abstract contract SphereXProtected {
    /**
     * @dev we would like to avoid occupying storage slots
     * @dev to easily incorporate with existing contracts
     */
    bytes32 private constant SPHEREX_ADMIN_STORAGE_SLOT = bytes32(uint256(keccak256("eip1967.spherex.spherex")) - 1);
    bytes32 private constant SPHEREX_ENGINE_STORAGE_SLOT =
        bytes32(uint256(keccak256("eip1967.spherex.spherex_engine")) - 1);

    /**
     * @dev this struct is used to reduce the stack usage of the modifiers.
     */
    struct ModifierLocals {
        bytes32[] storageSlots;
        bytes32[] valuesBefore;
        uint256 gas;
    }

    /**
     * @dev used when the client doesn't use a proxy
     * @notice constructor visibality is required to support all compiler versions
     */
    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() internal {
        __SphereXProtected_init();
    }

    /**
     * @dev used when the client uses a proxy - should be called by the inhereter initialization
     */
    function __SphereXProtected_init() internal {
        if (_getAddress(SPHEREX_ADMIN_STORAGE_SLOT) == address(0)) {
            _setAddress(SPHEREX_ADMIN_STORAGE_SLOT, msg.sender);
        }
    }

    // ============ Helper functions ============

    function _sphereXEngine() private view returns (ISphereXEngine) {
        return ISphereXEngine(_getAddress(SPHEREX_ENGINE_STORAGE_SLOT));
    }

    /**
     * Stores a new address in an abitrary slot
     * @param slot where to store the address
     * @param newAddress address to store in given slot
     */
    function _setAddress(bytes32 slot, address newAddress) private {
        // solhint-disable-next-line no-inline-assembly
        // slither-disable-next-line assembly
        assembly {
            sstore(slot, newAddress)
        }
    }

    /**
     * Returns an address from an arbitrary slot.
     * @param slot to read an address from
     */
    function _getAddress(bytes32 slot) private view returns (address addr) {
        // solhint-disable-next-line no-inline-assembly
        // slither-disable-next-line assembly
        assembly {
            addr := sload(slot)
        }
    }

    // ============ Local modifiers ============

    modifier onlySphereXAdmin() {
        require(msg.sender == _getAddress(SPHEREX_ADMIN_STORAGE_SLOT), "!SX:SPHEREX");
        _;
    }

    modifier returnsIfNotActivated() {
        if (address(_sphereXEngine()) == address(0)) {
            return;
        }

        _;
    }

    // ============ Management ============

    /**
     *
     * @param newSphereXAdmin new address of the new admin account
     */
    function changeSphereXAdmin(address newSphereXAdmin) external onlySphereXAdmin {
        _setAddress(SPHEREX_ADMIN_STORAGE_SLOT, newSphereXAdmin);
    }

    /**
     *
     * @param newSphereXEngine new address of the spherex engine
     * @dev this is also used to actually enable the defence
     * (because as long is this address is 0, the protection is disabled).
     */
    function changeSphereXEngine(address newSphereXEngine) external onlySphereXAdmin {
        _setAddress(SPHEREX_ENGINE_STORAGE_SLOT, newSphereXEngine);
    }

    // ============ Hooks ============

    /**
     * @dev internal function for engine communication. We use it to reduce contract size.
     *  Should be called before the code of a function.
     * @param num function identifier
     * @param isExternalCall set to true if this was called externally
     *  or a 'public' function from another address
     */
    function _sphereXValidatePre(int16 num, bool isExternalCall)
        internal
        returnsIfNotActivated
        returns (ModifierLocals memory locals)
    {
        ISphereXEngine sphereXEngine = _sphereXEngine();
        if (isExternalCall) {
            locals.storageSlots = sphereXEngine.sphereXValidatePre(num, msg.sender, msg.data);
        } else {
            locals.storageSlots = sphereXEngine.sphereXValidateInternalPre(num);
        }
        locals.valuesBefore = _readStorage(locals.storageSlots);
        locals.gas = gasleft();
        return locals;
    }

    /**
     * @dev internal function for engine communication. We use it to reduce contract size.
     *  Should be called after the code of a function.
     * @param num function identifier
     * @param isExternalCall set to true if this was called externally
     *  or a 'public' function from another address
     */
    function _sphereXValidatePost(int16 num, bool isExternalCall, ModifierLocals memory locals)
        internal
        returnsIfNotActivated
    {
        uint256 gas = locals.gas - gasleft();

        ISphereXEngine sphereXEngine = _sphereXEngine();

        bytes32[] memory valuesAfter;
        valuesAfter = _readStorage(locals.storageSlots);

        if (isExternalCall) {
            sphereXEngine.sphereXValidatePost(num, gas, locals.valuesBefore, valuesAfter);
        } else {
            sphereXEngine.sphereXValidateInternalPost(num, gas, locals.valuesBefore, valuesAfter);
        }
    }

    /**
     * @dev internal function for engine communication. We use it to reduce contract size.
     *  Should be called before the code of a function.
     * @param num function identifier
     * @return locals ModifierLocals
     */
    function _sphereXValidateInternalPre(int16 num)
        internal
        returnsIfNotActivated
        returns (ModifierLocals memory locals)
    {
        locals.storageSlots = _sphereXEngine().sphereXValidateInternalPre(num);
        locals.valuesBefore = _readStorage(locals.storageSlots);
        locals.gas = gasleft();
        return locals;
    }

    /**
     * @dev internal function for engine communication. We use it to reduce contract size.
     *  Should be called after the code of a function.
     * @param num function identifier
     * @param locals ModifierLocals
     */
    function _sphereXValidateInternalPost(int16 num, ModifierLocals memory locals) internal returnsIfNotActivated {
        bytes32[] memory valuesAfter;
        valuesAfter = _readStorage(locals.storageSlots);
        _sphereXEngine().sphereXValidateInternalPost(num, locals.gas - gasleft(), locals.valuesBefore, valuesAfter);
    }

    /**
     *  @dev Modifier to be incorporated in all internal protected non-view functions
     */
    modifier sphereXGuardInternal(int16 num) {
        ModifierLocals memory locals = _sphereXValidateInternalPre(num);
        _;
        _sphereXValidateInternalPost(-num, locals);
    }

    /**
     *  @dev Modifier to be incorporated in all external protected non-view functions
     */
    modifier sphereXGuardExternal(int16 num) {
        ModifierLocals memory locals = _sphereXValidatePre(num, true);
        _;
        _sphereXValidatePost(-num, true, locals);
    }

    /**
     *  @dev Modifier to be incorporated in all public rotected non-view functions
     */
    modifier sphereXGuardPublic(int16 num, bytes4 selector) {
        ModifierLocals memory locals = _sphereXValidatePre(num, msg.sig == selector);
        _;
        _sphereXValidatePost(-num, msg.sig == selector, locals);
    }

    // ============ Internal Storage logic ============

    /**
     * Internal function that reads values from given storage slots and returns them
     * @param storageSlots list of storage slots to read
     * @return list of values read from the various storage slots
     */
    function _readStorage(bytes32[] memory storageSlots) internal view returns (bytes32[] memory) {
        uint256 arrayLength = storageSlots.length;
        bytes32[] memory values = new bytes32[](arrayLength);
        // create the return array data

        for (uint256 i = 0; i < arrayLength; i++) {
            bytes32 slot = storageSlots[i];
            bytes32 temp_value;
            // solhint-disable-next-line no-inline-assembly
            // slither-disable-next-line assembly
            assembly {
                temp_value := sload(slot)
            }

            values[i] = temp_value;
        }
        return values;
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (token/ERC20/ERC20.sol)

pragma solidity ^0.8.0;

import "./IERC20Upgradeable.sol";
import "./extensions/IERC20MetadataUpgradeable.sol";
import "../../utils/ContextUpgradeable.sol";
import "../../proxy/utils/Initializable.sol";

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
contract ERC20Upgradeable is Initializable, ContextUpgradeable, IERC20Upgradeable, IERC20MetadataUpgradeable {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * The default value of {decimals} is 18. To select a different value for
     * {decimals} you should overload it.
     *
     * All two of these values are immutable: they can only be set once during
     * construction.
     */
    function __ERC20_init(string memory name_, string memory symbol_)
        internal
        onlyInitializing
        sphereXGuardInternal(72)
    {
        __ERC20_init_unchained(name_, symbol_);
    }

    function __ERC20_init_unchained(string memory name_, string memory symbol_)
        internal
        onlyInitializing
        sphereXGuardInternal(73)
    {
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
     * Ether and Wei. This is the value {ERC20} uses, unless this function is
     * overridden;
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
    function transfer(address to, uint256 amount)
        public
        virtual
        override
        sphereXGuardPublic(84, 0xa9059cbb)
        returns (bool)
    {
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
    function approve(address spender, uint256 amount)
        public
        virtual
        override
        sphereXGuardPublic(81, 0x095ea7b3)
        returns (bool)
    {
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
    function transferFrom(address from, address to, uint256 amount)
        public
        virtual
        override
        sphereXGuardPublic(85, 0x23b872dd)
        returns (bool)
    {
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
    function increaseAllowance(address spender, uint256 addedValue)
        public
        virtual
        sphereXGuardPublic(83, 0x39509351)
        returns (bool)
    {
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
    function decreaseAllowance(address spender, uint256 subtractedValue)
        public
        virtual
        sphereXGuardPublic(82, 0xa457c2d7)
        returns (bool)
    {
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
    function _transfer(address from, address to, uint256 amount) internal virtual sphereXGuardInternal(80) {
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

    /**
     * @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal virtual sphereXGuardInternal(78) {
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
    function _burn(address account, uint256 amount) internal virtual sphereXGuardInternal(77) {
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
    function _approve(address owner, address spender, uint256 amount) internal virtual sphereXGuardInternal(75) {
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
    function _spendAllowance(address owner, address spender, uint256 amount)
        internal
        virtual
        sphereXGuardInternal(79)
    {
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
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual sphereXGuardInternal(76) {}

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
    function _afterTokenTransfer(address from, address to, uint256 amount) internal virtual sphereXGuardInternal(74) {}

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[45] private __gap;
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/draft-IERC20Permit.sol)

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
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.0;

import "../IERC20Upgradeable.sol";

/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
 */
interface IERC20MetadataUpgradeable is IERC20Upgradeable {
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
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

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
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.0;

import "../IERC20Upgradeable.sol";
import "../extensions/draft-IERC20PermitUpgradeable.sol";
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

    function safeTransfer(
        IERC20Upgradeable token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20Upgradeable token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(
        IERC20Upgradeable token,
        address spender,
        uint256 value
    ) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20Upgradeable token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20Upgradeable token,
        address spender,
        uint256 value
    ) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

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
        if (returndata.length > 0) {
            // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.2) (token/ERC721/ERC721.sol)

pragma solidity ^0.8.0;

import "./IERC721Upgradeable.sol";
import "./IERC721ReceiverUpgradeable.sol";
import "./extensions/IERC721MetadataUpgradeable.sol";
import "../../utils/AddressUpgradeable.sol";
import "../../utils/ContextUpgradeable.sol";
import "../../utils/StringsUpgradeable.sol";
import "../../utils/introspection/ERC165Upgradeable.sol";
import "../../proxy/utils/Initializable.sol";

/**
 * @dev Implementation of https://eips.ethereum.org/EIPS/eip-721[ERC721] Non-Fungible Token Standard, including
 * the Metadata extension, but not including the Enumerable extension, which is available separately as
 * {ERC721Enumerable}.
 */
contract ERC721Upgradeable is
    Initializable,
    ContextUpgradeable,
    ERC165Upgradeable,
    IERC721Upgradeable,
    IERC721MetadataUpgradeable
{
    using AddressUpgradeable for address;
    using StringsUpgradeable for uint256;

    // Token name
    string private _name;

    // Token symbol
    string private _symbol;

    // Mapping from token ID to owner address
    mapping(uint256 => address) private _owners;

    // Mapping owner address to token count
    mapping(address => uint256) private _balances;

    // Mapping from token ID to approved address
    mapping(uint256 => address) private _tokenApprovals;

    // Mapping from owner to operator approvals
    mapping(address => mapping(address => bool)) private _operatorApprovals;

    /**
     * @dev Initializes the contract by setting a `name` and a `symbol` to the token collection.
     */
    function __ERC721_init(string memory name_, string memory symbol_)
        internal
        onlyInitializing
        sphereXGuardInternal(86)
    {
        __ERC721_init_unchained(name_, symbol_);
    }

    function __ERC721_init_unchained(string memory name_, string memory symbol_)
        internal
        onlyInitializing
        sphereXGuardInternal(87)
    {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(ERC165Upgradeable, IERC165Upgradeable)
        returns (bool)
    {
        return interfaceId == type(IERC721Upgradeable).interfaceId
            || interfaceId == type(IERC721MetadataUpgradeable).interfaceId || super.supportsInterface(interfaceId);
    }

    /**
     * @dev See {IERC721-balanceOf}.
     */
    function balanceOf(address owner) public view virtual override returns (uint256) {
        require(owner != address(0), "ERC721: address zero is not a valid owner");
        return _balances[owner];
    }

    /**
     * @dev See {IERC721-ownerOf}.
     */
    function ownerOf(uint256 tokenId) public view virtual override returns (address) {
        address owner = _ownerOf(tokenId);
        require(owner != address(0), "ERC721: invalid token ID");
        return owner;
    }

    /**
     * @dev See {IERC721Metadata-name}.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev See {IERC721Metadata-symbol}.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev See {IERC721Metadata-tokenURI}.
     */
    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        _requireMinted(tokenId);

        string memory baseURI = _baseURI();
        return bytes(baseURI).length > 0 ? string(abi.encodePacked(baseURI, tokenId.toString())) : "";
    }

    /**
     * @dev Base URI for computing {tokenURI}. If set, the resulting URI for each
     * token will be the concatenation of the `baseURI` and the `tokenId`. Empty
     * by default, can be overridden in child contracts.
     */
    function _baseURI() internal view virtual returns (string memory) {
        return "";
    }

    /**
     * @dev See {IERC721-approve}.
     */
    function approve(address to, uint256 tokenId) public virtual override sphereXGuardPublic(100, 0x095ea7b3) {
        address owner = ERC721Upgradeable.ownerOf(tokenId);
        require(to != owner, "ERC721: approval to current owner");

        require(
            _msgSender() == owner || isApprovedForAll(owner, _msgSender()),
            "ERC721: approve caller is not token owner or approved for all"
        );

        _approve(to, tokenId);
    }

    /**
     * @dev See {IERC721-getApproved}.
     */
    function getApproved(uint256 tokenId) public view virtual override returns (address) {
        _requireMinted(tokenId);

        return _tokenApprovals[tokenId];
    }

    /**
     * @dev See {IERC721-setApprovalForAll}.
     */
    function setApprovalForAll(address operator, bool approved)
        public
        virtual
        override
        sphereXGuardPublic(103, 0xa22cb465)
    {
        _setApprovalForAll(_msgSender(), operator, approved);
    }

    /**
     * @dev See {IERC721-isApprovedForAll}.
     */
    function isApprovedForAll(address owner, address operator) public view virtual override returns (bool) {
        return _operatorApprovals[owner][operator];
    }

    /**
     * @dev See {IERC721-transferFrom}.
     */
    function transferFrom(address from, address to, uint256 tokenId)
        public
        virtual
        override
        sphereXGuardPublic(104, 0x23b872dd)
    {
        //solhint-disable-next-line max-line-length
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: caller is not token owner or approved");

        _transfer(from, to, tokenId);
    }

    /**
     * @dev See {IERC721-safeTransferFrom}.
     */
    function safeTransferFrom(address from, address to, uint256 tokenId)
        public
        virtual
        override
        sphereXGuardPublic(101, 0x42842e0e)
    {
        safeTransferFrom(from, to, tokenId, "");
    }

    /**
     * @dev See {IERC721-safeTransferFrom}.
     */
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory data)
        public
        virtual
        override
        sphereXGuardPublic(102, 0xb88d4fde)
    {
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: caller is not token owner or approved");
        _safeTransfer(from, to, tokenId, data);
    }

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * `data` is additional data, it has no specified format and it is sent in call to `to`.
     *
     * This internal function is equivalent to {safeTransferFrom}, and can be used to e.g.
     * implement alternative mechanisms to perform token transfer, such as signature-based.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function _safeTransfer(address from, address to, uint256 tokenId, bytes memory data)
        internal
        virtual
        sphereXGuardInternal(97)
    {
        _transfer(from, to, tokenId);
        require(_checkOnERC721Received(from, to, tokenId, data), "ERC721: transfer to non ERC721Receiver implementer");
    }

    /**
     * @dev Returns the owner of the `tokenId`. Does NOT revert if token doesn't exist
     */
    function _ownerOf(uint256 tokenId) internal view virtual returns (address) {
        return _owners[tokenId];
    }

    /**
     * @dev Returns whether `tokenId` exists.
     *
     * Tokens can be managed by their owner or approved accounts via {approve} or {setApprovalForAll}.
     *
     * Tokens start existing when they are minted (`_mint`),
     * and stop existing when they are burned (`_burn`).
     */
    function _exists(uint256 tokenId) internal view virtual returns (bool) {
        return _ownerOf(tokenId) != address(0);
    }

    /**
     * @dev Returns whether `spender` is allowed to manage `tokenId`.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view virtual returns (bool) {
        address owner = ERC721Upgradeable.ownerOf(tokenId);
        return (spender == owner || isApprovedForAll(owner, spender) || getApproved(tokenId) == spender);
    }

    /**
     * @dev Safely mints `tokenId` and transfers it to `to`.
     *
     * Requirements:
     *
     * - `tokenId` must not exist.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function _safeMint(address to, uint256 tokenId) internal virtual sphereXGuardInternal(95) {
        _safeMint(to, tokenId, "");
    }

    /**
     * @dev Same as {xref-ERC721-_safeMint-address-uint256-}[`_safeMint`], with an additional `data` parameter which is
     * forwarded in {IERC721Receiver-onERC721Received} to contract recipients.
     */
    function _safeMint(address to, uint256 tokenId, bytes memory data) internal virtual sphereXGuardInternal(96) {
        _mint(to, tokenId);
        require(
            _checkOnERC721Received(address(0), to, tokenId, data), "ERC721: transfer to non ERC721Receiver implementer"
        );
    }

    /**
     * @dev Mints `tokenId` and transfers it to `to`.
     *
     * WARNING: Usage of this method is discouraged, use {_safeMint} whenever possible
     *
     * Requirements:
     *
     * - `tokenId` must not exist.
     * - `to` cannot be the zero address.
     *
     * Emits a {Transfer} event.
     */
    function _mint(address to, uint256 tokenId) internal virtual sphereXGuardInternal(94) {
        require(to != address(0), "ERC721: mint to the zero address");
        require(!_exists(tokenId), "ERC721: token already minted");

        _beforeTokenTransfer(address(0), to, tokenId, 1);

        // Check that tokenId was not minted by `_beforeTokenTransfer` hook
        require(!_exists(tokenId), "ERC721: token already minted");

        unchecked {
            // Will not overflow unless all 2**256 token ids are minted to the same owner.
            // Given that tokens are minted one by one, it is impossible in practice that
            // this ever happens. Might change if we allow batch minting.
            // The ERC fails to describe this case.
            _balances[to] += 1;
        }

        _owners[tokenId] = to;

        emit Transfer(address(0), to, tokenId);

        _afterTokenTransfer(address(0), to, tokenId, 1);
    }

    /**
     * @dev Destroys `tokenId`.
     * The approval is cleared when the token is burned.
     * This is an internal function that does not check if the sender is authorized to operate on the token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     *
     * Emits a {Transfer} event.
     */
    function _burn(uint256 tokenId) internal virtual sphereXGuardInternal(92) {
        address owner = ERC721Upgradeable.ownerOf(tokenId);

        _beforeTokenTransfer(owner, address(0), tokenId, 1);

        // Update ownership in case tokenId was transferred by `_beforeTokenTransfer` hook
        owner = ERC721Upgradeable.ownerOf(tokenId);

        // Clear approvals
        delete _tokenApprovals[tokenId];

        unchecked {
            // Cannot overflow, as that would require more tokens to be burned/transferred
            // out than the owner initially received through minting and transferring in.
            _balances[owner] -= 1;
        }
        delete _owners[tokenId];

        emit Transfer(owner, address(0), tokenId);

        _afterTokenTransfer(owner, address(0), tokenId, 1);
    }

    /**
     * @dev Transfers `tokenId` from `from` to `to`.
     *  As opposed to {transferFrom}, this imposes no restrictions on msg.sender.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     *
     * Emits a {Transfer} event.
     */
    function _transfer(address from, address to, uint256 tokenId) internal virtual sphereXGuardInternal(99) {
        require(ERC721Upgradeable.ownerOf(tokenId) == from, "ERC721: transfer from incorrect owner");
        require(to != address(0), "ERC721: transfer to the zero address");

        _beforeTokenTransfer(from, to, tokenId, 1);

        // Check that tokenId was not transferred by `_beforeTokenTransfer` hook
        require(ERC721Upgradeable.ownerOf(tokenId) == from, "ERC721: transfer from incorrect owner");

        // Clear approvals from the previous owner
        delete _tokenApprovals[tokenId];

        unchecked {
            // `_balances[from]` cannot overflow for the same reason as described in `_burn`:
            // `from`'s balance is the number of token held, which is at least one before the current
            // transfer.
            // `_balances[to]` could overflow in the conditions described in `_mint`. That would require
            // all 2**256 token ids to be minted, which in practice is impossible.
            _balances[from] -= 1;
            _balances[to] += 1;
        }
        _owners[tokenId] = to;

        emit Transfer(from, to, tokenId);

        _afterTokenTransfer(from, to, tokenId, 1);
    }

    /**
     * @dev Approve `to` to operate on `tokenId`
     *
     * Emits an {Approval} event.
     */
    function _approve(address to, uint256 tokenId) internal virtual sphereXGuardInternal(90) {
        _tokenApprovals[tokenId] = to;
        emit Approval(ERC721Upgradeable.ownerOf(tokenId), to, tokenId);
    }

    /**
     * @dev Approve `operator` to operate on all of `owner` tokens
     *
     * Emits an {ApprovalForAll} event.
     */
    function _setApprovalForAll(address owner, address operator, bool approved)
        internal
        virtual
        sphereXGuardInternal(98)
    {
        require(owner != operator, "ERC721: approve to caller");
        _operatorApprovals[owner][operator] = approved;
        emit ApprovalForAll(owner, operator, approved);
    }

    /**
     * @dev Reverts if the `tokenId` has not been minted yet.
     */
    function _requireMinted(uint256 tokenId) internal view virtual {
        require(_exists(tokenId), "ERC721: invalid token ID");
    }

    /**
     * @dev Internal function to invoke {IERC721Receiver-onERC721Received} on a target address.
     * The call is not executed if the target address is not a contract.
     *
     * @param from address representing the previous owner of the given token ID
     * @param to target address that will receive the tokens
     * @param tokenId uint256 ID of the token to be transferred
     * @param data bytes optional data to send along with the call
     * @return bool whether the call correctly returned the expected magic value
     */
    function _checkOnERC721Received(address from, address to, uint256 tokenId, bytes memory data)
        private
        sphereXGuardInternal(93)
        returns (bool)
    {
        if (to.isContract()) {
            try IERC721ReceiverUpgradeable(to).onERC721Received(_msgSender(), from, tokenId, data) returns (
                bytes4 retval
            ) {
                return retval == IERC721ReceiverUpgradeable.onERC721Received.selector;
            } catch (bytes memory reason) {
                if (reason.length == 0) {
                    revert("ERC721: transfer to non ERC721Receiver implementer");
                } else {
                    /// @solidity memory-safe-assembly
                    assembly {
                        revert(add(32, reason), mload(reason))
                    }
                }
            }
        } else {
            return true;
        }
    }

    /**
     * @dev Hook that is called before any token transfer. This includes minting and burning. If {ERC721Consecutive} is
     * used, the hook may be called as part of a consecutive (batch) mint, as indicated by `batchSize` greater than 1.
     *
     * Calling conditions:
     *
     * - When `from` and `to` are both non-zero, ``from``'s tokens will be transferred to `to`.
     * - When `from` is zero, the tokens will be minted for `to`.
     * - When `to` is zero, ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     * - `batchSize` is non-zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(address from, address to, uint256 firstTokenId, uint256 batchSize)
        internal
        virtual
        sphereXGuardInternal(91)
    {}

    /**
     * @dev Hook that is called after any token transfer. This includes minting and burning. If {ERC721Consecutive} is
     * used, the hook may be called as part of a consecutive (batch) mint, as indicated by `batchSize` greater than 1.
     *
     * Calling conditions:
     *
     * - When `from` and `to` are both non-zero, ``from``'s tokens were transferred to `to`.
     * - When `from` is zero, the tokens were minted for `to`.
     * - When `to` is zero, ``from``'s tokens were burned.
     * - `from` and `to` are never both zero.
     * - `batchSize` is non-zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(address from, address to, uint256 firstTokenId, uint256 batchSize)
        internal
        virtual
        sphereXGuardInternal(89)
    {}

    /**
     * @dev Unsafe write access to the balances, used by extensions that "mint" tokens using an {ownerOf} override.
     *
     * WARNING: Anyone calling this MUST ensure that the balances remain consistent with the ownership. The invariant
     * being that for any address `a` the value returned by `balanceOf(a)` must be equal to the number of tokens such
     * that `ownerOf(tokenId)` is `a`.
     */
    // solhint-disable-next-line func-name-mixedcase
    function __unsafe_increaseBalance(address account, uint256 amount) internal sphereXGuardInternal(88) {
        _balances[account] += amount;
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[44] private __gap;
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC721/extensions/IERC721Metadata.sol)

pragma solidity ^0.8.0;

import "../IERC721Upgradeable.sol";

/**
 * @title ERC-721 Non-Fungible Token Standard, optional metadata extension
 * @dev See https://eips.ethereum.org/EIPS/eip-721
 */
interface IERC721MetadataUpgradeable is IERC721Upgradeable {
    /**
     * @dev Returns the token collection name.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the token collection symbol.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the Uniform Resource Identifier (URI) for `tokenId` token.
     */
    function tokenURI(uint256 tokenId) external view returns (string memory);
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC721/IERC721Receiver.sol)

pragma solidity ^0.8.0;

/**
 * @title ERC721 token receiver interface
 * @dev Interface for any contract that wants to support safeTransfers
 * from ERC721 asset contracts.
 */
interface IERC721ReceiverUpgradeable {
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
// OpenZeppelin Contracts (last updated v4.8.0) (token/ERC721/IERC721.sol)

pragma solidity ^0.8.0;

import "../../utils/introspection/IERC165Upgradeable.sol";

/**
 * @dev Required interface of an ERC721 compliant contract.
 */
interface IERC721Upgradeable is IERC165Upgradeable {
    /**
     * @dev Emitted when `tokenId` token is transferred from `from` to `to`.
     */
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables `approved` to manage the `tokenId` token.
     */
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables or disables (`approved`) `operator` to manage all of its assets.
     */
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    /**
     * @dev Returns the number of tokens in ``owner``'s account.
     */
    function balanceOf(address owner) external view returns (uint256 balance);

    /**
     * @dev Returns the owner of the `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function ownerOf(uint256 tokenId) external view returns (address owner);

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must have been allowed to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Transfers `tokenId` token from `from` to `to`.
     *
     * WARNING: Note that the caller is responsible to confirm that the recipient is capable of receiving ERC721
     * or else they may be permanently lost. Usage of {safeTransferFrom} prevents loss, though the caller must
     * understand this adds an external call which potentially creates a reentrancy vulnerability.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Gives permission to `to` to transfer `tokenId` token to another account.
     * The approval is cleared when the token is transferred.
     *
     * Only a single account can be approved at a time, so approving the zero address clears previous approvals.
     *
     * Requirements:
     *
     * - The caller must own the token or be an approved operator.
     * - `tokenId` must exist.
     *
     * Emits an {Approval} event.
     */
    function approve(address to, uint256 tokenId) external;

    /**
     * @dev Approve or remove `operator` as an operator for the caller.
     * Operators can call {transferFrom} or {safeTransferFrom} for any token owned by the caller.
     *
     * Requirements:
     *
     * - The `operator` cannot be the caller.
     *
     * Emits an {ApprovalForAll} event.
     */
    function setApprovalForAll(address operator, bool _approved) external;

    /**
     * @dev Returns the account approved for `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function getApproved(uint256 tokenId) external view returns (address operator);

    /**
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     *
     * See {setApprovalForAll}
     */
    function isApprovedForAll(address owner, address operator) external view returns (bool);
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (utils/Address.sol)

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
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
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
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
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
    function __Context_init() internal onlyInitializing sphereXGuardInternal(32) {}

    function __Context_init_unchained() internal onlyInitializing sphereXGuardInternal(35) {}

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
    function __ERC165_init() internal onlyInitializing sphereXGuardInternal(47) {}

    function __ERC165_init_unchained() internal onlyInitializing sphereXGuardInternal(49) {}
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
// OpenZeppelin Contracts (last updated v4.8.0) (utils/math/Math.sol)

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
    function mulDiv(
        uint256 x,
        uint256 y,
        uint256 denominator
    ) internal pure returns (uint256 result) {
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
                return prod0 / denominator;
            }

            // Make sure the result is less than 2^256. Also prevents denominator == 0.
            require(denominator > prod1);

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
    function mulDiv(
        uint256 x,
        uint256 y,
        uint256 denominator,
        Rounding rounding
    ) internal pure returns (uint256) {
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
            if (value >= 10**64) {
                value /= 10**64;
                result += 64;
            }
            if (value >= 10**32) {
                value /= 10**32;
                result += 32;
            }
            if (value >= 10**16) {
                value /= 10**16;
                result += 16;
            }
            if (value >= 10**8) {
                value /= 10**8;
                result += 8;
            }
            if (value >= 10**4) {
                value /= 10**4;
                result += 4;
            }
            if (value >= 10**2) {
                value /= 10**2;
                result += 2;
            }
            if (value >= 10**1) {
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
            return result + (rounding == Rounding.Up && 10**result < value ? 1 : 0);
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
     * @dev Return the log in base 10, following the selected rounding direction, of a positive value.
     * Returns 0 if given 0.
     */
    function log256(uint256 value, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = log256(value);
            return result + (rounding == Rounding.Up && 1 << (result * 8) < value ? 1 : 0);
        }
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (utils/StorageSlot.sol)

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
 * ```
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
 * _Available since v4.1 for `address`, `bool`, `bytes32`, and `uint256`._
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
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (utils/Strings.sol)

pragma solidity ^0.8.0;

import "./math/MathUpgradeable.sol";

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
// OpenZeppelin Contracts (last updated v4.9.0) (token/ERC20/utils/SafeERC20.sol)

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
     * non-reverting calls are assumed to be successful. Compatible with tokens that require the approval to be set to
     * 0 before setting it to a non-zero value.
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
pragma solidity >=0.6.2;

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
pragma solidity >=0.6.2;

import './IUniswapV2Router01.sol';

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
//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "./deps/OwnableUpgradeable.sol";
import "./deps/Initializable.sol";
import "./deps/UUPSUpgradeable.sol";
import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";
import "./interfaces/IIdleStrategy.sol";
import "./interfaces/IStrategy.sol";
import {ReceiptNFT} from "./ReceiptNFT.sol";
import {StrategyRouter} from "./StrategyRouter.sol";
import {Exchange} from "./exchange/Exchange.sol";
import "./deps/EnumerableSetExtension.sol";
import "./interfaces/IUsdOracle.sol";

/// @notice This contract contains batch related code, serves as part of StrategyRouter.
/// @notice This contract should be owned by StrategyRouter.
contract Batch is Initializable, UUPSUpgradeable, OwnableUpgradeable {
    using SafeERC20 for IERC20;
    using EnumerableSet for EnumerableSet.AddressSet;
    using EnumerableSetExtension for EnumerableSet.AddressSet;

    /* ERRORS */

    error AlreadySupportedToken();
    error CantRemoveTokenOfActiveStrategy();
    error UnsupportedToken();
    error NotReceiptOwner();
    error CycleClosed();
    error NotEnoughBalanceInBatch();
    error CallerIsNotStrategyRouter();
    error DepositFeeExceedsDepositAmountOrTheyAreEqual();
    error MaxDepositFeeExceedsThreshold();
    error MinDepositFeeExceedsMax();
    error DepositFeePercentExceedsFeePercentageThreshold();
    error NotSetMaxFeeInUsdWhenFeeInBpsIsSet();
    error DepositFeeTreasuryNotSet();
    error DepositUnderDepositFeeValue();
    error InvalidToken();

    event SetAddresses(Exchange _exchange, IUsdOracle _oracle, StrategyRouter _router, ReceiptNFT _receiptNft);
    event SetDepositFeeSettings(Batch.DepositFeeSettings newDepositFeeSettings);

    uint8 public constant UNIFORM_DECIMALS = 18;
    // used in rebalance function, UNIFORM_DECIMALS, so 1e17 == 0.1
    uint256 public constant REBALANCE_SWAP_THRESHOLD = 1e17;

    uint256 private constant DEPOSIT_FEE_AMOUNT_THRESHOLD = 50e18; // 50 USD
    uint256 private constant DEPOSIT_FEE_PERCENT_THRESHOLD = 300; // 3% in basis points
    uint256 private constant MAX_BPS = 10000; // 100%

    DepositFeeSettings public depositFeeSettings;

    ReceiptNFT public receiptContract;
    Exchange public exchange;
    StrategyRouter public router;
    IUsdOracle public oracle;

    EnumerableSet.AddressSet private supportedTokens;

    struct DepositFeeSettings {
        uint256 minFeeInUsd; // Amount of USD, must be `UNIFORM_DECIMALS` decimals
        uint256 maxFeeInUsd; // Amount of USD, must be `UNIFORM_DECIMALS` decimals
        uint256 feeInBps; // Percentage of deposit fee, in basis points
    }

    struct TokenInfo {
        address tokenAddress;
        uint256 balance;
        bool insufficientBalance;
    }

    struct CapacityData {
        bool isLimitReached;
        uint256 underflowUniform;
    }

    modifier onlyStrategyRouter() {
        if (msg.sender != address(router)) revert CallerIsNotStrategyRouter();
        _;
    }

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        // lock implementation
        _disableInitializers();
    }

    function initialize() external initializer sphereXGuardExternal(17) {
        __SphereXProtected_init();
        __Ownable_init();
        __UUPSUpgradeable_init();
    }

    function _authorizeUpgrade(address newImplementation) internal override onlyOwner sphereXGuardInternal(12) {}

    // Owner Functions

    function setAddresses(Exchange _exchange, IUsdOracle _oracle, StrategyRouter _router, ReceiptNFT _receiptNft)
        external
        onlyOwner
        sphereXGuardExternal(20)
    {
        exchange = _exchange;
        oracle = _oracle;
        router = _router;
        receiptContract = _receiptNft;
        emit SetAddresses(_exchange, _oracle, _router, _receiptNft);
    }

    /// @notice Set deposit fee settings in the batch.
    /// @param _depositFeeSettings Deposit settings.
    /// @dev Owner function.
    function setDepositFeeSettings(DepositFeeSettings calldata _depositFeeSettings)
        external
        onlyOwner
        sphereXGuardExternal(21)
    {
        // Ensure that maxFeeInUsd is not greater than the threshold of 50 USD
        if (_depositFeeSettings.maxFeeInUsd > DEPOSIT_FEE_AMOUNT_THRESHOLD) {
            revert MaxDepositFeeExceedsThreshold();
        }

        // Ensure that feeInBps is not greater than the threshold of 300 bps (3%)
        if (_depositFeeSettings.feeInBps > DEPOSIT_FEE_PERCENT_THRESHOLD) {
            revert DepositFeePercentExceedsFeePercentageThreshold();
        }

        // Ensure that minFeeInUsd is not greater than maxFeeInUsd
        if (_depositFeeSettings.maxFeeInUsd < _depositFeeSettings.minFeeInUsd) revert MinDepositFeeExceedsMax();

        // Ensure that maxFeeInUsd also has a value if feeInBps is set
        if (_depositFeeSettings.maxFeeInUsd == 0 && _depositFeeSettings.feeInBps != 0) {
            revert NotSetMaxFeeInUsdWhenFeeInBpsIsSet();
        }

        depositFeeSettings = _depositFeeSettings;
        emit SetDepositFeeSettings(depositFeeSettings);
    }

    // Universal Functions

    function supportsToken(address tokenAddress) public view returns (bool) {
        return supportedTokens.contains(tokenAddress);
    }

    /// @dev Returns list of supported tokens.
    function getSupportedTokens() public view returns (address[] memory) {
        return supportedTokens.values();
    }

    function getBatchValueUsd()
        public
        view
        returns (uint256 totalBalanceUsd, uint256[] memory supportedTokenBalancesUsd)
    {
        StrategyRouter.TokenPrice[] memory supportedTokenPrices = getSupportedTokensWithPriceInUsd();
        return this.getBatchValueUsdWithoutOracleCalls(supportedTokenPrices);
    }

    function getBatchValueUsdWithoutOracleCalls(StrategyRouter.TokenPrice[] calldata supportedTokenPrices)
        public
        view
        returns (uint256 totalBalanceUsd, uint256[] memory supportedTokenBalancesUsd)
    {
        supportedTokenBalancesUsd = new uint256[](supportedTokenPrices.length);
        for (uint256 i; i < supportedTokenBalancesUsd.length; i++) {
            address token = supportedTokenPrices[i].token;
            uint256 balance = ERC20(token).balanceOf(address(this));

            balance = ((balance * supportedTokenPrices[i].price) / 10 ** supportedTokenPrices[i].priceDecimals);
            balance = toUniform(balance, token);
            supportedTokenBalancesUsd[i] = balance;
            totalBalanceUsd += balance;
        }
    }

    function getSupportedTokensWithPriceInUsd()
        public
        view
        returns (StrategyRouter.TokenPrice[] memory supportedTokenPrices)
    {
        address[] memory _supportedTokens = getSupportedTokens();
        uint256 supportedTokensLength = _supportedTokens.length;
        supportedTokenPrices = new StrategyRouter.TokenPrice[](supportedTokensLength);
        for (uint256 i; i < supportedTokensLength; i++) {
            (uint256 price, uint8 priceDecimals) = oracle.getTokenUsdPrice(_supportedTokens[i]);
            supportedTokenPrices[i] =
                StrategyRouter.TokenPrice({price: price, priceDecimals: priceDecimals, token: _supportedTokens[i]});
        }
    }

    // @notice Get a deposit fee amount in tokens.
    // @param depositAmount Amount of tokens to deposit.
    // @param depositToken Token address.
    // @dev Returns a deposit fee amount with token decimals.
    function getDepositFeeInTokens(uint256 depositAmount, address depositToken)
        public
        view
        returns (uint256 feeAmount)
    {
        // convert deposit amount to USD
        (uint256 tokenUsdPrice, uint8 oraclePriceDecimals) = oracle.getTokenUsdPrice(depositToken);
        uint256 depositAmountInUsd = (depositAmount * tokenUsdPrice) / 10 ** oraclePriceDecimals;
        depositAmountInUsd = toUniform(depositAmountInUsd, depositToken);

        // calculate fee amount in USD
        uint256 feeAmountInUsd = calculateDepositFee(depositAmountInUsd);
        if (feeAmountInUsd == 0) return 0;

        // ensure that fee amount is not exceed deposit amount to avoid overflow
        // and they are not equal to avoid 0 deposit
        if (feeAmountInUsd >= depositAmountInUsd) revert DepositFeeExceedsDepositAmountOrTheyAreEqual();

        // convert fee amount in usd to tokens amount
        feeAmount = (feeAmountInUsd * 10 ** oraclePriceDecimals) / tokenUsdPrice;
        feeAmount = fromUniform(feeAmount, depositToken);
    }

    // User Functions

    /// @notice Withdraw tokens from batch while receipts are in batch.
    /// @notice Receipts are burned.
    /// @param receiptIds Receipt NFTs ids.
    /// @dev Only callable by user wallets.
    function withdraw(address receiptOwner, uint256[] calldata receiptIds, uint256 _currentCycleId)
        public
        onlyStrategyRouter
        sphereXGuardPublic(23, 0x8db77731)
        returns (uint256[] memory _receiptIds, address[] memory _tokens, uint256[] memory _withdrawnTokenAmounts)
    {
        // withdrawn tokens/amounts will be sent in event. due to solidity design can't do token=>amount array
        address[] memory tokens = new address[](receiptIds.length);
        uint256[] memory withdrawnTokenAmounts = new uint256[](receiptIds.length);

        for (uint256 i = 0; i < receiptIds.length; i++) {
            uint256 receiptId = receiptIds[i];
            if (receiptContract.ownerOf(receiptId) != receiptOwner) revert NotReceiptOwner();

            ReceiptNFT.ReceiptData memory receipt = receiptContract.getReceipt(receiptId);

            // only for receipts in current batch
            if (receipt.cycleId != _currentCycleId) revert CycleClosed();

            uint256 transferAmount = fromUniform(receipt.tokenAmountUniform, receipt.token);
            IERC20(receipt.token).safeTransfer(receiptOwner, transferAmount);
            receiptContract.burn(receiptId);

            tokens[i] = receipt.token;
            withdrawnTokenAmounts[i] = transferAmount;
        }
        return (receiptIds, tokens, withdrawnTokenAmounts);
    }

    /// @notice Deposit token into batch.
    /// @notice Tokens not deposited into strategies immediately.
    /// @param depositToken Supported token to deposit.
    /// @param amount Amount to deposit.
    /// @dev Returns deposited token amount and taken fee amount.
    /// @dev User should approve `amount` of `depositToken` to this contract.
    /// @dev Only callable by user wallets.
    function deposit(address depositor, address depositToken, uint256 amount, uint256 _currentCycleId)
        external
        onlyStrategyRouter
        sphereXGuardExternal(16)
        returns (uint256 depositAmount, uint256 depositFeeAmount)
    {
        if (!supportsToken(depositToken)) revert UnsupportedToken();

        depositFeeAmount = getDepositFeeInTokens(amount, depositToken);

        // set actual deposit amount depending on fee amount
        if (depositFeeAmount != 0) depositAmount = amount - depositFeeAmount;
        else depositAmount = amount;

        uint256 depositAmountUniform = toUniform(depositAmount, depositToken);

        receiptContract.mint(_currentCycleId, depositAmountUniform, depositToken, depositor);
    }

    function transfer(address token, address to, uint256 amount) external onlyStrategyRouter sphereXGuardExternal(22) {
        IERC20(token).safeTransfer(to, amount);
    }

    // Admin functions

    function rebalance(
        StrategyRouter.TokenPrice[] calldata supportedTokenPrices,
        StrategyRouter.StrategyInfo[] calldata strategies,
        uint256 remainingToAllocateStrategiesWeightSum,
        StrategyRouter.IdleStrategyInfo[] calldata idleStrategies
    ) public onlyStrategyRouter sphereXGuardPublic(18, 0x447ff4a1) {
        uint256[] memory balancesPendingAllocationToStrategy;
        TokenInfo[] memory tokenInfos;

        (balancesPendingAllocationToStrategy, tokenInfos) =
            _rebalanceNoAllocation(supportedTokenPrices, strategies, remainingToAllocateStrategiesWeightSum);

        for (uint256 i; i < strategies.length; i++) {
            if (balancesPendingAllocationToStrategy[i] > 0) {
                IERC20(strategies[i].depositToken).safeTransfer(
                    strategies[i].strategyAddress, balancesPendingAllocationToStrategy[i]
                );
                IStrategy(strategies[i].strategyAddress).deposit(balancesPendingAllocationToStrategy[i]);
            }
        }

        for (uint256 i; i < tokenInfos.length; i++) {
            uint256 supportedTokenBalance = tokenInfos[i].balance;
            if (supportedTokenBalance > 0) {
                IERC20(idleStrategies[i].depositToken).safeTransfer(
                    idleStrategies[i].strategyAddress, supportedTokenBalance
                );
                IIdleStrategy(idleStrategies[i].strategyAddress).deposit(supportedTokenBalance);
            }
        }
    }

    function _rebalanceNoAllocation(
        StrategyRouter.TokenPrice[] calldata supportedTokenPrices,
        StrategyRouter.StrategyInfo[] memory strategies,
        uint256 remainingToAllocateStrategiesWeightSum
    )
        internal
        sphereXGuardInternal(13)
        returns (uint256[] memory balancesPendingAllocationToStrategy, TokenInfo[] memory tokenInfos)
    {
        uint256 totalBatchUnallocatedTokens;

        // point 1
        tokenInfos = new TokenInfo[](supportedTokenPrices.length);

        // point 2
        for (uint256 i; i < tokenInfos.length; i++) {
            tokenInfos[i].tokenAddress = supportedTokenPrices[i].token;
            tokenInfos[i].balance = IERC20(tokenInfos[i].tokenAddress).balanceOf(address(this));

            uint256 tokenBalanceUniform = toUniform(tokenInfos[i].balance, tokenInfos[i].tokenAddress);

            // point 3
            if (tokenBalanceUniform > REBALANCE_SWAP_THRESHOLD) {
                totalBatchUnallocatedTokens += tokenBalanceUniform;
            } else {
                tokenInfos[i].insufficientBalance = true;
            }
        }

        balancesPendingAllocationToStrategy = new uint256[](strategies.length);
        CapacityData[] memory capacityData = new CapacityData[](strategies.length);
        // first traversal over strategies
        // 1. try to allocate funds to a strategy if a batch has balance in strategy's deposit token
        // that minimises swaps between tokens – prefer to put a token to strategy that natively support it
        for (uint256 i; i < strategies.length; i++) {
            // necessary check in assumption that some strategies could have 0 weight
            if (remainingToAllocateStrategiesWeightSum == 0) {
                break;
            }

            (capacityData[i].isLimitReached, capacityData[i].underflowUniform,) =
                IStrategy(strategies[i].strategyAddress).getCapacityData();
            capacityData[i].underflowUniform = toUniform(capacityData[i].underflowUniform, strategies[i].depositToken);

            if (capacityData[i].isLimitReached || capacityData[i].underflowUniform <= REBALANCE_SWAP_THRESHOLD) {
                remainingToAllocateStrategiesWeightSum -= strategies[i].weight;
                strategies[i].weight = 0;

                continue;
            }

            uint256 desiredStrategyBalanceUniform =
                (totalBatchUnallocatedTokens * strategies[i].weight) / remainingToAllocateStrategiesWeightSum;

            if (desiredStrategyBalanceUniform > capacityData[i].underflowUniform) {
                desiredStrategyBalanceUniform = capacityData[i].underflowUniform;
            }

            // nothing to deposit to this strategy
            if (desiredStrategyBalanceUniform <= REBALANCE_SWAP_THRESHOLD) {
                continue;
            }

            if (tokenInfos[strategies[i].depositTokenInSupportedTokensIndex].insufficientBalance) {
                continue;
            }

            uint256 batchTokenBalanceUniform = toUniform(
                tokenInfos[strategies[i].depositTokenInSupportedTokensIndex].balance, strategies[i].depositToken
            );
            // if there anything to allocate to a strategy
            if (batchTokenBalanceUniform >= desiredStrategyBalanceUniform) {
                // reduce weight of the current strategy in this iteration of rebalance to 0
                remainingToAllocateStrategiesWeightSum -= strategies[i].weight;
                strategies[i].weight = 0;
                // manipulation to avoid dust:
                // if the case remaining balance of token is below allocation threshold –
                // send it to the current strategy
                if (batchTokenBalanceUniform - desiredStrategyBalanceUniform <= REBALANCE_SWAP_THRESHOLD) {
                    totalBatchUnallocatedTokens -= batchTokenBalanceUniform;
                    balancesPendingAllocationToStrategy[i] +=
                        tokenInfos[strategies[i].depositTokenInSupportedTokensIndex].balance;
                    tokenInfos[strategies[i].depositTokenInSupportedTokensIndex].balance = 0;
                    tokenInfos[strategies[i].depositTokenInSupportedTokensIndex].insufficientBalance = true;
                } else {
                    uint256 desiredStrategyBalance =
                        fromUniform(desiredStrategyBalanceUniform, strategies[i].depositToken);
                    totalBatchUnallocatedTokens -= toUniform(desiredStrategyBalance, strategies[i].depositToken);
                    tokenInfos[strategies[i].depositTokenInSupportedTokensIndex].balance -= desiredStrategyBalance;
                    balancesPendingAllocationToStrategy[i] += desiredStrategyBalance;
                }
            } else {
                // reduce strategy weight in the current rebalance iteration proportionally to the degree
                // at which the strategy's desired balance was saturated
                // For example: if a strategy's weight is 10,000 and the total weight is 100,000
                // and the strategy's desired balance was saturated by 80%
                // we reduce the strategy weight by 80%
                // strategy weight = 10,000 - 80% * 10,000 = 2,000
                // total strategy weight = 100,000 - 80% * 10,000 = 92,000
                uint256 unfulfilledStrategyTokens = desiredStrategyBalanceUniform - batchTokenBalanceUniform;
                totalBatchUnallocatedTokens -= batchTokenBalanceUniform;
                capacityData[i].underflowUniform -= batchTokenBalanceUniform;

                remainingToAllocateStrategiesWeightSum -= strategies[i].weight;

                if (unfulfilledStrategyTokens == totalBatchUnallocatedTokens) {
                    strategies[i].weight = 100;
                } else {
                    strategies[i].weight = (unfulfilledStrategyTokens * remainingToAllocateStrategiesWeightSum)
                        / (totalBatchUnallocatedTokens - unfulfilledStrategyTokens);
                }

                remainingToAllocateStrategiesWeightSum += strategies[i].weight;

                balancesPendingAllocationToStrategy[i] +=
                    tokenInfos[strategies[i].depositTokenInSupportedTokensIndex].balance;
                tokenInfos[strategies[i].depositTokenInSupportedTokensIndex].balance = 0;
                tokenInfos[strategies[i].depositTokenInSupportedTokensIndex].insufficientBalance = true;
            }
        }

        // if everything was rebalanced already then remainingToAllocateStrategiesWeightSum == 0, spare cycles
        if (remainingToAllocateStrategiesWeightSum > 0) {
            for (uint256 i; i < strategies.length; i++) {
                // necessary check as some strategies that go last could saturated on the previous step already
                if (remainingToAllocateStrategiesWeightSum == 0) {
                    break;
                }

                if (capacityData[i].isLimitReached) {
                    continue;
                }

                uint256 desiredStrategyBalanceUniform =
                    (totalBatchUnallocatedTokens * strategies[i].weight) / remainingToAllocateStrategiesWeightSum;
                remainingToAllocateStrategiesWeightSum -= strategies[i].weight;

                if (desiredStrategyBalanceUniform > capacityData[i].underflowUniform) {
                    desiredStrategyBalanceUniform = capacityData[i].underflowUniform;
                }

                if (desiredStrategyBalanceUniform <= REBALANCE_SWAP_THRESHOLD) {
                    continue;
                }

                for (uint256 j; j < tokenInfos.length; j++) {
                    if (j == strategies[i].depositTokenInSupportedTokensIndex) {
                        continue;
                    }

                    if (tokenInfos[j].insufficientBalance) {
                        continue;
                    }

                    uint256 batchTokenBalanceUniform = toUniform(tokenInfos[j].balance, tokenInfos[j].tokenAddress);

                    // is there anything to allocate to a strategy
                    uint256 toSell;
                    if (batchTokenBalanceUniform >= desiredStrategyBalanceUniform) {
                        // manipulation to avoid leaving dust
                        // if the case remaining balance of token is below allocation threshold –
                        // send it to the current strategy
                        if (batchTokenBalanceUniform - desiredStrategyBalanceUniform <= REBALANCE_SWAP_THRESHOLD) {
                            totalBatchUnallocatedTokens -= batchTokenBalanceUniform;
                            toSell = tokenInfos[j].balance;
                            desiredStrategyBalanceUniform = 0;
                            tokenInfos[j].balance = 0;
                            tokenInfos[j].insufficientBalance = true;
                        } else {
                            toSell = fromUniform(desiredStrategyBalanceUniform, tokenInfos[j].tokenAddress);
                            totalBatchUnallocatedTokens -= toUniform(toSell, tokenInfos[j].tokenAddress);
                            desiredStrategyBalanceUniform = 0;
                            tokenInfos[j].balance -= toSell;
                        }
                    } else {
                        totalBatchUnallocatedTokens -= batchTokenBalanceUniform;
                        toSell = tokenInfos[j].balance;
                        desiredStrategyBalanceUniform -= batchTokenBalanceUniform;
                        tokenInfos[j].balance = 0;
                        tokenInfos[j].insufficientBalance = true;
                    }

                    balancesPendingAllocationToStrategy[i] += _trySwap(
                        toSell,
                        tokenInfos[j].tokenAddress,
                        strategies[i].depositToken,
                        supportedTokenPrices[j],
                        supportedTokenPrices[strategies[i].depositTokenInSupportedTokensIndex]
                    );

                    // if remaining desired strategy amount is below the threshold then break the cycle
                    if (desiredStrategyBalanceUniform <= REBALANCE_SWAP_THRESHOLD) {
                        break;
                    }
                }
            }
        }
    }

    /// @notice Set token as supported for user deposit and withdraw.
    /// @dev Admin function.
    function addSupportedToken(address tokenAddress) external onlyStrategyRouter sphereXGuardExternal(15) {
        // attempt to check that token address is valid
        if (!oracle.isTokenSupported(tokenAddress)) {
            revert InvalidToken();
        }
        if (supportsToken(tokenAddress)) revert AlreadySupportedToken();

        supportedTokens.add(tokenAddress);
    }

    /// @notice Remove token as supported for user deposit and withdraw.
    /// @notice It returns whether token was removed from tail
    /// @notice And if not the tail token address and new index were it was moved to
    /// @notice (the way how elements remove from arrays in solidity)
    /// @dev Admin function.
    function removeSupportedToken(address tokenAddress)
        external
        onlyStrategyRouter
        sphereXGuardExternal(19)
        returns (bool wasRemovedFromTail, address formerTailTokenAddress, uint256 newIndexOfFormerTailToken)
    {
        uint256 initialSupportedTokensLength = supportedTokens.length();
        for (uint256 i; i < initialSupportedTokensLength; i++) {
            if (supportedTokens.at(i) == tokenAddress) {
                newIndexOfFormerTailToken = i;
            }
        }

        uint256 strategiesLength = router.getStrategiesCount();
        // don't remove tokens that are in use by active strategies
        for (uint256 i = 0; i < strategiesLength; i++) {
            if (router.getStrategyDepositToken(i) == tokenAddress) {
                revert CantRemoveTokenOfActiveStrategy();
            }
        }

        supportedTokens.remove(tokenAddress);

        // if token was popped from the end no index replacement occurred
        if (newIndexOfFormerTailToken == initialSupportedTokensLength - 1) {
            return (true, address(0), type(uint256).max);
        } else {
            return (false, supportedTokens.at(newIndexOfFormerTailToken), newIndexOfFormerTailToken);
        }
    }

    // Internals

    /// @dev Change decimal places of number from `oldDecimals` to `newDecimals`.
    function changeDecimals(uint256 amount, uint8 oldDecimals, uint8 newDecimals) private pure returns (uint256) {
        if (oldDecimals < newDecimals) {
            return amount * (10 ** (newDecimals - oldDecimals));
        } else if (oldDecimals > newDecimals) {
            return amount / (10 ** (oldDecimals - newDecimals));
        }
        return amount;
    }

    /// @dev Swap tokens if they are different (i.e. not the same token)
    function _trySwap(
        uint256 amountA, // tokenFromAmount
        address tokenA, // tokenFrom
        address tokenB, // tokenTo
        StrategyRouter.TokenPrice memory usdPriceTokenA,
        StrategyRouter.TokenPrice memory usdPriceTokenB
    ) private sphereXGuardInternal(14) returns (uint256 result) {
        if (tokenA != tokenB) {
            IERC20(tokenA).safeTransfer(address(exchange), amountA);
            result = exchange.stablecoinSwap(amountA, tokenA, tokenB, address(this), usdPriceTokenA, usdPriceTokenB);
            return result;
        }
        return amountA;
    }

    /// @dev Change decimal places from token decimals to `UNIFORM_DECIMALS`.
    function toUniform(uint256 amount, address token) private view returns (uint256) {
        return changeDecimals(amount, ERC20(token).decimals(), UNIFORM_DECIMALS);
    }

    /// @dev Convert decimal places from `UNIFORM_DECIMALS` to token decimals.
    function fromUniform(uint256 amount, address token) private view returns (uint256) {
        return changeDecimals(amount, UNIFORM_DECIMALS, ERC20(token).decimals());
    }

    /// @notice calculate deposit fee in USD
    /// @param amountInUsd Amount tokens in USD with `UNIFORM_DECIMALS`.
    /// @dev returns fee amount of tokens in USD.
    function calculateDepositFee(uint256 amountInUsd) internal view returns (uint256 feeAmountInUsd) {
        DepositFeeSettings memory _depositFeeSettings = depositFeeSettings;

        feeAmountInUsd = (amountInUsd * _depositFeeSettings.feeInBps) / MAX_BPS;

        // check ranges and apply needed fee limits
        if (feeAmountInUsd < _depositFeeSettings.minFeeInUsd) feeAmountInUsd = _depositFeeSettings.minFeeInUsd;
        else if (feeAmountInUsd > _depositFeeSettings.maxFeeInUsd) feeAmountInUsd = _depositFeeSettings.maxFeeInUsd;
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (access/AccessControl.sol)

pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/utils/StringsUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/IAccessControlUpgradeable.sol";

import "./ContextUpgradeable.sol";
import "./ERC165Upgradeable.sol";
import "./Initializable.sol";

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
abstract contract AccessControlUpgradeable is
    Initializable,
    ContextUpgradeable,
    IAccessControlUpgradeable,
    ERC165Upgradeable
{
    function __AccessControl_init() internal onlyInitializing sphereXGuardInternal(3) {}

    function __AccessControl_init_unchained() internal onlyInitializing sphereXGuardInternal(4) {}

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
    function grantRole(bytes32 role, address account)
        public
        virtual
        override
        onlyRole(getRoleAdmin(role))
        sphereXGuardPublic(9, 0x2f2ff15d)
    {
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
    function revokeRole(bytes32 role, address account)
        public
        virtual
        override
        onlyRole(getRoleAdmin(role))
        sphereXGuardPublic(11, 0xd547741f)
    {
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
    function renounceRole(bytes32 role, address account) public virtual override sphereXGuardPublic(10, 0x36568abe) {
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
    function _setupRole(bytes32 role, address account) internal virtual sphereXGuardInternal(8) {
        _grantRole(role, account);
    }

    /**
     * @dev Sets `adminRole` as ``role``'s admin role.
     *
     * Emits a {RoleAdminChanged} event.
     */
    function _setRoleAdmin(bytes32 role, bytes32 adminRole) internal virtual sphereXGuardInternal(7) {
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
    function _grantRole(bytes32 role, address account) internal virtual sphereXGuardInternal(5) {
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
    function _revokeRole(bytes32 role, address account) internal virtual sphereXGuardInternal(6) {
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
// OpenZeppelin Contracts (last updated v4.7.0) (utils/Address.sol)

pragma solidity ^0.8.1;

/**
 * @dev Collection of functions related to the address type
 */
library AddressUpgradeable {
    error Address__InsufficientBalance();
    error Address__UnableToSendValue();
    error Address__InsufficientBalanceForCall();
    error Address__CallToNonContract();
    error Address__StaticCallToNonContract();
    error Address__LowLevelCallFailedWithCustomErrorCode(uint errorCode);
    error Address__LowLevelCallFailed();
    error Address__LowLevelCallWithValueFailed();
    error Address__LowLevelStaticCallFailed();

    enum ErrorCodes {
        unknown,
        functionCall,
        functionCallWithValue,
        functionStaticCall,
        functionDelegateCall
    }

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
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        // require(address(this).balance >= amount, "Address: insufficient balance");
        if (!(address(this).balance >= amount)) revert Address__InsufficientBalance();

        (bool success, ) = recipient.call{value: amount}("");
        // require(success, "Address: unable to send value, recipient may have reverted");
        if (!success) revert Address__UnableToSendValue();
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
        // return functionCall(target, data, "Address: low-level call failed");
        return functionCall(target, data, uint(ErrorCodes.functionCall));
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
        uint errorCode
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorCode);
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
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        // return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
        return functionCallWithValue(target, data, value, uint(ErrorCodes.functionCallWithValue));
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
        uint errorCode
    ) internal returns (bytes memory) {
        // require(address(this).balance >= value, "Address: insufficient balance for call");
        // require(isContract(target), "Address: call to non-contract");
        if (!(address(this).balance >= value)) revert Address__InsufficientBalanceForCall();
        if (!(isContract(target))) revert Address__CallToNonContract();

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorCode);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        // return functionStaticCall(target, data, "Address: low-level static call failed");
        return functionStaticCall(target, data, uint(ErrorCodes.functionStaticCall));
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
        uint errorCode
    ) internal view returns (bytes memory) {
        // require(isContract(target), "Address: static call to non-contract");
        if (!(isContract(target))) revert Address__StaticCallToNonContract();

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorCode);
    }

    /**
     * @dev Tool to verifies that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason using the provided one.
     *
     * _Available since v4.3._
     */
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        uint errorCode
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly
                /// @solidity memory-safe-assembly
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                // revert(errorMessage);
                if (errorCode == uint(ErrorCodes.functionCall)) revert Address__LowLevelCallFailed();
                else if (errorCode == uint(ErrorCodes.functionCallWithValue)) revert Address__LowLevelCallWithValueFailed();
                else if (errorCode == uint(ErrorCodes.functionStaticCall)) revert Address__LowLevelStaticCallFailed();
                else revert Address__LowLevelCallFailedWithCustomErrorCode(uint(errorCode));
            }
        }
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;

import "./Initializable.sol";

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
    function __Context_init() internal onlyInitializing sphereXGuardInternal(33) {}

    function __Context_init_unchained() internal onlyInitializing sphereXGuardInternal(34) {}

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
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

library EnumerableSetExtension {
    /// @dev Function will revert if address is not in set.
    function indexOf(EnumerableSet.AddressSet storage set, address value) internal view returns (uint256 index) {
        return set._inner._indexes[bytes32(uint256(uint160(value)))] - 1;
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/introspection/ERC165.sol)

pragma solidity ^0.8.0;

import "./IERC165Upgradeable.sol";
import "./Initializable.sol";

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
    function __ERC165_init() internal onlyInitializing sphereXGuardInternal(46) {}

    function __ERC165_init_unchained() internal onlyInitializing sphereXGuardInternal(48) {}
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
// OpenZeppelin Contracts (last updated v4.5.0) (proxy/ERC1967/ERC1967Upgrade.sol)

pragma solidity ^0.8.2;

import "@openzeppelin/contracts-upgradeable/proxy/beacon/IBeaconUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/interfaces/draft-IERC1822Upgradeable.sol";
import "./AddressUpgradeable.sol";
import "./StorageSlotUpgradeable.sol";
import "./Initializable.sol";

/**
 * @dev This abstract contract provides getters and event emitting update functions for
 * https://eips.ethereum.org/EIPS/eip-1967[EIP1967] slots.
 *
 * _Available since v4.1._
 *
 * @custom:oz-upgrades-unsafe-allow delegatecall
 */
abstract contract ERC1967UpgradeUpgradeable is Initializable {
    error ERC1967_NewImplementationIsNotAContract();
    error ERC1967Upgrade_UnsupportedProxiableUUID();
    error ERC1967Upgrade_NewImplementationIsNotUUPS();
    error ERC1967_NewAdminIsZeroAddress();
    error ERC1967_NewBeaconIsNotAContract();
    error ERC1967_BeaconImplementationIsNotAContract();
    error Address_DelegateCallToNonContract();

    function __ERC1967Upgrade_init() internal onlyInitializing sphereXGuardInternal(51) {}

    function __ERC1967Upgrade_init_unchained() internal onlyInitializing sphereXGuardInternal(53) {}
    // This is the keccak-256 hash of "eip1967.proxy.rollback" subtracted by 1

    bytes32 private constant _ROLLBACK_SLOT = 0x4910fdfa16fed3260ed0e7147f7cc6da11a60208b5b9406d12a635614ffd9143;

    /**
     * @dev Storage slot with the address of the current implementation.
     * This is the keccak-256 hash of "eip1967.proxy.implementation" subtracted by 1, and is
     * validated in the constructor.
     */
    bytes32 internal constant _IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;

    /**
     * @dev Emitted when the implementation is upgraded.
     */
    event Upgraded(address indexed implementation);

    /**
     * @dev Returns the current implementation address.
     */
    function _getImplementation() internal view returns (address) {
        return StorageSlotUpgradeable.getAddressSlot(_IMPLEMENTATION_SLOT).value;
    }

    /**
     * @dev Stores a new address in the EIP1967 implementation slot.
     */
    function _setImplementation(address newImplementation) private sphereXGuardInternal(63) {
        // require(AddressUpgradeable.isContract(newImplementation), "ERC1967: new implementation is not a contract");
        if (!(AddressUpgradeable.isContract(newImplementation))) revert ERC1967_NewImplementationIsNotAContract();
        StorageSlotUpgradeable.getAddressSlot(_IMPLEMENTATION_SLOT).value = newImplementation;
    }

    /**
     * @dev Perform implementation upgrade
     *
     * Emits an {Upgraded} event.
     */
    function _upgradeTo(address newImplementation) internal sphereXGuardInternal(67) {
        _setImplementation(newImplementation);
        emit Upgraded(newImplementation);
    }

    /**
     * @dev Perform implementation upgrade with additional setup call.
     *
     * Emits an {Upgraded} event.
     */
    function _upgradeToAndCall(address newImplementation, bytes memory data, bool forceCall)
        internal
        sphereXGuardInternal(68)
    {
        _upgradeTo(newImplementation);
        if (data.length > 0 || forceCall) {
            _functionDelegateCall(newImplementation, data);
        }
    }

    /**
     * @dev Perform implementation upgrade with security checks for UUPS proxies, and additional setup call.
     *
     * Emits an {Upgraded} event.
     */
    function _upgradeToAndCallUUPS(address newImplementation, bytes memory data, bool forceCall)
        internal
        sphereXGuardInternal(70)
    {
        // Upgrades from old implementations will perform a rollback test. This test requires the new
        // implementation to upgrade back to the old, non-ERC1822 compliant, implementation. Removing
        // this special case will break upgrade paths from old UUPS implementation to new ones.
        if (StorageSlotUpgradeable.getBooleanSlot(_ROLLBACK_SLOT).value) {
            _setImplementation(newImplementation);
        } else {
            try IERC1822ProxiableUpgradeable(newImplementation).proxiableUUID() returns (bytes32 slot) {
                // require(slot == _IMPLEMENTATION_SLOT, "ERC1967Upgrade: unsupported proxiableUUID");
                if (!(slot == _IMPLEMENTATION_SLOT)) revert ERC1967Upgrade_UnsupportedProxiableUUID();
            } catch {
                // revert("ERC1967Upgrade: new implementation is not UUPS");
                revert ERC1967Upgrade_NewImplementationIsNotUUPS();
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
     * @dev Emitted when the admin account has changed.
     */
    event AdminChanged(address previousAdmin, address newAdmin);

    /**
     * @dev Returns the current admin.
     */
    function _getAdmin() internal view returns (address) {
        return StorageSlotUpgradeable.getAddressSlot(_ADMIN_SLOT).value;
    }

    /**
     * @dev Stores a new address in the EIP1967 admin slot.
     */
    function _setAdmin(address newAdmin) private sphereXGuardInternal(59) {
        // require(newAdmin != address(0), "ERC1967: new admin is the zero address");
        if (!(newAdmin != address(0))) revert ERC1967_NewAdminIsZeroAddress();
        StorageSlotUpgradeable.getAddressSlot(_ADMIN_SLOT).value = newAdmin;
    }

    /**
     * @dev Changes the admin of the proxy.
     *
     * Emits an {AdminChanged} event.
     */
    function _changeAdmin(address newAdmin) internal sphereXGuardInternal(55) {
        emit AdminChanged(_getAdmin(), newAdmin);
        _setAdmin(newAdmin);
    }

    /**
     * @dev The storage slot of the UpgradeableBeacon contract which defines the implementation for this proxy.
     * This is bytes32(uint256(keccak256('eip1967.proxy.beacon')) - 1)) and is validated in the constructor.
     */
    bytes32 internal constant _BEACON_SLOT = 0xa3f0ad74e5423aebfd80d3ef4346578335a9a72aeaee59ff6cb3582b35133d50;

    /**
     * @dev Emitted when the beacon is upgraded.
     */
    event BeaconUpgraded(address indexed beacon);

    /**
     * @dev Returns the current beacon.
     */
    function _getBeacon() internal view returns (address) {
        return StorageSlotUpgradeable.getAddressSlot(_BEACON_SLOT).value;
    }

    /**
     * @dev Stores a new beacon in the EIP1967 beacon slot.
     */
    function _setBeacon(address newBeacon) private sphereXGuardInternal(61) {
        // require(AddressUpgradeable.isContract(newBeacon), "ERC1967: new beacon is not a contract");
        // require(
        //     AddressUpgradeable.isContract(IBeaconUpgradeable(newBeacon).implementation()),
        //     "ERC1967: beacon implementation is not a contract"
        // );
        if (!(AddressUpgradeable.isContract(newBeacon))) revert ERC1967_NewBeaconIsNotAContract();
        if (!(AddressUpgradeable.isContract(IBeaconUpgradeable(newBeacon).implementation()))) {
            revert ERC1967_BeaconImplementationIsNotAContract();
        }
        StorageSlotUpgradeable.getAddressSlot(_BEACON_SLOT).value = newBeacon;
    }

    /**
     * @dev Perform beacon upgrade with additional setup call. Note: This upgrades the address of the beacon, it does
     * not upgrade the implementation contained in the beacon (see {UpgradeableBeacon-_setImplementation} for that).
     *
     * Emits a {BeaconUpgraded} event.
     */
    function _upgradeBeaconToAndCall(address newBeacon, bytes memory data, bool forceCall)
        internal
        sphereXGuardInternal(65)
    {
        _setBeacon(newBeacon);
        emit BeaconUpgraded(newBeacon);
        if (data.length > 0 || forceCall) {
            _functionDelegateCall(IBeaconUpgradeable(newBeacon).implementation(), data);
        }
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function _functionDelegateCall(address target, bytes memory data)
        private
        sphereXGuardInternal(57)
        returns (bytes memory)
    {
        // require(AddressUpgradeable.isContract(target), "Address: delegate call to non-contract");
        if (!(AddressUpgradeable.isContract(target))) revert Address_DelegateCallToNonContract();

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return AddressUpgradeable.verifyCallResult(
            success, returndata, uint256(AddressUpgradeable.ErrorCodes.functionDelegateCall)
        );
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
// OpenZeppelin Contracts (last updated v4.7.0) (proxy/utils/Initializable.sol)

pragma solidity ^0.8.2;

import "./AddressUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/SphereXProtected.sol";

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
 * ```
 * contract MyToken is ERC20Upgradeable {
 *     function initialize() initializer public {
 *         __ERC20_init("MyToken", "MTK");
 *     }
 * }
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
abstract contract Initializable is SphereXProtected {
    error Initializable__ContractIsAlreadyInitialized();
    error Initializable__ContractIsNotInitializing();
    error Initializable_ContractIsInitializing();

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
     * `onlyInitializing` functions can be used to initialize parent contracts. Equivalent to `reinitializer(1)`.
     */
    modifier initializer() {
        bool isTopLevelCall = !_initializing;
        // require(
        //     (isTopLevelCall && _initialized < 1) || (!AddressUpgradeable.isContract(address(this)) && _initialized == 1),
        //     "Initializable: contract is already initialized"
        // );
        if (
            !(
                (isTopLevelCall && _initialized < 1)
                    || (!AddressUpgradeable.isContract(address(this)) && _initialized == 1)
            )
        ) {
            revert Initializable__ContractIsAlreadyInitialized();
        }
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
     * `initializer` is equivalent to `reinitializer(1)`, so a reinitializer may be used after the original
     * initialization step. This is essential to configure modules that are added through upgrades and that require
     * initialization.
     *
     * Note that versions can jump in increments greater than 1; this implies that if multiple reinitializers coexist in
     * a contract, executing them in the right order is up to the developer or operator.
     */
    modifier reinitializer(uint8 version) {
        // require(!_initializing && _initialized < version, "Initializable: contract is already initialized");
        if (!(!_initializing && _initialized < version)) revert Initializable__ContractIsAlreadyInitialized();
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
        // require(_initializing, "Initializable: contract is not initializing");
        if (!(_initializing)) revert Initializable__ContractIsNotInitializing();
        _;
    }

    /**
     * @dev Locks the contract, preventing any future reinitialization. This cannot be part of an initializer call.
     * Calling this in the constructor of a contract will prevent that contract from being initialized or reinitialized
     * to any version. It is recommended to use this to lock implementation contracts that are designed to be called
     * through proxies.
     */
    function _disableInitializers() internal virtual sphereXGuardInternal(105) {
        // require(!_initializing, "Initializable: contract is initializing");
        if (!(!_initializing)) revert Initializable_ContractIsInitializing();
        if (_initialized < type(uint8).max) {
            _initialized = type(uint8).max;
            emit Initialized(type(uint8).max);
        }
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

pragma solidity ^0.8.0;

import "./ContextUpgradeable.sol";
import "./Initializable.sol";

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
abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
    error Ownable__CallerIsNotTheOwner();
    error Ownable__NewOwnerIsTheZeroAddress();

    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    function __Ownable_init() internal onlyInitializing sphereXGuardInternal(107) {
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal onlyInitializing sphereXGuardInternal(109) {
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
        // require(owner() == _msgSender(), "Ownable: caller is not the owner");
        if (!(owner() == _msgSender())) revert Ownable__CallerIsNotTheOwner();
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner sphereXGuardPublic(114, 0x715018a6) {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner sphereXGuardPublic(116, 0xf2fde38b) {
        // require(newOwner != address(0), "Ownable: new owner is the zero address");
        if (!(newOwner != address(0))) revert Ownable__NewOwnerIsTheZeroAddress();
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual sphereXGuardInternal(112) {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (utils/StorageSlot.sol)

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
 * ```
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
 * _Available since v4.1 for `address`, `bool`, `bytes32`, and `uint256`._
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
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (proxy/utils/UUPSUpgradeable.sol)

pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/interfaces/draft-IERC1822Upgradeable.sol";
import "./ERC1967UpgradeUpgradeable.sol";
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
    error FunctionMustBeCalledThroughDelegatecall();
    error FunctionMustBeCalledThroughActiveProxy();
    error UUPSUpgradeable__MustNotBeCalledThroughDelegatecall();

    function __UUPSUpgradeable_init() internal onlyInitializing sphereXGuardInternal(158) {}

    function __UUPSUpgradeable_init_unchained() internal onlyInitializing sphereXGuardInternal(160) {}
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
        // require(address(this) != __self, "Function must be called through delegatecall");
        // require(_getImplementation() == __self, "Function must be called through active proxy");
        if (!(address(this) != __self)) revert FunctionMustBeCalledThroughDelegatecall();
        if (!(_getImplementation() == __self)) revert FunctionMustBeCalledThroughActiveProxy();
        _;
    }

    /**
     * @dev Check that the execution is not being performed through a delegate call. This allows a function to be
     * callable on the implementing contract but not through proxies.
     */
    modifier notDelegated() {
        // require(address(this) == __self, "UUPSUpgradeable: must not be called through delegatecall");
        if (!(address(this) == __self)) revert UUPSUpgradeable__MustNotBeCalledThroughDelegatecall();
        _;
    }

    /**
     * @dev Implementation of the ERC1822 {proxiableUUID} function. This returns the storage slot used by the
     * implementation. It is used to validate that the this implementation remains valid after an upgrade.
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
     */
    function upgradeTo(address newImplementation) external virtual onlyProxy sphereXGuardExternal(163) {
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
     */
    function upgradeToAndCall(address newImplementation, bytes memory data)
        external
        payable
        virtual
        onlyProxy
        sphereXGuardExternal(165)
    {
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
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "../interfaces/IAlgebraRouter.sol";
import "../interfaces/IAlgebraFactory.sol";
import "../interfaces/IAlgebraPool.sol";
import "../interfaces/IExchangePlugin.sol";

contract AlgebraPlugin is IExchangePlugin, Ownable {
    error CanNotSetIdenticalMediatorToken();

    // whether swap for the pair should be done through some ERC20-like token as intermediary
    mapping(address => mapping(address => address)) public mediatorTokens;

    IAlgebraRouter immutable algebraRouter;
    IAlgebraFactory immutable algebraFactory;

    uint256 private constant FEE_PERCENT_DENOMINATOR = 1e18;
    uint256 private constant POOL_FEE_DENOMINATOR = 1e6;

    constructor(
        IAlgebraRouter _algebraRouter,
        IAlgebraFactory _algebraFactory
    ) {
        algebraRouter = IAlgebraRouter(_algebraRouter);
        algebraFactory = IAlgebraFactory(_algebraFactory);
    }

    function setMediatorTokenForPair(
        address _mediatorToken, // set zero address to disable mediatorToken for a pair
        address[2] calldata pair
    ) external onlyOwner {
        (address token0, address token1) = sortTokens(pair[0], pair[1]);
        if (token0 == _mediatorToken || token1 == _mediatorToken) revert CanNotSetIdenticalMediatorToken();
        mediatorTokens[token0][token1] = _mediatorToken;
    }

    function getPathForTokenPair(address tokenA, address tokenB) public view returns (bytes memory pairPath) {
        (address token0, address token1) = sortTokens(tokenA, tokenB);
        address mediatorToken = mediatorTokens[token0][token1];

        if (mediatorToken != address(0)) return abi.encodePacked(tokenA, mediatorToken, tokenB);
        else return abi.encodePacked(tokenA, tokenB);
    }

    function swap(
        uint256 amountA,
        address tokenA,
        address tokenB,
        address to,
        uint256 minAmountOut
    ) public override returns (uint256 amountReceivedTokenB) {
        if (amountA == 0) return 0;
        bytes memory pairPath = getPathForTokenPair(tokenA, tokenB);

        IERC20(tokenA).approve(address(algebraRouter), amountA);

        // Perform the swap on router and get the amount of tokenB received
        amountReceivedTokenB = algebraRouter.exactInput(IAlgebraRouter.ExactInputParams({
            path: pairPath,
            recipient: to,
            deadline: block.timestamp,
            amountIn: amountA,
            amountOutMinimum: minAmountOut
        }));
    }

    function getExchangeProtocolFee(address tokenA, address tokenB) public view override returns (uint256 feePercent) {
        (address token0, address token1) = sortTokens(tokenA, tokenB);
        address mediatorToken = mediatorTokens[token0][token1];

        if (mediatorToken != address(0)) {
            IAlgebraPool poolAM = IAlgebraPool(algebraFactory.poolByPair(tokenA, mediatorToken));
            ( , , uint16 feeAM, , , , ) = poolAM.globalState();
            IAlgebraPool poolMB = IAlgebraPool(algebraFactory.poolByPair(mediatorToken, tokenB));
            ( , , uint16 feeMB, , , , ) = poolMB.globalState();

            return calculateFeePercentWithMediatorToken(feeAM, feeMB);
        } else {
            IAlgebraPool pool = IAlgebraPool(algebraFactory.poolByPair(tokenA, tokenB));
            ( , , uint16 fee, , , , ) = pool.globalState();

            return fee * FEE_PERCENT_DENOMINATOR / POOL_FEE_DENOMINATOR;
        }
    }

    function sortTokens(address tokenA, address tokenB) internal pure returns (address token0, address token1) {
        (token0, token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
    }

    /// @dev calculate fee percents 100% - (100% - feePercentAM) * (100% - feePercentMB) / 100%
    function calculateFeePercentWithMediatorToken(
        uint16 feeAM,
        uint16 feeMB
    ) internal pure returns (uint256 feePercent) {
        uint256 feePercentAM = feeAM * FEE_PERCENT_DENOMINATOR / POOL_FEE_DENOMINATOR;
        uint256 feePercentMB = feeMB * FEE_PERCENT_DENOMINATOR / POOL_FEE_DENOMINATOR;

        feePercent = FEE_PERCENT_DENOMINATOR -
            (FEE_PERCENT_DENOMINATOR - feePercentAM)
            * (FEE_PERCENT_DENOMINATOR - feePercentMB)
            / FEE_PERCENT_DENOMINATOR;
    }
}
//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;
import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";
import "../interfaces/ICurvePool.sol";
import "../interfaces/IExchangePlugin.sol";
import {StrategyRouter} from "../StrategyRouter.sol";
import {toUniform, fromUniform, MAX_BPS} from "../lib/Math.sol";

contract Exchange is UUPSUpgradeable, OwnableUpgradeable {
    using SafeERC20Upgradeable for IERC20Upgradeable;

    error RoutedSwapFailed();
    error RouteNotFound();
    error NewValueIsAboveMaxBps();

    struct RouteParams {
        // default exchange to use, could have low slippage but also lower liquidity
        address defaultRoute;
        // whenever input amount is over limit, then should use secondRoute
        uint256 limit;
        // second exchange, could have higher slippage but also higher liquidity
        address secondRoute;
    }

    // which plugin to use for swap for this pair
    // tokenA -> tokenB -> RouteParams
    mapping(address => mapping(address => RouteParams)) public routes;

    uint256 public constant MAX_STABLECOIN_SLIPPAGE_IN_BPS = 1000;
    uint256 public constant LIMIT_PRECISION = 1e12;
    uint256 public maxStablecoinSlippageInBps;

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        // lock implementation
        _disableInitializers();
    }

    function initialize() external initializer {
        __Ownable_init();
        __UUPSUpgradeable_init();
    }

    function _authorizeUpgrade(address newImplementation) internal override onlyOwner {}

    function setMaxStablecoinSlippageInBps(uint256 newMaxSlippage) external onlyOwner {
        if (newMaxSlippage > MAX_STABLECOIN_SLIPPAGE_IN_BPS) revert NewValueIsAboveMaxBps();
        maxStablecoinSlippageInBps = newMaxSlippage;
    }

    /// @notice Choose plugin where pair of tokens should be swapped.
    function setRoute(
        address[] calldata tokensA,
        address[] calldata tokensB,
        address[] calldata plugin
    ) external onlyOwner {
        for (uint256 i = 0; i < tokensA.length; i++) {
            (address token0, address token1) = sortTokens(tokensA[i], tokensB[i]);
            routes[token0][token1].defaultRoute = plugin[i];
        }
    }

    function setRouteEx(
        address[] calldata tokensA,
        address[] calldata tokensB,
        RouteParams[] calldata _routes
    ) external onlyOwner {
        for (uint256 i = 0; i < tokensA.length; i++) {
            (address token0, address token1) = sortTokens(tokensA[i], tokensB[i]);
            routes[token0][token1] = _routes[i];
        }
    }

    function getPlugin(uint256 amountA, address tokenA, address tokenB) public view returns (address plugin) {
        (address token0, address token1) = sortTokens(tokenA, tokenB);
        uint256 limit = routes[token0][token1].limit;
        // decimals: 12 + tokenA.decimals - 12 = tokenA.decimals
        uint256 limitWithDecimalsOfTokenA = (limit * 10 ** ERC20(tokenA).decimals()) / LIMIT_PRECISION;
        if (limit == 0 || amountA < limitWithDecimalsOfTokenA) plugin = routes[token0][token1].defaultRoute;
        else plugin = routes[token0][token1].secondRoute;
        if (plugin == address(0)) revert RouteNotFound();
        return plugin;
    }

    function getExchangeProtocolFee(
        uint256 amountA,
        address tokenA,
        address tokenB
    ) public view returns (uint256 feePercent) {
        address plugin = getPlugin(amountA, address(tokenA), address(tokenB));
        return IExchangePlugin(plugin).getExchangeProtocolFee(tokenA, tokenB);
    }

    function stablecoinSwap(
        uint256 amountA,
        address tokenA,
        address tokenB,
        address to,
        StrategyRouter.TokenPrice calldata usdPriceTokenA,
        StrategyRouter.TokenPrice calldata usdPriceTokenB
    ) public returns (uint256 amountReceived) {
        address plugin = getPlugin(amountA, address(tokenA), address(tokenB));
        uint256 minAmountOut = calculateMinAmountOut(amountA, tokenA, tokenB, usdPriceTokenA, usdPriceTokenB);
        IERC20Upgradeable(tokenA).safeTransfer(plugin, amountA);
        amountReceived = IExchangePlugin(plugin).swap(amountA, tokenA, tokenB, to, minAmountOut);
        if (amountReceived == 0) revert RoutedSwapFailed();
    }

    function protectedSwap(
        uint256 amountA,
        address tokenA,
        address tokenB,
        address to,
        StrategyRouter.TokenPrice calldata usdPriceTokenA,
        StrategyRouter.TokenPrice calldata usdPriceTokenB
    ) public returns (uint256 amountReceived) {
        return stablecoinSwap(amountA, tokenA, tokenB, to, usdPriceTokenA, usdPriceTokenB);
    }

    function swap(uint256 amountA, address tokenA, address tokenB, address to) public returns (uint256 amountReceived) {
        address plugin = getPlugin(amountA, address(tokenA), address(tokenB));
        IERC20Upgradeable(tokenA).safeTransfer(plugin, amountA);
        amountReceived = IExchangePlugin(plugin).swap(amountA, tokenA, tokenB, to, 0);
        if (amountReceived == 0) revert RoutedSwapFailed();
    }

    function sortTokens(address tokenA, address tokenB) internal pure returns (address token0, address token1) {
        (token0, token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
    }

    function calculateMinAmountOut(
        uint256 amountA,
        address tokenA,
        address tokenB,
        StrategyRouter.TokenPrice calldata usdPriceTokenA,
        StrategyRouter.TokenPrice calldata usdPriceTokenB
    ) private view returns (uint256 minAmountOut) {
        uint256 amountAInUsd = (toUniform(amountA, tokenA) * usdPriceTokenA.price) / 10 ** usdPriceTokenA.priceDecimals;
        minAmountOut = (amountAInUsd * 10 ** usdPriceTokenB.priceDecimals) / usdPriceTokenB.price;
        minAmountOut = (minAmountOut * (1e18 - getExchangeProtocolFee(amountA, tokenA, tokenB))) / 1e18;
        minAmountOut = (minAmountOut * (MAX_BPS - maxStablecoinSlippageInBps)) / MAX_BPS;
        minAmountOut = fromUniform(minAmountOut, tokenB);
    }
}
//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "../interfaces/IIdleStrategy.sol";
import "../StrategyRouter.sol";
import "../deps/Initializable.sol";
import "../deps/UUPSUpgradeable.sol";
import "../deps/OwnableUpgradeable.sol";
import "../deps/AccessControlUpgradeable.sol";

import "hardhat/console.sol";

/// @custom:oz-upgrades-unsafe-allow constructor state-variable-immutable
contract DefaultIdleStrategy is Initializable, UUPSUpgradeable, OwnableUpgradeable, AccessControlUpgradeable, IIdleStrategy {
    using SafeERC20 for IERC20;

    error CallerUpgrader();
    error NotAllAssetsWithdrawn();
    error OnlyDepositorsAllowedToDeposit();

    address internal upgrader;
    address internal moderator;

    IERC20 internal immutable token;
    StrategyRouter internal immutable strategyRouter;

    uint256 private constant DUST_THRESHOLD_UNIFORM = 1e17; // 0.1 USDT/BUSD/USDC in uniform decimals
    uint8 public constant UNIFORM_DECIMALS = 18;

    // Create a new role identifier for the depositor role
    bytes32 public constant DEPOSITOR_ROLE = keccak256("DEPOSITOR_ROLE");

    modifier onlyUpgrader() {
        if (msg.sender != address(upgrader)) revert CallerUpgrader();
        _;
    }

    /// @dev construct is intended to initialize immutables on implementation
    constructor(
        address _strategyRouter,
        IERC20 _token
    ) {
        strategyRouter = StrategyRouter(_strategyRouter);
        token = _token;

        // lock implementation
        _disableInitializers();
    }

    function initialize(address _upgrader, address[] calldata depositors) external initializer {
        __Ownable_init();
        __UUPSUpgradeable_init();
        upgrader = _upgrader;
        _setupRole(DEFAULT_ADMIN_ROLE, owner());
        for (uint256 i; i < depositors.length; i++) {
            _setupRole(DEPOSITOR_ROLE, depositors[i]);
        }
    }

    function setModerator(address _moderator) external onlyOwner {
        moderator = _moderator;
    }

    function _authorizeUpgrade(address newImplementation) internal override onlyUpgrader {}

    /// @notice Token used to deposit to strategy.
    function depositToken() external view override returns (address) {
        return address(token);
    }

    /// @notice Deposit token to strategy.
    function deposit(uint256 amount) external override {
        if (!hasRole(DEPOSITOR_ROLE, _msgSender())) {
            revert OnlyDepositorsAllowedToDeposit();
        }

        uint256 uniformAmount = toUniform(amount, address(token));

        if (uniformAmount < DUST_THRESHOLD_UNIFORM) {
            token.safeTransfer(moderator, amount);
        }
    }

    /// @notice Withdraw tokens from strategy.
    /// @dev Max withdrawable amount is returned by totalTokens.
    function withdraw(uint256 amount) external override onlyOwner returns (uint256 amountWithdrawn) {
        uint256 totalTokens_ = _totalTokens();
        if (totalTokens_ < amount) {
            amount = totalTokens_;
        }
        token.safeTransfer(msg.sender, amount);

        return amount;
    }

    /// @notice Approximated amount of token on the strategy.
    function totalTokens() external view override returns (uint256) {
        uint totalTokens_ = _totalTokens();
        uint256 uniformTotalTokens_ = toUniform(totalTokens_, address(token));

        if (uniformTotalTokens_ < DUST_THRESHOLD_UNIFORM) return 0;
        else return totalTokens_;
    }

    function _totalTokens() internal view returns (uint256) {
        return token.balanceOf(address(this));
    }

    /// @notice Withdraw all tokens from strategy.
    function withdrawAll() external override onlyOwner returns (uint256 amountWithdrawn) {
        amountWithdrawn = token.balanceOf(address(this));
        token.safeTransfer(msg.sender, amountWithdrawn);
        if (_totalTokens() != 0) {
            revert NotAllAssetsWithdrawn();
        }
    }

    // Internals

    /// @dev Change decimal places of number from `oldDecimals` to `newDecimals`.
    function changeDecimals(uint256 amount, uint8 oldDecimals, uint8 newDecimals) private pure returns (uint256) {
        if (oldDecimals < newDecimals) {
            return amount * (10 ** (newDecimals - oldDecimals));
        } else if (oldDecimals > newDecimals) {
            return amount / (10 ** (oldDecimals - newDecimals));
        }
        return amount;
    }

    /// @dev Change decimal places from token decimals to `UNIFORM_DECIMALS`.
    function toUniform(uint256 amount, address _token) private view returns (uint256) {
        return changeDecimals(amount, ERC20(_token).decimals(), UNIFORM_DECIMALS);
    }

    /// @dev Convert decimal places from `UNIFORM_DECIMALS` to token decimals.
    function fromUniform(uint256 amount, address _token) private view returns (uint256) {
        return changeDecimals(amount, UNIFORM_DECIMALS, ERC20(_token).decimals());
    }
}// SPDX-License-Identifier: Unlicense
pragma solidity >=0.5.0;

interface IAlgebraFactory {
    /**
   *  @notice Returns the pool address for a given pair of tokens and a fee, or address 0 if it does not exist
   *  @dev tokenA and tokenB may be passed in either token0/token1 or token1/token0 order
   *  @param tokenA The contract address of either token0 or token1
   *  @param tokenB The contract address of the other token
   *  @return pool The pool address
   */
  function poolByPair(address tokenA, address tokenB) external view returns (address pool);

}// SPDX-License-Identifier: Unlicense
pragma solidity >=0.7.5;

interface IAlgebraPool {
  function globalState() external view returns (
    uint160 price, // The square root of the current price in Q64.96 format
    int24 tick, // The current tick
    uint16 fee, // The current fee in hundredths of a bip, i.e. 1e-6
    uint16 timepointIndex, // The index of the last written timepoint
    uint16 communityFeeToken0, // The community fee represented as a percent of all collected fee in thousandths (1e-3)
    uint16 communityFeeToken1,
    bool unlocked // True if the contract is unlocked, otherwise - false
  );
}// SPDX-License-Identifier: Unlicense
pragma solidity >=0.7.5;

interface IAlgebraRouter {
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

}//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

interface ICurvePool {
  function A (  ) external view returns ( uint256 );
  function A_precise (  ) external view returns ( uint256 );
  function get_virtual_price (  ) external view returns ( uint256 );
  function calc_token_amount ( uint256[2] memory amounts, bool is_deposit ) external view returns ( uint256 );
  function add_liquidity ( uint256[2] memory amounts, uint256 min_mint_amount ) external returns ( uint256 );
  function get_dy ( int128 i, int128 j, uint256 dx ) external view returns ( uint256 );
  function get_dy_underlying ( int128 i, int128 j, uint256 dx ) external view returns ( uint256 );
  function exchange ( int128 i, int128 j, uint256 dx, uint256 min_dy ) external returns ( uint256 );
  function exchange_underlying ( int128 i, int128 j, uint256 dx, uint256 min_dy ) external returns ( uint256 );
  function remove_liquidity ( uint256 _amount, uint256[2] memory min_amounts ) external returns ( uint256[2] memory );
  function remove_liquidity_imbalance ( uint256[2] memory amounts, uint256 max_burn_amount ) external returns ( uint256 );
  function calc_withdraw_one_coin ( uint256 _token_amount, int128 i ) external view returns ( uint256 );
  function remove_liquidity_one_coin ( uint256 _token_amount, int128 i, uint256 _min_amount ) external returns ( uint256 );
  function ramp_A ( uint256 _future_A, uint256 _future_time ) external;
  function stop_ramp_A (  ) external;
  function commit_new_fee ( uint256 new_fee, uint256 new_admin_fee ) external;
  function apply_new_fee (  ) external;
  function revert_new_parameters (  ) external;
  function commit_transfer_ownership ( address _owner ) external;
  function apply_transfer_ownership (  ) external;
  function revert_transfer_ownership (  ) external;
  function admin_balances ( uint256 i ) external view returns ( uint256 );
  function withdraw_admin_fees (  ) external;
  function donate_admin_fees (  ) external;
  function kill_me (  ) external;
  function unkill_me (  ) external;
  function set_admin_fee_address ( address _admin_fee_address ) external;
  function coins ( uint256 arg0 ) external view returns ( address );
  function balances ( uint256 arg0 ) external view returns ( uint256 );
  function fee (  ) external view returns ( uint256 );
  function admin_fee (  ) external view returns ( uint256 );
  function admin_fee_address (  ) external view returns ( address );
  function owner (  ) external view returns ( address );
  function token (  ) external view returns ( address );
  function base_pool (  ) external view returns ( address );
  function base_virtual_price (  ) external view returns ( uint256 );
  function base_cache_updated (  ) external view returns ( uint256 );
  function base_coins ( uint256 arg0 ) external view returns ( address );
  function initial_A (  ) external view returns ( uint256 );
  function future_A (  ) external view returns ( uint256 );
  function initial_A_time (  ) external view returns ( uint256 );
  function future_A_time (  ) external view returns ( uint256 );
  function admin_actions_deadline (  ) external view returns ( uint256 );
  function transfer_ownership_deadline (  ) external view returns ( uint256 );
  function future_fee (  ) external view returns ( uint256 );
  function future_admin_fee (  ) external view returns ( uint256 );
  function future_owner (  ) external view returns ( address );
}
//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";
import {StrategyRouter} from "../StrategyRouter.sol";

// import "hardhat/console.sol";

interface IExchangePlugin {

    error ReceivedTooLittleTokenB();
    
    function swap(
        uint256 amountA,
        address tokenA,
        address tokenB,
        address to,
        uint256 minAmountOut
    ) external returns (uint256 amountReceivedTokenB);

    /// @notice Returns percent taken by DEX on which we swap provided tokens.
    /// @dev Fee percent has 18 decimals, e.g. 100% = 10**18
    function getExchangeProtocolFee(address tokenA, address tokenB)
        external
        view
        returns (uint256 feePercent);

}
//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

interface IIdleStrategy {

    /// @notice Token used to deposit to strategy.
    function depositToken() external view returns (address);

    /// @notice Deposit token to strategy.
    function deposit(uint256 amount) external;

    /// @notice Withdraw tokens from strategy.
    /// @dev Max withdrawable amount is returned by totalTokens.
    function withdraw(uint256 amount) external returns (uint256 amountWithdrawn);

    /// @notice Approximated amount of token on the strategy.
    function totalTokens() external view returns (uint256);

    /// @notice Withdraw all tokens from strategy.
    function withdrawAll() external returns (uint256 amountWithdrawn);
}//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;


interface IStrategy {


    /// @notice Token used to deposit to strategy.
    function depositToken() external view returns (address);

    /// @notice Deposit token to strategy.
    function deposit(uint256 amount) external;

    /// @notice Withdraw tokens from strategy.
    /// @dev Max withdrawable amount is returned by totalTokens.
    function withdraw(uint256 amount) external returns (uint256 amountWithdrawn);

    /// @notice Harvest rewards and reinvest them.
    function compound() external;

    /// @notice Approximated amount of token on the strategy.
    function totalTokens() external view returns (uint256);

    /// @notice Withdraw all tokens from strategy.
    function withdrawAll() external returns (uint256 amountWithdrawn);

    /// @notice Get hardcap target value
    function getHardcardTargetInToken() view external returns (uint256);

    /// @notice Set allowed deviation from target value
    function getHardcardDeviationInBps() view external returns (uint16);

    /// @notice Get data on satisfying hard limits
    function getCapacityData() view external returns (bool limitReached, uint256 underflow, uint256 overflow);
}//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

interface IUsdOracle {
    function isTokenSupported(address base)
        external
        view
        returns (bool isTokenSupported);

    /// @notice Get usd value of token `base`.
    function getTokenUsdPrice(address base)
        external
        view
        returns (uint256 price, uint8 decimals);
}
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

uint8 constant UNIFORM_DECIMALS = 18;
uint256 constant MAX_BPS = 10000;

library ClipMath {
    error DivByZero();

    function divCeil(uint256 _a, uint256 _b) internal pure returns (uint256 c) {
        if (_b == 0) revert DivByZero();
        c = _a / _b;
        if (_a % _b != 0) {
            c = c + 1;
        }
    }
}

/// @dev Change decimal places to `UNIFORM_DECIMALS`.
function toUniform(uint256 amount, address token) view returns (uint256) {
    return changeDecimals(amount, ERC20(token).decimals(), UNIFORM_DECIMALS);
}

/// @dev Convert decimal places from `UNIFORM_DECIMALS` to token decimals.
function fromUniform(uint256 amount, address token) view returns (uint256) {
    return changeDecimals(amount, UNIFORM_DECIMALS, ERC20(token).decimals());
}

/// @dev Change decimal places of number from `oldDecimals` to `newDecimals`.
function changeDecimals(uint256 amount, uint8 oldDecimals, uint8 newDecimals) pure returns (uint256) {
    if (oldDecimals < newDecimals) {
        return amount * (10 ** (newDecimals - oldDecimals));
    } else if (oldDecimals > newDecimals) {
        return amount / (10 ** (oldDecimals - newDecimals));
    }
    return amount;
}
//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract ReceiptNFT is ERC721Upgradeable, UUPSUpgradeable, OwnableUpgradeable {
    using Strings for uint256;

    event SetAmount(uint256 indexed receiptId, uint256 amount);

    error NonExistingToken();
    error ReceiptAmountCanOnlyDecrease();
    error NotManager();
    /// Invalid query range (`start` >= `stop`).
    error InvalidQueryRange();

    event BaseURISet(string newBaseURI, bool isDynamicURI);

    struct ReceiptData {
        uint256 cycleId;
        uint256 tokenAmountUniform; // in token
        address token;
    }

    uint256 private _receiptsCounter;

    mapping(uint256 => ReceiptData) public receipts;
    mapping(address => bool) public managers;

    string public uri;
    bool public dynamicURI;

    modifier onlyManager() {
        if (managers[msg.sender] == false) revert NotManager();
        _;
    }

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        // lock implementation
        _disableInitializers();
    }

    function initialize(address strategyRouter, address batch, string memory link, bool isDynamic)
        external
        initializer
        sphereXGuardExternal(119)
    {
        __SphereXProtected_init();
        __Ownable_init();
        __UUPSUpgradeable_init();
        __ERC721_init("Receipt NFT", "RECEIPT");

        setBaseURI(link, isDynamic);

        managers[strategyRouter] = true;
        managers[batch] = true;
    }

    function _authorizeUpgrade(address newImplementation) internal override onlyOwner sphereXGuardInternal(117) {}

    function setAmount(uint256 receiptId, uint256 amount) external onlyManager sphereXGuardExternal(121) {
        if (!_exists(receiptId)) revert NonExistingToken();
        if (receipts[receiptId].tokenAmountUniform < amount) revert ReceiptAmountCanOnlyDecrease();
        receipts[receiptId].tokenAmountUniform = amount;
        emit SetAmount(receiptId, amount);
    }

    function mint(uint256 cycleId, uint256 amount, address token, address wallet)
        external
        onlyManager
        sphereXGuardExternal(120)
    {
        uint256 _receiptId = _receiptsCounter;
        receipts[_receiptId] = ReceiptData({cycleId: cycleId, token: token, tokenAmountUniform: amount});
        _mint(wallet, _receiptId);
        _receiptsCounter++;
    }

    function burn(uint256 receiptId) external onlyManager sphereXGuardExternal(118) {
        if (!_exists(receiptId)) revert NonExistingToken();
        _burn(receiptId);
        delete receipts[receiptId];
    }

    /// @notice Get receipt data recorded in NFT.
    function getReceipt(uint256 receiptId) external view returns (ReceiptData memory) {
        if (_exists(receiptId) == false) revert NonExistingToken();
        return receipts[receiptId];
    }

    /**
     * @dev Returns an array of token IDs owned by `owner`,
     * in the range [`start`, `stop`].
     *
     * This function allows for tokens to be queried if the collection
     * grows too big for a single call of {ReceiptNFT-getTokensOfOwner}.
     *
     * Requirements:
     *
     * - `start <= receiptId < stop`
     */
    function getTokensOfOwnerIn(address owner, uint256 start, uint256 stop)
        public
        view
        returns (uint256[] memory receiptIds)
    {
        unchecked {
            if (start >= stop) revert InvalidQueryRange();
            uint256 receiptIdsIdx;
            uint256 stopLimit = _receiptsCounter;
            // Set `stop = min(stop, stopLimit)`.
            if (stop > stopLimit) {
                // At this point `start` could be greater than `stop`.
                stop = stopLimit;
            }
            uint256 receiptIdsMaxLength = balanceOf(owner);
            // Set `receiptIdsMaxLength = min(balanceOf(owner), stop - start)`,
            // to cater for cases where `balanceOf(owner)` is too big.
            if (start < stop) {
                uint256 rangeLength = stop - start;
                if (rangeLength < receiptIdsMaxLength) {
                    receiptIdsMaxLength = rangeLength;
                }
            } else {
                receiptIdsMaxLength = 0;
            }
            receiptIds = new uint256[](receiptIdsMaxLength);
            if (receiptIdsMaxLength == 0) {
                return receiptIds;
            }

            // We want to scan tokens in range [start <= receiptId < stop].
            // And if whole range is owned by user or when receiptIdsMaxLength is less than range,
            // then we also want to exit loop when array is full.
            uint256 receiptId = start;
            while (receiptId != stop && receiptIdsIdx != receiptIdsMaxLength) {
                if (_exists(receiptId) && ownerOf(receiptId) == owner) {
                    receiptIds[receiptIdsIdx++] = receiptId;
                }
                receiptId++;
            }

            // If after scan we haven't filled array, then downsize the array to fit.
            assembly {
                mstore(receiptIds, receiptIdsIdx)
            }
            return receiptIds;
        }
    }

    /**
     * @dev Returns an array of token IDs owned by `owner`.
     *
     * This function scans the ownership mapping and is O(totalSupply) in complexity.
     * It is meant to be called off-chain.
     *
     * See {ReceiptNFT-getTokensOfOwnerIn} for splitting the scan into
     * multiple smaller scans if the collection is large enough to cause
     * an out-of-gas error.
     */
    function getTokensOfOwner(address owner) public view returns (uint256[] memory receiptIds) {
        uint256 balance = balanceOf(owner);
        receiptIds = new uint256[](balance);
        uint256 receiptId;

        while (balance > 0) {
            if (_exists(receiptId) && ownerOf(receiptId) == owner) {
                receiptIds[--balance] = receiptId;
            }
            receiptId++;
        }
    }

    function tokenURI(uint256 receiptId) public view virtual override returns (string memory) {
        if (!_exists(receiptId)) revert NonExistingToken();

        return dynamicURI != true ? uri : string(abi.encodePacked(uri, receiptId.toString()));
    }

    function setBaseURI(string memory link, bool dynamic) public onlyOwner sphereXGuardPublic(122, 0xb64b21ca) {
        uri = link;
        dynamicURI = dynamic;
        emit BaseURISet(link, dynamic);
    }
}
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

contract SharesToken is ERC20Upgradeable, UUPSUpgradeable, OwnableUpgradeable {
    error CallerIsNotStrategyRouter();

    address private strategyRouter;

    modifier onlyStrategyRouter() {
        if (msg.sender != strategyRouter) revert CallerIsNotStrategyRouter();
        _;
    }

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        // lock implementation
        _disableInitializers();
    }

    function initialize(address _strategyRouter) external initializer sphereXGuardExternal(125) {
        __SphereXProtected_init();
        __Ownable_init();
        __UUPSUpgradeable_init();
        __ERC20_init("Clip-Finance Shares", "CF");
        strategyRouter = _strategyRouter;
    }

    function _authorizeUpgrade(address newImplementation) internal override onlyOwner sphereXGuardInternal(123) {}

    /// @dev Helper 'transferFrom' function that don't require user approval
    /// @dev Only callable by strategy router.
    function transferFromAutoApproved(address from, address to, uint256 amount)
        external
        onlyStrategyRouter
        sphereXGuardExternal(127)
    {
        _transfer(from, to, amount);
    }

    function mint(address to, uint256 amount) external onlyStrategyRouter sphereXGuardExternal(126) {
        _mint(to, amount);
    }

    function burn(address from, uint256 amount) external onlyStrategyRouter sphereXGuardExternal(124) {
        _burn(from, amount);
    }
}
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@chainlink/contracts/src/v0.8/AutomationCompatible.sol";
import "./deps/Initializable.sol";
import "./deps/UUPSUpgradeable.sol";
import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";
import "./interfaces/IStrategy.sol";
import "./interfaces/IUsdOracle.sol";
import {ReceiptNFT} from "./ReceiptNFT.sol";
import {Exchange} from "./exchange/Exchange.sol";
import {SharesToken} from "./SharesToken.sol";
import "./Batch.sol";
import "./StrategyRouterLib.sol";
import "./idle-strategies/DefaultIdleStrategy.sol";

/// @custom:oz-upgrades-unsafe-allow external-library-linking
contract StrategyRouter is Initializable, UUPSUpgradeable, AutomationCompatibleInterface {
    using SafeERC20 for IERC20;
    /* EVENTS */

    /// @notice Fires when user deposits in batch.
    /// @param token Supported token that user want to deposit.
    /// @param amountAfterFee Amount of `token` transferred from user after fee.
    /// @param feeAmount Amount of `token` fee taken for deposit to the batch.
    /// @param referral Code that is given to individuals who can refer other users
    event Deposit(address indexed user, address token, uint256 amountAfterFee, uint256 feeAmount, string referral);
    /// @notice Fires when batch is deposited into strategies.
    /// @param closedCycleId Index of the cycle that is closed.
    /// @param amount Sum of different tokens deposited into strategies.
    event AllocateToStrategies(uint256 indexed closedCycleId, uint256 amount);
    /// @notice Fires when compound process is finished.
    /// @param currentCycle Index of the current cycle.
    /// @param currentTvlInUsd Current TVL in USD.
    /// @param totalShares Current amount of shares.
    event AfterCompound(uint256 indexed currentCycle, uint256 currentTvlInUsd, uint256 totalShares);
    /// @notice Fires when user withdraw from strategies.
    /// @param token Supported token that user requested to receive after withdraw.
    /// @param amount Amount of `token` received by user.
    event WithdrawFromStrategies(address indexed user, address token, uint256 amount);
    /// @notice Fires when user converts his receipt into shares token.
    /// @param shares Amount of shares received by user.
    /// @param receiptIds Indexes of the receipts burned.
    event RedeemReceiptsToShares(address indexed user, uint256 shares, uint256[] receiptIds);
    /// @notice Fires when moderator converts foreign receipts into shares token.
    /// @param receiptIds Indexes of the receipts burned.
    event RedeemReceiptsToSharesByModerators(address indexed moderator, uint256[] receiptIds);

    /// @notice Fires when user withdraw from batch.
    /// @param user who initiated withdrawal.
    /// @param receiptIds original IDs of the corresponding deposited receipts (NFTs).
    /// @param tokens that is being withdrawn. can be one token multiple times.
    /// @param amounts Amount of respective token from `tokens` received by user.
    event WithdrawFromBatch(address indexed user, uint256[] receiptIds, address[] tokens, uint256[] amounts);

    // Events for setters.
    event SetAllocationWindowTime(uint256 newDuration);
    event SetModeratorAddress(address newAddress);
    event SetAddresses(
        Exchange _exchange,
        IUsdOracle _oracle,
        SharesToken _sharesToken,
        Batch _batch,
        ReceiptNFT _receiptNft
    );

    /* ERRORS */
    error AmountExceedTotalSupply();
    error UnsupportedToken();
    error NotReceiptOwner();
    error CycleNotClosed();
    error CycleClosed();
    error InsufficientShares();
    error DuplicateStrategy();
    error CycleNotClosableYet();
    error AmountNotSpecified();
    error CantRemoveLastStrategy();
    error NothingToRebalance();
    error NotModerator();
    error WithdrawnAmountLowerThanExpectedAmount();
    error InvalidIdleStrategy();
    error InvalidIndexForIdleStrategy();
    error IdleStrategySupportedTokenMismatch();

    struct TokenPrice {
        uint256 price;
        uint8 priceDecimals;
        address token;
    }

    struct StrategyInfo {
        address strategyAddress;
        address depositToken;
        uint256 depositTokenInSupportedTokensIndex;
        uint256 weight;
    }

    struct IdleStrategyInfo {
        address strategyAddress;
        address depositToken;
    }

    struct Cycle {
        // block.timestamp at which cycle started
        uint256 startAt;
        // batch USD value before deposited into strategies
        uint256 totalDepositedInUsd;
        // USD value received by strategies after all swaps necessary to ape into strategies
        uint256 receivedByStrategiesInUsd;
        // Protocol TVL after compound idle strategy and actual deposit to strategies
        uint256 strategiesBalanceWithCompoundAndBatchDepositsInUsd;
        // price per share in USD
        uint256 pricePerShare;
        // tokens price at time of the deposit to strategies
        mapping(address => uint256) prices;
    }

    uint8 private constant UNIFORM_DECIMALS = 18;
    uint256 private constant PRECISION = 1e18;
    uint256 private constant MAX_FEE_PERCENT = 2000;
    uint256 private constant FEE_PERCENT_PRECISION = 100;
    /// @notice Protocol comission in percents taken from yield. One percent is 100.
    uint256 internal constant feePercent = 1200;
    // we do not try to withdraw amount below this threshold
    // cause gas spending are high compared to this amount
    uint256 private constant WITHDRAWAL_DUST_THRESHOLD_USD = 1e17; // 10 cents / 0.1 USD

    /// @notice The time of the first deposit that triggered a current cycle
    uint256 internal currentCycleFirstDepositAt;
    /// @notice Current cycle duration in seconds, until funds are allocated from batch to strategies
    uint256 internal allocationWindowTime;
    /// @notice Current cycle counter. Incremented at the end of the cycle
    uint256 internal currentCycleId;
    /// @notice Current cycle deposits counter. Incremented on deposit and decremented on withdrawal.
    uint256 internal currentCycleDepositsCount;

    ReceiptNFT private receiptContract;
    Exchange internal exchange;
    IUsdOracle private oracle;
    SharesToken private sharesToken;
    Batch internal batch;
    address internal moderator;

    StrategyInfo[] internal strategies;
    uint256 internal allStrategiesWeightSum;

    IdleStrategyInfo[] internal idleStrategies;

    mapping(uint256 => Cycle) internal cycles;
    modifier onlyModerator() {
        if (moderator != msg.sender) revert NotModerator();
        _;
    }

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        // lock implementation
        _disableInitializers();
    }

    function initialize() external initializer sphereXGuardExternal(142) {
        __SphereXProtected_init();
        __UUPSUpgradeable_init();
        moderator = msg.sender;
        cycles[0].startAt = block.timestamp;
        allocationWindowTime = 1 hours;
    }

    function setAddresses(
        Exchange _exchange,
        IUsdOracle _oracle,
        SharesToken _sharesToken,
        Batch _batch,
        ReceiptNFT _receiptNft
    ) external onlyModerator sphereXGuardExternal(148) {
        exchange = _exchange;
        oracle = _oracle;
        sharesToken = _sharesToken;
        batch = _batch;
        receiptContract = _receiptNft;
        emit SetAddresses(_exchange, _oracle, _sharesToken, _batch, _receiptNft);
    }

    function _authorizeUpgrade(address newImplementation) internal override onlyModerator sphereXGuardInternal(136) {}

    // Universal Functions

    /// @notice Send pending money collected in the batch into the strategies.
    /// @notice Can be called when `allocationWindowTime` seconds has been passed or
    ///         batch usd value is more than zero.
    function allocateToStrategies() external sphereXGuardExternal(139) {
        /*
        step 1 - preparing data and assigning local variables for later reference
        step 2 - check requirements to launch a cycle
            condition #1: deposit in the current cycle is greater than zero
        step 3 - store USD price of supported tokens as cycle information
        step 4 - collect yield and re-deposit/re-stake depending on strategy
        step 5 - rebalance token in batch to match our desired strategies ratio
        step 6 - batch transfers funds to strategies and strategies deposit tokens to their respective farms
        step 7 - we calculate share price for the current cycle and calculate a new amount of shares to issue

            Description:

                step 7.1 - Get previous TVL from previous cycle and calculate compounded profit: current TVL
                           minus previous cycle TVL. if current cycle = 0, then TVL = 0
                step 7.2 - Save corrected current TVL in Cycle[strategiesBalanceWithCompoundAndBatchDepositsInUsd] for the next cycle
                step 7.3 - Calculate price per share
                step 7.4 - Mint shares for the new protocol's deposits
                step 7.5 - Mint CLT for Clip's treasure address. CLT amount = fee / price per share

            Case example:

                Previous cycle strategies TVL = 1000 USD and total shares count is 1000 CLT
                Compound yield is 10 USD, hence protocol commission (protocolCommissionInUsd) is 10 USD * 20% = 2 USD
                TLV after compound is 1010 USD. TVL excluding platform's commission is 1008 USD

                Hence protocol commission in shares (protocolCommissionInShares) will be

                (1010 USD * 1000 CLT / (1010 USD - 2 USD)) - 1000 CLT = 1.98412698 CLT

        step 8 - Calculate protocol's commission and withhold commission by issuing share tokens
        step 9 - store remaining information for the current cycle
        */

        // step 1
        StrategyRouter.TokenPrice[] memory supportedTokenPrices = batch.getSupportedTokensWithPriceInUsd();

        (uint256 batchValueInUsd, ) = batch.getBatchValueUsdWithoutOracleCalls(supportedTokenPrices);

        uint256 _currentCycleId = currentCycleId;

        // step 2
        if (batchValueInUsd == 0) revert CycleNotClosableYet();

        currentCycleFirstDepositAt = 0;

        // step 3
        {
            for (uint256 i = 0; i < supportedTokenPrices.length; i++) {
                if (ERC20(supportedTokenPrices[i].token).balanceOf(address(batch)) > 0) {
                    cycles[_currentCycleId].prices[supportedTokenPrices[i].token] = StrategyRouterLib.changeDecimals(
                        supportedTokenPrices[i].price,
                        supportedTokenPrices[i].priceDecimals,
                        UNIFORM_DECIMALS
                    );
                }
            }
        }

        // step 4
        uint256 strategiesLength = strategies.length;
        for (uint256 i; i < strategiesLength; i++) {
            IStrategy(strategies[i].strategyAddress).compound();
        }
        uint256 totalShares = sharesToken.totalSupply();
        (uint256 strategiesBalanceAfterCompoundInUsd, , , , ) = StrategyRouterLib.getStrategiesValueWithoutOracleCalls(
            strategies,
            idleStrategies,
            supportedTokenPrices
        );

        emit AfterCompound(_currentCycleId, strategiesBalanceAfterCompoundInUsd, totalShares);

        // step 5 and step 6
        batch.rebalance(supportedTokenPrices, strategies, allStrategiesWeightSum, idleStrategies);

        // step 7
        (uint256 strategiesBalanceAfterDepositInUsd, , , , ) = StrategyRouterLib.getStrategiesValueWithoutOracleCalls(
            strategies,
            idleStrategies,
            supportedTokenPrices
        );

        uint256 receivedByStrategiesInUsd = strategiesBalanceAfterDepositInUsd - strategiesBalanceAfterCompoundInUsd;

        if (totalShares == 0) {
            sharesToken.mint(address(this), receivedByStrategiesInUsd);
            cycles[_currentCycleId]
                .strategiesBalanceWithCompoundAndBatchDepositsInUsd = strategiesBalanceAfterDepositInUsd;
            cycles[_currentCycleId].pricePerShare =
                (strategiesBalanceAfterDepositInUsd * PRECISION) /
                sharesToken.totalSupply();
        } else {
            // step 7.1
            uint256 protocolCommissionInUsd = 0;
            if (
                strategiesBalanceAfterCompoundInUsd >
                cycles[_currentCycleId - 1].strategiesBalanceWithCompoundAndBatchDepositsInUsd
            ) {
                protocolCommissionInUsd =
                    ((strategiesBalanceAfterCompoundInUsd -
                        cycles[_currentCycleId - 1].strategiesBalanceWithCompoundAndBatchDepositsInUsd) * feePercent) /
                    (100 * FEE_PERCENT_PRECISION);
            }

            // step 7.2
            cycles[_currentCycleId]
                .strategiesBalanceWithCompoundAndBatchDepositsInUsd = strategiesBalanceAfterDepositInUsd;
            // step 7.3
            cycles[_currentCycleId].pricePerShare =
                ((strategiesBalanceAfterCompoundInUsd - protocolCommissionInUsd) * PRECISION) /
                totalShares;

            // step 7.4
            uint256 newShares = (receivedByStrategiesInUsd * PRECISION) / cycles[_currentCycleId].pricePerShare;
            sharesToken.mint(address(this), newShares);

            // step 7.5
            uint256 protocolCommissionInShares = (protocolCommissionInUsd * PRECISION) /
                cycles[_currentCycleId].pricePerShare;
            sharesToken.mint(moderator, protocolCommissionInShares);
        }

        // step 8
        cycles[_currentCycleId].receivedByStrategiesInUsd = receivedByStrategiesInUsd;
        cycles[_currentCycleId].totalDepositedInUsd = batchValueInUsd;

        emit AllocateToStrategies(_currentCycleId, receivedByStrategiesInUsd);

        // step 9
        ++currentCycleId;
        currentCycleDepositsCount = 0;
        cycles[_currentCycleId].startAt = block.timestamp;
    }

    /// @notice Harvest yield from farms, and reinvest these rewards into strategies.
    /// @notice Part of the harvested rewards is taken as protocol comission.
    function compoundAll() public sphereXGuardPublic(140, 0x9b05ddb3) {
        if (sharesToken.totalSupply() == 0) revert();

        uint256 len = strategies.length;
        for (uint256 i; i < len; i++) {
            IStrategy(strategies[i].strategyAddress).compound();
        }

        (uint256 balanceAfterCompoundInUsd, , , , ) = getStrategiesValue();
        uint256 totalShares = sharesToken.totalSupply();
        emit AfterCompound(currentCycleId, balanceAfterCompoundInUsd, totalShares);
    }

    /// @dev Returns list of supported tokens.
    function getSupportedTokens() public view returns (address[] memory) {
        return batch.getSupportedTokens();
    }

    /// @dev Returns strategy weight as percent of total weight.
    function getStrategyPercentWeight(uint256 _strategyId) public view returns (uint256 strategyPercentAllocation) {
        strategyPercentAllocation = (strategies[_strategyId].weight * PRECISION) / allStrategiesWeightSum;
    }

    /// @notice Returns count of strategies.
    function getStrategiesCount() public view returns (uint256 count) {
        return strategies.length;
    }

    /// @notice Returns array of strategies.
    function getStrategies() public view returns (StrategyInfo[] memory, uint256) {
        return (strategies, allStrategiesWeightSum);
    }

    /// @notice Returns array of idle strategies.
    function getIdleStrategies() public view returns (IdleStrategyInfo[] memory) {
        return idleStrategies;
    }

    /// @notice Returns deposit token of the strategy.
    function getStrategyDepositToken(uint256 i) public view returns (address) {
        return strategies[i].depositToken;
    }

    function getBatchValueUsd() public view returns (uint256 totalBalance, uint256[] memory balances) {
        return batch.getBatchValueUsd();
    }

    /// @notice Returns usd value of the token balances and their sum in the strategies.
    /// @notice All returned amounts have `UNIFORM_DECIMALS` decimals.
    /// @return totalBalance Total usd value.
    /// @return totalStrategyBalance Total usd active strategy tvl.
    /// @return totalIdleStrategyBalance Total usd idle strategy tvl.
    /// @return balances Array of usd value of strategy token balances.
    /// @return idleBalances Array of usd value of idle strategy token balances.
    function getStrategiesValue()
        public
        view
        returns (
            uint256 totalBalance,
            uint256 totalStrategyBalance,
            uint256 totalIdleStrategyBalance,
            uint256[] memory balances,
            uint256[] memory idleBalances
        )
    {
        (totalBalance, totalStrategyBalance, totalIdleStrategyBalance, balances, idleBalances) = StrategyRouterLib
            .getStrategiesValue(batch, strategies, idleStrategies);
    }

    /// @notice Returns stored address of the `Exchange` contract.
    function getExchange() public view returns (Exchange) {
        return exchange;
    }

    /// @notice Calculates amount of redeemable shares by burning receipts.
    /// @notice Cycle noted in receipts should be closed.
    function calculateSharesFromReceipts(uint256[] calldata receiptIds) public view returns (uint256 shares) {
        ReceiptNFT _receiptContract = receiptContract;
        uint256 _currentCycleId = currentCycleId;
        for (uint256 i = 0; i < receiptIds.length; i++) {
            uint256 receiptId = receiptIds[i];
            shares += StrategyRouterLib.calculateSharesFromReceipt(
                receiptId,
                _currentCycleId,
                _receiptContract,
                cycles
            );
        }
    }

    /// @notice Reedem shares for receipts on behalf of their owners.
    /// @notice Cycle noted in receipts should be closed.
    /// @notice Only callable by moderators.
    function redeemReceiptsToSharesByModerators(
        uint256[] calldata receiptIds
    ) public onlyModerator sphereXGuardPublic(146, 0xf67a48d2) {
        StrategyRouterLib.redeemReceiptsToSharesByModerators(
            receiptIds,
            currentCycleId,
            receiptContract,
            sharesToken,
            cycles
        );
        emit RedeemReceiptsToSharesByModerators(msg.sender, receiptIds);
    }

    /// @notice Calculate current usd value of shares.
    /// @dev Returned amount has `UNIFORM_DECIMALS` decimals.
    function calculateSharesUsdValue(uint256 amountShares) public view returns (uint256 amountUsd) {
        uint256 totalShares = sharesToken.totalSupply();
        if (amountShares > totalShares) revert AmountExceedTotalSupply();
        (uint256 strategiesLockedUsd, , , , ) = getStrategiesValue();

        uint256 currentPricePerShare = (strategiesLockedUsd * PRECISION) / totalShares;

        return (amountShares * currentPricePerShare) / PRECISION;
    }

    /// @notice Calculate shares amount from usd value.
    /// @dev Returned amount has `UNIFORM_DECIMALS` decimals.
    function calculateSharesAmountFromUsdAmount(uint256 amount) public view returns (uint256 shares) {
        (uint256 strategiesLockedUsd, , , , ) = getStrategiesValue();
        uint256 currentPricePerShare = (strategiesLockedUsd * PRECISION) / sharesToken.totalSupply();
        shares = (amount * PRECISION) / currentPricePerShare;
    }

    /// @notice Returns whether this token is supported.
    /// @param tokenAddress Token address to lookup.
    function supportsToken(address tokenAddress) public view returns (bool isSupported) {
        return batch.supportsToken(tokenAddress);
    }

    // User Functions

    /// @notice Convert receipts into share tokens.
    /// @notice Cycle noted in receipt should be closed.
    /// @return shares Amount of shares redeemed by burning receipts.
    function redeemReceiptsToShares(
        uint256[] calldata receiptIds
    ) public sphereXGuardPublic(145, 0x56c09978) returns (uint256 shares) {
        shares = StrategyRouterLib.burnReceipts(receiptIds, currentCycleId, receiptContract, cycles);
        sharesToken.transfer(msg.sender, shares);
        emit RedeemReceiptsToShares(msg.sender, shares, receiptIds);
    }

    /// @notice Withdraw tokens from strategies.
    /// @notice On partial withdraw leftover shares transferred to user.
    /// @notice If not enough shares unlocked from receipt, or no receipts are passed, then shares will be taken from user.
    /// @notice Receipts are burned.
    /// @notice Cycle noted in receipts should be closed.
    /// @param receiptIds Array of ReceiptNFT ids.
    /// @param withdrawToken Supported token that user wish to receive.
    /// @param shares Amount of shares to withdraw.
    function withdrawFromStrategies(
        uint256[] calldata receiptIds,
        address withdrawToken,
        uint256 shares,
        uint256 minTokenAmountToWithdraw,
        bool performCompound
    ) external sphereXGuardExternal(157) returns (uint256 withdrawnAmount) {
        if (shares == 0) revert AmountNotSpecified();
        uint256 supportedTokenIndex = type(uint256).max;
        address[] memory supportedTokens = getSupportedTokens();
        {
            uint256 supportedTokensLength = supportedTokens.length;
            for (uint256 i; i < supportedTokensLength; i++) {
                if (supportedTokens[i] == withdrawToken) {
                    supportedTokenIndex = i;
                    break;
                }
            }
        }
        if (supportedTokenIndex == type(uint256).max) {
            revert UnsupportedToken();
        }

        ReceiptNFT _receiptContract = receiptContract;
        uint256 _currentCycleId = currentCycleId;
        uint256 unlockedShares;

        // first try to get all shares from receipts
        for (uint256 i = 0; i < receiptIds.length; i++) {
            uint256 receiptId = receiptIds[i];
            if (_receiptContract.ownerOf(receiptId) != msg.sender) revert NotReceiptOwner();
            uint256 receiptShares = StrategyRouterLib.calculateSharesFromReceipt(
                receiptId,
                _currentCycleId,
                _receiptContract,
                cycles
            );
            unlockedShares += receiptShares;
            if (unlockedShares > shares) {
                // receipts fulfilled requested shares and more,
                // so get rid of extra shares and update receipt amount
                uint256 leftoverShares = unlockedShares - shares;
                unlockedShares -= leftoverShares;

                ReceiptNFT.ReceiptData memory receipt = receiptContract.getReceipt(receiptId);
                uint256 newReceiptAmount = (receipt.tokenAmountUniform * leftoverShares) / receiptShares;
                _receiptContract.setAmount(receiptId, newReceiptAmount);
            } else {
                // unlocked shares less or equal to requested, so can take whole receipt amount
                _receiptContract.burn(receiptId);
            }
            if (unlockedShares == shares) break;
        }

        // if receipts didn't fulfill requested shares amount, then try to take more from caller
        if (unlockedShares < shares) {
            // lack of shares -> get from user
            sharesToken.transferFromAutoApproved(msg.sender, address(this), shares - unlockedShares);
        }

        // Compound before calculate shares USD value and withdrawal if requested by user
        if (performCompound) compoundAll();

        // shares into usd using current PPS
        uint256 usdToWithdraw = calculateSharesUsdValue(shares);
        sharesToken.burn(address(this), shares);

        // Withhold withdrawn amount from cycle's TVL, to not to affect AllocateToStrategies calculations in this cycle
        uint256 adjustPreviousCycleStrategiesBalanceByInUsd = (shares * cycles[currentCycleId - 1].pricePerShare) /
            PRECISION;
        cycles[currentCycleId - 1]
            .strategiesBalanceWithCompoundAndBatchDepositsInUsd -= adjustPreviousCycleStrategiesBalanceByInUsd;

        withdrawnAmount = _withdrawFromStrategies(
            usdToWithdraw,
            withdrawToken,
            minTokenAmountToWithdraw,
            supportedTokenIndex
        );
    }

    /// @notice Withdraw tokens from batch.
    /// @notice Receipts are burned and user receives amount of tokens that was noted.
    /// @notice Cycle noted in receipts should be current cycle.
    /// @param _receiptIds Receipt NFTs ids.
    function withdrawFromBatch(uint256[] calldata _receiptIds) public sphereXGuardPublic(156, 0x1711c9ce) {
        (uint256[] memory receiptIds, address[] memory tokens, uint256[] memory withdrawnTokenAmounts) = batch.withdraw(
            msg.sender,
            _receiptIds,
            currentCycleId
        );

        currentCycleDepositsCount -= receiptIds.length;
        if (currentCycleDepositsCount == 0) currentCycleFirstDepositAt = 0;

        emit WithdrawFromBatch(msg.sender, receiptIds, tokens, withdrawnTokenAmounts);
    }

    /// @notice Deposit token into batch.
    /// @param depositToken Supported token to deposit.
    /// @param _amount Amount to deposit.
    /// @dev User should approve `_amount` of `depositToken` to this contract.
    function depositToBatch(
        address depositToken,
        uint256 _amount,
        string calldata referral
    ) external sphereXGuardExternal(141) {
        (uint256 depositAmount, uint256 depositFeeAmount) = batch.deposit(
            msg.sender,
            depositToken,
            _amount,
            currentCycleId
        );

        IERC20(depositToken).safeTransferFrom(msg.sender, address(batch), depositAmount);

        if (depositFeeAmount != 0) {
            IERC20(depositToken).safeTransferFrom(msg.sender, moderator, depositFeeAmount);
        }

        currentCycleDepositsCount++;
        if (currentCycleFirstDepositAt == 0) currentCycleFirstDepositAt = block.timestamp;

        emit Deposit(msg.sender, depositToken, depositAmount, depositFeeAmount, referral);
    }

    // Admin functions

    /// @notice Set token as supported for user deposit and withdraw.
    /// @dev Admin function.
    function setSupportedToken(
        address tokenAddress,
        bool supported,
        address idleStrategy
    ) external onlyModerator sphereXGuardExternal(154) {
        if (!supported) {
            StrategyRouter.TokenPrice[] memory supportedTokensWithPricesWithRemovedToken = batch
                .getSupportedTokensWithPriceInUsd();

            (bool wasRemovedFromTail, address formerTailTokenAddress, uint256 newIndexOfFormerTailToken) = batch
                .removeSupportedToken(tokenAddress);

            StrategyRouterLib._removeIdleStrategy(
                idleStrategies,
                batch,
                exchange,
                strategies,
                allStrategiesWeightSum,
                tokenAddress,
                supportedTokensWithPricesWithRemovedToken,
                moderator
            );
            if (!wasRemovedFromTail) {
                uint256 strategiesLength = strategies.length;
                for (uint256 i; i < strategiesLength; i++) {
                    if (strategies[i].depositToken == formerTailTokenAddress) {
                        strategies[i].depositTokenInSupportedTokensIndex = newIndexOfFormerTailToken;
                    }
                }
            }
        } else {
            batch.addSupportedToken(tokenAddress);
            address[] memory supportedTokens = getSupportedTokens();
            StrategyRouterLib.setIdleStrategy(
                idleStrategies,
                supportedTokens,
                supportedTokens.length - 1,
                idleStrategy,
                moderator
            );
        }
    }

    /// @notice Set address for fees collected by protocol.
    /// @dev Admin function.
    function setFeesCollectionAddress(address _moderator) external onlyModerator sphereXGuardExternal(150) {
        if (_moderator == address(0)) revert();
        moderator = _moderator;
        emit SetModeratorAddress(_moderator);
    }

    /// @notice Minimum time needed to be able to close the cycle.
    /// @param timeInSeconds Duration of cycle in seconds.
    /// @dev Admin function.
    function setAllocationWindowTime(uint256 timeInSeconds) external onlyModerator sphereXGuardExternal(149) {
        allocationWindowTime = timeInSeconds;
        emit SetAllocationWindowTime(timeInSeconds);
    }

    // ///
    // function viewParams() external view returns (uint256, address) {
    //     return (allocationWindowTime, address(batch));
    // }

    /// @notice Add strategy.
    /// @param _strategyAddress Address of the strategy.
    /// @param _weight Weight of the strategy. Used to split user deposit between strategies.
    /// @dev Admin function.
    /// @dev Deposit token must be supported by the router.
    function addStrategy(address _strategyAddress, uint256 _weight) external onlyModerator sphereXGuardExternal(138) {
        address strategyDepositTokenAddress = IStrategy(_strategyAddress).depositToken();
        address[] memory supportedTokens = getSupportedTokens();
        bool isDepositTokenSupported = false;
        uint256 depositTokenInSupportedTokensIndex;
        uint256 supportedTokensLength = supportedTokens.length;
        for (uint256 i; i < supportedTokensLength; i++) {
            if (supportedTokens[i] == strategyDepositTokenAddress) {
                depositTokenInSupportedTokensIndex = i;
                isDepositTokenSupported = true;
            }
        }
        if (!isDepositTokenSupported) {
            revert UnsupportedToken();
        }

        uint256 len = strategies.length;
        for (uint256 i = 0; i < len; i++) {
            if (strategies[i].strategyAddress == _strategyAddress) revert DuplicateStrategy();
        }

        strategies.push(
            StrategyInfo({
                strategyAddress: _strategyAddress,
                depositToken: strategyDepositTokenAddress,
                weight: _weight,
                depositTokenInSupportedTokensIndex: depositTokenInSupportedTokensIndex
            })
        );
        allStrategiesWeightSum += _weight;
    }

    /// @notice Update strategy weight.
    /// @param _strategyId Id of the strategy.
    /// @param _weight New weight of the strategy.
    /// @dev Admin function.
    function updateStrategy(uint256 _strategyId, uint256 _weight) external onlyModerator sphereXGuardExternal(155) {
        allStrategiesWeightSum -= strategies[_strategyId].weight;
        allStrategiesWeightSum += _weight;

        strategies[_strategyId].weight = _weight;
    }

    /// @notice Remove strategy and deposit its balance in other strategies.
    /// @notice Will revert when there is only 1 strategy left.
    /// @param _strategyId Id of the strategy.
    /// @dev Admin function.
    function removeStrategy(uint256 _strategyId) external onlyModerator sphereXGuardExternal(147) {
        if (strategies.length < 2) revert CantRemoveLastStrategy();
        StrategyInfo memory removedStrategyInfo = strategies[_strategyId];
        IStrategy removedStrategy = IStrategy(removedStrategyInfo.strategyAddress);

        uint256 len = strategies.length - 1;
        strategies[_strategyId] = strategies[len];
        strategies.pop();
        allStrategiesWeightSum -= removedStrategyInfo.weight;

        // compound removed strategy
        removedStrategy.compound();

        // withdraw all from removed strategy
        removedStrategy.withdrawAll();

        // compound all strategies
        for (uint256 i; i < len; i++) {
            IStrategy(strategies[i].strategyAddress).compound();
        }

        // deposit withdrawn funds into other strategies
        StrategyRouter.TokenPrice[] memory supportedTokenPrices = batch.getSupportedTokensWithPriceInUsd();
        StrategyRouterLib.rebalanceStrategies(exchange, strategies, allStrategiesWeightSum, supportedTokenPrices);

        Ownable(address(removedStrategy)).transferOwnership(moderator);
    }

    function setIdleStrategy(uint256 i, address idleStrategy) external onlyModerator sphereXGuardExternal(152) {
        StrategyRouterLib.setIdleStrategy(idleStrategies, getSupportedTokens(), i, idleStrategy, moderator);
    }

    /// @notice Rebalance strategies, so that their balances will match their weights.
    /// @return balances Balances of the strategies after rebalancing.
    /// @dev Admin function.
    function rebalanceStrategies()
        external
        onlyModerator
        sphereXGuardExternal(144)
        returns (uint256[] memory balances)
    {
        StrategyRouter.TokenPrice[] memory supportedTokenPrices = batch.getSupportedTokensWithPriceInUsd();
        return
            StrategyRouterLib.rebalanceStrategies(exchange, strategies, allStrategiesWeightSum, supportedTokenPrices);
    }

    /// @notice Checks weather upkeep method is ready to be called.
    /// Method is compatible with AutomationCompatibleInterface from ChainLink smart contracts
    /// @return upkeepNeeded Returns weither upkeep method needs to be executed
    /// @dev Automation function
    function checkUpkeep(bytes calldata) external view override returns (bool upkeepNeeded, bytes memory) {
        upkeepNeeded =
            currentCycleFirstDepositAt > 0 &&
            currentCycleFirstDepositAt + allocationWindowTime < block.timestamp;
    }

    function timestamp() external view returns (uint256 upkeepNeeded) {
        upkeepNeeded = block.timestamp;
    }

    /// @notice Execute upkeep routine that proxies to allocateToStrategies
    /// Method is compatible with AutomationCompatibleInterface from ChainLink smart contracts
    /// @dev Automation function
    function performUpkeep(bytes calldata) external override sphereXGuardExternal(143) {
        this.allocateToStrategies();
    }

    // @dev Returns cycle data
    function getCycle(
        uint256 _cycleId
    )
        public
        view
        returns (
            uint256 startAt,
            uint256 totalDepositedInUsd,
            uint256 receivedByStrategiesInUsd,
            uint256 strategiesBalanceWithCompoundAndBatchDepositsInUsd,
            uint256 pricePerShare
        )
    {
        Cycle storage requestedCycle = cycles[_cycleId];

        startAt = requestedCycle.startAt;
        totalDepositedInUsd = requestedCycle.totalDepositedInUsd;
        receivedByStrategiesInUsd = requestedCycle.receivedByStrategiesInUsd;
        strategiesBalanceWithCompoundAndBatchDepositsInUsd = requestedCycle
            .strategiesBalanceWithCompoundAndBatchDepositsInUsd;
        pricePerShare = requestedCycle.pricePerShare;
    }

    // Internals

    /// @param withdrawAmountUsd - USD value to withdraw. `UNIFORM_DECIMALS` decimals.
    /// @param withdrawToken Supported token to receive after withdraw.
    /// @param minTokenAmountToWithdraw min amount expected to be withdrawn
    /// @param supportedTokenIndex index in supported tokens
    /// @return tokenAmountToWithdraw amount of tokens that were actually withdrawn
    function _withdrawFromStrategies(
        uint256 withdrawAmountUsd,
        address withdrawToken,
        uint256 minTokenAmountToWithdraw,
        uint256 supportedTokenIndex
    ) private sphereXGuardInternal(137) returns (uint256 tokenAmountToWithdraw) {
        (
            ,
            uint256 totalStrategyBalance,
            uint256 totalIdleStrategyBalance,
            uint256[] memory strategyTokenBalancesUsd,
            uint256[] memory idleStrategyTokenBalancesUsd
        ) = getStrategiesValue();

        if (totalIdleStrategyBalance != 0) {
            if (idleStrategyTokenBalancesUsd[supportedTokenIndex] != 0) {
                // at this moment its in USD
                uint256 tokenAmountToWithdrawFromIdle = idleStrategyTokenBalancesUsd[supportedTokenIndex] <
                    withdrawAmountUsd
                    ? idleStrategyTokenBalancesUsd[supportedTokenIndex]
                    : withdrawAmountUsd;

                unchecked {
                    // we assume that the whole requested amount was withdrawn
                    // we on purpose do not adjust for slippage, fees, etc
                    // otherwise a user will be able to withdraw on Clip at better rates than on DEXes at other LPs expense
                    // if not the whole amount withdrawn from a strategy the slippage protection will sort this out
                    withdrawAmountUsd -= tokenAmountToWithdrawFromIdle;
                }

                (uint256 tokenUsdPrice, uint8 oraclePriceDecimals) = oracle.getTokenUsdPrice(withdrawToken);

                // convert usd value into token amount
                tokenAmountToWithdrawFromIdle =
                    (tokenAmountToWithdrawFromIdle * 10 ** oraclePriceDecimals) /
                    tokenUsdPrice;
                // adjust decimals of the token amount
                tokenAmountToWithdrawFromIdle = StrategyRouterLib.fromUniform(
                    tokenAmountToWithdrawFromIdle,
                    withdrawToken
                );
                tokenAmountToWithdraw += IStrategy(idleStrategies[supportedTokenIndex].strategyAddress).withdraw(
                    tokenAmountToWithdrawFromIdle
                );
            }

            if (withdrawAmountUsd != 0) {
                for (uint256 i; i < idleStrategies.length; i++) {
                    if (i == supportedTokenIndex) {
                        continue;
                    }
                    if (idleStrategyTokenBalancesUsd[i] == 0) {
                        continue;
                    }

                    // at this moment its in USD
                    uint256 tokenAmountToSwap = idleStrategyTokenBalancesUsd[i] < withdrawAmountUsd
                        ? idleStrategyTokenBalancesUsd[i]
                        : withdrawAmountUsd;

                    unchecked {
                        // we assume that the whole requested amount was withdrawn
                        // we on purpose do not adjust for slippage, fees, etc
                        // otherwise a user will be able to withdraw on Clip at better rates than on DEXes at other LPs expense
                        // if not the whole amount withdrawn from a strategy the slippage protection will sort this out
                        withdrawAmountUsd -= tokenAmountToSwap;
                    }

                    (uint256 tokenUsdPrice, uint8 oraclePriceDecimals) = oracle.getTokenUsdPrice(
                        idleStrategies[i].depositToken
                    );

                    // convert usd value into token amount
                    tokenAmountToSwap = (tokenAmountToSwap * 10 ** oraclePriceDecimals) / tokenUsdPrice;
                    // adjust decimals of the token amount
                    tokenAmountToSwap = StrategyRouterLib.fromUniform(
                        tokenAmountToSwap,
                        idleStrategies[i].depositToken
                    );
                    tokenAmountToSwap = IStrategy(idleStrategies[i].strategyAddress).withdraw(tokenAmountToSwap);
                    // swap for requested token
                    tokenAmountToWithdraw += StrategyRouterLib.trySwap(
                        exchange,
                        tokenAmountToSwap,
                        idleStrategies[i].depositToken,
                        withdrawToken
                    );

                    if (withdrawAmountUsd == 0) break;
                }
            }
        }

        if (withdrawAmountUsd != 0) {
            for (uint256 i; i < strategies.length; i++) {
                if (strategyTokenBalancesUsd[i] == 0) {
                    continue;
                }

                uint256 tokenAmountToSwap = (withdrawAmountUsd * strategyTokenBalancesUsd[i]) / totalStrategyBalance;
                totalStrategyBalance -= strategyTokenBalancesUsd[i];

                withdrawAmountUsd -= tokenAmountToSwap;

                // at this moment its in USD
                tokenAmountToSwap = strategyTokenBalancesUsd[i] < tokenAmountToSwap
                    ? strategyTokenBalancesUsd[i]
                    : tokenAmountToSwap;

                (uint256 tokenUsdPrice, uint8 oraclePriceDecimals) = oracle.getTokenUsdPrice(
                    strategies[i].depositToken
                );

                // convert usd value into token amount
                tokenAmountToSwap = (tokenAmountToSwap * 10 ** oraclePriceDecimals) / tokenUsdPrice;
                // adjust decimals of the token amount
                tokenAmountToSwap = StrategyRouterLib.fromUniform(tokenAmountToSwap, strategies[i].depositToken);
                tokenAmountToSwap = IStrategy(strategies[i].strategyAddress).withdraw(tokenAmountToSwap);
                // swap for requested token
                tokenAmountToWithdraw += StrategyRouterLib.trySwap(
                    exchange,
                    tokenAmountToSwap,
                    strategies[i].depositToken,
                    withdrawToken
                );
            }
        }

        if (tokenAmountToWithdraw < minTokenAmountToWithdraw) {
            revert WithdrawnAmountLowerThanExpectedAmount();
        }

        IERC20(withdrawToken).safeTransfer(msg.sender, tokenAmountToWithdraw);
        emit WithdrawFromStrategies(msg.sender, withdrawToken, tokenAmountToWithdraw);

        return tokenAmountToWithdraw;
    }
}
//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";
import "./idle-strategies/DefaultIdleStrategy.sol";
import "./interfaces/IIdleStrategy.sol";
import "./interfaces/IStrategy.sol";
import "./interfaces/IUsdOracle.sol";
import {ReceiptNFT} from "./ReceiptNFT.sol";
import {Exchange} from "./exchange/Exchange.sol";
import {SharesToken} from "./SharesToken.sol";
import "./Batch.sol";
import "./StrategyRouter.sol";

library StrategyRouterLib {
    using SafeERC20 for IERC20;

    error CycleNotClosed();

    uint8 private constant UNIFORM_DECIMALS = 18;
    uint256 private constant PRECISION = 1e18;
    // used in rebalance function, UNIFORM_DECIMALS, so 1e17 == 0.1
    uint256 private constant ALLOCATION_THRESHOLD = 1e17;

    struct StrategyData {
        address strategyAddress;
        address tokenAddress;
        uint256 tokenIndexInSupportedTokens;
        uint256 weight;
        uint256 toDeposit;
    }

    struct TokenData {
        uint256 currentBalance;
        uint256 currentBalanceUniform;
        bool isBalanceInsufficient;
    }

    bytes32 private constant SPHEREX_ADMIN_STORAGE_SLOT = bytes32(uint256(keccak256("eip1967.spherex.spherex")) - 1);
    bytes32 private constant SPHEREX_ENGINE_STORAGE_SLOT =
        bytes32(uint256(keccak256("eip1967.spherex.spherex_engine")) - 1);

    /**
     * @dev this struct is used to reduce the stack usage of the modifiers.
     */
    struct ModifierLocals {
        bytes32[] storageSlots;
        bytes32[] valuesBefore;
        uint256 gas;
    }

    // ============ Helper functions ============

    function _sphereXEngine() private view returns (ISphereXEngine) {
        return ISphereXEngine(_getAddress(SPHEREX_ENGINE_STORAGE_SLOT));
    }

    /**
     * Returns an address from an arbitrary slot.
     * @param slot to read an address from
     */
    function _getAddress(bytes32 slot) private view returns (address addr) {
        // solhint-disable-next-line no-inline-assembly
        // slither-disable-next-line assembly
        assembly {
            addr := sload(slot)
        }
    }

    // ============ Local modifiers ============

    modifier returnsIfNotActivated() {
        if (address(_sphereXEngine()) == address(0)) {
            return;
        }

        _;
    }

    // ============ Hooks ============

    /**
     * @dev internal function for engine communication. We use it to reduce contract size.
     *  Should be called before the code of a function.
     * @param num function identifier
     * @param isExternalCall set to true if this was called externally
     *  or a 'public' function from another address
     */
    function _sphereXValidatePre(
        int16 num,
        bool isExternalCall
    ) private returnsIfNotActivated returns (ModifierLocals memory locals) {
        ISphereXEngine sphereXEngine = _sphereXEngine();
        if (isExternalCall) {
            locals.storageSlots = sphereXEngine.sphereXValidatePre(num, msg.sender, msg.data);
        } else {
            locals.storageSlots = sphereXEngine.sphereXValidateInternalPre(num);
        }
        locals.valuesBefore = _readStorage(locals.storageSlots);
        locals.gas = gasleft();
        return locals;
    }

    /**
     * @dev internal function for engine communication. We use it to reduce contract size.
     *  Should be called after the code of a function.
     * @param num function identifier
     * @param isExternalCall set to true if this was called externally
     *  or a 'public' function from another address
     */
    function _sphereXValidatePost(
        int16 num,
        bool isExternalCall,
        ModifierLocals memory locals
    ) private returnsIfNotActivated {
        uint256 gas = locals.gas - gasleft();

        ISphereXEngine sphereXEngine = _sphereXEngine();

        bytes32[] memory valuesAfter;
        valuesAfter = _readStorage(locals.storageSlots);

        if (isExternalCall) {
            sphereXEngine.sphereXValidatePost(num, gas, locals.valuesBefore, valuesAfter);
        } else {
            sphereXEngine.sphereXValidateInternalPost(num, gas, locals.valuesBefore, valuesAfter);
        }
    }

    /**
     * @dev internal function for engine communication. We use it to reduce contract size.
     *  Should be called before the code of a function.
     * @param num function identifier
     * @return locals ModifierLocals
     */
    function _sphereXValidateInternalPre(
        int16 num
    ) private returnsIfNotActivated returns (ModifierLocals memory locals) {
        locals.storageSlots = _sphereXEngine().sphereXValidateInternalPre(num);
        locals.valuesBefore = _readStorage(locals.storageSlots);
        locals.gas = gasleft();
        return locals;
    }

    /**
     * @dev internal function for engine communication. We use it to reduce contract size.
     *  Should be called after the code of a function.
     * @param num function identifier
     * @param locals ModifierLocals
     */
    function _sphereXValidateInternalPost(int16 num, ModifierLocals memory locals) private returnsIfNotActivated {
        bytes32[] memory valuesAfter;
        valuesAfter = _readStorage(locals.storageSlots);
        _sphereXEngine().sphereXValidateInternalPost(num, locals.gas - gasleft(), locals.valuesBefore, valuesAfter);
    }

    /**
     *  @dev Modifier to be incorporated in all internal protected non-view functions
     */
    modifier sphereXGuardInternal(int16 num) {
        ModifierLocals memory locals = _sphereXValidateInternalPre(num);
        _;
        _sphereXValidateInternalPost(-num, locals);
    }

    /**
     *  @dev Modifier to be incorporated in all external protected non-view functions
     */
    modifier sphereXGuardExternal(int16 num) {
        ModifierLocals memory locals = _sphereXValidatePre(num, true);
        _;
        _sphereXValidatePost(-num, true, locals);
    }

    /**
     *  @dev Modifier to be incorporated in all public rotected non-view functions
     */

    modifier sphereXGuardPublic(int16 num, bytes4 selector) {
        ModifierLocals memory locals = _sphereXValidatePre(num, msg.sig == selector);
        _;
        _sphereXValidatePost(-num, msg.sig == selector, locals);
    }

    // ============ Internal Storage logic ============

    /**
     * Internal function that reads values from given storage slots and returns them
     * @param storageSlots list of storage slots to read
     * @return list of values read from the various storage slots
     */
    function _readStorage(bytes32[] memory storageSlots) private view returns (bytes32[] memory) {
        uint256 arrayLength = storageSlots.length;
        bytes32[] memory values = new bytes32[](arrayLength);
        // create the return array data

        for (uint256 i = 0; i < arrayLength; i++) {
            bytes32 slot = storageSlots[i];
            bytes32 temp_value;
            // solhint-disable-next-line no-inline-assembly
            // slither-disable-next-line assembly
            assembly {
                temp_value := sload(slot)
            }

            values[i] = temp_value;
        }
        return values;
    }

    // ============ Wrapper Functions ============

    function getStrategiesValue(
        Batch batch,
        StrategyRouter.StrategyInfo[] storage strategies,
        StrategyRouter.IdleStrategyInfo[] storage idleStrategies
    )
        public
        view
        returns (
            uint256 totalBalance,
            uint256 totalStrategyBalance,
            uint256 totalIdleStrategyBalance,
            uint256[] memory balances,
            uint256[] memory idleBalances
        )
    {
        StrategyRouter.TokenPrice[] memory supportedTokenPrices = batch.getSupportedTokensWithPriceInUsd();

        (
            totalBalance,
            totalStrategyBalance,
            totalIdleStrategyBalance,
            balances,
            idleBalances
        ) = getStrategiesValueWithoutOracleCalls(strategies, idleStrategies, supportedTokenPrices);
    }

    function getStrategiesValueWithoutOracleCalls(
        StrategyRouter.StrategyInfo[] storage strategies,
        StrategyRouter.IdleStrategyInfo[] storage idleStrategies,
        StrategyRouter.TokenPrice[] memory supportedTokenPrices
    )
        public
        view
        returns (
            uint256 totalBalance,
            uint256 totalStrategyBalance,
            uint256 totalIdleStrategyBalance,
            uint256[] memory balances,
            uint256[] memory idleBalances
        )
    {
        uint256 strategiesLength = strategies.length;
        balances = new uint256[](strategiesLength);
        for (uint256 i; i < strategiesLength; i++) {
            uint256 balanceInUsd = IStrategy(strategies[i].strategyAddress).totalTokens();

            StrategyRouter.TokenPrice memory tokenPrice = supportedTokenPrices[
                strategies[i].depositTokenInSupportedTokensIndex
            ];

            balanceInUsd = ((balanceInUsd * tokenPrice.price) / 10 ** tokenPrice.priceDecimals);
            balanceInUsd = toUniform(balanceInUsd, tokenPrice.token);
            balances[i] = balanceInUsd;
            totalBalance += balanceInUsd;
            totalStrategyBalance += balanceInUsd;
        }

        uint256 idleStrategiesLength = supportedTokenPrices.length;
        idleBalances = new uint256[](idleStrategiesLength);
        for (uint256 i; i < idleStrategiesLength; i++) {
            uint256 balanceInUsd = IIdleStrategy(idleStrategies[i].strategyAddress).totalTokens();

            StrategyRouter.TokenPrice memory tokenPrice = supportedTokenPrices[i];
            balanceInUsd = ((balanceInUsd * tokenPrice.price) / 10 ** tokenPrice.priceDecimals);
            balanceInUsd = toUniform(balanceInUsd, tokenPrice.token);
            idleBalances[i] = balanceInUsd;
            totalBalance += balanceInUsd;
            totalIdleStrategyBalance += balanceInUsd;
        }
    }

    // returns amount of shares locked by receipt.
    function calculateSharesFromReceipt(
        uint256 receiptId,
        uint256 currentCycleId,
        ReceiptNFT receiptContract,
        mapping(uint256 => StrategyRouter.Cycle) storage cycles
    ) public view returns (uint256 shares) {
        ReceiptNFT.ReceiptData memory receipt = receiptContract.getReceipt(receiptId);
        if (receipt.cycleId == currentCycleId) revert CycleNotClosed();

        uint256 depositCycleTokenPriceUsd = cycles[receipt.cycleId].prices[receipt.token];

        uint256 depositedUsdValueOfReceipt = (receipt.tokenAmountUniform * depositCycleTokenPriceUsd) / PRECISION;
        assert(depositedUsdValueOfReceipt > 0);
        // adjust according to what was actually deposited into strategies
        // example: ($1000 * $4995) / $5000 = $999
        uint256 allocatedUsdValueOfReceipt = (depositedUsdValueOfReceipt *
            cycles[receipt.cycleId].receivedByStrategiesInUsd) / cycles[receipt.cycleId].totalDepositedInUsd;
        return (allocatedUsdValueOfReceipt * PRECISION) / cycles[receipt.cycleId].pricePerShare;
    }

    /// @dev Change decimal places of number from `oldDecimals` to `newDecimals`.
    function changeDecimals(uint256 amount, uint8 oldDecimals, uint8 newDecimals) internal pure returns (uint256) {
        if (amount == 0) {
            return amount;
        }

        if (oldDecimals < newDecimals) {
            return amount * (10 ** (newDecimals - oldDecimals));
        } else if (oldDecimals > newDecimals) {
            return amount / (10 ** (oldDecimals - newDecimals));
        }
        return amount;
    }

    /// @dev Swap tokens if they are different (i.e. not the same token)
    //sphereXGuardInternal(1001)
    function trySwap(Exchange exchange, uint256 amount, address from, address to) internal returns (uint256 result) {
        if (from != to) {
            IERC20(from).safeTransfer(address(exchange), amount);
            result = exchange.swap(amount, from, to, address(this));
            return result;
        }
        return amount;
    }

    /// @dev Change decimal places to `UNIFORM_DECIMALS`.
    function toUniform(uint256 amount, address token) internal view returns (uint256) {
        return changeDecimals(amount, ERC20(token).decimals(), UNIFORM_DECIMALS);
    }

    /// @dev Convert decimal places from `UNIFORM_DECIMALS` to token decimals.
    function fromUniform(uint256 amount, address token) internal view returns (uint256) {
        return changeDecimals(amount, UNIFORM_DECIMALS, ERC20(token).decimals());
    }

    /// @notice receiptIds should be passed here already ordered by their owners in order not to do extra transfers
    /// @notice Example: [alice, bob, alice, bob] will do 4 transfers. [alice, alice, bob, bob] will do 2 transfers
    function redeemReceiptsToSharesByModerators(
        uint256[] calldata receiptIds,
        uint256 _currentCycleId,
        ReceiptNFT _receiptContract,
        SharesToken _sharesToken,
        mapping(uint256 => StrategyRouter.Cycle) storage cycles
    ) public sphereXGuardPublic(1002, 0x1033a4a2) {
        if (receiptIds.length == 0) revert();
        uint256 sameOwnerShares;
        // address sameOwnerAddress;
        for (uint256 i = 0; i < receiptIds.length; i++) {
            uint256 receiptId = receiptIds[i];
            uint256 shares = calculateSharesFromReceipt(receiptId, _currentCycleId, _receiptContract, cycles);
            address receiptOwner = _receiptContract.ownerOf(receiptId);
            if (i + 1 < receiptIds.length) {
                uint256 nextReceiptId = receiptIds[i + 1];
                address nextReceiptOwner = _receiptContract.ownerOf(nextReceiptId);
                if (nextReceiptOwner == receiptOwner) {
                    sameOwnerShares += shares;
                    // sameOwnerAddress = nextReceiptOwner;
                } else {
                    // this is the last receipt in a row of the same owner
                    sameOwnerShares += shares;
                    _sharesToken.transfer(receiptOwner, sameOwnerShares);
                    sameOwnerShares = 0;
                    // sameOwnerAddress = address(0);
                }
            } else {
                // this is the last receipt in the list, if previous owner is different then
                // sameOwnerShares is 0, otherwise it contain amount unlocked for that owner
                sameOwnerShares += shares;
                _sharesToken.transfer(receiptOwner, sameOwnerShares);
            }
            _receiptContract.burn(receiptId);
        }
    }

    /// burn receipts and return amount of shares noted in them.
    function burnReceipts(
        uint256[] calldata receiptIds,
        uint256 _currentCycleId,
        ReceiptNFT _receiptContract,
        mapping(uint256 => StrategyRouter.Cycle) storage cycles
    ) public sphereXGuardPublic(1003, 0xdf6ed7d9) returns (uint256 shares) {
        for (uint256 i = 0; i < receiptIds.length; i++) {
            uint256 receiptId = receiptIds[i];
            if (_receiptContract.ownerOf(receiptId) != msg.sender) revert StrategyRouter.NotReceiptOwner();
            shares += calculateSharesFromReceipt(receiptId, _currentCycleId, _receiptContract, cycles);
            _receiptContract.burn(receiptId);
        }
    }

    function rebalanceStrategies(
        Exchange exchange,
        StrategyRouter.StrategyInfo[] storage strategies,
        uint256 remainingToAllocateStrategiesWeightSum,
        StrategyRouter.TokenPrice[] memory supportedTokensWithPrices
    ) public sphereXGuardPublic(1004, 0xfeb659c5) returns (uint256[] memory balances) {
        // track balance to allocate between strategies
        uint256 totalUnallocatedBalanceUniform;
        StrategyData[] memory strategyDatas = new StrategyData[](strategies.length);

        uint256[] memory underflowedStrategyWeights = new uint256[](strategyDatas.length);
        uint256 remainingToAllocateUnderflowStrategiesWeightSum;

        TokenData[] memory currentTokenDatas = new TokenData[](supportedTokensWithPrices.length);
        balances = new uint256[](strategyDatas.length);

        // prepare state for allocation
        // 1. calculate total token balance of strategies and router
        // 2. derive strategy desired balances from total token balance
        // 3. withdraw overflows on strategies with excess
        // 4. use underflow to calculate new relative weights of strategies with deficit
        //    that will be used to allocate unallocated balance
        {
            uint256 totalBalanceUniform;

            // sum token balances of strategies to total balance
            // collect data about strategies
            for (uint256 i; i < strategyDatas.length; i++) {
                balances[i] = IStrategy(strategies[i].strategyAddress).totalTokens();
                strategyDatas[i] = StrategyData({
                    strategyAddress: strategies[i].strategyAddress,
                    tokenAddress: strategies[i].depositToken,
                    tokenIndexInSupportedTokens: 0,
                    weight: strategies[i].weight,
                    toDeposit: 0
                });
                totalBalanceUniform += toUniform(balances[i], strategyDatas[i].tokenAddress);

                for (uint256 j; j < supportedTokensWithPrices.length; j++) {
                    if (strategyDatas[i].tokenAddress == supportedTokensWithPrices[j].token) {
                        strategyDatas[i].tokenIndexInSupportedTokens = j;
                        break;
                    }
                }
            }
            // sum token balances of router to total balance
            // sum token balances of router to total unallocated balance
            // collect router token data
            for (uint256 i; i < supportedTokensWithPrices.length; i++) {
                uint256 currentTokenBalance = IERC20(supportedTokensWithPrices[i].token).balanceOf(address(this));
                currentTokenDatas[i].currentBalance = currentTokenBalance;
                uint256 currentTokenBalanceUniform = toUniform(currentTokenBalance, supportedTokensWithPrices[i].token);
                currentTokenDatas[i].currentBalanceUniform = currentTokenBalanceUniform;
                totalBalanceUniform += currentTokenBalanceUniform;
                totalUnallocatedBalanceUniform += currentTokenBalanceUniform;
            }

            // derive desired strategy balances
            // sum withdrawn overflows to total unallocated balance
            for (uint256 i; i < strategyDatas.length; i++) {
                uint256 desiredBalance = (totalBalanceUniform * strategyDatas[i].weight) /
                    remainingToAllocateStrategiesWeightSum;
                desiredBalance = fromUniform(desiredBalance, strategyDatas[i].tokenAddress);
                // if current balance is greater than desired – withdraw excessive tokens
                // add them up to total unallocated balance
                if (desiredBalance < balances[i]) {
                    uint256 balanceToWithdraw = balances[i] - desiredBalance;
                    if (toUniform(balanceToWithdraw, strategyDatas[i].tokenAddress) >= ALLOCATION_THRESHOLD) {
                        // withdraw is called only once
                        // we already know that strategy has overflow and its exact amount
                        // we do not care where withdrawn tokens will be allocated
                        uint256 withdrawnBalance = IStrategy(strategyDatas[i].strategyAddress).withdraw(
                            balanceToWithdraw
                        );
                        // could happen if we withdrew more tokens than expected
                        if (withdrawnBalance > balances[i]) {
                            balances[i] = 0;
                        } else {
                            balances[i] -= withdrawnBalance;
                        }
                        currentTokenDatas[strategyDatas[i].tokenIndexInSupportedTokens]
                            .currentBalance += withdrawnBalance;
                        withdrawnBalance = toUniform(withdrawnBalance, strategyDatas[i].tokenAddress);
                        currentTokenDatas[strategyDatas[i].tokenIndexInSupportedTokens]
                            .currentBalanceUniform += withdrawnBalance;
                        totalUnallocatedBalanceUniform += withdrawnBalance;
                    }
                }
                // otherwise use deficit of tokens as weight of a underflow strategy
                // used to allocate unallocated balance
                else {
                    uint256 balanceToAddUniform = toUniform(
                        desiredBalance - balances[i],
                        strategyDatas[i].tokenAddress
                    );
                    if (balanceToAddUniform >= ALLOCATION_THRESHOLD) {
                        remainingToAllocateUnderflowStrategiesWeightSum += balanceToAddUniform;
                        underflowedStrategyWeights[i] = balanceToAddUniform;
                    }
                }
            }

            // clean up: if token balance of Router is below THRESHOLD remove it from consideration
            // as these tokens are not accessible for strategy allocation
            for (uint256 i; i < supportedTokensWithPrices.length; i++) {
                uint256 currentTokenBalanceUniform = currentTokenDatas[i].currentBalanceUniform;
                if (currentTokenBalanceUniform < ALLOCATION_THRESHOLD) {
                    currentTokenDatas[i].isBalanceInsufficient = true;
                    totalUnallocatedBalanceUniform -= currentTokenBalanceUniform;
                }
            }
        }

        // all tokens to be allocation to strategies with underflow at Router at the moment
        // NO SWAP allocation
        // First try to allocate desired balance to any strategy if there is balance in deposit token of this strategy
        // available at Router
        // that aims to avoid swaps
        for (uint256 i; i < strategyDatas.length; i++) {
            if (underflowedStrategyWeights[i] == 0) {
                continue;
            }

            // NOT: desired balance is calculated used new derived weights
            // only underflow strategies has that weights
            uint256 desiredAllocationUniform = (totalUnallocatedBalanceUniform * underflowedStrategyWeights[i]) /
                remainingToAllocateUnderflowStrategiesWeightSum;

            if (desiredAllocationUniform < ALLOCATION_THRESHOLD) {
                remainingToAllocateUnderflowStrategiesWeightSum -= underflowedStrategyWeights[i];
                underflowedStrategyWeights[i] = 0;
                continue;
            }

            if (currentTokenDatas[strategyDatas[i].tokenIndexInSupportedTokens].isBalanceInsufficient) {
                continue;
            }

            address strategyTokenAddress = strategyDatas[i].tokenAddress;

            uint256 currentTokenBalance = currentTokenDatas[strategyDatas[i].tokenIndexInSupportedTokens]
                .currentBalance;
            uint256 currentTokenBalanceUniform = currentTokenDatas[strategyDatas[i].tokenIndexInSupportedTokens]
                .currentBalanceUniform;

            // allocation logic
            if (currentTokenBalanceUniform >= desiredAllocationUniform) {
                remainingToAllocateUnderflowStrategiesWeightSum -= underflowedStrategyWeights[i];
                underflowedStrategyWeights[i] = 0;

                // manipulation to avoid leftovers
                // if the token balance of Router will be lesser that THRESHOLD after allocation
                // then send leftover with the desired balance
                if (currentTokenBalanceUniform - desiredAllocationUniform < ALLOCATION_THRESHOLD) {
                    IERC20(strategyTokenAddress).safeTransfer(strategyDatas[i].strategyAddress, currentTokenBalance);
                    // memoise how much was deposited to strategy
                    // optimisation to call deposit method only once per strategy
                    strategyDatas[i].toDeposit = currentTokenBalance;

                    balances[i] += currentTokenBalance;
                    currentTokenDatas[strategyDatas[i].tokenIndexInSupportedTokens].currentBalance = 0;
                    currentTokenDatas[strategyDatas[i].tokenIndexInSupportedTokens].currentBalanceUniform = 0;
                    totalUnallocatedBalanceUniform -= currentTokenBalanceUniform;

                    currentTokenDatas[strategyDatas[i].tokenIndexInSupportedTokens].isBalanceInsufficient = true;
                } else {
                    desiredAllocationUniform = fromUniform(desiredAllocationUniform, strategyTokenAddress);
                    IERC20(strategyTokenAddress).safeTransfer(
                        strategyDatas[i].strategyAddress,
                        desiredAllocationUniform
                    );
                    // memoise how much was deposited to strategy
                    // optimisation to call deposit method only once per strategy
                    strategyDatas[i].toDeposit = desiredAllocationUniform;

                    balances[i] += desiredAllocationUniform;
                    currentTokenDatas[strategyDatas[i].tokenIndexInSupportedTokens].currentBalance =
                        currentTokenBalance -
                        desiredAllocationUniform;
                    desiredAllocationUniform = toUniform(desiredAllocationUniform, strategyTokenAddress);
                    currentTokenDatas[strategyDatas[i].tokenIndexInSupportedTokens].currentBalanceUniform =
                        currentTokenBalanceUniform -
                        desiredAllocationUniform;
                    totalUnallocatedBalanceUniform -= desiredAllocationUniform;
                }
            } else {
                // reduce strategy weight in the current rebalance iteration proportionally to the degree
                // at which the strategy's desired balance was saturated
                // For example: if a strategy's weight is 10,000 and the total weight is 100,000
                // and the strategy's desired balance was saturated by 80%
                // we reduce the strategy weight by 80%
                // strategy weight = 10,000 - 80% * 10,000 = 2,000
                // total strategy weight = 100,000 - 80% * 10,000 = 92,000
                uint256 saturatedWeightPoints = (underflowedStrategyWeights[i] * currentTokenBalanceUniform) /
                    desiredAllocationUniform;
                underflowedStrategyWeights[i] -= saturatedWeightPoints;
                remainingToAllocateUnderflowStrategiesWeightSum -= saturatedWeightPoints;
                totalUnallocatedBalanceUniform -= currentTokenBalanceUniform;

                IERC20(strategyTokenAddress).safeTransfer(strategyDatas[i].strategyAddress, currentTokenBalance);
                // memoise how much was deposited to strategy
                // optimisation to call deposit method only once per strategy
                strategyDatas[i].toDeposit = currentTokenBalance;

                balances[i] += currentTokenBalance;
                currentTokenDatas[strategyDatas[i].tokenIndexInSupportedTokens].currentBalance = 0;
                currentTokenDatas[strategyDatas[i].tokenIndexInSupportedTokens].currentBalanceUniform = 0;
                currentTokenDatas[strategyDatas[i].tokenIndexInSupportedTokens].isBalanceInsufficient = true;
            }
        }

        // SWAPFUL allocation
        // if not enough tokens in a strategy deposit token available
        // then try to saturate desired balance swapping other tokens
        for (uint256 i; i < strategyDatas.length; i++) {
            if (underflowedStrategyWeights[i] == 0) {
                if (strategyDatas[i].toDeposit > 0) {
                    // if the strategy was completely saturated at the previous step
                    // call deposit
                    IStrategy(strategyDatas[i].strategyAddress).deposit(strategyDatas[i].toDeposit);
                }
                continue;
            }

            uint256 desiredAllocationUniform = (totalUnallocatedBalanceUniform * underflowedStrategyWeights[i]) /
                remainingToAllocateUnderflowStrategiesWeightSum;
            // reduce weight, we are sure we will fulfill desired balance on this step
            remainingToAllocateUnderflowStrategiesWeightSum -= underflowedStrategyWeights[i];
            underflowedStrategyWeights[i] = 0;

            if (desiredAllocationUniform < ALLOCATION_THRESHOLD) {
                continue;
            }

            for (uint256 j; j < supportedTokensWithPrices.length; j++) {
                // skip deposit token as it was handled on the previous iteration
                if (strategyDatas[i].tokenIndexInSupportedTokens == j) {
                    continue;
                }

                if (currentTokenDatas[j].isBalanceInsufficient) {
                    continue;
                }

                uint256 currentTokenBalanceUniform = currentTokenDatas[j].currentBalanceUniform;

                if (currentTokenBalanceUniform >= desiredAllocationUniform) {
                    // manipulation to avoid leftovers
                    // if the token balance of Router will be lesser that THRESHOLD after allocation
                    // then send leftover with the desired balance
                    if (currentTokenBalanceUniform - desiredAllocationUniform < ALLOCATION_THRESHOLD) {
                        desiredAllocationUniform = 0;
                        totalUnallocatedBalanceUniform -= currentTokenBalanceUniform;

                        IERC20(supportedTokensWithPrices[j].token).safeTransfer(
                            address(exchange),
                            currentTokenDatas[j].currentBalance
                        );
                        uint256 received = exchange.stablecoinSwap(
                            currentTokenDatas[j].currentBalance,
                            supportedTokensWithPrices[j].token,
                            strategyDatas[i].tokenAddress,
                            strategyDatas[i].strategyAddress,
                            supportedTokensWithPrices[j],
                            supportedTokensWithPrices[strategyDatas[i].tokenIndexInSupportedTokens]
                        );
                        // memoise how much was deposited to strategy
                        // optimisation to call deposit method only once per strategy
                        strategyDatas[i].toDeposit = received;

                        balances[i] += received;
                        currentTokenDatas[j].currentBalance = 0;
                        currentTokenDatas[j].currentBalanceUniform = 0;
                        currentTokenDatas[j].isBalanceInsufficient = true;
                    } else {
                        desiredAllocationUniform = fromUniform(
                            desiredAllocationUniform,
                            supportedTokensWithPrices[j].token
                        );
                        totalUnallocatedBalanceUniform -= toUniform(
                            desiredAllocationUniform,
                            supportedTokensWithPrices[j].token
                        );

                        IERC20(supportedTokensWithPrices[j].token).safeTransfer(
                            address(exchange),
                            desiredAllocationUniform
                        );
                        uint256 received = exchange.swap(
                            desiredAllocationUniform,
                            supportedTokensWithPrices[j].token,
                            strategyDatas[i].tokenAddress,
                            strategyDatas[i].strategyAddress
                        );
                        // memoise how much was deposited to strategy
                        // optimisation to call deposit method only once per strategy
                        strategyDatas[i].toDeposit = received;

                        balances[i] += received;
                        currentTokenDatas[j].currentBalance -= desiredAllocationUniform;
                        currentTokenDatas[j].currentBalanceUniform -= desiredAllocationUniform;
                        desiredAllocationUniform = 0;
                    }
                } else {
                    desiredAllocationUniform -= currentTokenBalanceUniform;
                    totalUnallocatedBalanceUniform -= currentTokenBalanceUniform;

                    IERC20(supportedTokensWithPrices[j].token).safeTransfer(
                        address(exchange),
                        currentTokenDatas[j].currentBalance
                    );
                    uint256 received = exchange.swap(
                        currentTokenDatas[j].currentBalance,
                        supportedTokensWithPrices[j].token,
                        strategyDatas[i].tokenAddress,
                        strategyDatas[i].strategyAddress
                    );
                    // memoise how much was deposited to strategy
                    // optimisation to call deposit method only once per strategy
                    strategyDatas[i].toDeposit = received;

                    balances[i] += received;
                    currentTokenDatas[j].currentBalance = 0;
                    currentTokenDatas[j].currentBalanceUniform = 0;
                    currentTokenDatas[j].isBalanceInsufficient = true;
                }
                // optimisation, no need to continue
                if (desiredAllocationUniform < ALLOCATION_THRESHOLD) {
                    break;
                }
            }

            // deposit amount of tokens was transferred to the strategy
            IStrategy(strategyDatas[i].strategyAddress).deposit(strategyDatas[i].toDeposit);
        }
    }

    function setIdleStrategy(
        StrategyRouter.IdleStrategyInfo[] storage idleStrategies,
        address[] memory supportedTokens,
        uint256 i,
        address idleStrategy,
        address moderator
    ) public sphereXGuardPublic(1005, 0xe0607b14) {
        if (i >= supportedTokens.length) {
            revert StrategyRouter.InvalidIndexForIdleStrategy();
        }

        address tokenAddress = supportedTokens[i];
        if (idleStrategy == address(0) || IIdleStrategy(idleStrategy).depositToken() != tokenAddress) {
            revert StrategyRouter.InvalidIdleStrategy();
        }
        // Replace one idle strategy with the other one. Withdraw funds from previous one and add to new one.
        if (i < idleStrategies.length) {
            if (idleStrategies[i].strategyAddress != address(0)) {
                IIdleStrategy currentIdleStrategy = IIdleStrategy(idleStrategies[i].strategyAddress);
                if (currentIdleStrategy.totalTokens() != 0) {
                    uint256 withdrawnAmount = currentIdleStrategy.withdrawAll();
                    IERC20(tokenAddress).safeTransfer(idleStrategy, withdrawnAmount);
                    IIdleStrategy(idleStrategy).deposit(withdrawnAmount);
                }

                Ownable(address(currentIdleStrategy)).transferOwnership(moderator);
            }

            idleStrategies[i] = StrategyRouter.IdleStrategyInfo({
                strategyAddress: idleStrategy,
                depositToken: tokenAddress
            });
        } else {
            // ensure idle strategy pushed at index i
            // though in practice the loop will never be iterated
            for (uint256 j = idleStrategies.length; j < i; j++) {
                idleStrategies.push(
                    StrategyRouter.IdleStrategyInfo({strategyAddress: address(0), depositToken: address(0)})
                );
            }
            idleStrategies.push(
                StrategyRouter.IdleStrategyInfo({strategyAddress: idleStrategy, depositToken: tokenAddress})
            );
        }
    }

    function _removeIdleStrategy(
        StrategyRouter.IdleStrategyInfo[] storage idleStrategies,
        Batch batch,
        Exchange exchange,
        StrategyRouter.StrategyInfo[] storage strategies,
        uint256 allStrategiesWeightSum,
        address tokenAddress,
        StrategyRouter.TokenPrice[] memory supportedTokensWithPricesWithRemovedToken,
        address moderator
    ) public sphereXGuardPublic(1006, 0x603377d6) {
        StrategyRouter.IdleStrategyInfo memory idleStrategyToRemove;
        for (uint256 i; i < idleStrategies.length; i++) {
            if (tokenAddress == idleStrategies[i].depositToken) {
                idleStrategyToRemove = idleStrategies[i];
                idleStrategies[i] = idleStrategies[idleStrategies.length - 1];
                idleStrategies.pop();
                if (
                    idleStrategies.length != 0 &&
                    i != idleStrategies.length &&
                    idleStrategies[i].depositToken != batch.getSupportedTokens()[i]
                ) {
                    revert StrategyRouter.IdleStrategySupportedTokenMismatch();
                }
                break;
            }
        }

        if (IIdleStrategy(idleStrategyToRemove.strategyAddress).withdrawAll() != 0) {
            rebalanceStrategies(
                exchange,
                strategies,
                allStrategiesWeightSum,
                supportedTokensWithPricesWithRemovedToken
            );
        }
        Ownable(address(idleStrategyToRemove.strategyAddress)).transferOwnership(moderator);
    }
}
// SPDX-License-Identifier: MIT
pragma solidity >= 0.4.22 <0.9.0;

library console {
	address constant CONSOLE_ADDRESS = address(0x000000000000000000636F6e736F6c652e6c6f67);

	function _sendLogPayload(bytes memory payload) private view {
		uint256 payloadLength = payload.length;
		address consoleAddress = CONSOLE_ADDRESS;
		assembly {
			let payloadStart := add(payload, 32)
			let r := staticcall(gas(), consoleAddress, payloadStart, payloadLength, 0, 0)
		}
	}

	function log() internal view {
		_sendLogPayload(abi.encodeWithSignature("log()"));
	}

	function logInt(int256 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(int256)", p0));
	}

	function logUint(uint256 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256)", p0));
	}

	function logString(string memory p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string)", p0));
	}

	function logBool(bool p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool)", p0));
	}

	function logAddress(address p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address)", p0));
	}

	function logBytes(bytes memory p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes)", p0));
	}

	function logBytes1(bytes1 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes1)", p0));
	}

	function logBytes2(bytes2 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes2)", p0));
	}

	function logBytes3(bytes3 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes3)", p0));
	}

	function logBytes4(bytes4 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes4)", p0));
	}

	function logBytes5(bytes5 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes5)", p0));
	}

	function logBytes6(bytes6 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes6)", p0));
	}

	function logBytes7(bytes7 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes7)", p0));
	}

	function logBytes8(bytes8 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes8)", p0));
	}

	function logBytes9(bytes9 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes9)", p0));
	}

	function logBytes10(bytes10 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes10)", p0));
	}

	function logBytes11(bytes11 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes11)", p0));
	}

	function logBytes12(bytes12 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes12)", p0));
	}

	function logBytes13(bytes13 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes13)", p0));
	}

	function logBytes14(bytes14 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes14)", p0));
	}

	function logBytes15(bytes15 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes15)", p0));
	}

	function logBytes16(bytes16 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes16)", p0));
	}

	function logBytes17(bytes17 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes17)", p0));
	}

	function logBytes18(bytes18 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes18)", p0));
	}

	function logBytes19(bytes19 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes19)", p0));
	}

	function logBytes20(bytes20 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes20)", p0));
	}

	function logBytes21(bytes21 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes21)", p0));
	}

	function logBytes22(bytes22 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes22)", p0));
	}

	function logBytes23(bytes23 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes23)", p0));
	}

	function logBytes24(bytes24 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes24)", p0));
	}

	function logBytes25(bytes25 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes25)", p0));
	}

	function logBytes26(bytes26 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes26)", p0));
	}

	function logBytes27(bytes27 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes27)", p0));
	}

	function logBytes28(bytes28 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes28)", p0));
	}

	function logBytes29(bytes29 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes29)", p0));
	}

	function logBytes30(bytes30 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes30)", p0));
	}

	function logBytes31(bytes31 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes31)", p0));
	}

	function logBytes32(bytes32 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes32)", p0));
	}

	function log(uint256 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256)", p0));
	}

	function log(string memory p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string)", p0));
	}

	function log(bool p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool)", p0));
	}

	function log(address p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address)", p0));
	}

	function log(uint256 p0, uint256 p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,uint256)", p0, p1));
	}

	function log(uint256 p0, string memory p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,string)", p0, p1));
	}

	function log(uint256 p0, bool p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,bool)", p0, p1));
	}

	function log(uint256 p0, address p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,address)", p0, p1));
	}

	function log(string memory p0, uint256 p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint256)", p0, p1));
	}

	function log(string memory p0, string memory p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string)", p0, p1));
	}

	function log(string memory p0, bool p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool)", p0, p1));
	}

	function log(string memory p0, address p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address)", p0, p1));
	}

	function log(bool p0, uint256 p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint256)", p0, p1));
	}

	function log(bool p0, string memory p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string)", p0, p1));
	}

	function log(bool p0, bool p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool)", p0, p1));
	}

	function log(bool p0, address p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address)", p0, p1));
	}

	function log(address p0, uint256 p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint256)", p0, p1));
	}

	function log(address p0, string memory p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string)", p0, p1));
	}

	function log(address p0, bool p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool)", p0, p1));
	}

	function log(address p0, address p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address)", p0, p1));
	}

	function log(uint256 p0, uint256 p1, uint256 p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,uint256,uint256)", p0, p1, p2));
	}

	function log(uint256 p0, uint256 p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,uint256,string)", p0, p1, p2));
	}

	function log(uint256 p0, uint256 p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,uint256,bool)", p0, p1, p2));
	}

	function log(uint256 p0, uint256 p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,uint256,address)", p0, p1, p2));
	}

	function log(uint256 p0, string memory p1, uint256 p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,string,uint256)", p0, p1, p2));
	}

	function log(uint256 p0, string memory p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,string,string)", p0, p1, p2));
	}

	function log(uint256 p0, string memory p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,string,bool)", p0, p1, p2));
	}

	function log(uint256 p0, string memory p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,string,address)", p0, p1, p2));
	}

	function log(uint256 p0, bool p1, uint256 p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,bool,uint256)", p0, p1, p2));
	}

	function log(uint256 p0, bool p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,bool,string)", p0, p1, p2));
	}

	function log(uint256 p0, bool p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,bool,bool)", p0, p1, p2));
	}

	function log(uint256 p0, bool p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,bool,address)", p0, p1, p2));
	}

	function log(uint256 p0, address p1, uint256 p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,address,uint256)", p0, p1, p2));
	}

	function log(uint256 p0, address p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,address,string)", p0, p1, p2));
	}

	function log(uint256 p0, address p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,address,bool)", p0, p1, p2));
	}

	function log(uint256 p0, address p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,address,address)", p0, p1, p2));
	}

	function log(string memory p0, uint256 p1, uint256 p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint256,uint256)", p0, p1, p2));
	}

	function log(string memory p0, uint256 p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint256,string)", p0, p1, p2));
	}

	function log(string memory p0, uint256 p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint256,bool)", p0, p1, p2));
	}

	function log(string memory p0, uint256 p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint256,address)", p0, p1, p2));
	}

	function log(string memory p0, string memory p1, uint256 p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,uint256)", p0, p1, p2));
	}

	function log(string memory p0, string memory p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,string)", p0, p1, p2));
	}

	function log(string memory p0, string memory p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,bool)", p0, p1, p2));
	}

	function log(string memory p0, string memory p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,address)", p0, p1, p2));
	}

	function log(string memory p0, bool p1, uint256 p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,uint256)", p0, p1, p2));
	}

	function log(string memory p0, bool p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,string)", p0, p1, p2));
	}

	function log(string memory p0, bool p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,bool)", p0, p1, p2));
	}

	function log(string memory p0, bool p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,address)", p0, p1, p2));
	}

	function log(string memory p0, address p1, uint256 p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,uint256)", p0, p1, p2));
	}

	function log(string memory p0, address p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,string)", p0, p1, p2));
	}

	function log(string memory p0, address p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,bool)", p0, p1, p2));
	}

	function log(string memory p0, address p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,address)", p0, p1, p2));
	}

	function log(bool p0, uint256 p1, uint256 p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint256,uint256)", p0, p1, p2));
	}

	function log(bool p0, uint256 p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint256,string)", p0, p1, p2));
	}

	function log(bool p0, uint256 p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint256,bool)", p0, p1, p2));
	}

	function log(bool p0, uint256 p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint256,address)", p0, p1, p2));
	}

	function log(bool p0, string memory p1, uint256 p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,uint256)", p0, p1, p2));
	}

	function log(bool p0, string memory p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,string)", p0, p1, p2));
	}

	function log(bool p0, string memory p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,bool)", p0, p1, p2));
	}

	function log(bool p0, string memory p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,address)", p0, p1, p2));
	}

	function log(bool p0, bool p1, uint256 p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,uint256)", p0, p1, p2));
	}

	function log(bool p0, bool p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,string)", p0, p1, p2));
	}

	function log(bool p0, bool p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,bool)", p0, p1, p2));
	}

	function log(bool p0, bool p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,address)", p0, p1, p2));
	}

	function log(bool p0, address p1, uint256 p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,uint256)", p0, p1, p2));
	}

	function log(bool p0, address p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,string)", p0, p1, p2));
	}

	function log(bool p0, address p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,bool)", p0, p1, p2));
	}

	function log(bool p0, address p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,address)", p0, p1, p2));
	}

	function log(address p0, uint256 p1, uint256 p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint256,uint256)", p0, p1, p2));
	}

	function log(address p0, uint256 p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint256,string)", p0, p1, p2));
	}

	function log(address p0, uint256 p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint256,bool)", p0, p1, p2));
	}

	function log(address p0, uint256 p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint256,address)", p0, p1, p2));
	}

	function log(address p0, string memory p1, uint256 p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,uint256)", p0, p1, p2));
	}

	function log(address p0, string memory p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,string)", p0, p1, p2));
	}

	function log(address p0, string memory p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,bool)", p0, p1, p2));
	}

	function log(address p0, string memory p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,address)", p0, p1, p2));
	}

	function log(address p0, bool p1, uint256 p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,uint256)", p0, p1, p2));
	}

	function log(address p0, bool p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,string)", p0, p1, p2));
	}

	function log(address p0, bool p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,bool)", p0, p1, p2));
	}

	function log(address p0, bool p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,address)", p0, p1, p2));
	}

	function log(address p0, address p1, uint256 p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,uint256)", p0, p1, p2));
	}

	function log(address p0, address p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,string)", p0, p1, p2));
	}

	function log(address p0, address p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,bool)", p0, p1, p2));
	}

	function log(address p0, address p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,address)", p0, p1, p2));
	}

	function log(uint256 p0, uint256 p1, uint256 p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,uint256,uint256,uint256)", p0, p1, p2, p3));
	}

	function log(uint256 p0, uint256 p1, uint256 p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,uint256,uint256,string)", p0, p1, p2, p3));
	}

	function log(uint256 p0, uint256 p1, uint256 p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,uint256,uint256,bool)", p0, p1, p2, p3));
	}

	function log(uint256 p0, uint256 p1, uint256 p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,uint256,uint256,address)", p0, p1, p2, p3));
	}

	function log(uint256 p0, uint256 p1, string memory p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,uint256,string,uint256)", p0, p1, p2, p3));
	}

	function log(uint256 p0, uint256 p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,uint256,string,string)", p0, p1, p2, p3));
	}

	function log(uint256 p0, uint256 p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,uint256,string,bool)", p0, p1, p2, p3));
	}

	function log(uint256 p0, uint256 p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,uint256,string,address)", p0, p1, p2, p3));
	}

	function log(uint256 p0, uint256 p1, bool p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,uint256,bool,uint256)", p0, p1, p2, p3));
	}

	function log(uint256 p0, uint256 p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,uint256,bool,string)", p0, p1, p2, p3));
	}

	function log(uint256 p0, uint256 p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,uint256,bool,bool)", p0, p1, p2, p3));
	}

	function log(uint256 p0, uint256 p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,uint256,bool,address)", p0, p1, p2, p3));
	}

	function log(uint256 p0, uint256 p1, address p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,uint256,address,uint256)", p0, p1, p2, p3));
	}

	function log(uint256 p0, uint256 p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,uint256,address,string)", p0, p1, p2, p3));
	}

	function log(uint256 p0, uint256 p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,uint256,address,bool)", p0, p1, p2, p3));
	}

	function log(uint256 p0, uint256 p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,uint256,address,address)", p0, p1, p2, p3));
	}

	function log(uint256 p0, string memory p1, uint256 p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,string,uint256,uint256)", p0, p1, p2, p3));
	}

	function log(uint256 p0, string memory p1, uint256 p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,string,uint256,string)", p0, p1, p2, p3));
	}

	function log(uint256 p0, string memory p1, uint256 p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,string,uint256,bool)", p0, p1, p2, p3));
	}

	function log(uint256 p0, string memory p1, uint256 p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,string,uint256,address)", p0, p1, p2, p3));
	}

	function log(uint256 p0, string memory p1, string memory p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,string,string,uint256)", p0, p1, p2, p3));
	}

	function log(uint256 p0, string memory p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,string,string,string)", p0, p1, p2, p3));
	}

	function log(uint256 p0, string memory p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,string,string,bool)", p0, p1, p2, p3));
	}

	function log(uint256 p0, string memory p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,string,string,address)", p0, p1, p2, p3));
	}

	function log(uint256 p0, string memory p1, bool p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,string,bool,uint256)", p0, p1, p2, p3));
	}

	function log(uint256 p0, string memory p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,string,bool,string)", p0, p1, p2, p3));
	}

	function log(uint256 p0, string memory p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,string,bool,bool)", p0, p1, p2, p3));
	}

	function log(uint256 p0, string memory p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,string,bool,address)", p0, p1, p2, p3));
	}

	function log(uint256 p0, string memory p1, address p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,string,address,uint256)", p0, p1, p2, p3));
	}

	function log(uint256 p0, string memory p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,string,address,string)", p0, p1, p2, p3));
	}

	function log(uint256 p0, string memory p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,string,address,bool)", p0, p1, p2, p3));
	}

	function log(uint256 p0, string memory p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,string,address,address)", p0, p1, p2, p3));
	}

	function log(uint256 p0, bool p1, uint256 p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,bool,uint256,uint256)", p0, p1, p2, p3));
	}

	function log(uint256 p0, bool p1, uint256 p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,bool,uint256,string)", p0, p1, p2, p3));
	}

	function log(uint256 p0, bool p1, uint256 p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,bool,uint256,bool)", p0, p1, p2, p3));
	}

	function log(uint256 p0, bool p1, uint256 p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,bool,uint256,address)", p0, p1, p2, p3));
	}

	function log(uint256 p0, bool p1, string memory p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,bool,string,uint256)", p0, p1, p2, p3));
	}

	function log(uint256 p0, bool p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,bool,string,string)", p0, p1, p2, p3));
	}

	function log(uint256 p0, bool p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,bool,string,bool)", p0, p1, p2, p3));
	}

	function log(uint256 p0, bool p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,bool,string,address)", p0, p1, p2, p3));
	}

	function log(uint256 p0, bool p1, bool p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,bool,bool,uint256)", p0, p1, p2, p3));
	}

	function log(uint256 p0, bool p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,bool,bool,string)", p0, p1, p2, p3));
	}

	function log(uint256 p0, bool p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,bool,bool,bool)", p0, p1, p2, p3));
	}

	function log(uint256 p0, bool p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,bool,bool,address)", p0, p1, p2, p3));
	}

	function log(uint256 p0, bool p1, address p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,bool,address,uint256)", p0, p1, p2, p3));
	}

	function log(uint256 p0, bool p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,bool,address,string)", p0, p1, p2, p3));
	}

	function log(uint256 p0, bool p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,bool,address,bool)", p0, p1, p2, p3));
	}

	function log(uint256 p0, bool p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,bool,address,address)", p0, p1, p2, p3));
	}

	function log(uint256 p0, address p1, uint256 p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,address,uint256,uint256)", p0, p1, p2, p3));
	}

	function log(uint256 p0, address p1, uint256 p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,address,uint256,string)", p0, p1, p2, p3));
	}

	function log(uint256 p0, address p1, uint256 p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,address,uint256,bool)", p0, p1, p2, p3));
	}

	function log(uint256 p0, address p1, uint256 p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,address,uint256,address)", p0, p1, p2, p3));
	}

	function log(uint256 p0, address p1, string memory p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,address,string,uint256)", p0, p1, p2, p3));
	}

	function log(uint256 p0, address p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,address,string,string)", p0, p1, p2, p3));
	}

	function log(uint256 p0, address p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,address,string,bool)", p0, p1, p2, p3));
	}

	function log(uint256 p0, address p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,address,string,address)", p0, p1, p2, p3));
	}

	function log(uint256 p0, address p1, bool p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,address,bool,uint256)", p0, p1, p2, p3));
	}

	function log(uint256 p0, address p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,address,bool,string)", p0, p1, p2, p3));
	}

	function log(uint256 p0, address p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,address,bool,bool)", p0, p1, p2, p3));
	}

	function log(uint256 p0, address p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,address,bool,address)", p0, p1, p2, p3));
	}

	function log(uint256 p0, address p1, address p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,address,address,uint256)", p0, p1, p2, p3));
	}

	function log(uint256 p0, address p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,address,address,string)", p0, p1, p2, p3));
	}

	function log(uint256 p0, address p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,address,address,bool)", p0, p1, p2, p3));
	}

	function log(uint256 p0, address p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,address,address,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint256 p1, uint256 p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint256,uint256,uint256)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint256 p1, uint256 p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint256,uint256,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint256 p1, uint256 p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint256,uint256,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint256 p1, uint256 p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint256,uint256,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint256 p1, string memory p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint256,string,uint256)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint256 p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint256,string,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint256 p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint256,string,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint256 p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint256,string,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint256 p1, bool p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint256,bool,uint256)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint256 p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint256,bool,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint256 p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint256,bool,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint256 p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint256,bool,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint256 p1, address p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint256,address,uint256)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint256 p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint256,address,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint256 p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint256,address,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint256 p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint256,address,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, uint256 p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,uint256,uint256)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, uint256 p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,uint256,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, uint256 p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,uint256,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, uint256 p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,uint256,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, string memory p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,string,uint256)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,string,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,string,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,string,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, bool p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,bool,uint256)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,bool,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,bool,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,bool,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, address p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,address,uint256)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,address,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,address,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,address,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, uint256 p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,uint256,uint256)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, uint256 p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,uint256,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, uint256 p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,uint256,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, uint256 p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,uint256,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, string memory p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,string,uint256)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,string,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,string,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,string,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, bool p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,bool,uint256)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,bool,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,bool,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,bool,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, address p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,address,uint256)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,address,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,address,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,address,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, uint256 p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,uint256,uint256)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, uint256 p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,uint256,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, uint256 p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,uint256,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, uint256 p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,uint256,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, string memory p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,string,uint256)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,string,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,string,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,string,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, bool p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,bool,uint256)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,bool,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,bool,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,bool,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, address p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,address,uint256)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,address,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,address,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,address,address)", p0, p1, p2, p3));
	}

	function log(bool p0, uint256 p1, uint256 p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint256,uint256,uint256)", p0, p1, p2, p3));
	}

	function log(bool p0, uint256 p1, uint256 p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint256,uint256,string)", p0, p1, p2, p3));
	}

	function log(bool p0, uint256 p1, uint256 p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint256,uint256,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, uint256 p1, uint256 p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint256,uint256,address)", p0, p1, p2, p3));
	}

	function log(bool p0, uint256 p1, string memory p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint256,string,uint256)", p0, p1, p2, p3));
	}

	function log(bool p0, uint256 p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint256,string,string)", p0, p1, p2, p3));
	}

	function log(bool p0, uint256 p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint256,string,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, uint256 p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint256,string,address)", p0, p1, p2, p3));
	}

	function log(bool p0, uint256 p1, bool p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint256,bool,uint256)", p0, p1, p2, p3));
	}

	function log(bool p0, uint256 p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint256,bool,string)", p0, p1, p2, p3));
	}

	function log(bool p0, uint256 p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint256,bool,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, uint256 p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint256,bool,address)", p0, p1, p2, p3));
	}

	function log(bool p0, uint256 p1, address p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint256,address,uint256)", p0, p1, p2, p3));
	}

	function log(bool p0, uint256 p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint256,address,string)", p0, p1, p2, p3));
	}

	function log(bool p0, uint256 p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint256,address,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, uint256 p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint256,address,address)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, uint256 p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,uint256,uint256)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, uint256 p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,uint256,string)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, uint256 p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,uint256,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, uint256 p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,uint256,address)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, string memory p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,string,uint256)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,string,string)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,string,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,string,address)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, bool p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,bool,uint256)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,bool,string)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,bool,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,bool,address)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, address p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,address,uint256)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,address,string)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,address,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,address,address)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, uint256 p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,uint256,uint256)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, uint256 p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,uint256,string)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, uint256 p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,uint256,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, uint256 p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,uint256,address)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, string memory p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,string,uint256)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,string,string)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,string,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,string,address)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, bool p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,bool,uint256)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,bool,string)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,bool,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,bool,address)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, address p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,address,uint256)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,address,string)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,address,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,address,address)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, uint256 p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,uint256,uint256)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, uint256 p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,uint256,string)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, uint256 p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,uint256,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, uint256 p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,uint256,address)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, string memory p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,string,uint256)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,string,string)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,string,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,string,address)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, bool p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,bool,uint256)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,bool,string)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,bool,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,bool,address)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, address p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,address,uint256)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,address,string)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,address,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,address,address)", p0, p1, p2, p3));
	}

	function log(address p0, uint256 p1, uint256 p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint256,uint256,uint256)", p0, p1, p2, p3));
	}

	function log(address p0, uint256 p1, uint256 p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint256,uint256,string)", p0, p1, p2, p3));
	}

	function log(address p0, uint256 p1, uint256 p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint256,uint256,bool)", p0, p1, p2, p3));
	}

	function log(address p0, uint256 p1, uint256 p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint256,uint256,address)", p0, p1, p2, p3));
	}

	function log(address p0, uint256 p1, string memory p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint256,string,uint256)", p0, p1, p2, p3));
	}

	function log(address p0, uint256 p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint256,string,string)", p0, p1, p2, p3));
	}

	function log(address p0, uint256 p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint256,string,bool)", p0, p1, p2, p3));
	}

	function log(address p0, uint256 p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint256,string,address)", p0, p1, p2, p3));
	}

	function log(address p0, uint256 p1, bool p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint256,bool,uint256)", p0, p1, p2, p3));
	}

	function log(address p0, uint256 p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint256,bool,string)", p0, p1, p2, p3));
	}

	function log(address p0, uint256 p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint256,bool,bool)", p0, p1, p2, p3));
	}

	function log(address p0, uint256 p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint256,bool,address)", p0, p1, p2, p3));
	}

	function log(address p0, uint256 p1, address p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint256,address,uint256)", p0, p1, p2, p3));
	}

	function log(address p0, uint256 p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint256,address,string)", p0, p1, p2, p3));
	}

	function log(address p0, uint256 p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint256,address,bool)", p0, p1, p2, p3));
	}

	function log(address p0, uint256 p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint256,address,address)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, uint256 p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,uint256,uint256)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, uint256 p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,uint256,string)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, uint256 p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,uint256,bool)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, uint256 p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,uint256,address)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, string memory p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,string,uint256)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,string,string)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,string,bool)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,string,address)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, bool p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,bool,uint256)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,bool,string)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,bool,bool)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,bool,address)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, address p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,address,uint256)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,address,string)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,address,bool)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,address,address)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, uint256 p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,uint256,uint256)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, uint256 p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,uint256,string)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, uint256 p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,uint256,bool)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, uint256 p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,uint256,address)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, string memory p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,string,uint256)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,string,string)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,string,bool)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,string,address)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, bool p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,bool,uint256)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,bool,string)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,bool,bool)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,bool,address)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, address p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,address,uint256)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,address,string)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,address,bool)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,address,address)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, uint256 p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,uint256,uint256)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, uint256 p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,uint256,string)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, uint256 p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,uint256,bool)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, uint256 p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,uint256,address)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, string memory p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,string,uint256)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,string,string)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,string,bool)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,string,address)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, bool p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,bool,uint256)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,bool,string)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,bool,bool)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,bool,address)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, address p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,address,uint256)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,address,string)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,address,bool)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,address,address)", p0, p1, p2, p3));
	}

}
