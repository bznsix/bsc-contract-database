pragma solidity ^0.8.0;

interface ERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract CrossChain_BNB{


 uint256 idProvider;
 address fundHolder; 
 address owner;
 address validator;
 bool  isPaused;
 ERC20 public BnbHlper;

 struct userRecord{

    uint256 Id;
    uint256 amountSwap;
    uint256 timeOfSwap;
    bool isLastTimeSwap;
    
 }
 modifier onlyOwner() {
    require(msg.sender == owner);
    _; 
 }
  modifier onlyValidatior() {
    require(msg.sender == validator);
    _; 
 }


 mapping(address => bool) public isAnotherSideSwapCompleted;
 mapping(address  => userRecord) public  user;
 event DepoitBnbHlper(uint256 id , uint256 time , address indexed userAddr,  uint256 amount );
 
 constructor(address _owner, address _validator){

    owner  =_owner;
    validator = _validator;
    isPaused = true;        
    BnbHlper= ERC20(0x501Cb2Cd15198A4853bF8944b04c2053410A912B);   //  binance  helper  address add here
    fundHolder = 0x80755DBc7Ab389cC7c01E8D8536EBC773089f8f4;  // wallet address //   to store fund
    idProvider++;

 }


  function swapToken(uint256 amt ) public {
    require(isPaused ==  true,"Comtract Is Stoped");
    require(amt > 0,"Invalid Amount");
    require(BnbHlper.allowance(msg.sender,address(this)) >= amt, "Allowance not enough");
    if(user[msg.sender].isLastTimeSwap == true ){
        require(isAnotherSideSwapCompleted[msg.sender] == true ,"last transanction is In Pending of WHLPR , to user Wallet");
    }
    if(user[msg.sender].Id == 0){
        user[msg.sender].Id = idProvider;
    }
    idProvider++;
    user[msg.sender].amountSwap =amt; 
    user[msg.sender].timeOfSwap =block.timestamp; 
    BnbHlper.transferFrom(msg.sender,fundHolder,amt);
    user[msg.sender].isLastTimeSwap = true; 
    emit DepoitBnbHlper( user[msg.sender].Id , block.timestamp , msg.sender, amt );

  }

  function stopContract(bool status) public onlyOwner{
    isPaused = status;
  }
  
  function setUserLastWithrwalStatus(address userAddr , bool status) public {
        isAnotherSideSwapCompleted[userAddr] = status; 
  } 

  function changeTokenAdress(address token)public onlyOwner {
         BnbHlper = ERC20(token);
  } 
  
 
}