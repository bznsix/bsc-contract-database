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

contract BtcBot is Ownable {
    address public acceptedToken;
    address[] public depositUsers; // List of users who have made deposits
    mapping(address => uint256) public deposits;
    mapping(address => uint256) public usersProfitsTable;
    uint256[30] public last30RandomTable;
    uint256 public randomSeed;
    uint256 private currentIndex;
    uint256[30] public users30DayProfit; // Table to record the 30 most recent entries of user profits
    uint256 private profitIndex; // Index to keep track of the current position in the table
     uint256 public contractBNBBalance; // Balance of BNB held in the contract

    constructor() {
        randomSeed = block.timestamp; // Initial random seed
        currentIndex = 0;
        profitIndex = 0;
    }

    function setAcceptedToken(address _tokenAddress) external onlyOwner {
        acceptedToken = _tokenAddress;
    }

    function deposit(uint256 _amount) external {
        require(acceptedToken != address(0), "Accepted token is not set yet");
        require(_amount > 0, "Amount must be greater than 0");
        
        IERC20 token = IERC20(acceptedToken);
        require(token.allowance(msg.sender, address(this)) >= _amount, "Contract not allowed to spend tokens");
        
        require(token.transferFrom(msg.sender, address(this), _amount), "Token transfer failed");
        
        if (deposits[msg.sender] == 0) {
            depositUsers.push(msg.sender); // Add user to the list if it's their first deposit
        }
        
        deposits[msg.sender] += _amount;
    }

function generate() external onlyOwner {
    // Generate a random number between 0.00255 and 0.00277 using blockhash
    randomSeed = uint256(keccak256(abi.encodePacked(randomSeed, blockhash(block.number - 1))));
    uint256 randomFactor = (randomSeed % 230) + 255; // Range: 0.00255 to 0.00277

    // Update profits for each user based on their deposits
    for (uint256 i = 0; i < depositUsers.length; i++) {
        address user = depositUsers[i];
        uint256 userDeposit = deposits[user];
        uint256 userProfit = (userDeposit * randomFactor) / 100000;
        usersProfitsTable[user] += userProfit;
    }

    // Calculate the sum of the profits from the last 30 days
    uint256 sumProfits = 0;
    for (uint256 j = 0; j < users30DayProfit.length; j++) {
        sumProfits += users30DayProfit[j];
    }

    // Subtract the oldest profit and add the newest profit to the sum
    uint256 userProfit = (deposits[depositUsers[profitIndex]] * randomFactor) / 100000;
    sumProfits = sumProfits - users30DayProfit[profitIndex] + userProfit;

    // Update the users30DayProfit table with the new sum
    users30DayProfit[profitIndex] = sumProfits;
    
    // Update the last30RandomTable with the new random factor
    last30RandomTable[currentIndex] = randomFactor;
    
    // Update the currentIndex for the next iteration
    currentIndex = (currentIndex + 1) % 30;

    // Update the profitIndex for the next iteration
    profitIndex = (profitIndex + 1) % 30;
}


    function getUserProfit(address _user) external view returns (uint256) {
        return usersProfitsTable[_user];
    }

    function getLast30RandomNumbers() external view returns (uint256[30] memory) {
        return last30RandomTable;
    }

    function users30DayView() external view returns (uint256) {
    uint256 sumProfits = 0;
    for (uint256 j = 0; j < users30DayProfit.length; j++) {
        sumProfits += users30DayProfit[j];
    }
    return sumProfits;
    }

    function userWithdrawProfit() external {
        require(acceptedToken != address(0), "Accepted token is not set yet");

        uint256 userProfit = usersProfitsTable[msg.sender];
        require(userProfit > 0, "No profits available for withdrawal");

        usersProfitsTable[msg.sender] = 0; // Reset user's profit balance

        IERC20 token = IERC20(acceptedToken);
        require(token.transfer(msg.sender, userProfit), "Token transfer failed");
    }

// Withdraw function to allow the owner to withdraw any balance (BNB and tokens)
function withdrawAll() external onlyOwner {
    uint256 contractBalance = address(this).balance;
    contractBNBBalance = 0; // Reset the contract BNB balance
    payable(owner()).transfer(contractBalance);

    IERC20 token = IERC20(acceptedToken);
    uint256 tokenBalance = token.balanceOf(address(this));
    if (tokenBalance > 0) {
        token.transfer(owner(), tokenBalance);
    }
}
}