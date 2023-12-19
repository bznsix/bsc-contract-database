// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.20;

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
     * @dev Returns the value of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the value of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves a `value` amount of tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 value) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets a `value` amount of tokens as the allowance of `spender` over the
     * caller's tokens.
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
    function approve(address spender, uint256 value) external returns (bool);

    /**
     * @dev Moves a `value` amount of tokens from `from` to `to` using the
     * allowance mechanism. `value` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address from, address to, uint256 value) external returns (bool);
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (utils/ReentrancyGuard.sol)

pragma solidity ^0.8.20;

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
    uint256 private constant NOT_ENTERED = 1;
    uint256 private constant ENTERED = 2;

    uint256 private _status;

    /**
     * @dev Unauthorized reentrant call.
     */
    error ReentrancyGuardReentrantCall();

    constructor() {
        _status = NOT_ENTERED;
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
        // On the first call to nonReentrant, _status will be NOT_ENTERED
        if (_status == ENTERED) {
            revert ReentrancyGuardReentrantCall();
        }

        // Any calls to nonReentrant after this point will fail
        _status = ENTERED;
    }

    function _nonReentrantAfter() private {
        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = NOT_ENTERED;
    }

    /**
     * @dev Returns true if the reentrancy guard is currently set to "entered", which indicates there is a
     * `nonReentrant` function in the call stack.
     */
    function _reentrancyGuardEntered() internal view returns (bool) {
        return _status == ENTERED;
    }
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Billboost_status is ReentrancyGuard {
	// using SafeMath for uint;
	IERC20 public token; //0xFBc7460d6644192c483d0F291241928b60F09C08 - BILLS
	address public devAddress;
	address constant public ownerAddress = 0x103f80FDfCE3966651C4c2327a249B7096258BB3;
	// Dev 2%
	uint constant public DEV_FEE = 300;
	// owner 2%
	uint constant public OWNER_FEE = 700;

	uint constant public WITHDRAW_FEE_BASE = 500;
	uint constant public MAX_PROFIT = 20000;
	// 10000 = 100%, 1000 = 10%, 100 = 1%, 10 = 0.1%, 1 = 0.01%
	uint constant public PERCENTS_DIVIDER = 10000;
	uint constant public ROI_BASE = 30;
	uint constant public MACHINE_ROI = 15;

	uint constant public MACHINEBONUS_LENGTH = 20;
	uint[MACHINEBONUS_LENGTH] internal REFERRAL_PERCENTS = [4000, 2400, 1600, 600, 400, 200, 200, 200, 200, 200, 200, 200, 200, 200, 200, 400, 600, 1600, 2400, 4000];
	uint constant public INVEST_MIN_AMOUNT = 21 ether;
	uint constant public MINIMAL_REINVEST_AMOUNT = 0.01 ether;

	uint constant public MIN_WITHDRAW = 1;
	// uint constant internal WITHDRAW_FEE_PERCENT = 50;
	uint constant public WITHDRAW_FEE_PERCENT_DAY = 1000;
	uint constant public WITHDRAW_FEE_PERCENT_WEEK = 700;
	uint constant public WITHDRAW_FEE_PERCENT_TWO_WEEK = 300;
	uint constant public WITHDRAW_FEE_PERCENT_MONTH = 0;

	uint constant public TIME_STEP = 1 days;
	uint constant public WEEK_TO_DAY = 7;
	uint constant public TIME_STEP_WEEK = TIME_STEP * WEEK_TO_DAY;

	uint constant public FORCE_BONUS_PERCENT = 5000;

	uint public initDate;

	uint public totalUsers;
	uint public totalInvested;
	uint public totalWithdrawn;
	uint public totalDeposits;
	uint public totalReinvested;


	uint public constant MAX_WITHDRAW_PER_USER = 160_000 ether;
	uint public constant MAX_WEEKLY_WITHDRAW_PER_USER = 40_000 ether;

	struct Deposit {
		uint amount;
		uint initAmount;
		uint withdrawn;
		uint start;
		bool isForceWithdraw;
	}

	struct MachineBonus {
		uint initAmount;
		uint withdrawn;
		uint start;
		uint level;
		uint bonus;
		uint lastPayBonus;
	}

	struct User {
		address userAddress;
		mapping (uint => Deposit) deposits;
		uint depositsLength;
		MachineBonus[MACHINEBONUS_LENGTH] machineDeposits;
		uint totalInvest;
		uint primeInvest;
		uint totalWithdraw;
		uint bonusWithdraw_c;
		uint reinvested;
		uint checkpoint;
		uint[MACHINEBONUS_LENGTH] referrerCount;
		uint totalBonus;
		address referrer;
		bool hasWithdraw_f;
		bool machineAllow;
	}

	mapping(address => User) public users;
	mapping (address => uint) public lastBlock;

	event Paused(address account);
	event Unpaused(address account);

	modifier onlyOwner() {
		require(devAddress == msg.sender, "Ownable: caller is not the owner");
		_;
	}

	modifier whenNotPaused() {
		require(initDate > 0, "Pausable: paused");
		_;
	}

	modifier whenPaused() {
		require(initDate == 0, "Pausable: not paused");
		_;
	}

	function unpause() external whenPaused onlyOwner{
		initDate = block.timestamp;
		emit Unpaused(msg.sender);
	}

	function isPaused() external view returns(bool) {
		return (initDate == 0);
	}

	function getMaxprofit(Deposit memory ndeposit) internal pure returns(uint) {
		// return (ndeposit.amount.mul(MAX_PROFIT)).div(PERCENTS_DIVIDER);
		return (ndeposit.amount * MAX_PROFIT) / PERCENTS_DIVIDER;
	}

	function getUserMaxProfit(address user) public view returns(uint) {
		// return users[user].primeInvest.mul(MAX_PROFIT).div(PERCENTS_DIVIDER);
		return (users[user].primeInvest * MAX_PROFIT) / PERCENTS_DIVIDER;
	}

	function getUserTotalInvested(address user) public view returns(uint) {
		return users[user].primeInvest;
	}

	function getDate() external view  returns(uint) {
		return block.timestamp;
	}

	function getMachineDeposit(address user, uint index) external view returns(uint _initAmount, uint _withdrawn, uint _start) {
		_initAmount = users[user].machineDeposits[index].initAmount;
		_withdrawn = users[user].machineDeposits[index].withdrawn;
		_start = users[user].machineDeposits[index].start;
	}

	function getTotalMachineBonus(address _user) external view returns(uint) {
		uint totalMachineBonus;
		for(uint i; i < MACHINEBONUS_LENGTH; i++) {
			totalMachineBonus += users[_user].machineDeposits[i].initAmount;
		}
		return totalMachineBonus;
	}

	function getAlldeposits(address _user) external view returns(Deposit[] memory) {
		Deposit[] memory _deposits = new Deposit[](users[_user].depositsLength);
		for(uint i; i < users[_user].depositsLength; i++) {
			_deposits[i] = users[_user].deposits[i];
		}
		return _deposits;
	}

	function totalMachineWithdraw(address _user) external view returns(uint) {
		uint _totalMachineWithdraw;
		for(uint i; i < MACHINEBONUS_LENGTH; i++) {
			_totalMachineWithdraw += users[_user].machineDeposits[i].withdrawn;
		}
		return _totalMachineWithdraw;
	}

    function getlastActionDate(User storage user)
        internal
        view
        returns (uint)
    {
        uint checkpoint = user.checkpoint;

        if (initDate > checkpoint) checkpoint = initDate;

        return checkpoint;
    }

	function getMaxTimeWithdraw(uint userTimeStamp) public view returns(uint) {
		// uint maxWithdraw = (MAX_WEEKLY_WITHDRAW_PER_USER * (block.timestamp.sub(userTimeStamp))) / (WEEK_TO_DAY * TIME_STEP);
		uint maxWithdraw = (MAX_WEEKLY_WITHDRAW_PER_USER * (block.timestamp - userTimeStamp)) / (WEEK_TO_DAY * TIME_STEP);
		if(maxWithdraw > MAX_WITHDRAW_PER_USER) {
			maxWithdraw = MAX_WITHDRAW_PER_USER;
		}
		return maxWithdraw;
	}

	function getMaxTimeWithdrawByUser(address user) external view returns(uint _maxWithdraw, uint _maxWeek, uint _delta, uint _weekTime, uint _timeStep) {
		// return (getMaxTimeWithdraw(getlastActionDate(users[user])), MAX_WEEKLY_WITHDRAW_PER_USER, block.timestamp.sub(getlastActionDate(users[user])), WEEK_TO_DAY, TIME_STEP);
		return (getMaxTimeWithdraw(getlastActionDate(users[user])), MAX_WEEKLY_WITHDRAW_PER_USER, block.timestamp - getlastActionDate(users[user]), WEEK_TO_DAY, TIME_STEP);
	}

}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;
import "./Billboost_status.sol";

