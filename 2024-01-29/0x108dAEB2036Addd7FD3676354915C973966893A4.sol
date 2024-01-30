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
// OpenZeppelin Contracts (last updated v4.9.4) (token/ERC20/extensions/IERC20Permit.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 Permit extension allowing approvals to be made via signatures, as defined in
 * https://eips.ethereum.org/EIPS/eip-2612[EIP-2612].
 *
 * Adds the {permit} method, which can be used to change an account's ERC20 allowance (see {IERC20-allowance}) by
 * presenting a message signed by the account. By not relying on {IERC20-approve}, the token holder account doesn't
 * need to send a transaction, and thus is not required to hold Ether at all.
 *
 * ==== Security Considerations
 *
 * There are two important considerations concerning the use of `permit`. The first is that a valid permit signature
 * expresses an allowance, and it should not be assumed to convey additional meaning. In particular, it should not be
 * considered as an intention to spend the allowance in any specific way. The second is that because permits have
 * built-in replay protection and can be submitted by anyone, they can be frontrun. A protocol that uses permits should
 * take this into consideration and allow a `permit` call to fail. Combining these two aspects, a pattern that may be
 * generally recommended is:
 *
 * ```solidity
 * function doThingWithPermit(..., uint256 value, uint256 deadline, uint8 v, bytes32 r, bytes32 s) public {
 *     try token.permit(msg.sender, address(this), value, deadline, v, r, s) {} catch {}
 *     doThing(..., value);
 * }
 *
 * function doThing(..., uint256 value) public {
 *     token.safeTransferFrom(msg.sender, address(this), value);
 *     ...
 * }
 * ```
 *
 * Observe that: 1) `msg.sender` is used as the owner, leaving no ambiguity as to the signer intent, and 2) the use of
 * `try/catch` allows the permit to fail and makes the code tolerant to frontrunning. (See also
 * {SafeERC20-safeTransferFrom}).
 *
 * Additionally, note that smart contract wallets (such as Argent or Safe) are not able to produce permit signatures, so
 * contracts should have entry points that don't rely on permit.
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
     *
     * CAUTION: See Security Considerations above.
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
// OpenZeppelin Contracts (last updated v4.9.0) (utils/math/Math.sol)

pragma solidity ^0.8.0;

/**
 * @dev Standard math utilities missing in the Solidity language.
 */
