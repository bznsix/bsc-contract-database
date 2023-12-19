// SPDX-License-Identifier: MIT

pragma solidity >=0.6.12;
interface TokenLike {
    function transferFrom(address,address,uint) external;
    function transfer(address,uint) external;
    function approve(address,uint) external;
    function balanceOf(address) external view  returns (uint);
}
interface FifaDonateLike {
    function getRecommend(address) external view returns(address);
}
interface LockLike {
    function lock(
        address owner,
        address token,
        bool isLpToken,
        uint256 amount,
        uint256 unlockDate,
        string  memory description
    ) external returns (uint256 id);
    function unlock(uint256 lockId) external;
}
contract FiFaLpFarm {

    mapping (address => uint) public wards;
    function rely(address usr) external  auth { wards[usr] = 1; }
    function deny(address usr) external  auth { wards[usr] = 0; }
    modifier auth {
        require(wards[msg.sender] == 1, "FiFaLpFarm/not-authorized");
        _;
    }

    struct UserInfo {
        uint256    lpBalance;
        uint256    amount; 
        uint256    weight;   
        int256     rewardDebt;
        uint256    harved;
        uint256    beharve;
        uint256    total;
        uint256[3][]  withdrawList;
        uint256[2][]  harveList;
        uint256[5][]  depositList;
        RecommendInfo[]  teamList;

    }
    struct RecommendInfo { 
        address    under;
        uint256    what;
        uint256    amount;
        uint256    time;
    }
    struct LpFarmInfo {  
        uint256    dayAmount;
        uint256    myAmount;
        uint256    lpBlance;
        uint256    lpUsed;
        uint256    beHarve;
        uint256    harved;
        uint256[3][]  withdrawList;
        uint256[2][]  harveList;
        uint256[5][]  depositList;
        RecommendInfo[]  teamList;
    }
    uint256   public acclpPerShare;
    uint256   public lastRewardBlock = 34173409;
    uint256   public valuePerBlock = 347222*1E13;
    uint256   public over;
    uint256   public lpSupply;
    TokenLike public token = TokenLike(0xc0756C6a815c8eE652e1a950EfC6Fc84B5481cb9);
    TokenLike public lptoken = TokenLike(0x247733E3607Ea5bc2DF6ae91e5E0beD52a434e08);
    FifaDonateLike public Donate = FifaDonateLike(0x69aFf112689A9ccb6FBb46976824aCEC8C829dc4);
    //address   public lockAddr = 0x5E5b9bE5fd939c578ABE5800a90C566eeEbA44a5;
    address   public lockAddr = 0x407993575c91ce7643a4d4cCACc9A98c36eE1BBE;
    address   public founder = 0x03Cd193525832bD7427E7e0c7CE1e2C9AfcdC42F;
    mapping (address => UserInfo) public userInfo;


    event Deposit( address  indexed  owner,
                   uint256           wad
                  );
    event Harvest( address  indexed  owner,
                   uint256           wad
                  );
    event Withdraw( address  indexed  owner,
                    uint256           wad
                 );

        // --- Math ---
    function add(uint x, int y) internal pure returns (uint z) {
        z = x + uint(y);
        require(y >= 0 || z <= x);
        require(y <= 0 || z >= x);
    }
    function sub(uint x, int y) internal pure returns (uint z) {
        z = x - uint(y);
        require(y <= 0 || z <= x);
        require(y >= 0 || z >= x);
    }
    function mul(uint x, int y) internal pure returns (int z) {
        z = int(x) * y;
        require(int(x) >= 0);
        require(y == 0 || z / y == int(x));
    }
    function add(uint x, uint y) internal pure returns (uint z) {
        require((z = x + y) >= x);
    }
    function sub(uint x, uint y) internal pure returns (uint z) {
        require((z = x - y) <= x);
    }
    function mul(uint x, uint y) internal pure returns (uint z) {
        require(y == 0 || (z = x * y) / y == x);
    }
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0); // Solidity only automatically asserts when dividing by 0
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    
        return c;
      }
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a % b;
    }

    function sub(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a - b;
        require((b >= 0 && c <= a) || (b < 0 && c > a), "FiFaLpFarm/SignedSafeMath: subtraction overflow");

        return c;
    }
    function add(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a + b;
        require((b >= 0 && c >= a) || (b < 0 && c < a), "FiFaLpFarm/SignedSafeMath: addition overflow");

        return c;
    }
    function toUInt256(int256 a) internal pure returns (uint256) {
        require(a >= 0, "Integer < 0");
        return uint256(a);
    }
    //0x3949F3eDb71764f091e9c0517a9FE4877e58F28A
    constructor() {
        wards[msg.sender] = 1;
        init();
    }
    function init() public {
        TokenLike(lptoken).approve(lockAddr, ~uint256(0));
    }
    function setlastRewardBlock(uint startblock) external auth {
        lastRewardBlock = startblock;
    }
    function setover() public auth{
        if (over == 0)  {
            updateReward();
            over = 1;
        }
        else over = 0;
    }
    function setvaluePerBlock(uint256 _valuePerBlock) public auth{
        updateReward();
        valuePerBlock = _valuePerBlock;
    }
    function setAddress(uint what,address ust) external auth {
        if(what ==1) token = TokenLike(ust);
        else if(what ==2) lptoken = TokenLike(ust); 
        else if(what ==3) Donate = FifaDonateLike(ust);
        else if(what ==4) founder = ust;
    }
    //The pledge LP  
    function deposit(uint _amount,uint _day) public {
        require(_day <= 180, "FiFaLpFarm/1");
        updateReward();
        lptoken.transferFrom(msg.sender, address(this), _amount);
        UserInfo storage user = userInfo[msg.sender]; 
        user.amount = add(user.amount,_amount);
        uint weight = _amount*(100+_day)/100;
        user.weight +=  weight;
        lpSupply += weight;
        user.rewardDebt = add(user.rewardDebt,int256(mul(weight,acclpPerShare) / 1e18));
        uint256 id;
        if(_day>0) id = LockLike(lockAddr).lock(address(this), address(lptoken), true, _amount,block.timestamp+_day*86400, "");
        uint256[5] memory list = [_amount,_day,0,block.timestamp,id];
        user.depositList.push(list); 
        //
        address recommender = Donate.getRecommend(msg.sender);
        if(recommender ==address(0)) recommender = founder;
        UserInfo storage user1 = userInfo[recommender];
        uint reweight = weight/4;
        user1.weight +=  reweight;
        lpSupply += reweight;
        user1.rewardDebt = add(user1.rewardDebt,int256(mul(reweight,acclpPerShare) / 1e18));
        RecommendInfo memory list1;
            list1.under = msg.sender;
            list1.what = 1;
            list1.amount = reweight;
            list1.time = block.timestamp;
        user1.teamList.push(list1);
        emit Deposit(msg.sender,_amount);     
    }

    //Update mining data
    function updateReward() internal {
        if (over == 1) return;
        if (block.number <= lastRewardBlock) {
            return;
        }
        if (lpSupply == 0) {
            lastRewardBlock = block.number;
            return;
        }
        uint256 blocks = sub(block.number,lastRewardBlock);
        uint256 lotReward = div(mul(mul(valuePerBlock,blocks),uint(1e18)),lpSupply);
        acclpPerShare = add(acclpPerShare,lotReward);
        lastRewardBlock = block.number; 
    }
    //The harvest from mining
    function harvest() public returns (uint256) {
        return harvestForOther(msg.sender);  
    }
    function harvestForOther(address usr) public returns (uint256) {
        updateReward();
        UserInfo storage user = userInfo[usr];
        int256 accumulatedlp = int(mul(user.weight,acclpPerShare) / 1e18);
        uint256 _pendinglp = toUInt256(sub(accumulatedlp,user.rewardDebt));

        // Effects
        user.rewardDebt = accumulatedlp;

        // Interactions
        if (_pendinglp != 0) {
            token.transfer(usr, _pendinglp);
            user.harved = add(user.harved,_pendinglp);
            uint256[2] memory list = [_pendinglp,block.timestamp];
            user.harveList.push(list);
        } 
        emit Harvest(usr,_pendinglp); 
       return  _pendinglp;    
    }
    //Withdrawal pledge currency
    function withdraw(uint order,uint256 _amount) public {
        if(_amount ==0 || order ==0) return;
        updateReward();
        UserInfo storage user = userInfo[msg.sender];
        uint[5] storage id = user.depositList[order-1];
        require(block.timestamp >= id[3] + id[1]*86400, "FiFaLpFarm/2");
        require(_amount <= id[0]-id[2], "FiFaLpFarm/3");
        if(id[1]>0 && id[2]==0)  LockLike(lockAddr).unlock(id[4]);
        id[2] += _amount;
        uint weight = _amount*(100+id[1])/100;
        user.weight -=  weight;
        lpSupply -= weight;
        user.rewardDebt = sub(user.rewardDebt,int(mul(weight,acclpPerShare) / 1e18));
        user.amount = sub(user.amount,_amount);
        lptoken.transfer(msg.sender, _amount);
        uint256[3] memory list = [order,_amount,block.timestamp];
        user.withdrawList.push(list);
        //
        address recommender = Donate.getRecommend(msg.sender);
        if(recommender ==address(0)) recommender = founder;
        UserInfo storage user1 = userInfo[recommender];
        uint reweight = weight/4;
        user1.weight -=  reweight;
        lpSupply -= reweight;
        user1.rewardDebt = sub(user1.rewardDebt,int256(mul(reweight,acclpPerShare) / 1e18));
        RecommendInfo memory list1;
            list1.under = msg.sender;
            list1.what = 2;
            list1.amount = reweight;
            list1.time = block.timestamp;
        user1.teamList.push(list1);
        emit Withdraw(msg.sender,_amount);     
    }

    function getUserInfo(address usr) public view returns (UserInfo memory user) {
       user = userInfo[usr];
       user.beharve = beharvest(usr);
       user.total = user.harved + user.beharve;
       user.lpBalance = lptoken.balanceOf(usr);
    }

    //Estimate the harvest
    function beharvest(address usr) public view returns (uint256) {
        if(lpSupply ==0 || block.number<=lastRewardBlock) return 0;
        uint256 blocks = sub(block.number,lastRewardBlock);
        uint256 lotReward = div(mul(mul(valuePerBlock,blocks),uint(1e18)),lpSupply);
        uint256 _acclpPerShare = add(acclpPerShare,lotReward);
        UserInfo storage user = userInfo[usr];
        int256 accumulatedlp = int(mul(user.weight,_acclpPerShare) / 1e18);
        uint256 _pendinglp = toUInt256(sub(accumulatedlp,user.rewardDebt));
        return _pendinglp;
    }
    function getLpFarm(address usr) public view returns(LpFarmInfo memory lpFarmInfo){
        UserInfo memory user = userInfo[usr];
        lpFarmInfo.dayAmount = mul(valuePerBlock,uint(28800));
        if(lpSupply !=0) lpFarmInfo.myAmount = div(mul(mul(valuePerBlock,uint(28800)),user.weight),lpSupply);
        lpFarmInfo.lpBlance = lptoken.balanceOf(usr);
        lpFarmInfo.lpUsed = user.amount;
        lpFarmInfo.beHarve = beharvest(usr);
        lpFarmInfo.harved = user.harved;
        uint length = user.depositList.length;
        lpFarmInfo.depositList = new uint256[5][](length);
        for(uint i=0;i<length;i++){
            lpFarmInfo.depositList[i]=user.depositList[length-1-i];
        }
        uint length1 = user.withdrawList.length;
        lpFarmInfo.withdrawList = new uint256[3][](length1);
        for(uint i=0;i<length1;i++){
            lpFarmInfo.withdrawList[i]=user.withdrawList[length1-1-i];
        }
        uint length2 = user.harveList.length;
        lpFarmInfo.harveList = new uint256[2][](length2);
        for(uint i=0;i<length2;i++){
            lpFarmInfo.harveList[i]=user.harveList[length2-1-i];
        }
        uint length3 = user.teamList.length;
        lpFarmInfo.teamList = new RecommendInfo[](length3);
        for(uint i=0;i<length3;i++){
            lpFarmInfo.teamList[i]=user.teamList[length3-1-i];
        }
    }
    function unlock(uint256 id) public auth {
        LockLike(lockAddr).unlock(id);
    }
    function withdraw(address asses, uint256 amount, address ust) public auth {
        TokenLike(asses).transfer(ust, amount);
    }
 }