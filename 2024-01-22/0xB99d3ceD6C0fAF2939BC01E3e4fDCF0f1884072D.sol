// SPDX-License-Identifier: MIT
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
    event Approval(address indexed owner, address indexed spender, uint256 value);

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
    function allowance(address owner, address spender) external view returns (uint256);

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
    function transferFrom(address from, address to, uint256 value) external returns (bool);
}
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract ClaimErc20 {
    mapping(uint256 => mapping(address => uint256)) public distributees;
    mapping(uint256 => RewardEvent) public rewardEvents;
    uint256 public eventCount;

    struct RewardEvent {
        string description;
        uint256 deadline;
        address rewardToken;
        address distributer;
        bool isEnabled;
    }

    event DistributeesSet(uint256 indexed eventId, address[] distributeeAddresses, uint256[] amounts);
    event DistributerSet(address indexed distributer, address indexed rewardToken);
    event RewardClaimed(address indexed user, uint256 amount);
    event EventCreated(uint256 indexed eventId, address rewardToken, address distributer, uint256 deadline);
    event EventDeadlineUpdated(uint256 indexed eventId, uint256 newDeadline);
    event EventEnabled(uint256 indexed eventId);

    modifier EventExistenceCheck(uint256 _eventId) {
        require(_eventId != 0 && _eventId <= eventCount, "Event not found");
        _;
    }

    modifier EventAccessCheck(uint256 _eventId) {
        require(rewardEvents[_eventId].distributer == msg.sender, "No access to this event");
        _;
    }

    constructor() {}

    function claim(uint _eventId) public EventExistenceCheck(_eventId){
        RewardEvent memory targetEvent = rewardEvents[_eventId];

        require(targetEvent.isEnabled, "Event is not enabled");

        require(block.timestamp < targetEvent.deadline, "The cliam deadline is reached");

        uint256 targetAmount = distributees[_eventId][msg.sender];

        require(targetAmount > 0, "No tokens to claim");

        address targetToken = targetEvent.rewardToken;

        address distributer = targetEvent.distributer;

        distributees[_eventId][msg.sender] = 0;

        require(IERC20(targetToken).transferFrom(distributer, msg.sender, targetAmount), "Transfer failed");

        emit RewardClaimed(msg.sender, targetAmount);
    }

    function setDistributees(uint256 _eventId, address[] memory distributeeAddresses, uint256[] memory amounts) public EventExistenceCheck(_eventId) EventAccessCheck(_eventId) {
        require(distributeeAddresses.length == amounts.length, "Mismatched input lengths");
        for (uint256 i = 0; i < distributeeAddresses.length; i++) {
            distributees[_eventId][distributeeAddresses[i]] = amounts[i];
        }
        emit DistributeesSet(_eventId, distributeeAddresses, amounts);
    }

    function createEvent(address _rewardToken, uint256 _deadline, string memory _description) public {
        require(_deadline > block.timestamp, "Forbidden deadline before current time");
        eventCount += 1;
        RewardEvent storage newEvent = rewardEvents[eventCount];
        newEvent.description = _description;
        newEvent.rewardToken = _rewardToken;
        newEvent.distributer = msg.sender;
        newEvent.deadline = _deadline;
        emit EventCreated(eventCount, newEvent.rewardToken, newEvent.distributer, newEvent.deadline);
    }

    function enableEvent(uint256 _eventId) public EventExistenceCheck(_eventId) EventAccessCheck(_eventId) {
        RewardEvent storage targetEvent = rewardEvents[_eventId];
        require(!targetEvent.isEnabled, "Event is already enabled");
        targetEvent.isEnabled = true;
        emit EventEnabled(_eventId);
    }

    function updateDeadline(uint256 _eventId, uint256 _deadline) public EventExistenceCheck(_eventId) EventAccessCheck(_eventId) {
        require(_deadline > block.timestamp, "Forbidden deadline before current time");
        RewardEvent storage targetEvent = rewardEvents[_eventId];
        targetEvent.deadline = _deadline;
        emit EventDeadlineUpdated(_eventId, targetEvent.deadline);
    }
}