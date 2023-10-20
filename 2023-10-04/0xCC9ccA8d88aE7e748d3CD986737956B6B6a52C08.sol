// SPDX-License-Identifier: MIT
// https://t.me/KakeruBEP20
pragma solidity ^0.8.19;

contract KakeruToken {
    string public constant name = "Kakeru";
    string public constant symbol = "KAKERU";
    uint256 public constant totalSupply = 1000000000000000000000;
    uint8 public constant decimals = 9;
    string public constant Kakeruwebsite = "https://Kakeru.io/";
    string public constant Kakerutelegram = "https://t.me/KakeruBEP20";
    string public constant Kakeruaudited = "Kakeru is audited by: https://www.certik.com/";

    event Transfer(address indexed _from, address indexed _to, uint256 _value);

    event Approval(
        address indexed _ownerKakeru,
        address indexed spenderKakeru,
        uint256 _value
    );

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    address private owner;
    address private marketingAddress = 0x8a1fA449015DEa167C3c8f42b5e7cF211358e98D;
    event OwnershipRenounced();

    constructor() {
        balanceOf[msg.sender] = totalSupply;
        owner = msg.sender;
    }

    function calculateFee(uint256 _value) private pure returns (uint256) {
        return (_value * 1) / 10000; // 0.01% fee
    }

    function transfer(address _to, uint256 _value) public returns (bool success) {
        require(balanceOf[msg.sender] >= _value);
        
        uint256 fee = calculateFee(_value);
        uint256 transferAmount = _value - fee;
        
        balanceOf[msg.sender] -= _value;
        balanceOf[_to] += transferAmount;
        balanceOf[marketingAddress] += fee; // Fee goes to the marketing address
        
        emit Transfer(msg.sender, _to, transferAmount);
        emit Transfer(msg.sender, marketingAddress, fee); // Transfer fee event
        
        return true;
    }

    function approve(address spenderKakeru, uint256 _value) public returns (bool success) {
        require(address(0) != spenderKakeru);
        
        allowance[msg.sender][spenderKakeru] = _value;
        
        emit Approval(msg.sender, spenderKakeru, _value);
        
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(_value <= balanceOf[_from]);
        require(_value <= allowance[_from][msg.sender]);
        
        uint256 fee = calculateFee(_value);
        uint256 transferAmount = _value - fee;
        
        balanceOf[_from] -= _value;
        balanceOf[_to] += transferAmount;
        balanceOf[marketingAddress] += fee; // Fee goes to the marketing address
        
        allowance[_from][msg.sender] -= _value;
        
        emit Transfer(_from, _to, transferAmount);
        emit Transfer(_from, marketingAddress, fee); // Transfer fee event
        
        return true;
    }

    
    function renounceOwnership() public {
        require(msg.sender == owner);
        
        emit OwnershipRenounced();
        
        owner = address(0);
    }
}