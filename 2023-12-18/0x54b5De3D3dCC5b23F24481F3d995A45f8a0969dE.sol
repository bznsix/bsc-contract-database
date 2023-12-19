// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract WealthMe {
using SafeMath for uint256;

    address public owner;
    address public defaultReferrer = 0xD29B7fc082Ae829ad51fF8AD1F393464E14f0739;
    uint256 public constant PERCENT_DIVIDER = 10000;
    uint256 public constant TIME_STEP = 24 hours;
    uint256 public constant packPrice = 0.25 ether;
    uint256 public constant Team_FEE = 1000; // 10%
    uint256 public constant BoostNum = 1000; // 1 Boost Pack have 1000 positions

    struct Pack {
        uint256 packId;
        uint256 dailyInterest;
        uint256 rewardDays;
        uint256 boost;
        uint256 totalWithdrawn;
        uint256 checkpoint;
        uint256 unlockTime;
    }

    struct Partners {
        address referrer; // Upline address
        uint256 subNum; // 1 Level downline total amount
        address[] subOrdinates; // List of 1 level downline
        uint256 generations; // Record generations for 10 levels
    }

    struct User {
        uint256 totalInvested;
        uint256 totalWithdrawn;
        uint256 boostInterest;
        Pack[] packs;
    }

    struct SubordinateInfo {
        address walletAddress;
        User user;
    }

    mapping(address => User) public users;
    mapping(uint256 => Pack) public packs;
    mapping(address => Partners) public partners;
    uint256 public packCounter;
    uint256 public totalUsers;
    uint256 public totalBoostPurchased; // Records the total number of boost purchased, not the amount
    bool private isWithdrawing;

    event PackPurchased(address indexed user, uint256 packId, uint256 value);
    event PackUpgraded(address indexed user, uint256 packId, uint256 boost);
    event Withdrawn(address indexed user, uint256 amount);
    event BoostPurchased(
        address indexed user,
        uint256 boostAmount
    );

    constructor() {
        owner = msg.sender;
    }

    function purchasePacks(
        uint256 numPacks,
        address referrer
    ) external payable {
        require(numPacks > 0, "Number of packs must be greater than 0");
        require(msg.value >= numPacks.mul(packPrice), "Insufficient ETH sent");

        User storage user = users[msg.sender];

        if (user.totalInvested == 0) {
            totalUsers++;
        }

        uint256 generations = calculateGenerations(referrer); // Calculate the generations of the referrer
        recordReferral(msg.sender, referrer, msg.value, generations);

        uint256 startPackId = packCounter.add(1);
        uint256 endPackId = startPackId.add(numPacks).sub(1);

        for (uint256 i = startPackId; i <= endPackId; i++) {
            packs[i] = Pack({
                packId: i,
                dailyInterest: 150,
                rewardDays: 100,
                boost: 0,
                totalWithdrawn: 0,
                checkpoint: block.timestamp,
                unlockTime: block.timestamp
            });

            user.packs.push(packs[i]);
            packCounter = packCounter.add(1);
        }

        user.totalInvested = user.totalInvested.add(numPacks.mul(packPrice));

        uint256 teamFee = msg.value.mul(Team_FEE).div(PERCENT_DIVIDER);
        (bool teamFeeSuccess, ) = owner.call{value: teamFee}("");
        require(teamFeeSuccess, "Team fee transfer failed");

        emit PackPurchased(msg.sender, startPackId, msg.value);
    }

    function calculateGenerations(
        address referrer
    ) internal view returns (uint256) {
        uint256 generations = 0;
        address currentReferrer = referrer;
        while (currentReferrer != address(0) && generations < 10) {
            currentReferrer = partners[currentReferrer].referrer;
            generations = generations.add(1);
        }
        return generations;
    }

    function recordReferral(
        address sender,
        address referrer,
        uint256 value,
        uint256 generations
    ) internal {
        uint256 boostValue = value.mul(4).div(1e16);
        if (partners[sender].referrer == address(0)) {
            if (referrer != address(0) && referrer != sender && users[referrer].totalInvested > 0) {
                partners[sender].referrer = referrer;
                partners[referrer].subOrdinates.push(sender);
                partners[referrer].subNum = partners[referrer].subNum.add(1);
                partners[sender].generations = generations; // Record the generations of the referrer

                // Update boostInterest
                address currentReferrer = referrer;
                for (uint256 i = 0; i < generations; i++) {
                    uint256 boostInterest = boostValue.mul(100 - (i.mul(10))).div(100);
                    users[currentReferrer].boostInterest = users[currentReferrer].boostInterest.add(boostInterest);
                    currentReferrer = partners[currentReferrer].referrer;

                    if (currentReferrer == address(0)) {
                        break;
                    }
                }
            } else {
                partners[sender].referrer = defaultReferrer;
                partners[defaultReferrer].generations = generations; // Record the generations of the referrer

                // Update boostInterest
                address currentReferrer = defaultReferrer;
                for (uint256 i = 0; i < generations; i++) {
                    uint256 boostInterest = boostValue.mul(100 - (i.mul(10))).div(100);
                    users[currentReferrer].boostInterest = users[currentReferrer].boostInterest.add(boostInterest);
                    currentReferrer = partners[currentReferrer].referrer;

                    if (currentReferrer == address(0)) {
                        break;
                    }
                }
            }
        } else {
            address ref = partners[sender].referrer;
            // Update boostInterest
            address currentReferrer = ref;
            for (uint256 i = 0; i < partners[sender].generations; i++) {
                uint256 boostInterest = boostValue.mul(100 - (i.mul(10))).div(100);
                users[currentReferrer].boostInterest = users[currentReferrer].boostInterest.add(boostInterest);
                currentReferrer = partners[currentReferrer].referrer;

                if (currentReferrer == address(0)) {
                    break;
                }
            }
        }
    }

    function getSubOrdinates(address userAddress) public view returns (address[] memory) {
        return partners[userAddress].subOrdinates;
    }

    // Get 10 Levels Count
    function getSubordinateStats(
        address userAddress
    ) public view returns (uint256[] memory, uint256[] memory, uint256[] memory) {
        uint256[] memory walletCounts = new uint256[](10);
        uint256[] memory packCounts = new uint256[](10);
        uint256[] memory withdrawalAmounts = new uint256[](10);

        getSubordinateStatsRecursive(
            userAddress,
            0,
            walletCounts,
            packCounts,
            withdrawalAmounts
        );

        return (walletCounts, packCounts, withdrawalAmounts);
    }

    function getSubordinateStatsRecursive(
        address userAddress,
        uint256 level,
        uint256[] memory walletCounts,
        uint256[] memory packCounts,
        uint256[] memory withdrawalAmounts
    ) internal view {
        require(level < 10, "Exceeded maximum recursion depth");
        address[] memory subOrdinates = getSubOrdinates(userAddress);

        for (uint256 i = 0; i < subOrdinates.length; i++) {
            address subordinate = subOrdinates[i];

            walletCounts[level]++;
            packCounts[level] += users[subordinate].packs.length;
            withdrawalAmounts[level] += users[subordinate].totalWithdrawn;

            if (level < 9) {
                getSubordinateStatsRecursive(
                    subordinate,
                    level + 1,
                    walletCounts,
                    packCounts,
                    withdrawalAmounts
                );
            }
        }
    }
    // end

    function buyBoost(uint256 boostAmount) external payable {
        require(boostAmount > 0, "Boost amount must be greater than 0");
        require(msg.value >= boostAmount.mul(packPrice), "Insufficient ETH sent");

        uint256 totalBoost = boostAmount.mul(BoostNum);
        users[msg.sender].boostInterest = users[msg.sender].boostInterest.add(totalBoost);
        users[msg.sender].totalInvested = users[msg.sender].totalInvested.add(boostAmount.mul(packPrice));

        totalBoostPurchased = totalBoostPurchased.add(boostAmount); // Records the total number of boost purchased
        emit BoostPurchased(msg.sender, totalBoost);
    }

    function upgradePack(uint256 packId) external {
        require(packId <= packCounter, "Invalid packId");
        //require(users[msg.sender].boostInterest > 0, "No boost interest available");

        bool isPackOwned = false;
        for (uint256 i = 0; i < users[msg.sender].packs.length; i++) {
            if (users[msg.sender].packs[i].packId == packId) {
                isPackOwned = true;
                break;
            }
        }
        require(isPackOwned, "You do not own this pack");
        require(packs[packId].totalWithdrawn == 0, "Withdrawn packs cannot be upgraded");

        Pack storage pack = packs[packId];

        if (users[msg.sender].boostInterest > 0) {
            pack.boost = pack.boost.add(users[msg.sender].boostInterest);
            users[msg.sender].boostInterest = 0;
        }

        uint256 packIdElapsed = packCounter.add(totalBoostPurchased).add(pack.boost).sub(packId);

        if (packIdElapsed > 300000) {
            pack.dailyInterest = 200000;
            pack.rewardDays = 300;
            pack.unlockTime = block.timestamp;
        } else if (packIdElapsed > 250000) {
            pack.dailyInterest = 160000;
            pack.rewardDays = 300;
            pack.unlockTime = block.timestamp;
        } else if (packIdElapsed > 200000) {
            pack.dailyInterest = 120000;
            pack.rewardDays = 200;
            pack.unlockTime = block.timestamp;
        } else if (packIdElapsed > 160000) {
            pack.dailyInterest = 80000;
            pack.rewardDays = 200;
            pack.unlockTime = block.timestamp;
        } else if (packIdElapsed > 120000) {
            pack.dailyInterest = 50000;
            pack.rewardDays = 200;
            pack.unlockTime = block.timestamp;
        } else if (packIdElapsed > 80000) {
            pack.dailyInterest = 28000;
            pack.rewardDays = 200;
            pack.unlockTime = block.timestamp;
        } else if (packIdElapsed > 50000) {
            pack.dailyInterest = 10000;
            pack.rewardDays = 200;
            pack.unlockTime = block.timestamp;
        } else if (packIdElapsed > 20000) {
            pack.dailyInterest = 3200;
            pack.rewardDays = 200;
            pack.unlockTime = block.timestamp;
        } else if (packIdElapsed > 10000) {
            pack.dailyInterest = 1600;
            pack.rewardDays = 200;
            pack.unlockTime = block.timestamp;
        } else if (packIdElapsed > 5000) {
            pack.dailyInterest = 800;
            pack.rewardDays = 200;
            pack.unlockTime = block.timestamp;
        } else if (packIdElapsed > 2000) {
            pack.dailyInterest = 600;
            pack.rewardDays = 100;
            pack.unlockTime = block.timestamp;
        } else if (packIdElapsed > 1000) {
            pack.dailyInterest = 400;
            pack.rewardDays = 100;
            pack.unlockTime = block.timestamp;
        } else if (packIdElapsed > 500) {
            pack.dailyInterest = 300;
            pack.rewardDays = 100;
            pack.unlockTime = block.timestamp;
        } else if (packIdElapsed > 200) {
            pack.dailyInterest = 250;
            pack.rewardDays = 100;
            pack.unlockTime = block.timestamp;
        } else if (packIdElapsed > 75) {
            pack.dailyInterest = 200;
            pack.rewardDays = 100;
            pack.unlockTime = block.timestamp;
        }
        for (uint256 i = 0; i < users[msg.sender].packs.length; i++) {
            if (users[msg.sender].packs[i].packId == packId) {
                users[msg.sender].packs[i] = pack;
                break;
            }
        }

        emit PackUpgraded(msg.sender, packId, users[msg.sender].boostInterest);
    }

    function calculateEarnings(uint256 packId) public view returns (uint256) {
        Pack storage pack = packs[packId];
        uint256 timePassed = block.timestamp.sub(pack.checkpoint);
        return timePassed.mul(packPrice).mul(pack.dailyInterest).div(PERCENT_DIVIDER).div(TIME_STEP);
    }

    function calculateUserEarnings(address userAddress) external view returns (uint256) {
        User storage user = users[userAddress];
        uint256 totalEarnings = 0;
        for (uint256 i = 0; i < user.packs.length; i++) {
            totalEarnings = totalEarnings.add(calculateEarnings(user.packs[i].packId));
        }
        return totalEarnings;
    }

    function withdrawPackEarnings(uint256 packId) external {
        require(!isWithdrawing, "Withdrawal in progress");
        isWithdrawing = true;
        User storage user = users[msg.sender];
        require(user.packs.length > 0, "No investment packs owned");
        
        bool isPackOwned = false;
        uint256 earnings = 0;

        for (uint256 i = 0; i < user.packs.length; i++) {
            if (user.packs[i].packId == packId) {
                isPackOwned = true;
                earnings = calculateEarnings(packId);
                break;
            }
        }

        require(isPackOwned, "You do not own this pack");

        packs[packId].totalWithdrawn = packs[packId].totalWithdrawn.add(earnings);
        packs[packId].checkpoint = block.timestamp;
        user.totalWithdrawn = user.totalWithdrawn.add(earnings);

        uint256 contractBalance = address(this).balance;
        uint256 taxRate = calculateTaxRate(contractBalance);
        uint256 taxAmount = earnings.mul(taxRate).div(100);
        uint256 netEarnings = earnings.sub(taxAmount);

        // Boost rewards can also be claimed by the referrer during withdrawal
        if (netEarnings > 0 && contractBalance >= netEarnings) {
            address currentReferrer = partners[msg.sender].referrer;
            for (uint256 i = 0; i < partners[msg.sender].generations; i++) {
                uint256 boostValue = netEarnings.mul(4).div(1e16);
                uint256 boostInterest = boostValue.mul(100 - (i * 10)).div(100); // Calculate boostInterest based on generations
                users[currentReferrer].boostInterest = users[currentReferrer].boostInterest.add(boostInterest);
                currentReferrer = partners[currentReferrer].referrer;
            }

            (bool success, ) = msg.sender.call{value: netEarnings}("");
            require(success, "Transfer failed");
        }
        isWithdrawing = false;
    }

    function withdrawEarnings() external {
        require(!isWithdrawing, "Withdrawal in progress");
        isWithdrawing = true;
        User storage user = users[msg.sender];
        require(user.packs.length > 0, "No investment packs owned");
        
        uint256 totalEarnings = 0;
        for (uint256 i = 0; i < user.packs.length; i++) {
            uint256 packId = user.packs[i].packId;
            uint256 earnings = calculateEarnings(packId);
            totalEarnings = totalEarnings.add(earnings);
            packs[packId].totalWithdrawn = packs[packId].totalWithdrawn.add(earnings);
            packs[packId].checkpoint = block.timestamp;
        }
        user.totalWithdrawn = user.totalWithdrawn.add(totalEarnings);

        uint256 contractBalance = address(this).balance;
        uint256 taxRate = calculateTaxRate(contractBalance);
        uint256 taxAmount = totalEarnings.mul(taxRate).div(100);
        uint256 netEarnings = totalEarnings.sub(taxAmount);

        // Boost rewards can also be claimed by the referrer during withdrawal
        if (netEarnings > 0 && contractBalance >= netEarnings) {
            address currentReferrer = partners[msg.sender].referrer;
            for (uint256 i = 0; i < partners[msg.sender].generations; i++) {
                uint256 boostValue = netEarnings.mul(4).div(1e16);
                uint256 boostInterest = boostValue.mul(100 - (i * 10)).div(100); // Calculate boostInterest based on generations
                users[currentReferrer].boostInterest = users[currentReferrer].boostInterest.add(boostInterest);
                currentReferrer = partners[currentReferrer].referrer;
            }

            (bool success, ) = msg.sender.call{value: netEarnings}("");
            require(success, "Transfer failed");
        }
        isWithdrawing = false;
    }

    function calculateTaxRate(
        uint256 contractBalance
    ) internal pure returns (uint256) {
        if (contractBalance < 100 ether) {
            return 50; // 50% tax
        } else if (contractBalance < 300 ether) {
            return 40; // 40% tax
        } else if (contractBalance < 600 ether) {
            return 30; // 30% tax
        } else if (contractBalance < 1000 ether) {
            return 20; // 20% tax
        } else if (contractBalance < 2000 ether) {
            return 10; // 10% tax
        } else {
            return 0; // No tax
        }
    }
    
    function getContractBalance() external view returns (uint256) {
        return address(this).balance;
    }

    
    function getUserPackAttributes(address userAddress) external view returns (Pack[] memory) {
        User storage user = users[userAddress];
        Pack[] memory userPacks = new Pack[](user.packs.length);

        for (uint256 i = 0; i < user.packs.length; i++) {
            userPacks[i] = user.packs[i];
        }

        return userPacks;
    }


    function getUserInfo(address userAddress) external view returns (User memory) {
        return users[userAddress];
    }

    function getUserSubordinatesInfo(address userAddress) external view returns (SubordinateInfo[] memory) {
        address[] memory subordinates = partners[userAddress].subOrdinates;
        SubordinateInfo[] memory subordinateInfoList = new SubordinateInfo[](subordinates.length);

        for (uint256 i = 0; i < subordinates.length; i++) {
            address walletAddress = subordinates[i];
            User memory user = users[walletAddress];
            subordinateInfoList[i] = SubordinateInfo(walletAddress, user);
        }

        return subordinateInfoList;
    }


}


library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        uint256 c = a - b;
        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;
        return c;
    }
}