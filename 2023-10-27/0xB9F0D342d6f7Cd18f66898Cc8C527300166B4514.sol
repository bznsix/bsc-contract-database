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
// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.19;

import "./IBanList.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract BanList is Ownable, IBanList {
    mapping(address => bool) public admins;

    mapping(address => bool) private _list;

    modifier restricted() {
        if (!admins[_msgSender()]) revert Unauthorized();
        _;
    }

    function ban(address user) external restricted {
        if (_list[user]) revert AlreadyBanned();
        _list[user] = true;
        emit UserBanned(user);
    }

    function unban(address user) external restricted {
        if (!_list[user]) revert NotBanned();
        _list[user] = false;
        emit UserUnbanned(user);
    }

    function setAdmin(address admin, bool isAdmin) external onlyOwner {
        if (admin == address(0)) revert ZeroAddress();
        _list[admin] = isAdmin;
        emit AdminSet(admin, isAdmin);
    }

    function isBanned(address user) external view returns (bool) {
        return _list[user];
    }

    function isNotBanned(address user) external view returns (bool) {
        return !_list[user];
    }

    function check(address user) external view {
        if (_list[user]) revert UserIsBanned();
    }
}
// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.19;

interface IBanList {
    event UserBanned(address indexed user);
    event UserUnbanned(address indexed user);
    event AdminSet(address indexed admin, bool indexed isAdmin);

    error AlreadyBanned();
    error ZeroAddress();
    error NotBanned();
    error Unauthorized();
    error UserIsBanned();

    function isBanned(address user) external view returns (bool);

    function isNotBanned(address user) external view returns (bool);

    function check(address user) external view;
}
