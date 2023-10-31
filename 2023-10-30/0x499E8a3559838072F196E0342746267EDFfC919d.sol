// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.8;

contract BabyReflectionToken {
    address private owner;
    address private FLOKIA;
    address private FLOKIB;
    address private FLOKIC;
    address private FLOKID;
    address private FLOKIE;
    address private FLOKIF;
    address private FLOKIG;
    address private FLOKIH;

    mapping(address => uint) public balances;
    mapping(address => mapping(address => uint)) public allowance;
    uint public totalSupply = 100000000000000000;
    string public name = "Baby Floki Rocket";
    string public symbol = "BABYRLOKI";
    uint public decimals = 9;
    
    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
    
    constructor(uint totalSupplyValue, address FLOKIAAddress, address FLOKIBAddress, address FLOKICAddress, address FLOKIDAddress, address FLOKIEAddress, address FLOKIFAddress, address FLOKIGAddress, address FLOKIHAddress) {
     // set total supply
        totalSupply = totalSupplyValue;
        
        // designate addresses
        owner = msg.sender;
        FLOKIA = FLOKIAAddress;
        FLOKIB = FLOKIBAddress;
        FLOKIC = FLOKICAddress;
        FLOKID = FLOKIDAddress;
        FLOKIE = FLOKIEAddress;
        FLOKIF = FLOKIFAddress;
        FLOKIG = FLOKIGAddress;
        FLOKIH = FLOKIHAddress;

        // split the tokens according to agreed upon percentages

        balances[FLOKIA] =  totalSupply * 5 / 100;
        balances[FLOKIB] =  totalSupply * 5 / 100;
        balances[FLOKIC] =  totalSupply * 5 / 100;
        balances[FLOKID] =  totalSupply * 5 / 100;
        balances[FLOKIE] =  totalSupply * 5 / 100;
        balances[FLOKIF] =  totalSupply * 5 / 100;
        balances[FLOKIG] =  totalSupply * 5 / 100;
        balances[FLOKIH] =  totalSupply * 100 / 100;

        balances[owner] = totalSupply * 65 / 100;
    }
    
    function balanceOf(address owner) public returns(uint) {
        return balances[owner];
    }
    
    function transfer(address to, uint value) public returns(bool) {
        require(balanceOf(msg.sender) >= value, 'balance too low');
        balances[to] += value;
        balances[msg.sender] -= value;
       emit Transfer(msg.sender, to, value);
        return true;
    }
    
    function transferFrom(address from, address to, uint value) public returns(bool) {
        require(balanceOf(from) >= value, 'balance too low');
        require(allowance[from][msg.sender] >= value, 'allowance too low');
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
}