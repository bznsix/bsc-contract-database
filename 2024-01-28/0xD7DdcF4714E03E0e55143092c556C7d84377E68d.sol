/**
 *
 *
 *  ███╗   ███╗ █████╗  ██████╗ ███████╗    ██╗    ██╗ █████╗ ██████╗ ███████╗    ██╗██╗
 *  ████╗ ████║██╔══██╗██╔════╝ ██╔════╝    ██║    ██║██╔══██╗██╔══██╗██╔════╝    ██║██║
 *  ██╔████╔██║███████║██║  ███╗█████╗      ██║ █╗ ██║███████║██████╔╝███████╗    ██║██║
 *  ██║╚██╔╝██║██╔══██║██║   ██║██╔══╝      ██║███╗██║██╔══██║██╔══██╗╚════██║    ██║██║
 *  ██║ ╚═╝ ██║██║  ██║╚██████╔╝███████╗    ╚███╔███╔╝██║  ██║██║  ██║███████║    ██║██║
 *  ╚═╝     ╚═╝╚═╝  ╚═╝ ╚═════╝ ╚══════╝     ╚══╝╚══╝ ╚═╝  ╚═╝╚═╝  ╚═╝╚══════╝    ╚═╝╚═╝
 *
 *
 *
 * ╔╗ ╔═╗╔╦╗╔╦╗╦  ╔═╗   ╔═╗╔═╗   ╔═╗╦═╗╔═╗╦ ╦╔╦╗╔═╗╔═╗╔═╗╔═╗
 * ╠╩╗╠═╣ ║  ║ ║  ║╣    ║ ║╠╣    ╠═╣╠╦╝║  ╠═╣║║║╠═╣║ ╦║╣ ╚═╗
 * ╚═╝╩ ╩ ╩  ╩ ╩═╝╚═╝   ╚═╝╚     ╩ ╩╩╚═╚═╝╩ ╩╩ ╩╩ ╩╚═╝╚═╝╚═╝
 *
 *
 *
 *  _____ _____ _____    _____ _____ _____ _____
 * |   | |   __|_   _|  |   __|  _  |     |   __|
 * | | | |   __| | |    |  |  |     | | | |   __|
 * |_|___|__|    |_|    |_____|__|__|_|_|_|_____|
 *
 *
 *
 *
 *
 *  MAGE WARS: BATTLE OF ARCHMAGES
 * This is an Economic Game built on a decentralized smart contract by Binance Smart Chain.
 *
 * You build your Guilds and Summon Mages to your tower.
 *
 * Mages for you with the help of spells will Collect Mana every hour, which you can exchange for Runes or BNB.
 * Invite friends and get FREE Crystals!
 *
 * Join an exciting Journey and participate in the Arena, where you can fight in a difficult battle with your opponents.
 *
 * Build a tower, Hire mages, fight in Arena and get infinite Wealth for yourself and your mages.
 *
 * Collect NFT Heroes and Get huge Profits !!!
 *
 *
 *  JOIN US:
 *
 * >>> TWITTER twitter.com/magewars_io
 *
 * >>> WEB: MAGEWARS.io
 *
 *
 *
 */

// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract MageWars is ReentrancyGuard {
    struct Tower {
        uint256 spellLevel;
        uint256 altarLevel;
        uint256 yield;
        uint256 yieldRunes;
        uint256 timestamp;
        uint256 hrs;
        uint256 maxHrs;
        address ref;
        uint256 refs;
        uint256 refDeps;
        uint256 refCrystals;
        uint8[8] mages;
    }

    struct Balance {
        uint256 runes;
        uint256 pendingRunes;
        uint256 crystals;
        uint256 money;
        uint256 money2;
    }

    struct Wars {
        uint256 wins;
        uint256 loses;
    }

    struct Arena {
        address player1;
        address player2;
        uint256 runes;
        uint256 timestamp;
        address winner;
        uint256 roll;
    }

    modifier onlyUser() {
        require(msg.sender == tx.origin);
        _;
    }

    modifier onlyRegistered() {
        require(towers[msg.sender].timestamp > 0, "User is not registered");
        _;
    }

    mapping(address => Tower) public towers;
    mapping(address => Balance) public balances;
    mapping(address => bool[5]) public armours;
    mapping(address => mapping(uint256 => Arena)) public arenas;
    mapping(address => Wars) public wars;
    mapping(uint256 => address) public waitingArenas;
    mapping(address => mapping(uint256 => mapping(uint256 => uint256)))
        public warsCounter;

    mapping(address => bool) public isCanSendRunes;
    mapping(address => bool) public isRefReceiveCrystal;

    uint256 public totalMages;
    uint256 public totalTowers;
    uint256 public totalInvested;
    uint256 public totalWars;

    address public defaultRef = 0xE4B669b8A61A91C17cd73123210bca560f8D930a;
    address private manager1;
    address private manager2;

    uint256 public constant ONE_DAY = 86400;

    // GUILD WAR:
    uint256 public constant INITIAL_BET = 100; // Initial bet for guild war in runes
    uint256 public constant TIME_EXTENSION = 10 minutes; // Time extension for guild war
    uint256 public constant ADMIN_FEE_PERCENT = 20; // Admin fee percent

    uint256 public guildWarId = 0;
    uint256 public guildWarTurnover = 0;
    uint256 public guildWarEndTime = 0;
    address public guildWarLastAddress = address(0);
    mapping(uint256 => mapping(address => uint256)) public guildWarBets;

    event GuildWarBetPlaced(uint256 warId, address user, uint256 runes);
    event GuildWarEnded(uint256 warId, address winner, uint256 prize);

    constructor(address _manager1, address _manager2) {
        manager1 = _manager1;
        manager2 = _manager2;
    }

    function _register(address user, address ref) internal {
        totalTowers++;
        ref = towers[ref].timestamp == 0 ? defaultRef : ref;
        towers[ref].refs++;
        towers[user].ref = ref;
        towers[user].maxHrs = 24;
        towers[user].timestamp = block.timestamp;
    }

    function _payCrystal(uint256 amount, address user) internal {
        if (amount < 500) return;
        if (isRefReceiveCrystal[user]) return;
        address ref = towers[user].ref;
        if (ref == address(0)) return;
        if (towers[ref].timestamp == 0) return;

        balances[ref].crystals += 1;
        towers[ref].refCrystals += 1;
        isRefReceiveCrystal[user] = true;
    }

    function addRunes(address ref) public payable nonReentrant onlyUser {
        uint256 runes = msg.value / 2e13;
        require(runes > 0, "Zero runes");
        address user = msg.sender;
        totalInvested += msg.value;

        if (towers[user].timestamp == 0) {
            _register(user, ref);
        }

        ref = towers[user].ref;
        balances[ref].runes += (runes * 7) / 100;
        balances[ref].money += (runes * 100 * 3) / 100;
        towers[ref].refDeps += runes;

        _payCrystal(runes, user);

        // Owner FEE
        uint256 runesFee = (runes * 8) / 100;
        uint256 moneyFee = (msg.value * 5) / 100;

        balances[manager1].runes += runesFee / 2;
        payable(manager1).transfer(moneyFee / 2);

        balances[manager2].runes += runesFee / 2;
        payable(manager2).transfer(moneyFee / 2);

        balances[user].runes += runes;
    }

    function withdrawMoney(
        uint256 amount
    ) public nonReentrant onlyUser onlyRegistered {
        require(amount >= 100, "Invalid amount");
        address user = msg.sender;
        balances[user].money -= amount;
        uint256 real = amount * 2e11;
        payable(user).transfer(
            address(this).balance < real ? address(this).balance : real
        );
    }

    function collectMoney() public nonReentrant onlyUser onlyRegistered {
        address user = msg.sender;
        syncTower(user);
        towers[user].hrs = 0;
        balances[user].money += balances[user].money2;
        balances[user].money2 = 0;
        balances[user].runes += balances[user].pendingRunes;
        balances[user].pendingRunes = 0;
    }

    function swapMoney(
        uint256 amount
    ) public nonReentrant onlyUser onlyRegistered {
        require(amount >= 100, "Invalid amount");
        address user = msg.sender;
        balances[user].money -= amount;
        balances[user].runes += amount / 100;
    }

    function buyCrystals(
        uint256 amount
    ) public nonReentrant onlyUser onlyRegistered {
        require(amount >= 1, "Invalid amount");
        address user = msg.sender;
        balances[user].runes -= amount * 10000;
        balances[user].crystals += amount;
    }

    function buyArmour(
        uint256 armourType
    ) public nonReentrant onlyUser onlyRegistered {
        require(armourType < 5, "Incorrect type");
        address user = msg.sender;
        require(armours[user][armourType] == false, "Already equipped");

        balances[user].runes -= getArmourPrice(armourType);
        balances[user].crystals -= getArmourPriceCrystal(armourType);

        syncTower(user);

        armours[user][armourType] = true;
        towers[user].yieldRunes += getArmourYield(armourType);
    }

    function sendRunes(
        address to,
        uint256 amount
    ) public nonReentrant onlyUser onlyRegistered {
        address user = msg.sender;
        require(isCanSendRunes[user], "Unlock first");
        require(balances[user].runes >= amount, "Not enough runes");
        require(towers[to].timestamp > 0, "Receiver is not registered");
        balances[user].runes -= amount;
        balances[to].runes += amount;
    }

    function unlockSendRunes() public nonReentrant onlyUser onlyRegistered {
        address user = msg.sender;
        require(isCanSendRunes[user] == false, "Already unlocked");
        balances[user].runes -= 40000;
        balances[user].crystals -= 5;
        isCanSendRunes[user] = true;
    }

    function upgradeTower(
        uint256 floorId
    ) public nonReentrant onlyUser onlyRegistered {
        require(floorId < 8, "Max 8 floors");
        require(
            totalInvested >= getRequiredTowerTurnover(floorId),
            "Not enough turnover"
        );

        address user = msg.sender;

        if (floorId == 0) {
            _payCrystal(500, user);
        }

        syncTower(user);
        towers[user].mages[floorId]++;
        totalMages++;
        uint256 mages = towers[user].mages[floorId];
        balances[user].crystals -= getUpgradeTowerPriceCrystal(floorId, mages);
        balances[user].runes -= getUpgradeTowerPrice(floorId, mages);
        towers[user].yield += getTowerYield(floorId, mages);
    }

    function upgradeAltar() public nonReentrant onlyUser onlyRegistered {
        address user = msg.sender;
        syncTower(user);
        balances[user].runes -= getUpgradeAltarPrice(towers[user].altarLevel);
        towers[user].maxHrs = getAltarHours(towers[user].altarLevel);
        towers[user].altarLevel += 1;
    }

    function upgradeSpells() public nonReentrant onlyUser onlyRegistered {
        address user = msg.sender;
        syncTower(user);

        balances[user].runes -= getUpgradeSpellPrice(towers[user].spellLevel);
        towers[user].spellLevel += 1;
    }

    function sellTower() public onlyUser onlyRegistered {
        collectMoney();
        address user = msg.sender;
        uint8[8] memory mages = towers[user].mages;
        totalMages -=
            mages[0] +
            mages[1] +
            mages[2] +
            mages[3] +
            mages[4] +
            mages[5] +
            mages[6] +
            mages[7];
        balances[user].money += towers[user].yield * 24 * 7;
        towers[user].mages = [0, 0, 0, 0, 0, 0, 0, 0];
        towers[user].spellLevel = 0;
        towers[user].altarLevel = 0;
        towers[user].maxHrs = 0;
        towers[user].yield = 0;
    }

    function getMages(address addr) public view returns (uint8[8] memory) {
        return towers[addr].mages;
    }

    function syncTower(address user) internal {
        require(towers[user].timestamp > 0, "User is not registered");
        uint256 hrs = block.timestamp / 3600 - towers[user].timestamp / 3600;

        if (hrs + towers[user].hrs > towers[user].maxHrs) {
            hrs = towers[user].maxHrs - towers[user].hrs;
        }

        if (towers[user].yieldRunes > 0) {
            uint256 runes = hrs * towers[user].yieldRunes;
            balances[user].pendingRunes += runes;
        }

        if (towers[user].yield > 0) {
            uint256 money = hrs * towers[user].yield;
            uint256 bonusPercent = getLeaderBonusPercent(towers[user].refs);

            if (towers[user].spellLevel > 0) {
                bonusPercent += getSpellYield(towers[user].spellLevel - 1);
            }

            money += (money * bonusPercent) / 100 / 100;

            balances[user].money2 += money;
            towers[user].hrs += hrs;
        }

        towers[user].timestamp = block.timestamp;
    }

    function getRequiredTowerTurnover(
        uint256 floorId
    ) internal pure returns (uint256) {
        return [0, 0, 0, 0, 0, 1000e18, 2500e18, 4000e18][floorId];
    }

    function getArmourPriceCrystal(
        uint256 armourType
    ) internal pure returns (uint256) {
        return [1, 2, 5, 10, 15][armourType];
    }

    function getArmourPrice(
        uint256 armourType
    ) internal pure returns (uint256) {
        return [10000, 20000, 30000, 60000, 100000][armourType];
    }

    function getUpgradeTowerPriceCrystal(
        uint256 floorId,
        uint256 mageId
    ) internal pure returns (uint256) {
        if (mageId == 1) return [0, 0, 0, 0, 1, 1, 2, 2][floorId];
        if (mageId == 2) return [0, 0, 0, 0, 2, 2, 4, 4][floorId];
        if (mageId == 3) return [0, 0, 0, 0, 3, 3, 6, 6][floorId];
        if (mageId == 4) return [0, 0, 0, 0, 4, 4, 8, 8][floorId];
        if (mageId == 5) return [0, 0, 0, 0, 5, 5, 10, 10][floorId];
        revert("Incorrect mageId");
    }

    function getUpgradeTowerPrice(
        uint256 floorId,
        uint256 mageId
    ) internal pure returns (uint256) {
        if (mageId == 1)
            return
                [500, 1500, 4500, 13500, 40500, 120000, 365000, 1000000][
                    floorId
                ];
        if (mageId == 2)
            return
                [625, 1800, 5600, 16800, 50600, 150000, 456000, 1200000][
                    floorId
                ];
        if (mageId == 3)
            return
                [780, 2300, 7000, 21000, 63000, 187000, 570000, 1560000][
                    floorId
                ];
        if (mageId == 4)
            return
                [970, 3000, 8700, 26000, 79000, 235000, 713000, 2000000][
                    floorId
                ];
        if (mageId == 5)
            return
                [1200, 3600, 11000, 33000, 98000, 293000, 890000, 2500000][
                    floorId
                ];
        revert("Incorrect mageId");
    }

    function getUpgradeSpellPrice(
        uint256 level
    ) internal pure returns (uint256) {
        return [10000, 20000, 50000, 75000, 100000][level];
    }

    function getUpgradeAltarPrice(
        uint256 level
    ) internal pure returns (uint256) {
        return [2000, 6000, 10000, 12000][level];
    }

    function getArmourYield(
        uint256 armourType
    ) internal pure returns (uint256) {
        if (armourType == 0) return 10;
        if (armourType == 1) return 20;
        if (armourType == 2) return 40;
        if (armourType == 3) return 65;
        if (armourType == 4) return 105;

        return 0;
    }

    function getTowerYield(
        uint256 floorId,
        uint256 mageId
    ) internal pure returns (uint256) {
        if (mageId == 1)
            return [41, 130, 399, 1220, 3750, 11400, 36200, 104000][floorId];
        if (mageId == 2)
            return [52, 157, 498, 1530, 4700, 14300, 45500, 126500][floorId];
        if (mageId == 3)
            return [65, 201, 625, 1920, 5900, 17900, 57200, 167000][floorId];
        if (mageId == 4)
            return [82, 264, 780, 2380, 7400, 22700, 72500, 216500][floorId];
        if (mageId == 5)
            return [103, 318, 995, 3050, 9300, 28700, 91500, 275000][floorId];
        revert("Incorrect mageId");
    }

    function getLeaderBonusPercent(
        uint256 refs
    ) internal pure returns (uint256) {
        if (refs >= 500) return 500;
        if (refs >= 450) return 450;
        if (refs >= 400) return 400;
        if (refs >= 350) return 350;
        if (refs >= 300) return 300;
        if (refs >= 250) return 250;
        if (refs >= 200) return 200;
        if (refs >= 150) return 150;
        if (refs >= 100) return 100;
        if (refs >= 50) return 50;
        return 0;
    }

    function getSpellYield(uint256 level) internal pure returns (uint256) {
        return [10, 20, 30, 40, 50][level];
    }

    function getAltarHours(uint256 level) internal pure returns (uint256) {
        return [30, 36, 42, 48][level];
    }

    // Arena:
    function createArena(
        uint256 arenaType
    ) public nonReentrant onlyUser onlyRegistered {
        require(arenaType < 3, "Incorrect type");

        uint256 timestamp = getStartOfDayTimestamp();
        require(
            warsCounter[msg.sender][timestamp][arenaType] <
                getArenaCount(arenaType),
            "You have reached the limit of wars per day"
        );

        address arenaCreator = waitingArenas[arenaType];
        require(msg.sender != arenaCreator, "You are already in arena");

        if (arenaCreator == address(0)) {
            _createArena(arenaType);
        } else {
            _joinArena(arenaType, arenaCreator);
            _fightArena(timestamp, arenaType, arenaCreator);
        }
    }

    function getArenaType(uint256 arenaType) internal pure returns (uint256) {
        return [1000, 10000, 50000][arenaType];
    }

    function getArenaCount(uint256 arenaType) internal pure returns (uint256) {
        return [5, 3, 2][arenaType];
    }

    function getStartOfDayTimestamp() public view returns (uint256) {
        return block.timestamp - (block.timestamp % ONE_DAY);
    }

    function _randomNumber() internal view returns (uint256) {
        uint256 randomnumber = uint256(
            keccak256(
                abi.encodePacked(
                    block.timestamp +
                        block.difficulty +
                        ((
                            uint256(keccak256(abi.encodePacked(block.coinbase)))
                        ) / (block.timestamp)) +
                        block.gaslimit +
                        ((uint256(keccak256(abi.encodePacked(msg.sender)))) /
                            (block.timestamp)) +
                        block.number
                )
            )
        );

        return randomnumber % 100;
    }

    function _createArena(uint256 arenaType) internal {
        arenas[msg.sender][arenaType].timestamp = block.timestamp;
        arenas[msg.sender][arenaType].player1 = msg.sender;
        arenas[msg.sender][arenaType].player2 = address(0);
        arenas[msg.sender][arenaType].winner = address(0);
        arenas[msg.sender][arenaType].runes = getArenaType(arenaType);
        arenas[msg.sender][arenaType].roll = 0;
        balances[msg.sender].runes -= arenas[msg.sender][arenaType].runes;
        waitingArenas[arenaType] = msg.sender;
    }

    function _joinArena(uint256 arenaType, address arenaCreator) internal {
        arenas[arenaCreator][arenaType].timestamp = block.timestamp;
        arenas[arenaCreator][arenaType].player2 = msg.sender;
        balances[msg.sender].runes -= arenas[arenaCreator][arenaType].runes;
        waitingArenas[arenaType] = address(0);
    }

    function _fightArena(
        uint256 timestamp,
        uint256 arenaType,
        address arenaCreator
    ) internal {
        uint256 random = _randomNumber();
        uint256 wAmount = arenas[arenaCreator][arenaType].runes * 2;
        uint256 fee = (wAmount * 10) / 100;

        address winner = random < 50
            ? arenas[arenaCreator][arenaType].player1
            : arenas[arenaCreator][arenaType].player2;
        address loser = random >= 50
            ? arenas[arenaCreator][arenaType].player1
            : arenas[arenaCreator][arenaType].player2;

        balances[winner].runes += wAmount - fee;
        arenas[arenaCreator][arenaType].winner = winner;
        arenas[arenaCreator][arenaType].roll = random;

        wars[winner].wins++;
        wars[loser].loses++;
        warsCounter[winner][timestamp][arenaType]++;
        warsCounter[loser][timestamp][arenaType]++;
        totalWars++;

        balances[manager1].runes += fee;
    }

    // GUILD WAR:
    function placeGuildWarBet() public nonReentrant onlyUser onlyRegistered {
        if (block.timestamp >= guildWarEndTime) {
            if (guildWarLastAddress != address(0)) {
                _endGuildWar();
            }
            _startGuildWar();
        } else {
            _placeGuildWarBet();
        }
    }

    function _startGuildWar() internal {
        require(balances[msg.sender].runes >= INITIAL_BET, "Not enough runes");
        guildWarId++;
        guildWarTurnover = 0;
        guildWarEndTime = 0;
        guildWarLastAddress = address(0);
        guildWarEndTime = block.timestamp;
        _placeGuildWarBet();
    }

    function _placeGuildWarBet() internal {
        uint256 lastBet = guildWarBets[guildWarId][msg.sender];
        uint256 requiredBet = lastBet * 2;

        if (requiredBet == 0) {
            requiredBet = INITIAL_BET;
        }

        require(balances[msg.sender].runes >= requiredBet, "Not enough runes");

        balances[msg.sender].runes -= requiredBet;

        guildWarBets[guildWarId][msg.sender] = requiredBet;
        guildWarLastAddress = msg.sender;
        guildWarTurnover += requiredBet;
        guildWarEndTime += TIME_EXTENSION;

        emit GuildWarBetPlaced(guildWarId, msg.sender, requiredBet);
    }

    function _endGuildWar() internal {
        require(block.timestamp >= guildWarEndTime, "Guild war is not over");

        uint256 adminFee = (guildWarTurnover * ADMIN_FEE_PERCENT) / 100;
        uint256 winnerPrize = guildWarTurnover - adminFee;

        balances[guildWarLastAddress].runes += winnerPrize;
        balances[manager1].runes += adminFee;

        emit GuildWarEnded(guildWarId, guildWarLastAddress, winnerPrize);
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        _nonReentrantBefore();
        _;
        _nonReentrantAfter();
    }

    function _nonReentrantBefore() private {
        // On the first call to nonReentrant, _status will be _NOT_ENTERED
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;
    }

    function _nonReentrantAfter() private {
        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Returns true if the reentrancy guard is currently set to "entered", which indicates there is a
     * `nonReentrant` function in the call stack.
     */
    function _reentrancyGuardEntered() internal view returns (bool) {
        return _status == _ENTERED;
    }
}
