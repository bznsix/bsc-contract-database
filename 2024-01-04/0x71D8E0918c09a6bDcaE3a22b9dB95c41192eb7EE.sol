// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

library SafeMath {
    /*Addition*/
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }
    /*Subtraction*/
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;
        return c;
    }
    /*Multiplication*/
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }
    /*Divison*/
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        return c;
    }
    /* Modulus */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

contract GameLauncherStaking {

    IBEP20 public stakingToken;

    mapping(address => uint256) public rewards;

    address public primaryAdmin;

    uint private _totalSupply;

    mapping(address => uint) public _totalstakingbalances;

    uint256 constant public perDistribution = 100;

    uint256 public totalNumberofStakers;
	uint256 public totalStakesGML;

    uint256[5] public tierFromSlab = [0 ether,0 ether,0 ether,0 ether,0 ether];
    uint256[5] public tierToSlab = [0 ether,0 ether,0 ether,0 ether,0 ether];
    uint256[5] public tierAPY = [0 ether,0 ether,0 ether,0 ether,0 ether];
    uint[5] public tierXDays = [0,0,0,0,0];
    uint256[5] public tierXApy = [0 ether,0 ether,0 ether,0 ether,0 ether];

    address[] public stakingQualifier;

    uint[20] public stakePenaltySlab = [0 ether,0 ether,0 ether,0 ether,0 ether,0 ether,0 ether,0 ether,0 ether,0 ether,0 ether,0 ether,0 ether,0 ether,0 ether,0 ether,0 ether,0 ether,0 ether,0 ether];
    uint[20] public stakePenaltyPer = [0 ether,0 ether,0 ether,0 ether,0 ether,0 ether,0 ether,0 ether,0 ether,0 ether,0 ether,0 ether,0 ether,0 ether,0 ether,0 ether,0 ether,0 ether,0 ether,0 ether];

    struct User {
        uint256 totalStakedAvailable;
        uint256 totalStaked;
        uint256 totalUnStaked;
        uint256 totalReward;
		uint256 totalRewardWithdrawal;
		uint256 totalRewardStaked;
        uint256 maxAllocation;
        uint256 penaltyCollected;
        uint lastStakedUpdateTime;
        uint lastUnStakedUpdateTime;
        uint lastUpdateTime;
	}

    struct UserX {
        bool isXApy;
        uint paidDays;
	}

    mapping (address => User) public users;
    mapping (address => UserX) public usersx;

    constructor(address _primaryAdmin,address _stakingToken) {
        primaryAdmin = _primaryAdmin;
        stakingToken = IBEP20(_stakingToken);
    }

    function transferOwnership(address payable newOwner) public {
        require(primaryAdmin==msg.sender, 'Admin what?');
        primaryAdmin = newOwner;
    }

    function rewardPerDayToken(address account) public view returns (uint256 perdayinterest) {
        uint256 _perdayinterest=0;
        if (_totalstakingbalances[account] <= 0) {
            return _perdayinterest;
        }
        else{
            uint256 StakingToken=_totalstakingbalances[account];
            uint256 APYPer=0;
            uint256 Days=0;
            UserX storage userx = usersx[account];
            if(userx.isXApy==true){
                APYPer=tierXApy[getTierSlab(account)];
                Days=tierXDays[getTierSlab(account)];
            }
            else {
                APYPer=tierAPY[getTierSlab(account)];
                Days=365;
            }
            if(APYPer==0 || Days==0)
            {
                return _perdayinterest;
            }
            uint256 perDayPer=((APYPer*1e18)/(Days*1e18));
            _perdayinterest=((StakingToken*perDayPer)/perDistribution)/1e18;
            return _perdayinterest;
        }
    }

    //Get no of ROI Bonus Qualifier
    function getROIQualifier() public view returns(uint256) {
      return stakingQualifier.length;
    }

    function earned(address account) public view returns (uint256 totalroi,uint _noofDays) {
        User storage user = users[account];
        UserX storage userx = usersx[account];
        uint noofDays=view_GetNoofDaysBetweenTwoDate(user.lastUpdateTime,block.timestamp);
        uint256 _perdayinterest=rewardPerDayToken(account);
        if(userx.isXApy){
            if((userx.paidDays+noofDays)>tierXDays[getTierSlab(account)]){
                noofDays=(tierXDays[getTierSlab(account)]-userx.paidDays);
            }
        }
        return((_perdayinterest * noofDays)+rewards[account],noofDays);
    }

    modifier updateReward(address account) {
        User storage user = users[account];
        UserX storage userx = usersx[account];
        (uint256 roiUnSettled, uint noofDays) = earned(account);
        rewards[account] = roiUnSettled;
        user.lastUpdateTime = block.timestamp;
        if(userx.isXApy){
            userx.paidDays += noofDays;
        }
        _;
    }

    function _Stake(uint _amount,bool isXApy) external updateReward(msg.sender) {
        User storage user = users[msg.sender];
        //Manage Stake Holder & Staked GML
        if(_totalstakingbalances[msg.sender]==0){
            totalNumberofStakers += 1;
        }
        totalStakesGML +=_amount;
        //Update Supply & Balance of User
        _totalSupply += _amount;
        _totalstakingbalances[msg.sender] += _amount;
        //Update Stake Section
        user.totalStaked +=_amount;
        user.totalStakedAvailable +=_amount;
        if(isXApy && !usersx[msg.sender].isXApy){
            usersx[msg.sender].isXApy=true;
        }
        if(user.lastStakedUpdateTime == 0) {
            stakingQualifier.push(msg.sender);
        }  
        user.lastStakedUpdateTime =block.timestamp;
        stakingToken.transferFrom(msg.sender, address(this), _amount);
    }

    function _UnStake(uint _amount) external updateReward(msg.sender) {
        User storage user = users[msg.sender];
        UserX storage userx = usersx[msg.sender];
        require(_amount < _totalstakingbalances[msg.sender],'Insufficient Unstake GML');
        _totalstakingbalances[msg.sender] -= _amount;
        if(userx.isXApy){
            require(userx.paidDays>=tierXDays[getTierSlab(msg.sender)],'Did not completed tier x Days.');
        }
        //Get Penalty Percentage
        uint penaltyPer=getUnStakePenaltyPer(user.lastStakedUpdateTime,block.timestamp);
        //Get Penalty Amount
        uint256 penalty=_amount * penaltyPer / 100;
        //Update Penalty Collected
        user.penaltyCollected +=penalty;
        //Update Unstake Section
        user.totalUnStaked +=_amount;
        user.totalStakedAvailable -=_amount;
        user.lastUnStakedUpdateTime=block.timestamp;
        //Get Net Receivable Unstake Amount
        uint256 _payableamount=_amount-penalty;
        //Update Supply & Balance of User
        _totalSupply -= _payableamount;
         if(_totalstakingbalances[msg.sender]==0){
            totalNumberofStakers = totalNumberofStakers-1;
         }
         totalStakesGML -=_amount;
         stakingToken.transfer(msg.sender, _payableamount);
    }

    function _RewardStake(bool isXApy) external updateReward(msg.sender) {
        User storage user = users[msg.sender];
        uint256 reward = rewards[msg.sender];
        // Set Reward 0
        rewards[msg.sender] = 0;
        // Stake Section
        totalStakesGML +=reward;
        _totalstakingbalances[msg.sender] += reward;
        user.totalStaked +=reward;
        user.totalStakedAvailable +=reward;
        user.lastStakedUpdateTime =block.timestamp;
        if(isXApy && !usersx[msg.sender].isXApy){
            usersx[msg.sender].isXApy=true;
        }
        // Reward Stake Section
        user.totalRewardStaked +=reward;
    }

    function _RewardWithdrawal() external updateReward(msg.sender) {
        User storage user = users[msg.sender];
        UserX storage userx = usersx[msg.sender];
        if(userx.isXApy){
            require(userx.paidDays>=tierXDays[getTierSlab(msg.sender)],"Did not completed tier x Days.");
        }
        uint256 reward = rewards[msg.sender];
        // Set Reward 0
        rewards[msg.sender] = 0;
        // Reward Withdrawal Section
        user.totalRewardWithdrawal +=reward;
        _totalSupply -= reward;
        stakingToken.transfer(msg.sender, reward);
    }

    //Execute ROI Payout
    function _ClaculateOldAPY(uint8 fromQualifier,uint8 toQualifier) public { 
        require(primaryAdmin==msg.sender, 'Admin what?');
        for(uint8 i = fromQualifier; i < toQualifier; i++) {
            User storage user = users[stakingQualifier[i]];
            UserX storage userx = usersx[stakingQualifier[i]];
            (uint256 roiUnSettled, uint noofDays) = earned(stakingQualifier[i]);
            rewards[stakingQualifier[i]] = roiUnSettled;
            user.lastUpdateTime = block.timestamp;
            if(userx.isXApy){
                userx.paidDays += noofDays;
            }

        }
    }

    // Verify Staking By Admin In Case If Needed
    function _VerifyStake(uint _amount) external {
        require(primaryAdmin==msg.sender, 'Admin what?');
        _totalSupply += _amount;
        stakingToken.transferFrom(msg.sender, address(this), _amount);
    }

     // Verify Un Staking By Admin In Case If Needed
    function _VerifyUnStake(uint _amount) external updateReward(msg.sender) {
        require(primaryAdmin==msg.sender, 'Admin what?');
        require(_amount <= _totalSupply,'Insufficient GML For Collect');
        _totalSupply -= _amount;
        stakingToken.transfer(primaryAdmin, _amount);
    }

    //Get Tier Slab According To Staking GML
    function getTierSlab(address account) public view returns(uint tierindex){
        uint _tierindex=0;
        uint256 StakingToken=_totalstakingbalances[account];
        if(StakingToken >=tierFromSlab[0] && StakingToken <= tierToSlab[0]){
          _tierindex=0;
        }
        else if(StakingToken >=tierFromSlab[1] && StakingToken <= tierToSlab[1]){
          _tierindex=1;
        }
        else if(StakingToken >=tierFromSlab[2] && StakingToken <= tierToSlab[2]){
          _tierindex=2;
        }
        else if(StakingToken >=tierFromSlab[3] && StakingToken <= tierToSlab[3]){
          _tierindex=3;
        }
        else if(StakingToken > tierToSlab[3]){
         _tierindex=3;
        }
        else{
          _tierindex=4;
        } 
        return (_tierindex);
    }

    //Get Un Staking Penalty Percentage According To Time
    function getUnStakePenaltyPer(uint _startDate,uint _endDate) public view returns(uint penalty){
        uint _weeks=view_GetNoofWeekBetweenTwoDate(_startDate,_endDate);
        uint _penalty=0;
        if(_weeks <= stakePenaltySlab[0]) {
           _penalty=stakePenaltyPer[0];
        }
        else if(_weeks <= stakePenaltySlab[1]) {
           _penalty=stakePenaltyPer[1];
        }
        else if(_weeks <= stakePenaltySlab[2]) {
           _penalty=stakePenaltyPer[2];
        }
        else if(_weeks <= stakePenaltySlab[3]) {
           _penalty=stakePenaltyPer[3];
        }
        else if(_weeks <= stakePenaltySlab[4]) {
           _penalty=stakePenaltyPer[4];
        }
        else if(_weeks <= stakePenaltySlab[5]) { 
           _penalty=stakePenaltyPer[5];
        }
        else if(_weeks <= stakePenaltySlab[6]) {
           _penalty=stakePenaltyPer[6];
        }
        else if(_weeks <= stakePenaltySlab[7]) {
           _penalty=stakePenaltyPer[7];
        }
        else if(_weeks <= stakePenaltySlab[8]) {
           _penalty=stakePenaltyPer[8];
        }
        else if(_weeks <= stakePenaltySlab[9]) {
           _penalty=stakePenaltyPer[9];
        }
        else if(_weeks <= stakePenaltySlab[10]) {
           _penalty=stakePenaltyPer[10];
        }
         else if(_weeks <= stakePenaltySlab[11]) {
           _penalty=stakePenaltyPer[11];
        }
         else if(_weeks <= stakePenaltySlab[12]) {
           _penalty=stakePenaltyPer[12];
        }
         else if(_weeks <= stakePenaltySlab[13]) {
           _penalty=stakePenaltyPer[13];
        }
         else if(_weeks <= stakePenaltySlab[14]) {
           _penalty=stakePenaltyPer[14];
        }
        else if(_weeks <= stakePenaltySlab[15]) {
           _penalty=stakePenaltyPer[15];
        }
        else if(_weeks <= stakePenaltySlab[16]) {
           _penalty=stakePenaltyPer[16];
        }
        else if(_weeks <= stakePenaltySlab[17]) {
           _penalty=stakePenaltyPer[17];
        }
        else if(_weeks <= stakePenaltySlab[18]) {
           _penalty=stakePenaltyPer[18];
        }
        else if(_weeks <= stakePenaltySlab[19]) {
           _penalty=stakePenaltyPer[19];
        }
        return (_penalty);
    }

   function getUserPenaltyDetails(address account) public view returns (uint256 _penaltyPer,uint _stakedDay,uint _stakedWeek,uint _nooftotalSecond,uint _stakedHour,uint _stakedMinute,uint _stakedSecond) {
        User storage user = users[account];
        uint penaltyPer=getUnStakePenaltyPer(user.lastStakedUpdateTime,block.timestamp);
        uint stakedDay=view_GetNoofDaysBetweenTwoDate(user.lastStakedUpdateTime,block.timestamp);
        uint stakedWeek=view_GetNoofWeekBetweenTwoDate(user.lastStakedUpdateTime,block.timestamp);
        uint noofTotalSecond=view_GetNoofSecondBetweenTwoDate(user.lastStakedUpdateTime,block.timestamp);
        uint stakedHour=(noofTotalSecond-(stakedDay*86420))/60/60;
        uint stakedMinute=((noofTotalSecond-(stakedDay*86420))/60)-(stakedHour*60);
        uint stakedSecond=((noofTotalSecond-(stakedDay*86420)))-((stakedHour*3600)+(stakedMinute*60));
        return(penaltyPer,stakedDay,stakedWeek,noofTotalSecond,stakedHour,stakedMinute,stakedSecond);
   }

    //View Get Current Time Stamp
    function view_GetCurrentTimeStamp() public view returns(uint _timestamp){
       return (block.timestamp);
    }

    //View No Second Between Two Date & Time
    function view_GetNoofSecondBetweenTwoDate(uint _startDate,uint _endDate) public pure returns(uint _second){
        uint startDate = _startDate;
        uint endDate = _endDate;
        uint datediff = (endDate - startDate);
        return (datediff);
    }

    //View No Of Hour Between Two Date & Time
    function view_GetNoofHourBetweenTwoDate(uint _startDate,uint _endDate) public pure returns(uint _days){
        uint startDate = _startDate;
        uint endDate = _endDate;
        uint datediff = (endDate - startDate)/ 60 / 60;
        return (datediff);
    }

    //View No Of Days Between Two Date & Time
    function view_GetNoofDaysBetweenTwoDate(uint _startDate,uint _endDate) public pure returns(uint _days){
        uint startDate = _startDate;
        uint endDate = _endDate;
        uint datediff = (endDate - startDate)/ 60 / 60 / 24;
        return (datediff);
    }

    //View No Of Week Between Two Date & Time
    function view_GetNoofWeekBetweenTwoDate(uint _startDate,uint _endDate) public pure returns(uint _weeks){
        uint startDate = _startDate;
        uint endDate = _endDate;
        uint datediff = (endDate - startDate) / 60 / 60 / 24 ;
        uint weekdiff = (datediff) / 7 ;
        return (weekdiff);
    }

    //View No Of Month Between Two Date & Time
    function view_GetNoofMonthBetweenTwoDate(uint _startDate,uint _endDate) public pure returns(uint _months){
        uint startDate = _startDate;
        uint endDate = _endDate;
        uint datediff = (endDate - startDate) / 60 / 60 / 24 ;
        uint monthdiff = (datediff) / 30 ;
        return (monthdiff);
    }

    //View No Of Year Between Two Date & Time
    function view_GetNoofYearBetweenTwoDate(uint _startDate,uint _endDate) public pure returns(uint _years){
        uint startDate = _startDate;
        uint endDate = _endDate;
        uint datediff = (endDate - startDate) / 60 / 60 / 24 ;
        uint yeardiff = (datediff) / 365 ;
        return yeardiff;
    }

    // Update Bronze Tier Slab
    function update_TierBronze(uint256 _fromSlab,uint256 _toSlab,uint256 _tierAPY,uint _tierXDays,uint _tierXApy) external {
      require(primaryAdmin==msg.sender, 'Admin what?');
      tierFromSlab[0]=_fromSlab;
      tierToSlab[0]=_toSlab;
      tierAPY[0]=_tierAPY;
      tierXDays[0]=_tierXDays;
      tierXApy[0]=_tierXApy;
    }

    //View Bronze Tier Slab
    function view_TierBronze()external view returns(uint256 _fromSlab, uint256 _toSlab, uint256 _tierAPY,uint _tierXDays,uint _tierXApy){
       return (tierFromSlab[0],tierToSlab[0],tierAPY[0],tierXDays[0],tierXApy[0]);
    }

    // Update Silver Tier Slab
    function update_TierSilver(uint256 _fromSlab,uint256 _toSlab,uint256 _tierAPY,uint _tierXDays,uint _tierXApy) external {
      require(primaryAdmin==msg.sender, 'Admin what?');
      tierFromSlab[1]=_fromSlab;
      tierToSlab[1]=_toSlab;
      tierAPY[1]=_tierAPY;
      tierXDays[1]=_tierXDays;
      tierXApy[1]=_tierXApy;
    }

    //View Silver Tier Slab
    function view_TierSilver()external view returns(uint256 _fromSlab, uint256 _toSlab, uint256 _tierAPY,uint _tierXDays,uint _tierXApy){
       return (tierFromSlab[1],tierToSlab[1],tierAPY[1],tierXDays[1],tierXApy[1]);
    }

    // Update Gold Tier Slab
    function update_TierGold(uint256 _fromSlab,uint256 _toSlab,uint256 _tierAPY,uint _tierXDays,uint _tierXApy) external {
      require(primaryAdmin==msg.sender, 'Admin what?');
      tierFromSlab[2]=_fromSlab;
      tierToSlab[2]=_toSlab;
      tierAPY[2]=_tierAPY;
      tierXDays[2]=_tierXDays;
      tierXApy[2]=_tierXApy;
    }

    //View Gold Tier Slab
    function view_TierGold()external view returns(uint256 _fromSlab, uint256 _toSlab, uint256 _tierAPY,uint _tierXDays,uint _tierXApy){
       return (tierFromSlab[2],tierToSlab[2],tierAPY[2],tierXDays[2],tierXApy[2]);
    }

    //Update Diamond Tier Slab
    function update_TierDiamond(uint256 _fromSlab,uint256 _toSlab,uint256 _tierAPY,uint _tierXDays,uint _tierXApy) external {
      require(primaryAdmin==msg.sender, 'Admin what?');
      tierFromSlab[3]=_fromSlab;
      tierToSlab[3]=_toSlab;
      tierAPY[3]=_tierAPY;
      tierXDays[3]=_tierXDays;
      tierXApy[3]=_tierXApy;
    }

    //View Diamond Tier Slab
    function view_TierDiamond()external view returns(uint256 _fromSlab, uint256 _toSlab, uint256 _tierAPY,uint _tierXDays,uint _tierXApy){
       return (tierFromSlab[3],tierToSlab[3],tierAPY[3],tierXDays[3],tierXApy[3]);
    }

    //Update Stake Penalty Slab
    function update_stakePenaltySlab(uint _index,uint _week,uint _penalty) external {
      require(primaryAdmin==msg.sender, 'Admin what?');
      stakePenaltySlab[_index]=_week;
      stakePenaltyPer[_index]=_penalty;
    }

    //View Stake Penalty Slab
    function view_stakePenaltySlab(uint _index)external view returns(uint _week, uint _penalty){
       return (stakePenaltySlab[_index],stakePenaltyPer[_index]);
    }

    //Update No Of Stakers
    function verify_NumberofStakers(uint256 _amount) external {
      require(primaryAdmin==msg.sender, 'Admin what?');
      totalNumberofStakers+=_amount;
    }

    //Update Stakes GML
    function verify_StakesGML(uint256 _amount) external {
      require(primaryAdmin==msg.sender, 'Admin what?');
      totalStakesGML+=_amount;
    }
}

interface IBEP20 {
    function totalSupply() external view returns (uint);
    function balanceOf(address account) external view returns (uint);
    function transfer(address recipient, uint amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint);
    function approve(address spender, uint amount) external returns (bool);
    function transferFrom(address sender,address recipient,uint amount ) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);  
}