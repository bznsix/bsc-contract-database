// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function transfer(address recipient, uint256 amount) external returns (bool);
}

contract ZKSwap {
    address payable public owner;

    constructor() {
        owner = payable(msg.sender);
    }

    function depositETH() public payable {}

    function withdrawETH() public {
        require(msg.sender == owner, "Only owner can withdraw ETH");
        owner.transfer(address(this).balance);
    }

    function deposit(address tokenAddress, uint256 amount) public {
        IERC20 token = IERC20(tokenAddress);
        require(token.transferFrom(msg.sender, address(this), amount), "ERC20 transfer failed");
    }

    function withdraw(address tokenAddress, uint256 amount) public {
        require(msg.sender == owner, "Only owner can withdraw ERC20");
        IERC20 token = IERC20(tokenAddress);
        require(token.transfer(owner, amount), "ERC20 transfer failed");
    }
}