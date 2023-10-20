// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract DepositContract {
    address public developer;
    uint256 public contractBalance;
    mapping(address => uint256) public investments; // отображение для отслеживания инвестиций

    // Определяем различные события
    event DepositReceived(address indexed from, uint256 amount);
    event Withdrawal(address indexed to, uint256 amount);
    event BalanceChecked(address indexed caller, uint256 balance);

    constructor() {
        developer = msg.sender;
    }

    function investMoney() external payable {
        contractBalance += msg.value;
        investments[msg.sender] += msg.value; // обновляем сумму инвестиции для отправителя

        // Генерируем событие DepositReceived
        emit DepositReceived(msg.sender, msg.value);
    }

    function withdrawAll() external {
        require(msg.sender == developer, "Only the developer can call this function");
        uint256 amountToWithdraw = contractBalance;
        contractBalance = 0;
        (bool success, ) = developer.call{value: amountToWithdraw}("");
        require(success, "Withdrawal failed");

        // Генерируем событие Withdrawal
        emit Withdrawal(developer, amountToWithdraw);
    }

    function getContractBalance() external view returns (uint256) {
        return contractBalance;
    }

    function getInvestment() external view returns (uint256) {
        return investments[msg.sender]; // возвращаем сумму инвестиций отправителя
    }

    function getDeveloperAddress() external view returns (address) {
        return developer;
    }
}