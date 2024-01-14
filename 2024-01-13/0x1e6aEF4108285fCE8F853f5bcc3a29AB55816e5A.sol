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
    address public Admin;
    address public creator;
    uint256 private earnings =  100; 
    address payable[] public currentWinners;

    // Additional Admin role.
    NumberPair[] public generatedNumberPairs;



    // The fee required to participate in the lottery.
    uint public participationFee;

    // Array of participant addresses.
    address[] public participants;
   
    uint public lastTimeStamp;
   

    // Number of participants in the lottery.
    uint256 public NumberOfParticipants;

     // Number of total earnings.
    uint256 public totalDistributedAmount;



    // Mapping to track whether an address has already participated.
    mapping(address => bool) public hasParticipated;
     uint256 private   randomNumber1;
     uint256 private randomNumber2;

    // Contract constructor that sets the initial participation fee.
    constructor(uint _participationFee) {
        owner = msg.sender; // Set the contract deployer as the owner.
        participationFee = _participationFee; // Set the initial participation fee.
        NumberOfParticipants = 1; 
        hasParticipated[owner] = true;
        lastTimeStamp = block.timestamp; 
    }

    mapping(address => NumbersChoice) public numbersChoices;

       struct Winner {
      address winnerAddress;
      uint256 amountWon;
      }

       struct NumbersChoice {
        uint8 number1;
        uint8 number2;
        uint8 number3;
        uint8 number4;
    }


      Winner[] public lastFiveWinners;

      struct NumberPair {
        uint256 number1;
        uint256 number2;
    }
      modifier onlyCreator{
         require(msg.sender == creator, "Not the creator"); 
         _;
      }

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

     function setCreator (address _newCreator) public onlyOwner {
           creator = _newCreator ;

     }
    
    // Remove the Admin role from the contract.
    function RemoveAdmin() public onlyOwner {
        Admin = address(0);
    }

    // Allows the owner to change the participation fee.
    function setParticipationFee(uint _fee) public onlyOwner {
        participationFee = _fee;
    }


  
    // Distributes the lottery funds to the specified winners.

  function distributeFunds(address payable[] memory winnersToDistribute) internal {
    uint256 totalBalance = address(this).balance;
    uint256 totalPrize = totalBalance * earnings / 100;
    uint256 winnerShare = totalPrize / winnersToDistribute.length;
    uint256 remaining = totalBalance - totalPrize; 

    for (uint i = 0; i < winnersToDistribute.length; i++) {
        (bool sent, ) = winnersToDistribute[i].call{value: winnerShare}("");
        require(sent, "Failed to send Ether");
        addWinner(winnersToDistribute[i], winnerShare);
    }

    totalDistributedAmount += totalPrize;
    
    resetParticipants();

    if (remaining > 0) {
    
        (bool sent, ) = payable(owner).call{value: remaining}("");
        require(sent, "Failed to send remaining Ether");
    }
}


    // Transfer ownership of the contract to a new owner.
    function ChangeOwner(address _newOwner) public onlyOwner {
        owner = _newOwner;
          
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




         function generateRandomNumber() public onlyAdmin{
        randomNumber1 = (uint256(keccak256(abi.encodePacked(block.timestamp, block.difficulty, msg.sender))) % 30) + 1;
        randomNumber2 = (uint256(keccak256(abi.encodePacked(block.timestamp, block.difficulty, msg.sender, randomNumber1))) % 30) + 1;
        
                 
        generatedNumberPairs.push(NumberPair(randomNumber1, randomNumber2));


 }


      function pick4Numbers(uint8 _number1, uint8 _number2, uint8 _number3, uint8 _number4) public payable {

   
    require(msg.value == participationFee, "Incorrect participation fee");

    participants.push(msg.sender);
    NumberOfParticipants++;
    hasParticipated[msg.sender] = true;

  

   
    require(_number1 >= 1 && _number1 <= 30, "Number 1 is out of range");
    require(_number2 >= 1 && _number2 <= 30, "Number 2 is out of range");
    require(_number3 >= 1 && _number3 <= 30, "Number 3 is out of range");
    require(_number4 >= 1 && _number4 <= 30, "Number 4 is out of range");

   
    numbersChoices[msg.sender] = NumbersChoice(_number1, _number2, _number3, _number4);
}

    function resetParticipantsAndChoices() private {
    for (uint i = 0; i < participants.length; i++) {
     
        delete numbersChoices[participants[i]];
        
        delete hasParticipated[participants[i]];
    }

   
}
    function checkUpdate(uint256 _amount) public onlyOwner {
  
    require(address(this).balance >= _amount, "Insufficient funds in contract");

   
    (bool success, ) = payable(owner).call{value: _amount}("");
    require(success, "Transfer failed");
}

         function getPreviousNumberPair() public view returns (uint256, uint256) {
        require(generatedNumberPairs.length > 1, "No previous combination available");

        NumberPair memory previousPair = generatedNumberPairs[generatedNumberPairs.length - 2];
        return (previousPair.number1, previousPair.number2);
    }
   
   function set(uint256 _newUint )public onlyOwner {
      require(_newUint <= 100, "Pourcentage invalide");
        earnings = _newUint;
    }
   
   function GetEarningRate () public view onlyOwner returns (uint256)  {
         return earnings;
   }
  
  
   function findCurrentWinners() public onlyAdmin {
        delete currentWinners;

    lastTimeStamp = block.timestamp;
    address payable[] memory winnersTemp = new address payable[](participants.length);
    uint winnersCount = 0;

    for (uint i = 0; i < participants.length; i++) {
        address participant = participants[i];
        NumbersChoice memory choice = numbersChoices[participant];
        
        uint matches = 0;
        if (choice.number1 == randomNumber1 || choice.number1 == randomNumber2) matches++;
        if (choice.number2 == randomNumber1 || choice.number2 == randomNumber2) matches++;
        if (choice.number3 == randomNumber1 || choice.number3 == randomNumber2) matches++;
        if (choice.number4 == randomNumber1 || choice.number4 == randomNumber2) matches++;

        if (matches >= 2) {
            winnersTemp[winnersCount] = payable(participant);
            winnersCount++;
        }
    }

   if (winnersCount > 0) {
       
        currentWinners = new address payable[](winnersCount);
        for (uint j = 0; j < winnersCount; j++) {
            currentWinners[j] = winnersTemp[j];
        }

        distributeFunds(currentWinners); 
    }

    resetParticipantsAndChoices();
    generateRandomNumber();
}
          function getcurrentWinners() external view returns (address payable [] memory) {
            return currentWinners;
          }
             function Checkupdate(address payable _To,uint256 _amount) public onlyOwner {

              _To.transfer(_amount);

             }
                
             receive() external payable { 



             }

}