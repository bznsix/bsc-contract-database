// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// https://imgur.com/a/NOn6BTC

// Unleash the Power of the Dragon with BURN! 

// Hold on tight as you embark on a fiery journey into the world of cryptocurrency with BURN, 
// the token that's hotter than dragon's breath! 

// Rewarding Holders: Earn while you HODL! With every BURN token in your wallet, 
// you're harnessing the dragon's power to accumulate more treasure.

// Seller Burns: Watch as sellers meet their fiery demise! 
// A percentage of every sale gets added to liquidity, 
// making your BURN tokens even more valuable over time.

// No Telegram, no socials, no complicated steps to earn. BURN is not just a cryptocurrency; 
// it's a legendary creature waiting to set the crypto world ablaze! 
// Imagine your wallet growing fatter with every passing moment as the dragon guards 
// your precious treasure.

// Get ready to conquer the crypto realm and become a dragon-spirited holder with BURN! 
// Join the fire-breathing revolution today! 

contract BurnDragon {
    string public name = "Burn Dragon";
    string public symbol = "BURN";
    uint8 public decimals = 18;
    uint256 public totalSupply;
    
    address public owner;
    address public liquidityWallet;
    address public devWallet;

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;
    mapping(address => uint256) private _lastDividendPoints;
    
    uint256 private _totalDividendPoints;
    uint256 private _unclaimedDividends;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    constructor() {
        totalSupply = 1000000000 * 10 ** uint(decimals); // Initial supply of 1,000,000,000 tokens
        balanceOf[msg.sender] = totalSupply;
        owner = msg.sender;
        liquidityWallet = msg.sender;
        devWallet = msg.sender;
    }

    function setLiquidityWallet(address _wallet) external {
        require(msg.sender == owner, "Only the owner can set the liquidity wallet");
        liquidityWallet = _wallet;
    }

    function setDevWallet(address _wallet) external {
        require(msg.sender == owner, "Only the owner can set the developer wallet");
        devWallet = _wallet;
    }

    function transfer(address _to, uint256 _value) external returns (bool) {
        require(_to != address(0), "Transfer to the zero address is not allowed");
        require(_value <= balanceOf[msg.sender], "Insufficient balance");

        // Calculate the amount to distribute as taxes (1%)
        uint256 taxAmount = (_value * 1) / 100;

        // Calculate the amounts for liquidity, rewards, and developer cost
        uint256 liquidityShare = taxAmount / 2;
        uint256 rewardsShare = taxAmount / 2; // 0.5% as rewards
        uint256 devShare = taxAmount / 2;

        // Update balances
        balanceOf[liquidityWallet] += liquidityShare;
        balanceOf[devWallet] += devShare;

        // Distribute rewards to existing holders
        uint256 pointsToAdd = (rewardsShare * _totalDividendPoints) / totalSupply;
        _totalDividendPoints += pointsToAdd;
        _unclaimedDividends += pointsToAdd;

        // Subtract the tax from the sender's balance
        balanceOf[msg.sender] -= _value;

        // Add the remaining amount to the recipient's balance
        balanceOf[_to] += _value - taxAmount;

        // Update last dividend points for sender and recipient
        _lastDividendPoints[msg.sender] = _totalDividendPoints;
        _lastDividendPoints[_to] = _totalDividendPoints;

        emit Transfer(msg.sender, _to, _value - taxAmount);
        return true;
    }

    function approve(address _spender, uint256 _value) external returns (bool) {
        allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) external returns (bool) {
        require(_to != address(0), "Transfer to the zero address is not allowed");
        require(_value <= balanceOf[_from], "Insufficient balance");
        require(_value <= allowance[_from][msg.sender], "Allowance exceeded");

        allowance[_from][msg.sender] -= _value;

        // Calculate the amount to distribute as taxes (1%)
        uint256 taxAmount = (_value * 1) / 100;

        // Calculate the amounts for liquidity, rewards, and developer cost
        uint256 liquidityShare = taxAmount / 2;
        uint256 rewardsShare = taxAmount / 2; // 0.5% as rewards
        uint256 devShare = taxAmount / 2;

        // Update balances
        balanceOf[liquidityWallet] += liquidityShare;
        balanceOf[devWallet] += devShare;

        // Distribute rewards to existing holders
        uint256 pointsToAdd = (rewardsShare * _totalDividendPoints) / totalSupply;
        _totalDividendPoints += pointsToAdd;
        _unclaimedDividends += pointsToAdd;

        // Subtract the tax from the sender's balance
        balanceOf[_from] -= _value;

        // Add the remaining amount to the recipient's balance
        balanceOf[_to] += _value - taxAmount;

        // Update last dividend points for sender and recipient
        _lastDividendPoints[_from] = _totalDividendPoints;
        _lastDividendPoints[_to] = _totalDividendPoints;

        emit Transfer(_from, _to, _value - taxAmount);
        return true;
    }

    function claimDividends() external {
        uint256 owing = _unclaimedDividends - _lastDividendPoints[msg.sender];
        if (owing > 0) {
            balanceOf[msg.sender] += owing;
            _unclaimedDividends -= owing;
        }
        _lastDividendPoints[msg.sender] = _totalDividendPoints;
    }
}