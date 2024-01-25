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
// OpenZeppelin Contracts (last updated v4.9.0) (interfaces/IERC5267.sol)

pragma solidity ^0.8.0;

interface IERC5267 {
    /**
     * @dev MAY be emitted to signal that the domain could have changed.
     */
    event EIP712DomainChanged();

    /**
     * @dev returns the fields and values that describe the domain separator used by this contract for EIP-712
     * signature.
     */
    function eip712Domain()
        external
        view
        returns (
            bytes1 fields,
            string memory name,
            string memory version,
            uint256 chainId,
            address verifyingContract,
            bytes32 salt,
            uint256[] memory extensions
        );
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
// OpenZeppelin Contracts (last updated v4.9.0) (utils/cryptography/EIP712.sol)

pragma solidity ^0.8.8;

import "./ECDSA.sol";
import "../ShortStrings.sol";
import "../../interfaces/IERC5267.sol";

/**
 * @dev https://eips.ethereum.org/EIPS/eip-712[EIP 712] is a standard for hashing and signing of typed structured data.
 *
 * The encoding specified in the EIP is very generic, and such a generic implementation in Solidity is not feasible,
 * thus this contract does not implement the encoding itself. Protocols need to implement the type-specific encoding
 * they need in their contracts using a combination of `abi.encode` and `keccak256`.
 *
 * This contract implements the EIP 712 domain separator ({_domainSeparatorV4}) that is used as part of the encoding
 * scheme, and the final step of the encoding to obtain the message digest that is then signed via ECDSA
 * ({_hashTypedDataV4}).
 *
 * The implementation of the domain separator was designed to be as efficient as possible while still properly updating
 * the chain id to protect against replay attacks on an eventual fork of the chain.
 *
 * NOTE: This contract implements the version of the encoding known as "v4", as implemented by the JSON RPC method
 * https://docs.metamask.io/guide/signing-data.html[`eth_signTypedDataV4` in MetaMask].
 *
 * NOTE: In the upgradeable version of this contract, the cached values will correspond to the address, and the domain
 * separator of the implementation contract. This will cause the `_domainSeparatorV4` function to always rebuild the
 * separator from the immutable values, which is cheaper than accessing a cached version in cold storage.
 *
 * _Available since v3.4._
 *
 * @custom:oz-upgrades-unsafe-allow state-variable-immutable state-variable-assignment
 */
abstract contract EIP712 is IERC5267 {
    using ShortStrings for *;

    bytes32 private constant _TYPE_HASH =
        keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)");

    // Cache the domain separator as an immutable value, but also store the chain id that it corresponds to, in order to
    // invalidate the cached domain separator if the chain id changes.
    bytes32 private immutable _cachedDomainSeparator;
    uint256 private immutable _cachedChainId;
    address private immutable _cachedThis;

    bytes32 private immutable _hashedName;
    bytes32 private immutable _hashedVersion;

    ShortString private immutable _name;
    ShortString private immutable _version;
    string private _nameFallback;
    string private _versionFallback;

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
    constructor(string memory name, string memory version) {
        _name = name.toShortStringWithFallback(_nameFallback);
        _version = version.toShortStringWithFallback(_versionFallback);
        _hashedName = keccak256(bytes(name));
        _hashedVersion = keccak256(bytes(version));

        _cachedChainId = block.chainid;
        _cachedDomainSeparator = _buildDomainSeparator();
        _cachedThis = address(this);
    }

    /**
     * @dev Returns the domain separator for the current chain.
     */
    function _domainSeparatorV4() internal view returns (bytes32) {
        if (address(this) == _cachedThis && block.chainid == _cachedChainId) {
            return _cachedDomainSeparator;
        } else {
            return _buildDomainSeparator();
        }
    }

    function _buildDomainSeparator() private view returns (bytes32) {
        return keccak256(abi.encode(_TYPE_HASH, _hashedName, _hashedVersion, block.chainid, address(this)));
    }

    /**
     * @dev Given an already https://eips.ethereum.org/EIPS/eip-712#definition-of-hashstruct[hashed struct], this
     * function returns the hash of the fully encoded EIP712 message for this domain.
     *
     * This hash can be used together with {ECDSA-recover} to obtain the signer of a message. For example:
     *
     * ```solidity
     * bytes32 digest = _hashTypedDataV4(keccak256(abi.encode(
     *     keccak256("Mail(address to,string contents)"),
     *     mailTo,
     *     keccak256(bytes(mailContents))
     * )));
     * address signer = ECDSA.recover(digest, signature);
     * ```
     */
    function _hashTypedDataV4(bytes32 structHash) internal view virtual returns (bytes32) {
        return ECDSA.toTypedDataHash(_domainSeparatorV4(), structHash);
    }

