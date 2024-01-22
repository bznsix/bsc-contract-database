// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * Contact us on Telegram: https://t.me/grokceo_bsc
 * Follow us on Twitter: https://twitter.com/GrokCeo
 */

contract GROKCEO {

    // Token information
    string public name = "GROK CEO";
    string public symbol = "GROKCEO";
    uint8 public decimals = 18;  // Use 18 decimals, as it is the standard
    uint256 public totalSupply = 100000000000000000 * 10 ** uint256(decimals);

    // Mappings for balances and allowances
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    // Events for transfers and approvals
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    // Contract owner
    address private owner;

    // Modifier to restrict access to only owners
    modifier onlyOwner() {
        require(msg.sender == owner, "Not the owner");
        _;
    }

    // Constructor of the contract
    constructor() {
        balanceOf[msg.sender] = totalSupply;
        owner = msg.sender;

        emit Transfer(address(0), msg.sender, totalSupply);
    }

    // Transfer function
    function transfer(address to, uint256 value) external returns (bool) {
        _transfer(msg.sender, to, value);
        return true;
    }

    // Approval function
    function approve(address spender, uint256 value) external returns (bool) {
        allowance[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    // Transfer from function
    function transferFrom(address from, address to, uint256 value) external returns (bool) {
        require(value <= allowance[from][msg.sender], "Insufficient allowance");
        allowance[from][msg.sender] -= value;
        _transfer(from, to, value);
        return true;
    }

    // Internal function to perform the transfer
    function _transfer(address from, address to, uint256 value) internal {
        require(to != address(0), "Transfer to the zero address");
        require(value <= balanceOf[from], "Insufficient balance");

        balanceOf[from] -= value;
        balanceOf[to] += value;

        emit Transfer(from, to, value);
    }
}