// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

contract DragonsBaneCoin {
    string public name = "Dragon s Bane Legends Market";
    string public symbol = "DBL";
    uint8 public decimals = 18;
    uint256 public totalSupply;
    address public owner;

    mapping(address => uint256) public balanceOf;

    event Transfer(address indexed from, address indexed to, uint256 value);

    constructor() {
        uint256 initialSupply = 100000000 * 10**uint256(decimals);
        totalSupply = initialSupply;
        balanceOf[msg.sender] = initialSupply;
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can call this function");
        _;
    }

    function transfer(address to, uint256 value) public returns (bool) {
        require(to != address(0), "Invalid address");
        require(balanceOf[msg.sender] >= value, "Balance too low");

        balanceOf[msg.sender] -= value;
        balanceOf[to] += value;

        emit Transfer(msg.sender, to, value);

        return true;
    }

    function burn(uint256 value) public returns (bool) {
        require(balanceOf[msg.sender] >= value, "Balance too low");

        balanceOf[msg.sender] -= value;
        totalSupply -= value;

        emit Transfer(msg.sender, address(0), value);

        return true;
    }

    function redistribute(address to, uint256 value) public returns (bool) {
        require(balanceOf[msg.sender] >= value, "Balance too low");
        require(to != address(0), "Invalid address");

        balanceOf[msg.sender] -= value;
        balanceOf[to] += value;

        emit Transfer(msg.sender, to, value);

        return true;
    }

    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "Invalid address");
        owner = newOwner;
    }

    // Fonction de burn automatique tous les 1er du mois d'un montant de 5000 tokens
    function autoBurn() public onlyOwner {
        // Get the current day of the month
        uint256 day = block.timestamp / 86400;

        // Check if the current day is the 1st of the month
        require(day == 1, "Can only burn tokens on the 1st of the month");

        // Burn 5000 tokens
        burn(5000);
    }
}