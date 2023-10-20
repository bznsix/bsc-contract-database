// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

contract DragonsBaneLegends {
    string public name = "Dragon s Bane Legends Market";
    string public symbol = "DBL";
    uint8 public decimals = 18;
    uint256 public totalSupply;
    address public owner;

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    // Déclaration de la variable '_lastTransaction'
    mapping(address => uint256) private _lastTransaction;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Burn(address indexed from, uint256 value);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can call this function");
        _;
    }

    modifier antiWhale(uint256 value) {
        require(value <= totalSupply / 100, "Exceeds 1% of total supply");
        _;
    }

    modifier antiFrontRunning(address from) {
        require(_lastTransaction[from] + 180 < block.timestamp, "Transaction too fast");
        _;
    }

    constructor() {
        uint256 initialSupply = 100000000 * 10**uint256(decimals);
        totalSupply = initialSupply;
        balanceOf[msg.sender] = initialSupply;
        owner = msg.sender;
    }

    function approve(address spender, uint256 value) public returns (bool) {
        require(spender != address(0), "Invalid address");
        require(value <= balanceOf[msg.sender], "Overdrawn balance");

        allowance[msg.sender][spender] = value;

        return true;
    }

    function transfer(address to, uint256 value) public antiWhale(value) antiFrontRunning(msg.sender) returns (bool) {
        require(to != address(0), "Invalid address");
        require(balanceOf[msg.sender] >= value, "Balance too low");
        require(allowance[msg.sender][to] >= value, "Not enough allowance");

        balanceOf[msg.sender] -= value;
        balanceOf[to] += value;

        allowance[msg.sender][to] -= value;

        // Mise à jour de la variable '_lastTransaction'
        _lastTransaction[msg.sender] = block.timestamp;

        emit Transfer(msg.sender, to, value);

        return true;
    }

    function burn(uint256 value) public antiWhale(value) antiFrontRunning(msg.sender) returns (bool) {
        require(balanceOf[msg.sender] >= value, "Balance too low");

        balanceOf[msg.sender] -= value;
        totalSupply -= value;

        // Mise à jour de la variable '_lastTransaction'
        _lastTransaction[msg.sender] = block.timestamp;

        emit Transfer(msg.sender, address(0), value);

        emit Burn(msg.sender, value);

        return true;
    }

    function redistribute(address to, uint256 value) public antiWhale(value) antiFrontRunning(msg.sender) returns (bool) {
        require(to != address(0), "Invalid address");
        require(balanceOf[msg.sender] >= value, "Balance too low");

        balanceOf[msg.sender] -= value;
        balanceOf[to] += value;

        // Mise à jour de la variable '_lastTransaction'
        _lastTransaction[msg.sender] = block.timestamp;

        emit Transfer(msg.sender, to, value);

        return true;
    }

    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "Invalid address");
        owner = newOwner;
    }
}