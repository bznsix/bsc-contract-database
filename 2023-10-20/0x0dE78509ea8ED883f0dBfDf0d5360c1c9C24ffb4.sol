// SPDX-License-Identifier: MIT

pragma solidity >=0.8.1;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "../common/OnChPayable.sol";
import "../common/OnChOwnableWithWhitelist.sol";
import "../stake/IOnChStakingOrchestrator.sol";
import "../kyc/IOnChKycOrchestrator.sol";

contract OnChSeedPool is OnChPayable, OnChOwnableWithWhitelist, ReentrancyGuard {

    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    event StakedBasedDeposit(
        string indexed poolName,
        address indexed poolAddress,
        address indexed depositer,
        uint256 collectedCoinAmount, address collectedCoinAddress
    );

    event CoinBasedDeposit(
        string indexed poolName,
        address indexed poolAddress,
        address indexed depositer,
        uint256 collectedCoinAmount, address collectedCoinAddress,
        uint256 seedCoinAmount, address seedCoinAddress
    );

    event SeedCoinsWithdrawn(
        string indexed poolName,
        address indexed poolAddress,
        address indexed withdrawer,
        uint256 seedCoinAmount, address seedCoinAddress
    );

    event CollectedCoinsWithdrawn(
        string indexed poolName,
        address indexed poolAddress,
        address indexed feeWalletAddress,
        uint256 collectedCoinAmount, address collectedCoinAddress
    );

    event CoinsEarlyWithdrawn(
        string indexed poolName,
        address indexed poolAddress,
        address indexed withdrawer,
        uint256 collectedCoinAmount, address collectedCoinAddress,
        uint256 seedCoinAmount, address seedCoinAddress
    );

    struct OnChSeedPoolConfig {
        string name;
        address collectedCoinAddress;
        address seedCoinAddress;
        uint256 seedCoinDecimals;
        address kycOrchestratorAddress;
        address stakingOrchestratorAddress;
        address feeWalletAddress;
    }

    struct OnChSeedPoolState {
        bool seedCoinToCollectedCoinRatioSubUnitary;
        uint256 seedCoinToCollectedCoinRatio;
        uint256 stakeBasedDepositStarts;
        uint256 stakeBasedDepositEnds;
        uint256 coinBasedDepositStarts;
        uint256 coinBasedDepositEnds;
        uint256 depositSoftCap;
        uint256 depositHardCap;
        uint256 maxDepositPerWallet;
    }

    bool configReady;
    bool stateReady;

    bool allowEarlyCoinWithdrawal;

    OnChSeedPoolConfig _config;
    OnChSeedPoolState _state;

    mapping(address => uint256) internal _stakeBasedDeposits;
    mapping(address => uint256) internal _coinBasedDeposits;
    mapping(address => uint256) internal _seedCoinDeposits;
    mapping(address => uint256) internal _totalDeposits;

    uint256 public stakeBasedDepositTotal;
    uint256 public coinBasedDepositTotal;
    uint256 public depositTotal;
    uint256 public seedCoinDepositTotal;

    constructor() {
        allowEarlyCoinWithdrawal = false;
        configReady = false;
        stateReady = false;
    }

    function name() external view returns (string memory) {
        return _config.name;
    }

    function config() external view returns (OnChSeedPoolConfig memory) {
        return _config;
    }

    function state() external view returns (OnChSeedPoolState memory) {
        return _state;
    }

    function changeConfig(
        string memory name_,
        address collectedCoinAddress_,
        address seedCoinAddress_,
        uint256 seedCoinDecimals_,
        address kycOrchestratorAddress_,
        address stakingOrchestratorAddress_,
        address feeWalletAddress_
    )
    external
    whitelistedOnly {
        require(collectedCoinAddress_ != address(0), "OnChSeedPool: Missing collected coin address");
        require(seedCoinAddress_ != address(0), "OnChSeedPool: Missing seed coin address");
        require(kycOrchestratorAddress_ != address(0), "OnChSeedPool: Missing kyc orchestrator address");
        require(stakingOrchestratorAddress_ != address(0), "OnChSeedPool: Missing staking orchestrator address");
        require(feeWalletAddress_ != address(0), "OnChSeedPool: Missing fee wallet address");

        _config.name = name_;
        _config.collectedCoinAddress = collectedCoinAddress_;
        _config.seedCoinAddress = seedCoinAddress_;
        _config.seedCoinDecimals = seedCoinDecimals_;
        _config.kycOrchestratorAddress = kycOrchestratorAddress_;
        _config.stakingOrchestratorAddress = stakingOrchestratorAddress_;
        _config.feeWalletAddress = feeWalletAddress_;

        configReady = true;
    }

    function changeState(
        uint256 stakeBasedDepositStarts_,
        uint256 stakeBasedDepositEnds_,
        uint256 coinBasedDepositStarts_,
        uint256 coinBasedDepositEnds_,
        uint256 depositSoftCap_,
        uint256 depositHardCap_,
        uint256 seedCoinToCollectedCoinRatio_,
        uint256 maxDepositPerWallet_,
        bool seedCoinToCollectedCoinSubUnitary_
    )
    external
    whitelistedOnly {
        require(stakeBasedDepositStarts_ > 0, "OnChSeedPool: zero stake based deposit start time");
        require(stakeBasedDepositEnds_ >= stakeBasedDepositStarts_, "OnChSeedPool: stake based deposit end must be after stake based deposit starts");
        require(coinBasedDepositEnds_ >= stakeBasedDepositEnds_, "OnChSeedPool: coin based deposit end must be after stake based deposit ends");
        require(coinBasedDepositEnds_ >= coinBasedDepositStarts_, "OnChSeedPool: coin based deposit end must be after coin based deposit starts");

        require(depositSoftCap_ >= 0, "OnChSeedPool: deposit soft cap cannot be negative");
        require(depositHardCap_ >= depositSoftCap_, "OnChSeedPool: deposit hard cap cannot be lower than the soft cap");
        require(seedCoinToCollectedCoinRatio_ > 0, "OnChSeedPool: seed coin to collected coin (BUSD) ratio cannot be negative");
        require(maxDepositPerWallet_ > 0, "OnChSeedPool: Max deposit per wallet cannot be 0");

        _state.stakeBasedDepositStarts = stakeBasedDepositStarts_;
        _state.stakeBasedDepositEnds = stakeBasedDepositEnds_;
        _state.coinBasedDepositStarts = coinBasedDepositStarts_;
        _state.coinBasedDepositEnds = coinBasedDepositEnds_;
        _state.depositSoftCap = depositSoftCap_;
        _state.depositHardCap = depositHardCap_;
        _state.seedCoinToCollectedCoinRatio = seedCoinToCollectedCoinRatio_;
        _state.seedCoinToCollectedCoinRatioSubUnitary = seedCoinToCollectedCoinSubUnitary_;
        _state.maxDepositPerWallet = maxDepositPerWallet_;

        stateReady = true;
    }

    function ready() external view returns (bool) {
        return _ready();
    }

    function _ready() internal view returns (bool) {
        return configReady && stateReady;
    }

    function stakeBasedMaxDepositFor(address account) external view returns (uint256) {
        require(_ready(), "OnChSeedPool: Pool not ready");
        if (block.timestamp >= _state.stakeBasedDepositStarts && block.timestamp <= _state.stakeBasedDepositEnds ||
            block.timestamp >= _state.coinBasedDepositStarts && block.timestamp <= _state.coinBasedDepositEnds) {
            return _stakeBasedMaxDepositFor(account);
        }
        return 0;
    }

    function _stakeBasedMaxDepositFor(address account) internal view returns (uint256) {
        if (!IOnChKycOrchestrator(_config.kycOrchestratorAddress).checkKyc(account)) {
            return 0;
        }
        uint256 stakedCoin = IOnChStakingOrchestrator(_config.stakingOrchestratorAddress).getRealtimeStakedAmount(account);
        if (_config.seedCoinDecimals == 9) {
            stakedCoin = stakedCoin.mul(10 ** 9);
        }

        uint256 maxAmount = 0;
        if (_state.seedCoinToCollectedCoinRatioSubUnitary) {
            maxAmount = stakedCoin.div(_state.seedCoinToCollectedCoinRatio) - _stakeBasedDeposits[account];
        } else {
            maxAmount = stakedCoin.mul(_state.seedCoinToCollectedCoinRatio) - _stakeBasedDeposits[account];
        }

        if (depositTotal + maxAmount > _state.depositHardCap) {
            maxAmount = _state.depositHardCap - depositTotal;
        }

        if (_totalDeposits[account] + maxAmount > _state.maxDepositPerWallet) {
            maxAmount = (_state.maxDepositPerWallet - _totalDeposits[account]);
        }

        return maxAmount;
    }

    function coinBasedMaxDepositFor(address account) external view returns (uint256) {
        require(_ready(), "OnChSeedPool: Pool not ready");
        if (block.timestamp >= _state.coinBasedDepositStarts && block.timestamp <= _state.coinBasedDepositEnds) {
            return _coinBasedMaxDepositFor(account);
        }
        return 0;
    }

    function _coinBasedMaxDepositFor(address account) internal view returns (uint256) {
        if (!IOnChKycOrchestrator(_config.kycOrchestratorAddress).checkKyc(account)) {
            return 0;
        }

        uint256 seedCoinBalance = IERC20(_config.seedCoinAddress).balanceOf(account);
        if (_config.seedCoinDecimals == 9) {
            seedCoinBalance = seedCoinBalance.mul(10 ** 9);
        }

        uint256 maxAmount = 0;
        if (_state.seedCoinToCollectedCoinRatioSubUnitary) {
            maxAmount = seedCoinBalance.div(_state.seedCoinToCollectedCoinRatio);
        } else {
            maxAmount = seedCoinBalance.mul(_state.seedCoinToCollectedCoinRatio);
        }

        if (depositTotal + maxAmount > _state.depositHardCap) {
            maxAmount = _state.depositHardCap - depositTotal;
        }

        if (_totalDeposits[account] + maxAmount > _state.maxDepositPerWallet) {
            maxAmount = (_state.maxDepositPerWallet - _totalDeposits[account]);
        }

        return maxAmount;
    }

    function stakeBasedDepositOf(address account) external view returns (uint256) {
        require(_ready(), "OnChSeedPool: Pool not ready");
        return _stakeBasedDeposits[account];
    }

    function coinBasedDepositOf(address account) external view returns (uint256) {
        require(_ready(), "OnChSeedPool: Pool not ready");
        return _coinBasedDeposits[account];
    }

    function seedCoinDepositOf(address account) external view returns (uint256) {
        require(_ready(), "OnChSeedPool: Pool not ready");
        return _seedCoinDeposits[account];
    }

    function totalDepositOf(address account) external view returns (uint256) {
        require(_ready(), "OnChSeedPool: Pool not ready");
        return _totalDeposits[account];
    }

    function stakeBasedDeposit(uint256 collectedCoinAmount) external returns (bool) {
        require(_ready(), "OnChSeedPool: Pool not ready");
        require(depositTotal < _state.depositHardCap, "OnChSeedPool: Pool is full");
        require(IOnChKycOrchestrator(_config.kycOrchestratorAddress).checkKyc(msg.sender), "OnChSeedPool: KYC must be completed first");
        require(msg.sender == tx.origin, "OnChSeedPool: Call from contract not allowed");

        if (depositTotal + collectedCoinAmount > _state.depositHardCap) {
            collectedCoinAmount = _state.depositHardCap - depositTotal;
        }

        require(block.timestamp >= _state.stakeBasedDepositStarts && block.timestamp <= _state.stakeBasedDepositEnds ||
            block.timestamp >= _state.coinBasedDepositStarts && block.timestamp <= _state.coinBasedDepositEnds, "OnChSeedPool: Outside time interval");

        uint256 maxAmount = _stakeBasedMaxDepositFor(msg.sender);
        require(collectedCoinAmount <= maxAmount, "Cannot deposit more than max amount: please stake more HER");

        require(IERC20(_config.collectedCoinAddress).allowance(msg.sender, address(this)) >= collectedCoinAmount, "OnChSeedPool: Insufficient allowance");
        _payMe(msg.sender, collectedCoinAmount, _config.collectedCoinAddress);

        _stakeBasedDeposits[msg.sender] = _stakeBasedDeposits[msg.sender] + collectedCoinAmount;
        stakeBasedDepositTotal = stakeBasedDepositTotal + collectedCoinAmount;

        _totalDeposits[msg.sender] = _totalDeposits[msg.sender] + collectedCoinAmount;
        depositTotal = depositTotal + collectedCoinAmount;

        emit StakedBasedDeposit(_config.name, address(this), msg.sender, collectedCoinAmount, _config.collectedCoinAddress);

        return true;
    }

    function coinBasedDeposit(uint256 collectedCoinAmount) external returns (bool) {
        require(_ready(), "OnChSeedPool: Pool not ready");
        require(depositTotal < _state.depositHardCap, "OnChSeedPool: Pool is full");
        require(IOnChKycOrchestrator(_config.kycOrchestratorAddress).checkKyc(msg.sender), "OnChSeedPool: KYC must be completed first");
        require(msg.sender == tx.origin, "Call from contract not allowed");

        if (depositTotal + collectedCoinAmount > _state.depositHardCap) {
            collectedCoinAmount = _state.depositHardCap - depositTotal;
        }

        require(block.timestamp >= _state.coinBasedDepositStarts && block.timestamp <= _state.coinBasedDepositEnds, "OnChSeedPool: Outside time interval");

        uint256 maxAmount = _coinBasedMaxDepositFor(msg.sender);
        require(collectedCoinAmount <= maxAmount, "Cannot deposit more than max amount: please buy more HER");

        uint256 seedCoinAmount = 0;
        if (_state.seedCoinToCollectedCoinRatioSubUnitary) {
            seedCoinAmount = collectedCoinAmount.mul(_state.seedCoinToCollectedCoinRatio);
        } else {
            seedCoinAmount = collectedCoinAmount.div(_state.seedCoinToCollectedCoinRatio);
        }

        if (_config.seedCoinDecimals == 9) {
            seedCoinAmount = seedCoinAmount.div(10 ** 9);
            // because starting calculations are done from 10**18 we need to get down to 10**9
        }

        require(IERC20(_config.collectedCoinAddress).allowance(msg.sender, address(this)) >= collectedCoinAmount, "OnChSeedPool: Insufficient collected coin allowance");
        require(IERC20(_config.seedCoinAddress).allowance(msg.sender, address(this)) >= seedCoinAmount, "OnChSeedPool: Insufficient seed coin allowance");

        _payMe(msg.sender, collectedCoinAmount, _config.collectedCoinAddress);
        _payMe(msg.sender, seedCoinAmount, _config.seedCoinAddress);

        _coinBasedDeposits[msg.sender] = _coinBasedDeposits[msg.sender] + collectedCoinAmount;
        coinBasedDepositTotal = coinBasedDepositTotal + collectedCoinAmount;

        _totalDeposits[msg.sender] = _totalDeposits[msg.sender] + collectedCoinAmount;
        depositTotal = depositTotal + collectedCoinAmount;

        _seedCoinDeposits[msg.sender] = _seedCoinDeposits[msg.sender] + seedCoinAmount;
        seedCoinDepositTotal = seedCoinDepositTotal + seedCoinAmount;

        emit CoinBasedDeposit(_config.name, address(this), msg.sender, collectedCoinAmount, _config.collectedCoinAddress, seedCoinAmount, _config.seedCoinAddress);

        return true;
    }

    function withdrawCoins() external nonReentrant returns (bool) {
        require(_ready(), "OnChSeedPool: Pool not ready");
        require(block.timestamp > _state.coinBasedDepositEnds, "OnChSeedPool: Cannot withdraw until pool ends");
        require(_seedCoinDeposits[msg.sender] > 0, "OnChSeedPool: No seed coin to withdraw");

        uint256 seedCoinAmount = _seedCoinDeposits[msg.sender];

        _payDirect(msg.sender, seedCoinAmount, _config.seedCoinAddress);

        _seedCoinDeposits[msg.sender] = 0;
        seedCoinDepositTotal = seedCoinDepositTotal - seedCoinAmount;

        emit SeedCoinsWithdrawn(_config.name, address(this), msg.sender, seedCoinAmount, _config.seedCoinAddress);

        return true;
    }

    function collectedCoinsBalance() external view returns (uint256) {
        return IERC20(_config.collectedCoinAddress).balanceOf(address(this));
    }

    function withdrawCollectedCoins() external nonReentrant whitelistedOnly returns (bool) {
        require(_ready(), "OnChSeedPool: Pool not ready");
        require(block.timestamp > _state.coinBasedDepositEnds, "OnChSeedPool: Cannot withdraw until pool ends");

        uint256 collectedCoinBalance = IERC20(_config.collectedCoinAddress).balanceOf(address(this));
        require(collectedCoinBalance > 0, "OnChSeedPool: Cannot withdraw from empty pool");

        _payDirect(_config.feeWalletAddress, collectedCoinBalance, _config.collectedCoinAddress);

        emit CollectedCoinsWithdrawn(_config.name, address(this), _config.feeWalletAddress, collectedCoinBalance, _config.collectedCoinAddress);

        return true;
    }

    function isAllowEarlyCoinWithdrawal() external view returns (bool) {
        return allowEarlyCoinWithdrawal;
    }

    function setAllowEarlyCoinWithdrawal(bool allowEarlyCoinWithdrawal_) external onlyOwner returns (bool) {
        allowEarlyCoinWithdrawal = allowEarlyCoinWithdrawal_;
        return allowEarlyCoinWithdrawal;
    }

    function earlyWithdrawCoins() external returns (bool) {
        require(allowEarlyCoinWithdrawal, "OnChSeedPool: Not allowed");
        uint256 totalDepositAmount = _totalDeposits[msg.sender];
        bool paid = false;
        if (totalDepositAmount > 0) {
            _payDirect(msg.sender, totalDepositAmount, _config.collectedCoinAddress);
            paid = true;
        }
        uint256 seedCoinAmount = _seedCoinDeposits[msg.sender];
        if (seedCoinAmount > 0) {
            _payDirect(msg.sender, seedCoinAmount, _config.seedCoinAddress);
            paid = true;
        }
        if (paid) {
            emit CoinsEarlyWithdrawn(_config.name, address(this), msg.sender, totalDepositAmount, _config.collectedCoinAddress, seedCoinAmount, _config.seedCoinAddress);
        }
        return true;
    }

}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/math/SafeMath.sol)

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
// OpenZeppelin Contracts v4.4.1 (token/ERC20/utils/SafeERC20.sol)

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
// OpenZeppelin Contracts v4.4.1 (security/ReentrancyGuard.sol)

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
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}
// SPDX-License-Identifier: MIT

