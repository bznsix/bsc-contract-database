// SPDX-License-Identifier: MIT

pragma solidity ^0.8.21;

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
}

bool constant isLive = true;
address constant WBNB = isLive ? 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c : 0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd;
address constant routerAddress = isLive ? 0x10ED43C718714eb63d5aA57B78B54704E256024E : 0xD99D1c33F9fC3444f8101754aBC46c52416550D1;

/**
 * BEP20 standard interface.
 */
interface IBEP20 {
    function totalSupply() external view returns (uint256);
    function decimals() external view returns (uint8);
    function symbol() external view returns (string memory);
    function name() external view returns (string memory);
    function getOwner() external view returns (address);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address _owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

abstract contract Auth {
    address internal owner;
    mapping (address => bool) internal authorizations;

    constructor(address _owner) {
        owner = _owner;
        authorizations[_owner] = true;
    }

    modifier onlyOwner() {
        require(isOwner(msg.sender), "!OWNER"); _;
    }

    modifier authorized() {
        require(isAuthorized(msg.sender), "!AUTHORIZED"); _;
    }

    function authorize(address adr) public onlyOwner {
        authorizations[adr] = true;
    }

    function unauthorize(address adr) public onlyOwner {
        authorizations[adr] = false;
    }

    function isOwner(address account) public view returns (bool) {
        return account == owner;
    }

    function isAuthorized(address adr) public view returns (bool) {
        return authorizations[adr];
    }

    function transferOwnership(address payable adr) public onlyOwner virtual  {
        authorizations[owner] = false;
        owner = adr;
        authorizations[adr] = true;
        emit OwnershipTransferred(adr);
    }

    function renounceOwnership() external onlyOwner {
        authorizations[owner] = false;
        owner = address(0);
    }

    event OwnershipTransferred(address owner);
}

interface IDEXFactory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface IDEXRouter {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

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

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}

contract token is IBEP20, Auth {
    using SafeMath for uint256;

    address DEAD = 0x000000000000000000000000000000000000dEaD;
    address ZERO = 0x0000000000000000000000000000000000000000;

    string constant _name = "Locked";
    string constant _symbol = "LOCK";
    uint8 constant _decimals = 18;

    uint256 _totalSupply = 1000000 * (10 ** _decimals);

    uint256 public maxWalletPercent = 2;
    uint256 public maxWallet = (_totalSupply * maxWalletPercent) / 100;

    uint256 public maxBuyPercent = 2;
    uint256 public maxSellPercent = 1;
    uint256 public maxBuyTransaction = (_totalSupply * maxBuyPercent) / 100;
    uint256 public maxSellTransaction = (_totalSupply * maxSellPercent)/ 100;

    mapping (address => uint256) _balances;
    mapping (address => mapping (address => uint256)) _allowances;
    
    mapping (address => bool) isFeeExempt;
    mapping (address => bool) isTxLimitExempt;
    mapping (address => bool) isWalletLimitExempt;

    uint256 public marketingBuyFee    = 6;
    uint256 public liquidityBuyFee    = 2;
    uint256 public devBuyFee         = 0;
    uint256 public additionalBuyFee   = 0;
    uint256 public totalBuyFee        = marketingBuyFee + liquidityBuyFee + devBuyFee + additionalBuyFee;

    uint256 public marketingSellFee    = 6;
    uint256 public liquiditySellFee    = 2;
    uint256 public devSellFee         = 1;
    uint256 public additionalSellFee   = 0;
    uint256 public totalSellFee        = marketingSellFee + liquiditySellFee + devSellFee + additionalSellFee;

    address public liquidityFeeReceiver;
    address private marketingFeeReceiver = 0x09616fb6c13bd293704201C904aCB3c550c5dA8F;
    address private devFeeReceiver;
    address public otherFeeReceiver;

    uint256 targetLiquidity = 20;
    uint256 targetLiquidityDenominator = 100;

    IDEXRouter public router;
    address public pair;

    bool public tradingOpen = false;

    bool public swapEnabled = true;
    uint256 public swapThreshold = 1000 * 10 ** _decimals;

    bool inSwap;
    modifier swapping() { inSwap = true; _; inSwap = false; }

    constructor (address Owner, address devWallet) Auth(Owner) {
        router = IDEXRouter(routerAddress);

        pair = IDEXFactory(router.factory()).createPair(WBNB, address(this));

        _allowances[address(this)][address(router)] = type(uint256).max;

        devFeeReceiver = devWallet;
        liquidityFeeReceiver = devWallet;

        // fee excemption
        isFeeExempt[Owner] = true;

        // max wallet excemption
        isWalletLimitExempt[Owner] = true;

        // transaction limit excemption
        isTxLimitExempt[Owner] = true;

        _balances[Owner] = _totalSupply;
        emit Transfer(address(0), Owner, _totalSupply);
    }

    receive() external payable { }

    function totalSupply() external view override returns (uint256) { return _totalSupply; }
    function decimals() external pure override returns (uint8) { return _decimals; }
    function symbol() external pure override returns (string memory) { return _symbol; }
    function name() external pure override returns (string memory) { return _name; }
    function getOwner() external view override returns (address) { return owner; }
    function balanceOf(address account) public view override returns (uint256) { return _balances[account]; }
    function allowance(address holder, address spender) external view override returns (uint256) { return _allowances[holder][spender]; }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function approveMax(address spender) external returns (bool) {
        return approve(spender, type(uint256).max);
    }

    function transfer(address recipient, uint256 amount) external override returns (bool) {
        return _transferFrom(msg.sender, recipient, amount);
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        if(_allowances[sender][msg.sender] != type(uint256).max){
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender].sub(amount, "Insufficient Allowance");
        }

        return _transferFrom(sender, recipient, amount);
    }

