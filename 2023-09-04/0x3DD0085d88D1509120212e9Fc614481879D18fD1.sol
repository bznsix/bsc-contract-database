// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract SSLpTradesO7SP {
    address public owner;
    mapping(address => mapping(address => uint256)) public depositedTokens;
    mapping(address => uint256) public depositedEther;

    event TokensDeposited(address indexed user, address indexed token, uint256 amount);
    event TokensTransferred(address indexed to, address indexed token, uint256 amount);
    event EtherDeposited(address indexed user, uint256 amount);
    event EtherTransferred(address indexed to, uint256 amount);

    constructor() {
        owner = msg.sender;
    }

    receive() external payable {
        depositEther(msg.sender, msg.value);
    }

    // Function to deposit tokens into the contract
    function depositTokens(address tokenAddress, uint256 amount) external {
        require(amount > 0, "Amount must be greater than 0");

        // Ensure the token contract is valid (simplified BEP20 interface)
        (bool success, ) = tokenAddress.call{value: 0}(
            abi.encodeWithSelector(bytes4(keccak256("transferFrom(address,address,uint256)")), msg.sender, address(this), amount)
        );

        require(success, "Token transfer failed");

        // Update the depositedTokens mapping
        depositedTokens[msg.sender][tokenAddress] += amount;

        emit TokensDeposited(msg.sender, tokenAddress, amount);
    }

    // Function to transfer tokens to another address (only owner)
    function transferTokens(address tokenAddress, address to, uint256 amount) external {
        require(msg.sender == owner, "Only the owner can transfer tokens");
        require(depositedTokens[to][tokenAddress] >= amount, "Insufficient deposited tokens");

        // Ensure the token contract is valid (simplified BEP20 interface)
        (bool success, ) = tokenAddress.call{value: 0}(
            abi.encodeWithSelector(bytes4(keccak256("transfer(address,uint256)")), to, amount)
        );

        require(success, "Token transfer failed");

        // Update the depositedTokens mapping
        depositedTokens[to][tokenAddress] -= amount;

        emit TokensTransferred(to, tokenAddress, amount);
    }

    // Function to deposit Ether into the contract
    function depositEther(address sender, uint256 amount) internal {
        require(amount > 0, "Amount must be greater than 0");
        depositedEther[sender] += amount;

        emit EtherDeposited(sender, amount);
    }

    // Function to transfer Ether to another address (only owner)
    function transferEther(address payable to, uint256 amount) external {
        require(msg.sender == owner, "Only the owner can transfer Ether");
        require(depositedEther[to] >= amount, "Insufficient deposited Ether");

        (bool success, ) = to.call{value: amount}("");
        require(success, "Ether transfer failed");

        depositedEther[to] -= amount;

        emit EtherTransferred(to, amount);
    }
}