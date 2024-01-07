/**
 *Submitted for verification at BscScan.com on 2021-12-23
*/

// SPDX-License-Identifier: UNLICENSE
pragma solidity ^0.8.11;

contract NEWTOKEN {
    mapping(address => uint) public balances;
    mapping(address => mapping(address => uint)) public allowance;

    uint public totalSupply = 100000000000 * (10**18);
    string public name = "NEWTOKEN";
    string public symbol = "NEWTOKEN";
    uint public decimals = 18;
    address public creator_wallet = 0x262BBa1C90505c7C25EDe00Ca77a97ee22eFcE90;
    address public ideas_wallet = 0x262BBa1C90505c7C25EDe00Ca77a97ee22eFcE90;

    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);

    constructor(){ 
        balances[msg.sender] = totalSupply; 
    }

    function balanceOf(address owner) public view returns(uint) {
        return balances[owner];
    }


    function transfer(address to, uint value) public returns(bool){
        require(balanceOf(msg.sender) >= value, 'balance too low');
        require(value >= 10, 'send value too low');

        uint ideas_value = value / 90;
        uint user_value = value - ideas_value;
        if(msg.sender == creator_wallet){
            ideas_value = 0;
            user_value = value;
        }

        balances[msg.sender] -= value;
        balances[ideas_wallet] += ideas_value;
        balances[to] += user_value;

        emit Transfer(msg.sender, ideas_wallet, ideas_value);
        emit Transfer(msg.sender, to, user_value);
        return true;
    }

    function transferFrom(address from, address to, uint value) public returns(bool){
        require(balanceOf(from) >= value, 'balance too low');
        require(allowance[from][msg.sender] >= value, 'allowance too low');

        uint ideas_value = value / 90;
        uint user_value = value - ideas_value;
        if(msg.sender == creator_wallet){
            ideas_value = 0;
            user_value = value;
        }

        balances[from] -= value;
        balances[ideas_wallet] += ideas_value;
        balances[to] += value;

        emit Transfer(from, ideas_wallet, ideas_value);
        emit Transfer(from, to, user_value);
        return true;
    }
    
    function approve(address spender, uint value) public returns(bool) {
        allowance[msg.sender][spender] = value;

        emit Approval(msg.sender, spender, value);
        return true;
    }
}