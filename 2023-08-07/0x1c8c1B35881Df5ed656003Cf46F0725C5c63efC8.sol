// File @openzeppelin/contracts/utils/Context.sol@v3.4.1

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with GSN meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}


// File @openzeppelin/contracts/math/SafeMath.sol@v3.4.1



pragma solidity >=0.6.0 <0.8.0;

/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        uint256 c = a + b;
        if (c < a) return (false, 0);
        return (true, c);
    }

    /**
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b > a) return (false, 0);
        return (true, a - b);
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) return (true, 0);
        uint256 c = a * b;
        if (c / a != b) return (false, 0);
        return (true, c);
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b == 0) return (false, 0);
        return (true, a / b);
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b == 0) return (false, 0);
        return (true, a % b);
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
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
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
        require(b <= a, "SafeMath: subtraction overflow");
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
        if (a == 0) return 0;
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
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
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: division by zero");
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
        require(b > 0, "SafeMath: modulo by zero");
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
        require(b <= a, errorMessage);
        return a - b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryDiv}.
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
        require(b > 0, errorMessage);
        return a / b;
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
        require(b > 0, errorMessage);
        return a % b;
    }
}


// File @openzeppelin/contracts/token/ERC20/IERC20.sol@v3.4.1



pragma solidity >=0.6.0 <0.8.0;

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
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

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


// File @openzeppelin/contracts/utils/Address.sol@v3.4.1



pragma solidity >=0.6.2 <0.8.0;

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
        // solhint-disable-next-line no-inline-assembly
        assembly { size := extcodesize(account) }
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

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain`call` is an unsafe replacement for a function call: use this
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
    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
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
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{ value: value }(data);
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
    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
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
    function functionDelegateCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) private pure returns(bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                // solhint-disable-next-line no-inline-assembly
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


// File @openzeppelin/contracts/proxy/Initializable.sol@v3.4.1



// solhint-disable-next-line compiler-version
pragma solidity >=0.4.24 <0.8.0;

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since a proxied contract can't have a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 *
 * TIP: To avoid leaving the proxy in an uninitialized state, the initializer function should be called as early as
 * possible by providing the encoded function call as the `_data` argument to {UpgradeableProxy-constructor}.
 *
 * CAUTION: When used with inheritance, manual care must be taken to not invoke a parent initializer twice, or to ensure
 * that all initializers are idempotent. This is not verified automatically as constructors are by Solidity.
 */
abstract contract Initializable {

    /**
     * @dev Indicates that the contract has been initialized.
     */
    bool private _initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private _initializing;

    /**
     * @dev Modifier to protect an initializer function from being invoked twice.
     */
    modifier initializer() {
        require(_initializing || _isConstructor() || !_initialized, "Initializable: contract is already initialized");

        bool isTopLevelCall = !_initializing;
        if (isTopLevelCall) {
            _initializing = true;
            _initialized = true;
        }

        _;

        if (isTopLevelCall) {
            _initializing = false;
        }
    }

    /// @dev Returns true if and only if the function is running in the constructor
    function _isConstructor() private view returns (bool) {
        return !Address.isContract(address(this));
    }
}


// File contracts/libraries/DateTimeLibrary.sol



pragma solidity ^0.6.0;

library DateTimeLibrary {
	uint256 constant SECONDS_PER_DAY = 24 * 60 * 60;
	uint256 constant SECONDS_PER_HOUR = 60 * 60;
	uint256 constant SECONDS_PER_MINUTE = 60;

	function getHour(uint256 timestamp) internal pure returns (uint256 hour) {
		uint256 secs = timestamp % SECONDS_PER_DAY;
		hour = secs / SECONDS_PER_HOUR;
	}

	function getMinute(uint256 timestamp) internal pure returns (uint256 minute) {
		uint256 secs = timestamp % SECONDS_PER_HOUR;
		minute = secs / SECONDS_PER_MINUTE;
	}

	function getSecond(uint256 timestamp) internal pure returns (uint256 second) {
		second = timestamp % SECONDS_PER_MINUTE;
	}
}


// File contracts/LotteryOwnable.sol



pragma solidity 0.6.12;

