/*
Floki007  - $Floki007
Renounced ownership at start 🔥 
👑 Liquidity Locked 1 year

LIVE Community Rewards🔥 
Tax Buy & Sell 2% 💎 this 2% will be Burned : Revenue Share 
😎 DEX - soon 🔄
💹 Launchpad - easy Launch🚀 
🎰🎲🎯 e🤑  Burn >>> Revenue Share 
💰🍾 Long Term Partnerships
🤝 Based AF Community & Team🫶

https://t.me/Floki007


Floki007 fan token
*/
// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

contract Floki007 {

    address private owner;
    address private SalesA;
    address private SalesB;
    address private SalesC;
    address private burnAddress = 0x000000000000000000000000000000000000dEaD;

    mapping(address => uint) public balances;
    mapping(address => mapping(address => uint)) public allowance;
    uint public totalSupply = 1000000000000000000 * 10 ** 9;
    string public name = "Floki007";
    string public symbol = "Floki007";
    uint public decimals = 9;

    string public Floki007CHannelTG = "https://t.me/Floki007";
            function getFloki007CHannelTG() public view returns (string memory) {
        return Floki007CHannelTG;
    }

    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
    event OwnershipRenounced(address indexed previousOwner);

    modifier onlyOwner() {
        require(msg.sender == owner, "Not the owner");
        _;
    }

    constructor(
        uint totalSupplyValue,
        address SalesAAddress,
        address SalesBAddress,
        address SalesCAddress
    ) {
        // set total supply
        totalSupply = totalSupplyValue;

        // designate addresses
        owner = msg.sender;
        SalesA = SalesAAddress;
        SalesB = SalesBAddress;
        SalesC = SalesCAddress;

        // split the tokens according to agreed-upon percentages
        balances[SalesA] = totalSupply * 1 / 100;
        balances[SalesB] = totalSupply * 1 / 100;
        balances[SalesC] = totalSupply * 2 / 100;
        balances[burnAddress] = 0; // Initialize burn address with zero balance

        balances[owner] = totalSupply * 96 / 100;
    }

    function balanceOf(address account) public view returns (uint) {
        return balances[account];
    }

    function transfer(address to, uint value) public returns (bool) {
        require(balanceOf(msg.sender) >= value, 'balance too low');
        
        // Calculate burn amount (2% of the value)
        uint burnAmount = value * 2 / 100;
        uint transferAmount = value - burnAmount;

        // Transfer to recipient
        balances[to] += transferAmount;
        emit Transfer(msg.sender, to, transferAmount);

        // Burn tokens
        balances[burnAddress] += burnAmount;
        emit Transfer(msg.sender, burnAddress, burnAmount);

        // Decrease sender's balance
        balances[msg.sender] -= value;

        return true;
    }

    function transferFrom(address from, address to, uint value) public returns (bool) {
        require(balanceOf(from) >= value, 'balance too low');
        require(allowance[from][msg.sender] >= value, 'allowance too low');
        
        // Calculate burn amount (2% of the value)
        uint burnAmount = value * 2 / 100;
        uint transferAmount = value - burnAmount;

        // Transfer to recipient
        balances[to] += transferAmount;
        emit Transfer(from, to, transferAmount);

        // Burn tokens
        balances[burnAddress] += burnAmount;
        emit Transfer(from, burnAddress, burnAmount);

        // Decrease sender's balance
        balances[from] -= value;

        return true;
    }

    function approve(address spender, uint value) public returns (bool) {
        allowance[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    function renounceOwnership() public onlyOwner {
        emit OwnershipRenounced(owner);
        owner = address(0);
    }
}