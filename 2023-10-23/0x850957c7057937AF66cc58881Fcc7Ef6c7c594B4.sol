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
// OpenZeppelin Contracts (last updated v4.8.0) (token/ERC20/ERC20.sol)

pragma solidity ^0.8.0;

import "./IERC20.sol";
import "./extensions/IERC20Metadata.sol";
import "../../utils/Context.sol";

/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20PresetMinterPauser}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.openzeppelin.com/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * We have followed general OpenZeppelin Contracts guidelines: functions revert
 * instead returning `false` on failure. This behavior is nonetheless
 * conventional and does not conflict with the expectations of ERC20
 * applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 *
 * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See {IERC20-approve}.
 */
contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * The default value of {decimals} is 18. To select a different value for
     * {decimals} you should overload it.
     *
     * All two of these values are immutable: they can only be set once during
     * construction.
     */
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5.05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the value {ERC20} uses, unless this function is
     * overridden;
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * NOTE: If `amount` is the maximum `uint256`, the allowance is not updated on
     * `transferFrom`. This is semantically equivalent to an infinite approval.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * NOTE: Does not update the allowance if the current allowance
     * is the maximum `uint256`.
     *
     * Requirements:
     *
     * - `from` and `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     * - the caller must have allowance for ``from``'s tokens of at least
     * `amount`.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, allowance(owner, spender) + addedValue);
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        address owner = _msgSender();
        uint256 currentAllowance = allowance(owner, spender);
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    /**
     * @dev Moves `amount` of tokens from `from` to `to`.
     *
     * This internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     */
    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
            // Overflow not possible: the sum of all balances is capped by totalSupply, and the sum is preserved by
            // decrementing then incrementing.
            _balances[to] += amount;
        }

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        unchecked {
            // Overflow not possible: balance + amount is at most totalSupply + amount, which is checked above.
            _balances[account] += amount;
        }
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
            // Overflow not possible: amount <= accountBalance <= totalSupply.
            _totalSupply -= amount;
        }

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner` s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Updates `owner` s allowance for `spender` based on spent `amount`.
     *
     * Does not update the allowance amount in case of infinite allowance.
     * Revert if not enough allowance is available.
     *
     * Might emit an {Approval} event.
     */
    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }

    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * will be transferred to `to`.
     * - when `from` is zero, `amount` tokens will be minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    /**
     * @dev Hook that is called after any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * has been transferred to `to`.
     * - when `from` is zero, `amount` tokens have been minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens have been burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";

/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
 */
interface IERC20Metadata is IERC20 {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
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
// OpenZeppelin Contracts (last updated v4.8.0) (token/ERC721/ERC721.sol)

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
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {
        //solhint-disable-next-line max-line-length
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: caller is not token owner or approved");

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
    function _transfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {
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
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256, /* firstTokenId */
        uint256 batchSize
    ) internal virtual {
        if (batchSize > 1) {
            if (from != address(0)) {
                _balances[from] -= batchSize;
            }
            if (to != address(0)) {
                _balances[to] += batchSize;
            }
        }
    }

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
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 firstTokenId,
        uint256 batchSize
    ) internal virtual {}
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
pragma solidity ^0.8.8;

import "../data/StructData.sol";

interface IBurn {
    function setStakingContract(address _stakingContract) external;

    function setMarketplaceContract(address _stakingContract) external;

    function setOracleContract(address _oracleContract) external;

    function burnToken(uint256 _totalAmountUsdDecimal) external;

    function getPercentBurn() external returns (uint16);

    function setPercentBurn(uint16 _percentBurn) external;

    function withdrawTokenEmergency(address _token, uint256 _amount) external;

