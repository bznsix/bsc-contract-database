// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

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
}

/**
 * @dev String operations.
 */
library Strings {
    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";

    function toString(uint256 value) internal pure returns (string memory) {
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
     * @dev Returns true if the two strings are equal.
     */
    function equal(string memory a, string memory b) internal pure returns (bool) {
        return keccak256(bytes(a)) == keccak256(bytes(b));
    }
}


/**
 * @dev Provides a set of functions to operate with Base64 strings.
 *
 * _Available since v4.5._
 */
library Base64 {
    /**
     * @dev Base64 Encoding/Decoding Table
     */
    string internal constant _TABLE = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";

    /**
     * @dev Converts a `bytes` to its Bytes64 `string` representation.
     */
    function encode(bytes memory data) internal pure returns (string memory) {
        /**
         * Inspired by Brecht Devos (Brechtpd) implementation - MIT licence
         * https://github.com/Brechtpd/base64/blob/e78d9fd951e7b0977ddca77d92dc85183770daf4/base64.sol
         */
        if (data.length == 0) return "";

        // Loads the table into memory
        string memory table = _TABLE;

        // Encoding takes 3 bytes chunks of binary data from `bytes` data parameter
        // and split into 4 numbers of 6 bits.
        // The final Base64 length should be `bytes` data length multiplied by 4/3 rounded up
        // - `data.length + 2`  -> Round up
        // - `/ 3`              -> Number of 3-bytes chunks
        // - `4 *`              -> 4 characters for each chunk
        string memory result = new string(4 * ((data.length + 2) / 3));

        /// @solidity memory-safe-assembly
        assembly {
            // Prepare the lookup table (skip the first "length" byte)
            let tablePtr := add(table, 1)

            // Prepare result pointer, jump over length
            let resultPtr := add(result, 32)

            // Run over the input, 3 bytes at a time
            for {
                let dataPtr := data
                let endPtr := add(data, mload(data))
            } lt(dataPtr, endPtr) {

            } {
                // Advance 3 bytes
                dataPtr := add(dataPtr, 3)
                let input := mload(dataPtr)

                // To write each character, shift the 3 bytes (18 bits) chunk
                // 4 times in blocks of 6 bits for each character (18, 12, 6, 0)
                // and apply logical AND with 0x3F which is the number of
                // the previous character in the ASCII table prior to the Base64 Table
                // The result is then added to the table to get the character to write,
                // and finally write it in the result pointer but with a left shift
                // of 256 (1 byte) - 8 (1 ASCII char) = 248 bits

                mstore8(resultPtr, mload(add(tablePtr, and(shr(18, input), 0x3F))))
                resultPtr := add(resultPtr, 1) // Advance

                mstore8(resultPtr, mload(add(tablePtr, and(shr(12, input), 0x3F))))
                resultPtr := add(resultPtr, 1) // Advance

                mstore8(resultPtr, mload(add(tablePtr, and(shr(6, input), 0x3F))))
                resultPtr := add(resultPtr, 1) // Advance

                mstore8(resultPtr, mload(add(tablePtr, and(input, 0x3F))))
                resultPtr := add(resultPtr, 1) // Advance
            }

            // When data `bytes` is not exactly 3 bytes long
            // it is padded with `=` characters at the end
            switch mod(mload(data), 3)
            case 1 {
                mstore8(sub(resultPtr, 1), 0x3d)
                mstore8(sub(resultPtr, 2), 0x3d)
            }
            case 2 {
                mstore8(sub(resultPtr, 1), 0x3d)
            }
        }
        return result;
    }
}

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

    function _contextSuffixLength() internal view virtual returns (uint256) {
        return 0;
    }
}


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
        /*
        string memory baseURI = _baseURI();
        return bytes(baseURI).length > 0 ? string(abi.encodePacked(baseURI, tokenId.toString())) : "";
        */
        string memory metadata = '{"name": "Node","description": "Node NFT","image": "data:image/jpeg;base64,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"}';
        return string(abi.encodePacked("data:application/json;base64,", Base64.encode(bytes(metadata))));
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
    function transferFrom(address from, address to, uint256 tokenId) public virtual override {
        //solhint-disable-next-line max-line-length
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: caller is not token owner or approved");

        _transfer(from, to, tokenId);
    }

    /**
     * @dev See {IERC721-safeTransferFrom}.
     */
    function safeTransferFrom(address from, address to, uint256 tokenId) public virtual override {
        safeTransferFrom(from, to, tokenId, "");
    }

    /**
     * @dev See {IERC721-safeTransferFrom}.
     */
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory data) public virtual override {
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
    function _safeTransfer(address from, address to, uint256 tokenId, bytes memory data) internal virtual {
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
    function _safeMint(address to, uint256 tokenId, bytes memory data) internal virtual {
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
    function _transfer(address from, address to, uint256 tokenId) internal virtual {
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
    function _setApprovalForAll(address owner, address operator, bool approved) internal virtual {
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
    function _beforeTokenTransfer(address from, address to, uint256 firstTokenId, uint256 batchSize) internal virtual {}

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
    function _afterTokenTransfer(address from, address to, uint256 firstTokenId, uint256 batchSize) internal virtual {}
}

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


/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
contract Ownable is Context {
    address internal _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), _owner);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Returns true if the caller is the current owner.
     */
    function isOwner() public view returns (bool) {
        return _msgSender() == _owner;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     */
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}


contract NodeNFT is ERC721Enumerable, Ownable {
    using Strings for uint256;

    uint256 public _tokenId = 1;
    uint256 public _totalSupply = 21000;
    mapping(address => bool) private _minters;

    modifier onlyMinter() {
        require(_minters[msg.sender], "Ownable: caller is not the minter");
        _;
    }

    function isMinter(address minter) external view returns(bool) {
        return _minters[minter];
    }

    function setMinter(address minter, bool enable) external onlyOwner {
        _minters[minter] = enable;
    }

    function mint(address to) external onlyMinter returns(uint256){
        uint256 i = _tokenId;
        require(i <= _totalSupply);
        _mint(to, i);
        ++_tokenId;
        return i;
    }

    function mint(address to, uint n) external onlyMinter{
        uint256 i = _tokenId;
        require(i + n + 1 <= _totalSupply);
        while(n > 0){
            _mint(to, i);
            unchecked{++i; --n;}
        }
        _tokenId = i;
    }

    constructor() ERC721("Node", "Node NFT"){
        _minters[msg.sender] = true;
    }
}