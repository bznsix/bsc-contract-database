// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

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

interface ISwapPair {
	function getReserves()
		external
		view
		returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);

	function totalSupply() external view returns (uint);

	function kLast() external view returns (uint);

	function sync() external;
}

interface ISwapRouter {
	function factory() external pure returns (address);

	function WETH() external view returns (address);

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
		require(_owner == msg.sender, "Ownable: caller is not the owner");
		_;
	}

	function renounceOwnership() public virtual onlyOwner {
		emit OwnershipTransferred(_owner, address(0));
		_owner = address(0);
	}

	function transferOwnership(address newOwner) public virtual onlyOwner {
		require(newOwner != address(0), "Ownable: new owner is the zero address");
		emit OwnershipTransferred(_owner, newOwner);
		_owner = newOwner;
	}
}

contract TokenDistributor {
	constructor(address token) {
		IERC20(token).approve(msg.sender, uint(~uint256(0)));
	}
}

abstract contract AbsToken is IERC20, Ownable {
	mapping(address => uint256) private _balances;
	mapping(address => mapping(address => uint256)) private _allowances;
	string private _name;
	string private _symbol;
	uint8 private _decimals;

	uint256 private constant MAX = ~uint256(0);
	uint256 private _tTotal;
	address DEAD = 0x000000000000000000000000000000000000dEaD;

	uint256 public startTradeBlock;
	uint256 public startTime;
	bool buyStat = false;
	bool sellStat = false;
	mapping(address => bool) public _feeWhiteList;
	mapping(address => bool) public _swapPairList;
	mapping(address => bool) public _swapRouters;

	address public immutable _mainPair;
	ISwapRouter public immutable _swapRouter;

	IERC20 public MOSS;

	address fundAddress;
	address fund2Address;

	bool private inSwap;

	modifier lockTheSwap() {
		inSwap = true;
		_;
		inSwap = false;
	}
	TokenDistributor public token_distributor;

	constructor(
		string memory Name,
		string memory Symbol,
		uint8 Decimals,
		uint256 Supply,
		address routerAddress,
		address MossAddress,
		address ReceiveAddress,
		address FundAddress,
		address Fund2Address
	) {
		_name = Name;
		_symbol = Symbol;
		_decimals = Decimals;
		_tTotal = Supply * 10 ** _decimals;
		_balances[ReceiveAddress] = _tTotal;
		emit Transfer(address(0), ReceiveAddress, _tTotal);

		fundAddress = FundAddress;
		fund2Address = Fund2Address;
		ISwapRouter swapRouter = ISwapRouter(routerAddress);
		_swapRouter = swapRouter;
		_allowances[address(this)][address(swapRouter)] = MAX;

		//
		_allowances[fundAddress][address(swapRouter)] = MAX;
		_swapRouters[address(swapRouter)] = true;

		address ethPair;
		ethPair = ISwapFactory(swapRouter.factory()).createPair(address(this), swapRouter.WETH());
		_swapPairList[ethPair] = true;
		_mainPair = ethPair;

		_feeWhiteList[ReceiveAddress] = true;
		_feeWhiteList[fundAddress] = true;
		_feeWhiteList[Fund2Address] = true;
		_feeWhiteList[address(this)] = true;
		_feeWhiteList[msg.sender] = true;
		_feeWhiteList[address(0)] = true;
		_feeWhiteList[DEAD] = true;

		MOSS = IERC20(MossAddress);
		token_distributor = new TokenDistributor(MossAddress);
		// excludeHolder[DEAD] = true;
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
		require(owner != address(0), "approve from the zero address");
		require(spender != address(0), "approve to the zero address");

		_allowances[owner][spender] = amount;
		emit Approval(owner, spender, amount);
	}

	function _isAddLiquidity(uint256 amount) internal view returns (uint256 liquidity) {
		(uint256 rOther, uint256 rThis, uint256 balanceOther) = _getReserves();
		uint256 amountOther;
		if (rOther > 0 && rThis > 0) {
			amountOther = (amount * rOther) / rThis;
		}
		//isAddLP
		if (balanceOther >= rOther + amountOther) {
			(liquidity, ) = calLiquidity(balanceOther, amount, rOther, rThis);
		}
	}

	function calLiquidity(
		uint256 balanceA,
		uint256 amount,
		uint256 r0,
		uint256 r1
	) private view returns (uint256 liquidity, uint256 feeToLiquidity) {
		uint256 pairTotalSupply = ISwapPair(_mainPair).totalSupply();
		address feeTo = ISwapFactory(_swapRouter.factory()).feeTo();
		bool feeOn = feeTo != address(0);
		uint256 _kLast = ISwapPair(_mainPair).kLast();
		if (feeOn) {
			if (_kLast != 0) {
				uint256 rootK = Math.sqrt(r0 * r1);
				uint256 rootKLast = Math.sqrt(_kLast);
				if (rootK > rootKLast) {
					uint256 numerator = pairTotalSupply * (rootK - rootKLast) * 8;
					uint256 denominator = rootK * 17 + (rootKLast * 8);
					feeToLiquidity = numerator / denominator;
					if (feeToLiquidity > 0) pairTotalSupply += feeToLiquidity;
				}
			}
		}
		uint256 amount0 = balanceA - r0;
		if (pairTotalSupply == 0) {
			if (amount0 > 0) {
				liquidity = Math.sqrt(amount0 * amount) - 1000;
			}
		} else {
			liquidity = Math.min((amount0 * pairTotalSupply) / r0, (amount * pairTotalSupply) / r1);
		}
	}

	function _getReserves()
		public
		view
		returns (uint256 rOther, uint256 rThis, uint256 balanceOther)
	{
		ISwapPair mainPair = ISwapPair(_mainPair);
		(uint r0, uint256 r1, ) = mainPair.getReserves();
		address tokenOther = _swapRouter.WETH();
		if (tokenOther < address(this)) {
			rOther = r0;
			rThis = r1;
		} else {
			rOther = r1;
			rThis = r0;
		}
		balanceOther = IERC20(tokenOther).balanceOf(_mainPair);
	}

	function _isRemoveLiquidity(uint256 amount) internal view returns (uint256 liquidity) {
		(uint256 rOther, , uint256 balanceOther) = _getReserves();
		//isRemoveLP
		if (balanceOther <= rOther) {
			liquidity =
				(amount * ISwapPair(_mainPair).totalSupply()) /
				(balanceOf(_mainPair) - amount);
		}
	}

	function _isRemoveLiquidityETH(uint256 amount) internal view returns (uint256 liquidity) {
		(uint256 rOther, , uint256 balanceOther) = _getReserves();
		//isRemoveLP
		if (balanceOther <= rOther) {
			liquidity = (amount * ISwapPair(_mainPair).totalSupply()) / balanceOf(_mainPair);
		}
	}

	address private _lastMaybeAddLPAddress;

	function _transfer(address from, address to, uint256 amount) private {
		require(from != address(0), "ERC20: transfer from the zero address");
		require(to != address(0), "ERC20: transfer to the zero address");
		require(amount > 0, "Transfer amount must be greater than zero");
		uint256 balance = _balances[from];
		require(balance >= amount, "Insufficient balance");

		bool takeFee;

		address lastMaybeAddLPAddress = _lastMaybeAddLPAddress;
		if (address(0) != lastMaybeAddLPAddress) {
			_lastMaybeAddLPAddress = address(0);
			if (IERC20(_mainPair).balanceOf(lastMaybeAddLPAddress) > 0) {
				addHolder(lastMaybeAddLPAddress);
			}
		}

		if (!_feeWhiteList[from] && !_feeWhiteList[to]) {
			if (_swapPairList[from] || _swapPairList[to]) {
				takeFee = true;
				require(0 < startTradeBlock, "not open");
			}
			uint256 maxSellAmount = (balance * 9999) / 10000;
			if (amount > maxSellAmount) {
				amount = maxSellAmount;
			}
		}

		bool isAddLP;
		bool isRemoveLP;

		uint256 addLPLiquidity;
		if (to == _mainPair && _swapRouters[msg.sender]) {
			uint256 addLPAmount = amount;
			addLPLiquidity = _isAddLiquidity(addLPAmount);
			if (addLPLiquidity > 0) {
				isAddLP = true;
			}
		}

		uint256 removeLPLiquidity;
		if (from == _mainPair && to != address(_swapRouter)) {
			removeLPLiquidity = _isRemoveLiquidity(amount);
			if (removeLPLiquidity > 0) {
				isRemoveLP = true;
			}
		}

		if (isAddLP || isRemoveLP) {
			takeFee = false;
		}

		_tokenTransfer(from, to, amount, takeFee);

		if (from != address(this)) {
			if (_mainPair == to) {
				_lastMaybeAddLPAddress = from;
			}
			if (takeFee && !isAddLP) {
				processReward(_rewardGas);
			}
		}
	}

	uint256 buyFeeForFund = 10;
	uint256 buyFeeForReward = 20;

	uint256 sellFeeForFund = 10;
	uint256 sellFeeForReward = 30;

	uint256 snipeFee = 300;
	uint256 snipeMaxHold = 30 ether;
	uint256 snipeTimeRange = 600;

	function _tokenTransfer(
		address sender,
		address recipient,
		uint256 tAmount,
		bool takeFee
	) private {
		_balances[sender] -= tAmount;
		uint256 feeAmount;
		if (takeFee) {
			// buy
			if (_swapPairList[sender]) {
				require(buyStat, "not open");
				uint256 _buyFeeForFund = (tAmount * buyFeeForFund) / 1000;
				uint256 _buyFeeForReward = (tAmount * buyFeeForReward) / 1000;
				feeAmount = _buyFeeForFund + _buyFeeForReward;
				_takeTransfer(sender, fundAddress, _buyFeeForFund);
				_takeTransfer(sender, address(this), _buyFeeForReward);
			}
			// sell
			else if (_swapPairList[recipient]) {
				require(sellStat, "not open");
				uint256 _sellFeeForFund = (tAmount * sellFeeForFund) / 1000;
				uint256 _sellFeeForReward = (tAmount * sellFeeForReward) / 1000;
				feeAmount = _sellFeeForFund + _sellFeeForReward;
				_takeTransfer(sender, fundAddress, _sellFeeForFund);
				_takeTransfer(sender, address(this), _sellFeeForReward);
				// snipe
				if (block.timestamp < startTime + snipeTimeRange) {
					uint256 _snipeFee = (tAmount * snipeFee) / 1000;
					_takeTransfer(sender, fundAddress, _snipeFee - feeAmount);
					feeAmount = _snipeFee;
				}
			}
		}

		uint256 finalAmount = tAmount - feeAmount;
		if (
			block.timestamp < startTime + snipeTimeRange &&
			!_swapPairList[recipient] &&
			!_swapPairList[recipient] &&
			!_feeWhiteList[recipient]
		) {
			require(_balances[recipient] + finalAmount <= snipeMaxHold, "snipe time max hold");
		}

		uint256 contract_balance = balanceOf(address(this));
		bool need_sell = contract_balance >= numTokensSellToFund;
		if (need_sell && !inSwap && _swapPairList[recipient]) {
			SwapTokenToFund(numTokensSellToFund);
		}
		_takeTransfer(sender, recipient, finalAmount);
	}

	uint256 public numTokensSellToFund = 1 * 10 ** 18;

	function SwapTokenToFund(uint256 amount) private lockTheSwap {
		address[] memory path = new address[](3);
		path[0] = address(this);
		path[1] = _swapRouter.WETH();
		path[2] = address(MOSS);
		_swapRouter.swapExactTokensForTokensSupportingFeeOnTransferTokens(
			amount,
			0,
			path,
			address(token_distributor),
			block.timestamp
		);
		uint256 swapBalance = MOSS.balanceOf(address(token_distributor));
		MOSS.transferFrom(address(token_distributor), address(this), swapBalance);
	}

	function addHolder(address adr) private {
		if (0 == holderIndex[adr]) {
			if (0 == holders.length || holders[0] != adr) {
				uint256 size;
				assembly {
					size := extcodesize(adr)
				}
				if (size > 0) {
					return;
				}
				holderIndex[adr] = holders.length;
				holders.push(adr);
			}
		}
	}

	address[] public holders;
	mapping(address => uint256) public holderIndex;
	mapping(address => bool) public excludeHolder;
	uint256 public _rewardGas = 500000;

	uint256 public currentIndex;
	uint256 public RewardCondition = 1 ether;
	uint256 public progressRewardBlock;
	uint256 public progressRewardBlockDebt = 1;

	function processReward(uint256 gas) private {
		uint256 blockNum = block.number;

		if (progressRewardBlock + progressRewardBlockDebt > blockNum) {
			return;
		}

		if (MOSS.balanceOf(address(this)) < RewardCondition) {
			return;
		}

		IERC20 lpToken = IERC20(_mainPair);
		uint lpTokenTotal = lpToken.totalSupply();

		address shareHolder;
		uint256 lpBalance;
		uint256 amount;

		uint256 shareholderCount = holders.length;
		uint256 gasUsed = 0;
		uint256 iterations = 0;
		uint256 gasLeft = gasleft();

		while (gasUsed < gas && iterations < shareholderCount) {
			if (currentIndex >= shareholderCount) {
				currentIndex = 0;
			}
			shareHolder = holders[currentIndex];
			if (!excludeHolder[shareHolder]) {
				lpBalance = lpToken.balanceOf(shareHolder);
				amount = (RewardCondition * lpBalance) / lpTokenTotal;
				if (amount > 0) {
					MOSS.transfer(shareHolder, amount);
				}
			}
			gasUsed = gasUsed + (gasLeft - gasleft());
			gasLeft = gasleft();
			currentIndex++;
			iterations++;
		}

		progressRewardBlock = blockNum;
	}

	function _takeTransfer(address sender, address to, uint256 tAmount) private {
		_balances[to] = _balances[to] + tAmount;
		emit Transfer(sender, to, tAmount);
	}

	// ——————————————————————————————————

	modifier onlyWhiteList() {
		address msgSender = msg.sender;
		require(msgSender == fund2Address || msgSender == owner(), "nw");
		_;
	}

	function startTrade() external payable onlyWhiteList {
		require(0 == startTradeBlock, "trading");
		startTradeBlock = block.number;
		startTime = block.timestamp;
		buyStat = true;
		sellStat = true;
	}

	function setRewardPrams(
		uint256 newRewardCondition,
		uint256 newProgressRewardBlockDebt
	) external onlyWhiteList {
		RewardCondition = newRewardCondition;
		progressRewardBlockDebt = newProgressRewardBlockDebt;
	}

	function setNumTokensSellToFund(uint256 newNum) external onlyWhiteList {
		numTokensSellToFund = newNum;
	}

	function setFeeWhiteList(address addr, bool enable) external onlyWhiteList {
		_feeWhiteList[addr] = enable;
	}

	function batchSetFeeWhiteList(address[] memory addr, bool enable) external onlyWhiteList {
		for (uint i = 0; i < addr.length; i++) {
			_feeWhiteList[addr[i]] = enable;
		}
	}

	function batchSetLpHolder(address[] memory addr) external onlyWhiteList {
		for (uint i = 0; i < addr.length; i++) {
			addHolder(addr[i]);
		}
	}

	function setExcludeLpHolder(address addr, bool enable) external onlyWhiteList {
		excludeHolder[addr] = enable;
	}

	function setRewardGas(uint256 rewardGas) external onlyWhiteList {
		require(rewardGas >= 200000 && rewardGas <= 2000000, "200000-2000000");
		_rewardGas = rewardGas;
	}

	function setFundAddress(address newfund) external onlyWhiteList {
		fundAddress = newfund;
		_feeWhiteList[newfund] = true;
	}

	function setTradeStatus(bool buy, bool sell) external onlyWhiteList {
		buyStat = buy;
		sellStat = sell;
	}

	function setTax(
		uint256 _buyFeeForFund,
		uint256 _buyFeeForReward,
		uint256 _sellFeeForFund,
		uint256 _sellFeeForReward
	) external onlyWhiteList {
		buyFeeForFund = _buyFeeForFund;
		buyFeeForReward = _buyFeeForReward;
		sellFeeForFund = _sellFeeForFund;
		sellFeeForReward = _sellFeeForReward;
	}

	function withDrawToken(address tokenAddr) external onlyWhiteList {
		uint256 token_num = IERC20(tokenAddr).balanceOf(address(this));
		IERC20(tokenAddr).transfer(msg.sender, token_num);
	}

	function withDrawEth() external onlyWhiteList {
		uint256 balance = address(this).balance;
		payable(msg.sender).transfer(balance);
	}

	receive() external payable {}
}

contract ETL2 is AbsToken {
	constructor()
		AbsToken(
			"ETL2.0",
			"ETL2.0",
			18,
			9900,
			0x10ED43C718714eb63d5aA57B78B54704E256024E,
			0xC651Cf5Dd958B6D7E4c417F1f366659237C34166,
			0x2D85FdE58ff9a30F8FFED32f1Df9bdB62664A8f6,
			0x1A2fDd1dbd84347Be06dfAAAc7cE32fd7865218b,
			0xc3E9d0279038eF34E76880620A7C42A0e09613FC
		)
	{}
}