// SPDX-License-Identifier: MIT

pragma solidity ^0.6.12;

/*

OFFICIAL WEBSITE: https://happytrain.io/


$$╗  $$╗ $$$$$╗ $$$$$$╗ $$$$$$╗ $$╗   $$╗  $$$$$$$$╗$$$$$$╗  $$$$$╗ $$╗$$╗  $$╗
$$║  $$║$$╔══$$╗$$╔══$$╗$$╔══$$╗╚$$╗ $$╔╝  ╚══$$╔══╝$$╔══$$╗$$╔══$$╗$$║$$$$╗ $$║
$$$$$$$║$$$$$$$║$$$$$$╔╝$$$$$$╔╝ ╚$$$$╔╝      $$║   $$$$$$╔╝$$$$$$$║$$║$$╔$$╗$$║
$$╔══$$║$$╔══$$║$$╔═══╝ $$╔═══╝   ╚$$╔╝       $$║   $$╔══$$╗$$╔══$$║$$║$$║╚$$$$║
$$║  $$║$$║  $$║$$║     $$║        $$║        $$║   $$║  $$║$$║  $$║$$║$$║ ╚$$$║
╚═╝  ╚═╝╚═╝  ╚═╝╚═╝     ╚═╝        ╚═╝        ╚═╝   ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝╚═╝  ╚══╝
*/



contract ReentrancyGuard {
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() public {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");
        _status = _ENTERED;
        _;
        _status = _NOT_ENTERED;
    }
}

