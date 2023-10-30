// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function balanceOf(address account) external view returns (uint256);

    function transfer(
        address recipient,
        uint256 amount
    ) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);
}

contract TokenPresale {
    IERC20 public token;
    IERC20 public usdt = IERC20(0x55d398326f99059fF775485246999027B3197955);
    IERC20 public busd = IERC20(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56);

    address public owner;
    address public projectWallet;
    bool public isSaleActive = false;
    uint256 public stage;
    uint256 public minimumPurchaseAmount = 0; // Initial value set to 0
    uint256[] internal prices = [666, 333, 125]; // Added the prices array

    event TokensPurchased(
        address indexed buyer,
        uint256 amountSpent,
        uint256 tokensReceived,
        uint256 pricePerToken
    );

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    modifier saleIsActive() {
        require(isSaleActive, "Sale is not active");
        _;
    }

    constructor(address _token, address _projectWallet) {
        token = IERC20(_token);
        owner = msg.sender;
        projectWallet = _projectWallet;
        stage = 0;
    }

    function startSale() external onlyOwner {
        isSaleActive = true;
    }

    function stopSale() external onlyOwner {
        isSaleActive = false;
    }

    // Function to set the minimum purchase amount to 49
    function setMinimumPurchaseAmount() external onlyOwner {
        minimumPurchaseAmount = 49;
    }

    function buyWithUSDT(uint256 usdtAmount) public saleIsActive {
        usdtAmount *= 1e6; // Multiply the input by 1e6 for 6 decimals

        require(
            usdtAmount >= minimumPurchaseAmount * 1e6,
            "Purchase amount too low"
        );
        require(stage < prices.length, "Presale has ended");
        uint256 tokensToBuy = usdtAmount * prices[stage];
        require(
            token.balanceOf(address(this)) >= tokensToBuy,
            "Not enough tokens left for sale"
        );

        usdt.transferFrom(msg.sender, projectWallet, usdtAmount);
        token.transfer(msg.sender, tokensToBuy);

        emit TokensPurchased(
            msg.sender,
            usdtAmount,
            tokensToBuy,
            prices[stage]
        );
    }

    function buyWithBUSD(uint256 busdAmount) public saleIsActive {
        busdAmount *= 1e6; // Multiply the input by 1e6 for 6 decimals

        require(
            busdAmount >= minimumPurchaseAmount * 1e6,
            "Purchase amount too low"
        );
        require(stage < prices.length, "Presale has ended");
        uint256 tokensToBuy = busdAmount * prices[stage];
        require(
            token.balanceOf(address(this)) >= tokensToBuy,
            "Not enough tokens left for sale"
        );

        busd.transferFrom(msg.sender, projectWallet, busdAmount);
        token.transfer(msg.sender, tokensToBuy);

        emit TokensPurchased(
            msg.sender,
            busdAmount,
            tokensToBuy,
            prices[stage]
        );
    }

    function nextStage() public onlyOwner {
        require(stage < prices.length, "Presale already at final stage");
        stage++;
    }

    // Function to withdraw all remaining tokens from the contract
    function withdrawTokens() public onlyOwner {
        uint256 amount = token.balanceOf(address(this));
        token.transfer(owner, amount);
    }
}