contract LotteryOwnable {
	address private _owner;

	event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

	/**
	 * @dev Initializes the contract setting the deployer as the initial owner.
	 */
	constructor() internal {}

	function initOwner(address owner) internal {
		_owner = owner;
		emit OwnershipTransferred(address(0), owner);
	}

	/**
	 * @dev Returns the address of the current owner.
	 */
	function owner() public view returns (address) {
		return _owner;
	}

	/**
	 * @dev Throws if called by any account other than the owner.
	 */
	modifier onlyOwner() {
		require(_owner == msg.sender, "Ownable: caller is not the owner");
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
		emit OwnershipTransferred(_owner, address(0));
		_owner = address(0);
	}

	/**
	 * @dev Transfers ownership of the contract to a new account (`newOwner`).
	 * Can only be called by the current owner.
	 */
	function transferOwnership(address newOwner) public virtual onlyOwner {
		require(newOwner != address(0), "Ownable: new owner is the zero address");
		emit OwnershipTransferred(_owner, newOwner);
		_owner = newOwner;
	}
}


// File contracts/DoubleMoonLottery.sol



pragma solidity ^0.6.0;

// import "hardhat/console.sol";






interface ILotteryMigrator {
	function getMigratePlayer(uint start, uint end) external returns (address[] memory, uint256[] memory);
}

