// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

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

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

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


interface IERC20 {
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

}

/**
 * Company: Decrypted Labs
 * @title CiccaStaking Contract
 * @author Rabeeb Aqdas
 * @notice This contract enables users to stake ERC20 tokens, earn rewards based on the staking duration, and withdraw their staked tokens and rewards. 
 * It includes mechanisms for calculating staking rewards, applying penalties for early unstaking, and handling the overall staking process.
 * @dev Enables staking of ERC20 tokens with rewards and penalties.
*/
 
contract CiccaStaking is Ownable, Pausable {

  /// @notice A struct to hold the staking details of a user.
    struct User {
    uint256 amount; // The amount of tokens staked by the user.
    uint256 startTime; // The timestamp when the user started staking.
    uint256 endTime; // The timestamp when the staking period ends.
    uint256 rewardTaken; // The last timestamp when the rewards were taken.
    uint256 rewardToBeWithdrawn; // The amount of reward that is yet to be withdrawn by the user.
    uint256 claimed; // The total amount of rewards claimed by the user.
    }

    /// @dev The ERC20 token used for staking.
    IERC20 private _erc20Helper;

    /// @notice The total number of unique addresses that have staked tokens.
    uint256 public totalStakers;

/// @notice The total amount of tokens currently staked in the contract.
uint256 public totalStakeAmount;

/// @dev The duration of one day in seconds, used for reward calculations.
uint256 private constant ONEDAY = 86400;

/// @dev The base value for percentage calculations.
uint256 private constant BASE = 100;

/// @dev The penalty percentage applied to early unstaking.
uint256 private constant PENALTY = 25;

/// @notice A mapping to store the staking information of each user.
/// @dev Maps a user's address to their `User` struct, holding their staking details.
mapping (address => User) private userInfo;

/// @notice Emitted when a user stakes tokens.
/// @param by The address of the user who staked tokens.
/// @param amount The amount of tokens staked.
/// @param timeStamp The timestamp when the staking occurred.
event Staked(address indexed by, uint256 amount, uint256 timeStamp);

/// @notice Emitted when a user unstakes their tokens.
/// @param by The address of the user who unstaked tokens.
/// @param amount The amount of tokens unstaked.
/// @param timeStamp The timestamp when the unstaking occurred.
event UnStaked(address indexed by, uint256 amount, uint256 timeStamp);

/// @notice Emitted when a user withdraws their staking rewards.
/// @param by The address of the user who withdrew rewards.
/// @param amount The amount of rewards withdrawn.
/// @param timeStamp The timestamp when the withdrawal occurred.
event Withdrawn(address indexed by, uint256 amount, uint256 timeStamp);

    /// @notice Constructor to initialize the staking contract.
    /// @param _tokenAddress The address of the ERC20 token to be staked.
    constructor(address _tokenAddress) Ownable(_msgSender()) {
        _erc20Helper = IERC20(_tokenAddress);
    }

    /// @notice Allows users to stake their tokens.
    /// @dev Stakes `_amount` of tokens for the sender and updates staking information.
    /// @param _amount The amount of tokens to stake.
    function stake(uint256 _amount)
        external
        whenNotPaused
    {
        require(_amount > 99e18 , "Minimum Staking is 100");
        User memory _user = userInfo[_msgSender()];
        if(_user.amount > 0) {
            uint256 _reward = calculateReward(_msgSender());    
           _user.rewardToBeWithdrawn = _user.rewardToBeWithdrawn + _reward;
        }
        _erc20Helper.transferFrom(_msgSender(), address(this), _amount);     
        _user.amount = _user.amount + _amount;
        _user.startTime = block.timestamp;
        _user.rewardTaken = block.timestamp;
        _user.endTime = block.timestamp + 180 days; 
        userInfo[_msgSender()] = _user;
        totalStakers += 1;
        totalStakeAmount += _amount;
      emit Staked(_msgSender(), _amount, block.timestamp);
    }

    /// @notice Allows users to unstake their tokens.
    /// @dev Unstakes all staked tokens for the sender and applies penalties if applicable.
    function unstake() external whenNotPaused {
        address _sender = _msgSender();
        User memory _user = userInfo[_sender];
        require(_user.amount > 0, "Staking Not Found");  
        uint256 userAmount = _user.amount;
        uint256 amountToBeGiven = _user.endTime > block.timestamp ? (userAmount - (userAmount * PENALTY / BASE)) : userAmount;
        uint256 reward = calculateReward(_sender);
        _user.amount = 0;
        _user.startTime = 0;    
        _user.endTime = 0;    
        _user.rewardTaken = 0;
        _user.rewardToBeWithdrawn = _user.rewardToBeWithdrawn + reward;
        userInfo[_sender] = _user; 
        totalStakers = totalStakers - 1;
        totalStakeAmount = totalStakeAmount - userAmount;
        _erc20Helper.transfer(_sender, amountToBeGiven);       
        emit UnStaked(_sender, amountToBeGiven, block.timestamp);

    }

    /// @notice Allows users to withdraw their earned rewards.
    /// @dev Withdraws all available rewards for the sender.
    function withdrawReward() external whenNotPaused {
        address _sender = _msgSender();
        User memory _user = userInfo[_sender];
        require(_user.amount > 0 || _user.rewardToBeWithdrawn > 0, "No Reward Available"); 
        uint256 reward = calculateReward(_sender);
        uint256 totalReward = _user.rewardToBeWithdrawn + reward;
        _user.rewardToBeWithdrawn = 0;
        _user.rewardTaken = block.timestamp;    
        _user.claimed = _user.claimed + totalReward;
        userInfo[_sender] = _user;
        _erc20Helper.transfer(_sender, totalReward);    
        emit Withdrawn(_sender, totalReward, block.timestamp);       
    }

    /// @notice Calculates the reward for a given user.
    /// @dev Returns the calculated reward based on staked amount and time.
    /// @param _user The address of the user.
    /// @return _reward The calculated reward amount.
    function calculateReward(address _user)
        public
        view
        returns (uint256 _reward)
    {
        User memory _userInfo = userInfo[_user];
        if(_userInfo.amount > 0) {
        uint256 onePercent = (_userInfo.amount / BASE) / ONEDAY;
        uint256 _noOfSec = block.timestamp > _userInfo.endTime ? (_userInfo.endTime - _userInfo.rewardTaken) : block.timestamp - _userInfo.rewardTaken;
        _reward = _noOfSec * onePercent;
        }else {
            _reward = 0;
        }

    }

    /// @notice Provides the staking details of a given user.
    /// @dev Returns the staking information for `_user`.
    /// @param _user The address of the user to query.
    /// @return amount
    /// @return startTime
    /// @return endTime
    /// @return rewardTaken
    /// @return rewardToBeWithdrawn
    /// @return claimed
    function getDetails(address _user) external view returns (
        uint256 amount,
        uint256 startTime,      
        uint256 endTime,      
        uint256 rewardTaken,       
        uint256 rewardToBeWithdrawn,
        uint256 claimed) {
        User memory _userInfo = userInfo[_user];
        amount = _userInfo.amount;
        startTime = _userInfo.startTime;
        endTime = _userInfo.endTime;
        rewardTaken = _userInfo.rewardTaken;
        rewardToBeWithdrawn = _userInfo.rewardToBeWithdrawn;
        claimed = _userInfo.claimed;
    }
}