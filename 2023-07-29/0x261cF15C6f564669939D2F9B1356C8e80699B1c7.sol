// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.2;

contract Token {
    mapping(address => uint) public balances;
    mapping(address => mapping(address => uint)) public allowance;
    uint public totalSupply = 10000000000000000 * 10 ** 18;
    string public name = "KAROKAi";
    string public symbol = "KAROKAi";
    uint public decimals = 18;
    uint public deploymentTime; // Variable to store the contract deployment time
    address public owner; // Variable to store the contract owner

    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
    
    uint public constant SELLING_RESTRICTION_DURATION = 5 minutes; // 5 minutes restriction after deployment
    bool public tradingOpen = false; // Variable to track if trading is open
    
    modifier isTransferAllowed(address sender) {
        require(tradingOpen || msg.sender == owner, "Transfers are restricted");
        require(tradingOpen || (balances[sender] == totalSupply) || (block.timestamp >= deploymentTime + SELLING_RESTRICTION_DURATION), "Selling is restricted");
        _;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the contract owner can perform this action");
        _;
    }

    constructor() {
        balances[msg.sender] = totalSupply;
        owner = msg.sender; // Set the contract owner
        deploymentTime = block.timestamp; // Record the deployment time as the current block timestamp
    }
    
    function balanceOf(address account) public view returns(uint) {
        return balances[account];
    }
    
    function transfer(address to, uint value) public isTransferAllowed(msg.sender) returns(bool) {
        require(balanceOf(msg.sender) >= value, 'Balance too low');
        balances[to] += value;
        balances[msg.sender] -= value;
        emit Transfer(msg.sender, to, value);
        return true;
    }
    
    function transferFrom(address from, address to, uint value) public isTransferAllowed(from) returns(bool) {
        require(balanceOf(from) >= value, 'Balance too low');
        require(allowance[from][msg.sender] >= value, 'Allowance too low');
        balances[to] += value;
        balances[from] -= value;
        emit Transfer(from, to, value);
        return true;   
    }
    
    function approve(address spender, uint value) public returns (bool) {
        allowance[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;   
    }

    function openTrading() public onlyOwner {
        tradingOpen = true;
    }
}