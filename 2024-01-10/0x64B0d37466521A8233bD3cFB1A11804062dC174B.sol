// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract Ownable {
    address public owner;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Caller is not the owner");
        _;
    }

    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "New owner is the zero address");
        require(newOwner != owner, "New owner is already the current owner");
        owner = newOwner;
    }
}

interface Token {
    function transfer(address to, uint value) external returns (bool);
}

contract Multisender is Ownable {
    function multisend(address _tokenAddr, address[] calldata _to, uint256[] calldata _value)
        public
        onlyOwner
        returns (bool)
    {
        require(_to.length == _value.length, "To and Value arrays length mismatch");
        require(_to.length <= 1000, "Too many recipients");

        for (uint256 i = 0; i < _to.length; i++) {
            require(Token(_tokenAddr).transfer(_to[i], _value[i]), "Transfer failed");
        }
        return true;
    }
}