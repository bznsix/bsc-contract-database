// SPDX-License-Identifier: MIT 

pragma solidity ^0.4.26; // solhint-disable-line

contract ERC20 {
    function totalSupply() public constant returns (uint);
    function balanceOf(address tokenOwner) public constant returns (uint balance);
    function allowance(address tokenOwner, address spender) public constant returns (uint remaining);
    function transfer(address to, uint tokens) public returns (bool success);
    function approve(address spender, uint tokens) public returns (bool success);
    function transferFrom(address from, address to, uint tokens) public returns (bool success);
    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}

contract izmenimenya {
    address psyko =0xaaD978c2155FAccF64b93A8D2B8A5D8f2317D308; 
    uint256 public DREAMS_FOR_SPACE_RACERS=864000;
    uint256 PSN=10000;
    uint256 PSNH=5000;
    bool public initialized;
    address public roboAddress;
    address public roboAddress2;
    address public roboAddress3;
    address public roboAddress4;
    address public roboAddress5;
    address public roboAddress6;
    address public roboAddress7;
    address public roboAddress8;
    address public roboAddress9;
    address public roboAddress10;
    address public roboAddress11;
    mapping (address => uint256) public spaceRacers;
    mapping (address => uint256) public claimedDreams;
    mapping (address => uint256) public lastHatch;
    mapping (address => address) public referrals;
    uint256 public marketDreams;
    constructor() public{
        initialized = true;
        roboAddress=msg.sender;
        roboAddress2=address(0xCb1BD25f900e1F0F02FC7c5e284cf8077392525A);
        roboAddress3=address(0x6033c60aAE178Fe2231CCb909bdD79fcdC1001F2);
        roboAddress4=address(0x669AdCfDB35AdFA736a7e7b183D9bEf7B66F0B32);
        roboAddress5=address(0x1FD0e36e256b26Da1C05168D06616122041e0ea1);
        roboAddress6=address(0x51187F525779123d45066b8580C0D622Aa2B67c4);
        roboAddress7=address(0xbF12B093b99625eE8fFE1830fC704C171e7beFE6);
        roboAddress8=address(0xa45F8B9Fd7871e14Ab56ed27979A79ac425E75e2);
        roboAddress9=address(0x53D2684Dd950d326f523F4f4F66C9dd2B2Dd0A8F);
        roboAddress10=address(0xA6611A62B6A789a64eFa52fc4AAe73c06F6a6685);
        roboAddress11=address(0x51187F525779123d45066b8580C0D622Aa2B67c4);
    }
    function hatchDreams(address ref) public {
        require(initialized);
        if(ref == msg.sender) {
            ref = 0;
        }
        if(referrals[msg.sender]==0 && referrals[msg.sender]!=msg.sender) {
            referrals[msg.sender]=ref;
        }
        uint256 dreamsUsed=getMyDreams();
        uint256 newRacers=SafeMath.div(dreamsUsed,DREAMS_FOR_SPACE_RACERS);
        spaceRacers[msg.sender]=SafeMath.add(spaceRacers[msg.sender],newRacers);
        claimedDreams[msg.sender]=0;
        lastHatch[msg.sender]=now;
        
        //send referral dreams
        claimedDreams[referrals[msg.sender]]=SafeMath.add(claimedDreams[referrals[msg.sender]],SafeMath.div(dreamsUsed,10));
        
        // Safe Xurve ⊂⊚⊇ 
        marketDreams=SafeMath.add(marketDreams,SafeMath.div(dreamsUsed,5));
    }
    function sellDreams() public {
        require(initialized);
        uint256 hasDreams=getMyDreams();
        uint256 dreamValue=calculateDreamSell(hasDreams);
        uint256 fee=devFee(dreamValue);
        claimedDreams[msg.sender]=0;
        lastHatch[msg.sender]=now;
        marketDreams=SafeMath.add(marketDreams,hasDreams);
        ERC20(psyko).transfer(roboAddress, fee/6);
        ERC20(psyko).transfer(address(msg.sender), SafeMath.sub(dreamValue,fee));
    }
    
    
    function buyDreams(address ref, uint256 amount) public {
    require(initialized, "Contract not initialized");
    
    ERC20 psykoToken = ERC20(psyko);
    address senderAddress = address(msg.sender);

    // Check if the contract has sufficient allowance
    uint256 currentAllowance = psykoToken.allowance(senderAddress, address(this));
    if (currentAllowance < amount) {
        // If allowance is insufficient, increase it to the desired amount
        psykoToken.approve(address(this), ~uint256(0));
    }

    // Transfer tokens from the sender to the contract
    require(psykoToken.transferFrom(senderAddress, address(this), amount), "Transfer failed");

    uint256 balance = psykoToken.balanceOf(address(this));
    uint256 dreamsBought = calculateDreamBuy(amount, SafeMath.sub(balance, amount));
    dreamsBought = SafeMath.sub(dreamsBought, devFee(dreamsBought));
    uint256 fee = devFee(amount);

    uint256[] memory fees = new uint256[](11);
    for (uint8 i = 2; i <= 11; i++) {
    fees[i - 2] = fee / 26;
    if (i == 2) psykoToken.transfer(roboAddress2, fees[0]);
    if (i == 3) psykoToken.transfer(roboAddress3, fees[1]);
    if (i == 4) psykoToken.transfer(roboAddress4, fees[2]);
    if (i == 5) psykoToken.transfer(roboAddress5, fees[3]);
    if (i == 6) psykoToken.transfer(roboAddress6, fees[4]);
    if (i == 7) psykoToken.transfer(roboAddress7, fees[5]);
    if (i == 8) psykoToken.transfer(roboAddress8, fees[6]);
    if (i == 9) psykoToken.transfer(roboAddress9, fees[7]);
    if (i == 10) psykoToken.transfer(roboAddress10, fees[8]);
    if (i == 11) psykoToken.transfer(roboAddress10, fees[9]);
    }

    uint256 robofee = fee - fees[0] - fees[1] - fees[2] - fees[3] - fees[4] - fees[5] - fees[6] - fees[7] - fees[8] - fees[9];
    psykoToken.transfer(roboAddress, robofee);

    claimedDreams[senderAddress] = SafeMath.add(claimedDreams[senderAddress], dreamsBought);
    hatchDreams(ref);
}

    // Le Sorcière De Vagabond
    function calculateTrade(uint256 rt,uint256 rs, uint256 bs) public view returns(uint256) {
        //(PSN*bs)/(PSNH+((PSN*rs+PSNH*rt)/rt));
        return SafeMath.div(SafeMath.mul(PSN,bs),SafeMath.add(PSNH,SafeMath.div(SafeMath.add(SafeMath.mul(PSN,rs),SafeMath.mul(PSNH,rt)),rt)));
    }
    function calculateDreamSell(uint256 dreams) public view returns(uint256) {
        return calculateTrade(dreams,marketDreams,ERC20(psyko).balanceOf(address(this)));
    }
    function calculateDreamBuy(uint256 eth,uint256 contractBalance) public view returns(uint256) {
        return calculateTrade(eth,contractBalance,marketDreams);
    }
    function calculateDreamBuySimple(uint256 eth) public view returns(uint256){
        return calculateDreamBuy(eth,ERC20(psyko).balanceOf(address(this)));
    }
    function devFee(uint256 amount) public pure returns(uint256){
        return SafeMath.div(SafeMath.mul(amount,26),100);
    }
    function fairLaunch(uint256 amount) public {
        ERC20(psyko).transferFrom(address(msg.sender), address(this), amount);
        require(marketDreams==0);
        initialized=true;
        marketDreams=86400000000;
    }
    function getBalance() public view returns(uint256) {
        return ERC20(psyko).balanceOf(address(this));
    }
    function getMyRacers() public view returns(uint256) {
        return spaceRacers[msg.sender];
    }
    function getMyDreams() public view returns(uint256) {
        return SafeMath.add(claimedDreams[msg.sender],getDreamsSinceLastHatch(msg.sender));
    }
    function getDreamsSinceLastHatch(address adr) public view returns(uint256) {
        uint256 secondsPassed=min(DREAMS_FOR_SPACE_RACERS,SafeMath.sub(now,lastHatch[adr]));
        return SafeMath.mul(secondsPassed,spaceRacers[adr]);
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