contract Billboost is Billboost_status {
    // using SafeMath for uint;
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

    constructor(address _devAddr, address _token) {
        devAddress = _devAddr;
        token = IERC20(_token);

        emit Paused(msg.sender);
    }

    modifier isNotContract() {
        require(!isContract(msg.sender), "contract not allowed");
        _;
    }

    modifier checkUser_() {
        bool check = checkUser(msg.sender);
        require(check, "try again later");
        _;
    }

    function checkUser(address _user) public view returns (bool) {
        uint check = block.timestamp - getlastActionDate(users[_user]);
        if (check > TIME_STEP) return true;
        return false;
    }

    function useHasMaxWithDraw(address _user) public view returns (bool) {
        if(users[_user].totalWithdraw >= getUserMaxProfit(_user)) {
            return true;
        }
        return false;
    }

    modifier whenNotMaxWithDraw() {
        require(!useHasMaxWithDraw(msg.sender), "you have max withdraw");
        _;
    }

    modifier tenBlocks() {
        require(block.number - lastBlock[msg.sender] > 10, "wait 10 blocks");
        _;
    }
 
    function invest(address referrer, uint investAmt) external whenNotPaused nonReentrant isNotContract tenBlocks {
        // uint investAmt = msg.value;
        lastBlock[msg.sender] = block.number;
        token.transferFrom(msg.sender, address(this), investAmt);
        require(investAmt >= INVEST_MIN_AMOUNT, "insufficient deposit");

        User storage user = users[msg.sender];

        if (user.depositsLength == 0) {
            user.checkpoint = block.timestamp;
            user.userAddress = msg.sender;
            totalUsers++;
            if (
                user.referrer == address(0) &&
                users[referrer].depositsLength > 0 &&
                referrer != msg.sender &&
                users[referrer].referrer != msg.sender
            ) {
                user.referrer = referrer;
            }
            emit Newbie(msg.sender);
        }


        if (user.referrer != address(0)) {
            address upline = user.referrer;
            for (uint i; i < MACHINEBONUS_LENGTH; i++) {
                if (upline != address(0)) {
                    if (user.depositsLength == 0) {
                        users[upline].referrerCount[i] += 1;
                    }
                    // uint amount = (investAmt.mul(REFERRAL_PERCENTS[i])).div(PERCENTS_DIVIDER);
                    uint amount = (investAmt * REFERRAL_PERCENTS[i]) / PERCENTS_DIVIDER;
                    if (users[upline].machineDeposits[i].start == 0) {
                        users[upline].machineDeposits[i].start = block
                            .timestamp;
                        users[upline].machineDeposits[i].level = i + 1;
                    } else {
                        updateDeposit(upline, i);
                    }
                    users[upline].machineDeposits[i].initAmount += amount;
                    users[upline].totalBonus += amount;
                    emit RefBonus(upline, msg.sender, i, amount);
                    upline = users[upline].referrer;
                } else break;
            }
        }

        Deposit memory newDeposit;
        newDeposit.amount = investAmt;
        newDeposit.initAmount = investAmt;
        newDeposit.start = block.timestamp;
        user.deposits[user.depositsLength] = newDeposit;
        user.depositsLength++;
        user.totalInvest += investAmt;
        user.primeInvest += investAmt;
        user.machineAllow = true;

        totalInvested += investAmt;
        totalDeposits++;

        payInvestFee(investAmt);
        emit NewDeposit(msg.sender, investAmt);
    }

    function withdraw_f() external whenNotPaused checkUser_ whenNotMaxWithDraw nonReentrant isNotContract tenBlocks returns (bool) {
        lastBlock[msg.sender] = block.number;
        User storage user = users[msg.sender];

        uint totalAmount;

        for (uint i; i < user.depositsLength; i++) {
            uint dividends;
            Deposit memory deposit = user.deposits[i];

            if (
                deposit.withdrawn < getMaxprofit(deposit) &&
                deposit.isForceWithdraw == false
            ) {
                dividends = calculateDividents(deposit, user, totalAmount);

                if (dividends > 0) {
                    user.deposits[i].withdrawn += dividends; /// changing of storage data
                    totalAmount += dividends;
                }
            }
        }

        for (uint i; i < MACHINEBONUS_LENGTH; i++) {
            uint dividends;
            MachineBonus memory machineBonus = user.machineDeposits[i];
            if (
                machineBonus.withdrawn < machineBonus.initAmount &&
                user.machineAllow == true
            ) {
                dividends = calculateMachineDividents(
                    machineBonus,
                    user,
                    totalAmount
                );
                if (dividends > 0) {
                    // user.machineDeposits[i].withdrawn = machineBonus.withdrawn.add(dividends); /// changing of storage data
                    user.machineDeposits[i].withdrawn += dividends;
                    delete user.machineDeposits[i].bonus;
                    totalAmount += dividends;
                }
            }
        }

        require(totalAmount >= MIN_WITHDRAW, "User has no dividends");
        uint maxWithdraw = getMaxTimeWithdraw(getlastActionDate(user));
        if(maxWithdraw < MAX_WITHDRAW_PER_USER) {
            require(totalAmount <= maxWithdraw, "User balance exceeded");
        }

        // if(user.totalWithdraw.add(totalAmount) > MAX_WITHDRAW_PER_USER) {
        if(user.totalWithdraw + totalAmount > MAX_WITHDRAW_PER_USER) {
            // totalAmount = MAX_WITHDRAW_PER_USER.sub(user.totalWithdraw);
            totalAmount = MAX_WITHDRAW_PER_USER - user.totalWithdraw;
        }

        uint totalFee = withdrawFee(totalAmount, getlastActionDate(user));

        // uint toTransfer = totalAmount.sub(totalFee);
        uint toTransfer = totalAmount - totalFee;

        totalWithdrawn += totalAmount;

        user.checkpoint = block.timestamp;

        user.totalWithdraw += totalAmount;

        if (!user.hasWithdraw_f) {
            user.hasWithdraw_f = true;
        }

        transferHandler(msg.sender, toTransfer);

        emit FeePayed(msg.sender, totalFee);
        emit Withdrawn(msg.sender, totalAmount);
        return true;
    }

    function withdraw_C() external whenNotPaused checkUser_ whenNotMaxWithDraw nonReentrant isNotContract tenBlocks returns (bool) {
        lastBlock[msg.sender] = block.number;
        User storage user = users[msg.sender];
        require(!user.hasWithdraw_f, "User has withdraw_f");

        uint totalAmount;
        uint _bonus;

        for (uint i; i < user.depositsLength; i++) {
            uint dividends;
            Deposit memory deposit = user.deposits[i];

            if (
                deposit.withdrawn < getMaxprofit(deposit) &&
                deposit.isForceWithdraw == false
            ) {
                dividends = calculateDividents(deposit, user, totalAmount);
                _bonus += (deposit.initAmount * FORCE_BONUS_PERCENT) / PERCENTS_DIVIDER;
                if (dividends > 0) {
                    user.deposits[i].withdrawn += dividends; /// changing of storage data
                    totalAmount += dividends;
                }
                user.deposits[i].isForceWithdraw = true;
            }
        }

        for (uint i; i < MACHINEBONUS_LENGTH; i++) {
            uint dividends;
            MachineBonus memory machineBonus = user.machineDeposits[i];
            if (
                machineBonus.withdrawn < machineBonus.initAmount &&
                user.machineAllow == true
            ) {
                dividends = calculateMachineDividents(
                    machineBonus,
                    user,
                    totalAmount
                );
                if (dividends > 0) {
                    user.machineDeposits[i].withdrawn += dividends;
                    delete user.machineDeposits[i].bonus;
                    totalAmount += dividends;
                }
            }
        }
        uint _depositsWithdrawn = totalAmount;
        totalAmount += _bonus;
        require(totalAmount >= MIN_WITHDRAW, "User has no dividends");
        uint maxWithdraw = getMaxTimeWithdraw(getlastActionDate(user));
        if(maxWithdraw < MAX_WITHDRAW_PER_USER) {
            require(totalAmount <= maxWithdraw, "User balance exceeded");
        }

        if(user.totalWithdraw + totalAmount > MAX_WITHDRAW_PER_USER) {
            totalAmount = MAX_WITHDRAW_PER_USER - user.totalWithdraw;
        }

        user.machineAllow = false;

        uint totalFee = withdrawFee(totalAmount, getlastActionDate(user));

        uint toTransfer = totalAmount - totalFee;

        totalWithdrawn += totalAmount;

        user.checkpoint = block.timestamp;

        user.totalWithdraw += _depositsWithdrawn;
        user.bonusWithdraw_c += _bonus;

        transferHandler(msg.sender, toTransfer);

        emit FeePayed(msg.sender, totalFee);
        emit Withdrawn(msg.sender, totalAmount);
        return true;
    }

    function reinvestment() external whenNotPaused checkUser_ whenNotMaxWithDraw nonReentrant isNotContract tenBlocks returns (bool) {
        lastBlock[msg.sender] = block.number;
        User storage user = users[msg.sender];

        uint totalDividends;

        for (uint i; i < user.depositsLength; i++) {
            uint dividends;
            Deposit memory deposit = user.deposits[i];

            if (deposit.withdrawn < getMaxprofit(deposit)) {
                dividends = calculateDividents(deposit, user, totalDividends);

                if (dividends > 0) {
                    user.deposits[i].amount += dividends;
                    totalDividends += dividends;
                }
            }
        }

        for (uint i; i < MACHINEBONUS_LENGTH; i++) {
            MachineBonus memory machineBonus = user.machineDeposits[i];
            if (
                machineBonus.withdrawn < machineBonus.initAmount &&
                user.machineAllow == true
            ) {
                uint dividends = calculateMachineDividents(
                    machineBonus,
                    user,
                    totalDividends
                );
                if (dividends > 0) {
                    user.machineDeposits[i].initAmount += dividends;
                    delete user.machineDeposits[i].bonus;
                    totalDividends += dividends;
                }
            }
        }

        require(totalDividends > MINIMAL_REINVEST_AMOUNT, "User has no dividends");
        user.checkpoint = block.timestamp;

        user.reinvested += totalDividends;
        user.totalInvest += totalDividends;
        totalReinvested += totalDividends;

        if (user.referrer != address(0)) {
            address upline = user.referrer;
            for (uint i; i < MACHINEBONUS_LENGTH; i++) {
                if (upline != address(0)) {
                    if (user.depositsLength == 0) {
                        users[upline].referrerCount[i] += 1;
                    }
                    uint amount = (totalDividends * REFERRAL_PERCENTS[i]) / PERCENTS_DIVIDER;
                    if (users[upline].machineDeposits[i].start == 0) {
                        users[upline].machineDeposits[i].start = block
                            .timestamp;
                        users[upline].machineDeposits[i].level = i + 1;
                    } else {
                        updateDeposit(upline, i);
                    }
                    users[upline].machineDeposits[i].initAmount += amount;
                    users[upline].totalBonus += amount;
                    emit RefBonus(upline, msg.sender, i, amount);
                    upline = users[upline].referrer;
                } else break;
            }
        }

        emit Reinvestment(msg.sender, totalDividends);
        return true;
    }

    function getNextUserAssignment(address userAddress)
        public
        view
        returns (uint)
    {
        uint checkpoint = getlastActionDate(users[userAddress]);
        if (initDate > checkpoint) checkpoint = initDate;
        return checkpoint + TIME_STEP;
    }

    function getPublicData()
        external
        view
        returns (
            uint totalUsers_,
            uint totalInvested_,
            uint totalReinvested_,
            uint totalWithdrawn_,
            uint totalDeposits_,
            uint balance_,
            uint roiBase,
            uint maxProfit,
            uint minDeposit,
            uint daysFormdeploy
        )
    {
        totalUsers_ = totalUsers;
        totalInvested_ = totalInvested;
        totalReinvested_ = totalReinvested;
        totalWithdrawn_ = totalWithdrawn;
        totalDeposits_ = totalDeposits;
        balance_ = getContractBalance();
        roiBase = ROI_BASE;
        maxProfit = MAX_PROFIT;
        minDeposit = INVEST_MIN_AMOUNT;
        daysFormdeploy = (block.timestamp - initDate) / TIME_STEP;
    }

    function getUserData(address userAddress)
        external
        view
        returns (
            uint totalWithdrawn_,
            uint depositBalance,
            uint machineBalance,
            uint totalDeposits_,
            uint totalreinvest_,
            uint balance_,
            uint nextAssignment_,
            uint amountOfDeposits,
            uint checkpoint,
            uint maxWithdraw,
            address referrer_,
            uint[MACHINEBONUS_LENGTH] memory referrerCount_
        )
    {
        totalWithdrawn_ = users[userAddress].totalWithdraw + users[userAddress]
            .bonusWithdraw_c;
        totalDeposits_ = getUserTotalDeposits(userAddress);
        nextAssignment_ = getNextUserAssignment(userAddress);
        depositBalance = getUserDepositBalance(userAddress);
        machineBalance = getUserMachineBalance(userAddress);
        balance_ = getAvatibleDividens(userAddress);
        totalreinvest_ = users[userAddress].reinvested;
        amountOfDeposits = users[userAddress].depositsLength;
        checkpoint = getlastActionDate(users[userAddress]);
        referrer_ = users[userAddress].referrer;
        referrerCount_ = users[userAddress].referrerCount;
        maxWithdraw = getUserMaxProfit(userAddress);
    }

    function getContractBalance() public view returns (uint) {
        return token.balanceOf(address(this));
    }

    function getUserDepositBalance(address userAddress)
        internal
        view
        returns (uint)
    {
        User storage user = users[userAddress];

        uint totalDividends;

        for (uint i; i < user.depositsLength; i++) {
            Deposit memory deposit = users[userAddress].deposits[i];

            if (deposit.withdrawn < getMaxprofit(deposit)) {
                uint dividends = calculateDividents(deposit, user, totalDividends);
                totalDividends += dividends;
            }
        }

        return totalDividends;
    }

    function getUserMachineBalance(address userAddress) public view returns(uint) {
        User storage user = users[userAddress];
        uint fromDeposits = getUserDepositBalance(userAddress);
        uint totalDividends;
        for (uint i; i < MACHINEBONUS_LENGTH; i++) {
            MachineBonus memory machineBonus = user.machineDeposits[i];
            if (
                machineBonus.withdrawn < machineBonus.initAmount &&
                user.machineAllow == true
            ) {
                uint dividends = calculateMachineDividents(
                    machineBonus,
                    user,
                    fromDeposits + totalDividends
                );
                if (dividends > 0) {
                    totalDividends += dividends;
                }
            }
        }
        return totalDividends;
    }


    function getAvatibleDividens(address _user) internal view returns(uint) {
        return getUserDepositBalance(_user) + getUserMachineBalance(_user);
    }

    function calculateDividents(Deposit memory deposit, User storage user, uint _currentDividends)
        internal
        view
        returns (uint)
        {
        if(deposit.isForceWithdraw == true) {
            return 0;
        }
        uint dividends;
        uint depositPercentRate = getDepositRoi();

        uint checkDate = getDepsitStartDate(deposit);

        if (checkDate < getlastActionDate(user)) {
            checkDate = getlastActionDate(user);
        }

        dividends = (deposit.amount * depositPercentRate * (block.timestamp - checkDate)) / (PERCENTS_DIVIDER * TIME_STEP);

        uint _userMaxDividends = getUserMaxProfit(user.userAddress);
        if (
            user.totalWithdraw + dividends + _currentDividends >
            _userMaxDividends
        ) {
            if (user.totalWithdraw + _currentDividends < _userMaxDividends) {
                dividends =
                    _userMaxDividends -
                    user.totalWithdraw -
                    _currentDividends;
            } else {
                dividends = 0;
            }
        }

        if (deposit.withdrawn + dividends > getMaxprofit(deposit)) {
            dividends = getMaxprofit(deposit) - deposit.withdrawn;
        }

        return dividends;
    }

    function calculateMachineDividents(
        MachineBonus memory deposit,
        User storage user,
        uint _currentDividends
    ) internal view returns (uint) {
        if (!user.machineAllow) {
            return 0;
        }

        if (user.referrerCount[0] < deposit.level) {
            return 0;
        }

        uint dividends;

        uint checkDate = deposit.start;

        if (checkDate < getlastActionDate(user)) {
            checkDate = getlastActionDate(user);
        }

        if (checkDate < deposit.lastPayBonus) {
            checkDate = deposit.lastPayBonus;
        }

        dividends = (deposit.initAmount * MACHINE_ROI * (block.timestamp - checkDate)) / (PERCENTS_DIVIDER * TIME_STEP);

        dividends += deposit.bonus;

        uint _userMaxDividends = getUserMaxProfit(user.userAddress);
        if (
            user.totalWithdraw + dividends + _currentDividends >
            _userMaxDividends
        ) {
            if (user.totalWithdraw + _currentDividends < _userMaxDividends) {
                dividends =
                    _userMaxDividends -
                    user.totalWithdraw -
                    _currentDividends;
            } else {
                dividends = 0;
            }
        }

        if (deposit.withdrawn + dividends > deposit.initAmount) {
            dividends = deposit.initAmount - deposit.withdrawn;
        }

        return dividends;
    }

    function getUserDepositInfo(address userAddress, uint index)
        external
        view
        returns (
            uint amount_,
            uint withdrawn_,
            uint timeStart_,
            uint reinvested_,
            uint maxProfit
        )
    {
        Deposit memory deposit = users[userAddress].deposits[index];
        amount_ = deposit.amount;
        withdrawn_ = deposit.withdrawn;
        timeStart_ = getDepsitStartDate(deposit);
        reinvested_ = users[userAddress].reinvested;
        maxProfit = getMaxprofit(deposit);
    }

    function getUserTotalDeposits(address userAddress)
        internal
        view
        returns (uint)
    {
        return users[userAddress].totalInvest;
    }

    function getUserDeposittotalWithdrawn(address userAddress)
        internal
        view
        returns (uint)
    {
        User storage user = users[userAddress];

        uint amount;

        for (uint i; i < user.depositsLength; i++) {
            amount += users[userAddress].deposits[i].withdrawn;
        }
        return amount;
    }

    function isContract(address addr) internal view returns (bool) {
        uint size;
        assembly {
            size := extcodesize(addr)
        }
        return size > 0;
    }

    function getDepositRoi() private pure returns (uint) {
        return ROI_BASE;
    }

    function getDepsitStartDate(Deposit memory ndeposit)
        private
        view
        returns (uint)
    {
        if (initDate > ndeposit.start) {
            return initDate;
        } else {
            return ndeposit.start;
        }
    }

    function WITHDRAW_FEE_PERCENT(uint lastWithDraw)
        public
        view
        returns (uint)
    {
        if (initDate > lastWithDraw) {
            lastWithDraw = initDate;
        }
        uint delta = block.timestamp - lastWithDraw;
        if (delta < TIME_STEP * 7) {
            return WITHDRAW_FEE_PERCENT_DAY;
        } else if (delta < TIME_STEP * 15) {
            return WITHDRAW_FEE_PERCENT_WEEK;
        } else if (delta < TIME_STEP * 30) {
            return WITHDRAW_FEE_PERCENT_TWO_WEEK;
        }
        return WITHDRAW_FEE_PERCENT_MONTH;
    }

    function updateDeposit(address _user, uint _machineDeposit) internal {
        uint dividends = calculateMachineDividents(
            users[_user].machineDeposits[_machineDeposit],
            users[_user],
            0
        );
        if (dividends > 0) {
            users[_user].machineDeposits[_machineDeposit].bonus = dividends;
            users[_user].machineDeposits[_machineDeposit].lastPayBonus = block
                .timestamp;
        }
    }

    function withdrawFee(uint _totalAmount, uint checkExtraFee) internal returns(uint) {
        uint fee = WITHDRAW_FEE_BASE;
        if(checkExtraFee > 0) {
            fee += WITHDRAW_FEE_PERCENT(checkExtraFee);
        }
        uint feeAmout = (_totalAmount * fee) / PERCENTS_DIVIDER;
        uint feeToWAllet = feeAmout / 3;
        transferHandler(devAddress, feeToWAllet);
        transferHandler(ownerAddress, feeAmout - feeToWAllet);
        return feeAmout;
    }

    function payInvestFee(uint investAmount) internal {
        uint feeDev = (investAmount * DEV_FEE) / PERCENTS_DIVIDER;
        uint feeOwner = (investAmount * OWNER_FEE) / PERCENTS_DIVIDER;

        transferHandler(devAddress, feeDev);
        transferHandler(ownerAddress, feeOwner);
    }

    function transferHandler(address _address, uint _amount) internal {
        uint balance = token.balanceOf(address(this));
        if(balance < _amount) {
            _amount = balance;
        }
        token.transfer(_address, _amount);
    }

}
