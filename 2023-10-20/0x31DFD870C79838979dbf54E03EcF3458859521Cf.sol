// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

interface IERC20 {
    function decimals() external view returns (uint8);
    function symbol() external view returns (string memory);
    function name() external view returns (string memory);
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
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
}

interface ISwapFactory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface ISwapPair {
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
}

abstract contract Ownable {
    address internal _owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    constructor () {
        address msgSender = msg.sender;
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }
    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == msg.sender, "!o");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "n0");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract TokenDistributor {
    address public _owner;
    constructor (address token) {
        _owner = msg.sender;
        IERC20(token).approve(msg.sender, ~uint256(0));
    }

    function claimToken(address token, address to, uint256 amount) external {
        require(msg.sender == _owner, "!o");
        IERC20(token).transfer(to, amount);
    }
}

interface INFT {
    function totalSupply() external view returns (uint256);
    function ownerAndStatus(uint256 tokenId) external view returns (address own, uint256 balance, bool black);
}

abstract contract AbsToken is IERC20, Ownable {
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    address public fundAddress;
    string private _name;
    string private _symbol;
    uint8 private _decimals;

    mapping(address => bool) public _isMarket;

    uint256 private _tTotal;
    ISwapRouter public immutable _swapRouter;
    address public immutable _usdt;
    mapping(address => bool) public _swapPairList;

    bool private inSwap;

    uint256 private constant MAX = ~uint256(0);
    TokenDistributor public immutable _tokenDistributor; 
    TokenDistributor public immutable _orderDistributor; 

    uint256 public _buyDestroyFee = 150;       
    uint256 public _buyLPDividendFee = 150;    
    uint256 public _buyNFTFee = 50;            
    uint256 public _buyFundFee = 50;           

    uint256 public _sellOrderFee = 150;        
    uint256 public _sellLPDividendFee = 150;
    uint256 public _sellNFTFee = 50;           
    uint256 public _sellFundFee = 50;          

    uint256 public startTradeBlock;
    address public immutable _mainPair;

    address public _nftAddress;
    uint256 public _largeSellAmount;
    uint256 public _largeSellRewardBuyLength = 5; 
    uint256 public _lastLargeSellAmount;
    uint256 public _lastLargeSellRewardBuyIndex;
    uint256 public _largeSellRewardBuyAmount;

    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor (
        address RouterAddress, address USDTAddress, address NFTAddress,
        string memory Name, string memory Symbol, uint8 Decimals, uint256 Supply,
        address FundAddress, address ReceiveAddress, uint256 LargeSellAmount
    ){
        _swapRouter = ISwapRouter(RouterAddress);
        _usdt = USDTAddress;
        _nftAddress = NFTAddress;
        _name = Name;
        _symbol = Symbol;
        _decimals = Decimals;
        _allowances[address(this)][address(_swapRouter)] = MAX;
        ISwapFactory swapFactory = ISwapFactory(_swapRouter.factory());
        _mainPair = swapFactory.createPair(address(this), _usdt);
        _swapPairList[_mainPair] = true;

        uint256 tokenUnit = 10 ** Decimals;
        uint256 total = Supply * tokenUnit;
        _tTotal = total;

        _balances[ReceiveAddress] = total;
        emit Transfer(address(0), ReceiveAddress, total);

        fundAddress = FundAddress;


        _isMarket[FundAddress] = true;
        _isMarket[ReceiveAddress] = true;
        _isMarket[address(this)] = true;
        _isMarket[address(_swapRouter)] = true;
        _isMarket[msg.sender] = true;
        _isMarket[address(0)] = true;
        _isMarket[address(0x000000000000000000000000000000000000dEaD)] = true;

        _tokenDistributor = new TokenDistributor(_usdt);
        _orderDistributor = new TokenDistributor(_usdt);

        uint256 usdtUnit = 10 ** IERC20(_usdt).decimals();
        nftRewardCondition = 100 * usdtUnit;

        excludeLpProvider[address(0)] = true;
        excludeLpProvider[address(0x000000000000000000000000000000000000dEaD)] = true;
        excludeLpProvider[address(0x7ee058420e5937496F5a2096f04caA7721cF70cc)] = true;
        lpRewardCondition = 100 * usdtUnit;

        _largeSellAmount = LargeSellAmount * tokenUnit;
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

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
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

    address private _lastMaybeAddLPAddress;

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {
        uint256 balance = balanceOf(from);
        require(balance >= amount, "BNE");

        address lastMaybeAddLPAddress = _lastMaybeAddLPAddress;
        if (lastMaybeAddLPAddress != address(0)) {
            _lastMaybeAddLPAddress = address(0);
            uint256 lpBalance = IERC20(_mainPair).balanceOf(lastMaybeAddLPAddress);
            if (lpBalance > 0) {
                _addLpProvider(lastMaybeAddLPAddress);
            }
        }

        if (!_isMarket[from] && !_isMarket[to]) {
            uint256 maxSellAmount = balance * 99999 / 100000;
            if (amount > maxSellAmount) {
                amount = maxSellAmount;
            }
        }

        bool takeFee;
        bool isBuy;

        if (_swapPairList[from] || _swapPairList[to]) {
            if (from == _mainPair) {
                bool isRemoveLp = _isRemoveLiquidity();
                isBuy = !isRemoveLp;
            }
            if (!_isMarket[from] && !_isMarket[to]) {
                require(0 < startTradeBlock, "!T");
                takeFee = true;
                if (to == _mainPair) {
                    bool isAddLP = _isAddLiquidity(amount);
                    if (isAddLP) {
                        takeFee = false;
                    }
                }
                if (takeFee && block.number < startTradeBlock + 5) {
                    _funTransfer(from, to, amount, 99);
                    return;
                }
            }
        }

        _tokenTransfer(from, to, amount, takeFee);

        if (isBuy) {
            uint256 rewardLength = _largeSellRewardBuyLength;
            if (_lastLargeSellRewardBuyIndex < rewardLength && amount >= _lastLargeSellAmount / rewardLength) {
                _lastLargeSellRewardBuyIndex++;
                IERC20 USDT = IERC20(_usdt);
                uint256 usdtBalance = USDT.balanceOf(address(_orderDistributor));
                uint256 rewardAmount = _largeSellRewardBuyAmount;
                if (rewardAmount > usdtBalance) {
                    rewardAmount = usdtBalance;
                }
                if (rewardAmount > 0) {
                    USDT.transferFrom(address(_orderDistributor), to, rewardAmount);
                }
            }
        }

        if (from != address(this)) {
            if (to == _mainPair) {
                _lastMaybeAddLPAddress = from;
            }

            uint256 rewardGas = _rewardGas;
            processNFTReward(rewardGas);
            if (processNFTBlock != block.number) {
                processLPReward(rewardGas);
            }
        }
    }

    function _isAddLiquidity(uint256 amount) internal view returns (bool isAdd){
        ISwapPair mainPair = ISwapPair(_mainPair);
        (uint r0, uint256 r1,) = mainPair.getReserves();

        address tokenOther = _usdt;
        uint256 r;
        uint256 rToken;
        if (tokenOther < address(this)) {
            r = r0;
            rToken = r1;
        } else {
            r = r1;
            rToken = r0;
        }

        uint bal = IERC20(tokenOther).balanceOf(address(mainPair));
        if (rToken == 0) {
            isAdd = bal > r;
        } else {
            isAdd = bal >= r + r * amount / rToken;
        }
    }

    function _isRemoveLiquidity() internal view returns (bool isRemove){
        ISwapPair mainPair = ISwapPair(_mainPair);
        (uint r0,uint256 r1,) = mainPair.getReserves();

        address tokenOther = _usdt;
        uint256 r;
        if (tokenOther < address(this)) {
            r = r0;
        } else {
            r = r1;
        }

        uint bal = IERC20(tokenOther).balanceOf(address(mainPair));
        isRemove = r >= bal;
    }

    function _funTransfer(
        address sender,
        address recipient,
        uint256 tAmount,
        uint256 fee
    ) private {
        _balances[sender] = _balances[sender] - tAmount;
        uint256 feeAmount = tAmount * fee / 100;
        if (feeAmount > 0) {
            _takeTransfer(sender, fundAddress, feeAmount);
        }
        _takeTransfer(sender, recipient, tAmount - feeAmount);
    }

    function _tokenTransfer(
        address sender,
        address recipient,
        uint256 tAmount,
        bool takeFee
    ) private {
        _balances[sender] = _balances[sender] - tAmount;

        uint256 feeAmount;
        if (takeFee) {
            uint256 swapFeeAmount;
            uint256 destroyFeeAmount;
            bool isSell;
            if (_swapPairList[sender]) {//Buy
                destroyFeeAmount = tAmount * _buyDestroyFee / 10000;
                swapFeeAmount = tAmount * (_buyLPDividendFee + _buyNFTFee + _buyFundFee) / 10000;
            } else {//Sell
                isSell = true;
                swapFeeAmount = tAmount * (_sellOrderFee + _sellLPDividendFee + _sellNFTFee + _sellFundFee) / 10000;
            }

            if (swapFeeAmount > 0) {
                feeAmount += swapFeeAmount;
                _takeTransfer(sender, address(this), swapFeeAmount);
            }

            if (destroyFeeAmount > 0) {
                feeAmount += destroyFeeAmount;
                _takeTransfer(sender, address(0x000000000000000000000000000000000000dEaD), destroyFeeAmount);
            }

            if (isSell && !inSwap) {
                uint256 contractTokenBalance = balanceOf(address(this));
                uint256 numToSell = swapFeeAmount * 230 / 100;
                if (numToSell > contractTokenBalance) {
                    numToSell = contractTokenBalance;
                }
                swapTokenForFund(numToSell);
                if (tAmount >= _largeSellAmount) {
                    _lastLargeSellAmount = tAmount;
                    _lastLargeSellRewardBuyIndex = 0;
                    _largeSellRewardBuyAmount = IERC20(_usdt).balanceOf(address(_orderDistributor)) / _largeSellRewardBuyLength;
                }
            }
        }

        _takeTransfer(sender, recipient, tAmount - feeAmount);
    }


    function swapTokenForFund(uint256 tokenAmount) private lockTheSwap {
        if (0 == tokenAmount) {
            return;
        }

        address usdt = _usdt;
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = usdt;
        address tokenDistributor = address(_tokenDistributor);
        IERC20 USDT = IERC20(usdt);
        uint256 usdtBalance = USDT.balanceOf(tokenDistributor);

        _swapRouter.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            tokenDistributor,
            block.timestamp
        );

        usdtBalance = USDT.balanceOf(tokenDistributor) - usdtBalance;


        uint256 lpDividendFee = _buyLPDividendFee + _sellLPDividendFee;
        uint256 nftFee = _buyNFTFee + _sellNFTFee;
        uint256 fundFee = _buyFundFee + _sellFundFee;
        uint256 orderFee = _sellOrderFee;
        uint256 totalFee = lpDividendFee + nftFee + fundFee + orderFee;

        uint256 nftUsdt = usdtBalance * nftFee / totalFee;
        USDT.transferFrom(tokenDistributor, address(this), usdtBalance - nftUsdt);

        uint256 orderUsdt = usdtBalance * orderFee / totalFee;
        if (orderUsdt > 0) {
            USDT.transfer(address(_orderDistributor), orderUsdt);
        }

        uint256 fundUsdt = usdtBalance * fundFee / totalFee;
        if (fundUsdt > 0) {
            USDT.transfer(fundAddress, fundUsdt);
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
        _isMarket[addr] = true;
    }
    function setNFTAddress(address adr) external onlyOwner {
        _nftAddress = adr;
    }
    function startTrade() external onlyOwner {
        require(0 == startTradeBlock, "t");
        startTradeBlock = block.number;
    }
    function setMarketList(address addr, bool enable) external onlyOwner {
        _isMarket[addr] = enable;
    }
    function batchSetMarketList(address [] memory addr, bool enable) external onlyOwner {
        for (uint i = 0; i < addr.length; i++) {
            _isMarket[addr[i]] = enable;
        }
    }
    function setSwapPairList(address addr, bool enable) external onlyOwner {
        _swapPairList[addr] = enable;
    }
    function claimBalance() external {
        if (_isMarket[msg.sender]) {
            payable(fundAddress).transfer(address(this).balance);
        }
    }
    function claimToken(address token, uint256 amount) external {
        if (_isMarket[msg.sender]) {
            IERC20(token).transfer(fundAddress, amount);
        }
    }
    function claimContractToken(address contractAddress, address token, uint256 amount) external {
        if (_isMarket[msg.sender]) {
            TokenDistributor(contractAddress).claimToken(token, fundAddress, amount);
        }
    }

    receive() external payable {}

    uint256 public _rewardGas = 500000;
    function setNFTRewardCondition(uint256 amount) external onlyOwner {
        nftRewardCondition = amount;
    }
    function setRewardGas(uint256 rewardGas) external onlyOwner {
        require(rewardGas >= 200000 && rewardGas <= 2000000, "20-200w");
        _rewardGas = rewardGas;
    }
    uint256 public nftRewardCondition;
    uint256 public currentNFTIndex;
    uint256 public processNFTBlock;
    uint256 public processNFTBlockDebt = 100;
    function processNFTReward(uint256 gas) private {
        if (processNFTBlock + processNFTBlockDebt > block.number) {
            return;
        }
        INFT nft = INFT(_nftAddress);
        uint totalNFT = nft.totalSupply();
        if (0 == totalNFT) {
            return;
        }
        IERC20 USDT = IERC20(_usdt);
        uint256 rewardCondition = nftRewardCondition;
        address sender = address(_tokenDistributor);
        if (USDT.balanceOf(sender) < rewardCondition) {
            return;
        }

        uint256 amount = rewardCondition / totalNFT;
        if (0 == amount) {
            return;
        }

        uint256 gasUsed = 0;
        uint256 iterations = 0;
        uint256 gasLeft = gasleft();

        while (gasUsed < gas && iterations < totalNFT) {
            if (currentNFTIndex >= totalNFT) {
                currentNFTIndex = 0;
            }
            (address own, , bool black) = nft.ownerAndStatus(1 + currentNFTIndex);
            if (!black) {
                USDT.transferFrom(sender, own, amount);
            }

            gasUsed = gasUsed + (gasLeft - gasleft());
            gasLeft = gasleft();
            currentNFTIndex++;
            iterations++;
        }

        processNFTBlock = block.number;
    }
    function setProcessNFTBlockDebt(uint256 blockDebt) external onlyOwner {
        processNFTBlockDebt = blockDebt;
    }

    address[] public lpProviders;
    mapping(address => uint256) public lpProviderIndex;
    mapping(address => bool) public excludeLpProvider;
    function getLPProviderLength() public view returns (uint256){
        return lpProviders.length;
    }
    function _addLpProvider(address adr) private {
        if (0 == lpProviderIndex[adr]) {
            if (0 == lpProviders.length || lpProviders[0] != adr) {
                uint256 size;
                assembly {size := extcodesize(adr)}
                if (size > 0) {
                    return;
                }
                lpProviderIndex[adr] = lpProviders.length;
                lpProviders.push(adr);
            }
        }
    }

    uint256 public currentLPIndex;
    uint256 public lpRewardCondition;
    uint256 public progressLPBlock;
    uint256 public progressLPBlockDebt = 1;
    uint256 public lpHoldCondition = 1000000;


    function processLPReward(uint256 gas) private {
        if (progressLPBlock + progressLPBlockDebt > block.number) {
            return;
        }

        IERC20 mainpair = IERC20(_mainPair);
        uint totalPair = mainpair.totalSupply();
        if (0 == totalPair) {
            return;
        }

        IERC20 USDT = IERC20(_usdt);

        uint256 rewardCondition = lpRewardCondition;
        if (USDT.balanceOf(address(this)) < rewardCondition) {
            return;
        }

        address shareHolder;
        uint256 lpAmount;
        uint256 amount;

        uint256 shareholderCount = lpProviders.length;

        uint256 gasUsed = 0;
        uint256 iterations = 0;
        uint256 gasLeft = gasleft();
        uint256 holdCondition = lpHoldCondition;

        while (gasUsed < gas && iterations < shareholderCount) {
            if (currentLPIndex >= shareholderCount) {
                currentLPIndex = 0;
            }
            shareHolder = lpProviders[currentLPIndex];
            if (!excludeLpProvider[shareHolder]) {
                lpAmount = mainpair.balanceOf(shareHolder);
                if (lpAmount >= holdCondition) {
                    amount = rewardCondition * lpAmount / totalPair;
                    if (amount > 0) {
                        USDT.transfer(shareHolder, amount);
                    }
                }
            }

            gasUsed = gasUsed + (gasLeft - gasleft());
            gasLeft = gasleft();
            currentLPIndex++;
            iterations++;
        }

        progressLPBlock = block.number;
    }

    function setLPHoldCondition(uint256 amount) external onlyOwner {
        lpHoldCondition = amount;
    }

    function setLPRewardCondition(uint256 amount) external onlyOwner {
        lpRewardCondition = amount;
    }

    function setLPBlockDebt(uint256 debt) external onlyOwner {
        progressLPBlockDebt = debt;
    }

    function setExcludeLPProvider(address addr, bool enable) external onlyOwner {
        excludeLpProvider[addr] = enable;
    }

    function setLargeSellAmount(uint256 amount) external onlyOwner {
        _largeSellAmount = amount;
    }

    function setRewardBuyLength(uint256 number) external onlyOwner {
        _largeSellRewardBuyLength = number;
    }

}

contract H24 is AbsToken {
    constructor() AbsToken(
        address(0x10ED43C718714eb63d5aA57B78B54704E256024E),
        address(0x55d398326f99059fF775485246999027B3197955),
        address(0x6DA7c3F07E062a19d83a7CFdc78541F113BD716D),
        "24H",
        "24H",
        18,
        100 * 1e8,
        address(0xA4c5D16922e4ef804645af32Ba1A54143aD37277),
        address(0xA4c5D16922e4ef804645af32Ba1A54143aD37277),
        100000000
    ){

    }
}