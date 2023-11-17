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

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

interface ISquadNFT is IERC721 {
    function maxSupply() external view returns(uint256);
    function totalSupply() external view returns(uint256);
}/**
 *Submitted for verification at bscscan.com on 2020-09-22
 */

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./interface/ISquadNFT.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract ISEStake is Ownable {
    struct StakerInfo {
        uint256 cakeAmount;
        bool claimed;
        uint256 lastKey;
        bool squadNFTBonusClaimed;
        uint256 userNFTbalance;
    }

    struct GainsInfo {
        uint256 cakeAmount;
        bool claimed;
        address[] referrers;
    }

    IERC20 public immutable CAKE;
    IERC20 public immutable SQUAD;
    ISquadNFT public immutable SquadNFT;

    address public cakeWallet;
    address public squadNFTWallet;
    address public devWallet;

    mapping(address => StakerInfo) public stakerInfo;
    mapping(uint256 => address) registerInfo;
    mapping(address => GainsInfo) public gainsInfo;

    uint256 public totalStakedCake;
    uint256 public ISEbalance;
    uint256 public referralBalance;
    uint256 public squadNFTBonus;
    uint256 nounce;
    uint256 public totalNFTHolds;

    uint256 public startTime;
    uint256 public period = 8 days;
    uint256 public claimStartTime;
    uint256 public claimPeriod = 30 days;

    uint256 public claimedAmountForISE;
    uint256 public claimedAmountForReferral;
    uint256 public claimedAmountForNFTHolders;

    uint256 public threshold = 10 ** 18;

    event Stake(address indexed user, uint256 key, uint256 amount);
    event Claim(address indexed user, uint256 amount);
    event AirDrop(address indexed user, uint256 amount);
    event ClaimForNFTHoldBonus(address indexed user, uint256 amount);

    constructor(address _CAKE, address _SQUAD, address _SquadNFT) {
        CAKE = IERC20(_CAKE);
        SQUAD = IERC20(_SQUAD);
        SquadNFT = ISquadNFT(_SquadNFT);
        ISEbalance = 50_000_000 * (10 ** 18);       // 5% of total amount
        referralBalance = 5_000_000 * (10 ** 18);   // 0.5% of total amount
        squadNFTBonus = 10_000_000 * (10 ** 18);    // 1%
    }

    function stake(uint256 key, uint256 _amount) external returns(uint256) {
        require(startTime > 0, "not started");

        // update staking info
        stakerInfo[msg.sender].cakeAmount += _amount;
        totalStakedCake += _amount;
        uint256 referalCode;

        if (isValidUser(key, msg.sender)) {
            address referrer = registerInfo[key];
            gainsInfo[referrer].cakeAmount += _amount;
            gainsInfo[referrer].referrers.push(referrer);
        }

        // generate referral code (12 digits) when the amount is more than threshold
        if (stakerInfo[msg.sender].cakeAmount >= threshold && stakerInfo[msg.sender].lastKey == 0) {
            referalCode = (nounce % 100) * (10 ** 10) + block.timestamp;
            nounce++;
            registerInfo[referalCode] = msg.sender;
            stakerInfo[msg.sender].lastKey = referalCode;
            stakerInfo[msg.sender].userNFTbalance = SquadNFT.balanceOf(msg.sender);
            totalNFTHolds += stakerInfo[msg.sender].userNFTbalance;
        }
        CAKE.transferFrom(msg.sender, cakeWallet, _amount);

        emit Stake(msg.sender, referalCode, _amount);
        return referalCode;
    }

    function claim() external {
        require(isOver(), "still ISE");
        require(claimStartTime + claimPeriod > block.timestamp, "is over claim");
        require(!stakerInfo[msg.sender].claimed, "claimed");

        (uint256 claimAmount, ) = getClaimAmount(msg.sender);
        require(claimAmount > 0, "no claim");
        stakerInfo[msg.sender].claimed = true;
        claimedAmountForISE = claimedAmountForISE + claimAmount;

        SQUAD.transfer(msg.sender, claimAmount);

        emit Claim(msg.sender, claimAmount);
    }

    function airDropForReferral() external {
        require(isOver(), "still ISE");
        require(claimStartTime + claimPeriod > block.timestamp, "is over claim");
        require(!gainsInfo[msg.sender].claimed, "claimed");

        (, uint256 claimAmount) = getClaimAmount(msg.sender);
        require(claimAmount > 0, "no claim");
        gainsInfo[msg.sender].claimed = true;
        claimedAmountForReferral += claimAmount;

        SQUAD.transfer(msg.sender, claimAmount);

        emit AirDrop(msg.sender, claimAmount);
    }

    function claimForNFTHoldBonus() external {
        require(isOver(), "still ISE");
        require(claimStartTime + claimPeriod > block.timestamp, "is over claim");
        uint256 claimAmount = getClaimForNFTBonus(msg.sender);
        require(claimAmount > 0, "no claim");
        stakerInfo[msg.sender].squadNFTBonusClaimed = true;
        claimedAmountForNFTHolders += claimAmount;
        SQUAD.transfer(msg.sender, claimAmount);

        emit ClaimForNFTHoldBonus(msg.sender, claimAmount);
    }

    function getClaimAmount(
        address user
    ) public view returns (uint256 stakedAmount, uint256 referralAmount) {
        if (totalStakedCake == 0) return (0, 0);
        stakedAmount = stakerInfo[user].cakeAmount * ISEbalance / totalStakedCake;
        referralAmount = gainsInfo[user].cakeAmount * referralBalance / totalStakedCake;
    }

    function getClaimForNFTBonus(address user) public view returns (uint256 reward) {
        if (stakerInfo[user].squadNFTBonusClaimed == true || totalNFTHolds == 0) return 0;
        reward = squadNFTBonus * stakerInfo[user].userNFTbalance / totalNFTHolds;
    }

    function isOver() public view returns (bool) {
        return startTime + period < block.timestamp;
    }

    function getReferrerInfo(address user) external view returns(address[] memory) {
        return gainsInfo[user].referrers;
    }

    function recoverISERewardToken() external onlyOwner {
        require(claimStartTime + claimPeriod < block.timestamp, "still claiming");
        uint256 balance = ISEbalance - claimedAmountForISE;
        claimedAmountForISE = ISEbalance;
        SQUAD.transfer(squadNFTWallet, balance / 2);
        SQUAD.transfer(devWallet, (balance - balance / 2));
    }

    function recoverReferralToken() external onlyOwner {
        require(claimStartTime + claimPeriod < block.timestamp, "still claiming");
        uint256 balance = referralBalance - claimedAmountForReferral;
        claimedAmountForReferral = referralBalance;
        SQUAD.transfer(squadNFTWallet, balance / 2);
        SQUAD.transfer(devWallet, balance - balance / 2);
    }

    function recoverSquadNFTBonusToken() external onlyOwner {
        require(claimStartTime + claimPeriod < block.timestamp, "still claiming");
        uint256 balance = squadNFTBonus - claimedAmountForNFTHolders;
        claimedAmountForNFTHolders = squadNFTBonus;
        SQUAD.transfer(squadNFTWallet, balance / 2);
        SQUAD.transfer(devWallet, balance - balance / 2);
    }

    function start() external onlyOwner {
        require(startTime == 0);
        startTime = block.timestamp;
        claimStartTime = block.timestamp + period;
    }

    function end() external onlyOwner {
        startTime = 0;
        claimStartTime = block.timestamp;
    }

    function setCakeWallet(address _wallet) external onlyOwner {
        cakeWallet = _wallet;
    }

    function setSquadNFTWallet(address _wallet) external onlyOwner {
        squadNFTWallet = _wallet;
    }

    function setDevWallet(address _wallet) external onlyOwner {
        devWallet = _wallet;
    }

    function setThreshold(uint256 _amount) external onlyOwner {
        threshold = _amount;
    }

    function updateClaimPeriod(uint256 _time) external onlyOwner {
        claimPeriod = _time;
    }

    function isValidUser(uint256 key, address user) public view returns (bool) {
        return registerInfo[key] != address(0) && registerInfo[key] != user;
    }
}
