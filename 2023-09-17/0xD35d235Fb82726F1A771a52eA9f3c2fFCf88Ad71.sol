// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract RandomWinner {
    address public owner;
    address[] public participants;
    uint256 public totalFunds;
    uint256 public playerCount; // Track the number of players

    event ParticipantJoined(uint256 playerNumber, address indexed participant, uint256 amount);
    event WinnerPicked(string category, address winner, uint256 amount);

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can call this function");
        _;
    }

    receive() external payable {
        require(msg.value == 0.001 ether, "You must send exactly 0.001 ether");

        playerCount++; // Increment player count
        participants.push(msg.sender);
        totalFunds += msg.value;

        emit ParticipantJoined(playerCount, msg.sender, msg.value);

        if (participants.length >= 5) {
            pickWinners();
        }
    }

    function clearContract() external onlyOwner {
        payable(owner).transfer(address(this).balance);
    }

    function pickWinners() internal {
        require(participants.length >= 5, "Not enough participants yet");

        uint256 totalAmount = totalFunds;
        uint256 winnerAmount1 = (totalAmount * 50) / 100; // 50% of the total funds
        uint256 winnerAmount2 = (totalAmount * 20) / 100; // 20% of the total funds
        uint256 winnerAmount3 = (totalAmount * 10) / 100; // 10% of the total funds
        uint256 ownerAmount = totalAmount - winnerAmount1 - winnerAmount2 - winnerAmount3; // Remaining 20% for the owner

        for (uint256 i = 0; i < 3; i++) {
            uint256 randomIndex = uint256(keccak256(abi.encodePacked(blockhash(block.number - 1), block.coinbase, block.gaslimit, i))) % participants.length;
            address winner = participants[randomIndex];
            uint256 winnerAmount;

            if (i == 0) {
                winnerAmount = winnerAmount1;
                emit WinnerPicked("Gold", winner, winnerAmount);
            } else if (i == 1) {
                winnerAmount = winnerAmount2;
                emit WinnerPicked("Silver", winner, winnerAmount);
            } else {
                winnerAmount = winnerAmount3;
                emit WinnerPicked("Bronze", winner, winnerAmount);
            }

            payable(winner).transfer(winnerAmount);
        }

        payable(owner).transfer(ownerAmount);

        delete participants;
        totalFunds = 0;
        playerCount = 0; // Reset player count
    }
}