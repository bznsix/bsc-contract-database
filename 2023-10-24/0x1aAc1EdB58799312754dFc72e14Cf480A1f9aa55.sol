// SPDX-License-Identifier: MIT

pragma solidity 0.8.19;

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
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator.
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {trySub}.
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting with custom message when dividing by zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryMod}.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
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

contract PacoStaking is Owned {

    using SafeMath for uint256;
    
    address immutable public token;
    uint256 public totalStaked;
    uint256 public stakingTaxRate;                   // 10 = 1%
    uint256 public stakeTime;
    uint256 public dailyROI;                         // 100 = 1%
    uint256 public unstakingTaxRate;                 // 10 = 1%
    uint256 public minimumStakeValue;
    bool public active = true;

    mapping(address => uint256) public stakes;
    mapping(address => uint256) public stakeRewards;
    mapping(address => uint256) private timeOfStake;
    mapping(address => uint256) private lastClock;
    
    event OnWithdrawal(address sender, uint256 amount);
    event OnStake(address sender, uint256 amount, uint256 tax);
    event OnUnstake(address sender, uint256 amount, uint256 tax);
    event OnStatusChange(bool newStatus);
    event OnStakingTaxRateChange(uint256 newRate);
    event OnUnstakingTaxRateChange(uint256 newRate);
    event OnDailyROIChange(uint256 newROI);
    event OnMinimumStakeValueChange(uint256 newValue);
    event OnStakeTimeChange(uint256 newStakeTime);

    
    constructor(
        address _token,
        uint256 _stakingTaxRate, 
        uint256 _unstakingTaxRate,
        uint256 _dailyROI,
        uint256 _stakeTime,
        uint256 _minimumStakeValue
    ) {
        require(_token != address(0), "Token address cannot be zero");
        require(_stakingTaxRate > 0, "Staking tax rate must be greater than zero");
        require(_unstakingTaxRate > 0, "Unstaking tax rate must be greater than zero");
        require(_dailyROI > 0, "Daily ROI must be greater than zero");
        require(_stakeTime > 0, "Stake time must be greater than zero");
        require(_minimumStakeValue > 0, "Minimum stake value must be greater than zero");


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
    uint256 activeMinutes = (block.timestamp - timeOfStake[_stakeholder]) / 1 minutes; // Reward majority
    return (stakes[_stakeholder] * dailyROI * activeMinutes) / (100 * 2 * 24 hours); // Distributed every 1 minute
    }
    
    function stake(uint256 _amount) external whenActive() {
        require(_amount >= minimumStakeValue, "Amount is below minimum stake value.");
        require(IERC20(token).balanceOf(msg.sender) >= _amount, "Must have enough balance to stake");
        require(IERC20(token).transferFrom(msg.sender, address(this), _amount), "Stake failed due to failed amount transfer.");
        uint256 stakingTax = (stakingTaxRate * _amount) / 1000;
        uint256 afterTax = _amount - stakingTax;
        totalStaked = totalStaked + afterTax;
        stakeRewards[msg.sender] = stakeRewards[msg.sender] + calculateEarnings(msg.sender);
        uint256 remainder = (block.timestamp - lastClock[msg.sender]) % 1 days;
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
        uint256 remainder = (block.timestamp - lastClock[msg.sender]) % 1 days;
        lastClock[msg.sender] = block.timestamp - remainder;
        require(block.timestamp - timeOfStake[msg.sender] > stakeTime, "You need to stake for the minimum amount of days");
        totalStaked = totalStaked - _amount;
        IERC20(token).transfer(msg.sender, afterTax);
        emit OnUnstake(msg.sender, _amount, unstakingTax);
    }
    
    function withdrawEarnings() external returns (bool success) {
        uint256 totalReward = stakeRewards[msg.sender] + calculateEarnings(msg.sender);
        require(totalReward > 0, 'No reward to withdraw'); 
        require(IERC20(token).balanceOf(address(this)) - totalStaked >= totalReward, 'Insufficient balance in pool');
        stakeRewards[msg.sender] = 0;
        uint256 remainder = (block.timestamp - timeOfStake[msg.sender]) % 1 minutes;
        timeOfStake[msg.sender] = block.timestamp - remainder;
        IERC20(token).transfer(msg.sender, totalReward);
        emit OnWithdrawal(msg.sender, totalReward);
        return true;
    }


    function rewardPool() external view onlyOwner() returns(uint256 claimable) {
        return (IERC20(token).balanceOf(address(this)) - totalStaked);
    }
    
    function changeActiveStatus() external onlyOwner() {
        active = !active;
        emit OnStatusChange(active);
    }
    
    function setStakingTaxRate(uint256 _stakingTaxRate) external onlyOwner() {
        require(_stakingTaxRate < 1000, "Staking tax rate must be less than 1000");
        stakingTaxRate = _stakingTaxRate;
        emit OnStakingTaxRateChange(_stakingTaxRate);
    }
    
    function setUnstakingTaxRate(uint256 _unstakingTaxRate) external onlyOwner() {
        require(_unstakingTaxRate < 1000, "Unstaking tax rate must be less than 1000");
        unstakingTaxRate = _unstakingTaxRate;
        emit OnUnstakingTaxRateChange(_unstakingTaxRate);
    }
    
    function setDailyROI(uint256 _dailyROI) external onlyOwner() {
        dailyROI = _dailyROI;
        emit OnDailyROIChange(_dailyROI);
    }
    
    function setMinimumStakeValue(uint256 _minimumStakeValue) external onlyOwner() {
        minimumStakeValue = _minimumStakeValue;
        emit OnMinimumStakeValueChange(_minimumStakeValue);
    }
    
    function setStakeTime(uint256 _newStakeTime) external onlyOwner() {
        stakeTime = _newStakeTime;
        emit OnStakeTimeChange(_newStakeTime);
    }
    
    function checkUnstakeStatus(address _unstaker) public view returns(bool) {
        return block.timestamp - timeOfStake[_unstaker] > stakeTime;
    }

}