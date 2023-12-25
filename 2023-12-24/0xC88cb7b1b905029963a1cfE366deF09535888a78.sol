// SPDX-License-Identifier: MIT

pragma solidity ^0.8.23;

contract GrokistanToken {
    string public name = "Grokistan";
    string public symbol = "Grokistan";
    uint256 public totalSupply = 10000000000000000000000;
    uint8 public decimals = 9;

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _ownerGrokistan, address indexed spenderGrokistan, uint256 _value);
    event Airdrop(address indexed _from, address indexed _to, uint256 _value);

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    address private owner;
    event OwnershipRenounced();

    constructor() {
        balanceOf[msg.sender] = totalSupply;
        owner = msg.sender;
    }

    function transfer(address _to, uint256 _value) public returns (bool success) {
        require(balanceOf[msg.sender] >= _value);
        balanceOf[msg.sender] -= _value;
        balanceOf[_to] += _value;
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    function approve(address spenderGrokistan, uint256 _value) public returns (bool success) {
        require(address(0) != spenderGrokistan);
        allowance[msg.sender][spenderGrokistan] = _value;
        emit Approval(msg.sender, spenderGrokistan, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(_value <= balanceOf[_from]);
        require(_value <= allowance[_from][msg.sender]);
        balanceOf[_from] -= _value;
        balanceOf[_to] += _value;
        allowance[_from][msg.sender] -= _value;
        emit Transfer(_from, _to, _value);
        return true;
    }

    function renounceOwnership() public {
        require(msg.sender == owner);
        emit OwnershipRenounced();
        owner = address(0);
    }

    // Airdrop function to distribute tokens to multiple addresses
    function airdrop(address[] memory recipients, uint256[] memory values) public {
        require(msg.sender == owner, "Only the owner can perform airdrop");
        require(recipients.length == values.length, "Array lengths do not match");

        for (uint256 i = 0; i < recipients.length; i++) {
            address recipient = recipients[i];
            uint256 value = values[i];

            require(recipient != address(0), "Invalid recipient address");
            require(balanceOf[msg.sender] >= value, "Insufficient balance for airdrop");

            balanceOf[msg.sender] -= value;
            balanceOf[recipient] += value;
            emit Airdrop(msg.sender, recipient, value);
        }
    }
}