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

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract ScratchCard is Ownable {
    struct Card {
        string cardType; // Use string identifiers to represent card types
        string cardName;
        address tokenAddress;
        uint256 price;
        uint256 maxPrize;
        uint256 maxPrizeProbability;
        uint256 winningProbability;
    }
    mapping(address => uint256) public total; //Total amount of tokens (differentiated by token types)
    Card[] public availableCards;
    mapping(address => uint256) public cardBalances;
    mapping(address => mapping(string => uint256)) public cardCounts;
    uint256 public profitShare = 1000;
    address public lockAddr;
    event CardPurchased(
        address indexed user,
        string cardType,
        uint256 numberOfCards
    );
    event PrizeClaimed(address indexed user, string cardType, uint256 prize);

    event CardTypeAdded(
        string cardType,
        string cardName,
        address tokenAddress,
        uint256 price,
        uint256 maxPrize,
        uint256 maxPrizeProbability,
        uint256 winningProbability
    );
    event CardTypeRemoved(string cardType);
    event CardGifted(
        address indexed sender,
        address indexed recipient,
        string cardType,
        uint256 numberOfCards
    );

    constructor(address _lockAddr) {
        lockAddr = _lockAddr;
    }

    function addCardType(
        string calldata cardType,
        string calldata cardName,
        address tokenAddress,
        uint256 price,
        uint256 maxPrize,
        uint256 maxPrizeProbability,
        uint256 winningProbability
    ) external onlyOwner {
        for (uint256 i = 0; i < availableCards.length; i++) {
            if (
                keccak256(abi.encodePacked(availableCards[i].cardType)) ==
                keccak256(abi.encodePacked(cardType))
            ) {
                revert("Card type exist");
            }
        }
        availableCards.push(
            Card(
                cardType,
                cardName,
                tokenAddress,
                price,
                maxPrize,
                maxPrizeProbability,
                winningProbability
            )
        );
        emit CardTypeAdded(
            cardType,
            cardName,
            tokenAddress,
            price,
            maxPrize,
            maxPrizeProbability,
            winningProbability
        );
    }

    function removeCardType(string calldata cardType) external onlyOwner {
        for (uint256 i = 0; i < availableCards.length; i++) {
            if (
                keccak256(abi.encodePacked(availableCards[i].cardType)) ==
                keccak256(abi.encodePacked(cardType))
            ) {
                availableCards[i] = availableCards[availableCards.length - 1];
                availableCards.pop();
                emit CardTypeRemoved(cardType);
            }
        }
    }

    function purchaseCards(
        string calldata cardType,
        uint256 numberOfCards
    ) external {
        require(numberOfCards > 0, "Number of cards must be greater than zero");
        uint256 cardIndex = findCardIndex(cardType);

        require(cardIndex < availableCards.length, "Invalid card type");
        Card storage selectedCard = availableCards[cardIndex];
        IERC20 token = IERC20(selectedCard.tokenAddress);

        require(
            token.transferFrom(
                msg.sender,
                address(this),
                selectedCard.price * numberOfCards
            ),
            "Transfer failed"
        );

        cardBalances[msg.sender] += numberOfCards;
        cardCounts[msg.sender][cardType] += numberOfCards;
        total[selectedCard.tokenAddress] += selectedCard.price * numberOfCards;
        emit CardPurchased(msg.sender, cardType, numberOfCards);
    }

    function scratchCard(string calldata cardType) external returns (uint256) {
        require(cardBalances[msg.sender] > 0, "You have no cards to scratch");
        require(
            cardCounts[msg.sender][cardType] > 0,
            "You have no cards of this type"
        );
        uint256 cardIndex = findCardIndex(cardType);

        require(cardIndex < availableCards.length, "Invalid card type");
        Card storage selectedCard = availableCards[cardIndex];
        cardBalances[msg.sender]--;
        cardCounts[msg.sender][cardType]--;

        uint profit = (profitShare * selectedCard.price) / 10000;
        IERC20 token = IERC20(selectedCard.tokenAddress);
        total[selectedCard.tokenAddress] -= profit;
        token.transfer(lockAddr, profit); //fee
        uint256 randomNumber = uint256(
            keccak256(
                abi.encodePacked(
                    block.timestamp,
                    block.prevrandao,
                    msg.sender,
                    "demarket"
                )
            )
        );
        uint256 prize = 0;
        if (randomNumber % selectedCard.maxPrizeProbability == 0) {
            prize = selectedCard.maxPrize;
        } else {
            prize = determinePrize(randomNumber % 10000, selectedCard);
        }

        if (prize > 0) {
            require(
                prize <= total[selectedCard.tokenAddress],
                "prize exceed the total"
            );
            require(
                token.transfer(msg.sender, prize),
                "Transfer of prize failed"
            );
            emit PrizeClaimed(msg.sender, cardType, prize);

            total[selectedCard.tokenAddress] -= prize;

            return prize;
        } else {
            emit PrizeClaimed(msg.sender, cardType, 0);
            return 0;
        }
    }

    function determinePrize(
        uint256 randomNumber,
        Card storage selectedCard
    ) internal view returns (uint256) {
        if (randomNumber <= ((selectedCard.winningProbability * 60) / 100)) {
            return selectedCard.price;
        } else if (
            randomNumber <= ((selectedCard.winningProbability * 90) / 100)
        ) {
            return selectedCard.price * 2;
        } else if (
            randomNumber <= ((selectedCard.winningProbability * 95) / 100)
        ) {
            return selectedCard.price * 3;
        } else if (randomNumber <= selectedCard.winningProbability) {
            return selectedCard.price * 4;
        } else {
            return 0;
        }
    }

    function selectRandomCard() internal view returns (uint256) {
        uint256 seed = uint256(
            keccak256(
                abi.encodePacked(block.timestamp, block.prevrandao, msg.sender)
            )
        ) % availableCards.length;
        return seed;
    }

    function findCardIndex(
        string calldata cardType
    ) internal view returns (uint256) {
        for (uint256 i = 0; i < availableCards.length; i++) {
            if (
                keccak256(abi.encodePacked(availableCards[i].cardType)) ==
                keccak256(abi.encodePacked(cardType))
            ) {
                return i;
            }
        }
        revert("Card type not found");
    }

    function withdrawProfit(
        address tokenAddress,
        uint256 amountToWithdraw
    ) external onlyOwner {
        IERC20 profitToken = IERC20(tokenAddress);
        require(
            profitToken.transfer(owner(), amountToWithdraw),
            "Transfer failed"
        );
    }

    function setProfitShare(uint256 newProfitShare) external onlyOwner {
        profitShare = newProfitShare;
    }

    function giftCards(
        address recipient,
        string calldata cardType,
        uint256 numberOfCards
    ) external {
        require(numberOfCards > 0, "Number of cards must be greater than zero");
        uint256 cardIndex = findCardIndex(cardType);

        require(cardIndex < availableCards.length, "Invalid card type");
        Card storage selectedCard = availableCards[cardIndex];

        require(
            cardBalances[msg.sender] >= numberOfCards,
            "Insufficient cards to gift"
        );

        cardBalances[msg.sender] -= numberOfCards;
        cardCounts[msg.sender][cardType] -= numberOfCards;

        cardBalances[recipient] += numberOfCards;
        cardCounts[recipient][cardType] += numberOfCards;

        total[selectedCard.tokenAddress] += selectedCard.price * numberOfCards;

        emit CardGifted(msg.sender, recipient, cardType, numberOfCards);
    }
}
