// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

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
// File @openzeppelin/contracts/token/ERC20/ERC20.sol@v4.9.3

// Original license: SPDX_License_Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (token/ERC20/ERC20.sol)
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
/**
 * @title Crowdsale
 * @dev Crowdsale is a base contract for managing a token crowdsale,
 * allowing investors to purchase tokens with ether. This contract implements
 * such functionality in its most fundamental form and can be extended to provide additional
 * functionality and/or custom behavior.
 * The external interface represents the basic interface for purchasing tokens, and conform
 * the base architecture for crowdsales. They are *not* intended to be modified / overriden.
 * The internal interface conforms the extensible and modifiable surface of crowdsales. Override
 * the methods to add functionality. Consider using 'super' where appropiate to concatenate
 * behavior.
 */
contract Crowdsale  {


  // The token being sold
  ERC20 public token;

  // Address where funds are collected
  address payable public wallet;

  // How many token units a buyer gets per wei
  uint256 public rate;

  // Amount of wei raised
  uint256 public weiRaised;

  /**
   * Event for token purchase logging
   * @param purchaser who paid for the tokens
   * @param beneficiary who got the tokens
   * @param value weis paid for purchase
   * @param amount amount of tokens purchased
   */
  event TokenPurchase(
    address indexed purchaser,
    address indexed beneficiary,
    uint256 value,
    uint256 amount
  );

  /**
   * @param _rate Number of token units a buyer gets per wei
   * @param _wallet Address where collected funds will be forwarded to
   * @param _token Address of the token being sold
   */
  constructor(uint256 _rate, address payable _wallet, ERC20 _token)  {
    require(_rate > 0);
    require(_wallet != address(0));
    //require(_token != address(0));

    rate = _rate;
    wallet = _wallet;
    token = _token;
  }

  // -----------------------------------------
  // Internal interface (extensible)
  // -----------------------------------------

  /**
   * @dev Validation of an incoming purchase. Use require statements to revert state when conditions are not met. Use super to concatenate validations.
   * @param _beneficiary Address performing the token purchase
   * @param _weiAmount Value in wei involved in the purchase
   */
  function _preValidatePurchase(
    address _beneficiary,
    uint256 _weiAmount
  )
   pure internal
  {
    require(_beneficiary != address(0));
    require(_weiAmount != 0);
  }

  /**
   * @dev Validation of an executed purchase. Observe state and use revert statements to undo rollback when valid conditions are not met.
   * @param _beneficiary Address performing the token purchase
   * @param _weiAmount Value in wei involved in the purchase
   */
  function _postValidatePurchase(
    address _beneficiary,
    uint256 _weiAmount
  )
    internal
  {
    // optional override
  }

  /**
   * @dev Source of tokens. Override this method to modify the way in which the crowdsale ultimately gets and sends its tokens.
   * @param _beneficiary Address performing the token purchase
   * @param _tokenAmount Number of tokens to be emitted
   */
  function _deliverTokens(
    address _beneficiary,
    uint256 _tokenAmount
  )
    internal
  {
    token.transfer(_beneficiary, _tokenAmount);
  }

  /**
   * @dev Executed when a purchase has been validated and is ready to be executed. Not necessarily emits/sends tokens.
   * @param _beneficiary Address receiving the tokens
   * @param _tokenAmount Number of tokens to be purchased
   */
  function _processPurchase(
    address _beneficiary,
    uint256 _tokenAmount
  )
    internal
  {
    _deliverTokens(_beneficiary, _tokenAmount);
  }

  /**
   * @dev Override for extensions that require an internal state to check for validity (current user contributions, etc.)
   * @param _beneficiary Address receiving the tokens
   * @param _weiAmount Value in wei involved in the purchase
   */
  function _updatePurchasingState(
    address _beneficiary,
    uint256 _weiAmount
  )
    internal
  {
    // optional override
  }

  /**
   * @dev Override to extend the way in which ether is converted to tokens.
   * @param _weiAmount Value in wei to be converted into tokens
   * @return Number of tokens that can be purchased with the specified _weiAmount
   */
  function _getTokenAmount(uint256 _weiAmount)
    internal view returns (uint256)
  {
    return (_weiAmount * rate) / (10 ** 9);  // polfex have 9 decimals
  }


  function _forwardFunds() internal {
     (bool sent, ) = wallet.call{value: msg.value}("");
     require(sent, "Error sending BNBs");   
  }

} 
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
        _nonReentrantBefore();
        _;
        _nonReentrantAfter();
    }

    function _nonReentrantBefore() private {
        // On the first call to nonReentrant, _status will be _NOT_ENTERED
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;
    }

    function _nonReentrantAfter() private {
        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Returns true if the reentrancy guard is currently set to "entered", which indicates there is a
     * `nonReentrant` function in the call stack.
     */
    function _reentrancyGuardEntered() internal view returns (bool) {
        return _status == _ENTERED;
    }
}

