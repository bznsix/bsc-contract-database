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
// OpenZeppelin Contracts (last updated v4.8.0) (utils/cryptography/draft-EIP712.sol)

pragma solidity ^0.8.0;

// EIP-712 is Final as of 2022-08-11. This file is deprecated.

import "./EIP712.sol";
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
// OpenZeppelin Contracts (last updated v4.8.0) (utils/cryptography/EIP712.sol)

pragma solidity ^0.8.0;

import "./ECDSA.sol";

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
 * _Available since v3.4._
 */
abstract contract EIP712 {
    /* solhint-disable var-name-mixedcase */
    // Cache the domain separator as an immutable value, but also store the chain id that it corresponds to, in order to
    // invalidate the cached domain separator if the chain id changes.
    bytes32 private immutable _CACHED_DOMAIN_SEPARATOR;
    uint256 private immutable _CACHED_CHAIN_ID;
    address private immutable _CACHED_THIS;

    bytes32 private immutable _HASHED_NAME;
    bytes32 private immutable _HASHED_VERSION;
    bytes32 private immutable _TYPE_HASH;

    /* solhint-enable var-name-mixedcase */

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
        bytes32 hashedName = keccak256(bytes(name));
        bytes32 hashedVersion = keccak256(bytes(version));
        bytes32 typeHash = keccak256(
            "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"
        );
        _HASHED_NAME = hashedName;
        _HASHED_VERSION = hashedVersion;
        _CACHED_CHAIN_ID = block.chainid;
        _CACHED_DOMAIN_SEPARATOR = _buildDomainSeparator(typeHash, hashedName, hashedVersion);
        _CACHED_THIS = address(this);
        _TYPE_HASH = typeHash;
    }

    /**
     * @dev Returns the domain separator for the current chain.
     */
    function _domainSeparatorV4() internal view returns (bytes32) {
        if (address(this) == _CACHED_THIS && block.chainid == _CACHED_CHAIN_ID) {
            return _CACHED_DOMAIN_SEPARATOR;
        } else {
            return _buildDomainSeparator(_TYPE_HASH, _HASHED_NAME, _HASHED_VERSION);
        }
    }

    function _buildDomainSeparator(
        bytes32 typeHash,
        bytes32 nameHash,
        bytes32 versionHash
    ) private view returns (bytes32) {
        return keccak256(abi.encode(typeHash, nameHash, versionHash, block.chainid, address(this)));
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
pragma solidity ^0.8.17;

interface ILazyNFT {
    function redeem(
        address _redeem,
        uint256 _tokenid,
        string memory _uri
    ) external returns (uint256);
}
//SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./MarketEvents.sol";
import "./Verification.sol";
import "./ILazymint.sol";
import "./verifySignature.sol";
//import "hardhat/console.sol";

/// @title An Auction Contract for bidding and selling single and batched NFTs
/// @notice This contract can be used for auctioning any NFTs, and accepts any ERC20 token as payment
/// @author Disruptive Studios
/// @author Modified from Avo Labs GmbH (https://github.com/avolabs-io/nft-auction/blob/master/contracts/NFTAuction.sol)
contract NFTMarket is MarketEvents, verification, VerifySignature {
    ///@notice Map each auction with the token ID
    mapping(address => mapping(uint256 => Auction)) public nftContractAuctions;
    ///@notice If transfer fail save to withdraw later
    mapping(address => uint256) public failedTransferCredits;

    ///@notice Default values market fee
    address payable public addressmarketfee;
    uint256 public feeMarket = 250; //Equal 2.5%

    ///@notice Each Auction is unique to each NFT (contract + id pairing).
    ///@param auctionBidPeriod Increments the length of time the auction is open,
    ///in which a new bid can be made after each bid.
    ///@param ERC20Token The seller can specify an ERC20 token that can be used to bid or purchase the NFT.
    struct Auction {
        uint32 bidIncreasePercentage;
        uint32 auctionBidPeriod;
        uint64 auctionEnd;
        uint256 minPrice;
        uint256 buyNowPrice;
        uint256 nftHighestBid;
        address nftHighestBidder;
        address nftSeller;
        address ERC20Token;
        address[] feeRecipients;
        uint32[] feePercentages;
        bool lazymint;
        string metadata;
    }

    struct paymentInfo {
        address _nftContractAddress;
        uint256 _tokenId;
        address _erc20Token;
        uint256 _tokenAmount;
        uint256 _value;
        uint256 _coupon;
        bytes _signature;
        uint256 _nonce;
        bool _discount;
        address[] referals;
        uint256[] amounts;
        uint256 totalReferals;
    }

    

    /*///////////////////////////////////////////////////////////////
                              MODIFIERS
    //////////////////////////////////////////////////////////////*/

    modifier isAuctionNotStartedByOwner(
        address _nftContractAddress,
        uint256 _tokenId
    ) {
        require(
            nftContractAuctions[_nftContractAddress][_tokenId].nftSeller !=
                msg.sender,
            "Initiated by the owner"
        );

        if (
            nftContractAuctions[_nftContractAddress][_tokenId].nftSeller !=
            address(0)
        ) {
            require(
                msg.sender == IERC721(_nftContractAddress).ownerOf(_tokenId),
                "Sender doesn't own NFT"
            );
        }
        _;
    }

    /*///////////////////////////////////////////////////////////////
                              END MODIFIERS
    //////////////////////////////////////////////////////////////*/

    // constructor
    constructor(address payable _addressmarketfee) {
        addressmarketfee = _addressmarketfee;
    }

    /*///////////////////////////////////////////////////////////////
                    AUCTION/SELL CHECK FUNCTIONS
    //////////////////////////////////////////////////////////////*/
    ///@dev If the buy now price is set by the seller, check that the highest bid meets that price.
    function _isBuyNowPriceMet(address _nftContractAddress, uint256 _tokenId)
        internal
        view
        returns (bool)
    {
        uint256 buyNowPrice = nftContractAuctions[_nftContractAddress][_tokenId]
            .buyNowPrice;
        return
            buyNowPrice > 0 &&
            nftContractAuctions[_nftContractAddress][_tokenId].nftHighestBid >=
            buyNowPrice;
    }

    ///@dev Check that a bid is applicable for the purchase of the NFT.
    ///@dev In the case of a sale: the bid needs to meet the buyNowPrice.
    ///@dev if buyNowPrice is met, ignore increase percentage
    ///@dev In the case of an auction: the bid needs to be a % higher than the previous bid.
    ///@dev if the NFT is up for auction, the bid needs to be a % higher than the previous bid
    function _bidMeetBidRequirements(
        address _nftContractAddress,
        uint256 _tokenId,
        uint256 _tokenAmount,
        uint256 _value,
        bool _sign
    ) internal view returns (bool _state) {
        uint256 buyNowPrice = nftContractAuctions[_nftContractAddress][
                _tokenId
            ].buyNowPrice;
        if (_sign) {
            uint256 newTotal = buyNowPrice >= _value ?  (buyNowPrice - _value) : (_value - buyNowPrice);
            if (buyNowPrice > 0 &&
                (msg.value >= newTotal || _tokenAmount >= newTotal)) {
                return _state = true;
            }
        } else {
            if (
                buyNowPrice > 0 &&
                (msg.value >= buyNowPrice || _tokenAmount >= buyNowPrice)
            ) {
                return _state = true;
            }
            uint32 bidIncreasePercentage = nftContractAuctions[
                _nftContractAddress
            ][_tokenId].bidIncreasePercentage;

            uint256 bidIncreaseAmount = (nftContractAuctions[
                _nftContractAddress
            ][_tokenId].nftHighestBid * (10000 + bidIncreasePercentage)) /
                10000;
            return (msg.value >= bidIncreaseAmount ||
                _tokenAmount >= bidIncreaseAmount);
        }
    }

    ///@dev Payment is accepted in the following scenarios:
    ///@dev (1) Auction already created - can accept ETH or Specified Token
    ///@dev  --------> Cannot bid with ETH & an ERC20 Token together in any circumstance<------
    ///@dev (2) Auction not created - only ETH accepted (cannot early bid with an ERC20 Token
    ///@dev (3) Cannot make a zero bid (no ETH or Token amount)
    function _isPaymentAccepted(
        address _nftContractAddress,
        uint256 _tokenId,
        address _bidERC20Token,
        uint256 _tokenAmount,
        uint256 _value,
        bool _sign
    ) internal view returns (bool) {
       address auctionERC20Token = nftContractAuctions[
                _nftContractAddress][_tokenId].ERC20Token;
        if (_sign) {
            if(_value >= nftContractAuctions[_nftContractAddress][_tokenId].buyNowPrice){
                    return true;
            }
            if (auctionERC20Token != address(0)) {
                return
                    msg.value == 0 &&
                    auctionERC20Token == _bidERC20Token &&
                    _tokenAmount > 0;
            } else {
                return
                    msg.value != 0 &&
                    _bidERC20Token == address(0) &&
                    _tokenAmount == 0;
            }
            //return true;
        } else {
            if (auctionERC20Token != address(0)) {
                return
                    msg.value == 0 &&
                    auctionERC20Token == _bidERC20Token &&
                    _tokenAmount > 0;
            } else {
                return
                    msg.value != 0 &&
                    _bidERC20Token == address(0) &&
                    _tokenAmount == 0;
            }
        }
    }

    /*///////////////////////////////////////////////////////////////
                                     END
                            AUCTION CHECK FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /*///////////////////////////////////////////////////////////////
                      TRANSFER NFTS TO CONTRACT
    //////////////////////////////////////////////////////////////*/

    function _transferNftToAuctionContract(
        address _nftContractAddress,
        uint256 _tokenId
    ) internal {
        address _nftSeller = nftContractAuctions[_nftContractAddress][_tokenId]
            .nftSeller;
        if (IERC721(_nftContractAddress).ownerOf(_tokenId) == _nftSeller) {
            IERC721(_nftContractAddress).transferFrom(
                _nftSeller,
                address(this),
                _tokenId
            );
            require(
                IERC721(_nftContractAddress).ownerOf(_tokenId) == address(this),
                "nft transfer failed"
            );
        } else {
            require(
                IERC721(_nftContractAddress).ownerOf(_tokenId) == address(this),
                "Seller doesn't own NFT"
            );
        }
    }

    /*///////////////////////////////////////////////////////////////
                                END
                      TRANSFER NFTS TO CONTRACT
    //////////////////////////////////////////////////////////////*/

    /*///////////////////////////////////////////////////////////////
                          AUCTION CREATION
    //////////////////////////////////////////////////////////////*/

    ///@dev Setup parameters applicable to all auctions and whitelised sales:
    ///@dev --> ERC20 Token for payment (if specified by the seller) : _erc20Token
    ///@dev --> minimum price : _minPrice
    ///@dev --> buy now price : _buyNowPrice
    ///@dev --> the nft seller: msg.sender
    ///@dev --> The fee recipients & their respective percentages for a sucessful auction/sale
    function _setupAuction(
        address _nftContractAddress,
        uint256 _tokenId,
        address _erc20Token,
        uint256 _minPrice,
        uint256 _buyNowPrice,
        uint32 _bidIncreasePercentage,
        uint32 _auctionBidPeriod,
        address[] memory _feeRecipients,
        uint32[] memory _feePercentages
    ) internal isFeePercentagesLessThanMaximum(_feePercentages) {
        if (_erc20Token != address(0)) {
            nftContractAuctions[_nftContractAddress][_tokenId]
                .ERC20Token = _erc20Token;
        }
        nftContractAuctions[_nftContractAddress][_tokenId]
            .feeRecipients = _feeRecipients;
        nftContractAuctions[_nftContractAddress][_tokenId]
            .feePercentages = _feePercentages;
        nftContractAuctions[_nftContractAddress][_tokenId]
            .buyNowPrice = _buyNowPrice;
        nftContractAuctions[_nftContractAddress][_tokenId].minPrice = _minPrice;
        nftContractAuctions[_nftContractAddress][_tokenId].nftSeller = msg
            .sender;
        nftContractAuctions[_nftContractAddress][_tokenId]
            .bidIncreasePercentage = _bidIncreasePercentage;
        nftContractAuctions[_nftContractAddress][_tokenId]
            .auctionBidPeriod = _auctionBidPeriod;
    }

    function _createNewNftAuction(
        address _nftContractAddress,
        uint256 _tokenId,
        address _erc20Token, //change to BEP20Token
        uint256 _minPrice,
        uint256 _buyNowPrice,
        uint32 _bidIncreasePercentage,
        uint32 _auctionBidPeriod,
        address[] memory _feeRecipients,
        uint32[] memory _feePercentages,
        bool _lazymint,
        string memory _metadata
    ) internal {
        string memory _uri;
        if (!_lazymint) {
            _uri = metadata(_nftContractAddress, _tokenId);
        } else {
            _uri = _metadata;
        }
        nftContractAuctions[_nftContractAddress][_tokenId]
            .nftHighestBid = _minPrice;
        nftContractAuctions[_nftContractAddress][_tokenId].lazymint = _lazymint;
        nftContractAuctions[_nftContractAddress][_tokenId].metadata = _metadata;
        nftContractAuctions[_nftContractAddress][_tokenId].auctionEnd = (uint64(
            block.timestamp
        ) + _auctionBidPeriod);
        _setupAuction(
            _nftContractAddress,
            _tokenId,
            _erc20Token,
            _minPrice,
            _buyNowPrice,
            _bidIncreasePercentage,
            _auctionBidPeriod,
            _feeRecipients,
            _feePercentages
        );
        emit NftAuctionCreated(
            _nftContractAddress,
            _tokenId,
            msg.sender,
            _erc20Token,
            _minPrice,
            _buyNowPrice,
            _auctionBidPeriod,
            _bidIncreasePercentage,
            _feeRecipients,
            _feePercentages,
            _lazymint,
            _uri
        );
    }

    ///@param _bidIncreasePercentage It is the percentage for an offer to be validated.
    ///@param _auctionBidPeriod this is the time that the auction lasts until another bid occurs
    function createNewNftAuction(
        address _nftContractAddress,
        uint256 _tokenId,
        address _erc20Token,
        uint256 _minPrice,
        uint256 _buyNowPrice,
        uint32 _auctionBidPeriod,
        uint32 _bidIncreasePercentage,
        address[] memory _feeRecipients,
        uint32[] memory _feePercentages,
        bool _lazymint,
        string memory _metadata
    )
        external
        isAuctionNotStartedByOwner(_nftContractAddress, _tokenId)
        priceGreaterThanZero(_minPrice)
    {
        require(
            _bidIncreasePercentage >= 100, //Equal 1%
            "Bid increase percentage too low"
        );
        _createNewNftAuction(
            _nftContractAddress,
            _tokenId,
            _erc20Token,
            _minPrice,
            _buyNowPrice,
            _bidIncreasePercentage,
            _auctionBidPeriod,
            _feeRecipients,
            _feePercentages,
            _lazymint,
            _metadata
        );
        if (!_lazymint) {
            _transferNftToAuctionContract(_nftContractAddress, _tokenId);
        }
    }

    /*///////////////////////////////////////////////////////////////
                              END
                       AUCTION CREATION
    //////////////////////////////////////////////////////////////*/

    /*///////////////////////////////////////////////////////////////
                              SALES
    //////////////////////////////////////////////////////////////*/
    function _setupSale(
        address _nftContractAddress,
        uint256 _tokenId,
        address _erc20Token,
        uint256 _buyNowPrice,
        address[] memory _feeRecipients,
        uint32[] memory _feePercentages
    ) internal isFeePercentagesLessThanMaximum(_feePercentages) {
        if (_erc20Token != address(0)) {
            nftContractAuctions[_nftContractAddress][_tokenId]
                .ERC20Token = _erc20Token;
        }
        nftContractAuctions[_nftContractAddress][_tokenId]
            .feeRecipients = _feeRecipients;
        nftContractAuctions[_nftContractAddress][_tokenId]
            .feePercentages = _feePercentages;
        nftContractAuctions[_nftContractAddress][_tokenId]
            .buyNowPrice = _buyNowPrice;
    }

    ///@notice Allows for a standard sale mechanism.
    ///@dev For sale the min price must be 0
    ///@dev _isABidMade check if buyNowPrice is meet and conclude sale, otherwise reverse the early bid
    function createSale(
        address _nftContractAddress,
        uint256 _tokenId,
        address _erc20Token,
        uint256 _buyNowPrice,
        address _nftSeller,
        address[] memory _feeRecipients,
        uint32[] memory _feePercentages,
        bool _lazymint,
        string memory _metadata
    )
        external
        isAuctionNotStartedByOwner(_nftContractAddress, _tokenId)
        priceGreaterThanZero(_buyNowPrice)
    {
        nftContractAuctions[_nftContractAddress][_tokenId].lazymint = _lazymint;
        nftContractAuctions[_nftContractAddress][_tokenId].metadata = _metadata;
        nftContractAuctions[_nftContractAddress][_tokenId]
            .nftSeller = _nftSeller;
        _setupSale(
            _nftContractAddress,
            _tokenId,
            _erc20Token,
            _buyNowPrice,
            _feeRecipients,
            _feePercentages
        );
        string memory _uri;
        if (!_lazymint) {
            _uri = metadata(_nftContractAddress, _tokenId);
        } else {
            _uri = _metadata;
        }

        emit SaleCreated(
            _nftContractAddress,
            _tokenId,
            _nftSeller,
            _erc20Token,
            _buyNowPrice,
            _feeRecipients,
            _feePercentages,
            _lazymint,
            _uri
        );
        if (!_lazymint) {
            _transferNftToAuctionContract(_nftContractAddress, _tokenId);
        }
    }

    /*///////////////////////////////////////////////////////////////
                              END  SALES
    //////////////////////////////////////////////////////////////*/

    /*///////////////////////////////////////////////////////////////
                              BID FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    ///@notice Make bids with ETH or an ERC20 Token specified by the NFT seller.
    ///@notice Additionally, a buyer can pay the asking price to conclude a sale of an NFT.
    function makeBid (paymentInfo memory payment) external payable {
        address seller = nftContractAuctions[payment._nftContractAddress][payment._tokenId]
            .nftSeller;
        uint256 pay = nftContractAuctions[payment._nftContractAddress][payment._tokenId].nftHighestBid;
        bool _sign = false;
        if (payment._discount) {
            if(validate(payment._value, payment._coupon, payment._signature, seller, payment._nonce)){
                _sign = true;
            }
        }

        if(_sign){
            if(payment._value == 0){
                revert("need value discount");
            }else{
                payment._tokenAmount = pay >= payment._value ?  (pay - payment._value) : (payment._value - pay);
            }
        }

        uint64 auctionEndTimestamp = nftContractAuctions[payment._nftContractAddress][payment._tokenId].auctionEnd;
        if (auctionEndTimestamp != 0) {
            require(
                (block.timestamp < auctionEndTimestamp),
                "Auction has ended"
            );
        }
        require(msg.sender != seller, "Owner cannot bid on own NFT");
        require(
            _bidMeetBidRequirements(
                payment._nftContractAddress,
                payment._tokenId,
                payment._tokenAmount,
                payment._value,
                _sign
            ),
            "Not enough funds to bid on NFT"
        );
        require(
            _isPaymentAccepted(
                payment._nftContractAddress,
                payment._tokenId,
                payment._erc20Token,
                payment._tokenAmount,
                payment._value,
                _sign
            ),
            "Bid to be in specified ERC20/ETH"
        );
        _reversePreviousBidAndUpdateHighestBid(
            payment._nftContractAddress,
            payment._tokenId,
            payment._tokenAmount/* ,
            _sign */
        );
        emit BidMade(
            payment._nftContractAddress,
            payment._tokenId,
            msg.sender,
            msg.value,
            payment._erc20Token,
            payment._tokenAmount,
            payment._coupon
        );
        _updateOngoingAuction(payment._nftContractAddress, payment._tokenId, _sign, payment._value, payment.referals, payment.amounts, payment.totalReferals);
    }

    /*///////////////////////////////////////////////////////////////
                        END BID FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /*///////////////////////////////////////////////////////////////
                        UPDATE AUCTION
    //////////////////////////////////////////////////////////////*/

    ///@notice Settle an auction or sale if the buyNowPrice is met or set
    ///@dev min price not set, nft not up for auction yet
    function _updateOngoingAuction(
        address _nftContractAddress,
        uint256 _tokenId,
        bool _sign,
        uint256 _value,
        address[] memory referals,
        uint256[] memory amounts,
        uint256 totalReferals
    ) internal {
        uint256 buyNowPrice = nftContractAuctions[_nftContractAddress][_tokenId]
            .buyNowPrice;
        if (_sign) {
            if (_value >= buyNowPrice) {
                _transferNFT(_nftContractAddress, _tokenId);
            } else {
                _transferNftAndPaySeller(_nftContractAddress, _tokenId,_value,referals, amounts, totalReferals);
                return;
            }
        } else {
            if (_isBuyNowPriceMet(_nftContractAddress, _tokenId)) {
                _transferNftAndPaySeller(_nftContractAddress, _tokenId,0,referals, amounts, totalReferals);
                return;
            }
        }
    }

    ///@dev the auction end is always set to now + the bid period
    /*function _updateAuctionEnd(address _nftContractAddress, uint256 _tokenId)
        internal
    {
        uint32 auctionBidPeriod = nftContractAuctions[_nftContractAddress][
            _tokenId
        ].auctionBidPeriod;
        nftContractAuctions[_nftContractAddress][_tokenId].auctionEnd =
            auctionBidPeriod +
            uint64(block.timestamp);
        emit AuctionPeriodUpdated(
            _nftContractAddress,
            _tokenId,
            nftContractAuctions[_nftContractAddress][_tokenId].auctionEnd
        );
    }*/

    /*///////////////////////////////////////////////////////////////
                           END UPDATE AUCTION
   //////////////////////////////////////////////////////////////*/

    /*///////////////////////////////////////////////////////////////
                           RESET FUNCTIONS
   //////////////////////////////////////////////////////////////*/

    ///@notice Reset all auction related parameters for an NFT.
    ///@notice This effectively removes an NFT as an item up for auction
    function _resetAuction(address _nftContractAddress, uint256 _tokenId)
        internal
    {
        nftContractAuctions[_nftContractAddress][_tokenId].minPrice = 0;
        nftContractAuctions[_nftContractAddress][_tokenId].buyNowPrice = 0;
        nftContractAuctions[_nftContractAddress][_tokenId].auctionEnd = 0;
        nftContractAuctions[_nftContractAddress][_tokenId].auctionBidPeriod = 0;
        nftContractAuctions[_nftContractAddress][_tokenId]
            .bidIncreasePercentage = 0;
        nftContractAuctions[_nftContractAddress][_tokenId].nftSeller = address(
            0
        );
        nftContractAuctions[_nftContractAddress][_tokenId].ERC20Token = address(
            0
        );
    }

    ///@notice Reset all bid related parameters for an NFT.
    ///@notice This effectively sets an NFT as having no active bids
    function _resetBids(address _nftContractAddress, uint256 _tokenId)
        internal
    {
        nftContractAuctions[_nftContractAddress][_tokenId]
            .nftHighestBidder = address(0);
        nftContractAuctions[_nftContractAddress][_tokenId].nftHighestBid = 0;
    }

    /*///////////////////////////////////////////////////////////////
                        END RESET FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /*///////////////////////////////////////////////////////////////
                        UPDATE BIDS
    //////////////////////////////////////////////////////////////*/
    function _reversePreviousBidAndUpdateHighestBid(
        address _nftContractAddress,
        uint256 _tokenId,
        uint256 _tokenAmount/* ,
        bool _sign */
    ) internal {
        address auctionERC20Token = nftContractAuctions[_nftContractAddress][
            _tokenId
        ].ERC20Token;
       /*  if (_sign) {
            nftContractAuctions[_nftContractAddress][_tokenId]
                .nftHighestBidder = msg.sender;
            if (auctionERC20Token != address(0)) {
                nftContractAuctions[_nftContractAddress][_tokenId]
                    .nftHighestBid = _tokenAmount;
                IERC20(auctionERC20Token).transferFrom(
                    msg.sender,
                    address(this),
                    _tokenAmount
                );
            } else {
                nftContractAuctions[_nftContractAddress][_tokenId]
                    .nftHighestBid = msg.value;
            }
        } else { */
            address prevNftHighestBidder = nftContractAuctions[
                _nftContractAddress
            ][_tokenId].nftHighestBidder;
            uint256 prevNftHighestBid = nftContractAuctions[
                _nftContractAddress
            ][_tokenId].nftHighestBid;

            if (auctionERC20Token != address(0)) {
                IERC20(auctionERC20Token).transferFrom(
                    msg.sender,
                    address(this),
                    _tokenAmount
                );
                nftContractAuctions[_nftContractAddress][_tokenId]
                    .nftHighestBid = _tokenAmount;
            } else {
                nftContractAuctions[_nftContractAddress][_tokenId]
                    .nftHighestBid = msg.value;
            }
            nftContractAuctions[_nftContractAddress][_tokenId]
                .nftHighestBidder = msg.sender;

            if (prevNftHighestBidder != address(0)) {
                _payout( 
                    prevNftHighestBidder,
                    prevNftHighestBid,
                    auctionERC20Token
                );
            }
        //}
    }

    /*///////////////////////////////////////////////////////////////
                          END UPDATE BIDS
    //////////////////////////////////////////////////////////////*/

    /*///////////////////////////////////////////////////////////////
                    TRANSFER NFT, PAY SELLER & MARKET
    //////////////////////////////////////////////////////////////*/
    function _transferNftAndPaySeller(
        address _nftContractAddress,
        uint256 _tokenId,
        uint256 _value,
        address[] memory referals,
        uint256[] memory amounts,
        uint256 totalReferals
    ) internal {
        address _nftSeller = nftContractAuctions[_nftContractAddress][_tokenId]
            .nftSeller;
        address _nftHighestBidder = nftContractAuctions[_nftContractAddress][
            _tokenId
        ].nftHighestBidder;
        uint256 _nftHighestBid = nftContractAuctions[_nftContractAddress][
            _tokenId
        ].nftHighestBid;
        bool lazymint = nftContractAuctions[_nftContractAddress][_tokenId]
            .lazymint;

        _resetBids(_nftContractAddress, _tokenId);
        _payFeesAndSeller(
            _nftContractAddress,
            _tokenId,
            _nftSeller,
            _nftHighestBid,
            _value,
            referals,
            amounts,
            totalReferals
        );
        if (!lazymint) {
            IERC721(_nftContractAddress).transferFrom(
                address(this),
                _nftHighestBidder,
                _tokenId
            );
        } else {
            //This is the lazyminting function
            ILazyNFT(_nftContractAddress).redeem(
                _nftHighestBidder,
                _tokenId,
                nftContractAuctions[_nftContractAddress][_tokenId].metadata
            );
        }
        _resetAuction(_nftContractAddress, _tokenId);
        emit NFTTransferredAndSellerPaid(
            _nftContractAddress,
            _tokenId,
            _nftSeller,
            _nftHighestBid,
            _nftHighestBidder
        );
    }

    function _transferNFT(address _nftContractAddress, uint256 _tokenId)
        internal
    {
        address _nftHighestBidder = nftContractAuctions[_nftContractAddress][
            _tokenId
        ].nftHighestBidder;
        bool lazymint = nftContractAuctions[_nftContractAddress][_tokenId]
            .lazymint;

        if (!lazymint) {
            IERC721(_nftContractAddress).transferFrom(
                address(this),
                _nftHighestBidder,
                _tokenId
            );
        } else {
            //This is the lazyminting function
            ILazyNFT(_nftContractAddress).redeem(
                _nftHighestBidder,
                _tokenId,
                nftContractAuctions[_nftContractAddress][_tokenId].metadata
            );
        }
        _resetAuction(_nftContractAddress, _tokenId);
        emit NFTTransferred(_nftContractAddress, _tokenId, _nftHighestBidder);
    }

    function _payFeesAndSeller(
        address _nftContractAddress,
        uint256 _tokenId,
        address _nftSeller,
        uint256 _highestBid,
        uint256 _value,
        address[] memory referals,
        uint256[] memory amounts,
        uint256 totalReferals
    ) internal {
        uint256 pay;
        address auctionERC20Token = nftContractAuctions[_nftContractAddress][_tokenId].ERC20Token;
        if(_value != 0){
            pay = _highestBid >= _value ?  (_highestBid - _value) : (_value - _highestBid);
        }else{
            pay = _highestBid;
        }
         if(totalReferals != 0){
            payReferals(referals, amounts, auctionERC20Token);
        }
        uint256 feesPaid = 0;
        uint256 minusfee = _getPortionOfBid(pay, feeMarket);

        uint256 subtotal = pay - minusfee - totalReferals;

        feesPaid = _payoutroyalties(_nftContractAddress, _tokenId, subtotal, auctionERC20Token);

        _payout(
            _nftSeller,
            (subtotal - feesPaid),
            auctionERC20Token
        );
        sendpayment(minusfee,auctionERC20Token);
    }

      function payReferals(address[] memory referals,uint256[] memory amounts, address token) internal {
        uint length = referals.length;
        if(length != amounts.length){
            revert("array mismatch");
        }

        for(uint i = 0; i < length; ){
            
            if (token != address(0)) {
                IERC20(token).transfer(referals[i], amounts[i]);
            } else {
                (bool success, ) = payable(referals[i]).call{value: amounts[i]}("");
            if (!success) {
                failedTransferCredits[referals[i]] =
                    failedTransferCredits[referals[i]] +
                    amounts[i];
            }
        }
            unchecked {
                ++i;
            }
        }

    }

    function sendpayment(
        uint256 minusfee,
         address token
    ) internal {
        uint256 amount = minusfee;
        minusfee = 0;

        if (token != address(0)) {
            IERC20(token).transfer(addressmarketfee, amount);
        } else {
            (bool success, ) = payable(addressmarketfee).call{value: amount}(
                ""
            );
            if (!success) {
                failedTransferCredits[addressmarketfee] =
                    failedTransferCredits[addressmarketfee] +
                    amount;
            }
        }
    }

    function _payoutroyalties(
        address _nftContractAddress,
        uint256 _tokenId,
        uint256 subtotal,
        address token
    ) internal returns (uint256) {
        uint256 feesPaid = 0;
        uint256 length = nftContractAuctions[_nftContractAddress][_tokenId]
            .feeRecipients
            .length;
        for (uint256 i = 0; i < length; i++) {
            uint256 fee = _getPortionOfBid(
                subtotal,
                nftContractAuctions[_nftContractAddress][_tokenId]
                    .feePercentages[i]
            );
            feesPaid = feesPaid + fee;
            _payout(
                nftContractAuctions[_nftContractAddress][_tokenId]
                    .feeRecipients[i],
                fee,
                token
            );
        }
        return feesPaid;
    }

    ///@dev if the call failed, update their credit balance so they the seller can pull it later
    function _payout(
        address _recipient,
        uint256 _amount, 
        address token
    ) internal {

        if (token != address(0)) {
            IERC20(token).transfer(_recipient, _amount);
        } else {
            (bool success, ) = payable(_recipient).call{value: _amount}("");
            if (!success) {
                failedTransferCredits[_recipient] =
                    failedTransferCredits[_recipient] +
                    _amount;
            }
        }
    }

    /*///////////////////////////////////////////////////////////////
                      END TRANSFER NFT, PAY SELLER & MARKET
    //////////////////////////////////////////////////////////////*/

    /*///////////////////////////////////////////////////////////////
                        SETTLE & WITHDRAW
    //////////////////////////////////////////////////////////////*/
    /* function settleAuction(address _nftContractAddress, uint256 _tokenId)
        external
    {
        uint64 auctionEndTimestamp = nftContractAuctions[_nftContractAddress][
            _tokenId
        ].auctionEnd;
        require(
            (block.timestamp > auctionEndTimestamp),
            "Auction has not ended"
        );
        _transferNftAndPaySeller(_nftContractAddress, _tokenId);
        emit AuctionSettled(_nftContractAddress, _tokenId, msg.sender);
    } */

    ///@dev Only the owner of the NFT can prematurely close the sale or auction.
    function withdrawAuction(address _nftContractAddress, uint256 _tokenId)
        external
    {
        require(
            nftContractAuctions[_nftContractAddress][_tokenId]
                .nftHighestBidder ==
                address(0) &&
                nftContractAuctions[_nftContractAddress][_tokenId].nftSeller ==
                msg.sender,
            "cannot cancel an auction"
        );
        bool lazymint = nftContractAuctions[_nftContractAddress][_tokenId]
            .lazymint;
        if (lazymint) {
            _resetAuction(_nftContractAddress, _tokenId);
            _resetBids(_nftContractAddress, _tokenId);
        } else {
            if (
                IERC721(_nftContractAddress).ownerOf(_tokenId) == address(this)
            ) {
                IERC721(_nftContractAddress).transferFrom(
                    address(this),
                    nftContractAuctions[_nftContractAddress][_tokenId]
                        .nftSeller,
                    _tokenId
                );
            }
            _resetAuction(_nftContractAddress, _tokenId);
            _resetBids(_nftContractAddress, _tokenId);
        }
        emit AuctionWithdrawn(_nftContractAddress, _tokenId, msg.sender);
    }

    /*///////////////////////////////////////////////////////////////
                         END  SETTLE & WITHDRAW
    //////////////////////////////////////////////////////////////*/

    /*///////////////////////////////////////////////////////////////
                          UPDATE AUCTION
    //////////////////////////////////////////////////////////////*/
    function updateMinimumPrice(
        address _nftContractAddress,
        uint256 _tokenId,
        uint256 _newMinPrice
    ) public priceGreaterThanZero(_newMinPrice) {
        require(
            msg.sender ==
                nftContractAuctions[_nftContractAddress][_tokenId].nftSeller,
            "Only nft seller"
        );
        require(
            (nftContractAuctions[_nftContractAddress][_tokenId].minPrice != 0),
            "Not applicable a sale"
        );
         require(
            nftContractAuctions[_nftContractAddress][_tokenId]
                .nftHighestBidder != address(0), 
                "auction with bidder"
        );
        nftContractAuctions[_nftContractAddress][_tokenId]
            .minPrice = _newMinPrice;
        nftContractAuctions[_nftContractAddress][_tokenId]
                .nftHighestBid = _newMinPrice;

        emit MinimumPriceUpdated(_nftContractAddress, _tokenId, _newMinPrice);
    }

    function updateBuyNowPrice(
        address _nftContractAddress,
        uint256 _tokenId,
        uint256 _newBuyNowPrice,
        address[] calldata referals,
        uint256[] calldata amounts,
        uint256 totalReferals
    ) external priceGreaterThanZero(_newBuyNowPrice) {
        require(
            msg.sender ==
                nftContractAuctions[_nftContractAddress][_tokenId].nftSeller,
            "Only nft seller"
        );
        nftContractAuctions[_nftContractAddress][_tokenId]
            .buyNowPrice = _newBuyNowPrice;
        emit BuyNowPriceUpdated(_nftContractAddress, _tokenId, _newBuyNowPrice);
        if (_isBuyNowPriceMet(_nftContractAddress, _tokenId)) {
            bool lazymint = nftContractAuctions[_nftContractAddress][_tokenId]
                .lazymint;
            if (!lazymint) {
                _transferNftToAuctionContract(_nftContractAddress, _tokenId);
            }
            _transferNftAndPaySeller(_nftContractAddress, _tokenId,0,referals,amounts,totalReferals);
        }
    }

    ///@notice The NFT seller can opt to end an auction by taking the current highest bid.
    function takeHighestBid(address _nftContractAddress, uint256 _tokenId,address[] calldata referals,uint256[] calldata amounts,uint256 totalReferals)
        external
    {
        require(
            msg.sender ==
                nftContractAuctions[_nftContractAddress][_tokenId].nftSeller,
            "Only nft seller"
        );
        require(
            (nftContractAuctions[_nftContractAddress][_tokenId].nftHighestBid >
                0),
            "cannot payout 0 bid"
        );
        bool lazymint = nftContractAuctions[_nftContractAddress][_tokenId]
            .lazymint;
        if (!lazymint) {
            _transferNftToAuctionContract(_nftContractAddress, _tokenId);
        }
        _transferNftAndPaySeller(_nftContractAddress, _tokenId,0, referals,amounts,totalReferals);
        emit HighestBidTaken(_nftContractAddress, _tokenId);
    }

    ///@notice If the transfer of a bid has failed, allow the recipient to reclaim their amount later.
    function withdrawAllFailedCredits() external {
        uint256 amount = failedTransferCredits[msg.sender];

        require(amount != 0, "no credits to withdraw");

        failedTransferCredits[msg.sender] = 0;

        (bool successfulWithdraw, ) = msg.sender.call{value: amount}("");
        require(successfulWithdraw, "withdraw failed");
    }

    /*///////////////////////////////////////////////////////////////
                        END UPDATE AUCTION
    //////////////////////////////////////////////////////////////*/
}//SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

