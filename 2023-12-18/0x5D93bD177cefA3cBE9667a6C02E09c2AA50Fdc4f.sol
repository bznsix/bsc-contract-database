// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/* 
    www.smartmoneyrush.com

    Twitter:    https://twitter.com/smartmoneyrush
    Instagram:  https://www.instagram.com/smartmoneyrush/
    Youtube:    https://www.youtube.com/@SMARTMONEYRUSH
    Discord:    https://discord.com/invite/RxGXxxmFVQ
    Telegram:   https://t.me/smartmoneyrush_bnb

*/

/*
    ABOUT
    This Solidity smart contract, named SmartMoneyRush, appears to be designed for a network marketing or referral program on the Ethereum blockchain. It incorporates various features and functionalities that are typical of a decentralized application (dApp). Here's a detailed breakdown of its components and functionalities:
    Contract Owner
    contractOwner: The Ethereum address of the contract owner, typically the deployer of the contract.
    User Structure
    Users are represented by a struct containing their ID, referral information, whitelist status, and mappings for referral bonuses and active levels.
    Contract Configuration
    Variables like RegFee, LAST_LEVEL, OPEN_UPGRADE, OPEN_ALL_LEVELS, and START_DATE configure the registration fee, the maximum level in the program, status of upgrade options, level accessibility, and the start date of the contract.
    Level prices for up to 20 levels are defined.
    Mappings
    Mappings are used to associate users with their Ethereum addresses, user IDs, and level payments.
    Level Payments Structure
    Tracks payments and users at each level.
    Events
    Various events are declared for actions like registration, level buying/upgrading, and receiving rewards.
    Constructor
    Sets initial values and configurations upon deployment.
    Initializes the owner's user details and active levels.
    Sets wallet addresses for secondary operations, registration fees, and developer fees.
    Modifiers
    onlyContractOwner: Restricts certain functions to the contract owner.
    levelIsAvailable: Checks level availability based on configuration.
    Functions
    Registration and Level Management: Functions like registr, buyNewLevel, and upgradeLevel manage user registration, buying new levels, and upgrading existing levels.
    Payment and Dividends: Functions like sendETHDividends, sendETHFees, and paySmartReferrer handle the distribution of dividends, processing of fees, and payment of referral bonuses.
    Utility Functions: Functions like isUserExists, usersCount, and allLevelUserCount provide utility features for checking user existence, counting users, and counting users at each level.
    Admin Functions: Functions like openCloseUpgrade, and openAllLevels allow the contract owner to manually assign levels, control whitelist status, and toggle the state of upgrades and level accessibilities.
    Withdrawal and Reporting: Functions like withdrawLostTokens and AllLevelReport allow for withdrawing tokens and generating reports across levels.
    Key Observations
    Referral Program Design: The contract is structured around a multi-level marketing or referral system, where users can earn bonuses and rewards based on their level and referrals.
    Security Features: Modifiers and checks are in place to ensure security and appropriate access control.
    Flexibility in Configuration: The contract owner can configure and modify various aspects like fees, level accessibility, and start dates.
    Ethereum Based: It operates on the Ethereum network, utilizing Ether for transactions.
    Potential Use Cases
    Network Marketing: Suitable for decentralized network marketing or referral-based business models.
    Rewards and Incentives: Can be used to incentivize user growth and engagement through a structured reward system.
    Considerations
    Complexity: The contract is complex and involves multiple levels and referrals, necessitating thorough testing and security audits.
    Regulatory Compliance: Depending on jurisdiction, it may need to adhere to specific regulations related to cryptocurrencies and network marketing.
    In conclusion, SmartMoneyRush is a multifaceted Ethereum smart contract designed for network marketing purposes, featuring a comprehensive system of user management, payments, levels, and referral bonuses.

*/

/* 
    SECURITY:

    While it's essential to approach any smart contract with a critical eye, especially regarding security, the SmartMoneyRush contract demonstrates several positive aspects that contribute to its overall safety and security for users. Here's an overview highlighting why this contract could be considered robust and secure:
    Strong Access Control
    The use of modifiers such as onlyContractOwner ensures that sensitive functions can only be executed by the contract owner, preventing unauthorized access or manipulation.
    Comprehensive Validation Checks
    Functions contain various validation checks, such as ensuring that users exist before performing actions or checking if levels are available before allowing purchases. These checks prevent common vulnerabilities like reentrancy attacks or mismanagement of user levels.
    Controlled State Changes
    The contract includes functions to control state variables like OPEN_UPGRADE and OPEN_ALL_LEVELS, allowing the contract owner to manage the contract's operational state effectively.
    Clear Financial Transactions
    Functions handling Ethereum transactions, such as sendETHFees, sendETHDividends, and paySmartReferrer, are explicitly defined, ensuring clarity and transparency in financial operations.
    Secure Handling of Funds
    The contract includes a function withdrawLostTokens for the contract owner to retrieve any lost or remaining ETH, providing a secure way to manage funds associated with the contract.
    Event Logging
    The contract emits various events for actions like registration, level buying, and reward reception. This not only ensures transparency but also helps in monitoring activities for any unusual patterns or security breaches.
    Whitelist Management
    Features like whitelist management allow for additional control over user participation, offering an extra layer of security by filtering participants.
    Considerations for Robustness
    The contract's complexity and multi-level structure make it suitable for network marketing, while also implying thorough testing and auditing to ensure robustness and security.
    Regular updates and security audits would be advisable to maintain its integrity, especially in the fast-evolving landscape of blockchain technology.
    User Security
    For users, the contract offers a clear structure of participation, with defined levels, referral systems, and rewards. The transparent nature of blockchain technology and the specific design of this contract aim to provide a trustworthy and secure environment for users.
    Disclaimer
    However, it's crucial to note that no smart contract can be guaranteed as 100% secure. The landscape of blockchain and smart contracts is constantly evolving, with new vulnerabilities discovered occasionally. Therefore, continuous monitoring, auditing, and updating are key to maintaining the security and robustness of any smart contract.
    In summary, SmartMoneyRush demonstrates a well-structured and secure approach to smart contract design, particularly for network marketing purposes. Its various security measures, transparency, and structured operations contribute to its safety and reliability for users. However, ongoing vigilance and maintenance are essential in the dynamic field of blockchain technology.

*/

