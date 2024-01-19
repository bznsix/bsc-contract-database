// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (access/Ownable.sol)

pragma solidity ^0.8.20;

import {Context} from "../utils/Context.sol";

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

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the address provided by the deployer as the initial owner.
     */
    constructor(address initialOwner) {
        if (initialOwner == address(0)) {
            revert OwnableInvalidOwner(address(0));
        }
        _transferOwnership(initialOwner);
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
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
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
// OpenZeppelin Contracts (last updated v5.0.1) (utils/Context.sol)

pragma solidity ^0.8.20;

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

    function _contextSuffixLength() internal view virtual returns (uint256) {
        return 0;
    }
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
pragma solidity 0.8.20;

interface ISwapper {
    function swapTokens(address token, address tokenPay, uint _spend, uint _need, address _to, address _sendRest) external payable returns (uint256);
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

interface IBonusHander {

    struct NFT_Data {
        address owner;
        uint id;
        uint getType;
        bool used;
    }

    function getMyPercent(address _user, uint _myDivider) external view returns(uint);

    function bonusByType(uint _type) external view returns(uint);

    function getNFTaddress() external view returns(address);

    function useMybonus(address _user) external returns (uint _percent, uint _divider);

    function getMyBonus(address _user) external view returns (uint _percent, uint _divider);

    function getNftData(uint _id) external view returns (NFT_Data memory);

    function getNftDataByOwner(address _owner) external view returns (NFT_Data memory);

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
// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "../Resources/IContractsLibraryV3.sol";
import "../AirdropV3/ISwapper.sol";
import "../BonusHander/IBonusHander.sol";
import "./StakingState.sol";
import "./IStakingV1.sol";

contract CryptoStakingV2 is StakingState, ReentrancyGuard, Ownable {
    using EnumerableSet for EnumerableSet.AddressSet;
    address public operatorAddress;
    address public operator2Address;
    address public pWallet;
    // IContractsLibraryV2 public contractsLibrary;
    // PERCENT_DIVIDER = 100_000; // 100_000 = 100%, 10_000 = 10%, 1_000 = 1%, 100 = 0.1%, 10 = 0.01%, 1 = 0.001%
    mapping(address => RefData) public referrers;

    uint public constant minPool = 1;
    uint public poolsLength;
    uint public flatFee;
    // uint public devFee;
    EnumerableSet.AddressSet internal tokensInvest;
    ExternalWallets internal externalWallets;
    mapping(uint => mapping(address => UserInfo)) public users;

    mapping(address => uint) public lastBlock;
    mapping(uint => Pool) public pools;
    mapping(address => bool) public hasFirstDeposit;
    mapping(address => uint) public specialConvertionRate;
    mapping(address => bool) public blackList;

    modifier enoughFee() {
        require(msg.value >= flatFee, "Flat fees");
        _;
    }

    constructor(
        // address _library,
        address _tokenMaster,
        address _devFeeWallet,
        address _oWallet,
        address _mwallet,
        address _swapperNormal,
        address _stakingV1,
        address _bonusHander
    ) Ownable(msg.sender) {
        operatorAddress = msg.sender;
        // contractsLibrary = IContractsLibraryV2(_library);
        // externalWallets.airdropV1 = _airdropV1;
        // externalWallets.contractsLibrary = _library;
        operator2Address = 0xF669970132D5e6A5E6A9Aec4393384ADBca58b4f;
        externalWallets.router = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
        pWallet = 0xde5a95573DD1e8526cc70958b089B5a58b77223E;
        flatFee = 0.0035 ether;
        // devFee = 1_000;
        FORCE_WITHDRAW_FEE = 50_000;
        referrer_is_allowed = true;
        externalWallets.devWallet = _devFeeWallet;
        externalWallets.oWallet = _oWallet;
        externalWallets.mWallet = _mwallet;
        IUniswapV2Router02 ROUTER = IUniswapV2Router02(externalWallets.router);
        externalWallets.stakingV1 = _stakingV1;
        externalWallets.bonusHander = _bonusHander;
        externalWallets.WBNB = ROUTER.WETH();
        externalWallets.USDT = 0x55d398326f99059fF775485246999027B3197955;
        // // btc 0x7130d2A12B9BCbFAe4f2634d864A1Ee1Ce3Ead9c
        externalWallets.btc = 0x7130d2A12B9BCbFAe4f2634d864A1Ee1Ce3Ead9c;
        // beat 0x83d3C2D1A55687498Df6800c5F173EC6a7556089
        externalWallets.beat = 0x83d3C2D1A55687498Df6800c5F173EC6a7556089;
        // CryptoBeats:"0xbB21c4A6257f3306d0458E92aD0FE583AD0cE858"
        externalWallets.cryptoBeat = 0xbB21c4A6257f3306d0458E92aD0FE583AD0cE858;
        externalWallets.TOKEN_MASTER = _tokenMaster;
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

        blackList[0x0818C6b4Fb73a00794591BF4155C530c76cB9610] = true;
        blackList[0xe0EFdb262E94F3fb1102FF3951F60937eeb2c1AD] = true;
        blackList[0xFbc6A499a1dd6144E14201907bA9D36d21C34b5a] = true;
        blackList[0x268C9Ab5a7D2826306ac2B7e39B08c328e78D3FF] = true;
        blackList[0x42dcde176D75F4761B939B486a0a51eb1f191f89] = true;

        // specialConvertionRate[0x83d3C2D1A55687498Df6800c5F173EC6a7556089] = 0;
        // specialConvertionRate[0xbB21c4A6257f3306d0458E92aD0FE583AD0cE858] = 0;
        // 30 días 0.125% diario reinvets 24h+  -1 
        // 45 dias 0.25% diario reinvets 24h+ -2
        // 60 días 0.375% diario reinvets 24h+ -3
        // 90 días 0.5% diario reinvets 24h+ -4
        // 120 días 0.625% diario reinvets 24h+ -5
        // 150 días 0.75% diario reinvets 24h+ -6
        // 180 días 0.875% diario reinvets 12h+ -7
        // 360 días 1% diario reinvets 6h+ -8
        // PERCENT_DIVIDER = 100_000; // 100_000 = 100%, 10_000 = 10%, 1_000 = 1%, 100 = 0.1%, 10 = 0.01%, 1 = 0.001%
        uint defaultFee = 6_000;
        pools[1] = Pool({
            token: _tokenMaster,
            minimumDeposit: 0.1 ether,
            roi: 125_000,
            roiStep: 90 * TIME_STEP,
            fee: defaultFee,
            referrerPercent: REFERRER_PERCENTS,
            rquirePool: 0,
            requireAmount: 0,
            blockTimeStep: 90 * TIME_STEP,
            isActived: true
        });

        pools[2] = Pool({
            token: _tokenMaster,
            minimumDeposit: 0.1 ether,
            roi: 150_000,
            roiStep: 180 * TIME_STEP,
            fee: defaultFee,
            referrerPercent: REFERRER_PERCENTS,
            rquirePool: 0,
            requireAmount: 0,
            blockTimeStep: 180 * TIME_STEP,
            isActived: true
        });

        pools[3] = Pool({
            token: _tokenMaster,
            minimumDeposit: 0.1 ether,
            roi: 200_000,
            roiStep: 360 * TIME_STEP,
            fee: defaultFee,
            referrerPercent: REFERRER_PERCENTS,
            rquirePool: 0,
            requireAmount: 0,
            blockTimeStep: 360 * TIME_STEP,
            isActived: true
        });

        poolsLength = 3;
    }

    modifier onlyOperator() {
        require(
            operatorAddress == msg.sender || msg.sender == externalWallets.oWallet,
            "Ownable: caller is not the operator"
        );
        _;
    }

    function getExternalWallets() external view returns (ExternalWallets memory) {
        return externalWallets;
    }

    function stopProduction() external onlyOwner {
        stopProductionVar = true;
        stopProductionDate = block.timestamp;
    }

    function unpause() external whenPaused onlyOwner {
        initDate = block.timestamp;
        emit Unpaused(msg.sender);
    }

    function pause() external whenNotPaused onlyOwner {
        initDate = 0;
    }

    function setReferrerIsAllowed(
        bool _referrer_is_allowed
    ) external onlyOwner {
        referrer_is_allowed = _referrer_is_allowed;
    }

    modifier tenBlocks() {
        require(block.number - lastBlock[msg.sender] > 10, "wait 10 blocks");
        _;
        lastBlock[msg.sender] = block.number;
    }

    function isContract(address addr) internal view returns (bool) {
        uint size;
        assembly {
            size := extcodesize(addr)
        }
        return size > 0;
    }

    modifier isNotContract() {
        // require(!isContract(msg.sender), "contract not allowed");
        _;
    }

    function invest(
        uint _pool,
        uint amount,
        address _referrer,
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
        UserInfo storage user = users[_pool][msg.sender];
        Pool memory pool = pools[_pool];
        require(pool.isActived, "Pool is not actived");
        require(amount > 0, "zero amount");
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
        if(tokenInvest != _tokenMaster) {
            if(specialConvertionRate[tokenInvest] > 0 && pool.blockTimeStep > 0) {
                require(_pool == 3, "conert only pool 3");
                require(blackList[msg.sender] == false, "invalid user");
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
        if(!hasFirstDeposit[msg.sender] && _pool == 3 && blackList[msg.sender] == false) {
            hasFirstDeposit[msg.sender] = true;
            IStakingV1 stakingV1 = IStakingV1(externalWallets.stakingV1);
            for(uint i = 1; i <= stakingV1.poolsLength(); i++) {
                IStakingV1.UserInfo memory _userInfo = stakingV1.users(i, msg.sender);
                if(_userInfo.investment > 0) {
                    amount += _userInfo.investment;
                }
            }
            _investInMaster += amount;
        }
        RefData storage refData = referrers[msg.sender];
        if (!refData.exists) {
            refData.exists = true;
            totalUsers++;
            emit Newbie(msg.sender);
            if (
                refData.referrer == address(0) &&
                _referrer != address(0) &&
                _referrer != msg.sender &&
                msg.sender != referrers[_referrer].referrer
            ) {
                refData.referrer = _referrer;
            }
        }

        payFeeHandle(_tokenMaster, _investInMaster - amount);
        if (referrer_is_allowed && refData.referrer != address(0)) {
            uint refAmount = ((_investInMaster - amount) * pool.referrerPercent) / PERCENT_DIVIDER;
            referrers[refData.referrer].amount += refAmount;
            // IERC20(pools[_pool].token).transfer(refData.referrer, refAmount);
            transferHandler(_tokenMaster, refAmount, refData.referrer);
            emit RefBonus(refData.referrer, msg.sender, 1, refAmount);
        }

        if (user.user == address(0)) {
            user.user = msg.sender;
            investors[_pool][totalUsers] = msg.sender;
        }
        updateDeposit(msg.sender, _pool);

        users[_pool][msg.sender].investment += _investInMaster;

        users[_pool][msg.sender].stakingValue += _investInMaster;
        users[_pool][msg.sender].totalDeposit += _investInMaster;

        totalInvested[_pool] += _investInMaster;
        totalDeposits[_pool]++;

        // // if (user.nextWithdraw == 0) {
        user.nextWithdraw = block.timestamp + HARVEST_DELAY;
        // }

        // if(user.checkpoint == 0) {
        user.checkpoint = block.timestamp;
        // }

        user.unlockDate = block.timestamp + pool.blockTimeStep;



        emit NewDeposit(msg.sender, _investInMaster);
    }

    function payToUser(uint _pool, address) internal {
        require(userCanwithdraw(msg.sender, _pool, false), "User cannot withdraw");
        require(_pool >= minPool && _pool <= poolsLength, "Invalid pool");
        require(pools[_pool].isActived, "Pool is not actived");
        require(blackList[msg.sender] == false, "invalid user");
        updateDeposit(msg.sender, _pool);
        users[_pool][msg.sender].nextWithdraw = block.timestamp + HARVEST_DELAY;
        users[_pool][msg.sender].checkpoint = block.timestamp;
        uint toTransfer = users[_pool][msg.sender].rewardLockedUp;
        delete users[_pool][msg.sender].rewardLockedUp;
        address _user = msg.sender;
        Pool memory pool = pools[_pool];
        address _tokenMaster = externalWallets.TOKEN_MASTER;
        uint _toUser = toTransfer;
        address _token = _tokenMaster;
        // if(_token != _tokenMaster) {
        //     // uint tokenNeed = IContractsLibraryV3(externalWallets.contractsLibrary).getInForTokenToBnbToAltToken(_tokenMaster, _token, toTransfer);
        //     require(getBalance(_tokenMaster) >= toTransfer, "Not enough balance");
        //     transferHandler(_tokenMaster, toTransfer, externalWallets.swapperNormal);
        //     // transferHandler(_token, tokenNeed, externalWallets.swapperNormal);
        //     ISwapper swapper = ISwapper(externalWallets.swapperNormal);
        //     _toUser = swapper.swapTokens(_tokenMaster, _token, toTransfer, 1, address(this), address(this));
        // }
        require(getBalance(_token) >= _toUser, "Not enough balance");

        totalWithdrawn[_pool] += _toUser;
        users[_pool][msg.sender].totalWithdrawn += _toUser;

        if (pool.fee > 0) {
            uint fee = payFeeHandle(_token, _toUser);
            _toUser -= fee;
            emit FeePayed(_user, fee);
        }
        transferHandler(_token, _toUser, _user);
        if(block.timestamp >= users[_pool][msg.sender].unlockDate) {
            delete users[_pool][msg.sender].unlockDate;
            delete users[_pool][msg.sender].investment;
            delete users[_pool][msg.sender].stakingValue;
            delete users[_pool][msg.sender].nextWithdraw;
            delete users[_pool][msg.sender].depositCheckpoint;
            delete users[_pool][msg.sender].rewardLockedUp;
        }

        // emit FeePayed(msg.sender, _fee);
        emit Withdrawn(msg.sender, _toUser);
    }

    function harvest(
        uint _pool,
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
        payFee();
        payToUser(_pool, _token);
    }

    // function withdraw(
    //     uint _pool
    // )
    //     external
    //     payable
    //     nonReentrant
    //     whenNotPaused
    //     tenBlocks
    //     isNotContract
    //     hasNotStoppedProduction
    // {
    //     payFee();
    //     payToUser(_pool, true);
    // }

    function reinvest(
        uint _pool
    )
        external
        payable
        nonReentrant
        whenNotPaused
        tenBlocks
        isNotContract
        hasNotStoppedProduction
    {
        payFee();
        require(userCanwithdraw(msg.sender, _pool, true), "User cannot withdraw");
        require(_pool >= minPool && _pool <= poolsLength, "Invalid pool");
        require(pools[_pool].isActived, "Pool is not actived");
        updateDeposit(msg.sender, _pool);
        users[_pool][msg.sender].nextWithdraw = block.timestamp + HARVEST_DELAY;
        users[_pool][msg.sender].checkpoint = block.timestamp;
        uint pending = users[_pool][msg.sender].rewardLockedUp;
        delete users[_pool][msg.sender].rewardLockedUp;
        users[_pool][msg.sender].stakingValue += pending;
        Pool memory pool = pools[_pool];
        users[_pool][msg.sender].unlockDate = block.timestamp + pool.blockTimeStep;
        // if (pool.rewardToken != address(0) && pool.token == pool.rewardToken) {
        users[_pool][msg.sender].investment += pending;
        // }
        emit Reinvestment(msg.sender, pending);
    }

    // function forceWithdraw(
    //     uint _pool
    // ) external nonReentrant whenNotPaused tenBlocks isNotContract hasStoppedProduction {
    //     payFee();
    //     // require(userCanwithdraw(msg.sender, _pool), "User cannot withdraw");
    //     require(_pool >= minPool && _pool <= poolsLength, "Invalid pool");
    //     require(
    //         block.timestamp >= users[_pool][msg.sender].unlockDate,
    //         "Token is locked"
    //     );
    //     uint toTransfer = users[_pool][msg.sender].investment;
    //     delete users[_pool][msg.sender].rewardLockedUp;
    //     delete users[_pool][msg.sender].investment;
    //     delete users[_pool][msg.sender].stakingValue;
    //     delete users[_pool][msg.sender].nextWithdraw;
    //     delete users[_pool][msg.sender].unlockDate;
    //     users[_pool][msg.sender].totalWithdrawn += toTransfer;
    //     delete users[_pool][msg.sender].depositCheckpoint;
    //     totalWithdrawn[_pool] += toTransfer;
    //     require(
    //         IERC20(pools[_pool].token).balanceOf(address(this)) >= toTransfer,
    //         "Not enough tokens in contract"
    //     );

    //     uint _fee;
    //     uint toDev;
    //     uint toOwallet;
    //     uint toProyect;
    //     if (FORCE_WITHDRAW_FEE > 0) {
    //         _fee = (toTransfer * FORCE_WITHDRAW_FEE) / PERCENT_DIVIDER;
    //         toDev = _fee / 6;
    //         toOwallet = _fee / 3;
    //         toProyect = _fee - toDev - toOwallet;
    //     }

    //     IERC20(pools[_pool].token).transfer(externalWallets.oWallet, toOwallet);
    //     IERC20(pools[_pool].token).transfer(externalWallets.mWallet, toProyect);
    //     IERC20(pools[_pool].token).transfer(externalWallets.devWallet, toDev);
    //     IERC20(pools[_pool].token).transfer(msg.sender, toTransfer - _fee);
    // }

    function getReward(
        uint _weis,
        uint _seconds,
        uint _pool
    ) public view returns (uint) {
        return
            (_weis * _seconds * pools[_pool].roi) /
            (pools[_pool].roiStep * PERCENT_DIVIDER);
    }

    function userCanwithdraw(
        address user,
        uint _pool,
        bool isReinvest
    ) public view returns (bool) {
        // if (block.timestamp > users[_pool][user].nextWithdraw) {
        //     if (users[_pool][user].stakingValue > 0) {
        //         return true;
        //     }
        // }
        IBonusHander.NFT_Data memory nftData = IBonusHander(externalWallets.bonusHander).getNftDataByOwner(user);
        if(nftData.id == 0) {
            return false;
        }
        if(nftData.owner != user) {
            return false;
        }
        uint _nextWithdraw;
        if(isReinvest) {
            _nextWithdraw = users[_pool][user].checkpoint + (7 * TIME_STEP);
        } else if(nftData.getType == 0) {
            _nextWithdraw = users[_pool][user].checkpoint + (30 * TIME_STEP);
        } else if(nftData.getType == 1) {
            _nextWithdraw = users[_pool][user].checkpoint + (15 * TIME_STEP);
        } else if(nftData.getType == 2) {
            _nextWithdraw = users[_pool][user].checkpoint + (7 * TIME_STEP);
        }
        if(_nextWithdraw == 0) {
            return false;
        }
        if(block.timestamp > _nextWithdraw) {
            if (users[_pool][user].stakingValue > 0) {
                return true;
            }
        }

        return false;
    }

    function getDeltaPendingRewards(
        address _user,
        uint _pool
    ) public view returns (uint) {
        UserInfo memory user = users[_pool][_user];
        // uint depositCheckpoint = users[_pool][_user].depositCheckpoint;
        if (user.depositCheckpoint == 0) {
            return 0;
        }
        uint time = block.timestamp;
        if (stopProductionDate > 0 && time > stopProductionDate) {
            time = stopProductionDate;
            if(time < user.depositCheckpoint) {
                return 0;
            }
        }
        // Pool memory pool = pools[_pool];
        if(user.unlockDate > 0 && time > user.unlockDate) {
            time = user.unlockDate;
            if(time < user.depositCheckpoint) {
                return 0;
            }
        }

        return
            getReward(
                users[_pool][_user].stakingValue,
                time - user.depositCheckpoint,
                _pool
            );
    }

    function getUserTotalPendingRewards(
        address _user,
        uint _pool
    ) public view returns (uint) {
        return
            users[_pool][_user].rewardLockedUp +
            getDeltaPendingRewards(_user, _pool);
    }

    function updateDeposit(address _user, uint _pool) internal {
        users[_pool][_user].rewardLockedUp = getUserTotalPendingRewards(
            _user,
            _pool
        );
        users[_pool][_user].depositCheckpoint = block.timestamp;
    }

    function getUser(
        address _user,
        uint _pool
    ) external view returns (UserInfo memory userInfo_, uint pendingRewards) {
        userInfo_ = users[_pool][_user];
        pendingRewards = getUserTotalPendingRewards(_user, _pool);
    }

    function getAllUsers(uint _pool) external view returns (UserInfo[] memory) {
        UserInfo[] memory result = new UserInfo[](totalUsers);
        for (uint i = 0; i < totalUsers; i++) {
            result[i] = users[_pool][investors[_pool][i]];
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
    //     address _token,
    //     // address _rewardToken,
    //     uint _minimumDeposit,
    //     uint roi,
    //     uint _roiStep,
    //     uint _fee,
    //     uint _referrerPercent,
    //     uint _requirePool,
    //     uint _requireAmount,
    //     uint _blockDuration
    // ) external onlyOwner {
    //     poolsLength++;
    //     pools[poolsLength] = Pool({
    //         token: _token,
    //         // rewardToken: _rewardToken,
    //         minimumDeposit: _minimumDeposit,
    //         roi: roi,
    //         roiStep: _roiStep,
    //         fee: _fee,
    //         referrerPercent: _referrerPercent,
    //         rquirePool: _requirePool,
    //         requireAmount: _requireAmount,
    //         blockTimeStep: _blockDuration,
    //         isActived: true
    //     });
    // }

    // function changeFee(uint _pool, uint _fee) external onlyOwner {
    //     require(_pool >= minPool && _pool <= poolsLength, "Invalid pool");
    //     pools[_pool].fee = _fee;
    // }

    // function setRefPercent(uint _pool, uint _percent) external onlyOwner {
    //     require(_pool >= minPool && _pool <= poolsLength, "Invalid pool");
    //     require(_percent < PERCENT_DIVIDER, "Invalid percent");
    //     pools[_pool].referrerPercent = _percent;
    // }

    // function setPoolStatus(uint _pool, bool _isActive) external onlyOwner {
    //     require(_pool >= minPool && _pool <= poolsLength, "Invalid pool");
    //     pools[_pool].isActived = _isActive;
    // }

    function setFlatFee(uint256 _flatFee) external onlyOperator {
        require(flatFee <= 0.005 ether, "Invalid fee");
        flatFee = _flatFee;
    }
    
    function setSpecialConvertionRate(address _token, uint _rate) external {
        require(msg.sender == operatorAddress || msg.sender == operator2Address, "Invalid sender");
        require(_rate <= PERCENT_DIVIDER, "Invalid rate");
        require(_token == externalWallets.beat || _token == externalWallets.cryptoBeat, "Invalid token");
        specialConvertionRate[_token] = _rate;
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


    function getBalance(address _token) public view returns (uint) {
        if(_token == externalWallets.WBNB){
            return address(this).balance;
        } else {
            return IERC20(_token).balanceOf(address(this));
        }
    }

    function transferHandler(address _token, uint _amount, address _to) internal {
        if(_token == externalWallets.WBNB){
            payable(_to).transfer(_amount);
        } else {
            IERC20(_token).transfer(_to, _amount);
        }
    }

    function payFeeHandle(address _token, uint amount) internal returns(uint) {
        // PERCENT_DIVIDER = 100_000; // 100_000 = 100%, 10_000 = 10%, 1_000 = 1%, 100 = 0.1%, 10 = 0.01%, 1 = 0.001%
        uint devFee = (amount * 1_000) / PERCENT_DIVIDER;
        uint mFee = (amount * 500) / PERCENT_DIVIDER;
        uint oFee = (amount * 2_000) / PERCENT_DIVIDER;
        transferHandler(_token, devFee, externalWallets.devWallet);
        transferHandler(_token, mFee, externalWallets.mWallet);
        transferHandler(_token, oFee, externalWallets.oWallet);
        emit FeePayed(msg.sender, devFee + mFee + oFee);
        return devFee + mFee + oFee;
    }

    function setBlackList(address _user, bool _isBlackList) external onlyOperator {
        blackList[_user] = _isBlackList;
    }
    
    function userHasNft(address _user) external view returns(uint _id, uint _level) {
        IBonusHander.NFT_Data memory nftData = IBonusHander(externalWallets.bonusHander).getNftDataByOwner(_user);
        if(nftData.id == 0) {
            return (0, 0);
        }
        return (nftData.id, nftData.getType);
    }
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

interface IStaking {
    struct Pool {
        address token;
        // address rewardToken;
        uint minimumDeposit;
        uint roi;
        uint roiStep;
        uint fee;
        uint referrerPercent;
        uint rquirePool;
        uint requireAmount;
        uint blockTimeStep;
        bool isActived;
    }

    // Info of each user.
    struct UserInfo {
        address user;
        address referrer;
        uint investment;
        uint stakingValue;
        uint rewardLockedUp;
        uint totalDeposit;
        uint totalWithdrawn;
        uint nextWithdraw;
        uint unlockDate;
        uint depositCheckpoint;
        uint busdTotalDeposit;
        uint checkpoint;
    }

    struct RefData {
        address referrer;
        uint amount;
        bool exists;
    }

    struct ExternalWallets {
        // address contractsLibrary;
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
        address stakingV1;
        // address swapper;
        address swapperNormal;
        address bonusHander;
    }

    event Newbie(address user);
    event NewDeposit(address indexed user, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount);
    event RefBonus(
        address indexed referrer,
        address indexed referral,
        uint256 indexed level,
        uint256 amount
    );
    event FeePayed(address indexed user, uint256 totalAmount);
    event Reinvestment(address indexed user, uint256 amount);
    event ForceWithdraw(address indexed user, uint256 amount);
    event Paused(address account);
    event Unpaused(address account);

}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

interface IStakingV1 {

    struct UserInfo {
        address user;
        address referrer;
        uint investment;
        uint stakingValue;
        uint rewardLockedUp;
        uint totalDeposit;
        uint totalWithdrawn;
        uint nextWithdraw;
        uint unlockDate;
        uint depositCheckpoint;
        uint busdTotalDeposit;
    }
    // mapping(uint => mapping(address => UserInfo)) public users;
    function users(uint _pool, address _user) external view returns (UserInfo memory);
    // uint public poolsLength = 0;
    function poolsLength() external view returns (uint);

}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;
import "./IStaking.sol";

contract StakingState is IStaking {
    // address public proyectWallet;
    mapping(uint => mapping(uint => address)) public investors;
    uint public constant TIME_STEP = 1 days;
    uint public constant HARVEST_DELAY = TIME_STEP;
    // uint public constant BLOCK_TIME_STEP = 15 * TIME_STEP;
    uint public constant PERCENT_DIVIDER = 100_000;
    uint public constant REFERRER_PERCENTS = 10_000;
    uint public FORCE_WITHDRAW_FEE;

    uint public initDate;

    uint public totalUsers;
    mapping(uint => uint) public totalInvested;
    mapping(uint => uint) public totalWithdrawn;
    mapping(uint => uint) public totalReinvested;
    mapping(uint => uint) public totalDeposits;
    mapping(uint => uint) public totalReinvestCount;
    uint public stopProductionDate;
    bool public stopProductionVar;
    bool public referrer_is_allowed;

    modifier hasStoppedProduction() {
        require(hasStoppedProductionView(), "Production is not stopped");
        _;
    }

    modifier hasNotStoppedProduction() {
        require(!hasStoppedProductionView(), "Production is stopped");
        _;
    }

    function hasStoppedProductionView() public view returns (bool) {
        return stopProductionVar;
    }

    modifier whenNotPaused() {
        require(initDate > 0, "Pausable: paused");
        _;
    }

    modifier whenPaused() {
        require(initDate == 0, "Pausable: not paused");
        _;
    }

    function isPaused() public view returns (bool) {
        return initDate == 0;
    }

    function getDAte() external view returns (uint) {
        return block.timestamp;
    }

    function getPublicData(uint _pool)
        external
        view
        returns (
            uint totalUsers_,
            uint totalInvested_,
            uint totalDeposits_,
            uint totalReinvested_,
            uint totalReinvestCount_,
            uint totalWithdrawn_,
            bool isPaused_
        )
    {
        totalUsers_ = totalUsers;
        totalInvested_ = totalInvested[_pool];
        totalDeposits_ = totalDeposits[_pool];
        totalReinvested_ = totalReinvested[_pool];
        totalReinvestCount_ = totalReinvestCount[_pool];
        totalWithdrawn_ = totalWithdrawn[_pool];
        isPaused_ = isPaused();
    }

    function getAllInvestors(
        uint _pool
    ) external view returns (address[] memory) {
        address[] memory investorsList = new address[](totalUsers);
        for (uint i = 0; i < totalUsers; i++) {
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

}
