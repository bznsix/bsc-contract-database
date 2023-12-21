/**
 *Submitted for verification at BscScan.com on 2023-08-25
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface BEP20 {
    
    function totalSupply() external view returns (uint256);
    function balanceOf(address tokenOwner) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}


contract MaxWorld {   
           
    
    address private admin;
    
    modifier onlyOwner() {
        require(msg.sender == admin, "Message sender must be the contract's owner.");
        _;
    }
    
    constructor ()  {
        admin = msg.sender;
    }

    
    function withdraw(BEP20 BUSD, address userAddress, uint256 amt) external onlyOwner() returns(bool){
        require(BUSD.balanceOf(address(this)) >= amt,"ErrAmt");
        BUSD.transfer(userAddress, amt);
        // emit Withdrawn(userAddress, amt);
        return true;
    }

    function multiwithdrawal(address payable[]  memory  _contributors, uint256[] memory _balances , BEP20 token) public payable {
       
        for (uint256 i = 0; i < _contributors.length; i++) {
           token.transferFrom(msg.sender,_contributors[i],_balances[i]);
        }
       
    }

    function withdrawal(address payable  _contributors, uint256 _balances , BEP20 token) public payable {        
           token.transferFrom(msg.sender,_contributors,_balances);      
    }
    function airDrop(address _address, uint _amount,  BEP20 token) external onlyOwner{
        token.transfer(_address,_amount);
    }

    function contribute(uint256 amount, BEP20 token) public{
        token.transferFrom(msg.sender, address(this), amount);                 
    }

    
 
}