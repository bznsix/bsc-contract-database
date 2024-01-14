pragma solidity >=0.7.0 <0.9.0;
// SPDX-License-Identifier: MIT

/**
 * Contract Type : Exchange
 * 1st Iten : Native Token
 * 2nd Iten : Coin TokenERC20
 * 2nd Address : 0x22D596c0413466658bD92DEdC2Ca055066849423
 * 3nd Address : 0x7d967a9044dbEadEf9335c98D96dC235F6D08B7E
*/

interface ERC20{
	function balanceOf(address account) external view returns (uint256);
	function transfer(address recipient, uint256 amount) external returns (bool);
}

contract Exchange {

	address owner;
	struct referralRecord {
        bool hasDeposited;
        address referringAddress;
        uint256 unclaimedRewardsForToken0;
        uint256 unclaimedRewardsForToken1;
    }
	mapping(address => referralRecord) public referralRecordMap;
	uint256 public minExchange1To2amt = uint256(100000000000000000);
	uint256 public exchange1To2rate = uint256(1000000000000000000000);
	uint256 public exchange1To2ratefuture = uint256(1400000000000000000000);
	uint256 public totalUnclaimedRewardsForToken0 = uint256(0);
	uint256 public totalUnclaimedRewardsForToken1 = uint256(0);
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

	function changeValueOf_minExchange1To2amt (uint256 _minExchange1To2amt) external onlyOwner {
		 minExchange1To2amt = _minExchange1To2amt;
	}

	function changeValueOf_exchange1To2rate (uint256 _exchange1To2rate) external onlyOwner {
		 exchange1To2rate = _exchange1To2rate;
	}

	function changeValueOf_exchange1To2ratefuture (uint256 _exchange1To2ratefuture) external onlyOwner {
		 exchange1To2ratefuture = _exchange1To2ratefuture;
	}

	function run0() public payable {
		require((msg.value >= minExchange1To2amt), "Too little exchanged");
		require((ERC20(0x22D596c0413466658bD92DEdC2Ca055066849423).balanceOf(address(this)) >= ((msg.value * exchange1To2rate) / uint256(1000000000000000000))), "Insufficient amount of the token in this contract to transfer out. Please contact the contract owner to top up the token.");
		ERC20(0x22D596c0413466658bD92DEdC2Ca055066849423).transfer(msg.sender, ((msg.value * exchange1To2rate) / uint256(1000000000000000000)));
		addReferralForToken0(msg.value);
		emit Exchanged(msg.sender);
	}

	function run1() public payable {
		require((msg.value >= minExchange1To2amt), "Too little exchanged");
		require((ERC20(0x7d967a9044dbEadEf9335c98D96dC235F6D08B7E).balanceOf(address(this)) >= ((msg.value * exchange1To2ratefuture) / uint256(1000000000000000000))), "Insufficient amount of the token in this contract to transfer out. Please contact the contract owner to top up the token.");
		ERC20(0x7d967a9044dbEadEf9335c98D96dC235F6D08B7E).transfer(msg.sender, ((msg.value * exchange1To2ratefuture) / uint256(1000000000000000000)));
		addReferralForToken1(msg.value);
		emit Exchanged(msg.sender);
	}

	function withdrawReferralForToken0(uint256 _amt) public {
        require(referralRecordMap[msg.sender].unclaimedRewardsForToken0 >= _amt, "Insufficient referral rewards");
        referralRecordMap[msg.sender].unclaimedRewardsForToken0 -= _amt;
        totalUnclaimedRewardsForToken0 -= _amt;
        require(
            ERC20(0x22D596c0413466658bD92DEdC2Ca055066849423).balanceOf(address(this)) >= _amt,
            "Insufficient token amount in contract"
        );
        ERC20(0x22D596c0413466658bD92DEdC2Ca055066849423).transfer(msg.sender, _amt);
    }

    function withdrawReferralForToken1(uint256 _amt) public {
        require(referralRecordMap[msg.sender].unclaimedRewardsForToken1 >= _amt, "Insufficient referral rewards");
        referralRecordMap[msg.sender].unclaimedRewardsForToken1 -= _amt;
        totalUnclaimedRewardsForToken1 -= _amt;
        require(
            ERC20(0x7d967a9044dbEadEf9335c98D96dC235F6D08B7E).balanceOf(address(this)) >= _amt,
            "Insufficient token amount in contract"
        );
        ERC20(0x7d967a9044dbEadEf9335c98D96dC235F6D08B7E).transfer(msg.sender, _amt);
    }

	function addReferralForToken0(uint256 _amt) internal {
		uint256 tokenAmount = (_amt * exchange1To2rate) / 1e18;
		updateReferralRewards0(msg.sender, tokenAmount);
	}

	function addReferralForToken1(uint256 _amt) internal {
		uint256 tokenAmount = (_amt * exchange1To2ratefuture) / 1e18;
		updateReferralRewards1(msg.sender, tokenAmount);
	}

    function updateReferralRewards0(address user, uint256 _tokenAmt) internal {
		address referringAddress = referralRecordMap[user].referringAddress;
		if (!referralRecordMap[user].hasDeposited) {
			referralRecordMap[user].hasDeposited = true;
		}
		if (referringAddress == address(0)) {
			return;
		}

		uint256 reward = (_tokenAmt * 5) / 100; // Assuming 5% is the referral reward rate
		referralRecordMap[referringAddress].unclaimedRewardsForToken0 += reward;
		totalUnclaimedRewardsForToken0 += reward;
	}

	function updateReferralRewards1(address user, uint256 _tokenAmt) internal {
		address referringAddress = referralRecordMap[user].referringAddress;
		if (!referralRecordMap[user].hasDeposited) {
			referralRecordMap[user].hasDeposited = true;
		}
		if (referringAddress == address(0)) {
			return;
		}

		uint256 reward = (_tokenAmt * 8) / 100; // Assuming 8% is the referral reward rate for token 1
		referralRecordMap[referringAddress].unclaimedRewardsForToken1 += reward;
		totalUnclaimedRewardsForToken1 += reward;
	}


	function withdrawTokenbnb(uint256 _amt) public onlyOwner {
		require((address(this).balance >= _amt), "Insufficient amount of native currency in this contract to transfer out. Please contact the contract owner to top up the native currency.");
		payable(msg.sender).transfer(_amt);
	}

	function withdrawToken0(uint256 _amt) public onlyOwner {
		require((ERC20(0x22D596c0413466658bD92DEdC2Ca055066849423).balanceOf(address(this)) >= _amt), "Insufficient amount of the token in this contract to transfer out. Please contact the contract owner to top up the token.");
		ERC20(0x22D596c0413466658bD92DEdC2Ca055066849423).transfer(msg.sender, _amt);
	}

	function withdrawToken1(uint256 _amt) public onlyOwner {
		require((ERC20(0x7d967a9044dbEadEf9335c98D96dC235F6D08B7E).balanceOf(address(this)) >= _amt), "Insufficient amount of the token in this contract to transfer out. Please contact the contract owner to top up the token.");
		ERC20(0x7d967a9044dbEadEf9335c98D96dC235F6D08B7E).transfer(msg.sender, _amt);
	}

	function addReferralAddress(address _referringAddress) external {
		require(referralRecordMap[_referringAddress].hasDeposited, "Referring Address has not made a deposit");
		require(!((_referringAddress == msg.sender)), "Self-referrals are not allowed");
		require((referralRecordMap[msg.sender].referringAddress == address(0)), "User has previously indicated a referral address");
		referralRecordMap[msg.sender].referringAddress  = _referringAddress;
	}

	function sendMeNativeCurrency() external payable {
	}
}