    /**
     * @dev See {EIP-5267}.
     *
     * _Available since v4.9._
     */
    function eip712Domain()
        public
        view
        virtual
        override
        returns (
            bytes1 fields,
            string memory name,
            string memory version,
            uint256 chainId,
            address verifyingContract,
            bytes32 salt,
            uint256[] memory extensions
        )
    {
        return (
            hex"0f", // 01111
            _name.toStringWithFallback(_nameFallback),
            _version.toStringWithFallback(_versionFallback),
            block.chainid,
            address(this),
            bytes32(0),
            new uint256[](0)
        );
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
// OpenZeppelin Contracts (last updated v4.9.0) (utils/ShortStrings.sol)

pragma solidity ^0.8.8;

import "./StorageSlot.sol";

// | string  | 0xAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA   |
// | length  | 0x                                                              BB |
type ShortString is bytes32;

/**
 * @dev This library provides functions to convert short memory strings
 * into a `ShortString` type that can be used as an immutable variable.
 *
 * Strings of arbitrary length can be optimized using this library if
 * they are short enough (up to 31 bytes) by packing them with their
 * length (1 byte) in a single EVM word (32 bytes). Additionally, a
 * fallback mechanism can be used for every other case.
 *
 * Usage example:
 *
 * ```solidity
 * contract Named {
 *     using ShortStrings for *;
 *
 *     ShortString private immutable _name;
 *     string private _nameFallback;
 *
 *     constructor(string memory contractName) {
 *         _name = contractName.toShortStringWithFallback(_nameFallback);
 *     }
 *
 *     function name() external view returns (string memory) {
 *         return _name.toStringWithFallback(_nameFallback);
 *     }
 * }
 * ```
 */
library ShortStrings {
    // Used as an identifier for strings longer than 31 bytes.
    bytes32 private constant _FALLBACK_SENTINEL = 0x00000000000000000000000000000000000000000000000000000000000000FF;

    error StringTooLong(string str);
    error InvalidShortString();

    /**
     * @dev Encode a string of at most 31 chars into a `ShortString`.
     *
     * This will trigger a `StringTooLong` error is the input string is too long.
     */
    function toShortString(string memory str) internal pure returns (ShortString) {
        bytes memory bstr = bytes(str);
        if (bstr.length > 31) {
            revert StringTooLong(str);
        }
        return ShortString.wrap(bytes32(uint256(bytes32(bstr)) | bstr.length));
    }

    /**
     * @dev Decode a `ShortString` back to a "normal" string.
     */
    function toString(ShortString sstr) internal pure returns (string memory) {
        uint256 len = byteLength(sstr);
        // using `new string(len)` would work locally but is not memory safe.
        string memory str = new string(32);
        /// @solidity memory-safe-assembly
        assembly {
            mstore(str, len)
            mstore(add(str, 0x20), sstr)
        }
        return str;
    }

    /**
     * @dev Return the length of a `ShortString`.
     */
    function byteLength(ShortString sstr) internal pure returns (uint256) {
        uint256 result = uint256(ShortString.unwrap(sstr)) & 0xFF;
        if (result > 31) {
            revert InvalidShortString();
        }
        return result;
    }

    /**
     * @dev Encode a string into a `ShortString`, or write it to storage if it is too long.
     */
    function toShortStringWithFallback(string memory value, string storage store) internal returns (ShortString) {
        if (bytes(value).length < 32) {
            return toShortString(value);
        } else {
            StorageSlot.getStringSlot(store).value = value;
            return ShortString.wrap(_FALLBACK_SENTINEL);
        }
    }

    /**
     * @dev Decode a string that was encoded to `ShortString` or written to storage using {setWithFallback}.
     */
    function toStringWithFallback(ShortString value, string storage store) internal pure returns (string memory) {
        if (ShortString.unwrap(value) != _FALLBACK_SENTINEL) {
            return toString(value);
        } else {
            return store;
        }
    }

    /**
     * @dev Return the length of a string that was encoded to `ShortString` or written to storage using {setWithFallback}.
     *
     * WARNING: This will return the "byte length" of the string. This may not reflect the actual length in terms of
     * actual characters as the UTF-8 encoding of a single character can span over multiple bytes.
     */
    function byteLengthWithFallback(ShortString value, string storage store) internal view returns (uint256) {
        if (ShortString.unwrap(value) != _FALLBACK_SENTINEL) {
            return byteLength(value);
        } else {
            return bytes(store).length;
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
library StorageSlot {
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

pragma solidity ^0.8.0;

// A representation of an empty/uninitialized UID.
bytes32 constant EMPTY_UID = 0;

// A zero expiration represents an non-expiring attestation.
uint64 constant NO_EXPIRATION_TIME = 0;

error AccessDenied();
error DeadlineExpired();
error InvalidEAS();
error InvalidLength();
error InvalidSignature();
error NotFound();

/// @notice A struct representing ECDSA signature data.
struct Signature {
    uint8 v; // The recovery ID.
    bytes32 r; // The x-coordinate of the nonce R.
    bytes32 s; // The signature data.
}

/// @notice A struct representing a single attestation.
struct Attestation {
    bytes32 uid; // A unique identifier of the attestation.
    bytes32 schema; // The unique identifier of the schema.
    uint64 time; // The time when the attestation was created (Unix timestamp).
    uint64 expirationTime; // The time when the attestation expires (Unix timestamp).
    uint64 revocationTime; // The time when the attestation was revoked (Unix timestamp).
    bytes32 refUID; // The UID of the related attestation.
    address recipient; // The recipient of the attestation.
    address attester; // The attester/sender of the attestation.
    bool revocable; // Whether the attestation is revocable.
    bytes data; // Custom attestation data.
}

/// @notice A helper function to work with unchecked iterators in loops.
function uncheckedInc(uint256 i) pure returns (uint256 j) {
    unchecked {
        j = i + 1;
    }
}// SPDX-License-Identifier: MIT

pragma solidity 0.8.19;

import { EIP712 } from "@openzeppelin/contracts/utils/cryptography/EIP712.sol";
import { ECDSA } from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";

// prettier-ignore
import {
    Attestation,
    AccessDenied,
    DeadlineExpired,
    Signature,
    InvalidEAS,
    InvalidLength,
    InvalidSignature,
    NotFound,
    NO_EXPIRATION_TIME,
    uncheckedInc
} from "./Common.sol";

// prettier-ignore
import {
    AttestationRequest,
    AttestationRequestData,
    DelegatedAttestationRequest,
    DelegatedRevocationRequest,
    IEAS,
    MultiAttestationRequest,
    MultiDelegatedAttestationRequest,
    MultiDelegatedRevocationRequest,
    MultiRevocationRequest,
    RevocationRequest,
    RevocationRequestData
} from "./IEAS.sol";

import { Semver } from "./Semver.sol";

/// @notice A struct representing the full arguments of the full delegated attestation request.
struct DelegatedProxyAttestationRequest {
    bytes32 schema; // The unique identifier of the schema.
    AttestationRequestData data; // The arguments of the attestation request.
    Signature signature; // The EIP712 signature data.
    address attester; // The attesting account.
    uint64 deadline; // The deadline of the signature/request.
}

/// @notice A struct representing the full arguments of the delegated multi attestation request.
struct MultiDelegatedProxyAttestationRequest {
    bytes32 schema; // The unique identifier of the schema.
    AttestationRequestData[] data; // The arguments of the attestation requests.
    Signature[] signatures; // The EIP712 signatures data. Please note that the signatures are assumed to be signed with increasing nonces.
    address attester; // The attesting account.
    uint64 deadline; // The deadline of the signature/request.
}

/// @notice A struct representing the arguments of the full delegated revocation request.
struct DelegatedProxyRevocationRequest {
    bytes32 schema; // The unique identifier of the schema.
    RevocationRequestData data; // The arguments of the revocation request.
    Signature signature; // The EIP712 signature data.
    address revoker; // The revoking account.
    uint64 deadline; // The deadline of the signature/request.
}

/// @notice A struct representing the full arguments of the delegated multi revocation request.
struct MultiDelegatedProxyRevocationRequest {
    bytes32 schema; // The unique identifier of the schema.
    RevocationRequestData[] data; // The arguments of the revocation requests.
    Signature[] signatures; // The EIP712 signatures data. Please note that the signatures are assumed to be signed with increasing nonces.
    address revoker; // The revoking account.
    uint64 deadline; // The deadline of the signature/request.
}

/// @title EIP712Proxy
/// @notice This utility contract an be used to aggregate delegated attestations without requiring a specific order via
///     nonces. The contract doesn't request nonces and implements replay protection by storing ***immalleable***
///     signatures.
contract EIP712Proxy is Semver, EIP712, Ownable {
    error UsedSignature();

    // The hash of the data type used to relay calls to the attest function. It's the value of
    // keccak256("Attest(address attester,bytes32 schema,address recipient,uint64 expirationTime,bool revocable,bytes32 refUID,bytes data,uint256 value,uint64 deadline)").
    bytes32 private constant ATTEST_PROXY_TYPEHASH = 0xea02ffba7dcb45f6fc649714d23f315eef12e3b27f9a7735d8d8bf41eb2b1af1;

    // The hash of the data type used to relay calls to the revoke function. It's the value of
    // keccak256("Revoke(address revoker,bytes32 schema,bytes32 uid,uint256 value,uint64 deadline)").
    bytes32 private constant REVOKE_PROXY_TYPEHASH = 0x78a69a78c1a55cdff5cbf949580b410778cd9e4d1ecbe6f06a7fa8dc2441b57d;

    // The global EAS contract.
    IEAS private _eas;

    // The user readable name of the signing domain.
    string private _name;

    // The global mapping between proxy attestations and their attesters, so that we can verify that only the original
    // attester is able to revert attestations by proxy.
    mapping(bytes32 uid => address attester) private _attesters;
  
    // The global mapping between recipient addresses and their attesttions uids.
    mapping(address recipient => bytes32[] uids) private _recipientUids;

    // Replay protection signatures.
    mapping(bytes signature => bool used) private _signatures;

    /// @dev Creates a new EIP1271Verifier instance.
    /// @param eas The address of the global EAS contract.
    /// @param name The user readable name of the signing domain.
    constructor(IEAS eas, string memory name) Semver(1, 3, 0) EIP712(name, "1.3.0") {
        if (address(eas) == address(0)) {
            revert InvalidEAS();
        }

        _eas = eas;
        _name = name;
    }

    /// @notice Set the EAS address.
    /// @param eas The address of the new EAS.
    function setEAS(IEAS eas) external onlyOwner {
        _eas = eas;
    }

    /// @notice Returns the EAS.
    function getEAS() external view returns (IEAS) {
        return _eas;
    }

    /// @notice Returns the domain separator used in the encoding of the signatures for attest, and revoke.
    function getDomainSeparator() external view returns (bytes32) {
        return _domainSeparatorV4();
    }

    /// Returns the EIP712 type hash for the attest function.
    function getAttestTypeHash() external pure returns (bytes32) {
        return ATTEST_PROXY_TYPEHASH;
    }

    /// Returns the EIP712 type hash for the revoke function.
    function getRevokeTypeHash() external pure returns (bytes32) {
        return REVOKE_PROXY_TYPEHASH;
    }

    /// Returns the EIP712 name.
    function getName() external view returns (string memory) {
        return _name;
    }

    /// Returns the attester for a given uid.
    function getAttester(bytes32 uid) external view returns (address) {
        return _attesters[uid];
    }

    /// Returns the attestations uids for a given attested address (recipient).
    function getRecipientUids(address recipient) external view returns (bytes32[] memory) {
        return _recipientUids[recipient];
    }
    
    /// Returns the recipient for a given uid.
    function getUidReceipt(bytes32 uid) external view returns (Attestation memory) {
        return _eas.getAttestation(uid);
    }

    /// @notice Attests to a specific schema via the provided EIP712 signature.
    /// @param delegatedRequest The arguments of the delegated attestation request.
    /// @return The UID of the new attestation.
    function attestByDelegationSimple(
        DelegatedProxyAttestationRequest memory delegatedRequest
    ) internal returns (bytes32) {
        bytes32 uid = _eas.attest{ value: 0 }(
            AttestationRequest({ schema: delegatedRequest.schema, data: delegatedRequest.data })
        );

        _attesters[uid] = delegatedRequest.attester;

        _recipientUids[delegatedRequest.data.recipient].push(uid);

        return uid;
    }

    /// @notice Revokes an existing attestation to a specific schema via the provided EIP712 signature.
    /// @param delegatedRequest The arguments of the delegated revocation request.
    function revokeByDelegationSimple(
        RevocationRequest memory delegatedRequest
    ) internal virtual {
        return
            _eas.revoke{ value: 0 }(
                RevocationRequest({ schema: delegatedRequest.schema, data: delegatedRequest.data })
            );
    }

    /// @notice Attests to a specific schema via the provided EIP712 signature.
    /// @param delegatedRequest The arguments of the delegated attestation request.
    /// @return The UID of the new attestation.
    ///
    /// Example:
    ///     attestByDelegation({
    ///         schema: '0x8e72f5bc0a8d4be6aa98360baa889040c50a0e51f32dbf0baa5199bd93472ebc',
    ///         data: {
    ///             recipient: '0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266',
    ///             expirationTime: 1673891048,
    ///             revocable: true,
    ///             refUID: '0x0000000000000000000000000000000000000000000000000000000000000000',
    ///             data: '0x1234',
    ///             value: 0
    ///         },
    ///         signature: {
    ///             v: 28,
    ///             r: '0x148c...b25b',
    ///             s: '0x5a72...be22'
    ///         },
    ///         attester: '0xc5E8740aD971409492b1A63Db8d83025e0Fc427e',
    ///         deadline: 1673891048
    ///     })
    function attestByDelegation(
        DelegatedProxyAttestationRequest calldata delegatedRequest
    ) public payable virtual returns (bytes32) {
        _verifyAttest(delegatedRequest);

        bytes32 uid = _eas.attest{ value: msg.value }(
            AttestationRequest({ schema: delegatedRequest.schema, data: delegatedRequest.data })
        );

        _attesters[uid] = delegatedRequest.attester;

        _recipientUids[delegatedRequest.data.recipient].push(uid);

        return uid;
    }

    /// @notice Attests to multiple schemas using via provided EIP712 signatures.
    /// @param multiDelegatedRequests The arguments of the delegated multi attestation requests. The requests should be
    ///     grouped by distinct schema ids to benefit from the best batching optimization.
    /// @return The UIDs of the new attestations.
    ///
    /// Example:
    ///     multiAttestByDelegation([{
    ///         schema: '0x8e72f5bc0a8d4be6aa98360baa889040c50a0e51f32dbf0baa5199bd93472ebc',
    ///         data: [{
    ///             recipient: '0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266',
    ///             expirationTime: 1673891048,
    ///             revocable: true,
    ///             refUID: '0x0000000000000000000000000000000000000000000000000000000000000000',
    ///             data: '0x1234',
    ///             value: 0
    ///         },
    ///         {
    ///             recipient: '0xdEADBeAFdeAdbEafdeadbeafDeAdbEAFdeadbeaf',
    ///             expirationTime: 0,
    ///             revocable: false,
    ///             refUID: '0x0000000000000000000000000000000000000000000000000000000000000000',
    ///             data: '0x00',
    ///             value: 0
    ///         }],
    ///         signatures: [{
    ///             v: 28,
    ///             r: '0x148c...b25b',
    ///             s: '0x5a72...be22'
    ///         },
    ///         {
    ///             v: 28,
    ///             r: '0x487s...67bb',
    ///             s: '0x12ad...2366'
    ///         }],
    ///         attester: '0x1D86495b2A7B524D747d2839b3C645Bed32e8CF4',
    ///         deadline: 1673891048
    ///     }])
    function multiAttestByDelegation(
        MultiDelegatedProxyAttestationRequest[] calldata multiDelegatedRequests
    ) public payable virtual returns (bytes32[] memory) {
        uint256 length = multiDelegatedRequests.length;
        MultiAttestationRequest[] memory multiRequests = new MultiAttestationRequest[](length);

        for (uint256 i = 0; i < length; i = uncheckedInc(i)) {
            MultiDelegatedProxyAttestationRequest calldata multiDelegatedRequest = multiDelegatedRequests[i];
            AttestationRequestData[] calldata data = multiDelegatedRequest.data;

            // Ensure that no inputs are missing.
            uint256 dataLength = data.length;
            if (dataLength == 0 || dataLength != multiDelegatedRequest.signatures.length) {
                revert InvalidLength();
            }

            // Verify EIP712 signatures. Please note that the signatures are assumed to be signed with increasing nonces.
            for (uint256 j = 0; j < dataLength; j = uncheckedInc(j)) {
                _verifyAttest(
                    DelegatedProxyAttestationRequest({
                        schema: multiDelegatedRequest.schema,
                        data: data[j],
                        signature: multiDelegatedRequest.signatures[j],
                        attester: multiDelegatedRequest.attester,
                        deadline: multiDelegatedRequest.deadline
                    })
                );
            }

            multiRequests[i] = MultiAttestationRequest({ schema: multiDelegatedRequest.schema, data: data });
        }

        bytes32[] memory uids = _eas.multiAttest{ value: msg.value }(multiRequests);

        // Store all attesters, according to the order of the attestation requests.
        uint256 uidCounter = 0;

        for (uint256 i = 0; i < length; i = uncheckedInc(i)) {
            MultiDelegatedProxyAttestationRequest calldata multiDelegatedRequest = multiDelegatedRequests[i];
            AttestationRequestData[] calldata data = multiDelegatedRequest.data;

            uint256 dataLength = data.length;
            for (uint256 j = 0; j < dataLength; j = uncheckedInc(j)) {
                _attesters[uids[uidCounter]] = multiDelegatedRequest.attester;

                _recipientUids[data[j].recipient].push(uids[uidCounter]);

                unchecked {
                    ++uidCounter;
                }
            }
        }

        return uids;
    }

    /// @notice Revokes an existing attestation to a specific schema via the provided EIP712 signature.
    /// @param delegatedRequest The arguments of the delegated revocation request.
    ///
    /// Example:
    ///     revokeByDelegation({
    ///         schema: '0x8e72f5bc0a8d4be6aa98360baa889040c50a0e51f32dbf0baa5199bd93472ebc',
    ///         data: {
    ///             uid: '0xcbbc12102578c642a0f7b34fe7111e41afa25683b6cd7b5a14caf90fa14d24ba',
    ///             value: 0
    ///         },
    ///         signature: {
    ///             v: 27,
    ///             r: '0xb593...7142',
    ///             s: '0x0f5b...2cce'
    ///         },
    ///         revoker: '0x244934dd3e31bE2c81f84ECf0b3E6329F5381992',
    ///         deadline: 1673891048
    ///     })
    function revokeByDelegation(DelegatedProxyRevocationRequest calldata delegatedRequest) public payable virtual {
        _verifyRevoke(delegatedRequest);

        return
            _eas.revoke{ value: msg.value }(
                RevocationRequest({ schema: delegatedRequest.schema, data: delegatedRequest.data })
            );
    }

    /// @notice Revokes existing attestations to multiple schemas via provided EIP712 signatures.
    /// @param multiDelegatedRequests The arguments of the delegated multi revocation attestation requests. The requests
    ///     should be grouped by distinct schema ids to benefit from the best batching optimization.
    ///
    /// Example:
    ///     multiRevokeByDelegation([{
    ///         schema: '0x8e72f5bc0a8d4be6aa98360baa889040c50a0e51f32dbf0baa5199bd93472ebc',
    ///         data: [{
    ///             uid: '0x211296a1ca0d7f9f2cfebf0daaa575bea9b20e968d81aef4e743d699c6ac4b25',
    ///             value: 1000
    ///         },
    ///         {
    ///             uid: '0xe160ac1bd3606a287b4d53d5d1d6da5895f65b4b4bab6d93aaf5046e48167ade',
    ///             value: 0
    ///         }],
    ///         signatures: [{
    ///             v: 28,
    ///             r: '0x148c...b25b',
    ///             s: '0x5a72...be22'
    ///         },
    ///         {
    ///             v: 28,
    ///             r: '0x487s...67bb',
    ///             s: '0x12ad...2366'
    ///         }],
    ///         revoker: '0x244934dd3e31bE2c81f84ECf0b3E6329F5381992',
    ///         deadline: 1673891048
    ///     }])
    function multiRevokeByDelegation(
        MultiDelegatedProxyRevocationRequest[] calldata multiDelegatedRequests
    ) public payable virtual {
        uint256 length = multiDelegatedRequests.length;
        MultiRevocationRequest[] memory multiRequests = new MultiRevocationRequest[](length);

        for (uint256 i = 0; i < length; i = uncheckedInc(i)) {
            MultiDelegatedProxyRevocationRequest memory multiDelegatedRequest = multiDelegatedRequests[i];
            RevocationRequestData[] memory data = multiDelegatedRequest.data;

            // Ensure that no inputs are missing.
            uint256 dataLength = data.length;
            if (dataLength == 0 || dataLength != multiDelegatedRequest.signatures.length) {
                revert InvalidLength();
            }

            // Verify EIP712 signatures. Please note that the signatures are assumed to be signed with increasing nonces.
            for (uint256 j = 0; j < dataLength; j = uncheckedInc(j)) {
                RevocationRequestData memory requestData = data[j];

                _verifyRevoke(
                    DelegatedProxyRevocationRequest({
                        schema: multiDelegatedRequest.schema,
                        data: requestData,
                        signature: multiDelegatedRequest.signatures[j],
                        revoker: multiDelegatedRequest.revoker,
                        deadline: multiDelegatedRequest.deadline
                    })
                );
            }

            multiRequests[i] = MultiRevocationRequest({ schema: multiDelegatedRequest.schema, data: data });
        }

        _eas.multiRevoke{ value: msg.value }(multiRequests);
    }

    /// @dev Verifies delegated attestation request.
    /// @param request The arguments of the delegated attestation request.
    function _verifyAttest(DelegatedProxyAttestationRequest memory request) internal {
        if (request.deadline != NO_EXPIRATION_TIME && request.deadline < _time()) {
            revert DeadlineExpired();
        }

        AttestationRequestData memory data = request.data;
        Signature memory signature = request.signature;

        _verifyUnusedSignature(signature);

        bytes32 digest = _hashTypedDataV4(
            keccak256(
                abi.encode(
                    ATTEST_PROXY_TYPEHASH,
                    request.attester,
                    request.schema,
                    data.recipient,
                    data.expirationTime,
                    data.revocable,
                    data.refUID,
                    keccak256(data.data),
                    data.value,
                    request.deadline
                )
            )
        );

        if (ECDSA.recover(digest, signature.v, signature.r, signature.s) != request.attester) {
            revert InvalidSignature();
        }
    }

    /// @dev Verifies delegated revocation request.
    /// @param request The arguments of the delegated revocation request.
    function _verifyRevoke(DelegatedProxyRevocationRequest memory request) internal {
        if (request.deadline != NO_EXPIRATION_TIME && request.deadline < _time()) {
            revert DeadlineExpired();
        }

        RevocationRequestData memory data = request.data;

        // Allow only original attesters to revoke their attestations.
        address attester = _attesters[data.uid];
        if (attester == address(0)) {
            revert NotFound();
        }

        if (attester != msg.sender) {
            revert AccessDenied();
        }

        Signature memory signature = request.signature;

        _verifyUnusedSignature(signature);

        bytes32 digest = _hashTypedDataV4(
            keccak256(
                abi.encode(
                    REVOKE_PROXY_TYPEHASH,
                    request.revoker,
                    request.schema,
                    data.uid,
                    data.value,
                    request.deadline
                )
            )
        );

        if (ECDSA.recover(digest, signature.v, signature.r, signature.s) != request.revoker) {
            revert InvalidSignature();
        }
    }

    /// @dev Ensures that the provided EIP712 signature wasn't already used.
    /// @param signature The EIP712 signature data.
    function _verifyUnusedSignature(Signature memory signature) internal {
        bytes memory packedSignature = abi.encodePacked(signature.v, signature.r, signature.s);

        if (_signatures[packedSignature]) {
            revert UsedSignature();
        }

        _signatures[packedSignature] = true;
    }

    /// @dev Returns the current's block timestamp. This method is overridden during tests and used to simulate the
    ///     current block time.
    function _time() internal view virtual returns (uint64) {
        return uint64(block.timestamp);
    }
}// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import { ISchemaRegistry } from "./ISchemaRegistry.sol";
import { Attestation, Signature } from "./Common.sol";

/// @notice A struct representing the arguments of the attestation request.
struct AttestationRequestData {
    address recipient; // The recipient of the attestation.
    uint64 expirationTime; // The time when the attestation expires (Unix timestamp).
    bool revocable; // Whether the attestation is revocable.
    bytes32 refUID; // The UID of the related attestation.
    bytes data; // Custom attestation data.
    uint256 value; // An explicit ETH amount to send to the resolver. This is important to prevent accidental user errors.
}

/// @notice A struct representing the full arguments of the attestation request.
struct AttestationRequest {
    bytes32 schema; // The unique identifier of the schema.
    AttestationRequestData data; // The arguments of the attestation request.
}

/// @notice A struct representing the full arguments of the full delegated attestation request.
struct DelegatedAttestationRequest {
    bytes32 schema; // The unique identifier of the schema.
    AttestationRequestData data; // The arguments of the attestation request.
    Signature signature; // The ECDSA signature data.
    address attester; // The attesting account.
    uint64 deadline; // The deadline of the signature/request.
}

/// @notice A struct representing the full arguments of the multi attestation request.
struct MultiAttestationRequest {
    bytes32 schema; // The unique identifier of the schema.
    AttestationRequestData[] data; // The arguments of the attestation request.
}

/// @notice A struct representing the full arguments of the delegated multi attestation request.
struct MultiDelegatedAttestationRequest {
    bytes32 schema; // The unique identifier of the schema.
    AttestationRequestData[] data; // The arguments of the attestation requests.
    Signature[] signatures; // The ECDSA signatures data. Please note that the signatures are assumed to be signed with increasing nonces.
    address attester; // The attesting account.
    uint64 deadline; // The deadline of the signature/request.
}

/// @notice A struct representing the arguments of the revocation request.
struct RevocationRequestData {
    bytes32 uid; // The UID of the attestation to revoke.
    uint256 value; // An explicit ETH amount to send to the resolver. This is important to prevent accidental user errors.
}

/// @notice A struct representing the full arguments of the revocation request.
struct RevocationRequest {
    bytes32 schema; // The unique identifier of the schema.
    RevocationRequestData data; // The arguments of the revocation request.
}

/// @notice A struct representing the arguments of the full delegated revocation request.
struct DelegatedRevocationRequest {
    bytes32 schema; // The unique identifier of the schema.
    RevocationRequestData data; // The arguments of the revocation request.
    Signature signature; // The ECDSA signature data.
    address revoker; // The revoking account.
    uint64 deadline; // The deadline of the signature/request.
}

/// @notice A struct representing the full arguments of the multi revocation request.
struct MultiRevocationRequest {
    bytes32 schema; // The unique identifier of the schema.
    RevocationRequestData[] data; // The arguments of the revocation request.
}

/// @notice A struct representing the full arguments of the delegated multi revocation request.
struct MultiDelegatedRevocationRequest {
    bytes32 schema; // The unique identifier of the schema.
    RevocationRequestData[] data; // The arguments of the revocation requests.
    Signature[] signatures; // The ECDSA signatures data. Please note that the signatures are assumed to be signed with increasing nonces.
    address revoker; // The revoking account.
    uint64 deadline; // The deadline of the signature/request.
}

/// @title IEAS
/// @notice EAS - Ethereum Attestation Service interface.
interface IEAS {
    /// @notice Emitted when an attestation has been made.
    /// @param recipient The recipient of the attestation.
    /// @param attester The attesting account.
    /// @param uid The UID the revoked attestation.
    /// @param schemaUID The UID of the schema.
    event Attested(address indexed recipient, address indexed attester, bytes32 uid, bytes32 indexed schemaUID);

    /// @notice Emitted when an attestation has been revoked.
    /// @param recipient The recipient of the attestation.
    /// @param attester The attesting account.
    /// @param schemaUID The UID of the schema.
    /// @param uid The UID the revoked attestation.
    event Revoked(address indexed recipient, address indexed attester, bytes32 uid, bytes32 indexed schemaUID);

    /// @notice Emitted when a data has been timestamped.
    /// @param data The data.
    /// @param timestamp The timestamp.
    event Timestamped(bytes32 indexed data, uint64 indexed timestamp);

    /// @notice Emitted when a data has been revoked.
    /// @param revoker The address of the revoker.
    /// @param data The data.
    /// @param timestamp The timestamp.
    event RevokedOffchain(address indexed revoker, bytes32 indexed data, uint64 indexed timestamp);

    /// @notice Returns the address of the global schema registry.
    /// @return The address of the global schema registry.
    function getSchemaRegistry() external view returns (ISchemaRegistry);

    /// @notice Attests to a specific schema.
    /// @param request The arguments of the attestation request.
    /// @return The UID of the new attestation.
    ///
    /// Example:
    ///     attest({
    ///         schema: "0facc36681cbe2456019c1b0d1e7bedd6d1d40f6f324bf3dd3a4cef2999200a0",
    ///         data: {
    ///             recipient: "0xdEADBeAFdeAdbEafdeadbeafDeAdbEAFdeadbeaf",
    ///             expirationTime: 0,
    ///             revocable: true,
    ///             refUID: "0x0000000000000000000000000000000000000000000000000000000000000000",
    ///             data: "0xF00D",
    ///             value: 0
    ///         }
    ///     })
    function attest(AttestationRequest calldata request) external payable returns (bytes32);

    /// @notice Attests to a specific schema via the provided ECDSA signature.
    /// @param delegatedRequest The arguments of the delegated attestation request.
    /// @return The UID of the new attestation.
    ///
    /// Example:
    ///     attestByDelegation({
    ///         schema: '0x8e72f5bc0a8d4be6aa98360baa889040c50a0e51f32dbf0baa5199bd93472ebc',
    ///         data: {
    ///             recipient: '0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266',
    ///             expirationTime: 1673891048,
    ///             revocable: true,
    ///             refUID: '0x0000000000000000000000000000000000000000000000000000000000000000',
    ///             data: '0x1234',
    ///             value: 0
    ///         },
    ///         signature: {
    ///             v: 28,
    ///             r: '0x148c...b25b',
    ///             s: '0x5a72...be22'
    ///         },
    ///         attester: '0xc5E8740aD971409492b1A63Db8d83025e0Fc427e',
    ///         deadline: 1673891048
    ///     })
    function attestByDelegation(
        DelegatedAttestationRequest calldata delegatedRequest
    ) external payable returns (bytes32);

    /// @notice Attests to multiple schemas.
    /// @param multiRequests The arguments of the multi attestation requests. The requests should be grouped by distinct
    ///     schema ids to benefit from the best batching optimization.
    /// @return The UIDs of the new attestations.
    ///
    /// Example:
    ///     multiAttest([{
    ///         schema: '0x33e9094830a5cba5554d1954310e4fbed2ef5f859ec1404619adea4207f391fd',
    ///         data: [{
    ///             recipient: '0xdEADBeAFdeAdbEafdeadbeafDeAdbEAFdeadbeaf',
    ///             expirationTime: 1673891048,
    ///             revocable: true,
    ///             refUID: '0x0000000000000000000000000000000000000000000000000000000000000000',
    ///             data: '0x1234',
    ///             value: 1000
    ///         },
    ///         {
    ///             recipient: '0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266',
    ///             expirationTime: 0,
    ///             revocable: false,
    ///             refUID: '0x480df4a039efc31b11bfdf491b383ca138b6bde160988222a2a3509c02cee174',
    ///             data: '0x00',
    ///             value: 0
    ///         }],
    ///     },
    ///     {
    ///         schema: '0x5ac273ce41e3c8bfa383efe7c03e54c5f0bff29c9f11ef6ffa930fc84ca32425',
    ///         data: [{
    ///             recipient: '0xdEADBeAFdeAdbEafdeadbeafDeAdbEAFdeadbeaf',
    ///             expirationTime: 0,
    ///             revocable: true,
    ///             refUID: '0x75bf2ed8dca25a8190c50c52db136664de25b2449535839008ccfdab469b214f',
    ///             data: '0x12345678',
    ///             value: 0
    ///         },
    ///     }])
    function multiAttest(MultiAttestationRequest[] calldata multiRequests) external payable returns (bytes32[] memory);

    /// @notice Attests to multiple schemas using via provided ECDSA signatures.
    /// @param multiDelegatedRequests The arguments of the delegated multi attestation requests. The requests should be
    ///     grouped by distinct schema ids to benefit from the best batching optimization.
    /// @return The UIDs of the new attestations.
    ///
    /// Example:
    ///     multiAttestByDelegation([{
    ///         schema: '0x8e72f5bc0a8d4be6aa98360baa889040c50a0e51f32dbf0baa5199bd93472ebc',
    ///         data: [{
    ///             recipient: '0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266',
    ///             expirationTime: 1673891048,
    ///             revocable: true,
    ///             refUID: '0x0000000000000000000000000000000000000000000000000000000000000000',
    ///             data: '0x1234',
    ///             value: 0
    ///         },
    ///         {
    ///             recipient: '0xdEADBeAFdeAdbEafdeadbeafDeAdbEAFdeadbeaf',
    ///             expirationTime: 0,
    ///             revocable: false,
    ///             refUID: '0x0000000000000000000000000000000000000000000000000000000000000000',
    ///             data: '0x00',
    ///             value: 0
    ///         }],
    ///         signatures: [{
    ///             v: 28,
    ///             r: '0x148c...b25b',
    ///             s: '0x5a72...be22'
    ///         },
    ///         {
    ///             v: 28,
    ///             r: '0x487s...67bb',
    ///             s: '0x12ad...2366'
    ///         }],
    ///         attester: '0x1D86495b2A7B524D747d2839b3C645Bed32e8CF4',
    ///         deadline: 1673891048
    ///     }])
    function multiAttestByDelegation(
        MultiDelegatedAttestationRequest[] calldata multiDelegatedRequests
    ) external payable returns (bytes32[] memory);

    /// @notice Revokes an existing attestation to a specific schema.
    /// @param request The arguments of the revocation request.
    ///
    /// Example:
    ///     revoke({
    ///         schema: '0x8e72f5bc0a8d4be6aa98360baa889040c50a0e51f32dbf0baa5199bd93472ebc',
    ///         data: {
    ///             uid: '0x101032e487642ee04ee17049f99a70590c735b8614079fc9275f9dd57c00966d',
    ///             value: 0
    ///         }
    ///     })
    function revoke(RevocationRequest calldata request) external payable;

    /// @notice Revokes an existing attestation to a specific schema via the provided ECDSA signature.
    /// @param delegatedRequest The arguments of the delegated revocation request.
    ///
    /// Example:
    ///     revokeByDelegation({
    ///         schema: '0x8e72f5bc0a8d4be6aa98360baa889040c50a0e51f32dbf0baa5199bd93472ebc',
    ///         data: {
    ///             uid: '0xcbbc12102578c642a0f7b34fe7111e41afa25683b6cd7b5a14caf90fa14d24ba',
    ///             value: 0
    ///         },
    ///         signature: {
    ///             v: 27,
    ///             r: '0xb593...7142',
    ///             s: '0x0f5b...2cce'
    ///         },
    ///         revoker: '0x244934dd3e31bE2c81f84ECf0b3E6329F5381992',
    ///         deadline: 1673891048
    ///     })
    function revokeByDelegation(DelegatedRevocationRequest calldata delegatedRequest) external payable;

    /// @notice Revokes existing attestations to multiple schemas.
    /// @param multiRequests The arguments of the multi revocation requests. The requests should be grouped by distinct
    ///     schema ids to benefit from the best batching optimization.
    ///
    /// Example:
    ///     multiRevoke([{
    ///         schema: '0x8e72f5bc0a8d4be6aa98360baa889040c50a0e51f32dbf0baa5199bd93472ebc',
    ///         data: [{
    ///             uid: '0x211296a1ca0d7f9f2cfebf0daaa575bea9b20e968d81aef4e743d699c6ac4b25',
    ///             value: 1000
    ///         },
    ///         {
    ///             uid: '0xe160ac1bd3606a287b4d53d5d1d6da5895f65b4b4bab6d93aaf5046e48167ade',
    ///             value: 0
    ///         }],
    ///     },
    ///     {
    ///         schema: '0x5ac273ce41e3c8bfa383efe7c03e54c5f0bff29c9f11ef6ffa930fc84ca32425',
    ///         data: [{
    ///             uid: '0x053d42abce1fd7c8fcddfae21845ad34dae287b2c326220b03ba241bc5a8f019',
    ///             value: 0
    ///         },
    ///     }])
    function multiRevoke(MultiRevocationRequest[] calldata multiRequests) external payable;

    /// @notice Revokes existing attestations to multiple schemas via provided ECDSA signatures.
    /// @param multiDelegatedRequests The arguments of the delegated multi revocation attestation requests. The requests
    ///     should be grouped by distinct schema ids to benefit from the best batching optimization.
    ///
    /// Example:
    ///     multiRevokeByDelegation([{
    ///         schema: '0x8e72f5bc0a8d4be6aa98360baa889040c50a0e51f32dbf0baa5199bd93472ebc',
    ///         data: [{
    ///             uid: '0x211296a1ca0d7f9f2cfebf0daaa575bea9b20e968d81aef4e743d699c6ac4b25',
    ///             value: 1000
    ///         },
    ///         {
    ///             uid: '0xe160ac1bd3606a287b4d53d5d1d6da5895f65b4b4bab6d93aaf5046e48167ade',
    ///             value: 0
    ///         }],
    ///         signatures: [{
    ///             v: 28,
    ///             r: '0x148c...b25b',
    ///             s: '0x5a72...be22'
    ///         },
    ///         {
    ///             v: 28,
    ///             r: '0x487s...67bb',
    ///             s: '0x12ad...2366'
    ///         }],
    ///         revoker: '0x244934dd3e31bE2c81f84ECf0b3E6329F5381992',
    ///         deadline: 1673891048
    ///     }])
    function multiRevokeByDelegation(
        MultiDelegatedRevocationRequest[] calldata multiDelegatedRequests
    ) external payable;

    /// @notice Timestamps the specified bytes32 data.
    /// @param data The data to timestamp.
    /// @return The timestamp the data was timestamped with.
    function timestamp(bytes32 data) external returns (uint64);

    /// @notice Timestamps the specified multiple bytes32 data.
    /// @param data The data to timestamp.
    /// @return The timestamp the data was timestamped with.
    function multiTimestamp(bytes32[] calldata data) external returns (uint64);

    /// @notice Revokes the specified bytes32 data.
    /// @param data The data to timestamp.
    /// @return The timestamp the data was revoked with.
    function revokeOffchain(bytes32 data) external returns (uint64);

    /// @notice Revokes the specified multiple bytes32 data.
    /// @param data The data to timestamp.
    /// @return The timestamp the data was revoked with.
    function multiRevokeOffchain(bytes32[] calldata data) external returns (uint64);

    /// @notice Returns an existing attestation by UID.
    /// @param uid The UID of the attestation to retrieve.
    /// @return The attestation data members.
    function getAttestation(bytes32 uid) external view returns (Attestation memory);

    /// @notice Checks whether an attestation exists.
    /// @param uid The UID of the attestation to retrieve.
    /// @return Whether an attestation exists.
    function isAttestationValid(bytes32 uid) external view returns (bool);

    /// @notice Returns the timestamp that the specified data was timestamped with.
    /// @param data The data to query.
    /// @return The timestamp the data was timestamped with.
    function getTimestamp(bytes32 data) external view returns (uint64);

    /// @notice Returns the timestamp that the specified data was timestamped with.
    /// @param data The data to query.
    /// @return The timestamp the data was timestamped with.
    function getRevokeOffchain(address revoker, bytes32 data) external view returns (uint64);
}// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import { ISchemaResolver } from "./ISchemaResolver.sol";

/// @notice A struct representing a record for a submitted schema.
struct SchemaRecord {
    bytes32 uid; // The unique identifier of the schema.
    ISchemaResolver resolver; // Optional schema resolver.
    bool revocable; // Whether the schema allows revocations explicitly.
    string schema; // Custom specification of the schema (e.g., an ABI).
}

/// @title ISchemaRegistry
/// @notice The interface of global attestation schemas for the Ethereum Attestation Service protocol.
interface ISchemaRegistry {
    /// @notice Emitted when a new schema has been registered
    /// @param uid The schema UID.
    /// @param registerer The address of the account used to register the schema.
    /// @param schema The schema data.
    event Registered(bytes32 indexed uid, address indexed registerer, SchemaRecord schema);

    /// @notice Submits and reserves a new schema
    /// @param schema The schema data schema.
    /// @param resolver An optional schema resolver.
    /// @param revocable Whether the schema allows revocations explicitly.
    /// @return The UID of the new schema.
    function register(string calldata schema, ISchemaResolver resolver, bool revocable) external returns (bytes32);

    /// @notice Returns an existing schema by UID
    /// @param uid The UID of the schema to retrieve.
    /// @return The schema data members.
    function getSchema(bytes32 uid) external view returns (SchemaRecord memory);
}// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import { Attestation } from "./Common.sol";

/// @title ISchemaResolver
/// @notice The interface of an optional schema resolver.
interface ISchemaResolver {
    /// @notice Checks if the resolver can be sent ETH.
    /// @return Whether the resolver supports ETH transfers.
    function isPayable() external pure returns (bool);

    /// @notice Processes an attestation and verifies whether it's valid.
    /// @param attestation The new attestation.
    /// @return Whether the attestation is valid.
    function attest(Attestation calldata attestation) external payable returns (bool);

    /// @notice Processes multiple attestations and verifies whether they are valid.
    /// @param attestations The new attestations.
    /// @param values Explicit ETH amounts which were sent with each attestation.
    /// @return Whether all the attestations are valid.
    function multiAttest(
        Attestation[] calldata attestations,
        uint256[] calldata values
    ) external payable returns (bool);

    /// @notice Processes an attestation revocation and verifies if it can be revoked.
    /// @param attestation The existing attestation to be revoked.
    /// @return Whether the attestation can be revoked.
    function revoke(Attestation calldata attestation) external payable returns (bool);

    /// @notice Processes revocation of multiple attestation and verifies they can be revoked.
    /// @param attestations The existing attestations to be revoked.
    /// @param values Explicit ETH amounts which were sent with each revocation.
    /// @return Whether the attestations can be revoked.
    function multiRevoke(
        Attestation[] calldata attestations,
        uint256[] calldata values
    ) external payable returns (bool);
}// SPDX-License-Identifier: MIT

pragma solidity 0.8.19;

import { Pausable } from "@openzeppelin/contracts/security/Pausable.sol";

// prettier-ignore
import {
    EIP712Proxy,
    ECDSA,
    Signature,
    DelegatedProxyAttestationRequest,
    DelegatedProxyRevocationRequest,
    MultiDelegatedProxyAttestationRequest,
    MultiDelegatedProxyRevocationRequest,
    AttestationRequestData,
    RevocationRequestData,
    RevocationRequest
} from "./EIP712Proxy.sol";

import { IEAS } from "./IEAS.sol";

import { AccessDenied, uncheckedInc } from "./Common.sol";

///////////////////////////////////////////////////////////////
//  ___   __    ______   ___ __ __    ________  ______       //
// /__/\ /__/\ /_____/\ /__//_//_/\  /_______/\/_____/\      //
// \::\_\\  \ \\:::_ \ \\::\| \| \ \ \__.::._\/\::::_\/_     //
//  \:. `-\  \ \\:\ \ \ \\:.      \ \   \::\ \  \:\/___/\    //
//   \:. _    \ \\:\ \ \ \\:.\-/\  \ \  _\::\ \__\_::._\:\   //
//    \. \`-\  \ \\:\_\ \ \\. \  \  \ \/__\::\__/\ /____\:\  //
//     \__\/ \__\/ \_____\/ \__\/ \__\/\________\/ \_____\/  //
//                                                           //
///////////////////////////////////////////////////////////////

/// @title NomisEIP712Proxy
/// @author Nomis Labs
/// @notice A Nomis EIP712 proxy that allows only a specific address to attest and check the fees.
/// @custom:security-contact info@nomis.cc
contract NomisEIP712Proxy is 
    EIP712Proxy,
    Pausable
{
    /*#########################
    ##        Structs        ##
    ##########################*/

    /// @notice A struct representing the full arguments of the full delegated Nomis attestation request.
    struct NomisDelegatedProxyAttestationRequest {
        bytes32 schema; // The unique identifier of the schema.
        AttestationRequestData data; // The arguments of the attestation request.
        uint256 nonce; // The nonce from the NomisScore contract for attested wallet.
        bytes signature; // Nomis signature data.
    }

    /// @notice A struct representing the arguments of the full delegated revocation request.
    struct NomisDelegatedProxyRevocationRequest {
        bytes32 schema; // The unique identifier of the schema.
        RevocationRequestData data; // The arguments of the revocation request.
    }

    /*#########################
    ##       Variables       ##
    ##########################*/

    uint256 private _attestFee;

    bool private _checkSignatureEnabled = true;

    /*#########################
    ##        Mappings       ##
    ##########################*/

    /**
     * @dev A mapping of addresses to whitelist.
     */
    mapping(address => bool) public whitelist;

    /**
     * @dev The individual attest fee value for each address.
     */
    mapping(address => uint256) private _individualAttestFee;

    /*#########################
    ##        Modifiers      ##
    ##########################*/

    /**
     * @dev Modifier that checks if the passed fee is equal to the current attest fee set.
     * Requirements:
     * The fee passed must be equal to the current attest fee set.
     */
    modifier equalsFee() {
        address _recipient = msg.sender;
        uint256 _fee = msg.value;

        // check attest fee
        require(
            (_fee == _individualAttestFee[_recipient] && _fee > 0) ||
                whitelist[_recipient] ||
                _fee == _attestFee,
            "Attest fee: wrong attest fee value"
        );
        _;
    }

    /*#########################
    ##         Events        ##
    ##########################*/

    /**
     * @dev Emitted when a new Nomis attestation is created. 
     * @param recipient The address of the recipient wallet.
     * @param uid The unique identifier of the attestation.
     * @param attester The address of the attesting account.
     * @param tokenId The token id of the minted NomisScore.
     * @param updated The timestamp of the mint or last update of the NomisScore.
     * @param value The score value of the NomisScore.
     * @param chainId The chain id of the NomisScore.
     * @param calcModel The scoring calculation model of the NomisScore.
     */
    event NomisAttestation(
        address indexed recipient,
        bytes32 indexed uid,
        address indexed attester,
        uint256 tokenId,
        uint256 updated,
        uint16 value,
        uint256 chainId,
        uint16 calcModel
    );

    /**
     * @dev Emitted when the owner of the contract withdraws the funds from the contract balance.
     * @param owner The address of the owner who withdrew the funds.
     * @param balance The amount of funds withdrawn by the owner.
     */
    event Withdrawal(address indexed owner, uint256 indexed balance);

    /**
     * @dev Emitted when the recipient wallet is added to whitelist or removed from it.
     * @param recipient The address of the recipient wallet.
     * @param status The status of the recipient wallet in whitelist.
     */
    event ChangedWhitelistStatus(
        address indexed recipient,
        bool indexed status
    );

    /*#########################
    ##      Constructor      ##
    ##########################*/
    
    /// @dev Creates a new NomisEIP712Proxy instance.
    /// @param eas The address of the global EAS contract.
    /// @param name The user readable name of the signing domain.
    constructor(IEAS eas, string memory name) EIP712Proxy(eas, name) {
    }

    /*#########################
    ##    Write Functions    ##
    ##########################*/

    /// @notice Attests to a specific schema via the provided Nomis signature.
    /// @param delegatedRequest The arguments of the delegated attestation request.
    /// @return The UID of the new attestation.
    function attestByDelegationSimple(
        NomisDelegatedProxyAttestationRequest calldata delegatedRequest
    ) public payable whenNotPaused equalsFee returns (bytes32) {
        if (_checkSignatureEnabled) {
            _checkSignature(delegatedRequest.data.data, msg.sender, delegatedRequest.nonce, delegatedRequest.signature);
        }

        DelegatedProxyAttestationRequest memory request = DelegatedProxyAttestationRequest(
            delegatedRequest.schema,
            delegatedRequest.data,
            Signature(0, 0, 0),
            owner(),
            0
        );

        bytes32 uid = super.attestByDelegationSimple(request);

        (uint256 tokenId, uint256 updated, uint16 value, uint256 chainId, uint16 calcModel) = decodeAttestationData(delegatedRequest.data.data);
        emit NomisAttestation(delegatedRequest.data.recipient, uid, owner(), tokenId, updated, value, chainId, calcModel);

        return uid;
    }

    /// @notice Revokes a specific attestation.
    function revokeByDelegationSimple(
        NomisDelegatedProxyRevocationRequest calldata delegatedRequest
    ) public whenNotPaused onlyOwner {

        RevocationRequest memory request = RevocationRequest(
            delegatedRequest.schema,
            delegatedRequest.data
        );

        super.revokeByDelegationSimple(request);
    }

    /// @dev Set the check signature enabled or disabled.
    /// @param enabled The check signature enabled or disabled.
    /// @notice Only the contract owner can call this function.
    function setCheckSignatureEnabled(bool enabled) external onlyOwner {
        _checkSignatureEnabled = enabled;
    }

    /// @inheritdoc EIP712Proxy
    function attestByDelegation(
        DelegatedProxyAttestationRequest calldata delegatedRequest
    ) public payable whenNotPaused equalsFee onlyOwner override returns (bytes32) {
        // Ensure that only the owner is allowed to delegate attestations.
        _verifyAttester(delegatedRequest.attester);

        return super.attestByDelegation(delegatedRequest);
    }

    /// @inheritdoc EIP712Proxy
    /// @notice Only the contract owner can call this function.
    function multiAttestByDelegation(
        MultiDelegatedProxyAttestationRequest[] calldata multiDelegatedRequests
    ) public payable onlyOwner whenNotPaused equalsFee override returns (bytes32[] memory) {
        uint256 length = multiDelegatedRequests.length;
        for (uint256 i = 0; i < length; i = uncheckedInc(i)) {
            // Ensure that only the owner is allowed to delegate attestations.
            _verifyAttester(multiDelegatedRequests[i].attester);
        }

        return super.multiAttestByDelegation(multiDelegatedRequests);
    }

    /// @inheritdoc EIP712Proxy
    function revokeByDelegation(DelegatedProxyRevocationRequest calldata delegatedRequest) public payable override {
        // Ensure that only the owner is allowed to delegate revocations.
        _verifyAttester(delegatedRequest.revoker);

        super.revokeByDelegation(delegatedRequest);
    }

    /// @inheritdoc EIP712Proxy
    function multiRevokeByDelegation(
        MultiDelegatedProxyRevocationRequest[] calldata multiDelegatedRequests
    ) public payable onlyOwner override {
        uint256 length = multiDelegatedRequests.length;
        for (uint256 i = 0; i < length; i = uncheckedInc(i)) {
            // Ensure that only the owner is allowed to delegate revocations.
            _verifyAttester(multiDelegatedRequests[i].revoker);
        }

        super.multiRevokeByDelegation(multiDelegatedRequests);
    }

    /**
     * @dev Adds the given addresses to the whitelist.
     * @param actors The addresses to be added to the whitelist.
     */
    function whitelistAddresses(
        address[] calldata actors
    ) external onlyOwner {
        for (uint256 i = 0; i < actors.length; ++i) {
            whitelist[actors[i]] = true;

            emit ChangedWhitelistStatus(actors[i], true);
        }
    }

    /**
     * @dev Removes the given addresses from the whitelist.
     * @param actors The addresses to be removed from the whitelist.
     */
    function unWhitelistAddresses(
        address[] calldata actors
    ) external onlyOwner {
        for (uint256 i = 0; i < actors.length; ++i) {
            whitelist[actors[i]] = false;

            emit ChangedWhitelistStatus(actors[i], false);
        }
    }

    /**
     * @dev Allows the contract owner to withdraw a specific amount of native balance held by the contract.
     * Can only be called by the owner.
     * Emits a {Withdrawal} event upon successful withdrawal.
     * Throws a require error if there are no funds available for withdrawal.
     * Throws a require error if the specified withdrawal amount is greater than the contract balance.
     * @param amount The amount of balance to be withdrawn.
     */
    function withdraw(uint256 amount) external onlyOwner {
        uint256 balance = address(this).balance;
        require(balance > 0, "Withdrawal: No funds available");
        require(amount <= balance, "Withdrawal: Insufficient funds");

        (bool success, ) = msg.sender.call{value: amount}("");
        require(success, "Withdrawal: transfer failed");

        emit Withdrawal(msg.sender, amount);
    }

    /**
     * @dev Sets the new attest fee.
     * @param attestFee The new attest fee.
     * @notice Only the contract owner can call this function.
     */
    function setAttestFee(uint256 attestFee) external onlyOwner {
        _attestFee = attestFee;
    }

    /**
     * @dev Sets the individual attest fee for the given address.
     * @param recipient The address to set the individual attest fee for.
     * @param fee The individual attest fee.
     * @notice Only the contract owner can call this function.
     */
    function setIndividualAttestFee(
        address recipient,
        uint256 fee
    ) external onlyOwner {
        _individualAttestFee[recipient] = fee;
    }

    /// @dev Ensures that only the allowed attester can attest.
    /// @param attester The attester to verify.
    function _verifyAttester(address attester) private view {
        if (attester != owner()) {
            revert AccessDenied();
        }
    }

    function _checkSignature(
        bytes memory _attestationData,
        address _txSender,
        uint256 _nonce,
        bytes memory _signature
    ) private view {
        // Decode the attestation payload using abi.decode
        (uint256 tokenId, uint256 updated, uint16 value, uint256 chainId, uint16 calcModel) = decodeAttestationData(_attestationData);

        // Verify the signer of the message
        bytes32 messageHash = _hashTypedDataV4(
            keccak256(
                abi.encode(
                    keccak256(
                        "BASAttestationMessage(uint256 tokenId,uint256 updated,uint16 value,uint256 chainId,uint16 calcModel,uint256 nonce,address to)"
                    ),
                    tokenId,
                    updated,
                    value,
                    chainId,
                    calcModel,
                    _nonce,
                    _txSender
                )
            )
        );

        address signer = ECDSA.recover(messageHash, _signature);
        require(signer == owner() && signer != address(0), "_checkSignature: Invalid signature");
    }

    /**
     * @dev Pauses the contract.
     * See {Pausable-_pause}.
     * Can only be called by the owner.
     */
    function pause() external onlyOwner {
        _pause();
    }

    /**
     * @dev Unpauses the contract.
     * See {Pausable-_unpause}.
     * Can only be called by the owner.
     */
    function unpause() external onlyOwner {
        _unpause();
    }

    /*#########################
    ##    Read Functions    ##
    ##########################*/

    /**
     * @dev Returns the check signature enabled or disabled.
     * @return The check signature enabled or disabled.
     */
    function getCheckSignatureEnabled() external view returns (bool) {
        return _checkSignatureEnabled;
    }

    /**
     * @dev Returns the attestation data.
     * @param _attestationData The attestation data.
     * @return tokenId The token id of the minted NomisScore.
     * @return updated The timestamp of the mint or last update of the NomisScore.
     * @return value The score value of the NomisScore.
     * @return chainId The chain id of the NomisScore.
     * @return calcModel The scoring calculation model of the NomisScore.
     */
    function decodeAttestationData(
        bytes memory _attestationData
    ) public pure returns (
        uint256 tokenId,
        uint256 updated,
        uint16 value,
        uint256 chainId,
        uint16 calcModel
    ) {
        return abi.decode(_attestationData, (uint256, uint256, uint16, uint256, uint16));
    }

    /**
     * @dev Returns the current attest fee.
     * @return The current attest fee.
     */
    function getAttestFee() external view returns (uint256) {
        return _attestFee;
    }

    /**
     * @dev Sets the individual attest fee for the given address.
     * @param recipient The address to set the individual attest fee for.
     * @return The individual attest fee.
     * @notice Only the contract owner can call this function.
     */
    function getIndividualAttestFee(
        address recipient
    ) external view returns (uint256) {
        return _individualAttestFee[recipient];
    }
}// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

import { Strings } from "@openzeppelin/contracts/utils/Strings.sol";

/// @title Semver
/// @notice A simple contract for managing contract versions.
contract Semver {
    // Contract's major version number.
    uint256 private immutable _major;

    // Contract's minor version number.
    uint256 private immutable _minor;

    // Contract's patch version number.
    uint256 private immutable _path;

    /// @dev Create a new Semver instance.
    /// @param major Major version number.
    /// @param minor Minor version number.
    /// @param patch Patch version number.
    constructor(uint256 major, uint256 minor, uint256 patch) {
        _major = major;
        _minor = minor;
        _path = patch;
    }

    /// @notice Returns the full semver contract version.
    /// @return Semver contract version as a string.
    function version() external view returns (string memory) {
        return
            string(
                abi.encodePacked(Strings.toString(_major), ".", Strings.toString(_minor), ".", Strings.toString(_path))
            );
    }
}