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

pragma solidity ^0.8.19;

import {ReentrancyGuard} from "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import {IEpochsManager} from "@pnetwork-association/dao-v2-contracts/contracts/interfaces/IEpochsManager.sol";
import {IFeesManager} from "@pnetwork-association/dao-v2-contracts/contracts/interfaces/IFeesManager.sol";
import {MerkleProof} from "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
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
error OperationNotQueued(IPNetworkHub.Operation operation);
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
error MaxChallengeDurationPassed();
error MaxChallengeDurationNotPassed();
error ChallengeNotFound(IPNetworkHub.Challenge challenge);
error MaxChallengeDurationMustBeLessOrEqualThanMaxChallengePeriodDuration();
error InvalidEpoch(uint16 epoch);

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
    uint16 public immutable kChallengePeriod;
    uint16 public immutable maxOperationsInQueue;
    bytes4 public immutable interimChainNetworkId;
    uint256 public immutable lockedAmountChallengePeriod;
    uint256 public immutable lockedAmountStartChallenge;
    uint64 public immutable maxChallengeDuration;

    uint256 public challengesNonce;
    uint16 public numberOfOperationsInQueue;

    modifier onlySentinel(bytes32[] calldata proof) {
        _;
    }

    modifier onlyGuardian(bytes32[] calldata proof) {
        // TODO: check if msg.sender is a guardian
        _;
    }

    modifier onlyGovernance(string memory action) {
        // TODO: check if msg.sender is a governance
        _;
    }

    modifier onlyIfNotInactive(bytes32[] calldata proof) {
        // NOTE: avoid allowing slashed guardians/sentinels to operate without having resume itself on the RegistrationManager
        // TODO: if _epochsActorsStatus[epoch][sentinel] == ActorsStatus.Inactive revert
        _;
    }

    modifier onlyFarFromEpochClosingStartChallenge() {
        uint256 epochDuration = IEpochsManager(epochsManager).epochDuration();
        uint16 currentEpoch = IEpochsManager(epochsManager).currentEpoch();
        uint256 startFirstEpochTimestamp = IEpochsManager(epochsManager).startFirstEpochTimestamp();
        uint256 currentEpochEndTimestamp = startFirstEpochTimestamp + ((currentEpoch + 1) * epochDuration);

        // NOTE: 1 hours = threshold that a guardian/sentinel or challenger has time to resolve the challenge
        // before the epoch ends. Not setting this threshold would mean that it is possible
        // to open a challenge that can be solved an instant before the epoch change causing problems.
        // It is important that the system enters in lockdown mode before stopping to start challenges.
        // In this way we are sure that no malicious operations can be queued when keep alive mechanism is disabled.
        // currentEpochEndTimestamp - 1 hours - maxChallengeDuration <= currentEpochEndTimestamp - 1 hours - maxChallengePeriodDuration
        // maxChallengeDuration <=  maxChallengePeriodDuration
        // maxChallengeDuration <= baseChallengePeriodDuration + (maxOperationsInQueue * maxOperationsInQueue * kChallengePeriod) - kChallengePeriod
        if (block.timestamp + maxChallengeDuration > currentEpochEndTimestamp - 1 hours) {
            revert NearToEpochEnd();
        }

        _;
    }

    modifier onlyWhenIsNotInLockDown(bool addMaxChallengePeriodDuration) {
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
            block.timestamp +
                (
                    addMaxChallengePeriodDuration
                        ? baseChallengePeriodDuration +
                            (maxOperationsInQueue * maxOperationsInQueue * kChallengePeriod) -
                            kChallengePeriod
                        : 0
                ) >=
            currentEpochEndTimestamp - 1 hours
        ) {
            revert LockDown();
        }

        _;
    }

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
        uint64 maxChallengeDuration_,
        uint32 expectedSourceChainId
    ) GovernanceMessageHandler(telepathyRouter, governanceMessageVerifier, expectedSourceChainId) {
        // NOTE: see the comment within onlyFarFromEpochClosingStartChallenge
        if (
            maxChallengeDuration_ >
            baseChallengePeriodDuration_ +
                (maxOperationsInQueue_ * maxOperationsInQueue_ * kChallengePeriod_) -
                kChallengePeriod_
        ) {
            revert MaxChallengeDurationMustBeLessOrEqualThanMaxChallengePeriodDuration();
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
        maxChallengeDuration = maxChallengeDuration_;
    }

    /// @inheritdoc IPNetworkHub
    function getNetworkId() public view returns (bytes4) {
        return Network.getCurrentNetworkId();
    }

    /// @inheritdoc IPNetworkHub
    function challengeIdOf(Challenge memory challenge) public view returns (bytes32) {
        return
            sha256(
                abi.encode(challenge.nonce, challenge.actor, challenge.challenger, challenge.timestamp, block.chainid)
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
    function getChallengeStatus(Challenge calldata challenge) public view returns (ChallengeStatus) {
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
                abi.encode(
                    operation.originBlockHash,
                    operation.originTransactionHash,
                    operation.originNetworkId,
                    operation.nonce,
                    operation.originAccount,
                    operation.destinationAccount,
                    operation.destinationNetworkId,
                    operation.forwardDestinationNetworkId,
                    operation.underlyingAssetName,
                    operation.underlyingAssetSymbol,
                    operation.underlyingAssetDecimals,
                    operation.underlyingAssetTokenAddress,
                    operation.underlyingAssetNetworkId,
                    operation.assetAmount,
                    operation.protocolFeeAssetAmount,
                    operation.networkFeeAssetAmount,
                    operation.forwardNetworkFeeAssetAmount,
                    operation.userData,
                    operation.optionsMask,
                    operation.isForProtocol
                )
            );
    }

    /// @inheritdoc IPNetworkHub
    function operationStatusOf(Operation calldata operation) external view returns (OperationStatus) {
        return _operationsStatus[operationIdOf(operation)];
    }

    /// @inheritdoc IPNetworkHub
    function protocolGuardianCancelOperation(
        Operation calldata operation,
        bytes32[] calldata proof
    ) external onlyWhenIsNotInLockDown(false) onlyGuardian(proof) onlyIfNotInactive(proof) {
        _protocolCancelOperation(operation, Actor.Guardian);
    }

    /// @inheritdoc IPNetworkHub
    function protocolGovernanceCancelOperation(Operation calldata operation) external onlyGovernance("cancel") {
        _protocolCancelOperation(operation, Actor.Governance);
    }

    /// @inheritdoc IPNetworkHub
    function protocolSentinelCancelOperation(
        Operation calldata operation,
        bytes32[] calldata proof
    ) external onlyWhenIsNotInLockDown(false) onlySentinel(proof) onlyIfNotInactive(proof) {
        _protocolCancelOperation(operation, Actor.Sentinel);
    }

    /// @inheritdoc IPNetworkHub
    function protocolExecuteOperation(
        Operation calldata operation
    ) external payable onlyWhenIsNotInLockDown(false) nonReentrant {
        bytes32 operationId = operationIdOf(operation);
        OperationStatus operationStatus = _operationsStatus[operationId];
        if (operationStatus == OperationStatus.Executed) {
            revert OperationAlreadyExecuted(operation);
        } else if (operationStatus == OperationStatus.Cancelled) {
            revert OperationAlreadyCancelled(operation);
        } else if (operationStatus == OperationStatus.Null) {
            revert OperationNotQueued(operation);
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
    function protocolQueueOperation(Operation calldata operation) external payable onlyWhenIsNotInLockDown(true) {
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

        if (block.timestamp <= challenge.timestamp + maxChallengeDuration) {
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
    function solveChallengeGuardian(
        Challenge calldata challenge,
        bytes32[] calldata proof
    ) external onlyGuardian(proof) {
        address guardian = _msgSender();
        if (guardian != challenge.actor) {
            revert InvalidGuardian(guardian);
        }

        _solveChallenge(challenge);
    }

    /// @inheritdoc IPNetworkHub
    function solveChallengeSentinel(
        Challenge calldata challenge,
        bytes32[] calldata proof
    ) external onlySentinel(proof) {
        address sentinel = _msgSender();
        if (sentinel != challenge.actor) {
            revert InvalidSentinel(sentinel);
        }

        _solveChallenge(challenge);
    }

    /// @inheritdoc IPNetworkHub
    function startChallengeGuardian(
        address guardian,
        bytes32[] memory proof
    ) external payable onlyFarFromEpochClosingStartChallenge {
        if (
            !MerkleProof.verify(
                proof,
                _epochsGuardiansMerkleRoot[IEpochsManager(epochsManager).currentEpoch()],
                keccak256(abi.encodePacked(guardian))
            )
        ) {
            revert InvalidGuardian(guardian);
        }

        _startChallenge(guardian);
    }

    /// @inheritdoc IPNetworkHub
    function startChallengeSentinel(
        address sentinel,
        bytes32[] calldata proof
    ) external payable onlyFarFromEpochClosingStartChallenge {
        if (
            !MerkleProof.verify(
                proof,
                _epochsSentinelsMerkleRoot[IEpochsManager(epochsManager).currentEpoch()],
                keccak256(abi.encodePacked(sentinel))
            )
        ) {
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

    function _protocolCancelOperation(Operation calldata operation, Actor actor) internal {
        bytes32 operationId = operationIdOf(operation);

        OperationStatus operationStatus = _operationsStatus[operationId];
        if (operationStatus == OperationStatus.Executed) {
            revert OperationAlreadyExecuted(operation);
        } else if (operationStatus == OperationStatus.Cancelled) {
            revert OperationAlreadyCancelled(operation);
        } else if (operationStatus == OperationStatus.Null) {
            revert OperationNotQueued(operation);
        }

        (uint64 startTimestamp, uint64 endTimestamp) = _challengePeriodOf(operationId, operationStatus);
        if (uint64(block.timestamp) >= endTimestamp) {
            revert ChallengePeriodTerminated(startTimestamp, endTimestamp);
        }

        Action memory action = Action({actor: _msgSender(), timestamp: uint64(block.timestamp)});
        if (actor == Actor.Governance) {
            if (_operationsGovernanceCancelAction[operationId].actor != address(0)) {
                revert GovernanceOperationAlreadyCancelled(operation);
            }

            _operationsGovernanceCancelAction[operationId] = action;
            emit GovernanceOperationCancelled(operation);
        }
        if (actor == Actor.Guardian) {
            if (_operationsGuardianCancelAction[operationId].actor != address(0)) {
                revert GuardianOperationAlreadyCancelled(operation);
            }

            _operationsGuardianCancelAction[operationId] = action;
            emit GuardianOperationCancelled(operation);
        }
        if (actor == Actor.Sentinel) {
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

    function _solveChallenge(Challenge calldata challenge) internal {
        bytes32 challengeId = challengeIdOf(challenge);
        uint16 currentEpoch = IEpochsManager(epochsManager).currentEpoch();
        ChallengeStatus challengeStatus = _epochsChallengesStatus[currentEpoch][challengeId];

        if (challengeStatus == ChallengeStatus.Null) {
            revert ChallengeNotFound(challenge);
        }

        if (challengeStatus != ChallengeStatus.Pending) {
            revert InvalidChallengeStatus(challengeStatus, ChallengeStatus.Pending);
        }

        if (block.timestamp > challenge.timestamp + maxChallengeDuration) {
            revert MaxChallengeDurationPassed();
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
            timestamp: uint64(block.timestamp)
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
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {IPRegistry} from "../interfaces/IPRegistry.sol";
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
        address msgSender = _msgSender();
        if (msgSender != telepathyRouter) revert NotRouter(msgSender, telepathyRouter);
        // NOTE: we just need to check the address that called the telepathy router (GovernanceMessageVerifier)
        // and not who emitted the event on Polygon since it's the GovernanceMessageVerifier that verifies that
        // a certain event has been emitted by the GovernanceMessageEmitter

        if (sourceChainId != expectedSourceChainId) {
            revert UnsupportedChainId(sourceChainId, expectedSourceChainId);
        }

        if (sourceSender != governanceMessageVerifier) {
            revert InvalidGovernanceMessageVerifier(sourceSender, governanceMessageVerifier);
        }

        _onGovernanceMessage(data);

        return ITelepathyHandler.handleTelepathy.selector;
    }

    function _onGovernanceMessage(bytes memory message) internal virtual {}
}
pragma solidity ^0.8.19;

interface ITelepathyHandler {
    function handleTelepathy(uint32 sourceChainId, address sourceSender, bytes memory data) external returns (bytes4);
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
    enum Actor {
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
     * @notice Calculates the current active actors duration which is use to secure the system when few there are few actor that secure the system.
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
     *
     */
    function protocolSentinelCancelOperation(Operation calldata operation, bytes32[] calldata proof) external;

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
     *
     */
    function solveChallengeGuardian(Challenge calldata challenge, bytes32[] calldata proof) external;

    /*
     * @notice Solve a challenge of a sentinel and sends the bond (lockedAmountStartChallenge) to the DAO.
     *
     * @param challenge
     *
     */
    function solveChallengeSentinel(Challenge calldata challenge, bytes32[] calldata proof) external;

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
        uint256 currentchainId;
        assembly {
            currentchainId := chainid()
        }

        return getNetworkIdFromChainId(uint32(currentchainId));
    }
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
