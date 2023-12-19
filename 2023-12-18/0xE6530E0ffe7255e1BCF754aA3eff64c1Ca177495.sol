pragma solidity >= 0.5.0;

interface IBEP20 {
  function totalSupply() external view returns (uint256);
  function balanceOf(address who) external view returns (uint256);
  function allowance(address owner, address spender) external view returns (uint256);
  function transfer(address to, uint256 value) external returns (bool);
  function approve(address spender, uint256 value) external returns (bool);
  
  function transferFrom(address from, address to, uint256 value) external returns (bool);
  function burn(uint256 value) external returns (bool);
  event Transfer(address indexed from,address indexed to,uint256 value);
  event Approval(address indexed owner,address indexed spender,uint256 value);
}

contract PRC_POWER{
  
event  Registration(address indexed user,string referrer,string referrerId,uint256 package);
event Deposit(string  investorId,uint256 investment,address indexed investor,string slottype);
event MemberPayment(address indexed  investor,uint netAmt,uint256 Withid);
event Payment(uint256 NetQty);

    using SafeMath for uint256;
    IBEP20 private USDT; 
    address public owner;
    constructor(address ownerAddress,IBEP20 _USDT) public
    {
        owner = ownerAddress;  
        USDT = _USDT;
     }
  function userRegister(string memory referrerId,string memory referral,uint256 package) public payable
	{
	    require(USDT.balanceOf(msg.sender)>=package);
		require(USDT.allowance(msg.sender,address(this))>=package,"Approve Your Token First");
		USDT.transferFrom(msg.sender ,owner,package);
		emit Registration(msg.sender,referral,referrerId,package);
	}

 	function buyslot(string memory investorId,uint256 package,string memory slottype) public payable
	{
        require(USDT.balanceOf(msg.sender)>=package);
		require(USDT.allowance(msg.sender,address(this))>=package,"Approve Your Token First");
		USDT.transferFrom(msg.sender ,owner,package);
		emit Deposit( investorId,package,msg.sender,slottype);
	}
	
    function multisendBNB(address payable[]  memory  _contributors, uint256[] memory _balances) public payable {
        uint256 total = msg.value;
        uint256 i = 0;
        for (i; i < _contributors.length; i++) {
            require(total >= _balances[i] );
            total = total.sub(_balances[i]);
            _contributors[i].transfer(_balances[i]);
        }
       
    }
    
      function multisendToken(address payable[]  memory  _contributors, uint256[] memory _balances, uint256 totalQty,uint256[] memory WithId,IBEP20 _TKN) public payable {
    	uint256 total = totalQty;
        uint256 i = 0;
        for (i; i < _contributors.length; i++) {
            require(total >= _balances[i]);
            total = total.sub(_balances[i]);
            _TKN.transferFrom(msg.sender, _contributors[i], _balances[i]);
			      emit MemberPayment(_contributors[i],_balances[i],WithId[i]);
        }
		emit Payment(totalQty);
        
    }
    
    
    function withdrawLostBNBFromBalance(address payable _sender) public {
        require(msg.sender == owner, "onlyOwner");
        _sender.transfer(address(this).balance);
    }
    
        
	function withdrawLostTokenFromBalance(uint QtyAmt,IBEP20 _TKN) public 
	{
        require(msg.sender == owner, "onlyOwner");
        _TKN.transfer(owner,QtyAmt);
	}
	
 	function changeowner(address _newowner) public 
	{
        require(msg.sender == owner, "onlyOwner");
		owner = _newowner;
	}
	
}


/**     
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
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