interface TokenInterface {

    function decimals() external view  returns(uint8);
    function balanceOf(address _address) external view returns(uint256);
    function transfer(address _to, uint256 _value) external returns (bool success);

}

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * The initial owner is set to the address provided by the deployer. This can
 * later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    /**
     * @dev The caller account is not authorized to perform an operation.
     */
    error OwnableUnauthorizedAccount(address account);

    /**
     * @dev The owner is not a valid owner account. (eg. `address(0)`)
     */
    error OwnableInvalidOwner(address owner);

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the address provided by the deployer as the initial owner.
     */
    constructor(address initialOwner) {
        _transferOwnership(initialOwner);
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
        if (owner() != _msgSender()) {
            revert OwnableUnauthorizedAccount(_msgSender());
        }
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
        if (newOwner == address(0)) {
            revert OwnableInvalidOwner(address(0));
        }
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

// $$$$$$$\   $$$$$$\  $$\       $$$$$$$$\ $$$$$$$$\ $$\   $$\ 
// $$  __$$\ $$  __$$\ $$ |      $$  _____|$$  _____|$$ |  $$ |
// $$ |  $$ |$$ /  $$ |$$ |      $$ |      $$ |      \$$\ $$  |
// $$$$$$$  |$$ |  $$ |$$ |      $$$$$\    $$$$$\     \$$$$  / 
// $$  ____/ $$ |  $$ |$$ |      $$  __|   $$  __|    $$  $$<  
// $$ |      $$ |  $$ |$$ |      $$ |      $$ |      $$  /\$$\ 
// $$ |       $$$$$$  |$$$$$$$$\ $$ |      $$$$$$$$\ $$ /  $$ |
// \__|       \______/ \________|\__|      \________|\__|  \__|          
// https://www.polfex.io/
/// @author POLFEX
/// @notice Public Vesting of the PFX token 
/// @dev cainuriel@gmail.com
contract Vesting is Crowdsale, Ownable, ReentrancyGuard {

  bool public startReclaim;
  bool public openWhiteListed; 
  bool public useWhiteListed; 
  bool public saleIsActive;
  uint256 public vestingTime = 7802829;  // 90 days and seven hours
  uint256 public initialDate;
  uint256 public vestingOne;
  uint256 public vestingTwo;
  uint256 public vestingThree;
  uint256 public vestingFour;
  uint256 public totalReservedPolfex;
  uint256 public totalWhiteListedClients;
  uint256 public totalClients;
  mapping(address => uint256) public polfexPendingWithdrawal;
  mapping(address => bool) public whiteList;
  mapping(address => uint256) public investments; // total investments of client
  mapping(address => bool) public clients;
  mapping(address => uint256) public paidOut; // in BNBs
  mapping(address => uint256) public isclaimed; // pending claims
  mapping(address => uint256) private amounts;
  mapping(address => uint256) private amountTokens;

  TokenInterface TokenContract;

  uint constant MINIMUM_RESERVED = 0.1 ether; // bnbs
  uint constant MAXIMUM_RESERVED = 10 ether;  // bnbs
  uint constant ONE_QUARTER = 25;
  uint constant ONE_THIRD = 33;
  uint constant HALF = 50;
  uint constant THREE_QUARTERS = 75;

    /**
   * Event for token purchase logging
   * @param amount total sale balance
   * @param date collection date
   */
  event WithdrawBNB(
    uint256 amount,
    uint256 date
  );

      /**
   * Event for token claim tokens
   * @param amount of this vesting
    * @param amount of this vesting
    * @param owner who claimed
    * @param rest amount for will claim
   * @param date collection date
   */
  event ClaimedToken(
    uint256 amount,
    address owner,
    uint256 rest,
    uint256 date
  );

        /**
   * Event for token purchase logging
   * @param amount total sale balance
   * @param date collection date
   */
  event WithdrawPolfex(
    uint256 amount,
    uint256 date
  );

   /**
   * Event for reserved Polfex
   * @param amountBNB reserved in this transaction
   * @param amountTotal total  of bnbs reserved
   * @param client who reserved
   * @param date of this reserved transaction
   */
  event ReservedPolfex(
    uint256 amountBNB,
    uint256 amountTotal,
    address client,
    uint256 date
  );

  
  constructor  () Crowdsale(30000,  payable(0x6095210929E82ca795B3f6594a87a619d8C63900),ERC20(0x02d35B6698964d104E55bb21bEb157117F64B896))
                  Ownable(msg.sender)
  {

        TokenContract = TokenInterface(address(0x02d35B6698964d104E55bb21bEb157117F64B896)); 
        
  }

  function withDrawPolfexFromContract(uint _amount) external  onlyOwner()
  {
      uint256 balance = TokenContract.balanceOf(address(this));
      require(_amount <= balance, "Amount of withdrawal in excess of contract balance");
      require(TokenContract.transfer(owner(), _amount));
      emit WithdrawPolfex(_amount, block.timestamp);
  }

  function polfexBalanceInContract() external view returns (uint256)
  {
      return TokenContract.balanceOf(address(this));
  }

  function setRate(uint256 _newrate) public onlyOwner()
  {

      rate = _newrate;
  }

  function changeWallet(address payable _newWallet) external onlyOwner() 
  {
     wallet = _newWallet;
  }

   function registerINWahiteList(address _client) external
  {   
      require(saleIsActive, "The Polfex token reserve is not enable");
      require(openWhiteListed, "Whitelist is no open");
      require(!whiteList[_client], "This address is already registered in the whitelist");
      whiteList[_client] = true;
      totalWhiteListedClients++;
  }

    function reservation() public payable
  {
    require(saleIsActive, "The Polfex token reserve is not enable");
    if(useWhiteListed) require(whiteList[msg.sender], "You are not in WhiteList");
    require(!startReclaim, "The Polfex token claim is enabled.");
    require(msg.value >= MINIMUM_RESERVED, "The quantity is too small to reserve.");
    require((msg.value + paidOut[msg.sender]) <= MAXIMUM_RESERVED, "This amount exceeds the maximum of 10 BNBs per person.");
    clients[msg.sender] = true;
    totalClients++;
    investments[msg.sender] = investments[msg.sender] + msg.value;
    paidOut[msg.sender] = paidOut[msg.sender] + msg.value;
    polfexPendingWithdrawal[msg.sender] = polfexPendingWithdrawal[msg.sender] + (msg.value * rate) / (10 ** 9);
    isclaimed[msg.sender] = 4; // four vestings
    _forwardFunds();
    weiRaised = weiRaised + msg.value;
    totalReservedPolfex = totalReservedPolfex + (msg.value * rate) / (10 ** 9);
    emit ReservedPolfex(msg.value, paidOut[msg.sender], msg.sender, block.timestamp);
  }

  function activateClaim() public onlyOwner()
  {
        startReclaim = !startReclaim;
        initialDate = block.timestamp;
        vestingOne = initialDate;
        vestingTwo = initialDate + vestingTime;
        vestingThree = initialDate + (vestingTime * 2);
        vestingFour = initialDate + (vestingTime * 3);


  }

    function openOrCloseWhiteList() external onlyOwner()
  {
        openWhiteListed = !openWhiteListed;

  }

      function useWhiteList() external onlyOwner()
  {
        useWhiteListed = !useWhiteListed;

  }

  // amount to be withdrawn by the client at the next vesting
  function getReservedPolfexInNextVesting(address _client) public view returns (uint256)
  {
      uint percent = percentageByUser();
      if(percent == 100) return polfexPendingWithdrawal[_client];
      uint query = (polfexPendingWithdrawal[_client] * percent) / (10**2);
      return query;
  }

  function vestingPeriod() public view returns(uint256)
  { return timeVesting();
  }


  function timeVesting() internal view returns (uint256)
  {

      if(block.timestamp >= vestingFour) {
          return  vestingFour;
      } else if(block.timestamp >= vestingThree) {
          return  vestingThree;
      } else if(block.timestamp >= vestingTwo) {
          return  vestingTwo;
      } else if(block.timestamp >= vestingOne) {
          return  vestingOne;
      }

      return 0;

  }

    function getVestingNumber(uint _vestingTime) external view returns (uint256)
  {

      if(_vestingTime == vestingFour) {
          return  4;
      } else if(_vestingTime == vestingThree) {
          return  3;
      } else if(_vestingTime == vestingTwo) {
          return  2;
      } else if(_vestingTime >= vestingOne) {
          return  1;
      }

      return 0;

  }

   /**
   * @dev Depending on the claim period and the claims made by the user we return a percentage of withdrawal or another.
   */
    function percentageByUser() public view returns(uint256)
  { uint vesting = vestingPeriod();
    require(vesting != 0, "The token claiming period is not open yet.");
    if(vesting == vestingOne) {
            if(isclaimed[msg.sender] == 4) {
            return ONE_QUARTER;
            }
    }

    if(vesting == vestingTwo) {
            if(isclaimed[msg.sender] == 3) {
            return ONE_THIRD;
            } else if(isclaimed[msg.sender] == 4){
            return HALF;
            }
    }

    if(vesting == vestingThree) {
            if(isclaimed[msg.sender] == 2) {
            return HALF;
            } else if(isclaimed[msg.sender] == 3) {
            return ONE_THIRD;
            } else if(isclaimed[msg.sender] == 4){
            return THREE_QUARTERS;
            }
    }

    if(vesting == vestingFour) {
            if(isclaimed[msg.sender] != 0) {
            return 100; // 100%
            } else {
              return 0; // is finish the vesting
            }
    }

    return 0;


  }

    modifier hasClaimed {
      uint vesting = vestingPeriod();
       if(vesting == vestingOne) {
        require(isclaimed[msg.sender] == 4, "You have already claimed your Vesting. Wait for the next");
       }
       if(vesting == vestingTwo) {
        require(isclaimed[msg.sender] >= 3, "You have already claimed your Vesting. Wait for the next");
       }
       if(vesting == vestingThree) {
        require(isclaimed[msg.sender] >= 2, "You have already claimed your Vesting. Wait for the next");
       }
        if(vesting == vestingFour) {
        require(isclaimed[msg.sender] != 0, "You have already claimed all your tokens");
       }
      _;
   }

  function claimToken() public nonReentrant() hasClaimed
  { require(clients[msg.sender], "This account is not allowed to be claimed.");
    require(startReclaim, "The claim is not yet enabled.");
    require(isclaimed[msg.sender] != 0 , "You have nothing reserved or you have already claimed all your tokens.");

    uint256 vesting = timeVesting();

    if (vesting == 0) {

        revert("The vesting is not open. Check the time.");
    }

    uint256 tokens = getReservedPolfexInNextVesting(msg.sender);

    _processPurchase(msg.sender, tokens);

    polfexPendingWithdrawal[msg.sender] = polfexPendingWithdrawal[msg.sender] - tokens;
    totalReservedPolfex = totalReservedPolfex - tokens;

    if(vesting == vestingFour) {isclaimed[msg.sender] = 0;} else {isclaimed[msg.sender] = isclaimed[msg.sender] - 1;}

    emit ClaimedToken(tokens, msg.sender, polfexPendingWithdrawal[msg.sender],block.timestamp);

  }

   function flipSaleState() public onlyOwner 
    {
        saleIsActive = !saleIsActive;
    }

    receive ()  external payable
  {
    revert();
  }

}

