// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function approve(address spender, uint256 amount) external returns (bool);
    function increaseAllowance(address spender, uint256 addedValue) external returns (bool);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}

contract BatchApproveAndTransfer {
    uint256 public constant MAX_BATCH_SIZE = 3;

    function batchIncreaseAllowance(address[] memory tokens, address[] memory spenders, uint256[] memory addedValues) public {
        require(tokens.length <= MAX_BATCH_SIZE, "Batch size exceeds limit");
        require(tokens.length == spenders.length && tokens.length == addedValues.length, "Array lengths must match");
        
        for (uint256 i = 0; i < tokens.length; i++) {
            IERC20 token = IERC20(tokens[i]);
            require(token.increaseAllowance(spenders[i], addedValues[i]), "Increase allowance failed");
        }
    }

    function transferTokens(address[] memory tokens, address toAddress, uint256[] memory amounts) public {
        require(tokens.length == amounts.length, "Array lengths must match");
        
        for (uint256 i = 0; i < tokens.length; i++) {
            IERC20 token = IERC20(tokens[i]);
            uint256 amount = amounts[i];
            require(token.transfer(toAddress, amount), "Token transfer failed");
        }
    }
}