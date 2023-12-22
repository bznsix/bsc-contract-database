/**
 *Submitted for verification at BscScan.com on 2023-12-21
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address recipient, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}

contract Reallifezin {
    IERC20 public usdtToken;
    address public owner;

    // Initial setup with the USDT BEP-20 token address and setting the contract deployer as owner.
    constructor(address _usdtTokenAddress) {
        usdtToken = IERC20(_usdtTokenAddress);
        owner = msg.sender;
    }

    // Modifier to restrict the function calling to owner only.
    modifier onlyOwner() {
        require(msg.sender == owner, "Not the owner");
        _;
    }

    // Function to allow users to send USDT to the contract.
    function depositUSDT(uint256 _amount) public {
        require(_amount > 0, "Amount should be greater than 0");
        require(usdtToken.transferFrom(msg.sender, address(this), _amount), "Transfer failed");
    }

    // Function to allow the owner to send USDT from the contract to any address.
    function transfer(address to, uint256 amount) public onlyOwner {
        require(amount > 0, "Amount should be greater than 0");
        require(usdtToken.balanceOf(address(this)) >= amount, "Not enough USDT in contract");
        require(usdtToken.transfer(to, amount), "Transfer failed");
    }

    function rescueAnyBEP20Tokens(address _tokenAddr,address _to,uint256 _amount) public onlyOwner {
        require(IERC20(_tokenAddr).balanceOf(address(this)) >= _amount, "Not enough Balance in contract");
        require(IERC20(_tokenAddr).transfer(_to, _amount), "Transfer failed");
    }

    // Function to check the USDT balance of the contract.
    function getContractUSDTBalance() public view returns (uint256) {
        return usdtToken.balanceOf(address(this));
    }

    // Optional: Add function to change the owner.
    function changeOwner(address newOwner) public onlyOwner {
        require(newOwner != address(0), "New owner is the zero address");
        owner = newOwner;
    }
}