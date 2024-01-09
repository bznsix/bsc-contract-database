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
// OpenZeppelin Contracts (last updated v4.9.4) (utils/Context.sol)

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

    function _contextSuffixLength() internal view virtual returns (uint256) {
        return 0;
    }
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/security/Pausable.sol";

contract IDO is Ownable, Pausable {
    uint256 public totalLocked;
    address public revenueWallet;

    // Struct to store pool information
    struct PoolInfo {
        uint256 softCap;
        uint256 hardCap;
        uint256 startTime;
        uint256 finishTime;
        IERC20[] paymentCurrencies;
        uint256 price;
        uint256 soldAmount;
        bool status; // 0: inactive, 1: active
    }

    // Admin management
    mapping(address => bool) public admin;

    // Whitelist management
    mapping(address => bool) public whitelist;

    // Pool information
    PoolInfo public whitelistPool;

    // Pool information
    PoolInfo public publicPool;

    uint256 public minAmount;
    uint256 public maxAmount;

    mapping(address => uint256) private _whitelistLocked;
    mapping(address => uint256) private _publicLocked;

    uint256 private _totalAllocation;
    mapping(address => uint256) private _allocated;
    mapping(address => uint256) private _minAllocation;
    mapping(address => uint256) private _remainingAllocation;

    // Token IDO (to be distributed after IDO ends)
    IERC20 public idoToken;

    // Events
    event PoolCreated(
        address indexed admin,
        uint256 startTime,
        uint256 finishTime
    );
    event PoolUpdated(
        address indexed admin,
        uint256 softCap,
        uint256 hardCap,
        uint256 startTime,
        uint256 finishTime
    );
    event TokenPurchased(
        address indexed user,
        uint256 purchaseValue,
        uint256 buyAmount,
        IERC20 paymentCurrency
    );

    modifier onlyAdmin() {
        require(admin[_msgSender()], "You are not an admin");
        _;
    }

    modifier onlyWhitelister() {
        require(whitelist[_msgSender()], "Not in whitelist");
        _;
    }

    constructor(address _revenueWallet) {
        admin[_msgSender()] = true;
        revenueWallet = _revenueWallet;
    }

    function setAdmin(
        address[] calldata users,
        bool remove
    ) external onlyOwner whenNotPaused {
        for (uint256 i = 0; i < users.length; i++) {
            admin[users[i]] = !remove;
        }
    }

    function setRevenueWallet(address user) external onlyOwner {
        revenueWallet = user;
    }

    function setAllocations(
        address[] calldata users,
        uint256[] calldata minAllocations,
        uint256[] calldata maxAllocations
    ) external onlyAdmin {
        require(users.length > 0, "Wrong parameters");
        require(users.length == maxAllocations.length, "Wrong parameters");

        for (uint16 i = 0; i < users.length; i++) {
            whitelist[users[i]] = true;
            uint256 minted = _allocated[users[i]] -
                _remainingAllocation[users[i]];
            require(
                minted <= maxAllocations[i],
                "Minted is greater than allocation"
            );
            require(
                minAllocations[i] <= maxAllocations[i],
                "Min allocation must be less than or equal to max allocation"
            );
            _totalAllocation -= _allocated[users[i]];
            _allocated[users[i]] = maxAllocations[i];
            _minAllocation[users[i]] = minAllocations[i];
            _remainingAllocation[users[i]] = maxAllocations[i] - minted;
            _totalAllocation += maxAllocations[i];
        }
    }

    function setStatusPublicPool(bool status) external onlyAdmin whenNotPaused {
        require(publicPool.startTime > 0, "Invalid pool");

        publicPool.status = status;
    }

    function setStatusWhitelistPool(
        bool status
    ) external onlyAdmin whenNotPaused {
        require(whitelistPool.startTime > 0, "Invalid pool");

        whitelistPool.status = status;
    }

    function createOrUpdateWhitelistPoolInfo(
        uint256 softCap,
        uint256 hardCap,
        uint256 startTime,
        uint256 finishTime,
        IERC20[] calldata paymentCurrencies,
        uint256 price
    ) external onlyAdmin whenNotPaused {
        require(finishTime > startTime, "Finish time must be after start time");
        require(
            finishTime > block.timestamp,
            "Finish time must be after current time"
        );
        require(hardCap > 0, "Hard cap must be greater than 0");
        require(
            softCap <= hardCap,
            "Soft cap must be less than or equal to hard cap"
        );
        require(price > 0, "Price must be greater than 0");

        if (whitelistPool.startTime == 0) {
            require(
                startTime > block.timestamp,
                "Start time must be in the future"
            );

            whitelistPool = PoolInfo({
                softCap: softCap,
                hardCap: hardCap,
                startTime: startTime,
                finishTime: finishTime,
                paymentCurrencies: paymentCurrencies,
                price: price,
                soldAmount: whitelistPool.soldAmount,
                status: true
            });
            emit PoolUpdated(
                _msgSender(),
                softCap,
                hardCap,
                startTime,
                finishTime
            );
        } else if (whitelistPool.startTime > block.timestamp) {
            whitelistPool.softCap = softCap;
            whitelistPool.hardCap = hardCap;
            whitelistPool.startTime = startTime;
            whitelistPool.finishTime = finishTime;
            whitelistPool.paymentCurrencies = paymentCurrencies;
            whitelistPool.price = price;
            emit PoolUpdated(
                _msgSender(),
                softCap,
                hardCap,
                startTime,
                finishTime
            );
        } else {
            require(
                whitelistPool.finishTime > block.timestamp,
                "Cannot update ended pool"
            );
            require(
                hardCap > whitelistPool.soldAmount,
                "Hard cap should be more than sold amount"
            );
            whitelistPool.hardCap = hardCap;
            whitelistPool.finishTime = finishTime;
            emit PoolUpdated(
                _msgSender(),
                whitelistPool.softCap,
                hardCap,
                whitelistPool.startTime,
                finishTime
            );
        }
    }

    function createOrUpdatePublicPoolInfo(
        uint256 softCap,
        uint256 hardCap,
        uint256 startTime,
        uint256 finishTime,
        IERC20[] calldata paymentCurrencies,
        uint256 price
    ) external onlyAdmin whenNotPaused {
        require(finishTime > startTime, "Finish time must be after start time");
        require(
            finishTime > block.timestamp,
            "Finish time must be after current time"
        );
        require(hardCap > 0, "Hard cap must be greater than 0");
        require(
            softCap <= hardCap,
            "Soft cap must be less than or equal to hard cap"
        );
        require(price > 0, "Price must be greater than 0");

        if (publicPool.startTime == 0) {
            require(
                startTime > block.timestamp,
                "Start time must be in the future"
            );
            publicPool = PoolInfo({
                softCap: softCap,
                hardCap: hardCap,
                startTime: startTime,
                finishTime: finishTime,
                paymentCurrencies: paymentCurrencies,
                price: price,
                soldAmount: publicPool.soldAmount,
                status: true
            });
            emit PoolUpdated(
                _msgSender(),
                softCap,
                hardCap,
                startTime,
                finishTime
            );
        } else if (publicPool.startTime > block.timestamp) {
            publicPool.softCap = softCap;
            publicPool.hardCap = hardCap;
            publicPool.startTime = startTime;
            publicPool.finishTime = finishTime;
            publicPool.paymentCurrencies = paymentCurrencies;
            publicPool.price = price;
            emit PoolUpdated(
                _msgSender(),
                softCap,
                hardCap,
                startTime,
                finishTime
            );
        } else {
            require(
                publicPool.finishTime > block.timestamp,
                "Cannot update ended pool"
            );
            require(
                hardCap > publicPool.soldAmount,
                "Hard cap should be more than sold amount"
            );
            publicPool.hardCap = hardCap;
            publicPool.finishTime = finishTime;
            emit PoolUpdated(
                _msgSender(),
                publicPool.softCap,
                hardCap,
                publicPool.startTime,
                finishTime
            );
        }
    }

    function whitelistBuy(
        uint256 purchaseValue,
        IERC20 paymentCurrency
    ) external whenNotPaused {
        require(whitelistPool.startTime > 0, "Invalid pool");
        require(whitelistPool.status == true, "Inactive pool");
        require(whitelist[_msgSender()], "You are not a whitelister");
        require(purchaseValue > 0, "Purchase value must be greater than 0");
        require(
            block.timestamp >= whitelistPool.startTime,
            "Can not participate"
        );
        require(
            block.timestamp < whitelistPool.finishTime,
            "Can not participate"
        );

        uint256 buyAmount = (purchaseValue * 10 ** 18) / whitelistPool.price;
        require(
            whitelistPool.soldAmount + buyAmount <= whitelistPool.hardCap,
            "Exceeds the hard cap"
        );
        require(
            isPaymentCurrencyAllowedWhitelistPool(paymentCurrency),
            "PaymentCurrency not allowed"
        );
        require(
            _remainingAllocation[_msgSender()] >= buyAmount,
            "You do not have any allocations"
        );
        require(
            _allocated[_msgSender()] -
                _remainingAllocation[_msgSender()] +
                buyAmount >=
                _minAllocation[_msgSender()],
            "You should buy more than min allocation"
        );
        require(
            IERC20(paymentCurrency).allowance(_msgSender(), address(this)) >=
                purchaseValue,
            "Token allowance too low"
        );

        IERC20(paymentCurrency).transferFrom(
            _msgSender(),
            revenueWallet,
            purchaseValue
        );

        _whitelistLocked[_msgSender()] += buyAmount;
        totalLocked += buyAmount;
        whitelistPool.soldAmount += buyAmount;
        _remainingAllocation[_msgSender()] -= buyAmount;

        emit TokenPurchased(
            _msgSender(),
            purchaseValue,
            buyAmount,
            IERC20(paymentCurrency)
        );
    }

    function buy(
        uint256 purchaseValue,
        address paymentCurrency
    ) external whenNotPaused {
        require(publicPool.startTime > 0, "Invalid pool");
        require(publicPool.status == true, "Inactive pool");
        require(purchaseValue > 0, "Purchase value must be greater than 0");
        require(block.timestamp >= publicPool.startTime, "Can not participate");
        require(block.timestamp < publicPool.finishTime, "Can not participate");

        uint256 buyAmount = (purchaseValue * 10 ** 18) / publicPool.price;
        require(
            publicPool.soldAmount + buyAmount <= publicPool.hardCap,
            "Exceeds the hard cap"
        );
        require(maxAmount > 0, "No value maxAmount");
        require(
            buyAmount >= minAmount && buyAmount <= maxAmount,
            "Amount out of range"
        );

        require(
            IERC20(paymentCurrency).allowance(_msgSender(), address(this)) >=
                purchaseValue,
            "Token allowance too low"
        );

        IERC20(paymentCurrency).transferFrom(
            _msgSender(),
            revenueWallet,
            purchaseValue
        );

        _publicLocked[_msgSender()] += buyAmount;
        totalLocked += buyAmount;
        publicPool.soldAmount += buyAmount;

        emit TokenPurchased(
            _msgSender(),
            purchaseValue,
            buyAmount,
            IERC20(paymentCurrency)
        );
    }

    /* For FE
        1: allocated amount
        2: min allocation amount
        3: remaining allocation amount
        4: whitelist round amount
        5: public round amount
    */
    function infoWallet(
        address user
    ) public view returns (uint256, uint256, uint256, uint256, uint256) {
        return (
            _allocated[user],
            _minAllocation[user],
            _remainingAllocation[user],
            _whitelistLocked[user],
            _publicLocked[user]
        );
    }

    function getWhitelistPoolInfo() external view returns (PoolInfo memory) {
        return whitelistPool;
    }

    function getPublicPoolInfo() external view returns (PoolInfo memory) {
        return publicPool;
    }

    function setMinAmount(uint256 _minAmount) external onlyAdmin whenNotPaused {
        minAmount = _minAmount;
    }

    function setMaxAmount(uint256 _maxAmount) external onlyAdmin whenNotPaused {
        maxAmount = _maxAmount;
    }

    function _safeTransferFrom(
        address _sender,
        address _recipient,
        uint256 _amount,
        address _token
    ) private {
        bool sent = IERC20(_token).transferFrom(_sender, _recipient, _amount);
        require(sent, "Token transfer failed");
    }

    function withdraw(
        address _rewardAddress,
        uint256 _amount,
        address to
    ) external onlyOwner {
        IERC20(_rewardAddress).transfer(to, _amount);
    }

    function pause() external onlyOwner {
        _pause();
    }

    function unpause() external onlyOwner {
        _unpause();
    }

    function isPaymentCurrencyAllowedPublicPool(
        IERC20 paymentCurrency
    ) internal view returns (bool) {
        for (uint256 i = 0; i < publicPool.paymentCurrencies.length; i++) {
            if (publicPool.paymentCurrencies[i] == paymentCurrency) {
                return true;
            }
        }
        return false;
    }

    function isPaymentCurrencyAllowedWhitelistPool(
        IERC20 paymentCurrency
    ) internal view returns (bool) {
        for (uint256 i = 0; i < whitelistPool.paymentCurrencies.length; i++) {
            if (whitelistPool.paymentCurrencies[i] == paymentCurrency) {
                return true;
            }
        }
        return false;
    }
}
