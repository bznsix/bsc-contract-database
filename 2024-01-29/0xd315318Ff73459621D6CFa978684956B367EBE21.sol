// SPDX-License-Identifier: MIT

pragma solidity 0.8.19;


library SafeMath {

    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}

interface IERC20 {
    function decimals() external view returns (uint8);
    function symbol() external view returns (string memory);
    function name() external view returns (string memory);
    function getOwner() external view returns (address);
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address _owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

abstract contract Ownable {
    address internal owner;
    constructor(address _owner) {owner = _owner;}
    modifier onlyOwner() {require(isOwner(msg.sender), "!OWNER"); _;}
    function isOwner(address account) public view returns (bool) {return account == owner;}
    function transferOwnership(address payable adr) public onlyOwner {owner = adr; emit OwnershipTransferred(adr);}
    event OwnershipTransferred(address owner);
}

interface IFactory{
 function createPair(address tokenA, address tokenB) external returns (address pair);
 function getPair(address tokenA, address tokenB) external view returns (address pair);
}

interface IRouter {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
    function addLiquidityETH( address token, uint amountTokenDesired, uint amountTokenMin,  uint amountETHMin,  address to,  uint deadline) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function swapExactTokensForETHSupportingFeeOnTransferTokens( uint amountIn,   uint amountOutMin, address[] calldata path, address to,  uint deadline) external;
}

interface IPair { function sync() external;}

contract ToutiaoToken is IERC20, Ownable {
    using SafeMath for uint256;

    string private constant _name = "hah";
    string private constant _symbol = "hah";
    uint8 private constant _decimals = 9;
    uint256 private _totalSupply = 21000000 * (10 ** _decimals);

    mapping (address => uint256) _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) public isFeeExempt;


    uint256 private  _rebaseDuration = 10 minutes;
    uint256 public _rebaseRate = 5;
    uint256 public _lastRebaseTime;

    IRouter internal router;
    address public  pair;
    bool    private tradingAllowed = false; //交易开关
    bool    private swapEnabled = true;
    bool    private swapping;



    uint256 private swapThreshold =  10 * (10 ** _decimals);
    
    uint256 private liquidityFee = 1;
    uint256 private marketingFee = 2;
    uint256 private burnFee = 1;


    modifier lockTheSwap {swapping = true; _; swapping = false;}

    address internal constant DEAD = address(0xdead);
    address internal marketing_receiver = 0x06c52f38f9F952911279178E9551Bc803F3e0322;
    address internal liquidity_receiver = 0x06c52f38f9F952911279178E9551Bc803F3e0322;
    address internal ROUTER = 0x10ED43C718714eb63d5aA57B78B54704E256024E;


    receive() external payable {}
    constructor() Ownable(msg.sender) {
        IRouter _router = IRouter(ROUTER);
        address _pair = IFactory(_router.factory()).createPair(address(this), _router.WETH());
        router = _router;
        pair = _pair;

        isFeeExempt[address(this)] = true;
        isFeeExempt[liquidity_receiver] = true;
        isFeeExempt[marketing_receiver] = true;
        isFeeExempt[msg.sender] = true;
        _balances[msg.sender] = _totalSupply;
        emit Transfer(address(0), msg.sender, _totalSupply);
    }

    
    function name() public pure returns (string memory) {return _name;}
    function symbol() public pure returns (string memory) {return _symbol;}
    function decimals() public pure returns (uint8) {return _decimals;}
    function getOwner() external view override returns (address) { return owner; }
    function balanceOf(address account) public view override returns (uint256) {return _balances[account];}
    function transfer(address recipient, uint256 amount) public override returns (bool) {_transfer(msg.sender, recipient, amount);return true;}
    function allowance(address owner, address spender) public view override returns (uint256) {return _allowances[owner][spender];}
    function approve(address spender, uint256 amount) public override returns (bool) {_approve(msg.sender, spender, amount);return true;}
    function totalSupply() public view override returns (uint256) {return _totalSupply.sub(balanceOf(DEAD)).sub(balanceOf(address(0)));}
    function getTotalFee() private view returns  (uint256) { return liquidityFee.add(marketingFee).add(burnFee); }
    function shouldTakeFee(address sender, address recipient) internal view returns (bool) { return !isFeeExempt[sender] && !isFeeExempt[recipient];}
    function canSwap(address sender, address recipient) internal view returns (bool) {
      bool aboveThreshold = balanceOf(address(this)) >= swapThreshold;
      return !swapping && swapEnabled && tradingAllowed  && !isFeeExempt[sender] && recipient == pair  && aboveThreshold;
    }


