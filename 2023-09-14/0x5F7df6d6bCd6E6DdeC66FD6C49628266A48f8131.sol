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
// OpenZeppelin Contracts (last updated v4.8.0) (security/ReentrancyGuard.sol)

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

pragma solidity 0.8.19;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import {IERC20} from "../interfaces/IERC20.sol";

/**
 * @title P33rEscrowV1
 * @author Jasper Gabriel
 * @dev P33R escrow contract; handles deposits, withdrawals, and refunds.
 * @notice This version is intended as a MVP. Originally derived from OpenZeppelin.
 *
 * OpenZeppelin Intended usage: This contract (and derived escrow contracts) should be a
 * standalone contract, that only interacts with the contract that instantiated
 * it. That way, it is guaranteed that all Ether will be handled according to
 * the `Escrow` rules, and there is no need to check for payable functions or
 * transfers in the inheritance tree. The contract that uses the escrow as its
 * payment method should be its owner, and provide public methods redirecting
 * to the escrow's deposit and withdraw.
 */
contract P33rEscrowV1 is Ownable, ReentrancyGuard {
    // REVIEW: Set maximum limit (shouldn't exceed 100%) and check computations
    uint256 public immutable _fee;

    // For future consideration: add _transactionsOf?
    mapping(bytes32 => Transaction) public _transactions;

    // ERC20 fee balance
    mapping(address => uint256) public _feeBalance;

    // REVIEW: "packing structs"
    struct Transaction {
        address depositor;
        address token;
        uint256 amount;
        TransactionStatus status;
    }

    enum TransactionStatus {
        PENDING,
        SUCCESS,
        FAILED,
        WITHDRAWN,
        REFUNDED
    }

    event Deposited(
        bytes32 indexed referenceId,
        address indexed depositor,
        address token,
        uint256 amount,
        TransactionStatus status
    );

    event Withdrawn(
        bytes32 indexed referenceId,
        address indexed recipient,
        address token,
        uint256 amount,
        TransactionStatus status
    );

    event Refunded(
        bytes32 indexed referenceId,
        address indexed depositor,
        address token,
        uint256 amount,
        TransactionStatus status
    );

    event WithdrawnFee(
        address indexed recipient,
        address token,
        uint256 amount
    );

    event TransactionStatusUpdated(
        bytes32 indexed referenceId,
        TransactionStatus status
    );

    event Fallback(address indexed depositor, uint256 amount);

    error InvalidAmount();

    constructor(uint256 fee) {
        _fee = fee;
    }

    /**
     * @dev Invalid transaction status. Current transaction status is `current`,
     * but required status to be `required`.
     *
     * @param current current status of transaction.
     * @param required required status of transaction.
     */
    error InvalidTransactionStatus(
        TransactionStatus current,
        TransactionStatus required
    );

    /**
     * @dev Deposits the sent token amount and creates a transaction.
     *
     * @param referenceId The reference id of the transaction.
     * @param depositor The source address of the funds.
     * @param token The address of specified ERC20 token.
     * @param amount The amount of specified ERC20 token in wei.
     *
     * Emits a {Deposited} event.
     */
    function deposit(
        bytes32 referenceId,
        address depositor,
        address token,
        uint256 amount
    ) external onlyOwner nonReentrant {
        if (amount == 0) revert InvalidAmount();

        _transactions[referenceId] = Transaction(
            depositor,
            token,
            amount,
            TransactionStatus.PENDING
        );

        IERC20(token).transferFrom(depositor, address(this), amount);

        emit Deposited(
            referenceId,
            depositor,
            token,
            amount,
            TransactionStatus.PENDING
        );
    }

    /**
     * @dev Withdraws transaction token amount for a recipient, forwarding all gas to the
     * recipient.
     *
     * WARNING: Forwarding all gas opens the door to reentrancy vulnerabilities.
     * Make sure you trust the recipient, or are either following the
     * checks-effects-interactions pattern or using {ReentrancyGuard}.
     *
     * @param referenceId The reference id of the transaction.
     * @param recipient The address whose funds will be withdrawn and transferred to.
     *
     * Emits a {Withdrawn} event.
     */
    function withdraw(
        bytes32 referenceId,
        address recipient
    ) external onlyOwner nonReentrant {
        Transaction storage transaction = _transactions[referenceId];

        if (transaction.status != TransactionStatus.SUCCESS)
            revert InvalidTransactionStatus(
                transaction.status,
                TransactionStatus.SUCCESS
            );

        // Withdraw depositor balance minus fees
        uint256 fee = (transaction.amount * _fee) / 100;
        uint256 withdrawnAmount = transaction.amount - fee;
        address token = transaction.token;

        _feeBalance[token] += fee;
        transaction.amount = 0;
        updateTransactionStatus(referenceId, TransactionStatus.WITHDRAWN);

        IERC20(token).transfer(recipient, withdrawnAmount);

        emit Withdrawn(
            referenceId,
            recipient,
            token,
            withdrawnAmount,
            TransactionStatus.WITHDRAWN
        );
    }

    /**
     * @dev Refund transaction token amount for depositor.
     *
     * @param referenceId The reference id of the transaction.
     *
     * Emits a {Refunded} event.
     */
    function refund(bytes32 referenceId) external onlyOwner nonReentrant {
        Transaction storage transaction = _transactions[referenceId];

        if (transaction.status != TransactionStatus.FAILED)
            revert InvalidTransactionStatus(
                transaction.status,
                TransactionStatus.FAILED
            );

        address depositor = transaction.depositor;
        address token = transaction.token;
        uint256 refundedAmount = transaction.amount;

        transaction.amount = 0;
        updateTransactionStatus(referenceId, TransactionStatus.REFUNDED);

        IERC20(token).transfer(depositor, refundedAmount);

        emit Refunded(
            referenceId,
            depositor,
            token,
            refundedAmount,
            TransactionStatus.REFUNDED
        );
    }

    /**
     * @dev Withdraws accumulated fee for a token.
     *
     * @param recipient The source address of the funds.
     * @param token The address of specified ERC20 token.
     *
     * Emits a {WithdrawnFee} event.
     */
    function withdrawFee(
        address recipient,
        address token
    ) external onlyOwner nonReentrant {
        uint256 amount = _feeBalance[token];

        _feeBalance[token] = 0;

        IERC20(token).transfer(recipient, amount);

        emit WithdrawnFee(recipient, token, amount);
    }

    /**
     * @dev Updates status of transaction.
     *
     * @param referenceId The reference id of the transaction.
     * @param status The status of the transaction.
     *
     * Emits a {TransactionStatusUpdated} event.
     */
    function updateTransactionStatus(
        bytes32 referenceId,
        TransactionStatus status
    ) public onlyOwner {
        _transactions[referenceId].status = status;

        emit TransactionStatusUpdated(referenceId, status);
    }

    // REVIEW: consider fallback functions and ways to rescue unintended ERC20 transfers...
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

// https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v3.0.0/contracts/token/ERC20/IERC20.sol
interface IERC20 {
    function totalSupply() external view returns (uint);

    function balanceOf(address account) external view returns (uint);

    function transfer(address recipient, uint amount) external returns (bool);

    function allowance(
        address owner,
        address spender
    ) external view returns (uint);

    function approve(address spender, uint amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
}