contract DoubleMoonLottery is Context, LotteryOwnable, Initializable {
	using SafeMath for uint256;

	struct PlayerInfo {
		uint256 ticket;
		uint256 index;
		bool exists;
	}

	struct History {
		address winner;
		uint256 reward;
	}

	IERC20 public token;
	address public adminAddress;
	address public commuAddress;
	address public burnAddress;

	uint256 public sumReward;
	mapping(address => uint256) public playerRewards;
	mapping(uint256 => History) public historyWinners;
	mapping(address => PlayerInfo) public playerInfos;
	address[] public playerAddressIdxes;

	uint256 public rewardPercent;
	uint256 public burnPercent;
	uint256 public commuPercent;
	uint256 public tokenPerTicket;
	uint256 public minHolderToken;

	uint256 public maxBuyTicket;
	uint256 public roundNumber;

	bool public buyEnabled;
	bool public drawingPhase;

	ILotteryMigrator public migrator;

	event BuyTicket(address buyer, uint256 token);
	event Draw(address winner, uint256 reward);
	event Claim(address player, uint256 reward);
	event WithdrawTicket(address player, uint256 amount);
	event RefundTicket(address sender, uint256 amount);
	event EmergencyWithdraw(address receiver, uint256 amount);
	event FilterTimeUpdated(bool enabled);
	event BuyEnabledUpdated(bool enabled);

	modifier onlyAdmin() {
		require(msg.sender == adminAddress, "admin: wut?");
		_;
	}

	constructor() public {}

	function initialize(
		address _tokenAddress,
		address _commuAddress,
		address _adminAddress,
		uint256 _tokenPerTicket,
		uint256 _minHolderToken
	) public initializer {
		token = IERC20(_tokenAddress);
		commuAddress = _commuAddress;
		adminAddress = _adminAddress;
		burnAddress = address(1);
		maxBuyTicket = 50;
		rewardPercent = 6;
		burnPercent = 8;
		commuPercent = 2;
		tokenPerTicket = _tokenPerTicket;
		minHolderToken = _minHolderToken;
		roundNumber = 1;
		buyEnabled = true;

		initOwner(_msgSender());
	}

	function buyTicket(uint256 _amount) external {
		require(!drawingPhase, 'Drawing, can not buy now');
		require(buyEnabled, "Buy ticket is not enabled");
		require(_amount > 0, "Invalid ticket amount");
		require(maxBuyTicket >= _amount, "Over max buy ticket");
		uint256 ticketAmount = tokenPerTicket.mul(_amount);
		require(
			token.balanceOf(_msgSender()) >= ticketAmount,
			"Balance is not enough"
		);

		token.transferFrom(_msgSender(), address(this), ticketAmount);
		_addPlayer(_msgSender(), _amount);

		emit BuyTicket(_msgSender(), ticketAmount);
	}

	function totalReward() public view returns (uint256 reward) {
		uint256 totalTicketAmount = tokenPerTicket.mul(totalTicket());
		uint256 avaiableAmount = token.balanceOf(address(this)) - (sumReward.add(totalTicketAmount));
		uint256 rewardAmount = totalTicketAmount.mul(rewardPercent).div(10**2);
		reward = rewardAmount + avaiableAmount;
	}

	function enterDrawingPhase() external onlyAdmin {
        drawingPhase = true;
    }

	function drawing(address _randomAddress) external onlyAdmin {
		require(drawingPhase, 'Can not drawing');

		roundNumber++;
		uint256 _reward = totalReward();
		require(token.balanceOf(address(this)) >= _reward, "Total reward greater then balance");

		if (_reward == 0 || _randomAddress == address(0)) {
			drawingPhase = false;
			return;
		}

		playerRewards[_randomAddress] = playerRewards[_randomAddress].add(_reward);
		sumReward = sumReward.add(_reward);
		historyWinners[roundNumber - 1] = History(_randomAddress, _reward);

		drawingPhase = false;
		emit Draw(_randomAddress, _reward);
	}

	function claimReward(address player) public {
		uint256 _playerReward = playerRewards[player];
		require(sumReward > 0 && _playerReward > 0, "No reward");

		sumReward = sumReward.sub(_playerReward);
		// Burn
		uint256 burnAmount = _playerReward.mul(burnPercent).div(10**2);
		token.transfer(burnAddress, burnAmount);
		// Commu
		uint256 commuAmount = _playerReward.mul(commuPercent).div(10**2);
		token.transfer(commuAddress, commuAmount);
		// Player
		uint256 _reward =
			_playerReward.sub(
				_playerReward.mul(burnPercent + commuPercent).div(10**2)
			);
		token.transfer(player, _reward);
		playerRewards[player] = 0;
		emit Claim(player, _reward);
	}

	function claimReward() external {
		claimReward(_msgSender());
	}

	function myTicket() public view returns (uint256) {
		return playerInfos[_msgSender()].ticket;
	}

	function withdrawTicket(uint256 _amount) external {
		require(!drawingPhase, 'Drawing, can not buy now');
		require(tokenPerTicket > 0, "Invalid token per tickmet amount");
		require(rewardPercent >= 0, "Invalid percent reward");

		PlayerInfo storage withdrawPlayer = playerInfos[_msgSender()];
		require(withdrawPlayer.exists, "Player does not exist");
		require(withdrawPlayer.ticket >= _amount, "Invalid withdraw amount");

		withdrawPlayer.ticket -= _amount;
		if (withdrawPlayer.ticket <= 0) {
			_deletePlayer(_msgSender());
		}
		uint256 _tokenAmount = tokenPerTicket.mul(_amount);
		uint256 _playerAmount = _tokenAmount.sub((_tokenAmount).mul(rewardPercent).div(10**2));

		require(_playerAmount > 0, "Withdraw zero");
		token.transfer(_msgSender(), _playerAmount);
		emit WithdrawTicket(_msgSender(), _playerAmount);
	}

	function refundTicketAll() external onlyAdmin {
		require(playerAddressIdxes.length > 0, "No players refund");
		require(tokenPerTicket > 0, "Invalid token per tickmet amount");

		uint256 _playerAmount;
		for (uint256 i = 0; i < playerAddressIdxes.length; i++) {
			address _refundAddress = playerAddressIdxes[i];
			PlayerInfo memory _refundPlayer = playerInfos[_refundAddress];
			if (_refundPlayer.ticket > 0) {
				_playerAmount = (tokenPerTicket.mul(_refundPlayer.ticket)).sub(
					_refundPlayer.ticket.mul(tokenPerTicket).mul(rewardPercent).div(10**2)
				);
				token.transfer(_refundAddress, _playerAmount);
			}
			delete playerInfos[_refundAddress];
		}
		emit RefundTicket(_msgSender(), playerAddressIdxes.length);
		delete playerAddressIdxes;
	}

	function _addPlayer(address _player, uint256 _ticket) internal returns (bool) {
		// if user exists, add ticket
		if (playerInfos[_player].exists == true) {
			playerInfos[_player].ticket += _ticket;
		} else {
			// else its new user
			playerAddressIdxes.push(_player);
			playerInfos[_player].ticket = _ticket;
			playerInfos[_player].index = playerAddressIdxes.length - 1;
			playerInfos[_player].exists = true;
		}
		return true;
	}

	function _deletePlayer(address _player) internal returns (bool) {
		// if address exists
		if (playerInfos[_player].exists) {
			PlayerInfo memory deletedUser = playerInfos[_player];
			// if index is not the last entry
			if (deletedUser.index != playerAddressIdxes.length - 1) {
				// last playerInfos
				address lastAddress = playerAddressIdxes[playerAddressIdxes.length - 1];
				playerAddressIdxes[deletedUser.index] = lastAddress;
				playerInfos[lastAddress].index = deletedUser.index;
			}
			delete playerInfos[_player];
			playerAddressIdxes.pop();
			return true;
		}
	}

	function totalTicket() public view returns (uint256) {
		uint256 _total = 0;
		for (uint256 i = 0; i < playerAddressIdxes.length; i++) {
			_total += playerInfos[playerAddressIdxes[i]].ticket;
		}
		return _total;
	}

	function totalPlayer() public view returns (uint256) {
		return playerAddressIdxes.length;
	}

	function migratePlayer(uint start, uint end) external onlyAdmin {
        require(address(migrator) != address(0), "migrate: no migrator");
		uint length = end - start;
		address[] memory migrateAddress = new address[](length);
		uint256[] memory migrateTickets = new uint256[](length);
        (migrateAddress, migrateTickets) = migrator.getMigratePlayer(start, end);
		for (uint256 i = 0; i < migrateAddress.length; i++) {
			_addPlayer(migrateAddress[i], migrateTickets[i]);
		}
    }

	function setting(
		uint256 _maxBuyTicket,
		uint256 _rewardPercent,
		uint256 _burnPercent,
		uint256 _commuPercent
	) external onlyAdmin {
		require(_maxBuyTicket > 0, "Invalid max buy ticket");
		require(_rewardPercent >= 0, "Invalid percent reward");
		require(_burnPercent >= 0, "Invalid percent burn");
		require(_commuPercent >= 0, "Invalid percent commu");

		maxBuyTicket = _maxBuyTicket;
		rewardPercent = _rewardPercent;
		burnPercent = _burnPercent;
		commuPercent = _commuPercent;
	}

	function resetPlayerReward(address _player) external onlyAdmin {
		sumReward = sumReward.sub(playerRewards[_player]);
		playerRewards[_player] = 0;
	}

	function setTokenPerTicket(uint256 _tokenPerTicket) external onlyAdmin {
		require(_tokenPerTicket > 0, "Invalid token per ticket");
		tokenPerTicket = _tokenPerTicket;
	}

	function setMinHolderToken(uint256 _minHolderToken) external onlyAdmin {
		require(_minHolderToken >= 0, "Invalid min holder token");
		minHolderToken = _minHolderToken;
	}

	function setToken(address _tokenAddress) external onlyAdmin {
		token = IERC20(_tokenAddress);
	}

	function setCommuAddress(address _commuAddress) external onlyAdmin {
		commuAddress = _commuAddress;
	}

	function setBuyEnabled(bool _enabled) external onlyAdmin {
		buyEnabled = _enabled;
		emit BuyEnabledUpdated(_enabled);
	}

	function setRoundNumber(uint256 _roundNumber) public onlyAdmin {
		roundNumber = _roundNumber;
	}

	function setMigrator(ILotteryMigrator _migrator) external onlyAdmin {
        migrator = _migrator;
    }

	function setAdmin(address _adminAddress) public onlyOwner {
		adminAddress = _adminAddress;
	}

	// EMERGENCY ONLY.
	function emergencyWithdraw(uint256 _amount) external onlyAdmin {
		require(token.balanceOf(address(this)) >= _amount, "Balance is not enough");
		require(token.transfer(_msgSender(), _amount));
		emit EmergencyWithdraw(_msgSender(), _amount);
	}
}