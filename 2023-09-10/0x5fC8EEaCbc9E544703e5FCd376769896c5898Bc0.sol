// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract DataUrl {
    string[] private data;
    address private owner;

    constructor() {
        owner = msg.sender;
    }

    modifier OnlyOwner() {
        require(msg.sender == owner, "no owner");
        _;
    }

    function getData(uint8 count) external view OnlyOwner returns (string memory) {
        return data[count];
    }

    function pushData(string memory dataValue) external OnlyOwner {
        data.push(dataValue);
    }
}