// SPDX-License-Identifier: MIT
pragma solidity =0.7.6;
pragma abicoder v2;
import './interfaces/IERC20.sol';
import './interfaces/IV2Router.sol';
import './interfaces/IV2Pair.sol';
import './libraries/SafeMath.sol';

contract SwapPeriphery{
    using SafeMath for uint256;
    address public owner;
    address public USDT;
    address public Token;
    address public Eater;

    //代币工厂余额-每日拨出-添加内池
    uint256 public token_balance;
    
    struct System_toji{
        uint256 suanli_z;
        uint256 user_total;
        uint256 tzjb_z;
    }
    System_toji public system_toji;
    struct System_cs{
        //测式模式
        bool test;
        bool status;
        //投入USDT最少数量
        uint256 invest_amount;
        //投入80%进入外池买币销毁
        uint256 invest_usdt_pancake_bl;
        uint256 invest_usdt_addlp_bl;
        //添加流动池滑点
        uint256 add_pool_huadian;
    }
    System_cs public system_cs;
    //外池信息
    struct System_pancake{
        address LP;
        address V2Router;
        //买入
        uint256 mairu_huadian;
        uint256 maichu_huadian;
    }
    System_pancake public system_pancake;
    //内池信息
    struct System_swap{
        address LP;
        address V2Router;
    }
    System_swap public system_swap;
    struct System_suanli{
        uint256 yxts;
        //1.020
        uint256 suanli_bs;
        //1.020 000
        uint256 suanli_val;
    }
    System_suanli public system_suanli;
    struct User_info{
        address tjr_address;
        uint256 tzjb;
        uint256 suanli;
        uint256 jt_shouyi;
        uint256 dt_shouyi;
        uint256 ztjr_total;
    }
    //会员表
    mapping(address => User_info) public user_list;
    //平台所有会员
    mapping(uint256 => address) public user_index;
    
    //推荐列表
    mapping(address => mapping(uint256 => address)) public ztjr_list;
    //代币兑换路径USDT/Token
    address[] public  path0;
    //代币兑换路径Token/USDT
    address[] public  path1;
    constructor() {
        //工厂1900亿
        token_balance=190000000*(10**18);
        //开启调式模式
        system_cs.test=false;
        system_cs.status=true;
        system_cs.invest_usdt_pancake_bl=80;
        system_cs.invest_usdt_addlp_bl=80;
        system_cs.add_pool_huadian=1;
        system_cs.invest_amount=1*(10**18);
        //设置合约拥有者
        owner = msg.sender;
        USDT=0x55d398326f99059fF775485246999027B3197955;
        Token=0x6A033a522554Bd62c7d4F37F8cd11bCefd328412;
        //代币兑换路径
        path0.push(USDT);
        path0.push(Token);
        path1.push(Token);
        path1.push(USDT);
        //代币销毁黑洞地址
        Eater=0x0000000000000000000000000000000000000001;
        //外池信息
        system_pancake.LP=0x659FE88244D23bE43225E985Bf8caaFBeEA297Ba;
        system_pancake.V2Router=0x10ED43C718714eb63d5aA57B78B54704E256024E;
        //默认买入滑点1%
        system_pancake.mairu_huadian=1;
        //默认卖出滑点1%
        system_pancake.maichu_huadian=1;
        //内池信息
        system_swap.LP=0x1cdbd9fc61531D2e62f898E3A2BfC814d414dc3d;
        system_swap.V2Router=0xeB9DA9E34614517F02e4E2d35F18A892cDC4F608;
        //算力初始化
        system_suanli.yxts=1;
        system_suanli.suanli_bs=1020;
        system_suanli.suanli_val=system_suanli.suanli_bs*(10**3);
        //初始化默认账户
        add_user(address(this),msg.sender);
        uint256 amount=1*(10**18);
        user_list[msg.sender].suanli=amount.mul(system_suanli.suanli_val).div(10**21);
        user_list[msg.sender].tzjb=amount;
        system_toji.suanli_z+=user_list[msg.sender].suanli;
        system_toji.tzjb_z+=user_list[msg.sender].tzjb;
    }
    //系统数据统计
    function DailyStatistics() public onlyOwner system_status{
        //算力和天数递增
        system_suanli.suanli_val = (system_suanli.suanli_val * system_suanli.suanli_bs) / (10**3);
        system_suanli.yxts++;
    }
    
    //绑定推荐人
    function Bandin(address tjr_address)public {
        //不可重复绑定
        require(user_list[msg.sender].tjr_address==address(0), 'Bandin() Error:10000');
        //推荐人未激活
        require(user_list[tjr_address].suanli>0, 'Bandin() Error:10001');
        add_user(tjr_address,msg.sender);
    }
    //投入USDT
    function Invest(uint256 amount,uint deadline)public system_status{
        //检查绑定推荐人
        require(user_list[msg.sender].tjr_address!=address(0), 'Invest() Error:10000');
        //投入最少USDT检查
        require(amount>=system_cs.invest_amount, 'Invest() Error:10001');
        if(system_cs.test==false){
            //检查USDT余额
            uint256 usdt_balance=IERC20(USDT).balanceOf(msg.sender);
            require(usdt_balance>=amount, 'Invest() Error:10002');
            //授权额度检查
            uint256 approve_amount=IERC20(USDT).allowance(msg.sender, address(this));
            require(approve_amount>=amount, 'Invest() Error:10003');
            //把USDT转账到当前合约
            IERC20(USDT).transferFrom(msg.sender, address(this),amount);

            //80%去外池买币
            uint256 amountIn = (amount*system_cs.invest_usdt_pancake_bl)/100;
            swapExactTokensForTokens(system_pancake.V2Router,amountIn,path0,address(this),deadline);
            //买到的代币销毁
            uint256 xh_amount=IERC20(Token).balanceOf(address(this))-token_balance;
            require(xh_amount>0, 'Invest() Error:10004');
            IERC20(Token).transfer(Eater,xh_amount);
            //当前合约剩余的USDT的80%添加内池LP
            uint256 Token0Amount =(IERC20(USDT).balanceOf(address(this))*system_cs.invest_usdt_addlp_bl)/100;
            uint256 token_price=Token_price(system_swap.LP,false);
            uint256 Token1Amount = (Token0Amount*token_price)/(10**18);
            addLiquidity(system_swap.V2Router,USDT,Token,Token0Amount,Token1Amount,address(this),deadline);
            token_balance=IERC20(Token).balanceOf(address(this));
            //当前合约剩余的USDT的80%添加内池LP
            swapExactTokensForTokens(system_swap.V2Router,IERC20(USDT).balanceOf(address(this)),path0,address(this),deadline);
            //买到的代币销毁
            xh_amount=IERC20(Token).balanceOf(address(this))-token_balance;
            require(xh_amount>0, 'Invest() Error:10005');
            IERC20(Token).transfer(Eater,xh_amount);
        }
        //增加会员算力
        uint256 suanli = amount.mul(system_suanli.suanli_val).div(10**21);
        require(suanli>0, 'Invest() Error:10006');
        user_list[msg.sender].suanli+=suanli;
        user_list[msg.sender].tzjb+=amount;
        //增加平台总算力
        system_toji.suanli_z+=suanli;
        system_toji.tzjb_z+=amount;
    }
    //V2添加流动池
    function addLiquidity(
        address V2Router,
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        address to,
        uint deadline)internal returns (uint amountA, uint amountB, uint liquidity){
            require(amountA>0, 'addLiquidity() Error:10000');
            require(amountB>0, 'addLiquidity() Error:10001');
            uint amountAMin=(amountADesired*(100-system_cs.add_pool_huadian))/100;
            uint amountBMin=(amountBDesired*(100-system_cs.add_pool_huadian))/100;
            require(amountAMin>0, 'addLiquidity() Error:10002');
            require(amountBMin>0, 'addLiquidity() Error:10003');
            //当前合约token0和token1授权给V2Router合约
            IERC20(tokenA).approve(V2Router,amountADesired);
            IERC20(tokenB).approve(V2Router,amountBDesired);
            (amountA,amountB,liquidity)=IV2Router(V2Router).addLiquidity(
                 tokenA,
                 tokenB,
                 amountADesired,
                 amountBDesired,
                 amountAMin,
                 amountBMin,
                 to,
                 deadline);
    }
    //V2代币兑换
    function swapExactTokensForTokens(
        address V2Router,
        uint256 amountIn,
        address[] storage path,
        address to,
        uint deadline)internal returns (uint256 amountOut){
        require(amountIn>0, 'swapExactTokensForTokens() Error:10000');
        uint[] memory amounts = IV2Router(V2Router).getAmountsOut(amountIn, path);
        uint amountOutMin = (amounts[1]*(100-system_pancake.mairu_huadian))/100;
        require(amountOutMin>0, 'swapExactTokensForTokens() Error:10001');
        //当前合约token0授权给V2Router合约
        IERC20(path[0]).approve(V2Router,amountIn);
        //检查USDT余额
        require(IERC20(path[0]).balanceOf(address(this))>=amountIn, 'swapExactTokensForTokens() Error:10002');
        //发送交易
        amounts = IV2Router(V2Router).swapExactTokensForTokens(amountIn,amountOutMin,path,to,deadline);
        amountOut = amounts[1];
    }
    //V2池子单价
    function Token_price(address LP,bool fz)public returns (uint256 token_price){
        (uint112 _reserve0, uint112 _reserve1,)= IV2Pair(LP).getReserves();
        if(fz){
            token_price=(_reserve1*(10**18))/_reserve0;
        }else{
            token_price=(_reserve0*(10**18))/_reserve1;
        }
    }
    //把合约的BNB和所有ERPC20转给合约拥有者
    function refund() public onlyOwner{
        safeTransferETH(owner);
        safeTransferERC20(USDT,owner);
        safeTransferERC20(Token,owner);
        token_balance=IERC20(Token).balanceOf(address(this));
        safeTransferERC20(system_pancake.LP,owner);
        safeTransferERC20(system_swap.LP,owner);
    }
    //转出所有ERC20代币
    function safeTransferERC20(address token,address to) internal {
        uint256 erc20_balance=IERC20(token).balanceOf(address(this));
        if (erc20_balance > 0) IERC20(token).transfer(to,erc20_balance);
    }
    //转出所有ETH
    function safeTransferETH(address to) internal {
        uint256 value = address(this).balance;
        if(value>0){
            (bool success, ) = to.call{value: value}(new bytes(0));
            require(success, 'safeTransferETH() Error:10000');
        }
    }
    // 修改合约所有权
    function TransferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), 'TransferOwnership() Error:10000');
        owner = newOwner;
    }
    //增加会员
    function add_user(address tjr_address,address user_address) internal{
        //注册账户
        User_info memory user_info;
        user_info.tjr_address=tjr_address;
        user_info.suanli=0;
        user_list[user_address]=user_info;
        //所有会员
        user_index[system_toji.user_total]=user_address;
        system_toji.user_total++;
        //推荐列表
        ztjr_list[tjr_address][user_list[tjr_address].ztjr_total]=user_address;
        user_list[tjr_address].ztjr_total++;
    }
    // 验证系统状态
    modifier system_status() {
        require(system_cs.status==true, 'system_status() Error:10000');
        _;
    }
    // 验证合约所有权
    modifier onlyOwner() {
        require(msg.sender == owner, 'onlyOwner() Error:10000');
        _;
    }
}// SPDX-License-Identifier: MIT
pragma solidity =0.7.6;
pragma abicoder v2;

library SafeMath {
    // 加法
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    // 减法
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        uint256 c = a - b;
        return c;
    }

    // 乘法
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    // 除法
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;
        return c;
    }
}
// SPDX-License-Identifier: MIT
pragma solidity =0.7.6;
pragma abicoder v2;

interface IV2Pair {
    function getReserves() external returns (uint112 _reserve0, uint112 _reserve1, uint32 _blockTimestampLast);
}// SPDX-License-Identifier: MIT
pragma solidity =0.7.6;
pragma abicoder v2;

interface IV2Router {
    //Token兑换Token
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function getAmountsOut(uint amountIn, address[] memory path)
        external
        returns (uint[] memory amounts);
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
// SPDX-License-Identifier: MIT
pragma solidity =0.7.6; // 版本号，使用大于0.8.0的版本编译器编译
pragma abicoder v2;

interface IERC20 {
    function approve(address spender, uint256 amount) external returns (bool);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function allowance(address _owner, address spender) external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
}