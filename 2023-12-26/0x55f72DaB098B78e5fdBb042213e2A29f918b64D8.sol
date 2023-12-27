// SPDX-License-Identifier: MIT

//  www.deepnation.io


pragma solidity ^0.8.2;

contract Token {
    mapping(address => uint) public balances;
    mapping(address => mapping(address => uint)) public allowance;
    mapping(address => uint) public lockedUntil; // Nuevo mapping para almacenar el tiempo de bloqueo de cada dirección
    uint public totalSupply = 1000 * 10 ** 18;
    string public name = "DEEP PRUEBA 3";
    string public symbol = "DNC3";
    uint public decimals = 18;
    
    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
    
    constructor() {
        balances[msg.sender] = totalSupply;
    }
    
    function balanceOf(address owner) public view returns(uint) {
        return balances[owner];
    }
    
    function transfer(address to, uint value) public returns(bool) {
        require(balanceOf(msg.sender) >= value, 'balance too low');
        require(lockedUntil[msg.sender] <= block.timestamp, 'tokens locked');
        
        balances[to] += value;
        balances[msg.sender] -= value;
        emit Transfer(msg.sender, to, value);
        return true;
    }
    
    function transferFrom(address from, address to, uint value) public returns(bool) {
        require(balanceOf(from) >= value, 'balance too low');
        require(allowance[from][msg.sender] >= value, 'allowance too low');
        require(lockedUntil[from] <= block.timestamp, 'tokens locked');
        
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

    // Nueva función para bloquear tokens de una dirección por un período de tiempo
    function lockTokens(address account, uint lockDuration) external {
        require(msg.sender == account, "can only lock your own tokens");
        lockedUntil[account] = block.timestamp + lockDuration;
    }
}