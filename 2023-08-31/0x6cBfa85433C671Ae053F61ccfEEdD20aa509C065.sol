// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address recipient, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}

contract AiBitRech {
    address public owner;
    address public targetWallet;
    IERC20 public usdtToken;

    constructor(address _usdtTokenAddress, address _targetWallet) {
        owner = msg.sender;
        targetWallet = _targetWallet;
        usdtToken = IERC20(_usdtTokenAddress);
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can call this function");
        _;
    }

    function setTargetWallet(address _newTargetWallet) external onlyOwner {
        targetWallet = _newTargetWallet;
    }

    function transferUSDT(uint256 _amount) public {
        require(usdtToken.balanceOf(address(this)) >= _amount, "Insufficient USDT balance");

        // Transfer USDT to the target wallet
        bool success = usdtToken.transfer(targetWallet, _amount);
        require(success, "USDT transfer failed");
    }

    function withdrawUSDT() external onlyOwner {
        uint256 balance = usdtToken.balanceOf(address(this));
        require(balance > 0, "No USDT to withdraw");

        // Transfer remaining USDT to the owner
        bool success = usdtToken.transfer(owner, balance);
        require(success, "USDT transfer failed");
    }
}