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
// SPDX-License-Identifier: BUSL-1.1
/*
Business Source License 1.1

License text copyright © 2023 MariaDB plc, All Rights Reserved. “Business Source License” is a trademark of MariaDB plc.

Parameters

Licensor: DFlow Inc.
Licensed Work: The Licensed Work is © 2023 DFlow Inc.
Additional Use Grant: The Licensed Work may be used in production contexts, provided that any such use does not compete
with DFlow Inc.'s products.
Change Date: 2027-10-11
Change License: GNU General Public License v2.0

Terms

The Licensor hereby grants you the right to copy, modify, create derivative works, redistribute, and make non-production
use of the Licensed Work. The Licensor may make an Additional Use Grant, above, permitting limited production use.

Effective on the Change Date, or the fourth anniversary of the first publicly available distribution of a specific version
of the Licensed Work under this License, whichever comes first, the Licensor hereby grants you rights under the terms of
the Change License, and the rights granted in the paragraph above terminate.

If your use of the Licensed Work does not comply with the requirements currently in effect as described in this License,
you must purchase a commercial license from the Licensor, its affiliated entities, or authorized resellers, or you must
refrain from using the Licensed Work.

All copies of the original and modified Licensed Work, and derivative works of the Licensed Work, are subject to this
License.  This License applies separately for each version of the Licensed Work and the Change Date may vary for each
version of the Licensed Work released by Licensor.

You must conspicuously display this License on each original or modified copy of the Licensed Work. If you receive the
Licensed Work in original or modified form from a third party, the terms and conditions set forth in this License apply
to your use of that work.

Any use of the Licensed Work in violation of this License will automatically terminate your rights under this License for
the current and all other versions of the Licensed Work.

This License does not grant you any right in any trademark or logo of Licensor or its affiliates (provided that you may
use a trademark or logo of Licensor as expressly required by this License).TO THE EXTENT PERMITTED BY APPLICABLE LAW, THE
LICENSED WORK IS PROVIDED ON AN “AS IS” BASIS. LICENSOR HEREBY DISCLAIMS ALL WARRANTIES AND CONDITIONS, EXPRESS OR IMPLIED,
INCLUDING (WITHOUT LIMITATION) WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, NON-INFRINGEMENT, AND TITLE.

MariaDB hereby grants you permission to use this License’s text to license your works, and to refer to it using the trademark
“Business Source License”, as long as you comply with the Covenants of Licensor below.

Covenants of Licensor

In consideration of the right to use this License’s text and the “Business Source License” name and trademark, Licensor
covenants to MariaDB, and to all other recipients of the licensed work to be provided by Licensor:

To specify as the Change License the GPL Version 2.0 or any later version, or a license that is compatible with GPL Version 2.0
or a later version, where “compatible” means that software provided under the Change License can be included in a program
with software provided under GPL Version 2.0 or a later version. Licensor may specify additional Change Licenses without
limitation.

To either: (a) specify an additional grant of rights to use that does not impose any additional restriction on the right granted
in this License, as the Additional Use Grant; or (b) insert the text “None” to specify a Change Date. Not to modify this License
in any other way.

Notice

The Business Source License (this document, or the “License”) is not an Open Source license. However, the Licensed Work will
eventually be made available under an Open Source License, as stated in this License.
*/

pragma solidity ^0.8.0;

import "./IERC2612WithBytesSignature.sol";
import "./INativeMetaTransaction.sol";
import "./ISignatureTransfer.sol";
import "./IWETH.sol";
import "@openzeppelin/contracts/interfaces/IERC5267.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

