// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby disabling any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
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
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (utils/math/SafeMath.sol)

pragma solidity ^0.8.0;

// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is generally not needed starting with Solidity 0.8, since the compiler
 * now has built in overflow checking.
 */
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
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
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
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
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
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

interface TokenPriceInterface {
    function getTokenPrice() external view returns (uint256);
}

contract staking is Ownable {
    using SafeMath for uint256;

    IERC20 public usdtToken; // The USDT token contract

    uint256 public totalInvested;
    uint256 public totalRewards;

    uint256 public MINIMUM_STAKING_AMOUNT = 30 ether;
    uint256 public UNSTAKE_PERIOD = 500 days;

    bool public isPaused = false;

    struct User {
        address referrer;
        address[] referrals;
    }

    struct group {
        bool step1;
        bool step2;
        bool step3;
        bool step4;
        bool step5;
        bool step6;
        bool step7;
        bool step8;
    }

    mapping(address => group) public incomeGroup;

    mapping(address => User) public users;
    mapping(address => uint256) public totalRoiRewards;
    mapping(address => uint256) public stakedAmount;
    mapping(address => uint256) public rewardsEarned;
    mapping(address => uint256) public rewardsWithdrawn;
    mapping(address => uint256) public totalUnstaked;
    mapping(address => address) public referrerOf;
    mapping(address => uint256) public totalReferrals;
    mapping(address => uint256) public stakingTimestamp;
    mapping(address => uint256) public checkTime;
    mapping(uint256 => uint256) public levelPercentages;
    mapping(address => address[]) myDirectReferrals;
    mapping(address => uint256) public totalRewardsWithdraw;

    event Staked(address indexed user, uint256 amount);
    event Unstaked(address indexed user, uint256 amount);
    event RewardClaimed(address indexed user, uint256 amount);
    event StakingDeleted(address indexed user, uint256 amount);
    event LevelRewardDistributed(
        address indexed user,
        uint256 level,
        uint256 amount
    );

    TokenPriceInterface public tokenPriceContract;

    constructor() {
        usdtToken = IERC20(0xbf035D8f65b804963a8131B4779863e2541Bd91E);
        tokenPriceContract = TokenPriceInterface(
            0x285DA06f3eeBA9eE2708Cac46ecD5Aab0A932D45
        );
        setLevelPercentage(1, 15);
        setLevelPercentage(2, 10);
        setLevelPercentage(3, 5);
        setLevelPercentage(4, 3);
        setLevelPercentage(5, 2);

        for (uint256 i = 6; i <= 15; i++) {
            setLevelPercentage(i, 1);
        }
    }

    modifier userHasStaked() {
        require(stakedAmount[msg.sender] > 0, "No staked amount");
        _;
    }

    function setLevelPercentage(uint256 level, uint256 percentage)
        public
        onlyOwner
    {
        require(level >= 1 && level <= 15, "Level must be between 1 and 15");
        levelPercentages[level] = percentage;
    }

    function getLevelPercentage(uint256 level) internal view returns (uint256) {
        require(level >= 1 && level <= 15, "Level must be between 1 and 15");
        return levelPercentages[level];
    }

    function updateMinimumStakingAmount(uint256 _newMinimumStakingAmount)
        external
        onlyOwner
    {
        MINIMUM_STAKING_AMOUNT = _newMinimumStakingAmount;
    }

    function updateUnstakePeriod(uint256 _newUnstakePeriod) external onlyOwner {
        UNSTAKE_PERIOD = _newUnstakePeriod;
    }

    function getMyReferrals(address user)
        external
        view
        returns (address[] memory)
    {
        return users[user].referrals;
    }

    function getReferrerOf(address user) public view returns (address) {
        return users[user].referrer;
    }

    function getrewardsEarned(address user) public view returns (uint256) {
        return rewardsEarned[user];
    }

    function stake(uint256 amount, address referrer) external {
        require(!isPaused, "Contract is paused");
        require(
            tokenToUsdPrice(amount) >= MINIMUM_STAKING_AMOUNT,
            "Minimum staking amount is $30"
        );
        require(
            usdtToken.allowance(msg.sender, address(this)) >= amount,
            "Allowance not set"
        );
        require(
            usdtToken.transferFrom(msg.sender, address(this), amount),
            "Transfer failed"
        );
        totalRoiRewards[_msgSender()] += checkDailyReward(msg.sender);
        User storage user = users[msg.sender];
        stakedAmount[msg.sender] = stakedAmount[msg.sender].add(amount);
        totalInvested = totalInvested.add(amount);

        if (
            referrer != address(0) &&
            referrer != msg.sender &&
            user.referrer == address(0)
        ) {
            require(
                !isReferral(msg.sender, referrer),
                "Referrer cannot stake in their referral"
            );
            myDirectReferrals[referrer].push(msg.sender);
            user.referrer = referrer;
            users[referrer].referrals.push(msg.sender);
            referrerOf[msg.sender] = referrer;
            totalReferrals[referrer] = totalReferrals[referrer].add(1);
        }

        stakingTimestamp[msg.sender] = block.timestamp;
        checkTime[msg.sender] = block.timestamp;
        emit Staked(msg.sender, amount);

        distributeLevelRewards(msg.sender, amount);
    }

    function isReferral(address referrer, address potentialReferral)
        internal
        view
        returns (bool)
    {
        address[] storage referrals = users[referrer].referrals;
        for (uint256 i = 0; i < referrals.length; i++) {
            if (referrals[i] == potentialReferral) {
                return true;
            }
        }
        return false;
    }

    function withdrawRewardsEarned(address user) external userHasStaked {
        require(msg.sender == user, "wrong calller address");
        uint256 earnedRewards = rewardsEarned[user] + totalRoiRewards[user];
        require(earnedRewards > 0, "No earned rewards to withdraw");
        bool success = usdtToken.transfer(user, earnedRewards);
        require(success, "Failed to withdraw Dxim");
        rewardsWithdrawn[user] += earnedRewards;
        totalRewardsWithdraw[msg.sender] += earnedRewards;
        if (totalRewardsWithdraw[msg.sender] >= 4 * stakedAmount[msg.sender]) {
            stakedAmount[msg.sender] = 0;
        }
        rewardsEarned[user] = 0;
        checkTime[msg.sender] = 0;
    }

    function withdraw() external onlyOwner {
        uint256 amount = usdtToken.balanceOf(address(this));
        require(amount > 0, "This contract balance is ZERO Dxim");
        bool success = usdtToken.transfer(owner(), amount);
        require(success, "Failed to withdraw");
    }

    function unstake(address user) external userHasStaked {
        require(user == msg.sender, "wrong caller address");
        uint256 staked = stakedAmount[user];
        require(
            block.timestamp >= stakingTimestamp[user].add(UNSTAKE_PERIOD),
            "Unstake period not met"
        );

        uint256 rewards = calculateRewards(user);
        rewardsEarned[user] = rewards;

        if (rewards >= 4 * staked) {
            stakedAmount[user] = 0;
            emit StakingDeleted(user, staked);
        } else {
            usdtToken.transfer(user, staked);
            emit Unstaked(user, staked);
        }
        totalUnstaked[user] += staked;
        totalInvested = totalInvested.sub(staked);
        stakedAmount[user] = 0;
        stakingTimestamp[user] = 0;
        checkTime[msg.sender] = 0;

        usdtToken.transfer(user, rewards);
    }

    function totalUnstakedAmount(address user) public {
        uint256 Amount = stakedAmount[user];
        totalUnstaked[user] += Amount;
        stakedAmount[user] = 0;
    }

    function calculateRewards(address user) internal returns (uint256) {
        uint256 stakedAmountUser = stakedAmount[user];
        require(stakedAmountUser > 0, "No staked amount");

        uint256 stakingTimeInDays = (block.timestamp - checkTime[user]) /
            1 days;
        uint256 dailyROI = (stakedAmountUser * 4) / 1000;
        uint256 roiRewards = dailyROI * stakingTimeInDays;

        if (roiRewards + rewardsEarned[user] > (4 * stakedAmountUser)) {
            roiRewards = (4 * stakedAmountUser) - rewardsEarned[user];
        }

        rewardsEarned[user] = rewardsEarned[user].add(roiRewards);
        totalRoiRewards[user] = totalRoiRewards[user].add(roiRewards);

        distributeLevelRewards(user, roiRewards);

        return roiRewards;
    }

    function checkDailyReward(address user) public view returns (uint256) {
        uint256 stakingTimeInDays = (block.timestamp - checkTime[user]);

        uint256 dailyReward = (stakedAmount[user] * 4 * stakingTimeInDays) /
            1000 /
            1 days;
        return dailyReward;
    }

    function distributeLevelRewards(address user, uint256 amount) public {
        address referrer = referrerOf[user];

        for (uint256 level = 1; level <= 15; level++) {
            if (referrer == address(0)) {
                break;
            }
            uint256 levelReward = (amount * getLevelPercentage(level)) / 100;
            rewardsEarned[referrer] += levelReward;
            referrer = referrerOf[referrer];
        }
    }

    function claimRewardsIncom() external {
        address user = msg.sender;
        uint256 amount = totalBusinessUsd(user);
        bool claimStatus;
        require(
            amount >= 1000 ether,
            "Minimum total business requirement not met"
        );
        if (amount >= 1500000 ether && !incomeGroup[user].step1) {
            incomeGroup[user].step1 = true;
            usdtToken.transfer(user, usdToTokens(20000 ether));
            totalRewardsWithdraw[msg.sender] += usdToTokens(20000 ether);
            claimStatus = true;
        }
        if (
            amount >= 700000 ether &&
            amount < 1500000 ether &&
            !incomeGroup[user].step2
        ) {
            incomeGroup[user].step2 = true;
            usdtToken.transfer(user, 10000 ether);
            totalRewardsWithdraw[msg.sender] += usdToTokens(10000 ether);
            claimStatus = true;
        }
        if (
            amount >= 300000 ether &&
            amount < 700000 ether &&
            !incomeGroup[user].step3
        ) {
            incomeGroup[user].step3 = true;
            usdtToken.transfer(user, 5000 ether);
            totalRewardsWithdraw[msg.sender] += usdToTokens(5000 ether);
            claimStatus = true;
        }
        if (
            amount >= 150000 ether &&
            amount < 300000 ether &&
            !incomeGroup[user].step4
        ) {
            incomeGroup[user].step4 = true;
            usdtToken.transfer(user, 2000 ether);
            totalRewardsWithdraw[msg.sender] += usdToTokens(2000 ether);
            claimStatus = true;
        }
        if (
            amount >= 50000 ether &&
            amount < 150000 ether &&
            !incomeGroup[user].step5
        ) {
            incomeGroup[user].step5 = true;
            usdtToken.transfer(user, 1000 ether);
            totalRewardsWithdraw[msg.sender] += usdToTokens(1000 ether);
            claimStatus = true;
        }
        if (
            amount >= 25000 ether &&
            amount < 50000 ether &&
            !incomeGroup[user].step6
        ) {
            incomeGroup[user].step6 = true;
            usdtToken.transfer(user, 500 ether);
            totalRewardsWithdraw[msg.sender] += usdToTokens(500 ether);
            claimStatus = true;
        }
        if (
            amount >= 5000 ether &&
            amount < 25000 ether &&
            !incomeGroup[user].step7
        ) {
            incomeGroup[user].step7 = true;
            usdtToken.transfer(user, 200 ether);
            totalRewardsWithdraw[msg.sender] += usdToTokens(200 ether);
            claimStatus = true;
        }
        if (
            amount >= 1000 ether &&
            amount < 5000 ether &&
            !incomeGroup[user].step8
        ) {
            incomeGroup[user].step8 = true;
            usdtToken.transfer(user, 50 ether);
            totalRewardsWithdraw[msg.sender] += usdToTokens(50 ether);
            claimStatus = true;
        }
        if (totalRewardsWithdraw[msg.sender] >= 4 * stakedAmount[msg.sender]) {
            stakedAmount[msg.sender] = 0;
        }
        require(claimStatus, "Minimum total business requirement not met");
    }

    function pauseContract() external onlyOwner {
        isPaused = true;
    }

    /**
     * @dev Returns the current price of the token in USD.
     * The price is retrieved from the `tokenPriceContract` instance of `TokenPriceInterface`.
     * @return The current price of the token in USD.
     */
    function getTokenPrice() public view returns (uint256) {
        // 2 decimals
        return tokenPriceContract.getTokenPrice();
    }

    /**
     * @dev Calculates the equivalent USD price for a given token amount.
     * The price is calculated by dividing the token amount by the current token price.
     * @param amount The amount of tokens to be converted to USD.
     * @return The equivalent USD price for the given token amount.
     */
    function tokenToUsdPrice(uint256 amount) public view returns (uint256) {
        uint256 tokens = (amount * 100) / getTokenPrice();
        return tokens;
    }

    /**
     * @dev Calculates the equivalent token amount for a given USD price.
     * The amount of tokens is calculated by multiplying the USD amount by the current token price.
     * @param amount The amount of USD to be converted to tokens.
     * @return The equivalent token amount for the given USD price.
     */
    function usdToTokens(uint256 amount) public view returns (uint256) {
        uint256 tokens = (amount * getTokenPrice()) / 100;
        return tokens;
    }

    /**
     * @dev Calculates the total business volume in USD for a given user.
     * The total business volume is the sum of the staked amounts of the user's entire team, including direct and indirect referrals.
     * @param _user The address of the user.
     * @return The total business volume in USD.
     */
    function totalBusinessUsd(address _user) public view returns (uint256) {
        uint256 amount;
        uint256 team = myDirectReferrals[_user].length;
        for (uint256 i; i < team; i++) {
            address referralAddress = myDirectReferrals[_user][i];
            amount += getTeamAmount(referralAddress);
        }
        return tokenToUsdPrice(amount);
    }

    /**
     * @dev Returns the total staked amount of the user's team
     * @param _user The address of the user
     * @return The total staked amount of the user's team
     */

    function getTeamAmount(address _user) private view returns (uint256) {
        uint256 amount;
        for (uint256 i; i < 15; i++) {
            if (_user != address(0)) {
                amount += stakedAmount[_user];
                _user = getReferrerOf(_user);
            } else break;
        }
        return amount;
    }

    /**
     * @dev Returns the current token balance of the contract
     * @return The token balance of the contract
     */
    function getContractTokenBalance() public view returns (uint256) {
        return usdtToken.balanceOf(address(this));
    }

    function unpauseContract() external onlyOwner {
        isPaused = false;
    }
}
