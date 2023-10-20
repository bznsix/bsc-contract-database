// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract MichaelJackson {
    string public constant name = "MichaelJackson";
    string public constant symbol = "MJ";
    uint8 public constant decimals = 18;
    uint public totalSupply;
    address public feeCollector;
    address public owner;

    mapping(address => uint) balances;

    event Transfer(address from, address to, uint amount);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the contract owner can call this function");
        _;
    }

    constructor() {
        totalSupply = 1000000000 * (10**decimals);
        owner = 0x444b25601DE50Fa2DA9c9148f601876ACfb4c89B;
        feeCollector = 0x2328B7d81F0D7818aA9B4E7390A25D88faa09F6e;
    }

    function transfer(address to, uint amount) external {
        require(balances[msg.sender] >= amount, "Insufficient balance");

        uint fee = amount * 10 / 100;
        uint transferAmount = amount - fee;

        balances[msg.sender] -= amount;
        balances[to] += transferAmount;
        balances[feeCollector] += fee;

        emit Transfer(msg.sender, to, transferAmount);
    }

    function withdraw() external onlyOwner {
        uint amount = balances[feeCollector];
        balances[feeCollector] = 0;
        payable(feeCollector).transfer(amount);
    }
}