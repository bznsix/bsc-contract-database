// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.18;

import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IBurnableERC20} from "../../interfaces/IBurnableERC20.sol";
import "./../LevelOmniStaking.sol";

/**
 * @title MigrateableLgoOmniStaking
 * @notice Staking contract which accept migrate LGO from legacy contract
 */
contract MigrateableLgoOmniStaking is LevelOmniStaking {
    using SafeERC20 for IBurnableERC20;

    address public stakingV1;

    function setStakingV1(address _stakingV1) external onlyOwner {
        require(stakingV1 == address(0), "Already set");
        stakingV1 = _stakingV1;
        emit StakingV1Set(_stakingV1);
    }

    /**
     * @notice Allow stake without tax, only from legacy staking contract
     */
    function migrateStake(address _to, uint256 _amount) external whenNotPaused nonReentrant {
        require(msg.sender == stakingV1, "!stakingV1");
        require(_to != address(0), "Invalid address");
        require(_amount > 0, "Invalid amount");
        _updateCurrentEpoch();
        _updateUser(_to, _amount, true);
        totalStaked += _amount;
        stakeToken.safeTransferFrom(msg.sender, address(this), _amount);
        emit Staked(msg.sender, _to, currentEpoch, _amount, 0);
    }

    event StakingV1Set(address stakingV1);
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";
import "../extensions/draft-IERC20Permit.sol";
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

    function safePermit(
        IERC20Permit token,
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal {
        uint256 nonceBefore = token.nonces(owner);
        token.permit(owner, spender, value, deadline, v, r, s);
        uint256 nonceAfter = token.nonces(owner);
        require(nonceAfter == nonceBefore + 1, "SafeERC20: permit did not succeed");
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address-functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

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
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}
// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IBurnableERC20 is IERC20 {
    function burn(uint256 amount) external;
    function burnFrom(address account, uint256 amount) external;
}
// SPDX-License-Identifier: MIT

pragma solidity 0.8.18;

import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import {ReentrancyGuardUpgradeable} from "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import {PausableUpgradeable} from "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import {IBurnableERC20} from "../interfaces/IBurnableERC20.sol";
import {StakingReserve} from "./StakingReserve.sol";

/**
 * @title LevelOmniStaking
 * @author Level
 * @notice Stake protocol token to earn protocol revenue, in the form of LLP token. The reward is allocated weekly, which we called an epoch.
 * The protocol fee is collected to this contract in a daily basis.
 * Whenever an epoch ended, admin can move the collected fee between chains based on the staked amount on each chain,
 * then she call the allocate method to start distributing the reward.
 * User can choose to claim their reward as LLP token or swap to one of available tokens.
 */
contract LevelOmniStaking is Initializable, PausableUpgradeable, ReentrancyGuardUpgradeable, StakingReserve {
    using SafeERC20 for IERC20;
    using SafeERC20 for IBurnableERC20;

    struct EpochInfo {
        uint256 startTime;
        uint256 endTime;
        uint256 allocationTime;
        uint256 totalAccShare;
        uint256 lastUpdateAccShareTime;
        uint256 totalReward;
    }

    struct UserInfo {
        /// @notice staked amount of user in epoch
        uint256 amount;
        uint256 claimedReward;
        /// @notice accumulated amount, calculated by total of deposited amount multiplied with deposited time
        uint256 accShare;
        uint256 lastUpdateAccShareTime;
    }

    uint256 public constant STAKING_TAX_PRECISION = 1000;
    uint256 public constant STAKING_TAX = 0; // 0.4%
    uint256 public constant MIN_EPOCH_DURATION = 1 days;

    IBurnableERC20 public stakeToken;

    bool public enableNextEpoch;

    uint256 public currentEpoch;
    /// @notice start time of the current epoch
    uint256 public lastEpochTimestamp;
    uint256 public epochDuration;
    uint256 public totalStaked;

    mapping(uint256 epoch => EpochInfo) public epochs;
    mapping(address userAddress => mapping(uint256 epoch => UserInfo)) public users;
    mapping(address userAddress => uint256) public stakedAmounts;
    /// @notice list of epoch in which user updated their staked amount (stake or unstake)
    mapping(address userAddress => uint256[]) public userSnapshotEpochs;
    /// @notice list of tokens to which user can convert their reward. Note that they MUST pay the swap fee
    mapping(address tokenAddress => bool) public claimableTokens;

    constructor() {
        _disableInitializers();
    }

    function initialize(
        address _pool,
        address _stakeToken,
        address _llp,
        address _weth,
        address _ethUnwrapper,
        uint256 _startEpoch,
        uint256 _startTime
    ) external initializer {
        require(_stakeToken != address(0), "Invalid address");
        require(_startTime >= block.timestamp, "Invalid start time");
        __Pausable_init();
        __ReentrancyGuard_init();
        __StakingReserve_init(_pool, _llp, _weth, _ethUnwrapper);
        stakeToken = IBurnableERC20(_stakeToken);
        epochDuration = 7 days;
        currentEpoch = _startEpoch;
        lastEpochTimestamp = _startTime;
        epochs[_startEpoch].startTime = _startTime;
        epochs[_startEpoch].lastUpdateAccShareTime = _startTime;
        emit EpochStarted(_startEpoch, _startTime);
    }

    // =============== VIEW FUNCTIONS ===============
    function getNextEpochStartTime() public view returns (uint256) {
        return lastEpochTimestamp + epochDuration;
    }

    function pendingRewards(uint256 _epoch, address _user) public view returns (uint256) {
        return _pendingRewards(_epoch, _user);
    }

    /**
     * @dev searches a staked amount by epoch. Uses binary search.
     * @param _epoch the epoch being searched
     * @param _user the user for which the snapshot is being searched
     * @return The staked amount
     */
    function getStakedAmountByEpoch(uint256 _epoch, address _user) public view returns (uint256) {
        uint256[] storage _snapshotEpochs = userSnapshotEpochs[_user];
        uint256 _snapshotsCount = _snapshotEpochs.length;
        if (_snapshotsCount == 0) {
            return 0;
        }
        // First check most recent epoch
        if (_snapshotEpochs[_snapshotsCount - 1] <= _epoch) {
            return stakedAmounts[_user];
        }
        // Next check first epoch
        if (_snapshotEpochs[0] > _epoch) {
            return 0;
        }

        uint256 _lower = 0;
        uint256 _upper = _snapshotsCount - 1;
        while (_upper > _lower) {
            uint256 _center = _upper - (_upper - _lower) / 2; // ceil, avoiding overflow
            uint256 _centerEpoch = _snapshotEpochs[_center];
            if (_centerEpoch == _epoch) {
                return users[_user][_centerEpoch].amount;
            } else if (_centerEpoch < _epoch) {
                _lower = _center;
            } else {
                _upper = _center - 1;
            }
        }
        return users[_user][_snapshotEpochs[_lower]].amount;
    }

    // =============== USER FUNCTIONS ===============

    function stake(address _to, uint256 _amount) external virtual whenNotPaused nonReentrant {
        require(_to != address(0), "Invalid address");
        require(_amount > 0, "Invalid amount");
        uint256 _taxAmount = (_amount * STAKING_TAX) / STAKING_TAX_PRECISION;
        uint256 _stakedAmount = _amount - _taxAmount;
        _updateCurrentEpoch();
        _updateUser(_to, _stakedAmount, true);
        totalStaked += _stakedAmount;
        stakeToken.safeTransferFrom(msg.sender, address(this), _amount);
        if (_taxAmount != 0) {
            stakeToken.burn(_taxAmount);
        }
        emit Staked(msg.sender, _to, currentEpoch, _stakedAmount, _taxAmount);
    }

    function unstake(address _to, uint256 _amount) external virtual nonReentrant {
        require(_to != address(0), "Invalid address");
        require(_amount > 0, "Invalid amount");
        address _sender = msg.sender;
        require(stakedAmounts[_sender] >= _amount, "Insufficient staked amount");
        _updateCurrentEpoch();
        _updateUser(_sender, _amount, false);
        totalStaked -= _amount;
        stakeToken.safeTransfer(_to, _amount);
        emit Unstaked(_sender, _to, currentEpoch, _amount);
    }

    /// @notice claim rewards as LLP token
    function claimRewards(uint256 _epoch, address _to) external whenNotPaused nonReentrant {
        _claimRewards(msg.sender, _epoch, _to);
    }

    /// @notice claim multiple rewards as LLP token
    function claimMultipleRewards(uint256[] calldata _epochs, address _to) external whenNotPaused nonReentrant {
        _claimMultipleRewards(_epochs, _to, address(LLP), 0);
    }

    /// @notice claim then swap LLP token to one of the claimable tokens
    function claimRewardsToSingleToken(uint256 _epoch, address _to, address _tokenOut, uint256 _minAmountOut)
        external
        whenNotPaused
        nonReentrant
    {
        _claimRewardsToSingleToken(msg.sender, _epoch, _to, _tokenOut, _minAmountOut);
    }

    /// @notice claim multiple then swap LLP token to one of the claimable tokens
    function claimMultipleRewardsToSingleToken(
        uint256[] calldata _epochs,
        address _to,
        address _tokenOut,
        uint256 _minAmountOut
    ) external whenNotPaused nonReentrant {
        _claimMultipleRewards(_epochs, _to, _tokenOut, _minAmountOut);
    }

    /// @notice end current epoch and start a new one. Note that the reward is not available at this moment
    function nextEpoch() external {
        require(enableNextEpoch, "!enableNextEpoch");
        uint256 _nextEpochStartTime = getNextEpochStartTime();
        uint256 _currentTime = block.timestamp;
        require(_currentTime >= _nextEpochStartTime, "< next start time");

        _updateCurrentEpoch();
        epochs[currentEpoch].endTime = _currentTime;
        lastEpochTimestamp = _nextEpochStartTime;
        emit EpochEnded(currentEpoch, _nextEpochStartTime);

        currentEpoch++;
        epochs[currentEpoch].startTime = _currentTime;
        epochs[currentEpoch].lastUpdateAccShareTime = _currentTime;
        emit EpochStarted(currentEpoch, _nextEpochStartTime);
    }

    /// @notice convert ALL fee tokens to LLP token then allocate to selected epoch. Epoch MUST be ended but not allocated
    function allocateReward(uint256 _epoch) external virtual onlyDistributorOrOwner {
        EpochInfo memory _epochInfo = epochs[_epoch];
        require(_epochInfo.endTime != 0, "Epoch not ended");
        require(_epochInfo.allocationTime == 0, "Reward allocated");
        uint256 _beforeLLPBalance = LLP.balanceOf(address(this));
        for (uint8 i = 0; i < convertLLPTokens.length;) {
            address _token = convertLLPTokens[i];
            uint256 _amount = IERC20(_token).balanceOf(address(this));
            _convertTokenToLLP(_token, _amount);
            unchecked {
                ++i;
            }
        }
        uint256 _rewardAmount = LLP.balanceOf(address(this)) - _beforeLLPBalance;
        require(_rewardAmount != 0, "Reward = 0");
        _epochInfo.totalReward = _rewardAmount;
        _epochInfo.allocationTime = block.timestamp;
        epochs[_epoch] = _epochInfo;
        emit RewardAllocated(_epoch, _rewardAmount);
    }

    /// @notice convert SELECTED fee tokens to LLP token then allocate to selected epoch. Epoch MUST be ended but not allocated
    function allocateReward(uint256 _epoch, address[] calldata _tokens, uint256[] calldata _amounts)
        external
        virtual
        onlyDistributorOrOwner
    {
        uint256 _tokenLength = _tokens.length;
        require(_amounts.length == _tokenLength, "Length miss match");
        EpochInfo memory _epochInfo = epochs[_epoch];
        require(_epochInfo.endTime != 0, "Epoch not ended");
        require(_epochInfo.allocationTime == 0, "Reward allocated");
        uint256 _beforeLLPBalance = LLP.balanceOf(address(this));
        for (uint8 i = 0; i < _tokenLength;) {
            uint256 _amount = _amounts[i];
            require(_amount != 0, "Invalid amount");
            require(_amount <= IERC20(_tokens[i]).balanceOf(address(this)), "Exceeded balance");
            _convertTokenToLLP(_tokens[i], _amount);
            unchecked {
                ++i;
            }
        }
        uint256 _rewardAmount = LLP.balanceOf(address(this)) - _beforeLLPBalance;
        require(_rewardAmount != 0, "Reward = 0");
        _epochInfo.totalReward = _rewardAmount;
        _epochInfo.allocationTime = block.timestamp;
        epochs[_epoch] = _epochInfo;
        emit RewardAllocated(_epoch, _rewardAmount);
    }

    // =============== RESTRICTED ===============
    function setEnableNextEpoch(bool _enable) external onlyDistributorOrOwner {
        enableNextEpoch = _enable;

        emit EnableNextEpochSet(_enable);
    }

    function setEpochDuration(uint256 _epochDuration) external onlyOwner {
        require(_epochDuration >= MIN_EPOCH_DURATION, "< MIN_EPOCH_DURATION");
        EpochInfo memory _epochInfo = epochs[currentEpoch];
        require(_epochInfo.startTime + _epochDuration >= block.timestamp, "Invalid duration");
        epochDuration = _epochDuration;

        emit EpochDurationSet(_epochDuration);
    }

    function setClaimableToken(address _token, bool _allowed) external onlyOwner {
        require(_token != address(stakeToken) && _token != address(LLP) && _token != address(0), "Invalid address");
        if (claimableTokens[_token] != _allowed) {
            claimableTokens[_token] = _allowed;
            emit ClaimableTokenSet(_token, _allowed);
        }
    }

    function setFeeToken(address _token, bool _allowed) external onlyOwner {
        require(_token != address(LLP) && _token != address(stakeToken) && _token != address(0), "Invalid address");
        _setFeeToken(_token, _allowed);
    }

    function pause() external onlyDistributorOrOwner {
        _pause();
    }

    function unpause() external onlyDistributorOrOwner {
        _unpause();
    }

    // =============== INTERNAL FUNCTIONS ===============
    function _updateCurrentEpoch() internal {
        EpochInfo memory _epochInfo = epochs[currentEpoch];
        uint256 _currentTime = block.timestamp;
        if (_currentTime >= _epochInfo.startTime) {
            uint256 _elapsedTime = _currentTime - _epochInfo.lastUpdateAccShareTime;
            _epochInfo.totalAccShare += _elapsedTime * totalStaked;
            _epochInfo.lastUpdateAccShareTime = _currentTime;
            epochs[currentEpoch] = _epochInfo;
        }
    }

    function _updateUser(address _user, uint256 _amount, bool _isIncrease) internal {
        UserInfo memory _userSnapshot = users[_user][currentEpoch];
        EpochInfo memory _epochInfo = epochs[currentEpoch];
        if (_userSnapshot.lastUpdateAccShareTime == 0) {
            userSnapshotEpochs[_user].push(currentEpoch);
        }
        uint256 _currentTime = block.timestamp;
        uint256 _currentStakedAmounts = stakedAmounts[_user];
        if (_currentTime >= _epochInfo.startTime) {
            uint256 _lastUpdateAccShareTime = _userSnapshot.lastUpdateAccShareTime;
            if (_userSnapshot.lastUpdateAccShareTime < _epochInfo.startTime) {
                _lastUpdateAccShareTime = _epochInfo.startTime;
            }
            uint256 _elapsedTime = _currentTime - _lastUpdateAccShareTime;
            _userSnapshot.accShare += _elapsedTime * _currentStakedAmounts;
            _userSnapshot.lastUpdateAccShareTime = _currentTime;
        }
        stakedAmounts[_user] = _isIncrease ? _currentStakedAmounts + _amount : _currentStakedAmounts - _amount;
        _userSnapshot.amount = stakedAmounts[_user];
        users[_user][currentEpoch] = _userSnapshot;
    }

    function _claimRewards(address _user, uint256 _epoch, address _to) internal {
        require(_user != address(0), "Invalid address");
        require(_to != address(0), "Invalid address");
        uint256 _pendingRewards = _pendingRewards(_epoch, _user);
        if (_pendingRewards != 0) {
            users[_user][_epoch].claimedReward += _pendingRewards;
            _safeTransferToken(address(LLP), _to, _pendingRewards);
            emit Claimed(_user, _to, _epoch, _pendingRewards);
        }
    }

    function _claimRewardsToSingleToken(
        address _user,
        uint256 _epoch,
        address _to,
        address _tokenOut,
        uint256 _minAmountOut
    ) internal {
        require(_user != address(0), "Invalid address");
        require(_to != address(0), "Invalid address");
        require(claimableTokens[_tokenOut], "!claimableTokens");
        uint256 _pendingRewards = _pendingRewards(_epoch, _user);
        if (_pendingRewards != 0) {
            users[_user][_epoch].claimedReward += _pendingRewards;
            uint256 _amountOut = _convertLLPToToken(_to, _pendingRewards, _tokenOut, _minAmountOut);
            emit SingleTokenClaimed(_user, _to, _epoch, _pendingRewards, _tokenOut, _amountOut);
        }
    }

    function _claimMultipleRewards(uint256[] calldata _epochs, address _to, address _tokenOut, uint256 _minAmountOut)
        internal
    {
        require(_to != address(0), "Invalid address");
        address _sender = msg.sender;
        uint256 _length = _epochs.length;
        uint256 _totalPendingRewards;
        for (uint256 i = 0; i < _length;) {
            uint256 _epoch = _epochs[i];
            uint256 _pendingRewards = _pendingRewards(_epoch, _sender);
            if (_pendingRewards != 0) {
                _totalPendingRewards += _pendingRewards;
                users[_sender][_epoch].claimedReward += _pendingRewards;
                emit Claimed(_sender, _to, _epoch, _pendingRewards);
            }

            unchecked {
                ++i;
            }
        }
        if (_totalPendingRewards != 0) {
            if (_tokenOut == address(LLP)) {
                _safeTransferToken(address(LLP), _to, _totalPendingRewards);
            } else {
                require(claimableTokens[_tokenOut], "!claimableTokens");
                _convertLLPToToken(_to, _totalPendingRewards, _tokenOut, _minAmountOut);
            }
        }
    }

    function _pendingRewards(uint256 _epoch, address _user) internal view returns (uint256 _pendingRewards) {
        EpochInfo memory _epochInfo = epochs[_epoch];
        if (_epochInfo.endTime != 0 && _epochInfo.totalReward != 0) {
            UserInfo memory _userInfo = users[_user][_epoch];
            uint256 _stakedAmount = getStakedAmountByEpoch(_epoch, _user);
            uint256 _lastUpdateAccShareTime = _userInfo.lastUpdateAccShareTime;
            if (_lastUpdateAccShareTime == 0) {
                _lastUpdateAccShareTime = _epochInfo.startTime;
            }
            uint256 _userShare = _userInfo.accShare + ((_epochInfo.endTime - _lastUpdateAccShareTime) * _stakedAmount);
            if (_epochInfo.totalAccShare != 0) {
                _pendingRewards =
                    ((_userShare * _epochInfo.totalReward) / _epochInfo.totalAccShare) - _userInfo.claimedReward;
            }
        }
    }

    // =============== EVENTS ===============
    event EnableNextEpochSet(bool _enable);
    event EpochDurationSet(uint256 _epochDuration);
    event ClaimableTokenSet(address indexed _token, bool _allowed);
    event EpochStarted(uint256 indexed _epoch, uint256 _startTime);
    event EpochEnded(uint256 indexed _epoch, uint256 _endTime);
    event RewardAllocated(uint256 indexed _epoch, uint256 _amount);
    event Staked(address indexed _from, address indexed _to, uint256 _epoch, uint256 _stakedAmount, uint256 _taxAmount);
    event Unstaked(address indexed _from, address indexed _to, uint256 _epoch, uint256 _amount);
    event Claimed(address indexed _from, address indexed _to, uint256 _epoch, uint256 _amount);
    event SingleTokenClaimed(
        address indexed _from,
        address indexed _to,
        uint256 _epoch,
        uint256 _amount,
        address _tokenOut,
        uint256 _amountOut
    );
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/draft-IERC20Permit.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 Permit extension allowing approvals to be made via signatures, as defined in
 * https://eips.ethereum.org/EIPS/eip-2612[EIP-2612].
 *
 * Adds the {permit} method, which can be used to change an account's ERC20 allowance (see {IERC20-allowance}) by
 * presenting a message signed by the account. By not relying on {IERC20-approve}, the token holder account doesn't
 * need to send a transaction, and thus is not required to hold Ether at all.
 */
interface IERC20Permit {
    /**
     * @dev Sets `value` as the allowance of `spender` over ``owner``'s tokens,
     * given ``owner``'s signed approval.
     *
     * IMPORTANT: The same issues {IERC20-approve} has related to transaction
     * ordering also apply here.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `deadline` must be a timestamp in the future.
     * - `v`, `r` and `s` must be a valid `secp256k1` signature from `owner`
     * over the EIP712-formatted function arguments.
     * - the signature must use ``owner``'s current nonce (see {nonces}).
     *
     * For more information on the signature format, see the
     * https://eips.ethereum.org/EIPS/eip-2612#specification[relevant EIP
     * section].
     */
    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    /**
     * @dev Returns the current nonce for `owner`. This value must be
     * included whenever a signature is generated for {permit}.
     *
     * Every successful call to {permit} increases ``owner``'s nonce by one. This
     * prevents a signature from being used multiple times.
     */
    function nonces(address owner) external view returns (uint256);

    /**
     * @dev Returns the domain separator used in the encoding of the signature for {permit}, as defined by {EIP712}.
     */
    // solhint-disable-next-line func-name-mixedcase
    function DOMAIN_SEPARATOR() external view returns (bytes32);
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (utils/Address.sol)

pragma solidity ^0.8.1;

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
     *
     * [IMPORTANT]
     * ====
     * You shouldn't rely on `isContract` to protect against flash loan attacks!
     *
     * Preventing calls from contracts is highly discouraged. It breaks composability, breaks support for smart wallets
     * like Gnosis Safe, and does not provide security since it can be circumvented by calling from a contract
     * constructor.
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.

        return account.code.length > 0;
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
        return functionCallWithValue(target, data, 0, "Address: low-level call failed");
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
        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
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
        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
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
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verify that a low level call to smart-contract was successful, and revert (either by bubbling
     * the revert reason or using the provided one) in case of unsuccessful call or if target was not a contract.
     *
     * _Available since v4.8._
     */
    function verifyCallResultFromTarget(
        address target,
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        if (success) {
            if (returndata.length == 0) {
                // only check isContract if the call was successful and the return data is empty
                // otherwise we already know that it was a contract
                require(isContract(target), "Address: call to non-contract");
            }
            return returndata;
        } else {
            _revert(returndata, errorMessage);
        }
    }

    /**
     * @dev Tool to verify that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason or using the provided one.
     *
     * _Available since v4.3._
     */
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            _revert(returndata, errorMessage);
        }
    }

    function _revert(bytes memory returndata, string memory errorMessage) private pure {
        // Look for revert reason and bubble it up if present
        if (returndata.length > 0) {
            // The easiest way to bubble the revert reason is using memory via assembly
            /// @solidity memory-safe-assembly
            assembly {
                let returndata_size := mload(returndata)
                revert(add(32, returndata), returndata_size)
            }
        } else {
            revert(errorMessage);
        }
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.1) (proxy/utils/Initializable.sol)

pragma solidity ^0.8.2;

import "../../utils/AddressUpgradeable.sol";

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since proxied contracts do not make use of a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 *
 * The initialization functions use a version number. Once a version number is used, it is consumed and cannot be
 * reused. This mechanism prevents re-execution of each "step" but allows the creation of new initialization steps in
 * case an upgrade adds a module that needs to be initialized.
 *
 * For example:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * contract MyToken is ERC20Upgradeable {
 *     function initialize() initializer public {
 *         __ERC20_init("MyToken", "MTK");
 *     }
 * }
 * contract MyTokenV2 is MyToken, ERC20PermitUpgradeable {
 *     function initializeV2() reinitializer(2) public {
 *         __ERC20Permit_init("MyToken");
 *     }
 * }
 * ```
 *
 * TIP: To avoid leaving the proxy in an uninitialized state, the initializer function should be called as early as
 * possible by providing the encoded function call as the `_data` argument to {ERC1967Proxy-constructor}.
 *
 * CAUTION: When used with inheritance, manual care must be taken to not invoke a parent initializer twice, or to ensure
 * that all initializers are idempotent. This is not verified automatically as constructors are by Solidity.
 *
 * [CAUTION]
 * ====
 * Avoid leaving a contract uninitialized.
 *
 * An uninitialized contract can be taken over by an attacker. This applies to both a proxy and its implementation
 * contract, which may impact the proxy. To prevent the implementation contract from being used, you should invoke
 * the {_disableInitializers} function in the constructor to automatically lock it when it is deployed:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * /// @custom:oz-upgrades-unsafe-allow constructor
 * constructor() {
 *     _disableInitializers();
 * }
 * ```
 * ====
 */
abstract contract Initializable {
    /**
     * @dev Indicates that the contract has been initialized.
     * @custom:oz-retyped-from bool
     */
    uint8 private _initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private _initializing;

    /**
     * @dev Triggered when the contract has been initialized or reinitialized.
     */
    event Initialized(uint8 version);

    /**
     * @dev A modifier that defines a protected initializer function that can be invoked at most once. In its scope,
     * `onlyInitializing` functions can be used to initialize parent contracts.
     *
     * Similar to `reinitializer(1)`, except that functions marked with `initializer` can be nested in the context of a
     * constructor.
     *
     * Emits an {Initialized} event.
     */
    modifier initializer() {
        bool isTopLevelCall = !_initializing;
        require(
            (isTopLevelCall && _initialized < 1) || (!AddressUpgradeable.isContract(address(this)) && _initialized == 1),
            "Initializable: contract is already initialized"
        );
        _initialized = 1;
        if (isTopLevelCall) {
            _initializing = true;
        }
        _;
        if (isTopLevelCall) {
            _initializing = false;
            emit Initialized(1);
        }
    }

    /**
     * @dev A modifier that defines a protected reinitializer function that can be invoked at most once, and only if the
     * contract hasn't been initialized to a greater version before. In its scope, `onlyInitializing` functions can be
     * used to initialize parent contracts.
     *
     * A reinitializer may be used after the original initialization step. This is essential to configure modules that
     * are added through upgrades and that require initialization.
     *
     * When `version` is 1, this modifier is similar to `initializer`, except that functions marked with `reinitializer`
     * cannot be nested. If one is invoked in the context of another, execution will revert.
     *
     * Note that versions can jump in increments greater than 1; this implies that if multiple reinitializers coexist in
     * a contract, executing them in the right order is up to the developer or operator.
     *
     * WARNING: setting the version to 255 will prevent any future reinitialization.
     *
     * Emits an {Initialized} event.
     */
    modifier reinitializer(uint8 version) {
        require(!_initializing && _initialized < version, "Initializable: contract is already initialized");
        _initialized = version;
        _initializing = true;
        _;
        _initializing = false;
        emit Initialized(version);
    }

    /**
     * @dev Modifier to protect an initialization function so that it can only be invoked by functions with the
     * {initializer} and {reinitializer} modifiers, directly or indirectly.
     */
    modifier onlyInitializing() {
        require(_initializing, "Initializable: contract is not initializing");
        _;
    }

    /**
     * @dev Locks the contract, preventing any future reinitialization. This cannot be part of an initializer call.
     * Calling this in the constructor of a contract will prevent that contract from being initialized or reinitialized
     * to any version. It is recommended to use this to lock implementation contracts that are designed to be called
     * through proxies.
     *
     * Emits an {Initialized} event the first time it is successfully executed.
     */
    function _disableInitializers() internal virtual {
        require(!_initializing, "Initializable: contract is initializing");
        if (_initialized < type(uint8).max) {
            _initialized = type(uint8).max;
            emit Initialized(type(uint8).max);
        }
    }

    /**
     * @dev Returns the highest version that has been initialized. See {reinitializer}.
     */
    function _getInitializedVersion() internal view returns (uint8) {
        return _initialized;
    }

    /**
     * @dev Returns `true` if the contract is currently initializing. See {onlyInitializing}.
     */
    function _isInitializing() internal view returns (bool) {
        return _initializing;
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;
import "../proxy/utils/Initializable.sol";

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
abstract contract ReentrancyGuardUpgradeable is Initializable {
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

    function __ReentrancyGuard_init() internal onlyInitializing {
        __ReentrancyGuard_init_unchained();
    }

    function __ReentrancyGuard_init_unchained() internal onlyInitializing {
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
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (security/Pausable.sol)

pragma solidity ^0.8.0;

import "../utils/ContextUpgradeable.sol";
import "../proxy/utils/Initializable.sol";

/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
abstract contract PausableUpgradeable is Initializable, ContextUpgradeable {
    /**
     * @dev Emitted when the pause is triggered by `account`.
     */
    event Paused(address account);

    /**
     * @dev Emitted when the pause is lifted by `account`.
     */
    event Unpaused(address account);

    bool private _paused;

    /**
     * @dev Initializes the contract in unpaused state.
     */
    function __Pausable_init() internal onlyInitializing {
        __Pausable_init_unchained();
    }

    function __Pausable_init_unchained() internal onlyInitializing {
        _paused = false;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        _requireNotPaused();
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    modifier whenPaused() {
        _requirePaused();
        _;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns (bool) {
        return _paused;
    }

    /**
     * @dev Throws if the contract is paused.
     */
    function _requireNotPaused() internal view virtual {
        require(!paused(), "Pausable: paused");
    }

    /**
     * @dev Throws if the contract is not paused.
     */
    function _requirePaused() internal view virtual {
        require(paused(), "Pausable: not paused");
    }

    /**
     * @dev Triggers stopped state.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    /**
     * @dev Returns to normal state.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
}
// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.18;

import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import {OwnableUpgradeable} from "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import {IPool} from "../interfaces/IPool.sol";
import {IWETH} from "../interfaces/IWETH.sol";
import {IETHUnwrapper} from "../interfaces/IETHUnwrapper.sol";

abstract contract StakingReserve is Initializable, OwnableUpgradeable {
    using SafeERC20 for IERC20;
    using SafeERC20 for IWETH;

    IERC20 public LLP;
    IWETH public WETH;

    IPool public pool;
    IETHUnwrapper public ethUnwrapper;
    address public distributor;

    /// @notice the protocol generate fee in the form of these tokens
    mapping(address => bool) public feeTokens;
    /// @notice list of tokens allowed to convert to LLP. Other fee tokens MUST be manual swapped to these tokens before converting
    address[] public convertLLPTokens;
    /// @notice tokens allowed to convert to LLP, in form of map for fast checking
    mapping(address => bool) public isConvertLLPTokens;

    modifier onlyDistributorOrOwner() {
        _checkDistributorOrOwner();
        _;
    }

    function __StakingReserve_init(address _pool, address _llp, address _weth, address _ethUnwrapper)
        internal
        onlyInitializing
    {
        require(_pool != address(0), "Invalid address");
        require(_llp != address(0), "Invalid address");
        require(_weth != address(0), "Invalid address");
        require(_ethUnwrapper != address(0), "Invalid address");
        __Ownable_init();
        pool = IPool(_pool);
        LLP = IERC20(_llp);
        WETH = IWETH(_weth);
        ethUnwrapper = IETHUnwrapper(_ethUnwrapper);
    }

    // =============== RESTRICTED ===============
    function swap(address _fromToken, address _toToken, uint256 _amountIn, uint256 _minAmountOut)
        external
        onlyDistributorOrOwner
    {
        require(_toToken != _fromToken, "Invalid path");
        require(feeTokens[_fromToken] && feeTokens[_toToken], "Only feeTokens");
        uint256 _balanceBefore = IERC20(_toToken).balanceOf(address(this));
        IERC20(_fromToken).safeTransfer(address(pool), _amountIn);
        // self check slippage, so we send minAmountOut as 0
        pool.swap(_fromToken, _toToken, 0, address(this), abi.encode(msg.sender));
        uint256 _actualAmountOut = IERC20(_toToken).balanceOf(address(this)) - _balanceBefore;
        require(_actualAmountOut >= _minAmountOut, "!slippage");
        emit Swap(_fromToken, _toToken, _amountIn, _actualAmountOut);
    }

    /**
     * @notice operator can withdraw some tokens to manual swap or bridge to other chain's staking contract
     */
    function withdrawToken(address _token, address _to, uint256 _amount) external onlyDistributorOrOwner {
        require(feeTokens[_token], "Only feeTokens");
        require(_to != address(0), "Invalid address");
        _safeTransferToken(_token, _to, _amount);
        emit TokenWithdrawn(_to, _amount);
    }

    function setDistributor(address _distributor) external onlyOwner {
        require(_distributor != address(0), "Invalid address");
        distributor = _distributor;
        emit DistributorSet(distributor);
    }

    function setConvertLLPTokens(address[] calldata _tokens) external onlyOwner {
        for (uint256 i = 0; i < convertLLPTokens.length;) {
            isConvertLLPTokens[convertLLPTokens[i]] = false;
            unchecked {
                ++i;
            }
        }
        for (uint256 i = 0; i < _tokens.length;) {
            require(_tokens[i] != address(0), "Invalid address");
            isConvertLLPTokens[_tokens[i]] = true;
            unchecked {
                ++i;
            }
        }
        convertLLPTokens = _tokens;
        emit ConvertLLPTokensSet(_tokens);
    }

    // =============== INTERNAL FUNCTIONS ===============
    function _checkDistributorOrOwner() internal view virtual {
        require(msg.sender == distributor || msg.sender == owner(), "Caller is not the distributor or owner");
    }

    function _setFeeToken(address _token, bool _allowed) internal {
        if (feeTokens[_token] != _allowed) {
            feeTokens[_token] = _allowed;
            emit FeeTokenSet(_token, _allowed);
        }
    }

    function _convertTokenToLLP(address _token, uint256 _amount) internal {
        require(isConvertLLPTokens[_token], "Invalid token");
        if (_amount != 0) {
            IERC20(_token).safeIncreaseAllowance(address(pool), _amount);
            pool.addLiquidity(address(LLP), _token, _amount, 0, address(this));
        }
    }

    function _convertLLPToToken(address _to, uint256 _amount, address _tokenOut, uint256 _minAmountOut)
        internal
        returns (uint256)
    {
        LLP.safeIncreaseAllowance(address(pool), _amount);
        uint256 _balanceBefore = IERC20(_tokenOut).balanceOf(address(this));
        pool.removeLiquidity(address(LLP), _tokenOut, _amount, _minAmountOut, address(this));
        uint256 _amountOut = IERC20(_tokenOut).balanceOf(address(this)) - _balanceBefore;
        require(_amountOut >= _minAmountOut, "!slippage");
        _safeTransferToken(_tokenOut, _to, _amountOut);
        return _amountOut;
    }

    function _safeTransferToken(address _token, address _to, uint256 _amount) internal {
        if (_amount > 0) {
            if (_token == address(WETH)) {
                _safeUnwrapETH(_to, _amount);
            } else {
                IERC20(_token).safeTransfer(_to, _amount);
            }
        }
    }

    function _safeUnwrapETH(address _to, uint256 _amount) internal {
        WETH.safeIncreaseAllowance(address(ethUnwrapper), _amount);
        ethUnwrapper.unwrap(_amount, _to);
    }

    // =============== EVENTS ===============
    event DistributorSet(address indexed _distributor);
    event FeeTokenSet(address indexed _token, bool _allowed);
    event Swap(address indexed _tokenIn, address indexed _tokenOut, uint256 _amountIn, uint256 _amountOut);
    event TokenWithdrawn(address indexed _to, uint256 _amount);
    event ConvertLLPTokensSet(address[] _tokens);
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (utils/Address.sol)

pragma solidity ^0.8.1;

/**
 * @dev Collection of functions related to the address type
 */
library AddressUpgradeable {
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
     *
     * [IMPORTANT]
     * ====
     * You shouldn't rely on `isContract` to protect against flash loan attacks!
     *
     * Preventing calls from contracts is highly discouraged. It breaks composability, breaks support for smart wallets
     * like Gnosis Safe, and does not provide security since it can be circumvented by calling from a contract
     * constructor.
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.

        return account.code.length > 0;
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
        return functionCallWithValue(target, data, 0, "Address: low-level call failed");
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
        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
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
        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verify that a low level call to smart-contract was successful, and revert (either by bubbling
     * the revert reason or using the provided one) in case of unsuccessful call or if target was not a contract.
     *
     * _Available since v4.8._
     */
    function verifyCallResultFromTarget(
        address target,
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        if (success) {
            if (returndata.length == 0) {
                // only check isContract if the call was successful and the return data is empty
                // otherwise we already know that it was a contract
                require(isContract(target), "Address: call to non-contract");
            }
            return returndata;
        } else {
            _revert(returndata, errorMessage);
        }
    }

    /**
     * @dev Tool to verify that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason or using the provided one.
     *
     * _Available since v4.3._
     */
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            _revert(returndata, errorMessage);
        }
    }

    function _revert(bytes memory returndata, string memory errorMessage) private pure {
        // Look for revert reason and bubble it up if present
        if (returndata.length > 0) {
            // The easiest way to bubble the revert reason is using memory via assembly
            /// @solidity memory-safe-assembly
            assembly {
                let returndata_size := mload(returndata)
                revert(add(32, returndata), returndata_size)
            }
        } else {
            revert(errorMessage);
        }
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;
import "../proxy/utils/Initializable.sol";

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
abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal onlyInitializing {
    }

    function __Context_init_unchained() internal onlyInitializing {
    }
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[50] private __gap;
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/ContextUpgradeable.sol";
import "../proxy/utils/Initializable.sol";

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
abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    function __Ownable_init() internal onlyInitializing {
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal onlyInitializing {
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
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
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

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
}
pragma solidity >=0.8.0;

import {DataTypes} from "./DataTypes.sol";

interface IPool {
    struct TokenWeight {
        address token;
        uint256 weight;
    }

    struct RiskConfig {
        address tranche;
        uint256 riskFactor;
    }

    function isValidLeverageTokenPair(
        address _indexToken,
        address _collateralToken,
        DataTypes.Side _side,
        bool _isIncrease
    ) external view returns (bool);

    function canSwap(address _tokenIn, address _tokenOut) external view returns (bool);

    function increasePosition(
        address _account,
        address _indexToken,
        address _collateralToken,
        uint256 _sizeChanged,
        DataTypes.Side _side
    ) external;

    function decreasePosition(
        address _account,
        address _indexToken,
        address _collateralToken,
        uint256 _desiredCollateralReduce,
        uint256 _sizeChanged,
        DataTypes.Side _side,
        address _receiver
    ) external;

    function swap(address _tokenIn, address _tokenOut, uint256 _minOut, address _to, bytes calldata extradata)
        external;

    function addLiquidity(address _tranche, address _token, uint256 _amountIn, uint256 _minLpAmount, address _to)
        external;

    function removeLiquidity(address _tranche, address _tokenOut, uint256 _lpAmount, uint256 _minOut, address _to)
        external;

    function getPoolAsset(address _token) external view returns (DataTypes.AssetInfo memory);

    function getAllAssets() external view returns (address[] memory tokens, bool[] memory isStable);

    function getAllTranches() external view returns (address[] memory);

    function feeReserves(address token) external view returns (uint256);

    function withdrawFee(address _token, address _recipient) external;

    function isTranche(address _token) external view returns (bool);

    // =========== EVENTS ===========

    event SetOrderManager(address indexed orderManager);
    event IncreasePosition(
        bytes32 indexed key,
        address account,
        address collateralToken,
        address indexToken,
        uint256 collateralValue,
        uint256 sizeChanged,
        DataTypes.Side side,
        uint256 indexPrice,
        uint256 feeValue
    );
    event UpdatePosition(
        bytes32 indexed key,
        uint256 size,
        uint256 collateralValue,
        uint256 entryPrice,
        uint256 entryInterestRate,
        uint256 reserveAmount,
        uint256 indexPrice
    );
    event DecreasePosition(
        bytes32 indexed key,
        address account,
        address collateralToken,
        address indexToken,
        uint256 collateralChanged,
        uint256 sizeChanged,
        DataTypes.Side side,
        uint256 indexPrice,
        int256 pnl,
        uint256 feeValue
    );
    event ClosePosition(
        bytes32 indexed key,
        uint256 size,
        uint256 collateralValue,
        uint256 entryPrice,
        uint256 entryInterestRate,
        uint256 reserveAmount
    );
    event LiquidatePosition(
        bytes32 indexed key,
        address account,
        address collateralToken,
        address indexToken,
        DataTypes.Side side,
        uint256 size,
        uint256 collateralValue,
        uint256 reserveAmount,
        uint256 indexPrice,
        int256 pnl,
        uint256 feeValue
    );
    event DaoFeeWithdrawn(address indexed token, address recipient, uint256 amount);
    event FeeDistributorSet(address indexed feeDistributor);
    event LiquidityAdded(
        address indexed tranche, address indexed sender, address token, uint256 amount, uint256 lpAmount, uint256 fee
    );
    event LiquidityRemoved(
        address indexed tranche, address indexed sender, address token, uint256 lpAmount, uint256 amountOut, uint256 fee
    );
    event TokenWeightSet(TokenWeight[]);
    event Swap(
        address indexed sender,
        address tokenIn,
        address tokenOut,
        uint256 amountIn,
        uint256 amountOut,
        uint256 fee,
        uint256 priceIn,
        uint256 priceOut
    );
    event PositionFeeSet(uint256 positionFee, uint256 liquidationFee);
    event DaoFeeSet(uint256 value);
    event InterestAccrued(address indexed token, uint256 borrowIndex);
    event MaxLeverageChanged(uint256 maxLeverage);
    event TokenWhitelisted(address indexed token);
    event TokenDelisted(address indexed token);
    event OracleChanged(address indexed oldOracle, address indexed newOracle);
    event InterestRateSet(uint256 interestRate, uint256 stableCoinInterestRate, uint256 interval);
    event PoolHookChanged(address indexed hook);
    event TrancheAdded(address indexed lpToken);
    event TokenRiskFactorUpdated(address indexed token);
    event PnLDistributed(address indexed asset, address indexed tranche, int256 pnl);
    event MaintenanceMarginChanged(uint256 ratio);
    event MaxGlobalPositionSizeSet(address indexed token, uint256 maxLongRatios, uint256 maxShortSize);
    event PoolControllerChanged(address controller);
    event AssetRebalanced();
    event LiquidityCalculatorSet(address feeModel);
    event VirtualPoolValueRefreshed(uint256 value);
    event MaxLiquiditySet(address token, uint256 value);

    // ========== ERRORS ==============

    error UpdateCauseLiquidation();
    error InvalidLeverageTokenPair();
    error InvalidLeverage();
    error InvalidPositionSize();
    error OrderManagerOnly();
    error UnknownToken();
    error AssetNotListed();
    error InsufficientPoolAmount();
    error ReserveReduceTooMuch();
    error SlippageExceeded();
    error ValueTooHigh();
    error InvalidInterval();
    error PositionNotLiquidated();
    error ZeroAmount();
    error ZeroAddress();
    error RequireAllTokens();
    error DuplicateToken();
    error FeeDistributorOnly();
    error InvalidMaxLeverage();
    error InvalidSwapPair();
    error InvalidTranche();
    error TrancheAlreadyAdded();
    error RemoveLiquidityTooMuch();
    error CannotDistributeToTranches();
    error PositionNotExists();
    error MaxNumberOfTranchesReached();
    error TooManyTokenAdded();
    error AddLiquidityNotAllowed();
    error MaxGlobalShortSizeExceeded();
    error NotApplicableForStableCoin();
    error MaxLiquidityReach();
}
pragma solidity >=0.8.0;

import {IERC20} from "@openzeppelin/contracts/interfaces/IERC20.sol";

interface IWETH is IERC20 {
    function deposit() external payable;
    function transfer(address to, uint256 value) external returns (bool);
    function withdraw(uint256) external;
}
pragma solidity >= 0.8.0;

interface IETHUnwrapper {
    function unwrap(uint256 _amount, address _to) external;
}
pragma solidity >=0.8.0;

library DataTypes {
    enum Side {
        LONG,
        SHORT
    }

    struct PositionIdentifier {
        address owner;
        address indexToken;
        address collateralToken;
        Side side;
    }

    enum UpdatePositionType {
        INCREASE,
        DECREASE
    }

    struct UpdatePositionRequest {
        uint256 sizeChange;
        uint256 collateral;
        UpdatePositionType updateType;
        Side side;
    }

    enum OrderType {
        MARKET,
        LIMIT
    }

    enum OrderStatus {
        OPEN,
        FILLED,
        EXPIRED,
        CANCELLED
    }

    struct LeverageOrder {
        address owner;
        address indexToken;
        address collateralToken;
        OrderStatus status;
        address payToken;
        bool triggerAboveThreshold;
        uint256 price;
        uint256 executionFee;
        uint256 submissionBlock;
        uint256 expiresAt;
    }

    struct SwapOrder {
        address owner;
        address tokenIn;
        address tokenOut;
        OrderStatus status;
        uint256 amountIn;
        uint256 minAmountOut;
        uint256 price;
        uint256 executionFee;
    }

    struct AssetInfo {
        /// @notice amount of token deposited (via add liquidity or increase long position)
        uint256 poolAmount;
        /// @notice amount of token reserved for paying out when user decrease long position
        uint256 reservedAmount;
        /// @notice total borrowed (in USD) to leverage
        uint256 guaranteedValue;
        /// @notice total size of all short positions
        uint256 totalShortSize;
        /// @notice average entry price of all short positions
        uint256 averageShortPrice;
    }

    struct Position {
        /// @dev contract size is evaluated in dollar
        uint256 size;
        /// @dev collateral value in dollar
        uint256 collateralValue;
        /// @dev contract size in indexToken
        uint256 reserveAmount;
        /// @dev average entry price
        uint256 entryPrice;
        /// @dev last cumulative interest rate
        uint256 borrowIndex;
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (interfaces/IERC20.sol)

pragma solidity ^0.8.0;

import "../token/ERC20/IERC20.sol";
