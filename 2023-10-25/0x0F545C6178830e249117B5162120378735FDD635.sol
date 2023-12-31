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
// OpenZeppelin Contracts (last updated v4.9.0) (token/ERC20/utils/SafeERC20.sol)

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
     * non-reverting calls are assumed to be successful. Compatible with tokens that require the approval to be set to
     * 0 before setting it to a non-zero value.
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
// OpenZeppelin Contracts (last updated v4.9.0) (utils/cryptography/ECDSA.sol)

pragma solidity ^0.8.0;

import "../Strings.sol";

/**
 * @dev Elliptic Curve Digital Signature Algorithm (ECDSA) operations.
 *
 * These functions can be used to verify that a message was signed by the holder
 * of the private keys of a given address.
 */
library ECDSA {
    enum RecoverError {
        NoError,
        InvalidSignature,
        InvalidSignatureLength,
        InvalidSignatureS,
        InvalidSignatureV // Deprecated in v4.8
    }

    function _throwError(RecoverError error) private pure {
        if (error == RecoverError.NoError) {
            return; // no error: do nothing
        } else if (error == RecoverError.InvalidSignature) {
            revert("ECDSA: invalid signature");
        } else if (error == RecoverError.InvalidSignatureLength) {
            revert("ECDSA: invalid signature length");
        } else if (error == RecoverError.InvalidSignatureS) {
            revert("ECDSA: invalid signature 's' value");
        }
    }

    /**
     * @dev Returns the address that signed a hashed message (`hash`) with
     * `signature` or error string. This address can then be used for verification purposes.
     *
     * The `ecrecover` EVM opcode allows for malleable (non-unique) signatures:
     * this function rejects them by requiring the `s` value to be in the lower
     * half order, and the `v` value to be either 27 or 28.
     *
     * IMPORTANT: `hash` _must_ be the result of a hash operation for the
     * verification to be secure: it is possible to craft signatures that
     * recover to arbitrary addresses for non-hashed data. A safe way to ensure
     * this is by receiving a hash of the original message (which may otherwise
     * be too long), and then calling {toEthSignedMessageHash} on it.
     *
     * Documentation for signature generation:
     * - with https://web3js.readthedocs.io/en/v1.3.4/web3-eth-accounts.html#sign[Web3.js]
     * - with https://docs.ethers.io/v5/api/signer/#Signer-signMessage[ethers]
     *
     * _Available since v4.3._
     */
    function tryRecover(bytes32 hash, bytes memory signature) internal pure returns (address, RecoverError) {
        if (signature.length == 65) {
            bytes32 r;
            bytes32 s;
            uint8 v;
            // ecrecover takes the signature parameters, and the only way to get them
            // currently is to use assembly.
            /// @solidity memory-safe-assembly
            assembly {
                r := mload(add(signature, 0x20))
                s := mload(add(signature, 0x40))
                v := byte(0, mload(add(signature, 0x60)))
            }
            return tryRecover(hash, v, r, s);
        } else {
            return (address(0), RecoverError.InvalidSignatureLength);
        }
    }

    /**
     * @dev Returns the address that signed a hashed message (`hash`) with
     * `signature`. This address can then be used for verification purposes.
     *
     * The `ecrecover` EVM opcode allows for malleable (non-unique) signatures:
     * this function rejects them by requiring the `s` value to be in the lower
     * half order, and the `v` value to be either 27 or 28.
     *
     * IMPORTANT: `hash` _must_ be the result of a hash operation for the
     * verification to be secure: it is possible to craft signatures that
     * recover to arbitrary addresses for non-hashed data. A safe way to ensure
     * this is by receiving a hash of the original message (which may otherwise
     * be too long), and then calling {toEthSignedMessageHash} on it.
     */
    function recover(bytes32 hash, bytes memory signature) internal pure returns (address) {
        (address recovered, RecoverError error) = tryRecover(hash, signature);
        _throwError(error);
        return recovered;
    }

    /**
     * @dev Overload of {ECDSA-tryRecover} that receives the `r` and `vs` short-signature fields separately.
     *
     * See https://eips.ethereum.org/EIPS/eip-2098[EIP-2098 short signatures]
     *
     * _Available since v4.3._
     */
    function tryRecover(bytes32 hash, bytes32 r, bytes32 vs) internal pure returns (address, RecoverError) {
        bytes32 s = vs & bytes32(0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff);
        uint8 v = uint8((uint256(vs) >> 255) + 27);
        return tryRecover(hash, v, r, s);
    }

    /**
     * @dev Overload of {ECDSA-recover} that receives the `r and `vs` short-signature fields separately.
     *
     * _Available since v4.2._
     */
    function recover(bytes32 hash, bytes32 r, bytes32 vs) internal pure returns (address) {
        (address recovered, RecoverError error) = tryRecover(hash, r, vs);
        _throwError(error);
        return recovered;
    }

    /**
     * @dev Overload of {ECDSA-tryRecover} that receives the `v`,
     * `r` and `s` signature fields separately.
     *
     * _Available since v4.3._
     */
    function tryRecover(bytes32 hash, uint8 v, bytes32 r, bytes32 s) internal pure returns (address, RecoverError) {
        // EIP-2 still allows signature malleability for ecrecover(). Remove this possibility and make the signature
        // unique. Appendix F in the Ethereum Yellow paper (https://ethereum.github.io/yellowpaper/paper.pdf), defines
        // the valid range for s in (301): 0 < s < secp256k1n ÷ 2 + 1, and for v in (302): v ∈ {27, 28}. Most
        // signatures from current libraries generate a unique signature with an s-value in the lower half order.
        //
        // If your library generates malleable signatures, such as s-values in the upper range, calculate a new s-value
        // with 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141 - s1 and flip v from 27 to 28 or
        // vice versa. If your library also generates signatures with 0/1 for v instead 27/28, add 27 to v to accept
        // these malleable signatures as well.
        if (uint256(s) > 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0) {
            return (address(0), RecoverError.InvalidSignatureS);
        }

        // If the signature is valid (and not malleable), return the signer address
        address signer = ecrecover(hash, v, r, s);
        if (signer == address(0)) {
            return (address(0), RecoverError.InvalidSignature);
        }

        return (signer, RecoverError.NoError);
    }

    /**
     * @dev Overload of {ECDSA-recover} that receives the `v`,
     * `r` and `s` signature fields separately.
     */
    function recover(bytes32 hash, uint8 v, bytes32 r, bytes32 s) internal pure returns (address) {
        (address recovered, RecoverError error) = tryRecover(hash, v, r, s);
        _throwError(error);
        return recovered;
    }

    /**
     * @dev Returns an Ethereum Signed Message, created from a `hash`. This
     * produces hash corresponding to the one signed with the
     * https://eth.wiki/json-rpc/API#eth_sign[`eth_sign`]
     * JSON-RPC method as part of EIP-191.
     *
     * See {recover}.
     */
    function toEthSignedMessageHash(bytes32 hash) internal pure returns (bytes32 message) {
        // 32 is the length in bytes of hash,
        // enforced by the type signature above
        /// @solidity memory-safe-assembly
        assembly {
            mstore(0x00, "\x19Ethereum Signed Message:\n32")
            mstore(0x1c, hash)
            message := keccak256(0x00, 0x3c)
        }
    }

    /**
     * @dev Returns an Ethereum Signed Message, created from `s`. This
     * produces hash corresponding to the one signed with the
     * https://eth.wiki/json-rpc/API#eth_sign[`eth_sign`]
     * JSON-RPC method as part of EIP-191.
     *
     * See {recover}.
     */
    function toEthSignedMessageHash(bytes memory s) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n", Strings.toString(s.length), s));
    }

    /**
     * @dev Returns an Ethereum Signed Typed Data, created from a
     * `domainSeparator` and a `structHash`. This produces hash corresponding
     * to the one signed with the
     * https://eips.ethereum.org/EIPS/eip-712[`eth_signTypedData`]
     * JSON-RPC method as part of EIP-712.
     *
     * See {recover}.
     */
    function toTypedDataHash(bytes32 domainSeparator, bytes32 structHash) internal pure returns (bytes32 data) {
        /// @solidity memory-safe-assembly
        assembly {
            let ptr := mload(0x40)
            mstore(ptr, "\x19\x01")
            mstore(add(ptr, 0x02), domainSeparator)
            mstore(add(ptr, 0x22), structHash)
            data := keccak256(ptr, 0x42)
        }
    }

    /**
     * @dev Returns an Ethereum Signed Data with intended validator, created from a
     * `validator` and `data` according to the version 0 of EIP-191.
     *
     * See {recover}.
     */
    function toDataWithIntendedValidatorHash(address validator, bytes memory data) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19\x00", validator, data));
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
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (utils/math/SignedMath.sol)

