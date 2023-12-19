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
// OpenZeppelin Contracts (last updated v4.8.0) (security/ReentrancyGuard.sol)

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
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC1155/IERC1155.sol)

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
    function balanceOfBatch(address[] calldata accounts, uint256[] calldata ids)
        external
        view
        returns (uint256[] memory);

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
    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes calldata data
    ) external;

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
// OpenZeppelin Contracts v4.4.1 (token/ERC721/utils/ERC721Holder.sol)

pragma solidity ^0.8.0;

import "../IERC721Receiver.sol";

/**
 * @dev Implementation of the {IERC721Receiver} interface.
 *
 * Accepts all token transfers.
 * Make sure the contract is able to use its token with {IERC721-safeTransferFrom}, {IERC721-approve} or {IERC721-setApprovalForAll}.
 */
contract ERC721Holder is IERC721Receiver {
    /**
     * @dev See {IERC721Receiver-onERC721Received}.
     *
     * Always returns `IERC721Receiver.onERC721Received.selector`.
     */
    function onERC721Received(
        address,
        address,
        uint256,
        bytes memory
    ) public virtual override returns (bytes4) {
        return this.onERC721Received.selector;
    }
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
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (utils/math/SafeMath.sol)

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
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
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
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
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
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "@openzeppelin/contracts/token/ERC1155/utils/ERC1155Holder.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/introspection/IERC165.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "./ManageableAuction.sol";
import "./SendValueWithFallbackWithdraw.sol";
import "../interfaces/IRewardPool.sol";
import "./TokenAcceptanceCheck.sol";
import "../OperatorAccess.sol";
import "../interfaces/IGreedyArtAuction.sol";

/**
 * @title GreedyArtAuction main contract.
 */
contract GreedyArtAuction is
    IGreedyArtAuction,
    ManageableAuction,
    ERC721Holder,
    ERC1155Holder,
    SendValueWithFallbackWithdraw,
    OperatorAccess,
    ReentrancyGuard
{
    using SafeMath for uint;

    uint256 public index;
    uint256 public currentAuctionId;
    address public rewardPool;

    mapping(uint256 => Auction) public auctions;
    mapping(address => uint256[]) public userAuctions;

    constructor(
        address _feeTo,
        uint256 _initialServiceFee,
        uint256 _rewardPoolFee,
        uint256 _sellerFee,
        uint256 _minBidStep,
        uint256 _timeframe
    ) {
        require(
            _feeTo != address(0) &&
                _initialServiceFee <= 10000 &&
                _rewardPoolFee <= 10000 &&
                _sellerFee <= 10000 &&
                _minBidStep >= DEFAULT_FEE_DECIMAL &&
                _timeframe >= 20 * 60,
            "Constructor bad config"
        );

        feeTo = _feeTo;

        initialServiceFee = _initialServiceFee;
        rewardPoolFee = _rewardPoolFee;
        sellerFee = _sellerFee;

        minBidStep = _minBidStep;
        timeframe = _timeframe;
    }

    receive() external payable {
        revert("Auction: don't accept direct ether bid");
    }

    fallback() external payable {
        if (msg.value != 0) {
            emit Received(_msgSender(), msg.value);
        }
    }

    /**
     * @dev Creates new auction, and sets out
     * the details of the deal, like a {_token}, {_tokenId},
     * {_initialPrice}
     */
    function createNewERC721(
        IERC721 _token,
        uint256 _tokenId,
        uint256 _initialPrice
    ) external payable nonReentrant returns (uint256 _auctionId) {
        uint256 msgValue = msg.value;

        require(
            _initialPrice >= minBidStep && _initialPrice == msgValue,
            "Small deposit or deposit overflow"
        );
        require(msg.value % minBidStep == 0, "Auction: not a discrete bid");

        // check if seller can get back his ntf
        TokenAcceptanceCheck.checkOnERC721Received(
            address(this),
            _msgSender(),
            _tokenId,
            ""
        );

        uint256 initialFee = initialServiceFee.mul(_initialPrice).div(
            DEFAULT_FEE_DECIMAL
        );
        _withdrawEther(feeTo, initialFee);

        _token.safeTransferFrom(_msgSender(), address(this), _tokenId);

        index++;
        _auctionId = index;

        Auction storage a = auctions[_auctionId];

        a.token.tokenType = TokenType.ERC721;
        a.token.addr = address(_token);
        a.token.id = _tokenId;
        a.totalRaised += msgValue;
        a.initialPrice = _initialPrice;
        a.highestBidder = _msgSender();
        a.seller = _msgSender();
        a.initialServiceFee = initialServiceFee;

        userAuctions[_msgSender()].push(_auctionId);

        emit AuctionCreated(_auctionId);
    }

    /**
     * @dev Creates new auction, and sets out
     * the details of the deal, like a {_token}, {_tokenId}, {_tokenAmount},
     * {_initialPrice}
     */
    function createNewERC1155(
        IERC1155 _token,
        uint256 _tokenId,
        uint256 _tokenAmount,
        uint256 _initialPrice
    ) external payable nonReentrant returns (uint256 _auctionId) {
        uint256 msgValue = msg.value;

        require(
            _initialPrice >= minBidStep && _initialPrice == msgValue,
            "Small deposit or deposit overflow"
        );
        require(msg.value % minBidStep == 0, "Auction: not a discrete bid");

        // check if seller can get back his ntf
        TokenAcceptanceCheck.checkOnERC1155Received(
            address(this),
            address(this),
            _msgSender(),
            _tokenId,
            _tokenAmount,
            ""
        );

        uint256 initialFee = initialServiceFee.mul(_initialPrice).div(
            DEFAULT_FEE_DECIMAL
        );
        _withdrawEther(feeTo, initialFee);

        _token.safeTransferFrom(
            _msgSender(),
            address(this),
            _tokenId,
            _tokenAmount,
            ""
        );

        index++;
        _auctionId = index;

        Auction storage a = auctions[_auctionId];

        a.token.tokenType = TokenType.ERC1155;
        a.token.addr = address(_token);
        a.token.id = _tokenId;
        a.token.amount = _tokenAmount;
        a.totalRaised += msgValue;
        a.initialPrice = _initialPrice;
        a.highestBidder = _msgSender();
        a.seller = _msgSender();
        a.initialServiceFee = initialServiceFee;

        userAuctions[_msgSender()].push(_auctionId);

        emit AuctionCreated(_auctionId);
    }

    // @dev Seller can increase initial price during status AWAITING.
    function updateAuction(
        uint256 _auctionId,
        uint256 _initialPrice
    ) external payable {
        require(
            getStatus(_auctionId) == Status.AWAITING,
            "Auction: update impossible"
        );

        Auction storage a = auctions[_auctionId];

        require(_msgSender() == a.seller, "Auction: not seller");

        uint256 prevInitialPrice = a.initialPrice;

        require(_initialPrice >= prevInitialPrice + minBidStep, "Low price");
        require(
            msg.value == _initialPrice - prevInitialPrice,
            "Incorrect deposit, check value"
        );

        require(msg.value % minBidStep == 0, "Auction: not a discrete bid");

        uint256 initialFee = initialServiceFee.mul(msg.value).div(
            DEFAULT_FEE_DECIMAL
        );
        _withdrawEther(feeTo, initialFee);

        a.totalRaised += msg.value;
        a.initialPrice = _initialPrice;
        emit AuctionUpdated(_auctionId, _initialPrice);
    }

    function totalAuctions(address _user) public view returns (uint256) {
        return userAuctions[_user].length;
    }

    /**
     * @dev Returns bidding end date. If zero, auction is not started.
     */
    function biddingEnd(
        uint256 _auctionId
    ) public view returns (uint256 endIn) {
        Auction memory a = auctions[_auctionId];
        endIn =
            a.biddingStart +
            (timeframe - ((a.bids < timeframe) ? a.bids : 0));
    }

    /**
     * @dev Returns current auction status.
     */
    function getStatus(uint256 _auctionId) public view returns (Status status) {
        require(_auctionId <= index, "Auction: auction not exist");

        Auction memory a = auctions[_auctionId];

        if (a.status == Status.AWAITING) {
            return status = Status.AWAITING;
        }

        if (a.status == Status.CANCELLED) {
            return status = Status.CANCELLED;
        }

        if (a.status == Status.CLOSED) {
            return status = Status.CLOSED;
        }

        if (a.status == Status.PAUSED) {
            return status = Status.PAUSED;
        }

        if (a.status == Status.ACTIVATED) {
            status = Status.ACTIVATED;
            if (currentAuctionId != _auctionId) {
                return status = Status.AWAITING;
            }
            return status;
        }

        if (block.timestamp > biddingEnd(_auctionId)) {
            return status = Status.ENDED;
        }

        if (a.status == Status.IN_PROGRESS && currentAuctionId != _auctionId) {
            return status = Status.AWAITING;
        }

        status = a.status;
    }

    /**
     * @dev Make bid {msg.value} to contract.
     */
    function placeBid(uint256 _auctionId) external payable nonReentrant {
        Status status = getStatus(_auctionId);

        require(
            status == Status.IN_PROGRESS || status == Status.ACTIVATED,
            "Auction: bet not available"
        );

        Auction storage a = auctions[_auctionId];

        if (a.token.tokenType == TokenType.ERC721) {
            // check is bidder can receive erc721 ntfs
            TokenAcceptanceCheck.checkOnERC721Received(
                address(this),
                _msgSender(),
                a.token.id,
                ""
            );
        } else {
            // check is bidder can receive erc1155 ntfs
            TokenAcceptanceCheck.checkOnERC1155Received(
                address(this),
                address(this),
                _msgSender(),
                a.token.id,
                a.token.amount,
                ""
            );
        }

        require(
            _msgSender() != a.highestBidder,
            "Auction: attempt to outbid your bet"
        );
        require(
            msg.value >= a.highestBid + minBidStep,
            "Auction: not enough bid"
        );
        require(msg.value % minBidStep == 0, "Auction: not a discrete bid");

        // change auction status if it first bid in auction
        if (a.bids == 0) {
            a.biddingStart = block.timestamp;
            a.status = Status.IN_PROGRESS;
            emit AuctionStarted(
                _auctionId,
                a.biddingStart,
                biddingEnd(_auctionId)
            );
        }

        // update start time on every bid
        a.biddingStart = block.timestamp;
        uint256 rewardFee_;
        if (rewardPool != address(0)) {
            rewardFee_ = rewardPoolFee.mul(msg.value).div(DEFAULT_FEE_DECIMAL);
            _addBonus(_msgSender(), rewardFee_);
        }

        // update bid
        a.highestBid = msg.value;
        a.highestBidder = _msgSender();
        a.bids += 1;
        // all bids stored on contract
        a.totalRaised += msg.value;
        a.totalRewardFee += rewardFee_;

        emit BidPlaced(
            _auctionId,
            a.token.addr,
            a.token.id,
            _msgSender(),
            msg.value,
            a.totalRaised
        );
    }

    /**
     * @dev End the auction and send the highest bid
     * to the beneficiary.
     */
    function close(uint256 _auctionId) external nonReentrant {
        require(
            getStatus(_auctionId) == Status.ENDED,
            "Auction: close impossible"
        );

        Auction storage a = auctions[_auctionId];
        a.status = Status.CLOSED;

        uint256 bonusPool = a.totalRaised.sub(a.initialPrice);

        // reward to seller
        uint256 toSeller;
        if (sellerFee > 0) {
            toSeller = sellerFee.mul(bonusPool).div(DEFAULT_FEE_DECIMAL);
            _withdrawEther(a.seller, toSeller);
        }

        // reward to winner
        // divide bonus pool - all tokens without deposit service fee
        // reward to service from deposit
        uint256 toWinner;
        if (a.initialServiceFee > 0) {
            toWinner = a.initialPrice.sub(
                a.initialServiceFee.mul(a.initialPrice).div(DEFAULT_FEE_DECIMAL)
            );
        }
        toWinner += bonusPool - toSeller - a.totalRewardFee;
        _withdrawEther(a.highestBidder, toWinner);

        if (a.token.tokenType == TokenType.ERC1155) {
            _withdrawNFT1155(
                a.token.addr,
                a.highestBidder,
                a.token.id,
                a.token.amount
            ); // nft to winner
        } else {
            _withdrawNFT721(a.token.addr, a.highestBidder, a.token.id); // nft to winner
        }

        emit AuctionEnded(_auctionId, a.highestBidder, a.highestBid, bonusPool);
    }

    /**
     * @dev Cancel current auction, at any time before {Status.IN_PROGRESS}.
     */
    function cancel(uint256 _auctionId) external nonReentrant {
        Auction storage a = auctions[_auctionId];
        Status status = getStatus(_auctionId);

        bool cancelledByOperator = operators[_msgSender()];
        if (cancelledByOperator) {
            require(
                status == Status.AWAITING || status == Status.ACTIVATED,
                "Auction: cancel impossible"
            );
        } else {
            require(status == Status.AWAITING, "Auction: cancel impossible");
            require(_msgSender() == a.seller, "Auction: not seller");
        }

        a.status = Status.CANCELLED;

        // return NFT back to beneficiary {_msgSender()}
        if (a.token.tokenType == TokenType.ERC1155) {
            _withdrawNFT1155(
                a.token.addr,
                a.seller,
                a.token.id,
                a.token.amount
            ); // nft to winner
        } else {
            _withdrawNFT721(a.token.addr, a.seller, a.token.id); // nft to winner
        }

        uint256 penalty;
        if (a.initialServiceFee > 0) {
            penalty = a.initialPrice.sub(
                a.initialServiceFee.mul(a.initialPrice).div(DEFAULT_FEE_DECIMAL)
            );
        } else {
            penalty = a.totalRaised;
        }
        _withdrawEther(a.seller, penalty);
        emit AuctionCanceled(_auctionId);
        if (cancelledByOperator) {
            emit AuctionCanceledByOperator(_auctionId, _msgSender());
        }
    }

    function setNextAuction(uint256 _id) external onlyOperator {
        require(_id != 0, "Zero id set");

        Status currectAuctionStatus = getStatus(currentAuctionId);
        require(
            currectAuctionStatus != Status.PAUSED &&
                currectAuctionStatus != Status.IN_PROGRESS,
            "Auction: current auction in progress"
        );

        Status actualStatus = getStatus(_id);

        if (currentAuctionId != 0) {
            require(
                actualStatus == Status.AWAITING,
                "Auction: impossible to activate"
            );
        }

        currentAuctionId = _id;
        auctions[_id].status = Status.ACTIVATED;
        emit AuctionActivated(_id);
    }

    function pause(uint256 _auctionId) external onlyOperator {
        Status status = getStatus(_auctionId);

        require(
            status == Status.ACTIVATED || status == Status.IN_PROGRESS,
            "Auction: cannot pause"
        );

        Auction storage a = auctions[_auctionId];
        a.status = Status.PAUSED;
        a.biddingPausedAt = block.timestamp;

        emit AuctionPaused(_auctionId);
    }

    function unpause(uint256 _auctionId) external onlyOperator {
        Status status = getStatus(_auctionId);

        require(status == Status.PAUSED, "Auction: cannot unpause");

        Auction storage a = auctions[_auctionId];
        if (a.bids == 0) {
            a.status = Status.ACTIVATED;
            emit AuctionActivated(_auctionId);
        } else {
            a.status = Status.IN_PROGRESS;
            a.biddingStart =
                block.timestamp -
                (a.biddingPausedAt - a.biddingStart);
            emit AuctionStarted(
                _auctionId,
                a.biddingStart,
                biddingEnd(_auctionId)
            );
        }
    }

    function setRewardPool(address _rewardPool) external onlyOwner {
        rewardPool = _rewardPool;
    }

    /**
     * @dev Helps to count next minimum bid price by {_auctionId}.
     */
    function countNextMinBidPrice(
        uint256 _auctionId
    ) external view returns (uint256 price) {
        Auction memory auction = auctions[_auctionId];
        price = auction.highestBid + minBidStep;
    }

    function countReward(
        uint256 _auctionId
    ) external view returns (uint256 winnerReward, uint256 toSeller) {
        Auction memory a = auctions[_auctionId];

        // define bonus pool
        uint256 bonusPool = a.totalRaised.sub(a.initialPrice);

        toSeller += sellerFee.mul(bonusPool).div(DEFAULT_FEE_DECIMAL); // 10000 - 100%

        winnerReward += a.initialPrice.sub(
            a.initialServiceFee.mul(a.initialPrice).div(DEFAULT_FEE_DECIMAL)
        );
        winnerReward += bonusPool - toSeller - a.totalRewardFee;
    }

    /**
     * @dev Withdraw {_amount} ETH to {_beneficiary}.
     */
    function _withdrawEther(address _beneficiary, uint256 _amount) internal {
        require(
            address(this).balance >= _amount,
            "Auction: not enough balance"
        );

        _sendValueWithFallbackWithdraw(payable(_beneficiary), _amount);
    }

    // @dev Internal function for adding bonuses for participants.
    function _addBonus(address _account, uint256 _amount) internal {
        IRewardPool(rewardPool).deposit{value: _amount}(_account);
    }

    function _getFee(
        uint256 _amount,
        uint256 _fee
    ) internal pure returns (uint256) {
        unchecked {
            return (_amount * _fee) / DEFAULT_FEE_DECIMAL;
        }
    }

    /**
     * @dev Withdraw NFT {_token} to {_beneficiary}.
     */
    function _withdrawNFT721(
        address _token,
        address _beneficiary,
        uint256 _tokenId
    ) internal {
        IERC721(_token).safeTransferFrom(address(this), _beneficiary, _tokenId);
    }

    /**
     * @dev Withdraw NFT {_token} to {_beneficiary}.
     */
    function _withdrawNFT1155(
        address _token,
        address _beneficiary,
        uint256 _tokenId,
        uint256 _tokenAmount
    ) internal {
        IERC1155(_token).safeTransferFrom(
            address(this),
            _beneficiary,
            _tokenId,
            _tokenAmount,
            ""
        );
    }
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable2Step.sol";
import "../interfaces/IManageableAuction.sol";

contract ManageableAuction is IManageableAuction, Ownable2Step {
    uint256 constant DEFAULT_FEE_DECIMAL = 10000;

    /**
     * @notice Service fee receiver
     */
    address public override feeTo;
    /**
     * @notice Auction creation fee
     */
    uint256 public override initialServiceFee;
    /**
     * @notice Fee taken for rewards in reward pool
     */
    uint256 public override rewardPoolFee;
    /**
     * @notice Fee taken from seller
     */
    uint256 public override sellerFee;
    /**
     * @notice Minimum bid step
     */
    uint256 public override minBidStep;

    uint256 public override timeframe;

    function setFeeTo(address _dest) external override onlyOwner {
        require(_dest != address(0), "Address ZERO");
        feeTo = _dest;
        emit FeeToSet(_dest);
    }

    function setTimeframe(uint256 _limit) external override onlyOwner {
        require(_limit != 0, "Timeframe ZERO");
        timeframe = _limit;
        emit TimeframeSet(_limit);
    }

    // decimal 10000
    function setInitialServiceFee(uint256 _fee) external override onlyOwner {
        require(_fee <= DEFAULT_FEE_DECIMAL, "BP VIOLATION");
        initialServiceFee = _fee;
        emit ServiceFeeSet(_fee);
    }

    function setRewardPoolFee(uint256 _fee) external override onlyOwner {
        require(_fee <= DEFAULT_FEE_DECIMAL, "BP VIOLATION");
        rewardPoolFee = _fee;
        emit RewardPoolFeeSet(_fee);
    }

    function setSellerFee(uint256 _fee) external override onlyOwner {
        require(_fee <= DEFAULT_FEE_DECIMAL, "BP VIOLATION");
        sellerFee = _fee;
        emit ServiceBonusFeeSet(_fee);
    }

    function setMinBidStep(uint256 _step) external override onlyOwner {
        require(_step >= DEFAULT_FEE_DECIMAL, "Less then possible");

        minBidStep = _step;
        emit MinBidStepSet(_step);
    }
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Address.sol";

/**
 * @notice Attempt to send ETH and if the transfer fails or runs out of gas, store the balance
 * for future withdrawal instead.
 */
abstract contract SendValueWithFallbackWithdraw {
    mapping(address => uint256) private _pendingWithdrawals;

    event Withdrawal(address indexed _user, uint256 _amount);
    event WithdrawPending(address indexed _user, uint256 _amount);

    /**
     * @notice Returns how much funds are available for manual withdraw due to failed transfers.
     */
    function getPendingWithdrawal(address _user) public view returns (uint256) {
        return _pendingWithdrawals[_user];
    }

    /**
     * @notice Allows a user to manually withdraw funds which originally failed to transfer.
     */
    function withdraw() external {
        uint256 amount = _pendingWithdrawals[msg.sender];
        require(amount > 0, "No funds are pending withdrawal");
        _pendingWithdrawals[msg.sender] = 0;
        (bool success, ) = msg.sender.call{value: amount}("");
        require(success, "Ether withdraw failed");
        emit Withdrawal(msg.sender, amount);
    }

    function _sendValueWithFallbackWithdraw(
        address _user,
        uint256 _amount
    ) internal {
        if (_amount == 0) {
            return;
        }

        // Cap the gas to prevent consuming all available gas to block a tx from completing successfully
        // solhint-disable-next-line avoid-low-level-calls
        (bool success, ) = _user.call{value: _amount, gas: 21000}("");

        if (!success) {
            // Record failed sends for a withdrawal later
            // Transfers could fail if sent to a multisig with non-trivial receiver logic
            unchecked {
                _pendingWithdrawals[_user] += _amount;
            }

            emit WithdrawPending(_user, _amount);
        } else {
            emit Withdrawal(_user, _amount);
        }
    }
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155Receiver.sol";

// accept check if cannot, store to withdraw
library TokenAcceptanceCheck {
    /**
     * @dev Copied {ERC721._checkOnERC721Received}
     * from "openzeppelin/contracts/token/ERC721/ERC721.sol";
     */
    function checkOnERC721Received(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) internal {
        if (Address.isContract(to)) {
            try
                IERC721Receiver(to).onERC721Received(
                    msg.sender,
                    from,
                    tokenId,
                    _data
                )
            returns (bytes4 response) {
                if (response != IERC721Receiver(to).onERC721Received.selector) {
                    require(false, "ERC721: RECEIVER_REJECTED");
                }
            } catch Error(string memory reason) {
                require(false, reason);
            } catch {
                require(false, "ERC721: NON_RECEIVER");
            }
        }
    }

    /**
     * @dev Copied {ERC1155._doSafeTransferAcceptanceCheck}
     * from "openzeppelin/contracts/token/ERC1155/ERC1155.sol";
     */
    function checkOnERC1155Received(
        address operator,
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) internal {
        if (Address.isContract(to)) {
            try
                IERC1155Receiver(to).onERC1155Received(
                    operator,
                    from,
                    id,
                    amount,
                    data
                )
            returns (bytes4 response) {
                if (
                    response != IERC1155Receiver(to).onERC1155Received.selector
                ) {
                    require(false, "ERC1155: RECEIVER_REJECTED");
                }
            } catch Error(string memory reason) {
                require(false, reason);
            } catch {
                require(false, "ERC1155: NON_RECEIVER");
            }
        }
    }
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IGreedyArtAuction {
    enum Status {
        AWAITING,
        ACTIVATED,
        IN_PROGRESS, // after first bid
        ENDED, // after time is up
        CLOSED, // after withdraw
        CANCELLED,
        PAUSED
    }

    enum TokenType {
        ERC721,
        ERC1155
    }

    // NFT details
    struct Token {
        TokenType tokenType;
        address addr;
        uint256 id;
        uint256 amount;
    }

    struct Auction {
        address seller;
        uint256 biddingStart;
        uint256 biddingPausedAt;
        uint256 initialPrice;
        uint256 bids;
        address highestBidder;
        uint256 highestBid;
        uint256 totalRaised;
        uint256 totalRewardFee;
        uint256 initialServiceFee;
        Status status;
        Token token;
    }

    event AuctionCreated(uint256 auctionId);
    event AuctionUpdated(uint256 auctionId, uint256 initPrice);
    event AuctionActivated(uint256 auctionId);
    event AuctionStarted(
        uint256 auctionId,
        uint256 biddingStart,
        uint256 biddingEnd
    );
    event AuctionEnded(
        uint256 auctionId,
        address winner,
        uint256 highestBid,
        uint256 bonusPool
    );
    event AuctionClosed(uint256 auctionId, address winner, uint256 highestBid);
    event AuctionCanceled(uint256 auctionId);
    event AuctionCanceledByOperator(uint256 auctionId, address operator);
    event BidPlaced(
        uint256 auctionId,
        address indexed token,
        uint256 id,
        address bidder,
        uint256 bidPrice,
        uint256 bank
    );
    event Received(address from, uint256 amount);
    event AuctionPaused(uint256 auctionId);
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";

interface IManageableAuction {
    event FeeToSet(address dest);
    event ServiceFeeSet(uint256 fee);
    event RewardPoolFeeSet(uint256 fee);
    event ServiceBonusFeeSet(uint256 fee);
    event MinBidStepSet(uint256 step);
    event TimeframeSet(uint256 limit);

    function feeTo() external view returns (address);

    // Service fee on deposit
    function initialServiceFee() external view returns (uint256);

    // Service fee on close
    function rewardPoolFee() external view returns (uint256);

    // Seller fee on close
    function sellerFee() external view returns (uint256);

    // Minimal stem between
    function minBidStep() external view returns (uint256);

    function timeframe() external view returns (uint256);

    // dest should not be zero address. if dest is contract, it should implement IERC165
    function setFeeTo(address dest) external;

    function setTimeframe(uint256 limit) external;

    function setInitialServiceFee(uint256 fee) external;

    function setRewardPoolFee(uint256 fee) external;

    function setSellerFee(uint256 fee) external;

    function setMinBidStep(uint256 step) external;
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IRewardPool {
    function deposit(address account) external payable;
}
// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0 <1.0.0;

import "@openzeppelin/contracts/access/Ownable2Step.sol";

contract OperatorAccess is Ownable2Step {
    mapping(address => bool) public operators;

    event SetOperator(address account, bool status);

    function setOperator(address _account, bool _status) external onlyOwner {
        operators[_account] = _status;
        emit SetOperator(_account, _status);
    }

    modifier onlyOperator() {
        require(operators[msg.sender], "OperatorAccess: only operator");
        _;
    }
}
