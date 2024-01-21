pragma solidity ^0.8.19;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract BetGame {
  // Variable declaration
  address public betHub;
  IERC20 public usdtToken;
  bool public optionAWon;
  uint256 public totalBetOnOptionA;
  uint256 public totalBetOnOptionB;
  uint256 public gameStartTime;
  bool public isWinnerDetermined;
  uint256 public betsOnA;
  uint256 public betsOnB;
  bool public optionABlocked;
  bool public optionBBlocked;
  uint256 public threshold;
  uint256 public ownerFee;

  struct Bet {
    uint256 amount;
    bool isOptionA;
  }

  mapping(address => Bet[]) public bets;
  mapping(address => bool) public hasWithdrawn;

  constructor(address _betHub, address _usdtToken, uint256 _threshold, uint256 _fee) {
    betHub = _betHub;
    usdtToken = IERC20(_usdtToken);
    gameStartTime = block.timestamp; // Set the start time when the contract is deployed
    threshold = _threshold;
    ownerFee = _fee;
  }

  function placeBet(uint256 amount, bool isOptionA) public {
    require(!isWinnerDetermined, "Betting is closed");
    require(amount >= 500000000000000000, "Minimum bet is 0.5 USDT"); // Adjusted for 18 decimals
    require(isOptionA ? !optionABlocked : !optionBBlocked, "This betting option is currently blocked");
    // Calculate the fee and the bet amount
    uint256 fee = amount * ownerFee / 100; //  fee
    uint256 betAmount = amount - fee; //  bet amount

    // Transfer the fee to BetHub contract
    require(usdtToken.transferFrom(msg.sender, betHub, fee), "Fee transfer failed");

    // Transfer the bet amount to this contract
    require(usdtToken.transferFrom(msg.sender, address(this), betAmount), "Bet transfer failed");

    bets[msg.sender].push(Bet({ amount: betAmount, isOptionA: isOptionA }));
    // Update total bets for each option with the 90% bet amount only
    if (isOptionA) {
      betsOnA += 1;
      totalBetOnOptionA += betAmount;
    } else {
      betsOnB += 1;
      totalBetOnOptionB += betAmount;
    }
    // After the bet is placed, check if either option needs to be blocked or unblocked
    checkAndToggleOptionBlocking();
  }

  function checkAndToggleOptionBlocking() internal {
    uint256 totalBets = totalBetOnOptionA + totalBetOnOptionB;

    // Calculate the maximum allowed difference based on the percentage threshold
    uint256 maxDifference = (totalBets * threshold) / 100;

    uint256 difference;
    if (totalBetOnOptionA > totalBetOnOptionB) {
      difference = totalBetOnOptionA - totalBetOnOptionB;
    } else {
      difference = totalBetOnOptionB - totalBetOnOptionA;
    }

    if (difference > maxDifference) {
      // If the difference is greater than the threshold, block the option with the higher total
      optionABlocked = totalBetOnOptionA > totalBetOnOptionB;
      optionBBlocked = totalBetOnOptionB > totalBetOnOptionA;
    } else {
      // If the difference is within the threshold, ensure both options are unblocked
      optionABlocked = false;
      optionBBlocked = false;
    }
  }

  // Function for winners to withdraw winnings
  function withdrawWinnings() public {
    require(isWinnerDetermined, "Game not ended");
    require(!hasWithdrawn[msg.sender], "Winnings already withdrawn");

    bool userWon = false;
    uint256 totalWinningAmount = 0;
    for (uint i = 0; i < bets[msg.sender].length; i++) {
      if (bets[msg.sender][i].isOptionA == optionAWon) {
        userWon = true;
        uint256 winnerBet = bets[msg.sender][i].amount;

        // Calculate the winner's share for each bet from the losing pot
        uint256 winnerShareFromLosingPot = calculateIndividualBetWinnings(winnerBet, bets[msg.sender][i].isOptionA);

        // Add the original bet amount to the winner's earnings
        totalWinningAmount += winnerBet + winnerShareFromLosingPot;
      }
    }

    require(userWon, "Not a winner");

    usdtToken.transfer(msg.sender, totalWinningAmount);
    hasWithdrawn[msg.sender] = true;
  }

  function calculateIndividualBetWinnings(uint256 winnerBet, bool isOptionA) internal view returns (uint256) {
    uint256 winnerTotalBet = isOptionA ? totalBetOnOptionA : totalBetOnOptionB;
    uint256 loserTotalBet = isOptionA ? totalBetOnOptionB : totalBetOnOptionA;

    uint256 winnerShare = (winnerBet * loserTotalBet) / winnerTotalBet;
    return winnerShare;
  }

  function calculateTotalWinnings(address user) external view returns (uint256) {
    if (!isWinnerDetermined || hasWithdrawn[user]) return 0;

    uint256 totalWinningAmount = 0;
    for (uint i = 0; i < bets[user].length; i++) {
      if (bets[user][i].isOptionA == optionAWon) {
        uint256 winnerBet = bets[user][i].amount;
        uint256 winnerShareFromLosingPot = calculateIndividualBetWinnings(winnerBet, bets[user][i].isOptionA);
        totalWinningAmount += winnerBet + winnerShareFromLosingPot;
      }
    }

    return totalWinningAmount;
  }

  // Function to check if a user has winnings
  function hasWinnings(address user) public view returns (bool) {
    if (!isWinnerDetermined || hasWithdrawn[user]) return false;

    for (uint i = 0; i < bets[user].length; i++) {
      if (bets[user][i].isOptionA == optionAWon) {
        return true; // User has at least one winning bet
      }
    }

    return false; // No winning bets found
  }

  function determineWinner(string memory seed) public {
    require(msg.sender == betHub, "Only BetHub can determine the winner");
    require(!isWinnerDetermined, "Winner already determined");

    bytes32 randomHash = keccak256(abi.encodePacked(seed, block.difficulty, block.timestamp));
    optionAWon = uint256(randomHash) % 2 == 0;
    isWinnerDetermined = true;
  }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.19;

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
