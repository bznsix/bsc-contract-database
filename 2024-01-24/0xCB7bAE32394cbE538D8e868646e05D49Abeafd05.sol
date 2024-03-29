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
// OpenZeppelin Contracts v4.4.1 (interfaces/IERC20.sol)

pragma solidity ^0.8.0;

import "../token/ERC20/IERC20.sol";
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

pragma solidity ^0.8.0;

interface IBurn {
    function burn(address user,uint256 amount) external;
}// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface INFTFunction {
    function firstMint(address user,uint8 star) external returns (uint256);

    function normalMint(
        uint256 price,
        uint8 age,
        address user,
        address _root,
        uint8 star
    ) external returns (uint256);

    function burn(uint256 tokenId) external;

    function getPrice(uint256 tokenId) external view returns(uint256);

    function setPrice(uint256 tokenId, uint256 price) external;

    function getAge(uint256 tokenId) external view returns(uint8);

    function getStar(uint256 tokenId) external view returns(uint8);

    function getRoot(uint256 tokenId) external view returns(address);
}// SPDX-License-Identifier: MIT
/**
 *Submitted for verification at BscScan.com on 2021-04-23
*/

// File: contracts\interfaces\IPancakePair.sol

pragma solidity >=0.5.0;

interface IPancakePair {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address owner) external view returns (uint);

    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;

    event Mint(address indexed sender, uint amount0, uint amount1);
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint);
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function price0CumulativeLast() external view returns (uint);
    function price1CumulativeLast() external view returns (uint);
    function kLast() external view returns (uint);

    function mint(address to) external returns (uint liquidity);
    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;

    function initialize(address, address) external;
}// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./interfaces/IPancakePair.sol";
import "@openzeppelin/contracts/interfaces/IERC20.sol";
import "./interfaces/IBurn.sol";
import "./interfaces/INFTFunction.sol";

