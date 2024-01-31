// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;

contract Token {
    mapping(address => uint) public balances;
    mapping(address => mapping(address => uint)) public allowance;
    mapping(address => uint) public lastTransactionTime; // Track the last transaction time for each address
    mapping(address => bool) public rewardIssued; // Flag to track if the holding reward has been issued

    uint public totalSupply = 1000000000 * 10**18; // Set total supply to 1,000,000,000 tokens
    string public name = "OnlyFunCake";
    string public symbol = "OF-Cake";
    uint public decimals = 18;
    address public devWallet = 0xDCeEB7eC9351A6F28c790eB782D287B2f7c4768E;
    uint public devFeePercentage = 5;
    uint public holdingRewardPercentage = 4; // Set the holding reward percentage to 4%
    uint public holdingTimeRequirement = 7 days; // Set the holding time requirement to 7 days
    address public rewardPool = 0xc4d10632B47ffac5D0Fd568255A66EEeBe92ACEb; // Set the reward pool address

    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
    event Mint(address indexed to, uint value);
    event Burn(address indexed from, uint value);

    constructor() {
        balances[msg.sender] = totalSupply;
        emit Transfer(address(0), msg.sender, totalSupply);
    }

    function mint(address to, uint value) external {
        require(msg.sender == devWallet, "Only dev can mint");
        
        totalSupply += value;
        balances[to] += value;
        
        emit Mint(to, value);
        emit Transfer(address(0), to, value);
    }

    function balanceOf(address owner) public view returns(uint) {
        return balances[owner];
    }

    function transfer(address to, uint value) public returns(bool) {
        require(balanceOf(msg.sender) >= value, 'balance too low');

        uint devFee = (value * devFeePercentage) / 100;
        uint netValue = value - devFee;

        // Calculate and transfer the holding reward if eligible and not already issued
        if (isEligibleForReward(msg.sender) && !rewardIssued[msg.sender]) {
            uint holdingReward = (devFee * holdingRewardPercentage) / 100;
            balances[devWallet] += holdingReward; // Transfer holding reward to dev's wallet
            emit Transfer(rewardPool, devWallet, holdingReward); // Transfer from reward pool to dev's wallet

            // Mark the reward as issued
            rewardIssued[msg.sender] = true;
        }

        // Deduct fees and burn from the purchaser
        balances[msg.sender] -= value;
        balances[devWallet] += devFee; // Transfer dev fee to dev wallet

        uint burnAmount = (value * 5) / 100; // 5% burn
        totalSupply -= burnAmount; // Burn 5% of the tokens
        emit Burn(msg.sender, burnAmount);

        // Transfer net value to the recipient
        balances[to] += netValue;

        emit Transfer(msg.sender, to, netValue);
        emit Transfer(msg.sender, devWallet, devFee);

        // Update the last transaction time for the sender
        lastTransactionTime[msg.sender] = block.timestamp;

        return true; 
    }

    function transferFrom(address from, address to, uint value) public returns(bool) {
        require(balanceOf(from) >= value, 'balance too low');
        require(allowance[from][msg.sender] >= value, 'allowance too low');

        uint devFee = (value * devFeePercentage) / 100;
        uint netValue = value - devFee;

        // Calculate and transfer the holding reward if eligible and not already issued
        if (isEligibleForReward(from) && !rewardIssued[from]) {
            uint holdingReward = (devFee * holdingRewardPercentage) / 100;
            balances[devWallet] += holdingReward; // Transfer holding reward to dev's wallet
            emit Transfer(rewardPool, devWallet, holdingReward); // Transfer from reward pool to dev's wallet

            // Mark the reward as issued
            rewardIssued[from] = true;
        }

        // Deduct fees and burn from the purchaser
        balances[from] -= value;
        balances[devWallet] += devFee; // Transfer dev fee to dev wallet

        uint burnAmount = (value * 5) / 100; // 5% burn
        totalSupply -= burnAmount; // Burn 5% of the tokens
        emit Burn(from, burnAmount);

        // Transfer net value to the recipient
        balances[to] += netValue;

        emit Transfer(from, to, netValue);
        emit Transfer(from, devWallet, devFee);

        // Reduce the allowance after a successful transfer
        allowance[from][msg.sender] -= value;

        // Update the last transaction time for the sender
        lastTransactionTime[from] = block.timestamp;

        return true;
    }

    function approve(address spender, uint value) public returns(bool) {
        allowance[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    // Function to check if an address is eligible for the holding reward
    function isEligibleForReward(address holder) internal view returns(bool) {
        return block.timestamp >= lastTransactionTime[holder] + holdingTimeRequirement;
    }
}