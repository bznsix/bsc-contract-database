// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;
pragma experimental ABIEncoderV2;

interface IERC20 {
    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address to, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(address from, address to, uint256 amount) external returns (bool);
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
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

   
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

   
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

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

   
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

   
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }


    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

contract ETBYCore is Ownable {
    using SafeMath for uint256;

    address constant public rootAddress = address(0x000000000000000000000000000000000000dEaD);
    address public tokenGiftaddress = address(0xf2f70494aB67Ae156977bdF2f481091673d9F352);
    receive() external payable {}
    mapping(address => uint256) public _dayBuyAmountMap;

    mapping(address => address[]) public inviteRecords; // 邀请记录  邀请人地址 => 被邀请人地址数组

    mapping(address => uint256) public total_pledage;

    struct Market{
        uint lockDays;
        uint amount;        
        uint outMultiple;   
    }

    Market[] public markets;

    address public awardToken;
    address[] private _dayBuyAddressList;

    //质押
    struct Order{
        uint lockDays;
        uint initTime;
        uint updateTimePrincipal;
        uint updateTimeProfit;
        // uint updateTimeInvite;
        uint updateTimeteam;
        uint endTime;
        uint amount;
        uint initAmount;
        uint outMultiple;
    }

    mapping(address => Order[]) public userInfo;

    struct Achievement{
        address sponsor;
        uint level;         
        uint teamAch;      
        uint selfAch;       
        uint directReferralCount;
        uint indirectReferralCount;

        uint teamSize;         // 团队人数
        uint indexPrincipal;
        uint indexProfit;
        uint firstAward; //一级总奖励
        uint secondAward; //二级总奖励
        uint teamAward;
        // uint256 ShouYiAmount;
        Order[] orders;
        Or[] referrals;     // 直接推荐人列表
    }

    mapping(address => Achievement) public achievements;

    IERC20 public token;
    uint256 public DAY = 86400;
    // uint256 public DAY = 300;
    uint256 public NetworkInfo;

    struct Or {
        address referrals; 
        uint256 ETBYamount;
        uint256 lockDays;
        uint256 ShouYiAmount;
    }

    constructor() {
        achievements[rootAddress].sponsor = address(0xdeaddead);
        // achievements[msg.sender].level = 1;
        awardToken = address(0x06fC3670a8908115A1D35fb861c0806D0f30cd2f);
        // awardToken = address(0x0Ca5eA2Bdfd3C7766C952b8FfB874c23210Dc536);    //测试网;
        token = IERC20(awardToken);
        markets.push(Market(1,0,101));    //0  1   1
        markets.push(Market(7,0,108));    //1  7   8
        markets.push(Market(15,0,118));    //2 15  18
        markets.push(Market(30,0,138));    //3 30  38 
        markets.push(Market(90,0,228));    //4 90  128
        markets.push(Market(180,0,360));   //5 180 260
    }

    struct PersonInfo{
        uint level;
        uint teamAch;
    }

    function setUser(address owner,uint level) public onlyOwner {
        Achievement storage a = achievements[owner];
        a.level = level;
    }

    function getUserInfos(address owner)external view returns(PersonInfo memory info){
        Achievement storage a = achievements[owner];
        info.level = a.level;
        info.teamAch = a.teamAch;
    }

    function getNetworkInfo() external view returns (uint256) {
        return NetworkInfo;
    }

    function pledge(uint index, uint256 _amount) external {
        Market storage m = markets[index];
        Achievement storage ach =  achievements[msg.sender];
        require(_amount >= 100  && _amount <= 1000  ,"100 ~ 1000 ");
        m.amount = _amount *(1e18) ;

        IERC20(awardToken).transferFrom(msg.sender, address(this), m.amount);
        NetworkInfo += m.amount;
        uint256 ETBY = m.amount * (m.outMultiple - 100) / 100; 
        _doPledge(msg.sender, m.amount, m.outMultiple, m.lockDays,ETBY);
        
        ach.referrals.push(Or(msg.sender,m.amount,m.lockDays,ETBY));
        if(_dayBuyAmountMap[msg.sender] == 0) { 
            _dayBuyAddressList.push(msg.sender);
        } 
        _dayBuyAmountMap[msg.sender] += m.amount;
        total_pledage[msg.sender] += m.amount;
    }   

    function _doPledge(address owner,uint256 _amount,uint outMultiple,uint256 _lockDays,uint256 ETBY)private{
        require(_amount > 0,"invalid");
        Achievement storage ach = achievements[owner];
        uint time = getCurrentTime();
        ach.orders.push(
            Order(
                _lockDays,
                time,
                time,
                time,
                time,
                time + _lockDays * DAY,
                _amount * outMultiple / 100,
                _amount,
                outMultiple 
            )
        );
        //业绩刷新
        ach.selfAch += _amount;
        _addAch(owner, _amount,ETBY);
        // _updateLevel(owner);
    }

    function _addAch(address owner,uint256 value,uint256 ETBY)internal{

        address[] memory farthers = getForefathers(owner,10);

        for( uint i ; i < 10; i++ ){

            address farther = farthers[i];

            if( farther == address(0)) break;

            Achievement storage fa = achievements[farther];
            // UserInfo storage user = userInfos[farther];

            fa.teamAch += value;
            //更新等级    主网要加上
            _updateLevel(farther);         
            // uint256 ShouYi = fa.ShouYiAmount;
            uint256 teamAward = getRewardPercentage(farther,ETBY);

            fa.teamAward += teamAward;
            // user.teamAwardHistory += teamAward;

        }
    }

    function _updateLevel(address owner) private  {
        Achievement storage ach = achievements[owner];
        uint oldLevel = ach.level;
        uint8 newLevel = _getLevel(owner);
        if( newLevel != oldLevel){
            ach.level = newLevel;
        }
    }

    function _getLevel(address owner) public view returns(uint8){
        Achievement storage ach = achievements[owner];
        if( ach.selfAch == 0 ) return 0;

        uint teamAch = ach.teamAch ;

        uint256 teamSize = queryTeamMemberCount(owner);

        if( teamSize >= 1500 && teamAch >= 5000000e18){   //
            return 5;
        } else if (teamSize >= 450 && teamAch >= 1250000e18){   //
            return 4;
        } else if (teamSize >= 150 && teamAch >= 250000e18){     //
            return 3;
        } else if (teamSize >= 45 && teamAch >= 50000e18){     //
            return 2;
        }else if (teamSize >= 15  && teamAch >= 15000e18){     //
            return 1;
        }
        return 0;
    }

    // 获取会员奖励百分比
    function getRewardPercentage(address member,uint256 value ) public view returns (uint256) {
        Achievement storage user = achievements[member];
        if (user.level == 1) {
            return value * 20 / 100;
        } else if (user.level == 2) {
            return value * 30 / 100;
        } else if (user.level == 3) {
            return value * 40 / 100;
        } else if (user.level == 4) {
            return value * 50 / 100;
        } else if (user.level == 5) {
            return value * 60 / 100;
        } else {
            return 0;
        }
    }

    // 领取本金
    function drawPrincipal()external returns(uint v1,uint v2) {
        
        Achievement storage user = achievements[msg.sender];

        Order[] storage orders = user.orders;
        uint index = user.indexPrincipal;

        uint time = getCurrentTime();

        for( uint i = index; i < orders.length; i++ ){
            Order storage order = orders[i];
            require(time > order.endTime,"Not yet");
            uint updateTimePrincipal = order.updateTimePrincipal;
            uint t = time > order.endTime ? order.endTime : time;
            if( t > updateTimePrincipal ){

                uint l = t - updateTimePrincipal;

                if( l > 0 ){
                    v1 += l *( order.amount / (order.lockDays * DAY) ) * 100 / order.outMultiple;

                }
                updateTimePrincipal = t;

                if( updateTimePrincipal >= order.endTime){

                    index = i + 1;
                }
                order.updateTimePrincipal = updateTimePrincipal;
            }
        }

        if( index > user.indexPrincipal ){
            user.indexPrincipal = index;
        }

        v2 = v1;

        if( v1 > 0 ){
            IERC20(awardToken).transfer(msg.sender, v1);
        }

    }

    function drawProfit()external returns(uint v1,uint v2) {

        Achievement storage user = achievements[msg.sender];

        Order[] storage orders = user.orders;
        uint index = user.indexProfit;

        uint time = getCurrentTime();
        for( uint i = index; i < orders.length; i++ ){
            Order storage order = orders[i];

            uint updateTimeProfit = order.updateTimeProfit;
            uint t = time > order.endTime ? order.endTime : time;
            if( t > updateTimeProfit ){

                uint l = t - updateTimeProfit;

                if( l > 0 ){
                    v1 += l *( order.amount / (order.lockDays * DAY) ) * (order.outMultiple.sub(100) ) / order.outMultiple;    //收益
                }
                updateTimeProfit = t;

                if( updateTimeProfit >= order.endTime){
                    index = i + 1;
                }
                order.updateTimeProfit = updateTimeProfit;
            }
        }

        if( index > user.indexProfit ){
            user.indexProfit = index;
        }

        if( v1 > 0 ){
            v2 = v1;
        }

        if( v2 > 0 ){
            IERC20(awardToken).transfer(msg.sender, v2 );
        }

        address parent = achievements[msg.sender].sponsor;
        Achievement storage ach = achievements[parent];
        ach.firstAward += v1 * 30 / 100;
        address secondParent = achievements[parent].sponsor;
        Achievement storage secondach = achievements[secondParent];
        secondach.secondAward += v1 * 10 / 100;
    }
    //计算用户收益
    function caldrawProfit() public view returns(uint v1){

        Achievement storage user = achievements[msg.sender];

        Order[] storage orders = user.orders;
        uint index = user.indexProfit;

        for( uint i = index; i < orders.length; i++ ){
            Order storage order = orders[i];
            v1 += order.amount  * (order.outMultiple.sub(100) ) / order.outMultiple;
            index = i + 1;
        }
    }

    function getCurrentTime()private view returns(uint){
        return block.timestamp ;
    }

    function setSwapTokensaddress(address _swapTokens) public onlyOwner {
        awardToken = _swapTokens;
    }

    function setTokensGiftaddress(address _swapTokens) public onlyOwner {
        tokenGiftaddress = _swapTokens;
    }

    function addRelationEx(address recommer) external returns (bool) {
        require(recommer != msg.sender,"your_self");
        require(achievements[msg.sender].sponsor == address(0x0),"binded");
        require(recommer == rootAddress || achievements[recommer].sponsor != address(0x0),"p_not_bind");

        inviteRecords[recommer].push(msg.sender);
        
        achievements[msg.sender].sponsor = recommer;
        achievements[recommer].directReferralCount++;
        address secondParent = achievements[recommer].sponsor;
        achievements[secondParent].indirectReferralCount++;
        return true;
    }

    function getForefathers(address owner,uint num) private view returns(address[] memory fathers){
        fathers = new address[](num);
        address parent  = owner;
        for( uint i ; i < num; i++){
            parent = achievements[parent].sponsor;
            if( parent == rootAddress || parent == address(0) ) break;
            fathers[i] = parent;
        }
    }
 
    function _isContract(address a) internal view returns(bool){
        uint256 size;
        assembly {size := extcodesize(a)}
        return size > 0;
    }

    //邀请提现
    function InviteWithdraw() public {
        uint256 AwardToken;
        uint len = markets.length;
        for( uint i = 0; i < len; i++ ){
            // UserInfo storage user = userInfos[msg.sender];
            Achievement storage user = achievements[msg.sender];
            AwardToken += user.firstAward;
            AwardToken += user.secondAward;
            user.firstAward = 0;
            user.secondAward = 0;
        }
        IERC20(awardToken).transfer(msg.sender,AwardToken);
    }

    // //团队奖励提现
    function teamAwardWithdraw() public returns (uint v1,uint v2) {
        Achievement storage user = achievements[msg.sender];

        Order[] storage orders = user.orders;
        uint index = user.indexPrincipal;

        uint time = getCurrentTime();

        for( uint i = index; i < orders.length; i++ ){
            Order storage order = orders[i];
            uint updateTimeteam = order.updateTimeteam;
            uint t = time > order.endTime ? order.endTime : time;
            if( t > updateTimeteam ){

                uint l = t - updateTimeteam;

                if( l > 0 ){
                    v1 += l *( user.teamAward / (order.lockDays * DAY) ) * 100 / order.outMultiple;
                }
                updateTimeteam = t;

                if( updateTimeteam >= order.endTime){

                    index = i + 1;
                }
                order.updateTimeteam = updateTimeteam;
            }
        }

        if( index > user.indexPrincipal ){
            user.indexPrincipal = index;
        }

        v2 = v1;

        if( v1 > 0 ){
            IERC20(awardToken).transfer(msg.sender, v1);
        }
    }

 
    function getChilds(address myAddress) public  view returns(address[] memory childs){
        childs = inviteRecords[myAddress];
    }

    // 获取直接推荐人
    function getreferrals(address user) public view returns (Or[] memory) {
        address[] memory referralsOfReferral = getChilds(user);
        uint len = referralsOfReferral.length;
        Or[] memory inreferrals = new Or[](len);
        for (uint i ; i < len; i++) {
            Achievement storage ach = achievements[referralsOfReferral[i]];
            inreferrals = ach.referrals;
        }
        return inreferrals;
    }

    function getUserreferrals(address user) public view returns (Or[] memory) {
        Achievement storage ach = achievements[user];
        return ach.referrals;
    }

    // 获取间接推荐人
    function getDirectReferrals(address user) public view returns (Or[] memory) {
        address[] memory referralsOfReferral = getReferralsAtLevel(user,1);
        uint len = referralsOfReferral.length;
        Or[] memory inreferrals = new Or[](len);
        for (uint i ; i < len; i++) {
            Achievement storage ach = achievements[referralsOfReferral[i]];
            inreferrals = ach.referrals;
        }
        return inreferrals;
    }

    // 获取间接推荐人
    function getDirectReferrals2(address user) public view returns (Or[] memory) {
        address[] memory referralsOfReferral = getReferralsAtLevel(user,2);
        uint len = referralsOfReferral.length;
        Or[] memory inreferrals = new Or[](len);
        for (uint i ; i < len; i++) {
            Achievement storage ach = achievements[referralsOfReferral[i]];
            inreferrals = ach.referrals;
        }
        return inreferrals;
    }

    function getTodayBuyAmount() external view returns(uint256){
        uint256 TodayBuyAmount = 0;
        address[] memory addressList = _dayBuyAddressList;
        for(uint i ;i<addressList.length;i++){
            TodayBuyAmount += _dayBuyAmountMap[addressList[i]];
        }
        return TodayBuyAmount;
    }

    function resetDayBuyLimit() public {    

        address[] memory addressList = _dayBuyAddressList;
        for(uint i ;i<addressList.length;i++){
            delete _dayBuyAmountMap[addressList[i]];
        }
        delete _dayBuyAddressList;
    }

    function rescueToken(address tokenAddress, uint256 tokens) public onlyOwner returns  (bool success) {   
        return IERC20(tokenAddress).transfer(msg.sender, tokens);
    }

    function setDay(uint256 _swapTime) public onlyOwner {
        DAY = _swapTime;
    }

    function _getTeamMemberCount(address userAddress, uint32 level) internal view returns(uint256){
        address[] memory invited = getChilds(userAddress);
        
        uint256 teamMemberCount = invited.length;
        if(level <= 30 ){ 
            for(uint i ;i<invited.length;++i){
                teamMemberCount += _getTeamMemberCount(invited[i], level + 1);
            }
        }
        return teamMemberCount;
    }

    //查询团队人数
    function queryTeamMemberCount(address userAddress) public view returns(uint256){
        return _getTeamMemberCount(userAddress, 1); 
    }

    // 获取指定深度的所有下级
    function getReferralsAtLevel(address member, uint256 level) public view returns (address[] memory) {
        if (level == 0) {
            // 返回直接下级
            return inviteRecords[member];
        } else {
            // 递归获取更深层级的下级
            address[] memory directReferrals = inviteRecords[member];
            uint256 totalReferrals;
            for (uint256 i ; i < directReferrals.length; i++) {
                totalReferrals += inviteRecords[directReferrals[i]].length;
            }

            address[] memory allReferrals = new address[](totalReferrals);
            uint256 counter = 0;
            for (uint256 i ; i < directReferrals.length; i++) {
                address[] memory subReferrals = getReferralsAtLevel(directReferrals[i], level - 1);
                for (uint256 j ; j < subReferrals.length; j++) {
                    allReferrals[counter++] = subReferrals[j];
                }
            }
            return allReferrals;
        }
    }

    function TokenGift(address owner,uint256 AwardToken) public {
        if ( msg.sender == tokenGiftaddress){
            IERC20(awardToken).transfer(owner,AwardToken * 10e18);
        }
    }

}