// SPDX-License-Identifier: MIT

pragma solidity =0.8.6;

import '@openzeppelin/contracts/access/Ownable.sol';
import '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import '@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol';
import '@openzeppelin/contracts/utils/math/SafeMath.sol';
import '../Staking/IStakingDelegate.sol';
import '../Staking/IStakingFeeDecider.sol';

/**
 * @title Token Staking
 * @dev BEP20 compatible token.
 */
contract StaticStakingV1 is Ownable {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    struct UserInfo {
        uint256 amount;
        uint256 rewardDebt;
        uint256 pendingRewards;
        uint256 lockedAmount;
        uint256 unbondAmount;
        uint256 lockedTimestamp;
        uint256 unbondTimestamp;
        bool isLocked;
    }

    struct PoolInfo {
        uint256 lastBlock;
        uint256 tokenPerShare;
        uint256 tokenRealStaked;
        uint256 tokenReceived;
        uint256 tokenRewarded;
        uint256 tokenTotalLimit;
        uint256 tokenTotalBonus; // in percent
        uint256 lockupTimerange;
        uint256 unbondTimerange;
    }

    IERC20 public baseToken;
    IERC20 public extrToken;
    IStakingDelegate public delegate;
    IStakingFeeDecider public unlockFeeDecider;
    IStakingFeeDecider public unbondFeeDecider;

    uint256 public startBlock;
    uint256 public closeBlock;
    uint256 public sumOfBlock;
    uint256 public claimingStartBlock;
    uint256 public depositsCloseBlock;

    uint256 public feeRewarded;
    uint256 public feeReceived;

    PoolInfo[] public poolInfo;
    mapping(uint256 => mapping(address => UserInfo)) public userInfo;
    uint256 public maxPid;

    event Deposited(address indexed user, uint256 pid, address indexed token, uint256 amount);
    event Withdrawn(address indexed user, uint256 pid, address indexed token, uint256 amount);
    event WithdrawnReward(address indexed user, uint256 pid, address indexed token, uint256 amount);
    event WithdrawnRemain(address indexed user, uint256 pid, address indexed token, uint256 amount);
    event WithdrawnFeeval(address indexed user, uint256 pid, address indexed token, uint256 amount);
    event LockChanged(address indexed user, uint256 pid, uint256 unlock, uint256 unbond);
    event FeeDeducted(address indexed user, uint256 pid, address indexed token, uint256 amount);
    event RewardChanged(address indexed token, uint256 reward);
    event UnlockFeeDeciderChanged(address indexed addr);
    event UnbondFeeDeciderChanged(address indexed addr);
    event StartBlockChanged(uint256 block);
    event CloseBlockChanged(uint256 block);
    event SumOfBlockChanged(uint256 block);
    event ClaimingStartBlockChanged(uint256 block);
    event DepositsCloseBlockChanged(uint256 block);

    constructor(uint256 lockupTimer, uint256 unbondTimer, uint256 poolBonus, uint256 poolLimit) {
        addPool(lockupTimer, unbondTimer, poolBonus, poolLimit);
        setSumOfBlock(10512000);
    }

    function setTokenAddress(IERC20 _baseToken, IERC20 _extrToken) public onlyOwner {
        require(address(_baseToken) != address(0), 'Staking: token address needs to be different than zero!');
        require(address(_extrToken) != address(0), 'Staking: token address needs to be different than zero!');
        require(address(baseToken) == address(0) && address(extrToken) == address(0), 'Staking: tokens already set!');
        baseToken = _baseToken;
        extrToken = _extrToken;
    }

    function setRewardBonus(uint256 _bonus) public onlyOwner {
        require(address(extrToken) != address(0), 'Staking: cannot set reward bonus before setting reward token!');
        for (uint256 i=0; i<maxPid; i++) updatePool(i);
        for (uint256 i=0; i<maxPid; i++) poolInfo[i].tokenTotalBonus = _bonus;
        emit RewardChanged(address(extrToken), _bonus);
    }

    function setSumOfBlock(uint256 _sumOfBlock) public onlyOwner {
        require(_sumOfBlock > 0, 'Staking: sum of block needs to be higher than zero!');
        for (uint256 i=0; i<maxPid; i++) updatePool(i);
        sumOfBlock = _sumOfBlock;
        emit StartBlockChanged(sumOfBlock);
    }

    function setUnlockFeeDecider(IStakingFeeDecider addr) public onlyOwner {
        require(address(addr) != address(0), 'Staking: unlock fee decider address needs to be different than zero!');
        unlockFeeDecider = addr;
        emit UnlockFeeDeciderChanged(address(addr));
    }

    function setUnbondFeeDecider(IStakingFeeDecider addr) public onlyOwner {
        require(address(addr) != address(0), 'Staking: unbond fee decider address needs to be different than zero!');
        unbondFeeDecider = addr;
        emit UnbondFeeDeciderChanged(address(addr));
    }

    function setStartBlock(uint256 _startBlock) public onlyOwner {
        require(startBlock == 0, 'Staking: start block already set');
        require(_startBlock > 0, 'Staking: start block needs to be higher than zero!');
        startBlock = _startBlock;
        emit StartBlockChanged(startBlock);
    }

    function setCloseBlock(uint256 _closeBlock) public onlyOwner {
        require(startBlock != 0, 'Staking: start block needs to be set first');
        require(closeBlock == 0, 'Staking: close block already set');
        require(_closeBlock > startBlock, 'Staking: close block needs to be higher than start one!');
        closeBlock = _closeBlock;
        emit CloseBlockChanged(closeBlock);
    }

    function setClaimingStartBlock(uint256 _claimingStartBlock) public onlyOwner {
        require(startBlock != 0, 'Staking: start block needs to be set first');
        claimingStartBlock = _claimingStartBlock;
        emit ClaimingStartBlockChanged(claimingStartBlock);
    }

    function setDepositsCloseBlock(uint256 _depositsCloseBlock) public onlyOwner {
        require(startBlock != 0, 'Staking: start block needs to be set first');
        depositsCloseBlock = _depositsCloseBlock;
        emit DepositsCloseBlockChanged(depositsCloseBlock);
    }

    function isStarted() public view returns (bool) {
        return startBlock != 0 && block.number >= startBlock;
    }

    function isStopped() public view returns (bool) {
        return closeBlock != 0 && block.number >= closeBlock;
    }

    function withdrawFee(address addr) public onlyOwner {
        require(startBlock != 0, 'Staking: start block needs to be set first');
        for (uint256 i=0; i<maxPid; i++) {
            updatePool(i);
        }

        uint256 unlockedFeeReward = feeRewarded.sub(feeReceived);
        uint256 possibleFeeAmount = baseToken.balanceOf(address(this));

        if (unlockedFeeReward > possibleFeeAmount) {
            unlockedFeeReward = possibleFeeAmount;
        }
        if (unlockedFeeReward > 0) {
            feeReceived = feeReceived.add(unlockedFeeReward);
            baseToken.safeTransfer(addr, unlockedFeeReward);
            emit WithdrawnFeeval(addr, 0, address(baseToken), unlockedFeeReward);
        }
    }

    function withdrawRemaining(address addr) public onlyOwner {
        require(startBlock != 0, 'Staking: start block needs to be set first');
        for (uint256 i=0; i<maxPid; i++) {
            updatePool(i);
        }

        uint256 allTokenRewarded = 0;
        uint256 allTokenReceived = 0;

        for (uint256 i=0; i<maxPid; i++) {
            allTokenRewarded = allTokenRewarded.add(poolInfo[i].tokenRewarded);
            allTokenReceived = allTokenReceived.add(poolInfo[i].tokenReceived);
        }

        uint256 unlockedAmount = 0;
        uint256 possibleAmount = extrToken.balanceOf(address(this));
        uint256 reservedAmount = allTokenRewarded.sub(allTokenReceived);

        if (address(baseToken) == address(extrToken)) {
            for (uint i=0; i<maxPid; i++) {
                reservedAmount = reservedAmount.add(poolInfo[i].tokenRealStaked);
            }
            reservedAmount = reservedAmount.add(feeRewarded).sub(feeReceived);
        }

        if (possibleAmount > reservedAmount) {
            unlockedAmount = possibleAmount.sub(reservedAmount);
        }
        if (unlockedAmount > 0) {
            extrToken.safeTransfer(addr, unlockedAmount);
            emit WithdrawnRemain(addr, 0, address(extrToken), unlockedAmount);
        }
    }

    function pendingRewards(uint256 pid, address addr) external view returns (uint256) {
        require(pid < maxPid, 'Staking: invalid pool ID provided');
        require(startBlock > 0 && block.number >= startBlock, 'Staking: not started yet');
        PoolInfo storage pool = poolInfo[pid];
        UserInfo storage user = userInfo[pid][addr];
        uint256 tokenPerShare = pool.tokenPerShare;
        uint256 lastMintedBlock = pool.lastBlock;
        if (lastMintedBlock == 0) {
            lastMintedBlock = startBlock;
        }
        uint256 lastBlock = getLastBlock();
        if (lastBlock == 0) {
            return 0;
        }
        if (lastBlock > lastMintedBlock && pool.tokenRealStaked != 0) {
            uint256 multiplier = lastBlock.sub(lastMintedBlock);
            uint256 tokenAward = multiplier
                .mul(pool.tokenRealStaked).div(sumOfBlock)
                .mul(pool.tokenTotalBonus).div(100);
            tokenPerShare = tokenPerShare.add(tokenAward.mul(1e12).div(pool.tokenRealStaked));
        }
        return user.amount.mul(tokenPerShare).div(1e12).sub(user.rewardDebt).add(user.pendingRewards);
    }

    function deposit(uint256 pid, uint256 amount) external {
        // amount eq to zero is allowed
        require(pid < maxPid, 'Staking: invalid pool ID provided');
        require(startBlock > 0 && block.number >= startBlock, 'Staking: not started yet');
        require(closeBlock == 0 || block.number <= closeBlock, 'Staking: staking has ended, please withdraw remaining tokens');
        require(depositsCloseBlock == 0 || block.number <= depositsCloseBlock, 'Staking: staking new deposits have been disabled');

        PoolInfo storage pool = poolInfo[pid];
        UserInfo storage user = userInfo[pid][msg.sender];

        require(pool.tokenTotalLimit == 0 || pool.tokenTotalLimit >= pool.tokenRealStaked.add(amount),
            'Staking: you cannot deposit over the limit!');

        instantReseal(pid);

        updatePool(pid);
        updatePendingRewards(pid, msg.sender);

        if (amount > 0) {
            user.amount = user.amount.add(amount);
            pool.tokenRealStaked = pool.tokenRealStaked.add(amount);
            baseToken.safeTransferFrom(address(msg.sender), address(this), amount);
            emit Deposited(msg.sender, pid, address(baseToken), amount);
        }
        user.rewardDebt = user.amount.mul(pool.tokenPerShare).div(1e12);

        if (address(delegate) != address(0)) {
            delegate.balanceChanged(msg.sender, pid, address(baseToken), user.amount);
        }
    }

    function freeUnlock(uint256 pid) external {
        UserInfo storage user = userInfo[pid][msg.sender];
        bool worked;
        if (user.lockedTimestamp > 0 && user.lockedTimestamp <= block.timestamp) {
            instantUnlock(pid);
            worked = true;
        }
        if (user.unbondTimestamp > 0 && user.unbondTimestamp <= block.timestamp) {
            instantUnbond(pid);
            worked = true;
        }
        require(worked, 'Staking: cannot unlock/unbond before timelock finishes!');
        if (address(delegate) != address(0)) {
            delegate.balanceChanged(msg.sender, pid, address(baseToken), user.amount);
        }
    }

    function paidUnlock(uint256 pid) external {
        UserInfo storage user = userInfo[pid][msg.sender];
        instantUnseal(pid);
        if (address(delegate) != address(0)) {
            delegate.balanceChanged(msg.sender, pid, address(baseToken), user.amount);
        }
    }

    function withdraw(uint256 pid, uint256 amount) external {
        // amount eq to zero is allowed
        require(pid < maxPid, 'Staking: invalid pool ID provided');
        require(startBlock > 0 && block.number >= startBlock, 'Staking: not started yet');

        PoolInfo storage pool = poolInfo[pid];
        UserInfo storage user = userInfo[pid][msg.sender];

        require((!user.isLocked && block.timestamp >= user.lockedTimestamp) || isStopped(),
            'Staking: you cannot withdraw before unlock!');
        require((!user.isLocked && block.timestamp >= user.unbondTimestamp) || isStopped(),
            'Staking: you cannot withdraw before unbond!');
        require(user.amount >= amount, 'Staking: you cannot withdraw more than you have!');

        uint256 feeCost;
        feeCost = feeRewarded;
        instantUnseal(pid);
        feeCost = feeRewarded - feeCost;
        amount = amount - feeCost; // deduct fees

        updatePool(pid);
        updatePendingRewards(pid, msg.sender);

        if (amount > 0) {
            user.amount = user.amount.sub(amount);
            pool.tokenRealStaked = pool.tokenRealStaked.sub(amount);
            baseToken.safeTransfer(address(msg.sender), amount);
            emit Withdrawn(msg.sender, pid, address(baseToken), amount);
        }
        user.rewardDebt = user.amount.mul(pool.tokenPerShare).div(1e12);

        if (address(delegate) != address(0)) {
            delegate.balanceChanged(msg.sender, pid, address(baseToken), user.amount);
        }
    }

    function claim(uint256 pid) external {
        require(pid < maxPid, 'Staking: invalid pool ID provided');
        require(startBlock > 0 && block.number >= startBlock, 'Staking: not started yet');
        require(claimingStartBlock == 0 || block.number >= claimingStartBlock, 'Staking: claiming rewards is not active');

        PoolInfo storage pool = poolInfo[pid];
        UserInfo storage user = userInfo[pid][msg.sender];

        updatePool(pid);
        updatePendingRewards(pid, msg.sender);

        if (user.pendingRewards > 0) {
            uint256 claimedAmount = transferPendingRewards(pid, msg.sender, user.pendingRewards);
            emit WithdrawnReward(msg.sender, pid, address(baseToken), claimedAmount);
            user.pendingRewards = user.pendingRewards.sub(claimedAmount);
            pool.tokenReceived = pool.tokenReceived.add(claimedAmount);
        }
        user.rewardDebt = user.amount.mul(pool.tokenPerShare).div(1e12);
    }

    function instantReseal(uint256 pid) internal returns (bool) {
        unsafeRelock(pid);
        return true;
    }

    function instantUnlock(uint256 pid) internal returns (bool) {
        PoolInfo storage pool = poolInfo[pid];
        UserInfo storage user = userInfo[pid][msg.sender];
        if (user.lockedTimestamp > 0) {
            bool isEarlyUnlock = user.lockedTimestamp > block.timestamp;
            uint256 cachedLockedTimestamp = user.lockedTimestamp;
            unsafeUnlock(pid);
            user.lockedTimestamp = cachedLockedTimestamp;

            updatePool(pid);
            updatePendingRewards(pid, msg.sender);

            if (!isStopped() && isEarlyUnlock && address(unlockFeeDecider) != address(0)) {
                uint256 fee = unlockFeeDecider.calculateFee(msg.sender, pid, user.amount); // X% fee
                feeRewarded = feeRewarded.add(fee);
                user.amount = user.amount.sub(fee);
                pool.tokenRealStaked = pool.tokenRealStaked.sub(fee);
                emit FeeDeducted(msg.sender, pid, address(baseToken), fee);
            }

            user.rewardDebt = user.amount.mul(pool.tokenPerShare).div(1e12);
            user.lockedTimestamp = 0;
            return true;
        }
        return false;
    }

    function instantUnbond(uint256 pid) internal returns (bool) {
        PoolInfo storage pool = poolInfo[pid];
        UserInfo storage user = userInfo[pid][msg.sender];
        if (user.unbondTimestamp > 0) {
            bool isEarlyUnbond = user.unbondTimestamp > block.timestamp;
            uint256 cachedLockedTimestamp = user.lockedTimestamp;
            unsafeUnbond(pid);
            user.lockedTimestamp = cachedLockedTimestamp;

            updatePool(pid);
            updatePendingRewards(pid, msg.sender);

            if (!isStopped() && isEarlyUnbond && address(unbondFeeDecider) != address(0)) {
                uint256 fee = unbondFeeDecider.calculateFee(msg.sender, pid, user.amount);
                feeRewarded = feeRewarded.add(fee);
                user.amount = user.amount.sub(fee);
                pool.tokenRealStaked = pool.tokenRealStaked.sub(fee);
                emit FeeDeducted(msg.sender, pid, address(baseToken), fee);
            }

            user.rewardDebt = user.amount.mul(pool.tokenPerShare).div(1e12);
            user.lockedTimestamp = 0;
            return true;
        }
        return false;
    }

    function instantUnseal(uint256 pid) internal returns (bool) {
        bool unlockNeeded = instantUnlock(pid);
        bool unbondNeeded = instantUnbond(pid);
        return unlockNeeded || unbondNeeded;
    }

    function unsafeRelock(uint256 pid) internal {
        PoolInfo storage pool = poolInfo[pid];
        UserInfo storage user = userInfo[pid][msg.sender];

        updatePool(pid);
        updatePendingRewards(pid, msg.sender);

        user.lockedTimestamp = block.timestamp.add(pool.lockupTimerange);
        user.unbondTimestamp = 0;
        user.isLocked = true;

        pool.tokenRealStaked = pool.tokenRealStaked.add(user.unbondAmount);
        user.unbondAmount = 0;
        user.lockedAmount = user.amount;

        user.rewardDebt = user.amount.mul(pool.tokenPerShare).div(1e12);
        emit LockChanged(msg.sender, pid, user.lockedTimestamp, 0);
    }

    function unsafeUnlock(uint256 pid) internal {
        PoolInfo storage pool = poolInfo[pid];
        UserInfo storage user = userInfo[pid][msg.sender];

        updatePool(pid);
        updatePendingRewards(pid, msg.sender);

        user.lockedTimestamp = 0;
        user.unbondTimestamp = block.timestamp.add(pool.unbondTimerange);
        user.isLocked = false;

        pool.tokenRealStaked = pool.tokenRealStaked.sub(user.lockedAmount);
        user.unbondAmount = user.amount;
        user.lockedAmount = 0;

        user.rewardDebt = user.amount.mul(pool.tokenPerShare).div(1e12);
        emit LockChanged(msg.sender, pid, 0, user.unbondTimestamp);
    }

    function unsafeUnbond(uint256 pid) internal {
        UserInfo storage user = userInfo[pid][msg.sender];

        user.lockedTimestamp = 0;
        user.unbondTimestamp = 0;

        emit LockChanged(msg.sender, pid, 0, 0);
    }

    function addPool(uint256 _lockupTimerange, uint256 _unbondTimerange, uint256 _tokenTotalBonus,
        uint256 _tokenTotalLimit) internal {
        require(maxPid < 10, 'Staking: Cannot add more than 10 pools!');

        poolInfo.push(PoolInfo({
            lastBlock: 0,
            tokenPerShare: 0,
            tokenRealStaked: 0,
            tokenReceived: 0,
            tokenRewarded: 0,
            tokenTotalLimit: _tokenTotalLimit,
            tokenTotalBonus: _tokenTotalBonus,
            lockupTimerange: _lockupTimerange,
            unbondTimerange: _unbondTimerange
        }));
        maxPid = maxPid.add(1);
    }

    function updatePool(uint256 pid) internal {
        if (pid >= maxPid) {
            return;
        }
        if (startBlock == 0 || block.number < startBlock) {
            return;
        }
        PoolInfo storage pool = poolInfo[pid];
        if (pool.lastBlock == 0) {
            pool.lastBlock = startBlock;
        }
        uint256 lastBlock = getLastBlock();
        if (lastBlock <= pool.lastBlock) {
            return;
        }
        uint256 poolTokenRealStaked = pool.tokenRealStaked;
        if (poolTokenRealStaked == 0) {
            return;
        }
        uint256 multiplier = lastBlock.sub(pool.lastBlock);
        uint256 tokenAward = multiplier
            .mul(poolTokenRealStaked).div(sumOfBlock)
            .mul(pool.tokenTotalBonus).div(100);
        pool.tokenRewarded = pool.tokenRewarded.add(tokenAward);
        pool.tokenPerShare = pool.tokenPerShare.add(tokenAward.mul(1e12).div(poolTokenRealStaked));
        pool.lastBlock = lastBlock;
    }

    function updatePendingRewards(uint256 pid, address addr) internal {
        if (pid >= maxPid) {
            return;
        }
        PoolInfo storage pool = poolInfo[pid];
        UserInfo storage user = userInfo[pid][addr];
        uint256 pending = user.amount.mul(pool.tokenPerShare).div(1e12).sub(user.rewardDebt);
        if (pending > 0) {
            user.pendingRewards = user.pendingRewards.add(pending);
        }
    }

    function transferPendingRewards(uint256 pid, address to, uint256 amount) internal returns (uint256) {
        if (pid >= maxPid) {
            return 0;
        }
        if (amount == 0) {
            return 0;
        }
        uint256 tokenAmount = extrToken.balanceOf(address(this));
        if (tokenAmount == 0) {
            return 0;
        }
        if (tokenAmount > amount) {
            tokenAmount = amount;
        }
        extrToken.safeTransfer(to, tokenAmount);
        return tokenAmount;
    }

    function getLastBlock() internal view returns (uint256) {
        if (startBlock == 0) return 0;
        if (closeBlock == 0) return block.number;
        return (closeBlock < block.number) ? closeBlock : block.number;
    }
}// SPDX-License-Identifier: MIT

pragma solidity =0.8.6;

interface IStakingFeeDecider {
    function calculateFee(address addr, uint256 pid, uint256 amount) external view returns (uint256);
}
// SPDX-License-Identifier: MIT

pragma solidity =0.8.6;

interface IStakingDelegate {

    function balanceChanged(address user, uint256 pid, address token, uint256 amount) external;
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is no longer needed starting with Solidity 0.8. The compiler
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
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
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
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/*
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

pragma solidity ^0.8.0;

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) private pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../IERC20.sol";
import "../../../utils/Address.sol";

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

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
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

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
}
// SPDX-License-Identifier: MIT

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
        _setOwner(_msgSender());
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _setOwner(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}
