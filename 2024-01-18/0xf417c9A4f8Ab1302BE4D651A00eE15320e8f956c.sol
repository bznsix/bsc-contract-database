// File: @openzeppelin/contracts/security/ReentrancyGuard.sol


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

// File: @openzeppelin/contracts/utils/Context.sol


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

// File: @openzeppelin/contracts/access/Ownable.sol


// OpenZeppelin Contracts (last updated v4.9.0) (access/Ownable.sol)

pragma solidity ^0.8.0;


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

// File: @openzeppelin/contracts/utils/introspection/IERC165.sol


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

// File: @openzeppelin/contracts/token/ERC721/IERC721.sol


// OpenZeppelin Contracts (last updated v4.9.0) (token/ERC721/IERC721.sol)

pragma solidity ^0.8.0;


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

// File: @openzeppelin/contracts/token/ERC20/IERC20.sol


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

// File: NFTMarketplace.sol







pragma solidity ^0.8.19;

contract NFTMarketplace is ReentrancyGuard, Ownable {

    // Variables
    address private adminAddress; // the admin address
    uint private feePercent; // the fee percentage on sales 
    uint public itemCount = 0; 
    uint public itemSoldCount = 0;
    uint public itemRemovedCount = 0;

    IERC20 private cfxtoken;
    address private cfxtokenaddress;

    // only Admin overide
    modifier onlyAdmin() {
        require(msg.sender == adminAddress, "Only Admin");
        _;
    }

    struct Item {
        uint itemId;
        IERC721 nft;
        uint tokenId;
        uint price;
        address payable seller;
        address payable owner;
        bool sold;
        bool removed;
    }

    // itemId -> Item
    mapping(uint => Item) public items;

    event Offered(
        uint itemId,
        address indexed nft,
        uint tokenId,
        uint price,
        address indexed seller
    );

    event Bought(
        uint itemId,
        address indexed nft,
        uint tokenId,
        uint price,
        address indexed seller,
        address indexed buyer
    );

    event Removed(
        uint itemId,
        address indexed nft,
        uint tokenId,
        uint price,
        address indexed seller
    );

    constructor(uint _feePercent) {
        adminAddress = payable(msg.sender);
        feePercent = _feePercent;

        cfxtokenaddress = 0xDF5Ba79F0FD70c6609666d5eD603710609a530AB; //LIVE
        cfxtoken = IERC20(cfxtokenaddress);

    }

    function setPercentage(uint _newPercentage) public onlyAdmin {
        feePercent = _newPercentage;
    }

    function getPercentage() public view onlyAdmin returns (uint) {
        return feePercent;
    }

    // Make item to offer on the marketplace
    function makeItem(IERC721 _nft, uint _tokenId, uint _price) external nonReentrant {
        require(_price > 0, "< zero");
        // increment itemCount
        itemCount ++;
        // transfer nft
        _nft.transferFrom(msg.sender, address(this), _tokenId);
        // add new item to items mapping
        items[itemCount] = Item (
            itemCount,
            _nft,
            _tokenId,
            _price,
            payable(msg.sender),
            payable(address(0)),    // Initial buyer's address (zero address) wrapped in the payable type
            false,
            false
        );

        // emit Offered event
        emit Offered(
            itemCount,
            address(_nft),
            _tokenId,
            _price,
            msg.sender
        );
    }

    function purchaseItem(uint _itemId) external payable nonReentrant {
        uint _totalPrice = getTotalPrice(_itemId);
        Item storage item = items[_itemId];
        require(_itemId > 0 && _itemId <= itemCount, "doesn't exist");
        // using base crypto BNB or ETH
        //require(msg.value >= _totalPrice, "not enough ether to cover item price and market fee");
        
        require(!item.sold, "item sold");
        require(!item.removed, "item removed");

        // pay seller and the Marketplace Contract
        cfxtoken.transferFrom(msg.sender, item.seller, item.price );
        // Marketplace contract holds the feePercent
        cfxtoken.transferFrom(msg.sender, address(this), _totalPrice - item.price );

        // update item to sold
        item.sold = true;
        item.owner = payable(msg.sender);
        // transfer nft to buyer
        item.nft.transferFrom(address(this), msg.sender, item.tokenId);
        
        //increment Sold counter
        itemSoldCount ++;

        // emit Bought event
        emit Bought(
            _itemId,
            address(item.nft),
            item.tokenId,
            item.price,
            item.seller,
            msg.sender
        );
    }

    function removeItem(uint _itemId) external nonReentrant {
        Item storage item = items[_itemId];
        require(_itemId > 0 && _itemId <= itemCount, "doesn't exist");
        // using base crypto BNB or ETH
        //require(msg.value >= _totalPrice, "not enough ether to cover item price and market fee");

        require(!item.sold, "item sold");   
        require(!item.removed, "item already removed");

        // admin is allowed to remove
        if (msg.sender != adminAddress){
            require(msg.sender == item.seller, "not item seller");
        }
       
        // update item to removed
        item.removed = true;
        //owner returns to seller
        item.owner = payable(item.seller);
        // transfer nft back to seller msg.sender is equal to item.seller or is admin
        item.nft.transferFrom(address(this), item.seller, item.tokenId);
        
        //increment Removed counter
        itemRemovedCount ++;
        
        // emit Removed event
        emit Removed(
            _itemId,
            address(item.nft),
            item.tokenId,
            item.price,
            item.seller
        );
    }

    function fetchMarketItemsBySeller(address seller) public view returns (Item[] memory) {
        // Get the total number of items and calculate the number of unsold items
        uint256 unsoldItemCount = itemCount - itemSoldCount - itemRemovedCount;
        uint256 currentIndex = 0; // Current index for populating the 'items' array

        // Create a new dynamic array 'items' to store unsold market items
        Item[] memory tempItemsList = new Item[](unsoldItemCount);

        // Iterate through all items to find unsold items
        uint256 itemFilterCount;
        for (uint256 i = 0; i < itemCount; i++) {
            // Check if the item's owner is the zero address (not assigned to any owner so NOT sold)
            if (items[i + 1].owner == address(0) && payable(items[i + 1].seller) == seller) {
                uint256 currentId = i + 1; // Get the current item's ID
                Item storage currentItem = items[currentId]; // Get the reference to the current market item
                tempItemsList[currentIndex] = currentItem; // Add the unsold item to the 'items' array
                currentIndex += 1; // Increment the current index for the next item
                itemFilterCount+= 1; //Increment actual itemCount
            }
        }

        Item[] memory itemsList = new Item[](itemFilterCount);

    
        for(uint256 i = 0; i < itemFilterCount; i++){
            itemsList[i] = tempItemsList[i];
        }

        return itemsList; // Return the array of unsold market items
    }

    function fetchMarketItemsByCollection(address collection) public view returns (Item[] memory) {
        // Get the total number of items and calculate the number of unsold items
        uint256 unsoldItemCount = itemCount - itemSoldCount - itemRemovedCount;
        uint256 currentIndex = 0; // Current index for populating the 'items' array

        // Create a new dynamic array 'items' to store unsold market items
        Item[] memory tempItemsList = new Item[](unsoldItemCount);

        // Iterate through all items to find unsold items
        uint256 itemFilterCount;
        for (uint256 i = 0; i < itemCount; i++) {
            // Check if the item's owner is the zero address (not assigned to any owner so NOT sold)
            if (items[i + 1].owner == address(0) && address(items[i + 1].nft) == collection) {
                uint256 currentId = i + 1; // Get the current item's ID
                Item storage currentItem = items[currentId]; // Get the reference to the current market item
                tempItemsList[currentIndex] = currentItem; // Add the unsold item to the 'items' array
                currentIndex += 1; // Increment the current index for the next item
                itemFilterCount+= 1; //Increment actual itemCount
            }
        }

        Item[] memory itemsList = new Item[](itemFilterCount);

    
        for(uint256 i = 0; i < itemFilterCount; i++){
            itemsList[i] = tempItemsList[i];
        }

        return itemsList; // Return the array of unsold market items
    }

    function fetchMarketItems() public view returns (Item[] memory) {
        // Get the total number of items and calculate the number of unsold items
        uint256 unsoldItemCount = itemCount - itemSoldCount - itemRemovedCount;
        uint256 currentIndex = 0; // Current index for populating the 'items' array

        // Create a new dynamic array 'items' to store unsold market items
        Item[] memory itemsList = new Item[](unsoldItemCount);

        // Iterate through all items to find unsold items
        for (uint256 i = 0; i < itemCount; i++) {
            // Check if the item's owner is the zero address (not assigned to any owner so NOT sold)
            if (items[i + 1].owner == address(0)) {
                uint256 currentId = i + 1; // Get the current item's ID
                Item storage currentItem = items[currentId]; // Get the reference to the current market item
                itemsList[currentIndex] = currentItem; // Add the unsold item to the 'items' array
                currentIndex += 1; // Increment the current index for the next item
            }
        }

        return itemsList; // Return the array of unsold market items
    }

    function fetchMarketSoldItemsBySeller(address seller) public view returns (Item[] memory) {
        // Get the total number of items and calculate the number of unsold items
        uint256 soldItemCount = itemSoldCount;
        uint256 currentIndex = 0; // Current index for populating the 'items' array

        // Create a new dynamic array 'items' to store unsold market items
        Item[] memory tempItemsList = new Item[](soldItemCount);

        // Iterate through all items to find unsold items
        uint256 itemFilterCount;
        for (uint256 i = 0; i < itemCount; i++) {
            // Check if the item's owner is the zero address (not assigned to any owner so NOT sold)
            if (items[i + 1].sold == true && payable(items[i + 1].seller) == seller) {
                uint256 currentId = i + 1; // Get the current item's ID
                Item storage currentItem = items[currentId]; // Get the reference to the current market item
                tempItemsList[currentIndex] = currentItem; // Add the unsold item to the 'items' array
                currentIndex += 1; // Increment the current index for the next item
                itemFilterCount+= 1; //Increment actual itemCount
            }
        }

        Item[] memory itemsList = new Item[](itemFilterCount);

    
        for(uint256 i = 0; i < itemFilterCount; i++){
            itemsList[i] = tempItemsList[i];
        }

        return itemsList; // Return the array of unsold market items
    }

    function fetchMarketSoldItemsByCollection(address collection) public view returns (Item[] memory) {
        // Get the total number of items and calculate the number of unsold items
        uint256 soldItemCount = itemSoldCount;
        uint256 currentIndex = 0; // Current index for populating the 'items' array

        // Create a new dynamic array 'items' to store unsold market items
        Item[] memory tempItemsList = new Item[](soldItemCount);

        // Iterate through all items to find unsold items
        uint256 itemFilterCount;
        for (uint256 i = 0; i < itemCount; i++) {
            // Check if the item's owner is the zero address (not assigned to any owner so NOT sold)
            if (items[i + 1].sold == true && address(items[i + 1].nft) == collection) {
                uint256 currentId = i + 1; // Get the current item's ID
                Item storage currentItem = items[currentId]; // Get the reference to the current market item
                tempItemsList[currentIndex] = currentItem; // Add the unsold item to the 'items' array
                currentIndex += 1; // Increment the current index for the next item
                itemFilterCount+= 1; //Increment actual itemCount
            }
        }

        Item[] memory itemsList = new Item[](itemFilterCount);

    
        for(uint256 i = 0; i < itemFilterCount; i++){
            itemsList[i] = tempItemsList[i];
        }

        return itemsList; // Return the array of unsold market items
    }

    function fetchMarketSoldItems() public view returns (Item[] memory) {
        // Get the total number of items and calculate the number of unsold items
        uint256 soldItemCount = itemSoldCount;
        uint256 currentIndex = 0; // Current index for populating the 'items' array

        // Create a new dynamic array 'items' to store unsold market items
        Item[] memory itemsList = new Item[](soldItemCount);

        // Iterate through all items to find sold items
        for (uint256 i = 0; i < itemCount; i++) {
            // Check if the item's are sold)
            if (items[i + 1].sold == true) {
                uint256 currentId = i + 1; // Get the current item's ID
                Item storage currentItem = items[currentId]; // Get the reference to the current market item
                itemsList[currentIndex] = currentItem; // Add the unsold item to the 'items' array
                currentIndex += 1; // Increment the current index for the next item
            }
        }

        return itemsList; // Return the array of unsold market items
    }

    function fetchMarketRemovedItems() public view returns (Item[] memory) {
        // Get the total number of items and calculate the number of unsold items
        uint256 removedItemCount = itemRemovedCount;
        uint256 currentIndex = 0; // Current index for populating the 'items' array

        // Create a new dynamic array 'items' to store unsold market items
        Item[] memory itemsList = new Item[](removedItemCount);

        // Iterate through all items to find removed items
        for (uint256 i = 0; i < itemCount; i++) {
            // Check if the item's are removed)
            if (items[i + 1].removed == true) {
                uint256 currentId = i + 1; // Get the current item's ID
                Item storage currentItem = items[currentId]; // Get the reference to the current market item
                itemsList[currentIndex] = currentItem; // Add the unsold item to the 'items' array
                currentIndex += 1; // Increment the current index for the next item
            }
        }

        return itemsList; // Return the array of unsold market items
    }

    function getTotalPrice(uint _itemId) view public returns(uint){
        return((items[_itemId].price*(100 + feePercent))/100);
    }

    //Only admin

    function withdraw(uint256 _quantity) public payable onlyOwner() {
        
        uint256 quantity;
        quantity = _quantity * (10**uint256(18));
        cfxtoken.transfer(msg.sender, quantity);
    }

    function setCfxAddress(address _newAddress) public onlyOwner() {
        cfxtokenaddress = _newAddress;
        cfxtoken = IERC20(cfxtokenaddress);
    }

    function getCfxAddress() public onlyOwner() view returns(address) {
        return cfxtokenaddress;
    }

}