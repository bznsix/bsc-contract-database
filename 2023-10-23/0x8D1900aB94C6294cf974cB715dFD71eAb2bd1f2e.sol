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
// OpenZeppelin Contracts (last updated v4.9.0) (utils/structs/EnumerableSet.sol)
// This file was procedurally generated from scripts/generate/templates/EnumerableSet.js.

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
 * ```solidity
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
 * Trying to delete such a structure from storage will likely result in data corruption, rendering the structure
 * unusable.
 * See https://github.com/ethereum/solidity/pull/11843[ethereum/solidity#11843] for more info.
 *
 * In order to clean an EnumerableSet, you can either remove all elements one by one or create a fresh instance using an
 * array of EnumerableSet.
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
        bytes32[] memory store = _values(set._inner);
        bytes32[] memory result;

        /// @solidity memory-safe-assembly
        assembly {
            result := store
        }

        return result;
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
     * @dev Returns the number of values in the set. O(1).
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
pragma solidity >=0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./SafeMath.sol";

contract Reto is Ownable, Pausable, ReentrancyGuard {
    using EnumerableSet for EnumerableSet.AddressSet;
    using SafeMath for uint;
    IERC20 public TOKEN;
    uint private constant BEATS_TO_HATCH_1MINERS = 1080000; //for final version should be seconds in a day
    uint private constant PSN = 10000;
    uint private constant PSNH = 5000;
    uint public constant PERCENTS_DIVIDER = 10_000; // 100% = 10000, 10% = 1000, 1% = 100, 0.1% = 10, 0.01% = 1
    uint public constant MAX_WITHDRAW = 20000;
    // MUTIPLIER_BASE = 6000 = 60%
    uint public constant MUTIPLIER_BASE = 6000;
    uint internal constant DEV_DEF_FEE = 3_000;

    uint public constant REFERRER_PERCENTS_LENGTH = 1;
    uint internal constant REF_ARRAY_LENGTH = 4;
    uint[REFERRER_PERCENTS_LENGTH] public REFERRER_PERCENTS = [
        1000 //1 level
    ];
    uint public constant MIN_INVEST = 0.1 ether;

    uint public marketBeats;
    uint private players;
    uint public flatFee;
    uint public devFeeFlat;

    struct User {
        uint invest;
        uint withdraw;
        uint reinvest;
        uint hatcheryMiners;
        uint claimedBeats;
        uint lastHatch;
        uint checkpoint;
        address referrals;
        uint[REFERRER_PERCENTS_LENGTH] referrer;
        uint bonus;
        uint amountBNBReferrer;
        uint amountBEATSReferrer;
        uint totalRefDeposits;
        uint premiumBonus;
    }

    uint public initDate;

    mapping(address => User) public users;
    mapping(address => uint) public whiteList;

    struct UserWithdrawData {
        address user;
        uint amount;
        uint[REFERRER_PERCENTS_LENGTH] referrer;
    }

    mapping(address => UserWithdrawData) public userWithdrawData;
    mapping(uint => address) public userWithdrawDataIndex;
    uint public userWithdrawDataLength;

    uint public totalInvested;
    uint public constant TIME_STEP = 1 days;

    address public devWallet;
    address public mWallet;
    address public oWallet;
    address public sWallet;
    address public flatFeeWallet;
    address public defWAllet;
    address public whitelistReceiver;

    uint internal constant DEV_FEE = 100;
    uint internal constant MWALLET_FEE = 100;
    uint internal constant SWALLET_FEE = 100;
    uint internal constant OWALLET_FEE = 300;

    uint public constant FEE_REDUCTION_STEP = 15 * TIME_STEP;
    uint public whitelistPrice = 1_000 ether;

    struct FeeStruct {
        address wallet;
        uint amount;
    }

    EnumerableSet.AddressSet internal whiteListAdmin;

    event TotalWithdraw(address indexed user, uint amount);
    event WhiteListSet(address indexed user, bool indexed status);

    // constructor(address _dev, address _mWallet) Ownable(_dev) {
    constructor(address _dev, address _mWallet, address _whitelist, address _token) {
        TOKEN = IERC20(_token);
        devWallet = _dev;
        mWallet = _mWallet;
        whitelistReceiver = _whitelist;
        oWallet = 0xffa739da7eDFf167738FBB239DF4AD85C28E8a8B;
        sWallet = 0x3e046582E459E373D6b95fB9638c0478fE2C9F90;
        defWAllet = 0xA25a2D1d26c253a7Cc4F16328cAcD7e828E6F768;
        flatFeeWallet = 0x0fFe00e98fb513F51E01Bf62BFbE900A4fDc641D;
        marketBeats = 108000000000;
        flatFee = 0.0047 ether;
        devFeeFlat = 5_000;
        whiteListAdmin.add(devWallet);
        whiteListAdmin.add(mWallet);
        whiteListAdmin.add(oWallet);
        whiteListAdmin.add(defWAllet);
        whiteListAdmin.add(sWallet);
        _pause();
        //  _unpause();
        // initDate = block.timestamp;
    }

    function setWhitelistAdmin(
        address[] memory adr,
        bool _add
    ) external onlyOwner {
        if (_add) {
            for (uint256 i = 0; i < adr.length; i++) {
                whiteListAdmin.add(adr[i]);
            }
        } else {
            for (uint256 i = 0; i < adr.length; i++) {
                whiteListAdmin.remove(adr[i]);
            }
        }
    }

    function isWhitelistAdmin(address account) public view returns (bool) {
        return whiteListAdmin.contains(account);
    }

    function getWhitelistAdminis() external view returns (address[] memory) {
        return whiteListAdmin.values();
    }

    modifier onlyWhitelistAdmin() {
        require(
            isWhitelistAdmin(msg.sender),
            "WhitelistAdminRole: caller does not have the WhitelistAdmin role"
        );
        _;
    }

    function addToWhiteList(address adr) external onlyWhitelistAdmin {
        addWhiteList(adr);
    }

    function setWhitelistPrice(uint _price) external onlyWhitelistAdmin {
        whitelistPrice = _price;
    }

    function buyWhitelist() external payable nonReentrant whenNotPaused {
        TOKEN.transferFrom(msg.sender, whitelistReceiver, whitelistPrice);
        addWhiteList(msg.sender);
    }

    function setWhitelist(
        address[] memory _whitelist,
        bool _value
    ) external onlyWhitelistAdmin {
        uint time;

        if(_value) {
            time = block.timestamp;
        }

        for (uint256 i = 0; i < _whitelist.length; i++) {
            whiteList[_whitelist[i]] = time;
            emit WhiteListSet(_whitelist[i], _value);
        }
    }

    function addWhiteList(address adr) private {
        whiteList[adr] = block.timestamp;
        emit WhiteListSet(adr, true);
    }

    function removeToWhiteList(address adr) external onlyWhitelistAdmin {
        delete whiteList[adr];
        emit WhiteListSet(adr, false);
    }

    function unpause() external onlyOwner {
        _unpause();
        initDate = block.timestamp;
    }

    function secondsFromInit() public view returns (uint) {
        if (initDate == 0) {
            return 0;
        }
        return block.timestamp.sub(initDate);
    }

    function daysFromInit() external view returns (uint) {
        return secondsFromInit().div(TIME_STEP);
    }

    modifier checkUser_() {
        require(checkUser(msg.sender), "try again later 1");
        _;
    }

    modifier enoughFee() {
        require(msg.value >= flatFee, "Flat fee");
        _;
    }

    function checkUser(address _user) public view returns (bool) {
        uint check = block.timestamp.sub(users[_user].checkpoint);
        if (check > TIME_STEP) {
            return true;
        }
        return false;
    }

    function getDateForSelling(address adr) external view returns (uint) {
        return SafeMath.add(users[adr].checkpoint, TIME_STEP);
    }

    function reInvest() external payable checkUser_ nonReentrant whenNotPaused {
        calculateReinvest(true);
    }

    function hatchBeats(uint beatsUsed, User storage user) private {
        uint newMiners = SafeMath.div(beatsUsed, BEATS_TO_HATCH_1MINERS);
        user.hatcheryMiners = SafeMath.add(user.hatcheryMiners, newMiners);
        delete user.claimedBeats;
        user.lastHatch = block.timestamp;
        user.checkpoint = block.timestamp;
        //boost market to nerf miners hoarding
        marketBeats = SafeMath.add(marketBeats, SafeMath.div(beatsUsed, 5));
    }

    function calculateMyBeats(
        address adr,
        bool isReinvest
    ) public view returns (uint hasBeats, uint beatValue, uint beats) {
        uint beats_ = getMyBeats(adr);
        uint hasBeats_ = beats_; // beats for reinvest
        uint beatValue_; // beat value for withdraw
        (uint multiplier, uint divider) = getMyBonus(isReinvest);
        beatValue_ = calculateBeatSell(
            SafeMath.div(SafeMath.mul(hasBeats_, multiplier), divider)
        );
        hasBeats_ -= SafeMath.div(SafeMath.mul(hasBeats_, multiplier), divider);
        uint remain = getUserRemainProfit(adr);
        if (remain == 0) {
            beatValue_ = 0;
        } else if (remain < beatValue_) {
            beatValue_ = remain;
        }

        hasBeats = hasBeats_;
        beatValue = beatValue_;
        beats = calculateBeatSell(beats_); // beats total value
    }

    function sell() external payable checkUser_ nonReentrant whenNotPaused {
        _payFee();
        (uint hasBeats, uint beatValue, ) = calculateMyBeats(msg.sender, false);

        require(beatValue > 0, "No beats to sell");
        (uint fee, FeeStruct[REF_ARRAY_LENGTH] memory feeStruct) = withdrawFee(
            beatValue
        );
        require(SafeMath.sub(beatValue, fee) > 0, "Amount don't allowed");

        User storage user = users[msg.sender];
        // uint beatsUsed = hasBeats;
        uint newMiners = SafeMath.div(hasBeats, BEATS_TO_HATCH_1MINERS);
        user.hatcheryMiners = SafeMath.add(user.hatcheryMiners, newMiners);
        delete user.claimedBeats;
        user.lastHatch = block.timestamp;
        user.checkpoint = block.timestamp;

        marketBeats = SafeMath.add(marketBeats, hasBeats);
        user.withdraw += beatValue;
        uint userWithdraw = beatValue;
        if (userWithdrawData[msg.sender].user == address(0)) {
            userWithdrawDataIndex[userWithdrawDataLength] = msg.sender;
            userWithdrawDataLength += 1;
            userWithdrawData[msg.sender].user = msg.sender;
        }
        userWithdrawData[msg.sender].amount += userWithdraw;
        userWithdrawData[msg.sender].referrer = user.referrer;
        payFees(feeStruct);
        // payable(msg.sender).transfer(SafeMath.sub(beatValue, fee));
        if (getUserRemainProfit(msg.sender) == 0) {
            delete users[msg.sender].claimedBeats;
            delete users[msg.sender].hatcheryMiners;
        }
        transferHandler(payable(msg.sender), SafeMath.sub(beatValue, fee));
        emit TotalWithdraw(msg.sender, user.withdraw);
    }

    function calculateReinvest(bool _withFee) private {
        (uint hasBeats, uint beatValue, ) = calculateMyBeats(msg.sender, true);
        // (uint fee, ) = withdrawFee(beatValue);
        require(beatValue > 0, "Amount don't allowed");
        User storage user = users[msg.sender];
        uint newMiners = SafeMath.div(hasBeats, BEATS_TO_HATCH_1MINERS);
        user.hatcheryMiners = SafeMath.add(user.hatcheryMiners, newMiners);
        delete user.claimedBeats;
        user.lastHatch = block.timestamp;
        user.checkpoint = block.timestamp;

        marketBeats = SafeMath.add(marketBeats, hasBeats);
        user.reinvest += beatValue;
        // payFees(feeStruct);
        // payable(msg.sender).transfer(SafeMath.sub(beatValue, fee));
        // transferHandler(payable(msg.sender), SafeMath.sub(beatValue, fee));
        buyHandler(users[msg.sender].referrals, beatValue, _withFee);
    }

    function beatsRewards(address adr) external view returns (uint) {
        uint hasBeats = getMyBeats(adr);
        uint beatValue = calculateBeatSell(hasBeats);
        return beatValue;
    }

    function referrerCommission(
        uint _amount,
        uint level
    ) private view returns (uint) {
        //return SafeMath.div(SafeMath.mul(_amount, referrerCommissionVal), 100);
        return
            SafeMath.div(
                SafeMath.mul(_amount, REFERRER_PERCENTS[level]),
                PERCENTS_DIVIDER
            );
    }

    function buy(
        address ref,
        uint _amount
    ) external payable nonReentrant whenNotPaused {
        // uint _amount = msg.value;
        require(_amount >= MIN_INVEST, "Min amount");
        TOKEN.transferFrom(msg.sender, address(this), _amount);

        _payFee();
        // _amount = _amount.sub(flatFee);

        buyHandler(ref, _amount, true);
    }

    function buyHandler(address ref, uint investAmout, bool payFee) private {
        User storage user = users[msg.sender];
        if (user.referrals == address(0) && msg.sender != defWAllet) {
            if (
                ref == msg.sender ||
                users[ref].referrals == msg.sender ||
                msg.sender == users[ref].referrals
            ) {
                user.referrals = defWAllet;
            } else {
                user.referrals = ref;
            }
            if (user.referrals != msg.sender && user.referrals != address(0)) {
                address upline = user.referrals;
                address old = msg.sender;
                for (uint i = 0; i < REFERRER_PERCENTS_LENGTH; i++) {
                    if (
                        upline != address(0) &&
                        upline != old &&
                        users[upline].referrals != old
                    ) {
                        users[upline].referrer[i] += 1;
                        old = upline;
                        upline = users[upline].referrals;
                    } else break;
                }
            }
        }

        uint beatsBought = calculateBeatBuy(
            investAmout,
            SafeMath.sub(getBalance(), investAmout)
        );

        (uint beatsFee, ) = devFee(beatsBought);
        beatsBought = SafeMath.sub(beatsBought, beatsFee);
        if (payFee) {
            (, FeeStruct[REF_ARRAY_LENGTH] memory feeStruct) = devFee(
                investAmout
            );
            payFees(feeStruct);
        }

        if (user.invest == 0) {
            user.checkpoint = block.timestamp;
            players = SafeMath.add(players, 1);
        }
        user.invest += investAmout;
        user.claimedBeats = SafeMath.add(user.claimedBeats, beatsBought);
        hatchBeats(getMyBeats(msg.sender), user);
        payCommision(user, investAmout);
        totalInvested += investAmout;
    }

    function payCommision(User storage user, uint investAmout) private {
        if (user.referrals != msg.sender && user.referrals != address(0)) {
            address upline = user.referrals;
            address old = msg.sender;
            if (upline == address(0)) {
                upline = defWAllet;
            }
            for (uint i = 0; i < REFERRER_PERCENTS_LENGTH; i++) {
                if (
                    (upline != address(0) &&
                        upline != old &&
                        users[upline].referrals != old) || upline == defWAllet
                ) {
                    uint amountReferrer = referrerCommission(investAmout, i);
                    users[upline].amountBNBReferrer = SafeMath.add(
                        users[upline].amountBNBReferrer,
                        amountReferrer
                    );

                    users[upline].totalRefDeposits = SafeMath.add(
                        users[upline].totalRefDeposits,
                        investAmout
                    );
                    // payable(upline).transfer(amountReferrer);
                    // transferHandler(payable(upline), amountReferrer);
                    users[upline].bonus = users[upline].bonus.add(amountReferrer);

                    upline = users[upline].referrals;
                    old = user.referrals;
                    if (upline == address(0)) {
                        upline = defWAllet;
                    }
                } else break;
            }
        }
    }

    function calculateTrade(
        uint rt,
        uint rs,
        uint bs
    ) private pure returns (uint) {
        uint a = PSN.mul(bs);
        uint b = PSNH;

        uint c = PSN.mul(rs);
        uint d = PSNH.mul(rt);

        uint h = c.add(d).div(rt);
        return a.div(b.add(h));
    }

    function calculateBeatSell(uint beats) private view returns (uint) {
        uint _cal = calculateTrade(beats, marketBeats, getBalance());
        return _cal;
    }

    function calculateBeatBuy(
        uint eth,
        uint contractBalance
    ) public view returns (uint) {
        return calculateTrade(eth, contractBalance, marketBeats);
    }

    function calculateBeatBuySimple(uint eth) external view returns (uint) {
        return calculateBeatBuy(eth, getBalance());
    }

    function devFee(
        uint _amount
    )
        private
        view
        returns (uint _totalFee, FeeStruct[REF_ARRAY_LENGTH] memory _feeStruct)
    {
        uint dFee = SafeMath.div(
            SafeMath.mul(_amount, DEV_FEE),
            PERCENTS_DIVIDER
        );
        uint mFee = SafeMath.div(
            SafeMath.mul(_amount, MWALLET_FEE),
            PERCENTS_DIVIDER
        );
        uint oFee = SafeMath.div(
            SafeMath.mul(_amount, OWALLET_FEE),
            PERCENTS_DIVIDER
        );
        uint sFee = SafeMath.div(
            SafeMath.mul(_amount, SWALLET_FEE),
            PERCENTS_DIVIDER
        );

        _feeStruct[0] = FeeStruct(devWallet, dFee);
        _feeStruct[1] = FeeStruct(mWallet, mFee);
        _feeStruct[2] = FeeStruct(oWallet, oFee);
        _feeStruct[3] = FeeStruct(sWallet, sFee);

        _totalFee = SafeMath.add(dFee, mFee);
        _totalFee = SafeMath.add(_totalFee, oFee);
        _totalFee = SafeMath.add(_totalFee, sFee);

        return (_totalFee, _feeStruct);
    }

    function withdrawFee(
        uint _amount
    )
        private
        view
        returns (uint _totalFee, FeeStruct[REF_ARRAY_LENGTH] memory _feeStruct)
    {
        return devFee(_amount);
    }

    function getBalance() public view returns (uint) {
        return TOKEN.balanceOf(address(this));
        // return address(this).balance;
    }

    function getMyMiners(address adr) external view returns (uint) {
        User memory user = users[adr];
        return user.hatcheryMiners;
    }

    function getPlayers() external view returns (uint) {
        return players;
    }

    function getMyBeats(address adr) public view returns (uint) {
        User memory user = users[adr];
        return SafeMath.add(user.claimedBeats, getBeatsSinceLastHatch(adr));
    }

    function getBeatsSinceLastHatch(address adr) public view returns (uint) {
        User memory user = users[adr];
        uint secondsPassed = min(
            BEATS_TO_HATCH_1MINERS,
            SafeMath.sub(block.timestamp, user.lastHatch)
        );
        return SafeMath.mul(secondsPassed, user.hatcheryMiners);
    }

    function min(uint a, uint b) private pure returns (uint) {
        return a < b ? a : b;
    }

    function getSellStars(
        address user_
    ) external view returns (uint beatValue) {
        uint hasBeats = getMyBeats(user_);
        beatValue = calculateBeatSell(hasBeats);
    }

    function getPublicData()
        external
        view
        returns (uint _totalInvest, uint _balance)
    {
        _totalInvest = totalInvested;
        _balance = getBalance();
    }

    function userData(
        address user_
    )
        external
        view
        returns (
            uint lastHatch_,
            uint rewards_,
            uint amountAvailableReinvest_,
            uint availableWithdraw_,
            uint beatsMiners_,
            address referrals_,
            uint[REFERRER_PERCENTS_LENGTH] memory referrer,
            uint checkpoint,
            uint referrerBNB,
            uint referrerBEATS,
            uint totalRefDeposits
            // uint bonus
        )
    {
        User memory user = users[user_];
        (, uint beatValue, uint beats) = calculateMyBeats(user_, false);
        (, amountAvailableReinvest_, ) = calculateMyBeats(user_, true);
        // amountAvailableReinvest_ = beatValue;
        lastHatch_ = user.lastHatch;
        referrals_ = user.referrals;
        rewards_ = beats;
        // amountAvailableReinvest_ = beatValue; // SafeMath.sub(beats, beatValue);
        availableWithdraw_ = beatValue;
        beatsMiners_ = getBeatsSinceLastHatch(user_);
        referrer = user.referrer;
        checkpoint = user.checkpoint;
        referrerBNB = user.amountBNBReferrer;
        referrerBEATS = user.amountBEATSReferrer;
        totalRefDeposits = user.totalRefDeposits;
        
    }

    function payFees(FeeStruct[REF_ARRAY_LENGTH] memory _fees) internal {
        for (uint i = 0; i < _fees.length; i++) {
            if (_fees[i].amount > 0) {
                // payable(_fees[i].wallet).transfer(_fees[i].amount);
                transferHandler(payable(_fees[i].wallet), _fees[i].amount);
            }
        }
    }

    function getDate() external view returns (uint) {
        return block.timestamp;
    }

    function getMyBonus(
        bool isReinvest
    ) public view returns (uint multiplier, uint divider) {
        divider = PERCENTS_DIVIDER;
        multiplier = MUTIPLIER_BASE;

        if (secondsFromInit() >= FEE_REDUCTION_STEP) {
            multiplier = divider;
        }

        if (multiplier > divider || isReinvest) {
            multiplier = divider;
        }
    }

    function transferHandler(address adr, uint amount) private {
        if (amount > getBalance()) {
            amount = getBalance();
        }
        uint _toDev = 0;
        if (adr == defWAllet) {
            _toDev = amount.mul(DEV_DEF_FEE).div(PERCENTS_DIVIDER);
            amount = amount.sub(_toDev);
        }
        TOKEN.transfer(adr, amount);
        // payable(adr).transfer(amount);
        if (_toDev > 0) {
            TOKEN.transfer(devWallet, _toDev);
            // payable(devWallet).transfer(_toDev);
        }
    }

    function getUserWithdrawData()
        external
        view
        returns (UserWithdrawData[] memory)
    {
        UserWithdrawData[] memory result = new UserWithdrawData[](
            userWithdrawDataLength
        );
        for (uint i = 0; i < userWithdrawDataLength; i++) {
            result[i] = userWithdrawData[userWithdrawDataIndex[i]];
        }
        return result;
    }

    function UserWithdrawDataRange(
        uint limit,
        uint offset
    ) external view returns (UserWithdrawData[] memory) {
        UserWithdrawData[] memory result = new UserWithdrawData[](limit);
        for (uint i = 0; i < limit; i++) {
            result[i] = userWithdrawData[userWithdrawDataIndex[i + offset]];
        }
        return result;
    }

    function getInvestSumReinvest(address adr) public view returns (uint) {
        return users[adr].withdraw + users[adr].reinvest;
    }

    function getUserRemainProfit(address _user) public view returns (uint) {
        User memory user = users[_user];
        uint userWithdraw = user.withdraw;
        uint userInvest = user.invest;
        uint maxWithdraw = userInvest.mul(MAX_WITHDRAW).div(PERCENTS_DIVIDER);
        if (userWithdraw >= maxWithdraw) {
            return 0;
        }
        return maxWithdraw.sub(userWithdraw);
    }

    function setFeeReceiver(address _feeReceiver) external onlyOwner {
        oWallet = _feeReceiver;
    }

    function setDevFeeReceiver(address _devFeeReceiver) external onlyOwner {
        devWallet = _devFeeReceiver;
    }

    function setDevFee(uint256 _newDevFee) external onlyOwner {
        devFeeFlat = _newDevFee;
    }

    function setFlatFee(uint256 _flatFee) external onlyOwner {
        flatFee = _flatFee;
    }
    
    function payBonus() payable checkUser_  nonReentrant whenNotPaused  external {
        User storage user = users[msg.sender];
        uint amount = user.bonus;
        uint _totalFee;
        FeeStruct[REF_ARRAY_LENGTH] memory feeStruct;
        _payFee();
        delete user.bonus;
        user.checkpoint = block.timestamp;
          (_totalFee,feeStruct) = devFee(amount);
            payFees(feeStruct);
            amount = amount.sub(_totalFee);
        // user.premiumBonus = user.premiumBonus.add(amount);
        // payable(msg.sender).transfer(amount);
        transferHandler(payable(msg.sender), amount);

    }
    function _payFee() internal enoughFee {
        if (flatFee > 0) {
            // uint256 devFeeAmount = (flatFee * devFeeFlat) / PERCENTS_DIVIDER;
            // uint256 devFeeAmount = (msg.value * devFeeFlat) / PERCENTS_DIVIDER;
            // // uint256 feeAmount = flatFee - devFeeAmount;
            // uint256 feeAmount = msg.value - devFeeAmount;
            uint feeAmount = flatFee.div(3);
            payable(flatFeeWallet).transfer(feeAmount);
            payable(mWallet).transfer(feeAmount);
            payable(devWallet).transfer(address(this).balance);
        }
    }

}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;


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