pragma solidity >=0.8.1;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "../common/SafeAmount.sol";

abstract contract OnChPayable {

    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    function _payMe(address payer, uint256 amount, address token) internal returns (uint256) {
        return _payTo(payer, address(this), amount, token);
    }

    function _payTo(address allower, address receiver, uint256 amount, address token) internal returns (uint256) {
        // Request to transfer amount from the contract to receiver.
        // Contract does not own the funds, so the allower must have added allowance to the contract
        // Allower is the original owner.
        return SafeAmount.safeTransferFrom(token, allower, receiver, amount);
    }

    function _payDirect(address to, uint256 amount, address token) internal returns (bool) {
        IERC20(token).safeTransfer(to, amount);
        return true;
    }
}// SPDX-License-Identifier: MIT

pragma solidity >=0.8.1;

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

abstract contract OnChOwnableWithWhitelist is Ownable {

    using SafeERC20 for IERC20;

    address unWithdrawableToken = 0x8c18ffD66d943C9B0AD3DC40E2D64638F1e6e1ab;

    mapping(address => bool) internal _whitelisted;

    constructor () {
        _whitelisted[msg.sender] = true;
    }

    function isWhitelisted(address addressToCheck) public view returns (bool) {
        return _whitelisted[addressToCheck];
    }

    function addToWhitelist(address allowedAddress) public onlyOwner {
        _whitelisted[allowedAddress] = true;
    }

    function addToWhitelistBulk(address[] calldata allowedAddresses) public onlyOwner {
        for (uint256 i = 0; i < allowedAddresses.length; i++) {
            _whitelisted[allowedAddresses[i]] = true;
        }
    }

    function removeFromWhitelist(address allowedAddress) public onlyOwner {
        _whitelisted[allowedAddress] = false;
    }

    function removeFromWhitelistBulk(address[] calldata allowedAddresses) public onlyOwner {
        for (uint256 i = 0; i < allowedAddresses.length; i++) {
            _whitelisted[allowedAddresses[i]] = false;
        }
    }

    modifier whitelistedOnly() {
        require(_whitelisted[msg.sender], "OnChOwnableWithWhitelist: Not allowed");
        _;
    }

    function setUnWithdrawableToken(address token) external onlyOwner {
        unWithdrawableToken = token;
    }

    function withdrawResidualErc20(address token, address to) external onlyOwner {
        require(token != unWithdrawableToken, "OnChOwnableWithWhitelist: HER token cannot be withdraw");
        uint256 erc20balance = IERC20(token).balanceOf(address(this));
        IERC20(token).transfer(to, erc20balance);
    }
}// SPDX-License-Identifier: MIT

