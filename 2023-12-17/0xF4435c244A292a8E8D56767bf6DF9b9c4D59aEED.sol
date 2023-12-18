/**
 *Submitted for verification at BscScan.com on 2023-11-01
*/

pragma solidity ^0.8.0;

contract DailyTreasureEvent {
    address public owner;
    mapping(address => uint256) public lifetimeChestCount;
    mapping(address => uint256) public lifetimePremiumChestCount;
    mapping(address => bool) public premiumUsers;

    event ChestOpened(address indexed user, uint256 timestamp);
    event PremiumChestOpened(address indexed user, uint256 timestamp);
    event PremiumUserAdded(address user);
    event PremiumUserRemoved(address user);

    constructor(address[] memory initialPremiumUsers) {
        owner = msg.sender;
        // Push initial premium users into the contract
        for (uint256 i = 0; i < initialPremiumUsers.length; i++) {
            premiumUsers[initialPremiumUsers[i]] = true;
        }
    }

    function openChest() public {
        lifetimeChestCount[msg.sender]++;
        emit ChestOpened(msg.sender, block.timestamp);
    }

    function openPremiumChest() public {
        require(isPremiumUser(msg.sender), "Only premium users can open premium chests");
        lifetimePremiumChestCount[msg.sender]++;
        emit PremiumChestOpened(msg.sender, block.timestamp);
    }

    function isPremiumUser(address user) public view returns (bool) {
        return premiumUsers[user];
    }

    function addPremiumUser(address user) public {
        require(msg.sender == owner, "Only the owner can add premium users");
        premiumUsers[user] = true;
        emit PremiumUserAdded(user);
    }

    function removePremiumUser(address user) public {
        require(msg.sender == owner, "Only the owner can remove premium users");
        premiumUsers[user] = false;
        emit PremiumUserRemoved(user);
    }
}