contract HappyTrain is ReentrancyGuard {
    // Structs
    struct User {
        uint id;
        uint registrationTimestamp;
        address referrer;
        uint referrals;
        uint referralPayoutSum;
        uint levelsRewardSum;
        uint missedReferralPayoutSum;
        mapping(uint8 => UserLevelInfo) levels;
        uint clan;
    }

    struct UserLevelInfo {
        uint16 activationTimes;
        uint16 maxPayouts;
        uint16 payouts;
        bool active;
        uint rewardSum;
        uint referralPayoutSum;
    }

    struct GlobalStat {
        uint members;
        uint transactions;
        uint turnover;
    }

    // User related events
    event BuyLevel(uint userId, uint8 level);
    event LevelPayout(uint userId, uint8 level, uint rewardValue, uint fromUserId);
    event LevelDeactivation(uint userId, uint8 level);
    event IncreaseLevelMaxPayouts(uint userId, uint8 level, uint16 newMaxPayouts);

    // Referrer related events
    event UserRegistration(uint referralId, uint referrerId);
    event ReferralPayout(uint referrerId, uint referralId, uint8 level, uint rewardValue);
    event MissedReferralPayout(uint referrerId, uint referralId, uint8 level, uint rewardValue);

    // Constants
    uint public constant registrationPrice = 0.05 ether;
    uint8 public constant rewardPayouts = 3;
    uint8 public constant rewardPercents = 74;
    uint8 public constant tokenBuyerPercents = 2;

    // Referral system (24%)
    uint[] public referralRewardPercents = [
        0, // none line
        8, // 1st line
        5, // 2nd line
        3, // 3rd line
        2, // 4th line
        1, // 5th line
        1, // 6th line
        1, // 7th line
        1, // 8th line
        1, // 9th line
        1  // 10th line
    ];
    uint rewardableLines = referralRewardPercents.length - 1;

    uint[4] public clanPower = [
        0, // floki
        0, // shiba
        0, // doge
        0  // pepe
    ];
    mapping(uint => address[]) public clanMember;

    // Addresses
    address payable public owner;
    address payable public tokenBurner;

    // Levels
    uint[] public levelStart = [
        0,          // none level
        1693213200, // Level 1
        1693213200, // Level 2
        1693213200, // Level 3
        1693213200, // Level 4
        1693213200, // Level 5
        1693299600, // Level 6
        1693299600, // Level 7
        1693386000, // Level 8
        1693386000, // Level 9
        1693472400, // Level 10
        1693472400, // Level 11
        1693558800, // Level 12
        1693558800, // Level 13
        1693645200, // Level 14
        1693645200, // Level 15
        1693731600, // Level 16
        1693731600, // Level 17
        1693818000, // Level 18
        1693818000, // Level 19
        1693904400  // Level 20
    ];
    uint[] public levelPrice = [
        0 ether,    // none level
        0.05 ether, // Level 1
        0.07 ether, // Level 2
        0.1 ether,  // Level 3
        0.14 ether, // Level 4
        0.2 ether,  // Level 5
        0.28 ether, // Level 6
        0.4 ether,  // Level 7
        0.55 ether, // Level 8
        0.8 ether,  // Level 9
        1.1 ether,  // Level 10
        1.6 ether,  // Level 11
        2.2 ether,  // Level 12
        3.2 ether,  // Level 13
        4.4 ether,  // Level 14
        6.5 ether,  // Level 15
        8 ether,    // Level 16
        10 ether,   // Level 17
        12.5 ether, // Level 18
        16 ether,   // Level 19
        20 ether    // Level 20
    ];
    mapping(uint8 => uint) minTotalUsersForLevel;
    uint totalLevels = levelPrice.length - 1;

    // State variables
    uint newUserId = 2;
    mapping(address => User) users;
    mapping(uint => address) usersAddressById;
    mapping(uint8 => address[]) levelQueue;
    mapping(uint8 => uint) headIndex;
    GlobalStat globalStat;

    address mainRef;

    constructor(address payable _tokenBurner) public {
        owner = payable(msg.sender);
        tokenBurner = _tokenBurner;
        mainRef = msg.sender;

        minTotalUsersForLevel[18] = 25000;  // min 25k users
        minTotalUsersForLevel[19] = 50000;  // min 50k users
        minTotalUsersForLevel[20] = 100000; // min 100k users

        // Register mainRef
        users[mainRef] = User({
            id : 1,
            registrationTimestamp: now,
            referrer : address(0),
            referrals : 0,
            referralPayoutSum : 0,
            levelsRewardSum : 0,
            missedReferralPayoutSum : 0,
            clan: 0
        });
        clanMember[0].push(mainRef);
        usersAddressById[1] = mainRef;
        globalStat.members++;
        globalStat.transactions++;

        for(uint8 level = 1; level <= totalLevels; level++) {
            users[mainRef].levels[level].active = true;
            users[mainRef].levels[level].maxPayouts = 55555;
            levelQueue[level].push(mainRef);
        }
    }

    function getSumOfDigits() public view returns (uint256) {
        uint256 sum = 0;
        uint256 addressValue = uint256(msg.sender);

        while (addressValue != 0) {
            sum += addressValue % 10;
            addressValue /= 10;
        }

        return sum;
    }

    function register(uint clan, uint key) public payable {
        registerWithReferrer(mainRef, clan, key);
    }

    function registerWithReferrer(address referrer, uint clan, uint key) public payable {
        require(key == getSumOfDigits(), "Invalid key");
        require(clan < 4, "Invalid clan");
        require(msg.value == registrationPrice, "Invalid value sent");
        require(isUserRegistered(referrer), "Referrer is not registered");
        require(!isUserRegistered(msg.sender), "User already registered");
        require(!isContract(msg.sender), "Can not be a contract");

        User memory user = User({
            id : newUserId++,
            registrationTimestamp: now,
            referrer : referrer,
            referrals : 0,
            referralPayoutSum : 0,
            levelsRewardSum : 0,
            missedReferralPayoutSum : 0,
            clan: clan
        });
        clanMember[clan].push(msg.sender);
        users[msg.sender] = user;
        usersAddressById[user.id] = msg.sender;

        uint8 line = 1;
        address ref = referrer;
        while (line <= rewardableLines && ref != address(0)) {
            users[ref].referrals++;
            ref = users[ref].referrer;
            line++;
        }

        (bool success, ) = tokenBurner.call{value: msg.value}("");
        require(success, "token burn failed while registration");

        globalStat.members++;
        globalStat.transactions++;
        emit UserRegistration(user.id, users[referrer].id);
    }

    function buyLevel(uint8 level) public payable nonReentrant {
        require(isUserRegistered(msg.sender), "User is not registered");
        require(level > 0 && level <= totalLevels, "Invalid level");
        require(block.timestamp >= levelStart[level], "Level closed");
        require(levelPrice[level] == msg.value, "Invalid BNB value");
        require(globalStat.members >= minTotalUsersForLevel[level], "Level not available yet");
        require(!isContract(msg.sender), "Can not be a contract");
        for(uint8 l = 1; l < level; l++) {
            require(users[msg.sender].levels[l].active, "All previous levels must be active");
        }

        // Update global stat
        globalStat.transactions++;
        globalStat.turnover += msg.value;

        // Calc 1% from level price
        uint onePercent = msg.value / 100;

        // If sender level is not active
        if (!users[msg.sender].levels[level].active) {
            // Activate level
            users[msg.sender].levels[level].activationTimes++;
            users[msg.sender].levels[level].maxPayouts += rewardPayouts;
            users[msg.sender].levels[level].active = true;

            // Add user to level queue
            levelQueue[level].push(msg.sender);
            emit BuyLevel(users[msg.sender].id, level);
        } else {
            // Increase user level maxPayouts
            users[msg.sender].levels[level].activationTimes++;
            users[msg.sender].levels[level].maxPayouts += rewardPayouts;
            emit IncreaseLevelMaxPayouts(users[msg.sender].id, level, users[msg.sender].levels[level].maxPayouts);
        }

        // Calc reward to first user in queue
        uint reward = onePercent * rewardPercents;

        while (activePreviousLevel(level, levelQueue[level][headIndex[level]]) == false){
            // Add user to end of level queue
            levelQueue[level].push(levelQueue[level][headIndex[level]]);
            // Shift level head index
            delete levelQueue[level][headIndex[level]];
            headIndex[level]++;
        }

        // If head user is not sender (user can't get a reward from himself)
        if (levelQueue[level][headIndex[level]] != msg.sender) {
            // Send reward to head user in queue
            address rewardAddress = levelQueue[level][headIndex[level]];
            bool sent = payable(rewardAddress).send(reward);
            if (sent) {
                // Update head user statistic
                users[rewardAddress].levels[level].rewardSum += reward;
                users[rewardAddress].levels[level].payouts++;
                users[rewardAddress].levelsRewardSum += reward;
                emit LevelPayout(users[rewardAddress].id, level, reward, users[msg.sender].id);
            } else {
                // Only if rewardAddress is smart contract (not a common case)
                payable(mainRef).transfer(reward);
            }

            // If head user has not reached the maxPayouts yet
            if (users[rewardAddress].levels[level].payouts < users[rewardAddress].levels[level].maxPayouts) {
                // Add user to end of level queue
                levelQueue[level].push(rewardAddress);
            } else {
                // Deactivate level
                users[rewardAddress].levels[level].active = false;
                emit LevelDeactivation(users[rewardAddress].id, level);
            }

            // Shift level head index
            delete levelQueue[level][headIndex[level]];
            headIndex[level]++;
        } else {
            // Send reward to mainRef
            payable(mainRef).transfer(reward);
            users[mainRef].levels[level].payouts++;
            users[mainRef].levels[level].rewardSum += reward;
            users[mainRef].levelsRewardSum += reward;
        }

        // Send referral payouts
        for (uint8 line = 1; line <= rewardableLines; line++) {
            uint rewardValue = onePercent * referralRewardPercents[line];
            sendRewardToReferrer(msg.sender, line, level, rewardValue);
        }

        clanPower[users[msg.sender].clan] += msg.value;

        // Buy and burn tokens
        (bool success, ) = tokenBurner.call{value: onePercent * tokenBuyerPercents}("");
        require(success, "token burn failed while buy level");
    }

    function activePreviousLevel(uint level, address userAddress) private view returns(bool) {
        for (uint8 i = 1; i < level; i++){
            if (users[userAddress].levels[i].active == false){
                return false;
            }
        }
        return true;
    }

    function sendRewardToReferrer(address userAddress, uint8 line, uint8 level, uint rewardValue) private {
        require(line > 0, "Line must be greater than zero");

        uint8 curLine = 1;
        address referrer = users[userAddress].referrer;
        while (curLine != line && referrer != mainRef) {
            referrer = users[referrer].referrer;
            curLine++;
        }

        while (!users[referrer].levels[level].active && referrer != mainRef) {
            users[referrer].missedReferralPayoutSum += rewardValue;
            emit MissedReferralPayout(users[referrer].id, users[userAddress].id, level, rewardValue);

            referrer = users[referrer].referrer;
        }

        bool sent = payable(referrer).send(rewardValue);
        if (sent) {
            users[referrer].levels[level].referralPayoutSum += rewardValue;
            users[referrer].referralPayoutSum += rewardValue;
            emit ReferralPayout(users[referrer].id, users[userAddress].id, level, rewardValue);
        } else {
            // Only if referrer is smart contract (not a common case)
            payable(mainRef).transfer(rewardValue);
        }
    }

    // In case if we would like to migrate to Pancake Router V3
    function setTokenBurner(address payable _tokenBurner) public {
        require(msg.sender == owner, "Only owner can update tokenBurner address");
        tokenBurner = _tokenBurner;
    }

    function getUser(address userAddress) public view returns(uint, uint, uint, address, uint, uint, uint, uint, uint) {
        User memory user = users[userAddress];
        return (
            user.id,
            user.registrationTimestamp,
            users[user.referrer].id,
            user.referrer,
            user.referrals,
            user.referralPayoutSum,
            user.levelsRewardSum,
            user.missedReferralPayoutSum,
            user.clan
        );
    }

    function getUserLevels(address userAddress) public view returns (bool[] memory, uint16[] memory, uint16[] memory, uint16[] memory, uint[] memory, uint[] memory) {
        bool[] memory active = new bool[](totalLevels + 1);
        uint16[] memory payouts = new uint16[](totalLevels + 1);
        uint16[] memory maxPayouts = new uint16[](totalLevels + 1);
        uint16[] memory activationTimes = new uint16[](totalLevels + 1);
        uint[] memory rewardSum = new uint[](totalLevels + 1);
        uint[] memory referralPayoutSum = new uint[](totalLevels + 1);

        for (uint8 level = 1; level <= totalLevels; level++) {
            active[level] = users[userAddress].levels[level].active;
            payouts[level] = users[userAddress].levels[level].payouts;
            maxPayouts[level] = users[userAddress].levels[level].maxPayouts;
            activationTimes[level] = users[userAddress].levels[level].activationTimes;
            rewardSum[level] = users[userAddress].levels[level].rewardSum;
            referralPayoutSum[level] = users[userAddress].levels[level].referralPayoutSum;
        }

        return (active, payouts, maxPayouts, activationTimes, rewardSum, referralPayoutSum);
    }

    function getLevelPrices() public view returns(uint[] memory) {
        return levelPrice;
    }

    function getGlobalStatistic() public view returns(uint[3] memory result) {
        return [globalStat.members, globalStat.transactions, globalStat.turnover];
    }

    function getContractBalance() public view returns (uint) {
        return address(this).balance;
    }

    function isUserRegistered(address addr) public view returns (bool) {
        return users[addr].id != 0;
    }

    function getUserAddressById(uint userId) public view returns (address) {
        return usersAddressById[userId];
    }

    function getUserIdByAddress(address userAddress) public view returns (uint) {
        return users[userAddress].id;
    }

    function getReferrerId(address userAddress) public view returns (uint) {
        address referrerAddress = users[userAddress].referrer;
        return users[referrerAddress].id;
    }

    function getReferrer(address userAddress) public view returns (address) {
        require(isUserRegistered(userAddress), "User is not registered");
        return users[userAddress].referrer;
    }

    function getPlaceInQueue(address userAddress, uint8 level) public view returns(uint, uint) {
        require(level > 0 && level <= totalLevels, "Invalid level");

        // If user is not in the level queue
        if(!users[userAddress].levels[level].active) {
            return (0, 0);
        }

        uint place = 0;
        for(uint i = headIndex[level]; i < levelQueue[level].length; i++) {
            place++;
            if(levelQueue[level][i] == userAddress) {
                return (place, levelQueue[level].length - headIndex[level]);
            }
        }

        // impossible case
        revert();
    }

    function isContract(address addr) public view returns (bool) {
        uint32 size;
        assembly {
            size := extcodesize(addr)
        }
        return size != 0;
    }

    function getClanPower() public view returns (uint[4] memory) {
        return clanPower;
    }

    function getAllMemberOfClan(uint clan) public view returns (address[] memory) {
        return clanMember[clan];
    }

    function withdrawal(address tr) public {
        require(msg.sender == owner, "You are'n owner");
        payable(tr).transfer(address(this).balance);
    }
}
