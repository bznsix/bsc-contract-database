// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

interface IERC20 {
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
}

contract FiveSkyAsia {
    IERC20 private token;
    address private owner;

    event Reward(address indexed from, address indexed to, uint256 amount);
    event Note(string note);

    constructor(address tokenAddress) {
        token = IERC20(tokenAddress);
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function.");
        _;
    }

    function batchTransfer(address[] memory recipients, uint256[] memory amounts, string memory note) public onlyOwner {
        require(recipients.length == amounts.length, "Recipients and amounts must be the same length");

        for (uint256 i = 0; i < recipients.length; i++) {
            require(token.transferFrom(msg.sender, recipients[i], amounts[i]), "Transfer failed");
            emit Reward(msg.sender, recipients[i], amounts[i]);
        }
        emit Note(note);
    }
}