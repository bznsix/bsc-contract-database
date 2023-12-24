// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address to, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}

contract Crowdsale {
    IERC20 public token;
    uint256 public price; // Number of tokens per 1 BNB (with decimals)
    uint256 public maxOrderPerAddress;
    address public owner;
    address private withdrawAddress;
    mapping(address => uint256) public amountPurchased;

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    constructor(address _token, uint256 _price, uint256 _maxOrder, address _withdrawAddress) {
        token = IERC20(_token);
        price = _price; // Adjust this considering the decimals of the token
        maxOrderPerAddress = _maxOrder;
        owner = msg.sender;
        withdrawAddress = _withdrawAddress;
    }

    function setPrice(uint256 _newPrice) external onlyOwner {
        price = _newPrice * 10**18; // Adjust for token decimals
    }

    function setMaxOrderPerAddress(uint256 _maxOrder) external onlyOwner {
        maxOrderPerAddress = _maxOrder;
    }

    function withdrawTokens(uint256 _amount) external onlyOwner {
        require(token.transfer(withdrawAddress, _amount), "Token transfer failed");
    }

    function setWithdrawAddress(address _withdrawAddress) external onlyOwner {
        withdrawAddress = _withdrawAddress;
    }

    function withdrawBNB(uint256 amount) external onlyOwner {
        require(amount <= address(this).balance, "Insufficient balance in contract");
        payable(withdrawAddress).transfer(amount);
    }

    // Function to self-destruct the contract
    function destroyContract() external onlyOwner {
        selfdestruct(payable(owner));
    }

    // Fallback function to accept BNB
    receive() external payable {
        uint256 amount = price * msg.value / 1 ether; // Adjusting for decimal places
        require(amountPurchased[msg.sender] + amount <= maxOrderPerAddress, "Exceeds max order per address");
        require(amount <= token.balanceOf(address(this)), "Insufficient token balance in contract");

        amountPurchased[msg.sender] += amount;
        require(token.transfer(msg.sender, amount), "Token transfer failed");
    }
}