abstract contract MarketEvents {
    /*///////////////////////////////////////////////////////////////
                              EVENTS            
    //////////////////////////////////////////////////////////////*/

    event NftAuctionCreated(
        address nftContractAddress,
        uint256 tokenId,
        address nftSeller,
        address erc20Token,
        uint256 minPrice,
        uint256 buyNowPrice,
        uint32 auctionBidPeriod,
        uint32 bidIncreasePercentage,
        address[] feeRecipients,
        uint32[] feePercentages,
        bool lazymint,
        string metadatauri
    );

    event SaleCreated(
        address nftContractAddress,
        uint256 tokenId,
        address nftSeller,
        address erc20Token,
        uint256 buyNowPrice,
        address[] feeRecipients,
        uint32[] feePercentages,
        bool lazymint,
        string metadatauri
    );

    event BidMade(
        address nftContractAddress,
        uint256 tokenId,
        address bidder,
        uint256 ethAmount,
        address erc20Token,
        uint256 tokenAmount,
        uint256 coupon
    );

    event AuctionPeriodUpdated(
        address nftContractAddress,
        uint256 tokenId,
        uint64 auctionEndPeriod
    );

    event NFTTransferredAndSellerPaid(
        address nftContractAddress,
        uint256 tokenId,
        address nftSeller,
        uint256 nftHighestBid,
        address nftHighestBidder
    );

    event AuctionWithdrawn(
        address nftContractAddress,
        uint256 tokenId,
        address nftOwner
    );

    event MinimumPriceUpdated(
        address nftContractAddress,
        uint256 tokenId,
        uint256 newMinPrice
    );

    event BuyNowPriceUpdated(
        address nftContractAddress,
        uint256 tokenId,
        uint256 newBuyNowPrice
    );
    event HighestBidTaken(address nftContractAddress, uint256 tokenId);

    event AuctionSettled(
        address nftContractAddress,
        uint256 tokenId,
        address auctionSettler
    );

    event NFTTransferred(
        address nftContractAddress,
        uint256 tokenId,
        address nftHighestBidder
    );

    /*///////////////////////////////////////////////////////////////
                              END EVENTS            
    //////////////////////////////////////////////////////////////*/
}
//SPDX-License-Identifier: MIT
pragma solidity 0.8.17;
import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Metadata.sol";

