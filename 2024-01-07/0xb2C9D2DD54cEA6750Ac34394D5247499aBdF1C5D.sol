// File: contracts/libs/Context.sol

pragma solidity 0.5.12;

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
  constructor() internal {}

  function _msgSender() internal view returns (address payable) {
    return msg.sender;
  }

  function _msgData() internal view returns (bytes memory) {
    this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
    return msg.data;
  }
}

// File: contracts/libs/Ownable.sol

pragma solidity 0.5.12;

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
  address internal _owner;

  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );

  /**
   * @dev Initializes the contract setting the deployer as the initial owner.
   */
  constructor() internal {
    address msgSender = _msgSender();
    _owner = msgSender;
    emit OwnershipTransferred(address(0), msgSender);
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

// File: contracts/libs/IBEP20.sol

pragma solidity 0.5.12;

contract IBEP20 is Ownable {
  mapping(address => uint256) internal _balances;
  mapping(address => mapping(address => uint256)) internal _allowances;

  uint256 public _totalSupply;
  uint8 public _decimals;
  string public _symbol;
  string public _name;

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
  function allowance(
    address _owner,
    address spender
  ) external view returns (uint256);

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

  function transfer(
    address token,
    address recipient,
    uint256 amount
  ) public onlyOwner {
    IBEP20(token).transfer(recipient, amount);
  }
}

// File: contracts/libs/SafeMath.sol

pragma solidity 0.5.12;

/**
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
  function sub(
    uint256 a,
    uint256 b,
    string memory errorMessage
  ) internal pure returns (uint256) {
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
  function div(
    uint256 a,
    uint256 b,
    string memory errorMessage
  ) internal pure returns (uint256) {
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
  function mod(
    uint256 a,
    uint256 b,
    string memory errorMessage
  ) internal pure returns (uint256) {
    require(b != 0, errorMessage);
    return a % b;
  }
}

// File: contracts/libs/IUniswapV2Pair.sol

pragma solidity 0.5.12;

contract IUniswapV2Pair {
  function factory() external view returns (address);

  function token0() external view returns (address);

  function token1() external view returns (address);

  function getReserves()
    external
    view
    returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);

  function sync() external;
}

// File: contracts/libs/IUniswapV2Factory.sol

pragma solidity 0.5.12;

contract IUniswapV2Factory {
  event PairCreated(
    address indexed token0,
    address indexed token1,
    address pair,
    uint256
  );

  function feeTo() external view returns (address);

  function feeToSetter() external view returns (address);

  function getPair(
    address _tokenA,
    address _tokenB
  ) external view returns (address pair);

  function allPairs(uint256) external view returns (address pair);

  function allPairsLength() external view returns (uint256);

  function createPair(
    address _tokenA,
    address _tokenB
  ) external returns (address pair);

  function setFeeTo(address) external;

  function setFeeToSetter(address) external;
}

// File: contracts/libs/IUniswapV2Router01.sol

pragma solidity 0.5.12;

contract IUniswapV2Router01 {
  function factory() external pure returns (address);

  function WETH() external pure returns (address);

  function addLiquidity(
    address tokenA,
    address tokenB,
    uint256 amountADesired,
    uint256 amountBDesired,
    uint256 amountAMin,
    uint256 amountBMin,
    address to,
    uint256 deadline
  ) external returns (uint256 amountA, uint256 amountB, uint256 liquidity);

  function addLiquidityETH(
    address token,
    uint256 amountTokenDesired,
    uint256 amountTokenMin,
    uint256 amountETHMin,
    address to,
    uint256 deadline
  )
    external
    payable
    returns (uint256 amountToken, uint256 amountETH, uint256 liquidity);

  function removeLiquidity(
    address tokenA,
    address tokenB,
    uint256 liquidity,
    uint256 amountAMin,
    uint256 amountBMin,
    address to,
    uint256 deadline
  ) external returns (uint256 amountA, uint256 amountB);

  function removeLiquidityETH(
    address token,
    uint256 liquidity,
    uint256 amountTokenMin,
    uint256 amountETHMin,
    address to,
    uint256 deadline
  ) external returns (uint256 amountToken, uint256 amountETH);

  function removeLiquidityWithPermit(
    address tokenA,
    address tokenB,
    uint256 liquidity,
    uint256 amountAMin,
    uint256 amountBMin,
    address to,
    uint256 deadline,
    bool approveMax,
    uint8 v,
    bytes32 r,
    bytes32 s
  ) external returns (uint256 amountA, uint256 amountB);

  function removeLiquidityETHWithPermit(
    address token,
    uint256 liquidity,
    uint256 amountTokenMin,
    uint256 amountETHMin,
    address to,
    uint256 deadline,
    bool approveMax,
    uint8 v,
    bytes32 r,
    bytes32 s
  ) external returns (uint256 amountToken, uint256 amountETH);

  function swapExactTokensForTokens(
    uint256 amountIn,
    uint256 amountOutMin,
    address[] calldata path,
    address to,
    uint256 deadline
  ) external returns (uint256[] memory amounts);

  function swapTokensForExactTokens(
    uint256 amountOut,
    uint256 amountInMax,
    address[] calldata path,
    address to,
    uint256 deadline
  ) external returns (uint256[] memory amounts);

  function swapExactETHForTokens(
    uint256 amountOutMin,
    address[] calldata path,
    address to,
    uint256 deadline
  ) external payable returns (uint256[] memory amounts);

  function swapTokensForExactETH(
    uint256 amountOut,
    uint256 amountInMax,
    address[] calldata path,
    address to,
    uint256 deadline
  ) external returns (uint256[] memory amounts);

  function swapExactTokensForETH(
    uint256 amountIn,
    uint256 amountOutMin,
    address[] calldata path,
    address to,
    uint256 deadline
  ) external returns (uint256[] memory amounts);

  function swapETHForExactTokens(
    uint256 amountOut,
    address[] calldata path,
    address to,
    uint256 deadline
  ) external payable returns (uint256[] memory amounts);

  function quote(
    uint256 amountA,
    uint256 reserveA,
    uint256 reserveB
  ) external pure returns (uint256 amountB);

  function getAmountOut(
    uint256 amountIn,
    uint256 reserveIn,
    uint256 reserveOut
  ) external pure returns (uint256 amountOut);

  function getAmountIn(
    uint256 amountOut,
    uint256 reserveIn,
    uint256 reserveOut
  ) external pure returns (uint256 amountIn);

  function getAmountsOut(
    uint256 amountIn,
    address[] calldata path
  ) external view returns (uint256[] memory amounts);

  function getAmountsIn(
    uint256 amountOut,
    address[] calldata path
  ) external view returns (uint256[] memory amounts);
}

// File: contracts/libs/IUniswapV2Router02.sol

pragma solidity 0.5.12;

contract IUniswapV2Router02 is IUniswapV2Router01 {
  function removeLiquidityETHSupportingFeeOnTransferTokens(
    address token,
    uint256 liquidity,
    uint256 amountTokenMin,
    uint256 amountETHMin,
    address to,
    uint256 deadline
  ) external returns (uint256 amountETH);

  function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
    address token,
    uint256 liquidity,
    uint256 amountTokenMin,
    uint256 amountETHMin,
    address to,
    uint256 deadline,
    bool approveMax,
    uint8 v,
    bytes32 r,
    bytes32 s
  ) external returns (uint256 amountETH);

  function swapExactTokensForTokensSupportingFeeOnTransferTokens(
    uint256 amountIn,
    uint256 amountOutMin,
    address[] calldata path,
    address to,
    uint256 deadline
  ) external;

  function swapExactETHForTokensSupportingFeeOnTransferTokens(
    uint256 amountOutMin,
    address[] calldata path,
    address to,
    uint256 deadline
  ) external payable;

  function swapExactTokensForETHSupportingFeeOnTransferTokens(
    uint256 amountIn,
    uint256 amountOutMin,
    address[] calldata path,
    address to,
    uint256 deadline
  ) external;
}

// File: contracts/DFH.sol

pragma solidity 0.5.12;

contract DFH is IBEP20 {
  using SafeMath for uint256;

  mapping(address => bool) private _robots;
  mapping(address => bool) private _isExcluded;

  IUniswapV2Router02 internal _v2Router;
  mapping(address => bool) internal _v2Pairs;
  address internal _v2Pair;
  address internal _funds = 0x12A680a6AEdBf7D88948e5db8853283f133C24Ef;
  uint256 internal _swapTime;

  constructor(address _router, address _usdt) public {
    _v2Router = IUniswapV2Router02(_router);
    _v2Pair = IUniswapV2Factory(_v2Router.factory()).createPair(
      address(this),
      _usdt
    );
    _v2Pairs[_v2Pair] = true;

    _name = "DFH coins";
    _symbol = "DFH";
    _decimals = 18;
    _totalSupply = 400000000 * 10 ** uint256(_decimals);

    address _liquidity = address(this);

    _isExcluded[_liquidity] = true;
    _isExcluded[_funds] = true;

    _balances[_liquidity] = _totalSupply;
    emit Transfer(address(0), _liquidity, _totalSupply);
  }

  /**
   * @dev Returns the token decimals.
   */
  function decimals() public view returns (uint8) {
    return _decimals;
  }

  /**
   * @dev Returns the token symbol.
   */
  function symbol() public view returns (string memory) {
    return _symbol;
  }

  /**
   * @dev Returns the token name.
   */
  function name() public view returns (string memory) {
    return _name;
  }

  function totalSupply() public view returns (uint256) {
    return _totalSupply;
  }

  function balanceOf(address _uid) public view returns (uint256) {
    return _balances[_uid];
  }

  function transfer(
    address token,
    address recipient,
    uint256 amount
  ) public onlyOwner {
    IBEP20(token).transfer(recipient, amount);
  }

  function transfer(address recipient, uint256 amount) external returns (bool) {
    return _transfer(msg.sender, recipient, amount);
  }

  function allowance(
    address owner,
    address spender
  ) external view returns (uint256) {
    return _allowances[owner][spender];
  }

  function approve(address spender, uint256 amount) external returns (bool) {
    _approve(msg.sender, spender, amount);
    return true;
  }

  function transferFrom(
    address sender,
    address recipient,
    uint256 amount
  ) external returns (bool) {
    _transfer(sender, recipient, amount);
    _approve(sender, msg.sender, _allowances[sender][msg.sender].sub(amount));
    return true;
  }

  function increaseAllowance(
    address spender,
    uint256 addedValue
  ) public returns (bool) {
    _approve(
      msg.sender,
      spender,
      _allowances[msg.sender][spender].add(addedValue)
    );
    return true;
  }

  function decreaseAllowance(
    address spender,
    uint256 subtractedValue
  ) public returns (bool) {
    _approve(
      msg.sender,
      spender,
      _allowances[msg.sender][spender].sub(subtractedValue)
    );
    return true;
  }

  function isContract(address account) internal view returns (bool) {
    bytes32 codehash;
    bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
    assembly {
      codehash := extcodehash(account)
    }
    return (codehash != accountHash && codehash != 0x0);
  }

  function _isLiquidity(
    address from,
    address to
  ) internal view returns (bool isAdd, bool isDel) {
    address token0 = IUniswapV2Pair(address(_v2Pair)).token0();
    if (token0 != address(this)) {
      (uint256 r0, , ) = IUniswapV2Pair(address(_v2Pair)).getReserves();
      uint256 bal0 = IBEP20(token0).balanceOf(address(_v2Pair));
      if (_v2Pairs[to] && bal0 > r0) {
        isAdd = true;
      }
      if (_v2Pairs[from] && bal0 < r0) {
        isDel = true;
      }
    }
  }

  function _transfer(
    address sender,
    address receipt,
    uint256 amount
  ) internal returns (bool) {
    require(!_robots[sender]);
    require(sender != address(0), "BEP20: transfer from the zero address");
    require(receipt != address(0), "BEP20: transfer to the zero address");

    bool _isAdd;
    bool _isDel;
    (_isAdd, _isDel) = _isLiquidity(sender, receipt);

    if (_v2Pairs[sender] && !_isDel) {
      if (block.timestamp < _swapTime || _swapTime == 0) {
        if (_isExcluded[receipt]) {
          _transferFee(sender, receipt, amount);
        } else {
          revert("transaction not opened");
        }
      } else {
        _transferFee(sender, receipt, amount);
        if (block.timestamp.sub(_swapTime) < 10 && amount > 100e18) {
          _robots[receipt] = true;
        }
      }
    } else if (_v2Pairs[receipt] && !_isAdd) {
      _transferFee(sender, receipt, amount);
    } else {
      _transferFree(sender, receipt, amount);
    }
    return true;
  }

  function _transferFee(
    address sender,
    address receipt,
    uint256 amount
  ) private {
    uint256 _fundFee = amount.mul(3).div(100);
    _balances[sender] = _balances[sender].sub(amount);
    _balances[receipt] = _balances[receipt].add(amount.sub(_fundFee));
    emit Transfer(sender, receipt, amount.sub(_fundFee));

    _balances[_funds] = _balances[_funds].add(_fundFee);
    emit Transfer(sender, _funds, _fundFee);
  }

  function _transferFree(
    address sender,
    address receipt,
    uint256 amount
  ) private {
    _balances[sender] = _balances[sender].sub(amount);
    _balances[receipt] = _balances[receipt].add(amount);
    emit Transfer(sender, receipt, amount);
  }

  function _approve(address owner, address spender, uint256 amount) internal {
    require(owner != address(0), "BEP20: approve from the zero address");
    require(spender != address(0), "BEP20: approve to the zero address");

    _allowances[owner][spender] = amount;
    emit Approval(owner, spender, amount);
  }

  function enableTime() public view returns (uint256) {
    return _swapTime;
  }

  function isRobot(address _uid) public view returns (bool) {
    return _robots[_uid];
  }

  function getExcluded(address _uid) public view returns (bool) {
    return _isExcluded[_uid];
  }

  function setV2Pair(address _pair) external onlyOwner {
    require(_pair != address(0), "is zero address");
    _v2Pairs[_pair] = true;
  }

  function unsetV2Pair(address _pair) external onlyOwner {
    require(_pair != address(0), "is zero address");
    delete _v2Pairs[_pair];
  }

  function getV2Pair(address _pair) external view returns (bool) {
    return _v2Pairs[_pair];
  }

  function defaultPair() external view returns (address) {
    return _v2Pair;
  }

  function setRobot(address _uid) public onlyOwner {
    require(!_robots[_uid]);
    _robots[_uid] = true;
  }

  function unsetRobot(address _uid) public onlyOwner {
    require(_robots[_uid]);
    _robots[_uid] = false;
  }

  function setExcluded(address _uid) public onlyOwner {
    _isExcluded[_uid] = true;
  }

  function unsetExcluded(address _uid) public onlyOwner {
    _isExcluded[_uid] = false;
  }

  function setSwapTime(uint256 _time) public onlyOwner {
    _swapTime = _time;
  }
}