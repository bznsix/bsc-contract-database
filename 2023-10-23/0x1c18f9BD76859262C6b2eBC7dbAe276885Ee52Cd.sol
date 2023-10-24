// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface AggregatorV3Interface {
  function decimals() external view returns (uint8);

  function description() external view returns (string memory);

  function version() external view returns (uint256);

  function getRoundData(uint80 _roundId)
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );

  function latestRoundData()
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );
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
// OpenZeppelin Contracts (last updated v4.9.0) (utils/math/SafeMath.sol)

pragma solidity ^0.8.0;

// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is generally not needed starting with Solidity 0.8, since the compiler
 * now has built in overflow checking.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator.
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {trySub}.
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting with custom message when dividing by zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryMod}.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}
pragma solidity >=0.5.0;

interface IUniswapV2Factory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
}
pragma solidity >=0.5.0;

interface IUniswapV2Pair {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address owner) external view returns (uint);

    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;

    event Mint(address indexed sender, uint amount0, uint amount1);
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint);
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function price0CumulativeLast() external view returns (uint);
    function price1CumulativeLast() external view returns (uint);
    function kLast() external view returns (uint);

    function mint(address to) external returns (uint liquidity);
    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;

    function initialize(address, address) external;
}
pragma solidity ^0.8.2;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Pair.sol";
import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Factory.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract AbxOracle is Ownable {
    AggregatorV3Interface public priceFeed;
    using SafeERC20 for IERC20;
    using SafeMath for uint256;
    address public PancakeFactory = 0xcA143Ce32Fe78f1f7019d7d551a6402fC5350c73; //
    address public BNBToken = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c; //
    address public ABXToken = 0x00ABf6CD520629462127a178026c331fCc41BB8B; //

    constructor() {
        priceFeed = AggregatorV3Interface(
            0x0567F2323251f0Aab15c8dFb1967E4e8A7D42aeE
        );
    }

    // Function to get the price of a BEP-20 token in BNB
    function getTokenPriceInBNB(
        address tokenAddress
    ) public view returns (uint256) {
        // BNB token address
        address pairAddress = IUniswapV2Factory(PancakeFactory).getPair(
            tokenAddress,
            BNBToken
        ); // Get the pair address
        require(pairAddress != address(0), "Pair not found"); // Ensure the pair exists

        uint256 tokenReserves;
        uint256 bnbReserves;
        (tokenReserves, bnbReserves, ) = IUniswapV2Pair(pairAddress)
            .getReserves(); // Get the reserves
        return bnbReserves.mul(1e18).div(tokenReserves);
    }

    function getBNBPriceInUSD() public view returns (uint256) {
        (, int256 price, , , ) = priceFeed.latestRoundData();
        return uint256(price) * 10 ** 10;
    }

    function getBNBFromUSD(uint256 usdAmount) public view returns (uint256) {
        uint256 bnbPriceInUSD = getBNBPriceInUSD(); // Get the price of BNB in USD
        uint256 bnbAmount = usdAmount.mul(1e18).div(bnbPriceInUSD); // Calculate the amount of BNB you would get for the given USD amount
        return bnbAmount;
    }

    function getABXFromUSD(uint256 usdAmount) public view returns (uint256) {
        uint256 bnbPriceInUSD = getBNBPriceInUSD(); // Get the price of BNB in  USD // 238709260000000000000
        uint256 bnbAmount = usdAmount.mul(1e18).div(bnbPriceInUSD); // Calculate the amount of BNB you would get for the given USD amount
        uint256 tokenPriceInBNB = getTokenPriceInBNB(ABXToken); // Get the price of the token in BNB
        uint256 tokenAmount = bnbAmount.mul(1e18).div(tokenPriceInBNB);
        return tokenAmount;
    }

    function getUSDFromABX(uint256 tokenAmount) public view returns (uint256) {
        uint256 tokenPriceInBNB = getTokenPriceInBNB(ABXToken); // Get the price of the token in BNB
        uint256 bnbAmount = tokenAmount.mul(tokenPriceInBNB).div(1e18); // Calculate the amount of BNB you would get for the given token amount
        uint256 bnbPriceInUSD = getBNBPriceInUSD(); // Get the price of BNB in USD
        uint256 usdAmount = bnbAmount.mul(bnbPriceInUSD).div(1e18);
        return usdAmount;
    }

    function getABXPriceInUSD() public view returns (uint256) {
        uint256 bnbPriceInUSD = getBNBPriceInUSD(); // Get the price of BNB in USD
        uint256 tokenPriceInBNB = getTokenPriceInBNB(ABXToken);
        return bnbPriceInUSD.mul(tokenPriceInBNB).div(1e18);
    }

    function withdrawAll() external onlyOwner {
        uint256 contractBalance = address(this).balance;
        if (contractBalance > 0) {
            payable(owner()).transfer(contractBalance);
        }
    }

    function setAggregatorV3InterfaceAddress(
        address _aggregatorV3Interface_address
    ) public onlyOwner {
        require(_aggregatorV3Interface_address != address(0));
        priceFeed = AggregatorV3Interface(_aggregatorV3Interface_address);
    }

    function setFactoryAddress(
        address _pancakeFactory_address
    ) public onlyOwner {
        require(_pancakeFactory_address != address(0));
        PancakeFactory = _pancakeFactory_address;
    }

    function setBNBAddress(address _bnb_address) public onlyOwner {
        require(_bnb_address != address(0));
        BNBToken = _bnb_address;
    }

    function setABXAddress(address _ABX_address) public onlyOwner {
        require(_ABX_address != address(0));
        ABXToken = _ABX_address;
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "./AbxOracle.sol";

contract AbxStaking is ReentrancyGuard {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    AbxOracle public abxOracle;
    IERC20 public TOKENABX;
    address public owner;
    address public abxOracleAddress =
        0xD721Dc1B489145152c56De8020210485B2E9f80D;
    address public devWallet;
    address public mktWallet;
    address public poolWallet;
    uint256 public totalWithdrawn;
    uint256 public dailyInterestRate = 200;
    uint256 public maxBNBMultiplier = 10;
    uint256 public referralRate = 500;
    uint256 public feeRateInvest = 1000;
    uint256 public feeRateWitdeawn = 500;
    uint256 public maxStakeDuration = 100 days;
    uint256 public emergencyWithdrawFeeRate = 5000;
    uint256 public constant withdrawalCooldown = 1 days;
    uint256 public constant referralPercentage = 800;
    uint256 public currentDepositID = 0;

    struct Investor {
        uint256 tokenDeposit; // Cantidad de tokens depositados
        uint256 tokenDepositInUSD; // Cantidad de tokens depositados
        uint256 bnbDeposit; // Cantidad de BNB depositados
        uint256 totalEarned;
        uint256 referralEarnings;
        uint256 lastActionTimestamp;
        uint256 stakeStartTime;
        uint256 expectedEarned;
        uint256 totalWithdrawn;
        uint256 tokenusd;
    }

    struct Referral {
        address referrer;
        uint256 earnings;
    }
    struct Actions {
        uint256 lastWithdrawalTime;
        uint256 lastReinvestrawalTime;
    }
    struct Investment {
        uint256 id;
        uint256 bnbDeposit;
        uint256 tokenDeposit;
        uint256 stakeStartTime;
        uint256 totalEarned;
        uint256 totalWithdrawn;
        uint256 timeWithdrawn;
        uint256 timeReinvest;
    }

    mapping(address => Investor) public investors;
    mapping(address => Referral) public referrers;
    mapping(address => Actions) public actionsUsers;
    mapping(address => Investment[]) public investments;

    constructor() {
        abxOracle = AbxOracle(abxOracleAddress);
        TOKENABX = IERC20(abxOracle.ABXToken());
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can call this function");
        _;
    }

    function setDevWallet(address _newDevWallet) external onlyOwner {
        devWallet = _newDevWallet;
    }

    function depositTokens(uint256 _usdAmount) external nonReentrant {
        require(_usdAmount > 0, "Amount must be greater than 0");
        Investor storage investor = investors[msg.sender];
        investor.tokenusd = _usdAmount;
        uint256 tokenUSD = abxOracle.getABXFromUSD(_usdAmount);
        investor.tokenDepositInUSD = tokenUSD;
        investor.tokenDeposit = investor.tokenDeposit.add(tokenUSD);
        TOKENABX.transferFrom(msg.sender, address(this), tokenUSD);
    }

    function depositBNB(address referrer) external payable {
        require(msg.value > 0, "BNB amount must be greater than 0");
        Investor storage investor = investors[msg.sender];
        Referral storage referrerse = referrers[msg.sender];
        Investment memory newInvestment;
        require(investor.tokenDeposit > 0, "No token deposit found");
        referrerse.referrer = referrer;
        uint256 depositId = currentDepositID;
        referrerse.earnings = msg.value.mul(referralPercentage).div(10000);
        uint256 maxBNBAmountFromUSD = investor.tokenusd.mul(maxBNBMultiplier);

        uint256 maxBNBToUSD = abxOracle.getBNBFromUSD(maxBNBAmountFromUSD);
        require(
            msg.value <= maxBNBToUSD,
            "Exceeded maximum BNB deposit amount"
        );

        newInvestment.id = depositId;
        newInvestment.bnbDeposit = msg.value;
        newInvestment.tokenDeposit = investor.tokenDeposit;
        newInvestment.stakeStartTime = block.timestamp;

        investments[msg.sender].push(newInvestment);

        // Distribuir comisiones antes de transferir fondos
        uint256 feeRate = msg.value.mul(feeRateInvest).div(10000);
        payable(referrer).transfer(referrerse.earnings);
        distributeFees(feeRate);
        currentDepositID++;
    }

    function calculateEarnedAmount(
        address _investor,
        uint256 investmentIndex
    ) internal view returns (uint256) {
        Investment storage existingInvestment = investments[_investor][
            investmentIndex
        ];

        uint256 timePassed = block.timestamp.sub(
            existingInvestment.stakeStartTime
        );
        uint256 effectiveDuration = timePassed > maxStakeDuration
            ? maxStakeDuration
            : timePassed;

        uint256 totalEarnings = existingInvestment
            .bnbDeposit
            .mul(dailyInterestRate)
            .mul(effectiveDuration)
            .div(1 days)
            .div(10000);
        return totalEarnings;
    }

    function calculateRealTimeEarnings(
        address _investor,
        uint256 investmentIndex
    ) public view returns (uint256) {
        Investment storage existingInvestment = investments[_investor][
            investmentIndex
        ];

        uint256 currentTime = block.timestamp;
        uint256 stakeStartTime = existingInvestment.stakeStartTime;

        uint256 timePassed = currentTime > stakeStartTime
            ? currentTime - stakeStartTime
            : 0;

        uint256 totalInterest = (existingInvestment.bnbDeposit *
            dailyInterestRate *
            timePassed) /
            (1 days) /
            10000; // Divide by 100 for percentage

        uint256 totalAmount = existingInvestment.bnbDeposit + totalInterest;
        uint256 maxEarnings = existingInvestment.bnbDeposit * 2;

        if (totalAmount >= maxEarnings) {
            totalInterest = maxEarnings - existingInvestment.bnbDeposit;
        }

        return totalInterest;
    }

    function withdrawTokens() external nonReentrant {
        Investor storage investor = investors[msg.sender];
        require(investor.tokenDeposit > 0, "No investment found");

        require(
            TOKENABX.balanceOf(msg.sender) >= 1,
            "Must have at least 1 TOKENABX to withdraw"
        );
        investor.stakeStartTime = block.timestamp;

        TOKENABX.transfer(msg.sender, investor.tokenDeposit);
        investor.tokenDeposit = 0;
        investor.lastActionTimestamp = block.timestamp;
    }

    function withdrawInitialAndEarned(
        uint256 investmentIndex
    ) external nonReentrant {
        Investor storage investor = investors[msg.sender];
        Investment storage existingInvestment = investments[msg.sender][
            investmentIndex
        ];
        require(
            block.timestamp.sub(existingInvestment.stakeStartTime) >=
                maxStakeDuration,
            "Not eligible for withdrawal yet"
        );
        require(existingInvestment.bnbDeposit > 0, "No investment found");
        require(existingInvestment.tokenDeposit > 0, "No investment found");
        uint256 earnedAmount = calculateEarnedAmount(
            msg.sender,
            investmentIndex
        );
        require(earnedAmount > 0, "No earnings available");
        uint256 totalAmount = earnedAmount;
        require(
            address(this).balance >= totalAmount,
            "Insufficient BNB in contract for withdrawal"
        );
        // Distribuir comisiones antes de transferir fondos
        uint256 feeRate = totalAmount.mul(feeRateWitdeawn).div(10000);
        TOKENABX.transfer(msg.sender, existingInvestment.tokenDeposit);
        // Transferir los BNB depositados y ganancias al inversor
        distributeFees(feeRate);
        payable(msg.sender).transfer(totalAmount.sub(feeRate));
        totalWithdrawn = totalWithdrawn.add(totalAmount);
        investor.tokenDeposit = 0;
        investor.bnbDeposit = 0;
        investor.totalEarned = 0;
        investor.lastActionTimestamp = 0;
        investor.stakeStartTime = 0;
        investor.expectedEarned = 0;
        existingInvestment.totalWithdrawn = totalWithdrawn;
    }

    function withdrawEarned(uint256 investmentIndex) external nonReentrant {
        Investor storage investor = investors[msg.sender];
        Investment storage existingInvestment = investments[msg.sender][
            investmentIndex
        ];
        require(investor.tokenDeposit > 0, "No investment found");
        require(existingInvestment.tokenDeposit > 0, "No investment found");
        require(existingInvestment.bnbDeposit > 0, "No investment found");

        uint256 earnedAmount = calculateRealTimeEarnings(
            msg.sender,
            investmentIndex
        );
        uint256 totalAmount = earnedAmount;

        require(earnedAmount > 0, "No earnings available");

        require(
            address(this).balance >= totalAmount,
            "Insufficient BNB in contract for withdrawal"
        );
        uint256 timeSinceLastReinvest = block.timestamp.sub(
            existingInvestment.timeWithdrawn
        );
        require(
            timeSinceLastReinvest >= 86400,
            "Reinvestment cooldown period not passed"
        );

        uint256 feeRate = totalAmount.mul(feeRateWitdeawn).div(10000);

        totalWithdrawn = totalWithdrawn.add(totalAmount);

        existingInvestment.totalEarned = totalWithdrawn;
        existingInvestment.timeWithdrawn = block.timestamp;

        distributeFees(feeRate);
        payable(msg.sender).transfer(totalAmount.sub(feeRate));
    }

    function reinvest(uint256 investmentIndex) external nonReentrant {
        Actions storage action = actionsUsers[msg.sender];
        Investor storage investor = investors[msg.sender];
        Investment storage existingInvestment = investments[msg.sender][
            investmentIndex
        ];
        require(investor.tokenDeposit > 0, "No investment found");
        require(existingInvestment.tokenDeposit > 0, "No TOKEN deposit found");
        require(
            existingInvestment.bnbDeposit > 0,
            "No existing investment found"
        );
        uint256 timeSinceLastReinvest = block.timestamp.sub(
            existingInvestment.timeReinvest
        );
        require(
            timeSinceLastReinvest >= 86400,
            "Reinvestment cooldown period not passed"
        );

        uint256 earnedAmount = calculateRealTimeEarnings(
            msg.sender,
            investmentIndex
        );
        require(earnedAmount > 0, "No earnings available");

        distributeFees(earnedAmount);

        action.lastReinvestrawalTime = block.timestamp;

        existingInvestment.totalEarned = existingInvestment.totalEarned.add(
            earnedAmount
        );
        existingInvestment.bnbDeposit = existingInvestment.bnbDeposit.add(
            earnedAmount
        );
        existingInvestment.stakeStartTime = block.timestamp;
        existingInvestment.timeReinvest = block.timestamp;
    }

    function getContractBalance() external view returns (uint256) {
        return address(this).balance;
    }

    function getTokenBalance() external view returns (uint256) {
        return TOKENABX.balanceOf(address(this));
    }

    function getUserInvestments(
        address user
    ) external view returns (Investment[] memory) {
        return investments[user];
    }

    function getTimeRemaining(
        address _investor
    ) external view returns (uint256) {
        Investor storage investor = investors[_investor];
        uint256 timePassed = block.timestamp.sub(investor.stakeStartTime);

        if (timePassed >= maxStakeDuration) {
            return 0;
        } else {
            return maxStakeDuration.sub(timePassed);
        }
    }

    function getEstimatedEarnings(
        address _investor,
        uint256 investmentIndex
    ) external view returns (uint256) {
        uint256 earnedAmount = calculateEarnedAmount(
            _investor,
            investmentIndex
        );
        return earnedAmount;
    }

    function getEstimatedEarningsNow(
        uint256 investmentIndex
    ) external view returns (uint256) {
        uint256 earnedAmount = calculateEarnedAmount(
            msg.sender,
            investmentIndex
        );
        return earnedAmount;
    }

    function distributeFees(uint256 _investComission) internal {
        uint256 totalFee = _investComission; // 10%
        uint256 devFee = totalFee.mul(2500).div(10000);
        uint256 mktFee = totalFee.mul(2500).div(10000);
        uint256 poolFee = totalFee.mul(5000).div(10000);

        payable(devWallet).transfer(devFee);
        payable(mktWallet).transfer(mktFee);
        payable(poolWallet).transfer(poolFee);
    }

    function setWallets(
        address _devWallet,
        address _mktWallet,
        address _poolWallet
    ) external onlyOwner {
        require(_devWallet != address(0), "Invalid dev wallet address");
        require(_mktWallet != address(0), "Invalid marketing wallet address");
        require(_poolWallet != address(0), "Invalid pool wallet address");
        devWallet = _devWallet;
        mktWallet = _mktWallet;
        poolWallet = _poolWallet;
    }

    function setAbxOracleAddress(address _abxOracleAddress) public onlyOwner {
        require(_abxOracleAddress != address(0));
        abxOracleAddress = _abxOracleAddress;
    }
}