contract NftMarketplace is ReentrancyGuard, Ownable {
    IERC20 public astrErc20;
    IERC20 public lsErc20;
    IBurn public astrBurn;
    IERC20 public usdtAddress;
    address public nftAddress;

    IPancakePair public pair;
    address public marketAddrss;
    address public awardAddress;

    uint256 public startTime;
    uint256 public endTime;
    uint256 public totalShare;
    uint8 public star;

    bool public isBuy;
    bool public isSell;

    event nodeFeeShare(address indexed user, address indexed root, uint256 fee);
    event mintEvent(
        address indexed user,
        uint256 indexed tokenId,
        uint8 age,
        uint256 price,
        uint8 star
    );

    event burnEvent(address indexed user, uint256 indexed tokenId);

    event ItemListed(
        address indexed seller,
        uint256 indexed tokenId,
        uint256 price
    );

    event ItemCanceled(address indexed seller, uint256 indexed tokenId);

    event ItemBought(
        address indexed buyer,
        uint256 indexed tokenId,
        address seller,
        uint256 price
    );

    struct Listing {
        uint256 price;
        address seller;
    }

    // State Variables
    mapping(uint256 => Listing) private s_listings;

    constructor(
        IBurn _burnAddress,
        IERC20 _astrAddress,
        IERC20 _lsAddress,
        IERC20 _usdtAddress,
        address _nftAddress,
        IPancakePair _pair
    ) {
        astrBurn = _burnAddress;
        astrErc20 = _astrAddress;
        lsErc20 = _lsAddress;
        usdtAddress = _usdtAddress;
        nftAddress = _nftAddress;
        pair = _pair;
        isBuy = true;
        isSell = true;
    }

    // Function modifiers
    modifier notListed(uint256 tokenId, address owner) {
        Listing memory listing = s_listings[tokenId];
        if (listing.price > 0) {
            revert AlreadyListed(tokenId);
        }
        _;
    }

    modifier isOwner(uint256 tokenId, address spender) {
        IERC721 nft = IERC721(nftAddress);
        address owner = nft.ownerOf(tokenId);
        if (spender != owner) {
            revert NotOwner();
        }
        _;
    }

    modifier isListed(uint256 tokenId) {
        Listing memory listing = s_listings[tokenId];
        if (listing.price <= 0) {
            revert NotListed(tokenId);
        }
        _;
    }

    modifier feeCheck() {
        require(msg.value >= 0.0001 ether, "fee error");
        _;
    }

    function nftIdo() external payable feeCheck {
        require(totalShare > 0, "mint finished");
        require(block.timestamp >= startTime, "not start");
        require(block.timestamp <= endTime, "time end");
        uint256 price = 100 * 1e18;
        usdtAddress.transferFrom(msg.sender, address(this), price);
        INFTFunction func = INFTFunction(nftAddress);
        uint256 tokenId = func.firstMint(msg.sender, star);
        totalShare--;
        emit mintEvent(msg.sender, tokenId, 1, price, star);
    }

    function listItem(
        uint256 tokenId,
        uint256 lsAmount
    )
        external
        payable
        notListed(tokenId, msg.sender)
        isOwner(tokenId, msg.sender)
        feeCheck
    {
        require(isSell, "not open");
        INFTFunction func = INFTFunction(nftAddress);
        uint256 oldPrice = func.getPrice(tokenId);
        require(oldPrice < 1000 * 1e18, "only split");
        (uint256 price, uint256 fee, ) = getNextPriceAndFee(tokenId, lsAmount);
        if (func.getAge(tokenId) == 3) {
            transferFeeToProject(fee, lsAmount);
        } else {
            transferFee(tokenId, fee, lsAmount);
        }
        nftTransferCheck(tokenId, price);
        emit ItemListed(msg.sender, tokenId, price);
    }

    function getNextPriceAndFee(
        uint256 tokenId,
        uint256 lsAmount
    ) public view returns (uint256 price, uint256 fee, uint256 maxLs) {
        INFTFunction func = INFTFunction(nftAddress);
        uint256 oldPrice = func.getPrice(tokenId);
        uint8 age = func.getAge(tokenId);
        uint256 priceUnit;
        uint256 feeUnit = 6;
        if (oldPrice < 500 * 1e18) {
            priceUnit = 110;
        } else {
            priceUnit = 105;
        }

        uint256 feeU;
        if (age == 3) {
            price = oldPrice;
            feeU = (10 * 1e18 * 3) / 10;
        } else {
            price = (oldPrice * priceUnit) / 100;
            feeU = ((price - oldPrice) * feeUnit) / 10;
        }
        maxLs = feeU / 2;
        require(lsAmount <= maxLs, "ls overed");
        fee = getAstrFeeByU(feeU - lsAmount);
    }

    function getUFeeByAstr(uint256 fee) internal view returns (uint256) {
        uint112 _reserve0;
        uint112 _reserve1;
        (_reserve0, _reserve1, ) = pair.getReserves();
        uint256 feeU = (_reserve1 * fee) / _reserve0;
        return feeU;
    }

    function getAstrFeeByU(uint256 u) internal view returns (uint256) {
        uint112 _reserve0;
        uint112 _reserve1;
        (_reserve0, _reserve1, ) = pair.getReserves();
        uint256 fee = (_reserve1 * u) / _reserve0;
        return fee;
    }

    function transferFee(
        uint256 tokenId,
        uint256 fee,
        uint256 lsAmount
    ) internal {
        INFTFunction func = INFTFunction(nftAddress);
        uint256 percent1 = (fee * 1) / 6;
        address root = func.getRoot(tokenId);
        if (lsAmount > 0)
            lsErc20.transferFrom(msg.sender, marketAddrss, lsAmount);
        astrErc20.transferFrom(msg.sender, address(this), fee);
        astrBurn.burn(address(this), percent1);
        astrErc20.transfer(root, percent1);
        astrErc20.transfer(awardAddress, percent1 * 2);
        astrErc20.transfer(marketAddrss, fee - percent1 * 4);
        emit nodeFeeShare(msg.sender, root, percent1);
    }

    function transferFeeToProject(uint256 fee, uint256 lsAmount) internal {
        if (lsAmount > 0)
            lsErc20.transferFrom(msg.sender, marketAddrss, lsAmount);
        astrErc20.transferFrom(msg.sender, marketAddrss, fee);

        emit nodeFeeShare(msg.sender, marketAddrss, fee);
    }

    function nftTransferCheck(uint256 tokenId, uint256 price) internal {
        IERC721 nft = IERC721(nftAddress);
        if (nft.getApproved(tokenId) != address(this)) {
            revert NotApprovedForMarketplace();
        }
        s_listings[tokenId] = Listing(price, msg.sender);
    }

    function cancelListing(
        uint256 tokenId
    ) external payable isOwner(tokenId, msg.sender) isListed(tokenId) feeCheck {
        delete (s_listings[tokenId]);
        emit ItemCanceled(msg.sender, tokenId);
    }

    function buyItem(
        uint256 tokenId
    ) external payable isListed(tokenId) nonReentrant feeCheck {
        require(isBuy, "not open");
        Listing memory listedItem = s_listings[tokenId];
        usdtAddress.transferFrom(
            msg.sender,
            listedItem.seller,
            listedItem.price
        );
        delete (s_listings[tokenId]);
        IERC721(nftAddress).safeTransferFrom(
            listedItem.seller,
            msg.sender,
            tokenId
        );
        INFTFunction func = INFTFunction(nftAddress);
        func.setPrice(tokenId, listedItem.price);
        emit ItemBought(
            msg.sender,
            tokenId,
            listedItem.seller,
            listedItem.price
        );
    }

    /*
     * @notice 获取NFT卖家列表
     */
    function getListing(
        uint256 tokenId
    ) external view returns (Listing memory) {
        return s_listings[tokenId];
    }

    function split(
        uint256 tokenId,
        uint256 lsAmount
    ) external payable isOwner(tokenId, msg.sender) feeCheck {
        INFTFunction func = INFTFunction(nftAddress);
        uint256 oldPrice = func.getPrice(tokenId);
        require(oldPrice > 1000 * 1e18, "only sell");
        uint8 age = func.getAge(tokenId);
        uint8 _star = func.getStar(tokenId);

        func.burn(tokenId);
        emit burnEvent(msg.sender, tokenId);
        if (age == 1) {
            (, uint256 fee, ) = getNextPriceAndFee(tokenId, lsAmount);
            transferFeeToProject(fee, lsAmount);
            for (uint8 i = 0; i < 2; i++) {
                uint256 newMintId = func.normalMint(
                    5055 * 1e17,
                    2,
                    msg.sender,
                    msg.sender,
                    _star
                );
                emit mintEvent(msg.sender, newMintId, 2, 5055 * 1e17, _star);
            }
        }
        if (age == 2) {
            for (uint8 i = 0; i < 10; i++) {
                uint256 newMintId = func.normalMint(
                    100 * 1e18,
                    3,
                    msg.sender,
                    msg.sender,
                    _star
                );
                emit mintEvent(msg.sender, newMintId, 3, 100 * 1e18, _star);
            }
        }
    }

    function withdraw(address payable recipient) public onlyOwner {
        recipient.transfer(address(this).balance);
    }

    function withdrawToken(address _tokenAddress) public onlyOwner {
        IERC20(_tokenAddress).transfer(
            msg.sender,
            IERC20(_tokenAddress).balanceOf(address(this))
        );
    }

    function setAddress(
        address _awardAddress,
        address _marketAddrss
    ) public onlyOwner {
        awardAddress = _awardAddress;
        marketAddrss = _marketAddrss;
    }

    function setRoundInfo(
        uint256 _startTime,
        uint256 _endTime,
        uint256 _totalShare,
        uint8 _star
    ) external onlyOwner {
        startTime = _startTime;
        endTime = _endTime;
        totalShare = _totalShare;
        star = _star;
    }

    function setStart(bool _isBuy, bool _isSell) external onlyOwner {
        isBuy = _isBuy;
        isSell = _isSell;
    }

    function emergencyCancelList(uint256 tokenId) external onlyOwner {
        delete (s_listings[tokenId]);
        emit ItemCanceled(msg.sender, tokenId);
    }

    error PriceNotMet(uint256 tokenId, uint256 price);
    error ItemNotForSale(uint256 tokenId);
    error NotListed(uint256 tokenId);
    error AlreadyListed(uint256 tokenId);
    error NoProceeds();
    error NotOwner();
    error NotApprovedForMarketplace();
}