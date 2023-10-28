// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Memeland {
    string public name = "Memeland";
    string public symbol = "MEME";
    uint256 public totalSupply = 10000000 * 10**18; // 10 million tokens
    address public owner;
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    constructor() {
        owner = msg.sender;
        balanceOf[owner] = totalSupply;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the contract owner can perform this action");
        _;
    }

    function transfer(address to, uint256 value) external returns (bool) {
        require(balanceOf[msg.sender] >= value, "Insufficient balance");

        balanceOf[msg.sender] -= value;
        balanceOf[to] += value;

        emit Transfer(msg.sender, to, value);
        return true;
    }

    function approve(address spender, uint256 value) external returns (bool) {
        allowance[msg.sender][spender] = value;

        emit Approval(msg.sender, spender, value);
        return true;
    }

    function transferFrom(address from, address to, uint256 value) external returns (bool) {
        require(balanceOf[from] >= value, "Insufficient balance");
        require(allowance[from][msg.sender] >= value, "Not enough allowance");

        balanceOf[from] -= value;
        balanceOf[to] += value;
        allowance[from][msg.sender] -= value;

        emit Transfer(from, to, value);
        return true;
    }

    function burn(uint256 value) external onlyOwner {
        require(balanceOf[msg.sender] >= value, "Insufficient balance");

        balanceOf[msg.sender] -= value;
        totalSupply -= value;

        emit Transfer(msg.sender, address(0), value);
    }

    function renounceOwnership() external onlyOwner {
        owner = address(0);
    }

    function increaseAllowance(address spender, uint256 addedValue) external returns (bool) {
        allowance[msg.sender][spender] += addedValue;

        emit Approval(msg.sender, spender, allowance[msg.sender][spender]);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) external returns (bool) {
        require(allowance[msg.sender][spender] >= subtractedValue, "Decreased allowance below zero");

        allowance[msg.sender][spender] -= subtractedValue;

        emit Approval(msg.sender, spender, allowance[msg.sender][spender]);
        return true;
    }
}