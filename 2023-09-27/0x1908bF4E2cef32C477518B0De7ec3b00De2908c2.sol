// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.18;

import {IMultiplierTracker} from "../interfaces/IMultiplierTracker.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

interface IUniswapV2Pair {
    function token0() external view returns (address);
    function getReserves() external view returns (uint112 _reserve0, uint112 _reserve1, uint32 _blockTimestampLast);
    function totalSupply() external view returns (uint112 _totalSupply);
}

/**
 * @title MultiplierTracker
 * @author LevelFinance
 * @notice Track the relative rate between LVL_USDT_LP and LVL token, calculated by the number of LVL used to mint 1 LP
 */
contract MultiplierTracker is IMultiplierTracker, Ownable {
    uint256 public constant UPDATE_INTERVAL = 1 hours;
    uint256 public constant UPDATE_TIMEOUT = 1.5 hours;
    uint256 public constant EPOCH_DURATION = 7 days;
    uint256 public constant EPOCH_TIMEOUT = 8 days;
    uint256 public constant MULTIPLIER_PRECISION = 1e6;

    IUniswapV2Pair public LVL_USDT_PAIR;
    address public LVL;

    uint256 public lastValue;
    uint256 public lastEpochValue;
    uint256 public accumulateValue;

    uint256 public lastUpdateTime;
    uint256 public lastEpochTime;

    uint256 public multiplier;
    uint256 public epochUpdateCount;
    address public updater;

    constructor(address _lvl, address _pair, uint256 _multiplier) {
        if (_lvl == address(0)) revert ZeroAddress();
        if (_pair == address(0)) revert ZeroAddress();
        LVL = _lvl;
        LVL_USDT_PAIR = IUniswapV2Pair(_pair);
        _setMultiplier(_multiplier);
    }

    // =============== VIEW FUNCTIONS ===============
    function getVestingMultiplier() external view returns (uint256) {
        if (block.timestamp >= lastUpdateTime + UPDATE_TIMEOUT) revert Outdated();
        return lastValue * multiplier / MULTIPLIER_PRECISION;
    }

    function getStakingMultiplier() external view returns (uint256) {
        if (block.timestamp >= lastEpochTime + EPOCH_TIMEOUT) revert Outdated();
        return lastEpochValue * multiplier / MULTIPLIER_PRECISION;
    }

    // =============== USER FUNCTIONS ===============
    function update() external {
        if (msg.sender != updater && msg.sender != owner()) revert Unauthorized();
        if (lastUpdateTime == 0) revert NotStarted();
        uint256 _now = block.timestamp;
        if (_now < lastUpdateTime + UPDATE_INTERVAL) revert TooEarlyForUpdate();
        uint256 _currentValue = _getCurrentValue();
        accumulateValue += _currentValue;
        lastValue = _currentValue;
        lastUpdateTime = _now;
        epochUpdateCount++;

        // start new epoch
        if (_now >= lastEpochTime + EPOCH_DURATION) {
            lastEpochValue = accumulateValue / epochUpdateCount;
            // round to nearest epoch time
            lastEpochTime += (_now - lastEpochTime) / EPOCH_DURATION * EPOCH_DURATION;
            accumulateValue = _currentValue;
            epochUpdateCount = 1;
            emit EpochFinished(lastEpochValue);
        }

        emit ValueUpdated(_currentValue);
    }

    function start() external onlyOwner {
        if (lastUpdateTime == 0) {
            uint256 _now = block.timestamp;
            uint256 _currentValue = _getCurrentValue();
            lastValue = _currentValue;
            accumulateValue = _currentValue;
            epochUpdateCount = 1;
            lastUpdateTime = _now;
            lastEpochTime = _now;
            emit ValueUpdated(_currentValue);
        }
    }

    // =============== RESTRICTED ===============
    function setUpdater(address _updater) external onlyOwner {
        if (_updater == address(0)) revert ZeroAddress();
        updater = _updater;
        emit UpdaterSet(_updater);
    }

    function setMultiplier(uint256 _multiplier) external onlyOwner {
        _setMultiplier(_multiplier);
    }

    // =============== INTERNAL FUNCTIONS ===============
    function _getCurrentValue() internal view returns (uint256) {
        address _token0 = LVL_USDT_PAIR.token0();
        (uint256 _reserve0, uint256 _reserve1,) = LVL_USDT_PAIR.getReserves();
        uint256 _lvlBalance = LVL == _token0 ? _reserve0 : _reserve1;
        uint256 _lpTotalSupply = LVL_USDT_PAIR.totalSupply();
        // simplified since LVL and LP share the same decimals of 18
        return _lvlBalance * MULTIPLIER_PRECISION / _lpTotalSupply;
    }

    function _setMultiplier(uint256 _multiplier) internal {
        if (_multiplier < MULTIPLIER_PRECISION) revert MultiplierTooLow();
        multiplier = _multiplier;
        emit MultiplierSet(_multiplier);
    }

    // =============== ERRORS ===============
    error ZeroAddress();
    error NotStarted();
    error Outdated();
    error Unauthorized();
    error TooEarlyForUpdate();
    error MultiplierTooLow();

    // =============== EVENTS ===============
    event UpdaterSet(address _updater);
    event MultiplierSet(uint256 _multiplier);
    event ValueUpdated(uint256 _value);
    event EpochFinished(uint256 _value);
}
// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

interface IMultiplierTracker {
    function getVestingMultiplier() external view returns (uint256);
    function getStakingMultiplier() external view returns (uint256);
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
