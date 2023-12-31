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
// OpenZeppelin Contracts (last updated v4.9.0) (token/ERC721/utils/ERC721Holder.sol)

pragma solidity ^0.8.0;

import "../IERC721Receiver.sol";

/**
 * @dev Implementation of the {IERC721Receiver} interface.
 *
 * Accepts all token transfers.
 * Make sure the contract is able to use its token with {IERC721-safeTransferFrom}, {IERC721-approve} or {IERC721-setApprovalForAll}.
 */
contract ERC721Holder is IERC721Receiver {
    /**
     * @dev See {IERC721Receiver-onERC721Received}.
     *
     * Always returns `IERC721Receiver.onERC721Received.selector`.
     */
    function onERC721Received(address, address, uint256, bytes memory) public virtual override returns (bytes4) {
        return this.onERC721Received.selector;
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
pragma solidity ^0.8.8;

interface IWithdrawNFTByAdmin {
    function transferNftEmergency(address _receiver, uint256 _nftId) external;

    function transferMultiNftsEmergency(address[] memory _receivers, uint256[] memory _nftIds) external;
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

interface IWithdrawTokenByAdmin {
    function recoverLostBNB() external;

    function withdrawTokenEmergency(address _token, uint256 _amount) external;

    function withdrawTokenEmergencyFrom(address _from, address _to, address _currency, uint256 _amount) external;
}
// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity >=0.7.0;

/// @title Optimized overflow and underflow safe math operations
/// @notice Contains methods for doing math operations that revert on overflow or underflow for minimal gas cost
library LowGasSafeMath {
    /// @notice Returns x + y, reverts if sum overflows uint256
    /// @param x The augend
    /// @param y The addend
    /// @return z The sum of x and y
    function add(uint256 x, uint256 y) internal pure returns (uint256 z) {
        require((z = x + y) >= x);
    }

    /// @notice Returns x - y, reverts if underflows
    /// @param x The minuend
    /// @param y The subtrahend
    /// @return z The difference of x and y
    function sub(uint256 x, uint256 y) internal pure returns (uint256 z) {
        require((z = x - y) <= x);
    }

    /// @notice Returns x * y, reverts if overflows
    /// @param x The multiplicand
    /// @param y The multiplier
    /// @return z The product of x and y
    function mul(uint256 x, uint256 y) internal pure returns (uint256 z) {
        require(x == 0 || (z = x * y) / x == y);
    }

    /// @notice Returns x + y, reverts if overflows or underflows
    /// @param x The augend
    /// @param y The addend
    /// @return z The sum of x and y
    function add(int256 x, int256 y) internal pure returns (int256 z) {
        require((z = x + y) >= x == (y >= 0));
    }

    /// @notice Returns x - y, reverts if overflows or underflows
    /// @param x The minuend
    /// @param y The subtrahend
    /// @return z The difference of x and y
    function sub(int256 x, int256 y) internal pure returns (int256 z) {
        require((z = x - y) <= x == (y >= 0));
    }
}
// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity >=0.5.0;

/// @title Safe casting methods
/// @notice Contains methods for safely casting between types
library SafeCast {
    /// @notice Cast a uint256 to a uint160, revert on overflow
    /// @param y The uint256 to be downcasted
    /// @return z The downcasted integer, now type uint160
    function toUint160(uint256 y) internal pure returns (uint160 z) {
        require((z = uint160(y)) == y);
    }

    /// @notice Cast a int256 to a int128, revert on overflow or underflow
    /// @param y The int256 to be downcasted
    /// @return z The downcasted integer, now type int128
    function toInt128(int256 y) internal pure returns (int128 z) {
        require((z = int128(y)) == y);
    }

    /// @notice Cast a uint256 to a int256, revert on overflow
    /// @param y The uint256 to be casted
    /// @return z The casted integer, now type int256
    function toInt256(uint256 y) internal pure returns (int256 z) {
        require(y < 2 ** 255);
        z = int256(y);
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

interface IMarketplace {
    event Buy(address seller, address buyer, uint256 nftId);
    event Sell(address seller, address buyer, uint256 nftId);
    event ErrorLog(bytes message);

    function buyByCurrency(uint256 _nftId, uint256 _refCode) external;

    function buyByToken(uint256 _nftId, uint256 _refCode) external;

    function getActiveMemberForAccount(address _wallet) external view returns (uint256);

    function getReferredNftValueForAccount(address _wallet) external view returns (uint256);

    function getNftCommissionEarnedForAccount(address _wallet) external view returns (uint256);

    function getNftSaleValueForAccountInUsdDecimal(address _wallet) external view returns (uint256);

    function getF1ListForAccount(address _wallet) external view returns (address[] memory);

    function getTeamNftSaleValueForAccountInUsdDecimal(address _wallet) external view returns (uint256);

    function updateReferralData(address _user, uint256 _refCode) external;

    function possibleChangeReferralData(address _wallet) external returns (bool);

    function checkValidRefCodeAdvance(address _user, uint256 _refCode) external view returns (bool);

    function genReferralCodeForAccount() external returns (uint256);

    function getReferralCodeForAccount(address _wallet) external view returns (uint256);

    function getReferralAccountForAccount(address _user) external view returns (address);

    function getReferralAccountForAccountExternal(address _user) external view returns (address);

    function getAccountForReferralCode(uint256 _refCode) external view returns (address);

    function getMaxEarnableCommission(address _user) external view returns (uint256);

    function getTotalCommissionEarned(address _user) external view returns (uint256);

    function getCommissionLimit(address _user) external view returns (uint256);

    function getNftPaymentType(uint256 _nftId) external view returns (bool);
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

interface IMarketplaceMigrate {
    function updateMyRefCodeOnlyOwner(address[] calldata _user, uint256[] calldata _refCode) external;

    function updateNftCommissionEarnedOnlyOwner(
        address[] calldata _user,
        uint256[] calldata _commissionEarned
    ) external;

    function updateNftSaleValueOnlyOwner(address[] calldata _users, uint256[] calldata _nftSaleValues) external;

    function updateUserF1ListOnlyOwner(address _user, address[] memory _f1Users) external;

    function updateNftPaymentTypeOnlyOwner(uint256[] calldata _nftIds, bool[] calldata _paymentTypes) external;

    function updateUserRefParentOnlyOwner(address[] calldata _users, address[] calldata _parents) external;
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

interface IMarketplaceSetting {
    function allowBuyNftByCurrency(bool _activePayByCurrency) external;

    function allowBuyNftByToken(bool _activePayByToken) external;

    function setSystemWallet(address _newSystemWallet) external;

    function setSaleWalletAddress(address _saleAddress) external;

    function setOracleAddress(address _oracleAddress) external;

    function setStakingAddress(address _stakingAddress) external;

    function setCurrencyAddress(address _currency) external;

    function setTokenAddress(address _token) external;

    function setNftAddress(address _nft) external;

    function setContractOwner(address _newContractOwner) external;

    function setTypePayCommission(bool _typePayCommission) external;

    function setCommissionPercent(uint256 _percent) external;

    function setMaxCommissionDefault(uint256 _maxCommissionDefault) external;

    function setCommissionMultipleTime(uint256 _commissionMultipleTime) external;

    function setSaleStart(uint256 _newSaleStart) external;

    function setSaleEnd(uint256 _newSaleEnd) external;

    function setSalePercent(uint8 _nftTier, uint32 _newSalePercent) external;
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";
import "../libraries/LowGasSafeMath.sol";
import "../libraries/SafeCast.sol";
import "./IMarketplace.sol";
import "./IMarketplaceMigrate.sol";
import "./IMarketplaceSetting.sol";
import "../interfaces/IWithdrawTokenByAdmin.sol";
import "../interfaces/IWithdrawNFTByAdmin.sol";
import "../nft/IAICrewNFT.sol";
import "../oracle/IOracle.sol";
import "../stake/IStaking.sol";

contract Marketplace is
    IMarketplace,
    Ownable,
    ERC721Holder,
    IWithdrawTokenByAdmin,
    IWithdrawNFTByAdmin,
    IMarketplaceMigrate,
    IMarketplaceSetting
{
    using LowGasSafeMath for uint256;
    using SafeCast for uint256;

    uint256 public constant TOKEN_DECIMAL = 1e18;
    bool public constant PAYMENT_TYPE_TOKEN = false;
    bool public constant PAYMENT_TYPE_USDT = true;

    address public nft;
    address public token;
    address public currency;
    address public oracleContract;
    address public stakingContract;
    address public systemWallet;
    address public saleWallet = 0x62605feEF3Da8A3D0D2803bA4208ccc51030ba33;
    address private contractOwner;

    // for network stats
    mapping(address => uint256) private nftCommissionEarned;
    mapping(address => uint256) private nftSaleValue;
    mapping(address => address[]) private userF1List;

    mapping(uint256 => address) private referralCodeUser; // refCode => user
    mapping(address => uint256) private userReferralCode; // user => refCode
    mapping(address => address) private userRefParent; // user => parent

    mapping(uint256 => bool) private nftPaymentType;

    uint256 private saleStart = 1691625600; // 2023-08-10 00:00:00
    uint256 private saleEnd = 1692143999; // 2023-08-15 23:59:59
    mapping(uint8 => uint32) private salePercent; // Percent * 100, ex: 100 = 1%

    uint256 private commissionBuyPercent = 0; // Percent * 100, ex: 100 = 1%
    uint256 private maxCommissionDefault = 500000000000000000000; // 500$
    uint256 private commissionMultipleTime = 5; // 5 x totalStakedAmount

    bool private allowBuyByCurrency = true; // default allow
    bool private allowBuyByToken = true; // default true
    bool private typePayCom = true; // false is pay com by token, true is pay com by usdt
    bool private unlocked = true;

    constructor(address _nft, address _token, address _oracle, address _systemWallet, address _currency) {
        nft = _nft;
        token = _token;
        currency = _currency;
        oracleContract = _oracle;
        systemWallet = _systemWallet;
        contractOwner = _msgSender();
        initDefaultReferral();
    }

    modifier checkOwner() {
        require(owner() == _msgSender() || contractOwner == _msgSender(), "MARKETPLACE: caller is not the owner");
        _;
    }

    modifier lock() {
        require(unlocked == true, "MARKETPLACE: Locked");
        unlocked = false;
        _;
        unlocked = true;
    }

    modifier isAcceptBuyByCurrency() {
        require(allowBuyByCurrency, "MARKETPLACE: Only accept payment in token");
        _;
    }

    modifier isAcceptBuyByToken() {
        require(allowBuyByToken, "MARKETPLACE: Only accept payment in currency");
        _;
    }

    /**
     * @dev init default referral as system wallet
     */
    function initDefaultReferral() internal {
        uint256 systemRefCode = 1000;
        userReferralCode[systemWallet] = systemRefCode;
        referralCodeUser[systemRefCode] = systemWallet;
    }

    function getCurrentSalePercent(uint8 nftTier) internal view returns (uint32) {
        if (block.timestamp >= saleStart && block.timestamp < saleEnd) {
            return salePercent[nftTier];
        }

        return 0;
    }

    function updateNetworkData(address _buyer, uint256 _totalValueUsdWithDecimal) internal {
        uint256 currentNftSaleValue = nftSaleValue[_buyer];
        nftSaleValue[_buyer] = currentNftSaleValue + _totalValueUsdWithDecimal;
    }

    /**
     * @dev buyByCurrency function
     * @param _nftId NFT ID want to buy
     * @param _refCode referral code of ref account
     */
    function buyByCurrency(uint256 _nftId, uint256 _refCode) external override isAcceptBuyByCurrency lock {
        updateReferralData(msg.sender, _refCode);
        uint256 totalValueUsdWithDecimal = IAICrewNFT(nft).getNftPriceUsd(_nftId) * TOKEN_DECIMAL;
        uint8 nftTier = IAICrewNFT(nft).getNftTier(_nftId);
        uint256 saleValueUsdWithDecimal = 0;
        {
            uint32 currentSale = getCurrentSalePercent(nftTier);
            if (currentSale > 0) {
                saleValueUsdWithDecimal = (totalValueUsdWithDecimal * currentSale) / 10000;
            }
        }

        uint256 payValueUsdWithDecimal = totalValueUsdWithDecimal - saleValueUsdWithDecimal;
        pay(currency, payValueUsdWithDecimal);

        // Transfer nft from marketplace to buyer
        IAICrewNFT(nft).safeTransferFrom(address(this), msg.sender, _nftId, "");
        nftPaymentType[_nftId] = PAYMENT_TYPE_USDT;
        emit Buy(address(this), msg.sender, _nftId);

        updateNetworkData(msg.sender, totalValueUsdWithDecimal);
        address refAddress = getReferralAccountForAccount(msg.sender);
        payReferralCommissions(refAddress, totalValueUsdWithDecimal);
    }

    /**
     * @dev buyByToken function
     * @param _nftId NFT ID want to buy
     * @param _refCode referral code of ref account
     */
    function buyByToken(uint256 _nftId, uint256 _refCode) external override isAcceptBuyByToken lock {
        updateReferralData(msg.sender, _refCode);
        uint256 totalValueUsdWithDecimal = IAICrewNFT(nft).getNftPriceUsd(_nftId) * TOKEN_DECIMAL;
        uint8 nftTier = IAICrewNFT(nft).getNftTier(_nftId);
        uint256 totalValueInTokenWithDecimal = IOracle(oracleContract).convertUsdBalanceDecimalToTokenDecimal(
            totalValueUsdWithDecimal
        );

        uint256 saleValueInTokenWithDecimal = 0;
        {
            uint32 currentSale = getCurrentSalePercent(nftTier);
            if (currentSale > 0) {
                saleValueInTokenWithDecimal = (totalValueInTokenWithDecimal * currentSale) / 10000;
            }
        }

        uint256 payValueTokenWithDecimal = totalValueInTokenWithDecimal - saleValueInTokenWithDecimal;
        pay(token, payValueTokenWithDecimal);

        // Transfer nft from marketplace to buyer
        IAICrewNFT(nft).safeTransferFrom(address(this), msg.sender, _nftId, "");
        nftPaymentType[_nftId] = PAYMENT_TYPE_TOKEN;
        emit Buy(address(this), msg.sender, _nftId);

        updateNetworkData(msg.sender, totalValueUsdWithDecimal);
        address refAddress = getReferralAccountForAccount(msg.sender);
        payReferralCommissions(refAddress, totalValueUsdWithDecimal);
    }

    function pay(address payToken, uint256 payValueTokenWithDecimal) internal {
        require(
            IERC20(payToken).balanceOf(msg.sender) >= payValueTokenWithDecimal,
            "MARKETPLACE: Not enough balance to buy NFTs"
        );
        require(
            IERC20(payToken).allowance(msg.sender, address(this)) >= payValueTokenWithDecimal,
            "MARKETPLACE: Must approve first"
        );
        require(
            IERC20(payToken).transferFrom(msg.sender, saleWallet, payValueTokenWithDecimal),
            "MARKETPLACE: Transfer to MARKETPLACE failed"
        );
    }

    /**
     * @dev get children of an address
     */
    function countChildrenUsers(address _wallet) public view returns (uint256) {
        address[] memory f1User = userF1List[_wallet];
        uint256 k = f1User.length;

        for (uint256 i = 0; i < f1User.length; i++) {
            k += countChildrenUsers(f1User[i]);
        }

        return k;
    }

    /**
     * @dev generate a referral code for user (internal function)
     * @param _user user wallet address
     */
    function generateReferralCode(address _user) internal {
        uint256 salt = 1;
        uint256 refCode = generateRandomCode(salt, _user);
        while (referralCodeUser[refCode] != address(0) || refCode < 1001) {
            salt++;
            refCode = generateRandomCode(salt, _user);
        }
        userReferralCode[_user] = refCode;
        referralCodeUser[refCode] = _user;
    }

    /**
     * @dev generate a random code for ref
     */
    function generateRandomCode(uint256 _salt, address _wallet) internal view returns (uint256) {
        bytes32 randomHash = keccak256(abi.encodePacked(block.timestamp, _wallet, _salt));
        return uint256(randomHash) % 1000000;
    }

    /**
     * @dev the function pay commission(default 3%) to referral account
     */
    function payReferralCommissions(address _receiver, uint256 _amountUsdDecimal) internal {
        uint256 commissionAmountInUsdDecimal = (_amountUsdDecimal * commissionBuyPercent) / 10000;
        if (commissionAmountInUsdDecimal <= 0) {
            return;
        }

        uint256 maxEarn = getMaxEarnableCommission(_receiver);
        if (maxEarn < commissionAmountInUsdDecimal) {
            commissionAmountInUsdDecimal = maxEarn;
        }

        if (commissionAmountInUsdDecimal <= 0) {
            return;
        }

        uint256 currentCommissionEarned = nftCommissionEarned[_receiver];
        nftCommissionEarned[_receiver] = currentCommissionEarned + commissionAmountInUsdDecimal;

        if (typePayCom == PAYMENT_TYPE_USDT) {
            IERC20(currency).transfer(_receiver, commissionAmountInUsdDecimal);
        } else {
            uint256 commissionAmountInTokenDecimal = IOracle(oracleContract).convertUsdBalanceDecimalToTokenDecimal(
                commissionAmountInUsdDecimal
            );
            IERC20(token).transfer(_receiver, commissionAmountInTokenDecimal);
        }
    }

    function getActiveMemberForAccount(address _wallet) external view override returns (uint256) {
        return userF1List[_wallet].length;
    }

    function getReferredNftValueForAccount(address _wallet) external view override returns (uint256) {
        uint256 nftValue = 0;
        address[] memory f1Users = userF1List[_wallet];
        for (uint256 i = 0; i < f1Users.length; i++) {
            nftValue += nftSaleValue[f1Users[i]];
        }

        return nftValue;
    }

    function getNftCommissionEarnedForAccount(address _wallet) external view override returns (uint256) {
        return nftCommissionEarned[_wallet];
    }

    /**
     * @dev get NFT sale value
     */
    function getNftSaleValueForAccountInUsdDecimal(address _wallet) external view override returns (uint256) {
        return nftSaleValue[_wallet];
    }

    /**
     * @dev get children of an address
     */
    function getF1ListForAccount(address _wallet) external view override returns (address[] memory) {
        return userF1List[_wallet];
    }

    /**
     * @dev get Team NFT sale value
     */
    function getTeamNftSaleValueForAccountInUsdDecimal(address _wallet) external view override returns (uint256) {
        uint256 teamNftValue = getChildrenNftSaleValueInUsdDecimal(_wallet);
        return teamNftValue;
    }

    function getChildrenNftSaleValueInUsdDecimal(address _wallet) internal view returns (uint256) {
        uint256 nftValue = 0;
        uint256 f1Count = userF1List[_wallet].length;
        for (uint256 i = 0; i < f1Count; i++) {
            address f1 = userF1List[_wallet][i];
            nftValue += nftSaleValue[f1];
            nftValue += getChildrenNftSaleValueInUsdDecimal(f1);
        }

        return nftValue;
    }

    /**
     * @dev update referral data function
     * @param _refCode referral code of ref account
     */
    function updateReferralData(address _user, uint256 _refCode) public override {
        require(_user == _msgSender() || stakingContract == _msgSender(), "MARKETPLACE: caller is not the input user");
        require(systemWallet != _msgSender(), "MARKETPLACE: system wallet can't update ref data");

        if (possibleChangeReferralData(_user)) {
            require(checkValidRefCodeAdvance(_user, _refCode), "MARKETPLACE: Cheat ref detected");
            _updateReferralData(_user, _refCode);
        }
    }

    function _updateReferralData(address _user, uint256 _refCode) internal {
        address refAddress = getAccountForReferralCode(_refCode);
        userRefParent[_user] = refAddress;

        if (userReferralCode[_user] == 0) {
            generateReferralCode(_user);
        }

        userF1List[refAddress].push(_user);
    }

    /**
     * @dev check possible to change referral data for a user
     * @param _user user wallet address
     */
    function possibleChangeReferralData(address _user) public view override returns (bool) {
        return userRefParent[_user] == address(0);
    }

    function checkValidRefCodeAdvance(address _user, uint256 _refCode) public view override returns (bool) {
        address parentUser = getAccountForReferralCode(_refCode);
        if (parentUser == systemWallet) {
            return true;
        }

        while (parentUser != address(0)) {
            if (_user == parentUser) {
                return false;
            }

            parentUser = userRefParent[parentUser];
        }

        return true;
    }

    /**
     * @dev generate referral code for an account
     */
    function genReferralCodeForAccount() external override returns (uint256) {
        require(userReferralCode[msg.sender] == 0, "MARKETPLACE: Account already have the ref code");
        generateReferralCode(msg.sender);
        return userReferralCode[msg.sender];
    }

    /**
     * @dev get referral code for an account
     * @param _user user wallet address
     */
    function getReferralCodeForAccount(address _user) external view override returns (uint256) {
        return userReferralCode[_user];
    }

    /**
     * @dev the function return referral address for specified address
     */
    function getReferralAccountForAccount(address _user) public view override returns (address) {
        address refWallet = userRefParent[_user];
        if (refWallet == address(0)) {
            refWallet = systemWallet;
        }
        return refWallet;
    }

    /**
     * @dev the function return referral address for specified address (without system)
     */
    function getReferralAccountForAccountExternal(address _user) public view override returns (address) {
        return userRefParent[_user];
    }

    /**
     * @dev get account for referral code
     * @param _refCode refCode
     */
    function getAccountForReferralCode(uint256 _refCode) public view override returns (address) {
        address refAddress = referralCodeUser[_refCode];
        if (refAddress == address(0)) {
            refAddress = systemWallet;
        }
        return refAddress;
    }

    function getMaxEarnableCommission(address _user) public view override returns (uint256) {
        uint256 maxEarn = getCommissionLimit(_user);
        uint256 earned = getTotalCommissionEarned(_user);
        if (maxEarn <= earned) {
            return 0;
        }

        return maxEarn - earned;
    }

    function getTotalCommissionEarned(address _user) public view override returns (uint256) {
        uint256 earned = nftCommissionEarned[_user];
        if (stakingContract != address(0)) {
            earned += IStaking(stakingContract).getTotalStakingCommissionEarned(_user);
        }

        return earned;
    }

    function getCommissionLimit(address _user) public view override returns (uint256) {
        uint256 maxEarn = maxCommissionDefault;
        uint256 defaultMax = maxCommissionDefault;
        {
            if (stakingContract != address(0)) {
                uint256 stakeMaxValue = IStaking(stakingContract).getTotalStakeAmountUSDWithDecimal(_user);
                maxEarn = stakeMaxValue * commissionMultipleTime;
                if (maxEarn < defaultMax) {
                    maxEarn = defaultMax;
                }
            }
        }

        return maxEarn;
    }

    function getNftPaymentType(uint256 _nftId) external view override returns (bool) {
        return nftPaymentType[_nftId];
    }

    // Setting
    function allowBuyNftByCurrency(bool _activePayByCurrency) external override checkOwner {
        allowBuyByCurrency = _activePayByCurrency;
    }

    function allowBuyNftByToken(bool _activePayByToken) external override checkOwner {
        allowBuyByToken = _activePayByToken;
    }

    function setOracleAddress(address _oracleAddress) external override checkOwner {
        oracleContract = _oracleAddress;
    }

    function setStakingAddress(address _stakingAddress) external override checkOwner {
        stakingContract = _stakingAddress;
    }

    /**
     * @dev the function to update system wallet. Only owner can do this action
     */
    function setSystemWallet(address _newSystemWallet) external override checkOwner {
        systemWallet = _newSystemWallet;
        initDefaultReferral();
    }

    function setSaleWalletAddress(address _saleAddress) external override checkOwner {
        require(_saleAddress != address(0), "MARKETPLACE: Invalid Sale address");
        saleWallet = _saleAddress;
    }

    function setContractOwner(address _newContractOwner) external override checkOwner {
        contractOwner = _newContractOwner;
    }

    function setCurrencyAddress(address _currency) external override checkOwner {
        currency = _currency;
    }

    function setTokenAddress(address _token) external override checkOwner {
        token = _token;
    }

    function setNftAddress(address _nft) external override checkOwner {
        nft = _nft;
    }

    /**
     * @dev set type pay com(token or currency)
     *
     * false is pay com by token
     * true is pay com by usdt
     */
    function setTypePayCommission(bool _typePayCommission) external override checkOwner {
        typePayCom = _typePayCommission;
    }

    function setCommissionPercent(uint256 _percent) external override checkOwner {
        commissionBuyPercent = _percent;
    }

    function setMaxCommissionDefault(uint256 _maxCommissionDefault) external override checkOwner {
        maxCommissionDefault = _maxCommissionDefault;
    }

    function setCommissionMultipleTime(uint256 _commissionMultipleTime) external override checkOwner {
        commissionMultipleTime = _commissionMultipleTime;
    }

    function setSaleStart(uint256 _newSaleStart) external override checkOwner {
        saleStart = _newSaleStart;
    }

    function setSaleEnd(uint256 _newSaleEnd) external override checkOwner {
        require(_newSaleEnd >= saleStart, "MARKETPLACE: Time ending must greater than time beginning");
        saleEnd = _newSaleEnd;
    }

    function setSalePercent(uint8 _nftTier, uint32 _newSalePercent) external override checkOwner {
        salePercent[_nftTier] = _newSalePercent;
    }

    // Migrate
    function updateMyRefCodeOnlyOwner(
        address[] calldata _users,
        uint256[] calldata _refCodes
    ) external override checkOwner {
        require(_users.length == _refCodes.length, "MARKETPLACE: _users and _refCodes must be same size");
        for (uint32 index = 0; index < _users.length; index++) {
            userReferralCode[_users[index]] = _refCodes[index];
            referralCodeUser[_refCodes[index]] = _users[index];
        }
    }

    function updateNftCommissionEarnedOnlyOwner(
        address[] calldata _users,
        uint256[] calldata _commissionEarneds
    ) external override checkOwner {
        require(
            _users.length == _commissionEarneds.length,
            "MARKETPLACE: _users and _commissionEarneds must be same size"
        );
        for (uint32 index = 0; index < _users.length; index++) {
            nftCommissionEarned[_users[index]] = _commissionEarneds[index];
        }
    }

    function updateNftSaleValueOnlyOwner(
        address[] calldata _users,
        uint256[] calldata _nftSaleValues
    ) external override checkOwner {
        require(_users.length == _nftSaleValues.length, "MARKETPLACE: _nftIds and _paymentTypes must be same size");
        for (uint32 index = 0; index < _users.length; index++) {
            nftSaleValue[_users[index]] = _nftSaleValues[index];
        }
    }

    function updateUserF1ListOnlyOwner(address _user, address[] calldata _f1Users) external override checkOwner {
        userF1List[_user] = _f1Users;
        for (uint32 index = 0; index < _f1Users.length; index++) {
            userRefParent[_f1Users[index]] = _user;
        }
    }

    function updateNftPaymentTypeOnlyOwner(
        uint256[] calldata _nftIds,
        bool[] calldata _paymentTypes
    ) external override checkOwner {
        require(_nftIds.length == _paymentTypes.length, "MARKETPLACE: _nftIds and _paymentTypes must be same size");
        for (uint32 index = 0; index < _nftIds.length; index++) {
            nftPaymentType[_nftIds[index]] = _paymentTypes[index];
        }
    }

    function updateUserRefParentOnlyOwner(
        address[] calldata _users,
        address[] calldata _parents
    ) external override checkOwner {
        require(_users.length == _parents.length, "MARKETPLACE: _users and _parents must be same size");
        for (uint32 index = 0; index < _users.length; index++) {
            userRefParent[_users[index]] = _parents[index];
        }
    }

    // Withdraw token
    function recoverLostBNB() external override checkOwner {
        address payable recipient = payable(msg.sender);
        recipient.transfer(address(this).balance);
    }

    function withdrawTokenEmergency(address _token, uint256 _amount) external override checkOwner {
        IERC20(_token).transfer(msg.sender, _amount);
    }

    function withdrawTokenEmergencyFrom(
        address _from,
        address _to,
        address _token,
        uint256 _amount
    ) external override checkOwner {
        IERC20(_token).transferFrom(_from, _to, _amount);
    }

    function transferNftEmergency(address _receiver, uint256 _nftId) public override checkOwner {
        IAICrewNFT(nft).safeTransferFrom(address(this), _receiver, _nftId, "");
    }

    function transferMultiNftsEmergency(
        address[] calldata _receivers,
        uint256[] calldata _nftIds
    ) external override checkOwner {
        require(_receivers.length == _nftIds.length, "MARKETPLACE: _receivers and _nftIds must be same size");
        for (uint256 index = 0; index < _nftIds.length; index++) {
            transferNftEmergency(_receivers[index], _nftIds[index]);
        }
    }

    receive() external payable {}
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

interface IAICrewNFT is IERC721 {
    function getNftPriceUsd(uint256 _nftId) external view returns (uint256);

    function ownerOf(uint256 tokenId) external view returns (address owner);

    function safeTransferFrom(address from, address to, uint256 tokenId) external;

    function getNftTier(uint256 _nftId) external view returns (uint8);

    function isApprovedForAll(address owner, address operator) external view returns (bool);
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

interface IOracle {
    function convertUsdBalanceDecimalToTokenDecimal(uint256 _balanceUsdDecimal) external view returns (uint256);

    function setUsdtAmount(uint256 _usdtAmount) external;

    function setTokenAmount(uint256 _tokenAmount) external;

    function setMinTokenAmount(uint256 _tokenAmount) external;

    function setMaxTokenAmount(uint256 _tokenAmount) external;
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

interface IStaking {
    struct StakedNFT {
        address stakerAddress;
        uint256 startTime;
        uint256 unlockTime;
        uint256 lastClaimTime;
        uint256[] nftIds;
        uint256 totalValueStakeUsd;
        uint256 totalClaimedAmountUsdWithDecimal;
        uint256 totalRewardAmountUsdWithDecimal;
        uint32 apy;
        bool isUnstaked;
    }

    event Staked(uint256 id, address indexed staker, uint256 indexed nftID, uint256 unlockTime, uint32 apy);
    event Unstaked(uint256 id, address indexed staker, uint256 indexed nftID);
    event Claimed(uint256 id, address indexed staker, uint256 claimAmount);

    function getStakeApyForTier(uint8 _nftTier) external returns (uint32);

    function getTotalCrewInvestment(address _wallet) external returns (uint256);

    function getTeamStakingValue(address _wallet) external returns (uint256);

    function getMaxEarnableCommission(address _user) external view returns (uint256);

    function getTotalCommissionEarned(address _user) external view returns (uint256);

    function getReferredStakedValue(address _wallet) external returns (uint256);

    function getReferredStakedValueFull(address _wallet) external returns (uint256);

    function getCurrentProfitLevel(address _wallet) external view returns (uint8);

    function getProfitCommissionUnclaimed(address _wallet) external view returns (uint256);

    function getProfitCommissionUnclaimedWithDeep(address _wallet, uint8 _deep) external view returns (uint256);

    function getStakingCommissionEarned(address _wallet) external view returns (uint256);

    function getProfitCommissionEarned(address _wallet) external view returns (uint256);

    function getDirectCommissionEarned(address _wallet) external view returns (uint256);

    function getTotalStakingCommissionEarned(address _wallet) external view returns (uint256);

    function getTotalStakeAmountUSD(address _staker) external view returns (uint256);

    function getTotalStakeAmountUSDWithDecimal(address _staker) external view returns (uint256);

    function getTotalStakeAmountUSDWithoutDecimal(address _staker) external view returns (uint256);

    function stake(uint256[] memory _nftIds, uint256 _refCode) external;

    function unstake(uint256 _stakeId) external;

    function claim(uint256 _stakeId) external;

    function claimAll(uint256[] memory _stakeIds) external;

    function getDetailOfStake(uint256 _stakeId) external view returns (StakedNFT memory);

    function possibleUnstake(uint256 _stakeId) external view returns (bool);

    function claimableForStakeInUsdWithDecimal(uint256 _stakeId) external view returns (uint256);

    function rewardUnstakeInTokenWithDecimal(uint256 _stakeId) external view returns (uint256);

    function estimateValueUsdForListNft(uint256[] memory _nftIds) external view returns (uint256);
}
