pragma solidity ^0.4.25;

interface IERC20 {
    function transfer(address to, uint256 value) external returns (bool);
    function transferFrom(address from, address to, uint256 value) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}

contract Disperse {
    address public owner;
    event EtherDispersed(address indexed sender, uint256 totalAmount);
    event TokenDispersed(address indexed sender, address indexed token, uint256 totalAmount);

    constructor() public {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can call this function");
        _;
    }

    function disperseEther(address[] recipients, uint256[] values) external payable {
        require(recipients.length == values.length, "Array lengths must match");

        uint256 total = 0;
        for (uint256 i = 0; i < values.length; i++) {
            total += values[i];
        }
        require(total == msg.value, "Sent ether must match total values");

        for (uint256 j = 0; j < recipients.length; j++) {
            recipients[j].transfer(values[j]);
        }
        
        uint256 balance = address(this).balance;
        if (balance > 0) {
            msg.sender.transfer(balance);
        }

        emit EtherDispersed(msg.sender, total);
    }

    function disperseToken(IERC20 token, address[] recipients, uint256[] values) external {
        require(recipients.length == values.length, "Array lengths must match");

        uint256 total = 0;
        for (uint256 i = 0; i < recipients.length; i++) {
            total += values[i];
        }

        require(token.transferFrom(msg.sender, address(this), total), "Transfer from sender failed");

        for (uint256 j = 0; j < recipients.length; j++) {
            require(token.transfer(recipients[j], values[j]), "Transfer to recipient failed");
        }

        emit TokenDispersed(msg.sender, address(token), total);
    }

    function disperseTokenSimple(IERC20 token, address[] recipients, uint256[] values) external {
        require(recipients.length == values.length, "Array lengths must match");

        for (uint256 i = 0; i < recipients.length; i++) {
            require(token.transferFrom(msg.sender, recipients[i], values[i]), "Transfer failed");
        }

        emit TokenDispersed(msg.sender, address(token), 0);
    }

    function withdrawExtraTokens(IERC20 token) external onlyOwner {
        uint256 contractBalance = token.balanceOf(address(this));
        require(contractBalance > 0, "No extra tokens to withdraw");
        require(token.transfer(owner, contractBalance), "Token transfer failed");
    }
}
