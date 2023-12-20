// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

contract foodtopianFF {
    uint256 public devFeePercentage;
    uint256 public devFeeBalance;
    address public owner;

    struct Game {
        address player1;
        address player2;
        uint256 betAmount;
        bool isActive;
        address winner;
        address lastWinner;
        uint256 gameStartTime;
    }

    Game[4] public games;

    event GameCreated(uint256 indexed gameId, address indexed player1, uint256 betAmount);
    event GameJoined(uint256 indexed gameId, address indexed player2);
    event GameCancelled(uint256 indexed gameId);
    event WinnerDecided(uint256 indexed gameId, address indexed winner);
    event DevFeeWithdrawn(address indexed owner, uint256 amount);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can call this function.");
        _;
    }

    constructor(uint256 _devFeePercentage) {
        owner = msg.sender;
        devFeePercentage = _devFeePercentage;
    }

    function createGame(uint256 gameId) external payable {
        require(gameId >= 0 && gameId < 4, "Invalid game ID.");
        require(!games[gameId].isActive, "Game is already active.");
        require(msg.value > 0, "Bet amount must be greater than 0.");

        games[gameId] = Game({
            player1: msg.sender,
            player2: address(0),
            betAmount: msg.value,
            isActive: true,
            winner: address(0),
            lastWinner: games[gameId].lastWinner, // Keep the last winner
            gameStartTime: 0 // Initialized to 0; will be set when the second player joins
        });

        emit GameCreated(gameId, msg.sender, msg.value);
    }

    function joinGame(uint256 gameId) external payable {
        require(gameId >= 0 && gameId < 4, "Invalid game ID.");
        require(games[gameId].isActive, "Game is not active.");
        require(games[gameId].player2 == address(0), "Game already has a second player.");
        require(msg.value == games[gameId].betAmount, "Bet amount does not match.");

        games[gameId].player2 = msg.sender;
        games[gameId].gameStartTime = block.timestamp;

        emit GameJoined(gameId, msg.sender);
    }

    function cancelGame(uint256 gameId) external {
        require(gameId >= 0 && gameId < 4, "Invalid game ID.");
        require(games[gameId].isActive, "Game is not active.");
        require(
            games[gameId].player1 == msg.sender || msg.sender == owner,
            "Only the creator or owner can cancel the game."
        );

        payable(games[gameId].player1).transfer(games[gameId].betAmount);
        delete games[gameId];

        emit GameCancelled(gameId);
    }

    function setDevFeePercentage(uint256 _devFeePercentage) external onlyOwner {
        require(_devFeePercentage <= 100, "Dev fee percentage cannot be more than 100.");
        devFeePercentage = _devFeePercentage;
    }

    function withdrawDevFee() external onlyOwner {
        uint256 amount = devFeeBalance;
        require(amount > 0, "No dev fees available for withdrawal");

        devFeeBalance = 0;
        payable(owner).transfer(amount);

        emit DevFeeWithdrawn(owner, amount);
    }

    function decideWinner(uint256 gameId) external {
        require(gameId >= 0 && gameId < 4, "Invalid game ID.");
        require(games[gameId].isActive, "Game is not active.");
        require(games[gameId].player2 != address(0), "Game does not have a second player.");
        require(block.timestamp >= games[gameId].gameStartTime + 5, "Cannot decide winner yet.");

       uint256 randomResult = (block.timestamp + block.prevrandao + gameId) % 2;
        games[gameId].winner = randomResult == 0 ? games[gameId].player1 : games[gameId].player2;

        // Calculate and transfer the developer's fee
        uint256 devFee = (games[gameId].betAmount * 2 * devFeePercentage) / 100;
        uint256 payout = (games[gameId].betAmount * 2) - devFee;
        devFeeBalance += devFee;
        payable(games[gameId].winner).transfer(payout);

        // Emit the event for the decided winner
        emit WinnerDecided(gameId, games[gameId].winner);

        // Keep the last winner before resetting the game
        address lastWinner = games[gameId].winner;

        // Reset the game
        games[gameId] = Game({
            player1: address(0),
            player2: address(0),
            betAmount: 0,
            isActive: false,
            winner: address(0),
            lastWinner: lastWinner, // Set the last winner
            gameStartTime: 0
        });
    }

    // Read function to get the last winner of a game
    function getLastWinner(uint256 gameId) public view returns (address) {
        require(gameId >= 0 && gameId < 4, "Invalid game ID.");
        return games[gameId].lastWinner;
    }

}