library Math {
    enum Rounding {
        Down, // Toward negative infinity
        Up, // Toward infinity
        Zero // Toward zero
    }

    /**
     * @dev Returns the largest of two numbers.
     */
    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a > b ? a : b;
    }

    /**
     * @dev Returns the smallest of two numbers.
     */
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    /**
     * @dev Returns the average of two numbers. The result is rounded towards
     * zero.
     */
    function average(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b) / 2 can overflow.
        return (a & b) + (a ^ b) / 2;
    }

    /**
     * @dev Returns the ceiling of the division of two numbers.
     *
     * This differs from standard division with `/` in that it rounds up instead
     * of rounding down.
     */
    function ceilDiv(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b - 1) / b can overflow on addition, so we distribute.
        return a == 0 ? 0 : (a - 1) / b + 1;
    }

    /**
     * @notice Calculates floor(x * y / denominator) with full precision. Throws if result overflows a uint256 or denominator == 0
     * @dev Original credit to Remco Bloemen under MIT license (https://xn--2-umb.com/21/muldiv)
     * with further edits by Uniswap Labs also under MIT license.
     */
    function mulDiv(uint256 x, uint256 y, uint256 denominator) internal pure returns (uint256 result) {
        unchecked {
            // 512-bit multiply [prod1 prod0] = x * y. Compute the product mod 2^256 and mod 2^256 - 1, then use
            // use the Chinese Remainder Theorem to reconstruct the 512 bit result. The result is stored in two 256
            // variables such that product = prod1 * 2^256 + prod0.
            uint256 prod0; // Least significant 256 bits of the product
            uint256 prod1; // Most significant 256 bits of the product
            assembly {
                let mm := mulmod(x, y, not(0))
                prod0 := mul(x, y)
                prod1 := sub(sub(mm, prod0), lt(mm, prod0))
            }

            // Handle non-overflow cases, 256 by 256 division.
            if (prod1 == 0) {
                // Solidity will revert if denominator == 0, unlike the div opcode on its own.
                // The surrounding unchecked block does not change this fact.
                // See https://docs.soliditylang.org/en/latest/control-structures.html#checked-or-unchecked-arithmetic.
                return prod0 / denominator;
            }

            // Make sure the result is less than 2^256. Also prevents denominator == 0.
            require(denominator > prod1, "Math: mulDiv overflow");

            ///////////////////////////////////////////////
            // 512 by 256 division.
            ///////////////////////////////////////////////

            // Make division exact by subtracting the remainder from [prod1 prod0].
            uint256 remainder;
            assembly {
                // Compute remainder using mulmod.
                remainder := mulmod(x, y, denominator)

                // Subtract 256 bit number from 512 bit number.
                prod1 := sub(prod1, gt(remainder, prod0))
                prod0 := sub(prod0, remainder)
            }

            // Factor powers of two out of denominator and compute largest power of two divisor of denominator. Always >= 1.
            // See https://cs.stackexchange.com/q/138556/92363.

            // Does not overflow because the denominator cannot be zero at this stage in the function.
            uint256 twos = denominator & (~denominator + 1);
            assembly {
                // Divide denominator by twos.
                denominator := div(denominator, twos)

                // Divide [prod1 prod0] by twos.
                prod0 := div(prod0, twos)

                // Flip twos such that it is 2^256 / twos. If twos is zero, then it becomes one.
                twos := add(div(sub(0, twos), twos), 1)
            }

            // Shift in bits from prod1 into prod0.
            prod0 |= prod1 * twos;

            // Invert denominator mod 2^256. Now that denominator is an odd number, it has an inverse modulo 2^256 such
            // that denominator * inv = 1 mod 2^256. Compute the inverse by starting with a seed that is correct for
            // four bits. That is, denominator * inv = 1 mod 2^4.
            uint256 inverse = (3 * denominator) ^ 2;

            // Use the Newton-Raphson iteration to improve the precision. Thanks to Hensel's lifting lemma, this also works
            // in modular arithmetic, doubling the correct bits in each step.
            inverse *= 2 - denominator * inverse; // inverse mod 2^8
            inverse *= 2 - denominator * inverse; // inverse mod 2^16
            inverse *= 2 - denominator * inverse; // inverse mod 2^32
            inverse *= 2 - denominator * inverse; // inverse mod 2^64
            inverse *= 2 - denominator * inverse; // inverse mod 2^128
            inverse *= 2 - denominator * inverse; // inverse mod 2^256

            // Because the division is now exact we can divide by multiplying with the modular inverse of denominator.
            // This will give us the correct result modulo 2^256. Since the preconditions guarantee that the outcome is
            // less than 2^256, this is the final result. We don't need to compute the high bits of the result and prod1
            // is no longer required.
            result = prod0 * inverse;
            return result;
        }
    }

    /**
     * @notice Calculates x * y / denominator with full precision, following the selected rounding direction.
     */
    function mulDiv(uint256 x, uint256 y, uint256 denominator, Rounding rounding) internal pure returns (uint256) {
        uint256 result = mulDiv(x, y, denominator);
        if (rounding == Rounding.Up && mulmod(x, y, denominator) > 0) {
            result += 1;
        }
        return result;
    }

    /**
     * @dev Returns the square root of a number. If the number is not a perfect square, the value is rounded down.
     *
     * Inspired by Henry S. Warren, Jr.'s "Hacker's Delight" (Chapter 11).
     */
    function sqrt(uint256 a) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        // For our first guess, we get the biggest power of 2 which is smaller than the square root of the target.
        //
        // We know that the "msb" (most significant bit) of our target number `a` is a power of 2 such that we have
        // `msb(a) <= a < 2*msb(a)`. This value can be written `msb(a)=2**k` with `k=log2(a)`.
        //
        // This can be rewritten `2**log2(a) <= a < 2**(log2(a) + 1)`
        // → `sqrt(2**k) <= sqrt(a) < sqrt(2**(k+1))`
        // → `2**(k/2) <= sqrt(a) < 2**((k+1)/2) <= 2**(k/2 + 1)`
        //
        // Consequently, `2**(log2(a) / 2)` is a good first approximation of `sqrt(a)` with at least 1 correct bit.
        uint256 result = 1 << (log2(a) >> 1);

        // At this point `result` is an estimation with one bit of precision. We know the true value is a uint128,
        // since it is the square root of a uint256. Newton's method converges quadratically (precision doubles at
        // every iteration). We thus need at most 7 iteration to turn our partial result with one bit of precision
        // into the expected uint128 result.
        unchecked {
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            return min(result, a / result);
        }
    }

    /**
     * @notice Calculates sqrt(a), following the selected rounding direction.
     */
    function sqrt(uint256 a, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = sqrt(a);
            return result + (rounding == Rounding.Up && result * result < a ? 1 : 0);
        }
    }

    /**
     * @dev Return the log in base 2, rounded down, of a positive value.
     * Returns 0 if given 0.
     */
    function log2(uint256 value) internal pure returns (uint256) {
        uint256 result = 0;
        unchecked {
            if (value >> 128 > 0) {
                value >>= 128;
                result += 128;
            }
            if (value >> 64 > 0) {
                value >>= 64;
                result += 64;
            }
            if (value >> 32 > 0) {
                value >>= 32;
                result += 32;
            }
            if (value >> 16 > 0) {
                value >>= 16;
                result += 16;
            }
            if (value >> 8 > 0) {
                value >>= 8;
                result += 8;
            }
            if (value >> 4 > 0) {
                value >>= 4;
                result += 4;
            }
            if (value >> 2 > 0) {
                value >>= 2;
                result += 2;
            }
            if (value >> 1 > 0) {
                result += 1;
            }
        }
        return result;
    }

    /**
     * @dev Return the log in base 2, following the selected rounding direction, of a positive value.
     * Returns 0 if given 0.
     */
    function log2(uint256 value, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = log2(value);
            return result + (rounding == Rounding.Up && 1 << result < value ? 1 : 0);
        }
    }

    /**
     * @dev Return the log in base 10, rounded down, of a positive value.
     * Returns 0 if given 0.
     */
    function log10(uint256 value) internal pure returns (uint256) {
        uint256 result = 0;
        unchecked {
            if (value >= 10 ** 64) {
                value /= 10 ** 64;
                result += 64;
            }
            if (value >= 10 ** 32) {
                value /= 10 ** 32;
                result += 32;
            }
            if (value >= 10 ** 16) {
                value /= 10 ** 16;
                result += 16;
            }
            if (value >= 10 ** 8) {
                value /= 10 ** 8;
                result += 8;
            }
            if (value >= 10 ** 4) {
                value /= 10 ** 4;
                result += 4;
            }
            if (value >= 10 ** 2) {
                value /= 10 ** 2;
                result += 2;
            }
            if (value >= 10 ** 1) {
                result += 1;
            }
        }
        return result;
    }

    /**
     * @dev Return the log in base 10, following the selected rounding direction, of a positive value.
     * Returns 0 if given 0.
     */
    function log10(uint256 value, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = log10(value);
            return result + (rounding == Rounding.Up && 10 ** result < value ? 1 : 0);
        }
    }

    /**
     * @dev Return the log in base 256, rounded down, of a positive value.
     * Returns 0 if given 0.
     *
     * Adding one to the result gives the number of pairs of hex symbols needed to represent `value` as a hex string.
     */
    function log256(uint256 value) internal pure returns (uint256) {
        uint256 result = 0;
        unchecked {
            if (value >> 128 > 0) {
                value >>= 128;
                result += 16;
            }
            if (value >> 64 > 0) {
                value >>= 64;
                result += 8;
            }
            if (value >> 32 > 0) {
                value >>= 32;
                result += 4;
            }
            if (value >> 16 > 0) {
                value >>= 16;
                result += 2;
            }
            if (value >> 8 > 0) {
                result += 1;
            }
        }
        return result;
    }

    /**
     * @dev Return the log in base 256, following the selected rounding direction, of a positive value.
     * Returns 0 if given 0.
     */
    function log256(uint256 value, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = log256(value);
            return result + (rounding == Rounding.Up && 1 << (result << 3) < value ? 1 : 0);
        }
    }
}
pragma solidity ^0.8.19;

// SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/math/Math.sol";


interface IERC20Extended {
    function decimals() external view returns (uint256);
}

interface IWBNB is IERC20 {
    function deposit() external payable;
    function withdraw(uint256 wad) external;
}

interface IPlanetRouter {

    function addLiquidity(address tokenA, address tokenB, uint amountADesired, uint amountBDesired, uint amountAMin, uint amountBMin,
        address to,
        uint deadline) external returns (uint amountA, uint amountB, uint liquidity);
 
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);
}

interface IUniswapV2Pair {
    // function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function burn(address to) external returns (uint amount0, uint amount1);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    // function totalSupply() external view returns (uint256);
    // function kLast() external view returns (uint256);
}

interface ISolidlyPair {
    function token0() external view returns (address);
    function token1() external view returns (address);
    function stable() external view returns (bool);
    function getAmountOut(uint256 amountIn, address tokenIn) external view returns (uint256);
}

interface ISolidlyRouter{
    function addLiquidity(
        address tokenA,
        address tokenB,
        bool stable,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);

        function quoteAddLiquidity(
        address tokenA,
        address tokenB,
        bool stable,
        uint amountADesired,
        uint amountBDesired
    ) external view returns (uint amountA, uint amountB, uint liquidity);
}

interface IGammaUniProxy{
    function deposit(
        uint256 deposit0,
        uint256 deposit1,
        address to,
        address pos,
        uint256[4] memory minIn
    ) external returns (uint256 shares);

