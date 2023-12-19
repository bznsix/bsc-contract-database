// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;


interface IERC20 {
    function balanceOf(address account) external view returns (uint);

    function transfer(address reNLCient, uint amount) external returns (bool);

    function transferFrom(address sender, address reNLCient, uint amount) external returns (bool);
}


abstract contract Context {
    function _msgSender() internal view returns (address) {
        return msg.sender;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
        _transferOwnership(_msgSender());
    }

    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    function owner() public view returns (address) {
        return _owner;
    }

    function _checkOwner() private view {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }

    function renounceOwnership() external onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) external onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

abstract contract ReentrancyGuard {
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        _nonReentrantBefore();
        _;
        _nonReentrantAfter();
    }

    function _nonReentrantBefore() private {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        _status = _ENTERED;
    }

    function _nonReentrantAfter() private {
        _status = _NOT_ENTERED;
    }

    function _reentrancyGuardEntered() private view returns (bool) {
        return _status == _ENTERED;
    }
}



contract NLCStaking is Ownable, ReentrancyGuard {
    struct PoolInfo {
        uint256 lockupDuration;
        uint256 returnPer;
    }
    struct OrderInfo {
        address beneficiary;
        uint256 amount;
        uint256 lockupDuration;
        uint256 returnPer;
        uint256 starttime;
        uint256 endtime;
        uint256 claimedReward;
        bool claimed;
    }
    uint256 private constant _days90 = 90 days;
    uint256 private constant _days190 = 190 days;
    uint256 private constant _days280 = 280 days;
    uint256 private constant _days360 = 360 days;
    uint256 private constant _days420 = 420 days;
    uint256 private constant _days680 = 680 days;

    uint256 private constant _days365 = 365 days;
    IERC20 public token;
    bool public started = true;
    uint256 public emergencyWithdrawFeesPercentage = 20;

    uint256 private _90daysPercentage = 29;
    uint256 private _190daysPercentage = 49;
    uint256 private _280daysPercentage = 69;
    uint256 private _360daysPercentage = 99;
    uint256 private _420daysPercentage = 119;
    uint256 private _680daysPercentage = 149;
    uint256  public  minimumAmount = 30000 * 10 **9;
    uint256 private latestOrderId = 0;
    uint public totalStakers ; // use 
    uint public totalStaked ; // use 
    uint256 public totalStake = 0;
    uint256 public totalWithdrawal = 0;
    uint256 public totalRewardPending = 0;
    uint256 public totalRewardsDistribution = 0;

    mapping(uint256 => PoolInfo) public pooldata;
    mapping(address => uint256) public balanceOf;
    mapping(address => uint256) public totalRewardEarn;
    mapping(uint256 => OrderInfo) public orders;
    mapping(address => uint256[]) private orderIds;

    mapping(address => mapping(uint => bool)) public hasStaked;
    mapping(uint => uint) public stakeOnPool;
    mapping(uint => uint) public rewardOnPool;
    mapping(uint => uint) public stakersPlan;

    event Deposit(
        address indexed user,
        uint256 indexed lockupDuration,
        uint256 amount,
        uint256 returnPer
    );
    event Withdraw(
        address indexed user,
        uint256 amount,
        uint256 reward,
        uint256 total
    );
    event WithdrawAll(address indexed user, uint256 amount);
    event RewardClaimed(address indexed user, uint256 reward);
    event RefRewardClaimed(address indexed user, uint256 reward);

    constructor(address _token, bool _started) {
        token = IERC20(_token);
        started = _started;

        pooldata[90].lockupDuration = _days90; // 90 days
        pooldata[90].returnPer = _90daysPercentage;

        pooldata[190].lockupDuration = _days190; // 190 days
        pooldata[190].returnPer = _190daysPercentage;

         pooldata[280].lockupDuration = _days280; // 280 days
        pooldata[280].returnPer = _280daysPercentage;

         pooldata[360].lockupDuration = _days360; // 360 days
        pooldata[360].returnPer = _360daysPercentage;

         pooldata[420].lockupDuration = _days420; // 420 days
        pooldata[420].returnPer = _420daysPercentage;

         pooldata[680].lockupDuration = _days680; // 680 days
        pooldata[680].returnPer = _680daysPercentage;


    }

    function deposit(
        uint256 _amount,
        uint256 _lockupDuration
    ) external {
      
        require(_amount >= minimumAmount , " Minimum Stake amount is 30000" );
        PoolInfo storage pool = pooldata[_lockupDuration];
        require(
            pool.lockupDuration > 0,
            "TokenStakingNLC: asked pool does not exist"
        );
        require(started, "TokenStakingNLC: staking not yet started");
        require(_amount > 0, "TokenStakingNLC: stake amount must be non zero");

        uint256 APY = (_amount * pool.returnPer) / 100;
        uint256 userReward = (APY * pool.lockupDuration) / _days365;
        require(
            token.transferFrom(_msgSender(), address(this), _amount),
            "TokenStakingNLC: token transferFrom via deposit not succeeded"
        );

        orders[++latestOrderId] = OrderInfo(
            _msgSender(),
            _amount,
            pool.lockupDuration,
            pool.returnPer,
            block.timestamp,
            block.timestamp + pool.lockupDuration,
            0,
            false
        );

          if (!hasStaked[msg.sender][_lockupDuration]) {
             stakersPlan[_lockupDuration] = stakersPlan[_lockupDuration] + 1;
             totalStakers = totalStakers + 1 ;
        }

        hasStaked[msg.sender][_lockupDuration] = true;
        stakeOnPool[_lockupDuration] = stakeOnPool[_lockupDuration] + _amount ;
        totalStaked = totalStaked + _amount ;
        totalStake += _amount;
        totalRewardPending += userReward;
        balanceOf[_msgSender()] += _amount;
        orderIds[_msgSender()].push(latestOrderId);
        emit Deposit(
            _msgSender(),
            pool.lockupDuration,
            _amount,
            pool.returnPer
        );
    }


    function withdraw(uint256 orderId) external nonReentrant {
        require(
            orderId <= latestOrderId,
            "TokenStakingNLC: INVALID orderId, orderId greater than latestOrderId"
        );

        OrderInfo storage orderInfo = orders[orderId];
        require(
            _msgSender() == orderInfo.beneficiary,
            "TokenStakingNLC: caller is not the beneficiary"
        );
        require(!orderInfo.claimed, "TokenStakingNLC: order already unstaked");

          require(
            block.timestamp >= orderInfo.endtime,
            "TokenStakingNLC: stake locked until lock duration completion"
        );
    
        uint256 claimAvailable = pendingRewards(orderId);
        uint256 total = orderInfo.amount + claimAvailable;

        totalRewardEarn[_msgSender()] += claimAvailable;
        totalRewardsDistribution += claimAvailable;
        orderInfo.claimedReward += claimAvailable;
        totalRewardPending -= claimAvailable;

        balanceOf[_msgSender()] -= orderInfo.amount;
        totalWithdrawal += orderInfo.amount;
        orderInfo.claimed = true;

        require(
            token.transfer(address(_msgSender()), total),
            "TokenStakingNLC: token transfer via withdraw not succeeded"
        );
        rewardOnPool[orderInfo.lockupDuration] = rewardOnPool[orderInfo.lockupDuration] + claimAvailable ;
        emit Withdraw(_msgSender(), orderInfo.amount, claimAvailable, total);
    }


    function claimRewards(uint256 orderId) external nonReentrant {
        require(
            orderId <= latestOrderId,
            "TokenStakingNLC: INVALID orderId, orderId greater than latestOrderId"
        );

        OrderInfo storage orderInfo = orders[orderId];
        require(
            _msgSender() == orderInfo.beneficiary,
            "TokenStakingNLC: caller is not the beneficiary"
        );
        require(!orderInfo.claimed, "TokenStakingNLC: order already unstaked");

        uint256 claimAvailable = pendingRewards(orderId);
        totalRewardEarn[_msgSender()] += claimAvailable;
        totalRewardsDistribution += claimAvailable;
        totalRewardPending -= claimAvailable;
        orderInfo.claimedReward += claimAvailable;

        require(
            token.transfer(address(_msgSender()), claimAvailable),
            "TokenStakingNLC: token transfer via claim rewards not succeeded"
        );
        rewardOnPool[orderInfo.lockupDuration] = rewardOnPool[orderInfo.lockupDuration] + claimAvailable ;
        emit RewardClaimed(address(_msgSender()), claimAvailable);
    }

    function pendingRewards(uint256 orderId) public view returns (uint256) {
        require(
            orderId <= latestOrderId,
            "TokenStakingNLC: INVALID orderId, orderId greater than latestOrderId"
        );

        OrderInfo storage orderInfo = orders[orderId];
        if (!orderInfo.claimed) {
            if (block.timestamp >= orderInfo.endtime) {
                uint256 APY = (orderInfo.amount * orderInfo.returnPer) / 100;
                uint256 reward = (APY * orderInfo.lockupDuration) / _days365;
                uint256 claimAvailable = reward - orderInfo.claimedReward;
                return claimAvailable;
            } else {
                uint256 stakeTime = block.timestamp - orderInfo.starttime;
                uint256 APY = (orderInfo.amount * orderInfo.returnPer) / 100;
                uint256 reward = (APY * stakeTime) / _days365;
                uint256 claimAvailableNow = reward - orderInfo.claimedReward;
                return claimAvailableNow;
            }
        } else {
            return 0;
        }
    }

 function emergencyWithdraw(uint256 orderId) external nonReentrant {
        require(
            orderId <= latestOrderId,
            "TokenStakingNLC: INVALID orderId, orderId greater than latestOrderId"
        );

        OrderInfo storage orderInfo = orders[orderId];
        require(
            _msgSender() == orderInfo.beneficiary,
            "TokenStakingNLC: caller is not the beneficiary"
        );
        require(!orderInfo.claimed, "TokenStakingNLC: order already unstaked");

        uint256 claimAvailable = pendingRewards(orderId);
        uint256 fees = (orderInfo.amount * emergencyWithdrawFeesPercentage) /
            100;
        orderInfo.amount -= fees;
        uint256 total = orderInfo.amount + claimAvailable;

        totalRewardEarn[_msgSender()] += claimAvailable;
        totalRewardsDistribution += claimAvailable;
        totalRewardPending -= claimAvailable;
        orderInfo.claimedReward += claimAvailable;

        uint256 APY = ((orderInfo.amount + fees) * orderInfo.returnPer) / 100;
        uint256 totalReward = (APY * orderInfo.lockupDuration) / _days365;
        totalRewardPending -= (totalReward - orderInfo.claimedReward);

        balanceOf[_msgSender()] -= (orderInfo.amount + fees);
        totalWithdrawal += (orderInfo.amount + fees);
        orderInfo.claimed = true;

        require(
            token.transfer(address(_msgSender()), total),
            "TokenStakingNLC: token transfer via emergency withdraw not succeeded"
        );
         require(
            token.transfer(0x6B13e81a716eb305994fB48a8a60b44c8A43eDC8, fees),
            "TokenStakingNLC: token transfer via emergency withdraw to admin is not succeeded"
        );
        emit WithdrawAll(_msgSender(), total);
    }



    function toggleStaking(bool _start) external onlyOwner returns (bool) {
        started = _start;
        return true;
    }

    function investorOrderIds(
        address investor
    ) external view returns (uint256[] memory ids) {
        uint256[] memory arr = orderIds[investor];
        return arr;
    }

    function _totalRewards(address ref) private view returns (uint256) {
        uint256 rewards;
        uint256[] memory arr = orderIds[ref];
        for (uint256 i = 0; i < arr.length; i++) {
            OrderInfo memory order = orders[arr[i]];
            rewards += (order.claimedReward + pendingRewards(arr[i]));
        }
        return rewards;
    }


    function transferAnyERC20Token(
        address payaddress,
        address tokenAddress,
        uint256 amount
    ) external onlyOwner {
        IERC20(tokenAddress).transfer(payaddress, amount);
    }
}