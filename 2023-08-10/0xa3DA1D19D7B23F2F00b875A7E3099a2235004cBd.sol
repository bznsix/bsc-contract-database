// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Forwarder {
    address public destination;

    // Установите адрес назначения при развертывании контракта
    constructor(address _destination) {
        destination = _destination;
    }

    // Функция для получения ETH
    receive() external payable {
        _forwardFunds();
    }

    // Внутренняя функция, которая передает полученные средства на адрес назначения
    function _forwardFunds() internal {
        payable(destination).transfer(address(this).balance);
    }
}