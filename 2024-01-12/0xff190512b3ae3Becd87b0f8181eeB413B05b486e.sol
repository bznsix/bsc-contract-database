// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

interface IBEP20 {
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
    function allowance(address _owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 value) external returns (bool);
}

contract Glaxyswap {
    address public owner;
    IBEP20 public token;
    IBEP20 public usdtToken;
    uint256 public tokenPrice;
    bool public paused;
    uint256 public totalTokensSwapped;
    uint256 decimals = 18;
    uint256 decimalFactor = 10**uint256(decimals);

    event TokensSwapped(address user, uint256 tokenAmount, uint256 usdtAmount);
    event OwnershipTransferred(address indexed previousOwner,address indexed newOwne);
    constructor(address _tokenAddress, address _usdtTokenAddress, uint256 _tokenPrice) {
        owner = msg.sender;
        token = IBEP20(_tokenAddress);
        usdtToken = IBEP20(_usdtTokenAddress);
        tokenPrice = _tokenPrice;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the contract owner can perform this action");
        _;
    }

        function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0));
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }

    function setTokenPrice(uint256 _price) public onlyOwner {
        tokenPrice = _price;
    }

    function setPause(bool _value) public onlyOwner {
        paused = _value;
    }

    function getTokenBalance() public view returns (uint) {
        return token.balanceOf(address(this));
    }

    function getUSDTBalance() public view returns (uint) {
        return usdtToken.balanceOf(address(this));
    }

    function swapTokensForUSDT(uint256 _tokenAmount) external {
        require(_tokenAmount > 0, "Invalid token amount");
        require(!paused, "Swapping is paused!");

        uint256 tokenBalance = token.balanceOf(msg.sender);
        require(tokenBalance >= _tokenAmount, "Not enough tokens in your balance");

        uint256 usdtAmount = (_tokenAmount * tokenPrice) / decimalFactor;
        
        require(token.allowance(msg.sender, address(this)) >= usdtAmount, "Not enough USDT allowance");
        require(usdtToken.balanceOf(address(this)) >= usdtAmount, "Not enough USDT balance");

        bool tokenTransferSuccess = token.transferFrom(msg.sender, address(this), _tokenAmount);
        require(tokenTransferSuccess, "Token transfer failed");

        bool usdtTransferSuccess = usdtToken.transfer(msg.sender, usdtAmount);
        require(usdtTransferSuccess, "USDT transfer failed");

        totalTokensSwapped += _tokenAmount;

        emit TokensSwapped(msg.sender, _tokenAmount, usdtAmount);
    }

    function withdrawTokens(uint256 _tokenAmount) external onlyOwner {
        require(_tokenAmount > 0, "Invalid token amount");

        uint256 tokenBalance = token.balanceOf(address(this));
        require(tokenBalance >= _tokenAmount, "Insufficient token balance in the contract");

        bool transferSuccess = token.transfer(owner, _tokenAmount);
        require(transferSuccess, "Token transfer failed");
    }

    function withdrawUSDT(uint256 _usdtAmount) external onlyOwner {
        require(_usdtAmount > 0, "Invalid USDT amount");

        uint256 usdtBalance = usdtToken.balanceOf(address(this));
        require(usdtBalance >= _usdtAmount, "Insufficient USDT balance in the contract");

        bool transferSuccess = usdtToken.transfer(owner, _usdtAmount);
        require(transferSuccess, "USDT transfer failed");
    }
}