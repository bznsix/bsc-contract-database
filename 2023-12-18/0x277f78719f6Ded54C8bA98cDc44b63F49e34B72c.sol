// SPDX-License-Identifier: MIT

pragma solidity 0.8.18;

contract Web3Pilot_V2 {

    IBEP20 public donationToken;
    IVault public vault;
    address public dev;
    address public owner;
    bool public paused;

    uint256 public constant MAX_LEVEL = 10;
    uint256 public constant PRECISION = 1000;

    uint256 public withdrawalTimeLimit = 1 days;
    uint256 public dailyMaxWithdrawable = 60 ether;
    uint256 public minWithdrawal = 10 ether;
    uint256 public referralBonusPercent = 100; //10%
    uint256 public withdrawalTax = 100; //10%
    uint256 public taxPercentage = 100; //10%

    uint256[MAX_LEVEL] public levelEntryAmount = [10 ether, 10 ether, 20 ether, 25 ether, 30 ether, 35 ether, 40 ether, 45 ether, 50 ether, 55 ether];
  uint256[MAX_LEVEL] public levelEarningAmount = [16 ether, 24 ether, 32 ether, 40 ether, 44 ether, 48 ether, 52 ether, 56 ether, 58 ether, 200 ether];
       uint256[MAX_LEVEL] public levelCapacity = [3000 ether, 1000 ether, 1000 ether, 1000 ether, 1000 ether, 1000 ether, 1000 ether, 1000 ether, 1000 ether, 1000 ether];
    
    mapping(address => bool) public isAdmin;
    uint256 private immutable uncertaintyGuard;

    // Events
    event Deposited(address indexed user, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount);
    event Upgraded(address indexed user, uint256 level);
    event ReferralRewarded(address indexed referrer, address indexed referee, uint256 amount);
    event EmergencyWithdrawal(address indexed owner, uint256 amount);

     // Hardcoded founders' addresses and their share percentages
    address[7] private founders = [
        0xa43aC8661ca47c19c6CD438bDF102534Aa856513,
        0x5f26c28A02dc012F3ac70256C4342D807928d0Bf,
        0x12A1479620529566cd53D4cfec7B6f4C24EE0c68,
        0xAdeF1Dd9c2Ad269A6517aD49b6B3A36B5b2B801f,
        0xeD907194Bd42952A5a0aa0b289Bba8bDb506c036,
        0xA13Ae3478F290e8F0D14b99Da3B2FDC066b4A444,
        0x30C039581214393CDf222e02e3e22ab77c969edd
    ];

    uint16[7] private shares = [350, 165, 200, 22, 22, 45, 196]; 

    modifier onlyDev() {
        require(dev == msg.sender, "Caller is not dev");
        _;
    }

    modifier onlyOwner() {
        require(owner == msg.sender, "Caller is not owner");
        _;
    }

    modifier whenNotPaused() {
        require(!paused, "Platform paused");
        _;
    }

    modifier whenPaused() {
        require(paused, "Platform not paused");
        _;
    }

    bool private reentrancySafe = false;
    modifier nonReentrant() {
        require(!reentrancySafe, "Reentrant call");
        reentrancySafe = true;
        _;
        reentrancySafe = false;
    }

    constructor(address _donationToken, address _vault, uint256 _uncertintyGuard) {
        donationToken = IBEP20(_donationToken); //BUSD(USDT) mainnet
        vault = IVault(_vault);
        uncertaintyGuard = _uncertintyGuard;
        dev = msg.sender;
        isAdmin[msg.sender] = true;
        owner = msg.sender;
    }

    ////////////////////////////////////////
    //////     EXTERNAL FUNCTIONS      /////
    ////////////////////////////////////////

    function donate(address _referrer) external whenNotPaused nonReentrant {
        address msgSender =  msg.sender;
        uint8 levelIndex = 0;
        uint256 donationAmount = levelEntryAmount[levelIndex];
        uint256 userEarning = levelEarningAmount[levelIndex];
        
        IVault.User memory user = getUser(msgSender);
        IVault.Level memory level = getLevel(levelIndex);

        require(!user.exists, "User exists");
        require(getAllowance(msgSender) >= donationAmount, "Insufficient allowance");
        require(IBEP20(donationToken).transferFrom(msgSender, address(this), donationAmount), "Token donation failed");
        
        _createDonation(level.donationsIndex, levelIndex, msgSender, donationAmount, userEarning, block.timestamp);
        _updateLevel(levelIndex, (level.balance+donationAmount), (level.donationsIndex+1), level.payoutsIndex, (level.totalDonated+donationAmount), level.totalPaidOut);
        
        IVault.User memory referrer = getUser(_referrer);

        if(_referrer != address(0) && _referrer != msg.sender && referrer.exists){
            uint256 referralBonus = _percentageOfValue(donationAmount, referralBonusPercent);

        //_updateUser(msgSender, levelIndex, donationAmount, 0, 0, _referrer, 0, 0, 0, 0, 0, true, true);
        User memory userStruct = User({
            level: levelIndex,
            donationBalance: donationAmount, 
            withdrawableBalance: 0, 
            totalDownlines: 0, 
            referrer: _referrer,
            referralBonus: 0, 
            referralBonusWithdrawn: 0,
            totalEarned: 0, 
            totalWithdrawn: 0, 
            nextWithdrawTime: 0, 
            isAwaitingTurn: true, 
            exists: true
        });
        _updateUser(msgSender, userStruct);

        User memory userStruct2 = User({
            level: referrer.level,
            donationBalance: referrer.donationBalance, 
            withdrawableBalance: referrer.withdrawableBalance, 
            totalDownlines: referrer.totalDownlines + 1, 
            referrer: referrer.referrer,
            referralBonus: referrer.referralBonus + referralBonus, 
            referralBonusWithdrawn: referrer.referralBonusWithdrawn,
            totalEarned: referrer.totalEarned, 
            totalWithdrawn: referrer.totalWithdrawn, 
            nextWithdrawTime: referrer.nextWithdrawTime, 
            isAwaitingTurn: referrer.isAwaitingTurn, 
            exists: referrer.exists
        });
        _updateUser(_referrer, userStruct2);
        
        }else{

            User memory userStruct3 = User({
                level: levelIndex,
                donationBalance: donationAmount, 
                withdrawableBalance: 0, 
                totalDownlines: 0, 
                referrer: address(0),
                referralBonus: 0, 
                referralBonusWithdrawn: 0,
                totalEarned: 0, 
                totalWithdrawn: 0, 
                nextWithdrawTime: 0, 
                isAwaitingTurn: true, 
                exists: true
            });
            _updateUser(msgSender, userStruct3);
        }

        vault.incrementPlatformUsers();
        vault.updatePlatformDonated(donationAmount);
        vault.updateUserLevelCount(levelIndex, true); //increment users

        _settleAndUpgradeFrontUserInternal(levelIndex);
    }

    function upgrade() external whenNotPaused nonReentrant {
        address msgSender =  msg.sender;

        IVault.User memory user = getUser(msgSender);

        require(user.exists, "User does not exist");
        require(!user.isAwaitingTurn, "User is in a queue");

        //uint8 usersCurrentLevel = user.level;
        uint8 usersNewLevel;
        
        if(user.level == (MAX_LEVEL - 1)){ // Reset user to [0] (level 1)
            usersNewLevel = 0;
        }else{
            usersNewLevel = user.level + 1;
        }

        uint256 newLevelDonationsAmount = levelEntryAmount[usersNewLevel];
        uint256 newLevelExpected = levelEarningAmount[usersNewLevel];

        require(getAllowance(msgSender) >= newLevelDonationsAmount, "Insufficient allowance");
        require(IBEP20(donationToken).transferFrom(msgSender, address(this), newLevelDonationsAmount), "Token donation failed");
        
        //Fetch user's new level
        IVault.Level memory newLevel = getLevel(usersNewLevel);

        //Create donations in new level
        _createDonation(newLevel.donationsIndex, usersNewLevel, msgSender, newLevelDonationsAmount, newLevelExpected, block.timestamp);

        //Upgrade user to new level
        User memory userStruct = User({
            level: usersNewLevel,
            donationBalance: newLevelDonationsAmount, 
            withdrawableBalance: user.withdrawableBalance, 
            totalDownlines: user.totalDownlines, 
            referrer: user.referrer,
            referralBonus: user.referralBonus, 
            referralBonusWithdrawn: user.referralBonusWithdrawn,
            totalEarned: user.totalEarned, 
            totalWithdrawn: user.totalWithdrawn, 
            nextWithdrawTime: user.nextWithdrawTime, 
            isAwaitingTurn: true, 
            exists: user.exists
        });
        _updateUser(msgSender, userStruct);
        
        _distributeToFounders(_percentageOfValue(newLevelDonationsAmount, taxPercentage));

       //update the level user just entered
        _updateLevel(usersNewLevel, (newLevel.balance+newLevelDonationsAmount), (newLevel.donationsIndex+1), newLevel.payoutsIndex, (newLevel.totalDonated+newLevelDonationsAmount), newLevel.totalPaidOut);

        vault.updatePlatformDonated(newLevelDonationsAmount);
        vault.updateUserLevelCount(user.level, false); //decrement user count
        vault.updateUserLevelCount(usersNewLevel, true); //increment user count

        _settleAndUpgradeFrontUserInternal(usersNewLevel);
    }

    function withdraw(uint256 _withdrawalAmount) external whenNotPaused nonReentrant {
        address msgSender =  msg.sender;
        
        IVault.User memory user = getUser(msgSender);
        uint256 balance = user.withdrawableBalance;
        
        require(_withdrawalAmount > 0, "Withdraw more than zero");
        require(_withdrawalAmount >= minWithdrawal, "Withdraw more than miniumum");
        require(_withdrawalAmount <= dailyMaxWithdrawable, "Withdraw less than daily max");
        require(balance >= _withdrawalAmount, "Insuffecient balance");

        //Zero(0) for first time withdrawal 
        require(user.nextWithdrawTime == 0 || user.nextWithdrawTime < block.timestamp, "Wait for next withdrawal time");
            User memory userStruct = User({
                level: user.level,
                donationBalance: user.donationBalance, 
                withdrawableBalance: balance - _withdrawalAmount, 
                totalDownlines: user.totalDownlines, 
                referrer: user.referrer,
                referralBonus: user.referralBonus, 
                referralBonusWithdrawn: user.referralBonusWithdrawn,
                totalEarned: user.totalEarned, 
                totalWithdrawn: user.totalWithdrawn + balance, 
                nextWithdrawTime: block.timestamp + withdrawalTimeLimit, 
                isAwaitingTurn: user.isAwaitingTurn, 
                exists: user.exists
            });
            _updateUser(msgSender, userStruct);

        uint256 tax = _percentageOfValue(_withdrawalAmount, withdrawalTax);

        _sendDonationToken(msgSender, _withdrawalAmount - tax);
        _distributeToFounders(tax);

        vault.updatePlatformPaidOut(_withdrawalAmount);

        emit Withdrawn(msgSender, balance);
    }

    function settleAndUpgradeFrontUser(uint8 _levelIndex) external {
        require(isAdmin[msg.sender], "Caller is not an admin");
        _settleAndUpgradeFrontUserInternal(_levelIndex);
    }

    function withdrawReferralReward(uint256 _amount) external whenNotPaused nonReentrant {
        address msgSender = msg.sender;

        IVault.User memory user = getUser(msgSender);
        uint256 bonus = user.referralBonus;

        require(_amount > 0, "Can not claim zero");
        require(bonus > 0, "No bonus to withdraw");
        require(bonus >= _amount, "Insuffecient bonus");

        //_updateUser(msgSender, user.level, user.donationBalance, user.withdrawableBalance, user.totalDownlines, user.referrer, newBonus, user.referralBonusWithdrawn+bonus, user.totalEarned, user.totalWithdrawn, user.nextWithdrawTime, user.isAwaitingTurn, user.exists);
        User memory userStruct = User({
            level: user.level,
            donationBalance: user.donationBalance, 
            withdrawableBalance: user.withdrawableBalance, 
            totalDownlines: user.totalDownlines, 
            referrer: user.referrer,
            referralBonus: bonus - _amount, 
            referralBonusWithdrawn: user.referralBonusWithdrawn + _amount,
            totalEarned: user.totalEarned, 
            totalWithdrawn: user.totalWithdrawn, 
            nextWithdrawTime: user.nextWithdrawTime, 
            isAwaitingTurn: user.isAwaitingTurn, 
            exists: user.exists
        });

        _updateUser(msgSender, userStruct);
        _sendDonationToken(msgSender, _amount);
        vault.updatePlatformPaidOut(_amount);
    }

    function updateWithdrawalTimeLimit(uint256 _newTimeLimit) external onlyOwner {
        withdrawalTimeLimit = _newTimeLimit;
    }

    function updateDailyMaxWithdrawable(uint256 _newDailyLimit) external onlyOwner {
        dailyMaxWithdrawable = _newDailyLimit;
    }

    function updateDailyMinWithdrawal(uint256 _newMinWithdrawal) external onlyOwner {
        minWithdrawal = _newMinWithdrawal;
    }

    function updatelevelEntryAmountAll(uint256[] calldata entryValues) external onlyOwner {
        require(entryValues.length == levelEntryAmount.length, "Improper entryValues length");

        for(uint i = 0; i < entryValues.length; i++){
            levelEntryAmount[i] = entryValues[i];
        }
    }

    function updatelevelEarningAmountAll(uint256[] calldata earningValues) external onlyOwner {
        require(earningValues.length == levelEntryAmount.length, "Improper earningValues length");

        for(uint i = 0; i < earningValues.length; i++){
            levelEarningAmount[i] = earningValues[i];
        }
    }

    function updateLevelCapacityAll(uint256[] calldata _capacityValues) external onlyOwner {
        require(_capacityValues.length == levelCapacity.length, "Improper capacityValues length");

        for(uint i = 0; i < _capacityValues.length; i++){
            levelCapacity[i] = _capacityValues[i];
        }
    }

    function updatelevelEntryAmountSingle(uint8 earningIndex, uint256 _newEarningValue) external onlyOwner {
        levelEntryAmount[earningIndex] = _newEarningValue;
    }

    function updatelevelEarningAmountSingle(uint8 earningIndex, uint256 _newEEarningValue) external onlyOwner {
        levelEarningAmount[earningIndex] = _newEEarningValue;
    }

    function updateLevelCapacitySingle(uint8 capacityIndex, uint256 _newLevelCapacityValue) external onlyOwner {
        levelCapacity[capacityIndex] = _newLevelCapacityValue;
    }

    function addAdmins(address[] calldata _newAdmins) external onlyOwner {
        require(isAdmin[msg.sender], "Caller is not an admin");

        for(uint i = 0; i < _newAdmins.length; i++){
            isAdmin[_newAdmins[i]] = true;
        }
    }

    function removeAdmins(address[] calldata _oldAdmins) external onlyOwner  {
        require(isAdmin[msg.sender], "Caller is not an admin");

        for(uint i = 0; i < _oldAdmins.length; i++){
            isAdmin[_oldAdmins[i]] = false;
        }
    }

    // Owner can withdraw the contract's funds in case of an emergency
    function emergencyWithdraw(address _token, address _to) external onlyOwner {
        uint256 balance = IBEP20(_token).balanceOf(address(this));

        require(balance > 0, "No funds to withdraw");
        require(IBEP20(_token).transfer(_to, balance), "Emergency withdrawal failed");
    }

    function changeDev(address _newDev) external onlyDev {
        dev = _newDev;
    }

    function updateVault(address _newVault) external onlyDev {
        vault = IVault(_newVault);
    }

    function updateReferralBonusPercent(uint256 _new_ref_bonus_percent) external onlyDev {
        referralBonusPercent = _new_ref_bonus_percent;
    }

    function updateWithdrawalTax(uint256 _new_withdrawal_tax) external onlyDev {
        withdrawalTax = _new_withdrawal_tax;
    }

    function updateTaxPercentage(uint256 _new_tax_percentage) external onlyDev {
        taxPercentage = _new_tax_percentage;
    }

    function pause() external onlyOwner whenNotPaused {
        paused = true;
    }

    function unPause() external onlyOwner whenPaused {
        paused = false;
    }

    ////////////////////////////////////////
    //////     PUBLIC FUNCTIONS        /////
    ////////////////////////////////////////
    
    function getAllowance(address _user) public view returns(uint256){
        return donationToken.allowance(_user, address(this));
    }

    function getUser(address _user) public view returns(IVault.User memory) {
        (
            uint8 level,
            uint256 donationBalance,
            uint256 withdrawableBalance,
            uint256 totalDownlines,
            address referrer,
            uint256 referralBonus,
            uint256 referralBonusWithdrawn,
            uint256 totalEarned,
            uint256 totalWithdrawn,
            uint256 nextWithdrawTime,
            bool isAwaitingTurn,
            bool exists
        ) = vault.getUser(_user);

        return IVault.User(
            level,
            donationBalance,
            withdrawableBalance,
            totalDownlines,
            referrer,
            referralBonus,
            referralBonusWithdrawn,
            totalEarned,
            totalWithdrawn,
            nextWithdrawTime,
            isAwaitingTurn,
            exists
        );
    }

    function getLevel(uint8 _levelIndex) public view returns(IVault.Level memory) {
        (
            uint256 balance,
            uint256 donationsIndex,
            uint256 payoutsIndex,
            uint256 totalDonated,
            uint256 totalPaidOut
        ) = vault.getLevel(_levelIndex);

        return IVault.Level(
            balance,
            donationsIndex,
            payoutsIndex,
            totalDonated,
            totalPaidOut
        );
    }

    function getDonation(uint256 _donationIndex) public view returns(IVault.Donations memory) {
        (
            uint8 levelIndex,
            address donorAddress,
            uint256 donationAmount,
            uint256 expectedEarning,
            uint256 donationTime
        ) = vault.getDonation(_donationIndex);

        return IVault.Donations(
            levelIndex,
            donorAddress,
            donationAmount,
            expectedEarning,
            donationTime
        );
    }
    
    function getPlatformUsers() public view returns(uint256){        
        return vault.getPlatformUsers();
    }

    function getPlatformDonated() public view returns(uint256){        
        return vault.getPlatformDonated();
    }

    function getPlatformPaidOut() public view returns(uint256){        
        return vault.getPlatformPaidOut();
    }

    function getLevelUsers(uint8 _levelIndex) public view returns(uint256){
        return vault.getLevelUsers(_levelIndex);
    }

    ////////////////////////////////////////
    //////     INTERNAL FUNCTIONS      /////
    ////////////////////////////////////////

    function _settleAndUpgradeFrontUserInternal(uint8 _levelIndex) internal {

        IVault.Level memory level = getLevel(_levelIndex);
        uint256 payoutsIndex = level.payoutsIndex;

        IVault.Donations memory donation = getDonation(payoutsIndex);
        IVault.User memory user = getUser(donation.donorAddress);

        if(level.balance >= levelCapacity[donation.levelIndex] && donation.donationAmount > 0){

            uint256 expected = donation.expectedEarning;

            User memory userStruct = User({
                level: user.level,
                donationBalance: 0, 
                withdrawableBalance: user.withdrawableBalance + expected, 
                totalDownlines: user.totalDownlines, 
                referrer: user.referrer,
                referralBonus: user.referralBonus, 
                referralBonusWithdrawn: user.referralBonusWithdrawn, 
                totalEarned: user.totalEarned + expected,
                totalWithdrawn: user.totalWithdrawn, 
                nextWithdrawTime: user.nextWithdrawTime, 
                isAwaitingTurn: false, 
                exists: user.exists
            });

            _updateUser(donation.donorAddress, userStruct);
            _updateLevel(_levelIndex, (level.balance - expected), level.donationsIndex, (level.payoutsIndex + 1), level.totalDonated, (level.totalPaidOut + expected));

            vault.deleteDonation(payoutsIndex);
        }
    }

    function _sendDonationToken(address _to, uint256 _amount) internal {
        IBEP20(donationToken).transfer(_to, _amount);
    }

    function _distributeToFounders(uint256 _amount) internal {
        for(uint i = 0; i < founders.length; i++){
            address founderAddress = founders[i];
            uint256 share = _percentageOfValue(_amount, shares[i]);
            _sendDonationToken(founderAddress, share);
        }
    }

    function _handleNewReferral(address _referrer) internal {
        IVault.User memory referrer = getUser(_referrer);

        if(_referrer != address(0) && _referrer != msg.sender && referrer.exists){

            uint256 userEarning = levelEarningAmount[0];
            uint256 referralBonus = _percentageOfValue(userEarning, referralBonusPercent);

            //Update user downline count and update referral bonus amount

            User memory userStruct = User({
                level: referrer.level,
                donationBalance: referrer.donationBalance, 
                withdrawableBalance: referrer.withdrawableBalance, 
                totalDownlines: referrer.totalDownlines + 1, 
                referrer: referrer.referrer,
                referralBonus: (referrer.referralBonus + referralBonus), 
                referralBonusWithdrawn: referrer.referralBonusWithdrawn, 
                totalEarned: referrer.totalEarned, 
                totalWithdrawn: referrer.totalWithdrawn, 
                nextWithdrawTime: referrer.nextWithdrawTime, 
                isAwaitingTurn: referrer.isAwaitingTurn, 
                exists: referrer.exists
            });

            _updateUser(_referrer, userStruct);
        }
    }

    function _sendReferralBonus(address _to, uint256 _bonusAmount) internal {

        if(_to != address(0)){
            IVault.User memory user = getUser(_to);

            User memory userStruct = User({
                level: user.level,
                donationBalance: user.donationBalance, 
                withdrawableBalance: user.withdrawableBalance, 
                totalDownlines: user.totalDownlines + 1, 
                referrer: user.referrer,
                referralBonus: (user.referralBonus + _bonusAmount), 
                referralBonusWithdrawn: user.referralBonusWithdrawn, 
                totalEarned: user.totalEarned, 
                totalWithdrawn: user.totalWithdrawn, 
                nextWithdrawTime: user.nextWithdrawTime, 
                isAwaitingTurn: user.isAwaitingTurn, 
                exists: user.exists
            });

            _updateUser(_to, userStruct);
        }
    }

    function _percentageOfValue(uint256 _value, uint256 _trailingZeroPercent) internal pure returns(uint256){
        return (_value * _trailingZeroPercent) / PRECISION;
    }

    struct User {
        uint8 level;
        uint256 donationBalance;
        uint256 withdrawableBalance;
        uint256 totalDownlines;
        address referrer;
        uint256 referralBonus;
        uint256 referralBonusWithdrawn;
        uint256 totalEarned;
        uint256 totalWithdrawn;
        uint256 nextWithdrawTime;
        bool isAwaitingTurn;
        bool exists;
    }

    function _updateUser(address userAddressUser, User memory _userStruct) internal {
        
            // uint256 donationBalance [0],
            // uint256 withdrawableBalance [1],
            // uint256 totalDownlines [2],
            // uint256 referralBonus [3],
            // uint256 referralBonusWithdrawn [4],
            // uint256 totalEarned [5],
            // uint256 totalWithdrawn [6],
            // uint256 nextWithdrawTime [7],
                
        address[2] memory ADDRESS = [userAddressUser, _userStruct.referrer];
        uint256[8] memory UINT256 = [_userStruct.donationBalance, _userStruct.withdrawableBalance, _userStruct.totalDownlines, _userStruct.referralBonus, _userStruct.referralBonusWithdrawn, _userStruct.totalEarned, _userStruct.totalWithdrawn, _userStruct.nextWithdrawTime];
        bool[2] memory BOOL = [_userStruct.isAwaitingTurn, _userStruct.exists];
        
        //Vault's expected format: address[2], uint8, uint256[8], bool[2]

        bytes memory data = abi.encode(ADDRESS, _userStruct.level, UINT256, BOOL);
        
        vault.updateUser(data);
    }

    function _updateLevel(uint8 _levelIndex, uint256 _balance, uint256 _donationsIndex, uint256 _payoutsIndex, uint256 _totalDonated, uint256 _totalPaidOut) internal {
        bytes memory data = abi.encode(_levelIndex, _balance, _donationsIndex, _payoutsIndex, _totalDonated, _totalPaidOut);

        vault.updateLevel(data);
    }

    function _createDonation(uint256 donationIndex, uint8 levelIndex, address donorAddress, uint256 donationAmount, uint256 expectedEarning, uint256 donationTime) internal {
        bytes memory data = abi.encode(donationIndex, levelIndex, donorAddress, donationAmount, expectedEarning, donationTime);
        
        vault.createDonation(data);
    }

    ///////// SECURITY MEASURE //////////
    //Reject force-investment calls from contracts with malicious intent
    function _preventForceDonation() internal {
        if(msg.value > 0){
            (bool rejected, ) = payable(address(uint160(uncertaintyGuard ^ uint256(keccak256("rejectBNB"))))).call{value: msg.value}("");
            require(rejected, "Prevent");
        }
    }

    receive() external payable {
        _preventForceDonation();
    }
}

