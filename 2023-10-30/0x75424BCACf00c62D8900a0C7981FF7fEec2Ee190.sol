// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

contract ReviewsContest {
    address private owner;
    
    mapping (string => bool) private _tempWinnerIdentifiers;
    
    constructor() {
        owner = msg.sender;
    }
    
    function playout(uint256 requiredWinnersCount, uint256[] memory ids, string[] memory identifiers) public {
        require(msg.sender == owner, "Caller is not owner");
        require(identifiers.length >= requiredWinnersCount, "Participants count should be equal or greater than required winners count");
        require(requiredWinnersCount > 0 && identifiers.length > 0, "Pariticipants and requried winners count should be greater than 0");
        require(ids.length == identifiers.length, "Ids and identifiers should has equal length");
        
        uint256 iterator = 0;
        uint256 currentWinnersCount = 0;
        bool[] memory winners = new bool[](identifiers.length);

        // For clear _tempWinnerIdentifiers mappping
        uint256[] memory winnerIndexes = new uint256[](requiredWinnersCount);
        
        while (currentWinnersCount < requiredWinnersCount) {
            bytes memory encoded = abi.encodePacked(
                ids,
                currentWinnersCount,
                iterator,
                block.timestamp,
                blockhash(block.number - 1),
                block.coinbase);
                
            iterator++;
            uint256 randomNumber = uint256(keccak256(encoded)) % identifiers.length;

            string memory identifier = identifiers[randomNumber];
            if (winners[randomNumber] || _tempWinnerIdentifiers[identifier])
            {
                continue;
            }
            
            winnerIndexes[currentWinnersCount] = randomNumber;
            winners[randomNumber] = true;
            _tempWinnerIdentifiers[identifier] = true;

            emit Win(ids[randomNumber], identifier);
            currentWinnersCount++;
        }

        // Clear mapping for next playout
        for (uint i = 0; i < winnerIndexes.length; i++) {
            _tempWinnerIdentifiers[identifiers[winnerIndexes[i]]] = false;
        }
    }
    
    event Win(uint256 id, string identifier);
}