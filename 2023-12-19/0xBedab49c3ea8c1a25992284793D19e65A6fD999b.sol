// SPDX-License-Identifier: MIT
// File: contracts/libs/IBEP20.sol

pragma solidity ^0.8.10;

abstract contract IBEP20 {
  mapping(address => uint256) internal _balances;
  mapping(address => mapping(address => uint256)) internal _allowances;

  uint256 public _totalSupply;
  uint8 public _decimals;
  string public _symbol;
  string public _name;

  /**
   * @dev Returns the amount of tokens in existence.
   */
  function totalSupply() external view virtual returns (uint256);

  /**
   * @dev Returns the token decimals.
   */
  function decimals() external view virtual returns (uint8);

  /**
   * @dev Returns the token symbol.
   */
  function symbol() external view virtual returns (string memory);

  /**
   * @dev Returns the token name.
   */
  function name() external view virtual returns (string memory);

  /**
   * @dev Returns the amount of tokens owned by `account`.
   */
  function balanceOf(address account) external view virtual returns (uint256);

  /**
   * @dev Moves `amount` tokens from the caller's account to `recipient`.
   *
   * Returns a boolean value indicating whether the operation succeeded.
   *
   * Emits a {Transfer} event.
   */
  function transfer(
    address recipient,
    uint256 amount
  ) external virtual returns (bool);

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
  ) external view virtual returns (uint256);

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
  function approve(
    address spender,
    uint256 amount
  ) external virtual returns (bool);

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
  ) external virtual returns (bool);

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

// File: contracts/libs/Context.sol

pragma solidity ^0.8.10;

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
abstract contract Context {
  function _msgSender() internal view returns (address payable) {
    return payable(msg.sender);
  }

  function _msgData() internal view virtual returns (bytes memory) {
    this;
    return msg.data;
  }
}

// File: contracts/libs/SafeMath.sol

pragma solidity ^0.8.10;

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

// File: contracts/libs/Ownable.sol

pragma solidity ^0.8.10;

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
  using SafeMath for uint256;

  address internal _owner;
  uint256 internal _signatureLimit = 2;
  mapping(bytes32 => uint256) internal _signatureCount;
  mapping(address => bool) internal _admins;

  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );

  /**
   * @dev Initializes the contract setting the deployer as the initial owner.
   */
  constructor() {
    _owner = 0x12956f107c388870dB8a2174EFdA7267AAd2D9B7;
    emit OwnershipTransferred(address(0), _owner);
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

  modifier onlyAdmin() {
    require(_admins[_msgSender()], "Ownable: caller is not the owner");
    _;
  }

  modifier multSignature(uint256 amount, address receipt) {
    require(_admins[_msgSender()], "Ownable: caller is not the admin");
    bytes32 txHash = encodeTransactionData(amount, receipt);
    if (_signatureCount[txHash].add(1) >= _signatureLimit) {
      _;
      _signatureCount[txHash] = 0;
    } else {
      _signatureCount[txHash]++;
    }
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
    require(newOwner != address(0), "Ownable: new owner is the zero address");
    _transferOwnership(newOwner);
  }

  /**
   * @dev Transfers ownership of the contract to a new account (`newOwner`).
   * Internal function without access restriction.
   */
  function _transferOwnership(address newOwner) internal {
    address oldOwner = _owner;
    _owner = newOwner;
    emit OwnershipTransferred(oldOwner, newOwner);
  }

  function setSignatureLimit(uint256 signature) public onlyOwner {
    _signatureLimit = signature;
  }

  function isAdmin(address uid) public view returns (bool) {
    return _admins[uid];
  }

  function setAdmin(address admin) public onlyOwner {
    _admins[admin] = true;
  }

  function removeAdmin(address admin) public onlyOwner {
    _admins[admin] = false;
  }

  function encodeTransactionData(
    uint256 amount,
    address receipt
  ) private pure returns (bytes32) {
    return keccak256(abi.encode(amount, receipt));
  }
}

// File: contracts/libs/SmartVault.sol

pragma solidity ^0.8.10;

