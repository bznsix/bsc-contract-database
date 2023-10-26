// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract RocketCoin {
    string public name = "Rocket Coin";
    string public symbol = "RKT";
    uint8 public decimals = 18;
    uint256 public totalSupply = 21_000_000_000 * 10**uint256(decimals);
    uint256 public finalSupply = totalSupply / 10; // Final 10% remaining

    address public owner;
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    uint256 public lastBurnTimestamp;
    uint256 public constant burnRate = 5; // Percentage to burn per week

    constructor() {
        owner = msg.sender;
        balanceOf[msg.sender] = totalSupply;
    }

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Burn(address indexed burner, uint256 value);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can call this function");
        _;
    }

    function transfer(address to, uint256 value) public returns (bool) {
        require(to != address(0), "Invalid address");
        require(balanceOf[msg.sender] >= value, "Insufficient balance");
        balanceOf[msg.sender] -= value;
        balanceOf[to] += value;
        emit Transfer(msg.sender, to, value);
        return true;
    }

    function approve(address spender, uint256 value) public returns (bool) {
        allowance[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    function transferFrom(address from, address to, uint256 value) public returns (bool) {
        require(from != address(0), "Invalid address");
        require(to != address(0), "Invalid address");
        require(balanceOf[from] >= value, "Insufficient balance");
        require(allowance[from][msg.sender] >= value, "Allowance exceeded");
        balanceOf[from] -= value;
        balanceOf[to] += value;
        allowance[from][msg.sender] -= value;
        emit Transfer(from, to, value);
        return true;
    }

    function burn() public onlyOwner {
        uint256 toBurn = (totalSupply * burnRate) / 100;
        require(toBurn > 0, "No tokens to burn");
        require(balanceOf[msg.sender] >= toBurn, "Insufficient balance to burn");
        balanceOf[msg.sender] -= toBurn;
        totalSupply -= toBurn;
        lastBurnTimestamp = block.timestamp;
        emit Burn(msg.sender, toBurn);
    }

    function availableToBurn() public view returns (uint256) {
        uint256 weeksElapsed = (block.timestamp - lastBurnTimestamp) / 1 weeks;
        if (weeksElapsed > 0) {
            return (balanceOf[msg.sender] * burnRate * weeksElapsed) / 100;
        } else {
            return 0;
        }
    }
}