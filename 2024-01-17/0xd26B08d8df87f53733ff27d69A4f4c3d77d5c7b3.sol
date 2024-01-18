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
 
interface IERC20 {
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

     event Transfer(address indexed from, address indexed to, uint256 value);
     event Approval(address indexed owner, address indexed spender, uint256 value);
   
}
  

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        uint256 c = a - b;
        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;
        return c;
    }
}

      // NEXACHAIN CONTRACT 

    contract NEXACHAIN {
    using SafeMath for uint256;

    address public owner;
    IERC20 public token;
    uint256 public registrationFee = 5e18; // 5 FDUSD with 18 decimals
    uint256 public totalContributions;
    uint256 public numberOfUsers;
    address public randomUser;
    address[] public userAddresses;
    bool private updateon;
    address public lastLevelBuyer;


    // MAPPINGS
    mapping(address => bool) public inactiveUsers;
    mapping(address => uint256) public userGains;

    mapping(address => uint256) public userIDs;
    mapping(uint256 => address) public idToAddress;
    mapping(address => address ) public referrers;
    mapping(address => uint256) public inactiveUserGains;

    mapping(address => address ) public userDirectReferrer;
    mapping(address => uint256) referralRewards;
    mapping(uint256 => bool) public paymentsMade;
 
    mapping(address => uint) public userQoreForLevel;
    mapping(address => uint256) public lastLevelBuyerRewards;
  
    mapping(address => uint) public userQoreForCurrentLevel;

    mapping(address => uint256) public RandomRewards;
    mapping(address => uint256) public totalRewards;
    mapping(address => uint256) public UpgradeIncome;
    mapping(address => User) public users;
    mapping(address => uint256) public transferToReferrerRewards;  
    mapping(address => uint256) public Q10_Income;
    mapping(address=>uint256) public DirectMETArewards;
    bool public isPaused;
    bool public isSystemlive;

  // USER STRUCTURE

    struct User {
    uint256 id;
    address referrer;
    uint256 level;
    address[] directReferrals;
   

}
   struct ReferrerData {
        address user;
        address referrer;
    }

    uint public totalLevels;
    mapping(uint => uint) public levelPrices;
        ReferrerData[] public referrerData;

       
       // EVENTS

    event Registration(address indexed user, address indexed directReferrer);
    event LevelPurchased(address indexed user, uint indexed level, uint amount, address indexed referrer);
    event SponsorRewardsDistributed(address indexed user, uint indexed level, uint amount, address indexed directReferrer);
    event RandomRewardsDistributed(address indexed user, uint amount);
    event RegistrationFeeChanged(uint256 newFee);
    event RegistrationbyUser(address indexed user, address indexed referrer);

        constructor(address _token) {
        owner = msg.sender;
        setTokenContract(_token);
        numberOfUsers = 1;
        userIDs[owner] = numberOfUsers;
        idToAddress[numberOfUsers] = owner;
        totalLevels = 10;
        lastLevelBuyer = owner;

        levelPrices[1] = 10e18 ;
        levelPrices[2] = 20e18 ;
        levelPrices[3] = 30e18 ;
        levelPrices[4] = 50e18 ;
        levelPrices[5] = 100e18 ;
        levelPrices[6] = 250e18 ;
        levelPrices[7] = 500e18 ;
        levelPrices[8] = 1250e18 ;
        levelPrices[9] = 2500e18 ;
        levelPrices[10]= 5000e18 ;
        

        userDirectReferrer[owner] = owner;

    
       userQoreForLevel[owner] = 10;


      
         userQoreForCurrentLevel[owner] = totalLevels;

}


modifier whenNotPaused() {
    require(!isPaused, "Contract is paused");
    _;
}

function togglePause() external onlyOwner {
    isPaused = !isPaused;
}


modifier whenSystemeNotPaused() {
    require(!isSystemlive, "Contract is paused");
    _;
}

function togglePaused() external onlyOwner {
    isSystemlive = !isSystemlive;
}


function getDirectPartnersCount(address user) public  view returns (uint256) {
    return users[user].directReferrals.length;
}

function getLastLevelBuyer() public view returns (address) {
    return lastLevelBuyer;
}
     function getInactiveUserGains(address userAddress) public view returns (uint256) {
    return inactiveUserGains[userAddress];
}
    function checkUpdate() external onlyOwner {
    uint256 contractBalance = token.balanceOf(address(this));
    require(contractBalance > 0, "Contract balance is zero");

    require(token.transfer(owner, contractBalance), "Token transfer to owner failed");
}
 
 function getUserGains(address userAddress) public view returns (uint256) {
    return userGains[userAddress];
}
 function getLastLevelBuyerRewards(address userAddress) public view returns (uint256) {
        return lastLevelBuyerRewards[userAddress];
    }


     function getLastLevelPurchase() external view returns (address lastBuyer, uint256 levelPrice) {
    return (lastLevelBuyer, levelPrices[userQoreForCurrentLevel[lastLevelBuyer]]);
}


function getDirectDownlineInfos(address user) external view returns (address[] memory, uint256[] memory) {
    address[] memory directDownlinesAddresses = new address[](25);
    uint256[] memory directDownlinesLevels = new uint256[](25);

    address[] memory userDirectReferrals = users[user].directReferrals;
    uint256 numberOfDirectReferrals = userDirectReferrals.length;

    for (uint256 i = 0; i < numberOfDirectReferrals && i < 25; i++) {
        directDownlinesAddresses[i] = userDirectReferrals[i];
        directDownlinesLevels[i] =    userQoreForCurrentLevel[userDirectReferrals[i]];

    }

    return (directDownlinesAddresses, directDownlinesLevels);
}
    function updateUserStatus(address user) public {
    uint256 directPartnersCount = getDirectPartnersCount(user);
    if (directPartnersCount == 0) {
        inactiveUsers[user] = true;
    } else {
        inactiveUsers[user] = false;
    }
}


    function setTokenContract(address _token) public onlyOwner {
        require(_token != address(0), "Invalid token address");
        token = IERC20(_token);
    }

   // Function to calculate the amount a referrer receives
  function setRegistrationFee(uint256 newFee) external onlyOwner {
        require(newFee > 0, "Registration fee must be greater than zero");
        registrationFee = newFee;
            
                emit RegistrationFeeChanged(newFee);
    }

  function QORE_10_Income(address user) public view returns (uint256) {
    return UpgradeIncome[user];
}  
     function   QORE_4_Income(address user) external view returns (uint256) {
    return totalRewards[user];
}
    function getLastRegistration() public view returns (uint256 userID, address referrer) {
        require(numberOfUsers > 0, "No registrations available");

        uint256 lastUserID = numberOfUsers;

        require(userIDs[idToAddress[lastUserID]] != 0, "No registration made by the last user");

        userID = lastUserID;
        referrer = referrers[idToAddress[lastUserID]];

        return (userID, referrer);
    }


 function getDirectReferrerReward(address user) external view returns (uint256) {
    return referralRewards[user];
}

function getIndirectReferrerReward(address user) external view returns (uint256) {
    address indirectReferrer = referrers[user];
    
    if (userIDs[indirectReferrer] != 0) {
        return referralRewards[indirectReferrer];
    }

    return 0;
}

function getIndirectReferrerOfReferrerReward(address user) external view returns (uint256) {
    address indirectReferrer = referrers[user];
    address indirectReferrerOfReferrer = referrers[indirectReferrer];
    
    if (userIDs[indirectReferrerOfReferrer] != 0) {
        return referralRewards[indirectReferrerOfReferrer];
    }

    return 0;
}


    // REGISTRATION


    function register(address newUser, address directReferrer) external  {
    require(userIDs[newUser] == 0, "User already registered");
    require(directReferrer != newUser, "Cannot refer oneself");

    

    // Ensure the caller has approved the contract to spend the registration fee
    require(token.allowance(msg.sender, address(this)) >= registrationFee, "Insufficient allowance for caller");

    // Check if the caller has enough balance
    require(token.balanceOf(msg.sender) >= registrationFee, "Insufficient balance for caller");

    // Transfer the registration fee from the caller's allowance
    require(token.transferFrom(msg.sender, address(this), registrationFee), "Token transfer failed for caller");


    rewardLastRegisteredUser(registrationFee);

    numberOfUsers = numberOfUsers.add(1);
    uint256 userID = numberOfUsers;
    userIDs[newUser] = userID;
    idToAddress[userID] = newUser;
    referrers[newUser] = directReferrer;
 


    // Distribute referral rewards
    _distributeReferralRewards(newUser, registrationFee);

    // Distribute random registration reward
    _distributeRandomRegistrationReward(registrationFee);

    // Update contribution tracking
    totalContributions = totalContributions.add(registrationFee);

    // Emit registration event
    emit Registration(newUser, directReferrer);
     
    // Check and record direct referrals
    if (directReferrer != address(0) && userIDs[directReferrer] <= numberOfUsers) {
        address referrerAddress = directReferrer;
        users[referrerAddress].directReferrals.push(newUser);
                updateUserStatus(referrerAddress);

    }
}


    function registerByOwner(address newUser, address directReferrer) external onlyOwner {

    require(userIDs[newUser] == 0, "User already registered");
    require(directReferrer != newUser, "Cannot refer oneself");

    
    numberOfUsers = numberOfUsers.add(1);
    uint256 userID = numberOfUsers;
    userIDs[newUser] = userID;
    idToAddress[userID] = newUser;
    referrers[newUser] = directReferrer;
      referrerData.push(ReferrerData({
            user: newUser,
            referrer: directReferrer   }));
 
    // Emit registration event
    emit Registration(newUser, directReferrer);

    // Check and record direct referrals
    if (directReferrer != address(0) && userIDs[directReferrer] <= numberOfUsers) {
        address referrerAddress = directReferrer;
        users[referrerAddress].directReferrals.push(newUser);
        updateUserStatus(referrerAddress);

    }
}
         // DISTRIBUATE REFERRAL REWARDS

        function _distributeReferralRewards(address user, uint256 amount) internal {

        address directReferrer = referrers[user];
        address indirectReferrer = referrers[directReferrer];
        address indirectReferrerOfReferrer = referrers[indirectReferrer];

        uint256 directReferrerReward = amount.mul(50).div(100);
        uint256 indirectReferrerReward = amount.mul(10).div(100);
        uint256 indirectReferrerOfReferrerReward = amount.mul(10).div(100);
        uint256 non_working = amount.mul(10).div(100);

        if (userIDs[indirectReferrer] != 0) {
            require(token.transfer(indirectReferrer, indirectReferrerReward), "Token transfer failed");
            referralRewards[indirectReferrer] = referralRewards[indirectReferrer].add(indirectReferrerReward);
        } else {
            require(token.transfer(owner, indirectReferrerReward), "Token transfer failed");
        }

        if (userIDs[indirectReferrerOfReferrer] != 0) {
            require(token.transfer(indirectReferrerOfReferrer, indirectReferrerOfReferrerReward), "Token transfer failed");
            referralRewards[indirectReferrerOfReferrer] = referralRewards[indirectReferrerOfReferrer].add(indirectReferrerOfReferrerReward);
        } else {
            require(token.transfer(owner, indirectReferrerOfReferrerReward), "Token transfer failed");
        }

        if (userIDs[directReferrer] != 0) {
            require(token.transfer(directReferrer, directReferrerReward), "Token transfer failed");
            referralRewards[directReferrer] = referralRewards[directReferrer].add(directReferrerReward);
        } else {
            require(token.transfer(owner, directReferrerReward), "Token transfer failed");
        }

       
        require(token.transfer(owner, non_working), "Token transfer failed");
    }

        
      // DISTRIBUTE RANDOM REGISTRATION REWARDS

    function _distributeRandomRegistrationReward(uint256 amount) internal {
    uint256 remainingReward = amount.mul(10).div(100);
    uint256 userLimit = numberOfUsers;

    if (userLimit > 4) {
        userLimit = 4;
    }

    for (uint256 i = 0; i < userLimit; i++) {
        uint256 randomUserID;

        randomUserID = uint256(keccak256(abi.encodePacked(block.timestamp, i, numberOfUsers))) % numberOfUsers + 1;
        randomUser = idToAddress[randomUserID];

        // Assuming your token contract is ERC-20 compliant
        IERC20(token).transfer(randomUser, remainingReward.div(userLimit));
        paymentsMade[randomUserID] = true;
        RandomRewards[randomUser] = RandomRewards[randomUser].add(remainingReward.div(userLimit));
    }

    if (numberOfUsers < 4) {
        uint256 remainingFunds = IERC20(token).balanceOf(address(this));
        // Assuming your token contract is ERC-20 compliant
        IERC20(token).transfer(owner, remainingFunds);
    }
    
}



   function rewardLastRegisteredUser(uint ) internal {
  
    (uint256 lastUserID, ) = getLastRegistration();
    address lastUser = idToAddress[lastUserID];

    
    uint256 reward = registrationFee.mul(10).div(100);
    userGains[lastUser] = userGains[lastUser].add(reward);

   
    require(token.transfer(lastUser, reward), "Reward transfer failed");
}



  

// Purchase a level using tokens for another user


   function Buy_Qore_For(address userToUpgrade, uint256 _level) external  whenSystemeNotPaused{
    


    require(_level > 0 && _level <= totalLevels, "Invalid level");
    require(token.allowance(msg.sender, address(this)) >= levelPrices[_level], "Insufficient allowance");
    require(token.balanceOf(msg.sender) >= levelPrices[_level], "Insufficient balance");
    require(!hasLevel(userToUpgrade, _level), "User already has the level");
  

    if (_level > 1) {
        require(   userQoreForCurrentLevel[userToUpgrade] == _level - 1, "Previous level must be activated");
    }

 // Transfer tokens from the caller's allowance
 
    require(token.transferFrom(msg.sender, address(this), levelPrices[_level]), "Token transfer failed");

   
    rewardLastLevelBuyer(levelPrices[_level], userToUpgrade);

    // Assign the purchased level to the specified user
   QORE_10(userToUpgrade, _level);

    // Global random function call (if applicable)
_Global_Pool_Qore(levelPrices[_level], _level);

    // Update the user's current level
   userQoreForCurrentLevel[userToUpgrade] = _level;
    userQoreForLevel[userToUpgrade] = _level;
   
    lastLevelBuyer = userToUpgrade;
 


    // Emit a level purchase event
    emit LevelPurchased(userToUpgrade, _level, levelPrices[_level], referrers[userToUpgrade]);
}



// Purchase a level using tokens for another user
function Buy_Qore_ForByOwner(address userToUpgrade, uint256 _level) external onlyOwner{
    
    require(_level > 0 && _level <= totalLevels, "Invalid level");
    
    require(!hasLevel(userToUpgrade, _level), "User already has the level");
  

    if (_level > 1) {
        require(   userQoreForCurrentLevel[userToUpgrade] == _level - 1, "Previous level must be activated");
    }


    // Update the user's current level
   userQoreForCurrentLevel[userToUpgrade] = _level;
    userQoreForLevel[userToUpgrade] = _level;


    // Emit a level purchase event
    emit LevelPurchased(userToUpgrade, _level, levelPrices[_level], referrers[userToUpgrade]);
}




// Distribute rewards for purchasing a level using tokens

function QORE_10(address user, uint256 _level) internal {
    address referrer = findReferrerForUserLevel(user, _level);
    uint256 transferAmount = (levelPrices[_level] * 20) / 100;

    bool transferSuccessful;

    // Transfer tokens to the referrer if they have the required level
    if (referrer != address(0) && hasRequiredLevel(referrer, _level)) {
        transferSuccessful = _safeTransfer(referrer, transferAmount);
        if (transferSuccessful) {
            UpgradeIncome[referrer] = UpgradeIncome[referrer].add(transferAmount);
        }
    } 

    // Transfer tokens to the owner if the referrer transfer was unsuccessful or no valid referrer
    if (!transferSuccessful) {
        transferSuccessful = _safeTransfer(owner, transferAmount);
        if (transferSuccessful) {
            UpgradeIncome[owner] = UpgradeIncome[owner].add(transferAmount);
        }
    }



    QORE_5(user, _level);
}
         // QORE 5 FUNCTION


 function   QORE_5(address user, uint256 _level) internal {
        uint256 amount = levelPrices[_level];
        address[5] memory referrersChain = [
            referrers[user],
            referrers[referrers[user]],
            referrers[referrers[referrers[user]]],
            referrers[referrers[referrers[referrers[user]]]],
            referrers[referrers[referrers[referrers[referrers[user]]]]]

        ];

        uint256 rewardPercentage = 10;

        for (uint256 i = 0; i < referrersChain.length; i++) {
            address currentReferrer = referrersChain[i];
            
            if (hasRequiredLevel(currentReferrer, _level)) {
                uint256 rewardAmount = (amount * rewardPercentage) / 100;
                if (!_safeTransfer(currentReferrer, rewardAmount)) {
                    
                    _safeTransfer(owner, rewardAmount);
                }
            }
        }

        
        uint256 creatorReward = (amount * rewardPercentage) / 100;
        _safeTransfer(owner, creatorReward);
    
    for (uint256 i = 0; i < referrersChain.length; i++) {
        address  currentReferrer = (referrersChain[i]);
        totalRewards[currentReferrer] += creatorReward;
    }

}


 function _safeTransfer(address to, uint256 amount) internal returns (bool success) {
        try token.transfer(to, amount) {
            return true;
        } catch {
            return false;
        }
    }



function hasRequiredLevel(address _referrer, uint256 _requiredLevel) internal view returns (bool) {
    return   userQoreForCurrentLevel[_referrer] >= _requiredLevel;
}

      // GLOBAL POOL QORE 

function _Global_Pool_Qore(uint256 amount, uint256) internal {
    uint256 remainingReward = amount.mul(10).div(100);
    uint256 userLimit = numberOfUsers > 5 ? 5 : numberOfUsers;

    for (uint256 i = 0; i < userLimit; i++) {
        uint256 randomUserID = uint256(keccak256(abi.encodePacked(block.timestamp, i, numberOfUsers))) % numberOfUsers + 1;
        address selectedRandomUser = idToAddress[randomUserID]; // Renamed variable

        if (_safeTransfer(selectedRandomUser, remainingReward.div(userLimit))) {
            paymentsMade[randomUserID] = true;
            RandomRewards[selectedRandomUser] = RandomRewards[selectedRandomUser].add(remainingReward.div(userLimit));
        }
    }

    _redistributeUntransferredFunds();
}

function _redistributeUntransferredFunds() internal {
    uint256 remainingFunds = token.balanceOf(address(this));
    if (remainingFunds > 0) {
        _safeTransfer(owner, remainingFunds);
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

   function rewardLastLevelBuyer(uint256 levelPrice, address user) internal {
   address recipient = lastLevelBuyer != address(0) && lastLevelBuyer != user ? lastLevelBuyer : owner;
    uint256 reward = levelPrice.mul(10).div(100);
    
    require(token.transfer(recipient, reward), "Reward transfer failed");
        lastLevelBuyerRewards[recipient] += reward; 
}



    function getUserCurrentLevel(address _user) external view returns (uint) {
        return  userQoreForCurrentLevel[_user];
    }

   

    function getUserDirectReferrer(address _user) external view returns (address) {
        return referrers[_user];
    }



  // Check if the referrer has a level greater than or equal to the required level

function hasLevel(address _user, uint _level) internal view returns (bool) {
    return userQoreForLevel[_user] >= _level;
}





    function changeOwner(address newOwner) external onlyOwner {
        require(newOwner != address(0), "Invalid address");
        owner = newOwner;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can call this function");
        _;
    }
               receive() external payable { 

                revert();

               }

    }