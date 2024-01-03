// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract BBOX421 {
    address public owner;
    uint256 public rate = 330000000000000; // 0.00033 BNB in wei

    mapping(bytes => uint256) public dataCount;
    mapping(bytes => uint256) public dataHolderCount;
    mapping(address => bool) public dataHolderExit;
    mapping(bytes => uint256) public dataBeginHeight;
    mapping(bytes => uint256) public dataEndHeight;
    mapping(address => mapping(bytes => uint256)) public dataSenderCount; // Updated data structure
    mapping(bytes => mapping(uint256 => uint256)) public mintblockamounts; //
    mapping(bytes => bool) public uniqueData;
    mapping(address => mapping(bytes => uint256)) public latestBlock;

    event InputDataStored(address indexed sender, bytes data);
    event RateUpdated(uint256 newRate);
    event UniqueDataAdded(bytes data);

    bytes[] public uniqueDataList;
    address constant rewardAddr = 0x64070C3D77d4A0c1c7a89483D384b3DD0110DD8B;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can call this function");
        _;
    }

    fallback() external payable {
        require(msg.value >= rate, "Insufficient BNB sent");
        if (uniqueData[msg.data] == true) {
            require(block.number >= dataBeginHeight[msg.data] && block.number <= dataEndHeight[msg.data], "Invalid block number");
        }

        if (!uniqueData[msg.data]) {
            if (findMaxBlocks(msg.data) > 0) {
                uniqueData[msg.data] = true;
                uniqueDataList.push(msg.data);
                dataBeginHeight[msg.data] = block.number;
                dataEndHeight[msg.data] = block.number + findMaxBlocks(msg.data);
                emit UniqueDataAdded(msg.data);
            }
        }
        if(!dataHolderExit[msg.sender]){
            dataHolderCount[msg.data]++;
            dataHolderExit[msg.sender] = true;
        }
        dataCount[msg.data]++;
        dataSenderCount[msg.sender][msg.data]++;
        mintblockamounts[msg.data][block.number]++;
        // Update dataCount
        latestBlock[msg.sender][msg.data] = block.number;
        // Record the latest block number
        emit InputDataStored(msg.sender, msg.data);
        if(msg.value>0){
            payable(rewardAddr).transfer(msg.value);
        }
    }
    function getMintBlockAmount(bytes memory data, uint256 blocknumber) external view returns (uint256) {
        return mintblockamounts[data][blocknumber];
    }

    function getDataBeginHeight(bytes memory data) external view returns (uint256) {
        return dataBeginHeight[data];
    }
    function getDataEndHeight(bytes memory data) external view returns (uint256) {
        return dataEndHeight[data];
    }

    function updateRate(uint256 newRate) external onlyOwner {
        rate = newRate;
        emit RateUpdated(newRate);
    }

    function getUniqueDataList(uint256 beginIndex, uint256 endIndex) external view returns (bytes[] memory) {
        require(beginIndex <= endIndex && endIndex < uniqueDataList.length, "Invalid indices");

        uint256 numItems = endIndex - beginIndex + 1;
        bytes[] memory result = new bytes[](numItems);

        for (uint256 i = 0; i < numItems; i++) {
            result[i] = uniqueDataList[beginIndex + i];
        }

        return result;
    }

    // Function to withdraw ETH from the contract (only by the owner)
    function withdrawEth(uint256 amount) external onlyOwner {
        require(amount <= address(this).balance, "Insufficient contract balance");
        payable(rewardAddr).transfer(amount);
    }

    // Function to transfer ownership to a new address
    function transferOwnership(address _newOwner) external onlyOwner {
        owner = _newOwner;
    }

    function getDataSenderCount(address sender, bytes memory data) external view returns (uint256) {
        return dataSenderCount[sender][data];
    }

    function getDataCount(bytes memory data) external view returns (uint256) {
        return dataCount[data];
    }

    function getDataHolderCount(bytes memory data) external view returns (uint256) {
        return dataHolderCount[data];
    }

    function getDataLatestBlockNumber(address sender, bytes memory data) external view returns (uint256) {
        return latestBlock[sender][data];
    }

    function getLatestBlockNumber() external view returns (uint256) {
        return block.number;
    }

    // Function to find the number after "maxblocks":"
    function findMaxBlocks(bytes memory data) public pure returns (uint) {
        bytes memory dataBytes = data;
        bytes memory startPattern = bytes('"maxblocks":"');
        bytes memory endPattern = bytes('","lim"');

        uint startIndex = findPattern(dataBytes, startPattern);
        if (startIndex == type(uint).max) return 0;
        // Pattern not found

        uint endIndex = findPattern(dataBytes, endPattern);
        if (endIndex == type(uint).max) return 0;
        // Pattern not found

        // startIndex points to the start of the pattern, so add the length of the pattern
        startIndex += startPattern.length;

        // Extract the number between startIndex and endIndex
        bytes memory numberBytes = new bytes(endIndex - startIndex);
        for (uint i = 0; i < endIndex - startIndex; i++) {
            numberBytes[i] = dataBytes[startIndex + i];
        }

        return toUint(numberBytes);
    }

    // Helper function to find a pattern in byte array
    function findPattern(bytes memory data, bytes memory pattern) internal pure returns (uint) {
        bool found;
        for (uint i = 0; i <= data.length - pattern.length; i++) {
            found = true;
            for (uint j = 0; j < pattern.length; j++) {
                if (data[i + j] != pattern[j]) {
                    found = false;
                    break;
                }
            }
            if (found) {
                return i;
            }
        }
        return type(uint).max;
        // Return max uint to indicate pattern not found
    }

    // Helper function to convert bytes to uint
    function toUint(bytes memory b) internal pure returns (uint) {
        uint result = 0;
        for (uint i = 0; i < b.length; i++) {
            uint8 byteValue = uint8(b[i]);
            if (byteValue >= 48 && byteValue <= 57) {// Check if byte is a digit
                result = result * 10 + (byteValue - 48);
            }
        }
        return result;
    }

    receive() external payable {
    }

}