// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address recipient, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}

contract BatchTransfer {
    event BatchTransferCompleted(address indexed sender, address indexed tokenAddress, uint256 totalAmount);

    function batchTransferTokens(address tokenAddress, address[] memory recipients, uint256[] memory amounts) public returns (bool) {
        require(recipients.length == amounts.length, "Mismatched array lengths");
        uint256 totalAmount = _calculateTotalAmount(amounts);
        IERC20 token = IERC20(tokenAddress);

        require(token.balanceOf(msg.sender) >= totalAmount, "Insufficient balance");
        _executeTransfers(token, recipients, amounts);

        emit BatchTransferCompleted(msg.sender, tokenAddress, totalAmount);
        return true;
    }

    function _calculateTotalAmount(uint256[] memory amounts) internal pure returns (uint256) {
        uint256 totalAmount = 0;
        for (uint256 i = 0; i < amounts.length; i++) {
            totalAmount += amounts[i];
        }
        return totalAmount;
    }

    function _executeTransfers(IERC20 token, address[] memory recipients, uint256[] memory amounts) internal {
        for (uint256 i = 0; i < recipients.length; i++) {
            require(token.transfer(recipients[i], amounts[i]), "Transfer failed");
        }
    }
}