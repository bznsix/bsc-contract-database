pragma solidity 0.5.4;

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


contract Ownable {
   address public owner;
    modifier onlyOwner {
        require(owner == msg.sender, "Not Owner");
        _;
    }
  function transferOwnership(address newOwner) public onlyOwner {
  require(msg.sender != address(0));
    owner = newOwner;
  }
}

interface ITRC20 {
  function totalSupply() external view returns (uint256);
  function balanceOf(address who) external view returns (uint256);
  function allowance(address owner, address spender) external view returns (uint256);
  function transfer(address to, uint256 value) external returns (bool);
  function approve(address spender, uint256 value) external returns (bool);
  
  function transferFrom(address from, address to, uint256 value) external returns (bool);
  function burn(uint256 value) external returns (bool);
  event Transfer(address indexed from,address indexed to,uint256 value);
  event Approval(address indexed owner,address indexed sender,uint256 value);
}

contract MultiSend is Ownable {
    using SafeMath for uint256;

    constructor(address ownerAddress) public {
		owner = ownerAddress;
    }
	
  	function multisend_Token(ITRC20 _Token, address[]  memory  _contributors, uint256[] memory _balances, uint256 totalQty) public  {
    	uint256 total = totalQty;
        uint256 i = 0;
        for (i; i < _contributors.length; i++) {
            require(total >= _balances[i]);
            total = total.sub(_balances[i]);
            _Token.transferFrom(msg.sender, _contributors[i], _balances[i]);
        }
    }
    function multisend_Coin( address[]  memory  _contributors, uint256[] memory _balances, uint256 totalQty) public payable {
        require(totalQty==msg.value);
    	uint256 total = totalQty;
        for (uint i=0; i < _contributors.length; i++) {
            require(total >= _balances[i]);
            total = total.sub(_balances[i]);
            uint balanace = _balances[i];
            address contributer = _contributors[i];
            address(uint160(contributer)).transfer(balanace);
        }

    }
	
}