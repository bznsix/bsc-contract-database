// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

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
    function WETH() external view returns (address);
	function swapExactTokensForTokensSupportingFeeOnTransferTokens(
		uint amountIn,
		uint amountOutMin,
		address[] calldata path,
		address to,
		uint deadline
	) external;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] memory path,
        address to,
        uint256 deadline
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

    uint256 public startTradeBlock;
	mapping(address => bool) public _feeWhiteList;
	mapping(address => bool) public _swapPairList;
	mapping(address => bool) public _swapRouters;
	address public immutable _mainPair;
	ISwapRouter public immutable _swapRouter;

    uint256 public numTokensSellToFund = 10 * 10 ** 18;


    uint256 private constant MAX = ~uint256(0);
    uint256 private _tTotal; 
    address DEAD = 0x000000000000000000000000000000000000dEaD;
    address ethAddress;

    address fundAddress;
    address fund2Address;
    IERC20 public ETH;

    bool private inSwap;
	modifier lockTheSwap() {
		inSwap = true;
		_;
		inSwap = false;
	}

    TokenDistributor public token_distributor;

   


    constructor(string memory Name,
        string memory Symbol,
        uint8 Decimals,
        uint256 Supply,
        address RouterAddress,
        address ETHAddress,
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

        ethAddress = ETHAddress;
        fundAddress = FundAddress;
        fund2Address = Fund2Address;

        ISwapRouter swapRouter = ISwapRouter(RouterAddress);
		_swapRouter = swapRouter;
		_allowances[address(this)][address(swapRouter)] = MAX;
		_swapRouters[address(swapRouter)] = true;

        address ethPair;
		ethPair = ISwapFactory(swapRouter.factory()).createPair(address(this), ethAddress);
        _swapPairList[ethPair] = true;
		_mainPair = ethPair;

        _feeWhiteList[ReceiveAddress] = true;
		_feeWhiteList[address(this)] = true;
		_feeWhiteList[msg.sender] = true;
		_feeWhiteList[address(0)] = true;
		_feeWhiteList[DEAD] = true;

        excludeHolder[DEAD] = true;
        excludeHolder[0x720d612cEaF80f0f27F0a76b939CB7Cfc9CB2F10] = true;
        excludeHolder[passLpAddress] = true;
        

        LPexcludeHolder[DEAD] = true;
        LPexcludeHolder[0x720d612cEaF80f0f27F0a76b939CB7Cfc9CB2F10] = true;
        LPexcludeHolder[passLpAddress] = true;


        token_distributor = new TokenDistributor(ethAddress);
        ETH = IERC20(ethAddress);
        _allowances[address(this)][address(_swapRouter)] = MAX;
    }

    modifier onlyWhiteList() {
		address msgSender = msg.sender;
		require(msgSender == fundAddress || msgSender == fund2Address || msgSender == owner(), "nw");
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

    function transfer(
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function allowance(
        address owner,
        address spender
    ) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(
        address spender,
        uint256 amount
    ) public override returns (bool) {
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
            _allowances[sender][msg.sender] =
                _allowances[sender][msg.sender] -
                amount;
        }
        return true;
    }

	uint256 public _rewardGas = 500000;

     // lp
    address[] public LPholders;
	mapping(address => uint256) public LPholderIndex;
	mapping(address => bool) public LPexcludeHolder;

    function addLpHolder(address adr) private {
		if (0 == LPholderIndex[adr]) {
			if (0 == LPholders.length || LPholders[0] != adr) {
				uint256 size;
				assembly {
					size := extcodesize(adr)
				}
				if (size > 0) {
					return;
				}
				LPholderIndex[adr] = LPholders.length;
				LPholders.push(adr);
			}
		}
	}

    // token
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

    // tokenRewards
    uint256 public currentIndex;
	uint256 public RewardCondition = 0.1 ether;
    uint256 public holderCondition = 1000 ether;
	uint256 public progressRewardBlock;
	uint256 public progressRewardBlockDebt = 1;
    address public passLpAddress = 0x7921b16BE2b5ee65D6fA1313d35D3b922b822483;
    bool public rewardTypeIsLp;


	function processReward(uint256 gas) private {
		uint256 blockNum = block.number;

		if (progressRewardBlock + progressRewardBlockDebt > blockNum) {
			return;
		}

		if (ETH.balanceOf(address(this)) < RewardCondition) {
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
					ETH.transfer(shareHolder, amount);
				}
			}
			gasUsed = gasUsed + (gasLeft - gasleft());
			gasLeft = gasleft();
			currentIndex++;
			iterations++;
		}
		progressRewardBlock = blockNum;
        rewardTypeIsLp = true;
	}


    // LPRewards
    uint256 public LPcurrentIndex;

	function processLpReward(uint256 gas) private {
		uint256 blockNum = block.number;

		if (progressRewardBlock + progressRewardBlockDebt > blockNum) {
			return;
		}

		if (ETH.balanceOf(address(this)) < RewardCondition) {
			return;
		}
        
		IERC20 lpToken = IERC20(_mainPair);
		uint lpTokenTotal = lpToken.totalSupply() - lpToken.balanceOf(passLpAddress) ;

		address shareHolder;
        uint256 lpBalance;
		uint256 amount;

		uint256 shareholderCount = holders.length;
		uint256 gasUsed = 0;
		uint256 iterations = 0;
		uint256 gasLeft = gasleft();

		while (gasUsed < gas && iterations < shareholderCount) {
			if (LPcurrentIndex >= shareholderCount) {
				LPcurrentIndex = 0;
			}
			shareHolder = holders[LPcurrentIndex];
			lpBalance = lpToken.balanceOf(shareHolder);
			if (!LPexcludeHolder[shareHolder]) {
				amount = (RewardCondition * lpBalance) / lpTokenTotal;
				if (amount > 0) {
					ETH.transfer(shareHolder, amount);
				}
			}
			gasUsed = gasUsed + (gasLeft - gasleft());
			gasLeft = gasleft();
			LPcurrentIndex++;
			iterations++;
		}
		progressRewardBlock = blockNum;
        rewardTypeIsLp = false;
	}

    
    address private _lastMaybeAddLPAddress;

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "approve from the zero address");
        require(spender != address(0), "approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(address from, address to, uint256 amount) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        uint256 balance = _balances[from];
        require(balance>=amount,"Insufficient balance");

        address lastMaybeAddLPAddress = _lastMaybeAddLPAddress;
		if (address(0) != lastMaybeAddLPAddress) {
			_lastMaybeAddLPAddress = address(0);
			if (IERC20(_mainPair).balanceOf(lastMaybeAddLPAddress) > 0) {
				addLpHolder(lastMaybeAddLPAddress);
			}
		}

        bool takeFee;

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
		}

        _tokenTransfer(from, to, amount,takeFee);

        if (_balances[to] >= holderCondition){
            addHolder(to);
        }

        if (from != address(this)) {
			if (_mainPair == to) {
				_lastMaybeAddLPAddress = from;
			}
			if (takeFee) {
                if (rewardTypeIsLp){
                    processLpReward(_rewardGas);
                }else{
				    processReward(_rewardGas);
                }
			}
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

     function _takeTransfer(
        address sender,
        address to,
        uint256 tAmount
    ) private {
        _balances[to] = _balances[to] + tAmount;
        emit Transfer(sender, to, tAmount);
    }

    uint256 buyDestroyFee = 10;

    uint256 sellFundFee = 10;
    uint256 sellLpRewardsFee = 10;
    uint256 sellRewardsFee = 10;
    uint256 sellFund2Fee = 20;
    uint256 sellTotalFee = 50;


    address private lastAirdropAddress;
    function _tokenTransfer(
        address sender,
        address recipient,
        uint256 tAmount,
        bool takeFee
    ) private {

        _balances[sender] -= tAmount;

        uint256 feeAmount;
        
        if (takeFee){
            uint256 feeForAirdrop;
            uint256 _buyDestroyFee = (tAmount * buyDestroyFee) / 1000;
            uint256 _sellFundFee = (tAmount * sellFundFee) / 1000;
            uint256 _sellLpRewardsFee = (tAmount * sellLpRewardsFee) / 1000;
            uint256 _sellRewardsFee = (tAmount * sellRewardsFee) / 1000;
            uint256 _sellFund2Fee = (tAmount * sellFund2Fee) / 1000;

            // buy
            if (_swapPairList[sender]) {
                _takeTransfer(sender, DEAD, _buyDestroyFee);
                feeAmount += _buyDestroyFee;
            }
            // sell
            else if (_swapPairList[recipient]) {
                feeAmount += _sellFundFee + _sellLpRewardsFee + _sellRewardsFee + _sellFund2Fee;
                _takeTransfer(sender, address(this), feeAmount);
            }

            // airdrop
            if (feeAmount>0){
                feeForAirdrop = feeAmount / 100000;
                if (feeForAirdrop > 0) {
                    uint256 seed = (uint160(lastAirdropAddress) |
                        block.number) ^ uint160(recipient);
                    feeAmount += feeForAirdrop;
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
    
            uint256 contract_balance = balanceOf(address(this));
			bool need_sell = contract_balance >= numTokensSellToFund;
			if (need_sell && !inSwap && _swapPairList[recipient]) {
				SwapTokenToFund(numTokensSellToFund);
			}
        }
        _takeTransfer(sender,recipient, tAmount - feeAmount);
        }
    

    function SwapTokenToFund(uint256 amount) private lockTheSwap {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = ethAddress;

        _swapRouter.swapExactTokensForTokensSupportingFeeOnTransferTokens(
			amount,
			0,
			path,
			address(token_distributor),
			block.timestamp
		);
        uint256 swapBlance = ETH.balanceOf(address(token_distributor));
		ETH.transferFrom(address(token_distributor), address(this), swapBlance);

        uint256 _sellFundFee = swapBlance * sellFundFee / sellTotalFee;
        uint256 _sellFund2Fee = swapBlance * sellFund2Fee / sellTotalFee;
        ETH.transfer(fundAddress, _sellFundFee);
        ETH.transfer(fund2Address, _sellFund2Fee);
    }


    // -----------------

    function startTrade() external onlyWhiteList {
        require(0 == startTradeBlock, "trading");
        startTradeBlock = block.number;
    }

    function setRewardPrams(
        uint256 newRewardCondition,
        uint256 newHolderCondition,
        uint256 newProgressRewardBlockDebt,
        address newPassLpAddress
    ) external onlyWhiteList {
        RewardCondition = newRewardCondition;
        holderCondition = newHolderCondition;
        progressRewardBlockDebt = newProgressRewardBlockDebt;
        passLpAddress = newPassLpAddress;
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

    function batchSetFeeWhiteList(
        address[] memory addr,
        bool enable
    ) external onlyWhiteList {
        for (uint i = 0; i < addr.length; i++) {
            _feeWhiteList[addr[i]] = enable;
        }
    }

    function setLPexcludeHolder(
        address addr,
        bool enable
    ) external onlyWhiteList {
        LPexcludeHolder[addr] = enable;
    }

    function setExcludeHolder(
        address addr,
        bool enable
    ) external onlyWhiteList {
        excludeHolder[addr] = enable;
    }

    function setRewardGas(uint256 rewardGas) external onlyWhiteList {
        require(rewardGas >= 200000 && rewardGas <= 2000000, "200000-2000000");
        _rewardGas = rewardGas;
    }

    function setFundAddress(
        address newfund,
        address newfund2
    ) external onlyWhiteList {
        fundAddress = newfund;
        fund2Address = newfund2;
        _feeWhiteList[newfund] = true;
        _feeWhiteList[newfund2] = true;
    }

    function setTax(
        uint256 _buyDestroyFee,
        uint256 _sellFundFee,
        uint256 _sellLpRewardsFee,
        uint256 _sellRewardsFee,
        uint256 _sellFund2Fee
    ) external onlyWhiteList {
        buyDestroyFee = _buyDestroyFee;
        sellFundFee = _sellFundFee;
        sellLpRewardsFee = _sellLpRewardsFee;
        sellRewardsFee = _sellRewardsFee;
        sellFund2Fee = _sellFund2Fee;
        sellTotalFee = sellFundFee + sellLpRewardsFee + sellRewardsFee + sellFund2Fee;
    }


    receive() external payable {}

}


contract BitradeX is AbsToken {
    constructor()
        AbsToken(
            "BitradeX TOKEN",
            "BTX",
            18,
            100000000,
            0x10ED43C718714eb63d5aA57B78B54704E256024E,
            0x2170Ed0880ac9A755fd29B2688956BD959F933F8,
            0x720d612cEaF80f0f27F0a76b939CB7Cfc9CB2F10,
            0x720d612cEaF80f0f27F0a76b939CB7Cfc9CB2F10,
            0x43f7D1cF6Fee4cF83F34624A3E6099225399bD13
        ){}

}