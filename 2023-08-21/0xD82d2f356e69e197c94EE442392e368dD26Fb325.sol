// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

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
// SPDX-License-Identifier: MIT
//                                                                          /$$      
//                                                                         | $$      
//     /$$$$$$$  /$$$$$$  /$$  /$$  /$$        /$$$$$$$  /$$$$$$   /$$$$$$$| $$$$$$$ 
//    /$$_____/ /$$__  $$| $$ | $$ | $$       /$$_____/ |____  $$ /$$_____/| $$__  $$
//   | $$      | $$  \ $$| $$ | $$ | $$      | $$        /$$$$$$$|  $$$$$$ | $$  \ $$
//   | $$      | $$  | $$| $$ | $$ | $$      | $$       /$$__  $$ \____  $$| $$  | $$
//   |  $$$$$$$|  $$$$$$/|  $$$$$/$$$$/      |  $$$$$$$|  $$$$$$$ /$$$$$$$/| $$  | $$
//    \_______/ \______/  \_____/\___/        \_______/ \_______/|_______/ |__/  |__/
//   

pragma solidity ^0.8.7;

import "@openzeppelin/contracts/access/Ownable.sol";

error Staking__TransferFailed();
error Staking__NeedsMoreThanZero();
interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function mint(address receiver, uint256 amount) external returns (bool);
}
contract Staking is Ownable {
    IERC20 private s_stakingToken;
    IERC20 private s_rewardToken;

    // address => how much they stake
    mapping(address => uint256) private s_balances;
    // how much each address have been paid already
    mapping(address => uint256) private s_rewards;
    mapping(address => uint256) private lastClock;

    uint256 public  REWARD_RATE = 115740740741; // 1% per day 
    // how many tokens have been sent to the contract
    uint256 private s_totalSupply;
    uint256 private s_lastUpdateTime;

    // MODIFIERS
    modifier updateReward(address account) {
        uint256 pastRewards = s_rewards[account];
        uint256 currentBalance = s_balances[account];
        uint256 _earned = ((currentBalance * REWARD_RATE * (block.timestamp - lastClock[account]) ) / 1e18) + pastRewards;
        lastClock[account] = block.timestamp;
        s_rewards[account] = _earned;
        _;
    }

    modifier moreThanZero(uint256 amount) {
        if (amount == 0) {
            revert Staking__NeedsMoreThanZero();
        }

        _;
    }

    // keeping track of staking token right away when it is deployed
    constructor(address stakingToken, address rewardToken) {
        s_stakingToken = IERC20(stakingToken);
        s_rewardToken = IERC20(rewardToken);
    }


    // do we allow any tokens?❌ =>
    //      can be done using Chainlink to convert between prices of tokens
    // or just a specific tokens?✅
    function stake(
        uint256 amount
    ) external moreThanZero(amount) updateReward(msg.sender) {
        // keep track how much user has staked
        s_balances[msg.sender] += amount;
        // keep track how much token we have in total
        s_totalSupply += amount;
        // transfer the tokens to this contract
        bool success = s_stakingToken.transferFrom(
            msg.sender,
            address(this),
            amount
        );
        if (!success) {
            revert Staking__TransferFailed();
        }

        // emit event
        // emit TokenStaked
    }

    function withdraw(
        uint256 amount
    ) external moreThanZero(amount) updateReward(msg.sender) {
        require(amount <= s_balances[msg.sender], "Staking Balance");
        // keep track how much user has staked
        s_balances[msg.sender] -= amount;
        // keep track how much token we have in total
        s_totalSupply -= amount;
        // transfer the tokens to the user
        bool success = s_stakingToken.transfer(msg.sender, amount);

        if (!success) {
            revert Staking__TransferFailed();
        }

        // emit event
    }

    function claimReward() external updateReward(msg.sender) {

        uint256 reward = s_rewards[msg.sender];

        // reward token is different from staking token
        bool success = s_rewardToken.mint(msg.sender, reward);
        s_rewards[msg.sender] = 0;
        if (!success) {
            revert Staking__TransferFailed();
        }
    }
        //sets the daily ROI
    function setDailyROI(uint _REWARD_RATE) external onlyOwner {
        REWARD_RATE = _REWARD_RATE;
    }
    function getTotalStakedTokens() external view returns (uint256) {
        return s_totalSupply;
    }

    function getStakedAmount(
        address userAddress
    ) external view returns (uint256) {
        return s_balances[userAddress];
    }

    function getReward(address userAddress) external view returns (uint256) {
        uint256 pastRewards = s_rewards[userAddress];
        uint256 currentBalance = s_balances[userAddress];
        uint256 _earned = ((currentBalance * REWARD_RATE * (block.timestamp - lastClock[userAddress]) ) / 1e18) + pastRewards;
        return s_rewards[userAddress] + _earned;
    }

    function getRewardRate() external view returns (uint256) {
        return REWARD_RATE;
    }

    function withdrawToken(address _tokenContract, uint _amount) external onlyOwner returns (bool success) {
        IERC20 tokenContract = IERC20(_tokenContract);
        tokenContract.transfer(msg.sender, _amount);
        return true;
    }
    
    function withdrawNative() external onlyOwner returns (bool success) {
        payable(msg.sender).transfer(address(this).balance);
        return true;
    }
}
