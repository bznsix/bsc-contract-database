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
// OpenZeppelin Contracts (last updated v4.9.0) (utils/math/SafeMath.sol)

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
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
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
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
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
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Referral is Ownable {
    using SafeMath for uint;

    /**
     * @dev Max referral level depth
     */
    uint8 constant MAX_REFER_DEPTH = 3;

    /**
     * @dev Max referee amount to bonus rate depth
     */
    uint8 constant MAX_REFEREE_BONUS_LEVEL = 3;

    /**
     * @dev The struct of account information
     * @param referrer The referrer addresss
     * @param reward The total referral reward of an address
     * @param referredCount The total referral amount of an address
     * @param lastActiveTimestamp The last active timestamp of an address
     */
    struct Account {
        address payable referrer;
        uint reward;
        uint referredCount;
        uint lastActiveTimestamp;
    }

    /**
     * @dev The struct of referee amount to bonus rate
     * @param lowerBound The minial referee amount
     * @param rate The bonus rate for each referee amount
     */
    struct RefereeBonusRate {
        uint lowerBound;
        uint rate;
    }

    event RegisteredReferer(address referee, address referrer);
    event RegisteredRefererFailed(address referee, address referrer, string reason);
    event PaidReferral(address from, address to, uint amount, uint level);
    event UpdatedUserLastActiveTime(address user, uint timestamp);

    mapping(address => Account) public accounts;

    uint256[] levelRate;
    uint256 referralBonus;
    uint256 decimals;
    uint256 secondsUntilInactive;
    bool onlyRewardActiveReferrers;
    RefereeBonusRate[] refereeBonusRateMap;

    /**
     * @param _decimals The base decimals for float calc, for example 1000
     * @param _referralBonus The total referral bonus rate, which will divide by decimals. For example, If you will like to set as 5%, it can set as 50 when decimals is 1000.
     * @param _secondsUntilInactive The seconds that a user does not update will be seen as inactive.
     * @param _onlyRewardActiveReferrers The flag to enable not paying to inactive uplines.
     * @param _levelRate The bonus rate for each level, which will divide by decimals too. The max depth is MAX_REFER_DEPTH.
     * @param _refereeBonusRateMap The bonus rate mapping to each referree amount, which will divide by decimals too. The max depth is MAX_REFER_DEPTH.
     * The map should be pass as [<lower amount>, <rate>, ....]. For example, you should pass [1, 250, 5, 500, 10, 1000] when decimals is 1000 for the following case.
     *
     *  25%     50%     100%
     *   | ----- | ----- |----->
     *  1ppl    5ppl    10ppl
     *
     * @notice refereeBonusRateMap's lower amount should be ascending
     */
    constructor(
        uint _decimals,
        uint _referralBonus,
        uint _secondsUntilInactive,
        bool _onlyRewardActiveReferrers,
        uint16[3] memory _levelRate,
        uint16[2] memory _refereeBonusRateMap
    ) public {
        require(_levelRate.length > 0, "Referral level should be at least one");
        require(_levelRate.length <= MAX_REFER_DEPTH, "Exceeded max referral level depth");
        require(
            _refereeBonusRateMap.length % 2 == 0,
            "Referee Bonus Rate Map should be pass as [<lower amount>, <rate>, ....]"
        );
        require(
            _refereeBonusRateMap.length / 2 <= MAX_REFEREE_BONUS_LEVEL,
            "Exceeded max referree bonus level depth"
        );
        require(_referralBonus <= _decimals, "Referral bonus exceeds 100%");
        require(sum(_levelRate) <= _decimals, "Total level rate exceeds 100%");

        decimals = _decimals;
        referralBonus = _referralBonus;
        secondsUntilInactive = _secondsUntilInactive;
        onlyRewardActiveReferrers = _onlyRewardActiveReferrers;
        levelRate = _levelRate;

        // Set default referee amount rate as 1ppl -> 100% if rate map is empty.
        if (_refereeBonusRateMap.length == 0) {
            refereeBonusRateMap.push(RefereeBonusRate(1, decimals));
            return;
        }

        for (uint i; i < _refereeBonusRateMap.length; i += 2) {
            if (_refereeBonusRateMap[i + 1] > decimals) {
                revert("One of referee bonus rate exceeds 100%");
            }
            // Cause we can't pass struct or nested array without enabling experimental ABIEncoderV2, use array to simulate it
            refereeBonusRateMap.push(
                RefereeBonusRate(_refereeBonusRateMap[i], _refereeBonusRateMap[i + 1])
            );
        }
    }

    function sum(uint16[3] memory data) public pure returns (uint) {
        uint S;
        for (uint i; i < data.length; i++) {
            S += data[i];
        }
        return S;
    }

    /**
     * @dev Utils function for check whether an address has the referrer
     */
    function hasReferrer(address addr) public view returns (bool) {
        return accounts[addr].referrer != address(0);
    }

    /**
     * @dev Get block timestamp with function for testing mock
     */
    function getTime() public view returns (uint256) {
        return block.timestamp; // solium-disable-line security/no-block-members
    }

    /**
     * @dev Given a user amount to calc in which rate period
     * @param amount The number of referrees
     */
    function getRefereeBonusRate(uint256 amount) public view returns (uint256) {
        uint rate = refereeBonusRateMap[0].rate;
        for (uint i = 1; i < refereeBonusRateMap.length; i++) {
            if (amount < refereeBonusRateMap[i].lowerBound) {
                break;
            }
            rate = refereeBonusRateMap[i].rate;
        }
        return rate;
    }

    function isCircularReference(address referrer, address referee) internal view returns (bool) {
        address parent = referrer;

        for (uint i; i < levelRate.length; i++) {
            if (parent == address(0)) {
                break;
            }

            if (parent == referee) {
                return true;
            }

            parent = accounts[parent].referrer;
        }

        return false;
    }

    /**
     * @dev Add an address as referrer
     * @param referrer The address would set as referrer of msg.sender
     * @return whether success to add upline
     */
    function addReferrer(address payable referrer) internal returns (bool) {
        if (referrer == address(0)) {
            emit RegisteredRefererFailed(msg.sender, referrer, "Referrer cannot be 0x0 address");
            return false;
        } else if (isCircularReference(referrer, msg.sender)) {
            emit RegisteredRefererFailed(
                msg.sender,
                referrer,
                "Referee cannot be one of referrer uplines"
            );
            return false;
        } else if (accounts[msg.sender].referrer != address(0)) {
            emit RegisteredRefererFailed(
                msg.sender,
                referrer,
                "Address have been registered upline"
            );
            return false;
        }

        Account storage userAccount = accounts[msg.sender];
        Account storage parentAccount = accounts[referrer];

        userAccount.referrer = referrer;
        userAccount.lastActiveTimestamp = getTime();
        parentAccount.referredCount = parentAccount.referredCount.add(1);

        emit RegisteredReferer(msg.sender, referrer);
        return true;
    }

    /**
     * @dev This will calc and pay referral to uplines instantly
     * @param value The number tokens will be calculated in referral process
     * @return the total referral bonus paid
     */
    function payReferral(uint256 value, IERC20 token) internal returns (uint256) {
        Account storage userAccount = accounts[msg.sender];
        uint totalReferal;

        for (uint i; i < levelRate.length; i++) {
            address payable parent = userAccount.referrer;
            Account storage parentAccount = accounts[userAccount.referrer];

            if (parent == address(0)) {
                break;
            }

            if (
                (onlyRewardActiveReferrers &&
                    parentAccount.lastActiveTimestamp.add(secondsUntilInactive) >= getTime()) ||
                !onlyRewardActiveReferrers
            ) {
                uint c = value.mul(referralBonus).div(decimals);
                c = c.mul(levelRate[i]).div(decimals);
                c = c.mul(getRefereeBonusRate(parentAccount.referredCount)).div(decimals);

                totalReferal = totalReferal.add(c);

                parentAccount.reward = parentAccount.reward.add(c);
                token.transfer(parent, c);
                /* parent.transfer(c); */
                emit PaidReferral(msg.sender, parent, c, i + 1);
            }

            userAccount = parentAccount;
        }

        updateActiveTimestamp(msg.sender);
        return totalReferal;
    }

    /**
     * @dev Developers should define what kind of actions are seens active. By default, payReferral will active msg.sender.
     * @param user The address would like to update active time
     */
    function updateActiveTimestamp(address user) internal {
        uint timestamp = getTime();
        accounts[user].lastActiveTimestamp = timestamp;
        emit UpdatedUserLastActiveTime(user, timestamp);
    }

    function setSecondsUntilInactive(uint _secondsUntilInactive) public onlyOwner {
        secondsUntilInactive = _secondsUntilInactive;
    }

    function setOnlyRewardAActiveReferrers(bool _onlyRewardActiveReferrers) public onlyOwner {
        onlyRewardActiveReferrers = _onlyRewardActiveReferrers;
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "./Referral.sol";

error Staking__TransferFailed();
error NotTimeYet();

contract Staking_v2 is ReentrancyGuard, Referral {
    IERC20 private s_stakingToken;
    address private brykManager;
    bool private initialized;

    mapping(address => uint256) public staked;
    mapping(address => uint256) public previousReward;
    mapping(address => uint256) private stakedFromTS;
    mapping(address => uint256) private stakedToTS;
    mapping(address => uint256) private rewardPercentage;

    //level1=35% / level2=10% / level3=5%
    constructor() Referral(10000, 10000, 365 days, false, [3500, 1000, 500], [1, 10000]) {}

    function init(address stakingToken, address manager) public {
        require(!initialized, "Contract instance has already been initialized");
        initialized = true;
        s_stakingToken = IERC20(stakingToken);
        brykManager = manager;
    }

    function getReward() public view returns (uint256) {
        return
            ((((rewardPercentage[msg.sender] * staked[msg.sender]) / 100) *
                ((block.timestamp - stakedFromTS[msg.sender]) / (1 days))) / 100) +
            previousReward[msg.sender];
    }

    function _stake(uint256 amount, uint256 rp, uint256 rd) private {
        require(amount > 0, "amount is <= 0");

        bool success = s_stakingToken.transferFrom(msg.sender, address(this), amount);
        if (!success) revert Staking__TransferFailed();

        uint256 previousProfit = getReward();
        if (previousProfit > 0) previousReward[msg.sender] = previousProfit;

        rewardPercentage[msg.sender] = rp;
        stakedFromTS[msg.sender] = block.timestamp;
        stakedToTS[msg.sender] = block.timestamp + rd;
        staked[msg.sender] += amount;
    }

    function verifyManager(address _manager) internal view returns (bool) {
        return brykManager == _manager;
    }

    function verify(
        uint256 amount,
        uint256 rp,
        uint256 rd,
        address userAddress,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal view returns (bool) {
        bytes32 messageHash = keccak256(abi.encodePacked(amount, rp, rd, userAddress));
        bytes32 ethSignedMessageHash = keccak256(
            abi.encodePacked("\x19Ethereum Signed Message:\n32", messageHash)
        );
        address recoveredAddress = ecrecover(ethSignedMessageHash, v, r, s);
        return verifyManager(recoveredAddress);
    }

    function stakeRef(
        uint256 amount,
        uint256 rp,
        uint256 rd,
        address payable referrer,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external {
        require(verify(amount, rp, rd, msg.sender, v, r, s), "Invalid signature");
        if ((referrer != address(0)) && (referrer != msg.sender)) addReferrer(referrer);
        _stake(amount, rp, rd);
    }

    function stake(uint256 amount, uint256 rp, uint256 rd, uint8 v, bytes32 r, bytes32 s) external {
        require(verify(amount, rp, rd, msg.sender, v, r, s), "Invalid signature");
        _stake(amount, rp, rd);
    }

    function unstake() external {
        require(staked[msg.sender] > 0, "staked is <= 0");
        require(stakedToTS[msg.sender] <= block.timestamp, "NotTimeYet");

        uint256 daysStaked = (block.timestamp - stakedFromTS[msg.sender]) / (1 days);
        uint256 reward = (((rewardPercentage[msg.sender] * staked[msg.sender]) / 100) *
            daysStaked) / 100;
        uint256 totalReward = staked[msg.sender] + reward + previousReward[msg.sender];

        bool success = s_stakingToken.transfer(msg.sender, totalReward);
        require(success, "Token transfer failed");

        staked[msg.sender] = 0;
        previousReward[msg.sender] = 0;
    }

    function claim() public {
        require(staked[msg.sender] > 0, "staked is <= 0");

        uint256 daysStaked = (block.timestamp - stakedFromTS[msg.sender]) / (1 days);
        uint256 reward = ((((rewardPercentage[msg.sender] * staked[msg.sender]) / 100) *
            daysStaked) / 100) + previousReward[msg.sender];

        bool success = s_stakingToken.transfer(msg.sender, reward);
        require(success, "Token transfer failed");

        stakedFromTS[msg.sender] = block.timestamp;
        previousReward[msg.sender] = 0;
    }
}
