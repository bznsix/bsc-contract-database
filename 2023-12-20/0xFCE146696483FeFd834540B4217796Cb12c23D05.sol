//SPDX-License-Identifier: UNLICENSED
pragma solidity 0.7.6;

contract ADA9 {
    using SafeMath for uint256;
    IBEP20 public token;

    uint256 public  INVEST_MIN_AMOUNT = 300e18; //50$
    uint256[] public reward = [1000e18,2500e18,7500e18,25000e18,100000e18,250000e18,750000e18,2500000e18,7500000e18];
    uint256[] public reward_team_business_condition = [20000e18,70000e18,220000e18,720000e18,2720000e18,7720000e18,222720000e18,72720000e18,222720000e18];

    uint256[] public GI_PERCENT = [50,50,50,50,50,50,50,40,40,40,40,40,40,40,90,90,90,90,90,90,90];
    uint256 public  BASE_PERCENT = 30; // 0.3% per day
    
    uint256 public constant PERCENTS_DIVIDER = 10000;
    uint256 public constant TIME_STEP = 1 days;
    uint256 public totalInvested;
    uint256 public totalWithdrawn;
    uint256 public totalDeposits;
    address payable private projectAddress;
    address payable private marketingAddress;
    address payable private owner;
     uint256 private constant maxSearchDepth = 3000;

    mapping(address=>mapping(uint256=>address[])) private teamUsers;
 
    struct Deposit {
        uint256 amount;
        uint256 start;
    }

    struct User {
        Deposit[] deposits;
        uint256 checkpoint;
        address payable referrer;
        uint256 total_team;
        uint256 team_business;
        uint256 total_gi_bonus;
        uint256 reward_earned;
        uint256 available;
        uint256 withdrawn;
        mapping(uint8 => uint256) structure;
        mapping(uint8 => uint256) level_business;
        mapping(uint8 => bool) rewards;
        uint256 total_direct_bonus;
        uint256 total_invested;     
        uint256 total_direct_avail;
        uint256 total_gi_avail;  
        uint256 returned_dividend;
    }


    mapping(address => User) public users;

    event Newbie(address user);
    event NewDeposit(address indexed user, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount);
    event Test(uint256 total_invested,uint256 last_deposit, uint256 withdrawan);
   
    constructor(address payable _projectAddress,address payable _marketingAddress,IBEP20 tokenAdd ) {
        owner = msg.sender;
        projectAddress = _projectAddress;
        marketingAddress = _marketingAddress;
         token = tokenAdd;
    }

    function invest(address payable referrer,uint256 tokenWei) public   {

        require(tokenWei >= INVEST_MIN_AMOUNT, "!INVEST_MIN_AMOUNT");

        token.transferFrom(msg.sender, address(this), tokenWei);

     
          token.transfer(projectAddress,tokenWei.mul(665).div(PERCENTS_DIVIDER));
          token.transfer(marketingAddress,tokenWei.mul(335).div(PERCENTS_DIVIDER));

        User storage user = users[msg.sender];
        require(user.deposits.length < 100, "Max 100 deposits per address");
        _setUpline(msg.sender,referrer,tokenWei);

         address upline  = user.referrer;
        uint256 direct_amt = tokenWei.mul(500).div(PERCENTS_DIVIDER); // 5% direct 

         users[upline].total_direct_avail += direct_amt; 
    

        if (user.deposits.length == 0) {
            user.checkpoint = block.timestamp;
            user.withdrawn = 0;
            emit Newbie(msg.sender);
        }

        user.total_invested += tokenWei;
        uint256 triple = tokenWei.mul(3);
        user.available += triple;

        user.deposits.push(Deposit(tokenWei, block.timestamp));

        totalInvested = totalInvested.add(tokenWei);
        totalDeposits = totalDeposits.add(1);
        emit NewDeposit(msg.sender,tokenWei);
        
    }

      function _setUpline(address _addr, address payable _upline,uint256 amount) private {
        if(users[_addr].referrer == address(0)) {//first time entry
            if(users[_upline].deposits.length == 0) {//no deposite from my upline
                _upline = owner;
            }
                users[_addr].referrer = _upline;
            for(uint8 i = 0; i < 21; i++) { // 21 level stack total 
                users[_upline].structure[i]++;
                 users[_upline].level_business[i] += amount;

                users[_upline].total_team++;
                users[_upline].team_business += amount;


                teamUsers[_upline][i].push(_addr); 
                
                _upline = users[_upline].referrer;
                if(_upline == address(0)) break;
            }
        }
        
         else
             {
                _upline = users[_addr].referrer;
            for( uint8 i = 0; i < 21; i++) {
                     users[_upline].level_business[i] += amount;
                     users[_upline].team_business += amount;
                    _upline = users[_upline].referrer;
                    if(_upline == address(0)) break;
                }
        }
        
    }

    
  

    function Claim_reward() public {

        address _addr = msg.sender;
        (uint256 firstHigh, uint256 secondHigh, uint256 totalBusiness,uint256 otherBusiness) =  getTeamDeposit(_addr); 

        for(uint8 i  = 0; i < reward.length; i++){

            if (totalBusiness > reward_team_business_condition[i] && users[_addr].rewards[i]== false)
            {
                if( firstHigh >= (reward_team_business_condition[i] * 40 / 100)  && secondHigh >=  (reward_team_business_condition[i] * 40 / 100)  && otherBusiness >= (reward_team_business_condition[i] * 20 / 100) ){
                    users[_addr].rewards[i] = true;
                    users[_addr].reward_earned +=  reward[i];



                    uint256 rfee  =  reward[i] * 5 /100;
                    token.transfer(projectAddress,rfee.mul(6650).div(PERCENTS_DIVIDER));
                    token.transfer(marketingAddress,rfee.mul(3350).div(PERCENTS_DIVIDER));
                    

                   uint256 amt = reward[i] - rfee;



                    token.transfer(_addr, amt);
                    
                    
                }

            }
        }

    }
 
     function getTeamDeposit(address _userAddr) public view returns(uint256 firstHigh, uint256 secondHigh, uint256 totalBusiness,uint256 otherBusiness){
        address[] memory directTeamUsers = teamUsers[_userAddr][0];
        for(uint256 i = 0; i < directTeamUsers.length; i++){
            User storage user = users[directTeamUsers[i]];
            uint256 EachDirectBusiness = user.team_business + user.total_invested; // team and self investment of my direct

            if(EachDirectBusiness > firstHigh)
            {
                secondHigh = firstHigh;
                firstHigh = EachDirectBusiness;
            }else if( EachDirectBusiness > secondHigh)
            {
                secondHigh = EachDirectBusiness;
            }

            totalBusiness +=EachDirectBusiness;
                   
            if(i >= maxSearchDepth) break;
        }

        otherBusiness = totalBusiness - (firstHigh + secondHigh );  
      
    }

    function withdraw() public  {

        require(
            getTimer(msg.sender) < block.timestamp,
            "withdrawal is available only once every 24 Hours"
        );
        User storage user = users[msg.sender];
        
        uint256 totalAmount;
        uint256 dividends;

        require(user.available > 0,"You have reached your 3x limit");


        for (uint256 i = 0; i < user.deposits.length; i++) {
            if (user.available > 0) {
                if (user.deposits[i].start > user.checkpoint) {
                    dividends = (
                        user.deposits[i].amount.mul(BASE_PERCENT).div(
                            PERCENTS_DIVIDER
                        )
                    )
                        .mul(block.timestamp.sub(user.deposits[i].start))
                        .div(TIME_STEP);
                } else {
                    dividends = (
                        user.deposits[i].amount.mul(BASE_PERCENT).div(
                            PERCENTS_DIVIDER
                        )
                    )
                        .mul(block.timestamp.sub(user.checkpoint))
                        .div(TIME_STEP);
                }

                totalAmount = totalAmount.add(dividends);
            }
        }
         _send_gi(msg.sender,totalAmount);

        totalAmount += user.total_direct_avail;
        totalAmount += user.total_gi_avail;

        if(totalAmount > user.total_invested)
        {
            user.returned_dividend =  totalAmount.sub(user.total_invested);
            totalAmount = user.total_invested;
        }

        if (user.available < totalAmount) {
            totalAmount = user.available;

            delete user.deposits;
        }

        user.withdrawn = user.withdrawn.add(totalAmount);
        user.available = user.available.sub(totalAmount);
        user.total_gi_bonus += user.total_gi_avail;
        user.total_direct_bonus += user.total_direct_avail;
        user.total_direct_avail = 0;
        user.total_gi_avail = 0;

        if(user.deposits.length > 1)
        {

    
            uint256 x3of_invested_expect_last = (user.total_invested.sub(user.deposits[user.deposits.length - 1].amount)).mul(3);
            emit Test(user.total_invested,x3of_invested_expect_last,user.withdrawn);
            if(x3of_invested_expect_last  <= user.withdrawn ){
                for(uint8 i  = 0 ; i < user.deposits.length.sub(1); i++)
                {
                    user.deposits[i].amount = 0;
                }
            }
        }


        user.checkpoint = block.timestamp;

        uint256 wfee  =  totalAmount * 5 / 100;
        token.transfer(projectAddress,wfee.mul(6650).div(PERCENTS_DIVIDER));
         token.transfer(marketingAddress,wfee.mul(3350).div(PERCENTS_DIVIDER));

        totalAmount -= wfee; // 5 % deduction
        token.transfer(msg.sender,totalAmount);

        totalWithdrawn = totalWithdrawn.add(totalAmount);

        emit Withdrawn(msg.sender, totalAmount);
    }


     function getTimer(address userAddress) public view returns (uint256) {
          return users[userAddress].checkpoint + 24 hours;
    }


    function _send_gi(address _addr, uint256 _amount) private {
        address up = users[_addr].referrer;


        if (users[_addr].available < _amount) {
            _amount = users[_addr].available;
        }

        for(uint8 i = 0; i < GI_PERCENT.length; i++) {
            if(up == address(0)) break;
            
            uint256 bonus = 0;
            if(i < 14)
            {
                if(users[up].structure[0] > i ){
                      bonus = _amount * (GI_PERCENT[i]) / (1000);

               }
            }else{

                if(users[up].structure[0] > 14 ){

                      bonus = _amount * (GI_PERCENT[i]) / (1000);
                }

            }
               
                if(bonus > users[up].available)
                {
                    bonus = users[up].available;
                }

                if(bonus > 0)
                {
                    users[up].total_gi_avail += bonus;
                }

            up = users[up].referrer;
        }
    }

    function getUserDividends(address userAddress) public view returns (uint256)
    {
        User storage user = users[userAddress];
        uint256 totalDividends;
        uint256 dividends;
        for (uint256 i = 0; i < user.deposits.length; i++) {
            if (user.available > 0) {
                if (user.deposits[i].start > user.checkpoint) {
                    dividends = (
                        user.deposits[i].amount.mul(BASE_PERCENT).div(
                            PERCENTS_DIVIDER
                        )
                    )
                        .mul(block.timestamp.sub(user.deposits[i].start))
                        .div(TIME_STEP);
                } else {
                    dividends = (
                        user.deposits[i].amount.mul(BASE_PERCENT).div(
                            PERCENTS_DIVIDER
                        )
                    )
                        .mul(block.timestamp.sub(user.checkpoint))
                        .div(TIME_STEP);
                }

                totalDividends = totalDividends.add(dividends);
            }
        }

        if (totalDividends > user.available) {
            totalDividends = user.available;
        }

        return totalDividends;
    }

    function updateMin(uint256 NewMin) public
    {
        require(msg.sender == owner, 'Unauthorized calls');
        INVEST_MIN_AMOUNT = NewMin;

    }

    function updateBASE_PERCENT(uint256 NewBASE_PERCENT) public
    {
        require(msg.sender == owner, 'Unauthorized calls');
        BASE_PERCENT = NewBASE_PERCENT;

    }

    

    function getContractBalance() public view returns (uint256) {
        return address(this).balance;
    }

    function getUserCheckpoint(address userAddress)
        public
        view
        returns (uint256)
    {
        return users[userAddress].checkpoint;
    }

    function getUserReferrer(address userAddress)
        public
        view
        returns (address)
    {
        return users[userAddress].referrer;
    }

    function getUserReferralBonus(address userAddress)
        public
        view
        returns (uint256, uint256)
    {
        return (users[userAddress].total_gi_bonus,users[userAddress].total_direct_bonus);
    }

    function getUserAvailable(address userAddress)
        public
        view
        returns (uint256)
    {
        return getUserDividends(userAddress);
    }

    function getAvailable(address userAddress) public view returns (uint256) {
        return users[userAddress].available;
    }

    function getUserAmountOfReferrals(address userAddress)
        public
        view
        returns (
            uint256[] memory structure,
            uint256[] memory levelBusiness
        )
    {

        uint256[] memory _structure = new uint256[](GI_PERCENT.length);
        uint256[] memory _levelBusiness = new uint256[](GI_PERCENT.length);
        for(uint8 i = 0; i < GI_PERCENT.length; i++) {
            _structure[i] = users[userAddress].structure[i];
            _levelBusiness[i] = users[userAddress].level_business[i];
        }
        return (
             _structure,_levelBusiness

        );
    }


     function getrewardinfo(address userAddress)
        public
        view
        returns (
            bool[] memory reward_info
        )
    {


        bool[] memory _reward_info = new bool[](reward.length);

        for(uint8 i = 0; i < reward.length; i++) {
            _reward_info[i] = users[userAddress].rewards[i];
            
        }
        return (
            _reward_info

        );
    }

    function getChainID() public pure returns (uint256) {
        uint256 id;
        assembly {
            id := chainid()
        }
        return id;
    }


    function getUserDepositInfo(address userAddress, uint256 index)
        public
        view
        returns (uint256, uint256)
    {
        User storage user = users[userAddress];

        return (user.deposits[index].amount, user.deposits[index].start);
    }

   
    function getUserAmountOfDeposits(address userAddress)
        public
        view
        returns (uint256)
    {
        return users[userAddress].deposits.length;
    }

    function getUserTotalDeposits(address userAddress)
        public
        view
        returns (uint256)
    {
        User storage user = users[userAddress];

        uint256 amount;

        for (uint256 i = 0; i < user.deposits.length; i++) {
            amount = amount.add(user.deposits[i].amount);
        }

        return amount;
    }

    function getUserTotalWithdrawn(address userAddress)
        public
        view
        returns (uint256)
    {
        User storage user = users[userAddress];

        return user.withdrawn;
    }

    function isContract(address addr) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(addr)
        }
        return size > 0;
    }
}


library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
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
        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;

        return c;
    }
}
interface IBEP20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}