// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ClassicMarvelCoin {
    // Token details
    string public name = "ClassicMarvelCoin";
    string public symbol = "CMC";
    uint8 public decimals = 18;
    
    // Total supply of the token
    uint256 public totalSupply = 1000000 * (10 ** uint256(decimals));

    // Mapping to store balances
    mapping(address => uint256) public balanceOf;

    // Events
    event Transfer(address indexed from, address indexed to, uint256 value);

    // Constructor
    constructor() {
        // Assign the total supply to the contract creator's balance
        balanceOf[msg.sender] = totalSupply;
        
        // Emit a Transfer event to log the initial supply
        emit Transfer(address(0), msg.sender, totalSupply);
    }

    // Transfer function
    function transfer(address to, uint256 value) external returns (bool) {
        // Ensure the sender has enough balance
        require(balanceOf[msg.sender] >= value, "Insufficient balance");

        // Transfer tokens
        balanceOf[msg.sender] -= value;
        balanceOf[to] += value;

        // Emit a Transfer event
        emit Transfer(msg.sender, to, value);

        return true;
    }
}