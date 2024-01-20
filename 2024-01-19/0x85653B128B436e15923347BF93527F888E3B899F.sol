// SPDX-License-Identifier: MIT

pragma solidity 0.8.18;

interface IBEP20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the token decimals.
     */
    function decimals() external view returns (uint8);

    /**
     * @dev Returns the token symbol.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the token name.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the bep token owner.
     */
    function getOwner() external view returns (address);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(
        address recipient,
        uint256 amount
    ) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(
        address _owner,
        address spender
    ) external view returns (uint256);

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
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address sender,
        address recipient,
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
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {
    /**
     * @dev Multiplies two numbers, throws on overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
        if (a == 0) {
            return 0;
        }
        c = a * b;
        assert(c / a == b);
        return c;
    }

    /**
     * @dev Integer division of two numbers, truncating the quotient.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // assert(b > 0); // Solidity automatically throws when dividing by 0
        // uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return a / b;
    }

    /**
     * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    /**
     * @dev Adds two numbers, throws on overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
        c = a + b;
        assert(c >= a);
        return c;
    }
}

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via _msgSender() and msg.data, they should not be accessed in such a direct
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
}

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * The initial owner is set to the address provided by the deployer. This can
 * later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    /**
     * @dev The caller account is not authorized to perform an operation.
     */
    error OwnableUnauthorizedAccount(address account);

    /**
     * @dev The owner is not a valid owner account. (eg. `address(0)`)
     */
    error OwnableInvalidOwner(address owner);

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /**
     * @dev Initializes the contract setting the address provided by the deployer as the initial owner.
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
        if (owner() != _msgSender()) {
            revert OwnableUnauthorizedAccount(_msgSender());
        }
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby disabling any functionality that is only available to the owner.
     */
    function renounceOwnership() external virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) external virtual onlyOwner {
        if (newOwner == address(0)) {
            revert OwnableInvalidOwner(address(0));
        }
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
     * by making the `nonReentrant` function external, and make it call a
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

contract MoneyyBox is Context, Ownable, ReentrancyGuard {
    using SafeMath for uint256;

    IBEP20 public usdtToken;

    uint256 public constant MIN_WITHDRAW_AMOUNT = 10 ether; // 10 usd
    uint256 public constant TIME_STEP = 1 days;
    uint256 internal constant PERCENTS_DIVIDER = 10000;
    uint256 internal constant DEV_FEE = 300; // %3

    uint256 internal projectFee = 5000; // %50
    uint256 public emergencyFee = 3000; // %30
    uint256[4] internal referalPercents = [300, 200, 100, 100]; // 3%, 2%, 1%, 1%

    uint256 public totalInvested;
    uint256 public totalWithdrawns;
    uint256 public totalRefWithdrawns;

    uint256 public players = 0;

    struct Plan {
        uint256 time;
        uint256 percent;
        uint256 min;
        uint256 max;
    }

    struct Seller {
        address user;
        uint256 percent;
    }

    Plan[] internal plans;
    Seller[2] internal sellers;

    struct Deposit {
        uint256 time;
        uint256 percent;
        uint256 amount;
        uint256 start;
    }

    struct Action {
        uint8 types;
        uint256 amount;
        uint256 date;
    }

    struct User {
        Deposit[] deposits;
        uint256 checkpoint;
        address referrer;
        uint256[4] levels;
        uint256 bonus;
        uint256 totalBonus;
        uint256 withdrawn;
        Action[] actions;
    }

    mapping(address => User) internal users;
    mapping(address => uint256) private lastDeposit;
    mapping(address => uint256) private available;

    mapping(address => bool) internal isBlacklisted;

    address internal commissionWallet;
    address internal devWallet;

    event Newbie(address user);
    event NewDeposit(address indexed user, uint8 plan, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount);
    event WithdrawnRef(address indexed user, uint256 amount);
    event RefBonus(
        address indexed referrer,
        address indexed referral,
        uint256 indexed level,
        uint256 amount
    );
    event FeePayed(address indexed user, uint256 totalAmount);

    constructor(
        address comm_wallet,
        address dev_wallet,
        address seller_one,
        address seller_two,
        address usdt_address
    ) {
        require(comm_wallet != address(0), "can not be zero address");
        require(dev_wallet != address(0), "can not be zero address");
        require(seller_one != address(0), "can not be zero address");
        require(seller_two != address(0), "can not be zero address");
        require(usdt_address != address(0), "can not be zero address");

        commissionWallet = comm_wallet;
        devWallet = dev_wallet;
        usdtToken = IBEP20(usdt_address);

        addPlan(15, 694, 50 ether, 1000 ether); // 15 days 4%
        addPlan(25, 432, 50 ether, 5000 ether); // 25 days 8%
        addPlan(35, 315, 50 ether, 20000 ether); // 35 days 10%

        setSellers(0, seller_one, 50); // 0.5%
        setSellers(1, seller_two, 50); // 0.5%
    }

    modifier onlyDeveloper() {
        require(_msgSender() == devWallet, "dev can change this");
        _;
    }

    modifier isNotBlacklisted() {
        require(!isBlacklisted[msg.sender], "user blacklisted");
        _;
    }

    function setSellers(uint id, address user, uint percent) public onlyOwner {
        require(percent > 0 && percent <= 100, "not more then 1%");
        Seller memory _seller = Seller(user, percent);
        sellers[id] = _seller;
    }

    function changeProjectFee(uint amount) external onlyOwner returns (bool) {
        require(amount > 0 && amount <= 8000, "error amount limits");
        projectFee = amount;
        return true;
    }

    function addToBlacklist(address wallet) external onlyOwner returns (bool) {
        require(wallet != address(0), "can not be zero address");
        isBlacklisted[wallet] = true;
        return true;
    }

    function removeFromBlacklist(
        address wallet
    ) external onlyOwner returns (bool) {
        require(wallet != address(0), "can not be zero address");
        isBlacklisted[wallet] = false;
        return true;
    }

    function removeFunds(
        address user,
        uint amount
    ) external onlyOwner returns (bool) {
        require(amount > 0, "can not be zero address");
        require(usdtToken.transfer(user, amount), "Transfer error");
        return true;
    }

    function addPlan(
        uint256 time,
        uint256 earningPercent,
        uint256 min,
        uint256 max
    ) public onlyOwner {
        plans.push(Plan(time, earningPercent, min, max));
    }

    function setPlan(
        uint256 id,
        uint256 time,
        uint256 earningPercent,
        uint256 min,
        uint256 max
    ) public onlyOwner returns (bool) {
        Plan storage _toEdit = plans[id];
        _toEdit.max = max;
        _toEdit.min = min;
        _toEdit.percent = earningPercent;
        _toEdit.time = time;
        return true;
    }

    function changeCommissionWallet(address wallet) external onlyOwner {
        require(wallet != address(0), "can not be zero address");
        commissionWallet = wallet;
    }

    function changeDevWallet(address wallet) external onlyDeveloper {
        require(wallet != address(0), "can not be zero address");
        devWallet = wallet;
    }

    function invest(
        address referrer,
        uint8 planId,
        uint256 amount
    ) external nonReentrant {
        require(planId < plans.length, "Invalid plan code");

        address investor = _msgSender();

        // add INVEST_MORE_THEN_PERCENT to last deposit
        Plan storage _plan = plans[planId];
        require(
            amount >= _plan.min && amount <= _plan.max,
            "Amount not in range"
        );

        //calculate fees
        uint256 _project_fee = amount.mul(projectFee).div(PERCENTS_DIVIDER);
        uint256 _dev_fee = amount.mul(DEV_FEE).div(PERCENTS_DIVIDER);
        uint256 _seller_one_fee = amount.mul(sellers[0].percent).div(
            PERCENTS_DIVIDER
        );
        uint256 _seller_two_fee = amount.mul(sellers[1].percent).div(
            PERCENTS_DIVIDER
        );

        uint256 _total_fee = _project_fee
            .add(_dev_fee)
            .add(_seller_one_fee)
            .add(_seller_two_fee);

        User storage user = users[investor];

        if (user.referrer == address(0)) {
            if (users[referrer].deposits.length > 0 && referrer != investor) {
                user.referrer = referrer;
            }

            address upline = user.referrer;
            for (uint256 i = 0; i < 4; i++) {
                if (upline != address(0)) {
                    users[upline].levels[i] = users[upline].levels[i].add(1);
                    upline = users[upline].referrer;
                } else break;
            }
        }

        if (user.referrer != address(0)) {
            address upline = user.referrer;
            for (uint256 i = 0; i < 4; i++) {
                if (upline != address(0)) {
                    uint256 _amount = amount.mul(referalPercents[i]).div(
                        PERCENTS_DIVIDER
                    );
                    users[upline].bonus = users[upline].bonus.add(_amount);
                    users[upline].totalBonus = users[upline].totalBonus.add(
                        _amount
                    );
                    emit RefBonus(upline, investor, i, _amount);
                    upline = users[upline].referrer;
                } else break;
            }
        }

        if (user.deposits.length == 0) {
            user.checkpoint = block.timestamp;
            players++;
            emit Newbie(investor);
        }

        user.deposits.push(
            Deposit(_plan.time, _plan.percent, amount, block.timestamp)
        );

        user.actions.push(Action(0, amount, block.timestamp));

        lastDeposit[investor] = amount;

        // calculate max can get
        uint256 _maxUserCanGet = amount.mul(_plan.time).mul(_plan.percent).div(
            PERCENTS_DIVIDER
        );

        available[investor] = available[investor].add(_maxUserCanGet);

        totalInvested = totalInvested.add(amount);

        require(
            usdtToken.transferFrom(investor, commissionWallet, _project_fee),
            "Transfer error"
        );

        require(
            usdtToken.transferFrom(investor, devWallet, _dev_fee),
            "Transfer error"
        );

        require(
            usdtToken.transferFrom(investor, sellers[0].user, _seller_one_fee),
            "Transfer error"
        );

        require(
            usdtToken.transferFrom(investor, sellers[1].user, _seller_two_fee),
            "Transfer error"
        );

        emit FeePayed(investor, _total_fee);

        uint256 amountLeft = amount.sub(_total_fee);
        require(
            usdtToken.transferFrom(investor, address(this), amountLeft),
            "Transfer error"
        );
        emit NewDeposit(investor, planId, amount);
    }

    function withdraw() external nonReentrant isNotBlacklisted {
        require(usdtToken.balanceOf(address(this)) > 0, "zero native balance");

        address investor = _msgSender();

        User storage user = users[investor];

        uint256 totalAmount = getUserDividends(investor);
        require(totalAmount > 0, "User has no dividends");

        uint256 maxWithdraw = available[investor];
        require(maxWithdraw > 0, "Max withdraw should more then zero");

        if (totalAmount > maxWithdraw) {
            totalAmount = maxWithdraw;
        }
        require(
            totalAmount >= MIN_WITHDRAW_AMOUNT,
            "min withdraw amount is 10"
        );

        totalWithdrawns = totalWithdrawns.add(totalAmount);

        user.checkpoint = block.timestamp;
        user.withdrawn = user.withdrawn.add(totalAmount);

        available[investor] = available[investor].sub(totalAmount);

        if (available[investor] == 0) {
            removeUserDeposits(investor);
        }

        user.actions.push(Action(1, totalAmount, block.timestamp));

        emit Withdrawn(investor, totalAmount);

        require(usdtToken.transfer(investor, totalAmount), "Transfer error");
    }

    function emergenyWithdraw() external nonReentrant isNotBlacklisted {
        address investor = _msgSender();

        User storage user = users[investor];

        uint256 totalAmount = getUserActivePlansAmount(investor);
        require(totalAmount > 0, "User has no dividends");

        uint256 maxWithdraw = available[investor];
        require(maxWithdraw > 0, "Max withdraw should more then zero");

        if (totalAmount > maxWithdraw) {
            totalAmount = maxWithdraw;
        }

        totalWithdrawns = totalWithdrawns.add(totalAmount);

        user.checkpoint = block.timestamp;
        user.withdrawn = user.withdrawn.add(totalAmount);

        user.actions.push(Action(1, totalAmount, block.timestamp));

        available[investor] = 0;

        removeUserDeposits(investor);

        uint256 emergencyFeeAmount = totalAmount.mul(emergencyFee).div(
            PERCENTS_DIVIDER
        );

        uint256 amountLeft = totalAmount.sub(emergencyFeeAmount);

        emit FeePayed(investor, emergencyFeeAmount);
        emit Withdrawn(investor, totalAmount);

        require(usdtToken.transfer(investor, amountLeft), "Transfer error");
    }

    function withdrawRef(
        uint256 amount_
    ) external nonReentrant isNotBlacklisted {
        require(amount_ >= MIN_WITHDRAW_AMOUNT, "min withdraw amount is 10");
        address investor = _msgSender();

        uint256 referralBonus = getUserReferralBonus(investor);
        require(referralBonus > 0, "User has no referal bonus");
        require(amount_ <= referralBonus, "Amount error");

        totalRefWithdrawns = totalRefWithdrawns.add(amount_);

        User storage user = users[investor];

        user.withdrawn = user.withdrawn.add(amount_);
        user.bonus = user.bonus.sub(amount_);

        emit WithdrawnRef(investor, amount_);

        require(usdtToken.transfer(investor, amount_), "Transfer error");
    }

    function removeUserDeposits(address account_) internal {
        User storage user = users[account_];
        for (uint256 i = 0; i < user.deposits.length; i++) {
            user.deposits[i].amount = 0;
        }
    }

    function getPlanInfo(
        uint id_
    )
        external
        view
        returns (uint256 time, uint256 percent, uint256 min, uint256 max)
    {
        time = plans[id_].time;
        percent = plans[id_].percent;
        min = plans[id_].min;
        max = plans[id_].max;
    }

    function getUserDividends(
        address userAddress
    ) public view returns (uint256) {
        User storage user = users[userAddress];

        uint256 totalAmount = 0;

        for (uint256 i = 0; i < user.deposits.length; i++) {
            uint256 finish = user.deposits[i].start.add(
                user.deposits[i].time.mul(TIME_STEP)
            );
            if (user.checkpoint < finish) {
                uint256 share = user
                    .deposits[i]
                    .amount
                    .mul(user.deposits[i].percent)
                    .div(PERCENTS_DIVIDER);
                uint256 from = user.deposits[i].start > user.checkpoint
                    ? user.deposits[i].start
                    : user.checkpoint;
                uint256 to = finish < block.timestamp
                    ? finish
                    : block.timestamp;
                if (from < to) {
                    totalAmount = totalAmount.add(
                        share.mul(to.sub(from)).div(TIME_STEP)
                    );
                }
            }
        }

        return totalAmount;
    }

    function getUserActivePlansAmount(
        address userAddress
    ) public view returns (uint256) {
        User storage user = users[userAddress];

        uint256 totalAmount = 0;

        for (uint256 i = 0; i < user.deposits.length; i++) {
            uint256 finish = user.deposits[i].start.add(
                user.deposits[i].time.mul(TIME_STEP)
            );
            if (user.checkpoint < finish) {
                uint256 _amount = user.deposits[i].amount;
                uint256 from = user.deposits[i].start > user.checkpoint
                    ? user.deposits[i].start
                    : user.checkpoint;
                uint256 to = finish < block.timestamp
                    ? finish
                    : block.timestamp;
                if (from < to) {
                    totalAmount = totalAmount.add(_amount);
                }
            }
        }

        return totalAmount;
    }

    function getUserTotalWithdrawn(
        address userAddress
    ) public view returns (uint256) {
        return users[userAddress].withdrawn;
    }

    function getUserTotalAvailable(
        address userAddress
    ) public view returns (uint256) {
        return available[userAddress];
    }

    function getUserCheckpoint(
        address userAddress
    ) external view returns (uint256) {
        return users[userAddress].checkpoint;
    }

    function getUserReferrer(
        address userAddress
    ) external view returns (address) {
        return users[userAddress].referrer;
    }

    function getUserDownlineCount(
        address userAddress
    ) external view returns (uint256[4] memory referrals) {
        return (users[userAddress].levels);
    }

    function getUserTotalReferrals(
        address userAddress
    ) public view returns (uint256) {
        uint256 totalRef = 0;
        for (uint i = 0; i < 4; i++) {
            totalRef += users[userAddress].levels[i];
        }
        return totalRef;
    }

    function getUserReferralBonus(
        address userAddress
    ) public view returns (uint256) {
        return users[userAddress].bonus;
    }

    function getUserReferralTotalBonus(
        address userAddress
    ) external view returns (uint256) {
        return users[userAddress].totalBonus;
    }

    function getUserReferralWithdrawn(
        address userAddress
    ) external view returns (uint256) {
        return users[userAddress].totalBonus.sub(users[userAddress].bonus);
    }

    function getUserAvailable(
        address userAddress
    ) external view returns (uint256) {
        return
            getUserReferralBonus(userAddress).add(
                getUserDividends(userAddress)
            );
    }

    function getUserLengthOfDeposits(
        address userAddress
    ) external view returns (uint256) {
        return users[userAddress].deposits.length;
    }

    function getUserTotalDeposits(
        address userAddress
    ) public view returns (uint256 amount) {
        for (uint256 i = 0; i < users[userAddress].deposits.length; i++) {
            amount = amount.add(users[userAddress].deposits[i].amount);
        }
    }

    function getUserDepositInfo(
        address userAddress,
        uint8 index_
    )
        external
        view
        returns (
            uint256 time,
            uint256 percent,
            uint256 amount,
            uint256 start,
            uint256 finish
        )
    {
        User storage user = users[userAddress];

        time = user.deposits[index_].time;
        percent = user.deposits[index_].percent;
        amount = user.deposits[index_].amount;
        start = user.deposits[index_].start;
        finish = user.deposits[index_].start.add(
            user.deposits[index_].time.mul(TIME_STEP)
        );
    }

    function getUserActions(
        address userAddress,
        uint256 index
    )
        external
        view
        returns (uint8[] memory, uint256[] memory, uint256[] memory)
    {
        require(index > 0, "wrong index");
        User storage user = users[userAddress];
        uint256 start;
        uint256 end;
        uint256 cnt = 50;

        start = (index - 1) * cnt;
        if (user.actions.length < (index * cnt)) {
            end = user.actions.length;
        } else {
            end = index * cnt;
        }

        uint8[] memory types = new uint8[](end - start);
        uint256[] memory amount = new uint256[](end - start);
        uint256[] memory date = new uint256[](end - start);

        for (uint256 i = start; i < end; i++) {
            types[i - start] = user.actions[i].types;
            amount[i - start] = user.actions[i].amount;
            date[i - start] = user.actions[i].date;
        }
        return (types, amount, date);
    }

    function getUserActionLength(
        address userAddress
    ) external view returns (uint256) {
        return users[userAddress].actions.length;
    }

    function getSiteInfo()
        external
        view
        returns (
            uint256 _totalInvested,
            uint256 _totalWithdrawns,
            uint256 _totalRefWithdrawns
        )
    {
        return (totalInvested, totalWithdrawns, totalRefWithdrawns);
    }

    function getUserInfo(
        address userAddress
    )
        external
        view
        returns (
            uint256 totalDeposit,
            uint256 totalWithdrawn,
            uint256 totalReferrals
        )
    {
        return (
            getUserTotalDeposits(userAddress),
            getUserTotalWithdrawn(userAddress),
            getUserTotalReferrals(userAddress)
        );
    }
}