// SPDX-License-Identifier: MIT
pragma solidity  ^0.8.7;

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
    function getTime() public   view  returns (uint256)
    {
        return block.timestamp;
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
    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
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

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
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
//这个合约用于暂存USDT，用于回流和营销钱包，分红
contract TokenDistributor {
    //构造参数传USDT合约地址
    constructor (address token) {
        //将暂存合约的USDT授权给合约创建者，这里的创建者是代币合约，授权数量为最大整数
        IERC20(token).approve(msg.sender, uint(~uint256(0)));
    }
}
abstract contract ABSToken is IERC20,Ownable
{
    using SafeMath for uint256;
    //>持币信息
    mapping (address=>uint256) private  _balances;
    //授权使用信息
    mapping (address=>mapping (address=>uint256)) private _allowances;
    //记录需要持币分红的所有地址，辅助做遍历使用
    address[] public  _tRewardOwners;
    //记录需要分红的总代币数量【不保留精度】
    uint256 public   _tRewardTotal;
    //持币分红排除地址列表
    mapping (address=>bool )_tRewardExcludeAddress;

    string private  _name;
    string private _symbol;
    uint256 private  _tokenTotal;
    //营销钱包
    address private  _fundAddress;
    //项目方地址
    address private  _proOwnerAddress;
    //合伙人-份额
    mapping (address=>uint256) public  _partnersInfo;
    //合伙人锁仓信息
    mapping (address=>uint256) public  _partnerLockedInfo;
    //合伙人列表，mapping无法遍历，用array来辅助
    address[] private _partnerAddress;
    //合伙人总份额
    uint256 private   _partnerShareTotal;
    
    //手续费白名单
    mapping (address=>bool) _feeWhiteList;
    //交易白名单[开盘可以抢筹码的]
    mapping (address=>bool) public  _whiteList;
    //黑名单
    mapping (address=>bool) _blackList;
    //黑洞地址
    address private  DEAD=address(0x000000000000000000000000000000000000dEaD);
    //BSC链USDT合约地址
    address private  _USDTAddress;
    //usdt合约
    IERC20 _USDTContract; 
    //uniswap路由
    IUniswapV2Router02 _uniswapv2Router;
    //uniswap池子交易对地址
    mapping (address=>bool) public   _uniswapPair;
    //usdt暂存中转合约
    TokenDistributor _usdtDistributor;

    //营销税[护盘税](一半代币+一半USDT)
    uint256 private  _fundFee=150;
    //合伙人分红(直接分USDT)
    uint256 private   _partnerFee=150;
    //持币分红（USDT）
    uint256 private   _keepTokenFee=200;
    //回流，添加池子
    uint256 private   _liqiudityFee=50;
    //销毁税，直接打入黑洞地址
    uint256 private   _destoryFee=50;
    //交易总税
    uint256 public   _transtionFee=_fundFee+_partnerFee+_liqiudityFee+_keepTokenFee+_destoryFee; 
    //转账税
    uint256 private  _transferFee=600;
    //持币分红的最小持币数量
    uint256 public   _kTokenShareLimitNum;
    
    //要分红的代币兑换成USDT的触发条件,缓存代币数量达到多少时 里面包括了【1半营销+股东+持币分红】
    uint256 public   _shareExchangeTriggerLimitNum;
    //持币分红USDT时USDT的缓存值最小到多少
    uint256 public   _kTokenRewardUSDTLimitCache;


    //用于回流的代币数量缓存
    uint256 public   _liqiudityCacheTokenNum;
    //自动添加流动性的最小代币数量
    uint256 public   _liqiudityMinLimitNum;
    //白名单成员在前几分钟限购数量
    uint256 public  _whiteListBuyLimit;
    //交易状态
    uint256 public  _startTradeBlock=0;
    //最大值
    uint256 private  _MAX=~uint256(0);
    
    uint256 private  _maxSellLimit;
    //>合伙人锁仓到达时间
    uint256 public  _lockToTime;

    //合于正在进行交易中状态变量
    bool private  inSwaping;


    fallback()external  payable {}
    receive()external  payable {}

    modifier lockTheSwap()
    {
        inSwaping = true;
        _;
        inSwaping = false;
    }
    modifier  onlyFunder()
    {
      require(msg.sender==_fundAddress);
      _;
    }
    constructor(string memory __name,
                string memory __symbol,
                uint256 __supply,
                address __fundAddress,
                address __proOwnerAddress,
                address[] memory __partners,  
                address _usdtAddress,              
                address _swapRouterAddress,
                address[] memory __feeWhiteList,
                address[] memory __defaultWhiteList,
                uint256 __whiteListBuyLimit,
                uint256[] memory shareData,     
                uint256 __lockDays)  
    {
       _name=__name;
       _symbol=__symbol;     
       _tokenTotal=__supply*10**18;
       _maxSellLimit=_tokenTotal.div(50);
        _whiteListBuyLimit=__whiteListBuyLimit*10**18;//白名单开盘前几分钟限购数量
       _liqiudityMinLimitNum=shareData[0]*10**18;//自动添加流动性最小值
        _kTokenShareLimitNum=shareData[1]*10**18;//持币分红最小值
       _shareExchangeTriggerLimitNum=shareData[2]*10**18;//营销和和合伙人分红USDT时的最小代币数量
        _kTokenRewardUSDTLimitCache=shareData[3]; //持币分红时积攒的最小USDT数量    

       _fundAddress=__fundAddress;
       _proOwnerAddress=__proOwnerAddress;       
       
       _USDTAddress=_usdtAddress;      
       _USDTContract = IERC20(_USDTAddress);
   

       //创建uniswapv2路由
       _uniswapv2Router=IUniswapV2Router02(_swapRouterAddress);   
       address usdtPair =IUniswapV2Factory(_uniswapv2Router.factory()).createPair(address(this),_USDTAddress);  
       _uniswapPair[usdtPair]=true;

       //>将合约内的代币全部授权给v2路由
       _allowances[address(this)][address(_uniswapv2Router)]=_MAX;
       //将合约内的USDT资产授权给v2路由
       _USDTContract.approve(address(_uniswapv2Router), _MAX);            
 
       //实例化usdt暂存合约[把暂存合约的资产授权给了本合约]
       _usdtDistributor=new TokenDistributor(_USDTAddress);

       //手续费白名单设置    
       _feeWhiteList[address(0)]=true;//>0零地址
       _whiteList[address(0)]=true;
        _feeWhiteList[address(this)]=true;//合约本身
       _whiteList[address(this)]=true;
       _feeWhiteList[msg.sender]=true;//创建的地址(拥有者)
       _whiteList[msg.sender]=true;
       _feeWhiteList[__fundAddress]=true;//营销钱包
       _whiteList[__fundAddress]=true;
       _feeWhiteList[__proOwnerAddress]=true;//项目方
       _whiteList[__proOwnerAddress]=true;
       _feeWhiteList[address(_uniswapv2Router)]=true;//v2路由
       _whiteList[address(_uniswapv2Router)]=true;
        _feeWhiteList[usdtPair]=true;    //交易对
       _whiteList[usdtPair]=true;   
       

        addDefaultFeeWhiteList(__feeWhiteList);        
        addDefaultWhiteList(__defaultWhiteList);

        //把代币发送到营销钱包里面【80%】    
        _balances[_fundAddress]=_tokenTotal.div(100).mul(80);
        emit  Transfer(address(0), _fundAddress, _tokenTotal.div(100).mul(80));

        //合伙人和技术方持币20%【80%分给合伙人+20%分给技术方】
        uint256 otherTokenNum=_tokenTotal.div(100).mul(20);
        //>设置股东份额信息[合伙人平均分配]      
        uint256 _pToken=otherTokenNum.div(100).mul(80).div(__partners.length);
        for(uint64 i=0;i<__partners.length;i++)
        {
            addPartnerShareHolderInfo(__partners[i],100,_pToken);
        }        
        //>项目方在股东份额中占20%[一定要先计算完合伙人的再计算项目方的]
        uint256 proJShare=_partnerShareTotal.div(4);
        addPartnerShareHolderInfo(_proOwnerAddress,proJShare,otherTokenNum.div(100).mul(20));    

        //持币分红过滤地址【营销，项目方，合伙人都不再享受持币分红】
        _tRewardExcludeAddress[_fundAddress]=true;  //营销钱包不参与持币分红
        _tRewardExcludeAddress[address(_uniswapv2Router)]=true;
        _tRewardExcludeAddress[usdtPair]=true;
        _tRewardExcludeAddress[address(0)]=true;
        _tRewardExcludeAddress[address(this)]=true;
        _tRewardExcludeAddress[DEAD]=true;
        
        //>计算交易滑点
        reCalculateFee();

        //合伙人锁仓30天
        _lockToTime=block.timestamp+__lockDays*86400*1000;
    }
    //添加免税的名单
    function addDefaultFeeWhiteList(address[] memory defaultList) private 
    {
        require(defaultList.length>0);
        for(uint256 i=0;i<defaultList.length;i++)
        {
            _feeWhiteList[defaultList[i]]=true;   
        }
    }
    //添加默认的白名单列表[项目未发布前已经明确的白名单]
    function addDefaultWhiteList(address[] memory defaultWhiteList) private 
    {
        require(defaultWhiteList.length>0);
        for(uint256 i=0;i<defaultWhiteList.length;i++)
        {
            _whiteList[defaultWhiteList[i]]=true;   
        }
    }
    //添加合伙人信息【份额+默认持币】
    function addPartnerShareHolderInfo(address holder,uint256 share, uint256 tokenAmount) private   
    { 
       require(holder!=address(0),"address 0 can't be shareHolder"); 
       require(holder!=DEAD,"dead address can't be shareHolder");       
       _partnersInfo[holder]=share;//>默认是100的份额
       _partnerShareTotal=_partnerShareTotal.add(share);     
       _partnerAddress.push(holder);    
       //合伙人都在白名单中  
        _whiteList[holder]=true;   
        //>合伙人钱包不再享受持币分红，只有合伙人分红
        _tRewardExcludeAddress[holder]=true;
        //默认持币
        _balances[holder]=tokenAmount;
        emit  Transfer(address(0),holder, tokenAmount);    
        _partnerLockedInfo[holder]=tokenAmount;   //合伙人锁仓
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
    function transferFrom(address from,address to,uint256 amount) public  override returns(bool)
    {
        _transfer(from,to,amount);
        if(_allowances[from][msg.sender]!=_MAX) //减少授权数量
        {
            _allowances[from][msg.sender]=_allowances[from][msg.sender].sub(amount);
        }
        return true;
    }
    
    function reCalculateFee() private 
    {
       _transtionFee=_fundFee+_partnerFee+_liqiudityFee+_keepTokenFee+_destoryFee; 
    }
    
    function _transfer(address from,address to,uint256 amount) private 
    {         
        require(from!=address(0),"ERC20:transfer can not from zero address");
        require(to!=address(0),"ERC20:transfer can not to zero address");
        require(amount>10**13,"transfer amount must greater than zero");      
        if(_uniswapPair[from]||_uniswapPair[to]) //>买卖     
        {          
            require(!_blackList[from]&&!_blackList[to],"black list user can't buy or sell");   
            if(_startTradeBlock==0)//还没有开始交易，只有白名单里的才能进行交易
            {
                require(_whiteList[from]&&_whiteList[to],"trade is not start");
                if(_uniswapPair[from]) //如果是购买，则需要限制购买数量
                {
                   require(amount<_whiteListBuyLimit.div(2),"you can't buy more token,wait trade beging, soon!"); //限制单次购买
                   uint256 curNum=balanceOf(to);
                   require(curNum.add(amount)<_whiteListBuyLimit,"you can't buy more token,wait trade beging, soon!");//限制购买总量                                 
                }               
            }    
            if(_uniswapPair[to]&&_partnersInfo[from]>0&&block.timestamp<_lockToTime) //合伙人锁仓时候不能卖出被锁定的token
            {
                require(balanceOf(from).sub(amount)>=_partnerLockedInfo[from],"you can't sell your locked token");                  
            }          
            if(_uniswapPair[to]&&amount==balanceOf(from)&&amount>10000)//不能全部卖掉，保留一点，防止持币地址减少【小于10000的时候可以卖掉，但是gas舍得吗】
            {
                amount=amount.sub(10000);
            }     
            bool takeFee=true;
            if(_uniswapPair[from])//>表示购买
            {
               takeFee=!_feeWhiteList[to];
            }
            else //>表示卖出
            {
               takeFee=!_feeWhiteList[from];
            }           
            _takeTranstion(from,to,amount,takeFee);            
        }       
        else  //>普通转账
        {
           require(!_blackList[from],"black list user can not transfer"); //不能从黑名单转出
           require(_startTradeBlock==1,"trade has not begin,wait for a moment"); //交易未开启，不能转账
           if(_partnersInfo[from]>0&&block.timestamp<_lockToTime) //合伙人锁仓时候不能转移被锁定的token
           {
                require(balanceOf(from).sub(amount)>=_partnerLockedInfo[from],"you can't transfer your locked token");                  
           }
            if(amount==balanceOf(from)&&amount>10000)//不能全部转走，保留一点，防止持币地址减少【小于10000的时候可以转走，但是gas舍得吗】
            {
                amount=amount.sub(10000);               
            }        
            bool takeFee= _transferFee>0&&(!_feeWhiteList[from]||!_feeWhiteList[to]);             
            _takeTransfer(from,to,amount,takeFee);
        }
    }
 
    // 交易
    function _takeTranstion(address from,address to,uint256 value,bool takeFee) private 
    {           
        if(takeFee)
        {           
            //添加流动性和分红移动要在本次转移之前操作，要不然会报错【PancakeLibrar:INSUFFICIENT_INPUT_AMOUNT 】谨记！！！！
            //流动性添加和分红分开做，不要一次性处理，要不然触发者要承担的gas太高
            if(!inSwaping&&_uniswapPair[to]) //不在swap中，而且是卖出操作
            {
                uint256 contractBalance=balanceOf(address(this));  //目前合约内缓存着的代币数量               
                //尝试触发分红     
                uint256 cachedToken=contractBalance.sub(_liqiudityCacheTokenNum);           
                bool overMinTokenBalance=cachedToken>=_shareExchangeTriggerLimitNum&&_shareExchangeTriggerLimitNum>0;
                if(overMinTokenBalance)
                {              
                    triggerShare(cachedToken);
                }
                else 
                {
                    bool canAddLiquidity=(contractBalance>_liqiudityCacheTokenNum)&&(_liqiudityCacheTokenNum>=_liqiudityMinLimitNum);
                    if( canAddLiquidity)//如果流动性的缓存代币数量够添加流动性，则添加流动性  
                    {
                        swapAndAddLiquidityUSDT();
                    } 
                }               
            }
            _transtionWithFee(from,to,value);       
        }
        else 
        {
            //给购买者
            _tokenTransfer(from,to,value);
        }
    }
    function _transtionWithFee(address from,address to,uint256 value ) private 
    {               
        uint256 feeAmount=value.div(10000).mul(_transtionFee);
        //转移到营销钱包(币转一半，另外一半留着买U)
        _tokenTransfer(from,_fundAddress,feeAmount.div(_transtionFee).mul(_fundFee.div(2)));
        //暂时转移到本合约内【 营销钱包的(一半)+股东的暂时放到合约内+添加到流动性的也暂时放到合约内+持币分红的】
        uint tempAmount=feeAmount.div(_transtionFee).mul(_fundFee.div(2).add(_partnerFee).add(_liqiudityFee).add(_keepTokenFee));    
        _tokenTransfer(from,address(this),tempAmount);      
        //记录一下用于回流代币数量
        _liqiudityCacheTokenNum=_liqiudityCacheTokenNum.add(feeAmount.div(_transtionFee).mul(_liqiudityFee));     
        //打入黑洞
        _tokenTransfer(from,DEAD,feeAmount.div(_transtionFee).mul(_destoryFee));   

        //未开启交易前卖出滑点双倍[一半给营销，一半销毁],如果一次性卖出总额的1/50 也是一样
        if(_uniswapPair[to]&&(_startTradeBlock==0||value>=_maxSellLimit))
        {
            uint256 otherFeeAmount=value.div(10000).mul(_transtionFee);
            _tokenTransfer(from,_fundAddress,otherFeeAmount.div(2));
            _tokenTransfer(from,DEAD, otherFeeAmount.sub(otherFeeAmount.div(2)));   
            //实际卖出的
           _tokenTransfer(from,to,value.sub(feeAmount).sub(otherFeeAmount));     
        }  
        else 
        {
           //实际给到购买者或实际卖出
           _tokenTransfer(from,to,value.sub(feeAmount));     
        }  
    }
    //转账
    function _takeTransfer(address from,address to,uint256 value,bool takeFee) private
    {
       if(takeFee)
       {   
           //未开启交易前转账滑点双倍
           if(_startTradeBlock==0)
            {  
                uint256 feeAmount=value.div(10000).mul(_transferFee);
                //>一半给营销钱包             
                _tokenTransfer(from,_fundAddress,feeAmount);
                //>一半直接销毁
                _tokenTransfer(from,DEAD,feeAmount.sub( feeAmount));  
                //剩下的给目标对象
                _tokenTransfer(from,to,value.sub(feeAmount.mul(2)));              
           }
           else 
           {
                uint256 feeAmount=value.div(10000).mul(_transferFee);
                //>一半给营销钱包
                uint256 fundAmount=feeAmount.div(2);     
                _tokenTransfer(from,_fundAddress,fundAmount);
                //>一半直接销毁
                _tokenTransfer(from,DEAD,feeAmount.sub( fundAmount));
                //剩下的给目标对象
                _tokenTransfer(from,to,value.sub(feeAmount));
           }
       }
       else 
       {
            _tokenTransfer(from,to,value);
       }
    }
   //转移token的最终操作
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
    //记录持币分红基础数据
    function recordKeepTokenRewardData(address from,uint256 from_old, address to, uint256 to_old, uint256 value)private   
    {
       if(!_tRewardExcludeAddress[from]) //>不在忽略列表
       {            
           if(from_old>=_kTokenShareLimitNum) //>说明之前在持币分红列表中
           {
             _tRewardTotal=_tRewardTotal.sub(value.div(10**18));             
           }
       }
        if(!_tRewardExcludeAddress[to]) //>不在忽略列表
       {
           if(to_old>=_kTokenShareLimitNum) //>说明之前在持币分红列表中
           {
              _tRewardTotal=_tRewardTotal.add(value.div(10**18));   //去掉精度，防止后面计算分红的时候因为精度问题计算结果为0了          
           }
           else //>之前不在
           {
                if(_balances[to]>=_kTokenShareLimitNum) //达到条件了，则添加一下
                {
                   _tRewardTotal=_tRewardTotal.add(_balances[to].div(10**18));  
                  _tRewardOwners.push(to);
                }
           }
       }
    }   
    function _approve(address owner,address spender,uint256 amount) private 
    {
        require(amount>0,"approve num must greater zero");
        uint256 maxNum=balanceOf(owner);
        require(maxNum>=amount,"approve num must letter than you have");  
        _allowances[owner][spender]=amount;
        emit  Approval(owner, spender, amount);
    }
    //兑换并添加流动性(token-usdt)
    function swapAndAddLiquidityUSDT() private lockTheSwap
    {
        uint256 half =_liqiudityCacheTokenNum.div(2);          
        uint256 halfLiqiudityTokenNum=_liqiudityCacheTokenNum.sub(half);
        if(halfLiqiudityTokenNum>0&&half>0)
        {          
            //兑换前先查一下中转合约内的USDT数量
            uint256 preUsdtBalance=_USDTContract.balanceOf(address(_usdtDistributor));
            swapTokenForUSDT(halfLiqiudityTokenNum);  //先兑换  
            uint256 afterUsdtBalance=_USDTContract.balanceOf(address(_usdtDistributor));
            uint256 initUSDTBalance=_USDTContract.balanceOf(address(this));
            transferUSDTToContract(afterUsdtBalance.sub(preUsdtBalance)); //再转移,只转移本次增加的部分
            uint256 curUSDTBalance=_USDTContract.balanceOf(address(this));      
            uint256 usdtAmount=curUSDTBalance.sub(initUSDTBalance); 
            if(usdtAmount>0) 
            {   
                _uniswapv2Router.addLiquidity(address(this), _USDTAddress, halfLiqiudityTokenNum, usdtAmount, 0, 0, _proOwnerAddress, block.timestamp);
                _liqiudityCacheTokenNum=0;                 
            }          
        }       
    }
    //触发分红[持币分红的人数一旦过高，可能gas超高，这里需要优化一下]
    function triggerShare( uint256 tokenAmount ) private lockTheSwap
    {           
        //>先检测一下持币分红  这里这样做主要是为了把分红时的gas给平摊出去
        uint256 kTokenUSDTCached=_USDTContract.balanceOf(address(_usdtDistributor)); 
        if(kTokenUSDTCached>=_kTokenRewardUSDTLimitCache)
        {
           keepTokenShareOut(kTokenUSDTCached); //持币分红      
        }
        else 
        {
            uint256 preUsdtBalance=_USDTContract.balanceOf(address(_usdtDistributor));        
            swapTokenForUSDT(tokenAmount);//>把合约内的代币兑换成USDT      
            uint256 afterUsdtBalance=_USDTContract.balanceOf(address(_usdtDistributor)); 
            //>把营销+合伙人的部分给转走就可以了
            uint256 tempUsdtNum=afterUsdtBalance.sub(preUsdtBalance);
            uint256 tempTotalFee=_fundFee.div(2).add(_partnerFee).add(_keepTokenFee);
            uint256 tKotenPart=tempUsdtNum.div(tempTotalFee).mul(_keepTokenFee);
            transferUSDTToContract(tempUsdtNum.sub(tKotenPart));//usdt资产从中转合约内转移到本合约内
            uint256 curUSDT=_USDTContract.balanceOf(address(this));
            if(curUSDT>=0)
            {
                uint256 usdtTotalFee=_fundFee.div(2)+_partnerFee;
                uint256 pUSDT=curUSDT.div(usdtTotalFee);
                fundShareOut(pUSDT.mul(_fundFee.div(2)));    //营销钱包分红
                partnerShareOut(pUSDT.mul(_partnerFee));     //合伙人分红               
            }   
        }         
    }
    //给营销钱包分红USDT
    function fundShareOut(uint256 usdtAmount) private 
    { 
        if(usdtAmount>0)
        {
            _USDTContract.transfer(_fundAddress, usdtAmount);     
            return;
        }     
    }
    //合伙人分红USDT
    function partnerShareOut(uint256 usdtAmount) private 
    {
        if(usdtAmount>0)
        {
            if(_partnerAddress.length>0)
            {              
                int num=0;
                for(uint64 i=0;i< _partnerAddress.length;i++)
                {
                    address adr=_partnerAddress[i];
                    uint256 shareUsdt=usdtAmount.div(_partnerShareTotal).mul(_partnersInfo[adr]);//>需要保留精度
                    if(shareUsdt>0) 
                    {
                        _USDTContract.transfer(adr, shareUsdt);
                        num++;                 
                    }
                }
                if(num==0)//>没有分出去，则分给项目方
                {
                   _USDTContract.transfer(_proOwnerAddress, usdtAmount);          
                   return;
                }
            }
            else  //没有股东，分给项目方
            {
                _USDTContract.transfer(_proOwnerAddress, usdtAmount);             
                return;
            }       
        }
    }
    //持币分红USDT[暂存在中转合约内的]
    function keepTokenShareOut(uint256 usdtAmount) private 
    {
        if(usdtAmount>0)
        {
            if(_tRewardOwners.length>0)
            {
                uint256 num=0;
                uint256 pUsdt=usdtAmount.div(_tRewardTotal);
                for(uint256 i=0;i<_tRewardOwners.length;i++)         
                {   
                    uint256 cur=_balances[_tRewardOwners[i]];
                    if(cur>=_kTokenShareLimitNum) //[_tRewardOwners里面添加过后就没有删除了，所以这里需要再次判断]
                    {
                        uint256 pAmount=pUsdt*(cur.div(10**18));
                        if(pAmount>0) 
                        {                        
                            _USDTContract.transferFrom(address(_usdtDistributor), _tRewardOwners[i], pAmount);
                            num++;
                        }
                    }
                }
                if(num==0)//>没有满足条件的持币目标，则分红给项目方
                {
                    _USDTContract.transferFrom(address(_usdtDistributor),_proOwnerAddress, usdtAmount);         
                    return;
                }
            }
            else //>没有满足条件的持币目标，则分红给项目方
            {
                _USDTContract.transferFrom(address(_usdtDistributor),_proOwnerAddress, usdtAmount);          
                return;
            }
        }
    }    
    //将本合约内的代币兑换为USDT
    function swapTokenForUSDT(uint256 tokenAmount) private 
    {      
       address[] memory path=new address[](2);
       path[0]=address(this);
       path[1]=_USDTAddress;            
       _uniswapv2Router.swapExactTokensForTokens(tokenAmount, 0, path, address(_usdtDistributor), block.timestamp) ;
    }  
    //>把暂存USDT合约内的资产转账到本合约地址      
    function transferUSDTToContract(uint usdtAmount) private 
    {      
       if(usdtAmount>0)
       {   
            _USDTContract.transferFrom(address(_usdtDistributor), address(this), usdtAmount);           
       }       
    } 
    //添加交易对
    function setUniswapPairAdress(address adr) external  onlyFunder
     {
        if(!_uniswapPair[adr])
        {
            _uniswapPair[adr]=true;
            _feeWhiteList[adr]=true;    //把交易对添加白名单
            _whiteList[adr]=true;   
            _tRewardExcludeAddress[adr]=true;
        }
     }
    //开启交易
    function startTrade() external  onlyOwner
    {
        _startTradeBlock=1;
    }
    //设置合伙人锁仓天数
    function setPartnerLockTime(uint256 timeDays) external  onlyFunder
    {
        _lockToTime=block.timestamp+timeDays*86400*1000;
    }
    //提取合约钱包内的主链币余额到营销钱包
    function claimBalance() external  onlyFunder
    {               
        payable (_proOwnerAddress).transfer(address(this).balance);        
    }
    function claimUsdtDistributorBalance() external onlyFunder
    {               
       uint256 usdtBalance=_USDTContract.balanceOf(address(_usdtDistributor));
       if(usdtBalance>0)
       {   
            _USDTContract.transferFrom(address(_usdtDistributor), _proOwnerAddress, usdtBalance);           
       }     
    }
    //提取本合约钱包内的其他代币到项目方钱包
    function claimToken(address token)external onlyFunder
    {                 
        IERC20(token).transfer(_fundAddress, IERC20(token).balanceOf(address(this)));
        if(token==address(this)) _liqiudityCacheTokenNum=0;
    }   
    function setTranstionFee(uint256 __fundFee,uint256 __partnerFee,uint256 __kTokenFee,uint256 __burnFee,uint256 __liqiuidityFee) external onlyOwner
    {
        if(__fundFee>50&&__partnerFee>50&&__kTokenFee>50&&__burnFee>50&&__liqiuidityFee>50 && (__fundFee+__partnerFee+__kTokenFee+__burnFee+__liqiuidityFee)<10000)
        {
            _fundFee=__fundFee;
            _partnerFee=__partnerFee;
            _keepTokenFee=__kTokenFee;
            _destoryFee=__burnFee;
            _liqiudityFee=__liqiuidityFee;
            reCalculateFee();
        }
    }
    function setTransferFee(uint256 _fee) external onlyFunder
    {
       if(_fee>=0&&_fee<10000)
       {
           _transferFee=_fee;
       }
    }
    //添加黑名单
    function addBlackList(address addr) external  onlyOwner
    {    
        _blackList[addr]=true;       
        if(_partnersInfo[addr]>0) //被加入黑名单的 合伙人名单里面也不能有他了
        {
            _partnerShareTotal=_partnerShareTotal.sub(_partnersInfo[addr]);
            _partnersInfo[addr]=0;
        }
    }  
    //设置白名单
    function setWhiteList(address addr,bool state) external  onlyOwner
    {
        if(state&& _blackList[addr])  _blackList[addr]=false;//如果在黑名单里面，则从黑名单移除掉     
        _whiteList[addr]=state;
    }     
    //设置手续费白名单
    function setFeeWhiteList(address addr,bool state) external onlyFunder
    {        
        _feeWhiteList[addr]=state;
    }
    //自动添加流动性最小代币数量限制[不带精度]
    function setLiqiudityMinLimit(uint256 min) external  onlyFunder
    {
        uint256 reallyValue=min.mul(10**18);
        require(min>10,"the value you set must be greater than 10");      
        _liqiudityMinLimitNum=reallyValue;
    }
    //设置分红USDT触发的最小缓存的代币数量【不带精度】
    function setShareAutoTriggerMinLimit(uint256 value) external  onlyFunder
    {
        uint256 reallyValue=value.mul(10**18);       
        require(reallyValue>0&& reallyValue<(_tokenTotal.div(10)),"the value you set tool big");
        _shareExchangeTriggerLimitNum=reallyValue;
    }  
    //设置分红USDT触发的最小缓存的代币数量【不带精度】  
    function setKTokenRewardUSDTLimitCache(uint256 value) external  onlyFunder
    {
        require(value>0,"keep token share usdt cache must greater than zero");
        uint256 reallyValue=value.mul(10**18);     
        _kTokenRewardUSDTLimitCache=reallyValue;
    }
    function setMaxSellLimit(uint256 _max) external  onlyFunder
    {      
        uint temp=_max.mul(10**18);
        require(temp<_tokenTotal.div(10),"too big");
        _maxSellLimit=temp;
    }
}

contract CToken is ABSToken
{
    //>合伙人
    address[]  private  shareHolders=
        [           
            0x35324BB546F9804039BD623878751CA0FF1b8a55,  //1
            0x70a1B5aAE2bfB22E40Fe2FDa0eeFd9b788353EB0,  //2
            0x8c6dF1B8bb78b19c24AC6422D7DCa8BE213D2189,  //3
            0xcF2FdCa296786Cd92134795B26d0F4CA91DC90B2,  //4
            0xB5699fD4326a0B9F54caa47F1620decE580DF9B1   //5
        ];  
    address usdtAddress=address(0x55d398326f99059fF775485246999027B3197955);  //usdt 主网合约地址： 0x55d398326f99059fF775485246999027B3197955  usdt 测试网合约地址：0x7ef95a0FEE0Dd31b22626fA2e10Ee6A223F8a684
    address swapRouterAddress=address(0x10ED43C718714eb63d5aA57B78B54704E256024E);  //v2主网路由： 0x10ED43C718714eb63d5aA57B78B54704E256024E   v2测试网路由[非官方的]:0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3/0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
    
    address[] private whiteList=[0x35324BB546F9804039BD623878751CA0FF1b8a55];
    address[] private feeWhiteList=[0x35324BB546F9804039BD623878751CA0FF1b8a55];
    uint256[] shareData=
    [
        5000,      //流动性数量
        10000,     //持币分红要求的最小持币数量
        2000,     //合伙人，营销钱包分红时代币数量
        1*10**18    //持币分红时积攒的USDT最小数量
    ];
    constructor() ABSToken(
        "XPLST1.0",
        "XPLST1",
        210000,
        0xa39FcB63F950e7dAAB3C909cebf9E728E9503d46,//>营销钱包
        0x8a00C7040C3c0E0249c8e4E2Bd739f1AFa6817B0, //>项目方钱包
        shareHolders,      
        usdtAddress,
        swapRouterAddress,
        feeWhiteList,
        whiteList,          //>默认白名单列表
        10000,              //>白名单限购代币数量
        shareData,
        1){}               //合伙人地址锁仓时间[天]
}