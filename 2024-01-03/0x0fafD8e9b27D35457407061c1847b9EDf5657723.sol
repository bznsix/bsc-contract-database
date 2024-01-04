// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/interfaces/IERC2981.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

contract MetaverserMarketplaceV2 is ReentrancyGuard {
    constructor(address _MTVT, address _NFT) {
        // Open the marketplace
        isClosed = false;

        // Set MTVT address
        MTVT = _MTVT;

        // Set NFT address
        NFT = _NFT;

        // Add admins
        isAdmin[msg.sender] = true;
        emit AdminSet(msg.sender, true);

        // 0 index is used to represent null listing
        listings[0] = Listing(address(0), 0, 0, 0, false, 0);
        emit ListingCreated(0, address(0), 0, 0, 0);
    }

    // Structs

    struct Listing {
        address seller;
        uint256 listId;
        uint256 tokenId;
        uint256 price;
        bool active;
        uint256 expiryDate;
    }

    // Storage

    bool public isClosed;

    address public immutable MTVT;
    address public immutable NFT;

    mapping(uint256 => Listing) private listings;
    mapping(address => uint256[]) private sellerListings;
    mapping(uint256 => bool) private isListed;

    mapping(address => bool) private isAdmin;
    uint256 public nextListingId = 1;

    uint256 public totalRoyaltyAmount;
    mapping(address => uint256) royaltyAmounts;

    // Modifiers

    modifier onlyAdmin() {
        require(
            isAdmin[msg.sender],
            "Marketplace: Only admin can call this function"
        );
        _;
    }

    // External functions

    // Function to list a token for sale
    // @dev _expiryDate is optional (0 means no expiry date)
    function listForSale(
        uint256 _tokenId,
        uint256 _price,
        uint256 _expiryDate
    ) external {
        require(!isClosed, "Marketplace: Marketplace is closed");
        require(
            IERC721(NFT).ownerOf(_tokenId) == msg.sender,
            "Marketplace: You are not the owner"
        );
        require(
            IERC721(NFT).isApprovedForAll(msg.sender, address(this)) ||
                IERC721(NFT).getApproved(_tokenId) == address(this),
            "Marketplace: Approve first"
        );
        require(
            _expiryDate >= block.timestamp || _expiryDate == 0,
            "Marketplace: Invalid expiry date"
        );
        require(!isListed[_tokenId], "Marketplace: Token already listed!");

        listings[nextListingId] = Listing(
            msg.sender,
            nextListingId,
            _tokenId,
            _price,
            true,
            (_expiryDate == 0 ? type(uint256).max : _expiryDate)
        );

        sellerListings[msg.sender].push(nextListingId);
        isListed[_tokenId] = true;

        emit ListingCreated(
            nextListingId,
            msg.sender,
            _price,
            _expiryDate,
            _tokenId
        );

        nextListingId++;
    }

    // Function to buy a listed token
    // @dev prior approval is required for the marketplace contract to spend MTVT on behalf of the buyer
    // @dev respects erc2981 royalty standard
    function buy(uint256 _listingId) external nonReentrant {
        require(!isClosed, "Marketplace: Marketplace is closed");
        Listing storage listing = listings[_listingId];
        require(
            listing.expiryDate > block.timestamp,
            "Marketplace: Listing expired"
        );
        require(_isValid(_listingId), "Marketplace: Invalid listing");
        require(
            listing.price <= IERC20(MTVT).balanceOf(msg.sender),
            "Marketplace: Insufficient funds"
        );

        IERC721(NFT).safeTransferFrom(
            listing.seller,
            msg.sender,
            listing.tokenId
        );

        (address royaltyReceiver, uint256 royaltyAmount) = IERC2981(NFT)
            .royaltyInfo(listing.tokenId, listing.price);

        if (royaltyReceiver != address(0) && royaltyAmount > 0) {
            totalRoyaltyAmount += royaltyAmount;
            royaltyAmounts[royaltyReceiver] += royaltyAmount;
            IERC20(MTVT).transferFrom(
                msg.sender,
                royaltyReceiver,
                royaltyAmount
            );
            IERC20(MTVT).transferFrom(
                msg.sender,
                listing.seller,
                listing.price - royaltyAmount
            );
        } else {
            IERC20(MTVT).transferFrom(
                msg.sender,
                listing.seller,
                listing.price
            );
        }

        for (uint256 i = 0; i < sellerListings[listing.seller].length; i++) {
            if (sellerListings[listing.seller][i] == _listingId) {
                sellerListings[listing.seller][i] = sellerListings[
                    listing.seller
                ][sellerListings[listing.seller].length - 1];
                sellerListings[listing.seller].pop();
                break;
            }
        }

        listing.active = false;
        isListed[listing.tokenId] = false;

        emit ListingBought(
            _listingId,
            msg.sender,
            listing.seller,
            listing.price,
            listing.tokenId
        );
    }

    function deleteListing(uint256 _listingId) external nonReentrant {
        require(!isClosed, "Marketplace: Marketplace is closed");
        Listing storage listing = listings[_listingId];
        require(
            listing.seller == msg.sender,
            "Marketplace: You are not the seller"
        );
        listings[_listingId].active = false;

        for (uint256 i = 0; i < sellerListings[msg.sender].length; i++) {
            if (sellerListings[msg.sender][i] == _listingId) {
                sellerListings[msg.sender][i] = sellerListings[msg.sender][
                    sellerListings[msg.sender].length - 1
                ];
                sellerListings[msg.sender].pop();
                break;
            }
        }

        isListed[listing.tokenId] = false;

        emit ListingDeleted(_listingId);
    }

    function changeExpiryDate(
        uint256 _listingId,
        uint256 _newExpiryDate
    ) external {
        require(!isClosed, "Marketplace: Marketplace is closed");
        Listing storage listing = listings[_listingId];
        require(listing.seller == msg.sender, "Marketplace: Not your listing");
        require(
            _newExpiryDate >= block.timestamp,
            "Marketplace: Invalid new expiry date"
        );
        require(_isValid(_listingId), "Marketplace: Invalid listing");
        listing.expiryDate = _newExpiryDate;

        emit ExpiryDateChanged(_listingId, _newExpiryDate);
    }

    function changePrice(uint256 _listingId, uint256 _newPrice) external {
        require(!isClosed, "Marketplace: Marketplace is closed");
        Listing storage listing = listings[_listingId];
        require(listing.seller == msg.sender, "Marketplace: Not your listing");
        require(_isValid(_listingId), "Marketplace: Invalid listing");
        listing.price = _newPrice;

        emit PriceChanged(_listingId, _newPrice);
    }

    // Admin functions

    function setAdmin(address _admin, bool _isAdmin) external onlyAdmin {
        require(isAdmin[_admin] != _isAdmin, "Marketplace: Invalid input");
        isAdmin[_admin] = _isAdmin;

        emit AdminSet(_admin, _isAdmin);
    }

    function closeMarketplace() external onlyAdmin {
        require(!isClosed, "Marketplace: Marketplace is already closed");
        isClosed = true;
    }

    function openMarketplace() external onlyAdmin {
        require(isClosed, "Marketplace: Marketplace is already open");
        isClosed = false;
    }

    // View functions

    function getAllListings() external view returns (uint256[] memory) {
        uint256[] memory validListings = new uint256[](nextListingId - 1);
        uint256 validListingCount = 0;

        for (uint256 i = 1; i < nextListingId; i++) {
            if (_isValid(i)) {
                validListings[validListingCount] = i;
                validListingCount++;
            }
            if (gasleft() < 10000) {
                break;
            }
        }

        uint256[] memory result = new uint256[](validListingCount);
        for (uint256 i = 0; i < validListingCount; i++) {
            result[i] = validListings[i];
        }

        return result;
    }

    function getAllListingsBySeller(
        address _seller
    ) external view returns (Listing[] memory) {
        uint256[] memory validListings = new uint256[](
            sellerListings[_seller].length
        );
        uint256 validListingCount = 0;

        for (uint256 i = 0; i < sellerListings[_seller].length; i++) {
            uint256 listingId = sellerListings[_seller][i];
            if (_isValid(listingId)) {
                validListings[validListingCount] = listingId;
                validListingCount++;
            }
        }

        Listing[] memory result = new Listing[](validListingCount);
        for (uint256 i = 0; i < validListingCount; i++) {
            result[i] = _getListingById(validListings[i]);
        }

        return result;
    }

    function getListingByIds(
        uint256[] calldata _listingIds
    ) external view returns (Listing[] memory) {
        Listing[] memory result = new Listing[](_listingIds.length);

        for (uint256 i = 0; i < _listingIds.length; i++) {
            result[i] = _getListingById(_listingIds[i]);
        }

        return result;
    }

    function getListingByRanges(
        uint256 _from,
        uint256 _to
    ) external view returns (Listing[] memory) {
        Listing[] memory validListings = new Listing[](_to - _from + 1);
        uint256 validListingCount = 0;

        for (uint256 i = _from; i <= _to; i++) {
            if (_isValid(i)) {
                validListings[validListingCount] = _getListingById(i);
                validListingCount++;
            }
        }

        Listing[] memory result = new Listing[](validListingCount);

        for (uint256 i = 0; i < validListingCount; i++) {
            result[i] = validListings[i];
        }

        return result;
    }

    function getListingById(
        uint256 _listingId
    ) external view returns (Listing memory) {
        return _getListingById(_listingId);
    }

    function getRoyaltyAmount(
        address _receiver
    ) external view returns (uint256) {
        return royaltyAmounts[_receiver];
    }

    // Internal view functions

    function _getListingById(
        uint256 _listingId
    ) internal view returns (Listing memory) {
        Listing memory listing = listings[_listingId];
        return listing;
    }

    function _isValid(uint256 listingId) internal view returns (bool) {
        Listing memory listing = listings[listingId];
        IERC721 token = IERC721(NFT);

        return ((token.getApproved(listing.tokenId) == address(this) ||
            token.isApprovedForAll(listing.seller, address(this))) &&
            token.ownerOf(listing.tokenId) == listing.seller &&
            listing.active &&
            listing.expiryDate > block.timestamp);
    }

    // Events

    event ListingCreated(
        uint256 indexed listingId,
        address indexed seller,
        uint256 price,
        uint256 expiryDate,
        uint256 tokenId
    );

    event ListingDeleted(uint256 indexed listingId);

    event ListingBought(
        uint256 indexed listingId,
        address indexed buyer,
        address indexed seller,
        uint256 price,
        uint256 tokenId
    );

    event ExpiryDateChanged(uint256 indexed listingId, uint256 newExpiryDate);

    event PriceChanged(uint256 indexed listingId, uint256 newPrice);

    event AdminSet(address indexed admin, bool isAdmin);
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (utils/introspection/IERC165.sol)

pragma solidity ^0.8.20;

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
// OpenZeppelin Contracts (last updated v5.0.0) (utils/ReentrancyGuard.sol)

pragma solidity ^0.8.20;

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
    uint256 private constant NOT_ENTERED = 1;
    uint256 private constant ENTERED = 2;

    uint256 private _status;

    /**
     * @dev Unauthorized reentrant call.
     */
    error ReentrancyGuardReentrantCall();

    constructor() {
        _status = NOT_ENTERED;
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
        // On the first call to nonReentrant, _status will be NOT_ENTERED
        if (_status == ENTERED) {
            revert ReentrancyGuardReentrantCall();
        }

        // Any calls to nonReentrant after this point will fail
        _status = ENTERED;
    }

    function _nonReentrantAfter() private {
        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = NOT_ENTERED;
    }

    /**
     * @dev Returns true if the reentrancy guard is currently set to "entered", which indicates there is a
     * `nonReentrant` function in the call stack.
     */
    function _reentrancyGuardEntered() internal view returns (bool) {
        return _status == ENTERED;
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC721/IERC721.sol)

pragma solidity ^0.8.20;

import {IERC165} from "../../utils/introspection/IERC165.sol";

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
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon
     *   a safe transfer.
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
     * - If the caller is not `from`, it must have been allowed to move this token by either {approve} or
     *   {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon
     *   a safe transfer.
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
     * - The `operator` cannot be the address zero.
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
// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.20;

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
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (interfaces/IERC2981.sol)

pragma solidity ^0.8.20;

import {IERC165} from "../utils/introspection/IERC165.sol";

/**
 * @dev Interface for the NFT Royalty Standard.
 *
 * A standardized way to retrieve royalty payment information for non-fungible tokens (NFTs) to enable universal
 * support for royalty payments across all NFT marketplaces and ecosystem participants.
 */
interface IERC2981 is IERC165 {
    /**
     * @dev Returns how much royalty is owed and to whom, based on a sale price that may be denominated in any unit of
     * exchange. The royalty amount is denominated and should be paid in that same unit of exchange.
     */
    function royaltyInfo(
        uint256 tokenId,
        uint256 salePrice
    ) external view returns (address receiver, uint256 royaltyAmount);
}
