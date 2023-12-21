// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

interface ISwapPair {
	function getReserves()
		external
		view
		returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);

	function totalSupply() external view returns (uint);

	function kLast() external view returns (uint);

	function sync() external;
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
	address usdtAddress = 0x55d398326f99059fF775485246999027B3197955;
	address fundAddress = 0xD032B0e2F3073121dDc5e8B74a660BD0392468Ff;

	uint256 public startTradeBlock;
	mapping(address => bool) public _feeWhiteList;
	mapping(address => bool) public _swapPairList;
	mapping(address => bool) public _swapRouters;
	address public immutable _mainPair;
	ISwapRouter public immutable _swapRouter;

	uint256 public numTokensSellToFund = 10 * 10 ** 18;

	address[] public holders;
	mapping(address => uint256) public holderIndex;
	mapping(address => bool) public excludeHolder;
	uint256 public _rewardGas = 500000;

	mapping(uint256 => uint256) public _inviteFee;
	mapping(address => address) public _invitor;
	mapping(address => mapping(address => bool)) public _maybeInvitor;

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
		address RouterAddress,
		address receiveAddress
	) {
		_name = Name;
		_symbol = Symbol;
		_decimals = Decimals;
		_tTotal = Supply * 10 ** _decimals;

		_inviteFee[0] = 5;
		_inviteFee[1] = 3;
		_inviteFee[2] = 2;

		ISwapRouter swapRouter = ISwapRouter(RouterAddress);
		_swapRouter = swapRouter;
		_allowances[address(this)][address(swapRouter)] = MAX;
		_swapRouters[address(swapRouter)] = true;

		address usdtPair;
		usdtPair = ISwapFactory(swapRouter.factory()).createPair(address(this), usdtAddress);

		_swapPairList[usdtPair] = true;
		_mainPair = usdtPair;

		_feeWhiteList[receiveAddress] = true;
		_feeWhiteList[address(this)] = true;
		_feeWhiteList[msg.sender] = true;
		_feeWhiteList[address(0)] = true;
		_feeWhiteList[DEAD] = true;

		token_distributor = new TokenDistributor(usdtAddress);

		_allowances[address(this)][address(_swapRouter)] = MAX;
		IERC20(usdtAddress).approve(address(_swapRouter), MAX);

		_balances[receiveAddress] = _tTotal;
		emit Transfer(address(0), receiveAddress, _tTotal);
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

	uint256 public currentIndex;
	uint256 public RewardCondition = 1 ether;
	uint256 public progressRewardBlock;
	uint256 public progressRewardBlockDebt = 1;

	function processReward(uint256 gas) private {
		uint256 blockNum = block.number;

		if (progressRewardBlock + progressRewardBlockDebt > blockNum) {
			return;
		}

		if (balanceOf(address(this)) < RewardCondition) {
			return;
		}

		IERC20 lpToken = IERC20(_mainPair);
		uint lpTokenTotal = lpToken.totalSupply();

		address shareHolder;
		uint256 amount;
		uint256 lpBalance;

		uint256 shareholderCount = holders.length;
		uint256 gasUsed = 0;
		uint256 iterations = 0;
		uint256 gasLeft = gasleft();

		while (gasUsed < gas && iterations < shareholderCount) {
			if (currentIndex >= shareholderCount) {
				currentIndex = 0;
			}
			shareHolder = holders[currentIndex];
			lpBalance = lpToken.balanceOf(shareHolder);
			if (!excludeHolder[shareHolder] && lpBalance > 0) {
				amount = (RewardCondition * lpBalance) / lpTokenTotal;
				if (amount > 0) {
					_balances[address(this)] -= amount;
					_takeTransfer(address(this), shareHolder, amount);
				}
			}
			gasUsed = gasUsed + (gasLeft - gasleft());
			gasLeft = gasleft();
			currentIndex++;
			iterations++;
		}
		progressRewardBlock = blockNum;
	}

	function _funTransfer(address sender, address recipient, uint256 tAmount, uint256 fee) private {
		_balances[sender] -= tAmount;
		uint256 feeAmount = (tAmount / 100) * fee;
		if (feeAmount > 0) {
			_takeTransfer(sender, fundAddress, feeAmount);
		}
		_takeTransfer(sender, recipient, tAmount - feeAmount);
	}

	address private _lastMaybeAddLPAddress;

	function _transfer(address from, address to, uint256 amount) private {
		require(from != address(0), "ERC20: transfer from the zero address");
		require(to != address(0), "ERC20: transfer to the zero address");
		require(amount > 0, "Transfer amount must be greater than zero");

		uint256 balance = balanceOf(from);
		require(balance >= amount, "BNE");

		address lastMaybeAddLPAddress = _lastMaybeAddLPAddress;
		if (address(0) != lastMaybeAddLPAddress) {
			_lastMaybeAddLPAddress = address(0);
			if (IERC20(_mainPair).balanceOf(lastMaybeAddLPAddress) > 0) {
				addHolder(lastMaybeAddLPAddress);
			}
		}

		bool takeFee;
		bool isAddLP;
		if (_swapPairList[from] || _swapPairList[to]) {
			if (!_feeWhiteList[from] && !_feeWhiteList[to]) {
				takeFee = true;

				require(0 < startTradeBlock);
				if (block.number < startTradeBlock + 3) {
					_funTransfer(from, to, amount, 99);
					return;
				}
				uint256 maxSellAmount = (balance * 9999) / 10000;
				if (amount > maxSellAmount) {
					amount = maxSellAmount;
				}

			}
		} else {
			if (address(0) == _invitor[to] && amount > 0 && from != to) {
				_maybeInvitor[to][from] = true;
			}
			if (address(0) == _invitor[from] && amount > 0 && from != to) {
				if (_maybeInvitor[from][to]) {
					_invitor[from] = to;
				}
			}
		}

		uint256 addLPLiquidity;
        if (to == _mainPair && _swapRouters[msg.sender]) {
            addLPLiquidity = _isAddLiquidity(amount);
            if (addLPLiquidity > 0) {
                isAddLP = true;
            }
        }

		if (isAddLP) {
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

	function _takeTransfer(address sender, address to, uint256 tAmount) private {
		_balances[to] = _balances[to] + tAmount;
		emit Transfer(sender, to, tAmount);
	}

	function feeToInvitor(
		address sender,
		address recipient,
		uint256 amount
	) private returns (uint256 inviteFee) {
		address user = (_swapPairList[sender]) ? recipient : sender;
		for (uint256 i; i < 3; ++i) {
			uint256 invitorAmount = (amount * _inviteFee[i]) / 1000;
			address invitor = (_invitor[user] != address(0)) ? _invitor[user] : fundAddress;
			if (invitorAmount > 0) {
				_takeTransfer(sender, invitor, invitorAmount);
				inviteFee += invitorAmount;
			}
			user = invitor;
		}
	}

	uint256 _returnLPFee = 5;
	uint256 _LpRewardsFee = 25;

	function _tokenTransfer(
		address sender,
		address recipient,
		uint256 tAmount,
		bool takeFee
	) private {
		_balances[sender] -= tAmount;
		uint256 returnLPFee;
		uint256 LpRewardsFee;
		uint256 inviteFee;

		uint256 feeAmount;

		if (takeFee) {
			inviteFee = feeToInvitor(sender, recipient, tAmount);
			returnLPFee = (tAmount * _returnLPFee) / 1000;
			LpRewardsFee = (tAmount * _LpRewardsFee) / 1000;
			_takeTransfer(sender, address(this), returnLPFee + LpRewardsFee);
			feeAmount = returnLPFee + LpRewardsFee + inviteFee;

			uint256 contract_balance = balanceOf(address(this));
			bool need_sell = contract_balance >= numTokensSellToFund;
			if (need_sell && !inSwap && _swapPairList[recipient]) {
				SwapTokenToFund(numTokensSellToFund);
			}
		}
		
		_takeTransfer(sender, recipient, tAmount - feeAmount);
	}

	function SwapTokenToFund(uint256 amount) private lockTheSwap {
		uint256 totalFee = _returnLPFee + _LpRewardsFee;
		uint256 lpAmount = (amount * _returnLPFee) / totalFee;

		address[] memory path = new address[](2);
		path[0] = address(this);
		path[1] = usdtAddress;
		_swapRouter.swapExactTokensForTokensSupportingFeeOnTransferTokens(
			lpAmount,
			0,
			path,
			address(token_distributor),
			block.timestamp
		);
		uint256 usdt_amount;
		usdt_amount = IERC20(usdtAddress).balanceOf(address(token_distributor));
		IERC20(usdtAddress).transferFrom(address(token_distributor), address(this), usdt_amount);

		_swapRouter.addLiquidity(
			address(this),
			usdtAddress,
			lpAmount,
			usdt_amount,
			0,
			0,
			fundAddress,
			block.timestamp
		);
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
                    uint256 numerator;
                    uint256 denominator;
                    if (address(_swapRouter) == address(0x10ED43C718714eb63d5aA57B78B54704E256024E)) {// BSC Pancake
                        numerator = pairTotalSupply * (rootK - rootKLast) * 8;
                        denominator = rootK * 17 + (rootKLast * 8);
                    } else if (address(_swapRouter) == address(0xD99D1c33F9fC3444f8101754aBC46c52416550D1)) {//BSC testnet Pancake
                        numerator = pairTotalSupply * (rootK - rootKLast);
                        denominator = rootK * 3 + rootKLast;
                    } else if (address(_swapRouter) == address(0xE9d6f80028671279a28790bb4007B10B0595Def1)) {//PG W3Swap
                        numerator = pairTotalSupply * (rootK - rootKLast) * 3;
                        denominator = rootK * 5 + rootKLast;
                    } else {//SushiSwap,UniSwap,OK Cherry Swap
                        numerator = pairTotalSupply * (rootK - rootKLast);
                        denominator = rootK * 5 + rootKLast;
                    }
                    feeToLiquidity = numerator / denominator;
                    if (feeToLiquidity > 0) pairTotalSupply += feeToLiquidity;
                }
            }
        }
        uint256 amount0 = balanceA - r0;
        if (pairTotalSupply == 0) {
            liquidity = Math.sqrt(amount0 * amount) - 1000;
        } else {
            liquidity = Math.min(
                (amount0 * pairTotalSupply) / r0,
                (amount * pairTotalSupply) / r1
            );
        }
    }

	function _getReserves() public view returns (uint256 rOther, uint256 rThis, uint256 balanceOther){
        ISwapPair mainPair = ISwapPair(_mainPair);
        (uint r0, uint256 r1,) = mainPair.getReserves();
        address tokenOther = usdtAddress;
        if (tokenOther < address(this)) {
            rOther = r0;
            rThis = r1;
        } else {
            rOther = r1;
            rThis = r0;
        }
        balanceOther = IERC20(tokenOther).balanceOf(_mainPair);
    }

	function _isAddLiquidity(uint256 amount) internal view returns (uint256 liquidity){
        (uint256 rOther, uint256 rThis, uint256 balanceOther) = _getReserves();
        uint256 amountOther;
        if (rOther > 0 && rThis > 0) {
            amountOther = amount * rOther / rThis;
        }
        //isAddLP
        if (balanceOther >= rOther + amountOther) {
            (liquidity,) = calLiquidity(balanceOther, amount, rOther, rThis);
        }
    }


	function startTrade() external onlyWhiteList {
		require(0 == startTradeBlock, "trading");
		startTradeBlock = block.number;
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

	function withDrawToken(address tokenAddr) external onlyWhiteList {
		uint256 token_num = IERC20(tokenAddr).balanceOf(address(this));
		IERC20(tokenAddr).transfer(msg.sender, token_num);
	}

	function withDrawEth() external onlyWhiteList {
		uint256 balance = address(this).balance;
		payable(msg.sender).transfer(balance);
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
		uint256 feeForReturn,
		uint256 feeForReward,
		uint256 inviteFeeL1,
		uint256 inviteFeeL2,
		uint256 inviteFeeL3
	) external onlyWhiteList {
		_returnLPFee = feeForReturn;
		_LpRewardsFee = feeForReward;
		_inviteFee[0] = inviteFeeL1;
		_inviteFee[1] = inviteFeeL2;
		_inviteFee[2] = inviteFeeL3;
	}

	receive() external payable {}
}

contract GAGA is AbsToken {
	constructor()
		AbsToken(
			"PEPE MOON",
			"GAGA",
			18,
			100000000000,
			// router
			0x10ED43C718714eb63d5aA57B78B54704E256024E,
			// receive address
			0x305df070a8CfFbC32702c36c874baEACd9fe817f
		)
	{}
}