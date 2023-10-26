// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

contract Ownable {
    address public owner;
    address public feeRecipient;
    uint256 public serviceFee;

    constructor() {
        owner = msg.sender;
        feeRecipient = msg.sender;
        serviceFee = 1000000000000000; // 0.001 BNB (em Wei) como taxa inicial
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Apenas o proprietario pode chamar esta funcao");
        _;
    }

    modifier onlyOwnerOrFeeRecipient() {
        require(msg.sender == owner || msg.sender == feeRecipient, "Apenas o proprietario ou o destinatario da taxa podem chamar esta funcao");
        _;
    }

    function transferOwnership(address newOwner) public onlyOwner {
        owner = newOwner;
    }

    function setFeeRecipient(address newRecipient) public onlyOwner {
        feeRecipient = newRecipient;
    }

    function setServiceFee(uint256 newFee) public onlyOwner {
        serviceFee = newFee;
    }
}

interface Token {
    function transfer(address to, uint256 value) external returns (bool);
}

contract Multisender is Ownable {
    function multisend(address _tokenAddr, address[] calldata _to, uint256[] calldata _valueInWei)
        external
        returns (bool _success)
    {
        require(_to.length == _valueInWei.length, "Tamanho dos arrays nao corresponde");
        require(_to.length <= 1000, "Muitos destinatarios");

        uint256 totalFee = serviceFee * _to.length;
        require(Token(_tokenAddr).transfer(feeRecipient, totalFee), "Falha na transferencia de taxa");

        for (uint256 i = 0; i < _to.length; i++) {
            require(Token(_tokenAddr).transfer(_to[i], _valueInWei[i]), "Falha na transferencia de token");
        }

        emit MultisendCompleted("SPACESENDER - MULTISENDER", msg.sender, _tokenAddr);

        return true;
    }

    event MultisendCompleted(string indexed description, address indexed sender, address indexed tokenAddress);
}