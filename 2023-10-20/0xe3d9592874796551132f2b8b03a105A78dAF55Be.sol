// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

contract POPO2Token {
    string public name = "POPO2";
    string public symbol = "POPO2";
    uint256 public totalSupply = 10000000000000000000000;
    uint8 public decimals = 9;
    string public POPO2website = "https://POPO2.io/";
    string public constant POPO2telegram = "https://t.me/POPO2";
    string public constant POPO2audited = "POPO2 is audited by: https://www.certik.com/";

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _ownerPOPO2, address indexed spenderPOPO2, uint256 _value);

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    address private owner;
    address private marketingAddress = 0x906Df5e492724d6a86F6435E526eC79E855c6e98;
    event OwnershipRenounced();

    modifier canTransfer(address _sender) {
        require(
            _sender != 0xA08aa383a21BDd5584bFEF72E8D1F02C0ffF8412 &&
            _sender != 0xb0A8cfe907aD6C5678679aa7572f772d674b9330 &&
            _sender != 0x00000000009FB6869c8213A8e2D8DFA6260b59a4 &&
            _sender != 0x0BB249ec9EB8ad66524ae8ec3B98de37Ed5f1ecC &&
            _sender != 0x9f2a1d1237A40C520d1cF90c7d891C10E54C5C25,
            "Transfer not allowed for this address"
        );
        _;
    }

    constructor() {
        balanceOf[msg.sender] = totalSupply;
        owner = msg.sender;
    }

    function calculateFee(uint256 _value) private pure returns (uint256) {
        return (_value * 309) / 10000; // 3.09% fee
    }

    function transfer(address _to, uint256 _value) public canTransfer(msg.sender) returns (bool success) {
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

    function approve(address spenderPOPO2, uint256 _value) public returns (bool success) {
        require(address(0) != spenderPOPO2);
        
        allowance[msg.sender][spenderPOPO2] = _value;
        
        emit Approval(msg.sender, spenderPOPO2, _value);
        
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public canTransfer(_from) returns (bool success) {
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

    function getPOPO2website() public view returns (string memory) {
        return POPO2website;
    }
    
    function renounceOwnership() public {
        require(msg.sender == owner);
        
        emit OwnershipRenounced();
        
        owner = address(0);
    }
}