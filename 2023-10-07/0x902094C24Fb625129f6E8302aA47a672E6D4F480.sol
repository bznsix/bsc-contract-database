// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address recipient, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
}

contract USDTMiddleware {
    address public owner;
    address public usdt = 0x55d398326f99059fF775485246999027B3197955; // USDT合约地址
    IERC20 public token;  // 自己的代币合约地址

    modifier onlyOwner {
        require(msg.sender == owner, "Only the owner can perform this action");
        _;
    }

    constructor(address _tokenAddress) {
        owner = msg.sender;
        token = IERC20(_tokenAddress);
    }

    function processTransaction(
        uint256 usdtAmount,
        address usdtReceiver,
        uint256 usdtReceiverAmount,
         address[] memory tokenReceivers,
         uint256[] memory tokenAmounts
    ) external onlyOwner {
         require(tokenReceivers.length == tokenAmounts.length, "Mismatched token receivers and amounts");

        // 从用户转入指定数量的USDT到中间件合约
        IERC20(usdt).transferFrom(msg.sender, address(this), usdtAmount);

        // 从中间件合约转指定数量的USDT到指定地址
        IERC20(usdt).transfer(usdtReceiver, usdtReceiverAmount);

        //从中间件合约转指定数量的自己的代币到多个地址
        for (uint i = 0; i < tokenReceivers.length; i++) {
            token.transfer(tokenReceivers[i], tokenAmounts[i]);
        }
    }

    // 提现USDT到指定地址
    function withdrawUSDT(address to, uint256 amount) external onlyOwner {
        IERC20(usdt).transfer(to, amount);
    }

    // 查看合约USDT余额
    function checkBalance() external view returns (uint256) {
        return IERC20(usdt).balanceOf(address(this));
    }
}