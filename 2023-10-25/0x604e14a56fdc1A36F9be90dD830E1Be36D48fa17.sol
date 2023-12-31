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
// OpenZeppelin Contracts (last updated v4.8.0) (access/Ownable2Step.sol)

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
    function acceptOwnership() external {
        address sender = _msgSender();
        require(pendingOwner() == sender, "Ownable2Step: caller is not the new owner");
        _transferOwnership(sender);
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (proxy/Clones.sol)

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
    function predictDeterministicAddress(address implementation, bytes32 salt)
        internal
        view
        returns (address predicted)
    {
        return predictDeterministicAddress(implementation, salt, address(this));
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
// OpenZeppelin Contracts (last updated v4.8.0) (utils/cryptography/ECDSA.sol)

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
    function tryRecover(
        bytes32 hash,
        bytes32 r,
        bytes32 vs
    ) internal pure returns (address, RecoverError) {
        bytes32 s = vs & bytes32(0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff);
        uint8 v = uint8((uint256(vs) >> 255) + 27);
        return tryRecover(hash, v, r, s);
    }

    /**
     * @dev Overload of {ECDSA-recover} that receives the `r and `vs` short-signature fields separately.
     *
     * _Available since v4.2._
     */
    function recover(
        bytes32 hash,
        bytes32 r,
        bytes32 vs
    ) internal pure returns (address) {
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
    function tryRecover(
        bytes32 hash,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal pure returns (address, RecoverError) {
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
    function recover(
        bytes32 hash,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal pure returns (address) {
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
    function toEthSignedMessageHash(bytes32 hash) internal pure returns (bytes32) {
        // 32 is the length in bytes of hash,
        // enforced by the type signature above
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
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
    function toTypedDataHash(bytes32 domainSeparator, bytes32 structHash) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19\x01", domainSeparator, structHash));
    }
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
pragma solidity 0.8.18;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IToken is IERC20 {
    function initialize(string memory name_, string memory symbol_) external;

    function mint(address to_, uint256 amount_) external;
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

import "@openzeppelin/contracts/access/Ownable2Step.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/proxy/Clones.sol";
import "./utils/EIP712Custom.sol";
import "./utils/DeployTokenHasher.sol";
import "./utils/MintTokenHasher.sol";
import "./IToken.sol";

/// @title Token Controller, mint and manage Token
contract TokenCtrl is
    Ownable2Step,
    EIP712Custom,
    DeployTokenHasher,
    MintTokenHasher
{
    using Counters for Counters.Counter;
    using Address for address;

    // properties
    // token symbol to address mapping
    mapping(bytes32 => address) public tokens;
    // token nonces
    mapping(bytes32 => Counters.Counter) private _nonces;
    // token lists
    bytes32[] public tokenLists;
    // authorities
    mapping(address => bool) public authorities;
    // token template
    address public tokenTemplate;

    // events
    event DeployToken(
        address indexed tokenAddress,
        address indexed authority,
        address sender,
        bytes32 symbol
    );

    event MintToken(
        address indexed tokenAddress,
        address indexed authority,
        address indexed destination,
        uint256 amount,
        address sender,
        bytes32 symbol
    );

    event ChangeTokenController(
        address indexed tokenAddress,
        address indexed newController,
        address sender,
        bytes32 symbol
    );

    event EnlistToken(
        address indexed tokenAddress,
        address sender,
        bytes32 symbol
    );

    event DelistToken(
        address indexed tokenAddress,
        address sender,
        bytes32 symbol
    );

    event SetAuthority(
        address indexed authority,
        address sender,
        bool isAuthority
    );

    event SetTokenTemplate(
        address indexed tokenTemplate,
        address indexed previousTokenTemplate,
        address sender
    );

    // modifier
    modifier onlyAuthority() {
        require(authorities[_msgSender()], "ONLY_AUTHORITY: unauthorized");
        _;
    }

    constructor(
        address authority_,
        address tokenTemplate_
    ) EIP712Custom("TokenCtrl", "1") {
        //  set authority
        _setAuthority(authority_);

        // set token Template address
        _setTokenTemplate(tokenTemplate_);
    }

    // external functions

    /// Deploy new Token with EIP-712 signature, signer must be **authority**
    /// @param params_ DeployTokenParams of token to be deployed
    /// @param v_ V value of a signature
    /// @param r_ R value of a signature
    /// @param s_ S value of a signature
    function deployToken(
        DeployTokenParam calldata params_,
        uint8 v_,
        bytes32 r_,
        bytes32 s_
    ) external {
        // verify deadline
        // 15-second rule: deadline is about an hour, it is safe to use block.timestamp
        // slither-disable-next-line timestamp
        require(
            block.timestamp <= params_.deadline,
            "DEPLOY_TOKEN: expired deadline"
        );

        bytes32 symbol32 = _stringToBytes32(params_.symbol);
        // token must not be already deployed
        require(
            _getTokenAddress(symbol32) == address(0),
            "DEPLOY_TOKEN: token already deployed"
        );

        // find parameters by chainId
        EvmDeployToken memory dt = EvmDeployToken(address(0), 0, 0);
        for (uint256 i = 0; i < params_.deployTokens.length; i++) {
            if (params_.deployTokens[i].chainId == block.chainid) {
                dt = params_.deployTokens[i];
            }
        }
        require(dt.chainId != 0, "DEPLOY_TOKEN: chain id not match");

        // verify contract address
        require(
            dt.contractAddress == address(this),
            "DEPLOY_TOKEN: mismatch contract address"
        );

        // check nonce, to prevent replay attack
        require(
            dt.nonce == _useNonces(symbol32),
            "DEPLOY_TOKEN: invalid nonce"
        );

        // verify signer of the signature
        bytes32 structHash = _hashDeployTokenStruct(params_);
        address signer = _recoverSigner(structHash, v_, r_, s_);
        require(authorities[signer], "DEPLOY_TOKEN: unauthorized");

        // deploy token
        address tokenAddress = Clones.clone(tokenTemplate);

        _registerToken(symbol32, tokenAddress);

        // emit event
        emit DeployToken(tokenAddress, signer, _msgSender(), symbol32);

        // initialize token
        IToken(tokenAddress).initialize(params_.name, params_.symbol);
    }

    /// Mint Tokens with EIP-712 signature, signer must be **authority**
    /// @param params_ MintTokenParams of token to be minted
    /// @param v_ V value of a signature
    /// @param r_ R value of a signature
    /// @param s_ S value of a signature
    function mintToken(
        MintTokenParams calldata params_,
        uint8 v_,
        bytes32 r_,
        bytes32 s_
    ) external {
        // verify deadline
        // 15-second rule: deadline is about an hour, it is safe to use block.timestamp
        // slither-disable-next-line timestamp
        require(
            block.timestamp <= params_.deadline,
            "MINT_TOKEN: expired deadline"
        );

        bytes32 symbol32 = _stringToBytes32(params_.symbol);
        address tokenAddress = _getTokenAddress(symbol32);
        require(tokenAddress != address(0), "MINT_TOKEN: token not found");

        // find parameters by chainId
        EvmMintDestination memory dt = EvmMintDestination(address(0), 0, 0);
        for (uint256 i = 0; i < params_.destinations.length; i++) {
            if (params_.destinations[i].chainId == block.chainid) {
                dt = params_.destinations[i];
            }
        }
        require(dt.chainId != 0, "MINT_TOKEN: chain id not match");

        // verify contract address
        require(
            dt.contractAddress == address(this),
            "MINT_TOKEN: mismatch contract address"
        );

        // verify token nonce, to prevent replay attack
        require(dt.nonce == _useNonces(symbol32), "MINT_TOKEN: invalid nonce");

        // verify signer of the signature
        bytes32 structHash = _hashMintTokenStruct(params_);
        address signer = _recoverSigner(structHash, v_, r_, s_);
        require(authorities[signer], "MINT_TOKEN: unauthorized");

        // emit event
        emit MintToken(
            tokenAddress,
            signer, // authority
            signer, // mint to
            params_.amount,
            _msgSender(), // sender
            symbol32
        );

        // mint token
        IToken(tokenAddress).mint(signer, params_.amount);
    }

    /// Change token controller, caller must be **authority**
    /// @param symbol_ Symbol of the token
    /// @param newController_ New controller to be assgined to
    function changeTokenController(
        string calldata symbol_,
        address newController_
    ) external onlyAuthority {
        // new controller address must not empty
        require(
            newController_ != address(0),
            "CHANGE_TOKEN_CONTROLLER: new controller is empty"
        );

        bytes32 symbol32 = _stringToBytes32(symbol_);
        address tokenAddress = _getTokenAddress(symbol32);
        // verify token symbol exists
        require(
            tokenAddress != address(0),
            "CHANGE_TOKEN_CONTROLLER: token not found"
        );

        // bump token nonce
        _useNonces(symbol32);

        // emit event
        emit ChangeTokenController(
            tokenAddress,
            newController_,
            _msgSender(),
            symbol32
        );

        // change token controller
        _doChangeTokenController(tokenAddress, newController_);
    }

    /// Enlist token deployed from other controller, caller must be **authority**
    /// @param symbol_ Symbol of the token
    /// @param tokenAddress_ Token address to be added
    /// @dev token's ownership must be transfered before enlisting the token
    function enlistToken(
        string calldata symbol_,
        address tokenAddress_
    ) external onlyAuthority {
        bytes32 symbol32 = _stringToBytes32(symbol_);
        // verify token symbol exists
        require(
            tokens[symbol32] == address(0),
            "ENLIST_TOKEN: token already exists"
        );

        // token address must not be empty
        require(tokenAddress_ != address(0), "ENLIST_TOKEN: address is empty");

        // token owner must be this controller
        require(
            Ownable(tokenAddress_).owner() == address(this),
            "ENLIST_TOKEN: token is not owned by the controller"
        );

        // bump token nonce
        _useNonces(symbol32);

        // register token
        _registerToken(symbol32, tokenAddress_);

        emit EnlistToken(tokenAddress_, _msgSender(), symbol32);
    }

    /// Delist token from the controller, caller must be **authority**
    /// @param symbol_ Symbol of the token
    function delistToken(string calldata symbol_) external onlyAuthority {
        bytes32 symbol32 = _stringToBytes32(symbol_);
        address tokenAddress = tokens[symbol32];
        require(tokenAddress != address(0), "DELIST_TOKEN: token not found");

        // bump token nonce
        _useNonces(symbol32);

        // unregister token
        _unregisterToken(symbol32);

        emit DelistToken(tokenAddress, _msgSender(), symbol32);
    }

    /// Set authority address of this controller, caller must be **owner**
    /// @param authority_ New authority
    function setAuthority(address authority_) external onlyOwner {
        _setAuthority(authority_);
    }

    /// Remove authority address from this controller, caller must be **owner**
    /// @param authority_ Authority to be removed
    function removeAuthority(address authority_) external onlyOwner {
        require(authorities[authority_], "REMOVE_AUTHORITY: not authority");
        authorities[authority_] = false;

        emit SetAuthority(authority_, _msgSender(), false);
    }

    function transferOwnership(address newOwner) public override onlyOwner {
        // new owner must not be authority
        require(
            !authorities[newOwner],
            "TRANSFER_OWNERSHIP: new owner is already be an authority"
        );
        super.transferOwnership(newOwner);
    }

    /// Set token token template, caller must be **owner**
    /// @param tokenTemplate_ Address of token template
    function setTokenTemplate(address tokenTemplate_) external onlyOwner {
        _setTokenTemplate(tokenTemplate_);
    }

    /// Get token address by symbol
    /// @param symbol_ Symbol of the token
    function getTokenAddress(
        string memory symbol_
    ) external view returns (address) {
        bytes32 symbol32 = _stringToBytes32(symbol_);
        return _getTokenAddress(symbol32);
    }

    /// Get current token nonce by symbol
    /// @param symbol_ Symbol of the token
    function getNonces(string memory symbol_) external view returns (uint256) {
        bytes32 symbol32 = _stringToBytes32(symbol_);
        return _nonces[symbol32].current();
    }

    /// Get symbol of token registered with this controller
    function getTokenLists() external view returns (bytes32[] memory) {
        return tokenLists;
    }

    // private functions
    function _getTokenAddress(
        bytes32 symbol32_
    ) private view returns (address) {
        return tokens[symbol32_];
    }

    function _registerToken(bytes32 symbol32_, address tokenAddress_) private {
        tokens[symbol32_] = tokenAddress_;
        tokenLists.push(symbol32_);
    }

    function _unregisterToken(bytes32 symbol32_) private {
        delete tokens[symbol32_];
        // intentional not to clear nonce, as it may lead to replay attack

        uint256 len = tokenLists.length;
        if (
            (len == 1 && tokenLists[0] == symbol32_) ||
            tokenLists[len - 1] == symbol32_
        ) {
            // one item and matches
            // or being last item
            tokenLists.pop();
        } else {
            // find item index
            for (uint i = 0; i < len - 1; i++) {
                if (tokenLists[i] == symbol32_) {
                    // swap item from last index
                    tokenLists[i] = tokenLists[len - 1];
                    break;
                }
            }
            tokenLists.pop();
        }
    }

    function _doChangeTokenController(
        address tokenAddress_,
        address newController_
    ) private {
        Ownable(tokenAddress_).transferOwnership(newController_);
    }

    function _useNonces(bytes32 symbol32_) private returns (uint256 current_) {
        // return current nonce and then increment
        Counters.Counter storage nonce = _nonces[symbol32_];
        current_ = nonce.current();
        nonce.increment();
    }

    function _setAuthority(address authority_) private {
        require(authority_ != address(0), "SET_AUTHORITY: authority is empty");
        // new authority must not be owner or pending owner
        require(
            authority_ != owner() && authority_ != pendingOwner(),
            "SET_AUTHORITY: owner cannot be authority"
        );
        // revert if already be authroity
        require(
            !authorities[authority_],
            "SET_AUTHORITY: already be authority"
        );
        authorities[authority_] = true;

        emit SetAuthority(authority_, _msgSender(), true);
    }

    function _setTokenTemplate(address tokenTemplate_) private {
        // token template must be zero
        require(
            tokenTemplate_ != address(0),
            "SET_TOKEN_TEMPLATE: token template is zero"
        );
        // token template must be a contract
        require(
            tokenTemplate_.isContract(),
            "SET_TOKEN_TEMPLATE: token template is not a contract"
        );

        address previousTokenTemplate = tokenTemplate;
        tokenTemplate = tokenTemplate_;

        emit SetTokenTemplate(
            tokenTemplate_,
            previousTokenTemplate,
            _msgSender()
        );
    }

    // utilities funcitons
    function _stringToBytes32(
        string memory source_
    ) private pure returns (bytes32 result_) {
        result_ = bytes32(abi.encodePacked(source_));
    }
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

/// @title Deploy Token Hasher
abstract contract DeployTokenHasher {
    // keccak256("DeployToken(string name,string symbol,EvmDeployToken[] deployTokens,StellarDeployToken stellarDeployToken,uint256 deadline)EvmDeployToken(address contractAddress,uint256 chainId,uint256 nonce)StellarDeployToken(string asset,string authority,uint256 sequenceNo)");
    bytes32 private constant _DEPLOY_TOKEN_TYPEHASH =
        0xb0d684284bab62fd5887a7ff9bf55a567a90e78b8a82f543d2d7aad12f721eb7;

    // keccak256("EvmDeployToken(address contractAddress,uint256 chainId,uint256 nonce)");
    bytes32 private constant _EVM_DEPLOY_TOKEN_TYPEHASH =
        0x16be7e703a5ec19023dc1f99e6b1b464b2e71aefd0c9b6e791b34f20755bdd6f;

    // keccak256("StellarDeployToken(string asset,string authority,uint256 sequenceNo)");
    bytes32 private constant _STELLAR_DEPLOY_TOKEN_TYPEHASH =
        0xc7036020acece1e4e42197d1db5470d4a8c7b7c4071b1b01e6c2e3a007fde9d5;

    struct EvmDeployToken {
        address contractAddress;
        uint256 chainId;
        uint256 nonce;
    }

    struct StellarDeployToken {
        string asset;
        string authority;
        uint256 sequenceNo;
    }

    struct DeployTokenParam {
        string name;
        string symbol;
        EvmDeployToken[] deployTokens;
        StellarDeployToken stellarDeployToken;
        uint256 deadline;
    }

    /// Hash `DeployTokenParams` for ERC-712 signature validation
    function _hashDeployTokenStruct(
        DeployTokenParam memory _params
    ) internal pure returns (bytes32) {
        bytes32[] memory deployTokensHashes = new bytes32[](
            _params.deployTokens.length
        );

        // hash each EvmDeployToken
        for (uint256 i = 0; i < _params.deployTokens.length; i++) {
            deployTokensHashes[i] = _hashEvmDeployTokenStruct(
                _params.deployTokens[i]
            );
        }

        // hash StellarDeployToken
        bytes32 stellarDeployTokenHash = _hashStellarDeployTokenStruct(
            _params.stellarDeployToken
        );

        // hash DeployTokenParam
        bytes32 structHash = keccak256(
            abi.encode(
                _DEPLOY_TOKEN_TYPEHASH,
                keccak256(bytes(_params.name)),
                keccak256(bytes(_params.symbol)),
                keccak256(abi.encodePacked(deployTokensHashes)),
                stellarDeployTokenHash,
                _params.deadline
            )
        );

        return structHash;
    }

    /// Hash `EvmDeployToken` for ERC-712 signature validation
    function _hashEvmDeployTokenStruct(
        EvmDeployToken memory _params
    ) private pure returns (bytes32 _encodedStruct) {
        // hash EvmDeployToken
        _encodedStruct = keccak256(
            abi.encode(
                _EVM_DEPLOY_TOKEN_TYPEHASH,
                _params.contractAddress,
                _params.chainId,
                _params.nonce
            )
        );
    }

    /// Hash `StellarDeployToken` for ERC-712 signature validation
    function _hashStellarDeployTokenStruct(
        StellarDeployToken memory _params
    ) private pure returns (bytes32 _encodedStruct) {
        // hash StellarDeployToken
        _encodedStruct = keccak256(
            abi.encode(
                _STELLAR_DEPLOY_TOKEN_TYPEHASH,
                keccak256(bytes(_params.asset)),
                keccak256(bytes(_params.authority)),
                _params.sequenceNo
            )
        );
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (utils/cryptography/EIP712.sol)

pragma solidity 0.8.18;

import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

/**
 * Modified from openzeppelin/contracts/utils/cryptography/EIP712.sol
 * This fixed verifying contract address to 0xCcCCccccCCCCcCCCCCCcCcCccCcCCCcCcccccccC and chain_id to 56789
 */

abstract contract EIP712Custom {
    /* solhint-disable var-name-mixedcase */
    // Cache the domain separator as an immutable value, but also store the chain id that it corresponds to, in order to
    // invalidate the cached domain separator if the chain id changes.
    bytes32 private immutable _cachedDomainSeparator;

    /**
     * @dev Initializes the domain separator and parameter caches.
     *
     * The meaning of `name` and `version` is specified in
     * https://eips.ethereum.org/EIPS/eip-712#definition-of-domainseparator[EIP 712]:
     *
     * - `name`: the user readable name of the signing domain, i.e. the name of the DApp or the protocol.
     * - `version`: the current major version of the signing domain.
     *
     * NOTE: These parameters cannot be changed except through a xref:learn::upgrading-smart-contracts.adoc[smart
     * contract upgrade].
     */
    constructor(string memory _name, string memory _version) {
        bytes32 hashedName = keccak256(bytes(_name));
        bytes32 hashedVersion = keccak256(bytes(_version));
        // keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)");
        bytes32 typeHash = 0x8b73c3c69bb8fe3d512ecc4cf759cc79239f7b179b0ffacaa9a75d522b39400f;

        // verifyingContract: 0xCcCCccccCCCCcCCCCCCcCcCccCcCCCcCcccccccC
        // chain_id: 56789
        _cachedDomainSeparator = keccak256(
            abi.encode(
                typeHash,
                hashedName,
                hashedVersion,
                56789,
                address(0xCcCCccccCCCCcCCCCCCcCcCccCcCCCcCcccccccC)
            )
        );
    }

    function _hashTypedDataV4(
        bytes32 _structHash
    ) private view returns (bytes32) {
        return ECDSA.toTypedDataHash(_cachedDomainSeparator, _structHash);
    }

    /// Recover signature
    function _recoverSigner(
        bytes32 _structHash,
        uint8 _v,
        bytes32 _r,
        bytes32 _s
    ) internal view returns (address _signer) {
        bytes32 hash = _hashTypedDataV4(_structHash);
        _signer = ECDSA.recover(hash, _v, _r, _s);
    }
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

/// @title Mint Token Hasher
abstract contract MintTokenHasher {
    // keccak256("MintToken(string symbol,uint256 amount,EvmMintDestination[] destinations,StellarMintDestination stellarDestination,uint256 deadline)EvmMintDestination(address contractAddress,uint256 chainId,uint256 nonce)StellarMintDestination(string asset,string authority,uint256 sequenceNo)");
    bytes32 private constant _MINT_TOKEN_TYPEHASH =
        0x7768cc1a3091453e40ae794b95130b9a7ecd0497b18984c57c52995e34d884fd;

    // keccak256("EvmMintDestination(address contractAddress,uint256 chainId,uint256 nonce)");
    bytes32 private constant _EVM_MINT_DESTINATION_TYPEHASH =
        0xf926565b58497271466ade9f996776ec81486c663ec41ce3bea33da7e1f9c031;

    // keccak256("StellarMintDestination(string asset,string authority,uint256 sequenceNo)");
    bytes32 private constant _STELLAR_MINT_DESTINATION_TYPEHASH =
        0x1169d81a1d4f5d9bdd3142477ed3d12d102799cac7ce46e17f2a3ba127f70c55;

    struct EvmMintDestination {
        address contractAddress;
        uint256 chainId;
        uint256 nonce;
    }

    struct StellarMintDestination {
        string asset;
        string authority;
        uint256 sequenceNo;
    }

    struct MintTokenParams {
        string symbol;
        uint256 amount;
        EvmMintDestination[] destinations;
        StellarMintDestination stellarDestination;
        uint256 deadline;
    }

    /// Hash `MintTokenParams` for ERC-712 signature validation
    function _hashMintTokenStruct(
        MintTokenParams memory _params
    ) internal pure returns (bytes32) {
        bytes32[] memory destinations = new bytes32[](
            _params.destinations.length
        );

        // hash each EvmMintDestination
        for (uint256 i = 0; i < _params.destinations.length; i++) {
            destinations[i] = _hashEvmMintDestinationStruct(
                _params.destinations[i]
            );
        }

        // hash StellarMintDestination
        bytes32 stellarDestination = _hashStellarMintDestinationStruct(
            _params.stellarDestination
        );

        // hash MintTokenParams
        bytes32 structHash = keccak256(
            abi.encode(
                _MINT_TOKEN_TYPEHASH,
                keccak256(bytes(_params.symbol)),
                _params.amount,
                keccak256(abi.encodePacked(destinations)),
                stellarDestination,
                _params.deadline
            )
        );

        return structHash;
    }

    /// Hash `EvmMintDestination` for ERC-712 signature validation
    function _hashEvmMintDestinationStruct(
        EvmMintDestination memory _params
    ) private pure returns (bytes32 _encodedStruct) {
        _encodedStruct = keccak256(
            abi.encode(
                _EVM_MINT_DESTINATION_TYPEHASH,
                _params.contractAddress,
                _params.chainId,
                _params.nonce
            )
        );
    }

    /// Hash `StellarMintDestination` for ERC-712 signature validation
    function _hashStellarMintDestinationStruct(
        StellarMintDestination memory _params
    ) private pure returns (bytes32 _encodedStruct) {
        _encodedStruct = keccak256(
            abi.encode(
                _STELLAR_MINT_DESTINATION_TYPEHASH,
                keccak256(bytes(_params.asset)),
                keccak256(bytes(_params.authority)),
                _params.sequenceNo
            )
        );
    }
}
