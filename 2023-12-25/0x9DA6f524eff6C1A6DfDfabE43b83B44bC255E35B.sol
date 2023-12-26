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
// OpenZeppelin Contracts (last updated v4.9.0) (token/ERC1155/ERC1155.sol)

pragma solidity ^0.8.0;

import "./IERC1155.sol";
import "./IERC1155Receiver.sol";
import "./extensions/IERC1155MetadataURI.sol";
import "../../utils/Address.sol";
import "../../utils/Context.sol";
import "../../utils/introspection/ERC165.sol";

/**
 * @dev Implementation of the basic standard multi-token.
 * See https://eips.ethereum.org/EIPS/eip-1155
 * Originally based on code by Enjin: https://github.com/enjin/erc-1155
 *
 * _Available since v3.1._
 */
contract ERC1155 is Context, ERC165, IERC1155, IERC1155MetadataURI {
    using Address for address;

    // Mapping from token ID to account balances
    mapping(uint256 => mapping(address => uint256)) private _balances;

    // Mapping from account to operator approvals
    mapping(address => mapping(address => bool)) private _operatorApprovals;

    // Used as the URI for all token types by relying on ID substitution, e.g. https://token-cdn-domain/{id}.json
    string private _uri;

    /**
     * @dev See {_setURI}.
     */
    constructor(string memory uri_) {
        _setURI(uri_);
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {
        return
            interfaceId == type(IERC1155).interfaceId ||
            interfaceId == type(IERC1155MetadataURI).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    /**
     * @dev See {IERC1155MetadataURI-uri}.
     *
     * This implementation returns the same URI for *all* token types. It relies
     * on the token type ID substitution mechanism
     * https://eips.ethereum.org/EIPS/eip-1155#metadata[defined in the EIP].
     *
     * Clients calling this function must replace the `\{id\}` substring with the
     * actual token type ID.
     */
    function uri(uint256) public view virtual override returns (string memory) {
        return _uri;
    }

    /**
     * @dev See {IERC1155-balanceOf}.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function balanceOf(address account, uint256 id) public view virtual override returns (uint256) {
        require(account != address(0), "ERC1155: address zero is not a valid owner");
        return _balances[id][account];
    }

    /**
     * @dev See {IERC1155-balanceOfBatch}.
     *
     * Requirements:
     *
     * - `accounts` and `ids` must have the same length.
     */
    function balanceOfBatch(
        address[] memory accounts,
        uint256[] memory ids
    ) public view virtual override returns (uint256[] memory) {
        require(accounts.length == ids.length, "ERC1155: accounts and ids length mismatch");

        uint256[] memory batchBalances = new uint256[](accounts.length);

        for (uint256 i = 0; i < accounts.length; ++i) {
            batchBalances[i] = balanceOf(accounts[i], ids[i]);
        }

        return batchBalances;
    }

    /**
     * @dev See {IERC1155-setApprovalForAll}.
     */
    function setApprovalForAll(address operator, bool approved) public virtual override {
        _setApprovalForAll(_msgSender(), operator, approved);
    }

    /**
     * @dev See {IERC1155-isApprovedForAll}.
     */
    function isApprovedForAll(address account, address operator) public view virtual override returns (bool) {
        return _operatorApprovals[account][operator];
    }

    /**
     * @dev See {IERC1155-safeTransferFrom}.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) public virtual override {
        require(
            from == _msgSender() || isApprovedForAll(from, _msgSender()),
            "ERC1155: caller is not token owner or approved"
        );
        _safeTransferFrom(from, to, id, amount, data);
    }

    /**
     * @dev See {IERC1155-safeBatchTransferFrom}.
     */
    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) public virtual override {
        require(
            from == _msgSender() || isApprovedForAll(from, _msgSender()),
            "ERC1155: caller is not token owner or approved"
        );
        _safeBatchTransferFrom(from, to, ids, amounts, data);
    }

    /**
     * @dev Transfers `amount` tokens of token type `id` from `from` to `to`.
     *
     * Emits a {TransferSingle} event.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - `from` must have a balance of tokens of type `id` of at least `amount`.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155Received} and return the
     * acceptance magic value.
     */
    function _safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) internal virtual {
        require(to != address(0), "ERC1155: transfer to the zero address");

        address operator = _msgSender();
        uint256[] memory ids = _asSingletonArray(id);
        uint256[] memory amounts = _asSingletonArray(amount);

        _beforeTokenTransfer(operator, from, to, ids, amounts, data);

        uint256 fromBalance = _balances[id][from];
        require(fromBalance >= amount, "ERC1155: insufficient balance for transfer");
        unchecked {
            _balances[id][from] = fromBalance - amount;
        }
        _balances[id][to] += amount;

        emit TransferSingle(operator, from, to, id, amount);

        _afterTokenTransfer(operator, from, to, ids, amounts, data);

        _doSafeTransferAcceptanceCheck(operator, from, to, id, amount, data);
    }

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {_safeTransferFrom}.
     *
     * Emits a {TransferBatch} event.
     *
     * Requirements:
     *
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155BatchReceived} and return the
     * acceptance magic value.
     */
    function _safeBatchTransferFrom(
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual {
        require(ids.length == amounts.length, "ERC1155: ids and amounts length mismatch");
        require(to != address(0), "ERC1155: transfer to the zero address");

        address operator = _msgSender();

        _beforeTokenTransfer(operator, from, to, ids, amounts, data);

        for (uint256 i = 0; i < ids.length; ++i) {
            uint256 id = ids[i];
            uint256 amount = amounts[i];

            uint256 fromBalance = _balances[id][from];
            require(fromBalance >= amount, "ERC1155: insufficient balance for transfer");
            unchecked {
                _balances[id][from] = fromBalance - amount;
            }
            _balances[id][to] += amount;
        }

        emit TransferBatch(operator, from, to, ids, amounts);

        _afterTokenTransfer(operator, from, to, ids, amounts, data);

        _doSafeBatchTransferAcceptanceCheck(operator, from, to, ids, amounts, data);
    }

    /**
     * @dev Sets a new URI for all token types, by relying on the token type ID
     * substitution mechanism
     * https://eips.ethereum.org/EIPS/eip-1155#metadata[defined in the EIP].
     *
     * By this mechanism, any occurrence of the `\{id\}` substring in either the
     * URI or any of the amounts in the JSON file at said URI will be replaced by
     * clients with the token type ID.
     *
     * For example, the `https://token-cdn-domain/\{id\}.json` URI would be
     * interpreted by clients as
     * `https://token-cdn-domain/000000000000000000000000000000000000000000000000000000000004cce0.json`
     * for token type ID 0x4cce0.
     *
     * See {uri}.
     *
     * Because these URIs cannot be meaningfully represented by the {URI} event,
     * this function emits no events.
     */
    function _setURI(string memory newuri) internal virtual {
        _uri = newuri;
    }

    /**
     * @dev Creates `amount` tokens of token type `id`, and assigns them to `to`.
     *
     * Emits a {TransferSingle} event.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155Received} and return the
     * acceptance magic value.
     */
    function _mint(address to, uint256 id, uint256 amount, bytes memory data) internal virtual {
        require(to != address(0), "ERC1155: mint to the zero address");

        address operator = _msgSender();
        uint256[] memory ids = _asSingletonArray(id);
        uint256[] memory amounts = _asSingletonArray(amount);

        _beforeTokenTransfer(operator, address(0), to, ids, amounts, data);

        _balances[id][to] += amount;
        emit TransferSingle(operator, address(0), to, id, amount);

        _afterTokenTransfer(operator, address(0), to, ids, amounts, data);

        _doSafeTransferAcceptanceCheck(operator, address(0), to, id, amount, data);
    }

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {_mint}.
     *
     * Emits a {TransferBatch} event.
     *
     * Requirements:
     *
     * - `ids` and `amounts` must have the same length.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155BatchReceived} and return the
     * acceptance magic value.
     */
    function _mintBatch(
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual {
        require(to != address(0), "ERC1155: mint to the zero address");
        require(ids.length == amounts.length, "ERC1155: ids and amounts length mismatch");

        address operator = _msgSender();

        _beforeTokenTransfer(operator, address(0), to, ids, amounts, data);

        for (uint256 i = 0; i < ids.length; i++) {
            _balances[ids[i]][to] += amounts[i];
        }

        emit TransferBatch(operator, address(0), to, ids, amounts);

        _afterTokenTransfer(operator, address(0), to, ids, amounts, data);

        _doSafeBatchTransferAcceptanceCheck(operator, address(0), to, ids, amounts, data);
    }

    /**
     * @dev Destroys `amount` tokens of token type `id` from `from`
     *
     * Emits a {TransferSingle} event.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `from` must have at least `amount` tokens of token type `id`.
     */
    function _burn(address from, uint256 id, uint256 amount) internal virtual {
        require(from != address(0), "ERC1155: burn from the zero address");

        address operator = _msgSender();
        uint256[] memory ids = _asSingletonArray(id);
        uint256[] memory amounts = _asSingletonArray(amount);

        _beforeTokenTransfer(operator, from, address(0), ids, amounts, "");

        uint256 fromBalance = _balances[id][from];
        require(fromBalance >= amount, "ERC1155: burn amount exceeds balance");
        unchecked {
            _balances[id][from] = fromBalance - amount;
        }

        emit TransferSingle(operator, from, address(0), id, amount);

        _afterTokenTransfer(operator, from, address(0), ids, amounts, "");
    }

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {_burn}.
     *
     * Emits a {TransferBatch} event.
     *
     * Requirements:
     *
     * - `ids` and `amounts` must have the same length.
     */
    function _burnBatch(address from, uint256[] memory ids, uint256[] memory amounts) internal virtual {
        require(from != address(0), "ERC1155: burn from the zero address");
        require(ids.length == amounts.length, "ERC1155: ids and amounts length mismatch");

        address operator = _msgSender();

        _beforeTokenTransfer(operator, from, address(0), ids, amounts, "");

        for (uint256 i = 0; i < ids.length; i++) {
            uint256 id = ids[i];
            uint256 amount = amounts[i];

            uint256 fromBalance = _balances[id][from];
            require(fromBalance >= amount, "ERC1155: burn amount exceeds balance");
            unchecked {
                _balances[id][from] = fromBalance - amount;
            }
        }

        emit TransferBatch(operator, from, address(0), ids, amounts);

        _afterTokenTransfer(operator, from, address(0), ids, amounts, "");
    }

    /**
     * @dev Approve `operator` to operate on all of `owner` tokens
     *
     * Emits an {ApprovalForAll} event.
     */
    function _setApprovalForAll(address owner, address operator, bool approved) internal virtual {
        require(owner != operator, "ERC1155: setting approval status for self");
        _operatorApprovals[owner][operator] = approved;
        emit ApprovalForAll(owner, operator, approved);
    }

    /**
     * @dev Hook that is called before any token transfer. This includes minting
     * and burning, as well as batched variants.
     *
     * The same hook is called on both single and batched variants. For single
     * transfers, the length of the `ids` and `amounts` arrays will be 1.
     *
     * Calling conditions (for each `id` and `amount` pair):
     *
     * - When `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * of token type `id` will be  transferred to `to`.
     * - When `from` is zero, `amount` tokens of token type `id` will be minted
     * for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens of token type `id`
     * will be burned.
     * - `from` and `to` are never both zero.
     * - `ids` and `amounts` have the same, non-zero length.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual {}

    /**
     * @dev Hook that is called after any token transfer. This includes minting
     * and burning, as well as batched variants.
     *
     * The same hook is called on both single and batched variants. For single
     * transfers, the length of the `id` and `amount` arrays will be 1.
     *
     * Calling conditions (for each `id` and `amount` pair):
     *
     * - When `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * of token type `id` will be  transferred to `to`.
     * - When `from` is zero, `amount` tokens of token type `id` will be minted
     * for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens of token type `id`
     * will be burned.
     * - `from` and `to` are never both zero.
     * - `ids` and `amounts` have the same, non-zero length.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual {}

    function _doSafeTransferAcceptanceCheck(
        address operator,
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) private {
        if (to.isContract()) {
            try IERC1155Receiver(to).onERC1155Received(operator, from, id, amount, data) returns (bytes4 response) {
                if (response != IERC1155Receiver.onERC1155Received.selector) {
                    revert("ERC1155: ERC1155Receiver rejected tokens");
                }
            } catch Error(string memory reason) {
                revert(reason);
            } catch {
                revert("ERC1155: transfer to non-ERC1155Receiver implementer");
            }
        }
    }

    function _doSafeBatchTransferAcceptanceCheck(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) private {
        if (to.isContract()) {
            try IERC1155Receiver(to).onERC1155BatchReceived(operator, from, ids, amounts, data) returns (
                bytes4 response
            ) {
                if (response != IERC1155Receiver.onERC1155BatchReceived.selector) {
                    revert("ERC1155: ERC1155Receiver rejected tokens");
                }
            } catch Error(string memory reason) {
                revert(reason);
            } catch {
                revert("ERC1155: transfer to non-ERC1155Receiver implementer");
            }
        }
    }

    function _asSingletonArray(uint256 element) private pure returns (uint256[] memory) {
        uint256[] memory array = new uint256[](1);
        array[0] = element;

        return array;
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC1155/extensions/IERC1155MetadataURI.sol)

pragma solidity ^0.8.0;

import "../IERC1155.sol";

/**
 * @dev Interface of the optional ERC1155MetadataExtension interface, as defined
 * in the https://eips.ethereum.org/EIPS/eip-1155#metadata-extensions[EIP].
 *
 * _Available since v3.1._
 */
interface IERC1155MetadataURI is IERC1155 {
    /**
     * @dev Returns the URI for token type `id`.
     *
     * If the `\{id\}` substring is present in the URI, it must be replaced by
     * clients with the actual token type ID.
     */
    function uri(uint256 id) external view returns (string memory);
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (token/ERC1155/IERC1155.sol)

pragma solidity ^0.8.0;

import "../../utils/introspection/IERC165.sol";

/**
 * @dev Required interface of an ERC1155 compliant contract, as defined in the
 * https://eips.ethereum.org/EIPS/eip-1155[EIP].
 *
 * _Available since v3.1._
 */
interface IERC1155 is IERC165 {
    /**
     * @dev Emitted when `value` tokens of token type `id` are transferred from `from` to `to` by `operator`.
     */
    event TransferSingle(address indexed operator, address indexed from, address indexed to, uint256 id, uint256 value);

    /**
     * @dev Equivalent to multiple {TransferSingle} events, where `operator`, `from` and `to` are the same for all
     * transfers.
     */
    event TransferBatch(
        address indexed operator,
        address indexed from,
        address indexed to,
        uint256[] ids,
        uint256[] values
    );

    /**
     * @dev Emitted when `account` grants or revokes permission to `operator` to transfer their tokens, according to
     * `approved`.
     */
    event ApprovalForAll(address indexed account, address indexed operator, bool approved);

    /**
     * @dev Emitted when the URI for token type `id` changes to `value`, if it is a non-programmatic URI.
     *
     * If an {URI} event was emitted for `id`, the standard
     * https://eips.ethereum.org/EIPS/eip-1155#metadata-extensions[guarantees] that `value` will equal the value
     * returned by {IERC1155MetadataURI-uri}.
     */
    event URI(string value, uint256 indexed id);

    /**
     * @dev Returns the amount of tokens of token type `id` owned by `account`.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function balanceOf(address account, uint256 id) external view returns (uint256);

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {balanceOf}.
     *
     * Requirements:
     *
     * - `accounts` and `ids` must have the same length.
     */
    function balanceOfBatch(
        address[] calldata accounts,
        uint256[] calldata ids
    ) external view returns (uint256[] memory);

    /**
     * @dev Grants or revokes permission to `operator` to transfer the caller's tokens, according to `approved`,
     *
     * Emits an {ApprovalForAll} event.
     *
     * Requirements:
     *
     * - `operator` cannot be the caller.
     */
    function setApprovalForAll(address operator, bool approved) external;

    /**
     * @dev Returns true if `operator` is approved to transfer ``account``'s tokens.
     *
     * See {setApprovalForAll}.
     */
    function isApprovedForAll(address account, address operator) external view returns (bool);

    /**
     * @dev Transfers `amount` tokens of token type `id` from `from` to `to`.
     *
     * Emits a {TransferSingle} event.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - If the caller is not `from`, it must have been approved to spend ``from``'s tokens via {setApprovalForAll}.
     * - `from` must have a balance of tokens of type `id` of at least `amount`.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155Received} and return the
     * acceptance magic value.
     */
    function safeTransferFrom(address from, address to, uint256 id, uint256 amount, bytes calldata data) external;

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {safeTransferFrom}.
     *
     * Emits a {TransferBatch} event.
     *
     * Requirements:
     *
     * - `ids` and `amounts` must have the same length.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155BatchReceived} and return the
     * acceptance magic value.
     */
    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] calldata ids,
        uint256[] calldata amounts,
        bytes calldata data
    ) external;
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC1155/IERC1155Receiver.sol)

