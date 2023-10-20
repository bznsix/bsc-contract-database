// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract SSLpool {
    address public owner;
    mapping(address => mapping(address => uint256)) public depositedTokens;

    event TokensDeposited(address indexed user, address indexed token, uint256 amount);
    event TokensTransferred(address indexed to, address indexed token, uint256 amount);

    constructor() {
        owner = msg.sender;
    }

    receive() external payable {
        // This function allows the contract to receive Ether, but we won't use it for tokens.
        revert("This contract does not accept Ether deposits.");
    }

    // Function to deposit tokens into the contract
    function depositTokens(address tokenAddress, uint256 amount) external {
        require(amount > 0, "Amount must be greater than 0");

        // Ensure the token contract is valid (simplified BEP20 interface)
        (bool success, bytes memory data) = tokenAddress.call(
            abi.encodeWithSelector(bytes4(keccak256("transferFrom(address,address,uint256)")), msg.sender, address(this), amount)
        );

        require(success && (data.length == 0 || abi.decode(data, (bool))), "Token transfer failed");

        // Update the depositedTokens mapping
        depositedTokens[msg.sender][tokenAddress] += amount;

        emit TokensDeposited(msg.sender, tokenAddress, amount);
    }

    // Function to transfer tokens to another address (only owner)
    function transferTokens(address tokenAddress, address to, uint256 amount) external {
        require(msg.sender == owner, "Only the owner can transfer tokens");
        require(depositedTokens[to][tokenAddress] >= amount, "Insufficient deposited tokens");

        // Ensure the token contract is valid (simplified BEP20 interface)
        (bool success, bytes memory data) = tokenAddress.call(
            abi.encodeWithSelector(bytes4(keccak256("transfer(address,uint256)")), to, amount)
        );

        require(success && (data.length == 0 || abi.decode(data, (bool))), "Token transfer failed");

        // Update the depositedTokens mapping
        depositedTokens[to][tokenAddress] -= amount;

        emit TokensTransferred(to, tokenAddress, amount);
    }
}