// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC721/IERC721.sol)

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
     * WARNING: Usage of this method is discouraged, use {safeTransferFrom} whenever possible.
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
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC721/IERC721.sol)

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
     * WARNING: Usage of this method is discouraged, use {safeTransferFrom} whenever possible.
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
// OpenZeppelin Contracts (last updated v4.7.0) (utils/cryptography/ECDSA.sol)

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
        InvalidSignatureV
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
        } else if (error == RecoverError.InvalidSignatureV) {
            revert("ECDSA: invalid signature 'v' value");
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
        // Check the signature length
        // - case 65: r,s,v signature (standard)
        // - case 64: r,vs signature (cf https://eips.ethereum.org/EIPS/eip-2098) _Available since v4.1._
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
        } else if (signature.length == 64) {
            bytes32 r;
            bytes32 vs;
            // ecrecover takes the signature parameters, and the only way to get them
            // currently is to use assembly.
            /// @solidity memory-safe-assembly
            assembly {
                r := mload(add(signature, 0x20))
                vs := mload(add(signature, 0x40))
            }
            return tryRecover(hash, r, vs);
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
        if (v != 27 && v != 28) {
            return (address(0), RecoverError.InvalidSignatureV);
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
// OpenZeppelin Contracts (last updated v4.7.0) (utils/Strings.sol)

pragma solidity ^0.8.0;

/**
 * @dev String operations.
 */
library Strings {
    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";
    uint8 private constant _ADDRESS_LENGTH = 20;

    /**
     * @dev Converts a `uint256` to its ASCII `string` decimal representation.
     */
    function toString(uint256 value) internal pure returns (string memory) {
        // Inspired by OraclizeAPI's implementation - MIT licence
        // https://github.com/oraclize/ethereum-api/blob/b42146b063c7d6ee1358846c198246239e9360e8/oraclizeAPI_0.4.25.sol

        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation.
     */
    function toHexString(uint256 value) internal pure returns (string memory) {
        if (value == 0) {
            return "0x00";
        }
        uint256 temp = value;
        uint256 length = 0;
        while (temp != 0) {
            length++;
            temp >>= 8;
        }
        return toHexString(value, length);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation with fixed length.
     */
    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _HEX_SYMBOLS[value & 0xf];
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
// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.6;

import "../libraries/BotanStruct.sol";

interface IGeneScience {
    function unbox(
        BotanStruct.Botan memory seed,
        BotanStruct.Botan calldata dad,
        BotanStruct.Botan calldata mom
    ) external view returns (BotanStruct.Botan memory);

    function grow(
        BotanStruct.Botan memory seed,
        BotanStruct.Botan calldata dad,
        BotanStruct.Botan calldata mom
    ) external view returns (BotanStruct.Botan memory);
}
// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.6;

library BotanStruct {
    struct Botan {
        uint32 category;
        BotanRarity rarity; // 1-4
        uint8 breedTimes; // 0-n
        BotanPhase phase; // 1-4
        uint32 dadId;
        uint32 momId;
        uint64 time;
        uint64 blocks;
    }

    enum BotanPhase {
        None,
        Seed,
        Plant
    }

    enum BotanRarity {
        None,
        C,
        R,
        SR,
        SSR
    }
}
// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.6;

library LandStruct {
    struct Land {
        LandRarity rarity; //1-4
        uint32 category;
        uint64 time;
    }

    enum LandRarity {
        None,
        C,
        R,
        SR,
        SSR
    }
}
// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.6;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "../libraries/BotanStruct.sol";
import "../libraries/LandStruct.sol";
import "../nft/IBotanNFT.sol";
import "../nft/ILandNFT.sol";
import "../role/IRole.sol";
import "../role/IBlackList.sol";
import "../gene/IGeneScience.sol";

contract GameLogicV2 {
    event SetContractEvent(uint256 _type, address _contract);
    event SetContractOwnerEvent(address _owner);
    event SetUnboxSecondsEvent(uint64 _val);
    event SetGrowSecondsEvent(uint64 _val);
    event SetSecondsPerBlockEvent(uint64 _val);
    event SetMaxBreedTimesEvent(uint8 _cVal, uint8 _rVal, uint8 _srVal, uint8 _ssrVal);
    event BurnBotanEvent(uint256 _val);
    event BurnLandEvent(uint256 _val);
    event AdminWithdrawEvent(
        address indexed _tokenAddr,
        uint256 indexed _orderId,
        address _from,
        address indexed _to,
        uint256 _amountOrTokenId
    );
    event UserWithdrawEvent(
        address indexed _tokenAddr,
        uint256 indexed _orderId,
        address _from,
        address indexed _to,
        uint256 _amountOrTokenId
    );
    event SetWithdrawAddressEvent(address _address);
    event OrderPaymentEvent(
        address indexed _tokenAddr,
        uint256 indexed _orderId,
        address indexed _userAddress,
        uint256 _amount
    );
    event SetSignerEvent(address _signer);
    event SetVersionEvent(string _version);

    event FusionPayEvent(uint256 _orderId);
    event FusionRevertEvent(uint256 _orderId);

    struct PayInfo {
        address from;
        address to;
        address tokenAddress;
        uint256 amount;
    }

    IBotanNFT internal botanNFT;
    ILandNFT internal landNFT;
    IRole internal roleContract;
    IBlackList internal blackListContract;
    IGeneScience internal geneScienceContract;

    uint64 internal secondsPerBlock;
    // grow time
    uint64 internal growSeconds;
    uint64 internal growBlocks;

    uint8[5] internal maxBreedTimes;

    address internal signer;
    address internal owner;
    mapping(bytes => bool) internal signMap;

    address internal withdrawAddr;

    string internal version = "pc_gl_v2";

    constructor() {
        owner = msg.sender;
        secondsPerBlock = 3;
        growSeconds = 600 seconds;
        growBlocks = growSeconds / secondsPerBlock;
        maxBreedTimes = [0, 7, 6, 5, 3];
        withdrawAddr = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    function changeOwner(address _newOwner) external onlyOwner {
        owner = _newOwner;
        emit SetContractOwnerEvent(_newOwner);
    }

    modifier onlyCFO() {
        require(address(roleContract) != address(0), "Role contract isn't set");
        require(roleContract.isCFO(msg.sender), "Only CFO can call this function");
        _;
    }

    function setSigner(address _signer) external {
        require(
            owner == msg.sender || (address(roleContract) != address(0) && roleContract.isCEO(msg.sender)),
            "Permission denied"
        );
        signer = _signer;
        emit SetSignerEvent(_signer);
    }

    function setVersion(string calldata _version) external {
        require(
            owner == msg.sender || (address(roleContract) != address(0) && roleContract.isCEO(msg.sender)),
            "Permission denied"
        );
        version = _version;
        emit SetVersionEvent(_version);
    }

    function setBotanNFTContract(address _address) external {
        require(
            owner == msg.sender || (address(roleContract) != address(0) && roleContract.isCEO(msg.sender)),
            "Permission denied"
        );
        botanNFT = IBotanNFT(_address);
        emit SetContractEvent(0, _address);
    }

    function setLandNFTContract(address _address) external {
        require(
            owner == msg.sender || (address(roleContract) != address(0) && roleContract.isCEO(msg.sender)),
            "Permission denied"
        );
        landNFT = ILandNFT(_address);
        emit SetContractEvent(1, _address);
    }

    function setRoleContract(address _address) external {
        require(
            owner == msg.sender || (address(roleContract) != address(0) && roleContract.isCEO(msg.sender)),
            "Permission denied"
        );
        roleContract = IRole(_address);
        emit SetContractEvent(2, _address);
    }

    function setBlackListContract(address _address) external {
        require(
            owner == msg.sender || (address(roleContract) != address(0) && roleContract.isCEO(msg.sender)),
            "Permission denied"
        );
        blackListContract = IBlackList(_address);
        emit SetContractEvent(3, _address);
    }

    function setGeneScienceContract(address _address) external {
        require(
            owner == msg.sender || (address(roleContract) != address(0) && roleContract.isCEO(msg.sender)),
            "Permission denied"
        );
        geneScienceContract = IGeneScience(_address);
        emit SetContractEvent(4, _address);
    }

    function setWithdrawAddr(address _address) external {
        require(
            owner == msg.sender || (address(roleContract) != address(0) && roleContract.isCEO(msg.sender)),
            "Permission denied"
        );
        withdrawAddr = _address;
        emit SetWithdrawAddressEvent(_address);
    }

    function setGrowSeconds(uint64 _val) external {
        require(address(roleContract) != address(0), "Role contract isn't set");
        require(roleContract.isCEO(msg.sender), "Permission denied");
        growSeconds = _val;
        growBlocks = growSeconds / secondsPerBlock;
        emit SetGrowSecondsEvent(_val);
    }

    function setSecondsPerBlock(uint64 _val) external {
        require(address(roleContract) != address(0), "Role contract isn't set");
        require(roleContract.isCEO(msg.sender), "Permission denied");
        secondsPerBlock = _val;
        growBlocks = growSeconds / secondsPerBlock;
        emit SetSecondsPerBlockEvent(_val);
    }

    function setMaxBreedTimes(uint8[5] calldata _val) external {
        require(address(roleContract) != address(0), "Role contract isn't set");
        require(roleContract.isCEO(msg.sender), "Permission denied");
        maxBreedTimes = _val;
        emit SetMaxBreedTimesEvent(_val[1], _val[2], _val[3], _val[4]);
    }

    function doGrow(
        uint256 _tokenId,
        BotanStruct.Botan memory _newPlantData,
        uint256 _tx
    ) internal returns (BotanStruct.Botan memory) {
        require(address(botanNFT) != address(0), "BotanNFT contract isn't set");
        require(botanNFT.exists(_tokenId), "Token is not minted");
        BotanStruct.Botan memory _seed = botanNFT.getPlantDataByLogic(_tokenId);
        require(_seed.phase == BotanStruct.BotanPhase.Seed, "This is not a seed");
        require((_seed.time + growSeconds) < block.timestamp, "Time is not reached");
        _seed.rarity = _newPlantData.rarity;
        _seed.category = _newPlantData.category;
        botanNFT.growByLogic(_tokenId, _seed, _tx);
        return _newPlantData;
    }

    function grow(uint256 _tokenId, uint256 _tx) external returns (BotanStruct.Botan memory) {
        require(address(roleContract) != address(0), "Role contract isn't set");
        require(address(geneScienceContract) != address(0), "GeneScience Contract contract isn't set");
        require(roleContract.isCXO(msg.sender), "Permission denied");
        BotanStruct.Botan memory seed = botanNFT.getPlantDataByLogic(_tokenId);
        BotanStruct.Botan memory dad = botanNFT.getPlantDataByLogic(seed.dadId);
        BotanStruct.Botan memory mom = botanNFT.getPlantDataByLogic(seed.momId);
        BotanStruct.Botan memory _newPlantData = geneScienceContract.grow(seed, dad, mom);
        return doGrow(_tokenId, _newPlantData, _tx);
    }
    /*
    function growByPlantData(
        uint256 _tokenId,
        BotanStruct.Botan calldata _newPlantData,
        uint256 _tx
    ) external returns (BotanStruct.Botan memory) {
        require(address(roleContract) != address(0), "Role contract isn't set");
        require(roleContract.isCXO(msg.sender), "Permission denied");
        BotanStruct.Botan memory _seed = botanNFT.getPlantDataByLogic(_tokenId);
        _seed.rarity = _newPlantData.rarity;
        _seed.category = _newPlantData.category;
        return doGrow(_tokenId, _seed, _tx);
    }

    function growByPlantDataWithSign(
        uint256 _tokenId,
        BotanStruct.Botan calldata _newPlantData,
        uint256 _tx,
        bytes memory _sign
    ) external returns (BotanStruct.Botan memory) {
        require(signMap[_sign] != true, "This signature already be used!");
        bytes32 _msgHash = ECDSA.toEthSignedMessageHash(
            keccak256(
                abi.encodePacked(
                    "pc_gl_v1",
                    _tokenId,
                    _newPlantData.category,
                    _newPlantData.rarity,
                    _newPlantData.breedTimes,
                    _newPlantData.phase,
                    _newPlantData.dadId,
                    _newPlantData.momId,
                    _tx,
                    block.chainid
                )
            )
        );
        address signerAddress = ECDSA.recover(_msgHash, _sign);
        require(signerAddress != address(0) && signerAddress == signer, "Invalid Signer!");
        signMap[_sign] = true;
        return doGrow(_tokenId, _newPlantData, _tx);
    }
*/
    function breed(
        address _owner,
        uint256 _dadId,
        uint256 _momId,
        BotanStruct.BotanRarity _rarity,
        uint256 _tx,
        bool _safe
    ) external returns (uint256) {
        require(address(roleContract) != address(0), "Role contract isn't set");
        require(roleContract.isCXO(msg.sender), "Permission denied");
        return doBreed(_owner, _dadId, _momId, _rarity, _tx, _safe);
    }

    function breedWithSign(
        address _owner,
        uint256 _dadId,
        uint256 _momId,
        BotanStruct.BotanRarity _rarity,
        uint256 _tx,
        bool _safe,
        bytes memory _sign
    ) external returns (uint256) {
        require(signMap[_sign] != true, "This signature already be used!");
        bytes32 _msgHash = ECDSA.toEthSignedMessageHash(
            keccak256(abi.encodePacked("pc_gl_v1", _owner, _dadId, _momId, _rarity, _tx, _safe, block.chainid))
        );
        address signerAddress = ECDSA.recover(_msgHash, _sign);
        require(signerAddress != address(0) && signerAddress == signer, "Invalid Signer!");
        signMap[_sign] = true;
        return doBreed(_owner, _dadId, _momId, _rarity, _tx, _safe);
    }

    function doBreed(
        address _owner,
        uint256 _dadId,
        uint256 _momId,
        BotanStruct.BotanRarity _rarity,
        uint256 _tx,
        bool _safe
    ) internal returns (uint256) {
        require(address(botanNFT) != address(0), "BotanNFT contract isn't set");
        require(botanNFT.exists(_dadId), "Dad is not minted");
        require(botanNFT.exists(_momId), "Mom is not minted");
        BotanStruct.Botan memory dad = botanNFT.getPlantDataByLogic(_dadId);
        BotanStruct.Botan memory mom = botanNFT.getPlantDataByLogic(_momId);
        require(
            ((mom.momId == 0 || dad.dadId == 0) ||
                // Or their parents are not same.There are not brother
                ((mom.dadId != dad.dadId) &&
                    (mom.dadId != dad.momId) &&
                    (mom.momId != dad.momId) &&
                    (mom.momId != dad.dadId))) &&
                // Their parents can not be father and son
                ((_momId != dad.momId && _momId != dad.dadId) && (_dadId != mom.momId && _dadId != mom.dadId)),
            "Inbreeding is prohibited."
        );
        uint8 mombt = maxBreedTimes[uint8(mom.rarity)];
        uint8 dadbt = maxBreedTimes[uint8(dad.rarity)];
        require((mom.breedTimes < mombt) && (dad.breedTimes < dadbt), "Breeding limit exceeded.");
        return
            botanNFT.breedByLogic(_owner, _dadId, _momId, _rarity, uint64(block.number + growBlocks - 1), _tx, _safe);
    }

    function mintLand(
        address _owner,
        LandStruct.Land calldata _landData,
        uint256 _tx,
        bool _safe
    ) external returns (uint256) {
        require(address(roleContract) != address(0), "Role contract isn't set");
        require(roleContract.isCXO(msg.sender), "Permission denied");
        return landNFT.mintLandByLogic(_owner, _landData, _tx, _safe);
    }

    function mintLandWithSign(
        address _owner,
        LandStruct.Land calldata _landData,
        uint256 _tx,
        bool _safe,
        bytes memory _sign
    ) external returns (uint256) {
        require(signMap[_sign] != true, "This signature already be used!");
        bytes32 _msgHash = ECDSA.toEthSignedMessageHash(
            keccak256(
                abi.encodePacked(
                    "pc_gl_v1",
                    _owner,
                    _landData.category,
                    _landData.rarity,
                    _landData.time,
                    _tx,
                    _safe,
                    block.chainid
                )
            )
        );
        address signerAddress = ECDSA.recover(_msgHash, _sign);
        require(signerAddress != address(0) && signerAddress == signer, "Invalid Signer!");
        signMap[_sign] = true;
        return landNFT.mintLandByLogic(_owner, _landData, _tx, _safe);
    }

    function mintSeedOrPlant(
        address _owner,
        BotanStruct.Botan calldata _plantData,
        uint256 _tx,
        bool _safe
    ) external returns (uint256) {
        require(address(roleContract) != address(0), "Role contract isn't set");
        require(roleContract.isCXO(msg.sender), "Permission denied");
        return botanNFT.mintSeedOrPlantByLogic(_owner, _plantData, _tx, _safe);
    }

    function mintSeedOrPlantWithSign(
        address _owner,
        BotanStruct.Botan calldata _plantData,
        uint256 _tx,
        bool _safe,
        bytes memory _sign
    ) external returns (uint256) {
        require(signMap[_sign] != true, "This signature already be used!");
        bytes32 _msgHash = ECDSA.toEthSignedMessageHash(
            keccak256(
                abi.encodePacked(
                    "pc_gl_v1",
                    _owner,
                    _plantData.category,
                    _plantData.rarity,
                    _plantData.breedTimes,
                    _plantData.phase,
                    _plantData.dadId,
                    _plantData.momId,
                    _tx,
                    _safe,
                    block.chainid
                )
            )
        );
        address signerAddress = ECDSA.recover(_msgHash, _sign);
        require(signerAddress != address(0) && signerAddress == signer, "Invalid Signer!");
        signMap[_sign] = true;
        return botanNFT.mintSeedOrPlantByLogic(_owner, _plantData, _tx, _safe);
    }

    function growByPlantDataWithSignV2(
        uint256 _tokenId,
        BotanStruct.Botan calldata _newPlantData,
        uint256 _tx,
        PayInfo calldata _payInfo,
        bytes memory _sign
    ) external payable virtual returns (BotanStruct.Botan memory) {
        require(signMap[_sign] != true, "This signature already be used!");
        bytes memory _encodedPayInfo = abi.encodePacked(
            _payInfo.from,
            _payInfo.to,
            _payInfo.tokenAddress,
            _payInfo.amount
        );
        bytes32 _msgHash = ECDSA.toEthSignedMessageHash(
            keccak256(
                abi.encodePacked(
                    version,
                    _tokenId,
                    _newPlantData.category,
                    _newPlantData.rarity,
                    _newPlantData.breedTimes,
                    _newPlantData.phase,
                    _tx,
                    _encodedPayInfo,
                    block.chainid
                )
            )
        );
        address signerAddress = ECDSA.recover(_msgHash, _sign);
        require(signerAddress != address(0) && signerAddress == signer, "Invalid Signer!");
        signMap[_sign] = true;
        if (_payInfo.amount > 0) {
            payTokenV2(_payInfo.tokenAddress, _payInfo.to, _payInfo.amount, _tx);
        }
        return doGrow(_tokenId, _newPlantData, _tx);
    }

    function breedWithSignV2(
        address _owner,
        uint256 _dadId,
        uint256 _momId,
        BotanStruct.BotanRarity _rarity,
        uint256 _tx,
        bool _safe,
        PayInfo calldata _payInfo,
        bytes memory _sign
    ) external payable returns (uint256) {
        require(signMap[_sign] != true, "This signature already be used!");
        bytes memory _encodedPayInfo = abi.encodePacked(
            _payInfo.from,
            _payInfo.to,
            _payInfo.tokenAddress,
            _payInfo.amount
        );
        bytes32 _msgHash = ECDSA.toEthSignedMessageHash(
            keccak256(abi.encodePacked(version, _owner, _rarity, _tx, _safe, _encodedPayInfo, block.chainid))
        );
        address signerAddress = ECDSA.recover(_msgHash, _sign);
        require(signerAddress != address(0) && signerAddress == signer, "Invalid Signer!");
        signMap[_sign] = true;
        if (_payInfo.amount > 0) {
            payTokenV2(_payInfo.tokenAddress, _payInfo.to, _payInfo.amount, _tx);
        }
        return doBreed(_owner, _dadId, _momId, _rarity, _tx, _safe);
    }

    function mintLandWithSignV2(
        address _owner,
        LandStruct.Land calldata _landData,
        uint256 _tx,
        bool _safe,
        PayInfo calldata _payInfo,
        bytes memory _sign
    ) external payable returns (uint256) {
        require(signMap[_sign] != true, "This signature already be used!");
        bytes memory _encodedPayInfo = abi.encodePacked(
            _payInfo.from,
            _payInfo.to,
            _payInfo.tokenAddress,
            _payInfo.amount
        );
        bytes32 _msgHash = ECDSA.toEthSignedMessageHash(
            keccak256(
                abi.encodePacked(
                    version,
                    _owner,
                    _landData.category,
                    _landData.rarity,
                    _landData.time,
                    _tx,
                    _safe,
                    _encodedPayInfo,
                    block.chainid
                )
            )
        );
        address signerAddress = ECDSA.recover(_msgHash, _sign);
        require(signerAddress != address(0) && signerAddress == signer, "Invalid Signer!");
        signMap[_sign] = true;
        if (_payInfo.amount > 0) {
            payTokenV2(_payInfo.tokenAddress, _payInfo.to, _payInfo.amount, _tx);
        }
        return landNFT.mintLandByLogic(_owner, _landData, _tx, _safe);
    }

    function mintSeedOrPlantWithSignV2(
        address _owner,
        BotanStruct.Botan calldata _plantData,
        uint256 _tx,
        bool _safe,
        PayInfo calldata _payInfo,
        bytes memory _sign
    ) external payable returns (uint256) {
        require(signMap[_sign] != true, "This signature already be used!");
        bytes memory _encodedPayInfo = abi.encodePacked(
            _payInfo.from,
            _payInfo.to,
            _payInfo.tokenAddress,
            _payInfo.amount
        );
        bytes32 _msgHash = ECDSA.toEthSignedMessageHash(
            keccak256(
                abi.encodePacked(
                    version,
                    _owner,
                    _plantData.category,
                    _plantData.rarity,
                    _plantData.breedTimes,
                    _plantData.phase,
                    _tx,
                    _encodedPayInfo,
                    block.chainid
                )
            )
        );
        address signerAddress = ECDSA.recover(_msgHash, _sign);
        require(signerAddress != address(0) && signerAddress == signer, "Invalid Signer!");
        signMap[_sign] = true;
        if (_payInfo.amount > 0) {
            payTokenV2(_payInfo.tokenAddress, _payInfo.to, _payInfo.amount, _tx);
        }
        return botanNFT.mintSeedOrPlantByLogic(_owner, _plantData, _tx, _safe);
    }

    function fusionBurnOrTransfer(
        uint256[] calldata _fusionTokenIds,
        address _fusionTo
    ) internal {
        bool isBurn = _fusionTo == address(0);
        for (uint256 i = 0; i < _fusionTokenIds.length; i++) {
            uint256 _fusionTokenId = _fusionTokenIds[i];
            if (isBurn) {
                botanNFT.burnByLogic(_fusionTokenId);
            } else {
                botanNFT.transferFrom(msg.sender, _fusionTo, _fusionTokenId);
            }
        }
    }

    function fusionRevert(
        uint256[] calldata _revertTokenIds,
        address _revertFrom,
        address _revertTo
    ) internal {
        for (uint256 i = 0; i < _revertTokenIds.length; i++) {
            uint256 _fusionTokenId = _revertTokenIds[i];
            botanNFT.transferFrom(_revertFrom, _revertTo, _fusionTokenId);
        }
    }

    function fusionPlantPay(
        uint256[] calldata _fusionTokenIds,
        address _fusionTo,
        uint256 _tx,
        PayInfo calldata _payInfo,
        bytes memory _sign
    ) external payable {
        require(signMap[_sign] != true, "This signature already be used!");
        bytes memory _encodedPayInfo = abi.encodePacked(
            _payInfo.from,
            _payInfo.to,
            _payInfo.tokenAddress,
            _payInfo.amount
        );
        bytes32 _msgHash = ECDSA.toEthSignedMessageHash(
            keccak256(
                abi.encodePacked(
                    version,
                    _fusionTokenIds,
                    _fusionTo,
                    _tx,
                    _encodedPayInfo,
                    block.chainid
                )
            )
        );
        address signerAddress = ECDSA.recover(_msgHash, _sign);
        require(signerAddress != address(0) && signerAddress == signer, "Invalid Signer!");
        signMap[_sign] = true;
        if (_payInfo.amount > 0) {
            payTokenV2(_payInfo.tokenAddress, _payInfo.to, _payInfo.amount, _tx);
        }
        if (_fusionTokenIds.length > 0) {
            fusionBurnOrTransfer(_fusionTokenIds, _fusionTo);
        }
        emit FusionPayEvent(_tx);
    }

    function fusionPlantWithSignV2(
        address _owner,
        uint256[] calldata _fusionTokenIds,
        address _fusionTo,
        uint256[] calldata _revertTokenIds,
        address _revertFrom,
        address _revertTo,
        BotanStruct.Botan calldata _plantData,
        uint256 _tx,
        bool _safe,
        PayInfo calldata _payInfo,
        bytes memory _sign
    ) external payable returns (uint256) {
        require(signMap[_sign] != true, "This signature already be used!");
        bytes memory _encodedPayInfo = abi.encodePacked(
            _payInfo.from,
            _payInfo.to,
            _payInfo.tokenAddress,
            _payInfo.amount
        );
        bytes32 _msgHash = ECDSA.toEthSignedMessageHash(
            keccak256(
                abi.encodePacked(
                    version,
                    _owner,
                    _fusionTokenIds,
                    _fusionTo,
                    _revertTokenIds,
                    _revertFrom,
                    _revertTo,
                    _plantData.category,
                    _plantData.rarity,
                    _tx,
                    _encodedPayInfo,
                    block.chainid
                )
            )
        );
        address signerAddress = ECDSA.recover(_msgHash, _sign);
        require(signerAddress != address(0) && signerAddress == signer, "Invalid Signer!");
        signMap[_sign] = true;
        if (_payInfo.amount > 0) {
            payTokenV2(_payInfo.tokenAddress, _payInfo.to, _payInfo.amount, _tx);
        }
        if (_fusionTokenIds.length > 0) {
            fusionBurnOrTransfer(_fusionTokenIds, _fusionTo);
        }
        if (_revertTokenIds.length > 0) {
            fusionRevert(_revertTokenIds, _revertFrom, _revertTo);
            emit FusionRevertEvent(_tx);
        }
        if (_plantData.category > 0) {
            return botanNFT.mintSeedOrPlantByLogic(_owner, _plantData, _tx, _safe);
        }
        return 0;
    }

    function payTokenV2(address _tokenAddr, address _to, uint256 _amount, uint256 _orderId) public payable virtual {
        require(_amount > 0, "You need pay some token");
        require(address(blackListContract) != address(0), "BlackList contract isn't set");
        require(blackListContract.notInBlackList(msg.sender), "You are on the blacklist");
        if (_tokenAddr == address(0)) {
            payMainTokenV2(_amount, _orderId);
        } else {
            payErc20TokenV2(_tokenAddr, _to, _amount, _orderId);
        }
    }

    function payMainTokenV2(uint256 _amount, uint256 _orderId) public payable virtual {
        require(msg.value >= _amount, "You don't pay enough main token");
        emit OrderPaymentEvent(address(0), _orderId, msg.sender, _amount);
    }

    function payErc20TokenV2(address _tokenAddr, address _to, uint256 _amount, uint256 _orderId) internal virtual {
        IERC20 tokenContract = IERC20(_tokenAddr);
        uint256 allowance = tokenContract.allowance(msg.sender, address(this));
        require(allowance >= _amount, "Check the token allowance");
        tokenContract.transferFrom(msg.sender, _to, _amount);
        emit OrderPaymentEvent(_tokenAddr, _orderId, msg.sender, _amount);
    }

    function withdrawMainTokenV2ByAdmin(uint256 _orderId, uint256 _amount) public onlyCFO returns (bool) {
        require(_amount <= address(this).balance, "Not enough main token");
        // solhint-disable-next-line avoid-low-level-calls
        (bool ret /*bytes memory data*/, ) = withdrawAddr.call{ value: _amount }("");
        if (ret) {
            emit AdminWithdrawEvent(address(0), _orderId, address(this), withdrawAddr, _amount);
        } else {
            revert("Withdraw main token failed");
        }

        return ret;
    }

    function withdrawErc20TokenV2ByAdmin(
        address _tokenAddr,
        uint256 _orderId,
        uint256 _amount
    ) public onlyCFO returns (bool) {
        IERC20 tokenContract = IERC20(_tokenAddr);
        require(_amount <= tokenContract.balanceOf(address(this)), "Not enough ERC20 token");
        bool ret = tokenContract.transfer(withdrawAddr, _amount);
        if (ret) {
            emit AdminWithdrawEvent(_tokenAddr, _orderId, address(this), withdrawAddr, _amount);
        } else {
            revert("Withdraw ERC20 token failed");
        }

        return ret;
    }

    function withdrawErc20TokenV2ByUser(
        address _tokenAddr,
        address _from,
        address _to,
        uint256 _amount,
        uint256 _orderId,
        bytes memory _sign
    ) public returns (bool) {
        bytes32 _msgHash = ECDSA.toEthSignedMessageHash(
            keccak256(abi.encodePacked(version, _tokenAddr, _from, _to, _amount, _orderId, block.chainid))
        );
        address signerAddress = ECDSA.recover(_msgHash, _sign);
        require(signerAddress != address(0) && signerAddress == signer, "Invalid Signer!");
        signMap[_sign] = true;
        IERC20 tokenContract = IERC20(_tokenAddr);
        tokenContract.transferFrom(_from, _to, _amount);
        emit UserWithdrawEvent(_tokenAddr, _orderId, _from, _to, _amount);
        return true;
    }

    function withdrawErc721TokenV2ByUser(
        address _tokenAddr,
        address _from,
        address _to,
        uint256 _tokenId,
        uint256 _orderId,
        bytes memory _sign
    ) public returns (bool) {
        bytes32 _msgHash = ECDSA.toEthSignedMessageHash(
            keccak256(abi.encodePacked(version, _tokenAddr, _from, _to, _tokenId, _orderId, block.chainid))
        );
        address signerAddress = ECDSA.recover(_msgHash, _sign);
        require(signerAddress != address(0) && signerAddress == signer, "Invalid Signer!");
        signMap[_sign] = true;
        IERC721 tokenContract = IERC721(_tokenAddr);
        tokenContract.transferFrom(_from, _to, _tokenId);
        emit UserWithdrawEvent(_tokenAddr, _orderId, _from, _to, _tokenId);
        return true;
    }

    function burnBotan(uint256 _tokenId) external {
        require(address(botanNFT) != address(0), "BotanNFT contract isn't set");
        require(
            owner == msg.sender || (address(roleContract) != address(0) && roleContract.isCXO(msg.sender)),
            "Permission denied"
        );
        botanNFT.burnByLogic(_tokenId);
        emit BurnBotanEvent(_tokenId);
    }

    function burnLand(uint256 _tokenId) external {
        require(address(landNFT) != address(0), "LandNFT contract isn't set");
        require(
            owner == msg.sender || (address(roleContract) != address(0) && roleContract.isCXO(msg.sender)),
            "Permission denied"
        );
        landNFT.burnByLogic(_tokenId);
        emit BurnLandEvent(_tokenId);
    }
}
// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.6;

import "@openzeppelin/contracts-upgradeable/token/ERC721/IERC721Upgradeable.sol";
import "../libraries/BotanStruct.sol";

interface IBotanNFT is IERC721Upgradeable {
    function getPlantDataByUser(uint256 _tokenId) external view returns (BotanStruct.Botan memory);

    function getPlantDataByLogic(uint256 _tokenId) external view returns (BotanStruct.Botan memory);

    function mintSeedOrPlantByLogic(
        address _owner,
        BotanStruct.Botan calldata _plantData,
        uint256 _tx,
        bool _safe
    ) external returns (uint256);

    function breedByLogic(
        address _owner,
        uint256 _dadId,
        uint256 _momId,
        BotanStruct.BotanRarity _rarity,
        uint64 _blocks,
        uint256 _tx,
        bool _safe
    ) external returns (uint256);

    function growByLogic(
        uint256 _tokenId,
        BotanStruct.Botan calldata _newGeneData,
        uint256 _tx
    ) external returns (BotanStruct.Botan memory);

    function exists(uint256 tokenId) external view returns (bool);

    function burnByCXO(uint256 _tokenId) external;

    function burnByLogic(uint256 _tokenId) external;
}
// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.6;

import "@openzeppelin/contracts-upgradeable/token/ERC721/IERC721Upgradeable.sol";
import "../libraries/LandStruct.sol";

interface ILandNFT is IERC721Upgradeable {
    function getLandDataByLogic(uint256 _tokenId) external view returns (LandStruct.Land memory);

    function getLandDataByUser(uint256 _tokenId) external view returns (LandStruct.Land memory);

    function exists(uint256 tokenId) external view returns (bool);

    function mintLandByLogic(
        address _owner,
        LandStruct.Land calldata _landData,
        uint256 _tx,
        bool _safe
    ) external returns (uint256);

    function burnByCXO(uint256 _tokenId) external;

    function burnByLogic(uint256 _tokenId) external;
}
// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.6;

interface IBlackList {
    function addToBlackList(address _user) external;

    function removeFromBlackList(address _user) external;

    function inBlackList(address _user) external view returns (bool);

    function notInBlackList(address _user) external view returns (bool);
}
// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.6;

interface IRole {
    function isCEO(address addr) external view returns (bool);

    function isCOO(address addr) external view returns (bool);

    function isCFO(address addr) external view returns (bool);

    function isCXO(address addr) external view returns (bool);

    function isCTO(address addr) external view returns (bool);
}
