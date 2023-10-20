// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

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
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
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
// OpenZeppelin Contracts v4.4.1 (security/Pausable.sol)

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
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns (bool) {
        return _paused;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        require(!paused(), "Pausable: paused");
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
        require(paused(), "Pausable: not paused");
        _;
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
// OpenZeppelin Contracts v4.4.1 (security/ReentrancyGuard.sol)

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
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

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
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

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
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Address.sol)

pragma solidity ^0.8.0;

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verifies that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason using the provided one.
     *
     * _Available since v4.3._
     */
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
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
//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Escrow is ReentrancyGuard, Pausable, Ownable {
    using Address for address payable;

    // Events
    // ---------------------------------------------------

    // Event emitted when a new deposit is made
    event Deposited(
        string depositId,
        address indexed tokenAddress,
        uint256 amount,
        uint256 feeAmount,
        address indexed receiver,
        address indexed sender,
        uint256 timestamp
    );

    // Event emitted when a deposit is transferred
    event DepositTransferred(
        string depositId,
        uint256 amount,
        address indexed receiver,
        uint256 timestamp
    );

    // Event emitted when a deposit is transferred by owner
    event DepositTransferredByOwner(
        string depositId,
        uint256 amount,
        address indexed receiver,
        uint256 timestamp
    );

    // Event emitted when a deposit is cancelled
    event DepositCancelled(
        string depositId,
        uint256 amount,
        address indexed receiver,
        uint256 timestamp
    );

    // Event emitted when a new payment is made
    event Paid(
        string paymentId,
        address indexed tokenAddress,
        uint256 amount,
        address indexed sender,
        uint256 timestamp
    );

    // Variables
    // ---------------------------------------------------

    // Mapping from deposit ID to deposit amount in wei
    mapping(string => uint256) private _depositsAmount;

    // Mapping from deposit ID to deposit fee in wei
    mapping(string => uint256) private _depositsFee;

    // Mapping from deposit ID to deposit sender
    mapping(string => address) private _depositsSenders;

    // Mapping from deposit ID to deposit receiver
    mapping(string => address) private _depositsReceivers;

    // Mapping from deposit ID to deposit token address
    // Applicable for ERC20 deposits
    mapping(string => address) private _depositsToken;

    // Mapping from payment ID to payment amount in wei
    mapping(string => uint256) private _paymentsAmount;

    // Mapping from payment ID to payment sender
    mapping(string => address) private _paymentsSenders;

    // Mapping from payment ID to payment token address
    // Applicable for ERC20 payments
    mapping(string => address) private _paymentsToken;

    // Address that collects fees
    address payable feeCollector;

    // Constructor of the NonCustodial Escrow Contract
    // The constructor is a special function that gets called when the contract is created.
    // It takes the _feeCollector address as an input parameter.
    // The _feeCollector is the address that will collect the fees from the transactions in this contract.
    // The payable keyword allows this address to receive and hold ethers.
    constructor(address _feeCollector) {
        feeCollector = payable(_feeCollector);
    }

    // The deposit function is used to deposit ether into the NonCustodial Escrow Contract.
    // This function can only be called when the contract is not paused and ensures no reentrancy attacks.
    // Inputs:
    // - receiver: The address which will be allowed to withdraw the deposit.
    // - feeAmount: The amount of fee that will be deducted from the deposit.
    // - depositId: A unique identifier for the deposit.
    function deposit(
        address receiver,
        uint256 feeAmount,
        string memory depositId
    ) public payable whenNotPaused nonReentrant {
        // Checks if the deposit with the given depositId has already been created.
        // If so, the function will be terminated and the transaction will be rolled back.
        require(_depositsAmount[depositId] == 0, "Deposit already created");
        // Checks if the receiver's address is valid. It shouldn't be a zero address.
        require(receiver != address(0x0), "Invalid receiver");
        // Deducts the feeAmount from the total value sent with the transaction.
        // The remaining value is the actual deposit amount.
        uint256 amount = msg.value - feeAmount;
        // Checks if the calculated amount is greater than zero.
        require(amount > 0, "Invalid amount");
        // Stores the deposit amount mapped with the depositId.
        _depositsAmount[depositId] = amount;
        // Stores the fee amount mapped with the depositId.
        _depositsFee[depositId] = feeAmount;
        // Stores the sender's address mapped with the depositId.
        _depositsSenders[depositId] = msg.sender;
        // Stores the receiver's address mapped with the depositId.
        _depositsReceivers[depositId] = receiver;
        // Emits an event for the deposit with all the details.
        emit Deposited(
            depositId,
            address(0x0),
            amount,
            feeAmount,
            receiver,
            msg.sender,
            block.timestamp
        );
    }

    // The transferDeposit function is used to transfer the deposited amount to the receiver.
    // This function can only be called when the contract is not paused and ensures no reentrancy attacks.
    // Input:
    // - depositId: The unique identifier of the deposit which will be transferred.
    function transferDeposit(
        string memory depositId
    ) public whenNotPaused nonReentrant {
        // Checks if the sender of this function call is the one who created the deposit.
        // If not, the function will be terminated and the transaction will be rolled back.
        require(
            _depositsSenders[depositId] == msg.sender,
            "Only the owner of deposit can transfer"
        );
        // Checks if the deposit amount associated with the given depositId is greater than zero.
        // If not, it assumes that the deposit has already been transferred.
        require(_depositsAmount[depositId] > 0, "Deposit already transferred");

        // Retrieves the deposit amount for the provided depositId.
        uint256 amount = _depositsAmount[depositId];

        // Retrieves the receiver's address for the provided depositId and makes it payable.
        address payable receiver = payable(_depositsReceivers[depositId]);

        // Sets the deposit amount for the provided depositId to zero, indicating that it's been transferred.
        _depositsAmount[depositId] = 0;

        // Checks if there is a fee associated with the deposit.
        if (_depositsFee[depositId] > 0) {
            // If yes, then transfers the fee to the feeCollector.
            feeCollector.sendValue(_depositsFee[depositId]);
        }

        // Transfers the deposit amount to the receiver.
        receiver.sendValue(amount);

        // Emits an event for the transferred deposit with all the details.
        emit DepositTransferred(depositId, amount, receiver, block.timestamp);
    }

    // The cancelDeposit function is used to allow the receiver of a deposit to cancel it.
    // This function can only be called when the contract is not paused and ensures no reentrancy attacks.
    // Input:
    // - depositId: The unique identifier of the deposit which will be cancelled.
    function cancelDeposit(
        string memory depositId
    ) public whenNotPaused nonReentrant {
        // Checks if the sender of this function call is the one who is supposed to receive the deposit.
        // If not, the function will be terminated and the transaction will be rolled back.
        require(
            _depositsReceivers[depositId] == msg.sender,
            "Only the receiver of deposit can cancel"
        );
        // Checks if the deposit amount associated with the given depositId is greater than zero.
        // If not, it assumes that the deposit has already been transferred.
        require(_depositsAmount[depositId] > 0, "Deposit already transferred");

        // Retrieves the deposit amount for the provided depositId.
        uint256 amount = _depositsAmount[depositId];

        // Retrieves the original sender's address for the provided depositId and makes it payable.
        address payable receiver = payable(_depositsSenders[depositId]);

        // Sets the deposit amount for the provided depositId to zero, indicating that it's been cancelled.
        _depositsAmount[depositId] = 0;

        // Transfers the deposit amount back to the original sender including the fee amount if any.
        receiver.sendValue(amount + _depositsFee[depositId]);

        // Emits an event for the transferred deposit with all the details.
        emit DepositTransferred(depositId, amount, receiver, block.timestamp);

        // Emits an event for the cancelled deposit with all the details.
        emit DepositCancelled(depositId, amount, receiver, block.timestamp);
    }

    // The depositErc20 function is used to deposit ERC20 tokens into the escrow contract.
    // This function can only be called when the contract is not paused and ensures no reentrancy attacks.
    // Inputs:
    // - receiver: The address of the entity intended to receive the deposit.
    // - token: The address of the ERC20 token being deposited.
    // - amount: The amount of the ERC20 tokens being deposited.
    // - feeAmount: The amount of the ERC20 tokens being used as a fee.
    // - depositId: The unique identifier of the deposit.
    function depositErc20(
        address receiver,
        address token,
        uint256 amount,
        uint256 feeAmount,
        string memory depositId
    ) public whenNotPaused nonReentrant {
        // Checks if the deposit associated with the given depositId is already created.
        // If yes, the function will be terminated and the transaction will be rolled back.
        require(_depositsAmount[depositId] == 0, "Deposit already created");
        // Checks if the amount of tokens to be deposited is valid i.e., it should be greater than zero.
        require(amount > 0, "Invalid amount");
        // Checks if the receiver's address is valid.
        require(receiver != address(0x0), "Invalid receiver");

        // Initializes the ERC20 token contract interface with the provided token's address.
        IERC20 Token = IERC20(token);

        // Transfers the specified amount of tokens from the sender to this contract.
        // The sender needs to approve this contract to spend tokens on their behalf before calling this function.
        bool isTokenTransferred = Token.transferFrom(
            msg.sender,
            address(this),
            amount
        );

        // Checks if the tokens have been successfully transferred.
        require(isTokenTransferred, "Tokens are not transferred.");

        // Stores the deposit amount (total amount minus fee), sender's address, receiver's address,
        // fee amount and token's address associated with the given depositId in the contract's storage.
        _depositsAmount[depositId] = amount - feeAmount;
        _depositsFee[depositId] = feeAmount;
        _depositsSenders[depositId] = msg.sender;
        _depositsReceivers[depositId] = receiver;
        _depositsToken[depositId] = token;

        // Emits an event with the details of the deposit.
        emit Deposited(
            depositId,
            token,
            amount,
            feeAmount,
            receiver,
            msg.sender,
            block.timestamp
        );
    }

    // The transferDepositErc20 function is used to transfer the deposited ERC20 tokens from the escrow contract to the receiver.
    // This function can only be called when the contract is not paused and ensures no reentrancy attacks.
    // Input:
    // - depositId: The unique identifier of the deposit.
    function transferDepositErc20(
        string memory depositId
    ) public whenNotPaused nonReentrant {
        // Checks if the sender is the depositor associated with the given depositId.
        // If not, the function will be terminated and the transaction will be rolled back.
        require(
            _depositsSenders[depositId] == msg.sender,
            "Only the owner of deposit can transfer"
        );
        // Checks if the deposit associated with the given depositId has already been transferred.
        // If yes, the function will be terminated and the transaction will be rolled back.
        require(_depositsAmount[depositId] > 0, "Deposit already transferred");
        // Checks if the deposited token associated with the given depositId is valid.
        require(
            _depositsToken[depositId] != address(0x0),
            "Invalid ERC20 token"
        );

        uint256 amount = _depositsAmount[depositId];

        // Sets the deposit amount associated with the given depositId to zero in the contract's storage.
        _depositsAmount[depositId] = 0;

        // Initializes the ERC20 token contract interface with the deposited token's address.
        IERC20 Token = IERC20(_depositsToken[depositId]);

        // Checks if the fee associated with the given depositId is greater than zero.
        // If yes, it transfers the fee from this contract to the fee collector.
        if (_depositsFee[depositId] > 0) {
            bool isTokenFeeTransferred = Token.transfer(
                payable(feeCollector),
                _depositsFee[depositId]
            );

            // Checks if the fee has been successfully transferred.
            require(isTokenFeeTransferred, "Fee is not transferred.");
        }

        // Transfers the deposited tokens from this contract to the receiver.
        bool isTokenTransferred = Token.transfer(
            payable(_depositsReceivers[depositId]),
            amount
        );

        // Checks if the tokens have been successfully transferred.
        require(isTokenTransferred, "Tokens are not transferred.");

        // Emits an event with the details of the deposit transfer.
        emit DepositTransferred(
            depositId,
            amount,
            _depositsReceivers[depositId],
            block.timestamp
        );
    }

    // The cancelDepositErc20 function is used to cancel the deposit of ERC20 tokens in the escrow contract and refund them to the depositor.
    // This function can only be called when the contract is not paused and ensures no reentrancy attacks.
    // Input:
    // - depositId: The unique identifier of the deposit.
    function cancelDepositErc20(
        string memory depositId
    ) public whenNotPaused nonReentrant {
        // Checks if the sender is the receiver associated with the given depositId.
        // If not, the function will be terminated and the transaction will be rolled back.
        require(
            _depositsReceivers[depositId] == msg.sender,
            "Only the receiver of deposit can cancel"
        );
        // Checks if the deposit associated with the given depositId has already been transferred.
        // If yes, the function will be terminated and the transaction will be rolled back.
        require(_depositsAmount[depositId] > 0, "Deposit already transferred");
        // Checks if the deposited token associated with the given depositId is valid.
        require(
            _depositsToken[depositId] != address(0x0),
            "Invalid ERC20 token"
        );

        uint256 amount = _depositsAmount[depositId];

        // Sets the deposit amount associated with the given depositId to zero in the contract's storage.
        _depositsAmount[depositId] = 0;

        // Initializes the ERC20 token contract interface with the deposited token's address.
        IERC20 Token = IERC20(_depositsToken[depositId]);

        // Transfers the deposited tokens along with the fee from this contract back to the depositor.
        bool isTokenTransferred = Token.transfer(
            payable(_depositsSenders[depositId]),
            amount + _depositsFee[depositId]
        );

        // Checks if the tokens have been successfully transferred.
        require(isTokenTransferred, "Tokens are not transferred.");

        // Emits an event with the details of the deposit transfer.
        emit DepositTransferred(
            depositId,
            amount,
            _depositsSenders[depositId],
            block.timestamp
        );
        // Emits an event with the details of the deposit cancellation.
        emit DepositCancelled(
            depositId,
            amount,
            _depositsSenders[depositId],
            block.timestamp
        );
    }

    // The transferDepositByOwner function is used by the contract owner to transfer the deposit to a receiver.
    // The owner can choose to transfer the deposit with or without the fee.
    // This function can only be called by the contract owner and ensures no reentrancy attacks.
    // Input:
    // - depositId: The unique identifier of the deposit.
    // - receiver: The address that will receive the transfer.
    // - withFee: A boolean indicating whether the transfer should include the deposit fee.
    function transferDepositByOwner(
        string memory depositId,
        address receiver,
        bool withFee
    ) public onlyOwner nonReentrant {
        // Checks if the deposit associated with the given depositId has already been transferred.
        // If yes, the function will be terminated and the transaction will be rolled back.
        require(_depositsAmount[depositId] > 0, "Deposit already transferred");

        // Checks if the receiver is the depositor or the originally intended receiver.
        // If not, the function will be terminated and the transaction will be rolled back.
        require(
            receiver == _depositsSenders[depositId] ||
                receiver == _depositsReceivers[depositId],
            "Receiver is neither the deposit creator or the final receiver."
        );

        uint256 amount = _depositsAmount[depositId];

        // Convert the receiver address into a payable address.
        address payable receiverPayable = payable(receiver);

        // Sets the deposit amount associated with the given depositId to zero in the contract's storage.
        _depositsAmount[depositId] = 0;

        uint256 finalAmount = amount;

        // If the 'withFee' is true, then add the fee to the final amount to be transferred.
        // If not, send the fee to the feeCollector address.
        if (withFee) {
            finalAmount = finalAmount + _depositsFee[depositId];
        } else {
            feeCollector.sendValue(_depositsFee[depositId]);
        }

        // Transfers the final amount to the receiver.
        receiverPayable.sendValue(finalAmount);

        // Emits an event with the details of the deposit transfer.
        emit DepositTransferred(depositId, amount, receiver, block.timestamp);
        // Emits an event with the details of the deposit transfer by the owner.
        emit DepositTransferredByOwner(
            depositId,
            amount,
            receiver,
            block.timestamp
        );
    }

    // The transferDepositErc20ByOwner function is used by the contract owner to transfer the deposit of ERC20 tokens to a receiver.
    // The owner can choose to transfer the deposit with or without the fee.
    // This function can only be called by the contract owner and ensures no reentrancy attacks.
    // Input:
    // - depositId: The unique identifier of the deposit.
    // - receiver: The address that will receive the transfer.
    // - withFee: A boolean indicating whether the transfer should include the deposit fee.
    function transferDepositErc20ByOwner(
        string memory depositId,
        address receiver,
        bool withFee
    ) public onlyOwner nonReentrant {
        // Checks if the deposit associated with the given depositId has already been transferred.
        // If yes, the function will be terminated and the transaction will be rolled back.
        require(_depositsAmount[depositId] > 0, "Deposit already transferred");

        // Checks if the deposit associated with the given depositId involves ERC20 tokens.
        // If not, the function will be terminated and the transaction will be rolled back.
        require(
            _depositsToken[depositId] != address(0x0),
            "Invalid ERC20 token"
        );

        // Checks if the receiver is the depositor or the originally intended receiver.
        // If not, the function will be terminated and the transaction will be rolled back.
        require(
            receiver == _depositsSenders[depositId] ||
                receiver == _depositsReceivers[depositId],
            "Receiver is neither the deposit creator or the final receiver."
        );

        uint256 amount = _depositsAmount[depositId];

        // Sets the deposit amount associated with the given depositId to zero in the contract's storage.
        _depositsAmount[depositId] = 0;

        // Creates an instance of the ERC20 token contract associated with the depositId.
        IERC20 Token = IERC20(_depositsToken[depositId]);

        uint256 finalAmount = amount;

        // If the 'withFee' is true, then add the fee to the final amount to be transferred.
        // If not, and if the fee amount is greater than zero, then transfer the fee to the feeCollector address.
        if (withFee) {
            finalAmount = finalAmount + _depositsFee[depositId];
        } else {
            if (_depositsFee[depositId] > 0) {
                bool isTokenFeeTransferred = Token.transfer(
                    payable(feeCollector),
                    _depositsFee[depositId]
                );

                require(isTokenFeeTransferred, "Fee is not transferred.");
            }
        }

        // Transfers the final amount of ERC20 tokens to the receiver.
        bool isTokenTransferred = Token.transfer(
            payable(receiver),
            finalAmount
        );

        // Checks if the tokens have been successfully transferred.
        // If not, the function will be terminated and the transaction will be rolled back.
        require(isTokenTransferred, "Tokens are not transferred.");

        // Emits an event with the details of the deposit transfer.
        emit DepositTransferred(depositId, amount, receiver, block.timestamp);
        // Emits an event with the details of the deposit transfer by the owner.
        emit DepositTransferredByOwner(
            depositId,
            amount,
            receiver,
            block.timestamp
        );
    }

    // The `payment` function allows for the creation and execution of a payment in one operation.
    // This function is protected against reentrancy attacks and can only be executed when the contract is not paused.
    // Input:
    // - paymentId: The unique identifier for the payment.
    function payment(
        string memory paymentId
    ) public payable whenNotPaused nonReentrant {
        // Checks if a payment with the same ID has already been created.
        // If yes, the function will be terminated and the transaction will be rolled back.
        require(_paymentsAmount[paymentId] == 0, "Payment already created");

        // The value of the payment is obtained from the special `msg.value` variable.
        uint256 amount = msg.value;

        // Checks if the value of the payment is greater than zero.
        // If not, the function will be terminated and the transaction will be rolled back.
        require(amount > 0, "Invalid amount");

        // Transfers the value of the payment to the feeCollector.
        feeCollector.sendValue(amount);

        // Stores the value of the payment in the `_paymentsAmount` mapping using `paymentId` as the key.
        _paymentsAmount[paymentId] = amount;

        // Stores the address of the sender (payer) in the `_paymentsSenders` mapping using `paymentId` as the key.
        _paymentsSenders[paymentId] = msg.sender;

        // Emits an event to log that the payment has been made.
        emit Paid(paymentId, address(0x0), amount, msg.sender, block.timestamp);
    }

    // The `paymentErc20` function allows for the creation and execution of a payment in ERC20 tokens in one operation.
    // This function is protected against reentrancy attacks and can only be executed when the contract is not paused.
    // Input:
    // - token: The contract address of the ERC20 token to be transferred.
    // - amount: The amount of the ERC20 token to be transferred.
    // - paymentId: The unique identifier for the payment.
    function paymentErc20(
        address token,
        uint256 amount,
        string memory paymentId
    ) public whenNotPaused nonReentrant {
        // Checks if a payment with the same ID has already been created.
        // If yes, the function will be terminated and the transaction will be rolled back.
        require(_paymentsAmount[paymentId] == 0, "Payment already created");

        // Checks if the amount of the payment is greater than zero.
        // If not, the function will be terminated and the transaction will be rolled back.
        require(amount > 0, "Invalid amount");

        // Initializes an instance of the ERC20 token contract.
        IERC20 Token = IERC20(token);

        // Tries to transfer the specified amount of tokens from the sender's (payer's) account to the `feeCollector`.
        // The function will fail if the sender has not enough tokens or has not approved the transfer.
        bool isTokenTransferred = Token.transferFrom(
            msg.sender,
            feeCollector,
            amount
        );

        // Checks if the token transfer was successful.
        // If not, the function will be terminated and the transaction will be rolled back.
        require(isTokenTransferred, "Tokens are not transferred.");

        // Stores the value of the payment in the `_paymentsAmount` mapping using `paymentId` as the key.
        _paymentsAmount[paymentId] = amount;

        // Stores the address of the sender (payer) in the `_paymentsSenders` mapping using `paymentId` as the key.
        _paymentsSenders[paymentId] = msg.sender;

        // Stores the contract address of the ERC20 token in the `_paymentsToken` mapping using `paymentId` as the key.
        _paymentsToken[paymentId] = token;

        // Emits an event to log that the payment has been made.
        emit Paid(paymentId, token, amount, msg.sender, block.timestamp);
    }
}