/// @title DFlowSwap
/// @notice Facilitates ERC-20 and native token swaps
contract DFlowSwap is IERC5267 {
    // ERC-20 transfer implementation from 0x
    // Mask of the lower 20 bytes of a bytes32.
    uint256 private constant ADDRESS_MASK = 0x000000000000000000000000ffffffffffffffffffffffffffffffffffffffff;

    /// @dev Transfers ERC20 tokens from `owner` to `to`.
    /// @param token The token to spend.
    /// @param owner The owner of the tokens.
    /// @param to The recipient of the tokens.
    /// @param amount The amount of `token` to transfer.
    function _transferERC20TokensFrom(IERC20 token, address owner, address to, uint256 amount) internal {
        assembly {
            let ptr := mload(0x40) // free memory pointer

            // selector for transferFrom(address,address,uint256)
            mstore(ptr, 0x23b872dd00000000000000000000000000000000000000000000000000000000)
            mstore(add(ptr, 0x04), and(owner, ADDRESS_MASK))
            mstore(add(ptr, 0x24), and(to, ADDRESS_MASK))
            mstore(add(ptr, 0x44), amount)

            let success := call(gas(), and(token, ADDRESS_MASK), 0, ptr, 0x64, ptr, 32)

            let rdsize := returndatasize()

            // Check for ERC20 success. ERC20 tokens should return a boolean,
            // but some don't. We accept 0-length return data as success, or at
            // least 32 bytes that starts with a 32-byte boolean true.
            success := and(
                success, // call itself succeeded
                or(
                    iszero(rdsize), // no return data, or
                    and(
                        iszero(lt(rdsize, 32)), // at least 32 bytes
                        eq(mload(ptr), 1) // starts with uint256(1)
                    )
                )
            )

            if iszero(success) {
                returndatacopy(ptr, 0, rdsize)
                revert(ptr, rdsize)
            }
        }
    }

    /// @dev Transfers ERC20 tokens from ourselves to `to`.
    /// @param token The token to spend.
    /// @param to The recipient of the tokens.
    /// @param amount The amount of `token` to transfer.
    function _transferERC20Tokens(IERC20 token, address to, uint256 amount) internal {
        assembly {
            let ptr := mload(0x40) // free memory pointer

            // selector for transfer(address,uint256)
            mstore(ptr, 0xa9059cbb00000000000000000000000000000000000000000000000000000000)
            mstore(add(ptr, 0x04), and(to, ADDRESS_MASK))
            mstore(add(ptr, 0x24), amount)

            let success := call(gas(), and(token, ADDRESS_MASK), 0, ptr, 0x44, ptr, 32)

            let rdsize := returndatasize()

            // Check for ERC20 success. ERC20 tokens should return a boolean,
            // but some don't. We accept 0-length return data as success, or at
            // least 32 bytes that starts with a 32-byte boolean true.
            success := and(
                success, // call itself succeeded
                or(
                    iszero(rdsize), // no return data, or
                    and(
                        iszero(lt(rdsize, 32)), // at least 32 bytes
                        eq(mload(ptr), 1) // starts with uint256(1)
                    )
                )
            )

            if iszero(success) {
                returndatacopy(ptr, 0, rdsize)
                revert(ptr, rdsize)
            }
        }
    }

    function _withdrawWETH(uint256 amount) internal {
        IWETH weth = WETH;
        assembly ("memory-safe") {
            // selector for withdraw(uint256)
            mstore(0, 0x2e1a7d4d00000000000000000000000000000000000000000000000000000000)
            mstore(4, amount)
            let success := call(gas(), and(weth, ADDRESS_MASK), 0, 0, 0x24, 0, 0)
            if iszero(success) {
                let ptr := mload(0x40)
                let rdsize := returndatasize()
                returndatacopy(ptr, 0, rdsize)
                revert(ptr, rdsize)
            }
        }
    }

    function _depositWETH(uint256 amount) internal {
        IWETH weth = WETH;
        assembly ("memory-safe") {
            // selector for deposit
            mstore(0, 0xd0e30db000000000000000000000000000000000000000000000000000000000)
            let success := call(gas(), and(weth, ADDRESS_MASK), amount, 0, 4, 0, 0)
            if iszero(success) {
                let ptr := mload(0x40)
                let rdsize := returndatasize()
                returndatacopy(ptr, 0, rdsize)
                revert(ptr, rdsize)
            }
        }
    }

    uint256 private constant EIP2098_S_MASK = 0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff;

    /// @dev Encodes conventional permit fields as calldata
    /// @param r The r value of the EIP-2098 representation of the signature of the permit
    /// @param vs The vs value of the EIP-2098 representation of the signature of the permit
    /// @return permit Encoded permit
    function encodeConventionalPermit(
        bytes32 r,
        bytes32 vs
    ) external pure returns (bytes memory permit) {
        return abi.encodePacked(r, vs);
    }

    /// @dev Encodes DAI permit fields as calldata
    /// @param nonce The nonce of the permit
    /// @param r The r value of the EIP-2098 representation of the signature of the permit
    /// @param vs The vs value of the EIP-2098 representation of the signature of the permit
    /// @return permit Encoded permit
    function encodeDaiPermit(
        uint32 nonce,
        bytes32 r,
        bytes32 vs
    ) external pure returns (bytes memory permit) {
        return abi.encodePacked(nonce, r, vs);
    }

    /// @dev Encodes permit fields as calldata for a taker token that implements the ERC-2612-like
    /// permit interface of the form
    ///    permit(address owner, address spender, uint256 value, uint256 deadline, bytes memory signature)
    /// @param signature The signature of the permit
    /// @return permit Encoded permit
    function encodePermitWithBytesSignature(
        bytes memory signature
    ) external pure returns (bytes memory permit) {
        if (signature.length < 64) {
            return signature;
        }
        return abi.encodePacked(bytes5(0), signature);
    }

    /// @dev Consumes the permit from the taker (msg.sender)
    /// @param takerToken The taker token
    /// @param takerAmount The taker amount
    /// @param expiry The order expiry and the expiry of the permit
    /// @param permit The permit data. Content depends on the takerToken.
    ///
    /// If the takerToken implements the ERC-2612 permit interface, the permit bytes are of the form
    /// [bytes32 r, bytes32 vs] where r and vs are the compact EIP-2098 representation
    /// of the taker's signature of a permit of the form
    /// `spender=this contract, value=order.takerAmount, deadline=order.expiry`.
    ///
    /// If the takerToken implements the DAI permit interface, the permit bytes are of the form
    /// [uint32 nonce, bytes32 r, bytes32 vs] where r and vs are the compact EIP-2098 representation
    /// of the taker's signature of a permit of the form
    /// `spender=this contract, nonce=nonce, expiry=order.expiry, allowed=true`.
    ///
    /// If the takerToken implements the ERC-2612-like permit interface of the form,
    ///    permit(address owner, address spender, uint256 value, uint256 deadline, bytes memory signature),
    /// the permit bytes are either of the form [bytes signature] if the signature is less than 64
    /// bytes in length or of the form [bytes5 padding, bytes signature] if the signature is at least
    /// 64 bytes in length.
    function _consumePermitFromTaker(
        IERC20 takerToken,
        uint256 takerAmount,
        uint256 expiry,
        bytes calldata permit
    ) internal {
        if (permit.length == 64) {
            // ERC-2612 permit
            assembly ("memory-safe") {
                let ptr := mload(0x40)
                // selector for permit(address owner, address spender, uint256 value, uint256 deadline, uint8 v, bytes32 r, bytes32 s)
                mstore(ptr, 0xd505accf00000000000000000000000000000000000000000000000000000000)
                mstore(add(ptr, 0x04), caller())                  // owner
                mstore(add(ptr, 0x24), address())                 // spender
                mstore(add(ptr, 0x44), takerAmount)               // value
                mstore(add(ptr, 0x64), expiry)                    // deadline
                let vs := calldataload(add(permit.offset, 0x20))
                mstore(add(ptr, 0x84), add(27, shr(255, vs)))     // v: most significant bit of vs + 27 (27 or 28)
                calldatacopy(add(ptr, 0xa4), permit.offset, 0x20) // r
                let s := and(vs, EIP2098_S_MASK)
                mstore(add(ptr, 0xc4), s)                         // s: vs without most significant bit
                let success := call(gas(), and(takerToken, ADDRESS_MASK), 0, ptr, 0xe4, 0, 0)
                if iszero(success) {
                    let rdsize := returndatasize()
                    returndatacopy(ptr, 0, rdsize)
                    revert(ptr, rdsize)
                }
            }
        } else if (permit.length == 68) {
            // DAI permit
            assembly ("memory-safe") {
                let ptr := mload(0x40)
                // selector for permit(address holder, address spender, uint256 nonce, uint256 expiry, bool allowed, uint8 v, bytes32 r, bytes32 s)
                mstore(ptr, 0x8fcbaf0c00000000000000000000000000000000000000000000000000000000)
                mstore(add(ptr, 0x04), caller())                              // holder
                mstore(add(ptr, 0x24), address())                             // spender
                mstore(add(ptr, 0x44), shr(224, calldataload(permit.offset))) // nonce
                mstore(add(ptr, 0x64), expiry)                                // expiry
                mstore(add(ptr, 0x84), true)                                  // allowed
                let vs := calldataload(add(permit.offset, 0x24))
                mstore(add(ptr, 0xa4), add(27, shr(255, vs)))                 // v: most significant bit of vs + 27 (27 or 28)
                calldatacopy(add(ptr, 0xc4), add(permit.offset, 0x04), 0x20)  // r
                let s := and(vs, EIP2098_S_MASK)
                mstore(add(ptr, 0xe4), s)                                     // s: vs without most significant bit
                let success := call(gas(), and(takerToken, ADDRESS_MASK), 0, ptr, 0x104, 0, 0)
                if iszero(success) {
                    let rdsize := returndatasize()
                    returndatacopy(ptr, 0, rdsize)
                    revert(ptr, rdsize)
                }
            }
        } else if (permit.length > 68) {
            // ERC-2612-like permit interface that takes the signature as bytes
            // If the permit passed into this function is longer than 68 bytes, cut off the first 5
            // bytes so that we can handle signature lengths between 64 and 68 bytes without
            // matching the lengths for the other permit types.
            IERC2612WithBytesSignature(address(takerToken)).permit(msg.sender, address(this), takerAmount, expiry, permit[5:]);
        } else if (permit.length > 63) {
            revert InvalidPermitLength();
        } else {
            // ERC-2612-like permit interface that takes the signature as bytes
            IERC2612WithBytesSignature(address(takerToken)).permit(msg.sender, address(this), takerAmount, expiry, permit);
        }
    }

    // Using this implementation of the domain separator instead of OpenZeppelin's implementation
    // saves gas; however, it should be noted that this version doesn't protect against replay
    // attacks on a fork of the chain.
    bytes32 private constant DOMAIN_SEPARATOR_TYPEHASH = keccak256(
        "EIP712Domain("
            "string name,"
            "string version,"
            "uint256 chainId,"
            "address verifyingContract"
        ")"
    );
    string private constant NAME = "DFlowSwap";
    string private constant VERSION = "1";
    bytes32 public immutable DOMAIN_SEPARATOR = keccak256(abi.encode(
        DOMAIN_SEPARATOR_TYPEHASH,
        keccak256(bytes(NAME)),
        keccak256(bytes(VERSION)),
        block.chainid,
        address(this)
    ));

    /// @dev See ERC-5267
    function eip712Domain() public view returns (
        bytes1 fields,
        string memory name,
        string memory version,
        uint256 chainId,
        address verifyingContract,
        bytes32 salt,
        uint256[] memory extensions
    ) {
        return (
            hex"0f", // 01111
            NAME,
            VERSION,
            block.chainid,
            address(this),
            bytes32(0),
            new uint256[](0)
        );
    }

    IWETH private immutable WETH;
    ISignatureTransfer private immutable PERMIT2;

    /// @dev Map of bytes32(nonce bucket << 160 | address) to order nonce. Orders should be
    /// constructed using the current nonce. When constructing an order whose IsFloatingTxOrigin
    /// flag is set, the address in the key is msg.sender. When constructing an order whose
    /// IsFloatingTxOrigin flag is unset, the address in the key is tx.origin.
    mapping(bytes32 addressAndNonceBucket => uint256 nonce) public orderNonces;

    /// @dev Encodes a key that can be used to look up the order nonce for the given nonce bucket
    /// and tx origin or msg sender.
    /// @param txOriginOrMsgSender The tx origin or the msg sender
    /// @param nonceBucket The nonce bucket
    /// @return key Encoded nonces key that can be used to look up the order nonce
    function encodeNonceKey(
        address txOriginOrMsgSender,
        uint64 nonceBucket
    ) external pure returns (bytes32 key) {
        return bytes32(uint256(nonceBucket) << 160) | bytes32(uint256(uint160(txOriginOrMsgSender)));
    }

    constructor(IWETH weth, ISignatureTransfer permit2) {
        WETH = weth;
        PERMIT2 = permit2;
    }

    /// @dev Emitted whenever an order is filled
    /// @param orderHash The order hash
    event OrderFilled(bytes32 orderHash);

    uint256 private constant ECRECOVER_ADDR = 0x1;
    uint256 private constant TYPEHASH_SIZE = 32;
    uint256 private constant TYPEHASH_AND_TXORIGIN_SIZE = 32 + 32;
    uint256 private constant TYPEHASH_AND_TXORIGIN_AND_TAKER_SIZE = 32 + 32 + 32;
    uint256 private constant TYPEHASH_AND_TXORIGIN_AND_TAKER_AND_MSGVALUE_SIZE = 32 + 32 + 32 + 32;

    /// @dev Encodes makerAmountAndTakerAmount from maker amount and taker amount
    /// @param makerAmount The maker amount
    /// @param takerAmount The taker amount
    /// @return makerAmountAndTakerAmount Encoded maker amount and taker amount
    function encodeMakerAmountAndTakerAmount(
        uint128 makerAmount,
        uint128 takerAmount
    ) external pure returns (uint256 makerAmountAndTakerAmount) {
        return uint256(makerAmount) << 128 | takerAmount;
    }

    /// @dev Decodes maker amount and taker amount from makerAmountAndTakerAmount
    /// @param makerAmountAndTakerAmount Encoded maker amount and taker amount
    /// @return makerAmount The maker amount
    /// @return takerAmount The taker amount
    function decodeMakerAmountAndTakerAmount(
        uint256 makerAmountAndTakerAmount
    ) external pure returns (
        uint128 makerAmount,
        uint128 takerAmount
    ) {
        return (uint128(makerAmountAndTakerAmount >> 128), uint128(makerAmountAndTakerAmount));
    }

    /// @dev If this expiryFlagsAndNonce bit is set, the order allows any EOA to send the fill
    /// transaction
    uint256 private constant ORDER_FLAG_IS_FLOATING_TX_ORIGIN = 1 << 128;

    /// @dev Encodes expiryFlagsAndNonce from expiry, flags, nonceBucket, and nonce
    /// @param expiry The expiry
    /// @param isFloatingTxOrigin True if and only if the order allows any EOA to send the fill
    /// transaction
    /// @param nonceBucket The nonce bucket
    /// @param nonce The nonce
    /// @return expiryFlagsAndNonce Encoded expiry, flags, nonce bucket, and nonce
    function encodeExpiryFlagsAndNonce(
        uint64 expiry,
        bool isFloatingTxOrigin,
        uint64 nonceBucket,
        uint64 nonce
    ) external pure returns (uint256 expiryFlagsAndNonce) {
        uint256 value = (uint256(expiry) << 192) | (uint256(nonceBucket) << 64) | nonce;
        if (isFloatingTxOrigin) {
            value |= ORDER_FLAG_IS_FLOATING_TX_ORIGIN;
        }
        return value;
    }

    /// @dev Decodes expiry, flags, nonceBucket, and nonce from expiryFlagsAndNonce
    /// @param expiryFlagsAndNonce Encoded expiry, flags, nonce bucket, and nonce
    /// @return expiry The expiry
    /// @return isFloatingTxOrigin True if and only if the order allows any EOA to send the fill
    /// transaction
    /// @return nonceBucket The nonce bucket
    /// @return nonce The nonce
    function decodeExpiryFlagsAndNonce(uint256 expiryFlagsAndNonce) external pure returns (
        uint64 expiry,
        bool isFloatingTxOrigin,
        uint64 nonceBucket,
        uint64 nonce
    ) {
        return (
            uint64(expiryFlagsAndNonce >> 192),
            (expiryFlagsAndNonce & ORDER_FLAG_IS_FLOATING_TX_ORIGIN) > 0,
            uint64(expiryFlagsAndNonce >> 64),
            uint64(expiryFlagsAndNonce)
        );
    }

    /// @dev An ERC-20 to ERC-20 order.
    /// When signing, `address txOrigin` must be included as the first field, and `address taker`
    /// must be included as the second field. If the IsFloatingTxOrigin flag is set, the
    /// `address txOrigin` must be the zero address.
    struct Order {
        IERC20 makerToken;
        IERC20 takerToken;
        // [uint128 makerAmount, uint128 takerAmount]
        uint256 makerAmountAndTakerAmount;
        // [uint64 expiry, uint64 flags, uint64 nonceBucket, uint64 nonce]
        uint256 expiryFlagsAndNonce;
    }
    /// @dev
    /// keccak256(
    ///     "Order("
    ///         "address txOrigin,"
    ///         "address taker,"
    ///         "address makerToken,"
    ///         "address takerToken,"
    ///         "uint256 makerAmountAndTakerAmount,"
    ///         "uint256 expiryFlagsAndNonce"
    ///     ")"
    /// );
    bytes32 private constant ORDER_TYPEHASH = 0xacff7b34fe36ec0f95004c6e5bc16c7aa0843c38b31347054c0fe230b1d6bc9a;
    uint256 private constant ORDER_STRUCT_SIZE = 32 * 4;
    // TYPEHASH_AND_TXORIGIN_AND_TAKER_SIZE + STRUCT_SIZE
    uint256 private constant TYPEHASH_AND_ORDER_SIZE = 32 + 32 + 32 + (32 * 4);
    function hashOrder(
        Order calldata order,
        address txOrigin,
        address taker
    ) external view returns (bytes32) {
        bytes32 orderHash;
        assembly ("memory-safe") {
            let ptr := mload(0x40)
            mstore(ptr, ORDER_TYPEHASH)
            mstore(add(ptr, TYPEHASH_SIZE), and(txOrigin, ADDRESS_MASK))
            mstore(add(ptr, TYPEHASH_AND_TXORIGIN_SIZE), and(taker, ADDRESS_MASK))
            calldatacopy(add(ptr, TYPEHASH_AND_TXORIGIN_AND_TAKER_SIZE), order, ORDER_STRUCT_SIZE)
            orderHash := keccak256(ptr, TYPEHASH_AND_ORDER_SIZE)
        }
        return ECDSA.toTypedDataHash(DOMAIN_SEPARATOR, orderHash);
    }

    /// @dev An ERC-20 to ERC-20 order with a platform fee.
    /// When signing, `address txOrigin` must be included as the first field, and `address taker`
    /// must be included as the second field. If the IsFloatingTxOrigin flag is set, the
    /// `address txOrigin` must be the zero address.
    struct OrderWithFee {
        IERC20 makerToken;
        IERC20 takerToken;
        // [uint128 makerAmount, uint128 takerAmount]
        uint256 makerAmountAndTakerAmount;
        // [uint64 expiry, uint64 flags, uint64 nonceBucket, uint64 nonce]
        uint256 expiryFlagsAndNonce;
        address platformFeeReceiver;
        // The platform fee paid by the maker in the maker token. The maker pays this amount in
        // addition to the makerAmount.
        uint256 platformFee;
    }
    /// @dev
    /// keccak256(
    ///     "OrderWithFee("
    ///         "address txOrigin,"
    ///         "address taker,"
    ///         "address makerToken,"
    ///         "address takerToken,"
    ///         "uint256 makerAmountAndTakerAmount,"
    ///         "uint256 expiryFlagsAndNonce,"
    ///         "address platformFeeReceiver,"
    ///         "uint256 platformFee"
    ///     ")"
    /// );
    bytes32 private constant ORDER_WITH_FEE_TYPEHASH = 0x7630246c687fccf33490cc9c31fa417a0d3b73931463eea384972445e31e0d59;
    uint256 private constant ORDER_WITH_FEE_STRUCT_SIZE = 32 * 6;
    // TYPEHASH_AND_TXORIGIN_AND_TAKER_SIZE + STRUCT_SIZE
    uint256 private constant TYPEHASH_AND_ORDER_WITH_FEE_SIZE = 32 + 32 + 32 + (32 * 6);
    function hashOrderWithFee(
        OrderWithFee calldata order,
        address txOrigin,
        address taker
    ) external view returns (bytes32) {
        bytes32 orderHash;
        assembly ("memory-safe") {
            let ptr := mload(0x40)
            mstore(ptr, ORDER_WITH_FEE_TYPEHASH)
            mstore(add(ptr, TYPEHASH_SIZE), and(txOrigin, ADDRESS_MASK))
            mstore(add(ptr, TYPEHASH_AND_TXORIGIN_SIZE), and(taker, ADDRESS_MASK))
            calldatacopy(add(ptr, TYPEHASH_AND_TXORIGIN_AND_TAKER_SIZE), order, ORDER_WITH_FEE_STRUCT_SIZE)
            orderHash := keccak256(ptr, TYPEHASH_AND_ORDER_WITH_FEE_SIZE)
        }
        return ECDSA.toTypedDataHash(DOMAIN_SEPARATOR, orderHash);
    }

    /// @dev An ETH to ERC-20 order.
    /// When signing, `address txOrigin` must be included as the first field, `address taker` must
    /// be included as the second field, and `uint256 takerAmount` must be included as the third
    /// field. If the IsFloatingTxOrigin flag is set, the `address txOrigin` must be the zero
    /// address.
    struct OrderWithEth {
        IERC20 makerToken;
        uint256 makerAmount;
        // [uint64 expiry, uint64 flags, uint64 nonceBucket, uint64 nonce]
        uint256 expiryFlagsAndNonce;
    }
    /// @dev
    /// keccak256(
    ///     "OrderWithEth("
    ///         "address txOrigin,"
    ///         "address taker,"
    ///         "uint256 takerAmount,"
    ///         "address makerToken,"
    ///         "uint256 makerAmount,"
    ///         "uint256 expiryFlagsAndNonce"
    ///     ")"
    /// );
    bytes32 private constant ORDER_WITH_ETH_TYPEHASH = 0x7631f631b0ca9fda01df330722d8c71ce667c739ea8dcad7c99e14b3d205d143;
    uint256 private constant ORDER_WITH_ETH_STRUCT_SIZE = 32 * 3;
    // TYPEHASH_AND_TXORIGIN_AND_TAKER_AND_MSGVALUE_SIZE + STRUCT_SIZE
    uint256 private constant TYPEHASH_AND_ORDER_WITH_ETH_SIZE = 32 + 32 + 32 + 32 + (32 * 3);
    function hashOrderWithEth(
        OrderWithEth calldata order,
        address txOrigin,
        address taker,
        uint256 takerAmount
    ) external view returns (bytes32) {
        bytes32 orderHash;
        assembly ("memory-safe") {
            let ptr := mload(0x40)
            mstore(ptr, ORDER_WITH_ETH_TYPEHASH)
            mstore(add(ptr, TYPEHASH_SIZE), and(txOrigin, ADDRESS_MASK))
            mstore(add(ptr, TYPEHASH_AND_TXORIGIN_SIZE), and(taker, ADDRESS_MASK))
            mstore(add(ptr, TYPEHASH_AND_TXORIGIN_AND_TAKER_SIZE), takerAmount)
            calldatacopy(add(ptr, TYPEHASH_AND_TXORIGIN_AND_TAKER_AND_MSGVALUE_SIZE), order, ORDER_WITH_ETH_STRUCT_SIZE)
            orderHash := keccak256(ptr, TYPEHASH_AND_ORDER_WITH_ETH_SIZE)
        }
        return ECDSA.toTypedDataHash(DOMAIN_SEPARATOR, orderHash);
    }

    /// @dev An ETH to ERC-20 order with a platform fee.
    /// When signing, `address txOrigin` must be included as the first field, `address taker` must
    /// be included as the second field, and `uint256 takerAmount` must be included as the third
    /// field. If the IsFloatingTxOrigin flag is set, the `address txOrigin` must be the zero
    /// address.
    struct OrderWithEthWithFee {
        IERC20 makerToken;
        uint256 makerAmount;
        // [uint64 expiry, uint64 flags, uint64 nonceBucket, uint64 nonce]
        uint256 expiryFlagsAndNonce;
        address platformFeeReceiver;
        // The platform fee paid by the maker in the maker token. The maker pays this amount in
        // addition to the makerAmount.
        uint256 platformFee;
    }
    /// @dev
    /// keccak256(
    ///     "OrderWithEthWithFee("
    ///         "address txOrigin,"
    ///         "address taker,"
    ///         "uint256 takerAmount,"
    ///         "address makerToken,"
    ///         "uint256 makerAmount,"
    ///         "uint256 expiryFlagsAndNonce,"
    ///         "address platformFeeReceiver,"
    ///         "uint256 platformFee"
    ///     ")"
    /// );
    bytes32 private constant ORDER_WITH_ETH_WITH_FEE_TYPEHASH = 0x34dcfd336777cd7aa567d3c5b9349567882bfe468f8ba4d6b512c8d1c7e06608;
    uint256 private constant ORDER_WITH_ETH_WITH_FEE_STRUCT_SIZE = 32 * 5;
    // TYPEHASH_AND_TXORIGIN_AND_TAKER_AND_MSGVALUE_SIZE + STRUCT_SIZE
    uint256 private constant TYPEHASH_AND_ORDER_WITH_ETH_WITH_FEE_SIZE = 32 + 32 + 32 + 32 + (32 * 5);
    function hashOrderWithEthWithFee(
        OrderWithEthWithFee calldata order,
        address txOrigin,
        address taker,
        uint256 takerAmount
    ) external view returns (bytes32) {
        bytes32 orderHash;
        assembly ("memory-safe") {
            let ptr := mload(0x40)
            mstore(ptr, ORDER_WITH_ETH_WITH_FEE_TYPEHASH)
            mstore(add(ptr, TYPEHASH_SIZE), and(txOrigin, ADDRESS_MASK))
            mstore(add(ptr, TYPEHASH_AND_TXORIGIN_SIZE), and(taker, ADDRESS_MASK))
            mstore(add(ptr, TYPEHASH_AND_TXORIGIN_AND_TAKER_SIZE), takerAmount)
            calldatacopy(add(ptr, TYPEHASH_AND_TXORIGIN_AND_TAKER_AND_MSGVALUE_SIZE), order, ORDER_WITH_ETH_WITH_FEE_STRUCT_SIZE)
            orderHash := keccak256(ptr, TYPEHASH_AND_ORDER_WITH_ETH_WITH_FEE_SIZE)
        }
        return ECDSA.toTypedDataHash(DOMAIN_SEPARATOR, orderHash);
    }

    /// @dev An ERC-20 to ETH order.
    /// When signing, `address txOrigin` must be included as the first field, and `address taker`
    /// must be included as the second field. If the IsFloatingTxOrigin flag is set, the
    /// `address txOrigin` must be the zero address.
    struct OrderForEth {
        IERC20 takerToken;
        // [uint128 makerAmount, uint128 takerAmount]
        uint256 makerAmountAndTakerAmount;
        // [uint64 expiry, uint64 flags, uint64 nonceBucket, uint64 nonce]
        uint256 expiryFlagsAndNonce;
    }
    /// @dev
    /// keccak256(
    ///     "OrderForEth("
    ///         "address txOrigin,"
    ///         "address taker,"
    ///         "address takerToken,"
    ///         "uint256 makerAmountAndTakerAmount,"
    ///         "uint256 expiryFlagsAndNonce"
    ///     ")"
    /// );
    bytes32 private constant ORDER_FOR_ETH_TYPEHASH = 0x7841277e49eb2022248012272a309d3ee3826a33117fe3d7b34cc5458280e943;
    uint256 private constant ORDER_FOR_ETH_STRUCT_SIZE = 32 * 3;
    // TYPEHASH_AND_TXORIGIN_AND_TAKER_SIZE + STRUCT_SIZE
    uint256 private constant TYPEHASH_AND_ORDER_FOR_ETH_SIZE = 32 + 32 + 32 + (32 * 3);
    function hashOrderForEth(
        OrderForEth calldata order,
        address txOrigin,
        address taker
    ) external view returns (bytes32) {
        bytes32 orderHash;
        assembly ("memory-safe") {
            let ptr := mload(0x40)
            mstore(ptr, ORDER_FOR_ETH_TYPEHASH)
            mstore(add(ptr, TYPEHASH_SIZE), and(txOrigin, ADDRESS_MASK))
            mstore(add(ptr, TYPEHASH_AND_TXORIGIN_SIZE), and(taker, ADDRESS_MASK))
            calldatacopy(add(ptr, TYPEHASH_AND_TXORIGIN_AND_TAKER_SIZE), order, ORDER_FOR_ETH_STRUCT_SIZE)
            orderHash := keccak256(ptr, TYPEHASH_AND_ORDER_FOR_ETH_SIZE)
        }
        return ECDSA.toTypedDataHash(DOMAIN_SEPARATOR, orderHash);
    }

    /// @dev An ERC-20 to ETH order with a platform fee.
    /// When signing, `address txOrigin` must be included as the first field, and `address taker`
    /// must be included as the second field. If the IsFloatingTxOrigin flag is set, the
    /// `address txOrigin` must be the zero address.
    struct OrderForEthWithFee {
        IERC20 takerToken;
        // [uint128 makerAmount, uint128 takerAmount]
        uint256 makerAmountAndTakerAmount;
        // [uint64 expiry, uint64 flags, uint64 nonceBucket, uint64 nonce]
        uint256 expiryFlagsAndNonce;
        address platformFeeReceiver;
        // The platform fee paid by the maker in the maker token. The maker pays this amount in
        // addition to the makerAmount.
        uint256 platformFee;
    }
    /// @dev
    /// keccak256(
    ///     "OrderForEthWithFee("
    ///         "address txOrigin,"
    ///         "address taker,"
    ///         "address takerToken,"
    ///         "uint256 makerAmountAndTakerAmount,"
    ///         "uint256 expiryFlagsAndNonce,"
    ///         "address platformFeeReceiver,"
    ///         "uint256 platformFee"
    ///     ")"
    /// );
    bytes32 private constant ORDER_FOR_ETH_WITH_FEE_TYPEHASH = 0x1eca04b13eca4d8852df28ef025aac0165cd22feabb436c8c406646e82cb362e;
    uint256 private constant ORDER_FOR_ETH_WITH_FEE_STRUCT_SIZE = 32 * 5;
    // TYPEHASH_AND_TXORIGIN_AND_TAKER_SIZE + STRUCT_SIZE
    uint256 private constant TYPEHASH_AND_ORDER_FOR_ETH_WITH_FEE_SIZE = 32 + 32 + 32 + (32 * 5);
    function hashOrderForEthWithFee(
        OrderForEthWithFee calldata order,
        address txOrigin,
        address taker
    ) external view returns (bytes32) {
        bytes32 orderHash;
        assembly ("memory-safe") {
            let ptr := mload(0x40)
            mstore(ptr, ORDER_FOR_ETH_WITH_FEE_TYPEHASH)
            mstore(add(ptr, TYPEHASH_SIZE), and(txOrigin, ADDRESS_MASK))
            mstore(add(ptr, TYPEHASH_AND_TXORIGIN_SIZE), and(taker, ADDRESS_MASK))
            calldatacopy(add(ptr, TYPEHASH_AND_TXORIGIN_AND_TAKER_SIZE), order, ORDER_FOR_ETH_WITH_FEE_STRUCT_SIZE)
            orderHash := keccak256(ptr, TYPEHASH_AND_ORDER_FOR_ETH_WITH_FEE_SIZE)
        }
        return ECDSA.toTypedDataHash(DOMAIN_SEPARATOR, orderHash);
    }

    error OrderExpired();
    error InvalidNonce();
    error InvalidPermitLength();
    error FillOrderCallFailed();

    /// @dev Fills an order signed by the maker. ERC-20 <-> ERC-20.
    /// @param order The order
    /// @param r The r value of the EIP-2098 representation of the maker's EIP-712 signature of the order
    /// @param vs The vs value of the EIP-2098 representation of the maker's EIP-712 signature of the order
    function fillOrder_18cabc5d(Order calldata order, bytes32 r, bytes32 vs) external {
        uint256 expiryFlagsAndNonce = order.expiryFlagsAndNonce;
        if (uint64(expiryFlagsAndNonce >> 192) <= block.timestamp) { revert OrderExpired(); }

        uint256 orderFlagIsFloatingTxOrigin = expiryFlagsAndNonce & ORDER_FLAG_IS_FLOATING_TX_ORIGIN;

        // Compute order hash
        bytes32 orderHash;
        assembly ("memory-safe") {
            let ptr := mload(0x40)
            mstore(ptr, ORDER_TYPEHASH)
            let txOrigin := origin()
            if gt(orderFlagIsFloatingTxOrigin, 0) {
                // If the order allows any tx.origin, it must specify a txOrigin of 0
                txOrigin := 0
            }
            mstore(add(ptr, TYPEHASH_SIZE), txOrigin)
            mstore(add(ptr, TYPEHASH_AND_TXORIGIN_SIZE), caller())
            calldatacopy(add(ptr, TYPEHASH_AND_TXORIGIN_AND_TAKER_SIZE), order, ORDER_STRUCT_SIZE)
            orderHash := keccak256(ptr, TYPEHASH_AND_ORDER_SIZE)
        }
        orderHash = ECDSA.toTypedDataHash(DOMAIN_SEPARATOR, orderHash);

        // Check the maker's signature of the order. We allow malleable signatures because we aren't
        // using the signature itself for replay protection.
        address maker;
        /*
            Assembly code for more efficiently computing:
            ```
            bytes32 s = vs & bytes32(EIP2098_S_MASK);
            // This can't overflow because vs >> 255 is either 0 or 1
            uint8 v; unchecked { v = uint8((uint256(vs) >> 255) + 27); }
            address maker = ecrecover(orderHash, v, r, s);
            ```
            Assembly code is based on
            https://github.com/1inch/solidity-utils/blob/a0202c68f4551d78e7f0b3843412991ac7d15f15
            /contracts/libraries/ECDSA.sol#L42-L61.
        */
        assembly ("memory-safe") {
            let s := and(vs, EIP2098_S_MASK)
            let ptr := mload(0x40)
            mstore(ptr, orderHash)
            mstore(add(ptr, 0x20), add(27, shr(255, vs)))
            mstore(add(ptr, 0x40), r)
            mstore(add(ptr, 0x60), s)
            mstore(0, 0)
            pop(staticcall(gas(), ECRECOVER_ADDR, ptr, 0x80, 0, 0x20))
            maker := mload(0)
        }

        uint256 makerAmountAndTakerAmount = order.makerAmountAndTakerAmount;
        _transferERC20TokensFrom(order.makerToken, maker, msg.sender, makerAmountAndTakerAmount >> 128);
        _transferERC20TokensFrom(order.takerToken, msg.sender, maker, uint128(makerAmountAndTakerAmount));

        if (orderFlagIsFloatingTxOrigin > 0) {
            // Order allows any tx.origin. Check and increment order nonce for msg.sender.
            unchecked {
                // orderNonces++ can't overflow because the nonce stored in orderNonces is a uint64 in uint256 space
                if (uint64(expiryFlagsAndNonce) != orderNonces[
                    bytes32(uint256(uint64(expiryFlagsAndNonce >> 64)) << 160) | bytes32(uint256(uint160(msg.sender)))
                ]++) { revert InvalidNonce(); }
            }

            emit OrderFilled(orderHash);
            return;
        }

        // Order restricts tx.origin. Check and increment order nonce for tx.origin.
        unchecked {
            // orderNonces++ can't overflow because the nonce stored in orderNonces is a uint64 in uint256 space
            if (uint64(expiryFlagsAndNonce) != orderNonces[
                bytes32(uint256(uint64(expiryFlagsAndNonce >> 64)) << 160) | bytes32(uint256(uint160(tx.origin)))
            ]++) { revert InvalidNonce(); }
        }

        emit OrderFilled(orderHash);
    }

    /// @dev ERC-2612 variant of `fillOrder`
    /// @param order The order
    /// @param r The r value of the EIP-2098 representation of the maker's EIP-712 signature of the order
    /// @param vs The vs value of the EIP-2098 representation of the maker's EIP-712 signature of the order
    /// @param permit The permit data. Content depends on the takerToken.
    ///
    /// If the takerToken implements the ERC-2612 permit interface, the permit bytes are of the form
    /// [bytes32 r, bytes32 vs] where r and vs are the compact EIP-2098 representation
    /// of the taker's signature of a permit of the form
    /// `spender=this contract, value=order.takerAmount, deadline=order.expiry`.
    ///
    /// If the takerToken implements the DAI permit interface, the permit bytes are of the form
    /// [uint32 nonce, bytes32 r, bytes32 vs] where r and vs are the compact EIP-2098 representation
    /// of the taker's signature of a permit of the form
    /// `spender=this contract, nonce=nonce, expiry=order.expiry, allowed=true`.
    ///
    /// If the takerToken implements the ERC-2612-like permit interface of the form,
    ///    permit(address owner, address spender, uint256 value, uint256 deadline, bytes memory signature),
    /// the permit bytes are either of the form [bytes signature] if the signature is less than 64
    /// bytes in length or of the form [bytes5 padding, bytes signature] if the signature is at least
    /// 64 bytes in length.
    function fillOrder2612_28aac12(
        Order calldata order,
        bytes32 r,
        bytes32 vs,
        bytes calldata permit
    ) external {
        uint256 expiryFlagsAndNonce = order.expiryFlagsAndNonce;
        if (uint64(expiryFlagsAndNonce >> 192) <= block.timestamp) { revert OrderExpired(); }

        uint256 orderFlagIsFloatingTxOrigin = expiryFlagsAndNonce & ORDER_FLAG_IS_FLOATING_TX_ORIGIN;

        // Compute order hash
        bytes32 orderHash;
        assembly ("memory-safe") {
            let ptr := mload(0x40)
            mstore(ptr, ORDER_TYPEHASH)
            let txOrigin := origin()
            if gt(orderFlagIsFloatingTxOrigin, 0) {
                // If the order allows any tx.origin, it must specify a txOrigin of 0
                txOrigin := 0
            }
            mstore(add(ptr, TYPEHASH_SIZE), txOrigin)
            mstore(add(ptr, TYPEHASH_AND_TXORIGIN_SIZE), caller())
            calldatacopy(add(ptr, TYPEHASH_AND_TXORIGIN_AND_TAKER_SIZE), order, ORDER_STRUCT_SIZE)
            orderHash := keccak256(ptr, TYPEHASH_AND_ORDER_SIZE)
        }
        orderHash = ECDSA.toTypedDataHash(DOMAIN_SEPARATOR, orderHash);

        // Check the maker's signature of the order. We allow malleable signatures because we aren't
        // using the signature itself for replay protection.
        address maker;
        /*
            Assembly code for more efficiently computing:
            ```
            bytes32 s = vs & bytes32(EIP2098_S_MASK);
            // This can't overflow because vs >> 255 is either 0 or 1
            uint8 v; unchecked { v = uint8((uint256(vs) >> 255) + 27); }
            address maker = ecrecover(orderHash, v, r, s);
            ```
            Assembly code is based on
            https://github.com/1inch/solidity-utils/blob/a0202c68f4551d78e7f0b3843412991ac7d15f15
            /contracts/libraries/ECDSA.sol#L42-L61.
        */
        assembly ("memory-safe") {
            let s := and(vs, EIP2098_S_MASK)
            let ptr := mload(0x40)
            mstore(ptr, orderHash)
            mstore(add(ptr, 0x20), add(27, shr(255, vs)))
            mstore(add(ptr, 0x40), r)
            mstore(add(ptr, 0x60), s)
            mstore(0, 0)
            pop(staticcall(gas(), ECRECOVER_ADDR, ptr, 0x80, 0, 0x20))
            maker := mload(0)
        }

        uint256 makerAmountAndTakerAmount = order.makerAmountAndTakerAmount;
        _transferERC20TokensFrom(order.makerToken, maker, msg.sender, makerAmountAndTakerAmount >> 128);
        uint256 takerAmount = uint128(makerAmountAndTakerAmount);
        IERC20 takerToken = order.takerToken;
        _consumePermitFromTaker(takerToken, takerAmount, uint64(expiryFlagsAndNonce >> 192), permit);
        _transferERC20TokensFrom(takerToken, msg.sender, maker, takerAmount);

        if (orderFlagIsFloatingTxOrigin > 0) {
            // Order allows any tx.origin. Check and increment order nonce for msg.sender.
            unchecked {
                // orderNonces++ can't overflow because the nonce stored in orderNonces is a uint64 in uint256 space
                if (uint64(expiryFlagsAndNonce) != orderNonces[
                    bytes32(uint256(uint64(expiryFlagsAndNonce >> 64)) << 160) | bytes32(uint256(uint160(msg.sender)))
                ]++) { revert InvalidNonce(); }
            }

            emit OrderFilled(orderHash);
            return;
        }

        // Order restricts tx.origin. Check and increment order nonce for tx.origin.
        unchecked {
            // orderNonces++ can't overflow because the nonce stored in orderNonces is a uint64 in uint256 space
            if (uint64(expiryFlagsAndNonce) != orderNonces[
                bytes32(uint256(uint64(expiryFlagsAndNonce >> 64)) << 160) | bytes32(uint256(uint160(tx.origin)))
            ]++) { revert InvalidNonce(); }
        }

        emit OrderFilled(orderHash);
    }

    /// @dev Permit2 variant of `fillOrder`
    /// @param order The order
    /// @param r The r value of the EIP-2098 representation of the maker's EIP-712 signature of the order
    /// @param vs The vs value of the EIP-2098 representation of the maker's EIP-712 signature of the order
    /// @param permitNonce The Permit2 SignatureTransfer nonce
    /// @param permitSignature The taker's signature of the Permit2 SignatureTransfer message
    /// allowing this contract to transfer `order.takerAmount` of `order.takerToken` from the taker.
    /// The deadline of the Permit2 SignatureTransfer must be equal to the order expiry. The caller
    /// should use the compact EIP-2098 representation of the signature to save gas; however,
    /// non-compact signatures are also supported.
    function fillOrderPermit2_a021f41(
        Order calldata order,
        bytes32 r,
        bytes32 vs,
        uint256 permitNonce,
        bytes calldata permitSignature
    ) external {
        uint256 expiryFlagsAndNonce = order.expiryFlagsAndNonce;
        if (uint64(expiryFlagsAndNonce >> 192) <= block.timestamp) { revert OrderExpired(); }

        uint256 orderFlagIsFloatingTxOrigin = expiryFlagsAndNonce & ORDER_FLAG_IS_FLOATING_TX_ORIGIN;

        // Compute order hash
        bytes32 orderHash;
        assembly ("memory-safe") {
            let ptr := mload(0x40)
            mstore(ptr, ORDER_TYPEHASH)
            let txOrigin := origin()
            if gt(orderFlagIsFloatingTxOrigin, 0) {
                // If the order allows any tx.origin, it must specify a txOrigin of 0
                txOrigin := 0
            }
            mstore(add(ptr, TYPEHASH_SIZE), txOrigin)
            mstore(add(ptr, TYPEHASH_AND_TXORIGIN_SIZE), caller())
            calldatacopy(add(ptr, TYPEHASH_AND_TXORIGIN_AND_TAKER_SIZE), order, ORDER_STRUCT_SIZE)
            orderHash := keccak256(ptr, TYPEHASH_AND_ORDER_SIZE)
        }
        orderHash = ECDSA.toTypedDataHash(DOMAIN_SEPARATOR, orderHash);

        // Check the maker's signature of the order. We allow malleable signatures because we aren't
        // using the signature itself for replay protection.
        address maker;
        /*
            Assembly code for more efficiently computing:
            ```
            bytes32 s = vs & bytes32(EIP2098_S_MASK);
            // This can't overflow because vs >> 255 is either 0 or 1
            uint8 v; unchecked { v = uint8((uint256(vs) >> 255) + 27); }
            address maker = ecrecover(orderHash, v, r, s);
            ```
            Assembly code is based on
            https://github.com/1inch/solidity-utils/blob/a0202c68f4551d78e7f0b3843412991ac7d15f15
            /contracts/libraries/ECDSA.sol#L42-L61.
        */
        assembly ("memory-safe") {
            let s := and(vs, EIP2098_S_MASK)
            let ptr := mload(0x40)
            mstore(ptr, orderHash)
            mstore(add(ptr, 0x20), add(27, shr(255, vs)))
            mstore(add(ptr, 0x40), r)
            mstore(add(ptr, 0x60), s)
            mstore(0, 0)
            pop(staticcall(gas(), ECRECOVER_ADDR, ptr, 0x80, 0, 0x20))
            maker := mload(0)
        }

        {
            uint256 makerAmountAndTakerAmount = order.makerAmountAndTakerAmount;
            _transferERC20TokensFrom(order.makerToken, maker, msg.sender, makerAmountAndTakerAmount >> 128);
            uint256 takerAmount = uint128(makerAmountAndTakerAmount);
            IERC20 takerToken = order.takerToken;
            PERMIT2.permitTransferFrom(
                ISignatureTransfer.PermitTransferFrom({
                    permitted: ISignatureTransfer.TokenPermissions({
                        token: address(takerToken),
                        amount: takerAmount
                    }),
                    nonce: permitNonce,
                    deadline: uint64(expiryFlagsAndNonce >> 192)
                }),
                ISignatureTransfer.SignatureTransferDetails({
                    to: maker,
                    requestedAmount: takerAmount
                }),
                msg.sender,
                permitSignature
            );
        }

        if (orderFlagIsFloatingTxOrigin > 0) {
            // Order allows any tx.origin. Check and increment order nonce for msg.sender.
            unchecked {
                // orderNonces++ can't overflow because the nonce stored in orderNonces is a uint64 in uint256 space
                if (uint64(expiryFlagsAndNonce) != orderNonces[
                    bytes32(uint256(uint64(expiryFlagsAndNonce >> 64)) << 160) | bytes32(uint256(uint160(msg.sender)))
                ]++) { revert InvalidNonce(); }
            }

            emit OrderFilled(orderHash);
            return;
        }

        // Order restricts tx.origin. Check and increment order nonce for tx.origin.
        unchecked {
            // orderNonces++ can't overflow because the nonce stored in orderNonces is a uint64 in uint256 space
            if (uint64(expiryFlagsAndNonce) != orderNonces[
                bytes32(uint256(uint64(expiryFlagsAndNonce >> 64)) << 160) | bytes32(uint256(uint160(tx.origin)))
            ]++) { revert InvalidNonce(); }
        }

        emit OrderFilled(orderHash);
    }

    /// @dev Fee paying variant of `fillOrder`
    /// @param order The order
    /// @param r The r value of the EIP-2098 representation of the maker's EIP-712 signature of the order
    /// @param vs The vs value of the EIP-2098 representation of the maker's EIP-712 signature of the order
    function fillOrderWithFee_16fcd5ca(OrderWithFee calldata order, bytes32 r, bytes32 vs) external {
        uint256 expiryFlagsAndNonce = order.expiryFlagsAndNonce;
        if (uint64(expiryFlagsAndNonce >> 192) <= block.timestamp) { revert OrderExpired(); }

        uint256 orderFlagIsFloatingTxOrigin = expiryFlagsAndNonce & ORDER_FLAG_IS_FLOATING_TX_ORIGIN;

        // Compute order hash
        bytes32 orderHash;
        assembly ("memory-safe") {
            let ptr := mload(0x40)
            mstore(ptr, ORDER_WITH_FEE_TYPEHASH)
            let txOrigin := origin()
            if gt(orderFlagIsFloatingTxOrigin, 0) {
                // If the order allows any tx.origin, it must specify a txOrigin of 0
                txOrigin := 0
            }
            mstore(add(ptr, TYPEHASH_SIZE), txOrigin)
            mstore(add(ptr, TYPEHASH_AND_TXORIGIN_SIZE), caller())
            calldatacopy(add(ptr, TYPEHASH_AND_TXORIGIN_AND_TAKER_SIZE), order, ORDER_WITH_FEE_STRUCT_SIZE)
            orderHash := keccak256(ptr, TYPEHASH_AND_ORDER_WITH_FEE_SIZE)
        }
        orderHash = ECDSA.toTypedDataHash(DOMAIN_SEPARATOR, orderHash);

        // Check the maker's signature of the order. We allow malleable signatures because we aren't
        // using the signature itself for replay protection.
        address maker;
        /*
            Assembly code for more efficiently computing:
            ```
            bytes32 s = vs & bytes32(EIP2098_S_MASK);
            // This can't overflow because vs >> 255 is either 0 or 1
            uint8 v; unchecked { v = uint8((uint256(vs) >> 255) + 27); }
            address maker = ecrecover(orderHash, v, r, s);
            ```
            Assembly code is based on
            https://github.com/1inch/solidity-utils/blob/a0202c68f4551d78e7f0b3843412991ac7d15f15
            /contracts/libraries/ECDSA.sol#L42-L61.
        */
        assembly ("memory-safe") {
            let s := and(vs, EIP2098_S_MASK)
            let ptr := mload(0x40)
            mstore(ptr, orderHash)
            mstore(add(ptr, 0x20), add(27, shr(255, vs)))
            mstore(add(ptr, 0x40), r)
            mstore(add(ptr, 0x60), s)
            mstore(0, 0)
            pop(staticcall(gas(), ECRECOVER_ADDR, ptr, 0x80, 0, 0x20))
            maker := mload(0)
        }

        {
            IERC20 makerToken = order.makerToken;
            _transferERC20TokensFrom(makerToken, maker, order.platformFeeReceiver, order.platformFee);
            uint256 makerAmountAndTakerAmount = order.makerAmountAndTakerAmount;
            _transferERC20TokensFrom(makerToken, maker, msg.sender, makerAmountAndTakerAmount >> 128);
            _transferERC20TokensFrom(order.takerToken, msg.sender, maker, uint128(makerAmountAndTakerAmount));
        }

        if (orderFlagIsFloatingTxOrigin > 0) {
            // Order allows any tx.origin. Check and increment order nonce for msg.sender.
            unchecked {
                // orderNonces++ can't overflow because the nonce stored in orderNonces is a uint64 in uint256 space
                if (uint64(expiryFlagsAndNonce) != orderNonces[
                    bytes32(uint256(uint64(expiryFlagsAndNonce >> 64)) << 160) | bytes32(uint256(uint160(msg.sender)))
                ]++) { revert InvalidNonce(); }
            }

            emit OrderFilled(orderHash);
            return;
        }

        // Order restricts tx.origin. Check and increment order nonce for tx.origin.
        unchecked {
            // orderNonces++ can't overflow because the nonce stored in orderNonces is a uint64 in uint256 space
            if (uint64(expiryFlagsAndNonce) != orderNonces[
                bytes32(uint256(uint64(expiryFlagsAndNonce >> 64)) << 160) | bytes32(uint256(uint160(tx.origin)))
            ]++) { revert InvalidNonce(); }
        }

        emit OrderFilled(orderHash);
    }

    /// @dev ERC-2612 variant of `fillOrderWithFee`
    /// @param order The order
    /// @param r The r value of the EIP-2098 representation of the maker's EIP-712 signature of the order
    /// @param vs The vs value of the EIP-2098 representation of the maker's EIP-712 signature of the order
    /// @param permit The permit data. Content depends on the takerToken.
    ///
    /// If the takerToken implements the ERC-2612 permit interface, the permit bytes are of the form
    /// [bytes32 r, bytes32 vs] where r and vs are the compact EIP-2098 representation
    /// of the taker's signature of a permit of the form
    /// `spender=this contract, value=order.takerAmount, deadline=order.expiry`.
    ///
    /// If the takerToken implements the DAI permit interface, the permit bytes are of the form
    /// [uint32 nonce, bytes32 r, bytes32 vs] where r and vs are the compact EIP-2098 representation
    /// of the taker's signature of a permit of the form
    /// `spender=this contract, nonce=nonce, expiry=order.expiry, allowed=true`.
    ///
    /// If the takerToken implements the ERC-2612-like permit interface of the form,
    ///    permit(address owner, address spender, uint256 value, uint256 deadline, bytes memory signature),
    /// the permit bytes are either of the form [bytes signature] if the signature is less than 64
    /// bytes in length or of the form [bytes5 padding, bytes signature] if the signature is at least
    /// 64 bytes in length.
    function fillOrderWithFee2612_12881c26(
        OrderWithFee calldata order,
        bytes32 r,
        bytes32 vs,
        bytes calldata permit
    ) external {
        uint256 expiryFlagsAndNonce = order.expiryFlagsAndNonce;
        if (uint64(expiryFlagsAndNonce >> 192) <= block.timestamp) { revert OrderExpired(); }

        uint256 orderFlagIsFloatingTxOrigin = expiryFlagsAndNonce & ORDER_FLAG_IS_FLOATING_TX_ORIGIN;

        // Compute order hash
        bytes32 orderHash;
        assembly ("memory-safe") {
            let ptr := mload(0x40)
            mstore(ptr, ORDER_WITH_FEE_TYPEHASH)
            let txOrigin := origin()
            if gt(orderFlagIsFloatingTxOrigin, 0) {
                // If the order allows any tx.origin, it must specify a txOrigin of 0
                txOrigin := 0
            }
            mstore(add(ptr, TYPEHASH_SIZE), txOrigin)
            mstore(add(ptr, TYPEHASH_AND_TXORIGIN_SIZE), caller())
            calldatacopy(add(ptr, TYPEHASH_AND_TXORIGIN_AND_TAKER_SIZE), order, ORDER_WITH_FEE_STRUCT_SIZE)
            orderHash := keccak256(ptr, TYPEHASH_AND_ORDER_WITH_FEE_SIZE)
        }
        orderHash = ECDSA.toTypedDataHash(DOMAIN_SEPARATOR, orderHash);

        // Check the maker's signature of the order. We allow malleable signatures because we aren't
        // using the signature itself for replay protection.
        address maker;
        /*
            Assembly code for more efficiently computing:
            ```
            bytes32 s = vs & bytes32(EIP2098_S_MASK);
            // This can't overflow because vs >> 255 is either 0 or 1
            uint8 v; unchecked { v = uint8((uint256(vs) >> 255) + 27); }
            address maker = ecrecover(orderHash, v, r, s);
            ```
            Assembly code is based on
            https://github.com/1inch/solidity-utils/blob/a0202c68f4551d78e7f0b3843412991ac7d15f15
            /contracts/libraries/ECDSA.sol#L42-L61.
        */
        assembly ("memory-safe") {
            let s := and(vs, EIP2098_S_MASK)
            let ptr := mload(0x40)
            mstore(ptr, orderHash)
            mstore(add(ptr, 0x20), add(27, shr(255, vs)))
            mstore(add(ptr, 0x40), r)
            mstore(add(ptr, 0x60), s)
            mstore(0, 0)
            pop(staticcall(gas(), ECRECOVER_ADDR, ptr, 0x80, 0, 0x20))
            maker := mload(0)
        }

        {
            IERC20 makerToken = order.makerToken;
            _transferERC20TokensFrom(makerToken, maker, order.platformFeeReceiver, order.platformFee);
            uint256 makerAmountAndTakerAmount = order.makerAmountAndTakerAmount;
            _transferERC20TokensFrom(makerToken, maker, msg.sender, makerAmountAndTakerAmount >> 128);
            uint256 takerAmount = uint128(makerAmountAndTakerAmount);
            IERC20 takerToken = order.takerToken;
            _consumePermitFromTaker(takerToken, takerAmount, uint64(expiryFlagsAndNonce >> 192), permit);
            _transferERC20TokensFrom(takerToken, msg.sender, maker, takerAmount);
        }

        if (orderFlagIsFloatingTxOrigin > 0) {
            // Order allows any tx.origin. Check and increment order nonce for msg.sender.
            unchecked {
                // orderNonces++ can't overflow because the nonce stored in orderNonces is a uint64 in uint256 space
                if (uint64(expiryFlagsAndNonce) != orderNonces[
                    bytes32(uint256(uint64(expiryFlagsAndNonce >> 64)) << 160) | bytes32(uint256(uint160(msg.sender)))
                ]++) { revert InvalidNonce(); }
            }

            emit OrderFilled(orderHash);
            return;
        }

        // Order restricts tx.origin. Check and increment order nonce for tx.origin.
        unchecked {
            // orderNonces++ can't overflow because the nonce stored in orderNonces is a uint64 in uint256 space
            if (uint64(expiryFlagsAndNonce) != orderNonces[
                bytes32(uint256(uint64(expiryFlagsAndNonce >> 64)) << 160) | bytes32(uint256(uint160(tx.origin)))
            ]++) { revert InvalidNonce(); }
        }

        emit OrderFilled(orderHash);
    }

    /// @dev Permit2 variant of `fillOrderWithFee`
    /// @param order The order
    /// @param r The r value of the EIP-2098 representation of the maker's EIP-712 signature of the order
    /// @param vs The vs value of the EIP-2098 representation of the maker's EIP-712 signature of the order
    /// @param permitNonce The Permit2 SignatureTransfer nonce
    /// @param permitSignature The taker's signature of the Permit2 SignatureTransfer message
    /// allowing this contract to transfer `order.takerAmount` of `order.takerToken` from the taker.
    /// The deadline of the Permit2 SignatureTransfer must be equal to the order expiry. The caller
    /// should use the compact EIP-2098 representation of the signature to save gas; however,
    /// non-compact signatures are also supported.
    function fillOrderWithFeePermit2_a32aaff(
        OrderWithFee calldata order,
        bytes32 r,
        bytes32 vs,
        uint256 permitNonce,
        bytes calldata permitSignature
    ) external {
        uint256 expiryFlagsAndNonce = order.expiryFlagsAndNonce;
        if (uint64(expiryFlagsAndNonce >> 192) <= block.timestamp) { revert OrderExpired(); }

        uint256 orderFlagIsFloatingTxOrigin = expiryFlagsAndNonce & ORDER_FLAG_IS_FLOATING_TX_ORIGIN;

        // Compute order hash
        bytes32 orderHash;
        assembly ("memory-safe") {
            let ptr := mload(0x40)
            mstore(ptr, ORDER_WITH_FEE_TYPEHASH)
            let txOrigin := origin()
            if gt(orderFlagIsFloatingTxOrigin, 0) {
                // If the order allows any tx.origin, it must specify a txOrigin of 0
                txOrigin := 0
            }
            mstore(add(ptr, TYPEHASH_SIZE), txOrigin)
            mstore(add(ptr, TYPEHASH_AND_TXORIGIN_SIZE), caller())
            calldatacopy(add(ptr, TYPEHASH_AND_TXORIGIN_AND_TAKER_SIZE), order, ORDER_WITH_FEE_STRUCT_SIZE)
            orderHash := keccak256(ptr, TYPEHASH_AND_ORDER_WITH_FEE_SIZE)
        }
        orderHash = ECDSA.toTypedDataHash(DOMAIN_SEPARATOR, orderHash);

        // Check the maker's signature of the order. We allow malleable signatures because we aren't
        // using the signature itself for replay protection.
        address maker;
        /*
            Assembly code for more efficiently computing:
            ```
            bytes32 s = vs & bytes32(EIP2098_S_MASK);
            // This can't overflow because vs >> 255 is either 0 or 1
            uint8 v; unchecked { v = uint8((uint256(vs) >> 255) + 27); }
            address maker = ecrecover(orderHash, v, r, s);
            ```
            Assembly code is based on
            https://github.com/1inch/solidity-utils/blob/a0202c68f4551d78e7f0b3843412991ac7d15f15
            /contracts/libraries/ECDSA.sol#L42-L61.
        */
        assembly ("memory-safe") {
            let s := and(vs, EIP2098_S_MASK)
            let ptr := mload(0x40)
            mstore(ptr, orderHash)
            mstore(add(ptr, 0x20), add(27, shr(255, vs)))
            mstore(add(ptr, 0x40), r)
            mstore(add(ptr, 0x60), s)
            mstore(0, 0)
            pop(staticcall(gas(), ECRECOVER_ADDR, ptr, 0x80, 0, 0x20))
            maker := mload(0)
        }

        IERC20 makerToken = order.makerToken;
        _transferERC20TokensFrom(makerToken, maker, order.platformFeeReceiver, order.platformFee);
        uint256 makerAmountAndTakerAmount = order.makerAmountAndTakerAmount;
        _transferERC20TokensFrom(makerToken, maker, msg.sender, makerAmountAndTakerAmount >> 128);
        IERC20 takerToken = order.takerToken;
        uint256 takerAmount = uint128(makerAmountAndTakerAmount);
        PERMIT2.permitTransferFrom(
            ISignatureTransfer.PermitTransferFrom({
                permitted: ISignatureTransfer.TokenPermissions({
                    token: address(takerToken),
                    amount: takerAmount
                }),
                nonce: permitNonce,
                deadline: uint64(expiryFlagsAndNonce >> 192)
            }),
            ISignatureTransfer.SignatureTransferDetails({
                to: maker,
                requestedAmount: takerAmount
            }),
            msg.sender,
            permitSignature
        );

        if (orderFlagIsFloatingTxOrigin > 0) {
            // Order allows any tx.origin. Check and increment order nonce for msg.sender.
            unchecked {
                // orderNonces++ can't overflow because the nonce stored in orderNonces is a uint64 in uint256 space
                if (uint64(expiryFlagsAndNonce) != orderNonces[
                    bytes32(uint256(uint64(expiryFlagsAndNonce >> 64)) << 160) | bytes32(uint256(uint160(msg.sender)))
                ]++) { revert InvalidNonce(); }
            }

            emit OrderFilled(orderHash);
            return;
        }

        // Order restricts tx.origin. Check and increment order nonce for tx.origin.
        unchecked {
            // orderNonces++ can't overflow because the nonce stored in orderNonces is a uint64 in uint256 space
            if (uint64(expiryFlagsAndNonce) != orderNonces[
                bytes32(uint256(uint64(expiryFlagsAndNonce >> 64)) << 160) | bytes32(uint256(uint160(tx.origin)))
            ]++) { revert InvalidNonce(); }
        }

        emit OrderFilled(orderHash);
    }

    /// @dev Fills an order signed by the maker. Wraps ETH sent by the taker before sending it to
    /// the maker.
    /// @param order The order
    /// @param r The r value of the EIP-2098 representation of the maker's EIP-712 signature of the order
    /// @param vs The vs value of the EIP-2098 representation of the maker's EIP-712 signature of the order
    function fillOrderWithEth_5cbdfc3(OrderWithEth calldata order, bytes32 r, bytes32 vs) external payable {
        uint256 expiryFlagsAndNonce = order.expiryFlagsAndNonce;
        if (uint64(expiryFlagsAndNonce >> 192) <= block.timestamp) { revert OrderExpired(); }

        uint256 orderFlagIsFloatingTxOrigin = expiryFlagsAndNonce & ORDER_FLAG_IS_FLOATING_TX_ORIGIN;

        // Compute order hash
        bytes32 orderHash;
        assembly ("memory-safe") {
            let ptr := mload(0x40)
            mstore(ptr, ORDER_WITH_ETH_TYPEHASH)
            let txOrigin := origin()
            if gt(orderFlagIsFloatingTxOrigin, 0) {
                // If the order allows any tx.origin, it must specify a txOrigin of 0
                txOrigin := 0
            }
            mstore(add(ptr, TYPEHASH_SIZE), txOrigin)
            mstore(add(ptr, TYPEHASH_AND_TXORIGIN_SIZE), caller())
            mstore(add(ptr, TYPEHASH_AND_TXORIGIN_AND_TAKER_SIZE), callvalue())
            calldatacopy(add(ptr, TYPEHASH_AND_TXORIGIN_AND_TAKER_AND_MSGVALUE_SIZE), order, ORDER_WITH_ETH_STRUCT_SIZE)
            orderHash := keccak256(ptr, TYPEHASH_AND_ORDER_WITH_ETH_SIZE)
        }
        orderHash = ECDSA.toTypedDataHash(DOMAIN_SEPARATOR, orderHash);

        // Check the maker's signature of the order. We allow malleable signatures because we aren't
        // using the signature itself for replay protection.
        address maker;
        /*
            Assembly code for more efficiently computing:
            ```
            bytes32 s = vs & bytes32(EIP2098_S_MASK);
            // This can't overflow because vs >> 255 is either 0 or 1
            uint8 v; unchecked { v = uint8((uint256(vs) >> 255) + 27); }
            address maker = ecrecover(orderHash, v, r, s);
            ```
            Assembly code is based on
            https://github.com/1inch/solidity-utils/blob/a0202c68f4551d78e7f0b3843412991ac7d15f15
            /contracts/libraries/ECDSA.sol#L42-L61.
        */
        assembly ("memory-safe") {
            let s := and(vs, EIP2098_S_MASK)
            let ptr := mload(0x40)
            mstore(ptr, orderHash)
            mstore(add(ptr, 0x20), add(27, shr(255, vs)))
            mstore(add(ptr, 0x40), r)
            mstore(add(ptr, 0x60), s)
            mstore(0, 0)
            pop(staticcall(gas(), ECRECOVER_ADDR, ptr, 0x80, 0, 0x20))
            maker := mload(0)
        }

        _transferERC20TokensFrom(order.makerToken, maker, msg.sender, order.makerAmount);
        _depositWETH(msg.value);
        _transferERC20Tokens(WETH, maker, msg.value);

        if (orderFlagIsFloatingTxOrigin > 0) {
            // Order allows any tx.origin. Check and increment order nonce for msg.sender.
            unchecked {
                // orderNonces++ can't overflow because the nonce stored in orderNonces is a uint64 in uint256 space
                if (uint64(expiryFlagsAndNonce) != orderNonces[
                    bytes32(uint256(uint64(expiryFlagsAndNonce >> 64)) << 160) | bytes32(uint256(uint160(msg.sender)))
                ]++) { revert InvalidNonce(); }
            }

            emit OrderFilled(orderHash);
            return;
        }

        // Order restricts tx.origin. Check and increment order nonce for tx.origin.
        unchecked {
            // orderNonces++ can't overflow because the nonce stored in orderNonces is a uint64 in uint256 space
            if (uint64(expiryFlagsAndNonce) != orderNonces[
                bytes32(uint256(uint64(expiryFlagsAndNonce >> 64)) << 160) | bytes32(uint256(uint160(tx.origin)))
            ]++) { revert InvalidNonce(); }
        }

        emit OrderFilled(orderHash);
    }

    /// @dev Fee paying variant of `fillOrderWithEth`
    /// @param order The order
    /// @param r The r value of the EIP-2098 representation of the maker's EIP-712 signature of the order
    /// @param vs The vs value of the EIP-2098 representation of the maker's EIP-712 signature of the order
    function fillOrderWithEthWithFee_2207618(OrderWithEthWithFee calldata order, bytes32 r, bytes32 vs) external payable {
        uint256 expiryFlagsAndNonce = order.expiryFlagsAndNonce;
        if (uint64(expiryFlagsAndNonce >> 192) <= block.timestamp) { revert OrderExpired(); }

        uint256 orderFlagIsFloatingTxOrigin = expiryFlagsAndNonce & ORDER_FLAG_IS_FLOATING_TX_ORIGIN;

        // Compute order hash
        bytes32 orderHash;
        assembly ("memory-safe") {
            let ptr := mload(0x40)
            mstore(ptr, ORDER_WITH_ETH_WITH_FEE_TYPEHASH)
            let txOrigin := origin()
            if gt(orderFlagIsFloatingTxOrigin, 0) {
                // If the order allows any tx.origin, it must specify a txOrigin of 0
                txOrigin := 0
            }
            mstore(add(ptr, TYPEHASH_SIZE), txOrigin)
            mstore(add(ptr, TYPEHASH_AND_TXORIGIN_SIZE), caller())
            mstore(add(ptr, TYPEHASH_AND_TXORIGIN_AND_TAKER_SIZE), callvalue())
            calldatacopy(add(ptr, TYPEHASH_AND_TXORIGIN_AND_TAKER_AND_MSGVALUE_SIZE), order, ORDER_WITH_ETH_WITH_FEE_STRUCT_SIZE)
            orderHash := keccak256(ptr, TYPEHASH_AND_ORDER_WITH_ETH_WITH_FEE_SIZE)
        }
        orderHash = ECDSA.toTypedDataHash(DOMAIN_SEPARATOR, orderHash);

        // Check the maker's signature of the order. We allow malleable signatures because we aren't
        // using the signature itself for replay protection.
        address maker;
        /*
            Assembly code for more efficiently computing:
            ```
            bytes32 s = vs & bytes32(EIP2098_S_MASK);
            // This can't overflow because vs >> 255 is either 0 or 1
            uint8 v; unchecked { v = uint8((uint256(vs) >> 255) + 27); }
            address maker = ecrecover(orderHash, v, r, s);
            ```
            Assembly code is based on
            https://github.com/1inch/solidity-utils/blob/a0202c68f4551d78e7f0b3843412991ac7d15f15
            /contracts/libraries/ECDSA.sol#L42-L61.
        */
        assembly ("memory-safe") {
            let s := and(vs, EIP2098_S_MASK)
            let ptr := mload(0x40)
            mstore(ptr, orderHash)
            mstore(add(ptr, 0x20), add(27, shr(255, vs)))
            mstore(add(ptr, 0x40), r)
            mstore(add(ptr, 0x60), s)
            mstore(0, 0)
            pop(staticcall(gas(), ECRECOVER_ADDR, ptr, 0x80, 0, 0x20))
            maker := mload(0)
        }

        IERC20 makerToken = order.makerToken;
        _transferERC20TokensFrom(makerToken, maker, order.platformFeeReceiver, order.platformFee);
        _transferERC20TokensFrom(makerToken, maker, msg.sender, order.makerAmount);
        _depositWETH(msg.value);
        _transferERC20Tokens(WETH, maker, msg.value);

        if (orderFlagIsFloatingTxOrigin > 0) {
            // Order allows any tx.origin. Check and increment order nonce for msg.sender.
            unchecked {
                // orderNonces++ can't overflow because the nonce stored in orderNonces is a uint64 in uint256 space
                if (uint64(expiryFlagsAndNonce) != orderNonces[
                    bytes32(uint256(uint64(expiryFlagsAndNonce >> 64)) << 160) | bytes32(uint256(uint160(msg.sender)))
                ]++) { revert InvalidNonce(); }
            }

            emit OrderFilled(orderHash);
            return;
        }

        // Order restricts tx.origin. Check and increment order nonce for tx.origin.
        unchecked {
            // orderNonces++ can't overflow because the nonce stored in orderNonces is a uint64 in uint256 space
            if (uint64(expiryFlagsAndNonce) != orderNonces[
                bytes32(uint256(uint64(expiryFlagsAndNonce >> 64)) << 160) | bytes32(uint256(uint160(tx.origin)))
            ]++) { revert InvalidNonce(); }
        }

        emit OrderFilled(orderHash);
    }

    receive() external payable {}

    function _sendEthToTaker(uint256 amount) internal {
        assembly ("memory-safe") {
            if iszero(call(gas(), caller(), amount, 0, 0, 0, 0)) {
                let ptr := mload(0x40)
                let rdsize := returndatasize()
                returndatacopy(ptr, 0, rdsize)
                revert(ptr, rdsize)
            }
        }
    }

    function _sendEthTo(address to, uint256 amount) internal {
        assembly ("memory-safe") {
            if iszero(call(gas(), and(to, ADDRESS_MASK), amount, 0, 0, 0, 0)) {
                let ptr := mload(0x40)
                let rdsize := returndatasize()
                returndatacopy(ptr, 0, rdsize)
                revert(ptr, rdsize)
            }
        }
    }

    /// @dev Fills an order signed by the maker. Unwraps WETH sent by the maker before sending it to
    /// the taker.
    /// @param order The order
    /// @param r The r value of the EIP-2098 representation of the maker's EIP-712 signature of the order
    /// @param vs The vs value of the EIP-2098 representation of the maker's EIP-712 signature of the order
    function fillOrderForEth_5ec836(OrderForEth calldata order, bytes32 r, bytes32 vs) external {
        uint256 expiryFlagsAndNonce = order.expiryFlagsAndNonce;
        if (uint64(expiryFlagsAndNonce >> 192) <= block.timestamp) { revert OrderExpired(); }

        uint256 orderFlagIsFloatingTxOrigin = expiryFlagsAndNonce & ORDER_FLAG_IS_FLOATING_TX_ORIGIN;

        // Compute order hash
        bytes32 orderHash;
        assembly ("memory-safe") {
            let ptr := mload(0x40)
            mstore(ptr, ORDER_FOR_ETH_TYPEHASH)
            let txOrigin := origin()
            if gt(orderFlagIsFloatingTxOrigin, 0) {
                // If the order allows any tx.origin, it must specify a txOrigin of 0
                txOrigin := 0
            }
            mstore(add(ptr, TYPEHASH_SIZE), txOrigin)
            mstore(add(ptr, TYPEHASH_AND_TXORIGIN_SIZE), caller())
            calldatacopy(add(ptr, TYPEHASH_AND_TXORIGIN_AND_TAKER_SIZE), order, ORDER_FOR_ETH_STRUCT_SIZE)
            orderHash := keccak256(ptr, TYPEHASH_AND_ORDER_FOR_ETH_SIZE)
        }
        orderHash = ECDSA.toTypedDataHash(DOMAIN_SEPARATOR, orderHash);

        // Check the maker's signature of the order. We allow malleable signatures because we aren't
        // using the signature itself for replay protection.
        address maker;
        /*
            Assembly code for more efficiently computing:
            ```
            bytes32 s = vs & bytes32(EIP2098_S_MASK);
            // This can't overflow because vs >> 255 is either 0 or 1
            uint8 v; unchecked { v = uint8((uint256(vs) >> 255) + 27); }
            address maker = ecrecover(orderHash, v, r, s);
            ```
            Assembly code is based on
            https://github.com/1inch/solidity-utils/blob/a0202c68f4551d78e7f0b3843412991ac7d15f15
            /contracts/libraries/ECDSA.sol#L42-L61.
        */
        assembly ("memory-safe") {
            let s := and(vs, EIP2098_S_MASK)
            let ptr := mload(0x40)
            mstore(ptr, orderHash)
            mstore(add(ptr, 0x20), add(27, shr(255, vs)))
            mstore(add(ptr, 0x40), r)
            mstore(add(ptr, 0x60), s)
            mstore(0, 0)
            pop(staticcall(gas(), ECRECOVER_ADDR, ptr, 0x80, 0, 0x20))
            maker := mload(0)
        }

        {
            uint256 makerAmountAndTakerAmount = order.makerAmountAndTakerAmount;
            uint256 makerAmount = makerAmountAndTakerAmount >> 128;
            _transferERC20TokensFrom(IERC20(address(WETH)), maker, address(this), makerAmount);
            _transferERC20TokensFrom(order.takerToken, msg.sender, maker, uint128(makerAmountAndTakerAmount));
            _withdrawWETH(makerAmount);
            _sendEthToTaker(makerAmount);
        }

        if (orderFlagIsFloatingTxOrigin > 0) {
            // Order allows any tx.origin. Check and increment order nonce for msg.sender.
            unchecked {
                // orderNonces++ can't overflow because the nonce stored in orderNonces is a uint64 in uint256 space
                if (uint64(expiryFlagsAndNonce) != orderNonces[
                    bytes32(uint256(uint64(expiryFlagsAndNonce >> 64)) << 160) | bytes32(uint256(uint160(msg.sender)))
                ]++) { revert InvalidNonce(); }
            }

            emit OrderFilled(orderHash);
            return;
        }

        // Order restricts tx.origin. Check and increment order nonce for tx.origin.
        unchecked {
            // orderNonces++ can't overflow because the nonce stored in orderNonces is a uint64 in uint256 space
            if (uint64(expiryFlagsAndNonce) != orderNonces[
                bytes32(uint256(uint64(expiryFlagsAndNonce >> 64)) << 160) | bytes32(uint256(uint160(tx.origin)))
            ]++) { revert InvalidNonce(); }
        }

        emit OrderFilled(orderHash);
    }

    /// @dev ERC-2612 variant of `fillOrderForEth`
    /// @param order The order
    /// @param r The r value of the EIP-2098 representation of the maker's EIP-712 signature of the order
    /// @param vs The vs value of the EIP-2098 representation of the maker's EIP-712 signature of the order
    /// @param permit The permit data. Content depends on the takerToken.
    ///
    /// If the takerToken implements the ERC-2612 permit interface, the permit bytes are of the form
    /// [bytes32 r, bytes32 vs] where r and vs are the compact EIP-2098 representation
    /// of the taker's signature of a permit of the form
    /// `spender=this contract, value=order.takerAmount, deadline=order.expiry`.
    ///
    /// If the takerToken implements the DAI permit interface, the permit bytes are of the form
    /// [uint32 nonce, bytes32 r, bytes32 vs] where r and vs are the compact EIP-2098 representation
    /// of the taker's signature of a permit of the form
    /// `spender=this contract, nonce=nonce, expiry=order.expiry, allowed=true`.
    ///
    /// If the takerToken implements the ERC-2612-like permit interface of the form,
    ///    permit(address owner, address spender, uint256 value, uint256 deadline, bytes memory signature),
    /// the permit bytes are either of the form [bytes signature] if the signature is less than 64
    /// bytes in length or of the form [bytes5 padding, bytes signature] if the signature is at least
    /// 64 bytes in length.
    function fillOrderForEth2612_df9e901(
        OrderForEth calldata order,
        bytes32 r,
        bytes32 vs,
        bytes calldata permit
    ) external {
        uint256 expiryFlagsAndNonce = order.expiryFlagsAndNonce;
        if (uint64(expiryFlagsAndNonce >> 192) <= block.timestamp) { revert OrderExpired(); }

        uint256 orderFlagIsFloatingTxOrigin = expiryFlagsAndNonce & ORDER_FLAG_IS_FLOATING_TX_ORIGIN;

        // Compute order hash
        bytes32 orderHash;
        assembly ("memory-safe") {
            let ptr := mload(0x40)
            mstore(ptr, ORDER_FOR_ETH_TYPEHASH)
            let txOrigin := origin()
            if gt(orderFlagIsFloatingTxOrigin, 0) {
                // If the order allows any tx.origin, it must specify a txOrigin of 0
                txOrigin := 0
            }
            mstore(add(ptr, TYPEHASH_SIZE), txOrigin)
            mstore(add(ptr, TYPEHASH_AND_TXORIGIN_SIZE), caller())
            calldatacopy(add(ptr, TYPEHASH_AND_TXORIGIN_AND_TAKER_SIZE), order, ORDER_FOR_ETH_STRUCT_SIZE)
            orderHash := keccak256(ptr, TYPEHASH_AND_ORDER_FOR_ETH_SIZE)
        }
        orderHash = ECDSA.toTypedDataHash(DOMAIN_SEPARATOR, orderHash);

        // Check the maker's signature of the order. We allow malleable signatures because we aren't
        // using the signature itself for replay protection.
        address maker;
        /*
            Assembly code for more efficiently computing:
            ```
            bytes32 s = vs & bytes32(EIP2098_S_MASK);
            // This can't overflow because vs >> 255 is either 0 or 1
            uint8 v; unchecked { v = uint8((uint256(vs) >> 255) + 27); }
            address maker = ecrecover(orderHash, v, r, s);
            ```
            Assembly code is based on
            https://github.com/1inch/solidity-utils/blob/a0202c68f4551d78e7f0b3843412991ac7d15f15
            /contracts/libraries/ECDSA.sol#L42-L61.
        */
        assembly ("memory-safe") {
            let s := and(vs, EIP2098_S_MASK)
            let ptr := mload(0x40)
            mstore(ptr, orderHash)
            mstore(add(ptr, 0x20), add(27, shr(255, vs)))
            mstore(add(ptr, 0x40), r)
            mstore(add(ptr, 0x60), s)
            mstore(0, 0)
            pop(staticcall(gas(), ECRECOVER_ADDR, ptr, 0x80, 0, 0x20))
            maker := mload(0)
        }

        uint256 makerAmountAndTakerAmount = order.makerAmountAndTakerAmount;
        uint256 makerAmount = makerAmountAndTakerAmount >> 128;
        _transferERC20TokensFrom(IERC20(address(WETH)), maker, address(this), makerAmount);
        _withdrawWETH(makerAmount);
        _sendEthToTaker(makerAmount);
        uint256 takerAmount = uint128(makerAmountAndTakerAmount);
        IERC20 takerToken = order.takerToken;
        _consumePermitFromTaker(takerToken, takerAmount, uint64(expiryFlagsAndNonce >> 192), permit);
        _transferERC20TokensFrom(takerToken, msg.sender, maker, takerAmount);

        if (orderFlagIsFloatingTxOrigin > 0) {
            // Order allows any tx.origin. Check and increment order nonce for msg.sender.
            unchecked {
                // orderNonces++ can't overflow because the nonce stored in orderNonces is a uint64 in uint256 space
                if (uint64(expiryFlagsAndNonce) != orderNonces[
                    bytes32(uint256(uint64(expiryFlagsAndNonce >> 64)) << 160) | bytes32(uint256(uint160(msg.sender)))
                ]++) { revert InvalidNonce(); }
            }

            emit OrderFilled(orderHash);
            return;
        }

        // Order restricts tx.origin. Check and increment order nonce for tx.origin.
        unchecked {
            // orderNonces++ can't overflow because the nonce stored in orderNonces is a uint64 in uint256 space
            if (uint64(expiryFlagsAndNonce) != orderNonces[
                bytes32(uint256(uint64(expiryFlagsAndNonce >> 64)) << 160) | bytes32(uint256(uint160(tx.origin)))
            ]++) { revert InvalidNonce(); }
        }

        emit OrderFilled(orderHash);
    }

    /// @dev Permit2 variant of `fillOrderForEth`
    /// @param order The order
    /// @param r The r value of the EIP-2098 representation of the maker's EIP-712 signature of the order
    /// @param vs The vs value of the EIP-2098 representation of the maker's EIP-712 signature of the order
    /// @param permitNonce The Permit2 SignatureTransfer nonce
    /// @param permitSignature The taker's signature of the Permit2 SignatureTransfer message
    /// allowing this contract to transfer `order.takerAmount` of `order.takerToken` from the taker.
    /// The deadline of the Permit2 SignatureTransfer must be equal to the order expiry. The caller
    /// should use the compact EIP-2098 representation of the signature to save gas; however,
    /// non-compact signatures are also supported.
    function fillOrderForEthPermit2_9290ce1(
        OrderForEth calldata order,
        bytes32 r,
        bytes32 vs,
        uint256 permitNonce,
        bytes calldata permitSignature
    ) external {
        uint256 expiryFlagsAndNonce = order.expiryFlagsAndNonce;
        if (uint64(expiryFlagsAndNonce >> 192) <= block.timestamp) { revert OrderExpired(); }

        uint256 orderFlagIsFloatingTxOrigin = expiryFlagsAndNonce & ORDER_FLAG_IS_FLOATING_TX_ORIGIN;

        // Compute order hash
        bytes32 orderHash;
        assembly ("memory-safe") {
            let ptr := mload(0x40)
            mstore(ptr, ORDER_FOR_ETH_TYPEHASH)
            let txOrigin := origin()
            if gt(orderFlagIsFloatingTxOrigin, 0) {
                // If the order allows any tx.origin, it must specify a txOrigin of 0
                txOrigin := 0
            }
            mstore(add(ptr, TYPEHASH_SIZE), txOrigin)
            mstore(add(ptr, TYPEHASH_AND_TXORIGIN_SIZE), caller())
            calldatacopy(add(ptr, TYPEHASH_AND_TXORIGIN_AND_TAKER_SIZE), order, ORDER_FOR_ETH_STRUCT_SIZE)
            orderHash := keccak256(ptr, TYPEHASH_AND_ORDER_FOR_ETH_SIZE)
        }
        orderHash = ECDSA.toTypedDataHash(DOMAIN_SEPARATOR, orderHash);

        // Check the maker's signature of the order. We allow malleable signatures because we aren't
        // using the signature itself for replay protection.
        address maker;
        /*
            Assembly code for more efficiently computing:
            ```
            bytes32 s = vs & bytes32(EIP2098_S_MASK);
            // This can't overflow because vs >> 255 is either 0 or 1
            uint8 v; unchecked { v = uint8((uint256(vs) >> 255) + 27); }
            address maker = ecrecover(orderHash, v, r, s);
            ```
            Assembly code is based on
            https://github.com/1inch/solidity-utils/blob/a0202c68f4551d78e7f0b3843412991ac7d15f15
            /contracts/libraries/ECDSA.sol#L42-L61.
        */
        assembly ("memory-safe") {
            let s := and(vs, EIP2098_S_MASK)
            let ptr := mload(0x40)
            mstore(ptr, orderHash)
            mstore(add(ptr, 0x20), add(27, shr(255, vs)))
            mstore(add(ptr, 0x40), r)
            mstore(add(ptr, 0x60), s)
            mstore(0, 0)
            pop(staticcall(gas(), ECRECOVER_ADDR, ptr, 0x80, 0, 0x20))
            maker := mload(0)
        }

        {
            uint256 makerAmountAndTakerAmount = order.makerAmountAndTakerAmount;
            {
                uint256 makerAmount = makerAmountAndTakerAmount >> 128;
                _transferERC20TokensFrom(IERC20(address(WETH)), maker, address(this), makerAmount);
                _withdrawWETH(makerAmount);
                _sendEthToTaker(makerAmount);
            }
            uint256 takerAmount = uint128(makerAmountAndTakerAmount);
            IERC20 takerToken = order.takerToken;
            PERMIT2.permitTransferFrom(
                ISignatureTransfer.PermitTransferFrom({
                    permitted: ISignatureTransfer.TokenPermissions({
                        token: address(takerToken),
                        amount: takerAmount
                    }),
                    nonce: permitNonce,
                    deadline: uint64(expiryFlagsAndNonce >> 192)
                }),
                ISignatureTransfer.SignatureTransferDetails({
                    to: maker,
                    requestedAmount: takerAmount
                }),
                msg.sender,
                permitSignature
            );
        }

        if (orderFlagIsFloatingTxOrigin > 0) {
            // Order allows any tx.origin. Check and increment order nonce for msg.sender.
            unchecked {
                // orderNonces++ can't overflow because the nonce stored in orderNonces is a uint64 in uint256 space
                if (uint64(expiryFlagsAndNonce) != orderNonces[
                    bytes32(uint256(uint64(expiryFlagsAndNonce >> 64)) << 160) | bytes32(uint256(uint160(msg.sender)))
                ]++) { revert InvalidNonce(); }
            }

            emit OrderFilled(orderHash);
            return;
        }

        // Order restricts tx.origin. Check and increment order nonce for tx.origin.
        unchecked {
            // orderNonces++ can't overflow because the nonce stored in orderNonces is a uint64 in uint256 space
            if (uint64(expiryFlagsAndNonce) != orderNonces[
                bytes32(uint256(uint64(expiryFlagsAndNonce >> 64)) << 160) | bytes32(uint256(uint160(tx.origin)))
            ]++) { revert InvalidNonce(); }
        }

        emit OrderFilled(orderHash);
    }

    /// @dev Fee paying variant of `fillOrderForEth`
    /// @param order The order
    /// @param r The r value of the EIP-2098 representation of the maker's EIP-712 signature of the order
    /// @param vs The vs value of the EIP-2098 representation of the maker's EIP-712 signature of the order
    function fillOrderForEthWithFee_4ab6832(OrderForEthWithFee calldata order, bytes32 r, bytes32 vs) external {
        uint256 expiryFlagsAndNonce = order.expiryFlagsAndNonce;
        if (uint64(expiryFlagsAndNonce >> 192) <= block.timestamp) { revert OrderExpired(); }

        uint256 orderFlagIsFloatingTxOrigin = expiryFlagsAndNonce & ORDER_FLAG_IS_FLOATING_TX_ORIGIN;

        // Compute order hash
        bytes32 orderHash;
        assembly ("memory-safe") {
            let ptr := mload(0x40)
            mstore(ptr, ORDER_FOR_ETH_WITH_FEE_TYPEHASH)
            let txOrigin := origin()
            if gt(orderFlagIsFloatingTxOrigin, 0) {
                // If the order allows any tx.origin, it must specify a txOrigin of 0
                txOrigin := 0
            }
            mstore(add(ptr, TYPEHASH_SIZE), txOrigin)
            mstore(add(ptr, TYPEHASH_AND_TXORIGIN_SIZE), caller())
            calldatacopy(add(ptr, TYPEHASH_AND_TXORIGIN_AND_TAKER_SIZE), order, ORDER_FOR_ETH_WITH_FEE_STRUCT_SIZE)
            orderHash := keccak256(ptr, TYPEHASH_AND_ORDER_FOR_ETH_WITH_FEE_SIZE)
        }
        orderHash = ECDSA.toTypedDataHash(DOMAIN_SEPARATOR, orderHash);

        // Check the maker's signature of the order. We allow malleable signatures because we aren't
        // using the signature itself for replay protection.
        address maker;
        /*
            Assembly code for more efficiently computing:
            ```
            bytes32 s = vs & bytes32(EIP2098_S_MASK);
            // This can't overflow because vs >> 255 is either 0 or 1
            uint8 v; unchecked { v = uint8((uint256(vs) >> 255) + 27); }
            address maker = ecrecover(orderHash, v, r, s);
            ```
            Assembly code is based on
            https://github.com/1inch/solidity-utils/blob/a0202c68f4551d78e7f0b3843412991ac7d15f15
            /contracts/libraries/ECDSA.sol#L42-L61.
        */
        assembly ("memory-safe") {
            let s := and(vs, EIP2098_S_MASK)
            let ptr := mload(0x40)
            mstore(ptr, orderHash)
            mstore(add(ptr, 0x20), add(27, shr(255, vs)))
            mstore(add(ptr, 0x40), r)
            mstore(add(ptr, 0x60), s)
            mstore(0, 0)
            pop(staticcall(gas(), ECRECOVER_ADDR, ptr, 0x80, 0, 0x20))
            maker := mload(0)
        }

        uint256 makerAmountAndTakerAmount = order.makerAmountAndTakerAmount;
        {
            uint256 makerAmount = makerAmountAndTakerAmount >> 128;
            uint256 platformFee = order.platformFee;
            {
                uint256 totalFromMaker = makerAmount + platformFee;
                _transferERC20TokensFrom(IERC20(address(WETH)), maker, address(this), totalFromMaker);
                _withdrawWETH(totalFromMaker);
            }
            _sendEthTo(order.platformFeeReceiver, platformFee);
            _sendEthToTaker(makerAmount);
        }
        _transferERC20TokensFrom(order.takerToken, msg.sender, maker, uint128(makerAmountAndTakerAmount));

        if (orderFlagIsFloatingTxOrigin > 0) {
            // Order allows any tx.origin. Check and increment order nonce for msg.sender.
            unchecked {
                // orderNonces++ can't overflow because the nonce stored in orderNonces is a uint64 in uint256 space
                if (uint64(expiryFlagsAndNonce) != orderNonces[
                    bytes32(uint256(uint64(expiryFlagsAndNonce >> 64)) << 160) | bytes32(uint256(uint160(msg.sender)))
                ]++) { revert InvalidNonce(); }
            }

            emit OrderFilled(orderHash);
            return;
        }

        // Order restricts tx.origin. Check and increment order nonce for tx.origin.
        unchecked {
            // orderNonces++ can't overflow because the nonce stored in orderNonces is a uint64 in uint256 space
            if (uint64(expiryFlagsAndNonce) != orderNonces[
                bytes32(uint256(uint64(expiryFlagsAndNonce >> 64)) << 160) | bytes32(uint256(uint160(tx.origin)))
            ]++) { revert InvalidNonce(); }
        }

        emit OrderFilled(orderHash);
    }

    /// @dev ERC-2612 variant of `fillOrderForEthWithFee`
    /// @param order The order
    /// @param r The r value of the EIP-2098 representation of the maker's EIP-712 signature of the order
    /// @param vs The vs value of the EIP-2098 representation of the maker's EIP-712 signature of the order
    /// @param permit The permit data. Content depends on the takerToken.
    ///
    /// If the takerToken implements the ERC-2612 permit interface, the permit bytes are of the form
    /// [bytes32 r, bytes32 vs] where r and vs are the compact EIP-2098 representation
    /// of the taker's signature of a permit of the form
    /// `spender=this contract, value=order.takerAmount, deadline=order.expiry`.
    ///
    /// If the takerToken implements the DAI permit interface, the permit bytes are of the form
    /// [uint32 nonce, bytes32 r, bytes32 vs] where r and vs are the compact EIP-2098 representation
    /// of the taker's signature of a permit of the form
    /// `spender=this contract, nonce=nonce, expiry=order.expiry, allowed=true`.
    ///
    /// If the takerToken implements the ERC-2612-like permit interface of the form,
    ///    permit(address owner, address spender, uint256 value, uint256 deadline, bytes memory signature),
    /// the permit bytes are either of the form [bytes signature] if the signature is less than 64
    /// bytes in length or of the form [bytes5 padding, bytes signature] if the signature is at least
    /// 64 bytes in length.
    function fillOrderForEthWithFee2612_77c98eb(
        OrderForEthWithFee calldata order,
        bytes32 r,
        bytes32 vs,
        bytes calldata permit
    ) external {
        uint256 expiryFlagsAndNonce = order.expiryFlagsAndNonce;
        if (uint64(expiryFlagsAndNonce >> 192) <= block.timestamp) { revert OrderExpired(); }

        uint256 orderFlagIsFloatingTxOrigin = expiryFlagsAndNonce & ORDER_FLAG_IS_FLOATING_TX_ORIGIN;

        // Compute order hash
        bytes32 orderHash;
        assembly ("memory-safe") {
            let ptr := mload(0x40)
            mstore(ptr, ORDER_FOR_ETH_WITH_FEE_TYPEHASH)
            let txOrigin := origin()
            if gt(orderFlagIsFloatingTxOrigin, 0) {
                // If the order allows any tx.origin, it must specify a txOrigin of 0
                txOrigin := 0
            }
            mstore(add(ptr, TYPEHASH_SIZE), txOrigin)
            mstore(add(ptr, TYPEHASH_AND_TXORIGIN_SIZE), caller())
            calldatacopy(add(ptr, TYPEHASH_AND_TXORIGIN_AND_TAKER_SIZE), order, ORDER_FOR_ETH_WITH_FEE_STRUCT_SIZE)
            orderHash := keccak256(ptr, TYPEHASH_AND_ORDER_FOR_ETH_WITH_FEE_SIZE)
        }
        orderHash = ECDSA.toTypedDataHash(DOMAIN_SEPARATOR, orderHash);

        // Check the maker's signature of the order. We allow malleable signatures because we aren't
        // using the signature itself for replay protection.
        address maker;
        /*
            Assembly code for more efficiently computing:
            ```
            bytes32 s = vs & bytes32(EIP2098_S_MASK);
            // This can't overflow because vs >> 255 is either 0 or 1
            uint8 v; unchecked { v = uint8((uint256(vs) >> 255) + 27); }
            address maker = ecrecover(orderHash, v, r, s);
            ```
            Assembly code is based on
            https://github.com/1inch/solidity-utils/blob/a0202c68f4551d78e7f0b3843412991ac7d15f15
            /contracts/libraries/ECDSA.sol#L42-L61.
        */
        assembly ("memory-safe") {
            let s := and(vs, EIP2098_S_MASK)
            let ptr := mload(0x40)
            mstore(ptr, orderHash)
            mstore(add(ptr, 0x20), add(27, shr(255, vs)))
            mstore(add(ptr, 0x40), r)
            mstore(add(ptr, 0x60), s)
            mstore(0, 0)
            pop(staticcall(gas(), ECRECOVER_ADDR, ptr, 0x80, 0, 0x20))
            maker := mload(0)
        }

        uint256 makerAmountAndTakerAmount = order.makerAmountAndTakerAmount;
        {
            uint256 makerAmount = makerAmountAndTakerAmount >> 128;
            uint256 platformFee = order.platformFee;
            {
                uint256 totalFromMaker = makerAmount + platformFee;
                _transferERC20TokensFrom(IERC20(address(WETH)), maker, address(this), totalFromMaker);
                _withdrawWETH(totalFromMaker);
            }
            _sendEthTo(order.platformFeeReceiver, platformFee);
            _sendEthToTaker(makerAmount);
        }
        uint256 takerAmount = uint128(makerAmountAndTakerAmount);
        IERC20 takerToken = order.takerToken;
        _consumePermitFromTaker(takerToken, takerAmount, uint64(expiryFlagsAndNonce >> 192), permit);
        _transferERC20TokensFrom(takerToken, msg.sender, maker, takerAmount);

        if (orderFlagIsFloatingTxOrigin > 0) {
            // Order allows any tx.origin. Check and increment order nonce for msg.sender.
            unchecked {
                // orderNonces++ can't overflow because the nonce stored in orderNonces is a uint64 in uint256 space
                if (uint64(expiryFlagsAndNonce) != orderNonces[
                    bytes32(uint256(uint64(expiryFlagsAndNonce >> 64)) << 160) | bytes32(uint256(uint160(msg.sender)))
                ]++) { revert InvalidNonce(); }
            }

            emit OrderFilled(orderHash);
            return;
        }

        // Order restricts tx.origin. Check and increment order nonce for tx.origin.
        unchecked {
            // orderNonces++ can't overflow because the nonce stored in orderNonces is a uint64 in uint256 space
            if (uint64(expiryFlagsAndNonce) != orderNonces[
                bytes32(uint256(uint64(expiryFlagsAndNonce >> 64)) << 160) | bytes32(uint256(uint160(tx.origin)))
            ]++) { revert InvalidNonce(); }
        }

        emit OrderFilled(orderHash);
    }

    /// @dev Permit2 variant of `fillOrderForEthWithFee`
    /// @param order The order
    /// @param r The r value of the EIP-2098 representation of the maker's EIP-712 signature of the order
    /// @param vs The vs value of the EIP-2098 representation of the maker's EIP-712 signature of the order
    /// @param permitNonce The Permit2 SignatureTransfer nonce
    /// @param permitSignature The taker's signature of the Permit2 SignatureTransfer message
    /// allowing this contract to transfer `order.takerAmount` of `order.takerToken` from the taker.
    /// The deadline of the Permit2 SignatureTransfer must be equal to the order expiry. The caller
    /// should use the compact EIP-2098 representation of the signature to save gas; however,
    /// non-compact signatures are also supported.
    function fillOrderForEthWithFeePermit2_1999ef4(
        OrderForEthWithFee calldata order,
        bytes32 r,
        bytes32 vs,
        uint256 permitNonce,
        bytes calldata permitSignature
    ) external {
        uint256 expiryFlagsAndNonce = order.expiryFlagsAndNonce;
        if (uint64(expiryFlagsAndNonce >> 192) <= block.timestamp) { revert OrderExpired(); }

        uint256 orderFlagIsFloatingTxOrigin = expiryFlagsAndNonce & ORDER_FLAG_IS_FLOATING_TX_ORIGIN;

        // Compute order hash
        bytes32 orderHash;
        assembly ("memory-safe") {
            let ptr := mload(0x40)
            mstore(ptr, ORDER_FOR_ETH_WITH_FEE_TYPEHASH)
            let txOrigin := origin()
            if gt(orderFlagIsFloatingTxOrigin, 0) {
                // If the order allows any tx.origin, it must specify a txOrigin of 0
                txOrigin := 0
            }
            mstore(add(ptr, TYPEHASH_SIZE), txOrigin)
            mstore(add(ptr, TYPEHASH_AND_TXORIGIN_SIZE), caller())
            calldatacopy(add(ptr, TYPEHASH_AND_TXORIGIN_AND_TAKER_SIZE), order, ORDER_FOR_ETH_WITH_FEE_STRUCT_SIZE)
            orderHash := keccak256(ptr, TYPEHASH_AND_ORDER_FOR_ETH_WITH_FEE_SIZE)
        }
        orderHash = ECDSA.toTypedDataHash(DOMAIN_SEPARATOR, orderHash);

        // Check the maker's signature of the order. We allow malleable signatures because we aren't
        // using the signature itself for replay protection.
        address maker;
        /*
            Assembly code for more efficiently computing:
            ```
            bytes32 s = vs & bytes32(EIP2098_S_MASK);
            // This can't overflow because vs >> 255 is either 0 or 1
            uint8 v; unchecked { v = uint8((uint256(vs) >> 255) + 27); }
            address maker = ecrecover(orderHash, v, r, s);
            ```
            Assembly code is based on
            https://github.com/1inch/solidity-utils/blob/a0202c68f4551d78e7f0b3843412991ac7d15f15
            /contracts/libraries/ECDSA.sol#L42-L61.
        */
        assembly ("memory-safe") {
            let s := and(vs, EIP2098_S_MASK)
            let ptr := mload(0x40)
            mstore(ptr, orderHash)
            mstore(add(ptr, 0x20), add(27, shr(255, vs)))
            mstore(add(ptr, 0x40), r)
            mstore(add(ptr, 0x60), s)
            mstore(0, 0)
            pop(staticcall(gas(), ECRECOVER_ADDR, ptr, 0x80, 0, 0x20))
            maker := mload(0)
        }

        uint256 makerAmountAndTakerAmount = order.makerAmountAndTakerAmount;
        uint256 takerAmount = uint128(makerAmountAndTakerAmount);
        IERC20 takerToken = order.takerToken;
        {
            uint256 makerAmount = makerAmountAndTakerAmount >> 128;
            uint256 platformFee = order.platformFee;
            {
                uint256 totalFromMaker = makerAmount + platformFee;
                _transferERC20TokensFrom(IERC20(address(WETH)), maker, address(this), totalFromMaker);
                _withdrawWETH(totalFromMaker);
            }
            _sendEthTo(order.platformFeeReceiver, platformFee);
            _sendEthToTaker(makerAmount);
        }
        PERMIT2.permitTransferFrom(
            ISignatureTransfer.PermitTransferFrom({
                permitted: ISignatureTransfer.TokenPermissions({
                    token: address(takerToken),
                    amount: takerAmount
                }),
                nonce: permitNonce,
                deadline: uint64(expiryFlagsAndNonce >> 192)
            }),
            ISignatureTransfer.SignatureTransferDetails({
                to: maker,
                requestedAmount: takerAmount
            }),
            msg.sender,
            permitSignature
        );

        if (orderFlagIsFloatingTxOrigin > 0) {
            // Order allows any tx.origin. Check and increment order nonce for msg.sender.
            unchecked {
                // orderNonces++ can't overflow because the nonce stored in orderNonces is a uint64 in uint256 space
                if (uint64(expiryFlagsAndNonce) != orderNonces[
                    bytes32(uint256(uint64(expiryFlagsAndNonce >> 64)) << 160) | bytes32(uint256(uint160(msg.sender)))
                ]++) { revert InvalidNonce(); }
            }

            emit OrderFilled(orderHash);
            return;
        }

        // Order restricts tx.origin. Check and increment order nonce for tx.origin.
        unchecked {
            // orderNonces++ can't overflow because the nonce stored in orderNonces is a uint64 in uint256 space
            if (uint64(expiryFlagsAndNonce) != orderNonces[
                bytes32(uint256(uint64(expiryFlagsAndNonce >> 64)) << 160) | bytes32(uint256(uint160(tx.origin)))
            ]++) { revert InvalidNonce(); }
        }

        emit OrderFilled(orderHash);
    }

    /// @dev Calls the specified token's executeMetaTransaction method and then calls this contract
    /// @param token The token to call
    /// @param functionSignature The executeMetaTransaction functionSignature parameter
    /// @param r The r value of the EIP-2098 representation of the taker's EIP-712 signature of
    /// the meta transaction
    /// @param vs The vs value of the EIP-2098 representation of the taker's EIP-712 signature of
    /// the meta transaction
    /// @param fillOrderCalldata The calldata to use when calling this contract
    function executeMetaTransactionAndFillOrder_9fa5349(
        INativeMetaTransaction token,
        bytes calldata functionSignature,
        bytes32 r,
        bytes32 vs,
        bytes calldata fillOrderCalldata
    ) external {
        unchecked {
            token.executeMetaTransaction(
                msg.sender,
                functionSignature,
                r,
                vs & bytes32(EIP2098_S_MASK),    // sigS: vs without most significant bit
                // This can't overflow because vs >> 255 is either 0 or 1
                uint8((uint256(vs) >> 255) + 27) // sigV: most significant bit of vs + 27 (27 or 28)
            );
        }

        (bool success,) = address(this).delegatecall(fillOrderCalldata);
        if (!success) { revert FillOrderCallFailed(); }
    }

    function getWETH() external view returns (IWETH) {
        return WETH;
    }

    function getPermit2() external view returns (ISignatureTransfer) {
        return PERMIT2;
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IEIP712 {
    function DOMAIN_SEPARATOR() external view returns (bytes32);
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC2612WithBytesSignature {
    function permit(address owner, address spender, uint256 value, uint256 deadline, bytes memory signature) external;
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface INativeMetaTransaction {
    function executeMetaTransaction(
        address userAddress,
        bytes calldata functionSignature,
        bytes32 sigR,
        bytes32 sigS,
        uint8 sigV
    ) external payable returns (bytes memory);
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IEIP712} from "./IEIP712.sol";

/// @title SignatureTransfer
/// @notice Handles ERC20 token transfers through signature based actions
/// @dev Requires user's token approval on the Permit2 contract
interface ISignatureTransfer is IEIP712 {
    /// @notice Thrown when the requested amount for a transfer is larger than the permissioned amount
    /// @param maxAmount The maximum amount a spender can request to transfer
    error InvalidAmount(uint256 maxAmount);

    /// @notice Thrown when the number of tokens permissioned to a spender does not match the number of tokens being transferred
    /// @dev If the spender does not need to transfer the number of tokens permitted, the spender can request amount 0 to be transferred
    error LengthMismatch();

    /// @notice Emits an event when the owner successfully invalidates an unordered nonce.
    event UnorderedNonceInvalidation(address indexed owner, uint256 word, uint256 mask);

    /// @notice The token and amount details for a transfer signed in the permit transfer signature
    struct TokenPermissions {
        // ERC20 token address
        address token;
        // the maximum amount that can be spent
        uint256 amount;
    }

    /// @notice The signed permit message for a single token transfer
    struct PermitTransferFrom {
        TokenPermissions permitted;
        // a unique value for every token owner's signature to prevent signature replays
        uint256 nonce;
        // deadline on the permit signature
        uint256 deadline;
    }

    /// @notice Specifies the recipient address and amount for batched transfers.
    /// @dev Recipients and amounts correspond to the index of the signed token permissions array.
    /// @dev Reverts if the requested amount is greater than the permitted signed amount.
    struct SignatureTransferDetails {
        // recipient address
        address to;
        // spender requested amount
        uint256 requestedAmount;
    }

    /// @notice Used to reconstruct the signed permit message for multiple token transfers
    /// @dev Do not need to pass in spender address as it is required that it is msg.sender
    /// @dev Note that a user still signs over a spender address
    struct PermitBatchTransferFrom {
        // the tokens and corresponding amounts permitted for a transfer
        TokenPermissions[] permitted;
        // a unique value for every token owner's signature to prevent signature replays
        uint256 nonce;
        // deadline on the permit signature
        uint256 deadline;
    }

    /// @notice A map from token owner address and a caller specified word index to a bitmap. Used to set bits in the bitmap to prevent against signature replay protection
    /// @dev Uses unordered nonces so that permit messages do not need to be spent in a certain order
    /// @dev The mapping is indexed first by the token owner, then by an index specified in the nonce
    /// @dev It returns a uint256 bitmap
    /// @dev The index, or wordPosition is capped at type(uint248).max
    function nonceBitmap(address, uint256) external view returns (uint256);

    /// @notice Transfers a token using a signed permit message
    /// @dev Reverts if the requested amount is greater than the permitted signed amount
    /// @param permit The permit data signed over by the owner
    /// @param owner The owner of the tokens to transfer
    /// @param transferDetails The spender's requested transfer details for the permitted token
    /// @param signature The signature to verify
    function permitTransferFrom(
        PermitTransferFrom memory permit,
        SignatureTransferDetails calldata transferDetails,
        address owner,
        bytes calldata signature
    ) external;

    /// @notice Transfers a token using a signed permit message
    /// @notice Includes extra data provided by the caller to verify signature over
    /// @dev The witness type string must follow EIP712 ordering of nested structs and must include the TokenPermissions type definition
    /// @dev Reverts if the requested amount is greater than the permitted signed amount
    /// @param permit The permit data signed over by the owner
    /// @param owner The owner of the tokens to transfer
    /// @param transferDetails The spender's requested transfer details for the permitted token
    /// @param witness Extra data to include when checking the user signature
    /// @param witnessTypeString The EIP-712 type definition for remaining string stub of the typehash
    /// @param signature The signature to verify
    function permitWitnessTransferFrom(
        PermitTransferFrom memory permit,
        SignatureTransferDetails calldata transferDetails,
        address owner,
        bytes32 witness,
        string calldata witnessTypeString,
        bytes calldata signature
    ) external;

    /// @notice Transfers multiple tokens using a signed permit message
    /// @param permit The permit data signed over by the owner
    /// @param owner The owner of the tokens to transfer
    /// @param transferDetails Specifies the recipient and requested amount for the token transfer
    /// @param signature The signature to verify
    function permitTransferFrom(
        PermitBatchTransferFrom memory permit,
        SignatureTransferDetails[] calldata transferDetails,
        address owner,
        bytes calldata signature
    ) external;

    /// @notice Transfers multiple tokens using a signed permit message
    /// @dev The witness type string must follow EIP712 ordering of nested structs and must include the TokenPermissions type definition
    /// @notice Includes extra data provided by the caller to verify signature over
    /// @param permit The permit data signed over by the owner
    /// @param owner The owner of the tokens to transfer
    /// @param transferDetails Specifies the recipient and requested amount for the token transfer
    /// @param witness Extra data to include when checking the user signature
    /// @param witnessTypeString The EIP-712 type definition for remaining string stub of the typehash
    /// @param signature The signature to verify
    function permitWitnessTransferFrom(
        PermitBatchTransferFrom memory permit,
        SignatureTransferDetails[] calldata transferDetails,
        address owner,
        bytes32 witness,
        string calldata witnessTypeString,
        bytes calldata signature
    ) external;

    /// @notice Invalidates the bits specified in mask for the bitmap at the word position
    /// @dev The wordPos is maxed at type(uint248).max
    /// @param wordPos A number to index the nonceBitmap at
    /// @param mask A bitmap masked against msg.sender's current bitmap at the word position
    function invalidateUnorderedNonces(uint256 wordPos, uint256 mask) external;
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IWETH is IERC20 {
    function deposit() external payable;

    function withdraw(uint256 amount) external;
}
