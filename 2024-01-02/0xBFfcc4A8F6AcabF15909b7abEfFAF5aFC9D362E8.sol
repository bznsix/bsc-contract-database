// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract Token {
    mapping(address => uint) public balances;
    mapping(address => mapping(address => uint)) public allowance;
    uint public constant totalSupply = 320000000000000 * 10 ** 18;
    string public constant name = "Cute Grok";
    string public constant symbol = "CuteGrok";
    uint public constant decimals = 18;
   
    address public owner;
    address public taxCollector;
    uint public constant taxRate = 5;
    bool public taxEnabled = false;

    bool private locked;

    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
   
    constructor() {
        owner = msg.sender;
        taxCollector = msg.sender;
        balances[msg.sender] = totalSupply;
    }
   
    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    modifier noReentrant() {
        require(!locked, "No reentrancy allowed");
        locked = true;
        _;
        locked = false;
    }

    function balanceOf(address _owner) public view returns(uint) {
        return balances[_owner];
    }
   
    function transfer(address to, uint value) external noReentrant returns(bool) {
        require(balanceOf(msg.sender) >= value, 'balance too low');
        uint tax = 0;
        if (taxEnabled) {
            tax = value * taxRate / 100;
            value -= tax;
            balances[taxCollector] += tax;
        }
        balances[to] += value;
        balances[msg.sender] -= (value + tax);
        emit Transfer(msg.sender, to, value);
        return true;
    }
   
    function transferFrom(address from, address to, uint value) external noReentrant returns(bool) {
        require(balanceOf(from) >= value, 'balance too low');
        require(allowance[from][msg.sender] >= value, 'allowance too low');
        uint tax = 0;
        if (taxEnabled) {
            tax = value * taxRate / 100;
            value -= tax;
            balances[taxCollector] += tax;
        }
        balances[to] += value;
        balances[from] -= (value + tax);
        emit Transfer(from, to, value);
        return true;  
    }
   
    function approve(address spender, uint value) external returns (bool) {
        allowance[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;  
    }

    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(owner, address(0));
        owner = address(0);
    }

    function setTaxCollector(address _taxCollector) public onlyOwner {
        taxCollector = _taxCollector;
    }

    function toggleTax(bool _state) public onlyOwner {
        taxEnabled = _state;
    }
}