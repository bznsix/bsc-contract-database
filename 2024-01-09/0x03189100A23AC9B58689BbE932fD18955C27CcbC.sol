//SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

contract Growdcxstake {
	using SafeMath for uint256;

	IERC20 public erctoken;
	address token = 0xEB0ae76f3e67a7439884c8ff80f734c8d2472Ebb; //GDX
    

	/** default percentages **/
	uint256 public PROJECT_FEE = 100;
    uint256 public DEV_FEE = 100;
	uint256 public MKT_BUYBACK_FEE = 50;
	uint256[] public REFERRAL_PERCENT = [100, 50, 40, 30, 20, 10, 10, 10, 5, 5, 5, 5, 2, 2, 2, 2, 1, 1, 1, 1];
	uint256 constant public TIME_STEP = 1 days;
	uint256 constant private PERCENTS_DIVIDER = 1000;

	/* whale control features. **/
	
	  
	uint256 public COMPOUND_COOLDOWN = 24 * 60 * 60;  //24h
    uint256 public REINVEST_BONUS = 0; //1% Bonus on compounding
	uint256 public MAX_WITHDRAW = 100000 ether;  //10k
	uint256 public WALLET_LIMIT = 1000000000 ether;  //20k

    /** deposits after this timestamp gets additional percentages **/
    uint256 public PERCENTAGE_BONUS_STARTTIME = 1690905600; 
	uint256 public PERCENTAGE_BONUS_PLAN_1 = 0; // +1% from Above time stamp
    uint256 public PERCENTAGE_BONUS_PLAN_2 = 0;
    uint256 public PERCENTAGE_BONUS_PLAN_3 = 0;
    uint256 public PERCENTAGE_BONUS_PLAN_4 = 0;

    /* project statistics **/
	uint256 public totalInvested;
	uint256 public totalReInvested;
	uint256 public totalRefBonus;
	uint256 public totalInvestorCount;

    struct Plan {
        uint256 time;
        uint256 percent;
        uint256 mininvest;
        uint256 maxinvest;

        /** plan statistics **/
        uint256 planTotalInvestorCount;
        uint256 planTotalInvestments;
        uint256 planTotalReInvestorCount;
        uint256 planTotalReInvestments;
        
        bool planActivated;
    }
    
	struct Deposit {
        uint8 plan;
		uint256 amount;
		uint256 start;
		bool reinvested;
	}
    
    Plan[] internal plans;

	struct User {
		Deposit[] deposits;
        
		mapping (uint8 => uint256) checkpoints; /** a checkpoint for each plan **/
		
		uint256 totalInvested;
		address referrer;
		uint256 referralsCount;
		uint256 bonus;
		uint256 totalBonus;
		uint256 withdrawn;
		uint256 reinvested;
		uint256 totalDepositAmount;
	}

	mapping (address => User) internal users;

    address payable private dev1;
    address payable private dev2;
    address payable private mktAndBuyBack;
	address public contractOwner;
    uint public startTime = 1690300800 ; 
	event Newbie(address user);
	event NewDeposit(address indexed user, uint8 plan, uint256 amount);
	event ReinvestedDeposit(address indexed user, uint8 plan, uint256 amount);
	event Withdrawn(address indexed user, uint256 amount);
	event RefBonus(address indexed referrer, address indexed referral, uint256 amount);
	event FeePayed(address indexed user, uint256 totalAmount);

	constructor(address payable _dev1, address payable _dev2, address payable _mkt) {require(!isContract(_dev1) && !isContract(_dev2) && !isContract(_mkt));
        contractOwner = msg.sender;
        dev1 = _dev1;
        dev2 = _dev2;
        mktAndBuyBack = _mkt;
        erctoken = IERC20(token);

        plans.push(Plan(400, 5, 10000 ether, 100000 ether, 0, 0, 0, 0, true));
        plans.push(Plan(286, 7, 100000 ether, 1000000 ether, 0, 0, 0, 0, true));
        plans.push(Plan(200, 10, 1000000 ether, 1000000000 ether, 0, 0, 0, 0, true));
	}

	function invest(address referrer, uint8 plan, uint256 amounterc) public {
    require(block.timestamp > startTime, "Project not started yet");
    require(plan < plans.length, "Invalid Plan.");
    require(amounterc >= plans[plan].mininvest, "Less than minimum amount required for the selected Plan.");
    require(amounterc <= plans[plan].maxinvest, "More than maximum amount required for the selected Plan.");
    require(plans[plan].planActivated, "Plan selected is disabled");
    require(getUserActiveProjectInvestments(msg.sender).add(amounterc) <= WALLET_LIMIT, "Max wallet deposit limit reached.");

    // fees
    erctoken.transferFrom(address(msg.sender), address(this), amounterc);
    emit FeePayed(msg.sender, payFees(amounterc));

    User storage user = users[msg.sender];

    if (user.referrer == address(0)) {
        if (users[referrer].deposits.length > 0 && referrer != msg.sender) {
            user.referrer = referrer;
        }

        // Update the referral count for the first level
        address upline1 = user.referrer;
        if (upline1 != address(0)) {
            users[upline1].referralsCount = users[upline1].referralsCount.add(1);
        }

        // Update referral count for additional levels
        for (uint256 i = 1; i < REFERRAL_PERCENT.length; i++) {
            address upline = users[upline1].referrer;
            if (upline != address(0)) {
                users[upline].referralsCount = users[upline].referralsCount.add(1);
                upline1 = upline;
            } else {
                break;
            }
        }
    }

    if (user.referrer != address(0)) {
        address upline = user.referrer;
        for (uint256 i = 0; i < REFERRAL_PERCENT.length; i++) {
            if (upline != address(0)) {
                uint256 amount = amounterc.mul(REFERRAL_PERCENT[i]).div(PERCENTS_DIVIDER);
                users[upline].bonus = users[upline].bonus.add(amount);
                users[upline].totalBonus = users[upline].totalBonus.add(amount);
                totalRefBonus = totalRefBonus.add(amount);
                emit RefBonus(upline, msg.sender, amount);
                upline = users[upline].referrer;
            } else {
                break;
            }
        }
    }

    if (user.deposits.length == 0) {
        user.checkpoints[plan] = block.timestamp;

        emit Newbie(msg.sender);
        totalInvestorCount = totalInvestorCount.add(1);
        plans[plan].planTotalInvestorCount = plans[plan].planTotalInvestorCount.add(1);
    }

    user.deposits.push(Deposit(plan, amounterc, block.timestamp, false));

    user.totalInvested = user.totalInvested.add(amounterc);
    totalInvested = totalInvested.add(amounterc);

    plans[plan].planTotalInvestments = plans[plan].planTotalInvestments.add(amounterc);

    emit NewDeposit(msg.sender, plan, amounterc);
}


    function reinvest() public {
        uint8 plan = 0;
        require(block.timestamp > startTime, "Project not started yet");

        User storage user = users[msg.sender];

        if(user.checkpoints[plan].add(COMPOUND_COOLDOWN) > block.timestamp){
            revert("Compounding/Reinvesting can only be made after compound cooldown.");
        }

        uint256 totalAmount = getUserDividends(msg.sender, int8(plan));

        uint256 finalAmount = totalAmount.add(totalAmount.mul(REINVEST_BONUS).div(PERCENTS_DIVIDER));

        uint256 referralBonus = getUserReferralBonus(msg.sender);
		if (referralBonus > 0) {
			user.bonus = 0;
			finalAmount = finalAmount.add(referralBonus);
		}

		user.deposits.push(Deposit(plan, finalAmount, block.timestamp, true));

        if(user.checkpoints[plan] == 0){
		    plans[plan].planTotalReInvestorCount = plans[plan].planTotalReInvestorCount.add(1);
        }

        user.reinvested = user.reinvested.add(finalAmount);
        user.checkpoints[plan] = block.timestamp;
        

        /** statistics **/
		totalReInvested = totalReInvested.add(finalAmount);
		plans[plan].planTotalReInvestments = plans[plan].planTotalReInvestments.add(finalAmount);

		emit ReinvestedDeposit(msg.sender, plan, finalAmount);
	}

	function withdraw() public {
        require(block.timestamp > startTime, "Project not started yet");
		User storage user = users[msg.sender];

		uint256 totalAmount = getUserDividends(msg.sender);

		uint256 referralBonus = getUserReferralBonus(msg.sender);
		if (referralBonus > 0) {
			user.bonus = 0;
			totalAmount = totalAmount.add(referralBonus);
		}

		require(totalAmount > 0, "User has no dividends");

		uint256 contractBalance = erctoken.balanceOf(address(this));

		if (contractBalance < totalAmount) {
			user.bonus = totalAmount.sub(contractBalance);
			user.totalBonus = user.totalBonus.add(user.bonus);
			totalAmount = contractBalance;
		}

		for (uint8 i = 0; i < plans.length; i++) {
			if (user.checkpoints[i] > block.timestamp) {
				revert("Withdrawals can only be made after withdraw cooldown.");
			}

			user.checkpoints[i] = block.timestamp; /** global withdraw will reset checkpoints on all plans **/
		}

		/** Excess dividends are sent back to the user's account available for the next withdrawal. **/
		if (totalAmount > MAX_WITHDRAW) {
			user.bonus = totalAmount.sub(MAX_WITHDRAW);
			totalAmount = MAX_WITHDRAW;
		}

		 /** global withdraw will also reset CUTOFF **/
		user.withdrawn = user.withdrawn.add(totalAmount);

		erctoken.transfer(msg.sender, totalAmount);
		emit Withdrawn(msg.sender, totalAmount);
	}
	
	function payFees(uint256 amounterc) internal returns(uint256) {
		uint256 fee = amounterc.mul(PROJECT_FEE).div(PERCENTS_DIVIDER);
        uint256 feeDev = amounterc.mul(DEV_FEE).div(PERCENTS_DIVIDER);
		uint256 marketing = amounterc.mul(MKT_BUYBACK_FEE).div(PERCENTS_DIVIDER);
		erctoken.transfer(dev1, fee);
        erctoken.transfer(dev2, feeDev);
        erctoken.transfer(mktAndBuyBack, marketing);
        return fee.add(marketing).add(feeDev);
    }

	function getUserDividends(address userAddress, int8 plan) public view returns (uint256) {
		User storage user = users[userAddress];

		uint256 totalAmount;

		uint256 endPoint = block.timestamp;

		for (uint256 i = 0; i < user.deposits.length; i++) {
		    if(plan > -1){
		        if(user.deposits[i].plan != uint8(plan)){
		            continue;
		        }
		    }
			uint256 finish = user.deposits[i].start.add(plans[user.deposits[i].plan].time.mul(1 days));
			/** check if plan is not yet finished. **/
			if (user.checkpoints[user.deposits[i].plan] < finish) {

			    uint256 percent = plans[user.deposits[i].plan].percent;
			    if(user.deposits[i].start >= PERCENTAGE_BONUS_STARTTIME){
                    if(user.deposits[i].plan == 0){
                        percent = percent.add(PERCENTAGE_BONUS_PLAN_1);
                    }else if(user.deposits[i].plan == 1){
                        percent = percent.add(PERCENTAGE_BONUS_PLAN_2);
                    }else if(user.deposits[i].plan == 2){
                        percent = percent.add(PERCENTAGE_BONUS_PLAN_3);
                    }else if(user.deposits[i].plan == 3){
                        percent = percent.add(PERCENTAGE_BONUS_PLAN_4);
                    }
			    }

				uint256 share = user.deposits[i].amount.mul(percent).div(PERCENTS_DIVIDER);

				uint256 from = user.deposits[i].start > user.checkpoints[user.deposits[i].plan] ? user.deposits[i].start : user.checkpoints[user.deposits[i].plan];
				/** uint256 to = finish < block.timestamp ? finish : block.timestamp; **/
				uint256 to = finish < endPoint ? finish : endPoint;
				if (from < to) {
					totalAmount = totalAmount.add(share.mul(to.sub(from)).div(TIME_STEP));
				}
			}
		}

		return totalAmount;
	}
    
	function getUserActiveProjectInvestments(address userAddress) public view returns (uint256){
	    uint256 totalAmount;

		/** get total active investments in all plans. **/
        for(uint8 i = 0; i < plans.length; i++){
              totalAmount = totalAmount.add(getUserActiveInvestments(userAddress, i));  
        }
        
	    return totalAmount;
	}

	function getUserActiveInvestments(address userAddress, uint8 plan) public view returns (uint256){
	    User storage user = users[userAddress];
	    uint256 totalAmount;

		for (uint256 i = 0; i < user.deposits.length; i++) {

	        if(user.deposits[i].plan != uint8(plan)){
	            continue;
	        }

			uint256 finish = user.deposits[i].start.add(plans[user.deposits[i].plan].time.mul(1 days));
			if (user.checkpoints[uint8(plan)] < finish) {
			    /** sum of all unfinished deposits from plan **/
				totalAmount = totalAmount.add(user.deposits[i].amount);
			}
		}
	    return totalAmount;
	}


	function getPlanInfo(uint8 plan) public view returns(uint256 time, uint256 percent, uint256 minimumInvestment, uint256 maximumInvestment,
	  uint256 planTotalInvestorCount, uint256 planTotalInvestments , uint256 planTotalReInvestorCount, uint256 planTotalReInvestments, bool planActivated) {
		time = plans[plan].time;
		percent = plans[plan].percent;
		minimumInvestment = plans[plan].mininvest;
		maximumInvestment = plans[plan].maxinvest;
		planTotalInvestorCount = plans[plan].planTotalInvestorCount;
		planTotalInvestments = plans[plan].planTotalInvestments;
		planTotalReInvestorCount = plans[plan].planTotalReInvestorCount;
		planTotalReInvestments = plans[plan].planTotalReInvestments;
		planActivated = plans[plan].planActivated;
	}

	function getContractBalance() public view returns (uint256) {
		return erctoken.balanceOf(address(this));
	}

	function getUserDividends(address userAddress) public view returns (uint256) {
	    return getUserDividends(userAddress, -1);
	}

	function getUserTotalWithdrawn(address userAddress) public view returns (uint256) {
		return users[userAddress].withdrawn;
	}

	function getUserCheckpoint(address userAddress, uint8 plan) public view returns(uint256) {
		return users[userAddress].checkpoints[plan];
	}

	function getUserReferrer(address userAddress) public view returns(address) {
		return users[userAddress].referrer;
	}

    function getUserTotalReferrals(address userAddress) public view returns (uint256){
        return users[userAddress].referralsCount;
    }

	function getUserReferralBonus(address userAddress) public view returns(uint256) {
	    return users[userAddress].bonus;
	}

	function getUserReferralTotalBonus(address userAddress) public view returns(uint256) {
		return users[userAddress].totalBonus;
	}

	function getUserReferralWithdrawn(address userAddress) public view returns(uint256) {
		return users[userAddress].totalBonus.sub(users[userAddress].bonus);
	}

	function getUserAvailable(address userAddress) public view returns(uint256) {
		return getUserReferralBonus(userAddress).add(getUserDividends(userAddress));
	}

	function getUserAmountOfDeposits(address userAddress) public view returns(uint256) {
		return users[userAddress].deposits.length;
	}

	function getUserTotalDeposits(address userAddress) public view returns(uint256 amount) {
		for (uint256 i = 0; i < users[userAddress].deposits.length; i++) {
			amount = amount.add(users[userAddress].deposits[i].amount);
		}
	}

	function getUserDepositInfo(address userAddress, uint256 index) public view returns(uint8 plan, uint256 percent, uint256 amount, uint256 start, uint256 finish, bool reinvested) {
	    User storage user = users[userAddress];
		plan = user.deposits[index].plan;
		percent = plans[plan].percent;
		amount = user.deposits[index].amount;
		start = user.deposits[index].start;
		finish = user.deposits[index].start.add(plans[user.deposits[index].plan].time.mul(1 days));
		reinvested = user.deposits[index].reinvested;
	}

    function getSiteInfo() public view returns (uint256 _totalInvested, uint256 _totalBonus) {
        return (totalInvested, totalRefBonus);
    }

	function getUserInfo(address userAddress) public view returns(uint256 totalDeposit, uint256 totalWithdrawn, uint256 totalReferrals) {
		return(getUserTotalDeposits(userAddress), getUserTotalWithdrawn(userAddress), getUserTotalReferrals(userAddress));
	}

	/** Get Block Timestamp **/
	function getBlockTimeStamp() public view returns (uint256) {
	    return block.timestamp;
	}

	/** Get Plans Length **/
	function getPlansLength() public view returns (uint256) {
	    return plans.length;
	}

	function isContract(address addr) internal view returns (bool) {
        uint size;
        assembly { size := extcodesize(addr) }
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

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a % b;
    }
}