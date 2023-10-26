// SPDX-License-Identifier: MIT

pragma solidity >=0.6.2;

contract MoonCash {
    uint256 public MOONERS_FOR_1BNB = 10000;
    uint256 public SECOND_RATE = 347223;
    uint256 public SECOND_RATE_SCALE = 10**10;
    uint256 public REF_RATE = 8;
    uint256 public DECIMALS = 10**18;
    uint256 public WITHDRAW_TERM = 30;

    bool public initialized = false;

    address payable public devAddress;
    mapping(address => uint256) public claimedEggs;
    mapping(address => uint256) public lastHatch;
    mapping(address => uint256) public lastCompound;
    mapping(address => uint256) public firstBuy;
    mapping(address => address) public referrals;

    constructor() {
        devAddress = payable(msg.sender);
    }

    modifier onlyOwner() {
        require(devAddress == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    function buyMooners(address ref) public payable {
        require(initialized, "Platform is not already active");
        //calculate mooners
        uint256 eggsBought = calculateEggBuy(msg.value);
        //calculate devFee and trasfer
        uint256 fee = devFee(msg.value);
        devAddress.transfer(fee);
        //check if user already bought
        if (firstBuy[msg.sender] == 0) {
            firstBuy[msg.sender] = block.timestamp;
        }
        //assign mooners to the user
        claimedEggs[msg.sender] = SafeMath.add(claimedEggs[msg.sender],eggsBought);
        //compound to the referral (if referral not exist send compound to dead wallet)
        uint256 referralEggs = SafeMath.div(SafeMath.mul(eggsBought, REF_RATE),100);
        sendReferralMooners(ref, referralEggs);
    }

    function getProfitsFromMooners() public {
        require(initialized, "Platform is not already active");
        //get numdays of first buy
        uint256 numDays = calculateDaysBuy(msg.sender);
        //check if 30days are passed from the first buy
        require(numDays >= WITHDRAW_TERM, "You need to wait 30 days from your first buy");
        //get alla mooners of the user
        uint256 hasEggs = getMyEggs(msg.sender);
        //calculate the profit
        uint256 eggValue = calculateEggSell(hasEggs, msg.sender);
        //calculate devFee and trasfer
        uint256 fee = devFee(eggValue);
        devAddress.transfer(fee);
        //assign the date of the last withdraw
        lastHatch[msg.sender] = block.timestamp;
        //send profits to the user wallet
        payable(msg.sender).transfer(SafeMath.sub(eggValue, fee));
    }

    function compoundMooners() public {
        require(initialized, "Platform is not already active");

        //calculate new user mooners
        uint256 userEggs = getMyEggs(msg.sender);
        uint256 profitsToCompund = calculateEggSell(userEggs, msg.sender);
        uint256 newMiners = SafeMath.div(SafeMath.mul(profitsToCompund, MOONERS_FOR_1BNB), DECIMALS);
        //store the date of the last compound
        lastCompound[msg.sender] = block.timestamp;

        //add new Mooners to user wallet
        claimedEggs[msg.sender] = SafeMath.add(claimedEggs[msg.sender],newMiners);
    }

    function sendReferralMooners(address ref, uint256 value) private {
        uint256 eggs = value;
        claimedEggs[ref] = SafeMath.add(claimedEggs[ref], eggs);
    }

    function giveMoonersForSponsorship(address ref, uint256 value) public onlyOwner {
        uint256 eggs = value;
        firstBuy[ref] = block.timestamp;
        claimedEggs[ref] = SafeMath.add(claimedEggs[ref], eggs);
    }

    function initPlatform(bool start) public onlyOwner {
        if (start == true) {
            initialized = true;
        }
    }

    function calculateEggSell(uint256 eggs, address user) public view returns (uint256) {
        //calculate numdays from last user action
        uint256 numSeconds = calculateSeconds(user);
        //calculate number of BNBs related to number of Mooners
        uint256 eth_num = SafeMath.div(SafeMath.mul(eggs, 100), MOONERS_FOR_1BNB);
        //calculate profits to withdraw
        uint256 profits = SafeMath.div(SafeMath.div(SafeMath.div(SafeMath.mul(SafeMath.mul(SafeMath.mul(eth_num, numSeconds), SECOND_RATE), DECIMALS), SECOND_RATE_SCALE),100),100);

        return profits;
    }

    function calculateSeconds(address user) public view returns (uint256) {
        //get the date of the last user withdraw
        uint256 last_withdraw = lastHatch[user];
        //check if there was a compound
        if (last_withdraw == 0) {
            last_withdraw = lastCompound[user];
        }
        //check if there was a withdraw or a compound, if not get the buy date
        if (last_withdraw == 0) {
            last_withdraw = firstBuy[user];
        }
        uint256 today_date = block.timestamp;
        //calculate the number of seconds
        uint256 numSeconds = SafeMath.sub(today_date, last_withdraw);

        return numSeconds;
    }

    function calculateDaysBuy(address user) public view returns (uint256) {
        //get the date of the last user buy
        uint256 last_buy = firstBuy[user];
        uint256 today_date = block.timestamp;
        //calculate the number of days
        uint256 diff = SafeMath.sub(today_date, last_buy);
        uint256 numDays = SafeMath.div(SafeMath.div(SafeMath.div(diff, 60), 60),24);

        return numDays;
    }

    function calculateEggBuy(uint256 eth_num) public view returns (uint256) {
        return SafeMath.div(SafeMath.mul(eth_num, MOONERS_FOR_1BNB), DECIMALS);
    }

    function devFee(uint256 amount) public pure returns (uint256) {
        return SafeMath.div(SafeMath.mul(amount, 5), 100);
    }

    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }

    function getMyEggs(address user) public view returns (uint256) {
        return claimedEggs[user];
    }
}

library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        assert(c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // assert(b > 0); // Solidity automatically throws when dividing by 0
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
}