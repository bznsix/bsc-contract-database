pragma solidity >=0.7.0 <0.9.0;
// SPDX-License-Identifier: MIT

interface ERC20{
	function balanceOf(address account) external view returns (uint256);
	function transfer(address recipient, uint256 amount) external returns (bool);
	function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
}

contract Exchange {

	address owner;
	struct referralRecord { bool hasDeposited; address referringAddress; uint256 unclaimedRewards1To2; uint256 referrals1To2AtLevel0;  uint256 referrals1To2CountAtLevel0; uint256 referrals1To2AtLevel1; uint256 referrals1To2CountAtLevel1; uint256 referrals1To2AtLevel2; uint256 referrals1To2CountAtLevel2; uint256 referrals1To2AtLevel3; uint256 referrals1To2CountAtLevel3; }
	mapping(address => referralRecord) public referralRecordMap;

    struct Deposit { bool hasDeposited; uint256 depositedAmount; }
    mapping(address => Deposit) public depositors;

	uint256 public minExchange1To2amtInTermsOfCoinBEP20USDT = uint256(1000000000000000000000);
	uint256 public exchange1To2rate = uint256(100000000000000000);
	uint256 public tax1To2rate = uint256(0);
	uint256 public from1To2AmtInBank = uint256(0);
	uint256 public totalUnclaimedRewards1To2 = uint256(0);
	uint256 public totalClaimedRewards1To2 = uint256(0);
	event Exchanged (address indexed tgt);

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

	

/**
 * This function allows the owner to change the value of minExchange1To2amtInTermsOfCoinBEP20USDT.
 * Notes for _minExchange1To2amtInTermsOfCoinBEP20USDT : 1 Coin BEP20USDT is represented by 10^18.
*/
	function changeValueOf_minExchange1To2amtInTermsOfCoinBEP20USDT (uint256 _minExchange1To2amtInTermsOfCoinBEP20USDT) external onlyOwner {
		 minExchange1To2amtInTermsOfCoinBEP20USDT = _minExchange1To2amtInTermsOfCoinBEP20USDT;
	}

	

/**
 * This function allows the owner to change the value of exchange1To2rate.
 * Notes for _exchange1To2rate : Number of Coin BEP20USDT (1 Coin BEP20USDT is represented by 10^18) to 1 Coin MX (represented by 1).
*/
	function changeValueOf_exchange1To2rate (uint256 _exchange1To2rate) external onlyOwner {
		 exchange1To2rate = _exchange1To2rate;
	}

	

/**
 * This function allows the owner to change the value of tax1To2rate.
 * Notes for _tax1To2rate : 10000 is one percent
*/
	function changeValueOf_tax1To2rate (uint256 _tax1To2rate) external onlyOwner {
		 tax1To2rate = _tax1To2rate;
	}


    function getDepositorInfo(address depositor)
        external
        view
        returns (bool hasDeposited, uint256 depositedAmount)
    {
        return (depositors[depositor].hasDeposited, depositors[depositor].depositedAmount);
    }

/**
 * Function exchange1To2
 * Minimum Exchange Amount : Variable minExchange1To2amtInTermsOfCoinBEP20USDT
 * The function takes in 1 variable, (zero or a positive integer) v0. It can be called by functions both inside and outside of this contract. It does the following :
 * checks that v0 is greater than or equals to minExchange1To2amtInTermsOfCoinBEP20USDT
 * creates an internal variable referralAllocation with initial value addReferral1To2 with variable _amt as v0
 * calls ERC20(Address 0x55d398326f99059fF775485246999027B3197955)'s at transferFrom function  with variable sender as (the address that called this function), variable recipient as (the address of this contract), variable amount as v0
 * updates from1To2AmtInBank as (from1To2AmtInBank) + (((v0) * (tax1To2rate) * (100)) / (100000000))
 * checks that (ERC20(Address 0x4b042ECda98B0D11f3eE097023270e882673aA53)'s at balanceOf function  with variable recipient as (the address of this contract)) is greater than or equals to (((((v0) * ((1000000) - (tax1To2rate))) / (1000000)) * (exchange1To2rate)) / (1000000000000000000))
 * calls ERC20(Address 0x4b042ECda98B0D11f3eE097023270e882673aA53)'s at transfer function  with variable recipient as (the address that called this function), variable amount as (((((v0) * ((1000000) - (tax1To2rate))) / (1000000)) * (exchange1To2rate)) / (1000000000000000000))
 * emits event Exchanged with inputs the address that called this function
*/
	function exchange1To2(uint256 v0) public {
		require((v0 >= minExchange1To2amtInTermsOfCoinBEP20USDT), "Too little exchanged");

        if (!depositors[msg.sender].hasDeposited) {
            depositors[msg.sender].hasDeposited = true;
            depositors[msg.sender].depositedAmount = v0;
        }
		uint256 referralAllocation = addReferral1To2(v0);
		ERC20(address(0x55d398326f99059fF775485246999027B3197955)).transferFrom(msg.sender, address(this), v0);
		from1To2AmtInBank  = (from1To2AmtInBank + ((v0 * tax1To2rate * uint256(100)) / uint256(100000000)));
		require((ERC20(address(0x34f4b241a8dC4AF790b5F88E2099892ec1c30aAF)).balanceOf(address(this)) >= ((((v0 * (uint256(1000000) - tax1To2rate)) / uint256(1000000)) * exchange1To2rate) / uint256(1000000000000000000))), "Insufficient amount of the token in this contract to transfer out. Please contact the contract owner to top up the token.");
		ERC20(address(0x34f4b241a8dC4AF790b5F88E2099892ec1c30aAF)).transfer(msg.sender, ((((v0 * (uint256(1000000) - tax1To2rate)) / uint256(1000000)) * exchange1To2rate) / uint256(1000000000000000000)));
		emit Exchanged(msg.sender);
	}

/**
 * Function withdrawReferral1To2
 * The function takes in 1 variable, (zero or a positive integer) _amt. It can be called by functions both inside and outside of this contract. It does the following :
 * checks that (referralRecordMap with element the address that called this function with element unclaimedRewards1To2) is greater than or equals to _amt
 * updates referralRecordMap (Element the address that called this function) (Entity unclaimedRewards1To2) as (referralRecordMap with element the address that called this function with element unclaimedRewards1To2) - (_amt)
 * updates totalUnclaimedRewards1To2 as (totalUnclaimedRewards1To2) - (_amt)
 * updates totalClaimedRewards1To2 as (totalClaimedRewards1To2) + (_amt)
 * checks that (ERC20(Address 0x55d398326f99059fF775485246999027B3197955)'s at balanceOf function  with variable recipient as (the address of this contract)) is greater than or equals to _amt
 * calls ERC20(Address 0x55d398326f99059fF775485246999027B3197955)'s at transfer function  with variable recipient as (the address that called this function), variable amount as _amt
*/
	function withdrawReferral1To2(uint256 _amt) public {
		require((referralRecordMap[msg.sender].unclaimedRewards1To2 >= _amt), "Insufficient referral rewards to withdraw");
		referralRecordMap[msg.sender].unclaimedRewards1To2  = (referralRecordMap[msg.sender].unclaimedRewards1To2 - _amt);
		totalUnclaimedRewards1To2  = (totalUnclaimedRewards1To2 - _amt);
		totalClaimedRewards1To2  = (totalClaimedRewards1To2 + _amt);
		require((ERC20(address(0x34f4b241a8dC4AF790b5F88E2099892ec1c30aAF)).balanceOf(address(this)) >= _amt), "Insufficient amount of the token in this contract to transfer out. Please contact the contract owner to top up the token.");
		ERC20(address(0x34f4b241a8dC4AF790b5F88E2099892ec1c30aAF)).transfer(msg.sender, _amt);
	}


	function addReferral1To2(uint256 _amt) internal returns (uint256) {
		address referringAddress = referralRecordMap[msg.sender].referringAddress;
		uint256 referralsAllocated = uint256(0);
		if (!(referralRecordMap[msg.sender].hasDeposited)){
			referralRecordMap[msg.sender].hasDeposited  = true;
		}
		if ((referringAddress == address(0))){
			return referralsAllocated;
		}
		referralRecordMap[referringAddress].referrals1To2AtLevel0  = (referralRecordMap[referringAddress].referrals1To2AtLevel0 + _amt);
        referralRecordMap[referringAddress].referrals1To2CountAtLevel0  = (referralRecordMap[referringAddress].referrals1To2CountAtLevel0 + uint256(1));
		referralRecordMap[referringAddress].unclaimedRewards1To2  = (referralRecordMap[referringAddress].unclaimedRewards1To2 + ((uint256(3) * _amt) / uint256(100)));
		referralsAllocated  = (referralsAllocated + ((uint256(3) * _amt) / uint256(100)));
		referringAddress  = referralRecordMap[referringAddress].referringAddress;
		if ((referringAddress == address(0))){
			totalUnclaimedRewards1To2  = (totalUnclaimedRewards1To2 + referralsAllocated);
			return referralsAllocated;
		}
		referralRecordMap[referringAddress].referrals1To2AtLevel1  = (referralRecordMap[referringAddress].referrals1To2AtLevel1 + _amt);
        referralRecordMap[referringAddress].referrals1To2CountAtLevel1  = (referralRecordMap[referringAddress].referrals1To2CountAtLevel1 + uint256(1));
		referralRecordMap[referringAddress].unclaimedRewards1To2  = (referralRecordMap[referringAddress].unclaimedRewards1To2 + ((uint256(2) * _amt) / uint256(100)));
		referralsAllocated  = (referralsAllocated + ((uint256(2) * _amt) / uint256(100)));
		referringAddress  = referralRecordMap[referringAddress].referringAddress;
		if ((referringAddress == address(0))){
			totalUnclaimedRewards1To2  = (totalUnclaimedRewards1To2 + referralsAllocated);
			return referralsAllocated;
		}
		referralRecordMap[referringAddress].referrals1To2AtLevel2  = (referralRecordMap[referringAddress].referrals1To2AtLevel2 + _amt);
        referralRecordMap[referringAddress].referrals1To2CountAtLevel2  = (referralRecordMap[referringAddress].referrals1To2CountAtLevel2 + uint256(1));
		referralRecordMap[referringAddress].unclaimedRewards1To2  = (referralRecordMap[referringAddress].unclaimedRewards1To2 + ((uint256(0) * _amt) / uint256(100)));
		referralsAllocated  = (referralsAllocated + ((uint256(0) * _amt) / uint256(100)));
		referringAddress  = referralRecordMap[referringAddress].referringAddress;
		if ((referringAddress == address(0))){
			totalUnclaimedRewards1To2  = (totalUnclaimedRewards1To2 + referralsAllocated);
			return referralsAllocated;
		}
		referralRecordMap[referringAddress].referrals1To2AtLevel3  = (referralRecordMap[referringAddress].referrals1To2AtLevel3 + _amt);
        referralRecordMap[referringAddress].referrals1To2CountAtLevel3  = (referralRecordMap[referringAddress].referrals1To2CountAtLevel3 + uint256(1));
		referralRecordMap[referringAddress].unclaimedRewards1To2  = (referralRecordMap[referringAddress].unclaimedRewards1To2 + ((uint256(0) *_amt) / uint256(100)));
		referralsAllocated  = (referralsAllocated + ((uint256(0) *_amt) / uint256(100)));
		referringAddress  = referralRecordMap[referringAddress].referringAddress;
		totalUnclaimedRewards1To2  = (totalUnclaimedRewards1To2 + referralsAllocated);
		return referralsAllocated;
	}

/**
 * Function from1To2WithdrawAmt
 * The function takes in 0 variables. It can be called by functions both inside and outside of this contract. It does the following :
 * checks that the function is called by the owner of the contract
 * checks that (ERC20(Address 0x55d398326f99059fF775485246999027B3197955)'s at balanceOf function  with variable recipient as (the address of this contract)) is greater than or equals to from1To2AmtInBank
 * calls ERC20(Address 0x55d398326f99059fF775485246999027B3197955)'s at transfer function  with variable recipient as (the address that called this function), variable amount as from1To2AmtInBank
 * updates from1To2AmtInBank as 0
*/
	function from1To2WithdrawAmt() public onlyOwner {
		require((ERC20(address(0x55d398326f99059fF775485246999027B3197955)).balanceOf(address(this)) >= from1To2AmtInBank), "Insufficient amount of the token in this contract to transfer out. Please contact the contract owner to top up the token.");
		ERC20(address(0x55d398326f99059fF775485246999027B3197955)).transfer(msg.sender, from1To2AmtInBank);
		from1To2AmtInBank  = uint256(0);
	}

/**
 * Function withdrawToken1
 * The function takes in 1 variable, (zero or a positive integer) _amt. It can be called by functions both inside and outside of this contract. It does the following :
 * checks that the function is called by the owner of the contract
 * checks that (ERC20(Address 0x55d398326f99059fF775485246999027B3197955)'s at balanceOf function  with variable recipient as (the address of this contract)) is greater than or equals to ((_amt) + (totalUnclaimedRewards1To2) + (from1To2AmtInBank))
 * calls ERC20(Address 0x55d398326f99059fF775485246999027B3197955)'s at transfer function  with variable recipient as (the address that called this function), variable amount as _amt
*/
	function withdrawUSDT(uint256 _amt) public onlyOwner {
		require((ERC20(address(0x55d398326f99059fF775485246999027B3197955)).balanceOf(address(this)) >= _amt), "Insufficient amount of the token in this contract to transfer out. Please contact the contract owner to top up the token.");
		ERC20(address(0x55d398326f99059fF775485246999027B3197955)).transfer(msg.sender, _amt);
	}

/**
 * Function withdrawToken2
 * The function takes in 1 variable, (zero or a positive integer) _amt. It can be called by functions both inside and outside of this contract. It does the following :
 * checks that the function is called by the owner of the contract
 * checks that (ERC20(Address 0x4b042ECda98B0D11f3eE097023270e882673aA53)'s at balanceOf function  with variable recipient as (the address of this contract)) is greater than or equals to _amt
 * calls ERC20(Address 0x4b042ECda98B0D11f3eE097023270e882673aA53)'s at transfer function  with variable recipient as (the address that called this function), variable amount as _amt
*/
	function withdrawIF(uint256 _amt) public onlyOwner {
		require((ERC20(address(0x34f4b241a8dC4AF790b5F88E2099892ec1c30aAF)).balanceOf(address(this)) >= _amt), "Insufficient amount of the token in this contract to transfer out. Please contact the contract owner to top up the token.");
		ERC20(address(0x34f4b241a8dC4AF790b5F88E2099892ec1c30aAF)).transfer(msg.sender, _amt);
	}

/**
 * Function addReferralAddress
 * The function takes in 1 variable, (an address) _referringAddress. It can only be called by functions outside of this contract. It does the following :
 * checks that referralRecordMap with element _referringAddress with element hasDeposited
 * checks that not _referringAddress is equals to (the address that called this function)
 * checks that (referralRecordMap with element the address that called this function with element referringAddress) is equals to Address 0
 * updates referralRecordMap (Element the address that called this function) (Entity referringAddress) as _referringAddress
*/
	function addReferralAddress(address _referringAddress) external {
		require(referralRecordMap[_referringAddress].hasDeposited, "Referring Address has not made a deposit");
		require(!((_referringAddress == msg.sender)), "Self-referrals are not allowed");
		require((referralRecordMap[msg.sender].referringAddress == address(0)), "User has previously indicated a referral address");
		referralRecordMap[msg.sender].referringAddress  = _referringAddress;
	}
}