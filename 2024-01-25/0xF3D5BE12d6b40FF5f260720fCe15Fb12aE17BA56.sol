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

library StructData {
    // struct to store staked NFT information
    struct StakedNFT {
        address stakerAddress;
        uint256 lastClaimedTime;
        uint256 unlockTime;
        uint256 totalValueStakeUsdWithDecimal;
        uint256 totalClaimedAmountTokenWithDecimal;
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

    struct InfoCommissionNetwork {
        address user;
        uint256 time;
        uint256 value;
    }

    struct ListCommissionData {
        StructData.InfoCommissionNetwork[] childList;
    }

    struct StakeTokenPools {
        uint256 poolId;
        uint256 maxStakePerWallet;
        uint256 duration;
        bool isPayProfit;
        uint256 totalStake;
        uint256 totalEarn;
        address stakeToken;
        address earnToken;
    }

    struct StakedToken {
        uint256 stakeId;
        address userAddress;
        uint256 poolId;
        uint256 unlockTime;
        uint256 startTime;
        uint256 totalValueStake;
        uint256 totalValueClaimed;
        bool isWithdraw;
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

interface IEarn {
    event Earned(address _user, uint256 _valueDecimal);

    function setTokenContract(address _fitzenToken) external;

    function setOracleContract(address _oracleContract) external;

    function setStakingContract(address _stakingContract) external;

    function setMarketPlaceContract(address _marketplaceContract) external;

    function setRunningTokenEarned(address _address, uint256 value) external;

    function getRunningTokenEarned(address _wallet) external view returns (uint256);

    function getRunningCommissionEarned(address _wallet) external view returns (uint256);

    function forceUpdateRunningCommissionEarned(address _user, uint256 _value) external;

    function setMasterAddress(address _masterAddress) external;

    function claim(address _user, uint256 _valueDecimal, uint256 _earnableCommissionRewardUsdDecimal) external;

    function transferTokenToMasterAddress(uint256 _valueDecimal) external;
}
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";
import "../nft/OceanFiNFT.sol";
import "../data/StructData.sol";
import "../oracle/Oracle.sol";
import "../token/OceanFiERC20.sol";

contract Maintenance is Ownable, ERC721Holder {
    address public nft;
    address public token;
    uint16 public maintenanceFee;
    address private oracleContract;
    address public saleWallet = 0xbccEBAB38333b9E092817697941225f02A11e1B5;
    uint256 private timeToRepair;
    uint256 private timeCanRepair;
    bool reentrancyGuardForRepair = false;
    mapping(uint256 => bool) nftNeedRepair;
    mapping(uint256 => uint256) lastRepair;
    mapping(uint256 => StructData.ListMaintenance) listTimeNftMaintenance;

    event NftNeedRepair(uint256 nft, uint256 _time);
    event NftRepaired(uint256 nft, uint256 _time);

    constructor(address _nft) {
        nft = _nft;
        timeToRepair = 30;
        timeCanRepair = 7;
    }

    modifier validId(uint256 _nftId) {
        require(OceanFiNFT(nft).ownerOf(_nftId) != address(0), "INVALID NFT ID");
        _;
    }

    function setSaleWalletAddress(address _saleAddress) external onlyOwner {
        require(_saleAddress != address(0), "MARKETPLACE: INVALID SALE ADDRESS");
        saleWallet = _saleAddress;
    }

    function setNftAddress(address _nftAddress) external onlyOwner {
        require(_nftAddress != address(0), "MAINTENANCE: INVALID NFT ADDRESS");
        nft = _nftAddress;
    }

    function setTokenAddress(address _tokenAddress) external onlyOwner {
        require(_tokenAddress != address(0), "MAINTENANCE: INVALID TOKEN ADDRESS");
        token = _tokenAddress;
    }

    function setOracleAddress(address _oracleAddress) external onlyOwner {
        require(_oracleAddress != address(0), "MARKETPLACE: INVALID ORACLE ADDRESS");
        oracleContract = _oracleAddress;
    }

    function setMaintenanceFee(uint16 _percent) external onlyOwner {
        require(_percent >= 0 && _percent <= 100, "MAINTENANCE: INVALID PERCENT FEE");
        maintenanceFee = _percent;
    }

    function getFeeMaintainNft(uint256 _nftId) public view validId(_nftId) returns (uint256) {
        if (maintenanceFee == 0 || oracleContract == address(0) || token == address(0)) {
            return 0;
        }
        uint256 nftValueInUsd = OceanFiNFT(nft).getNftPriceUsd(_nftId);
        uint256 nftValueInToken = Oracle(oracleContract).convertUsdBalanceDecimalToTokenDecimal(nftValueInUsd);
        uint256 feeToMaintain = (nftValueInToken * (10 ** OceanFiERC20(token).decimals()) * maintenanceFee) / 100;
        return feeToMaintain;
    }

    function setDayNeedToRepair(uint256 _dayToNeedRepair) external onlyOwner {
        timeToRepair = _dayToNeedRepair;
    }

    function setTimeCanRepair(uint256 _dayCanRepair) external onlyOwner {
        timeCanRepair = _dayCanRepair;
    }

    function getDayNeedToRepair() external view returns (uint256) {
        return timeToRepair;
    }

    function getDayCanRepair() external view returns (uint256) {
        return timeCanRepair;
    }

    function isNeedRepair(uint256 _nftId) external view validId(_nftId) returns (bool) {
        bool isRepair = nftNeedRepair[_nftId];
        if (isRepair) {
            return isRepair;
        }
        if (timeToRepair == 0) {
            return false;
        }
        uint256 timeNow = block.timestamp;
        uint256 timeNeedRepair = getTimeRepair(_nftId);
        if (timeNeedRepair == 0) {
            return false;
        }
        if (timeNeedRepair <= timeNow) {
            return true;
        } else {
            return false;
        }
    }

    function checkNftNeedRepair(uint256 _nftId) external validId(_nftId) returns (bool) {
        bool isRepair = nftNeedRepair[_nftId];
        if (isRepair) {
            return isRepair;
        }
        if (timeToRepair == 0) {
            return false;
        }
        uint256 timeNow = block.timestamp;
        uint256 timeNeedRepair = getTimeRepair(_nftId);
        if (timeNeedRepair == 0) {
            return false;
        }
        if (timeNeedRepair <= timeNow) {
            nftNeedRepair[_nftId] = true;
            (bool checkSaveTime, StructData.InfoMaintenanceNft memory item, ) = checkTimeInListMaintenance(
                timeNeedRepair,
                _nftId
            );
            if (!checkSaveTime) {
                item.startTimeRepair = timeNeedRepair;
                item.endTimeRepair = 0;
                listTimeNftMaintenance[_nftId].childList.push(item);
            }
            emit NftNeedRepair(_nftId, timeNeedRepair);
            return true;
        } else {
            nftNeedRepair[_nftId] = false;
            return false;
        }
    }

    function checkNftNextTimeRepair(uint256 _nftId) public view validId(_nftId) returns (uint256) {
        uint256 timeNeedRepair = getTimeRepair(_nftId);
        if (timeNeedRepair != 0) {
            timeNeedRepair = timeNeedRepair - timeCanRepair * 24 * 3600;
        }
        return timeNeedRepair;
    }

    function checkTimeInListMaintenance(
        uint256 _timeNeedRepair,
        uint256 _nftId
    ) internal view returns (bool, StructData.InfoMaintenanceNft memory, uint) {
        StructData.InfoMaintenanceNft[] memory listMaintenance = listTimeNftMaintenance[_nftId].childList;
        bool checkSaveTime = false;
        uint idxMaintain = 0;
        StructData.InfoMaintenanceNft memory item;
        for (uint i = 0; i < listMaintenance.length; i++) {
            uint256 checkTime = listMaintenance[i].startTimeRepair;
            if (checkTime == _timeNeedRepair) {
                checkSaveTime = true;
                item = listMaintenance[i];
                idxMaintain = i;
                break;
            }
        }
        return (checkSaveTime, item, idxMaintain);
    }

    function getTimeRepair(uint256 _nftId) public view returns (uint256) {
        uint256 lastTimeRepair = lastRepair[_nftId];
        if (lastTimeRepair == 0) {
            lastTimeRepair = OceanFiNFT(nft).getBuyTime(_nftId); //buy time
        }
        if (lastTimeRepair == 0) {
            return 0;
        }
        uint256 timeNeedRepair = lastTimeRepair + timeToRepair * 3600 * 24;
        return timeNeedRepair;
    }

    function repairNft(uint256 _nftId) external validId(_nftId) {
        require(!reentrancyGuardForRepair, "MAINTENANCE: REENTRANCY DETECTED");
        reentrancyGuardForRepair = true;
        uint256 timeNeedRepair = getTimeRepair(_nftId);
        uint256 timeUserCanRepair = checkNftNextTimeRepair(_nftId);
        require(block.timestamp >= timeUserCanRepair, "MAINTENANCE: CAN NOT REPAIR NFT");
        uint256 feeNft = getFeeMaintainNft(_nftId);
        if (feeNft != 0 && token != address(0)) {
            require(
                OceanFiERC20(token).balanceOf(msg.sender) >= feeNft,
                "MAINTENANCE: NOT ENOUGH BALANCE CURRENCY TO REPAIR NFTs"
            );
            require(
                OceanFiERC20(token).allowance(msg.sender, address(this)) >= feeNft,
                "MAINTENANCE: MUST APPROVE FIRST"
            );
            require(
                OceanFiERC20(token).transferFrom(msg.sender, saleWallet, feeNft),
                "MAINTENANCE: FAILED IN TRANSFER CURRENCY TO MAINTENANCE"
            );
        }
        nftNeedRepair[_nftId] = false;
        if (block.timestamp >= timeNeedRepair) {
            (
                bool checkSaveTime,
                StructData.InfoMaintenanceNft memory item,
                uint idxMaintain
            ) = checkTimeInListMaintenance(timeNeedRepair, _nftId);
            if (checkSaveTime) {
                item.endTimeRepair = block.timestamp;
                listTimeNftMaintenance[_nftId].childList[idxMaintain] = item;
            } else {
                item.startTimeRepair = timeNeedRepair;
                item.endTimeRepair = block.timestamp;
                listTimeNftMaintenance[_nftId].childList.push(item);
            }
            lastRepair[_nftId] = block.timestamp;
            emit NftRepaired(_nftId, block.timestamp + timeToRepair * 3600 * 24);
        } else {
            lastRepair[_nftId] = timeNeedRepair;
            emit NftRepaired(_nftId, timeNeedRepair + timeToRepair * 3600 * 24);
        }
        reentrancyGuardForRepair = false;
    }

    function getTotalTimeRepair(uint256 _nftId) external view validId(_nftId) returns (uint256) {
        StructData.InfoMaintenanceNft[] memory listMaintenance = listTimeNftMaintenance[_nftId].childList;
        uint256 totalTime = 0;
        for (uint i = 0; i < listMaintenance.length; i++) {
            uint256 startTime = listMaintenance[i].startTimeRepair;
            uint256 endTime = listMaintenance[i].endTimeRepair;
            if (endTime == 0) {
                endTime = block.timestamp;
            }
            totalTime = totalTime + (endTime - startTime);
        }
        return totalTime;
    }

    function getTotalTimeStakeBroken(
        uint256 _nftId,
        uint256 stakeTime
    ) external view validId(_nftId) returns (uint256) {
        StructData.InfoMaintenanceNft[] memory listMaintenance = listTimeNftMaintenance[_nftId].childList;
        uint256 totalTime = 0;
        for (uint i = 0; i < listMaintenance.length; i++) {
            uint256 endTime = listMaintenance[i].endTimeRepair;
            if (endTime == 0) {
                endTime = block.timestamp;
            }
            if (endTime > stakeTime) {
                uint256 startTime = listMaintenance[i].startTimeRepair;
                if (startTime < stakeTime) {
                    startTime = stakeTime;
                }
                totalTime = totalTime + (endTime - startTime);
            }
        }

        // total time can't claim
        uint256 lastTimeRepair = getTimeRepair(_nftId);
        if (lastTimeRepair < block.timestamp && lastTimeRepair > 0) {
            totalTime = totalTime + block.timestamp - lastTimeRepair;
        }

        return totalTime;
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
        require(OceanFiERC20(_token).transfer(msg.sender, _amount), "CANNOT WITHDRAW TOKEN");
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

    function buyByTokenAndCurrency(uint256[] memory _nftIds, address _refAddress) external;

    function setSaleWalletAddress(address _saleAddress) external;

    function setStakingContractAddress(address _stakingAddress) external;

    function setNetworkWalletAddress(address _networkWallet) external;

    function setMaxNumberStakeValue(uint8 _percent) external;

    function setDefaultMaxCommission(uint256 _value) external;

    function setSaleStrategyOnlyCurrencyStart(uint256 _newSaleStart) external;

    function setSaleStrategyOnlyCurrencyEnd(uint256 _newSaleEnd) external;

    function setSalePercent(uint256 _newSalePercent) external;

    function setOracleAddress(address _oracleAddress) external;

    function setNftAddress(address _nftAddress) external;

    function allowBuyNftByCurrency(bool _activePayByCurrency) external;

    function allowBuyNftPass(bool _useNftPass) external;

    function allowBuyNftByToken(bool _activePayByToken) external;

    function setPayToken(bool _payInCurrency, bool _payInToken, bool _payInFlex) external;

    function allowBuyNftByCurrencyAndToken(bool _activePayByCurrencyAndToken) external;

    function setToken(address _address) external;

    function setTypePayCommission(uint256 _typePayCommission) external;

    function getActiveMemberForAccount(address _wallet) external returns (uint256);

    function getTotalCommission(address _wallet) external view returns (uint256);

    function getReferredNftValueForAccount(address _wallet) external returns (uint256);

    function getNftCommissionEarnedForAccount(address _wallet) external view returns (uint256);

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

    function isBuyByToken(uint256 _nftId) external view returns (bool);

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

    function setTierPriceUsdPercent(uint16 _tier, uint256 _percent) external;

    function getTierUsdPercent(uint16 _tier)external view returns (uint256);

    function setCommissionPercent(uint8 _level, uint16 _percent) external;

    function setMaxCommission(uint8 _level) external;

    function setNftBuyByToken(uint256 _nftId, bool _isBuyByToken) external;

    function setRankingContractAddress(address _stakingAddress) external;

    function setIsEnableBurnToken(bool _isEnableBurnToken) external;

    function setBurnAddress(address _burnAddress) external;
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";

contract OceanFiNFT is ERC721, Ownable, Pausable, ERC721Burnable {
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
    // Mapping from token ID to tier
    mapping(uint256 => uint16) private tokenTiers;
    // Mapping from token ID to time lock transfer
    mapping(uint256 => uint256) private lockTimeTransfer;
    mapping(uint256 => uint256) private buyTime;
    // Mapping from token ID to equip pool
    mapping(uint256 => bool) private equipPool;

    event Equipped(uint256 nft, uint256 _time);
    event UnEquipped(uint256 nft, uint256 _time);

    constructor(string memory _name, string memory _symbol, address _manager) ERC721(_name, _symbol) {
        marketplaceContractAddress = address(0);
        stakingContractAddress = address(0);
        lockDay = 365;
        transferOwnership(_manager);
        initTierPrices();
    }

    modifier validId(uint256 _nftId) {
        require(ownerOf(_nftId) != address(0), "INVALID NFT ID");
        _;
    }

    function initTierPrices() public onlyOwner {
        tierPrices[1] = 100000;
        tierPrices[2] = 25000;
        tierPrices[3] = 10000;
        tierPrices[4] = 5000;
        tierPrices[5] = 3000;
        tierPrices[6] = 1000;
        tierPrices[7] = 500;
        tierPrices[8] = 150;
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
        emit Equipped(_nftId, block.timestamp);
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
        emit UnEquipped(_nftId, block.timestamp);
    }

    function setEquipNftByAdmin(uint256 _nftId, bool _isEquip) external onlyOwner {
        equipPool[_nftId] = _isEquip;
    }

    function setLockTimeNftByAdmin(uint256 _nftId, uint256 timeLockNft) external onlyOwner {
        lockTimeTransfer[_nftId] = timeLockNft;
        buyTime[_nftId] = timeLockNft;
    }

    function getBuyTime(uint256 _nftId) external view validId(_nftId) returns (uint256) {
        return buyTime[_nftId];
    }

    function getLockTimeTransfer(uint256 _nftId) external view validId(_nftId) returns (uint256) {
        return lockTimeTransfer[_nftId];
    }

    //for external call
    function getNftPriceUsd(uint256 _nftId) external view validId(_nftId) returns (uint256) {
        uint16 nftTier = tokenTiers[_nftId];
        return tierPrices[nftTier];
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
    uint8 private typeConvert = 1; // 0:average 1: only swap 2: only pancake

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

import "../data/StructData.sol";

interface IStaking {
    event Staked(uint256 id, address indexed staker, uint256 indexed nftID, uint256 unlockTime);
    event Unstaked(uint256 id, address indexed staker, uint256 indexed nftID);

    event Claimed(uint256 id, address indexed staker, uint256 claimAmount);

    event ErrorLog(bytes message);

    function setTimeOpenStaking(uint256 _timeOpening) external;

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

    function setMarketContract(address _marketContract) external;

    function setRankingAddress(address _rankingAddress) external;

    function forceUpdateTeamStakingValue(address _user, uint256 _value) external;

    function forceUpdateStakingCommissionEarned(address _user, uint256 _value) external;

    function stake(uint256 _nftId, bytes memory _data) external;

    function unstake(uint256 _stakeId, bytes memory data) external;

    function claim(uint256 _stakeId) external;

    function claimAll(uint256[] memory _stakeIds) external;

    function getDetailOfStake(uint256 _stakeId) external view returns (StructData.StakedNFT memory);

    function possibleUnstake(uint256 _stakeId) external view returns (bool);

    function claimableForStakeInTokenWithDecimal(uint256 _nftId) external view returns (uint256);

    function earnableForStakeWithDecimal(uint256 _nftId) external view returns (uint256);

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

    function setEarnContract(address _earnContract) external;

    function setStakeTokenContract(address _stakeTokenContract) external;

    function setMaintenanceContract(address _maintenanceContract) external;

    function removeStakeEmergency(address _user, uint256[] memory _stakeIds) external;

    function setMarketCommission(address _currentRef, uint256 _commissionUsdWithDecimal) external;

    function getCommissionProfitUnclaim(address _user) external view returns (uint256);

    function getSaleAddresses() external view returns (address[] memory);

    function setSaleAddress(address[] memory _saleAddress) external;

    function checkUserIsSaleAddress(address _user) external view returns (bool);

    function setStakingLimit(uint256 _monthLimit) external;

    function getIsEnablePayRankingCommission() external view returns (bool);

    function setIsEnablePayRankingCommission(bool _isEnablePayRankingCommission) external;
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";
import "../nft/OceanFiNFT.sol";
import "../market/IMarketplace.sol";
import "../ranking/IRanking.sol";
import "../maintenance/Maintenance.sol";
import "../oracle/Oracle.sol";
import "../earn/IEarn.sol";
import "../tier/ITier.sol";
import "../data/StructData.sol";
import "./IStaking.sol";

contract Staking is IStaking, Ownable, ERC721Holder {
    address public oceanFiToken;
    address public usdtToken;
    address public nft;
    address public marketplaceContract;
    address public oracleContract;
    address public rankingContract;
    address public maintenanceContract;
    address public earnContract;
    address public stakeTokenContract;
    address public tierContract;
    address[] saleAddresses;

    bool public isEnablePayRankingCommission = true;
    uint256 public timeOpenStaking = 1689786000;
    uint256 public tokenDecimal = 1000000000000000000;
    uint256 public stakingPeriod = 24;
    uint256 public stakingLimit = 6;
    uint private unlocked = 1;

    // for network stats
    mapping(address => uint256) totalTeamInvestment;
    mapping(address => uint256) stakingCommissionEarned;
    mapping(address => uint256) refStakingValue;
    mapping(address => uint256) teamStakingValue;

    // mapping to store staked NFT information
    mapping(uint256 => StructData.StakedNFT) private stakedNFTs;
    // mapping to store commission percent when ref claim staking token
    mapping(uint32 => uint16) public commissionPercents;
    // mapping to store amount staked to get reward
    mapping(uint8 => uint32) public amountConditions;
    // mapping to store total stake amount
    mapping(address => uint256) public amountStaked;

    mapping(address => uint256[]) userStakingNfts; // nft user staking

    constructor(
        address _oceanFiToken,
        address _usdtToken,
        address _nft,
        address _oracleContract,
        address _marketplace,
        address _tierContract
    ) {
        oceanFiToken = _oceanFiToken;
        usdtToken = _usdtToken;
        nft = _nft;
        marketplaceContract = _marketplace;
        oracleContract = _oracleContract;
        tierContract = _tierContract;
        initCommissionConditionUsd();
        initCommissionPercents();
    }

    modifier isTimeForStaking() {
        require(block.timestamp >= timeOpenStaking, "STAKING: THE STAKING PROGRAM HAS NOT YET STARTED.");
        _;
    }

    modifier isOwnerNft(uint256 _nftId) {
        require(OceanFiNFT(nft).ownerOf(_nftId) == msg.sender, "STAKING: NOT OWNER THIS NFT ID");
        _;
    }

    modifier lock() {
        require(unlocked == 1, "STAKING: LOCKED");
        unlocked = 0;
        _;
        unlocked = 1;
    }

    /**
     * @dev set time open staking program
     */
    function setTimeOpenStaking(uint256 _timeOpening) external override onlyOwner {
        require(block.timestamp < _timeOpening, "STAKING: INVALID TIME OPENING.");
        timeOpenStaking = _timeOpening;
    }

    /**
     * @dev set token reward for direct commission
     */
    function setTokenDecimal(uint256 _decimal) external override onlyOwner {
        tokenDecimal = 10 ** _decimal;
    }

    /**
     * @dev set staking period
     */
    function setStakingPeriod(uint16 _stakingPeriod) external override onlyOwner {
        stakingPeriod = _stakingPeriod;
    }

    function getIsEnablePayRankingCommission() public view override returns (bool) {
        return isEnablePayRankingCommission;
    }

    function setIsEnablePayRankingCommission(bool _isEnablePayRankingCommission) external override onlyOwner {
        isEnablePayRankingCommission = _isEnablePayRankingCommission;
    }

    function getSaleAddresses() external view override returns (address[] memory) {
        return saleAddresses;
    }

    function setSaleAddress(address[] memory _saleAddress) external override onlyOwner {
        saleAddresses = _saleAddress;
    }

    function setTierContract(address _tierContract) external onlyOwner {
        tierContract = _tierContract;
    }

    function setTokenContract(address _tokenContract) external onlyOwner {
        oceanFiToken = _tokenContract;
    }

    /**
     * @dev init commission percent when ref claim staking token
     */
    function initCommissionPercents() internal {
        commissionPercents[0] = 1000;
        commissionPercents[1] = 800;
        commissionPercents[2] = 600;
        commissionPercents[3] = 500;
        commissionPercents[4] = 300;
        commissionPercents[5] = 300;
        commissionPercents[6] = 200;
        commissionPercents[7] = 100;
        commissionPercents[8] = 100;
        commissionPercents[9] = 100;
    }

    /**
     * @dev init condition(staked amount) to get commission for each level
     */
    function initCommissionConditionUsd() internal {
        amountConditions[0] = 0;
        amountConditions[1] = 300;
        amountConditions[2] = 500;
        amountConditions[3] = 1000;
        amountConditions[4] = 2000;
        amountConditions[5] = 3000;
        amountConditions[6] = 4000;
        amountConditions[7] = 5000;
        amountConditions[8] = 6000;
        amountConditions[9] = 6000;
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

    function setStakingLimit(uint256 _monthLimit) external override onlyOwner {
        stakingLimit = _monthLimit;
    }

    /**
     * @dev function to get commission condition
     * @param _level commission level
     */
    function getCommissionPercent(uint8 _level) public view override returns (uint16) {
        return commissionPercents[_level];
    }

    /**
     * @dev function to set commission percent
     * @param _level commission level
     * @param _percent commission percent value want to set (0-100)
     */
    function setCommissionPercent(uint8 _level, uint16 _percent) external override onlyOwner {
        commissionPercents[_level] = _percent;
    }

    function getTotalTeamInvestment(address _wallet) external view override returns (uint256) {
        return totalTeamInvestment[_wallet];
    }

    function getRefStakingValue(address _wallet) external view override returns (uint256) {
        return refStakingValue[_wallet];
    }

    function getTeamStakingValue(address _wallet) external view override returns (uint256) {
        return teamStakingValue[_wallet];
    }

    function getStakingCommissionEarned(address _wallet) external view override returns (uint256) {
        if (earnContract != address(0)) {
            return (stakingCommissionEarned[_wallet] + IEarn(earnContract).getRunningCommissionEarned(_wallet));
        } else {
            return stakingCommissionEarned[_wallet];
        }
    }

    function forceUpdateTotalCrewInvestment(address _user, uint256 _value) external override onlyOwner {
        totalTeamInvestment[_user] = _value;
    }

    function forceUpdateTeamStakingValue(address _user, uint256 _value) external override onlyOwner {
        teamStakingValue[_user] = _value;
    }

    function forceUpdateStakingCommissionEarned(address _user, uint256 _value) external override onlyOwner {
        stakingCommissionEarned[_user] = _value;
    }

    /**
     * @dev stake NFT function
     * @param _nftId NFT ID want to stake
     * @param _data addition information. Default is 0x00
     */
    function stake(uint256 _nftId, bytes memory _data) external override isTimeForStaking lock {
        // Get total balance in usd staked for user
        require(OceanFiNFT(nft).isApprovedForAll(msg.sender, address(this)), "STAKING: MUST APPROVE FIRST");
        address currentRef = IMarketplace(marketplaceContract).getReferralAccountForAccount(msg.sender);
        uint256 unlockTimeEstimate = block.timestamp + (2592000 * stakingPeriod);
        uint256 totalAmountStakeUsdDecimal = estimateValueUsdForStakeNft(_nftId) * tokenDecimal;
        // Update struct data
        stakedNFTs[_nftId].stakerAddress = msg.sender;
        stakedNFTs[_nftId].lastClaimedTime = block.timestamp;
        stakedNFTs[_nftId].unlockTime = unlockTimeEstimate;
        stakedNFTs[_nftId].totalValueStakeUsdWithDecimal = totalAmountStakeUsdDecimal;
        stakedNFTs[_nftId].isUnstaked = false;
        // Update amount staked for user
        amountStaked[msg.sender] = amountStaked[msg.sender] + totalAmountStakeUsdDecimal;
        userStakingNfts[msg.sender].push(_nftId);
        // Transfer NFT from user to contract
        require(OceanFiNFT(nft).ownerOf(_nftId) == msg.sender, "STAKING: NOT OWNER THIS NFT ID");
        try OceanFiNFT(nft).safeTransferFrom(msg.sender, address(this), _nftId, _data) {
            // Emit event
            emit Staked(_nftId, msg.sender, _nftId, unlockTimeEstimate);
        } catch (bytes memory _error) {
            emit ErrorLog(_error);
            revert("STAKING: NFT TRANSFER FAILED");
        }

        // Update refferal data & fixed data
        IMarketplace(marketplaceContract).updateReferralData(msg.sender, currentRef);
        // Update crew investment data && team staking data
        updateCrewInvestmentData(currentRef, totalAmountStakeUsdDecimal, _nftId);
        //update stat
        refStakingValue[currentRef] = refStakingValue[currentRef] + totalAmountStakeUsdDecimal;
    }

    /**
     * @dev get commission percent in new rule.
     */
    function getUserCommissionCanEarnUsdWithDecimal(
        address _user,
        uint256 _totalCommissionInTokenDecimal
    ) public view returns (uint256) {
        uint256 _totalCommissionInUsdDecimal = (_totalCommissionInTokenDecimal * tokenDecimal) /
                Oracle(oracleContract).convertUsdBalanceDecimalToTokenDecimal(tokenDecimal);
        uint256 maxCommissionWithDecimal = IMarketplace(marketplaceContract).getMaxCommissionByAddressInUsd(_user);
        uint256 totalCommissionDecimalEarned = IMarketplace(marketplaceContract).getTotalCommission(_user);
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
     * @param _nftId nft id claim
     */
    function claim(uint256 _nftId) public override lock {
        StructData.StakedNFT memory stakeInfo = stakedNFTs[_nftId];
        require(stakeInfo.unlockTime > 0, "STAKING: ONLY CLAIM YOUR OWN STAKE");
        require(block.timestamp > stakeInfo.lastClaimedTime, "STAKING: WRONG TIME TO CLAIM");
        require(!stakeInfo.isUnstaked, "STAKING: ALREADY UNSTAKED");
        require(stakeInfo.stakerAddress == msg.sender, "STAKING: ONLY CLAIM YOUR OWN STAKE");
        require(!checkUserIsSaleAddress(msg.sender), "STAKING: SALE ADDRESS CANNOT CLAIM");

        uint256 claimableRewardInTokenWithDecimal = claimableForStakeInTokenWithDecimal(_nftId);
        if (claimableRewardInTokenWithDecimal > 0) {
            require(
                IERC20(oceanFiToken).balanceOf(address(this)) >= claimableRewardInTokenWithDecimal,
                "STAKING: NOT ENOUGH TOKEN BALANCE TO PAY REWARD"
            );
            require(
                IERC20(oceanFiToken).transfer(msg.sender, claimableRewardInTokenWithDecimal),
                "STAKING: UNABLE TO TRANSFER COMMISSION PAYMENT TO RECIPIENT"
            );
            // get total commission can earned of ref 6 months
            uint256 earnableCommissionRewardTokenDecimal = earnableForStakeWithDecimal(_nftId);
            if (earnableCommissionRewardTokenDecimal > claimableRewardInTokenWithDecimal) {
                earnableCommissionRewardTokenDecimal = claimableRewardInTokenWithDecimal;
            }
            if (earnableCommissionRewardTokenDecimal > 0) {
                // Pay multi levels commission for user
                address currentRef = IMarketplace(marketplaceContract).getReferralAccountForAccount(msg.sender);
                bool paidDirectSuccess = payCommissionMultiLevels(currentRef, earnableCommissionRewardTokenDecimal);
                require(paidDirectSuccess == true, "STAKING: FAIL IN PAY COMMISSION FOR DIRECT REF");

                // pay for ranking commission
                if (isEnablePayRankingCommission) {
                    IRanking(rankingContract).payRankingCommission(currentRef, earnableCommissionRewardTokenDecimal);
                }
            }
            stakedNFTs[_nftId].totalClaimedAmountTokenWithDecimal += claimableRewardInTokenWithDecimal;
            stakedNFTs[_nftId].lastClaimedTime = block.timestamp;

            emit Claimed(_nftId, msg.sender, claimableRewardInTokenWithDecimal);
        }
    }

    /**
     * @dev function to calculate claimable reward in Usd based on staking time and period
     * @param _nftId nft Id claiming
     */
    function claimableForStakeInTokenWithDecimal(uint256 _nftId) public view override returns (uint256) {
        StructData.StakedNFT memory stakeInfo = stakedNFTs[_nftId];
        uint256 totalTokenClaimDecimal = 0;
        uint256 timeDuration = block.timestamp < stakeInfo.unlockTime ? block.timestamp : stakeInfo.unlockTime;
        uint256 timeBroken = Maintenance(maintenanceContract).getTotalTimeStakeBroken(
            _nftId,
            stakeInfo.lastClaimedTime
        );
        uint32 tier = OceanFiNFT(nft).getNftTier(_nftId);
        uint256 index = ITier(tierContract).getMaxIndex(tier);
        uint256 tokenEarn = 0;
        for (uint i = 0; i < index; i++) {
            uint256 startTime = ITier(tierContract).getStartTime(tier)[i];
            uint256 endTime = ITier(tierContract).getEndTime(tier)[i];
            tokenEarn = ITier(tierContract).getTokenEarn(tier)[i];
            if (startTime <= stakeInfo.lastClaimedTime && (endTime > stakeInfo.lastClaimedTime || endTime == 0)) {
                endTime = endTime > 0 ? endTime : timeDuration;
                totalTokenClaimDecimal +=
                    ((endTime - stakeInfo.lastClaimedTime) * tokenEarn * tokenDecimal) /
                    86400 /
                    10000;
                stakeInfo.lastClaimedTime = endTime;
            }
        }

        uint256 totalTokenLostByBroken = (timeBroken * tokenEarn * tokenDecimal) / 86400 / 10000;
        if (totalTokenLostByBroken > totalTokenClaimDecimal) {
            return 0;
        }

        return totalTokenClaimDecimal - totalTokenLostByBroken;
    }

    /**
     * @dev function to get earnable commission 6 months
     * @param _nftId nft ID claiming
     */
    function earnableForStakeWithDecimal(uint256 _nftId) public view override returns (uint256) {
        StructData.StakedNFT memory stakeInfo = stakedNFTs[_nftId];
        uint256 startBuyTime = OceanFiNFT(nft).getBuyTime(_nftId);
        uint256 endEarnableTime = 0;
        if (startBuyTime > 0) {
            endEarnableTime = startBuyTime + 2592000 * stakingLimit;
        } else {
            endEarnableTime = stakeInfo.unlockTime - 2592000 * (stakingPeriod - stakingLimit);
        }
        if (stakeInfo.lastClaimedTime >= endEarnableTime) {
            // 6 * 30 * 24 * 3600
            return 0;
        }

        uint256 totalTokenCanEarnDecimal = 0;
        uint256 timeDuration = block.timestamp < stakeInfo.unlockTime ? block.timestamp : stakeInfo.unlockTime;
        uint32 tier = OceanFiNFT(nft).getNftTier(_nftId);
        uint256 index = ITier(tierContract).getMaxIndex(tier);
        for (uint i = 0; i < index; i++) {
            uint256 startTime = ITier(tierContract).getStartTime(tier)[i];
            uint256 endTime = ITier(tierContract).getEndTime(tier)[i];
            uint256 tokenEarn = ITier(tierContract).getTokenEarn(tier)[i];
            if (startTime <= stakeInfo.lastClaimedTime && (endTime > stakeInfo.lastClaimedTime || endTime == 0)) {
                endTime = endTime > 0 ? endTime : timeDuration;
                endTime = endEarnableTime < endTime ? endEarnableTime : endTime;
                totalTokenCanEarnDecimal +=
                    ((endTime - stakeInfo.lastClaimedTime) * tokenEarn * tokenDecimal) /
                    86400 /
                    10000;
            }
        }

        return totalTokenCanEarnDecimal;
    }

    function checkUserIsSaleAddress(address _user) public view override returns (bool) {
        bool isSale = false;
        for (uint i = 0; i < saleAddresses.length; i++) {
            if (_user == saleAddresses[i]) {
                isSale = true;
            }
        }

        return isSale;
    }

       /**
     * @dev function to pay commissions in 10 level
     * @param _firstRef direct referral account wallet address
     * @param _totalAmountStakeTokenWithDecimal total amount stake in token with decimal for this stake
     */
    function payCommissionMultiLevels(
        address _firstRef,
        uint256 _totalAmountStakeTokenWithDecimal
    ) internal returns (bool) {
        address currentRef = _firstRef;
        uint8 index = 0;
        while (currentRef != address(0) && index < 10) {
            // Check if ref account is eligible to staked amount enough for commission
            bool totalStakeAmount = possibleForCommission(currentRef, index);
            if (totalStakeAmount) {
                // Transfer commission in token amount
                uint256 commissionPercent = getCommissionPercent(index);
                uint256 totalCommissionInTokenDecimal = (_totalAmountStakeTokenWithDecimal * commissionPercent) / 10000;
                // calculate max commission can earn
                uint256 _commissionCanEarnUsdWithDecimal = getUserCommissionCanEarnUsdWithDecimal(
                    currentRef,
                    totalCommissionInTokenDecimal
                );
                if (_commissionCanEarnUsdWithDecimal > 0) {
                    totalCommissionInTokenDecimal = Oracle(oracleContract).convertUsdBalanceDecimalToTokenDecimal(
                        _commissionCanEarnUsdWithDecimal
                    );
                    require(totalCommissionInTokenDecimal > 0, "STAKING: INVALID TOKEN BALANCE COMMISSION");
                    require(
                        IERC20(oceanFiToken).balanceOf(address(this)) >= totalCommissionInTokenDecimal,
                        "STAKING: NOT ENOUGH TOKEN BALANCE TO PAY COMMISSION"
                    );
                    require(
                        IERC20(oceanFiToken).transfer(currentRef, totalCommissionInTokenDecimal),
                        "STAKING: UNABLE TO TRANSFER COMMISSION PAYMENT TO RECIPIENT"
                    );
                    // update market contract
                    IMarketplace(marketplaceContract).updateCommissionStakeValueData(
                        currentRef,
                        _commissionCanEarnUsdWithDecimal
                    );
                    stakingCommissionEarned[currentRef] =
                        stakingCommissionEarned[currentRef] +
                        totalCommissionInTokenDecimal;
                }
            }
            index++;
            currentRef = IMarketplace(marketplaceContract).getReferralAccountForAccount(currentRef);
        }
        return true;
    }

    /**
     * @dev function to check the staked amount enough to get commission
     * @param _staker staker wallet address
     * @param _level commission level need to check condition
     */
    function possibleForCommission(address _staker, uint8 _level) public view returns (bool) {
        uint256 totalStakeAmount = IMarketplace(marketplaceContract).getNftSaleValueForAccountInUsdDecimal(_staker);
        totalStakeAmount = totalStakeAmount / tokenDecimal;
        uint32 conditionAmount = amountConditions[_level];
        if (totalStakeAmount >= conditionAmount) {
            return true;
        }

        return false;
    }

    /**
     * @dev function to get total stake amount in usd
     * @param _staker staker wallet address
     */
    function getTotalStakeAmountUSD(address _staker) public view returns (uint256) {
        return amountStaked[_staker] / tokenDecimal;
    }

    function updateCrewInvestmentData(
        address nextRef,
        uint256 _totalAmountStakeUsdWithDecimal,
        uint256 _nftId
    ) internal {
        address currentRef;
        uint8 index = 1;
        while (currentRef != nextRef && nextRef != address(0) && index <= 100) {
            // Update Team Staking Value ( 100 level)
            currentRef = nextRef;
            uint256 currentCrewInvestmentValue = totalTeamInvestment[currentRef];
            totalTeamInvestment[currentRef] = currentCrewInvestmentValue + _totalAmountStakeUsdWithDecimal;
            IRanking(rankingContract).setUserRefNfts(_nftId, currentRef);
            uint256 currentStakingValue = teamStakingValue[currentRef];
            teamStakingValue[currentRef] = currentStakingValue + _totalAmountStakeUsdWithDecimal;
            index++;
            nextRef = payable(IMarketplace(marketplaceContract).getReferralAccountForAccount(currentRef));
        }
    }

    /**
     * @dev estimate value in USD for a stake of NFT
     * @param _nftId id nft stake
     */
    function estimateValueUsdForStakeNft(uint256 _nftId) public view returns (uint256) {
        return OceanFiNFT(nft).getNftPriceUsd(_nftId);
    }

    /**
     * @dev unstake NFT function
     * @param _nftId id nft unstake
     * @param _data addition information. Default is 0x00
     */
    function unstake(uint256 _nftId, bytes memory _data) external override lock {
        require(possibleUnstake(_nftId) == true, "STAKING: STILL IN STAKING PERIOD");
        address staker = stakedNFTs[_nftId].stakerAddress;
        require(staker == msg.sender, "STAKING: NOT NFT OF USER");
        // Set staking was unstaked
        stakedNFTs[_nftId].isUnstaked = true;
        // Update total amount staked of user
        uint256 amountStakedUser = stakedNFTs[_nftId].totalValueStakeUsdWithDecimal;
        amountStaked[msg.sender] = amountStaked[msg.sender] - amountStakedUser;
        // Transfer NFT from contract to claimer
        try OceanFiNFT(nft).safeTransferFrom(address(this), staker, _nftId, _data) {
            // Emit event
            emit Unstaked(_nftId, staker, _nftId);
        } catch (bytes memory _error) {
            emit ErrorLog(_error);
            revert("STAKING: UNSTAKE FAILED");
        }
        // Calculate & send reward in token
        uint256 claimableRewardInTokenWithDecimal = claimableForStakeInTokenWithDecimal(_nftId);
        require(
            IERC20(oceanFiToken).balanceOf(address(this)) >= claimableRewardInTokenWithDecimal,
            "STAKING: NOT ENOUGH TOKEN BALANCE TO PAY UNSTAKE REWARD"
        );
        require(
            IERC20(oceanFiToken).transfer(staker, claimableRewardInTokenWithDecimal),
            "STAKING: UNABLE TO TRANSFER COMMISSION PAYMENT TO RECIPIENT"
        );
        // get total commission can earned of ref 6 months
        uint256 earnableCommissionRewardTokenDecimal = earnableForStakeWithDecimal(_nftId);
        if (earnableCommissionRewardTokenDecimal > claimableRewardInTokenWithDecimal) {
            earnableCommissionRewardTokenDecimal = claimableRewardInTokenWithDecimal;
        }
        if (earnableCommissionRewardTokenDecimal > 0) {
            // Pay multi levels commission for user
            address currentRef = IMarketplace(marketplaceContract).getReferralAccountForAccount(msg.sender);
            bool paidDirectSuccess = payCommissionMultiLevels(currentRef, earnableCommissionRewardTokenDecimal);
            require(paidDirectSuccess == true, "STAKING: FAIL IN PAY COMMISSION FOR DIRECT REF");

            // pay for ranking commission
            if (isEnablePayRankingCommission) {
                IRanking(rankingContract).payRankingCommission(currentRef, earnableCommissionRewardTokenDecimal);
            }
        }
        // Set total claimed full
        stakedNFTs[_nftId].totalClaimedAmountTokenWithDecimal += claimableRewardInTokenWithDecimal;

        emit Claimed(_nftId, msg.sender, claimableRewardInTokenWithDecimal);
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
    function transferNftEmergency(address _receiver, uint256 _nftId) public override onlyOwner {
        require(OceanFiNFT(nft).ownerOf(_nftId) == address(this), "STAKING: NOT OWNER OF THIS NFT");
        try OceanFiNFT(nft).safeTransferFrom(address(this), _receiver, _nftId, "") {} catch (bytes memory _error) {
            emit ErrorLog(_error);
            revert("STAKING: NFT TRANSFER FAILED");
        }
    }

    /**
     * @dev transfer a list of NFT from this contract to a list of account, only owner
     */
    function transferMultiNftsEmergency(
        address[] memory _receivers,
        uint256[] memory _nftIds
    ) external override onlyOwner {
        require(_receivers.length == _nftIds.length, "STAKING: MUST BE SAME SIZE");
        for (uint index = 0; index < _nftIds.length; index++) {
            transferNftEmergency(_receivers[index], _nftIds[index]);
        }
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
     * @dev set maintenance contract address
     */
    function setMaintenanceContract(address _maintenanceContract) public override onlyOwner {
        require(_maintenanceContract != address(0), "STAKING: INVALID MAINTENANCE ADDRESS");
        maintenanceContract = _maintenanceContract;
    }

    /**
     * @dev set earn contract address
     */
    function setEarnContract(address _earnContract) external override onlyOwner {
        require(_earnContract != address(0), "STAKING: INVALID EARN CONTRACT ADDRESS");
        earnContract = _earnContract;
    }

    /**
    * @dev set earn contract address
     */
    function setStakeTokenContract(address _stakeTokenContract) external override onlyOwner {
        require(_stakeTokenContract != address(0), "STAKING: INVALID STAKE TOKEN CONTRACT ADDRESS");
        stakeTokenContract = _stakeTokenContract;
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
     * @param _currentRef user update commission value
     * @param _commissionUsdWithDecimal commission value
     */
    function setMarketCommission(address _currentRef, uint256 _commissionUsdWithDecimal) external override {
        require(
            msg.sender == rankingContract || msg.sender == earnContract || msg.sender == stakeTokenContract,
            "STAKING: SENDER NOT RANKING OR EARN CONTRACT"
        );
        IMarketplace(marketplaceContract).updateCommissionStakeValueData(_currentRef, _commissionUsdWithDecimal);
    }

    /**
     * @dev get commission levels can claim
     * @param _user user address
     */
    function getCommissionProfitUnclaim(address _user) external view override returns (uint256) {
        uint8 maxFloor = getMaxFloorProfit(_user);
        uint256 totalClaimableTokenWithDecimal = 0;
        totalClaimableTokenWithDecimal = getClaimableProfitF1(_user, 0, maxFloor, totalClaimableTokenWithDecimal);
        uint256 _commissionCanEarnUsdWithDecimal = getUserCommissionCanEarnUsdWithDecimal(
            _user,
            totalClaimableTokenWithDecimal
        );

        return _commissionCanEarnUsdWithDecimal;
    }

    function getMaxFloorProfit(address _user) public view override returns (uint8) {
        uint256 totalBuyAmount = IMarketplace(marketplaceContract).getNftSaleValueForAccountInUsdDecimal(_user);
        uint8 maxFloor = 0;
        for (uint8 i = 0; i < 10; i++) {
            if (totalBuyAmount >= amountConditions[i]) {
                maxFloor = i;
            }
        }

        return maxFloor;
    }

    /**
     * @dev get commission can earn of level
     * @param _user user calculate
     * @param floor floor earn commission
     * @param maxFloor max floor earn commission
     * @param totalClaimableTokenWithDecimal total claim
     */
    function getClaimableProfitF1(
        address _user,
        uint8 floor,
        uint8 maxFloor,
        uint256 totalClaimableTokenWithDecimal
    ) internal view returns (uint256) {
        uint16 _commissionPercent = commissionPercents[floor];
        address[] memory f1s = IMarketplace(marketplaceContract).getF1ListForAccount(_user);
        if (f1s.length == 0) {
            return totalClaimableTokenWithDecimal;
        }
        floor = floor + 1;
        for (uint index = 0; index < f1s.length; index++) {
            uint256[] memory nfts = userStakingNfts[f1s[index]];
            for (uint i = 0; i < nfts.length; i++) {
                uint256 earnableCommissionRewardTokenDecimal = claimableForStakeInTokenWithDecimal(nfts[i]);
                uint256 commissionNftCanEarnToken = (earnableCommissionRewardTokenDecimal * _commissionPercent) / 10000;
                totalClaimableTokenWithDecimal = totalClaimableTokenWithDecimal + commissionNftCanEarnToken;
            }
            if (floor <= maxFloor) {
                totalClaimableTokenWithDecimal = getClaimableProfitF1(
                    f1s[index],
                    floor,
                    maxFloor,
                    totalClaimableTokenWithDecimal
                );
            }
        }

        return totalClaimableTokenWithDecimal;
    }

    function setMarketContract(address _marketContract) external override onlyOwner {
        marketplaceContract = _marketContract;
    }

     function updateStakeNFT(
        uint256 _nftId,
        uint256 _lastClaimedTime,
        uint256 _unlockTime,
        uint256 _totalValueStakeUsdWithDecimal,
        address _stakerAddress,
        uint256 _totalClaimedAmountTokenWithDecimal,
        bool _isUnstaked
    ) external onlyOwner {
        stakedNFTs[_nftId].stakerAddress = _stakerAddress;
        stakedNFTs[_nftId].lastClaimedTime = _lastClaimedTime;
        stakedNFTs[_nftId].unlockTime = _unlockTime;
        stakedNFTs[_nftId].totalValueStakeUsdWithDecimal = _totalValueStakeUsdWithDecimal;
        stakedNFTs[_nftId].totalClaimedAmountTokenWithDecimal = _totalClaimedAmountTokenWithDecimal;
        stakedNFTs[_nftId].isUnstaked = _isUnstaked;
    }

    function updateUserStakingNftsOnlyOwner(address _wallet, uint256[] calldata _userStakingNfts) external onlyOwner {
        userStakingNfts[_wallet] = _userStakingNfts;
    }

    function updateUserInformation(
        address _user,
        uint256 _totalTeamInvestment,
        uint256 _stakingCommissionEarned,
        uint256 _refStakingValue,
        uint256 _teamStakingValue,
        uint256 _amountStaked
    ) external onlyOwner {
        totalTeamInvestment[_user] = _totalTeamInvestment;
        stakingCommissionEarned[_user] = _stakingCommissionEarned;
        refStakingValue[_user] = _refStakingValue;
        teamStakingValue[_user] = _teamStakingValue;
        amountStaked[_user] = _amountStaked;
    }

    /**
     * @dev possible to receive any IERC20 tokens
     */
    receive() external payable {}
}
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

interface IMarketplaceSmall {
    function getNftSaleValueForAccountInUsdDecimal(address _wallet) external view returns (uint256);
}

contract InternalSwap is Ownable {
    uint256 public constant SECONDS_PER_DAY = 86400;

    uint256 private usdtAmount = 1000000;
    uint256 private tokenAmount = 2000000;
    address public currency;
    address public tokenAddress;
    address public marketContract;
    uint8 private typeSwap = 0; //0: all, 1: usdt -> token only, 2: token -> usdt only
    bool public onlyBuyerCanSwap = false;

    uint256 private limitDay = 1;
    uint256 private limitValue = 0;
    uint256 private _taxSellFee = 1000;
    uint256 private _taxBuyFee = 0;
    address private _taxAddress = 0x7a84d8a52550D9dc666a600F39930b05C80457e3;

    mapping(address => bool) private _addressBuyExcludeTaxFee;
    mapping(address => bool) private _addressSellExcludeHasTaxFee;
    mapping(address => bool) public swapWhiteList;

    // wallet -> date buy -> total amount
    mapping(address => mapping(uint256 => uint256)) private _sellAmounts;

    address private contractOwner;
    uint256 private unlocked = 1;

    event ChangeRate(uint256 _usdtAmount, uint256 _tokenAmount, uint256 _time);

    constructor(address _stableToken, address _tokenAddress) {
        currency = _stableToken;
        tokenAddress = _tokenAddress;
        contractOwner = _msgSender();
    }

    modifier checkOwner() {
        require(owner() == _msgSender() || contractOwner == _msgSender(), "SWAP: CALLER IS NOT THE OWNER");
        _;
    }

    modifier canSwap() {
        require(!onlyBuyerCanSwap || swapWhiteList[msg.sender] || isBuyer(msg.sender), "SWAP: CALLER CAN NOT SWAP");
        _;
    }

    modifier lock() {
        require(unlocked == 1, "SWAP: LOCKED");
        unlocked = 0;
        _;
        unlocked = 1;
    }

    function isBuyer(address _wallet) public view returns (bool) {
        require(marketContract != address(0), "SWAP: MARKETPLACE CONTRACT IS ZERO ADDRESS");
        return IMarketplaceSmall(marketContract).getNftSaleValueForAccountInUsdDecimal(_wallet) > 0;
    }

    function getLimitDay() external view returns (uint256) {
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

    function getTaxSellFee() external view returns (uint256) {
        return _taxSellFee;
    }

    function getTaxBuyFee() external view returns (uint256) {
        return _taxBuyFee;
    }

    function getTaxAddress() external view returns (address) {
        return _taxAddress;
    }

    function getTypeSwap() external view returns (uint8) {
        return typeSwap;
    }

    function setCurrency(address _currency) external checkOwner {
        currency = _currency;
    }

    function setTokenAddress(address _tokenAddress) external checkOwner {
        tokenAddress = _tokenAddress;
    }

    function setMarketContract(address _marketContract) external checkOwner {
        marketContract = _marketContract;
    }

    function setLimitDay(uint256 _limitDay) external checkOwner {
        limitDay = _limitDay;
    }

    function setLimitValue(uint256 _limitValue) external checkOwner {
        limitValue = _limitValue;
    }

    function setOnlyBuyerCanSwap(bool _onlyBuyerCanSwap) external checkOwner {
        onlyBuyerCanSwap = _onlyBuyerCanSwap;
    }

    function setSwapWhiteList(address _walletAddress, bool _isSwapWhiteList) external checkOwner {
        swapWhiteList[_walletAddress] = _isSwapWhiteList;
    }

    function setTaxSellFeePercent(uint256 taxFeeBps) external checkOwner {
        _taxSellFee = taxFeeBps;
    }

    function setTaxBuyFeePercent(uint256 taxFeeBps) external checkOwner {
        _taxBuyFee = taxFeeBps;
    }

    function setTaxAddress(address taxAddress) external checkOwner {
        _taxAddress = taxAddress;
    }

    function setAddressBuyExcludeTaxFee(address account, bool excludeFee) external checkOwner {
        _addressBuyExcludeTaxFee[account] = excludeFee;
    }

    function setAddressSellExcludeTaxFee(address account, bool excludeFee) external checkOwner {
        _addressSellExcludeHasTaxFee[account] = excludeFee;
    }

    function setPriceData(uint256 _usdtAmount, uint256 _tokenAmount) external checkOwner {
        require(_usdtAmount > 0 && _tokenAmount > 0, "SWAP: INVALID DATA");
        usdtAmount = _usdtAmount;
        tokenAmount = _tokenAmount;
        emit ChangeRate(_usdtAmount, _tokenAmount, block.timestamp);
    }

    function setPriceType(uint8 _type) external checkOwner {
        require(_type <= 2, "SWAP: INVALID TYPE SWAP (0, 1, 2)");
        typeSwap = _type;
    }

    function checkCanSellToken(address _wallet, uint256 _tokenValue) internal view returns (bool) {
        if (limitValue == 0 || limitDay == 0) {
            return true;
        }

        uint256 currentDate = block.timestamp / (limitDay * SECONDS_PER_DAY);
        uint256 valueAfterSell = _sellAmounts[_wallet][currentDate] + _tokenValue;
        uint256 maxValue = (limitValue * (10 ** ERC20(tokenAddress).decimals()) * tokenAmount) / usdtAmount;

        if (valueAfterSell > maxValue) {
            return false;
        }

        return true;
    }

    function buyToken(uint256 _usdtValue) external lock canSwap {
        require(typeSwap == 1 || typeSwap == 0, "SWAP: CANNOT BUY TOKEN NOW");
        require(_usdtValue > 0, "SWAP: INVALID VALUE");

        uint256 buyFee = 0;
        uint256 amountTokenDecimal = (_usdtValue * tokenAmount) / usdtAmount;
        if (_taxBuyFee != 0 && !_addressBuyExcludeTaxFee[msg.sender]) {
            buyFee = (amountTokenDecimal * _taxBuyFee) / 10000;
            amountTokenDecimal = amountTokenDecimal - buyFee;
        }

        if (amountTokenDecimal != 0) {
            require(ERC20(currency).balanceOf(msg.sender) >= _usdtValue, "SWAP: NOT ENOUGH BALANCE CURRENCY TO BUY");
            require(ERC20(currency).allowance(msg.sender, address(this)) >= _usdtValue, "SWAP: MUST APPROVE FIRST");
            require(ERC20(currency).transferFrom(msg.sender, address(this), _usdtValue), "SWAP: FAIL TO SWAP");

            require(ERC20(tokenAddress).transfer(msg.sender, amountTokenDecimal), "SWAP: FAIL TO SWAP");
            if (buyFee != 0) {
                require(ERC20(tokenAddress).transfer(_taxAddress, buyFee), "SWAP: FAIL TO SWAP");
            }
        }
    }

    function sellToken(uint256 _tokenValue) external lock canSwap {
        require(typeSwap == 2 || typeSwap == 0, "SWAP: CANNOT SELL TOKEN NOW");
        require(_tokenValue > 0, "SWAP: INVALID VALUE");
        require(checkCanSellToken(msg.sender, _tokenValue), "SWAP: MAXIMUM SWAP TODAY");

        uint256 sellFee = 0;
        if (_taxSellFee != 0 && !_addressSellExcludeHasTaxFee[msg.sender]) {
            sellFee = (_tokenValue * _taxSellFee) / 10000;
        }
        uint256 amountUsdtDecimal = ((_tokenValue - sellFee) * usdtAmount) / tokenAmount;

        if (amountUsdtDecimal != 0) {
            require(ERC20(tokenAddress).balanceOf(msg.sender) >= _tokenValue, "SWAP: NOT ENOUGH BALANCE TOKEN TO SELL");
            require(ERC20(tokenAddress).allowance(msg.sender, address(this)) >= _tokenValue, "SWAP: MUST APPROVE FIRST");
            require(ERC20(tokenAddress).transferFrom(msg.sender, address(this), _tokenValue), "SWAP: FAIL TO SWAP");
            require(ERC20(currency).transfer(msg.sender, amountUsdtDecimal), "SWAP: FAIL TO SWAP");

            if (sellFee != 0) {
                require(ERC20(tokenAddress).transfer(_taxAddress, sellFee), "SWAP: FAIL TO SWAP");
            }

            if (limitDay > 0) {
                uint256 currentDate = block.timestamp / (limitDay * SECONDS_PER_DAY);
                _sellAmounts[msg.sender][currentDate] = _sellAmounts[msg.sender][currentDate] + _tokenValue;
            }
        }
    }

    function setContractOwner(address _newContractOwner) external checkOwner {
        contractOwner = _newContractOwner;
    }

    function recoverBNB(uint256 _amount) public checkOwner {
        require(_amount > 0, "INVALID AMOUNT");
        address payable recipient = payable(msg.sender);
        recipient.transfer(_amount);
    }

    function withdrawTokenEmergency(address _token, uint256 _amount) public checkOwner {
        require(_amount > 0, "INVALID AMOUNT");
        require(IERC20(_token).transfer(msg.sender, _amount), "CANNOT WITHDRAW TOKEN");
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

interface ITier {
    function setNftTierEarnPerDay(uint32 _nftTier, uint256 _nftTierEarnPerDay) external;
    
    function setNftTierExactly(uint32 _nftTier, uint256[] calldata _startTime, uint256[] calldata _endTime, uint256[] calldata _tokenEarn) external;

    function getStartTime(uint32 _nftTier) external view returns (uint256[] memory);

    function getEndTime(uint32 _nftTier) external view returns (uint256[] memory);

    function getTokenEarn(uint32 _nftTier) external view returns (uint256[] memory);

    function getMaxIndex(uint32 _nftTier) external view returns (uint256);
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract OceanFiERC20 is Context, IERC20, IERC20Metadata, Ownable {
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    address private _taxAddress = 0x7a84d8a52550D9dc666a600F39930b05C80457e3;
    uint256 private _taxSellFee = 0;
    uint256 private _taxBuyFee = 0;

    mapping(address => bool) private _addressSellHasTaxFee;
    mapping(address => bool) private _addressBuyHasTaxFee;
    mapping(address => bool) private _addressBuyExcludeTaxFee;
    mapping(address => bool) private _addressSellExcludeHasTaxFee;

    mapping (address => uint256) public _balancesLocked;
    mapping (address => bool) public _lockers;
    mapping (address => bool) public _unlockers;

    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * All two of these values are immutable: they can only be set once during
     * construction.
     */
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
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

    function setTaxSellFeePercent(uint256 taxSellFee) public onlyOwner {
        _taxSellFee = taxSellFee;
    }

    function setTaxBuyFeePercent(uint256 taxBuyFee) public onlyOwner {
        _taxBuyFee = taxBuyFee;
    }

    function setTaxAddress(address taxAddress) public onlyOwner {
        require(taxAddress != address(0), "ERC20: taxAddress is zero address");
        _taxAddress = taxAddress;
    }

    function setAddressSellHasTaxFee(address account, bool hasFee) public onlyOwner {
        require(account != address(0), "ERC20: account is zero address");
        _addressSellHasTaxFee[account] = hasFee;
    }

    function isAddressSellHasTaxFee(address account) public view returns (bool) {
        return _addressSellHasTaxFee[account];
    }

    function setAddressBuyHasTaxFee(address account, bool hasFee) public onlyOwner {
        require(account != address(0), "ERC20: account is zero address");
        _addressBuyHasTaxFee[account] = hasFee;
    }

    function isAddressBuyHasTaxFee(address account) public view returns (bool) {
        return _addressBuyHasTaxFee[account];
    }

    function setAddressBuyExcludeTaxFee(address account, bool hasFee) public onlyOwner {
        require(account != address(0), "ERC20: account is zero address");
        _addressBuyExcludeTaxFee[account] = hasFee;
    }

    function setAddressSellExcludeTaxFee(address account, bool hasFee) public onlyOwner {
        require(account != address(0), "ERC20: account is zero address");
        _addressSellExcludeHasTaxFee[account] = hasFee;
    }

    function setLocker(address account, bool isLocker) public onlyOwner {
        require(account != address(0), "ERC20: account is zero address");
        _lockers[account] = isLocker;
    }

    function setUnlocker(address account, bool isUnlocker) public onlyOwner {
        require(account != address(0), "ERC20: account is zero address");
        _unlockers[account] = isUnlocker;
    }

    function unlockBalance(address wallet, uint256 amount) public {
        require(_unlockers[_msgSender()], "ERC20: not allow!");
        _balancesLocked[wallet] = _balancesLocked[wallet] - amount;
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
        require(amount <= balanceOf(from) - _balancesLocked[from], "ERC20: Not enough balance!");
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        uint256 amountToReceive = amount;
        uint256 amountToTax = 0;

        if (_taxSellFee != 0 && _addressSellHasTaxFee[to] && !_addressSellExcludeHasTaxFee[from]) {
            uint256 amountSellFee = (amountToReceive * _taxSellFee) / 10000;
            amountToReceive = amountToReceive - amountSellFee;
            amountToTax = amountToTax + amountSellFee;
        } else {
            if (_taxBuyFee != 0 && _addressBuyHasTaxFee[from] && !_addressBuyExcludeTaxFee[to]) {
                uint256 amountBuyFee = (amountToReceive * _taxBuyFee) / 10000;
                amountToReceive = amountToReceive - amountBuyFee;
                amountToTax = amountToTax + amountBuyFee;
            }
        }

        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
            _balances[to] += amountToReceive;
        }
        emit Transfer(from, to, amountToReceive);

        if(_lockers[from]){
            _balancesLocked[to] = _balancesLocked[to] + amountToReceive;
        }

        if (amountToTax != 0) {
            unchecked {
                _balances[_taxAddress] += amountToTax;
            }
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