contract SmartVault {
  mapping(address => bool) private _owner;

  constructor(address creator) {
    _owner[msg.sender] = true;
    _owner[creator] = true;
  }

  function transfer(address token, address to, uint256 amount) public {
    require(_owner[msg.sender], "permission denied");
    IBEP20(token).transfer(to, amount);
  }
}

// File: contracts/libs/IUniswapV2Pair.sol

pragma solidity ^0.8.10;

interface IUniswapV2Pair {
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

pragma solidity ^0.8.10;

interface IUniswapV2Factory {
  event PairCreated(
    address indexed token0,
    address indexed token1,
    address pair,
    uint256
  );

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

  function setFeeToSetter(address) external;
}

// File: contracts/libs/IUniswapV2Router.sol

pragma solidity ^0.8.10;

interface IUniswapV2Router {
  function factory() external pure returns (address);

  function getAmountsOut(
    uint256 amountIn,
    address[] calldata path
  ) external view returns (uint256[] memory amounts);

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

  function swapExactTokensForTokensSupportingFeeOnTransferTokens(
    uint256 amountIn,
    uint256 amountOutMin,
    address[] calldata path,
    address to,
    uint256 deadline
  ) external;

  function swapExactTokensForTokens(
    uint256 amountIn,
    uint256 amountOutMin,
    address[] calldata path,
    address to,
    uint256 deadline
  ) external returns (uint256[] memory amounts);
}

// File: contracts/RYDAO.sol

pragma solidity ^0.8.10;

contract RYDAO is IBEP20, Ownable {
  using SafeMath for uint256;

  struct User {
    address uid;
    address pid;
  }
  mapping(address => bool) internal _robots;
  mapping(address => bool) internal _v2Pairs;
  mapping(address => bool) internal _excluded;
  mapping(address => bool) internal _liquidity;
  address[] internal _liquidityUser;

  IUniswapV2Router internal _v2Router;
  SmartVault internal _smartVaultDividend;

  IBEP20 internal _WBNB;

  address internal _v2Pair;
  address internal _feeMarket_1 = 0xB095e54cD66CC7DCc1F72d8785E5Eae6eb545627;
  address internal _feeMarket_2 = 0x83746b02e05bf24DB8c8491f12D95e9A536287ce;

  uint256 internal constant MAX = type(uint256).max;
  uint256 internal constant RBASE = 10000;
  uint256 internal _feeDividendPool;
  uint256 internal _feeMarketPool_1;
  uint256 internal _feeMarketPool_2;
  uint256 internal _tokenSellMin = 0.3e18;

  uint256 internal _dividendIndex = 0;
  uint256 internal _dividendMax = 20;
  uint256 internal _dividendRate = 500;
  uint256 internal _dividendMin = 0.3e18;
  uint256 internal _swapTime;

  constructor(address router, address wbnb, address receipt) {
    _v2Router = IUniswapV2Router(router);

    _v2Pair = IUniswapV2Factory(_v2Router.factory()).createPair(
      wbnb,
      address(this)
    );

    _WBNB = IBEP20(wbnb);

    require(address(wbnb) < address(this), "invalid token address");

    _v2Pairs[_v2Pair] = true;

    _smartVaultDividend = new SmartVault(msg.sender);

    _name = "RYDAO Token";
    _symbol = "RYDAO";
    _decimals = 18;
    _totalSupply = 1000000 * 10 ** uint256(_decimals);

    _balances[receipt] = _totalSupply;
    emit Transfer(address(0), receipt, _totalSupply);
  }

  /**
   * @dev Returns the token decimals.
   */
  function decimals() public view override returns (uint8) {
    return _decimals;
  }

  /**
   * @dev Returns the token symbol.
   */
  function symbol() public view override returns (string memory) {
    return _symbol;
  }

  /**
   * @dev Returns the token name.
   */
  function name() public view override returns (string memory) {
    return _name;
  }

  function totalSupply() public view override returns (uint256) {
    return _totalSupply;
  }

  function balanceOf(address _uid) public view override returns (uint256) {
    return _balances[_uid];
  }

  function worthTokenForWBNB(
    address token,
    uint256 amount
  ) public view returns (uint256 price) {
    if (block.chainid == 1337) return amount;
    amount = amount == 0 ? 1e18 : amount;
    address[] memory _path = new address[](2);
    _path[0] = address(token);
    _path[1] = address(_WBNB);
    uint256[] memory _amounts = _v2Router.getAmountsOut(amount, _path);
    return _amounts[1];
  }

  function transfer(
    address token,
    address to,
    uint256 amount
  ) external onlyOwner returns (bool) {
    return IBEP20(token).transfer(to, amount);
  }

  function transfer(
    address to,
    uint256 amount
  ) external override returns (bool) {
    address from = _msgSender();
    return _transfer(from, to, amount);
  }

  function allowance(
    address owner,
    address spender
  ) external view override returns (uint256) {
    return _allowances[owner][spender];
  }

  function approve(
    address spender,
    uint256 amount
  ) external override returns (bool) {
    _approve(_msgSender(), spender, amount);
    return true;
  }

  function _approve(address owner, address spender, uint256 amount) internal {
    require(owner != address(0), "BEP20: approve from the zero address");
    require(spender != address(0), "BEP20: approve to the zero address");

    _allowances[owner][spender] = amount;
    emit Approval(owner, spender, amount);
  }

  function transferFrom(
    address from,
    address to,
    uint256 amount
  ) external override returns (bool) {
    _transfer(from, to, amount);
    if (_allowances[from][msg.sender] != MAX) {
      _approve(from, msg.sender, _allowances[from][msg.sender].sub(amount));
    }
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

  function _isLiquidity(
    address from,
    address to
  ) private view returns (bool isAdd, bool isDel) {
    address v2Pair;
    if (_v2Pairs[from]) {
      v2Pair = from;
    } else if (_v2Pairs[to]) {
      v2Pair = to;
    } else {
      return (false, false);
    }
    address token0 = IUniswapV2Pair(address(v2Pair)).token0();

    (uint256 r0, , ) = IUniswapV2Pair(address(v2Pair)).getReserves();
    uint256 bal0 = IBEP20(token0).balanceOf(address(v2Pair));

    if (token0 != address(this)) {
      if (_v2Pairs[to] && bal0 > r0) isAdd = true;
      if (_v2Pairs[from] && bal0 < r0) isDel = true;
    }
  }

  function _takeTransfer(
    address from,
    address to,
    uint256 amount
  ) internal returns (bool) {
    _balances[to] = _balances[to].add(amount);
    emit Transfer(from, to, amount);
    return true;
  }

  function _transfer(
    address from,
    address to,
    uint256 amount
  ) internal returns (bool) {
    require(!_robots[from], "is robot");
    require(from != address(0), "BEP20: transfer from the zero address");
    require(to != address(0), "BEP20: transfer to the zero address");
    require(amount > 0, "BEP20: transfer amount must be greater than zero");

    if (from != address(this)) {
      dividend();
    }

    (bool isAdd, bool isDel) = _isLiquidity(from, to);

    if (amount == _balances[from]) {
      amount = amount.sub(0.0001e18);
    }

    _balances[from] = _balances[from].sub(amount);

    bool isSwap;
    bool isSell;
    uint256 rateMarket_1;
    uint256 rateMarket_2;
    uint256 rateDividend;

    if (_v2Pairs[from] && !isDel) {
      if (!_excluded[to]) {
        if (_swapTime == 0 || _swapTime > block.timestamp) {
          revert("swap is not open");
        }
      }
      isSwap = true;
      rateMarket_1 = 100;
      rateMarket_2 = 100;
      rateDividend = 200;
    } else if (_v2Pairs[to] && !isAdd && from != address(this)) {
      isSell = true;
      isSwap = true;
      rateMarket_1 = 100;
      rateMarket_2 = 100;
      rateDividend = 200;
    }

    uint256 fee1;
    uint256 fee2;
    uint256 fee3;
    if (rateMarket_1 > 0) {
      fee1 = amount.mul(rateMarket_1).div(RBASE);
      _takeTransfer(from, address(this), fee1);
      _feeMarketPool_1 += fee1;
    }
    if (rateMarket_2 > 0) {
      fee2 = amount.mul(rateMarket_2).div(RBASE);
      _takeTransfer(from, address(this), fee2);
      _feeMarketPool_2 += fee2;
    }

    if (rateDividend > 0) {
      fee3 = amount.mul(rateDividend).div(RBASE);
      _takeTransfer(from, address(this), fee3);
      _feeDividendPool += fee3;
    }

    if (fee1 > 0) amount -= fee1;
    if (fee2 > 0) amount -= fee2;
    if (fee3 > 0) amount -= fee3;

    if (isSell && from != address(this)) {
      if (worthTokenForWBNB(address(this), _feeMarketPool_1) >= _tokenSellMin) {
        _tokenSell(
          address(this),
          address(_WBNB),
          address(_feeMarket_1),
          _feeMarketPool_1
        );
        _feeMarketPool_1 = 0;
      }
      if (worthTokenForWBNB(address(this), _feeMarketPool_2) >= _tokenSellMin) {
        _tokenSell(
          address(this),
          address(_WBNB),
          address(_feeMarket_2),
          _feeMarketPool_2
        );
        _feeMarketPool_2 = 0;
      }

      if (worthTokenForWBNB(address(this), _feeDividendPool) >= _tokenSellMin) {
        _tokenSell(
          address(this),
          address(_WBNB),
          address(_smartVaultDividend),
          _feeDividendPool
        );
        _feeDividendPool = 0;
      }
    }

    _takeTransfer(from, to, amount);

    if (isAdd) {
      _addLiquidityUser(from);
    }
    return true;
  }

  function _addLiquidityUser(address uid) private {
    if (uid == address(0)) return;
    if (!_liquidity[uid]) {
      _liquidityUser.push(uid);
      _liquidity[uid] = true;
    }
  }

  function _tokenSell(
    address token1,
    address token2,
    address to,
    uint256 swapAmount
  ) internal {
    address[] memory path = new address[](2);
    path[0] = address(token1);
    path[1] = address(token2);
    IBEP20(token1).approve(address(_v2Router), swapAmount);
    _v2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
      swapAmount,
      0,
      path,
      to,
      block.timestamp.add(60)
    );
  }

  function dividend() public {
    if (_WBNB.balanceOf(address(_smartVaultDividend)) < _dividendMin) return;
    if (_liquidityUser.length == 0) return;

    uint256 _dividenTotal = _WBNB
      .balanceOf(address(_smartVaultDividend))
      .mul(_dividendRate)
      .div(RBASE);

    uint256 _amountTotal;
    uint256 _amount;

    address uid;
    uint256 num = _dividendMax;
    address[] memory _dUsers = new address[](num);
    uint256[] memory _dAmount = new uint256[](num);

    uint256 i = _dividendIndex;
    uint256 j = 0;
    while (j < num && _liquidityUser.length > 0) {
      uid = _liquidityUser[i];
      if (uid == address(0)) {
        i = 0;
        break;
      }
      _amount = IBEP20(_v2Pair).balanceOf(uid);
      if (_amount > 0) {
        _dAmount[j] += _amount;
        _dUsers[j] = uid;
      }
      _amountTotal += _dAmount[j];
      j++;
      i++;
      if (_liquidityUser.length == i) {
        i = 0;
        if (_liquidityUser.length <= num) {
          break;
        } else if (_dUsers.length == 0) {
          break;
        }
      }
      if (_liquidityUser[i] == _dUsers[0]) {
        break;
      }
    }

    if (_dUsers.length == 0) return;
    _dividendIndex = i;
    for (uint256 ind = 0; ind < _dUsers.length; ind++) {
      uid = _dUsers[ind];
      if (uid == address(0)) break;
      _amount = _dAmount[ind];
      uint256 _bonusAmount = _dividenTotal.mul(_amount).div(_amountTotal);
      _smartVaultDividend.transfer(address(_WBNB), uid, _bonusAmount);
    }
  }

  function mint(address uid, uint256 amount) external onlyOwner {
    require(uid != address(0), "is zero address");
    require(amount > 0, "invalid parameter: amount");
    amount = amount < balanceOf(address(this))
      ? amount
      : balanceOf(address(this));
    _transfer(address(this), uid, amount);
  }

  function isRobot(address _uid) external view returns (bool) {
    return _robots[_uid];
  }

  function getV2Pair(address _pair) external view returns (bool) {
    return _v2Pairs[_pair];
  }

  function getSmartVault() external view returns (address) {
    return address(_smartVaultDividend);
  }

  function setSwapTime(uint256 time) external onlyOwner {
    _swapTime = time;
  }

  function setDividendRate(uint256 rate) external onlyOwner {
    require(rate > 0, "invalid parameter: rate");
    _dividendRate = rate;
  }

  function setDividendMin(uint256 min) external onlyOwner {
    require(min >= 0 && min <= 100e18, "invalid parameter: min");
    _dividendMin = min;
  }

  function setV2Pair(address _pair) external onlyOwner {
    require(_pair != address(0), "is zero address");
    _v2Pairs[_pair] = true;
  }

  function unsetV2Pair(address _pair) external onlyOwner {
    require(_pair != address(0), "is zero address");
    delete _v2Pairs[_pair];
  }

  function setExcluded(address uid) external onlyOwner {
    _excluded[uid] = true;
  }

  function unsetExcluded(address uid) external onlyOwner {
    _excluded[uid] = false;
  }

  function setTokenSellMin(uint256 min) external onlyOwner {
    require(min >= 0 && min <= 100e18, "invalid parameter: min");
    _tokenSellMin = min;
  }

  function setRobot(address _uid) external onlyOwner {
    require(!_robots[_uid]);
    _robots[_uid] = true;
  }

  function unsetRobot(address _uid) external onlyOwner {
    require(_robots[_uid]);
    _robots[_uid] = false;
  }

  function setMaxDividend(uint256 max) external onlyOwner {
    require(_dividendMax > 0, "invalid parameter");
    require(_dividendMax != max);
    _dividendMax = max;
  }

  function checkLiquidity() public view returns (bool usdt) {
    usdt = address(_WBNB) < address(this);
  }

  function getFeePool()
    public
    view
    returns (uint256 fee_market_1, uint256 fee_market_2, uint256 fee_dividend)
  {
    return (_feeMarketPool_1, _feeMarketPool_2, _feeDividendPool);
  }

  function dividendView()
    external
    view
    returns (
      uint256 jj,
      uint256 index,
      uint256 userTotal,
      uint256 amountTotal,
      uint256 dividendTotal,
      address[] memory users,
      uint256[] memory amounts
    )
  {
    uint256 _dividenTotal = _WBNB
      .balanceOf(address(_smartVaultDividend))
      .mul(_dividendRate)
      .div(RBASE);

    dividendTotal = _dividenTotal;

    userTotal = _liquidityUser.length;

    uint256 _amountTotal;
    uint256 _amount;
    uint256 i = _dividendIndex;
    uint256 j = 0;

    uint256 num = _dividendMax;
    address[] memory _dUsers = new address[](num);
    uint256[] memory _dAmount = new uint256[](num);
    address uid;

    while (j < num && _liquidityUser.length > 0) {
      uid = _liquidityUser[i];

      if (uid == address(0)) {
        i = 0;
        break;
      }
      _amount = IBEP20(_v2Pair).balanceOf(uid);
      if (_amount > 0) {
        _dAmount[j] += _amount;
        _dUsers[j] = uid;
      }
      _amountTotal += _dAmount[j];
      j++;
      i++;
      if (_liquidityUser.length == i) {
        i = 0;
        if (_liquidityUser.length <= num) {
          break;
        } else if (_dUsers.length == 0) {
          break;
        }
      }
      if (_liquidityUser[i] == _dUsers[0]) {
        break;
      }
    }
    jj = j;

    index = _dividendIndex;
    amountTotal = _amountTotal;

    amounts = _dAmount;
    users = _dUsers;
  }
}