pragma solidity ^0.8.0;

import "../../utils/introspection/IERC165.sol";

/**
 * @dev _Available since v3.1._
 */
interface IERC1155Receiver is IERC165 {
    /**
     * @dev Handles the receipt of a single ERC1155 token type. This function is
     * called at the end of a `safeTransferFrom` after the balance has been updated.
     *
     * NOTE: To accept the transfer, this must return
     * `bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"))`
     * (i.e. 0xf23a6e61, or its own function selector).
     *
     * @param operator The address which initiated the transfer (i.e. msg.sender)
     * @param from The address which previously owned the token
     * @param id The ID of the token being transferred
     * @param value The amount of tokens being transferred
     * @param data Additional data with no specified format
     * @return `bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"))` if transfer is allowed
     */
    function onERC1155Received(
        address operator,
        address from,
        uint256 id,
        uint256 value,
        bytes calldata data
    ) external returns (bytes4);

    /**
     * @dev Handles the receipt of a multiple ERC1155 token types. This function
     * is called at the end of a `safeBatchTransferFrom` after the balances have
     * been updated.
     *
     * NOTE: To accept the transfer(s), this must return
     * `bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"))`
     * (i.e. 0xbc197c81, or its own function selector).
     *
     * @param operator The address which initiated the batch transfer (i.e. msg.sender)
     * @param from The address which previously owned the token
     * @param ids An array containing ids of each token being transferred (order and length must match values array)
     * @param values An array containing amounts of each token being transferred (order and length must match ids array)
     * @param data Additional data with no specified format
     * @return `bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"))` if transfer is allowed
     */
    function onERC1155BatchReceived(
        address operator,
        address from,
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata data
    ) external returns (bytes4);
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC1155/utils/ERC1155Holder.sol)

