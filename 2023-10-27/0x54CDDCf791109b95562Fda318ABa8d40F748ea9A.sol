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
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (utils/Address.sol)

pragma solidity ^0.8.1;

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     *
     * [IMPORTANT]
     * ====
     * You shouldn't rely on `isContract` to protect against flash loan attacks!
     *
     * Preventing calls from contracts is highly discouraged. It breaks composability, breaks support for smart wallets
     * like Gnosis Safe, and does not provide security since it can be circumvented by calling from a contract
     * constructor.
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.

        return account.code.length > 0;
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verify that a low level call to smart-contract was successful, and revert (either by bubbling
     * the revert reason or using the provided one) in case of unsuccessful call or if target was not a contract.
     *
     * _Available since v4.8._
     */
    function verifyCallResultFromTarget(
        address target,
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        if (success) {
            if (returndata.length == 0) {
                // only check isContract if the call was successful and the return data is empty
                // otherwise we already know that it was a contract
                require(isContract(target), "Address: call to non-contract");
            }
            return returndata;
        } else {
            _revert(returndata, errorMessage);
        }
    }

    /**
     * @dev Tool to verify that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason or using the provided one.
     *
     * _Available since v4.3._
     */
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            _revert(returndata, errorMessage);
        }
    }

    function _revert(bytes memory returndata, string memory errorMessage) private pure {
        // Look for revert reason and bubble it up if present
        if (returndata.length > 0) {
            // The easiest way to bubble the revert reason is using memory via assembly
            /// @solidity memory-safe-assembly
            assembly {
                let returndata_size := mload(returndata)
                revert(add(32, returndata), returndata_size)
            }
        } else {
            revert(errorMessage);
        }
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
// OpenZeppelin Contracts (last updated v4.6.0) (utils/math/SafeMath.sol)

pragma solidity ^0.8.0;

// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is generally not needed starting with Solidity 0.8, since the compiler
 * now has built in overflow checking.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator.
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {trySub}.
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting with custom message when dividing by zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryMod}.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}
// Csdoge Marketplace NFT Sell contract

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "./ICsdogeSign.sol";

interface INftMint {
    function getApproved(uint256) external view returns (address);

    function safeTransferFrom(
        address,
        address,
        uint256
    ) external;

    function ownerOf(uint256) external view returns (address);

    function approve(address, uint256) external;
}

