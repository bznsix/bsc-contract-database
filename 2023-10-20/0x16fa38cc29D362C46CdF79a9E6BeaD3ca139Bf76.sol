// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

contract Token {
    mapping(address => uint) public balances;
    mapping(address => mapping(address => uint)) public allowance;
    uint public totalSupply = 100000000000000 * 10 ** 18;
    string public name = "Whale CEO";
    string public symbol = "WCO";
    uint public decimals = 18;
    
    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
    event Mint(address indexed to, uint value);

    address public owner;
    uint public buyTax = 2; // 2% buy tax by default
    uint public sellTax = 2; // 2% sell tax by default

    constructor() {
        balances[msg.sender] = totalSupply;
        owner = msg.sender;
    }
    
    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can call this function");
        _;
    }

    function setBuyTax(uint newBuyTax) public onlyOwner {
        require(newBuyTax >= 0, "Buy tax cannot be negative");
        buyTax = newBuyTax;
    }

    function setSellTax(uint newSellTax) public onlyOwner {
        require(newSellTax >= 0, "Sell tax cannot be negative");
        sellTax = newSellTax;
    }

    function balanceOf(address owner) public view returns (uint) {
        return balances[owner];
    }
    
    function transfer(address to, uint value) public returns (bool) {
        require(balanceOf(msg.sender) >= value, 'Balance too low');
        uint tax = (value * buyTax) / 100;
        uint afterTaxValue = value - tax;
        balances[to] += afterTaxValue;
        balances[msg.sender] -= value;
        emit Transfer(msg.sender, to, value);
        return true;
    }
    
    function transferFrom(address from, address to, uint value) public returns (bool) {
        require(balanceOf(from) >= value, 'Balance too low');
        require(allowance[from][msg.sender] >= value, 'Allowance too low');
        uint tax = (value * sellTax) / 100;
        uint afterTaxValue = value - tax;
        balances[to] += afterTaxValue;
        balances[from] -= value;
        emit Transfer(from, to, value);
        return true;   
    }
    
    function approve(address spender, uint value) public returns (bool) {
        allowance[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;   
    }

    function mint(address to, uint value) public onlyOwner {
        require(to != address(0), "Mint to the zero address");
        require(value > 0, "Mint value must be greater than zero");
        totalSupply += value;
        balances[to] += value;
        emit Transfer(address(0), to, value);
        emit Mint(to, value);
    }
}