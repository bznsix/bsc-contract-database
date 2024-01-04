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
// OpenZeppelin Contracts (last updated v4.9.0) (token/ERC721/IERC721.sol)

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
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external;

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
    function safeTransferFrom(address from, address to, uint256 tokenId) external;

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
    function transferFrom(address from, address to, uint256 tokenId) external;

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
    function setApprovalForAll(address operator, bool approved) external;

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
pragma solidity >=0.5.0;

interface IUniswapV2Factory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
}
pragma solidity >=0.5.0;

interface IUniswapV2Pair {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address owner) external view returns (uint);

    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;

    event Mint(address indexed sender, uint amount0, uint amount1);
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint);
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function price0CumulativeLast() external view returns (uint);
    function price1CumulativeLast() external view returns (uint);
    function kLast() external view returns (uint);

    function mint(address to) external returns (uint liquidity);
    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;

    function initialize(address, address) external;
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
// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.0;

/*
 ██████╗ █████╗ ██╗   ██╗██╗        ██████╗ █████╗ ██╗     ██╗██████╗ ██╗████████╗██╗   ██╗
██╔════╝██╔══██╗██║   ██║██║       ██╔════╝██╔══██╗██║     ██║██╔══██╗██║╚══██╔══╝╚██╗ ██╔╝
╚█████╗ ██║  ██║██║   ██║██║       ╚█████╗ ██║  ██║██║     ██║██║  ██║██║   ██║    ╚████╔╝ 
 ╚═══██╗██║  ██║██║   ██║██║        ╚═══██╗██║  ██║██║     ██║██║  ██║██║   ██║     ╚██╔╝  
██████╔╝╚█████╔╝╚██████╔╝███████╗  ██████╔╝╚█████╔╝███████╗██║██████╔╝██║   ██║      ██║   
╚═════╝  ╚════╝  ╚═════╝ ╚══════╝  ╚═════╝  ╚════╝ ╚══════╝╚═╝╚═════╝ ╚═╝   ╚═╝      ╚═╝   

 * Twitter: https://twitter.com/SoulSolidity
 *  GitHub: https://github.com/SoulSolidity
 *     Web: https://SoulSolidity.com
 */

interface ISoulAccessManaged {
    function soulAccessRegistry() external view returns (address soulAccessRegistry);
}
// SPDX-License-Identifier: GPL-3.0-only
pragma solidity 0.8.19;

/*
 ██████╗ █████╗ ██╗   ██╗██╗        ██████╗ █████╗ ██╗     ██╗██████╗ ██╗████████╗██╗   ██╗
██╔════╝██╔══██╗██║   ██║██║       ██╔════╝██╔══██╗██║     ██║██╔══██╗██║╚══██╔══╝╚██╗ ██╔╝
╚█████╗ ██║  ██║██║   ██║██║       ╚█████╗ ██║  ██║██║     ██║██║  ██║██║   ██║    ╚████╔╝ 
 ╚═══██╗██║  ██║██║   ██║██║        ╚═══██╗██║  ██║██║     ██║██║  ██║██║   ██║     ╚██╔╝  
██████╔╝╚█████╔╝╚██████╔╝███████╗  ██████╔╝╚█████╔╝███████╗██║██████╔╝██║   ██║      ██║   
╚═════╝  ╚════╝  ╚═════╝ ╚══════╝  ╚═════╝  ╚════╝ ╚══════╝╚═╝╚═════╝ ╚═╝   ╚═╝      ╚═╝   

 * Twitter: https://twitter.com/SoulSolidity
 *  GitHub: https://github.com/SoulSolidity
 *     Web: https://SoulSolidity.com
 */

import {IAccessControl} from "@openzeppelin/contracts/access/IAccessControl.sol";
import {ISoulAccessManaged} from "./ISoulAccessManaged.sol";

contract SoulAccessManaged is ISoulAccessManaged {
    address public soulAccessRegistry;

    error SoulAccessUnauthorized();

    constructor(address _accessRegistryAddress) {
        soulAccessRegistry = _accessRegistryAddress;
    }

    /**
     * @dev Modifier to make a function callable only by accounts with a specific role in the SoulAccessRegistry.
     * @param roleName The name of the role to check.
     * Reverts with a SoulAccessUnauthorizedAccount error if the calling account does not have the role.
     */
    modifier onlyAccessRegistryRoleName(string memory roleName) {
        if (!_hasAccessRegistryRole(_getRoleHash(roleName), msg.sender)) {
            revert SoulAccessUnauthorized();
        }
        _;
    }

    /**
     * @dev Modifier to make a function callable only by accounts with a specific role in the SoulAccessRegistry.
     * @param role The hash of the role to check.
     * Reverts with a SoulAccessUnauthorizedAccount error if the calling account does not have the role.
     */
    modifier onlyAccessRegistryRole(bytes32 role) {
        if (!_hasAccessRegistryRole(role, msg.sender)) {
            revert SoulAccessUnauthorized();
        }
        _;
    }

    /**
     * @dev Generates a hash for a role name to be used within the SoulAccessRegistry.
     * @param role The name of the role.
     * @return bytes32 The hash of the role name.
     */
    function _getRoleHash(string memory role) internal pure returns (bytes32) {
        return keccak256(bytes(role));
    }

    /**
     * @dev Checks if an account has a specific role in the SoulAccessRegistry.
     * @param role The hash of the role to check.
     * @param account The address of the account to check.
     * @return bool True if the account has the role, false otherwise.
     */
    function _hasAccessRegistryRole(bytes32 role, address account) private view returns (bool) {
        return IAccessControl(soulAccessRegistry).hasRole(role, account);
    }
}
// SPDX-License-Identifier: UNLICENSED
// !! THIS FILE WAS AUTOGENERATED BY abi-to-sol v0.8.0. SEE SOURCE BELOW. !!
pragma solidity >=0.7.0 <0.9.0;
pragma experimental ABIEncoderV2;

interface ICustomBillRefillable {
    event BillClaimed(uint256 indexed billId, address indexed recipient, uint256 payout, uint256 remaining);
    event BillCreated(uint256 deposit, uint256 payout, uint256 expires, uint256 indexed billId);
    event BillInitialized(ICustomBill.BillTerms billTerms, uint256 lastDecay);
    event BillPriceChanged(uint256 internalPrice, uint256 debtRatio);
    event BillRefilled(address payoutToken, uint256 amountAdded);
    event ControlVariableAdjustment(uint256 initialBCV, uint256 newBCV, uint256 adjustment);
    event FeeToChanged(address indexed newFeeTo);
    event Initialized(uint8 version);
    event MaxTotalPayoutChanged(uint256 newMaxTotalPayout);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole);
    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);
    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);
    event SetAdjustment(uint256 currentBCV, uint256 increment, uint256 targetBCV, uint256 buffer);
    event SetFees(uint256[] fees, uint256[] tierCeilings);
    event SetPendingOwner(address indexed pendingOwner);
    event TermsSet(uint8 parameter, uint256 input);
    event UpdateClaimApproval(address indexed owner, address indexed approvedAccount, bool approved);

    function DAO() external view returns (address);

    function DEFAULT_ADMIN_ROLE() external view returns (bytes32);

    function MAX_FEE() external view returns (uint256);

    function REFILL_ROLE() external view returns (bytes32);

    function acceptOwnership() external;

    function adjustment()
        external
        view
        returns (uint256 rate, uint256 target, uint256 buffer, uint256 lastAdjustmentTimestamp);

    function allIssuedBillIds() external view returns (uint256[] memory);

    function batchClaim(uint256[] memory _billIds) external returns (uint256 payout);

    function batchRedeem(uint256[] memory _billIds) external returns (uint256 payout);

    function billInfo(
        uint256
    )
        external
        view
        returns (
            uint256 payout,
            uint256 payoutClaimed,
            uint256 vesting,
            uint256 vestingTerm,
            uint256 vestingStartTimestamp,
            uint256 lastClaimTimestamp,
            uint256 truePricePaid
        );

    function billNft() external view returns (address);

    function billPrice() external view returns (uint256 price_);

    function changeFeeTo(address _feeTo) external;

    function claim(uint256 _billId) external returns (uint256);

    function claimablePayout(uint256 _billId) external view returns (uint256 claimablePayout_);

    function currentDebt() external view returns (uint256);

    function currentFee() external view returns (uint256 currentFee_);

    function customTreasury() external view returns (address);

    function debtDecay() external view returns (uint256 decay_);

    function debtRatio() external view returns (uint256 debtRatio_);

    function deposit(uint256 _amount, uint256 _maxPrice, address _depositor) external returns (uint256);

    function feeInPayout() external view returns (bool);

    function feeTiers(uint256) external view returns (uint256 tierCeilings, uint256 fees);

    function feeTo() external view returns (address);

    function getBillIds(address user) external view returns (uint256[] memory);

    function getBillIdsInRange(address user, uint256 start, uint256 end) external view returns (uint256[] memory);

    function getBillInfo(uint256 billId) external view returns (ICustomBill.Bill memory);

    function getFeeTierLength() external view returns (uint256 tierLength_);

    function getMaxTotalPayout() external view returns (uint256);

    function getRoleAdmin(bytes32 role) external view returns (bytes32);

    function getRoleMember(bytes32 role, uint256 index) external view returns (address);

    function getRoleMemberCount(bytes32 role) external view returns (uint256);

    function grantRefillRole(address[] memory _billRefillers) external;

    function grantRole(bytes32 role, address account) external;

    function hasRole(bytes32 role, address account) external view returns (bool);

    function initialize(
        address _customTreasury,
        ICustomBill.BillCreationDetails memory _billCreationDetails,
        ICustomBill.BillTerms memory _billTerms,
        ICustomBill.BillAccounts memory _billAccounts,
        address[] memory _billRefillers
    ) external;

    function initialize(
        address _customTreasury,
        ICustomBill.BillCreationDetails memory _billCreationDetails,
        ICustomBill.BillTerms memory _billTerms,
        ICustomBill.BillAccounts memory _billAccounts
    ) external;

    function lastDecay() external view returns (uint256);

    function maxPayout() external view returns (uint256);

    function owner() external view returns (address);

    function payoutFor(uint256 _amount) external view returns (uint256 _payout, uint256 _fee);

    function payoutToken() external view returns (address);

    function pendingOwner() external view returns (address);

    function pendingPayout(uint256 _billId) external view returns (uint256 pendingPayout_);

    function pendingVesting(uint256 _billId) external view returns (uint256 pendingVesting_);

    function principalToken() external view returns (address);

    function redeem(uint256 _billId) external returns (uint256);

    function redeemerApproved(address, address) external view returns (bool);

    function refillPayoutToken(uint256 _refillAmount) external;

    function renounceOwnership() external;

    function renounceRole(bytes32 role, address account) external;

    function revokeRefillRole(address[] memory _billRefillers) external;

    function revokeRole(bytes32 role, address account) external;

    function setAdjustment(uint256 _rate, uint256 _target, uint256 _buffer) external;

    function setBillTerms(uint8 _parameter, uint256 _input) external;

    function setClaimApproval(address approvedAccount, bool approved) external;

    function setFeeTiers(uint256[] memory fees, uint256[] memory tierCeilings) external;

    function setMaxTotalPayout(uint256 _maxTotalPayout) external;

    function setPendingOwner(address newPendingOwner) external;

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

    function terms()
        external
        view
        returns (
            uint256 controlVariable,
            uint256 vestingTerm,
            uint256 minimumPrice,
            uint256 maxPayout,
            uint256 maxDebt,
            uint256 maxTotalPayout,
            uint256 initialDebt
        );

    function totalDebt() external view returns (uint256);

    function totalPayoutGiven() external view returns (uint256);

    function totalPrincipalBilled() external view returns (uint256);

    function transferOwnership(address) external view;

    function trueBillPrice() external view returns (uint256 price_);

    function userBillIds() external view returns (uint256[] memory);

    function vestedPayoutAtTime(uint256 _billId, uint256 _timestamp) external view returns (uint256 vestedPayout_);

    function vestingCurve() external view returns (address);

    function vestingPayout(uint256 _billId) external view returns (uint256 vestingPayout_);

    function vestingPeriod(uint256 _billId) external view returns (uint256 vestingStart_, uint256 vestingEnd_);
}

