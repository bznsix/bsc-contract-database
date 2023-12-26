pragma solidity ^0.6.0;
// SPDX-License-Identifier: Unlicensed

 interface IUniswapV2Pair {
    function totalSupply() external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function balanceOf(address owner) external view returns (uint256);

    function token0() external view returns (address);

    function token1() external view returns (address);

    function getReserves()
        external
        view
        returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
}
interface IERC20 {
    function totalSupply() external view returns (uint);

    function balanceOf(address account) external view returns (uint);

    function transfer(address recipient, uint amount) external returns (bool);

    function allowance(
        address owner,
        address spender
    ) external view returns (uint);

    function approve(address spender, uint amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
}


contract spark   {
 
    uint256 public ranking;
    uint256 public LuckyPool;
    uint256 public LuckyRank;
    uint256 public LuckyNumber;
    uint256 public minus = 10000;
    mapping(uint256 => LuckyPoolUser) public LuckyPooltoUser;

    IERC20 BNK;

    mapping(uint256 => uint256) public leader;
    uint256 public leaderRanking;

    mapping(uint256 => address) public RankToaddress;
    mapping(address => uint256) public addressToRank;
    mapping(uint256 => User) public ranktoUser;
    struct User {
        uint8 level; // 等级
        uint256 BNBblance; // 可提BNB数
        uint256 joinBNBblance; // 参与BNB总额
        uint256 examineTime; // 参与时间
        uint256 recommend; // 推荐人数
        uint256 superiorRank; // 上级推荐人的ID
        uint256 time1; // 最近直推人时间1
        uint256 time2; // 最近直推人时间2 
        uint256 teamIncomebonus; //团队奖金
        uint256 allocationbonus; // 公排奖金
        uint256 Luckybonus; // 奖池奖金
        uint256 SpecialRewardbonus; // 特别礼物
     }
    mapping(address=> address[]) private teamUsers;
    uint256 SpecialRewardsblance; // 特别礼物

    address _Manager; // 拥有者

    struct LuckyPoolUser {
        address grandPrizeAddress; // 特等奖
        address firstPrizeAddress; // 一等奖
        address secondPrizeAddress; // 二等奖
        uint256 grandPrizeBNBblance; //  特等奖
        uint256 firstPrizeBNBblance; // 一等奖
        uint256 secondPrizeBNBblance; // 二等奖
    }


    constructor()
    public {
        _Manager = msg.sender;
        BNK  = IERC20(0x04e1eEa12acbe2Efb00d9e3B52d8d0f325ff8539);

    }

     

  function register(address Raddres ) public payable {
    ranking +=1; 
    if (msg.value == 1 ether/100000){
        ranktoUser[ranking].level = 1;
                BNK.transfer(msg.sender, 50e18*minus/10000);

    
    }
    else  if (msg.value == 2 ether/100000){
        ranktoUser[ranking].level = 2;
                BNK.transfer(msg.sender, 100e18*minus/10000);

    }
    else if (msg.value == 4 ether/100000){
        ranktoUser[ranking].level = 3;
                BNK.transfer(msg.sender, 200e18*minus/10000);

      }
    else if (msg.value == 6 ether/100000){
        ranktoUser[ranking].level = 4;
                BNK.transfer(msg.sender, 300e18*minus/10000);

    }
    else if (msg.value == 10 ether/100000){
        ranktoUser[ranking].level = 5;
                BNK.transfer(msg.sender, 800e18*minus/10000);

        // addleader(ranking);
    }
    else{
        require(false,"out value");
    }


    //    if (Rank == 1 ){
    //     ranktoUser[ranking].level = 1;
    //     BNK.transfer(msg.sender, 50e18*minus/10000);


    // }
    // else  if (Rank == 2 ){
    //     ranktoUser[ranking].level = 2;
    //     BNK.transfer(msg.sender, 100e18*minus/10000);

    //  }
    // else if (Rank == 4 ){
    //     ranktoUser[ranking].level = 3;
    //     BNK.transfer(msg.sender, 200e18*minus/10000);

    //    }
    // else if (Rank == 6 ){
    //     ranktoUser[ranking].level = 4;
    //     BNK.transfer(msg.sender, 300e18*minus/10000);

    // }
    // else if (Rank == 10 ){
    //     ranktoUser[ranking].level = 5;
    //     BNK.transfer(msg.sender, 800e18*minus/10000);

    //  }
    // else{
    //     require(false,"out value");
    // }
        minus = minus*9900/10000;


    uint256  superiorRank =   addressToRank[Raddres];
    if (superiorRank > 0){
      ranktoUser[ranking].superiorRank = superiorRank;
      ranktoUser[superiorRank].recommend += 1;
      teamUsers[Raddres].push(msg.sender);
      if(ranktoUser[superiorRank].time1 < ranktoUser[superiorRank].time2){
          ranktoUser[superiorRank].time1 = block.timestamp;
      }else {
          ranktoUser[superiorRank].time2 = block.timestamp;
      }
       
 


    }

    ranktoUser[ranking].examineTime = block.timestamp;
    addressToRank[msg.sender] = ranking;
    // ranktoUser[ranking].joinBNBblance = msg.value;
    // teamIncome(msg.sender,msg.value);
    // allocation(msg.sender,msg.value);
    RankToaddress[ranking] = msg.sender;

      Reinvestment_N(msg.value);
      // Reinvestment_N(Rank *1e18);
      

   }

 
  function Reinvestment() public payable {
      Reinvestment_N(msg.value);
      // Reinvestment_N(Rank);
   }


    function addleader(uint256 Rank) private {
        leaderRanking+=1;
        leader[leaderRanking] = ranking;
       if(ranktoUser[Rank].time1 < ranktoUser[Rank].time2){
          ranktoUser[Rank].time1 = block.timestamp;
      }else {
          ranktoUser[Rank].time2 = block.timestamp;
      }

    }


     function addcs(uint256 Rank ) public {
        require(msg.sender == _Manager, "8888"); 

        ranktoUser[Rank].BNBblance += 10 ether;

    }
  function getTeamUsers( address selfRank) public view returns(address[] memory) {
        return teamUsers[selfRank];
    }
 


  function Reinvestment_N(uint256 amount) private {

    uint256  selfRank =   addressToRank[msg.sender];

    if (ranktoUser[selfRank].joinBNBblance<10 ether){
        if (ranktoUser[selfRank].joinBNBblance + amount >= 10 ether){
            addleader(selfRank);
        }

    }
    ranktoUser[selfRank].joinBNBblance += amount;
    
    teamIncome(msg.sender,msg.value);
    allocation(msg.sender,msg.value);
    AddLuckyPool(ranktoUser[selfRank].superiorRank , selfRank, amount/20);

   }
  //  31785300000000000000
//    29506770000000000000
    function AddLuckyPool(uint256 superiorRank,uint256 selfRank,uint256 amount) private   {
    

      LuckyPool += amount;
      uint256  bonus = 0;

      if(LuckyPool*getPrice()/1e18 >= 3000e18/100000){
            LuckyNumber+=1;
          ranktoUser[selfRank].BNBblance += LuckyPool/10;
          ranktoUser[selfRank].Luckybonus += LuckyPool/10;
          LuckyPooltoUser[LuckyNumber].firstPrizeAddress = RankToaddress[selfRank];
          LuckyPooltoUser[LuckyNumber].firstPrizeBNBblance = LuckyPool/10;



          bonus +=LuckyPool/10;
           if (superiorRank > 0&&ranktoUser[superiorRank].recommend >2){
              ranktoUser[superiorRank].BNBblance += LuckyPool*35/100;
              ranktoUser[superiorRank].Luckybonus += LuckyPool*35/100;

            LuckyPooltoUser[superiorRank].grandPrizeAddress = RankToaddress[superiorRank];
            LuckyPooltoUser[superiorRank].grandPrizeBNBblance  = LuckyPool*35/100;

              bonus +=LuckyPool*35/100;
          }
            ranktoUser[LuckyRank].BNBblance += LuckyPool*5/100;
            ranktoUser[LuckyRank].Luckybonus += LuckyPool*5/100;
            bonus +=LuckyPool*5/100;
            LuckyPooltoUser[LuckyRank].secondPrizeAddress = RankToaddress[LuckyRank];
            LuckyPooltoUser[LuckyRank].secondPrizeBNBblance  = LuckyPool*5/100;


          LuckyPool-=bonus;



      } 

      LuckyRank = selfRank;
         


      


     }

 
    // function getPrice() public pure returns (uint256) {
    //   return 270*1e18 ;
    //    }
    function getPrice() public view returns (uint256) {
          address usdt = 0x55d398326f99059fF775485246999027B3197955;
        IUniswapV2Pair pairContract = IUniswapV2Pair(0x16b9a82891338f9bA80E2D6970FddA79D1eb0daE);
        (uint256 reserve0, uint256 reserve1, ) = pairContract.getReserves();
        uint256 usdtBalance = usdt == pairContract.token0()
            ? reserve0
            : reserve1;
        uint256 bhBalance = usdt == pairContract.token0() ? reserve1 : reserve0;
        return usdtBalance*(1e18)/(bhBalance);
    }
 

 
// 团队收益
  function teamIncome(address Raddres,uint256 amount) private      {

    uint256 ranks = addressToRank[Raddres];
    if(ranktoUser[ranks].superiorRank == 0){
      return ;
    }

    User  storage user = ranktoUser[ranktoUser[ranks].superiorRank];
       uint i = 1;
      while ( i < 8) {

        if(i<3){
          if(i == 1){
            user.BNBblance += amount/100*12;
            user.teamIncomebonus += amount/100*12;
          }
          if(i == 2){
            user.BNBblance += amount/100*8;
            user.teamIncomebonus += amount/100*8;
          }
        }else if (i>=3 &&i<5&&user.recommend>=2){
            if(i == 3){
            user.BNBblance += amount/100*5;
            user.teamIncomebonus += amount/100*5;
          }if(i == 4){
            user.BNBblance += amount/100*5;
            user.teamIncomebonus += amount/100*5;
          }
        }else if (i>=5 &&i<8&&user.recommend>=4){
          if(i == 5){
            user.BNBblance += amount/100*10;
            user.teamIncomebonus += amount/100*10;
          }
          if(i == 6){
            user.BNBblance += amount/100*8;
            user.teamIncomebonus += amount/100*8;
          }if(i == 7){
            user.BNBblance += amount/100*2;
            user.teamIncomebonus += amount/100*2;
          }
        }
          if(ranktoUser[ranks].superiorRank>0){
            user = ranktoUser[ranktoUser[ranks].superiorRank];
            ++i;
          }else {
             i = 8;
          } 
        }
  }


  // 公排收益
  function allocation(address Raddres,uint256 amount) private {

    uint256 ranks = addressToRank[Raddres];
    // User  memory user = ranktoUser[ranks];
      uint i = 1;
      while ( i < 26) {

        if(ranks>i){
          if (i<= 5){
              ranktoUser[ranks - i].BNBblance += amount/100;
          }else if (i>5 &&i<= 13 && ranktoUser[ranks - i].level > 1 ){
              ranktoUser[ranks - i].BNBblance += amount/100;
              ranktoUser[ranks - i].allocationbonus += amount/100;
          }else if (i>13 &&i<= 16 && ranktoUser[ranks - i].level >2){
              ranktoUser[ranks - i].BNBblance += amount/100;
              ranktoUser[ranks - i].allocationbonus += amount/100;
          }
          else if (i>16 &&i<= 19 && ranktoUser[ranks - i].level > 3){
              ranktoUser[ranks - i].BNBblance += amount/100;
              ranktoUser[ranks - i].allocationbonus += amount/100;
          }
          else if (i>19 &&i<= 25 && ranktoUser[ranks - i].level > 4){
              ranktoUser[ranks - i].BNBblance += amount/100;
              ranktoUser[ranks - i].allocationbonus += amount/100;
          }
        }
            ++i;
        }

      uint j = 1;


      while ( j < 11) {

        if(j + ranks<ranking){
          if (j<= 5){
              ranktoUser[ranks + j].BNBblance += amount/100;
              ranktoUser[ranks + j].allocationbonus += amount/100;
          }else if (i>5 &&j<= 13 && ranktoUser[ranks + j].level > 1 ){
              ranktoUser[ranks + j].BNBblance += amount/100;
              ranktoUser[ranks + j].allocationbonus += amount/100;
          }else if (i>13 &&j<= 16 && ranktoUser[ranks + j].level >2){
              ranktoUser[ranks + j].BNBblance += amount/100;
              ranktoUser[ranks + j].allocationbonus += amount/100;
          }
          else if (i>16 &&j<= 19 && ranktoUser[ranks + j].level > 3){
              ranktoUser[ranks + j].BNBblance += amount/100;
              ranktoUser[ranks + j].allocationbonus += amount/100;
          }
          else if (i>19 &&j<= 25 && ranktoUser[ranks + j].level > 4){
              ranktoUser[ranks + j].BNBblance += amount/100;
              ranktoUser[ranks + j].allocationbonus += amount/100;
          }
        }
            ++j;
        }
  }


  
   function withdraw( uint256 value) public    {

     if (ranktoUser[addressToRank[msg.sender]].BNBblance >= value) {
        ranktoUser[addressToRank[msg.sender]].BNBblance  -= value;
         SpecialRewardsblance+=(value/100);
        value -= value/20;
        uint256 BNBbl =    getBNBValue(msg.sender);
        address payable owner = address(uint160( msg.sender));
         Reinvestment_N(value - value*BNBbl/100) ;
        owner.transfer(value*BNBbl/100);
        // BNK.transfer(msg.sender, value*BNBbl/100);

     }
   }



  // 特别奖励   
   function SpecialRewards( ) public     {
    require(msg.sender == _Manager, "8888"); 

      uint j = 1;
      while ( j <= leaderRanking) {
        if(block.timestamp - ranktoUser[leader[j]].examineTime <  2678400 ){
          ranktoUser[leader[j]].BNBblance += SpecialRewardsblance/leaderRanking;
         ranktoUser[leader[j]].SpecialRewardbonus += SpecialRewardsblance/leaderRanking;

        }else {
          if(block.timestamp - ranktoUser[leader[j]].time1 <  2678400 && 
            block.timestamp - ranktoUser[leader[j]].time2<  2678400 ){
              ranktoUser[leader[j]].BNBblance += SpecialRewardsblance/leaderRanking;
              ranktoUser[leader[j]].SpecialRewardbonus += SpecialRewardsblance/leaderRanking;
          }
        }
            ++j;
        }
   }







    function getBNBValue(address Raddres) public view returns (uint256 bl)   {

        uint256 ranks = addressToRank[Raddres];
        User  memory user = ranktoUser[ranks];
    
     

  
          if(user.recommend>10&&user.joinBNBblance>6 ether){
               return 80;
          }
          else if(user.recommend>8&&user.joinBNBblance>6 ether){
            return 75;
          }
          else if(user.recommend>6&&user.joinBNBblance>6 ether){
            return 70;
           }
          else if(user.recommend>4&&user.joinBNBblance>4 ether){
            return 60;
           }
          else if(user.recommend>2&&user.joinBNBblance>2 ether){
          return 50;
           }else {
             return 40;
           }

       

 
        
     

      
  }


         
 
   

  function getbn(address addres) public{
      require(msg.sender == _Manager, "8888"); 
      address payable _Manager = address(uint160(addres));
      _Manager.transfer(address(this).balance);
  }

 
    








   
}