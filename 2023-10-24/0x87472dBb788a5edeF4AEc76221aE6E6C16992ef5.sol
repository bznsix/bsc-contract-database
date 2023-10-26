/**
 *Submitted for verification at testnet.bscscan.com on 2023-10-24
*/

/**
 *Submitted for verification at BscScan.com on 2023-06-06
 */

// SPDX-License-Identifier: MIT
// File: @openzeppelin/contracts/token/ERC20/IERC20.sol

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
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

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
    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

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
     function burnFrom(address account, uint256 amount) external;
     function burn(uint256 amount) external;
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

// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

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

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

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
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
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

// File: @openzeppelin/contracts/token/ERC721/IERC721Receiver.sol

// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC721/IERC721Receiver.sol)

pragma solidity ^0.8.0;

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
     * If any other value is returned or the interface is not implemented by the recipient, the transfer will be reverted.
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

// OpenZeppelin Contracts (last updated v4.8.0) (security/ReentrancyGuard.sol)

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
}

// File: @openzeppelin/contracts/token/ERC721/IERC721.sol

// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC721/IERC721.sol)

pragma solidity ^0.8.0;

/**
 * @dev Required interface of an ERC721 compliant contract.
 */
interface IERC721 is IERC165 {
    /**
     * @dev Emitted when `tokenId` token is transferred from `from` to `to`.
     */
    event Transfer(
        address indexed from,
        address indexed to,
        uint256 indexed tokenId
    );

    /**
     * @dev Emitted when `owner` enables `approved` to manage the `tokenId` token.
     */
    event Approval(
        address indexed owner,
        address indexed approved,
        uint256 indexed tokenId
    );

    /**
     * @dev Emitted when `owner` enables or disables (`approved`) `operator` to manage all of its assets.
     */
    event ApprovalForAll(
        address indexed owner,
        address indexed operator,
        bool approved
    );

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
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;

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
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Transfers `tokenId` token from `from` to `to`.
     *
     * WARNING: Usage of this method is discouraged, use {safeTransferFrom} whenever possible.
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
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

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
    ` * Operators can call {transferFrom} or {safeTransferFrom} for any token owned by the caller.
     *
     * Requirements:
     *
     * - The `operator` cannot be the caller.
     *
     * Emits an {ApprovalForAll} event.
     */
    function setApprovalForAll(address operator, bool _approved) external;

    /**
     * @dev Returns the account approved for `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function getApproved(uint256 tokenId)
        external
        view
        returns (address operator);

    /**
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     *
     * See {setApprovalForAll}
     */
    function isApprovedForAll(address owner, address operator)
        external
        view
        returns (bool);
}

// File: arma-staking.sol

pragma solidity ^0.8.7;

interface pancake {
    function getAmountsOut(uint256 amountIn, address[] memory path)
        external
        view
        returns (uint256[] memory amounts);
}

interface nft {
    function changePercentage(uint256 _arma, uint256 _ausd) external;
}

pragma solidity ^0.8.7;

