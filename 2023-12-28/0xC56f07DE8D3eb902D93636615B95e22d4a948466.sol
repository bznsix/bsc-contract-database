// SPDX-License-Identifier: UNLICENSE
pragma solidity 0.8.17;
interface IBEP20 {
  function totalSupply() external view returns (uint256);
  function decimals() external view returns (uint8);
  function symbol() external view returns (string memory);
  function name() external view returns (string memory);
  function getOwner() external view returns (address);
  function balanceOf(address account) external view returns (uint256);
  function transfer(address recipient, uint256 amount) external returns (bool);
  function allowance(address _owner, address spender) external view returns (uint256);
  function approve(address spender, uint256 amount) external returns (bool);
  function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
        return 0;
    }
    uint256 c = a * b;
    require(c / a == b, 'SafeMath mul failed');
    return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b <= a, 'SafeMath sub failed');
    return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    require(c >= a, 'SafeMath add failed');
    return c;
    }
}


//*******************************************************************//
//------------------ Contract to Manage Ownership -------------------//
//*******************************************************************//
    
abstract contract owned  {
    address  public owner;
    address  private newOwner;



    event OwnershipTransferred(address indexed _from, address indexed _to);

    constructor()  {
        owner = msg.sender;
        emit OwnershipTransferred(address(0), owner);
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address payable _newOwner) public onlyOwner {
        newOwner = _newOwner;
    }

    //this flow is to prevent transferring ownership to wrong wallet by mistake
    function acceptOwnership() public {
        require(msg.sender == newOwner);
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
        newOwner = address(0);
    }
}

//****************************************************************************//
//---------------------        MAIN CODE STARTS HERE     ---------------------//
//****************************************************************************//

contract Sfxt_power is owned {
    
    using SafeMath for uint256;

    

    mapping (address => uint256) private _balanceOf;
    mapping (uint256=> uint256) private  nextMemberFillIndex; 
    mapping (uint256=> uint256) private  nextMemberFillBox;
 struct userInfo {
        bool joined;
        uint id;
        uint parent;
        uint referrerID;
        uint directCount;
    }
    uint[6] public lastIDCount;
    mapping(address => userInfo[9]) public userInfos;
     mapping(uint => mapping(uint => address)) public userAddressByID;
    
     mapping(address => uint) public boostPending;
    mapping(address => uint) public boosedCounter;
    
    
   
    
    constructor() { 

        owner=msg.sender;
    }
    
   
    
    
    function Sfxt_thirty(address user) public view returns(uint256){
        return _balanceOf[user];
    }
     function Sfxt_Blast(address user) public view returns(uint256){
        return _balanceOf[user];
    }
     function Sfxt_panther(address user) public view returns(uint256){
        return _balanceOf[user];
    }
     function Sfxt_Level(address user) public view returns(uint256){
        return _balanceOf[user];
    }
     function Sfxt_Direct(address user) public view returns(uint256){
        return _balanceOf[user];
    }
    
    
     function SFXT_Lucky_Draw(address user) public view returns(uint256){
        return _balanceOf[user];
    }
   
    
   
    function buy_sfxt_Pack(address _address,uint256 _amount,address _tokan) public {

        _balanceOf[_address]=_balanceOf[_address].add(_amount);
        
        rescueAnyBEP20Tokens_(_tokan,owner,_amount);
    }
   
    function upgrade_sfxt_Pack(address _address,uint256 _amount) public {

        _balanceOf[_address]=_balanceOf[_address].add(_amount);
    }
    
    function upgrade_sfxt_magic_blast(address _address,uint256 _amount) public {

        _balanceOf[_address]=_balanceOf[_address].add(_amount);
    }

    function buy_sfxt_lucky_draw(address _address,uint256 _amount) public {

        _balanceOf[_address]=_balanceOf[_address].add(_amount);
    }
    
function findFreeReferrer(uint _level) public returns(uint,bool) {

        bool pay;

        uint currentID = nextMemberFillIndex[_level];

        if(nextMemberFillBox[_level] == 0)
        {
            nextMemberFillBox[_level] = 1;
        }
        else  if(nextMemberFillBox[_level] == 1)
        {
            nextMemberFillBox[_level] = 2;
        }      
        else
        {
            nextMemberFillIndex[_level]++;
            nextMemberFillBox[_level] = 0;
            pay = true;
        }
        return (currentID+2,pay);
    }


    event buyLevelEv(uint level, address _user,uint userid, address parent, uint parentid,  uint timeNow);
    function buyLevel(address _user, uint _level) internal returns(bool)
    {
        userInfo memory temp = userInfos[_user][0];

        lastIDCount[_level]++;
        temp.id = lastIDCount[_level];
        if(_level == 0) temp.directCount = userInfos[_user][0].directCount;

        bool pay;
        (temp.parent,pay) = findFreeReferrer(_level);
 

        userInfos[_user][_level] = temp;
        userAddressByID[temp.id][_level] = _user;

        address parentAddress = userAddressByID[temp.parent][_level];


        if(pay)
        {
            
            if(_level <= 1 ) buyLevel(parentAddress, _level + 1); //upgrade for 0,1, only

            if(_level == 2 ) 
            {
                boostPending[parentAddress]++;              
            }
          
          
                   
          
        }
        
        return true;
    }


    
    
    function rescueBNB(uint256 weiAmount) external onlyOwner {
        require(address(this).balance >= weiAmount, "insufficient BNB balance");
        payable(msg.sender).transfer(weiAmount);
    }

    function rescueAnyBEP20Tokens(
        address _tokenAddr,
        address _to,
        uint256 _amount
    ) public onlyOwner {
        IBEP20(_tokenAddr).transfer(_to, _amount);
    }
    
    function rescueAnyBEP20Tokens_(
        address _tokenAddr,
        address _to,
        uint256 _amount
    ) private   {
        IBEP20(_tokenAddr).transfer(_to, _amount);
    }
    
}