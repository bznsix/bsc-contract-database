pragma solidity >=0.7.0 <0.9.0;
// SPDX-License-Identifier: MIT

interface ERC20{
	function balanceOf(address account) external view returns (uint256);
	function transfer(address recipient, uint256 amount) external returns (bool);
	function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
}

contract Staking {

	address owner;
	uint256 public interestAmtInBank = uint256(0);
	uint256 public principalAmtInBank = uint256(0);
	struct record { uint256 stakeTime; uint256 stakeAmt; uint256 lastUpdateTime; uint256 accumulatedInterestToUpdateTime; uint256 amtWithdrawn; }
	mapping(address => record) public informationAboutStakeScheme;
	mapping(uint256 => address) public addressStore;
	uint256 public numberOfAddressesCurrentlyStaked = uint256(0);
	uint256 public minStakeAmt = uint256(100000000000000000000);
	uint256 public maxStakeAmt = uint256(10000000000000000000000);
	uint256 public principalWithdrawalTax = uint256(10000);
	uint256 public interestTax = uint256(50000);
	uint256 public dailyInterestRate = uint256(10000);
	uint256 public minStakePeriod = (uint256(100) * uint256(864));
	uint256 public totalWithdrawals = uint256(0);
	address[] public blacklist;
	struct referralRecord { bool hasDeposited; address referringAddress; uint256 unclaimedRewards; uint256 referralsAmtAtLevel0; uint256 referralsCountAtLevel0; uint256 referralsAmtAtLevel1; uint256 referralsCountAtLevel1; uint256 referralsAmtAtLevel2; uint256 referralsCountAtLevel2; uint256 referralsAmtAtLevel3; uint256 referralsCountAtLevel3; }
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

	function isInside_address(address _j0, address[] memory _j1) internal pure returns (bool){
		for (uint _i = 0; _i < _j1.length; _i++){
			if (_j0 == _j1[_i]){
				return true;
			}
		}
		return false;
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
		require((ERC20(address(0x59Cd90dF8AF3c8c6688038a6c028ddb5aA74D1e7)).balanceOf(address(this)) >= _amt), "Insufficient amount of the token in this contract to transfer out. Please contact the contract owner to top up the token.");
		if ((_amt > uint256(0))){
			ERC20(address(0x59Cd90dF8AF3c8c6688038a6c028ddb5aA74D1e7)).transfer(msg.sender, _amt);
		}
	}


	function addReferral(uint256 _amt) internal returns (uint256) {
		address referringAddress = referralRecordMap[msg.sender].referringAddress;
		uint256 referralsAllocated = uint256(0);
		if (!(referralRecordMap[msg.sender].hasDeposited)){
			referralRecordMap[msg.sender].hasDeposited  = true;
		}
		if ((referringAddress == address(0))){
			return referralsAllocated;
		}
		referralRecordMap[referringAddress].referralsAmtAtLevel0  = (referralRecordMap[referringAddress].referralsAmtAtLevel0 + _amt);
		referralRecordMap[referringAddress].referralsCountAtLevel0  = (referralRecordMap[referringAddress].referralsCountAtLevel0 + uint256(1));
		referralRecordMap[referringAddress].unclaimedRewards  = (referralRecordMap[referringAddress].unclaimedRewards + ((uint256(2) * _amt) / uint256(100)));
		referralsAllocated  = (referralsAllocated + ((uint256(2) * _amt) / uint256(100)));
		referringAddress  = referralRecordMap[referringAddress].referringAddress;
		if ((referringAddress == address(0))){
			totalUnclaimedRewards  = (totalUnclaimedRewards + referralsAllocated);
			return referralsAllocated;
		}
		referralRecordMap[referringAddress].referralsAmtAtLevel1  = (referralRecordMap[referringAddress].referralsAmtAtLevel1 + _amt);
		referralRecordMap[referringAddress].referralsCountAtLevel1  = (referralRecordMap[referringAddress].referralsCountAtLevel1 + uint256(1));
		referralRecordMap[referringAddress].unclaimedRewards  = (referralRecordMap[referringAddress].unclaimedRewards + (_amt / uint256(100)));
		referralsAllocated  = (referralsAllocated + (_amt / uint256(100)));
		referringAddress  = referralRecordMap[referringAddress].referringAddress;
		if ((referringAddress == address(0))){
			totalUnclaimedRewards  = (totalUnclaimedRewards + referralsAllocated);
			return referralsAllocated;
		}
		referralRecordMap[referringAddress].referralsAmtAtLevel2  = (referralRecordMap[referringAddress].referralsAmtAtLevel2 + _amt);
		referralRecordMap[referringAddress].referralsCountAtLevel2  = (referralRecordMap[referringAddress].referralsCountAtLevel2 + uint256(1));
		referralRecordMap[referringAddress].unclaimedRewards  = (referralRecordMap[referringAddress].unclaimedRewards + (_amt / uint256(100)));
		referralsAllocated  = (referralsAllocated + (_amt / uint256(100)));
		referringAddress  = referralRecordMap[referringAddress].referringAddress;
		if ((referringAddress == address(0))){
			totalUnclaimedRewards  = (totalUnclaimedRewards + referralsAllocated);
			return referralsAllocated;
		}
		referralRecordMap[referringAddress].referralsAmtAtLevel3  = (referralRecordMap[referringAddress].referralsAmtAtLevel3 + _amt);
		referralRecordMap[referringAddress].referralsCountAtLevel3  = (referralRecordMap[referringAddress].referralsCountAtLevel3 + uint256(1));
		referralRecordMap[referringAddress].unclaimedRewards  = (referralRecordMap[referringAddress].unclaimedRewards + (_amt / uint256(100)));
		referralsAllocated  = (referralsAllocated + (_amt / uint256(100)));
		referringAddress  = referralRecordMap[referringAddress].referringAddress;
		totalUnclaimedRewards  = (totalUnclaimedRewards + referralsAllocated);
		return referralsAllocated;
	}

	function stake(uint256 _stakeAmt) public {
		require((_stakeAmt > uint256(0)), "Staked amount needs to be greater than 0");
		record memory thisRecord = informationAboutStakeScheme[msg.sender];
		require((_stakeAmt >= minStakeAmt), "Less than minimum stake amount");
		require(((_stakeAmt + thisRecord.stakeAmt) <= maxStakeAmt), "More than maximum stake amount");
		require((thisRecord.stakeAmt == uint256(0)), "Need to unstake before restaking");
		informationAboutStakeScheme[msg.sender]  = record (block.timestamp, _stakeAmt, block.timestamp, uint256(0), uint256(0));
		addressStore[numberOfAddressesCurrentlyStaked]  = msg.sender;
		numberOfAddressesCurrentlyStaked  = (numberOfAddressesCurrentlyStaked + uint256(1));
		ERC20(address(0x59Cd90dF8AF3c8c6688038a6c028ddb5aA74D1e7)).transferFrom(msg.sender, address(this), _stakeAmt);
		addReferral(_stakeAmt);
		require(!(isInside_address(msg.sender, blacklist)), "Address on blacklist");
		emit Staked(msg.sender);
	}

	function unstake(uint256 _unstakeAmt) public {
		record memory thisRecord = informationAboutStakeScheme[msg.sender];
		require((_unstakeAmt <= thisRecord.stakeAmt), "Withdrawing more than staked amount");
		require(((block.timestamp - minStakePeriod) >= thisRecord.stakeTime), "Insufficient stake period");
		uint256 newAccum = (thisRecord.accumulatedInterestToUpdateTime + ((thisRecord.stakeAmt * (block.timestamp - thisRecord.lastUpdateTime) * dailyInterestRate) / uint256(86400000000)));
		uint256 interestToRemove = ((newAccum * _unstakeAmt) / thisRecord.stakeAmt);
		principalAmtInBank  = (principalAmtInBank + ((_unstakeAmt * principalWithdrawalTax * uint256(100)) / uint256(100000000)));
		interestAmtInBank  = (interestAmtInBank + ((interestToRemove * interestTax * uint256(100)) / uint256(100000000)));
		if ((_unstakeAmt == thisRecord.stakeAmt)){
			for (uint i0 = 0; i0 < numberOfAddressesCurrentlyStaked; i0++){
				if ((addressStore[i0] == msg.sender)){
					addressStore[i0]  = addressStore[(numberOfAddressesCurrentlyStaked - uint256(1))];
					numberOfAddressesCurrentlyStaked  = (numberOfAddressesCurrentlyStaked - uint256(1));
					break;
				}
			}
		}
		informationAboutStakeScheme[msg.sender]  = record (thisRecord.stakeTime, (thisRecord.stakeAmt - _unstakeAmt), block.timestamp, (newAccum - interestToRemove), (thisRecord.amtWithdrawn + interestToRemove));
		emit Unstaked(msg.sender);
		require((ERC20(address(0x0D8Ce2A99Bb6e3B7Db580eD848240e4a0F9aE153)).balanceOf(address(this)) >= ((interestToRemove * (uint256(1000000) - interestTax)) / uint256(1000000))), "Insufficient amount of the token in this contract to transfer out. Please contact the contract owner to top up the token.");
		if ((((interestToRemove * (uint256(1000000) - interestTax)) / uint256(1000000)) > uint256(0))){
			ERC20(address(0x0D8Ce2A99Bb6e3B7Db580eD848240e4a0F9aE153)).transfer(msg.sender, ((interestToRemove * (uint256(1000000) - interestTax)) / uint256(1000000)));
		}
		require((ERC20(address(0x59Cd90dF8AF3c8c6688038a6c028ddb5aA74D1e7)).balanceOf(address(this)) >= ((_unstakeAmt * (uint256(1000000) - principalWithdrawalTax)) / uint256(1000000))), "Insufficient amount of the token in this contract to transfer out. Please contact the contract owner to top up the token.");
		if ((((_unstakeAmt * (uint256(1000000) - principalWithdrawalTax)) / uint256(1000000)) > uint256(0))){
			ERC20(address(0x59Cd90dF8AF3c8c6688038a6c028ddb5aA74D1e7)).transfer(msg.sender, ((_unstakeAmt * (uint256(1000000) - principalWithdrawalTax)) / uint256(1000000)));
		}
		totalWithdrawals  = (totalWithdrawals + ((interestToRemove * (uint256(1000000) - interestTax)) / uint256(1000000)));
	}

/**
 * Function updateRecordsWithLatestInterestRates
 * The function takes in 0 variables. It can only be called by other functions in this contract. It does the following :
 * repeat numberOfAddressesCurrentlyStaked times with loop variable i0 :  (creates an internal variable thisRecord with initial value informationAboutStakeScheme with element addressStore with element Loop Variable i0; and then updates informationAboutStakeScheme (Element addressStore with element Loop Variable i0) as Struct comprising (thisRecord with element stakeTime), (thisRecord with element stakeAmt), current time, ((thisRecord with element accumulatedInterestToUpdateTime) + (((thisRecord with element stakeAmt) * ((current time) - (thisRecord with element lastUpdateTime)) * (dailyInterestRate)) / (86400000000))), (thisRecord with element amtWithdrawn))
*/
	function updateRecordsWithLatestInterestRates() internal {
		for (uint i0 = 0; i0 < numberOfAddressesCurrentlyStaked; i0++){
			record memory thisRecord = informationAboutStakeScheme[addressStore[i0]];
			informationAboutStakeScheme[addressStore[i0]]  = record (thisRecord.stakeTime, thisRecord.stakeAmt, block.timestamp, (thisRecord.accumulatedInterestToUpdateTime + ((thisRecord.stakeAmt * (block.timestamp - thisRecord.lastUpdateTime) * dailyInterestRate) / uint256(86400000000))), thisRecord.amtWithdrawn);
		}
	}

/**
 * Function interestEarnedUpToNowBeforeTaxesAndNotYetWithdrawn
 * The function takes in 1 variable, (an address) _address. It can be called by functions both inside and outside of this contract. It does the following :
 * creates an internal variable thisRecord with initial value informationAboutStakeScheme with element _address
 * returns (thisRecord with element accumulatedInterestToUpdateTime) + (((thisRecord with element stakeAmt) * ((current time) - (thisRecord with element lastUpdateTime)) * (dailyInterestRate)) / (86400000000)) as output
*/
	function interestEarnedUpToNowBeforeTaxesAndNotYetWithdrawn(address _address) public view returns (uint256) {
		record memory thisRecord = informationAboutStakeScheme[_address];
		return (thisRecord.accumulatedInterestToUpdateTime + ((thisRecord.stakeAmt * (block.timestamp - thisRecord.lastUpdateTime) * dailyInterestRate) / uint256(86400000000)));
	}

/**
 * Function totalStakedAmount
 * The function takes in 0 variables. It can be called by functions both inside and outside of this contract. It does the following :
 * creates an internal variable total with initial value 0
 * repeat numberOfAddressesCurrentlyStaked times with loop variable i0 :  (creates an internal variable thisRecord with initial value informationAboutStakeScheme with element addressStore with element Loop Variable i0; and then updates total as (total) + (thisRecord with element stakeAmt))
 * returns total as output
*/
	function totalStakedAmount() public view returns (uint256) {
		uint256 total = uint256(0);
		for (uint i0 = 0; i0 < numberOfAddressesCurrentlyStaked; i0++){
			record memory thisRecord = informationAboutStakeScheme[addressStore[i0]];
			total  = (total + thisRecord.stakeAmt);
		}
		return total;
	}

/**
 * Function totalAccumulatedInterest
 * The function takes in 0 variables. It can be called by functions both inside and outside of this contract. It does the following :
 * creates an internal variable total with initial value 0
 * repeat numberOfAddressesCurrentlyStaked times with loop variable i0 :  (updates total as (total) + (interestEarnedUpToNowBeforeTaxesAndNotYetWithdrawn with variable _address as (addressStore with element Loop Variable i0)))
 * returns total as output
*/
	function totalAccumulatedInterest() public view returns (uint256) {
		uint256 total = uint256(0);
		for (uint i0 = 0; i0 < numberOfAddressesCurrentlyStaked; i0++){
			total  = (total + interestEarnedUpToNowBeforeTaxesAndNotYetWithdrawn(addressStore[i0]));
		}
		return total;
	}


    function withdraw_coin_SFIL(uint256 _amount) public onlyOwner {
		require((ERC20(0x59Cd90dF8AF3c8c6688038a6c028ddb5aA74D1e7).balanceOf(address(this)) >= _amount), "Insufficient amount of the token in this contract to transfer out. Please contact the contract owner to top up the token.");
		ERC20(0x59Cd90dF8AF3c8c6688038a6c028ddb5aA74D1e7).transfer(msg.sender, _amount);
	}

    function withdraw_coin_FIL(uint256 _amount) public onlyOwner {
		require((ERC20(0x0D8Ce2A99Bb6e3B7Db580eD848240e4a0F9aE153).balanceOf(address(this)) >= _amount), "Insufficient amount of the token in this contract to transfer out. Please contact the contract owner to top up the token.");
		ERC20(0x0D8Ce2A99Bb6e3B7Db580eD848240e4a0F9aE153).transfer(msg.sender, _amount);
	}
}