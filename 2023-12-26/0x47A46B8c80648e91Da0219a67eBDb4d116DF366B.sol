// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

interface IERC20 {
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
}

contract LuckyBOX {
    address public verifyToken;
    address public rewardToken;
    
    mapping(address => uint256) public Box1_lastTimestamp;
    mapping(address => uint256) public Box2_lastTimestamp;
    mapping(address => uint256) public Box3_lastTimestamp;
    mapping(address => uint256) public Box4_lastTimestamp;

    constructor() {
        verifyToken = 0xa6784228Fa6A953D1D0D7e271A70Dff467f5d256; // verify Token
        rewardToken = 0xa6784228Fa6A953D1D0D7e271A70Dff467f5d256; // reward Token
    }

    function GrokBox1() public {
    uint256 tokenBalance = IERC20(verifyToken).balanceOf(msg.sender);
    uint256 requiredBalance = 1000000000 * 10**18;
    require(tokenBalance >= requiredBalance, "Insufficient token balance");
    require(block.timestamp >= Box1_lastTimestamp[msg.sender] + 86400 || Box1_lastTimestamp[msg.sender] == 0, "Claim cooldown has not passed yet");
    uint256 rewardAmount = generateRandom(10000000 * 10**18, 50000000 * 10**18); // reward Random with 18 decimals
    IERC20(rewardToken).transfer(msg.sender, rewardAmount);
    Box1_lastTimestamp[msg.sender] = block.timestamp;
    }
    function getLastBOX1Timestamp(address user) external view returns (uint256) {
        return Box1_lastTimestamp[user];
    }

    function GrokBox2() public {
    uint256 tokenBalance = IERC20(verifyToken).balanceOf(msg.sender);
    uint256 requiredBalance = 500000000 * 10**18;
    require(tokenBalance >= requiredBalance, "Insufficient token balance");
    require(block.timestamp >= Box2_lastTimestamp[msg.sender] + 86400 || Box2_lastTimestamp[msg.sender] == 0, "Claim cooldown has not passed yet");
    uint256 rewardAmount = generateRandom(5000000 * 10**18, 25000000 * 10**18); // reward Random with 18 decimals
    IERC20(rewardToken).transfer(msg.sender, rewardAmount);
    Box2_lastTimestamp[msg.sender] = block.timestamp;
    }
    function getLastBOX2Timestamp(address user) external view returns (uint256) {
        return Box2_lastTimestamp[user];
    }
    
    function GrokBox3() public {
    uint256 tokenBalance = IERC20(verifyToken).balanceOf(msg.sender);
    uint256 requiredBalance = 200000000 * 10**18;
    require(tokenBalance >= requiredBalance, "Insufficient token balance");
    require(block.timestamp >= Box3_lastTimestamp[msg.sender] + 86400 || Box3_lastTimestamp[msg.sender] == 0, "Claim cooldown has not passed yet");
    uint256 rewardAmount = generateRandom(2000000 * 10**18, 10000000 * 10**18); // reward Random with 18 decimals
    IERC20(rewardToken).transfer(msg.sender, rewardAmount);
    Box3_lastTimestamp[msg.sender] = block.timestamp;
    }
    function getLastBOX3Timestamp(address user) external view returns (uint256) {
        return Box3_lastTimestamp[user];
    }

    function GrokBox4() public {
    uint256 tokenBalance = IERC20(verifyToken).balanceOf(msg.sender);
    uint256 requiredBalance = 100000000 * 10**18;
    require(tokenBalance >= requiredBalance, "Insufficient token balance");
    require(block.timestamp >= Box4_lastTimestamp[msg.sender] + 86400 || Box4_lastTimestamp[msg.sender] == 0, "Claim cooldown has not passed yet");
    uint256 rewardAmount = generateRandom(1000000 * 10**18, 5000000 * 10**18); // reward Random with 18 decimals
    IERC20(rewardToken).transfer(msg.sender, rewardAmount);
    Box4_lastTimestamp[msg.sender] = block.timestamp;
    }
    function getLastBOX4Timestamp(address user) external view returns (uint256) {
        return Box4_lastTimestamp[user];
    }


    function generateRandom(uint256 min, uint256 max) internal view returns (uint256) {
    bytes32 hash = keccak256(abi.encodePacked(blockhash(block.number - 1), block.timestamp, msg.sender));
    uint256 randomNumber = uint256(hash);
    uint256 scaledRandomNumber = randomNumber % (max - min + 1);
    return scaledRandomNumber + min;
    }


}