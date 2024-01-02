/**
 Submitted for verification at BscScan.com on 2024-01-01
**/

// Telegram :@knobinu
// Website  :knobinu.com
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.2;

contract Token {
    mapping(address => uint) public balances;
    mapping(address => mapping(address => uint)) public allowance;
    uint public totalSupply = 420 * 10**18;
    string public name = "KNOB INU";
    string public symbol = "KNOB";
    uint public decimals = 18;
    address public owner;

    address public marketingWallet;

    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
    event OwnershipRenounced(address indexed previousOwner);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        balances[msg.sender] = totalSupply;
        owner = msg.sender;
        marketingWallet = 0xf55d7d669daBD18294Cf996e1e23349104cFA3E7;
    }

    function balanceOf(address _owner) public view returns (uint) {
        return balances[_owner];
    }

    function transfer(address to, uint value) public returns (bool) {
        require(balanceOf(msg.sender) >= value, "Balance too low");
        require(value <= totalSupply / 20, "Sell amount exceeds max limit");
        _transfer(msg.sender, to, value);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint value
    ) public returns (bool) {
        require(balanceOf(from) >= value, "Balance too low");
        require(allowance[from][msg.sender] >= value, "Allowance too low");
        _transfer(from, to, value);
        return true;
    }

    function approve(address spender, uint value) public returns (bool) {
        allowance[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    function getBalance(address _owner) public view returns (uint) {
        return balances[_owner];
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    function renounceOwnership() public onlyOwner {
        owner = address(0);
        emit OwnershipRenounced(owner);
    }

    function enounceOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "New owner cannot be zero address");
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }

    function burn(uint value) public onlyOwner {
        require(balanceOf(msg.sender) >= value, "Insufficient balance for burn");
        balances[msg.sender] -= value;
        totalSupply -= value;
        emit Transfer(msg.sender, address(0), value);
    }

    function _transfer(address from, address to, uint value) internal {
        uint taxAmount = value * 2 / 100;
        balances[marketingWallet] += taxAmount;
        value -= taxAmount;
        balances[to] += value;
        balances[from] -= value;
        emit Transfer(from, to, value);
    }
}