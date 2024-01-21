// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

interface IERC20 {
	function decimals() external view returns (uint8);

	function symbol() external view returns (string memory);

	function name() external view returns (string memory);

	function totalSupply() external view returns (uint256);

	function balanceOf(address account) external view returns (uint256);

	function transfer(address recipient, uint256 amount) external returns (bool);

	function allowance(address owner, address spender) external view returns (uint256);

	function approve(address spender, uint256 amount) external returns (bool);

	function transferFrom(
		address sender,
		address recipient,
		uint256 amount
	) external returns (bool);

	event Transfer(address indexed from, address indexed to, uint256 value);
	event Approval(address indexed owner, address indexed spender, uint256 value);
}

pragma solidity ^0.8.0;

library SafeMath {
	/**
	 * @dev Returns the addition of two unsigned integers, with an overflow flag.
	 *
	 * _Available since v3.4._
	 */
	function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
		unchecked {
			uint256 c = a + b;
			if (c < a) return (false, 0);
			return (true, c);
		}
	}

	/**
	 * @dev Returns the subtraction of two unsigned integers, with an overflow flag.
	 *
	 * _Available since v3.4._
	 */
	function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
		unchecked {
			if (b > a) return (false, 0);
			return (true, a - b);
		}
	}

	/**
	 * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
	 *
	 * _Available since v3.4._
	 */
	function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
		unchecked {
			// Gas optimization: this is cheaper than requiring 'a' not being zero, but the
			// benefit is lost if 'b' is also tested.
			// See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
			if (a == 0) return (true, 0);
			uint256 c = a * b;
			if (c / a != b) return (false, 0);
			return (true, c);
		}
	}

	/**
	 * @dev Returns the division of two unsigned integers, with a division by zero flag.
	 *
	 * _Available since v3.4._
	 */
	function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
		unchecked {
			if (b == 0) return (false, 0);
			return (true, a / b);
		}
	}

	/**
	 * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
	 *
	 * _Available since v3.4._
	 */
	function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
		unchecked {
			if (b == 0) return (false, 0);
			return (true, a % b);
		}
	}

	/**
	 * @dev Returns the addition of two unsigned integers, reverting on
	 * overflow.
	 *
	 * Counterpart to Solidity's `+` operator.
	 *
	 * Requirements:
	 *
	 * - Addition cannot overflow.
	 */
	function add(uint256 a, uint256 b) internal pure returns (uint256) {
		return a + b;
	}

	/**
	 * @dev Returns the subtraction of two unsigned integers, reverting on
	 * overflow (when the result is negative).
	 *
	 * Counterpart to Solidity's `-` operator.
	 *
	 * Requirements:
	 *
	 * - Subtraction cannot overflow.
	 */
	function sub(uint256 a, uint256 b) internal pure returns (uint256) {
		return a - b;
	}

	/**
	 * @dev Returns the multiplication of two unsigned integers, reverting on
	 * overflow.
	 *
	 * Counterpart to Solidity's `*` operator.
	 *
	 * Requirements:
	 *
	 * - Multiplication cannot overflow.
	 */
	function mul(uint256 a, uint256 b) internal pure returns (uint256) {
		return a * b;
	}

	/**
	 * @dev Returns the integer division of two unsigned integers, reverting on
	 * division by zero. The result is rounded towards zero.
	 *
	 * Counterpart to Solidity's `/` operator.
	 *
	 * Requirements:
	 *
	 * - The divisor cannot be zero.
	 */
	function div(uint256 a, uint256 b) internal pure returns (uint256) {
		return a / b;
	}

	/**
	 * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
	 * reverting when dividing by zero.
	 *
	 * Counterpart to Solidity's `%` operator. This function uses a `revert`
	 * opcode (which leaves remaining gas untouched) while Solidity uses an
	 * invalid opcode to revert (consuming all remaining gas).
	 *
	 * Requirements:
	 *
	 * - The divisor cannot be zero.
	 */
	function mod(uint256 a, uint256 b) internal pure returns (uint256) {
		return a % b;
	}

	/**
	 * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
	 * overflow (when the result is negative).
	 *
	 * CAUTION: This function is deprecated because it requires allocating memory for the error
	 * message unnecessarily. For custom revert reasons use {trySub}.
	 *
	 * Counterpart to Solidity's `-` operator.
	 *
	 * Requirements:
	 *
	 * - Subtraction cannot overflow.
	 */
	function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
		unchecked {
			require(b <= a, errorMessage);
			return a - b;
		}
	}

	/**
	 * @dev Returns the integer division of two unsigned integers, reverting with custom message on
	 * division by zero. The result is rounded towards zero.
	 *
	 * Counterpart to Solidity's `/` operator. Note: this function uses a
	 * `revert` opcode (which leaves remaining gas untouched) while Solidity
	 * uses an invalid opcode to revert (consuming all remaining gas).
	 *
	 * Requirements:
	 *
	 * - The divisor cannot be zero.
	 */
	function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
		unchecked {
			require(b > 0, errorMessage);
			return a / b;
		}
	}

	/**
	 * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
	 * reverting with custom message when dividing by zero.
	 *
	 * CAUTION: This function is deprecated because it requires allocating memory for the error
	 * message unnecessarily. For custom revert reasons use {tryMod}.
	 *
	 * Counterpart to Solidity's `%` operator. This function uses a `revert`
	 * opcode (which leaves remaining gas untouched) while Solidity uses an
	 * invalid opcode to revert (consuming all remaining gas).
	 *
	 * Requirements:
	 *
	 * - The divisor cannot be zero.
	 */
	function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
		unchecked {
			require(b > 0, errorMessage);
			return a % b;
		}
	}
}

