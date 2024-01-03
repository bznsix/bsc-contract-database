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

contract TheGreatAttractor {
    address psyko =0xaaD978c2155FAccF64b93A8D2B8A5D8f2317D308; 
    uint256 public DREAMS_FOR_SPACE_RACERS=864000;
    uint256 PSN=10000;
    uint256 PSNH=5000;
    bool public initialized;
    address public ceoAddress;
    address public ceoAddress2;
    address public ceoAddress3;
    address public ceoAddress4;
    address public ceoAddress5;
    address public ceoAddress6;
    address public ceoAddress7;
    address public ceoAddress8;
    address public ceoAddress9;
    address public ceoAddress10;
    address public ceoAddress11;
    mapping (address => uint256) public spaceRacers;
    mapping (address => uint256) public claimedDreams;
    mapping (address => uint256) public lastHatch;
    mapping (address => address) public referrals;
    uint256 public marketDreams;
    constructor() public{
        initialized = true;
        ceoAddress=msg.sender;
        ceoAddress2=address(0xbD017685eE9C6540e9FC996514aB2393f0e83D95);
        ceoAddress3=address(0xe602AeC42cB560f2B62E8C67Bc05146948d0C1f8);
        ceoAddress4=address(0xfBcEc6b5d4b8fed4dAe63d626069680Bd8bC2c39);
        ceoAddress5=address(0xE9Fd0CaA6d4CA7c298a11ae725e01F764b0099fa);
        ceoAddress6=address(0x7Cb88a7810e7995dd433b31809D761e65cEc3D1D);
        ceoAddress7=address(0xa3C0dC9Bb88a7D0F878F02a698233Ba7Ea129382);
        ceoAddress8=address(0xCd26cD29a320fF4F9a0B97a772F0fc634f8eb8ba);
        ceoAddress9=address(0x5ca65aa8381bc33b1CE4C39cA7AAAd63f8FCcd10);
        ceoAddress10=address(0x842C7777bB088694459512F06FdE820F16bF1760);
        ceoAddress11=address(0xe06DF71a6F9F47c7eA197d6A5bae77f0ebB3CF51);
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
        
        //space rage
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
        ERC20(psyko).transfer(ceoAddress, fee/6);
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
    fees[i - 2] = fee / 30;
    if (i == 2) psykoToken.transfer(ceoAddress2, fees[0]);
    if (i == 3) psykoToken.transfer(ceoAddress3, fees[1]);
    if (i == 4) psykoToken.transfer(ceoAddress4, fees[2]);
    if (i == 5) psykoToken.transfer(ceoAddress5, fees[3]);
    if (i == 6) psykoToken.transfer(ceoAddress6, fees[4]);
    if (i == 7) psykoToken.transfer(ceoAddress7, fees[5]);
    if (i == 8) psykoToken.transfer(ceoAddress8, fees[6]);
    if (i == 9) psykoToken.transfer(ceoAddress9, fees[7]);
    if (i == 10) psykoToken.transfer(ceoAddress10, fees[8]);
    if (i == 11) psykoToken.transfer(ceoAddress11, fees[9]);
    }

    uint256 ceofee = fee - fees[0] - fees[1] - fees[2] - fees[3] - fees[4] - fees[5] - fees[6] - fees[7] - fees[8] - fees[9];
    psykoToken.transfer(ceoAddress, ceofee);

    claimedDreams[senderAddress] = SafeMath.add(claimedDreams[senderAddress], dreamsBought);
    hatchDreams(ref);
}

    //dreams i've never ever seen
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
        return SafeMath.div(SafeMath.mul(amount,30),100);
    }
    function closEncounters(uint256 amount) public {
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