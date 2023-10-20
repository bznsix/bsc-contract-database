// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (token/ERC1155/IERC1155.sol)

pragma solidity ^0.8.0;

import "../../utils/introspection/IERC165.sol";

/**
 * @dev Required interface of an ERC1155 compliant contract, as defined in the
 * https://eips.ethereum.org/EIPS/eip-1155[EIP].
 *
 * _Available since v3.1._
 */
interface IERC1155 is IERC165 {
    /**
     * @dev Emitted when `value` tokens of token type `id` are transferred from `from` to `to` by `operator`.
     */
    event TransferSingle(address indexed operator, address indexed from, address indexed to, uint256 id, uint256 value);

    /**
     * @dev Equivalent to multiple {TransferSingle} events, where `operator`, `from` and `to` are the same for all
     * transfers.
     */
    event TransferBatch(
        address indexed operator,
        address indexed from,
        address indexed to,
        uint256[] ids,
        uint256[] values
    );

    /**
     * @dev Emitted when `account` grants or revokes permission to `operator` to transfer their tokens, according to
     * `approved`.
     */
    event ApprovalForAll(address indexed account, address indexed operator, bool approved);

    /**
     * @dev Emitted when the URI for token type `id` changes to `value`, if it is a non-programmatic URI.
     *
     * If an {URI} event was emitted for `id`, the standard
     * https://eips.ethereum.org/EIPS/eip-1155#metadata-extensions[guarantees] that `value` will equal the value
     * returned by {IERC1155MetadataURI-uri}.
     */
    event URI(string value, uint256 indexed id);

    /**
     * @dev Returns the amount of tokens of token type `id` owned by `account`.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function balanceOf(address account, uint256 id) external view returns (uint256);

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {balanceOf}.
     *
     * Requirements:
     *
     * - `accounts` and `ids` must have the same length.
     */
    function balanceOfBatch(
        address[] calldata accounts,
        uint256[] calldata ids
    ) external view returns (uint256[] memory);

    /**
     * @dev Grants or revokes permission to `operator` to transfer the caller's tokens, according to `approved`,
     *
     * Emits an {ApprovalForAll} event.
     *
     * Requirements:
     *
     * - `operator` cannot be the caller.
     */
    function setApprovalForAll(address operator, bool approved) external;

    /**
     * @dev Returns true if `operator` is approved to transfer ``account``'s tokens.
     *
     * See {setApprovalForAll}.
     */
    function isApprovedForAll(address account, address operator) external view returns (bool);

    /**
     * @dev Transfers `amount` tokens of token type `id` from `from` to `to`.
     *
     * Emits a {TransferSingle} event.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - If the caller is not `from`, it must have been approved to spend ``from``'s tokens via {setApprovalForAll}.
     * - `from` must have a balance of tokens of type `id` of at least `amount`.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155Received} and return the
     * acceptance magic value.
     */
    function safeTransferFrom(address from, address to, uint256 id, uint256 amount, bytes calldata data) external;

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {safeTransferFrom}.
     *
     * Emits a {TransferBatch} event.
     *
     * Requirements:
     *
     * - `ids` and `amounts` must have the same length.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155BatchReceived} and return the
     * acceptance magic value.
     */
    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] calldata ids,
        uint256[] calldata amounts,
        bytes calldata data
    ) external;
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC1155/IERC1155Receiver.sol)

pragma solidity ^0.8.0;

import "../../utils/introspection/IERC165.sol";

/**
 * @dev _Available since v3.1._
 */
interface IERC1155Receiver is IERC165 {
    /**
     * @dev Handles the receipt of a single ERC1155 token type. This function is
     * called at the end of a `safeTransferFrom` after the balance has been updated.
     *
     * NOTE: To accept the transfer, this must return
     * `bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"))`
     * (i.e. 0xf23a6e61, or its own function selector).
     *
     * @param operator The address which initiated the transfer (i.e. msg.sender)
     * @param from The address which previously owned the token
     * @param id The ID of the token being transferred
     * @param value The amount of tokens being transferred
     * @param data Additional data with no specified format
     * @return `bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"))` if transfer is allowed
     */
    function onERC1155Received(
        address operator,
        address from,
        uint256 id,
        uint256 value,
        bytes calldata data
    ) external returns (bytes4);

