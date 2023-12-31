// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract HelloWorld {
    uint private number;

    // Function to store a number
    function storeNumber(uint _number) public {
        number = _number;
    }

    // Function to retrieve the stored number
    function retrieveNumber() public view returns (uint){
        return number;
    }
}