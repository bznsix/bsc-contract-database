// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.4) (utils/Context.sol)

pragma solidity ^0.8.15;

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

    function _contextSuffixLength() internal view virtual returns (uint256) {
        return 0;
    }
}

// OpenZeppelin Contracts (last updated v4.9.0) (access/Ownable.sol)

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

// OpenZeppelin Contracts (last updated v4.9.0) (security/ReentrancyGuard.sol)

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
     * @dev Returns true if the reentrancy guard is currently set to "entered", which indicates there is a
     * `nonReentrant` function in the call stack.
     */
    function _reentrancyGuardEntered() internal view returns (bool) {
        return _status == _ENTERED;
    }
}

interface IERC20 {
    function transfer(address to, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
}

interface IPRNG {
    function getRandomNumberWithLimit(uint256 length) external returns (uint256);
    function isPaused() external view returns (bool);
}

/**
 * @title TwoDice - Simple Dice Rolling Game
 * @notice TwoDice is a decentralized dice game where players bet on the outcome of a roll of two six-sided dice, using 0xGamble (1UCK) tokens. Players can specify a number and choose whether they believe the roll will be over or under that number.
 * @dev The game incorporates a dynamic payout system based on the chosen numbers and the roll's outcome, with several parameters adjustable by the owner. It integrates a pseudo-random number generator for dice rolls and provides a range of player and administrative functions.
 * @author notaraspberrypi
 *
 * NOTE: All betting and payout values are represented and transacted in Wei units (18 decimals).
 * Use https://bscscan.com/unitconverter for convenient unit conversions.
 *
 * **Before Playing:**
 * Players must approve 0xGamble (1UCK) token spending for this contract before placing bets.
 * Go to the 0xGamble (1UCK) contract and approve the required token amount.
 * 
 * **How to Play:**
 * **Place a Bet and Roll:** Call `placeBetAndRoll`, specifying the bet amount, chosen number, and whether it's over or under.
 * **Result and Payout:** After the dice roll, if the bet condition is met (total roll over/under the chosen number), the player wins a payout calculated based on their bet and the corresponding multiplier.
 * **Community Fee:** A portion (COMMUNITY_WALLET_FEE_PERCENTAGE) of losing bets are transferred directly to the community wallet
 * **Dev Fee Parameters:** Any frontend dev implementing a UI for this contract may add his wallet address and fee % (max FRONTEND_MAX_FEE_PERCENTAGE) to get a portion of all losing bets. When calling the contract directly, use the null address (0x0000000000000000000000000000000000000000) and a feePercentage of 0.
 * **Payout Multipliers:**
 * 
 * ### Over
 * | Chosen Number | Multiplier |
 * | 2             | 1.01x      |
 * | 3             | 1.07x      |
 * | 4             | 1.18x      |
 * | 5             | 1.36x      |
 * | 6             | 1.68x      |
 * | 7             | 2.35x      |
 * | 8             | 3.53x      |
 * | 9             | 5.88x      |
 * | 10            | 11.8x      |
 * | 11            | 35.3x      |
 * ### Under
 * | Chosen Number | Multiplier |
 * | 12            | 1.01x      |
 * | 11            | 1.07x      |
 * | 10            | 1.18x      |
 * | 9             | 1.36x      |
 * | 8             | 1.68x      |
 * | 7             | 2.35x      |
 * | 6             | 3.53x      |
 * | 5             | 5.88x      |
 * | 4             | 11.8x      |
 * | 3             | 35.3x      |
 * 
 * **Parameters:**
 * - `multipliersOver`: Payout multipliers for when the player bets on "over."
 * - `multipliersUnder`: Payout multipliers for when the player bets on "under."
 * - `communityWalletAddress`: Address of the community wallet where a portion of the tokens from losing bets is sent.
 * 
 * **User Functions:**
 * - `placeBetAndRoll`: Allows users to place a bet, specifying the bet amount, chosen number, over/under, and additional fee parameters for rewarding the frontend developer
 * 
 * **Owner Functions:**
 * - `withdrawFromHouseBank`: Withdraw tokens from the house bank by the owner. Note: The owner can withdraw all tokens from the house bank at any time e.g. when an updated contract needs to be deployed
 * - `setCommunityWalletAddress`: Set a new community wallet address where a portion of losing bets are sent and any token donations are sent.
 * - `withdrawRandomTokens`: Withdraw random tokens sent to the contract to the community wallet address.
 * - `receive`: Handle BNB sent to the contract address and send it to the community wallet address.
 *
 * **View Functions:**
 * - `getMaxBet`: Calculate the maximum bet based on the house bank balance and max payout.
 * - `getHouseBankBalance`: Get the current balance of the house bank.
 * 
 * **Public Variables:**
 * - `name`: Returns the name of the game.
 * - `description`: Returns the description of the game.
 * - `version`: Returns the version of the game.
 * - `gambleTokenAddress`: Address of the 0xGamble (1UCK) token contract.
 * - `prngAddress`: Address of the pseudo-random number generator contract.
 * - `communityWalletAddress`: Address of the community wallet.
 *
 * **Events:**
 * - `BetPlaced`: Emitted when a user places a bet.
 * - `DiceRolled`: Emitted when dice are rolled, indicating the result.
 * - `GameResult`: Emitted when a game is concluded, showing the player, win/loss, and payout.
 * - `TokensWithdrawn`: Emitted when tokens are withdrawn from the house bank.
 *
 *  Good 1UCK!
 */

contract TwoDice is Ownable, ReentrancyGuard {
    // Metadata
    string public  name = "TwoDice";
    string public description = "Simple dice game for 0xGamble (1UCK).";
    string public version = "1.0.1";

    // External contracts
    address public gambleTokenAddress;
    address public prngAddress;

    // 0xGamble token community wallet
    address public communityWalletAddress;

    // The minimum bet is initially set to one 1uck token or 1'000'000'000'000'000'000 Wei
    uint256 public minBetAmount = 1000000000000000000;

    // Constants
    uint256 private constant FRONTEND_MAX_FEE_PERCENTAGE = 5; // The maximum fee the frontend dev can set when playing the game
    uint256 private constant COMMUNITY_WALLET_FEE_PERCENTAGE = 5; // The percentage fee for losing bets that go to the community wallet
    uint256 private constant MAX_PAYOUT_PERCENT = 30; // The maximum possible payout in % of the house bank (30%)
    uint256 private constant MAX_MULTIPLIER = 353; // The maximum possible payout multiplier for calculating the max bet (35.3x)

    // Payout multipliers for OVER and UNDER scenarios
    mapping(uint256 => uint256) private multipliersOver;
    mapping(uint256 => uint256) private multipliersUnder;

    // Events
    event BetPlaced(address indexed player, uint256 betAmount, uint8 chosenNumber, bool isOver);
    event DiceRolled(address indexed player, uint256 die1, uint256 die2);
    event GameResult(address indexed player, bool win, uint256 payout);
    event TokensWithdrawn(address indexed owner, uint256 amount);

    constructor(address _gambleTokenAddress, address _prngAddress) {
        gambleTokenAddress = _gambleTokenAddress;
        prngAddress = _prngAddress;

        // Initialize multipliers for OVER
        multipliersOver[2] = 101; // 1.01x
        multipliersOver[3] = 107; // 1.07x
        multipliersOver[4] = 118; // 1.18x
        multipliersOver[5] = 136; // 1.36x
        multipliersOver[6] = 168; // 1.68x
        multipliersOver[7] = 235; // 2.35x
        multipliersOver[8] = 353; // 3.53x
        multipliersOver[9] = 588; // 5.88x
        multipliersOver[10] = 1180; // 11.8x
        multipliersOver[11] = 3530; // 35.3x

        // Initialize multipliers for UNDER
        multipliersUnder[12] = 101; // 1.01x
        multipliersUnder[11] = 107; // 1.07x
        multipliersUnder[10] = 118; // 1.18x
        multipliersUnder[9] = 136; // 1.36x
        multipliersUnder[8] = 168; // 1.68x
        multipliersUnder[7] = 235; // 2.35x
        multipliersUnder[6] = 353; // 3.53x
        multipliersUnder[5] = 588; // 5.88x
        multipliersUnder[4] = 1180; // 11.8x
        multipliersUnder[3] = 3530; // 35.3x
    }

    function placeBetAndRoll(uint256 _bet, uint8 _number, bool _isOver, address _feeAddress, uint256 _feePercentage) public nonReentrant {
        require(_isOver ? _number >= 2 && _number <= 11 : _number >= 3 && _number <= 12, "Number not in range. Over:2-11, Under:3-12");
        require(_feePercentage <= FRONTEND_MAX_FEE_PERCENTAGE, "Frontend dev fee percentage is too high");
        require(IERC20(gambleTokenAddress).allowance(msg.sender, address(this)) >= _bet, "Insufficient allowance");
        require(IERC20(gambleTokenAddress).balanceOf(msg.sender) >= _bet, "Insufficient balance");
        require(!IPRNG(prngAddress).isPaused(), "The PRNG contract is paused");
        require(_bet <= getMaxBet(), "Bet amount exceeds max bet. Max possible payout cannot exceed 30% of the house bank");
        require(_bet >= minBetAmount, "Bet amount is below the minimum bet amount");

        // Calculate the maximum possible payout
        uint256 payout = calculatePayout(_bet, _number, _isOver);        

        // Transfer the bet amount to this contract
        require(IERC20(gambleTokenAddress).transferFrom(msg.sender, address(this), _bet), "Failed to transfer bet amount");

        // Roll two d6 dice
        uint256[] memory diceRolls = rollDice();
        uint256 totalRoll = diceRolls[0] + diceRolls[1];

        bool isWin = (_isOver && totalRoll > _number) || (!_isOver && totalRoll < _number);

        if (isWin) {
            // Transfer winnings
            require(IERC20(gambleTokenAddress).transfer(msg.sender, payout), "Failed to transfer winnings");
        } else {
            // Calculate frontend dev fee and send tokens if applicable
            if (_feeAddress != address(0) && _feePercentage != 0) {
                uint256 fee = (_bet * _feePercentage) / 100;
                require(IERC20(gambleTokenAddress).transfer(_feeAddress, fee), "Failed to transfer frontend dev fee");
            }
            // Calculate community wallet fee and send tokens
            if (communityWalletAddress != address(0)) {
                uint256 fee = (_bet * COMMUNITY_WALLET_FEE_PERCENTAGE) / 100;
                require(IERC20(gambleTokenAddress).transfer(communityWalletAddress, fee), "Failed to transfer frontend dev fee");
            }
        }

        emit BetPlaced(msg.sender, _bet, _number, _isOver);
        emit DiceRolled(msg.sender, diceRolls[0], diceRolls[1]);
        emit GameResult(msg.sender, isWin, isWin ? payout : 0);
    }

    // Function to get two random numbers to simulate two d6 dice rolls
    function rollDice() private returns (uint256[] memory) {
        uint256[] memory diceRolls = new uint256[](2);

        // Try to get the first random number
        try IPRNG(prngAddress).getRandomNumberWithLimit(6) returns (uint256 number) {
            diceRolls[0] = number;
        } catch (bytes memory /* error */) {
            revert("PRNG contract error");
        }

        // Try to get the second random number
        try IPRNG(prngAddress).getRandomNumberWithLimit(6) returns (uint256 number) {
            diceRolls[1] = number;
        } catch (bytes memory /* error */) {
            revert("PRNG contract error");
        }

        return diceRolls;
    }

    // Function to calculate payout
    function calculatePayout(uint256 _bet, uint8 _number, bool _isOver) private view returns (uint256) {
        uint256 multiplier = _isOver ? multipliersOver[_number] : multipliersUnder[_number];
        return (_bet * multiplier) / 100;
    }

    function getHouseBankBalance() public view returns (uint256) {
        return IERC20(gambleTokenAddress).balanceOf(address(this));
    }

    function setMinimumBetAmount(uint256 _minBetAmount) public onlyOwner nonReentrant {
        require(_minBetAmount > 0, "The minimum bet amount has to be greater than 0");
        minBetAmount = _minBetAmount;
    }

    // Function to calculate the maximum bet
    function getMaxBet() public view returns (uint256) {
        // Calculate the maximum payout first
        uint256 maxPayout = (IERC20(gambleTokenAddress).balanceOf(address(this)) * MAX_PAYOUT_PERCENT) / 100;

        // The maximum bet is the maximum payout divided by the maximum multiplier
        return maxPayout * 10 / MAX_MULTIPLIER; 
    }

    // Withdraw 1uck tokens from the house bank
    function withdrawFromHouseBank(uint256 _amount) public onlyOwner nonReentrant {
        require(_amount > 0, "Amount must be greater than 0");
        require(_amount <= IERC20(gambleTokenAddress).balanceOf(address(this)), "Not enough excess tokens available");

        require(IERC20(gambleTokenAddress).transfer(msg.sender, _amount), "Failed to transfer tokens");

        emit TokensWithdrawn(msg.sender, _amount);
    }

    // Set the 0xGamble community wallet address - a percentage of all losing bets are sent to this address
    function setCommunityWalletAddress(address _newCommunityWalletAddress) public onlyOwner nonReentrant {
        require(_newCommunityWalletAddress != address(0), "Invalid community wallet address");
        communityWalletAddress = _newCommunityWalletAddress;
    }

    // Handle BNB sent to the contract address - BNB is sent to the community wallet (thank you for your donations)
    // ONLY WORKS FOR NATIVE BNB, NOT WRAPPED TOKENS (WBNB doesn't work)
    receive() external payable nonReentrant {
        require(msg.value > 0, "Amount must be greater than 0");
        (bool success, ) = payable(communityWalletAddress).call{value: msg.value}("");
        require(success, "BNB transfer to community wallet failed");
    }

    // Withdraw random tokens that have been sent to the contract to the community wallet
    function withdrawRandomTokens(address _randomTokenAddress) public onlyOwner nonReentrant {
        require(_randomTokenAddress != gambleTokenAddress, "Cannot withdraw 0xGamble (1UCK) tokens using this method");
        IERC20 randomToken = IERC20(_randomTokenAddress);
        uint256 randomBalance = randomToken.balanceOf(address(this));
        require(randomBalance > 0, "No balance available for the specified token");
        require(randomToken.transfer(communityWalletAddress, randomBalance), "Token transfer failed");
    }
}