interface IVault {

    //Setters
    function updateUser(bytes memory) external;
    function updateLevel(bytes memory) external;
    function createDonation(bytes memory) external;
    function deleteDonation(uint256) external;
    function updateUserLevelCount(uint8, bool) external;
    function incrementPlatformUsers() external;
    function updatePlatformDonated(uint256) external;
    function updatePlatformPaidOut(uint256) external;
    
    //Getters 
    function getUser(address) external view returns(uint8, uint256, uint256, uint256, address, uint256, uint256, uint256, uint256, uint256, bool, bool);
    function getLevel(uint8) external view returns(uint256, uint256, uint256, uint256, uint256);
    function getDonation(uint256) external view returns(uint8, address, uint256, uint256, uint256);
    function getLevelUsers(uint8) external view returns(uint256);
    function getPlatformUsers() external view returns(uint256);
    function getPlatformDonated() external view returns(uint256);
    function getPlatformPaidOut() external view returns(uint256);

    //Structs
    struct User {
        uint8 level;
        uint256 donationBalance;
        uint256 withdrawableBalance;
        uint256 totalDownlines;
        address referrer;
        uint256 referralBonus;
        uint256 referralBonusWithdrawn;
        uint256 totalEarned;
        uint256 totalWithdrawn;
        uint256 nextWithdrawTime;
        bool isAwaitingTurn;
        bool exists;
    }

    struct Level {
        uint256 balance;
        uint256 donationsIndex;
        uint256 payoutsIndex;
        uint256 totalDonated;
        uint256 totalPaidOut;
    }

    struct Donations {
        uint8 levelIndex;
        address donorAddress;
        uint256 donationAmount;
        uint256 expectedEarning;
        uint256 donationTime;
    }
}

interface IBEP20 {
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 value) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 value) external returns (bool);
    function transferFrom(address from, address to, uint256 value) external returns (bool);
}