/**
 *
 * Website: www.grokjesus.vip 
 * Twitter (X) : https://x.com/grokjesus
 * Telegram : https://t.me/GrokJesus
 * 
*/

// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.18;

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

interface BEP20 {
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
    address internal potentialOwner;

    constructor(address _owner) {
        owner = _owner;
    }

    modifier onlyOwner() {
        require(isOwner(msg.sender), "!OWNER"); _;
    }

    function isOwner(address account) public view returns (bool) {
        return account == owner;
    }


    function transferOwnership(address payable adr) external onlyOwner {
        require(adr != owner, "Already the owner");
        require(adr != address(0), "Can not be zero address.");
        potentialOwner = adr;
        emit OwnershipNominated(adr);
    }

    function renounceOwnership() external onlyOwner {
        owner = address(0);
        emit OwnershipTransferred(owner);
    }

    function acceptOwnership() external {
        require(msg.sender == potentialOwner, "You must be nominated as potential owner before you can accept the role.");
        owner = potentialOwner;
        potentialOwner = address(0);
        emit OwnershipTransferred(owner);
    }

    event OwnershipTransferred(address owner);
    event OwnershipNominated(address potentialOwner);
}

interface IDEXFactory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface IDEXRouter {
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

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}

contract GrokJesus is BEP20, Auth {
    using SafeMath for uint256;

    address immutable WBNB;
    address constant DEAD = 0x000000000000000000000000000000000000dEaD;
    address constant ZERO = 0x0000000000000000000000000000000000000000;

    string public constant name = "Grok Jesus";
    string public constant symbol = "Grok Jesus";
    uint8 public constant decimals = 18;

    uint256 public constant totalSupply = 7_777_777_777 * 10**decimals;

    mapping (address => uint256) public balanceOf;
    mapping (address => mapping (address => uint256)) _allowances;

    mapping (address => bool) public isFeeExempt;

    uint256 sellFees = 3;
    uint256 buyFees = 3;
    uint256 transferFees = 0;
    uint256 public constant feeDenominator = 100;

    address public marketingFeeReceiver;

    IDEXRouter public router;
    address public immutable pair;

    bool public tradingOpen = false;
    bool public swapEnabled = false;
    uint256 public swapThreshold = totalSupply / 1000;
    bool inSwap;
    modifier swapping() { inSwap = true; _; inSwap = false; }

    constructor () Auth(msg.sender) {
        router = IDEXRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        WBNB = router.WETH();

        pair = IDEXFactory(router.factory()).createPair(WBNB, address(this));
        _allowances[address(this)][address(router)] = type(uint256).max;

        marketingFeeReceiver = 0x2fef87D4840f531463ddd47d5B10bF378025eD1E;

        isFeeExempt[msg.sender] = true;
        isFeeExempt[marketingFeeReceiver] = true;

        balanceOf[msg.sender] = totalSupply;
        emit Transfer(address(0), msg.sender, totalSupply);
    }

    receive() external payable { }

    function getOwner() external view override returns (address) { return owner; }
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

    function _transferFrom(address sender, address recipient, uint256 amount) internal returns (bool) {
        if(inSwap){ return _basicTransfer(sender, recipient, amount); }

        if(!isFeeExempt[sender] && !isFeeExempt[recipient]){
            require(tradingOpen,"Trading not open yet");
        }

        if(shouldSwapBack()){ swapBack(); }

        balanceOf[sender] = balanceOf[sender].sub(amount, "Insufficient Balance");

        uint256 amountReceived = (isFeeExempt[sender] || isFeeExempt[recipient]) ? amount : takeFee(sender, amount, recipient);

        balanceOf[recipient] = balanceOf[recipient].add(amountReceived);

        emit Transfer(sender, recipient, amountReceived);
        return true;
    }
    
    function _basicTransfer(address sender, address recipient, uint256 amount) internal returns (bool) {
        balanceOf[sender] = balanceOf[sender].sub(amount, "Insufficient Balance");
        balanceOf[recipient] = balanceOf[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function takeFee(address sender, uint256 amount, address recipient) internal returns (uint256) {
        if(amount == 0){
            return amount;
        }

        uint256 multiplier = transferFees;

        if(recipient == pair) {
            multiplier = sellFees;
        } else if(sender == pair) {
            multiplier = buyFees;
        }

        uint256 feeAmount = amount.mul(multiplier).div(feeDenominator);

        if(feeAmount > 0){
            balanceOf[address(this)] = balanceOf[address(this)].add(feeAmount);
            emit Transfer(sender, address(this), feeAmount);
        }
        
        return amount.sub(feeAmount);
    }

    function shouldSwapBack() internal view returns (bool) {
        return msg.sender != pair
        && !inSwap
        && swapEnabled
        && balanceOf[address(this)] >= swapThreshold;
    }

    function clearStuckBalance(uint256 amountPercentage) external onlyOwner {
        require(amountPercentage <= 100, "Max 100%");
        uint256 amountBNB = address(this).balance;
        uint256 amountToClear = ( amountBNB * amountPercentage ) / 100;
        payable(msg.sender).transfer(amountToClear);
    }

    function clearStuckToken(address tokenAddress, uint256 tokens) external onlyOwner returns (bool success) {
        require(tokenAddress != address(this), "Cannot withdraw native token");

        if(tokens == 0){
            tokens = BEP20(tokenAddress).balanceOf(address(this));
        }

        return BEP20(tokenAddress).transfer(msg.sender, tokens);
    }

    function goLive() external onlyOwner {
        tradingOpen = true;
        swapEnabled = true;
    }

    function swapBack() internal swapping {
        uint256 amountToSwap = swapThreshold;
        bool success;

        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = WBNB;

        router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            amountToSwap,
            0,
            path,
            address(this),
            block.timestamp
        );

        (success,) = payable(marketingFeeReceiver).call{value: address(this).balance}("");
    }

    function manage_FeeExempt(address[] calldata addresses, bool status) external onlyOwner {
        require(addresses.length < 501,"GAS Error: max limit is 500 addresses");
        for (uint256 i=0; i < addresses.length; ++i) {
            isFeeExempt[addresses[i]] = status;
        }
    }

    function setFees(uint256 _buy, uint256 _sell, uint256 _trans) external onlyOwner {
        require(_sell <= 3, "Buy tax cannot be more than 3%");
        require(_buy <= 3, "Sell tax cannot be more than 3%");
        require(_trans <= 3, "Transfer Tax cannot be more than 3%");

        sellFees = _sell;
        buyFees = _buy;
        transferFees = _trans;
    }

    function setFeeReceivers(address _marketingFeeReceiver) external onlyOwner {
        require(_marketingFeeReceiver != address(0),"Marketing fee address cannot be zero address");
        marketingFeeReceiver = _marketingFeeReceiver;
    }

    function setSwapBackSettings(bool _enabled, uint256 _denominator) external onlyOwner {
        require( _denominator >= 100, "Max swapback can be 1% of supply");
        require( _denominator <= 10000, "Min swapback can be 0.01% of supply");

        swapEnabled = _enabled;
        swapThreshold = totalSupply/_denominator;
    }

    function getCirculatingSupply() public view returns (uint256) {
        return (totalSupply - balanceOf[DEAD] - balanceOf[ZERO]);
    }

}