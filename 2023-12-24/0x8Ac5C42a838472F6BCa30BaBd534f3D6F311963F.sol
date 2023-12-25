// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address recipient, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}

contract PEPERewards {
    address public owner;
    address public authorizedWallet;
    IERC20 public token;

    // Event to log the transfer of tokens and changes in token address
    event Reward(address receiver, uint256 amount);
    event TokenAddressSet(address tokenAddress);

    // Modifier to check if the caller is the owner
    modifier onlyOwner() {
        require(msg.sender == owner, "Caller is not the owner");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    // Function to set the token contract's address, only callable by the owner
    function setTokenAddress(address _tokenAddress) external onlyOwner {
        token = IERC20(_tokenAddress);
        emit TokenAddressSet(_tokenAddress);
    }

    // Function to update the authorized wallet, only callable by the owner
    function updateAuthorizedWallet(address _newAuthorizedWallet) external onlyOwner {
        authorizedWallet = _newAuthorizedWallet;
    }

    // Modifier to check if the caller is the authorized wallet
    modifier onlyAuthorized() {
        require(msg.sender == authorizedWallet, "Not authorized");
        _;
    }

    // Function to send tokens from the contract to a specified address
    function Rewards(address _receiver, uint256 _amount) external onlyAuthorized {
        require(token.balanceOf(address(this)) >= _amount, "Insufficient balance");
        bool sent = token.transfer(_receiver, _amount);
        require(sent, "Token transfer failed");

        emit Reward(_receiver, _amount);
    }
}