pragma solidity ^0.8.0;

/**
 * @dev Standard signed math utilities missing in the Solidity language.
 */
library SignedMath {
    /**
     * @dev Returns the largest of two signed numbers.
     */
    function max(int256 a, int256 b) internal pure returns (int256) {
        return a > b ? a : b;
    }

    /**
     * @dev Returns the smallest of two signed numbers.
     */
    function min(int256 a, int256 b) internal pure returns (int256) {
        return a < b ? a : b;
    }

    /**
     * @dev Returns the average of two signed numbers without overflow.
     * The result is rounded towards zero.
     */
    function average(int256 a, int256 b) internal pure returns (int256) {
        // Formula from the book "Hacker's Delight"
        int256 x = (a & b) + ((a ^ b) >> 1);
        return x + (int256(uint256(x) >> 255) & (a ^ b));
    }

    /**
     * @dev Returns the absolute unsigned value of a signed value.
     */
    function abs(int256 n) internal pure returns (uint256) {
        unchecked {
            // must be unchecked in order to support `n = type(int256).min`
            return uint256(n >= 0 ? n : -n);
        }
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (utils/Strings.sol)

pragma solidity ^0.8.0;

import "./math/Math.sol";
import "./math/SignedMath.sol";

/**
 * @dev String operations.
 */
library Strings {
    bytes16 private constant _SYMBOLS = "0123456789abcdef";
    uint8 private constant _ADDRESS_LENGTH = 20;

    /**
     * @dev Converts a `uint256` to its ASCII `string` decimal representation.
     */
    function toString(uint256 value) internal pure returns (string memory) {
        unchecked {
            uint256 length = Math.log10(value) + 1;
            string memory buffer = new string(length);
            uint256 ptr;
            /// @solidity memory-safe-assembly
            assembly {
                ptr := add(buffer, add(32, length))
            }
            while (true) {
                ptr--;
                /// @solidity memory-safe-assembly
                assembly {
                    mstore8(ptr, byte(mod(value, 10), _SYMBOLS))
                }
                value /= 10;
                if (value == 0) break;
            }
            return buffer;
        }
    }

    /**
     * @dev Converts a `int256` to its ASCII `string` decimal representation.
     */
    function toString(int256 value) internal pure returns (string memory) {
        return string(abi.encodePacked(value < 0 ? "-" : "", toString(SignedMath.abs(value))));
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation.
     */
    function toHexString(uint256 value) internal pure returns (string memory) {
        unchecked {
            return toHexString(value, Math.log256(value) + 1);
        }
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation with fixed length.
     */
    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }

    /**
     * @dev Converts an `address` with fixed length of 20 bytes to its not checksummed ASCII `string` hexadecimal representation.
     */
    function toHexString(address addr) internal pure returns (string memory) {
        return toHexString(uint256(uint160(addr)), _ADDRESS_LENGTH);
    }

    /**
     * @dev Returns true if the two strings are equal.
     */
    function equal(string memory a, string memory b) internal pure returns (bool) {
        return keccak256(bytes(a)) == keccak256(bytes(b));
    }
}
// SPDX-License-Identifier: AGPL-3.0

pragma solidity ^0.8.20;

import '@openzeppelin/contracts/utils/Address.sol';
import '@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol';
import '@openzeppelin/contracts/token/ERC20/IERC20.sol';

/// @title ergonomic and robust utility functions to set and reset allowances in a safe way
/// @notice this library is embedded in the contract since it has only internal functions
library ApproveUtils {
        using Address for address;
        using SafeERC20 for IERC20;

        /// @notice ERC20 safeApprove
        /// @dev Gives `spender` allowance to transfer `requiredAmount` of `token` held by this contract
        function safeApproveImproved(IERC20 token, address spender, uint256 requiredAmount) internal {
                uint256 allowance = token.allowance(address(this), spender);

                // only change allowance if we don't have enough of it already
                if (allowance >= requiredAmount) return;

                if (allowance == 0) {
                        // safeApprove works only if trying to set to 0 or current allowance is 0
                        token.safeApprove(spender, requiredAmount);
                        return;
                }

                // current allowance != 0 and less than the required amount
                // first try to set it to the required amount
                try token.approve(spender, requiredAmount) returns (bool result) {
                        // check return status safeApprove() does this for us, but not approve()
                        require(result, 'failed to approve spender');
                } catch {
                        // Probably a non standard ERC20, like USDT

                        // set allowance to 0
                        token.safeApprove(spender, 0);
                        // set allowance to required amount
                        token.safeApprove(spender, requiredAmount);
                }
        }

        /// @dev Reset ERC20 allowance to 0
        function zeroAllowance(IERC20 token, address spender) internal {
                // if already 0 don't do anything (can't be less than 0 because uint)
                if (token.allowance(address(this), spender) == 0) return;

                token.safeApprove(spender, 0);

                require(token.allowance(address(this), spender) == 0, 'failed to zero allowance');
        }
}
// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.20;

contract Constants {
        /// @dev deletes an entry from a whitelist - isn't currently used from the contract. kept for documentation purposes
        bytes32 internal constant ZERO = bytes32(uint256(0));
        /// @dev allow flag in a whitelist - isn't currently used from the contract. reserved for future use
        bytes32 internal constant TRUE = bytes32(uint256(1));


        /// @dev destination role
        bytes32 internal constant ROLE_DESTINATION = bytes32(uint256(2));

        /// @dev provider role
        bytes32 internal constant ROLE_PROVIDER = bytes32(uint256(3));  

        /// @dev signer role
        bytes32 internal constant ROLE_SIGNER = bytes32(uint256(4));


        uint8 internal constant PAY_ALLOWANCE_ERC20 = 1;
        uint8 internal constant PAY_PERMIT2_PERMIT_AND_TRANSFER = 2;
        uint8 internal constant PAY_PERMIT2_TRANSFER = 3;
        uint8 internal constant PAY_PERMIT2_SIG_TRANSFER = 4;
}// SPDX-License-Identifier: AGPL-3.0

/*

 Used only by [swappin.gifts](https://swappin.gifts]) to accept payments in any token or native coin.
 We've designed this contract to be non-upgradable. Once the contract has been deployed to the blockchain, it will never change.
 This guarantee, as provided by the blockchain, together with the complete source code of the contract, will allow any party to verify the security properties and guarantees.
 By putting security and transparency first, we hope to pave the way for a more trustless and trustable ecosystem.
 Clara pacta, boni amici.


                                                             =;                                                                                                 
                                                            ;@f     `z.                                                                                         
                                                           ?@@o    *QR                                                                                          
                                                          T@@@*`^hQ@@~                                                                                          
                               `!vSjv*.                 ~D@@@@%@@@@@B;;~~~:,,'`` `,.                                                                            
                           `^yg@@@}    :i      ``...';iD@@@@@@@@@@@@@@@@@@@@@@@@@QY;~'`                                                                         
                        :zg@@@@@@@Wi*jQ@875q8Q@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@bod@@@@@@QNKa7<;,.     `                                                         
                      z@@@@@@@@@@@@@@@@@@@@@@@DXUd&@@@@@@@@@@@@@@@@@@@@@@@@@RjjQ@@@@@@@@@@@@@@@@@@@Qm<`                                                         
                      +@@@Q@@@@@@@@@@@@@@@@Qf;,`,7N@@@@@@@@@@@@@@@@@@@@@@NoqQ@@@@@@@@@@@@@@@@@@NESE%@@@Q86}|~`                                                  
                       @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@goZhQ@DqbbD%BQ@@@@QB8E7hXAN@@@@@@@@@@@@@@QE=.                                              
                       5@@b;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@&hz?!^hgQ@@@@@@@@Q&#%655XqRQyj8@@@@@@@@@@@@@@@@@@@q*.                                           
                       'Q@@`x@z8@@@@@@@@@@@@@@@@@@@@@@@@@Qbj\r,``;fDQQQWE|;,~~~~,!czzzfEqQ@@@@WE6DQ@@@@@@@@@@@@@@@@@@Bj+`                                       
                        'Q@y |~`qf .~wbDDgWD%Q@@@@@@@@@@@@@@@@@@@@QWEL,7yjz+,   ,?7yXqUSc;.~?}URQ@QNQQQQBb57|=*s}yZShXqDDy?^'                                   
                         `6@*    ~   ,Q@@@@@@Kj@@@@@@@@@@@@@@@@@@@@@@@@Ez@@@@@QQ@Q@@@@@@@Qw^Z6yc;   ,\i>~'z8QQbUK@@@@@@@@@@W%D%j!                               
                           ^Q|      ;Q@@@@@QDk<@@@@@@@@@@@@@@@RkXN@@@@@@RL@@@@@@@Q*}@@@@@@@z`Q@@@@E,'|{XQQa=*K@@@qyQ@@@@@@@@@@bAQQ^                             
                            `\i`  ~D@@@@@DDQQ^b@@@@@@auQ@@@kT=vi^>~Q@@@@@{@@@@@@Y``d@@@@@@j ,@@@@@@@^:QgJ~~^^`'7W@@yS@@@@@@@@@@@NQ@U`                           
                               `;D@@@@#XD@U; +@@@@@@@@P,Bi`~.7@@{DTX@@@@X@@@@%i` =Q@@@@87'`z@@@@@@@@j K@@@6,`:   `^jDKg8Q@@@@@@@@@@@Q;                          
                              ,D@@@@KY8@I`  ;@@@@@@@@@Qi  ~@h+%czNu@@@QyQ@#J_~<SQ@Q%qX*=76@@@@@@@@Qi'}@@@@@Q ;Nx.   '`'r^':^|zjm6DNQ@@d;                        
                          `?6J@@@@o^J@Zqy: *@@@@@gSoLvEy   ?f\JgKB@@RLi5*''<aR8BNkjz^!yD%8BQ8D6mwZjg@@@@@@@7 'g@@E``;ERaK@BE>~DNQQQNDdaLu\`                     
                        ~U@@LN@@hsBhQI`7@@@@@@@jjN@Q@~     ~yNb8@gRu,     !R67^,     .\aEZs|!, 'iUg#%Ayz|;`_j@@@@@8 ;%}6@od@@QP@@@@@@@@@U|EK*`                  
                      ,D@@@@;@#iW@!.@@@%@@@@@j7QQf_ {    ;Dg6E%%Wq<      .r`        `,`       ~XE7^_,nNQQQ@@@@@@@@@, y@K;j*L@@Q@@@@@@@@@@@%K@Q;                 
                   ~*.@@@@@@~^=@g' j@@@@@@d}n8m~       `6D~:IQQs'                             '        .^nKQ@@@@Q%c  }@@Q.  `iQQ@@@@@@@@@@@@@@@;                
                  !@Q'@@@@@Q^=@f    `~;;^=7T~          D\  DD!                                               ;xi?<*7b@@@@k j:  ~ugQQ#@@@@@@@@@@Q`               
                .JJ@@d*@@@QRxQ?                       .=  ^!                                                  `?6Q@@@@@@@^ i@m`XE+.\wc;;*zSdQ@@@Q,              
               i} s@@@w^gk8%m;                            `                                                       .;?vz|. `D@@d`A@Q+A@@Qz}@@Q%DKDQE,            
             .K7 'Q@@@@'.QQ;L                                                                                      !s7c7fq@@@@@,a^yB~7@@@aQ@@@@@@@@K'           
            ~Q7 .Q@@@@@L5#''                                                                                        .ibQ@@@@@@@'f@~ , ,D@@y@@@@@@@@@QI.         
           =@#z;Q@@@@QDI~                                                                                              '~^in{\' y@@;    !D@q@@@@@@@@@@@o`       
          <Q!b@q@@@@UA@:                                                                                                =qDSIzjB@@@#      ~U%DQ@@@@@@@@@j       
         ?@~`@@NW@gYQ@!     .s.                                                                                           _yQ@@@@@@@`b. dj' >f|!7g@@@@@@@`      
        <@i z@@@u^t@@^     ,Q~                                                                                               _\mDBq* 8#`b@@z{@@NS,IZ8@@@@^      
       =@k ;@@@@@`K@~   ^`!@o                                                                                               ^7;`    !@@y_R@@_Q@@@5@@QN@@@B.     
       QQ``Q@@@@@o@~  'E:z@@.                                                                                                ~W@@QQ@@@@Q,'<Qy,@@@6@@@@@@hQ6+`   
    *\`@< 6@@@@@@h8  ~d'k@@a=                                                                                                  ;q@@@@@@h!Q`.K.,#@h@@@@@@@@@j    
    ~@Q@ ;@@@@@@AQa ~B'N@@@^%  !                                                                                                '`!7jY^ j@\  , `Dd@@@@@@@@@@}   
    !@@@;}@@@@@RP@!'Q;kQ=@g7W`{,                                                                                                _%n^,,+E@@D   ' `oE@@@@@@@@@U   
    b%W@@jQ@@@mb@j`Bj>qy{EjUQB|                                                                                                  ,Q@@@@@@@B ! Wy .;;g@@@@@@@E   
   <@;N@@@Az%*Q@N`EQ`=7@z;=K@;                                                                                                     +8@@@@@n D~%@j+@s.,E@@@@@a   
  :@Q,@@@@@Q;`Q@'z@z ~@@|  ;`                                                                                                     `\_'*ti~ ~@L|@Q~@@@L6zuQ@@R   
  #@a<@@@@@@@\!,,@@, Q@@^ ,                                                                                                        ;@Q{^;!}@@* L@`@@Qk@@@y|D@?  
 `@@vI@@@@@@@@@'q@@`^@@@!=jD                                                                                                        L@@@@@@@@'  y.6@mQ@@@@#`y@~ 
  Q@|J@@@@@@@@@7U@Q d@@@;K~@                                                                                                        .;Q@@@@@?`+   ~@n@@@@@@;'Q<`
'sz@}~@@@@@@@d@{`A,`@@@@;a7q'                                                                                                       SL`=5P}, of    P{Q@@@@@7 @+ 
 'Q@@|i@@@@Q|@@_   ,@KQ@r|@;~                                                                                                       _@W+'``_m@| ~y `hk@@@@@U @Q 
  v@h@QAD@@;N@B    ~@',Q\,@>`                                                                                                        w@@@@@@@Q` 8@: 'm@@@@@Q @@+
  *@.D@@@k*.N@L    :g?+'< Q7                                                                                                        .`U@@@@@%, .@@^,y,a@@@@@;@@~
  j@:?@@@@@U+z`  <=`yx@!  zi                                                                                                        c; ;fP};_7  Qh Q@@,=@@@@Q@| 
  %@^'@@@@@@@Qf` @@7 n@@i .^                                                                                                        7@!    ^@,  |`?@@@<6hg@@@u  
  %@5 X@@@@@@@8Q`y@@`v@@@* `                                                                                                        ;@@Q6XQ@j     R@%X@@@#|Q@~  
  L@Q ~@@@@@@@DQX`X@ ^@@@@;                                                                                                        ``w@@@@@y      Q@Q@@@@@=`@n  
   T@| j@@@@@@N%@,`= `@@@@@:                                                                                                       {f ;Jjz,~` ;X  Q@@@@@@@f,@S  
  `iU@! j@@@@@RN@z    q@@@@@:                                                                                                     `Q@j' `;Uf U@@~ hQ@@@@@@hy@R  
   `d@@gnjd@@@6Q@U    ,@@i;U@:                                                                                                    '@@@@@@@5 ^@#^`o_n@@@@@@Q@@+  
     W@SQ@@#DK*~RD     L@L '~d~                                                                                                  h f@@@@g^  Kj `B@i`7@@@@@@@!   
     ,QQ:Q@@@@@S;>   `' ?j NX;;                                                                                                 ^@, :\i;,  `? `d@@Q.`b@@@@Q~    
      ,@D'@@@@@@@%Kn` QS:. c@@Q>                                                                                                Q@Qj!;}a      6@Qaq@Q;@@@Q`     
       ,Qx*@@@@@@@@6@^7@@D,`Q@@@B;                                                                                             '@@@@@@i .T;  +@XZ@@@@X^@@i      
        .8~h@@@@@@@E@@i;6@y ,@@@@@k`                                                                                        ~D `@@@@j. u@@+  QuN@@@@@g K@~      
         `U.!R@@@@@Qm@@* ,s  _Q@@@@Q|                                                                                      ;@Q  |7~`` ?@@@~.~D@@@@@@@{'ES`      
          ^WUtJoPURQ'K@@^     'N@D*oWf                                                                                    ,@@@K*^Tf^  Q&|;AE'@@@@@@@B'W+        
           `qQ@@@@QDy?rc;      `5Q !i?;                                                                                `T R@@@@@Q*   ;;`k@@j B@@@@@@!gQ         
            `S;g@@@@@@@#Ay;  *Nz,;.;@@@@dL'                                                                          `{@f X@@@U!      ,Q@@djq7@@@@@zQ@7         
             ;g`|@@@@@@@@qN%_ E@@Q' =@@@@@@b;                                                                       ,Q@@D. ',;*' ~   'Q@kk@@@^@@@@d@@R`         
              mQ,'Z@@@@@@@qB@j'^h@g  !@@@@QQ@D,                                                                 's:'@@@@@@QQE!!h@\  `QDA@@@@@iZ@@@@q;           
              `Q@^ ;g@@@@@@y8@Q+ `*;  ,D@@; `;^.                                                              `f@D Z@@@@Qw=` v@@Q ,^zBQ@@@@@@;;@@y,             
               `A@b'`~zkd%RD!+zi'``   ``^#|'@@@@@#EL:                                                     .  ^Q@@8.,rvz=    i@U*^D@*d@@@@@@@f !R'               
                 :7%@bQ@@@@@@@@@QWdKy{;i#XE,z@@@@@@@@@q*`                                             `^ZN; ^@@@@@@@@d^`    : ;D@@?`5@@@@@@z`Sq`                
                    '{'`~y@@@@@@@@@@@68QhKQ@7,q@@@@N^:,;+'`                                         +X@@@~  g@@@@Qh*. ';`   ;d@QKyU^@@@@@Q;+QN`                 
                     `A\` `}@@@@@@@@@@%6@@k~^: 'v#@Q',Q@@@@@@@Qdy*_                         `!zSX_+Q@@@@Q*^;zjs+  YQ@@D,  `EWgWQ@@@P@@@@z;D@Q.                  
                      `BQ=  'jQ@@@@@@@@DJgQD'     ~Yqr|Q@@@@@@w\>;,.~!=||*^;:.      `,!**~*d@@@B' @@@@@@@@@@@87.`a@@@y `''y%@@@@@@@q@@B>k@@Q~                   
                       'W@Qyi<^v5UKKbKKquiJdN%Kyz;!mZY~ ;oQ@@@; !qQ@@@@@@@@w?~.'*aW@@@E;>Q@@@@@K;'^EgQQgK5i;`  ,wm7*TSQ@,<@@@@@@@@id@gq@8o!                     
                         !wQ@U|\ag@@@@@@@@@@@@@#k@@E{SR|   '=aBX~?b@@@@@@D` `{&@@@@@@L  R@@@@@@@@@@gj<,'jXK%j`   ~S@@@W:.@@@@@@@K,,@Qy;`                        
                            `;iv,  _\8@@@@@@@@@@@m@@@%^     '\yuS! `!{bQ@@Bi~{R@@@@@@@@NUKKEI=!;,`  `!q@@@Wr  .uQ@@QgDQRY@@@@@D~`LNc                            
                                \K>`  ,fQ@@@@@@@QU,,~?nSPaUDXfYyjSL      `,^xJ!``'~;;!^^;;|uzL*+;  'i7\L?^,``zQ@@@@@@@@*Q@@@P~~a@D.                             
                                 ,WQZ;   ;\o5Ti\zkN@@@@@@@N%%RQ@QqY'      ~d@@@@A?`    <KQ@@@Qj^` ';i}UgQ@T~Q@@@@@@@@@S=@@K+7%@@y`                              
                                   ^6@QZ+;|o%@@@@@@@@@@@@@@@@Q+`,+\nSqDQQ%XYcI\*!~' `'''_^*?'`+}R@@QQQQQK,7@@@@@@@@@@u`W@dD&KaL'                                
                                      `,;|h@6fUB@@@@@@@@@QmnzjDQ@@@@@@@WDq6byi|izykb8Q@@@Qy+cXKD%NQQQQQQ!L@@@@@@@@8\,+fn~`                                      
                                           .aQUi;,!|zJcr*w@@@@@@@@@@@@@@@Q*`^PAgQ@@@QWwv. 'fQ@@@@@@@@@@@_@@@@@@bucyBQ<                                          
                                             ,h@@@8a7TwQ@@@@@@@@@@@@@@@Di*A@@@@@@@@@@@@L;A@@@@@@@@@@@@8_D@@@@@8Q@@WL`                                           
                                               .^<<+!!\6NDwYzfEK8Q@@Qy|yQ@@@@@@@@@@@@Q!S@@@@@@@@@@&U7!~y@QdE}T*!_.                                              
                                                         ;yQ@QKo7<^~iN@@Q%K6U66qqqUm*i@@@@@@N6a}JYEwt<=z'                                                       
                                                            `!czv|z7<<sERBgDqUUkkXomQ@QRdDDDDbqXy>'                                                             
                                                                         .^z5aY?~`~T;`                                                                          

*/

pragma solidity ^0.8.20;

import '@openzeppelin/contracts/utils/Address.sol';
import '@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol';
import '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import '@openzeppelin/contracts/security/ReentrancyGuard.sol';
import '@openzeppelin/contracts/utils/cryptography/ECDSA.sol';
import './Whitelist.sol';
import './ApproveUtils.sol';
import './IPermit2.sol';
// import 'hardhat/console.sol';

///
/// @title Used only by [swappin.gifts](https://swappin.gifts]) to accept payments in any token or native coin.
/// @author swappin.gifts
/// @notice We've designed this contract to be non-upgradable. Once the contract has been deployed to the blockchain, it will never change.
/// @notice This guarantee, as provided by the blockchain, together with the complete source code of the contract, will allow any party to verify the security properties and guarantees.
/// @notice By putting security and transparency first, we hope to pave the way for a more trustless and trustable ecosystem.
/// @notice Clara pacta, boni amici.
/// @dev Supports payment with several different ERC20 tokens and ETH in one transaction, NFT mint & burn, Permit2.
/// @dev See README.md for more information.
///
contract Gateway is ReentrancyGuard, Whitelist {
        using Address for address;
        using SafeERC20 for IERC20;
        using ApproveUtils for IERC20;

        IPermit2 public immutable PERMIT2;

        /// @notice emitted on succesfull payment
        event Payment(bytes32 indexed orderId, uint64 indexed refId, address indexed dest, address tokenTo, uint256 amount);

        /// @notice emitted on succesfull execution of execute()
        event ExecuteEvent(int8 indexed eventType, bytes32 eventData);

        constructor(address _permit2Address) {
                PERMIT2 = IPermit2(_permit2Address);
        }

        ///
        /// @notice The create2 constructor alternative. Initializes the whitelist and sets the owner.
        /// @dev Setting the owner this way is secure because the DeterministicDeployFactory.deploy() is onlyOwner.
        /// @dev `_dests` and `_tokens` are pairs so arrays must have same length. Same applies to `_providers` and `_providerSpenders`.
        ///
        /// @param _dests array of allowed destination wallets
        /// @param _tokens array of allowed destination tokens
        /// @param _providers array of allowed swap providers
        /// @param _providerSpenders array of allowed swap provider spender contracts (sometimes not the same as the provider main contract)
        /// @param _signers array of allowed signers
        /// @param _ownerAddress the constructor will transfer ownership to this account
        ///
        function init(
                address[] memory _dests,
                address[] memory _tokens,
                address[] memory _providers,
                address[] memory _providerSpenders,
                address[] memory _signers,
                address _ownerAddress
        ) external onlyOwner {
                // make sure pair lists lengths match
                require(_providers.length == _providerSpenders.length, 'providers and providerSpenders length differs');
                require(_dests.length == _tokens.length, 'destinations and tokens length differs');

                // fill white list of providers
                setProviders(_providers, _providerSpenders, TRUE);

                // fill white list of destinations
                setDestinations(_dests, _tokens, TRUE);

                // fill white list of signers (for execute() method)
                setSigners(_signers, TRUE);

                // transfer ownership to final owner
                transferOwnership(_ownerAddress);
        }

        ////
        //// @notice Pay with any token or ETH, converting on the fly into toToken.
        //// @dev
        //// @dev This entry point supports 
        //// @dev 1. ERC20 allowance flow.
        //// @dev 2. Permit2 SignatureTransfer allowance flow.
        //// @dev 3. AllowanceTransfer allowance flow - permit & transfer.
        //// @dev 4. AllowanceTransfer allowance flow - transfer (allowance exists).
        ////
        //// @notice This external method is for the simple use case of payment alone. 
        ///  @notice For complex txs that include additional operations such as mint and redeem, execute() is used.
        ////
        //// @param orderInfo order info
        //// @param swapInfo swap info
        //// @param paymentMethod data specific to the selected payment flow type
        ////
        function payWithAnyToken(OrderInfo memory orderInfo, TokenSwapInfo[] memory swapInfo, PaymentMethodInfo memory paymentMethod) external payable nonReentrant {
                _payWithAnyToken(orderInfo, swapInfo, paymentMethod);
        }

        ///
        /// @notice Composes several tx in one meta tx.
        /// @dev Executes a signed list of tx.
        /// @dev Signature verification protects against tampering.  
        /// @dev Contained tx are unsigned, which prevents their extraction (i.e. mint without payment).
        /// @dev 
        ///
        function execute(Tx[] calldata txs, int8 eventType, bytes32 eventData, bytes calldata signature) external payable nonReentrant {
                _requireValidSigned(ECDSA.toEthSignedMessageHash(keccak256(abi.encode(address(this), block.chainid, txs, eventType, eventData))), signature);

                uint len = txs.length;
                for (uint i = 0; i < len; ) {
                        Tx calldata t = txs[i];
                        address to = t.to;
                        bytes calldata data = t.data;

                        if (to == address(this)) {
                                // call the payment function directly and internaly
                                (OrderInfo memory orderInfo, TokenSwapInfo[] memory swapInfo, PaymentMethodInfo memory paymentMethod) = abi.decode(
                                        data,
                                        (OrderInfo, TokenSwapInfo[], PaymentMethodInfo)
                                );
                                _payWithAnyToken(orderInfo, swapInfo, paymentMethod);
                        } else if (t.value > 0) {
                                // optionaly appends msg.sender
                                to.functionCallWithValue(t.msgSender ? abi.encodePacked(data, msg.sender) : data, t.value);
                        } else {
                                // optionaly appends msg.sender 
                                to.functionCall(t.msgSender ? abi.encodePacked(data, msg.sender) : data);
                        }

                        unchecked {
                                ++i;
                        }
                }

                emit ExecuteEvent(eventType, eventData);
        }

        function _payWithAnyToken(OrderInfo memory orderInfo, TokenSwapInfo[] memory swapInfo, PaymentMethodInfo memory paymentMethod) private {
                IERC20 tokenTo = orderInfo.tokenTo;
                address dest = orderInfo.dest;

                // validation. save start balance
                uint256 destStartBalance = paymentStart(tokenTo, dest);

                // transfer to this contract or dest from user wallet
                transferFromSender(orderInfo, swapInfo, paymentMethod);

                // swap tokens and ETH to toToken and transfer to 'dest'
                executeSwaps(swapInfo, tokenTo, dest);

                // verify that 'minAmountTo' of 'tokenTo' added to 'dest'
                uint256 totalAmountReceived = verifyFinalAmounts(destStartBalance, tokenTo, dest, orderInfo.minAmountTo);

                emit Payment(orderInfo.orderId, orderInfo.refId, dest, address(tokenTo), totalAmountReceived);
        }

        function transferFromSender(OrderInfo memory orderInfo, TokenSwapInfo[] memory swapInfo, PaymentMethodInfo memory paymentMethod) private {
                if (paymentMethod.methodType == PAY_ALLOWANCE_ERC20) {
                        transferByErc20Allowance(orderInfo, swapInfo);
                } else if (paymentMethod.methodType == PAY_PERMIT2_PERMIT_AND_TRANSFER) {
                        permit2PermitAndTransfer(paymentMethod.methodSpecificData);
                } else if (paymentMethod.methodType == PAY_PERMIT2_TRANSFER) {
                        permit2ValidateAndTransfer(abi.decode(paymentMethod.methodSpecificData, (IPermit2.AllowanceTransferDetails[])));
                } else if (paymentMethod.methodType == PAY_PERMIT2_SIG_TRANSFER) {
                        permit2SigTransfer(paymentMethod.methodSpecificData);
                } else {
                        revert('unknown paymentMethod');
                }
        }

        /// @notice Permit2 SignatureTransfer single-use permit & transfer
        /// @dev Transfer tokens from msg.sender to this contract
        /// @dev Transfer toTokens directly to 'dest'
        /// @dev Permit2 provides batch transfer, which can be used only once for all the tokens in one call
        function permit2SigTransfer(bytes memory methodSpecificData) private {
                Permit2SignatureBatch memory permit2 = abi.decode(methodSpecificData, (Permit2SignatureBatch));
                PERMIT2.permitTransferFrom(permit2.permit, permit2.transferDetails, msg.sender, permit2.permit2Signature);
        }

        /// @notice Permit2 AllowanceTransfer permit & transfer
        /// @dev Transfer tokens from msg.sender to this contract
        /// @dev Transfer toTokens directly to 'dest'
        /// @dev Permit2 provides batch transfer, which can be used only once for all the tokens in one call
        function permit2PermitAndTransfer(bytes memory methodSpecificData) private {
                Permit2AllowanceBatch memory permit2 = abi.decode(methodSpecificData, (Permit2AllowanceBatch));

                // first permit the allowance
                PERMIT2.permit(msg.sender, permit2.permit, permit2.permit2Signature);

                // next perform the transfer
                permit2ValidateAndTransfer(permit2.transferDetails);
        }

        /// @notice Permit2 AllowanceTransfer just transfer
        /// @dev Validates the batch and then
        /// @dev Transfer tokens from msg.sender to this contract
        /// @dev Transfer toTokens directly to 'dest'
        /// @dev Permit2 provides batch transfer, which can be used only once for all the tokens in one call
        function permit2ValidateAndTransfer(IPermit2.AllowanceTransferDetails[] memory batchDetails) private {
                // make sure it's only msg.sender operating on his own tokens
                validatePermit2Batch(batchDetails);

                // perform transfers
                PERMIT2.transferFrom(batchDetails);
        }

        /// @notice ERC20 allowance flow - batch ERC20.safeTransferFrom()
        /// @dev Transfer tokens from msg.sender to this contract
        /// @dev Transfer toTokens directly to 'dest'
        function transferByErc20Allowance(OrderInfo memory orderInfo, TokenSwapInfo[] memory swapInfo) private {
                uint256 batchLen = swapInfo.length;
                // transfer tokens from sender to this contract. or to dest (if tokenFrom=tokenTo)
                for (uint i = 0; i < batchLen; ) {
                        TokenSwapInfo memory s = swapInfo[i];
                        IERC20 tokenFrom = s.tokenFrom;

                        // Skip ETH swap entries
                        if (address(tokenFrom) != address(0)) {
                                // Send to 'dest' (if tokenTo) or to this contract (if requires conversion to tokenTo first)
                                tokenFrom.safeTransferFrom(msg.sender, tokenFrom == orderInfo.tokenTo ? orderInfo.dest : address(this), s.amountFrom);
                        }

                        unchecked {
                                ++i;
                        }
                }
        }

        function paymentStart(IERC20 tokenTo, address dest) private view returns (uint256) {
                // destination address and token are white listed
                require(_isValidDestination(dest, address(tokenTo)), 'unknown destination');

                // return start balance of dest
                return tokenTo.balanceOf(dest);
        }

        function executeSwaps(TokenSwapInfo[] memory swapInfo, IERC20 tokenTo, address dest) private returns (uint256) {
                uint256 totalAmountReceived = 0;

                uint256 batchLen = swapInfo.length;
                for (uint i = 0; i < batchLen; ) {
                        TokenSwapInfo memory s = swapInfo[i];

                        // don't swap the tokenTo token
                        if (s.tokenFrom == tokenTo) {
                                // basic input checks
                                require(s.minAmountTo > 1, 'invalid minAmountTo');
                                require(s.amountFrom > 0, 'invalid amountFrom');
                        } else {
                                if (address(s.tokenFrom) == address(0)) {
                                        // call provider to convert ETH to tokenTo
                                        totalAmountReceived += swapEth(s, tokenTo);
                                } else {
                                        // call provider to convert tokenFrom to tokenTo
                                        totalAmountReceived += swapToken(s, tokenTo);
                                }
                        }

                        unchecked {
                                ++i;
                        }
                }

                // transfer received tokenTo from all swaps to dest address
                if (totalAmountReceived > 0) {
                        tokenTo.safeTransfer(dest, totalAmountReceived);
                }

                return totalAmountReceived;
        }

        ///
        /// @notice Call DEX provider to convert ETH to `token`
        ///
        function swapEth(TokenSwapInfo memory swapInfo, IERC20 tokenTo) private returns (uint256) {
                uint256 minAmountTo = swapInfo.minAmountTo;
                uint256 amountFrom = swapInfo.amountFrom;
                address swapProvider = swapInfo.swapProvider;

                // provider address is white listed
                require(_isValidProvider(swapProvider), 'unknown provider');
                require(minAmountTo > 1, 'invalid minAmountTo');
                require(amountFrom > 0, 'invalid amountFrom');

                // save this contract's ETH  balance
                uint256 ethStartBalance = address(this).balance;
                // save this contract's token balance
                uint256 startBalance = tokenTo.balanceOf(address(this));

                // call provider to convert ETH to token
                swapProvider.functionCallWithValue(swapInfo.swapCalldata, amountFrom);

                // verify received tokens amount from provider
                uint256 receivedAmount = tokenTo.balanceOf(address(this)) - startBalance;
                require(receivedAmount >= minAmountTo, 'invalid amount of token from swap provider');

                // verify transfered exactly the received ETH to provider
                require(ethStartBalance - address(this).balance == amountFrom, 'invalid amount transferred to swap provider');

                // return the actual amount calculated from balances (not what the provider might have returned)
                return receivedAmount;
        }

        ///
        /// @notice Call DEX provider to convert `tokenFrom` to `tokenTo`
        ///
        function swapToken(TokenSwapInfo memory swapInfo, IERC20 tokenTo) private returns (uint256) {
                uint256 minAmountTo = swapInfo.minAmountTo;
                uint256 amountFrom = swapInfo.amountFrom;
                address swapProvider = swapInfo.swapProvider;
                address providerSpender = swapInfo.providerSpender;
                IERC20 tokenFrom = swapInfo.tokenFrom;

                // provider address and provider spender address are white listed
                require(_isValidProviderSpender(swapProvider, providerSpender), 'unknown provider');
                require(minAmountTo > 1, 'invalid minAmountTo');
                require(amountFrom > 0, 'invalid amountFrom');

                // allow providerSpender to spend amountFrom of tokenFrom tokens held by this contract
                tokenFrom.safeApproveImproved(providerSpender, amountFrom);

                // save start tokenTo balance
                uint256 startBalance = tokenTo.balanceOf(address(this));

                // call swap provider
                swapProvider.functionCall(swapInfo.swapCalldata);

                // verify tokenTo amount received from provider corresponds to what was quoted
                uint256 receivedAmount = tokenTo.balanceOf(address(this)) - startBalance;
                require(receivedAmount >= minAmountTo, 'received invalid destToken amount from swap provider');

                // reset providerSpender allowance to 0
                tokenFrom.zeroAllowance(providerSpender);

                // return the actual amount calculated from balances
                return receivedAmount;
        }

        ///
        /// @notice Verify final payment amount 
        ///
        function verifyFinalAmounts(uint256 destStartBalance, IERC20 tokenTo, address _dest, uint256 minAmountTo) private view returns (uint256) {
                // total amount of tokenTo added to 'dest' since getting 'destStartBalance'
                uint256 totalAmountReceived = tokenTo.balanceOf(_dest) - destStartBalance;

                require(totalAmountReceived >= minAmountTo, 'invalid amount transfered to dest');

                return totalAmountReceived;
        }

        ///
        /// @notice Verifies signature and signer
        ///
        function _requireValidSigned(bytes32 hash, bytes calldata signature) private view returns (bool) {
                (address recovered, ECDSA.RecoverError error) = ECDSA.tryRecover(hash, signature);

                require(error == ECDSA.RecoverError.NoError && _isValidSigner(recovered), 'execute: invalid signature or signer');

                return true;
        }

        function validatePermit2Batch(IPermit2.AllowanceTransferDetails[] memory batchDetails) private view {
                uint256 batchLength = batchDetails.length;
                for (uint256 i = 0; i < batchLength; ) {
                        require(batchDetails[i].from == msg.sender, 'from address is not owner');
                        unchecked {
                                ++i;
                        }
                }
        }

        struct Tx {
                address to;
                uint256 value;
                bool msgSender;
                bytes data;
        }

        struct OrderInfo {
                bytes32 orderId;
                uint64 refId;
                address dest;
                IERC20 tokenTo;
                uint256 minAmountTo;
        }

        struct TokenSwapInfo {
                address swapProvider;
                address providerSpender;
                IERC20 tokenFrom;
                uint256 amountFrom;
                uint256 minAmountTo;
                bytes swapCalldata;
        }

        struct PaymentMethodInfo {
                uint8 methodType;
                bytes methodSpecificData;
        }

        struct Permit2AllowanceBatch {
                IPermit2.PermitBatch permit;
                IPermit2.AllowanceTransferDetails[] transferDetails;
                bytes permit2Signature;
        }

        struct Permit2SignatureBatch {
                IPermit2.PermitBatchTransferFrom permit;
                IPermit2.SignatureTransferDetails[] transferDetails;
                bytes permit2Signature;
        }
}
// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.20;

import '@openzeppelin/contracts/token/ERC20/IERC20.sol';

/// @title Just what is used from the Permit2 interface
interface IPermit2 {

        /// @notice The permit data for a token
    struct PermitDetails {
        // ERC20 token address
        address token;
        // the maximum amount allowed to spend
        uint160 amount;
        // timestamp at which a spender's token allowances become invalid
        uint48 expiration;
        // an incrementing value indexed per owner,token,and spender for each signature
        uint48 nonce;
    }

    /// @notice Details for a token transfer.
    struct AllowanceTransferDetails {
        // the owner of the token
        address from;
        // the recipient of the token
        address to;
        // the amount of the token
        uint160 amount;
        // the token to be transferred
        address token;
    }

    /// @notice The permit message signed for multiple token allowances
    struct PermitBatch {
        // the permit data for multiple token allowances
        PermitDetails[] details;
        // address permissioned on the allowed tokens
        address spender;
        // deadline on the permit signature
        uint256 sigDeadline;
    }

   /// @notice Permit a spender to the signed amounts of the owners tokens via the owner's EIP-712 signature
    /// @dev May fail if the owner's nonce was invalidated in-flight by invalidateNonce
    /// @param owner The owner of the tokens being approved
    /// @param permitBatch Data signed over by the owner specifying the terms of approval
    /// @param signature The owner's signature over the permit data
    function permit(address owner, PermitBatch memory permitBatch, bytes calldata signature) external;


    /// @notice Transfer approved tokens in a batch
    /// @param transferDetails Array of owners, recipients, amounts, and tokens for the transfers
    /// @dev Requires the from addresses to have approved at least the desired amount
    /// of tokens to msg.sender.
    function transferFrom(AllowanceTransferDetails[] calldata transferDetails) external;

    
    // Token and amount in a permit message.
    struct TokenPermissions {
        // Token to transfer.
        IERC20 token;
        // Amount to transfer.
        uint256 amount;
    }

    // Transfer details for permitTransferFrom().
    struct SignatureTransferDetails {
        // Recipient of tokens.
        address to;
        // Amount to transfer.
        uint256 requestedAmount;
    }

    struct PermitBatchTransferFrom {
        // the tokens and corresponding amounts permitted for a transfer
        TokenPermissions[] permitted;
        // a unique value for every token owner's signature to prevent signature replays
        uint256 nonce;
        // deadline on the permit signature
        uint256 deadline;
    }

    function permitTransferFrom(
        PermitBatchTransferFrom memory permit,
        SignatureTransferDetails[] calldata transferDetails,
        address owner,
        bytes calldata signature
    ) external;    
}// SPDX-License-Identifier: AGPL-3.0

pragma solidity ^0.8.20;

import '@openzeppelin/contracts/utils/Address.sol';
import '@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol';
import '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import '@openzeppelin/contracts/security/ReentrancyGuard.sol';
import '@openzeppelin/contracts/access/Ownable.sol';
import './Constants.sol';

/// @title A whitelist for provider addresses and destination addresses
/// @notice Use by inheriting
contract Whitelist is Ownable, Constants {
        /// @dev roles
        mapping(bytes32 => bytes32) public _roles;

        /// @notice  on added/removed destination
        event UpdatedDestination(address indexed dest, address indexed token, bytes32 status);

        /// @notice  on added/removed provider
        event UpdatedProvider(address indexed provider, address indexed providerSpender, bytes32 status);

        /// @notice  on added/removed signer
        event UpdatedSigner(address indexed frowarder, bytes32 status);

        constructor() {}

        /// @dev Returns current status flag for destination
        function _isValidDestination(address dest, address token) internal view returns (bool) {
                return _roles[keccak256(abi.encode(dest, token, ROLE_DESTINATION))] == TRUE;
        }

        /// @dev Returns current status flag for provider and spender address combination
        function _isValidProviderSpender(address providerAddress, address spenderAddress) internal view returns (bool) {
                return _roles[keccak256(abi.encode(providerAddress, spenderAddress, ROLE_PROVIDER))] == TRUE;
        }

        /// @dev Returns current status flag for provider address
        function _isValidProvider(address providerAddress) internal view returns (bool) {
                return _roles[keccak256(abi.encode(providerAddress, ROLE_PROVIDER))] == TRUE;
        }

        /// @dev Returns if signer is valid
        function _isValidSigner(address signerAddress) internal view returns (bool) {
                return _roles[keccak256(abi.encode(signerAddress, ROLE_SIGNER))] == TRUE;
        }

        /// @dev Adds/deletes the given destinations from the white list
        function setDestinations(address[] memory dests, address[] memory tokens, bytes32 flag) public onlyOwner {
                uint256 len = dests.length;
                for (uint256 i = 0; i < len; i++) {
                        emit UpdatedDestination(dests[i], tokens[i], flag);
                        _roles[keccak256(abi.encode(dests[i], tokens[i], ROLE_DESTINATION))] = flag;
                }
        }

        /// @dev Adds/deletes the given signer from the white list
        function setSigners(address[] memory signers, bytes32 flag) public onlyOwner {
                uint256 len = signers.length;
                for (uint256 i = 0; i < len; i++) {
                        emit UpdatedSigner(signers[i], flag);
                        _roles[keccak256(abi.encode(signers[i], ROLE_SIGNER))] = flag;
                }
        }

        /// @dev Adds/deletes the given providers from the white list
        function setProviders(address[] memory _providers, address[] memory _providerSpenders, bytes32 flag) public onlyOwner {
                uint256 len = _providers.length;
                for (uint256 i = 0; i < len; i++) {
                        emit UpdatedProvider(_providers[i], _providerSpenders[i], flag);
                        _roles[keccak256(abi.encode(_providers[i], ROLE_PROVIDER))] = flag;
                        _roles[keccak256(abi.encode(_providers[i], _providerSpenders[i], ROLE_PROVIDER))] = flag;
                }
        }
}
