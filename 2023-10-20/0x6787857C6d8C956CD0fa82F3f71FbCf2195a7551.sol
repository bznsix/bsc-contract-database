// SPDX-License-Identifier: MIT
pragma solidity ^0.6.6; 

// Creating a Contract
contract GBTOKEN {
    // Table to map addresses to their balance
    mapping(address => uint256) balances;

    // Mapping owner address to those who are allowed to use the contract
    mapping(address => mapping(address => uint256)) allowed;

    // Token details
    string public name = "GBTOKEN";
    string public symbol = "GBT";
    uint8 public decimals = 18; // 18 is the most common number of decimal places

    // Total supply
    uint256 public totalSupply;

    // Owner address
    address public owner; 

    // Event triggered when approve(address _spender, uint256 _value) is called.
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

    // Event triggered when tokens are transferred.
    event Transfer(address indexed _from, address indexed _to, uint256 _value);

    // Constructor to assign the total supply to the owner
    constructor() public {
        owner = msg.sender;
        totalSupply = 500000 * 10**uint256(decimals); 
        balances[msg.sender] = totalSupply; // Mint the initial supply and assign it to the contract owner
    }

    // Function to add a new token holder
    function addHolder(address _newHolder, uint256 _initialBalance) public returns (bool success) {
        require(msg.sender == owner, "Only the owner can add token holders");
        require(balances[_newHolder] == 0, "Token holder already exists");
        
        balances[_newHolder] = _initialBalance;
        return true;
    }

    // Function to get the number of decimals
    function getDecimals() public view returns (uint8) {
        return decimals;
    }

    // Function to get the name of the token
    function getName() public view returns (string memory) {
        return name;
    }

    // Function to get the symbol of the token
    function getSymbol() public view returns (string memory) {
        return symbol;
    }

    // Function to get the total supply of tokens
    function getTotalSupply() public view returns (uint256) {
        return totalSupply;
    }

    // Function that returns the token balance of a specific address
    function balanceOf(address _owner) public view returns (uint256 balance) {
        return balances[_owner];
    }

    // Function that allows a user to transfer tokens to another address
    function transfer(address _to, uint256 _value) public returns (bool success) {
        require(balances[msg.sender] >= _value, "Insufficient balance");
        balances[msg.sender] -= _value;
        balances[_to] += _value;
        emit Transfer(msg.sender, _to, _value);
        return true;
    }
}