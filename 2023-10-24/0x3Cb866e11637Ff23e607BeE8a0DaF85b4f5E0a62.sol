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

contract StakeBLB_BLB is Ownable, Pausable {
    using EnumerableSet for EnumerableSet.UintSet;

    IERC20 public BUSD;
    IERC20 public BLB;
    IBLBSwap public BLBSwap;

    uint256 public totalDepositBLB;
    uint256 public totalPendingBLB;

    mapping(address => Investment[]) public investments;

    Checkpoint checkpoint1;
    Checkpoint checkpoint2;
    Checkpoint checkpoint3;

    struct Investment {
        uint256 amount;
        uint256 start;
        uint256 end;
        uint256 profit;
        uint256 claimTime;
    }

    struct Checkpoint{
        uint256 passTime; //Percent
        uint256 saveDeposit; //Percent
        uint256 saveProfit; //Percent
    }
    
    event Deposit(
        address indexed userAddr, 
        uint256 indexed investmentId, 
        uint256 amountBLB, 
        uint256 amountUSD,
        string indexed depositToken
    );
    event Claim(
        address indexed userAddr, 
        uint256 indexed investmentId, 
        uint256 amountBLB
    );
    event Withdraw(
        address indexed userAddr, 
        uint256 indexed investmentId, 
        uint256 amountBLB
    );

    constructor(
        IERC20 _BUSD,
        IERC20 _BLB,
        address blbSwap,
        uint256[] memory durationsInDays,
        uint256[] memory profits 
    ) {
        BUSD = _BUSD;
        BLB = _BLB;
        BLBSwap = IBLBSwap(blbSwap);

        setPlans(durationsInDays, profits);
        setCheckpoints({
            passTime1 : 0 , saveDeposit1 : 80 , saveProfit1 : 0,
            passTime2 : 50, saveDeposit2 : 100, saveProfit2 : 0,
            passTime3 : 80, saveDeposit3 : 100, saveProfit3 : 40
        });
    }

    function BLBsForUSD(uint256 amountBUSD) public view returns(uint256){
        return BLBSwap.BLBsForUSD(amountBUSD);
    }

    function BLBsForBNB(uint256 amountBNB) external view returns(uint256){
        return BLBSwap.BLBsForBNB(amountBNB);
    }


    function releaseTime(
        address investor, 
        uint256 investmentId
    ) public view returns(uint256) {
        return investments[investor][investmentId].end;
    }

    function userInvestments(address investor) public view returns(Investment[] memory) {
        return investments[investor];
    }

    function userTotalStake(address investor) public view returns(uint256 totalStake) {
        Investment[] storage invests = investments[investor];
        uint256 len = invests.length;

        for(uint256 i; i < len; i++) {
            if(invests[i].claimTime == 0) {
                totalStake += invests[i].amount;
            }
        }
    }

    function pendingWithdrawal(
        address investor, 
        uint256 investmentId
    ) public view returns(uint256) {

        Investment storage investment = investments[investor][investmentId];

        uint256 amountDeposit; 
        uint256 amountProfit;
        uint256 currentTime = block.timestamp;
        uint256 start = investment.start;
        uint256 end = investment.end; 
        uint256 duration = investment.end - investment.start; 
        uint256 amount = investment.amount; 
        uint256 profit = investment.profit; 

        if(
            currentTime >= end
        ){
            amountDeposit = amount;
            amountProfit = profit;
        } else if(
            currentTime >= checkpoint3.passTime * duration /100 + start
        ){
            amountDeposit = amount * checkpoint3.saveDeposit / 100;
            amountProfit = profit * checkpoint3.saveProfit / 100;
        } else if(
            currentTime >= checkpoint2.passTime * duration /100 + start
        ){
            amountDeposit = amount * checkpoint2.saveDeposit / 100;
            amountProfit = profit * checkpoint2.saveProfit / 100;
        } else if(
            currentTime >= checkpoint1.passTime * duration /100 + start
        ){
            amountDeposit = amount * checkpoint1.saveDeposit / 100;
            amountProfit = profit * checkpoint1.saveProfit / 100;
        }
        return amountDeposit + amountProfit;
    }

    function pendingWithdrawal(
        address investor
    ) public view returns(uint256 total) {

        uint256 len = investments[investor].length;

        for(uint256 i; i < len; i++) {
            total += pendingWithdrawal(investor, i);
        }
    }

    function buyAndStake(uint256 amountBUSD, uint256 duration) public payable whenNotPaused {
        require(rewardPlans[duration] != 0, "there is no plan by this duration");

        address investor = msg.sender;
        uint256 amount;

        if(amountBUSD != 0) {
            require(msg.value == 0, "not allowed to buy in BUSD and BNB in same time");
            amount = BLBSwap.BLBsForUSD(amountBUSD);
            BUSD.transferFrom(investor, owner(), amountBUSD); 
        } else {
            amount = BLBSwap.BLBsForBNB(msg.value);
            payable(owner()).transfer(msg.value);
        }

        uint256 start = block.timestamp;
        uint256 end = block.timestamp + duration;
        uint256 profit = amount * rewardPlans[duration] / 10 ** 18;

        investments[investor].push(Investment(amount, start, end, profit, 0));

        totalDepositBLB += amount;
        totalPendingBLB += profit;
    }

    function newInvestment(uint256 amount, uint256 duration) public whenNotPaused {
        require(rewardPlans[duration] != 0, "there is no plan by this duration");

        address investor = msg.sender;
        uint256 start = block.timestamp;
        uint256 end = block.timestamp + duration;
        uint256 profit = amount * rewardPlans[duration] / 10 ** 18;

        BLB.transferFrom(investor, address(this), amount);

        investments[investor].push(Investment(amount, start, end, profit, 0));

        totalDepositBLB += amount;
        totalPendingBLB += profit;
    }

    function withdraw(uint256 investmentId) public {
        address payable investor = payable(msg.sender);

        Investment storage investment = investments[investor][investmentId];

        uint256 amount = pendingWithdrawal(investor, investmentId);

        require(amount > 0, "StakePool: nothing to withdraw");

        investment.claimTime = block.timestamp;

        require(
            BLB.balanceOf(address(this)) > amount, 
            "insufficient BLB balance in the contract"
        );
        BLB.transfer(investor, amount);

        totalDepositBLB -= investment.amount;
        totalPendingBLB -= investment.profit;
    }

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


// time plans -----------------------------------------------------------------------------------

    uint256[] _plans;
    mapping(uint256 => bool) planExists;
    mapping(uint256 => uint256) public rewardPlans;

    function plans() public view returns(uint256[] memory durations, uint256[] memory profits) {
        uint256 len = _plans.length;
        durations = new uint256[](len);
        profits = new uint256[](len);

        for(uint256 i = 0; i < len; i++) {
            durations[i] = _plans[i];
            profits[i] = rewardPlans[_plans[i]];
        }
    }

    function setPlans(
        uint256[] memory durationsInDays,
        uint256[] memory profits
    ) public onlyOwner {
        uint256 newLen = durationsInDays.length;
        require(
            newLen == profits.length,
            "lists must be the same length"
        );
        uint256 oldLen = _plans.length;
        for(uint256 i; i < oldLen; i++) {
            delete rewardPlans[_plans[i] * 1 days];
        }
        delete _plans;

        uint256 timing;
        for (uint256 i; i < newLen; i++) {
            timing = durationsInDays[i] * 1 days;
            _plans.push(timing);
            rewardPlans[timing] = profits[i];
        }
    }
}// SPDX-License-Identifier: MIT
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