pragma solidity ^0.8.0;

import "./ERC1155Receiver.sol";

/**
 * Simple implementation of `ERC1155Receiver` that will allow a contract to hold ERC1155 tokens.
 *
 * IMPORTANT: When inheriting this contract, you must include a way to use the received tokens, otherwise they will be
 * stuck.
 *
 * @dev _Available since v3.1._
 */
contract ERC1155Holder is ERC1155Receiver {
    function onERC1155Received(
        address,
        address,
        uint256,
        uint256,
        bytes memory
    ) public virtual override returns (bytes4) {
        return this.onERC1155Received.selector;
    }

    function onERC1155BatchReceived(
        address,
        address,
        uint256[] memory,
        uint256[] memory,
        bytes memory
    ) public virtual override returns (bytes4) {
        return this.onERC1155BatchReceived.selector;
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC1155/utils/ERC1155Receiver.sol)

pragma solidity ^0.8.0;

import "../IERC1155Receiver.sol";
import "../../../utils/introspection/ERC165.sol";

/**
 * @dev _Available since v3.1._
 */
abstract contract ERC1155Receiver is ERC165, IERC1155Receiver {
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {
        return interfaceId == type(IERC1155Receiver).interfaceId || super.supportsInterface(interfaceId);
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
// OpenZeppelin Contracts v4.4.1 (utils/introspection/ERC165.sol)

pragma solidity ^0.8.0;

import "./IERC165.sol";

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
// Csdoge Marketplace SFT Mint contract

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC1155/utils/ERC1155Receiver.sol";
import "@openzeppelin/contracts/token/ERC1155/utils/ERC1155Holder.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract LoopartCsDoge is ERC1155, ERC1155Holder, Ownable {
    using SafeERC20 for IERC20;

    struct NFTCategory {
        uint256 id;
        string name;
        bool isVisible;
    }

    struct StakingPool {
        uint256 poolId;
        uint256 nftStaked;
        uint256 nftRemaining;
        uint256 unclaimedUserCount;
        uint256 startTime;
        uint256 endTime;
        uint256 tokenAllocated;
        uint256 tokenRemaining;
        uint256 categoryId;
        address rewardTokenAddress;
        bool isActive;
    }

    struct NFTInfo {
        uint256 tokenId;
        uint256 amount;
        uint256 boughtAmount;
        uint256 price;
        uint256 categoryId;
        address paymentTokenAddress;
        bool isNativePayment;
        string name;
        string description;
        string tokenUri;
        string imgUri;
        string creatorName;
    }

    struct UserStakedNFT {
        uint256 id;
        NFTInfo nftInfo;
        uint256 stakedAmount;
        uint256 stakedAt;
        bool isUnstaked;
    }

    struct PoolStakerInfo {
        address user;
        uint256 stakedAmount;
        bool hasClaimed;
    }

    NFTCategory[] public nftCategories;
    NFTInfo[] public nftInfos;
    StakingPool[] public stakingPools;

    uint256 private _currentTokenId = 0;
    uint256 private _currentCategoryId = 0;
    uint256 private _currentPoolId = 0;
    uint256 public devFee = 200; // 2%
    uint256 public penaltyFee = 1500; // 15%
    address devWallet;

    mapping(string => uint256) private _idmap;
    mapping(uint256 => string) private _uris;
    mapping(string => bool) private _categorymap;
    mapping(uint256 => uint256) private _tokenIdToIndex;
    mapping(uint256 => uint256) private _categoryIdToIndex;
    mapping(uint256 => uint256) private _poolIdToIndex;
    mapping(address => mapping(uint256 => UserStakedNFT[]))
        private _userStakedNFTs; // useraddress => (poolId => NFTs)
    mapping(address => mapping(uint256 => bool)) public userClaimedRewards; // useraddress => (poolId => claimedStatus)
    mapping(uint256 => address[]) public poolStakers; // poolId => stakers
    mapping(uint256 => mapping(address => uint256)) public userStakedAmount; // poolId => (useraddress => stakedAmount)

    constructor() ERC1155("") {}

    /**
     * @notice Override ERC1155 base uri function to use IPFS CIDs instead of token ids
     * @param id ID of token to get URI for
     * @return Correctly formatted IPFS URI for token
     */
    function uri(
        uint256 id
    ) public view virtual override returns (string memory) {
        return _uris[id];
    }

    //////////////////////////////////////////
    /// Admin role
    //////////////////////////////////////////
    /**
     * @notice Create a new category
     * @param name the name of the category
     */
    function createCategory(string memory name) external onlyOwner {
        require(!_categorymap[name], "This category already exists");

        _currentCategoryId += 1;
        nftCategories.push(NFTCategory(_currentCategoryId, name, true));

        _categorymap[name] = true;
        _categoryIdToIndex[_currentCategoryId] = _currentCategoryId - 1;
    }

    /**
     * @notice Set visibility of the category
     * @param categoryId id of the category
     * @param visibility visibility of the category
     */
    function setCategoryVisibility(
        uint256 categoryId,
        bool visibility
    ) external onlyOwner {
        uint256 categoryIndex = _categoryIdToIndex[categoryId];
        NFTCategory storage nftCategory = nftCategories[categoryIndex];
        nftCategory.isVisible = visibility;
    }

    /**
     * @notice Create a new staking pool
     * @param lockingPeriod locking period of the pool
     */
    function createStakingPool(
        uint256 categoryId,
        uint256 lockingPeriod,
        address rewardTokenAddress
    ) external onlyOwner {
        _currentPoolId += 1;
        uint256 current_blocktime = block.timestamp;

        stakingPools.push(
            StakingPool({
                poolId: _currentPoolId,
                nftStaked: 0,
                nftRemaining: 0,
                unclaimedUserCount: 0,
                startTime: current_blocktime,
                endTime: current_blocktime + lockingPeriod,
                tokenAllocated: 0,
                tokenRemaining: 0,
                categoryId: categoryId,
                rewardTokenAddress: rewardTokenAddress,
                isActive: true
            })
        );

        _poolIdToIndex[_currentPoolId] = _currentPoolId - 1;
    }

    /**
     * @notice Set active status of the pool
     * @param poolId id of the pool
     * @param isActive active status to set
     */
    function setPoolActiveStatus(
        uint256 poolId,
        bool isActive
    ) external onlyOwner {
        uint256 poolIndex = _poolIdToIndex[poolId];
        StakingPool storage stakingPool = stakingPools[poolIndex];

        require(
            stakingPool.unclaimedUserCount == 0,
            "There are some users unclaimed"
        );
        stakingPool.isActive = isActive;
    }

    /**
     * @notice Set locking period of the pool
     * @param poolId id of the pool
     * @param lockingPeriod locking period to set
     */
    function setPoolLockingPeriod(
        uint256 poolId,
        uint256 lockingPeriod
    ) external onlyOwner {
        uint256 current_blocktime = block.timestamp;
        uint256 poolIndex = _poolIdToIndex[poolId];
        StakingPool storage stakingPool = stakingPools[poolIndex];

        require(
            stakingPool.endTime > current_blocktime,
            "Locking period is already over"
        );
        require(
            stakingPool.startTime + lockingPeriod >= current_blocktime,
            "Invalid locking period"
        );

        stakingPool.endTime = stakingPool.startTime + lockingPeriod;
    }

    /**
     * @notice Set reward token address
     * @param poolId id of the pool
     * @param rewardTokenAddress reward token address
     */
    function setPoolRewardTokenAddress(
        uint256 poolId,
        address rewardTokenAddress
    ) external onlyOwner {
        uint256 current_blocktime = block.timestamp;
        uint256 poolIndex = _poolIdToIndex[poolId];
        StakingPool storage stakingPool = stakingPools[poolIndex];

        require(stakingPool.tokenAllocated == 0, "Token is remaining");

        require(
            stakingPool.endTime > current_blocktime,
            "Locking period is already over"
        );

        stakingPool.rewardTokenAddress = rewardTokenAddress;
    }

    /**
     * @notice Allocate tokens to given pool
     * @param poolId id of the pool
     * @param tokenAmount locking period to set
     */
    function allocateTokensToPool(
        uint256 poolId,
        uint256 tokenAmount
    ) external onlyOwner {
        uint256 current_blocktime = block.timestamp;
        uint256 poolIndex = _poolIdToIndex[poolId];
        StakingPool storage stakingPool = stakingPools[poolIndex];

        require(
            stakingPool.endTime > current_blocktime,
            "Locking period is already over"
        );

        address rewardTokenAddress = stakingPool.rewardTokenAddress;

        IERC20(rewardTokenAddress).safeTransferFrom(
            msg.sender,
            address(this),
            tokenAmount
        );

        stakingPool.tokenAllocated += tokenAmount;
        stakingPool.tokenRemaining += tokenAmount;
    }

    /**
     * @notice Withdraw tokens from tokens
     * @param poolId id of the pool
     * @param tokenAmount locking period to set
     */
    function withdrawTokensFromPool(
        uint256 poolId,
        uint256 tokenAmount
    ) external onlyOwner {
        uint256 current_blocktime = block.timestamp;
        uint256 poolIndex = _poolIdToIndex[poolId];
        StakingPool storage stakingPool = stakingPools[poolIndex];

        require(
            stakingPool.tokenRemaining >= tokenAmount,
            "Insufficient token balance"
        );

        require(
            stakingPool.endTime > current_blocktime ||
                stakingPool.unclaimedUserCount == 0,
            "Not time to withdraw"
        );

        address rewardTokenAddress = stakingPool.rewardTokenAddress;

        IERC20(rewardTokenAddress).safeTransfer(msg.sender, tokenAmount);

        if (stakingPool.endTime > current_blocktime) {
            stakingPool.tokenAllocated -= tokenAmount;
        }
        stakingPool.tokenRemaining -= tokenAmount;
    }

    /**
     * @notice Set nft price
     * @param tokenId token id
     * @param price nft price
     */
    function setNFTPrice(uint256 tokenId, uint256 price) external onlyOwner {
        uint256 nftInfoIndex = _tokenIdToIndex[tokenId];
        NFTInfo storage nftInfo = nftInfos[nftInfoIndex];
        nftInfo.price = price;
    }

    /**
     * @notice Set dev fee
     * @param _devfee fee for dev
     */
    function setDevFee(uint256 _devfee) external onlyOwner {
        devFee = _devfee;
    }

    /**
     * @notice Set dev wallet
     * @param _devWallet dev wallet
     */
    function setDevWallet(address _devWallet) external onlyOwner {
        devWallet = _devWallet;
    }

    /**
     * @notice Withdraw native tokens from SC
     */
    function withdrawNativeToken() external onlyOwner {
        Address.sendValue(payable(msg.sender), address(this).balance);
    }

    /**
     * @notice Withdraw tokens from SC
     * @param tokenAddress token address
     */
    function withdrawToken(address tokenAddress) external onlyOwner {
        IERC20(tokenAddress).safeTransfer(
            msg.sender,
            IERC20(tokenAddress).balanceOf(address(this))
        );
    }

    /**
     * @notice Mint a new NFT to contract
     * @param tokenUri the uri of the token metadata on IPFS
     * @param imgUri the uri of the token image on IPFS
     * @param name the name of the asset
     * @param description the CID of the asset
     * @param creatorName the creator name of the asset
     * @param amount the number of copies to mint
     * @param price the price per copy
     * @param categoryId id of the category
     * @param paymentTokenAddress token address available to buy the assets
     * @param isNativePayment determine if users can buy using native token
     * @param data additional data to be stored with the token
     */
    function mint(
        string memory tokenUri,
        string memory imgUri,
        string memory name,
        string memory description,
        string memory creatorName,
        uint256 amount,
        uint256 price,
        uint256 categoryId,
        address paymentTokenAddress,
        bool isNativePayment,
        bytes memory data
    ) external onlyOwner {
        require(_idmap[tokenUri] == 0, "This uri already exists");
        require(
            categoryId > 0 && categoryId <= _currentCategoryId,
            "Invalid category Id"
        );
        _currentTokenId += 1;

        _idmap[tokenUri] = _currentTokenId;
        _uris[_currentTokenId] = tokenUri;
        _tokenIdToIndex[_currentTokenId] = _currentTokenId - 1;

        nftInfos.push(
            NFTInfo({
                tokenId: _currentTokenId,
                amount: amount,
                boughtAmount: 0,
                price: price,
                categoryId: categoryId,
                paymentTokenAddress: paymentTokenAddress,
                isNativePayment: isNativePayment,
                name: name,
                description: description,
                tokenUri: tokenUri,
                imgUri: imgUri,
                creatorName: creatorName
            })
        );

        _mint(address(this), _currentTokenId, amount, data);
    }

    /**
     * @notice Burn
     * @param tokenId token id
     * @param amount amount to burn
     */
    function burn(uint256 tokenId, uint256 amount) external onlyOwner {
        NFTInfo storage nftInfo = nftInfos[_tokenIdToIndex[tokenId]];

        require(tokenId > 0 && tokenId <= _currentTokenId, "Invalid token Id");
        require(amount > 0, "Amount should be higher that zero");
        require(
            (nftInfo.amount - nftInfo.boughtAmount) >= amount,
            "Insufficient nft balance"
        );

        nftInfo.amount -= amount;

        _burn(address(this), tokenId, amount);
    }

    /**
     * @notice Unstake all NFTs on behalf of user
     * @param poolId the pool ID
     * @param user user address
     */
    function unstakeAllOnBehalf(
        uint256 poolId,
        address user
    ) external onlyOwner {
        require(poolId > 0 && poolId <= _currentPoolId, "Invalid pool Id");

        uint256 current_blocktime = block.timestamp;
        uint256 poolIndex = _poolIdToIndex[poolId];
        StakingPool storage stakingPool = stakingPools[poolIndex];

        require(
            stakingPool.endTime < current_blocktime,
            "Locking period is not over"
        );

        UserStakedNFT[] storage stakedNFTs = _userStakedNFTs[user][poolId];

        for (uint i = 0; i < stakedNFTs.length; i++) {
            if (!stakedNFTs[i].isUnstaked) {
                _safeTransferFrom(
                    address(this),
                    user,
                    stakedNFTs[i].nftInfo.tokenId,
                    stakedNFTs[i].stakedAmount,
                    ""
                );

                userStakedAmount[poolId][user] -= stakedNFTs[i].stakedAmount;
                stakingPool.nftRemaining -= stakedNFTs[i].stakedAmount;

                stakedNFTs[i].isUnstaked = true;
            }
        }
    }

    /**
     * @notice Claim rewards
     * @param poolId the pool ID
     * @param user user address
     */
    function claimRewardsOnBehalf(
        uint256 poolId,
        address user
    ) external onlyOwner {
        require(poolId > 0 && poolId <= _currentPoolId, "Invalid pool Id");

        uint256 current_blocktime = block.timestamp;
        uint256 poolIndex = _poolIdToIndex[poolId];
        StakingPool storage stakingPool = stakingPools[poolIndex];

        require(
            stakingPool.endTime < current_blocktime,
            "Locking period is not over"
        );
        require(!userClaimedRewards[user][poolId], "Already claimed");

        UserStakedNFT[] memory stakedNFTs = _userStakedNFTs[user][poolId];

        require(stakedNFTs.length > 0, "Invalid staker");

        uint256 totalRewards = 0;
        uint256 rewardRate = stakingPool.tokenAllocated /
            stakingPool.nftStaked /
            (stakingPool.endTime - stakingPool.startTime);

        for (uint i = 0; i < stakedNFTs.length; i++) {
            totalRewards +=
                (stakingPool.endTime - stakedNFTs[i].stakedAt) *
                rewardRate *
                stakedNFTs[i].stakedAmount;
        }

        uint256 amountForDev = (totalRewards * penaltyFee) / 10000;
        IERC20(stakingPool.rewardTokenAddress).safeTransfer(
            devWallet,
            amountForDev
        );
        IERC20(stakingPool.rewardTokenAddress).safeTransfer(
            user,
            totalRewards - amountForDev
        );

        userClaimedRewards[user][poolId] = true;
        stakingPool.unclaimedUserCount -= 1;
        stakingPool.tokenRemaining -= totalRewards;
    }

    //////////////////////////////////////////
    /// User role
    //////////////////////////////////////////
    /**
     * @notice Buy
     * @param tokenId the token Id
     * @param amount amount to buy
     */
    function buy(uint256 tokenId, uint256 amount) external payable {
        uint256 nftInfoIndex = _tokenIdToIndex[tokenId];
        NFTInfo storage nftInfo = nftInfos[nftInfoIndex];

        require(tokenId > 0 && tokenId <= _currentTokenId, "Invalid token Id");
        require(amount > 0, "Amount should be higher that zero");
        require(devWallet != address(0), "Dev wallet not set");
        require(
            (nftInfo.amount - nftInfo.boughtAmount) >= amount,
            "Insufficient nft balance"
        );

        uint256 totalPrice = nftInfo.price * amount;
        uint256 devFeeAmount = (totalPrice * devFee) / 10000;

        if (nftInfo.isNativePayment) {
            require(totalPrice == msg.value, "Invalid pay amount");

            payable(owner()).transfer(totalPrice - devFeeAmount);
            payable(devWallet).transfer(devFeeAmount);
        } else {
            require(
                totalPrice <
                    IERC20(nftInfo.paymentTokenAddress).balanceOf(msg.sender),
                "Insufficient token balance"
            );

            IERC20(nftInfo.paymentTokenAddress).safeTransferFrom(
                msg.sender,
                owner(),
                totalPrice - devFeeAmount
            );
            IERC20(nftInfo.paymentTokenAddress).safeTransferFrom(
                msg.sender,
                devWallet,
                devFeeAmount
            );
        }

        nftInfo.boughtAmount += amount;

        _safeTransferFrom(address(this), msg.sender, tokenId, amount, "");
    }

    /**
     * @notice Buy and gift NFTs
     * @param tokenId the token Id
     * @param totalAmount total amount to buy
     * @param addresses array of the address
     * @param amounts array of the amount
     */
    function giftNFTs(
        uint256 tokenId,
        uint256 totalAmount,
        address[] calldata addresses,
        uint256[] calldata amounts
    ) external payable {
        require(tokenId > 0 && tokenId <= _currentTokenId, "Invalid token Id");
        require(totalAmount > 0, "Amount should be higher that zero");
        require(devWallet != address(0), "Dev wallet not set");
        require(
            addresses.length == amounts.length,
            "Mismatched length of addresses and amounts"
        );

        uint256 nftInfoIndex = _tokenIdToIndex[tokenId];
        NFTInfo storage nftInfo = nftInfos[nftInfoIndex];

        require(
            (nftInfo.amount - nftInfo.boughtAmount) >= totalAmount,
            "Insufficient balance"
        );

        uint256 totalPrice = nftInfo.price * totalAmount;
        uint256 devFeeAmount = (totalPrice * devFee) / 10000;

        if (nftInfo.isNativePayment) {
            require(totalPrice == msg.value, "Invalid pay amount");

            payable(owner()).transfer(totalPrice - devFeeAmount);
            payable(devWallet).transfer(devFeeAmount);
        } else {
            require(
                totalPrice <
                    IERC20(nftInfo.paymentTokenAddress).balanceOf(msg.sender),
                "Insufficient token balance"
            );

            IERC20(nftInfo.paymentTokenAddress).safeTransferFrom(
                msg.sender,
                owner(),
                totalPrice - devFeeAmount
            );
            IERC20(nftInfo.paymentTokenAddress).safeTransferFrom(
                msg.sender,
                devWallet,
                devFeeAmount
            );
        }

        for (uint i = 0; i < addresses.length; i++) {
            _safeTransferFrom(
                address(this),
                addresses[i],
                tokenId,
                amounts[i],
                ""
            );
        }

        nftInfo.boughtAmount += totalAmount;
    }

    /**
     * @notice Stake NFTs
     * @param poolId the pool Id
     * @param tokenId the token Id
     * @param amount amount to stake
     */
    function stake(uint256 poolId, uint256 tokenId, uint256 amount) external {
        require(poolId > 0 && poolId <= _currentPoolId, "Invalid pool Id");
        require(tokenId > 0 && tokenId <= _currentTokenId, "Invalid token Id");
        require(amount > 0, "Amount should be higher that zero");

        uint256 current_blocktime = block.timestamp;
        uint256 poolIndex = _poolIdToIndex[poolId];
        uint256 nftInfoIndex = _tokenIdToIndex[tokenId];

        StakingPool storage stakingPool = stakingPools[poolIndex];
        NFTInfo memory nftInfo = nftInfos[nftInfoIndex];

        require(
            balanceOf(msg.sender, tokenId) >= amount,
            "Insufficient NFT balance"
        );
        require(stakingPool.isActive, "The staking pool is inactive");

        require(
            stakingPool.endTime > current_blocktime,
            "Locking period is over"
        );

        require(
            stakingPool.categoryId == nftInfo.categoryId,
            "Mismatched category"
        );

        _setApprovalForAll(msg.sender, address(this), true);
        _safeTransferFrom(msg.sender, address(this), tokenId, amount, "");

        UserStakedNFT[] storage stakedNFTs = _userStakedNFTs[msg.sender][
            poolId
        ];

        if (stakedNFTs.length == 0) {
            stakingPool.unclaimedUserCount += 1;
            poolStakers[poolId].push(msg.sender);
        }

        uint256 stakedId = stakedNFTs.length + 1;

        stakedNFTs.push(
            UserStakedNFT({
                id: stakedId,
                nftInfo: nftInfo,
                stakedAmount: amount,
                stakedAt: current_blocktime,
                isUnstaked: false
            })
        );

        userStakedAmount[poolId][msg.sender] += amount;
        stakingPool.nftStaked += amount;
        stakingPool.nftRemaining += amount;
    }

    /**
     * @notice Stake NFTs
     * @param poolId the pool Id
     * @param tokenId the token Id
     * @param stakedId staked Id
     */
    function unstake(
        uint256 poolId,
        uint256 tokenId,
        uint256 stakedId
    ) external {
        require(poolId > 0 && poolId <= _currentPoolId, "Invalid pool Id");
        require(tokenId > 0 && tokenId <= _currentTokenId, "Invalid token Id");

        uint256 current_blocktime = block.timestamp;
        uint256 poolIndex = _poolIdToIndex[poolId];
        uint256 nftInfoIndex = _tokenIdToIndex[tokenId];

        StakingPool storage stakingPool = stakingPools[poolIndex];
        NFTInfo memory nftInfo = nftInfos[nftInfoIndex];

        UserStakedNFT[] storage stakedNFTs = _userStakedNFTs[msg.sender][
            poolId
        ];

        require(
            stakingPool.endTime < current_blocktime,
            "Locking period is not over"
        );
        require(
            stakingPool.categoryId == nftInfo.categoryId,
            "Mismatched category"
        );
        require(
            stakedId > 0 && stakedId <= stakedNFTs.length,
            "Invalid stake id"
        );
        require(!stakedNFTs[stakedId - 1].isUnstaked, "Already unstaked");

        _safeTransferFrom(
            address(this),
            msg.sender,
            tokenId,
            stakedNFTs[stakedId - 1].stakedAmount,
            ""
        );

        userStakedAmount[poolId][msg.sender] -= stakedNFTs[stakedId - 1]
            .stakedAmount;
        stakingPool.nftRemaining -= stakedNFTs[stakedId - 1].stakedAmount;

        stakedNFTs[stakedId - 1].isUnstaked = true;
    }

    /**
     * @notice Unstake all NFTs
     * @param poolId the pool ID
     */
    function unstakeAll(uint256 poolId) external {
        require(poolId > 0 && poolId <= _currentPoolId, "Invalid pool Id");

        uint256 current_blocktime = block.timestamp;
        uint256 poolIndex = _poolIdToIndex[poolId];
        StakingPool storage stakingPool = stakingPools[poolIndex];

        require(
            stakingPool.endTime < current_blocktime,
            "Locking period is not over"
        );

        UserStakedNFT[] storage stakedNFTs = _userStakedNFTs[msg.sender][
            poolId
        ];

        for (uint i = 0; i < stakedNFTs.length; i++) {
            if (!stakedNFTs[i].isUnstaked) {
                _safeTransferFrom(
                    address(this),
                    msg.sender,
                    stakedNFTs[i].nftInfo.tokenId,
                    stakedNFTs[i].stakedAmount,
                    ""
                );

                userStakedAmount[poolId][msg.sender] -= stakedNFTs[i]
                    .stakedAmount;
                stakingPool.nftRemaining -= stakedNFTs[i].stakedAmount;

                stakedNFTs[i].isUnstaked = true;
            }
        }
    }

    /**
     * @notice Claim rewards
     * @param poolId the pool ID
     */
    function claimRewards(uint256 poolId) external {
        require(poolId > 0 && poolId <= _currentPoolId, "Invalid pool Id");

        uint256 current_blocktime = block.timestamp;
        uint256 poolIndex = _poolIdToIndex[poolId];
        StakingPool storage stakingPool = stakingPools[poolIndex];

        require(
            stakingPool.endTime < current_blocktime,
            "Locking period is not over"
        );
        require(!userClaimedRewards[msg.sender][poolId], "Already claimed");

        UserStakedNFT[] memory stakedNFTs = _userStakedNFTs[msg.sender][poolId];

        require(stakedNFTs.length > 0, "Invalid staker");

        uint256 totalRewards = 0;
        uint256 rewardRate = stakingPool.tokenAllocated /
            stakingPool.nftStaked /
            (stakingPool.endTime - stakingPool.startTime);

        for (uint i = 0; i < stakedNFTs.length; i++) {
            totalRewards +=
                (stakingPool.endTime - stakedNFTs[i].stakedAt) *
                rewardRate *
                stakedNFTs[i].stakedAmount;
        }

        IERC20(stakingPool.rewardTokenAddress).safeTransfer(
            msg.sender,
            totalRewards
        );

        userClaimedRewards[msg.sender][poolId] = true;
        stakingPool.unclaimedUserCount -= 1;
        stakingPool.tokenRemaining -= totalRewards;
    }

    //////////////////////////////////////////
    /// View methods
    //////////////////////////////////////////
    /**
     * @notice Get NFT categories
     */
    function getNFTCategories() external view returns (NFTCategory[] memory) {
        return nftCategories;
    }

    /**
     * @notice Get Staking pools
     */
    function getStakingPools(
        uint256 fromIndex,
        uint256 size,
        bool isAll
    ) external view returns (StakingPool[] memory) {
        if (isAll) {
            return stakingPools;
        } else {
            StakingPool[] memory validStakingPools = new StakingPool[](size);

            for (uint i = 0; i < size; i++) {
                if ((fromIndex + i) < _currentPoolId) {
                    validStakingPools[i] = stakingPools[fromIndex + i];
                }
            }

            return validStakingPools;
        }
    }

    /**
     * @notice Get sepecific staking pool according to pool id
     */
    function getStakingPool(
        uint256 poolId
    ) external view returns (StakingPool memory) {
        return stakingPools[_poolIdToIndex[poolId]];
    }

    /**
     * @notice Get NFT infos
     */
    function getNFTInfos(
        uint256 fromIndex,
        uint256 size,
        bool isAll
    ) external view returns (NFTInfo[] memory) {
        if (isAll) {
            return nftInfos;
        } else {
            NFTInfo[] memory validNFTInfos = new NFTInfo[](size);

            for (uint i = 0; i < size; i++) {
                if ((fromIndex + i) < _currentTokenId) {
                    validNFTInfos[i] = nftInfos[fromIndex + i];
                }
            }

            return validNFTInfos;
        }
    }

    /**
     * @notice Get sepecific NFT info according to token id
     */
    function getNFTInfo(
        uint256 tokenId
    ) external view returns (NFTInfo memory) {
        return nftInfos[_tokenIdToIndex[tokenId]];
    }

    /**
     * @notice Get user staked NFTs according to pool
     */
    function getUserStakedNFTs(
        address user,
        uint256 poolId,
        uint256 fromIndex,
        uint256 size,
        bool isAll
    ) external view returns (UserStakedNFT[] memory) {
        UserStakedNFT[] memory allStakedNFTs = _userStakedNFTs[user][poolId];
        if (isAll) {
            return allStakedNFTs;
        } else {
            UserStakedNFT[] memory userStakedNFTs = new UserStakedNFT[](size);

            for (uint i = 0; i < size; i++) {
                if ((fromIndex + i) < allStakedNFTs.length) {
                    userStakedNFTs[i] = allStakedNFTs[fromIndex + i];
                }
            }

            return userStakedNFTs;
        }
    }

    /**
     * @notice Get pool stakers info
     */
    function getPoolStakersInfo(
        uint256 poolId,
        uint256 fromIndex,
        uint256 size,
        bool isAll
    ) external view returns (PoolStakerInfo[] memory) {
        if (isAll) {
            PoolStakerInfo[] memory poolStakersInfo = new PoolStakerInfo[](
                poolStakers[poolId].length
            );

            for (uint i = 0; i < poolStakers[poolId].length; i++) {
                address userAddress = poolStakers[poolId][i];
                poolStakersInfo[i] = PoolStakerInfo({
                    user: userAddress,
                    stakedAmount: userStakedAmount[poolId][userAddress],
                    hasClaimed: userClaimedRewards[userAddress][poolId]
                });
            }

            return poolStakersInfo;
        } else {
            PoolStakerInfo[] memory poolStakersInfo = new PoolStakerInfo[](
                size
            );

            for (uint i = 0; i < size; i++) {
                if ((fromIndex + i) < poolStakers[poolId].length) {
                    address userAddress = poolStakers[poolId][fromIndex + i];
                    poolStakersInfo[i] = PoolStakerInfo({
                        user: userAddress,
                        stakedAmount: userStakedAmount[poolId][userAddress],
                        hasClaimed: userClaimedRewards[userAddress][poolId]
                    });
                }
            }

            return poolStakersInfo;
        }
    }

    /**
     * @notice Get current block time
     */
    function getCurrentTime() external view returns (uint256) {
        return block.timestamp;
    }

    function supportsInterface(
        bytes4 interfaceId
    ) public view virtual override(ERC1155, ERC1155Receiver) returns (bool) {
        return
            interfaceId == 0x01ffc9a7 || // ERC-165 support (i.e. `bytes4(keccak256('supportsInterface(bytes4)'))`).
            interfaceId == 0x4e2312e0 ||
            interfaceId == type(IERC1155).interfaceId ||
            interfaceId == type(IERC1155MetadataURI).interfaceId ||
            super.supportsInterface(interfaceId);
    }
}