    /**
     * @dev Handles the receipt of a multiple ERC1155 token types. This function
     * is called at the end of a `safeBatchTransferFrom` after the balances have
     * been updated.
     *
     * NOTE: To accept the transfer(s), this must return
     * `bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"))`
     * (i.e. 0xbc197c81, or its own function selector).
     *
     * @param operator The address which initiated the batch transfer (i.e. msg.sender)
     * @param from The address which previously owned the token
     * @param ids An array containing ids of each token being transferred (order and length must match values array)
     * @param values An array containing amounts of each token being transferred (order and length must match ids array)
     * @param data Additional data with no specified format
     * @return `bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"))` if transfer is allowed
     */
    function onERC1155BatchReceived(
        address operator,
        address from,
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata data
    ) external returns (bytes4);
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Counters.sol)

pragma solidity ^0.8.0;

/**
 * @title Counters
 * @author Matt Condon (@shrugs)
 * @dev Provides counters that can only be incremented, decremented or reset. This can be used e.g. to track the number
 * of elements in a mapping, issuing ERC721 ids, or counting request ids.
 *
 * Include with `using Counters for Counters.Counter;`
 */
library Counters {
    struct Counter {
        // This variable should never be directly accessed by users of the library: interactions must be restricted to
        // the library's function. As of Solidity v0.5.2, this cannot be enforced, though there is a proposal to add
        // this feature: see https://github.com/ethereum/solidity/issues/4637
        uint256 _value; // default: 0
    }

    function current(Counter storage counter) internal view returns (uint256) {
        return counter._value;
    }

    function increment(Counter storage counter) internal {
        unchecked {
            counter._value += 1;
        }
    }

    function decrement(Counter storage counter) internal {
        uint256 value = counter._value;
        require(value > 0, "Counter: decrement overflow");
        unchecked {
            counter._value = value - 1;
        }
    }

    function reset(Counter storage counter) internal {
        counter._value = 0;
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/introspection/IERC165.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
interface IERC165 {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155Receiver.sol";

contract TimeBattle is IERC1155Receiver {
    using Counters for Counters.Counter;

    enum BattleStatus {
        Create,
        Start,
        Finish,
        Cancel
    }

    struct Battle {
        uint256 id;
        BattleStatus status;
        address creator;
        address joiner;
        uint256 creatorToken;
        uint256 joinerToken;
        uint256 startTimestamp;
        address winner;
    }

    address public tokenAddress;
    uint256 public startDuration = 10 seconds;
    Counters.Counter public battleCount;
    mapping(uint256 => Battle) battles;

    event BattleCreated(address creator, uint256 tokenId);
    event BattleStarted(uint256 battleId, address joiner, uint256 tokenId);
    event BattleFinished(uint256 battleId, address winner);
    event BattlCancelled(uint256 battleId, address owner);

    constructor(address _tokenAddress) {
        tokenAddress = _tokenAddress;
    }

    function createBattle(uint256 _tokenId) external {
        require(
            IERC1155(tokenAddress).balanceOf(msg.sender, _tokenId) > 0,
            "TimeBattle: not token owner"
        );

        battleCount.increment();

        uint256 currentBattleId = battleCount.current();

        IERC1155(tokenAddress).safeTransferFrom(
            msg.sender,
            address(this),
            _tokenId,
            1,
            ""
        );

        battles[currentBattleId] = Battle(
            currentBattleId,
            BattleStatus.Create,
            msg.sender,
            address(0),
            _tokenId,
            0,
            0,
            address(0)
        );

        emit BattleCreated(msg.sender, _tokenId);
    }

    function joinBattle(uint256 _battleId, uint256 _tokenId) external {
        require(
            battleCount.current() >= _battleId && _battleId > 0,
            "TimeBattle: invalid battle id"
        );
        Battle storage battle = battles[_battleId];
        require(
            battle.status == BattleStatus.Create,
            "TimeBattle: already started battle"
        );
        require(battle.creator != msg.sender, "TimeBattle: not valid joiner");
        require(
            IERC1155(tokenAddress).balanceOf(msg.sender, _tokenId) > 0,
            "Not token owner"
        );

        IERC1155(tokenAddress).safeTransferFrom(
            msg.sender,
            address(this),
            _tokenId,
            1,
            ""
        );

        battle.status = BattleStatus.Start;
        battle.joiner = msg.sender;
        battle.joinerToken = _tokenId;
        battle.startTimestamp = block.timestamp;
        battle.winner = _randomGenerator(_battleId) == 0
            ? battle.creator
            : battle.joiner;

        emit BattleStarted(_battleId, msg.sender, _tokenId);
    }

    function cancelBattle(uint256 _battleId) external {
        require(
            battleCount.current() >= _battleId && _battleId > 0,
            "TimeBattle: invalid battle id"
        );
        Battle storage battle = battles[_battleId];

        require(
            battle.status == BattleStatus.Create,
            "TimeBattle: already started"
        );
        require(
            battle.creator == msg.sender,
            "TimeBattle: not creator of the battle"
        );

        IERC1155(tokenAddress).safeTransferFrom(
            address(this),
            msg.sender,
            battle.creatorToken,
            1,
            ""
        );

        battle.status = BattleStatus.Cancel;

        emit BattlCancelled(_battleId, msg.sender);
    }

    function claimReward(uint256 _battleId) external {
        require(
            battleCount.current() >= _battleId && _battleId > 0,
            "TimeBattle: invalid battle id"
        );
        Battle storage battle = battles[_battleId];
        require(
            battle.status == BattleStatus.Start,
            "TimeBattle: not joined or finished or cancelled"
        );
        require(
            battle.startTimestamp + startDuration <= block.timestamp,
            "TimeBattle: not started battle"
        );
        require(
            battle.creator == msg.sender || battle.joiner == msg.sender,
            "TimeBattle: not battle player"
        );
        require((battle.winner == msg.sender), "TimeBattle: not winner");

        battle.status = BattleStatus.Finish;

        IERC1155(tokenAddress).safeTransferFrom(
            address(this),
            msg.sender,
            battle.creatorToken,
            1,
            ""
        );

        IERC1155(tokenAddress).safeTransferFrom(
            address(this),
            msg.sender,
            battle.joinerToken,
            1,
            ""
        );

        emit BattleFinished(_battleId, msg.sender);
    }

    function getBattle(uint256 _battleId) public view returns (Battle memory) {
        require(
            battleCount.current() >= _battleId && _battleId > 0,
            "TimeBattle: invalid battle id"
        );
        return battles[_battleId];
    }

    function getBattles() public view returns (Battle[] memory) {
        Battle[] memory battle = new Battle[](battleCount.current());

        for (uint i = 0; i < battleCount.current(); i++) {
            battle[i] = battles[i + 1];
        }

        return battle;
    }

    function _randomGenerator(
        uint256 _battleId
    ) internal view returns (uint256) {
        Battle memory battle = battles[_battleId];
        uint256 random = uint256(
            keccak256(
                abi.encode(
                    block.timestamp,
                    blockhash(block.number - 1),
                    battle.creator,
                    battle.joiner
                )
            )
        );

        return random % 2;
    }

    function onERC1155Received(
        address operator,
        address from,
        uint256 id,
        uint256 value,
        bytes calldata data
    ) external pure returns (bytes4) {
        return this.onERC1155Received.selector;
    }

    function onERC1155BatchReceived(
        address operator,
        address from,
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata data
    ) external pure returns (bytes4) {
        return this.onERC1155BatchReceived.selector;
    }

    function supportsInterface(
        bytes4 interfaceId
    ) public view virtual returns (bool) {
        return interfaceId == type(IERC1155Receiver).interfaceId;
    }
}