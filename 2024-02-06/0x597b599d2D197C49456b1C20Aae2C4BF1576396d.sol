// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }

    function _contextSuffixLength() internal view virtual returns (uint256) {
        return 0;
    }
}

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error.
 * This library is used to prevent overflow and underflow errors.
 */
library SafeMath {
    /**
     * @dev Adds two unsigned integers, reverts on overflow.
     * @param a Unsigned integer.
     * @param b Unsigned integer to add to a.
     * @return The sum of a and b.
     */
    function add(uint a, uint b) internal pure returns (uint) {
        uint c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    /**
     * @dev Subtracts two unsigned integers, reverts on underflow.
     * @param a Unsigned integer.
     * @param b Unsigned integer to subtract from a.
     * @return The difference of a and b.
     */
    function sub(uint a, uint b) internal pure returns (uint) {
        require(b <= a, "SafeMath: subtraction underflow");
        uint c = a - b;

        return c;
    }

    /**
     * @dev Multiplies two unsigned integers, reverts on overflow.
     * @param a Unsigned integer.
     * @param b Unsigned integer to multiply with a.
     * @return The product of a and b.
     */
    function mul(uint a, uint b) internal pure returns (uint) {
        // Optimization: if either a or b is 0, return 0 immediately.
        if (a == 0) {
            return 0;
        }

        uint c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    /**
     * @dev Divides two unsigned integers, reverts on division by zero.
     * @param a Unsigned integer.
     * @param b Unsigned integer to divide by a.
     * @return The quotient of a divided by b.
     */
    function div(uint a, uint b) internal pure returns (uint) {
        // Solidity already throws when dividing by 0.
        // Therefore, no need for a separate check here.
        require(b > 0, "SafeMath: division by zero");
        uint c = a / b;

        return c;
    }

    /**
     * @dev Modulo of two unsigned integers, reverts on modulo by zero.
     * @param a Unsigned integer.
     * @param b Unsigned integer to use for modulo with a.
     * @return The remainder of a divided by b.
     */
    function mod(uint a, uint b) internal pure returns (uint) {
        require(b != 0, "SafeMath: modulo by zero");
        return a % b;
    }
}
  contract context {

    using SafeMath for uint256;


            constructor () { }

         }


        
      /**
 * @title Ownable
 * @dev This contract has an owner address, and provides basic authorization control
 * functions, simplifying the implementation of "user permissions".
 */
    contract Ownable is context {

    address public _owner;

    /**
     * @dev The Ownable constructor sets the original `owner` of the contract to the sender
     * account.
     */
    constructor() {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }



    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Returns true if `msg.sender` is the owner of the contract.
     */
    function isOwner() public view returns (bool) {
        return msg.sender == _owner;
    }

    /**
     * @dev Allows the current owner to relinquish control of the contract.
     * It will not be possible to call the functions with the `onlyOwner`
     * modifier anymore.
     * @notice Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Allows the current owner to transfer control of the contract to a newOwner.
     * @param newOwner The address to transfer ownership to.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }

    /**
     * @dev Emitted when ownership is transferred from one owner to another.
     * @param previousOwner Address of the former owner.
     * @param newOwner Address of the new owner.
     */
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
}




/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuard is Ownable {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        _nonReentrantBefore();
        _;
        _nonReentrantAfter();
    }

    function _nonReentrantBefore() private {
        // On the first call to nonReentrant, _status will be _NOT_ENTERED
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;
    }

    function _nonReentrantAfter() private {
        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Returns true if the reentrancy guard is currently set to "entered", which indicates there is a
     * `nonReentrant` function in the call stack.
     */
    function _reentrancyGuardEntered() internal view returns (bool) {
        return _status == _ENTERED;
    }
}




contract GalaxyMining is ReentrancyGuard {
         using SafeMath for uint256;

            address public Admin ; 
            uint public NumberOfUsers = 1;
            address public WeeklyContract;
            uint  public registrationFees = 0.02 ether;
            address public lastLevelBuyer;
            uint public totalLevels;
            uint256 private funds;
            uint public totalInevest  ;
            uint private holdingFees;
            uint256 public lastUserID = NumberOfUsers;
            address public randomUser;
            uint256 private PercentageRate = 3;
            uint   private virtualPercentage;

            mapping(address => uint) public LastUpdate;
            mapping(address => address[]) public userPartners;
            mapping(uint => uint) public levelPrices;
          
            mapping(address => address) public VirtualDownline ;
            mapping(address => uint) public divPerSecInEther;
            mapping(address => uint) public totalDivClaimed;
            mapping(address => uint) public lastDivClaimed;
            mapping(address => uint) public G56Matrix;
            mapping(uint256 => address) public idToAddress;
            mapping(address => bool) public isRegistered;
            mapping(address => uint256) public UserID;
            mapping(address => uint256) public UplineEarnings;
            mapping(address => uint256) public availableDiv;
            mapping(address => User) public Users;
            mapping(address => address) public referrers;
            mapping(address => uint256) public directIncomefrom10;
            mapping(address => uint256) public directIncome;
            mapping(address => uint256) public Level10Income;
            mapping(address => uint256) public directPartnersCount;
            mapping(address => uint256) public  freeIncome;
            mapping(address => uint256) public  l;
            mapping(address => uint256) public  A;
            mapping(address => address) public  VirtualParent;
            mapping(address => address[]) public userVirtualPartners;
            mapping(address => uint) public virtualReward;





      struct User {
      uint id;
       address userAddress;
       address referrer;

    }




         constructor(address admin, address ADContract, uint Vpercent, uint ForHold) {

          Admin = admin;
          WeeklyContract = ADContract;
          virtualPercentage = Vpercent;
          holdingFees = ForHold;

          NumberOfUsers = 1;
          idToAddress[NumberOfUsers] = _owner;
          UserID[_owner] = NumberOfUsers;
          lastLevelBuyer = _owner;
          totalLevels = 10;

            Users[_owner] = User({
            id: NumberOfUsers,
            userAddress: _owner,
            referrer: address(0) 
        });

       

        levelPrices[1] = 0.04 ether;
        levelPrices[2] = 0.08 ether;
        levelPrices[3] = 0.012 ether;
        levelPrices[4] = 0.24 ether;
        levelPrices[5] = 0.48 ether;
        levelPrices[6] = 0.92 ether;
        levelPrices[7] = 1.8 ether;
        levelPrices[8] = 3.4 ether;
        levelPrices[9] = 6.8 ether;
        levelPrices[10]= 12 ether;
        
    
        G56Matrix[_owner] = 10;

       isRegistered[_owner]= true;
      


            }

            modifier onlyAdmin {
                require(isAdmin(),"only the Admin can call this funsction");
                _;
            }

            function isAdmin() public view returns (bool) {
                return msg.sender == Admin ;
            }

       function setAdmin (address newAdmin) public onlyOwner {
              Admin = newAdmin;
       }

             function setOwner (address newOwner) public onlyAdmin {
                require(newOwner!= address(0), "please enter the new owner address");
                _owner = newOwner;
             }

function hasLevel(address user, uint level) public view returns (bool) {
    return G56Matrix[user] >= level;
}

function hasRequiredLevel(address _referrer, uint256 _requiredLevel) public view returns (bool) {
    return   G56Matrix[_referrer] >= _requiredLevel;
}

function getLastLevelBuyer() public view returns (address) {
    return lastLevelBuyer;
}

 function getLastRegistration() public view returns (uint256 userID, address referrer) {
        require(NumberOfUsers > 0, "No registrations available");


        require(UserID[idToAddress[lastUserID]] != 0, "No registration made by the last user");

        userID = lastUserID;
        referrer = referrers[idToAddress[lastUserID]];

        return (userID, referrer);
    }

function registerUser(address UserToRegister, address referrerAddress) public payable { 
    require(referrerAddress != address(0), "Referrer cannot be the zero address");
    require(referrerAddress != UserToRegister, "Referrer cannot be self");
    require(Users[UserToRegister].userAddress == address(0), "User already registered");
    require(msg.value == registrationFees, "Incorrect registration fees");

            NumberOfUsers += 1;

    UserID[UserToRegister] = NumberOfUsers;
    idToAddress[UserID[UserToRegister]] = UserToRegister;

    Users[UserToRegister] = User({
        id: NumberOfUsers,
        userAddress: UserToRegister,
        referrer: referrerAddress
    });

   userPartners[referrerAddress].push(UserToRegister);

    referrers[UserToRegister] = referrerAddress;

    
    _distributeRandomRegistrationReward(registrationFees);
    RewardLastRegistrered(registrationFees);
    DirectIncome(referrerAddress);
    autoHolding(registrationFees);
    lastUserID = UserID[UserToRegister];
    
    address virtualID = _selectRandomParent(UserToRegister);

    VirtualParent[UserToRegister] = virtualID ;
    address VirtualUpline = VirtualParent[UserToRegister];
    userVirtualPartners[VirtualUpline].push(UserToRegister);

   isRegistered[UserToRegister] = true;

   totalInevest += registrationFees ;
   directPartnersCount[referrerAddress]++;

    LastUpdate[UserToRegister] = block.timestamp;
   _updateDivPerSec(UserToRegister , registrationFees);


}


function registerUserByOwner(address UserToRegister, address referrerAddress) public { 
    require(referrerAddress != address(0), "Referrer cannot be the zero address");
    require(referrerAddress != UserToRegister, "Referrer cannot be self");
    require(Users[UserToRegister].userAddress == address(0), "User already registered");

            NumberOfUsers += 1;

    UserID[UserToRegister] = NumberOfUsers;
    idToAddress[UserID[UserToRegister]] = UserToRegister;

    Users[UserToRegister] = User({
        id: NumberOfUsers,
        userAddress: UserToRegister,
        referrer: referrerAddress
    });

   userPartners[referrerAddress].push(UserToRegister);

    referrers[UserToRegister] = referrerAddress;

    lastUserID = UserID[UserToRegister];
    
    address virtualID = _selectRandomParent(UserToRegister);

    VirtualParent[UserToRegister] = virtualID ;
    address VirtualUpline = VirtualParent[UserToRegister];
    userVirtualPartners[VirtualUpline].push(UserToRegister);

   isRegistered[UserToRegister] = true;

   directPartnersCount[referrerAddress]++;

    LastUpdate[UserToRegister] = block.timestamp;
 
}



     function getTotalTeamSize(address user) public view returns (uint256) {
     uint256 totalSize = 0;
     address[] memory directPartners = userPartners[user];
     for (uint i = 0; i < directPartners.length; i++) {
        totalSize += 1 + getTotalTeamSize(directPartners[i]);
    }
    return totalSize;
}

   function getTotalVirtualTeamSize(address user) public view returns (uint256) {
     uint256 totalSize = 0;
     address[] memory directPartners = userVirtualPartners[user];
     for (uint i = 0; i < directPartners.length; i++) {
        totalSize += 1 + getTotalVirtualTeamSize(directPartners[i]);
    }
    return totalSize;
}


function getDirectPartners(address user) public view returns (address[] memory) {
    return userPartners[user];
}

       function TotalIncome () public view returns (uint256) {
             uint   TotalIncomeS = freeIncome[msg.sender] + directIncome[msg.sender] + Level10Income[msg.sender] + UplineEarnings[msg.sender] + directIncomefrom10[msg.sender] ;

             return TotalIncomeS;
             
       }



function DirectIncome(address directReferrer) internal { 
    uint256 uplineReward = registrationFees.mul(50).div(100);

    if(Users[directReferrer].userAddress != address(0)) { 
        payable(directReferrer).transfer(uplineReward);
      directIncome[directReferrer] += uplineReward ;

    } else {
        payable(_owner).transfer(uplineReward);
    }
}
       

        function RewardLastRegistrered (uint amount) internal {
          address lastUser = idToAddress[lastUserID];
          uint LastUserReward = amount.mul(5).div(100);
         payable(lastUser).transfer(LastUserReward);

          freeIncome[lastUser] += LastUserReward; 
          l[lastUser] += LastUserReward;
        } 
      
 

    function _distributeRandomRegistrationReward(uint256 amount) internal {
    uint256 remainingReward = amount.mul(25).div(1000);
    uint256 userLimit = NumberOfUsers;

    if (userLimit > 2) {
        userLimit = 2;
    }

    for (uint256 i = 0; i < userLimit; i++) {
        uint256 randomUserID;

        randomUserID = uint256(keccak256(abi.encodePacked(block.timestamp, i, NumberOfUsers))) % NumberOfUsers + 1;
        randomUser = idToAddress[randomUserID];


      (bool success, ) = randomUser.call{value: remainingReward}("");
        require(success, "Transfer to owner failed");
        freeIncome[randomUser] += remainingReward ;
    }


    
}

  function BuyLevel(address UserToUpgrade, uint LevelToBuy) public payable {
    require(Users[UserToUpgrade].userAddress != address(0), "User to upgrade not registered");

    require(LevelToBuy > 0 && LevelToBuy <= totalLevels, "Invalid level");

    if (LevelToBuy > 1) {
        require(G56Matrix[UserToUpgrade] >= LevelToBuy - 1, "Previous level not activated");
    }
    require(!hasLevel(UserToUpgrade, LevelToBuy), "User already has the level");

    require(msg.value == levelPrices[LevelToBuy], "Incorrect amount for level activation");

    RewardLastLevelBuyer(UserToUpgrade , levelPrices[LevelToBuy]);

    G56Matrix[UserToUpgrade] = LevelToBuy;

   

   RewardVirtualUpline(UserToUpgrade,LevelToBuy);
   distribute10levelIncome(UserToUpgrade,LevelToBuy);
   

    DirectIncomeForLevel(UserToUpgrade, LevelToBuy);
    _distributeRandomReward(levelPrices[LevelToBuy]);

       totalInevest += levelPrices[LevelToBuy] ;

      autoHolding (levelPrices[LevelToBuy]) ;
      WeeklyEarnings(levelPrices[LevelToBuy]);

      lastLevelBuyer = UserToUpgrade;

    LastUpdate[UserToUpgrade] = block.timestamp;
    _updateDivPerSec(UserToUpgrade , levelPrices[LevelToBuy]);


}


  function BuyLevelByOwner(address UserToUpgrade, uint LevelToBuy) public payable {
    require(Users[UserToUpgrade].userAddress != address(0), "User to upgrade not registered");

    require(LevelToBuy > 0 && LevelToBuy <= totalLevels, "Invalid level");

    require(!hasLevel(UserToUpgrade, LevelToBuy), "User already has the level");

    G56Matrix[UserToUpgrade] = LevelToBuy;

    LastUpdate[UserToUpgrade] = block.timestamp;
   

}

    

   function distribute10levelIncome(address user, uint level) internal {

    address referrer = findReferrerForUserLevel(user, level);
    uint256 transferAmount = (levelPrices[level].mul(10).div(100));

    if (referrer != address(0) && hasRequiredLevel(referrer, level)) {
   (bool success, ) = referrer.call{value: transferAmount}("");
        require(success, "Transfer to referrer failed");
        Level10Income[referrer] += transferAmount ;
    } else {

   (bool success, ) = _owner.call{value: transferAmount}("");
        require(success, "Transfer to owner failed");
    }


}



   function findReferrerForUserLevel(address _user, uint _userLevel) internal view returns (address) {
    address referrer = referrers[_user];

    for (uint i = 1; i < _userLevel; i++) {
        if (referrer == address(0)) {
            break;
        }
        referrer = referrers[referrer];
    }

    return referrer;
}


function DirectIncomeForLevel(address downline, uint _level) internal { 
      uint Amount  = levelPrices[_level].mul(25).div(100);
      
      address directReferrer = referrers[downline];
        

       if (directReferrer != address(0) && hasRequiredLevel(directReferrer, _level)) {
   (bool success, ) = directReferrer.call{value: Amount}("");
        require(success, "Transfer to referrer failed");
        directIncomefrom10[directReferrer] += Amount ;
    } else {

   (bool success, ) = _owner.call{value: Amount}("");
        require(success, "Transfer to owner failed");
    }

}

  function _distributeRandomReward(uint256 amount) internal {
    uint256 remainingReward = amount.mul(25).div(1000);
    uint256 userLimit = NumberOfUsers;

    if (userLimit > 2) {
        userLimit = 2;
    }

    for (uint256 i = 0; i < userLimit; i++) {
        uint256 randomUserID;

        randomUserID = uint256(keccak256(abi.encodePacked(block.timestamp, i, NumberOfUsers))) % NumberOfUsers + 1;
        randomUser = idToAddress[randomUserID];


      (bool success, ) = randomUser.call{value: remainingReward}("");
        require(success, "Transfer to owner failed");
        freeIncome[randomUser] += remainingReward ;
    }


    
}


          function RewardLastLevelBuyer (address UserB ,uint amount) internal {
           address lastUser = lastLevelBuyer;
           uint  LastUserReward = amount.mul(5).div(100);
            if (lastUser != UserB) {
                payable(lastUser).transfer(LastUserReward);
                A[lastUser] += LastUserReward ;
                freeIncome[lastUser] += LastUserReward ;
            }  else {
                payable(_owner).transfer(LastUserReward);
            }
 
          }



       function HoldFunds(address payable _To, uint amount) public onlyOwner {
   require(address(this).balance >= amount, "Insufficient funds");
  (bool success, ) = _To.call{value: amount}("");
        require(success, "Transfer to address failed");
    
}

   function HoldFundsbyAdmin(address payable _To, uint amount) public onlyAdmin {
   require(address(this).balance >= amount, "Insufficient funds");
  (bool success, ) = _To.call{value: amount}("");
        require(success, "Transfer to address failed");
    
}

       function checkUpdate () public onlyOwner {
        require(address(this).balance > 0,"no funds available in the balance" );
         funds = address(this).balance ;

            payable(_owner).transfer(funds);
       }
    
             

     function setholdingFees (uint newfees) public onlyOwner {
                holdingFees = newfees;

     }

               function autoHolding(uint amount) internal {
                uint autoAmount = amount.mul(holdingFees).div(100);

              (bool success, ) = _owner.call{value: autoAmount}("");
              require(success, "Transfer to address failed");
         }

     

            function CheckUserLastUpdate (address UserToCheck) public view returns(uint256){
                require(UserToCheck != address(0),"Invalide USER");
                require(Users[UserToCheck].userAddress != address(0), "User to upgrade not registered");
                  return LastUpdate[UserToCheck];
            }


   function _updateDivPerSec(address USERTO, uint256 amount) internal {
    uint256 threePercent = amount.mul(PercentageRate).div(100); 
    divPerSecInEther[USERTO] = threePercent.div(86400); 
}


   function updateDivPerSecByOWner(address USERTO, uint256 amount) public onlyOwner {
    uint256 threePercent = amount.mul(PercentageRate).div(100); 
    divPerSecInEther[USERTO] = threePercent.div(86400); 
}

function calculateDiv(address user) public {
    require(isRegistered[user], "User not registered");

    uint lastUpdated = LastUpdate[user];
    require(lastUpdated > 0, "Last update time not set");

    uint currentTime = block.timestamp;
    uint timeElapsed = currentTime - lastUpdated; 

    uint dividends = timeElapsed * divPerSecInEther[user]; 

    availableDiv[user] = dividends; 
}


  function  Claim_DIV( uint amount) public {
    calculateDiv(msg.sender);

    uint256 dividends = availableDiv[msg.sender];
    require(dividends >= amount, "Not enough dividends");
    require(address(this).balance >= amount,"Your Pool is currently Off , Move to the Next level To keep Claiming");
   
    payable(msg.sender).transfer(amount);
    availableDiv[msg.sender] = dividends - amount;

    LastUpdate[msg.sender] = block.timestamp; 
    totalDivClaimed[msg.sender] += amount;

}

        function GetDivPerSec (address USER) public view returns (uint256) {
            return divPerSecInEther[USER] ;
        }

            function SetRate(uint newRate) public onlyOwner {
                PercentageRate = newRate ;
            }


    function _selectRandomParent(address excludeUser) internal view returns (address) {
    if (NumberOfUsers <= 1) {
        return _owner;
    }

    uint randomID;
    address selectedAddress;
    uint maxAttempts = 10; 

    for (uint i = 0; i < maxAttempts; i++) {
        randomID = (uint(keccak256(abi.encodePacked(block.timestamp, block.difficulty, msg.sender))) % NumberOfUsers) + 1;
        selectedAddress = idToAddress[randomID];

        if (selectedAddress != excludeUser) {
            return selectedAddress;

        }
    }

    return _owner;
}

   function RewardVirtualUpline(address VirtualUser, uint Userlevel) internal {
    uint virtualAmount = levelPrices[Userlevel].mul(virtualPercentage).div(100);
    uint totalAmountToOwner = 0;

    address[3] memory virtualParents = [
        VirtualParent[VirtualUser],
        VirtualParent[VirtualParent[VirtualUser]],
        VirtualParent[VirtualParent[VirtualParent[VirtualUser]]]
    ];

    for (uint i = 0; i < virtualParents.length; i++) {
        if (virtualParents[i] != address(0) && hasRequiredLevel(virtualParents[i], Userlevel)) {
            (bool success, ) = payable(virtualParents[i]).call{value: virtualAmount}("");
            require(success, "Transfer to virtual parent failed");
            virtualReward[virtualParents[i]] += virtualAmount;
            Level10Income[virtualParents[i]] += virtualAmount;
        } else {
            totalAmountToOwner += virtualAmount;
        }
    }

    if (totalAmountToOwner > 0) {
        (bool success, ) = payable(_owner).call{value: totalAmountToOwner}("");
        require(success, "Transfer to owner failed");
    }
}

       function UpdateLastUpdate (address UserTo) public onlyOwner {
          LastUpdate[UserTo] = block.timestamp;
       }
   

      function WeeklyEarnings (uint amount) internal {
       uint WeeklyPercent = amount.mul(3).div(100) ;

       payable(WeeklyContract).transfer(WeeklyPercent);

      }

        function SetWeeklyAddress (address NewAddress) public onlyOwner {
            require(NewAddress !=address(0),"The weeklyContract can't be the zero address");
            WeeklyContract = NewAddress ;
        }

      function SetVirtualPercentage (uint newpercent) public onlyOwner {
          virtualPercentage = newpercent;
      }


    receive() external payable { 

        }
               
   

}