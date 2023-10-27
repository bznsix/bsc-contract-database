// SPDX-License-Identifier: MIT 


// ██████╗░░██████╗░██████╗░░█████╗░░█████╗░███████╗
// ██╔══██╗██╔════╝░██╔══██╗██╔══██╗██╔══██╗██╔════╝
// ██████╦╝██║░░██╗░██████╔╝███████║██║░░╚═╝█████╗░░
// ██╔══██╗██║░░╚██╗██╔══██╗██╔══██║██║░░██╗██╔══╝░░
// ██████╦╝╚██████╔╝██║░░██║██║░░██║╚█████╔╝███████╗
// ╚═════╝░░╚═════╝░╚═╝░░╚═╝╚═╝░░╚═╝░╚════╝░╚══════╝

pragma solidity >=0.4.22 <0.9.0;

contract Bgrace {
	using SafeMath for uint256;

	uint256 constant public INVEST_MIN_AMOUNT = 0.05 ether;
	uint256[] public REFERRAL_PERCENTS = [50, 30, 10];
	uint256 constant public PROJECT_FEE = 80;
	uint256 constant public marketingFee = 40;
	uint256 constant public WITHDRAW_FEE = 1000; //In base point
	uint256 constant public PERCENTS_DIVIDER = 1000;
 	uint256 constant public TIME_STEP = 1 days;

	uint256 WITHDRAW_FEE_1 = 50; //5%
	uint256 WITHDRAW_FEE_2 = 100; //10%

	uint256 public totalStaked;
	uint256 public totalRefBonus;
	uint256 public totalUsers;

    struct Plan {
        uint256 time;
        uint256 percent;
    }

    Plan[] internal plans;

	struct Deposit {
        uint8 plan;
		uint256 percent;
		uint256 amount;
		uint256 profit;
		uint256 start;
		uint256 finish;
	}

	struct User {
		Deposit[] deposits;
		uint256 checkpoint;
        uint256 holdBonusCheckpoint;
		address referrer;
		uint256[3] levels;
		uint256 bonus;
		uint256 totalInvested;
		uint256 totalBonus;
		uint256 totalWithdrawn;
	}

	mapping (address => User) internal users;

	uint256 public startUNIX;
	address payable public commissionWallet;
	address payable public marketingWallet;

	event Newbie(address user);
	event NewDeposit(address indexed user, uint8 plan, uint256 percent, uint256 amount, uint256 profit, uint256 start, uint256 finish);
	event Withdrawn(address indexed user, uint256 amount);
	event RefBonus(address indexed referrer, address indexed referral, uint256 indexed level, uint256 amount);
	event FeePayed(address indexed user, uint256 totalAmount);
    event GiveAwayBonus(address indexed user,uint256 amount);

	constructor(address payable wallet,address payable marketing, uint256 startDate)  {
		require(!isContract(wallet));
		require(startDate > 0);
		commissionWallet = wallet;
		marketingWallet = marketing;
		startUNIX = startDate;

		plans.push(Plan(14, 90)); // 9% per day for 14 days
        plans.push(Plan(21, 75)); // 7.5% per day for 21 days
        plans.push(Plan(28, 70)); // 7% per day for 28 days
		plans.push(Plan(14, 137)); // 13.7% per day for 14 days (at the end)
        plans.push(Plan(21, 131)); // 13.1% per day for 21 days (at the end)
        plans.push(Plan(28, 104)); // 10.4% per day for 28 days (at the end)
	}


	function invest(address referrer, uint8 plan) public payable {
		require(msg.value >= INVEST_MIN_AMOUNT,"Invalid amount");
        require(plan < 6, "Invalid plan");
	    User storage user = users[msg.sender];
        require(user.totalInvested < 50 ether, "Max 50 Bnb deposits per address");
		uint256 fee = msg.value.mul(PROJECT_FEE).div(PERCENTS_DIVIDER);
		commissionWallet.transfer(fee);
		emit FeePayed(msg.sender, fee);
        uint256 mfee  = msg.value.mul(marketingFee).div(PERCENTS_DIVIDER);
        marketingWallet.transfer(mfee);
       	emit FeePayed(msg.sender, mfee);

	
		if (user.referrer == address(0)) {
			if (users[referrer].deposits.length > 0 && referrer != msg.sender) {
				user.referrer = referrer;
			}

			address upline = user.referrer;
			for (uint256 i = 0; i < 3; i++) {
				if (upline != address(0)) {
					users[upline].levels[i] = users[upline].levels[i].add(1);
					upline = users[upline].referrer;
				} else break;
			}
		}

		if (user.referrer != address(0)) {

			address upline = user.referrer;
			for (uint256 i = 0; i < 3; i++) {
				if (upline != address(0)) {
					uint256 amount = msg.value.mul(REFERRAL_PERCENTS[i]).div(PERCENTS_DIVIDER);
					users[upline].bonus = users[upline].bonus.add(amount);
					totalRefBonus = totalRefBonus.add(amount);
					users[upline].totalBonus = users[upline].totalBonus.add(amount);
					emit RefBonus(upline, msg.sender, i, amount);
					upline = users[upline].referrer;
				} else break;
			}
		}

		if (user.deposits.length == 0) {
			user.checkpoint = block.timestamp;
			totalUsers = totalUsers.add(1);
            user.holdBonusCheckpoint = block.timestamp;
			emit Newbie(msg.sender);
		}
   
		(uint256 percent, uint256 profit, uint256 finish) = getResult(plan, msg.value);
		user.deposits.push(Deposit(plan, percent, msg.value, profit, block.timestamp, finish));

		totalStaked = totalStaked.add(msg.value);
		user.totalInvested += msg.value;
		emit NewDeposit(msg.sender, plan, percent, msg.value, profit, block.timestamp, finish);
	}


	function withdraw() public {
		User storage user = users[msg.sender];

		uint256 totalAmount = getUserDividends(msg.sender);

		uint256 referralBonus = getUserReferralBonus(msg.sender);
		if (referralBonus > 0) {
			user.bonus = 0;
			totalAmount = totalAmount.add(referralBonus);
		}

		require(totalAmount > 0, "User has no dividends");

		uint256 contractBalance = address(this).balance;
		if (contractBalance < totalAmount) {
			totalAmount = contractBalance;
		}

		user.checkpoint = block.timestamp;
	    user.holdBonusCheckpoint = block.timestamp;
		payable(msg.sender).transfer(totalAmount);
		user.totalWithdrawn = user.totalWithdrawn.add(totalAmount);
		emit Withdrawn(msg.sender, totalAmount);

	}

	function getContractBalance() public view returns (uint256) {
		return address(this).balance;
	}

	function getPlanInfo(uint8 plan) public view returns(uint256 time, uint256 percent) {
		time = plans[plan].time;
		percent = plans[plan].percent;
	}

		function getPercent(uint8 plan) public view returns (uint256) {
			return plans[plan].percent;
    }

	function getResult(uint8 plan, uint256 deposit) public view returns (uint256 percent, uint256 profit, uint256 finish) {
		percent = getPercent(plan);
			profit = deposit.mul(percent).div(PERCENTS_DIVIDER).mul(plans[plan].time);
		finish = block.timestamp.add(plans[plan].time.mul(TIME_STEP));
	}

	

	

	function getUserDividends(address userAddress) public view returns (uint256) {
		User storage user = users[userAddress];

		uint256 totalAmount;
	   

		for (uint256 i = 0; i < user.deposits.length; i++) {
			if (user.checkpoint < user.deposits[i].finish) {
				if (user.deposits[i].plan < 3) {
                    uint256 share = user.deposits[i].amount.mul(user.deposits[i].percent).div(PERCENTS_DIVIDER);
					uint256 from = user.deposits[i].start > user.checkpoint ? user.deposits[i].start : user.checkpoint;
					uint256 to = user.deposits[i].finish < block.timestamp ? user.deposits[i].finish : block.timestamp;
					if (from < to) {
						uint256 _dividends = share.mul(to.sub(from)).div(TIME_STEP);
						uint256 _dividendsWithFee = _dividends.sub(_dividends.mul(WITHDRAW_FEE_1).div(PERCENTS_DIVIDER));
						totalAmount = totalAmount.add(_dividendsWithFee);
					}
				} else if (block.timestamp > user.deposits[i].finish) {
					    uint256 _profit = user.deposits[i].profit;
						uint256 _profitWithFee = _profit.sub(_profit.mul(WITHDRAW_FEE_2).div(PERCENTS_DIVIDER));
						totalAmount = totalAmount.add(_profitWithFee);
				}
			}
		}

		return totalAmount;
	}

	 function getContractInfo() public view returns(uint256, uint256, uint256) {
        return(totalStaked, totalRefBonus, totalUsers);
    }

	function getUserCheckpoint(address userAddress) public view returns(uint256) {
		return users[userAddress].checkpoint;
	}

	function getUserReferrer(address userAddress) public view returns(address) {
		return users[userAddress].referrer;
	}
    


	function getUserDownlineCount(address userAddress) public view returns(uint256, uint256, uint256) {
		return (users[userAddress].levels[0],users[userAddress].levels[1],users[userAddress].levels[2]);
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

	function gettotalWithdrawn(address userAddress) public view returns(uint256 amount)
	{
		return users[userAddress].totalWithdrawn;
	}

	function getUserDepositInfo(address userAddress, uint256 index) public view returns(uint8 plan, uint256 percent, uint256 amount, uint256 profit, uint256 start, uint256 finish) {
	    User storage user = users[userAddress];

		plan = user.deposits[index].plan;
		percent = user.deposits[index].percent;
		amount = user.deposits[index].amount;
		profit = user.deposits[index].profit;
		start = user.deposits[index].start;
		finish = user.deposits[index].finish;
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
}