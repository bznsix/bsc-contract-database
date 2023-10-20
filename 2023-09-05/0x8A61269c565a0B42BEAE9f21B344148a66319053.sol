// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

interface IERC20 {
    function transferFrom(address from, address to, uint256 value) external returns (bool);
}

contract TransferUSDT {
    address public usdtTokenAddress;

    constructor(address _usdtTokenAddress) {
        usdtTokenAddress = _usdtTokenAddress;
    }

    function transferUSDT(address from, address to, uint256 amount) public returns (bool) {
        IERC20 usdtToken = IERC20(usdtTokenAddress);
        return usdtToken.transferFrom(from, to, amount);
    }
}