interface ICustomBill {
    struct BillTerms {
        uint256 controlVariable;
        uint256 vestingTerm;
        uint256 minimumPrice;
        uint256 maxPayout;
        uint256 maxDebt;
        uint256 maxTotalPayout;
        uint256 initialDebt;
    }

    struct Bill {
        uint256 payout;
        uint256 payoutClaimed;
        uint256 vesting;
        uint256 vestingTerm;
        uint256 vestingStartTimestamp;
        uint256 lastClaimTimestamp;
        uint256 truePricePaid;
    }

    struct BillCreationDetails {
        address payoutToken;
        address principalToken;
        address initialOwner;
        address vestingCurve;
        uint256[] tierCeilings;
        uint256[] fees;
        bool feeInPayout;
    }

    struct BillAccounts {
        address feeTo;
        address DAO;
        address billNft;
    }
}
// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

/*
 ██████╗ █████╗ ██╗   ██╗██╗        ██████╗ █████╗ ██╗     ██╗██████╗ ██╗████████╗██╗   ██╗
██╔════╝██╔══██╗██║   ██║██║       ██╔════╝██╔══██╗██║     ██║██╔══██╗██║╚══██╔══╝╚██╗ ██╔╝
╚█████╗ ██║  ██║██║   ██║██║       ╚█████╗ ██║  ██║██║     ██║██║  ██║██║   ██║    ╚████╔╝ 
 ╚═══██╗██║  ██║██║   ██║██║        ╚═══██╗██║  ██║██║     ██║██║  ██║██║   ██║     ╚██╔╝  
██████╔╝╚█████╔╝╚██████╔╝███████╗  ██████╔╝╚█████╔╝███████╗██║██████╔╝██║   ██║      ██║   
╚═════╝  ╚════╝  ╚═════╝ ╚══════╝  ╚═════╝  ╚════╝ ╚══════╝╚═╝╚═════╝ ╚═╝   ╚═╝      ╚═╝   

 * Twitter: https://twitter.com/SoulSolidity
 *  GitHub: https://github.com/SoulSolidity
 *     Web: https://SoulSolidity.com
 */

/// -----------------------------------------------------------------------
/// Package Imports (alphabetical)
/// -----------------------------------------------------------------------
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IUniswapV2Pair} from "@uniswap/v2-core/contracts/interfaces/IUniswapV2Pair.sol";
import {IUniswapV2Router02} from "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

/// -----------------------------------------------------------------------
/// Local Imports (alphabetical)
/// -----------------------------------------------------------------------
import {Constants} from "../../utils/Constants.sol";
import {ICustomBillRefillable} from "./lib/ICustomBillRefillable.sol";
import {ISoulFeeManager} from "../../fee-manager/ISoulFeeManager.sol";
import {SoulZap_Ext_BondNftWhitelist} from "./SoulZap_Ext_BondNftWhitelist.sol";
import {SoulZap_UniV2} from "../../SoulZap_UniV2.sol";

/**
 * @title SoulZap_Ext_ApeBond
 * @dev This contract extends the SoulZap_UniV2 contract with additional functionality for ApeBond.
 * @author Soul Solidity - Contact for mainnet licensing until 730 days after first deployment transaction with matching bytecode.
 * Otherwise feel free to experiment locally or on testnets.
 * @notice Do not use this contract for any tokens that do not have a standard ERC20 implementation.
 */
abstract contract SoulZap_Ext_ApeBond is SoulZap_Ext_BondNftWhitelist, SoulZap_UniV2 {
    using SafeERC20 for IERC20;

    /// -----------------------------------------------------------------------
    /// Events
    /// -----------------------------------------------------------------------

    event ZapBond(ZapParams zapParams, ICustomBillRefillable bond, uint256 maxPrice);

    /// -----------------------------------------------------------------------
    /// External Functions
    /// -----------------------------------------------------------------------

    /// @notice Zap single token to ApeBond
    /// @param zapParams ISoulZap.ZapParams
    /// @param bond Treasury bond address
    /// @param maxPrice Max price of treasury bond
    function zapBond(
        ZapParams memory zapParams,
        SwapPath memory feeSwapPath,
        ICustomBillRefillable bond,
        uint256 maxPrice
    ) external payable nonReentrant whenNotPaused verifyMsgValueAndWrap(zapParams.tokenIn, zapParams.amountIn) {
        if (address(zapParams.tokenIn) == address(Constants.NATIVE_ADDRESS)) {
            _zapBond(zapParams, feeSwapPath, bond, maxPrice);
        } else {
            uint256 balanceBefore = _getBalance(zapParams.tokenIn);
            zapParams.tokenIn.safeTransferFrom(msg.sender, address(this), zapParams.amountIn);
            zapParams.amountIn = _getBalance(zapParams.tokenIn) - balanceBefore;
            _zapBond(zapParams, feeSwapPath, bond, maxPrice);
        }
    }

    /// -----------------------------------------------------------------------
    /// Private Functions
    /// -----------------------------------------------------------------------

    function _zapBond(
        ZapParams memory zapParams,
        SwapPath memory feeSwapPath,
        ICustomBillRefillable bond,
        uint256 maxPrice
    ) private {
        // Verify inputs
        require(zapParams.amountIn > 0, "SoulZap: amountIn must be > 0");
        require(zapParams.to != address(0), "SoulZap: Can't zap to null address");
        require(zapParams.liquidityPath.lpRouter != address(0), "SoulZap: lp router can not be address(0)");
        require(zapParams.token0 != address(0), "SoulZap: token0 can not be address(0)");
        require(zapParams.token1 != address(0), "SoulZap: token1 can not be address(0)");

        IUniswapV2Pair bondPrincipalToken = IUniswapV2Pair(bond.principalToken());
        bool skipFee = isBondNftWhitelisted(bond);

        //Check if bond principal token is single token or lp
        bool isSingleTokenBond = true;
        try IUniswapV2Pair(bondPrincipalToken).token0() returns (address /*_token0*/) {
            isSingleTokenBond = false;
        } catch (bytes memory) {}

        address to;
        if (isSingleTokenBond) {
            SwapParams memory swapParams = SwapParams({
                tokenIn: zapParams.tokenIn,
                amountIn: zapParams.amountIn,
                tokenOut: zapParams.token0,
                path: zapParams.path0,
                to: zapParams.to,
                deadline: zapParams.deadline
            });
            require(swapParams.tokenOut == address(bondPrincipalToken), "ApeBond: Wrong token for Bond");
            to = swapParams.to;
            swapParams.to = address(this);
            _swap(swapParams, feeSwapPath, !skipFee);
        } else {
            require(
                (zapParams.token0 == bondPrincipalToken.token0() && zapParams.token1 == bondPrincipalToken.token1()) ||
                    (zapParams.token1 == bondPrincipalToken.token0() &&
                        zapParams.token0 == bondPrincipalToken.token1()),
                "ApeBond: Wrong LP bondPrincipalToken for Bond"
            );
            to = zapParams.to;
            zapParams.to = address(this);
            _zap(zapParams, feeSwapPath, !skipFee);
        }

        uint256 balance = bondPrincipalToken.balanceOf(address(this));
        IERC20(address(bondPrincipalToken)).forceApprove(address(bond), balance);
        bond.deposit(balance, maxPrice, to);
        IERC20(address(bondPrincipalToken)).forceApprove(address(bond), 0);

        emit ZapBond(zapParams, bond, maxPrice);
    }
}
// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

/*
 ██████╗ █████╗ ██╗   ██╗██╗        ██████╗ █████╗ ██╗     ██╗██████╗ ██╗████████╗██╗   ██╗
██╔════╝██╔══██╗██║   ██║██║       ██╔════╝██╔══██╗██║     ██║██╔══██╗██║╚══██╔══╝╚██╗ ██╔╝
╚█████╗ ██║  ██║██║   ██║██║       ╚█████╗ ██║  ██║██║     ██║██║  ██║██║   ██║    ╚████╔╝ 
 ╚═══██╗██║  ██║██║   ██║██║        ╚═══██╗██║  ██║██║     ██║██║  ██║██║   ██║     ╚██╔╝  
██████╔╝╚█████╔╝╚██████╔╝███████╗  ██████╔╝╚█████╔╝███████╗██║██████╔╝██║   ██║      ██║   
╚═════╝  ╚════╝  ╚═════╝ ╚══════╝  ╚═════╝  ╚════╝ ╚══════╝╚═╝╚═════╝ ╚═╝   ╚═╝      ╚═╝   

 * Twitter: https://twitter.com/SoulSolidity
 *  GitHub: https://github.com/SoulSolidity
 *     Web: https://SoulSolidity.com
 */

