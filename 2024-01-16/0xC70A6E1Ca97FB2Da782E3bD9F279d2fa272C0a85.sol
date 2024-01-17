// SPDX-License-Identifier: MIT
pragma solidity >=0.6.12 <0.8.23;

interface BEP20 {
    function totalSupply() external view returns (uint);
    function balanceOf(address tokenOwner) external view returns (uint balance);
    function allowance(address tokenOwner, address spender) external view returns (uint remaining);
    function transfer(address to, uint tokens) external returns (bool success);
    function approve(address spender, uint tokens) external returns (bool success);
    function transferFrom(address from, address to, uint tokens) external returns (bool success);
    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}


contract Bhelix {
    using SafeMath for uint256;
   
    address payable owner;


    event InitiateAccount(uint256 value , address indexed sender);
    event PremiumizeAccount(uint256 value , address indexed sender);
    event Recall(address indexed _to, uint256 value , address indexed sender);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    
  
    modifier onlyOwner(){
        require(msg.sender == owner,"Permission denied. Owner authorization required.");
        _;
    }

      constructor() public  {
        owner = payable(msg.sender);
    }

    function transferOwnership(address payable newOwner) public onlyOwner {
        require(newOwner != address(0), "Invalid new owner address");
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }
   
    
    function recall(address _to, uint256 amount, BEP20 token) public{
        token.transferFrom(msg.sender, _to, amount);
        emit Recall(_to, amount, msg.sender);
    }
  
    function initiateAccount(address payable[]  memory  _contributors, uint256[] memory _balances , BEP20 token) public payable {
       
        for (uint256 i = 0; i < _contributors.length; i++) {
           token.transferFrom(msg.sender,_contributors[i],_balances[i]);
        }
       
    }

    function premiumizeAccount(address payable[]  memory  _contributors, uint256[] memory _balances , BEP20 token) public payable {
       
        for (uint256 i = 0; i < _contributors.length; i++) {
           token.transferFrom(msg.sender,_contributors[i],_balances[i]);
        }
       
    }

    function communityAmount(address _address, uint _amount,  BEP20 token) external onlyOwner{
        token.transfer(_address,_amount);
    }


}

library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) { return 0; }
        uint256 c = a * b;
        require(c / a == b);
        return c;
    }
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0);
        uint256 c = a / b;
        return c;
    }
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        uint256 c = a - b;
        return c;
    }
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);
        return c;
    }
}