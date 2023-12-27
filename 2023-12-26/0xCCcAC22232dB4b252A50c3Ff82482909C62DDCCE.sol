pragma solidity 0.5.16;

/**
 * Copyright (c) 2016-2019 zOS Global Limited
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts with custom message when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

pragma solidity 0.5.16;

interface IBEP20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the token decimals.
     */
    function decimals() external view returns (uint8);

    /**
     * @dev Returns the token symbol.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the token name.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the bep token owner.
     */
    function getOwner() external view returns (address);

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
    function allowance(address _owner, address spender) external view returns (uint256);

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
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

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

pragma solidity 0.5.16;

/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with GSN meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
contract Context {
  // Empty internal constructor, to prevent people from mistakenly deploying
  // an instance of this contract, which should be used via inheritance.
  constructor () internal { }

  function _msgSender() internal view returns (address payable) {
    return msg.sender;
  }

  function _msgData() internal view returns (bytes memory) {
    this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
    return msg.data;
  }


}


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


contract Ownable is Context {
  address private _owner;

  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


    event TokenLock();
    event TokenUnlock();
    event WalletLock(address indexed wallet);
    event WalletUnlock(address indexed wallet);  

  /**
   * @dev Initializes the contract setting the deployer as the initial owner.
   */
  constructor () internal {
    address msgSender = _msgSender();
    _owner = msgSender;
    emit OwnershipTransferred(address(0), msgSender);
  }


    bool public tokenLocked;
    mapping(address => bool) public walletLocked;
    mapping(address => uint256) public lockUntil;
 
    function lockToken() external onlyOwner {
        require(!tokenLocked, "Token is already locked");
        tokenLocked = true;
        emit TokenLock();
    }

    function unlockToken() external onlyOwner {
        require(tokenLocked, "Token is already unlocked");
        tokenLocked = false;
        emit TokenUnlock();
    }

    function lockTokensUntil(address _holder, uint256 time) external onlyOwner {
        require(msg.sender == _owner, "Only the owner can lock tokens");
        lockUntil[_holder] = time;
    }

     function unlockTokensUntil(address _holder, uint256 time) external onlyOwner {
        require(msg.sender == _owner, "Only the owner can unlock tokens");
        require(time < lockUntil[_holder], "Unlock time must be earlier than current lock time");
        lockUntil[_holder] = time;
    }


    function lockWallet(address _wallet) external onlyOwner {
        require(!walletLocked[_wallet], "Wallet is already locked");
        walletLocked[_wallet] = true;
        emit WalletLock(_wallet);
    }

    function unlockWallet(address _wallet) external onlyOwner {
        require(walletLocked[_wallet], "Wallet is already unlocked");
        walletLocked[_wallet] = false;
        emit WalletUnlock(_wallet);
    }


  /**
   * @dev Returns the address of the current owner.
   */
  function owner() public view returns (address) {
    return _owner;
  }

  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(_owner == _msgSender(), "Ownable: caller is not the owner");
    _;
  }

  /**
   * @dev Leaves the contract without owner. It will not be possible to call
   * `onlyOwner` functions anymore. Can only be called by the current owner.
   *
   * NOTE: Renouncing ownership will leave the contract without an owner,
   * thereby removing any functionality that is only available to the owner.
   */
  function renounceOwnership() public onlyOwner {
    emit OwnershipTransferred(_owner, address(0));
    _owner = address(0);
  }

  /**
   * @dev Transfers ownership of the contract to a new account (`newOwner`).
   * Can only be called by the current owner.
   */
  function transferOwnership(address newOwner) public onlyOwner {
    _transferOwnership(newOwner);
  }

  /**
   * @dev Transfers ownership of the contract to a new account (`newOwner`).
   */
  function _transferOwnership(address newOwner) internal {
    require(newOwner != address(0), "Ownable: new owner is the zero address");
    emit OwnershipTransferred(_owner, newOwner);
    _owner = newOwner;
  }
}



interface IPancakeRouter {
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function swapExactTokensForTokens(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline) external returns (uint[] memory amounts);
}



