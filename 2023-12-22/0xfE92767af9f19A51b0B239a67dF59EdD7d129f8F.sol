// SPDX-License-Identifier: MIT

pragma solidity ^0.8.6;

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

    function token0() external view returns (address);

    function token1() external view returns (address);

    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);

    function WETH() external pure returns (address);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
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

interface ISwapPair {
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);

    function token0() external view returns (address);

    function token1() external view returns (address);

    function totalSupply() external view returns (uint);

    function kLast() external view returns (uint);

    function sync() external;
}

abstract contract AbsToken is IERC20, Ownable {
    
    mapping(address => uint256) public _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    address public fundAddress;
    address public marketAddress;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    mapping(address => bool) public _wl;
    mapping(address => bool) public _wl2;
    mapping(address => uint256) public _wl2b;

    mapping(address => bool) public _bl;

    uint256 private _tTotal;

    ISwapRouter public immutable _swapRouter;
    mapping(address => bool) public _swapPairList;
    mapping(address => bool) public _swapRouters;

    bool private inSwap;

    bool public bSwap = true;

    uint256 private constant MAX = ~uint256(0);

    uint256 public _buyTax = 500;
    uint256 public _sellTax = 500;

    uint256 public startTradeBlock;
    uint256 public startAddLPBlock;
    address public immutable _mainPair;
    address public  immutable _weth;

    uint256 public _startTradeTime;

    uint256 public _numToSell;

    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor (
        address RouterAddress, 
        address ReceiveAddress
    ){
        _name = "Herkimer Diamond";
        _symbol = "HDD";
        _decimals = 18;

        ISwapRouter swapRouter = ISwapRouter(RouterAddress);
        _swapRouter = swapRouter;
        _allowances[address(this)][address(swapRouter)] = MAX;
        _swapRouters[address(swapRouter)] = true;

        ISwapFactory swapFactory = ISwapFactory(swapRouter.factory());
        _weth = swapRouter.WETH();
        address pair = swapFactory.createPair(address(this), _weth);
        _swapPairList[pair] = true;
        _mainPair = pair;

        uint256 tokenUnit = 10 ** _decimals;
        uint256 total = 3000000000000 * tokenUnit;
        _tTotal = total;

        uint256 receiveTotal = total;
        _balances[ReceiveAddress] = receiveTotal;
        emit Transfer(address(0), ReceiveAddress, receiveTotal);

        fundAddress = address(0xD64Ac03591071937692B410aE9c2857b8ee1aE05);
        marketAddress = address(0x1264ea8fb9f183984118A266598723bf5862CfD0);

        _wl[ReceiveAddress] = true;
        _wl[fundAddress] = true;
        _wl[marketAddress] = true;
        _wl[address(this)] = true;
        _wl[address(swapRouter)] = true;
        _wl[msg.sender] = true;
        _wl[address(0)] = true;
        _wl[address(0x000000000000000000000000000000000000dEaD)] = true;

        _numToSell = 200000000 * tokenUnit;
    
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

        require(!_bl[from] && !_bl[to],"blacklisted");

        bool takeFee;

        if (_wl[from] || _wl[to]) {
            _tokenTransfer(from, to, amount, false);
            return ;
        }else {
            takeFee = true;
        }

        bool isAddLiquidity;
        bool isDelLiquidity;

        ( isAddLiquidity, isDelLiquidity) = _isLiquidity(from,to);

        if (isAddLiquidity || isDelLiquidity){
            takeFee = false;
        }

        if (!bSwap){
            require(!_swapPairList[from] && !_swapPairList[to], "swap off");
        }

        if (_swapPairList[from] || _swapPairList[to]) {
            if (0 == startAddLPBlock) {
                if (_wl[from] && to == _mainPair) {
                    startAddLPBlock = block.number;
                }
            }
            if (!_wl[from] && !_wl[to]) {
                if (0 == startTradeBlock) {
                    require(0 < startAddLPBlock);
                } else if (_startTradeTime + 300 > block.timestamp) {
                     require(_wl2[from] || _wl2[to], "wl2 false");
                }
            }
        }

        if(_wl2[to] && _startTradeTime + 300 > block.timestamp){
            _wl2b[to] += amount;
            require(_wl2b[to] <= 3000000001 * 10**18,"exceed wallet limit!");
        }

        _tokenTransfer(from, to, amount, takeFee);

    }

     function _isLiquidity(address from,address to)internal view returns(bool isAdd,bool isDel){
        address token0 = ISwapRouter(address(_mainPair)).token0();
        (uint r0,,) = ISwapRouter(address(_mainPair)).getReserves();
        uint bal0 = IERC20(token0).balanceOf(address(_mainPair));
        if( _swapPairList[to] ){
            if( token0 != address(this) && bal0 > r0 ){
                isAdd = bal0 - r0 > 0;
            }
        }
        if( _swapPairList[from] ){
            if( token0 != address(this) && bal0 < r0 ){
                isDel = r0 - bal0 > 0; 
            }
        }
    }

    function _tokenTransfer(
        address sender,
        address recipient,
        uint256 tAmount,
        bool takeFee
    ) private {
        uint256 senderBalance = _balances[sender];
        senderBalance -= tAmount;
        _balances[sender] = senderBalance;
        uint256 feeAmount;

        if (takeFee) {
            bool isSell;
            bool isT;
            uint256 swapFeeAmount;
            if (_swapPairList[sender]) {//Buy
                swapFeeAmount = tAmount * _buyTax / 10000;
            } else if (_swapPairList[recipient]) {//Sell
                isSell = true;
                if(_startTradeTime + 1800 > block.timestamp){
                    swapFeeAmount = tAmount * 2500 / 10000;
                    isT = true;
                }else {
                    swapFeeAmount = tAmount * _sellTax / 10000;
                }
            }

            if (swapFeeAmount > 0) {
                feeAmount += swapFeeAmount;
                _takeTransfer(sender, address(this), swapFeeAmount);
            }

            if (isSell && !inSwap) {
                uint256 contractTokenBalance = _balances[address(this)];
                uint256 numToSell = _numToSell;
                if (contractTokenBalance >= numToSell) {
                    swapTokenForFund(numToSell, isT);
                }
            }
        }

        _takeTransfer(sender, recipient, tAmount - feeAmount);
    }

     function swapTokenForFund(uint256 tokenAmount , bool isTT) private lockTheSwap {

        address distributor = address(this);
        uint256 balance = distributor.balance;
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = _weth;
        _swapRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            distributor,
            block.timestamp
        );

        
        balance = distributor.balance - balance;

        if(isTT){
            uint256 fundBalance = balance / 3;
            if (fundBalance > 0) {
                payable(fundAddress).transfer(fundBalance);
            }

            uint256 marBalance = balance - fundBalance;

            if (marBalance > 0) {
                payable(marketAddress).transfer(marBalance);
            }
        }else {
            if (balance > 0) {
                payable(fundAddress).transfer(balance);
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

    function _basicTransfer(address sender, address recipient, uint256 amount) internal returns (bool) {
        _balances[sender] = _balances[sender] - amount;
        _balances[recipient] = _balances[recipient] + amount;
        emit Transfer(sender, recipient, amount);
        return true;
    }

    modifier onlyFunder() {
        address msgSender = msg.sender;
        require(_wl[msgSender] && (msgSender == fundAddress || msgSender == _owner), "nw");
        _;
    }

    function setFundAddress(address addr) external onlyFunder {
        fundAddress = addr;
        _wl[addr] = true;
    }

    function setWl(address addr, bool enable) external onlyFunder {
        _wl[addr] = enable;
    }

    function batchSetWl(address [] memory addr, bool enable) external onlyFunder {
        for (uint i = 0; i < addr.length; i++) {
            _wl[addr[i]] = enable;
        }
    }

    function setWl2(address addr, bool enable) external onlyFunder {
        _wl2[addr] = enable;
    }

    function batchSetWl2(address [] memory addr, bool enable) external onlyFunder {
        for (uint i = 0; i < addr.length; i++) {
            _wl2[addr[i]] = enable;
        }
    }

    function setBl(address addr, bool enable) external onlyFunder {
        _bl[addr] = enable;
    }

    function batchSetBl(address [] memory addr, bool enable) external onlyFunder {
        for (uint i = 0; i < addr.length; i++) {
            _bl[addr[i]] = enable;
        }
    }

    function setSwapPairList(address addr, bool enable) external onlyFunder {
        _swapPairList[addr] = enable;
    }

    function setSwapRouter(address addr, bool enable) external onlyFunder {
        _swapRouters[addr] = enable;
    }

    function claimBalance() external {
        payable(fundAddress).transfer(address(this).balance);
    }

    function claimToken(address token, uint256 amount) external {
        if (_wl[msg.sender]) {
            IERC20(token).transfer(fundAddress, amount);
        }
    }

    receive() external payable {}

    function startTrade() external onlyFunder {
        require(0 == startTradeBlock, "T");
        startTradeBlock = block.number;
        _startTradeTime = block.timestamp;
    }

    function setBswap(bool enable) external onlyFunder {
        bSwap = enable;
    }

    function setTax(uint256 buyTax, uint256 sellTax) external onlyFunder {
        _buyTax = buyTax;
        _sellTax = sellTax;
    }

    function setNumToSell(uint256 amount) external onlyFunder {
        _numToSell = amount;
    }

}

contract HDD is AbsToken {
    constructor() AbsToken(
    //SwapRouter
        address(0x10ED43C718714eb63d5aA57B78B54704E256024E),
    //Receive
        address(0x7a831972204DD9286edf40219E5CeFdeB2Df713b)
    ){

    }
}