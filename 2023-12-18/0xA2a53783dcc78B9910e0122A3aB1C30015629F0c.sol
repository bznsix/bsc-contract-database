pragma solidity ^0.8.0;

contract BNBDistributor {
    address public owner;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner, "Caller is not the owner");
        _;
    }

    function distributeBNB(address payable[] memory recipients, uint256[] memory amounts) external onlyOwner {
        require(recipients.length == amounts.length, "The length of recipients and amounts must be equal");

        for (uint i = 0; i < recipients.length; i++) {
            require(address(this).balance >= amounts[i], "Not enough balance to send");
            recipients[i].transfer(amounts[i]);
        }
    }

    function withdrawAll() external onlyOwner {
        payable(msg.sender).transfer(address(this).balance);
    }

    receive() external payable {}
}