contract CsdogeNFTSell is Ownable, IERC721Receiver {
    using SafeMath for uint256;

    address public signContract;
    address public csdogeNftContract;
    address public treasuryWallet;
    address public devWallet;
    uint256 public marketplaceFee; // 150
    uint256 public devFee; // 50

    enum SaleStatus {
        NotInSale,
        InFixedSale,
        InAuction
    }

    struct FixedSale {
        address nftSeller;
        address nftBuyer;
        uint256 salePrice;
    }

    struct Auction {
        uint256 auctionStartTimestamp;
        uint256 auctionEndTimestamp;
        uint256 startPrice;
        uint256 nftHighestBidPrice;
        address nftHighestBidder;
        address nftSeller;
    }

    mapping(address => mapping(uint256 => FixedSale)) fixedSales; // nft address -> tokenId -> FixedSale
    mapping(address => mapping(uint256 => Auction)) auctions; // nft address -> tokenId -> Auction
    mapping(address => mapping(uint256 => SaleStatus)) public nftSaleStatus; // nft address -> tokenId -> SaleStatus

    event NftFixedSaleListed(
        address nftSeller,
        address nftAddress,
        uint256 tokenId,
        uint256 salePrice,
        uint256 listTimestamp
    );

    event NftFixedSaleCancelled(
        address nftSeller,
        address nftAddress,
        uint256 tokenId
    );

    event NftFixedSalePriceUpdated(
        address nftSeller,
        address nftAddress,
        uint256 tokenId,
        uint256 updateSalePrice
    );

    event FixedSaleNftSold(
        address nftBuyer,
        address nftAddress,
        uint256 tokenId,
        uint256 salePrice
    );

    event NftAuctionListed(
        address nftSeller,
        address nftAddress,
        uint256 tokenId,
        uint256 auctionStartTimestamp,
        uint256 auctionEndTimestamp,
        uint256 startPrice
    );

    event NftAuctionSalePriceUpdated(
        address nftSeller,
        address nftAddress,
        uint256 tokenId,
        uint256 updateSalePrice
    );

    event NftBidDone(
        address nftAddress,
        uint256 tokenId,
        uint256 bidPrice,
        address nftBidder
    );

    event NftAuctionCancelled(
        address nftAddress,
        uint256 tokenId,
        address nftSeller
    );

    event NftAuctionSettled(
        address nftAddress,
        uint256 tokenId,
        address nftHighestBidder,
        uint256 nftHighestBidPrice,
        address nftSeller
    );

    event NftBurned(
        address nftAddress,
        uint256 tokenId,
        address burner
    );

    modifier isNftNotInSale(address _nftAddress, uint256 _tokenId) {
        require(
            nftSaleStatus[_nftAddress][_tokenId] == SaleStatus.NotInSale,
            "Nft is already in sale"
        );
        _;
    }

    modifier isNftInFixedSale(address _nftAddress, uint256 _tokenId) {
        require(
            nftSaleStatus[_nftAddress][_tokenId] == SaleStatus.InFixedSale,
            "Nft is not in fixed sale"
        );
        _;
    }

    modifier isNftInAuctionSaleAndAuctionOngoing(
        address _nftAddress,
        uint256 _tokenId
    ) {
        require(
            nftSaleStatus[_nftAddress][_tokenId] == SaleStatus.InAuction,
            "Nft is not in auction sale"
        );
        require(
            block.timestamp <
                auctions[_nftAddress][_tokenId].auctionEndTimestamp,
            "Auction is over"
        );
        require(
            block.timestamp >=
                auctions[_nftAddress][_tokenId].auctionStartTimestamp,
            "Auction is not started yet"
        );
        _;
    }

    modifier isOwnerOfNotInSaleNft(address _nftAddress, uint256 _tokenId) {
        require(
            msg.sender == INftMint(_nftAddress).ownerOf(_tokenId),
            "You are not owner of not in sale nft"
        );
        _;
    }

    modifier isOwnerOfFixedSaleNft(address _nftAddress, uint256 _tokenId) {
        require(
            msg.sender == fixedSales[_nftAddress][_tokenId].nftSeller,
            "You are not nft owner of fixed sale nft"
        );
        _;
    }

    modifier isOwnerOfAuctionNft(address _nftAddress, uint256 _tokenId) {
        require(
            msg.sender == auctions[_nftAddress][_tokenId].nftSeller,
            "You are not nft owner of auction nft"
        );
        _;
    }

    modifier isBidPriceGreaterThanPreviousOne(
        address _nftAddress,
        uint256 _tokenId,
        uint256 _bidPrice
    ) {
        require(
            _bidPrice > auctions[_nftAddress][_tokenId].nftHighestBidPrice,
            "Bid should be greater than previous bid"
        );
        _;
    }

    modifier canSettleAuction(address _nftAddress, uint256 _tokenId) {
        require(
            nftSaleStatus[_nftAddress][_tokenId] == SaleStatus.InAuction,
            "Nft is not in auction sale"
        );
        require(
            block.timestamp >
                auctions[_nftAddress][_tokenId].auctionEndTimestamp,
            "Auction is ongoing yet"
        );
        _;
    }

    modifier isNobodyMadeBidYet(address _nftAddress, uint256 _tokenId) {
        require(
            address(0) == auctions[_nftAddress][_tokenId].nftHighestBidder,
            "bid done"
        );
        _;
    }

    modifier buyPriceMeetSalePrice(
        address _nftAddress,
        uint256 _tokenId,
        uint256 _buyPrice
    ) {
        require(
            _buyPrice >= fixedSales[_nftAddress][_tokenId].salePrice,
            "Buy Price is not enough"
        );
        _;
    }

    modifier isPriceGreaterThanZero(uint256 _price) {
        require(_price > 0, "Price cannot be 0");
        _;
    }

    modifier isSignatureVerified(
        address _nftAddress,
        uint256 _tokenId,
        bytes memory _signature
    ) {
        require(
            ICsdogeSign(signContract).verify(
                msg.sender,
                _nftAddress,
                _tokenId,
                1, // for compatibility with sign contract
                _signature
            ),
            "Invalid Sign!"
        );
        _;
    }

    constructor() {}

    receive() external payable {}

    function setSignContract(address _signContract) external onlyOwner {
        signContract = _signContract;
    }

    function setCsdogeNftContract(address _csdogeNftContract)
        external
        onlyOwner
    {
        csdogeNftContract = _csdogeNftContract;
    }

    function setTreasuryWallet(address _treasuryWallet) external onlyOwner {
        treasuryWallet = _treasuryWallet;
    }

    function setDevWallet(address _devWallet) external onlyOwner {
        devWallet = _devWallet;
    }

    function setMarketplaceFee(uint256 _marketplaceFee) external onlyOwner {
        marketplaceFee = _marketplaceFee;
    }

    function setDevFee(uint256 _devFee) external onlyOwner {
        devFee = _devFee;
    }

    function withdraw() external onlyOwner {
        Address.sendValue(payable(msg.sender), address(this).balance);
    }

    // Nft FIXED SALE
    function listFixedSale(
        address _nftAddress,
        uint256 _tokenId,
        uint256 _salePrice,
        bytes memory _signature
    )
        external
        isOwnerOfNotInSaleNft(_nftAddress, _tokenId)
        isNftNotInSale(_nftAddress, _tokenId)
        isPriceGreaterThanZero(_salePrice)
        isSignatureVerified(_nftAddress, _tokenId, _signature)
    {
        fixedSales[_nftAddress][_tokenId] = FixedSale(
            msg.sender,
            address(0),
            _salePrice
        );
        nftSaleStatus[_nftAddress][_tokenId] = SaleStatus.InFixedSale;

        INftMint(_nftAddress).approve(address(this), _tokenId);

        INftMint(_nftAddress).safeTransferFrom(
            msg.sender,
            address(this),
            _tokenId
        );
        ICsdogeSign(signContract).increaseNonce(msg.sender);

        emit NftFixedSaleListed(
            msg.sender,
            _nftAddress,
            _tokenId,
            _salePrice,
            block.timestamp
        );
    }

    function cancelFixedSale(
        address _nftAddress,
        uint256 _tokenId,
        bytes memory _signature
    )
        external
        isNftInFixedSale(_nftAddress, _tokenId)
        isOwnerOfFixedSaleNft(_nftAddress, _tokenId)
        isSignatureVerified(_nftAddress, _tokenId, _signature)
    {
        INftMint(_nftAddress).safeTransferFrom(
            address(this),
            msg.sender,
            _tokenId
        );

        nftSaleStatus[_nftAddress][_tokenId] = SaleStatus.NotInSale;
        ICsdogeSign(signContract).increaseNonce(msg.sender);

        emit NftFixedSaleCancelled(msg.sender, _nftAddress, _tokenId);
    }

    function updateFixedSalePrice(
        address _nftAddress,
        uint256 _tokenId,
        uint256 _updatedSalePrice,
        bytes memory _signature
    )
        external
        isNftInFixedSale(_nftAddress, _tokenId)
        isOwnerOfFixedSaleNft(_nftAddress, _tokenId)
        isPriceGreaterThanZero(_updatedSalePrice)
        isSignatureVerified(_nftAddress, _tokenId, _signature)
    {
        fixedSales[_nftAddress][_tokenId].salePrice = _updatedSalePrice;
        ICsdogeSign(signContract).increaseNonce(msg.sender);

        emit NftFixedSalePriceUpdated(
            msg.sender,
            _nftAddress,
            _tokenId,
            _updatedSalePrice
        );
    }

    function buyFromFixedSale(
        address _nftAddress,
        uint256 _tokenId,
        bytes memory _signature
    )
        external
        payable
        isNftInFixedSale(_nftAddress, _tokenId)
        buyPriceMeetSalePrice(_nftAddress, _tokenId, msg.value)
        isSignatureVerified(_nftAddress, _tokenId, _signature)
    {
        INftMint(_nftAddress).safeTransferFrom(
            address(this),
            msg.sender,
            _tokenId
        );

        nftSaleStatus[_nftAddress][_tokenId] = SaleStatus.NotInSale;

        fixedSales[_nftAddress][_tokenId].nftBuyer = msg.sender;

        {
            FixedSale memory currentFixedSale = fixedSales[_nftAddress][
                _tokenId
            ];

            Address.sendValue(
                payable(currentFixedSale.nftSeller),
                (currentFixedSale.salePrice *
                    (10000 - marketplaceFee - devFee)) / 10000
            );
            Address.sendValue(
                payable(treasuryWallet),
                (currentFixedSale.salePrice * marketplaceFee) / 10000
            );
            Address.sendValue(
                payable(devWallet),
                (currentFixedSale.salePrice * devFee) / 10000
            );
        }
        ICsdogeSign(signContract).increaseNonce(msg.sender);

        emit FixedSaleNftSold(msg.sender, _nftAddress, _tokenId, msg.value);
    }

    // Nft AUCTION SALE
    function listNftAuction(
        address _nftAddress,
        uint256 _tokenId,
        uint256 _auctionStartTimestamp,
        uint256 _auctionEndTimestamp,
        uint256 _startPrice,
        bytes memory _signature
    )
        external
        isOwnerOfNotInSaleNft(_nftAddress, _tokenId)
        isNftNotInSale(_nftAddress, _tokenId)
        isPriceGreaterThanZero(_startPrice)
        isSignatureVerified(_nftAddress, _tokenId, _signature)
    {
        _storeNftAuctionDetails(
            _nftAddress,
            _tokenId,
            _auctionStartTimestamp,
            _auctionEndTimestamp,
            _startPrice
        );
        ICsdogeSign(signContract).increaseNonce(msg.sender);

        emit NftAuctionListed(
            msg.sender,
            _nftAddress,
            _tokenId,
            _auctionStartTimestamp,
            _auctionEndTimestamp,
            _startPrice
        );
    }

    function updateAuctionSalePrice(
        address _nftAddress,
        uint256 _tokenId,
        uint256 _updatedSalePrice,
        bytes memory _signature
    )
        external
        isSignatureVerified(_nftAddress, _tokenId, _signature)
        isNftInAuctionSaleAndAuctionOngoing(_nftAddress, _tokenId)
        isOwnerOfAuctionNft(_nftAddress, _tokenId)
        isNobodyMadeBidYet(_nftAddress, _tokenId)
    {
        require(_updatedSalePrice > 0, "Price cannot be 0");

        auctions[_nftAddress][_tokenId].startPrice = _updatedSalePrice;
        auctions[_nftAddress][_tokenId].nftHighestBidPrice = _updatedSalePrice;
        
        ICsdogeSign(signContract).increaseNonce(msg.sender);

        emit NftAuctionSalePriceUpdated(
            msg.sender,
            _nftAddress,
            _tokenId,
            _updatedSalePrice
        );
    }

    function makeBid(
        address _nftAddress,
        uint256 _tokenId,
        bytes memory _signature
    )
        external
        payable
        isNftInAuctionSaleAndAuctionOngoing(_nftAddress, _tokenId)
        isBidPriceGreaterThanPreviousOne(_nftAddress, _tokenId, msg.value)
        isSignatureVerified(_nftAddress, _tokenId, _signature)
    {
        Auction memory currentAuction = auctions[_nftAddress][_tokenId];

        if (currentAuction.nftHighestBidder != address(0)) {
            Address.sendValue(
                payable(currentAuction.nftHighestBidder),
                currentAuction.nftHighestBidPrice
            );
        }

        auctions[_nftAddress][_tokenId].nftHighestBidPrice = msg.value;
        auctions[_nftAddress][_tokenId].nftHighestBidder = msg.sender;

        ICsdogeSign(signContract).increaseNonce(msg.sender);

        emit NftBidDone(_nftAddress, _tokenId, msg.value, msg.sender);
    }

    function cancelNftAuction(
        address _nftAddress,
        uint256 _tokenId,
        bytes memory _signature
    )
        external
        isSignatureVerified(_nftAddress, _tokenId, _signature)
        isNftInAuctionSaleAndAuctionOngoing(_nftAddress, _tokenId)
        isOwnerOfAuctionNft(_nftAddress, _tokenId)
        isNobodyMadeBidYet(_nftAddress, _tokenId)
    {
        nftSaleStatus[_nftAddress][_tokenId] = SaleStatus.NotInSale;

        INftMint(_nftAddress).safeTransferFrom(
            address(this),
            msg.sender,
            _tokenId
        );
        ICsdogeSign(signContract).increaseNonce(msg.sender);

        emit NftAuctionCancelled(_nftAddress, _tokenId, msg.sender);
    }

    function settleNftAuction(address _nftAddress, uint256 _tokenId)
        external
        onlyOwner
        canSettleAuction(_nftAddress, _tokenId)
    {
        address nftBuyer = auctions[_nftAddress][_tokenId].nftHighestBidder;

        if (nftBuyer == address(0)) {
            INftMint(_nftAddress).safeTransferFrom(
                address(this),
                auctions[_nftAddress][_tokenId].nftSeller,
                _tokenId
            );

            nftSaleStatus[_nftAddress][_tokenId] = SaleStatus.NotInSale;
        } else {
            _transferNftAndPaySeller(
                _nftAddress,
                _tokenId,
                auctions[_nftAddress][_tokenId].nftHighestBidPrice,
                nftBuyer
            );
        }

        emit NftAuctionSettled(
            _nftAddress,
            _tokenId,
            nftBuyer,
            auctions[_nftAddress][_tokenId].nftHighestBidPrice,
            auctions[_nftAddress][_tokenId].nftSeller
        );
    }

    function burnNft(address _nftAddress, uint256 _tokenId)
        external
        isOwnerOfNotInSaleNft(_nftAddress, _tokenId)
    {
        INftMint(_nftAddress).approve(address(this), _tokenId);
        
        INftMint(_nftAddress).safeTransferFrom(
            msg.sender,
            address(1),
            _tokenId
        );

        emit NftBurned(
            _nftAddress,
            _tokenId,
            msg.sender
        );
    }

    function getNftAuctionDetails(address _nftAddress, uint256 _tokenId)
        external
        view
        returns (Auction memory)
    {
        return auctions[_nftAddress][_tokenId];
    }

    function getNftFixedSaleDetails(address _nftAddress, uint256 _tokenId)
        external
        view
        returns (FixedSale memory)
    {
        return fixedSales[_nftAddress][_tokenId];
    }

    function _transferNftAndPaySeller(
        address _nftAddress,
        uint256 _tokenId,
        uint256 _bidPrice,
        address _nftBuyer
    ) internal {
        INftMint(_nftAddress).safeTransferFrom(
            address(this),
            _nftBuyer,
            _tokenId
        );

        nftSaleStatus[_nftAddress][_tokenId] = SaleStatus.NotInSale;

        Address.sendValue(
            payable(auctions[_nftAddress][_tokenId].nftSeller),
            (_bidPrice * (10000 - marketplaceFee - devFee)) / 10000
        );

        Address.sendValue(
            payable(treasuryWallet),
            (_bidPrice * marketplaceFee) / 10000
        );
        Address.sendValue(payable(devWallet), (_bidPrice * devFee) / 10000);
    }

    function _storeNftAuctionDetails(
        address _nftAddress,
        uint256 _tokenId,
        uint256 _auctionStartTimestamp,
        uint256 _auctionEndTimestamp,
        uint256 _startPrice
    ) internal {
        auctions[_nftAddress][_tokenId] = Auction(
            _auctionStartTimestamp,
            _auctionEndTimestamp,
            _startPrice,
            _startPrice,
            address(0),
            msg.sender
        );

        nftSaleStatus[_nftAddress][_tokenId] = SaleStatus.InAuction;

        INftMint(_nftAddress).approve(address(this), _tokenId);
        
        INftMint(_nftAddress).safeTransferFrom(
            msg.sender,
            address(this),
            _tokenId
        );
    }

    function onERC721Received(
        address,
        address,
        uint256,
        bytes memory
    ) public virtual override returns (bytes4) {
        return this.onERC721Received.selector;
    }
}
// Csdoge Marketplace Sign Interface contract

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;
import "@openzeppelin/contracts/access/Ownable.sol";

interface ICsdogeSign {
    function verify(
        address _minter,
        address _contractAddress,
        uint256 _tokenId,
        uint256 _amount,
        bytes memory _signature
    ) external view returns (bool);

    function increaseNonce(address _minter) external;
}
