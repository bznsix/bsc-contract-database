// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract RandomWinner {
    address public owner;
    address[] public participants;
    uint256 public totalFunds;
    bool public isGameActive;

    event ParticipantJoined(address indexed participant, uint256 amount);
    event WinnerPicked(address winner, uint256 amount);

    constructor() {
        owner = msg.sender;
        isGameActive = true;
    }

    modifier gameActive() {
        require(isGameActive, "Game is not active");
        _;
    }

    receive() external payable gameActive {
        require(msg.value == 0.001 ether, "You must send exactly 0.001 ether");

        participants.push(msg.sender);
        totalFunds += msg.value;

        emit ParticipantJoined(msg.sender, msg.value);

        if (participants.length == 3) {
            pickWinner();
        }
    }

    function clearContract() external {
        require(msg.sender == owner, "Only the owner can clear the contract");
        payable(owner).transfer(address(this).balance);
    }

    function pickWinner() internal gameActive {
        require(participants.length == 3, "Not enough participants yet");

        bytes32 combinedData = keccak256(abi.encode(blockhash(block.number - 1), block.coinbase, block.gaslimit));
        uint256 winnerIndex = uint256(combinedData) % participants.length;
        address winner = participants[winnerIndex];
        uint256 winnerAmount = (totalFunds * 80) / 100;
        uint256 ownerAmount = (totalFunds * 20) / 100;

        payable(winner).transfer(winnerAmount);
        payable(owner).transfer(ownerAmount);

        emit WinnerPicked(winner, winnerAmount);

        delete participants;
        totalFunds = 0;
        isGameActive = true;
    }
}