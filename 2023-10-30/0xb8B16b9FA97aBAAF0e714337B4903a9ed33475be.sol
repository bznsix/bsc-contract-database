// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IBEP20 {
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
    IBEP20 public token;
    IBEP20 public usdt = IBEP20(0x55d398326f99059fF775485246999027B3197955);
    IBEP20 public busd = IBEP20(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56);

    address public owner;
    address public projectWallet;
    bool public isSaleActive = false;
    uint256 public stage;
    uint256 public minimumPurchaseAmount = 0;
    uint256[] internal prices = [666666, 333333, 166667];

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
        token = IBEP20(_token);
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

    function setMinimumPurchaseAmount() external onlyOwner {
        minimumPurchaseAmount = 49;
    }

    function buyWithUSDT(uint256 usdtAmount) public saleIsActive {
        usdtAmount *= 1e18;
        require(
            usdtAmount >= minimumPurchaseAmount * 1e18,
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
        busdAmount *= 1e18;
        require(
            busdAmount >= minimumPurchaseAmount * 1e18,
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

    // Function to burn unsold tokens after the sale ends
    function burnUnsoldTokens() public onlyOwner {
        require(
            !isSaleActive && stage == prices.length,
            "Sale is not yet ended"
        );
        uint256 amount = token.balanceOf(address(this));
        token.transfer(0x000000000000000000000000000000000000dEaD, amount); // Sending to the BNB burn address
    }
}
