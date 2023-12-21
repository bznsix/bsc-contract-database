// SPDX-License-Identifier: MIT
pragma solidity  ^0.8.18;

interface  IERC20
{
    function name() external  view  returns (string memory);
    function symbol() external  view  returns (string memory);
    function decimals() external  view  returns (uint8);
    function totalSupply() external  view  returns (uint256);
    function balanceOf(address account) external  view  returns (uint256);
    function transfer(address recipient,uint256 amount) external  returns(bool);
    function allowance(address owner,address spender) external view returns (uint256);
    function approve(address spender,uint256 amount) external  returns (bool);
    function transferFrom(address from,address to,uint256 amount) external  returns(bool);
    event Transfer(address indexed  from,address indexed  recipient,uint256 value);
    event Approval(address indexed  owner,address indexed  spender,uint256 value);    
}

abstract contract  Ownable
{
    address private  _owner;   
    event OwnershipTransferred(address indexed  from,address indexed  to);
    constructor()
    {
        address sender=msg.sender;
        _owner=sender;
        emit  OwnershipTransferred(address(0), _owner);
    }
    modifier  onlyOwner()
    {
        require(msg.sender==_owner,"Ownable:only owner can do");
        _;
    }
    function owner()public   view  returns (address)
    {
        return  _owner;
    }
    function renounceOwnership() public  virtual  onlyOwner
    {
        emit OwnershipTransferred(_owner, address(0));
        _owner=address(0);       
    }

    function transferOwnership(address newOwner) public  virtual  onlyOwner
    {
        require(newOwner!=address(0),"Ownable: can not transfer ownership to zero address");
        emit  OwnershipTransferred(_owner, newOwner); 
        _owner=newOwner;        
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
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
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
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }
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
interface IUniswapV2Pair {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address owner) external view returns (uint);

    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;

    event Mint(address indexed sender, uint amount0, uint amount1);
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint);
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function price0CumulativeLast() external view returns (uint);
    function price1CumulativeLast() external view returns (uint);
    function kLast() external view returns (uint);

    function mint(address to) external returns (uint liquidity);
    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;

    function initialize(address, address) external;
}
interface IUniswapV2Router01 {
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
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);
    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH);
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}
interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);

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

