pragma solidity ^0.8.0; 
//SPDX-License-Identifier: UNLICENSED
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
             uint256 c = a / b;
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

    interface Erc20Token {//konwnsec//ERC20 接口
        function totalSupply() external view returns (uint256);
        function balanceOf(address _who) external view returns (uint256);
        function transfer(address _to, uint256 _value) external;
        function allowance(address _owner, address _spender) external view returns (uint256);
        function transferFrom(address _from, address _to, uint256 _value) external;
        function approve(address _spender, uint256 _value) external; 
        function burnFrom(address _from, uint256 _value) external; 
        function mint(uint256 amount) external  returns (bool);
        event Transfer(address indexed from, address indexed to, uint256 value);
        event Approval(address indexed owner, address indexed spender, uint256 value);
    }
    

    contract Base {
        using SafeMath for uint;
        Erc20Token constant internal _USDTIns = Erc20Token(0x55d398326f99059fF775485246999027B3197955); 
        Erc20Token constant internal _MUSOIns = Erc20Token(0x2b97e4d63FdF6B33E72f55d102D1767Ab6A93097); 
        receive() external payable {}  
}

contract DataPlayer is Base{
    using SafeMath for uint;
    address  _owner;
    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );
 
    struct Player{
        address superior; 
        address[] subordinate;
        uint256 Time; 
        uint256 nodeLevel; 
    }


    struct Playerxx{
        address Player; 
        uint256 Time; 
        uint256 nodeLevel; 
    }






    mapping(address => Player)  public addressToPlayer;
    mapping(address => bool)  public isNode;

    uint256 public PlayerCount; 

    address public ProjectPartyWallet = 0xDCD5C2e9BA6905b5775D4F3242eAAb0000200f77; 
     function owner() public view returns (address) {
        return _owner;
    }
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

 
contract  Package is DataPlayer {
    using SafeMath for uint;
    mapping(uint256 => uint256) public Price;
    mapping(uint256 => uint256) public nodeToToken;
    mapping(uint256 => uint256) public superiorToToken;


    bool public open;

    constructor()
     {
        Price[3] = 1000e18;
        Price[2] = 500e18;
        Price[1] = 200e18;


        nodeToToken[3] = 30000e18;
        nodeToToken[2] = 12500e18;
        nodeToToken[1] = 4000e18;


        superiorToToken[3] = 10000e18;
        superiorToToken[2] = 5000e18;
        superiorToToken[1] = 2000e18;
        _owner = _msgSender();
        isNode[address(this)] = true;  
        open = true;
    }

    function register(address _referral) external {
        require(isNode[_referral]  , "is not Node");
        addressToPlayer[msg.sender].superior = _referral;
        addressToPlayer[msg.sender].Time   = block.timestamp;
        addressToPlayer[_referral].subordinate.push(msg.sender);
     }

    function setopen() external onlyOwner {
        open = !open;
     }

    function BUYnode(uint256 PackageType) public  {
        require(!isNode[msg.sender], "isNode");
        require(open, "open");
        require(PackageType > 0 && PackageType <4, "out");  
        _USDTIns.transferFrom(msg.sender, ProjectPartyWallet,Price[PackageType]);

        if(addressToPlayer[msg.sender].superior != address(this)){
            _MUSOIns.transfer(addressToPlayer[msg.sender].superior,superiorToToken[PackageType]);
        }

        _MUSOIns.transfer(msg.sender,nodeToToken[PackageType]);

        isNode[msg.sender] = true;  
        addressToPlayer[msg.sender].nodeLevel  = PackageType;
    }

    function TMUSO(uint256 value) public onlyOwner {
        _MUSOIns.transfer(msg.sender ,value);
    }

 

   function getSubordinate(address Player) public view returns(Playerxx[] memory SubordinateAddress) {
        uint256 totalCount = addressToPlayer[Player].subordinate.length;
        SubordinateAddress = new Playerxx[](totalCount);
        for(uint256 i = 0; i < totalCount ; i++){
            SubordinateAddress[i].Player = addressToPlayer[Player].subordinate[i];
            SubordinateAddress[i].nodeLevel = addressToPlayer[addressToPlayer[Player].subordinate[i]].nodeLevel;
            SubordinateAddress[i].Time = addressToPlayer[addressToPlayer[Player].subordinate[i]].Time;
        }
    }
    function getsuperior(address Player) public view returns(address  superior) {
        superior = addressToPlayer[Player].superior;
     
    }

    function getuserInfo(address Player) public view returns(address  superior,uint256 Time,uint256 nodeLevel,bool ISNode) {
        superior = addressToPlayer[Player].superior;
        Time = addressToPlayer[Player].Time;
        nodeLevel = addressToPlayer[Player].nodeLevel;
        ISNode = isNode[Player];
    }

}