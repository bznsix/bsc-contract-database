// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

interface IBEP20 {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address who) external view returns (uint256);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function transfer(address to, uint256 value) external returns (bool);

    function approve(address spender, uint256 value) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

contract Ownable {
    address private _owner;

    event OwnershipRenounced(address indexed previousOwner);
    event TransferOwnerShip(address indexed previousOwner);

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
        _owner = msg.sender;
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(msg.sender == _owner, "Not owner");
        _;
    }

    function renounceOwnership() public onlyOwner {
        emit OwnershipRenounced(_owner);
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public onlyOwner {
        emit TransferOwnerShip(newOwner);
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0), "Owner can not be 0");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract TokenFarming is Ownable {
    uint256 noLockupDays = 99999; // no lockup days means user can withdraw anytime
    uint256 public minimumStakingAmount;
    uint256 public maximumStakingAmount;
    uint256 public noLockupRewardPer = 5; // .5% per day -> values are in 1000
    uint256 public lockup100DaysRewardPer = 15; // 1.5% per day -> values are in 1000
    uint256 public lockup150DaysRewardPer = 20; // 2% per day
    uint256 public lockup280DaysRewardPer = 25; // 2.5% per day

    uint256 public firstGenReferralPer = 200; // 20% -> values are in 1000
    uint256 public secondGenReferralPer = 100; // 10%
    uint256 public thirdGenReferralPer = 50; // 5%
    uint256 public fourthToTenthGenReferralPer = 10; // 1% === 10/1000

    IBEP20 public stakingToken;
    IBEP20 public token;

    bool lock_ = false;
    bool public stakingActive = true;

    // users
    address[] public users;
    mapping(address => bool) public isUser;

    mapping(address => bool) public isStaked;
    mapping(address => uint256) public lockupDays;
    mapping(address => uint256) public stakingBalance;
    mapping(address => uint256) public rewardsClaimed;
    mapping(address => uint256) public userUnlockTime;
    mapping(address => uint256) public totalRewardsClaimed;

    // referral mapping
    mapping(address => address) public referralMapping;
    mapping(address => address[]) public referralList;
    mapping(address => uint256) public referredAt;
    mapping(address => uint256) public referralClaimableRewards;
    mapping(address => uint256) public totalReferralRewardsClaimed;
    mapping(address => mapping(address => uint256)) public earnedAmountByRefFromMe;

    modifier lock() {
        require(!lock_, "Process is locked");
        lock_ = true;
        _;
        lock_ = false;
    }

    constructor() {
        stakingToken = IBEP20(0xA8230773Cb12Dd0500791bb3AD3F5aCc26452933);
        token = IBEP20(0x9A7646BCF322Bea1dee11FfF86d9D6d9E42E5009); // mars token
        uint8 _decimals = stakingToken.decimals();

        minimumStakingAmount = 5000 * (10 ** _decimals);
        maximumStakingAmount = 500000 * (10 ** _decimals);
    }

    // staking function
    function stake(uint256 _amount, uint256 _lockDays, address _referrer) public lock {
        require(stakingActive, "Staking is not active");
        require(isValidLockDays(_lockDays), "Invalid lock days");
        require(_amount >= minimumStakingAmount, "Amount less than minimum");
        require(_amount <= maximumStakingAmount, "Amount exceeds maximum");

        uint256 _userLockDays = lockupDays[msg.sender];
        require(_userLockDays == 0, "Already Staked");

        // Transfer tokens to this contract
        require(stakingToken.transferFrom(msg.sender, address(this), _amount), "Transfer failed");

        lockupDays[msg.sender] = _lockDays;
        stakingBalance[msg.sender] += _amount;

        // Set referral if applicable
        if (_referrer != address(0) && _referrer != msg.sender && referralMapping[msg.sender] == address(0) && isStaked[_referrer] && msg.sender != referralMapping[_referrer]) {
            referredAt[msg.sender] = block.timestamp;
            referralMapping[msg.sender] = _referrer;
            referralList[_referrer].push(msg.sender);
        }

        if(!isUser[msg.sender]){
            isUser[msg.sender] = true;
            users.push(msg.sender);
        }

        isStaked[msg.sender] = true;

        // Set unlock time for the staked tokens
        userUnlockTime[msg.sender] = block.timestamp + (_lockDays * 1 days);
    }


    // claimable rewards function
    function claimableRewards(address _user) public view returns (uint256) {
        uint256 _stakingAmount = stakingBalance[_user];
        uint256 _lockDays = lockupDays[_user];
        uint256 _days = getDaysCompleted(_user);

        if(_days > _lockDays){
            _days = _lockDays;
        }

        uint256 _rewardPercentage = getDailyRewardPercentage(_user);
                
        uint256 _amount = ((_stakingAmount * _rewardPercentage * _days) / (1000)) - rewardsClaimed[_user];
        return _amount;
    }

    // claimable referral rewards
    function claimableReferralRewards(address _user) public view returns (uint256){
        return referralClaimableRewards[_user];
    }

    // claim rewards function
    function claimRewards() public lock {
        require(stakingBalance[msg.sender] > 0, "No staking balance");

        uint256 _amount = claimableRewards(msg.sender);
        require(_amount > 0, "No rewards");

        uint256 _lockDays = lockupDays[msg.sender];

        rewardsClaimed[msg.sender] += _amount;
        totalRewardsClaimed[msg.sender] += _amount;

        // transfer tokens to this address
        token.transfer(msg.sender, _amount);

        uint256 _days = getDaysCompleted(msg.sender);

        // reset user data if user claimed all rewards
        if(_lockDays != noLockupDays && _days >= _lockDays){
            lockupDays[msg.sender] = 0;
            stakingBalance[msg.sender] = 0;
            userUnlockTime[msg.sender] = 0;
            rewardsClaimed[msg.sender] = 0;
        }

        // referral rewards
        address _referrer = referralMapping[msg.sender];
        if (_referrer != address(0)) {
            uint256 _referrerAmount = userReferralShare(_amount, 1);
            referralClaimableRewards[_referrer] += _referrerAmount;
            earnedAmountByRefFromMe[_referrer][msg.sender] += _referrerAmount;
        }
        _referrer = referralMapping[_referrer];
        if (_referrer != address(0)) {
            uint256 _referrerAmount = userReferralShare(_amount, 2);
            referralClaimableRewards[_referrer] += _referrerAmount;
            earnedAmountByRefFromMe[_referrer][msg.sender] += _referrerAmount;
        }
        _referrer = referralMapping[_referrer];
        if (_referrer != address(0)) {
            uint256 _referrerAmount = userReferralShare(_amount, 3);
            referralClaimableRewards[_referrer] += _referrerAmount;
            earnedAmountByRefFromMe[_referrer][msg.sender] += _referrerAmount;
        }
        _referrer = referralMapping[_referrer];
        if (_referrer != address(0)) {
            uint256 _referrerAmount = userReferralShare(_amount, 4);
            referralClaimableRewards[_referrer] += _referrerAmount;
        }
        _referrer = referralMapping[_referrer];
        if (_referrer != address(0)) {
            uint256 _referrerAmount = userReferralShare(_amount, 5);
            referralClaimableRewards[_referrer] += _referrerAmount;
        }
        _referrer = referralMapping[_referrer];
        if (_referrer != address(0)) {
            uint256 _referrerAmount = userReferralShare(_amount, 6);
            referralClaimableRewards[_referrer] += _referrerAmount;
        }
        _referrer = referralMapping[_referrer];
        if (_referrer != address(0)) {
            uint256 _referrerAmount = userReferralShare(_amount, 7);
            referralClaimableRewards[_referrer] += _referrerAmount;
        }
        _referrer = referralMapping[_referrer];
        if (_referrer != address(0)) {
            uint256 _referrerAmount = userReferralShare(_amount, 8);
            referralClaimableRewards[_referrer] += _referrerAmount;
        }
        _referrer = referralMapping[_referrer];
        if (_referrer != address(0)) {
            uint256 _referrerAmount = userReferralShare(_amount, 9);
            referralClaimableRewards[_referrer] += _referrerAmount;
        }
        _referrer = referralMapping[_referrer];
        if (_referrer != address(0)) {
            uint256 _referrerAmount = userReferralShare(_amount, 10);
            referralClaimableRewards[_referrer] += _referrerAmount;
        }
    }

    // unustake function only for no lockup days
    function unstake() public lock {
        uint256 _amount = stakingBalance[msg.sender];
        require(_amount > 0, "No staking balance");
        require(lockupDays[msg.sender] == noLockupDays, "Only for no lockup days");
        // check if claimable rewards are there;
        uint256 _claimableRewards = claimableRewards(msg.sender);
        require(_claimableRewards == 0, "Claim rewards first");
        
        lockupDays[msg.sender] = 0;
        stakingBalance[msg.sender] = 0;
        userUnlockTime[msg.sender] = 0;
        rewardsClaimed[msg.sender] = 0;

        // transfer tokens to this address
        stakingToken.transfer(msg.sender, _amount);
    }

    function userReferralShare(uint256 _amount,uint256 _referrerLevel) public view returns (uint256) {
        return (_amount * getReferralPercentage(_referrerLevel)) / 1000;
    }

    // claim referral rewards function
    function claimReferralRewards() public lock {
        uint256 _amount = claimableReferralRewards(msg.sender);
        require(_amount > 0, "No referral rewards");

        referralClaimableRewards[msg.sender] = 0;
        totalReferralRewardsClaimed[msg.sender] += _amount;

        // transfer tokens to this address
        token.transfer(msg.sender, _amount);
    }

    // internal functions
    function isValidLockDays(uint256 _lockDays) internal view returns (bool){
        if(_lockDays == noLockupDays || _lockDays == 100 || _lockDays == 150 || _lockDays == 280){
            return true;
        }else{
            return false;
        }
    }

    struct RefOfUser{
        address user;
        uint256 amount;
        uint256 timestamp;
    }

    // getReferralsData function
    function getReferralsData(address _user) public view returns (RefOfUser[] memory){
        uint256 length = users.length;
        RefOfUser[] memory _referrals = new RefOfUser[](length);
        uint256 count = 0;
        for (uint256 i = 0; i < length; i++) {
            uint256 _earnedAmount = earnedAmountByRefFromMe[_user][users[i]];
            if(_earnedAmount > 0){
                _referrals[count] = RefOfUser(users[i], _earnedAmount, referredAt[users[i]]);
                count++;
            }
        }

        assembly {
            mstore(_referrals, count)
        }

        return _referrals;        
    }

    function getDaysCompleted(address _user) internal view returns (uint256){
        uint256 _unlockTime = userUnlockTime[_user];
        uint256 _lockDays = lockupDays[_user];
        if(_unlockTime == 0){
            return 0;
        }
        uint256 _userLockTime = _unlockTime - (_lockDays * 1 days); // it will give time when user locked his tokens
        uint256 _days = (block.timestamp - _userLockTime) / (1 days);
        return _days;
    }

    function getReferralPercentage(uint256 _referrerLevel) internal view returns (uint256){
        if (_referrerLevel == 1) {
            return firstGenReferralPer;
        } else if (_referrerLevel == 2) {
            return secondGenReferralPer;
        } else if (_referrerLevel == 3) {
            return thirdGenReferralPer;
        } else if (_referrerLevel >= 4 && _referrerLevel <= 10) {
            return fourthToTenthGenReferralPer;
        } else {
            return 0;
        }
    }

    function getDailyRewardPercentage(address _user) internal view returns (uint256){
        uint256 _lockupDays = lockupDays[_user];
        if(_lockupDays == noLockupDays){
            return noLockupRewardPer;
        }else if(_lockupDays == 100){
            return lockup100DaysRewardPer;
        }else if(_lockupDays == 150){
            return lockup150DaysRewardPer;
        }else if(_lockupDays == 280){
            return lockup280DaysRewardPer;
        }else{
            return 0;
        }
    }

    // all onlyOwner functions here
    // create functions to override value for each global variable

    function setToken(address _token) public onlyOwner {
        token = IBEP20(_token);
    }

    function setNoLockupRewardPer(uint256 _noLockupRewardPer) public onlyOwner {
        noLockupRewardPer = _noLockupRewardPer;
    }

    function setLockup100DaysRewardPer(uint256 _lockup100DaysRewardPer) public onlyOwner {
        lockup100DaysRewardPer = _lockup100DaysRewardPer;
    }

    function setLockup150DaysRewardPer(uint256 _lockup150DaysRewardPer) public onlyOwner {
        lockup150DaysRewardPer = _lockup150DaysRewardPer;
    }

    function setLockup280DaysRewardPer(uint256 _lockup280DaysRewardPer) public onlyOwner {
        lockup280DaysRewardPer = _lockup280DaysRewardPer;
    }

    function setFirstGenReferralPer(uint256 _firstGenReferralPer) public onlyOwner {
        firstGenReferralPer = _firstGenReferralPer;
    }

    function setSecondGenReferralPer(uint256 _secondGenReferralPer) public onlyOwner {
        secondGenReferralPer = _secondGenReferralPer;
    }
    
    function setThirdGenReferralPer(uint256 _thirdGenReferralPer) public onlyOwner {
        thirdGenReferralPer = _thirdGenReferralPer;
    }

    function setFourthToTenthGenReferralPer(uint256 _fourthToTenthGenReferralPer) public onlyOwner {
        fourthToTenthGenReferralPer = _fourthToTenthGenReferralPer;
    }

    // set staking token
    function setStakingToken(address _stakingToken) public onlyOwner {
        stakingToken = IBEP20(_stakingToken);
    }

    // set minimum staking amount
    function setMinimumStakingAmount(uint256 _minimumStakingAmount) public onlyOwner{
        minimumStakingAmount = _minimumStakingAmount;
    }

    // set maximum staking amount
    function setMaximumStakingAmount(uint256 _maximumStakingAmount) public onlyOwner{
        maximumStakingAmount = _maximumStakingAmount;
    }

    // set staking active
    function setStakingActive(bool _stakingActive) public onlyOwner {
        stakingActive = _stakingActive;
    }

    // withdraw tokens
    function withdrawTokens(address _token, uint256 _amount) public onlyOwner {
        IBEP20(_token).transfer(msg.sender, _amount);
    }
}