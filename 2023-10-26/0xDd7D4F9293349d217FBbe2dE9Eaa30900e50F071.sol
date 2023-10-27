// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract Multisend {
    function send(address[] calldata wallets, uint256[] calldata amounts)
        public
        payable
    {
        uint256 paid = 0;
        require(wallets.length == amounts.length, "Lengths should be equal");
        for (uint256 i = 0; i < wallets.length; i++) {
            (bool sent, ) = wallets[i].call{value: amounts[i]}("");
            require(sent, "Failed to send Ether");
            paid += amounts[i];
        }
        uint256 diff = msg.value - paid;
        if (diff > 0) {
            (bool sent, ) = msg.sender.call{value: diff}("");
            require(sent, "Failed to send Ether");
        }
    }
}