/// -----------------------------------------------------------------------
/// Package Imports (alphabetical)
/// -----------------------------------------------------------------------
import {EnumerableSet} from "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

/// -----------------------------------------------------------------------
/// Local Imports (alphabetical)
/// -----------------------------------------------------------------------
import {ICustomBillRefillable} from "./lib/ICustomBillRefillable.sol";
import {SoulAccessManaged} from "../../access/SoulAccessManaged.sol";

/// @title SoulZap_Ext_BondNftWhitelist
/// @notice This contract extension requires specific role setup to manage the whitelist of Bond NFTs.
/// The roles are managed through the SoulAccessManaged contract and are critical for the
/// security and proper administration of the whitelist functionality.
abstract contract SoulZap_Ext_BondNftWhitelist is SoulAccessManaged {
    using EnumerableSet for EnumerableSet.AddressSet;

    EnumerableSet.AddressSet private _whitelistedBondNfts;

    event BondNftWhitelisted(address indexed bondNft, bool whitelisted);

    /// @notice Add or remove a bondNft from the whitelist
    /// @param _bondNft The address of the bondNft to be added or removed
    /// @param _isWhitelisted True to add the bondNft to the whitelist, false to remove it
    function setBondNftWhitelist(
        address _bondNft,
        bool _isWhitelisted
    ) external onlyAccessRegistryRoleName("SOUL_ZAP_ADMIN_ROLE") {
        if (_isWhitelisted) {
            require(_whitelistedBondNfts.add(_bondNft), "BondNft already whitelisted");
            emit BondNftWhitelisted(_bondNft, true);
        } else {
            require(_whitelistedBondNfts.remove(_bondNft), "BondNft not whitelisted");
            emit BondNftWhitelisted(_bondNft, false);
        }
    }

    /// @notice Check if a bondNft is whitelisted
    /// @param _bond The bondNft to check
    /// @return True if the bondNft is whitelisted, false otherwise
    function isBondNftWhitelisted(ICustomBillRefillable _bond) public view returns (bool) {
        return _whitelistedBondNfts.contains(_bond.billNft());
    }

    /// @notice Get the count of whitelisted bondNfts
    /// @return The number of whitelisted bondNfts
    function getWhitelistedBondNftCount() public view returns (uint256) {
        return _whitelistedBondNfts.length();
    }

    /// @notice Get a whitelisted bondNft by index
    /// @param _index The index of the whitelisted bondNft
    /// @return The address of the whitelisted bondNft at the given index
    function getWhitelistedBondNftAtIndex(uint256 _index) public view returns (address) {
        require(_index < _whitelistedBondNfts.length(), "Index out of bounds");
        return _whitelistedBondNfts.at(_index);
    }
}
// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

/*
 ██████╗ █████╗ ██╗   ██╗██╗        ██████╗ █████╗ ██╗     ██╗██████╗ ██╗████████╗██╗   ██╗
██╔════╝██╔══██╗██║   ██║██║       ██╔════╝██╔══██╗██║     ██║██╔══██╗██║╚══██╔══╝╚██╗ ██╔╝
╚█████╗ ██║  ██║██║   ██║██║       ╚█████╗ ██║  ██║██║     ██║██║  ██║██║   ██║    ╚████╔╝ 
 ╚═══██╗██║  ██║██║   ██║██║        ╚═══██╗██║  ██║██║     ██║██║  ██║██║   ██║     ╚██╔╝  
██████╔╝╚█████╔╝╚██████╔╝███████╗  ██████╔╝╚█████╔╝███████╗██║██████╔╝██║   ██║      ██║   
╚═════╝  ╚════╝  ╚═════╝ ╚══════╝  ╚═════╝  ╚════╝ ╚══════╝╚═╝╚═════╝ ╚═╝   ╚═╝      ╚═╝   

 * Twitter: https://twitter.com/SoulSolidity
 *  GitHub: https://github.com/SoulSolidity
 *     Web: https://SoulSolidity.com
 */

/**
 * @title SoulFeeManager_Interface
 * @dev This contract is an interface for the SoulFeeManager. It includes a function for getting the fee based on epoch volume.
 * @author Soul Solidity - Contact for mainnet licensing until 730 days after first deployment transaction with matching bytecode.
 * Otherwise feel free to experiment locally or on testnets.
 */
interface ISoulFeeManager {
    function isSoulFeeManager() external view returns (bool);

    function FEE_DENOMINATOR() external view returns (uint256 denominator);

    function getFeeInfo(
        uint256 _volume
    )
        external
        view
        returns (
            address[] memory feeTokens,
            uint256 currentFeePercentage,
            uint256 feeDenominator,
            address feeCollector
        );

    function getFee(uint256 epochVolume) external view returns (uint256 fee);

    function getFeeCollector() external view returns (address fee);

    function getFeeTokensLength() external view returns (uint256 length);

    function getFeeTokens() external view returns (address[] memory tokens);

    function getFeeToken(uint256 index) external view returns (address token);

    function isFeeToken(address _token) external view returns (bool valid);
}
// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.19;

/*
 ██████╗ █████╗ ██╗   ██╗██╗        ██████╗ █████╗ ██╗     ██╗██████╗ ██╗████████╗██╗   ██╗
██╔════╝██╔══██╗██║   ██║██║       ██╔════╝██╔══██╗██║     ██║██╔══██╗██║╚══██╔══╝╚██╗ ██╔╝
╚█████╗ ██║  ██║██║   ██║██║       ╚█████╗ ██║  ██║██║     ██║██║  ██║██║   ██║    ╚████╔╝ 
 ╚═══██╗██║  ██║██║   ██║██║        ╚═══██╗██║  ██║██║     ██║██║  ██║██║   ██║     ╚██╔╝  
██████╔╝╚█████╔╝╚██████╔╝███████╗  ██████╔╝╚█████╔╝███████╗██║██████╔╝██║   ██║      ██║   
╚═════╝  ╚════╝  ╚═════╝ ╚══════╝  ╚═════╝  ╚════╝ ╚══════╝╚═╝╚═════╝ ╚═╝   ╚═╝      ╚═╝   

 * Twitter: https://twitter.com/SoulSolidity
 *  GitHub: https://github.com/SoulSolidity
 *     Web: https://SoulSolidity.com
 */

// External package imports
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {IUniswapV2Router02} from "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";

// Internal route directory imports
import {IWETH} from "../lib/IWETH.sol";
import {ISoulFeeManager} from "../fee-manager/ISoulFeeManager.sol";
import {SoulZap_UniV2} from "../SoulZap_UniV2.sol";
import {SoulZap_Ext_ApeBond} from "../extensions/ApeBond/SoulZap_Ext_ApeBond.sol";

/**
 * @title SoulZap_UniV2_Extended_V1
 * @dev This contract is an implementation of ISoulZap interface. It includes functionalities for zapping into
 * UniswapV2 type liquidity pools.
 * @notice This contract has the following features:
 * 1. UniswapV2 Zap In
 * 2. Deposit into ApeBond, Bond contracts.
 * @author Soul Solidity - Contact for mainnet licensing until 730 days after first deployment transaction with matching bytecode.
 * Otherwise feel free to experiment locally or on testnets.
 */
contract SoulZap_UniV2_Extended_V1 is SoulZap_UniV2, SoulZap_Ext_ApeBond {
    constructor(
        address _accessRegistry,
        IWETH _wnative,
        ISoulFeeManager _soulFeeManager,
        /// @dev Set to zero to start epoch tracking immediately
        uint256 _epochStartTime
    ) SoulZap_UniV2(_accessRegistry, _wnative, _soulFeeManager, _epochStartTime) SoulZap_Ext_ApeBond() {}
}
// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.0;

/*
 ██████╗ █████╗ ██╗   ██╗██╗        ██████╗ █████╗ ██╗     ██╗██████╗ ██╗████████╗██╗   ██╗
██╔════╝██╔══██╗██║   ██║██║       ██╔════╝██╔══██╗██║     ██║██╔══██╗██║╚══██╔══╝╚██╗ ██╔╝
╚█████╗ ██║  ██║██║   ██║██║       ╚█████╗ ██║  ██║██║     ██║██║  ██║██║   ██║    ╚████╔╝ 
 ╚═══██╗██║  ██║██║   ██║██║        ╚═══██╗██║  ██║██║     ██║██║  ██║██║   ██║     ╚██╔╝  
██████╔╝╚█████╔╝╚██████╔╝███████╗  ██████╔╝╚█████╔╝███████╗██║██████╔╝██║   ██║      ██║   
╚═════╝  ╚════╝  ╚═════╝ ╚══════╝  ╚═════╝  ╚════╝ ╚══════╝╚═╝╚═════╝ ╚═╝   ╚═╝      ╚═╝   

 * Twitter: https://twitter.com/SoulSolidity
 *  GitHub: https://github.com/SoulSolidity
 *     Web: https://SoulSolidity.com
 */

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {ISoulAccessManaged} from "./access/ISoulAccessManaged.sol";
import {ISoulFeeManager} from "./fee-manager/ISoulFeeManager.sol";
import {ITransferHelper} from "./utils/ITransferHelper.sol";
import {IEpochVolumeTracker} from "./utils/IEpochVolumeTracker.sol";

interface ISoulZap_UniV2 is ISoulAccessManaged, ITransferHelper, IEpochVolumeTracker {
    /// -----------------------------------------------------------------------
    /// Swap Path
    /// -----------------------------------------------------------------------

    enum SwapType {
        V2
    }

    struct SwapPath {
        address swapRouter;
        SwapType swapType;
        address[] path;
        uint256 amountOut;
        uint256 amountOutMin;
    }

