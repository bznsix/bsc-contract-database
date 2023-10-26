// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

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
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

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
}
/*
*░██╗░░░░░░░██╗░█████╗░███████╗░█████╗░░░███╗░░
*░██║░░██╗░░██║██╔══██╗██╔════╝██╔══██╗░████║░░
*░╚██╗████╗██╔╝██║░░██║█████╗░░██║░░██║██╔██║░░
*░░████╔═████║░██║░░██║██╔══╝░░██║░░██║╚═╝██║░░
*░░╚██╔╝░╚██╔╝░╚█████╔╝██║░░░░░╚█████╔╝███████╗
*░░░╚═╝░░░╚═╝░░░╚════╝░╚═╝░░░░░░╚════╝░╚══════╝
*----------https://worldfootball.io/-----------
*/
// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract LotteryV5Goldium {
    uint256 public ticketPrice = 5000 * 10**18; // 5000 tokens (wei value)
    uint256 public maxTickets = 100; // maximum tickets per lottery
    uint256 public ticketCommission = 500 * 10**18; // 500 tokens (wei value) commission per ticket
    uint256 public duration = 1440 minutes; // The duration set for the lottery

    uint256 public expiration; // Timeout in case the lottery was not carried out.
    address public lotteryOperator; // the creator of the lottery
    uint256 public operatorTotalCommission = 0; // the total commission balance
    address public lastWinner; // the last winner of the lottery
    uint256 public lastWinnerAmount; // the last winner amount of the lottery

    mapping(address => uint256) public winnings; // maps the winners to their winnings
    address[] public tickets; // array of purchased Tickets

    IERC20 public token; // the ERC20 token used for buying tickets

    modifier onlyOwner() {
        require(msg.sender == lotteryOperator, "Caller is not the owner");
        _;
    }

    constructor(address _tokenAddress) {
        lotteryOperator = msg.sender;
        expiration = block.timestamp + duration;
        token = IERC20(_tokenAddress);
    }

    function getTickets() public view returns (address[] memory) {
        return tickets;
    }

    function getWinningsForAddress(address addr) public view returns (uint256) {
        return winnings[addr];
    }

    function BuyTickets(uint256 numOfTicketsToBuy) public {
        require(numOfTicketsToBuy > 0, "Number of tickets to buy must be greater than zero");

        uint256 totalPrice = ticketPrice * numOfTicketsToBuy;

        require(token.allowance(msg.sender, address(this)) >= totalPrice, "Insufficient token allowance");
        require(numOfTicketsToBuy <= RemainingTickets(), "Not enough tickets available.");

        for (uint256 i = 0; i < numOfTicketsToBuy; i++) {
            tickets.push(msg.sender);
        }

        token.transferFrom(msg.sender, address(this), totalPrice);
    }

    function DrawWinnerTicket() public onlyOwner {
        require(tickets.length > 0, "No tickets were purchased");

        bytes32 blockHash = blockhash(block.number - tickets.length);
        uint256 randomNumber = uint256(keccak256(abi.encodePacked(block.timestamp, blockHash)));
        uint256 winningTicket = randomNumber % tickets.length;

        address winner = tickets[winningTicket];
        lastWinner = winner;
        winnings[winner] += (tickets.length * (ticketPrice - ticketCommission));
        lastWinnerAmount = winnings[winner];
        operatorTotalCommission += (tickets.length * ticketCommission);
        delete tickets;
        expiration = block.timestamp + duration;
    }

    function restartDraw() public onlyOwner {
        require(tickets.length == 0, "Cannot restart draw as draw is in play");

        delete tickets;
        expiration = block.timestamp + duration;
    }

    function checkWinningsAmount() public view returns (uint256) {
        address payable winner = payable(msg.sender);

        uint256 reward2Transfer = winnings[winner];

        return reward2Transfer;
    }

    function WithdrawWinnings(address tokenAddress) public {
        address payable winner = payable(msg.sender);

        uint256 reward2Transfer = winnings[winner];
        require(reward2Transfer > 0, "No winnings to withdraw");

        winnings[winner] = 0;

        if (tokenAddress == address(0)) {
            // Withdraw Ether
            (bool success, ) = winner.call{ value: reward2Transfer }("");
            require(success, "Failed to withdraw winnings in Ether");
        } else {
            // Withdraw Tokens
            IERC20 tokenToWithdraw = IERC20(tokenAddress);
            require(tokenToWithdraw.transfer(winner, reward2Transfer), "Token transfer failed");
        }
    }

    function RefundAll() public {
        require(block.timestamp >= expiration, "The lottery has not expired yet");

        for (uint256 i = 0; i < tickets.length; i++) {
            address payable to = payable(tickets[i]);
            tickets[i] = address(0);
            (bool success, ) = to.call{ value: ticketPrice }("");
            require(success, "Failed to refund ticket");
        }
        delete tickets;
    }

    function WithdrawCommission(address tokenAddress) public onlyOwner {
        address payable operator = payable(msg.sender);

        uint256 commission2Transfer = operatorTotalCommission;
        operatorTotalCommission = 0;

        if (tokenAddress == address(0)) {
            // Withdraw Ether
            (bool success, ) = operator.call{ value: commission2Transfer }("");
            require(success, "Failed to withdraw commission in Ether");
        } else {
            // Withdraw Tokens
            IERC20 commissionToken = IERC20(tokenAddress);
            require(commissionToken.transfer(operator, commission2Transfer), "Token transfer failed");
        }
    }

    function IsWinner() public view returns (bool) {
        return winnings[msg.sender] > 0;
    }

    function CurrentWinningReward() public view returns (uint256) {
        return tickets.length * ticketPrice;
    }

    function RemainingTickets() public view returns (uint256) {
        return maxTickets - tickets.length;
    }

    function setDuration(uint256 newDuration) public onlyOwner {
        require(newDuration > 0, "Duration must be greater than zero");
        expiration = block.timestamp + newDuration;
        duration = newDuration;
    }

    function setLotteryOperator(address newOperator) public onlyOwner {
        require(newOperator != address(0), "New operator address cannot be zero address");
        lotteryOperator = newOperator;
    }
	function setTicketPrice(uint256 newPrice) public onlyOwner {
		require(newPrice > 0, "Ticket price must be greater than zero");
		ticketPrice = newPrice;
	}

	function setTicketCommission(uint256 newCommission) public onlyOwner {
		require(newCommission >= 0, "Commission cannot be negative");
		ticketCommission = newCommission;
	}
	function setMaxTickets(uint256 newMaxTickets) public onlyOwner {
		require(newMaxTickets > 0, "Max tickets must be greater than zero");
		maxTickets = newMaxTickets;
	}

}