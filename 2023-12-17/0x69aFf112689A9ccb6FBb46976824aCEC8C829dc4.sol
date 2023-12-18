// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
interface TokenLike {
    function transferFrom(address,address,uint) external;
    function transfer(address,uint) external;
    function balanceOf(address) external view returns (uint256);
}
contract FiFaDonate{
	// --- Auth ---
    mapping (address => uint) public wards;
    function rely(address usr) external  auth { wards[usr] = 1; }
    function deny(address usr) external  auth { wards[usr] = 0; }
    modifier auth {
        require(wards[msg.sender] == 1, "FiFaDonate/not-authorized");
        _;
    }

    TokenLike   public usdt = TokenLike(0x55d398326f99059fF775485246999027B3197955);
    TokenLike   public FiFaCP = TokenLike(0x17CfF66d3D236bd2D53D6F258078F968a4eaE83D);
    address     public funder = 0x95dEd8Cf893f22342d35E96E050899Cfd9876E92;
    uint256     public tier = 60;
    uint256     public leng = 60;
    uint256[]   public depositAmount = [200,500,1000];
    uint256[]   public rates = [0,200,210,220,80,40];
    uint256[]   public scales = [20,40,80,120,160,200,240];
    uint256[]   public vips = [0,100,300,600,1500,3000,6000];

    mapping (address => UserInfo)   public userInfo;

    struct UserInfo { 
        uint256   amount;
        address    recommender;
        address[]  underline;
        uint256    vip;
        uint256    performance;
        uint256    teamEarn;
        uint256    small;
        address    bigAddress;
        uint256[2][]  depositList;
        RecommendInfo[]  teamList;
    }
    struct RecommendInfo { 
        address    under;
        uint256    what;
        uint256    amount;
        uint256    time;
    }
    struct FirstInfo { 
        address    recommender;
        uint256    usdtAmount;
        uint256    cpBlance;
        uint256    cpAmount;
        uint256[3][]  depositList;
    }
	constructor(){
       wards[msg.sender] = 1;
    }

    function  setArray(uint what,uint256[] memory data) public auth{
        if(what==1) depositAmount = data;
        else if(what==2) rates = data;
        else if(what==3) scales = data;
        else if(what==4) vips = data;
    }

    function  file(uint what,address ust,uint256 data) public auth{
        if(what == 1)  usdt = TokenLike(ust);
        else if(what == 2)  FiFaCP =  TokenLike(ust);
        else if(what == 3)  funder =  ust;
        else if(what == 4)  tier =  data;
        else if(what == 5)  leng =  data;
    }

    function  setLevel(address usr,uint256 vip) public auth{
        userInfo[usr].vip = vip;
    }
    function setRecommend(address usr,address recommender) external auth {
        userInfo[usr].recommender = recommender;
        userInfo[recommender].underline.push(usr);
    }
    function getRecommend(address usr) external view returns(address recommender) {
        recommender = userInfo[usr].recommender;
    }
    function setUnder(address usr,address[] memory unlines) external auth {
        userInfo[usr].underline = unlines;
    }
	function deposit(uint wad,address recommender) external{
        require(wad>=depositAmount[0]*1E18,"FiFaDonate/1");
        UserInfo storage user = userInfo[msg.sender];
        if(user.recommender == address(0)) {
            require(userInfo[recommender].recommender != address(0),"FiFaDonate/2");
            user.recommender = recommender;
            userInfo[recommender].underline.push(msg.sender);
        }
        else recommender = user.recommender;
        usdt.transferFrom(msg.sender,funder,wad);
        user.amount +=wad;
        uint[2] memory data = [wad,block.timestamp];
        user.depositList.push(data);
        uint cpAmount = getMul(wad);
        FiFaCP.transfer(msg.sender,cpAmount);
        uint earnAmount;
        for(uint i=0;i<2;i++){
            earnAmount = cpAmount*rates[4+i]/1000;
            FiFaCP.transfer(recommender,earnAmount);
            RecommendInfo memory list;
                        list.under = msg.sender;
                        list.what = i;
                        list.amount = earnAmount;
                        list.time = block.timestamp;
            UserInfo storage up = userInfo[recommender];
            up.teamList.push(list);
            up.teamEarn +=earnAmount;
            recommender = up.recommender;
        }
        user.performance +=cpAmount;
        assignment(msg.sender,cpAmount);
    }
    function depositForNode(address usr,address recommender) external auth{
        uint wad = 1E21;
        UserInfo storage user = userInfo[usr];
        if(user.recommender == address(0)) {
            require(userInfo[recommender].recommender != address(0),"FiFaDonate/30");
            user.recommender = recommender;
            userInfo[recommender].underline.push(usr);
        }
        else recommender = user.recommender;
        user.amount +=wad;
        uint[2] memory data = [wad,block.timestamp];
        user.depositList.push(data);
        uint cpAmount = 220*wad;
        FiFaCP.transfer(usr,cpAmount);
        uint earnAmount;
        for(uint i=0;i<2;i++){
            earnAmount = cpAmount*rates[4+i]/1000;
            FiFaCP.transfer(recommender,earnAmount);
            RecommendInfo memory list;
                        list.under = usr;
                        list.what = i;
                        list.amount = earnAmount;
                        list.time = block.timestamp;
            UserInfo storage up = userInfo[recommender];
            up.teamList.push(list);
            up.teamEarn +=earnAmount;
            recommender = up.recommender;
        }
        user.performance +=cpAmount;
        assignment(usr,cpAmount);
    }
    function depositAuth(address usr,uint wad,address recommender) external auth{
        require(wad>=depositAmount[0]*1E18,"FiFaDonate/3");
        UserInfo storage user = userInfo[usr];
        if(user.recommender == address(0)) {
            require(userInfo[recommender].recommender != address(0),"FiFaDonate/4");
            user.recommender = recommender;
            userInfo[recommender].underline.push(usr);
        }
        else recommender = user.recommender;
        user.amount +=wad;
        uint[2] memory data = [wad,block.timestamp];
        user.depositList.push(data);
        uint cpAmount = getMul(wad);
        FiFaCP.transfer(usr,cpAmount);
        uint earnAmount;
        for(uint i=0;i<2;i++){
            earnAmount = cpAmount*rates[4+i]/1000;
            FiFaCP.transfer(recommender,earnAmount);
            RecommendInfo memory list;
                        list.under = usr;
                        list.what = i;
                        list.amount = earnAmount;
                        list.time = block.timestamp;
            UserInfo storage up = userInfo[recommender];
            up.teamList.push(list);
            up.teamEarn +=earnAmount;
            recommender = up.recommender;
        }
        user.performance +=cpAmount;
        assignment(usr,cpAmount);
    }
    function assignment(address usr,uint amount) internal{
        uint levelForLower = 0;
        bool lateral = false;
        uint lastRate = 0;
        uint level = 0;
        uint maxLevel = scales.length-1;
        address sender = usr;
        for(uint i=0;i<tier;i++) {
            address referrer = userInfo[usr].recommender;
            if(referrer == address(0)) break;
            if(level < maxLevel || (level == maxLevel && !lateral)){
                UserInfo storage up = userInfo[referrer];
                level = up.vip;
                uint wad = 0;
                if(level > levelForLower) {
                    wad = amount*(scales[level]-lastRate)/1000;
                    levelForLower = level;
                    lastRate = scales[level];
                    if(lateral) lateral = false;
                }
                else if(level >0 && level == levelForLower && !lateral){
                    wad = amount*scales[0]/1000;
                    lateral = true;
                }
                if(wad >0) {
                    FiFaCP.transfer(referrer,wad);
                    up.teamEarn +=wad;
                    RecommendInfo memory list;
                        list.under = sender;
                        list.what = 3;
                        list.amount = wad;
                        list.time = block.timestamp;
                    up.teamList.push(list);
                }
            }
            hierarchical(usr,amount);
            usr = referrer;
        }
    }
    function hierarchical(address usr,uint wad) internal{
        UserInfo storage user = userInfo[usr];
        address referrer = user.recommender;
        UserInfo storage up = userInfo[referrer];
        address bigAddress = up.bigAddress;
        uint maxvip = vips.length-1;
        if(up.small < vips[maxvip]*1E24 && bigAddress != usr){
            uint256 bigAmount = userInfo[bigAddress].performance;
            if(user.performance > bigAmount){
                uint beforAmount = user.performance - wad;
                up.small = up.small - beforAmount + bigAmount;
                up.bigAddress = usr;
            }else up.small += wad;
            uint i= up.vip;
            if(i< maxvip && up.small >=vips[i+1]*1E24) up.vip +=1;
        }
        up.performance += wad;
    }
    function getMul(uint wad) public view returns(uint cpAmount){
        uint rate;
        if(wad >depositAmount[2]*1E18) rate = rates[3];
        else if(wad <=depositAmount[2]*1E18 && wad >depositAmount[1]*1E18) rate = rates[2];
        else if(wad <=depositAmount[1]*1E18 && wad >=depositAmount[0]*1E18) rate = rates[1];
        else rate = rates[0];
        cpAmount = wad*rate;
    }
    function getUserInfo(address usr) public view returns(UserInfo memory user){
        user = userInfo[usr];
        uint length = user.teamList.length;
        uint len = leng;
        if(length < len) len = length;
        RecommendInfo[]  memory List = new RecommendInfo[](len);
        uint j=1;
        for(uint i=0;i<len;i++) {
            RecommendInfo memory list = user.teamList[length-j];
            List[i] = list;
            j++;
        }
        user.teamList = List;
    }
    function getFirst(address usr) public view returns(FirstInfo memory firstInfo){
        UserInfo memory user = userInfo[usr];
        uint length = user.depositList.length;
        firstInfo.depositList = new uint256[3][](length);
        for(uint i=0;i<length;i++){
            uint usdtamount = user.depositList[i][0];
            uint cpamount = getMul(usdtamount);
            uint time = user.depositList[i][1];
            firstInfo.depositList[length-1-i]=[usdtamount,cpamount,time];
            firstInfo.cpAmount += cpamount;
        }
        firstInfo.usdtAmount = user.amount;
        firstInfo.recommender = user.recommender;
        firstInfo.cpBlance = FiFaCP.balanceOf(address(this));
    }
    function withdraw(address asses, uint256 amount, address ust) public auth {
        TokenLike(asses).transfer(ust, amount);
    }
}