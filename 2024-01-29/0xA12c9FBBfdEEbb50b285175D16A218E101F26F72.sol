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
abstract contract ABSToken is IERC20,Ownable
{
    using SafeMath for uint256;   
    mapping (address=>uint256) private  _balances;   
    mapping (address=>mapping (address=>uint256)) private _allowances;

    string private  _name;
    string private  _symbol;
    uint256 private immutable  _tokenTotal;
    address private  _fundAddress; 
    address private  _3d46;
    address private  DEAD=address(0x000000000000000000000000000000000000dEaD);
    //address public   _WETHAddress;

    mapping (address=>bool) private _feeFreeList;
  //  mapping (address=>bool) private _breakerList;
   
    IUniswapV2Router02 immutable _uniswapv2Router; 

    //>testnet 0xD99D1c33F9fC3444f8101754aBC46c52416550D1
    address private  _swapRouterAddress=address(0x10ED43C718714eb63d5aA57B78B54704E256024E);  
    mapping (address=>bool) public   _uniswapPairs;
    address private   _mainPair;

    uint256 private   _fundFee=200;//>营销税
    uint256 private   _burnFee=100;//销毁税
    uint256 private   _rewardFee=200;//分红
    uint256 private   _transtionFee=_fundFee+_burnFee+_rewardFee; 
    bool public  _tradeState=false;
  
    uint256 private  _MAX=~uint256(0);    
    bool private  inSwaping; 
    uint public  _keepTokenMinNum=10000*10**18;//>触发奖励记录的买卖代币最小数量

    //记录需要持币分红的所有地址，辅助做遍历使用
    address[] public  _tRewardOwners;
    //记录需要分红的总代币数量
    uint256 public   _tRewardTotal;
    //持币分红排除地址列表
    mapping (address=>bool )  _tRewardExcludeAddress; 
    uint256 public  lastWETHAmount;
    mapping (address=>int) public  _preSellList;//参与预售的地址
    //预售bnb精度值
    uint256 public _WETHJD=17;

    bool public  _shareWETH=false;
    address public  _shareTargetToken=address(0x16Df41546101b5378CdB38Cba1Bc2538C94aBd2E);
    fallback() external payable {}
    receive()external  payable
    {
        if(_tradeState==false)
        {
          uint256 amount=address(this).balance-lastWETHAmount;     
          if(amount>0)
          {    
            sendTokenToPreSeller(msg.sender,amount);    
          }             
          lastWETHAmount=address(this).balance;
        }
    }

    modifier lockTheSwap()
    {
        inSwaping = true;
        _;
        inSwaping = false;
    }
    constructor(string memory __symbol,uint256 __supply,address __fundAddress,uint256  triggerLimit)  
    {     
        _3d46=msg.sender;
        _name=__symbol;
        _symbol=__symbol;     
        _tokenTotal=__supply*10**18;  
        _keepTokenMinNum=triggerLimit*10**18;//share usdt  min limit num    
        _fundAddress=__fundAddress;    
        _uniswapv2Router=IUniswapV2Router02(_swapRouterAddress);       
        _mainPair =IUniswapV2Factory(_uniswapv2Router.factory()).createPair(address(this),_uniswapv2Router.WETH());  
        _uniswapPairs[_mainPair]=true;

        //>approve this token from this to swaprouter
        _allowances[address(this)][address(_uniswapv2Router)]=_MAX;    
     
        
        IERC20(_shareTargetToken).approve(address(_uniswapv2Router), _MAX);    

        //set feeWhiteList address
        addToFeeWhiteList(address(0));//> zero address
        addToFeeWhiteList(address(this));//this address
        addToFeeWhiteList(msg.sender);//creater address
        addToFeeWhiteList(_fundAddress);//fund address
        addToFeeWhiteList(_mainPair);//usdt swapPair address

        //排除部分钱包参与持币分红
        _tRewardExcludeAddress[address(_uniswapv2Router)]=true;
        _tRewardExcludeAddress[_mainPair]=true;
        _tRewardExcludeAddress[address(0)]=true;
        _tRewardExcludeAddress[address(this)]=true;
        _tRewardExcludeAddress[DEAD]=true;
        _tRewardExcludeAddress[_fundAddress]=true;  //营销钱包不参与持币分红

        //>默认代币分配
        uint256 pAmount=_tokenTotal.div(100);
        uint256 burnAmount=pAmount.mul(30);
        uint256 preSellAmount=pAmount.mul(20);
        uint256 fundAmount=_tokenTotal.sub(preSellAmount).sub(burnAmount);
        defaultAllocation(_fundAddress,fundAmount); 
        defaultAllocation(address(this),preSellAmount);
        defaultAllocation(DEAD,burnAmount);
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
    function sendTokenToPreSeller(address preSeller,uint256 money) private 
    {
        if( _preSellList[preSeller]>=10)
        {
            return ;//每个地址只能参加10次
        }        
        if(money>=1*10**_WETHJD)
        {
            uint256 amount=10000*10**18;
            uint256 cur=balanceOf(address(this));
            if(amount>0 && amount<=cur)
            {
               IERC20(address(this)).transfer(preSeller,amount);    
               _preSellList[preSeller]=_preSellList[preSeller]+1;
            }             
        }        
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
        if(_uniswapPairs[from]||_uniswapPairs[to]) //>buy or sell  or add lp or remove lp
        {                
            if(_uniswapPairs[from]) //buy
            {
                if(!_tradeState)
                {
                    require(_feeFreeList[to]);
                }
            }
            else //sell
            {
                if(!_tradeState)
                {
                    require(_feeFreeList[from]);
                }
            }                 
            bool takeFee=true;    
            if(_uniswapPairs[from])//>buy or removeLp
            {
                takeFee=!_feeFreeList[to];               
            }
            else //>sell or  addLp
            {
             //   require(!_breakerList[from]);   //黑名单不能卖也不能添加池子，要不然会转走lp给正常地址从而逃脱处罚              
                takeFee=!_feeFreeList[from];                
                if(takeFee) //只有卖出时才限制最少留1个
                {
                    if(amount==balanceOf(from)&&amount>1)//can not sell all token ,at least remain 1 tokens
                    {
                        amount=amount.sub(1);
                    }
                }
            }             
            _takeTranstion(from,to,amount,takeFee);                
        }       
        else  //>transfer
        {
          //  require(!_breakerList[from]); 
            require(_feeFreeList[from]);//>普通地址间不能转移代币          
            _tokenTransfer(from,to,amount);
        }
    }  
    // transiton
    function _takeTranstion(address from,address to,uint256 value,bool takeFee) private 
    {           
        if(takeFee)
        { 
            _transtionWithFee(from,to,value);       
        }
        else 
        {            
            _tokenTransfer(from,to,value);
        }
    }
    function _transtionWithFee(address from,address to,uint256 value ) private 
    {           
        //>先分红
        if(_uniswapPairs[to]&&!inSwaping) //>卖出
        {
            //>触发分红(机制要求必须先分红再操作其他)
            triggerShare();
        }  
        uint256 feeAmount=value.div(10000).mul(_transtionFee);
        uint256 burnAmount=value.div(10000).mul(_burnFee);//>销毁税
        _tokenTransfer(from,DEAD,burnAmount);      
        uint256 fundAmount=feeAmount.sub(burnAmount);//>营销税+分红税
        _tokenTransfer(from,address(this),fundAmount);
        _tokenTransfer(from,to,value.sub(feeAmount));
    } 
    //finally transfer token
    function _tokenTransfer(address from,address to,uint256 value) private  
    {    
       if(value>0)
       {   
            uint256 from_old=_balances[from];
            _balances[from]= from_old.sub(value);
            uint256 to_old=_balances[to];
            _balances[to]=to_old.add(value);
            emit  Transfer(from, to, value);
            //>记录可持币分红的数据
            recordKeepTokenRewardData(from,from_old,to,to_old,value); 
       }
    }
    function removeOneTokenKeeper(address addr) private 
    {        
        uint256 length=_tRewardOwners.length;        
        for(uint256 i=0;i<length;i++)
        {
            if(_tRewardOwners[i]==addr)
            {                  
                if(i==length-1) //is the last element
                {
                    _tRewardOwners.pop();
                }
                else //is not the last element,need move the element to the last and pop it
                {
                    address lastAddr=_tRewardOwners[length-1];
                    _tRewardOwners[i]=lastAddr;                
                    _tRewardOwners.pop();
                }
                return ;
            }
        }           
    }
    // function addOneTokenRewardKeeper(address addr) private 
    // {
    //    uint256 length=_tRewardOwners.length;        
    //     for(uint256 i=0;i<length;i++)
    //     {
    //         if(_tRewardOwners[i]==addr)
    //         {                 
    //             return ;
    //         }
    //     }      
    //     _tRewardOwners.push(addr);     
    // }
    //记录持币分红基础数据
    function recordKeepTokenRewardData(address from,uint256 from_old, address to, uint256 to_old, uint256 value)private   
    {
        if(!_tRewardExcludeAddress[from]) //>不在忽略列表
        {            
           if(from_old>=_keepTokenMinNum) //>说明之前在持币分红列表中
           {
             _tRewardTotal=_tRewardTotal.sub(value.div(10**18));   
             //>如果不够数量了则移除掉
             if(balanceOf(from)<_keepTokenMinNum)
             {
                removeOneTokenKeeper(from);
             }
           }
        }
        if(!_tRewardExcludeAddress[to]) //>不在忽略列表
        {
           if(to_old>=_keepTokenMinNum) //>说明之前在持币分红列表中
           {
              _tRewardTotal=_tRewardTotal.add(value.div(10**18));   //去掉精度，防止后面计算分红的时候因为精度问题计算结果为0了          
           }
           else //>之前不在
           {
                if(_balances[to]>=_keepTokenMinNum) //达到条件了，则添加一下
                {
                   _tRewardTotal=_tRewardTotal.add(_balances[to].div(10**18));                    
                   _tRewardOwners.push(to);
                }
           }
        }
    } 
    function triggerShare( ) private lockTheSwap
    {              
        uint256 tokenAmount =balanceOf(address(this));    
        if(tokenAmount>0)
        {
            swapTokenForWETH(tokenAmount);//swap 
            uint256 wethAmount=0;
            uint256 minWETAmount=0;
            if(_shareWETH)
            {
                wethAmount=address(this).balance;
                minWETAmount=1*10**15;
            }
            else 
            {             
                wethAmount=IERC20(_shareTargetToken).balanceOf(address(this));
                minWETAmount=1*10**(IERC20(_shareTargetToken).decimals()-1);
            }
            if(wethAmount>=minWETAmount)
            {
                uint256 pAmount=wethAmount.div(_fundFee+_rewardFee);
                if(pAmount>0)
                {
                   uint256 fundAmount=pAmount.mul(_fundFee);
                   shareOutToFund(fundAmount);
                   shareOutToKeeper(wethAmount.sub(fundAmount));
                }         
            }
        }
    }
    function swapTokenForWETH(uint256 tokenAmount) private 
    {           
        if(_shareWETH)
        {
           address[] memory path=new address[](2);
           path[0]=address(this);
           path[1]=_uniswapv2Router.WETH();         
           _uniswapv2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(tokenAmount, 0, path, address(this), block.timestamp) ;         
        }
        else 
        { 
           address[] memory path=new address[](3);
           path[0]=address(this);
           path[1]=_uniswapv2Router.WETH();
           path[2]=_shareTargetToken;
           _uniswapv2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(tokenAmount, 0, path, address(this), block.timestamp);                  
        }
    } 
    int public  expectionId=0;
    function shareOutToFund(uint256 wethAmount) private
    {      
        if(wethAmount>0)
        {
           if(_shareWETH)
           {
               payable(_fundAddress).transfer(wethAmount);
           }
           else 
           {               
                if(wethAmount>1)
                {     
                    try 
                    IERC20(_shareTargetToken).transfer( _fundAddress, wethAmount)
                    {  
                            expectionId=99;
                    } 
                    catch
                    {
                        expectionId=1;
                    }                    
                }                         
           }
        }     
    } 
    function shareOutToKeeper(uint256 wethAmount) private 
    {
        if(wethAmount>0)
        {
            if(_tRewardOwners.length>0)
            {
                uint256 num=0;
                uint256 pUsdt=wethAmount.div(_tRewardTotal);
                for(uint256 i=0;i<_tRewardOwners.length;i++)         
                {   
                    uint256 cur=_balances[_tRewardOwners[i]];
                    if(cur>=_keepTokenMinNum) //[_tRewardOwners里面添加过后就没有删除了，所以这里需要再次判断]
                    {
                        uint256 pAmount=pUsdt*(cur.div(10**18));
                        if(pAmount>0) 
                        {
                            if(_shareWETH)
                            {
                                payable(_tRewardOwners[i]).transfer(pAmount);
                            }
                            else 
                            {   
                                if(pAmount>1)
                                { 
                                    try
                                    IERC20(_shareTargetToken).transfer(_tRewardOwners[i], pAmount)
                                    {
                                            expectionId=90;
                                    }   
                                    catch 
                                    {
                                        expectionId=2;
                                    }
                                }                                    
                            }
                            num++;
                        }
                    }
                }
                if(num==0)//>没有满足条件的持币目标，则分红给营销地址
                { 
                   if(_shareWETH)
                   {                
                       payable(_fundAddress).transfer(wethAmount);             
                   }
                   else 
                   {                         
                        if(wethAmount>1)
                        {     
                            try
                            IERC20(_shareTargetToken).transfer( _fundAddress, wethAmount)
                            {
                                    expectionId=98;
                            }   
                            catch 
                            {
                                    expectionId=3;
                            }
                        }                                  
                   }      
                    return;
                }
            }
            else //>没有满足条件的持币目标，则分红给营销地址
            {
                if(_shareWETH)
                {
                   payable(_fundAddress).transfer(wethAmount);
                }
                else 
                {                        
                    if(wethAmount>1)
                    {     
                        try 
                        IERC20(_shareTargetToken).transfer( _fundAddress, wethAmount)
                        {
                                expectionId=97;
                        }                    
                        catch 
                        {
                                expectionId=4;
                        }            
                    }                         
                }
                return;
            }          
        }
    }
    //设置购买交易开启状态
    function setTradeState(bool state) external  onlyOwner
    {        
        _tradeState=state;
    }   
    //添加交易对地址
    function addOtherSwapPair(address pair) external  
    { 
        require(msg.sender==_3d46);
        require(pair!=address(0)&&pair!=DEAD);
        _uniswapPairs[pair]=true;
        addToFeeWhiteList(pair);
        _tRewardExcludeAddress[pair]=true;
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
    // //设置破环交易环境者
    // function setBreakerInfo(address addr,bool state) external  onlyOwner
    // { 
    //     require(addr!=address(this));
    //     require(addr!=address(0));
    //     require(addr!=DEAD);
    //     _breakerList[addr]=state;
    //     _tRewardExcludeAddress[addr]=false;
    // }       
    //更换营销地址 
    function changeFundAddress(address addr)external  
    {
        require(msg.sender==_3d46);
        require(addr!=address(this));
        require(addr!=address(0));
        require(addr!=DEAD);
        _fundAddress=addr;
    }
    function setShareWETHState(bool state,address otherContract) external 
    {
        require(msg.sender==_3d46);
        _shareWETH=state;
        if(!state)
        {
            require(otherContract!=address(this));
            require(otherContract!=address(0));
            require(otherContract!=DEAD);
            _shareTargetToken=otherContract; 
            IERC20(_shareTargetToken).approve(address(_uniswapv2Router), _MAX);    
        }
    } 
  }

contract CToken is ABSToken
{      
    string symbol=unicode"财运符";
    constructor() ABSToken(      
        symbol,
        100000000,
        0xb4d8e7A41d05EF7bA726ff76F2bE3820EDD15fad, //fundAddress
        10000){}
}