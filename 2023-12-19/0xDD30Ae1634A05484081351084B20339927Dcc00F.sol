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
// OpenZeppelin Contracts (last updated v4.9.0) (access/Ownable2Step.sol)

pragma solidity ^0.8.0;

import "./Ownable.sol";

/**
 * @dev Contract module which provides access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership} and {acceptOwnership}.
 *
 * This module is used through inheritance. It will make available all functions
 * from parent (Ownable).
 */
abstract contract Ownable2Step is Ownable {
    address private _pendingOwner;

    event OwnershipTransferStarted(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Returns the address of the pending owner.
     */
    function pendingOwner() public view virtual returns (address) {
        return _pendingOwner;
    }

    /**
     * @dev Starts the ownership transfer of the contract to a new account. Replaces the pending transfer if there is one.
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual override onlyOwner {
        _pendingOwner = newOwner;
        emit OwnershipTransferStarted(owner(), newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`) and deletes any pending owner.
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual override {
        delete _pendingOwner;
        super._transferOwnership(newOwner);
    }

    /**
     * @dev The new owner accepts the ownership transfer.
     */
    function acceptOwnership() public virtual {
        address sender = _msgSender();
        require(pendingOwner() == sender, "Ownable2Step: caller is not the new owner");
        _transferOwnership(sender);
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (security/Pausable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
abstract contract Pausable is Context {
    /**
     * @dev Emitted when the pause is triggered by `account`.
     */
    event Paused(address account);

    /**
     * @dev Emitted when the pause is lifted by `account`.
     */
    event Unpaused(address account);

    bool private _paused;

    /**
     * @dev Initializes the contract in unpaused state.
     */
    constructor() {
        _paused = false;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        _requireNotPaused();
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    modifier whenPaused() {
        _requirePaused();
        _;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns (bool) {
        return _paused;
    }

    /**
     * @dev Throws if the contract is paused.
     */
    function _requireNotPaused() internal view virtual {
        require(!paused(), "Pausable: paused");
    }

    /**
     * @dev Throws if the contract is not paused.
     */
    function _requirePaused() internal view virtual {
        require(paused(), "Pausable: not paused");
    }

    /**
     * @dev Triggers stopped state.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    /**
     * @dev Returns to normal state.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;

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
// OpenZeppelin Contracts (last updated v4.9.0) (token/ERC721/IERC721.sol)

pragma solidity ^0.8.0;

import "../../utils/introspection/IERC165.sol";

/**
 * @dev Required interface of an ERC721 compliant contract.
 */
interface IERC721 is IERC165 {
    /**
     * @dev Emitted when `tokenId` token is transferred from `from` to `to`.
     */
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables `approved` to manage the `tokenId` token.
     */
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables or disables (`approved`) `operator` to manage all of its assets.
     */
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    /**
     * @dev Returns the number of tokens in ``owner``'s account.
     */
    function balanceOf(address owner) external view returns (uint256 balance);

    /**
     * @dev Returns the owner of the `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function ownerOf(uint256 tokenId) external view returns (address owner);

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external;

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must have been allowed to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(address from, address to, uint256 tokenId) external;

    /**
     * @dev Transfers `tokenId` token from `from` to `to`.
     *
     * WARNING: Note that the caller is responsible to confirm that the recipient is capable of receiving ERC721
     * or else they may be permanently lost. Usage of {safeTransferFrom} prevents loss, though the caller must
     * understand this adds an external call which potentially creates a reentrancy vulnerability.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address from, address to, uint256 tokenId) external;

    /**
     * @dev Gives permission to `to` to transfer `tokenId` token to another account.
     * The approval is cleared when the token is transferred.
     *
     * Only a single account can be approved at a time, so approving the zero address clears previous approvals.
     *
     * Requirements:
     *
     * - The caller must own the token or be an approved operator.
     * - `tokenId` must exist.
     *
     * Emits an {Approval} event.
     */
    function approve(address to, uint256 tokenId) external;

    /**
     * @dev Approve or remove `operator` as an operator for the caller.
     * Operators can call {transferFrom} or {safeTransferFrom} for any token owned by the caller.
     *
     * Requirements:
     *
     * - The `operator` cannot be the caller.
     *
     * Emits an {ApprovalForAll} event.
     */
    function setApprovalForAll(address operator, bool approved) external;

    /**
     * @dev Returns the account approved for `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function getApproved(uint256 tokenId) external view returns (address operator);

    /**
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     *
     * See {setApprovalForAll}
     */
    function isApprovedForAll(address owner, address operator) external view returns (bool);
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
pragma solidity 0.8.21;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "../interfaces/IAssetsHolder.sol";
import "@openzeppelin/contracts/access/Ownable2Step.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract QuestsDappRadar is Ownable2Step, ReentrancyGuard, Pausable {
    IAssetsHolder public assetsHolder;
    address public admin;

    struct ERC20TokenInfo {
        address tokenAddress;
        uint256 amount;
    }

    struct ERC721TokenInfo {
        address tokenAddress;
        uint256 tokenId;
    }

    struct ERC1155TokenInfo {
        address tokenAddress;
        uint256 tokenId;
        uint256 amount;
    }

    struct QuestData {
        address[] erc20RewardAddresses;
        address[] erc721RewardAddresses;
        address[] erc1155RewardAddresses;
        bool isClaimable;
    }

    struct ERC1155TokenReward {
        uint256 tokenId;
        uint256 amount;
    }

    mapping(uint256 questId => mapping(address erc20Address => uint256 amount)) private remainingERC20Rewards;
    mapping(uint256 questId => QuestData) private questRewards;
    mapping(uint256 questId => mapping(address winner => uint256[] amounts)) private erc20Winner;
    mapping(uint256 questId => mapping(address winner => uint256[] nftId)) private erc721Winner;
    mapping(uint256 questId => mapping(address winner => ERC1155TokenReward[] erc1155RewardDetail)) private erc1155Winner;

    constructor(IAssetsHolder _assetsHolder) {
        assetsHolder = _assetsHolder;
    }
    
    /// @dev Modifier to make a function callable only by the admin.
    modifier onlyAdmin() {
        require(msg.sender == admin, "This function can only be called by admin");
        _;
    }

    /// @notice Sets a new admin for the contract.
    /// @dev This function can only be called by the current admin.
    /// @param newAdmin The address of the new admin.
    function setNewAdmin(address newAdmin) external onlyOwner {
        admin = newAdmin;
    }

    /// @notice Creates a new quest with the provided reward tokens.
    /// @dev This function can only be called by the owner of the contract.
    /// @param questId The unique identifier for the new quest.
    /// @param erc20RewardAddresses An array of addresses for the ERC20 reward tokens.
    /// @param erc721RewardAddresses An array of addresses for the ERC721 reward tokens.
    /// @param erc1155RewardAddresses An array of addresses for the ERC1155 reward tokens.
    function createQuest(
        uint256 questId,
        address[] memory erc20RewardAddresses,
        address[] memory erc721RewardAddresses,
        address[] memory erc1155RewardAddresses
    ) external onlyAdmin {
        require(erc20RewardAddresses.length > 0 || erc721RewardAddresses.length > 0 || erc1155RewardAddresses.length > 0, "Rewards shouldn't be empty");
        require(questRewards[questId].erc20RewardAddresses.length == 0 && questRewards[questId].erc721RewardAddresses.length == 0 && questRewards[questId].erc1155RewardAddresses.length == 0, "Quest already exists");

        uint256 erc20RewardAddressesLength = erc20RewardAddresses.length;
        for (uint256 i = 0; i < erc20RewardAddressesLength; ++i) {
            require(isLikelyERC20(erc20RewardAddresses[i]), "That contract does not have ERC20 standards");
        }

        uint256 erc721RewardAddressesLength = erc721RewardAddresses.length;
        for (uint256 j = 0; j < erc721RewardAddressesLength; ++j) {
            require(isLikelyERC721(erc721RewardAddresses[j]), "That contract does not have ERC721 standards");
        }

        uint256 erc1155RewardAddressesLength = erc1155RewardAddresses.length;
        for (uint256 k = 0; k < erc1155RewardAddressesLength; ++k) {
            require(isLikelyERC1155(erc1155RewardAddresses[k]), "That contract does not have ERC1155 standards");
        }

        QuestData storage reward = questRewards[questId];
        reward.erc20RewardAddresses = erc20RewardAddresses;
        reward.erc721RewardAddresses = erc721RewardAddresses;
        reward.erc1155RewardAddresses = erc1155RewardAddresses;
        emit QuestCreated(questId);
    }

    /// @notice Sets the rewards for multiple winners of a quest.
    /// @dev This function can only be called by the owner of the contract.
    /// @param questId The unique identifier for the quest.
    /// @param winners An array of addresses of the winners.
    /// @param erc20Rewards An array of arrays of ERC20TokenInfo structs for the ERC20 reward tokens for each winner.
    /// @param erc721Rewards An array of arrays of ERC721TokenInfo structs for the ERC721 reward tokens for each winner.
    /// @param erc1155Rewards An array of arrays of ERC1155TokenInfo structs for the ERC1155 reward tokens for each winner.
    function setWinnerRewards(
        uint256 questId,
        address[] memory winners,
        ERC20TokenInfo[][] memory erc20Rewards,
        ERC721TokenInfo[][] memory erc721Rewards,
        ERC1155TokenInfo[][] memory erc1155Rewards
    ) external onlyAdmin {
        require(
            winners.length == erc20Rewards.length &&
            winners.length == erc721Rewards.length &&
            winners.length == erc1155Rewards.length,
            "Input lengths do not match"
        );
        QuestData memory reward = questRewards[questId];
        require(reward.erc20RewardAddresses.length > 0 || reward.erc721RewardAddresses.length > 0 || reward.erc1155RewardAddresses.length > 0, "Quest does not exist");

        for (uint256 i = 0; i < winners.length; i++) {
            for (uint256 l = 0; l < erc20Rewards[i].length; ++l) {
                require(reward.erc20RewardAddresses[l] == erc20Rewards[i][l].tokenAddress, "You should follow order");
                uint256 currentReward = remainingERC20Rewards[questId][erc20Rewards[i][l].tokenAddress];
                require(currentReward >= erc20Rewards[i][l].amount, "Insufficient reward");
                remainingERC20Rewards[questId][erc20Rewards[i][l].tokenAddress] = currentReward - erc20Rewards[i][l].amount;
                erc20Winner[questId][winners[i]].push(erc20Rewards[i][l].amount);
            }

            for (uint256 j = 0; j < erc721Rewards[i].length; ++j) {
                require(reward.erc721RewardAddresses[j] == erc721Rewards[i][j].tokenAddress, "You should follow order");
                erc721Winner[questId][winners[i]].push(erc721Rewards[i][j].tokenId);
            }

            for (uint256 k = 0; k < erc1155Rewards[i].length; ++k) {
                require(reward.erc1155RewardAddresses[k] == erc1155Rewards[i][k].tokenAddress, "You should follow order");
                erc1155Winner[questId][winners[i]].push(ERC1155TokenReward(erc1155Rewards[i][k].tokenId, erc1155Rewards[i][k].amount));
            }
            emit WinnerSet(questId, winners[i]);
        }
    }

    /// @notice Sets the claim status of a quest.
    /// @dev This function can only be called by the owner of the contract.
    /// @param questId The unique identifier for the quest.
    /// @param availability The new claim status for the quest.
    function setQuestClaimStatus(uint256 questId, bool availability) external onlyAdmin {
        questRewards[questId].isClaimable = availability;
    }

    /// @notice Sets the ERC20 amount for a specific quest without transferring any tokens.
    /// @dev This function can only be called by the owner of the contract.
    /// @param questId The unique identifier for the quest whose ERC20 amount is to be set.
    /// @param token The address of the ERC20 token.
    /// @param amount The new amount of the ERC20 token for the quest.
    function setRemainingERC20RewardsForQuest(uint256 questId, address token, uint256 amount) external onlyAdmin {
        remainingERC20Rewards[questId][token] = amount;
    }

    /// @notice Transfers ERC20 tokens from the contract owner to the assetsHolder and updates the ERC20 amount for a specific quest.
    /// @dev This function can only be called by the owner of the contract.
    /// @param token The address of the ERC20 token to be transferred.
    /// @param amount The amount of the ERC20 token to be transferred.
    /// @param questId The unique identifier for the quest whose ERC20 amount is to be updated.
    function addERC20RewardToQuest(uint256 questId, address token, uint256 amount) external onlyAdmin {
        require(IERC20(token).transfer(address(assetsHolder), amount), "Transfer failed");
        remainingERC20Rewards[questId][token] += amount;
    }

    /// @notice Retrieves the total ERC20 amount associated with a specific quest.
    /// @param questId The unique identifier for the quest.
    /// @return The total ERC20 amount associated with the quest.
    function getQuestERC20Amount(uint256 questId,address token) public view returns (uint256) {
        return remainingERC20Rewards[questId][token];
    }

    /// @notice Allows a user to claim the reward for a quest.
    /// @dev This function can only be called when the contract is not paused.
    /// @param questId The unique identifier for the quest.
    function claimReward(uint256 questId) external nonReentrant whenNotPaused {
        require(questRewards[questId].isClaimable, "Can not yet claim rewards");
        QuestData memory reward = questRewards[questId];
        uint256[] memory erc20tokensAmount = erc20Winner[questId][msg.sender];
        uint256[] memory erc721tokensId = erc721Winner[questId][msg.sender];
        ERC1155TokenReward[] memory erc1155Details = erc1155Winner[questId][msg.sender];

        require(erc20tokensAmount.length > 0 || erc721tokensId.length > 0 || erc1155Details.length > 0, "Winner is not defined");
        delete erc20Winner[questId][msg.sender];
        delete erc721Winner[questId][msg.sender];
        delete erc1155Winner[questId][msg.sender];

        for (uint256 i = 0; i < erc20tokensAmount.length; ++i) {
            if(erc20tokensAmount[i] > 0){
                assetsHolder.transferERC20(reward.erc20RewardAddresses[i], erc20tokensAmount[i], msg.sender);
            }
        }

        for (uint256 j = 0; j < erc721tokensId.length; ++j) {
            if(erc721tokensId[j] > 0){
                assetsHolder.transferERC721(reward.erc721RewardAddresses[j], erc721tokensId[j], msg.sender);
            }
        }

        for (uint256 k = 0; k < erc1155Details.length; ++k) {
            if(erc1155Details[k].amount > 0){
                assetsHolder.transferERC1155(reward.erc1155RewardAddresses[k], erc1155Details[k].tokenId, erc1155Details[k].amount, msg.sender, "");
            }
        }

        emit RewardClaimed(questId, msg.sender, erc20tokensAmount, erc721tokensId, erc1155Details);
    }

    /// @notice Checks the rewards for a winner of a quest.
    /// @param questId The unique identifier for the quest.
    /// @param winner The address of the winner.
    function checkWinner(uint256 questId, address winner) external view returns (uint256[] memory, uint256[] memory,  ERC1155TokenReward[] memory) {
        uint256[] memory erc20Amount = erc20Winner[questId][winner];
        uint256[] memory erc721Id = erc721Winner[questId][winner];
        ERC1155TokenReward[] memory erc1155IdAmount = erc1155Winner[questId][winner];
        return (erc20Amount, erc721Id, erc1155IdAmount);
    }

    /// @notice Gets the data for a quest.
    /// @param questId The unique identifier for the quest.
    function getQuestData(uint256 questId) external view returns (QuestData memory) {
        return questRewards[questId];
    }

    /// @notice Removes a winner from a quest.
    /// @dev This function can only be called by the owner of the contract.
    /// @param questId The unique identifier for the quest.
    /// @param winner The address of the winner.
    function removeWinner(uint256 questId, address winner) external onlyAdmin {
        uint256[] memory erc20tokensAmount = erc20Winner[questId][winner];
        for (uint256 i = 0; i < erc20tokensAmount.length; ++i) {
            remainingERC20Rewards[questId][questRewards[questId].erc20RewardAddresses[i]] += erc20tokensAmount[i];
        }
        delete erc20Winner[questId][winner];
        delete erc721Winner[questId][winner];
        delete erc1155Winner[questId][winner];
    }

    /// @notice Checks if a contract is likely an ERC20 contract.
    /// @param _token The address of the contract.
    function isLikelyERC20(address _token) internal view returns (bool) {
        try IERC20(_token).allowance(address(this), msg.sender) returns (uint256) {
            return true;
        } catch {
            return false;
        }
    }

    /// @notice Checks if a contract is likely an ERC721 contract.
    /// @param _token The address of the contract.
    function isLikelyERC721(address _token) internal view returns (bool) {
         bytes4 erc721InterfaceID = 0x80ac58cd;
        try IERC165(_token).supportsInterface(erc721InterfaceID) returns (bool result) {
            return result;
        } catch {
            return false;
        }
    }

    /// @notice Checks if a contract is likely an ERC1155 contract.
    /// @param _token The address of the contract.
    function isLikelyERC1155(address _token) internal view returns (bool) {
        bytes4 erc1155InterfaceID = 0xd9b67a26;
        try IERC165(_token).supportsInterface(erc1155InterfaceID) returns (bool supportsERC1155) {
            return supportsERC1155;
        } catch {
            return false;
        }
    }

    function pause() external onlyOwner {
        _pause();
    }

    function unpause() external onlyOwner {
        _unpause();
    }

    event QuestCreated(uint256 questId);
    event WinnerSet(uint256 questId, address winner);
    event RewardClaimed(
        uint256 questId,
        address claimer,
        uint256[] erc20tokensAmount,
        uint256[] erc721tokensId,
        ERC1155TokenReward[] erc1155Details
    );
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.21;

interface IAssetsHolder {
    function transferERC721(address tokenAddress, uint256 tokenId, address recipient) external;
    function transferERC20(address tokenAddress, uint256 amount, address recipient) external;
    function transferERC1155(address tokenAddress, uint256 id, uint256 amount, address recipient, bytes calldata data) external;
}