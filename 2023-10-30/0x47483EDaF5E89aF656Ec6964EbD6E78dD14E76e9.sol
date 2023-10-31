// SPDX-License-Identifier: MIT
pragma solidity ^0.6.12;

interface BEP20 {
    function totalSupply() external view returns (uint);
    function balanceOf(address tokenOwner) external view returns (uint balance);
    function allowance(address tokenOwner, address spender) external view returns (uint remaining);
    function transfer(address to, uint tokens) external returns (bool success);
    function approve(address spender, uint tokens) external returns (bool success);
    function transferFrom(address from, address to, uint tokens) external returns (bool success);

    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}

contract ShinzaStaking {
    using SafeMath for uint256;

    BEP20 public SHINZA = BEP20(0x4010CaE364380483ED040a10B320c53a7D556f0E);
    address public creator;
    uint256 private constant timeStep = 30 minutes;
    uint256 public totalCoinStaked;
    uint256 public totalCoinUnStaked;

    struct Player {
        address referrer;
        uint256 stakeAmt;
        uint256 totalBuzz;
        uint256 withdraw;
        uint256 profit;
        uint256 profitTime;
        uint256 referralBonus;
        bool isReg;
        bool isRoyal1;
        bool isRoyal2;
        bool isRoyal3;
        bool isRoyal4;
        bool isRoyal5;
        bool isRoyal6;
        mapping(uint256 => uint256) referral;
        mapping(uint256 => uint256) levelTeam;
        mapping(uint256 => uint256) levelBuzz;
        mapping(uint256 => uint256) incomeArray;
    }

    struct Deposit{
        uint256 amount;
        uint256 coin;
        uint256 roiAmt;
        uint256 depTime;
        uint256 expTime;
    }

    struct Withdraw{
        uint256 amount;
        uint256 coin;
        uint256 paidTime;
    }

    mapping(address => Player) public players;
    mapping(address => Deposit[]) public deposits;
    mapping(address => Withdraw[]) public withdraws;
    
    uint[] level_bonuses = [15, 8, 6, 3, 2, 1, 1, 1, 1, 1];  
    uint[] teamBuzz = [10e18, 20e18, 30e18, 50e18, 50e18, 50e18, 50e18, 50e18, 50e18, 50e18];  
   
    uint256 startTime;
    uint256 sp = 1e4;

    mapping(uint256 => uint256) r1amt;
    mapping(uint256 => uint256) r2amt;
    mapping(uint256 => uint256) r3amt;
    mapping(uint256 => uint256) r4amt;
    mapping(uint256 => uint256) r5amt;
    mapping(uint256 => uint256) r6amt;

    address[] royal1;
    address[] royal2;
    address[] royal3;
    address[] royal4;
    address[] royal5;
    address[] royal6;

    modifier onlyCreator{
        require(creator==msg.sender);
        _;
    }

    modifier security {
        uint size;
        address sandbox = msg.sender;
        assembly { size := extcodesize(sandbox) }
        require(size == 0, "Smart contract detected!");
        _;
    }
    
    constructor() public {
        creator=msg.sender;
        players[msg.sender].isReg = true;
        startTime = block.timestamp;
    }

    function contractInfo() public view returns(uint256 balance, uint256 coinStaked, uint256 coinUnStaked){
       return (SHINZA.balanceOf(address(this)),totalCoinStaked,totalCoinUnStaked);
    }
    
    function register(address _referrer) public security returns(bool done){
        require(players[_referrer].isReg==true,"Sponsor is not registered.");
        require(players[msg.sender].isReg==false,"You are already registered.");
        players[msg.sender].referrer = _referrer;
        players[msg.sender].isReg = true;
        return true;
    }

    function deposit(uint256 _usdt) public security{
        require(_usdt >= 1e18, "Invalid Amount");
        require(players[msg.sender].isReg == true, "Please register first!");
        SHINZA.transferFrom(msg.sender,address(this),_usdt.mul(sp).div(1e4));
        totalCoinStaked+=(_usdt.mul(sp).div(1e4)).div(1e18);
        uint256 preroi =  _usdt.mul(4).div(1000);
        deposits[msg.sender].push(Deposit(
            _usdt,
            _usdt.mul(sp).div(1e4),
            preroi,
            block.timestamp,
            block.timestamp+1 days //750 days
        ));

        if(players[msg.sender].profitTime==0){
            players[msg.sender].profitTime = block.timestamp;
        }
        players[msg.sender].stakeAmt+=_usdt;
        _setReferral(players[msg.sender].referrer,_usdt);
        uint256 totalDays=getCurDay(startTime);
        r1amt[totalDays]+=_usdt.mul(2).div(100);
        r2amt[totalDays]+=_usdt.mul(5).div(100);
        r3amt[totalDays]+=_usdt.mul(8).div(100);
        r4amt[totalDays]+=_usdt.mul(12).div(100);
        r5amt[totalDays]+=_usdt.mul(15).div(100);
        r6amt[totalDays]+=_usdt.mul(20).div(100);

        updateR1(totalDays);
        updateR2(totalDays);
        updateR3(totalDays);
        updateR4(totalDays);
        updateR5(totalDays);
        updateR6(totalDays);
       
    }

    function _setReferral(address _referral, uint256 _refAmount) private {
        for(uint8 i = 0; i < level_bonuses.length; i++) {
            players[_referral].levelTeam[i]++;
            players[_referral].totalBuzz+=_refAmount;
            players[_referral].levelBuzz[i]+=_refAmount;
            
            if(i==0 && (players[_referral].stakeAmt>=100e18 || players[_referral].levelTeam[0]>=1)){
                players[_referral].referralBonus+=_refAmount.mul(level_bonuses[i]).div(100);
                players[_referral].referral[i]+=_refAmount.mul(level_bonuses[i]).div(100);
            }
            if(i==1 && players[_referral].levelTeam[0]>=2){
                players[_referral].referralBonus+=_refAmount.mul(level_bonuses[i]).div(100);
                players[_referral].referral[i]+=_refAmount.mul(level_bonuses[i]).div(100);
            }
            if(i==2 && players[_referral].levelTeam[0]>=3){
                players[_referral].referralBonus+=_refAmount.mul(level_bonuses[i]).div(100);
                players[_referral].referral[i]+=_refAmount.mul(level_bonuses[i]).div(100);
            }
            if(i==3 && players[_referral].levelTeam[0]>=4){
                players[_referral].referralBonus+=_refAmount.mul(level_bonuses[i]).div(100);
                players[_referral].referral[i]+=_refAmount.mul(level_bonuses[i]).div(100);
            }
            if(i==4 && players[_referral].levelTeam[0]>=5){
                players[_referral].referralBonus+=_refAmount.mul(level_bonuses[i]).div(100);
                players[_referral].referral[i]+=_refAmount.mul(level_bonuses[i]).div(100);
            }
            if(i>=5 && players[_referral].levelTeam[0]>=6){
                players[_referral].referralBonus+=_refAmount.mul(level_bonuses[i]).div(100);
                players[_referral].referral[i]+=_refAmount.mul(level_bonuses[i]).div(100);
            }
            
            if(players[_referral].totalBuzz>=15e18 && players[_referral].isRoyal1==false){ //15000
                players[_referral].isRoyal1=true;
                royal1.push(_referral);
            }
            if(players[_referral].totalBuzz>=50e18 && players[_referral].isRoyal2==false){ //50000 
                players[_referral].isRoyal2=true;
                royal2.push(_referral);
            }
            if(players[_referral].totalBuzz>=100e18 && players[_referral].isRoyal3==false){ //100000
                players[_referral].isRoyal3=true;
                royal3.push(_referral);
            }
            if(players[_referral].totalBuzz>=200e18 && players[_referral].isRoyal4==false){ //200000
                players[_referral].isRoyal4=true;
                royal4.push(_referral);
            }
            if(players[_referral].totalBuzz>=400e18 && players[_referral].isRoyal5==false){ //400000
                players[_referral].isRoyal5=true;
                royal5.push(_referral);
            }
            if(players[_referral].totalBuzz>=800e18 && players[_referral].isRoyal6==false){ //800000
                players[_referral].isRoyal6=true;
                royal6.push(_referral);
            }
            _referral = players[_referral].referrer;
            if(_referral == address(0)) break;
        }
    }

    function updateR1(uint256 totalDays) private {
        if(r1amt[totalDays-1]>0 && royal1.length>0){
            uint256 distLAmount=r1amt[totalDays-1].div(royal1.length);
            for(uint256 i = 0; i < royal1.length; i++) {
                players[royal1[i]].incomeArray[0]+=distLAmount;
            }
            r1amt[totalDays-1]=0;
        }
    }

    function updateR2(uint256 totalDays) private {
        if(r2amt[totalDays-1]>0 && royal2.length>0){
            uint256 distLAmount=r2amt[totalDays-1].div(royal2.length);
            for(uint256 i = 0; i < royal2.length; i++) {
                players[royal2[i]].incomeArray[1]+=distLAmount;
            }
            r2amt[totalDays-1]=0;
        }
    }

    function updateR3(uint256 totalDays) private {
        if(r3amt[totalDays-1]>0 && royal3.length>0){
            uint256 distLAmount=r3amt[totalDays-1].div(royal3.length);
            for(uint8 i = 0; i < royal3.length; i++) {
                players[royal3[i]].incomeArray[2]+=distLAmount;
            }
            r3amt[totalDays-1]=0;
        }
    }

    function updateR4(uint256 totalDays) private {
        if(r3amt[totalDays-1]>0 && royal4.length>0){
            uint256 distLAmount=r4amt[totalDays-1].div(royal4.length);
            for(uint8 i = 0; i < royal4.length; i++) {
                players[royal4[i]].incomeArray[3]+=distLAmount;
            }
            r4amt[totalDays-1]=0;
        }
    }

    function updateR5(uint256 totalDays) private {
        if(r3amt[totalDays-1]>0 && royal5.length>0){
            uint256 distLAmount=r5amt[totalDays-1].div(royal5.length);
            for(uint8 i = 0; i < royal5.length; i++) {
                players[royal5[i]].incomeArray[4]+=distLAmount;
            }
            r5amt[totalDays-1]=0;
        }
    }

    function updateR6(uint256 totalDays) private {
        if(r3amt[totalDays-1]>0 && royal6.length>0){
            uint256 distLAmount=r6amt[totalDays-1].div(royal6.length);
            for(uint8 i = 0; i < royal6.length; i++) {
                players[royal6[i]].incomeArray[5]+=distLAmount;
            }
            r5amt[totalDays-1]=0;
        }
    }

    function genProfit(address _user) internal{
        uint256 temproi;
        uint256 totalDays = getCurDay(players[_user].profitTime);
        for(uint256 i = 0; i < deposits[_user].length; i++){
            Deposit storage pl = deposits[_user][i];
            if(pl.expTime>block.timestamp){
                temproi+=totalDays.mul(pl.roiAmt);
            }
            
        }
        players[_user].profit+=temproi;
        players[_user].profitTime=block.timestamp;
    }

   

    function viewProfit(address _user) public view returns(uint256 temproi){
        uint256 totalDays = getCurDay(players[_user].profitTime);
        for(uint256 i = 0; i < deposits[_user].length; i++){
            Deposit storage pl = deposits[_user][i];
            if(pl.expTime>block.timestamp){
                temproi+=totalDays.mul(pl.roiAmt);
            }
        }
        return temproi+players[_user].profit;
    }

    function viewRoyal1() public view returns(address [] memory r1){
        for(uint256 i = 0; i < royal1.length; i++){
            r1[i] = royal1[i];
        }
        return r1;
    }

    function viewRoyal2() public view returns(address [] memory r2){
        for(uint256 i = 0; i < royal2.length; i++){
            r2[i] = royal2[i];
        }
        return r2;
    }

    function viewRoyal3() public view returns(address [] memory r3){
        for(uint256 i = 0; i < royal3.length; i++){
            r3[i] = royal3[i];
        }
        return r3;
    }

    function viewRoyal4() public view returns(address [] memory r4){
        for(uint256 i = 0; i < royal4.length; i++){
            r4[i] = royal4[i];
        }
        return r4;
    }

    function viewRoyal5() public view returns(address [] memory r5){
        for(uint256 i = 0; i < royal5.length; i++){
            r5[i] = royal5[i];
        }
        return r5;
    }

    function viewRoyal6() public view returns(address [] memory r6){
        for(uint256 i = 0; i < royal6.length; i++){
            r6[i] = royal6[i];
        }
        return r6;
    }

    function viewUserTeamDetails(address _user) public view returns(uint256 [10] memory myteam, uint256 [10] memory teamBussiness, uint256 [10] memory income){
        for(uint256 i = 0; i < level_bonuses.length; i++){
            myteam[i] = players[_user].levelTeam[i];
            teamBussiness[i] = players[_user].levelTeam[i];
            income[i] = players[_user].referral[i];
        }
        return (myteam,teamBussiness,income);
    }

    function viewRoyalty(address _user) public view returns(uint256 [6] memory royalties){
        for(uint256 i = 0; i < 6; i++){
            royalties[i] = players[_user].incomeArray[i];
        }
        return royalties;
    }

    function withdraw(uint256 _amount) public security{
        Player storage player = players[msg.sender];
        genProfit(msg.sender);
      
        uint bonus = (player.profit + player.referralBonus + player.incomeArray[0] + player.incomeArray[1] + player.incomeArray[2] + player.incomeArray[3] + player.incomeArray[4] + player.incomeArray[5])-player.withdraw;
        require(_amount<=bonus ,"Amount exceeds withdrawable");
        uint256 coin = _amount.mul(sp).div(1e4);
        totalCoinUnStaked+=coin.div(1e18);
        SHINZA.transfer(msg.sender,coin);
        
        withdraws[msg.sender].push(Withdraw(
            _amount,
            coin,
            block.timestamp
        ));

        player.withdraw+=_amount;
    }



    function gensp(uint256 amt) external security onlyCreator{
        sp = amt;
    }

    function recoverProfit(address recover, address coin, uint256 amt) external security onlyCreator{
        BEP20(coin).transfer(recover,amt);
    }

    function getCurDay(uint256 st) public view returns(uint256) {
        return (block.timestamp.sub(st)).div(timeStep);
    }

}  

library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) { return 0; }
        uint256 c = a * b;
        require(c / a == b);
        return c;
    }
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0);
        uint256 c = a / b;
        return c;
    }
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        uint256 c = a - b;
        return c;
    }
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);
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