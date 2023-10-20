// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

interface IERC20 {
    function transfer(address to, uint amount) external returns (bool);
}

interface IHOF is IERC20 {
    function hold(address _owner, uint amount) external;

    function release(address _owner, uint amount) external;
}

contract HofAirdrop {
    IHOF public hofTokenContract;

    event RewardAirdrop(address indexed addr, uint amount);
    event InitializUnlocking(address indexed addr);
    event ClaimAirdrop(address indexed addr);

    struct AirdropUser {
        address addr;
        uint reward;
    }
    struct Airdrop {
        uint balance;
        bool claimed;
        bool initializeUnlocking;
        uint unlockDate;
        bool shared;
    }

    address owner;

    mapping(address => Airdrop) private airdrops;

    constructor(address hofContract) {
        owner = msg.sender;
        hofTokenContract = IHOF(hofContract);
    }

    function getSender() private view returns (address) {
        return msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    function getAirdrop() public view returns (Airdrop memory) {
        address sender = getSender();
        return airdrops[sender];
    }

    function shareAirdrop(AirdropUser[] memory perticipants) public onlyOwner {
        AirdropUser memory airdropUser;

        for (uint i = 0; i < perticipants.length; i++) {
            airdropUser = perticipants[i];
            if (airdrops[airdropUser.addr].shared) continue;

            airdrops[airdropUser.addr].balance = airdropUser.reward;
            airdrops[airdropUser.addr].shared = true;

            hofTokenContract.hold(airdropUser.addr, airdropUser.reward);
            hofTokenContract.transfer(airdropUser.addr, airdropUser.reward);
            emit RewardAirdrop(airdropUser.addr, airdropUser.reward);
        }
    }

    function initializeUnlock() public {
        address sender = getSender();
        Airdrop memory airdrop = airdrops[sender];
        require(!airdrop.initializeUnlocking, "unlocking already triggered");
        require(airdrop.balance > 0, "You don't have airdrop reward to claim");
        airdrops[sender].unlockDate = block.timestamp + 30 days;
        airdrops[sender].initializeUnlocking = true;
        emit InitializUnlocking(sender);
    }

    function claimAirdrop() public {
        address sender = getSender();
        Airdrop memory airdrop = airdrops[sender];
        require(
            airdrop.initializeUnlocking,
            "You have not unlocked your airdrop"
        );
        require(
            airdrop.unlockDate >= block.timestamp,
            "Your airdrop reward is not unlocked yet"
        );
        require(!airdrop.claimed, "You have already claimed your airdrop");
        airdrops[sender].claimed = true;
        hofTokenContract.release(sender, airdrop.balance);
        emit ClaimAirdrop(sender);
    }
}