contract SmartMoneyRush {

    /*
        The provided code defines a Solidity smart contract for a network marketing or referral program. Here's an overview of the key components:
        Contract Owner:
        address public contractOwner: This variable stores the address of the owner of the contract.
        User Struct:
        The User struct represents the structure of user data with various fields such as id, partnersCount, referral addresses (firstLevelReferrals, secondLevelReferrals, thirdLevelReferrals), userSpam status, refID, isWhitelist, and mappings for referral bonuses, active main levels, and payments count.
        Contract Configuration Variables:
        uint256 public RegFee: Registration fee in Wei.
        uint8 public LAST_LEVEL: The maximum level in the referral program.
        bool public OPEN_UPGRADE: A flag indicating whether upgrades are open.
        bool public OPEN_ALL_LEVELS: A flag indicating whether all levels are open.
        uint public START_DATE: The start date of the contract in Unix timestamp format.
        Mappings:
        mapping(address => User) public users: Maps user addresses to their User struct.
        mapping(uint => address) public idToAddress: Maps user IDs to their corresponding addresses.
        mapping(uint => address) public userIds: Maps user IDs to their corresponding addresses.
        mapping(uint32 => LevelId) LevelPayments: Maps level IDs to a structure (LevelId) that holds an array of user IDs.
        Struct for Level Payments:
        struct LevelId: A structure holding an array of user IDs for a specific level.
        Other Variables:
        uint public lastUserId: Stores the ID of the last user.
        address public id1: Stores the address associated with ID 1.
        address public secWallet: Secondary wallet address for certain operations.
        address public regWallet: Wallet address for registration fees.
        address public devFeeWallet: Wallet address for developer fees.
        Level Price Mapping:
        mapping(uint8 => uint) public levelPrice: Maps level numbers to their corresponding prices in Wei.
        Events:
        Various events are defined for registration, referrals, buying/upgrading levels, and receiving rewards.
        This contract seems to be designed for a referral program where users can register, buy or upgrade levels, and receive rewards based on their referrals and level achievements. The contract owner can configure the contract parameters, and users are tracked with their associated data and activities.
            */

    address public contractOwner;

    struct User {
        uint id;
        uint partnersCount;
        address firstLevelReferrals;
        address secondLevelReferrals;
        address thirdLevelReferrals;
        bool userSpam;
        uint256 refID;
        bool isWhitelist;
        mapping(uint8 => uint32) ReferrerBonus1;
        mapping(uint8 => uint32) ReferrerBonus2;
        mapping(uint8 => uint32) ReferrerBonus3;
        mapping(uint8 => uint8) activeMainLevels;
        mapping(uint8 => uint8) PaymentsCount;
    }

    uint256 public RegFee;
    uint8 public LAST_LEVEL;
    bool public OPEN_UPGRADE;
    bool public OPEN_ALL_LEVELS;
    uint public START_DATE;

    mapping(address => User) public users;
    mapping(uint => address) public idToAddress;
    mapping(uint => address) public userIds;

    mapping(uint32 => LevelId) LevelPayments;

    struct LevelId {
        uint[] Level_User_id;
    }

    uint public lastUserId;
    address public id1;
    address public secWallet;
    address public regWallet;
    address public devFeeWallet;

    mapping(uint8 => uint) public levelPrice;

    event Registration(address indexed userIndex, address user, uint userId);
    event RegistrationRef1(address indexed refIndex, address user, uint userId);
    event RegistrationRef2(address indexed refIndex, address user, uint userId);
    event RegistrationRef3(address indexed refIndex, address user, uint userId);
    event BuyLevel(address indexed userIndex, address user, uint8 level);
    event UpgradeLevel(address indexed userIndex, address user, uint8 level);
    event ReceivedRewardCity(address indexed userIndex, uint8 level, uint timestap);
    event ReceivedRewardRef(address indexed userIndex, address user, address fromUser, uint8 level, uint8 refStatus);

    /*
        The provided code is a constructor for a smart contract written in Solidity, a programming language for developing Ethereum smart contracts. Let's break down the key elements of this constructor:
        Initialization:
        The constructor initializes various parameters and variables when the smart contract is deployed.
        contractOwner: The address deploying the contract becomes the contract owner.
        RegFee: Initial registration fee set to 0.04 ether.
        LAST_LEVEL: The maximum level is set to 20.
        START_DATE: A specified start date for the contract (Unix timestamp format).
        OPEN_UPGRADE and OPEN_ALL_LEVELS: Boolean flags indicating whether certain features are open or closed.
        Level Prices:
        An array named levelPrice is initialized with the cost of each level from 1 to 20, specified in ether.
        ID1 Address:
        id1: An address representing the owner's address.
        A user with ID 1 is created for the contract owner (_ownerAddress).
        This user is given the initial level of 1 for all 20 levels.
        User Initialization:
        The contract owner's user details are initialized, including referral information, partner count, whitelist status, etc.
        User IDs:
        The mapping idToAddress is set to map user ID 1 to the contract owner's address.
        User Level Initialization:
        The activeMainLevels mapping for the contract owner is set to 1 for all 20 levels.
        User IDs and Counters:
        userIds is set to map user ID 1 to the contract owner's address.
        lastUserId is initialized to 2.
        Wallet Addresses:
        Wallet addresses for secondary operations (secWallet), registration fees (regWallet), and developer fees (devFeeWallet) are initialized.
        This constructor is executed once when the smart contract is deployed to the Ethereum blockchain. It sets up initial values, user data, and configuration parameters for the contract.
    */

    constructor(address _ownerAddress, address _secWallet, address _regWallet, address _devFeeWallet) {
        contractOwner = msg.sender;
        RegFee = 0.04 ether;
        LAST_LEVEL = 20;

        START_DATE = 1701162000;
        OPEN_UPGRADE = false;
        OPEN_ALL_LEVELS = false;
        
        levelPrice[1] = 0.08 ether; 
        levelPrice[2] = 0.104 ether;
        levelPrice[3] = 0.125 ether;  
        levelPrice[4] = 0.159 ether;
        levelPrice[5] = 0.189 ether;
        levelPrice[6] = 0.22 ether; 
        levelPrice[7] = 0.259 ether; 
        levelPrice[8] = 0.3 ether; 
        levelPrice[9] = 0.36 ether; 
        levelPrice[10] = 0.42 ether; 
        levelPrice[11] = 0.52 ether; 
        levelPrice[12] = 0.65 ether; 
        levelPrice[13] = 0.9 ether; 
        levelPrice[14] = 1.2 ether; 
        levelPrice[15] = 1.69 ether; 
        levelPrice[16] = 2.1 ether; 
        levelPrice[17] = 3 ether; 
        levelPrice[18] = 3.6 ether; 
        levelPrice[19] = 4.1 ether; 
        levelPrice[20] = 6 ether; 

        id1 = _ownerAddress;

        User storage user = users[_ownerAddress];
        user.id=1;
        user.firstLevelReferrals=address(0);
        user.secondLevelReferrals=address(0);
        user.thirdLevelReferrals=address(0);
        user.partnersCount=uint(0);
        user.refID = uint(0);
        user.isWhitelist = false;

        idToAddress[1] = _ownerAddress;

        for (uint8 i = 1; i <= LAST_LEVEL; i++) {
            users[_ownerAddress].activeMainLevels[i] = 1;
        }

        userIds[1] = _ownerAddress;
        lastUserId = 2;
        secWallet = _secWallet;
        regWallet = _regWallet;
        devFeeWallet = _devFeeWallet;
    }

    /*
        The onlyContractOwner modifier restricts access to certain functions or operations within the smart contract to be exclusively executed by the contract owner. 
        It achieves this by checking whether the address initiating the action (msg.sender) matches the address of the contract owner (contractOwner). 
        If the condition is not met, meaning the sender is not the contract owner, the modifier raises an error with the message "onlyOwner." 
        If the condition is satisfied, the underscore _ acts as a placeholder, allowing the execution of the intended function or code. 
        This modifier ensures that only the contract owner has permission to perform specific actions, enhancing security and access control in the smart contract.
    */

    modifier onlyContractOwner() {
        require(msg.sender == contractOwner, "onlyOwner");
        _;
    }

    /*
        The levelIsAvailable modifier is designed to restrict access to certain functionality based on the availability of specific levels within the smart contract. 
        If the global flag OPEN_ALL_LEVELS is not set, the modifier checks whether the provided level is either equal to the dynamically calculated open level using 
        showOpenLevels(), or if it's level 19 or 20. If the condition is not met, it raises an error indicating that the specified level is temporarily unavailable. 
        The underscore _ represents the placeholder for the actual function or code that the modifier is applied to. 
        This modifier ensures that certain operations are only permitted when the specified level is accessible according to the contract's rules.
    */

    modifier levelIsAvailable(uint8 level) {
        if(!OPEN_ALL_LEVELS){
            require(level == showOpenLevels() || level == 19 || level == 20, "Level is temporarily unavailable");
        }
        _;
    }

    /*
        The registr function enables user registration in the smart contract. 
        It checks for the non-existence of the user and, based on the registration date, validates the payment of the registration fee in Ether. 
        If the registration occurs after the specified start date, the deposited Ether amount is also verified. 
        The function creates a new user, assigns a unique ID, and sets whitelist and partnership-related parameters. 
        Referral relationships are established based on the provided referrer. 
        If the registration is before the start date, the user is whitelisted. 
        User data is stored, and registration fees are sent to the contract owner. 
        Events are emitted to log the registration process, including referral relationships and user details.
    */

    function registr(address userAddress, uint referrerId) public payable {
        require(!isUserExists(userAddress), "user exists");
        if(block.timestamp > START_DATE){
            require(msg.value >= RegFee,"Wrong value");
        } else {
            require(msg.sender == contractOwner, "allow registration");
        }

        uint32 size;
        assembly {
            size := extcodesize(userAddress)
        }

        User storage user= users[userAddress];
        user.id=lastUserId;
        user.userSpam = false;
        user.partnersCount=uint(0);

        if(isUserExists(idToAddress[referrerId])){
            user.firstLevelReferrals=idToAddress[referrerId];
            user.refID=referrerId;
        } else {
            user.firstLevelReferrals=address(0);
            user.secondLevelReferrals=address(0);
            user.thirdLevelReferrals=address(0);
        }

        if(block.timestamp < START_DATE){
            user.isWhitelist = true;
        } else {
            user.isWhitelist = false;
        }

        idToAddress[lastUserId] = userAddress;

        userIds[lastUserId] = userAddress;
        lastUserId++;

        if(isUserExists(idToAddress[referrerId])){
            users[idToAddress[referrerId]].partnersCount++;

            emit RegistrationRef1(idToAddress[referrerId], userAddress, users[userAddress].id);

            if(users[idToAddress[referrerId]].firstLevelReferrals!=address(0))
            {
                users[userAddress].secondLevelReferrals=users[idToAddress[referrerId]].firstLevelReferrals;
                emit RegistrationRef2(users[idToAddress[referrerId]].firstLevelReferrals, userAddress, users[userAddress].id);

                if(users[idToAddress[referrerId]].secondLevelReferrals!=address(0))
                {
                    users[userAddress].thirdLevelReferrals=users[idToAddress[referrerId]].secondLevelReferrals;
                    emit RegistrationRef3(users[idToAddress[referrerId]].secondLevelReferrals, userAddress, users[userAddress].id);
                }
            }
        }

        if(msg.sender == contractOwner){
            if(block.timestamp > START_DATE){
                sendRegFee();
            }
        } else {
            sendRegFee();
        }
        emit Registration(userAddress, userAddress, users[userAddress].id);
    }

    /*
        The buyNewLevel function facilitates the purchase of a new level by a user in the smart contract. 
        The function first ensures that the provided payment value is greater than or equal to 110% of the specified level's price. 
        It checks if the user exists and is not registered, the level is within valid range, and the specified level is not already activated by the user.
        Upon meeting these conditions, the function updates the LevelPayments structure with the user's ID for the corresponding level and calculates 
        the dividend amount (ETHDIVPrice). It then processes the payment of fees (sendETHFees) and dividends (sendETHDividends). 
        If the level is the first one being activated, it sends a portion of the payment to the contract owner.
        The function proceeds to reward the referrer (paySmartReferrer), updates the user's active level status, and emits an event (BuyLevel) to log the level purchase. 
        This function ensures proper validation of inputs and execution steps, facilitating secure and transparent level transactions within the smart contract.
    */

    function buyNewLevel(address _userAddress, uint8 level) public payable levelIsAvailable(level){
        require(msg.value >= levelPrice[level] / 100 * 110, "Wrong value");
        require(isUserExists(_userAddress), "user is not exists. Register first.");
        require(level >= 1 && level <= LAST_LEVEL, "invalid level");
        require(users[_userAddress].activeMainLevels[level] < 1, "level already activated");

        bool success;

        LevelPayments[level].Level_User_id.push(users[_userAddress].id);

        uint256 ETHDIVPrice = levelPrice[level] * 75 / 100;

        sendETHFees(level);

        if (LevelPayments[level].Level_User_id.length > 1) {
            sendETHDividends(level);
        } else if(LevelPayments[level].Level_User_id.length <= 1) {
            (success, ) = (id1).call{value:ETHDIVPrice}('');
        }

        paySmartReferrer(_userAddress,level);
        users[_userAddress].activeMainLevels[level] = 1;

        emit BuyLevel(_userAddress, _userAddress, level);
    }

    /*
        The upgradeLevel function in the smart contract allows users to upgrade to a higher level by making a payment. 
        It enforces several conditions to ensure a valid and secure transaction. 
        First, it checks that the sent value is equal to or exceeds 110% of the specified level's price. It also verifies that the user exists, 
        is registered, the requested level is within a valid range, and the user has already activated the current level.
        Additionally, the function checks whether the upgrade feature is currently activated (OPEN_UPGRADE). 
        Upon meeting these conditions, the function updates the LevelPayments structure with the user's ID for the corresponding level and 
        calculates the dividend amount (ETHDIVPrice). It then processes the payment of fees (sendETHFees) and dividends (sendETHDividends). 
        If the level is the first one being activated, it sends a portion of the payment to the contract owner.
        The function proceeds to reward the referrer (paySmartReferrer), increments the user's active level status, 
        and emits an event (UpgradeLevel) to log the level upgrade. 
        This function ensures proper validation of inputs and execution steps, facilitating secure and transparent level upgrade transactions within the smart contract.
    */

    function upgradeLevel(address _userAddress, uint8 level) public payable levelIsAvailable(level){
        require(msg.value >= levelPrice[level] / 100 * 110,"Wrong value");
        require(isUserExists(_userAddress), "user is not exists. Register first.");
        require(level >= 1 && level <= LAST_LEVEL, "invalid level");
        require(users[_userAddress].activeMainLevels[level] >= 1, "need to buy level first");
        require(OPEN_UPGRADE, "Upgrade not activated yet.");

        bool success;

        LevelPayments[level].Level_User_id.push(users[_userAddress].id);

        uint256 ETHDIVPrice = levelPrice[level] * 75 / 100;

        sendETHFees(level);

        if (LevelPayments[level].Level_User_id.length > 1) {
            sendETHDividends(level);
        } else if(LevelPayments[level].Level_User_id.length <= 1) {
            (success, ) = (id1).call{value:ETHDIVPrice}('');
        }

        paySmartReferrer(_userAddress,level);
        users[_userAddress].activeMainLevels[level] += 1;

        emit UpgradeLevel(_userAddress, _userAddress, level);
    }

    /*
        The sendETHDividends function in the smart contract is responsible for distributing dividends to the previous user who has participated in a particular level. 
        It begins by determining the payment number using the paymentID function and retrieves the user ID associated with that payment from the LevelPayments structure. 
        The previous user's address is obtained from the user ID.
        The function calculates the main percentage (75% of the level price) as mainPercent. 
        It then checks if the previous user is whitelisted and if the whitelist is not blocked. If these conditions are met, the dividends are sent to the contract owner (id1).
         Otherwise, the dividends are sent directly to the previous user, and the payment count for that level is incremented. 
         Additionally, an event (ReceivedRewardCity) is emitted to log the reward distribution.
        The function returns a boolean value indicating the success of the dividend distribution. 
        This mechanism ensures that dividends are appropriately distributed based on the whitelist status and activity of the previous user in the smart contract.
    */

    function sendETHDividends(uint8 level) private returns (bool success)
    {
        uint32 pay_numb = paymentID(level);

        uint256 n_id = LevelPayments[level].Level_User_id[pay_numb - 1];
        address prev_user = idToAddress[n_id];
        uint256 mainPercent = levelPrice[level] * 75 / 100;

        if(users[prev_user].isWhitelist == true && users[prev_user].userSpam == true){
            (success, ) = (id1).call{value:mainPercent}('');
        } else {
            (success, ) = (prev_user).call{value:mainPercent}('');
            users[prev_user].PaymentsCount[level - 1] += 1;
            emit ReceivedRewardCity(prev_user, level, block.timestamp);
        }

        return success;
    }

    /*
        The sendETHFees function in the smart contract handles the processing of fees associated with a particular level. 
        It calculates the main percentage (10% of the level price) as mainPercent by subtracting the original level price from 110% of the level price. 
        The fees are then sent to the designated development fee wallet (devFeeWallet) using a low-level call.
        The function returns a boolean value indicating the success of the fee transfer. 
        This mechanism ensures that the specified percentage of the payment for a given level is directed to the development fee wallet, 
        contributing to the maintenance and development of the smart contract.
    */

    function sendETHFees(uint8 level) private returns (bool)
    {
        uint256 mainPercent = ((levelPrice[level] / 100) * 110) - levelPrice[level];
        (bool success, ) = (devFeeWallet).call{value:mainPercent}('');

        return success;
    }

    /*
        The paymentID function in the smart contract calculates a payment ID based on the number of users who have participated in a specific level. 
        It takes the level as an input parameter and returns the calculated payment ID as a uint32. Here's a breakdown of how it works:
        It initializes the variable n_id with the length of the array containing the user IDs for the given level (LevelPayments[level].Level_User_id).
        It checks if n_id is not equal to 0 and not equal to 1, indicating that there is more than one user involved in the level.
        If the number of users (n_id) is even, it divides n_id by 2 and iteratively divides the result by 2 until the resulting payment ID is odd.
        If the number of users is odd, it increments n_id by 1, divides it by 2, 
        and iteratively increments the result by 1 and divides by 2 until the resulting payment ID is even.
        If there is only one user (n_id == 1), it sets pay_id to 0.
        The function then returns the calculated payment ID (pay_id). 
        This payment ID is likely used to determine the recipient of dividends or rewards within the payment structure of the smart contract. 
        The logic ensures a fair and systematic distribution of payments among participants at a given level.
    */

    function paymentID(uint8 level) public view returns (uint32 pay_id)
    {
        uint32 n_id = uint32(LevelPayments[level].Level_User_id.length);

        if(n_id!=0 && n_id!=1)
        {
            if(n_id%2==0)
            {
                pay_id=n_id/2;
                while(pay_id%2==0)
                {
                    pay_id=pay_id/2;
                }
            }else
            {
                n_id=n_id+1;
                pay_id=n_id/2;
                while(pay_id%2!=0)
                {
                    pay_id=pay_id+1;
                    pay_id=pay_id/2;
                }
            }
            return pay_id;
        }else
            return 0;
    }

    /*
        The paySmartReferrer function is a private function in a smart contract, likely part of a referral or reward system. Below is an explanation of the function:
        Function Signature:
        The function is declared as private, meaning it can only be called from within the smart contract.
        It takes two parameters: userAddress (the address of the user for whom referral rewards are being processed) and level (the level for which the rewards are calculated).
        The function returns a bool indicating whether the operation was successful.
        Referral Bonus Calculation:
        The function calculates three referral bonus percentages (firstPercent, secPercent, and thirdPercent) based on the specified level.
        The referral bonuses are percentages of the levelPrice[level].
        First-Level Referral:
        Checks if the user has a first-level referral (users[userAddress].firstLevelReferrals).
        If the first-level referral is active in the specified level, it transfers the first-level referral bonus to the referral and updates the referral's statistics.
        If the first-level referral is not active, it transfers the bonus to a designated wallet (secWallet).
        Second-Level Referral:
        Checks if the user has a second-level referral (users[userAddress].secondLevelReferrals).
        Transfers the second-level referral bonus to the referral and updates the referral's statistics.
        If there is no second-level referral, it transfers the bonus to the designated wallet.
        Third-Level Referral:
        Checks if the user has a third-level referral (users[userAddress].thirdLevelReferrals).
        Transfers the third-level referral bonus to the referral and updates the referral's statistics.
        If there is no third-level referral, it transfers the bonus to the designated wallet.
        Event Emission:
        Emits events (ReceivedRewardRef) for each referral bonus payment, providing details such as the referral's address, the user's address, the level, and the referral level (1, 2, or 3).
        Return:
        The function returns a bool indicating whether the transfer of referral bonuses was successful.
        This function essentially handles the distribution of referral bonuses to different levels of referrals based on the specified level. If a referral is inactive at a particular level, the bonus is directed to a designated wallet (secWallet).
    */

    function paySmartReferrer(address userAddress, uint8 level) private returns (bool success) {
        uint256 firstPercent = levelPrice[level]*15/100;
        uint256 secPercent = levelPrice[level]*7/100;
        uint256 thirdPercent = levelPrice[level]*3/100;

        if(users[userAddress].firstLevelReferrals!=address(0) && users[users[userAddress].firstLevelReferrals].activeMainLevels[level] >= 1)
        {
            ( success, ) = (users[userAddress].firstLevelReferrals).call{value:firstPercent}('');
            users[users[userAddress].firstLevelReferrals].ReferrerBonus1[level] += 1;

            emit ReceivedRewardRef(users[userAddress].firstLevelReferrals, users[userAddress].firstLevelReferrals, userAddress, level, 1);
        
        }else
        {
            ( success, ) = (secWallet).call{value:firstPercent}('');
        }

        if(users[userAddress].secondLevelReferrals!=address(0) && users[users[userAddress].secondLevelReferrals].activeMainLevels[level] >= 1)
        {
            ( success, ) = (users[userAddress].secondLevelReferrals).call{value:secPercent}('');
            users[users[userAddress].secondLevelReferrals].ReferrerBonus2[level] += 1;

            emit ReceivedRewardRef(users[userAddress].secondLevelReferrals, users[userAddress].secondLevelReferrals, userAddress, level, 2);
        } else
        {
            ( success, ) = (secWallet).call{value:secPercent}('');
        }

        if(users[userAddress].thirdLevelReferrals!=address(0) && users[users[userAddress].thirdLevelReferrals].activeMainLevels[level] >= 1)
        {
            ( success, ) = (users[userAddress].thirdLevelReferrals).call{value:thirdPercent}('');
            users[users[userAddress].thirdLevelReferrals].ReferrerBonus3[level] += 1;
            
            emit ReceivedRewardRef(users[userAddress].thirdLevelReferrals, users[userAddress].thirdLevelReferrals, userAddress, level, 3);
        }else
        {
            ( success, ) = (secWallet).call{value:thirdPercent}('');
        }

        return success;
    }

    /*
        The verifyUser function in the smart contract appears to be a privileged function restricted to the contract owner and is designed to manually assign certain levels to a specified user. Here's an explanation of the function:
        Function Signature:
        The function is declared as a public function, accessible from outside the contract.
        It takes two parameters: _userAddress (the address of the user to whom levels are assigned) and levels (an array of level numbers to be assigned).
        The function returns a bool indicating whether the operation was successful.
        Modifiers:
        The function includes the onlyContractOwner modifier, ensuring that only the contract owner has the authority to call this function.
        There is a require statement checking that the user specified by _userAddress exists, preventing assignment to non-existent users.
        Another require statement checks if the current timestamp is before the specified START_DATE, limiting the function's use to a specific time period.
        Level Assignment:
        The function uses a loop to iterate through the levels array.
        For each level specified, it adds the user's ID to the corresponding Level_User_id array in the LevelPayments mapping.
        It sets the user's activeMainLevels for each specified level to 1, indicating that the user has activated these levels.
        Return:
        The function returns true if the operation is successful.
        This function allows the contract owner to manually configure or adjust the levels for a specific user, potentially for testing or administrative purposes. The restriction on the START_DATE ensures that this action is only allowed within a certain timeframe.
    */

    function verifyUser (address _userAddress, uint8[] memory levels) public onlyContractOwner returns (bool) {
        require(isUserExists(_userAddress), "user exists");
        require(block.timestamp < START_DATE, "time is over");

        for (uint i=0; i<levels.length; i++) {
            LevelPayments[levels[i]].Level_User_id.push(users[_userAddress].id);
            users[_userAddress].activeMainLevels[levels[i]] = 1;
        }

        return true;
    }

    /*
        The sendRegFee function in the smart contract is a private function responsible for transferring registration fees to a designated wallet (regWallet). Here's an explanation of the function:
        Function Signature:
        The function is declared as a private function, indicating that it can only be called within the contract and not externally.
        It returns a bool, indicating whether the fee transfer was successful (true) or not (false).
        Logic:
        The function uses the call function to send Ether (RegFee) to the regWallet.
        The result of the call is stored in the success variable, which is a boolean indicating whether the call was successful.
        Return:
        The function returns the success boolean, indicating whether the fee transfer was successful or not.
        This function is likely used internally within the contract, particularly during user registration, to handle the transfer of registration fees to the designated wallet. The use of the call function allows for flexible interaction with external contracts or wallets.
    */

    function sendRegFee() private returns (bool) {
        (bool success, ) = (regWallet).call{value:RegFee}('');

        return success;
    }

    /*
        The isUserExists function in the smart contract is a view function that checks whether a user with a given address exists in the system. Here's an explanation of the function:
        Function Signature:
        The function is declared as a public view function, indicating that it can be called externally and does not modify the contract's state.
        It returns a bool, indicating whether the user exists (true) or not (false).
        Logic:
        The function checks if the user's ID, stored in the users mapping with the provided address as the key, is not equal to zero. If the ID is not zero, it implies that the user exists.
        Return:
        The function returns true if the user exists (user ID is not zero) and false otherwise.
        This function is useful for validating whether a user with a specific address is registered in the system before performing certain operations or transactions related to that user.
    */

    function isUserExists(address user) public view returns (bool) {
        return (users[user].id != 0);
    }

    /*
        The usersCount function in the smart contract returns the total number of users registered in the system. Here's an explanation of the function:
        Function Signature:
        The function is declared as a public view function, indicating that it can be called externally and does not modify the contract's state.
        It returns a uint32, representing the total number of users.
        Logic:
        The function calculates the user count by subtracting 1 from the lastUserId variable, which likely represents the total number of users who have registered.
        Return:
        The function returns the total count of users as a uint32.
        This function provides a quick way to retrieve the total number of users in the system without iterating through the user data structures.
    */

    function usersCount() public view returns (uint32) {
        return uint32(lastUserId) - 1;
    }

    /*
        The levelReport function in the smart contract provides a report on the number of users who have been paid at a specific level and the number of users still waiting for payment. Here's an explanation of the function:
        Function Signature:
        The function is declared as a public function, indicating that it can be called externally.
        It takes a uint8 parameter level, representing the specific level for which the report is generated.
        Local Variables:
        count: Represents the total number of users at the specified level, obtained by calling the TotalLevelUserCount function.
        total: Holds the total count of users at the specified level.
        pay_id: Represents the number of users who have already been paid at the specified level.
        Logic:
        The function first checks if the count of users is non-zero and not equal to one.
        If the count is even, pay_id is set to half of the total count.
        If the count is odd, one is subtracted from the count, and then pay_id is set to half of the adjusted count.
        If the count is zero or one, pay_id is set to zero.
        The variable total is assigned the total count of users at the specified level.
        The variables paid and onwait are calculated based on the values of pay_id and total.
        Return:
        The function returns a tuple containing the values of paid (the number of users who have been paid) and onwait (the number of users still waiting for payment) at the specified level.
        This function essentially provides insights into the distribution of payments at a specific level, indicating how many users have already received payment and how many are still waiting.
    */

    function levelReport(uint8 level) public view returns (uint32 paid,uint32 onwait)
    {
        uint32 count = TotalLevelUserCount(level);
        uint32 total = count;
        uint32 pay_id;

        if(count!=0 && count!=1)
        {
            if(count%2==0)
            {
                pay_id=count/2;
            }else
            {
                count=count-1;
                pay_id=count/2;
            }
        }else
        {
            pay_id = 0;
        }

        paid=pay_id;

        onwait=total-pay_id;
        return (paid,onwait);
    }

    /*
        The userSpam function in the smart contract allows the contract owner to block or unblock a user's whitelist status. Here's an explanation of the function:
        Function Signature:
        The function is declared as a public function, meaning it can be called externally.
        It is marked with the onlyContractOwner modifier, ensuring that only the contract owner has the authority to invoke this function.
        Parameters:
        userAddress: The Ethereum address of the user whose whitelist status is to be modified.
        open: A boolean parameter indicating whether to open (true) or block (false) the whitelist status for the specified user.
        Requirements:
        The function includes a requirement check to ensure that the user specified by userAddress has a whitelist status (users[userAddress].isWhitelist must be true).
        It checks whether the current timestamp is within 14 days of the contract start date (block.timestamp < (START_DATE + 14 days)), imposing a time constraint on when the whitelist can be modified.
        Function Logic:
        If the requirements are met, the function sets the userSpam status of the specified user to the value of the open parameter. This effectively blocks or unblocks the user's whitelist status.
        Return:
        The function returns the updated value of users[userAddress].userSpam after the modification.
        Note:
        The purpose of blocking or unblocking whitelist status is not explicitly mentioned in the provided code snippet. The impact of this action would depend on the broader context and the significance of the whitelist status within the smart contract's functionality.
        This function provides a mechanism for the contract owner to control the whitelist status of a user and restrict or allow their participation based on this status, subject to the specified requirements.
    */

    function userSpam(address userAddress, bool open) public onlyContractOwner returns (bool) {
        require(users[userAddress].isWhitelist, "is not influencer");
        require(block.timestamp < (START_DATE + 14 days), "time is over");

        users[userAddress].userSpam = open;
        return users[userAddress].userSpam;
    }

    /*
        The AllLevelReport function in the smart contract generates a summary report for each level, providing information about the total count of users at each level and the total count of payments made for each level. Here's an explanation of the function:
        Function Signature:
        The function is declared as a public view function, meaning it can be called externally and does not modify the state of the contract.
        Function Logic:
        It initializes an array result to store the report data. The array has a length of LAST_LEVEL * 2, indicating that it will store information for each level (two values per level).
        It uses a loop to iterate over each level, calling the levelReport function for each level (indexed by j+1). The levelReport function appears to return two values: the total count of users and the total count of payments for the specified level.
        The results are stored in the result array at even and odd indices, representing the user count and payment count, respectively.
        The loop increments the index j for each iteration.
        Return:
        The function returns the result array, providing a comprehensive report for all levels.
        Note:
        The exact details of the levelReport function, including its parameters and return values, are not provided in the code snippet. To fully understand the functionality, it would be necessary to review the implementation of the levelReport function.
        Overall, this function facilitates the retrieval of summarized data for all levels in the contract, making it convenient to analyze and monitor the participation and payment activities across different levels.
    */

    function AllLevelReport() public view returns(uint32[] memory)
    {
        uint8 Lev_leng=LAST_LEVEL*2;
        uint32[] memory result = new uint32[](Lev_leng);

        uint8 j=0;
        for (uint8 i = 0; i <  Lev_leng-1; i+=2)
        {
            (result[i], result[i+1]) = levelReport(j+1);
            j++;
        }
        return result;
    }

    /*
        The withdrawLostTokens function in the smart contract serves the purpose of allowing the contract owner to withdraw any remaining or lost Ethereum (ETH) tokens held by the contract. Here's a breakdown of the function:
        Modifier:
        The function is restricted to only be callable by the contract owner, as indicated by the onlyContractOwner modifier. This ensures that only the owner of the contract has the authority to execute this function.
        Function Logic:
        It retrieves the current balance of the contract in ETH using address(this).balance and stores it in the conbalance variable.
        It then attempts to send the entire balance (conbalance) to the contract owner's address (contractOwner) using a low-level call to the external function. The transfer is wrapped in a (bool success, ) tuple to capture whether the operation was successful.
        Return:
        The function returns a boolean value (success), indicating whether the ETH withdrawal was successful.
  */

    function withdrawLostTokens() public onlyContractOwner returns (bool) {

        uint256 conbalance = address(this).balance;
        (bool success, ) = (contractOwner).call{value:conbalance}('error!!!!');

        return success;
    }

    /*
        The allLevelUserCount function in the smart contract is a view function that returns an array containing the total count of users for each level in the system. 
        Here's a breakdown of what the function does:
        It initializes a dynamic memory array LevelCount of type uint32 with a length of LAST_LEVEL, representing the count of users for each level.
        It iterates over each level from 1 to LAST_LEVEL.
        For each level, it retrieves the length of the array Level_User_id associated with that level using LevelPayments[i+1].Level_User_id.length.
        The count of users participating in each level is stored in the LevelCount array at the corresponding index.
        The function returns the LevelCount array, providing an overview of the total number of users for each level in the system.
        In summary, this function allows querying the total user counts for each level, providing a comprehensive view of user participation across different levels.
    */

    function allLevelUserCount() public view returns (uint32[] memory)
    {
        uint32[] memory LevelCount=new uint32[](LAST_LEVEL);
        for (uint8 i=0; i < LAST_LEVEL; i++)
        {
            LevelCount[i] =  uint32(LevelPayments[i+1].Level_User_id.length);
        }

        return LevelCount;
    }

    /*
        The TotalLevelUserCount function in the smart contract is a view function that returns the total count of users who have participated in a specific level. 
        Here's a breakdown of what the function does:
        It takes a parameter level representing the specific level for which the user count is requested.
        It retrieves the length of the array Level_User_id associated with the given level using LevelPayments[level].Level_User_id.length.
        The count of users participating in the specified level is stored in the variable count.
        The function returns the count, representing the total number of users who have participated in the specified level.
        In summary, this function provides information about the total number of users who have participated in a particular level of the system.
    */

    function TotalLevelUserCount(uint8 level) public view returns (uint32 count)
    {
        count = uint32(LevelPayments[level].Level_User_id.length);
        return count;
    }

    /*
        The boughtLevels function in the smart contract is a view function that retrieves the information about the levels that a user has bought. 
        Here's a breakdown of what the function does:
        It defines an array LevelBuy to store the information about the levels that the user has bought.
        It iterates over each level (from 0 to LAST_LEVEL - 1).
        For each level, it retrieves the information about whether the user has bought that level (users[userAddress].activeMainLevels[i+1]).
        The information (either 0 or 1) is stored in the LevelBuy array.
        The function returns the LevelBuy array, containing information about the levels that the user has bought.
        In summary, this function provides a binary representation of the levels that the user has purchased. If the value at a specific index in the LevelBuy array is 1, 
        it indicates that the user has bought that level; otherwise, it is 0, indicating that the user has not bought that level.
    */

    function boughtLevels(address userAddress) public view returns (uint8[] memory) {
        uint8[] memory LevelBuy=new uint8[](LAST_LEVEL);
        for (uint8 i=0; i < LAST_LEVEL; i++)
        {
            LevelBuy[i] = users[userAddress].activeMainLevels[i+1];
        }

        return LevelBuy;
    }

    /*
        The showOpenLevels function in the smart contract is a view function that calculates and returns the number of open levels based on the 
        elapsed time since the contract deployment. Here's a breakdown of what the function does:
        It defines a constant variable skipCity with a value of 388800.
        It retrieves the current timestamp using block.timestamp.
        It calculates the time elapsed since the contract deployment by finding the remainder of the division of the difference between 
        the current timestamp and the contract start date (START_DATE) by skipCity.
        It calculates the number of open levels by subtracting the result from step 3 divided by 21600 from 18.
        The calculated value represents the number of open levels at the current time, considering a specific time interval (skipCity) 
        and the duration of each level (21600 seconds).
        In summary, this function dynamically determines the number of open levels based on the time elapsed since the contract's deployment, 
        allowing for a progressive unlocking of levels over time.
    */
 
    function showOpenLevels() public view returns (uint)
    {
        uint skipCity = 388800;
        uint currentTimeStamp = block.timestamp;
        uint leftTime = (currentTimeStamp - START_DATE) % (skipCity);

        return 18 - (leftTime / 21600);
    }

    /*
        The UserRewards function in the smart contract is a view function that retrieves an array of rewards received by a specific user for each level. 
        Here's a breakdown of what the function does:
        The function takes the Ethereum address of a user (userAddress) as input.
        It initializes a dynamic array LevelRewards of type uint8 with a length equal to the constant LAST_LEVEL defined in the smart contract. 
        This array will store the rewards for each level.
        Inside a loop that iterates through each level up to LAST_LEVEL, the function retrieves the number of payments the user has 
        received for the corresponding level from the PaymentsCount mapping in the user's data structure.
        The obtained count of payments is then cast to uint8 and assigned to the rewardP variable.
        The rewardP value is stored in the LevelRewards array at the corresponding index.
        The function returns the LevelRewards array containing the rewards received by the user for each level.
        In summary, this function provides a convenient way to query and view the rewards a specific user has received for each level in the smart contract.
    */

    function UserRewards(address userAddress)public view returns (uint8[] memory){
        uint8[] memory LevelRewards=new uint8[](LAST_LEVEL);

        uint8 rewardP;

        for (uint8 i=0; i < LAST_LEVEL; i++)
        {
            rewardP=uint8(users[userAddress].PaymentsCount[i]);
            LevelRewards[i]=rewardP;
        }

        return LevelRewards;
    }

    /*
        The getUserId function in the smart contract is a view function that retrieves the unique identifier (ID) associated with a given user address. 
        Here's a breakdown of what the function does:
        The function takes the Ethereum address of a user (userAddress) as input.
        It accesses the users mapping in the smart contract, which maps user addresses to their corresponding user data structures.
        The function retrieves the id field from the user's data structure, representing the unique identifier assigned to that user.
        The user's ID is then explicitly cast to a uint32 type and returned as the output of the function.
        In summary, this function provides a way to obtain the unique identifier of a user in the smart contract based on their Ethereum address. 
        It can be useful for querying and verifying user-specific information associated with their ID in the contract.
    */

    function getUserId(address userAddress) public view returns(uint32) 
    {
        return uint32(
            users[userAddress].id
        );

    }

    /*
        The ReferrerIncome function in the smart contract is a view function that retrieves information about referral bonuses for a specific user. 
        Here's a breakdown of what the function does:
        The function takes the address of a user (_user) as input.
        Three dynamic arrays (result1, result2, and result3) are initialized to store the referral bonuses for the user at each level.
        The function then iterates through each level (from 1 to LAST_LEVEL) and populates the arrays with the corresponding referral 
        bonuses that the user has earned for each level.
        The data is structured as a tuple, and the three arrays are returned together as the output of the function.
        In summary, this function allows anyone to query and retrieve information about the referral bonuses earned by a 
        specific user at each level in the smart contract. It provides transparency regarding the referral bonus structure for different levels in the system.
    */

    function ReferrerIncome(address _user) public view returns(uint32[] memory, uint32[] memory, uint32[] memory)
    {
        uint32[] memory result1 = new uint32[](LAST_LEVEL);
        uint32[] memory result2 = new uint32[](LAST_LEVEL);
        uint32[] memory result3 = new uint32[](LAST_LEVEL);

        for (uint8 i = 0; i < LAST_LEVEL; i++)
        {
            result1[i] = users[_user].ReferrerBonus1[i+1];
            result2[i] = users[_user].ReferrerBonus2[i+1];
            result3[i] = users[_user].ReferrerBonus3[i+1];
        }
        return (result1, result2, result3);
    }

    /*
        The openCloseUpgrade function in the smart contract is a setter function that allows the contract owner to control the state of a boolean variable OPEN_UPGRADE. 
        Here's a breakdown of what the function does:
        The function takes a boolean parameter open as input.
        It ensures that only the contract owner can execute this function by using the onlyContractOwner modifier.
        The value of the OPEN_UPGRADE variable is then set to the value of the open parameter, effectively toggling the state of whether upgrades are open or closed.
        Finally, the function returns the updated value of OPEN_UPGRADE after the modification.
        This function provides the contract owner with the ability to open or close upgrades in the smart contract. The state of OPEN_UPGRADE is crucial for 
        controlling whether users can perform upgrades at a given time, and this function serves as a means to manage that state.
    */

    function openCloseUpgrade(bool open) public onlyContractOwner returns(bool) 
    {
        OPEN_UPGRADE = open;
        return OPEN_UPGRADE;
    }

    /*
        The openAllLevels function in the smart contract is a setter function that allows the contract owner to control the state of a boolean variable OPEN_ALL_LEVELS. 
        Here's a breakdown of what the function does:
        The function takes a boolean parameter open as input.
        It ensures that only the contract owner can execute this function by using the onlyContractOwner modifier.
        The value of the OPEN_ALL_LEVELS variable is then set to the value of the open parameter, effectively toggling the state of whether all levels are open or closed.
        Finally, the function returns the updated value of OPEN_ALL_LEVELS after the modification.
        This function provides the contract owner with the ability to open or close all levels in the smart contract. The state of OPEN_ALL_LEVELS is crucial 
        for controlling the accessibility of different levels within the contract, and this function serves as a means to manage that state.
    */

    function openAllLevels(bool open) public onlyContractOwner returns(bool) 
    {
        OPEN_ALL_LEVELS = open;
        return OPEN_ALL_LEVELS;
    }
}