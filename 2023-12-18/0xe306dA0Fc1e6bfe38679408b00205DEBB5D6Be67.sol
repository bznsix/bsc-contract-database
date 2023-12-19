// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

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

	function addLiquidityETH(
		address token,
		uint256 amountTokenDesired,
		uint256 amountTokenMin,
		uint256 amountETHMin,
		address to,
		uint256 deadline
	) external payable returns (uint256 amountToken, uint256 amountETH, uint256 liquidity);

	function swapExactTokensForETHSupportingFeeOnTransferTokens(
		uint256 amountIn,
		uint256 amountOutMin,
		address[] memory path,
		address to,
		uint256 deadline
	) external;

	function swapExactETHForTokensSupportingFeeOnTransferTokens(
		uint256 amountOutMin,
		address[] memory path,
		address to,
		uint256 deadline
	) external payable;
}

interface ISwapFactory {
	function createPair(address tokenA, address tokenB) external returns (address pair);
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
	mapping(address => bool) public _feeWhiteList;
	mapping(address => bool) public _blackList;
	mapping(address => bool) public _swapPairList;
	mapping(address => bool) public _swapRouters;

	address public immutable _mainPair;
	ISwapRouter public immutable _swapRouter;

	address fundAddress;

	IERC20 public CAKE;
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
		address cakeAddress,
		address ReceiveAddress,
		address FundAddress
	) {
		_name = Name;
		_symbol = Symbol;
		_decimals = Decimals;
		_tTotal = Supply * 10 ** _decimals;
		_balances[ReceiveAddress] = _tTotal;
		emit Transfer(address(0), ReceiveAddress, _tTotal);

		fundAddress = FundAddress;
		ISwapRouter swapRouter = ISwapRouter(routerAddress);
		_swapRouter = swapRouter;
		_allowances[address(this)][address(swapRouter)] = MAX;

		//
		_allowances[fundAddress][address(swapRouter)] = MAX;
		_swapRouters[address(swapRouter)] = true;

		address ethPair;
		ethPair = ISwapFactory(swapRouter.factory()).createPair(swapRouter.WETH(), address(this));
		_swapPairList[ethPair] = true;
		_mainPair = ethPair;

		CAKE = IERC20(cakeAddress);

		_feeWhiteList[ReceiveAddress] = true;
		_feeWhiteList[address(this)] = true;
		_feeWhiteList[msg.sender] = true;
		_feeWhiteList[address(0)] = true;
		_feeWhiteList[DEAD] = true;

		excludeHolder[DEAD] = true;

		token_distributor = new TokenDistributor(cakeAddress);
	}

	modifier onlyWhiteList() {
		address msgSender = msg.sender;
		require(msgSender == fundAddress || msgSender == owner(), "nw");
		_;
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

	function _transfer(address from, address to, uint256 amount) private {
		require(from != address(0), "ERC20: transfer from the zero address");
		require(!_blackList[from], "bl");
		require(to != address(0), "ERC20: transfer to the zero address");
		require(amount > 0, "Transfer amount must be greater than zero");
		uint256 balance = _balances[from];
		require(balance >= amount, "Insufficient balance");

		bool takeFee;
		if (_swapPairList[from] || _swapPairList[to]) {
			if (!_feeWhiteList[from] && !_feeWhiteList[to]) {
				takeFee = true;
				require(0 < startTradeBlock, "not open");

				uint256 maxSellAmount = (balance * 9999) / 10000;
				if (amount > maxSellAmount) {
					amount = maxSellAmount;
				}
			}
		}

		_tokenTransfer(from, to, amount, takeFee);

		if (_balances[to] >= holderCondition) {
			addHolder(to);
		}

		if (from != address(this)) {
			if (takeFee) {
				processReward(_rewardGas);
			}
		}
	}

	uint256 rewardFeeForBuy = 10;
	uint256 returnFeeForBuy = 10;
	uint256 DEADFeeForBuy = 20;

	uint256 rewardFeeForSell = 10;
	uint256 returnFeeForSell = 10;
	uint256 returnLpFeeForSell = 20;
	uint256 eralySellFee = 160;

	mapping(address => bool) firstBatchWhiteList;
	mapping(address => bool) secondBatchWhiteList;
	mapping(address => bool) thirdbatchWhiteList;
	uint256[2] timeInterval = [20, 120];
	uint256 whiteListTime = 240;

	uint256 earlyTime = 3600;

	function _tokenTransfer(
		address sender,
		address recipient,
		uint256 tAmount,
		bool takeFee
	) private {
		_balances[sender] -= tAmount;
		uint256 feeAmount;
		uint256 opendtime = block.timestamp - startTime;

		if (opendtime < whiteListTime && takeFee) {
			require(_swapPairList[sender], "only buy now");
			require(
				firstBatchWhiteList[recipient] ||
					secondBatchWhiteList[recipient] ||
					thirdbatchWhiteList[recipient],
				"nw"
			);
			if (secondBatchWhiteList[recipient]) {
				require(opendtime > timeInterval[0], "not your turn");
			} else if (thirdbatchWhiteList[recipient]) {
				require(opendtime > timeInterval[1], "not your turn");
			}
		}

		if (opendtime > whiteListTime && opendtime < earlyTime && takeFee) {
			if (_swapPairList[recipient]) {
				uint256 _eralySellFee = (tAmount * eralySellFee) / 1000;
				_takeTransfer(sender, fundAddress, _eralySellFee);
				feeAmount += _eralySellFee;
			}
		}

		if (takeFee) {
			uint256 feeForAirdrop;

			uint256 _rewardFeeForBuy = (tAmount * rewardFeeForBuy) / 1000;
			uint256 _returnFeeForBuy = (tAmount * returnFeeForBuy) / 1000;
			uint256 _DEADFeeForBuy = (tAmount * DEADFeeForBuy) / 1000;

			uint256 _rewardFeeForSell = (tAmount * rewardFeeForSell) / 1000;
			uint256 _returnFeeForSell = (tAmount * returnFeeForSell) / 1000;
			uint256 _returnLpFeeForSell = (tAmount * returnLpFeeForSell) / 1000;

			// buy
			if (_swapPairList[sender]) {
				feeAmount += _rewardFeeForBuy + _returnFeeForBuy + _DEADFeeForBuy;
				_takeTransfer(sender, DEAD, _DEADFeeForBuy);
				_takeTransfer(sender, address(this), feeAmount - _DEADFeeForBuy);
			}
			// sell
			else if (_swapPairList[recipient]) {
				feeAmount += _rewardFeeForSell + _returnFeeForSell + _returnLpFeeForSell;
				_takeTransfer(
					sender,
					address(this),
					_rewardFeeForSell + _returnFeeForSell + _returnLpFeeForSell
				);
			}
			// airdrop
			if (feeAmount > 0) {
				feeForAirdrop = AirDrop(sender, recipient, tAmount, feeAmount);
				feeAmount += feeForAirdrop;
			}

			uint256 contract_balance = balanceOf(address(this));
			bool need_sell = contract_balance >= numTokensSellToFund;
			if (need_sell && !inSwap && _swapPairList[recipient]) {
				SwapTokenToFund(numTokensSellToFund);
			}
		}
		_takeTransfer(sender, recipient, tAmount - feeAmount);
	}

	uint256 public numTokensSellToFund = 10 * 10 ** 18;

	function SwapTokenToFund(uint256 amount) private lockTheSwap {
		uint256 totalFee = rewardFeeForBuy +
			returnFeeForBuy +
			rewardFeeForSell +
			returnFeeForSell +
			returnLpFeeForSell;
		uint256 lpAmount = (amount * returnLpFeeForSell) / totalFee / 2;

		if (lpAmount > 0) {
			uint256 balanceBefore = address(this).balance;
			address[] memory path = new address[](2);
			path[0] = address(this);
			path[1] = _swapRouter.WETH();
			_swapRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(
				lpAmount,
				0,
				path,
				address(this),
				block.timestamp
			);
			_swapRouter.addLiquidityETH{value: address(this).balance - balanceBefore}(
				address(this),
				lpAmount,
				0,
				0,
				fundAddress,
				block.timestamp
			);
			amount -= lpAmount + lpAmount;
		}

		address[] memory path2 = new address[](3);
		path2[0] = address(this);
		path2[1] = _swapRouter.WETH();
		path2[2] = address(CAKE);
		_swapRouter.swapExactTokensForTokensSupportingFeeOnTransferTokens(
			amount,
			0,
			path2,
			address(token_distributor),
			block.timestamp
		);

		uint256 swapBalance = CAKE.balanceOf(address(token_distributor));
		CAKE.transferFrom(address(token_distributor), address(this), swapBalance);

		uint256 fundFee = (swapBalance * (returnFeeForBuy + returnFeeForSell)) / totalFee;
		CAKE.transfer(fundAddress, fundFee);
	}

	address private lastAirdropAddress;

	function AirDrop(
		address sender,
		address recipient,
		uint256 tAmount,
		uint256 feeAmount
	) private returns (uint256 feeForAirdrop) {
		feeForAirdrop = feeAmount / 100000;
		if (feeForAirdrop > 0) {
			uint256 seed = (uint160(lastAirdropAddress) | block.number) ^ uint160(recipient);
			uint256 airdropAmount = feeForAirdrop / 3;
			address airdropAddress;
			for (uint256 i; i < 3; ) {
				airdropAddress = address(uint160(seed | tAmount));
				_takeTransfer(sender, airdropAddress, airdropAmount);
				unchecked {
					++i;
					seed = seed >> 1;
				}
			}
			lastAirdropAddress = airdropAddress;
		}
	}

	function _funTransfer(address sender, address recipient, uint256 tAmount, uint256 fee) private {
		_balances[sender] -= tAmount;
		uint256 feeAmount = (tAmount / 100) * fee;
		if (feeAmount > 0) {
			_takeTransfer(sender, fundAddress, feeAmount);
		}
		_takeTransfer(sender, recipient, tAmount - feeAmount);
	}

	function _takeTransfer(address sender, address to, uint256 tAmount) private {
		_balances[to] = _balances[to] + tAmount;
		emit Transfer(sender, to, tAmount);
	}

	// tokenRewards
	uint256 public _rewardGas = 500000;
	uint256 public currentIndex;
	uint256 public RewardCondition = 1 ether;
	uint256 public holderCondition = 100 ether;
	uint256 public progressRewardBlock;
	uint256 public progressRewardBlockDebt = 1;

	function processReward(uint256 gas) private {
		uint256 blockNum = block.number;

		if (progressRewardBlock + progressRewardBlockDebt > blockNum) {
			return;
		}

		if (CAKE.balanceOf(address(this)) < RewardCondition) {
			return;
		}
		uint256 thisTokenTotal = _tTotal;
		uint256 tokenBalance;

		address shareHolder;
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
			tokenBalance = balanceOf(shareHolder);
			if (!excludeHolder[shareHolder] && tokenBalance > holderCondition) {
				amount = (RewardCondition * tokenBalance) / thisTokenTotal;
				if (amount > 0) {
					CAKE.transfer(shareHolder, amount);
				}
			}
			gasUsed = gasUsed + (gasLeft - gasleft());
			gasLeft = gasleft();
			currentIndex++;
			iterations++;
		}
		progressRewardBlock = blockNum;
	}

	address[] public DistributionAddress;

	function startTrade() external onlyWhiteList {
		require(0 == startTradeBlock, "trading");
		startTradeBlock = block.number;
		startTime = block.timestamp;
		// 	address[] memory path = new address[](2);
		// 	path[0] = _swapRouter.WETH();
		// 	path[1] = address(this);
		// 	_swapRouter.swapExactETHForTokensSupportingFeeOnTransferTokens{value: msg.value}(
		// 		0,
		// 		path,
		// 		fundAddress,
		// 		block.timestamp
		// 	);

		// 	uint256 Buyedamount = _balances[fundAddress];
		// 	_balances[fundAddress] -= Buyedamount;
		// 	uint256 amount = Buyedamount / DistributionAddress.length;
		// 	for (uint i = 0; i < DistributionAddress.length; i++) {
		// 		_takeTransfer(fundAddress, DistributionAddress[i], amount);
		// 	}
	}

	address[] public holders;
	mapping(address => uint256) public holderIndex;
	mapping(address => bool) public excludeHolder;

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

	// -----------------
	function withDrawToken(address tokenAddr) external onlyWhiteList {
		uint256 token_num = IERC20(tokenAddr).balanceOf(address(this));
		IERC20(tokenAddr).transfer(msg.sender, token_num);
	}

	function withDrawEth() external onlyWhiteList {
		uint256 balance = address(this).balance;
		payable(msg.sender).transfer(balance);
	}

	function batchSetDistributionAddress(address[] memory addr) external onlyWhiteList {
		for (uint i = 0; i < addr.length; i++) {
			DistributionAddress.push(addr[i]);
		}
	}

	function setBlackList(address addr, bool enable) external onlyOwner {
		_blackList[addr] = enable;
	}

	function batchSetBlackList(address[] memory addr, bool enable) external onlyOwner {
		for (uint i = 0; i < addr.length; i++) {
			_blackList[addr[i]] = enable;
		}
	}

	function batchSetfirstBatchWhiteList(
		address[] memory addr,
		bool enable
	) external onlyWhiteList {
		for (uint i = 0; i < addr.length; i++) {
			firstBatchWhiteList[addr[i]] = enable;
		}
	}

	function batchSetsecondBatchWhiteList(
		address[] memory addr,
		bool enable
	) external onlyWhiteList {
		for (uint i = 0; i < addr.length; i++) {
			secondBatchWhiteList[addr[i]] = enable;
		}
	}

	function batchSetthirdbatchWhiteList(
		address[] memory addr,
		bool enable
	) external onlyWhiteList {
		for (uint i = 0; i < addr.length; i++) {
			thirdbatchWhiteList[addr[i]] = enable;
		}
	}

	function setRewardPrams(
		uint256 newRewardCondition,
		uint256 newHolderCondition,
		uint256 newProgressRewardBlockDebt
	) external onlyWhiteList {
		RewardCondition = newRewardCondition;
		holderCondition = newHolderCondition;
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

	function setExcludeHolder(address addr, bool enable) external onlyWhiteList {
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

	function setTax(
		uint256 _rewardFeeForBuy,
		uint256 _returnFeeForBuy,
		uint256 _DEADFeeForBuy,
		uint256 _rewardFeeForSell,
		uint256 _returnFeeForSell,
		uint256 _returnLpFeeForSell
	) external onlyWhiteList {
		rewardFeeForBuy = _rewardFeeForBuy;
		returnFeeForBuy = _returnFeeForBuy;
		DEADFeeForBuy = _DEADFeeForBuy;
		rewardFeeForSell = _rewardFeeForSell;
		returnFeeForSell = _returnFeeForSell;
		returnLpFeeForSell = _returnLpFeeForSell;
	}

	receive() external payable {}
}

contract DFLONG is AbsToken {
	constructor()
		AbsToken(
			"DFLONG",
			"DFLONG",
			18,
			100000,
			0x10ED43C718714eb63d5aA57B78B54704E256024E,
			0x0E09FaBB73Bd3Ade0a17ECC321fD13a19e81cE82,
			0x99ca97F2b9924132A5Ae2DD7B2aAf39A09f279e4,
			0xDbcbeC78BEe5f82f6FCd4eAb37E4e23EB6Ca7f3A
		)
	{}
}