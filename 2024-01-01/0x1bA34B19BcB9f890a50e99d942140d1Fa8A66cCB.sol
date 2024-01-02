// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

interface IERC20 {
    function totalSupply() external view returns (uint);
    function balanceOf(address account) external view returns (uint);
    function transfer(address recipient, uint amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint amount) external returns (bool);
    function approve(address spender, uint amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint);
    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
}

contract Migration {
    address public tokenAddress;
    address public owner;
    mapping(address => uint256) public userTokenBalances;
    address[] public users;

    modifier onlyOwner() {
        require(msg.sender == owner, "Not the owner");
        _;
    }

    event TokensDeposited(address indexed user, uint256 amount);
    event TokensWithdrawn(address indexed user, uint256 amount);

    constructor(address _tokenAddress) {
        tokenAddress = _tokenAddress;
        owner = msg.sender;
    }

    function MigrateTokens(uint256 amount) external {
        require(amount > 0, "Amount must be greater than 0");

        // Transfer tokens from the user to this contract
        require(IERC20(tokenAddress).transferFrom(msg.sender, address(this), amount), "Token transfer failed");

        // Update user's token balance
        userTokenBalances[msg.sender] += amount;

        // Add user to the list if not already added
        if (!userExists(msg.sender)) {
            users.push(msg.sender);
        }

        emit TokensDeposited(msg.sender, amount);
    }

    function withdrawTokens(uint256 amount) external onlyOwner {
        require(amount > 0, "Amount must be greater than 0");
        require(amount <= IERC20(tokenAddress).balanceOf(address(this)), "Insufficient balance");

        // Transfer tokens from this contract to the owner
        require(IERC20(tokenAddress).transfer(owner, amount), "Token transfer failed");

        emit TokensWithdrawn(owner, amount);
    }

    function getUserTokenBalance(address user) external view returns (uint256) {
        return userTokenBalances[user];
    }

    function getAllUserTokenBalances() external view  returns (address[] memory, uint256[] memory) {
        uint256 userCount = users.length;
        address[] memory allUsers = new address[](userCount);
        uint256[] memory balances = new uint256[](userCount);

        for (uint256 i = 0; i < userCount; i++) {
            address currentUser = users[i];
            allUsers[i] = currentUser;
            balances[i] = userTokenBalances[currentUser];
        }

        return (allUsers, balances);
    }

    function userExists(address user) internal view returns (bool) {
        for (uint256 i = 0; i < users.length; i++) {
            if (users[i] == user) {
                return true;
            }
        }
        return false;
    }

    function getContractTokenBalance() external view returns (uint256) {
        return IERC20(tokenAddress).balanceOf(address(this));
    }

    
}