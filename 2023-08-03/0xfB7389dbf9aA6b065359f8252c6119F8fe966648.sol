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
    function _upgradeToAndCall(
        address newImplementation,
        bytes memory data,
        bool forceCall
    ) internal {
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
    function _upgradeToAndCallUUPS(
        address newImplementation,
        bytes memory data,
        bool forceCall
    ) internal {
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
    function _upgradeBeaconToAndCall(
        address newBeacon,
        bytes memory data,
        bool forceCall
    ) internal {
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
    function _functionDelegateCall(address target, bytes memory data) private returns (bytes memory) {
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
// OpenZeppelin Contracts (last updated v4.8.0) (proxy/utils/Initializable.sol)

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
        if (_initialized < type(uint8).max) {
            _initialized = type(uint8).max;
            emit Initialized(type(uint8).max);
        }
    }

    /**
     * @dev Internal function that returns the initialized version. Returns `_initialized`
     */
    function _getInitializedVersion() internal view returns (uint8) {
        return _initialized;
    }

    /**
     * @dev Internal function that returns the initialized version. Returns `_initializing`
     */
    function _isInitializing() internal view returns (bool) {
        return _initializing;
    }
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
// OpenZeppelin Contracts (last updated v4.6.0) (proxy/Proxy.sol)

pragma solidity ^0.8.0;

/**
 * @dev This abstract contract provides a fallback function that delegates all calls to another contract using the EVM
 * instruction `delegatecall`. We refer to the second contract as the _implementation_ behind the proxy, and it has to
 * be specified by overriding the virtual {_implementation} function.
 *
 * Additionally, delegation to the implementation can be triggered manually through the {_fallback} function, or to a
 * different contract through the {_delegate} function.
 *
 * The success and return data of the delegated call will be returned back to the caller of the proxy.
 */
abstract contract Proxy {
    /**
     * @dev Delegates the current call to `implementation`.
     *
     * This function does not return to its internal call site, it will return directly to the external caller.
     */
    function _delegate(address implementation) internal virtual {
        assembly {
            // Copy msg.data. We take full control of memory in this inline assembly
            // block because it will not return to Solidity code. We overwrite the
            // Solidity scratch pad at memory position 0.
            calldatacopy(0, 0, calldatasize())

            // Call the implementation.
            // out and outsize are 0 because we don't know the size yet.
            let result := delegatecall(gas(), implementation, 0, calldatasize(), 0, 0)

            // Copy the returned data.
            returndatacopy(0, 0, returndatasize())

            switch result
            // delegatecall returns 0 on error.
            case 0 {
                revert(0, returndatasize())
            }
            default {
                return(0, returndatasize())
            }
        }
    }

    /**
     * @dev This is a virtual function that should be overridden so it returns the address to which the fallback function
     * and {_fallback} should delegate.
     */
    function _implementation() internal view virtual returns (address);

    /**
     * @dev Delegates the current call to the address returned by `_implementation()`.
     *
     * This function does not return to its internal call site, it will return directly to the external caller.
     */
    function _fallback() internal virtual {
        _beforeFallback();
        _delegate(_implementation());
    }

    /**
     * @dev Fallback function that delegates calls to the address returned by `_implementation()`. Will run if no other
     * function in the contract matches the call data.
     */
    fallback() external payable virtual {
        _fallback();
    }

    /**
     * @dev Fallback function that delegates calls to the address returned by `_implementation()`. Will run if call data
     * is empty.
     */
    receive() external payable virtual {
        _fallback();
    }

    /**
     * @dev Hook that is called before falling back to the implementation. Can happen as part of a manual `_fallback`
     * call, or as part of the Solidity `fallback` or `receive` functions.
     *
     * If overridden should call `super._beforeFallback()`.
     */
    function _beforeFallback() internal virtual {}
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (proxy/utils/Initializable.sol)

pragma solidity ^0.8.2;

import "../../utils/Address.sol";

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
            (isTopLevelCall && _initialized < 1) || (!Address.isContract(address(this)) && _initialized == 1),
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
        if (_initialized < type(uint8).max) {
            _initialized = type(uint8).max;
            emit Initialized(type(uint8).max);
        }
    }

    /**
     * @dev Internal function that returns the initialized version. Returns `_initialized`
     */
    function _getInitializedVersion() internal view returns (uint8) {
        return _initialized;
    }

    /**
     * @dev Internal function that returns the initialized version. Returns `_initializing`
     */
    function _isInitializing() internal view returns (bool) {
        return _initializing;
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
// OpenZeppelin Contracts (last updated v4.8.0) (security/ReentrancyGuard.sol)

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
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (token/ERC1155/ERC1155.sol)

pragma solidity ^0.8.0;

import "./IERC1155.sol";
import "./IERC1155Receiver.sol";
import "./extensions/IERC1155MetadataURI.sol";
import "../../utils/Address.sol";
import "../../utils/Context.sol";
import "../../utils/introspection/ERC165.sol";

/**
 * @dev Implementation of the basic standard multi-token.
 * See https://eips.ethereum.org/EIPS/eip-1155
 * Originally based on code by Enjin: https://github.com/enjin/erc-1155
 *
 * _Available since v3.1._
 */
contract ERC1155 is Context, ERC165, IERC1155, IERC1155MetadataURI {
    using Address for address;

    // Mapping from token ID to account balances
    mapping(uint256 => mapping(address => uint256)) private _balances;

    // Mapping from account to operator approvals
    mapping(address => mapping(address => bool)) private _operatorApprovals;

    // Used as the URI for all token types by relying on ID substitution, e.g. https://token-cdn-domain/{id}.json
    string private _uri;

    /**
     * @dev See {_setURI}.
     */
    constructor(string memory uri_) {
        _setURI(uri_);
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {
        return
            interfaceId == type(IERC1155).interfaceId ||
            interfaceId == type(IERC1155MetadataURI).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    /**
     * @dev See {IERC1155MetadataURI-uri}.
     *
     * This implementation returns the same URI for *all* token types. It relies
     * on the token type ID substitution mechanism
     * https://eips.ethereum.org/EIPS/eip-1155#metadata[defined in the EIP].
     *
     * Clients calling this function must replace the `\{id\}` substring with the
     * actual token type ID.
     */
    function uri(uint256) public view virtual override returns (string memory) {
        return _uri;
    }

    /**
     * @dev See {IERC1155-balanceOf}.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function balanceOf(address account, uint256 id) public view virtual override returns (uint256) {
        require(account != address(0), "ERC1155: address zero is not a valid owner");
        return _balances[id][account];
    }

    /**
     * @dev See {IERC1155-balanceOfBatch}.
     *
     * Requirements:
     *
     * - `accounts` and `ids` must have the same length.
     */
    function balanceOfBatch(address[] memory accounts, uint256[] memory ids)
        public
        view
        virtual
        override
        returns (uint256[] memory)
    {
        require(accounts.length == ids.length, "ERC1155: accounts and ids length mismatch");

        uint256[] memory batchBalances = new uint256[](accounts.length);

        for (uint256 i = 0; i < accounts.length; ++i) {
            batchBalances[i] = balanceOf(accounts[i], ids[i]);
        }

        return batchBalances;
    }

    /**
     * @dev See {IERC1155-setApprovalForAll}.
     */
    function setApprovalForAll(address operator, bool approved) public virtual override {
        _setApprovalForAll(_msgSender(), operator, approved);
    }

    /**
     * @dev See {IERC1155-isApprovedForAll}.
     */
    function isApprovedForAll(address account, address operator) public view virtual override returns (bool) {
        return _operatorApprovals[account][operator];
    }

    /**
     * @dev See {IERC1155-safeTransferFrom}.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) public virtual override {
        require(
            from == _msgSender() || isApprovedForAll(from, _msgSender()),
            "ERC1155: caller is not token owner or approved"
        );
        _safeTransferFrom(from, to, id, amount, data);
    }

    /**
     * @dev See {IERC1155-safeBatchTransferFrom}.
     */
    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) public virtual override {
        require(
            from == _msgSender() || isApprovedForAll(from, _msgSender()),
            "ERC1155: caller is not token owner or approved"
        );
        _safeBatchTransferFrom(from, to, ids, amounts, data);
    }

    /**
     * @dev Transfers `amount` tokens of token type `id` from `from` to `to`.
     *
     * Emits a {TransferSingle} event.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - `from` must have a balance of tokens of type `id` of at least `amount`.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155Received} and return the
     * acceptance magic value.
     */
    function _safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) internal virtual {
        require(to != address(0), "ERC1155: transfer to the zero address");

        address operator = _msgSender();
        uint256[] memory ids = _asSingletonArray(id);
        uint256[] memory amounts = _asSingletonArray(amount);

        _beforeTokenTransfer(operator, from, to, ids, amounts, data);

        uint256 fromBalance = _balances[id][from];
        require(fromBalance >= amount, "ERC1155: insufficient balance for transfer");
        unchecked {
            _balances[id][from] = fromBalance - amount;
        }
        _balances[id][to] += amount;

        emit TransferSingle(operator, from, to, id, amount);

        _afterTokenTransfer(operator, from, to, ids, amounts, data);

        _doSafeTransferAcceptanceCheck(operator, from, to, id, amount, data);
    }

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {_safeTransferFrom}.
     *
     * Emits a {TransferBatch} event.
     *
     * Requirements:
     *
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155BatchReceived} and return the
     * acceptance magic value.
     */
    function _safeBatchTransferFrom(
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual {
        require(ids.length == amounts.length, "ERC1155: ids and amounts length mismatch");
        require(to != address(0), "ERC1155: transfer to the zero address");

        address operator = _msgSender();

        _beforeTokenTransfer(operator, from, to, ids, amounts, data);

        for (uint256 i = 0; i < ids.length; ++i) {
            uint256 id = ids[i];
            uint256 amount = amounts[i];

            uint256 fromBalance = _balances[id][from];
            require(fromBalance >= amount, "ERC1155: insufficient balance for transfer");
            unchecked {
                _balances[id][from] = fromBalance - amount;
            }
            _balances[id][to] += amount;
        }

        emit TransferBatch(operator, from, to, ids, amounts);

        _afterTokenTransfer(operator, from, to, ids, amounts, data);

        _doSafeBatchTransferAcceptanceCheck(operator, from, to, ids, amounts, data);
    }

    /**
     * @dev Sets a new URI for all token types, by relying on the token type ID
     * substitution mechanism
     * https://eips.ethereum.org/EIPS/eip-1155#metadata[defined in the EIP].
     *
     * By this mechanism, any occurrence of the `\{id\}` substring in either the
     * URI or any of the amounts in the JSON file at said URI will be replaced by
     * clients with the token type ID.
     *
     * For example, the `https://token-cdn-domain/\{id\}.json` URI would be
     * interpreted by clients as
     * `https://token-cdn-domain/000000000000000000000000000000000000000000000000000000000004cce0.json`
     * for token type ID 0x4cce0.
     *
     * See {uri}.
     *
     * Because these URIs cannot be meaningfully represented by the {URI} event,
     * this function emits no events.
     */
    function _setURI(string memory newuri) internal virtual {
        _uri = newuri;
    }

    /**
     * @dev Creates `amount` tokens of token type `id`, and assigns them to `to`.
     *
     * Emits a {TransferSingle} event.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155Received} and return the
     * acceptance magic value.
     */
    function _mint(
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) internal virtual {
        require(to != address(0), "ERC1155: mint to the zero address");

        address operator = _msgSender();
        uint256[] memory ids = _asSingletonArray(id);
        uint256[] memory amounts = _asSingletonArray(amount);

        _beforeTokenTransfer(operator, address(0), to, ids, amounts, data);

        _balances[id][to] += amount;
        emit TransferSingle(operator, address(0), to, id, amount);

        _afterTokenTransfer(operator, address(0), to, ids, amounts, data);

        _doSafeTransferAcceptanceCheck(operator, address(0), to, id, amount, data);
    }

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {_mint}.
     *
     * Emits a {TransferBatch} event.
     *
     * Requirements:
     *
     * - `ids` and `amounts` must have the same length.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155BatchReceived} and return the
     * acceptance magic value.
     */
    function _mintBatch(
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual {
        require(to != address(0), "ERC1155: mint to the zero address");
        require(ids.length == amounts.length, "ERC1155: ids and amounts length mismatch");

        address operator = _msgSender();

        _beforeTokenTransfer(operator, address(0), to, ids, amounts, data);

        for (uint256 i = 0; i < ids.length; i++) {
            _balances[ids[i]][to] += amounts[i];
        }

        emit TransferBatch(operator, address(0), to, ids, amounts);

        _afterTokenTransfer(operator, address(0), to, ids, amounts, data);

        _doSafeBatchTransferAcceptanceCheck(operator, address(0), to, ids, amounts, data);
    }

    /**
     * @dev Destroys `amount` tokens of token type `id` from `from`
     *
     * Emits a {TransferSingle} event.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `from` must have at least `amount` tokens of token type `id`.
     */
    function _burn(
        address from,
        uint256 id,
        uint256 amount
    ) internal virtual {
        require(from != address(0), "ERC1155: burn from the zero address");

        address operator = _msgSender();
        uint256[] memory ids = _asSingletonArray(id);
        uint256[] memory amounts = _asSingletonArray(amount);

        _beforeTokenTransfer(operator, from, address(0), ids, amounts, "");

        uint256 fromBalance = _balances[id][from];
        require(fromBalance >= amount, "ERC1155: burn amount exceeds balance");
        unchecked {
            _balances[id][from] = fromBalance - amount;
        }

        emit TransferSingle(operator, from, address(0), id, amount);

        _afterTokenTransfer(operator, from, address(0), ids, amounts, "");
    }

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {_burn}.
     *
     * Emits a {TransferBatch} event.
     *
     * Requirements:
     *
     * - `ids` and `amounts` must have the same length.
     */
    function _burnBatch(
        address from,
        uint256[] memory ids,
        uint256[] memory amounts
    ) internal virtual {
        require(from != address(0), "ERC1155: burn from the zero address");
        require(ids.length == amounts.length, "ERC1155: ids and amounts length mismatch");

        address operator = _msgSender();

        _beforeTokenTransfer(operator, from, address(0), ids, amounts, "");

        for (uint256 i = 0; i < ids.length; i++) {
            uint256 id = ids[i];
            uint256 amount = amounts[i];

            uint256 fromBalance = _balances[id][from];
            require(fromBalance >= amount, "ERC1155: burn amount exceeds balance");
            unchecked {
                _balances[id][from] = fromBalance - amount;
            }
        }

        emit TransferBatch(operator, from, address(0), ids, amounts);

        _afterTokenTransfer(operator, from, address(0), ids, amounts, "");
    }

    /**
     * @dev Approve `operator` to operate on all of `owner` tokens
     *
     * Emits an {ApprovalForAll} event.
     */
    function _setApprovalForAll(
        address owner,
        address operator,
        bool approved
    ) internal virtual {
        require(owner != operator, "ERC1155: setting approval status for self");
        _operatorApprovals[owner][operator] = approved;
        emit ApprovalForAll(owner, operator, approved);
    }

    /**
     * @dev Hook that is called before any token transfer. This includes minting
     * and burning, as well as batched variants.
     *
     * The same hook is called on both single and batched variants. For single
     * transfers, the length of the `ids` and `amounts` arrays will be 1.
     *
     * Calling conditions (for each `id` and `amount` pair):
     *
     * - When `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * of token type `id` will be  transferred to `to`.
     * - When `from` is zero, `amount` tokens of token type `id` will be minted
     * for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens of token type `id`
     * will be burned.
     * - `from` and `to` are never both zero.
     * - `ids` and `amounts` have the same, non-zero length.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual {}

    /**
     * @dev Hook that is called after any token transfer. This includes minting
     * and burning, as well as batched variants.
     *
     * The same hook is called on both single and batched variants. For single
     * transfers, the length of the `id` and `amount` arrays will be 1.
     *
     * Calling conditions (for each `id` and `amount` pair):
     *
     * - When `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * of token type `id` will be  transferred to `to`.
     * - When `from` is zero, `amount` tokens of token type `id` will be minted
     * for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens of token type `id`
     * will be burned.
     * - `from` and `to` are never both zero.
     * - `ids` and `amounts` have the same, non-zero length.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual {}

    function _doSafeTransferAcceptanceCheck(
        address operator,
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) private {
        if (to.isContract()) {
            try IERC1155Receiver(to).onERC1155Received(operator, from, id, amount, data) returns (bytes4 response) {
                if (response != IERC1155Receiver.onERC1155Received.selector) {
                    revert("ERC1155: ERC1155Receiver rejected tokens");
                }
            } catch Error(string memory reason) {
                revert(reason);
            } catch {
                revert("ERC1155: transfer to non-ERC1155Receiver implementer");
            }
        }
    }

    function _doSafeBatchTransferAcceptanceCheck(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) private {
        if (to.isContract()) {
            try IERC1155Receiver(to).onERC1155BatchReceived(operator, from, ids, amounts, data) returns (
                bytes4 response
            ) {
                if (response != IERC1155Receiver.onERC1155BatchReceived.selector) {
                    revert("ERC1155: ERC1155Receiver rejected tokens");
                }
            } catch Error(string memory reason) {
                revert(reason);
            } catch {
                revert("ERC1155: transfer to non-ERC1155Receiver implementer");
            }
        }
    }

    function _asSingletonArray(uint256 element) private pure returns (uint256[] memory) {
        uint256[] memory array = new uint256[](1);
        array[0] = element;

        return array;
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC1155/extensions/IERC1155MetadataURI.sol)

pragma solidity ^0.8.0;

import "../IERC1155.sol";

/**
 * @dev Interface of the optional ERC1155MetadataExtension interface, as defined
 * in the https://eips.ethereum.org/EIPS/eip-1155#metadata-extensions[EIP].
 *
 * _Available since v3.1._
 */
interface IERC1155MetadataURI is IERC1155 {
    /**
     * @dev Returns the URI for token type `id`.
     *
     * If the `\{id\}` substring is present in the URI, it must be replaced by
     * clients with the actual token type ID.
     */
    function uri(uint256 id) external view returns (string memory);
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC1155/IERC1155.sol)

pragma solidity ^0.8.0;

import "../../utils/introspection/IERC165.sol";

/**
 * @dev Required interface of an ERC1155 compliant contract, as defined in the
 * https://eips.ethereum.org/EIPS/eip-1155[EIP].
 *
 * _Available since v3.1._
 */
interface IERC1155 is IERC165 {
    /**
     * @dev Emitted when `value` tokens of token type `id` are transferred from `from` to `to` by `operator`.
     */
    event TransferSingle(address indexed operator, address indexed from, address indexed to, uint256 id, uint256 value);

    /**
     * @dev Equivalent to multiple {TransferSingle} events, where `operator`, `from` and `to` are the same for all
     * transfers.
     */
    event TransferBatch(
        address indexed operator,
        address indexed from,
        address indexed to,
        uint256[] ids,
        uint256[] values
    );

    /**
     * @dev Emitted when `account` grants or revokes permission to `operator` to transfer their tokens, according to
     * `approved`.
     */
    event ApprovalForAll(address indexed account, address indexed operator, bool approved);

    /**
     * @dev Emitted when the URI for token type `id` changes to `value`, if it is a non-programmatic URI.
     *
     * If an {URI} event was emitted for `id`, the standard
     * https://eips.ethereum.org/EIPS/eip-1155#metadata-extensions[guarantees] that `value` will equal the value
     * returned by {IERC1155MetadataURI-uri}.
     */
    event URI(string value, uint256 indexed id);

    /**
     * @dev Returns the amount of tokens of token type `id` owned by `account`.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function balanceOf(address account, uint256 id) external view returns (uint256);

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {balanceOf}.
     *
     * Requirements:
     *
     * - `accounts` and `ids` must have the same length.
     */
    function balanceOfBatch(address[] calldata accounts, uint256[] calldata ids)
        external
        view
        returns (uint256[] memory);

    /**
     * @dev Grants or revokes permission to `operator` to transfer the caller's tokens, according to `approved`,
     *
     * Emits an {ApprovalForAll} event.
     *
     * Requirements:
     *
     * - `operator` cannot be the caller.
     */
    function setApprovalForAll(address operator, bool approved) external;

    /**
     * @dev Returns true if `operator` is approved to transfer ``account``'s tokens.
     *
     * See {setApprovalForAll}.
     */
    function isApprovedForAll(address account, address operator) external view returns (bool);

    /**
     * @dev Transfers `amount` tokens of token type `id` from `from` to `to`.
     *
     * Emits a {TransferSingle} event.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - If the caller is not `from`, it must have been approved to spend ``from``'s tokens via {setApprovalForAll}.
     * - `from` must have a balance of tokens of type `id` of at least `amount`.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155Received} and return the
     * acceptance magic value.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes calldata data
    ) external;

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {safeTransferFrom}.
     *
     * Emits a {TransferBatch} event.
     *
     * Requirements:
     *
     * - `ids` and `amounts` must have the same length.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155BatchReceived} and return the
     * acceptance magic value.
     */
    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] calldata ids,
        uint256[] calldata amounts,
        bytes calldata data
    ) external;
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC1155/IERC1155Receiver.sol)

pragma solidity ^0.8.0;

import "../../utils/introspection/IERC165.sol";

/**
 * @dev _Available since v3.1._
 */
interface IERC1155Receiver is IERC165 {
    /**
     * @dev Handles the receipt of a single ERC1155 token type. This function is
     * called at the end of a `safeTransferFrom` after the balance has been updated.
     *
     * NOTE: To accept the transfer, this must return
     * `bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"))`
     * (i.e. 0xf23a6e61, or its own function selector).
     *
     * @param operator The address which initiated the transfer (i.e. msg.sender)
     * @param from The address which previously owned the token
     * @param id The ID of the token being transferred
     * @param value The amount of tokens being transferred
     * @param data Additional data with no specified format
     * @return `bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"))` if transfer is allowed
     */
    function onERC1155Received(
        address operator,
        address from,
        uint256 id,
        uint256 value,
        bytes calldata data
    ) external returns (bytes4);

    /**
     * @dev Handles the receipt of a multiple ERC1155 token types. This function
     * is called at the end of a `safeBatchTransferFrom` after the balances have
     * been updated.
     *
     * NOTE: To accept the transfer(s), this must return
     * `bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"))`
     * (i.e. 0xbc197c81, or its own function selector).
     *
     * @param operator The address which initiated the batch transfer (i.e. msg.sender)
     * @param from The address which previously owned the token
     * @param ids An array containing ids of each token being transferred (order and length must match values array)
     * @param values An array containing amounts of each token being transferred (order and length must match ids array)
     * @param data Additional data with no specified format
     * @return `bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"))` if transfer is allowed
     */
    function onERC1155BatchReceived(
        address operator,
        address from,
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata data
    ) external returns (bytes4);
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (token/ERC20/ERC20.sol)

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
     * The default value of {decimals} is 18. To select a different value for
     * {decimals} you should overload it.
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
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
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
    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
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
    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
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
    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
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
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

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
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
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
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/ERC20Capped.sol)

pragma solidity ^0.8.0;

import "../ERC20.sol";

/**
 * @dev Extension of {ERC20} that adds a cap to the supply of tokens.
 */
abstract contract ERC20Capped is ERC20 {
    uint256 private immutable _cap;

    /**
     * @dev Sets the value of the `cap`. This value is immutable, it can only be
     * set once during construction.
     */
    constructor(uint256 cap_) {
        require(cap_ > 0, "ERC20Capped: cap is 0");
        _cap = cap_;
    }

    /**
     * @dev Returns the cap on the token's total supply.
     */
    function cap() public view virtual returns (uint256) {
        return _cap;
    }

    /**
     * @dev See {ERC20-_mint}.
     */
    function _mint(address account, uint256 amount) internal virtual override {
        require(ERC20.totalSupply() + amount <= cap(), "ERC20Capped: cap exceeded");
        super._mint(account, amount);
    }
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
// OpenZeppelin Contracts (last updated v4.8.0) (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";
import "../extensions/draft-IERC20Permit.sol";
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

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20 token,
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
        IERC20 token,
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
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
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
        if (returndata.length > 0) {
            // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (token/ERC721/ERC721.sol)

pragma solidity ^0.8.0;

import "./IERC721.sol";
import "./IERC721Receiver.sol";
import "./extensions/IERC721Metadata.sol";
import "../../utils/Address.sol";
import "../../utils/Context.sol";
import "../../utils/Strings.sol";
import "../../utils/introspection/ERC165.sol";

/**
 * @dev Implementation of https://eips.ethereum.org/EIPS/eip-721[ERC721] Non-Fungible Token Standard, including
 * the Metadata extension, but not including the Enumerable extension, which is available separately as
 * {ERC721Enumerable}.
 */
contract ERC721 is Context, ERC165, IERC721, IERC721Metadata {
    using Address for address;
    using Strings for uint256;

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
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {
        return
            interfaceId == type(IERC721).interfaceId ||
            interfaceId == type(IERC721Metadata).interfaceId ||
            super.supportsInterface(interfaceId);
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
    function approve(address to, uint256 tokenId) public virtual override {
        address owner = ERC721.ownerOf(tokenId);
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
    function setApprovalForAll(address operator, bool approved) public virtual override {
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
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {
        //solhint-disable-next-line max-line-length
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: caller is not token owner or approved");

        _transfer(from, to, tokenId);
    }

    /**
     * @dev See {IERC721-safeTransferFrom}.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {
        safeTransferFrom(from, to, tokenId, "");
    }

    /**
     * @dev See {IERC721-safeTransferFrom}.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory data
    ) public virtual override {
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
    function _safeTransfer(
        address from,
        address to,
        uint256 tokenId,
        bytes memory data
    ) internal virtual {
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
        address owner = ERC721.ownerOf(tokenId);
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
    function _safeMint(address to, uint256 tokenId) internal virtual {
        _safeMint(to, tokenId, "");
    }

    /**
     * @dev Same as {xref-ERC721-_safeMint-address-uint256-}[`_safeMint`], with an additional `data` parameter which is
     * forwarded in {IERC721Receiver-onERC721Received} to contract recipients.
     */
    function _safeMint(
        address to,
        uint256 tokenId,
        bytes memory data
    ) internal virtual {
        _mint(to, tokenId);
        require(
            _checkOnERC721Received(address(0), to, tokenId, data),
            "ERC721: transfer to non ERC721Receiver implementer"
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
    function _mint(address to, uint256 tokenId) internal virtual {
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
    function _burn(uint256 tokenId) internal virtual {
        address owner = ERC721.ownerOf(tokenId);

        _beforeTokenTransfer(owner, address(0), tokenId, 1);

        // Update ownership in case tokenId was transferred by `_beforeTokenTransfer` hook
        owner = ERC721.ownerOf(tokenId);

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
    function _transfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {
        require(ERC721.ownerOf(tokenId) == from, "ERC721: transfer from incorrect owner");
        require(to != address(0), "ERC721: transfer to the zero address");

        _beforeTokenTransfer(from, to, tokenId, 1);

        // Check that tokenId was not transferred by `_beforeTokenTransfer` hook
        require(ERC721.ownerOf(tokenId) == from, "ERC721: transfer from incorrect owner");

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
    function _approve(address to, uint256 tokenId) internal virtual {
        _tokenApprovals[tokenId] = to;
        emit Approval(ERC721.ownerOf(tokenId), to, tokenId);
    }

    /**
     * @dev Approve `operator` to operate on all of `owner` tokens
     *
     * Emits an {ApprovalForAll} event.
     */
    function _setApprovalForAll(
        address owner,
        address operator,
        bool approved
    ) internal virtual {
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
    function _checkOnERC721Received(
        address from,
        address to,
        uint256 tokenId,
        bytes memory data
    ) private returns (bool) {
        if (to.isContract()) {
            try IERC721Receiver(to).onERC721Received(_msgSender(), from, tokenId, data) returns (bytes4 retval) {
                return retval == IERC721Receiver.onERC721Received.selector;
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
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256, /* firstTokenId */
        uint256 batchSize
    ) internal virtual {
        if (batchSize > 1) {
            if (from != address(0)) {
                _balances[from] -= batchSize;
            }
            if (to != address(0)) {
                _balances[to] += batchSize;
            }
        }
    }

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
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 firstTokenId,
        uint256 batchSize
    ) internal virtual {}
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (token/ERC721/extensions/ERC721Enumerable.sol)

pragma solidity ^0.8.0;

import "../ERC721.sol";
import "./IERC721Enumerable.sol";

/**
 * @dev This implements an optional extension of {ERC721} defined in the EIP that adds
 * enumerability of all the token ids in the contract as well as all token ids owned by each
 * account.
 */
abstract contract ERC721Enumerable is ERC721, IERC721Enumerable {
    // Mapping from owner to list of owned token IDs
    mapping(address => mapping(uint256 => uint256)) private _ownedTokens;

    // Mapping from token ID to index of the owner tokens list
    mapping(uint256 => uint256) private _ownedTokensIndex;

    // Array with all token ids, used for enumeration
    uint256[] private _allTokens;

    // Mapping from token id to position in the allTokens array
    mapping(uint256 => uint256) private _allTokensIndex;

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(IERC165, ERC721) returns (bool) {
        return interfaceId == type(IERC721Enumerable).interfaceId || super.supportsInterface(interfaceId);
    }

    /**
     * @dev See {IERC721Enumerable-tokenOfOwnerByIndex}.
     */
    function tokenOfOwnerByIndex(address owner, uint256 index) public view virtual override returns (uint256) {
        require(index < ERC721.balanceOf(owner), "ERC721Enumerable: owner index out of bounds");
        return _ownedTokens[owner][index];
    }

    /**
     * @dev See {IERC721Enumerable-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _allTokens.length;
    }

    /**
     * @dev See {IERC721Enumerable-tokenByIndex}.
     */
    function tokenByIndex(uint256 index) public view virtual override returns (uint256) {
        require(index < ERC721Enumerable.totalSupply(), "ERC721Enumerable: global index out of bounds");
        return _allTokens[index];
    }

    /**
     * @dev See {ERC721-_beforeTokenTransfer}.
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 firstTokenId,
        uint256 batchSize
    ) internal virtual override {
        super._beforeTokenTransfer(from, to, firstTokenId, batchSize);

        if (batchSize > 1) {
            // Will only trigger during construction. Batch transferring (minting) is not available afterwards.
            revert("ERC721Enumerable: consecutive transfers not supported");
        }

        uint256 tokenId = firstTokenId;

        if (from == address(0)) {
            _addTokenToAllTokensEnumeration(tokenId);
        } else if (from != to) {
            _removeTokenFromOwnerEnumeration(from, tokenId);
        }
        if (to == address(0)) {
            _removeTokenFromAllTokensEnumeration(tokenId);
        } else if (to != from) {
            _addTokenToOwnerEnumeration(to, tokenId);
        }
    }

    /**
     * @dev Private function to add a token to this extension's ownership-tracking data structures.
     * @param to address representing the new owner of the given token ID
     * @param tokenId uint256 ID of the token to be added to the tokens list of the given address
     */
    function _addTokenToOwnerEnumeration(address to, uint256 tokenId) private {
        uint256 length = ERC721.balanceOf(to);
        _ownedTokens[to][length] = tokenId;
        _ownedTokensIndex[tokenId] = length;
    }

    /**
     * @dev Private function to add a token to this extension's token tracking data structures.
     * @param tokenId uint256 ID of the token to be added to the tokens list
     */
    function _addTokenToAllTokensEnumeration(uint256 tokenId) private {
        _allTokensIndex[tokenId] = _allTokens.length;
        _allTokens.push(tokenId);
    }

    /**
     * @dev Private function to remove a token from this extension's ownership-tracking data structures. Note that
     * while the token is not assigned a new owner, the `_ownedTokensIndex` mapping is _not_ updated: this allows for
     * gas optimizations e.g. when performing a transfer operation (avoiding double writes).
     * This has O(1) time complexity, but alters the order of the _ownedTokens array.
     * @param from address representing the previous owner of the given token ID
     * @param tokenId uint256 ID of the token to be removed from the tokens list of the given address
     */
    function _removeTokenFromOwnerEnumeration(address from, uint256 tokenId) private {
        // To prevent a gap in from's tokens array, we store the last token in the index of the token to delete, and
        // then delete the last slot (swap and pop).

        uint256 lastTokenIndex = ERC721.balanceOf(from) - 1;
        uint256 tokenIndex = _ownedTokensIndex[tokenId];

        // When the token to delete is the last token, the swap operation is unnecessary
        if (tokenIndex != lastTokenIndex) {
            uint256 lastTokenId = _ownedTokens[from][lastTokenIndex];

            _ownedTokens[from][tokenIndex] = lastTokenId; // Move the last token to the slot of the to-delete token
            _ownedTokensIndex[lastTokenId] = tokenIndex; // Update the moved token's index
        }

        // This also deletes the contents at the last position of the array
        delete _ownedTokensIndex[tokenId];
        delete _ownedTokens[from][lastTokenIndex];
    }

    /**
     * @dev Private function to remove a token from this extension's token tracking data structures.
     * This has O(1) time complexity, but alters the order of the _allTokens array.
     * @param tokenId uint256 ID of the token to be removed from the tokens list
     */
    function _removeTokenFromAllTokensEnumeration(uint256 tokenId) private {
        // To prevent a gap in the tokens array, we store the last token in the index of the token to delete, and
        // then delete the last slot (swap and pop).

        uint256 lastTokenIndex = _allTokens.length - 1;
        uint256 tokenIndex = _allTokensIndex[tokenId];

        // When the token to delete is the last token, the swap operation is unnecessary. However, since this occurs so
        // rarely (when the last minted token is burnt) that we still do the swap here to avoid the gas cost of adding
        // an 'if' statement (like in _removeTokenFromOwnerEnumeration)
        uint256 lastTokenId = _allTokens[lastTokenIndex];

        _allTokens[tokenIndex] = lastTokenId; // Move the last token to the slot of the to-delete token
        _allTokensIndex[lastTokenId] = tokenIndex; // Update the moved token's index

        // This also deletes the contents at the last position of the array
        delete _allTokensIndex[tokenId];
        _allTokens.pop();
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC721/extensions/IERC721Enumerable.sol)

pragma solidity ^0.8.0;

import "../IERC721.sol";

/**
 * @title ERC-721 Non-Fungible Token Standard, optional enumeration extension
 * @dev See https://eips.ethereum.org/EIPS/eip-721
 */
interface IERC721Enumerable is IERC721 {
    /**
     * @dev Returns the total amount of tokens stored by the contract.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns a token ID owned by `owner` at a given `index` of its token list.
     * Use along with {balanceOf} to enumerate all of ``owner``'s tokens.
     */
    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256);

    /**
     * @dev Returns a token ID at a given `index` of all the tokens stored by the contract.
     * Use along with {totalSupply} to enumerate all tokens.
     */
    function tokenByIndex(uint256 index) external view returns (uint256);
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC721/extensions/IERC721Metadata.sol)

pragma solidity ^0.8.0;

import "../IERC721.sol";

/**
 * @title ERC-721 Non-Fungible Token Standard, optional metadata extension
 * @dev See https://eips.ethereum.org/EIPS/eip-721
 */
interface IERC721Metadata is IERC721 {
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
// OpenZeppelin Contracts (last updated v4.8.0) (token/ERC721/IERC721.sol)

pragma solidity ^0.8.0;

import "../../utils/introspection/IERC165.sol";

/**
 * @dev Required interface of an ERC721 compliant contract.
 */
interface IERC721 is IERC165 {
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
// OpenZeppelin Contracts (last updated v4.8.0) (utils/Address.sol)

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
// OpenZeppelin Contracts (last updated v4.8.0) (utils/math/Math.sol)

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
// OpenZeppelin Contracts (last updated v4.8.0) (utils/Strings.sol)

pragma solidity ^0.8.0;

import "./math/Math.sol";

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
}
// SPDX-License-Identifier: MIT

pragma solidity >=0.8.4;

import '@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol';
import '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import '../core/SafeOwnable.sol';

contract ERC20Airdrop is SafeOwnable {
    using SafeERC20 for IERC20;

    uint public nonce;

    function ERC20Transfer(uint _startNonce, IERC20 _token, address _vault, address[] memory _users, uint[] memory _amounts) external onlyOwner {
        if (_vault == address(0)) {
            _vault = address(this);
        }
        require(_startNonce > nonce, "already done");
        require(_users.length > 0 && _users.length == _amounts.length, "illegal length");
        for (uint i = 0; i < _users.length; i ++) {
            _token.safeTransferFrom(_vault, _users[i], _amounts[i]);
        }
        nonce = _startNonce + _users.length - 1;
    }

}
// SPDX-License-Identifier: MIT

pragma solidity >=0.8.4;

import '@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol';
import '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import '../interfaces/IMintableERC721V2.sol';
import '../core/SafeOwnable.sol';

contract NFTAirdrop is SafeOwnable {
    using SafeERC20 for IERC20;

    uint public nonce;

    function ERC721Mint(uint _startNonce, IMintableERC721V2 _token, address[] memory _users, uint[] memory _tokenIds) external onlyOwner {
        require(_startNonce > nonce, "already done");
        require(_users.length > 0 && _users.length == _tokenIds.length, "illegal length");
        for (uint i = 0; i < _users.length; i ++) {
            _token.mintById(_users[i], _tokenIds[i]);
        }
        nonce = _startNonce + _users.length - 1;
    }
}
// SPDX-License-Identifier: MIT

pragma solidity >=0.8.4;

import '@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol';
import '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import '../interfaces/IMintableERC721V2.sol';
import '../core/SafeOwnable.sol';

contract NFTAirdropV2 is SafeOwnable {
    using SafeERC20 for IERC20;

    uint public nonce;

    function ERC721Mint(uint _startNonce, IMintableERC721V2 _token, address[] memory _users, uint[] memory _tokenIds) external onlyOwner {
        require(_startNonce > nonce, "already done");
        require(_users.length > 0 && _users.length == _tokenIds.length, "illegal length");
        for (uint i = 0; i < _users.length; i ++) {
            _token.mintById(_users[i], _tokenIds[i]);
        }
        nonce = _startNonce + _users.length - 1;
    }

    function ERC721Transfer(uint _startNonce, address vault, IMintableERC721V2 _token, address[] memory _users, uint[] memory _tokenIds) external onlyOwner {
        require(_startNonce > nonce, "already done");
        require(_users.length > 0 && _users.length == _tokenIds.length, "illegal length");
        if (vault == address(0)) {
            vault = msg.sender;
        }
        for (uint i = 0; i < _users.length; i ++) {
            _token.safeTransferFrom(vault, _users[i], _tokenIds[i]);
        }
        nonce = _startNonce + _users.length - 1;
    }
}
// SPDX-License-Identifier: MIT

pragma solidity >=0.8.4;

import './SafeOwnableInterface.sol';

abstract contract Burnable is SafeOwnableInterface {

    event BurnerChanged(address burner, bool available);
    event BurnerLocked();

    mapping(address => bool) public burners;
    bool public burnerLocked;

    constructor(address[] memory _burners, bool _burnerLocked) {
        for (uint i = 0; i < _burners.length; i ++) {
            require(_burners[i] != address(0), "illegal burner");
            burners[_burners[i]] = true;
            emit BurnerChanged(_burners[i], true);
        }
        if (_burnerLocked) {
            require(_burners.length > 0, "no burner avaliable");
            emit BurnerLocked();
        }
        burnerLocked = _burnerLocked;
    }

    modifier BurnerNotLocked {
        require(!burnerLocked, "minter locked");
        _;
    }

    function addBurner(address _burner) external onlyOwner BurnerNotLocked {
        require(!burners[_burner], "already burner");
        burners[_burner] = true;
        emit BurnerChanged(_burner, true);
    }

    function delBurner(address _burner) external onlyOwner BurnerNotLocked {
        require(burners[_burner], "not a burner");
        delete burners[_burner];
        emit BurnerChanged(_burner, false);
    }

    function burnerLock() external onlyOwner BurnerNotLocked {
        burnerLocked = true;
        emit BurnerLocked();
    }

    modifier onlyBurner() {
        require(burners[msg.sender], "only burner can do this");
        _;
    }

    modifier onlyBurnerSignature(bytes32 _hash, uint8 _v, bytes32 _r, bytes32 _s) {
        address verifier = ecrecover(keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", _hash)), _v, _r, _s);
        require(burners[verifier], "burner verify failed");
        _;
    }

    modifier onlyBurnerOrBurnerSignature(bytes32 _hash, uint8 _v, bytes32 _r, bytes32 _s) {
        if (!burners[msg.sender]) {
            address verifier = ecrecover(keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", _hash)), _v, _r, _s);
            require(burners[verifier], "burner verify failed");
        }
        _;
    }

}
// SPDX-License-Identifier: MIT

pragma solidity >=0.8.4;

import './SafeOwnableInterface.sol';

abstract contract Mintable is SafeOwnableInterface {

    event MinterChanged(address minter, bool available);
    event MinterLocked();

    mapping(address => bool) public minters;
    bool public minterLocked;

    constructor(address[] memory _minters, bool _minterLocked) {
        for (uint i = 0; i < _minters.length; i ++) {
            require(_minters[i] != address(0), "illegal minter");
            minters[_minters[i]] = true;
            emit MinterChanged(_minters[i], true);
        }
        if (_minterLocked) {
            require(_minters.length > 0, "no minter avaliable");
            emit MinterLocked();
        }
        minterLocked = _minterLocked;
    }

    modifier MinterNotLocked {
        require(!minterLocked, "minter locked");
        _;
    }

    function addMinter(address _minter) external onlyOwner MinterNotLocked {
        require(!minters[_minter], "already minter");
        minters[_minter] = true;
        emit MinterChanged(_minter, true);
    }

    function delMinter(address _minter) external onlyOwner MinterNotLocked {
        require(minters[_minter], "not a minter");
        delete minters[_minter];
        emit MinterChanged(_minter, false);
    }

    function minterLock() external onlyOwner MinterNotLocked {
        minterLocked = true;
        emit MinterLocked();
    }

    modifier onlyMinter() {
        require(minters[msg.sender], "only minter can do this");
        _;
    }

    modifier onlyMinterSignature(bytes32 _hash, uint8 _v, bytes32 _r, bytes32 _s) {
        address verifier = ecrecover(keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", _hash)), _v, _r, _s);
        require(minters[verifier], "minter verify failed");
        _;
    }

    modifier onlyMinterOrMinterSignature(bytes32 _hash, uint8 _v, bytes32 _r, bytes32 _s) {
        if (!minters[msg.sender]) {
            address verifier = ecrecover(keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", _hash)), _v, _r, _s);
            require(minters[verifier], "minter verify failed");
        }
        _;
    }

}
// SPDX-License-Identifier: MIT

pragma solidity >=0.8.4;

import '@openzeppelin/contracts/token/ERC721/ERC721.sol';
import '../interfaces/IERC721Core.sol';
import './SafeOwnableInterface.sol';

abstract contract NFTCore is ERC721, IERC721Core, SafeOwnableInterface {

    uint public immutable MAX_SUPPLY;
    string internal baseURI;
    uint public override totalSupply;

    constructor(string memory _name, string memory _symbol, string memory _uri, uint _maxSupply) ERC721(_name, _symbol) {
        baseURI = _uri;
        MAX_SUPPLY = _maxSupply;
    }

    function _baseURI() internal view virtual override(ERC721) returns (string memory) {
        return baseURI;
    }

    function setBaseURI(string memory _newBaseURI) external onlyOwner {
        baseURI = _newBaseURI;
    }

    function mintInternal(address _to, uint _num) internal {
        uint mTotalSupply = totalSupply;
        require(_num > 0 && mTotalSupply + _num <= MAX_SUPPLY, "already full");
        unchecked {
            for (uint i = 0; i < _num; i ++) {
                _mint(_to, mTotalSupply + 1 + i); 
            }
            totalSupply += _num;
        }
    }

    function burnInternal(address _user, uint256 _tokenId) internal {
        require(ownerOf(_tokenId) == _user, "illegal owner");
        require(_isApprovedOrOwner(msg.sender, _tokenId), "caller is not owner nor approved");
        _burn(_tokenId);
    }

}
// SPDX-License-Identifier: MIT

pragma solidity >=0.8.4;

import '@openzeppelin/contracts/token/ERC721/ERC721.sol';
import '../interfaces/IERC721Core.sol';
import './SafeOwnableInterface.sol';

abstract contract NFTCoreV2 is ERC721, IERC721Core, SafeOwnableInterface {

    address public constant BURN_ADDRESS = 0x000000000000000000000000000000000000dEaD;
    uint public immutable MAX_SUPPLY;
    string internal baseURI;
    uint public override totalSupply;

    constructor(string memory _name, string memory _symbol, string memory _uri, uint _maxSupply) ERC721(_name, _symbol) {
        baseURI = _uri;
        MAX_SUPPLY = _maxSupply;
    }

    function _baseURI() internal view virtual override(ERC721) returns (string memory) {
        return baseURI;
    }

    function setBaseURI(string memory _newBaseURI) external onlyOwner {
        baseURI = _newBaseURI;
    }

    function mintInternal(address _to, uint _num) internal {
        uint mTotalSupply = totalSupply;
        require(_num > 0 && mTotalSupply + _num <= MAX_SUPPLY, "already full");
        unchecked {
            for (uint i = 0; i < _num; i ++) {
                _mint(_to, mTotalSupply + 1 + i); 
            }
            totalSupply += _num;
        }
    }

    function burnInternal(address _user, uint256 _tokenId) internal {
        require(ownerOf(_tokenId) == _user, "illegal owner");
        require(_isApprovedOrOwner(msg.sender, _tokenId), "caller is not owner nor approved");
        //_burn(_tokenId);
        _transfer(_user, BURN_ADDRESS, _tokenId);
    }

}
// SPDX-License-Identifier: MIT

pragma solidity >=0.8.4;

import '@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol';
import '../interfaces/IERC721CoreV2.sol';
import './SafeOwnableInterface.sol';

abstract contract NFTCoreV3 is ERC721Enumerable, IERC721CoreV2, SafeOwnableInterface {

    address public constant BURN_ADDRESS = 0x000000000000000000000000000000000000dEaD;
    uint public immutable MAX_SUPPLY;
    string internal baseURI;

    constructor(string memory _name, string memory _symbol, string memory _uri, uint _maxSupply) ERC721(_name, _symbol) {
        baseURI = _uri;
        MAX_SUPPLY = _maxSupply;
    }

    function _baseURI() internal view virtual override(ERC721) returns (string memory) {
        return baseURI;
    }

    function setBaseURI(string memory _newBaseURI) external onlyOwner {
        baseURI = _newBaseURI;
    }

    function mintInternal(address _to, uint _num) internal {
        uint mTotalSupply = totalSupply();
        require(_num > 0 && mTotalSupply + _num <= MAX_SUPPLY, "nft already full");
        unchecked {
            for (uint i = 0; i < _num; i ++) {
                _mint(_to, mTotalSupply + 1 + i); 
            }
        }
    }

    function mintByIdInternal(address _to, uint _tokenId) internal {
        require(_tokenId > 0 && _tokenId <= MAX_SUPPLY && !_exists(_tokenId), "illegal tokenId");
        _mint(_to, _tokenId);
    }

    function burnInternal(address _user, uint256 _tokenId) internal {
        require(ownerOf(_tokenId) == _user, "illegal owner");
        require(_isApprovedOrOwner(msg.sender, _tokenId), "caller is not owner nor approved");
        _transfer(_user, BURN_ADDRESS, _tokenId);
    }

}
// SPDX-License-Identifier: MIT

pragma solidity >=0.8.4;

import '@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol';
import '../interfaces/IERC721CoreV2.sol';
import './SafeOwnableInterface.sol';

abstract contract NFTCoreV4 is ERC721Enumerable, IERC721CoreV2, SafeOwnableInterface {

    address public constant BURN_ADDRESS = 0x000000000000000000000000000000000000dEaD;
    uint public immutable MAX_SUPPLY;
    string internal baseURI;

    constructor(string memory _name, string memory _symbol, string memory _uri, uint _maxSupply) ERC721(_name, _symbol) {
        baseURI = _uri;
        MAX_SUPPLY = _maxSupply;
    }

    function _baseURI() internal view virtual override(ERC721) returns (string memory) {
        return baseURI;
    }

    function setBaseURI(string memory _newBaseURI) external onlyOwner {
        baseURI = _newBaseURI;
    }

    function mintInternal(address _to, uint _num) internal {
        uint mTotalSupply = totalSupply();
        require(_num > 0 && mTotalSupply + _num <= MAX_SUPPLY, "nft already full");
        unchecked {
            for (uint i = 0; i < _num; i ++) {
                _mint(_to, mTotalSupply + 1 + i); 
            }
        }
    }

    function mintByIdInternal(address _to, uint _tokenId) internal {
        require(_tokenId > 0 && _tokenId <= MAX_SUPPLY && !_exists(_tokenId), "illegal tokenId");
        _mint(_to, _tokenId);
    }

    function burnInternal(address _user, uint256 _tokenId) internal {
        require(ownerOf(_tokenId) == _user, "illegal owner");
        require(_isApprovedOrOwner(msg.sender, _tokenId), "caller is not owner nor approved");
        _transfer(_user, BURN_ADDRESS, _tokenId);
    }

    function exists(uint _tokenId) external view returns(bool) {
        return _exists(_tokenId);
    }

}
// SPDX-License-Identifier: MIT

pragma solidity >=0.8.4;

import './SafeOwnableInterface.sol';

abstract contract Operatable is SafeOwnableInterface {

    event OperaterChanged(address operater, bool available);

    mapping(address => bool) public operaters;

    function _addOperator(address _operater) internal {
        require(!operaters[_operater], "already operater");
        operaters[_operater] = true;
        emit OperaterChanged(_operater, true);
    }

    function addOperater(address _operater) external onlyOwner {
        _addOperator(_operater);
    }

    function delOperater(address _operater) external onlyOwner {
        require(operaters[_operater], "not a operater");
        delete operaters[_operater];
        emit OperaterChanged(_operater, false);
    }

    modifier onlyOperater() {
        require(operaters[msg.sender], "only operater can do this");
        _;
    }

    modifier onlyOperaterSignature(bytes32 _hash, uint8 _v, bytes32 _r, bytes32 _s) {
        address verifier = ecrecover(keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", _hash)), _v, _r, _s);
        require(operaters[verifier], "operater verify failed");
        _;
    }

    modifier onlyOperaterOrOperaterSignature(bytes32 _hash, uint8 _v, bytes32 _r, bytes32 _s) {
        if (!operaters[msg.sender]) {
            address verifier = ecrecover(keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", _hash)), _v, _r, _s);
            require(operaters[verifier], "operater verify failed");
        }
        _;
    }

}
// SPDX-License-Identifier: MIT

pragma solidity >=0.8.4;

import '@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol';
import '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import './SafeOwnableInterface.sol';
import '../interfaces/IWETH.sol';
import './TransferCore.sol';

abstract contract ReceiverCore is TransferCore, SafeOwnableInterface {
    using SafeERC20 for IERC20;

    event NewReceiver(address oldValue, address newValue);

    address public receiver;

    constructor(address _receiver, IWETH _weth) TransferCore(_weth) {
        require(_receiver != address(0), "illegal receiver");
        receiver = _receiver;
        emit NewReceiver(address(0), _receiver);
    }

    function setReceiver(address _receiver) external onlyOwner {
        require(_receiver != address(0) && _receiver != receiver, "illegal receiver");
        emit NewReceiver(receiver, _receiver);
        receiver = _receiver;
    }

    function sendToReceiver(IERC20 _token, address _user, uint _amount) internal returns (uint) {
        uint balanceBefore = tokenBalance(_token, receiver);
        tokenTransferFrom(_token, _user, receiver, _amount);
        uint balanceAfter = tokenBalance(_token, receiver);
        return balanceAfter - balanceBefore;
    }

}
// SPDX-License-Identifier: MIT

pragma solidity >=0.8.4;

import './SafeOwnableInterface.sol';

/**
 * This is a contract copied from 'OwnableUpgradeable.sol'
 * It has the same fundation of Ownable, besides it accept pendingOwner for mor Safe Use
 */
abstract contract SafeOwnable is SafeOwnableInterface {
    address private _owner;
    address private _pendingOwner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _transferOwnership(msg.sender);
    }

    function owner() public override view returns (address) {
        return _owner;
    }

    function pendingOwner() public view returns (address) {
        return _pendingOwner;
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function setPendingOwner(address _addr) public onlyOwner {
        _pendingOwner = _addr;
    }

    function acceptOwner() public {
        require(msg.sender == _pendingOwner, "Ownable: caller is not the pendingOwner"); 
        _transferOwnership(_pendingOwner);
        _pendingOwner = address(0);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}
// SPDX-License-Identifier: MIT

pragma solidity >=0.8.4;

/**
 * This is a contract copied from 'OwnableUpgradeable.sol'
 * It has the same fundation of Ownable, besides it accept pendingOwner for mor Safe Use
 */
abstract contract SafeOwnableInterface {

    function owner() public virtual view returns (address);

    modifier onlyOwner() {
        require(owner() == msg.sender, "Ownable: caller is not the owner");
        _;
    }

}
// SPDX-License-Identifier: MIT

pragma solidity >=0.8.4;

import './SafeOwnableInterface.sol';

abstract contract TimeCore is SafeOwnableInterface {

    event StartAtChanged(uint oldValue, uint newValue);
    event FinishAtChanged(uint oldValue, uint newValue);

    uint public startAt;
    uint public finishAt;

    constructor() {
        startAt = 0;
        emit StartAtChanged(0, startAt);
        finishAt = type(uint).max;
        emit FinishAtChanged(0, finishAt);
    }

    function _setStartAt(uint _startAt) internal {
        emit StartAtChanged(startAt, _startAt);
        startAt = _startAt;
    }

    function _setFinishAt(uint _finishAt) internal {
        emit FinishAtChanged(finishAt, _finishAt);
        finishAt = _finishAt;
    }

    function setStartAt(uint _startAt) external onlyOwner {
        _setStartAt(_startAt);
    }

    function setFinishAt(uint _finishAt) external onlyOwner {
        _setFinishAt(_finishAt);
    }

    modifier RightTime() {
        require(block.timestamp >= startAt && block.timestamp <= finishAt, "illegal time");
        _;
    }

    modifier AlreadyBegin() {
        require(block.timestamp >= startAt, "not begin");
        _;
    }

    modifier NotFinish() {
        require(block.timestamp <= finishAt, "already finish");
        _;
    }

}
// SPDX-License-Identifier: MIT

pragma solidity >=0.8.4;

import '@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol';
import '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import './SafeOwnableInterface.sol';
import '../interfaces/IWETH.sol';

abstract contract TransferCore {
    using SafeERC20 for IERC20;

    IWETH public immutable WETH;

    constructor(IWETH _weth) {
        require(address(_weth) != address(0), "illegal weth");
        WETH = _weth;
    }

    function tokenTransferFrom(IERC20 _token, address _from, address _to, uint _amount) internal {
        if (address(_token) == address(WETH)) {
            if (_to == address(this)) {
                require(msg.value >= _amount, "illegal amount");
                WETH.deposit{value: _amount}();
            } else if (_from == address(this)) {
                WETH.withdraw(_amount);
                payable(_to).transfer(_amount);
            } else {
                payable(_to).transfer(_amount);
            }
        } else {
            _token.safeTransferFrom(_from, _to, _amount);
        }
    }

    function tokenBalance(IERC20 _token, address _user) internal view returns (uint) {
        if (address(_token) == address(WETH)) {
            return _user.balance;
        } else {
            return _token.balanceOf(_user);
        }
    }

}
// SPDX-License-Identifier: MIT

pragma solidity >=0.8.4;

import './SafeOwnableInterface.sol';

abstract contract Verifier is SafeOwnableInterface {

    event VerifierChanged(address oldVerifier, address newVerifier);

    address public verifier;

    constructor(address _verifier) {
        require(_verifier != address(0), "illegal verifier");
        verifier = _verifier;
        emit VerifierChanged(address(0), _verifier);
    }

    function setVerifier(address _verifier) external onlyOwner {
        require(_verifier != address(0), "illegal verifier");
        emit VerifierChanged(verifier, _verifier);
        verifier = _verifier;
    }

}
// SPDX-License-Identifier: MIT

pragma solidity >=0.8.4;

import './SafeOwnableInterface.sol';

abstract contract VerifierV2 is SafeOwnableInterface {

    event VerifierChanged(address oldVerifier, address newVerifier);

    address public verifier;

    function _setVerifier(address _verifier) internal {
        require(_verifier != address(0), "illegal verifier");
        emit VerifierChanged(verifier, _verifier);
        verifier = _verifier;
    }

    function setVerifier(address _verifier) external onlyOwner {
        _setVerifier(_verifier);
    }

}
// SPDX-License-Identifier: MIT

pragma solidity >=0.8.4;

import '@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol';
import '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import '../core/ReceiverCore.sol';
import '../core/SafeOwnable.sol';
import '../interfaces/IWETH.sol';
import '../core/TimeCore.sol';

contract ActionEvent is SafeOwnable, TimeCore, ReceiverCore {

    event Action(address user, IERC20 token, uint action, uint price, uint amount, uint total, bytes data, uint timestamp);

    uint constant public PRICE_BASE = 10 ** 18;

    mapping(IERC20 => mapping(uint => uint)) public actions;
    mapping(IERC20 => mapping(uint => bool)) public actionsEnable;

    constructor(address _receiver, IWETH _weth) ReceiverCore(_receiver, _weth) {
    }

    modifier LegalAction(uint action) {
        require(action > 0, "illegal action");
        _;
    }

    function addAction(IERC20 _token, uint _action, uint _price) external onlyOwner {
        actions[_token][_action] = _price;
        actionsEnable[_token][_action] = true;
    }

    function delAction(IERC20 _token, uint _action) external onlyOwner {
        delete actions[_token][_action];
        delete actionsEnable[_token][_action];
    }

    function doAction(IERC20 _token, uint _action, uint _amount, bytes memory data) external payable LegalAction(_action) RightTime {
        require(actionsEnable[_token][_action], "not support");
        uint price = actions[_token][_action];
        require(price > 0, "illegal action");
        uint total = price * _amount / PRICE_BASE;
        if (total > 0) {
            require(sendToReceiver(_token, msg.sender, total) == total, "illegal amount");
        }
        emit Action(msg.sender, _token, _action, price, _amount, total, data, block.timestamp);
        //emit Action(_token, _action, price, _amount, total, 100);
    }

}
// SPDX-License-Identifier: MIT

pragma solidity >=0.8.4;

import '../interfaces/IMintableERC721.sol';
import '../core/SafeOwnable.sol';
import '../core/Verifier.sol';

contract ClassicClaim is SafeOwnable, Verifier {

    event Claim(uint nonce, address user, uint nftId);

    IMintableERC721 public immutable nft;
    uint public immutable startAt;
    uint public immutable finishAt;

    mapping(uint => bool) public nonces;
    uint public totalMintNum;

    constructor(IMintableERC721 _nft, uint _startAt, uint _finishAt, address _verifier) Verifier(_verifier) {
        require(address(_nft) != address(0), "illegal nft");
        nft = _nft;
        require(_startAt > block.timestamp && _finishAt > _startAt, "illegal time");
        startAt = _startAt;
        finishAt = _finishAt;
    }
    
    modifier AlreadyBegin() {
        require(block.timestamp >= startAt, "not begin");
        _;
    }
    
    modifier NotFinish() {
        require(block.timestamp <= finishAt, "already finish");
        _;
    }

    function mint(uint _nonce, uint _num, uint8 _v, bytes32 _r, bytes32 _s) external AlreadyBegin NotFinish {
        require(_num > 0 && !nonces[_nonce], "nonce already used");
        require(
            ecrecover(keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", keccak256(abi.encodePacked(address(this), _nonce, msg.sender, _num)))), _v, _r, _s) == verifier,
            "verify failed"
        );
        nft.mint(msg.sender, _num);
        uint lastTokenId = nft.totalSupply();
        for (uint i = 0; i < _num; i ++) {
            emit Claim(_nonce, msg.sender, lastTokenId - i);
        }
        nonces[_nonce] = true;
        totalMintNum += _num;
    }
}
// SPDX-License-Identifier: MIT

pragma solidity >=0.8.4;

import '@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol';
import '../interfaces/IMintableERC721.sol';
import '../core/SafeOwnable.sol';

contract CostMintV2 is SafeOwnable {
    using SafeERC20 for IERC20;

    event ReceiverChanged(address oldReceiver, address newReceiver);
    event TokenPriceChanged(IERC20 token, uint price, bool avaliable);
    event Buy(address user, IERC20 token, uint price, IMintableERC721 nft, uint256 tokenId);

    address immutable public WETH;
    IMintableERC721 public immutable nft;
    uint public immutable startAt;
    uint public immutable finishAt;
    uint public immutable maxNum;
    uint public immutable userLimit;
    uint public immutable perLimit;

    mapping(IERC20 => bool) public supportTokens;
    mapping(IERC20 => uint) public tokensPrice;
    address payable public receiver;

    uint public sellNum;
    mapping(address => uint) public buyNum;

    constructor(
        address _WETH, 
        IMintableERC721 _nft, 
        uint _startAt, 
        uint _finishAt, 
        uint _maxNum, 
        uint _userLimit, 
        uint _perLimit,
        IERC20[] memory _tokens, 
        uint[] memory _prices, 
        address payable _receiver
    ) {
        require(_WETH != address(0), "illegal WETH");
        WETH = _WETH;
        require(address(_nft) != address(0), "illegal nft");
        nft = _nft;
        require(_startAt > block.timestamp && _finishAt > _startAt, "illegal start or end time");
        startAt = _startAt;
        finishAt = _finishAt;
        require(_userLimit > 0 && _maxNum >= _userLimit, "illegal num");
        maxNum = _maxNum;
        userLimit = _userLimit;
        perLimit = _perLimit;
        require(_tokens.length == _prices.length && _tokens.length > 0, "illegal length");
        for (uint i = 0; i < _tokens.length; i ++) {
            require(address(_tokens[i]) != address(0) && !supportTokens[_tokens[i]], "illegal token");
            supportTokens[_tokens[i]] = true;
            tokensPrice[_tokens[i]] = _prices[i];
            emit TokenPriceChanged(_tokens[i], _prices[i], true);
        }
        require(_receiver != address(0), "illegal receiver");
        receiver = _receiver;
        emit ReceiverChanged(address(0), _receiver);
    }

    function addSupportToken(IERC20 _token, uint _price) external onlyOwner {
        require(address(_token) != address(0) && !supportTokens[_token], "illegal token");
        supportTokens[_token] = true;
        tokensPrice[_token] = _price;
        emit TokenPriceChanged(_token, _price, true);
    }

    function setSupportToken(IERC20 _token, uint _price) external onlyOwner {
        require(supportTokens[_token], "token not exist");
        tokensPrice[_token] = _price;
        emit TokenPriceChanged(_token, _price, true);
    }

    function delSupportToken(IERC20 _token) external onlyOwner {
        require(supportTokens[_token], "token not exist");
        delete supportTokens[_token];
        delete tokensPrice[_token];
        emit TokenPriceChanged(_token, 0, false);
    }

    function setReceiver(address payable _receiver) external onlyOwner {
        require(_receiver != address(0), "illegal receiver");
        emit ReceiverChanged(receiver, _receiver);
        receiver = _receiver;
    }

    modifier AlreadyBegin() {
        require(block.timestamp >= startAt, "not begin");
        _;
    }

    modifier NotFinish() {
        require(block.timestamp <= finishAt, "already finish");
        _;
    }

    modifier TokenSupport(IERC20 _token) {
        require(supportTokens[_token], "token not support");
        _;
    }

    modifier Enough(uint _num) {
        require(sellNum + _num <= maxNum, "already full");
        require(buyNum[msg.sender] + _num <= userLimit, "already limit");
        require(_num <= perLimit, "buy num too much");
        _;
    }

    function buy(IERC20 _payToken, uint _num) external payable AlreadyBegin NotFinish TokenSupport(_payToken) Enough(_num) {
        unchecked {
            uint cost = _num * tokensPrice[_payToken];
            if (cost > 0) {
                if (address(_payToken) == WETH) {
                    require(msg.value == cost, "illegal payment");
                    receiver.transfer(msg.value);
                } else {
                    _payToken.safeTransferFrom(msg.sender, receiver, cost);
                }
            }
            nft.mint(msg.sender, _num);
            sellNum += _num;
            buyNum[msg.sender] += _num;
            uint currentSupply = nft.totalSupply();
            for (uint i = 0; i < _num; i ++) {
                emit Buy(msg.sender, _payToken, tokensPrice[_payToken], nft, currentSupply - _num + i + 1);
            }
        }
    }
}
// SPDX-License-Identifier: MIT

pragma solidity >=0.8.4;

import '@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol';
import '@openzeppelin/contracts/token/ERC20/ERC20.sol';
import '../interfaces/IMintableERC721.sol';
import '../interfaces/IBurnableERC721.sol';
import '../core/SafeOwnable.sol';
import '../core/Verifier.sol';

contract Evolution is SafeOwnable, Verifier {

    event NewEvolutionDirection(IBurnableERC721 burnNFT, IERC721 evolutionNFT, bool avaliable);
    event Evoluted(address user, IBurnableERC721 burnNFT, uint[] burnNftId, IERC721 evolutionNFT, uint evolutionNftId);

    //burn nft => evolution nft => true
    mapping(IBurnableERC721 => mapping(IERC721 => bool)) public evolutionDirection;

    constructor(IBurnableERC721[] memory _burnNFTs, IERC721[] memory _evolutionNFTs, address _verifier) Verifier(_verifier) {
        require(_burnNFTs.length == _evolutionNFTs.length, "illegal nfts");
        for (uint i = 0; i < _burnNFTs.length; i ++) {
            require(address(_burnNFTs[i]) != address(0) && address(_evolutionNFTs[i]) != address(0), "zero address");
            require(!evolutionDirection[_burnNFTs[i]][_evolutionNFTs[i]], "direction already exist");
            evolutionDirection[_burnNFTs[i]][_evolutionNFTs[i]] = true;
            emit NewEvolutionDirection(_burnNFTs[i], _evolutionNFTs[i], true);
        }
    }

    function addEvolutionDirection(IBurnableERC721 _burnNFT, IERC721 _evolutionNFT) external onlyOwner {
        require(address(_burnNFT) != address(0) && address(_evolutionNFT) != address(0), "zero address"); 
        require(!evolutionDirection[_burnNFT][_evolutionNFT], "already exist");
        evolutionDirection[_burnNFT][_evolutionNFT] = true;
        emit NewEvolutionDirection(_burnNFT, _evolutionNFT, true);
    }

    function delEvolutionDirection(IBurnableERC721 _burnNFT, IERC721 _evolutionNFT) external onlyOwner {
        require(evolutionDirection[_burnNFT][_evolutionNFT], "not exist");
        delete evolutionDirection[_burnNFT][_evolutionNFT];
        emit NewEvolutionDirection(_burnNFT, _evolutionNFT, false);
    }

    function evolution(IBurnableERC721 _burnNFT, uint[] memory _burnNftIds, IERC721 _evolutionNFT, uint _evolutionNftId, uint8 _v, bytes32 _r, bytes32 _s) external {
        require(
            ecrecover(keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", keccak256(abi.encodePacked(address(this), msg.sender, _burnNFT, _burnNftIds, _evolutionNFT , _evolutionNftId)))), _v, _r, _s) == verifier,
            "verify failed"
        );
        require(evolutionDirection[_burnNFT][_evolutionNFT], "direction not exist");
        require(_evolutionNFT.ownerOf(_evolutionNftId) == msg.sender, "illegal owner");
        for (uint i = 0; i < _burnNftIds.length; i ++) {
            _burnNFT.burn(msg.sender, _burnNftIds[i]);
        }
        emit Evoluted(msg.sender, _burnNFT, _burnNftIds, _evolutionNFT, _evolutionNftId);
    }

}
// SPDX-License-Identifier: MIT

pragma solidity >=0.8.4;

import '@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol';
import '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import '../core/SafeOwnable.sol';
import '../core/TimeCore.sol';

contract GoldenCoinShop is SafeOwnable, TimeCore {
    using SafeERC20 for IERC20;

    uint constant public interval = 1 days;

    event ItemChanged(uint id, IERC20 token, uint cost, uint reward, bool available);
    event ReceiverChanged(address oldReceiver, address newReceiver);
    event Buy(uint id, IERC20 token, uint cost, uint reward, uint timestamp);
    event DailyGoldenLimitChanged(uint oldValue, uint newValue);

    struct Item {
        uint id;
        IERC20 token;
        uint cost;
        uint reward;
        uint dailyLimit;
        bool available;
    }

    IERC20 immutable public WETH;
    Item[] public items;
    address payable public receiver;
    mapping (uint => mapping(address => uint)) public userLast;
    mapping (uint => mapping(address => uint)) public userBuyed;
    uint public globalLast;
    uint public globalBuyed;
    uint public dailyGoldenLimit;

    constructor(IERC20 _WETH, address payable _receiver) {
        WETH = _WETH;
        require(_receiver != address(0), "illegal receiver");
        emit ReceiverChanged(receiver, _receiver);
        receiver = _receiver;
    }

    function addItem(IERC20 _token, uint _cost, uint _reward, uint _dailyLimit) internal {
        require(address(_token) != address(0), "illegal token");
        items.push(Item({
            id: items.length,
            token: _token,
            cost: _cost,
            reward: _reward,
            dailyLimit: _dailyLimit,
            available: true
        }));
        unchecked {
            emit ItemChanged(items.length - 1, _token, _cost, _reward, true);
        }
    }

    function addItems(IERC20[] memory _tokens, uint[] memory _costs, uint[] memory _rewards, uint[] memory _dailyLimits) external onlyOwner {
        require(_tokens.length == _costs.length && _costs.length == _rewards.length && _rewards.length == _dailyLimits.length, "illegallength"); 
        unchecked {
            for (uint i = 0; i < _tokens.length; i ++) {
                addItem(_tokens[i], _costs[i], _rewards[i], _dailyLimits[i]);
            }
        }
    }

    function disableItems(uint[] memory _ids) external onlyOwner {
        unchecked {
            for (uint i = 0; i < _ids.length; i ++) {
                require(_ids[i] < items.length, "illegal id");
                Item storage item = items[_ids[i]];
                item.available = false;
                emit ItemChanged(item.id, item.token, item.cost, item.reward, item.available);
            }
        }
    }

    function enableItems(uint[] memory _ids) external onlyOwner {
        unchecked {
            for (uint i = 0; i < _ids.length; i ++) {
                require(_ids[i] < items.length, "illegal id");
                Item storage item = items[_ids[i]];
                item.available = true;
                emit ItemChanged(item.id, item.token, item.cost, item.reward, item.available);
            }
        }
    }

    function changeItem(uint _id, uint _cost, uint _reward, uint _dailyLimit, bool _available) internal {
        require(_id < items.length, "illegal id");
        Item storage item = items[_id];
        item.cost = _cost;
        item.reward = _reward;
        item.dailyLimit = _dailyLimit;
        item.available = _available;
        emit ItemChanged(_id, item.token, item.cost, item.reward, item.available);
    }

    function changeItems(Item[] memory _items) external onlyOwner {
        for (uint i = 0; i < _items.length; i ++) {
            changeItem(_items[i].id, _items[i].cost, _items[i].reward, _items[i].dailyLimit, _items[i].available);
        }
    }

    function changeReciever(address payable _receiver) external onlyOwner {
        require(_receiver != address(0), "illegal receiver");
        emit ReceiverChanged(receiver, _receiver);
        receiver = _receiver;
    }

    function changeDailyGoldenLimit(uint _limit) external onlyOwner {
        emit DailyGoldenLimitChanged(dailyGoldenLimit, _limit);
        dailyGoldenLimit = _limit;
    }

    function buy(uint _id, IERC20 _token, uint _cost, uint _reward) external payable RightTime {
        require(_id < items.length, "illegal id");
        Item memory item = items[_id];
        require(item.available, "item not exist");
        require(item.token == _token && item.cost == _cost && item.reward == _reward, "item changed");
        uint currentDay = block.timestamp / interval;

        uint remain = item.dailyLimit;
        if (userLast[_id][msg.sender] >= currentDay) {
            remain = item.dailyLimit - userBuyed[_id][msg.sender];
        } else {
            userBuyed[_id][msg.sender] = 0;
            userLast[_id][msg.sender] = currentDay;
        }
        require(remain > 0, "already full");

        uint dailyBuyed = 0;
        if (globalLast >= currentDay) {
            dailyBuyed = globalBuyed;
        } else {
            globalLast = currentDay;
            globalBuyed = 0;
        }
        require(dailyBuyed + _reward <= dailyGoldenLimit, "already full");
        if (_token == WETH) {
            require(_cost == msg.value, "illegal cost");
            receiver.transfer(_cost);
        } else {
            _token.safeTransferFrom(msg.sender, receiver, _cost);
        }
        userBuyed[_id][msg.sender] += 1;
        globalBuyed += _reward;
        emit Buy(_id, _token, _cost, _reward, block.timestamp);
    }

    function userDailyBuyed(uint _id, address _user) external view returns (uint) {
        uint currentDay = block.timestamp / interval;
        if (userLast[_id][_user] >= currentDay) {
            return userBuyed[_id][_user];
        } else {
            return 0;
        }
    }

    function globalDailyBuyed() external view returns (uint) {
        uint currentDay = block.timestamp / interval;
        if (globalLast >= currentDay) {
            return globalBuyed;
        } else {
            return 0;
        }
    }

    function itemLength() public view returns (uint length) {
        for (uint i = 0; i < items.length; i ++) {
            if (items[i].available) {
                unchecked {
                    length += 1;
                }
            }
        }
    }

    function itemArrayLength() external view returns (uint) {
        return items.length;
    }

    function allItems() external view returns (Item[] memory itemList) {
        itemList = new Item[](itemLength()); 
        uint currentIndex = 0;
        for (uint i = 0; i < items.length; i ++) {
            if (items[i].available) {
                itemList[currentIndex].id = items[i].id;
                itemList[currentIndex].token = items[i].token;
                itemList[currentIndex].cost = items[i].cost;
                itemList[currentIndex].reward = items[i].reward;
                itemList[currentIndex].dailyLimit = items[i].dailyLimit;
                itemList[currentIndex].available = items[i].available;
                unchecked {
                    currentIndex += 1;
                }
            }
        }
    }

}
// SPDX-License-Identifier: MIT

pragma solidity >=0.8.4;

import '../interfaces/IBurnableERC721.sol';
import '../core/SafeOwnable.sol';

contract HelloPuff is SafeOwnable {

    event SignIn(address user, uint timestamp, uint loop, uint score);
    event BurnReward(uint nonce, address user, IERC721 nft, uint rewardId);

    uint public immutable BEGIN_TIME = 36000;
    uint public constant MAX_LOOP = 7;
    uint public immutable interval;

    uint public startAt;
    uint public finishAt;
    uint[] public scoreInfo;
    mapping(address => uint) public userCrycle;
    mapping(address => uint) public userLoop;
    mapping(address => uint) public userScores;
    mapping(IERC721 => mapping(uint => uint)) public nftCrycle;
    uint public totalScores;
    uint public nonce;
    mapping(IERC721 => bool) public supportNfts;

    constructor(uint _startAt, uint _finishAt, uint _interval, IERC721[] memory _supportNfts, uint[] memory _scores) {
        require(_startAt > block.timestamp && _finishAt > _startAt, "illegal startAt or finishAt");
        startAt = _startAt;
        finishAt = _finishAt;
        require(_interval != 0, "interval is zero");
        interval = _interval;
        for (uint i = 0; i < _supportNfts.length; i ++) {
            supportNfts[_supportNfts[i]] = true;
        }
        require(_scores.length == MAX_LOOP, "illegal score num");
        scoreInfo.push(0);
        for (uint i = 0; i < _scores.length; i ++) {
            scoreInfo.push(_scores [i]);
        }
    }

    function getScoreInfo() external view returns(uint[] memory) {
        return scoreInfo;
    }

    function setTimeInfo(uint _startAt, uint _finishAt) external onlyOwner {
        if (_startAt != 0) {
            require(_startAt > block.timestamp, "illegal startAt");
            startAt = _startAt;
        }
        if (_finishAt != 0) {
            require(_finishAt > startAt, "illegal startAt or finishAt");
            finishAt = _finishAt;
        }
    }

    function setScore(uint _loop, uint _newScore) external onlyOwner {
        require(_loop > 0 && _loop <= MAX_LOOP, "illegal loop");
        scoreInfo[_loop] = _newScore;
    }

    function setSupportNft(IERC721 _supportNft, bool _support) external onlyOwner {
        if (_support) {
            require(!supportNfts[_supportNft], "already support");
            supportNfts[_supportNft] = true;
        } else {
            require(supportNfts[_supportNft], "not supported this nft");
            delete supportNfts[_supportNft];
        }
    }

    modifier AlreadyBegin() {
        require(block.timestamp >= startAt, "not begin");
        _;
    }
    
    modifier NotFinish() {
        require(block.timestamp <= finishAt, "already finish");
        _;
    }

    function timeToCrycle(uint _timestamp) public view returns(uint _crycle) {
        return (_timestamp - BEGIN_TIME) / interval;
    }

    function signIn() external AlreadyBegin NotFinish {
        uint crycle = timeToCrycle(block.timestamp);
        uint lastCrycle = userCrycle[msg.sender];
        require(crycle > lastCrycle, "already signIn");
        uint loop = 1;
        if (crycle - lastCrycle == 1) {
            if (userLoop[msg.sender] >= MAX_LOOP) {
                loop = 1;
            } else {
                loop = userLoop[msg.sender] + 1;
            }
        } else {
            loop = 1; 
        }
        uint score = scoreInfo[loop];
        userCrycle[msg.sender] = crycle;
        userLoop[msg.sender] = loop;
        userScores[msg.sender] += score;
        totalScores += score;
        emit SignIn(msg.sender, block.timestamp, loop, score);
    }

    function signInInfo(address _user) external view returns(bool available, uint loop) {
        if (block.timestamp < startAt || block.timestamp > finishAt) {
            return (false, 0);
        }
        uint crycle = timeToCrycle(block.timestamp);
        if (crycle == userCrycle[_user]) {
            return (false, userLoop[_user]);
        } else if (crycle - userCrycle[_user] > 1) {
            return (true, 1);
        } else if (userLoop[_user] >= MAX_LOOP) {
            return (true, 1);
        } else {
            return (true, userLoop[_user] + 1);
        }
    }

    function strengthen(IERC721 _strengthenNft, uint _rewardId) external AlreadyBegin NotFinish {
        require(supportNfts[_strengthenNft], "nft not support");
        require(_strengthenNft.ownerOf(_rewardId) == msg.sender, "illegal owner");
        uint crycle = timeToCrycle(block.timestamp);
        uint lastCrycle = nftCrycle[_strengthenNft][_rewardId];
        require(crycle > lastCrycle, "already signIn");
        nonce ++;
        nftCrycle[_strengthenNft][_rewardId] = crycle;
        emit BurnReward(nonce, msg.sender, _strengthenNft, _rewardId);
    }

    function strengthenInfo(IERC721 _strengthenNft, uint _rewardId) external view returns(bool available) {
        uint crycle = timeToCrycle(block.timestamp);
        return  crycle > nftCrycle[_strengthenNft][_rewardId];
    }
}
// SPDX-License-Identifier: MIT

pragma solidity >=0.8.4;

import '@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol';
import '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import '../interfaces/IMintableERC721V3.sol';
import '../core/SafeOwnable.sol';
import '../core/TimeCore.sol';

contract NFTShop is SafeOwnable, TimeCore {
    using SafeERC20 for IERC20;

    event ItemChanged(uint id, IERC20 paymentToken, uint cost, IMintableERC721V3 receiveNFT, uint receiveNum, bool available);
    event ReceiverChanged(address oldReceiver, address newReceiver);
    event NftSupplyChanged(IMintableERC721V3 nft, uint oldSupply, uint newSupply);
    event Buy(uint id, address user, IERC20 paymentToken, uint cost, IMintableERC721V3 receiveNFT, uint[] nftIds, uint timestamp);

    struct Item {
        uint id;
        IERC20 paymentToken;
        uint cost;
        IMintableERC721V3 receiveNFT;
        uint receiveNum;
        bool available;
    }

    IERC20 immutable public WETH;
    Item[] public items;
    address payable public receiver;
    mapping(IMintableERC721V3 => uint) public nftSupply;
    mapping(IMintableERC721V3 => uint) public nftSelled;
    mapping(address => mapping(IMintableERC721V3 => uint)) public userBuyed;

    constructor(IERC20 _WETH, address payable _receiver) {
        WETH = _WETH;
        require(_receiver != address(0), "illegal receiver");
        emit ReceiverChanged(receiver, _receiver);
        receiver = _receiver;
    }

    function addItem(IERC20 _paymentToken, uint _cost, IMintableERC721V3 _receiveNFT, uint _receiveNum) internal {
        require(address(_paymentToken) != address(0) && address(_receiveNFT) != address(0), "illegal token");
        items.push(Item({
            id: items.length,
            paymentToken: _paymentToken,
            cost: _cost,
            receiveNFT: _receiveNFT,
            receiveNum: _receiveNum,
            available: true
        }));
        unchecked {
            emit ItemChanged(items.length - 1, _paymentToken, _cost, _receiveNFT, _receiveNum, true);
        }
    }

    function addItems(IERC20[] memory _paymentTokens, uint[] memory _costs, IMintableERC721V3[] memory _receiveNFTs, uint[] memory _receiveNums) external onlyOwner {
        require(_paymentTokens.length == _costs.length && _costs.length == _receiveNFTs.length && _receiveNFTs.length == _receiveNums.length, "illegallength"); 
        unchecked {
            for (uint i = 0; i < _paymentTokens.length; i ++) {
                addItem(_paymentTokens[i], _costs[i], _receiveNFTs[i], _receiveNums[i]);
            }
        }
    }

    function disableItems(uint[] memory _ids) external onlyOwner {
        unchecked {
            for (uint i = 0; i < _ids.length; i ++) {
                require(_ids[i] < items.length, "illegal id");
                Item storage item = items[_ids[i]];
                item.available = false;
                emit ItemChanged(item.id, item.paymentToken, item.cost, item.receiveNFT, item.receiveNum, item.available);
            }
        }
    }

    function enableItems(uint[] memory _ids) external onlyOwner {
        unchecked {
            for (uint i = 0; i < _ids.length; i ++) {
                require(_ids[i] < items.length, "illegal id");
                Item storage item = items[_ids[i]];
                item.available = true;
                emit ItemChanged(item.id, item.paymentToken, item.cost, item.receiveNFT, item.receiveNum, item.available);
            }
        }
    }

    function changeItem(uint _id, uint _cost, uint _receiveNum, bool _available) internal {
        require(_id < items.length, "illegal id");
        Item storage item = items[_id];
        item.cost = _cost;
        item.receiveNum = _receiveNum;
        item.available = _available;
        emit ItemChanged(_id, item.paymentToken, item.cost, item.receiveNFT, item.receiveNum, item.available);
    }

    function changeItems(Item[] memory _items) external onlyOwner {
        for (uint i = 0; i < _items.length; i ++) {
            changeItem(_items[i].id, _items[i].cost, _items[i].receiveNum, _items[i].available);
        }
    }

    function changeReceiver(address payable _receiver) external onlyOwner {
        require(_receiver != address(0), "illegal receiver");
        emit ReceiverChanged(receiver, _receiver);
        receiver = _receiver;
    }

    function changeSupply(IMintableERC721V3 _nft, uint _num) external onlyOwner {
        require(_num >= nftSelled[_nft], "already executed");
        emit NftSupplyChanged(_nft, nftSupply[_nft], _num);
        nftSupply[_nft] = _num;
    }

    function buy(uint _id, uint _cost, uint _receiveNum) external payable RightTime {
        require(_id < items.length, "illegal id");
        Item memory item = items[_id];
        require(item.available, "item not exist");
        require(item.cost == _cost && item.receiveNum == _receiveNum, "item changed");
        require(nftSelled[item.receiveNFT] + item.receiveNum <= nftSupply[item.receiveNFT], "already executed");
        if (item.paymentToken == WETH) {
            require(_cost == msg.value, "illegal cost");
            receiver.transfer(_cost);
        } else {
            item.paymentToken.safeTransferFrom(msg.sender, receiver, _cost);
        }
        uint currentSupply = item.receiveNFT.totalSupply();
        item.receiveNFT.mint(msg.sender, item.receiveNum);
        nftSelled[item.receiveNFT] += item.receiveNum;
        userBuyed[msg.sender][item.receiveNFT] += item.receiveNum;
        uint[] memory nftIds = new uint[](item.receiveNum);
        for (uint i = 0; i < item.receiveNum; i ++) {
            nftIds[i] = currentSupply + i + 1;
        }
        emit Buy(_id, msg.sender, item.paymentToken, item.cost, item.receiveNFT, nftIds, block.timestamp);
    }

    function itemLength() public view returns (uint length) {
        for (uint i = 0; i < items.length; i ++) {
            if (items[i].available) {
                unchecked {
                    length += 1;
                }
            }
        }
    }

    function itemArrayLength() external view returns (uint) {
        return items.length;
    }

    function allItems() external view returns (Item[] memory itemList) {
        itemList = new Item[](itemLength()); 
        uint currentIndex = 0;
        for (uint i = 0; i < items.length; i ++) {
            if (items[i].available) {
                itemList[currentIndex].id = items[i].id;
                itemList[currentIndex].paymentToken = items[i].paymentToken;
                itemList[currentIndex].cost = items[i].cost;
                itemList[currentIndex].receiveNFT = items[i].receiveNFT;
                itemList[currentIndex].receiveNum = items[i].receiveNum;
                itemList[currentIndex].available = items[i].available;
                unchecked {
                    currentIndex += 1;
                }
            }
        }
    }
}
// SPDX-License-Identifier: MIT

pragma solidity >=0.8.4;

import '../interfaces/IMintableERC721V3.sol';
import '../interfaces/INFTShop.sol';
import '../core/SafeOwnable.sol';
import '../core/TimeCore.sol';

contract PuffNewYearClaim is SafeOwnable, TimeCore {

    event ClaimConditionChanged(uint oldValue, uint newValue);
    event TotalSupplyChanged(uint oldValue, uint newValue);
    event Claim(address user, uint nftId);

    IMintableERC721V3 public immutable puffNewYearNFT;
    IMintableERC721V3 public immutable classicNFT;
    INFTShop public immutable nftShop;
    uint public claimCondition;
    mapping(address => uint) public userClaimed;
    uint public totalSupply;
    uint public totalClaimed;

    constructor(IMintableERC721V3 _puffNewYearNFT, IMintableERC721V3 _classicNFT, INFTShop _nftShop, uint _claimCondition, uint _totalSupply) {
        require(address(_puffNewYearNFT) != address(0) && address(_classicNFT) != address(0) && address(_nftShop) != address(0), "illegal nft");
        puffNewYearNFT = _puffNewYearNFT;
        classicNFT = _classicNFT;
        nftShop = _nftShop;
        emit ClaimConditionChanged(claimCondition, _claimCondition);
        claimCondition = _claimCondition;
        require(_totalSupply <= _puffNewYearNFT.MAX_SUPPLY(), "illegal totalSupply");
        emit TotalSupplyChanged(totalSupply, _totalSupply);
        totalSupply = _totalSupply;
    }

    function setClaimCondition(uint _condition) external onlyOwner {
        require(_condition != 0, "illegal value");
        emit ClaimConditionChanged(claimCondition, _condition);
        claimCondition = _condition;
    }

    function setTotalSupply(uint _totalSupply) external onlyOwner {
        require(_totalSupply >= totalClaimed && _totalSupply <= puffNewYearNFT.MAX_SUPPLY(), "illegal value");
        emit TotalSupplyChanged(totalSupply, _totalSupply);
        totalSupply = _totalSupply;
    }

    function available(address _user) public view returns(uint totalNum, uint claimedNum) {
        uint userBuyed = nftShop.userBuyed(_user, classicNFT);
        totalNum = userBuyed / claimCondition;
        claimedNum = userClaimed[_user];
    }

    function claim() external RightTime {
        (uint totalNum, uint claimedNum) = available(msg.sender);
        require(totalNum > claimedNum, "no available");
        uint remain = totalNum - claimedNum;
        require(totalClaimed + remain <= totalSupply, "already executed");
        puffNewYearNFT.mint(msg.sender, remain);
        userClaimed[msg.sender] += remain;
        totalClaimed += remain;
        uint lastTokenId = puffNewYearNFT.totalSupply();
        for (uint i = 0; i < remain; i ++) {
            emit Claim(msg.sender, lastTokenId - 1);
        }
    }
}
// SPDX-License-Identifier: MIT

pragma solidity >=0.8.4;

contract PuffRecord {

    uint public nonce = 0;
    event Record(uint nonce, uint tokenId, uint tokenType, address user);

    constructor() {
        nonce = 1;
    }

    function search(uint tokenId, uint tokenType) external {
        emit Record(nonce ++, tokenId, tokenType, msg.sender);
    }

}
// SPDX-License-Identifier: MIT

pragma solidity >=0.8.4;

import '../interfaces/IBurnableERC721.sol';
import '../core/SafeOwnable.sol';
import '../core/Verifier.sol';

contract TicketBurn is SafeOwnable {

    event BurnReward(uint nonce, address user, uint[] burnIds, address nft, uint rewardId);

    IBurnableERC721 public immutable nft;
    uint public immutable startAt;
    uint public immutable finishAt;

    uint public nonce;

    constructor(IBurnableERC721 _nft, uint _startAt, uint _finishAt) {
        require(address(_nft) != address(0), "illegal nft");
        nft = _nft;
        require(_startAt > block.timestamp && _finishAt > _startAt, "illegal time");
        startAt = _startAt;
        finishAt = _finishAt;
    }
    
    modifier AlreadyBegin() {
        require(block.timestamp >= startAt, "not begin");
        _;
    }
    
    modifier NotFinish() {
        require(block.timestamp <= finishAt, "already finish");
        _;
    }

    function burn(uint [] memory _burnIds, address _burnNFT, uint _rewardId) external AlreadyBegin NotFinish {
        for (uint i = 0; i < _burnIds.length; i ++) { 
            nft.burn(msg.sender, _burnIds[i]);
        }
        nonce ++;
        emit BurnReward(nonce, msg.sender, _burnIds, _burnNFT, _rewardId);
    }
}
// SPDX-License-Identifier: MIT

pragma solidity >=0.8.4;

import '@openzeppelin/contracts/token/ERC721/IERC721.sol';
import './IERC721Core.sol';

interface IBurnableERC721 is IERC721Core {

    function burn(address _to, uint _id) external;

}

// SPDX-License-Identifier: MIT

pragma solidity >=0.8.4;

import '@openzeppelin/contracts/token/ERC721/IERC721.sol';
import './IERC721CoreV2.sol';

interface IBurnableERC721V2 is IERC721CoreV2 {

    function burn(address _to, uint _id) external;

}

// SPDX-License-Identifier: MIT

pragma solidity >=0.8.4;

import '@openzeppelin/contracts/token/ERC721/IERC721.sol';

interface IERC721Core is IERC721 {

    function totalSupply() external returns (uint);

}

// SPDX-License-Identifier: MIT

pragma solidity >=0.8.4;

import '@openzeppelin/contracts/token/ERC721/extensions/IERC721Enumerable.sol';

interface IERC721CoreV2 is IERC721Enumerable {

}

// SPDX-License-Identifier: MIT

pragma solidity >=0.8.4;

import './IMintableBurnableERC721.sol';

interface IGenesisNFT is IMintableBurnableERC721 {
    function MAX_MINT_NUM() external returns(uint);
    function MAX_RESERVE_NUM() external returns(uint);
    function ticketNFT() external returns(IMintableBurnableERC721);
    function mintedNum() external returns(uint);
    function reservedNum() external returns(uint);
    function userReserved(address user) external returns(uint);
    function draw(uint _luckyNftId, uint _totalNum, uint8 _v, bytes32 _r, bytes32 _s) external;
    function reserve(address _to, uint _num, uint8 _v, bytes32 _r, bytes32 _s) external;
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.8.4;

import './IMintableERC721.sol';
import './IBurnableERC721.sol';

interface IMintableBurnableERC721 is IMintableERC721, IBurnableERC721 {

}

// SPDX-License-Identifier: MIT

pragma solidity >=0.8.4;

import './IMintableERC721V2.sol';
import './IBurnableERC721V2.sol';

interface IMintableBurnableERC721V2 is IMintableERC721V2, IBurnableERC721V2 {

}

// SPDX-License-Identifier: MIT

pragma solidity >=0.8.4;

import '@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol';

interface IMintableERC20 is IERC20Metadata {

    function mint(address to, uint256 amount) external returns (uint);

}

// SPDX-License-Identifier: MIT

pragma solidity >=0.8.4;

import '@openzeppelin/contracts/token/ERC721/IERC721.sol';
import './IERC721Core.sol';

interface IMintableERC721 is IERC721Core {

    function mint(address _to, uint _num) external;

}

// SPDX-License-Identifier: MIT

pragma solidity >=0.8.4;

import '@openzeppelin/contracts/token/ERC721/IERC721.sol';
import './IERC721CoreV2.sol';

interface IMintableERC721V2 is IERC721CoreV2 {

    function mint(address _to, uint _num) external;

    function mintById(address _to, uint _tokenId) external;

}

// SPDX-License-Identifier: MIT

pragma solidity >=0.8.4;

import '@openzeppelin/contracts/token/ERC721/IERC721.sol';
import './IERC721Core.sol';

interface IMintableERC721V3 is IERC721Core {

    function mint(address _to, uint _num) external;

    function MAX_SUPPLY() external view returns (uint);

}

// SPDX-License-Identifier: MIT

pragma solidity >=0.8.4;

import '@openzeppelin/contracts/token/ERC721/IERC721.sol';
import './IERC721CoreV2.sol';

interface IMintableERC721V4 is IERC721CoreV2 {

    function mint(address _to, uint _num) external;

    function mintById(address _to, uint _tokenId) external;

    function exists(uint _tokenId) external view returns(bool);

}

// SPDX-License-Identifier: MIT

pragma solidity >=0.8.4;

import './IMintableERC721V3.sol';

interface INFTShop {

    function userBuyed(address user, IMintableERC721V3 nft) external view returns (uint);

}

// SPDX-License-Identifier: MIT

pragma solidity >=0.8.4;

import './IProxyImplementation.sol';

interface IOwnableDelegateProxy {

    function initialize (IProxyImplementation _impl, address _user, address _factory) external;

    function implementation() external view returns(address);

}
// SPDX-License-Identifier: MIT

pragma solidity >=0.8.4;

import './IProxyImplementation.sol';

interface IProxyFactory {

    function contracts(address _caller) external returns (bool);

    function registerProxy() external returns (address);

    function proxies(address user) external returns (IProxyImplementation);

    function proxyImplementation() external returns (IProxyImplementation);

}
// SPDX-License-Identifier: MIT

pragma solidity >=0.8.4;

interface IProxyImplementation {

    enum HowToCall { Call, DelegateCall }

    function proxy(address dest, HowToCall howToCall, bytes memory data) external returns (bool result);

}
// SPDX-License-Identifier: MIT

pragma solidity >=0.8.4;

interface ISafeOwnable {

    function owner() external view returns (address);

}
// SPDX-License-Identifier: MIT

pragma solidity >=0.8.4;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface ITokenTransferProxy {

    function transferFrom(IERC20 _token, address _from, address _to, uint _amount) external returns (bool);

}
// SPDX-License-Identifier: MIT

pragma solidity >=0.5.0;

interface IWETH {
    function deposit() external payable;
    function transfer(address to, uint value) external returns (bool);
    function withdraw(uint) external;
}
// SPDX-License-Identifier: MIT

pragma solidity >=0.8.4;

library ArrayUtils {

    /*
     * Replace bytes in an array with bytes in another array, guarded by a bitmask
     * Efficiency of this function is a bit unpredictable because of the EVM's word-specific model (arrays under 32 bytes will be slower)
     * 
     * @dev Mask must be the size of the byte array. A nonzero byte means the byte array can be changed.
     * @param array The original array
     * @param desired The target array
     * @param mask The mask specifying which bits can be changed
     * @return The updated byte array (the parameter will be modified inplace)
     */
    function guardedArrayReplace(bytes memory array, bytes memory desired, bytes memory mask)
        internal
        pure
    {
        require(array.length == desired.length);
        require(array.length == mask.length);

        uint words = array.length / 0x20;
        uint index = words * 0x20;
        assert(index / 0x20 == words);
        uint i;

        for (i = 0; i < words; i++) {
            /* Conceptually: array[i] = (!mask[i] && array[i]) || (mask[i] && desired[i]), bitwise in word chunks. */
            assembly {
                let commonIndex := mul(0x20, add(1, i))
                let maskValue := mload(add(mask, commonIndex))
                mstore(add(array, commonIndex), or(and(not(maskValue), mload(add(array, commonIndex))), and(maskValue, mload(add(desired, commonIndex)))))
            }
        }

        /* Deal with the last section of the byte array. */
        if (words > 0) {
            /* This overlaps with bytes already set but is still more efficient than iterating through each of the remaining bytes individually. */
            i = words;
            assembly {
                let commonIndex := mul(0x20, add(1, i))
                let maskValue := mload(add(mask, commonIndex))
                mstore(add(array, commonIndex), or(and(not(maskValue), mload(add(array, commonIndex))), and(maskValue, mload(add(desired, commonIndex)))))
            }
        } else {
            /* If the byte array is shorter than a word, we must unfortunately do the whole thing bytewise.
               (bounds checks could still probably be optimized away in assembly, but this is a rare case) */
            for (i = index; i < array.length; i++) {
                array[i] = ((mask[i] ^ 0xff) & array[i]) | (mask[i] & desired[i]);
            }
        }
    }

    /*
     * Test if two arrays are equal
     * Source: https://github.com/GNSPS/solidity-bytes-utils/blob/master/contracts/BytesLib.sol
     * 
     * @dev Arrays must be of equal length, otherwise will return false
     * @param a First array
     * @param b Second array
     * @return Whether or not all bytes in the arrays are equal
     */
    function arrayEq(bytes memory a, bytes memory b)
        internal
        pure
        returns (bool)
    {
        bool success = true;

        assembly {
            let length := mload(a)

            // if lengths don't match the arrays are not equal
            switch eq(length, mload(b))
            case 1 {
                // cb is a circuit breaker in the for loop since there's
                //  no said feature for inline assembly loops
                // cb = 1 - don't breaker
                // cb = 0 - break
                let cb := 1

                let mc := add(a, 0x20)
                let end := add(mc, length)

                for {
                    let cc := add(b, 0x20)
                // the next line is the loop condition:
                // while(uint(mc < end) + cb == 2)
                } eq(add(lt(mc, end), cb), 2) {
                    mc := add(mc, 0x20)
                    cc := add(cc, 0x20)
                } {
                    // if any of these checks fails then arrays are not equal
                    if iszero(eq(mload(mc), mload(cc))) {
                        // unsuccess:
                        success := 0
                        cb := 0
                    }
                }
            }
            default {
                // unsuccess:
                success := 0
            }
        }

        return success;
    }

    /*
     * Unsafe write byte array into a memory location
     *
     * @param index Memory location
     * @param source Byte array to write
     * @return End memory index
     */
    function unsafeWriteBytes(uint index, bytes memory source)
        internal
        pure
        returns (uint)
    {
        if (source.length > 0) {
            assembly {
                let length := mload(source)
                let end := add(source, add(0x20, length))
                let arrIndex := add(source, 0x20)
                let tempIndex := index
                for { } eq(lt(arrIndex, end), 1) {
                    arrIndex := add(arrIndex, 0x20)
                    tempIndex := add(tempIndex, 0x20)
                } {
                    mstore(tempIndex, mload(arrIndex))
                }
                index := add(index, length)
            }
        }
        return index;
    }

    /*
     * Unsafe write address into a memory location
     *
     * @param index Memory location
     * @param source Address to write
     * @return End memory index
     */
    function unsafeWriteAddress(uint index, address source)
        internal
        pure
        returns (uint)
    {
        uint conv = uint(uint160(source)) << 0x60;
        assembly {
            mstore(index, conv)
            index := add(index, 0x14)
        }
        return index;
    }

    /*
     * Unsafe write uint into a memory location
     *
     * @param index Memory location
     * @param source uint to write
     * @return End memory index
     */
    function unsafeWriteUint(uint index, uint source)
        internal
        pure
        returns (uint)
    {
        assembly {
            mstore(index, source)
            index := add(index, 0x20)
        }
        return index;
    }

    /*
     * Unsafe write uint8 into a memory location
     *
     * @param index Memory location
     * @param source uint8 to write
     * @return End memory index
     */
    function unsafeWriteUint8(uint index, uint8 source)
        internal
        pure
        returns (uint)
    {
        assembly {
            mstore8(index, source)
            index := add(index, 0x1)
        }
        return index;
    }

}

contract ReentrancyGuarded {

    bool reentrancyLock = false;

    /* Prevent a contract function from being reentrant-called. */
    modifier reentrancyGuard {
        if (reentrancyLock) {
            revert();
        }
        reentrancyLock = true;
        _;
        reentrancyLock = false;
    }

}
// SPDX-License-Identifier: MIT

pragma solidity >=0.8.4;

import "../interfaces/IProxyImplementation.sol";
import "../interfaces/ITokenTransferProxy.sol";
import "./ExchangeCore.sol";

contract Exchange is ExchangeCore {

    constructor(IProxyFactory _proxyFactory, ITokenTransferProxy _tokenTransferProxy, IERC20 _exchangeToken, address _protocolFeeRecipient) {
        proxyFactory = _proxyFactory;
        tokenTransferProxy = _tokenTransferProxy;
        exchangeToken = _exchangeToken;
        protocolFeeRecipient = _protocolFeeRecipient;
    }

    function approveOrder_ (
        address[7] memory addrs,
        uint[9] memory uints,
        FeeMethod feeMethod,
        Side side,
        SaleKind saleKind,
        IProxyImplementation.HowToCall howToCall,
        bytes memory targetdata,
        bytes memory replacementPattern,
        bytes memory staticExtradata,
        bool orderbookInclusionDesired) 
        external
    {
        Order memory order = Order(addrs[0], addrs[1], addrs[2], uints[0], uints[1], uints[2], uints[3], addrs[3], feeMethod, side, saleKind, addrs[4], howToCall, targetdata, replacementPattern, addrs[5], staticExtradata, IERC20(addrs[6]), uints[4], uints[5], uints[6], uints[7], uints[8]);
        return approveOrder(order, orderbookInclusionDesired);
    }

    function cancelOrder_(
        address[7] memory addrs,
        uint[9] memory uints,
        FeeMethod feeMethod,
        Side side,
        SaleKind saleKind,
        IProxyImplementation.HowToCall howToCall,
        bytes memory targetdata,
        bytes memory replacementPattern,
        bytes memory staticExtradata,
        uint8 v,
        bytes32 r,
        bytes32 s)
        external
    {

        return cancelOrder(
          Order(addrs[0], addrs[1], addrs[2], uints[0], uints[1], uints[2], uints[3], addrs[3], feeMethod, side, saleKind, addrs[4], howToCall, targetdata, replacementPattern, addrs[5], staticExtradata, IERC20(addrs[6]), uints[4], uints[5], uints[6], uints[7], uints[8]),
          Sig(v, r, s)
        );
    }

    function atomicMatch_(
        address[14] memory addrs,
        uint[18] memory uints,
        uint8[8] memory feeMethodsSidesKindsHowToCalls,
        bytes memory calldataBuy,
        bytes memory calldataSell,
        bytes memory replacementPatternBuy,
        bytes memory replacementPatternSell,
        bytes memory staticExtradataBuy,
        bytes memory staticExtradataSell,
        uint8[2] memory vs,
        bytes32[5] memory rssMetadata)
        external
        payable
    {

        return atomicMatch(
          Order(addrs[0], addrs[1], addrs[2], uints[0], uints[1], uints[2], uints[3], addrs[3], FeeMethod(feeMethodsSidesKindsHowToCalls[0]), Side(feeMethodsSidesKindsHowToCalls[1]), SaleKind(feeMethodsSidesKindsHowToCalls[2]), addrs[4], IProxyImplementation.HowToCall(feeMethodsSidesKindsHowToCalls[3]), calldataBuy, replacementPatternBuy, addrs[5], staticExtradataBuy, IERC20(addrs[6]), uints[4], uints[5], uints[6], uints[7], uints[8]),
          Sig(vs[0], rssMetadata[0], rssMetadata[1]),
          Order(addrs[7], addrs[8], addrs[9], uints[9], uints[10], uints[11], uints[12], addrs[10], FeeMethod(feeMethodsSidesKindsHowToCalls[4]), Side(feeMethodsSidesKindsHowToCalls[5]), SaleKind(feeMethodsSidesKindsHowToCalls[6]), addrs[11], IProxyImplementation.HowToCall(feeMethodsSidesKindsHowToCalls[7]), calldataSell, replacementPatternSell, addrs[12], staticExtradataSell, IERC20(addrs[13]), uints[13], uints[14], uints[15], uints[16], uints[17]),
          Sig(vs[1], rssMetadata[2], rssMetadata[3]),
          rssMetadata[4]
        );
    }

}
// SPDX-License-Identifier: MIT

pragma solidity >=0.8.4;

import '@openzeppelin/contracts/security/ReentrancyGuard.sol';
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "../interfaces/IOwnableDelegateProxy.sol";
import "../interfaces/IProxyImplementation.sol";
import "../interfaces/ITokenTransferProxy.sol";
import "../interfaces/IProxyFactory.sol";
import "../libraries/ArrayUtils.sol";
import "../core/SafeOwnable.sol";

contract ExchangeCore is ReentrancyGuard, SafeOwnable {
    
    event OrderApprovedPartOne(
        bytes32 indexed hash, address exchange, address indexed maker, address taker, 
        uint makerRelayerFee, uint takerRelayerFee, uint makerProtocolFee, uint takerProtocolFee, address indexed feeRecipient, 
        FeeMethod feeMethod, Side side, SaleKind saleKind, address target
    );
    event OrderApprovedPartTwo(
        bytes32 indexed hash, IProxyImplementation.HowToCall howToCall, bytes targetdata, 
        bytes replacementPattern, address staticTarget, bytes staticExtradata, IERC20 paymentToken, 
        uint basePrice, uint extra, uint listingTime, uint expirationTime, uint salt, bool orderbookInclusionDesired
    );
    event OrderCancelled(bytes32 indexed hash);
    event OrdersMatched(bytes32 buyHash, bytes32 sellHash, address indexed maker, address indexed taker, uint price, bytes32 indexed metadata);

    IERC20 public exchangeToken;

    IProxyFactory public proxyFactory;

    ITokenTransferProxy public tokenTransferProxy;

    mapping(bytes32 => bool) public cancelledOrFinalized;

    mapping(bytes32 => bool) public approvedOrders;

    uint public minimumMakerProtocolFee = 0;

    uint public minimumTakerProtocolFee = 0;

    address public protocolFeeRecipient;

    enum FeeMethod { ProtocolFee, SplitFee }

    uint public constant INVERSE_BASIS_POINT = 10000;

    enum Side { Buy, Sell }

    enum SaleKind { FixedPrice, DutchAuction }

    constructor() {
    }

    struct Sig {
        uint8 v;
        bytes32 r;
        bytes32 s;
    }

    struct Order {
        address exchange;
        address maker;
        address taker;
        uint makerRelayerFee;
        uint takerRelayerFee;
        uint makerProtocolFee;
        uint takerProtocolFee;
        address feeRecipient;
        FeeMethod feeMethod;
        Side side;
        SaleKind saleKind;
        address target;
        IProxyImplementation.HowToCall howToCall;
        bytes targetdata;
        bytes replacementPattern;
        address staticTarget;
        bytes staticExtradata;
        IERC20 paymentToken;
        uint basePrice;
        uint extra;
        uint listingTime;
        uint expirationTime;
        uint salt;
    }

    function changeMinimumMakerProtocolFee(uint newMinimumMakerProtocolFee)
        public
        onlyOwner
    {
        minimumMakerProtocolFee = newMinimumMakerProtocolFee;
    }

    function changeMinimumTakerProtocolFee(uint newMinimumTakerProtocolFee)
        public
        onlyOwner
    {
        minimumTakerProtocolFee = newMinimumTakerProtocolFee;
    }

    function changeProtocolFeeRecipient(address newProtocolFeeRecipient)
        public
        onlyOwner
    {
        protocolFeeRecipient = newProtocolFeeRecipient;
    }

    function changeExchangeToken(IERC20 newExchangeToken)
        public
        onlyOwner
    {
        exchangeToken = newExchangeToken;
    }

    function transferTokens(IERC20 token, address from, address to, uint amount)
        internal
    {
        if (amount > 0) {
            tokenTransferProxy.transferFrom(token, from, to, amount);
        }
    }

    function chargeProtocolFee(address from, address to, uint amount)
        internal
    {
        transferTokens(exchangeToken, from, to, amount);
    }

    function staticCall(address target, bytes memory data, bytes memory extradata)
        public
        view
        returns (bool result)
    {
        bytes memory combined = new bytes(data.length + extradata.length);
        uint index;
        assembly {
            index := add(combined, 0x20)
        }
        index = ArrayUtils.unsafeWriteBytes(index, extradata);
        ArrayUtils.unsafeWriteBytes(index, data);
        assembly {
            result := staticcall(gas(), target, add(combined, 0x20), mload(combined), mload(0x40), 0)
        }
        return result;
    }

    function sizeOf(Order memory order)
        internal
        pure
        returns (uint)
    {
        return ((0x14 * 7) + (0x20 * 9) + 4 + order.targetdata.length + order.replacementPattern.length + order.staticExtradata.length);
    }

    function hashOrder(Order memory order)
        internal
        pure
        returns (bytes32 hash)
    {
        /* Unfortunately abi.encodePacked doesn't work here, stack size constraints. */
        uint size = sizeOf(order);
        bytes memory array = new bytes(size);
        uint index;
        assembly {
            index := add(array, 0x20)
        }
        index = ArrayUtils.unsafeWriteAddress(index, order.exchange);
        index = ArrayUtils.unsafeWriteAddress(index, order.maker);
        index = ArrayUtils.unsafeWriteAddress(index, order.taker);
        index = ArrayUtils.unsafeWriteUint(index, order.makerRelayerFee);
        index = ArrayUtils.unsafeWriteUint(index, order.takerRelayerFee);
        index = ArrayUtils.unsafeWriteUint(index, order.makerProtocolFee);
        index = ArrayUtils.unsafeWriteUint(index, order.takerProtocolFee);
        index = ArrayUtils.unsafeWriteAddress(index, order.feeRecipient);
        index = ArrayUtils.unsafeWriteUint8(index, uint8(order.feeMethod));
        index = ArrayUtils.unsafeWriteUint8(index, uint8(order.side));
        index = ArrayUtils.unsafeWriteUint8(index, uint8(order.saleKind));
        index = ArrayUtils.unsafeWriteAddress(index, order.target);
        index = ArrayUtils.unsafeWriteUint8(index, uint8(order.howToCall));
        index = ArrayUtils.unsafeWriteBytes(index, order.targetdata);
        index = ArrayUtils.unsafeWriteBytes(index, order.replacementPattern);
        index = ArrayUtils.unsafeWriteAddress(index, order.staticTarget);
        index = ArrayUtils.unsafeWriteBytes(index, order.staticExtradata);
        index = ArrayUtils.unsafeWriteAddress(index, address(order.paymentToken));
        index = ArrayUtils.unsafeWriteUint(index, order.basePrice);
        index = ArrayUtils.unsafeWriteUint(index, order.extra);
        index = ArrayUtils.unsafeWriteUint(index, order.listingTime);
        index = ArrayUtils.unsafeWriteUint(index, order.expirationTime);
        index = ArrayUtils.unsafeWriteUint(index, order.salt);
        assembly {
            hash := keccak256(add(array, 0x20), size)
        }
        return hash;
    }

    function hashToSign(Order memory order)
        internal
        pure
        returns (bytes32)
    {
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hashOrder(order)));
    }

    function requireValidOrder(Order memory order, Sig memory sig)
        internal
        view
        returns (bytes32)
    {
        bytes32 hash = hashToSign(order);
        require(validateOrder(hash, order, sig));
        return hash;
    }

    function validateParameters(SaleKind saleKind, uint expirationTime)
        pure
        internal
        returns (bool)
    {
        /* Auctions must have a set expiration date. */
        return (saleKind == SaleKind.FixedPrice || expirationTime > 0);
    }

    function validateOrderParameters(Order memory order)
        internal
        view
        returns (bool)
    {
        /* Order must be targeted at this protocol version (this Exchange contract). */
        if (order.exchange != address(this)) {
            return false;
        }
        /* Order must possess valid sale kind parameter combination. */
        if (!validateParameters(order.saleKind, order.expirationTime)) {
            return false;
        }

        /* If using the split fee method, order must have sufficient protocol fees. */
        if (order.feeMethod == FeeMethod.SplitFee && (order.makerProtocolFee < minimumMakerProtocolFee || order.takerProtocolFee < minimumTakerProtocolFee)) {
            return false;
        }

        return true;
    }

    function validateOrder(bytes32 hash, Order memory order, Sig memory sig) 
        internal
        view
        returns (bool)
    {
        /* Not done in an if-conditional to prevent unnecessary ecrecover evaluation, which seems to happen even though it should short-circuit. */
        /* Order must have valid parameters. */
        if (!validateOrderParameters(order)) {
            return false;
        }

        /* Order must have not been canceled or already filled. */
        if (cancelledOrFinalized[hash]) {
            return false;
        }
        
        /* Order authentication. Order must be either:
        /* (a) previously approved */
        if (approvedOrders[hash]) {
            return true;
        }

        /* or (b) ECDSA-signed by maker. */
        if (ecrecover(hash, sig.v, sig.r, sig.s) == order.maker) {
            return true;
        }

        return false;
    }

    function approveOrder(Order memory order, bool orderbookInclusionDesired)
        internal
    {
        /* CHECKS */

        /* Assert sender is authorized to approve order. */
        require(msg.sender == order.maker);

        /* Calculate order hash. */
        bytes32 hash = hashToSign(order);

        /* Assert order has not already been approved. */
        require(!approvedOrders[hash]);

        /* EFFECTS */
    
        /* Mark order as approved. */
        approvedOrders[hash] = true;
  
        /* Log approval event. Must be split in two due to Solidity stack size limitations. */
        {
            emit OrderApprovedPartOne(hash, order.exchange, order.maker, order.taker, order.makerRelayerFee, order.takerRelayerFee, order.makerProtocolFee, order.takerProtocolFee, order.feeRecipient, order.feeMethod, order.side, order.saleKind, order.target);
        }
        {   
            emit OrderApprovedPartTwo(hash, order.howToCall, order.targetdata, order.replacementPattern, order.staticTarget, order.staticExtradata, order.paymentToken, order.basePrice, order.extra, order.listingTime, order.expirationTime, order.salt, orderbookInclusionDesired);
        }
    }

    function cancelOrder(Order memory order, Sig memory sig) 
        internal
    {
        /* CHECKS */

        /* Calculate order hash. */
        bytes32 hash = requireValidOrder(order, sig);

        /* Assert sender is authorized to cancel order. */
        require(msg.sender == order.maker);
  
        /* EFFECTS */
      
        /* Mark order as cancelled, preventing it from being matched. */
        cancelledOrFinalized[hash] = true;

        /* Log cancel event. */
        emit OrderCancelled(hash);
    }

    function calculateFinalPrice(Side side, SaleKind saleKind, uint basePrice, uint extra, uint listingTime, uint expirationTime)
        view
        internal
        returns (uint finalPrice)
    {
        if (saleKind == SaleKind.FixedPrice) {
            return basePrice;
        } else if (saleKind == SaleKind.DutchAuction) {
            uint diff = extra * (block.timestamp - listingTime) / (expirationTime - listingTime);
            if (side == Side.Sell) {
                /* Sell-side - start price: basePrice. End price: basePrice - extra. */
                return basePrice - diff;
            } else {
                /* Buy-side - start price: basePrice. End price: basePrice + extra. */
                return basePrice + diff;
            }
        }
    }

    function calculateCurrentPrice (Order memory order)
        internal  
        view
        returns (uint)
    {
        return calculateFinalPrice(order.side, order.saleKind, order.basePrice, order.extra, order.listingTime, order.expirationTime);
    }

    function calculateMatchPrice(Order memory buy, Order memory sell)
        view
        internal
        returns (uint)
    {
        /* Calculate sell price. */
        uint sellPrice = calculateFinalPrice(sell.side, sell.saleKind, sell.basePrice, sell.extra, sell.listingTime, sell.expirationTime);

        /* Calculate buy price. */
        uint buyPrice = calculateFinalPrice(buy.side, buy.saleKind, buy.basePrice, buy.extra, buy.listingTime, buy.expirationTime);

        /* Require price cross. */
        require(buyPrice >= sellPrice);
        
        /* Maker/taker priority. */
        return sell.feeRecipient != address(0) ? sellPrice : buyPrice;
    }

    function executeFundsTransfer(Order memory buy, Order memory sell)
        internal
        returns (uint)
    {
        /* Only payable in the special case of unwrapped Ether. */
        if (address(sell.paymentToken) != address(0)) {
            require(msg.value == 0);
        }

        /* Calculate match price. */
        uint price = calculateMatchPrice(buy, sell);

        /* If paying using a token (not Ether), transfer tokens. This is done prior to fee payments to that a seller will have tokens before being charged fees. */
        if (price > 0 && address(sell.paymentToken) != address(0)) {
            transferTokens(sell.paymentToken, buy.maker, sell.maker, price);
        }

        /* Amount that will be received by seller (for Ether). */
        uint receiveAmount = price;

        /* Amount that must be sent by buyer (for Ether). */
        uint requiredAmount = price;

        /* Determine maker/taker and charge fees accordingly. */
        if (sell.feeRecipient != address(0)) {
            /* Sell-side order is maker. */
      
            /* Assert taker fee is less than or equal to maximum fee specified by buyer. */
            require(sell.takerRelayerFee <= buy.takerRelayerFee);

            if (sell.feeMethod == FeeMethod.SplitFee) {
                /* Assert taker fee is less than or equal to maximum fee specified by buyer. */
                require(sell.takerProtocolFee <= buy.takerProtocolFee);

                /* Maker fees are deducted from the token amount that the maker receives. Taker fees are extra tokens that must be paid by the taker. */

                if (sell.makerRelayerFee > 0) {
                    uint makerRelayerFee = sell.makerRelayerFee * price / INVERSE_BASIS_POINT;
                    if (address(sell.paymentToken) == address(0)) {
                        receiveAmount = receiveAmount - makerRelayerFee;
                        payable(sell.feeRecipient).transfer(makerRelayerFee);
                    } else {
                        transferTokens(sell.paymentToken, sell.maker, sell.feeRecipient, makerRelayerFee);
                    }
                }

                if (sell.takerRelayerFee > 0) {
                    uint takerRelayerFee = sell.takerRelayerFee * price / INVERSE_BASIS_POINT;
                    if (address(sell.paymentToken) == address(0)) {
                        requiredAmount = requiredAmount + takerRelayerFee;
                        payable(sell.feeRecipient).transfer(takerRelayerFee);
                    } else {
                        transferTokens(sell.paymentToken, buy.maker, sell.feeRecipient, takerRelayerFee);
                    }
                }

                if (sell.makerProtocolFee > 0) {
                    uint makerProtocolFee = sell.makerProtocolFee * price / INVERSE_BASIS_POINT;
                    if (address(sell.paymentToken) == address(0)) {
                        receiveAmount = receiveAmount - makerProtocolFee;
                        payable(protocolFeeRecipient).transfer(makerProtocolFee);
                    } else {
                        transferTokens(sell.paymentToken, sell.maker, protocolFeeRecipient, makerProtocolFee);
                    }
                }

                if (sell.takerProtocolFee > 0) {
                    uint takerProtocolFee = sell.takerProtocolFee * price / INVERSE_BASIS_POINT;
                    if (address(sell.paymentToken) == address(0)) {
                        requiredAmount = requiredAmount + takerProtocolFee;
                        payable(protocolFeeRecipient).transfer(takerProtocolFee);
                    } else {
                        transferTokens(sell.paymentToken, buy.maker, protocolFeeRecipient, takerProtocolFee);
                    }
                }

            } else {
                /* Charge maker fee to seller. */
                chargeProtocolFee(sell.maker, sell.feeRecipient, sell.makerRelayerFee);

                /* Charge taker fee to buyer. */
                chargeProtocolFee(buy.maker, sell.feeRecipient, sell.takerRelayerFee);
            }
        } else {
            /* Buy-side order is maker. */

            /* Assert taker fee is less than or equal to maximum fee specified by seller. */
            require(buy.takerRelayerFee <= sell.takerRelayerFee);

            if (sell.feeMethod == FeeMethod.SplitFee) {
                /* The Exchange does not escrow Ether, so direct Ether can only be used to with sell-side maker / buy-side taker orders. */
                require(address(sell.paymentToken) != address(0));

                /* Assert taker fee is less than or equal to maximum fee specified by seller. */
                require(buy.takerProtocolFee <= sell.takerProtocolFee);

                if (buy.makerRelayerFee > 0) {
                    uint makerRelayerFee = buy.makerRelayerFee * price / INVERSE_BASIS_POINT;
                    transferTokens(sell.paymentToken, buy.maker, buy.feeRecipient, makerRelayerFee);
                }

                if (buy.takerRelayerFee > 0) {
                    uint takerRelayerFee = buy.takerRelayerFee * price / INVERSE_BASIS_POINT;
                    transferTokens(sell.paymentToken, sell.maker, buy.feeRecipient, takerRelayerFee);
                }

                if (buy.makerProtocolFee > 0) {
                    uint makerProtocolFee = buy.makerProtocolFee * price / INVERSE_BASIS_POINT;
                    transferTokens(sell.paymentToken, buy.maker, protocolFeeRecipient, makerProtocolFee);
                }

                if (buy.takerProtocolFee > 0) {
                    uint takerProtocolFee = buy.takerProtocolFee * price / INVERSE_BASIS_POINT;
                    transferTokens(sell.paymentToken, sell.maker, protocolFeeRecipient, takerProtocolFee);
                }

            } else {
                /* Charge maker fee to buyer. */
                chargeProtocolFee(buy.maker, buy.feeRecipient, buy.makerRelayerFee);
      
                /* Charge taker fee to seller. */
                chargeProtocolFee(sell.maker, buy.feeRecipient, buy.takerRelayerFee);
            }
        }

        if (address(sell.paymentToken) == address(0)) {
            /* Special-case Ether, order must be matched by buyer. */
            require(msg.value >= requiredAmount);
            payable(sell.maker).transfer(receiveAmount);
            /* Allow overshoot for variable-price auctions, refund difference. */
            uint diff = msg.value - requiredAmount;
            if (diff > 0) {
                payable(buy.maker).transfer(diff);
            }
        }

        /* This contract should never hold Ether, however, we cannot assert this, since it is impossible to prevent anyone from sending Ether e.g. with selfdestruct. */

        return price;
    }

    function canSettleOrder(uint listingTime, uint expirationTime)
        view
        internal
        returns (bool)
    {
        return (listingTime < block.timestamp) && (expirationTime == 0 || block.timestamp < expirationTime);
    }


    function ordersCanMatch(Order memory buy, Order memory sell)
        internal
        view
        returns (bool)
    {
        return (
            /* Must be opposite-side. */
            (buy.side == Side.Buy && sell.side == Side.Sell) &&     
            /* Must use same fee method. */
            (buy.feeMethod == sell.feeMethod) &&
            /* Must use same payment token. */
            (buy.paymentToken == sell.paymentToken) &&
            /* Must match maker/taker addresses. */
            (sell.taker == address(0) || sell.taker == buy.maker) &&
            (buy.taker == address(0) || buy.taker == sell.maker) &&
            /* One must be maker and the other must be taker (no bool XOR in Solidity). */
            ((sell.feeRecipient == address(0) && buy.feeRecipient != address(0)) || (sell.feeRecipient != address(0) && buy.feeRecipient == address(0))) &&
            /* Must match target. */
            (buy.target == sell.target) &&
            /* Must match howToCall. */
            (buy.howToCall == sell.howToCall) &&
            /* Buy-side order must be settleable. */
            canSettleOrder(buy.listingTime, buy.expirationTime) &&
            /* Sell-side order must be settleable. */
            canSettleOrder(sell.listingTime, sell.expirationTime)
        );
    }

    function atomicMatch(Order memory buy, Sig memory buySig, Order memory sell, Sig memory sellSig, bytes32 metadata)
        internal
        nonReentrant
    {
        /* CHECKS */
      
        /* Ensure buy order validity and calculate hash if necessary. */
        bytes32 buyHash;
        if (buy.maker == msg.sender) {
            require(validateOrderParameters(buy));
        } else {
            buyHash = requireValidOrder(buy, buySig);
        }

        /* Ensure sell order validity and calculate hash if necessary. */
        bytes32 sellHash;
        if (sell.maker == msg.sender) {
            require(validateOrderParameters(sell));
        } else {
            sellHash = requireValidOrder(sell, sellSig);
        }
        
        /* Must be matchable. */
        require(ordersCanMatch(buy, sell));

        /* Target must exist (prevent malicious selfdestructs just prior to order settlement). */
        uint size;
        address target = sell.target;
        assembly {
            size := extcodesize(target)
        }
        require(size > 0);
      
        /* Must match calldata after replacement, if specified. */ 
        if (buy.replacementPattern.length > 0) {
          ArrayUtils.guardedArrayReplace(buy.targetdata, sell.targetdata, buy.replacementPattern);
        }
        if (sell.replacementPattern.length > 0) {
          ArrayUtils.guardedArrayReplace(sell.targetdata, buy.targetdata, sell.replacementPattern);
        }
        require(ArrayUtils.arrayEq(buy.targetdata, sell.targetdata));

        /* Retrieve delegateProxy contract. */
        IProxyImplementation delegateProxy = proxyFactory.proxies(sell.maker);

        /* Proxy must exist. */
        require(address(delegateProxy) != address(0));

        /* Assert implementation. */
        require(IOwnableDelegateProxy(address(delegateProxy)).implementation() == address(proxyFactory.proxyImplementation()));

        /* Access the passthrough ProxyImplementation. */
        IProxyImplementation proxy = IProxyImplementation(address(delegateProxy));

        /* EFFECTS */

        /* Mark previously signed or approved orders as finalized. */
        if (msg.sender != buy.maker) {
            cancelledOrFinalized[buyHash] = true;
        }
        if (msg.sender != sell.maker) {
            cancelledOrFinalized[sellHash] = true;
        }

        /* INTERACTIONS */

        /* Execute funds transfer and pay fees. */
        uint price = executeFundsTransfer(buy, sell);

        /* Execute specified call through proxy. */
        require(proxy.proxy(sell.target, sell.howToCall, sell.targetdata));

        /* Static calls are intentionally done after the effectful call so they can check resulting state. */

        /* Handle buy-side static call if specified. */
        if (buy.staticTarget != address(0)) {
            require(staticCall(buy.staticTarget, sell.targetdata, buy.staticExtradata));
        }

        /* Handle sell-side static call if specified. */
        if (sell.staticTarget != address(0)) {
            require(staticCall(sell.staticTarget, sell.targetdata, sell.staticExtradata));
        }

        /* Log match event. */
        emit OrdersMatched(buyHash, sellHash, sell.feeRecipient != address(0) ? sell.maker : buy.maker, sell.feeRecipient != address(0) ? buy.maker : sell.maker, price, metadata);
    }

}
// SPDX-License-Identifier: MIT

pragma solidity >=0.8.4;

import "./ExchangeCore.sol";

contract ExchangeView is ExchangeCore {
    
    address public exchange;

    constructor(address _exchange) {
        exchange = _exchange;
    }

    function validateOrderParametersView(Order memory order)
        internal
        view
        returns (bool)
    {
        /* Order must be targeted at this protocol version (this Exchange contract). */
        if (order.exchange != exchange) {
            return false;
        }
        /* Order must possess valid sale kind parameter combination. */
        if (!validateParameters(order.saleKind, order.expirationTime)) {
            return false;
        }

        /* If using the split fee method, order must have sufficient protocol fees. */
        if (order.feeMethod == FeeMethod.SplitFee && (order.makerProtocolFee < minimumMakerProtocolFee || order.takerProtocolFee < minimumTakerProtocolFee)) {
            return false;
        }

        return true;
    }

    function validateOrderView(bytes32 hash, Order memory order, Sig memory sig) 
        internal
        view
        returns (bool)
    {
        /* Not done in an if-conditional to prevent unnecessary ecrecover evaluation, which seems to happen even though it should short-circuit. */
        /* Order must have valid parameters. */
        if (!validateOrderParametersView(order)) {
            return false;
        }

        /* Order must have not been canceled or already filled. */
        if (ExchangeCore(exchange).cancelledOrFinalized(hash)) {
            return false;
        }
        
        /* Order authentication. Order must be either:
        /* (a) previously approved */
        if (ExchangeCore(exchange).approvedOrders(hash)) {
            return true;
        }

        /* or (b) ECDSA-signed by maker. */
        if (ecrecover(hash, sig.v, sig.r, sig.s) == order.maker) {
            return true;
        }

        return false;
    }

    function guardedArrayReplace(bytes memory data, bytes memory desired, bytes memory mask)
        external
        pure
        returns (bytes memory)
    {
        ArrayUtils.guardedArrayReplace(data, desired, mask);
        return data;
    }

    function testCopy(bytes memory arrToCopy)
        external
        pure
        returns (bytes memory)
    {
        bytes memory arr = new bytes(arrToCopy.length);
        uint index;
        assembly {
            index := add(arr, 0x20)
        }
        ArrayUtils.unsafeWriteBytes(index, arrToCopy);
        return arr;
    }

    function testCopyAddress(address addr)
        external
        pure
        returns (bytes memory)
    {
        bytes memory arr = new bytes(0x14);
        uint index;
        assembly {
            index := add(arr, 0x20)
        }
        ArrayUtils.unsafeWriteAddress(index, addr);
        return arr;
    }

    function getCalculateFinalPrice(Side side, SaleKind saleKind, uint basePrice, uint extra, uint listingTime, uint expirationTime)
        external
        view
        returns (uint)
    {
        return calculateFinalPrice(side, saleKind, basePrice, extra, listingTime, expirationTime);
    }

    function hashOrder_(
        address[7] memory addrs,
        uint[9] memory uints,
        FeeMethod feeMethod,
        Side side,
        SaleKind saleKind,
        IProxyImplementation.HowToCall howToCall,
        bytes memory data,
        bytes memory replacementPattern,
        bytes memory staticExtradata)
        public
        pure
        returns (bytes32)
    {
        return hashOrder(
          Order(addrs[0], addrs[1], addrs[2], uints[0], uints[1], uints[2], uints[3], addrs[3], feeMethod, side, saleKind, addrs[4], howToCall, data, replacementPattern, addrs[5], staticExtradata, IERC20(addrs[6]), uints[4], uints[5], uints[6], uints[7], uints[8])
        );
    }

    function hashToSign_(
        address[7] memory addrs,
        uint[9] memory uints,
        FeeMethod feeMethod,
        Side side,
        SaleKind saleKind,
        IProxyImplementation.HowToCall howToCall,
        bytes memory data,
        bytes memory replacementPattern,
        bytes memory staticExtradata)
        public
        pure
        returns (bytes32)
    { 
        return hashToSign(
          Order(addrs[0], addrs[1], addrs[2], uints[0], uints[1], uints[2], uints[3], addrs[3], feeMethod, side, saleKind, addrs[4], howToCall, data, replacementPattern, addrs[5], staticExtradata, IERC20(addrs[6]), uints[4], uints[5], uints[6], uints[7], uints[8])
        );
    }

    function validateOrderParameters_ (
        address[7] memory addrs,
        uint[9] memory uints,
        FeeMethod feeMethod,
        Side side,
        SaleKind saleKind,
        IProxyImplementation.HowToCall howToCall,
        bytes memory data,
        bytes memory replacementPattern,
        bytes memory staticExtradata)
        view
        public
        returns (bool)
    {
        Order memory order = Order(addrs[0], addrs[1], addrs[2], uints[0], uints[1], uints[2], uints[3], addrs[3], feeMethod, side, saleKind, addrs[4], howToCall, data, replacementPattern, addrs[5], staticExtradata, IERC20(addrs[6]), uints[4], uints[5], uints[6], uints[7], uints[8]);
        return validateOrderParameters(
          order
        );
    }

    function validateOrder_ (
        address[7] memory addrs,
        uint[9] memory uints,
        FeeMethod feeMethod,
        Side side,
        SaleKind saleKind,
        IProxyImplementation.HowToCall howToCall,
        bytes memory data,
        bytes memory replacementPattern,
        bytes memory staticExtradata,
        uint8 v,
        bytes32 r,
        bytes32 s)
        view
        public
        returns (bool)
    {
        Order memory order = Order(addrs[0], addrs[1], addrs[2], uints[0], uints[1], uints[2], uints[3], addrs[3], feeMethod, side, saleKind, addrs[4], howToCall, data, replacementPattern, addrs[5], staticExtradata, IERC20(addrs[6]), uints[4], uints[5], uints[6], uints[7], uints[8]);
        return validateOrderView(
          hashToSign(order),
          order,
          Sig(v, r, s)
        );
    }

    function calculateCurrentPrice_(
        address[7] memory addrs,
        uint[9] memory uints,
        FeeMethod feeMethod,
        Side side,
        SaleKind saleKind,
        IProxyImplementation.HowToCall howToCall,
        bytes memory data,
        bytes memory replacementPattern,
        bytes memory staticExtradata)
        public
        view
        returns (uint)
    {
        return calculateCurrentPrice(
          Order(addrs[0], addrs[1], addrs[2], uints[0], uints[1], uints[2], uints[3], addrs[3], feeMethod, side, saleKind, addrs[4], howToCall, data, replacementPattern, addrs[5], staticExtradata, IERC20(addrs[6]), uints[4], uints[5], uints[6], uints[7], uints[8])
        );
    }

    function ordersCanMatch_(
        address[14] memory addrs,
        uint[18] memory uints,
        uint8[8] memory feeMethodsSidesKindsHowToCalls,
        bytes memory calldataBuy,
        bytes memory calldataSell,
        bytes memory replacementPatternBuy,
        bytes memory replacementPatternSell,
        bytes memory staticExtradataBuy,
        bytes memory staticExtradataSell)
        public
        view
        returns (bool)
    {
        Order memory buy = Order(addrs[0], addrs[1], addrs[2], uints[0], uints[1], uints[2], uints[3], addrs[3], FeeMethod(feeMethodsSidesKindsHowToCalls[0]), Side(feeMethodsSidesKindsHowToCalls[1]), SaleKind(feeMethodsSidesKindsHowToCalls[2]), addrs[4], IProxyImplementation.HowToCall(feeMethodsSidesKindsHowToCalls[3]), calldataBuy, replacementPatternBuy, addrs[5], staticExtradataBuy, IERC20(addrs[6]), uints[4], uints[5], uints[6], uints[7], uints[8]);
        Order memory sell = Order(addrs[7], addrs[8], addrs[9], uints[9], uints[10], uints[11], uints[12], addrs[10], FeeMethod(feeMethodsSidesKindsHowToCalls[4]), Side(feeMethodsSidesKindsHowToCalls[5]), SaleKind(feeMethodsSidesKindsHowToCalls[6]), addrs[11], IProxyImplementation.HowToCall(feeMethodsSidesKindsHowToCalls[7]), calldataSell, replacementPatternSell, addrs[12], staticExtradataSell, IERC20(addrs[13]), uints[13], uints[14], uints[15], uints[16], uints[17]);
        return ordersCanMatch(
          buy,
          sell
        );
    }

    function orderCalldataCanMatch(bytes memory buyCalldata, bytes memory buyReplacementPattern, bytes memory sellCalldata, bytes memory sellReplacementPattern)
        public
        pure
        returns (bool)
    {
        if (buyReplacementPattern.length > 0) {
          ArrayUtils.guardedArrayReplace(buyCalldata, sellCalldata, buyReplacementPattern);
        }
        if (sellReplacementPattern.length > 0) {
          ArrayUtils.guardedArrayReplace(sellCalldata, buyCalldata, sellReplacementPattern);
        }
        return ArrayUtils.arrayEq(buyCalldata, sellCalldata);
    }

    function calculateMatchPrice_(
        address[14] memory addrs,
        uint[18] memory uints,
        uint8[8] memory feeMethodsSidesKindsHowToCalls,
        bytes memory calldataBuy,
        bytes memory calldataSell,
        bytes memory replacementPatternBuy,
        bytes memory replacementPatternSell,
        bytes memory staticExtradataBuy,
        bytes memory staticExtradataSell)
        public
        view
        returns (uint)
    {
        Order memory buy = Order(addrs[0], addrs[1], addrs[2], uints[0], uints[1], uints[2], uints[3], addrs[3], FeeMethod(feeMethodsSidesKindsHowToCalls[0]), Side(feeMethodsSidesKindsHowToCalls[1]), SaleKind(feeMethodsSidesKindsHowToCalls[2]), addrs[4], IProxyImplementation.HowToCall(feeMethodsSidesKindsHowToCalls[3]), calldataBuy, replacementPatternBuy, addrs[5], staticExtradataBuy, IERC20(addrs[6]), uints[4], uints[5], uints[6], uints[7], uints[8]);
        Order memory sell = Order(addrs[7], addrs[8], addrs[9], uints[9], uints[10], uints[11], uints[12], addrs[10], FeeMethod(feeMethodsSidesKindsHowToCalls[4]), Side(feeMethodsSidesKindsHowToCalls[5]), SaleKind(feeMethodsSidesKindsHowToCalls[6]), addrs[11], IProxyImplementation.HowToCall(feeMethodsSidesKindsHowToCalls[7]), calldataSell, replacementPatternSell, addrs[12], staticExtradataSell, IERC20(addrs[13]), uints[13], uints[14], uints[15], uints[16], uints[17]);
        return calculateMatchPrice(
          buy,
          sell
        );
    }
}
// SPDX-License-Identifier: MIT

pragma solidity >=0.8.4;

import '@openzeppelin/contracts-upgradeable/proxy/ERC1967/ERC1967UpgradeUpgradeable.sol';
import '@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol';
import '@openzeppelin/contracts/utils/Address.sol';
import '@openzeppelin/contracts/proxy/Proxy.sol';
import '../interfaces/IProxyImplementation.sol';
import '../interfaces/IProxyFactory.sol';

contract OwnableDelegateProxy is ERC1967UpgradeUpgradeable, Proxy {
    using Address for address;

    function initialize (IProxyImplementation _impl, address _user, address _factory) external initializer {
        _upgradeToAndCall(address(_impl), abi.encodeWithSignature("initialize(address,address)", _user, _factory), true);
    }

    function _implementation() internal view virtual override returns (address) {
        return _getImplementation(); 
    }

    function implementation() external view returns (address) {
        return _implementation();
    }
}
// SPDX-License-Identifier: MIT

pragma solidity >=0.8.4;

import '@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol';
import '@openzeppelin/contracts/utils/Address.sol';
import '../interfaces/IOwnableDelegateProxy.sol';
import '../interfaces/IProxyImplementation.sol';
import './OwnableDelegateProxy.sol';
import '../core/SafeOwnable.sol';

contract ProxyFactory is SafeOwnable, Initializable {

    bytes32 public constant INIT_CODE_HASH = keccak256(abi.encodePacked(type(OwnableDelegateProxy).creationCode));

    IProxyImplementation public proxyImplementation;

    mapping(address => IOwnableDelegateProxy) public proxies;

    mapping(address => uint) public pending;

    mapping(address => bool) public contracts;

    uint public DELAY_PERIOD = 2 weeks;

    constructor(IProxyImplementation _proxyImplementation) {
        proxyImplementation = _proxyImplementation;
    }

    function startGrantAuthentication (address _addr) external onlyOwner {
        require(!contracts[_addr] && pending[_addr] == 0, "already in contracts or pending");
        pending[_addr] = block.timestamp;
    }

    function endGrantAuthentication (address _addr) external onlyOwner {
        require(!contracts[_addr] && pending[_addr] != 0 && ((pending[_addr] + DELAY_PERIOD) < block.timestamp), "time not right");
        pending[_addr] = 0;
        contracts[_addr] = true;
    }

    function revokeAuthentication (address _addr) external onlyOwner {
        contracts[_addr] = false;
    }

    function registerProxy() external returns (address proxy) {
        require(address(proxies[msg.sender]) == address(0), "already registed");
        bytes memory bytecode = type(OwnableDelegateProxy).creationCode;
        bytes32 salt = keccak256(abi.encodePacked(msg.sender));
        assembly {
            proxy := create2(0, add(bytecode, 32), mload(bytecode), salt)
        }
        proxies[msg.sender] = IOwnableDelegateProxy(payable(proxy));
        IOwnableDelegateProxy(payable(proxy)).initialize(proxyImplementation, msg.sender, address(this));
    }

    function grantInitialAuthentication(address authAddress) external onlyOwner initializer {
        contracts[authAddress] = true;
    }
}
// SPDX-License-Identifier: MIT

pragma solidity >=0.8.4;

import '@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol';
import '@openzeppelin/contracts/utils/Address.sol';
import '../interfaces/IProxyFactory.sol';

contract ProxyImplementation is Initializable {
    using Address for address;

    address public user;

    IProxyFactory public factory;

    bool public revoked;

    enum HowToCall { Call, DelegateCall }

    event Revoked(bool revoked);

    function initialize (address _user, IProxyFactory _factory) external onlyInitializing {
        require(user == address(0) && address(factory) == address(0), "already verified");
        user = _user;
        factory = _factory;
    }

    function setRevoke(bool revoke) external {
        require(msg.sender == user, "only user can do this");
        revoked = revoke;
        emit Revoked(revoke);
    }

    function proxy(address dest, HowToCall howToCall, bytes memory data) public returns (bool result) {
        require(msg.sender == user || (!revoked && factory.contracts(msg.sender)));
        if (howToCall == HowToCall.Call) {
            dest.functionCall(data);
        } else if (howToCall == HowToCall.DelegateCall) {
            dest.functionDelegateCall(data);
        } else {
            return false;
        }
        return true;
    }

}
// SPDX-License-Identifier: MIT

pragma solidity >=0.8.4;

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "../interfaces/IProxyFactory.sol";

contract TokenTransferProxy {
    using SafeERC20 for IERC20;

    IProxyFactory public factory;

    constructor(IProxyFactory _factory) {
        factory = _factory;
    }

    function transferFrom(IERC20 _token, address _from, address _to, uint _amount) external returns (bool) {
        require(factory.contracts(msg.sender), "illegal caller");
        _token.safeTransferFrom(_from, _to, _amount);
        return true;
    }

}
// SPDX-License-Identifier: MIT

pragma solidity >=0.8.4;

import '@openzeppelin/contracts/token/ERC1155/ERC1155.sol';
import '../core/SafeOwnable.sol';

contract MockERC1155 is SafeOwnable, ERC1155 {

    string public name;
    string public symbol;
    function setURI(string memory _uri) external onlyOwner {
        _setURI(_uri);
    }

    constructor(
        string memory _name, 
        string memory _symbol, 
        string memory _uri
    ) ERC1155(_uri) {
        name = _name;
        symbol = _symbol;
    }

    function mint(address _to, uint _tokenId, uint _amount) external onlyOwner {
        _mint(_to, _tokenId, _amount, new bytes(0));
    }
}
// SPDX-License-Identifier: MIT

pragma solidity >= 0.8.4;

import '@openzeppelin/contracts/token/ERC20/ERC20.sol';

contract MockERC20 is ERC20 {

    uint8 tokenDecimals;

    constructor(string memory _name, string memory _symbol, uint8 _decimals) ERC20(_name, _symbol) {
        tokenDecimals = _decimals;
    }

    function mint(address _to, uint _amount) external returns (uint) {
        _mint(_to, _amount);
        return _amount;
    }

    function burn(address _to, uint _amount) external {
        _burn(_to, _amount);
    }

    function decimals() public view virtual override(ERC20) returns (uint8) {
        return tokenDecimals;
    }
}
// SPDX-License-Identifier: MIT

pragma solidity >= 0.8.4;

import '@openzeppelin/contracts/token/ERC20/ERC20.sol';
import './MockToken.sol';

contract MockERC20Factory {

    event Deploy(string name, string symbol, uint8 decimals, MockToken token);

    function deploy(string memory _name, string memory _symbol, uint8 _decimals) external {
        MockToken token = new MockToken(_name, _symbol, _decimals);
        emit Deploy(_name, _symbol, _decimals, token);
    }
}
// SPDX-License-Identifier: MIT

pragma solidity >=0.8.4;

import '@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol';
import '../core/SafeOwnable.sol';

contract MockERC721 is SafeOwnable, ERC721Enumerable {

    string public baseURI;

    function _baseURI() internal view override virtual returns (string memory) {
        return baseURI;
    }

    constructor(
        string memory _name, 
        string memory _symbol, 
        string memory _uri
    ) ERC721(_name, _symbol) {
        baseURI = _uri;
    }

    function mint(address _to, uint _tokenId) external onlyOwner {
        _mint(_to, _tokenId);
    }

    function setBaseURI(string memory _uri) external onlyOwner {
        baseURI = _uri;
    }
}
// SPDX-License-Identifier: MIT

pragma solidity >=0.8.4;

import '../interfaces/IMintableBurnableERC721V2.sol';
import '../core/SafeOwnable.sol';
import '../core/Mintable.sol';
import '../core/Burnable.sol';
import '../core/NFTCoreV3.sol';

contract MockNFT is SafeOwnable, NFTCoreV3, Mintable, Burnable {

    constructor(
        string memory _name, 
        string memory _symbol, 
        string memory _uri
    ) NFTCoreV3(_name, _symbol, _uri, type(uint256).max) Mintable(new address[](0), false) Burnable(new address[](0), false) {
    }

    function mint(address _to, uint _num) external {
        mintInternal(_to, _num);
    }

    function burn(address _user, uint256 _tokenId) external {
        burnInternal(_user, _tokenId); 
    }
}
// SPDX-License-Identifier: MIT

pragma solidity >=0.8.4;

import '@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol';
import '../core/SafeOwnable.sol';

contract MockNFTV2 is SafeOwnable, ERC721Enumerable {

    string public baseURI;

    function _baseURI() internal view override virtual returns (string memory) {
        return baseURI;
    }

    constructor(
        string memory _name, 
        string memory _symbol, 
        string memory _uri
    ) ERC721(_name, _symbol) {
        baseURI = _uri;
    }

    function mint(address _to, uint _tokenId) external onlyOwner {
        _mint(_to, _tokenId);
    }

    function setBaseURI(string memory _uri) external onlyOwner {
        baseURI = _uri;
    }
}
// SPDX-License-Identifier: MIT

pragma solidity >= 0.8.4;

import '@openzeppelin/contracts/token/ERC20/ERC20.sol';

contract MockToken is ERC20 {

    uint8 tokenDecimals;

    constructor(string memory _name, string memory _symbol, uint8 _decimals) ERC20(_name, _symbol) {
        tokenDecimals = _decimals;
    }

    function mint(address _to, uint _amount) external returns (uint) {
        _mint(_to, _amount);
        return _amount;
    }

    function burn(address _to, uint _amount) external {
        _burn(_to, _amount);
    }

    function decimals() public view virtual override(ERC20) returns (uint8) {
        return tokenDecimals;
    }
}
// SPDX-License-Identifier: MIT

pragma solidity >=0.8.4;

import '../interfaces/IMintableERC20.sol';

contract TokenFaucet {

    function mint(IMintableERC20 _token, address _to, uint _amount) external {
        _token.mint(_to, _amount); 
    }
}
// SPDX-License-Identifier: MIT

pragma solidity >= 0.8.4;

contract WETH {

    string public name;
    string public symbol;
    uint8  public decimals;

    constructor(string memory _name, string memory _symbol, uint8 _decimals) {
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
    }

    event  Approval(address indexed src, address indexed guy, uint wad);
    event  Transfer(address indexed src, address indexed dst, uint wad);
    event  Deposit(address indexed dst, uint wad);
    event  Withdrawal(address indexed src, uint wad);

    mapping (address => uint)                       public  balanceOf;
    mapping (address => mapping (address => uint))  public  allowance;

    receive() external payable {
        deposit();
    }

    function deposit() public payable {
        balanceOf[msg.sender] += msg.value;
        emit Deposit(msg.sender, msg.value);
    }

    function withdraw(uint wad) external {
        require(balanceOf[msg.sender] >= wad, "illegal balance");
        balanceOf[msg.sender] -= wad;
        payable(msg.sender).transfer(wad);
        emit Withdrawal(msg.sender, wad);
    }

    function totalSupply() public view returns (uint) {
        return address(this).balance;
    }

    function approve(address guy, uint wad) public returns (bool) {
        allowance[msg.sender][guy] = wad;
        emit Approval(msg.sender, guy, wad);
        return true;
    }

    function transfer(address dst, uint wad) public returns (bool) {
        return transferFrom(msg.sender, dst, wad);
    }

    function transferFrom(address src, address dst, uint wad)
        public
        returns (bool)
    {
        require(balanceOf[src] >= wad);

        if (src != msg.sender && allowance[src][msg.sender] != type(uint).max) {
            require(allowance[src][msg.sender] >= wad);
            allowance[src][msg.sender] -= wad;
        }

        balanceOf[src] -= wad;
        balanceOf[dst] += wad;

        emit Transfer(src, dst, wad);

        return true;
    }
}
// SPDX-License-Identifier: MIT

pragma solidity >=0.8.4;

import '../interfaces/IMintableBurnableERC721V2.sol';
import '../core/SafeOwnable.sol';
import '../core/Mintable.sol';
import '../core/Burnable.sol';
import '../core/NFTCoreV3.sol';

contract ClassicNFT is SafeOwnable, NFTCoreV3, Mintable, Burnable {

    constructor(
        string memory _name, 
        string memory _symbol, 
        string memory _uri
    ) NFTCoreV3(_name, _symbol, _uri, type(uint256).max) Mintable(new address[](0), false) Burnable(new address[](0), false) {
    }

    function mint(address _to, uint _num) external onlyMinter {
        mintInternal(_to, _num);
    }

    function burn(address _user, uint256 _tokenId) external onlyBurner {
        burnInternal(_user, _tokenId);
    }
}
// SPDX-License-Identifier: MIT

pragma solidity >=0.8.4;

import '@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol';
import '../interfaces/IMintableERC721.sol';
import '../core/SafeOwnable.sol';

contract CostMint is SafeOwnable {
    using SafeERC20 for IERC20;

    event ReceiverChanged(address oldReceiver, address newReceiver);
    event TokenPriceChanged(IERC20 token, uint price, bool avaliable);

    address immutable public WETH;
    IMintableERC721 public immutable nft;
    uint public immutable startAt;
    uint public immutable finishAt;
    uint public immutable maxNum;
    uint public immutable userLimit;

    mapping(IERC20 => bool) public supportTokens;
    mapping(IERC20 => uint) public tokensPrice;
    address payable public receiver;

    uint public sellNum;
    mapping(address => uint) public buyNum;

    constructor(
        address _WETH, 
        IMintableERC721 _nft, 
        uint _startAt, 
        uint _finishAt, 
        uint _maxNum, 
        uint _userLimit, 
        IERC20[] memory _tokens, 
        uint[] memory _prices, 
        address payable _receiver
    ) {
        require(_WETH != address(0), "illegal WETH");
        WETH = _WETH;
        require(address(_nft) != address(0), "illegal nft");
        nft = _nft;
        require(_startAt > block.timestamp && _finishAt > _startAt, "illegal time");
        startAt = _startAt;
        finishAt = _finishAt;
        require(_userLimit > 0 && _maxNum > _userLimit, "illegal num");
        maxNum = _maxNum;
        userLimit = _userLimit;
        require(_tokens.length == _prices.length && _tokens.length > 0, "illegal length");
        for (uint i = 0; i < _tokens.length; i ++) {
            require(address(_tokens[i]) != address(0) && !supportTokens[_tokens[i]], "illegal token");
            supportTokens[_tokens[i]] = true;
            tokensPrice[_tokens[i]] = _prices[i];
            emit TokenPriceChanged(_tokens[i], _prices[i], true);
        }
        require(_receiver != address(0), "illegal receiver");
        receiver = _receiver;
        emit ReceiverChanged(address(0), _receiver);
    }

    function addSupportToken(IERC20 _token, uint _price) external onlyOwner {
        require(address(_token) != address(0) && !supportTokens[_token], "illegal token");
        supportTokens[_token] = true;
        tokensPrice[_token] = _price;
        emit TokenPriceChanged(_token, _price, true);
    }

    function setSupportToken(IERC20 _token, uint _price) external onlyOwner {
        require(supportTokens[_token], "token not exist");
        tokensPrice[_token] = _price;
        emit TokenPriceChanged(_token, _price, true);
    }

    function delSupportToken(IERC20 _token) external onlyOwner {
        require(supportTokens[_token], "token not exist");
        delete supportTokens[_token];
        delete tokensPrice[_token];
        emit TokenPriceChanged(_token, 0, false);
    }

    function setReceiver(address payable _receiver) external onlyOwner {
        require(_receiver != address(0), "illegal receiver");
        emit ReceiverChanged(receiver, _receiver);
        receiver = _receiver;
    }

    modifier AlreadyBegin() {
        require(block.timestamp >= startAt, "not begin");
        _;
    }

    modifier NotFinish() {
        require(block.timestamp <= finishAt, "already finish");
        _;
    }

    modifier TokenSupport(IERC20 _token) {
        require(supportTokens[_token], "token not support");
        _;
    }

    modifier Enough(uint _num) {
        require(sellNum + _num <= maxNum, "already full");
        require(buyNum[msg.sender] + _num <= userLimit, "already limit");
        _;
    }

    function buy(IERC20 _payToken, uint _num) external payable AlreadyBegin NotFinish TokenSupport(_payToken) Enough(_num) {
        unchecked {
            uint cost = _num * tokensPrice[_payToken];
            if (cost > 0) {
                if (address(_payToken) == WETH) {
                    require(msg.value == cost, "illegal payment");
                    receiver.transfer(msg.value);
                } else {
                    _payToken.safeTransferFrom(msg.sender, receiver, cost);
                }
            }
            nft.mint(msg.sender, _num);
            sellNum += _num;
            buyNum[msg.sender] += _num;
        }
    }
}
// SPDX-License-Identifier: MIT

pragma solidity >=0.8.4;

import '../interfaces/IMintableERC721.sol';
import '../core/SafeOwnable.sol';
import '../core/Verifier.sol';

contract FreeMint is SafeOwnable, Verifier {

    IMintableERC721 public immutable nft;
    uint public immutable startAt;
    uint public immutable finishAt;

    mapping(address => uint) public userMintNum;
    uint public totalMintNum;

    constructor(IMintableERC721 _nft, uint _startAt, uint _finishAt, address _verifier) Verifier(_verifier) {
        require(address(_nft) != address(0), "illegal nft");
        nft = _nft;
        require(_startAt > block.timestamp && _finishAt > _startAt, "illegal time");
        startAt = _startAt;
        finishAt = _finishAt;
    }
    
    modifier AlreadyBegin() {
        require(block.timestamp >= startAt, "not begin");
        _;
    }
    
    modifier NotFinish() {
        require(block.timestamp <= finishAt, "already finish");
        _;
    }

    function mint(uint _num, uint _userNum, uint _totalNum, uint8 _v, bytes32 _r, bytes32 _s) external AlreadyBegin NotFinish {
        require(
            ecrecover(keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", keccak256(abi.encodePacked(address(this), msg.sender, _userNum, _totalNum)))), _v, _r, _s) == verifier,
            "verify failed"
        );
        require(_num + userMintNum[msg.sender] <= _userNum && totalMintNum + _num <= _totalNum, "free mint already full");
        nft.mint(msg.sender, _num);
        userMintNum[msg.sender] += _num;
        totalMintNum += _num;
    }
}
// SPDX-License-Identifier: MIT

pragma solidity >=0.8.4;

import '../core/SafeOwnable.sol';
import '../core/NFTCoreV4.sol';
import '../core/Mintable.sol';
import '../core/Burnable.sol';

contract GeneralNFT is SafeOwnable, NFTCoreV4, Mintable, Burnable {

    constructor(
        string memory _name, 
        string memory _symbol, 
        string memory _uri
    ) NFTCoreV4(_name, _symbol, _uri, type(uint).max) Mintable(new address[](0), false) Burnable(new address[](0), false) {
    }

    function mintById(address _to, uint _tokenId) external onlyMinter {
        mintByIdInternal(_to, _tokenId);
    }

    function burn(address _user, uint256 _tokenId) external onlyBurner {
        burnInternal(_user, _tokenId); 
    }
}
// SPDX-License-Identifier: MIT

pragma solidity >=0.8.4;

import '../interfaces/IBurnableERC721.sol';
import '../interfaces/IGenesisNFT.sol';
import '../core/SafeOwnable.sol';
import '../core/Verifier.sol';

contract GenesisFreeMint is SafeOwnable, Verifier {
    
    event Draw(address user, IBurnableERC721 burnNFT, uint burnNftId, uint newNftId);

    IBurnableERC721 public immutable ticketNFT;
    IGenesisNFT public immutable genesisNFT;
    uint public immutable MAX_MINT_NUM;
    uint public immutable MAX_RESERVE_NUM;
    uint public totalMintNum;
    uint public immutable startAt;
    uint public immutable finishAt;

    constructor(
        IGenesisNFT _genesisNFT,
        address _verifier,
        uint _startAt,
        uint _finishAt
    ) Verifier(_verifier) {
        require(address(_genesisNFT) != address(0), "illegal genesisNft");
        genesisNFT = _genesisNFT;
        ticketNFT = IBurnableERC721(address(_genesisNFT.ticketNFT()));
        MAX_MINT_NUM = _genesisNFT.MAX_MINT_NUM();
        MAX_RESERVE_NUM = _genesisNFT.MAX_RESERVE_NUM();
        require(_startAt > block.timestamp && _finishAt > _startAt, "illegal time");
        startAt = _startAt;
        finishAt = _finishAt;
    }

    modifier AlreadyBegin() {
        require(block.timestamp >= startAt, "not begin");
        _;
    }
    
    modifier NotFinish() {
        require(block.timestamp <= finishAt, "already finish");
        _;
    }
    function draw(uint _luckyNftId, uint _totalNum, uint8 _v, bytes32 _r, bytes32 _s) external AlreadyBegin NotFinish {
        require(
            ecrecover(keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", keccak256(abi.encodePacked(address(this), msg.sender, _luckyNftId, _totalNum)))), _v, _r, _s) == verifier,
            "verify failed"
        );
        if (genesisNFT.mintedNum() < MAX_MINT_NUM) {
            ticketNFT.transferFrom(msg.sender, address(this), _luckyNftId);
            ticketNFT.approve(address(genesisNFT), _luckyNftId);
            genesisNFT.draw(_luckyNftId, MAX_MINT_NUM, _v, _r, _s);
            genesisNFT.transferFrom(address(this), msg.sender, genesisNFT.totalSupply());
        } else if (genesisNFT.reservedNum() < MAX_RESERVE_NUM) {
            uint userNum = genesisNFT.userReserved(msg.sender);
            require(ticketNFT.ownerOf(_luckyNftId) == msg.sender, "illegal user");
            ticketNFT.transferFrom(msg.sender, 0x000000000000000000000000000000000000dEaD, _luckyNftId);
            genesisNFT.reserve(msg.sender, userNum + 1, _v, _r, _s);

        } else {
            revert("already full");
        }
        totalMintNum += 1;
        emit Draw(msg.sender, ticketNFT, _luckyNftId, genesisNFT.totalSupply());
    }
}
// SPDX-License-Identifier: MIT

pragma solidity >=0.8.4;

import '../interfaces/IMintableBurnableERC721.sol';
import '../core/SafeOwnable.sol';
import '../core/Mintable.sol';
import '../core/NFTCore.sol';

contract GenesisNFT is SafeOwnable, NFTCore, Mintable {
    
    event Draw(address user, IMintableBurnableERC721 burnNFT, uint burnNftId, uint newNftId);
    event Reserve(address to, uint nftId);

    uint public constant MAX_MINT_NUM = 2200;
    uint public constant MAX_RESERVE_NUM = 300;

    IMintableBurnableERC721 public immutable ticketNFT;

    uint public mintedNum;
    uint public reservedNum;
    mapping(address => uint) public userReserved;

    constructor(
        string memory _name, 
        string memory _symbol, 
        string memory _uri, 
        IMintableBurnableERC721 _ticketNFT
    ) NFTCore(_name, _symbol, _uri, MAX_MINT_NUM + MAX_RESERVE_NUM) Mintable(new address[](0), false) {
        require(address(_ticketNFT) != address(0), "illegal ticketNFT");
        ticketNFT = _ticketNFT;
    }

    function draw(uint _luckyNftId, uint _totalNum, uint8 _v, bytes32 _r, bytes32 _s) external onlyMinterOrMinterSignature(keccak256(abi.encodePacked(address(this), msg.sender, _luckyNftId, _totalNum)), _v, _r, _s) {
        ticketNFT.burn(msg.sender, _luckyNftId);
        unchecked {
            require(mintedNum < MAX_MINT_NUM && mintedNum < _totalNum && _totalNum <= MAX_MINT_NUM, "mint already full");
            mintInternal(msg.sender, 1);
            mintedNum += 1;
        }
        emit Draw(msg.sender, ticketNFT, _luckyNftId, totalSupply);
    }

    function reserve(address _to, uint _num, uint8 _v, bytes32 _r, bytes32 _s) external onlyMinterOrMinterSignature(keccak256(abi.encodePacked(address(this), _to, _num)), _v, _r, _s) {
        uint availableNum = _num - userReserved[_to];
        unchecked {
            require(availableNum > 0 && reservedNum + availableNum <= MAX_RESERVE_NUM, "reserve already full");
            for (uint i = 0; i < availableNum; i ++) {
                mintInternal(_to, 1);
                emit Reserve(_to, totalSupply);
            }
            reservedNum += availableNum;
            userReserved[_to] += availableNum;
        }
    }
}
// SPDX-License-Identifier: MIT

pragma solidity >=0.8.4;

import '../core/SafeOwnable.sol';
import '../core/NFTCoreV3.sol';
import '../core/Mintable.sol';
import '../core/Burnable.sol';

contract GenesisNFTV2 is SafeOwnable, NFTCoreV3, Mintable, Burnable {

    uint public constant MINT_START_ID = 2501;
    uint public mintId = MINT_START_ID;
    constructor(
        string memory _name, 
        string memory _symbol, 
        string memory _uri
    ) NFTCoreV3(_name, _symbol, _uri, 2500) Mintable(new address[](0), false) Burnable(new address[](0), false) {
    }

    function mint(address _to, uint _num) external onlyMinter {
        for (uint i = 0; i < _num; i ++) {
            mintByIdInternal(_to, mintId + i);
        }
        mintId += _num;
    }

    function mintById(address _to, uint _tokenId) external onlyMinter {
        require(_tokenId < MINT_START_ID, "illeagl _tokenId");
        mintByIdInternal(_to, _tokenId);
    }

    function burn(address _user, uint256 _tokenId) external onlyBurner {
        burnInternal(_user, _tokenId); 
    }
}
// SPDX-License-Identifier: MIT

pragma solidity >=0.8.4;

import '../interfaces/IBurnableERC721.sol';
import '../interfaces/IGenesisNFT.sol';
import '../core/SafeOwnable.sol';
import '../core/Verifier.sol';

contract Halloween is SafeOwnable, Verifier {
    
    event Draw(address user, IBurnableERC721 burnNFT, uint burnNftId, uint newNftId);
    event Reserve(address to, uint nftId);

    uint public constant MAX_MINT_NUM = 2200;
    uint public constant MAX_RESERVE_NUM = 300;

    IBurnableERC721 public immutable ticketNFT;
    IGenesisNFT public immutable genesisNFT;
    uint public immutable MAX_NUM = 300;
    uint public totalMintNum;
    uint public immutable startAt;
    uint public immutable finishAt;

    constructor(
        IBurnableERC721 _ticketNFT,
        IGenesisNFT _genesisNFT,
        address _verifier,
        uint _startAt,
        uint _finishAt
    ) Verifier(_verifier) {
        require(address(_ticketNFT) != address(0), "illegal ticketNft");
        ticketNFT = _ticketNFT;
        require(address(_genesisNFT) != address(0), "illegal genesisNft");
        genesisNFT = _genesisNFT;
        require(_startAt > block.timestamp && _finishAt > _startAt, "illegal time");
        startAt = _startAt;
        finishAt = _finishAt;
    }

    modifier AlreadyBegin() {
        require(block.timestamp >= startAt, "not begin");
        _;
    }
    
    modifier NotFinish() {
        require(block.timestamp <= finishAt, "already finish");
        _;
    }

    function draw(uint _luckyNftId, uint _totalNum, uint8 _v, bytes32 _r, bytes32 _s) external AlreadyBegin NotFinish {
        require(
            ecrecover(keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", keccak256(abi.encodePacked(address(this), msg.sender, _luckyNftId, _totalNum)))), _v, _r, _s) == verifier,
            "verify failed"
        );
        require(totalMintNum <= _totalNum && _totalNum <= MAX_NUM, "already full");
        ticketNFT.transferFrom(msg.sender, 0x000000000000000000000000000000000000dEaD, _luckyNftId);
        genesisNFT.reserve(msg.sender, genesisNFT.userReserved(msg.sender) + 1, 0, 0, 0);
        totalMintNum += 1;
        emit Draw(msg.sender, ticketNFT, _luckyNftId, genesisNFT.totalSupply());
    }
}
// SPDX-License-Identifier: MIT

pragma solidity >=0.8.4;

import '../interfaces/IMintableBurnableERC721V2.sol';
import '../core/SafeOwnable.sol';
import '../core/Mintable.sol';
import '../core/Burnable.sol';
import '../core/NFTCoreV3.sol';

contract PuffNewYearNFT is SafeOwnable, NFTCoreV3, Mintable, Burnable {

    constructor(
        string memory _name, 
        string memory _symbol, 
        string memory _uri
    ) NFTCoreV3(_name, _symbol, _uri, 2023) Mintable(new address[](0), false) Burnable(new address[](0), false) {
    }

    function mint(address _to, uint _num) external onlyMinter {
        mintInternal(_to, _num);
    }

    function burn(address _user, uint256 _tokenId) external onlyBurner {
        burnInternal(_user, _tokenId);
    }
}
// SPDX-License-Identifier: MIT

pragma solidity >=0.8.4;

import '../interfaces/IMintableBurnableERC721.sol';
import '../core/SafeOwnable.sol';
import '../core/Mintable.sol';
import '../core/Burnable.sol';
import '../core/NFTCore.sol';

contract TicketNFT is SafeOwnable, NFTCore, Mintable, Burnable, IMintableBurnableERC721 {

    constructor(
        string memory _name, 
        string memory _symbol, 
        string memory _uri
    ) NFTCore(_name, _symbol, _uri, 15000) Mintable(new address[](0), false) Burnable(new address[](0), false) {
    }

    function mint(address _to, uint _num) external override onlyMinter {
        mintInternal(_to, _num);
    }

    function burn(address _user, uint256 _tokenId) external override onlyBurner {
        burnInternal(_user, _tokenId); 
    }
}
// SPDX-License-Identifier: MIT

pragma solidity >=0.8.4;

import '../core/SafeOwnable.sol';
import '../core/Mintable.sol';
import '../core/Burnable.sol';
import '../core/NFTCoreV3.sol';

contract TicketNFTV2 is SafeOwnable, NFTCoreV3, Mintable, Burnable {

    uint public constant MINT_START_ID = 3959;
    uint public mintId = MINT_START_ID;
    constructor(
        string memory _name, 
        string memory _symbol, 
        string memory _uri
    ) NFTCoreV3(_name, _symbol, _uri, 15000) Mintable(new address[](0), false) Burnable(new address[](0), false) {
    }

    function mint(address _to, uint _num) external onlyMinter {
        for (uint i = 0; i < _num; i ++) {
            mintByIdInternal(_to, mintId + i);
        }
        mintId += _num;
    }

    function mintById(address _to, uint _tokenId) external onlyMinter {
        require(_tokenId < MINT_START_ID, "illeagl _tokenId");
        mintByIdInternal(_to, _tokenId);
    }

    function burn(address _user, uint256 _tokenId) external onlyBurner {
        burnInternal(_user, _tokenId); 
    }

}
// SPDX-License-Identifier: MIT

pragma solidity >=0.8.4;

import '../interfaces/IMintableERC721V2.sol';
import '../core/SafeOwnable.sol';
import '../core/NFTCoreV3.sol';
import '../core/Mintable.sol';
import '../core/Burnable.sol';
import '../core/Verifier.sol';

contract WorldCupNFT is SafeOwnable, NFTCoreV3, Verifier {

    event Mint(IMintableERC721V2 burnNFT, uint burnNftId, uint nftType, uint nftId);

    IMintableERC721V2 public immutable burnNFT;
    address public immutable HOLE_ADDRESS = 0x000000000000000000000000000000000000dEaD;
    uint public constant TYPE_NUM = 32;
    uint public startAt;
    uint public finishAt;

    struct Range {
        uint startIndex;
        uint endIndex;
    }
    Range[] public typeRanges;

    constructor(
        uint _startAt,
        uint _finishAt,
        string memory _name, 
        string memory _symbol, 
        string memory _uri,
        IMintableERC721V2 _burnNFT,
        address _verifier
    ) NFTCoreV3(_name, _symbol, _uri, 3840) Verifier(_verifier) {
        require(_startAt > block.timestamp, "illegal startAt");
        startAt = _startAt;
        require(_finishAt > _startAt, "illegal startAt or finishAt");
        finishAt = _finishAt;
        burnNFT = _burnNFT;
        typeRanges.push(Range({
            startIndex: 1,
            endIndex: 0
        }));
        require(MAX_SUPPLY % TYPE_NUM == 0, "illegal TYPE_NUM with MAX_SUPPLY");
        uint typeNum = MAX_SUPPLY / TYPE_NUM;
        for (uint i = 1; i <= TYPE_NUM; i ++) {
            typeRanges.push(Range({
                startIndex: typeNum * (i - 1) + 1,
                endIndex: typeNum * i
            }));
        }
    }

    function setTimeInfo(uint _startAt, uint _finishAt) external onlyOwner {
        if (_startAt != 0) {
            require(_startAt > block.timestamp, "illegal startAt");
            startAt = _startAt;
        }
        if (_finishAt != 0) {
            require(_finishAt > startAt, "illegal startAt or finishAt");
            finishAt = _finishAt;
        }
    }

    modifier AlreadyBegin() {
        require(block.timestamp >= startAt, "active not begin");
        _;
    }
    
    modifier NotFinish() {
        require(block.timestamp <= finishAt, "active already finish");
        _;
    }

    function mintInternal(uint _type, uint _burnNftId) internal {
        require(_type > 0 && _type <= TYPE_NUM, "illegal type");
        burnNFT.safeTransferFrom(msg.sender, HOLE_ADDRESS, _burnNftId);
        uint nftId = typeRanges[_type].startIndex;
        require(nftId <= typeRanges[_type].endIndex, "already full");
        _mint(msg.sender, nftId);
        typeRanges[_type].startIndex = nftId + 1;
        emit Mint(burnNFT, _burnNftId, _type, nftId);
    }

    function mint(uint[] memory _types, uint[] memory _burnNftIds, uint8 _v, bytes32 _r, bytes32 _s) external AlreadyBegin NotFinish {
        require(_types.length == _burnNftIds.length && _types.length > 0);
        require(
            ecrecover(keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", keccak256(abi.encodePacked(address(this), msg.sender, _types, _burnNftIds)))), _v, _r, _s) == verifier,
            "verify failed"
        );
        for (uint i = 0; i < _types.length; i ++) {
            mintInternal(_types[i], _burnNftIds[i]);
        }
    }
}
// SPDX-License-Identifier: MIT

pragma solidity >=0.8.4;

import '@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol';
import '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import '@openzeppelin/contracts/security/Pausable.sol';
import '../core/SafeOwnable.sol';

interface ISwapPair {
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function getReserves() external view returns (uint112 _reserve0, uint112 _reserve1, uint32 _blockTimestampLast);
}

interface IWETH {
    function deposit() external payable;
    function withdraw(uint) external;
}

contract PuffRouter is SafeOwnable, Pausable {
    using SafeERC20 for IERC20;

    event NewSwapFee(uint oldValue, uint newValue);
    event NewSwapReceiver(address oldReceiver, address newReceiver);
    
    address public immutable factory;
    bytes32 public immutable pairInitCodeHash;
    uint256 public immutable fee;
    uint256 public immutable feeBase;
    address public immutable WETH;
    uint public swapFee;
    uint public constant MAX_SWAP_FEE = 5000;
    uint public constant PERCENT_BASE = 1e6;
    address public swapFeeReceiver;

    modifier ensure(uint deadline) {
        require(deadline >= block.timestamp, 'BabyRouter: EXPIRED');
        _;
    }

    constructor(address _factory, address _WETH, uint _swapFee, address _swapFeeReceiver, bytes32 _pairInitCodeHash, uint _fee, uint _feeBase) {
        factory = _factory;
        WETH = _WETH;
        _setSwapFee(_swapFee);
        _setSwapFeeReceiver(_swapFeeReceiver);
        pairInitCodeHash = _pairInitCodeHash;
        fee = _fee;
        feeBase = _feeBase;
    }

    receive() external payable {
        assert(msg.sender == WETH); 
    }

    function pause() internal virtual whenNotPaused {
        _pause();
    }

    function unpause() internal virtual whenPaused {
        _unpause();
    }

    function _setSwapFee(uint _swapFee) internal {
        require(_swapFee <= MAX_SWAP_FEE, "illegal swapFee");
        emit NewSwapFee(swapFee, _swapFee);
        swapFee = _swapFee;
    }

    function setSwapFee(uint _swapFee) public onlyOwner {
        _setSwapFee(_swapFee);
    }

    function _setSwapFeeReceiver(address _swapFeeReceiver) internal {
        require(_swapFeeReceiver != address(0), "illegal receiver");
        emit NewSwapReceiver(swapFeeReceiver, _swapFeeReceiver);
        swapFeeReceiver = _swapFeeReceiver;
    }

    function setSwapFeeReceiver(address _swapFeeReceiver) public onlyOwner {
        _setSwapFeeReceiver(_swapFeeReceiver);
    }

    function sortTokens(address tokenA, address tokenB) internal pure returns (address token0, address token1) {
        require(tokenA != tokenB, 'IDENTICAL_ADDRESSES');
        (token0, token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
        require(token0 != address(0), 'ZERO_ADDRESS');
    }

    function pairFor(address tokenA, address tokenB) internal view returns (address pair) {
        (address token0, address token1) = sortTokens(tokenA, tokenB);
        pair = address(uint160(uint(keccak256(abi.encodePacked(
                hex'ff',
                factory,
                keccak256(abi.encodePacked(token0, token1)),
                pairInitCodeHash
            )))));
    }

    function getReserves(address tokenA, address tokenB) internal view returns (uint reserveA, uint reserveB) {
        (address token0,) = sortTokens(tokenA, tokenB);
        (uint reserve0, uint reserve1,) = ISwapPair(pairFor(tokenA, tokenB)).getReserves();
        (reserveA, reserveB) = tokenA == token0 ? (reserve0, reserve1) : (reserve1, reserve0);
    }

    function quote(uint amountA, uint reserveA, uint reserveB) internal pure returns (uint amountB) {
        require(amountA > 0, 'INSUFFICIENT_AMOUNT');
        require(reserveA > 0 && reserveB > 0, 'INSUFFICIENT_LIQUIDITY');
        amountB = amountA * reserveB / reserveA;
    }

    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) internal view returns (uint amountOut) {
        require(amountIn > 0, 'INSUFFICIENT_INPUT_AMOUNT');
        require(reserveIn > 0 && reserveOut > 0, 'INSUFFICIENT_LIQUIDITY');
        uint amountInWithFee = amountIn * (feeBase - fee);
        uint numerator = amountInWithFee * reserveOut;
        uint denominator = reserveIn * feeBase + amountInWithFee;
        amountOut = numerator / denominator;
    }

    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) internal view returns (uint amountIn) {
        require(amountOut > 0, 'INSUFFICIENT_OUTPUT_AMOUNT');
        require(reserveIn > 0 && reserveOut > 0, 'INSUFFICIENT_LIQUIDITY');
        uint numerator = reserveIn * amountOut * feeBase;
        uint denominator = (reserveOut - amountOut) * (feeBase - fee);
        amountIn = (numerator / denominator) + 1;
    }

    function getAmountsOut(uint amountIn, address[] memory path) internal view returns (uint[] memory amounts) {
        require(path.length >= 2, 'INVALID_PATH');
        amounts = new uint[](path.length);
        amounts[0] = amountIn;
        for (uint i; i < path.length - 1; i++) {
            (uint reserveIn, uint reserveOut) = getReserves(path[i], path[i + 1]);
            amounts[i + 1] = getAmountOut(amounts[i], reserveIn, reserveOut);
        }
    }

    function getAmountsIn(uint amountOut, address[] memory path) internal view returns (uint[] memory amounts) {
        require(path.length >= 2, 'INVALID_PATH');
        amounts = new uint[](path.length);
        amounts[amounts.length - 1] = amountOut;
        for (uint i = path.length - 1; i > 0; i--) {
            (uint reserveIn, uint reserveOut) = getReserves(path[i - 1], path[i]);
            amounts[i - 1] = getAmountIn(amounts[i], reserveIn, reserveOut);
        }
    }

    function _swap(uint[] memory amounts, address[] memory path, address _to) internal virtual {
        for (uint i; i < path.length - 1; i++) {
            (address input, address output) = (path[i], path[i + 1]);
            (address token0,) = sortTokens(input, output);
            uint amountOut = amounts[i + 1];
            (uint amount0Out, uint amount1Out) = input == token0 ? (uint(0), amountOut) : (amountOut, uint(0));
            address to = i < path.length - 2 ? pairFor(output, path[i + 2]) : _to;
            ISwapPair(pairFor(input, output)).swap(
                amount0Out, amount1Out, to, new bytes(0)
            );
        }
    }

    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external ensure(deadline) returns (uint[] memory amounts) {
        uint payFee = amountIn * swapFee / PERCENT_BASE;
        IERC20(path[0]).safeTransferFrom(
            msg.sender, swapFeeReceiver, payFee
        );
        amountIn -= payFee;
        amounts = getAmountsOut(amountIn, path);
        require(amounts[amounts.length - 1] >= amountOutMin, 'INSUFFICIENT_OUTPUT_AMOUNT');
        IERC20(path[0]).safeTransferFrom(
            msg.sender, pairFor(path[0], path[1]), amounts[0]
        );
        _swap(amounts, path, to);
    }

    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external ensure(deadline) returns (uint[] memory amounts) {
        amounts = getAmountsIn(amountOut, path);
        require(amounts[0] <= amountInMax, 'EXCESSIVE_INPUT_AMOUNT');
        uint payFee = amounts[0] * swapFee / (PERCENT_BASE - swapFee);
        IERC20(path[0]).safeTransferFrom(
            msg.sender, swapFeeReceiver, payFee
        );
        IERC20(path[0]).safeTransferFrom(
            msg.sender, pairFor(path[0], path[1]), amounts[0]
        );
        _swap(amounts, path, to);
    }

    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        ensure(deadline)
        returns (uint[] memory amounts)
    {
        require(path[0] == WETH, 'INVALID_PATH');
        uint payFee = msg.value * swapFee / PERCENT_BASE;
        uint amountIn = msg.value - payFee;
        amounts = getAmountsOut(amountIn, path);
        require(amounts[amounts.length - 1] >= amountOutMin, 'INSUFFICIENT_OUTPUT_AMOUNT');
        IWETH(WETH).deposit{value: msg.value}();
        IERC20(WETH).safeTransfer(swapFeeReceiver, payFee);
        IERC20(WETH).safeTransfer(pairFor(path[0], path[1]), amounts[0]);
        _swap(amounts, path, to);
    }

    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address payable to, uint deadline)
        external
        ensure(deadline)
        returns (uint[] memory amounts)
    {
        require(path[path.length - 1] == WETH, 'INVALID_PATH');
        amounts = getAmountsIn(amountOut, path);
        require(amounts[0] <= amountInMax, 'EXCESSIVE_INPUT_AMOUNT');
        uint payFee = amounts[0] * swapFee / (PERCENT_BASE - swapFee);
        IERC20(path[0]).safeTransferFrom(
            msg.sender, swapFeeReceiver, payFee
        );
        IERC20(path[0]).safeTransferFrom(
            msg.sender, pairFor(path[0], path[1]), amounts[0]
        );
        _swap(amounts, path, address(this));
        IWETH(WETH).withdraw(amounts[amounts.length - 1]);
        to.transfer(amounts[amounts.length-1]);
    }

    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address payable to, uint deadline)
        external
        ensure(deadline)
        returns (uint[] memory amounts)
    {
        require(path[path.length - 1] == WETH, 'INVALID_PATH');
        uint payFee = amountIn * swapFee / PERCENT_BASE;
        IERC20(path[0]).safeTransferFrom(
            msg.sender, swapFeeReceiver, payFee
        );
        amountIn -= payFee;
        amounts = getAmountsOut(amountIn, path);
        require(amounts[amounts.length - 1] >= amountOutMin, 'INSUFFICIENT_OUTPUT_AMOUNT');
        IERC20(path[0]).safeTransferFrom(
            msg.sender, pairFor(path[0], path[1]), amounts[0]
        );
        _swap(amounts, path, address(this));
        IWETH(WETH).withdraw(amounts[amounts.length - 1]);
        to.transfer(amounts[amounts.length - 1]);
    }

    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        ensure(deadline)
        returns (uint[] memory amounts)
    {
        require(path[0] == WETH, 'INVALID_PATH');
        amounts = getAmountsIn(amountOut, path);
        uint payFee = amounts[0] * swapFee / (PERCENT_BASE - swapFee);
        require(amounts[0] + payFee <= msg.value, 'EXCESSIVE_INPUT_AMOUNT');
        IWETH(WETH).deposit{value: amounts[0] + payFee}();
        IERC20(WETH).safeTransfer(swapFeeReceiver, payFee);
        IERC20(WETH).safeTransfer(pairFor(path[0], path[1]), amounts[0]);
        _swap(amounts, path, to);
        if (msg.value > amounts[0] + payFee) payable(msg.sender).transfer(msg.value - amounts[0] - payFee);
    }
}
// SPDX-License-Identifier: MIT

pragma solidity >=0.8.4;

import '@openzeppelin/contracts/token/ERC20/extensions/ERC20Capped.sol';
import '../core/SafeOwnable.sol';

contract PuffGo is ERC20Capped, SafeOwnable {

    event MinterChanged(address indexed minter, uint maxAmount);

    uint256 public constant MAX_SUPPLY = 10 * 10 ** 8 * 10 ** 18;
    mapping(address => uint) public minters;

    constructor() ERC20Capped(MAX_SUPPLY) ERC20("Puffverse Governance Token", "PGT") {
    }

    function addMinter(address _minter, uint _maxAmount) public onlyOwner {
        require(_minter != address(0), "illegal minter");
        require(minters[_minter] == 0, "already minter");
        minters[_minter] = _maxAmount;
        emit MinterChanged(_minter, _maxAmount);
    }

    function delMinter(address _minter) public onlyOwner {
        require(_minter != address(0), "illegal minter");
        require(minters[_minter] > 0, "not minter");
        delete minters[_minter];
        emit MinterChanged(_minter, 0);
    }

    modifier onlyMinter(uint _amount) {
        require(minters[msg.sender] >= _amount, "caller is not minter or not enough");
        _;
    }

    function mint(address to, uint256 amount) external onlyMinter(amount) returns (uint) {
        if (amount > MAX_SUPPLY - totalSupply()) {
            return 0;
        }
        if (minters[msg.sender] < amount) {
            amount = minters[msg.sender];
        }
        minters[msg.sender] = minters[msg.sender] - amount;
        _mint(to, amount);
        return amount; 
    }
}
// SPDX-License-Identifier: MIT

pragma solidity >=0.8.4;

import '@openzeppelin/contracts/token/ERC1155/IERC1155Receiver.sol';
import '@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol';
import '@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol';
import '@openzeppelin/contracts/proxy/utils/Initializable.sol';
import '@openzeppelin/contracts/security/ReentrancyGuard.sol';
import '@openzeppelin/contracts/token/ERC1155/IERC1155.sol';
import '@openzeppelin/contracts/token/ERC721/IERC721.sol';
import '@openzeppelin/contracts/token/ERC20/IERC20.sol';

import '../core/SafeOwnable.sol';
import '../core/VerifierV2.sol';

import 'hardhat/console.sol';

contract Vault is SafeOwnable, Initializable, VerifierV2, IERC721Receiver, IERC1155Receiver, ReentrancyGuard {
    using SafeERC20 for IERC20;

    event SupportTokenChanged(address token, TokenType tokenType);
    event Deposit(uint orderId, address user, uint timestamp, TokenType tokenType, address token, uint tokenId, uint amount, uint totalAmount);
    event Withdraw(uint orderId, address user, uint timestamp, TokenType tokenType, address token, uint tokenId, uint amount, uint totalAmount);
    event RecoverWrongToken(TokenType tokenType, address token, uint tokenId, uint amount, address receiver);

    enum TokenType {
        NONE,
        NATIVE,
        ERC20,
        ERC721,
        ERC1155
    }
    
    uint orderId = 1;
    mapping(bytes32 => bool) public hashes;
    mapping(address => TokenType) public supportTokens;

    //AssetKey = keccak256(abi.encodePacked(user, token, tokenId)) and for NATIVE and ERC20 the tokenId is alway 0
    //TokenKey = keccak256(abi.encodePacked(token, tokenId)) and for NATIVE and ERC20 the tokenId is alway 0;
    mapping(bytes32 => uint) public userOrderId;        //every time the user deposit or withdraw, a new orderId will produced, and the old on will be useless
    mapping(bytes32 => uint) public userBalance;        //the balance of a asset user deposited into the vault
    mapping(bytes32 => uint) public tokenBalance;       //the total balance of a asset that all user deposited into the vault

    function initialize(address _owner, address _verifier) external initializer {
        _transferOwnership(_owner);
        _setVerifier(_verifier);
    }

    function setSupportToken(address _token, TokenType _type) external onlyOwner {
        supportTokens[_token] = _type;
        emit SupportTokenChanged(_token, _type);
    }

    struct DepositParam {
        address token;
        uint tokenId;
        uint amount;
    }

    function AssetKey(address user, DepositParam memory param) internal pure returns (bytes32, bytes32) {
        return (keccak256(abi.encodePacked(user, param.token, param.tokenId)), keccak256(abi.encodePacked(param.token, param.tokenId)));
    }

    function deposit(DepositParam memory param) external payable nonReentrant {
        TokenType tokenType = supportTokens[param.token];
        (bytes32 assetKey, bytes32 tokenKey) = AssetKey(msg.sender, param);
        if (tokenType == TokenType.NATIVE) {
            require(param.tokenId == 0, "illegal token or tokenId");
            require(msg.value == param.amount, "illegal amount");
            userBalance[assetKey] += param.amount;
        } else if (tokenType == TokenType.ERC20) {
            require(param.tokenId == 0, "illegal token or tokenId");
            IERC20(param.token).safeTransferFrom(msg.sender, address(this), param.amount);
            userBalance[assetKey] += param.amount;
        } else if (tokenType == TokenType.ERC721) {
            require(param.amount == 1, "illegal token or amount");
            IERC721(param.token).safeTransferFrom(msg.sender, address(this), param.tokenId, new bytes(0));
            userBalance[assetKey] = param.amount;
        } else if (tokenType == TokenType.ERC1155) {
            IERC1155(param.token).safeTransferFrom(msg.sender, address(this), param.tokenId, param.amount, new bytes(0));
            userBalance[assetKey] += param.amount;
        } else {
            revert("illegal token type");
        }
        tokenBalance[tokenKey] += param.amount;
        userOrderId[assetKey] = orderId;
        emit Deposit(orderId ++, msg.sender, block.timestamp, tokenType, param.token, param.tokenId, param.amount, userBalance[assetKey]);
    }

    struct WithdrawParam {
        uint id;
        address token;
        uint tokenId;
        uint amount;
        uint totalAmount;
        uint8 v;
        bytes32 r;
        bytes32 s;
    }

    function AssetKey(address user, WithdrawParam memory param) internal pure returns (bytes32, bytes32) {
        return (keccak256(abi.encodePacked(user, param.token, param.tokenId)), keccak256(abi.encodePacked(param.token, param.tokenId)));
    }

    function withdraw(WithdrawParam memory param) external nonReentrant {
        bytes32 hash = keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", keccak256(abi.encode(
            address(this), param.id, msg.sender, param.token, param.tokenId, param.amount, param.totalAmount
        ))));
        address signer = ecrecover(hash, param.v, param.r, param.s);
        require(!hashes[hash] && signer != address(0) && signer == verifier, "signature failed");
        hashes[hash] = true;
        TokenType tokenType = supportTokens[param.token];
        (bytes32 assetKey, bytes32 tokenKey) = AssetKey(msg.sender, param);
        require(userOrderId[assetKey] == param.id, "illegal id");
        uint currentBalance = userBalance[assetKey];
        if (tokenType == TokenType.NATIVE) {
            require(param.tokenId == 0, "illegal token or tokenId");
            if (param.totalAmount > currentBalance) {
                require(param.totalAmount - currentBalance <= address(this).balance - tokenBalance[tokenKey], "illegal totalAmount");
            }
            payable(msg.sender).transfer(param.amount);
            userBalance[assetKey] = param.totalAmount - param.amount;
            if (param.totalAmount > param.amount) {
                userOrderId[assetKey] = orderId;
                emit Deposit(orderId ++, msg.sender, block.timestamp, tokenType, param.token, param.tokenId, 0, param.totalAmount - param.amount);
            } else {
                delete userOrderId[assetKey];
                delete userBalance[assetKey];
            }
        } else if (tokenType == TokenType.ERC20) {
            require(param.tokenId == 0, "illegal token or tokenId");
            if (param.totalAmount > currentBalance) {
                require(param.totalAmount - currentBalance <= IERC20(param.token).balanceOf(address(this)) - tokenBalance[tokenKey], "illegal totalAmount");
            }
            IERC20(param.token).safeTransfer(msg.sender, param.amount);
            userBalance[assetKey] = param.totalAmount - param.amount;
            if (param.totalAmount > param.amount) {
                userOrderId[assetKey] = orderId;
                emit Deposit(orderId ++, msg.sender, block.timestamp, tokenType, param.token, param.tokenId, 0, param.totalAmount - param.amount);
            } else {
                delete userOrderId[assetKey];
                delete userBalance[assetKey];
            }
        } else if (tokenType == TokenType.ERC721) {
            require(param.amount == 1 && param.totalAmount == 1, "illegal token or amount");
            if (currentBalance == 0) {
                require(IERC721(param.token).ownerOf(param.tokenId) == address(this) && tokenBalance[tokenKey] == 0, "illeagl totalAmount"); 
            }
            IERC721(param.token).safeTransferFrom(address(this), msg.sender, param.tokenId, new bytes(0));
            delete userOrderId[assetKey];
            delete userBalance[assetKey];
        } else if (tokenType == TokenType.ERC1155) {
            if (param.totalAmount > currentBalance) {
                require(param.totalAmount - currentBalance <= IERC1155(param.token).balanceOf(address(this), param.tokenId) - tokenBalance[tokenKey], "illeagl totalAmount");
            }
            IERC1155(param.token).safeTransferFrom(address(this), msg.sender, param.tokenId, param.amount, new bytes(0));
            userBalance[assetKey] = param.totalAmount - param.amount;
            if (param.totalAmount > param.amount) {
                userOrderId[assetKey] = orderId;
                emit Deposit(orderId ++, msg.sender, block.timestamp, tokenType, param.token, param.tokenId, 0, param.totalAmount - param.amount);
            } else {
                delete userOrderId[assetKey];
                delete userBalance[assetKey];
            }
        } else {
            revert("illegal token type");
        }
        if (param.totalAmount >= currentBalance) {
            tokenBalance[tokenKey] = tokenBalance[tokenKey] + (param.totalAmount - currentBalance) - param.amount;
        } else {
            tokenBalance[tokenKey] = tokenBalance[tokenKey] - (currentBalance - param.totalAmount) - param.amount;
        }
        emit Withdraw(param.id, msg.sender, block.timestamp, tokenType, param.token, param.tokenId, param.amount, param.totalAmount);
    }

    function AssetKey(address user, address token, uint tokenId) internal pure returns (bytes32, bytes32) {
        return (keccak256(abi.encodePacked(user, token, tokenId)), keccak256(abi.encodePacked(token, tokenId)));
    }

    function recoverWrongToken(TokenType tokenType, address token, uint tokenId, uint amount, address payable receiver) external onlyOwner {
        (, bytes32 tokenKey) = AssetKey(msg.sender, token, tokenId);
        if (tokenType == TokenType.NATIVE) {
            uint remain = address(this).balance - tokenBalance[tokenKey];
            require(remain >= amount, "illegal amount"); 
            receiver.transfer(amount);
        } else if (tokenType == TokenType.ERC20) {
            uint remain = IERC20(token).balanceOf(address(this)) - tokenBalance[tokenKey];
            require(remain >= amount, "illegal amount"); 
            IERC20(token).safeTransfer(receiver, amount);
        } else if (tokenType == TokenType.ERC721) {
            require(amount == 1 && tokenBalance[tokenKey] == 0, "illegal amount");
            IERC721(token).safeTransferFrom(address(this), receiver, tokenId, new bytes(0));
        } else if (tokenType == TokenType.ERC1155) {
            uint remain = IERC1155(token).balanceOf(address(this), tokenId) - tokenBalance[tokenKey];
            require(remain >= amount, "illegal amount");
            IERC1155(token).safeTransferFrom(address(this), receiver, tokenId, amount, new bytes(0));
        } else {
            revert("illegal token type");
        }
        emit RecoverWrongToken(tokenType, token, tokenId, amount, receiver);
    }

    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external override pure returns (bytes4) {
        if (false) {
            operator;
            from;
            tokenId;
            data;
        }
        return 0x150b7a02;
    }

    function onERC1155Received(
        address operator,
        address from,
        uint256 id,
        uint256 value,
        bytes calldata data
    ) external override pure returns (bytes4) {
        if (false) {
            operator;
            from;
            id;
            value;
            data;
        }
        return 0xf23a6e61;
    }

    function onERC1155BatchReceived(
        address operator,
        address from,
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata data
    ) external override pure returns (bytes4) {
        if (false) {
            operator;
            from;
            ids;
            values;
            data;
        }
        return 0xbc197c81;
    }

    function supportsInterface(bytes4 interfaceId) external override pure returns (bool) {
        return
            interfaceId == type(IERC1155Receiver).interfaceId ||
            interfaceId == type(IERC721Receiver).interfaceId ||
            interfaceId == type(IERC165).interfaceId;
    }

    receive() external payable {}
}
// SPDX-License-Identifier: MIT

pragma solidity >=0.8.4;

import '@openzeppelin/contracts/token/ERC1155/IERC1155Receiver.sol';
import '@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol';
import '@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol';
import '@openzeppelin/contracts/proxy/utils/Initializable.sol';
import '@openzeppelin/contracts/security/ReentrancyGuard.sol';
import '@openzeppelin/contracts/token/ERC1155/IERC1155.sol';
import '@openzeppelin/contracts/token/ERC721/IERC721.sol';
import '@openzeppelin/contracts/token/ERC20/IERC20.sol';

import '../interfaces/IMintableERC721V4.sol';
import '../core/SafeOwnable.sol';
import '../core/VerifierV2.sol';
import '../core/Operatable.sol';

import 'hardhat/console.sol';

contract VaultV2 is SafeOwnable, Operatable, Initializable, IERC721Receiver, IERC1155Receiver, ReentrancyGuard {
    using SafeERC20 for IERC20;

    event SupportTokenChanged(address token, TokenType tokenType);
    event MintableNFTChanged(address token, bool available);
    event Deposit(address user, uint timestamp, TokenType tokenType, address token, uint tokenId, uint amount);
    event Withdraw(address user, uint timestamp, TokenType tokenType, address token, uint tokenId, uint amount);
    event RecoverWrongToken(TokenType tokenType, address token, uint tokenId, uint amount, address receiver);

    enum TokenType {
        NONE,
        NATIVE,
        ERC20,
        ERC721,
        ERC1155
    }
    
    mapping(address => TokenType) public supportTokens;
    mapping(address => bool) public mintableNFTs;

    function initialize(address _owner, address[] memory _operators) external initializer {
        _transferOwnership(_owner);
        for (uint i = 0; i < _operators.length; i ++) {
            _addOperator(_operators[i]);
        }
    }

    function setSupportToken(address _token, TokenType _type) external onlyOwner {
        supportTokens[_token] = _type;
        emit SupportTokenChanged(_token, _type);
    }

    function setMintableNFT(address _token, bool _available) external onlyOwner {
        if (_available) {
            require(supportTokens[_token] == TokenType.ERC721, "not support");
        }
        mintableNFTs[_token] = _available;
        emit MintableNFTChanged(_token, _available);
    }

    struct DepositParam {
        address token;
        uint tokenId;
        uint amount;
    }

    function deposit(DepositParam memory param) public payable nonReentrant {
        TokenType tokenType = supportTokens[param.token];
        if (tokenType == TokenType.NATIVE) {
            require(param.tokenId == 0, "illegal token or tokenId");
            require(msg.value >= param.amount, "illegal amount");
        } else if (tokenType == TokenType.ERC20) {
            require(param.tokenId == 0, "illegal token or tokenId");
            IERC20(param.token).safeTransferFrom(msg.sender, address(this), param.amount);
        } else if (tokenType == TokenType.ERC721) {
            require(param.amount == 1, "illegal token or amount");
            IERC721(param.token).safeTransferFrom(msg.sender, address(this), param.tokenId, new bytes(0));
        } else if (tokenType == TokenType.ERC1155) {
            IERC1155(param.token).safeTransferFrom(msg.sender, address(this), param.tokenId, param.amount, new bytes(0));
        } else {
            revert("illegal token type");
        }
        emit Deposit(msg.sender, block.timestamp, tokenType, param.token, param.tokenId, param.amount);
    }

    function depositAll(DepositParam[] memory param) external payable {
        uint totalValue = 0;
        for (uint i = 0; i < param.length; i ++) {
            if (supportTokens[param[i].token] == TokenType.NATIVE) {
                totalValue += param[i].amount;
            }
            deposit(param[i]);
        }
        require(msg.value == totalValue, "illegal value");
    }

    function withdraw(address _token, uint _tokenId, uint _amount, address _recipient) public onlyOperater nonReentrant {
        TokenType tokenType = supportTokens[_token];
        if (tokenType == TokenType.NATIVE) {
            require(_tokenId == 0, "illegal token or tokenId");
            payable(_recipient).transfer(_amount);
        } else if (tokenType == TokenType.ERC20) {
            require(_tokenId == 0, "illegal token or tokenId");
            IERC20(_token).safeTransfer(_recipient, _amount);
        } else if (tokenType == TokenType.ERC721) {
            require(_amount == 1, "illegal token or amount");
            if (mintableNFTs[_token] && !IMintableERC721V4(_token).exists(_tokenId)) {
                IMintableERC721V4(_token).mintById(_recipient, _tokenId);
            } else {
                IERC721(_token).safeTransferFrom(address(this), _recipient, _tokenId, new bytes(0));
            }
        } else if (tokenType == TokenType.ERC1155) {
            IERC1155(_token).safeTransferFrom(address(this), _recipient, _tokenId, _amount, new bytes(0));
        } else {
            revert("illegal token type");
        }
        emit Withdraw(_recipient, block.timestamp, tokenType, _token, _tokenId, _amount);
    }

    function withdrawAll(address[] memory _tokens, uint[] memory _tokenIds, uint[] memory _amounts, address[] memory _recipients) external onlyOperater {
        require(_tokens.length == _tokenIds.length && _tokenIds.length == _amounts.length && _amounts.length == _recipients.length, "illegal length");
        for (uint i = 0; i < _tokens.length; i ++) {
            withdraw(_tokens[i], _tokenIds[i], _amounts[i], _recipients[i]);
        }
    }

    function recoverWrongToken(TokenType tokenType, address token, uint tokenId, uint amount, address payable receiver) external onlyOwner {
        if (tokenType == TokenType.NATIVE) {
            receiver.transfer(amount);
        } else if (tokenType == TokenType.ERC20) {
            IERC20(token).safeTransfer(receiver, amount);
        } else if (tokenType == TokenType.ERC721) {
            IERC721(token).safeTransferFrom(address(this), receiver, tokenId, new bytes(0));
        } else if (tokenType == TokenType.ERC1155) {
            IERC1155(token).safeTransferFrom(address(this), receiver, tokenId, amount, new bytes(0));
        } else {
            revert("illegal token type");
        }
        emit RecoverWrongToken(tokenType, token, tokenId, amount, receiver);
    }

    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external override pure returns (bytes4) {
        if (false) {
            operator;
            from;
            tokenId;
            data;
        }
        return 0x150b7a02;
    }

    function onERC1155Received(
        address operator,
        address from,
        uint256 id,
        uint256 value,
        bytes calldata data
    ) external override pure returns (bytes4) {
        if (false) {
            operator;
            from;
            id;
            value;
            data;
        }
        return 0xf23a6e61;
    }

    function onERC1155BatchReceived(
        address operator,
        address from,
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata data
    ) external override pure returns (bytes4) {
        if (false) {
            operator;
            from;
            ids;
            values;
            data;
        }
        return 0xbc197c81;
    }

    function supportsInterface(bytes4 interfaceId) external override pure returns (bool) {
        return
            interfaceId == type(IERC1155Receiver).interfaceId ||
            interfaceId == type(IERC721Receiver).interfaceId ||
            interfaceId == type(IERC165).interfaceId;
    }

    receive() external payable {}
}
// SPDX-License-Identifier: MIT

pragma solidity >=0.8.4;
pragma abicoder v2;

import '../core/SafeOwnable.sol';

contract ConfigView is SafeOwnable {

    mapping(string => string[]) public configs;

    function addConfig(string memory _key, string[] memory _values) external onlyOwner {
        configs[_key] = _values;
    }

    function setConfig(string memory _key, uint _index, string memory _value) external onlyOwner {
        for (uint i = configs[_key].length; i <= _index; i ++) {
            configs[_key].push("");
        }
        configs[_key][_index] = _value;
    }

    function getConfig(string memory _key) external view returns (string[] memory) {
        return configs[_key];
    }

    function existConfig(string memory _key) external view returns (bool) {
        return configs[_key].length > 0;
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