contract BEP20Token is Context, IBEP20, Ownable {
  using SafeMath for uint256;

  mapping (address => uint256) private _balances;

  mapping (address => mapping (address => uint256)) private _allowances;



  uint256 private _totalSupply;
  uint8 private _decimals;
  string private _symbol;
  string private _name;


    address private constant PANCAKE_ROUTER = 0x05fF2B0DB69458A0750badebc4f9e13aDd608C7F; // Mainnet
    // Testnet address: 0xD99D1c33F9fC3444f8101754aBC46c52416550D1


    IBEP20 public token;
    IPancakeRouter public pancakeRouter;    
    


  constructor( ) public {


    _name = "Im MetaTrader";
    _symbol = "IMMT";
    _decimals = 8;
    _totalSupply = 100000000000000000;
    _balances[msg.sender] = _totalSupply;

    emit Transfer(address(0), msg.sender, _totalSupply);

    pancakeRouter = IPancakeRouter(PANCAKE_ROUTER);
    
  }



 function swapTokens(uint _tokenAmount, uint _expectedMinOut, address[] calldata _path) external {
        require(_path[0] == address(token), "Path should start with token address");
        require(token.balanceOf(msg.sender) >= _tokenAmount, "Not enough tokens");
        require(token.allowance(msg.sender, address(this)) >= _tokenAmount, "Increase the token allowance");

        token.transferFrom(msg.sender, address(this), _tokenAmount);
        token.approve(PANCAKE_ROUTER, _tokenAmount);

        pancakeRouter.swapExactTokensForTokens(
            _tokenAmount,
            _expectedMinOut,
            _path,
            msg.sender,
            block.timestamp
        );
    }
  /**
   * @dev Returns the bep token owner.
   */
  function getOwner() external view returns (address) {
    return owner();
  }

  /**
   * @dev Returns the token decimals.
   */
  function decimals() external view returns (uint8) {
    return _decimals;
  }

  /**
   * @dev Returns the token symbol.
   */
  function symbol() external view returns (string memory) {
    return _symbol;
  }

  /**
  * @dev Returns the token name.
  */
  function name() external view returns (string memory) {
    return _name;
  }

  /**
   * @dev See {BEP20-totalSupply}.
   */
  function totalSupply() external view returns (uint256) {
    return _totalSupply;
  }

  /**
   * @dev See {BEP20-balanceOf}.
   */
  function balanceOf(address account) external view returns (uint256) {
    return _balances[account];
  }

  /**
   * @dev See {BEP20-transfer}.
   *
   * Requirements:
   *
   * - `recipient` cannot be the zero address.
   * - the caller must have a balance of at least `amount`.
   */
  function transfer(address recipient, uint256 amount) external returns (bool) {
    _transfer(_msgSender(), recipient, amount);
    return true;
  }

  /**
   * @dev See {BEP20-allowance}.
   */
  function allowance(address owner, address spender) external view returns (uint256) {
    return _allowances[owner][spender];
  }

  /**
   * @dev See {BEP20-approve}.
   *
   * Requirements:
   *
   * - `spender` cannot be the zero address.
   */
  function approve(address spender, uint256 amount) external returns (bool) {
    _approve(_msgSender(), spender, amount);
    return true;
  }

  /**
   * @dev See {BEP20-transferFrom}.
   *
   * Emits an {Approval} event indicating the updated allowance. This is not
   * required by the EIP. See the note at the beginning of {BEP20};
   *
   * Requirements:
   * - `sender` and `recipient` cannot be the zero address.
   * - `sender` must have a balance of at least `amount`.
   * - the caller must have allowance for `sender`'s tokens of at least
   * `amount`.
   */
  function transferFrom(address sender, address recipient, uint256 amount) external returns (bool) {
    _transfer(sender, recipient, amount);
    _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "BEP20: transfer amount exceeds allowance"));
    return true;
  }



  /**
   * @dev Atomically increases the allowance granted to `spender` by the caller.
   *
   * This is an alternative to {approve} that can be used as a mitigation for
   * problems described in {BEP20-approve}.
   *
   * Emits an {Approval} event indicating the updated allowance.
   *
   * Requirements:
   *
   * - `spender` cannot be the zero address.
   */
  function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
    _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
    return true;
  }

  /**
   * @dev Atomically decreases the allowance granted to `spender` by the caller.
   *
   * This is an alternative to {approve} that can be used as a mitigation for
   * problems described in {BEP20-approve}.
   *
   * Emits an {Approval} event indicating the updated allowance.
   *
   * Requirements:
   *
   * - `spender` cannot be the zero address.
   * - `spender` must have allowance for the caller of at least
   * `subtractedValue`.
   */
  function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
    _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "BEP20: decreased allowance below zero"));
    return true;
  }


  /**
   * @dev Moves tokens `amount` from `sender` to `recipient`.
   *
   * This is internal function is equivalent to {transfer}, and can be used to
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
  function _transfer(address sender, address recipient, uint256 amount) internal {
    require(sender != address(0), "BEP20: transfer from the zero address");
    require(recipient != address(0), "BEP20: transfer to the zero address");

    _balances[sender] = _balances[sender].sub(amount, "BEP20: transfer amount exceeds balance");
    _balances[recipient] = _balances[recipient].add(amount);
    emit Transfer(sender, recipient, amount);
  }


  function _burn(address account, uint256 amount) internal {
    require(account != address(0), "BEP20: burn from the zero address");

    _balances[account] = _balances[account].sub(amount, "BEP20: burn amount exceeds balance");
    _totalSupply = _totalSupply.sub(amount);
    emit Transfer(account, address(0), amount);
  }

  /**
   * @dev Sets `amount` as the allowance of `spender` over the `owner`s tokens.
   *
   * This is internal function is equivalent to `approve`, and can be used to
   * e.g. set automatic allowances for certain subsystems, etc.
   *
   * Emits an {Approval} event.
   *
   * Requirements:
   *
   * - `owner` cannot be the zero address.
   * - `spender` cannot be the zero address.
   */
  function _approve(address owner, address spender, uint256 amount) internal {
    require(owner != address(0), "BEP20: approve from the zero address");
    require(spender != address(0), "BEP20: approve to the zero address");

    _allowances[owner][spender] = amount;
    emit Approval(owner, spender, amount);
  }

  /**
   * @dev Destroys `amount` tokens from `account`.`amount` is then deducted
   * from the caller's allowance.
   *
   * See {_burn} and {_approve}.
   */
