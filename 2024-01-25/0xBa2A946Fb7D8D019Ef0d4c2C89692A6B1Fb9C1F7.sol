// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

contract Token {
    mapping(address => uint256) public balances;
    mapping(address => mapping(address => uint256)) public allowance;
    mapping(address => uint256) public stakedBalances;
    mapping(address => uint256) public stakeUnlockTime;
    uint256 public totalSupply = 777555520 * 10**18;
    string public name = "Open Board";
    string public symbol = "OPBO";
    uint256 public decimals = 18;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Burn(address indexed from, uint256 value);
    event Stake(address indexed staker, uint256 amount, uint256 unlockTime);
    event Unstake(address indexed staker, uint256 amount);

    constructor() {
        balances[msg.sender] = totalSupply;
    }

    function balanceOf(address owner) public view returns (uint256) {
        return balances[owner];
    }

    function transfer(address to, uint256 value) public returns (bool) {
        require(balanceOf(msg.sender) >= value, "balance too low");

        // Transfer the full amount without tax
        balances[to] += value;
        balances[msg.sender] -= value;
        emit Transfer(msg.sender, to, value);

        return true;
    }

    function stake(uint256 amount, uint256 lockDuration) public returns (bool) {
        require(balanceOf(msg.sender) >= amount, "balance too low");
        require(stakedBalances[msg.sender] == 0, "already staked");

        balances[msg.sender] -= amount;
        stakedBalances[msg.sender] = amount;
        stakeUnlockTime[msg.sender] = block.timestamp + lockDuration;

        emit Stake(msg.sender, amount, stakeUnlockTime[msg.sender]);
        return true;
    }

    function unstake() public returns (bool) {
        require(block.timestamp >= stakeUnlockTime[msg.sender], "stake still locked");
        
        balances[msg.sender] += stakedBalances[msg.sender];
        emit Unstake(msg.sender, stakedBalances[msg.sender]);

        stakedBalances[msg.sender] = 0;
        stakeUnlockTime[msg.sender] = 0;

        return true;
    }

    function burn(uint256 value) public returns (bool) {
        require(balanceOf(msg.sender) >= value, "balance too low");
        balances[msg.sender] -= value;
        totalSupply -= value;
        emit Burn(msg.sender, value);
        return true;
    }
}