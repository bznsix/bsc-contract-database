// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// ReentrancyGuard contract to prevent reentrant calls
contract ReentrancyGuard {
    bool private locked;

    modifier preventReentrancy() {
        require(!locked, "ReentrancyGuard: reentrant call");
        locked = true;
        _;
        locked = false;
    }
}

contract Digicoin is ReentrancyGuard {
    string public name = "Digicoin";
    string public symbol = "DC";
    uint8 public decimals = 18;
    uint256 public totalSupply = 110 * 10**27;
    uint256 public stakingBonusPool = 43 * 10**27;

    mapping(address => uint256) public balanceOf;
    mapping(address => uint256) public stakedBalanceOf;
    mapping(address => uint256) public stakingBonusOf;

    uint256 public maxStakingPerTransaction = 10 * 10**27;
    uint256 public transferLimit = 300000;
    uint256 public lastTransferTime;
    uint256 public transferredCount;
    uint256 public transferFeePercentage = 2;
    uint256 public constant FEE_DIVISOR = 10000;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Staked(address indexed user, uint256 amount);
    event Unstaked(address indexed user, uint256 amount);

    constructor() {
        balanceOf[msg.sender] = totalSupply;
        lastTransferTime = block.timestamp;
    }

    function transfer(address to, uint256 value) external preventReentrancy {
        require(balanceOf[msg.sender] >= value, "Insufficient balance");
        require(transferredCount < transferLimit, "Transfer limit exceeded");

        if (block.timestamp - lastTransferTime >= 1 seconds) {
            lastTransferTime = block.timestamp;
            transferredCount = 1;
        } else {
            transferredCount++;
        }

        uint256 fee = (value * transferFeePercentage) / FEE_DIVISOR;
        uint256 netAmount = value - fee;

        balanceOf[msg.sender] -= value;
        balanceOf[to] += netAmount;
        emit Transfer(msg.sender, to, netAmount);
    }

    function stake(uint256 amount) external preventReentrancy {
        require(amount > 0, "Amount must be greater than 0");
        require(
            amount <= maxStakingPerTransaction,
            "Staking amount exceeds maximum limit"
        );
        require(balanceOf[msg.sender] >= amount, "Insufficient balance");

        balanceOf[msg.sender] -= amount;
        stakedBalanceOf[msg.sender] += amount;
        stakingBonusOf[msg.sender] += (amount * stakingBonusPool) / totalSupply;
        emit Staked(msg.sender, amount);
    }

    function unstake(uint256 amount) external preventReentrancy {
        require(amount > 0, "Amount must be greater than 0");
        require(
            stakedBalanceOf[msg.sender] >= amount,
            "Insufficient staked balance"
        );

        uint256 bonusToRemove = (amount * stakingBonusPool) / totalSupply;
        stakingBonusPool -= bonusToRemove;
        stakedBalanceOf[msg.sender] -= amount;
        balanceOf[msg.sender] += amount + stakingBonusOf[msg.sender];
        stakingBonusOf[msg.sender] -= bonusToRemove;
        emit Unstaked(msg.sender, amount);
    }
}