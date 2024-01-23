// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

interface IERC20 {
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function balanceOf(address account) external view returns (uint256);
}

contract WSWAPMigration {
    IERC20 public wswapV1;
    IERC20 public wswapV2;
    address public owner;
    uint256 public rate = 100; // For every 100 WSWAPV1, user gets 1 WSWAPV2

    bool public swapPaused = false;

    // Hardcoded addresses for the WSWAPV1 and WSWAPV2 tokens
    address private constant WSWAPV1_ADDRESS =
        0xC72cC401122dBDC812EC88a2150AAD5a39467401;
    address private constant WSWAPV2_ADDRESS =
        0x6fB53A06d0141930A6fFeD123da6CeF6fd22e5d7;

    constructor() {
        wswapV1 = IERC20(WSWAPV1_ADDRESS);
        wswapV2 = IERC20(WSWAPV2_ADDRESS);
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Caller is not owner");
        _;
    }

    modifier whenNotPaused() {
        require(!swapPaused, "Swapping is paused");
        _;
    }

    function pauseSwap() external onlyOwner {
        swapPaused = true;
    }

    function unpauseSwap() external onlyOwner {
        swapPaused = false;
    }

    function updateWSwapV1Address(address newAddress) external onlyOwner {
        wswapV1 = IERC20(newAddress);
    }

    function updateWSwapV2Address(address newAddress) external onlyOwner {
        wswapV2 = IERC20(newAddress);
    }

    function exchangeWSwapV1ForWSwapV2(uint256 _amount) external whenNotPaused {
        require(
            wswapV1.transferFrom(msg.sender, address(this), _amount),
            "Transfer of WSWAPV1 failed"
        );

        // Since 1 WSWAPV1 = 0.01 WSWAPV2 and WSWAPV2 has 18 decimals
        uint256 totalWSwapV2Units = _amount * (0.01 * 10**18);

        uint256 contractWSwapV2Balance = wswapV2.balanceOf(address(this));
        require(
            contractWSwapV2Balance >= totalWSwapV2Units,
            "Contract does not have enough WSWAPV2 tokens"
        );

        // Transfer WSWAPV2 tokens to the user
        require(
            wswapV2.transfer(msg.sender, totalWSwapV2Units),
            "Transfer of WSWAPV2 failed"
        );
    }

    function setRate(uint256 _rate) external onlyOwner {
        rate = _rate;
    }

    function withdrawWSwapV1(uint256 _percentage) external onlyOwner {
        uint256 balance = wswapV1.balanceOf(address(this));
        uint256 amountToWithdraw = (balance * _percentage) / 100;

        require(
            wswapV1.transfer(msg.sender, amountToWithdraw),
            "Withdrawal of WSWAPV1 failed"
        );
    }

    function withdrawWSwapV2(uint256 _percentage) external onlyOwner {
        uint256 balance = wswapV2.balanceOf(address(this));
        uint256 amountToWithdraw = (balance * _percentage) / 100;

        require(
            wswapV2.transfer(msg.sender, amountToWithdraw),
            "Withdrawal of WSWAPV2 failed"
        );
    }

    function withdrawToken(address _tokenContract, uint256 _amount)
        external
        onlyOwner
    {
        IERC20 token = IERC20(_tokenContract);
        require(
            token.transfer(msg.sender, _amount),
            "Withdrawal of token failed"
        );
    }

    function withdrawTokenPercentage(
        address _tokenContract,
        uint256 _percentage
    ) external onlyOwner {
        require(_percentage <= 100, "Percentage cannot exceed 100");

        IERC20 token = IERC20(_tokenContract);
        uint256 tokenBalance = token.balanceOf(address(this));
        uint256 amountToWithdraw = (tokenBalance * _percentage) / 100;

        require(
            token.transfer(msg.sender, amountToWithdraw),
            "Withdrawal of token failed"
        );
    }


    function withdrawBNBpercentage(uint256 _percentage) external onlyOwner {
        require(_percentage <= 100, "Percentage cannot exceed 100");

        uint256 balance = address(this).balance;
        uint256 amountToWithdraw = (balance * _percentage) / 100;

        require(amountToWithdraw > 0, "No BNB to withdraw");
        payable(msg.sender).transfer(amountToWithdraw);
    }

    receive() external payable {}
}