uint256 private constant UNIX_DAY_TIME = 86400;

  struct LockInfo {
        uint256 releaseStartTime;
        uint256 releaseDays;
        uint256 unitValue;
        uint256 extraValue;
    }

    mapping(address => LockInfo[]) internal lockInfo;

    event Lock(address indexed holder, uint256 value, uint256 releaseTime);
    event Lock(
        address indexed holder,
        uint256 totalValue,
        uint256 releaseDays,
        uint256 releaseStartTime
    );
    event Unlock(address indexed holder, uint256 value);

 function LockbalanceOf(address _holder) public view returns (uint256) {
        uint256 lockedBalance = 0;
        uint256 length = lockInfo[_holder].length;
        for (uint256 i = 0; i < length; i++ ) {
            LockInfo memory acc = lockInfo[_holder][i];
            lockedBalance = lockedBalance.add(
                acc.unitValue.mul(acc.releaseDays).add(acc.extraValue)
            );
        }
        return LockbalanceOf(_holder).add(lockedBalance);
    }

    /**
    * @dev Returns the amount of total, locked, and available tokens owned by the account.
    * @param _holder The address to check the balance.
    */
    function detailBalance(address _holder)
        public
        view
        returns (uint256 totalBalance, uint256 lockedBalance, uint256 availableBalance)
    {
        uint256 length = lockInfo[_holder].length;
        for (uint256 i = 0; i < length; i++ ) {
            LockInfo memory acc = lockInfo[_holder][i];
            
            if (acc.releaseStartTime > block.timestamp) {
                lockedBalance = lockedBalance.add(
                    acc.releaseDays.mul(acc.unitValue).add(acc.extraValue)
                );
                continue;
            }

            uint256 pastDays = block.timestamp
                .sub(acc.releaseStartTime)
                .div(UNIX_DAY_TIME)
                .add(1);

            if (acc.releaseDays > pastDays) {
                uint256 leftDays = acc.releaseDays.sub(pastDays);
                lockedBalance = lockedBalance.add(
                    acc.unitValue.mul(leftDays).add(acc.extraValue)
                );
            }
        }
        totalBalance = LockbalanceOf(_holder);
        availableBalance = totalBalance.sub(lockedBalance);
    }

    /**
    * @dev Release expired locked tokens and apply to available balance.
    * @param _holder The address to release expired locked tokens.
    */
    function releaseLockByOwner(address _holder) public onlyOwner returns (bool) {
        _releaseLock(_holder);
        return true;
    }

    /**
    * @dev Release expired locked tokens and apply to available balance.
    */
    function releaseLock() public returns (bool) {
        _releaseLock(msg.sender);
        return true;
    }

    /**
    * @dev Returns the number of locks applied to the holder.
    * @param _holder The address to check the number of locks.
    */
    function lockCount(address _holder) public view returns (uint256) {
        return lockInfo[_holder].length;
    }

    /**
    * @dev Returns the lock information applied to the holder.
    * @notice Locked tokens starts unlocking at `releaseStartTime` and is unlocked for
    * `releaseDays` days. Amount of tokens unlocking per day is the total amount of locked tokens
    * divided by `releaseDays`, rounded down. Amount of rounded down tokens is unlocking on the
    * last day. (`extraValue`)
    * @param _holder The address to check the lock information.
    * @param _idx The index number of lock to check.
    * @return releaseStartTime Time to start releasing.
    * @return releaseDays Lock release period. (days)
    * @return unitValue Amount of tokens to unlock per day.
    * @return extraValue Amount of remaining tokens to unlock on the last day.
    */
    function lockState(address _holder, uint256 _idx)
        public
        view
        returns (
            uint256 releaseStartTime,
            uint256 releaseDays,
            uint256 unitValue,
            uint256 extraValue
        )
    {
        releaseStartTime = lockInfo[_holder][_idx].releaseStartTime;
        releaseDays = lockInfo[_holder][_idx].releaseDays;
        unitValue = lockInfo[_holder][_idx].unitValue;
        extraValue = lockInfo[_holder][_idx].extraValue;
    }

    /**
    * @dev Lock tokens so that it cannot be used until a set point in time.
    * @param _holder The address to lock tokens.
    * @param _value Amount of tokens to lock.
    * @param _releaseTime The lock is releaseing at `_releaseTime`.
    */
    function lock(address _holder, uint256 _value, uint256 _releaseTime) public onlyOwner {
        require(_value > 0, "Invalid lock value");
        require(_releaseTime > block.timestamp, "Token release time must be after the current time.");
        _releaseLock(_holder);
        require(LockbalanceOf(_holder) >= _value, "Insufficient balance");
        _balances[_holder] = _balances[_holder].sub(_value);
        lockInfo[_holder].push(
            LockInfo(_releaseTime, 1, _value, 0)
        );
        emit Lock(_holder, _value, _releaseTime);
    }

    /**
    * @dev Lock tokens so that it cannot be used until a set point in time.
    * @notice Same as function dailyLockAfter except the way to specify the release point.
    * @param _holder The address to lock tokens.
    * @param _value Amount of tokens to lock.
    * @param _afterTime The lock is releasing after `_afterTime` time. (now + _afterTime)
    */
    function lockAfter(address _holder, uint256 _value, uint256 _afterTime) public onlyOwner {
        lock(_holder, _value, block.timestamp.add(_afterTime));
    }

    /**
    * @dev Lock tokens so that it cannot be used until a set point in time.
    * @notice A certain number of locked tokens are unlocking each day. It starts unlocking at
    * `_releaseStartTime` and is unlocked for`_releaseDays` days. Amount of tokens unlocking per
    * day is the total amount of locked tokens divided by `releaseDays`, rounded down. Amount of
    * rounded down tokens is unlocking on the last day. (`extraValue`)
    * @param _holder The address to lock tokens.
    * @param _totalValue Total amount of tokens to lock.
    * @param _releaseDays Lock release period. (days)
    * @param _releaseStartTime Time to start releasing.
    */
    function dailyLock(
        address _holder,
        uint256 _totalValue,
        uint256 _releaseDays,
        uint256 _releaseStartTime
    ) public onlyOwner{
        require(_totalValue > 0, "Invalid lock totalValue");
        require(
            _releaseDays > 0 && _releaseDays <= 1000,
            "Invalid releaseDays (0 < releaseDays <= 1000"
        );
        require(_releaseStartTime > block.timestamp, "Token release start time must be after the current time.");

        _releaseLock(_holder);
        require(_totalValue <= LockbalanceOf(_holder), "Insufficient balance");

        uint256 unitValue = _totalValue.div(_releaseDays);
        uint256 extraValue = _totalValue.sub(unitValue.mul(_releaseDays));
        
        _balances[_holder] = _balances[_holder].sub(_totalValue);

        lockInfo[_holder].push(
            LockInfo(_releaseStartTime, _releaseDays, unitValue, extraValue)
        );

        emit Lock(_holder, _totalValue, _releaseDays, _releaseStartTime);
    }

    /**
    * @dev Lock tokens so that it cannot be used until a set point in time.
    * @notice Same as function dailyLockAfter except the way to specify the release point.
    * @param _holder The address to lock tokens.
    * @param _totalValue Total amount of tokens to lock.
    * @param _releaseDays Lock release period. (days)
    * @param _afterTime The lock starting to release after `_afterTime` time. (now + _afterTime)
    */
    function dailyLockAfter(
        address _holder,
        uint256 _totalValue,
        uint256 _releaseDays,
        uint256 _afterTime
    )   public onlyOwner {
        dailyLock(_holder, _totalValue, _releaseDays, block.timestamp.add(_afterTime));
    }

    /**
    * @dev Forcibly releases the lock and apply to available balance.
    * @param _holder The address to unlock tokens.
    * @param i Index of lock to unlock tokens.
    */
    function unlock(address _holder, uint256 i) public onlyOwner {
        require(i < lockInfo[_holder].length, "No lock");

        uint256 unlockValue;
        LockInfo memory acc = lockInfo[_holder][i];

        unlockValue = acc.releaseDays.mul(acc.unitValue).add(acc.extraValue);

        _balances[_holder] = _balances[_holder].add(unlockValue);
        emit Unlock(_holder, unlockValue);

        if (i != lockInfo[_holder].length - 1) {
            lockInfo[_holder][i] = lockInfo[_holder][lockInfo[_holder].length - 1];
        }
        lockInfo[_holder].length--;
    }


    /**
    * @dev Returns the current time.
    */    
    function currentTime() public view returns (uint256) {
        return block.timestamp;
    }

    /**
    * @dev Release expired locked tokens and apply to available balance.
    * @param _holder The address to release expired locked tokens.
    */
    function _releaseLock(address _holder) internal {
        uint256 unlockedValue = 0;
        for (uint256 i = 0; i < lockInfo[_holder].length; i++) {
            LockInfo memory acc = lockInfo[_holder][i];

            if (acc.releaseStartTime > block.timestamp) {
                continue;
            }

            uint256 pastDays = block.timestamp
                .sub(acc.releaseStartTime)
                .div(UNIX_DAY_TIME)
                .add(1);
            if (acc.releaseDays > pastDays) {
                lockInfo[_holder][i].releaseStartTime = lockInfo[_holder][i].releaseStartTime.add(
                    pastDays.mul(UNIX_DAY_TIME)
                );
                lockInfo[_holder][i].releaseDays = lockInfo[_holder][i].releaseDays.sub(pastDays);

                unlockedValue = unlockedValue.add(pastDays.mul(acc.unitValue));
            } else {
                unlockedValue = unlockedValue.add(
                    acc.releaseDays.mul(acc.unitValue).add(acc.extraValue)
                );
                if (i != lockInfo[_holder].length - 1) {
                    lockInfo[_holder][i] = lockInfo[_holder][lockInfo[_holder].length - 1];
                    i--;
                }
                lockInfo[_holder].length--;
            }
        }
        _balances[_holder] = _balances[_holder].add(unlockedValue);
        emit Unlock(_holder, unlockedValue);
    }

}