    //// -----------------------------------------------------------------------
    /// Liquidity Path
    /// -----------------------------------------------------------------------

    enum LPType {
        V2
    }

    struct LiquidityPath {
        address lpRouter;
        LPType lpType;
        uint256 amountAMin;
        uint256 amountBMin;
        uint256 lpAmount;
    }

    /// -----------------------------------------------------------------------
    /// Swap Params
    /// -----------------------------------------------------------------------

    struct SwapParams {
        IERC20 tokenIn;
        uint256 amountIn;
        address tokenOut;
        SwapPath path;
        address to;
        uint256 deadline;
    }

    /// -----------------------------------------------------------------------
    /// Zap Params
    /// -----------------------------------------------------------------------

    struct ZapParams {
        IERC20 tokenIn;
        uint256 amountIn;
        address token0;
        address token1;
        SwapPath path0;
        SwapPath path1;
        LiquidityPath liquidityPath;
        address to;
        uint256 deadline;
    }

    /// -----------------------------------------------------------------------
    /// Storage Variables
    /// -----------------------------------------------------------------------

    function soulFeeManager() external view returns (ISoulFeeManager);

    /// -----------------------------------------------------------------------
    /// Functions
    /// -----------------------------------------------------------------------

    function swap(SwapParams memory swapParams, SwapPath memory feeSwapPath) external payable;

    function zap(ZapParams memory zapParams, SwapPath memory feeSwapPath) external payable;

    /// -----------------------------------------------------------------------
    /// Fee Management
    /// -----------------------------------------------------------------------

    function isFeeToken(address _token) external view returns (bool valid);