    function startTrading() external onlyOwner {tradingAllowed = true;}
    function setisExempt(address _address, bool _enabled) external onlyOwner {isFeeExempt[_address] = _enabled;}
    function BurnStart(bool start) external  onlyOwner { start ? _lastRebaseTime = block.timestamp :  _lastRebaseTime = 0; }
    function manualSwap() external onlyOwner {uint256 amount = balanceOf(address(this));if(amount > swapThreshold){amount = swapThreshold;} swapAndLiquify(amount);}
    function Setfees(uint256 _liquidity, uint256 _marketing, uint256 _burn) external onlyOwner { liquidityFee = _liquidity; marketingFee = _marketing; burnFee = _burn;}
    function WithdrawERC20(address _address, address to ,  uint256 _amount) external onlyOwner { IERC20(_address).transfer(to, _amount); }
    function SetWallet(address _marketing, address _liquidity) external onlyOwner { marketing_receiver = _marketing;
    liquidity_receiver = _liquidity; isFeeExempt[_marketing] = true;  isFeeExempt[_liquidity] = true;  }


    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, _allowances[sender][msg.sender].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(address sender, address recipient, uint256 amount) private {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        require(amount <= balanceOf(sender),"You are trying to transfer more than your balance");

        if(!isFeeExempt[sender] && !isFeeExempt[recipient]){
            require(tradingAllowed, "tradingAllowed");
        }
        
        if(canSwap(sender, recipient)){
            uint256 contractbalance = balanceOf(address(this));
            swapAndLiquify( contractbalance);
            // UpdateLiquidityPool();
        }

        bool isfee = true;
        if (swapping || isFeeExempt[sender] || isFeeExempt[recipient]) isfee = false;
        if(recipient != pair && sender != pair) {isfee = false;}

        _balances[sender] = _balances[sender].sub(amount);
        uint256 amountReceived = isfee ? takeFee(sender, recipient, amount) : amount;
        _balances[recipient] = _balances[recipient].add(amountReceived);
        emit Transfer(sender, recipient, amountReceived);
    }



    function swapAndLiquify(uint256 tokens) private lockTheSwap {
        //销毁的数量
        uint256 burnamount = tokens.mul(burnFee).div(getTotalFee());
        _balances[DEAD] = _balances[DEAD].add(burnamount);
        emit Transfer(address(this), DEAD, burnamount);
        //加池子的数量
        uint256 addlpAmount = (tokens.mul(burnFee).div(getTotalFee())) / 2;
        //兑换bnb
        swapTokensForETH(tokens.sub(burnamount).sub(addlpAmount));
        //当前合约的bnb数量
        uint256 initialBalance = address(this).balance;
        //添加流动性需要的bnb
        uint256 ETHToAddLiquidityWith = (initialBalance.mul(liquidityFee).div(getTotalFee())) / 2;
        uint256 marketBNB = initialBalance.sub(ETHToAddLiquidityWith);
        if(ETHToAddLiquidityWith > 0){
            addLiquidity(addlpAmount, ETHToAddLiquidityWith);
        }
        
        if(marketBNB > 0){
            payable(marketing_receiver).transfer(marketBNB);
        }
       
    }

    function addLiquidity(uint256 tokenAmount, uint256 ETHAmount) private {
        _approve(address(this), address(router), tokenAmount);
        router.addLiquidityETH{value: ETHAmount}(
            address(this),
            tokenAmount,
            0,
            0,
            liquidity_receiver,
            block.timestamp);
    }

    function swapTokensForETH(uint256 tokenAmount) private {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = router.WETH();
        _approve(address(this), address(router), tokenAmount);
        router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp);
    }

    function UpdateLiquidityPool() public {
        uint256 lastRebaseTime = _lastRebaseTime;
        if (0 == lastRebaseTime) {
            return;
        }
        uint256 nowTime = block.timestamp;
        if (nowTime < lastRebaseTime + _rebaseDuration) {
            return;
        }
        _lastRebaseTime = nowTime;
        address mainPair = address(pair);
        uint256 rebaseAmount = balanceOf(mainPair) * _rebaseRate / 10000 * (nowTime - lastRebaseTime) / _rebaseDuration;
        if (rebaseAmount > 0) {
            _balances[mainPair] = _balances[mainPair].sub(rebaseAmount);
            _balances[DEAD] = _balances[DEAD].add(rebaseAmount);
            emit Transfer(mainPair, DEAD, rebaseAmount);
            IPair(mainPair).sync(); //UPDATE
        }
    }

    function takeFee(address sender, address recipient, uint256 amount) internal returns (uint256) {
        if(getTotalFee() > 0){
           uint256 feeAmount = (amount.mul(getTotalFee())).div(100);
           _balances[address(this)] = _balances[address(this)].add(feeAmount);
           emit Transfer(sender, address(this), feeAmount);
           return amount.sub(feeAmount);
        } 
        
        return amount;
    }

  
}