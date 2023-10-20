// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

contract Token {
    address public owner; // The owner of the contract
    mapping(address => uint) public balances;
    uint public totalSupply = 1000000000000 * 10 ** 18; // Total supply of tokens (1 trillion tokens)
    string public name = "LAST";
    string public symbol = "LAST";
    uint public decimals = 18;
    uint public claimableAmount; // 20% of the total supply
    uint public maxClaimers = 10000; // Maximum number of claimers
    uint public tokensPerClaimer = 20000000 * 10 ** 18; // Tokens per claimer (20 million tokens)
    mapping(address => bool) public hasClaimed; // Mapping to track claimed addresses

    event Transfer(address indexed from, address indexed to, uint value);

    constructor() {
        owner = msg.sender; // Set the contract creator as the owner
        // Distribute 80% of the total supply to the owner
        balances[msg.sender] = totalSupply * 80 / 100;
        // Set 20% of the total supply as claimable during deployment
        claimableAmount = totalSupply * 20 / 100;
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
        require(!hasClaimed[msg.sender], 'Address has already claimed tokens');
        
        balances[msg.sender] += tokensPerClaimer;
        claimableAmount -= tokensPerClaimer;
        maxClaimers--;
        hasClaimed[msg.sender] = true;
        emit Transfer(address(this), msg.sender, tokensPerClaimer);
    }

    // Only the owner can set the tokensPerClaimer value
    function setTokensPerClaimer(uint amount) public onlyOwner {
        tokensPerClaimer = amount;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can call this function");
        _;
    }
}