// SPDX-License-Identifier: MIT
// File: contracts/libs/IBEP20.sol

pragma solidity ^0.8.10;

abstract contract IBEP20 {
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

// File: contracts/libs/I4M.sol

pragma solidity ^0.8.10;

abstract contract I4M {
  function isUser(address uid) external virtual returns (bool);

  function isActiveUser(address uid) external virtual returns (bool);
}

// File: contracts/libs/SafeMath.sol

pragma solidity ^0.8.10;

library SafeMath {
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    require(c >= a, "SafeMath: addition overflow");

    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b <= a, "SafeMath: subtraction overflow");
    uint256 c = a - b;
    return c;
  }

  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    require(c / a == b, "SafeMath: multiplication overflow");

    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b > 0, "SafeMath: division by zero");
    uint256 c = a / b;
    return c;
  }

  function mod(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b != 0, "SafeMath: modulo by zero");
    return a % b;
  }
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

  /**
   * @dev Initializes the contract setting the deployer as the initial owner.
   */
  constructor() {
    _owner = _msgSender();
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
   * @dev Transfers ownership of the contract to a new account (`newOwner`).
   * Can only be called by the current owner.
   */
  function transferOwnership(address newOwner) public onlyOwner {
    _owner = newOwner;
  }
}

// File: contracts/libs/ICakePool.sol

pragma solidity ^0.8.10;

abstract contract ICakePool {
  function balanceOf(address account) external view virtual returns (uint256);

  function mint(uint256 mintAmount) external virtual returns (uint256);

  function redeem(uint256 redeemTokens) external virtual returns (uint256);

  function redeemUnderlying(
    uint256 redeemAmount
  ) external virtual returns (uint256);
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
    amount = amount == 0 ? IBEP20(token).balanceOf(address(this)) : amount;
    IBEP20(token).transfer(to, amount);
  }
}

// File: contracts/Minter.sol

pragma solidity ^0.8.10;

abstract contract IROCK is IBEP20 {
  function burn(uint256 amount) external virtual;
}

