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
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract MissWorldPrediction {
    address public owner;
    uint256 public poolEndTime;
    uint256 public totalFees;
    uint256 public totalTickets;
    IERC20 public usdt; // The USDT token contract address
    bool public paused;

    mapping(address => mapping(string => uint256)) public userPredictions; // User address to prediction mapping
    mapping(string => uint256) public contestantsTotalAmount;
    mapping(address => uint256) public userRewards; // Mapping to track each user's reward balance
    mapping(string => mapping(address => bool)) public isuserVotesForContestant;
    mapping(string => uint256) public userVotesForContestant;
    mapping(string => mapping(address => bool)) public hasClaimedReward;
  

    // Mapping to store the top 5 winners and their positions
    mapping(uint256 => string) public top5Winners;


    event Supported(address indexed user, uint256 amount, string contestantName);
    event contestantsAmount(string indexed contestantName, uint256 amount);
    event RewardClaimed(address indexed user, uint256 amount);
    

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function.");
        _;
    }

    modifier poolOpen() {
        require(!paused && block.timestamp <= poolEndTime, "Prediction pool is closed or paused.");
        _;
    }

    modifier onlyTop5Contestants(string memory contestantName) {
        bool isTop5 = false;
        for (uint256 i = 1; i <= 5; i++) {
            if (keccak256(bytes(contestantName)) == keccak256(bytes(top5Winners[i]))) {
                isTop5 = true;
                break;
            }
        }
        require(isTop5, "Contestant is not in the top 5 winners");
        _;
    }

    constructor() {
        owner = msg.sender;
        poolEndTime = 1696471093;
        usdt = IERC20(0x38D6B8efda5aBaA53247A4Ab8A7E65C30F7c0282);
        paused = false;
    }

    function support(string memory _contestantName, uint256 _ticketCount) external poolOpen {
        require(!paused, "Contract is paused.");
        require(_ticketCount >= 1, "Ticket should be greater than or equal to 1");
        // Calculate the total USDT required
        uint256 totalUSDTRequired = _ticketCount * 10 * 1e18; // Each ticket costs 10 USDT

        // Transfer USDT from the user to this contract
        usdt.transferFrom(msg.sender, address(this), totalUSDTRequired);

        userPredictions[msg.sender][_contestantName] += _ticketCount;
        contestantsTotalAmount[_contestantName] += totalUSDTRequired;
     
        if(isuserVotesForContestant[_contestantName][msg.sender] == false){
             userVotesForContestant[_contestantName]++;
            isuserVotesForContestant[_contestantName][msg.sender]  = true;
        }
        
        totalFees += totalUSDTRequired;
        totalTickets += _ticketCount;

        emit contestantsAmount(_contestantName, totalUSDTRequired);
        emit Supported(msg.sender, totalUSDTRequired, _contestantName);
    }

    function closePool() external view onlyOwner {
        require(block.timestamp > poolEndTime, "Pool is still open.");
    }

    function calculateUserReward(address user, string memory contestantName) internal view returns (uint256) {
        uint256 userAmount = userPredictions[user][contestantName];
        uint256 totalTop5Amount = 0;

        for (uint256 i = 1; i <= 5; i++) {
            string memory winnerName = top5Winners[i];
            totalTop5Amount += contestantsTotalAmount[winnerName];
        }

        uint256 totalDistributedAmount = totalFees - totalTop5Amount;
        uint256 rewardPercentage = getPercentageForWinner(contestantName); // Use dynamic percentage
        uint256 contestantReward = (totalDistributedAmount * rewardPercentage) / 100;

        if (userAmount == 0 || totalDistributedAmount == 0) {
            return 0; // No reward for this user if they didn't support the contestant or no distributed amount
        }
   
        uint256 voterCount = userVotesForContestant[contestantName];
            // Distribute rewards to voters of this contestant
            if (voterCount > 0) {
                    uint256 rewardPerVoter = contestantReward / voterCount;
                    uint256 voterTickets = userPredictions[user][contestantName];
                    uint256 voterReward = rewardPerVoter * voterTickets;
                    return voterReward;
                
            }else{
                return 0;
            }
    }



    function claimReward(string memory contestantName) external poolOpen onlyTop5Contestants(contestantName) {
        require(userPredictions[msg.sender][contestantName] > 0, "No prediction for this contestant");
        require(!hasClaimedReward[contestantName][msg.sender], "Reward already claimed");


        uint256 userReward = calculateUserReward(msg.sender, contestantName);
        require(userReward > 0, "No reward available for this user");
        // Update the user's reward balance
        userRewards[msg.sender] += userReward;
        // Transfer the reward to the user
        usdt.transfer(msg.sender, userReward);
        // Emit an event to notify the user
        emit RewardClaimed(msg.sender, userReward);
    }

    function getPercentageForWinner(string memory contestantName) public view returns (uint256) {
        for (uint256 i = 1; i <= 5; i++) {
            if (keccak256(bytes(contestantName)) == keccak256(bytes(top5Winners[i]))) {
                return getPercentage(i); // Use the position to get the percentage
            }
        }
        return 0; // No percentage for non-winners
    }


    function getPercentage(uint256 position) internal pure returns (uint256) {
        if (position == 1) {
            return 40;
        } else if (position == 2) {
            return 20;
        } else if (position == 3) {
            return 15;
        } else if (position == 4) {
            return 10;
        } else if (position == 5) {
            return 5;
        }
        return 0; // Invalid position
    }

    // Function to set the top 5 winners and their positions
    function setTop5Winners(string[5] memory winners, uint256[5] memory positions) external onlyOwner {
        require(winners.length == 5 && positions.length == 5, "Invalid number of winners and positions");
        for (uint256 i = 0; i < 5; i++) {
            top5Winners[positions[i]] = winners[i];
        }
    }

    function withdraw() external onlyOwner {
        require(!paused, "Contract is paused.");
        require(block.timestamp > poolEndTime, "Prediction pool is still open.");
        // Calculate the total contract balance
        uint256 contractBalance = usdt.balanceOf(address(this));

        require(contractBalance > 0, "No funds to withdraw.");

        // Transfer the entire contract balance to the owner
        usdt.transfer(owner, contractBalance);
    }

    function withdrawOwnerShare() external onlyOwner {
        // Calculate the owner's share based on the total contract balance
        uint256 contractBalance = usdt.balanceOf(address(this));
        uint256 ownerShare = (contractBalance * 10) / 100;

        // Transfer the owner's share to the owner
        usdt.transfer(owner, ownerShare);
    }

    // Emergency stop function to pause certain functions
    function emergencyStop(bool _pause) external onlyOwner {
        paused = _pause;
    }

      // Function to modify the end time by the owner
    function modifyEndTime(uint256 newEndTime) external onlyOwner {
        require(newEndTime > block.timestamp, "New end time must be in the future");
        poolEndTime = newEndTime;
    }

}
