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


        Erc20Token constant internal _USDTIns = Erc20Token(0xA469aBe4Fb1a748f4D3B5e68C79b488685d36C01); 
        Erc20Token constant internal _LRIns = Erc20Token(0x18574784a47cA034fdc146C57Ae13D86AB1Ad4C3); 

        address  _owner;
        address  _operator;

   
        
        modifier onlyOwner() {
            require(msg.sender == _owner, "Permission denied"); _;
        }
     

  
        function transferOwnership(address newOwner) public onlyOwner {
            require(newOwner != address(0));
            _owner = newOwner;
        }

 
        receive() external payable {}  
}



 

contract DataPlayer is Base{
       using SafeMath for uint;
      

    struct Player{
            uint256 id; 
            address addr; 
            address superior; 
        
    }
    mapping(address => mapping(uint256 => uint256)) public PlayerPackage; 


    mapping(uint256 => uint256)  public PackagePrice;


    mapping(address => bool)  public isNode;






    uint256 public LimitJ = 20; 
    uint256 public LimitY = 40; 
    uint256 public LimitT = 100; 
    uint256 public PlayerCount; 

 
 
    mapping(address => Player) public _player; 


    address public ProjectPartyWallet = 0xE685af29b4352c2658C50CE4d49B02F006eAb148; 
    address public LP = 0xE685af29b4352c2658C50CE4d49B02F006eAb148; 
 
 
 
  

 
}




 
contract RUNPackage is DataPlayer {
    using SafeMath for uint;

    mapping(address => uint256) public _RunAddrMap; 
    mapping(uint256 => uint256) public Price;
    constructor()
     {
        _owner = msg.sender; 
        _operator = msg.sender; 
        Price[1] = 10000e18;
        Price[2] = 5000e18;
        Price[3] = 1500e18;
    }


      function setPrice(uint256 price,uint256 PackageType  ) public onlyOwner  { 
        Price[PackageType] = price;
    }

    function setaddress(address addr ) public onlyOwner  { 
        ProjectPartyWallet = addr;
    }

  function setLP(address addr ) public onlyOwner  { 
        LP = addr;
    }

  function  PlayeRegistry(  address superior) external {
        uint256 id = _RunAddrMap[msg.sender];
        if (id == 0) {
            PlayerCount++;
            _RunAddrMap[msg.sender] = PlayerCount;
            _player[msg.sender].id  = PlayerCount;
            _player[msg.sender].addr = msg.sender;
            id = _RunAddrMap[superior];
            if (id > 0 && superior != msg.sender) {
                _player[msg.sender].superior = superior;
             }
        }
    }


 
// 购买套餐
    function BUYnode(uint256 PackageType ,address superior ) public{

         
        require(!isNode[msg.sender], "isNode");

        if(PackageType == 1){
            require(LimitJ > 0, "Package sell out");  
            LimitJ = LimitJ.sub(1);
        }else if(PackageType == 2){
            require(LimitY > 0, "Package sell out");  
            LimitY = LimitY.sub(1);
        }else if(PackageType == 3){
            require(LimitT > 0, "Package sell out");  
            LimitT = LimitT.sub(1);
        }
        uint256  TU = Price[PackageType].div(20);
        _USDTIns.transferFrom(msg.sender, superior,TU);
        _USDTIns.transferFrom(msg.sender, ProjectPartyWallet,Price[PackageType].sub(TU));
        isNode[msg.sender] = true;
    }



    function Withdraw(uint256 balance ,address Player ) public  onlyOwner{
        _LRIns.transferFrom(ProjectPartyWallet, Player,balance);
    }



    function get_Price() public view returns(uint256) {

        uint256 usdtBalance = _USDTIns.balanceOf(address(LP));
        uint256 SpireBalance = _LRIns.balanceOf(address(LP));
        if(usdtBalance == 0){
             return  0;
        }else{
            return  SpireBalance.mul(10000000).div(usdtBalance);
        }
    }


    function get_l( ) public view returns(uint256) {
         uint256 OutAddressBalance = _LRIns.balanceOf(ProjectPartyWallet);
         uint256 AllBalance = _LRIns.totalSupply();
        return  (AllBalance -  OutAddressBalance );

    }

    function get_NodePrice() public view  returns(uint256,uint256,uint256) { 
        return (Price[1],Price[2],Price[3]);
    }


     function get_ISNode(address Player) public view  returns(bool) { 
        return isNode[Player];
    }


    function get_dEaDAddressBalance( ) public view returns(uint256) {
        uint256 dEaDAddressBalance = _LRIns.balanceOf(address(0x000000000000000000000000000000000000dEaD));
        return dEaDAddressBalance;
    }

    function WithdrawFZ(uint256 balance) public {
  
    }


}