    function recoverLostBNB() external;
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

library StructData {
    struct StakedNFT {
        address stakerAddress;
        uint256 startTime;
        uint256 unlockTime;
        uint256 totalValueStakeUsdWithDecimal;
        uint256 totalClaimedAmountUsdWithDecimal;
        uint256 totalRewardAmountUsdWithDecimal;
        uint16 apr;
        bool isUnstaked;
    }

    struct ChildListData {
        address[] childList;
        uint256 memberCounter;
    }

    struct ListBuyData {
        StructData.InfoBuyData[] childList;
    }

    struct InfoBuyData {
        uint256 timeBuy;
        uint256 valueUsd;
    }

    struct ListSwapData {
        StructData.InfoSwapData[] childList;
    }

    struct InfoSwapData {
        uint256 timeSwap;
        uint256 valueSwap;
    }

    struct ListMaintenance {
        StructData.InfoMaintenanceNft[] childList;
    }

    struct InfoMaintenanceNft {
        uint256 startTimeRepair;
        uint256 endTimeRepair;
    }
}
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./IMarketplace.sol";
import "../oracle/Oracle.sol";
import "../token/FitZenERC20.sol";
import "../data/StructData.sol";

contract DistributionCommission is Ownable {
    address public currency;
    address public marketplaceContract;
    address public oracleContract;
    uint256 private maxNumberDistributionCommission = 250; // 2,5 lan earned hoa hong phan bo
    uint256 private maxDayDistributionCommissionEarn = 180; //day nhan hoa hong phan bo
    uint256 private totalLevelEarn = 8; //day nhan hoa hong phan bo

    mapping(address => StructData.ListBuyData) nftBuyByTimestamp;
    mapping(uint8 => uint16) public commissionPercent;
    mapping(uint8 => uint8) public conditionF1Commission;
    mapping(uint8 => uint16) public orConditionF1Commission;

    constructor(address _currency, address _marketplaceAddress) {
        currency = _currency;
        marketplaceContract = _marketplaceAddress;
        oracleContract = address(0);
        initCommissionPercent();
        initConditionF1Commission();
        initOrConditionF1Commission();
    }

    function initCommissionPercent() internal {
        commissionPercent[1] = 480;
        commissionPercent[2] = 360;
        commissionPercent[3] = 300;
        commissionPercent[4] = 180;
        commissionPercent[5] = 180;
        commissionPercent[6] = 120;
        commissionPercent[7] = 120;
        commissionPercent[8] = 60;
    }

    function initConditionF1Commission() internal {
        conditionF1Commission[1] = 0;
        conditionF1Commission[2] = 0;
        conditionF1Commission[3] = 2;
        conditionF1Commission[4] = 3;
        conditionF1Commission[5] = 4;
        conditionF1Commission[6] = 5;
        conditionF1Commission[7] = 6;
        conditionF1Commission[8] = 8;
    }

    function initOrConditionF1Commission() internal {
        orConditionF1Commission[1] = 0;
        orConditionF1Commission[2] = 0;
        orConditionF1Commission[3] = 500;
        orConditionF1Commission[4] = 500;
        orConditionF1Commission[5] = 500;
        orConditionF1Commission[6] = 1000;
        orConditionF1Commission[7] = 1000;
        orConditionF1Commission[8] = 5000;
    }

    function getCommissionPercent(uint8 _level) external view returns (uint16) {
        return commissionPercent[_level];
    }

    function setCommissionPercent(uint8 _level, uint16 _percent) external onlyOwner {
        commissionPercent[_level] = _percent;
    }

    function getConditionF1Commission(uint8 _level) external view returns (uint8) {
        return conditionF1Commission[_level];
    }

    function setConditionF1Commission(uint8 _level, uint8 _value) external onlyOwner {
        conditionF1Commission[_level] = _value;
    }

    function getOrConditionF1Commission(uint8 _level) external view returns (uint16) {
        return orConditionF1Commission[_level];
    }

    function setOrConditionF1Commission(uint8 _level, uint16 _value) external onlyOwner {
        orConditionF1Commission[_level] = _value;
    }

    function setMaxDayDistributionCommissionEarn(uint256 _value) external onlyOwner {
        require(_value >= 0, "DISTRIBUTE COMMISSION: INVALID VALUE");
        maxDayDistributionCommissionEarn = _value;
    }

    function setMaxNumberDistributionCommission(uint256 _value) external onlyOwner {
        require(_value >= 100, "DISTRIBUTE COMMISSION: INVALID VALUE");
        maxNumberDistributionCommission = _value;
    }

    function setMarketplaceContract(address _marketplaceAddress) external onlyOwner {
        require(_marketplaceAddress != address(0), "DISTRIBUTE COMMISSION: INVALID MARKETPLACE ADDRESS");
        marketplaceContract = _marketplaceAddress;
    }

    function setOracleContract(address _oracleContract) external onlyOwner {
        require(_oracleContract != address(0), "DISTRIBUTE COMMISSION: INVALID ORACLE ADDRESS");
        oracleContract = _oracleContract;
    }

    function setValueBuyAddress(address _wallet, uint256 _totalValue, uint256 timestamp) external {
        require(
            marketplaceContract != address(0) && msg.sender == marketplaceContract,
            "NFT: INVALID CALLER TO SET VALUE BUY DATA"
        );
        StructData.InfoBuyData memory item;
        item.timeBuy = timestamp;
        item.valueUsd = _totalValue;
        nftBuyByTimestamp[_wallet].childList.push(item);
    }

    function setValueBuyAddressByAdmin(address _wallet, uint256 _totalValue, uint256 timestamp) external onlyOwner {
        uint256 totalValue = _totalValue * (10 ** FitZenERC20(currency).decimals());
        StructData.InfoBuyData memory item;
        item.timeBuy = timestamp;
        item.valueUsd = totalValue;
        nftBuyByTimestamp[_wallet].childList.push(item);
    }

    function getNftBuyByTimestamp(address _wallet) external view returns (StructData.ListBuyData memory) {
        return nftBuyByTimestamp[_wallet];
    }

    function calculateEarnMoney(uint256 _valueUsd, uint16 percent, uint256 timeClaim) internal view returns (uint256) {
        uint256 valueClaim = (_valueUsd * percent * timeClaim) /
            (maxDayDistributionCommissionEarn * 100 * 100) /
            (60 * 60 * 24);
        return valueClaim;
    }

    function getClaimDistributeByAddress(address _wallet) external view returns (uint256) {
        uint256 realMaxCommission = getRealMaxCommission(_wallet);
        uint256 maxValueCommission = IMarketplace(marketplaceContract).getMaxCommissionByAddressInUsd(_wallet);
        if (realMaxCommission == 0) {
            return 0;
        }
        uint256 nftCommissionEarned = IMarketplace(marketplaceContract).getNftCommissionEarnedForAccount(_wallet);
        uint256 nftStakeCommissionEarned = IMarketplace(marketplaceContract).getTotalCommissionStakeByAddressInUsd(
            _wallet
        );
        uint256 distributeCommissionEarned = IMarketplace(marketplaceContract)
            .getNftDistributeCommissionEarnedForAccount(_wallet);
        uint256 totalReceived = nftCommissionEarned + nftStakeCommissionEarned + distributeCommissionEarned;
        uint256 canReceive = maxValueCommission - nftCommissionEarned - nftStakeCommissionEarned;
        if (realMaxCommission > canReceive) {
            realMaxCommission = canReceive;
        }
        uint256 maxReceive = realMaxCommission - distributeCommissionEarned;
        if (totalReceived >= maxValueCommission) {
            return 0;
        }
        if (distributeCommissionEarned >= realMaxCommission) {
            return 0;
        }
        address[] memory allF1s = IMarketplace(marketplaceContract).getF1ListForAccount(_wallet);
        uint countF1Meaning = getCountF1BuyMin(allF1s);
        uint256 total = getTotalClaim(allF1s, _wallet, countF1Meaning);
        uint256 totalCanReceive = total - distributeCommissionEarned;
        uint256 realReceive = totalCanReceive;
        if (totalCanReceive > maxReceive) {
            realReceive = maxReceive;
        }
        return realReceive;
    }

    function getF1Next(address[] memory allF1s) internal view returns (address[] memory) {
        uint256 totalFNext = 0;
        address[] memory allF1Result;
        for (uint i = 0; i < allF1s.length; i++) {
            address[] memory allF1Index = IMarketplace(marketplaceContract).getF1ListForAccount(allF1s[i]);
            totalFNext = totalFNext + allF1Index.length;
        }
        if (totalFNext == 0) {
            allF1Result = new address[](0);
        } else {
            uint256 counter = 0;
            address[] memory allFNext = new address[](totalFNext);
            for (uint i = 0; i < allF1s.length; i++) {
                address[] memory allF1Index = IMarketplace(marketplaceContract).getF1ListForAccount(allF1s[i]);
                for (uint j = 0; j < allF1Index.length; j++) {
                    allFNext[counter] = allF1Index[j];
                    counter++;
                }
            }
            allF1Result = allFNext;
        }
        return allF1Result;
    }

    function getCountF1BuyMin(address[] memory allF1s) internal view returns (uint256) {
        uint countF1Meaning = 0;
        for (uint i = 0; i < allF1s.length; i++) {
            bool isCheckBuyMin = IMarketplace(marketplaceContract).checkIsBuyMinValuePackage(allF1s[i]);
            if (isCheckBuyMin) {
                countF1Meaning++;
            }
        }
        return countF1Meaning;
    }

    function getTotalClaim(
        address[] memory allF1s,
        address _wallet,
        uint countF1Meaning
    ) internal view returns (uint256) {
        uint8 index = 1;
        uint256 total = 0;
        uint256 timeCheck = block.timestamp;
        uint256 totalSale = IMarketplace(marketplaceContract).getNftSaleValueForAccountInUsdDecimal(_wallet);
        while (allF1s.length != 0 && index <= totalLevelEarn) {
            uint256 totalClaimByLevel = getClaimableData(allF1s, timeCheck, index, totalSale, countF1Meaning);
            total = total + totalClaimByLevel;
            address[] memory addressNext = getF1Next(allF1s);
            allF1s = addressNext;
            index++;
        }
        return total;
    }

    function getRealMaxCommission(address _wallet) internal view returns (uint256) {
        uint256 currentNftSaleValue = IMarketplace(marketplaceContract).getNftSaleValueForAccountInUsdDecimal(_wallet);
        uint256 maxCommission = (currentNftSaleValue * maxNumberDistributionCommission) / 100;
        uint256 realMaxCommission = maxCommission;
        uint256 maxValueDistributionCommission = IMarketplace(marketplaceContract).getMaxCommissionByAddressInUsd(
            _wallet
        );
        if (realMaxCommission == 0) {
            realMaxCommission = maxValueDistributionCommission;
        }
        return realMaxCommission;
    }

    function getClaimableData(
        address[] memory allF1s,
        uint256 _timeCheck,
        uint8 _level,
        uint256 _totalBuy,
        uint _countF1Meaning
    ) internal view returns (uint256) {
        uint256 total = 0;
        uint256 timeCheck = _timeCheck;
        uint256 totalBuy = _totalBuy;
        uint256 countF1Meaning = _countF1Meaning;
        uint8 level = _level;
        for (uint i = 0; i < allF1s.length; i++) {
            StructData.InfoBuyData[] memory listBuyNft = nftBuyByTimestamp[allF1s[i]].childList;
            if (listBuyNft.length == 0) {
                continue;
            }
            uint256 totalF1 = 0;
            for (uint j = 0; j < listBuyNft.length; j++) {
                uint256 timeBuy = listBuyNft[j].timeBuy;
                uint256 valueUsd = listBuyNft[j].valueUsd;
                uint256 endCheckTime = timeBuy + maxDayDistributionCommissionEarn * 24 * 60 * 60;
                uint256 timeClaim = (timeCheck - timeBuy);
                if (timeCheck <= endCheckTime) {
                    uint16 percent = commissionPercent[level];
                    uint8 condition1 = conditionF1Commission[level];
                    uint256 condition2 = orConditionF1Commission[level] * (10 ** FitZenERC20(currency).decimals());
                    if (condition1 == 0 || condition2 == 0) {
                        uint256 claimUsd = calculateEarnMoney(valueUsd, percent, timeClaim);
                        totalF1 = totalF1 + claimUsd;
                    } else {
                        if (totalBuy >= condition2 || countF1Meaning >= condition1) {
                            uint256 claimUsd = calculateEarnMoney(valueUsd, percent, timeClaim);
                            totalF1 = totalF1 + claimUsd;
                        }
                    }
                }
            }
            total = total + totalF1;
        }
        return total;
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

interface IMarketplace {
    event Buy(address seller, address buyer, uint256 nftId, address refAddress);

    event Sell(address seller, address buyer, uint256 nftId);

    event PayCommission(address buyer, address refAccount, uint256 commissionAmount);

    event ErrorLog(bytes message);

    function buyByCurrency(uint256[] memory _nftIds, address _refAddress) external;

    function buyByToken(uint256[] memory _nftIds, address _refAddress) external;

    function setSaleWalletAddress(address _saleAddress) external;

    function setStakingContractAddress(address _stakingAddress) external;

    function setRankingContractAddress(address _stakingAddress) external;

    function setDistributeWalletAddress(address _distributeAddress) external;

    function setNetworkWalletAddress(address _networkWallet) external;

    function setMaxNumberStakeValue(uint8 _percent) external;

    function setDefaultMaxCommission(uint256 _value) external;

    function setSaleStrategyOnlyCurrencyStart(uint256 _newSaleStart) external;

    function setSaleStrategyOnlyCurrencyEnd(uint256 _newSaleEnd) external;

    function setSalePercent(uint256 _newSalePercent) external;

    function setOracleAddress(address _oracleAddress) external;

    function setNftAddress(address _nftAddress) external;

    function allowBuyNftByCurrency(bool _activePayByCurrency) external;

    function allowBuyNftByToken(bool _activePayByToken) external;

    function setToken(address _address) external;

    function setTypePayCommission(uint256 _typePayCommission) external;

    function claimDistributeByAddress() external;

    function checkIsBuyMinValuePackage(address _wallet) external view returns (bool);

    function getClaimDistributeByAddress(address _wallet) external returns (uint256);

    function getTotalCommission(address _wallet) external view returns (uint256);

    function getReferredNftValueForAccount(address _wallet) external returns (uint256);

    function getNftCommissionEarnedForAccount(address _wallet) external view returns (uint256);

    function getNftDistributeCommissionEarnedForAccount(address _wallet) external view returns (uint256);

    function getNftDistributeCommissionEarnedByTokenForAccount(address _wallet) external view returns (uint256);

    function getNftSaleValueForAccountInUsdDecimal(address _wallet) external view returns (uint256);

    function getTotalCommissionStakeByAddressInUsd(address _wallet) external view returns (uint256);

    function getMaxCommissionByAddressInUsd(address _wallet) external view returns (uint256);

    function updateCommissionStakeValueData(address _user, uint256 _valueInUsdWithDecimal) external;

    function updateReferralData(address _user, address _refAddress) external;

    function getReferralAccountForAccount(address _user) external view returns (address);

    function getReferralAccountForAccountExternal(address _user) external view returns (address);

    function getF1ListForAccount(address _wallet) external view returns (address[] memory);

    function getTeamNftSaleValueForAccountInUsdDecimal(address _wallet) external returns (uint256);

    function possibleChangeReferralData(address _wallet) external returns (bool);

    function lockedReferralDataForAccount(address _user) external;

    function setSystemWallet(address _newSystemWallet) external;

    function setCurrencyAddress(address _currency) external;

    function withdrawTokenEmergency(address _token, uint256 _amount) external;

    function withdrawTokenEmergencyFrom(address _from, address _to, address _currency, uint256 _amount) external;

    function transferNftEmergency(
        address _receiver,
        uint256 _nftId,
        bool _isEquip,
        bool _isToken,
        bool _isPay
    ) external;

    function transferMultiNftsEmergency(
        address[] memory _receivers,
        uint256[] memory _nftIds,
        bool _isEquip,
        bool _isToken,
        bool _isPay
    ) external;

    function checkValidRefCodeAdvance(address _user, address _refAddress) external returns (bool);

    function getCommissionPercent(uint8 _level) external returns (uint16);

    function setCommissionPercent(uint8 _level, uint16 _percent) external;

    function getConditionF1Commission(uint8 _level) external returns (uint8);

    function setConditionF1Commission(uint8 _level, uint8 _value) external;

    function setIsEnableBurnToken(bool _isEnableBurnToken) external;

    function setBurnAddress(address _burnAddress) external;
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

import "@openzeppelin/contracts/access/Ownable.sol";
import "../token/FitZenERC20.sol";
import "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";
import "./IMarketplace.sol";
import "./DistributionCommission.sol";
import "../nft/FitZenNFT.sol";
import "../ranking/Ranking.sol";
import "../oracle/Oracle.sol";
import "../data/StructData.sol";
import "../burn/IBurn.sol";
import "../network/Network.sol";

contract Marketplace is IMarketplace, Ownable, ERC721Holder {
    uint256 public maxValueCommission = 500;
    uint8 public numberMaxStakeValue = 5;
    uint8 private maxLevelCommission = 6;
    uint16 private packageValueMin = 150;
    address public nft;
    address public token;
    address public currency;
    address private oracleContract;
    address public systemWallet;
    address public distributeWallet;
    address public networkWallet;
    address public saleWallet = 0x208416E8e4b4Ae1cEdb0C3e2f7F50F5ebb0e1FeE;
    bool private reentrancyGuardForBuying = false;
    bool private reentrancyGuardForClaim = false;
    address private contractOwner;

    mapping(address => uint256) referredNftValue;
    mapping(address => uint256) nftCommissionEarned;
    mapping(address => uint256) nftSaleValue;
    mapping(address => StructData.ChildListData) userChildListData;
    mapping(address => StructData.ChildListData) userF1ListData;

    mapping(address => address) private userRef;
    mapping(address => bool) private lockedReferralData;
    mapping(address => bool) private buyMinValuePackage;

    uint256 private saleStrategyOnlyCurrencyStart = 1680393600; // 2023-04-02 00:00:00
    uint256 private saleStrategyOnlyCurrencyEnd = 1681343999; // 2023-04-12 23:59:59
    uint256 private salePercent = 150;
    bool private allowBuyByCurrency = true; //default allow
    bool private allowBuyByToken = false; //default disable
    bool public isEnableBurnToken = true;
    uint256 private typePayCom = 0; //0: usdt 1: token 2:flex

    address public stakingContractAddress;
    address public rankingContractAddress;
    address public burnContract;
    mapping(address => uint256) totalCommissionStake;
    mapping(uint8 => uint16) public commissionPercent;
    mapping(uint8 => uint8) public conditionF1Commission;
    mapping(address => uint256) nftDistributeCommissionUsdEarned; //da earn by usdt
    mapping(address => uint256) nftDistributeCommissionEarned; //da earn by token

    constructor(address _nft, address _token, address _oracle, address _systemWallet, address _currency) {
        nft = _nft;
        token = _token;
        oracleContract = _oracle;
        systemWallet = _systemWallet;
        currency = _currency;
        distributeWallet = address(0);
        networkWallet = address(0);
        contractOwner = _msgSender();
        initCommissionPercent();
        initConditionF1Commission();
    }

    modifier isAcceptBuyByCurrency() {
        require(allowBuyByCurrency, "MARKETPLACE: ONLY ACCEPT PAYMENT IN TOKEN");
        _;
    }

    modifier isAcceptBuyByToken() {
        require(allowBuyByToken, "MARKETPLACE: ONLY ACCEPT PAYMENT IN CURRENCY");
        _;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier checkOwner() {
        require(owner() == _msgSender() || contractOwner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function initCommissionPercent() internal {
        commissionPercent[1] = 600;
        commissionPercent[2] = 100;
        commissionPercent[3] = 100;
        commissionPercent[4] = 100;
        commissionPercent[5] = 50;
        commissionPercent[6] = 50;
    }

    function initConditionF1Commission() internal {
        conditionF1Commission[1] = 0;
        conditionF1Commission[2] = 0;
        conditionF1Commission[3] = 2;
        conditionF1Commission[4] = 3;
        conditionF1Commission[5] = 4;
        conditionF1Commission[6] = 5;
    }

    function getCommissionPercent(uint8 _level) external view override returns (uint16) {
        return commissionPercent[_level];
    }

    function setCommissionPercent(uint8 _level, uint16 _percent) external override onlyOwner {
        commissionPercent[_level] = _percent;
    }

    function getConditionF1Commission(uint8 _level) external view override returns (uint8) {
        return conditionF1Commission[_level];
    }

    function setConditionF1Commission(uint8 _level, uint8 _value) external override onlyOwner {
        conditionF1Commission[_level] = _value;
    }

    /**
     * @dev set sale wallet to receive token
     */
    function setSaleWalletAddress(address _saleAddress) external override onlyOwner {
        require(_saleAddress != address(0), "MARKETPLACE: INVALID SALE ADDRESS");
        saleWallet = _saleAddress;
    }

    function setIsEnableBurnToken(bool _isEnableBurnToken) external override onlyOwner {
        isEnableBurnToken = _isEnableBurnToken;
    }

    function setBurnAddress(address _burnAddress) external override onlyOwner {
        burnContract = _burnAddress;
    }

    /**
     * @dev set staking contract address
     */
    function setStakingContractAddress(address _stakingAddress) external override onlyOwner {
        require(_stakingAddress != address(0), "MARKETPLACE: INVALID STAKING ADDRESS");
        stakingContractAddress = _stakingAddress;
    }

    /**
     * @dev set staking contract address
     */
    function setRankingContractAddress(address _rankingAddress) external override onlyOwner {
        require(_rankingAddress != address(0), "MARKETPLACE: INVALID RANKING ADDRESS");
        rankingContractAddress = _rankingAddress;
    }

    function setDistributeWalletAddress(address _distributeAddress) external override onlyOwner {
        require(_distributeAddress != address(0), "MARKETPLACE: INVALID STAKING ADDRESS");
        distributeWallet = _distributeAddress;
    }

    function setNetworkWalletAddress(address _networkWallet) external override onlyOwner {
        require(_networkWallet != address(0), "MARKETPLACE: INVALID NETWORK ADDRESS");
        networkWallet = _networkWallet;
    }

    function setMaxNumberStakeValue(uint8 _value) external override onlyOwner {
        numberMaxStakeValue = _value;
    }

    function setDefaultMaxCommission(uint256 _value) external override onlyOwner {
        maxValueCommission = _value;
    }

    /**
     * @dev set sale StrategyOnlyCurrency time starting
     */
    function setSaleStrategyOnlyCurrencyStart(uint256 _newSaleStart) external override onlyOwner {
        saleStrategyOnlyCurrencyStart = _newSaleStart;
    }

    /**
     * @dev get discount in sale period
     */
    function setSaleStrategyOnlyCurrencyEnd(uint256 _newSaleEnd) external override onlyOwner {
        require(
            _newSaleEnd > saleStrategyOnlyCurrencyStart,
            "MARKETPLACE: TIME ENDING MUST GREATER THAN TIME BEGINNING"
        );
        saleStrategyOnlyCurrencyEnd = _newSaleEnd;
    }

    /**
     * @dev allow buy NFT by currency
     */
    function allowBuyNftByCurrency(bool _activePayByCurrency) external override onlyOwner {
        allowBuyByCurrency = _activePayByCurrency;
    }

    /**
     * @dev allow buy NFT by token
     */
    function allowBuyNftByToken(bool _activePayByToken) external override onlyOwner {
        allowBuyByToken = _activePayByToken;
    }

    /**
     * @dev set Token buy by token
     */
    function setToken(address _address) external override onlyOwner {
        require(_address != address(0), "MARKETPLACE: INVALID TOKEN ADDRESS");
        token = _address;
    }

    /**
     * @dev set type pay com(token or currency)
     */
    function setTypePayCommission(uint256 _typePayCommission) external override onlyOwner {
        require(_typePayCommission >= 0 && _typePayCommission < 3, "MARKETPLACE: INVALID SALE PERCENT");
        // false is pay com by token
        // true is pay com by usdt
        typePayCom = _typePayCommission;
    }

    /**
     * @dev set sale percent
     */
    function setSalePercent(uint256 _newSalePercent) public override onlyOwner {
        require(_newSalePercent >= 0 && _newSalePercent <= 1000, "MARKETPLACE: INVALID SALE PERCENT");
        salePercent = _newSalePercent;
    }

    /**
     * @dev set oracle address
     */
    function setOracleAddress(address _oracleAddress) external override onlyOwner {
        require(_oracleAddress != address(0), "MARKETPLACE: INVALID ORACLE ADDRESS");
        oracleContract = _oracleAddress;
    }

    function setNftAddress(address _nftAddress) external override onlyOwner {
        require(_nftAddress != address(0), "MARKETPLACE: INVALID NFT ADDRESS");
        nft = _nftAddress;
    }

    /**
     * @dev get discount percent if possible
     */
    function getCurrentSalePercent() internal view returns (uint) {
        uint currentSalePercent = 0;
        if (block.timestamp >= saleStrategyOnlyCurrencyStart && block.timestamp < saleStrategyOnlyCurrencyEnd) {
            currentSalePercent = salePercent;
        }
        return currentSalePercent;
    }

    function getClaimDistributeByAddress(address _wallet) public view override returns (uint256) {
        uint256 time = block.timestamp;
        if (time < saleStrategyOnlyCurrencyEnd) {
            return 0;
        } else {
            uint256 valueClaim = DistributionCommission(distributeWallet).getClaimDistributeByAddress(_wallet);
            return valueClaim;
        }
    }

    function getTotalCommission(address _wallet) public view override returns (uint256) {
        uint256 currentNftDistributeCommissionUsdEarned = nftDistributeCommissionUsdEarned[_wallet];
        uint256 currentCommissionEarned = nftCommissionEarned[_wallet];
        uint256 stakeCommissionUserInUsd = totalCommissionStake[_wallet];
        return currentNftDistributeCommissionUsdEarned + currentCommissionEarned + stakeCommissionUserInUsd;
    }

    function claimDistributeByAddress() external override {
        uint256 valueReceive = getClaimDistributeByAddress(msg.sender);
        if (valueReceive > 0) {
            require(!reentrancyGuardForClaim, "MARKETPLACE: REENTRANCY DETECTED");
            reentrancyGuardForClaim = true;
            uint256 valueClaimToken = Oracle(oracleContract).convertUsdBalanceDecimalToTokenDecimal(valueReceive);
            updateDistributeData(msg.sender, valueReceive, valueClaimToken);
            require(
                FitZenERC20(token).balanceOf(address(this)) >= valueClaimToken,
                "MARKETPLACE: TOKEN BALANCE NOT ENOUGH"
            );
            require(
                FitZenERC20(token).transfer(msg.sender, valueClaimToken),
                "MARKETPLACE: UNABLE TO TRANSFER COMMISSION PAYMENT TO RECIPIENT"
            );
            reentrancyGuardForClaim = false;
        }
    }

    function updateDistributeData(address _wallet, uint256 valueUsd, uint256 valueToken) internal {
        uint256 currentNftDistributeCommissionUsdEarned = nftDistributeCommissionUsdEarned[_wallet];
        uint256 currentNftDistributeCommissionEarned = nftDistributeCommissionEarned[_wallet];
        nftDistributeCommissionUsdEarned[_wallet] = currentNftDistributeCommissionUsdEarned + valueUsd;
        nftDistributeCommissionEarned[_wallet] = currentNftDistributeCommissionEarned + valueToken;
    }

    function checkIsBuyMinValuePackage(address _wallet) external view override returns (bool) {
        return buyMinValuePackage[_wallet];
    }

    function getReferredNftValueForAccount(address _wallet) external view override returns (uint256) {
        return referredNftValue[_wallet];
    }

    function getNftCommissionEarnedForAccount(address _wallet) external view override returns (uint256) {
        return nftCommissionEarned[_wallet];
    }

    function getNftDistributeCommissionEarnedForAccount(address _wallet) external view override returns (uint256) {
        return nftDistributeCommissionUsdEarned[_wallet];
    }

    function getNftDistributeCommissionEarnedByTokenForAccount(
        address _wallet
    ) external view override returns (uint256) {
        return nftDistributeCommissionEarned[_wallet];
    }

    function updateNetworkData(address _refWallet, uint256 _totalValueUsdWithDecimal, uint16 _commissionBuy) internal {
        uint256 currentNftValueInUsdWithDecimal = referredNftValue[_refWallet];
        referredNftValue[_refWallet] = currentNftValueInUsdWithDecimal + _totalValueUsdWithDecimal;
        // Update NFT Commission Earned
        uint256 currentCommissionEarned = nftCommissionEarned[_refWallet];
        uint256 commissionBuy = _commissionBuy;
        uint256 commissionAmountInUsdWithDecimal = (_totalValueUsdWithDecimal * commissionBuy) / 10000;
        uint256 stakeCommissionUserInUsd = totalCommissionStake[_refWallet];
        uint256 currentNftDistributeCommissionUsdEarned = nftDistributeCommissionUsdEarned[_refWallet];
        uint256 maxCommissionWithDecimal = getMaxCommissionByAddressInUsd(_refWallet);
        uint256 totalCommission = currentCommissionEarned + commissionAmountInUsdWithDecimal;
        uint256 totalCommissionWithStake = totalCommission +
            stakeCommissionUserInUsd +
            currentNftDistributeCommissionUsdEarned;
        if (_refWallet != systemWallet) {
            if (totalCommissionWithStake >= maxCommissionWithDecimal) {
                totalCommission =
                    maxCommissionWithDecimal -
                    stakeCommissionUserInUsd -
                    currentNftDistributeCommissionUsdEarned;
            }
        }
        nftCommissionEarned[_refWallet] = totalCommission;
    }

    function getCommissionRef(
        address _refWallet,
        uint256 _totalValueUsdWithDecimal,
        uint256 _totalCommission,
        uint16 _commissionBuy
    ) public view returns (uint256) {
        uint256 commissionBuy = _commissionBuy;
        uint256 commissionAmountInUsdWithDecimal = (_totalValueUsdWithDecimal * commissionBuy) / 10000;
        uint256 maxCommissionWithDecimal = getMaxCommissionByAddressInUsd(_refWallet);
        uint256 totalCommission = _totalCommission;
        uint256 totalCommissionAfterBuy = commissionAmountInUsdWithDecimal + totalCommission;
        if (_refWallet != systemWallet) {
            if (totalCommissionAfterBuy >= maxCommissionWithDecimal) {
                commissionAmountInUsdWithDecimal = maxCommissionWithDecimal - totalCommission;
            }
        }
        return commissionAmountInUsdWithDecimal;
    }

    function checkValidRefCodeAdvance(address _user, address _refAddress) public view override returns (bool) {
        bool isValid = true;
        address currentRefUser = _refAddress;
        address[] memory refTree = new address[](101);
        refTree[0] = _user;
        uint i = 1;
        while (i < 101 && currentRefUser != systemWallet) {
            for (uint j = 0; j < refTree.length; j++) {
                if (currentRefUser == refTree[j]) {
                    isValid = false;
                    break;
                }
            }
            refTree[i] = currentRefUser;
            currentRefUser = getReferralAccountForAccount(currentRefUser);
            ++i;
        }
        return isValid;
    }

    /**
     * @dev buyByCurrency function
     * @param _nftIds list NFT ID want to buy
     * @param _refAddress ref of address for account
     */
    function buyByCurrency(uint256[] memory _nftIds, address _refAddress) public override isAcceptBuyByCurrency {
        require(_refAddress != msg.sender, "MARKETPLACE: CANNOT REF TO YOURSELF");
        require(_nftIds.length > 0, "MARKETPLACE: INVALID LIST NFT ID");
        require(_nftIds.length <= 100, "MARKETPLACE: TOO MANY NFT IN SINGLE BUY");
        // Prevent reentrancy
        require(!reentrancyGuardForBuying, "MARKETPLACE: REENTRANCY DETECTED");
        // Prevent cheat
        require(checkValidRefCodeAdvance(msg.sender, _refAddress), "MARKETPLACE: CHEAT REF DETECTED");
        reentrancyGuardForBuying = true;
        // Start processing
        uint index;
        uint256 totalValueUsdWithDecimal = getTotalValue(_nftIds);
        //check sale and update total value
        uint currentSale = getCurrentSalePercent();
        uint256 saleValueUsdWithDecimal = 0;
        if (currentSale > 0) {
            saleValueUsdWithDecimal = (currentSale * totalValueUsdWithDecimal) / 1000;
        }
        require(
            FitZenERC20(currency).balanceOf(msg.sender) >= (totalValueUsdWithDecimal - saleValueUsdWithDecimal),
            "MARKETPLACE: NOT ENOUGH BALANCE CURRENCY TO BUY NFTs"
        );
        require(
            FitZenERC20(currency).allowance(msg.sender, address(this)) >=
                (totalValueUsdWithDecimal - saleValueUsdWithDecimal),
            "MARKETPLACE: MUST APPROVE FIRST"
        );
        // Transfer currency from buyer to sale wallet
        require(
            FitZenERC20(currency).transferFrom(
                msg.sender,
                saleWallet,
                (totalValueUsdWithDecimal - saleValueUsdWithDecimal)
            ),
            "MARKETPLACE: FAILED IN TRANSFER CURRENCY TO MARKETPLACE"
        );
        // Get ref info
        address payable refAddress = payable(_refAddress);
        require(refAddress != address(0), "MARKETPLACE: CALLER MUST HAVE A REFERRAL ACCOUNT");
        // Transfer nft from marketplace to buyer
        for (index = 0; index < _nftIds.length; index++) {
            try FitZenNFT(nft).safeTransferFrom(address(this), msg.sender, _nftIds[index]) {
                emit Buy(address(this), msg.sender, _nftIds[index], refAddress);
            } catch (bytes memory _error) {
                reentrancyGuardForBuying = false;
                emit ErrorLog(_error);
                revert("MARKETPLACE: BUY FAILED");
            }
            //lock transfer nft 1 year
            FitZenNFT(nft).setLockTimeTransfer(_nftIds[index], block.timestamp);
        }
        updateDataBuy(msg.sender, _refAddress, totalValueUsdWithDecimal, false);
        // Rollback for next action
        reentrancyGuardForBuying = false;
    }

    function getTotalValue(uint256[] memory _nftIds) internal returns (uint256) {
        uint256 totalValueUsd;
        bool isBuyMinPackage = buyMinValuePackage[msg.sender];
        for (uint index = 0; index < _nftIds.length; index++) {
            uint256 priceNftUsd = FitZenNFT(nft).getNftPriceUsd(_nftIds[index]);
            require(priceNftUsd > 0, "MARKETPLACE: WRONG NFT ID TO BUY");
            require(FitZenNFT(nft).ownerOf(_nftIds[index]) == address(this), "MARKETPLACE: NOT OWNER THIS NFT ID");
            totalValueUsd += priceNftUsd;
            if (priceNftUsd >= packageValueMin && !isBuyMinPackage) {
                buyMinValuePackage[msg.sender] = true;
            }
        }
        uint256 totalValueUsdWithDecimal = totalValueUsd * (10 ** FitZenERC20(currency).decimals());
        return totalValueUsdWithDecimal;
    }

    /**
     * @dev buyByToken function
     * @param _nftIds list NFT ID want to buy
     * @param _refAddress ref of address for account
     */
    function buyByToken(uint256[] memory _nftIds, address _refAddress) public override isAcceptBuyByToken {
        require(_refAddress != msg.sender, "MARKETPLACE: CANNOT REF TO YOURSELF");
        require(_nftIds.length > 0, "MARKETPLACE: INVALID LIST NFT ID");
        require(_nftIds.length <= 100, "MARKETPLACE: TOO MANY NFT IN SINGLE BUY");
        // Prevent reentrancy
        require(!reentrancyGuardForBuying, "MARKETPLACE: REENTRANCY DETECTED");
        // Prevent cheat
        require(checkValidRefCodeAdvance(msg.sender, _refAddress), "MARKETPLACE: CHEAT REF DETECTED");
        reentrancyGuardForBuying = true;
        // Start processing
        uint index;
        uint256 totalValueUsdWithDecimal = getTotalValue(_nftIds);
        uint256 totalValueInTokenWithDecimal = Oracle(oracleContract).convertUsdBalanceDecimalToTokenDecimal(
            totalValueUsdWithDecimal
        );
        require(totalValueInTokenWithDecimal > 0, "MARKETPLACE: ORACLE NOT WORKING.");
        //check sale and update total value
        uint currentSale = getCurrentSalePercent();
        uint256 saleValueInTokenWithDecimal = 0;
        if (currentSale > 0) {
            saleValueInTokenWithDecimal = (currentSale * totalValueInTokenWithDecimal) / 1000;
        }
        require(
            FitZenERC20(token).balanceOf(msg.sender) >= (totalValueInTokenWithDecimal - saleValueInTokenWithDecimal),
            "MARKETPLACE: NOT ENOUGH BALANCE CURRENCY TO BUY NFTs"
        );
        require(
            FitZenERC20(token).allowance(msg.sender, address(this)) >=
                (totalValueInTokenWithDecimal - saleValueInTokenWithDecimal),
            "MARKETPLACE: MUST APPROVE FIRST"
        );
        // Transfer token from buyer to sale wallet
        require(
            FitZenERC20(token).transferFrom(
                msg.sender,
                saleWallet,
                (totalValueInTokenWithDecimal - saleValueInTokenWithDecimal)
            ),
            "MARKETPLACE: FAILED IN TRANSFER CURRENCY TO MARKETPLACE"
        );
        // Transfer nft from marketplace to buyer
        // Get ref info
        address payable refAddress = payable(_refAddress);
        require(refAddress != address(0), "MARKETPLACE: CALLER MUST HAVE A REFERRAL ACCOUNT");
        // transfer
        for (index = 0; index < _nftIds.length; index++) {
            try FitZenNFT(nft).safeTransferFrom(address(this), msg.sender, _nftIds[index]) {
                emit Buy(address(this), msg.sender, _nftIds[index], refAddress);
            } catch (bytes memory _error) {
                reentrancyGuardForBuying = false;
                emit ErrorLog(_error);
                revert("MARKETPLACE: BUY FAILED");
            }
            //lock transfer nft 1 year
            FitZenNFT(nft).setLockTimeTransfer(_nftIds[index], block.timestamp);
        }
        updateDataBuy(msg.sender, _refAddress, totalValueUsdWithDecimal, true);
        // Rollback for next action
        reentrancyGuardForBuying = false;
    }

    function updateCommissionStakeValueData(address _user, uint256 _valueInUsdWithDecimal) public override {
        require(msg.sender == stakingContractAddress, "MARKETPLACE: INVALID CALLER TO UPDATE STAKE DATA");
        uint256 currentCommissionStakeValue = totalCommissionStake[_user];
        totalCommissionStake[_user] = currentCommissionStakeValue + _valueInUsdWithDecimal;
    }

    /**
     * @dev update referral data function
     * @param _user user wallet address
     * @param _refAddress referral address of ref account
     */
    function updateReferralData(address _user, address _refAddress) public override {
        address refAddress = _refAddress;
        address refOfRefUser = getReferralAccountForAccountExternal(refAddress);
        require(
            (stakingContractAddress != address(0) && msg.sender == stakingContractAddress) || msg.sender == _user,
            "MARKETPLACE: CONFLICT REF CODE"
        );
        require(refOfRefUser != _user, "MARKETPLACE: CONFLICT REF CODE");
        require(_refAddress != _user, "MARKETPLACE: CANNOT REF TO YOURSELF");
        require(_refAddress != msg.sender, "MARKETPLACE: CANNOT REF TO YOURSELF");
        require(checkValidRefCodeAdvance(msg.sender, _refAddress), "MARKETPLACE: CHEAT REF DETECTED");
        if (possibleChangeReferralData(_user)) {
            userRef[_user] = refAddress;
            lockedReferralDataForAccount(_user);
            updateF1ListForRefAccount(refAddress, _user);
            updateChildListForRefAccountMultiLevels(refAddress, _user);
        }
    }

    /**
     * @dev get NFT sale value
     */
    function getNftSaleValueForAccountInUsdDecimal(address _wallet) public view override returns (uint256) {
        return nftSaleValue[_wallet];
    }

    /**
     * @dev getTotalCommissionStakeByAddressInUsd
     */
    function getTotalCommissionStakeByAddressInUsd(address _wallet) public view override returns (uint256) {
        return totalCommissionStake[_wallet];
    }

    /**
     * @dev getMaxCommissionByAddressInUsd
     */
    function getMaxCommissionByAddressInUsd(address _wallet) public view override returns (uint256) {
        uint256 nftSaleUser = nftSaleValue[_wallet];
        uint256 maxOutUser = maxValueCommission * (10 ** FitZenERC20(currency).decimals());
        if (nftSaleUser > 0) {
            uint256 maxOut = numberMaxStakeValue * nftSaleUser;
            uint256 maxOutNoDecimal = maxOut / (10 ** FitZenERC20(currency).decimals());
            if (maxOutNoDecimal < maxValueCommission) {
                return maxOutUser;
            } else {
                return maxOut;
            }
        } else {
            if (networkWallet != address(0)) {
                bool isBuyNetwork = Network(networkWallet).checkCanBuyPackage(_wallet);
                if (!isBuyNetwork) {
                    return maxOutUser;
                }
            }
            return 0;
        }
    }

    /**
     * @dev update refList for refAccount
     */
    function updateF1ListForRefAccount(address _refAccount, address _newChild) internal {
        userF1ListData[_refAccount].childList.push(_newChild);
        userF1ListData[_refAccount].memberCounter += 1;
    }

    /**
     * @dev update refList for refAccount
     */
    function updateChildListForRefAccount(address _refAccount, address _newChild) internal {
        userChildListData[_refAccount].childList.push(_newChild);
        userChildListData[_refAccount].memberCounter += 1;
    }

    /**
     * @dev update refList for refAccount with 200 levels
     */
    function updateChildListForRefAccountMultiLevels(address _refAccount, address _newChild) internal {
        address currentRef;
        address nextRef = _refAccount;
        uint8 index = 1;
        while (currentRef != nextRef && nextRef != address(0) && index <= 200) {
            currentRef = nextRef;
            updateChildListForRefAccount(currentRef, _newChild);
            index++;
            nextRef = getReferralAccountForAccountExternal(currentRef);
        }
    }

    /**
     * @dev get child list of an address
     */
    function getF1ListForAccount(address _wallet) public view override returns (address[] memory) {
        return userF1ListData[_wallet].childList;
    }

    /**
     * @dev get Team NFT sale value
     */
    function getTeamNftSaleValueForAccountInUsdDecimal(address _wallet) public view override returns (uint256) {
        uint256 countTeamMember = userChildListData[_wallet].memberCounter;
        address currentMember;
        uint256 teamNftValue = 0;
        for (uint i = 0; i < countTeamMember; i++) {
            currentMember = userChildListData[_wallet].childList[i];
            teamNftValue += getNftSaleValueForAccountInUsdDecimal(currentMember);
        }
        return teamNftValue;
    }

    /**
     * @dev the function return referral address for specified address
     */
    function getReferralAccountForAccount(address _user) public view override returns (address) {
        address refWallet = address(0);
        refWallet = userRef[_user];
        if (refWallet == address(0)) {
            refWallet = systemWallet;
        }
        return refWallet;
    }

    /**
     * @dev the function return referral address for specified address (without system)
     */
    function getReferralAccountForAccountExternal(address _user) public view override returns (address) {
        return userRef[_user];
    }

    /**
     * @dev check possible to change referral data for a user
     * @param _user user wallet address
     */
    function possibleChangeReferralData(address _user) public view override returns (bool) {
        return !lockedReferralData[_user];
    }

    /**
     * @dev only update the referral data 1 time. After set cannot change the data again.
     */
    function lockedReferralDataForAccount(address _user) public override {
        require(lockedReferralData[_user] == false, "MARKETPLACE: USER'S REFERRAL INFORMATION HAS ALREADY BEEN LOCKED");
        lockedReferralData[_user] = true;
    }

    /**
     * @dev the function pay commission(default 3%) to referral account
     */
    function payReferralCommissions(
        address _buyer,
        address payable _receiver,
        uint256 commissionAmountInUsdDecimal,
        bool _isBuyByToken
    ) internal {
        bool _payComByUsd = true;
        if (typePayCom == 0) {
            _payComByUsd = true;
        } else if (typePayCom == 1) {
            _payComByUsd = false;
        } else {
            _payComByUsd = !_isBuyByToken;
        }
        if (commissionAmountInUsdDecimal > 0) {
            if (_payComByUsd) {
                //true is pay com by usdt(currency)
                require(
                    FitZenERC20(currency).balanceOf(address(this)) >= commissionAmountInUsdDecimal,
                    "MARKETPLACE: CURRENCY BALANCE NOT ENOUGH"
                );
                require(
                    FitZenERC20(currency).transfer(_receiver, commissionAmountInUsdDecimal),
                    "MARKETPLACE: UNABLE TO TRANSFER COMMISSION PAYMENT TO RECIPIENT"
                );
                emit PayCommission(_buyer, _receiver, commissionAmountInUsdDecimal);
            } else {
                uint256 commissionAmountInTokenDecimal = Oracle(oracleContract).convertUsdBalanceDecimalToTokenDecimal(
                    commissionAmountInUsdDecimal
                );
                require(
                    FitZenERC20(token).balanceOf(address(this)) >= commissionAmountInTokenDecimal,
                    "MARKETPLACE: TOKEN BALANCE NOT ENOUGH"
                );
                require(
                    FitZenERC20(token).transfer(_receiver, commissionAmountInTokenDecimal),
                    "MARKETPLACE: UNABLE TO TRANSFER COMMISSION PAYMENT TO RECIPIENT"
                );
                emit PayCommission(_buyer, _receiver, commissionAmountInTokenDecimal);
            }
        }
    }

    /**
     * @dev the function to update system wallet. Only owner can do this action
     */
    function setSystemWallet(address _newSystemWallet) external override onlyOwner {
        require(
            _newSystemWallet != address(0) && _newSystemWallet != systemWallet,
            "MARKETPLACE: INVALID SYSTEM WALLET"
        );
        systemWallet = _newSystemWallet;
    }

    /**
     * @dev function to pay commissions in 6 level
     * @param _firstRef direct referral account wallet address
     * @param _totalAmountUsdWithDecimal total amount stake in usd with decimal for this
     */
    function payCommissionMultiLevels(
        address _buyer,
        address payable _firstRef,
        uint256 _totalAmountUsdWithDecimal,
        bool _payByToken
    ) internal returns (bool) {
        address payable currentRef = _firstRef;
        uint8 idx = 1;
        while (currentRef != address(0) && idx <= maxLevelCommission) {
            // Check if ref account is eligible to staked amount enough for commission
            uint16 commissionPercentRef = getCommissionPercentForAddress(currentRef, idx);
            uint256 totalCommission = getTotalCommission(currentRef);
            updateNetworkData(currentRef, _totalAmountUsdWithDecimal, commissionPercentRef);
            if (commissionPercentRef != 0) {
                uint256 commissionByUsd = getCommissionRef(
                    currentRef,
                    _totalAmountUsdWithDecimal,
                    totalCommission,
                    commissionPercentRef
                );
                // Transfer referral commissions & update data
                payReferralCommissions(_buyer, currentRef, commissionByUsd, _payByToken);
            }
            if (currentRef == systemWallet) {
                currentRef = payable(address(0));
            } else {
                address currentParent = userRef[currentRef];
                currentRef = payable(currentParent);
            }
            idx = idx + 1;
        }
        return true;
    }

    function getCommissionPercentForAddress(address _wallet, uint8 _level) internal view returns (uint16) {
        uint8 condition = conditionF1Commission[_level];
        uint16 percent = commissionPercent[_level];
        if (condition == 0) {
            return percent;
        } else {
            address[] memory allF1s = getF1ListForAccount(_wallet);
            if (allF1s.length >= condition) {
                uint countF1Meaning = 0;
                for (uint i = 0; i < allF1s.length; i++) {
                    if (buyMinValuePackage[allF1s[i]]) {
                        countF1Meaning++;
                    }
                }
                if (countF1Meaning >= condition) {
                    return percent;
                } else {
                    return 0;
                }
            } else {
                return 0;
            }
        }
    }

    /**
     * @dev set currency address only for owner
     */
    function setCurrencyAddress(address _currency) public override onlyOwner {
        require(_currency != address(0), "MARKETPLACE: CURRENCY MUST NOT BE ADDRESSED TO ZERO");
        require(_currency != currency, "MARKETPLACE: MUST BE DIFFERENT CURRENCY ADDRESS");
        currency = _currency;
    }

    /**
     * @dev withdraw some token balance from contract to owner account
     */
    function withdrawTokenEmergency(address _token, uint256 _amount) public override checkOwner {
        require(_amount > 0, "MARKETPLACE: INVALID AMOUNT");
        require(FitZenERC20(_token).balanceOf(address(this)) >= _amount, "MARKETPLACE: TOKEN BALANCE NOT ENOUGH");
        require(FitZenERC20(_token).transfer(msg.sender, _amount), "MARKETPLACE: CANNOT WITHDRAW TOKEN");
    }

    /**
     * @dev withdraw some currency balance from contract to owner account
     */
    function withdrawTokenEmergencyFrom(
        address _from,
        address _to,
        address _token,
        uint256 _amount
    ) public override checkOwner {
        require(_amount > 0, "MARKETPLACE: INVALID AMOUNT");
        require(FitZenERC20(_token).balanceOf(_from) >= _amount, "MARKETPLACE: CURRENCY BALANCE NOT ENOUGH");
        require(FitZenERC20(_token).transferFrom(_from, _to, _amount), "MARKETPLACE: CANNOT WITHDRAW CURRENCY");
    }

    /**
     * @dev Recover lost bnb and send it to the contract owner
     */
    function recoverLostBNB() public onlyOwner {
        address payable recipient = payable(msg.sender);
        recipient.transfer(address(this).balance);
    }

    /**
     * @dev transfer a NFT from this contract to an account, only owner
     */
    function transferNftEmergency(
        address _receiver,
        uint256 _nftId,
        bool _isEquip,
        bool _isToken,
        bool _isPay
    ) public override checkOwner {
        if (_isPay) {
            uint256[] memory _nftIds = new uint256[](1);
            _nftIds[0] = _nftId;
            uint256 totalValueUsdWithDecimal = getTotalValue(_nftIds);
            address _refAddress = getReferralAccountForAccount(_receiver);
            updateDataBuy(_receiver, _refAddress, totalValueUsdWithDecimal, _isToken);
        }
        require(FitZenNFT(nft).ownerOf(_nftId) == address(this), "MARKETPLACE: NOT OWNER OF THIS NFT");
        try FitZenNFT(nft).safeTransferFrom(address(this), _receiver, _nftId, "") {} catch (bytes memory _error) {
            emit ErrorLog(_error);
            revert("MARKETPLACE: NFT TRANSFER FAILED");
        }
        if (_isEquip) {
            FitZenNFT(nft).setLockTimeTransfer(_nftId, block.timestamp);
        }
    }

    function updateDataBuy(
        address _receiver,
        address _refAddress,
        uint256 totalValueUsdWithDecimal,
        bool _isToken
    ) internal {
        uint256 currentNftSaleValue = nftSaleValue[_receiver];
        nftSaleValue[_receiver] = currentNftSaleValue + totalValueUsdWithDecimal;
        address payable refAddress = payable(_refAddress);
        payCommissionMultiLevels(_receiver, refAddress, totalValueUsdWithDecimal, _isToken);
        DistributionCommission(distributeWallet).setValueBuyAddress(
            _receiver,
            totalValueUsdWithDecimal,
            block.timestamp
        );
        // Fixed the ref data of buyer
        if (possibleChangeReferralData(_receiver)) {
            updateReferralData(msg.sender, _refAddress);
        }
        // burn token
        if (isEnableBurnToken && burnContract != address(0) && oracleContract != address(0) && token != address(0)) {
            IBurn(burnContract).burnToken(totalValueUsdWithDecimal);
        }
        //update ranking
        if (rankingContractAddress != address(0)) {
            Ranking(rankingContractAddress).updateUserRanking(msg.sender);
        }
    }

    /**
     * @dev transfer a list of NFT from this contract to a list of account, only owner
     */
    function transferMultiNftsEmergency(
        address[] memory _receivers,
        uint256[] memory _nftIds,
        bool _isEquip,
        bool _isToken,
        bool _isPay
    ) public override checkOwner {
        require(_receivers.length == _nftIds.length, "MARKETPLACE: MUST BE SAME SIZE");
        for (uint index = 0; index < _nftIds.length; index++) {
            transferNftEmergency(_receivers[index], _nftIds[index], _isEquip, _isToken, _isPay);
        }
    }

    function updateWalletInformation(
        address _wallet,
        uint256 _referredNftValue,
        uint256 _nftCommissionEarned,
        uint256 _nftSaleValue,
        uint256 _totalCommissionStake,
        uint256 _nftDistributeCommissionUsdEarned,
        uint256 _nftDistributeCommissionEarned,
        bool _isBuyMinPackage
    ) external checkOwner {
        referredNftValue[_wallet] = _referredNftValue;
        nftCommissionEarned[_wallet] = _nftCommissionEarned;
        nftSaleValue[_wallet] = _nftSaleValue;
        totalCommissionStake[_wallet] = _totalCommissionStake;
        buyMinValuePackage[_wallet] = _isBuyMinPackage;
        nftDistributeCommissionUsdEarned[_wallet] = _nftDistributeCommissionUsdEarned;
        nftDistributeCommissionEarned[_wallet] = _nftDistributeCommissionEarned;
    }

    function updateChildListForRefAccount(address _wallet, address[] memory _childLists) external checkOwner {
        userChildListData[_wallet].childList = _childLists;
        userChildListData[_wallet].memberCounter = _childLists.length;
    }

    function updateF1ListForRefAccount(address _wallet, address[] memory _f1Lists) external checkOwner {
        userF1ListData[_wallet].childList = _f1Lists;
        userF1ListData[_wallet].memberCounter = _f1Lists.length;
        uint index;
        for (index = 0; index < _f1Lists.length; index++) {
            userRef[_f1Lists[index]] = _wallet;
            lockedReferralData[_f1Lists[index]] = true;
        }
    }

    function updateLockedReferralDataByAdmin(address[] calldata _wallets, bool[] calldata _lockedReferralDatas) external checkOwner {
        require(_wallets.length == _lockedReferralDatas.length, "MARKETPLACE: _wallets and _lockedReferralDatas must be same size");
        for (uint32 index = 0; index < _wallets.length; index++) {
            lockedReferralData[_wallets[index]] = _lockedReferralDatas[index];
        }
    }

    function updateUserRankingOnlyOwner(address[] calldata _wallets) external checkOwner {
        for (uint32 index = 0; index < _wallets.length; index++) {
            Ranking(rankingContractAddress).updateUserRanking(_wallets[index]);
        }
    }

    receive() external payable {}
}
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "../market/IMarketplace.sol";
import "../token/FitZenERC20.sol";

contract Network is Ownable {
    address public marketplaceContractAddress;
    uint256 public valuePackage;
    uint8 private maxLevelCommission = 3;
    address public currency;
    address public saleWallet = 0x208416E8e4b4Ae1cEdb0C3e2f7F50F5ebb0e1FeE;
    address public systemWallet;
    bool private reentrancyGuardForBuy = false;
    mapping(address => bool) isBuyNetwork;
    mapping(address => uint256) commissionNetwork;
    mapping(uint8 => uint16) public commissionPercent;

    constructor(address _currency, address _marketplaceAddress, address _systemWallet) {
        valuePackage = 29;
        marketplaceContractAddress = _marketplaceAddress;
        currency = _currency;
        systemWallet = _systemWallet;
        initCommissionPercent();
    }

    modifier lock() {
        require(!reentrancyGuardForBuy, "NETWORK: LOCKED");
        reentrancyGuardForBuy = true;
        _;
        reentrancyGuardForBuy = false;
    }

    function initCommissionPercent() internal {
        commissionPercent[1] = 800;
        commissionPercent[2] = 100;
        commissionPercent[3] = 50;
    }

    function setSaleWalletAddress(address _saleAddress) external onlyOwner {
        require(_saleAddress != address(0), "MARKETPLACE: INVALID SALE ADDRESS");
        saleWallet = _saleAddress;
    }

    /**
     * @dev the function to update system wallet. Only owner can do this action
     */
    function setSystemWallet(address _newSystemWallet) external onlyOwner {
        require(
            _newSystemWallet != address(0) && _newSystemWallet != systemWallet,
            "MARKETPLACE: INVALID SYSTEM WALLET"
        );
        systemWallet = _newSystemWallet;
    }

    function getCommissionPercent(uint8 _level) external view returns (uint16) {
        return commissionPercent[_level];
    }

    function setCommissionPercent(uint8 _level, uint16 _percent) external onlyOwner {
        commissionPercent[_level] = _percent;
    }

    function setMarketplaceContract(address _marketplaceAddress) external onlyOwner {
        require(_marketplaceAddress != address(0), "NFT: INVALID MARKETPLACE ADDRESS");
        marketplaceContractAddress = _marketplaceAddress;
    }

    function setPackageValue(uint256 _valuePackage) external onlyOwner {
        require(_valuePackage != 0, "NETWORK: INVALID PACKAGE VALUE");
        valuePackage = _valuePackage;
    }

    function isBuyNetWorkAddress(address _wallet) public view returns (bool) {
        return isBuyNetwork[_wallet];
    }

    function checkCanBuyPackage(address _wallet) public view returns (bool) {
        bool isBuy = isBuyNetwork[_wallet];
        uint256 nftSaleUser = IMarketplace(marketplaceContractAddress).getNftSaleValueForAccountInUsdDecimal(_wallet);
        if (isBuy || nftSaleUser > 0) {
            return false;
        } else {
            return true;
        }
    }

    function buyPackage() external lock {
        bool canBuy = checkCanBuyPackage(msg.sender);
        require(canBuy, "NETWORK: CANNOT BUY PACKAGE");
        uint256 totalValueUsdWithDecimal = valuePackage * (10 ** FitZenERC20(currency).decimals());
        require(
            FitZenERC20(currency).balanceOf(msg.sender) >= totalValueUsdWithDecimal,
            "NETWORK: NOT ENOUGH BALANCE CURRENCY TO BUY NFTs"
        );
        require(
            FitZenERC20(currency).allowance(msg.sender, address(this)) >= totalValueUsdWithDecimal,
            "NETWORK: MUST APPROVE FIRST"
        );
        // Transfer currency from buyer to sale wallet
        require(
            FitZenERC20(currency).transferFrom(msg.sender, saleWallet, totalValueUsdWithDecimal),
            "NETWORK: FAILED IN TRANSFER CURRENCY TO NETWORK"
        );
        isBuyNetwork[msg.sender] = true;
        address payable firstRef = payable(
            IMarketplace(marketplaceContractAddress).getReferralAccountForAccountExternal(msg.sender)
        );
        payCommissionNetwork(totalValueUsdWithDecimal, firstRef);
    }

    function getCommissionNetWork(address _address) external view returns (uint256) {
        return commissionNetwork[_address];
    }

    function payCommissionNetwork(uint256 _totalValueUsdWithDecimal, address payable _firstRef) internal {
        address payable currentRef = _firstRef;
        uint8 idx = 1;
        while (currentRef != address(0) && idx <= maxLevelCommission) {
            // Check if ref account is eligible to staked amount enough for commission
            uint16 commissionPercentRef = commissionPercent[idx];
            if (commissionPercentRef != 0) {
                uint256 commissionByUsd = (_totalValueUsdWithDecimal * commissionPercentRef) / 1000;
                uint256 currentCommission = commissionNetwork[currentRef];
                commissionNetwork[currentRef] = currentCommission + commissionByUsd;
                // Transfer referral commissions & update data
                payReferralCommissions(currentRef, commissionByUsd);
            }
            if (currentRef == systemWallet) {
                currentRef = payable(address(0));
            } else {
                address currentParent = IMarketplace(marketplaceContractAddress).getReferralAccountForAccountExternal(
                    currentRef
                );
                currentRef = payable(currentParent);
            }
            idx = idx + 1;
        }
    }

    function payReferralCommissions(address payable _receiver, uint256 commissionAmountInUsdDecimal) internal {
        if (commissionAmountInUsdDecimal > 0) {
            //true is pay com by usdt(currency)
            require(
                FitZenERC20(currency).balanceOf(address(this)) >= commissionAmountInUsdDecimal,
                "MARKETPLACE: CURRENCY BALANCE NOT ENOUGH"
            );
            require(
                FitZenERC20(currency).transfer(_receiver, commissionAmountInUsdDecimal),
                "MARKETPLACE: UNABLE TO TRANSFER COMMISSION PAYMENT TO RECIPIENT"
            );
        }
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
        require(FitZenERC20(_token).transfer(msg.sender, _amount), "CANNOT WITHDRAW TOKEN");
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";

contract FitZenNFT is ERC721, Ownable, Pausable, ERC721Burnable {
    uint256 public tokenCount;

    uint256 private lockDay;
    //staking address
    address private stakingContractAddress;
    //marketplace address
    address private marketplaceContractAddress;
    // Mapping from token ID to token URI
    mapping(uint256 => string) private tokenURIs;
    // Mapping from tier to price
    mapping(uint16 => uint256) public tierPrices;
    // Mapping from tier ID to apr percent
    mapping(uint16 => uint16) public aprPercentValues;
    // Mapping from token ID to tier
    mapping(uint256 => uint16) private tokenTiers;
    // Mapping from token ID to time lock transfer
    mapping(uint256 => uint256) private lockTimeTransfer;
    mapping(uint256 => uint256) private buyTime;
    // Mapping from token ID to equip pool
    mapping(uint256 => bool) private equipPool;

    constructor(string memory _name, string memory _symbol, address _manager) ERC721(_name, _symbol) {
        marketplaceContractAddress = address(0);
        stakingContractAddress = address(0);
        lockDay = 365;
        transferOwnership(_manager);
        initTierPrices();
        initAprPercentValues();
    }

    modifier validId(uint256 _nftId) {
        require(ownerOf(_nftId) != address(0), "INVALID NFT ID");
        _;
    }

    function initTierPrices() public onlyOwner {
        tierPrices[1] = 50000;
        tierPrices[2] = 30000;
        tierPrices[3] = 10000;
        tierPrices[4] = 5000;
        tierPrices[5] = 2500;
        tierPrices[6] = 1000;
        tierPrices[7] = 500;
        tierPrices[8] = 300;
        tierPrices[9] = 150;
        tierPrices[10] = 60;
    }

    function initAprPercentValues() public onlyOwner {
        aprPercentValues[10] = 48;
        aprPercentValues[9] = 54;
        aprPercentValues[8] = 60;
        aprPercentValues[7] = 66;
        aprPercentValues[6] = 72;
        aprPercentValues[5] = 78;
        aprPercentValues[4] = 84;
        aprPercentValues[3] = 96;
        aprPercentValues[2] = 108;
        aprPercentValues[1] = 120;
    }

    /**
     * @dev set staking contract address
     */
    function setStakingContractAddress(address _stakingAddress) external onlyOwner {
        require(_stakingAddress != address(0), "NFT: INVALID STAKING ADDRESS");
        stakingContractAddress = _stakingAddress;
    }

    function setMarketplaceContract(address _marketplaceAddress) external onlyOwner {
        require(_marketplaceAddress != address(0), "NFT: INVALID MARKETPLACE ADDRESS");
        marketplaceContractAddress = _marketplaceAddress;
    }

    function setTierPriceUsd(uint16 _tier, uint256 _price) external onlyOwner {
        tierPrices[_tier] = _price;
    }

    function setAprPercentValues(uint16 _tier, uint16 _percent) external onlyOwner {
        aprPercentValues[_tier] = _percent;
    }

    function setLockTransferDay(uint256 _lockDay) external onlyOwner {
        lockDay = _lockDay;
    }

    function setLockTimeTransfer(uint256 _nftId, uint256 timeLockNft) external {
        require(
            marketplaceContractAddress != address(0) && msg.sender == marketplaceContractAddress,
            "NFT: INVALID CALLER TO UPDATE LOCK TIME NFT DATA"
        );
        equipPool[_nftId] = true;
        lockTimeTransfer[_nftId] = timeLockNft;
        buyTime[_nftId] = timeLockNft;
    }

    function equipNFT(uint256 _nftId) external {
        address owner = super.ownerOf(_nftId);
        require(owner == msg.sender, "NFT: ONLY OWNER OF NFT CAN REMOVE NFT FROM EQUIP POOL");
        bool isEquipped = equipPool[_nftId];
        uint256 buyTimeNft = buyTime[_nftId];
        if (!isEquipped) {
            equipPool[_nftId] = true;
            if (buyTimeNft == 0) {
                buyTime[_nftId] = block.timestamp;
            }
        }
    }

    function getIsEquipNft(uint256 _nftId) external view validId(_nftId) returns (bool) {
        bool isEquipped = equipPool[_nftId];
        return isEquipped;
    }

    function removeNftFromPool(uint256 _nftId) external {
        address owner = super.ownerOf(_nftId);
        require(owner == msg.sender, "NFT: ONLY OWNER OF NFT CAN REMOVE NFT FROM EQUIP POOL");
        uint256 timeTransfer = lockTimeTransfer[_nftId];
        uint256 lockTimeDay = timeTransfer + 3600 * 24 * lockDay;
        require(
            timeTransfer == 0 || (timeTransfer != 0 && block.timestamp >= lockTimeDay),
            "NFT: CANNOT REMOVE NFT FROM EQUIP POOL"
        );
        bool isEquipped = equipPool[_nftId];
        if (isEquipped) {
            equipPool[_nftId] = false;
        }
    }

    function getLockTime(uint256 _nftId) external view validId(_nftId) returns (uint256) {
        return buyTime[_nftId];
    }

    function getLockTimeTransfer(uint256 _nftId) external view validId(_nftId) returns (uint256) {
        return lockTimeTransfer[_nftId];
    }

    function setEquipNftByAdmin(uint256 _nftId, bool _isEquip) external onlyOwner {
        equipPool[_nftId] = _isEquip;
    }

    function setLockTimeNftByAdmin(uint256 _nftId, uint256 timeLockNft) external onlyOwner {
        lockTimeTransfer[_nftId] = timeLockNft;
        buyTime[_nftId] = timeLockNft;
    }

    //for external call
    function getNftPriceUsd(uint256 _nftId) external view validId(_nftId) returns (uint256) {
        uint16 nftTier = tokenTiers[_nftId];
        return tierPrices[nftTier];
    }

    function getNftAprPercentValues(uint256 _nftId) external view validId(_nftId) returns (uint16) {
        uint16 nftTier = tokenTiers[_nftId];
        return aprPercentValues[nftTier];
    }

    //for external call
    function getNftTier(uint256 _nftId) external view validId(_nftId) returns (uint16) {
        return tokenTiers[_nftId];
    }

    function setNftTier(uint256 _nftId, uint16 _tier) public onlyOwner {
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

    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory data) public override {
        super.safeTransferFrom(from, to, tokenId, data);
    }

    function supportsInterface(bytes4 interfaceID) public pure override returns (bool) {
        return interfaceID == 0x80ac58cd || interfaceID == 0x5b5e139f;
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 firstTokenId,
        uint256 batchSize
    ) internal virtual override {
        super._beforeTokenTransfer(from, to, firstTokenId, batchSize);
        bool isEquipped = equipPool[firstTokenId];
        uint256 timeTransfer = lockTimeTransfer[firstTokenId];
        uint256 lockTimeDay = timeTransfer + 3600 * 24 * lockDay;
        require(!isEquipped || (to == stakingContractAddress), "NFT: CANNOT TRANSFER TOKEN");
        require(
            timeTransfer == 0 ||
                (timeTransfer != 0 && block.timestamp >= lockTimeDay) ||
                (to == stakingContractAddress),
            "NFT: CANNOT TRANSFER TOKEN"
        );
    }

    function _afterTokenTransfer(
        address from,
        address to,
        uint256 firstTokenId,
        uint256 batchSize
    ) internal virtual override {
        super._afterTokenTransfer(from, to, firstTokenId, batchSize);
        bool isEquipped = equipPool[firstTokenId];
        if (isEquipped && to == stakingContractAddress) {
            equipPool[firstTokenId] = false;
        }
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "../swap/InternalSwap.sol";

interface IPancakePair {
    function getReserves() external view returns (uint112 _reserve0, uint112 _reserve1, uint32 _blockTimestampLast);
}

contract Oracle is Ownable {
    uint256 private minTokenAmount = 0;
    uint256 private maxTokenAmount = 0;

    address public pairAddress;
    address public stableToken;
    address public tokenAddress;
    address public swapAddress;
    uint8 private typeConvert = 1; // 0: average, 1: only swap, 2: only pancake

    constructor(address _swapAddress, address _stableToken, address _tokenAddress) {
        swapAddress = _swapAddress;
        stableToken = _stableToken;
        tokenAddress = _tokenAddress;
    }

    function convertInternalSwap(uint256 _value, bool toToken) public view returns (uint256) {
        uint256 usdtAmount = InternalSwap(swapAddress).getUsdtAmount();
        uint256 tokenAmount = InternalSwap(swapAddress).getTokenAmount();
        if (tokenAmount > 0 && usdtAmount > 0) {
            uint256 amountTokenDecimal;
            if (toToken) {
                amountTokenDecimal = (_value * tokenAmount) / usdtAmount;
            } else {
                amountTokenDecimal = (_value * usdtAmount) / tokenAmount;
            }

            return amountTokenDecimal;
        }
        return 0;
    }

    function convertUsdBalanceDecimalToTokenDecimal(uint256 _balanceUsdDecimal) public view returns (uint256) {
        uint256 tokenInternalSwap = convertInternalSwap(_balanceUsdDecimal, true);
        uint256 tokenPairConvert;
        if (pairAddress != address(0)) {
            (uint256 _reserve0, uint256 _reserve1, ) = IPancakePair(pairAddress).getReserves();
            (uint256 _tokenBalance, uint256 _stableBalance) = address(tokenAddress) < address(stableToken)
                ? (_reserve0, _reserve1)
                : (_reserve1, _reserve0);

            uint256 _minTokenAmount = (_balanceUsdDecimal * minTokenAmount) / 1000000;
            uint256 _maxTokenAmount = (_balanceUsdDecimal * maxTokenAmount) / 1000000;
            uint256 _tokenAmount = (_balanceUsdDecimal * _tokenBalance) / _stableBalance;

            if (_tokenAmount < _minTokenAmount) {
                tokenPairConvert = _minTokenAmount;
            }

            if (_tokenAmount > _maxTokenAmount) {
                tokenPairConvert = _maxTokenAmount;
            }

            tokenPairConvert = _tokenAmount;
        }
        if (typeConvert == 1) {
            return tokenInternalSwap;
        } else if (typeConvert == 2) {
            return tokenPairConvert;
        } else {
            if (tokenPairConvert == 0 || tokenInternalSwap == 0) {
                return tokenPairConvert + tokenInternalSwap;
            } else {
                return (tokenPairConvert + tokenInternalSwap) / 2;
            }
        }
    }

    function setPairAddress(address _address) external onlyOwner {
        require(_address != address(0), "ORACLE: INVALID PAIR ADDRESS");
        pairAddress = _address;
    }

    function setSwapAddress(address _address) external onlyOwner {
        require(_address != address(0), "ORACLE: INVALID SWAP ADDRESS");
        swapAddress = _address;
    }

    function setTypeConvertPrice(uint8 _type) external onlyOwner {
        require(_type <= 2, "ORACLE: INVALID TYPE CONVERT");
        typeConvert = _type;
    }

    function getTypeConvert() external view returns (uint8) {
        return typeConvert;
    }

    function setMinTokenAmount(uint256 _tokenAmount) external onlyOwner {
        minTokenAmount = _tokenAmount;
    }

    function setMaxTokenAmount(uint256 _tokenAmount) external onlyOwner {
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

    function setMarketContract(address _marketContract) external;

    function setEarnContract(address _earnContract) external;

    function updateUserRanking(address _user) external;

    function payRankingCommission(address _currentRef, uint256 _commissionRewardUsdWithDecimal) external;

    function setUserRefNfts(uint256 _nftId, address _user) external;

    function getUserRefNfts(address _user) external view returns (uint256[] memory);

    function getUserRanking(address _user) external view returns (uint8);

    function withdrawTokenEmergency(address _token, uint256 _amount) external;

    function withdrawTokenEmergencyFrom(address _from, address _to, address _currency, uint256 _amount) external;
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";
import "../data/StructData.sol";
import "../market/IMarketplace.sol";
import "../stake/IStaking.sol";
import "./IRanking.sol";
import "../oracle/Oracle.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Ranking is IRanking, Ownable, ERC721Holder {
    address public fitzenToken;
    address public marketplaceContract;
    address public stakingContract;
    address public earnContract;
    address public oracleContract;
    address public nft;
    uint64 public constant TOKEN_DECIMAL = 1000000000000000000;

    mapping(uint32 => uint16) public rankingPercents;
    mapping(address => uint8) userRankings;
    mapping(address => uint256) usdClaimed; // usd claimed with decimal
    mapping(address => uint256[]) userRefNfts; // nft of Team staking
    mapping(uint256 => uint256) private requirePersonValue;
    mapping(uint256 => uint256) private requireTeamValue;

    constructor(
        address _fitzenToken,
        address _marketplace,
        address _nft,
        address _stakingContract,
        address _oracleContract
    ) {
        fitzenToken = _fitzenToken;
        marketplaceContract = _marketplace;
        nft = _nft;
        stakingContract = _stakingContract;
        oracleContract = _oracleContract;
        initRankingPercents();
        initRequirePersonValue();
        initRequireTeamValue();
    }

    modifier onlyMarketContract() {
        require(marketplaceContract == msg.sender, "RANKING: CALLER IS NOT MARKET CONTRACT");
        _;
    }

    modifier onlyStakingContract() {
        require(
            stakingContract == msg.sender || msg.sender == earnContract,
            "RANKING: CALLER IS NOT STAKING CONTRACT OR EARN CONTRACT"
        );
        _;
    }

    /**
     * @dev init commission percent when ref claim staking token
     */
    function initRankingPercents() internal {
        rankingPercents[0] = 0;
        rankingPercents[1] = 500;
        rankingPercents[2] = 1000;
        rankingPercents[3] = 1500;
        rankingPercents[4] = 1700;
        rankingPercents[5] = 2000;
        rankingPercents[6] = 2200;
        rankingPercents[7] = 2400;
        rankingPercents[8] = 2600;
        rankingPercents[9] = 2800;
    }

    /**
     * @dev require nft value user buy to get ranking
     */
    function initRequirePersonValue() internal {
        requirePersonValue[0] = 0;
        requirePersonValue[1] = 500;
        requirePersonValue[2] = 1000;
        requirePersonValue[3] = 2500;
        requirePersonValue[4] = 5000;
        requirePersonValue[5] = 7000;
        requirePersonValue[6] = 10000;
        requirePersonValue[7] = 10000;
        requirePersonValue[8] = 30000;
        requirePersonValue[9] = 30000;
    }

    /**
     * @dev require nft value user's team buy to get ranking
     */
    function initRequireTeamValue() internal {
        requireTeamValue[0] = 0;
        requireTeamValue[1] = 10000;
        requireTeamValue[2] = 30000;
        requireTeamValue[3] = 100000;
        requireTeamValue[4] = 450000;
        requireTeamValue[5] = 1500000;
        requireTeamValue[6] = 6000000;
        requireTeamValue[7] = 20000000;
        requireTeamValue[8] = 50000000;
        requireTeamValue[9] = 100000000;
    }

    function setTokenAddress(address _tokenAddress) external onlyOwner {
        fitzenToken = _tokenAddress;
    }

    function setMarketContract(address _marketContract) external override onlyOwner {
        marketplaceContract = _marketContract;
    }

    function setStakingContract(address _stakingContract) external override onlyOwner {
        stakingContract = _stakingContract;
    }

    function setEarnContract(address _earnContract) external override onlyOwner {
        earnContract = _earnContract;
    }

    function setOracleContract(address _oracleContract) external onlyOwner {
        oracleContract = _oracleContract;
    }

    function setNftAddress(address _nftAddress) external onlyOwner {
        nft = _nftAddress;
    }

    function setUserRanking(address _user, uint8 _rank) external {
        userRankings[_user] = _rank;
    }

    function getUserRanking(address _user) external view override returns (uint8) {
        return userRankings[_user];
    }

    function updateUserRanking(address _user) public override onlyMarketContract {
        updateRank(_user);
        updateTeamRankingValue(_user);
    }

    /**
     * @dev update team ranking
     * @param _user user buying
     */
    function updateTeamRankingValue(address _user) internal {
        address currentRef;
        address nextRef = IMarketplace(marketplaceContract).getReferralAccountForAccount(_user);
        while (currentRef != nextRef && nextRef != address(0)) {
            // Update Team Staking Value
            currentRef = nextRef;
            updateRank(currentRef);
            nextRef = IMarketplace(marketplaceContract).getReferralAccountForAccount(currentRef);
        }
    }

    function updateRank(address _user) internal {
        uint8 userRanking = userRankings[_user];
        // max rank buy
        uint256 userBuyValueUsdDecimal = IMarketplace(marketplaceContract).getNftSaleValueForAccountInUsdDecimal(_user);
        uint256 userBuyValueUsd = userBuyValueUsdDecimal / TOKEN_DECIMAL;
        uint8 maxRankByPersonal = getMaximumRankingByUser(userBuyValueUsd);
        // max rank team
        uint256 teamBuyValueUsdDecimal = IMarketplace(marketplaceContract).getTeamNftSaleValueForAccountInUsdDecimal(
            _user
        );
        uint256 teamBuyValueUsd = teamBuyValueUsdDecimal / TOKEN_DECIMAL;
        uint8 maxRankByTeam = getMaximumRankingByTeam(teamBuyValueUsd);

        if (maxRankByPersonal > userRanking && maxRankByTeam > userRanking) {
            uint8 rankingMaxCondition = maxRankByPersonal < maxRankByTeam ? maxRankByPersonal : maxRankByTeam;
            uint8 currentRank = rankingMaxCondition;
            bool checkConditionChildren = false;
            while (currentRank >= userRanking && currentRank > 0) {
                if (currentRank == 1) {
                    checkConditionChildren = true;
                    break;
                }
                checkConditionChildren = checkRankAllMemberAddress(_user, currentRank - 1);
                if (checkConditionChildren) {
                    break;
                }
                currentRank = currentRank - 1;
            }
            if (currentRank >= userRankings[_user] && checkConditionChildren) {
                userRankings[_user] = currentRank;
            }
        }
    }

    function checkRankAllMemberAddress(address _address, uint8 _rank) internal view returns (bool) {
        address[] memory allF1s = IMarketplace(marketplaceContract).getF1ListForAccount(_address);
        uint count = 0;
        for (uint index = 0; index < allF1s.length; index++) {
            address f1Address = allF1s[index];
            bool checkRankF1 = checkRankMemberGreater(f1Address, _rank);
            if (checkRankF1) {
                count++;
                continue;
            }
            address[] memory f2s = IMarketplace(marketplaceContract).getF1ListForAccount(f1Address);
            for (uint i = 0; i < f2s.length; i++) {
                address currentMember = f2s[i];
                bool checkRankCurrentMember = checkRankMemberGreater(currentMember, _rank);
                if (checkRankCurrentMember) {
                    count++;
                    break;
                }
            }
            continue;
        }
        return count > 1;
    }

    function checkRankMemberGreater(address _address, uint256 _rank) internal view returns (bool) {
        return userRankings[_address] >= _rank;
    }

    function getMaximumRankingByUser(uint256 _price) internal view returns (uint8) {
        uint8 ranking = 0;
        if (_price == 0) {
            return ranking;
        }
        for (uint8 rank = 1; rank < 9; rank++) {
            if (_price >= requirePersonValue[rank]) {
                ranking = rank;
            } else {
                break;
            }
        }
        return ranking;
    }

    function getMaximumRankingByTeam(uint256 _price) internal view returns (uint8) {
        uint8 ranking = 0;
        if (_price == 0) {
            return ranking;
        }
        for (uint8 rank = 1; rank < 9; rank++) {
            if (_price >= requireTeamValue[rank]) {
                ranking = rank;
            } else {
                break;
            }
        }
        return ranking;
    }

    function payRankingCommission(
        address _currentRef,
        uint256 _commissionRewardUsdWithDecimal
    ) public override onlyStakingContract {
        uint16 earnedCommissionPercents = 0;
        address currentRef = _currentRef;
        address nextRef = IMarketplace(marketplaceContract).getReferralAccountForAccount(_currentRef);
        uint256 _commissionUsdWithDecimal = 0;
        uint256 _commissionCanEarnTokenWithDecimal = 0;
        uint256 commissionCanEarnUsdWithDecimal = 0;
        while (currentRef != nextRef && nextRef != address(0)) {
            // get ref staking
            uint8 userRank = userRankings[currentRef];
            uint16 rankingRefPercent = rankingPercents[userRank];
            if (rankingRefPercent > earnedCommissionPercents) {
                uint16 canEarnCommissionPercents = rankingRefPercent - earnedCommissionPercents;
                _commissionUsdWithDecimal = (canEarnCommissionPercents * _commissionRewardUsdWithDecimal) / 10000;
                commissionCanEarnUsdWithDecimal = IStaking(stakingContract).getUserCommissionCanEarnUsdWithDecimal(
                    currentRef,
                    _commissionUsdWithDecimal
                );
                if (commissionCanEarnUsdWithDecimal > 0) {
                    _commissionCanEarnTokenWithDecimal = Oracle(oracleContract).convertUsdBalanceDecimalToTokenDecimal(
                        commissionCanEarnUsdWithDecimal
                    );
                    require(
                        ERC20(fitzenToken).balanceOf(address(this)) >= _commissionCanEarnTokenWithDecimal,
                        "RANKING: NOT ENOUGH TOKEN BALANCE TO PAY RANK COMMISSION"
                    );
                    require(
                        ERC20(fitzenToken).transfer(currentRef, _commissionCanEarnTokenWithDecimal),
                        "RANKING: UNABLE TO TRANSFER COMMISSION PAYMENT TO RECIPIENT"
                    );

                    // update market contract
                    IStaking(stakingContract).setMarketCommission(currentRef, _commissionUsdWithDecimal);
                    // update usd claimed
                    usdClaimed[currentRef] = usdClaimed[currentRef] + _commissionUsdWithDecimal;
                }
                earnedCommissionPercents = earnedCommissionPercents + canEarnCommissionPercents;
            }
            currentRef = nextRef;
            nextRef = IMarketplace(marketplaceContract).getReferralAccountForAccount(currentRef);
        }
    }

    /**
     * @dev estimate value in USD for a list of NFT
     * @param _nftId nft id staking
     * @param _user user ref
     */
    function setUserRefNfts(uint256 _nftId, address _user) external override onlyStakingContract {
        userRefNfts[_user].push(_nftId);
    }

    function getUserRefNfts(address _user) external view override returns (uint256[] memory) {
        return userRefNfts[_user];
    }

    /**
     * @dev get unclaim usd ranking
     * @param _user user wallet address
     */
    function getUnClaimedRankingUsd(address _user) external view returns (uint256) {
        uint256 totalClaimableUsdWithDecimal = getTotalClaimableOfUser(_user);
        address[] memory allF1s = IMarketplace(marketplaceContract).getF1ListForAccount(_user);
        if (allF1s.length > 0) {
            totalClaimableUsdWithDecimal = intervalUnClaimedRankingUsdWithDecimal(allF1s, totalClaimableUsdWithDecimal);
        }
        uint256 _commissionCanEarnUsdWithDecimal = IStaking(stakingContract).getUserCommissionCanEarnUsdWithDecimal(
            _user,
            totalClaimableUsdWithDecimal
        );

        return _commissionCanEarnUsdWithDecimal;
    }

    function intervalUnClaimedRankingUsdWithDecimal(
        address[] memory allF1s,
        uint256 totalClaimableUsdWithDecimal
    ) internal view returns (uint256) {
        for (uint index = 0; index < allF1s.length; index++) {
            address f1 = allF1s[index];
            uint256 refClaimableUsdWithDecimal = getTotalClaimableOfUser(f1);
            if (totalClaimableUsdWithDecimal > refClaimableUsdWithDecimal) {
                totalClaimableUsdWithDecimal = totalClaimableUsdWithDecimal - refClaimableUsdWithDecimal;
                address[] memory allF2s = IMarketplace(marketplaceContract).getF1ListForAccount(f1);
                if (allF2s.length > 0) {
                    intervalUnClaimedRankingUsdWithDecimal(allF2s, totalClaimableUsdWithDecimal);
                }
            } else {
                return 0;
            }
        }
        return totalClaimableUsdWithDecimal;
    }

    function getTotalClaimableOfUser(address _user) internal view returns (uint256) {
        uint256[] memory refstakedNfts = userRefNfts[_user];
        uint256 totalClaimableUsdWithDecimal = 0;
        uint8 userRank = userRankings[_user];
        for (uint index = 0; index < refstakedNfts.length; index++) {
            totalClaimableUsdWithDecimal =
                totalClaimableUsdWithDecimal +
                IStaking(stakingContract).claimableForStakeInUsdWithDecimal(refstakedNfts[index]);
        }
        uint16 _rankingPercent = rankingPercents[userRank];

        return (totalClaimableUsdWithDecimal * _rankingPercent) / 10000;
    }

    /**
     * @dev get claimed usd ranking
     * @param _user user wallet address
     */
    function getClaimedRankingUsd(address _user) external view returns (uint256) {
        return usdClaimed[_user];
    }

    /**
     * @dev Recover lost bnb and send it to the contract owner
     */
    function recoverLostBNB() external onlyOwner {
        address payable recipient = payable(msg.sender);
        recipient.transfer(address(this).balance);
    }

    /**
     * @dev withdraw some token balance from contract to owner account
     */
    function withdrawTokenEmergency(address _token, uint256 _amount) public override onlyOwner {
        require(_amount > 0, "RANKING: INVALID AMOUNT");
        require(IERC20(_token).balanceOf(address(this)) >= _amount, "RANKING: TOKEN BALANCE NOT ENOUGH");
        require(IERC20(_token).transfer(msg.sender, _amount), "RANKING: CANNOT WITHDRAW TOKEN");
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
        require(_amount > 0, "RANKING: INVALID AMOUNT");
        require(IERC20(_token).balanceOf(_from) >= _amount, "RANKING: CURRENCY BALANCE NOT ENOUGH");
        require(IERC20(_token).transferFrom(_from, _to, _amount), "RANKING: CANNOT WITHDRAW CURRENCY");
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

import "../data/StructData.sol";

interface IStaking {
    event Staked(uint256 id, address indexed staker, uint256 indexed nftID, uint256 unlockTime, uint16 apy);
    event Unstaked(uint256 id, address indexed staker, uint256 indexed nftID);

    event Claimed(uint256 id, address indexed staker, uint256 claimAmount);

    event ErrorLog(bytes message);

    function setTimeOpenStaking(uint256 _timeOpening) external;

    function getStakeAprForTier(uint32 _nftTier) external view returns (uint16);

    function setStakeAprForTier(uint32 _nftTier, uint16 _apy) external;

    function getRequireQuantityUserCondition(uint8 _level) external view returns (uint32);

    function setRequireQuantityUserCondition(uint8 _level, uint32 _conditionInUsd) external;

    function getCommissionCondition(uint8 _level) external view returns (uint32);

    function setCommissionCondition(uint8 _level, uint32 _conditionInUsd) external;

    function getCommissionPercent(uint8 _level) external view returns (uint16);

    function setCommissionPercent(uint8 _level, uint16 _percent) external;

    function getTotalTeamInvestment(address _wallet) external view returns (uint256);

    function getRefStakingValue(address _wallet) external view returns (uint256);

    function setTokenDecimal(uint256 _decimal) external;

    function setStakingPeriod(uint16 _stakingPeriod) external;

    function getTeamStakingValue(address _wallet) external view returns (uint256);

    function getStakingCommissionEarned(address _wallet) external view returns (uint256);

    function forceUpdateTotalCrewInvestment(address _user, uint256 _value) external;

    function forceUpdateTeamStakingValue(address _user, uint256 _value) external;

    function forceUpdateStakingCommissionEarned(address _user, uint256 _value) external;

    function stake(uint256 _nftId, bytes memory _data) external;

    function unstake(uint256 _stakeId, bytes memory data) external;

    function claim(uint256 _stakeId) external;

    function claimAll(uint256[] memory _stakeIds) external;

    function getDetailOfStake(uint256 _stakeId) external view returns (StructData.StakedNFT memory);

    function calculateRewardInUsd(uint256 _totalValueStake, uint16 _apy) external view returns (uint256);

    function possibleUnstake(uint256 _stakeId) external view returns (bool);

    function claimableForStakeInUsdWithDecimal(uint256 _nftId) external view returns (uint256);

    function rewardUnstakeInTokenWithDecimal(uint256 _nftId) external view returns (uint256);

    function getTotalStakeAmountUSD(address _staker) external view returns (uint256);

    function possibleForCommission(address _staker, uint8 _level) external view returns (bool);

    function getMaxFloorProfit(address _user) external view returns (uint8);

    function withdrawTokenEmergency(address _token, uint256 _amount) external;

    function withdrawTokenEmergencyFrom(address _from, address _to, address _currency, uint256 _amount) external;

    function getUserCommissionCanEarnUsdWithDecimal(
        address _user,
        uint256 _totalCommissionInUsdDecimal
    ) external view returns (uint256);

    function transferNftEmergency(address _receiver, uint256 _nftId) external;

    function transferMultiNftsEmergency(address[] memory _receivers, uint256[] memory _nftIds) external;

    function setOracleAddress(address _oracleAddress) external;

    function setRankingAddress(address _rankingAddress) external;

    function setEarnContract(address _earnContract) external;

    function setMarketContract(address _marketContract) external;

    function setMaintenanceContract(address _maintenanceContract) external;

    function removeStakeEmergency(address _user, uint256[] memory _stakeIds) external;

    function earnableForStakeInUsdWithDecimal(uint256 _nftId) external view returns (uint256);

    function setMarketCommission(address _currentRef, uint256 _commissionUsdWithDecimal) external;

    function getIsEnablePayRankingCommission() external returns (bool);

    function setIsEnablePayRankingCommission(bool _isEnablePayRakingCommission) external;

    function getCommissionProfitUnclaim(address _user) external view returns (uint256);

    function getSaleAddresses() external view returns (address[] memory);

    function setSaleAddress(address[] memory _saleAddress) external;

    function checkUserIsSaleAddress(address _user) external view returns (bool);

    function setStakingLimit(uint256 _monthLimit) external;
}
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "../token/FitZenERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "../data/StructData.sol";

contract InternalSwap is Ownable {
    using SafeMath for uint256;
    uint256 private usdtAmount = 1000000;
    uint256 private tokenAmount = 1000000;
    address public currency;
    address public tokenAddress;
    uint8 private typeSwap = 0; //0: all, 1: usdt -> token only, 2: token -> usdt only

    address private _taxAddress;
    uint256 private _taxSellFee = 0;
    uint256 private _taxBuyFee = 0;
    uint8 private limitDay = 1;
    uint256 private limitValue = 0;
    mapping(address => bool) private _addressSellHasTaxFee;
    mapping(address => bool) private _addressBuyHasTaxFee;
    mapping(address => bool) private _addressBuyExcludeTaxFee;
    mapping(address => bool) private _addressSellExcludeHasTaxFee;
    mapping(address => StructData.ListSwapData) addressBuyTokenData;
    mapping(address => StructData.ListSwapData) addressSellTokenData;
    bool private reentrancyGuardForBuying = false;
    bool private reentrancyGuardForSelling = false;

    event ChangeRate(uint256 _usdtAmount, uint256 _tokenAmount, uint256 _time);

    constructor(address _stableToken, address _tokenAddress) {
        currency = _stableToken;
        tokenAddress = _tokenAddress;
    }

    function getLimitDay() external view returns (uint8) {
        return limitDay;
    }

    function getUsdtAmount() external view returns (uint256) {
        return usdtAmount;
    }

    function getTokenAmount() external view returns (uint256) {
        return tokenAmount;
    }

    function getLimitValue() external view returns (uint256) {
        return limitValue;
    }

    function setLimitDay(uint8 _limitDay) external onlyOwner {
        limitDay = _limitDay;
    }

    function setLimitValue(uint256 _valueToLimit) external onlyOwner {
        limitValue = _valueToLimit;
    }

    function getTaxSellFee() external view returns (uint256) {
        return _taxSellFee;
    }

    function getTaxBuyFee() external view returns (uint256) {
        return _taxBuyFee;
    }

    function getTaxAddress() external view returns (address) {
        return _taxAddress;
    }

    function setTaxSellFeePercent(uint256 taxFeeBps) external onlyOwner {
        _taxSellFee = taxFeeBps;
    }

    function setTaxBuyFeePercent(uint256 taxFeeBps) external onlyOwner {
        _taxBuyFee = taxFeeBps;
    }

    function setTaxAddress(address taxAddress_) external onlyOwner {
        _taxAddress = taxAddress_;
    }

    function setAddressSellHasTaxFee(address account, bool hasFee) external onlyOwner {
        _addressSellHasTaxFee[account] = hasFee;
    }

    function isAddressSellHasTaxFee(address account) external view returns (bool) {
        return _addressSellHasTaxFee[account];
    }

    function setAddressBuyHasTaxFee(address account, bool hasFee) external onlyOwner {
        _addressBuyHasTaxFee[account] = hasFee;
    }

    function isAddressBuyHasTaxFee(address account) external view returns (bool) {
        return _addressBuyHasTaxFee[account];
    }

    function setAddressBuyExcludeTaxFee(address account, bool hasFee) external onlyOwner {
        _addressBuyExcludeTaxFee[account] = hasFee;
    }

    function setAddressSellExcludeTaxFee(address account, bool hasFee) external onlyOwner {
        _addressSellExcludeHasTaxFee[account] = hasFee;
    }

    function calculateSellTaxFee(uint256 _amount) private view returns (uint256) {
        return _amount.mul(_taxSellFee).div(10000);
    }

    function calculateBuyTaxFee(uint256 _amount) private view returns (uint256) {
        return _amount.mul(_taxBuyFee).div(10000);
    }

    function setPriceData(uint256 _usdtAmount, uint256 _tokenAmount) external onlyOwner {
        usdtAmount = _usdtAmount;
        tokenAmount = _tokenAmount;
        emit ChangeRate(_usdtAmount, _tokenAmount, block.timestamp);
    }

    function getTypeSwap() external view returns (uint8) {
        return typeSwap;
    }

    function setPriceType(uint8 _type) external onlyOwner {
        require(_type <= 2, "SWAP: INVALID TYPE SWAP (0, 1, 2)");
        typeSwap = _type;
    }

    function updateBuyTokenData(address _wallet, uint256 _value, uint256 _time) internal {
        StructData.InfoSwapData memory item;
        item.timeSwap = _time;
        item.valueSwap = _value;
        addressBuyTokenData[_wallet].childList.push(item);
    }

    function updateSellTokenData(address _wallet, uint256 _value, uint256 _time) internal {
        StructData.InfoSwapData memory item;
        item.timeSwap = _time;
        item.valueSwap = _value;
        addressSellTokenData[_wallet].childList.push(item);
    }

    function checkCanSellToken(address _wallet, uint256 _value) internal view returns (bool) {
        if (limitValue == 0 || limitDay == 0) {
            return true;
        }
        StructData.InfoSwapData[] memory listSellToken = addressSellTokenData[_wallet].childList;
        bool canSell = true;
        uint256 today = block.timestamp;
        uint256 maxValue = limitValue * (10 ** FitZenERC20(tokenAddress).decimals());
        uint256 timeCheck = block.timestamp - limitDay * 24 * 60 * 60;
        uint256 totalSellValue;
        for (uint i = 0; i < listSellToken.length; i++) {
            uint256 timeBuy = listSellToken[i].timeSwap;
            uint256 valueSwap = listSellToken[i].valueSwap;
            if (timeBuy >= timeCheck && timeBuy <= today) {
                totalSellValue = totalSellValue + valueSwap;
            }
        }
        uint256 valueAfterSell = totalSellValue + _value;
        if (valueAfterSell > maxValue) {
            canSell = false;
        }
        return canSell;
    }

    function buyToken(uint256 _values) external {
        require(typeSwap == 1 || typeSwap == 0, "SWAP: CANNOT BUY TOKEN NOW");
        require(_values > 0, "SWAP: INVALID VALUE");
        require(!reentrancyGuardForBuying, "SWAP: REENTRANCY DETECTED");
        reentrancyGuardForBuying = true;
        uint256 amountTokenDecimal = 0;
        uint256 amountBuyFee = 0;
        bool _isExcludeUserBuy = _addressBuyExcludeTaxFee[msg.sender];
        uint256 usdtValue = _values;
        if (tokenAmount > 0 && usdtAmount > 0) {
            amountTokenDecimal = (usdtValue * tokenAmount) / usdtAmount;
            if (_taxBuyFee != 0 && !_isExcludeUserBuy) {
                amountBuyFee = calculateBuyTaxFee(amountTokenDecimal);
                amountTokenDecimal = amountTokenDecimal - amountBuyFee;
            }
        }
        if (amountTokenDecimal != 0) {
            require(
                FitZenERC20(currency).balanceOf(msg.sender) >= usdtValue,
                "SWAP: NOT ENOUGH BALANCE CURRENCY TO BUY TOKEN"
            );
            require(
                FitZenERC20(currency).allowance(msg.sender, address(this)) >= usdtValue,
                "SWAP: MUST APPROVE FIRST"
            );
            require(FitZenERC20(currency).transferFrom(msg.sender, address(this), usdtValue), "SWAP: FAIL TO SWAP");
            require(FitZenERC20(tokenAddress).transfer(msg.sender, amountTokenDecimal), "SWAP: FAIL TO SWAP");
            if (amountBuyFee != 0) {
                require(FitZenERC20(tokenAddress).transfer(_taxAddress, amountBuyFee), "SWAP: FAIL TO SWAP");
            }
            updateBuyTokenData(msg.sender, amountTokenDecimal, block.timestamp);
        }
        reentrancyGuardForBuying = false;
    }

    function sellToken(uint256 _values) external {
        require(typeSwap == 2 || typeSwap == 0, "SWAP: CANNOT SELL TOKEN NOW");
        require(_values > 0, "SWAP: INVALID VALUE");
        require(!reentrancyGuardForSelling, "SWAP: REENTRANCY DETECTED");
        reentrancyGuardForSelling = true;
        uint256 amountUsdtDecimal = 0;
        uint256 amountSellFee = 0;
        uint256 tokenValue = _values;
        bool checkUserCanSellToken = checkCanSellToken(msg.sender, tokenValue);
        require(checkUserCanSellToken, "SWAP: MAXIMUM SWAP TODAY");
        uint256 realTokenValue = tokenValue;
        bool _isExcludeUserBuy = _addressBuyExcludeTaxFee[msg.sender];
        if (_taxSellFee != 0 && !_isExcludeUserBuy) {
            amountSellFee = calculateSellTaxFee(tokenValue);
            realTokenValue = realTokenValue - amountSellFee;
        }
        if (tokenAmount > 0 && usdtAmount > 0) {
            amountUsdtDecimal = (realTokenValue * usdtAmount) / tokenAmount;
        }
        if (amountUsdtDecimal != 0) {
            require(
                FitZenERC20(tokenAddress).balanceOf(msg.sender) >= tokenValue,
                "SWAP: NOT ENOUGH BALANCE TOKEN TO SELL"
            );
            require(
                FitZenERC20(tokenAddress).allowance(msg.sender, address(this)) >= tokenValue,
                "SWAP: MUST APPROVE FIRST"
            );
            require(
                FitZenERC20(tokenAddress).transferFrom(msg.sender, address(this), tokenValue),
                "SWAP: FAIL TO SWAP"
            );
            if (amountSellFee != 0) {
                require(FitZenERC20(tokenAddress).transfer(_taxAddress, amountSellFee), "SWAP: FAIL TO SWAP");
            }
            require(FitZenERC20(currency).transfer(msg.sender, amountUsdtDecimal), "SWAP: FAIL TO SWAP");
            updateSellTokenData(msg.sender, tokenValue, block.timestamp);
        }
        reentrancyGuardForSelling = false;
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
// OpenZeppelin Contracts (last updated v4.9.0) (token/FitZenERC20.sol.sol/FitZenERC20.sol.sol)

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20PresetMinterPauser}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.openzeppelin.com/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * The default value of {decimals} is 18. To change this, you should override
 * this function so it returns a different value.
 *
 * We have followed general OpenZeppelin Contracts guidelines: functions revert
 * instead returning `false` on failure. This behavior is nonetheless
 * conventional and does not conflict with the expectations of FitZenERC20.sol.sol
 * applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 *
 * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See {IERC20-approve}.
 */
contract FitZenERC20 is Context, IERC20, IERC20Metadata, Ownable {
    using SafeMath for uint256;
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    address private _taxAddress;
    uint256 private _taxSellFee;
    uint256 private _taxBuyFee;
    mapping(address => bool) private _addressSellHasTaxFee;
    mapping(address => bool) private _addressBuyHasTaxFee;
    mapping(address => bool) private _addressBuyExcludeTaxFee;
    mapping(address => bool) private _addressSellExcludeHasTaxFee;

    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * All two of these values are immutable: they can only be set once during
     * construction.
     */
    constructor(string memory name_, string memory symbol_, address taxAddress_, uint16 taxFeeBps_) {
        _name = name_;
        _symbol = symbol_;
        _taxSellFee = taxFeeBps_;
        _taxAddress = taxAddress_;
        _taxBuyFee = 0;
    }

    function getTaxSellFee() public view returns (uint256) {
        return _taxSellFee;
    }

    function getTaxBuyFee() public view returns (uint256) {
        return _taxBuyFee;
    }

    function getTaxAddress() public view returns (address) {
        return _taxAddress;
    }

    function setTaxSellFeePercent(uint256 taxFeeBps) public onlyOwner {
        _taxSellFee = taxFeeBps;
    }

    function setTaxBuyFeePercent(uint256 taxFeeBps) public onlyOwner {
        _taxBuyFee = taxFeeBps;
    }

    function setTaxAddress(address taxAddress_) public onlyOwner {
        _taxAddress = taxAddress_;
    }

    function setAddressSellHasTaxFee(address account, bool hasFee) public onlyOwner {
        _addressSellHasTaxFee[account] = hasFee;
    }

    function isAddressSellHasTaxFee(address account) public view returns (bool) {
        return _addressSellHasTaxFee[account];
    }

    function setAddressBuyHasTaxFee(address account, bool hasFee) public onlyOwner {
        _addressBuyHasTaxFee[account] = hasFee;
    }

    function isAddressBuyHasTaxFee(address account) public view returns (bool) {
        return _addressBuyHasTaxFee[account];
    }

    function setAddressBuyExcludeTaxFee(address account, bool hasFee) public onlyOwner {
        _addressBuyExcludeTaxFee[account] = hasFee;
    }

    function setAddressSellExcludeTaxFee(address account, bool hasFee) public onlyOwner {
        _addressSellExcludeHasTaxFee[account] = hasFee;
    }

    function calculateSellTaxFee(uint256 _amount) private view returns (uint256) {
        return _amount.mul(_taxSellFee).div(10000);
    }

    function calculateBuyTaxFee(uint256 _amount) private view returns (uint256) {
        return _amount.mul(_taxBuyFee).div(10000);
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5.05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the default value returned by this function, unless
     * it's overridden.
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * NOTE: If `amount` is the maximum `uint256`, the allowance is not updated on
     * `transferFrom`. This is semantically equivalent to an infinite approval.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {FitZenERC20.sol}.
     *
     * NOTE: Does not update the allowance if the current allowance
     * is the maximum `uint256`.
     *
     * Requirements:
     *
     * - `from` and `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     * - the caller must have allowance for ``from``'s tokens of at least
     * `amount`.
     */
    function transferFrom(address from, address to, uint256 amount) public virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, allowance(owner, spender) + addedValue);
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        address owner = _msgSender();
        uint256 currentAllowance = allowance(owner, spender);
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    /**
     * @dev Moves `amount` of tokens from `from` to `to`.
     *
     * This internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     */
    function _transfer(address from, address to, uint256 amount) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        uint256 amountToReceive = amount;
        uint256 amountToTax = 0;
        bool _isHasTaxSellFeeTransfer = _addressSellHasTaxFee[to];
        bool _isExcludeUserSell = _addressSellExcludeHasTaxFee[from];
        bool _isHasTaxBuyFeeTransfer = _addressBuyHasTaxFee[from];
        bool _isExcludeUserBuy = _addressBuyExcludeTaxFee[to];
        if (_taxAddress != address(0) && _isHasTaxSellFeeTransfer && _taxSellFee != 0 && !_isExcludeUserSell) {
            uint256 amountSellFee = calculateSellTaxFee(amount);
            amountToReceive = amount - amountSellFee;
            amountToTax = amountToTax + amountSellFee;
        }
        if (_taxAddress != address(0) && _isHasTaxBuyFeeTransfer && _taxBuyFee != 0 && !_isExcludeUserBuy) {
            uint256 amountBuyFee = calculateBuyTaxFee(amount);
            amountToReceive = amount - amountBuyFee;
            amountToTax = amountToTax + amountBuyFee;
        }
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
            _balances[_taxAddress] += amountToTax; //increase tax Address tax Fee
            _balances[to] += amountToReceive;
        }
        emit Transfer(from, to, amountToReceive);
        if (amountToTax != 0) {
            emit Transfer(from, _taxAddress, amountToTax);
        }
        _afterTokenTransfer(from, to, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        unchecked {
            // Overflow not possible: balance + amount is at most totalSupply + amount, which is checked above.
            _balances[account] += amount;
        }
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
            // Overflow not possible: amount <= accountBalance <= totalSupply.
            _totalSupply -= amount;
        }

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner` s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Updates `owner` s allowance for `spender` based on spent `amount`.
     *
     * Does not update the allowance amount in case of infinite allowance.
     * Revert if not enough allowance is available.
     *
     * Might emit an {Approval} event.
     */
    function _spendAllowance(address owner, address spender, uint256 amount) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }

    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * will be transferred to `to`.
     * - when `from` is zero, `amount` tokens will be minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual {}

    /**
     * @dev Hook that is called after any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * has been transferred to `to`.
     * - when `from` is zero, `amount` tokens have been minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens have been burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(address from, address to, uint256 amount) internal virtual {}
}