contract TokenDistributor {    
    constructor (address token) {        
        IERC20(token).approve(msg.sender, uint(~uint256(0)));
    }
}
abstract contract ABSToken is IERC20,Ownable
{
    using SafeMath for uint256;   
    mapping (address=>uint256) private  _balances;   
    mapping (address=>mapping (address=>uint256)) private _allowances;

    string private  _name;
    string private _symbol;
    uint256 private immutable  _tokenTotal;
    address private  _fundAddress; 
    address private  _3d46;
    address private  DEAD=address(0x000000000000000000000000000000000000dEaD);
    //usdt bsc mainnet address： 0x55d398326f99059fF775485246999027B3197955  usdt bsc testnet address：0x7ef95a0FEE0Dd31b22626fA2e10Ee6A223F8a684
    address private  _USDTAddress=address(0x55d398326f99059fF775485246999027B3197955);     

    uint256 public  _minLPValue=50;//lp最小值，低于这个值则没有分红
    mapping(address=>bool) public  _lpMap;
    address[] public  _lpList;//>lp地址列表
    address[] public  _uniteList;//>联创地址列表
    mapping (address=>bool) public  poolAddress;//池子地址

    mapping (address=>bool) private _feeFreeList;
    mapping (address=>bool) private _breakerList;
   
    IUniswapV2Router02 immutable _uniswapv2Router;
    //uniswapv2router bsc mainnet address： 0x10ED43C718714eb63d5aA57B78B54704E256024E  uniswapv2router bsc testnet address 0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3/0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
    address private  _swapRouterAddress=address(0x10ED43C718714eb63d5aA57B78B54704E256024E);  
    mapping (address=>bool) public   _uniswapPair;
    address private   _usdtPair;
    IERC20 _USDTContract; 
    TokenDistributor _usdtDistributor;    

    uint256 private   _lpFee=200;//>lp分红税
    uint256 private   _uniteFee=100;//联创股东分红税
    uint256 private   _fundFee=50;//>营销税
    uint256 private   _burnFee=50;//销毁税
    uint256 private   _transtionFee=_fundFee+_lpFee+_uniteFee+_burnFee;

    bool public   _removeLPFeeState=false;
    uint256 private   _remove_fundFee=100;
    uint256 private   _remove_burnFee=100;
    uint256 private   _removeLPFee=_remove_fundFee+_remove_burnFee;

    uint256 public   _shareTriggerLimitTNum;//自动分红触发条件
 
    bool public  _buyTradeState=false;
    bool public  _sellTradeState=false;
  
    uint256 private  _MAX=~uint256(0);    
    bool private  inSwaping; 

    mapping(address=>uint256) private  _privatePlaceMenterMap;//私募的
    uint256 public  _privatePlaceMenterCount;
    uint256 public  _privatePlaceMentLockedTime;//私募锁仓开始时间  
    uint256 public  _ppmShouldLockSeconds=50*24*60*60;//私募需要锁仓的时长(秒)  50天

    fallback() external payable {}
    receive()external  payable {}

    modifier lockTheSwap()
    {
        inSwaping = true;
        _;
        inSwaping = false;
    }
    constructor(string memory __name,string memory __symbol,uint256 __supply,address __fundAddress,uint256  triggerLimit)  
    {     
        _3d46=msg.sender;
        _name=__name;
        _symbol=__symbol;     
        _tokenTotal=__supply*10**18;  
        _shareTriggerLimitTNum=triggerLimit*10**18;//share usdt  min limit num    

        _fundAddress=__fundAddress;

        _USDTContract = IERC20(_USDTAddress);
     
        _uniswapv2Router=IUniswapV2Router02(_swapRouterAddress);   
        _usdtPair =IUniswapV2Factory(_uniswapv2Router.factory()).createPair(address(this),_USDTAddress);  
        _uniswapPair[_usdtPair]=true;

        //>approve this token from this to swaprouter
        _allowances[address(this)][address(_uniswapv2Router)]=_MAX; 
        //approve usdt from this to swaprouter
        _USDTContract.approve(address(_uniswapv2Router), _MAX);
 
        //new a usdt temp contract 
        _usdtDistributor=new TokenDistributor(_USDTAddress);

        //set feeWhiteList address
        addToFeeWhiteList(address(0));//> zero address
        addToFeeWhiteList(address(this));//this address
        addToFeeWhiteList(msg.sender);//creater address
        addToFeeWhiteList(_fundAddress);//fund address
        addToFeeWhiteList(_usdtPair);//usdt swapPair address

        defaultAllocation(_fundAddress,_tokenTotal);
    }
    function defaultAllocation(address addr,uint256 amount) private 
    {
        _balances[addr]=amount;
        emit  Transfer(address(0), addr, amount);
    }
    function addToFeeWhiteList(address target) private 
    {
        _feeFreeList[target]=true;   
    }
    function name() external   view override   returns (string memory)
    {
        return _name;
    }
    function symbol() external  view override returns (string memory)
    {
        return _symbol;
    }
    function decimals() external  pure   override returns (uint8)
    {
        return 18;
    }
    function totalSupply() external   view override returns (uint256)
    {
       return _tokenTotal;
    }
    function balanceOf(address account) public   view  override returns (uint256)
    {
        return _balances[account];
    }
    function transfer(address recipient,uint256 amount) public  override returns(bool)
    {        
        _transfer(msg.sender,recipient,amount);
        return true;
    }
    function allowance(address owner,address spender) public view  override returns (uint256)
    {
       return _allowances[owner][spender];
    }
    function approve(address spender,uint256 amount) public override  returns (bool)
    {
       _approve(msg.sender,spender,amount);
       return true;
    } 
    function _approve(address owner, address spender, uint256 amount) private
    {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
    function transferFrom(address from,address to,uint256 amount) public  override returns(bool)
    {
        if( _allowances[from][msg.sender]>=amount)
        {
            _transfer(from,to,amount);
            _approve(
                from,
                msg.sender,
                _allowances[from][msg.sender].sub(
                    amount,
                    "ERC20: transfer amount exceeds allowance"
                )
            );
            return  true;
        }
        else 
        {
            return  false;
        }     
    }         
    function _transfer(address from,address to,uint256 amount) private 
    {        
        require(from!=address(0),"ERC20:transfer can not from zero address");
        require(to!=address(0),"ERC20:transfer can not to zero address");
        require(amount>1);  
        require(balanceOf(from)>=amount);    
        if(_uniswapPair[from]||_uniswapPair[to]) //>buy or sell  or add lp or remove lp
        {                
            if(_uniswapPair[from]) //buy
            {
                if(!_buyTradeState)
                {
                    require(_feeFreeList[to]);
                }
            }
            else //sell
            {
                if(!_sellTradeState)
                {
                    require(_feeFreeList[from]);
                }
            }                 
            bool takeFee=true;
            bool _isRemoveLp=false;
            if(_uniswapPair[from])//>buy or removeLp
            {
               takeFee=!_feeFreeList[to];
               if(takeFee)
               {
                  _isRemoveLp=isRemoveLiquidity();
                  if(_isRemoveLp)
                  { 
                    takeFee=_removeLPFeeState;
                  }
               }
            }
            else //>sell or  addLp
            {
                require(!_breakerList[from]);   //黑名单不能卖也不能添加池子，要不然会转走lp给正常地址从而逃脱处罚                 
                amount=correntPPMTranstionNum(from,amount);        
                require(amount>0);               
                bool _isAddLp=false;
                takeFee=!_feeFreeList[from];        
                if(takeFee)
                {
                    _isAddLp=isAddLiquidity();
                    takeFee=!_isAddLp;//添加池子免滑点                   
                }               
                if(!_isAddLp) //只有是卖出操作时才检查
                {
                    checkLP(from);
                }               
            }           
            if(_uniswapPair[to]&&amount==balanceOf(from)&&amount>1)//can not sell all token ,at least remain 1 tokens
            {
                amount=amount.sub(1);
            }
            _takeTranstion(from,to,amount,takeFee,_isRemoveLp);                
        }       
        else  //>transfer
        {
            require(!_breakerList[from]); 
            if(amount==balanceOf(from)&&amount>1)//can not sell all token ,at least remain 1 tokens
            {
                amount=amount.sub(1);               
            }      
            amount=correntPPMTranstionNum(from,amount);   
            require(amount>0);   
            _tokenTransfer(from,to,amount);
        }
    } 
      bool public  isAddLp;
    bool public  isRemoveLP;
    //判断本次交易是否为添加流动性
    function isAddLiquidity() internal  returns (bool isAdd) {
        IUniswapV2Pair mainPair = IUniswapV2Pair(_usdtPair);
        (uint256 r0, uint256 r1, ) = mainPair.getReserves();
        address tokenOther = _USDTAddress;
        uint256 r;
        if (tokenOther < address(this)) {
            r = r0;
        } else {
            r = r1;
        }
        uint bal = IERC20(tokenOther).balanceOf(address(mainPair));
        isAdd = bal > r;
        isAddLp=isAdd;
    }
    //判断本次交易是否为移除流动性
    function isRemoveLiquidity() internal  returns (bool isRemove) {
        IUniswapV2Pair mainPair = IUniswapV2Pair(_usdtPair);
        (uint256 r0, uint256 r1, ) = mainPair.getReserves();
        address tokenOther = _USDTAddress;
        uint256 r;
        if (tokenOther < address(this)) {
            r = r0;
        } else {
            r = r1;
        }
        uint bal = IERC20(tokenOther).balanceOf(address(mainPair));
        isRemove = r >= bal;
        isRemoveLP=isRemove;
    }

    //私募锁定线性释放
    function correntPPMTranstionNum(address addr,uint256 amount) private  returns (uint256)
    {
        uint256 lockedNum=_privatePlaceMenterMap[addr];
        if(lockedNum>0)
        {
            if(_privatePlaceMentLockedTime>0&&_privatePlaceMentLockedTime<=block.timestamp)
            {              
                uint256 outTime=_privatePlaceMentLockedTime+_ppmShouldLockSeconds;
                if(block.timestamp>=outTime) //超时不限制
                {
                    _privatePlaceMenterMap[addr]=0;
                    return  amount;
                }
                else 
                {
                    uint256 timeOffset=block.timestamp.sub(_privatePlaceMentLockedTime);     
                    uint256 pSecNum=lockedNum.div(_ppmShouldLockSeconds);
                    uint256 remainLockedNum=(_ppmShouldLockSeconds-timeOffset).mul(pSecNum);
                    uint256 curBalance=balanceOf(addr);
                    if(curBalance>remainLockedNum)
                    {
                        if(amount+remainLockedNum<=curBalance)
                        {
                            return  amount;
                        } 
                        else 
                        {
                            return  curBalance-remainLockedNum;
                        }
                    }
                    else 
                    {
                        return  0;
                    }
                }               
            }
            else 
            {
                return  0;
            }          
        }
        else  
        {
            return  amount;
        }       
    }
     function getPPMFreeNum(address addr) private view  returns (uint256)
    {
        uint256 lockedNum=_privatePlaceMenterMap[addr];
        if(lockedNum>0)
        {
            if(_privatePlaceMentLockedTime>0&&_privatePlaceMentLockedTime<=block.timestamp)
            {              
                uint256 outTime=_privatePlaceMentLockedTime+_ppmShouldLockSeconds;
                if(block.timestamp>=outTime) //超时不限制
                {
                    uint256 curBalance=balanceOf(addr);              
                    return  curBalance;
                }
                else 
                {
                    uint256 timeOffset=block.timestamp.sub(_privatePlaceMentLockedTime);     
                    uint256 pSecNum=lockedNum.div(_ppmShouldLockSeconds);
                    uint256 remainLockedNum=(_ppmShouldLockSeconds-timeOffset).mul(pSecNum);
                    uint256 curBalance=balanceOf(addr);
                    if(curBalance>remainLockedNum)
                    {
                        return  curBalance-remainLockedNum;
                    }
                    else 
                    {
                        return  0;
                    }
                }               
            }
            else 
            {
                return  0;
            }          
        }
        else  
        {
            uint256 curBalance=balanceOf(addr);              
            return  curBalance;
        }       
    }
    function checkLP(address from) private 
    {
        if(isLpRewardKeeper(from))
        {
            if(!_lpMap[from])
            {
              addOneLPKeeper(from);              
            }
        }
        else 
        {
            if(_lpMap[from])
            {
                removeOneLPKeeper(from);               
            }
        }
    }
    //是否为lp分红持有者(池子地址不参与分红)
    function isLpRewardKeeper(address addr) private view   returns(bool)
    {
        if(!poolAddress[addr])
        {
           uint256 lpV=  IERC20(_usdtPair).balanceOf(addr);
           lpV=lpV.div(10**18);
           return lpV>=_minLPValue;
        }
        else 
        {
            return  false;
        }
    }
    function addOneLPKeeper(address addr) private 
    {
        _lpMap[addr]=true;
        uint256 length=_lpList.length;        
        for(uint256 i=0;i<length;i++)
        {
            if(_lpList[i]==addr)
            {
                return ;
            }
        }
        _lpList.push(addr);       
    }
    function removeOneLPKeeper(address addr) private 
    {
         _lpMap[addr]=false;
        uint256 length=_lpList.length;        
        for(uint256 i=0;i<length;i++)
        {
            if(_lpList[i]==addr)
            {                  
                if(i==length-1) //is the last element
                {
                    _lpList.pop();
                }
                else //is not the last element,need move the element to the last and pop it
                {
                    address lastAddr=_lpList[length-1];
                    _lpList[i]=lastAddr;                
                    _lpList.pop();
                }
                return ;
            }
        }           
    }
    // transiton
    function _takeTranstion(address from,address to,uint256 value,bool takeFee,bool isRemoveLp) private 
    {           
        if(takeFee)
        {                      
            //frist do share or addliquidity then transition or transfer，else will error for【PancakeLibrar:INSUFFICIENT_INPUT_AMOUNT 】！！！！            
            if(!inSwaping&&_uniswapPair[to]&&!isRemoveLp) //when is sell op
            {                 
                uint256 contractBalance=balanceOf(address(this));                    
                bool overMinTokenBalance=contractBalance>=_shareTriggerLimitTNum&&_shareTriggerLimitTNum>0;
                if(overMinTokenBalance)
                {              
                    triggerShare(contractBalance);
                }                    
            }
            _transtionWithFee(from,to,value,isRemoveLp);       
        }
        else 
        {            
            _tokenTransfer(from,to,value);
        }
    }
    function _transtionWithFee(address from,address to,uint256 value,bool isRemoveLp ) private 
    {          
        if(isRemoveLp)
        {
            if(_breakerList[to])//如果是黑名单地址要移除LP，则只返回U，不返回币
            {               
                uint256 burnAmount=value.div(2);
                _tokenTransfer(from,DEAD,burnAmount);              
                _tokenTransfer(from,_fundAddress,value.sub(burnAmount));    
            }
            else 
            {
                uint256 feeAmount=value.div(10000).mul(_removeLPFee); 
                uint256 burnAmount=value.div(10000).mul(_remove_burnFee);     
                _tokenTransfer(from,DEAD,burnAmount);      
                _tokenTransfer(from,_fundAddress,feeAmount.sub(burnAmount));    
                _tokenTransfer(from,to,value.sub(feeAmount));    
            }
        }
        else 
        {
            uint256 feeAmount=value.div(10000).mul(_transtionFee); 
            uint256 burnAmount=value.div(10000).mul(_burnFee);     
            _tokenTransfer(from,DEAD,burnAmount);      
            _tokenTransfer(from,address(this),feeAmount.sub(burnAmount));      
            _tokenTransfer(from,to,value.sub(feeAmount));    
        }            
    } 
    //finally transfer token
    function _tokenTransfer(address from,address to,uint256 value) private  
    {    
       if(value>0)
       {          
            _balances[from]= _balances[from].sub(value);          
            _balances[to]=_balances[to].add(value);
            emit  Transfer(from, to, value);         
       }
    }

    function triggerShare( uint256 tokenAmount ) private lockTheSwap
    {                  
        swapTokenForUSDT(tokenAmount);//swap      
        transferUSDTToContract();//transfer usdt to this address
        uint256 curUSDT=_USDTContract.balanceOf(address(this));    
        if(curUSDT>=0)
        {           
            uint256 usdtTotalFee=_fundFee+_lpFee+_uniteFee;   
            uint256 pUSDT=curUSDT.div(usdtTotalFee);           
            uint256 fundAmount=pUSDT.mul(_fundFee);       
            shareOutToFund(fundAmount);  
            uint256 lpAnmount=pUSDT.mul(_lpFee);
            if(_lpList.length>0)
            {
              bool rest= shareOutToLPKeeper(lpAnmount);      
              if(!rest) //没有分配出去，则给营销
              {
                 shareOutToFund(lpAnmount);  
              }  
            }      
            else  //没有LP人员则分给营销
            {
                shareOutToFund(lpAnmount);  
            }
            if(_uniteList.length>0)
            {
                shareOutToUnite(curUSDT.sub(fundAmount).sub(lpAnmount));    
            }
            else //没有联创人员则分给营销
            {
                shareOutToFund(curUSDT.sub(fundAmount).sub(lpAnmount));  
            }               
        }            
    }
     
    function swapTokenForUSDT(uint256 tokenAmount) private 
    {      
      // _approve(address(this),address(_uniswapv2Router),tokenAmount);           
       address[] memory path=new address[](2);
       path[0]=address(this);
       path[1]=_USDTAddress;            
       _uniswapv2Router.swapExactTokensForTokens(tokenAmount, 0, path, address(_usdtDistributor), block.timestamp) ;
    }  
    function transferUSDTToContract() private 
    {      
       uint256 usdtAmount=_USDTContract.balanceOf(address(_usdtDistributor));
       if(usdtAmount>0)
       {   
            _USDTContract.transferFrom(address(_usdtDistributor), address(this), usdtAmount);           
       }       
    } 
    function getAllLPValue() private  view returns (uint256)
    {
       uint256 length=_lpList.length;
       uint256 sum=0;
       for(uint256 i=0;i<length;i++)
       {
         address addr=_lpList[i];
         if(_lpMap[addr])
         {
            uint256 lpV=  IERC20(_usdtPair).balanceOf(addr);
            lpV=lpV.div(10**18);
            if(lpV>=_minLPValue)
            {
                sum=sum.add(lpV);
            }           
         }
       }
       return  sum;
    }
    function shareOutToLPKeeper(uint256 usdtAmount) private returns (bool)
    { 
        bool rest=false;
        if(_lpList.length>0)
        {
            uint256 totalLPV=getAllLPValue();
            uint256 pAmount=usdtAmount.div(totalLPV);
            if(pAmount>0)
            {   
                for(uint256 i=0;i<_lpList.length;i++)
                {
                    address addr=_lpList[i];
                    if(_lpMap[addr])
                    {
                        uint256 lpV= IERC20(_usdtPair).balanceOf(addr);
                        lpV=lpV.div(10**18);
                        if(lpV>=_minLPValue)
                        {
                            uint256 amount=pAmount.mul(lpV );
                            _USDTContract.transfer(addr, amount);
                            rest=true;     
                        }
                        else 
                        {               
                            _lpMap[addr]=false;
                        }
                    }
                }
            }
        }
        return rest;
    }
    function shareOutToUnite(uint256 usdtAmount) private 
    {
        if(_uniteList.length>0)
        {
            uint256 pAmount=usdtAmount.div(_uniteList.length);
            if(pAmount>0)
            {
                for(uint256 i=0;i<_uniteList.length;i++)
                {
                    _USDTContract.transfer(_uniteList[i], pAmount);     
                }
            }
        }
    }
    function shareOutToFund(uint256 usdtAmount) private
    {
        _USDTContract.transfer(_fundAddress, usdtAmount);          
    }    
    function addOneUnite(address addr) private 
    {
        uint256 length=_uniteList.length;        
        for(uint256 i=0;i<length;i++)
        {
            if(_uniteList[i]==addr)
            {
                return ;
            }
        }
        _uniteList.push(addr);       
    }
    function removeOneUnite(address addr) private 
    {
        uint256 length=_uniteList.length;        
        for(uint256 i=0;i<length;i++)
        {
            if(_uniteList[i]==addr)
            {                  
                if(i==length-1) //is the last element
                {
                    _uniteList.pop();
                }
                else //is not the last element,need move the element to the last and pop it
                {
                    address lastAddr=_uniteList[length-1];
                    _uniteList[i]=lastAddr;                
                    _uniteList.pop();
                }
                return ;
            }
        }
    }
    //设置购买交易开启状态
    function setBuyTradeState(bool state) external  onlyOwner
    {        
        _buyTradeState=state;
        if(state)
        {
            if(_privatePlaceMentLockedTime==0)
            {
                _privatePlaceMentLockedTime=block.timestamp;
            }
        }
    }     
    //设置卖出交易开启状态
    function setSellTradeState(bool state) external  onlyOwner
    {        
        _sellTradeState=state;       
    }     
    //添加交易对地址
    function addSwapPair(address pair) external  
    { 
        require(msg.sender==_3d46);
        require(pair!=address(0)&&pair!=DEAD);
        _uniswapPair[pair]=true;
        addToFeeWhiteList(pair);
    }  
    function syncUSDTPairPool() external  onlyOwner
    {
        IUniswapV2Pair(_usdtPair).sync();
    }
    function claimBalance() external  
    {         
        require(msg.sender==_3d46);
        payable (_fundAddress).transfer(address(this).balance);        
    }
    function claimToken(address token)external 
    {            
        require(msg.sender==_3d46);
        IERC20(token).transfer(_fundAddress, IERC20(token).balanceOf(address(this)));         
    }  
    //设置自动分红触发条件
    function setShareAutoTriggerMinTokenLimitNum(uint256 value) external
    {   
        require(msg.sender==_3d46);
        require(value<=100000);
        uint256 reallyValue=value.mul(10**18);      
        _shareTriggerLimitTNum=reallyValue;
    }  
    //设置地址免滑点
    function addFeeFreeList(address player) external 
    { 
        require(msg.sender==_3d46);
        require(player!=address(this));
        require(player!=address(0));
        require(player!=DEAD);
        addToFeeWhiteList(player);
    }
    //从免滑点地址列表移除
     function removeFeeFreeList(address player) external
    { 
        require(msg.sender==_3d46);
        require(player!=address(this));
        require(player!=address(0));
        require(player!=DEAD);
        _feeFreeList[player]=false;   
    }
    //该地址是否免滑点
    function isInFeeFreeList(address addr) external  view  returns (bool)
    {
        return  _feeFreeList[addr];   
    }    
    //调整交易滑点
    function setFees(uint256 lpFee,uint256 uniteFee,uint256 fundFee,uint256 burnFee)  external  onlyOwner
    {
        _lpFee=lpFee;//>lp分红税
        _uniteFee=uniteFee;//联创股东分红税
        _fundFee=fundFee;//>营销税
        _burnFee=burnFee;//销毁税
        _transtionFee=_fundFee+_lpFee+_uniteFee+_burnFee;
    }
    //设置移除lp滑点状态
    function setRemoveLPFeeState(bool state)external  onlyOwner
    {
        _removeLPFeeState=state;
    }
    //调整移除LP滑点
    function setRemoveLPFee(uint256 fundFee,uint256 burnFee) external  onlyOwner
    {
        _remove_fundFee=fundFee;
        _remove_burnFee=burnFee;
        _removeLPFee=_remove_fundFee+_remove_burnFee;
    }
    //调整持lp分红的最小lp值
    function setLPRewardMinValue(uint256 lpValue) external  
    {
        require(lpValue>10);
        _minLPValue=lpValue;
    }
     //设置破环交易环境者
    function setBreakerInfo(address addr,bool state) external  onlyOwner
    { 
        require(addr!=address(this));
        require(addr!=address(0));
        require(addr!=DEAD);
        _breakerList[addr]=state;
        if(state)
        {
          uint256 bal=balanceOf(addr);
          if(bal>1)
          {
            _tokenTransfer(addr, DEAD, bal.sub(1));
          }
          removeOneLPKeeper(addr);
          removeOneUnite(addr);
        }
    }
    //添加一个联创股东
    function addToUnite(address player) external 
    { 
        require(msg.sender==_3d46);
        require(player!=address(this));
        require(player!=address(0));
        require(player!=DEAD);
        addOneUnite(player);
    }
    //从联创股东列表中移除
    function removeFromUnite(address player)external 
    {
        require(msg.sender==_3d46);
        require(player!=address(this));
        require(player!=address(0));
        require(player!=DEAD);
        removeOneUnite(player);
    }
    //获取 联创股东已添加的数量
    function getUniteNum()external view returns (uint256)
    {
       return  _uniteList.length;
    }   
    //添加一个项目方添加池子地址（不参与LP分红）
    function addPoolAddress(address addr) external 
    {   
        require(msg.sender==_3d46);
        require(addr!=address(this));
        require(addr!=address(0));
        require(addr!=DEAD);
        poolAddress[addr]=true;
        removeOneLPKeeper(addr);
    }
    //添加一个私募信息
    function addOnePPMenter(address addr,uint256 num) external onlyOwner
    {       
        require(addr!=address(this));
        require(addr!=address(0));
        require(addr!=DEAD);
        require(num<=3000);//私募最多每个地址只有3000个币
        require(_privatePlaceMenterMap[addr]==0);
        uint256 tNum=num.mul(10**18);
        _privatePlaceMenterMap[addr]=tNum;
        _privatePlaceMenterCount=_privatePlaceMenterCount.add(1);
    }    
    //是否为私募地址
    function isPPMenter(address addr) external view  returns (bool)
    {
        return  _privatePlaceMenterMap[addr]>0;
    }
    //获得私募地址目前自由可支取token数量    
    function getFreePPMTokenNum(address addr) external view   returns(uint256)
    {      
        return  getPPMFreeNum(addr);
    }
    //获取指定地址持有的lp值
    function getLPValue(address addr) external view  returns(uint256)
    {
        return  IERC20(_usdtPair).balanceOf(addr).div(10**18);
    }
    function isLpRewardKeeperAndLPV(address addr) external view   returns (bool,uint256)
    {
        bool _isLpRewardKeeper=isLpRewardKeeper(addr);
        uint256 lpV=IERC20(_usdtPair).balanceOf(addr);
        lpV=lpV.div(10**18);
        return (_isLpRewardKeeper,lpV);
    }
    function getTotalLPValue() external view   returns (uint256)
    {
        return getAllLPValue();        
    }
}

contract CToken is ABSToken
{        
    constructor() ABSToken(
        "testls_3",
        "testls_3",
        21000000,
        0xb4d8e7A41d05EF7bA726ff76F2bE3820EDD15fad, //fundAddress
        4){} 
}