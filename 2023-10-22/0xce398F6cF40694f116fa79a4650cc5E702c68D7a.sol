// SPDX-License-Identifier: --MIT--
pragma solidity ^0.8.16;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IBEP20 {
    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
}

contract VisionCoinStaking  {

    enum StakeType {
        SHORT_TERM,
        MEDIUM_TERM,
        LONG_TERM
    }

    struct Stake {
        StakeType stakeType;
        uint256 stakeAmount;
        uint256 rewardPerSecond;
        uint256 stakeStartTime;
        uint256 stakeEndTime;
        uint256 lastRewardTime;
        uint256 claimedRewardAmount;
        uint256 unstakeTime;
        bool isActive;
    }

    IBEP20 public immutable VISION_TOKEN;
    uint256 public totalStakeAmount;
    uint256 public totalRewardClaimed;

    uint256 public constant ST_REWARD_RATE_PER_YEAR = 12;
    uint256 public constant MT_REWARD_RATE_PER_YEAR = 14;
    uint256 public constant LT_REWARD_RATE_PER_YEAR = 16;
    uint256 public constant ST_STAKING_DURATION_IN_YEAR = 1;
    uint256 public constant MT_STAKING_DURATION_IN_YEAR = 3;
    uint256 public constant LT_STAKING_DURATION_IN_YEAR = 5;
    uint256 public constant SECONDS_IN_YEAR = 12 * 30 * 24 * 3600; // MONTH_IN_YEAR * DAY_IN_MONTH * HOUR_IN_DAY * SECOND_IN_HOUR

    mapping(StakeType => uint256) public stakeCounts;
    mapping(StakeType => uint256) public durations;
    mapping(StakeType => uint256 ) public rewardRates;
    mapping(address => uint256) public userStakeCount;
    mapping(StakeType => uint256) public totalStakeAmountPerType;
    mapping(address => mapping(uint256 => Stake)) public userStake;

    //events
    event RewardClaimed(
        uint256 indexed _stakeId,
        address indexed _stakerAddress,
        uint256 _rewardAmount,
        uint256 rewardTime,
        uint256 _claimedRewardAmount
    );
    event Unstaked(
        uint256 indexed _stakeId,
        address indexed _stakerAddress,
        uint256 _stakeAmount,
        StakeType _stakeType,
        uint256 _stakeStartTime,
        uint256 _stakeEndTime,
        uint256 _claimedRewardAmount
    );
    event Staked(
        uint256 indexed _stakeId,
        address indexed _stakerAddress,
        uint256 _stakeAmount,
        StakeType _stakeType,
        uint256 _stakeStartTime,
        uint256 _stakeEndTime
    );

    constructor(address _tokenAddress){
        require(_tokenAddress != address(0), "token address invalid.");

        VISION_TOKEN = IBEP20(_tokenAddress);
        durations[StakeType.SHORT_TERM] = ST_STAKING_DURATION_IN_YEAR * SECONDS_IN_YEAR;
        rewardRates[(StakeType.SHORT_TERM)] = ST_REWARD_RATE_PER_YEAR;
        durations[(StakeType.MEDIUM_TERM)] = MT_STAKING_DURATION_IN_YEAR * SECONDS_IN_YEAR;
        rewardRates[(StakeType.MEDIUM_TERM)] = MT_STAKING_DURATION_IN_YEAR * MT_REWARD_RATE_PER_YEAR;
        durations[(StakeType.LONG_TERM)] = LT_STAKING_DURATION_IN_YEAR * SECONDS_IN_YEAR;
        rewardRates[(StakeType.LONG_TERM)] = LT_STAKING_DURATION_IN_YEAR * LT_REWARD_RATE_PER_YEAR;
    }

    function pendingReward(address _userAddress, uint256 _stakeId) public view returns(uint256){
        if(_stakeId ==0 || _stakeId > userStakeCount[_userAddress])
            return 0;

        Stake storage stakeDetail = userStake[_userAddress][_stakeId];
        if(block.timestamp < stakeDetail.lastRewardTime)
            return 0;

        uint256 rewardAmount;
        if(block.timestamp >= stakeDetail.stakeEndTime ){
            rewardAmount = stakeDetail.rewardPerSecond * (stakeDetail.stakeEndTime - stakeDetail.lastRewardTime);
        }
        else{
            rewardAmount = stakeDetail.rewardPerSecond * (block.timestamp - stakeDetail.lastRewardTime);
        }

        return rewardAmount;
    }

    function availableRewardAmount() public view returns(uint256){
        return (VISION_TOKEN.balanceOf(address(this)) - totalStakeAmount);
    }

    function calculateRewardPerSecond(StakeType _stakeType ,uint256 _stakeAmount) internal view returns(uint256){
        uint256 totalReward = rewardRates[_stakeType] * _stakeAmount / 100;

        return (totalReward / durations[_stakeType]);
    }

    function claimReward(uint256 _stakeId) public{
        require(_stakeId <= userStakeCount[msg.sender] && _stakeId !=0 , "Invalid stakeId.");

        uint256 reward = pendingReward(msg.sender,_stakeId);
        require(reward > 0 , "No reward available for withdraw.");

        Stake storage stakeDetail = userStake[msg.sender][_stakeId];
        uint256 availableRewardToken = availableRewardAmount();
        require(availableRewardToken >= reward, "Reward token is insuffient!!");

        if(block.timestamp > stakeDetail.stakeEndTime)
            stakeDetail.lastRewardTime = stakeDetail.stakeEndTime;
        else
            stakeDetail.lastRewardTime = block.timestamp;

        stakeDetail.claimedRewardAmount += reward ;
        totalRewardClaimed += reward;
        VISION_TOKEN.transfer(msg.sender , reward);

        emit RewardClaimed(
            _stakeId,
            msg.sender,
            reward,
            block.timestamp,
            stakeDetail.claimedRewardAmount
        );
    }

    function stake(StakeType _stakeType , uint256 _stakeAmount) external {
        require(uint256(_stakeType) <= uint256(StakeType.LONG_TERM),"Invalid stake type");
        require(_stakeAmount > 0 , "Staking amount must be greater than Zero.");
        require(VISION_TOKEN.balanceOf(msg.sender) >= _stakeAmount , "You have not sufficient Vision Token.");

        VISION_TOKEN.transferFrom(msg.sender,address(this),_stakeAmount);
        Stake memory newStake;
        newStake.stakeType = _stakeType;
        newStake.stakeAmount = _stakeAmount;
        newStake.rewardPerSecond = calculateRewardPerSecond(_stakeType ,_stakeAmount);
        newStake.stakeStartTime = block.timestamp;
        newStake.stakeEndTime = block.timestamp + durations[_stakeType];
        newStake.lastRewardTime = block.timestamp;
        newStake.isActive = true;
        stakeCounts[_stakeType]++;
        userStakeCount[msg.sender]++;
        totalStakeAmountPerType[_stakeType] += _stakeAmount;
        totalStakeAmount += _stakeAmount;
        userStake[msg.sender][userStakeCount[msg.sender]]=newStake;

        emit Staked(
            userStakeCount[msg.sender],
            msg.sender,
            _stakeAmount,
            _stakeType,
            block.timestamp,
            newStake.stakeEndTime
        );
    }

    function unstake(uint256 _stakeId) external{
        require(_stakeId <= userStakeCount[msg.sender] && _stakeId !=0 , "Invalid stakeId.");

        Stake storage stakeDetail = userStake[msg.sender][_stakeId];
        require(block.timestamp > stakeDetail.stakeEndTime , "staking period not completed.");
        require(stakeDetail.isActive == true , "You alredy unstake your tokens.");

        stakeDetail.isActive = false;
        stakeDetail.unstakeTime = block.timestamp;
        if(pendingReward(msg.sender, _stakeId) > 0){
            claimReward(_stakeId);
        }

        totalStakeAmount -= stakeDetail.stakeAmount;
        totalStakeAmountPerType[stakeDetail.stakeType] -= stakeDetail.stakeAmount;
        VISION_TOKEN.transfer(msg.sender , stakeDetail.stakeAmount);

        emit Unstaked(
            _stakeId,
            msg.sender,
            stakeDetail.stakeAmount,
            stakeDetail.stakeType,
            stakeDetail.stakeStartTime,
            stakeDetail.stakeEndTime,
            stakeDetail.claimedRewardAmount
        );
    }

    function emergencyUnstake(uint256 _stakeId) external {
        require(_stakeId <= userStakeCount[msg.sender] && _stakeId !=0 , "Invalid stakeId.");

        Stake storage stakeDetail = userStake[msg.sender][_stakeId];
        require(block.timestamp > stakeDetail.stakeEndTime , "staking period not completed.");
        require(stakeDetail.isActive == true , "You alredy unstake your tokens.");

        stakeDetail.isActive = false;
        stakeDetail.unstakeTime = block.timestamp;

        totalStakeAmount -= stakeDetail.stakeAmount;
        totalStakeAmountPerType[stakeDetail.stakeType] -= stakeDetail.stakeAmount;
        VISION_TOKEN.transfer(msg.sender , stakeDetail.stakeAmount);

        emit Unstaked(
            _stakeId,
            msg.sender,
            stakeDetail.stakeAmount,
            stakeDetail.stakeType,
            stakeDetail.stakeStartTime,
            stakeDetail.stakeEndTime,
            stakeDetail.claimedRewardAmount
        );
    }
}