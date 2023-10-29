/**
 * @title PoppyQuackMultisender
 * @dev Smart contract created by PoppyQuack from ParaQuack Meme Token Community, a meme-powered DeFi project.
 * This contract allows the multisending of BNB and tokens to multiple addresses, while providing ownership management.
 *
 * Our motto: "Never give up!" embodies our commitment to providing innovative solutions and services in the crypto space.
 *
 * Visit our website at https://paraquack.com to learn more about our community and projects.
 */

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract PoppyQuackMultisender {
    address public owner;

    event BNBReceived(address indexed sender, uint256 amount);

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can call this function");
        _;
    }

    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "Invalid new owner address");
        owner = newOwner;
    }

    function multisendToken(address _tokenAddr, address[] calldata _to, uint256[] calldata _value) public returns (bool success) {
        require(_to.length == _value.length, "Address and value arrays must have the same length");
        require(_to.length <= 1000, "Too many recipients in a single transaction");

        for (uint256 i = 0; i < _to.length; i++) {
            require(Token(_tokenAddr).transfer(_to[i], _value[i]), "Token transfer failed");
        }

        return true;
    }

    function multisendBNB(address[] calldata _to, uint256[] calldata _value) public onlyOwner {
        require(_to.length == _value.length, "Address and value arrays must have the same length");
        require(_to.length <= 1000, "Too many recipients in a single transaction");

        for (uint256 i = 0; i < _to.length; i++) {
            payable(_to[i]).transfer(_value[i]);
        }
    }

    receive() external payable {
        emit BNBReceived(msg.sender, msg.value);
    }
}

interface Token {
    function transfer(address to, uint256 value) external returns (bool);
}