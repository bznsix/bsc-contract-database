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
pragma solidity >=0.8.11;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

contract Stake is Ownable {
    using EnumerableSet for EnumerableSet.AddressSet;

    EnumerableSet.AddressSet private _stakers;
    mapping(address => bool) private _isStaker;

    IERC20 public immutable TOKEN;
    address public launchPadContract;
    uint256 public immutable lockPeriod;

    uint256 public constant TIERS1AMOUNT = 10_000_000 * 1E18; 
    uint256 public constant TIERS2AMOUNT = 50_000_000 * 1E18;
    uint256 public constant TIERS3AMOUNT = 200_000_000 * 1E18;
    uint256 public constant TIERS4AMOUNT = 1_000_000_000 * 1E18;
    uint256 public constant TIERS5AMOUNT = 10_000_000_000 * 1E18;

    uint256 private _snapShotNumber;

    uint256[6] private _tiersStaked;

    struct UserData {
        uint256 staked;
        uint256 unlockDate;
        uint256 tiers;
    }

    mapping(address => uint256[]) private _userSnapshots;
    mapping(address => mapping(uint256 => UserData)) private _userDatas;

    event Staked(address indexed user, uint256 amount);
    event Unstaked(address indexed user, uint256 amount);
    event LaunchpadSet(address launchpadAddress);

    constructor(IERC20 _token, uint256 _lockPeriod) {
        TOKEN = _token;
        lockPeriod = _lockPeriod;
    }

    function setLaunchpadContract(address _launchPad) external onlyOwner {
        launchPadContract = _launchPad;
        emit LaunchpadSet(_launchPad);
    }

    function getStakerNumber() external view returns(uint256){
        return _stakers.length();
    }

    function getStakerAtIndex(uint256 index) external view returns(address){
        return _stakers.at(index);
    }

    function getTiersStaked() external view returns(uint256[6] memory){
        return _tiersStaked;
    }

    function getUserData(
        address _user
    ) external view returns (UserData memory) {
        uint256[] memory _snaps = _userSnapshots[_user];
        if(_snaps.length == 0){
            return UserData(0,0,0);
        }else{
            return _getUserData(_user, _snaps[_snaps.length-1]);
        }
    }

    function canUserUnstake(address _user) external view returns(bool){
        uint256[] memory _snaps = _userSnapshots[_user];
        if(_snaps.length != 0){
            return block.timestamp >= _userDatas[_user][_snaps[_snaps.length-1]].unlockDate;
        }else {
            return false;
        }
    }

    function getInvestorsDatas(
        address _user,
        uint256 _snapNb
    ) external view returns (uint256 tiersNb, uint256 amountStaked) {
        UserData memory u;
        uint256[] memory _snaps = _userSnapshots[_user];
        
        if(_snaps.length == 0){
            return (0,0);
        }else if (_snapNb >= _snaps[_snaps.length-1]) {
            u = _userDatas[_user][_snaps[_snaps.length-1]];
            tiersNb = u.tiers;
            amountStaked = u.staked;
        } else {
            if(_snaps.length >= 2){
            for(uint256 i = _snaps.length - 2; i > 0  ; ){
                    if(_snapNb >= _snaps[i]){
                        u = _userDatas[_user][_snaps[i]];
                        tiersNb = u.tiers;
                        amountStaked = u.staked;
                        break;
                    }
                    unchecked {
                        -- i;
                    }
                }
            }else{
                return (0,0);
            }
        }
    }

    function _getUserData(
        address _user,
        uint256 _snapNb
    ) internal view returns (UserData memory) {
        return _userDatas[_user][_snapNb];
    }

    function getUserStakedAmount(
        address _user
    ) external view returns (uint256) {
        return _userDatas[_user][_userSnapshots[_user][_userSnapshots[_user].length-1]].staked;
    }

    function snapShotPool()
        external
        returns (
            uint256[6] memory tiersStaked,
            uint256 snapShotNb
        )
    {
        require(msg.sender == launchPadContract, "Not auth to snapshot");
        ++_snapShotNumber;

        snapShotNb = _snapShotNumber;
        tiersStaked = _tiersStaked;

    }

    function stake(uint256 _amount) external {
        address _sender = _msgSender();
        require(TOKEN.transferFrom(_sender, address(this), _amount),"Transfer failed");
        uint256 _userReadyForSnapshot = _snapShotNumber + 1;

        uint256 _oldTiers;
        uint256 _newTiers;

        if (!_isStaker[_sender]) {
            require(_amount >= TIERS1AMOUNT, "Minimum first stake not reached");
            _userSnapshots[_sender].push(_userReadyForSnapshot);
            _isStaker[_sender] = true;
            _stakers.add(_sender);
            _userDatas[_sender][_userReadyForSnapshot].staked = _amount;

            _newTiers = _getTiers(_amount);
            _userDatas[_sender][_userReadyForSnapshot].tiers = _newTiers;

            _tiersStaked[_newTiers] += _amount;


        } else {
            uint256[] memory _snaps = _userSnapshots[_sender];

            if(_snaps[_snaps.length - 1] != _userReadyForSnapshot){
                _userSnapshots[_sender].push(_userReadyForSnapshot);
            }

            UserData memory u = _userDatas[_sender][_snaps[_snaps.length - 1]];
            uint256 _newStakingAmount = _amount + u.staked;
            _userDatas[_sender][_userReadyForSnapshot].staked = _newStakingAmount;

            _oldTiers = u.tiers;
            _newTiers = _getTiers(_newStakingAmount);

            if (_oldTiers != _newTiers) {
                _userDatas[_sender][_userReadyForSnapshot].tiers = _newTiers;

                _tiersStaked[_oldTiers] -= u.staked;
                _tiersStaked[_newTiers] += _newStakingAmount;
            }else{
                _tiersStaked[_oldTiers] += _amount;
            }
        }

        _userDatas[_sender][_userReadyForSnapshot].unlockDate =
            uint256(block.timestamp) +
            lockPeriod;

        emit Staked(_sender, _amount);
    }

    function unStake(uint256 _amount) external  {
        address _sender = _msgSender();
        uint256[] memory _snaps = _userSnapshots[_sender];
        require(_isStaker[_sender], "You are not a staker");

        uint256 _lastSnapShotForUser = _snaps[_snaps.length - 1];
        UserData storage u = _userDatas[_sender][_lastSnapShotForUser];

        require(block.timestamp >= u.unlockDate, "To soon for unstake");
        require(u.staked >= _amount, "Can't unstake so much");
        u.staked -= _amount;
        uint256 _oldTiers = u.tiers;
        _tiersStaked[_oldTiers] -= _amount;

        if (u.staked == 0) {
            _isStaker[_sender] = false;
            _stakers.remove(_sender);
            _userSnapshots[_sender] = new uint256[](0);

        } else {
            uint256 _newTiers = _getTiers(u.staked);
            require(_newTiers != 0, "Can't stake less than Tiers1Amount");

            if (_oldTiers != _newTiers) {
                u.tiers = _newTiers;
                _tiersStaked[_newTiers] += u.staked;
                _tiersStaked[_oldTiers] -= u.staked;
            }
        }

        emit Unstaked(_sender, _amount);
        require(TOKEN.transfer(_sender, _amount),"Transfer error");
    }

    function _getTiers(uint256 _amount) internal pure returns (uint256) {
        if (_amount >= TIERS5AMOUNT) {
            return 5;
        }else if (_amount >= TIERS4AMOUNT) {
            return 4;
        }else if (_amount >= TIERS3AMOUNT) {
            return 3;
        } else if (_amount >= TIERS2AMOUNT) {
            return 2;
        } else if (_amount >= TIERS1AMOUNT) {
            return 1;
        } else {
            return 0;
        }
    }

}
