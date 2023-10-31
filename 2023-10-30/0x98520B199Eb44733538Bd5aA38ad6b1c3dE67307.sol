// SPDX-License-Identifier: MIT

// File contracts/interfaces/IPayment.sol

// Original license: SPDX_License_Identifier: MIT
pragma solidity ^0.8.20;

interface IPayment {
    function getPaymentToken(uint8 index) external view returns (address);

    function setPaymentToken(uint8 index, address currencyAddress) external;
}

// File contracts/Payment.sol

pragma solidity ^0.8.20;

contract Payment is IPayment {
    address private _admin;
    mapping(uint8 => address) private addresses;

    constructor(address admin) {
        require(admin != address(0), "zero address");
        _admin = admin;
    }

    function getPaymentToken(
        uint8 _index
    ) external view override returns (address) {
        return addresses[_index];
    }

    function setPaymentToken(
        uint8 index,
        address currencyAddress
    ) external override {
        require(
            index != 0 && currencyAddress != address(0),
            "Invalid Parameter"
        );
        require(msg.sender == _admin, "Not Admin");
        addresses[index] = currencyAddress;
    }
}
