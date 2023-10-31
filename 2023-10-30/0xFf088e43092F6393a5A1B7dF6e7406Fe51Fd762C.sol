// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}

contract TokenSale {
    address public owner;
    IERC20 public token; // 这是您要出售的代币
    IERC20 public usdt; // 假设您使用的是USDT作为支付方式
    uint256 public rate; // 1 USDT 可以买到多少代币
    uint256 public minPurchase; // 最小购买量（USDT）
    uint256 public maxPurchase; // 最大购买量（USDT）

    constructor(address _token, address _usdt, uint256 _rate) {
        owner = msg.sender;
        token = IERC20(_token);
        usdt = IERC20(_usdt);
        rate = _rate;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    function setRate(uint256 _rate) external onlyOwner {
        rate = _rate;
    }

    function setPurchaseLimits(uint256 _min, uint256 _max) external onlyOwner {
        require(_min <= _max, "Min should not be greater than max");
        minPurchase = _min;
        maxPurchase = _max;
    }

    function setToken(address _token) external onlyOwner {
        token = IERC20(_token);
    }

    function buyTokens(uint256 usdtAmount) external {
        require(usdtAmount >= minPurchase && usdtAmount <= maxPurchase, "Invalid purchase amount");
        
        uint256 tokenAmount = usdtAmount * rate;
        
        // 用户支付 USDT
        require(usdt.transferFrom(msg.sender, address(this), usdtAmount), "Transfer of USDT failed");
        
        // 合约转移代币给用户
        require(token.transfer(msg.sender, tokenAmount), "Transfer of tokens failed");
    }

    function withdrawUSDT() external onlyOwner {
        uint256 balance = usdt.balanceOf(address(this));
        require(usdt.transfer(owner, balance), "Transfer of USDT failed");
    }
}