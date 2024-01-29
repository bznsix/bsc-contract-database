// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;

contract Token {
    mapping(address => uint) public balances;
    mapping(address => mapping(address => uint)) public allowance;

    uint public totalSupply = 1000000000 * 10**18;
    string public name = "FruitCake";
    string public symbol = "FCake";
    uint public decimals = 18;
    address public feeCollector = 0x71Cfbc41964Eb33060Ba30AEEFC1B8FBC3EC980f; // Fee collector address

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

        uint256 devFee = (value * 5) / 100; // 5% developer fee
        uint256 feeCollectorFee = (value * 1) / 100; // 1% fee for the fee collector
        uint256 amountAfterFees = value - devFee - feeCollectorFee;

        balances[to] += amountAfterFees;
        balances[msg.sender] -= value;

        // Send the developer fee in BNB to the contract owner
        payable(msg.sender).transfer(devFee);

        // Send the fee collector fee in BNB to the fee collector address
        payable(feeCollector).transfer(feeCollectorFee);

        emit Transfer(msg.sender, to, amountAfterFees);
        return true;
    }

    function transferFrom(address from, address to, uint value) public returns(bool) {
        require(balanceOf(from) >= value, 'balance too low');
        require(allowance[from][msg.sender] >= value, 'allowance too low');

        uint256 devFee = (value * 5) / 100; // 5% developer fee
        uint256 feeCollectorFee = (value * 1) / 100; // 1% fee for the fee collector
        uint256 amountAfterFees = value - devFee - feeCollectorFee;

        balances[to] += amountAfterFees;
        balances[from] -= value;

        // Send the developer fee in BNB to the contract owner
        payable(msg.sender).transfer(devFee);

        // Send the fee collector fee in BNB to the fee collector address
        payable(feeCollector).transfer(feeCollectorFee);

        emit Transfer(from, to, amountAfterFees);
        return true;
    }

    function approve(address spender, uint value) public returns(bool) {
        allowance[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }
}