    function getFeeInfo()
        external
        view
        returns (
            address[] memory feeTokens,
            uint256 currentFeePercentage,
            uint256 feeDenominator,
            address feeCollector
        );
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IWETH is IERC20 {
    function deposit() external payable;

    function withdraw(uint256) external;
}
// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

/*
 ██████╗ █████╗ ██╗   ██╗██╗        ██████╗ █████╗ ██╗     ██╗██████╗ ██╗████████╗██╗   ██╗
██╔════╝██╔══██╗██║   ██║██║       ██╔════╝██╔══██╗██║     ██║██╔══██╗██║╚══██╔══╝╚██╗ ██╔╝
╚█████╗ ██║  ██║██║   ██║██║       ╚█████╗ ██║  ██║██║     ██║██║  ██║██║   ██║    ╚████╔╝ 
 ╚═══██╗██║  ██║██║   ██║██║        ╚═══██╗██║  ██║██║     ██║██║  ██║██║   ██║     ╚██╔╝  
██████╔╝╚█████╔╝╚██████╔╝███████╗  ██████╔╝╚█████╔╝███████╗██║██████╔╝██║   ██║      ██║   
╚═════╝  ╚════╝  ╚═════╝ ╚══════╝  ╚═════╝  ╚════╝ ╚══════╝╚═╝╚═════╝ ╚═╝   ╚═╝      ╚═╝   

 * Twitter: https://twitter.com/SoulSolidity
 *  GitHub: https://github.com/SoulSolidity
 *     Web: https://SoulSolidity.com
 */

/// -----------------------------------------------------------------------
/// Package Imports
/// -----------------------------------------------------------------------
import {EnumerableSet} from "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

/// -----------------------------------------------------------------------
/// Local Imports
/// -----------------------------------------------------------------------
import {SoulAccessManaged} from "./access/SoulAccessManaged.sol";

/// @title SoulZap_UniV2_Whitelist
/// @notice This contract extension requires specific role setup to manage the whitelist of Bond NFTs.
/// The roles are managed through the SoulAccessManaged contract and are critical for the
/// security and proper administration of the whitelist functionality.
abstract contract SoulZap_UniV2_Whitelist is SoulAccessManaged {
    using EnumerableSet for EnumerableSet.AddressSet;

    EnumerableSet.AddressSet private _whitelistedRouters;

    event RouterWhitelisted(address indexed router, bool whitelisted);

    /// @notice Add or remove a router from the whitelist
    /// @dev This function allows adding or removing a router from the whitelist.
    /// @param _router The address of the router to be added or removed
    /// @param _isWhitelisted True to add the router to the whitelist, false to remove it
    function setRouterWhitelist(
        address _router,
        bool _isWhitelisted
    ) external onlyAccessRegistryRoleName("SOUL_ZAP_ADMIN_ROLE") {
        if (_isWhitelisted) {
            require(_whitelistedRouters.add(_router), "Router already whitelisted");
            emit RouterWhitelisted(_router, true);
        } else {
            require(_whitelistedRouters.remove(_router), "Router not whitelisted");
            emit RouterWhitelisted(_router, false);
        }
    }

    /// @notice Check if a router is whitelisted
    /// @dev This function checks if a router is whitelisted.
    /// @param _router The address of the router to check
    /// @return true if the router is whitelisted, false otherwise
    function isRouterWhitelisted(address _router) public view returns (bool) {
        return _whitelistedRouters.contains(_router);
    }

    /// @notice Get the count of whitelisted routers
    /// @dev This function returns the count of whitelisted routers.
    /// @return the count of whitelisted routers
    function getWhitelistedRouterCount() public view returns (uint256) {
        return _whitelistedRouters.length();
    }

    /// @notice Get the whitelisted router at a specific index
    /// @dev This function returns the whitelisted router at the specified index.
    /// @param _index The index of the whitelisted router to retrieve
    /// @return the address of the whitelisted router at the specified index
    function getWhitelistedRouterAtIndex(uint256 _index) public view returns (address) {
        require(_index < _whitelistedRouters.length(), "Index out of bounds");
        return _whitelistedRouters.at(_index);
    }
}
// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.19;

/*
 ██████╗ █████╗ ██╗   ██╗██╗        ██████╗ █████╗ ██╗     ██╗██████╗ ██╗████████╗██╗   ██╗
██╔════╝██╔══██╗██║   ██║██║       ██╔════╝██╔══██╗██║     ██║██╔══██╗██║╚══██╔══╝╚██╗ ██╔╝
╚█████╗ ██║  ██║██║   ██║██║       ╚█████╗ ██║  ██║██║     ██║██║  ██║██║   ██║    ╚████╔╝ 
 ╚═══██╗██║  ██║██║   ██║██║        ╚═══██╗██║  ██║██║     ██║██║  ██║██║   ██║     ╚██╔╝  
██████╔╝╚█████╔╝╚██████╔╝███████╗  ██████╔╝╚█████╔╝███████╗██║██████╔╝██║   ██║      ██║   
╚═════╝  ╚════╝  ╚═════╝ ╚══════╝  ╚═════╝  ╚════╝ ╚══════╝╚═╝╚═════╝ ╚═╝   ╚═╝      ╚═╝   

 * Twitter: https://twitter.com/SoulSolidity
 *  GitHub: https://github.com/SoulSolidity
 *     Web: https://SoulSolidity.com
 */

/// -----------------------------------------------------------------------
/// Package Imports (alphabetical)
/// -----------------------------------------------------------------------

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import {IUniswapV2Factory} from "@uniswap/v2-core/contracts/interfaces/IUniswapV2Factory.sol";
import {IUniswapV2Pair} from "@uniswap/v2-core/contracts/interfaces/IUniswapV2Pair.sol";
import {IUniswapV2Router02} from "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";
import {Pausable} from "@openzeppelin/contracts/security/Pausable.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

/// -----------------------------------------------------------------------
/// Internal Imports (alphabetical)
/// -----------------------------------------------------------------------
import {Constants} from "./utils/Constants.sol";
import {IWETH} from "./lib/IWETH.sol";
import {EpochVolumeTracker} from "./utils/EpochVolumeTracker.sol";
import {ISoulFeeManager} from "./fee-manager/ISoulFeeManager.sol";
import {ISoulZap_UniV2} from "./ISoulZap_UniV2.sol";
import {SoulAccessManaged} from "./access/SoulAccessManaged.sol";
import {SoulZap_UniV2_Whitelist} from "./SoulZap_UniV2_Whitelist.sol";
import {TransferHelper} from "./utils/TransferHelper.sol";
import {TokenHelper} from "./utils/TokenHelper.sol";
import {LocalVarsLib} from "./utils/LocalVarsLib.sol";
import {Sweeper} from "./utils/Sweeper.sol";

/*
/// @dev The receive method is used as a fallback function in a contract
/// and is called when ether is sent to a contract with no calldata.

*/
/**
 * @title SoulZap_UniV2
 * @notice This contract includes functionalities for zapping in and out of UniswapV2 type liquidity pools.
 * @dev Do not use this contract for any tokens that do not have a standard ERC20 implementation.
 * @author Soul Solidity - Contact for mainnet licensing until 730 days after first deployment
 *   transaction with matching bytecode.
 * Otherwise feel free to experiment locally or on testnets.
 */
contract SoulZap_UniV2 is
    ISoulZap_UniV2,
    SoulAccessManaged,
    SoulZap_UniV2_Whitelist,
    EpochVolumeTracker,
    Initializable,
    Pausable,
    ReentrancyGuard,
    TransferHelper,
    Sweeper
{
    using SafeERC20 for IERC20;

    /// -----------------------------------------------------------------------
    /// Storage variables
    /// -----------------------------------------------------------------------

    ISoulFeeManager public soulFeeManager;

    bytes32 public SOUL_ZAP_ADMIN_ROLE = _getRoleHash("SOUL_ZAP_ADMIN_ROLE");
    bytes32 public SOUL_ZAP_PAUSER_ROLE = _getRoleHash("SOUL_ZAP_PAUSER_ROLE");

    /// -----------------------------------------------------------------------
    /// Events
    /// -----------------------------------------------------------------------

    event Swap(SwapParams swapParams);
    event Zap(ZapParams zapParams);

    /// -----------------------------------------------------------------------
    /// Constructor
    /// -----------------------------------------------------------------------

    constructor(
        address _accessRegistry,
        IWETH _wnative,
        ISoulFeeManager _soulFeeManager,
        /// @dev Set to zero to start epoch tracking immediately
        uint256 _epochStartTime
    )
        SoulAccessManaged(_accessRegistry)
        EpochVolumeTracker(_epochStartTime, 0)
        TransferHelper(_wnative)
        Sweeper(new address[](0), true, SOUL_ZAP_ADMIN_ROLE)
    {
        require(_soulFeeManager.isSoulFeeManager(), "SoulZap: soulFeeManager is not ISoulFeeManager");
        soulFeeManager = _soulFeeManager;
    }

    /// @dev The receive method is used as a fallback function in a contract
    /// and is called when ether is sent to a contract with no calldata.
    receive() external payable {
        require(msg.sender == address(WNATIVE), "SoulZap: Only receive from WNATIVE");
    }

    /**
     * @dev This modifier checks if the transaction includes Ether (msg.value > 0).
     * If it does, it ensures that the input token is Wrapped Native (WNATIVE) and the input amount is 0.
     * It then wraps the Ether into WNATIVE and returns the amount of WNATIVE.
     *
     * @param _inputToken The token that the user wants to use for the transaction.
     * @param _inputAmount The amount of the token that the user wants to use for the transaction.
     */
    modifier verifyMsgValueAndWrap(IERC20 _inputToken, uint256 _inputAmount) {
        if (address(_inputToken) == address(Constants.NATIVE_ADDRESS)) {
            (, uint256 wrappedAmount) = _wrapNative();
            require(_inputAmount == wrappedAmount, "SoulZap: amountIn not equal to wrappedAmount");
        } else {
            require(msg.value == 0, "SoulZap: msg.value should be 0");
        }
        _;
    }

    /// -----------------------------------------------------------------------
    /// Pausing
    /// -----------------------------------------------------------------------

    /// @notice Pauses the contract functionality.
    function pause() external onlyAccessRegistryRole(SOUL_ZAP_PAUSER_ROLE) {
        _pause();
    }

    /// @notice Unpauses the contract functionality.
    /// @dev This operation should only be performed by an admin role as it can be a critical operation.
    function unpause() external onlyAccessRegistryRole(SOUL_ZAP_ADMIN_ROLE) {
        _unpause();
    }

    /// -----------------------------------------------------------------------
    /// Swap Functions
    /// -----------------------------------------------------------------------

    /// @notice Zap single token to LP
    /// @param swapParams all parameters for zap
    /// @param feeSwapPath swap path for protocol fee
    function swap(
        SwapParams memory swapParams,
        SwapPath memory feeSwapPath
    )
        external
        payable
        override
        nonReentrant
        whenNotPaused
        verifyMsgValueAndWrap(swapParams.tokenIn, swapParams.amountIn)
    {
        if (address(swapParams.tokenIn) == address(Constants.NATIVE_ADDRESS)) {
            _swap(swapParams, feeSwapPath, true);
        } else {
            // No msg.value
            uint256 balanceBefore = _getBalance(swapParams.tokenIn);
            swapParams.tokenIn.safeTransferFrom(msg.sender, address(this), swapParams.amountIn);
            swapParams.amountIn = _getBalance(swapParams.tokenIn) - balanceBefore;
            _swap(swapParams, feeSwapPath, true);
        }
    }

    /// @notice Ultimate ZAP function
    /// @dev Assumes tokens are already transferred to this contract.
    /// @param swapParams all parameters for swap
    /// @param feeSwapPath swap path for protocol fee
    function _swap(SwapParams memory swapParams, SwapPath memory feeSwapPath, bool takeFee) internal {
        // Verify inputs
        require(swapParams.amountIn > 0, "SoulZap: amountIn must be > 0");
        require(swapParams.to != address(0), "SoulZap: Can't swap to null address");
        require(swapParams.tokenOut != address(0), "SoulZap: tokenOut can't be address(0)");
        require(address(swapParams.tokenIn) != swapParams.tokenOut, "SoulZap: tokens can't be the same");

        bool native = address(swapParams.tokenIn) == address(Constants.NATIVE_ADDRESS);
        if (native) swapParams.tokenIn = WNATIVE;

        if (takeFee) {
            swapParams.amountIn -= _handleFee(
                swapParams.tokenIn,
                swapParams.amountIn,
                feeSwapPath,
                swapParams.deadline
            );
        }

        /**
         * Handle token Swap
         */
        require(swapParams.path.swapRouter != address(0), "SoulZap: swap router can not be address(0)");
        require(swapParams.path.path[0] == address(swapParams.tokenIn), "SoulZap: wrong path path[0]");
        require(
            swapParams.path.path[swapParams.path.path.length - 1] == swapParams.tokenOut,
            "SoulZap: wrong path path[-1]"
        );
        swapParams.tokenIn.forceApprove(swapParams.path.swapRouter, swapParams.amountIn);
        _routerSwapFromPath(swapParams.path, swapParams.amountIn, swapParams.to, swapParams.deadline);

        emit Swap(swapParams);
    }

    /// -----------------------------------------------------------------------
    /// Zap Functions
    /// -----------------------------------------------------------------------

    /// @notice Zap single token to LP
    /// @param zapParams parameters for Zap
    /// @param feeSwapPath swap path for protocol fee
    function zap(
        ZapParams memory zapParams,
        SwapPath memory feeSwapPath
    )
        external
        payable
        override
        nonReentrant
        whenNotPaused
        verifyMsgValueAndWrap(zapParams.tokenIn, zapParams.amountIn)
    {
        if (address(zapParams.tokenIn) == address(Constants.NATIVE_ADDRESS)) {
            _zap(zapParams, feeSwapPath, true);
        } else {
            uint256 balanceBefore = _getBalance(zapParams.tokenIn);
            zapParams.tokenIn.safeTransferFrom(msg.sender, address(this), zapParams.amountIn);
            zapParams.amountIn = _getBalance(zapParams.tokenIn) - balanceBefore;
            _zap(zapParams, feeSwapPath, true);
        }
    }

    /// @notice Ultimate ZAP function
    /// @dev Assumes tokens are already transferred to this contract.
    /// - Native input zap MUST be done with Constants.NATIVE_ADDRESS
    /// @param zapParams see ISoulZap_UniV2.ZapParams struct
    /// @param feeSwapPath see ISoulZap_UniV2.SwapPath struct
    function _zap(ZapParams memory zapParams, SwapPath memory feeSwapPath, bool takeFee) internal {
        // Verify inputs
        require(zapParams.amountIn > 0, "SoulZap: amountIn must be > 0");
        require(zapParams.to != address(0), "SoulZap: Can't zap to null address");
        require(zapParams.liquidityPath.lpRouter != address(0), "SoulZap: lp router can not be address(0)");
        require(zapParams.token0 != address(0), "SoulZap: token0 can not be address(0)");
        require(zapParams.token1 != address(0), "SoulZap: token1 can not be address(0)");

        bool native = address(zapParams.tokenIn) == address(Constants.NATIVE_ADDRESS);
        if (native) zapParams.tokenIn = WNATIVE;

        // Setup struct to prevent stack overflow
        LocalVarsLib.LocalVars memory vars;

        if (takeFee) {
            zapParams.amountIn -= _handleFee(zapParams.tokenIn, zapParams.amountIn, feeSwapPath, zapParams.deadline);
        }

        /**
         * Setup swap amount0 and amount1
         */
        if (zapParams.liquidityPath.lpType == LPType.V2) {
            // Handle UniswapV2 Liquidity
            require(
                IUniswapV2Factory(IUniswapV2Router02(zapParams.liquidityPath.lpRouter).factory()).getPair(
                    zapParams.token0,
                    zapParams.token1
                ) != address(0),
                "SoulZap: Pair doesn't exist"
            );
            vars.amount0In = zapParams.amountIn / 2;
            vars.amount1In = zapParams.amountIn / 2;
        } else {
            revert("SoulZap: LPType not supported");
        }

        /**
         * Handle token0 Swap
         */
        if (zapParams.token0 != address(zapParams.tokenIn)) {
            require(zapParams.path0.swapRouter != address(0), "SoulZap: swap router can not be address(0)");
            require(zapParams.path0.path[0] == address(zapParams.tokenIn), "SoulZap: wrong path path0[0]");
            require(
                zapParams.path0.path[zapParams.path0.path.length - 1] == zapParams.token0,
                "SoulZap: wrong path path0[-1]"
            );
            zapParams.tokenIn.forceApprove(zapParams.path0.swapRouter, vars.amount0In);
            vars.amount0Out = _routerSwapFromPath(zapParams.path0, vars.amount0In, address(this), zapParams.deadline);
        } else {
            vars.amount0Out = zapParams.amountIn - vars.amount1In;
        }
        /**
         * Handle token1 Swap
         */
        if (zapParams.token1 != address(zapParams.tokenIn)) {
            require(zapParams.path1.swapRouter != address(0), "SoulZap: swap router can not be address(0)");
            require(zapParams.path1.path[0] == address(zapParams.tokenIn), "SoulZap: wrong path path1[0]");
            require(
                zapParams.path1.path[zapParams.path1.path.length - 1] == zapParams.token1,
                "SoulZap: wrong path path1[-1]"
            );
            zapParams.tokenIn.forceApprove(zapParams.path1.swapRouter, vars.amount1In);
            vars.amount1Out = _routerSwapFromPath(zapParams.path1, vars.amount1In, address(this), zapParams.deadline);
        } else {
            vars.amount1Out = zapParams.amountIn - vars.amount0In;
        }

        /**
         * Handle Liquidity Add
         */
        IERC20(zapParams.token0).forceApprove(address(zapParams.liquidityPath.lpRouter), vars.amount0Out);
        IERC20(zapParams.token1).forceApprove(address(zapParams.liquidityPath.lpRouter), vars.amount1Out);

        if (zapParams.liquidityPath.lpType == LPType.V2) {
            // Add liquidity to UniswapV2 Pool
            (vars.amount0Lp, vars.amount1Lp, vars.lpAmount) = IUniswapV2Router02(zapParams.liquidityPath.lpRouter)
                .addLiquidity(
                    zapParams.token0,
                    zapParams.token1,
                    vars.amount0Out,
                    vars.amount1Out,
                    zapParams.liquidityPath.amountAMin,
                    zapParams.liquidityPath.amountBMin,
                    zapParams.to,
                    zapParams.deadline
                );
            // Possible option to check for min amount of LP tokens received
            // require(vars.lpAmount >= zapParams.liquidityPath.lpAmount, "SoulZap: Not enough LP tokens received");
        } else {
            revert("SoulZap: lpType not supported");
        }

        if (zapParams.token0 == address(WNATIVE)) {
            // Ensure WNATIVE is called last
            _transferOut(IERC20(zapParams.token1), vars.amount1Out - vars.amount1Lp, msg.sender, native);
            _transferOut(IERC20(zapParams.token0), vars.amount0Out - vars.amount0Lp, msg.sender, native);
        } else {
            _transferOut(IERC20(zapParams.token0), vars.amount0Out - vars.amount0Lp, msg.sender, native);
            _transferOut(IERC20(zapParams.token1), vars.amount1Out - vars.amount1Lp, msg.sender, native);
        }

        /**
         * Remove approval
         */
        IERC20(zapParams.token0).forceApprove(address(zapParams.liquidityPath.lpRouter), 0);
        IERC20(zapParams.token1).forceApprove(address(zapParams.liquidityPath.lpRouter), 0);

        emit Zap(zapParams);
    }

    function _routerSwapFromPath(
        SwapPath memory _uniSwapPath,
        uint256 _amountIn,
        address _to,
        uint256 _deadline
    ) private returns (uint256 amountOut) {
        require(isRouterWhitelisted(_uniSwapPath.swapRouter), "SoulZap: router not whitelisted");
        require(_uniSwapPath.path.length >= 2, "SoulZap: need path0 of >=2");

        address outputToken = _uniSwapPath.path[_uniSwapPath.path.length - 1];
        uint256 balanceBefore = _getBalance(IERC20(outputToken), _to);
        // Swap based on swap type
        if (_uniSwapPath.swapType == SwapType.V2) {
            IUniswapV2Router02(_uniSwapPath.swapRouter).swapExactTokensForTokensSupportingFeeOnTransferTokens(
                _amountIn,
                _uniSwapPath.amountOutMin,
                _uniSwapPath.path,
                _to,
                _deadline
            );
        } else {
            revert("SoulZap: SwapType not supported");
        }
        // Return the balance increase of the output token sent to _to
        amountOut = _getBalance(IERC20(outputToken), _to) - balanceBefore;
    }

    /// -----------------------------------------------------------------------
    /// Fee functions
    /// -----------------------------------------------------------------------

    /**
     * @notice Checks if a given token is a valid fee token.
     * @dev Calls the soulFeeManager's isFeeToken function to determine if the token is used for fees.
     * @param _token The address of the token to check.
     * @return valid True if the token is a valid fee token, false otherwise.
     */
    function isFeeToken(address _token) external view returns (bool valid) {
        return soulFeeManager.isFeeToken(_token);
    }

    /**
     * @notice Retrieves the current fee information for a given epoch volume.
     * @dev Calls the soulFeeManager's getFeeInfo function with the current epoch volume to get fee details.
     * @return feeTokens An array of addresses representing the fee tokens.
     * @return currentFeePercentage The current fee percentage for the epoch.
     * @return feeDenominator The denominator used to calculate the fee percentage.
     * @return feeCollector The address of the fee collector.
     */
    function getFeeInfo()
        public
        view
        override
        returns (address[] memory feeTokens, uint256 currentFeePercentage, uint256 feeDenominator, address feeCollector)
    {
        (feeTokens, currentFeePercentage, feeDenominator, feeCollector) = soulFeeManager.getFeeInfo(getEpochVolume());
    }

    /**
     * @notice Handles the protocol fee calculation and transfer.
     * @dev This function calculates the protocol fee based on the input amount and the current epoch volume.
     * If the protocol fee is not zero, it checks if the output token from the fee swap path is a valid fee token.
     * If the fee swap path length is greater than or equal to 2, it approves the input token for the swap router
     *   and performs a router swap.
     * If the fee swap path length is less than 2, it transfers out the input token to the fee collector.
     * The function also accumulates the volume based on the output of the swap or the input fee amount.
     * @param _inputToken The input token for which the fee is to be calculated.
     * @param _inputAmount The amount of the input token.
     * @param _feeSwapPath The swap path for the fee.
     * @param _deadline The deadline for the swap to occur.
     * @return inputFeeAmount The calculated fee amount.
     */
    function _handleFee(
        IERC20 _inputToken,
        uint256 _inputAmount,
        SwapPath memory _feeSwapPath,
        uint256 _deadline
    ) private returns (uint256 inputFeeAmount) {
        (, uint256 feePercentage, uint256 feeDenominator, address feeCollector) = getFeeInfo();
        if (feePercentage == 0) {
            return 0;
        }

        inputFeeAmount = (_inputAmount * feePercentage) / feeDenominator;

        if (_feeSwapPath.path.length >= 2) {
            require(address(_inputToken) == _feeSwapPath.path[0], "SoulZap: Invalid input token in feeSwapPath");
            address outputToken = _feeSwapPath.path[_feeSwapPath.path.length - 1];
            require(soulFeeManager.isFeeToken(outputToken), "SoulZap: Invalid output token in feeSwapPath");

            _inputToken.forceApprove(_feeSwapPath.swapRouter, inputFeeAmount);
            uint256 amountOut = _routerSwapFromPath(_feeSwapPath, inputFeeAmount, feeCollector, _deadline);
            // Accumulate normalized fee volume
            _accumulateFeeVolume(TokenHelper.normalizeTokenAmount(outputToken, amountOut));
        } else {
            /// @dev Input token is considered fee token or a token with no output route
            /// In order to not create a denial of service, we take any input token in this case.
            _transferOut(_inputToken, inputFeeAmount, feeCollector, false);
            // Only increase fee volume if input token is a fee token
            if (soulFeeManager.isFeeToken(address(_inputToken))) {
                // Accumulate normalized fee volume
                _accumulateFeeVolume(TokenHelper.normalizeTokenAmount(address(_inputToken), inputFeeAmount));
            }
        }
    }
}
// SPDX-License-Identifier: GPL-3.0-only
pragma solidity 0.8.19;

/*
 ██████╗ █████╗ ██╗   ██╗██╗        ██████╗ █████╗ ██╗     ██╗██████╗ ██╗████████╗██╗   ██╗
██╔════╝██╔══██╗██║   ██║██║       ██╔════╝██╔══██╗██║     ██║██╔══██╗██║╚══██╔══╝╚██╗ ██╔╝
╚█████╗ ██║  ██║██║   ██║██║       ╚█████╗ ██║  ██║██║     ██║██║  ██║██║   ██║    ╚████╔╝ 
 ╚═══██╗██║  ██║██║   ██║██║        ╚═══██╗██║  ██║██║     ██║██║  ██║██║   ██║     ╚██╔╝  
██████╔╝╚█████╔╝╚██████╔╝███████╗  ██████╔╝╚█████╔╝███████╗██║██████╔╝██║   ██║      ██║   
╚═════╝  ╚════╝  ╚═════╝ ╚══════╝  ╚═════╝  ╚════╝ ╚══════╝╚═╝╚═════╝ ╚═╝   ╚═╝      ╚═╝   

 * Twitter: https://twitter.com/SoulSolidity
 *  GitHub: https://github.com/SoulSolidity
 *     Web: https://SoulSolidity.com
 */

library Constants {
    address public constant NATIVE_ADDRESS = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;
    // TODO: Consider upping to 1e18;
    uint256 internal constant DENOMINATOR = 10_000;
    uint256 internal constant PRECISION = 1e18;
}
// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.19;

/*
 ██████╗ █████╗ ██╗   ██╗██╗        ██████╗ █████╗ ██╗     ██╗██████╗ ██╗████████╗██╗   ██╗
██╔════╝██╔══██╗██║   ██║██║       ██╔════╝██╔══██╗██║     ██║██╔══██╗██║╚══██╔══╝╚██╗ ██╔╝
╚█████╗ ██║  ██║██║   ██║██║       ╚█████╗ ██║  ██║██║     ██║██║  ██║██║   ██║    ╚████╔╝ 
 ╚═══██╗██║  ██║██║   ██║██║        ╚═══██╗██║  ██║██║     ██║██║  ██║██║   ██║     ╚██╔╝  
██████╔╝╚█████╔╝╚██████╔╝███████╗  ██████╔╝╚█████╔╝███████╗██║██████╔╝██║   ██║      ██║   
╚═════╝  ╚════╝  ╚═════╝ ╚══════╝  ╚═════╝  ╚════╝ ╚══════╝╚═╝╚═════╝ ╚═╝   ╚═╝      ╚═╝   

 * Twitter: https://twitter.com/SoulSolidity
 *  GitHub: https://github.com/SoulSolidity
 *     Web: https://SoulSolidity.com
 */

import {IEpochVolumeTracker} from "./IEpochVolumeTracker.sol";

/**
 * @title EpochVolumeTracker
 * @dev This contract is used to track the volume of epochs.
 * @author Soul Solidity - Contact for mainnet licensing until 730 days after first deployment transaction with matching bytecode.
 * Otherwise feel free to experiment locally or on testnets.
 */
contract EpochVolumeTracker is IEpochVolumeTracker {
    /// -----------------------------------------------------------------------
    /// Storage variables
    /// -----------------------------------------------------------------------

    uint256 private _EPOCH_DURATION = 28 days;
    /// @dev Setting to 1 to reduce gas costs
    uint256 private _lifetimeCumulativeVolume = 1;
    uint256 private _epochStartCumulativeVolume = 1;
    uint256 private _lastEpochStartTime;
    uint256 private _initialEpochStartTime;

    /// -----------------------------------------------------------------------
    /// Constructor
    /// -----------------------------------------------------------------------

    constructor(uint256 __lastEpochStartTime, uint256 _epochDuration) {
        if (__lastEpochStartTime == 0) {
            /// @dev Default current epoch start time is current block timestamp
            _lastEpochStartTime = block.timestamp;
        } else {
            /// @dev Can set the current epoch start time to a past time or future for integration flexibility
            // If epoch start time is too far in the past past, then the epoch will start immediately
            // IF epoch start time is in the future, then the epoch will not start until the epoch start time
            _lastEpochStartTime = __lastEpochStartTime;
        }

        _initialEpochStartTime = __lastEpochStartTime;

        if (_epochDuration == 0) {
            /// @dev Default epoch duration is 28 days
            _EPOCH_DURATION = 28 days;
        } else {
            _EPOCH_DURATION = _epochDuration;
        }
    }

    /// -----------------------------------------------------------------------
    /// Epoch functions
    /// -----------------------------------------------------------------------

    /**
     * @notice Retrieves the volume information for the current epoch.
     * @dev This function returns the lifetime cumulative volume, the cumulative volume at the start of the epoch,
     * the start time of the last epoch, the time left in the current epoch, and the duration of an epoch.
     * @return epochVolume The volume of the current epoch.
     * @return lifetimeCumulativeVolume The total volume accumulated since the contract's inception.
     * @return epochStartCumulativeVolume The total volume accumulated at the start of the current epoch.
     * @return lastEpochStartTime The start time of the last epoch.
     * @return timeLeftInEpoch The remaining time in the current epoch.
     * @return epochDuration The duration of an epoch.
     */
    function getEpochVolumeInfo()
        public
        view
        override
        returns (
            uint256 epochVolume,
            uint256 lifetimeCumulativeVolume,
            uint256 epochStartCumulativeVolume,
            uint256 lastEpochStartTime,
            uint256 timeLeftInEpoch,
            uint256 epochDuration
        )
    {
        return (
            getEpochVolume(),
            _lifetimeCumulativeVolume,
            _epochStartCumulativeVolume,
            _lastEpochStartTime,
            getTimeLeftInEpoch(),
            _EPOCH_DURATION
        );
    }

    /// @notice Returns the volume of the current epoch
    /// @return The volume of the current epoch
    function getEpochVolume() public view override returns (uint256) {
        if (_epochNeedsReset()) {
            return 0;
        }
        return _lifetimeCumulativeVolume - _epochStartCumulativeVolume;
    }

    /// @notice Returns the "virtual" time left in the current epoch
    /// @return The "virtual" time left in the current epoch
    function getTimeLeftInEpoch() public view override returns (uint256) {
        if (block.timestamp < _initialEpochStartTime) {
            return 0;
        }
        uint256 timeSinceInitialEpochStart = block.timestamp - _initialEpochStartTime;
        uint256 timeElapsedInCurrentEpoch = timeSinceInitialEpochStart % _EPOCH_DURATION;
        return _EPOCH_DURATION - timeElapsedInCurrentEpoch;
    }

    /// @dev Resets the epoch based on the "virtual" time left in the current epoch
    function _resetEpoch() internal {
        // Update epoch start cumulative volume to lifetime cumulative volume
        _epochStartCumulativeVolume = _lifetimeCumulativeVolume;
        // Update current epoch start time based on the "virtual" time left in the current epoch
        _lastEpochStartTime = block.timestamp - ((block.timestamp - _initialEpochStartTime) % _EPOCH_DURATION);
    }

    /// @notice Checks if the current epoch is over
    /// @return True if the current epoch is over, false otherwise
    function _epochNeedsReset() private view returns (bool) {
        return block.timestamp >= _lastEpochStartTime + _EPOCH_DURATION;
    }

    /// -----------------------------------------------------------------------
    /// Volume functions
    /// -----------------------------------------------------------------------

    /// @dev Accumulates volume and updates epoch start time if current epoch is over.
    /// @param _volume The volume to be accumulated. Intended to be normalized to 18 decimals
    function _accumulateFeeVolume(uint256 _volume) internal {
        // Epoch start time in future, do not accumulate volume until epoch starts.
        // Allows for setting epoch start time to a future time for configuration flexibility.
        if (block.timestamp < _initialEpochStartTime) {
            return;
        }

        if (_epochNeedsReset()) {
            _resetEpoch();
        }

        // Add the volume to lifetime cumulative volume
        _lifetimeCumulativeVolume += _volume;
        emit AccumulateVolume(_volume, _lifetimeCumulativeVolume, _epochStartCumulativeVolume, _lastEpochStartTime);
    }
}
// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

/*
 ██████╗ █████╗ ██╗   ██╗██╗        ██████╗ █████╗ ██╗     ██╗██████╗ ██╗████████╗██╗   ██╗
██╔════╝██╔══██╗██║   ██║██║       ██╔════╝██╔══██╗██║     ██║██╔══██╗██║╚══██╔══╝╚██╗ ██╔╝
╚█████╗ ██║  ██║██║   ██║██║       ╚█████╗ ██║  ██║██║     ██║██║  ██║██║   ██║    ╚████╔╝ 
 ╚═══██╗██║  ██║██║   ██║██║        ╚═══██╗██║  ██║██║     ██║██║  ██║██║   ██║     ╚██╔╝  
██████╔╝╚█████╔╝╚██████╔╝███████╗  ██████╔╝╚█████╔╝███████╗██║██████╔╝██║   ██║      ██║   
╚═════╝  ╚════╝  ╚═════╝ ╚══════╝  ╚═════╝  ╚════╝ ╚══════╝╚═╝╚═════╝ ╚═╝   ╚═╝      ╚═╝   

 * Twitter: https://twitter.com/SoulSolidity
 *  GitHub: https://github.com/SoulSolidity
 *     Web: https://SoulSolidity.com
 */

interface IEpochVolumeTracker {
    /// -----------------------------------------------------------------------
    /// Events
    /// -----------------------------------------------------------------------

