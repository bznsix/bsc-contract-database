// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract PDXCcoin {
    string public name = "PDXC Coin";
    string public symbol = "PDXC";
    uint8 public decimals = 18;
    uint256 public totalSupply = 1000000000 * (10 ** uint256(decimals));

    address public owner;
    mapping(address => uint256) public balanceOf;
    mapping(address => bool) public whiteListed; // Addresses allowed to sell
    mapping(address => mapping(address => uint256)) public allowance;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event WhiteListed(address indexed account, bool isWhitelisted);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    modifier onlyWhitelisted() {
        require(whiteListed[msg.sender], "Only whitelisted addresses can sell");
        _;
    }

    constructor() {
        balanceOf[msg.sender] = totalSupply;
        owner = msg.sender;
        whiteListed[msg.sender] = true; // Owner is initially whitelisted
    }

    function transferOwnership(address newOwner) external onlyOwner {
        require(newOwner != address(0), "Invalid address");
        owner = newOwner;
    }

    function addToWhiteList(address account) external onlyOwner {
        whiteListed[account] = true;
        emit WhiteListed(account, true);
    }

    function removeFromWhiteList(address account) external onlyOwner {
        whiteListed[account] = false;
        emit WhiteListed(account, false);
    }

    function transfer(address to, uint256 value) external returns (bool) {
        require(to != address(0), "Invalid address");
        require(balanceOf[msg.sender] >= value, "Insufficient balance");

        balanceOf[msg.sender] -= value;
        balanceOf[to] += value;
        emit Transfer(msg.sender, to, value);
        return true;
    }

    function approve(address spender, uint256 value) external returns (bool) {
        allowance[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    function transferFrom(address from, address to, uint256 value) external returns (bool) {
        require(from != address(0), "Invalid address");
        require(to != address(0), "Invalid address");
        require(balanceOf[from] >= value, "Insufficient balance");
        require(allowance[from][msg.sender] >= value, "Allowance exceeded");

        balanceOf[from] -= value;
        balanceOf[to] += value;
        allowance[from][msg.sender] -= value; // Subtract allowance here
        emit Transfer(from, to, value);
        return true;
    }
}
