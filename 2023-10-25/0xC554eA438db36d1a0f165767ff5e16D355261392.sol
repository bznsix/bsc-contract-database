pragma solidity >=0.7.0 <0.9.0;
// SPDX-License-Identifier: MIT


interface ERC20{
	function balanceOf(address account) external view returns (uint256);
	function transfer(address recipient, uint256 amount) external returns (bool);
	function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
}

contract BLUEstaking {

	address owner;
	uint256 public interestAmtInBank = uint256(0);
	uint256 public principalAmtInBank = uint256(0);
	struct record { uint256 stakeTime; uint256 stakeAmt; uint256 lastUpdateTime; uint256 accumulatedInterestToUpdateTime; uint256 amtWithdrawn; }
	mapping(address => record) public informationAboutStakeScheme;
	mapping(uint256 => address) public addressStore;
    mapping(address => uint256) public totalStakedAmountByUser;
    mapping(address => uint256) public leverageAmountByUser;
    mapping(address => uint256) public lastTeamRewardWithdrawalTime;
	uint256 public numberOfAddressesCurrentlyStaked = uint256(0);
	uint256 public minStakeAmt = uint256(100000000000000000000);
	uint256 public maxStakeAmt = uint256(1000000000000000000000);
	uint256 public principalWithdrawalTax = uint256(50000);
	uint256 public interestTax = uint256(100000);
	uint256 public dailyInterestRate = uint256(10000);
	uint256 public minStakePeriod = (uint256(100) * uint256(864));
	uint256 public totalWithdrawals = uint256(0);
	struct referralRecord { 
        bool hasDeposited; 
        address referringAddress; 
        uint256 unclaimedRewards; 
        uint256 referralsAmtAtLevel0; 
        uint256 referralsCountAtLevel0; 
        uint256 referralsAmtAtLevel1; 
        uint256 referralsCountAtLevel1; 
        uint256 referralsAmtAtLevel2; 
        uint256 referralsCountAtLevel2;
        uint256 referralsCountAtLevel3;
        uint256 referralsCountAtLevel4;
        uint256 referralsCountAtLevel5;
        uint256 referralsCountAtLevel6;
        uint256 totalReferrals;}

    mapping(address => uint256) public referralLevels;
    mapping(address => uint256) public unclaimedTeamRewards;
	mapping(address => referralRecord) public referralRecordMap;
	event ReferralAddressAdded (address indexed referredAddress);
	uint256 public totalUnclaimedRewards = uint256(0);
	uint256 public totalClaimedRewards = uint256(0);
	event Staked (address indexed account);
	event Unstaked (address indexed account);

	constructor() {
		owner = msg.sender;
	}

	//This function allows the owner to specify an address that will take over ownership rights instead. Please double check the address provided as once the function is executed, only the new owner will be able to change the address back.
	function changeOwner(address _newOwner) public onlyOwner {
		owner = _newOwner;
	}

	modifier onlyOwner() {
		require(msg.sender == owner);
		_;
	}

	function minUIntPair(uint _i, uint _j) internal pure returns (uint){
		if (_i < _j){
			return _i;
		}else{
			return _j;
		}
	}


	function changeValueOf_minStakeAmt(uint256 _minStakeAmt) external onlyOwner {
		minStakeAmt  = _minStakeAmt;
	}


	function changeValueOf_maxStakeAmt(uint256 _maxStakeAmt) external onlyOwner {
		maxStakeAmt  = _maxStakeAmt;
	}


	function changeValueOf_principalWithdrawalTax(uint256 _principalWithdrawalTax) external onlyOwner {
		principalWithdrawalTax  = _principalWithdrawalTax;
	}


	function changeValueOf_interestTax(uint256 _interestTax) external onlyOwner {
		interestTax  = _interestTax;
	}


	function changeValueOf_minStakePeriod(uint256 _minStakePeriod) external onlyOwner {
		minStakePeriod  = _minStakePeriod;
	}


	function addReferralAddress(address _referringAddress) external {
		require(referralRecordMap[_referringAddress].hasDeposited, "Referring Address has not made a deposit");
		require(!((_referringAddress == msg.sender)), "Self-referrals are not allowed");
		require((referralRecordMap[msg.sender].referringAddress == address(0)), "User has previously indicated a referral address");
		referralRecordMap[msg.sender].referringAddress  = _referringAddress;
		emit ReferralAddressAdded(msg.sender);
	}


	function withdrawReferral(uint256 _amt) public {
		require((referralRecordMap[msg.sender].unclaimedRewards >= _amt), "Insufficient referral rewards to withdraw");
		referralRecordMap[msg.sender].unclaimedRewards  = (referralRecordMap[msg.sender].unclaimedRewards - _amt);
		totalUnclaimedRewards  = (totalUnclaimedRewards - _amt);
		totalClaimedRewards  = (totalClaimedRewards + _amt);
		require((ERC20(address(0x37E114C11DAc6c1c4958C9362b88fdD99C6f6351)).balanceOf(address(this)) >= _amt), "Insufficient amount of the token in this contract to transfer out. Please contact the contract owner to top up the token.");
		if ((_amt > uint256(0))){
			ERC20(address(0x37E114C11DAc6c1c4958C9362b88fdD99C6f6351)).transfer(msg.sender, _amt);
		}
	}


    function addReferral(uint256 _amt) internal returns (uint256) {
        address referringAddress = referralRecordMap[msg.sender].referringAddress;
        address level2Referrer = address(0); // Initialized to a default value
        address level3Referrer = address(0); // Initialized to a default value
        uint256 referralsAllocated = uint256(0);

        if (!(referralRecordMap[msg.sender].hasDeposited)) {
            referralRecordMap[msg.sender].hasDeposited = true;
        }

        if ((referringAddress == address(0))) {
            return referralsAllocated;
        }

        // 1st level referral
        referralRecordMap[referringAddress].referralsCountAtLevel0 += 1;
        referralRecordMap[referringAddress].unclaimedRewards += (5 * _amt) / 100;
        referralsAllocated += (5 * _amt) / 100;

        // Check 2nd level referral
        level2Referrer = referralRecordMap[referringAddress].referringAddress;
        
        if (level2Referrer != address(0)) {
            referralRecordMap[level2Referrer].referralsCountAtLevel1 += 1;

            if (referralRecordMap[level2Referrer].referralsCountAtLevel0 >= 2) {
                referralRecordMap[level2Referrer].unclaimedRewards += (8 * _amt) / 100;
                referralsAllocated += (8 * _amt) / 100;
            }

            // Check 3rd level referral
            level3Referrer = referralRecordMap[level2Referrer].referringAddress;
            if (level3Referrer != address(0)) {
                referralRecordMap[level3Referrer].referralsCountAtLevel2 += 1;

                if (referralRecordMap[level3Referrer].referralsCountAtLevel0 >= 3) {
                    referralRecordMap[level3Referrer].unclaimedRewards += (2 * _amt) / 100;
                    referralsAllocated += (2 * _amt) / 100;
                }
            }
        }
        
        // Check 4th level referral
        address level4Referrer = referralRecordMap[level3Referrer].referringAddress;
        if (level4Referrer != address(0)) {
            referralRecordMap[level4Referrer].referralsCountAtLevel3 += 1;

            // Check 5th level referral
            address level5Referrer = referralRecordMap[level4Referrer].referringAddress;
            if (level5Referrer != address(0)) {
                referralRecordMap[level5Referrer].referralsCountAtLevel4 += 1;

                // Check 6th level referral
                address level6Referrer = referralRecordMap[level5Referrer].referringAddress;
                if (level6Referrer != address(0)) {
                    referralRecordMap[level6Referrer].referralsCountAtLevel5 += 1;
                
                    // Check 7th level referral
                    address level7Referrer = referralRecordMap[level6Referrer].referringAddress;
                    if (level7Referrer != address(0)) {
                        referralRecordMap[level7Referrer].referralsCountAtLevel6 += 1;
                    }
                }
            }
        }

        totalUnclaimedRewards += referralsAllocated;

        // 更新团队总人数
        updateTotalReferrals(referringAddress);
        updateTotalReferrals(level2Referrer);
        updateTotalReferrals(level3Referrer);
        
        // 根据推荐人数和团队人数确定推荐级别
        determineReferralLevel(msg.sender);
        
        determineReferralLevel(referringAddress);
            if (level2Referrer != address(0)) {
                determineReferralLevel(level2Referrer);
            }
            if (level3Referrer != address(0)) {
                determineReferralLevel(level3Referrer);
            }

        return referralsAllocated;
        }

    function getReferralData(address user) public view returns (uint256 directReferrals, uint256 totalReferrals) {
        return (referralRecordMap[user].referralsCountAtLevel0, referralRecordMap[user].totalReferrals);
    }

    function updateTotalReferrals(address userAddress) internal {
        referralRecordMap[userAddress].totalReferrals = referralRecordMap[userAddress].referralsCountAtLevel0 +
                                                    referralRecordMap[userAddress].referralsCountAtLevel1 +
                                                    referralRecordMap[userAddress].referralsCountAtLevel2 +
                                                    referralRecordMap[userAddress].referralsCountAtLevel3 +
                                                    referralRecordMap[userAddress].referralsCountAtLevel4 +
                                                    referralRecordMap[userAddress].referralsCountAtLevel5 +
                                                    referralRecordMap[userAddress].referralsCountAtLevel6;
    }


    function determineReferralLevel(address user) internal {
        (uint256 currentLevel0Refs, uint256 currentTotalRefs) = getReferralData(user);
        
        if (currentLevel0Refs > 30 && currentTotalRefs >= 100000) {
            referralLevels[user] = 4;
        } else if (currentLevel0Refs > 20 && currentTotalRefs >= 10000 && currentTotalRefs < 100000) {
            referralLevels[user] = 3;
        } else if (currentLevel0Refs > 15 && currentTotalRefs >= 1000 && currentTotalRefs < 10000) {
            referralLevels[user] = 2;
        } else if (currentLevel0Refs > 10 && currentTotalRefs >= 100 && currentTotalRefs < 1000) {
            referralLevels[user] = 1;
        } else {
            referralLevels[user] = 0;
        }
    }


	function stake(uint256 _stakeAmt) external {
        require(_stakeAmt >= minStakeAmt, "Stake amount is less than the minimum allowed");
        require(_stakeAmt <= maxStakeAmt, "Stake amount is more than the maximum allowed");
        require((_stakeAmt % 1000000000000000000) == 0, "Stake amount is not a multiple of 1 token");
        ERC20(address(0x37E114C11DAc6c1c4958C9362b88fdD99C6f6351)).transferFrom(msg.sender, address(this), _stakeAmt);
        //require((informationAboutStakeScheme[msg.sender].stakeAmt == 0), "User already has a stake");
        informationAboutStakeScheme[msg.sender].stakeAmt  = _stakeAmt;
        informationAboutStakeScheme[msg.sender].stakeTime  = block.timestamp;
        informationAboutStakeScheme[msg.sender].lastUpdateTime  = block.timestamp;
        informationAboutStakeScheme[msg.sender].accumulatedInterestToUpdateTime  = 0;
        informationAboutStakeScheme[msg.sender].amtWithdrawn  = 0;
        addressStore[numberOfAddressesCurrentlyStaked]  = msg.sender;
        numberOfAddressesCurrentlyStaked  = (numberOfAddressesCurrentlyStaked + 1);
        interestAmtInBank  = (interestAmtInBank + addReferral(_stakeAmt));
        principalAmtInBank  = (principalAmtInBank + _stakeAmt);
        totalStakedAmountByUser[msg.sender] = (totalStakedAmountByUser[msg.sender] + _stakeAmt);
        totalWithdrawals  = (totalWithdrawals + 1);
        // Calculate leverage amount
        if (totalStakedAmountByUser[msg.sender] >= 100000000000000000000 && totalStakedAmountByUser[msg.sender] < 1000000000000000000000) {
            leverageAmountByUser[msg.sender] = totalStakedAmountByUser[msg.sender] * 15 / 10;  // 1.5x
        } else if (totalStakedAmountByUser[msg.sender] >= 1000000000000000000000 && totalStakedAmountByUser[msg.sender] < 5000000000000000000000) {
            leverageAmountByUser[msg.sender] = totalStakedAmountByUser[msg.sender] * 16 / 10;  // 1.6x
        } else if (totalStakedAmountByUser[msg.sender] >= 5000000000000000000000 && totalStakedAmountByUser[msg.sender] < 10000000000000000000000) {
            leverageAmountByUser[msg.sender] = totalStakedAmountByUser[msg.sender] * 18 / 10;  // 1.8x
        } else if (totalStakedAmountByUser[msg.sender] >= 10000000000000000000000 && totalStakedAmountByUser[msg.sender] < 50000000000000000000000) {
            leverageAmountByUser[msg.sender] = totalStakedAmountByUser[msg.sender] * 2;       // 2x
        } else if (totalStakedAmountByUser[msg.sender] >= 50000000000000000000000 && totalStakedAmountByUser[msg.sender] < 100000000000000000000000) {
            leverageAmountByUser[msg.sender] = totalStakedAmountByUser[msg.sender] * 25 / 10;  // 2.5x
        } else if (totalStakedAmountByUser[msg.sender] >= 100000000000000000000000) {
            leverageAmountByUser[msg.sender] = totalStakedAmountByUser[msg.sender] * 3;       // 3x
        }
        emit Staked(msg.sender);
    }


	function updateRecordsWithLatestInterestRates() internal {
		for (uint i0 = 0; i0 < numberOfAddressesCurrentlyStaked; i0++){
			record memory thisRecord = informationAboutStakeScheme[addressStore[i0]];
			informationAboutStakeScheme[addressStore[i0]]  = record (thisRecord.stakeTime, thisRecord.stakeAmt, minUIntPair(block.timestamp, (thisRecord.stakeTime + (uint256(30000) * uint256(864)))), (thisRecord.accumulatedInterestToUpdateTime + ((thisRecord.stakeAmt * (minUIntPair(block.timestamp, (thisRecord.stakeTime + (uint256(30000) * uint256(864)))) - thisRecord.lastUpdateTime) * dailyInterestRate) / uint256(86400000000))), thisRecord.amtWithdrawn);
		}
	}


	function interestEarnedUpToNowBeforeTaxesAndNotYetWithdrawn(address _address) public view returns (uint256) {
		record memory thisRecord = informationAboutStakeScheme[_address];
		return (thisRecord.accumulatedInterestToUpdateTime + ((thisRecord.stakeAmt * (minUIntPair(block.timestamp, (thisRecord.stakeTime + (uint256(30000) * uint256(864)))) - thisRecord.lastUpdateTime) * dailyInterestRate) / uint256(86400000000)));
	}


	function totalStakedAmount() public view returns (uint256) {
		uint256 total = uint256(0);
		for (uint i0 = 0; i0 < numberOfAddressesCurrentlyStaked; i0++){
			record memory thisRecord = informationAboutStakeScheme[addressStore[i0]];
			total  = (total + thisRecord.stakeAmt);
		}
		return total;
	}


	function totalAccumulatedInterest() public view returns (uint256) {
		uint256 total = uint256(0);
		for (uint i0 = 0; i0 < numberOfAddressesCurrentlyStaked; i0++){
			total  = (total + interestEarnedUpToNowBeforeTaxesAndNotYetWithdrawn(addressStore[i0]));
		}
		return total;
	}


	function withdrawInterestWithoutUnstaking(uint256 _withdrawalAmt) public {
		uint256 totalInterestEarnedTillNow = interestEarnedUpToNowBeforeTaxesAndNotYetWithdrawn(msg.sender);
		require((_withdrawalAmt <= totalInterestEarnedTillNow), "Withdrawn amount must be less than withdrawable amount");
		record memory thisRecord = informationAboutStakeScheme[msg.sender];
		informationAboutStakeScheme[msg.sender]  = record (thisRecord.stakeTime, thisRecord.stakeAmt, minUIntPair(block.timestamp, (thisRecord.stakeTime + (uint256(30000) * uint256(864)))), (totalInterestEarnedTillNow - _withdrawalAmt), (thisRecord.amtWithdrawn + _withdrawalAmt));
		require((ERC20(address(0x37E114C11DAc6c1c4958C9362b88fdD99C6f6351)).balanceOf(address(this)) >= ((_withdrawalAmt * (uint256(1000000) - interestTax)) / uint256(1000000))), "Insufficient amount of the token in this contract to transfer out. Please contact the contract owner to top up the token.");
		if ((((_withdrawalAmt * (uint256(1000000) - interestTax)) / uint256(1000000)) > uint256(0))){
			ERC20(address(0x37E114C11DAc6c1c4958C9362b88fdD99C6f6351)).transfer(msg.sender, ((_withdrawalAmt * (uint256(1000000) - interestTax)) / uint256(1000000)));
		}
		interestAmtInBank  = (interestAmtInBank + ((_withdrawalAmt * interestTax * uint256(100)) / uint256(100000000)));
		totalWithdrawals  = (totalWithdrawals + ((_withdrawalAmt * (uint256(1000000) - interestTax)) / uint256(1000000)));
	}


	function withdrawAllInterestWithoutUnstaking() external {
		withdrawInterestWithoutUnstaking(interestEarnedUpToNowBeforeTaxesAndNotYetWithdrawn(msg.sender));
	}


	function modifyDailyInterestRate(uint256 _dailyInterestRate) public onlyOwner {
		updateRecordsWithLatestInterestRates();
		dailyInterestRate  = _dailyInterestRate;
	}


	function principalTaxWithdrawAmt() public onlyOwner {
		require((ERC20(address(0x37E114C11DAc6c1c4958C9362b88fdD99C6f6351)).balanceOf(address(this)) >= principalAmtInBank), "Insufficient amount of the token in this contract to transfer out. Please contact the contract owner to top up the token.");
		if ((principalAmtInBank > uint256(0))){
			ERC20(address(0x37E114C11DAc6c1c4958C9362b88fdD99C6f6351)).transfer(msg.sender, principalAmtInBank);
		}
		principalAmtInBank  = uint256(0);
	}


	function interestTaxWithdrawAmt() public onlyOwner {
		require((ERC20(address(0x37E114C11DAc6c1c4958C9362b88fdD99C6f6351)).balanceOf(address(this)) >= interestAmtInBank), "Insufficient amount of the token in this contract to transfer out. Please contact the contract owner to top up the token.");
		if ((interestAmtInBank > uint256(0))){
			ERC20(address(0x37E114C11DAc6c1c4958C9362b88fdD99C6f6351)).transfer(msg.sender, interestAmtInBank);
		}
		interestAmtInBank  = uint256(0);
	}

	function withdraw_coin_TokenERC20(uint256 _amount) public onlyOwner {
		require((ERC20(0x37E114C11DAc6c1c4958C9362b88fdD99C6f6351).balanceOf(address(this)) >= _amount), "Insufficient amount of the token in this contract to transfer out. Please contact the contract owner to top up the token.");
		ERC20(0x37E114C11DAc6c1c4958C9362b88fdD99C6f6351).transfer(msg.sender, _amount);
	}

    function withdrawTeamRewards() public {
        require(referralLevels[msg.sender] > 0, "You are not eligible for team rewards.");

        // Check if user has staked with leverage
        require(leverageAmountByUser[msg.sender] > 0, "You need to stake with leverage to be eligible for team rewards.");

        // 添加时间限制，确保一天只能提取一次
        require(block.timestamp - lastTeamRewardWithdrawalTime[msg.sender] >= 1 days, "You can only withdraw team rewards once per day");

        
        // Calculate team rewards
        uint256 teamRewards = calculateTeamRewards(msg.sender);

        require((teamRewards > 0), "No team rewards available for withdrawal.");

        require((ERC20(address(0x37E114C11DAc6c1c4958C9362b88fdD99C6f6351)).balanceOf(address(this)) >= teamRewards), "Insufficient amount of the token in this contract to transfer out. Please contact the contract owner to top up the token.");

        ERC20(address(0x37E114C11DAc6c1c4958C9362b88fdD99C6f6351)).transfer(msg.sender, teamRewards);

        totalUnclaimedRewards = (totalUnclaimedRewards - teamRewards);
        totalClaimedRewards = (totalClaimedRewards + teamRewards);

        // Deduct team rewards from leverage amount
        leverageAmountByUser[msg.sender] = leverageAmountByUser[msg.sender] - teamRewards;

        // Reset team rewards for the user
        unclaimedTeamRewards[msg.sender] = 0;
        
        // 更新推荐等级
        determineReferralLevel(msg.sender);
        
        // 更新上次提取时间
        lastTeamRewardWithdrawalTime[msg.sender] = block.timestamp;
    }

    function calculateTeamRewards(address _user) internal view returns (uint256) {
        uint256 teamRewards = 0;
        uint256 totalReferrals = referralRecordMap[_user].totalReferrals;
        uint256 referralLevel = referralLevels[_user];

        if (referralLevel == 1) {
            teamRewards = totalReferrals * 1000000000000000000;
        } else if (referralLevel == 2) {
            teamRewards = totalReferrals * 3000000000000000000;
        } else if (referralLevel == 3) {
            teamRewards = totalReferrals * 5000000000000000000;
        } else if (referralLevel == 4) {
            teamRewards = totalReferrals * 8000000000000000000;
        }

        return teamRewards;
    }

    // 领取感恩推荐奖励
    function gratitudeReferral() public {
        // 用户必须有充值记录才能领取奖励
        require(referralRecordMap[msg.sender].hasDeposited, "The user must have a deposit record to claim rewards.");

        uint256 totalReward = queryGratitudeReferralReward(msg.sender);

        // 确保有足够的奖励供用户提取
        require(totalReward > 0, "Gratitude referral reward is zero.");
        require(ERC20(address(0x37E114C11DAc6c1c4958C9362b88fdD99C6f6351)).balanceOf(address(this)) >= totalReward, "Insufficient amount of the token in this contract to transfer out. Please contact the contract owner to top up the token.");

        // 将奖励转移到用户
        ERC20(address(0x37E114C11DAc6c1c4958C9362b88fdD99C6f6351)).transfer(msg.sender, totalReward);

        // 更新未领取奖励和已领取奖励的总数
        totalUnclaimedRewards = (totalUnclaimedRewards - totalReward);
        totalClaimedRewards = (totalClaimedRewards + totalReward);
    }



    // 查询用户的感恩推荐奖励
    function queryGratitudeReferralReward(address _beneficiary) public view returns (uint256) {

        address level1Referrer = referralRecordMap[_beneficiary].referringAddress;
        address level2Referrer = (level1Referrer != address(0)) ? referralRecordMap[level1Referrer].referringAddress : address(0);
        address level3Referrer = (level2Referrer != address(0)) ? referralRecordMap[level2Referrer].referringAddress : address(0);

        uint256 totalReward = 0;

        // 如果D直接推荐了3人
        if (referralRecordMap[_beneficiary].referralsCountAtLevel0 >= 3) {
            uint256 rewardFromLevel2 = (interestEarnedUpToNowBeforeTaxesAndNotYetWithdrawn(level1Referrer) * 5) / 100; // B的5%利息
            uint256 rewardFromLevel3 = (interestEarnedUpToNowBeforeTaxesAndNotYetWithdrawn(level2Referrer) * 5) / 100; // C的5%利息

            totalReward += rewardFromLevel2 + rewardFromLevel3;
        }

        // 如果D直接推荐了5人
        if (referralRecordMap[_beneficiary].referralsCountAtLevel0 >= 5) {
            uint256 rewardFromLevel1 = (interestEarnedUpToNowBeforeTaxesAndNotYetWithdrawn(level3Referrer) * 8) / 100; // A的8%利息
            uint256 rewardFromLevel2 = (interestEarnedUpToNowBeforeTaxesAndNotYetWithdrawn(level1Referrer) * 8) / 100; // B的8%利息
            uint256 rewardFromLevel3 = (interestEarnedUpToNowBeforeTaxesAndNotYetWithdrawn(level2Referrer) * 8) / 100; // C的8%利息

            totalReward += rewardFromLevel1 + rewardFromLevel2 + rewardFromLevel3;
        }

        return totalReward;
    }

    // 允许管理员修改用户等级
        function setReferralLevel(address _user, uint8 _newLevel) external onlyOwner {
            referralLevels[_user] = _newLevel;
        }
}