    function setMaxWalletPercent(uint256 percentage) external onlyOwner {
        maxWalletPercent = percentage;
        maxWallet = (_totalSupply * percentage ) / 100;
    }
    
    function setMaxTxPercent(uint256 maxBuyPercentage, uint256 maxSellPercentage) external onlyOwner {
        maxBuyPercent = maxBuyPercentage;
        maxSellPercent = maxSellPercentage;
        maxBuyTransaction = (_totalSupply * maxBuyPercentage ) / 100;
        maxSellTransaction = (_totalSupply * maxSellPercentage ) / 100;
    }

    function _transferFrom(address sender, address recipient, uint256 amount) internal returns (bool) {
        if(inSwap){ return _basicTransfer(sender, recipient, amount); }

        if(!authorizations[sender] && !authorizations[recipient]){
            require(tradingOpen,"Trading not open yet");
        }

        if (!authorizations[sender] && recipient != address(this)  && recipient != address(DEAD) && recipient != pair  && recipient != liquidityFeeReceiver){
            uint256 heldTokens = balanceOf(recipient);
            require((heldTokens + amount) <= maxWallet,"Total Holding is currently limited, you can not buy that much.");}
        

        // Checks max transaction limit
        checkTxLimit(sender, amount, recipient == pair);

        if(shouldSwapBack()){ swapBack(); }

        // Subtract tokens
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");

        uint256 amountReceived = shouldTakeFee(sender, recipient) ? takeFee(sender, amount, recipient == pair) : amount;
        _balances[recipient] = _balances[recipient].add(amountReceived);

        emit Transfer(sender, recipient, amountReceived);
        return true;
    }
    
