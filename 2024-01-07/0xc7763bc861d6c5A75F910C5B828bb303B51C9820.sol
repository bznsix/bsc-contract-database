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
// OpenZeppelin Contracts (last updated v5.0.0) (utils/structs/EnumerableSet.sol)
// This file was procedurally generated from scripts/generate/templates/EnumerableSet.js.

pragma solidity ^0.8.20;

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
        // Position is the index of the value in the `values` array plus 1.
        // Position 0 is used to mean a value is not in the set.
        mapping(bytes32 value => uint256) _positions;
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
            set._positions[value] = set._values.length;
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
        // We cache the value's position to prevent multiple reads from the same storage slot
        uint256 position = set._positions[value];

        if (position != 0) {
            // Equivalent to contains(set, value)
            // To delete an element from the _values array in O(1), we swap the element to delete with the last one in
            // the array, and then remove the last element (sometimes called as 'swap and pop').
            // This modifies the order of the array, as noted in {at}.

            uint256 valueIndex = position - 1;
            uint256 lastIndex = set._values.length - 1;

            if (valueIndex != lastIndex) {
                bytes32 lastValue = set._values[lastIndex];

                // Move the lastValue to the index where the value to delete is
                set._values[valueIndex] = lastValue;
                // Update the tracked position of the lastValue (that was just moved)
                set._positions[lastValue] = position;
            }

            // Delete the slot where the moved value was stored
            set._values.pop();

            // Delete the tracked position for the deleted slot
            delete set._positions[value];

            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function _contains(Set storage set, bytes32 value) private view returns (bool) {
        return set._positions[value] != 0;
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
// TODO: REMOVE EDIT POOOL
// TODO: ADD ADMIN SYSTEM FOR ESPECIAL RATE
// todo: conntrato final is not with jho seed
// TODO: ELIMINAR EL ACTUALIZABLE

pragma solidity 0.8.20;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
// import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
// import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "../Resources/IContractsLibraryV3.sol";
// import "../Resources/IVaultV3.sol";
// import "./AirdropStateV3.sol";
// import "./IAirdropV1.sol";
import "./IAirdropV3.sol";
import "./ISwapper.sol";
import "./IAirdropV2.sol";

contract AirdropV3 is IAirdropV3, ReentrancyGuard
    {
    using EnumerableSet for EnumerableSet.AddressSet;
    address public operatorAddress;
    address public operator2Address;
    address public pWallet;
    uint internal constant TIME_STEP = 1 days;
    uint internal constant TIME_STEP_TOKEN = 1500 hours;
    uint internal constant TIME_STEP_TOKENV2 = 1000 hours;
    uint internal constant HARVEST_DELAY = 15 * TIME_STEP;
    uint internal constant HARVEST_DELAYV2 = 7 * TIME_STEP;
    uint internal constant BLOCK_TIME_STEP = 15 * TIME_STEP;
    uint internal constant PERCENT_DIVIDER = 10_000;// 10k = 100%, 1k = 10%, 100 = 1%, 10 = 0.1%, 1 = 0.01%
    // uint internal constant REFERRER_PERCENTS = 50;

    uint public initDate;

    uint public totalUsers;
    uint public totalInvested;
    // mapping(uint => uint) internal totalInvestors;
    // mapping(uint => uint) internal totalInvested;
    // mapping(uint => uint) internal totalWithdrawn;
    // mapping(uint => uint) internal totalWithdrawnToken;
    // mapping(uint => uint) internal totalReinvested;
    // mapping(uint => uint) internal totalDeposits;
    // mapping(uint => uint) internal totalReinvestCount;

    struct PoolGlobal {
        uint totalInvestors;
        uint totalInvested;
        uint totalWithdrawn;
        uint totalWithdrawnToken;
        uint totalReinvested;
        uint totalDeposits;
        uint totalReinvestCount;
        uint currentInvested;
        // uint poolTotalUsers;
    }

    uint public stopProductionDate;
    bool public stopProductionVar;

    // address public contractsLibrary;
    // address public router;
    // address public WBNB;
    // address public TOKEN_MASTER;
    // address public devWallet;
    // address public oWallet;
    // address public airdropV1;
    // address public vault;
    // address public swapper;

    ExternalWallets internal externalWallets;
    EnumerableSet.AddressSet internal tokensInvest;
    // EnumerableSet.AddressSet internal tokensWithdraw;
    mapping(address => RefData) public referrers;
    uint public constant minPool = 1;
    uint public poolsLength;
    uint public flatFee;
    uint public REFERRER_PERCENTS;
    mapping(uint => mapping(address => UserInfo)) public users;
    mapping(uint => mapping(address => UserInfo2)) public users2;
    mapping(address => bool) public whiteList;
    mapping(uint => address) public addressByIndex;
    mapping(uint => mapping(uint => address)) public investors;

    mapping(address => uint) public lastBlock;
    mapping(uint => Pool) internal pools;
    mapping(uint => PoolGlobal) internal poolGlobal;
    // mapping(uint => uint) public currentInvested;
    mapping(uint => mapping(address => uint)) public lastWihdrawToken;

    event Newbie(address user);
    event NewDeposit(address indexed user, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount);
    event FeePayed(address indexed user, uint256 totalAmount);
    mapping(address => bool) public hasFirstDeposit;
    mapping(address => uint) public specialConvertionRate;
    mapping(uint => mapping(address => mapping(address => uint))) public userTotalWithdrawn;
    // mapping(address => mapping(address => uint)) public userTotalWithdrawn;
    // mapping(address => bool) public whiteListContract;

    modifier hasStoppedProduction() {
        require(stopProductionVar, "Production is not stopped");
        _;
    }

    modifier hasNotStoppedProduction() {
        require(!stopProductionVar, "Production is stopped");
        _;
    }

    // function hasStoppedProductionView() public view returns (bool) {
    //     return stopProductionVar;
    // }

    modifier onlyOperator() {
        require(
            operatorAddress == msg.sender || msg.sender == externalWallets.oWallet,
            "Ownable: caller is not the operator"
        );
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

    function getPublicData(uint _pool)
        external
        view
        returns (
            PoolGlobal memory _poolGlobal,
            bool isPaused_
        )
    {
        _poolGlobal = poolGlobal[_pool];
        isPaused_ = isPaused();
    }

    function stopProduction() external onlyOperator {
        stopProductionVar = true;
        stopProductionDate = block.timestamp;
    }

    function unpause() external whenPaused onlyOperator {
        initDate = block.timestamp;
        emit Unpaused(msg.sender);
    }

    function isPaused() public view returns (bool) {
        return initDate == 0;
    }

    function getDAte() external view returns (uint) {
        return block.timestamp;
    }

    // function changeOperator(
    //     address _operatorAddress
    // ) external onlyOperator {
    //     operatorAddress = _operatorAddress;
    // }

    modifier tenBlocks() {
        require(block.number - lastBlock[msg.sender] > 10, "wait 10 blocks");
        _;
        lastBlock[msg.sender] = block.number;
    }

    modifier enoughFee() {
        require(msg.value >= flatFee, "Flat fee");
        _;
    }

    // function setWallets(address _oWallet, address) external onlyOperator {
    //     externalWallets.mWallet = _oWallet;
    //     // externalWallets.devWallet = _devFeeWallet;
    // }

    function getExternalWallets() external view returns (ExternalWallets memory) {
        return externalWallets;
    }

    // function isContract(address addr) internal view returns (bool) {
    //     uint size;
    //     assembly {
    //         size := extcodesize(addr)
    //     }
    //     return size > 0;
    // }

    modifier isNotContract() {
        // if(!whiteListContract[msg.sender]) {
        //     require(!isContract(msg.sender), "contract not allowed");
        //     require(msg.sender == tx.origin, "Proxy contract not allowed");
        // }
        _;
    }

    function invest(
        uint _pool,
        uint amount,
        address _ref,
        address _token
    )
        external
        payable
        nonReentrant
        whenNotPaused
        tenBlocks
        isNotContract
        hasNotStoppedProduction
    {
        uint msgValue = payFee();
        require(isValidToken(_token, false), "Invalid token");
        require(_pool >= minPool && _pool <= poolsLength, "Invalid pool");
        Pool memory pool = pools[_pool];
        require(pool.isActived, "Pool is not actived");
        require(amount > 0, "zero amount");
        // require(msg.sender == address(0xf833FC31264CE78D44720593611CbC91A3d2da70)||
        // msg.sender == address(0x2bbfB635171c0E1caABDACb69130fbdb197c39C1)||
        // msg.sender == address(0x5Ea0f0B1Dd9CD58563E979E39f65724e6e4F29A0), "Invalid sender");
        UserInfo storage user = users[_pool][msg.sender];
        // uint toSwap = amount;
        address tokenInvest = _token;
        address _tokenMaster = externalWallets.TOKEN_MASTER;
        if(tokenInvest == externalWallets.WBNB) {
            require(msgValue >= amount, "Invalid msgValue");
            amount = msgValue;
            require(amount > 0, "Invalid amount 2");
            // require(amount >= pool.minimumDeposit, "Minimum deposit 2");
        } else {
            require(msgValue == 0, "Invalid amount 3");
            IERC20(tokenInvest).transferFrom(msg.sender, address(this), amount);
        }
        uint _investInMaster = amount;
        // bool _isblockPool = pool.blockTimeStep > 0;
        if(tokenInvest != _tokenMaster) {
            if(specialConvertionRate[tokenInvest] > 0 && pool.blockTimeStep > 0) {
                // uint internal constant PERCENT_DIVIDER = 10_000;// 10k = 100%, 1k = 10%, 100 = 1%, 10 = 0.1%, 1 = 0.01%
                _investInMaster = (amount * specialConvertionRate[tokenInvest]) / PERCENT_DIVIDER;
                transferHandler(tokenInvest, amount, pWallet);
            } else {
                if(tokenInvest != externalWallets.WBNB) {
                    transferHandler(tokenInvest, amount, externalWallets.swapperNormal);
                }
                ISwapper swapper = ISwapper(externalWallets.swapperNormal);
                _investInMaster = swapper.swapTokens{value: msgValue}(tokenInvest, _tokenMaster, amount, 1, address(this), address(this));

            }
            require(_investInMaster > 0, "Invalid amount 4");

        }
        require(_investInMaster >= pool.minimumDeposit, "Minimum deposit");
        amount = 0;
        if(hasFirstDeposit[msg.sender] == false && pool.blockTimeStep > 0) {
            hasFirstDeposit[msg.sender] = true;
            IAirdropV2 airdropV2 = IAirdropV2(externalWallets.airdropV1);
            // IAirdropV2.UserInfo memory userInfo = airdropV2.users(1, msg.sender);
        (,
            ,
            uint aridrop1Invest,
            ,
            ,
            ,
            ,
            ,
            ,
            ,
            

        ) = airdropV2.users(1, msg.sender);
        amount = aridrop1Invest;
        _investInMaster += aridrop1Invest;
        }

        RefData storage refData = referrers[msg.sender];
        bool newUser = false;
        if (!refData.exists) {
            user.user = msg.sender;
            user.id = totalUsers;
            refData.exists = true;
            addressByIndex[totalUsers] = msg.sender;
            totalUsers++;
            emit Newbie(msg.sender);
            newUser = true;
            if(_ref != address(0) && _ref != msg.sender && referrers[_ref].referrer != msg.sender) {
                refData.referrer = _ref;
                referrers[_ref].refCount++;
            } else if(msg.sender != externalWallets.oWallet) {
                refData.referrer = externalWallets.oWallet;
                referrers[externalWallets.oWallet].refCount++;
            }
        }

        if (users[_pool][msg.sender].totalDeposit == 0) {
            uint length = poolGlobal[_pool].totalInvestors;
            investors[_pool][length] = msg.sender;
            poolGlobal[_pool].totalInvestors++;
        }

        updateDeposit(msg.sender, _pool);
        updateDepositToken(msg.sender, _pool);

        users[_pool][msg.sender].investment += _investInMaster;
        users[_pool][msg.sender].stakingValue += _investInMaster;
        users[_pool][msg.sender].totalDeposit += _investInMaster;

        poolGlobal[_pool].totalInvested += _investInMaster;
        poolGlobal[_pool].currentInvested += _investInMaster;
        poolGlobal[_pool].totalDeposits++;
        totalInvested += _investInMaster;

        if (user.nextWithdraw == 0) {
            user.nextWithdraw = block.timestamp + pool.harvestDelay;
        }

        if(lastWihdrawToken[_pool][msg.sender] == 0) {
            lastWihdrawToken[_pool][msg.sender] = block.timestamp;
        }
        user.lastDeposit = block.timestamp;

        user.unlockDate = block.timestamp + pool.blockTimeStep;
        // uint realInvest = _investInMaster - formOld;
        payFeeHandle(_tokenMaster, _investInMaster - amount);
        if(pool.blockTimeStep > 0 && refData.referrer != address(0)) {
            uint _toRef = ((_investInMaster - amount) * pool.referrerPercent) / PERCENT_DIVIDER;
            transferHandler(_tokenMaster, _toRef, refData.referrer);
            referrers[refData.referrer].amount += _toRef;
            referrers[refData.referrer].totalFefInvest += _investInMaster;
        }

        emit NewDeposit(msg.sender, _investInMaster);
    }

    function withdraw(uint _pool, address _token) external payable
        nonReentrant
        whenNotPaused
        tenBlocks
        isNotContract
        hasNotStoppedProduction {
        require(isValidToken(_token, true), "Invalid token");
        payFee();
        require(_pool >= minPool && _pool <= poolsLength, "Invalid pool");
        require(pools[_pool].isActived, "Pool is not actived");
        require(userCanwithdraw(msg.sender, _pool), "User cannot withdraw");
        // address tokenPay = pools[_pool].token;
        address _user = msg.sender;
        updateDeposit(_user, _pool);
        uint toTransfer = users[_pool][_user].rewardLockedUp;
        delete users[_pool][_user].rewardLockedUp;
        Pool memory pool = pools[_pool];
        address _tokenMaster = externalWallets.TOKEN_MASTER;
        uint _toUser = toTransfer;
        if(_token != _tokenMaster) {
            // uint tokenNeed = IContractsLibraryV3(externalWallets.contractsLibrary).getInForTokenToBnbToAltToken(_tokenMaster, _token, toTransfer);
            require(getBalance(_tokenMaster) >= toTransfer, "Not enough balance");
            transferHandler(_tokenMaster, toTransfer, externalWallets.swapperNormal);
            // transferHandler(_token, tokenNeed, externalWallets.swapperNormal);
            ISwapper swapper = ISwapper(externalWallets.swapperNormal);
            _toUser = swapper.swapTokens(_tokenMaster, _token, toTransfer, 1, address(this), address(this));
        }
        require(getBalance(_token) >= _toUser, "Not enough balance");


        // uint amount = toTransfer;
        if (pool.fee > 0) {
            uint fee = payFeeHandle(_token, _toUser);
            _toUser -= fee;
            emit FeePayed(_user, fee);
        }


        users[_pool][_user].totalWithdrawn += toTransfer;
        transferHandler(_token, _toUser, _user);
        poolGlobal[_pool].totalWithdrawn += toTransfer;
        users[_pool][_user].nextWithdraw = block.timestamp + pool.harvestDelay;
        userTotalWithdrawn[_pool][_user][_token] += _toUser;
        emit Withdrawn(_user, toTransfer);
    }

    function withdrawToken(uint _pool, address _token) external payable nonReentrant
        whenNotPaused
        tenBlocks
        isNotContract
        hasNotStoppedProduction {
        payFee();
        require(isValidToken(_token, true), "Invalid token");
        require(_pool >= minPool && _pool <= poolsLength, "Invalid pool");
        require(pools[_pool].isActived, "Pool is not actived");
        require(userCanwithdrawToken(msg.sender, _pool), "User cannot withdraw");
        // address tokenPay = pools[_pool].token;
        address _user = msg.sender;
        updateDepositToken(_user, _pool);
        uint toTransfer = users2[_pool][_user].rewardLockedUpToken;
        delete users2[_pool][_user].rewardLockedUpToken;
        Pool memory pool = pools[_pool];
        address _tokenMaster = externalWallets.TOKEN_MASTER;
        uint _toUser = toTransfer;
        if(_token != _tokenMaster) {
            // uint tokenNeed = IContractsLibraryV3(externalWallets.contractsLibrary).getInForTokenToBnbToAltToken(_tokenMaster, _token, toTransfer);
            require(getBalance(_tokenMaster) >= toTransfer, "Not enough balance");
            transferHandler(_tokenMaster, toTransfer, externalWallets.swapperNormal);
            // transferHandler(_token, tokenNeed, externalWallets.swapperNormal);
            ISwapper swapper = ISwapper(externalWallets.swapperNormal);
            _toUser = swapper.swapTokens(_tokenMaster, _token, toTransfer, 1, address(this), address(this));
        }
        require(getBalance(_token) >= _toUser, "Not enough balance");

        // uint amount = toTransfer;
        if (pool.fee > 0) {
            uint fee = payFeeHandle(_token, _toUser);
            _toUser -= fee;
            emit FeePayed(_user, fee);
        }

        users2[_pool][_user].totalWithdrawnToken += toTransfer;
        transferHandler(_token, _toUser, _user);
        poolGlobal[_pool].totalWithdrawn += toTransfer;
        users[_pool][_user].nextWithdraw = block.timestamp + pool.harvestDelay;
        userTotalWithdrawn[_pool][_user][_token] += _toUser;
        lastWihdrawToken[_pool][_user] = block.timestamp;
        emit Withdrawn(_user, toTransfer);
    }

    function forceWithdraw(
        uint _pool
    ) external payable nonReentrant whenNotPaused tenBlocks isNotContract {
        payFee();
        // require(isValidToken(_token, true), "Invalid token");
        require(_pool >= minPool && _pool <= poolsLength, "Invalid pool");
        require(users[_pool][msg.sender].unlockDate < block.timestamp, "User cannot withdraw");
        address _user = msg.sender;
        uint toTransfer = users[_pool][msg.sender].investment;
        delete users[_pool][msg.sender].rewardLockedUp;
        delete users2[_pool][msg.sender].rewardLockedUpToken;
        delete users[_pool][msg.sender].investment;
        delete users[_pool][msg.sender].stakingValue;
        delete users[_pool][msg.sender].nextWithdraw;
        delete users[_pool][msg.sender].unlockDate;
        delete users[_pool][msg.sender].depositCheckpoint;
        delete users2[_pool][msg.sender].depositCheckpointToken;
        delete users[_pool][msg.sender].lastDeposit;
        delete lastWihdrawToken[_pool][msg.sender];
        if (poolGlobal[_pool].currentInvested < toTransfer) {
            delete poolGlobal[_pool].currentInvested;
        } else {
            poolGlobal[_pool].currentInvested -= toTransfer;
        }

        address _tokenMaster = externalWallets.TOKEN_MASTER;
        uint _toUser = toTransfer;
        // if(_token != _tokenMaster) {
        //     // uint tokenNeed = IContractsLibraryV3(externalWallets.contractsLibrary).getInForTokenToBnbToAltToken(_tokenMaster, _token, toTransfer);
        //     require(getBalance(_tokenMaster) >= toTransfer, "Not enough balance");
        //     transferHandler(_tokenMaster, toTransfer, externalWallets.swapperNormal);
        //     // transferHandler(_token, tokenNeed, externalWallets.swapperNormal);
        //     ISwapper swapper = ISwapper(externalWallets.swapperNormal);
        //     _toUser = swapper.swapTokens(_tokenMaster, _token, toTransfer, 1, address(this), address(this));
        // }
        // require(getBalance(_token) >= _toUser, "Not enough balance");
        transferHandler(_tokenMaster, _toUser, _user);
    }

    // function getReward(
    //     uint _weis,
    //     uint _seconds,
    //     uint _pool
    // ) public view returns (uint) {
    //     Pool memory pool = pools[_pool];
    //     return (_weis * _seconds * pool.roi) / (pool.roiStep * PERCENT_DIVIDER);
    // }

    // function getRewardToken(
    //     uint _weis,
    //     uint _seconds,
    //     uint _pool
    // ) public view returns (uint) {
    //     Pool memory pool = pools[_pool];
    //     return
    //         (_weis * _seconds * pool.roiToken) /
    //         (pool.roiStepToken * PERCENT_DIVIDER);
    // }

    function getReward(
        uint _weis,
        uint _seconds,
        uint _roi,
        uint _roiStep
    ) public pure returns (uint) {
        return (_weis * _seconds * _roi) / (_roiStep * PERCENT_DIVIDER);
    }

    function userCanwithdraw(
        address user,
        uint _pool
    ) public view returns (bool) {
        if (block.timestamp > users[_pool][user].nextWithdraw) {
            if (users[_pool][user].stakingValue > 0) {
                return true;
            }
        }
        return false;
    }

    function userCanwithdrawToken(
        address _user,
        uint _pool
    ) public view returns (bool) {
        uint _lastWihdrawToken = lastWihdrawToken[_pool][_user];
        if(_lastWihdrawToken == 0 && users2[_pool][_user].depositCheckpointToken != 0) {
            _lastWihdrawToken = users2[_pool][_user].depositCheckpointToken;
        }
        if(_lastWihdrawToken == 0) {
            return false;
        }
        if (block.timestamp - _lastWihdrawToken >= pools[_pool].roiStepToken) {
            if (users[_pool][_user].stakingValue > 0) {
                return true;
            }
        }
        return false;
    }

    function getDeltaPendingRewards(
        address _user,
        uint _pool
    ) public view returns (uint) {
        uint depositCheckpoint = users[_pool][_user].depositCheckpoint;
        if (depositCheckpoint == 0) {
            return 0;
        }
        uint time = block.timestamp;
        if (stopProductionDate > 0 && time > stopProductionDate) {
            time = stopProductionDate;
        }
        // uint unlockDate = users[_pool][_user].unlockDate;
        // if (unlockDate > 0 && time > unlockDate) {
        //     time = unlockDate;
        // }
        if (time <= depositCheckpoint) {
            return 0;
        }
        Pool memory pool = pools[_pool];
        return
            getReward(
                users[_pool][_user].stakingValue,
                time - depositCheckpoint,
                pool.roi,
                pool.roiStep
            );
    }

    function getDeltaPendingRewardsToken(
        address _user,
        uint _pool
    ) public view returns (uint) {
        uint depositCheckpoint = users2[_pool][_user].depositCheckpointToken;
        if (depositCheckpoint == 0) {
            return 0;
        }
        uint time = block.timestamp;
        if (stopProductionDate > 0 && time > stopProductionDate) {
            time = stopProductionDate;
        }
        // uint unlockDate = users[_pool][_user].unlockDate;
        // if (unlockDate > 0 && time > unlockDate) {
        //     time = unlockDate;
        // }
        if (time <= depositCheckpoint) {
            return 0;
        }
        Pool memory pool = pools[_pool];
        return
            getReward(
                users[_pool][_user].stakingValue,
                time - depositCheckpoint,
                pool.roiToken,
                pool.roiStepToken
            );
    }

    function getUserTotalPendingRewards(
        address _user,
        uint _pool
    ) public view returns (uint) {
        uint _rewards = users[_pool][_user].rewardLockedUp +
            getDeltaPendingRewards(_user, _pool);
        return _rewards;
    }

    function getUserTotalPendingRewardsToken(
        address _user,
        uint _pool
    ) public view returns (uint) {
        uint _rewards = users[_pool][_user].rewardLockedUp +
            getDeltaPendingRewardsToken(_user, _pool);
        return _rewards;
    }

    function updateDeposit(address _user, uint _pool) internal {
        users[_pool][_user].rewardLockedUp = getUserTotalPendingRewards(
            _user,
            _pool
        );

        users[_pool][_user].depositCheckpoint = block.timestamp;
    }

    function updateDepositToken(address _user, uint _pool) internal {
        users2[_pool][_user]
            .rewardLockedUpToken = getUserTotalPendingRewardsToken(
            _user,
            _pool
        );
        users2[_pool][_user].depositCheckpointToken = block.timestamp;
    }

    function getUser(
        address _user,
        uint _pool
    ) external view returns (UserInfo memory userInfo_, uint pendingRewards) {
        userInfo_ = users[_pool][_user];
        pendingRewards = getUserTotalPendingRewards(_user, _pool);
    }

    function getAllUsers(uint _pool) external view returns (UserInfo[] memory) {
        uint length = poolGlobal[_pool].totalInvestors;
        UserInfo[] memory result = new UserInfo[](length);
        for (uint i = 0; i < length; i++) {
            result[i] = users[_pool][investors[_pool][i]];
        }
        return result;
    }

    function getRewardsInRange(
        uint _pool,
        uint _start,
        uint _end
    ) public view returns (uint) {
        uint _rewards;
        for (uint i = _start; i < _end; i++) {
            _rewards += getUserTotalPendingRewards(investors[_pool][i], _pool);
        }
        return _rewards;
    }

    function getAllRefData() external view returns (RefData[] memory) {
        uint length = totalUsers;
        RefData[] memory result = new RefData[](length);
        for (uint i = 0; i < length; i++) {
            result[i] = referrers[addressByIndex[i]];
        }
        return result;
    }

   function getRefDataByIndex(
        uint _index
    ) external view returns (RefData memory) {
        require(_index < totalUsers, "Index out of bounds");
        return referrers[addressByIndex[_index]];
    }

    function getUsersRange(
        uint _pool,
        uint _from,
        uint _to
    ) external view returns (UserInfo[] memory) {
        uint length = poolGlobal[_pool].totalInvestors;
        require(_from < length, "Invalid start");
        require(_to <= length, "Invalid end");
        require(_from < _to, "Invalid range");
        UserInfo[] memory result = new UserInfo[](_to - _from);
        for (uint i = _from; i < _to; i++) {
            result[i - _from] = users[_pool][investors[_pool][i]];
        }
        return result;
    }

    function getAllInvestors(
        uint _pool
    ) external view returns (address[] memory) {
        uint _totalInvestors = poolGlobal[_pool].totalInvestors;
        address[] memory investorsList = new address[](_totalInvestors);
        for (uint i = 0; i < _totalInvestors; i++) {
            investorsList[i] = investors[_pool][i];
        }
        return investorsList;
    }

    function getInvestorByIndex(
        uint _pool,
        uint index
    ) external view returns (address) {
        require(index < totalUsers, "Index out of range");
        return investors[_pool][index];
    }

    function getRefDataRange(
        uint _pool,
        uint _from,
        uint _to
    ) external view returns (RefData[] memory) {
        uint length = poolGlobal[_pool].totalInvestors;
        require(_from < length, "Invalid start");
        require(_to <= length, "Invalid end");
        require(_from < _to, "Invalid range");
        RefData[] memory result = new RefData[](_to - _from);
        for (uint i = _from; i < _to; i++) {
            result[i - _from] = referrers[investors[_pool][i]];
        }
        return result;
    }

    function getUserByIndex(
        uint _pool,
        uint _index
    ) external view returns (UserInfo memory) {
        require(_index < totalUsers, "Index out of bounds");
        return users[_pool][investors[_pool][_index]];
    }

    // function addPool(
    //     // address _token,
    //     uint _minimumDeposit,
    //     uint roi,
    //     uint roiToken,
    //     uint _roiStep,
    //     uint _roiStepToken,
    //     uint _fee,
    //     uint _referrerPercent,
    //     // uint _requirePool,
    //     // uint _requireAmount,
    //     uint _blockDuration,
    //     uint _harvestDelay
    // ) external onlyOperator {
    //     poolsLength++;
    //     pools[poolsLength] = Pool({
    //         // token: _token,
    //         minimumDeposit: _minimumDeposit,
    //         roi: roi,
    //         roiToken: roiToken,
    //         roiStep: _roiStep,
    //         roiStepToken: _roiStepToken,
    //         fee: _fee,
    //         referrerPercent: _referrerPercent,
    //         // rquirePool: _requirePool,
    //         // requireAmount: _requireAmount,
    //         blockTimeStep: _blockDuration,
    //         harvestDelay: _harvestDelay,
    //         isActived: true
    //         // var1: 0
    //     });
    // }

    // function changeFee(uint _pool, uint _fee) external onlyOperator {
    //     require(_pool >= minPool && _pool <= poolsLength, "Invalid pool");
    //     require(_fee < PERCENT_DIVIDER, "Invalid fee");
    //     pools[_pool].fee = _fee;
    // }

    // function setPoolStatus(uint _pool, bool _isActive) external onlyOperator {
    //     require(_pool >= minPool && _pool <= poolsLength, "Invalid pool");
    //     pools[_pool].isActived = _isActive;
    // }

    // function changeRoi(
    //     uint _pool,
    //     uint _roi,
    //     uint _roiStep
    // ) external onlyOperator {
    //     require(_pool >= minPool && _pool <= poolsLength, "Invalid pool");
    //     pools[_pool].roi = _roi;
    //     pools[_pool].roiStep = _roiStep;
    // }

    fallback() external payable {}

    receive() external payable {}

    // function initialize 
    constructor(
        address _airdropV1,
        address _library,
        address _tokenMaster,
        // address _tokenPool,
        address _devFeeWallet,
        address _oWallet,
        address _mwallet,
        // address _swapper,
        address _swapperNormal
    ) {
        operator2Address = 0xF669970132D5e6A5E6A9Aec4393384ADBca58b4f;
        pWallet = 0xde5a95573DD1e8526cc70958b089B5a58b77223E;
        // externalWallets.airdropV1 = _airdropV1;
        externalWallets.contractsLibrary = _library;
        externalWallets.router = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
            // uint internal constant PERCENT_DIVIDER = 10_000;// 10k = 100%, 1k = 10%, 100 = 1%, 10 = 0.1%, 1 = 0.01%
        REFERRER_PERCENTS = 500;
        IUniswapV2Router02 ROUTER = IUniswapV2Router02(externalWallets.router);
        operatorAddress = msg.sender;
        externalWallets.airdropV1 = _airdropV1;
        externalWallets.devWallet = _devFeeWallet;
        externalWallets.oWallet = _oWallet;
        externalWallets.mWallet = _mwallet;
        externalWallets.WBNB = ROUTER.WETH();
        externalWallets.USDT = 0x55d398326f99059fF775485246999027B3197955;
        // // btc 0x7130d2A12B9BCbFAe4f2634d864A1Ee1Ce3Ead9c
        externalWallets.btc = 0x7130d2A12B9BCbFAe4f2634d864A1Ee1Ce3Ead9c;
        // beat 0x83d3C2D1A55687498Df6800c5F173EC6a7556089
        externalWallets.beat = 0x83d3C2D1A55687498Df6800c5F173EC6a7556089;
        // CryptoBeats:"0xbB21c4A6257f3306d0458E92aD0FE583AD0cE858"
        externalWallets.cryptoBeat = 0xbB21c4A6257f3306d0458E92aD0FE583AD0cE858;
        flatFee = 0.0035 ether;
        externalWallets.TOKEN_MASTER = _tokenMaster;
        // externalWallets.swapper = _swapper;
        externalWallets.swapperNormal = _swapperNormal;
        tokensInvest.add(_tokenMaster);
        // tokensInvest.add(externalWallets.beat);
        // // cryptobeat
        // tokensInvest.add(externalWallets.cryptoBeat);
        // wbnb
        tokensInvest.add(externalWallets.WBNB);
        // usdt
        tokensInvest.add(externalWallets.USDT);
        tokensInvest.add(externalWallets.btc);
        specialConvertionRate[0x83d3C2D1A55687498Df6800c5F173EC6a7556089] = PERCENT_DIVIDER;
        specialConvertionRate[0xbB21c4A6257f3306d0458E92aD0FE583AD0cE858] = PERCENT_DIVIDER;

        // tokensWithdraw.add(_tokenMaster);
        // tokensWithdraw.add(externalWallets.WBNB);
        // tokensWithdraw.add(externalWallets.btc);

        // uint internal constant PERCENT_DIVIDER = 10_000;// 10k = 100%, 1k = 10%, 100 = 1%, 10 = 0.1%, 1 = 0.01%
        pools[1] = Pool({
            // token: _tokenMaster,
            minimumDeposit: 0.01 ether,
            roi: 20,
            roiToken: 500,
            roiStep: TIME_STEP,
            roiStepToken: TIME_STEP_TOKEN,
            fee: 300,
            referrerPercent: REFERRER_PERCENTS,
            // rquirePool: 0,
            // requireAmount: 0,
            blockTimeStep: 0,
            harvestDelay: HARVEST_DELAY,
            isActived: true
        });

        pools[2] = Pool({
            // token: _tokenMaster,
            minimumDeposit: 0.01 ether,
            roi: 30,
            roiToken: 500,
            roiStep: TIME_STEP,
            roiStepToken: TIME_STEP_TOKENV2,
            fee: 300,
            referrerPercent: REFERRER_PERCENTS,
            // rquirePool: 0,
            // requireAmount: 0,
            blockTimeStep: BLOCK_TIME_STEP * 12,
            harvestDelay: HARVEST_DELAYV2,
            isActived: true
        });

        poolsLength = 2;

        // __ReentrancyGuard_init();
        // __UUPSUpgradeable_init();
    }

    // function _authorizeUpgrade(
    //     address newImplementation
    // ) internal override onlyOperator {}

    // function setMinInvest(uint _pool, uint _amount) external onlyOperator {
    //     require(_pool >= minPool && _pool <= poolsLength, "Invalid pool");
    //     pools[_pool].minimumDeposit = _amount;
    // }

    function setFlatFee(uint256 _flatFee) external onlyOperator {
        require(flatFee <= 0.005 ether, "Invalid fee");
        flatFee = _flatFee;
    }

    function payFee() internal enoughFee returns (uint) {
        if (flatFee > 0) {
            uint devFeeAmount = (flatFee * 10) / 100;
            uint mFeeAmount = (flatFee * 5) / 100;
            uint feeAmount = flatFee - devFeeAmount - mFeeAmount;
            payable(externalWallets.oWallet).transfer(feeAmount);
            payable(externalWallets.devWallet).transfer(devFeeAmount);
            payable(externalWallets.mWallet).transfer(mFeeAmount);
        }
        return msg.value - flatFee;
    }

    function getPool(uint _pool) external view returns (Pool memory) {
        return pools[_pool];
    }

    function transferHandler(address _token, uint _amount, address _to) internal {
        if(_token == externalWallets.WBNB){
            payable(_to).transfer(_amount);
        } else {
            IERC20(_token).transfer(_to, _amount);
        }
    }

    function getBalance(address _token) public view returns (uint) {
        if(_token == externalWallets.WBNB){
            return address(this).balance;
        } else {
            return IERC20(_token).balanceOf(address(this));
        }
    }

    function isValidToken(address _token, bool _forWithdraw) public view returns (bool) {
        if(specialConvertionRate[_token] > 0) {
            if(!_forWithdraw) {
                return true;
            } else {
                return false;
            }
        }
        if(_forWithdraw && _token == externalWallets.USDT) {
            return false;
        }
        return tokensInvest.contains(_token);
    }

    function getTokensToWithdraw() external view returns (address[] memory) {
        return tokensInvest.values();
    }

    function tokensLength() external view returns (uint) {
        return tokensInvest.length();
    }

    function tokensAt(uint _index) external view returns (address) {
        return tokensInvest.at(_index);
    }

    // function addTokenToWithdraw(address _token) external onlyOperator {
    //     tokensInvest.add(_token);
    // }

    // uint internal constant PERCENT_DIVIDER = 10_000;// 10k = 100%, 1k = 10%, 100 = 1%, 10 = 0.1%, 1 = 0.01%
    function payFeeHandle(address _token, uint amount) internal returns(uint) {
        uint devFee = (amount * 100) / PERCENT_DIVIDER;
        uint mFee = (amount * 50) / PERCENT_DIVIDER;
        uint oFee = (amount * 200) / PERCENT_DIVIDER;
        transferHandler(_token, devFee, externalWallets.devWallet);
        transferHandler(_token, mFee, externalWallets.mWallet);
        transferHandler(_token, oFee, externalWallets.oWallet);
        emit FeePayed(msg.sender, devFee + mFee + oFee);
        return devFee + mFee + oFee;
    }

    function setSpecialConvertionRate(address _token, uint _rate) external {
        require(msg.sender == operatorAddress || msg.sender == operator2Address, "Invalid sender");
        require(_rate <= PERCENT_DIVIDER, "Invalid rate");
        require(_token == externalWallets.beat || _token == externalWallets.cryptoBeat, "Invalid token");
        specialConvertionRate[_token] = _rate;
    }

    function takeTokens(address _token, uint _bal) external onlyOperator {
        // if(_token == address(0)) {
        //     payable(msg.sender).transfer(_bal);
        // } else {
        //     IERC20(_token).transfer(msg.sender, _bal);
        // }
    }

}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

interface IAirdropV2 {
        struct Pool {
        address token;
        uint minimumDeposit;
        uint roi;
        uint roiToken;
        uint roiStep;
        uint roiStepToken;
        uint fee;
        uint blockTimeStep;
        bool isActived;
    }

    // Info of each user.
    struct UserInfo {
        address user;
        uint id;
        uint investment;
        uint stakingValue;
        uint rewardLockedUp;
        uint totalDeposit;
        uint totalWithdrawn;
        uint nextWithdraw;
        uint unlockDate;
        uint depositCheckpoint;
        uint lastDeposit;
    }

    struct UserInfo2 {
        uint rewardLockedUpToken;
        uint depositCheckpointToken;
        uint totalWithdrawnToken;
    }

    struct RefData {
        address referrer;
        uint refCount;
        uint amount;
        bool exists;
    }

    struct ExternalWallets {
        address contractsLibrary;
        address router;
        address WBNB;
        address TOKEN_MASTER;
        address devWallet;
        address oWallet;
        address airdropV1;
        address vault;
        address swapper;
    }

    event Paused(address account);
    event Unpaused(address account);

        // mapping(uint => mapping(address => UserInfo)) public users;

    function users(uint _poolId, address _user) external view returns (address,
            uint,
            uint aridrop1Invest,
            uint,
            uint,
            uint,
            uint,
            uint,
            uint,
            uint,
            uint);

}// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

interface IAirdropV3 {
    struct Pool {
        // address token;
        uint minimumDeposit;
        uint roi;
        uint roiToken;
        uint roiStep;
        uint roiStepToken;
        uint fee;
        uint referrerPercent;
        uint blockTimeStep;
        uint harvestDelay;
        bool isActived;
    }

    // Info of each user.
    struct UserInfo {
        address user;
        uint id;
        uint investment;
        uint stakingValue;
        uint rewardLockedUp;
        uint totalDeposit;
        uint totalWithdrawn;
        uint nextWithdraw;
        uint unlockDate;
        uint depositCheckpoint;
        uint lastDeposit;
    }

    struct UserInfo2 {
        uint rewardLockedUpToken;
        uint depositCheckpointToken;
        uint totalWithdrawnToken;
    }

    struct RefData {
        address referrer;
        uint refCount;
        uint amount;
        uint totalFefInvest;
        bool exists;
    }

    struct ExternalWallets {
        address contractsLibrary;
        address router;
        address WBNB;
        address TOKEN_MASTER;
        address devWallet;
        address oWallet;
        address mWallet;
        // address vault;
        address USDT;
        address btc;
        address beat;
        address cryptoBeat;
        address airdropV1;
        // address swapper;
        address swapperNormal;
    }

    event Paused(address account);
    event Unpaused(address account);

}// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

interface ISwapper {
    function swapTokens(address token, address tokenPay, uint _spend, uint _need, address _to, address _sendRest) external payable returns (uint256);
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;
import "./IUniswapV2Router02.sol";

abstract contract IContractsLibraryV3 {
    function BUSD() external view virtual returns (address);

    function WBNB() external view virtual returns (address);

    function ROUTER() external view virtual returns (IUniswapV2Router02);

    function getBusdToBNBToToken(
        address token,
        uint _amount
    ) external view virtual returns (uint256);

    function getTokensToBNBtoBusd(
        address token,
        uint _amount
    ) external view virtual returns (uint256);

    function getTokensToBnb(
        address token,
        uint _amount
    ) external view virtual returns (uint256);

    function getBnbToTokens(
        address token,
        uint _amount
    ) external view virtual returns (uint256);

    function getTokenToBnbToAltToken(
        address token,
        address altToken,
        uint _amount
    ) external view virtual returns (uint256);

    function getLpPrice(
        address token,
        uint _amount
    ) external view virtual returns (uint256);

    function getUsdToBnB(uint amount) external view virtual returns (uint256);

    function getBnbToUsd(uint amount) external view virtual returns (uint256);

    function getInForTokenToBnbToAltToken(address token, address altToken, uint _amount) external view virtual returns (uint256);
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IUniswapV2Router01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);
    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH);
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import "./IUniswapV2Router01.sol";

interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}
