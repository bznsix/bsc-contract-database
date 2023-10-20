// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (access/Ownable.sol)

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
    function __Ownable_init() internal onlyInitializing {
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal onlyInitializing {
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

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
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
// OpenZeppelin Contracts (last updated v4.9.0) (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;
import "../proxy/utils/Initializable.sol";

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
abstract contract ReentrancyGuardUpgradeable is Initializable {
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

    function __ReentrancyGuard_init() internal onlyInitializing {
        __ReentrancyGuard_init_unchained();
    }

    function __ReentrancyGuard_init_unchained() internal onlyInitializing {
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

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
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
// OpenZeppelin Contracts (last updated v4.8.0) (finance/PaymentSplitter.sol)

pragma solidity ^0.8.0;

import "../token/ERC20/utils/SafeERC20.sol";
import "../utils/Address.sol";
import "../utils/Context.sol";

/**
 * @title PaymentSplitter
 * @dev This contract allows to split Ether payments among a group of accounts. The sender does not need to be aware
 * that the Ether will be split in this way, since it is handled transparently by the contract.
 *
 * The split can be in equal parts or in any other arbitrary proportion. The way this is specified is by assigning each
 * account to a number of shares. Of all the Ether that this contract receives, each account will then be able to claim
 * an amount proportional to the percentage of total shares they were assigned. The distribution of shares is set at the
 * time of contract deployment and can't be updated thereafter.
 *
 * `PaymentSplitter` follows a _pull payment_ model. This means that payments are not automatically forwarded to the
 * accounts but kept in this contract, and the actual transfer is triggered as a separate step by calling the {release}
 * function.
 *
 * NOTE: This contract assumes that ERC20 tokens will behave similarly to native tokens (Ether). Rebasing tokens, and
 * tokens that apply fees during transfers, are likely to not be supported as expected. If in doubt, we encourage you
 * to run tests before sending real value to this contract.
 */
contract PaymentSplitter is Context {
    event PayeeAdded(address account, uint256 shares);
    event PaymentReleased(address to, uint256 amount);
    event ERC20PaymentReleased(IERC20 indexed token, address to, uint256 amount);
    event PaymentReceived(address from, uint256 amount);

    uint256 private _totalShares;
    uint256 private _totalReleased;

    mapping(address => uint256) private _shares;
    mapping(address => uint256) private _released;
    address[] private _payees;

    mapping(IERC20 => uint256) private _erc20TotalReleased;
    mapping(IERC20 => mapping(address => uint256)) private _erc20Released;

    /**
     * @dev Creates an instance of `PaymentSplitter` where each account in `payees` is assigned the number of shares at
     * the matching position in the `shares` array.
     *
     * All addresses in `payees` must be non-zero. Both arrays must have the same non-zero length, and there must be no
     * duplicates in `payees`.
     */
    constructor(address[] memory payees, uint256[] memory shares_) payable {
        require(payees.length == shares_.length, "PaymentSplitter: payees and shares length mismatch");
        require(payees.length > 0, "PaymentSplitter: no payees");

        for (uint256 i = 0; i < payees.length; i++) {
            _addPayee(payees[i], shares_[i]);
        }
    }

    /**
     * @dev The Ether received will be logged with {PaymentReceived} events. Note that these events are not fully
     * reliable: it's possible for a contract to receive Ether without triggering this function. This only affects the
     * reliability of the events, and not the actual splitting of Ether.
     *
     * To learn more about this see the Solidity documentation for
     * https://solidity.readthedocs.io/en/latest/contracts.html#fallback-function[fallback
     * functions].
     */
    receive() external payable virtual {
        emit PaymentReceived(_msgSender(), msg.value);
    }

    /**
     * @dev Getter for the total shares held by payees.
     */
    function totalShares() public view returns (uint256) {
        return _totalShares;
    }

    /**
     * @dev Getter for the total amount of Ether already released.
     */
    function totalReleased() public view returns (uint256) {
        return _totalReleased;
    }

    /**
     * @dev Getter for the total amount of `token` already released. `token` should be the address of an IERC20
     * contract.
     */
    function totalReleased(IERC20 token) public view returns (uint256) {
        return _erc20TotalReleased[token];
    }

    /**
     * @dev Getter for the amount of shares held by an account.
     */
    function shares(address account) public view returns (uint256) {
        return _shares[account];
    }

    /**
     * @dev Getter for the amount of Ether already released to a payee.
     */
    function released(address account) public view returns (uint256) {
        return _released[account];
    }

    /**
     * @dev Getter for the amount of `token` tokens already released to a payee. `token` should be the address of an
     * IERC20 contract.
     */
    function released(IERC20 token, address account) public view returns (uint256) {
        return _erc20Released[token][account];
    }

    /**
     * @dev Getter for the address of the payee number `index`.
     */
    function payee(uint256 index) public view returns (address) {
        return _payees[index];
    }

    /**
     * @dev Getter for the amount of payee's releasable Ether.
     */
    function releasable(address account) public view returns (uint256) {
        uint256 totalReceived = address(this).balance + totalReleased();
        return _pendingPayment(account, totalReceived, released(account));
    }

    /**
     * @dev Getter for the amount of payee's releasable `token` tokens. `token` should be the address of an
     * IERC20 contract.
     */
    function releasable(IERC20 token, address account) public view returns (uint256) {
        uint256 totalReceived = token.balanceOf(address(this)) + totalReleased(token);
        return _pendingPayment(account, totalReceived, released(token, account));
    }

    /**
     * @dev Triggers a transfer to `account` of the amount of Ether they are owed, according to their percentage of the
     * total shares and their previous withdrawals.
     */
    function release(address payable account) public virtual {
        require(_shares[account] > 0, "PaymentSplitter: account has no shares");

        uint256 payment = releasable(account);

        require(payment != 0, "PaymentSplitter: account is not due payment");

        // _totalReleased is the sum of all values in _released.
        // If "_totalReleased += payment" does not overflow, then "_released[account] += payment" cannot overflow.
        _totalReleased += payment;
        unchecked {
            _released[account] += payment;
        }

        Address.sendValue(account, payment);
        emit PaymentReleased(account, payment);
    }

    /**
     * @dev Triggers a transfer to `account` of the amount of `token` tokens they are owed, according to their
     * percentage of the total shares and their previous withdrawals. `token` must be the address of an IERC20
     * contract.
     */
    function release(IERC20 token, address account) public virtual {
        require(_shares[account] > 0, "PaymentSplitter: account has no shares");

        uint256 payment = releasable(token, account);

        require(payment != 0, "PaymentSplitter: account is not due payment");

        // _erc20TotalReleased[token] is the sum of all values in _erc20Released[token].
        // If "_erc20TotalReleased[token] += payment" does not overflow, then "_erc20Released[token][account] += payment"
        // cannot overflow.
        _erc20TotalReleased[token] += payment;
        unchecked {
            _erc20Released[token][account] += payment;
        }

        SafeERC20.safeTransfer(token, account, payment);
        emit ERC20PaymentReleased(token, account, payment);
    }

    /**
     * @dev internal logic for computing the pending payment of an `account` given the token historical balances and
     * already released amounts.
     */
    function _pendingPayment(
        address account,
        uint256 totalReceived,
        uint256 alreadyReleased
    ) private view returns (uint256) {
        return (totalReceived * _shares[account]) / _totalShares - alreadyReleased;
    }

    /**
     * @dev Add a new payee to the contract.
     * @param account The address of the payee to add.
     * @param shares_ The number of shares owned by the payee.
     */
    function _addPayee(address account, uint256 shares_) private {
        require(account != address(0), "PaymentSplitter: account is the zero address");
        require(shares_ > 0, "PaymentSplitter: shares are 0");
        require(_shares[account] == 0, "PaymentSplitter: account already has shares");

        _payees.push(account);
        _shares[account] = shares_;
        _totalShares = _totalShares + shares_;
        emit PayeeAdded(account, shares_);
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
// OpenZeppelin Contracts (last updated v4.9.0) (utils/math/SafeMath.sol)

pragma solidity ^0.8.0;

// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

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
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/finance/PaymentSplitter.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

using SafeMath for uint256;
using SafeERC20 for IERC20;

contract BarnajeDAOGate is PaymentSplitter, ReentrancyGuard, Ownable {
    address[] public payees;
    IERC20 public usdt;

    event FundsReleased(address indexed recipient, uint256 amount);

    constructor(
        address[] memory _payees,
        uint256[] memory shares,
        address _usdtAddress
    ) payable PaymentSplitter(_payees, shares) {
        payees = _payees;
        usdt = IERC20(_usdtAddress);
    }

    function getPayees() public view returns (address[] memory) {
        return payees;
    }

    function depositUSDT(uint256 amount) public {
        usdt.safeTransferFrom(msg.sender, address(this), amount);
    }

    function releaseFundsToAll() public onlyOwner nonReentrant {
        uint256 totalShares = totalShares();
        uint256 totalReceived = usdt.balanceOf(address(this));

        require(totalReceived != 0, "No funds to release");

        for (uint256 i = 0; i < payees.length; i++) {
            uint256 payment = totalReceived.mul(shares(payees[i])).div(totalShares);
            usdt.safeTransfer(payees[i], payment);
            emit FundsReleased(payees[i], payment);
        }
    }
}// SPDX-License-Identifier: MIT

//  ██████╗  █████╗ ██████╗ ███╗   ██╗ █████╗      ██╗███████╗
//  ██╔══██╗██╔══██╗██╔══██╗████╗  ██║██╔══██╗     ██║██╔════╝
//  ██████╔╝███████║██████╔╝██╔██╗ ██║███████║     ██║█████╗
//  ██╔══██╗██╔══██║██╔══██╗██║╚██╗██║██╔══██║██   ██║██╔══╝
//  ██████╔╝██║  ██║██║  ██║██║ ╚████║██║  ██║╚█████╔╝███████╗
//  ╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═══╝╚═╝  ╚═╝ ╚════╝ ╚══════╝
//

pragma solidity ^0.8.4;

import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

import "./Initialize.sol";
import "./BarnajeTreeHandler.sol";
import "./BarnajeDAOGate.sol";
import "./Raindrops.sol";

import "./model/StepData.sol";
import "./model/TreeNode.sol";
import "./model/Floor.sol";
import "./model/User.sol";

contract BarnajeSDP is
    Initializable,
    OwnableUpgradeable,
    ReentrancyGuardUpgradeable
{
    event Deposit(address indexed donor, uint256 amount);
    event Transfer(address indexed from, address to, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount);
    event Donate(address indexed donor, uint amount);
    event Requalified(address indexed donor, uint step);
    event Received(
        address indexed receiver,
        address indexed donor,
        uint amount,
        string donationType
    );
    event Recovered(address token, uint256 amount);
    event RaindropsClaimed(address indexed claimant, uint amount);
    event NotEligibleDueToStepRequalification(
        string receiver,
        string donor,
        uint step,
        uint donationsReceived
    );
    event TestEvent(string message);

    IERC20 public usdt; // USDT token contract interface
    BarnajeTreeHandler public treeHandler; // Manager sponsor contract interface
    BarnajeDAOGate public paymentSplitter; // Payment splitter contract interface
    Raindrops public raindrops;

    mapping(address => User) public users;
    mapping(string => bool) public usernameExists;
    mapping(address => mapping(uint256 => uint256))
        public donationsReceivedPerStep;
    mapping(uint256 => uint256) public maxDonationsPerStep;
    mapping(address => uint256) public lastClaimedDistribution;

    uint256 public currentDistribution;

    StepData[] private steps; // Steps and floor
    address public dao; // DAO address
    uint256 public donatedCount; // Total number of users donated
    uint256 public amountDonated; // Total amount donated
    uint256 public startDate;
    bool public hasGenesis; // Flag to check if the contract is initialized

    uint256 public totalRaindropsToDistribute;
    uint256 public totalActiveUsersAtDistribution;

    struct FloorConditions {
        bool isFloorFourConditionMet;
        bool isFloorFiveConditionMet;
        bool isFloorSixConditionMet;
        bool isFloorSevenConditionMet;
    }

    function initialize(
        IERC20 _usdt,
        BarnajeTreeHandler _treeHandler,
        BarnajeDAOGate _paymentSplitter,
        address _dao,
        uint256 _startDate
    ) public initializer {
        __Ownable_init();
        __ReentrancyGuard_init();

        usdt = _usdt;
        treeHandler = _treeHandler;
        paymentSplitter = _paymentSplitter;
        dao = _dao;
        startDate = _startDate;
    }

    modifier afterStartDate() {
        require(
            block.timestamp >= startDate,
            "The contract has not launched yet"
        );
        _;
    }

    function toLowerCase(
        string memory str
    ) internal pure returns (string memory) {
        bytes memory bStr = bytes(str);
        bytes memory bLower = new bytes(bStr.length);
        for (uint i = 0; i < bStr.length; i++) {
            // Uppercase character ASCII values are between 65 and 90 (inclusive)
            // To get lowercase, add 32 to the uppercase ASCII value
            if ((uint8(bStr[i]) >= 65) && (uint8(bStr[i]) <= 90)) {
                bLower[i] = bytes1(uint8(bStr[i]) + 32);
            } else {
                bLower[i] = bStr[i];
            }
        }
        return string(bLower);
    }

    function register(
        address _referred,
        string calldata _username
    ) public nonReentrant afterStartDate {
        require(
            _referred != dao ||
                keccak256(abi.encodePacked(_username)) ==
                keccak256(abi.encodePacked("1000k")),
            "Cannot register under the DAO"
        );
        require(
            !usernameExists[toLowerCase(_username)],
            "Username is already taken"
        );
        require(
            !users[msg.sender].userRegistered,
            "User is already registered"
        );
        require(users[_referred].userRegistered, "Sponsor isn't registered");

        User storage user = users[msg.sender];
        user.userRegistered = true;
        user.referred = _referred;
        user.maxSponsored = 4;
        user.username = _username;
        users[_referred].registered.push(msg.sender);
        usernameExists[toLowerCase(_username)] = true;
    }

    // user will need to approve the contract to transferFrom
    function deposit(uint256 _amount) public nonReentrant afterStartDate {
        require(users[msg.sender].userRegistered, "User is not registered");
        require(_amount > 0, "Must deposit more than zero");

        users[msg.sender].balance += _amount;
        users[msg.sender].amountDeposit += _amount;

        require(
            usdt.transferFrom(msg.sender, address(this), _amount),
            "Error depositing"
        );

        emit Deposit(msg.sender, _amount);
    }

    function donate(
        uint _stepup,
        bool _useTicketToRide
    ) public nonReentrant afterStartDate {
        uint256 totalCost = getCostOfSteps(msg.sender, _stepup);
        require(totalCost > 0, "Invalid stepup");

        if (_useTicketToRide) {
            require(
                users[msg.sender].lockedBalance >= totalCost,
                "Insufficient locked balance for donation"
            );
        } else {
            require(
                users[msg.sender].balance >= totalCost,
                "Insufficient balance for donation"
            );
        }

        // make sure to set users step below for this check
        require(users[msg.sender].step + _stepup <= 21, "Max step level is 21");

        if (users[msg.sender].sponsor == address(0)) {
            address nodeToStartAt;
            donatedCount++;

            // spillover here give sponsorship to one of refer's children
            if (
                users[users[msg.sender].referred].sponsored.length >=
                users[users[msg.sender].referred].maxSponsored
            ) {
                nodeToStartAt = sponsorSpillover();
                // give sponsorship to original referrer otherwise
            } else {
                nodeToStartAt = setSponsor();
            }

            treeHandler.addToTree(msg.sender, nodeToStartAt);
        }

        if (_useTicketToRide) {
            users[msg.sender].lockedBalance -= totalCost;
        } else {
            users[msg.sender].balance -= totalCost;
        }

        uint newDonated = users[msg.sender].donated + totalCost;
        users[msg.sender].donated = newDonated;

        amountDonated += totalCost;

        disperseForStepUp(_stepup);

        emit Donate(msg.sender, totalCost);
    }

    function requalify(uint _targetStep) public nonReentrant afterStartDate {
        uint totalCost = steps[_targetStep].amount;
        require(
            users[msg.sender].balance >= totalCost,
            "Insufficient balance for requalification"
        );
        require(totalCost > 0, "Invalid requalification step");

        users[msg.sender].balance -= totalCost;

        uint newDonated = users[msg.sender].donated + totalCost; // Calculate new value first
        users[msg.sender].donated = newDonated; // Then write it to storage

        amountDonated += totalCost;

        disperseForRequalification(_targetStep);

        donationsReceivedPerStep[msg.sender][_targetStep] = 0;

        emit Requalified(msg.sender, _targetStep);
    }

    function sendTicketToRide(
        address _to,
        uint256 _amount
    ) public nonReentrant afterStartDate {
        require(
            users[msg.sender].balance >= _amount,
            "Insufficient balance for transfer"
        );
        require(_to != msg.sender, "Cannot transfer to self");

        // Decrement sender's balance
        users[msg.sender].balance -= _amount;

        // Increment receiver's balance (Locked)
        users[_to].lockedBalance += _amount;
        emit Transfer(msg.sender, _to, _amount);
    }

    // Function to withdraw tokens from the contract
    function withdrawal(uint256 amount) public nonReentrant afterStartDate {
        uint256 totalBalance = usdt.balanceOf(address(this)); // get the contract's balance
        uint256 userBalance = users[msg.sender].balance;

        require(
            totalBalance >= amount,
            "Insufficient balance for withdrawal in contract"
        );
        require(userBalance >= amount, "Insufficient balance for withdrawal");

        // Decrement sender's balance
        users[msg.sender].balance -= amount;
        require(usdt.transfer(msg.sender, amount), "Error withdrawing");
        emit Withdrawn(msg.sender, amount);
    }

    function claimRaindrops() public nonReentrant afterStartDate {
        require(totalActiveUsersAtDistribution > 0, "No raindrops to claim");
        require(
            lastClaimedDistribution[msg.sender] < currentDistribution,
            "Raindrops already claimed for this distribution"
        );

        uint256 amountPerUser = totalRaindropsToDistribute /
            totalActiveUsersAtDistribution;
        totalRaindropsToDistribute -= amountPerUser; // Update the total amount remaining
        totalActiveUsersAtDistribution--; // Decrease the count of active users

        users[msg.sender].balance += amountPerUser; // Move raindrops to balance

        lastClaimedDistribution[msg.sender] = currentDistribution;

        emit RaindropsClaimed(msg.sender, amountPerUser);
    }

    function daoWithdrawal(uint256 amount) internal {
        uint256 totalBalance = usdt.balanceOf(address(this)); // get the contract's balance

        require(
            totalBalance >= amount,
            "Insufficient balance for withdrawal in contract"
        );

        // Approve the PaymentSplitter contract to spend the specified amount of USDT
        usdt.approve(address(paymentSplitter), amount);

        // Transfer the specified amount to the DAO
        paymentSplitter.depositUSDT(amount);

        paymentSplitter.releaseFundsToAll();

        users[address(paymentSplitter)].balance -= amount;
        emit Withdrawn(address(paymentSplitter), amount);
    }

    function getNextStep(
        address _user
    ) external view returns (StepData memory) {
        uint256 step = users[_user].step;
        uint256 stepsLength = steps.length;
        if (0 == stepsLength) {
            revert("Steps are 0");
        }
        if (step == stepsLength - 1) {
            return steps[step];
        }
        return steps[step + 1];
    }

    function getCostOfSteps(
        address _user,
        uint256 amountOfStepsUp
    ) public view returns (uint256 totalCost) {
        uint256 step = users[_user].step;
        uint256 stepsLength = steps.length;

        for (uint256 i = 0; i < amountOfStepsUp; i++) {
            if (step >= stepsLength - 1) {
                break; // Stop if we've reached the highest step
            }
            totalCost += steps[step + 1].amount; // Add the cost of the next step
            step++;
        }

        return totalCost;
    }

    function getUserStep(
        address _user
    ) external view returns (StepData memory) {
        return steps[users[_user].step];
    }

    function getDao() external view returns (address) {
        return dao;
    }

    function getRaindropsBalance() external view returns (uint) {
        return usdt.balanceOf(address(raindrops));
    }

    function getNode(
        address _user
    ) external view returns (BarnajeTreeHandler.TreeNode memory) {
        BarnajeTreeHandler.TreeNode memory node = treeHandler.getTreeNode(
            _user
        );
        return node;
    }

    function getUserRegistered(
        address _user
    ) external view returns (address[] memory) {
        return users[_user].registered;
    }

    function getUserSponsored(
        address _user
    ) external view returns (address[] memory) {
        return users[_user].sponsored;
    }

    function getUserRaindropBalance() external view returns (uint balance) {
        if (lastClaimedDistribution[msg.sender] == currentDistribution) {
            return 0;
        }

        uint totalRaindrops = totalRaindropsToDistribute;
        uint totalUsers = totalActiveUsersAtDistribution;
        balance = totalRaindrops / totalUsers;
        return balance;
    }

    function getMinSponsoredChild()
        public
        view
        returns (uint minIndex, uint minValue)
    {
        address[] memory referrerChilds = users[users[msg.sender].referred]
            .sponsored;
        uint referrerChildsLength = referrerChilds.length;
        uint[] memory referrerChildsSponsoredLength = new uint[](
            referrerChildsLength
        );
        address referrerChild;

        for (uint i = 0; i < referrerChildsLength; ++i) {
            referrerChild = referrerChilds[i];
            referrerChildsSponsoredLength[i] = users[referrerChild]
                .sponsored
                .length;
        }

        minValue = referrerChildsSponsoredLength[0];

        for (uint i = 0; i < referrerChildsSponsoredLength.length; ++i) {
            if (referrerChildsSponsoredLength[i] < minValue) {
                minValue = referrerChildsSponsoredLength[i];
                minIndex = i;
            }
        }

        return (minIndex, minValue);
    }

    // Function only for genesis before launch
    function completeGenesis() public onlyOwner nonReentrant {
        if (hasGenesis == false) {
            Initialize genesis = new Initialize();
            StepData[] memory stepsData = genesis.generateSteps();

            for (uint256 i = 0; i < stepsData.length; i++) {
                steps.push(stepsData[i]);
            }

            for (uint256 i = 10; i <= 21; i++) {
                if (i >= 10 && i < 13) {
                    maxDonationsPerStep[i] = 12;
                } else if (i >= 13 && i < 16) {
                    maxDonationsPerStep[i] = 16;
                } else if (i >= 16 && i < 19) {
                    maxDonationsPerStep[i] = 18;
                } else if (i >= 19 && i <= 21) {
                    maxDonationsPerStep[i] = 20;
                }
            }

            hasGenesis = true;
        }
    }

    function completeUser(
        address _me,
        string memory _username,
        uint256 _balance,
        uint256 _step,
        uint _donated,
        address _sponsor,
        address _partner,
        address _leftChild,
        address _rightChild
    ) public onlyOwner nonReentrant {
        require(_me != address(0), "User wallet cannot be 0x0");
        require(
            _sponsor != address(0) || _me == dao,
            "Sponsor wallet cannot be 0x0"
        );
        require(
            _partner != address(0) || _me == dao,
            "Partner wallet cannot be 0x0"
        );
        User storage user = users[_me];
        user.username = _username;
        user.balance = _balance;
        user.step = _step;
        user.donated = _donated;
        user.userRegistered = true;
        users[_me].maxSponsored = 4;
        users[_me].sponsor = _sponsor;
        users[_me].referred = _sponsor;
        treeHandler.pushToTreeManually(_me, _partner, _leftChild, _rightChild);
        donatedCount++;
        amountDonated += _donated;
        usernameExists[toLowerCase(_username)] = true;

        if (_sponsor != address(0)) {
            users[_sponsor].sponsored.push(_me);
            users[_sponsor].registered.push(_me);
        }
    }

    function disperseForStepUp(uint _stepup) internal {
        for (uint i = 1; i <= _stepup; i++) {
            users[msg.sender].step = users[msg.sender].step + 1;
            disperseStep(users[msg.sender].step);
        }
    }

    function disperseForRequalification(uint _targetStep) internal {
        disperseStep(_targetStep);
    }

    function disperseStep(uint _step) internal {
        uint stepCost = steps[_step].amount;
        uint floor = _step > 0 ? (_step - 1) / 3 + 1 : 1;

        if (floor == 1) {
            address sponsor = users[msg.sender].sponsor;
            users[sponsor].balance += stepCost;

            if (sponsor == dao) {
                daoWithdrawal(users[dao].balance);
            }

            emit Received(sponsor, msg.sender, stepCost, "SDP");
        } else {
            address memberNFloorsUp = treeHandler.getAncestor(
                msg.sender,
                floor
            );
            uint memberStep;
            uint checkCount = 0;
            while (memberNFloorsUp != dao && checkCount < 3) {
                memberStep = users[memberNFloorsUp].step;

                bool isStepConditionMet = memberStep >= _step;

                FloorConditions memory floorConditions = FloorConditions(
                    floor == 4 && users[memberNFloorsUp].sponsored.length >= 1,
                    floor == 5 && users[memberNFloorsUp].sponsored.length >= 2,
                    floor == 6 && users[memberNFloorsUp].sponsored.length >= 3,
                    floor == 7 && users[memberNFloorsUp].sponsored.length >= 4
                );

                bool isFloorConditionMet = floor < 4 ||
                    floorConditions.isFloorFourConditionMet ||
                    floorConditions.isFloorFiveConditionMet ||
                    floorConditions.isFloorSixConditionMet ||
                    floorConditions.isFloorSevenConditionMet;

                bool stepIsNotAtRequalificationLimit = _step < 10 ||
                    donationsReceivedPerStep[memberNFloorsUp][_step] <
                    maxDonationsPerStep[_step];

                if (
                    !stepIsNotAtRequalificationLimit &&
                    memberNFloorsUp != address(0)
                ) {
                    uint alreadyReceived = donationsReceivedPerStep[
                        memberNFloorsUp
                    ][_step];

                    emit NotEligibleDueToStepRequalification(
                        users[memberNFloorsUp].username,
                        users[msg.sender].username,
                        _step,
                        alreadyReceived
                    );
                }

                if (
                    isStepConditionMet &&
                    isFloorConditionMet &&
                    stepIsNotAtRequalificationLimit
                ) {
                    break;
                } else {
                    memberNFloorsUp = treeHandler.getAncestor(
                        memberNFloorsUp,
                        1
                    );
                    checkCount++;
                }
            }

            if (checkCount == 3 && memberNFloorsUp != dao) {
                memberNFloorsUp = dao;

                users[memberNFloorsUp].balance += stepCost;
                daoWithdrawal(users[dao].balance);

                emit Received(memberNFloorsUp, msg.sender, stepCost, "SDP");
            } else {
                users[memberNFloorsUp].balance += (stepCost / 2);

                if (memberNFloorsUp == dao) {
                    daoWithdrawal(users[dao].balance);
                }

                emit Received(
                    memberNFloorsUp,
                    msg.sender,
                    (stepCost / 2),
                    "SDP"
                );

                donationsReceivedPerStep[memberNFloorsUp][_step]++;

                if (users[memberNFloorsUp].sponsor != address(0)) {
                    address firstGen = users[memberNFloorsUp].sponsor;

                    users[firstGen].balance += (stepCost / 4);

                    if (firstGen == dao) {
                        daoWithdrawal(users[dao].balance);
                    }

                    emit Received(
                        firstGen,
                        msg.sender,
                        stepCost / 4,
                        "1st Gen"
                    );
                } else {
                    users[dao].balance += (stepCost / 4);

                    daoWithdrawal(users[dao].balance);

                    emit Received(dao, msg.sender, (stepCost / 4), "1st Gen");
                }

                if (
                    users[users[memberNFloorsUp].sponsor].sponsor !=
                    address(0) &&
                    checkCount == 0
                ) {
                    address secondGen = users[users[memberNFloorsUp].sponsor]
                        .sponsor;

                    users[secondGen].balance += (stepCost / 4);

                    if (secondGen == dao) {
                        daoWithdrawal(users[dao].balance);
                    }

                    emit Received(
                        secondGen,
                        msg.sender,
                        stepCost / 4,
                        "2nd Gen"
                    );
                } else {
                    users[dao].balance += (stepCost / 4);

                    daoWithdrawal(users[dao].balance);

                    emit Received(dao, msg.sender, (stepCost / 4), "2nd Gen");
                }
            }
        }
    }

    function sponsorSpillover() internal returns (address nodeToStartAt) {
        (uint minIndex, uint minValue) = getMinSponsoredChild();

        // will give refererr sponsorship if their children have hit max too
        if (minValue == users[users[msg.sender].referred].maxSponsored) {
            users[users[msg.sender].referred].maxSponsored++;
            users[users[msg.sender].referred].sponsored.push(msg.sender);
            users[msg.sender].sponsor = users[msg.sender].referred;

            nodeToStartAt = users[msg.sender].referred;
            return nodeToStartAt;
            // otherwise children with min refs gets it
        } else {
            users[users[users[msg.sender].referred].sponsored[minIndex]]
                .sponsored
                .push(msg.sender);
            users[msg.sender].sponsor = users[users[msg.sender].referred]
                .sponsored[minIndex];

            nodeToStartAt = users[users[msg.sender].referred].sponsored[
                minIndex
            ];
            return nodeToStartAt;
        }
    }

    function setSponsor() internal returns (address nodeToStartAt) {
        users[users[msg.sender].referred].sponsored.push(msg.sender);
        users[msg.sender].sponsor = users[msg.sender].referred;

        nodeToStartAt = users[msg.sender].referred;
        return nodeToStartAt;
    }

    function renounceOwnershipToDao() public onlyOwner {
        transferOwnership(dao);
    }

    // Function to recover any ERC20 tokens sent to the contract
    function recoverERC20(
        address tokenAddress,
        uint256 tokenAmount
    ) external onlyOwner {
        require(
            IERC20(tokenAddress).transfer(owner(), tokenAmount),
            "ERC20 Transfer failed"
        );
        emit Recovered(tokenAddress, tokenAmount);
    }

    // Function to recover any Ether sent to the contract
    function recoverETH(uint256 amount) external onlyOwner {
        payable(owner()).transfer(amount);
        emit Recovered(address(0), amount);
    }

    function emitTestEvent() external {
        emit TestEvent("Test event emitted");
    }

    function setStartDate(uint256 _startDate) external onlyOwner {
        startDate = _startDate;
    }

    function setRaindrops(Raindrops _raindrops) external onlyOwner {
        raindrops = _raindrops;
    }

    function distributeRaindrops(uint amount) external {
        require(
            msg.sender == address(raindrops),
            "Only the raindrops contract can call this function"
        );

        totalRaindropsToDistribute = amount;
        totalActiveUsersAtDistribution = donatedCount;

        require(
            totalActiveUsersAtDistribution > 0,
            "No active users to distribute to"
        );

        currentDistribution++;
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/access/Ownable.sol";

contract BarnajeTreeHandler is Ownable {
    struct TreeNode {
        address parent;
        address leftChild;
        address rightChild;
        address[] upline;
    }

    event addNode(address indexed sponsor, address referred, bool isLeft);

    address public dao;

    constructor(address _dao) {
        dao = _dao;
        initDao();
    }

    mapping(address => TreeNode) public tree;

    function initDao() private {
        tree[dao].parent = address(0);
        tree[dao].upline = new address[](0);

        emit addNode(address(0), dao, true);
    }

    function addToTree(
        address _user,
        address _parent
    ) external onlyOwner returns (address _address) {
        // Create and initialize the new node
        tree[_user].upline = tree[_parent].upline;
        tree[_user].upline.push(_parent);

        // BFS to find the first node with available space
        address[] memory queue = new address[](1);
        queue[0] = _parent;
        uint256 front = 0;

        while (front < queue.length) {
            address currentAddress = queue[front];

            // Check if direct children are available
            if (tree[currentAddress].leftChild == address(0)) {
                tree[currentAddress].leftChild = _user;
                tree[_user].parent = currentAddress;
                emit addNode(currentAddress, _user, true);
                return tree[currentAddress].leftChild;
            }
            if (tree[currentAddress].rightChild == address(0)) {
                tree[currentAddress].rightChild = _user;
                tree[_user].parent = currentAddress;
                emit addNode(currentAddress, _user, false);
                return tree[currentAddress].rightChild;
            }

            // The order of these conditions determines the filling order
            if (tree[tree[currentAddress].leftChild].leftChild == address(0)) {
                tree[tree[currentAddress].leftChild].leftChild = _user;
                tree[_user].parent = tree[currentAddress].leftChild;
                emit addNode(tree[currentAddress].leftChild, _user, true);
                return tree[tree[currentAddress].leftChild].leftChild;
            }
            if (tree[tree[currentAddress].rightChild].leftChild == address(0)) {
                tree[tree[currentAddress].rightChild].leftChild = _user;
                tree[_user].parent = tree[currentAddress].rightChild;
                emit addNode(tree[currentAddress].rightChild, _user, true);
                return tree[tree[currentAddress].rightChild].leftChild;
            }
            if (tree[tree[currentAddress].leftChild].rightChild == address(0)) {
                tree[tree[currentAddress].leftChild].rightChild = _user;
                tree[_user].parent = tree[currentAddress].leftChild;
                emit addNode(tree[currentAddress].leftChild, _user, false);
                return tree[tree[currentAddress].leftChild].rightChild;
            }
            if (
                tree[tree[currentAddress].rightChild].rightChild == address(0)
            ) {
                tree[tree[currentAddress].rightChild].rightChild = _user;
                tree[_user].parent = tree[currentAddress].rightChild;
                emit addNode(tree[currentAddress].rightChild, _user, false);
                return tree[tree[currentAddress].rightChild].rightChild;
            }

            // If all spaces are full, we add the children to the queue
            if (tree[currentAddress].leftChild != address(0)) {
                queue = pushAddress(queue, tree[currentAddress].leftChild);
            }
            if (tree[currentAddress].rightChild != address(0)) {
                queue = pushAddress(queue, tree[currentAddress].rightChild);
            }

            front += 1;
        }
    }

    function pushAddress(
        address[] memory arr,
        address addr
    ) private pure returns (address[] memory) {
        address[] memory newArr = new address[](arr.length + 1);
        for (uint256 i = 0; i < arr.length; i++) {
            newArr[i] = arr[i];
        }
        newArr[arr.length] = addr;
        return newArr;
    }

    function getTreeNode(address _addr) external view returns (TreeNode memory) {
        return tree[_addr];
    }

    function pushToTreeManually(
        address _user,
        address _parent,
        address leftChild,
        address rightChild
    ) external onlyOwner {
        tree[_user].upline = tree[_parent].upline;
        tree[_user].upline.push(_parent);
        tree[_user].parent = _parent;
        tree[_user].leftChild = leftChild;
        tree[_user].rightChild = rightChild;
        if (leftChild != address(0)) {
            emit addNode(_user, leftChild, true);
        }
        if (rightChild != address(0)) {
            emit addNode(_user, rightChild, false);
        }
    }

    function getAncestor(
        address _addr,
        uint256 n
    ) external view returns (address) {
        address currentAddress = _addr;
        for (uint256 i = 0; i < n; i++) {
            currentAddress = tree[currentAddress].parent;
            if (currentAddress == address(0)) {
                return address(0); // Return 0 if we've reached the root of the tree
            }
        }
        return currentAddress;
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/access/Ownable.sol";

// import "./model/UserGenesis.sol";
import "./model/StepData.sol";
import "./model/Floor.sol";

contract Initialize is Ownable {
    function convertToUSDT(uint256 baseAmount) internal pure returns (uint256) {
        return baseAmount * 1e18;
    }

    function generateSteps() public view onlyOwner returns (StepData[] memory) {
        StepData[] memory steps = new StepData[](22);
        // Populate the steps array
        steps[0] = StepData({
            amount: convertToUSDT(0),
            step: 0,
            floor: Floor.INIT,
            minimumReferrals: 0
        });
        steps[1] = StepData({
            amount: convertToUSDT(50),
            step: 1,
            floor: Floor.BRONZE,
            minimumReferrals: 0
        });
        steps[2] = StepData({
            amount: convertToUSDT(100),
            step: 2,
            floor: Floor.BRONZE,
            minimumReferrals: 0
        });
        steps[3] = StepData({
            amount: convertToUSDT(200),
            step: 3,
            floor: Floor.BRONZE,
            minimumReferrals: 0
        });
        steps[4] = StepData({
            amount: convertToUSDT(300),
            step: 4,
            floor: Floor.SILVER,
            minimumReferrals: 0
        });
        steps[5] = StepData({
            amount: convertToUSDT(500),
            step: 5,
            floor: Floor.SILVER,
            minimumReferrals: 0
        });
        steps[6] = StepData({
            amount: convertToUSDT(700),
            step: 6,
            floor: Floor.SILVER,
            minimumReferrals: 0
        });
        steps[7] = StepData({
            amount: convertToUSDT(1000),
            step: 7,
            floor: Floor.GOLD,
            minimumReferrals: 0
        });
        steps[8] = StepData({
            amount: convertToUSDT(1400),
            step: 8,
            floor: Floor.GOLD,
            minimumReferrals: 0
        });
        steps[9] = StepData({
            amount: convertToUSDT(1800),
            step: 9,
            floor: Floor.GOLD,
            minimumReferrals: 0
        });
        steps[10] = StepData({
            amount: convertToUSDT(2200),
            step: 10,
            floor: Floor.EMERALD,
            minimumReferrals: 1
        });
        steps[11] = StepData({
            amount: convertToUSDT(2600),
            step: 11,
            floor: Floor.EMERALD,
            minimumReferrals: 1
        });
        steps[12] = StepData({
            amount: convertToUSDT(3000),
            step: 12,
            floor: Floor.EMERALD,
            minimumReferrals: 1
        });
        steps[13] = StepData({
            amount: convertToUSDT(3500),
            step: 13,
            floor: Floor.SAPPHIRE,
            minimumReferrals: 2
        });
        steps[14] = StepData({
            amount: convertToUSDT(4000),
            step: 14,
            floor: Floor.SAPPHIRE,
            minimumReferrals: 2
        });
        steps[15] = StepData({
            amount: convertToUSDT(4500),
            step: 15,
            floor: Floor.SAPPHIRE,
            minimumReferrals: 2
        });
        steps[16] = StepData({
            amount: convertToUSDT(5000),
            step: 16,
            floor: Floor.RUBY,
            minimumReferrals: 3
        });
        steps[17] = StepData({
            amount: convertToUSDT(5500),
            step: 17,
            floor: Floor.RUBY,
            minimumReferrals: 3
        });
        steps[18] = StepData({
            amount: convertToUSDT(6000),
            step: 18,
            floor: Floor.RUBY,
            minimumReferrals: 3
        });
        steps[19] = StepData({
            amount: convertToUSDT(7000),
            step: 19,
            floor: Floor.DIAMOND,
            minimumReferrals: 4
        });
        steps[20] = StepData({
            amount: convertToUSDT(8000),
            step: 20,
            floor: Floor.DIAMOND,
            minimumReferrals: 4
        });
        steps[21] = StepData({
            amount: convertToUSDT(10000),
            step: 21,
            floor: Floor.DIAMOND,
            minimumReferrals: 4
        });
        return steps;
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

enum Floor {
    INIT,
    BRONZE,
    SILVER,
    GOLD,
    EMERALD,
    SAPPHIRE,
    RUBY,
    DIAMOND
}// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./Floor.sol";

struct StepData {
    uint256 amount;
    uint256 step;
    Floor floor;
    uint256 minimumReferrals;
}// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

struct TreeNode {
    address parent;
    address leftChild;
    address rightChild;
    address[] upline;
}// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

struct User {
    uint balance;
    uint lockedBalance;
    uint step;
    uint amountDeposit;
    uint donated;
    uint maxSponsored; // default amount of max sponsored
    address[] registered;
    address[] sponsored;
    address sponsor;
    address referred;
    bool userRegistered;
    string username;
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import "./BarnajeSDP.sol";

using SafeMath for uint256;
using SafeERC20 for IERC20;

contract Raindrops is ReentrancyGuard, Ownable {
    BarnajeSDP public barnajeSDP;
    IERC20 public usdt;

    constructor(BarnajeSDP _barnajeSDP, address _usdtAddress) payable {
        barnajeSDP = _barnajeSDP;
        usdt = IERC20(_usdtAddress);
    }

    function distributeRaindrops() external onlyOwner nonReentrant {
        uint256 totalReceived = usdt.balanceOf(address(this));
        require(totalReceived != 0, "No funds to release");

        usdt.safeTransfer(address(barnajeSDP), totalReceived);

        barnajeSDP.distributeRaindrops(totalReceived);
    }
}