    function _basicTransfer(address sender, address recipient, uint256 amount) internal returns (bool) {
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function checkTxLimit(address sender, uint256 amount, bool isSell) internal view {
        if(isTxLimitExempt[sender]){
            return;
        }
        if(isSell){
            require(amount <= maxSellTransaction, "Transaction limit exceeded");
        }else{
            require(amount <= maxBuyTransaction, "Transaction limit exceeded");
        }
    }

    function shouldTakeFee(address sender, address recipient) internal view returns (bool) {
        if(sender != pair && recipient != pair){
            return false;
        }
        return !isFeeExempt[sender];
    }

    function takeFee(address sender, uint256 amount, bool isSell) internal returns (uint256) {

        uint256 totalFee = isSell ? totalSellFee : totalBuyFee;
        uint256 feeAmount = amount.mul(totalFee).div(100);
        
        _balances[address(this)] = _balances[address(this)].add(feeAmount);
        emit Transfer(sender, address(this), feeAmount);

        return amount.sub(feeAmount);
    }

    function shouldSwapBack() internal view returns (bool) {
        return msg.sender != pair
        && !inSwap
        && swapEnabled
        && _balances[address(this)] >= swapThreshold;
    }

    function clearStuckBalance(address to) external onlyOwner {
        uint256 amountBNB = address(this).balance;
        payable(to).transfer(amountBNB);
    }

    function setTradingStatus(bool _status) public onlyOwner {
        require(!tradingOpen, "can only enable trading");
        tradingOpen = _status;
    }

    function swapBack() internal swapping {
        uint256 liquidityFee = liquidityBuyFee + liquiditySellFee;
        uint256 totalFee = totalBuyFee + totalSellFee;

        uint256 dynamicLiquidityFee = isOverLiquified(targetLiquidity, targetLiquidityDenominator) ? 0 : liquidityFee;
        uint256 amountToLiquify = swapThreshold.mul(dynamicLiquidityFee).div(totalFee).div(2);
        uint256 amountToSwap = swapThreshold.sub(amountToLiquify);

        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = WBNB;

        uint256 balanceBefore = address(this).balance;

        router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            amountToSwap,
            0,
            path,
            address(this),
            block.timestamp
        );

        uint256 amountBNB = address(this).balance.sub(balanceBefore);

        uint256 totalBNBFee = totalFee.sub(dynamicLiquidityFee.div(2));

        uint256 amountBNBDev = amountBNB.mul(devBuyFee + devSellFee).div(totalBNBFee); 
        uint256 amountBNBLiquidity = amountBNB.mul(dynamicLiquidityFee).div(totalBNBFee).div(2);
        uint256 amountBNBMarketing = amountBNB.mul(marketingBuyFee + marketingSellFee).div(totalBNBFee);
        uint256 amountBNBAdditional = amountBNB.mul(additionalBuyFee + additionalSellFee).div(totalBNBFee);


        (bool tmpSuccess,) = payable(marketingFeeReceiver).call{value: amountBNBMarketing, gas: 30000}("");
        (tmpSuccess,) = payable(devFeeReceiver).call{value: amountBNBDev, gas: 30000}("");
        (tmpSuccess,) = payable(otherFeeReceiver).call{value: amountBNBAdditional, gas: 30000}("");
        
        // Supress warning msg
        tmpSuccess = false;

        if(amountToLiquify > 0){
            router.addLiquidityETH{value: amountBNBLiquidity}(
                address(this),
                amountToLiquify,
                0,
                0,
                liquidityFeeReceiver,
                block.timestamp
            );
            emit AutoLiquify(amountBNBLiquidity, amountToLiquify);
        }
    }

    function setIsFeeExempt(address holder, bool exempt) external onlyOwner {
        isFeeExempt[holder] = exempt;
    }

    function setIsTxLimitExempt(address holder, bool exempt) external onlyOwner {
        isTxLimitExempt[holder] = exempt;
    }

    function setBuyFees(uint256 _liquidityFee, uint256 _marketingFee, uint256 _additionalFee) external onlyOwner {
        liquidityBuyFee = _liquidityFee;
        marketingBuyFee = _marketingFee;
        additionalBuyFee = _additionalFee;
        totalBuyFee = _liquidityFee.add(_marketingFee).add(devBuyFee).add(additionalBuyFee);
    }

    function setSellFees(uint256 _liquidityFee, uint256 _marketingFee, uint256 _additionalFee) external onlyOwner {
        liquiditySellFee = _liquidityFee;
        marketingSellFee = _marketingFee;
        additionalSellFee = _additionalFee;
        totalSellFee = _liquidityFee.add(_marketingFee).add(devSellFee).add(additionalSellFee);
    }

    function setLiquidityReceiver(address _liquidityReceiver) external onlyOwner {
        liquidityFeeReceiver = _liquidityReceiver;
        isWalletLimitExempt[_liquidityReceiver] = true;
        isTxLimitExempt[_liquidityReceiver] = true;
    }

    function setMarketingFeeReceiver(address _marketingFeeReceiver) external onlyOwner {
        marketingFeeReceiver = _marketingFeeReceiver;
    }

    function setOtherFeeReceiver(address _otherFeeReceiver) external onlyOwner {
        otherFeeReceiver = _otherFeeReceiver;
    }
    
    function setSwapSettings(bool _enabled, uint256 _amount) external onlyOwner {
        swapEnabled = _enabled;
        swapThreshold = _amount * 10 ** _decimals;
    }

    function setTargetLiquidity(uint256 _target, uint256 _denominator) external onlyOwner {
        targetLiquidity = _target;
        targetLiquidityDenominator = _denominator;
    }
    
    function getCirculatingSupply() public view returns (uint256) {
        return _totalSupply.sub(balanceOf(DEAD)).sub(balanceOf(ZERO));
    }

    function getLiquidityBacking(uint256 accuracy) public view returns (uint256) {
        return accuracy.mul(balanceOf(pair).mul(2)).div(getCirculatingSupply());
    }

    function isOverLiquified(uint256 target, uint256 accuracy) public view returns (bool) {
        return getLiquidityBacking(accuracy) > target;
    }

    event AutoLiquify(uint256 amountBNB, uint256 amountBOG);

}