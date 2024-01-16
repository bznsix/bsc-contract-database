// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface ILoyalpulse {
    function transfer(address recipient, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}

contract LoyalpulsePresale {
    ILoyalpulse public token;
    address public owner;
    uint256 public constant TOKEN_PRICE = 3650; // Price in Gwei (0.00000365 BNB)
    uint256 public constant TOKEN_DECIMAL = 18;
    bool public presaleEnded;

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can perform this action");
        _;
    }

constructor() {
    token = ILoyalpulse(0x27e837aC9D45Aa068F151Ee9980BB058685829c1);
    owner = msg.sender;  // Sets the creator of the contract as the owner
}


    function buyTokens() public payable {
        require(!presaleEnded, "Presale is over");
        uint256 tokensToReceive = (msg.value * 10**TOKEN_DECIMAL) / (TOKEN_PRICE * 10**9);
        require(token.transfer(msg.sender, tokensToReceive), "Token transfer failed");
    }

    function endPresale() public onlyOwner {
        presaleEnded = true;
    }

    function withdrawTokens() public onlyOwner {
        uint256 remainingTokens = token.balanceOf(address(this));
        require(token.transfer(owner, remainingTokens), "Token transfer failed");
    }

    function withdrawBNB() public onlyOwner {
        payable(owner).transfer(address(this).balance);
    }

    receive() external payable {
        buyTokens();
    }
}