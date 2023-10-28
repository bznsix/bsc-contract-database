// SPDX-License-Identifier: MIT 

pragma solidity ^0.4.26; // solhint-disable-line

contract BEP20 {
    function totalSupply() public constant returns (uint);
    function balanceOf(address tokenOwner) public constant returns (uint balance);
    function allowance(address tokenOwner, address spender) public constant returns (uint remaining);
    function transfer(address to, uint tokens) public returns (bool success);
    function approve(address spender, uint tokens) public returns (bool success);
    function transferFrom(address from, address to, uint tokens) public returns (bool success);
    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}

contract shi20_miner {
    //uint256 EGGS_PER_MINERS_PER_SECOND=1;
    address SHI20 =0x7eb336D88f1E0a75662679Ca72C493DD81Cb5B73; 
    uint256 public EGGS_TO_HATCH_1MINERS=540000;//for final version should be seconds in a day
    uint256 PSN=10000;
    uint256 PSNH=5000;
    bool public initialized=false;
    address public ceoAddress;
    address public newCeoAddress;  // New owner address
    mapping (address => uint256) public hatcheryMiners;
    mapping (address => uint256) public claimedEggs;
    mapping (address => uint256) public lastHatch;
    mapping (address => address) public referrals;
    uint256 public marketEggs;
    constructor() public{
        ceoAddress = msg.sender; // The contract deployer is the owner
        newCeoAddress=address(0x8817CEe820F0Da553Af81C29f2c69F2940219539);
    }

    modifier onlyCEO() {
        require(msg.sender == ceoAddress, "Only the current CEO can call this function");
        _;
    }

    // Function to transfer ownership to a new address
    function transferOwnership(address _newCeoAddress) public onlyCEO {
        require(_newCeoAddress != address(0), "New CEO address cannot be zero");
        newCeoAddress = _newCeoAddress;
    }

    function hatchEggs(address ref) public {
        require(initialized);
        if(ref == msg.sender) {
            ref = 0;
        }
        if(referrals[msg.sender]==0 && referrals[msg.sender]!=msg.sender) {
            referrals[msg.sender]=ref;
        }
        uint256 eggsUsed=getMyEggs();
        uint256 newMiners=SafeMath.div(eggsUsed,EGGS_TO_HATCH_1MINERS);
        hatcheryMiners[msg.sender]=SafeMath.add(hatcheryMiners[msg.sender],newMiners);
        claimedEggs[msg.sender]=0;
        lastHatch[msg.sender]=now;
        
        //send referral eggs
        claimedEggs[referrals[msg.sender]]=SafeMath.add(claimedEggs[referrals[msg.sender]],SafeMath.div(eggsUsed,7));
        
        //boost market to nerf miners hoarding
        marketEggs=SafeMath.add(marketEggs,SafeMath.div(eggsUsed,5));
    }
    function sellEggs() public {
        require(initialized);
        uint256 hasEggs=getMyEggs();
        uint256 eggValue=calculateEggSell(hasEggs);
        uint256 fee=devFee(eggValue);
        uint256 fee2=fee/2;
        claimedEggs[msg.sender]=0;
        lastHatch[msg.sender]=now;
        marketEggs=SafeMath.add(marketEggs,hasEggs);
        BEP20(SHI20).transfer(ceoAddress, fee2);
        BEP20(SHI20).transfer(newCeoAddress, fee-fee2);
        BEP20(SHI20).transfer(address(msg.sender), SafeMath.sub(eggValue,fee));
    }
    function buyEggs(address ref, uint256 amount) public {
        require(initialized);
    
        BEP20(SHI20).transferFrom(address(msg.sender), address(this), amount);
        
        uint256 balance = BEP20(SHI20).balanceOf(address(this));
        uint256 eggsBought=calculateEggBuy(amount,SafeMath.sub(balance,amount));
        eggsBought=SafeMath.sub(eggsBought,devFee(eggsBought));
        uint256 fee=devFee(amount);
        uint256 fee2=fee/2;
        BEP20(SHI20).transfer(ceoAddress, fee2);
        BEP20(SHI20).transfer(newCeoAddress, fee-fee2);
        claimedEggs[msg.sender]=SafeMath.add(claimedEggs[msg.sender],eggsBought);
        hatchEggs(ref);
    }
    //magic trade balancing algorithm
    function calculateTrade(uint256 rt,uint256 rs, uint256 bs) public view returns(uint256) {
        //(PSN*bs)/(PSNH+((PSN*rs+PSNH*rt)/rt));
        return SafeMath.div(SafeMath.mul(PSN,bs),SafeMath.add(PSNH,SafeMath.div(SafeMath.add(SafeMath.mul(PSN,rs),SafeMath.mul(PSNH,rt)),rt)));
    }
    function calculateEggSell(uint256 eggs) public view returns(uint256) {
        return calculateTrade(eggs,marketEggs,BEP20(SHI20).balanceOf(address(this)));
    }
    function calculateEggBuy(uint256 bnb,uint256 contractBalance) public view returns(uint256) {
        return calculateTrade(bnb,contractBalance,marketEggs);
    }
    function calculateEggBuySimple(uint256 bnb) public view returns(uint256){
        return calculateEggBuy(bnb,BEP20(SHI20).balanceOf(address(this)));
    }
    function devFee(uint256 amount) public pure returns(uint256){
        return SafeMath.div(SafeMath.mul(amount,7),100);
    }

    function seedMarket(uint256 amount) public {
            BEP20(SHI20).transferFrom(address(msg.sender), address(this), amount);
            require(marketEggs == 0); // Ensure the market is not already seeded
            initialized = true; // Mark the contract as initialized
            marketEggs = 550000; // Set the initial value of marketEggs
    }
    function getBalance() public view returns(uint256) {
        return BEP20(SHI20).balanceOf(address(this));
    }
    function getMyMiners() public view returns(uint256) {
        return hatcheryMiners[msg.sender];
    }
    function getMyEggs() public view returns(uint256) {
        return SafeMath.add(claimedEggs[msg.sender],getEggsSinceLastHatch(msg.sender));
    }
    function getEggsSinceLastHatch(address adr) public view returns(uint256) {
        uint256 secondsPassed=min(EGGS_TO_HATCH_1MINERS,SafeMath.sub(now,lastHatch[adr]));
        return SafeMath.mul(secondsPassed,hatcheryMiners[adr]);
    }
    function min(uint256 a, uint256 b) private pure returns (uint256) {
        return a < b ? a : b;
    }
}

library SafeMath {

  /**
  * @dev Multiplies two numbers, throws on overflow.
  */
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
    return c;
  }

  /**
  * @dev Integer division of two numbers, truncating the quotient.
  */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  /**
  * @dev Substracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  /**
  * @dev Adds two numbers, throws on overflow.
  */
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}