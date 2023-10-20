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
// OpenZeppelin Contracts (last updated v4.9.0) (access/Ownable2Step.sol)

pragma solidity ^0.8.0;

import "./Ownable.sol";

/**
 * @dev Contract module which provides access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership} and {acceptOwnership}.
 *
 * This module is used through inheritance. It will make available all functions
 * from parent (Ownable).
 */
abstract contract Ownable2Step is Ownable {
    address private _pendingOwner;

    event OwnershipTransferStarted(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Returns the address of the pending owner.
     */
    function pendingOwner() public view virtual returns (address) {
        return _pendingOwner;
    }

    /**
     * @dev Starts the ownership transfer of the contract to a new account. Replaces the pending transfer if there is one.
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual override onlyOwner {
        _pendingOwner = newOwner;
        emit OwnershipTransferStarted(owner(), newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`) and deletes any pending owner.
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual override {
        delete _pendingOwner;
        super._transferOwnership(newOwner);
    }

    /**
     * @dev The new owner accepts the ownership transfer.
     */
    function acceptOwnership() public virtual {
        address sender = _msgSender();
        require(pendingOwner() == sender, "Ownable2Step: caller is not the new owner");
        _transferOwnership(sender);
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (interfaces/IERC1271.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC1271 standard signature validation method for
 * contracts as defined in https://eips.ethereum.org/EIPS/eip-1271[ERC-1271].
 *
 * _Available since v4.1._
 */
interface IERC1271 {
    /**
     * @dev Should return whether the signature provided is valid for the provided data
     * @param hash      Hash of the data to be signed
     * @param signature Signature byte array associated with _data
     */
    function isValidSignature(bytes32 hash, bytes memory signature) external view returns (bytes4 magicValue);
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (proxy/Clones.sol)

pragma solidity ^0.8.0;

/**
 * @dev https://eips.ethereum.org/EIPS/eip-1167[EIP 1167] is a standard for
 * deploying minimal proxy contracts, also known as "clones".
 *
 * > To simply and cheaply clone contract functionality in an immutable way, this standard specifies
 * > a minimal bytecode implementation that delegates all calls to a known, fixed address.
 *
 * The library includes functions to deploy a proxy using either `create` (traditional deployment) or `create2`
 * (salted deterministic deployment). It also includes functions to predict the addresses of clones deployed using the
 * deterministic method.
 *
 * _Available since v3.4._
 */
library Clones {
    /**
     * @dev Deploys and returns the address of a clone that mimics the behaviour of `implementation`.
     *
     * This function uses the create opcode, which should never revert.
     */
    function clone(address implementation) internal returns (address instance) {
        /// @solidity memory-safe-assembly
        assembly {
            // Cleans the upper 96 bits of the `implementation` word, then packs the first 3 bytes
            // of the `implementation` address with the bytecode before the address.
            mstore(0x00, or(shr(0xe8, shl(0x60, implementation)), 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000))
            // Packs the remaining 17 bytes of `implementation` with the bytecode after the address.
            mstore(0x20, or(shl(0x78, implementation), 0x5af43d82803e903d91602b57fd5bf3))
            instance := create(0, 0x09, 0x37)
        }
        require(instance != address(0), "ERC1167: create failed");
    }

    /**
     * @dev Deploys and returns the address of a clone that mimics the behaviour of `implementation`.
     *
     * This function uses the create2 opcode and a `salt` to deterministically deploy
     * the clone. Using the same `implementation` and `salt` multiple time will revert, since
     * the clones cannot be deployed twice at the same address.
     */
    function cloneDeterministic(address implementation, bytes32 salt) internal returns (address instance) {
        /// @solidity memory-safe-assembly
        assembly {
            // Cleans the upper 96 bits of the `implementation` word, then packs the first 3 bytes
            // of the `implementation` address with the bytecode before the address.
            mstore(0x00, or(shr(0xe8, shl(0x60, implementation)), 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000))
            // Packs the remaining 17 bytes of `implementation` with the bytecode after the address.
            mstore(0x20, or(shl(0x78, implementation), 0x5af43d82803e903d91602b57fd5bf3))
            instance := create2(0, 0x09, 0x37, salt)
        }
        require(instance != address(0), "ERC1167: create2 failed");
    }

    /**
     * @dev Computes the address of a clone deployed using {Clones-cloneDeterministic}.
     */
    function predictDeterministicAddress(
        address implementation,
        bytes32 salt,
        address deployer
    ) internal pure returns (address predicted) {
        /// @solidity memory-safe-assembly
        assembly {
            let ptr := mload(0x40)
            mstore(add(ptr, 0x38), deployer)
            mstore(add(ptr, 0x24), 0x5af43d82803e903d91602b57fd5bf3ff)
            mstore(add(ptr, 0x14), implementation)
            mstore(ptr, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73)
            mstore(add(ptr, 0x58), salt)
            mstore(add(ptr, 0x78), keccak256(add(ptr, 0x0c), 0x37))
            predicted := keccak256(add(ptr, 0x43), 0x55)
        }
    }

    /**
     * @dev Computes the address of a clone deployed using {Clones-cloneDeterministic}.
     */
    function predictDeterministicAddress(
        address implementation,
        bytes32 salt
    ) internal view returns (address predicted) {
        return predictDeterministicAddress(implementation, salt, address(this));
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (proxy/utils/Initializable.sol)

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
/**
 * SPDX-License-Identifier: UNLICENSED
 */
pragma solidity 0.8.18;

import '@openzeppelin/contracts/utils/Address.sol';
import '@openzeppelin/contracts/access/Ownable2Step.sol';
import '@openzeppelin/contracts/proxy/Clones.sol';
import '@openzeppelin/contracts/proxy/utils/Initializable.sol';

import './interfaces/IHashflowFactory.sol';
import './interfaces/IHashflowPool.sol';
import './interfaces/IHashflowRouter.sol';

/// @title HashflowFactory
/// @author Victor Ionescu
/// @notice Implementation of IHashflowFactory.
contract HashflowFactory is IHashflowFactory, Ownable2Step, Initializable {
    using Address for address;

    address public router;

    address public _poolImpl;

    mapping(address => bool) public allowedPoolCreators;

    /// @inheritdoc IHashflowFactory
    function initialize(address _router)
        external
        override
        initializer
        onlyOwner
    {
        require(
            _router != address(0),
            'HashflowFactory::initialize Router cannot be 0 address.'
        );
        router = _router;
    }

    /// @inheritdoc IHashflowFactory
    function updatePoolCreatorAuthorization(address poolCreator, bool status)
        external
        override
        onlyOwner
    {
        require(
            poolCreator != address(0),
            'HashflowFactory::updatePoolCreatorAuthorization Pool creator cannot be 0 address.'
        );
        allowedPoolCreators[poolCreator] = status;
        emit UpdatePoolCreatorAuthorization(poolCreator, status);
    }

    /// @inheritdoc IHashflowFactory
    function createPool(string calldata name, address signer)
        external
        override
    {
        require(
            allowedPoolCreators[_msgSender()],
            'HashflowFactory::createPool Not authorized.'
        );

        require(
            router != address(0),
            'HashflowFactory::createPool Router has not been initialized.'
        );

        address newPool = _createPoolInternal(name, signer, _msgSender());

        IHashflowRouter(router).updatePoolAuthorization(newPool, true);

        emit CreatePool(newPool, _msgSender());
    }

    function _createPoolInternal(
        string memory name,
        address signer,
        address operations
    ) internal virtual returns (address) {
        require(
            bytes(name).length > 0,
            'HashflowFactory::_createPoolInternal Name cannot be empty.'
        );
        require(
            _poolImpl != address(0),
            'HasflowFactory::_createPoolInternal Pool implementation not set.'
        );

        address newPool = Clones.clone(_poolImpl);
        IHashflowPool(newPool).initialize(name, signer, operations, router);

        require(
            newPool != address(0),
            'HashflowFactory: new pool is 0 address'
        );

        return newPool;
    }

    /// @inheritdoc IHashflowFactory
    function updatePoolImpl(address poolImpl) external override onlyOwner {
        require(
            poolImpl.isContract(),
            'HashflowFactory::updatePoolImpl Pool Implementation must be a contract.'
        );
        require(
            _poolImpl == address(0),
            'HashflowFactory::updatePoolImpl Pool Implementation cannot be re-initialized.'
        );

        emit UpdatePoolImplementation(poolImpl, _poolImpl);

        _poolImpl = poolImpl;
    }

    /// @dev We do not allow owner to renounce ownership.
    function renounceOwnership() public view override onlyOwner {
        revert('HashflowFactory: Renouncing ownership not allowed.');
    }
}
/**
 * SPDX-License-Identifier: UNLICENSED
 */
pragma solidity >=0.8.0;

import './IQuote.sol';

/// @title IHashflowFactory
/// @author Victor Ionescu
/**
 * @notice The Factory's main purpose is to create HashflowPool contracts. Every
 * Hashflow trade happens within the context of a HashflowPool.
 *
 * The Factory tracks implementation contracts that every instance of HashflowPool,
 * delegates its function calls to.
 *
 * The Factory is configured with an instance of a HashflowRouter contract, which
 * is passed on to pools.
 */
interface IHashflowFactory is IQuote {
    /// @notice Emitted when the owner updates the authorization status of a pool creator
    /// @param poolCreator The wallet to create pools.
    /// @param authorizationStatus Whether the wallet is now authorized to create pools.
    event UpdatePoolCreatorAuthorization(
        address poolCreator,
        bool authorizationStatus
    );

    /// @notice Emitted when a pool is created.
    /// @param pool The address of the newly created pool.
    /// @param operations The Operations key that manages the pool.
    event CreatePool(address pool, address operations);

    /// @notice Emitted when the implementation of the HashflowPool contract changes.
    /// @param poolImpl The address of the new HashflowPool implementation.
    /// @param prevPoolImpl The address of the old HashflowPool implementation.
    event UpdatePoolImplementation(address poolImpl, address prevPoolImpl);

    /// @notice Initializes the Factory.
    /// @param router The Hashflow Router.
    function initialize(address router) external;

    /// @notice Returns the associated Hashflow Router.
    function router() external view returns (address);

    /// @notice Returns where a Pool Creator is authorized to create pools.
    /// @param poolCreator The address of the Pool Creator.
    /// @return Whether the creator is allowed to create pools.
    function allowedPoolCreators(address poolCreator)
        external
        view
        returns (bool);

    /// @notice Updates the authorization status for a Pool Creator.
    /// @param poolCreator The address of the Pool Creator.
    /// @param status The new authorization status.
    function updatePoolCreatorAuthorization(address poolCreator, bool status)
        external;

    /// @notice Creates a HashflowPool smart contract.
    /// @param name Name of the pool.
    /// @param signer The signer key used to validate signatures.
    /// @dev The msg.sender is the operations key that owns and manages the pool.
    function createPool(string calldata name, address signer) external;

    /**
     * @notice Updates the implementation contract that is used to create pools.
     * The update only reflects on pools that are created after this update occurs.
     * The existing pool contracts are not upgradeable.
     */
    /// @param poolImpl The address of the new implementation contract.
    function updatePoolImpl(address poolImpl) external;
}
/**
 * SPDX-License-Identifier: UNLICENSED
 */
pragma solidity >=0.8.0;

import '@openzeppelin/contracts/interfaces/IERC1271.sol';

import './IQuote.sol';

/// @title IHashflowPool
/// @author Victor Ionescu
/**
 * Pool contract used for trading. The Pool can either hold funds or
 * rely on external accounts. External accounts are used in order to preserve
 * Capital Efficiency on the Market Maker side. This way, a Market Maker can
 * make markets using funds that are also used on other venues.
 */
interface IHashflowPool is IQuote, IERC1271 {
    /// @notice Specifies a HashflowPool on a foreign chain.
    struct AuthorizedXChainPool {
        uint16 chainId;
        bytes32 pool;
    }

    /// @notice Contains a signer verification address, and whether trading is enabled.
    struct SignerConfiguration {
        address signer;
        bool enabled;
    }

    /// @notice Emitted when the authorization status of a withdrawal account changes.
    /// @param account The account for which the status changes.
    /// @param authorized The new authorization status.
    event UpdateWithdrawalAccount(address account, bool authorized);

    /// @notice Emitted when the signer key used for the pool has changed.
    /// @param signer The new signer key.
    /// @param prevSigner The old signer key.
    event UpdateSigner(address signer, address prevSigner);

    /// @notice Emitted when liquidity is withdrawn from the pool.
    /// @param token Token being withdrawn.
    /// @param recipient Address receiving the token.
    /// @param withdrawAmount Amount being withdrawn.
    event RemoveLiquidity(
        address token,
        address recipient,
        uint256 withdrawAmount
    );

    /// @notice Emitted when an intra-chain trade happens.
    /// @param trader The trader.
    /// @param effectiveTrader The effective Trader.
    /// @param txid The txid of the quote.
    /// @param baseToken The token the trader sold.
    /// @param quoteToken The token the trader bought.
    /// @param baseTokenAmount The amount of baseToken sold.
    /// @param quoteTokenAmount The amount of quoteToken bought.
    event Trade(
        address trader,
        address effectiveTrader,
        bytes32 txid,
        address baseToken,
        address quoteToken,
        uint256 baseTokenAmount,
        uint256 quoteTokenAmount
    );

    /// @notice Emitted when a cross-chain trade happens.
    /// @param dstChainId The Hashflow Chain ID for the destination chain.
    /// @param dstPool The pool address on the destination chain.
    /// @param trader The trader address.
    /// @param txid The txid of the quote.
    /// @param baseToken The token the trader sold.
    /// @param quoteToken The token the trader bought.
    /// @param baseTokenAmount The amount of baseToken sold.
    /// @param quoteTokenAmount The amount of quoteToken bought.
    event XChainTrade(
        uint16 dstChainId,
        bytes32 dstPool,
        address trader,
        bytes32 dstTrader,
        bytes32 txid,
        address baseToken,
        bytes32 quoteToken,
        uint256 baseTokenAmount,
        uint256 quoteTokenAmount
    );

    /// @notice Emitted when a cross-chain trade is filled.
    /// @param txid The txid identified the quote that was filled.
    event XChainTradeFill(bytes32 txid);

    /// @notice Main initializer.
    /// @param name Name of the pool.
    /// @param signer Signer key used for quote / deposit verification.
    /// @param operations Operations key that governs the pool.
    /// @param router Address of the HashflowRouter contract.
    function initialize(
        string calldata name,
        address signer,
        address operations,
        address router
    ) external;

    /// @notice Returns the pool name.
    function name() external view returns (string memory);

    /// @notice Returns the signer address and whether the pool is enabled.
    function signerConfiguration() external view returns (address, bool);

    /// @notice Returns the Operations address of this pool.
    function operations() external view returns (address);

    /// @notice Returns the Router contract address.
    function router() external view returns (address);

    /// @notice Returns the current nonce for a trader.
    function nonces(address trader) external view returns (uint256);

    /// @notice Removes liquidity from the pool.
    /// @param token Token to withdraw.
    /// @param recipient Address to send token to.
    /// @param amount Amount to withdraw.
    function removeLiquidity(
        address token,
        address recipient,
        uint256 amount
    ) external;

    /// @notice Execute an RFQ-T trade.
    /// @param quote The quote to be executed.
    function tradeRFQT(RFQTQuote memory quote) external payable;

    /// @notice Execute an RFQ-M trade.
    /// @param quote The quote to be executed.
    function tradeRFQM(RFQMQuote memory quote) external;

    /// @notice Execute a cross-chain RFQ-T trade.
    /// @param quote The quote to be executed.
    /// @param trader The account that sends baseToken on this chain.
    function tradeXChainRFQT(XChainRFQTQuote memory quote, address trader)
        external
        payable;

    /// @notice Execute a cross-chain RFQ-M trade.
    /// @param quote The quote to be executed.
    function tradeXChainRFQM(XChainRFQMQuote memory quote) external;

    /// @notice Changes authorization for a set of pools to send X-Chain messages.
    /// @param pools The pools to change authorization status for.
    /// @param authorized The new authorization status.
    function updateXChainPoolAuthorization(
        AuthorizedXChainPool[] calldata pools,
        bool authorized
    ) external;

    /// @notice Changes authorization for an X-Chain Messenger app.
    /// @param xChainMessenger The address of the Messenger app.
    /// @param authorized The new authorization status.
    function updateXChainMessengerAuthorization(
        address xChainMessenger,
        bool authorized
    ) external;

    /// @notice Fills an x-chain order that completed on the source chain.
    /// @param externalAccount The external account to fill from, if any.
    /// @param txid The txid of the quote.
    /// @param trader The trader to receive the funds.
    /// @param quoteToken The token to be sent.
    /// @param quoteTokenAmount The amount of quoteToken to be sent.
    function fillXChain(
        address externalAccount,
        bytes32 txid,
        address trader,
        address quoteToken,
        uint256 quoteTokenAmount
    ) external;

    /// @notice Updates withdrawal account authorization.
    /// @param withdrawalAccounts the accounts for which to update authorization status.
    /// @param authorized The new authorization status.
    function updateWithdrawalAccount(
        address[] memory withdrawalAccounts,
        bool authorized
    ) external;

    /// @notice Updates the signer key.
    /// @param signer The new signer key.
    function updateSigner(address signer) external;

    /// @notice Used by the router to disable pool actions (Trade, Withdraw, Deposit)
    function killswitchOperations(bool enabled) external;

    /// @notice Returns the token reserves for this pool.
    /// @param token The token to check reserves for.
    function getReserves(address token) external view returns (uint256);

    /// @notice Approves a token for spend. Used for 1inch RFQ protocol.
    /// @param token The address of the ERC-20 token.
    /// @param spender The spender address (typically the 1inch RFQ order router)
    /// @param amount The approval amount.
    function approveToken(
        address token,
        address spender,
        uint256 amount
    ) external;

    /// @notice Increases allowance for a token. Used for 1inch RFQ protocol.
    /// @param token The address of the ERC-20 token.
    /// @param spender The spender address (typically the 1inch RFQ order router).
    /// @param amount The approval amount.
    function increaseTokenAllowance(
        address token,
        address spender,
        uint256 amount
    ) external;

    /// @notice Decreases allowance for a token. Used for 1inch RFQ protocol.
    /// @param token The address of the ERC-20 token.
    /// @param spender The spender address (typically the 1inch RFQ order router)
    /// @param amount The approval amount.
    function decreaseTokenAllowance(
        address token,
        address spender,
        uint256 amount
    ) external;
}
/**
 * SPDX-License-Identifier: UNLICENSED
 */
pragma solidity >=0.8.0;

import './IQuote.sol';

/// @title IHashflowRouter
/// @author Victor Ionescu
/**
 * @notice In terms of user-facing functionality, the Router is responsible for:
 * - orchestrating trades
 * - managing cross-chain permissions
 *
 * Every trade requires consent from two parties: the Trader and the Market Maker.
 * However, there are two models to establish consent:
 * - RFQ-T: in this model, the Market Maker provides an EIP-191 signature for the quote,
 *   while the Trader signs the transaction and submits it on-chain
 * - RFQ-M: in this model, the Trader provides an EIP-712 signature for the quote,
 *   the Market Maker provides an EIP-191 signature, and a 3rd party relays the trade.
 *   The 3rd party can be the Market Maker itself.
 *
 * In terms of Hashflow internals, the Router maintains a set of authorized pool
 * contracts that are allowed to be used for trading. This allowlist creates
 * guarantees against malicious behavior, as documented in specific places.
 *
 * The Router contract is not upgradeable. In order to change functionality, a new
 * Router has to be deployed, and new HashflowPool contracts have to be deployed
 * by the Market Makers.
 */
/// @dev Trade / liquidity events are emitted at the HashflowPool level, rather than the router.
interface IHashflowRouter is IQuote {
    /**
     * @notice X-Chain message received from an X-Chain Messenger. This is used by the
     * Router to communicate a fill to a HashflowPool.
     */
    struct XChainFillMessage {
        /// @notice The Hashflow Chain ID of the source chain.
        uint16 srcHashflowChainId;
        /// @notice The address of the HashflowPool on the source chain.
        bytes32 srcPool;
        /// @notice The HashflowPool to disburse funds on the destination chain.
        address dstPool;
        /**
         * @notice The external account linked to the HashflowPool on the destination chain.
         * If the HashflowPool holds funds, this should be bytes32(0).
         */
        address dstExternalAccount;
        /// @notice The recipient of the quoteToken on the destination chain.
        address dstTrader;
        /// @notice The token that the trader buys on the destination chain.
        address quoteToken;
        /// @notice The amount of quoteToken bought.
        uint256 quoteTokenAmount;
        /// @notice Unique identifier for the quote.
        /// @dev Generated off-chain via a distributed UUID generator.
        bytes32 txid;
        /// @notice The caller of the trade function on the source chain.
        bytes32 srcCaller;
        /// @notice The contract to call, if any.
        address dstContract;
        /// @notice The calldata for the contract.
        bytes dstContractCalldata;
    }

    /// @notice Emitted when the authorization status of a pool changes.
    /// @param pool The pool whose status changed.
    /// @param authorized The new auth status.
    event UpdatePoolAuthorizaton(address pool, bool authorized);

    /// @notice Emitted when a sender pool authorization changes.
    /// @param pool Pool address on this chain.
    /// @param otherHashflowChainId Hashflow Chain ID of the other chain.
    /// @param otherChainPool Pool address on the other chain.
    /// @param authorized Whether the pool is authorized.
    event UpdateXChainPoolAuthorization(
        address indexed pool,
        uint16 otherHashflowChainId,
        bytes32 otherChainPool,
        bool authorized
    );

    /// @notice Emitted when the authorization of an x-caller changes.
    /// @param pool Pool address on this chain.
    /// @param otherHashflowChainId Hashflow Chain ID of the other chain.
    /// @param caller Caller address on the other chain.
    /// @param authorized Whether the caller is authorized.
    event UpdateXChainCallerAuthorization(
        address indexed pool,
        uint16 otherHashflowChainId,
        bytes32 caller,
        bool authorized
    );

    /// @notice Emitted when the authorization status of an X-Chain Messenger changes for a pool.
    /// @param pool Pool address for which the Messenger authorization changes.
    /// @param xChainMessenger Address of the Messenger.
    /// @param authorized Whether the X-Chain Messenger is authorized.
    event UpdateXChainMessengerAuthorization(
        address indexed pool,
        address xChainMessenger,
        bool authorized
    );

    /// @notice Emitted when the authorized status of an X-Chain Messenger changes for a callee.
    /// @param callee Address of the callee.
    /// @param xChainMessenger Address of the Messenger.
    /// @param authorized Whether the X-Chain Messenger is authorized.
    event UpdateXChainMessengerCallerAuthorization(
        address indexed callee,
        address xChainMessenger,
        bool authorized
    );

    /// @notice Emitted when the Limit Order Guardian address is updated.
    /// @param guardian The new Guardian address.
    event UpdateLimitOrderGuardian(address guardian);

    /// @notice Initializes the Router. Called one time.
    /// @param factory The address of the HashflowFactory contract.
    function initialize(address factory) external;

    /// @notice Returns the address of the associated HashflowFactor contract.
    function factory() external view returns (address);

    function authorizedXChainPools(
        bytes32 dstPool,
        uint16 srcHChainId,
        bytes32 srcPool
    ) external view returns (bool);

    function authorizedXChainCallers(
        address dstContract,
        uint16 srcHashflowChainId,
        bytes32 caller
    ) external view returns (bool);

    function authorizedXChainMessengersByPool(address pool, address messenger)
        external
        view
        returns (bool);

    function authorizedXChainMessengersByCallee(
        address callee,
        address messenger
    ) external view returns (bool);

    /// @notice Executes an intra-chain RFQ-T trade.
    /// @param quote The quote data to be executed.
    function tradeRFQT(RFQTQuote memory quote) external payable;

    /// @notice Executes an intra-chain RFQ-T trade, leveraging an ERC-20 permit.
    /// @param quote The quote data to be executed.
    /// @dev Does not support native tokens for the baseToken.
    function tradeRFQTWithPermit(
        RFQTQuote memory quote,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s,
        uint256 amountToApprove
    ) external;

    /// @notice Executes an intra-chain RFQ-T trade.
    /// @param quote The quote to be executed.
    function tradeRFQM(RFQMQuote memory quote) external;

    /// @notice Executes an intra-chain RFQ-T trade, leveraging an ERC-20 permit.
    /// @param quote The quote to be executed.
    /// @param deadline The deadline of the ERC-20 permit.
    /// @param v v-part of the signature.
    /// @param r r-part of the signature.
    /// @param s s-part of the signature.
    /// @param amountToApprove The amount being approved.
    function tradeRFQMWithPermit(
        RFQMQuote memory quote,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s,
        uint256 amountToApprove
    ) external;

    /// @notice Executes an intra-chain RFQ-T trade.
    /// @param quote The quote to be executed.
    /// @param guardianSignature A signature issued by the Limit Order Guardian.
    function tradeRFQMLimitOrder(
        RFQMQuote memory quote,
        bytes memory guardianSignature
    ) external;

    /// @notice Executes an intra-chain RFQ-T trade, leveraging an ERC-20 permit.
    /// @param quote The quote to be executed.
    /// @param guardianSignature A signature issued by the Limit Order Guardian.
    /// @param deadline The deadline of the ERC-20 permit.
    /// @param v v-part of the signature.
    /// @param r r-part of the signature.
    /// @param s s-part of the signature.
    /// @param amountToApprove The amount being approved.
    function tradeRFQMLimitOrderWithPermit(
        RFQMQuote memory quote,
        bytes memory guardianSignature,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s,
        uint256 amountToApprove
    ) external;

    /// @notice Executes an RFQ-T cross-chain trade.
    /// @param quote The quote to be executed.
    /// @param dstContract The address of the contract to be called on the destination chain.
    /// @param dstCalldata The calldata for the smart contract call.
    function tradeXChainRFQT(
        XChainRFQTQuote memory quote,
        bytes32 dstContract,
        bytes memory dstCalldata
    ) external payable;

    /// @notice Executes an RFQ-T cross-chain trade, leveraging an ERC-20 permit.
    /// @param quote The quote to be executed.
    /// @param dstContract The address of the contract to be called on the destination chain.
    /// @param dstCalldata The calldata for the smart contract call.
    /// @param deadline The deadline of the ERC-20 permit.
    /// @param v v-part of the signature.
    /// @param r r-part of the signature.
    /// @param s s-part of the signature.
    /// @param amountToApprove The amount being approved.
    function tradeXChainRFQTWithPermit(
        XChainRFQTQuote memory quote,
        bytes32 dstContract,
        bytes memory dstCalldata,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s,
        uint256 amountToApprove
    ) external payable;

    /// @notice Executes an RFQ-M cross-chain trade.
    /// @param quote The quote to be executed.
    /// @param dstContract The address of the contract to be called on the destination chain.
    /// @param dstCalldata The calldata for the smart contract call.
    function tradeXChainRFQM(
        XChainRFQMQuote memory quote,
        bytes32 dstContract,
        bytes memory dstCalldata
    ) external payable;

    /// @notice Similar to tradeXChainRFQm, but includes a spend permit for the baseToken.
    /// @param quote The quote to be executed.
    /// @param dstContract The address of the contract to be called on the destination chain.
    /// @param dstCalldata The calldata for the smart contract call.
    /// @param deadline The deadline of the ERC-20 permit.
    /// @param v v-part of the signature.
    /// @param r r-part of the signature.
    /// @param s s-part of the signature.
    /// @param amountToApprove The amount to approve.
    function tradeXChainRFQMWithPermit(
        XChainRFQMQuote memory quote,
        bytes32 dstContract,
        bytes memory dstCalldata,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s,
        uint256 amountToApprove
    ) external payable;

    /// @notice Completes the second leg of a cross-chain trade.
    /// @param fillMessage Payload containing information necessary to complete the trade.
    function fillXChain(XChainFillMessage memory fillMessage) external;

    /// @notice Returns whether the pool is authorized for trading.
    /// @param pool The address of the HashflowPool.
    function authorizedPools(address pool) external view returns (bool);

    /// @notice Allows the owner to unauthorize a potentially compromised pool. Cannot be reverted.
    /// @param pool The address of the HashflowPool.
    function forceUnauthorizePool(address pool) external;

    /// @notice Authorizes a HashflowPool for trading.
    /// @dev Can only be called by the HashflowFactory or the admin.
    function updatePoolAuthorization(address pool, bool authorized) external;

    /// @notice Updates the authorization status of an X-Chain pool pair.
    /// @param otherHashflowChainId The Hashflow Chain ID of the peer chain.
    /// @param otherPool The 32-byte representation of the Pool address on the peer chain.
    /// @param authorized Whether the pool is authorized to communicate with the sender pool.
    function updateXChainPoolAuthorization(
        uint16 otherHashflowChainId,
        bytes32 otherPool,
        bool authorized
    ) external;

    /// @notice Updates the authorization status of an X-Chain caller.
    /// @param otherHashflowChainId The Hashflow Chain ID of the peer chain.
    /// @param caller The caller address.
    /// @param authorized Whether the caller is authorized to send an x-call to the sender pool.
    function updateXChainCallerAuthorization(
        uint16 otherHashflowChainId,
        bytes32 caller,
        bool authorized
    ) external;

    /// @notice Updates the authorization status of an X-Chain Messenger app.
    /// @param xChainMessenger The address of the Messenger App.
    /// @param authorized The new authorization status.
    function updateXChainMessengerAuthorization(
        address xChainMessenger,
        bool authorized
    ) external;

    /// @notice Updates the authorization status of an X-Chain Messenger app.
    /// @param xChainMessenger The address of the Messenger App.
    /// @param authorized The new authorization status.
    function updateXChainMessengerCallerAuthorization(
        address xChainMessenger,
        bool authorized
    ) external;

    /// @notice Used to stop all operations on a pool, in case of an emergency.
    /// @param pool The address of the HashflowPool.
    /// @param enabled Whether the pool is enabled.
    function killswitchPool(address pool, bool enabled) external;

    /// @notice Used to update the Limit Order Guardian.
    /// @param guardian The address of the new Guardian.
    function updateLimitOrderGuardian(address guardian) external;

    /// @notice Allows the owner to withdraw excess funds from the Router.
    /// @dev Under normal operations, the Router should not have excess funds.
    function withdrawFunds(address token) external;
}
/**
 * SPDX-License-Identifier: UNLICENSED
 */
pragma solidity >=0.8.0;

/// @title IQuote
/// @author Victor Ionescu
/**
 * @notice Interface for quote structs used for trading. There are two major types of trades:
 * - intra-chain: atomic transactions within one chain
 * - cross-chain: multi-leg transactions between two chains, which utilize interoperability protocols
 *                such as Wormhole.
 *
 * Separately, there are two trading modes:
 * - RFQ-T: the trader signs the transaction, the market maker signs the quote
 * - RFQ-M: both the trader and Market Maker sign the quote, any relayer can sign the transaction
 */
interface IQuote {
    /// @notice Used for intra-chain RFQ-T trades.
    struct RFQTQuote {
        /// @notice The address of the HashflowPool to trade against.
        address pool;
        /**
         * @notice The external account linked to the HashflowPool.
         * If the HashflowPool holds funds, this should be address(0).
         */
        address externalAccount;
        /// @notice The recipient of the quoteToken at the end of the trade.
        address trader;
        /**
         * @notice The account "effectively" making the trade (ultimately receiving the funds).
         * This is commonly used by aggregators, where a proxy contract (the 'trader')
         * receives the quoteToken, and the effective trader is the user initiating the call.
         *
         * This field DOES NOT influence movement of funds. However, it is used to check against
         * quote replay.
         */
        address effectiveTrader;
        /// @notice The token that the trader sells.
        address baseToken;
        /// @notice The token that the trader buys.
        address quoteToken;
        /**
         * @notice The amount of baseToken sold in this trade. The exchange rate
         * is going to be preserved as the quoteTokenAmount / baseTokenAmount ratio.
         *
         * Most commonly, effectiveBaseTokenAmount will == baseTokenAmount.
         */
        uint256 effectiveBaseTokenAmount;
        /// @notice The max amount of baseToken sold.
        uint256 baseTokenAmount;
        /// @notice The amount of quoteToken bought when baseTokenAmount is sold.
        uint256 quoteTokenAmount;
        /// @notice The Unix timestamp (in seconds) when the quote expires.
        /// @dev This gets checked against block.timestamp.
        uint256 quoteExpiry;
        /// @notice The nonce used by this effectiveTrader. Nonces are used to protect against replay.
        uint256 nonce;
        /// @notice Unique identifier for the quote.
        /// @dev Generated off-chain via a distributed UUID generator.
        bytes32 txid;
        /// @notice Signature provided by the market maker (EIP-191).
        bytes signature;
    }

    /// @notice Used for intra-chain RFQ-M trades.
    struct RFQMQuote {
        /// @notice The address of the HashflowPool to trade against.
        address pool;
        /**
         * @notice The external account linked to the HashflowPool.
         * If the HashflowPool holds funds, this should be address(0).
         */
        address externalAccount;
        /// @notice The account that will be debited baseToken / credited quoteToken.
        address trader;
        /// @notice The token that the trader sells.
        address baseToken;
        /// @notice The token that the trader buys.
        address quoteToken;
        /// @notice The amount of baseToken sold.
        uint256 baseTokenAmount;
        /// @notice The amount of quoteToken bought.
        uint256 quoteTokenAmount;
        /// @notice The Unix timestamp (in seconds) when the quote expires.
        /// @dev This gets checked against block.timestamp.
        uint256 quoteExpiry;
        /// @notice Unique identifier for the quote.
        /// @dev Generated off-chain via a distributed UUID generator.
        bytes32 txid;
        /// @notice Signature provided by the trader (EIP-712).
        bytes takerSignature;
        /// @notice Signature provided by the market maker (EIP-191).
        bytes makerSignature;
    }

    /// @notice Used for cross-chain RFQ-T trades.
    struct XChainRFQTQuote {
        /// @notice The Hashflow Chain ID of the source chain.
        uint16 srcChainId;
        /// @notice The Hashflow Chain ID of the destination chain.
        uint16 dstChainId;
        /// @notice The address of the HashflowPool to trade against on the source chain.
        address srcPool;
        /// @notice The HashflowPool to disburse funds on the destination chain.
        /// @dev This is bytes32 in order to anticipate non-EVM chains.
        bytes32 dstPool;
        /**
         * @notice The external account linked to the HashflowPool on the source chain.
         * If the HashflowPool holds funds, this should be address(0).
         */
        address srcExternalAccount;
        /**
         * @notice The external account linked to the HashflowPool on the destination chain.
         * If the HashflowPool holds funds, this should be bytes32(0).
         */
        bytes32 dstExternalAccount;
        /// @notice The recipient of the quoteToken on the destination chain.
        bytes32 dstTrader;
        /// @notice The token that the trader sells on the source chain.
        address baseToken;
        /// @notice The token that the trader buys on the destination chain.
        bytes32 quoteToken;
        /**
         * @notice The amount of baseToken sold in this trade. The exchange rate
         * is going to be preserved as the quoteTokenAmount / baseTokenAmount ratio.
         *
         * Most commonly, effectiveBaseTokenAmount will == baseTokenAmount.
         */
        uint256 effectiveBaseTokenAmount;
        /// @notice The amount of baseToken sold.
        uint256 baseTokenAmount;
        /// @notice The amount of quoteToken bought.
        uint256 quoteTokenAmount;
        /**
         * @notice The Unix timestamp (in seconds) when the quote expire. Only enforced
         * on the source chain.
         */
        /// @dev This gets checked against block.timestamp.
        uint256 quoteExpiry;
        /// @notice The nonce used by this trader.
        uint256 nonce;
        /// @notice Unique identifier for the quote.
        /// @dev Generated off-chain via a distributed UUID generator.
        bytes32 txid;
        /**
         * @notice The address of the IHashflowXChainMessenger contract used for
         * cross-chain communication.
         */
        address xChainMessenger;
        /// @notice Signature provided by the market maker (EIP-191).
        bytes signature;
    }

    /// @notice Used for Cross-Chain RFQ-M trades.
    struct XChainRFQMQuote {
        /// @notice The Hashflow Chain ID of the source chain.
        uint16 srcChainId;
        /// @notice The Hashflow Chain ID of the destination chain.
        uint16 dstChainId;
        /// @notice The address of the HashflowPool to trade against on the source chain.
        address srcPool;
        /// @notice The HashflowPool to disburse funds on the destination chain.
        /// @dev This is bytes32 in order to anticipate non-EVM chains.
        bytes32 dstPool;
        /**
         * @notice The external account linked to the HashflowPool on the source chain.
         * If the HashflowPool holds funds, this should be address(0).
         */
        address srcExternalAccount;
        /**
         * @notice The external account linked to the HashflowPool on the destination chain.
         * If the HashflowPool holds funds, this should be bytes32(0).
         */
        bytes32 dstExternalAccount;
        /// @notice The account that will be debited baseToken on the source chain.
        address trader;
        /// @notice The recipient of the quoteToken on the destination chain.
        bytes32 dstTrader;
        /// @notice The token that the trader sells on the source chain.
        address baseToken;
        /// @notice The token that the trader buys on the destination chain.
        bytes32 quoteToken;
        /// @notice The amount of baseToken sold.
        uint256 baseTokenAmount;
        /// @notice The amount of quoteToken bought.
        uint256 quoteTokenAmount;
        /**
         * @notice The Unix timestamp (in seconds) when the quote expire. Only enforced
         * on the source chain.
         */
        /// @dev This gets checked against block.timestamp.
        uint256 quoteExpiry;
        /// @notice Unique identifier for the quote.
        /// @dev Generated off-chain via a distributed UUID generator.
        bytes32 txid;
        /**
         * @notice The address of the IHashflowXChainMessenger contract used for
         * cross-chain communication.
         */
        address xChainMessenger;
        /// @notice Signature provided by the trader (EIP-712).
        bytes takerSignature;
        /// @notice Signature provided by the market maker (EIP-191).
        bytes makerSignature;
    }
}
