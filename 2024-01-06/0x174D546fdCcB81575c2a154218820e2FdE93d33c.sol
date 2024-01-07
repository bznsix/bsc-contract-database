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
pragma solidity ^0.8.16;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

error AlreadyCheckedIn();
error NotQuestTime();
error QuestStarted();
error QuestEnded();
error InvalidTime();
error TransferFailed();

/**
 * @title Quest
 * @dev Quest contract to do quest
 */
contract Quest is Ownable {
    uint256 constant CHECKIN_INTERVAL = 1 days;

    mapping(address => uint256[]) private checkIns;
    /// @dev The start time of the quest
    uint256 public startTime;
    /// @dev The end time of the quest
    uint256 public endTime;
    /// @dev The reward amount of the quest
    uint256 public rewardAmount;
    /// @dev The reward token of the quest
    IERC20 public rewardToken;


    /// @dev Event to emit when the start time is change
    event StartTimeChange(uint256 timestamp);
    /// @dev Event to emit when the end time is change
    event EndTimeChange(uint256 timestamp);
    /// @dev Event to emit when someone checked in
    event CheckedIn(address indexed user, uint256 times, uint256 timestamp);
    /// @dev Event to emit when the reward amount is change
    event RewardAmountChanged(uint256 newRewardAmount);
    /// @dev Event to emit when the reward token is change
    event RewardTokenChanged(address newTokenAddress);


    /**
     * @dev Constructor
     * @param _tokenAddress The address of the ERC20 token used for rewards
     * @param _startTime The start time of the quest
     * @param _endTime The end time of the quest
     */
    constructor(address _tokenAddress, uint256 _startTime, uint256 _endTime) {
        rewardAmount = 5 * 10 ** 18; // 5 tokens as the default reward amount
        rewardToken = IERC20(_tokenAddress);

        if (_endTime == 0) {
            _endTime = type(uint256).max;
        }
        if (_startTime == 0) {
            _startTime = block.timestamp;
        }
        if (_startTime > _endTime || _startTime < block.timestamp) {
            revert InvalidTime();
        }

        startTime = _startTime;
        emit StartTimeChange(_startTime);

        endTime = _endTime;
        emit EndTimeChange(_endTime);
    }

    /**
     * @dev get check in times of the user
     * @param _user The address of the user
     */
    function getCheckInTimes(address _user) public view returns (uint256) {
        return checkIns[_user].length;
    }

    /**
     * @dev get check in history of the user
     * @param _user The address of the user
     */
    function getCheckInHistory(
        address _user
    ) public view returns (uint256[] memory) {
        return checkIns[_user];
    }

    /**
     * @dev get last check in time of the user
     * @param _user The address of the user
     */
    function getLastCheckInTime(address _user) public view returns (uint256) {
        return checkIns[_user][checkIns[_user].length - 1];
    }

    /**
     * @dev Set the start time of the quest
     * @param _startTime The start time of the quest
     */
    function setStartTime(uint256 _startTime) public onlyOwner {
        if (block.timestamp > startTime) {
            revert QuestStarted();
        }

        if (_startTime > endTime || _startTime < block.timestamp) {
            revert InvalidTime();
        }

        startTime = _startTime;
        emit StartTimeChange(_startTime);
    }

    /**
     * @dev Set the end time of the quest
     * @param _endTime The end time of the quest
     */
    function setEndTime(uint256 _endTime) public onlyOwner {
        if (startTime > _endTime || _endTime < block.timestamp) {
            revert InvalidTime();
        }

        endTime = _endTime;
        emit EndTimeChange(_endTime);
    }

    /**
     * @dev Start the quest
     */
    function start() public onlyOwner {
        if (block.timestamp > startTime) {
            revert QuestStarted();
        }

        startTime = block.timestamp;
        emit StartTimeChange(block.timestamp);
    }

    /**
     * @dev End the quest
     */
    function end() public onlyOwner {
        if (block.timestamp < startTime) {
            revert NotQuestTime();
        }

        if (block.timestamp > endTime) {
            revert QuestEnded();
        }

        endTime = block.timestamp;
        emit EndTimeChange(block.timestamp);
    }

    /**
     * @dev Set the reward amount of the quest
     * @param _rewardAmount The reward amount of the quest
     */
    function setRewardAmount(uint256 _rewardAmount) public onlyOwner {
        rewardAmount = _rewardAmount;
        emit RewardAmountChanged(_rewardAmount);
    }

    /**
     * @dev Update the reward token address
     * @param _newTokenAddress The new ERC20 token address
     */
    function updateRewardToken(address _newTokenAddress) public onlyOwner {
        require(_newTokenAddress != address(0), "Token address cannot be zero address.");

        // Updating reward token to new token address
        rewardToken = IERC20(_newTokenAddress);
        emit RewardTokenChanged(_newTokenAddress);
    }


    /**
     * @dev Check in to the quest
     */
    function checkIn() public {
        if (block.timestamp < startTime || block.timestamp > endTime) {
            revert NotQuestTime();
        }

        uint256[] memory checkInInfo = checkIns[msg.sender];

        if (
            checkInInfo.length > 0 &&
            checkInInfo[checkInInfo.length - 1] + CHECKIN_INTERVAL >
            block.timestamp
        ) {
            revert AlreadyCheckedIn();
        }

        checkIns[msg.sender].push(block.timestamp);

        // Transfer the reward to the user
        bool sent = rewardToken.transfer(msg.sender, rewardAmount);
        if (!sent) {
            revert TransferFailed();
        }

        emit CheckedIn(msg.sender, checkInInfo.length, block.timestamp);
    }
}
