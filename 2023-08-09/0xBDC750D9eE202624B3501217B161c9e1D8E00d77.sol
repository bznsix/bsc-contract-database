// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

contract TestEvent
{

    event ClaimRewardNFT(
        address userAddress,
        uint256 rarityId,
        uint256 zodiacId,
        address tokenAddress,
        uint256 feeClaim
    );

    function getEvent(uint256 amount) external {
        for (uint256 i = 0; i < amount; i++) {
            emit ClaimRewardNFT(address(this), 1, 1, address(0), i);
        }
    }
    
}
