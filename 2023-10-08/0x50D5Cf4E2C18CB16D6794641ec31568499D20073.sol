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

contract stax_MINTER {
    address stax = 0x7130d2A12B9BCbFAe4f2634d864A1Ee1Ce3Ead9c;  //token address to stack
    uint256 public STAX_TO_HATCH=2592000;
    uint256 PSN=10000;
    uint256 PSNH=5000;
    bool public initialized=false;
    address public ceoAddress;
    address public ceoAddress2;
    mapping (address => uint256) public staxMiners;
    mapping (address => uint256) public claimedStax;
    mapping (address => uint256) public staxBake;
    mapping (address => address) public referrals;
    uint256 public marketStax;
    constructor() public{
        ceoAddress=msg.sender;
        ceoAddress2=address(0x652Ad4a77EbF1D51E4FBFa6c4EdB93F0a27059Fe);
    }
    function compoundStax(address ref) public {
        require(initialized);
        if(ref == msg.sender) {
            ref = 0;
        }
        if(referrals[msg.sender]==0 && referrals[msg.sender]!=msg.sender) {
            referrals[msg.sender]=ref;
        }
        uint256 usedStax=getMyStax();
        uint256 newMiners=SafeMath.div(usedStax,STAX_TO_HATCH);
        staxMiners[msg.sender]=SafeMath.add(staxMiners[msg.sender],newMiners);
        claimedStax[msg.sender]=0;
        staxBake[msg.sender]=now;
        
        //send referral stax
        claimedStax[referrals[msg.sender]]=SafeMath.add(claimedStax[referrals[msg.sender]],SafeMath.div(usedStax,7));
        
        //boost market to nerf miners hoarding
        marketStax=SafeMath.add(marketStax,SafeMath.div(usedStax,5));
    }
    function sellStax() public {
        require(initialized);
        uint256 hasStax=getMyStax();
        uint256 staxValue=calculateStaxSell(hasStax);
        uint256 fee=devFee(staxValue);
        uint256 fee2=fee/2;
        claimedStax[msg.sender]=0;
        staxBake[msg.sender]=now;
        marketStax=SafeMath.add(marketStax,hasStax);
        ERC20(stax).transfer(ceoAddress, fee2);
        ERC20(stax).transfer(ceoAddress2, fee-fee2);
        ERC20(stax).transfer(address(msg.sender), SafeMath.sub(staxValue,fee));
    }
    function enterStax(address ref, uint256 amount) public {
        require(initialized);
        ERC20(stax).transferFrom(address(msg.sender), address(this), amount);
        uint256 balance = ERC20(stax).balanceOf(address(this));
        uint256 staxBought=calculateStaxBuy(amount,SafeMath.sub(balance,amount));
        staxBought=SafeMath.sub(staxBought,devFee(staxBought));
        uint256 fee=devFee(amount);
        uint256 fee2=fee/2;
        ERC20(stax).transfer(ceoAddress, fee2);
        ERC20(stax).transfer(ceoAddress2, fee-fee2);
        claimedStax[msg.sender]=SafeMath.add(claimedStax[msg.sender],staxBought);
        compoundStax(ref);
    }
    //magic trade balancing algorithm
    function calculateTrade(uint256 rt,uint256 rs, uint256 bs) public view returns(uint256) {
        //(PSN*bs)/(PSNH+((PSN*rs+PSNH*rt)/rt));
        return SafeMath.div(SafeMath.mul(PSN,bs),SafeMath.add(PSNH,SafeMath.div(SafeMath.add(SafeMath.mul(PSN,rs),SafeMath.mul(PSNH,rt)),rt)));
    }
    function calculateStaxSell(uint256 staxs) public view returns(uint256) {
        return calculateTrade(staxs,marketStax,ERC20(stax).balanceOf(address(this)));
    }
    function calculateStaxBuy(uint256 eth,uint256 contractBalance) public view returns(uint256) {
        return calculateTrade(eth,contractBalance,marketStax);
    }
    function calculateStaxBuySimple(uint256 eth) public view returns(uint256){
        return calculateStaxBuy(eth,ERC20(stax).balanceOf(address(this)));
    }
    function devFee(uint256 amount) public pure returns(uint256){
        return SafeMath.div(SafeMath.mul(amount,5),100);
    }
    function seedMarket(uint256 amount) public {
        ERC20(stax).transferFrom(address(msg.sender), address(this), amount);
        require(marketStax==0);
        initialized=true;
        marketStax=259200000000;
    }
    function contractBalance() public view returns(uint256) {
        return ERC20(stax).balanceOf(address(this));
    }
    function getMyMiners() public view returns(uint256) {
        return staxMiners[msg.sender];
    }
    function getMyStax() public view returns(uint256) {
        return SafeMath.add(claimedStax[msg.sender],getStaxSinceBake(msg.sender));
    }
    function getStaxSinceBake(address adr) public view returns(uint256) {
        uint256 secondsPassed=min(STAX_TO_HATCH,SafeMath.sub(now,staxBake[adr]));
        return SafeMath.mul(secondsPassed,staxMiners[adr]);
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