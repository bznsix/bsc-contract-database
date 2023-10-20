// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

interface IBLBSwap {
    function BLBsForUSD(uint256 amountBUSD) external view returns(uint256);
    function BLBsForBNB(uint256 amountBNB) external view returns(uint256);
}

contract FarmBLB is Ownable, Pausable {
    using EnumerableSet for EnumerableSet.UintSet;

    IERC20 public BUSD;
    IERC20 public BLB;
    IBLBSwap public BLBSwap;

    uint256 public totalDepositBLB;

    mapping(address => Investment[]) investments;
    mapping(address => mapping(uint256 => Payment[])) _investmentPayments;

    Checkpoint checkpoint1;
    Checkpoint checkpoint2;
    Checkpoint checkpoint3;

    struct InvestInfo {
        uint256 start;
        uint256 end;
        uint256 claimedMonth;
        uint256 claimedBLB;
        uint256 withdrawTime;
        uint256 amountBLB;
        uint256 amountUSD;
        uint256 monthId;
        uint256 monthlyProfitBLB;
        uint256 claimable;
    }

    struct Payment {
        uint256 amountBLB;
        uint256 amountUSD;
        uint256 monthId;
        uint256 monthlyProfitBLB;
    }

    struct Investment {
        uint256 start;
        uint256 end;
        uint256 claimedMonth;
        uint256 claimedBLB;
        uint256 withdrawTime;
    }

    struct Checkpoint{
        uint256 passTime; //Percent
        uint256 saveDeposit; //Percent
        uint256 saveProfit; //Percent
    }

    constructor(
        IERC20 _BUSD,
        IERC20 _BLB,
        address blbSwap,
        uint256[] memory _investPlanAmounts_,
        uint256[] memory _investPlanProfits_
    ) {
        BUSD = _BUSD;
        BLB = _BLB;
        BLBSwap = IBLBSwap(blbSwap);
        minStakeTime = 360 days;

        setCheckpoints({
            passTime1 : 0 , saveDeposit1 : 80 , saveProfit1 : 0,
            passTime2 : 50, saveDeposit2 : 100, saveProfit2 : 0,
            passTime3 : 80, saveDeposit3 : 100, saveProfit3 : 40
        });

        setInvestPlans(_investPlanAmounts_, _investPlanProfits_);
    }

    function BLBsForUSD(uint256 amountBUSD) public view returns(uint256){
        return BLBSwap.BLBsForUSD(amountBUSD);
    }

    function BLBsForBNB(uint256 amountBNB) external view returns(uint256){
        return BLBSwap.BLBsForBNB(amountBNB);
    }

    function userInvestments(address investor) public view returns(
        InvestInfo[] memory _investments_
    ) {
        Investment[] memory _invests = investments[investor];
        uint256 len = investments[investor].length;
        _investments_ = new InvestInfo[](len);
        Payment memory _payment;

        for (uint256 i; i < len; i++) {
            _payment = _investmentPayments[investor][i][_investmentPayments[investor][i].length - 1];
            _investments_[i] = InvestInfo(
                _invests[i].start,
                _invests[i].end,
                _invests[i].claimedMonth,
                _invests[i].claimedBLB,
                _invests[i].withdrawTime,
                _payment.amountBLB,
                _payment.amountUSD,
                _payment.monthId,
                _payment.monthlyProfitBLB,
                claimable(investor, i)
            );
        }
    }

    function investmentPayments(address investor, uint256 investmentId) public view returns(Payment[] memory _payments_) {
        return _investmentPayments[investor][investmentId];
    }

    function userTotalStake(address investor) public view returns(uint256 totalStake) {
        Investment[] storage invests = investments[investor];
        uint256 len = invests.length;

        for(uint256 i; i < len; i++) {
            if(invests[i].withdrawTime == 0) {
                totalStake += _investmentPayments[investor][i][_investmentPayments[investor][i].length - 1].amountBLB;
            }
        }
    }

    function userTotalStakeUSD(address investor) public view returns(uint256 totalStake) {
        Investment[] storage invests = investments[investor];
        uint256 len = invests.length;

        for(uint256 i; i < len; i++) {
            if(invests[i].withdrawTime == 0) {
                totalStake += _investmentPayments[investor][i][_investmentPayments[investor][i].length - 1].amountUSD;
            }
        }
    }

// investing in --------------------------------------------------------------------------------

    function buyAndStake(uint256 amountBUSD) public payable whenNotPaused {
        uint256 duration = minStakeTime;
        address investor = msg.sender;
        uint256 amountBLB;
        uint256 amountUSD;

        if(amountBUSD != 0) {
            require(msg.value == 0, "not allowed to buy in BUSD and BNB in same time");
            amountBLB = BLBSwap.BLBsForUSD(amountBUSD);
            amountUSD = amountBUSD;
            BUSD.transferFrom(investor, owner(), amountBUSD); 
        } else {
            amountBLB = BLBSwap.BLBsForBNB(msg.value);
            amountUSD = amountBLB * 10 ** 18 / BLBSwap.BLBsForUSD(10 ** 18);
            payable(owner()).transfer(msg.value);
        }

        uint256 start = block.timestamp;
        uint256 end = block.timestamp + duration;
        investments[investor].push(Investment(start, end, 0, 0, 0));
        _investmentPayments[investor][investments[investor].length - 1].push(Payment(amountBLB, amountUSD, 1, monthlyProfit(amountBLB, amountUSD)));

        totalDepositBLB += amountBLB;
    }

    function newInvestment(uint256 amountBLB) public whenNotPaused {
        uint256 duration = minStakeTime;

        address investor = msg.sender;
        uint256 start = block.timestamp;
        uint256 end = block.timestamp + duration;
        uint256 amountUSD = amountBLB * 10 ** 18 / BLBSwap.BLBsForUSD(10 ** 18);

        BLB.transferFrom(investor, address(this), amountBLB);


        investments[investor].push(Investment(start, end, 0, 0, 0));
        _investmentPayments[investor][investments[investor].length - 1].push(Payment(amountBLB, amountUSD, 1, monthlyProfit(amountBLB, amountUSD)));

        totalDepositBLB += amountBLB;
    }

    function topUpPayable(uint256 amountBUSD, uint256 investmentId) public payable whenNotPaused {

        uint256 addingAmount;
        uint256 addingAmountUSD;
        address investor = msg.sender;
        uint256 currentTime = block.timestamp;

        if(amountBUSD != 0) {
            require(msg.value == 0, "not allowed to topUp in BUSD and BNB in same time");
            addingAmount = BLBSwap.BLBsForUSD(amountBUSD);
            addingAmountUSD = amountBUSD;
            BUSD.transferFrom(investor, owner(), amountBUSD); 
        } else {
            addingAmount = BLBSwap.BLBsForBNB(msg.value);
            addingAmountUSD = addingAmount * 10 ** 18 / BLBSwap.BLBsForUSD(10 ** 18);
            payable(owner()).transfer(msg.value);
        }

        Investment memory investment = investments[investor][investmentId];
        Payment memory lastPayment = _investmentPayments[investor][investmentId][_investmentPayments[investor][investmentId].length - 1];

        require(investment.withdrawTime == 0, "investment ended");

        uint256 profitMonth = (currentTime - investment.start) / 30 days + 2;
        uint256 totalAmountBLB = lastPayment.amountBLB + addingAmount;
        uint256 totalAmountUSD = lastPayment.amountUSD + addingAmountUSD;
        _investmentPayments[investor][investmentId].push(Payment(
            totalAmountBLB, 
            totalAmountUSD, 
            profitMonth,
            monthlyProfit(totalAmountBLB, totalAmountUSD)
        ));

        totalDepositBLB += addingAmount;
    }

    function topUp(uint256 addingAmount, uint256 investmentId) public whenNotPaused {

        address investor = msg.sender;
        uint256 currentTime = block.timestamp;
        uint256 addingAmountUSD = addingAmount * 10 ** 18 / BLBSwap.BLBsForUSD(10 ** 18);

        Investment memory investment = investments[investor][investmentId];
        Payment memory lastPayment = _investmentPayments[investor][investmentId][_investmentPayments[investor][investmentId].length - 1];
        require(investment.withdrawTime == 0, "investment ended");

        BLB.transferFrom(investor, address(this), addingAmount);

        uint256 profitMonth = (currentTime - investment.start) / 30 days + 2;
        uint256 totalAmountBLB = lastPayment.amountBLB + addingAmount;
        uint256 totalAmountUSD = lastPayment.amountUSD + addingAmountUSD;
        _investmentPayments[investor][investmentId].push(Payment(
            totalAmountBLB, 
            totalAmountUSD, 
            profitMonth,
            monthlyProfit(totalAmountBLB, totalAmountUSD)
        ));

        totalDepositBLB += addingAmount;
    }


// claiming ------------------------------------------------------------------------------------

    function claimable(address investor, uint256 investmentId) public view returns(uint256 amountBLB) {
        require(investmentId < investments[investor].length, "invalid investmentId");
        
        Investment storage investment = investments[investor][investmentId];
        if(investment.withdrawTime != 0) {return 0;}
        uint256 currentTime = block.timestamp;
        uint256 pastMonths = (currentTime - investment.start) / 30 days;
        uint256 paidMonths = investment.claimedMonth;

        uint256 payPlanId = _investmentPayments[investor][investmentId].length - 1;
        for(uint256 i = pastMonths; i > paidMonths; i--) {
            while(_investmentPayments[investor][investmentId][payPlanId].monthId > i) {
                payPlanId --;
            }
            amountBLB += _investmentPayments[investor][investmentId][payPlanId].monthlyProfitBLB;
        }
    }

    function claimById(uint256 investmentId) public {
        address investor = msg.sender;
        uint256 amountBLB;

        require(investmentId < investments[investor].length, "invalid investmentId");
        
        Investment storage investment = investments[investor][investmentId];
        require(investment.withdrawTime == 0, "investment ended");
        
        uint256 currentTime = block.timestamp;
        uint256 pastMonths = (currentTime - investment.start) / 30 days;
        uint256 paidMonths = investment.claimedMonth;

        uint256 payPlanId = _investmentPayments[investor][investmentId].length - 1;
        for(uint256 i = pastMonths; i > paidMonths; i--) {
            while(_investmentPayments[investor][investmentId][payPlanId].monthId > i) {
                payPlanId --;
            }
            amountBLB += _investmentPayments[investor][investmentId][payPlanId].monthlyProfitBLB;
        }
        investment.claimedMonth = pastMonths;
        investment.claimedBLB += amountBLB;

        BLB.transfer(investor, amountBLB);
    }

// investing out --------------------------------------------------------------------------------

    function releaseTime(
        address investor, 
        uint256 investmentId
    ) public view returns(uint256) {
        return investments[investor][investmentId].end;
    }

    function pendingWithdrawalById(
        address investor, 
        uint256 investmentId
    ) public view returns(uint256) {

        Investment storage investment = investments[investor][investmentId];
        Payment[] memory payments = _investmentPayments[investor][investmentId];
        Payment memory lastPayment = payments[payments.length - 1];

        if(investment.withdrawTime != 0) {
            return 0;
        }

        uint256 currentTime = block.timestamp;
        uint256 start = investment.start;
        uint256 end = investment.end; 
        uint256 duration = investment.end - investment.start;
        uint256 monthRemaining = (duration / 30 days) - (currentTime - start) / 30 days - 1;
        uint256 totalDeposit = lastPayment.amountBLB; 
        uint256 totalClaimed = investment.claimedBLB;
        uint256 totalProfit = investment.claimedBLB + monthRemaining * lastPayment.monthlyProfitBLB;

        uint256 amountDeposit; 
        uint256 amountProfit; 

        if(
            currentTime >= end
        ){
            amountDeposit = totalDeposit;
            amountProfit = totalProfit;
        } else if(
            currentTime >= checkpoint3.passTime * duration /100 + start
        ){
            amountDeposit = totalDeposit * checkpoint3.saveDeposit / 100;
            amountProfit = totalProfit * checkpoint3.saveProfit / 100;
        } else if(
            currentTime >= checkpoint2.passTime * duration /100 + start
        ){
            amountDeposit = totalDeposit * checkpoint2.saveDeposit / 100;
            amountProfit = totalProfit * checkpoint2.saveProfit / 100;
        } else if(
            currentTime >= checkpoint1.passTime * duration /100 + start
        ){
            amountDeposit = totalDeposit * checkpoint1.saveDeposit / 100;
            amountProfit = totalProfit * checkpoint1.saveProfit / 100;
        }

        uint256 totalAmount = amountDeposit + amountProfit;

        return totalAmount > totalClaimed ? totalAmount - totalClaimed : 0;
    }

    function pendingWithdrawal(
        address investor
    ) public view returns(uint256 total) {

        uint256 len = investments[investor].length;

        for(uint256 i; i < len; i++) {
            total += pendingWithdrawalById(investor, i);
        }
    }

    function withdraw(uint256 investmentId) public {
        address investor = msg.sender;

        require(investmentId < investments[investor].length, "invalid investmentId");
        Investment storage investment = investments[investor][investmentId];

        claimById(investmentId);
        uint256 amount = pendingWithdrawalById(investor, investmentId);

        require(amount > 0, "StakePool: nothing to withdraw");

        investment.withdrawTime = block.timestamp;

        require(
            BLB.balanceOf(address(this)) > amount, 
            "insufficient BLB balance in the contract"
        );
        BLB.transfer(investor, amount);
    }

// profit plans ---------------------------------------------------------------------------------
    uint256[] _investPlanAmounts;
    uint256[] _investPlanProfits;

    function setInvestPlans(
        uint256[] memory _investPlanAmounts_,
        uint256[] memory _investPlanProfits_
    ) public onlyOwner {
        uint256 len = _investPlanAmounts_.length;
        require(len ==_investPlanProfits_.length, "arrays length must be same");
        for(uint256 i = 1; i < len; i++) {
            require(
                _investPlanAmounts_[i] > _investPlanAmounts_[i-1],
                "amounts must be increasing in a row"
            );
            require(
                _investPlanProfits_[i] >= _investPlanProfits_[i-1],
                "profits must be same or increasing in a row"
            );
        }
        _investPlanAmounts = _investPlanAmounts_;
        _investPlanProfits = _investPlanProfits_;
    }

    function plans() external view returns(
        uint256[] memory _investPlanAmounts_, 
        uint256[] memory _investPlanProfits_  
    ) {
        _investPlanAmounts_ = _investPlanAmounts;
        _investPlanProfits_ = _investPlanProfits;
    }


// profit calculator -------------------------------------------------------------------

    function monthlyProfit(uint256 amountBLB, uint256 amountUSD) public view returns(uint256 profitBLB) {
        uint256 len = _investPlanAmounts.length;
        for(uint256 i = len; i > 0; i--) {
            if(amountUSD >= _investPlanAmounts[i - 1]) {
                profitBLB = amountBLB * _investPlanProfits[i - 1]/10000;
                break;
            }
        }
        require(profitBLB != 0, "no plan for this amount");
    }

// minStakeTime -------------------------------------------------------------------------

    uint256 public minStakeTime;
    function setMinStakeTime(uint256 _minStakeTime) public onlyOwner {
        minStakeTime = _minStakeTime;
    }


// administration -----------------------------------------------------------------------
    

    function checkpoints() public view returns(
        Checkpoint memory checkpoint1_, 
        Checkpoint memory checkpoint2_, 
        Checkpoint memory checkpoint3_
    ){
        checkpoint1_ = checkpoint1;
        checkpoint2_ = checkpoint2;
        checkpoint3_ = checkpoint3;
    }

    function setCheckpoints(
        uint256 passTime1, uint256 saveDeposit1, uint256 saveProfit1,
        uint256 passTime2, uint256 saveDeposit2, uint256 saveProfit2,
        uint256 passTime3, uint256 saveDeposit3, uint256 saveProfit3
    ) public onlyOwner {
        require(
            passTime1 < passTime2 && passTime2 < passTime3, 
            "Pass Times must be increasing in a row"
        );
        require(
            saveDeposit1 <= saveDeposit2 && saveDeposit2 <= saveDeposit3, 
            "Pass Times must be same or increasing in a row"
        );
        require(
            saveProfit1 <= saveProfit2 && saveProfit2 <= saveProfit3, 
            "Pass Times must be same or increasing in a row"
        );
        checkpoint1 = Checkpoint(passTime1, saveDeposit1, saveProfit1);
        checkpoint2 = Checkpoint(passTime2, saveDeposit2, saveProfit2);
        checkpoint3 = Checkpoint(passTime3, saveDeposit3, saveProfit3);
    }

    function loanBLB(address borrower, uint256 amount) public onlyOwner {
        BLB.transfer(borrower, amount);
    }

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    function changeBLBSwap(address _BLBSwap) public onlyOwner {
        BLBSwap = IBLBSwap(_BLBSwap);
    }

    function pay(
        address user,
        uint256 amount
    ) external {
        BLB.transferFrom(msg.sender, user, amount);
    }

    function payBatch(
        address[] calldata users,
        uint256[] calldata amounts
    ) external {
        uint256 len = users.length;
        require(len == amounts.length, "Lists must be same in length");
        address from = msg.sender;
        for(uint256 i; i < len; i++) {
            BLB.transferFrom(from, users[i], amounts[i]);
        }
    }

    function payToOwner(uint256 amountBUSD) public payable {

        if(amountBUSD != 0) {
            require(msg.value == 0, "not allowed to buy in BUSD and BNB in same time");
            BUSD.transferFrom(msg.sender, owner(), amountBUSD); 
        } else {
            payable(owner()).transfer(msg.value);
        }
    }
}// SPDX-License-Identifier: MIT
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
// OpenZeppelin Contracts (last updated v4.7.0) (security/Pausable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
abstract contract Pausable is Context {
    /**
     * @dev Emitted when the pause is triggered by `account`.
     */
    event Paused(address account);

    /**
     * @dev Emitted when the pause is lifted by `account`.
     */
    event Unpaused(address account);

    bool private _paused;

    /**
     * @dev Initializes the contract in unpaused state.
     */
    constructor() {
        _paused = false;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        _requireNotPaused();
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    modifier whenPaused() {
        _requirePaused();
        _;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns (bool) {
        return _paused;
    }

    /**
     * @dev Throws if the contract is paused.
     */
    function _requireNotPaused() internal view virtual {
        require(!paused(), "Pausable: paused");
    }

    /**
     * @dev Throws if the contract is not paused.
     */
    function _requirePaused() internal view virtual {
        require(paused(), "Pausable: not paused");
    }

    /**
     * @dev Triggers stopped state.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    /**
     * @dev Returns to normal state.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (utils/structs/EnumerableSet.sol)

pragma solidity ^0.8.0;

/**
 * @dev Library for managing
 * https://en.wikipedia.org/wiki/Set_(abstract_data_type)[sets] of primitive
 * types.
 *
 * Sets have the following properties:
 *
 * - Elements are added, removed, and checked for existence in constant time
 * (O(1)).
 * - Elements are enumerated in O(n). No guarantees are made on the ordering.
 *
 * ```
 * contract Example {
 *     // Add the library methods
 *     using EnumerableSet for EnumerableSet.AddressSet;
 *
 *     // Declare a set state variable
 *     EnumerableSet.AddressSet private mySet;
 * }
 * ```
 *
 * As of v3.3.0, sets of type `bytes32` (`Bytes32Set`), `address` (`AddressSet`)
 * and `uint256` (`UintSet`) are supported.
 *
 * [WARNING]
 * ====
 *  Trying to delete such a structure from storage will likely result in data corruption, rendering the structure unusable.
 *  See https://github.com/ethereum/solidity/pull/11843[ethereum/solidity#11843] for more info.
 *
 *  In order to clean an EnumerableSet, you can either remove all elements one by one or create a fresh instance using an array of EnumerableSet.
 * ====
 */
library EnumerableSet {
    // To implement this library for multiple types with as little code
    // repetition as possible, we write it in terms of a generic Set type with
    // bytes32 values.
    // The Set implementation uses private functions, and user-facing
    // implementations (such as AddressSet) are just wrappers around the
    // underlying Set.
    // This means that we can only create new EnumerableSets for types that fit
    // in bytes32.

    struct Set {
        // Storage of set values
        bytes32[] _values;
        // Position of the value in the `values` array, plus 1 because index 0
        // means a value is not in the set.
        mapping(bytes32 => uint256) _indexes;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function _add(Set storage set, bytes32 value) private returns (bool) {
        if (!_contains(set, value)) {
            set._values.push(value);
            // The value is stored at length-1, but we add 1 to all indexes
            // and use 0 as a sentinel value
            set._indexes[value] = set._values.length;
            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function _remove(Set storage set, bytes32 value) private returns (bool) {
        // We read and store the value's index to prevent multiple reads from the same storage slot
        uint256 valueIndex = set._indexes[value];

        if (valueIndex != 0) {
            // Equivalent to contains(set, value)
            // To delete an element from the _values array in O(1), we swap the element to delete with the last one in
            // the array, and then remove the last element (sometimes called as 'swap and pop').
            // This modifies the order of the array, as noted in {at}.

            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;

            if (lastIndex != toDeleteIndex) {
                bytes32 lastValue = set._values[lastIndex];

                // Move the last value to the index where the value to delete is
                set._values[toDeleteIndex] = lastValue;
                // Update the index for the moved value
                set._indexes[lastValue] = valueIndex; // Replace lastValue's index to valueIndex
            }

            // Delete the slot where the moved value was stored
            set._values.pop();

            // Delete the index for the deleted slot
            delete set._indexes[value];

            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function _contains(Set storage set, bytes32 value) private view returns (bool) {
        return set._indexes[value] != 0;
    }

    /**
     * @dev Returns the number of values on the set. O(1).
     */
    function _length(Set storage set) private view returns (uint256) {
        return set._values.length;
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function _at(Set storage set, uint256 index) private view returns (bytes32) {
        return set._values[index];
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function _values(Set storage set) private view returns (bytes32[] memory) {
        return set._values;
    }

    // Bytes32Set

    struct Bytes32Set {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _add(set._inner, value);
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _remove(set._inner, value);
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(Bytes32Set storage set, bytes32 value) internal view returns (bool) {
        return _contains(set._inner, value);
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(Bytes32Set storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(Bytes32Set storage set, uint256 index) internal view returns (bytes32) {
        return _at(set._inner, index);
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(Bytes32Set storage set) internal view returns (bytes32[] memory) {
        return _values(set._inner);
    }

    // AddressSet

    struct AddressSet {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(AddressSet storage set, address value) internal returns (bool) {
        return _add(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(AddressSet storage set, address value) internal returns (bool) {
        return _remove(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(AddressSet storage set, address value) internal view returns (bool) {
        return _contains(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(AddressSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(AddressSet storage set, uint256 index) internal view returns (address) {
        return address(uint160(uint256(_at(set._inner, index))));
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(AddressSet storage set) internal view returns (address[] memory) {
        bytes32[] memory store = _values(set._inner);
        address[] memory result;

        /// @solidity memory-safe-assembly
        assembly {
            result := store
        }

        return result;
    }

    // UintSet

    struct UintSet {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(UintSet storage set, uint256 value) internal returns (bool) {
        return _add(set._inner, bytes32(value));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(UintSet storage set, uint256 value) internal returns (bool) {
        return _remove(set._inner, bytes32(value));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(UintSet storage set, uint256 value) internal view returns (bool) {
        return _contains(set._inner, bytes32(value));
    }

    /**
     * @dev Returns the number of values on the set. O(1).
     */
    function length(UintSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(UintSet storage set, uint256 index) internal view returns (uint256) {
        return uint256(_at(set._inner, index));
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(UintSet storage set) internal view returns (uint256[] memory) {
        bytes32[] memory store = _values(set._inner);
        uint256[] memory result;

        /// @solidity memory-safe-assembly
        assembly {
            result := store
        }

        return result;
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