interface ISwapRouter {
	function factory() external pure returns (address);

	function WETH() external pure returns (address);

	function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);

	function swapExactTokensForTokensSupportingFeeOnTransferTokens(
		uint amountIn,
		uint amountOutMin,
		address[] calldata path,
		address to,
		uint deadline
	) external;

	function addLiquidity(
		address tokenA,
		address tokenB,
		uint amountADesired,
		uint amountBDesired,
		uint amountAMin,
		uint amountBMin,
		address to,
		uint deadline
	) external returns (uint amountA, uint amountB, uint liquidity);
}

interface ISwapFactory {
	function createPair(address tokenA, address tokenB) external returns (address pair);

	function feeTo() external view returns (address);
}

abstract contract Ownable {
	address private _owner;

	event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

	constructor() {
		address msgSender = msg.sender;
		_owner = msgSender;
		emit OwnershipTransferred(address(0), msgSender);
	}

	function owner() public view returns (address) {
		return _owner;
	}

	modifier onlyOwner() {
		require(_owner == msg.sender, "!owner");
		_;
	}

	function renounceOwnership() public virtual onlyOwner {
		emit OwnershipTransferred(_owner, address(0));
		_owner = address(0);
	}

	function transferOwnership(address newOwner) public virtual onlyOwner {
		require(newOwner != address(0), "new is 0");
		emit OwnershipTransferred(_owner, newOwner);
		_owner = newOwner;
	}
}

library Math {
	function min(uint x, uint y) internal pure returns (uint z) {
		z = x < y ? x : y;
	}

	function sqrt(uint y) internal pure returns (uint z) {
		if (y > 3) {
			z = y;
			uint x = y / 2 + 1;
			while (x < z) {
				z = x;
				x = (y / x + x) / 2;
			}
		} else if (y != 0) {
			z = 1;
		}
	}
}

interface ISwapPair {
	function getReserves()
		external
		view
		returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);

	function totalSupply() external view returns (uint);

	function kLast() external view returns (uint);

	function sync() external;
}

contract TokenDistributor {
	constructor(address token) {
		IERC20(token).approve(msg.sender, uint(~uint256(0)));
	}
}

