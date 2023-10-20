// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

contract UserRegistration {

    struct UserData {
        string email;
        string shortDescription;
        string longDescription;
        string ipfsHash;
    }

    mapping(address => UserData) public users;

    event UserRegistered(
        address indexed userAddress
    );

    function registerUser(
        string memory _email,
        string memory _shortDescription,
        string memory _longDescription,
        string memory _ipfsHash
    ) public {

        // Записываем данные пользователя
        users[msg.sender] = UserData(
            _email,
            _shortDescription,
            _longDescription,
            _ipfsHash
        );

        emit UserRegistered(msg.sender);
    }

}