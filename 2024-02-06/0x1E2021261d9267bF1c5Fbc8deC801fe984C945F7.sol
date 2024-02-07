// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

/**
 * @title Launchpad - raise funds for IDO
 * @dev 4 rounds : 0 = not open, 1 = guaranty round, 2 = fcfs, 3 = sale finished
 */
contract LaunchpadRefund is Ownable, ReentrancyGuard {
    using SafeERC20 for IERC20;

    uint16 public round2Multiplier;
    uint256 public saleStartDate;
    uint256 public immutable tokenTarget;
    uint256 public immutable stableTarget;
    uint256 public immutable idoTokenToStableRation; // ratio between tokenTarget and stableTarget * 10000
    uint256 public round1Duration;
    bool public endUnlocked;
    uint256 public totalOwed;
    uint256 public stableRaised;
    
    bool public refundEnabled;
    uint256 public refundPercentage;
    uint256 public constant PERCENTAGE_RATE_CONVERTER = 100;
    uint256 public constant PRECISION_MULTIPLIER = 10_000;

    mapping(address => uint256) public refundedAmount;
    bool ownerRefundExecuted;

    IERC20 public immutable stablecoin;

    mapping(address => bool) public whitelist;
    mapping(address => uint256) private userAllocation;
    mapping(address => bool) public hasParticipated;
    mapping(address => uint256) public contributedRound1;
    mapping(address => uint256) public contributedRound2;
    address[] public participants;
    mapping(address => bool) public admins;

    event SaleWillStart(uint256 startTimestamp);
    event SaleEnded(uint256 endTimestamp);
    event PoolProgress(uint256 stableRaised, uint256 stableTarget);
    event Round2MultiplierChanged(uint16 round2Multiplier);
    event Refunded(address indexed user, uint256 refundAmount);
    event Round1Duration(uint256 duration);

    modifier atRound(uint8 requiredRound) {
        uint8 currentRound = roundNumber();
        require(currentRound == requiredRound, "invalid round");
        _;
    }

    modifier onlyAdmin() {
        require(admins[_msgSender()], "Caller is not the admin");
        _;
    }

    modifier hasStableAllowance(address allower, uint256 amount) {
        // Make sure the allower has provided the right allowance.
        uint256 ourAllowance = stablecoin.allowance(allower, address(this));
        require(ourAllowance >= amount, "allowance too low");

        _;
    }

    constructor(
        uint256 _tokenTarget,
        uint256 _stableTarget,
        uint256 _saleStartDate,
        uint16 _round2Multiplier,
        IERC20 _stableCoinAddress,
        address[] memory _admins,
        uint256 _round1Duration
    ) Ownable() {
        require(_stableTarget > 0, "_stableTarget is zero");
        require(_tokenTarget > 0, "_tokenTarget is zero");
        require(_round2Multiplier > 0, "_round2Multiplier is zero");
        require(address(_stableCoinAddress) != address(0), "stableCoin == address(0)");
        require(_round1Duration > 0, "_round1Duration is zero");

        round1Duration = _round1Duration;
        tokenTarget = _tokenTarget;
        stableTarget = _stableTarget;
        saleStartDate = _saleStartDate;
        round2Multiplier = _round2Multiplier;
        idoTokenToStableRation = (tokenTarget * PRECISION_MULTIPLIER) / stableTarget;
        stablecoin = _stableCoinAddress;

        admins[_msgSender()] = true;
        for (uint256 i = 0; i < _admins.length; i++) {
            admins[_admins[i]] = true;
        }
    }

    function refund() nonReentrant public {
        require(endUnlocked, "Sale not marked as ended");
        require(refundEnabled, "Refund not enabled");
        require(refundPercentage > 0, "Refund percentage is 0");

        address user = _msgSender();    
        require(hasParticipated[user], "Not participated");
        require(refundedAmount[user] == 0, "Already refunded");

        uint256 userContributed = contributedRound1[user] + contributedRound2[user];
        uint256 userRefoundAmount = calculateRefund(user);
        require(userRefoundAmount <= userContributed, "Refund to big");

        refundedAmount[user] = userRefoundAmount;

        stablecoin.safeTransfer(user, userRefoundAmount);
        emit Refunded(user, userRefoundAmount);
    }

    /**
     * @dev method is used to calculate available refund for provided user address
     */
    function calculateRefund(address user) public view returns (uint256 userRefoundAmount) {
        if(!endUnlocked || refundPercentage == 0 || !refundEnabled || refundedAmount[user] > 0 || !hasParticipated[user]) {
            return 0;
        }

        uint256 userContributed = contributedRound1[user] + contributedRound2[user];

        uint256 refundCalculationDividend = userContributed * refundPercentage * PRECISION_MULTIPLIER;
        userRefoundAmount = refundCalculationDividend / (PERCENTAGE_RATE_CONVERTER * PRECISION_MULTIPLIER);
    }

    /**
     * @dev method is used to get amount which is refunded for user
     */
    function getUserRefundedAmount(address user) public view returns (uint256 userRefoundedAmount) {
        userRefoundedAmount =  refundedAmount[user];
    }

    /**
     * @dev activate/deactivate refund
     */
    function setRefundEnabled(bool _refundEnabled) external onlyOwner {
        refundEnabled = _refundEnabled;
    }

    /**
     * @dev method is used to set refund percentage
     */
    function setRefundPercentage(uint256 _refundPercentage) external onlyOwner {
        require(_refundPercentage <= 100, "Refund perc. greater than 100");

        refundPercentage = _refundPercentage;
    }

    /**
     * @dev method is used to add user as admin
     * @param user user address that will be added to admins
     */
    function addAdmin(address user) external onlyOwner {
        admins[user] = true;
    }

    /**
     * @dev method is used to check if user is admin
     * @param user user address
     */
    function isAdmin(address user) external view returns (bool isUserAdmin) {
        isUserAdmin = admins[user];
    }

    /**
     * @dev method is used to set round2Multiplier
     * @param _round2Multiplier round2 (FCFS) multipler. Allowance from round1 is multiplied by this factor
     */
    function setRound2Multiplier(uint16 _round2Multiplier) external onlyOwner {
        round2Multiplier = _round2Multiplier;

        emit Round2MultiplierChanged(_round2Multiplier);
    }

    /**
     * @dev method is used to set sale start date
     * @param _saleStartDate sale start date. Must be in future and sale is not yet started
     */
    function setSaleStartDate(uint256 _saleStartDate) external onlyOwner atRound(0) {
        require(block.timestamp < _saleStartDate, "saleDate in past");

        saleStartDate = _saleStartDate;

        emit SaleWillStart(_saleStartDate);
    }

    /**
     * @dev method is used to set sale start date
     * @param _round1Duration sale start date. Must be in future and sale is not yet started
     */
    function setRound1Duration(uint256 _round1Duration) external onlyOwner atRound(0) {
        require(_round1Duration > 0, "_round1Duration is zero");
        require(!endUnlocked, "sale has ended");
        require(participants.length == 0, "sale has started");

        round1Duration = _round1Duration;

        emit Round1Duration(round1Duration);
    }

    /**
     * @dev method used to mark sale as finished
    */
    function finishSale() external onlyOwner {
        require(!endUnlocked, "sale already ended");

        endUnlocked = true;
        emit SaleEnded(block.timestamp);
    }

    /**
     * @dev method used to add whitelist users with allocation
     * @param user user which will be whitelisted
     * @param allocation user allocation for round 1
    */
    function addWhitelistedAddress(address user, uint256 allocation) external onlyAdmin {
        _addWhitelistedAddress(user, allocation);
    }

    /**
     * @dev method used to add whitelist users with allocation
     * @param users users which will be whitelisted
     * @param allocations user's allocation for round 1
    */
    function addMultipleWhitelistedAddresses(address[] calldata users, uint256[] calldata allocations) external onlyAdmin {
        require(users.length == allocations.length, "must have same length");

        for (uint256 i = 0; i < users.length; i++) {
            _addWhitelistedAddress(users[i], allocations[i]);
        }
    }

    /**
     * @dev method used to remove user from whitelist
     * @param user user which will be removed from whitelist
    */
    function removeWhitelistedAddress(address user) external onlyOwner {
        whitelist[user] = false;
        userAllocation[user] = 0;
    }

    /**
     * @dev method used to collect stable token raised after sale has ended
    */
    function withdrawStable() external onlyOwner {
        require(endUnlocked, "sale not ended");

        stablecoin.safeTransfer(
            _msgSender(),
            stablecoin.balanceOf(address(this))
        );
    }

    /**
     * @dev method used to refund stable token after refund is activated. Only part of refund is available. 1000 - refundPercentage
    */
    function withdrawStableRefund() external onlyOwner {
        require(endUnlocked, "sale not ended");

        require(!ownerRefundExecuted, "Alredy refunded to owner");
        
        ownerRefundExecuted = true;
        
        uint256 ownerRefundPercentage = 100 - refundPercentage;

        uint256 refundCalculationDividend = stableRaised * ownerRefundPercentage * PRECISION_MULTIPLIER;
        uint256 amountToWithdraw = refundCalculationDividend / (PERCENTAGE_RATE_CONVERTER * PRECISION_MULTIPLIER);

        require(amountToWithdraw <= stableRaised, "Refund withdraw too big.");
        require(amountToWithdraw > 0, "Refund withdraw must bigger > 0");

        stablecoin.safeTransfer(
            _msgSender(),
            amountToWithdraw
        );
    }

    /**
     * @dev method used to get user contribution. It is returning stable token invested and token amoun that will receive once vesting starts
     * @param user user address
    */
    function getUserContribution(address user) external view returns (uint256 contributedStable, uint256 tokensToReceive) {
        contributedStable = contributedRound1[user] + contributedRound2[user];
        tokensToReceive = (contributedStable * idoTokenToStableRation) / PRECISION_MULTIPLIER;
    }

    /**
     * @dev rescue any token accidentally sent to this contract
     * @param token address of IREC20 token
    */
    function emergencyWithdrawToken(IERC20 token) external onlyOwner atRound(3) {
        token.safeTransfer(_msgSender(), token.balanceOf(address(this)));
    }

    /**
     * @dev participate in round1. User can invest up to amount whitelisted for sale.
     * @param stableAmount amount to buy
    */
    function buyRound1(uint256 stableAmount) external atRound(1) hasStableAllowance(_msgSender(), stableAmount) {
        address user = _msgSender();

        uint256 allowance = round1Allowance(user);

        _checkAllowance(allowance, stableAmount);

        _registerParticipation(user);

        contributedRound1[user] += stableAmount;

        _buy(stableAmount);
    }

    /**
     * @dev participate in round2 (FCFS). User can invest up to (round2Multiplier * whitelisted amount) for sale. 
     * @param stableAmount amount to buy
    */
    function buyRound2(uint256 stableAmount) external atRound(2) hasStableAllowance(_msgSender(), stableAmount) {
        address user = _msgSender();

        uint256 allowance = round2Allowance(user);

        _checkAllowance(allowance, stableAmount);

        _registerParticipation(user);

        contributedRound2[user] += stableAmount;

        _buy(stableAmount);
    }

    /**
     * @dev returns current round calculated, depnding on state of contract
    */
    function roundNumber() public view returns (uint8 _roundNumber) {
        if (endUnlocked) return 3;

        if (block.timestamp < saleStartDate || saleStartDate == 0) {
            return 0;
        }

        if (block.timestamp >= saleStartDate && block.timestamp < saleStartDate + round1Duration) {
            return 1;
        }

        if (block.timestamp >= (saleStartDate + round1Duration)) {
            return 2;
        }
    }

    /**
     * @dev returns number of participatns
    */
    function getNumberOfParticipants() public view returns (uint256) {
        return participants.length;
    }

    /**
     * @dev returns flag if user is whitelisted
     * @param user user address
    */
    function isWhitelisted(address user) public view returns (bool) {
        return whitelist[user];
    }

    /**
     * @dev returns round1 allowance
     * @param user user address
    */
    function round1Allowance(address user) public view returns (uint256) {
        if (!whitelist[user]) return 0;

        return userAllocation[user] - contributedRound1[user];
    }

    /**
     * @dev returns round2 allowance
     * @param user user address
    */
    function round2Allowance(address user) public view returns (uint256) {
        if (!whitelist[user]) return 0;

        return
            (userAllocation[user] * round2Multiplier) - contributedRound2[user];
    }

    function _addWhitelistedAddress(address user, uint256 allocation) private {
        whitelist[user] = true;
        userAllocation[user] = allocation;
    }

    function _checkAllowance(uint256 allowance, uint256 amount) private pure {
        require(allowance > 0, "invlaid allowance");
        require(allowance >= amount, "amount bigger than allowance");
    }

    function _registerParticipation(address user) private {
        if (!hasParticipated[user]) {
            hasParticipated[user] = true;
            participants.push(user);
        }
    }

    function _buy(uint256 stableAmount) nonReentrant private {
        require(stableAmount > 0, "stableAmount is 0");

        stablecoin.safeTransferFrom(_msgSender(), address(this), stableAmount);

        uint256 tokenAmount = (stableAmount * idoTokenToStableRation) / PRECISION_MULTIPLIER;

        totalOwed += tokenAmount;
        require(tokenTarget >= totalOwed, "soldout");

        stableRaised += stableAmount;
        require(stableTarget >= stableRaised, "soldout");
        
        emit PoolProgress(stableRaised, stableTarget);

        if (stableRaised == stableTarget) {
            endUnlocked = true;
            emit SaleEnded(block.timestamp);
        }
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
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
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";
import "../../../utils/Address.sol";

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

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
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
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
// OpenZeppelin Contracts v4.4.1 (security/ReentrancyGuard.sol)

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
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (utils/Address.sol)

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
        return functionCall(target, data, "Address: low-level call failed");
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
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
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
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
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
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verifies that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason using the provided one.
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
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
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
