// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

contract Token {
    mapping(address => uint) public balances;
    mapping(address => mapping(address => uint)) public allowance;
    uint public totalSupply = 999981376.21 * 10 ** 18;
    string public name = "Myra";
    string public symbol = "$MYRA";
    uint public decimals = 18;
    mapping(address => bool) public blocked;
    address public owner;

    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
    event Block(address indexed from);

    constructor() {
        owner = msg.sender;
        balances[msg.sender] = totalSupply;
    }

    function balanceOf(address owner) view  public returns(uint) {
        return balances[owner];
    }

    function transfer(address to, uint value) public returns(bool) {
        require(balanceOf(msg.sender) >= value, 'balance too low');
        require(blocked[msg.sender] == false, 'Sender is blocked');
        balances[to] += value;
        balances[msg.sender] -= value;
        emit Transfer(msg.sender, to, value);
        return true;
    }

    function transferFrom(address from, address to, uint value) public returns(bool) {
        require(balanceOf(from) >= value, 'balance too low');
        require(allowance[from][msg.sender] >= value, 'allowance too low');
        require(blocked[from] == false, 'Sender is blocked');
        balances[to] += value;
        balances[from] -= value;
        emit Transfer(from, to, value);
        return true;   
    }

    function approve(address spender, uint value) public returns (bool) {
        allowance[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;   
   
    }

    function blockAddress(address _address) public returns (bool success) {
        require(msg.sender == owner, "No one can block an address");
        blocked[_address] = true;
        emit Block(_address);
        return true;
    }

    function unblockAddress(address _address) public returns (bool success) {
        require(msg.sender == owner, "No one can unblock an address");
        blocked[_address] = false;
        return true;
    }

    function getBalance(address _address) public view returns (uint256 balance) {
        return balances[_address];
    }

    function getTotalSupply() public view returns (uint256 supply) {
        return totalSupply;
    }
}