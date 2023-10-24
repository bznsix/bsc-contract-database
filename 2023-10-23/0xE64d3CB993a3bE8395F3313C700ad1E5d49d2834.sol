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
// OpenZeppelin Contracts v4.4.1 (interfaces/IERC20.sol)

pragma solidity ^0.8.0;

import "../token/ERC20/IERC20.sol";
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (interfaces/IERC721.sol)

pragma solidity ^0.8.0;

import "../token/ERC721/IERC721.sol";
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (security/ReentrancyGuard.sol)

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
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/draft-IERC20Permit.sol)

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
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";
import "../extensions/draft-IERC20Permit.sol";
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

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

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
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC721/ERC721.sol)

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
        address owner = _owners[tokenId];
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
            "ERC721: approve caller is not token owner nor approved for all"
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
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {
        //solhint-disable-next-line max-line-length
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: caller is not token owner nor approved");

        _transfer(from, to, tokenId);
    }

    /**
     * @dev See {IERC721-safeTransferFrom}.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {
        safeTransferFrom(from, to, tokenId, "");
    }

    /**
     * @dev See {IERC721-safeTransferFrom}.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory data
    ) public virtual override {
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: caller is not token owner nor approved");
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
    function _safeTransfer(
        address from,
        address to,
        uint256 tokenId,
        bytes memory data
    ) internal virtual {
        _transfer(from, to, tokenId);
        require(_checkOnERC721Received(from, to, tokenId, data), "ERC721: transfer to non ERC721Receiver implementer");
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
        return _owners[tokenId] != address(0);
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
    function _safeMint(
        address to,
        uint256 tokenId,
        bytes memory data
    ) internal virtual {
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

        _beforeTokenTransfer(address(0), to, tokenId);

        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(address(0), to, tokenId);

        _afterTokenTransfer(address(0), to, tokenId);
    }

    /**
     * @dev Destroys `tokenId`.
     * The approval is cleared when the token is burned.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     *
     * Emits a {Transfer} event.
     */
    function _burn(uint256 tokenId) internal virtual {
        address owner = ERC721.ownerOf(tokenId);

        _beforeTokenTransfer(owner, address(0), tokenId);

        // Clear approvals
        _approve(address(0), tokenId);

        _balances[owner] -= 1;
        delete _owners[tokenId];

        emit Transfer(owner, address(0), tokenId);

        _afterTokenTransfer(owner, address(0), tokenId);
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
    function _transfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {
        require(ERC721.ownerOf(tokenId) == from, "ERC721: transfer from incorrect owner");
        require(to != address(0), "ERC721: transfer to the zero address");

        _beforeTokenTransfer(from, to, tokenId);

        // Clear approvals from the previous owner
        _approve(address(0), tokenId);

        _balances[from] -= 1;
        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(from, to, tokenId);

        _afterTokenTransfer(from, to, tokenId);
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
    function _setApprovalForAll(
        address owner,
        address operator,
        bool approved
    ) internal virtual {
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
     * @dev Hook that is called before any token transfer. This includes minting
     * and burning.
     *
     * Calling conditions:
     *
     * - When `from` and `to` are both non-zero, ``from``'s `tokenId` will be
     * transferred to `to`.
     * - When `from` is zero, `tokenId` will be minted for `to`.
     * - When `to` is zero, ``from``'s `tokenId` will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {}

    /**
     * @dev Hook that is called after any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {}
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC721/extensions/ERC721Enumerable.sol)

pragma solidity ^0.8.0;

import "../ERC721.sol";
import "./IERC721Enumerable.sol";

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
     * @dev Hook that is called before any token transfer. This includes minting
     * and burning.
     *
     * Calling conditions:
     *
     * - When `from` and `to` are both non-zero, ``from``'s `tokenId` will be
     * transferred to `to`.
     * - When `from` is zero, `tokenId` will be minted for `to`.
     * - When `to` is zero, ``from``'s `tokenId` will be burned.
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual override {
        super._beforeTokenTransfer(from, to, tokenId);

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
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC721/extensions/IERC721Enumerable.sol)

pragma solidity ^0.8.0;

import "../IERC721.sol";

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
// OpenZeppelin Contracts (last updated v4.7.0) (utils/Address.sol)

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
        return functionCall(target, data, "Address: low-level call failed");
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
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
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
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
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
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verifies that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason using the provided one.
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
pragma solidity >=0.5.0;

interface IUniswapV2Factory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
}
pragma solidity >=0.5.0;

interface IUniswapV2Pair {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address owner) external view returns (uint);

    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;

    event Mint(address indexed sender, uint amount0, uint amount1);
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint);
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function price0CumulativeLast() external view returns (uint);
    function price1CumulativeLast() external view returns (uint);
    function kLast() external view returns (uint);

    function mint(address to) external returns (uint liquidity);
    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;

    function initialize(address, address) external;
}
pragma solidity >=0.6.2;

interface IUniswapV2Router01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);
    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH);
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}
pragma solidity >=0.6.2;

import './IUniswapV2Router01.sol';

interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}
pragma solidity >=0.5.0;

interface IWETH {
    function deposit() external payable;
    function transfer(address to, uint value) external returns (bool);
    function withdraw(uint) external;
}
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/interfaces/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import "./interfaces/IRewardsVault.sol";
import "./interfaces/IPancakePair.sol";
import "./interfaces/IMasterchefPigs.sol";
import "./interfaces/IPancakeFactory.sol";
import "./interfaces/IDogsToken.sol";
import "./interfaces/IDogPoundActions.sol";
import "./interfaces/IStakeManager.sol";
import "./interfaces/IRewardsVault.sol";


interface IDogPoundPool {
    function deposit(address _user, uint256 _amount) external;
    function withdraw(address _user, uint256 _amount) external;
    function getStake(address _user, uint256 _stakeID) external view returns(uint256 stakedAmount);
}

contract DogPoundManager is Ownable {
    using SafeERC20 for IERC20;

    IStakeManager public StakeManager = IStakeManager(0x25A959dDaEcEb50c1B724C603A57fe7b32eCbEeA);
    IDogPoundPool public DogPoundLinearPool = IDogPoundPool(0x935B36a774f2c04b8fA92acf3528d7DF681C0297);
    IDogPoundPool public DogPoundAutoPool = IDogPoundPool(0xf911D1d7118278f86eedfD94bC7Cd141D299E28D);
    IDogPoundActions public DogPoundActions;
    IRewardsVault public rewardsVault = IRewardsVault(0x4c004C4fB925Be396F902DE262F2817dEeBC22Ec);

    bool public isPaused;
    uint256 public walletReductionPerMonth = 200;
    uint256 public burnPercent = 30;
    uint256 public minHoldThreshold = 10e18;

    uint256 public loyaltyScoreMaxReduction = 3000;
    uint256 public dogsDefaultTax = 9000;
    uint256 public minDogVarTax = 300;
    uint256 public withdrawlRestrictionTime = 24 hours;
    DogPoundManager public oldDp = DogPoundManager(0x6dA8227Bc7B576781ffCac69437e17b8D4F4aE41);
    address public dogsToken = 0x198271b868daE875bFea6e6E4045cDdA5d6B9829;
    IDogsToken public DogsToken = IDogsToken(dogsToken);
    IUniswapV2Router02 public constant PancakeRouter = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
    uint256 public linearPoolSize = oldDp.linearPoolSize();
    uint256 public autoPoolSize = oldDp.autoPoolSize();

    struct UserInfo {
        uint256 walletStartTime;
        uint256 overThresholdTimeCounter;
        uint256 lastDepositTime;
        uint256 totalStaked;
    }

    struct StakeInfo {
        uint256 amount;
        uint256 startTime;
        bool isAutoPool;
    } 

    mapping(address => UserInfo) public userInfo;

    modifier notPaused() {
        require(!isPaused, "notPaused: DogPound paused !");
        _;
    }

    constructor(){
        _approveTokenIfNeeded(0x198271b868daE875bFea6e6E4045cDdA5d6B9829);
    }
    

    function deposit(uint256 _amount, bool _isAutoCompound) external notPaused {
        require(_amount > 0, 'deposit !> 0');
        initUser(msg.sender);
        StakeManager.saveStake(msg.sender, _amount, _isAutoCompound);
        DogsToken.transferFrom(msg.sender, address(this), _amount);
        if (StakeManager.totalStaked(msg.sender) >= minHoldThreshold && userInfo[msg.sender].walletStartTime == 0){
                userInfo[msg.sender].walletStartTime = block.timestamp;
        }
        if (_isAutoCompound){
            DogsToken.transfer(address(DogPoundAutoPool), _amount);
            DogPoundAutoPool.deposit(msg.sender, _amount);
            autoPoolSize += _amount;
        } else {
            DogsToken.transfer(address(DogPoundLinearPool), _amount);
            DogPoundLinearPool.deposit(msg.sender, _amount);
            linearPoolSize += _amount;
        }
        userInfo[msg.sender].totalStaked += _amount;
        userInfo[msg.sender].lastDepositTime = block.timestamp;

    }

    function withdrawToWallet(uint256 _amount, uint256 _stakeID) external notPaused {
        initUser(msg.sender);
        require(block.timestamp - userInfo[msg.sender].lastDepositTime > withdrawlRestrictionTime,"withdrawl locked");
        _withdraw(_amount, _stakeID);
        if (StakeManager.totalStaked(msg.sender) < minHoldThreshold && userInfo[msg.sender].walletStartTime > 0){
            userInfo[msg.sender].overThresholdTimeCounter += block.timestamp - userInfo[msg.sender].walletStartTime;
            userInfo[msg.sender].walletStartTime = 0;
        }
        DogsToken.updateTransferTaxRate(0);
        DogsToken.transfer(msg.sender, _amount);
        DogsToken.updateTransferTaxRate(dogsDefaultTax);
    }

    function swapFromWithdrawnStake(uint256 _amount, uint256 _stakeID, address[] memory path) public {
        initUser(msg.sender);
        StakeManager.utilizeWithdrawnStake(msg.sender, _amount, _stakeID);
        uint256 taxReduction = totalTaxReductionWithdrawnStake(msg.sender, _stakeID);
        DogsToken.transferFrom(msg.sender, address(this), _amount);
        doSwap(address(this), _amount, taxReduction, path);
        IERC20 transfertoken = IERC20(path[path.length - 1]);
        uint256 balance = transfertoken.balanceOf(address(this));
        uint256 balance2 = DogsToken.balanceOf(address(this));
        DogsToken.updateTransferTaxRate(0);
        DogsToken.transfer(msg.sender, balance2);
        DogsToken.updateTransferTaxRate(dogsDefaultTax);
        transfertoken.transfer(msg.sender, balance);
    }

    function transferFromWithdrawnStake(uint256 _amount, address _to, uint256 _stakeID) public {
        initUser(msg.sender);
        StakeManager.utilizeWithdrawnStake(msg.sender, _amount, _stakeID);
        uint256 taxReduction = totalTaxReductionWithdrawnStake(msg.sender, _stakeID);
        DogsToken.transferFrom(msg.sender, address(this), _amount);
        doTransfer(_to , _amount, taxReduction);
    }
    //loyalty methods can stay unchanged
    function swapDogsWithLoyalty(uint256 _amount, address[] memory path) public {
        initUser(msg.sender);
        uint256 taxReduction = totalTaxReductionLoyaltyOnly(msg.sender);
        DogsToken.transferFrom(msg.sender, address(this), _amount);
        doSwap(address(this), _amount, taxReduction, path);
        IERC20 transfertoken = IERC20(path[path.length - 1]);
        uint256 balance = transfertoken.balanceOf(address(this));
        uint256 balance2 = DogsToken.balanceOf(address(this));
        DogsToken.updateTransferTaxRate(0);
        DogsToken.transfer(msg.sender, balance2);
        DogsToken.updateTransferTaxRate(dogsDefaultTax);
        transfertoken.transfer(msg.sender, balance);
    }
    //loyalty methods can stay unchanged
    function transferDogsWithLoyalty(uint256 _amount, address _to) public {
        initUser(msg.sender);
        uint256 taxReduction = totalTaxReductionLoyaltyOnly(msg.sender);
        DogsToken.transferFrom(msg.sender, address(this), _amount);
        doTransfer(_to ,_amount, taxReduction);
    }

    function _approveTokenIfNeeded(address token) private {
        if (IERC20(token).allowance(address(this), address(PancakeRouter)) == 0) {
            IERC20(token).safeApprove(address(PancakeRouter), type(uint256).max);
        }
    }

    // Internal functions
    function _withdraw(uint256 _amount, uint256 _stakeID) internal {
        bool isAutoPool = StakeManager.isStakeAutoPool(msg.sender, _stakeID);
        StakeManager.withdrawFromStake(msg.sender ,_amount, _stakeID); //require amount makes sense for stake
        if (isAutoPool){
            DogPoundAutoPool.withdraw(msg.sender, _amount);
            autoPoolSize -= _amount;
        } else {
            DogPoundLinearPool.withdraw(msg.sender, _amount);
            linearPoolSize -= _amount;
        }
        userInfo[msg.sender].totalStaked -= _amount;
    }

    // View functions
    function walletTaxReduction(address _user) public view returns (uint256){
        UserInfo storage user = userInfo[_user];
        (uint256 e1, uint256 e2,uint256 _deptime, uint256 e3 )= readOldStruct(_user);
        if(user.lastDepositTime == 0 && _deptime != 0){
            uint256 currentReduction = 0;
            if (StakeManager.totalStaked(_user) < minHoldThreshold){
                currentReduction = (e2 / 30 days) * walletReductionPerMonth;
                if(currentReduction > loyaltyScoreMaxReduction){
                    return loyaltyScoreMaxReduction;
                }
                return currentReduction;
            }
            currentReduction = (((block.timestamp - e1) + e2) / 30 days) * walletReductionPerMonth;
            if(currentReduction > loyaltyScoreMaxReduction){
                return loyaltyScoreMaxReduction;
            }
            return currentReduction;  

        }
        uint256 currentReduction = 0;
        if (StakeManager.totalStaked(_user) < minHoldThreshold){
            currentReduction = (user.overThresholdTimeCounter / 30 days) * walletReductionPerMonth;
            if(currentReduction > loyaltyScoreMaxReduction){
                return loyaltyScoreMaxReduction;
            }
            return currentReduction;
        }
        currentReduction = (((block.timestamp - user.walletStartTime) + user.overThresholdTimeCounter) / 30 days) * walletReductionPerMonth;
        if(currentReduction > loyaltyScoreMaxReduction){
            return loyaltyScoreMaxReduction;
        }
        return currentReduction;    
    }

    function totalTaxReductionLoyaltyOnly(address _user)public view returns (uint256){
        uint256 walletReduction = walletTaxReduction(_user);
        if(walletReduction > (dogsDefaultTax - minDogVarTax)){
            walletReduction = (dogsDefaultTax - minDogVarTax);
        }else{
            walletReduction = dogsDefaultTax - walletReduction - minDogVarTax;
        }
        return walletReduction;
    }
    

    function totalTaxReductionWithdrawnStake(address _user, uint256 _stakeID) public view returns (uint256){
        uint256 stakeReduction = StakeManager.getWithdrawnStakeTaxReduction(_user, _stakeID);
        uint256 walletReduction = walletTaxReduction(_user);
        uint256 _totalTaxReduction = stakeReduction + walletReduction;
        if(_totalTaxReduction >= (dogsDefaultTax - (2 * minDogVarTax))){
            _totalTaxReduction = 300;
        }else{
            _totalTaxReduction = dogsDefaultTax - _totalTaxReduction - minDogVarTax;
        }
        return _totalTaxReduction;
    }

    function readOldStruct2(address _user) public view returns (uint256, uint256, uint256, uint256){
        if(userInfo[_user].lastDepositTime == 0){
                return oldDp.userInfo(_user);
            }
        return (userInfo[_user].walletStartTime,userInfo[_user].overThresholdTimeCounter,userInfo[_user].lastDepositTime,userInfo[_user].totalStaked );
    }

    function setminHoldThreshold(uint256 _minHoldThreshold) external onlyOwner{
        minHoldThreshold = _minHoldThreshold;
    }

    function setPoolSizes(uint256 s1, uint256 s2) external onlyOwner {
        linearPoolSize = s1;
        autoPoolSize = s2;
    }

    function setAutoPool(address _autoPool) external onlyOwner {
        DogPoundAutoPool = IDogPoundPool(_autoPool);
    }

    function setLinearPool(address _linearPool) external onlyOwner {
        DogPoundLinearPool = IDogPoundPool(_linearPool);
    }

    function setStakeManager(IStakeManager _stakeManager) external onlyOwner {
        StakeManager = _stakeManager;
    }

    function changeWalletReductionRate(uint256 walletReduction) external onlyOwner{
        require(walletReduction < 1000);
        walletReductionPerMonth = walletReduction;
    }

    function changeWalletCapReduction(uint256 walletReductionCap) external onlyOwner{
        require(walletReductionCap < 6000);
        loyaltyScoreMaxReduction = walletReductionCap;
    }

    function getAutoPoolSize() external view returns (uint256){
        if(linearPoolSize == 0 ){
            return 0;
        }
        return (autoPoolSize*10000/(linearPoolSize+autoPoolSize));
    }

    function totalStaked(address _user) external view returns (uint256){
        return userInfo[_user].totalStaked;
    }

    function changeBurnPercent(uint256 newBurn) external onlyOwner{
        require(burnPercent < 200);
        burnPercent = newBurn;
    }

    function initUser(address _user) internal {
        if(userInfo[_user].lastDepositTime == 0){
            (uint256 e, uint256 e2,uint256 _deptime, uint256 e3 )= readOldStruct(_user);
            if(_deptime != 0){
                userInfo[_user].walletStartTime = e; 
                userInfo[_user].overThresholdTimeCounter = e2;
                userInfo[_user].lastDepositTime = _deptime;
                userInfo[_user].totalStaked = e3;
            }
        }
    }

    function readOldStruct(address _user) public view returns (uint256, uint256, uint256, uint256){
        return oldDp.userInfo(_user);
    }

    function doSwap(address _to, uint256 _amount, uint256 _taxReduction, address[] memory path) internal  {
        uint256 burnAmount = (_amount * burnPercent)/1000;
        uint256 leftAmount =  _amount - burnAmount;
        uint256 tempTaxval = 1e14/(1e3 - burnPercent);
        uint256 taxreductionNew = (_taxReduction * tempTaxval) / 1e11;

        DogsToken.updateTransferTaxRate(taxreductionNew);
        // make the swap
        PancakeRouter.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            leftAmount,
            0, // accept any amount of tokens
            path,
            _to,
            block.timestamp
        );

        DogsToken.updateTransferTaxRate(dogsDefaultTax);

        DogsToken.burn(burnAmount);

    }

    function doTransfer(address _to, uint256 _amount, uint256 _taxReduction) internal {
        uint256 burnAmount = (_amount * burnPercent)/1000;
        uint256 leftAmount =  _amount - burnAmount;
        uint256 tempTaxval = 1e14/(1e3 - burnPercent);
        uint256 taxreductionNew = (_taxReduction * tempTaxval) / 1e11;

        DogsToken.updateTransferTaxRate(taxreductionNew);

        DogsToken.transfer(_to, leftAmount);

        DogsToken.updateTransferTaxRate(dogsDefaultTax);

        DogsToken.burn(burnAmount);

    }

    function setDogsTokenAndDefaultTax(address _address, uint256 _defaultTax) external onlyOwner {
        DogsToken = IDogsToken(_address);
        dogsDefaultTax = _defaultTax;
    }

    function setRewardsVault(address _rewardsVaultAddress) public onlyOwner{
        rewardsVault = IRewardsVault(_rewardsVaultAddress);
    }

}pragma solidity ^0.8.0;

import "@openzeppelin/contracts/interfaces/IERC20.sol";
import "@openzeppelin/contracts/interfaces/IERC721.sol";

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import "./interfaces/IRewardsVault.sol";
import "./interfaces/IPancakePair.sol";
import "./interfaces/IMasterchefPigs.sol";
import "./interfaces/IPancakeFactory.sol";
import "./interfaces/IDogsToken.sol";
import "./interfaces/IDogPoundActions.sol";
import "./interfaces/IStakeManager.sol";
import "./interfaces/IRewardsVault.sol";
import ".//DogsNftManager.sol";
import "./DogPoundManager.sol";
import "./StakeManager.sol";
import "./StakeManagerV2.sol";
import "./NftPigMcStakingBusd.sol";

interface IDPMOLD {
    function linearPoolSize() external view returns (uint256);

    function autoPoolSize() external view returns (uint256);

    function userInfo(
        address
    ) external view returns (uint256, uint256, uint256, uint256);
}

contract DogPoundManagerV3 is Ownable {
    using SafeERC20 for IERC20;

    DogsNftManager public nftManager;
    StakeManager public stakeManagerV1 =
        StakeManager(0x25A959dDaEcEb50c1B724C603A57fe7b32eCbEeA);
    StakeManagerV2 public stakeManager;
    IDogPoundPool public DogPoundLinearPool =
        IDogPoundPool(0x935B36a774f2c04b8fA92acf3528d7DF681C0297);
    IDogPoundPool public DogPoundAutoPool =
        IDogPoundPool(0xf911D1d7118278f86eedfD94bC7Cd141D299E28D);
    IDogPoundActions public DogPoundActions;
    IRewardsVault public rewardsVault =
        IRewardsVault(0x4c004C4fB925Be396F902DE262F2817dEeBC22Ec);

    uint256 public walletReductionPerMonth = 200;
    uint256 public burnPercent = 30;
    uint256 public minHoldThreshold = 10e18;
    uint256 public dustAmount = 100000;
    uint256 public loyaltyScoreMaxReduction = 1000;
    uint256 public dogsDefaultTax = 9000;
    uint256 public minDogVarTax = 300;
    uint256 public withdrawlRestrictionTime = 24 hours;
    DogPoundManager public oldDp =
        DogPoundManager(0x1Bc00F2076A97A68511109883B0671721ff51955);
    IDPMOLD public oldOldDp =
        IDPMOLD(0x6dA8227Bc7B576781ffCac69437e17b8D4F4aE41);
    address public dogsToken = 0x198271b868daE875bFea6e6E4045cDdA5d6B9829;
    NftPigMcStakingBusd public nftStakeBusd;
    NftPigMcStakingBusd public nftStakeBnb;
    IDogsToken public DogsToken = IDogsToken(dogsToken);
    IUniswapV2Router02 public constant PancakeRouter =
        IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
    uint256 public linearPoolSize;
    uint256 public autoPoolSize;

    struct UserInfo {
        uint256 walletStartTime;
        uint256 overThresholdTimeCounter;
        uint256 lastDepositTime;
        uint256 totalStaked;
    }

    struct StakeInfo {
        uint256 amount;
        uint256 startTime;
        bool isAutoPool;
    }

    mapping(address => UserInfo) public userInfo;

    constructor(
        address _nftManager,
        address _nftStakeBusd,
        address _nftStakeBnb
    ) {
        nftStakeBusd = NftPigMcStakingBusd(payable(_nftStakeBusd));
        nftStakeBnb = NftPigMcStakingBusd(payable(_nftStakeBnb));
        nftManager = DogsNftManager(_nftManager);

        autoPoolSize = oldDp.autoPoolSize();
        linearPoolSize = oldDp.linearPoolSize();
        _approveTokenIfNeeded(
            0x198271b868daE875bFea6e6E4045cDdA5d6B9829,
            address(PancakeRouter)
        );
        _approveTokenIfNeeded(
            0x198271b868daE875bFea6e6E4045cDdA5d6B9829,
            address(_nftManager)
        );
    }

    function deposit(uint256 _amount, bool _isAutoCompound) external {
        require(_amount > 0, "deposit !> 0");
        initUser(msg.sender);
        stakeManager.saveStake(msg.sender, _amount, _isAutoCompound);
        DogsToken.transferFrom(msg.sender, address(this), _amount);
        if (
            userInfo[msg.sender].totalStaked + _amount >= minHoldThreshold &&
            userInfo[msg.sender].walletStartTime == 0
        ) {
            userInfo[msg.sender].walletStartTime = block.timestamp;
        }
        if (_isAutoCompound) {
            DogsToken.transfer(address(DogPoundAutoPool), _amount);
            DogPoundAutoPool.deposit(msg.sender, _amount);
            autoPoolSize += _amount;
        } else {
            DogsToken.transfer(address(DogPoundLinearPool), _amount);
            DogPoundLinearPool.deposit(msg.sender, _amount);
            linearPoolSize += _amount;
        }
        userInfo[msg.sender].totalStaked += _amount;
        userInfo[msg.sender].lastDepositTime = block.timestamp;
    }

    function depositOldUserInit(
        uint256 _amount,
        bool _isAutoCompound,
        uint256 _lastActiveStake
    ) external {
        require(_amount > 0, "deposit !> 0");
        initUser(msg.sender);
        stakeManager.saveStakeOldUserInit(
            msg.sender,
            _amount,
            _isAutoCompound,
            _lastActiveStake
        );
        DogsToken.transferFrom(msg.sender, address(this), _amount);
        if (
            userInfo[msg.sender].totalStaked >= minHoldThreshold &&
            userInfo[msg.sender].walletStartTime == 0
        ) {
            userInfo[msg.sender].walletStartTime = block.timestamp;
        }
        if (_isAutoCompound) {
            DogsToken.transfer(address(DogPoundAutoPool), _amount);
            DogPoundAutoPool.deposit(msg.sender, _amount);
            autoPoolSize += _amount;
        } else {
            DogsToken.transfer(address(DogPoundLinearPool), _amount);
            DogPoundLinearPool.deposit(msg.sender, _amount);
            linearPoolSize += _amount;
        }
        userInfo[msg.sender].totalStaked += _amount;
        userInfo[msg.sender].lastDepositTime = block.timestamp;
    }

    function withdrawToWallet(uint256 _amount, uint256 _stakeID) external {
        initUser(msg.sender);
        require(
            block.timestamp - userInfo[msg.sender].lastDepositTime >
                withdrawlRestrictionTime,
            "withdrawl locked"
        );
        _withdraw(_amount, _stakeID);
        if (
            userInfo[msg.sender].totalStaked < minHoldThreshold &&
            userInfo[msg.sender].walletStartTime > 0
        ) {
            userInfo[msg.sender].overThresholdTimeCounter +=
                block.timestamp -
                userInfo[msg.sender].walletStartTime;
            userInfo[msg.sender].walletStartTime = 0;
        }
    }

    function swapFromWithdrawnStake(
        uint256 _amount,
        uint256 _tokenID,
        address[] memory path
    ) public {
        initUser(msg.sender);
        uint256 taxReduction = totalTaxReductionWithdrawnStake(
            msg.sender,
            _tokenID
        );
        nftManager.transferFrom(msg.sender, address(this), _tokenID);
        nftManager.useNFTbalance(_tokenID, _amount, address(this));
        doSwap(address(this), _amount, taxReduction, path);
        IERC20 transfertoken = IERC20(path[path.length - 1]);
        uint256 balance = transfertoken.balanceOf(address(this));
        uint256 balance2 = DogsToken.balanceOf(address(this));
        nftManager.returnNFTbalance(_tokenID, balance2, address(this));
        nftManager.utilizeNFTbalance(_tokenID, _amount - balance2);
        transfertoken.transfer(msg.sender, balance);
        if (
            nftManager.nftPotentialBalance(_tokenID) +
                nftStakeBnb.lpAmount(_tokenID) +
                nftStakeBusd.lpAmount(_tokenID) >
            dustAmount
        ) {
            nftManager.transferFrom(address(this), msg.sender, _tokenID);
        } else {
            nftManager.transferFrom(
                address(this),
                0x000000000000000000000000000000000000dEaD,
                _tokenID
            );
        }
    }

    function transferFromWithdrawnStake(
        uint256 _amount,
        address _to,
        uint256 _tokenID
    ) public {
        initUser(msg.sender);
        uint256 taxReduction = totalTaxReductionWithdrawnStake(
            msg.sender,
            _tokenID
        );
        nftManager.transferFrom(msg.sender, address(this), _tokenID);
        nftManager.useNFTbalance(_tokenID, _amount, address(this));
        nftManager.utilizeNFTbalance(_tokenID, _amount);
        doTransfer(_to, _amount, taxReduction);
        if (
            nftManager.nftPotentialBalance(_tokenID) +
                nftStakeBnb.lpAmount(_tokenID) +
                nftStakeBusd.lpAmount(_tokenID) >
            dustAmount
        ) {
            nftManager.transferFrom(address(this), msg.sender, _tokenID);
        } else {
            nftManager.transferFrom(
                address(this),
                0x000000000000000000000000000000000000dEaD,
                _tokenID
            );
        }
    }

    function returnNftBalanceThroughManager(
        uint256 _tokenID,
        uint256 _amount
    ) public {
        nftManager.transferFrom(msg.sender, address(this), _tokenID);
        DogsToken.transferFrom(msg.sender, address(this), _amount);
        nftManager.returnNFTbalance(_tokenID, _amount, address(this));
        nftManager.transferFrom(address(this), msg.sender, _tokenID);
    }

    function _approveTokenIfNeeded(address token, address _address) private {
        if (IERC20(token).allowance(address(this), address(_address)) == 0) {
            IERC20(token).safeApprove(address(_address), type(uint256).max);
        }
    }

    // Internal functions
    function _withdraw(uint256 _amount, uint256 _stakeID) internal {
        bool isAutoPool = stakeManager.isStakeAutoPool(msg.sender, _stakeID);
        if (isAutoPool) {
            DogPoundAutoPool.withdraw(msg.sender, _amount);
            autoPoolSize -= _amount;
        } else {
            DogPoundLinearPool.withdraw(msg.sender, _amount);
            linearPoolSize -= _amount;
        }
        stakeManager.withdrawFromStake(
            msg.sender,
            _amount,
            _stakeID,
            address(this)
        );
        userInfo[msg.sender].totalStaked -= _amount;
    }

    // View functions
    function walletTaxReduction(address _user) public view returns (uint256) {
        UserInfo storage user = userInfo[_user];
        uint256 walletStartTime = user.walletStartTime;
        uint256 overThresholdTimeCounter = user.overThresholdTimeCounter;
        uint256 totalStaked = user.totalStaked;
        if (user.lastDepositTime == 0) {
            (walletStartTime, overThresholdTimeCounter, , ) = oldDp
                .readOldStruct2(_user);
            totalStaked = stakeManagerV1.totalStaked(_user);
        }
        uint256 currentReduction = 0;
        if (totalStaked < minHoldThreshold) {
            currentReduction =
                (overThresholdTimeCounter / 30 days) *
                walletReductionPerMonth;
            if (currentReduction > loyaltyScoreMaxReduction) {
                return loyaltyScoreMaxReduction;
            }
            return currentReduction;
        }
        currentReduction =
            (((block.timestamp - walletStartTime) + overThresholdTimeCounter) /
                30 days) *
            walletReductionPerMonth;
        if (currentReduction > loyaltyScoreMaxReduction) {
            return loyaltyScoreMaxReduction;
        }
        return currentReduction;
    }

    function totalTaxReductionWithdrawnStake(
        address _user,
        uint256 _tokenID
    ) public view returns (uint256) {
        uint256 stakeReduction = stakeManager.getWithdrawnStakeTaxReduction(
            _tokenID
        );
        uint256 walletReduction = walletTaxReduction(_user);
        uint256 _totalTaxReduction = stakeReduction + walletReduction;
        if (_totalTaxReduction >= (dogsDefaultTax - (2 * minDogVarTax))) {
            _totalTaxReduction = 300;
        } else {
            _totalTaxReduction =
                dogsDefaultTax -
                _totalTaxReduction -
                minDogVarTax;
        }
        return _totalTaxReduction;
    }

    function transitionOldWithdrawnStake(
        address _user,
        uint256 _stakeID
    ) external {
        uint256 _amount = stakeManager
            .withdrawnStakeMove(_user, _stakeID)
            .amount;
        DogsToken.transferFrom(msg.sender, address(this), _amount);
        stakeManager.transitionOldWithdrawnStake(
            _user,
            _stakeID,
            address(this)
        );
    }

    function readOldStruct2(
        address _user
    ) public view returns (uint256, uint256, uint256, uint256) {
        if (userInfo[_user].lastDepositTime == 0) {
            return oldDp.readOldStruct2(_user);
        }
        return (
            userInfo[_user].walletStartTime,
            userInfo[_user].overThresholdTimeCounter,
            userInfo[_user].lastDepositTime,
            userInfo[_user].totalStaked
        );
    }

    function setminHoldThreshold(uint256 _minHoldThreshold) external onlyOwner {
        minHoldThreshold = _minHoldThreshold;
    }

    function setPoolSizes(uint256 s1, uint256 s2) external onlyOwner {
        linearPoolSize = s1;
        autoPoolSize = s2;
    }

    function setAutoPool(address _autoPool) external onlyOwner {
        DogPoundAutoPool = IDogPoundPool(_autoPool);
    }

    function setLinearPool(address _linearPool) external onlyOwner {
        DogPoundLinearPool = IDogPoundPool(_linearPool);
    }

    function setNftManager(address _nftManager) external onlyOwner {
        nftManager = DogsNftManager(_nftManager);
        _approveTokenIfNeeded(
            0x198271b868daE875bFea6e6E4045cDdA5d6B9829,
            address(nftManager)
        );
    }

    function setStakeManager(address _stakeManager) external onlyOwner {
        stakeManager = StakeManagerV2(_stakeManager);
    }

    function changeWalletReductionRate(
        uint256 walletReduction
    ) external onlyOwner {
        require(walletReduction < 1000);
        walletReductionPerMonth = walletReduction;
    }

    function changeWalletCapReduction(
        uint256 walletReductionCap
    ) external onlyOwner {
        require(walletReductionCap < 6000);
        loyaltyScoreMaxReduction = walletReductionCap;
    }

    function getAutoPoolSize() external view returns (uint256) {
        if (linearPoolSize == 0) {
            return 0;
        }
        return ((autoPoolSize * 10000) / (linearPoolSize + autoPoolSize));
    }

    function totalStaked(address _user) external view returns (uint256) {
        return userInfo[_user].totalStaked;
    }

    function changeBurnPercent(uint256 newBurn) external onlyOwner {
        require(burnPercent < 200);
        burnPercent = newBurn;
    }

    function initUser(address _user) internal {
        if (userInfo[_user].lastDepositTime == 0) {
            (uint256 e, uint256 e2, uint256 _deptime, uint256 e3) = oldDp
                .readOldStruct2(_user);
            if (_deptime != 0) {
                userInfo[_user].walletStartTime = e;
                userInfo[_user].overThresholdTimeCounter = e2;
                userInfo[_user].lastDepositTime = _deptime;
                userInfo[_user].totalStaked = stakeManagerV1.totalStaked(_user);
            }
        }
    }

    function readOldStruct(
        address _user
    ) public view returns (uint256, uint256, uint256, uint256) {
        return oldDp.userInfo(_user);
    }

    function readOldOldStruct(
        address _user
    ) public view returns (uint256, uint256, uint256, uint256) {
        return oldOldDp.userInfo(_user);
    }

    function doSwap(
        address _to,
        uint256 _amount,
        uint256 _taxReduction,
        address[] memory path
    ) internal {
        uint256 burnAmount = (_amount * burnPercent) / 1000;
        uint256 leftAmount = _amount - burnAmount;
        uint256 tempTaxval = 1e14 / (1e3 - burnPercent);
        uint256 taxreductionNew = (_taxReduction * tempTaxval) / 1e11;

        DogsToken.updateTransferTaxRate(taxreductionNew);
        // make the swap
        PancakeRouter.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            leftAmount,
            0, // accept any amount of tokens
            path,
            _to,
            block.timestamp
        );

        DogsToken.updateTransferTaxRate(dogsDefaultTax);

        DogsToken.burn(burnAmount);
    }

    function doTransfer(
        address _to,
        uint256 _amount,
        uint256 _taxReduction
    ) internal {
        uint256 burnAmount = (_amount * burnPercent) / 1000;
        uint256 leftAmount = _amount - burnAmount;
        uint256 tempTaxval = 1e14 / (1e3 - burnPercent);
        uint256 taxreductionNew = (_taxReduction * tempTaxval) / 1e11;

        DogsToken.updateTransferTaxRate(taxreductionNew);

        DogsToken.transfer(_to, leftAmount);

        DogsToken.updateTransferTaxRate(dogsDefaultTax);

        DogsToken.burn(burnAmount);
    }

    function setDogsTokenAndDefaultTax(
        address _address,
        uint256 _defaultTax
    ) external onlyOwner {
        DogsToken = IDogsToken(_address);
        dogsDefaultTax = _defaultTax;
    }

    function setRewardsVault(address _rewardsVaultAddress) public onlyOwner {
        rewardsVault = IRewardsVault(_rewardsVaultAddress);
    }
}
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/interfaces/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";

import "./interfaces/IDogsToken.sol";
import "./interfaces/IStakeManager.sol";

contract DogsNftManager is Ownable, ERC721, ERC721Enumerable {
    using SafeERC20 for IERC20;
    using Strings for uint256;
    mapping(address => bool) public allowedAddress;
    mapping(uint256 => uint256) public nftHoldingBalance;
    mapping(uint256 => uint256) public nftPotentialBalance;
    mapping(uint256 => uint256) public nftLastTime;
    string public baseURI = "https://animalfarm-nfts.vercel.app/api/nft/";	
    string public baseExtension = "";
    address public dogsToken = 0x198271b868daE875bFea6e6E4045cDdA5d6B9829;
    IDogsToken public DogsToken = IDogsToken(dogsToken);
    uint256 currentTokenID = 50;
    uint256 limitTime = 300;
    modifier onlyAllowedAddress() {
        require(allowedAddress[msg.sender], "allowed only");
        _;
    }

	
    constructor() ERC721("dogpoundNFT", "DPMNFT") {}

    function mintForWithdrawnStake(
        address _to,
        uint256 _amount,
        address _from
    ) external onlyAllowedAddress returns (uint256) {
        uint256 tokenID = currentTokenID;
        DogsToken.transferFrom(_from, address(this), _amount);
        _safeMint(_to, tokenID);
        nftHoldingBalance[tokenID] = _amount;
        nftPotentialBalance[tokenID] = _amount;
        currentTokenID += 1;
        return tokenID;
    }

    function useNFTbalance(
        uint256 _tokenID,
        uint256 _amount,
        address _to
    ) external onlyAllowedAddress {
        require(
            _amount <= nftHoldingBalance[_tokenID],
            "not enough tokens inside nft"
        );
        require(ownerOf(_tokenID) == msg.sender, "caller doesnt own nft");
        nftHoldingBalance[_tokenID] -= _amount;
        DogsToken.transfer(_to, _amount);
        nftLastTime[_tokenID] = block.timestamp;
    }

    function utilizeNFTbalance(
        uint256 _tokenID,
        uint256 _amount
    ) external onlyAllowedAddress {
        require(
            nftPotentialBalance[_tokenID] >= _amount &&
                (nftPotentialBalance[_tokenID] - _amount) >=
                nftHoldingBalance[_tokenID],
            "attempt to over utilize"
        );
        require(ownerOf(_tokenID) == msg.sender, "caller doesnt own nft");
        nftPotentialBalance[_tokenID] -= _amount;
        nftLastTime[_tokenID] = block.timestamp;
    }

    function returnNFTbalance(
        uint256 _tokenID,
        uint256 _amount,
        address _from
    ) external onlyAllowedAddress {
        require(
            (nftHoldingBalance[_tokenID] + _amount) <=
                nftPotentialBalance[_tokenID],
            "attempt to over deposit"
        );
        nftHoldingBalance[_tokenID] += _amount;
        DogsToken.transferFrom(_from, address(this), _amount);
        nftLastTime[_tokenID] = block.timestamp;
    }

    function returnNFTbalancePublic(
        uint256 _tokenID,
        uint256 _amount
    ) external {
        require(
            (nftHoldingBalance[_tokenID] + _amount) <=
                nftPotentialBalance[_tokenID],
            "attempt to over deposit"
        );
        require(
            ownerOf(_tokenID) == msg.sender,
            "you must own the nft you want to fill"
        );
        nftHoldingBalance[_tokenID] += _amount;
        DogsToken.transferFrom(msg.sender, address(this), _amount);
        nftLastTime[_tokenID] = block.timestamp;
    }

    function setAllowedAddress(address _address, bool _state) public onlyOwner {
        allowedAddress[_address] = _state;
    }

    function _transfer(
        address from,
        address to,
        uint256 tokenId
    ) internal override {
        require(
            (block.timestamp - nftLastTime[tokenId]) >= limitTime ||
                allowedAddress[from] ||
                allowedAddress[to],
            "transfer cooldown"
        );
        super._transfer(from, to, tokenId);
    }

    function setCooldown(uint256 _cooldown) external onlyOwner {
        limitTime = _cooldown;
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal override(ERC721, ERC721Enumerable) {
        super._beforeTokenTransfer(from, to, tokenId);
    }

    function supportsInterface(
        bytes4 interfaceId
    ) public view override(ERC721, ERC721Enumerable) returns (bool) {
        return super.supportsInterface(interfaceId);
    }

    function tokenURI(
        uint256 tokenId
    ) public view virtual override returns (string memory) {
        require(
            _exists(tokenId),
            "ERC721Metadata: URI query for nonexistent token"
        );
        string memory currentBaseURI = _baseURI();
        return
            bytes(currentBaseURI).length > 0
                ? string(
                    abi.encodePacked(
                        currentBaseURI,
                        tokenId.toString(),
                        baseExtension
                    )
                )
                : "";
    }

    function setBaseURI(string memory _newBaseURI) public onlyOwner {
        baseURI = _newBaseURI;
    }

    function setBaseExtension(
        string memory _newBaseExtension
    ) public onlyOwner {
        baseExtension = _newBaseExtension;
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return baseURI;
    }
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IDogPoundActions{
    function doSwap(address _from, uint256 _amount, uint256 _taxReduction, address[] memory path) external;
    function doTransfer(address _from, address _to, uint256 _amount, uint256 _taxReduction) external;
}// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IDogsExchangeHelper {
    function addDogsBNBLiquidity(uint256 nativeAmount) external payable returns (uint256 lpAmount, uint256 unusedEth, uint256 unusedToken);
    function addDogsLiquidity(address baseTokenAddress, uint256 baseAmount, uint256 dogsAmount) external returns (uint256 lpAmount, uint256 unusedEth, uint256 unusedToken);
    function buyDogsBNB(uint256 _minAmountOut, address[] memory _path) external payable returns(uint256 amountDogsBought);
    function buyDogs(uint256 _tokenAmount, uint256 _minAmountOut, address[] memory _path) external returns(uint256 amountDogsBought);
}// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/interfaces/IERC20.sol";

interface IDogsToken is IERC20{
    function updateTransferTaxRate(uint256 _txBaseTax) external;
    function updateTransferTaxRateToDefault() external;
    function burn(uint256 _amount) external;
}// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IMasterchefPigs {
    function deposit(uint256 _pid, uint256 _amount) external;
    function pendingPigs(uint256 _pid, address _user) external view returns (uint256);
    function depositMigrator(address _userAddress, uint256 _pid, uint256 _amount) external;
    function withdraw(uint256 _pid, uint256 _amount) external;
}pragma solidity ^0.8.0;

interface IPancakeFactory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
}// SPDX-License-Identifier: MIT
pragma solidity >=0.6.2;

interface IPancakePair {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address owner) external view returns (uint);

    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;

    event Mint(address indexed sender, uint amount0, uint amount1);
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint);
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function price0CumulativeLast() external view returns (uint);
    function price1CumulativeLast() external view returns (uint);
    function kLast() external view returns (uint);

    function mint(address to) external returns (uint liquidity);
    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;

    function initialize(address, address) external;
}// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IRewardsVault {

    function payoutDivs()
    external;

}// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IStakeManager {
    
    struct UserInfo {

        uint256 totalStakedDefault; //linear
        uint256 totalStakedAutoCompound;

        uint256 walletStartTime;
        uint256 overThresholdTimeCounter;

        uint256 activeStakesCount;
        uint256 withdrawStakesCount;

        mapping(uint256 => StakeInfo) activeStakes;
        mapping(uint256 => WithdrawnStakeInfo) withdrawnStakes;

    }

    struct WithdrawnStakeInfo {
        uint256 amount;
        uint256 taxReduction;
    }


    struct StakeInfo {
        uint256 amount;
        uint256 startTime;
        bool isAutoPool;
    } // todo find a way to refactor

    function saveStake(address _user, uint256 _amount, bool isAutoCompound) external;
    function withdrawFromStake(address _user,uint256 _amount, uint256 _stakeID) external;
    function getUserStake(address _user, uint256 _stakeID) external view returns (StakeInfo memory);
    function getActiveStakeTaxReduction(address _user, uint256 _stakeID) external view returns (uint256);
    function getWithdrawnStakeTaxReduction(address _user, uint256 _stakeID) external view returns (uint256);
    function isStakeAutoPool(address _user, uint256 _stakeID) external view returns (bool);
    function totalStaked(address _user) external view returns (uint256);
    function utilizeWithdrawnStake(address _user, uint256 _amount, uint256 _stakeID) external;
}pragma solidity >=0.7.0 <0.9.0;
import '@uniswap/v2-core/contracts/interfaces/IUniswapV2Pair.sol';
import '@uniswap/v2-core/contracts/interfaces/IUniswapV2Factory.sol';
import '@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol';

contract LPToTokenCalculator {
    address private constant UNISWAP_ROUTER_ADDRESS = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    IUniswapV2Router02 public uniswapRouter;

    constructor() public {
        uniswapRouter = IUniswapV2Router02(UNISWAP_ROUTER_ADDRESS);
    }

    function calculateTokensFromLPBusd(uint lpAmount) external view returns (uint tokenAAmount, uint tokenBAmount) {
        address pairAddress = IUniswapV2Factory(uniswapRouter.factory()).getPair(0x198271b868daE875bFea6e6E4045cDdA5d6B9829, 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56);
        IUniswapV2Pair pair = IUniswapV2Pair(pairAddress);
        
        (uint112 reserve0, uint112 reserve1,) = pair.getReserves();
        uint totalSupply = pair.totalSupply();

        // Calculate token amounts
        tokenAAmount = (uint(reserve0) * lpAmount) / totalSupply;
        tokenBAmount = (uint(reserve1) * lpAmount) / totalSupply;
    }

    function calculateTokensFromLPBnb(uint lpAmount) external view returns (uint tokenAAmount, uint tokenBAmount) {
        address pairAddress = IUniswapV2Factory(uniswapRouter.factory()).getPair(0x198271b868daE875bFea6e6E4045cDdA5d6B9829, 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c);
        IUniswapV2Pair pair = IUniswapV2Pair(pairAddress);
        
        (uint112 reserve0, uint112 reserve1,) = pair.getReserves();
        uint totalSupply = pair.totalSupply();

        // Calculate token amounts
        tokenAAmount = (uint(reserve0) * lpAmount) / totalSupply;
        tokenBAmount = (uint(reserve1) * lpAmount) / totalSupply;
    }

}
import "@openzeppelin/contracts/interfaces/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";

import ".//DogsNftManager.sol";
import "./StakeManagerV2.sol";
import "./interfaces/IDogsExchangeHelper.sol";
import "./interfaces/IDogsToken.sol";
import "./interfaces/IMasterchefPigs.sol";

contract NftPigMcStakingBnb is
    Ownable //consider doing structure where deposit withdraw etc are done through the dpm to avoid extra approvals
{
    using SafeERC20 for IERC20;

    IERC20 public PigsToken =
        IERC20(0x9a3321E1aCD3B9F6debEE5e042dD2411A1742002);
    IERC20 public BnbToken = IERC20(0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c);
    IERC20 public Dogs_BNB_LpToken =
        IERC20(0x2139C481d4f31dD03F924B6e87191E15A33Bf8B4);
    address public dogsToken = 0x198271b868daE875bFea6e6E4045cDdA5d6B9829;
    uint256 public lastPigsBalance = 0;
    uint256 public pigsRoundMask = 0;
    uint256 public lpStakedTotal;
    IDogsToken public DogsToken = IDogsToken(dogsToken);
    DogsNftManager public nftManager;
    IMasterchefPigs public MasterchefPigs =
        IMasterchefPigs(0x8536178222fC6Ec5fac49BbfeBd74CA3051c638f);
    IDogsExchangeHelper public DogsExchangeHelper =
        IDogsExchangeHelper(0xB59686fe494D1Dd6d3529Ed9df384cD208F182e8);

    IUniswapV2Router02 public constant PancakeRouter =
        IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
    mapping(uint256 => NftInfo) public nftInfo;

    receive() external payable {}

    struct NftInfo {
        uint256 lpAmount;
        uint256 pigsMask;
    }

    constructor(address _nftManager) {
        nftManager = DogsNftManager(_nftManager);
        _approveTokenIfNeeded(dogsToken, address(_nftManager));
        _approveTokenIfNeeded(dogsToken, address(DogsExchangeHelper));
        _approveTokenIfNeeded(address(BnbToken), address(DogsExchangeHelper));
    }

    function deposit(
        uint256 _tokenID,
        uint256 _dogsAmount,
        uint256 _bnbAmount
    ) external {
        nftManager.transferFrom(msg.sender, address(this), _tokenID);
        claimPigsRewardsInternal(_tokenID);
        nftManager.useNFTbalance(_tokenID, _dogsAmount, address(this));
        BnbToken.transferFrom(msg.sender, address(this), _bnbAmount);
        (
            uint256 dogsBnbLpReceived,
            uint256 balance2,
            uint256 balance
        ) = DogsExchangeHelper.addDogsLiquidity(
                address(BnbToken),
                _bnbAmount,
                _dogsAmount
            );
        nftManager.returnNFTbalance(_tokenID, balance2, address(this));
        BnbToken.transfer(msg.sender, balance);
        // nftInfo[_tokenID].dogAmount += _dogsAmount - balance2;
        nftInfo[_tokenID].lpAmount += dogsBnbLpReceived;
        _stakeIntoMCPigs(dogsBnbLpReceived);
        nftManager.transferFrom(address(this), msg.sender, _tokenID);
    }

    function withdraw(uint256 _tokenID, uint256 _lpPercent) external {
        require(_lpPercent <= 10000, "invalid percent");
        nftManager.transferFrom(msg.sender, address(this), _tokenID);
        uint256 lpToWithdraw = (nftInfo[_tokenID].lpAmount * _lpPercent) /
            10000;
        MasterchefPigs.withdraw(1, lpToWithdraw);
        handlePigsIncrease();
        claimPigsRewardsInternal(_tokenID);
        lpStakedTotal -= lpToWithdraw;
        (uint256 bnbRemoved, uint256 dogsRemoved) = removeLiquidityFromPair(
            lpToWithdraw
        );
        nftInfo[_tokenID].lpAmount -= lpToWithdraw;
        BnbToken.transfer(msg.sender, bnbRemoved);
        uint256 nftMaxBal = nftManager.nftPotentialBalance(_tokenID);
        uint256 nftCurBal = nftManager.nftHoldingBalance(_tokenID);
        if (dogsRemoved > nftMaxBal - nftCurBal) {
            uint256 fillAmount = nftMaxBal - nftCurBal;
            nftManager.returnNFTbalance(_tokenID, fillAmount, address(this));
            DogsToken.transfer(msg.sender, dogsRemoved - fillAmount);
        } else {
            nftManager.returnNFTbalance(_tokenID, dogsRemoved, address(this));
        }
        nftManager.transferFrom(address(this), msg.sender, _tokenID);
    }

    function claimPigsRewardsInternal(uint256 _tokenID) internal {
        uint256 pigsAmount = (nftInfo[_tokenID].lpAmount *
            (pigsRoundMask - nftInfo[_tokenID].pigsMask)) / 1e18;
        if (pigsAmount > lastPigsBalance) {
            pigsAmount = lastPigsBalance;
        }
        PigsToken.transfer(msg.sender, pigsAmount);
        lastPigsBalance -= pigsAmount;
        updateNftMask(_tokenID);
    }

    function claimPigsRewardsPublic(uint256[] memory _tokenIDs) public {
        for (uint256 i = 0; i < _tokenIDs.length; i++) {
            uint256 _tokenID = _tokenIDs[i];
            require(nftManager.ownerOf(_tokenID) == msg.sender, "not owner");
            uint256 pigsAmount = (nftInfo[_tokenID].lpAmount *
                (pigsRoundMask - nftInfo[_tokenID].pigsMask)) / 1e18;
            if (pigsAmount > lastPigsBalance) {
                pigsAmount = lastPigsBalance;
            }
            PigsToken.transfer(msg.sender, pigsAmount);
            lastPigsBalance -= pigsAmount;
            updateNftMask(_tokenID);
        }
    }

    function removeLiquidityFromPair(
        uint256 _amount
    ) internal returns (uint256 bnbRemoved, uint256 dogsRemoved) {
        Dogs_BNB_LpToken.approve(address(PancakeRouter), _amount);
        // add the liquidity
        (bnbRemoved, dogsRemoved) = PancakeRouter.removeLiquidity(
            address(BnbToken),
            dogsToken,
            _amount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            address(this),
            block.timestamp
        );
    }

    function pendingRewards(
        uint256 _tokenID
    ) external view returns (uint256 pigsAmount) {
        pigsAmount =
            (nftInfo[_tokenID].lpAmount *
                (pigsRoundMask - nftInfo[_tokenID].pigsMask)) /
            1e18;
    }

    function lpAmount(
        uint256 _tokenID
    ) external view returns (uint256 _lpAmount) {
        _lpAmount = nftInfo[_tokenID].lpAmount;
    }

    function _approveTokenIfNeeded(address token, address _address) private {
        if (IERC20(token).allowance(address(this), address(_address)) == 0) {
            IERC20(token).safeApprove(address(_address), type(uint256).max);
        }
    }

    function handlePigsIncrease() internal {
        uint256 pigsEarned = getPigsEarned();
        pigsRoundMask += (pigsEarned * 1e18) / lpStakedTotal;
    }

    function _stakeIntoMCPigs(uint256 _amountLP) internal {
        allowanceCheckAndSet(
            IERC20(Dogs_BNB_LpToken),
            address(MasterchefPigs),
            _amountLP
        );
        MasterchefPigs.deposit(1, _amountLP);
        lpStakedTotal += _amountLP;
        handlePigsIncrease();
    }

    function allowanceCheckAndSet(
        IERC20 _token,
        address _spender,
        uint256 _amount
    ) internal {
        uint256 allowance = _token.allowance(address(this), _spender);
        if (allowance < _amount) {
            require(_token.approve(_spender, _amount), "allowance err");
        }
    }

    function setNftManager(address _nftManager) external onlyOwner {
        nftManager = DogsNftManager(_nftManager);
        _approveTokenIfNeeded(dogsToken, address(nftManager));
    }

    function getPigsEarned() internal returns (uint256) {
        uint256 pigsBalance = PigsToken.balanceOf(address(this));
        uint256 pigsEarned = pigsBalance - lastPigsBalance;
        lastPigsBalance = pigsBalance;
        return pigsEarned;
    }

    function updateNftMask(uint256 _tokenID) internal {
        nftInfo[_tokenID].pigsMask = pigsRoundMask;
    }
}
import "@openzeppelin/contracts/interfaces/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

import ".//DogsNftManager.sol";
import "./StakeManagerV2.sol";
import "./interfaces/IDogsExchangeHelper.sol";
import "./interfaces/IDogsToken.sol";
import "./interfaces/IMasterchefPigs.sol";
import "@uniswap/v2-periphery/contracts/interfaces/IWETH.sol";

contract NftPigMcStakingBnbWWrap is
    Ownable,
    ReentrancyGuard //consider doing structure where deposit withdraw etc are done through the dpm to avoid extra approvals
{
    using SafeERC20 for IERC20;

    IERC20 public PigsToken =
        IERC20(0x9a3321E1aCD3B9F6debEE5e042dD2411A1742002);
    IERC20 public BnbToken = IERC20(0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c);
    IERC20 public Dogs_BNB_LpToken =
        IERC20(0x2139C481d4f31dD03F924B6e87191E15A33Bf8B4);
    IWETH wBnb = IWETH(0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c);
    address public dogsToken = 0x198271b868daE875bFea6e6E4045cDdA5d6B9829;
    uint256 public lastPigsBalance = 0;
    uint256 public pigsRoundMask = 0;
    uint256 public lpStakedTotal;
    IDogsToken public DogsToken = IDogsToken(dogsToken);
    DogsNftManager public nftManager;
    IMasterchefPigs public MasterchefPigs =
        IMasterchefPigs(0x8536178222fC6Ec5fac49BbfeBd74CA3051c638f);
    IDogsExchangeHelper public DogsExchangeHelper =
        IDogsExchangeHelper(0xB59686fe494D1Dd6d3529Ed9df384cD208F182e8);

    IUniswapV2Router02 public constant PancakeRouter =
        IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
    mapping(uint256 => NftInfo) public nftInfo;

    receive() external payable {}

    struct NftInfo {
        uint256 lpAmount;
        uint256 pigsMask;
    }

    constructor(address _nftManager) {
        nftManager = DogsNftManager(_nftManager);
        _approveTokenIfNeeded(dogsToken, address(_nftManager));
        _approveTokenIfNeeded(dogsToken, address(DogsExchangeHelper));
        _approveTokenIfNeeded(address(BnbToken), address(DogsExchangeHelper));
    }

    function deposit(
        uint256 _tokenID,
        uint256 _dogsAmount
    ) external payable nonReentrant {
        nftManager.transferFrom(msg.sender, address(this), _tokenID);
        claimPigsRewardsInternal(_tokenID);
        nftManager.useNFTbalance(_tokenID, _dogsAmount, address(this));
        uint256 bnbAmount = msg.value;
        wBnb.deposit{value: bnbAmount}();
        (
            uint256 dogsBnbLpReceived,
            uint256 balance2,
            uint256 balance
        ) = DogsExchangeHelper.addDogsLiquidity(
                address(BnbToken),
                bnbAmount,
                _dogsAmount
            );
        nftManager.returnNFTbalance(_tokenID, balance2, address(this));
        BnbToken.transfer(msg.sender, balance);
        // nftInfo[_tokenID].dogAmount += _dogsAmount - balance2;
        nftInfo[_tokenID].lpAmount += dogsBnbLpReceived;
        _stakeIntoMCPigs(dogsBnbLpReceived);
        nftManager.transferFrom(address(this), msg.sender, _tokenID);
    }

    function withdraw(
        uint256 _tokenID,
        uint256 _lpPercent
    ) external nonReentrant {
        require(_lpPercent <= 10000, "invalid percent");
        nftManager.transferFrom(msg.sender, address(this), _tokenID);
        uint256 lpToWithdraw = (nftInfo[_tokenID].lpAmount * _lpPercent) /
            10000;
        MasterchefPigs.withdraw(1, lpToWithdraw);
        handlePigsIncrease();
        claimPigsRewardsInternal(_tokenID);
        lpStakedTotal -= lpToWithdraw;
        (uint256 bnbRemoved, uint256 dogsRemoved) = removeLiquidityFromPair(
            lpToWithdraw
        );
        nftInfo[_tokenID].lpAmount -= lpToWithdraw;
        wBnb.withdraw(bnbRemoved);
        (bool success, ) = (msg.sender).call{value: bnbRemoved}("");
        require(success, "Transfer failed.");
        uint256 nftMaxBal = nftManager.nftPotentialBalance(_tokenID);
        uint256 nftCurBal = nftManager.nftHoldingBalance(_tokenID);
        if (dogsRemoved > nftMaxBal - nftCurBal) {
            uint256 fillAmount = nftMaxBal - nftCurBal;
            nftManager.returnNFTbalance(_tokenID, fillAmount, address(this));
            DogsToken.transfer(msg.sender, dogsRemoved - fillAmount);
        } else {
            nftManager.returnNFTbalance(_tokenID, dogsRemoved, address(this));
        }
        nftManager.transferFrom(address(this), msg.sender, _tokenID);
    }

    function claimPigsRewardsInternal(uint256 _tokenID) internal {
        uint256 pigsAmount = (nftInfo[_tokenID].lpAmount *
            (pigsRoundMask - nftInfo[_tokenID].pigsMask)) / 1e18;
        if (pigsAmount > lastPigsBalance) {
            pigsAmount = lastPigsBalance;
        }
        PigsToken.transfer(msg.sender, pigsAmount);
        lastPigsBalance -= pigsAmount;
        updateNftMask(_tokenID);
    }

    function claimPigsRewardsPublic(uint256[] memory _tokenIDs) public {
        for (uint256 i = 0; i < _tokenIDs.length; i++) {
            uint256 _tokenID = _tokenIDs[i];
            require(nftManager.ownerOf(_tokenID) == msg.sender, "not owner");
            uint256 pigsAmount = (nftInfo[_tokenID].lpAmount *
                (pigsRoundMask - nftInfo[_tokenID].pigsMask)) / 1e18;
            if (pigsAmount > lastPigsBalance) {
                pigsAmount = lastPigsBalance;
            }
            PigsToken.transfer(msg.sender, pigsAmount);
            lastPigsBalance -= pigsAmount;
            updateNftMask(_tokenID);
        }
    }

    function removeLiquidityFromPair(
        uint256 _amount
    ) internal returns (uint256 bnbRemoved, uint256 dogsRemoved) {
        Dogs_BNB_LpToken.approve(address(PancakeRouter), _amount);
        // add the liquidity
        (bnbRemoved, dogsRemoved) = PancakeRouter.removeLiquidity(
            address(BnbToken),
            dogsToken,
            _amount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            address(this),
            block.timestamp
        );
    }

    function _approveTokenIfNeeded(address token, address _address) private {
        if (IERC20(token).allowance(address(this), address(_address)) == 0) {
            IERC20(token).safeApprove(address(_address), type(uint256).max);
        }
    }

    function handlePigsIncrease() internal {
        uint256 pigsEarned = getPigsEarned();
        pigsRoundMask += (pigsEarned * 1e18) / lpStakedTotal;
    }

    function _stakeIntoMCPigs(uint256 _amountLP) internal {
        allowanceCheckAndSet(
            IERC20(Dogs_BNB_LpToken),
            address(MasterchefPigs),
            _amountLP
        );
        MasterchefPigs.deposit(1, _amountLP);
        lpStakedTotal += _amountLP;
        handlePigsIncrease();
    }

    function pendingRewards(
        uint256 _tokenID
    ) external view returns (uint256 pigsAmount) {
        pigsAmount =
            (nftInfo[_tokenID].lpAmount *
                (pigsRoundMask - nftInfo[_tokenID].pigsMask)) /
            1e18;
    }

    function lpAmount(
        uint256 _tokenID
    ) external view returns (uint256 _lpAmount) {
        _lpAmount = nftInfo[_tokenID].lpAmount;
    }

    function allowanceCheckAndSet(
        IERC20 _token,
        address _spender,
        uint256 _amount
    ) internal {
        uint256 allowance = _token.allowance(address(this), _spender);
        if (allowance < _amount) {
            require(_token.approve(_spender, _amount), "allowance err");
        }
    }

    function setNftManager(address _nftManager) external onlyOwner {
        nftManager = DogsNftManager(_nftManager);
        _approveTokenIfNeeded(dogsToken, address(nftManager));
    }

    function getPigsEarned() internal returns (uint256) {
        uint256 pigsBalance = PigsToken.balanceOf(address(this));
        uint256 pigsEarned = pigsBalance - lastPigsBalance;
        lastPigsBalance = pigsBalance;
        return pigsEarned;
    }

    function updateNftMask(uint256 _tokenID) internal {
        nftInfo[_tokenID].pigsMask = pigsRoundMask;
    }
}
import "@openzeppelin/contracts/interfaces/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";

import ".//DogsNftManager.sol";
import "./StakeManagerV2.sol";
import "./interfaces/IDogsExchangeHelper.sol";
import "./interfaces/IDogsToken.sol";
import "./interfaces/IMasterchefPigs.sol";

contract NftPigMcStakingBusd is
    Ownable //consider doing structure where deposit withdraw etc are done through the dpm to avoid extra approvals
{
    using SafeERC20 for IERC20;

    IERC20 public PigsToken =
        IERC20(0x9a3321E1aCD3B9F6debEE5e042dD2411A1742002);
    IERC20 public BusdToken =
        IERC20(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56);
    IERC20 public Dogs_BUSD_LpToken =
        IERC20(0xb5151965b13872B183EBa08e33D0d06743AC8132);
    address public dogsToken = 0x198271b868daE875bFea6e6E4045cDdA5d6B9829;
    uint256 public lastPigsBalance = 0;
    uint256 public pigsRoundMask = 0;
    uint256 public lpStakedTotal;
    IDogsToken public DogsToken = IDogsToken(dogsToken);
    DogsNftManager public nftManager;
    IMasterchefPigs public MasterchefPigs =
        IMasterchefPigs(0x8536178222fC6Ec5fac49BbfeBd74CA3051c638f);
    IDogsExchangeHelper public DogsExchangeHelper =
        IDogsExchangeHelper(0xB59686fe494D1Dd6d3529Ed9df384cD208F182e8);

    IUniswapV2Router02 public constant PancakeRouter =
        IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
    mapping(uint256 => NftInfo) public nftInfo;

    receive() external payable {}

    struct NftInfo {
        uint256 lpAmount;
        uint256 pigsMask;
    }

    constructor(address _nftManager) {
        nftManager = DogsNftManager(_nftManager);
        _approveTokenIfNeeded(dogsToken, address(_nftManager));
        _approveTokenIfNeeded(dogsToken, address(DogsExchangeHelper));
        _approveTokenIfNeeded(address(BusdToken), address(DogsExchangeHelper));
    }

    function deposit(
        uint256 _tokenID,
        uint256 _dogsAmount,
        uint256 _busdAmount
    ) external {
        nftManager.transferFrom(msg.sender, address(this), _tokenID);
        claimPigsRewardsInternal(_tokenID);
        nftManager.useNFTbalance(_tokenID, _dogsAmount, address(this));
        BusdToken.transferFrom(msg.sender, address(this), _busdAmount);
        (
            uint256 dogsBusdLpReceived,
            uint256 balance2,
            uint256 balance
        ) = DogsExchangeHelper.addDogsLiquidity(
                address(BusdToken),
                _busdAmount,
                _dogsAmount
            );
        nftManager.returnNFTbalance(_tokenID, balance2, address(this));
        BusdToken.transfer(msg.sender, balance);
        // nftInfo[_tokenID].dogAmount += _dogsAmount - balance2;
        nftInfo[_tokenID].lpAmount += dogsBusdLpReceived;
        _stakeIntoMCPigs(dogsBusdLpReceived);
        nftManager.transferFrom(address(this), msg.sender, _tokenID);
    }

    function withdraw(uint256 _tokenID, uint256 _lpPercent) external {
        require(_lpPercent <= 10000, "invalid percent");
        nftManager.transferFrom(msg.sender, address(this), _tokenID);
        uint256 lpToWithdraw = (nftInfo[_tokenID].lpAmount * _lpPercent) /
            10000;
        MasterchefPigs.withdraw(0, lpToWithdraw);
        handlePigsIncrease();
        claimPigsRewardsInternal(_tokenID);
        lpStakedTotal -= lpToWithdraw;
        (uint256 busdRemoved, uint256 dogsRemoved) = removeLiquidityFromPair(
            lpToWithdraw
        );
        nftInfo[_tokenID].lpAmount -= lpToWithdraw;
        BusdToken.transfer(msg.sender, busdRemoved);
        uint256 nftMaxBal = nftManager.nftPotentialBalance(_tokenID);
        uint256 nftCurBal = nftManager.nftHoldingBalance(_tokenID);
        if (dogsRemoved > nftMaxBal - nftCurBal) {
            uint256 fillAmount = nftMaxBal - nftCurBal;
            nftManager.returnNFTbalance(_tokenID, fillAmount, address(this));
            DogsToken.transfer(msg.sender, dogsRemoved - fillAmount);
        } else {
            nftManager.returnNFTbalance(_tokenID, dogsRemoved, address(this));
        }
        nftManager.transferFrom(address(this), msg.sender, _tokenID);
    }

    function claimPigsRewardsInternal(uint256 _tokenID) internal {
        uint256 pigsAmount = (nftInfo[_tokenID].lpAmount *
            (pigsRoundMask - nftInfo[_tokenID].pigsMask)) / 1e18;
        if (pigsAmount > lastPigsBalance) {
            pigsAmount = lastPigsBalance;
        }
        PigsToken.transfer(msg.sender, pigsAmount);
        lastPigsBalance -= pigsAmount;
        updateNftMask(_tokenID);
    }

    function claimPigsRewardsPublic(uint256[] memory _tokenIDs) public {
        for (uint256 i = 0; i < _tokenIDs.length; i++) {
            uint256 _tokenID = _tokenIDs[i];
            require(nftManager.ownerOf(_tokenID) == msg.sender, "not owner");
            uint256 pigsAmount = (nftInfo[_tokenID].lpAmount *
                (pigsRoundMask - nftInfo[_tokenID].pigsMask)) / 1e18;
            if (pigsAmount > lastPigsBalance) {
                pigsAmount = lastPigsBalance;
            }
            PigsToken.transfer(msg.sender, pigsAmount);
            lastPigsBalance -= pigsAmount;
            updateNftMask(_tokenID);
        }
    }

    function removeLiquidityFromPair(
        uint256 _amount
    ) internal returns (uint256 busdRemoved, uint256 dogsRemoved) {
        Dogs_BUSD_LpToken.approve(address(PancakeRouter), _amount);
        // add the liquidity
        (busdRemoved, dogsRemoved) = PancakeRouter.removeLiquidity(
            address(BusdToken),
            dogsToken,
            _amount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            address(this),
            block.timestamp
        );
    }

    function _approveTokenIfNeeded(address token, address _address) private {
        if (IERC20(token).allowance(address(this), address(_address)) == 0) {
            IERC20(token).safeApprove(address(_address), type(uint256).max);
        }
    }

    function handlePigsIncrease() internal {
        uint256 pigsEarned = getPigsEarned();
        pigsRoundMask += (pigsEarned * 1e18) / lpStakedTotal;
    }

    function _stakeIntoMCPigs(uint256 _amountLP) internal {
        allowanceCheckAndSet(
            IERC20(Dogs_BUSD_LpToken),
            address(MasterchefPigs),
            _amountLP
        );
        MasterchefPigs.deposit(0, _amountLP);
        lpStakedTotal += _amountLP;
        handlePigsIncrease();
    }

    function allowanceCheckAndSet(
        IERC20 _token,
        address _spender,
        uint256 _amount
    ) internal {
        uint256 allowance = _token.allowance(address(this), _spender);
        if (allowance < _amount) {
            require(_token.approve(_spender, _amount), "allowance err");
        }
    }

    function pendingRewards(
        uint256 _tokenID
    ) external view returns (uint256 pigsAmount) {
        pigsAmount =
            (nftInfo[_tokenID].lpAmount *
                (pigsRoundMask - nftInfo[_tokenID].pigsMask)) /
            1e18;
    }

    function lpAmount(
        uint256 _tokenID
    ) external view returns (uint256 _lpAmount) {
        _lpAmount = nftInfo[_tokenID].lpAmount;
    }

    function setNftManager(address _nftManager) external onlyOwner {
        nftManager = DogsNftManager(_nftManager);
        _approveTokenIfNeeded(dogsToken, address(nftManager));
    }

    function getPigsEarned() internal returns (uint256) {
        uint256 pigsBalance = PigsToken.balanceOf(address(this));
        uint256 pigsEarned = pigsBalance - lastPigsBalance;
        lastPigsBalance = pigsBalance;
        return pigsEarned;
    }

    function updateNftMask(uint256 _tokenID) internal {
        nftInfo[_tokenID].pigsMask = pigsRoundMask;
    }
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./DogsNftManager.sol";
import "./LPToTokenCalculator.sol";
import "./StakeManagerV2.sol";
import "./NftPigMcStakingBusd.sol";
import "./NftPigMcStakingBnb.sol";

contract NftReadContract {
 
  LPToTokenCalculator public lpCalc =  LPToTokenCalculator(0x1e55514a1bA84cC4144841111A5BAdA6D1416D08);
  StakeManagerV2 public stakeManager;
  NftPigMcStakingBnb public nftPigMcStakingBnb;
  NftPigMcStakingBusd public nftPigMcStakingBusd; 
  

  
  struct WithdrawnStakeInfoView2 {
        uint256 nftID;
        uint256 currentAmount;
        uint256 potentialAmount;
        uint256 dogsInLP;
        uint256 busdLP;
        uint256 bnbLP;
        uint256 pigsPendingBusd;
        uint256 pigsPendingBnb;
        uint256 taxReduction;
        uint256 endTime;
        bool isAutoPool;

  }

  constructor (address _stakeManager, address _stakebusd, address _stakebnb) {
    stakeManager = StakeManagerV2(_stakeManager);
    nftPigMcStakingBusd = NftPigMcStakingBusd(payable(_stakebusd));
    nftPigMcStakingBnb = NftPigMcStakingBnb(payable(_stakebnb));
  }



  function getUserWithdrawnStakes(address _user) external view returns(WithdrawnStakeInfoView2 [] memory ) {
    StakeManagerV2.WithdrawnStakeInfoView[] memory stakesinit = stakeManager.getUserWithdrawnStakes(_user);
    uint256 len = stakesinit.length;
    WithdrawnStakeInfoView2[] memory stakes = new WithdrawnStakeInfoView2[](len);
    for(uint256 i = 0; i < len ; i++){
      uint256 nftId = stakesinit[i].nftID;
      (uint256 lpAmountBusd , )  = (nftPigMcStakingBusd.nftInfo(nftId));
      (uint256 lpAmountBnb , ) = (nftPigMcStakingBnb.nftInfo(nftId));
      (uint256 lpTotalBusd, ) = lpCalc.calculateTokensFromLPBusd(lpAmountBusd);
      (uint256 lpTotalBnb, ) = lpCalc.calculateTokensFromLPBnb(lpAmountBnb);
      uint256 lpTotal = lpTotalBusd + lpTotalBnb;
      stakes[i].nftID = stakesinit[i].nftID;
      stakes[i].currentAmount = stakesinit[i].currentAmount;
      stakes[i].potentialAmount = stakesinit[i].potentialAmount;
      stakes[i].dogsInLP = lpTotal;
      stakes[i].busdLP = lpAmountBusd;
      stakes[i].bnbLP = lpAmountBnb;
      stakes[i].pigsPendingBusd = nftPigMcStakingBusd.pendingRewards(stakesinit[i].nftID);
      stakes[i].pigsPendingBnb = nftPigMcStakingBnb.pendingRewards(stakesinit[i].nftID);
      stakes[i].taxReduction = stakesinit[i].taxReduction;
      stakes[i].endTime = stakesinit[i].endTime;
      stakes[i].isAutoPool = stakesinit[i].isAutoPool;
    }

    return stakes;
    
  }


  function getWithdrawnStakeInfo(uint256 _tokenId) external view returns (WithdrawnStakeInfoView2 memory){
    StakeManagerV2.WithdrawnStakeInfoView memory stakeinit = stakeManager.getUserWithdrawnStake(_tokenId);
    WithdrawnStakeInfoView2 memory returnStake;
    (uint256 lpAmountBusd , )  = (nftPigMcStakingBusd.nftInfo(_tokenId));
    (uint256 lpAmountBnb , ) = (nftPigMcStakingBnb.nftInfo(_tokenId));
    (uint256 lpTotalBusd, ) = lpCalc.calculateTokensFromLPBusd(lpAmountBusd);
    (uint256 lpTotalBnb, ) = lpCalc.calculateTokensFromLPBnb(lpAmountBnb);
    uint256 lpTotal = lpTotalBusd + lpTotalBnb;
    returnStake.nftID = stakeinit.nftID;
    returnStake.currentAmount = stakeinit.currentAmount;
    returnStake.potentialAmount = stakeinit.potentialAmount;
    returnStake.dogsInLP = lpTotal;
    returnStake.taxReduction = stakeinit.taxReduction;
    returnStake.endTime = stakeinit.endTime;
    returnStake.isAutoPool = stakeinit.isAutoPool;
    returnStake.busdLP = lpAmountBusd;
    returnStake.bnbLP = lpAmountBnb;
    returnStake.pigsPendingBusd = nftPigMcStakingBusd.pendingRewards(stakeinit.nftID);
    returnStake.pigsPendingBnb = nftPigMcStakingBnb.pendingRewards(stakeinit.nftID);
    return returnStake;
  }



}// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";


contract StakeManager is Ownable{

    struct UserInfo {

        uint256 totalStakedDefault; //linear
        uint256 totalStakedAutoCompound;

        uint256 walletStartTime;
        uint256 overThresholdTimeCounter;

        uint256 activeStakesCount;
        uint256 withdrawStakesCount;

        mapping(uint256 => StakeInfo) activeStakes;
        mapping(uint256 => WithdrawnStakeInfo) withdrawnStakes;

    }

    struct StakeInfo {
        uint256 amount;
        uint256 startTime;
        bool isAutoPool;
    } 

    struct StakeInfoView {
        uint256 stakeID;
        uint256 taxReduction;
        uint256 amount;
        uint256 startTime;
        bool isAutoPool;
    } 

    struct WithdrawnStakeInfo {
        uint256 amount;
        uint256 taxReduction;
        uint256 endTime;
        bool isAutoPool;
    }

    struct WithdrawnStakeInfoView {
        uint256 stakeID;
        uint256 amount;
        uint256 taxReduction;
        uint256 endTime;
        bool isAutoPool;

    }


    address public DogPoundManger;
    mapping(address => UserInfo) userInfo;


    uint256 public reliefPerDay = 75;      // 0.75% default
    uint256 public reliefPerDayExtra = 25; // 0.25%

    constructor(address _DogPoundManger){
        DogPoundManger = _DogPoundManger;
    }

    modifier onlyDogPoundManager() {
        require(DogPoundManger == msg.sender, "manager only");
        _;
    }

    function saveStake(address _user, uint256 _amount, bool _isAutoCompound) onlyDogPoundManager external{
        UserInfo storage user = userInfo[_user];
        user.activeStakes[user.activeStakesCount].amount = _amount;
        user.activeStakes[user.activeStakesCount].startTime = block.timestamp;
        user.activeStakes[user.activeStakesCount].isAutoPool = _isAutoCompound;
        user.activeStakesCount++;
        if(_isAutoCompound){
            user.totalStakedAutoCompound += _amount;
        }else{
            user.totalStakedDefault += _amount;
        }
    }

    function withdrawFromStake(address _user,uint256 _amount, uint256 _stakeID) onlyDogPoundManager  external{
        UserInfo storage user = userInfo[_user];
        StakeInfo storage activeStake = user.activeStakes[_stakeID];
        require(_amount > 0, "withdraw: zero amount");
        require(activeStake.amount >= _amount, "withdraw: not good");
        uint256 withdrawCount = user.withdrawStakesCount;
        uint256 taxReduction = getActiveStakeTaxReduction(_user, _stakeID);
        bool isAutoCompound = isStakeAutoPool(_user,_stakeID);
        user.withdrawnStakes[withdrawCount].amount = _amount;
        user.withdrawnStakes[withdrawCount].taxReduction = taxReduction;
        user.withdrawnStakes[withdrawCount].endTime = block.timestamp;
        user.withdrawnStakes[withdrawCount].isAutoPool = isAutoCompound;
        user.withdrawStakesCount++;
        activeStake.amount -= _amount;
        if(isAutoCompound){
            user.totalStakedAutoCompound -= _amount;
        }else{
            user.totalStakedDefault -= _amount;
        }

    }

    function utilizeWithdrawnStake(address _user, uint256 _amount, uint256 _stakeID) onlyDogPoundManager external {
        UserInfo storage user = userInfo[_user];
        WithdrawnStakeInfo storage withdrawnStake = user.withdrawnStakes[_stakeID];
        require(withdrawnStake.amount >= _amount);
        user.withdrawnStakes[_stakeID].amount -= _amount;
    }

    function getUserActiveStakes(address _user) public view returns (StakeInfoView[] memory){
        UserInfo storage user = userInfo[_user];
        StakeInfoView[] memory stakes = new StakeInfoView[](user.activeStakesCount);
        for (uint256 i=0; i < user.activeStakesCount; i++){
            stakes[i] = StakeInfoView({
                stakeID : i,
                taxReduction:getActiveStakeTaxReduction(_user,i),
                amount : user.activeStakes[i].amount,
                startTime : user.activeStakes[i].startTime,
                isAutoPool : user.activeStakes[i].isAutoPool
            });
        }
        return stakes;
    }


    function getUserWithdrawnStakes(address _user) public view returns (WithdrawnStakeInfoView[] memory){
        UserInfo storage user = userInfo[_user];
        WithdrawnStakeInfoView[] memory stakes = new WithdrawnStakeInfoView[](user.withdrawStakesCount);
        for (uint256 i=0; i < user.withdrawStakesCount; i++){
            stakes[i] = WithdrawnStakeInfoView({
                stakeID : i,
                amount : user.withdrawnStakes[i].amount,
                taxReduction : user.withdrawnStakes[i].taxReduction,
                endTime : user.withdrawnStakes[i].endTime,
                isAutoPool : user.withdrawnStakes[i].isAutoPool
            });
        }
        return stakes;
    }

    function getActiveStakeTaxReduction(address _user, uint256 _stakeID) public view returns (uint256){
        StakeInfo storage activeStake = userInfo[_user].activeStakes[_stakeID];
        uint256 relief = reliefPerDay;
        if (activeStake.isAutoPool){
            relief = reliefPerDay + reliefPerDayExtra;
        }
        uint256 taxReduction = ((block.timestamp - activeStake.startTime) / 24 hours) * relief;
        return taxReduction;

    }

    function getWithdrawnStakeTaxReduction(address _user, uint256 _stakeID) public view returns (uint256){
        UserInfo storage user = userInfo[_user];
        return user.withdrawnStakes[_stakeID].taxReduction;
    }

    function getUserActiveStake(address _user, uint256 _stakeID) external view returns (StakeInfo memory){
        return userInfo[_user].activeStakes[_stakeID];

    }
    
    function changeReliefValues(uint256 relief1,uint256 relief2) external onlyOwner{
        require(relief1+relief2 < 1000);
        reliefPerDay = relief1;
        reliefPerDayExtra = relief2;
    }

    function getUserWithdrawnStake(address _user, uint256 _stakeID) external view returns (WithdrawnStakeInfo memory){
        return userInfo[_user].withdrawnStakes[_stakeID];
    }

    function isStakeAutoPool(address _user, uint256 _stakeID) public view returns (bool){
        return userInfo[_user].activeStakes[_stakeID].isAutoPool;
    }

    function totalStaked(address _user) public view returns (uint256){
        return userInfo[_user].totalStakedDefault + userInfo[_user].totalStakedAutoCompound;
    }
    
    function setDogPoundManager(address _address) public onlyOwner {
        DogPoundManger = _address;
    }

}// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./StakeManager.sol";
import "./DogsNftManager.sol";

contract StakeManagerV2 is Ownable {
    struct UserInfoV2 {
        uint256 activeStakesCount;
        mapping(uint256 => StakeInfo) activeStakes;
    }

    struct StakeInfo {
        uint256 amount;
        uint256 startTime;
        bool isAutoPool;
    }

    struct StakeInfoView {
        uint256 stakeID;
        uint256 taxReduction;
        uint256 amount;
        uint256 startTime;
        bool isAutoPool;
    }

    struct WithdrawnStakeInfoOld {
        uint256 amount;
        uint256 taxReduction;
        uint256 endTime;
        bool isAutoPool;
    }

    struct WithdrawnStakeInfo {
        uint256 taxReduction;
        uint256 endTime;
        bool isAutoPool;
    }

    struct WithdrawnStakeInfoView {
        uint256 nftID;
        uint256 currentAmount;
        uint256 potentialAmount;
        uint256 taxReduction;
        uint256 endTime;
        bool isAutoPool;
    }

    mapping(address => UserInfoV2) public userInfo;
    mapping(uint256 => WithdrawnStakeInfo) public nftWithdrawnStakes;
    mapping(address => bool) public allowedAddress;
    mapping(address => bool) public initAddress;

    StakeManager public stakeManagerV1 =
        StakeManager(0x25A959dDaEcEb50c1B724C603A57fe7b32eCbEeA);
    DogsNftManager public nftManager;
    uint256 public reliefPerDay = 75; // 0.75% default
    uint256 public reliefPerDayExtra = 25; // 0.25%

    constructor(address _DogPoundManger, address _DogsNftManager) {
        allowedAddress[_DogPoundManger] = true;
        nftManager = DogsNftManager(_DogsNftManager);
    }

    modifier onlyAllowedAddress() {
        require(allowedAddress[msg.sender], "allowed only");
        _;
    }

    function saveStake(
        address _user,
        uint256 _amount,
        bool _isAutoCompound
    ) external onlyAllowedAddress {
        if (!initAddress[_user]) {
            userInfo[_user].activeStakesCount = getOldActiveStakeCount(_user);
            initAddress[_user] = true;
        }
        UserInfoV2 storage user = userInfo[_user];
        user.activeStakes[user.activeStakesCount].amount = _amount;
        user.activeStakes[user.activeStakesCount].startTime = block.timestamp;
        user.activeStakes[user.activeStakesCount].isAutoPool = _isAutoCompound;
        user.activeStakesCount++;
    }

    function saveStakeOldUserInit(
        address _user,
        uint256 _amount,
        bool _isAutoCompound,
        uint256 _lastActiveStake
    ) external onlyAllowedAddress {
        require(
            !initAddress[_user] &&
                stakeManagerV1
                    .getUserActiveStake(_user, _lastActiveStake)
                    .startTime !=
                0 &&
                stakeManagerV1
                    .getUserActiveStake(_user, _lastActiveStake + 1)
                    .startTime ==
                0,
            "Passed stake isnt last stake"
        );
        userInfo[_user].activeStakesCount == _lastActiveStake + 1;
        initAddress[_user] = true;
        UserInfoV2 storage user = userInfo[_user];
        user.activeStakes[user.activeStakesCount].amount = _amount;
        user.activeStakes[user.activeStakesCount].startTime = block.timestamp;
        user.activeStakes[user.activeStakesCount].isAutoPool = _isAutoCompound;
        user.activeStakesCount++;
    }

    function withdrawFromStake(
        address _user,
        uint256 _amount,
        uint256 _stakeID,
        address _from
    ) external onlyAllowedAddress {
        UserInfoV2 storage user = userInfo[_user];
        StakeInfo storage activeStake = user.activeStakes[_stakeID];
        if (activeStake.startTime == 0) {
            user.activeStakes[_stakeID] = activeStakeMove(_user, _stakeID);
            activeStake = user.activeStakes[_stakeID];
        }
        require(_amount > 0, "withdraw: zero amount");
        require(activeStake.amount >= _amount, "withdraw: not good");
        uint256 taxReduction = getActiveStakeTaxReduction(_user, _stakeID);
        bool isAutoCompound = activeStake.isAutoPool;
        uint256 nftTokenID = nftManager.mintForWithdrawnStake(
            _user,
            _amount,
            _from
        );
        nftWithdrawnStakes[nftTokenID].taxReduction = taxReduction;
        nftWithdrawnStakes[nftTokenID].endTime = block.timestamp;
        nftWithdrawnStakes[nftTokenID].isAutoPool = isAutoCompound;
        activeStake.amount -= _amount;
    }

    function mergeNFTs(
        //burning usage and aggregation permissions has to be handled outside
        address _from,
        address _to,
        uint256 _amount,
        uint256 _mergeFrom
    ) external onlyAllowedAddress {
        uint256 _nftTokenID = nftManager.mintForWithdrawnStake(
            _to,
            _amount,
            _from
        );
        uint256 _taxReduction = nftWithdrawnStakes[_mergeFrom].taxReduction;
        bool _isAutoCompound = nftWithdrawnStakes[_mergeFrom].isAutoPool;
        uint256 _endTime = nftWithdrawnStakes[_mergeFrom].endTime;
        nftWithdrawnStakes[_nftTokenID].taxReduction = _taxReduction;
        nftWithdrawnStakes[_nftTokenID].endTime = _endTime;
        nftWithdrawnStakes[_nftTokenID].isAutoPool = _isAutoCompound;
    }

    function transitionOldWithdrawnStake(
        address _user,
        uint256 _stakeID,
        address _from
    ) external onlyAllowedAddress {
        WithdrawnStakeInfoOld memory oldStake = withdrawnStakeMoveInternal(
            _user,
            _stakeID
        );
        stakeManagerV1.utilizeWithdrawnStake(_user, oldStake.amount, _stakeID);
        uint256 nftTokenID = nftManager.mintForWithdrawnStake(
            _user,
            oldStake.amount,
            _from
        );
        nftWithdrawnStakes[nftTokenID].taxReduction = oldStake.taxReduction;
        nftWithdrawnStakes[nftTokenID].endTime = oldStake.endTime;
        nftWithdrawnStakes[nftTokenID].isAutoPool = oldStake.isAutoPool;
    }

    function activeStakeMove(
        address _user,
        uint256 _stakeID
    ) public view returns (StakeInfo memory) {
        StakeManager.StakeInfo memory oldActiveStake = stakeManagerV1
            .getUserActiveStake(_user, _stakeID);
        return
            StakeInfo(
                oldActiveStake.amount,
                oldActiveStake.startTime,
                oldActiveStake.isAutoPool
            );
    }

    function withdrawnStakeMove(
        address _user,
        uint256 _stakeID
    ) public view returns (WithdrawnStakeInfoOld memory) {
        StakeManager.WithdrawnStakeInfo
            memory oldWithdrawnStake = stakeManagerV1.getUserWithdrawnStake(
                _user,
                _stakeID
            );
        return
            WithdrawnStakeInfoOld(
                oldWithdrawnStake.amount,
                oldWithdrawnStake.taxReduction,
                oldWithdrawnStake.endTime,
                oldWithdrawnStake.isAutoPool
            );
    }

    function withdrawnStakeMoveInternal(
        address _user,
        uint256 _stakeID
    ) internal view returns (WithdrawnStakeInfoOld memory) {
        StakeManager.WithdrawnStakeInfo
            memory oldWithdrawnStake = stakeManagerV1.getUserWithdrawnStake(
                _user,
                _stakeID
            );
        return
            WithdrawnStakeInfoOld(
                oldWithdrawnStake.amount,
                oldWithdrawnStake.taxReduction,
                oldWithdrawnStake.endTime,
                oldWithdrawnStake.isAutoPool
            );
    }

    function getUserActiveStakes(
        address _user
    ) public view returns (StakeInfoView[] memory) {
        UserInfoV2 storage user = userInfo[_user];
        uint256 listInit = user.activeStakesCount;
        if (listInit == 0) {
            listInit = getOldActiveStakeCount(_user);
        }
        StakeInfoView[] memory stakes = new StakeInfoView[](listInit);
        for (uint256 i = 0; i < listInit; i++) {
            if (user.activeStakes[i].startTime == 0) {
                StakeInfo memory tempInf = activeStakeMove(_user, i);
                stakes[i] = StakeInfoView({
                    stakeID: i,
                    taxReduction: stakeManagerV1.getActiveStakeTaxReduction(
                        _user,
                        i
                    ),
                    amount: tempInf.amount,
                    startTime: tempInf.startTime,
                    isAutoPool: tempInf.isAutoPool
                });
            } else {
                stakes[i] = StakeInfoView({
                    stakeID: i,
                    taxReduction: getActiveStakeTaxReduction(_user, i),
                    amount: user.activeStakes[i].amount,
                    startTime: user.activeStakes[i].startTime,
                    isAutoPool: user.activeStakes[i].isAutoPool
                });
            }
        }
        return stakes;
    }

    function getUserWithdrawnStakes(
        address _user
    ) public view returns (WithdrawnStakeInfoView[] memory) {
        uint256 balance = nftManager.balanceOf(_user);
        WithdrawnStakeInfoView[] memory stakes = new WithdrawnStakeInfoView[](
            balance
        );
        uint256[] memory nftList = new uint256[](balance);
        for (uint256 i = 0; i < balance; i++) {
            nftList[i] = nftManager.tokenOfOwnerByIndex(_user, i);
        }

        for (uint256 i = 0; i < balance; i++) {
            stakes[i] = WithdrawnStakeInfoView({
                nftID: nftList[i],
                currentAmount: nftManager.nftHoldingBalance(nftList[i]),
                potentialAmount: nftManager.nftPotentialBalance(nftList[i]),
                taxReduction: nftWithdrawnStakes[nftList[i]].taxReduction,
                endTime: nftWithdrawnStakes[nftList[i]].endTime,
                isAutoPool: nftWithdrawnStakes[nftList[i]].isAutoPool
            });
        }
        return stakes;
    }

    function getOldActiveStakeCount(
        address _user
    ) internal view returns (uint256) {
        uint256 finalI = 0;
        while (true) {
            if (
                stakeManagerV1.getUserActiveStake(_user, finalI).startTime == 0
            ) {
                break;
            }
            finalI += 100;
        }
        if (finalI != 0) {
            finalI -= 90;
            while (true) {
                if (
                    stakeManagerV1
                        .getUserActiveStake(_user, finalI)
                        .startTime == 0
                ) {
                    break;
                }
                finalI += 10;
            }
            for (uint256 i = finalI - 9; i < finalI; i++) {
                if (
                    stakeManagerV1.getUserActiveStake(_user, i).startTime == 0
                ) {
                    return i;
                }
            }
            return finalI;
        }
        return 0;
    }

    function getActiveStakeTaxReduction(
        address _user,
        uint256 _stakeID
    ) public view returns (uint256) {
        StakeInfo storage activeStake = userInfo[_user].activeStakes[_stakeID];
        uint256 relief = reliefPerDay;
        if (activeStake.isAutoPool) {
            relief = reliefPerDay + reliefPerDayExtra;
        }
        uint256 taxReduction = ((block.timestamp - activeStake.startTime) /
            24 hours) * relief;
        return taxReduction;
    }

    function getWithdrawnStakeTaxReduction(
        uint256 _tokenID
    ) public view returns (uint256) {
        return nftWithdrawnStakes[_tokenID].taxReduction;
    }

    function getUserActiveStake(
        address _user,
        uint256 _stakeID
    ) external view returns (StakeInfo memory) {
        return userInfo[_user].activeStakes[_stakeID];
    }

    function getUserWithdrawnStake(
        uint256 _tokenID
    ) external view returns (WithdrawnStakeInfoView memory) {
        return
            WithdrawnStakeInfoView(
                _tokenID,
                nftManager.nftHoldingBalance(_tokenID),
                nftManager.nftPotentialBalance(_tokenID),
                nftWithdrawnStakes[_tokenID].taxReduction,
                nftWithdrawnStakes[_tokenID].endTime,
                nftWithdrawnStakes[_tokenID].isAutoPool
            );
    }

    function isStakeAutoPool(
        address _user,
        uint256 _stakeID
    ) public view returns (bool) {
        if (userInfo[_user].activeStakes[_stakeID].startTime == 0) {
            return activeStakeMove(_user, _stakeID).isAutoPool;
        } else {
            return userInfo[_user].activeStakes[_stakeID].isAutoPool;
        }
    }

    function changeReliefValues(
        uint256 relief1,
        uint256 relief2
    ) external onlyOwner {
        require(relief1 + relief2 < 1000);
        reliefPerDay = relief1;
        reliefPerDayExtra = relief2;
    }

    function setNftManager(address _nftManager) external onlyOwner {
        nftManager = DogsNftManager(_nftManager);
    }

    function setAllowedAddress(address _address, bool _state) public onlyOwner {
        allowedAddress[_address] = _state;
    }
}
