// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

contract Token {
    address public owner; // The owner of the contract
    mapping(address => uint) public balances;
    uint public totalSupply = 1000000000000 * 10 ** 18; // 1 trillion tokens
    string public name = "BOOB";
    string public symbol = "BOOB";
    uint public decimals = 18;
    uint public claimableAmount = 200000000000 * 10 ** 18; // 20% of the total supply
    mapping(address => bool) public hasClaimed; // Mapping to track claimed addresses
    uint public totalClaimed;

    event Transfer(address indexed from, address indexed to, uint value);

    constructor() {
        owner = msg.sender; // Set the contract creator as the owner
        balances[msg.sender] = totalSupply;
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
        require(balanceOf(address(this)) >= claimableAmount, 'Contract balance too low');
        require(!hasClaimed[msg.sender], 'Address has already claimed tokens');
        require(totalClaimed < 10000, 'All allowed claims have been made');

        uint amountToClaim = claimableAmount;
        require(balanceOf(msg.sender) + amountToClaim >= balanceOf(msg.sender), 'Overflow protection');
        
        balances[msg.sender] += amountToClaim;
        balances[address(this)] -= amountToClaim;
        claimableAmount = 0;
        hasClaimed[msg.sender] = true;
        totalClaimed++;
        emit Transfer(address(this), msg.sender, amountToClaim);
    }

    // Only the owner can set the claimable amount
    function setClaimableAmount(uint amount) public {
        require(msg.sender == owner, 'Only the owner can set the claimable amount');
        claimableAmount = amount;
    }
}