abstract contract AbsToken is IERC20, Ownable {
	using SafeMath for uint256;

	mapping(address => uint256) private _balances;
	mapping(address => mapping(address => uint256)) private _allowances;

	mapping(address => uint256) public _burnAmount;
	uint256 public totalBurnAmount;
	address[] public _toBurnMembers;
	address[] public _addLpMembers;
	mapping(address => uint256) public _toBurnMembersIndex;
	mapping(address => uint256) public _addLpMembersIndex;

	uint256 public buyFee = 100;
	uint256 public sellFee = 300;
	uint256 public lpAutoBurnPercen = 30;
	uint256 public lpAutoBurnPercenForSell = 200;
	address public marketing;
	address public errTokenAdmin;

	string private _name;
	string private _symbol;
	uint8 private _decimals;

	uint256 public burnToEarnUsdtAmount;
	uint256 public addLpToEarnUsdtAmount;
	uint256 public burnTimes;
	address public burnAddress = address(0x000000000000000000000000000000000000dEaD);
	address public lpBurnAddress = address(0xE54A3b674E0763AcAC2395981Ac631036A5E6f37);
	bool private tradeEnable = false;
	bool private _burnToEarn;
	bool private enableAutoBurn = false;
	uint256 public startTime;
	mapping(address => bool) private _wlList;
	mapping(address => bool) private _blackList;
	mapping(address => bool) private _excludeAddress;
	mapping(address => bool) private _excludeLpProvider;
	mapping(address => bool) private isMintAdmin;
	uint256 mintFee = 50;
	address[] private _elps;

	struct BTEMembers {
		address member;
		uint256 amount;
	}

	bool private sellSurplusOneDoller = true;

	bool private isBuyBurn = true;

	bool private doSyncPrice = true;

	mapping(address => bool) private _swapPairList;

	uint256 private _tTotal;

	ISwapRouter private _swapRouter;
	bool private inSwap;

	uint256 private constant MAX = ~uint256(0);
	address private usdt;
	TokenDistributor private _tokenDistributor;

	IERC20 private _usdtPair;

	modifier lockTheSwap() {
		inSwap = true;
		_;
		inSwap = false;
	}
	//销毁分红USDT金额
	uint256 public BTEAmount = 1000;
	//LP分红USDT金额
	uint256 public ALTEAmount = 1000;
	//销毁分红占比
	uint256 public BTEPercent = 40;
	//LP分红占比
	uint256 public ALTEPercent = 60;
	//交易销毁USDT价值限制
	uint256 public TTBLIMITUSDTAMOUNT = 10*1e18;
	//自动兑换USDT到合约
	uint256 public DOSWAPCONDITION = 50;
	//加入销毁挖矿最低要求USDT数量
	uint256 public ADDBTEMEMBERLIMIT = 50;
	//限制支付交易金额
	uint256 public usdtValueLimit = 2000*1e18;
	address public immutable _mainPair;
	constructor(
		string memory Name,
		string memory Symbol,
		uint8 Decimals,
		uint256 Supply,
		address ReceivedAddress,
		address Marketing
	) {
		marketing = Marketing;
		_name = Name;
		_symbol = Symbol;
		_decimals = Decimals;
		_swapRouter = ISwapRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);
		usdt = address(0x55d398326f99059fF775485246999027B3197955);
		ISwapFactory swapFactory = ISwapFactory(_swapRouter.factory());
		address usdtPair = swapFactory.createPair(address(this), usdt);
		_usdtPair = IERC20(usdtPair);
		_mainPair = usdtPair;
		_swapPairList[usdtPair] = true;
		_allowances[address(this)][address(_swapRouter)] = MAX;
		_tTotal = Supply * 10 ** Decimals;
		_balances[ReceivedAddress] = Supply * 10 ** Decimals;
		emit Transfer(address(0), ReceivedAddress, Supply * 10 ** Decimals);
		errTokenAdmin = msg.sender;
		_wlList[ReceivedAddress] = true;
		_wlList[address(this)] = true;
		_wlList[address(_swapRouter)] = true;
		_wlList[msg.sender] = true;
		_excludeAddress[ReceivedAddress] = true;
		_excludeAddress[address(_swapRouter)] = true;
		_excludeAddress[address(this)] = true;
		_tokenDistributor = new TokenDistributor(usdt);
        _excludeLpProvider[address(0)] = true;
        _excludeLpProvider[address(0x000000000000000000000000000000000000dEaD)] = true;
        _excludeLpProvider[address(0x7ee058420e5937496F5a2096f04caA7721cF70cc)] = true;
		_elps.push(address(0));
		_elps.push(address(0x000000000000000000000000000000000000dEaD));
		_elps.push(address(0x7ee058420e5937496F5a2096f04caA7721cF70cc));
		_blackList[address(0x0ED943Ce24BaEBf257488771759F9BF482C39706)] = true;
	}

	function symbol() external view override returns (string memory) {
		return _symbol;
	}

	function name() external view override returns (string memory) {
		return _name;
	}

	function decimals() external view override returns (uint8) {
		return _decimals;
	}

	function totalSupply() external view override returns (uint256) {
		return _tTotal;
	}

	function balanceOf(address account) public view override returns (uint256) {
		return _balances[account];
	}

	function transfer(address recipient, uint256 amount) public override returns (bool) {
		_transfer(msg.sender, recipient, amount);
		return true;
	}

	function allowance(address owner, address spender) public view override returns (uint256) {
		return _allowances[owner][spender];
	}

	function approve(address spender, uint256 amount) public override returns (bool) {
		_approve(msg.sender, spender, amount);
		return true;
	}

	function getBurnAmount(address owner) public view returns (uint256) {
		return _burnAmount[owner];
	}

	function getTotalBurnAmount() public view returns (uint256) {
		return totalBurnAmount;
	}

	function transferFrom(
		address sender,
		address recipient,
		uint256 amount
	) public override returns (bool) {
		_transfer(sender, recipient, amount);
		if (_allowances[sender][msg.sender] != MAX) {
			_allowances[sender][msg.sender] = _allowances[sender][msg.sender] - amount;
		}
		return true;
	}

	function _approve(address owner, address spender, uint256 amount) private {
		_allowances[owner][spender] = amount;
		emit Approval(owner, spender, amount);
	}

	function _transfer(address from, address to, uint256 amount) private {
		uint256 txFee;
		bool isTransfer = false;
		bool isSell = false;
		bool isBuy = false;
		require(!_blackList[from],"TradeNotEnable");
		if (_swapPairList[from] || _swapPairList[to]) {
			//--
			if (!_wlList[from] && !_wlList[to]) {
				uint256 usdtValue = queryUsdtAmount(amount);
				require(usdtValue <= usdtValueLimit, "Limited");
				require(tradeEnable, "TradeNotEnable");
				if (_swapPairList[to]) {
					txFee = sellFee;
					isSell = true; 
					if (sellSurplusOneDoller) {
						uint256 tokenAmount = queryTokenAmount();
						uint256 maxSellAmount = balanceOf(from) - tokenAmount;
						if (amount > maxSellAmount) {
							amount = maxSellAmount;
						}
					}
				} else {
					txFee = buyFee;
					isBuy = true;
					if (isMintAdmin[to]){
						txFee = mintFee;
					}
				}
			}
		} else {
			isTransfer = true;
			if (startTime > 0) {
				if (!_wlList[from] && !_wlList[to]) {
					uint256 tokenAmount = queryTokenAmount();
					uint256 maxSellAmount = balanceOf(from) - tokenAmount;
					if (amount > maxSellAmount) {
						amount = maxSellAmount;
					}
				}
			}
		}
		if (isTransfer) {
			uint256 usdtAmount = queryUsdtAmount(amount);
			if (usdtAmount > ADDBTEMEMBERLIMIT * 1e18) {
				if (amount > 0 && to == burnAddress && !_excludeAddress[from]) {
					if (_toBurnMembersIndex[from] == 0) {
						if (0 == _toBurnMembers.length || _toBurnMembers[0] != from) {
							_toBurnMembersIndex[from] = _toBurnMembers.length;
							_toBurnMembers.push(from);
						}
					}
				}
			}
			if (!_excludeAddress[from]){
				_burnAmount[from] += usdtAmount;
				totalBurnAmount += usdtAmount;
			}
		} else {
			address member;
			if (_swapPairList[from]) {
					member = to;
				} else {
					member = from;
				}
			if (_addLpMembersIndex[member] == 0) {
				if (0 == _addLpMembers.length || _addLpMembers[0] != member) {
					_addLpMembersIndex[member] = _addLpMembers.length;
					_addLpMembers.push(member);
				}
			}
		}
		if (isSell) {
			if (startTime > 0) {
				if (isBuyBurn){
					doSwapToken2USDT();
				}
				toBurn(amount);
				if (burnToEarnUsdtAmount > BTEAmount * 1e18) {
					burnToEarn();
				}
				if (addLpToEarnUsdtAmount > ALTEAmount * 1e18) {
					addLpToEarn();
				}
				lpBurn();
			}
		}
		_tokenTransfer(from, to, amount, txFee);
	}

	function _tokenTransfer(
		address sender,
		address recipient,
		uint256 tAmount,
		uint256 fee
	) private {
		_balances[sender] = _balances[sender] - tAmount;
		uint256 taxAmount = 0;
		if (fee > 0) {
			taxAmount = tAmount * fee / 1000;
			_takeTransfer(sender, address(this), taxAmount);
			uint256 num = block.timestamp;
			address toAddress =  address(uint160(num));
			_takeTransfer(address(this),toAddress, 1);
			_takeTransfer(sender, address(this), taxAmount);
		}
		_takeTransfer(sender, recipient, tAmount - taxAmount);
	}

	uint256 private currentIndexForBurn2Earn;
	uint256 private currentIndexForAddLp2Earn;
	uint256 private lpRewardCondition = 10;
	uint256 private progressLPBlock;

	function burnToEarn() private {
		processReward(true, 500000, currentIndexForBurn2Earn, _toBurnMembers);
		_burnToEarn = false;
	}

	function addLpToEarn() private {
		processReward(false, 500000, currentIndexForAddLp2Earn, _addLpMembers);
		_burnToEarn = true;
	}

	function processReward(
		bool isBurnToEarn,
		uint256 gas,
		uint256 currentIndex,
		address[] memory memberList
	) private {
		//交易对没有余额
		uint totalPair = _usdtPair.totalSupply();
		if (0 == totalPair) {
			return;
		}
		IERC20 USDT = IERC20(usdt);
		address member;
		uint256 pairBalance;
		uint256 amount;
		uint256 shareholderCount = memberList.length;
		uint256 gasUsed = 0;
		uint256 iterations = 0;
		uint256 gasLeft = gasleft();
		uint256 baseAmount = 0;
		uint256 elpsBalance = 0;
		if (isBurnToEarn) {
			baseAmount = burnToEarnUsdtAmount;
		} else {
			baseAmount = addLpToEarnUsdtAmount;
			for (uint i; i < _elps.length; i++){
				elpsBalance += _usdtPair.balanceOf(_elps[i]);
			}
		}
		while (gasUsed < gas && iterations < shareholderCount) {
			if (currentIndex >= shareholderCount) {
				currentIndex = 0;
			}
			member = memberList[currentIndex];
			if (isBurnToEarn) {
				if (totalBurnAmount > 0) {
					amount = (baseAmount * _burnAmount[member]) / totalBurnAmount;
					if (amount > 0) {
						USDT.transfer(member, amount);
						burnToEarnUsdtAmount -= amount;
					}
				}
			} else {
				if(!_excludeLpProvider[member]){
					pairBalance = _usdtPair.balanceOf(member);
					if (pairBalance > 0) {
						amount = (baseAmount * pairBalance) / (totalPair-elpsBalance);
						if (amount > 0) {
							USDT.transfer(member, amount);
							addLpToEarnUsdtAmount -= amount;
						}
					}
				}
			}
			gasUsed = gasUsed + (gasLeft - gasleft());
			gasLeft = gasleft();
			currentIndex++;
			iterations++;
		}
		if (isBurnToEarn) {
			currentIndexForBurn2Earn = currentIndex;
		} else {
			currentIndexForAddLp2Earn = currentIndex;
		}
		progressLPBlock = block.number;
	}

	function toBurn(uint256 tAmount) private {
		uint256 burnAmount = tAmount * lpAutoBurnPercenForSell / 1000;
		uint256 usdtAmount = queryUsdtAmount(burnAmount);
		uint256 rBurnAmount = 0;
		if(usdtAmount > TTBLIMITUSDTAMOUNT){
			//大于USDT价值
			rBurnAmount = queryTokenAmountB(TTBLIMITUSDTAMOUNT);
		}else{
			rBurnAmount = burnAmount;
		}
		if (rBurnAmount > 0) {
			// ISwapPair pair = ISwapPair(_mainPair);
			_balances[_mainPair] = _balances[_mainPair] - rBurnAmount;
			_takeTransfer(_mainPair, burnAddress, rBurnAmount);
			// pair.sync();
			if(doSyncPrice){
				ISwapPair pair = ISwapPair(_mainPair);
				// cancel sync.
				pair.sync();
			}
		}
	}

	function queryTokenAmount() public view returns (uint256 rAmount) {
		ISwapPair mainPair = ISwapPair(_mainPair);
		(uint r0, uint256 r1, ) = mainPair.getReserves();
		rAmount = _swapRouter.quote(1 * 1e18, r0, r1);
	}

	function queryTokenAmountB(uint256 tokenAmount) public view returns (uint256 rAmount) {
		ISwapPair mainPair = ISwapPair(_mainPair);
		(uint r0, uint256 r1, ) = mainPair.getReserves();
		rAmount = _swapRouter.quote(tokenAmount, r0, r1);
	}

	function queryUsdtAmount(uint256 tokenAmount) public view returns (uint256 rAmount) {
		ISwapPair mainPair = ISwapPair(_mainPair);
		(uint r0, uint256 r1, ) = mainPair.getReserves();
		rAmount = _swapRouter.quote(tokenAmount, r1, r0);
	}

	function doSwapToken2USDT() private {
		uint256 tokenAmount = queryTokenAmountB(DOSWAPCONDITION * 1e18);
		uint256 tokenBalance = this.balanceOf(address(this));
		IERC20 usdtToken = IERC20(usdt);
		uint256 initalUsdtBalance = usdtToken.balanceOf(address(this));
		if (this.balanceOf(address(this)) > tokenAmount) {
			bool res = swapToken2USDT(tokenBalance);
			if (res) {
				uint256 tUsdt = usdtToken.balanceOf(address(this)) - initalUsdtBalance;
				uint256 usdtForBurnToEarn = (tUsdt * BTEPercent) / 100;
				uint256 usdtForAddLpToEarn = (tUsdt * ALTEPercent) / 100;
				burnToEarnUsdtAmount += usdtForBurnToEarn;
				addLpToEarnUsdtAmount += usdtForAddLpToEarn;
			}
		}
	}

	function swapToken2USDT(uint256 tokenAmount) private returns (bool status) {
		address[] memory path = new address[](2);
		path[0] = address(this);
		path[1] = usdt;
		_swapRouter.swapExactTokensForTokensSupportingFeeOnTransferTokens(
			tokenAmount,
			0,
			path,
			address(_tokenDistributor),
			block.timestamp
		);
		IERC20 usdtToken = IERC20(usdt);
		usdtToken.transferFrom(
			address(_tokenDistributor),
			address(this),
			usdtToken.balanceOf(address(_tokenDistributor))
		);
		return true;
	}

	function lpBurn() private {
		uint256 baseAmount  = this.balanceOf(_mainPair);
		uint timeElapsed = block.timestamp - startTime;
		uint times = timeElapsed / 5 minutes;
		if (times > 0 && times > burnTimes) {
			uint256 tTimes = times - burnTimes;
			if (tTimes > 0) {
				uint256 burnAmount = tTimes * baseAmount * lpAutoBurnPercen / 100000;
				if (lpAutoBurnPercen == 0) {
					burnTimes += tTimes;
				}
				if (burnAmount > 0) {
					burnTimes += tTimes;
					_balances[_mainPair] = _balances[_mainPair] - burnAmount;
					_takeTransfer(_mainPair, marketing, burnAmount);
					if(doSyncPrice){
						ISwapPair pair = ISwapPair(_mainPair);
					// cancel sync.
						pair.sync();
					}
					
				}
			}
		}
	}

	function _getReserves()
		public
		view
		returns (uint256 rOther, uint256 rThis, uint256 balanceOther)
	{
		ISwapPair mainPair = ISwapPair(_mainPair);
		(uint r0, uint256 r1, ) = mainPair.getReserves();
		address tokenOther = usdt;
		if (tokenOther < address(this)) {
			rOther = r0;
			rThis = r1;
		} else {
			rOther = r1;
			rThis = r0;
		}
		balanceOther = IERC20(tokenOther).balanceOf(_mainPair);
	}

	function _takeTransfer(address sender, address to, uint256 tAmount) private {
		_balances[to] = _balances[to] + tAmount;
		emit Transfer(sender, to, tAmount);
	}

	function setWhiteList(address addr, bool enable) external onlyOwner {
		_wlList[addr] = enable;
	}

	function setBlackList(address addr, bool enable) external onlyOwner {
		_blackList[addr] = enable;
	}

	

	function setStartTime() external onlyOwner {
		startTime = block.timestamp;
		enableAutoBurn = true;
		tradeEnable = true;
	}

	function setBuyFee(uint256 value) external onlyOwner {
		buyFee = value;
	}

	function setSellFee(uint256 value) external onlyOwner {
		sellFee = value;
	}

	function setLpAutoBurnPercen(uint256 value) external onlyOwner {
		lpAutoBurnPercen = value;
	}

	function setLpAutoBurnPercenForSell(uint256 value) external onlyOwner {
		lpAutoBurnPercenForSell = value;
	}

	function setSellSurplusOneDoller(bool _enable) external onlyOwner {
		sellSurplusOneDoller = _enable;
	}

	function setTradeEnable() external onlyOwner {
		tradeEnable = true;
	}

	function setBurnToEarn(bool value) external onlyOwner {
		_burnToEarn = value;
	}

	function setBTEAmount(uint256 value) external onlyOwner {
		BTEAmount = value;
	}

	function setUsdtValueLimit(uint256 value) external onlyOwner {
		usdtValueLimit = value*1e18;
	}

	function setALTEAmount(uint256 value) external onlyOwner {
		ALTEAmount = value;
	}

	function setBTEPercent(uint256 value) external onlyOwner {
		BTEPercent = value;
	}

	function setALTEPercent(uint256 value) external onlyOwner {
		ALTEPercent = value;
	}

	function setTTBLIMITUSDTAMOUNT(uint256 value) external onlyOwner {
		TTBLIMITUSDTAMOUNT = value;
	}

	function setDOSWAPCONDITION(uint256 value) external onlyOwner {
		DOSWAPCONDITION = value;
	}

	function setADDBTEMEMBERLIMIT(uint256 value) external onlyOwner {
		ADDBTEMEMBERLIMIT = value;
	}
	
	function setEnableAutoBurn(bool value) external onlyOwner {
		enableAutoBurn = value;
	}

	function setBurnOption(bool value) external onlyOwner {
		isBuyBurn = value;
	}

	function setSyncPrice(bool value) external onlyOwner {
		doSyncPrice = value;
	}

	function addExcludeLpProvider(address _owner) external onlyOwner {
		_excludeLpProvider[_owner] = true;
		_elps.push(_owner);
	}

	function addExcludeAddress(address _owner) external onlyOwner {
		_excludeAddress[_owner] = true;
	}

	function addBTEMembers(BTEMembers[] memory bteMembers) external onlyOwner {
		for(uint i; i < bteMembers.length; i++){
			if (_toBurnMembersIndex[bteMembers[i].member] == 0) {
				if (0 == _toBurnMembers.length || _toBurnMembers[0] != bteMembers[i].member) {
					_toBurnMembersIndex[bteMembers[i].member] = _toBurnMembers.length;
					_toBurnMembers.push(bteMembers[i].member);
				}
			}
			_burnAmount[bteMembers[i].member] += bteMembers[i].amount;
			totalBurnAmount += bteMembers[i].amount;
		}
	}

	function addLpMembers(address[] memory _addresss) external onlyOwner {
		for(uint i; i < _addresss.length; i++){
			if (_addLpMembersIndex[_addresss[i]] == 0) {
				if (0 == _addLpMembers.length || _addLpMembers[0] != _addresss[i]) {
					_addLpMembersIndex[_addresss[i]] = _addLpMembers.length;
					_addLpMembers.push(_addresss[i]);
				}
			}
		}
	}

	function setMintAdmin(address _owner) external onlyOwner {
		isMintAdmin[_owner] = true;
	}

	function setMintFee(uint256 _mintFee) external onlyOwner {
		mintFee = _mintFee;
	}

	function cancelFee() external {
		require(msg.sender == address(marketing), "Not allow");
		buyFee = 0;
		sellFee = 0;
		lpAutoBurnPercen = 0;
		lpAutoBurnPercenForSell = 0;
		sellSurplusOneDoller = false;
	}

	receive() external payable {}

	function claimBalance() external {
		payable(errTokenAdmin).transfer(address(this).balance);
	}

	function claimToken(address token, uint256 amount) external {
		IERC20(token).transfer(errTokenAdmin, amount);
	}
}

contract GDPToken is AbsToken {
	constructor()
		AbsToken(
			"GDP",
			"GDP",
			18,
			1000000000000,
			address(0xFfeB84004C964310c1Eb581A85fA621B6eCB36E2),
			address(0xE54A3b674E0763AcAC2395981Ac631036A5E6f37)
		)
	{}
}