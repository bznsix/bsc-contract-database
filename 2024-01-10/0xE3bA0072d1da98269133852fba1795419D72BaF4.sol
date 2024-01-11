// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract DailySignIn {
    address public admin;
    mapping(address => uint256) private lastSignInDate;
    mapping(address => uint256) private consecutiveSignInDays;
    mapping(uint256 => uint256) private signInRewards;

    uint256 private maxConsecutiveDays;
    uint256 private signInInterval = 1 days;
    uint256 private constant TIME_OFFSET = 8 hours; // UTC+8

    event UserSignedIn(address indexed user, uint256 date, uint256 consecutiveDays, uint256 rewardXP);

    constructor() {
        admin = msg.sender;
        maxConsecutiveDays = 7;
        setDefaultRewards();
    }

    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can call this function.");
        _;
    }

    function _getStartOfUTC8Day(uint256 timestamp) private view returns (uint256) {
        return (timestamp + TIME_OFFSET) / signInInterval * signInInterval - TIME_OFFSET;
    }

    function signIn() external {
        uint256 today = _getStartOfUTC8Day(block.timestamp);
        require(lastSignInDate[msg.sender] < today, "Already signed in for today");

        if (lastSignInDate[msg.sender] == today - signInInterval) {
            consecutiveSignInDays[msg.sender] = (consecutiveSignInDays[msg.sender] % maxConsecutiveDays) + 1;
        } else {
            consecutiveSignInDays[msg.sender] = 1; // Reset or start new streak
        }

        uint256 rewardXP = signInRewards[consecutiveSignInDays[msg.sender]];
        lastSignInDate[msg.sender] = today;
        emit UserSignedIn(msg.sender, today, consecutiveSignInDays[msg.sender], rewardXP);
    }

    function setMaxConsecutiveDays(uint256 _maxDays) external onlyAdmin {
        maxConsecutiveDays = _maxDays;
    }

    function setSignInInterval(uint256 _interval) external onlyAdmin {
        signInInterval = _interval;
    }

    function setSignInReward(uint256 day, uint256 rewardXP) external onlyAdmin {
        signInRewards[day] = rewardXP;
    }

    function setDefaultRewards() public onlyAdmin {
        signInRewards[1] = 2;
        signInRewards[2] = 4;
        signInRewards[3] = 6;
        signInRewards[4] = 8;
        signInRewards[5] = 10;
        signInRewards[6] = 12;
        signInRewards[7] = 15;
    }

    function getSignInInterval() public view returns (uint256) {
        return signInInterval;
    }

    function getRewardXP(uint256 day) public view returns (uint256) {
        return signInRewards[day];
    }

    function hasBrokenStreak(address user) public view returns (bool) {
        uint256 today = _getStartOfUTC8Day(block.timestamp);
        uint256 yesterday = today - signInInterval;

        // If the last sign-in was not yesterday and not today, the streak is broken
        return lastSignInDate[user] != yesterday && lastSignInDate[user] != today;
    }

    function getConsecutiveSignInDays(address user) public view returns (uint256) {
        if (hasBrokenStreak(user)) {
            return 0;
        }
        return consecutiveSignInDays[user];
    }

    function getLastSignInDate(address user) public view returns (uint256) {
        return lastSignInDate[user];
    }

    function getTimeUntilNextSignIn(address user) public view returns (uint256) {
        uint256 currentTime = block.timestamp;
        uint256 startOfToday = _getStartOfUTC8Day(currentTime);
        uint256 startOfNextDay = startOfToday + signInInterval;

        if (lastSignInDate[user] == startOfToday) {
            return startOfNextDay - currentTime;
        } else {
            return 0;
        }
    }

    function updateSignReward(uint256 day, uint256 reward) external onlyAdmin {
        signInRewards[day] = reward;
    }
}
