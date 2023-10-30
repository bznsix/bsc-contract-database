/**
 *Submitted for verification at BscScan.com on 2023-04-14
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


interface IERC20 {
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}



// OpenZeppelin Contracts (last updated v4.8.0) (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;

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
abstract contract ReentrancyGuard {
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
contract Staking is ReentrancyGuard {
    
    enum Status {
        PENDING,
        FINISHED
    }
     enum LevelStatus {
        NEWBIE,
        SILVER,
        GOLDEN,
        DIAMOND
    }
     struct Stake {
        uint256 amount;
        uint256 time;
        Status status;
        uint256 endtime;
    }
    IERC20 public token;
    address public owner;
    address[] users;
    uint256 public totalStakedAmounts = 0;
    uint256 public minimumStake = 20 * 10**18; 
    uint256 public maximumStake = 10000 * 10**18;
    uint256 public dailyInterestRate = 1;
    uint256 public referralLevel1Percentage = 7;
    uint256 public referralLevel2Percentage = 4;
    uint256 public referralLevel3Percentage = 2;
    uint256 public silverEligibleStakeAmount = 100 * 10**18; 
    uint256 public goldenEligibleStakeAmount = 1000 * 10**18; 
    uint256 public diamondEligibleStakeAmount = 100000 * 10**18; 
    uint256 public silverEligibleReferralCount = 50; 
    uint256 public goldenEligibleReferralCount = 100; 
    uint256 public diamondEligibleReferralCount = 200; 
    uint256 public silverReferralReward = 100 * 10**18;
    uint256 public goldenReferralReward = 400 * 10**18; 
    uint256 public diamondReferralReward = 800 * 10**18;  
    mapping(address => Stake[]) public stakedAmounts;
    mapping(address => uint256) public userTotalStakedAmounts;
    mapping(address => bool) public isOldUser;
    mapping(address => address) public referrers;
    mapping(address => uint256) public referralEarnings;
    mapping(address => address[]) public referralsList;
    mapping(address => LevelStatus) public userLevel;
    mapping(address => LevelStatus) public referrerLevel;

    event Staked(address indexed user, uint256 amount);
    event Reward(address indexed user, uint256 amount);
    event Claimed(address indexed user, uint256 amount, uint256 stakeIndex);
    event Withdrawn(address indexed user, uint256 amount, uint256 stakeIndex);

    constructor(IERC20 _token) {
        token = _token;
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the contract owner can call this function");
        _;
    }

    function stake(uint256 amount, address referrer) external nonReentrant {
        require(amount >= minimumStake && amount <= maximumStake, "Invalid amount");
        require(token.transferFrom(msg.sender, address(this), amount), "Token transfer failed");

        if (referrers[msg.sender] == address(0) && referrer != address(0) && referrer != msg.sender && userTotalStakedAmounts[referrer] > 0) {
            referrers[msg.sender] = referrer;
            referralsList[referrer].push(msg.sender);

            if (referralsList[referrer].length >= silverEligibleReferralCount && referrerLevel[referrer] != LevelStatus.DIAMOND) {
                    uint256 reward;
                if (referralsList[referrer].length >= diamondEligibleReferralCount) {
                    reward = diamondReferralReward;
                    referrerLevel[referrer] = LevelStatus.DIAMOND;
                } else if (referralsList[referrer].length >= goldenEligibleReferralCount) {
                    reward = goldenReferralReward;
                    referrerLevel[referrer] = LevelStatus.GOLDEN;
                } else if (referralsList[referrer].length >= silverEligibleReferralCount) {
                    reward = silverReferralReward;
                    referrerLevel[referrer] = LevelStatus.SILVER;
                }

                if(token.transfer(referrer, reward)){
                    emit Reward(referrer, reward);
                }
            }
        }

        if(!isOldUser[msg.sender]){
            isOldUser[msg.sender] = true;
            users.push(msg.sender);
        }

        stakedAmounts[msg.sender].push(Stake(amount, block.timestamp,Status.PENDING,block.timestamp+uint256(100 days)));
        userTotalStakedAmounts[msg.sender] +=amount;
        totalStakedAmounts += amount;

        if(userTotalStakedAmounts[msg.sender] > 0 && userTotalStakedAmounts[msg.sender] < silverEligibleStakeAmount){
            userLevel[msg.sender] = LevelStatus.NEWBIE;
        } else if(userTotalStakedAmounts[msg.sender] >= silverEligibleStakeAmount && userTotalStakedAmounts[msg.sender] < goldenEligibleStakeAmount){
            userLevel[msg.sender] = LevelStatus.SILVER;
        } else if(userTotalStakedAmounts[msg.sender] >= goldenEligibleStakeAmount && userTotalStakedAmounts[msg.sender] < diamondEligibleStakeAmount){
            userLevel[msg.sender] = LevelStatus.GOLDEN;
        } else if(userTotalStakedAmounts[msg.sender] >= diamondEligibleStakeAmount){
            userLevel[msg.sender] = LevelStatus.DIAMOND;
        }

        emit Staked(msg.sender, amount);
    }

    function claim(uint256 stakeIndex) external nonReentrant {
        Stake[] storage stakes = stakedAmounts[msg.sender];
        require(stakeIndex < stakes.length, "Invalid stake index");
        require(block.timestamp >= stakes[stakeIndex].time + uint256(1 days),'You can withdraw only after 24 hrs');

        Stake storage stakedData = stakes[stakeIndex];
        require(stakedData.status != Status.FINISHED, "Already tokens are withdrawn");

        uint256 earnings = calculateEarnings(msg.sender, stakedData.time, stakedData.amount);
        require(earnings > 0, "No earnings");

        require(token.transfer(msg.sender, earnings), "Token transfer failed");

        stakedData.time = block.timestamp;

        emit Claimed(msg.sender, earnings, stakeIndex);
    }

     function withdraw(uint256 stakeIndex) external nonReentrant {
        Stake[] storage stakes = stakedAmounts[msg.sender];
        require(block.timestamp >= stakes[stakeIndex].endtime,'You still have remaining time to withdraw');
        require(stakeIndex < stakes.length, "Invalid stake index");

        Stake storage stakedData = stakes[stakeIndex];
        require(stakedData.status != Status.FINISHED, "Already tokens are withdrawn");

        uint256 amount = stakedData.amount;
        uint256 earnings = calculateEarnings(msg.sender, stakedData.time, amount);

        if (earnings > 0) {
            if(earnings > amount){
                earnings = amount;
            }
            require(token.transfer(msg.sender, earnings), "Token transfer failed");
            emit Claimed(msg.sender, earnings,stakeIndex);
        }

        require(token.transfer(msg.sender, amount), "Token transfer failed");
        stakedData.status = Status.FINISHED;
        userTotalStakedAmounts[msg.sender] -=amount;
        totalStakedAmounts -= amount;
        stakedData.endtime=0;
        emit Withdrawn(msg.sender, amount, stakeIndex);
    }

    function calculateEarnings(address account,uint256 startTime,uint256 amount) internal returns (uint256) {    
        uint256 timeDiff = block.timestamp - startTime;
        uint256 earningsPercentage = timeDiff * dailyInterestRate / 86400;
        uint256 earnings = amount * earningsPercentage / 100;
    
        uint256 referrer1Earnings = earnings * referralLevel1Percentage / 100;
        referralEarnings[referrers[account]] += referrer1Earnings;
    
        address referrer2 = referrers[referrers[account]];
        if (referrer2 != address(0)) {
            uint256 referrer2Earnings = earnings * referralLevel2Percentage / 100;
            referralEarnings[referrer2] += referrer2Earnings;
            address referrer3 = referrers[referrer2];
            if (referrer3 != address(0)) {
                uint256 referrer3Earnings = earnings * referralLevel3Percentage / 100;
                referralEarnings[referrer3] += referrer3Earnings;
            }
        }

        return earnings;
    }

    function changeOwner(address _owneraddress) external onlyOwner {
        owner = _owneraddress;
    }

    function withdrawMoneyOwner(uint256 _amount) external onlyOwner {
        require(token.transfer(owner, _amount), "Token transfer failed");
    }

    function withdrawReferralEarnings() external nonReentrant {
        uint256 amount = referralEarnings[msg.sender];
        require(amount > 0, "No earnings");
        referralEarnings[msg.sender] = 0;
        require(token.transfer(msg.sender, amount), "Token transfer failed");
    }

    function updateReferralRewards(uint256 newsilverReward, uint256 newGoldenReward, uint256 newDiamondReward) external onlyOwner nonReentrant {
        silverReferralReward = newsilverReward;
        goldenReferralReward = newGoldenReward;
        diamondReferralReward = newDiamondReward;
    }

    function updateEligibleReferralCounts(uint256 newSilverCount, uint256 newGoldenCount, uint256 newDiamondCount) external onlyOwner nonReentrant {
        silverEligibleReferralCount = newSilverCount;
        goldenEligibleReferralCount = newGoldenCount;
        diamondEligibleReferralCount = newDiamondCount;
    }

    function updateEligibleStakeAmounts(uint256 silverAmount, uint256 goldenAmount, uint256 diamondAmount) external onlyOwner nonReentrant {
        silverEligibleStakeAmount = silverAmount;
        goldenEligibleStakeAmount = goldenAmount;
        diamondEligibleStakeAmount = diamondAmount;
    }

    function updateDailyInterestRate(uint256 _dailyInterestRate) external onlyOwner nonReentrant{
        dailyInterestRate=_dailyInterestRate;
    }

    function getReferralEarnings(address user) external view returns (uint256) {
        return referralEarnings[user];
    }

    function getUserStakes(address user) external view returns (Stake[] memory) {
        return stakedAmounts[user];
    }

    function getReferrerAddress(address user) external view returns (address) {
        return referrers[user];
    }

    function getUserReferralList(address user) external view returns (address[] memory) {
        return referralsList[user];
    }

    function getReferralLevel(address user) external view returns (LevelStatus) {
        return referrerLevel[user];
    }

    function getUserLevel(address user) external view returns (LevelStatus) {
        return userLevel[user];
    }

    function getUserTotalStaked(address user) external view returns (uint256) {
        return userTotalStakedAmounts[user];
    }

    function getTotalStaked() external view returns (uint256) {
        return totalStakedAmounts;
    }

    function getUsers() external view returns (address[] memory) {
        return users;
    }

    function getEligibleStakeAmounts() external view returns (uint256 bronze,uint256 silver,uint256 gold) {
        return (silverEligibleStakeAmount,goldenEligibleStakeAmount,diamondEligibleStakeAmount);
    }

    function getEligibleReferralCounts() external view returns (uint256 bronze,uint256 silver,uint256 gold) {
        return (silverEligibleReferralCount,goldenEligibleReferralCount,diamondEligibleReferralCount);
    }

    function getReferralRewards() external view returns (uint256 bronze,uint256 silver,uint256 gold) {
        return (silverReferralReward,goldenReferralReward,diamondReferralReward);
    }
}