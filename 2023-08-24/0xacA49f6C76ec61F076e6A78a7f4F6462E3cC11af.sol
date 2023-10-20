// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address recipient, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    function balanceOf(address account) external view returns (uint256);
}

contract Business {
    address public owner;
    address public tokenAddress = 0xdDD42201E485ABa87099089b00978B87E7FBE796;

    struct DepositInfo {
        uint256 amount;
        uint256 depositTime;
    }

    mapping(address => DepositInfo) public userDeposits;
    mapping(address => uint256) public userTotalDeposits_pev;
    mapping(address => uint256) public depositTime_pev;
    address[] public addresses;

    event TokensDeposited(address indexed user, uint256 tokenAmount);
    event TokensWithdrawn(address indexed user, uint256 tokenAmount, address tokenAddress);

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can call this function");
        _;
    }

    uint256 private TokenPer_USD;

    function TokenPerUSD(uint256 _amount) public onlyOwner returns (bool) {
        TokenPer_USD = _amount;
        return true;
    }

    mapping(address => uint256) public userUSD;

    function Deposit(uint256 _amount) external {
        IERC20 token = IERC20(tokenAddress);
        require(token.transferFrom(msg.sender, address(this), _amount), "Deposit failed");

        userTotalDeposits_pev[msg.sender] = userDeposits[msg.sender].amount;
        depositTime_pev[msg.sender] = userDeposits[msg.sender].depositTime;

        userDeposits[msg.sender].amount += _amount;
        userDeposits[msg.sender].depositTime = block.timestamp;

        uint256 USD = _amount / TokenPer_USD;
        userUSD[msg.sender] += USD;

        addresses.push(msg.sender);
        emit TokensDeposited(msg.sender, _amount);
    }

    function Reinvest() external {
        DepositInfo storage depositInfo = userDeposits[msg.sender];
        require(depositInfo.amount > 0, "No deposit to reinvest");

        uint256 earnedUSD = getEarnedUSD(msg.sender);
        require(earnedUSD > 0, "No earned USD to reinvest");

        userTotalDeposits_pev[msg.sender] = userDeposits[msg.sender].amount;
        depositTime_pev[msg.sender] = userDeposits[msg.sender].depositTime;

        userDeposits[msg.sender].depositTime = block.timestamp;

        IERC20 token = IERC20(tokenAddress);
        require(token.transfer(msg.sender, (earnedUSD / 1000000000000000000) * TokenPer_USD), "Withdrawal failed");
        emit TokensWithdrawn(msg.sender, (earnedUSD / 1000000000000000000) * TokenPer_USD, tokenAddress);
        depositInfo.amount = 0;
    }

    function Withdraw() external {
        DepositInfo storage depositInfo = userDeposits[msg.sender];
        uint256 userDepositAmount = depositInfo.amount;
        require(userDepositAmount > 0, "No deposit to withdraw");

        userTotalDeposits_pev[msg.sender] = userDeposits[msg.sender].amount;
        depositTime_pev[msg.sender] = userDeposits[msg.sender].depositTime;

        IERC20 token = IERC20(tokenAddress);
        require(token.transfer(msg.sender, userDepositAmount), "Withdrawal failed");

        depositInfo.amount = 0;
        emit TokensWithdrawn(msg.sender, userDepositAmount, tokenAddress);
    }


    function getTokenBalance() public view returns (uint256) {
        IERC20 token = IERC20(tokenAddress);
        return token.balanceOf(address(this));
    }

    function getUserTotalDeposits(address _user) public view returns (uint256) {
        return userDeposits[_user].amount;
    }

    function getEarnedUSD(address user) public view returns (uint256) {
        uint256 timePassed = block.timestamp - userDeposits[user].depositTime;
        uint256 earnedAmount = (userUSD[user] * timePassed) * 1 / (100 * 86400); // 1% per Day
        return earnedAmount;
    }

    function getDepositTime(address _user) public view returns (uint256) {
        return userDeposits[_user].depositTime;
    }
}