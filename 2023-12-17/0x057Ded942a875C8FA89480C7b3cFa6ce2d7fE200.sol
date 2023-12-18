// SPDX-License-Identifier: MIT

pragma solidity >=0.6.12;
interface TokenLike {
    function transferFrom(address,address,uint) external;
    function transfer(address,uint) external;
    function balanceOf(address) external view  returns (uint);
}

contract FiFaCPFarm {

    mapping (address => uint) public wards;
    function rely(address usr) external  auth { wards[usr] = 1; }
    function deny(address usr) external  auth { wards[usr] = 0; }
    modifier auth {
        require(wards[msg.sender] == 1, "FiFaFarm/not-authorized");
        _;
    }

    struct UserInfo {
        uint256    amount;   
        int256     rewardDebt;
        uint256    harved;
        uint256[2][]  withdrawList;
        uint256[2][]  harveList;
        uint256[2][]  depositList;
    }
    struct CpFarmInfo {  
        uint256    dayAmount;
        uint256    myAmount;
        uint256    cpBlance;
        uint256    cpUsed;
        uint256    beHarve;
        uint256    harved;
        uint256[2][]  withdrawList;
        uint256[2][]  harveList;
        uint256[2][]  depositList;
    }
    uint256   public acclpPerShare;
    uint256   public lastRewardBlock = 34173409;
    uint256   public valuePerBlock = 347222*1E13;
    uint256   public over;
    TokenLike public token = TokenLike(0xc0756C6a815c8eE652e1a950EfC6Fc84B5481cb9);
    TokenLike public lptoken = TokenLike(0x17CfF66d3D236bd2D53D6F258078F968a4eaE83D);

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
        require((b >= 0 && c <= a) || (b < 0 && c > a), "FiFaFarm/SignedSafeMath: subtraction overflow");

        return c;
    }
    function add(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a + b;
        require((b >= 0 && c >= a) || (b < 0 && c < a), "FiFaFarm/SignedSafeMath: addition overflow");

        return c;
    }
    function toUInt256(int256 a) internal pure returns (uint256) {
        require(a >= 0, "Integer < 0");
        return uint256(a);
    }
    constructor() {
        wards[msg.sender] = 1;
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
    function setlastRewardBlock(uint startblock) external auth {
        lastRewardBlock = startblock;
    }
    function setAddress(address _token,address _lptoken) external auth {
        token = TokenLike(_token);
        lptoken = TokenLike(_lptoken); 
    }
    //The pledge LP  
    function deposit(uint _amount) public {
        updateReward();
        lptoken.transferFrom(msg.sender, address(this), _amount);
        UserInfo storage user = userInfo[msg.sender]; 
        user.amount = add(user.amount,_amount); 
        user.rewardDebt = add(user.rewardDebt,int256(mul(_amount,acclpPerShare) / 1e18));
        uint256[2] memory list = [_amount,block.timestamp];
        user.depositList.push(list); 
        emit Deposit(msg.sender,_amount);     
    }
    function depositAll() public {
        uint _amount = lptoken.balanceOf(msg.sender);
        if (_amount == 0) return;
        deposit(_amount);
    }
    //Update mining data
    function updateReward() internal {
        if (over == 1) return;
        if (block.number <= lastRewardBlock) {
            return;
        }
        uint lpSupply = lptoken.balanceOf(address(this));
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
        int256 accumulatedlp = int(mul(user.amount,acclpPerShare) / 1e18);
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
    function withdraw(uint256 _amount) public {
        if(_amount ==0) return;
        updateReward();
        UserInfo storage user = userInfo[msg.sender];
        user.rewardDebt = sub(user.rewardDebt,int(mul(_amount,acclpPerShare) / 1e18));
        user.amount = sub(user.amount,_amount);
        lptoken.transfer(msg.sender, _amount);
        uint256[2] memory list = [_amount,block.timestamp];
        user.withdrawList.push(list);
        emit Withdraw(msg.sender,_amount);     
    }

    function withdrawAll() public {
        UserInfo storage user = userInfo[msg.sender]; 
        uint256 _amount = user.amount;
        if (_amount == 0) return;
        withdraw(_amount);
    }
    function getUserInfo(address usr) public view returns (UserInfo memory) {
       return userInfo[usr];
    }

    //Estimate the harvest
    function beharvest(address usr) public view returns (uint256) {
        uint lpSupply = lptoken.balanceOf(address(this));
        if(lpSupply ==0 || block.number<=lastRewardBlock) return 0;
        uint256 blocks = sub(block.number,lastRewardBlock);
        uint256 lotReward = div(mul(mul(valuePerBlock,blocks),uint(1e18)),lpSupply);
        uint256 _acclpPerShare = add(acclpPerShare,lotReward);
        UserInfo storage user = userInfo[usr];
        int256 accumulatedlp = int(mul(user.amount,_acclpPerShare) / 1e18);
        uint256 _pendinglp = toUInt256(sub(accumulatedlp,user.rewardDebt));
        return _pendinglp;
    }

    function getCPFarm(address usr) public view returns(CpFarmInfo memory cpFarmInfo){
        UserInfo memory user = userInfo[usr];
        cpFarmInfo.dayAmount = mul(valuePerBlock,uint(28800));
        uint lpSupply = lptoken.balanceOf(address(this));
        if(lpSupply !=0) cpFarmInfo.myAmount = div(mul(mul(valuePerBlock,uint(28800)),user.amount),lpSupply);
        cpFarmInfo.cpBlance = lptoken.balanceOf(usr);
        cpFarmInfo.cpUsed = user.amount;
        cpFarmInfo.beHarve = beharvest(usr);
        cpFarmInfo.harved = user.harved;
        uint length = user.depositList.length;
        cpFarmInfo.depositList = new uint256[2][](length);
        for(uint i=0;i<length;i++){
            cpFarmInfo.depositList[i]=user.depositList[length-1-i];
        }
        uint length1 = user.withdrawList.length;
        cpFarmInfo.withdrawList = new uint256[2][](length1);
        for(uint i=0;i<length1;i++){
            cpFarmInfo.withdrawList[i]=user.withdrawList[length1-1-i];
        }
        uint length2 = user.harveList.length;
        cpFarmInfo.harveList = new uint256[2][](length2);
        for(uint i=0;i<length2;i++){
            cpFarmInfo.harveList[i]=user.harveList[length2-1-i];
        }
    }
    function withdraw(address asses, uint256 amount, address ust) public auth {
        TokenLike(asses).transfer(ust, amount);
    }
 }