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
// OpenZeppelin Contracts (last updated v4.9.0) (token/ERC721/ERC721.sol)

pragma solidity ^0.8.0;

import "./IERC721.sol";
import "./IERC721Receiver.sol";
import "./extensions/IERC721Metadata.sol";
import "../../utils/Address.sol";
import "../../utils/Context.sol";
import "../../utils/Strings.sol";
import "../../utils/introspection/ERC165.sol";

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

        string memory baseURI = _baseURI();
        return bytes(baseURI).length > 0 ? string(abi.encodePacked(baseURI, tokenId.toString())) : "";
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

    /**
     * @dev Unsafe write access to the balances, used by extensions that "mint" tokens using an {ownerOf} override.
     *
     * WARNING: Anyone calling this MUST ensure that the balances remain consistent with the ownership. The invariant
     * being that for any address `a` the value returned by `balanceOf(a)` must be equal to the number of tokens such
     * that `ownerOf(tokenId)` is `a`.
     */
    // solhint-disable-next-line func-name-mixedcase
    function __unsafe_increaseBalance(address account, uint256 amount) internal {
        _balances[account] += amount;
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (token/ERC721/extensions/ERC721Burnable.sol)

pragma solidity ^0.8.0;

import "../ERC721.sol";
import "../../../utils/Context.sol";

/**
 * @title ERC721 Burnable Token
 * @dev ERC721 Token that can be burned (destroyed).
 */
abstract contract ERC721Burnable is Context, ERC721 {
    /**
     * @dev Burns `tokenId`. See {ERC721-_burn}.
     *
     * Requirements:
     *
     * - The caller must own `tokenId` or be an approved operator.
     */
    function burn(uint256 tokenId) public virtual {
        //solhint-disable-next-line max-line-length
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: caller is not token owner or approved");
        _burn(tokenId);
    }
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
// OpenZeppelin Contracts (last updated v4.9.0) (token/ERC721/IERC721.sol)

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
// OpenZeppelin Contracts (last updated v4.9.0) (token/ERC721/utils/ERC721Holder.sol)

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
    function onERC721Received(address, address, uint256, bytes memory) public virtual override returns (bytes4) {
        return this.onERC721Received.selector;
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
pragma solidity ^0.8.8;

library StructData {
    // struct to store staked NFT information
    struct StakedNFT {
        address stakerAddress;
        uint256 startTime;
        uint256 unlockTime;
        uint256[] nftIds;
        uint256 totalValueStakeUsd;
        uint8 apy;
        uint256 totalClaimedAmountUsdWithDecimal;
        uint256 totalRewardAmountUsdWithDecimal;
        bool isUnstaked;
    }

    struct ChildListData {
        address[] childList;
        uint256 memberCounter;
    }
}
// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity >=0.7.0;

/// @title Optimized overflow and underflow safe math operations
/// @notice Contains methods for doing math operations that revert on overflow or underflow for minimal gas cost
library LowGasSafeMath {
    /// @notice Returns x + y, reverts if sum overflows uint256
    /// @param x The augend
    /// @param y The addend
    /// @return z The sum of x and y
    function add(uint256 x, uint256 y) internal pure returns (uint256 z) {
        require((z = x + y) >= x);
    }

    /// @notice Returns x - y, reverts if underflows
    /// @param x The minuend
    /// @param y The subtrahend
    /// @return z The difference of x and y
    function sub(uint256 x, uint256 y) internal pure returns (uint256 z) {
        require((z = x - y) <= x);
    }

    /// @notice Returns x * y, reverts if overflows
    /// @param x The multiplicand
    /// @param y The multiplier
    /// @return z The product of x and y
    function mul(uint256 x, uint256 y) internal pure returns (uint256 z) {
        require(x == 0 || (z = x * y) / x == y);
    }

    /// @notice Returns x + y, reverts if overflows or underflows
    /// @param x The augend
    /// @param y The addend
    /// @return z The sum of x and y
    function add(int256 x, int256 y) internal pure returns (int256 z) {
        require((z = x + y) >= x == (y >= 0));
    }

    /// @notice Returns x - y, reverts if overflows or underflows
    /// @param x The minuend
    /// @param y The subtrahend
    /// @return z The difference of x and y
    function sub(int256 x, int256 y) internal pure returns (int256 z) {
        require((z = x - y) <= x == (y >= 0));
    }
}
// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity >=0.5.0;

/// @title Safe casting methods
/// @notice Contains methods for safely casting between types
library SafeCast {
    /// @notice Cast a uint256 to a uint160, revert on overflow
    /// @param y The uint256 to be downcasted
    /// @return z The downcasted integer, now type uint160
    function toUint160(uint256 y) internal pure returns (uint160 z) {
        require((z = uint160(y)) == y);
    }

    /// @notice Cast a int256 to a int128, revert on overflow or underflow
    /// @param y The int256 to be downcasted
    /// @return z The downcasted integer, now type int128
    function toInt128(int256 y) internal pure returns (int128 z) {
        require((z = int128(y)) == y);
    }

    /// @notice Cast a uint256 to a int256, revert on overflow
    /// @param y The uint256 to be casted
    /// @return z The casted integer, now type int256
    function toInt256(uint256 y) internal pure returns (int256 z) {
        require(y < 2 ** 255);
        z = int256(y);
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

interface IMarketplace {
    event Buy(address seller, address buyer, uint256 nftId);
    event Sell(address seller, address buyer, uint256 nftId);
    event ErrorLog(bytes message);

    function buyByCurrency(uint256 _nftId, uint256 _refCode) external;

    function buyByToken(uint256 _nftId, uint256 _refCode) external;

    function getActiveMemberForAccount(address _wallet) external view returns (uint256);

    function getReferredNftValueForAccount(address _wallet) external view returns (uint256);

    function getNftCommissionEarnedForAccount(address _wallet) external view returns (uint256);

    function getNftSaleValueForAccountInUsdDecimal(address _wallet) external view returns (uint256);

    function getF1ListForAccount(address _wallet) external view returns (address[] memory);

    function getTeamNftSaleValueForAccountInUsdDecimal(address _wallet) external view returns (uint256);

    function updateReferralData(address _user, uint256 _refCode) external;

    function possibleChangeReferralData(address _wallet) external returns (bool);

    function checkValidRefCodeAdvance(address _user, uint256 _refCode) external view returns (bool);

    function genReferralCodeForAccount() external returns (uint256);

    function getReferralCodeForAccount(address _wallet) external view returns (uint256);

    function getReferralAccountForAccount(address _user) external view returns (address);

    function getReferralAccountForAccountExternal(address _user) external view returns (address);

    function getAccountForReferralCode(uint256 _refCode) external view returns (address);

    function getMaxEarnableCommission(address _user) external view returns (uint256);

    function getTotalCommissionEarned(address _user) external view returns (uint256);

    function getCommissionLimit(address _user) external view returns (uint256);

    function getNftPaymentType(uint256 _nftId) external view returns (bool);

    function allowBuyNftByCurrency(bool _activePayByCurrency) external;

    function allowBuyNftByToken(bool _activePayByToken) external;

    function setOracleAddress(address _oracleAddress) external;

    function setStakingAddress(address _stakingAddress) external;

    function setSystemWallet(address _newSystemWallet) external;

    function setSaleWalletAddress(address _saleAddress) external;

    function setCurrencyAddress(address _currency) external;

    function setTokenAddress(address _token) external;

    function setTypePayCommission(bool _typePayCommission) external;

    function setCommissionPercent(uint256 _percent) external;

    function setMaxCommissionDefault(uint256 _maxCommissionDefault) external;

    function setCommissionMultipleTime(uint256 _commissionMultipleTime) external;

    function setSaleStart(uint256 _newSaleStart) external;

    function setSaleEnd(uint256 _newSaleEnd) external;

    function setSalePercent(uint256 _newSalePercent, uint8 _nftTier) external;

    function updateReferralDataOnlyOwner(address _user, uint256 _refCode) external;

    function updateNftCommissionEarnedOnlyOwner(address _user, uint256 _commissionEarned) external;

    function updateNftSaleValueOnlyOwner(address _user, uint256 _nftSaleValue) external;

    function updateUserF1ListOnlyOwner(address _user, address[] memory _f1Users) external;

    function updateNftPaymentTypeOnlyOwner(uint256 _nftId, bool _paymentType) external;

    function updateUserRefParentOnlyOwner(address _user, address _parent) external;

    function recoverLostBNB() external;

    function withdrawTokenEmergency(address _token, uint256 _amount) external;

    function withdrawTokenEmergencyFrom(address _from, address _to, address _currency, uint256 _amount) external;

    function transferNftEmergency(address _receiver, uint256 _nftId) external;

    function transferMultiNftsEmergency(address[] memory _receivers, uint256[] memory _nftIds) external;
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";

contract AICrewNFT is ERC721, Ownable, Pausable, ERC721Burnable {
    uint256 public tokenCount;
    address private contractOwner;
    // Mapping from token ID to token URI
    mapping(uint256 => string) private tokenURIs;
    // Mapping from tier to price
    mapping(uint256 => uint256) public tierPrices;
    // Mapping from token ID to tier
    mapping(uint256 => uint8) private tokenTiers;

    constructor(string memory _name, string memory _symbol, address _manager) ERC721(_name, _symbol) {
        contractOwner = _msgSender();
        initTierPrices();
        transferOwnership(_manager);
    }

    modifier validId(uint256 _nftId) {
        require(ownerOf(_nftId) != address(0), "INVALID NFT ID");
        _;
    }

    function initTierPrices() public onlyOwner {
        tierPrices[1] = 50000;
        tierPrices[2] = 20000;
        tierPrices[3] = 10000;
        tierPrices[4] = 5000;
        tierPrices[5] = 3000;
        tierPrices[6] = 1000;
        tierPrices[7] = 100;
    }

    function setTierPriceUsd(uint256 _tier, uint256 _price) public onlyOwner {
        tierPrices[_tier] = _price;
    }

    //for external call
    function getNftPriceUsd(uint256 _nftId) external view validId(_nftId) returns (uint256) {
        uint256 nftTier = tokenTiers[_nftId];
        return tierPrices[nftTier];
    }

    //for external call
    function getNftTier(uint256 _nftId) external view validId(_nftId) returns (uint8) {
        return tokenTiers[_nftId];
    }

    function setNftTier(uint256 _nftId, uint8 _tier) public onlyOwner {
        tokenTiers[_nftId] = _tier;
    }

    function tokenURI(uint256 _nftId) public view virtual override returns (string memory) {
        require(ownerOf(_nftId) != address(0), "AICREW_NFT: NFT ID NOT EXIST");
        return tokenURIs[_nftId];
    }

    function setTokenURI(uint256 _nftId, string memory _tokenURI) public onlyOwner {
        require(ownerOf(_nftId) != address(0), "AICREW_NFT: NFT ID NOT EXIST");
        require(bytes(_tokenURI).length > 0, "AICREW_NFT: TOKEN URI MUST NOT NULL");
        tokenURIs[_nftId] = _tokenURI;
    }

    function mint(string memory _tokenURI, uint8 _tier) public onlyOwner {
        require(bytes(_tokenURI).length > 0, "AICREW_NFT: TOKEN URI MUST NOT NULL");
        tokenCount++;
        tokenURIs[tokenCount] = _tokenURI;
        tokenTiers[tokenCount] = _tier;
        _safeMint(msg.sender, tokenCount);
    }

    function batchMint(string[] memory _tokenURI, uint8 _tier) public onlyOwner {
        require(_tokenURI.length > 0, "AICREW_NFT: SIZE LIST URI MUST NOT BE ZERO");
        uint256 index;
        for (index = 0; index < _tokenURI.length; ++index) {
            mint(_tokenURI[index], _tier);
        }
    }

    function mintTo(string memory _tokenURI, uint8 _tier, address _to) public onlyOwner {
        require(_to != address(0), "AICREW_NFT: NOT ACCEPT ZERO ADDRESS");
        require(bytes(_tokenURI).length > 0, "AICREW_NFT: TOKEN URI MUST NOT NULL");
        tokenCount++;
        tokenURIs[tokenCount] = _tokenURI;
        tokenTiers[tokenCount] = _tier;
        _safeMint(_to, tokenCount);
    }

    function batchMintTo(string[] memory _tokenURI, uint8 _tier, address _to) public onlyOwner {
        require(_tokenURI.length > 0, "AICREW_NFT: SIZE LIST URI MUST NOT BE ZERO");
        uint256 index;
        for (index = 0; index < _tokenURI.length; ++index) {
            mintTo(_tokenURI[index], _tier, _to);
        }
    }

    function totalSupply() public view virtual returns (uint256) {
        return tokenCount;
    }

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory data) public override {
        super.safeTransferFrom(from, to, tokenId, data);
    }

    function supportsInterface(bytes4 interfaceID) public pure override returns (bool) {
        return interfaceID == 0x80ac58cd || interfaceID == 0x5b5e139f;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier checkOwner() {
        require(owner() == _msgSender() || contractOwner == _msgSender(), "AICREW_NFT: caller is not the owner");
        _;
    }

    /**
     * @dev Recover lost bnb and send it to the contract owner
     */
    function recoverLostBNB() public checkOwner {
        address payable recipient = payable(msg.sender);
        recipient.transfer(address(this).balance);
    }

    /**
     * @dev withdraw some token balance from contract to owner account
     */
    function withdrawTokenEmergency(address _token, uint256 _amount) public checkOwner {
        require(_amount > 0, "AICREW_NFT: INVALID AMOUNT");
        require(IERC20(_token).transfer(msg.sender, _amount), "AICREW_NFT: CANNOT WITHDRAW TOKEN");
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

interface IOracle {
    function convertUsdBalanceDecimalToTokenDecimal(uint256 _balanceUsdDecimal) external view returns (uint256);

    function setUsdtAmount(uint256 _usdtAmount) external;

    function setTokenAmount(uint256 _tokenAmount) external;

    function setMinTokenAmount(uint256 _tokenAmount) external;

    function setMaxTokenAmount(uint256 _tokenAmount) external;
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

import "../data/StructData.sol";

interface IStaking {
    struct StakedNFT {
        address stakerAddress;
        uint256 startTime;
        uint256 unlockTime;
        uint256 lastClaimTime;
        uint256[] nftIds;
        uint256 totalValueStakeUsd;
        uint256 totalClaimedAmountUsdWithDecimal;
        uint256 totalRewardAmountUsdWithDecimal;
        uint32 apy;
        bool isUnstaked;
    }

    event Staked(uint256 id, address indexed staker, uint256 indexed nftID, uint256 unlockTime, uint32 apy);
    event Unstaked(uint256 id, address indexed staker, uint256 indexed nftID);
    event Claimed(uint256 id, address indexed staker, uint256 claimAmount);

    function getStakeApyForTier(uint8 _nftTier) external returns (uint32);

    function getDirectRewardCondition(uint8 _level) external returns (uint256);

    function getDirectRewardPercent(uint8 _level) external returns (uint32);

    function getProfitRewardCondition(uint8 _level) external returns (uint256);

    function getProfitRewardPercent(uint8 _level) external returns (uint32);

    function getTotalCrewInvestment(address _wallet) external returns (uint256);

    function getTeamStakingValue(address _wallet) external returns (uint256);

    function getMaxEarnableCommission(address _user) external view returns (uint256);

    function getTotalCommissionEarned(address _user) external view returns (uint256);

    function getReferredStakedValue(address _wallet) external returns (uint256);

    function getReferredStakedValueFull(address _wallet) external returns (uint256);

    function getCurrentProfitLevel(address _wallet) external view returns (uint8);

    function getProfitCommissionUnclaimed(address _wallet) external view returns (uint256);

    function getProfitCommissionUnclaimedWithDeep(address _wallet, uint8 _deep) external view returns (uint256);

    function getStakingCommissionEarned(address _wallet) external view returns (uint256);

    function getProfitCommissionEarned(address _wallet) external view returns (uint256);

    function getDirectCommissionEarned(address _wallet) external view returns (uint256);

    function getTotalStakingCommissionEarned(address _wallet) external view returns (uint256);

    function getTotalStakeAmountUSD(address _staker) external view returns (uint256);

    function getTotalStakeAmountUSDWithoutDecimal(address _staker) external view returns (uint256);

    function stake(uint256[] memory _nftIds, uint256 _refCode) external;

    function unstake(uint256 _stakeId) external;

    function claim(uint256 _stakeId) external;

    function claimAll(uint256[] memory _stakeIds) external;

    function getDetailOfStake(uint256 _stakeId) external view returns (StakedNFT memory);

    function possibleUnstake(uint256 _stakeId) external view returns (bool);

    function claimableForStakeInUsdWithDecimal(uint256 _stakeId) external view returns (uint256);

    function rewardUnstakeInTokenWithDecimal(uint256 _stakeId) external view returns (uint256);

    function estimateValueUsdForListNft(uint256[] memory _nftIds) external view returns (uint256);
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";
import "../libraries/LowGasSafeMath.sol";
import "../libraries/SafeCast.sol";
import "../oracle/IOracle.sol";
import "../nft/AICrewNFT.sol";
import "../market/IMarketplace.sol";
import "./IStaking.sol";

contract Staking is IStaking, Ownable, ERC721Holder {
    using LowGasSafeMath for uint256;
    using SafeCast for uint256;

    uint256 private constant TOKEN_DECIMAL = 1e18;
    uint256 private constant ONE_MONTH_SECONDS = 2592000;
    uint256 private constant ONE_YEAR_SECONDS = 31104000;
    uint256 private constant DIRECT_LEVEL = 31104000;
    bool private constant PAYMENT_TYPE_TOKEN = false;
    bool private constant PAYMENT_TYPE_USDT = true;

    address private contractOwner;

    address public nft;
    address public token;
    address public currency;
    address public rewardToken;
    address public marketplaceContract;
    address public oracleContract;
    uint256 public timeOpenStaking = 1684713599; // 2023-05-21
    uint256 public stakingPeriod = 24; // 24 month
    uint256 public profitRewardTime = 6; // 6 month

    uint8 public typePayDirectCom = 1; // 0 is pay com by token, 1 is pay com by usdt, 2 is pay com by buy typePayCom
    bool public typePayProfitCom = false; // false is pay com by token, true is pay com by usdt
    bool private unlocked = true;

    mapping(address => uint256) private totalStakingCommissionEarned; // With decimals
    mapping(address => uint256) private directCommissionEarned; // With decimals
    mapping(address => uint256) private stakingCommissionEarned; // With decimals
    mapping(address => uint256) private profitCommissionEarned; // With decimals
    mapping(uint256 => StakedNFT) private stakedNFTs; // mapping to nftId to stake
    mapping(uint256 => uint256) private nftStakes; // mapping to store reward APY per staking period
    mapping(uint8 => uint32) private nftTierApys; // mapping to store commission percent
    mapping(uint8 => uint256) private directRewardConditions; // Without decimals
    mapping(uint8 => uint32) private directRewardPercents; // Percent / 1000
    mapping(uint8 => uint256) private profitRewardConditions; // Without decimals
    mapping(uint8 => uint32) private profitRewardPercents; // Percent / 1000
    mapping(address => uint256) private totalStakedAmount; // Without decimals
    mapping(address => uint256) private maxNftStakedAmount; // Without decimals
    mapping(address => uint256[]) private userStakeIdList;

    using Counters for Counters.Counter;
    Counters.Counter private totalStakesCounter;

    constructor(address _token, address _currency, address _nft, address _oracleContract, address _marketplace) {
        nft = _nft;
        token = _token;
        currency = _currency;
        rewardToken = _token;
        contractOwner = _msgSender();
        oracleContract = _oracleContract;
        marketplaceContract = _marketplace;
        initStakeApy();
        initDirectRewardConditions();
        initDirectRewardPercents();
        initProfitRewardConditions();
        initProfitRewardPercents();
    }

    modifier checkOwner() {
        require(owner() == _msgSender() || contractOwner == _msgSender(), "STAKING: caller is not the owner");
        _;
    }

    modifier lock() {
        require(unlocked == true, "STAKING: Locked");
        unlocked = false;
        _;
        unlocked = true;
    }

    modifier isTimeForStaking() {
        require(block.timestamp >= timeOpenStaking, "STAKING: THE STAKING PROGRAM HAS NOT YET STARTED.");
        _;
    }

    function initStakeApy() internal {
        nftTierApys[1] = 960;
        nftTierApys[2] = 960;
        nftTierApys[3] = 960;
        nftTierApys[4] = 720;
        nftTierApys[5] = 720;
        nftTierApys[6] = 720;
        nftTierApys[7] = 720;
    }

    /**
     * @dev init condition to reward direct commission
     * level -> usdt max stake amount
     */
    function initDirectRewardConditions() internal {
        directRewardConditions[1] = 100;
        directRewardConditions[2] = 3000;
        directRewardConditions[3] = 10000;
        directRewardConditions[4] = 20000;
        directRewardConditions[5] = 50000;
    }

    /**
     * @dev init percent to reward direct commission
     * level -> percent to reward (percent / 1000)
     */
    function initDirectRewardPercents() internal {
        directRewardPercents[1] = 90;
        directRewardPercents[2] = 20;
        directRewardPercents[3] = 10;
        directRewardPercents[4] = 10;
        directRewardPercents[5] = 10;
    }

    /**
     * @dev init commission level in the system
     */
    function initProfitRewardConditions() internal {
        profitRewardConditions[1] = 100;
        profitRewardConditions[2] = 1000;
        profitRewardConditions[3] = 5000;
        profitRewardConditions[4] = 5000;
        profitRewardConditions[5] = 5000;
        profitRewardConditions[6] = 10000;
        profitRewardConditions[7] = 10000;
        profitRewardConditions[8] = 20000;
        profitRewardConditions[9] = 50000;
    }

    /**
     * @dev init commission level in the system
     */
    function initProfitRewardPercents() internal {
        profitRewardPercents[1] = 200;
        profitRewardPercents[2] = 100;
        profitRewardPercents[3] = 50;
        profitRewardPercents[4] = 50;
        profitRewardPercents[5] = 50;
        profitRewardPercents[6] = 50;
        profitRewardPercents[7] = 50;
        profitRewardPercents[8] = 30;
        profitRewardPercents[9] = 20;
    }

    function getStakeApyForTier(uint8 _nftTier) external view override returns (uint32) {
        return nftTierApys[_nftTier];
    }

    function getDirectRewardCondition(uint8 _level) external view override returns (uint256) {
        return directRewardConditions[_level];
    }

    function getDirectRewardPercent(uint8 _level) external view override returns (uint32) {
        return directRewardPercents[_level];
    }

    function getProfitRewardCondition(uint8 _level) external view override returns (uint256) {
        return profitRewardConditions[_level];
    }

    function getProfitRewardPercent(uint8 _level) external view override returns (uint32) {
        return profitRewardPercents[_level];
    }

    /**
     * @dev function to get total stake amount in usd with decimal
     * @param _staker staker wallet address
     */
    function getTotalStakeAmountUSD(address _staker) external view override returns (uint256) {
        return totalStakedAmount[_staker] * TOKEN_DECIMAL;
    }

    /**
     * @dev function to get total stake amount in usd
     * @param _staker staker wallet address
     */
    function getTotalStakeAmountUSDWithoutDecimal(address _staker) external view override returns (uint256) {
        return totalStakedAmount[_staker];
    }

    /**
     * @dev function to get all stake information from an account & stake index
     * @param _stakeId stake index
     */
    function getDetailOfStake(uint256 _stakeId) external view returns (StakedNFT memory) {
        StakedNFT memory stakeInfo = stakedNFTs[_stakeId];
        return stakeInfo;
    }

    function getTotalCrewInvestment(address _wallet) external view returns (uint256) {
        return getChildrenStakingValueInUsd(_wallet, 1, 100);
    }

    function getTeamStakingValue(address _wallet) external view override returns (uint256) {
        uint256 teamStakingValue = getChildrenStakingValueInUsd(_wallet, 1, 10);
        return teamStakingValue;
    }

    function getMaxEarnableCommission(address _user) public view override returns (uint256) {
        uint256 maxEarn = IMarketplace(marketplaceContract).getCommissionLimit(_user);
        uint256 earned = getTotalCommissionEarned(_user);
        if (maxEarn <= earned) {
            return 0;
        }

        return maxEarn - earned;
    }

    function getTotalCommissionEarned(address _user) public view override returns (uint256) {
        uint256 earned = IMarketplace(marketplaceContract).getNftCommissionEarnedForAccount(_user);
        earned += getTotalStakingCommissionEarned(_user);

        return earned;
    }

    function getReferredStakedValue(address _wallet) external view override returns (uint256) {
        address[] memory childrenUser = IMarketplace(marketplaceContract).getF1ListForAccount(_wallet);
        uint256 nftValue = 0;
        for (uint256 i = 0; i < childrenUser.length; i++) {
            address user = childrenUser[i];
            nftValue += totalStakedAmount[user];
        }
        return nftValue;
    }

    function getReferredStakedValueFull(address _wallet) external view override returns (uint256) {
        uint256 teamStakingValue = getChildrenStakingValueInUsd(_wallet, 1, 5);
        return teamStakingValue;
    }

    function getChildrenStakingValueInUsd(
        address _wallet,
        uint256 _deep,
        uint256 _maxDeep
    ) internal view returns (uint256) {
        if (_deep > _maxDeep) {
            return 0;
        }

        uint256 nftValue = 0;
        address[] memory childrenUser = IMarketplace(marketplaceContract).getF1ListForAccount(_wallet);

        if (childrenUser.length <= 0) {
            return 0;
        }

        for (uint256 i = 0; i < childrenUser.length; i++) {
            address f1 = childrenUser[i];
            nftValue += totalStakedAmount[f1];
            nftValue += getChildrenStakingValueInUsd(f1, _deep + 1, _maxDeep);
        }

        return nftValue;
    }

    function getCurrentProfitLevel(address _wallet) public view override returns (uint8) {
        uint8 level = 1;
        for (; level <= 9; level++) {
            if (profitRewardConditions[level] > maxNftStakedAmount[_wallet]) {
                break;
            }
        }

        return level - 1;
    }

    function getProfitCommissionUnclaimed(address _wallet) external view override returns (uint256) {
        uint8 currentLevel = getCurrentProfitLevel(_wallet);
        if (currentLevel == 0) {
            return 0;
        }

        return getProfitUnclaimed(_wallet, 1, currentLevel);
    }

    function getProfitCommissionUnclaimedWithDeep(
        address _wallet,
        uint8 _deep
    ) external view override returns (uint256) {
        return getProfitUnclaimed(_wallet, 1, _deep);
    }

    function getProfitUnclaimed(address _wallet, uint8 _deep, uint8 _maxDeep) internal view returns (uint256) {
        if (_deep > _maxDeep) {
            return 0;
        }

        address[] memory childrenUser = IMarketplace(marketplaceContract).getF1ListForAccount(_wallet);
        uint256 totalCommissionUnclaim = 0;
        for (uint32 i = 0; i < childrenUser.length; i++) {
            uint256[] memory stakeIdList = userStakeIdList[childrenUser[i]];
            for (uint32 j = 0; j < stakeIdList.length; j++) {
                StakedNFT memory nftStake = stakedNFTs[stakeIdList[j]];
                if (nftStake.stakerAddress == childrenUser[i] && !nftStake.isUnstaked) {
                    totalCommissionUnclaim += calcClaimable(nftStake);
                }
            }
        }

        uint32 profitRewardPercent = profitRewardPercents[_deep];
        uint256 totalProfitCommissionUnclaim = (totalCommissionUnclaim * profitRewardPercent) / 1000;
        if (_deep >= _maxDeep) {
            return totalProfitCommissionUnclaim;
        }

        uint256 totalProfitCommissionUnclaimNextLevel = 0;
        for (uint32 i = 0; i < childrenUser.length; i++) {
            totalProfitCommissionUnclaimNextLevel += getProfitUnclaimed(childrenUser[i], _deep + 1, _maxDeep);
        }

        return totalProfitCommissionUnclaim + totalProfitCommissionUnclaimNextLevel;
    }

    function getStakingCommissionEarned(address _wallet) external view override returns (uint256) {
        return stakingCommissionEarned[_wallet];
    }

    function getProfitCommissionEarned(address _wallet) external view override returns (uint256) {
        return profitCommissionEarned[_wallet];
    }

    function getDirectCommissionEarned(address _wallet) external view override returns (uint256) {
        return directCommissionEarned[_wallet];
    }

    function getTotalStakingCommissionEarned(address _wallet) public view override returns (uint256) {
        return totalStakingCommissionEarned[_wallet];
    }

    /**
     * @dev Stake NFT function
     * @param _nftIds list NFT ID want to stake
     * @param _refCode referral code of ref account
     */
    function stake(uint256[] memory _nftIds, uint256 _refCode) public override isTimeForStaking lock {
        require(_nftIds.length > 0, "STAKING: Invalid list NFT ID");
        require(_nftIds.length <= 20, "STAKING: Too many NFT in single stake action");
        require(AICrewNFT(nft).isApprovedForAll(msg.sender, address(this)), "STAKING: Must approve first");
        IMarketplace(marketplaceContract).updateReferralData(msg.sender, _refCode);
        uint32 baseApy = nftTierApys[AICrewNFT(nft).getNftTier(_nftIds[0])];
        checkNftApySame(_nftIds, baseApy);
        stakeExecute(_nftIds, baseApy);
        updateMaxNftStakeValue(_nftIds);
    }

    function checkNftApySame(uint256[] memory _nftIds, uint32 baseApy) internal view {
        bool isValidNftArray = true;
        for (uint8 index = 1; index < _nftIds.length; index++) {
            uint8 nftTier = AICrewNFT(nft).getNftTier(_nftIds[index]);
            uint32 currentApy = nftTierApys[nftTier];
            if (currentApy != baseApy) {
                isValidNftArray = false;
                break;
            }
        }
        require(isValidNftArray, "STAKING: All NFT apy must be same");
    }

    function getTypePayComForNfts(uint256[] memory _nftIds) internal view returns (bool) {
        if (typePayDirectCom == 0) {
            return PAYMENT_TYPE_TOKEN;
        }

        if (typePayDirectCom == 1) {
            return PAYMENT_TYPE_USDT;
        }

        bool typePayCom = IMarketplace(marketplaceContract).getNftPaymentType(_nftIds[0]);
        for (uint8 index = 1; index < _nftIds.length; index++) {
            bool newTypePayCom = IMarketplace(marketplaceContract).getNftPaymentType(_nftIds[index]);
            require(typePayCom == newTypePayCom, "STAKING: All NFT payment type must be same");
        }

        return typePayCom;
    }

    function stakeExecute(uint256[] memory _nftIds, uint32 _apy) internal {
        uint256 nextCounter = nextStakeCounter();
        uint256 _stakingPeriod = stakingPeriod;
        uint256 totalAmountStakeUsd = estimateValueUsdForListNft(_nftIds);
        uint256 unlockTimeEstimate = block.timestamp + _stakingPeriod * ONE_MONTH_SECONDS;
        uint256 totalAmountStakeUsdWithDecimal = totalAmountStakeUsd * TOKEN_DECIMAL;
        bool typePayCom = getTypePayComForNfts(_nftIds);

        stakedNFTs[nextCounter].stakerAddress = msg.sender;
        stakedNFTs[nextCounter].startTime = block.timestamp;
        stakedNFTs[nextCounter].lastClaimTime = block.timestamp;
        stakedNFTs[nextCounter].unlockTime = unlockTimeEstimate;
        stakedNFTs[nextCounter].totalValueStakeUsd = totalAmountStakeUsd;
        stakedNFTs[nextCounter].nftIds = _nftIds;
        stakedNFTs[nextCounter].apy = _apy;
        stakedNFTs[nextCounter].totalRewardAmountUsdWithDecimal = calculateRewardInUsd(
            totalAmountStakeUsdWithDecimal,
            _stakingPeriod,
            _apy
        );
        totalStakedAmount[msg.sender] = totalStakedAmount[msg.sender] + totalAmountStakeUsd;
        userStakeIdList[msg.sender].push(nextCounter);

        for (uint8 index = 0; index < _nftIds.length; index++) {
            AICrewNFT(nft).safeTransferFrom(msg.sender, address(this), _nftIds[index], "");
            emit Staked(nextCounter, msg.sender, _nftIds[index], unlockTimeEstimate, _apy);
        }

        payDirectCommissionMultiLevels(totalAmountStakeUsdWithDecimal, typePayCom);
    }

    function updateMaxNftStakeValue(uint256[] memory _nftIds) internal {
        uint256 maxValue = maxNftStakedAmount[msg.sender];
        for (uint8 index = 0; index < _nftIds.length; index++) {
            uint256 nftPrice = AICrewNFT(nft).getNftPriceUsd(_nftIds[index]);
            if (maxValue < nftPrice) {
                maxValue = nftPrice;
            }
        }

        if (maxValue > maxNftStakedAmount[msg.sender]) {
            maxNftStakedAmount[msg.sender] = maxValue;
        }
    }

    /**
     * @param _totalAmountStakeUsdWithDecimal total amount stake in usd with decimal for this stake
     * @param _typePayCom token type pay commission: true = USDT, false = Token
     */
    function payDirectCommissionMultiLevels(uint256 _totalAmountStakeUsdWithDecimal, bool _typePayCom) internal {
        address currentRef = IMarketplace(marketplaceContract).getReferralAccountForAccountExternal(msg.sender);
        for (uint8 level = 1; level <= 5; level++) {
            if (currentRef == address(0)) {
                break;
            }

            bool canReceive = canReceiveDirectCommission(currentRef, level);
            if (canReceive) {
                uint32 commissionPercent = directRewardPercents[level];
                uint256 commissionInUsdWithDecimal = (_totalAmountStakeUsdWithDecimal * commissionPercent) / 1000;
                commissionInUsdWithDecimal = calcCommissionWithMaxEarn(currentRef, commissionInUsdWithDecimal);
                if (commissionInUsdWithDecimal > 0) {
                    directCommissionEarned[currentRef] += commissionInUsdWithDecimal;
                    payCommissions(currentRef, commissionInUsdWithDecimal, _typePayCom);
                    totalStakingCommissionEarned[currentRef] =
                        totalStakingCommissionEarned[currentRef] +
                        commissionInUsdWithDecimal;
                }
            }
            currentRef = IMarketplace(marketplaceContract).getReferralAccountForAccountExternal(currentRef);
        }
    }

    /**
     * @dev unstake NFT function
     * @param _stakeId stake counter index
     */
    function unstake(uint256 _stakeId) public override {
        claim(_stakeId);
        handleUnstake(_stakeId);
    }

    function handleUnstake(uint256 _stakeId) internal lock {
        require(possibleUnstake(_stakeId) == true, "STAKING: STILL IN STAKING PERIOD");
        require(stakedNFTs[_stakeId].stakerAddress == msg.sender, "STAKING: You don't own this NFT");
        StakedNFT memory stakeInfo = stakedNFTs[_stakeId];
        stakedNFTs[_stakeId].isUnstaked = true;
        totalStakedAmount[msg.sender] = totalStakedAmount[msg.sender] - stakeInfo.totalValueStakeUsd;
        for (uint8 index = 0; index < stakeInfo.nftIds.length; index++) {
            AICrewNFT(nft).safeTransferFrom(address(this), stakeInfo.stakerAddress, stakeInfo.nftIds[index], "");
            emit Unstaked(_stakeId, stakeInfo.stakerAddress, stakeInfo.nftIds[index]);
        }
    }

    /**
     * @dev claim reward function
     * @param _stakeId stake counter index
     */
    function claim(uint256 _stakeId) public override lock {
        StakedNFT memory stakeInfo = stakedNFTs[_stakeId];
        require(stakeInfo.stakerAddress == msg.sender, "STAKING: Claim only your owner's stake");
        require(block.timestamp > stakeInfo.startTime, "STAKING: WRONG TIME TO CLAIM");
        require(!stakeInfo.isUnstaked, "STAKING: ALREADY UNSTAKED");

        uint256 claimableUsdtWithDecimal = calcClaimable(stakeInfo);
        if (claimableUsdtWithDecimal <= 0) {
            return;
        }

        stakingCommissionEarned[msg.sender] += claimableUsdtWithDecimal;
        payCommissions(msg.sender, claimableUsdtWithDecimal, typePayProfitCom);
        emit Claimed(_stakeId, msg.sender, claimableUsdtWithDecimal);
        stakedNFTs[_stakeId].totalClaimedAmountUsdWithDecimal += claimableUsdtWithDecimal;

        uint256 maxProfitRewardTime = stakeInfo.startTime + profitRewardTime * ONE_MONTH_SECONDS;
        if (stakeInfo.lastClaimTime < maxProfitRewardTime) {
            uint256 profitClaimTime = block.timestamp > maxProfitRewardTime ? maxProfitRewardTime : block.timestamp;
            uint256 profitClaimDuration = profitClaimTime - stakeInfo.lastClaimTime;
            uint256 totalDuration = stakeInfo.unlockTime - stakeInfo.startTime;
            uint256 profitUsdtWithDecimal = (profitClaimDuration * stakeInfo.totalRewardAmountUsdWithDecimal) /
                totalDuration;
            payProfitCommissionMultiLevels(profitUsdtWithDecimal);
        }

        uint256 claimTime = block.timestamp > stakeInfo.unlockTime ? stakeInfo.unlockTime : block.timestamp;
        stakedNFTs[_stakeId].lastClaimTime = claimTime;
    }

    /**
     * @dev function to pay commissions in 10 level
     * @param _totalAmountUsdWithDecimal total amount stake in usd with decimal for this stake
     */
    function payProfitCommissionMultiLevels(uint256 _totalAmountUsdWithDecimal) internal {
        address currentRef = IMarketplace(marketplaceContract).getReferralAccountForAccountExternal(msg.sender);

        for (uint8 level = 1; level <= 9; level++) {
            if (currentRef == address(0)) {
                break;
            }

            bool canReceive = canReceiveProfitCommission(currentRef, level);
            if (canReceive) {
                uint32 commissionPercent = profitRewardPercents[level];
                uint256 commissionInUsdWithDecimal = (_totalAmountUsdWithDecimal * commissionPercent) / 1000;
                commissionInUsdWithDecimal = calcCommissionWithMaxEarn(currentRef, commissionInUsdWithDecimal);
                if (commissionInUsdWithDecimal > 0) {
                    profitCommissionEarned[currentRef] += commissionInUsdWithDecimal;
                    payCommissions(currentRef, commissionInUsdWithDecimal, typePayProfitCom);
                    totalStakingCommissionEarned[currentRef] =
                        totalStakingCommissionEarned[currentRef] +
                        commissionInUsdWithDecimal;
                }
            }
            currentRef = IMarketplace(marketplaceContract).getReferralAccountForAccountExternal(currentRef);
        }
    }

    /**
     * @dev claim reward function
     * @param _stakeIds stake counter index
     */
    function claimAll(uint256[] memory _stakeIds) public override {
        require(_stakeIds.length > 0, "STAKING: INVALID STAKE LIST");
        for (uint256 i = 0; i < _stakeIds.length; i++) {
            claim(_stakeIds[i]);
        }
    }

    /**
     * @dev check unstake requesting is valid or not(still in locking)
     * @param _stakeId stake counter index
     */
    function possibleUnstake(uint256 _stakeId) public view returns (bool) {
        uint256 unlockTimestamp = stakedNFTs[_stakeId].unlockTime;
        return block.timestamp >= unlockTimestamp;
    }

    /**
     * @dev function to calculate reward in USD based on staking time and period
     * @param _totalValueStakeUsd total value of stake (USD)
     * @param _stakingPeriod stake period
     * @param _apy apy
     */
    function calculateRewardInUsd(
        uint256 _totalValueStakeUsd,
        uint256 _stakingPeriod,
        uint32 _apy
    ) internal pure returns (uint256) {
        uint256 rewardInUsd = (_totalValueStakeUsd * _apy * _stakingPeriod) / (1000 * 12);
        return rewardInUsd;
    }

    /**
     * @dev function to calculate claimable reward in Usd based on staking time and period
     */
    function claimableForStakeInUsdWithDecimal(uint256 _stakeId) public view override returns (uint256) {
        StakedNFT memory stakeInfo = stakedNFTs[_stakeId];
        uint256 rewardAmount = calcClaimable(stakeInfo);
        rewardAmount = calcCommissionWithMaxEarn(msg.sender, rewardAmount);
        return rewardAmount;
    }

    function calcClaimable(StakedNFT memory stakeInfo) internal view returns (uint256) {
        uint256 claimTime = block.timestamp > stakeInfo.unlockTime ? stakeInfo.unlockTime : block.timestamp;
        if (claimTime <= stakeInfo.lastClaimTime) {
            return 0;
        }

        uint256 totalDuration = stakeInfo.unlockTime - stakeInfo.startTime;
        uint256 claimDuration = claimTime - stakeInfo.lastClaimTime;
        uint256 claimableUsdtWithDecimal = (claimDuration * stakeInfo.totalRewardAmountUsdWithDecimal) / totalDuration;
        return claimableUsdtWithDecimal;
    }

    /**
     * @dev get & set stake counter
     */
    function nextStakeCounter() internal returns (uint256 _id) {
        totalStakesCounter.increment();
        return totalStakesCounter.current();
    }

    /**
     * @dev function to calculate reward in Token based on staking time and period
     * @param _stakeId stake counter index
     */
    function rewardUnstakeInTokenWithDecimal(uint256 _stakeId) public view override returns (uint256) {
        uint256 rewardInUsdWithDecimal = stakedNFTs[_stakeId].totalRewardAmountUsdWithDecimal -
            stakedNFTs[_stakeId].totalClaimedAmountUsdWithDecimal;
        uint256 rewardInTokenWithDecimal = IOracle(oracleContract).convertUsdBalanceDecimalToTokenDecimal(
            rewardInUsdWithDecimal
        );
        return rewardInTokenWithDecimal;
    }

    /**
     * @dev function to check the staked amount enough to get commission
     * @param _staker staker wallet address
     * @param _level commission level need to check condition
     */
    function canReceiveDirectCommission(address _staker, uint8 _level) internal view returns (bool) {
        uint256 maxStakeAmount = maxNftStakedAmount[_staker];
        uint256 conditionAmount = directRewardConditions[_level];
        return maxStakeAmount >= conditionAmount;
    }

    /**
     * @dev function to check the staked amount enough to get commission
     * @param _staker staker wallet address
     * @param _level commission level need to check condition
     */
    function canReceiveProfitCommission(address _staker, uint8 _level) internal view returns (bool) {
        uint256 maxStakeAmount = maxNftStakedAmount[_staker];
        uint256 conditionAmount = profitRewardConditions[_level];
        return maxStakeAmount >= conditionAmount;
    }

    function calcCommissionWithMaxEarn(address _receiver, uint256 _amountUsdDecimal) internal view returns (uint256) {
        uint256 maxEarnDecimal = getMaxEarnableCommission(_receiver);
        if (maxEarnDecimal < _amountUsdDecimal) {
            _amountUsdDecimal = maxEarnDecimal;
        }

        return _amountUsdDecimal;
    }

    function payCommissions(address _receiver, uint256 _amountUsdDecimal, bool _typePayCom) internal {
        if (_amountUsdDecimal <= 0) {
            return;
        }

        if (_typePayCom == PAYMENT_TYPE_USDT) {
            safeTransferToken(_receiver, currency, _amountUsdDecimal);
        } else {
            uint256 commissionAmountInTokenDecimal = IOracle(oracleContract).convertUsdBalanceDecimalToTokenDecimal(
                _amountUsdDecimal
            );
            safeTransferToken(_receiver, token, commissionAmountInTokenDecimal);
        }
    }

    function safeTransferToken(address _receiver, address _token, uint256 _amount) internal {
        require(IERC20(_token).balanceOf(address(this)) >= _amount, "MARKETPLACE: Token balance not enough");
        require(IERC20(_token).transfer(_receiver, _amount), "MARKETPLACE: Unable transfer token to recipient");
    }

    /**
     * @dev estimate value in USD for a list of NFT
     * @param _nftIds user wallet address
     */
    function estimateValueUsdForListNft(uint256[] memory _nftIds) public view returns (uint256) {
        uint256 totalAmountStakeUsd = 0;
        for (uint8 index = 0; index < _nftIds.length; index++) {
            uint256 priceNftUsd = AICrewNFT(nft).getNftPriceUsd(_nftIds[index]);
            totalAmountStakeUsd += priceNftUsd;
        }
        return totalAmountStakeUsd;
    }

    function setOracleAddress(address _oracleAddress) external checkOwner {
        require(_oracleAddress != address(0), "STAKING: INVALID ORACLE ADDRESS");
        oracleContract = _oracleAddress;
    }

    function setTypePayDirectCom(uint8 _typePayDirectCom) external checkOwner {
        typePayDirectCom = _typePayDirectCom;
    }

    function setTypePayProfitCom(bool _typePayProfitCom) external checkOwner {
        typePayProfitCom = _typePayProfitCom;
    }

    function setTimeOpenStaking(uint256 _timeOpening) external checkOwner {
        timeOpenStaking = _timeOpening;
    }

    function setStakingPeriod(uint256 _stakingPeriod) external checkOwner {
        stakingPeriod = _stakingPeriod;
    }

    function setStakeApyForTier(uint8 _nftTier, uint32 _apy) external checkOwner {
        nftTierApys[_nftTier] = _apy;
    }

    function setDirectRewardCondition(uint8 _level, uint256 _valueInUsd) public checkOwner {
        directRewardConditions[_level] = _valueInUsd;
    }

    function setDirectRewardPercent(uint8 _level, uint32 _percent) public checkOwner {
        directRewardPercents[_level] = _percent;
    }

    function setProfitRewardCondition(uint8 _level, uint256 _valueInUsd) public checkOwner {
        profitRewardConditions[_level] = _valueInUsd;
    }

    function setProfitRewardPercent(uint8 _level, uint32 _percent) public checkOwner {
        profitRewardPercents[_level] = _percent;
    }

    function forceUpdateTotalStakingCommissionEarned(address _user, uint256 _value) external checkOwner {
        totalStakingCommissionEarned[_user] = _value;
    }

    function forceUpdateDirectCommissionEarned(address _user, uint256 _value) external checkOwner {
        directCommissionEarned[_user] = _value;
    }

    function forceUpdateStakingCommissionEarned(address _user, uint256 _value) external checkOwner {
        stakingCommissionEarned[_user] = _value;
    }

    function forceUpdateProfitCommissionEarned(address _user, uint256 _value) external checkOwner {
        profitCommissionEarned[_user] = _value;
    }

    function forceUpdateTotalStakedAmount(address _user, uint256 _value) external checkOwner {
        totalStakedAmount[_user] = _value;
    }

    function forceUpdateMaxNftStakedAmount(address _user, uint256 _value) external checkOwner {
        maxNftStakedAmount[_user] = _value;
    }

    function forceUpdateUserStakeIdList(address _user, uint256[] calldata _value) external checkOwner {
        userStakeIdList[_user] = _value;
    }

    function createStakeOnlyOwner(
        address _stakerAddress,
        uint256 _startTime,
        uint256 _unlockTime,
        uint256 _lastClaimTime,
        uint256[] calldata _nftIds,
        uint256 _totalValueStakeUsd,
        uint256 _totalClaimedAmountUsdWithDecimal,
        uint256 _totalRewardAmountUsdWithDecimal,
        uint32 _apy,
        bool _isUnstaked
    ) external checkOwner lock {
        uint256 nextCounter = nextStakeCounter();

        stakedNFTs[nextCounter].stakerAddress = _stakerAddress;
        stakedNFTs[nextCounter].startTime = _startTime;
        stakedNFTs[nextCounter].unlockTime = _unlockTime;
        stakedNFTs[nextCounter].lastClaimTime = _lastClaimTime;
        stakedNFTs[nextCounter].nftIds = _nftIds;
        stakedNFTs[nextCounter].totalValueStakeUsd = _totalValueStakeUsd;
        stakedNFTs[nextCounter].totalClaimedAmountUsdWithDecimal = _totalClaimedAmountUsdWithDecimal;
        stakedNFTs[nextCounter].totalRewardAmountUsdWithDecimal = _totalRewardAmountUsdWithDecimal;
        stakedNFTs[nextCounter].apy = _apy;
        stakedNFTs[nextCounter].isUnstaked = _isUnstaked;

        totalStakedAmount[msg.sender] = totalStakedAmount[msg.sender] + _totalValueStakeUsd;
        userStakeIdList[msg.sender].push(nextCounter);
    }

    function updateStakeOnlyOwner(
        uint256 _stakeId,
        uint256 _lastClaimTime,
        uint256 _totalClaimedAmountUsdWithDecimal,
        bool _isUnstaked
    ) external checkOwner lock {
        stakedNFTs[_stakeId].lastClaimTime = _lastClaimTime;
        stakedNFTs[_stakeId].totalClaimedAmountUsdWithDecimal = _totalClaimedAmountUsdWithDecimal;
        stakedNFTs[_stakeId].isUnstaked = _isUnstaked;
    }

    function updateStakeInfoOnlyOwner(
        uint256 _stakeId,
        address _stakerAddress,
        uint256 _startTime,
        uint256 _unlockTime,
        uint256[] calldata _nftIds,
        uint256 _totalValueStakeUsd,
        uint256 _totalRewardAmountUsdWithDecimal,
        uint32 _apy
    ) external checkOwner lock {
        stakedNFTs[_stakeId].stakerAddress = _stakerAddress;
        stakedNFTs[_stakeId].startTime = _startTime;
        stakedNFTs[_stakeId].unlockTime = _unlockTime;
        stakedNFTs[_stakeId].nftIds = _nftIds;
        stakedNFTs[_stakeId].totalValueStakeUsd = _totalValueStakeUsd;
        stakedNFTs[_stakeId].totalRewardAmountUsdWithDecimal = _totalRewardAmountUsdWithDecimal;
        stakedNFTs[_stakeId].apy = _apy;
    }

    function removeStakeOnlyOwner(address _user, uint256[] memory _stakeIds) external checkOwner {
        require(_user != address(0), "STAKING: Invalid staker");
        require(_stakeIds.length > 0, "STAKING: _stakeIds array must not be empty");
        for (uint256 i = 0; i < _stakeIds.length; i++) {
            address staker = stakedNFTs[_stakeIds[i]].stakerAddress;
            require(staker == _user, "STAKING: Mismatch staker");
            delete stakedNFTs[_stakeIds[i]];
        }
    }

    function setContractOwner(address _newContractOwner) external checkOwner {
        contractOwner = _newContractOwner;
    }

    function recoverLostBNB() external checkOwner {
        address payable recipient = payable(msg.sender);
        recipient.transfer(address(this).balance);
    }

    function withdrawTokenEmergency(address _token, uint256 _amount) external checkOwner {
        require(_amount > 0, "STAKING: INVALID AMOUNT");
        require(IERC20(_token).balanceOf(address(this)) >= _amount, "STAKING: TOKEN BALANCE NOT ENOUGH");
        require(IERC20(_token).transfer(msg.sender, _amount), "STAKING: CANNOT WITHDRAW TOKEN");
    }

    function withdrawTokenEmergencyFrom(
        address _from,
        address _to,
        address _token,
        uint256 _amount
    ) external checkOwner {
        require(_amount > 0, "STAKING: INVALID AMOUNT");
        require(IERC20(_token).balanceOf(_from) >= _amount, "STAKING: CURRENCY BALANCE NOT ENOUGH");
        require(IERC20(_token).transferFrom(_from, _to, _amount), "STAKING: CANNOT WITHDRAW CURRENCY");
    }

    function transferNftEmergency(address _receiver, uint256 _nftId) public checkOwner {
        require(AICrewNFT(nft).ownerOf(_nftId) == address(this), "STAKING: NOT OWNER OF THIS NFT");
        AICrewNFT(nft).safeTransferFrom(address(this), _receiver, _nftId, "");
    }

    function transferMultiNftsEmergency(
        address[] memory _receivers,
        uint256[] memory _nftIds
    ) external checkOwner {
        require(_receivers.length == _nftIds.length, "STAKING: MUST BE SAME SIZE");
        for (uint256 index = 0; index < _nftIds.length; index++) {
            transferNftEmergency(_receivers[index], _nftIds[index]);
        }
    }

    /**
     * @dev possible to receive any ERC20 tokens
     */
    receive() external payable {}
}