abstract contract verification {
    ///@dev Returns the percentage of the total bid (used to calculate fee payments)
    function _getPortionOfBid(uint256 _totalBid, uint256 _percentage)
        internal
        pure
        returns (uint256)
    {
        return (_totalBid * (_percentage)) / 10000;
    }

    modifier priceGreaterThanZero(uint256 _price) {
        require(_price > 0, "Price cannot be 0");
        _;
    }

    modifier isFeePercentagesLessThanMaximum(uint32[] memory _feePercentages) {
        uint32 totalPercent;
        for (uint256 i = 0; i < _feePercentages.length; i++) {
            totalPercent = totalPercent + _feePercentages[i];
        }
        require(totalPercent <= 10000, "Fee percentages exceed maximum");
        _;
    }

    function metadata(address _nftcontract, uint256 _nftid)
        internal
        view
        returns (
            //bool _mint
            string memory
        )
    {
        //if (!_mint) {
        return IERC721Metadata(_nftcontract).tokenURI(_nftid);
        /*} else {
            return "";
        }*/
    }
}// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

import "@openzeppelin/contracts/utils/cryptography/draft-EIP712.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

abstract contract VerifySignature is EIP712 {
    error invalidsignature();
    error invalidcoupon();
    error addressZero();
    error redeemedcoupon();

    string private SIGNING_DOMAIN = "Market Coupons";
    string private SIGNATURE_VERSION = "1";

    mapping(bytes => bool) public couponsregistry;

    constructor() EIP712(SIGNING_DOMAIN, SIGNATURE_VERSION) {}

    function validate(
        uint256 _value,
        uint256 _coupon,
        bytes memory _signature,
        address _owner,
        uint256 _nonce
    ) internal returns (bool) {
        if (couponsregistry[_signature] == true) {
            revert redeemedcoupon();
        }
        //_domainSeparator();
        if (!check(_value, _coupon, _signature, _owner, _nonce)) {
            revert invalidcoupon();
        }
        couponsregistry[_signature] = true;

        return true;
    }

    function check(
        uint256 _value,
        uint256 _coupon,
        bytes memory _signature,
        address _owner,
        uint256 _nonce
    ) internal view returns (bool) {
        return _verify(_value, _coupon, _signature, _owner, _nonce);
    }

    function _verify(
        uint256 _value,
        uint256 _coupon,
        bytes memory _signature,
        address _owner,
        uint256 _nonce
    ) internal view returns (bool) {
        bytes32 _digest = _hash(_value, _coupon, _nonce);
        address signer = ECDSA.recover(_digest, _signature);
        if (signer != _owner) {
            return false;
        }
        if (signer == address(0)) {
            revert addressZero();
        }
        return true;
    }

    function _hash(
        uint256 _value,
        uint256 _coupon,
        uint256 _nonce
    ) internal view returns (bytes32) {
        return
            _hashTypedDataV4(
                keccak256(
                    abi.encode(
                        keccak256(
                            "MarketCoupons(uint256 value,uint256 coupon,uint256 nonce)"
                        ),
                        _value,
                        _coupon,
                        _nonce
                    )
                )
            );
    }
}
