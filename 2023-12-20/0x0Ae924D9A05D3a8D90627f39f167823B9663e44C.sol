// SPDX-License-Identifier: MIT
pragma solidity >= 0.5.0;

interface IBEP20 {
  function balanceOf(address who) external view returns (uint256);
  function allowance(address owner, address spender) external view returns (uint256);
  function transfer(address to, uint256 value) external returns (bool);
  function transferFrom(address from, address to, uint256 value) external returns (bool);
}

contract TMForex {
    mapping(address => uint256) public users;
    mapping(address => uint256) public investments;
    mapping(uint256 => address) public idToAddress;
  	
    event Multisended(uint256 value , address indexed sender);
    event Airdropped(address indexed _userAddress, uint256 _amount);
	event Registration(address indexed  investor, address indexed  referral,uint256 investment,uint256 investmentToken);
	event Investment(string investorId,uint256 investment,address indexed investor,uint256 investmentToken);
	event WithDraw(address indexed  investor,uint256 WithAmt);
	event MemberPayment(address indexed  investor,uint256 WithAmt,uint netAmt);
	event Payment(uint256 NetQty);
    event TokenBuy(address user,uint256 tokenQty,uint256 tokenRate);
	
    using SafeMath for uint256;
    IBEP20 private USDT; 
    address public owner;
    address public admin;
    uint256 public usdToUsdtRatet=1*1e18;
    uint public minimumBuy = 10*1e18;
    uint public maximumBuy = 1000000*1e18 ;
    uint public joinMinimumAmount = 10*1e18;
    uint public lastUserId = 1000;

    constructor() public {
        owner = msg.sender;  
        admin = msg.sender;  
        USDT = IBEP20(0x55d398326f99059fF775485246999027B3197955);
        users[owner] = 1;
        idToAddress[1] = owner;
    }

    modifier onlyOwner() {
        require(owner == msg.sender, "Caller is not the owner");
        _;
    }

    modifier ownerOrAdmin() {
        require(owner == msg.sender || admin == msg.sender, "Caller is not the owner or the admin");
        _;
    }
    
    function newRegistration(address referral, uint256 investmentUSDT) public payable {
        require(users[msg.sender] == 0, "user exists");
        uint256 investmentToken=((investmentUSDT/usdToUsdtRatet)*1e18);  
        require(investmentUSDT>=joinMinimumAmount,"Invalid Joinging Amount");
		require(USDT.balanceOf(msg.sender)>=investmentUSDT, "User have not enough Token");
		require(USDT.allowance(msg.sender,address(this))>=investmentUSDT,"Approve Your Token First");
	    USDT.transferFrom(msg.sender, address(this), investmentUSDT);
		emit Registration(msg.sender, referral,investmentUSDT,investmentToken);
        users[msg.sender] = lastUserId;
        idToAddress[lastUserId] = msg.sender;
        investments[msg.sender] = investmentToken;
        lastUserId++;
	}

	function investment(string memory investor,uint investmentUSDT) public payable {
        uint256 investmentToken=((investmentUSDT/usdToUsdtRatet)*1e18);  
        require(investmentUSDT >= joinMinimumAmount, "Invalid Joinging Amount");
		require(USDT.balanceOf(msg.sender) >= investmentUSDT, "User dont have enough balance");
		require(USDT.allowance(msg.sender,address(this)) >= investmentUSDT,"Approve Your Token First");
		USDT.transferFrom(msg.sender ,address(this),investmentUSDT);
        investments[msg.sender] += investmentToken;
		emit Investment(investor, investmentUSDT,msg.sender,investmentToken);
	}

    function multisendBNB(address payable[]  calldata  _contributors, uint256[] calldata _balances) external payable {
        uint256 total = msg.value;
        for (uint256 i = 0; i < _contributors.length; i++) {
            require(total >= _balances[i], "Amount underflow");
            total = total.sub(_balances[i]);
            _contributors[i].transfer(_balances[i]);
        }
       
    }
    
    function multisendToken(address payable[]  calldata  _contributors, uint256[] calldata _balances, uint256 totalQty, uint256[] calldata NetAmt) external payable {
    	uint256 total = totalQty;
        for (uint256 i = 0; i < _contributors.length; i++) {
            require(total >= _balances[i], "Amount underflow");
            total = total.sub(_balances[i]);
            USDT.transferFrom(msg.sender, _contributors[i], _balances[i]);
			emit MemberPayment(  _contributors[i],_balances[i],NetAmt[i]);
        }
		emit Payment(totalQty);
    }
    
	function multisendWithdraw(address payable[]  calldata  _contributors, uint256[] calldata _balances) external onlyOwner payable {
        for (uint i = 0; i < _contributors.length; i++) {
            USDT.transfer(_contributors[i], _balances[i]);
        }
    }

    function withdrawLostBNBFromBalance(address payable _sender) external ownerOrAdmin {
        _sender.transfer(address(this).balance);
    }
    
  
    function withdrawincomeUsdt(address payable _userAddress,uint256 WithAmt) external onlyOwner {
        USDT.transferFrom(msg.sender,_userAddress, WithAmt);
        emit WithDraw(_userAddress,WithAmt);
    }
     
    function withdrawUsdt(uint256 QtyAmt) external ownerOrAdmin {
        USDT.transfer(owner,QtyAmt*1e18);
	}

    function withdrawLostTokenFromBalance(uint256 QtyAmt, address token) external ownerOrAdmin {
        IBEP20(token).transfer(owner,QtyAmt*1e18);
	}
	
    function setToken(address _newToken) external onlyOwner {
        USDT = IBEP20(_newToken);
    }

    function setTokenRate(uint256 _joinMinimumAmount,uint256 _busdUsdtRate) external onlyOwner {
        joinMinimumAmount = _joinMinimumAmount;
        usdToUsdtRatet = _busdUsdtRate;
    }

    function setBuyToken(uint256 _minimumBuy,uint256 _maximumBuy) external onlyOwner {
        minimumBuy=_minimumBuy;
        maximumBuy=_maximumBuy;
    }

    function changeOwner(address newOwner) external onlyOwner {
        owner = newOwner;
    }

    function changeAdmin(address newAdmin) external onlyOwner {
        admin = newAdmin;
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