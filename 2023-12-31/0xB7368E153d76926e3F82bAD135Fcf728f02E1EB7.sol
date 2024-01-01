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
// OpenZeppelin Contracts (last updated v5.0.0) (utils/Context.sol)

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
/**
 *  _____ _____ _____  _______     __
 * |  __ \_   _/ ____|/ ____\ \   / /
 * | |__) || || |  __| |  __ \ \_/ / 
 * |  ___/ | || | |_ | | |_ | \   /  
 * | |    _| || |__| | |__| |  | |   
 * |_|   |_____\_____|\_____|  |_|Coink   
 *                                   
 * https://app.piggycoin.finance/migrate
 */

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

/// @custom:security-contact d3vnull10@gmail.com
contract PiggyMigrate is Ownable, ReentrancyGuard {
  address private _tokenIn;
  address private _tokenOut;

  uint256 private _threshold = 1_000_000;

  mapping(address => bool) private _blacklisted;

  mapping(address => uint) private _migrateDates;
  mapping(address => uint256) private _migrateHolders;

  event Migrate(address indexed account, uint256 amountIn, uint256 amountOut);

  constructor() Ownable(msg.sender){}

  function isBlacklisted() internal view returns (bool) {
    return _blacklisted[msg.sender];
  }

  function hasMigrated() public view returns (bool) {
    return _migrateDates[msg.sender] != 0;
  }

  function hasMigratedOn() public view returns (uint) {
    return _migrateDates[msg.sender];
  }

  function canMigrate() public view returns (bool) {
    return !hasMigrated() && _migrateHolders[msg.sender] >= _threshold && IERC20(_tokenIn).balanceOf(msg.sender) >= _threshold;
  }

  function migrateAmount() public view returns (uint256) {
    return _migrateHolders[msg.sender];
  }

  function migrate(address sender) public payable nonReentrant {
    if(sender == address(0)) sender = msg.sender;
    require(!isBlacklisted(), "PiggyMigrate: you are blacklisted, get outta here!!!!!");
    require(!hasMigrated(), "PiggyMigrate: account already migrated");
    require(canMigrate(), "PiggyMigrate: no tokens found to migrate");

    IERC20 tokenIn = IERC20(_tokenIn);
    IERC20 tokenOut = IERC20(_tokenOut);

    uint256 amount = _migrateHolders[msg.sender];
    uint256 amountOut = amount / 1e3; // ratio 1K:1 $PiggyC to PiggyC

    require(tokenOut.balanceOf(address(this)) >= amountOut, "PiggyMigrate: insuffient tokens to migrate, contact admin");
    
    // migrate
    tokenIn.transferFrom(msg.sender, address(this), amount);
    tokenOut.transfer(sender, amountOut);
    _migrateDates[sender] = block.timestamp;
    _migrateDates[msg.sender] = block.timestamp;

    emit Migrate(sender, amount, amountOut);
  }

  function setThreshold(uint256 threshold) public onlyOwner {
    _threshold = threshold;
  }

  function getHolderInfo(address account) public view onlyOwner returns (uint, uint256){
    return (
      _migrateDates[account], _migrateHolders[account] // Token migrate date and balance
    );
  }

  function transferTokensOut(address tokenAddress, uint256 amount) public onlyOwner {
    require(tokenAddress == _tokenIn || tokenAddress == _tokenOut, "PiggyMigrate: not a vaild token address");
    _transferTokens(tokenAddress, amount);
  }

  function setTokens(address tokenIn, address tokenOut) public onlyOwner {
    require(address(tokenIn) != address(0), "PiggyMigrate: tokenIn is the zero address");
    require(address(tokenOut) != address(0), "PiggyMigrate: tokenOut is the zero address");
    _tokenIn = tokenIn;
    _tokenOut = tokenOut;
  }

  function setMigrateHolders(address[] memory holders, uint[] memory balances) external onlyOwner {
    require(holders.length == balances.length, "PiggyMigrate: arrays dont match");
    for(uint i = 0; i < holders.length; i++) _migrateHolders[holders[i]] = balances[i];
  }

  function resetMigrateHolder(address holder, uint balance) public onlyOwner {
    _migrateHolders[holder] = balance;
    _migrateDates[holder] = 0;// reset date to be able to migrate again
  }

  function setBlacklisted(address account, bool blacklisted) public onlyOwner {
    _blacklisted[account] = blacklisted;
  }

  /**
   * @dev implementations could hold tokens and this method is responsible 
   * for transferring those tokens out to the caller wallet
   */
  function _transferTokens(address token, uint256 amount) internal {
    require(IERC20(token).balanceOf(address(this)) >= amount, "PiggyMigrate: insufficient balance");
    IERC20(token).transfer(msg.sender, amount);
  }
}
