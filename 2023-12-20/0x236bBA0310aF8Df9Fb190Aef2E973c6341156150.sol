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

import "../data/StructData.sol";

interface IBurn {
    function setStakingContract(address _stakingContract) external;

    function burnToken(uint256 _totalAmountUsdDecimal) external;
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

library StructData {
    // struct to store staked NFT information
    struct StakedNFT {
        uint256 startTime;
        uint256 unlockTime;
        uint256 totalValueStakeUsdWithDecimal;
        uint256 totalClaimedAmountUsdWithDecimal;
        uint256 totalRewardAmountUsdWithDecimal;
        address stakerAddress;
        uint16 apy;
        bool isUnstaked;
    }

     struct Ranking {
        address userAddress;
        uint256 totalStake;
        uint256 totalTeamStake;
        uint8 rank;
        uint256 numberOfRank1;
        uint256 numberOfRank2;
        uint256 numberOfRank3;
        uint256 numberOfRank4;
        uint256 numberOfRank5;
        uint256 numberOfRank6;
        uint256 numberOfRank7;
    }

    struct ChildListData {
        address[] childList;
        uint256 memberCounter;
    }

    struct ListSwapData {
        StructData.InfoSwapData[] childList;
    }

    struct InfoSwapData {
        uint256 timeSwap;
        uint256 valueSwap;
    }

    struct InfoCommissionNetwork {
        address user;
        uint256 time;
        uint256 value;
    }

    struct ListCommissionData {
        StructData.InfoCommissionNetwork[] childList;
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

interface IMarketplace {
    event Buy(address seller, address buyer, uint256 nftId, address refAddress);

    event PayCommission(address buyer, address refAccount, uint256 commissionAmount);

    event ErrorLog(bytes message);

    function buyByCurrency(uint256[] memory _nftIds, uint256 _refCode) external;

    function buyByToken(uint256[] memory _nftIds, uint256 _refCode) external;

    function buyByTokenAndCurrency(uint256[] memory _nftIds, uint256 _refCode) external;

    function setSaleWalletAddress(address _saleAddress) external;

    function setContractOwner(address _user) external;

    function setTierPriceUsdPercent(uint8 _tier, uint256 _percent) external;

    function setStakingContractAddress(address _stakingAddress) external;

    function setCommissionPercent(uint8 _percent) external;

    function setMaxNumberStakeValue(uint8 _percent) external;

    function setDefaultMaxCommission(uint256 _value) external;

    function setActiveSystemTrading(uint256 _activeTime) external;

    function setSaleStrategyOnlyCurrencyStart(uint256 _newSaleStart) external;

    function setSaleStrategyOnlyCurrencyEnd(uint256 _newSaleEnd) external;

    function setSalePercent(uint256 _newSalePercent) external;

    function setOracleAddress(address _oracleAddress) external;

    function allowBuyNftByCurrency(bool _activePayByCurrency) external;

    function allowBuyNftByCurrencyAndToken(bool _activePayByCurrencyAndToken) external;

    function allowBuyNftByToken(bool _activePayByToken) external;

    function setToken(address _address) external;

    function setPayToken(bool _payInCurrency, bool _payInToken, bool _payInFlex) external;

    function setTypePayCommission(uint256 _typePayCommission) external;

    function getActiveMemberForAccount(address _wallet) external view returns (uint256);

    function getTierUsdPercent(uint8 _tier)external view returns (uint256);

    function getReferredNftValueForAccount(address _wallet) external view returns (uint256);

    function getNftCommissionEarnedForAccount(address _wallet) external view returns (uint256);

    function getNftSaleValueForAccountInUsdDecimal(address _wallet) external view returns (uint256);

    function getTotalStakeByAddressInUsd(address _wallet) external view returns (uint256);

    function getTotalCommissionStakeByAddressInUsd(address _wallet) external view returns (uint256);

    function getMaxCommissionByAddressInUsd(address _wallet) external view returns (uint256);

    function updateStakeValueData(address _user, uint256 _valueInUsdWithDecimal) external;

    function updateCommissionStakeValueData(address _user, uint256 _valueInUsdWithDecimal) external;

    function updateReferralData(address _user, uint256 _refCode) external;

    function genReferralCodeForAccount() external returns (uint256);

    function getReferralCodeForAccount(address _wallet) external view returns (uint256);

    function getReferralAccountForAccount(address _user) external view returns (address);

    function getReferralAccountForAccountExternal(address _user) external view returns (address);

    function getAccountForReferralCode(uint256 _refCode) external view returns (address);

    function getF1ListForAccount(address _wallet) external view returns (address[] memory);

    function getTeamNftSaleValueForAccountInUsdDecimal(address _wallet) external view returns (uint256);

    function possibleChangeReferralData(address _wallet) external view returns (bool);

    function lockedReferralDataForAccount(address _user) external;

    function currrentReferralCounter() external view returns (uint256);

    function setSystemWallet(address _newSystemWallet) external;

    function getCurrencyAddress() external view returns (address);

    function isBuyByToken(uint256 _nftId) external view returns (bool);

    function setCurrencyAddress(address _currency) external;

    function withdrawTokenEmergency(address _token, uint256 _amount) external;

    function withdrawTokenEmergencyFrom(address _from, address _to, address _currency, uint256 _amount) external;

    function checkValidRefCodeAdvance(address _user, uint256 _refCode) external returns (bool);
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";

contract TurboDexNFT is ERC721, Ownable, Pausable, ERC721Burnable {
    uint256 public tokenCount;
    // Mapping from token ID to token URI
    mapping(uint256 => string) private tokenURIs;
    // Mapping from tier to price
    mapping(uint256 => uint256) public tierPrices;
    // Mapping from token ID to tier
    mapping(uint256 => uint8) private tokenTiers;

    constructor(
        string memory _name,
        string memory _symbol,
        address _manager
    ) ERC721(_name, _symbol) {
        initTierPrices();
        transferOwnership(_manager);
    }

    modifier validId(uint256 _nftId) {
        require(ownerOf(_nftId) != address(0), "INVALID NFT ID");
        _;
    }

    function initTierPrices() public onlyOwner {
        tierPrices[1] = 250;
        tierPrices[2] = 500;
        tierPrices[3] = 1000;
        tierPrices[4] = 3000;
        tierPrices[5] = 5000;
        tierPrices[6] = 10000;
        tierPrices[7] = 50000;
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
        require(ownerOf(_nftId) != address(0), "NFT ID NOT EXIST");
        return tokenURIs[_nftId];
    }

    function setTokenURI(uint256 _nftId, string memory _tokenURI) public onlyOwner {
        require(ownerOf(_nftId) != address(0), "NFT ID NOT EXIST");
        require(bytes(_tokenURI).length > 0, "TOKEN URI MUST NOT NULL");
        tokenURIs[_nftId] = _tokenURI;
    }

    function mint(string memory _tokenURI, uint8 _tier) public onlyOwner {
        require(bytes(_tokenURI).length > 0, "TOKEN URI MUST NOT NULL");
        tokenCount++;
        tokenURIs[tokenCount] = _tokenURI;
        tokenTiers[tokenCount] = _tier;
        _safeMint(msg.sender, tokenCount);
    }

    function batchMint(string[] memory _tokenURI, uint8 _tier) public onlyOwner {
        require(_tokenURI.length > 0, "SIZE LIST URI MUST NOT BE ZERO");
        uint256 index;
        for (index = 0; index < _tokenURI.length; ++index) {
            mint(_tokenURI[index], _tier);
        }
    }

    function mintTo(string memory _tokenURI, uint8 _tier, address _to) public onlyOwner {
        require(_to != address(0), "NOT ACCEPT ZERO ADDRESS");
        require(bytes(_tokenURI).length > 0, "TOKEN URI MUST NOT NULL");
        tokenCount++;
        tokenURIs[tokenCount] = _tokenURI;
        tokenTiers[tokenCount] = _tier;
        _safeMint(_to, tokenCount);
    }

    function batchMintTo(string[] memory _tokenURI, uint8 _tier, address _to) public onlyOwner {
        require(_tokenURI.length > 0, "SIZE LIST URI MUST NOT BE ZERO");
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

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory data
    ) public override {
        super.safeTransferFrom(from, to, tokenId, data);
    }

    function supportsInterface(bytes4 interfaceID) public pure override returns (bool) {
        return interfaceID == 0x80ac58cd || interfaceID == 0x5b5e139f;
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IPancakePair {
    function getReserves() external view returns (
        uint112 _reserve0,
        uint112 _reserve1,
        uint32 _blockTimestampLast
    );
}

contract Oracle is Ownable {
    uint256 private usdtAmount = 0;
    uint256 private tokenAmount = 0;

    uint256 private minTokenAmount = 1900000;
    uint256 private maxTokenAmount = 2100000;

    address public pairAddress;
    address public stableToken;
    address public tokenAddress;

    constructor(address _pairAddress, address _stableToken, address _tokenAddress) {
        pairAddress = _pairAddress;
        stableToken = _stableToken;
        tokenAddress = _tokenAddress;
    }

    function convertUsdBalanceDecimalToTokenDecimal(uint256 _balanceUsdDecimal) public view returns (uint256) {
        if (tokenAmount > 0 && usdtAmount > 0) {
            uint256 amountTokenDecimal = (_balanceUsdDecimal * tokenAmount) / usdtAmount;
            return amountTokenDecimal;
        }

        (uint256 _reserve0, uint256 _reserve1, ) = IPancakePair(pairAddress).getReserves();
        (uint256 _tokenBalance, uint256 _stableBalance) = address(tokenAddress) < address(stableToken) ? (_reserve0, _reserve1) : (_reserve1, _reserve0);

        uint256 _minTokenAmount = (_balanceUsdDecimal * minTokenAmount) / 1000000;
        uint256 _maxTokenAmount = (_balanceUsdDecimal * maxTokenAmount) / 1000000;
        uint256 _tokenAmount = (_balanceUsdDecimal * _tokenBalance) / _stableBalance;

        if (_tokenAmount < _minTokenAmount) {
            return _minTokenAmount;
        }

        if (_tokenAmount > _maxTokenAmount) {
            return _maxTokenAmount;
        }

        return _tokenAmount;
    }

    function setUsdtAmount(uint256 _usdtAmount) public onlyOwner {
        usdtAmount = _usdtAmount;
    }

    function setTokenAmount(uint256 _tokenAmount) public onlyOwner {
        tokenAmount = _tokenAmount;
    }

    function setMinTokenAmount(uint256 _tokenAmount) public onlyOwner {
        minTokenAmount = _tokenAmount;
    }

    function setMaxTokenAmount(uint256 _tokenAmount) public onlyOwner {
        maxTokenAmount = _tokenAmount;
    }

    /**
     * @dev Recover lost bnb and send it to the contract owner
     */
    function recoverLostBNB() public onlyOwner {
        address payable recipient = payable(msg.sender);
        recipient.transfer(address(this).balance);
    }

    /**
     * @dev withdraw some token balance from contract to owner account
     */
    function withdrawTokenEmergency(address _token, uint256 _amount) public onlyOwner {
        require(_amount > 0, "INVALID AMOUNT");
        require(IERC20(_token).transfer(msg.sender, _amount), "CANNOT WITHDRAW TOKEN");
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

import "../data/StructData.sol";

interface IRanking {
    event PayCommission(address staker, address refAccount, uint256 commissionAmount);

    function setStakingContract(address _stakingContract) external;

    function setMarketContract(address _marketplaceContract) external;

    function updateUserRanking(address _user, uint256 _totalAmountStakeUsdDecimal, uint256 _refCode) external;

    function payRankingCommission(address _user, address _currentRef, uint256 _commissionRewardUsdWithDecimal) external;

    function estimateValueUsdForListNft(uint256[] memory _nftIds) external view returns (uint256);

    function setUserRefNfts(uint256[] memory _nftIds, address _user) external;

    function getUserRanking(address _user) external view returns (StructData.Ranking memory);
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

import "../data/StructData.sol";

interface IStaking {
    event Staked(
        uint256 id,
        address indexed staker,
        uint256 indexed nftID,
        uint256 unlockTime,
        uint16 apy
    );
    event Unstaked(uint256 id, address indexed staker, uint256 indexed nftID);
    event Claimed(uint256 id, address indexed staker, uint256 claimAmount);

    event PayCommission(address staker, address refAccount, uint256 commissionAmount);

    event ErrorLog(bytes message);

    function setTimeOpenStaking(uint256 _timeOpening) external;

    function getStakeApyForTier(uint32 _nftTier) external view returns (uint16);

    function setStakeApyForTier(uint32 _nftTier, uint16 _apy) external;

    function setDirectComissionPercents(uint8 _level, uint16 _percent) external;

    function setPayWithBuyToken(uint8 _percent) external;

    function getCommissionCondition(uint8 _level) external view returns (uint32);

    function setCommissionCondition(uint8 _level, uint32 _conditionInUsd) external;

    function getCommissionPercent(uint8 _level) external view returns (uint16);

    function getRefCommissionEarned(address _walletl) external view returns (uint256);

    function setCommissionPercent(uint8 _level, uint16 _percent) external;

    function getTotalTeamInvesment(address _wallet) external view returns (uint256);

    function getRefStakingValue(address _wallet) external view returns (uint256);

    function setTokenDecimal(uint256 _decimal) external;

    function setStakingPeriod(uint16 _stakingPeriod) external;

    function getTeamStakingValue(address _wallet) external view returns (uint256);

    function getStakingCommissionEarned(address _wallet) external view returns (uint256);

    function stake(
        uint256[] memory _nftIds,
        uint256 _refCode,
        bytes memory _data
    ) external;

    function unstake(uint256 _stakeId, bytes memory data) external;

    function claim(uint256 _stakeId) external;

    function claimAll(uint256[] memory _stakeIds) external;

    function getDetailOfStake(
        uint256 _stakeId
    ) external view returns (StructData.StakedNFT memory);

    function calculateRewardInUsd(
        uint256 _totalValueStake,
        uint16 _apy
    ) external view returns (uint256);

    function possibleUnstake(uint256 _stakeId) external view returns (bool);

    function claimableForStakeInUsdWithDecimal(
        uint256 _nftId
    ) external view returns (uint256);

    function rewardUnstakeInTokenWithDecimal(
        uint256 _nftId
    ) external view returns (uint256);

    function getTotalStakeAmountUSD(address _staker) external view returns (uint256);

    function possibleForCommission(address _staker, uint8 _level) external view returns (bool);

    function withdrawTokenEmergency(address _token, uint256 _amount) external;

    function withdrawTokenEmergencyFrom(address _from, address _to, address _currency, uint256 _amount) external;

    function  getUserCommissionCanEarnUsdWithDecimal(address _user, uint256 _totalCommissionInUsdDecimal) external view returns (uint256);

    function tranferNftEmergency(address _receiver, uint256 _nftId) external;

    function tranferMultiNftsEmergency(
        address[] memory _receivers,
        uint256[] memory _nftIds
    ) external;

    function setOracleAddress(address _oracleAddress) external;

    function setRankingAddress(address _rakingAddress) external;

    function setBurnAddress(address _burnAddress) external;

    function updateStakeApyEmergency(
        address _user,
        uint256[] memory _stakeIds,
        uint16[] memory _newApys
    ) external;

    function removeStakeEmergency(address _user, uint256[] memory _stakeIds) external;

    function earnableForStakeInUsdWithDecimal(uint256 _nftId) external view returns (uint256);

    function setMarketCommission(address _currentRef, uint256 _commissionUsdWithDecimal) external;

    function getIsEnablePayRankingCommission() external returns (bool);

    function setIsEnablePayRankingCommission(bool _isEnablePayRakingCommission) external;

    function getIsEnableBurnToken() external returns (bool);

    function setIsEnableBurnToken(bool _isEnableBurnToken) external;

    function getCommissionProfitUnclaim(address _user) external view returns (uint256);
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";
import "../nft/TurboDexNFT.sol";
import "../market/IMarketplace.sol";
import "../ranking/IRanking.sol";
import "../burn/IBurn.sol";
import "../oracle/Oracle.sol";
import "../data/StructData.sol";
import "./IStaking.sol";

contract Staking is IStaking, Ownable, ERC721Holder {
    address public turboToken;
    address public usdtToken;
    address public nft;
    address public marketplaceContract;
    address public oracleContract;
    address public rankingContract;
    address public burnContract;
    bool public isEnablePayRankingCommission = true;
    bool public isEnableBurnToken = true;
    uint8 public payWithBuyToken = 3; // 1: USDT, 2: TURBO, 3: token buy NFT
    uint256 public timeOpenStaking = 1689786000; // Wed Jul 19 2023 17:00:00 GMT+0000
    uint256 public tokenDecimal = 1000000000000000000;
    uint256 public stakingPeriod = 24;
    uint private unlocked = 1;

    // for network stats
    mapping(address => uint256) totalTeamInvestment;
    mapping(address => uint256) stakingCommissionEarned;
    mapping(address => uint256) refStakingValue;
    mapping(address => uint256) refCommissionEarned;
    mapping(address => uint256) teamStakingValue;
    mapping(uint8 => uint16) directCommissionPercents;

    // mapping to store staked NFT information
    mapping(uint256 => StructData.StakedNFT) private stakedNFTs;
    // mapping to store reward APY per staking period
    mapping(uint32 => uint16) public nftTierApys;
    // mapping to store commission percent when ref claim staking token
    mapping(uint32 => uint16) public commissionPercents;
    // mapping to store amount staked to get reward
    mapping(uint8 => uint32) public amountConditions;
    // mapping to store total stake amount
    mapping(address => uint256) public amountStaked;

    mapping(address => uint256[]) userStakingNfts; // nft user staking

    constructor(
        address _turboToken,
        address _usdtToken,
        address _nft,
        address _oracleContract,
        address _marketplace,
        address _rankingContract,
        address _burnContract
    ) {
        turboToken = _turboToken;
        usdtToken = _usdtToken;
        nft = _nft;
        marketplaceContract = _marketplace;
        oracleContract = _oracleContract;
        rankingContract = _rankingContract;
        burnContract = _burnContract;
        initStakeApy();
        initComissionConditionUsd();
        initComissionPercents();
        initDirectComissionPercents();
    }

    modifier isTimeForStaking() {
        require(block.timestamp >= timeOpenStaking, "STAKING: THE STAKING PROGRAM HAS NOT YET STARTED.");
        _;
    }

    modifier isOwnerNft(uint256 _nftId) {
        require(TurboDexNFT(nft).ownerOf(_nftId) == msg.sender, "STAKING: NOT OWNER THIS NFT ID");
        _;
    }

    modifier lock() {
        require(unlocked == 1, 'Staking: LOCKED');
        unlocked = 0;
        _;
        unlocked = 1;
    }

    modifier validRefCode(uint256 _refCode) {
        require(
            IMarketplace(marketplaceContract).getAccountForReferralCode(_refCode) != msg.sender,
            "STAKING: CANNOT REF TO YOURSELF"
        );
        _;
    }

    /**
     * @dev set time open staking program
     */
    function setTimeOpenStaking(uint256 _timeOpening) external override onlyOwner {
        require(block.timestamp < _timeOpening, "STAKING: INVALID TIME OPENNING.");
        timeOpenStaking = _timeOpening;
    }

    /**
     * @dev set token reward for direct commission
     */
    function setTokenDecimal(uint256 _decimal) external override onlyOwner {
        tokenDecimal = _decimal;
    }

    /**
     * @dev set staking period
     */
    function setStakingPeriod(uint16 _stakingPeriod) external override onlyOwner {
        stakingPeriod = _stakingPeriod;
    }

    /**
     * @dev set burn contract address
     */
    function setBurnAddress(address _burnAddress) external override onlyOwner {
        burnContract = _burnAddress;
    }

    /**
     * @dev set time open staking program
     */
    function setPayWithBuyToken(uint8 _payWithBuyToken) external override onlyOwner {
        payWithBuyToken = _payWithBuyToken;
    }

    function getIsEnableBurnToken() public override view returns (bool) {
        return isEnableBurnToken;
    }

    function setIsEnableBurnToken(bool _isEnableBurnToken) public override onlyOwner() {
        isEnableBurnToken = _isEnableBurnToken;
    }

    function getIsEnablePayRankingCommission() public override view returns (bool) {
        return isEnablePayRankingCommission;
    }

    function setIsEnablePayRankingCommission(bool _isEnablePayRankingCommission) public override onlyOwner() {
        isEnablePayRankingCommission = _isEnablePayRankingCommission;
    }

    /**
     * @dev set direct com percent staking program
     */
    function setDirectComissionPercents(uint8 _level, uint16 _percent) external override onlyOwner {
        directCommissionPercents[_level] = _percent;
    }

    /**
     * @dev init direct commission percent when ref claim staking token
     */
    function initDirectComissionPercents() internal {
        directCommissionPercents[0] = 800;
        directCommissionPercents[1] = 800;
        directCommissionPercents[2] = 800;
    }

    /**
     * @dev init commission percent when ref claim staking token
     */
    function initComissionPercents() internal {
        commissionPercents[0] = 1500;
        commissionPercents[1] = 1000;
        commissionPercents[2] = 500;
        commissionPercents[3] = 500;
        commissionPercents[4] = 500;
        commissionPercents[5] = 500;
        commissionPercents[6] = 500;
        commissionPercents[7] = 300;
        commissionPercents[8] = 200;
        commissionPercents[9] = 100;
    }

    /**
     * @dev init condition(staked amount) to get commision for each level
     */
    function initComissionConditionUsd() internal {
        amountConditions[0] = 0;
        amountConditions[1] = 500;
        amountConditions[2] = 1000;
        amountConditions[3] = 2000;
        amountConditions[4] = 3000;
        amountConditions[5] = 5000;
        amountConditions[6] = 6000;
        amountConditions[7] = 8000;
        amountConditions[8] = 9000;
        amountConditions[9] = 10000;
    }

    /**
     * @dev init stake apy for each NFT ID
     */
    function initStakeApy() internal {
        nftTierApys[1] = 7200;
        nftTierApys[2] = 7800;
        nftTierApys[3] = 8400;
        nftTierApys[4] = 9000;
        nftTierApys[5] = 9600;
        nftTierApys[6] = 10200;
        nftTierApys[7] = 10800;
    }

    /**
     * @dev function to get stake apy for NFT ID
     * @param _nftTier NFT ID
     */
    function getStakeApyForTier(uint32 _nftTier) external view override returns (uint16) {
        return nftTierApys[_nftTier];
    }

    /**
     * @dev function to set stake apy for NFT ID
     * @param _nftTier NFT ID
     * @param _apy apy value want to set
     */
    function setStakeApyForTier(uint32 _nftTier, uint16 _apy) external override onlyOwner {
        require(_apy > 0, "STAKING: INVALID APY PERCENT");
        nftTierApys[_nftTier] = _apy;
    }

    /**
     * @dev function to get commission condition
     * @param _level commission level
     */
    function getCommissionCondition(uint8 _level) external view override returns (uint32) {
        return amountConditions[_level];
    }

    /**
     * @dev function to set commission condition
     * @param _level commission level
     * @param _conditionInUsd threshold in USD that the commissioner must achieve
     */
    function setCommissionCondition(uint8 _level, uint32 _conditionInUsd) external override onlyOwner {
        amountConditions[_level] = _conditionInUsd;
    }

    /**
     * @dev function to get commission condition
     * @param _level commission level
     */
    function getCommissionPercent(uint8 _level) public view override returns (uint16) {
        return commissionPercents[_level];
    }

    /**
     * @dev function to get commission earned when ref stake
     * @param _user user address
     */
    function getRefCommissionEarned(address _user) external view override returns (uint256) {
        return refCommissionEarned[_user];
    }

    /**
     * @dev function to set commission percent
     * @param _level commission level
     * @param _percent commission percent value want to set (0-100)
     */
    function setCommissionPercent(uint8 _level, uint16 _percent) external override onlyOwner {
        commissionPercents[_level] = _percent;
    }

    function getTotalTeamInvesment(address _wallet) external view override returns (uint256) {
        return totalTeamInvestment[_wallet];
    }

    function getRefStakingValue(address _wallet) external view override returns (uint256) {
        return refStakingValue[_wallet];
    }

    function getTeamStakingValue(address _wallet) external view override returns (uint256) {
        return teamStakingValue[_wallet];
    }

    function getStakingCommissionEarned(address _wallet) external view override returns (uint256) {
        return stakingCommissionEarned[_wallet];
    }

    /**
     * @dev stake NFT function
     * @param _nftIds list NFT ID want to stake
     * @param _refCode referral code of ref account
     * @param _data addition information. Default is 0x00
     */
    function stake(
        uint256[] memory _nftIds,
        uint256 _refCode,
        bytes memory _data
    ) external override validRefCode(_refCode) isTimeForStaking lock {
        require(_nftIds.length > 0, "STAKING: INVALID LIST NFT ID");
        require(_nftIds.length <= 20, "STAKING: TOO MANY NFT IN SINGLE STAKE ACTION");
        require(
            IMarketplace(marketplaceContract).checkValidRefCodeAdvance(msg.sender, _refCode),
            "STAKING: CHEAT REF DETECTED"
        );

        // Executing stake action
        stakeExecute(_nftIds, _refCode, _data);
    }

    /**
     * @dev stake NFT function
     * @param _nftIds list NFT ID want to stake
     * @param _refCode referral code of ref account
     * @param _data addition information. Default is 0x00
     */

    function stakeExecute(
        uint256[] memory _nftIds,
        uint256 _refCode,
        bytes memory _data
    ) internal {
        // Get total balance in usd staked for user
        require(TurboDexNFT(nft).isApprovedForAll(msg.sender, address(this)), "STAKING: MUST APPROVE FIRST");
        uint index;
        uint256 _totalAmountStakeUsdDecimal = 0;
        address currentRef = IMarketplace(marketplaceContract).getAccountForReferralCode(_refCode);
        uint256 unlockTimeEstimate = block.timestamp + (2592000 * stakingPeriod);
        for (index = 0; index < _nftIds.length; index++) {
            uint16 _apy = nftTierApys[TurboDexNFT(nft).getNftTier(_nftIds[index])];
            uint256 _singleStakeUsdDecimal = stakeSingleNftExecute(_nftIds[index], _apy, _data, currentRef, unlockTimeEstimate);
            _totalAmountStakeUsdDecimal = _totalAmountStakeUsdDecimal + _singleStakeUsdDecimal;
        }
        // Update referral data & fixed data
        IMarketplace(marketplaceContract).updateReferralData(msg.sender, _refCode);
        // Update Ranking
        IRanking(rankingContract).updateUserRanking(msg.sender, _totalAmountStakeUsdDecimal, _refCode);
        // Update stake value to marketplace contract
        IMarketplace(marketplaceContract).updateStakeValueData(msg.sender, _totalAmountStakeUsdDecimal);
        // Update crew investment data
        updateCrewInvesmentData(_refCode, _totalAmountStakeUsdDecimal, _nftIds);
        // Update team staking data
        updateTeamStakingValue(_refCode, _totalAmountStakeUsdDecimal);
        // burn token
        if (isEnableBurnToken) {
            IBurn(burnContract).burnToken(_totalAmountStakeUsdDecimal);
        }
    }

    function stakeSingleNftExecute(
        uint256 _nftId,
        uint16 _apy,
        bytes memory _data,
        address currentRef,
        uint256 unlockTimeEstimate
    ) internal returns (uint256) {
        // set reward token for direct commission
        address rewardToken = getRewardToken(_nftId);
        // Get total balance in usd staked for user
        uint256 totalAmountStakeUsdDecimal = estimateValueUsdForStakeNft(_nftId) * tokenDecimal;
        // Update struct data
        uint256 rewardUsdDecimal = calculateRewardInUsd(totalAmountStakeUsdDecimal, _apy);
        stakedNFTs[_nftId].stakerAddress = msg.sender;
        stakedNFTs[_nftId].startTime = block.timestamp;
        stakedNFTs[_nftId].unlockTime = unlockTimeEstimate;
        stakedNFTs[_nftId].apy = _apy;
        stakedNFTs[_nftId].totalRewardAmountUsdWithDecimal = rewardUsdDecimal;
        stakedNFTs[_nftId].totalValueStakeUsdWithDecimal = totalAmountStakeUsdDecimal;
        stakedNFTs[_nftId].isUnstaked = false;
        // Update amount staked for user
        amountStaked[msg.sender] = amountStaked[msg.sender] + totalAmountStakeUsdDecimal;
        userStakingNfts[msg.sender].push(_nftId);
        // Transfer NFT from user to contract
        require(TurboDexNFT(nft).ownerOf(_nftId) == msg.sender, "STAKING: NOT OWNER THIS NFT ID");
        try TurboDexNFT(nft).safeTransferFrom(msg.sender, address(this), _nftId, _data) {
            // Emit event
            emit Staked(_nftId, msg.sender, _nftId, unlockTimeEstimate, _apy);
        } catch (bytes memory _error) {
            emit ErrorLog(_error);
            revert("STAKING: NFT TRANSFER FAILED");
        }

        // Pay direct stake commission for currentRef
        bool paidDirectSuccess = payDirectCommission(currentRef, totalAmountStakeUsdDecimal, rewardToken);
        require(paidDirectSuccess == true, "STAKING: FAILED IN PAY COMMISSION FOR DIRECT REF");
        //update stat
        refStakingValue[currentRef] = refStakingValue[currentRef] + totalAmountStakeUsdDecimal;
        return totalAmountStakeUsdDecimal;
    }

    /**
     * @dev function to pay commissions in 10 level
     * @param _firstRef direct referral account wallet address
     * @param totalAmountStakeUsdDecimal total amount stake in usd with decimal for this stake
     */
    function payDirectCommission(address _firstRef, uint256 totalAmountStakeUsdDecimal, address rewardToken) internal returns (bool) {
        address currentRef = _firstRef;
        uint16 commissionPercent = getComissionPercentInRule(currentRef);
        uint256 _commissionInUsdDecimal = (totalAmountStakeUsdDecimal * commissionPercent) / 10000;
        require(_commissionInUsdDecimal > 0, "DIRECT COMMISSION: INVALID TOKEN COMMISSION");
        // calculate max commission can earn
        uint256 _commissionCanEarnUsdWithDecimal = getUserCommissionCanEarnUsdWithDecimal(
            currentRef,
            _commissionInUsdDecimal
        );

        // user buy with usdt token
        uint256 totalCommissionInTokenDecimal = _commissionCanEarnUsdWithDecimal;

        // user buy with turbo token
        if (totalCommissionInTokenDecimal > 0) {
            if (rewardToken == turboToken) {
                totalCommissionInTokenDecimal = Oracle(oracleContract).convertUsdBalanceDecimalToTokenDecimal(
                    _commissionCanEarnUsdWithDecimal
                );
            }
            require(
                IERC20(rewardToken).balanceOf(address(this)) >= totalCommissionInTokenDecimal,
                "STAKING: NOT ENOUGH TOKEN BALANCE TO PAY COMMISSION"
            );
            require(
                IERC20(rewardToken).transfer(currentRef, totalCommissionInTokenDecimal),
                "STAKING: UNABLE TO TRANSFER COMMISSION PAYMENT TO RECIPIENT"
            );
            // update market contract
            IMarketplace(marketplaceContract).updateCommissionStakeValueData(
                currentRef,
                _commissionCanEarnUsdWithDecimal
            );
            // emit Event
            emit PayCommission(msg.sender, currentRef, _commissionCanEarnUsdWithDecimal);
            // update stat
            refCommissionEarned[currentRef] = refCommissionEarned[currentRef] + _commissionCanEarnUsdWithDecimal;
        }
        return true;
    }

    /**
     * @dev get commission percent in new rule.
     */
    function getUserCommissionCanEarnUsdWithDecimal(
        address _user,
        uint256 _totalCommissionInUsdDecimal
    ) public view returns (uint256) {
        uint256 maxCommissionWithDecimal = IMarketplace(marketplaceContract).getMaxCommissionByAddressInUsd(_user);
        uint256 totalCommissionDecimalEarned = IMarketplace(marketplaceContract).getNftCommissionEarnedForAccount(
            _user
        ) + IMarketplace(marketplaceContract).getTotalCommissionStakeByAddressInUsd(_user);
        if (totalCommissionDecimalEarned >= maxCommissionWithDecimal) {
            return 0;
        }

        uint256 totalCommissionDecimalLeft = maxCommissionWithDecimal - totalCommissionDecimalEarned;
        if (totalCommissionDecimalLeft > _totalCommissionInUsdDecimal) {
            return _totalCommissionInUsdDecimal;
        }

        return totalCommissionDecimalLeft;
    }

    /**
     * @dev get commission percent in new rule.
     */
    function getComissionPercentInRule(address _user) internal view returns (uint16) {
        uint16 _comissionPercent = directCommissionPercents[0];
        address[] memory allF1s = IMarketplace(marketplaceContract).getF1ListForAccount(_user);
        if (allF1s.length >= 5) {
            uint countF1Meaning = 0;
            uint256 valueStakeRequire = 1000 * tokenDecimal;
            for (uint i = 0; i < allF1s.length; i++) {
                uint256 totalStakeValue = IMarketplace(marketplaceContract).getTotalStakeByAddressInUsd(allF1s[i]);
                if (totalStakeValue >= valueStakeRequire) {
                    countF1Meaning++;
                }
            }
            if (countF1Meaning >= 5 && countF1Meaning < 10) {
                _comissionPercent = directCommissionPercents[1];
            } else {
                if (countF1Meaning >= 10) {
                    _comissionPercent = directCommissionPercents[2];
                }
            }
        }
        return _comissionPercent;
    }

    /**
     * @dev claim reward function
     * @param _nftIds nftIds Claim
     */
    function claimAll(uint256[] memory _nftIds) external override {
        require(_nftIds.length > 0, "STAKING: INVALID STAKE LIST");
        for (uint i = 0; i < _nftIds.length; i++) {
            claim(_nftIds[i]);
        }
    }

    /**
     * @dev claim reward function
     * @param _nftId nft id cleam
     */
    function claim(uint256 _nftId) public override lock() {
        StructData.StakedNFT memory stakeInfo = stakedNFTs[_nftId];
        require(stakeInfo.unlockTime > 0, "STAKING: ONLY CLAIM YOUR OWN STAKE");
        require(block.timestamp > stakeInfo.startTime, "STAKING: WRONG TIME TO CLAIM");
        require(!stakeInfo.isUnstaked, "STAKING: ALREADY UNSTAKED");
        require(stakeInfo.stakerAddress == msg.sender, "STAKING: ONLY CLAIM YOUR OWN STAKE");
        uint256 claimableRewardInUsdWithDecimal = claimableForStakeInUsdWithDecimal(_nftId);
        if (claimableRewardInUsdWithDecimal > 0) {
            uint256 claimableRewardInTokenWithDecimal = Oracle(oracleContract).convertUsdBalanceDecimalToTokenDecimal(
                claimableRewardInUsdWithDecimal
            );
            require(
                IERC20(turboToken).balanceOf(address(this)) >= claimableRewardInTokenWithDecimal,
                "STAKING: NOT ENOUGH TOKEN BALANCE TO PAY REWARD"
            );
            require(
                IERC20(turboToken).transfer(msg.sender, claimableRewardInTokenWithDecimal),
                "STAKING: UNABLE TO TRANSFER COMMISSION PAYMENT TO RECIPIENT"
            );
            // get total commission can earned of ref 6 months
            uint256 earnableCommissionRewardUsdDecimal = earnableForStakeInUsdWithDecimal(_nftId);
            if (earnableCommissionRewardUsdDecimal > claimableRewardInUsdWithDecimal) {
                earnableCommissionRewardUsdDecimal = claimableRewardInUsdWithDecimal;
            }
            if (earnableCommissionRewardUsdDecimal > 0) {
                // Pay multi levels commission for user
                address payable currentRef = payable(
                    IMarketplace(marketplaceContract).getReferralAccountForAccount(msg.sender)
                );
                bool paidDirectSuccess = payCommissionMultiLevels(currentRef, earnableCommissionRewardUsdDecimal);
                require(paidDirectSuccess == true, "STAKING: FAILED IN PAY COMMISSION FOR DIRECT REF");

                // pay for ranking commission
                if (isEnablePayRankingCommission) {
                    IRanking(rankingContract).payRankingCommission(msg.sender, currentRef, earnableCommissionRewardUsdDecimal);
                }
            }
            stakedNFTs[_nftId].totalClaimedAmountUsdWithDecimal += claimableRewardInUsdWithDecimal;

            emit Claimed(_nftId, msg.sender, claimableRewardInTokenWithDecimal);
        }
    }

    /**
     * @dev function to pay commissions in 10 level
     * @param _firstRef direct referral account wallet address
     * @param _totalAmountStakeUsdWithDecimal total amount stake in usd with decimal for this stake
     */
    function payCommissionMultiLevels(
        address payable _firstRef,
        uint256 _totalAmountStakeUsdWithDecimal
    ) internal returns (bool) {
        address payable currentRef = _firstRef;
        uint8 index = 0;
        while (currentRef != address(0) && index < 10) {
            // Check if ref account is eligible to staked amount enough for commission
            bool totalStakeAmount = possibleForCommission(currentRef, index);
            if (totalStakeAmount) {
                // Transfer commission in token amount
                uint256 commissionPercent = getCommissionPercent(index);
                uint256 _commissionInUsdWithDecimal = (_totalAmountStakeUsdWithDecimal * commissionPercent) / 10000;
                // calculate max commission can earn
                uint256 _commissionCanEarnUsdWithDecimal = getUserCommissionCanEarnUsdWithDecimal(
                    currentRef,
                    _commissionInUsdWithDecimal
                );
                if (_commissionCanEarnUsdWithDecimal > 0) {
                    uint256 totalCommissionInTokenDecimal = Oracle(oracleContract)
                        .convertUsdBalanceDecimalToTokenDecimal(_commissionCanEarnUsdWithDecimal);
                    require(totalCommissionInTokenDecimal > 0, "STAKING: INVALID TOKEN BALANCE COMMISSION");
                    require(
                        IERC20(turboToken).balanceOf(address(this)) >= totalCommissionInTokenDecimal,
                        "STAKING: NOT ENOUGH TOKEN BALANCE TO PAY COMMISSION"
                    );
                    require(
                        IERC20(turboToken).transfer(currentRef, totalCommissionInTokenDecimal),
                        "STAKING: UNABLE TO TRANSFER COMMISSION PAYMENT TO RECIPIENT"
                    );
                    // update market contract
                    IMarketplace(marketplaceContract).updateCommissionStakeValueData(
                        currentRef,
                        _commissionCanEarnUsdWithDecimal
                    );
                    stakingCommissionEarned[currentRef] = stakingCommissionEarned[currentRef] + _commissionCanEarnUsdWithDecimal;
                    // emit Event
                    emit PayCommission(msg.sender, currentRef, totalCommissionInTokenDecimal);
                }
            }
            index++;
            currentRef = payable(IMarketplace(marketplaceContract).getReferralAccountForAccount(currentRef));
        }
        return true;
    }

    /**
     * @dev function to get earnable commission 6 months
     * @param _nftId nft ID claiming
     */
    function earnableForStakeInUsdWithDecimal(uint256 _nftId) public view override returns (uint256) {
        StructData.StakedNFT memory stakeInfo = stakedNFTs[_nftId];
        uint256 totalDurationStaked = stakeInfo.unlockTime - stakeInfo.startTime;
        uint256 totalDurationCanEarn = 15552000; // 6 * 30 * 24 * 3600
        uint256 totalRewardAmountCanEarnUsdDecimal = (stakeInfo.totalRewardAmountUsdWithDecimal *
            totalDurationCanEarn) / totalDurationStaked;
        uint256 durationCanEarnUsdDecimal = 0;
        if (totalRewardAmountCanEarnUsdDecimal > stakeInfo.totalClaimedAmountUsdWithDecimal) {
            durationCanEarnUsdDecimal = totalRewardAmountCanEarnUsdDecimal - stakeInfo.totalClaimedAmountUsdWithDecimal;
        }

        return durationCanEarnUsdDecimal;
    }

    /**
     * @dev function to check the staked amount enough to get commission
     * @param _staker staker wallet address
     * @param _level commission level need to check condition
     */
    function possibleForCommission(address _staker, uint8 _level) public view returns (bool) {
        uint256 totalStakeAmount = getTotalStakeAmountUSD((_staker));
        uint32 conditionAmount = amountConditions[_level];
        bool resultCheck = false;
        if (totalStakeAmount >= conditionAmount) {
            resultCheck = true;
        }
        return resultCheck;
    }

    /**
     * @dev function to get total stake amount in usd
     * @param _staker staker wallet address
     */
    function getTotalStakeAmountUSD(address _staker) public view returns (uint256) {
        return amountStaked[_staker] / tokenDecimal;
    }

    function updateCrewInvesmentData(uint256 _refCode, uint256 _totalAmountStakeUsdWithDecimal, uint256[] memory _nftIds) internal {
        address payable currentRef;
        address payable nextRef = payable(IMarketplace(marketplaceContract).getAccountForReferralCode(_refCode));
        uint8 index = 1;
        while (currentRef != nextRef && nextRef != address(0) && index <= 100) {
            // Update Team Staking Value ( 100 level)
            currentRef = nextRef;
            uint256 currentCrewInvesmentValue = totalTeamInvestment[currentRef];
            totalTeamInvestment[currentRef] = currentCrewInvesmentValue + _totalAmountStakeUsdWithDecimal;
            IRanking(rankingContract).setUserRefNfts(_nftIds, currentRef);
            index++;
            nextRef = payable(IMarketplace(marketplaceContract).getReferralAccountForAccount(currentRef));
        }
    }

    /**
     * @dev estimate value in USD for a stake of NFT
     * @param _nftId id nft stake
     */
    function estimateValueUsdForStakeNft(uint256 _nftId) public view returns (uint256) {
        return TurboDexNFT(nft).getNftPriceUsd(_nftId);
    }

    /**
     * @dev function to calculate reward in USD based on staking time and ¬l
     * @param _totalValueStakeUsd total value of stake (USD)
     * @param _apy apy
     */
    function calculateRewardInUsd(
        uint256 _totalValueStakeUsd,
        uint16 _apy
    ) public view override returns (uint256) {
        // Get years
        uint256 yearAmount = stakingPeriod / 12;
        // Calculate to reward in token
        uint256 rewardInUsd = (_totalValueStakeUsd * _apy * yearAmount) / 10000;
        return rewardInUsd;
    }

    function updateTeamStakingValue(uint256 _refCode, uint256 _totalAmountStakeUsdWithDecimal) internal {
        address payable currentRef;
        address payable nextRef = payable(IMarketplace(marketplaceContract).getAccountForReferralCode(_refCode));
        uint8 index = 1;
        while (currentRef != nextRef && nextRef != address(0) && index <= 10) {
            // Update Team Staking Value ( 10 level)
            currentRef = nextRef;
            uint256 currentCrewInvesmentValue = teamStakingValue[currentRef];
            teamStakingValue[currentRef] = currentCrewInvesmentValue + _totalAmountStakeUsdWithDecimal;
            index++;
            nextRef = payable(IMarketplace(marketplaceContract).getReferralAccountForAccount(currentRef));
        }
    }

    /**
     * @dev function to calculate claimable reward in Usd based on staking time and period
     * @param _nftId nft Id claiming
     */
    function claimableForStakeInUsdWithDecimal(uint256 _nftId) public view override returns (uint256) {
        StructData.StakedNFT memory stakeInfo = stakedNFTs[_nftId];
        uint256 accumulateTimeStaked = block.timestamp - stakeInfo.startTime;
        uint256 totalDurationStaked = stakeInfo.unlockTime - stakeInfo.startTime;
        require(accumulateTimeStaked > 0, "STAKING: NOT TIME TO CLAIM");
        if (accumulateTimeStaked > totalDurationStaked) {
            accumulateTimeStaked = totalDurationStaked;
        }
        uint256 accumulateRewardInUsdWithDecimal = (stakeInfo.totalRewardAmountUsdWithDecimal * accumulateTimeStaked) /
            totalDurationStaked;
        uint256 remainRewardInUsd = accumulateRewardInUsdWithDecimal - stakeInfo.totalClaimedAmountUsdWithDecimal;
        return remainRewardInUsd;
    }

    /**
     * @dev unstake NFT function
     * @param _nftId id nft unstake
     * @param _data addition information. Default is 0x00
     */
    function unstake(uint256 _nftId, bytes memory _data) external override lock() {
        require(possibleUnstake(_nftId) == true, "STAKING: STILL IN STAKING PERIOD");
        address staker = stakedNFTs[_nftId].stakerAddress;
        require(staker == msg.sender, "STAKING: NOT NFT OF USER");
        // Set staking was unstaked for preventing Reentrancy
        stakedNFTs[_nftId].isUnstaked = true;
        // Update total amount staked of user
        uint256 amountStakedUser = stakedNFTs[_nftId].totalValueStakeUsdWithDecimal;
        amountStaked[msg.sender] = amountStaked[msg.sender] - amountStakedUser;
        // Update total amount staked of team
        // Transfer NFT from contract to claimer
        try TurboDexNFT(nft).safeTransferFrom(address(this), staker, _nftId, _data) {
            // Emit event
            emit Unstaked(_nftId, staker, _nftId);
        } catch (bytes memory _error) {
            emit ErrorLog(_error);
            revert("STAKING: UNSTAKE FAILED");
        }
        // Calculate & send reward in token
        uint256 tokenAmountWithDecimal = rewardUnstakeInTokenWithDecimal(_nftId);
        require(
            IERC20(turboToken).balanceOf(address(this)) >= tokenAmountWithDecimal,
            "STAKING: NOT ENOUGH TOKEN BALANCE TO PAY UNSTAKE REWARD"
        );
        require(
            IERC20(turboToken).transfer(staker, tokenAmountWithDecimal),
            "STAKING: UNABLE TO TRANSFER COMMISSION PAYMENT TO RECIPIENT"
        );
        // get total commission can earnd of ref 6 months
        uint256 claimableRewardInUsdWithDecimal = stakedNFTs[_nftId].totalRewardAmountUsdWithDecimal - stakedNFTs[_nftId].totalClaimedAmountUsdWithDecimal;
        uint256 earnableCommissionRewardUsdDecimal = earnableForStakeInUsdWithDecimal(_nftId);
        if (earnableCommissionRewardUsdDecimal > claimableRewardInUsdWithDecimal) {
            earnableCommissionRewardUsdDecimal = claimableRewardInUsdWithDecimal;
        }
        if (earnableCommissionRewardUsdDecimal > 0) {
            // Pay multi levels commission for user
            address payable currentRef = payable(
                IMarketplace(marketplaceContract).getReferralAccountForAccount(msg.sender)
            );
            bool paidDirectSuccess = payCommissionMultiLevels(currentRef, earnableCommissionRewardUsdDecimal);
            require(paidDirectSuccess == true, "STAKING: FAILD IN PAY COMMISSION FOR DERECT REF");

            // pay for ranking commission
            if (isEnablePayRankingCommission) {
                IRanking(rankingContract).payRankingCommission(msg.sender, currentRef, earnableCommissionRewardUsdDecimal);
            }
        }
        // Set total claimed full
        stakedNFTs[_nftId].totalClaimedAmountUsdWithDecimal = stakedNFTs[_nftId].totalRewardAmountUsdWithDecimal;
    }

    /**
     * @dev check unstake requesting is valid or not(still in locking)
     * @param _nftId nft id token unstake
     */
    function possibleUnstake(uint256 _nftId) public view returns (bool) {
        bool resultCheck = false;
        uint256 unlockTimestamp = stakedNFTs[_nftId].unlockTime;
        if (block.timestamp >= unlockTimestamp) {
            resultCheck = true;
        }
        return resultCheck;
    }

    /**
     * @dev function to calculate reward in Token based on staking time and period
     * @param _nftId nft id of token unstake
     */
    function rewardUnstakeInTokenWithDecimal(uint256 _nftId) public view override returns (uint256) {
        uint256 rewardInUsdWithDecimal = stakedNFTs[_nftId].totalRewardAmountUsdWithDecimal -
            stakedNFTs[_nftId].totalClaimedAmountUsdWithDecimal;
        uint256 rewardInTokenWithDecimal = Oracle(oracleContract).convertUsdBalanceDecimalToTokenDecimal(
            rewardInUsdWithDecimal
        );
        return rewardInTokenWithDecimal;
    }

    /**
     * @dev function to get all stake information from an account & stake index
     * @param _nftId nft id stake
     */
    function getDetailOfStake(uint256 _nftId) external view returns (StructData.StakedNFT memory) {
        StructData.StakedNFT memory stakeInfo = stakedNFTs[_nftId];
        return stakeInfo;
    }

    /**
     * @dev withdraw some token balance from contract to owner account
     */
    function withdrawTokenEmergency(address _token, uint256 _amount) public override onlyOwner {
        require(_amount > 0, "STAKING: INVALID AMOUNT");
        require(IERC20(_token).balanceOf(address(this)) >= _amount, "STAKING: TOKEN BALANCE NOT ENOUGH");
        require(IERC20(_token).transfer(msg.sender, _amount), "STAKING: CANNOT WITHDRAW TOKEN");
    }

    /**
     * @dev withdraw some currency balance from contract to owner account
     */
    function withdrawTokenEmergencyFrom(
        address _from,
        address _to,
        address _token,
        uint256 _amount
    ) public override onlyOwner {
        require(_amount > 0, "STAKING: INVALID AMOUNT");
        require(IERC20(_token).balanceOf(_from) >= _amount, "STAKING: CURRENCY BALANCE NOT ENOUGH");
        require(IERC20(_token).transferFrom(_from, _to, _amount), "STAKING: CANNOT WITHDRAW CURRENCY");
    }

    /**
     * @dev transfer a NFT from this contract to an account, only owner
     */
    function tranferNftEmergency(address _receiver, uint256 _nftId) public override onlyOwner {
        require(TurboDexNFT(nft).ownerOf(_nftId) == address(this), "STAKING: NOT OWNER OF THIS NFT");
        try TurboDexNFT(nft).safeTransferFrom(address(this), _receiver, _nftId, "") {} catch (bytes memory _error) {
            emit ErrorLog(_error);
            revert("STAKING: NFT TRANSFER FAILED");
        }
    }

    /**
     * @dev transfer a list of NFT from this contract to a list of account, only owner
     */
    function tranferMultiNftsEmergency(
        address[] memory _receivers,
        uint256[] memory _nftIds
    ) external override onlyOwner {
        require(_receivers.length == _nftIds.length, "STAKING: MUST BE SAME SIZE");
        for (uint index = 0; index < _nftIds.length; index++) {
            tranferNftEmergency(_receivers[index], _nftIds[index]);
        }
    }

    function setMarketplaceContract(address _marketplaceAddress) external onlyOwner {
        require(_marketplaceAddress != address(0), "STAKING: INVALID ADDRESS");
        marketplaceContract = _marketplaceAddress;
    }

    function setTurboToken(address _turboToken) external onlyOwner {
        require(_turboToken != address(0), "STAKING: INVALID ADDRESS");
        turboToken = _turboToken;
    }

    function setNft(address _nft) external onlyOwner {
        require(_nft != address(0), "STAKING: INVALID ADDRESS");
        nft = _nft;
    }

    /**
     * @dev set oracle address
     */
    function setOracleAddress(address _oracleAddress) external override onlyOwner {
        require(_oracleAddress != address(0), "STAKING: INVALID ORACLE ADDRESS");
        oracleContract = _oracleAddress;
    }

    /**
     * @dev set ranking address
     */
    function setRankingAddress(address _rankingAddress) public override onlyOwner {
        require(_rankingAddress != address(0), "STAKING: INVALID RANKING ADDRESS");
        rankingContract = _rankingAddress;
    }

    /**
     * @dev admin update apy
     * @param _user staker wallet address
     * @param _nftIds nft id list
     * @param _newApys list new-apy
     */
    function updateStakeApyEmergency(
        address _user,
        uint256[] memory _nftIds,
        uint16[] memory _newApys
    ) public onlyOwner {
        require(_user != address(0), "STAKING: INVALID STAKER");
        require(_nftIds.length == _newApys.length, "STAKING: ARRAYS MUST BE SAME LENGTH");
        uint256 totalAmountStakeUsdWithDecimal = 0;
        uint256 rewardUsdWithDecimal = 0;
        for (uint i = 0; i < _nftIds.length; i++) {
            // Update struct data
            bool isUnstaked = stakedNFTs[_nftIds[i]].isUnstaked;
            require(!isUnstaked, "STAKING: CANNOT UPDATE FOR UNSTAKED ID");
            totalAmountStakeUsdWithDecimal = stakedNFTs[_nftIds[i]].totalValueStakeUsdWithDecimal;
            require(totalAmountStakeUsdWithDecimal > 0, "STAKING: INVALID STAKER ID");
            require(_newApys[i] > 0, "STAKING: APY MUST BE A POSITIVE NUMBER");
            rewardUsdWithDecimal = calculateRewardInUsd(
                totalAmountStakeUsdWithDecimal,
                _newApys[i]
            );
            stakedNFTs[_nftIds[i]].apy = _newApys[i];
            stakedNFTs[_nftIds[i]].totalRewardAmountUsdWithDecimal = rewardUsdWithDecimal;
        }
    }

    /**
     * @dev admin remove stake in emergency case
     * @param _user staker wallet address
     * @param _nftIds list nft id
     */
    function removeStakeEmergency(address _user, uint256[] memory _nftIds) public onlyOwner {
        require(_user != address(0), "STAKING: INVALID STAKER");
        require(_nftIds.length > 0, "STAKING: ARRAYS MUST NOT BE EMPTY");
        for (uint i = 0; i < _nftIds.length; i++) {
            // Update struct data
            bool isUnstaked = stakedNFTs[_nftIds[i]].isUnstaked;
            require(!isUnstaked, "STAKING: CANNOT UPDATE FOR UNSTAKED ID");
            address staker = stakedNFTs[_nftIds[i]].stakerAddress;
            require(staker == _user, "STAKING: MISMATCH INFORMATION");
            //delete
            delete stakedNFTs[_nftIds[i]];
        }
    }

    /**
     * @dev set reward token for staking
     * @param _nftId nft stake
     */
    function getRewardToken(uint256 _nftId) internal view returns (address) {
        address _rewardToken = payWithBuyToken == 1 ? usdtToken : turboToken;
        if (payWithBuyToken == 3) {
            _rewardToken = IMarketplace(marketplaceContract).isBuyByToken(_nftId) ? turboToken : usdtToken;
        }
        return _rewardToken;
    }

    /**
     * @dev set reward token for staking
     * @param _currentRef user update commission value
     * @param _commissionUsdWithDecimal commission value
     */
    function setMarketCommission(address _currentRef, uint256 _commissionUsdWithDecimal) external override {
        require(msg.sender == rankingContract, "STAKING: SENDER NOT RANKING CONTRACT");
        IMarketplace(marketplaceContract).updateCommissionStakeValueData(
            _currentRef,
            _commissionUsdWithDecimal
        );
    }

    /**
     * @dev get commission levels can claim
     * @param _user user address
    */
    function getCommissionProfitUnclaim(address _user) external view override returns (uint256) {
        uint256 totalStakeAmount = getTotalStakeAmountUSD(_user);
        uint256 totalClaimableUsdWithDecimal = 0;
        uint8 floor = 0;
        for (uint8 i = 0; i < 9; i++) {
            if (totalStakeAmount >= amountConditions[i]) {
                floor = i;
            }
        }
        totalClaimableUsdWithDecimal = 0;
        totalClaimableUsdWithDecimal = getClaimableProfitF1(_user, 0, floor, totalClaimableUsdWithDecimal);
        uint256 _commissionCanEarnUsdWithDecimal = getUserCommissionCanEarnUsdWithDecimal(
            _user,
            totalClaimableUsdWithDecimal
        );

        return _commissionCanEarnUsdWithDecimal;
    }

    /**
     * @dev get commission can earn of level
     * @param _user user calculate
     * @param floor floor earn commission
     * @param maxFloor max floor earn commission
     * @param totalClaimableUsdWithDecimal total claim
    */
    function getClaimableProfitF1(address _user, uint8 floor, uint8 maxFloor, uint256 totalClaimableUsdWithDecimal) internal view returns (uint256) {
        uint16 _comissionPercent = commissionPercents[floor];
        address[] memory f1s = IMarketplace(marketplaceContract).getF1ListForAccount(_user);
        if (f1s.length == 0) {
            return totalClaimableUsdWithDecimal;
        }
        floor = floor + 1;
        for (uint index = 0; index < f1s.length; index++) {
            uint256[] memory nfts = userStakingNfts[f1s[index]];
            for (uint i = 0; i < nfts.length; i++) {
                uint256 earnableCommissionRewardUsdDecimal = claimableForStakeInUsdWithDecimal(nfts[i]);
                uint256 commissionNftCanEarnUsd = earnableCommissionRewardUsdDecimal * _comissionPercent / 10000;
                totalClaimableUsdWithDecimal = totalClaimableUsdWithDecimal + commissionNftCanEarnUsd;
            }
            if (floor <= maxFloor) {
                totalClaimableUsdWithDecimal = getClaimableProfitF1(f1s[index], floor, maxFloor, totalClaimableUsdWithDecimal);
            }
        }

        return totalClaimableUsdWithDecimal;
    }

    function updateStakeNFT(
        uint256 _nftId,
        uint256 _fromTimestamp,
        uint256 _totalValueStakeUsdWithDecimal,
        address _stakerAddress,
        uint256 _totalClaimedWithDecimal,
        uint256 _totalRewardAmountUsdWithDecimal,
        uint16 apy
    ) external onlyOwner {
        uint256 unlockTimeEstimate = _fromTimestamp + (stakingPeriod * 2592000);
        stakedNFTs[_nftId].startTime = _fromTimestamp;
        stakedNFTs[_nftId].unlockTime = unlockTimeEstimate;
        stakedNFTs[_nftId].totalClaimedAmountUsdWithDecimal = _totalClaimedWithDecimal;
        stakedNFTs[_nftId].totalRewardAmountUsdWithDecimal = _totalRewardAmountUsdWithDecimal;
        stakedNFTs[_nftId].totalValueStakeUsdWithDecimal = _totalValueStakeUsdWithDecimal;
        stakedNFTs[_nftId].stakerAddress = _stakerAddress;
        stakedNFTs[_nftId].apy = apy;
        userStakingNfts[_stakerAddress].push(_nftId);
    }

    function updateUserInformation(
        address _user,
        uint256 _totalTeamInvestment,
        uint256 _stakingCommissionEarned,
        uint256 _refStakingValue,
        uint256 _refCommissionEarned,
        uint256 _teamStakingValue,
        uint256 _amountStaked
    ) external onlyOwner {
        totalTeamInvestment[_user] = _totalTeamInvestment;
        stakingCommissionEarned[_user] = _stakingCommissionEarned;
        refStakingValue[_user] = _refStakingValue;
        refCommissionEarned[_user] = _refCommissionEarned;
        teamStakingValue[_user] = _teamStakingValue;
        amountStaked[_user] = _amountStaked;
    }

    /**
     * @dev possible to receive any IERC20 tokens
     */
    receive() external payable {}
}
