// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract WriteMyName {

    // Mapping to store names indexed by address
    mapping(address => string) public names;

    // Event emitted when a user writes their name
    event NameWritten(address indexed user, string name);

    // Function to write a name
    function writeName(string memory _name) public {
        names[msg.sender] = _name;
        emit NameWritten(msg.sender, _name);
    }

    // Function to read a user's name
    function getMyName() public view returns (string memory) {
        return names[msg.sender];
    }

    // Function to read any user's name by address
    function getName(address _userAddress) public view returns (string memory) {
        return names[_userAddress];
    }
}