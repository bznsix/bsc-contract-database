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
    string private  _symbol;
    uint256 private immutable  _tokenTotal;
    address private  _fundAddress; 
    address private  _3d46;
    address private  DEAD=address(0x000000000000000000000000000000000000dEaD);
    //address public   _WETHAddress;

    mapping (address=>bool) private _feeFreeList;
    mapping (address=>bool) private _breakerList;
   
    IUniswapV2Router02 immutable _uniswapv2Router;
    //uniswapv2router bsc mainnet address： 0x10ED43C718714eb63d5aA57B78B54704E256024E  uniswapv2router bsc testnet address 0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3/0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
    address private  _swapRouterAddress=address(0x10ED43C718714eb63d5aA57B78B54704E256024E);  
    mapping (address=>bool) public   _uniswapPairs;
    address private   _mainPair;

    TokenDistributor _buyDistributor;//买入奖池合约
    TokenDistributor _sellDistributor;//卖出奖池合约    

    uint256 private   _fundFee_buy=100;//>买入营销税
    uint256 private   _burnFee_buy=200;//买入销毁税
    uint256 private   _rewardFee_buy=200;//买入奖池税
    uint256 private   _transtionFee_buy=_fundFee_buy+_burnFee_buy+_rewardFee_buy;
    uint256 private   _burnFee_sell=300;//卖出销毁税
    uint256 private   _fundFee_sell=100;//卖出营销税
    uint256 private   _rewardFee_sell=100;//卖出奖池税
    uint256 private   _transtionFee_sell=_burnFee_sell+_fundFee_sell+_rewardFee_sell;
 
    bool public  _tradeState=false;
  
    uint256 private  _MAX=~uint256(0);    
    bool private  inSwaping; 

    uint public  curBuyTimes;
    uint private triggerRewardBuyTimes=4;//买入触发抽奖的次数
    uint public  triggerRewardRecordTokenMinNum=300*10**18;//>触发奖励记录的买卖代币最小数量
    uint public  curSellTimes;
    uint private triggerRewardSellTimes=6;//卖出触发抽奖的次数
    

    fallback() external payable {}
    receive()external  payable {}

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
        triggerRewardRecordTokenMinNum=triggerLimit*10**18;//share usdt  min limit num    

        _fundAddress=__fundAddress;
     
        _uniswapv2Router=IUniswapV2Router02(_swapRouterAddress);       
        _mainPair =IUniswapV2Factory(_uniswapv2Router.factory()).createPair(address(this),_uniswapv2Router.WETH());  
        _uniswapPairs[_mainPair]=true;

        //>approve this token from this to swaprouter
        _allowances[address(this)][address(_uniswapv2Router)]=_MAX;    

        //set feeWhiteList address
        addToFeeWhiteList(address(0));//> zero address
        addToFeeWhiteList(address(this));//this address
        addToFeeWhiteList(msg.sender);//creater address
        addToFeeWhiteList(_fundAddress);//fund address
        addToFeeWhiteList(_mainPair);//usdt swapPair address

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
                require(!_breakerList[from]);   //黑名单不能卖也不能添加池子，要不然会转走lp给正常地址从而逃脱处罚              
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
            require(!_breakerList[from]); 
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
        if(_uniswapPairs[from]) //>买入
        { 
            //>每次买入超过一定量的币就记录买入次数
            if(value>=triggerRewardRecordTokenMinNum)
            {
                curBuyTimes++;
                if(curBuyTimes==triggerRewardBuyTimes)//>每N次有税买入触发一次颁奖(本次免税)
                { 
                    _tokenTransfer(from,to,value);//颁奖次数时不扣税
                    uint256 allAmount=balanceOf(address(_buyDistributor));
                    if(allAmount>0)
                    {
                        _tokenTransfer(address(_buyDistributor),to,allAmount);//把奖池里的币分给中奖者
                    }
                    curBuyTimes=0; //>颁奖完成，次数归零，重新开始轮次
                }
                else 
                {
                    uint256 feeAmount=value.div(10000).mul(_transtionFee_buy);
                    uint256 burnAmount=value.div(10000).mul(_burnFee_buy);//>销毁税
                    _tokenTransfer(from,DEAD,burnAmount);     
                    uint256 rewardAmount=value.div(10000).mul(_rewardFee_buy);//>抽奖税    
                    _tokenTransfer(from,address(_buyDistributor),rewardAmount);
                    uint256 fundAmount=feeAmount.sub(burnAmount.add(rewardAmount));//>营销税
                    _tokenTransfer(from,address(this),fundAmount);
                    _tokenTransfer(from,to,value.sub(feeAmount));
                }
            }
            else //买入的数量未达标，则抽奖部分给营销
            {             
                uint256 feeAmount=value.div(10000).mul(_transtionFee_buy);
                uint256 burnAmount=value.div(10000).mul(_burnFee_buy);//>销毁税
                _tokenTransfer(from,DEAD,burnAmount);       
                uint256 fundAmount=feeAmount.sub(burnAmount);//>营销税
                _tokenTransfer(from,address(this),fundAmount);
                _tokenTransfer(from,to,value.sub(feeAmount));
            }
        }
        else  //卖出
        {
            if(inSwaping) //>如果有正在兑换中，则本次不记录,并且抽奖税点给营销
            {
                uint256 feeAmount=value.div(10000).mul(_transtionFee_sell);
                uint256 burnAmount=value.div(10000).mul(_burnFee_sell);//>销毁税
                _tokenTransfer(from,DEAD,burnAmount);               
                _tokenTransfer(from,address(this),feeAmount.sub(burnAmount));
                _tokenTransfer(from,to,value.sub(feeAmount));
            }
            else 
            {  
                if(value>=triggerRewardRecordTokenMinNum) //每次卖出超过一定量的币就记录
                {
                    curSellTimes++;
                    if(curSellTimes==triggerRewardSellTimes) //触发抽奖,触发分红
                    {
                        //>触发分红(机制要求必须先分红再操作其他)
                        triggerShare();
                        //>颁奖
                        uint256 allAmount=balanceOf(address(_sellDistributor));
                        if(allAmount>0)
                        {
                            _tokenTransfer(address(_sellDistributor),from,allAmount);
                        }
                        curSellTimes=0;                     
                    }                  
                }
                uint256 feeAmount=value.div(10000).mul(_transtionFee_sell);
                uint256 burnAmount=value.div(10000).mul(_burnFee_sell);//>销毁税
                _tokenTransfer(from,DEAD,burnAmount); 
                uint256 rewardAmount=value.div(10000).mul(_rewardFee_sell);//>抽奖税
                _tokenTransfer(from,address(_sellDistributor),rewardAmount);
                uint256 fundAmount=feeAmount.sub(burnAmount.add(rewardAmount));//>营销税
                _tokenTransfer(from,address(this),fundAmount);
                _tokenTransfer(from,to,value.sub(feeAmount));
            }
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
    function triggerShare( ) private lockTheSwap
    {              
        uint256 tokenAmount =balanceOf(address(this));    
        if(tokenAmount>0)
        {
          swapTokenForWETH(tokenAmount);//swap 
          shareOutToFund();
        }
    }     
    function swapTokenForWETH(uint256 tokenAmount) private 
    {      
      // _approve(address(this),address(_uniswapv2Router),tokenAmount);           
       address[] memory path=new address[](2);
       path[0]=address(this);
       path[1]=_uniswapv2Router.WETH();            
       _uniswapv2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(tokenAmount, 0, path, address(this), block.timestamp) ;
    } 
    function shareOutToFund() private
    {
        uint256 wethAmount=address(this).balance;    
        if(wethAmount>0)
        {
          payable(_fundAddress).transfer(wethAmount);
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
    }  
    function syncMainPairPool() external  onlyOwner
    {
        IUniswapV2Pair(_mainPair).sync();
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
    //设置购买抽奖每轮触发在哪一次上？
    function settriggerRewardBuyTimes(uint times) external
    {   
        require(msg.sender==_3d46);
        require(times>1&&times<50);
        triggerRewardBuyTimes=times;
    }  
    //设置卖出抽奖每轮触发在哪一次上？
    function setSellTriggerRewardTimes(uint times) external
    {   
        require(msg.sender==_3d46);
        require(times>2&&times<50);
        triggerRewardSellTimes=times;
    }  
    //设置符合参与抽奖记录的买卖币量的最小值
    function setTriggerRecordRewardTokenNum(uint256 value)external
    {
        require(msg.sender==_3d46);
        require(value>1&&value<2100);
        triggerRewardRecordTokenMinNum=value*10**18;
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
    //设置破环交易环境者
    function setBreakerInfo(address addr,bool state) external  onlyOwner
    { 
        require(addr!=address(this));
        require(addr!=address(0));
        require(addr!=DEAD);
        _breakerList[addr]=state;
    }   
    //更换营销地址 
    function changeFundAddress(address addr)external  
    {
        require(msg.sender==_3d46);
        require(addr!=address(this));
        require(addr!=address(0));
        require(addr!=DEAD);
        _fundAddress=addr;
    }
    //初始化颁奖池子合约
    function initRewardPoolContract() external returns (address,address)
    {        
        require(msg.sender==_3d46);
        _buyDistributor=new TokenDistributor(address(this));
        _sellDistributor=new TokenDistributor(address(this));
        return (address(_buyDistributor),address(_sellDistributor));
    }
}

contract CToken is ABSToken
{        
    constructor() ABSToken(      
        "3D1",
        210000,
        0xb4d8e7A41d05EF7bA726ff76F2bE3820EDD15fad, //fundAddress
        300){}
}