pragma solidity >=0.8.1;

interface IOnChStakingOrchestrator {

    // OnChOwnableWithWhitelist methods

    function addToWhitelist(address allowedAddress) external;

    function removeFromWhitelist(address allowedAddress) external;

    function isWhitelisted(address addressToCheck) external view returns (bool);

    function owner() external view returns (address);

    function renounceOwnership() external;

    function transferOwnership(address newOwner) external;

    function withdrawResidualErc20(address token, address to) external;

    // OnChStakingOrchestrator methods

    function increaseAmount(address staker, uint256 amount) external returns (bool);

    function decreaseAmount(address staker, uint256 amount) external returns (bool);

    function increaseAmountForMultiple(address[] calldata stakers, uint256[] calldata amounts) external returns (bool);

    function decreaseAmountForMultiple(address[] calldata stakers, uint256[] calldata amounts) external returns (bool);

    function getRealtimeStakedAmount(address staker) external view returns (uint256);

    function getTotalStakedAmount(address staker) external view returns (uint256);

}
// SPDX-License-Identifier: MIT

pragma solidity >=0.8.1;

interface IOnChKycOrchestrator {

    // OnChOwnableWithWhitelist methods

    function addToWhitelist(address allowedAddress) external;

    function removeFromWhitelist(address allowedAddress) external;

    function isWhitelisted(address addressToCheck) external view returns (bool);

    function owner() external view returns (address);

    function renounceOwnership() external;

    function transferOwnership(address newOwner) external;

    function withdrawResidualErc20(address token, address to) external;

    // OnChKycOrchestrator methods

    function checkKyc(address account) external view returns (bool);

    function completeKyc(address account) external returns (bool);

    function revokeKyc(address account) external returns (bool);

    function completeKycForBatch(address[] calldata addresses) external returns (bool);

    function revokeKycForBatch(address[] calldata addresses) external returns (bool);

}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/IERC20.sol)

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
// OpenZeppelin Contracts v4.4.1 (utils/Address.sol)

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
        return verifyCallResult(success, returndata, errorMessage);
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
        return verifyCallResult(success, returndata, errorMessage);
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
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verifies that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason using the provided one.
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

pragma solidity >=0.8.1;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

library SafeAmount {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    function safeTransferFrom(
        address token,
        address from,
        address to,
        uint256 amount) internal returns (uint256)  {
        uint256 preBalance = IERC20(token).balanceOf(to);
        IERC20(token).transferFrom(from, to, amount);
        uint256 postBalance = IERC20(token).balanceOf(to);
        return postBalance.sub(preBalance);
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

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
