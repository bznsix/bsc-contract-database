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
// OpenZeppelin Contracts (last updated v4.9.0) (access/Ownable2Step.sol)

pragma solidity ^0.8.0;

import "./Ownable.sol";

/**
 * @dev Contract module which provides access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership} and {acceptOwnership}.
 *
 * This module is used through inheritance. It will make available all functions
 * from parent (Ownable).
 */
abstract contract Ownable2Step is Ownable {
    address private _pendingOwner;

    event OwnershipTransferStarted(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Returns the address of the pending owner.
     */
    function pendingOwner() public view virtual returns (address) {
        return _pendingOwner;
    }

    /**
     * @dev Starts the ownership transfer of the contract to a new account. Replaces the pending transfer if there is one.
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual override onlyOwner {
        _pendingOwner = newOwner;
        emit OwnershipTransferStarted(owner(), newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`) and deletes any pending owner.
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual override {
        delete _pendingOwner;
        super._transferOwnership(newOwner);
    }

    /**
     * @dev The new owner accepts the ownership transfer.
     */
    function acceptOwnership() public virtual {
        address sender = _msgSender();
        require(pendingOwner() == sender, "Ownable2Step: caller is not the new owner");
        _transferOwnership(sender);
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
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable2Step.sol";

/// @title a PaymentReceiver contract for handling payments for off-chain Prefice submissions
/// @author UNCX Network
/// @dev Inherits the OpenZeppelin Ownable2Step for access controls
contract PaymentReceiver is Ownable2Step {

    /// @notice The address where all fee payments should be sent
    address public feeAddress;

    /// @notice The expected fee amount for each type of payment token
    mapping(address => uint256) public expectedFeeAmounts;

    /// @notice This event is emitted when payment occurs
    /// @param sender The sender address
    /// @param tokenAddress The payment token contract address
    /// @param feeAmount The fee amount paid
    /// @param submissionId The ID used to track the submission, to track if payment has been made
    event PaymentReceived(address sender, address tokenAddress, uint256 feeAmount, bytes32 submissionId);

    /// @notice This event is emitted when payment fees are updated for a token
    /// @param tokenAddress The payment token contract address the fee changed for
    /// @param feeAmount The new fee amount
    event PaymentFeeUpdated(address tokenAddress, uint256 feeAmount);

    /// @notice Create and configure a new PaymentReceiver contract
    /// @param _feeAddress The initial fee address to send fee payments to
    constructor(address _feeAddress) {
        feeAddress = _feeAddress;
    }

    /// @notice Handles the payment for the off-chain prefice submission
    /// @dev Accepts payment in ETH or supported ERC20 tokens and sends to the feeAddress
    /// @dev Zero address is used to specify intention to pay in ETH
    /// @dev Tokens with a fee of 0 will not be accepted
    /// @param tokenAddress The contract address of the token used for payment
    /// @param submissionId The ID of the off-chain submission, to track if payment has been made
    function pay(address tokenAddress, bytes32 submissionId) external payable {
        require(expectedFeeAmounts[tokenAddress] > 0, "Invalid fee token");

        if (tokenAddress == address(0)) {
            require(msg.value == expectedFeeAmounts[tokenAddress], "Incorrect ETH sent");
            payable(feeAddress).transfer(msg.value);
        } else {
            IERC20(tokenAddress).transferFrom(msg.sender, feeAddress, expectedFeeAmounts[tokenAddress]);
        }

        emit PaymentReceived(msg.sender, tokenAddress, expectedFeeAmounts[tokenAddress], submissionId);
    }

    /// @notice Updates the expected fee for the specified payment token
    /// @dev Settings a tokens fee to 0 disables payment in that token
    /// @param tokenAddress The token contract address to update fee settings for
    /// @param feeAmount The new fee amount for the specified token
    function updateFee(address tokenAddress, uint256 feeAmount) external onlyOwner {
        expectedFeeAmounts[tokenAddress] = feeAmount;
        emit PaymentFeeUpdated(tokenAddress, feeAmount);
    }

    /// @notice Update the fee address where the pay method sends fees
    /// @param _feeAddress The new fee address to update with
    function updateFeeAddress(address _feeAddress) external onlyOwner {
        feeAddress = _feeAddress;
    }

    /// @notice Function for admin to withdraw ETH or ERC20 tokens mistakenly sent to contract
    /// @dev Zero address is used to specify intention to withdraw ETH
    /// @param tokenAddress Address of token intended to withdraw. Zero address for ETH
    /// @param receiver Address to send withdrawn tokens to
    function withdrawTokens(address tokenAddress, address receiver) external onlyOwner {
        if (tokenAddress == address(0)) {
            payable(receiver).transfer(address(this).balance);
        } else {
            uint256 tokenBalance = IERC20(tokenAddress).balanceOf(address(this));
            IERC20(tokenAddress).transfer(receiver, tokenBalance);
        }
    }

    fallback() external payable {}
}