    event AccumulateVolume(
        uint256 volumeAccumulated,
        uint256 lifetimeCumulativeVolume,
        uint256 epochStartCumulativeVolume,
        uint256 currentEpochStartTime
    );

    /// -----------------------------------------------------------------------
    /// Public/External functions
    /// -----------------------------------------------------------------------

    function getEpochVolume() external view returns (uint256);

    function getTimeLeftInEpoch() external view returns (uint256);

    function getEpochVolumeInfo()
        external
        view
        returns (
            uint256 epochVolume,
            uint256 lifetimeCumulativeVolume,
            uint256 epochStartCumulativeVolume,
            uint256 lastEpochStartTime,
            uint256 timeLeftInEpoch,
            uint256 epochDuration
        );
}
// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.0;

/*
 ██████╗ █████╗ ██╗   ██╗██╗        ██████╗ █████╗ ██╗     ██╗██████╗ ██╗████████╗██╗   ██╗
██╔════╝██╔══██╗██║   ██║██║       ██╔════╝██╔══██╗██║     ██║██╔══██╗██║╚══██╔══╝╚██╗ ██╔╝
╚█████╗ ██║  ██║██║   ██║██║       ╚█████╗ ██║  ██║██║     ██║██║  ██║██║   ██║    ╚████╔╝ 
 ╚═══██╗██║  ██║██║   ██║██║        ╚═══██╗██║  ██║██║     ██║██║  ██║██║   ██║     ╚██╔╝  
██████╔╝╚█████╔╝╚██████╔╝███████╗  ██████╔╝╚█████╔╝███████╗██║██████╔╝██║   ██║      ██║   
╚═════╝  ╚════╝  ╚═════╝ ╚══════╝  ╚═════╝  ╚════╝ ╚══════╝╚═╝╚═════╝ ╚═╝   ╚═╝      ╚═╝   

 * Twitter: https://twitter.com/SoulSolidity
 *  GitHub: https://github.com/SoulSolidity
 *     Web: https://SoulSolidity.com
 */

import {IWETH} from "../lib/IWETH.sol";

interface ITransferHelper {
    /// -----------------------------------------------------------------------
    /// Storage variables
    /// -----------------------------------------------------------------------
    function WNATIVE() external view returns (IWETH);
}
// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.0;

library LocalVarsLib {
    struct LocalVars {
        uint256 amount0In;
        uint256 amount1In;
        uint256 amount0Out;
        uint256 amount1Out;
        uint256 amount0Lp;
        uint256 amount1Lp;
        uint256 lpAmount;
    }
}
// SPDX-License-Identifier: GPL-3.0-only
pragma solidity 0.8.19;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";

import {SoulAccessManaged} from "../access/SoulAccessManaged.sol";

/**
 * @dev Sweep any ERC20 token.
 * Sometimes people accidentally send tokens to a contract without any way to retrieve them.
 * This contract makes sure any erc20 tokens can be removed from the contract.
 */
abstract contract Sweeper is SoulAccessManaged {
    bytes32 private immutable sweeperAdminRole;

    struct NFT {
        IERC721 nftAddress;
        uint256[] ids;
    }
    mapping(address => bool) public lockedTokens;
    bool public allowNativeSweep;

    event SweepWithdrawToken(address indexed receiver, IERC20 indexed token, uint256 balance);

    event SweepWithdrawNFTs(address indexed receiver, NFT[] indexed nfts);

    event SweepWithdrawNative(address indexed receiver, uint256 balance);

    constructor(address[] memory _lockedTokens, bool _allowNativeSweep, bytes32 _sweeperAdminRole) {
        _lockTokens(_lockedTokens);
        allowNativeSweep = _allowNativeSweep;
        sweeperAdminRole = _sweeperAdminRole;
    }

    /**
     * @dev Transfers erc20 tokens to owner
     * Only owner of contract can call this function
     */
    function sweepTokens(IERC20[] memory tokens, address to) external onlyAccessRegistryRole(sweeperAdminRole) {
        NFT[] memory empty;
        sweepTokensAndNFTs(tokens, empty, to);
    }

    /**
     * @dev Transfers NFT to owner
     * Only owner of contract can call this function
     */
    function sweepNFTs(NFT[] memory nfts, address to) external onlyAccessRegistryRole(sweeperAdminRole) {
        IERC20[] memory empty;
        sweepTokensAndNFTs(empty, nfts, to);
    }

    /**
     * @dev Transfers ERC20 and NFT to owner
     * Only owner of contract can call this function
     */
    function sweepTokensAndNFTs(
        IERC20[] memory tokens,
        NFT[] memory nfts,
        address to
    ) public onlyAccessRegistryRole(sweeperAdminRole) {
        for (uint256 i = 0; i < tokens.length; i++) {
            IERC20 token = tokens[i];
            require(!lockedTokens[address(token)], "Tokens can't be swept");
            uint256 balance = token.balanceOf(address(this));
            token.transfer(to, balance);
            emit SweepWithdrawToken(to, token, balance);
        }

        for (uint256 i = 0; i < nfts.length; i++) {
            IERC721 nftAddress = nfts[i].nftAddress;
            require(!lockedTokens[address(nftAddress)], "Tokens can't be swept");
            uint256[] memory ids = nfts[i].ids;
            for (uint256 j = 0; j < ids.length; j++) {
                nftAddress.safeTransferFrom(address(this), to, ids[j]);
            }
        }
        emit SweepWithdrawNFTs(to, nfts);
    }

    /// @notice Sweep native coin
    /// @param _to address the native coins should be transferred to
    function sweepNative(address payable _to) external onlyAccessRegistryRole(sweeperAdminRole) {
        require(allowNativeSweep, "Not allowed");
        uint256 balance = address(this).balance;
        _to.transfer(balance);
        emit SweepWithdrawNative(_to, balance);
    }

    /**
     * @dev Refuse native sweep.
     * Once refused can't be allowed again
     */
    function refuseNativeSweep() external onlyAccessRegistryRole(sweeperAdminRole) {
        allowNativeSweep = false;
    }

    /**
     * @dev Lock single token so they can't be transferred from the contract.
     * Once locked it can't be unlocked
     */
    function lockToken(address token) external onlyAccessRegistryRole(sweeperAdminRole) {
        address[] memory tokenArray = new address[](1);
        tokenArray[0] = token;
        _lockTokens(tokenArray);
    }

    /**
     * @dev Lock multiple tokens so they can't be transferred from the contract.
     * Once locked it can't be unlocked
     */
    function lockTokens(address[] memory tokens) external onlyAccessRegistryRole(sweeperAdminRole) {
        _lockTokens(tokens);
    }

    function _lockTokens(address[] memory tokens) private {
        for (uint256 i = 0; i < tokens.length; i++) {
            lockedTokens[tokens[i]] = true;
        }
    }
}
// SPDX-License-Identifier: GPL-3.0-only
pragma solidity 0.8.19;

/*
 ██████╗ █████╗ ██╗   ██╗██╗        ██████╗ █████╗ ██╗     ██╗██████╗ ██╗████████╗██╗   ██╗
██╔════╝██╔══██╗██║   ██║██║       ██╔════╝██╔══██╗██║     ██║██╔══██╗██║╚══██╔══╝╚██╗ ██╔╝
╚█████╗ ██║  ██║██║   ██║██║       ╚█████╗ ██║  ██║██║     ██║██║  ██║██║   ██║    ╚████╔╝ 
 ╚═══██╗██║  ██║██║   ██║██║        ╚═══██╗██║  ██║██║     ██║██║  ██║██║   ██║     ╚██╔╝  
██████╔╝╚█████╔╝╚██████╔╝███████╗  ██████╔╝╚█████╔╝███████╗██║██████╔╝██║   ██║      ██║   
╚═════╝  ╚════╝  ╚═════╝ ╚══════╝  ╚═════╝  ╚════╝ ╚══════╝╚═╝╚═════╝ ╚═╝   ╚═╝      ╚═╝   

 * Twitter: https://twitter.com/SoulSolidity
 *  GitHub: https://github.com/SoulSolidity
 *     Web: https://SoulSolidity.com
 */

import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";

library TokenHelper {
    /**
     * @notice Retrieves the number of decimal places used by a given token.
     * @dev If the token supports the IERC20Metadata interface, it will return the token's decimals.
     * If the token does not support the interface, it will default to 18 decimals.
     * @param token The address of the token for which to retrieve the decimal places.
     * @return decimals The number of decimal places used by the token.
     */
    function getTokenDecimals(address token) internal view returns (uint8 decimals) {
        try IERC20Metadata(token).decimals() returns (uint8 dec) {
            decimals = dec;
        } catch {
            decimals = 18;
        }
    }

    /**
     * @notice Normalizes the amount of tokens to a standard 18 decimal format.
     * @dev This function adjusts the amount of tokens to a normalized 18 decimal format,
     *      taking into account the number of decimal places the token uses.
     * @param token The address of the ERC20 token for which to normalize the amount.
     * @param amount The original amount of tokens to be normalized.
     * @return The adjusted amount of tokens, normalized to 18 decimal places.
     */
    function normalizeTokenAmount(address token, uint256 amount) internal view returns (uint256) {
        return normalizeAmountByDecimals(amount, getTokenDecimals(token));
    }

    /**
     * @notice Adjusts the amount of tokens to a normalized 18 decimal format.
     * @dev Tokens with less than 18 decimals will loose precision to 18 decimals.
     * @param amount The original amount of tokens with `decimals` decimal places.
     * @param decimals The number of decimal places the token uses.
     * @return The adjusted amount of tokens, normalized to 18 decimal places.
     */
    function normalizeAmountByDecimals(uint256 amount, uint8 decimals) internal pure returns (uint256) {
        // If the token has more than 18 decimals, we divide the amount to normalize to 18 decimals.
        if (decimals > 18) {
            // Dividing by 10 ** (decimals - 18) to reduce the number of decimals.
            return amount / 10 ** (decimals - 18);
        } else if (decimals < 18) {
            // Multiplying by 10 ** (18 - decimals) to increase the number of decimals.
            return amount * 10 ** (18 - decimals);
        } else {
            // If the token already has 18 decimals, return the amount unchanged.
            return amount;
        }
    }
}
// SPDX-License-Identifier: GPL-3.0-only
pragma solidity 0.8.19;

/*
 ██████╗ █████╗ ██╗   ██╗██╗        ██████╗ █████╗ ██╗     ██╗██████╗ ██╗████████╗██╗   ██╗
██╔════╝██╔══██╗██║   ██║██║       ██╔════╝██╔══██╗██║     ██║██╔══██╗██║╚══██╔══╝╚██╗ ██╔╝
╚█████╗ ██║  ██║██║   ██║██║       ╚█████╗ ██║  ██║██║     ██║██║  ██║██║   ██║    ╚████╔╝ 
 ╚═══██╗██║  ██║██║   ██║██║        ╚═══██╗██║  ██║██║     ██║██║  ██║██║   ██║     ╚██╔╝  
██████╔╝╚█████╔╝╚██████╔╝███████╗  ██████╔╝╚█████╔╝███████╗██║██████╔╝██║   ██║      ██║   
╚═════╝  ╚════╝  ╚═════╝ ╚══════╝  ╚═════╝  ╚════╝ ╚══════╝╚═╝╚═════╝ ╚═╝   ╚═╝      ╚═╝   

 * Twitter: https://twitter.com/SoulSolidity
 *  GitHub: https://github.com/SoulSolidity
 *     Web: https://SoulSolidity.com
 */

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {ITransferHelper} from "../utils/ITransferHelper.sol";
import {IWETH} from "../lib/IWETH.sol";

contract TransferHelper is ITransferHelper {
    using SafeERC20 for IERC20;

    /// -----------------------------------------------------------------------
    /// Storage variables
    /// -----------------------------------------------------------------------

    IWETH public immutable WNATIVE;

    /// -----------------------------------------------------------------------
    /// Constructor
    /// -----------------------------------------------------------------------

    constructor(IWETH wnative) {
        WNATIVE = wnative;
    }

    /// -----------------------------------------------------------------------
    /// Wrapped Native helpers
    /// -----------------------------------------------------------------------

    /// @notice Wrap the msg.value into the Wrapped Native token
    /// @return wNative The IERC20 representation of the wrapped asset
    /// @return amount Amount of native tokens wrapped
    function _wrapNative() internal returns (IERC20 wNative, uint256 amount) {
        wNative = IERC20(address(WNATIVE));
        amount = msg.value;
        WNATIVE.deposit{value: amount}();
    }

    /// @notice Unwrap current balance of Wrapped Native tokens
    /// @return amount Amount of native tokens unwrapped
    function _unwrapNative() internal returns (uint256 amount) {
        amount = _getBalance(IERC20(address(WNATIVE)));
        IWETH(WNATIVE).withdraw(amount);
    }

    /// -----------------------------------------------------------------------
    /// ERC20 transfer helpers (supporting fee on transfer)
    /// - Also `_transferOut` WNative unwrap support.
    /// -----------------------------------------------------------------------

    /// @notice Transfers in ERC20 tokens from the sender to this contract
    /// @param token The ERC20 token to transfer
    /// @param amount The amount of tokens to transfer
    /// @return amountIn The actual amount of tokens transferred

    function _transferIn(IERC20 token, uint256 amount) internal returns (uint256 amountIn) {
        if (amount == 0) return 0;
        uint256 balanceBefore = _getBalance(token);
        token.safeTransferFrom(msg.sender, address(this), amount);
        amountIn = _getBalance(token) - balanceBefore;
    }

    /// @notice Transfers out ERC20 tokens from this contract to a recipient
    /// @param token The ERC20 token to transfer
    /// @param amount The amount of tokens to transfer
    /// @param to The recipient of the tokens
    /// @param native Whether to unwrap Wrapped Native tokens before transfer
    function _transferOut(IERC20 token, uint256 amount, address to, bool native) internal {
        if (amount == 0) return;
        if (address(token) == address(WNATIVE) && native) {
            IWETH(WNATIVE).withdraw(amount);
            // 2600 COLD_ACCOUNT_ACCESS_COST plus 2300 transfer gas - 1
            // Intended to support transfers to contracts, but not allow for further code execution
            (bool success, ) = to.call{value: amount, gas: 4899}("");
            require(success, "native transfer error");
        } else {
            token.safeTransfer(to, amount);
        }
    }

    /// @notice Gets the balance of an ERC20 token in this contract
    /// @param token The ERC20 token to check the balance of
    /// @return balance The balance of the tokens in this contract
    function _getBalance(IERC20 token) internal view returns (uint256 balance) {
        balance = token.balanceOf(address(this));
    }

    /// @notice Gets the balance of an ERC20 token in this contract
    /// @param token The ERC20 token to check the balance of
    /// @param token The address to check the balance of
    /// @return balance The balance of the tokens in this contract
    function _getBalance(IERC20 token, address _address) internal view returns (uint256 balance) {
        balance = token.balanceOf(_address);
    }
}