contract Minter is Ownable {
  using SafeMath for uint256;

  struct SwapPrice {
    uint256 price; // 价格
    uint256 time; // 时间
  }

  struct Ladder {
    uint256 min; // 最小天数
    uint256 max; // 最大天数
    uint256 num; // 产出总量
  }

  struct User {
    address uid; // 用户地址
    uint256 level; // 挖矿等级
    uint256 mintTotal; // 挖矿总量
    uint256 mintTime; // 挖矿时间
    uint256 buyNum; // 购买数量
    uint256 sellNum; // 出售数量
  }

  struct Order {
    uint256 key;
    address uid;
    uint256 amount;
    uint256 price;
    uint256 time;
    bool isBuy;
  }

  SwapPrice[] internal _swapPrice;

  ICakePool internal _vUSDT;
  IBEP20 internal _USDT;
  IBEP20 internal _USDM;
  IROCK internal _ROCK;
  I4M internal _MMMM;

  Ladder[] internal _ladders;

  SmartVault internal _smartMint;
  SmartVault internal _smartSwap;

  mapping(address => User) internal _minters;
  mapping(uint256 => uint256) internal _levelNum;
  mapping(uint256 => uint256) internal _mintNum;
  mapping(uint256 => uint256) internal _indexMintNum;
  mapping(uint256 => mapping(uint256 => uint256)) internal _indexLevelNum;
  mapping(address => Order[]) internal _orders;
  mapping(uint256 => uint256) internal _levelRate;

  uint256 internal RBASE = 10000;
  uint256 internal _rock_price = 1e18;
  uint256 internal _swap_fee = 2000;
  uint256 internal _year = 0;
  uint256 internal _mintTotal = 0;
  uint256 internal _buyTotal = 0;
  uint256 internal _sellTotal = 0;
  uint256 internal _freedNum;
  uint256 internal _cycle = 1 days;

  uint256 internal _startTime;
  uint256 internal _time;

  constructor(address usdt, address rock, address swap, uint256 time) {
    _USDT = IBEP20(usdt);
    _ROCK = IROCK(rock);
    _vUSDT = ICakePool(swap);
    _time = time;

    _ladders.push(Ladder(0, 365 * _cycle, 1995e18));
    _ladders.push(Ladder(365 * _cycle, 730 * _cycle, 2992.5e18));
    _ladders.push(Ladder(730 * _cycle, 1095 * _cycle, 3990e18));
    _ladders.push(Ladder(1095 * _cycle, 1460 * _cycle, 4987.5e18));
    _ladders.push(Ladder(1460 * _cycle, 1825 * _cycle, 5985e18));

    _levelRate[1] = 3000;
    _levelRate[2] = 3000;
    _levelRate[3] = 4000;

    _smartMint = new SmartVault(msg.sender);
    _smartSwap = new SmartVault(msg.sender);

    setRockPrice(1e18);
  }

  function updateTime() public {
    uint256 time = _time;
    if (time.add(_cycle) > block.timestamp) return;
    do {
      time = time.add(_cycle);
    } while (time.add(_cycle) < block.timestamp);
    _time = time;

    _indexLevelNum[_time][1] = _levelNum[1];
    _indexLevelNum[_time][2] = _levelNum[2];
    _indexLevelNum[_time][3] = _levelNum[3];
    _indexMintNum[_time] = _getPerDay();

    if (_startTime == 0 || block.timestamp < _startTime) return;
    if (_ROCK.balanceOf(address(this)) >= 10.5e18) {
      _ROCK.transfer(address(_smartSwap), 10.5e18);
      _freedNum += 10.5e18;
    }
  }

  function transfer(
    address token,
    address recipient,
    uint256 amount
  ) public onlyOwner {
    IBEP20(token).transfer(recipient, amount);
  }

  function sell(uint256 amount) external {
    updateTime();
    address uid = msg.sender;
    require(amount > 0, "invalid amount");

    _ROCK.transferFrom(uid, address(this), amount);
    _ROCK.burn(amount);

    uint256 usdtValue = amount.mul(_rock_price).div(1e18);
    uint256 fee = usdtValue.mul(_swap_fee).div(RBASE);
    uint256 usdtAmount = usdtValue.sub(fee);

    if (_minters[uid].uid == address(0)) {
      _minters[uid] = User(uid, 0, 0, 0, 0, 0);
      _levelNum[0]++;
    }

    _sellTotal += amount;
    _minters[uid].sellNum += amount;

    _withdraw(uid, usdtAmount);

    _orders[uid].push(
      Order(
        _orders[uid].length,
        uid,
        amount,
        _rock_price,
        block.timestamp,
        false
      )
    );
  }

  function buy(uint256 amount) external {
    updateTime();
    address uid = msg.sender;
    require(amount > 0, "invalid amount");
    require(_MMMM.isActiveUser(uid), "invalid user");

    uint256 usdtValue = amount.mul(_rock_price).div(1e18);
    _USDT.transferFrom(uid, address(this), usdtValue);

    _smartSwap.transfer(address(_ROCK), uid, amount);

    if (_minters[uid].uid == address(0)) {
      _minters[uid] = User(uid, 0, 0, 0, 0, 0);
      _levelNum[0]++;
    }

    _buyTotal += amount;
    _minters[uid].buyNum += amount;

    if (block.chainid != 1337) {
      _deposit();
    }
    _orders[uid].push(
      Order(
        _orders[uid].length,
        uid,
        amount,
        _rock_price,
        block.timestamp,
        true
      )
    );
  }

  function _deposit() private {
    uint256 amount = _USDT.balanceOf(address(this));
    _USDT.approve(address(_vUSDT), amount);
    _vUSDT.mint(amount);
  }

  function _withdraw(address uid, uint256 amount) private {
    if (block.chainid != 1337) {
      uint256 amount_1 = _USDT.balanceOf(address(this));
      _vUSDT.redeemUnderlying(amount);
      uint256 amount_2 = _USDT.balanceOf(address(this));
      amount = amount_2.sub(amount_1);
    }
    require(_USDT.transfer(uid, amount), "transfer fail");
  }

  function withdrawAll(address to) external onlyOwner {
    _vUSDT.redeem(_vUSDT.balanceOf(address(this)));
    _USDT.transfer(to, _USDT.balanceOf(address(this)));
  }

  function setRockPrice(uint256 price) public onlyOwner {
    require(price > 0, "invalid price");
    _rock_price = price;
    _swapPrice.push(SwapPrice(price, block.timestamp));
  }

  function setSwapFee(uint256 fee) external onlyOwner {
    require(fee >= 0 && fee <= 10000, "invalid fee");
    _swap_fee = fee;
  }

  function setMinter(address uid, uint256 level) external {
    require(msg.sender == address(_MMMM), "invalid sender");
    require(level >= 1 && level <= 3, "invalid level");

    _mint(uid, mintNum(uid));

    if (_minters[uid].uid == address(0)) {
      _minters[uid] = User(uid, level, 0, _time, 0, 0);
      _levelNum[level]++;
    } else {
      if (_minters[uid].level >= level) return;
      _levelNum[_minters[uid].level]--;
      _minters[uid].level = level;
      _levelNum[level]++;
    }
  }

  function mint() public {
    updateTime();
    uint256 num = mintNum(msg.sender);
    if (num > 0) {
      _mint(msg.sender, num);
    } else {
      _minters[msg.sender].mintTime = _time;
    }
  }

  function _mint(address uid, uint256 num) private {
    if (num > 0) {
      _smartMint.transfer(address(_ROCK), uid, num);
      _minters[uid].mintTotal += num;

      uint256 ladder = _getLadder();
      if (ladder != _year) {
        _year = ladder;
      }
      _mintNum[_year] += num;
      _mintTotal += num;
    }
    _minters[uid].mintTime = _time;
  }

  function mintNum(address uid) public view returns (uint256) {
    if (_startTime == 0) return 0;
    if (_startTime > block.timestamp) return 0;
    if (_minters[uid].uid == address(0)) return 0;
    if (_minters[uid].mintTime >= _time) return 0;
    if (_minters[uid].level == 0) return 0;
    uint256 num;
    uint256 levelNum;
    uint256 ind = 1;
    uint256 time = _minters[uid].mintTime.add(_cycle);
    time = time > _startTime ? time : _startTime;
    do {
      levelNum = _indexLevelNum[time][_minters[uid].level];
      if (levelNum > 0) {
        num += _indexMintNum[time]
          .mul(_levelRate[_minters[uid].level])
          .div(RBASE)
          .div(levelNum);
      }
      if (ind == 3) break;
      ind++;
      time += _cycle;
    } while (time <= _time);
    return num;
  }

  function _getPerDay() private view returns (uint256) {
    uint256 i = _getLadder();
    return _ladders[i].num.div(365);
  }

  function _getLadder() private view returns (uint256) {
    for (uint256 i = 0; i < _ladders.length; i++) {
      if (
        _ladders[i].min.add(_startTime) < block.timestamp &&
        _ladders[i].max.add(_startTime) >= block.timestamp
      ) {
        return i;
      }
    }
    return 0;
  }

  function getSmart()
    external
    view
    returns (address mintAddr, address swapAddr)
  {
    mintAddr = address(_smartMint);
    swapAddr = address(_smartSwap);
  }

  function getParams()
    public
    view
    returns (
      uint256 price,
      uint256 fee,
      uint256 startTime,
      uint256 time,
      uint256 year,
      uint256 buyTotal,
      uint256 sellTotal,
      uint256 mintLadder,
      uint256 mintCurrent,
      uint256 mintTotal,
      uint256 freedNum
    )
  {
    price = _rock_price;
    fee = _swap_fee;
    startTime = _startTime;
    time = _time;
    year = _year;
    buyTotal = _buyTotal;
    sellTotal = _sellTotal;
    mintLadder = _ladders[_getLadder()].num;
    mintCurrent = _mintNum[_year];
    mintTotal = _mintTotal;
    freedNum = _freedNum;
  }

  function setStartTime(uint256 startTime) external onlyOwner {
    require(startTime > 0, "invalid startTime");
    _startTime = startTime;
  }

  function set4M(address mmmm) external onlyOwner {
    require(address(mmmm) != address(0), "invalid address");
    _MMMM = I4M(mmmm);
  }

  function getMinter(address uid) external view returns (User memory) {
    return _minters[uid];
  }

  function getLevelNum()
    external
    view
    returns (uint256 l_1, uint256 l_2, uint256 l_3, uint256 m_1)
  {
    return (
      _indexLevelNum[_time][1],
      _indexLevelNum[_time][2],
      _indexLevelNum[_time][3],
      _indexMintNum[_time]
    );
  }

  function getPairBalance() external view returns (uint256 usdt, uint256 rock) {
    usdt = _USDT.balanceOf(address(this));
    if (block.chainid != 1337) {
      usdt += _vUSDT.balanceOf(address(this));
    }
    rock = _ROCK.balanceOf(address(_smartSwap));
  }

  function orderList(
    address uid,
    uint256 page,
    uint256 size
  ) external view returns (Order[] memory order, uint256 total) {
    total = _orders[uid].length;
    if (total == 0) return (order, total);
    page = page < 1 ? 1 : page;
    size = size > total ? total : size;

    uint256 end = total.sub(1).sub(page.sub(1).mul(size));
    uint256 start = end.sub(size.sub(1));

    order = new Order[](size);
    uint256 key;
    for (uint256 i = start; i <= end; i++) {
      order[key] = _orders[uid][end - key];
      key++;
    }
  }

  function rockPrice()
    external
    view
    returns (SwapPrice[] memory price, uint256 total)
  {
    uint256 page = 1;
    uint256 size = 10;

    total = _swapPrice.length;
    if (total == 0) return (price, total);
    page = page < 1 ? 1 : page;
    size = size > total ? total : size;

    uint256 end = total.sub(1).sub(page.sub(1).mul(size));
    uint256 start = end.sub(size.sub(1));

    price = new SwapPrice[](size);
    uint256 key;
    for (uint256 i = start; i <= end; i++) {
      price[key] = _swapPrice[end - key];
      key++;
    }
  }
}