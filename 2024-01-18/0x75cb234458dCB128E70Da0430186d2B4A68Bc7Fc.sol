
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/// @title NFsTay 
/// @author Rabeeb Aqdas

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

// File: @openzeppelin/contracts/access/Ownable.sol


// OpenZeppelin Contracts (last updated v5.0.0) (access/Ownable.sol)

  


/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * The initial owner is set to the address provided by the deployer. This can
 * later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    /**
     * @dev The caller account is not authorized to perform an operation.
     */
    error OwnableUnauthorizedAccount(address account);

    /**
     * @dev The owner is not a valid owner account. (eg. `address(0)`)
     */
    error OwnableInvalidOwner(address owner);

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the address provided by the deployer as the initial owner.
     */
    constructor(address initialOwner) {
        if (initialOwner == address(0)) {
            revert OwnableInvalidOwner(address(0));
        }
        _transferOwnership(initialOwner);
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
        if (owner() != _msgSender()) {
            revert OwnableUnauthorizedAccount(_msgSender());
        }
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
        if (newOwner == address(0)) {
            revert OwnableInvalidOwner(address(0));
        }
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

// File: @openzeppelin/contracts/security/ReentrancyGuard.sol


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

// File: @openzeppelin/contracts/token/ERC20/IERC20.sol


// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC20/IERC20.sol)

  

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

// File: @openzeppelin/contracts/token/ERC721/IERC721Receiver.sol


// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC721/IERC721Receiver.sol)

  

/**
 * @title ERC721 token receiver interface
 * @dev Interface for any contract that wants to support safeTransfers
 * from ERC721 asset contracts.
 */
interface IERC721Receiver {
    /**
     * @dev Whenever an {IERC721} `tokenId` token is transferred to this contract via {IERC721-safeTransferFrom}
     * by `operator` from `from`, this function is called.
     *
     * It must return its Solidity selector to confirm the token transfer.
     * If any other value is returned or the interface is not implemented by the recipient, the transfer will be
     * reverted.
     *
     * The selector can be obtained in Solidity with `IERC721Receiver.onERC721Received.selector`.
     */
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
}

// File: @openzeppelin/contracts/utils/introspection/IERC165.sol


// OpenZeppelin Contracts (last updated v5.0.0) (utils/introspection/IERC165.sol)

  

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

// File: @openzeppelin/contracts/token/ERC721/IERC721.sol


// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC721/IERC721.sol)

  


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


///////////////////////////////////////////////Interfaces//////////////////////////////////////////////////////////


interface ITreasury {
    function getMyUSDUpdatedPrice() external view returns (uint256 _myUsdPrice);
}


interface IMyUSD {
    function mint(address recipient, uint256 amount) external returns (bool);
}

///////////////////////////////////////////////Errors//////////////////////////////////////////////////

error PriceNotMet(uint256 tokenId, uint256 price);
error ItemNotForSale(uint256 tokenId);
error NotListed(uint256 tokenId);
error AlreadyListed(uint256 tokenId);
error NotLister(uint256 tokenId);   
error YouAreSeller(uint256 tokenId);    
error ConditionNotMet(uint256 price);   
error NoProceeds();
error NotOwner();
error NotApprovedForMarketplace();
error PriceMustBeAboveZero();
error InvalidCurrency();
error NotEnoughBalance(uint256 amount);
error TransferFailed();
error InvalidLength();

contract NFsTay is
    ReentrancyGuard,
    IERC721Receiver,
    Ownable
{

///////////////////////////////////////////////Structs//////////////////////////////////////////////////////////

    struct Listing {
        address currency;
        uint256 price;
        address seller;
        uint256 timestamp;
    }

///////////////////////////////////////////////Events//////////////////////////////////////////////////

    event ItemListed(
        address indexed seller,
        uint256 indexed tokenId,
        address currencyAddress,
        uint256 price
    );

    event ItemCanceled(
        address indexed seller,
        uint256 indexed tokenId
    );

    event ItemBought(
        address indexed buyer,
        uint256 indexed tokenId,
        address currencyAddress,
        uint256 price
    );

/////////////////////////////////////////State Variables/////////////////////////////////////////////

    uint256 public RockApyPerSecond = 4_756_468_797_564;
    address private usdcAddress;
    IERC721 private _nftHelper;
    IMyUSD private _myusdHelper;
    ITreasury private _treasuryHelper;

    mapping(uint256 => Listing) private listings;   

    receive() external payable { }

    constructor(
        address _myRocksAddress,
        address _myUsdAddress,
        address _usdcAddress,
        address _treasuryAddress
    ) Ownable(_msgSender()) {

        usdcAddress = _usdcAddress;
        _nftHelper = IERC721(_myRocksAddress);
        _myusdHelper = IMyUSD(_myUsdAddress);
       _treasuryHelper = ITreasury(_treasuryAddress);
    }

    modifier notListed(uint256 tokenId) {
        Listing memory listing = listings[tokenId];
        if (listing.price > 0) revert AlreadyListed(tokenId);
        
        _;
    }

    modifier isListed(uint256 tokenId) {
        Listing memory listing = listings[tokenId];
        if (listing.price == 0) revert NotListed(tokenId);
        
        _;
    }
    function _currenyValidation(address currency) private view returns (bool) {
        if(currency == address(_myusdHelper) || currency == usdcAddress || currency == address(0)) return true;
        else return false;
    }

    modifier isOwner(
        uint256 tokenId,
        address spender
    ) {
        address owner = _nftHelper.ownerOf(tokenId);
        if (spender != owner) revert NotLister(tokenId);
        
        _;
    }

    modifier isLister(
        uint256 tokenId,
        address spender
    ) {
        Listing memory listing = listings[tokenId];
        if (listing.seller != spender) revert NotLister(tokenId);
        
        _;
    }

/////////////////////////////////////////Main Functions/////////////////////////////////////////////

    /*
     * @notice Method for listing NFT
     * @param tokenId Token ID of NFT
     * @param currencyAddress the address of token in which you want to sell your NFT
     * @param price the amount at which you want to sell your NFT
     */
    function listItem(
        uint256 tokenId,
        address currencyAddress,
        uint256 price
    )
        external
        notListed(tokenId)
        isOwner(tokenId, _msgSender())
    {
        if (price == 0) revert PriceMustBeAboveZero();
        bool validation = _currenyValidation(currencyAddress);
        if(!validation) revert InvalidCurrency();
        IERC721 nft = _nftHelper;
        if (nft.getApproved(tokenId) != address(this) &&
           !nft.isApprovedForAll(_msgSender(), address(this))
        ) revert NotApprovedForMarketplace();
        nft.safeTransferFrom(_msgSender(), address(this), tokenId);
        listings[tokenId] = Listing(
            currencyAddress,
            price,
            _msgSender(),
            block.timestamp
        );
        emit ItemListed(
            _msgSender(),
            tokenId,
            currencyAddress,
            price
        );
    }

    /*
     * @notice Method for cancelling listing
     * @param tokenId Token ID of NFT
     */
    function cancelListing(
        uint256 tokenId
    )
        external
        isListed(tokenId)
        isLister(tokenId, _msgSender())
    {
        Listing memory listedItem = listings[tokenId];
        _nftHelper.safeTransferFrom(
            address(this),
            _msgSender(),
            tokenId
        );
        uint256 twapPrice = _treasuryHelper.getMyUSDUpdatedPrice();       
        if(twapPrice >= 1.01e18) {
        uint256 time = block.timestamp - listedItem.timestamp;
        uint256 reward = time * RockApyPerSecond;
        _myusdHelper.mint(listedItem.seller,reward);
        }
        delete (listings[tokenId]);
        emit ItemCanceled(_msgSender(), tokenId);
    }

    /*
     * @notice Method for buying listing
     * @param tokenId Token ID of NFT that you want to buy
     */
    function buyItem(
        uint256 tokenId
    )
        external
        payable
        isListed(tokenId)
        nonReentrant
    {

        Listing memory listedItem = listings[tokenId];
        if(listedItem.seller == _msgSender()) revert YouAreSeller(tokenId);
        if (listedItem.currency == address(0)) {
        if (msg.value < ((listedItem.price * 11) / 10)) revert PriceNotMet(tokenId, listedItem.price);
            
        (bool success,) = payable(listedItem.seller).call{value : ((listedItem.price * 9) / 10)}("");
            if(!success) revert TransferFailed();
        } else {
            if (
                IERC20(listedItem.currency).allowance(
                    _msgSender(),
                    address(this)
                ) < ((listedItem.price * 11) / 10)
            ) revert NotApprovedForMarketplace();
            IERC20(listedItem.currency).transferFrom(
                _msgSender(),
                listedItem.seller,
                ((listedItem.price * 9) / 10)
            );
            IERC20(listedItem.currency).transferFrom(
                _msgSender(),
                address(this),
                ((listedItem.price * 2) / 10)
            );
        }
        uint256 twapPrice = _treasuryHelper.getMyUSDUpdatedPrice();       
        if(twapPrice >= 1.01e18) {
        uint256 time = block.timestamp - listedItem.timestamp;
        uint256 reward = time * RockApyPerSecond;
        _myusdHelper.mint(listedItem.seller,reward);
        }
        delete (listings[tokenId]); 
        _nftHelper.safeTransferFrom(
            address(this),
            _msgSender(),
            tokenId
        );
        emit ItemBought(
            _msgSender(),
            tokenId,
            listedItem.currency,
            listedItem.price
        );
    }

    /*
     * @notice Method for updating listing
     * @param tokenId Token ID of NFT
     * @param newPrice Price in Wei of the item
     */
    function updateListing(
        uint256 tokenId,
        address newCurrencyAddress,
        uint256 newPrice
    )
        external
        isListed(tokenId)
        nonReentrant
        isLister(tokenId, _msgSender())
    {
        if (newPrice == 0) revert PriceMustBeAboveZero();
        
        listings[tokenId].price = newPrice;
        listings[tokenId].currency = newCurrencyAddress;
        emit ItemListed(
            _msgSender(),
            tokenId,
            newCurrencyAddress,
            newPrice
        );
    }

     /*
     * @notice Method for collecting reward earned by listing NFT
     * @param tokenIds[] of NFT (maximum 25)
     */

    function collectReward(uint256[] memory _tokenIds)  external {
        uint256 length = _tokenIds.length;
        if(length == 0 ||  length > 25) revert InvalidLength();
        uint256 twapPrice = _treasuryHelper.getMyUSDUpdatedPrice();    
        if(twapPrice < 1.01e18) revert ConditionNotMet(twapPrice); 
    
        uint256 totalTime;
        for(uint256 i ; i < length ; ++i) {
        Listing memory listing = listings[_tokenIds[i]];
        if (listing.price == 0) revert NotListed(_tokenIds[i]);
        if (listing.seller != _msgSender()) revert NotLister(_tokenIds[i]);
        
        totalTime = totalTime + (block.timestamp - listing.timestamp);
        listing.timestamp = block.timestamp;
        listings[_tokenIds[i]] = listing;
        }
        uint256 reward = totalTime * RockApyPerSecond;
        if(reward > 0) _myusdHelper.mint(_msgSender(),reward);
        
    }

/////////////////////////////////////////Ony Owner Functions/////////////////////////////////////////////
    
     /*
     * @notice Method for updating per second APY only for owner
     * @param _RockApyPerSecond per second APY
     */

    function updateAprPerRock(uint256 _RockApyPerSecond) external onlyOwner {
        RockApyPerSecond = _RockApyPerSecond;
    }

    /*
     * @notice Method for withdrawing BNB only for owner
     */

    function withdrawBNB() external onlyOwner {
        address owner = owner();
       uint256 amount = address(this).balance;
        if (amount == 0) revert NotEnoughBalance(amount);
        (bool success,) = payable(owner).call{value : amount}("");
        if(!success) revert TransferFailed();
    }

    /*
     * @notice Method for withdrawing tokens only for owner
     * @param address of token
     */

    function withdrawToken(address token) external onlyOwner {
        address owner = owner();
        bool validation = _currenyValidation(token);
        if(!validation) revert InvalidCurrency();
        uint256 amount = IERC20(token).balanceOf(address(this));
        if (amount == 0) revert NotEnoughBalance(amount);
        IERC20(token).transfer(owner, amount);
    }


/////////////////////////////////////////Getter Functions/////////////////////////////////////////////

    /*
     * @notice Method for get listing
     * @param tokenId Token ID of NFT
     * @returns the details of listed nft
     */

    function getListing(
        uint256 tokenId
    ) external view returns (Listing memory) {
        return listings[tokenId];
    }


    function onERC721Received(
        address /*operator*/,
        address /*from*/,
        uint256 /*tokenId*/,
        bytes calldata /*data*/
    ) external pure override returns (bytes4) {
        return IERC721Receiver.onERC721Received.selector;
    }
}
