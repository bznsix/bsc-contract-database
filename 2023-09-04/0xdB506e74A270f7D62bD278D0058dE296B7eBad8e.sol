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
pragma solidity ^0.8.4;
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./IBNB_Bank.sol";

contract BNB_Bank_State is Ownable, IBNB_Bank {
    using SafeMath for uint;
    // 1000 == 100%, 100 == 10%, 10 == 1%, 1 == 0.1%
    uint internal constant REFERRAL_LEGNTH = 3;
    uint[REFERRAL_LEGNTH] internal REFERRAL_PERCENTS = [100, 30, 20];
    uint internal INVEST_MIN_AMOUNT = 0.01 ether;
    // uint constant internal INVEST_FEE = 120;
    // uint internal constant WITHDRAW_FEE_PERCENT = 100;
    uint internal constant MIN_WITHDRAW = 1;
    uint internal constant PERCENTS_DIVIDER = 1_000;
    uint internal constant TIME_STEP = 1 days;
    uint internal constant CYCLE_STEP = 1 * TIME_STEP;
    // 2000 == 200%
    uint internal constant MAX_PROFIT = 2_000;
    // uint constant internal MARKET_FEE = 400;
    uint internal constant FORCE_WITHDRAW_PERCENT = 500;
    // 200 == 20%
    uint internal constant ROI_BASE = 200;

    uint internal constant DEFAULT_INVEST_FEE = 100;

    uint internal initDate;

    uint internal totalUsers;
    uint internal totalInvested;
    // uint internal totalInvestedUsd;
    uint internal totalWithdrawn;
    // uint internal totalWithdrawnTokens;
    uint internal totalDeposits;
    // uint internal totalReinvested;

    FeeData public fees;

    address public defaultWallet;
    address public feeWallet;
    address public feeDev;

    Plan public plan;

    mapping(address => User) public users;
    mapping(address => uint) public lastBlock;
    mapping(uint => address) public addressByIndex;

    event Paused(address account);
    event Unpaused(address account);

    modifier tenBlocks() {
        require(block.number.sub(lastBlock[msg.sender]) > 10, "wait 10 blocks");
        _;
        lastBlock[msg.sender] = block.number;
    }

    modifier whenNotPaused() {
        require(initDate > 0, "Pausable: paused");
        _;
    }

    modifier whenPaused() {
        require(initDate == 0, "Pausable: not paused");
        _;
    }

    function setFeeWallet(address _feeWallet) external onlyOwner {
        feeWallet = _feeWallet;
    }

    function setMinInvest(uint _amount) external onlyOwner {
        INVEST_MIN_AMOUNT = _amount;
    }

    function setFees(uint invest, uint withdraw) external onlyOwner {
        fees = FeeData(invest, withdraw);
    }

    function setReferralPercents(
        uint[REFERRAL_LEGNTH] memory _referralPercents
    ) external onlyOwner {
        uint sum;
        for (uint i = 0; i < REFERRAL_LEGNTH; i++) {
            sum = sum.add(_referralPercents[i]);
        }
        require(sum == PERCENTS_DIVIDER, "wrong percents sum");
        REFERRAL_PERCENTS = _referralPercents;
    }

    function getConstans()
        external
        view
        returns (
            uint _refLenght,
            uint _investMinAmount,
            uint _minWithdraw,
            uint _percentsDivider,
            uint _timeStep,
            uint _forceWithdrawPercent,
            uint _maxProfit
        )
    {
        return (
            REFERRAL_LEGNTH,
            INVEST_MIN_AMOUNT,
            MIN_WITHDRAW,
            PERCENTS_DIVIDER,
            TIME_STEP,
            FORCE_WITHDRAW_PERCENT,
            MAX_PROFIT
        );
    }

    function unpause() external whenPaused onlyOwner {
        initDate = block.timestamp;
        emit Unpaused(msg.sender);
    }

    function isPaused() external view returns (bool) {
        return (initDate == 0);
    }

    function getUser(address _user) public view override returns (User memory) {
        return users[_user];
    }

    function getUserByindex(
        uint _index
    ) external view override returns (User memory) {
        return users[addressByIndex[_index]];
    }

    function getAllUsers() external view override returns (User[] memory) {
        User[] memory _users = new User[](totalUsers);
        for (uint i = 0; i < totalUsers; i++) {
            _users[i] = users[addressByIndex[i]];
        }
        return _users;
    }

    function getAllInvestors()
        external
        view
        override
        returns (address[] memory)
    {
        address[] memory _users = new address[](totalUsers);
        for (uint i = 0; i < totalUsers; i++) {
            _users[i] = addressByIndex[i];
        }
        return _users;
    }

    function getUsersByRange(
        uint _init,
        uint end
    ) external view override returns (User[] memory) {
        User[] memory _users = new User[](end - _init);
        for (uint i = _init; i < end; i++) {
            _users[i] = users[addressByIndex[i]];
        }
        return _users;
    }

    function getDepsitStartDate(
        Deposit memory ndeposit
    ) internal view returns (uint) {
        uint _date = getContracDate();
        if (_date > ndeposit.start) {
            return _date;
        } else {
            return ndeposit.start;
        }
    }

    function getUserDepositInfo(
        address userAddress,
        uint index
    )
        external
        view
        returns (uint amount_, uint withdrawn_, uint timeStart_, uint maxProfit)
    {
        Deposit memory deposit = users[userAddress].deposits[index];
        amount_ = deposit.amount;
        withdrawn_ = deposit.withdrawn;
        timeStart_ = getDepsitStartDate(deposit);
        maxProfit = getMaxprofit(deposit);
    }

    function getMaxprofit(
        Deposit memory ndeposit
    ) internal view returns (uint) {
        if (ndeposit.force) {
            return
                (ndeposit.amount.mul(FORCE_WITHDRAW_PERCENT)).div(
                    PERCENTS_DIVIDER
                );
        }
        return (ndeposit.amount.mul(plan.MAX_PROFIT)).div(PERCENTS_DIVIDER);
    }

    function getDeposit(
        address _user,
        uint _index
    ) external view override returns (Deposit memory) {
        return users[_user].deposits[_index];
    }

    function getAllDeposits(
        address _user
    ) external view override returns (Deposit[] memory) {
        return users[_user].deposits;
    }

    function getUserPlans(
        address _user
    ) external view returns (Deposit[] memory) {
        User storage user = users[_user];
        Deposit[] memory result = new Deposit[](user.depositsLength);
        for (uint i; i < user.depositsLength; i++) {
            result[i] = user.deposits[i];
        }
        return result;
    }

    // function getUserTotalDeposits(
    //     address userAddress
    // ) internal view returns (uint) {
    //     User storage user = users[userAddress];
    //     uint amount;
    //     for (uint i; i < user.depositsLength; i++) {
    //         amount += users[userAddress].deposits[i].amount;
    //     }
    //     return amount;
    // }

    // function getUserTotalWithdrawn(
    //     address userAddress
    // ) internal view returns (uint) {
    //     User storage user = users[userAddress];

    //     uint amount;

    //     for (uint i; i < user.depositsLength; i++) {
    //         amount += users[userAddress].deposits[i].withdrawn;
    //     }
    //     return amount;
    // }

    function getDAte() public view returns (uint) {
        return block.timestamp;
    }

    function getReferrerBonus(
        address _user
    ) external view returns (uint[REFERRAL_LEGNTH] memory) {
        return users[_user].referrerBonus;
    }

    function getContracDate() public view returns (uint) {
        if (initDate == 0) {
            return block.timestamp;
        }
        return initDate;
    }

    function getPublicData()
        external
        view
        returns (
            uint totalUsers_,
            uint totalInvested_,
            // uint totalInvestedUsd_,
            // uint totalReinvested_,
            uint totalWithdrawn_,
            uint totalDeposits_,
            uint balance_,
            uint roiBase,
            // uint _totalWithdrawnTokens,
            // uint maxProfit,
            uint minDeposit,
            uint daysFormdeploy
        )
    {
        totalUsers_ = totalUsers;
        totalInvested_ = totalInvested;
        // totalInvestedUsd_ = totalInvestedUsd;
        // totalReinvested_ = totalReinvested;
        totalWithdrawn_ = totalWithdrawn;
        totalDeposits_ = totalDeposits;
        balance_ = getContractBalance();
        roiBase = ROI_BASE;
        // maxProfit = MAX_PROFIT;
        minDeposit = INVEST_MIN_AMOUNT;
        daysFormdeploy = (block.timestamp.sub(getContracDate())).div(TIME_STEP);
        // _totalWithdrawnTokens = totalWithdrawnTokens;
    }

    function getContractBalance() public view returns (uint) {
        return address(this).balance;
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./BNB_Bank_State.sol";

contract BNB_Bank is BNB_Bank_State, ReentrancyGuard  {
    using SafeMath for uint;
    bool public reinvestIsActive = true;
    event Newbie(address user);
    event NewDeposit(address indexed user, uint amount);
    event Withdrawn(address indexed user, uint amount);
    event RefBonus(
        address indexed referrer,
        address indexed referral,
        uint indexed level,
        uint amount
    );
    event FeePayed(address indexed user, uint totalAmount);
    event Reinvestment(address indexed user, uint amount);
    event ForceWithdraw(address indexed user, uint amount);

    constructor(address _feeWallet, address _defaultWallet) {
        User memory _user;
        require(
            _user.referrerCount.length == REFERRAL_LEGNTH &&
                _user.referrerBonus.length == REFERRAL_LEGNTH,
            "invalid referral length"
        );
        feeWallet = _feeWallet;
        feeDev = msg.sender;
        defaultWallet = _defaultWallet;
        plan = Plan(CYCLE_STEP, ROI_BASE, MAX_PROFIT);
        fees = FeeData(DEFAULT_INVEST_FEE, DEFAULT_INVEST_FEE);
        emit Paused(msg.sender);
    }

    modifier checkUser_() {
        uint check = block.timestamp.sub(
            getlastActionDate(users[msg.sender].checkpoint)
        );
        require(check > TIME_STEP, "try again later");
        _;
    }

    function checkUser() external view returns (bool) {
        uint check = block.timestamp.sub(
            getlastActionDate(users[msg.sender].checkpoint)
        );
        if (check > TIME_STEP) {
            return true;
        }
        return false;
    }

    function invest(
        address referrer
    ) external payable nonReentrant whenNotPaused tenBlocks {
        uint _amount = msg.value;
        payFeeInvest(_amount);
        investHandler(_amount, referrer, msg.sender);
    }

    function investHandler(
        uint investAmt,
        address referrer,
        address _user
    ) internal {
        require(investAmt >= INVEST_MIN_AMOUNT, "insufficient deposit");

        User storage user = users[_user];

        if (user.user == address(0)) {
            if (
                user.referrer == address(0) &&
                users[referrer].depositsLength > 0 &&
                referrer != _user &&
                users[referrer].referrer != _user
            ) {
                user.referrer = referrer;
            }
        }

        address upline;

        if (user.referrer != address(0)) {
            upline = user.referrer;
        } else {
            upline = defaultWallet;
        }

        bool isFirst = false;
        if (user.depositsLength == 0) {
            isFirst = true;
        }
        uint toDefault = 0;
        for (uint i; i < REFERRAL_PERCENTS.length; i++) {
            if (upline != address(0)) {
                uint amount = (investAmt.mul(REFERRAL_PERCENTS[i])).div(
                    PERCENTS_DIVIDER
                );

                if (upline == defaultWallet) {
                    toDefault += amount;
                } else {
                    users[upline].bonus += amount;
                }
                users[upline].totalBonus += investAmt;
                if (isFirst) {
                    users[upline].referrerCount[i] += 1;
                    if (i == 0) {
                        users[upline].referralsv0.push(_user);
                    } else if (i == 1) {
                        users[upline].referralsv1.push(_user);
                    } else if (i == 2) {
                        users[upline].referralsv2.push(_user);
                    } else if (i == 3) {
                        users[upline].referralsv3.push(_user);
                    } else if (i == 4) {
                        users[upline].referralsv4.push(_user);
                    }
                }
                users[upline].referrerBonus[i] += amount;
                emit RefBonus(upline, _user, i, amount);
                upline = users[upline].referrer;
                if (upline == address(0)) {
                    upline = defaultWallet;
                }
            } else break;
        }
        if (toDefault > 0) {
            transferHandler(defaultWallet, toDefault);
        }
        if (isFirst) {
            user.user = _user;
            user.checkpoint = block.timestamp;
            user.id = totalUsers;
            addressByIndex[totalUsers] = _user;
            totalUsers++;
            emit Newbie(_user);
        }

        Deposit memory newDeposit;
        // uint usdAmount = contractsLibrary.getBnbToUsd(investAmt);
        newDeposit.amount = investAmt;
        newDeposit.start = block.timestamp;
        // newDeposit.amountBnb = investAmt;
        newDeposit.id = user.depositsLength; // user.deposits[user.depositsLength] = newDeposit;
        user.deposits.push(newDeposit);
        user.depositsLength++;
        user.totalInvested += investAmt;
        // user.totalInvestedBnb += investAmt;

        totalInvested += investAmt;
        // totalInvestedUsd += usdAmount;
        totalDeposits += 1;
        emit NewDeposit(_user, investAmt);
    }

    function withdraw()
        external
        whenNotPaused
        checkUser_
        tenBlocks
    returns (bool) {
        return withdrawInternal(false);
    }

    function withdrawInternal(bool isReinvest) internal returns (bool) {
        if(isReinvest) {
            require(reinvestIsActive, "reinvest is not active");
        }
        User storage user = users[msg.sender];

        uint totalAmount;

        for (uint i; i < user.depositsLength; i++) {
            uint dividends;
            Deposit memory deposit = user.deposits[i];
            if (
                deposit.withdrawn < getMaxprofit(deposit) &&
                deposit.force == false
            ) {
                dividends = calculateDividents(deposit, user.checkpoint);

                if (dividends > 0) {
                    //changing of storage data
                    user.deposits[i].withdrawn += dividends;
                    delete user.deposits[i].acumulated;
                    totalAmount += dividends;
                }
            }
        }

        uint referralBonus = user.bonus;
        if (referralBonus > 0) {
            totalAmount += referralBonus;
            delete user.bonus;
        }

        require(totalAmount >= MIN_WITHDRAW, "User has no dividends");

        uint contractBalance = getContractBalance();
        if (contractBalance < totalAmount) {
            totalAmount = contractBalance;
        }


        user.checkpoint = block.timestamp;
        uint256 fee = payFees(totalAmount);
        emit FeePayed(msg.sender, fee);
        uint256 toTransfer = totalAmount.sub(fee);
        if(!isReinvest) {
            user.totalWithdrawn += totalAmount;
            totalWithdrawn += totalAmount;
            transferHandler(msg.sender, toTransfer);
            emit Withdrawn(msg.sender, totalAmount);
        } else {
            user.reinvest += totalAmount;
            emit Reinvestment(msg.sender, totalAmount);
            investHandler(toTransfer, user.referrer, msg.sender);
        }


        return true;
    }

    function reinvestment()
        external
        whenNotPaused
        checkUser_
        nonReentrant
        returns (bool)
    {
        return withdrawInternal(true);
    }

    function setReinvestStatus(bool _status) external onlyOwner {
        reinvestIsActive = _status;
    }

    function forceWithdraw() external whenNotPaused nonReentrant tenBlocks {
        User storage user = users[msg.sender];
        uint totalDividends;
        uint toFee;
        for (uint256 i; i < user.depositsLength; i++) {
            Deposit storage deposit = user.deposits[i];
            if (deposit.force == false) {
                deposit.force = true;
                uint maxProfit = getMaxprofit(deposit);
                if (deposit.withdrawn < maxProfit) {
                    uint profit = maxProfit.sub(deposit.withdrawn);
                    deposit.withdrawn = deposit.withdrawn.add(profit);
                    totalDividends += profit;
                    toFee += deposit.amount.sub(maxProfit, "sub error");
                }
            }
        }

        // uint referralBonus = user.bonus;
        // if (referralBonus > 0) {
        //     delete user.bonus;
        //     uint bonusToFee = referralBonus.mul(FORCE_WITHDRAW_PERCENT).div(
        //         PERCENTS_DIVIDER
        //     );
        //     totalDividends += referralBonus.sub(bonusToFee, "sub error 1");
        //     toFee += bonusToFee;
        // }

        require(totalDividends > 0, "User has no dividends");
        uint256 contractBalance = getContractBalance();
        if (contractBalance < totalDividends + toFee) {
            totalDividends = contractBalance.mul(FORCE_WITHDRAW_PERCENT).div(
                PERCENTS_DIVIDER
            );
            toFee = contractBalance.sub(totalDividends, "sub error 2");
        }
        user.checkpoint = block.timestamp;
        // payFees(toFee);
        transferHandler(feeWallet, toFee);
        transferHandler(msg.sender, totalDividends);
        emit FeePayed(msg.sender, toFee);
        emit ForceWithdraw(msg.sender, totalDividends);
    }

    function getNextUserAssignment(
        address userAddress
    ) public view returns (uint) {
        uint checkpoint = getlastActionDate(users[userAddress].checkpoint);
        uint _date = getContracDate();
        if (_date > checkpoint) checkpoint = _date;
        return checkpoint.add(TIME_STEP);
    }

    function getUserData(
        address userAddress
    )
        external
        view
        returns (
            uint totalWithdrawn_,
            uint totalDeposits_,
            uint _currentRefBonus,
            // uint totalRefBonus_,
            uint totalReinvest_,
            uint balance_,
            uint nextAssignment_,
            uint amountOfDeposits,
            uint checkpoint,
            uint id,
            address referrer_,
            uint[REFERRAL_LEGNTH] memory referrerCount_,
            uint[REFERRAL_LEGNTH] memory referrerBonus_
        )
    {
        User storage user = users[userAddress];
        totalWithdrawn_ = user.totalWithdrawn;
        totalDeposits_ = user.totalInvested;
        nextAssignment_ = getNextUserAssignment(userAddress);
        balance_ = getUserDividends(userAddress);
        _currentRefBonus = user.bonus;
        // totalRefBonus_ = user.totalBonus;
        totalReinvest_ = user.reinvest;
        amountOfDeposits = user.depositsLength;

        checkpoint = getlastActionDate(user.checkpoint);
        referrer_ = user.referrer;
        referrerCount_ = user.referrerCount;
        referrerBonus_ = user.referrerBonus;
        id = user.id;
    }

    function getUserDividends(
        address userAddress
    ) internal view returns (uint) {
        User storage user = users[userAddress];

        uint totalDividends;

        for (uint i; i < user.depositsLength; i++) {
            Deposit memory deposit = users[userAddress].deposits[i];

            if (
                deposit.withdrawn < getMaxprofit(deposit) &&
                deposit.force == false
            ) {
                uint dividends = calculateDividents(deposit, user.checkpoint);
                totalDividends += dividends;
            }
        }

        totalDividends += user.bonus;

        return totalDividends;
    }

    function calculateDividents(
        Deposit memory deposit,
        uint _userCheckpoint
    ) internal view returns (uint) {
        uint dividends;
        uint depositPercentRate = plan.percent;

        uint checkDate = getDepsitStartDate(deposit);

        if (checkDate < getlastActionDate(_userCheckpoint)) {
            checkDate = getlastActionDate(_userCheckpoint);
        }
        if (checkDate < deposit.checkpoint) {
            checkDate = deposit.checkpoint;
        }

        dividends = (
            deposit.amount.mul(
                depositPercentRate.mul(block.timestamp.sub(checkDate))
            )
        ).div((PERCENTS_DIVIDER).mul(plan.cycle));

        if (
            checkDate <= deposit.bonusEnd &&
            block.timestamp >= deposit.bonusStart
        ) {
            uint startBonus = deposit.bonusStart > checkDate
                ? deposit.bonusStart
                : checkDate;
            uint endBonus = deposit.bonusEnd < block.timestamp
                ? deposit.bonusEnd
                : block.timestamp;
            if (startBonus > endBonus) {
                startBonus = endBonus;
            }
            dividends += (
                deposit.amount.mul(
                    deposit.bonusRoi.mul(endBonus.sub(startBonus))
                )
            ).div((PERCENTS_DIVIDER).mul(plan.cycle));
        }

        dividends += deposit.acumulated;

        /*
		if(dividends + _current > userMaxProfit) {
			dividends = userMaxProfit.sub(_current, "max dividends");
		}
		*/

        if (deposit.withdrawn.add(dividends) > getMaxprofit(deposit)) {
            dividends = getMaxprofit(deposit).sub(deposit.withdrawn);
        }

        return dividends;
    }

    function updateDeposit(
        Deposit storage deposit,
        uint _userCheckpoint
    ) internal {
        require(
            deposit.withdrawn < getMaxprofit(deposit) && deposit.force == false,
            "deposit is closed"
        );

        deposit.acumulated = calculateDividents(deposit, _userCheckpoint);
        deposit.checkpoint = block.timestamp;
    }

    function getlastActionDate(
        uint _userCheckpoint
    ) internal view returns (uint) {
        uint checkpoint = _userCheckpoint;
        uint _date = getContracDate();
        if (_date > checkpoint) checkpoint = _date;
        return checkpoint;
    }

    function isContract(address addr) internal view returns (bool) {
        uint size;
        assembly {
            size := extcodesize(addr)
        }
        return size > 0;
    }

    function transferHandler(address to, uint amount) internal {
        if (amount > getContractBalance()) {
            amount = getContractBalance();
        }
        // if (to != feeWallet) {
        payable(to).transfer(amount);
        // }
        // else {
        //     uint toDev = amount.mul(defaultDevFee).div(PERCENTS_DIVIDER);
        //     payable(dAddress).transfer(toDev);
        //     payable(feeWallet).transfer(amount.sub(toDev));
        // }
    }

    //1_000
    function payFeeInvest(uint amount) internal {
        uint toFee = amount.mul(fees.investFee).div(PERCENTS_DIVIDER);
        uint toDev = toFee.mul(30).div(100);
        transferHandler(feeDev, toDev);
        transferHandler(feeWallet, toFee - toDev);
        emit FeePayed(msg.sender, toFee);
    }

    function payFees(uint amount) internal returns (uint) {
        uint toFee = amount.mul(fees.withdrawFee).div(PERCENTS_DIVIDER);
        uint toDev = toFee.mul(30).div(100);
        transferHandler(feeDev, toDev);
        transferHandler(feeWallet, toFee - toDev);
        emit FeePayed(msg.sender, toFee);
        return toFee;
    }

    fallback() external payable {}

    receive() external payable {}
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

interface IBNB_Bank {
    struct Deposit {
        uint id;
        uint amount;
        uint acumulated;
        // uint amountBnb;
        uint withdrawn;
        uint start;
        uint checkpoint;
        uint bonusStart;
        uint bonusEnd;
        uint bonusRoi;
        bool force;
    }

    struct FeeData {
        uint investFee;
        uint withdrawFee;
    }

    struct Plan {
        uint cycle;
        uint percent;
        uint MAX_PROFIT;
    }

    struct User {
        address user;
        address referrer;
        uint totalInvested;
        // uint totalInvestedBnb;
        uint totalWithdrawn;
        // uint tokenWithdrawn;
        uint depositsLength;
        uint bonus;
        uint reinvest;
        uint totalBonus;
        uint checkpoint;
        uint id;
        Deposit[] deposits;
        address[] referralsv0;
        address[] referralsv1;
        address[] referralsv2;
        address[] referralsv3;
        address[] referralsv4;
        uint[3] referrerCount;
        uint[3] referrerBonus;
    }

    function getUser(address _user) external view returns (User memory);

    function getDeposit(
        address _user,
        uint _index
    ) external view returns (Deposit memory);

    function getAllDeposits(
        address _user
    ) external view returns (Deposit[] memory);

    function getUserByindex(uint _index) external view returns (User memory);

    function getAllUsers() external view returns (User[] memory);

    function getAllInvestors() external view returns (address[] memory);

    function getUsersByRange(
        uint _init,
        uint end
    ) external view returns (User[] memory);
}
