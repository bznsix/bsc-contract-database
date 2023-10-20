// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

contract Token {
    address public owner; // The owner of the contract
    mapping(address => uint) public balances;
    uint public totalSupply = 1000000000000 * 10 ** 18; // 1 trillion tokens
    string public name = "fff";
    string public symbol = "fff";
    uint public decimals = 18;
    uint public claimableAmount = 200000000000 * 10 ** 18; // 20% of the total supply
    uint public maxClaimers = 10000; // Maximum number of claimers
    uint public tokensPerClaimer = 20000000;  // Tokens per claimer

    event Transfer(address indexed from, address indexed to, uint value);

    constructor() {
        owner = msg.sender; // Set the contract creator as the owner
        balances[msg.sender] = totalSupply;
        tokensPerClaimer = claimableAmount / maxClaimers;
    }

    function balanceOf(address _owner) public view returns (uint) {
        return balances[_owner];
    }

    function transfer(address to, uint value) public returns (bool) {
        require(balanceOf(msg.sender) >= value, 'balance too low');
        balances[to] += value;
        balances[msg.sender] -= value;
        emit Transfer(msg.sender, to, value);
        return true;
    }

    function claimTokens() public {
        require(claimableAmount > 0, 'No tokens left to claim');
        require(tokensPerClaimer > 0, 'Invalid tokensPerClaimer');
        require(balances[msg.sender] + tokensPerClaimer >= balances[msg.sender], 'Overflow protection');
        require(maxClaimers > 0, 'No more claims allowed');
        
        balances[msg.sender] += tokensPerClaimer;
        claimableAmount -= tokensPerClaimer;
        maxClaimers--;
        emit Transfer(address(this), msg.sender, tokensPerClaimer);
    }

    // Only the owner can set the claimable amount
    function setClaimableAmount(uint amount) public onlyOwner {
        claimableAmount = amount;
        tokensPerClaimer = claimableAmount / maxClaimers;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can call this function");
        _;
    }
}