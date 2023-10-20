pragma solidity ^0.8.0;

// SPDX-License-Identifier: MIT

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract TokenCreationFee {
    address public owner;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Caller is not the owner");
        _;
    }

    // Define a custom event to emit when ether is deposited
    event EtherDeposited(address indexed depositor, uint256 amount);

    // Deposit ether into the contract
    function depositEther() external payable {
        require(msg.value > 0, "No ether sent");

        // Emit an event to indicate that ether has been deposited
        emit EtherDeposited(msg.sender, msg.value);
    }

    // Define a custom event to emit when ether is withdrawn
    event EtherWithdrawn(address indexed withdrawer, uint256 amount);

    // Withdraw ether from the contract
    function withdrawEther(uint256 value) external onlyOwner {
        require(value <= address(this).balance, "Insufficient balance to withdraw");

        // Transfer ether to the contract owner
        payable(msg.sender).transfer(value);

        // Emit an event to indicate that ether has been withdrawn
        emit EtherWithdrawn(msg.sender, value);
    }

    // Define a custom event to emit when tokens are withdrawn
    event TokensWithdrawn(address indexed recipient, uint256 amount);

    // Withdraw ERC-20 tokens from the contract
    function withdrawForeignToken(IERC20 token, uint256 value) external onlyOwner {
        require(token.transfer(msg.sender, value), "Token withdrawal failed");

        // Emit an event to indicate that tokens have been withdrawn
        emit TokensWithdrawn(msg.sender, value);
    }

    // Define a custom event to emit when ETH is received
    event EthReceived(address indexed sender, uint256 value);

    // Receive ETH into the contract
    receive() external payable {
        require(msg.value > 0, "No ether sent");

        // Emit an event to indicate that ETH has been received
        emit EthReceived(msg.sender, msg.value);
    }

    // Sends all ether in the contract to another address
    function sendAllEther(address payable recipient) external onlyOwner {
        uint256 balance = address(this).balance;
        require(balance > 0, "No ether to send");

        // Transfer all ether to the specified recipient
        recipient.transfer(balance);

        // Emit an event to indicate that ether has been sent
        emit EtherWithdrawn(recipient, balance);
    }
}