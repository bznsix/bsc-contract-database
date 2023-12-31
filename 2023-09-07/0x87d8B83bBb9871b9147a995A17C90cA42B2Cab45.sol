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
// OpenZeppelin Contracts (last updated v4.9.0) (security/ReentrancyGuard.sol)

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

    /**
     * @dev Returns true if the reentrancy guard is currently set to "entered", which indicates there is a
     * `nonReentrant` function in the call stack.
     */
    function _reentrancyGuardEntered() internal view returns (bool) {
        return _status == _ENTERED;
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (token/ERC20/extensions/IERC20Permit.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 Permit extension allowing approvals to be made via signatures, as defined in
 * https://eips.ethereum.org/EIPS/eip-2612[EIP-2612].
 *
 * Adds the {permit} method, which can be used to change an account's ERC20 allowance (see {IERC20-allowance}) by
 * presenting a message signed by the account. By not relying on {IERC20-approve}, the token holder account doesn't
 * need to send a transaction, and thus is not required to hold Ether at all.
 */
interface IERC20Permit {
    /**
     * @dev Sets `value` as the allowance of `spender` over ``owner``'s tokens,
     * given ``owner``'s signed approval.
     *
     * IMPORTANT: The same issues {IERC20-approve} has related to transaction
     * ordering also apply here.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `deadline` must be a timestamp in the future.
     * - `v`, `r` and `s` must be a valid `secp256k1` signature from `owner`
     * over the EIP712-formatted function arguments.
     * - the signature must use ``owner``'s current nonce (see {nonces}).
     *
     * For more information on the signature format, see the
     * https://eips.ethereum.org/EIPS/eip-2612#specification[relevant EIP
     * section].
     */
    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    /**
     * @dev Returns the current nonce for `owner`. This value must be
     * included whenever a signature is generated for {permit}.
     *
     * Every successful call to {permit} increases ``owner``'s nonce by one. This
     * prevents a signature from being used multiple times.
     */
    function nonces(address owner) external view returns (uint256);

    /**
     * @dev Returns the domain separator used in the encoding of the signature for {permit}, as defined by {EIP712}.
     */
    // solhint-disable-next-line func-name-mixedcase
    function DOMAIN_SEPARATOR() external view returns (bytes32);
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
// OpenZeppelin Contracts (last updated v4.9.3) (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";
import "../extensions/IERC20Permit.sol";
import "../../../utils/Address.sol";

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    using Address for address;

    /**
     * @dev Transfer `value` amount of `token` from the calling contract to `to`. If `token` returns no value,
     * non-reverting calls are assumed to be successful.
     */
    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    /**
     * @dev Transfer `value` amount of `token` from `from` to `to`, spending the approval given by `from` to the
     * calling contract. If `token` returns no value, non-reverting calls are assumed to be successful.
     */
    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(IERC20 token, address spender, uint256 value) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    /**
     * @dev Increase the calling contract's allowance toward `spender` by `value`. If `token` returns no value,
     * non-reverting calls are assumed to be successful.
     */
    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 oldAllowance = token.allowance(address(this), spender);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, oldAllowance + value));
    }

    /**
     * @dev Decrease the calling contract's allowance toward `spender` by `value`. If `token` returns no value,
     * non-reverting calls are assumed to be successful.
     */
    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, oldAllowance - value));
        }
    }

    /**
     * @dev Set the calling contract's allowance toward `spender` to `value`. If `token` returns no value,
     * non-reverting calls are assumed to be successful. Meant to be used with tokens that require the approval
     * to be set to zero before setting it to a non-zero value, such as USDT.
     */
    function forceApprove(IERC20 token, address spender, uint256 value) internal {
        bytes memory approvalCall = abi.encodeWithSelector(token.approve.selector, spender, value);

        if (!_callOptionalReturnBool(token, approvalCall)) {
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, 0));
            _callOptionalReturn(token, approvalCall);
        }
    }

    /**
     * @dev Use a ERC-2612 signature to set the `owner` approval toward `spender` on `token`.
     * Revert on invalid signature.
     */
    function safePermit(
        IERC20Permit token,
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal {
        uint256 nonceBefore = token.nonces(owner);
        token.permit(owner, spender, value, deadline, v, r, s);
        uint256 nonceAfter = token.nonces(owner);
        require(nonceAfter == nonceBefore + 1, "SafeERC20: permit did not succeed");
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address-functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        require(returndata.length == 0 || abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     *
     * This is a variant of {_callOptionalReturn} that silents catches all reverts and returns a bool instead.
     */
    function _callOptionalReturnBool(IERC20 token, bytes memory data) private returns (bool) {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We cannot use {Address-functionCall} here since this should return false
        // and not revert is the subcall reverts.

        (bool success, bytes memory returndata) = address(token).call(data);
        return
            success && (returndata.length == 0 || abi.decode(returndata, (bool))) && Address.isContract(address(token));
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (utils/Address.sol)

pragma solidity ^0.8.1;

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
     *
     * Furthermore, `isContract` will also return true if the target contract within
     * the same transaction is already scheduled for destruction by `SELFDESTRUCT`,
     * which only has an effect at the end of a transaction.
     * ====
     *
     * [IMPORTANT]
     * ====
     * You shouldn't rely on `isContract` to protect against flash loan attacks!
     *
     * Preventing calls from contracts is highly discouraged. It breaks composability, breaks support for smart wallets
     * like Gnosis Safe, and does not provide security since it can be circumvented by calling from a contract
     * constructor.
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.

        return account.code.length > 0;
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
     * https://consensys.net/diligence/blog/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.8.0/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
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
        return functionCallWithValue(target, data, 0, "Address: low-level call failed");
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
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
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
        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
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
        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
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
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verify that a low level call to smart-contract was successful, and revert (either by bubbling
     * the revert reason or using the provided one) in case of unsuccessful call or if target was not a contract.
     *
     * _Available since v4.8._
     */
    function verifyCallResultFromTarget(
        address target,
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        if (success) {
            if (returndata.length == 0) {
                // only check isContract if the call was successful and the return data is empty
                // otherwise we already know that it was a contract
                require(isContract(target), "Address: call to non-contract");
            }
            return returndata;
        } else {
            _revert(returndata, errorMessage);
        }
    }

    /**
     * @dev Tool to verify that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason or using the provided one.
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
            _revert(returndata, errorMessage);
        }
    }

    function _revert(bytes memory returndata, string memory errorMessage) private pure {
        // Look for revert reason and bubble it up if present
        if (returndata.length > 0) {
            // The easiest way to bubble the revert reason is using memory via assembly
            /// @solidity memory-safe-assembly
            assembly {
                let returndata_size := mload(returndata)
                revert(add(32, returndata), returndata_size)
            }
        } else {
            revert(errorMessage);
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
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface AggregatorV3Interface {
    function decimals() external view returns (uint8);

    function description() external view returns (string memory);

    function version() external view returns (uint256);

    function getRoundData(
        uint80 _roundId
    ) external view returns (uint80 roundId, int256 answer, uint256 startedAt, uint256 updatedAt, uint80 answeredInRound);

    function latestRoundData()
    external
    view
    returns (uint80 roundId, int256 answer, uint256 startedAt, uint256 updatedAt, uint80 answeredInRound);
}
//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface INorawinPresale {
    function buyTokens(IERC20 _token, uint256 numberOfTokens, address referrer) external payable;

    function claimTokens() external;

    function claimAvailable() external view returns (uint256);

    function paymentMethods() external view returns (address[] memory);

    function tokensAvailableByPhase(uint256 phase) external view returns (uint256);

    function getCurrentPhase() external view returns (uint256);

    function checkPrice(IERC20 paymentToken, uint256 numberOfTokens) external view returns (uint256);
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {Address} from "@openzeppelin/contracts/utils/Address.sol";

import "./interfaces/INorawinPresale.sol";
import "./interfaces/AggregatorV3Interface.sol";

contract NorawinPresale is INorawinPresale, Ownable, ReentrancyGuard {
    using SafeERC20 for IERC20;

    using Address for address payable;

    // NWIN BEP20 contract
    IERC20 public immutable NWIN;

    // Norawin treasury address
    address public immutable treasury;

    // Unixtime when presale starts/ends
    uint256 public startTime;
    uint256 public endTime = 0;

    // Duration of vesting (seconds)
    uint256 public vestingDuration;

    // Current phase
    uint256 public currentPhase = 0;

    // Total number of tokens sold for each phase
    uint256[8] public tokensSoldPerPhase;

    // Number of tokens bought by address
    mapping(address => uint256) public tokensBought;

    // Number of tokens claimed by address
    mapping(address => uint256) public claimedTokens;

    // Token caps amount per each phase
    uint256[] public caps = new uint256[](8);

    // Token price in USD for each phase
    uint256[8] public tokenPrices;

    // BEP20 address
    mapping(address => AggregatorV3Interface) public paymentTokenToPriceFeed;

    // Supported payment methods
    address[] public supportedPaymentMethods;

    // Checking supported payment method by address
    mapping(address => bool) public isSupportedPaymentMethod;

    // Events
    event TokensBought(address indexed buyer, address indexed paymentToken, uint256 numberOfTokens, address indexed referrer);
    event TokensClaimed(address indexed claimer, uint256 numberOfTokens);

    /**
    * @param _nwin NWIN BEP20 contract
    * @param _startTime Unix time when presale starts
    * @param _vestingDuration Duration in seconds of vesting after the end of the presale
    * @param _treasury Treasury address where funds are sent
    * @param _caps The total number of tokens available for presale at each phase
    */
    constructor(
        IERC20 _nwin,
        uint256 _startTime,
        uint256 _vestingDuration,
        address _treasury,
        uint256[] memory _caps
    ) {
        require(_startTime >= block.timestamp, "Presale cannot start in the past");
        require(_caps.length == 8, "Caps array must contain 8 phases");

        NWIN = _nwin;
        startTime = _startTime;
        vestingDuration = _vestingDuration;
        treasury = _treasury;
        caps = _caps;
    }

    /**
     * @notice Called when sale is active
     * @param paymentToken address of payment method
     * @param numberOfTokens number of tokens to buying
     * @param referrer referrer address
     */
    function buyTokens(
        IERC20 paymentToken,
        uint256 numberOfTokens,
        address referrer
    ) external payable whenSaleIsActive nonReentrant {
        if (msg.value > 0) {
            require(address(paymentToken) == address(0), "Cannot have both BNB and BEP20 payment");

            // Check numberOfTokens don't exceed current cap
            if (numberOfTokens + tokensSoldPerPhase[currentPhase] > caps[currentPhase]) {
                numberOfTokens = caps[currentPhase] - tokensSoldPerPhase[currentPhase];
            }

            // Payment in BNB
            uint256 cost = getCost(paymentToken, numberOfTokens);
            require(msg.value >= cost, "Not enough BNB sent");

            _buyTokens(numberOfTokens, referrer);

            (bool sent,) = payable(treasury).call{value : cost}("");
            require(sent, "Failed to send BNB");

            uint256 remainder = msg.value - cost;

            if (remainder > 0) {
                (sent,) = payable(msg.sender).call{value : remainder}("");
                require(sent, "Failed to refund extra BNB");
            }
        } else {
            // Payment in BEP20
            uint256 cost = getCost(paymentToken, numberOfTokens);
            require(
                paymentToken.allowance(msg.sender, address(this)) >= cost,
                "Not enough allowance"
            );

            _buyTokens(numberOfTokens, referrer);
            paymentToken.safeTransferFrom(msg.sender, treasury, cost);
        }

        // Emit event
        emit TokensBought(
            msg.sender,
            address(paymentToken),
            numberOfTokens,
            referrer
        );
    }

    function _buyTokens(uint256 numberOfTokens, address referrer) internal {
        tokensBought[msg.sender] += numberOfTokens;
        tokensSoldPerPhase[currentPhase] += numberOfTokens;

        // Check if we have to give a bonus to referrer
        if (referrer != address(0)) {
            require(referrer != msg.sender, "You cannot refer yourself");
            uint256 bonusTokens = (numberOfTokens * 5) / 100;

            // Check bonusTokens don't exceed current cap
            if (bonusTokens + tokensSoldPerPhase[currentPhase] > caps[currentPhase]) {
                bonusTokens = caps[currentPhase] - tokensSoldPerPhase[currentPhase];
            }

            tokensBought[referrer] += bonusTokens;
            tokensSoldPerPhase[currentPhase] += bonusTokens;
        }

        // Checking if current phase has been completed
        if (tokensSoldPerPhase[currentPhase] >= caps[currentPhase]) {
            // Go to next phase
            ++currentPhase;
        }

        // Checking if we completed last phase
        if (currentPhase >= caps.length) {
            // Presale is over now
            endTime = block.timestamp;
        }
    }

    /**
     * @notice Transfer the number of tokens that are currently available
     */
    function claimTokens() external nonReentrant {
        require(endTime != 0, "Presale has not ended");
        require(tokensBought[msg.sender] > claimedTokens[msg.sender], "No unclaimed tokens available");

        uint256 passedTime = block.timestamp - endTime;
        uint256 releasableTokens;

        if (passedTime >= vestingDuration) {
            // All tokens are releasable after vestingDuration
            releasableTokens = tokensBought[msg.sender];
        } else {
            // 20% released immediately after presale ends
            uint256 immediateRelease = (tokensBought[msg.sender] * 2) / 10;

            // The number of tokens can be released immediately after the presale ends
            uint256 vestedTokens = ((tokensBought[msg.sender] - immediateRelease) * passedTime) / vestingDuration;
            releasableTokens = immediateRelease + vestedTokens;
        }

        uint256 tokensToClaim = releasableTokens - claimedTokens[msg.sender];
        claimedTokens[msg.sender] += tokensToClaim;
        NWIN.safeTransfer(msg.sender, tokensToClaim);

        // Emit event
        emit TokensClaimed(msg.sender, tokensToClaim);
    }

    /**
     * @notice Transfer the number of tokens that can currently be claimed by the user (if any)
     */
    function claimAvailable() external view returns (uint256) {
        if (endTime == 0) {
            return 0;
        }

        uint256 passedTime = block.timestamp - endTime;
        uint256 releasableTokens;

        if (passedTime >= vestingDuration) {
            // All tokens are releasable after vestingDuration
            releasableTokens = tokensBought[msg.sender];
        } else {
            // 20% released immediately after presale ends
            uint256 immediateRelease = (tokensBought[msg.sender] * 2) / 10;

            // The number of tokens can be released immediately after the presale ends
            uint256 vestedTokens = ((tokensBought[msg.sender] - immediateRelease) * passedTime) / vestingDuration;
            releasableTokens = immediateRelease + vestedTokens;
        }

        uint256 tokensToClaim = releasableTokens - claimedTokens[msg.sender];
        return tokensToClaim;
    }

    /**
     * @return list all supported payment methods
     */
    function paymentMethods() external view returns (address[] memory) {
        return supportedPaymentMethods;
    }

    /**
     * @return current phase of the presale
     */
    function getCurrentPhase() external view returns (uint256) {
        if (currentPhase >= 8) {
            return 8;
        }

        return currentPhase + 1;
    }

    /**
     * @return number of tokens available for presale in the given phase
     */
    function tokensAvailableByPhase(uint256 phase) external view returns (uint256) {
        require(phase >= 1 && phase <= 8, "Invalid phase");
        // 0-indexed array
        uint256 phaseIndex = phase - 1;
        return caps[phaseIndex] - tokensSoldPerPhase[phaseIndex];
    }

    /**
     * @param paymentToken the method of payment
     * @param numberOfTokens the number of tokens to buy
     * @return estimated price of buying a given number of tokens by payment method
     */
    function checkPrice(IERC20 paymentToken, uint256 numberOfTokens) external view returns (uint256) {
        return getCost(paymentToken, numberOfTokens);
    }

    /**
     * @notice modifier to check if presale is active
     */
    modifier whenSaleIsActive() {
        require(block.timestamp >= startTime && endTime == 0, "Presale is not active");
        require(currentPhase < 8, "Invalid phase");
        _;
    }

    /**
     * Calculate price of buying a number of tokens (NWIN)
     * @param paymentToken method of payment
     * @param numberOfTokens number of tokens to buy
     */
    function getCost(IERC20 paymentToken, uint256 numberOfTokens) internal view returns (uint256) {
        AggregatorV3Interface dataFeed = paymentTokenToPriceFeed[address(paymentToken)];

        require(address(dataFeed) != address(0), "Invalid data feed");
        require(isSupportedPaymentMethod[address(dataFeed)], "Unsupported payment method");

        (, int256 answer,,,) = dataFeed.latestRoundData();
        require(answer > 0, "Answer cannot be <= 0");
        require(dataFeed.decimals() == 8, "Unexpected decimals");

        uint256 price = uint256(answer) * 10 ** 10;

        // 1e15
        uint256 tokenPrice = tokenPrices[currentPhase];
        require(tokenPrice > 0, "Invalid token price");

        uint256 cost = (numberOfTokens * tokenPrice) / price;
        require(cost > 0, "Cost cannot be zero");

        return cost;
    }

    /**
     * @notice Set prices for each phase
     * @param _tokenPrices Array of token prices for each phase
     */
    function setTokenPrices(uint256[8] calldata _tokenPrices) external onlyOwner {
        tokenPrices = _tokenPrices;
    }

    /**
     * @notice Set a price feed for a given payment method
     * @param paymentToken IERC20 token to set price feed for
     * @param dataFeed AggregatorV3Interface price feed for the token
     */
    function setPriceFeed(address paymentToken, AggregatorV3Interface dataFeed) external onlyOwner {
        if (!isSupportedPaymentMethod[address(dataFeed)]) {
            paymentTokenToPriceFeed[paymentToken] = dataFeed;
            supportedPaymentMethods.push(paymentToken);
            isSupportedPaymentMethod[address(dataFeed)] = true;
        }
    }

    /**
     * @notice Unset a price feed for a given payment method
     * @param paymentToken IERC20 token to set price feed for
     * @param dataFeed AggregatorV3Interface price feed for the token
     */
    function unsetPriceFeed(address paymentToken, AggregatorV3Interface dataFeed) external onlyOwner {
        isSupportedPaymentMethod[address(dataFeed)] = false;
        paymentTokenToPriceFeed[paymentToken] = AggregatorV3Interface(address(0));

        // Create a new supported payment method array without the deleted payment method
        address[] memory newSupportedPaymentMethods = new address[](
            supportedPaymentMethods.length - 1
        );

        uint256 j = 0;
        for (uint256 i = 0; i < supportedPaymentMethods.length; ++i) {
            if (supportedPaymentMethods[i] != address(dataFeed)) {
                newSupportedPaymentMethods[j] = supportedPaymentMethods[i];
                ++j;
            }
        }

        supportedPaymentMethods = newSupportedPaymentMethods;
    }

    /**
     * @notice Stop the presale
     */
    function stopPresale() external onlyOwner {
        require(endTime == 0, "Presale has already ended");
        endTime = block.timestamp;

        uint unsoldTokens = 0;

        // Loop on each phase
        for (uint256 i = 0; i < caps.length; ++i) {
            // Add unsold tokens to unsoldTokens
            unsoldTokens += caps[i] - tokensSoldPerPhase[i];
        }

        // Transfer unsold NWIN to treasury
        if (unsoldTokens > 0) {
            NWIN.safeTransfer(treasury, unsoldTokens);
        }
    }

    /**
     * @notice Transfer ownership of the current contract to new owner
     * @param newOwner new owner of the current contract
     */
    function transferOwnership(address newOwner) public override onlyOwner {
        Ownable.transferOwnership(newOwner);
    }

    /**
     * Revert any BNB sent to the contract directly
     */
    receive() external payable {revert();}
}
