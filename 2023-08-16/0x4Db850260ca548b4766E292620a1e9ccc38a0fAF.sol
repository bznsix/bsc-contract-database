// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract Allowance {
    mapping (address => mapping (address => uint)) public allowance;

    function transferAllowance(address from, address to, uint amount) public {
        require(allowance[from][msg.sender] >= amount, "Insufficient allowance.");
        allowance[from][msg.sender] -= amount;
        allowance[to][msg.sender] += amount;
    }
    
    function receiveBNB() payable public {
        // Process received BNB here
    }
}