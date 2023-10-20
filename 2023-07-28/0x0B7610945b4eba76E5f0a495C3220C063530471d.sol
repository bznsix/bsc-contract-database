// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// SafeMath library for safe mathematical operations
library SafeMath {
    /**
     * @dev Adds two numbers, reverts on overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    /**
     * @dev Subtracts two numbers, reverts on overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        uint256 c = a - b;
        return c;
    }

    /**
     * @dev Multiplies two numbers, reverts on overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    /**
     * @dev Integer division of two numbers truncating the quotient, reverts on division by zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;
        return c;
    }
}

// Address library for address-related functions
library Address {
    /**
     * @dev Returns true if the address is a contract, false otherwise.
     */
    function isContract(address account) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }
}

// CakeBot contract
contract CakeBot {
    using SafeMath for uint256;
    using Address for address;

    string public name = "CakeBot";
    string public symbol = "CakeBot";
    uint8 public decimals = 18;
    uint256 public totalSupply;
    
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);


    constructor(uint256 initialSupply) {
        uint256 sullpy = initialSupply * 10 ** decimals;
        totalSupply = sullpy;
        balanceOf[msg.sender] = sullpy;
    }

    /**
     * @dev Transfer tokens from the caller's account to a recipient.
     */
    function transfer(address to, uint256 value) external returns (bool) {
        _transfer(msg.sender, to, value);
        return true;
    }

    /**
     * @dev Transfer tokens from an account to another account.
     */
    function transferFrom(address from, address to, uint256 value) external returns (bool) {
        require(value <= allowance[from][msg.sender], "Insufficient allowance");
        allowance[from][msg.sender] = allowance[from][msg.sender].sub(value);
        _transfer(from, to, value);
        return true;
    }

    /**
     * @dev Approve the spender to spend a certain amount of tokens on behalf of the owner.
     */
    function approve(address spender, uint256 value) external returns (bool) {
        require(spender != address(0), "Invalid spender address");
        allowance[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    /**
     * @dev Internal transfer function.
     */
    function _transfer(address from, address to, uint256 value) internal {
        require(from != address(0), "Invalid sender address");
        require(to != address(0), "Invalid recipient address");
        require(value > 0, "Transfer value must be greater than zero");
        require(balanceOf[from] >= value, "Insufficient balance");

        balanceOf[from] = balanceOf[from].sub(value);
        balanceOf[to] = balanceOf[to].add(value);

        emit Transfer(from, to, value);
    }
}