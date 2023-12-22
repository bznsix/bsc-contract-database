// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;
pragma abicoder v2;

interface IERC20 {
    function transfer(address to, uint256 value) external returns (bool);
    function transferFrom(address from, address to, uint256 value) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint);
}

contract ScrooG {
    IERC20 BEP20USDT = IERC20(0x55d398326f99059fF775485246999027B3197955); // USDT

    event BetRed(uint128 indexed battleId, address indexed sender, uint256 amount, uint256 battleEndTime);
    event BetBlue(uint128 indexed battleId, address indexed sender, uint256 amount, uint256 battleEndTime);
    event BattleCreated(uint128 indexed battleId, address indexed sender, uint64 royaltyPercent, uint256 battleStartTime, uint256 battleEndTime);
    event BattleApproved(uint128 indexed battleId, address indexed sender);
    event BattlePaid(uint128 indexed battleId);

    address public immutable owner;
    address public scroogAddress;  // The address where the system's commission is transferred.

    uint256 public minBetAmount;
    uint256 public maxBetAmount;

    uint256 public battleTimeout;
    uint256 public betTimeout;

    uint64 public feePercent;

    struct Battle {
        uint64 royaltyPercent;
        uint64 feePercent;

        uint256 blueTotalBets;
        uint256 redTotalBets;

        uint256 startTime;
        uint256 endTime;

        address blueAddress;
        address redAddress;

        bool paid;
    }

    mapping(uint128 battleId => Battle) public battles;

    mapping(uint128 battleId => address[]) public blueAddrs;
    mapping(uint128 battleId => mapping (address sender => uint256)) public blueBets;

    mapping(uint128 battleId => address[]) public redAddrs;
    mapping(uint128 battleId => mapping (address sender => uint256)) public redBets;

    modifier onlyOwner {
        _checkOwner();
        _;
    }

    function _checkOwner() internal view virtual {
        require(msg.sender == owner, "Not owner");
    }

    constructor() {
        owner = msg.sender;
        scroogAddress = msg.sender;

        minBetAmount = 1 * 1e18;    // 1 USDT
        maxBetAmount = 1000 * 1e18; // 1000 USDT

        battleTimeout = 1800;
        betTimeout = 300;

        feePercent = 10_000;
    }

    /**
     * @dev Internal function to check if the amount is within the allowed range.
     * @param amount The amount to check.
     */
    function _checkAmount(uint256 amount) internal view virtual {
        require(amount >= minBetAmount, "Amount too low");
        require(amount <= maxBetAmount, "Amount too high");
        require(BEP20USDT.allowance(msg.sender, address(this)) >= amount, "Allowance too low");
    }

    /**
     * @notice Creates a new battle.
     * @param battleId The ID of the battle.
     * @param royaltyPercent The percentage of the total bets to be paid as royalty to the creator of the battle.
     * @param startTime The timestamp when the battle will start.
     * @dev The battle can only be created if it hasn't been created before and if the royalty percentage is not greater than 50%.
     * @dev The start time of the battle must be in the future and within a week from the current timestamp.
     * @dev Emits a BattleCreated event upon successful creation.
     */
    function createBattle(uint128 battleId, uint64 royaltyPercent, uint64 startTime) external {
        Battle storage battle = battles[battleId];

        require(battle.blueAddress == address(0), "Battle created");
        require(royaltyPercent <= 50_000, "Royalty too high");
        require(startTime >= block.timestamp, "Timestamp too small");
        require(startTime < block.timestamp + 604800, "Timestamp too big");

        battle.blueAddress = msg.sender;
        battle.royaltyPercent = royaltyPercent;
        battle.feePercent = feePercent;
        battle.startTime = startTime;
        battle.endTime = startTime + battleTimeout;

        emit BattleCreated(battleId, msg.sender, royaltyPercent, startTime, battle.endTime);
    }

    /**
     * @notice Approves a battle by setting the red address.
     * @param battleId The ID of the battle to approve.
     * @dev The battle must have been created and the battle's start time must not have passed.
     */
    function approveBattle(uint128 battleId) external {
        Battle storage battle = battles[battleId];

        require(battle.blueAddress != address(0), "Battle not created");
        require(battle.redAddress == address(0), "Battle approved");
        require(battle.startTime > block.timestamp, "Battle expired");

        battle.redAddress = msg.sender;

        emit BattleApproved(battleId, msg.sender);
    }

    /**
     * @notice Places a bet on the blue side of a battle.
     * @param battleId The ID of the battle on which to place the bet.
     * @param amount The amount to bet, in wei.
     * @dev The amount must be within the minimum and maximum bet amounts set by the contract owner.
     * @dev The battle must have been created and approved, and the battle's end time must not have passed.
     * @dev If the battle ends within the bet timeout, the bet timeout will be extended.
     * @dev Emits a BetBlue event upon successful bet placement.
     */
    function betBlue(uint128 battleId, uint256 amount) external {
        _checkAmount(amount);
        _betBlue(battleId, amount, msg.sender);
    }

    function betBlueCoupon(uint128 battleId, uint256 amount, address sender) external returns (bool) {
        _checkAmount(amount);
        _betBlue(battleId, amount, sender);
        return true;
    }

    /**
     * @notice Places a bet on the blue side of a battle.
     * @param battleId The ID of the battle on which to place the bet.
     * @param amount The amount to bet, in wei.
     * @param sender.
     * @dev The amount must be within the minimum and maximum bet amounts set by the contract owner.
     * @dev The battle must have been created and approved, and the battle's end time must not have passed.
     * @dev If the battle ends within the bet timeout, the bet timeout will be extended.
     * @dev Emits a BetBlue event upon successful bet placement.
     */
    function _betBlue(uint128 battleId, uint256 amount, address sender) internal {
        Battle storage battle = battles[battleId];

        require(battle.blueAddress != address(0), "Battle not created");
        require(battle.redAddress != address(0), "Battle not approved");
        require(battle.startTime < block.timestamp, "Battle not started");
        require(battle.endTime > block.timestamp, "Battle finished");

        if (blueBets[battleId][sender] + amount > maxBetAmount) {
            amount = maxBetAmount - blueBets[battleId][sender];
        }

        require(BEP20USDT.allowance(msg.sender, address(this)) >= amount, "Allowance too low");
        require(BEP20USDT.transferFrom(msg.sender, address(this), amount));

        unchecked {
            battle.blueTotalBets += amount;
        }

        if (blueBets[battleId][sender] == 0) {
            blueAddrs[battleId].push(sender);
        }

        unchecked {
            blueBets[battleId][sender] += amount;
        }

        if (battle.endTime - block.timestamp < betTimeout) {
            battle.endTime = block.timestamp + betTimeout;
        }

        emit BetBlue(battleId, sender, amount, battle.endTime);
    }

    /**
     * @notice Places a bet on the red side of a battle.
     * @param battleId The ID of the battle on which to place the bet.
     * @param amount The amount to bet, in wei.
     * @dev The amount must be within the minimum and maximum bet amounts set by the contract owner.
     * @dev The battle must have been created and approved, and the battle's end time must not have passed.
     * @dev If the battle ends within the bet timeout, the bet timeout will be extended.
     * @dev Emits a BetRed event upon successful bet placement.
     */
    function betRed(uint128 battleId, uint256 amount) external {
        _checkAmount(amount);
        _betRed(battleId, amount, msg.sender);
    }

    function betRedCoupon(uint128 battleId, uint256 amount, address sender) external returns (bool) {
        _checkAmount(amount);
        _betRed(battleId, amount, sender);
        return true;
    }

    /** 
     * @notice Places a bet on the red side of a battle.
     * @param battleId The ID of the battle on which to place the bet.
     * @param amount The amount to bet, in wei.
     * @param sender.
     * @dev The amount must be within the minimum and maximum bet amounts set by the contract owner.
     * @dev The battle must have been created and approved, and the battle's end time must not have passed.
     * @dev If the battle ends within the bet timeout, the bet timeout will be extended.
     * @dev Emits a BetRed event upon successful bet placement.
     */
    function _betRed(uint128 battleId, uint256 amount, address sender) internal {
        Battle storage battle = battles[battleId];

        require(battle.blueAddress != address(0), "Battle not created");
        require(battle.redAddress != address(0), "Battle not approved");
        require(battle.startTime < block.timestamp, "Battle not started");
        require(battle.endTime > block.timestamp, "Battle finished");

        if (redBets[battleId][sender] + amount > maxBetAmount) {
            amount = maxBetAmount - redBets[battleId][sender];
        }

        require(BEP20USDT.allowance(msg.sender, address(this)) >= amount, "Allowance too low");
        require(BEP20USDT.transferFrom(msg.sender, address(this), amount));

        unchecked {
            battle.redTotalBets += amount;
        }

        if (redBets[battleId][sender] == 0) {
            redAddrs[battleId].push(sender);
        }

        unchecked {
            redBets[battleId][sender] += amount;
        }

        if (battle.endTime - block.timestamp < betTimeout) {
            battle.endTime = block.timestamp + betTimeout;
        }

        emit BetRed(battleId, sender, amount, battle.endTime);
    }

    /**
     * @notice Pays out the winnings and commission for a completed battle.
     * @dev This function calculates the winnings and commission based on the total bets placed and the royalty and fee percentages set. 
     * Depending on the outcome of the battle, the winnings are distributed to the winning side, while the commission is transferred to the system's commission address.
     * If the battle ends in a draw or there were no bets on one side, the bets are returned to their respective addresses.
     * @param battleId The ID of the battle for which to pay out the winnings and commission.
     * @dev The battle must have been created and approved, and the battle's end time must have passed.
     * @dev This function can only be called once for each battle.
     * @dev Emits a BattlePaid event upon successful payout.
     */
    function pay(uint128 battleId) external {
        _pay(battleId);
    }

    /**
     * @notice Pays out the winnings and commission for a completed battle.
     * @dev This function calculates the winnings and commission based on the total bets placed and the royalty and fee percentages set. 
     * Depending on the outcome of the battle, the winnings are distributed to the winning side, while the commission is transferred to the system's commission address.
     * If the battle ends in a draw or there were no bets on one side, the bets are returned to their respective addresses.
     * @param battleId The ID of the battle for which to pay out the winnings and commission.
     * @dev The battle must have been created and approved, and the battle's end time must have passed.
     * @dev This function can only be called once for each battle.
     * @dev Emits a BattlePaid event upon successful payout.
     */
    function _pay(uint128 battleId) internal {
        Battle storage battle = battles[battleId];

        require(!battle.paid, "Battle paid");
        require(battle.blueAddress != address(0), "Battle not created");
        require(battle.redAddress != address(0), "Battle not approved");
        require(battle.endTime < block.timestamp, "Battle not finished");

        battle.paid = true;

        uint256 totalBetsAmount = battle.redTotalBets + battle.blueTotalBets;
        uint256 interestAmount = totalBetsAmount * battle.feePercent / 100_000;

        // In case the bets are equal or there were no bets for one side at all, then we return the deposit.
        if (battle.redTotalBets == battle.blueTotalBets || battle.redTotalBets == 0 || battle.blueTotalBets == 0) {
            address[] memory addrs = redAddrs[battleId];
            uint256 j = addrs.length;

            for (uint256 i = 0; i < j; i++) {
                address addr = addrs[i];
                uint256 amount = redBets[battleId][addr];

                require(BEP20USDT.transfer(addr, amount));
            }


            addrs = blueAddrs[battleId];
            j = addrs.length;

            for (uint256 i = 0; i < j; i++) {
                address addr = addrs[i];
                uint256 amount = blueBets[battleId][addr];

                require(BEP20USDT.transfer(addr, amount));
            }
        }

        // The creator of the battle has lost.
        else if (battle.redTotalBets > battle.blueTotalBets) {
            uint256 royaltyAmount = battle.blueTotalBets * battle.royaltyPercent / 100_000;
            uint256 winAmount = battle.blueTotalBets - royaltyAmount;

            if (interestAmount > winAmount) {
                winAmount = 0;
                interestAmount = winAmount;
            } else {
                winAmount -= interestAmount;
            }

            // Coins left due to rounding.
            uint256 changeAmount = winAmount;

            address[] memory addrs = redAddrs[battleId];
            uint256 j = addrs.length;

            for (uint256 i = 0; i < j; i++) {
                address addr = addrs[i];
                uint256 amount = redBets[battleId][addr];

                uint256 portion = amount * (10**18) / battle.redTotalBets;
                uint256 gainAmount = winAmount * portion / (10**18);

                amount += gainAmount;
                changeAmount -= gainAmount;

                require(BEP20USDT.transfer(addr, amount));
            }

            // Add the remaining coins to the system's commission.
            interestAmount += changeAmount;

            // Payout the system's commission.
            require(BEP20USDT.transfer(scroogAddress, interestAmount));

            // Payout the winnings to the winner.
            require(BEP20USDT.transfer(battle.redAddress, royaltyAmount));
        }

        // The creator of the battle has won
        else {
            uint256 royaltyAmount = battle.redTotalBets * battle.royaltyPercent / 100_000;
            uint256 winAmount = battle.redTotalBets - royaltyAmount;

            // If the system's commission is greater than the total volume of bets after paying royalties,
            // then we take all the remaining bets from the losing side for ourselves.
            if (interestAmount > winAmount) {
                winAmount = 0;
                interestAmount = winAmount;
            } else {
                winAmount -= interestAmount;
            }

            // Coins left due to rounding.
            uint256 changeAmount = winAmount;

            address[] memory addrs = blueAddrs[battleId];
            uint256 j = addrs.length;

            for (uint256 i = 0; i < j; i++) {
                address addr = addrs[i];
                uint256 amount = blueBets[battleId][addr];

                uint256 portion = amount * (10**18) / battle.blueTotalBets;
                uint256 gainAmount = winAmount * portion / (10**18);

                amount += gainAmount;
                changeAmount -= gainAmount;

                require(BEP20USDT.transfer(addr, amount));
            }

            // Add the remaining coins to the system's commission.
            interestAmount += changeAmount;

            // Payout the system's commission.
            require(BEP20USDT.transfer(scroogAddress, interestAmount));

            // Payout the winnings to the winner.
            require(BEP20USDT.transfer(battle.blueAddress, royaltyAmount));
        }

        emit BattlePaid(battleId);
    }

    /**
     * @notice Sets the minimum bet amount for a battle.
     * @dev Only the contract owner can call this function.
     * @param amount The new minimum bet amount to set.
     * @dev The amount must be less than the current maximum bet amount.
     */
    function setMinBetAmount(uint256 amount) external onlyOwner {
        require(amount < maxBetAmount, "Too big");
        minBetAmount = amount;
    }

    /**
     * @notice Sets the maximum bet amount for a battle.
     * @dev Only the contract owner can call this function.
     * @param amount The new maximum bet amount to set.
     * @dev The amount must be greater than the current minimum bet amount.
     */
    function setMaxBetAmount(uint256 amount) external onlyOwner {
        require(amount > minBetAmount, "Too small");
        maxBetAmount = amount;
    }

    /**
     * @notice Sets the fee percentage for each battle.
     * @dev Only the contract owner can call this function.
     * @param val The new fee percentage to set. Must be less than or equal to 30,000. A value of 10,000 represents 10% fee.
     */
    function setFeePercent(uint64 val) external onlyOwner {
        require(val <= 30_000, "Too big");
        feePercent = val;
    }

    /**
     * @notice Sets the timeout for a battle.
     * @dev Only the contract owner can call this function.
     * @param val The new timeout value to set, in seconds.
     * @dev The timeout must be less than or equal to 86400 seconds (24 hours) and greater than or equal to 600 seconds (10 minutes).
     */
    function setBattleTimeout(uint256 val) external onlyOwner {
        require(val <= 86400, "Too big");
        require(val >= 600, "Too small");
        battleTimeout = val;
    }

    /**
     * @notice Sets the timeout for placing bets in a battle.
     * @dev Only the contract owner can call this function.
     * @param val The new timeout value to set, in seconds.
     * @dev The timeout must be less than or equal to 3600.
     */
    function setBetTimeout(uint256 val) external onlyOwner {
        require(val <= 3600, "Too big");
        betTimeout = val;
    }

    /**
     * @notice Set the address where the system's commission is transferred.
     * @dev Only the contract owner can call this function.
     * @param addr The new address to set as the system's commission address.
     * @dev The address must not be empty (0x0).
     */
    function setScroogAddress(address addr) external onlyOwner {
        require(addr != address(0), "Empty address");
        scroogAddress = addr;
    }
}