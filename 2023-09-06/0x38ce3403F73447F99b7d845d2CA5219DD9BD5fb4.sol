// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./IAuthorizationUtilsV0.sol";
import "./ITemplateUtilsV0.sol";
import "./IWithdrawalUtilsV0.sol";

interface IAirnodeRrpV0 is
    IAuthorizationUtilsV0,
    ITemplateUtilsV0,
    IWithdrawalUtilsV0
{
    event SetSponsorshipStatus(
        address indexed sponsor,
        address indexed requester,
        bool sponsorshipStatus
    );

    event MadeTemplateRequest(
        address indexed airnode,
        bytes32 indexed requestId,
        uint256 requesterRequestCount,
        uint256 chainId,
        address requester,
        bytes32 templateId,
        address sponsor,
        address sponsorWallet,
        address fulfillAddress,
        bytes4 fulfillFunctionId,
        bytes parameters
    );

    event MadeFullRequest(
        address indexed airnode,
        bytes32 indexed requestId,
        uint256 requesterRequestCount,
        uint256 chainId,
        address requester,
        bytes32 endpointId,
        address sponsor,
        address sponsorWallet,
        address fulfillAddress,
        bytes4 fulfillFunctionId,
        bytes parameters
    );

    event FulfilledRequest(
        address indexed airnode,
        bytes32 indexed requestId,
        bytes data
    );

    event FailedRequest(
        address indexed airnode,
        bytes32 indexed requestId,
        string errorMessage
    );

    function setSponsorshipStatus(address requester, bool sponsorshipStatus)
        external;

    function makeTemplateRequest(
        bytes32 templateId,
        address sponsor,
        address sponsorWallet,
        address fulfillAddress,
        bytes4 fulfillFunctionId,
        bytes calldata parameters
    ) external returns (bytes32 requestId);

    function makeFullRequest(
        address airnode,
        bytes32 endpointId,
        address sponsor,
        address sponsorWallet,
        address fulfillAddress,
        bytes4 fulfillFunctionId,
        bytes calldata parameters
    ) external returns (bytes32 requestId);

    function fulfill(
        bytes32 requestId,
        address airnode,
        address fulfillAddress,
        bytes4 fulfillFunctionId,
        bytes calldata data,
        bytes calldata signature
    ) external returns (bool callSuccess, bytes memory callData);

    function fail(
        bytes32 requestId,
        address airnode,
        address fulfillAddress,
        bytes4 fulfillFunctionId,
        string calldata errorMessage
    ) external;

    function sponsorToRequesterToSponsorshipStatus(
        address sponsor,
        address requester
    ) external view returns (bool sponsorshipStatus);

    function requesterToRequestCountPlusOne(address requester)
        external
        view
        returns (uint256 requestCountPlusOne);

    function requestIsAwaitingFulfillment(bytes32 requestId)
        external
        view
        returns (bool isAwaitingFulfillment);
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IAuthorizationUtilsV0 {
    function checkAuthorizationStatus(
        address[] calldata authorizers,
        address airnode,
        bytes32 requestId,
        bytes32 endpointId,
        address sponsor,
        address requester
    ) external view returns (bool status);

    function checkAuthorizationStatuses(
        address[] calldata authorizers,
        address airnode,
        bytes32[] calldata requestIds,
        bytes32[] calldata endpointIds,
        address[] calldata sponsors,
        address[] calldata requesters
    ) external view returns (bool[] memory statuses);
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface ITemplateUtilsV0 {
    event CreatedTemplate(
        bytes32 indexed templateId,
        address airnode,
        bytes32 endpointId,
        bytes parameters
    );

    function createTemplate(
        address airnode,
        bytes32 endpointId,
        bytes calldata parameters
    ) external returns (bytes32 templateId);

    function getTemplates(bytes32[] calldata templateIds)
        external
        view
        returns (
            address[] memory airnodes,
            bytes32[] memory endpointIds,
            bytes[] memory parameters
        );

    function templates(bytes32 templateId)
        external
        view
        returns (
            address airnode,
            bytes32 endpointId,
            bytes memory parameters
        );
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IWithdrawalUtilsV0 {
    event RequestedWithdrawal(
        address indexed airnode,
        address indexed sponsor,
        bytes32 indexed withdrawalRequestId,
        address sponsorWallet
    );

    event FulfilledWithdrawal(
        address indexed airnode,
        address indexed sponsor,
        bytes32 indexed withdrawalRequestId,
        address sponsorWallet,
        uint256 amount
    );

    function requestWithdrawal(address airnode, address sponsorWallet) external;

    function fulfillWithdrawal(
        bytes32 withdrawalRequestId,
        address airnode,
        address sponsor
    ) external payable;

    function sponsorToWithdrawalRequestCount(address sponsor)
        external
        view
        returns (uint256 withdrawalRequestCount);
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../interfaces/IAirnodeRrpV0.sol";

/// @title The contract to be inherited to make Airnode RRP requests
contract RrpRequesterV0 {
    IAirnodeRrpV0 public immutable airnodeRrp;

    /// @dev Reverts if the caller is not the Airnode RRP contract.
    /// Use it as a modifier for fulfill and error callback methods, but also
    /// check `requestId`.
    modifier onlyAirnodeRrp() {
        require(msg.sender == address(airnodeRrp), "Caller not Airnode RRP");
        _;
    }

    /// @dev Airnode RRP address is set at deployment and is immutable.
    /// RrpRequester is made its own sponsor by default. RrpRequester can also
    /// be sponsored by others and use these sponsorships while making
    /// requests, i.e., using this default sponsorship is optional.
    /// @param _airnodeRrp Airnode RRP contract address
    constructor(address _airnodeRrp) {
        airnodeRrp = IAirnodeRrpV0(_airnodeRrp);
        IAirnodeRrpV0(_airnodeRrp).setSponsorshipStatus(address(this), true);
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (access/Ownable.sol)

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
pragma solidity ^0.8.0;

import "@api3/airnode-protocol/contracts/rrp/requesters/RrpRequesterV0.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Lottery is Ownable, RrpRequesterV0 {
    struct Player {
        address account;
        int256 tokenBalance;
        int256 numberOfTickets;
    }

    struct Winner {
        uint256 round;
        address account;
        int256 numberOfTickets;
        uint256 bnbAmountWon;
        uint256 luckyNumber;
    }

    mapping(bytes32 => bool) public expectingRequestWithIdToBeFulfilled;
    mapping(uint256 => mapping(address => uint256)) public roundToPlayerId;
    mapping(uint256 => Player[]) private roundToPlayers;

    address public airnode;
    bytes32 public endpointIdUint256Array;
    address public sponsorWallet;

    Winner[] private previousWinners;
    uint256 private eligiblePlayerCount;
    int256 private ticketDenominator;
    uint256 private interval;
    uint256 private currentRound;
    uint256 private lastTimestamp;
    uint256 private playerIdCount;
    uint256 private totalBNBDistributed;
    int256 private totalTickets;
    uint256 private totalPlayers;
    uint256 private minPlayers;
    uint256 private minBalance;
    uint256 private winnersPerRound;
    address private tokenAddress;
    bool private isLotteryOpen = false;

    bool private canChangeConditions = false;
    int256 private newTicketDenominator;
    uint256 private newInterval;
    uint256 private newMinPlayers;
    uint256 private newMinBalance;
    uint256 private newWinnersPerRound;

    event RequestedUint256Array(bytes32 indexed requestId, uint256 size);
    event ReceivedUint256Array(bytes32 indexed requestId, uint256[] response);
    event PlayerDataUpdated(
        address indexed account,
        int256 indexed tokenBalance,
        int256 indexed numberOfTickets
    );
    event WinnersPicked(
        uint256 indexed round,
        uint8 indexed numOfWinners,
        uint256 indexed bnbWon
    );

    modifier onlyToken() {
        require(msg.sender == tokenAddress);
        _;
    }

    constructor(address _airnodeRrp) RrpRequesterV0(_airnodeRrp) {
        minBalance = 1 ether;
        winnersPerRound = 1;
        minPlayers = 5;
        interval = 3600;
        ticketDenominator = (1 * 1e9 * 1e18) / 100000;
    }

    receive() external payable {}

    function setRequestParameters(
        address _airnode,
        bytes32 _endpointIdUint256Array,
        address _sponsorWallet
    ) external onlyOwner {
        airnode = _airnode;
        endpointIdUint256Array = _endpointIdUint256Array;
        sponsorWallet = _sponsorWallet;
    }

    function canMakeRequest() public view returns (bool) {
        bool hasBalance = address(this).balance > minBalance;
        bool hasPlayers = eligiblePlayerCount > minPlayers;
        bool timePassed = (block.timestamp - lastTimestamp) > interval;
        return (isLotteryOpen && hasBalance && hasPlayers && timePassed);
    }

    function makeRequestUint256Array(uint256 size) external {
        require(canMakeRequest());
        require(size == winnersPerRound);

        bytes32 requestId = airnodeRrp.makeFullRequest(
            airnode,
            endpointIdUint256Array,
            address(this),
            sponsorWallet,
            address(this),
            this.fulfillUint256Array.selector,
            abi.encode(bytes32("1u"), bytes32("size"), size)
        );
        expectingRequestWithIdToBeFulfilled[requestId] = true;
        emit RequestedUint256Array(requestId, size);
    }

    function fulfillUint256Array(
        bytes32 requestId,
        bytes calldata data
    ) external onlyAirnodeRrp {
        require(
            expectingRequestWithIdToBeFulfilled[requestId],
            "Request ID not known"
        );
        expectingRequestWithIdToBeFulfilled[requestId] = false;
        uint256[] memory qrngUint256Array = abi.decode(data, (uint256[]));

        pickWinners(qrngUint256Array);

        emit ReceivedUint256Array(requestId, qrngUint256Array);
    }

    function updatePlayerData(address account, int256 amount) external onlyToken {
        if (roundToPlayerId[currentRound][account] == 0) {
            playerIdCount++;
            roundToPlayerId[currentRound][account] = playerIdCount;
        }

        int256 ticketAmount = 0;

        uint256 playerId = roundToPlayerId[currentRound][account] - 1;
        if (roundToPlayers[currentRound].length > playerId) {
            int256 ticketsBefore = roundToPlayers[currentRound][playerId].numberOfTickets;
            roundToPlayers[currentRound][playerId].tokenBalance += amount;
            roundToPlayers[currentRound][playerId].numberOfTickets = int256(
                roundToPlayers[currentRound][playerId].tokenBalance / ticketDenominator
            );

            if (roundToPlayers[currentRound][playerId].tokenBalance <= 0) {
                roundToPlayers[currentRound][playerId].numberOfTickets = 0;
                roundToPlayers[currentRound][playerId].tokenBalance = 0;
                eligiblePlayerCount--;
            } else {
				if (ticketsBefore == 0) {
					eligiblePlayerCount++;
				}
			}

            ticketAmount = roundToPlayers[currentRound][playerId].numberOfTickets - ticketsBefore;
        } else {
            if (amount < 0) {
                amount = 0;
            }
            ticketAmount = int256(amount / ticketDenominator);
            roundToPlayers[currentRound].push(Player(account, amount, ticketAmount));

            if(ticketAmount > 0) {
                eligiblePlayerCount++;
            }
        }

        totalTickets += ticketAmount;

        emit PlayerDataUpdated(
            roundToPlayers[currentRound][playerId].account,
            roundToPlayers[currentRound][playerId].tokenBalance,
            roundToPlayers[currentRound][playerId].numberOfTickets
        );
    }

    function pickWinners(uint256[] memory qrngArray) internal {
        uint256 from = 0;
        uint256 to = 0;

        for (uint256 i = 0; i < qrngArray.length; i++) {
            qrngArray[i] = qrngArray[i] % uint256(totalTickets);
        }

        uint256 contractBalance = address(this).balance;
        uint256 bnbWonPerWinner = contractBalance / winnersPerRound;

        Winner[] memory winners = new Winner[](winnersPerRound);

        for (uint256 i = 0; i < roundToPlayers[currentRound].length; ) {
            to = uint256(roundToPlayers[currentRound][i].numberOfTickets) + from;
            for (uint256 j = 0; j < winners.length;) {
                if (qrngArray[j] > from && qrngArray[j] <= to) {
                    winners[j] = Winner(
                        currentRound,
                        roundToPlayers[currentRound][i].account,
                        roundToPlayers[currentRound][i].numberOfTickets,
                        bnbWonPerWinner,
                        qrngArray[j]
                    );

                    previousWinners.push(winners[j]);
                }

                unchecked { j++; }
            }

            from = to;
            unchecked { i++; }
        }

        for (uint256 i = 0; i < winners.length; i++) {
            (bool success, ) = payable(winners[i].account).call{value: bnbWonPerWinner}("");
            require(success, "Failed to send ether");
        }

        totalBNBDistributed += contractBalance;
        totalPlayers += roundToPlayers[currentRound].length;

        if (canChangeConditions) {
            ticketDenominator = newTicketDenominator;
            interval = newInterval;
            minPlayers = newMinPlayers;
            minBalance = newMinBalance;
            winnersPerRound = newWinnersPerRound;
            canChangeConditions = false;
        }

        resetLottery();

        emit WinnersPicked(
            currentRound - 1,
            uint8(winners.length),
            contractBalance
        );
    }

    function resetLottery() internal {
        lastTimestamp = block.timestamp;
        currentRound++;
        totalTickets = 0;
        eligiblePlayerCount = 0;
        playerIdCount = 0;
    }

    function setTokenAddress(address _tokenAddress) external onlyOwner {
        tokenAddress = _tokenAddress;
    }

    function openLottery() external onlyOwner {
        lastTimestamp = block.timestamp;
        isLotteryOpen = true;
    }

    function changeConditions(
        int256 _newTicketDenominator,
        uint256 _newInterval,
        uint256 _newMinPlayers,
        uint256 _newMinBalance,
        uint256 _newWinnersPerRound
    ) external onlyOwner {
        newTicketDenominator = _newTicketDenominator;
        newInterval = _newInterval;
        newMinPlayers = _newMinPlayers;
        newMinBalance = _newMinBalance;
        newWinnersPerRound = _newWinnersPerRound;
        canChangeConditions = true;
    }

    function getTokenAddress() public view returns (address) {
        return tokenAddress;
    }

    function getTokenBalanceInThisRound(address account) public view returns (int256) {
        if (roundToPlayerId[currentRound][account] == 0) {
            return 0;
        }
        uint256 playerId = roundToPlayerId[currentRound][account] - 1;
        return roundToPlayers[currentRound][playerId].tokenBalance;
    }

    function getNumberOfTickets(address account) public view returns (int256) {
        if (roundToPlayerId[currentRound][account] == 0) {
            return 0;
        }
        uint256 playerId = roundToPlayerId[currentRound][account] - 1;
        return roundToPlayers[currentRound][playerId].numberOfTickets;
    }

    function getPlayersInRound(uint256 round) public view returns(Player[] memory) {
        return roundToPlayers[round];
    }

    function getRecentPlayers() public view returns (Player[] memory) {
        return roundToPlayers[currentRound];
    }

    function getPreviousWinners() public view returns (Winner[] memory) {
        return previousWinners;
    }

    function getTotalTickets() public view returns (int256) {
        return totalTickets;
    }

    function getCurrentRound() public view returns (uint256) {
        return currentRound;
    }

    function getTicketDenominator() public view returns (int256) {
        return ticketDenominator;
    }

    function getWinnersPerRound() public view returns (uint256) {
        return winnersPerRound;
    }

    function getMinPlayers() public view returns (uint256) {
        return minPlayers;
    }

    function getMinBalance() public view returns (uint256) {
        return minPlayers;
    }

    function getTotalBNBDistributed() public view returns (uint256) {
        return totalBNBDistributed;
    }

    function getTotalPlayers() public view returns (uint256) {
        return totalPlayers;
    }

    function getEligiblePlayerCount() public view returns(uint256) {
        return eligiblePlayerCount;
    }

    function getInterval() public view returns (uint256) {
        return interval;
    }

    function getTimeLeft() public view returns (uint256) {
        uint256 timeLeft = block.timestamp - lastTimestamp;
        if (timeLeft >= interval) {
            return 0;
        }
        return interval - timeLeft;
    }

    function isOpen() public view returns (bool) {
        return isLotteryOpen;
    }
}
