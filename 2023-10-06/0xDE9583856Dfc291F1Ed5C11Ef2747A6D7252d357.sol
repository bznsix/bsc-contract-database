// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IUniswapV2Router02 {
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    )
        external
        payable
        returns (uint amountToken, uint amountETH, uint liquidity);
}

contract DiziGoldCoin {
    string public name = "Dizi Gold Coin";
    string public symbol = "DGC";
    uint8 public decimals = 18;
    uint256 public totalSupply;
    uint256 private _maxTransactionAmount = 1000000 * 10**18;

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;
    mapping(address => bool) public isBlacklisted;
    mapping(address => bool) public isExcludedFromFee;
    mapping(address => bool) public isExcludedFromReward;
    mapping(address => uint256) private _rewardTokenHolders;
    mapping(address => uint256) private _lastRewardClaimed;
    address[] private _rewardTokenHolderAddresses;
    uint256 private _taxPercentage = 5;
    uint256 private _burnPercentage = 20;
    uint256 private _liquidityPercentage = 30;
    uint256 private _rewardPercentage = 50;
    uint256 private _totalTokensToDistribute;
    bool private _tradingEnabled = true;
    bool private _contractLocked = false;
    address private _owner;
    address private _pancakeSwapRouter;
    address private _liquidityPoolAddress;  // Address to add liquidity

    modifier onlyOwner() {
        require(msg.sender == _owner, "Not the contract owner");
        _;
    }

    modifier canTrade() {
        require(_tradingEnabled && !_contractLocked, "Trading is disabled or contract is locked");
        _;
    }

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    constructor(uint256 initialSupply) {
        totalSupply = initialSupply * 10**uint256(decimals);
        balanceOf[msg.sender] = totalSupply;
        _owner = msg.sender;
        emit Transfer(address(0), msg.sender, totalSupply);
    }

    // Function to set the liquidity pool address
    function setLiquidityPoolAddress(address liquidityPoolAddress) external onlyOwner {
        _liquidityPoolAddress = liquidityPoolAddress;
    }

   // Function to add liquidity to the specified pool
    function addLiquidityToPool(uint256 amountTokenDesired, uint256 amountETHMin) external onlyOwner payable {
        require(_liquidityPoolAddress != address(0), "Liquidity pool address not set");
        require(amountTokenDesired > 0, "Invalid amountTokenDesired");
        require(msg.value >= amountETHMin, "Insufficient ETH provided");

        // Call the approve function from the DiziGoldCoin contract
        this.approve(_liquidityPoolAddress, amountTokenDesired);

        // Add liquidity
        IUniswapV2Router02 uniswapRouter = IUniswapV2Router02(_pancakeSwapRouter);
        uniswapRouter.addLiquidityETH{value: msg.value}(
            address(this),
            amountTokenDesired,
            0,
            amountETHMin,
            _liquidityPoolAddress,
            block.timestamp
        );
    }

    function approve(address spender, uint256 amount) external canTrade returns (bool) {
        allowance[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function internalApprove(address spender, uint256 amount) internal {
        require(spender != address(0), "Invalid spender");
        require(amount > 0, "Invalid amount");
        allowance[address(this)][spender] = amount;
        emit Approval(address(this), spender, amount);
    }

    function transfer(address recipient, uint256 amount) external canTrade returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) external canTrade returns (bool) {
        require(amount <= allowance[sender][msg.sender], "Allowance exceeded");
        allowance[sender][msg.sender] -= amount;
        _transfer(sender, recipient, amount);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) external canTrade returns (bool) {
        allowance[msg.sender][spender] += addedValue;
        emit Approval(msg.sender, spender, allowance[msg.sender][spender]);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) external canTrade returns (bool) {
        uint256 currentAllowance = allowance[msg.sender][spender];
        require(subtractedValue <= currentAllowance, "Allowance cannot be negative");
        allowance[msg.sender][spender] = currentAllowance - subtractedValue;
        emit Approval(msg.sender, spender, allowance[msg.sender][spender]);
        return true;
    }

    function blacklistAddress(address account) external onlyOwner {
        isBlacklisted[account] = true;
    }

    function unblacklistAddress(address account) external onlyOwner {
        isBlacklisted[account] = false;
    }

    function enableTrading() external onlyOwner {
        _tradingEnabled = true;
    }

    function disableTrading() external onlyOwner {
        _tradingEnabled = false;
    }

    function lockContract() external onlyOwner {
        _contractLocked = true;
    }

    function unlockContract() external onlyOwner {
        _contractLocked = false;
    }

    function setTaxPercentage(uint256 taxPercentage) external onlyOwner {
        _taxPercentage = taxPercentage;
    }

    function setMaxTransactionAmount(uint256 maxTransactionAmount) external onlyOwner {
        require(maxTransactionAmount > 0, "Invalid amount");
        _maxTransactionAmount = maxTransactionAmount;
    }

    function setExcludedFromFee(address account, bool isExcluded) external onlyOwner {
        isExcludedFromFee[account] = isExcluded;
    }

    function setExcludedFromReward(address account, bool isExcluded) external onlyOwner {
        isExcludedFromReward[account] = isExcluded;
    }

    function setRewardForHolders(address[] memory holders, uint256[] memory amounts) external onlyOwner {
        require(holders.length == amounts.length, "Arrays length mismatch");

        for (uint256 i = 0; i < holders.length; i++) {
            require(holders[i] != address(0), "Invalid address");
            _rewardTokenHolders[holders[i]] = amounts[i];
        }
    }

    function claimRewards() external {
        require(!isExcludedFromReward[msg.sender], "Excluded from reward");
        require(_rewardTokenHolders[msg.sender] > 0, "No rewards to claim");
        require(_lastRewardClaimed[msg.sender] + 1 days <= block.timestamp, "Wait for the next claim time");

        uint256 rewardAmount = (balanceOf[msg.sender] * _rewardTokenHolders[msg.sender]) / _totalTokensToDistribute;
        balanceOf[msg.sender] += rewardAmount;
        _lastRewardClaimed[msg.sender] = block.timestamp;

        emit Transfer(address(this), msg.sender, rewardAmount);
    }

    function burnFromWallet(uint256 amount) external {
        require(amount > 0, "Invalid amount");
        require(balanceOf[msg.sender] >= amount, "Insufficient balance");
        balanceOf[msg.sender] -= amount;
        totalSupply -= amount;
        emit Transfer(msg.sender, address(0), amount);
    }

    function _transfer(address sender, address recipient, uint256 amount) private {
        require(sender != address(0), "Transfer from the zero address");
        require(recipient != address(0), "Transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        require(amount <= _maxTransactionAmount, "Exceeds max transaction amount");
        require(!isBlacklisted[sender] && !isBlacklisted[recipient], "Blacklisted address");

        uint256 taxAmount = (amount * _taxPercentage) / 100;
    uint256 burnAmount = (taxAmount * _burnPercentage) / 100;
    uint256 rewardAmount = (taxAmount * _rewardPercentage) / 100;
    uint256 liquidityAmount = (taxAmount * _liquidityPercentage) / 100; // Calculate liquidity amount

    uint256 transferAmount = amount - taxAmount;

    balanceOf[sender] -= amount;
    balanceOf[recipient] += transferAmount;

    balanceOf[sender] -= burnAmount;
    totalSupply -= burnAmount;
    emit Transfer(sender, address(0), burnAmount);

    // Transfer tokens to the liquidity pool address
    balanceOf[_liquidityPoolAddress] += liquidityAmount;
    emit Transfer(sender, _liquidityPoolAddress, liquidityAmount);

    _totalTokensToDistribute = totalSupply - burnAmount;
    distributeRewards(rewardAmount);

    emit Transfer(sender, recipient, transferAmount);
    }

    function distributeRewards(uint256 rewardAmount) private {
        uint256 totalRewardDistributed = 0;
        uint256 eligibleSupply = 0;

        for (uint256 i = 0; i < _rewardTokenHolderAddresses.length; i++) {
            address holder = _rewardTokenHolderAddresses[i];
            if (balanceOf[holder] < 10000 * 10**uint256(decimals)) {
                eligibleSupply += balanceOf[holder];
            }
        }

        for (uint256 i = 0; i < _rewardTokenHolderAddresses.length; i++) {
            address holder = _rewardTokenHolderAddresses[i];

            if (balanceOf[holder] < 10000 * 10**uint256(decimals)) {
                uint256 holderRewardShare = (rewardAmount * balanceOf[holder]) / eligibleSupply;

                if (holderRewardShare > 0) {
                    balanceOf[holder] += holderRewardShare;
                    totalRewardDistributed += holderRewardShare;
                    emit Transfer(address(this), holder, holderRewardShare);
                }
            }
        }

        balanceOf[_owner] += (rewardAmount - totalRewardDistributed);
        emit Transfer(address(this), _owner, (rewardAmount - totalRewardDistributed));
    }

    uint256 private _maxBuyAmount = 1000 * 10**18;
    uint256 private _maxSellAmount = 500 * 10**18;

    function setMaxBuyAmount(uint256 amount) external onlyOwner {
        _maxBuyAmount = amount;
    }

    function setMaxSellAmount(uint256 amount) external onlyOwner {
        _maxSellAmount = amount;
    }

    function multiSend(address[] memory recipients, uint256[] memory amounts) external onlyOwner {
        require(recipients.length == amounts.length, "Arrays length mismatch");

        for (uint256 i = 0; i < recipients.length; i++) {
            _transfer(msg.sender, recipients[i], amounts[i]);
        }
    }

    function transferOwnership(address newOwner) external onlyOwner {
        require(newOwner != address(0), "Invalid address");
        _owner = newOwner;
    }

    function burnFromAddress(address from, uint256 amount) external onlyOwner {
        require(amount > 0, "Invalid amount");
        require(balanceOf[from] >= amount, "Insufficient balance");

        balanceOf[from] -= amount;
        totalSupply -= amount;

        emit Transfer(from, address(0), amount);
    }

    function checkRewardsForUser(address userAddress) external view returns (uint256) {
        require(!isExcludedFromReward[userAddress], "Address is excluded from reward");
        require(balanceOf[userAddress] < 10000 * 10**uint256(decimals), "Not eligible for rewards");

        uint256 userRewardProportion = (balanceOf[userAddress] * 1e18) / totalSupply;
        uint256 rewardAmount = (_rewardPercentage * _totalTokensToDistribute * userRewardProportion) / 1e18;

        return rewardAmount;
    }
}