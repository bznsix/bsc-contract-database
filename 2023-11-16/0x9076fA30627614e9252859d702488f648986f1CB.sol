// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

contract JJToken {
    string public name = "JJ Token";
    string public symbol = "JJ";
    uint256 public totalSupply = 10000000000 * 10 ** 18; // 总量：10,000,000,000
    uint8 public decimals = 18;
    address public taxAddress = 0x9932Ce13874BcC480e9b2F2162bD228b2cAD1333;
    uint256 public taxRate = 3; // 税费率：3%

    mapping(address => uint256) private balances;
    mapping(address => mapping(address => uint256)) private allowances;

    event Transfer(address indexed from, address indexed to, uint256 amount);
    event Approval(address indexed owner, address indexed spender, uint256 amount);

    constructor() {
        balances[msg.sender] = totalSupply;
    }

    function balanceOf(address account) public view returns (uint256) {
        return balances[account];
    }

    function transfer(address to, uint256 amount) public returns (bool) {
        require(amount > 0, "Amount must be greater than zero");
        require(amount <= balances[msg.sender], "Insufficient balance");

        uint256 taxAmount = (amount * taxRate) / 100;
        uint256 transferAmount = amount - taxAmount;

        balances[msg.sender] -= amount;
        balances[to] += transferAmount;
        balances[taxAddress] += taxAmount;

        emit Transfer(msg.sender, to, transferAmount);
        emit Transfer(msg.sender, taxAddress, taxAmount);

        return true;
    }

    function transferFrom(address from, address to, uint256 amount) public returns (bool) {
        require(amount > 0, "Amount must be greater than zero");
        require(amount <= balances[from], "Insufficient balance");
        require(amount <= allowances[from][msg.sender], "Insufficient allowance");

        uint256 taxAmount = (amount * taxRate) / 100;
        uint256 transferAmount = amount - taxAmount;

        balances[from] -= amount;
        balances[to] += transferAmount;
        balances[taxAddress] += taxAmount;
        allowances[from][msg.sender] -= amount;

        emit Transfer(from, to, transferAmount);
        emit Transfer(from, taxAddress, taxAmount);

        return true;
    }

    function approve(address spender, uint256 amount) public returns (bool) {
        allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function allowance(address owner, address spender) public view returns (uint256) {
        return allowances[owner][spender];
    }
}