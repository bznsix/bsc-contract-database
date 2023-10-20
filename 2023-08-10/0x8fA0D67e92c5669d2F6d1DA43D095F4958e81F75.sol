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
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract RandomNumberGenerator is Ownable {
    uint256 public totalbotprofits;
    uint256 private randomNumber;
    uint256[] public last30RandomNumbers;
    uint256 public usersTotalAvailableEarnings;
    uint256 public DepositedCurrentTotal;
    uint256 public AllTimeTotalDeposited;
    uint256 public penaltySeconds;
    uint256 public penaltyPercentage;
    uint256[] public BotsTotalProfitsMoneyArray;
    uint256 public usersCurrentDailyEarnings;
    uint256 public usersAllTimeEarnings;

    address public tokenAddress = 0x55d398326f99059fF775485246999027B3197955;
    
    mapping(address => uint256) public tokenTotalDepositLimit; // Mapping to store the total deposit limit for each token
    mapping(address => uint256) public tokenAllTimeDeposited; // Mapping to store the all-time deposited amount of each token  
    mapping(address => uint256) public UserTotalDepositsWithdrawn; // Mapping to store total deposits withdrawn by each user
    mapping(address => uint256) public usersTotalEarningsWithdrawn;
    mapping(address => uint256) public UsersAllTimeEarnings; // Mapping to store users' all-time earnings
    mapping(address => uint256) public userPenaltyEndTimes; // Mapping to store penalty end times for each user
    mapping(address => mapping(address => uint256)) public tokenBalances; // Mapping to store token balances for each user
    mapping(address => bool) public supportedTokens; // Mapping to track supported tokens
    mapping(address => uint256) public UsersAllTimeDeposited;
    address[] public supportedTokenList; // List of supported tokens

    event Deposit(address indexed user, uint256 amount, uint256 timestamp);
    event Withdraw(address indexed user, uint256 amount, uint256 timestamp);
    event PenaltyPercentageChanged(uint256 newPenaltyPercentage);
    event PenaltySecondsChanged(uint256 newPenaltySeconds);
    event TokenAdded(address indexed token);
    event TokenRemoved(address indexed token);
    event OwnerWithdraw(address indexed token, uint256 amount);

    constructor(uint256 _penaltySeconds, uint256 _penaltyPercentage) {
        penaltySeconds = _penaltySeconds;
        penaltyPercentage = _penaltyPercentage;
        tokenAddress = 0x55d398326f99059fF775485246999027B3197955; // Store the token address
    }

    function generateRandomNumber() external onlyOwner {
        // Generate the random number
        randomNumber = uint256(keccak256(abi.encodePacked(block.difficulty, block.timestamp)));

        // Map the random number to the desired range (0.232 to 0.292)
        uint256 randomNumberMapped = (randomNumber % 601 + 232) * (1000 / 1000);

        // Calculate users' daily earnings based on their total deposited amount
        for (uint256 i = 0; i < depositRecords.length; i++) {
            DepositRecord storage record = depositRecords[i];
            uint256 userEarnings = (record.amount / 100) * randomNumberMapped;
            record.usersDailyEarnings += userEarnings;
            usersTotalAvailableEarnings += userEarnings;

            // Update the users' all-time earnings
            UsersAllTimeEarnings[record.user] += userEarnings;
        }

        // Update the totalbotprofits by adding the new random number
        totalbotprofits += randomNumberMapped;

        // Store the generated random number in the last30RandomNumbers array
        last30RandomNumbers.push(randomNumberMapped);

        // If there are more than 30 random numbers, remove the oldest one
        if (last30RandomNumbers.length > 30) {
            last30RandomNumbers.pop();
        }

        // Multiply the current total deposited amount by the random number divided by 100
        uint256 multipliedAmount = DepositedCurrentTotal * randomNumberMapped / 100;
        BotsTotalProfitsMoneyArray.push(multipliedAmount);
    }

    function convertEarningsToDeposit() external {
        uint256 availableEarnings = usersTotalAvailableEarnings;
        require(availableEarnings > 0, "No earnings available for conversion.");

        // Add the available earnings to the user's total deposited amount
        UserTotalDepositsWithdrawn[msg.sender] += availableEarnings;

        // Reset the available earnings to zero
        usersTotalAvailableEarnings = 0;

        // Update the user's all-time deposited amount
        UsersAllTimeDeposited[msg.sender] += availableEarnings;

        emit Deposit(msg.sender, availableEarnings, block.timestamp);
    }


        // Function to set the total deposit limit for a specific token
    function setTotalDepositLimit(address token, uint256 limit) external onlyOwner {
        require(supportedTokens[token], "Token not supported.");
        tokenTotalDepositLimit[token] = limit;
    }

    // Function to change the total deposit limit for a specific token
    function changeTotalDepositLimit(address token, uint256 newLimit) external onlyOwner {
        require(supportedTokens[token], "Token not supported.");
        tokenTotalDepositLimit[token] = newLimit;
    }

    function BotsTotalProfitMoney() external view returns (uint256) {
        uint256 totalProfit = 0;
        for (uint256 i = 0; i < BotsTotalProfitsMoneyArray.length; i++) {
            totalProfit += BotsTotalProfitsMoneyArray[i];
        }
        return totalProfit;
    }

    struct DepositRecord {
        address user;
        uint256 amount;
        uint256 timestamp;
        uint256 usersDailyEarnings;
    }

    DepositRecord[] private depositRecords;

    function deposit(uint256 _amount, address _token) external {
        require(_amount > 0, "Amount must be greater than zero.");
        require(supportedTokens[_token], "Token not supported.");
        require(tokenBalances[msg.sender][_token] + _amount <= tokenTotalDepositLimit[_token], "Exceeds total deposit limit for this token.");

        IERC20 token = IERC20(_token); // TOKEN TO SEND
        require(token.transferFrom(msg.sender, address(this), _amount), "Token transfer failed. Please approve the contract to spend the token.");

        depositRecords.push(DepositRecord(msg.sender, _amount, block.timestamp, 0));
        DepositedCurrentTotal += _amount;
        AllTimeTotalDeposited += _amount;
        tokenBalances[msg.sender][_token] += _amount;

        // Set the penalty end time for the user
        userPenaltyEndTimes[msg.sender] = block.timestamp + penaltySeconds;

        // Update the user's all-time deposited amount
        UsersAllTimeDeposited[msg.sender] += _amount;

        // Update the token's all-time deposited amount
        tokenAllTimeDeposited[_token] += _amount;

        emit Deposit(msg.sender, _amount, block.timestamp);
    }

 function withdraw() external {
        uint256 userTotalDeposited = getUserTotalDeposited(msg.sender);
        require(userTotalDeposited > 0, "No deposits found for the user.");

        // Check if the penalty period has ended
        if (block.timestamp < userPenaltyEndTimes[msg.sender]) {
            // Penalty period is still active
            uint256 penaltyAmount = (userTotalDeposited * penaltyPercentage) / 100;
            uint256 withdrawalAmount = userTotalDeposited - penaltyAmount;

            // Deduct the penalty amount from the user's total deposited amount
            for (uint256 i = 0; i < depositRecords.length; i++) {
                if (depositRecords[i].user == msg.sender) {
                    depositRecords[i].amount -= penaltyAmount;
                    DepositedCurrentTotal -= penaltyAmount;
                    break;
                }
            }

            // Update the total deposits withdrawn by the user, including penalties
            UserTotalDepositsWithdrawn[msg.sender] += withdrawalAmount;

            // Transfer the withdrawal amount (after penalty deduction) to the user
            IERC20 token = IERC20(tokenAddress);
            require(token.transfer(msg.sender, withdrawalAmount), "Token transfer failed.");

            // Reset the user's total deposited amount to zero
            for (uint256 i = 0; i < depositRecords.length; i++) {
                if (depositRecords[i].user == msg.sender) {
                    DepositedCurrentTotal -= depositRecords[i].amount;
                    depositRecords[i].amount = 0;
                    break;
                }
            }

            emit Withdraw(msg.sender, withdrawalAmount, block.timestamp);
        } else {
            // Penalty period has ended, user can withdraw the full amount
            IERC20 token = IERC20(tokenAddress);
            require(token.transfer(msg.sender, userTotalDeposited), "Token transfer failed.");

            // Update the total deposits withdrawn by the user, excluding penalties
            UserTotalDepositsWithdrawn[msg.sender] += userTotalDeposited;

            // Reset the user's total deposited amount to zero
            for (uint256 i = 0; i < depositRecords.length; i++) {
                if (depositRecords[i].user == msg.sender) {
                    DepositedCurrentTotal -= depositRecords[i].amount;
                    depositRecords[i].amount = 0;
                    break;
                }
            }

            emit Withdraw(msg.sender, userTotalDeposited, block.timestamp);
        }
    }

function withdrawEarnings() external {
    uint256 availableEarnings = usersTotalAvailableEarnings;
    require(availableEarnings > 0, "No earnings available for withdrawal.");

    // Record the total earnings withdrawn by the user
    usersTotalEarningsWithdrawn[msg.sender] += availableEarnings;

    // Reset the usersTotalAvailableEarnings to zero
    usersTotalAvailableEarnings = 0;

    // Transfer the earnings to the user
    IERC20 token = IERC20(tokenAddress);
    require(token.transfer(msg.sender, availableEarnings), "Token transfer failed.");

    emit Withdraw(msg.sender, availableEarnings, block.timestamp);
}

    function getUserTotalDeposited(address user) public view returns (uint256) {
        uint256 totalDeposited = 0;
        for (uint256 i = 0; i < depositRecords.length; i++) {
            if (depositRecords[i].user == user) {
                totalDeposited += depositRecords[i].amount;
            }
        }
        return totalDeposited;
    }

    function getUserAddress(uint256 index) external view returns (address) {
        require(index < depositRecords.length, "Invalid index.");
        return depositRecords[index].user;
    }

    function getUserLastDepositedTime(address user) public view returns (uint256) {
        uint256 lastDepositedTime = 0;
        for (uint256 i = depositRecords.length - 1; i >= 0; i--) {
            if (depositRecords[i].user == user) {
                lastDepositedTime = depositRecords[i].timestamp;
                break;
            }
        }
        return lastDepositedTime;
    }

    function getUserCurrentDailyEarnings(address user) external view returns (uint256) {
        for (uint256 i = 0; i < depositRecords.length; i++) {
            if (depositRecords[i].user == user) {
                return depositRecords[i].usersDailyEarnings;
            }
        }
        return 0;
    }

    function getUsersTotalAvailableEarnings() external view returns (uint256) {
        return usersTotalAvailableEarnings;
    }

    function getContractData() external view returns (uint256, uint256, uint256, uint256) {
        return (totalbotprofits, randomNumber, penaltySeconds, penaltyPercentage);
    }

    function UserPenaltySecondsLeft(address user) external view returns (uint256) {
        if (userPenaltyEndTimes[user] > block.timestamp) {
            return userPenaltyEndTimes[user] - block.timestamp;
        }
        return 0;
    }

    function setPenaltySeconds(uint256 _penaltySeconds) external onlyOwner {
        penaltySeconds = _penaltySeconds;
        emit PenaltySecondsChanged(_penaltySeconds);
    }

    function setPenaltyPercentage(uint256 _penaltyPercentage) external onlyOwner {
        penaltyPercentage = _penaltyPercentage;
        emit PenaltyPercentageChanged(_penaltyPercentage);
    }

    function addSupportedToken(address _token) external onlyOwner {
        require(!supportedTokens[_token], "Token already supported.");

        supportedTokens[_token] = true;
        supportedTokenList.push(_token);

        emit TokenAdded(_token);
    }

    function removeSupportedToken(address _token) external onlyOwner {
        require(supportedTokens[_token], "Token not supported.");

        supportedTokens[_token] = false;

        // Remove the token from the supportedTokenList
        for (uint256 i = 0; i < supportedTokenList.length; i++) {
            if (supportedTokenList[i] == _token) {
                if (i < supportedTokenList.length - 1) {
                    supportedTokenList[i] = supportedTokenList[supportedTokenList.length - 1];
                }
                supportedTokenList.pop();
                break;
            }
        }

        emit TokenRemoved(_token);
    }

    function getUserAllTimeDeposited(address user) external view returns (uint256) {
        return UsersAllTimeDeposited[user];
    }

    function getUserAllTimeEarnings(address user) external view returns (uint256) {
        return UsersAllTimeEarnings[user];
    }

    function getSupportedTokens() external view returns (address[] memory) {
        return supportedTokenList;
    }

    function getUserTotalEarningsWithdrawn(address user) external view returns (uint256) {
        return usersTotalEarningsWithdrawn[user];
    }

    function getUserTotalDepositsWithdrawn(address user) external view returns (uint256) {
        return UserTotalDepositsWithdrawn[user];
    }

    function BotAllTimePercentageProfit() external view returns (uint256) {
        return totalbotprofits;
    }

    function getBotAllTimeDeposited(address _token) external view returns (uint256) {
        return tokenAllTimeDeposited[_token];
    }



    // View function to retrieve the total amount of earnings and deposits a user has withdrawn
    function getUserAllTimeWithdrawn(address user) external view returns (uint256) {
        return usersTotalEarningsWithdrawn[user] + UserTotalDepositsWithdrawn[user];
    }

        // View function to retrieve the total amount of earnings and deposits all users have withdrawn
    function getBotAllTimeWithdrawn() external view returns (uint256) {
        uint256 totalWithdrawn = 0;
        for (uint256 i = 0; i < depositRecords.length; i++) {
            totalWithdrawn += depositRecords[i].amount;
        }
        return totalWithdrawn;
    }

       // View function to retrieve the total amount of earnings withdrawn by all users
    function getBotsTotalEarningsWithdrawn() external view returns (uint256) {
        uint256 totalEarningsWithdrawn = 0;
        for (uint256 i = 0; i < depositRecords.length; i++) {
            address user = depositRecords[i].user;
            totalEarningsWithdrawn += usersTotalEarningsWithdrawn[user];
        }
        return totalEarningsWithdrawn;
    }

        // View function to retrieve the total available earnings for all users
    function getBotsTotalAvailableEarnings() external view returns (uint256) {
        uint256 totalAvailableEarnings = 0;
        for (uint256 i = 0; i < depositRecords.length; i++) {
            address user = depositRecords[i].user;
            totalAvailableEarnings += usersTotalAvailableEarnings;
        }
        return totalAvailableEarnings;
    }

        // View function to retrieve the total all-time earnings for all users
    function getBotAllTimeEarnings() external view returns (uint256) {
        uint256 totalAllTimeEarnings = 0;
        for (uint256 i = 0; i < depositRecords.length; i++) {
            address user = depositRecords[i].user;
            totalAllTimeEarnings += usersAllTimeEarnings;
        }
        return totalAllTimeEarnings;
    }

            // View function to retrieve the total current daily earnings for all users
    function getBotCurrentDailyEarnings() external view returns (uint256) {
        uint256 totalCurrentDailyEarnings = 0;
        for (uint256 i = 0; i < depositRecords.length; i++) {
            address user = depositRecords[i].user;
            totalCurrentDailyEarnings += usersCurrentDailyEarnings;
        }
        return totalCurrentDailyEarnings;
    }

             // View function to read the penaltySeconds variable
    function getPenaltySeconds() external view returns (uint256) {
        return penaltySeconds;
    }

    function getCurrentDepositLimit(address token) external view returns (uint256) {
        require(supportedTokens[token], "Token not supported.");
        return tokenTotalDepositLimit[token];
    }

 
    function ownerWithdraw(address _token, uint256 _amount) external onlyOwner {
        IERC20 token = IERC20(_token);
        require(token.transfer(msg.sender, _amount), "Token transfer failed.");

        emit OwnerWithdraw(_token, _amount);
    }
}