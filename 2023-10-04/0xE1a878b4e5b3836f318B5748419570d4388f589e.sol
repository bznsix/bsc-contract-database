// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract PopularToken {
    string public name = "PopularToken";
    string public symbol = "POP";
    uint8 public decimals = 18;
    uint256 public totalSupply;
    uint256 public taxRate = 2; // 2% tax rate
    address public owner;

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event TaxCollected(address indexed from, uint256 value);

    constructor(uint256 initialSupply) {
        owner = msg.sender;
        totalSupply = initialSupply * 10**uint256(decimals);
        balanceOf[msg.sender] = totalSupply;
    }

    function transfer(address to, uint256 value) public returns (bool) {
        require(to != address(0), "Invalid address");
        require(balanceOf[msg.sender] >= value, "Insufficient balance");

        uint256 tax = (value * taxRate) / 100;
        uint256 afterTaxValue = value - tax;

        balanceOf[msg.sender] -= value;
        balanceOf[to] += afterTaxValue;
        balanceOf[owner] += tax;

        emit Transfer(msg.sender, to, afterTaxValue);
        emit TaxCollected(msg.sender, tax);

        return true;
    }

    function approve(address spender, uint256 value) public returns (bool) {
        allowance[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    function transferFrom(address from, address to, uint256 value) public returns (bool) {
        require(from != address(0), "Invalid address");
        require(to != address(0), "Invalid address");
        require(balanceOf[from] >= value, "Insufficient balance");
        require(allowance[from][msg.sender] >= value, "Allowance exceeded");

        uint256 tax = (value * taxRate) / 100;
        uint256 afterTaxValue = value - tax;

        balanceOf[from] -= value;
        balanceOf[to] += afterTaxValue;
        balanceOf[owner] += tax;
        allowance[from][msg.sender] -= value;

        emit Transfer(from, to, afterTaxValue);
        emit TaxCollected(from, tax);

        return true;
    }
}