    function getDepositAmount(
        address pos,
        address token,
        uint256 _deposit
    ) external view returns (uint256 amountStart, uint256 amountEnd);

}

interface IHypervisor{
    function withdraw(
        uint256 shares,
        address to,
        address from,
        uint256[4] memory minAmounts
    ) external returns (uint256 amount0, uint256 amount1);

    function getTotalAmounts() external view returns (uint256 total0, uint256 total1);
}

interface IPlanetFarm{
    function deposit(
        address mintAddress,
        uint256 wantAmount, 
        uint256 pid,
        uint256 lockTimeIndex
    ) external;
}pragma solidity ^0.8.19;

// SPDX-License-Identifier: MIT

import "./Dependencies.sol";

/**
@title Planet Zap via OneInch
@author Planet
@notice Use this to Zap and out of any LP on Planet
*/

contract PlanetZapOneInch is Ownable, ReentrancyGuard {
    using SafeERC20 for IERC20;

    address internal immutable oneInchRouter = 0x1111111254EEB25477B68fb85Ed929f73A960582; // Router for all the swaps to go through
    address internal immutable WBNB; // BNB address
    uint256 internal constant minimumAmount = 1000; // minimum number of tokens for the transaction to go through
    address public planetFarm; 

    enum WantType {
        WANT_TYPE_UNISWAP_V2,
        WANT_TYPE_SOLIDLY_STABLE,
        WANT_TYPE_SOLIDLY_VOLATILE,
        WANT_TYPE_GAMMA_HYPERVISOR
    }

    event TokenReturned(address token, uint256 amount); // emitted when any pending tokens left with the contract after a function call are sent back to the user
    event Swap(address tokenIn, uint256 amountIn); // emitted after every swap transaction
    event ZapIn(address tokenIn, uint256 amountIn); //  emitted after every ZapIn transaction
    event ZapOut(address tokenOut, uint256 amountOut); // emitted after every ZapOut transaction
    // should we also include destination tokens?

    constructor(address _WBNB) {
        // Safety checks to ensure WBNB token address
        IWBNB(_WBNB).deposit{value: 0}();
        IWBNB(_WBNB).withdraw(0);
        WBNB = _WBNB;
    }
    // Zap's main functions external and public functions

    /** 
    @notice Swaps BNB for any token via One Inch Router
    @param _token0 One Inch calldata for swapping BNB to the output token
    @param _outputToken Address of output token
    */
    function swapFromBNB (bytes calldata _token0, address _outputToken) external payable nonReentrant {
        require(msg.value >= minimumAmount, 'Planet: Insignificant input amount');
        address _wbnb = WBNB;

        IWBNB(_wbnb).deposit{value: msg.value}();
        _swap(_wbnb, _token0, _outputToken);
        emit Swap(_wbnb, msg.value);
    }
    
    /** 
    @notice Swaps any token for another token via One Inch Router
    @param _inputToken Address of input token
    @param _tokenInAmount Amount of input token to be swapped
    @param _token0 One Inch calldata for swapping the input token to the output token
    @param _outputToken Address of output token 
    */ 
    function swap (address _inputToken, uint256 _tokenInAmount, bytes calldata _token0, address _outputToken) external nonReentrant{
        require(_tokenInAmount >= minimumAmount, 'Planet: Insignificant input amount');
        IERC20(_inputToken).safeTransferFrom(msg.sender, address(this), _tokenInAmount);
        _swap(_inputToken, _token0, _outputToken);
        emit Swap(_inputToken, _tokenInAmount);
    }

    /** 
    @notice Zaps BNB into any LP Pair (including aggregated pairs) on Planet via One Inch Router
    @param _token0 One Inch calldata for swapping BNB to token0 of the LP Pair
    @param _token1 One Inch calldata for swapping BNB to token1 of the LP Pair
    @param _type LP Pair type, whether uniswapV2, solidly volatile or solidly stable
    @param _router Rourter where "Add Liquidity" is to be called, to create LP Pair
    @param _pair Address of the output LP Pair token
    */ 
    function zapInBNB (bytes calldata _token0, bytes calldata _token1, WantType _type, address _router, address _pair, bool _stake, uint256 pid, uint256 lockTimeIndex) external payable nonReentrant{
        require(msg.value >= minimumAmount, 'Planet: Insignificant input amount');

        address _wbnb = WBNB;
        IWBNB(_wbnb).deposit{value: msg.value}();
        bool _mintToMessageSender;

        if (!_stake)
            _mintToMessageSender = true;
        _zapIn(_wbnb, _token0, _token1, _type, _router, _pair, _mintToMessageSender);

        if (_stake){
            _stakeToFarm(_pair, pid, lockTimeIndex);

        }
        emit ZapIn(_wbnb, msg.value);
    }

    /** 
    @notice Zaps any token into any LP Pair (including aggregated pairs) on Planet via One Inch Router
    @param _inputToken Address of input token
    @param _tokenInAmount Amount of input token to be zapped
    @param _token0 One Inch calldata for swapping the input token to token0 of the LP Pair
    @param _token1 One Inch calldata for swapping the input token to token1 of the LP Pair
    @param _type LP Pair type, whether uniswapV2, solidly volatile or solidly stable
    @param _router Rourter where "Add Liquidity" is to be called, to create LP Pair
    @param _pair Address of the output LP Pair token
    */
    function zapIn (address _inputToken, uint256 _tokenInAmount, bytes calldata _token0, bytes calldata _token1, WantType _type, address _router, address _pair, bool _stake, uint256 pid, uint256 lockTimeIndex) external nonReentrant{
        require(_tokenInAmount >= minimumAmount, 'Planet: Insignificant input amount');

        IERC20(_inputToken).safeTransferFrom(msg.sender, address(this), _tokenInAmount);

         bool _mintToMessageSender;

        if (!_stake)
            _mintToMessageSender = true;
        _zapIn(_inputToken, _token0, _token1, _type, _router, _pair, _mintToMessageSender);
        
        if (_stake){
            _stakeToFarm(_pair, pid, lockTimeIndex);

        }
        emit ZapIn(_inputToken, _tokenInAmount);
    }

    function _stakeToFarm(address _pair, uint256 pid, uint256 lockTimeIndex) internal {
        uint256 amount = IERC20(_pair).balanceOf(address(this));
        _approveTokenIfNeeded(_pair, planetFarm);
        IPlanetFarm(planetFarm).deposit(msg.sender, amount, pid, lockTimeIndex);
    }
    

    /**
    @notice Zaps out any LP Pair (including aggregated pairs) on Planet to any desired token via One Inch Router
    @param _pair Address of the input LP Pair token
    @param _withdrawAmount Amount of LP Pair token to zapped out
    @param _desiredToken Address of the desired output token
    @param _dataToken0 One Inch calldata for swapping token0 of the LP Pair to the desired output token
    @param _dataToken1 One Inch calldata for swapping token1 of the LP Pair to the desired output token
    @param _type LP Pair type, whether uniswapV2, solidly volatile or solidly stable
    */
    function zapOut(address _pair, uint256 _withdrawAmount, address _desiredToken, bytes calldata _dataToken0, bytes calldata _dataToken1, WantType _type) external nonReentrant{
        require(_withdrawAmount >= minimumAmount, 'Planet: Insignificant withdraw amount');

        IERC20(_pair).safeTransferFrom(msg.sender, address(this), _withdrawAmount);
        _removeLiquidity(_pair, _withdrawAmount, _type);

        IUniswapV2Pair pair = IUniswapV2Pair(_pair);
        address[] memory path = new address[](3);
        path[0] = pair.token0();
        path[1] = pair.token1();
        path[2] = _desiredToken;

        _approveTokenIfNeeded(path[0], address(oneInchRouter));
        _approveTokenIfNeeded(path[1], address(oneInchRouter));

        if (_desiredToken != path[0]) {
            _swapViaOneInch(path[0], _dataToken0);
        }

        if (_desiredToken != path[1]) {
            _swapViaOneInch(path[1], _dataToken1);
        }
    
        _returnAssets(path); // function _returnAssets also takes care of withdrawing WBNB and sending it to the user as BNB
        emit ZapOut(address(pair), _withdrawAmount);
    }

    // View function helpers for the app

    /**
    @notice Calculates amount of second input token given the amount of first input tokens while depositing into gammaUniProxy
    @param _pair Hypervisor Address
    @param _token Address of token to deposit
    @param _inputTokenDepositAmount Amount of token to deposit
    @return _otherTokenAmountMin Minimum amounts of the pair token to deposit
    @return _otherTokenAmountMax Maximum amounts of the pair token to deposit 
    */
    function getSecondTokenDepositAmount(
        address _pair,
        address _token,
        uint256 _inputTokenDepositAmount,
        address _router
        ) public view returns (uint256 _otherTokenAmountMin, uint256 _otherTokenAmountMax){

        (_otherTokenAmountMin, _otherTokenAmountMax) =  IGammaUniProxy(_router).getDepositAmount(_pair, _token, _inputTokenDepositAmount);
        
    }

    /**
    @notice Calculates minimum number of tokens recieved when removing liquidity from an hypervisor
    @param _hypervisor Address of the hypervisor token
    @param _tokenA Address of token A of the hypervisor
    @param _liquidity Amount of hypervisor Tokens desired to be removed
    @return amountA Amount of token A that will be recieved on removing liquidity
    @return amountB Amount of token B that will be recieved on removing liquidity
    */
    function quoteRemoveLiquidityGammaUniproxy(
        address _hypervisor,
        address _tokenA,
        uint _liquidity
        ) external view returns (uint amountA, uint amountB){
            (uint256 total0, uint256 total1) = IHypervisor(_hypervisor).getTotalAmounts();
            uint256 totalSupply = IERC20(_hypervisor).totalSupply();

            amountA = (_liquidity * total0)/totalSupply;
            amountB = (_liquidity * total1)/totalSupply;

            (amountA , amountB) = IUniswapV2Pair(_hypervisor).token0() == _tokenA ? (amountA , amountB) : (amountB , amountA);
        }



    /** 
    @notice Calculates ratio of input tokens for creating solidly stable pairs
    @dev Since solidly stable pairs can be inbalanced we need the proper ratio for our swap, we need to account both for price of the assets and the ratio of the pair. 
    @param _pair Address of the solidly stable LP Pair token
    @param _router Address of the solidly router associated with the solidly stable LP Pair
    @return ratio1to0 Ratio of Token1 to Token0
    */
    function quoteStableAddLiquidityRatio(ISolidlyPair _pair, address _router) external view returns (uint256 ratio1to0) {
            address tokenA = _pair.token0();
            address tokenB = _pair.token1();

            uint256 investment = IERC20(tokenA).balanceOf(address(_pair)) * 10 / 10000;
            uint out = _pair.getAmountOut(investment, tokenA);
            (uint amountA, uint amountB,) = ISolidlyRouter(_router).quoteAddLiquidity(tokenA, tokenB, _pair.stable(), investment, out);
                
            amountA = amountA * 1e18 / 10**IERC20Extended(tokenA).decimals();
            amountB = amountB * 1e18 / 10**IERC20Extended(tokenB).decimals();
            out = out * 1e18 / 10**IERC20Extended(tokenB).decimals();
            investment = investment * 1e18 / 10**IERC20Extended(tokenA).decimals();
                
            uint ratio = (out * 1e18 * amountA ) / (investment  * amountB); 

                
            return 1e18 * 1e18 / (ratio + 1e18);
    }

    /**
    @notice Calculates minimum number of LP tokens recieved when creating an LP Pair
    @param _pair Address of the LP Pair token
    @param _tokenA Address of token A of the LP Pair
    @param _tokenB Address of token B of the LP Pair
    @param _amountADesired Desired amount of token A to be used to create the LP Pair
    @param _amountBDesired Desired amount of token B to be used to create the LP Pair
    @return amountA Actual amount of token A that will be used to create the LP Pair
    @return amountB Actual amount of token B that will be used to create the LP Pair
    @return liquidity Amount of LP Tokens to be recieved when adding liquidity
     */
    function quoteAddLiquidity(
        address _pair,
        address _tokenA,
        address _tokenB,
        uint _amountADesired,
        uint _amountBDesired
        ) external view returns (uint amountA, uint amountB, uint liquidity) {
        
        if (_pair == address(0)) {
            return (0,0,0);
        }

        (uint reserveA, uint reserveB) = getReserves(_pair, _tokenA, _tokenB);
        uint _totalSupply = IERC20(_pair).totalSupply();
        
        if (reserveA == 0 && reserveB == 0) {
            (amountA, amountB) = (_amountADesired, _amountBDesired);
            liquidity = Math.sqrt(amountA * amountB) - minimumAmount;
        } else {

            uint amountBOptimal = quoteLiquidity(_amountADesired, reserveA, reserveB);
            if (amountBOptimal <= _amountBDesired) {
                (amountA, amountB) = (_amountADesired, amountBOptimal);
                liquidity = Math.min(amountA * _totalSupply / reserveA, amountB * _totalSupply / reserveB);
            } else {
                uint amountAOptimal = quoteLiquidity(_amountBDesired, reserveB, reserveA);
                (amountA, amountB) = (amountAOptimal, _amountBDesired);
                liquidity = Math.min(amountA * _totalSupply / reserveA, amountB * _totalSupply / reserveB);
            }
        }
    }

    /**
    @notice Calculates minimum number of tokens recieved when removing liquidity from an LP Pair
    @param _pair Address of the LP Pair token
    @param _tokenA Address of token A of the LP Pair
    @param _tokenB Address of token B of the LP Pair
    @param _liquidity Amount of LP Tokens desired to be removed
    @return amountA Amount of token A that will be recieved on removing liquidity
    @return amountB Amount of token B that will be recieved on removing liquidity

    */
    function quoteRemoveLiquidity(
        address _pair,
        address _tokenA,
        address _tokenB,
        uint _liquidity
        ) external view returns (uint amountA, uint amountB) {

        if (_pair == address(0)) {
            return (0,0);
        }

        (uint reserveA, uint reserveB) = getReserves(_pair, _tokenA, _tokenB);
        uint _totalSupply = IERC20(_pair).totalSupply();

        amountA = _liquidity * reserveA / _totalSupply; // using balances ensures pro-rata distribution
        amountB = _liquidity * reserveB / _totalSupply; // using balances ensures pro-rata distribution

    }

    // fetches and sorts the reserves for a pair
    function getReserves(address _pair, address _tokenA, address _tokenB) public view returns (uint reserveA, uint reserveB) {
        (address token0,) = sortTokens(_tokenA, _tokenB);
        (uint reserve0, uint reserve1,) = IUniswapV2Pair(_pair).getReserves();
        (reserveA, reserveB) = _tokenA == token0 ? (reserve0, reserve1) : (reserve1, reserve0);
    }

    // internal functions

     // returns sorted token addresses, used to handle return values from pairs sorted in this order
    function sortTokens(address tokenA, address tokenB) internal pure returns (address token0, address token1) {
        require(tokenA != tokenB, 'PlanetLibrary: IDENTICAL_ADDRESSES');
        (token0, token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
        require(token0 != address(0), 'PlanetLibrary: ZERO_ADDRESS');
    }

    // given some amount of an asset and pair reserves, returns an equivalent amount of the other asset
    function quoteLiquidity(uint amountA, uint reserveA, uint reserveB) internal pure returns (uint amountB) {
        require(amountA > 0, 'PlanetLibrary: INSUFFICIENT_AMOUNT');
        require(reserveA > 0 && reserveB > 0, 'PlanetLibrary: INSUFFICIENT_LIQUIDITY');
        amountB = amountA * reserveB / reserveA;
    }

    // provides allowance for the spender to access the token when allowance is not already given
    function _approveTokenIfNeeded(address _token, address _spender) private {
        if (IERC20(_token).allowance(address(this), _spender) == 0) {
            IERC20(_token).safeApprove(_spender, type(uint).max);
        }
    }
    // swaps tokens via One Inch router
    function _swap(address _inputToken, bytes calldata _token0, address _outputToken) private {
        address[] memory path;
        path = new address[](2);
        path[0] = _outputToken;
        path[1] = _inputToken;

        _swapViaOneInch(_inputToken, _token0);

        _returnAssets(path);
    }

    // Zaps any token into any LP Pair on Planet via One Inch Router
    function _zapIn(address _inputToken, bytes calldata _token0, bytes calldata _token1, WantType _type, address _router, address _pair, bool _mintToMessageSender) private {

        address[] memory path;

        {
        IUniswapV2Pair pair = IUniswapV2Pair(_pair);
        path = new address[](3);
        path[0] = pair.token0();
        path[1] = pair.token1();
        path[2] = _inputToken;
        }

        if (_inputToken != path[0]) {
            _swapViaOneInch(_inputToken, _token0);
        }

        if (_inputToken != path[1]) {
            _swapViaOneInch(_inputToken, _token1);
        }

        {
        address approveToken = _router;
        if (_type == WantType.WANT_TYPE_GAMMA_HYPERVISOR){
            approveToken = _pair;
        }
        _approveTokenIfNeeded(path[0], address(approveToken));
        _approveTokenIfNeeded(path[1], address(approveToken));
        }

        uint256 lp0Amt = IERC20(path[0]).balanceOf(address(this));
        uint256 lp1Amt = IERC20(path[1]).balanceOf(address(this));

        uint256[4] memory min;
        address _mintTo = address(this); 

        if (_type == WantType.WANT_TYPE_GAMMA_HYPERVISOR){
            (uint256 lp1AmtMin, uint256 lp1AmtMax) = getSecondTokenDepositAmount(_pair, path[0], lp0Amt, _router);   
            if (lp1Amt >= lp1AmtMax){
                lp1Amt = (lp1AmtMin+lp1AmtMax)>>1;
            }
            else if (lp1Amt < lp1AmtMin){
                (uint256 lp0AmtMin, uint256 lp0AmtMax) = getSecondTokenDepositAmount(_pair, path[1], lp1Amt, _router);
                lp0Amt = (lp0AmtMin + lp0AmtMax)>>1;
            }
            
            uint256 shares = IGammaUniProxy(_router).deposit(lp0Amt, lp1Amt, address(this), _pair, min);
            require(IERC20(_pair).balanceOf(address(this)) >= shares, "LP tokens not returned from GAMMA Uniproxy");
            if (_mintToMessageSender){
                IERC20(_pair).safeTransfer(msg.sender, shares);
            }
	    }
        else if (_type == WantType.WANT_TYPE_UNISWAP_V2) {
            if(_mintToMessageSender)
                _mintTo = msg.sender;
            IPlanetRouter(_router).addLiquidity(path[0], path[1], lp0Amt, lp1Amt, 1, 1, _mintTo, block.timestamp);
        } else {
            if(_mintToMessageSender)
                _mintTo = msg.sender;
            bool stable = _type == WantType.WANT_TYPE_SOLIDLY_STABLE ? true : false;
            ISolidlyRouter(_router).addLiquidity(path[0], path[1], stable,  lp0Amt, lp1Amt, 1, 1, _mintTo, block.timestamp);
        }  
        _returnAssets(path);   
    }

    // removes liquidity from the pair by burning LP pair tokens of the input address 
    function _removeLiquidity(address _pair, uint256 _withdrawAmount, WantType _type) private {
        uint256 amount0;
        uint256 amount1;

        uint256[4] memory min;
        if (_type == WantType.WANT_TYPE_GAMMA_HYPERVISOR){
            (amount0, amount1) = IHypervisor(_pair).withdraw(_withdrawAmount, address(this), address(this), min);
        }
        else {
            IERC20(_pair).safeTransfer(_pair, IERC20(_pair).balanceOf(address(this)));
            (amount0, amount1) = IUniswapV2Pair(_pair).burn(address(this));
        }

        require(amount0 >= minimumAmount, "UniswapV2Router: INSUFFICIENT_A_AMOUNT");
        require(amount1 >= minimumAmount, "UniswapV2Router: INSUFFICIENT_B_AMOUNT");
    }

    // Our main swap function call. We call the aggregator contract with our fed data. If we get an error we revert and return the error result. 
    function _swapViaOneInch(address _inputToken, bytes memory _callData) private {
        
        address _oneInchRouter = oneInchRouter;
        _approveTokenIfNeeded(_inputToken, address(_oneInchRouter));

        (bool success, bytes memory retData) = _oneInchRouter.call(_callData);

        propagateError(success, retData, "1inch");

        require(success, "calling 1inch got an error");
    }

    // Error reporting from our call to the aggrator contract when we try to swap. 
    function propagateError(
        bool success,
        bytes memory data,
        string memory errorMessage
        ) public pure {
        // Forward error message from call/delegatecall
        if (!success) {
            if (data.length == 0) revert(errorMessage);
            assembly {
                revert(add(32, data), mload(data))
            }
        }
    }

    // Returns any pending assets left with the contract after a swap, zapIn or ZapOut back to the user
    function _returnAssets (address[] memory _tokens) private {
        uint256 balance;
        uint256 len = _tokens.length;
        address _wbnb = WBNB;
        for (uint256 i; i < len;) {
            balance = IERC20(_tokens[i]).balanceOf(address(this));
            if (balance > 0) {
                if (_tokens[i] == _wbnb) {
                    IWBNB(_wbnb).withdraw(balance);
                    (bool success,) = msg.sender.call{value: balance}(new bytes(0));
                    require(success, 'Planet: BNB transfer failed');
                    emit TokenReturned(_tokens[i], balance);
                } else {
                    IERC20(_tokens[i]).safeTransfer(msg.sender, balance);
                    emit TokenReturned(_tokens[i], balance);
                }
            }
            unchecked{
                i++;
            }
        }
    }

    // enabling the contract to receive BNB
    receive() external payable {
        assert(msg.sender == WBNB);
    }

    function inCaseTokensGetStuck(address _token, uint256 _amount) external onlyOwner{
        IERC20(_token).safeTransfer(_msgSender(), _amount);
    }

    function setPlanetFarm(address _newFarm) external onlyOwner{
       planetFarm = _newFarm;
    }

}
