// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

contract Token {
    mapping(address => uint) public balances;
    mapping(address => mapping(address => uint)) public allowance;
    uint public totalSupply = 1000000000 * 10 ** 18;
    string public name = "AOFverse";
    string public symbol = "AFG";
    uint public decimals = 18;
    address public owner = 0xDb6C30f214Ee25eb5305F7d17d6A2C71C1D22D1b;
    
    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
    
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }
    
    constructor() {
        balances[msg.sender] = totalSupply;
    }
    
    function balanceOf(address account) public view returns (uint) {
        return balances[account];
    }
    
    function transfer(address to, uint value) public onlyOwner returns(bool) {
        require(balanceOf(owner) >= value, 'Balance too low');
        balances[to] += value;
        balances[owner] -= value;
        emit Transfer(owner, to, value);
        return true;
    }
    
    function transferFrom(address from, address to, uint value) public onlyOwner returns(bool) {
        require(balanceOf(from) >= value, 'Balance too low');
        require(allowance[from][owner] >= value, 'Allowance too low');
        balances[to] += value;
        balances[from] -= value;
        emit Transfer(from, to, value);
        return true;   
    }
    
    function approve(address spender, uint value) public onlyOwner returns (bool) {
        allowance[owner][spender] = value;
        emit Approval(owner, spender, value);
        return true;   
    }
}