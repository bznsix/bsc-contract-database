// File: @openzeppelin/contracts/utils/math/SafeMath.sol

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
    function tryAdd(
        uint256 a,
        uint256 b
    ) internal pure returns (bool, uint256) {
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
    function trySub(
        uint256 a,
        uint256 b
    ) internal pure returns (bool, uint256) {
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
    function tryMul(
        uint256 a,
        uint256 b
    ) internal pure returns (bool, uint256) {
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
    function tryDiv(
        uint256 a,
        uint256 b
    ) internal pure returns (bool, uint256) {
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
    function tryMod(
        uint256 a,
        uint256 b
    ) internal pure returns (bool, uint256) {
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

// File: @openzeppelin/contracts/utils/Context.sol

// OpenZeppelin Contracts (last updated v5.0.0) (utils/Context.sol)

pragma solidity ^0.8.20;

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

// File: @openzeppelin/contracts/access/Ownable.sol

// OpenZeppelin Contracts (last updated v5.0.0) (access/Ownable.sol)

pragma solidity ^0.8.20;

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * The initial owner is set to the address provided by the deployer. This can
 * later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    /**
     * @dev The caller account is not authorized to perform an operation.
     */
    error OwnableUnauthorizedAccount(address account);

    /**
     * @dev The owner is not a valid owner account. (eg. `address(0)`)
     */
    error OwnableInvalidOwner(address owner);

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /**
     * @dev Initializes the contract setting the address provided by the deployer as the initial owner.
     */
    constructor(address initialOwner) {
        if (initialOwner == address(0)) {
            revert OwnableInvalidOwner(address(0));
        }
        _transferOwnership(initialOwner);
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
        if (owner() != _msgSender()) {
            revert OwnableUnauthorizedAccount(_msgSender());
        }
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
        if (newOwner == address(0)) {
            revert OwnableInvalidOwner(address(0));
        }
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

// File: @openzeppelin/contracts/security/Pausable.sol

// OpenZeppelin Contracts (last updated v4.7.0) (security/Pausable.sol)

pragma solidity ^0.8.0;

/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
abstract contract Pausable is Context {
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
    constructor() {
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
}

// File: @openzeppelin/contracts/token/ERC20/IERC20.sol

// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.20;

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
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    /**
     * @dev Returns the value of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the value of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves a `value` amount of tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 value) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(
        address owner,
        address spender
    ) external view returns (uint256);

    /**
     * @dev Sets a `value` amount of tokens as the allowance of `spender` over the
     * caller's tokens.
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
    function approve(address spender, uint256 value) external returns (bool);

    /**
     * @dev Moves a `value` amount of tokens from `from` to `to` using the
     * allowance mechanism. `value` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);
}

// File: MultimsgsenderLinearVesting.sol

pragma solidity ^0.8.0;

contract MultimsgsenderLinearVesting is Pausable, Ownable(address(msg.sender)) {
    using SafeMath for uint256;

    address public token;
    uint256 public adminFees;
    struct VestingSchedule {
        uint256 vestingStart;
        uint256 _vestingDuration; 
        uint256 totalTokens;
        uint256 withdrawnTokens;
        uint256 depositedTokens;
        uint256 remainingTokens;
    }
    uint256 public stakingStartTime; // November 12, 2023, 00:00:00 GMT
    uint256 public stakingEndTime; // November 30, 2023, 00:00:00 GMT
    uint256 public vestingStartTime; // December 1, 2023, 00:00:00 GMT
    event Staked(address indexed user, uint256 amount, uint256 timeStamp);
    event Withdrawn(address indexed user, uint256 amount, uint256 timeStamp);
    mapping(address => VestingSchedule) public vestingSchedules;
    mapping(address => uint256) public depositedBalances;
    uint256 vestingDuration=365;
    // uint256 vestingDuration = 5;

    constructor(
        address _token,
        uint256 _stakingStartTime,
        uint256 _stakingEndTime,
        uint256 _vestingStartTime,
        uint256 _fees
    ) {
        token = _token;
        stakingStartTime = _stakingStartTime;
        stakingEndTime = _stakingEndTime;
        vestingStartTime = _vestingStartTime;
        adminFees = _fees;
    }

    modifier duringStakingPeriod() {
        require(
            block.timestamp >= stakingStartTime &&
                block.timestamp <= stakingEndTime,
            "Staking not allowed"
        );
        _;
    }

    modifier afterStakingPeriod() {
        require(
            block.timestamp > stakingEndTime,
            "Staking period has been ended "
        );
        _;
    }

    function depositTokens(
        uint amount
    ) external duringStakingPeriod whenNotPaused {
        require(amount > 0, "Must deposit at least one token");
        depositedBalances[msg.sender] = depositedBalances[msg.sender].add(
            amount
        );
        depositedBalances[msg.sender] = depositedBalances[msg.sender].add(
            amount.mul(2)
        );

        // Assume a function `transferFrom` to handle depositing tokens
        IERC20(token).transferFrom(msg.sender, address(this), amount);

        vestingSchedules[msg.sender] = VestingSchedule({
            vestingStart: vestingStartTime,
            _vestingDuration: vestingDuration * 1 days,
            totalTokens: depositedBalances[msg.sender],
            withdrawnTokens: 0,
            depositedTokens: depositedBalances[msg.sender],
            remainingTokens: depositedBalances[msg.sender]
        });
        emit Staked(msg.sender, depositedBalances[msg.sender], block.timestamp); // Emit the 'Staked' event
    }

    function withdraw() external afterStakingPeriod whenNotPaused {
        VestingSchedule storage vestingSchedule = vestingSchedules[msg.sender];

        require(
            vestingSchedule.vestingStart > 0,
            "No vesting schedule found for this address"
        );
        require(
            block.timestamp >= vestingSchedule.vestingStart,
            "Vesting period has not started yet"
        );
        uint256 weeksSinceStart = (
            block.timestamp.sub(vestingSchedule.vestingStart)
        ).div(1 days); // Changed this line
        require(weeksSinceStart > 0, "No tokens available for withdrawal yet");
        if (weeksSinceStart > vestingDuration) {
            require(
                vestingSchedule.remainingTokens > 0,
                "no token left for withdrawl"
            );
            vestingSchedule.withdrawnTokens = vestingSchedule
                .withdrawnTokens
                .add(vestingSchedule.remainingTokens); // Changed this line
            uint256 _commission = (
                vestingSchedule.remainingTokens.mul(adminFees)
            ).div(100000); // Changed this line
            uint256 transferAfterFees = vestingSchedule.remainingTokens.sub(
                _commission
            ); // Changed this line
            IERC20(token).transfer(msg.sender, transferAfterFees);
            IERC20(token).transfer(owner(), _commission);
            vestingSchedule.remainingTokens = 0; // Changed this line
            emit Withdrawn(msg.sender, transferAfterFees, block.timestamp); // Emit the 'Withdrawn' event
        } else {
            uint256 tokensAvailable = (
                weeksSinceStart.mul(vestingSchedule.totalTokens)
            ).div(vestingDuration); // Changed this line
            tokensAvailable = tokensAvailable.sub(
                vestingSchedule.withdrawnTokens
            ); // Changed this line
            require(
                tokensAvailable > 0,
                "No tokens available for withdrawal yet"
            );
            require(
                tokensAvailable <=
                    vestingSchedule.totalTokens.sub(
                        vestingSchedule.withdrawnTokens
                    ),
                "Not enough tokens left for withdrawal"
            );

            vestingSchedule.withdrawnTokens = vestingSchedule
                .withdrawnTokens
                .add(tokensAvailable); // Changed this line
            vestingSchedule.remainingTokens = vestingSchedule
                .remainingTokens
                .sub(tokensAvailable); // Changed this line

            uint256 _commission = (tokensAvailable.mul(adminFees)).div(100000); // Changed this line
            uint256 transferAfterFees = tokensAvailable.sub(_commission); // Changed this line

            IERC20(token).transfer(msg.sender, transferAfterFees);
            IERC20(token).transfer(owner(), _commission);
            emit Withdrawn(msg.sender, transferAfterFees, block.timestamp); // Emit the 'Withdrawn' event
        }
    }

    function drain(uint256 amount) external onlyOwner {
        require(amount > 0, "Amount must be greater than zero");
        require(
            amount <= IERC20(token).balanceOf(address(this)),
            "Insufficient contract balance"
        );
        IERC20(token).transfer(owner(), amount);
    }

    function changeConfigurations(
        address _token,
        uint256 _stakingStartTime,
        uint256 _stakingEndTime,
        uint256 _vestingStartTime,
        uint256 _fees
    ) external onlyOwner {
        token = _token;
        stakingStartTime = _stakingStartTime;
        stakingEndTime = _stakingEndTime;
        vestingStartTime = _vestingStartTime;
        adminFees = _fees;
    }

    function checkAvailableTokens() external view returns (uint256) {
        VestingSchedule storage vestingSchedule = vestingSchedules[msg.sender];
        uint256 weeksSinceStart = (
            block.timestamp.sub(vestingSchedule.vestingStart)
        ).div(1 days);
        if (weeksSinceStart > vestingDuration) {
            return vestingSchedule.remainingTokens; // Changed this line
        }
        uint256 tokensAvailable = (
            weeksSinceStart.mul(vestingSchedule.totalTokens)
        ).div(vestingDuration);
        tokensAvailable = tokensAvailable.sub(vestingSchedule.withdrawnTokens);
        return tokensAvailable;
    }
}