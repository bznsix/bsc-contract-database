// SPDX-License-Identifier: MIT

pragma solidity 0.8.14;

// import hardhat console


contract PlaybuxRNG {
    // The address of the Owner
    address public s_owner;

    // Map of random numbers generated string => Array of random numbers generated
    mapping(string => uint256[]) public s_randomNumbersMap;

    // Event to log the generated random number
    event RandomNumberGenerated(string pool, uint256[] randomNumber);

    constructor() {
        s_owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == s_owner, "Only owner can call this function.");
        _;
    }

    // Function to generate multiple random numbers without duplication
    function generateSeveralRandomNumbers(
        uint256 salt,
        uint256 n,
        uint256 count,
        string memory pool
    ) external onlyOwner {
        require(s_randomNumbersMap[pool].length == 0, "Random numbers already generated for this pool.");

        // Combine the block hash and timestamp to create the seed
        // Unique seed for each call within the same block
        bytes32 seed = keccak256(
            abi.encodePacked(
                blockhash(block.number - 1), // Get the previous block hash
                block.timestamp, // Current block timestamp
                salt, // Salt provided by the owenr
                block.difficulty, // Difficulty of the current block
                block.coinbase // Current block miner's address
            )
        );

        // Generate count random numbers from the seed
        uint256 randomNumber;
        uint256 generatedCount = 0;
        uint256[] memory randomNumbers = new uint256[](count);
        while (generatedCount < count) {
            randomNumber = (uint256(seed) % n) + 1; // Generate a random number between 1 and n
            bool duplicate = false;
            for (uint256 i = 0; i < generatedCount; i++) {
                if (randomNumber == randomNumbers[i]) {
                    duplicate = true;
                    break;
                }
            }
            if (!duplicate) {
                randomNumbers[generatedCount] = randomNumber;
                generatedCount++;
            }
            seed = keccak256(abi.encodePacked(seed, randomNumber));
        }

        // Store the random numbers in the array
        s_randomNumbersMap[pool] = randomNumbers;

        // Emit the event
        emit RandomNumberGenerated(pool, randomNumbers);
    }

    function getRandomNumbersByPool(string memory pool) external view returns (uint256[] memory) {
        return s_randomNumbersMap[pool];
    }

    function setOwner(address owner) external onlyOwner {
        s_owner = owner;
    }
}
