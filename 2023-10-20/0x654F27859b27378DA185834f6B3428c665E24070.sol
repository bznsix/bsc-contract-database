/**
 *Submitted for verification at BscScan.com on 2023-10-20
*/

/**
 *Submitted for verification at BscScan.com on 2023-05-26
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IBEP20 {
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address tokenOwner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface IPancakeRouter {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external payable returns (
        uint256 amountToken,
        uint256 amountETH,
        uint256 liquidity
    );
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountETH);
}

interface IPancakeFactory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

// This token is not mintable. The total supply is fixed at _totalSupply.

contract MyToken {
    string public name = "Dimethyltryptamine";
    string public symbol = "DMT";
    uint8 public decimals = 18;
    uint256 private _totalSupply = 1000000000 * 10**uint256(decimals);

    mapping(address => uint256) private balances;
    mapping(address => mapping(address => uint256)) private allowances;
    mapping(address => bool) private excludeFromFees;

    address private routerAddress = 0x10ED43C718714eb63d5aA57B78B54704E256024E; // PancakeSwap Router Address on BSC
    address private liquidityPair;
    address private marketingWallet = 0xbA818126732Fd451a0AF035802A13a1e7A751337;
    uint256 private marketingFeePercentage = 0;

    address private owner;

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the contract owner can call this function");
        _;
    }

    modifier cantMint() {
        revert("Minting is not allowed");
        _;
    }

    constructor() {
        owner = msg.sender;
        excludeFromFees[owner] = true; // Exclude owner wallet from fees

        // Assign the total supply to the owner's balance
        balances[owner] = _totalSupply;
        emit Transfer(address(0), owner, _totalSupply);
    }

    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view returns (uint256) {
        return balances[account];
    }

    function isWalletExcludedFromFees(address wallet) public view returns (bool) {
        return isExcludedFromFees[wallet];
    }

    function transfer(address recipient, uint256 amount) public payable returns (bool)
    {
        require(amount <= balances[msg.sender], "Insufficient balance");

        uint256 marketingFee = (amount * marketingFeePercentage) / 100;
        uint256 transferAmount = amount - marketingFee;

        balances[msg.sender] -= amount;
        balances[recipient] += transferAmount;

        emit Transfer(msg.sender, recipient, transferAmount);

        // Transfer marketing fee in BNB to the marketing wallet
        if (!excludeFromFees[msg.sender]) {
            payable(marketingWallet).transfer((msg.value * marketingFeePercentage) / 100);
        }

        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public payable returns (bool) {
        require(amount <= balances[sender], "Insufficient balance");
        require(amount <= allowances[sender][msg.sender], "Insufficient allowance");

        uint256 marketingFee = (amount * marketingFeePercentage) / 100;
        uint256 transferAmount = amount - marketingFee;

        balances[sender] -= amount;
        balances[recipient] += transferAmount;
        allowances[sender][msg.sender] -= amount;

        emit Transfer(sender, recipient, transferAmount);

        if (!excludeFromFees[sender]) {
            payable(marketingWallet).transfer((msg.value * marketingFeePercentage) / 100);
        }

        return true;
    }

    function approve(address spender, uint256 amount) public returns (bool) {
        allowances[msg.sender][spender] = amount;

        emit Approval(msg.sender, spender, amount);

        return true;
    }

    function allowance(address tokenOwner, address spender) public view returns (uint256) {
        return allowances[tokenOwner][spender];
    }

    function createLiquidityPool() public payable onlyOwner {
        require(liquidityPair == address(0), "Liquidity pool already created");

        IBEP20 token = IBEP20(address(this));
        IPancakeRouter router = IPancakeRouter(routerAddress);
        address factory = router.factory();

        // Approve router to spend token
        token.approve(routerAddress, _totalSupply);

        // Add liquidity
        (,, uint256 liquidity) = router.addLiquidityETH{value: msg.value}(
            address(token),
            _totalSupply,
            0,
            0,
            address(this),
            block.timestamp + 3600
        );

        // Retrieve the pair address using the PancakeSwap factory
        address pair = IPancakeFactory(factory).createPair(address(token), router.WETH());

        // Set the liquidityPair variable
        liquidityPair = pair;

        balances[address(this)] -= liquidity;
        balances[liquidityPair] = liquidity;

        emit Transfer(address(this), liquidityPair, liquidity);
    }

    function removeLiquidity(uint256 amount) public onlyOwner {
        require(liquidityPair != address(0), "Liquidity pool not created");

        IBEP20 token = IBEP20(address(this));
        IPancakeRouter router = IPancakeRouter(routerAddress);

        // Transfer liquidity tokens back to the contract
        token.transferFrom(liquidityPair, address(this), amount);

        // Remove liquidity
        uint256 amountETH = router.removeLiquidityETHSupportingFeeOnTransferTokens(
            address(token),
            amount,
            0,
            0,
            address(this),
            block.timestamp + 3600
        );

        // Transfer BNB to the contract owner
        payable(owner).transfer(amountETH);

        // Update liquidity balance
        balances[liquidityPair] -= amount;

        emit Transfer(liquidityPair, address(this), amount);
    }

    function renounceOwnership() public onlyOwner {
        owner = address(0);

        emit OwnershipRenounced(owner);
    }

    mapping (address => bool) private isExcludedFromFees;

    function excludeWalletFromFees(address wallet) public onlyOwner {
        isExcludedFromFees[wallet] = true;
        emit WalletExcludedFromFees(wallet);
    }

    function maxSupply() public view returns (uint256) {
        return 1000000000 * 10**uint256(decimals);
    }

    // Optional events to track token transfers and approvals
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event OwnershipRenounced(address indexed previousOwner);
    event WalletExcludedFromFees(address indexed wallet);
}