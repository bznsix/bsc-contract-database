// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

contract PepeBandToken {
    string public constant name = "PepeBand";
    string public constant symbol = "PEPEBAND";
    uint8 public constant decimals = 9;
    uint256 public totalSupply = 900e9 * 1e9; // 900 billion tokens with 9 decimals
    address public owner;
    address public constant marketingWallet = 0x5164634D77b1104Faf535704ccF3dcfaAB56955F;
    address public constant deadWallet = 0x000000000000000000000000000000000000dEaD; // Make deadWallet constant

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;
    mapping(address => bool) public isExcludedFromFees;
    mapping(address => bool) public isExcludedFromTransferLimit;
    mapping(address => bool) public isExcludedFromBalanceLimit;

    uint256 public marketingFee = 3;
    uint256 public burnFee = 2;
    uint256 public maxTransactionAmount = totalSupply / 50; // 2% of totalSupply
    uint256 public maxBalancePerAddress = totalSupply / 50; // 5% of totalSupply

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event MarketingFeeUpdated(uint256 newFee);
    event BurnFeeUpdated(uint256 newFee);

    constructor() {
        owner = msg.sender;
        balanceOf[msg.sender] = totalSupply;
        isExcludedFromFees[owner] = true;
        isExcludedFromFees[marketingWallet] = true;
        isExcludedFromFees[deadWallet] = true;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can call this function");
        _;
    }

    function transferOwnership(address newOwner) external onlyOwner {
        require(newOwner != address(0), "Invalid new owner");
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }

    function setMarketingFee(uint256 fee) external onlyOwner {
        require(fee + burnFee <= 5, "Total fee cannot exceed 5%");
        marketingFee = fee;
        emit MarketingFeeUpdated(fee);
    }

    function setBurnFee(uint256 fee) external onlyOwner {
        require(fee + marketingFee <= 5, "Total fee cannot exceed 5%");
        burnFee = fee;
        emit BurnFeeUpdated(fee);
    }

    function setMaxTransactionAmount(uint256 amount) external onlyOwner {
        maxTransactionAmount = amount;
    }

    function setMaxBalancePerAddress(uint256 amount) external onlyOwner {
        maxBalancePerAddress = amount;
    }

    function excludeFromFees(address account, bool exclude) external onlyOwner {
        isExcludedFromFees[account] = exclude;
    }

    function excludeFromTransferLimit(address account, bool exclude) external onlyOwner {
        isExcludedFromTransferLimit[account] = exclude;
    }

    function excludeFromBalanceLimit(address account, bool exclude) external onlyOwner {
        isExcludedFromBalanceLimit[account] = exclude;
    }

    function transfer(address recipient, uint256 amount) external returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function approve(address spender, uint256 amount) external returns (bool) {
        allowance[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool) {
        _transfer(sender, recipient, amount);
        uint256 currentAllowance = allowance[sender][msg.sender];
        require(currentAllowance >= amount, "Transfer amount exceeds allowance");
        unchecked {
            allowance[sender][msg.sender] = currentAllowance - amount;
        }
        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal {
        require(sender != address(0), "Transfer from the zero address");
        require(recipient != address(0), "Transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        require(amount <= maxTransactionAmount || isExcludedFromTransferLimit[sender], "Exceeds maximum transaction amount");

        // Calculate fees as a percentage of the transfer amount
        uint256 marketingAmount = 0;
        uint256 burnAmount = 0;

        if (!isExcludedFromFees[sender]) {
            marketingAmount = (amount * marketingFee) / 100;
            burnAmount = (amount * burnFee) / 100;
        }

        // Calculate the transfer amount after deducting fees
        uint256 transferAmount = amount - marketingAmount - burnAmount;

        // Check if the recipient is excluded from balance limits
        if (!isExcludedFromBalanceLimit[recipient]) {
            // Check if the resulting balance of the recipient would exceed the max balance per address
            require(balanceOf[recipient] + transferAmount <= maxBalancePerAddress, "Exceeds maximum balance per address");
        }

        // Deduct the transfer amount from the sender's balance
        require(balanceOf[sender] >= transferAmount, "Insufficient balance");
        balanceOf[sender] -= transferAmount;

        // Handle fees only if the sender is not excluded from fees
        if (!isExcludedFromFees[sender]) {
            _handleFees(sender, marketingAmount, burnAmount);
        }

        // Add the transfer amount to the recipient's balance
        balanceOf[recipient] += transferAmount;

        emit Transfer(sender, recipient, transferAmount);
    }

    function _handleFees(address sender, uint256 marketingAmount, uint256 burnAmount) internal {
        // Transfer marketing fee to the marketing wallet
        balanceOf[sender] -= marketingAmount;
        balanceOf[marketingWallet] += marketingAmount;
        emit Transfer(sender, marketingWallet, marketingAmount);

        // Burn tokens
        totalSupply -= burnAmount;
        emit Transfer(sender, deadWallet, burnAmount);
    }

    function renounceOwnership() external onlyOwner {
        emit OwnershipTransferred(owner, address(0));
        owner = address(0);
    }
}