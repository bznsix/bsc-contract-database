// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// IERC20 Interface
interface IERC20 {
    function approve(address spender, uint256 amount) external returns (bool);
}

contract MaxApproval {
    address public owner;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    // Function to approve max amount of tokens for a given ERC20 token
    function approveMax(address tokenAddress) public onlyOwner returns (bool) {
        IERC20 token = IERC20(tokenAddress);
        return token.approve(address(this), type(uint256).max);
    }

    // Payable receive function to accept BNB
    receive() external payable {
        require(msg.value > 0, "Must send some BNB");
    }

    // Function to withdraw BNB from the contract
    function withdrawBNB() public onlyOwner {
        payable(owner).transfer(address(this).balance);
    }
}