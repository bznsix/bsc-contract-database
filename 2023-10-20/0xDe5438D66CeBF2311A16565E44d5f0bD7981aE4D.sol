// SPDX-License-Identifier: MIT

pragma solidity ^0.8.16;

interface IERC20 {
    function transfer(address to, uint256 tokens) external returns (bool success);
    function transferFrom(address from, address to, uint256 tokens) external returns (bool success);
    function balanceOf(address tokenOwner) external view returns (uint256 balance);
    function approve(address spender, uint256 tokens) external returns (bool success);
    function allowance(address tokenOwner, address spender) external view returns (uint256 remaining);
    function totalSupply() external view returns (uint256);
    event Transfer(address indexed from, address indexed to, uint256 tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint256 tokens);
}

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
        c = a + b;
        require(c >= a, "SafeMath: addition overflow");
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256 c) {
        require(b <= a, "SafeMath: subtraction overflow");
        c = a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
        c = a * b;
        require(a == 0 || c / a == b, "SafeMath: multiplication overflow");
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256 c) {
        require(b > 0, "SafeMath: division by zero");
        c = a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

contract Owned {
    address public owner;

    event OwnershipTransferred(address indexed _from, address indexed _to);

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can call this function");
        _;
    }

    function transferOwnership(address _newOwner) public onlyOwner {
        owner = _newOwner;
        emit OwnershipTransferred(owner, _newOwner);
    }
}

contract pacoStaking is Owned {
    
    using SafeMath for uint256;

    address public token;
    uint256 public totalStaked;
    uint256 public stakingTaxRate;
    uint256 public stakeTime;
    uint256 public dailyROI;                         // 100 = 1%
    uint256 public unstakingTaxRate;                   // 10 = 1%
    uint256 public minimumStakeValue;
    bool public active = true;
    bool public registered = true;

    mapping(address => uint256) public stakes;
    mapping(address => uint256) public referralRewards;
    mapping(address => uint256) public referralCount;
    mapping(address => uint256) public stakeRewards;
    mapping(address => uint256) private lastClock;
    mapping(address => uint256) private timeOfStake;
    
    event OnWithdrawal(address sender, uint256 amount);
    event OnStake(address sender, uint256 amount, uint256 tax);
    event OnUnstake(address sender, uint256 amount, uint256 tax);
    event OnRegisterAndStake(address stakeholder, uint256 amount, uint256 totalTax, address _referrer);
    
    constructor(
        address _token,
        uint256 _stakingTaxRate, 
        uint256 _unstakingTaxRate,
        uint256 _dailyROI,
        uint256 _stakeTime,
        uint256 _minimumStakeValue
    ) {
        token = _token;
        stakingTaxRate = _stakingTaxRate;
        unstakingTaxRate = _unstakingTaxRate;
        dailyROI = _dailyROI;
        stakeTime = _stakeTime;
        minimumStakeValue = _minimumStakeValue;
    }
    
    modifier whenActive() {
        require(active, "Smart contract is currently inactive");
        _;
    }
    
    function calculateEarnings(address _stakeholder) public view returns(uint256) {
        uint256 activeDays = (block.timestamp - lastClock[_stakeholder]) / 86400;
        return (stakes[_stakeholder] * dailyROI * activeDays) / 10000;
    }
    
    function stake(uint256 _amount) external whenActive() {
        require(_amount >= minimumStakeValue, "Amount is below minimum stake value.");
        require(IERC20(token).balanceOf(msg.sender) >= _amount, "Must have enough balance to stake");
        require(IERC20(token).transferFrom(msg.sender, address(this), _amount), "Stake failed due to failed amount transfer.");
        uint256 stakingTax = (stakingTaxRate * _amount) / 1000;
        uint256 afterTax = _amount - stakingTax;
        totalStaked = totalStaked + afterTax;
        stakeRewards[msg.sender] = stakeRewards[msg.sender] + calculateEarnings(msg.sender);
        uint256 remainder = (block.timestamp - lastClock[msg.sender]) % 86400;
        lastClock[msg.sender] = block.timestamp - remainder;
        timeOfStake[msg.sender] = block.timestamp;
        stakes[msg.sender] = stakes[msg.sender] + afterTax;
        emit OnStake(msg.sender, afterTax, stakingTax);
    }
    
    function unstake(uint256 _amount) external {
        require(_amount <= stakes[msg.sender] && _amount > 0, 'Insufficient balance to unstake');
        uint256 unstakingTax = (unstakingTaxRate * _amount) / 1000;
        uint256 afterTax = _amount - unstakingTax;
        stakeRewards[msg.sender] = stakeRewards[msg.sender] + calculateEarnings(msg.sender);
        stakes[msg.sender] = stakes[msg.sender] - _amount;
        uint256 remainder = (block.timestamp - lastClock[msg.sender]) % 86400;
        lastClock[msg.sender] = block.timestamp - remainder;
        require(block.timestamp - timeOfStake[msg.sender] > stakeTime, "You need to stake for the minimum amount of days");
        totalStaked = totalStaked - _amount;
        IERC20(token).transfer(msg.sender, afterTax);
        emit OnUnstake(msg.sender, _amount, unstakingTax);
    }
    
    function withdrawEarnings() external returns (bool success) {
        uint256 totalReward = referralRewards[msg.sender] + stakeRewards[msg.sender] + calculateEarnings(msg.sender);
        require(totalReward > 0, 'No reward to withdraw'); 
        require(IERC20(token).balanceOf(address(this)) - totalStaked >= totalReward, 'Insufficient balance in pool');
        stakeRewards[msg.sender] = 0;
        referralRewards[msg.sender] = 0;
        referralCount[msg.sender] = 0;
        uint256 remainder = (block.timestamp - lastClock[msg.sender]) % 86400;
        lastClock[msg.sender] = block.timestamp - remainder;
        IERC20(token).transfer(msg.sender, totalReward);
        emit OnWithdrawal(msg.sender, totalReward);
        return true;
    }

    function rewardPool() external view onlyOwner() returns(uint256 claimable) {
        return (IERC20(token).balanceOf(address(this)) - totalStaked);
    }
    
    function changeActiveStatus() external onlyOwner() {
        active = !active;
    }
    
    function setStakingTaxRate(uint256 _stakingTaxRate) external onlyOwner() {
        stakingTaxRate = _stakingTaxRate;
    }

    function setUnstakingTaxRate(uint256 _unstakingTaxRate) external onlyOwner() {
        unstakingTaxRate = _unstakingTaxRate;
    }
    
    function setDailyROI(uint256 _dailyROI) external onlyOwner() {
        dailyROI = _dailyROI;
    }
    
    function setMinimumStakeValue(uint256 _minimumStakeValue) external onlyOwner() {
        minimumStakeValue = _minimumStakeValue;
    }
    
    function setStakeTime(uint256 _newStakeTime) external onlyOwner() {
        stakeTime = _newStakeTime;
    }
    
    function checkUnstakeStatus(address _unstaker) public view returns(bool) {
        return block.timestamp - timeOfStake[_unstaker] > stakeTime;
    }  
}