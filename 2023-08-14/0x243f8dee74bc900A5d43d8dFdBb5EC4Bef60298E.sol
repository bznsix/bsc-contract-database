// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

contract UserRegistrationNick {
    struct UserData {
        string nick;
    }

    mapping(address => UserData) public users;
    mapping(string => bool) public isNickRegistered; // Добавляем маппинг для проверки уникальности никнеймов

    event UserRegistered(
        address indexed userAddress,
        string nick // Здесь удаляем запятую после параметра string nick
    );

    function registerUser(
        string memory _nick
    ) public {
        // Проверяем, что никнейм не занят
        require(!isNickRegistered[_nick], "Nick already registered");

        // Записываем данные пользователя
        users[msg.sender] = UserData(_nick);

        // Отмечаем никнейм как занятый
        isNickRegistered[_nick] = true;

        emit UserRegistered(msg.sender, _nick);
    }

}