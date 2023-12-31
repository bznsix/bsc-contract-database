// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;

/*
 * 
 *    ███╗   ██╗███████╗██╗  ██╗ █████╗ 
 *    ████╗  ██║██╔════╝██║ ██╔╝██╔══██╗
 *    ██╔██╗ ██║█████╗   █████  ███████║
 *    ██║╚██╗██║██╔══╝  ██╔═██╗ ██╔══██║
 *    ██║ ╚████║███████╗██║  ██╗██║  ██║
 *    ╚═╝  ╚═══╝╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝
 *       
 *       - NEXACHAIN: Next Generation -
 * 
 */

/**
 * @title NEXA Royalty Lottery Contract
 * This contract allows participants to enter a lottery by paying a fee.
 * The collected funds are distributed to selected winners.
 */
contract NEXA_ROYALTY_LOTTERY {
    
    // The owner's address. Only the owner can execute certain functions.
    address public owner;
    address public Admin; // Additional Admin role.

    // The fee required to participate in the lottery.
    uint public participationFee;

    // Array of participant addresses.
    address[] public participants;

    // Number of participants in the lottery.
    uint256 public NumberOfParticipants;

     // Number of total earnings.
    uint256 public totalDistributedAmount;

    // Mapping to track whether an address has already participated.
    mapping(address => bool) public hasParticipated;

    // Contract constructor that sets the initial participation fee.
    constructor(uint _participationFee) {
        owner = msg.sender; // Set the contract deployer as the owner.
        participationFee = _participationFee; // Set the initial participation fee.
        NumberOfParticipants = 1; 
        hasParticipated[owner] = true;
    }


       struct Winner {
      address winnerAddress;
      uint256 amountWon;
      }

      Winner[] public lastFiveWinners;

    // Modifier to restrict function access to only the contract owner.
    modifier onlyOwner {
        require(msg.sender == owner, "ONLY THE OWNER CAN CALL THIS FUNCTION");
        _;
    }
    
    // Modifier to restrict function access to only the Admin.
    modifier onlyAdmin {
        require(msg.sender == Admin , "ONLY THE ADMIN CAN CALL THIS FUNCTION");
        _;
    }

    // Set a new Admin for the contract.
    function SetAdmin(address _newAdmin) public onlyOwner {
        Admin = _newAdmin;
    }


    
    // Remove the Admin role from the contract.
    function RemoveAdmin() public onlyOwner {
        Admin = address(0);
    }

    // Allows the owner to change the participation fee.
    function setParticipationFee(uint _fee) public onlyOwner {
        participationFee = _fee;
    }

    // Allows an address to participate in the lottery.
    function participate(address _participant) public payable {
        require(msg.value == participationFee, "Incorrect participation fee");
        require(_participant != address(0), "Participant cannot be the zero address");
      

        participants.push(_participant);
        NumberOfParticipants++;
        hasParticipated[_participant] = true;
        HoldingFees();
    }

    // Allows owner to add a participant without participation fee.
    function participateOwn(address _participant) public payable onlyOwner {
        require(_participant != address(0), "Participant cannot be the zero address");
        participants.push(_participant);
        NumberOfParticipants++;
        hasParticipated[_participant] = true;
    }

    // Distributes the lottery funds to the specified winners.
    function distributeFunds(address payable[] memory winners) public onlyAdmin {
        uint256 totalBalance = address(this).balance;
        uint256 winnerShare = totalBalance / winners.length;
        uint256 remaining = totalBalance - (winnerShare * winners.length);

       

        for (uint i = 0; i < winners.length; i++) {
            winners[i].transfer(winnerShare);
           addWinner(winners[i], winnerShare);
        totalDistributedAmount += winnerShare; 

        }

        resetParticipants();

        if (remaining > 0) {
            payable(owner).transfer(remaining);

             
        }
    }

    // Transfer ownership of the contract to a new owner.
    function ChangeOwner(address _newOwner) public onlyOwner {
        owner = _newOwner;
          
    }

  
    function HoldingFees() internal {
        uint256 Hold = participationFee * 20 / 100;
        payable(owner).transfer(Hold);
    }

     function resetParticipants() private {
    for (uint i = 0; i < participants.length; i++) {
        hasParticipated[participants[i]] = false;
    }

    delete participants;
    NumberOfParticipants = 1;
}


     function addWinner(address payable winnerAddress, uint256 amountWon) private {

    lastFiveWinners.push(Winner(winnerAddress, amountWon));

 
    if (lastFiveWinners.length > 5) {
        for (uint i = 0; i < lastFiveWinners.length - 5; i++) {
            lastFiveWinners[i] = lastFiveWinners[i + 1];
        }
        lastFiveWinners.pop();
    }
}

function getLastFiveWinners() public view returns (Winner[] memory) {
    return lastFiveWinners;
}
       function getTotalDistributedAmount() public view returns (uint256) {
    return totalDistributedAmount;
}

function getCurrentBalance() public view returns (uint256) {
    return address(this).balance;
}
}