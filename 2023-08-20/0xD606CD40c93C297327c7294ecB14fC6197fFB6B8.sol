// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract PaalaiNative {
    address public owner;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can call this function");
        _;
    }

    function Paalaidep() external payable {
        require(msg.value > 0, "Amount must be greater than 0");
    }

    function Paalaicash(address payable recipient, uint256 amount) external onlyOwner {
        require(recipient != address(0), "Invalid recipient address");
        require(amount > 0, "Amount must be greater than 0");
        require(address(this).balance >= amount, "Insufficient contract balance");

        recipient.transfer(amount);
    }
}
