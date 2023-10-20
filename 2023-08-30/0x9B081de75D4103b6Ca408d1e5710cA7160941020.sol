// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/access/Ownable.sol";

import "./interfaces/ITradingFeeClaimedRecord.sol";

contract TradingFeeClaimedRecord is ITradingFeeClaimedRecord, Ownable {

    /// @dev mapping [user][bool]
    mapping(address => bool) public operators;

    /// @dev mapping [user][bool]
    mapping(address => bool) public override hasClaimedRebate;

    /// @dev mapping [user][bool]
    mapping(address => bool) public override hasClaimedTopTraders;

    event OperatorUpdated(address indexed operator, bool enabled);
    event TradingFeeClaimedRebateUpdated(address indexed topTradersExternal);
    event TradingFeeClaimedTopTradersUpdated(address indexed topTradersExternal);

    modifier onlyOperator() {
        require(operators[msg.sender], "caller is not the operator");
        _;
    }

    constructor() {
        // init hasClaimed on rebate
        hasClaimedRebate[address(0)] = true;

        // init hasClaimed on topTraders
        hasClaimedTopTraders[address(0)] = true;
    }

    /// @dev Update operator address in this contract, this is called by owner only
    /// @param _msgSender the address of operator
    function updateOperator(address _msgSender, bool _enabled) external onlyOwner {
        require(operators[_msgSender] != _enabled, "status not change");
        operators[_msgSender] = _enabled;
        emit OperatorUpdated(_msgSender, _enabled);
    }

    /// @dev Update hasClaimed record from rebate contract
    /// @param _msgSender the address of user
    function updateHasClaimedRebate(address _msgSender) external override onlyOperator {
        require(hasClaimedTopTraders[_msgSender] != true, "already claimed in topTraders");
        if (!hasClaimedRebate[_msgSender]) {
            hasClaimedRebate[_msgSender] = true;
            emit TradingFeeClaimedRebateUpdated(_msgSender);
        }
    }

    /// @dev Update hasClaimed record from topTraders contract
    /// @param _msgSender the address of user
    function updateHasClaimedTopTraders(address _msgSender) external override onlyOperator {
        require(hasClaimedRebate[_msgSender] != true, "already claimed in rebate");
        if (!hasClaimedTopTraders[_msgSender]) {
            hasClaimedTopTraders[_msgSender] = true;
            emit TradingFeeClaimedTopTradersUpdated(_msgSender);
        }
    }
}// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

interface ITradingFeeClaimedRecord {
    function hasClaimedRebate(address _msgSender)
        external
        view
        returns (
            bool claimed
        );

    function hasClaimedTopTraders(address _msgSender)
        external
        view
        returns (
            bool claimed
        );

    /// @dev Update hasClaimed record from rebate contract
    /// @param _msgSender the address of user
    function updateHasClaimedRebate(address _msgSender) external;

    /// @dev Update hasClaimed record from topTraders contract
    /// @param _msgSender the address of user
    function updateHasClaimedTopTraders(address _msgSender) external;
}
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
