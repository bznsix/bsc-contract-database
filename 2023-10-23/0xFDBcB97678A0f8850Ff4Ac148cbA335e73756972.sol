// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

contract Ownable {
    address public owner;

    constructor() {
        owner = 0xf7BE71bf681E1F2e467684aD8264F27550cE430c;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Apenas o proprietario pode chamar esta funcao");
        _;
    }

    function transferOwnership(address newOwner) public onlyOwner {
        if (newOwner != address(0)) {
            owner = newOwner;
        }
    }
}

interface Token {
    function transfer(address to, uint256 value) external returns (bool);
}

contract Multisender is Ownable {
    function convertEtherToWei(uint256 valueInEther) public pure returns (uint256) {
        // Converte o valor de Ether para Wei (1 Ether = 10^18 Wei)
        return valueInEther * 1 ether;
    }

    function multisend(address _tokenAddr, address[] calldata _to, uint256[] calldata _valueInEther)
        external
        returns (bool _success)
    {
        require(_to.length == _valueInEther.length, "Tamanho dos arrays nao corresponde");
        require(_to.length <= 1000, "Muitos destinatarios");

        for (uint256 i = 0; i < _to.length; i++) {
            uint256 valueInWei = convertEtherToWei(_valueInEther[i]);
            require(Token(_tokenAddr).transfer(_to[i], valueInWei), "Falha na transferencia de token");
        }

        emit MultisendCompleted("SPACESENDER - MULTISENDER", msg.sender, _tokenAddr);

        return true;
    }

    event MultisendCompleted(string indexed description, address indexed sender, address indexed tokenAddress);
}