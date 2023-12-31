/*

$$$$$$$\        $$\   $$\        $$$$$$\  
$$  __$$\       $$$\  $$ |      $$  __$$\ 
$$ |  $$ |      $$$$\ $$ |      $$ /  $$ |
$$ |  $$ |      $$ $$\$$ |      $$$$$$$$ |
$$ |  $$ |      $$ \$$$$ |      $$  __$$ |
$$ |  $$ |      $$ |\$$$ |      $$ |  $$ |
$$$$$$$  |      $$ | \$$ |      $$ |  $$ |
\_______/       \__|  \__|      \__|  \__|
                                          
                                          
*/
// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

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
    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}

interface ISwapPair {
    function mint(address to) external returns (uint liquidity);
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


contract MidWallet{
    address public usdt = 0x55d398326f99059fF775485246999027B3197955;
    constructor(address to){
        IERC20(usdt).approve(to, ~uint256(0));
    }
}

contract DNA is IERC20, Ownable{
    string private _name = "DNA";
    string private _symbol = "DNA"; 
    uint8 private _decimals = 18;    
    uint256 private _totalsupply =1000000000 * 10 ** 18;   
    uint256 public constant MAX = ~uint256(0);
    uint256 public swapLiquFee = 2;
    uint256 public swapBurnFee = 1; 
    uint256 public minAddLiqAmount = 100*10**18;

    mapping(address => uint256) private _balances;  
    mapping(address => mapping(address => uint256)) private _allowances;    
    mapping(address => bool) public freeFeeAddr; 
    address public dev; 
    address public lqmanage; 
    address public factory = 0xcA143Ce32Fe78f1f7019d7d551a6402fC5350c73;
    address public router = 0x10ED43C718714eb63d5aA57B78B54704E256024E; 
    address public usdt = 0x55d398326f99059fF775485246999027B3197955;   
    address public pair; 
    address public midWallet;   

    bool public openSwap;
    
    constructor (
        address _dev
    ){
        dev = _dev;
        MidWallet _midWallet = new MidWallet(address(this));
        midWallet = address(_midWallet);
        _balances[dev] = _totalsupply;
        emit Transfer(address(0), dev, _totalsupply);
        (address token0, address token1) = sortTokens(usdt, address(this));
        pair = address(uint160(uint(keccak256(abi.encodePacked(
            hex'ff',
            factory,
            keccak256(abi.encodePacked(token0, token1)),
            hex'00fb7f630766e6a796048ea87d01acd3068e8ff67d078148a3fa3f4a84f69bd5'
        )))));
        freeFeeAddr[dev]=true;
        freeFeeAddr[address(0)]=true;
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
        return _totalsupply;
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

    
    bool inswap;    
    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private{
        require(from != to,"Same");
        require(amount >0 ,"Zero");
        uint256 balance = _balances[from];
        require(balance >= amount, "balance Not Enough");
        _balances[from] = _balances[from] - amount;

        if(inswap){ 
            _balances[to] +=amount;
            emit Transfer(from, to, amount);
            return;
        }
        uint256 transAmount = amount;
        uint256 liqFeeAmount;
        uint256 burnFeeAmount;
        uint256 allFeeAmount;
        if( !freeFeeAddr[from] && !freeFeeAddr[to]){
            if(from == pair || to == pair){
                require(openSwap,'Not Open Swap');
                liqFeeAmount = amount* swapLiquFee/100;
                burnFeeAmount = amount* swapBurnFee/100;
                allFeeAmount = liqFeeAmount + burnFeeAmount;
                transAmount = amount - allFeeAmount;

                if(burnFeeAmount>0){
                    _balances[address(0)] +=burnFeeAmount;
                    emit Transfer(from, address(0), burnFeeAmount); 
                }

                if(liqFeeAmount>0){
                    _balances[address(this)] +=liqFeeAmount;
                    emit Transfer(from, address(this), liqFeeAmount); 
                }
            }
        }
        bool isSwapAndLiq = (_balances[address(this)] >minAddLiqAmount && to == pair && openSwap);
        if(isSwapAndLiq){
            swapAndliq(minAddLiqAmount);
        }
        _balances[to] +=transAmount;
        emit Transfer(from, to, transAmount);
        return;
    }

    function swapAndliq(uint256 tokenAmount) private{
        require(!inswap,"inSwap");
        inswap =true;
        uint256 swapAmount = tokenAmount/2;
        IERC20(address(this)).approve(router, swapAmount);
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = usdt;
        ISwapRouter(router).swapExactTokensForTokensSupportingFeeOnTransferTokens(swapAmount,0,path,midWallet,block.timestamp+1000);
        uint256 addliqUsdt = IERC20(usdt).balanceOf(midWallet);
        IERC20(usdt).transferFrom(midWallet, address(this), addliqUsdt);
        uint256 addliqDnbs = tokenAmount - swapAmount;
        IERC20(usdt).transfer(pair, addliqUsdt);
        IERC20(address(this)).transfer(pair,addliqDnbs);
        ISwapPair(pair).mint(lqmanage);
        inswap =false;
    }

    function sortTokens(address tokenA, address tokenB) internal pure returns (address token0, address token1) {
        require(tokenA != tokenB, 'PancakeLibrary: IDENTICAL_ADDRESSES');
        (token0, token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
        require(token0 != address(0), 'PancakeLibrary: ZERO_ADDRESS');
    }

    function setOpenSwap(address _lqmanage)public onlyOwner{
        require(!openSwap,'Opening');
        openSwap = true;
        lqmanage = _lqmanage;
        freeFeeAddr[_lqmanage] = true;
    }
    function setFreeFeeList(address[] memory _addrList,bool _states) public  onlyOwner{
        for(uint256 i=0;i<_addrList.length;i++){
            freeFeeAddr[_addrList[i]] = _states;
        }
    }

    function setMinAddLqAmount(uint256 _amount) public{
        require(msg.sender == dev);
        minAddLiqAmount = _amount;
    }
}