contract paynftstake is Ownable,ReentrancyGuard {
    IERC721 private parentNFT;

    struct Stake {
        address _address;
        uint256 tokenId;
        uint256 starttime;
        uint256 endtime;
        address nftaddress;
        uint256 price;
    }

    Stake[] public stakes;

    struct Tokens {
        address nft;
        uint256 tokenid;
        uint256 status; // 0 Unstake 1 stake 2 buy
        uint256 price;
        address user;
    }

    struct NftStructure {
        address nftaddress;
        uint256 index;
        mapping(uint256 => Tokens) tokenid;
        uint256 price;
        uint isActiveArma;
        uint isActiveBusd;
    }

    // mapping(address => Tokens) tokens;
    mapping(address => uint256[]) public tokenids;
    mapping(address => NftStructure) public nftstruct;

    address[] public nfts;

    struct PriceStruct {
        address nftaddress;
        uint256 tokenId;
        uint256 price;
        uint256 timestamp;
    }

    PriceStruct[] public priceStruct;
    //NftStructure[] public nftstruct;

    address public routerAddress = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address public baseToken = 0x55d398326f99059fF775485246999027B3197955;
    address public aarma = 0xf1F0FA0287C47804636fFeF14e2C241f2587903e;

    uint256 public busdPrice = 1e18;
    uint256 public ispancake = 1;
    bool public buyWithBUSD = false;
    bool public buyWithArma = false;
    uint256 public maxBurnSupply = 21150000e18;
    uint public burnPercentage = 2;
    uint256 public defaultrate=0;
    uint256 public burnarma;

    // constructor(address[] memory _address, uint256[] memory price) {
    //     // for (uint256 i = 0; i < _address.length; i++) {
    //     //     nfts.push(_address[i]);
    //     //     nftstruct[_address[i]].price = price[i];
    //     //     nftstruct[_address[i]].index = nfts.length + 1;
    //     // }
    // }

    function changeBurnPercentage(uint value) public onlyOwner {
        burnPercentage = value;
    }

    function changeMaxBurnSupply(uint256 value) public onlyOwner {
        maxBurnSupply = value;
    }

    function changeBuyWithBUSD(bool status) public onlyOwner {
        buyWithBUSD = status;
    }
    function changeBuyWithArma(bool status) public onlyOwner {
        buyWithArma = status;
    }

    modifier BuyWithBUSDNotPaused(){
        require(buyWithBUSD == false,"Buy with BUSD is paused!");
        _;
    }
    modifier BuyWithArmaotPaused(){
        require(buyWithArma == false,"Buy with Arma is paused!");
        _;
    }

    function BuyWithArmaPause(address nftId,uint status) public  onlyOwner {
        nftstruct[nftId].isActiveArma = status;
    }
    function BuyWithBusdPause(address nftId,uint status) public onlyOwner {
        nftstruct[nftId].isActiveBusd = status;
    }

    function changepancake(uint256 _stat) public onlyOwner {
        ispancake = _stat;
    }

    function changedefaultrate(uint256 _rate) public onlyOwner{
        defaultrate = _rate;
    }

    function changeTokens(address base, address arma) public onlyOwner {
        baseToken = base;
        aarma = arma;
    }

    function addNft(address _address, uint256 price) public onlyOwner {
        nfts.push(_address);
        nftstruct[_address].price = price;
        nftstruct[_address].index = nfts.length + 1;
    }

    function changeNftRate(address _address, uint256 price) public onlyOwner {
         nftstruct[_address].price = price;
    }

    event Stakes(address nftId, uint256 _tokenId, address _user,uint time);

    function stake(address nftId, uint256 _tokenId) public {
        require(IERC721(nftId).ownerOf(_tokenId) == msg.sender, "Wrong Owner");
        if (nftstruct[nftId].tokenid[_tokenId].tokenid == 0) {
            tokenids[nftId].push(_tokenId);
            nftstruct[nftId].tokenid[_tokenId].price = nftstruct[nftId].price;
            stakes.push(
                Stake({
                    _address: msg.sender,
                    tokenId: _tokenId,
                    starttime: block.timestamp,
                    endtime: 0,
                    nftaddress: nftId,
                    price: nftstruct[nftId].price
                })
            );
        } else {
            require(
                nftstruct[nftId].tokenid[_tokenId].status != 1,
                "Already Staked"
            );
            stakes.push(
                Stake({
                    _address: msg.sender,
                    tokenId: _tokenId,
                    starttime: block.timestamp,
                    endtime: 0,
                    nftaddress: nftId,
                    price: nftstruct[nftId].tokenid[_tokenId].price
                })
            );
        }
        nftstruct[nftId].tokenid[_tokenId].user = msg.sender;
        nftstruct[nftId].tokenid[_tokenId].nft = nftId;
        nftstruct[nftId].tokenid[_tokenId].tokenid = _tokenId;
        nftstruct[nftId].tokenid[_tokenId].status = 1;
        parentNFT = IERC721(nftId);
        parentNFT.transferFrom(msg.sender, address(this), _tokenId);
        emit Stakes(nftId, _tokenId, msg.sender,block.timestamp);
    }

    event Unstake(address nftId, uint256 _tokenId, address _user,uint time);

    function unstake(address nftId, uint256 _tokenId) public onlyOwner {
        //    Smart Contract owner can unstake nft;
        // tokenids[nftId].push(_tokenId);
        // require(nftstruct[nftId].tokenid[_tokenId].user == msg.sender,"Address is not Owner");
        require(
            nftstruct[nftId].tokenid[_tokenId].status == 1,
            "Already Unstake"
        );
        uint256 price = (nftstruct[nftId].tokenid[_tokenId].price * 5e18) /
            100e18;
        nftstruct[nftId].tokenid[_tokenId].price =
            nftstruct[nftId].tokenid[_tokenId].price +
            price;
        nftstruct[nftId].tokenid[_tokenId].user = (address(this));
        nftstruct[nftId].tokenid[_tokenId].status = 0;

        priceStruct.push(
            PriceStruct({
                nftaddress: nftId,
                tokenId: _tokenId,
                price: nftstruct[nftId].tokenid[_tokenId].price,
                timestamp: block.timestamp
            })
        );
        emit Unstake(nftId, _tokenId, msg.sender,block.timestamp);
    }

    event Buynft(address nftId, uint256 _tokenId, address _user, uint256 _arma,uint time);
    event BuynftBUSD(
        address nftId,
        uint256 _tokenId,
        address _user,
        uint256 _arma,
        uint time
    );

    function buyNft(address nftId, uint256 _tokenId) public BuyWithArmaotPaused {
        require(
            nftstruct[nftId].tokenid[_tokenId].status == 0,
            "Already Purchased or Staked"
        );
        require(nftstruct[nftId].isActiveArma == 0,"Buy with Arma is paused!");
        nftstruct[nftId].tokenid[_tokenId].user = msg.sender;
        nftstruct[nftId].tokenid[_tokenId].status = 2;
        // address nftAddress = nftstruct[nftId].nftaddress;
        parentNFT = IERC721(nftId);
        IERC20 paytoken = IERC20(aarma);
        uint256 totalAarma = ((nftstruct[nftId].tokenid[_tokenId].price *
            1e18) / getTokenPrice());
        uint256 burnValue = (totalAarma * burnPercentage) / 100;
        if(paytoken.totalSupply() > maxBurnSupply){
            paytoken.burnFrom(msg.sender,burnValue);
            totalAarma -= burnValue;
            burnarma += burnValue;
        }
        paytoken.transferFrom(msg.sender, address(this), totalAarma);
        parentNFT.transferFrom(address(this), msg.sender, _tokenId);
        emit Buynft(nftId, _tokenId, msg.sender, totalAarma,block.timestamp);
    }

    function buyNftBUSD(address nftId, uint256 _tokenId) public BuyWithBUSDNotPaused {
        require(
            nftstruct[nftId].tokenid[_tokenId].status == 0,
            "Already Purchased or Staked"
        );
        require(nftstruct[nftId].isActiveBusd == 0,"Buy with Busd is paused!");
        nftstruct[nftId].tokenid[_tokenId].user = msg.sender;
        nftstruct[nftId].tokenid[_tokenId].status = 2;
        // address nftAddress = nftstruct[nftId].nftaddress;
        parentNFT = IERC721(nftId);
        IERC20 paytoken = IERC20(baseToken);
        uint256 totalbaseToken = nftstruct[nftId].tokenid[_tokenId].price;
        uint256 burnValue = (totalbaseToken * burnPercentage) / 100;
        if(IERC20(aarma).totalSupply() > maxBurnSupply){
            uint256 totalAarma = (((burnValue) / getTokenPrice()) * 1e18);
            IERC20(aarma).burn(totalAarma);
            totalbaseToken -= totalAarma;
            burnarma += totalAarma;
        }
        paytoken.transferFrom(msg.sender, address(this), totalbaseToken);
        parentNFT.transferFrom(address(this), msg.sender, _tokenId);
        emit BuynftBUSD(nftId, _tokenId, msg.sender, totalbaseToken,block.timestamp);
    }
    
    function getTokenPrice() public view returns (uint256) {
        if (ispancake == 1) {
            address[] memory path = new address[](2);
            path[0] = baseToken;
            path[1] = aarma;
            uint256[] memory price = pancake(routerAddress).getAmountsOut(
                1e18,
                path
            );
            return (price[0] * 1e18) / (price[1]);
        } else {
            return (defaultrate);
        }
        // return 125e14;
    }

    function changeRouter(address _address) public onlyOwner {
        routerAddress = _address;
    }

    function getnfttokens(address nftId)
        public
        view
        returns (uint256[] memory)
    {
        return tokenids[nftId];
    }

    function getprice(address _nftid, uint256 _tokenId)
        public
        view
        returns (uint256)
    {
        return nftstruct[_nftid].tokenid[_tokenId].price;
    }

    function gettokenstatus(address nftId, uint256 _tokenId)
        public
        view
        returns (
            uint256,
            uint256,
            address
        )
    {
        return (
            nftstruct[nftId].tokenid[_tokenId].price,
            nftstruct[nftId].tokenid[_tokenId].status,
            nftstruct[nftId].tokenid[_tokenId].user
        );
    }

    function withdrawToken(address token, uint256 amount) public onlyOwner {
        IERC20 paytoken = IERC20(token);
        paytoken.transfer(msg.sender, amount);
    }

    function withdrawCoin() public onlyOwner {
        payable(msg.sender).transfer(address(this).balance);
    }

    function withdrawERC721(address nftId, uint256 _tokenId) public onlyOwner {
        require(
            nftstruct[nftId].tokenid[_tokenId].status == 0,
            "invalid index !!"
        );
        parentNFT = IERC721(nftId);
        parentNFT.transferFrom(address(this), msg.sender, _tokenId);
    }
}