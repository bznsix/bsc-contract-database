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
// OpenZeppelin Contracts (last updated v4.8.0) (token/ERC721/IERC721.sol)

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
     * Operators can call {transferFrom} or {safeTransferFrom} for any token owned by the caller.
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
// OpenZeppelin Contracts v4.4.1 (token/ERC721/utils/ERC721Holder.sol)

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
    function onERC721Received(
        address,
        address,
        uint256,
        bytes memory
    ) public virtual override returns (bytes4) {
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

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

interface IHREANFT is IERC721 {
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
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

interface IStakingMigrate {
    function updateTotalStakingCommissionEarnedOnlyOwner(
        address[] calldata _users,
        uint256[] calldata _values
    ) external;

    function updateStakeExceptProfitOnlyOwner(uint256[] calldata _stakeIds, bool[] calldata _isExcepts) external;

    function updateDirectCommissionEarnedOnlyOwner(address[] calldata _users, uint256[] calldata _values) external;

    function updateStakingCommissionEarnedOnlyOwner(address[] calldata _users, uint256[] calldata _values) external;

    function updateProfitCommissionEarnedOnlyOwner(address[] calldata _users, uint256[] calldata _values) external;

    function updateTotalStakedAmountOnlyOwner(address[] calldata _users, uint256[] calldata _values) external;

    function updateUserStakeIdListOnlyOwner(address _user, uint256[] calldata _value) external;

    function createStakeOnlyOwner(
        address _stakerAddress,
        uint256 _startTime,
        uint256 _unlockTime,
        uint256 _lastClaimTime,
        uint256[] calldata _nftIds,
        uint256 _totalValueStakeUsd,
        uint256 _totalClaimedAmountUsdWithDecimal,
        uint256 _totalRewardAmountUsdWithDecimal,
        uint32 _apy,
        bool _isUnstaked
    ) external;

    function updateStakeOnlyOwner(
        uint256 _stakeId,
        uint256 _lastClaimTime,
        uint256 _totalClaimedAmountUsdWithDecimal,
        bool _isUnstaked
    ) external;

    function updateStakeInfoOnlyOwner(
        uint256 _stakeId,
        address _stakerAddress,
        uint256 _startTime,
        uint256 _unlockTime,
        uint256[] calldata _nftIds,
        uint256 _totalValueStakeUsd,
        uint256 _totalRewardAmountUsdWithDecimal,
        uint32 _apy
    ) external;

    function removeStakeOnlyOwner(address _user, uint256[] memory _stakeIds) external;
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

interface IStakingSetting {
    function setNftAddress(address _nft) external;

    function setTokenAddress(address _token) external;

    function setCurrencyAddress(address _currency) external;

    function setMarketplaceContractAddress(address _marketplaceContract) external;

    function setOracleAddress(address _oracleAddress) external;

    function setContractOwner(address _newContractOwner) external;

    function setTypePayDirectCom(uint8 _typePayDirectCom) external;

    function setTypePayProfitCom(bool _typePayProfitCom) external;

    function setTimeOpenStaking(uint256 _timeOpening) external;

    function setStakingPeriod(uint256 _timeOpening) external;

    function setStakeApyForTier(uint8 _nftTier, uint32 _apy) external;

    function setDirectRewardCondition(uint8 _level, uint256 _valueInUsd, uint32 _percent) external;

    function setProfitRewardCondition(uint8 _level, uint256 _valueInUsd, uint32 _percent) external;

    function setStakeExceptProfit(uint256 _stakeId, bool _isExcept) external;
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";
import "../libraries/LowGasSafeMath.sol";
import "../libraries/SafeCast.sol";
import "../interfaces/IWithdrawTokenByAdmin.sol";
import "../interfaces/IWithdrawNFTByAdmin.sol";
import "../oracle/IOracle.sol";
import "../nft/IHREANFT.sol";
import "../market/IMarketplace.sol";
import "./IStaking.sol";
import "./IStakingMigrate.sol";
import "./IStakingSetting.sol";

contract Staking is
    IStaking,
    IStakingMigrate,
    IStakingSetting,
    Ownable,
    ERC721Holder,
    IWithdrawTokenByAdmin,
    IWithdrawNFTByAdmin
{
    using LowGasSafeMath for uint256;
    using SafeCast for uint256;

    uint256 private constant TOKEN_DECIMAL = 1e18;
    uint256 private constant ONE_MONTH_SECONDS = 2592000;
    uint256 private constant ONE_YEAR_SECONDS = 31104000;
    bool private constant PAYMENT_TYPE_TOKEN = false;
    bool private constant PAYMENT_TYPE_USDT = true;

    address private contractOwner;

    address public nft;
    address public token;
    address public currency;
    address public marketplaceContract;
    address public oracleContract;
    uint256 public timeOpenStaking = 1693353600; // 2023-08-30
    uint256 public stakingPeriod = 24; // 24 month
    uint256 public profitRewardTime = 6; // 6 month

    uint8 public typePayDirectCom = 2; // 0 is pay com by token, 1 is pay com by usdt, 2 is pay com by buy typePayCom
    bool public typePayProfitCom = false; // false is pay com by token, true is pay com by usdt
    bool private unlocked = true;

    mapping(address => uint256) private totalStakingCommissionEarned; // With decimals
    mapping(address => uint256) private directCommissionEarned; // With decimals
    mapping(address => uint256) private stakingCommissionEarned; // With decimals
    mapping(address => uint256) private profitCommissionEarned; // With decimals

    mapping(uint256 => StakedNFT) private stakedNFTs; // mapping to nftId to stake
    mapping(uint8 => uint32) private nftTierApys; // mapping to store commission percent, Percent * 100, ex: 100 = 1%
    mapping(uint8 => uint256) public directRewardConditions; // Without decimals
    mapping(uint8 => uint32) public directRewardPercents; // Percent * 100, ex: 100 = 1%
    mapping(uint8 => uint256) public profitRewardConditions; // Without decimals
    mapping(uint8 => uint32) public profitRewardPercents; // Percent * 100, ex: 100 = 1%
    mapping(uint256 => bool) public stakeExceptProfit;

    mapping(address => uint256) private totalStakedAmount; // Without decimals
    mapping(address => uint256[]) private userStakeIdList;

    using Counters for Counters.Counter;
    Counters.Counter private totalStakesCounter;

    constructor(address _token, address _currency, address _nft, address _oracleContract, address _marketplace) {
        nft = _nft;
        token = _token;
        currency = _currency;
        contractOwner = _msgSender();
        oracleContract = _oracleContract;
        marketplaceContract = _marketplace;
        initStakeApy();
        initDirectRewardConditions();
        initDirectRewardPercents();
        initProfitRewardConditions();
        initProfitRewardPercents();
    }

    modifier checkOwner() {
        require(owner() == _msgSender() || contractOwner == _msgSender(), "STAKING: caller is not the owner");
        _;
    }

    modifier lock() {
        require(unlocked == true, "STAKING: Locked");
        unlocked = false;
        _;
        unlocked = true;
    }

    modifier isTimeForStaking() {
        require(block.timestamp >= timeOpenStaking, "STAKING: The staking has not yet started.");
        _;
    }

    function initStakeApy() internal {
        nftTierApys[1] = 10800;
        nftTierApys[2] = 10200;
        nftTierApys[3] = 9600;
        nftTierApys[4] = 9000;
        nftTierApys[5] = 8400;
        nftTierApys[6] = 7800;
        nftTierApys[7] = 7200;
        nftTierApys[8] = 6600;
        nftTierApys[9] = 3600;
        nftTierApys[10] = 3600;
    }

    /**
     * @dev init condition to reward direct commission
     * level -> usdt max stake amount
     */
    function initDirectRewardConditions() internal {
        directRewardConditions[1] = 0;
        directRewardConditions[2] = 500;
        directRewardConditions[3] = 1000;
    }

    /**
     * @dev init percent to reward direct commission
     * level -> percent to reward (percent * 10000)
     */
    function initDirectRewardPercents() internal {
        directRewardPercents[1] = 800;
        directRewardPercents[2] = 200;
        directRewardPercents[3] = 100;
    }

    /**
     * @dev init commission level in the system
     */
    function initProfitRewardConditions() internal {
        profitRewardConditions[1] = 0;
        profitRewardConditions[2] = 500;
        profitRewardConditions[3] = 1000;
        profitRewardConditions[4] = 2000;
        profitRewardConditions[5] = 3000;
        profitRewardConditions[6] = 4000;
        profitRewardConditions[7] = 5000;
        profitRewardConditions[8] = 6000;
    }

    /**
     * @dev init percent to reward profit commission
     * level -> percent to reward (percent * 10000)
     */
    function initProfitRewardPercents() internal {
        profitRewardPercents[1] = 1500;
        profitRewardPercents[2] = 1000;
        profitRewardPercents[3] = 500;
        profitRewardPercents[4] = 500;
        profitRewardPercents[5] = 400;
        profitRewardPercents[6] = 300;
        profitRewardPercents[7] = 200;
        profitRewardPercents[8] = 100;
    }

    function getStakeApyForTier(uint8 _nftTier) external view override returns (uint32) {
        return nftTierApys[_nftTier];
    }

    function getTotalStakeAmountUSD(address _staker) external view override returns (uint256) {
        return totalStakedAmount[_staker] * TOKEN_DECIMAL;
    }

    function getTotalStakeAmountUSDWithDecimal(address _staker) external view override returns (uint256) {
        return totalStakedAmount[_staker] * TOKEN_DECIMAL;
    }

    function getTotalStakeAmountUSDWithoutDecimal(address _staker) external view override returns (uint256) {
        return totalStakedAmount[_staker];
    }

    function getDetailOfStake(uint256 _stakeId) external view returns (StakedNFT memory) {
        StakedNFT memory stakeInfo = stakedNFTs[_stakeId];
        return stakeInfo;
    }

    function getTotalCrewInvestment(address _wallet) external view returns (uint256) {
        return getChildrenStakingValueInUsd(_wallet, 1, 100);
    }

    function getTeamStakingValue(address _wallet) external view override returns (uint256) {
        uint256 teamStakingValue = getChildrenStakingValueInUsd(_wallet, 1, 10);
        return teamStakingValue;
    }

    function getMaxEarnableCommission(address _user) public view override returns (uint256) {
        uint256 maxEarn = IMarketplace(marketplaceContract).getCommissionLimit(_user);
        uint256 earned = getTotalCommissionEarned(_user);
        if (maxEarn <= earned) {
            return 0;
        }

        return maxEarn - earned;
    }

    function getTotalCommissionEarned(address _user) public view override returns (uint256) {
        uint256 earned = IMarketplace(marketplaceContract).getNftCommissionEarnedForAccount(_user);
        earned += getTotalStakingCommissionEarned(_user);

        return earned;
    }

    function getReferredStakedValue(address _wallet) external view override returns (uint256) {
        address[] memory childrenUser = IMarketplace(marketplaceContract).getF1ListForAccount(_wallet);
        uint256 nftValue = 0;
        for (uint256 i = 0; i < childrenUser.length; i++) {
            address user = childrenUser[i];
            nftValue += totalStakedAmount[user];
        }
        return nftValue;
    }

    function getReferredStakedValueFull(address _wallet) external view override returns (uint256) {
        uint256 teamStakingValue = getChildrenStakingValueInUsd(_wallet, 1, 5);
        return teamStakingValue;
    }

    function getChildrenStakingValueInUsd(
        address _wallet,
        uint256 _deep,
        uint256 _maxDeep
    ) internal view returns (uint256) {
        if (_deep > _maxDeep) {
            return 0;
        }

        uint256 nftValue = 0;
        address[] memory childrenUser = IMarketplace(marketplaceContract).getF1ListForAccount(_wallet);

        if (childrenUser.length <= 0) {
            return 0;
        }

        for (uint256 i = 0; i < childrenUser.length; i++) {
            address f1 = childrenUser[i];
            nftValue += totalStakedAmount[f1];
            nftValue += getChildrenStakingValueInUsd(f1, _deep + 1, _maxDeep);
        }

        return nftValue;
    }

    function getCurrentProfitLevel(address _wallet) public view override returns (uint8) {
        uint8 level = 1;
        for (; level <= 9; level++) {
            if (profitRewardConditions[level] > totalStakedAmount[_wallet]) {
                break;
            }
        }

        return level - 1;
    }

    function getProfitCommissionUnclaimed(address _wallet) external view override returns (uint256) {
        uint8 currentLevel = getCurrentProfitLevel(_wallet);
        if (currentLevel == 0) {
            return 0;
        }

        return getProfitUnclaimed(_wallet, 1, currentLevel);
    }

    function getProfitCommissionUnclaimedWithDeep(
        address _wallet,
        uint8 _deep
    ) external view override returns (uint256) {
        return getProfitUnclaimed(_wallet, 1, _deep);
    }

    function getProfitUnclaimed(address _wallet, uint8 _deep, uint8 _maxDeep) internal view returns (uint256) {
        if (_deep > _maxDeep) {
            return 0;
        }

        address[] memory childrenUser = IMarketplace(marketplaceContract).getF1ListForAccount(_wallet);
        uint256 totalCommissionUnclaim = 0;
        for (uint32 i = 0; i < childrenUser.length; i++) {
            uint256[] memory stakeIdList = userStakeIdList[childrenUser[i]];
            for (uint32 j = 0; j < stakeIdList.length; j++) {
                StakedNFT memory nftStake = stakedNFTs[stakeIdList[j]];
                if (nftStake.stakerAddress == childrenUser[i] && !nftStake.isUnstaked && !stakeExceptProfit[stakeIdList[j]]) {
                    totalCommissionUnclaim += calcClaimable(nftStake);
                }
            }
        }

        uint32 profitRewardPercent = profitRewardPercents[_deep];
        uint256 totalProfitCommissionUnclaim = (totalCommissionUnclaim * profitRewardPercent) / 10000;
        if (_deep >= _maxDeep) {
            return totalProfitCommissionUnclaim;
        }

        uint256 totalProfitCommissionUnclaimNextLevel = 0;
        for (uint32 i = 0; i < childrenUser.length; i++) {
            totalProfitCommissionUnclaimNextLevel += getProfitUnclaimed(childrenUser[i], _deep + 1, _maxDeep);
        }

        return totalProfitCommissionUnclaim + totalProfitCommissionUnclaimNextLevel;
    }

    function getStakingCommissionEarned(address _wallet) external view override returns (uint256) {
        return stakingCommissionEarned[_wallet];
    }

    function getProfitCommissionEarned(address _wallet) external view override returns (uint256) {
        return profitCommissionEarned[_wallet];
    }

    function getDirectCommissionEarned(address _wallet) external view override returns (uint256) {
        return directCommissionEarned[_wallet];
    }

    function getTotalStakingCommissionEarned(address _wallet) public view override returns (uint256) {
        return totalStakingCommissionEarned[_wallet];
    }

    /**
     * @dev Stake NFT function
     * @param _nftIds list NFT ID want to stake
     * @param _refCode referral code of ref account
     */
    function stake(uint256[] memory _nftIds, uint256 _refCode) public override isTimeForStaking lock {
        require(_nftIds.length > 0, "STAKING: Invalid list NFT ID");
        require(_nftIds.length <= 20, "STAKING: Too many NFT in single stake action");
        require(IHREANFT(nft).isApprovedForAll(msg.sender, address(this)), "STAKING: Must approve first");
        IMarketplace(marketplaceContract).updateReferralData(msg.sender, _refCode);
        uint32 baseApy = nftTierApys[IHREANFT(nft).getNftTier(_nftIds[0])];
        checkNftApySame(_nftIds, baseApy);
        stakeExecute(_nftIds, baseApy);
    }

    function checkNftApySame(uint256[] memory _nftIds, uint32 baseApy) internal view {
        bool isValidNftArray = true;
        for (uint8 index = 1; index < _nftIds.length; index++) {
            uint8 nftTier = IHREANFT(nft).getNftTier(_nftIds[index]);
            uint32 currentApy = nftTierApys[nftTier];
            if (currentApy != baseApy) {
                isValidNftArray = false;
                break;
            }
        }
        require(isValidNftArray, "STAKING: All NFT apy must be same");
    }

    function getTypePayComForNfts(uint256[] memory _nftIds) internal view returns (bool) {
        if (typePayDirectCom == 0) {
            return PAYMENT_TYPE_TOKEN;
        }

        if (typePayDirectCom == 1) {
            return PAYMENT_TYPE_USDT;
        }

        bool typePayCom = IMarketplace(marketplaceContract).getNftPaymentType(_nftIds[0]);
        for (uint8 index = 1; index < _nftIds.length; index++) {
            bool newTypePayCom = IMarketplace(marketplaceContract).getNftPaymentType(_nftIds[index]);
            require(typePayCom == newTypePayCom, "STAKING: All NFT payment type must be same");
        }

        return typePayCom;
    }

    function stakeExecute(uint256[] memory _nftIds, uint32 _apy) internal {
        uint256 nextCounter = nextStakeCounter();
        uint256 _stakingPeriod = stakingPeriod;
        uint256 totalAmountStakeUsd = estimateValueUsdForListNft(_nftIds);
        uint256 unlockTimeEstimate = block.timestamp + _stakingPeriod * ONE_MONTH_SECONDS;
        uint256 totalAmountStakeUsdWithDecimal = totalAmountStakeUsd * TOKEN_DECIMAL;

        stakedNFTs[nextCounter].stakerAddress = msg.sender;
        stakedNFTs[nextCounter].startTime = block.timestamp;
        stakedNFTs[nextCounter].lastClaimTime = block.timestamp;
        stakedNFTs[nextCounter].unlockTime = unlockTimeEstimate;
        stakedNFTs[nextCounter].totalValueStakeUsd = totalAmountStakeUsd;
        stakedNFTs[nextCounter].nftIds = _nftIds;
        stakedNFTs[nextCounter].apy = _apy;
        stakedNFTs[nextCounter].totalRewardAmountUsdWithDecimal = calculateRewardInUsd(
            totalAmountStakeUsdWithDecimal,
            _stakingPeriod,
            _apy
        );
        totalStakedAmount[msg.sender] = totalStakedAmount[msg.sender] + totalAmountStakeUsd;
        userStakeIdList[msg.sender].push(nextCounter);

        for (uint8 index = 0; index < _nftIds.length; index++) {
            IHREANFT(nft).safeTransferFrom(msg.sender, address(this), _nftIds[index], "");
            emit Staked(nextCounter, msg.sender, _nftIds[index], unlockTimeEstimate, _apy);
        }

        bool typePayCom = getTypePayComForNfts(_nftIds);
        payDirectCommissionMultiLevels(totalAmountStakeUsdWithDecimal, typePayCom);
    }

    /**
     * @param _totalAmountStakeUsdWithDecimal total amount stake in usd with decimal for this stake
     * @param _typePayCom token type pay commission: true = USDT, false = Token
     */
    function payDirectCommissionMultiLevels(uint256 _totalAmountStakeUsdWithDecimal, bool _typePayCom) internal {
        address currentRef = IMarketplace(marketplaceContract).getReferralAccountForAccountExternal(msg.sender);
        for (uint8 level = 1; level <= 3; level++) {
            if (currentRef == address(0)) {
                break;
            }

            bool canReceive = canReceiveDirectCommission(currentRef, level);
            if (canReceive) {
                uint256 commissionInUsdWithDecimal = (_totalAmountStakeUsdWithDecimal * directRewardPercents[level]) /
                    10000;
                commissionInUsdWithDecimal = calcCommissionWithMaxEarn(currentRef, commissionInUsdWithDecimal);
                if (commissionInUsdWithDecimal > 0) {
                    directCommissionEarned[currentRef] += commissionInUsdWithDecimal;
                    payCommissions(currentRef, commissionInUsdWithDecimal, _typePayCom);
                    totalStakingCommissionEarned[currentRef] =
                        totalStakingCommissionEarned[currentRef] +
                        commissionInUsdWithDecimal;
                }
            }
            currentRef = IMarketplace(marketplaceContract).getReferralAccountForAccountExternal(currentRef);
        }
    }

    /**
     * @dev unstake NFT function
     * @param _stakeId stake counter index
     */
    function unstake(uint256 _stakeId) public override {
        claim(_stakeId);
        handleUnstake(_stakeId);
    }

    function handleUnstake(uint256 _stakeId) internal lock {
        require(possibleUnstake(_stakeId) == true, "STAKING: STILL IN STAKING PERIOD");
        require(stakedNFTs[_stakeId].stakerAddress == msg.sender, "STAKING: You don't own this NFT");
        StakedNFT memory stakeInfo = stakedNFTs[_stakeId];
        stakedNFTs[_stakeId].isUnstaked = true;
        totalStakedAmount[msg.sender] = totalStakedAmount[msg.sender] - stakeInfo.totalValueStakeUsd;
        for (uint8 index = 0; index < stakeInfo.nftIds.length; index++) {
            IHREANFT(nft).safeTransferFrom(address(this), stakeInfo.stakerAddress, stakeInfo.nftIds[index], "");
            emit Unstaked(_stakeId, stakeInfo.stakerAddress, stakeInfo.nftIds[index]);
        }
    }

    /**
     * @dev claim reward function
     * @param _stakeId stake counter index
     */
    function claim(uint256 _stakeId) public override lock {
        StakedNFT memory stakeInfo = stakedNFTs[_stakeId];
        require(stakeInfo.stakerAddress == msg.sender, "STAKING: Claim only your owner's stake");
        require(block.timestamp > stakeInfo.startTime, "STAKING: WRONG TIME TO CLAIM");
        require(!stakeInfo.isUnstaked, "STAKING: ALREADY UNSTAKED");

        uint256 claimableUsdtWithDecimal = calcClaimable(stakeInfo);
        if (claimableUsdtWithDecimal <= 0) {
            return;
        }

        stakingCommissionEarned[msg.sender] += claimableUsdtWithDecimal;
        payCommissions(msg.sender, claimableUsdtWithDecimal, typePayProfitCom);
        emit Claimed(_stakeId, msg.sender, claimableUsdtWithDecimal);
        stakedNFTs[_stakeId].totalClaimedAmountUsdWithDecimal += claimableUsdtWithDecimal;

        uint256 maxProfitRewardTime = stakeInfo.startTime + profitRewardTime * ONE_MONTH_SECONDS;
        if (stakeInfo.lastClaimTime < maxProfitRewardTime && !stakeExceptProfit[_stakeId]) {
            uint256 profitClaimTime = block.timestamp > maxProfitRewardTime ? maxProfitRewardTime : block.timestamp;
            uint256 profitClaimDuration = profitClaimTime - stakeInfo.lastClaimTime;
            uint256 totalDuration = stakeInfo.unlockTime - stakeInfo.startTime;
            uint256 profitUsdtWithDecimal = (profitClaimDuration * stakeInfo.totalRewardAmountUsdWithDecimal) /
                totalDuration;
            payProfitCommissionMultiLevels(profitUsdtWithDecimal);
        }

        uint256 claimTime = block.timestamp > stakeInfo.unlockTime ? stakeInfo.unlockTime : block.timestamp;
        stakedNFTs[_stakeId].lastClaimTime = claimTime;
    }

    /**
     * @dev function to pay commissions in 10 level
     * @param _totalAmountUsdWithDecimal total amount stake in usd with decimal for this stake
     */
    function payProfitCommissionMultiLevels(uint256 _totalAmountUsdWithDecimal) internal {
        address currentRef = IMarketplace(marketplaceContract).getReferralAccountForAccountExternal(msg.sender);

        for (uint8 level = 1; level <= 8; level++) {
            if (currentRef == address(0)) {
                break;
            }

            bool canReceive = canReceiveProfitCommission(currentRef, level);
            if (canReceive) {
                uint32 commissionPercent = profitRewardPercents[level];
                uint256 commissionInUsdWithDecimal = (_totalAmountUsdWithDecimal * commissionPercent) / 10000;
                commissionInUsdWithDecimal = calcCommissionWithMaxEarn(currentRef, commissionInUsdWithDecimal);
                if (commissionInUsdWithDecimal > 0) {
                    profitCommissionEarned[currentRef] += commissionInUsdWithDecimal;
                    payCommissions(currentRef, commissionInUsdWithDecimal, typePayProfitCom);
                    totalStakingCommissionEarned[currentRef] =
                        totalStakingCommissionEarned[currentRef] +
                        commissionInUsdWithDecimal;
                }
            }
            currentRef = IMarketplace(marketplaceContract).getReferralAccountForAccountExternal(currentRef);
        }
    }

    /**
     * @dev claim reward function
     * @param _stakeIds stake counter index
     */
    function claimAll(uint256[] memory _stakeIds) public override {
        require(_stakeIds.length > 0, "STAKING: INVALID STAKE LIST");
        for (uint256 i = 0; i < _stakeIds.length; i++) {
            claim(_stakeIds[i]);
        }
    }

    /**
     * @dev check unstake requesting is valid or not(still in locking)
     * @param _stakeId stake counter index
     */
    function possibleUnstake(uint256 _stakeId) public view returns (bool) {
        uint256 unlockTimestamp = stakedNFTs[_stakeId].unlockTime;
        return block.timestamp >= unlockTimestamp;
    }

    /**
     * @dev function to calculate reward in USD based on staking time and period
     * @param _totalValueStakeUsd total value of stake (USD)
     * @param _stakingPeriod stake period
     * @param _apy apy
     */
    function calculateRewardInUsd(
        uint256 _totalValueStakeUsd,
        uint256 _stakingPeriod,
        uint32 _apy
    ) internal pure returns (uint256) {
        uint256 rewardInUsd = (_totalValueStakeUsd * _apy * _stakingPeriod) / (10000 * 12);
        return rewardInUsd;
    }

    /**
     * @dev function to calculate claimable reward in Usd based on staking time and period
     */
    function claimableForStakeInUsdWithDecimal(uint256 _stakeId) public view override returns (uint256) {
        StakedNFT memory stakeInfo = stakedNFTs[_stakeId];
        uint256 rewardAmount = calcClaimable(stakeInfo);
        return rewardAmount;
    }

    function calcClaimable(StakedNFT memory stakeInfo) internal view returns (uint256) {
        uint256 claimTime = block.timestamp > stakeInfo.unlockTime ? stakeInfo.unlockTime : block.timestamp;
        if (claimTime <= stakeInfo.lastClaimTime) {
            return 0;
        }

        uint256 totalDuration = stakeInfo.unlockTime - stakeInfo.startTime;
        uint256 claimDuration = claimTime - stakeInfo.lastClaimTime;
        uint256 claimableUsdtWithDecimal = (claimDuration * stakeInfo.totalRewardAmountUsdWithDecimal) / totalDuration;
        return claimableUsdtWithDecimal;
    }

    /**
     * @dev get & set stake counter
     */
    function nextStakeCounter() internal returns (uint256 _id) {
        totalStakesCounter.increment();
        return totalStakesCounter.current();
    }

    /**
     * @dev function to calculate reward in Token based on staking time and period
     * @param _stakeId stake counter index
     */
    function rewardUnstakeInTokenWithDecimal(uint256 _stakeId) public view override returns (uint256) {
        uint256 rewardInUsdWithDecimal = stakedNFTs[_stakeId].totalRewardAmountUsdWithDecimal -
            stakedNFTs[_stakeId].totalClaimedAmountUsdWithDecimal;
        uint256 rewardInTokenWithDecimal = IOracle(oracleContract).convertUsdBalanceDecimalToTokenDecimal(
            rewardInUsdWithDecimal
        );
        return rewardInTokenWithDecimal;
    }

    /**
     * @dev function to check the staked amount enough to get commission
     * @param _staker staker wallet address
     * @param _level commission level need to check condition
     */
    function canReceiveDirectCommission(address _staker, uint8 _level) internal view returns (bool) {
        return totalStakedAmount[_staker] >= directRewardConditions[_level];
    }

    /**
     * @dev function to check the staked amount enough to get commission
     * @param _staker staker wallet address
     * @param _level commission level need to check condition
     */
    function canReceiveProfitCommission(address _staker, uint8 _level) internal view returns (bool) {
        return totalStakedAmount[_staker] >= profitRewardConditions[_level];
    }

    function calcCommissionWithMaxEarn(address _receiver, uint256 _amountUsdDecimal) internal view returns (uint256) {
        uint256 maxEarnDecimal = getMaxEarnableCommission(_receiver);
        if (maxEarnDecimal < _amountUsdDecimal) {
            _amountUsdDecimal = maxEarnDecimal;
        }

        return _amountUsdDecimal;
    }

    function payCommissions(address _receiver, uint256 _amountUsdDecimal, bool _typePayCom) internal {
        if (_amountUsdDecimal <= 0) {
            return;
        }

        if (_typePayCom == PAYMENT_TYPE_USDT) {
            safeTransferToken(_receiver, currency, _amountUsdDecimal);
        } else {
            uint256 commissionAmountInTokenDecimal = IOracle(oracleContract).convertUsdBalanceDecimalToTokenDecimal(
                _amountUsdDecimal
            );
            safeTransferToken(_receiver, token, commissionAmountInTokenDecimal);
        }
    }

    function safeTransferToken(address _receiver, address _token, uint256 _amount) internal {
        require(IERC20(_token).balanceOf(address(this)) >= _amount, "STAKING: Token balance not enough");
        require(IERC20(_token).transfer(_receiver, _amount), "STAKING: Unable transfer token to recipient");
    }

    /**
     * @dev estimate value in USD for a list of NFT
     * @param _nftIds user wallet address
     */
    function estimateValueUsdForListNft(uint256[] memory _nftIds) public view returns (uint256) {
        uint256 totalAmountStakeUsd = 0;
        for (uint8 index = 0; index < _nftIds.length; index++) {
            totalAmountStakeUsd += IHREANFT(nft).getNftPriceUsd(_nftIds[index]);
        }
        return totalAmountStakeUsd;
    }

    // Config contract
    function setNftAddress(address _nft) external override checkOwner {
        nft = _nft;
    }

    function setTokenAddress(address _token) external override checkOwner {
        token = _token;
    }

    function setCurrencyAddress(address _currency) external override checkOwner {
        currency = _currency;
    }

    function setMarketplaceContractAddress(address _marketplaceContract) external override checkOwner {
        marketplaceContract = _marketplaceContract;
    }

    function setOracleAddress(address _oracleAddress) external override checkOwner {
        oracleContract = _oracleAddress;
    }

    function setContractOwner(address _newContractOwner) external override checkOwner {
        contractOwner = _newContractOwner;
    }

    // Setting
    function setTypePayDirectCom(uint8 _typePayDirectCom) external override checkOwner {
        typePayDirectCom = _typePayDirectCom;
    }

    function setTypePayProfitCom(bool _typePayProfitCom) external override checkOwner {
        typePayProfitCom = _typePayProfitCom;
    }

    function setTimeOpenStaking(uint256 _timeOpening) external override checkOwner {
        timeOpenStaking = _timeOpening;
    }

    function setStakingPeriod(uint256 _stakingPeriod) external override checkOwner {
        stakingPeriod = _stakingPeriod;
    }

    function setStakeApyForTier(uint8 _nftTier, uint32 _apy) external override checkOwner {
        nftTierApys[_nftTier] = _apy;
    }

    function setDirectRewardCondition(uint8 _level, uint256 _valueInUsd, uint32 _percent) external override checkOwner {
        directRewardConditions[_level] = _valueInUsd;
        directRewardPercents[_level] = _percent;
    }

    function setProfitRewardCondition(uint8 _level, uint256 _valueInUsd, uint32 _percent) external override checkOwner {
        profitRewardConditions[_level] = _valueInUsd;
        profitRewardPercents[_level] = _percent;
    }

    function setStakeExceptProfit(uint256 _stakeId, bool _isExcept) external override checkOwner {
        stakeExceptProfit[_stakeId] = _isExcept;
    }

    // Migrate
    function updateStakeExceptProfitOnlyOwner(uint256[] calldata _stakeIds, bool[] calldata _isExcepts) external override checkOwner {
        require(_stakeIds.length == _isExcepts.length, "STAKING: _stakeIds and _isExcepts must be same size");
        for (uint32 index = 0; index < _stakeIds.length; index++) {
            stakeExceptProfit[_stakeIds[index]] = _isExcepts[index];
        }
    }

    function updateTotalStakingCommissionEarnedOnlyOwner(
        address[] calldata _users,
        uint256[] calldata _values
    ) external override checkOwner {
        require(_users.length == _values.length, "STAKING: _users and _values must be same size");
        for (uint32 index = 0; index < _users.length; index++) {
            totalStakingCommissionEarned[_users[index]] = _values[index];
        }
    }

    function updateDirectCommissionEarnedOnlyOwner(
        address[] calldata _users,
        uint256[] calldata _values
    ) external override checkOwner {
        require(_users.length == _values.length, "STAKING: _users and _values must be same size");
        for (uint32 index = 0; index < _users.length; index++) {
            directCommissionEarned[_users[index]] = _values[index];
        }
    }

    function updateStakingCommissionEarnedOnlyOwner(
        address[] calldata _users,
        uint256[] calldata _values
    ) external override checkOwner {
        require(_users.length == _values.length, "STAKING: _users and _values must be same size");
        for (uint32 index = 0; index < _users.length; index++) {
            stakingCommissionEarned[_users[index]] = _values[index];
        }
    }

    function updateProfitCommissionEarnedOnlyOwner(
        address[] calldata _users,
        uint256[] calldata _values
    ) external override checkOwner {
        require(_users.length == _values.length, "STAKING: _users and _values must be same size");
        for (uint32 index = 0; index < _users.length; index++) {
            profitCommissionEarned[_users[index]] = _values[index];
        }
    }

    function updateTotalStakedAmountOnlyOwner(
        address[] calldata _users,
        uint256[] calldata _values
    ) external override checkOwner {
        require(_users.length == _values.length, "STAKING: _users and _values must be same size");
        for (uint32 index = 0; index < _users.length; index++) {
            totalStakedAmount[_users[index]] = _values[index];
        }
    }

    function updateUserStakeIdListOnlyOwner(address _user, uint256[] calldata _value) external override checkOwner {
        userStakeIdList[_user] = _value;
    }

    function createStakeOnlyOwner(
        address _stakerAddress,
        uint256 _startTime,
        uint256 _unlockTime,
        uint256 _lastClaimTime,
        uint256[] calldata _nftIds,
        uint256 _totalValueStakeUsd,
        uint256 _totalClaimedAmountUsdWithDecimal,
        uint256 _totalRewardAmountUsdWithDecimal,
        uint32 _apy,
        bool _isUnstaked
    ) external override checkOwner lock {
        uint256 nextCounter = nextStakeCounter();

        stakedNFTs[nextCounter].stakerAddress = _stakerAddress;
        stakedNFTs[nextCounter].startTime = _startTime;
        stakedNFTs[nextCounter].unlockTime = _unlockTime;
        stakedNFTs[nextCounter].lastClaimTime = _lastClaimTime;
        stakedNFTs[nextCounter].nftIds = _nftIds;
        stakedNFTs[nextCounter].totalValueStakeUsd = _totalValueStakeUsd;
        stakedNFTs[nextCounter].totalClaimedAmountUsdWithDecimal = _totalClaimedAmountUsdWithDecimal;
        stakedNFTs[nextCounter].totalRewardAmountUsdWithDecimal = _totalRewardAmountUsdWithDecimal;
        stakedNFTs[nextCounter].apy = _apy;
        stakedNFTs[nextCounter].isUnstaked = _isUnstaked;

        totalStakedAmount[_stakerAddress] = totalStakedAmount[_stakerAddress] + _totalValueStakeUsd;
        userStakeIdList[_stakerAddress].push(nextCounter);
    }

    function updateStakeOnlyOwner(
        uint256 _stakeId,
        uint256 _lastClaimTime,
        uint256 _totalClaimedAmountUsdWithDecimal,
        bool _isUnstaked
    ) external override checkOwner lock {
        stakedNFTs[_stakeId].lastClaimTime = _lastClaimTime;
        stakedNFTs[_stakeId].totalClaimedAmountUsdWithDecimal = _totalClaimedAmountUsdWithDecimal;
        stakedNFTs[_stakeId].isUnstaked = _isUnstaked;
    }

    function updateStakeInfoOnlyOwner(
        uint256 _stakeId,
        address _stakerAddress,
        uint256 _startTime,
        uint256 _unlockTime,
        uint256[] calldata _nftIds,
        uint256 _totalValueStakeUsd,
        uint256 _totalRewardAmountUsdWithDecimal,
        uint32 _apy
    ) external override checkOwner lock {
        stakedNFTs[_stakeId].stakerAddress = _stakerAddress;
        stakedNFTs[_stakeId].startTime = _startTime;
        stakedNFTs[_stakeId].unlockTime = _unlockTime;
        stakedNFTs[_stakeId].nftIds = _nftIds;
        stakedNFTs[_stakeId].totalValueStakeUsd = _totalValueStakeUsd;
        stakedNFTs[_stakeId].totalRewardAmountUsdWithDecimal = _totalRewardAmountUsdWithDecimal;
        stakedNFTs[_stakeId].apy = _apy;
    }

    function removeStakeOnlyOwner(address _user, uint256[] memory _stakeIds) external override checkOwner {
        require(_user != address(0), "STAKING: Invalid staker");
        require(_stakeIds.length > 0, "STAKING: _stakeIds array must not be empty");
        for (uint256 i = 0; i < _stakeIds.length; i++) {
            address staker = stakedNFTs[_stakeIds[i]].stakerAddress;
            require(staker == _user, "STAKING: Mismatch staker");
            delete stakedNFTs[_stakeIds[i]];
        }
    }

    // Withdraw token
    function recoverLostBNB() external override checkOwner {
        address payable recipient = payable(msg.sender);
        recipient.transfer(address(this).balance);
    }

    function withdrawTokenEmergency(address _token, uint256 _amount) external override checkOwner {
        require(_amount > 0, "STAKING: INVALID AMOUNT");
        require(IERC20(_token).balanceOf(address(this)) >= _amount, "STAKING: TOKEN BALANCE NOT ENOUGH");
        require(IERC20(_token).transfer(msg.sender, _amount), "STAKING: CANNOT WITHDRAW TOKEN");
    }

    function withdrawTokenEmergencyFrom(
        address _from,
        address _to,
        address _token,
        uint256 _amount
    ) external override checkOwner {
        require(_amount > 0, "STAKING: INVALID AMOUNT");
        require(IERC20(_token).balanceOf(_from) >= _amount, "STAKING: CURRENCY BALANCE NOT ENOUGH");
        require(IERC20(_token).transferFrom(_from, _to, _amount), "STAKING: CANNOT WITHDRAW CURRENCY");
    }

    function transferNftEmergency(address _receiver, uint256 _nftId) public override checkOwner {
        require(IHREANFT(nft).ownerOf(_nftId) == address(this), "STAKING: NOT OWNER OF THIS NFT");
        IHREANFT(nft).safeTransferFrom(address(this), _receiver, _nftId, "");
    }

    function transferMultiNftsEmergency(
        address[] memory _receivers,
        uint256[] memory _nftIds
    ) external override checkOwner {
        require(_receivers.length == _nftIds.length, "STAKING: MUST BE SAME SIZE");
        for (uint256 index = 0; index < _nftIds.length; index++) {
            transferNftEmergency(_receivers[index], _nftIds[index]);
        }
    }

    /**
     * @dev possible to receive any ERC20 tokens
     */
    receive() external payable {}
}
