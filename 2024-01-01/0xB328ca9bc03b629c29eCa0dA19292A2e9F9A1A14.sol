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
pragma solidity >=0.6.2;

interface IUniswapV2Router01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);
    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH);
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}
pragma solidity >=0.6.2;

import './IUniswapV2Router01.sol';

interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

// Uncomment this line to use console.log
// import "hardhat/console.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";

interface MixInterface {
    function transferToTemVault(uint usdtAmount) external;
}

interface IUnionFactory {
    function parameters()
        external
        view
        returns (
            string memory name,
            string memory symbol,
            string memory url,
            address factory,
            address unionAccount,
            IUniswapV2Router02 pancakeRouter,
            IERC20 usdt,
            MixInterface iMixInterface
        );

    function initializeParameters()
        external
        view
        returns (
            address foundationAccount,
            address marketAccount,
            address communityAccount,
            address defaultBoundAccount,
            IERC20 APi,
            IERC20 unionCoin,
            address withdrawFeeReceiver
        );
}
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

library FinancialMath {
    struct Financial {
        uint no;
        address owner;
        uint status;
        uint financialType;
        uint financialAmount;
        uint amountInterest;
        uint withdrawAmount;
        uint startTime;
        uint startDays;
        uint lastWithdrawTime;
        uint cycle;
    }

    struct CalPendingAmountParmeter1 {
        uint cycleTime;
        uint maxCycle;
        uint financialInterestRateBase;
    }

    struct CalPendingAmountParmeter2 {
        uint lastWithdrawTime;
        uint exitAmount;
        uint withdrawAmount;
        uint invitePendingAmount;
    }

    function getCurrentFinancialPendingReward(
        Financial[] memory financials,
        mapping(uint => uint) storage financialInterestRate,
        CalPendingAmountParmeter1 memory parameter1,
        CalPendingAmountParmeter2 memory parameter2
    ) public view returns (uint, uint, uint) {
        if (parameter2.lastWithdrawTime + 86400 > block.timestamp) {
            return (
                parameter2.invitePendingAmount,
                parameter2.invitePendingAmount,
                0
            );
        }
        if (
            parameter2.withdrawAmount + parameter2.invitePendingAmount >=
            parameter2.exitAmount
        ) {
            return (
                parameter2.invitePendingAmount,
                parameter2.invitePendingAmount,
                0
            );
        }
        uint pendingReward;
        for (uint i = 0; i < financials.length; i++) {
            Financial memory financial = financials[i];
            if (financial.status != 0) {
                continue;
            }
            uint currentDays = (block.timestamp - financial.lastWithdrawTime) /
                86400;
            if (currentDays == 0) {
                continue;
            }

            bool endCalculateReward;
            uint singleFinancialPendingReward;
            for (uint j = 1; j <= currentDays; j++) {
                if (j == 1) {
                    singleFinancialPendingReward = 0;
                }
                uint currentCycle = (financial.startDays + j) /
                    parameter1.cycleTime;
                if ((financial.startDays + j) % parameter1.cycleTime != 0) {
                    currentCycle += 1;
                }
                if (currentCycle >= parameter1.maxCycle) {
                    currentCycle = parameter1.maxCycle;
                }
                uint financialPendingReward = (financial.financialAmount *
                    financialInterestRate[currentCycle]) /
                    parameter1.financialInterestRateBase;
                if (
                    financialPendingReward +
                        financial.withdrawAmount +
                        singleFinancialPendingReward >=
                    financial.amountInterest
                ) {
                    financialPendingReward =
                        financial.amountInterest -
                        financial.withdrawAmount -
                        singleFinancialPendingReward;

                    if (
                        parameter2.withdrawAmount +
                            parameter2.invitePendingAmount +
                            financialPendingReward +
                            pendingReward >=
                        parameter2.exitAmount
                    ) {
                        financialPendingReward =
                            parameter2.exitAmount -
                            parameter2.withdrawAmount -
                            parameter2.invitePendingAmount -
                            pendingReward;
                        pendingReward += financialPendingReward;
                        endCalculateReward = true;
                        break;
                    }
                    pendingReward += financialPendingReward;
                    break;
                }
                if (
                    parameter2.withdrawAmount +
                        parameter2.invitePendingAmount +
                        financialPendingReward +
                        singleFinancialPendingReward >=
                    parameter2.exitAmount
                ) {
                    financialPendingReward =
                        parameter2.exitAmount -
                        parameter2.withdrawAmount -
                        parameter2.invitePendingAmount -
                        singleFinancialPendingReward;
                    pendingReward += financialPendingReward;
                    endCalculateReward = true;
                    break;
                }
                pendingReward += financialPendingReward;
                singleFinancialPendingReward += financialPendingReward;
                if (
                    parameter2.withdrawAmount +
                        parameter2.invitePendingAmount +
                        pendingReward >=
                    parameter2.exitAmount
                ) {
                    pendingReward =
                        parameter2.exitAmount -
                        parameter2.withdrawAmount -
                        parameter2.invitePendingAmount;
                    endCalculateReward = true;
                    break;
                }
            }
            if (endCalculateReward) {
                break;
            }
        }
        return (
            parameter2.invitePendingAmount + pendingReward,
            parameter2.invitePendingAmount,
            pendingReward
        );
    }

    function withdrawCurrentFinancialReward(
        Financial[] storage financials,
        mapping(uint => uint) storage financialInterestRate,
        CalPendingAmountParmeter1 memory parameter1,
        CalPendingAmountParmeter2 memory parameter2
    ) public returns (uint, uint, uint) {
        if (parameter2.lastWithdrawTime + 86400 > block.timestamp) {
            return (
                parameter2.invitePendingAmount,
                parameter2.invitePendingAmount,
                0
            );
        }
        if (
            parameter2.withdrawAmount + parameter2.invitePendingAmount >=
            parameter2.exitAmount
        ) {
            endCurrentFinancial(financials);
            return (
                parameter2.invitePendingAmount,
                parameter2.invitePendingAmount,
                0
            );
        }
        uint pendingReward;
        for (uint i = 0; i < financials.length; i++) {
            Financial memory financial = financials[i];
            if (financial.status != 0) {
                continue;
            }
            uint currentDays = (block.timestamp - financial.lastWithdrawTime) /
                86400;
            if (currentDays == 0) {
                continue;
            }
            bool endCalculateReward;
            uint singleFinancialPendingReward;
            for (uint j = 1; j <= currentDays; j++) {
                if (j == 1) {
                    singleFinancialPendingReward = 0;
                }
                uint currentCycle = (financial.startDays + j) /
                    parameter1.cycleTime;
                if ((financial.startDays + j) % parameter1.cycleTime != 0) {
                    currentCycle += 1;
                }
                if (currentCycle >= parameter1.maxCycle) {
                    currentCycle = parameter1.maxCycle;
                }
                uint financialPendingReward = (financial.financialAmount *
                    financialInterestRate[currentCycle]) /
                    parameter1.financialInterestRateBase;

                if (
                    financialPendingReward +
                        financial.withdrawAmount +
                        singleFinancialPendingReward >=
                    financial.amountInterest
                ) {
                    financialPendingReward =
                        financial.amountInterest -
                        financial.withdrawAmount -
                        singleFinancialPendingReward;

                    if (
                        parameter2.withdrawAmount +
                            parameter2.invitePendingAmount +
                            financialPendingReward +
                            pendingReward >=
                        parameter2.exitAmount
                    ) {
                        financialPendingReward =
                            parameter2.exitAmount -
                            parameter2.withdrawAmount -
                            parameter2.invitePendingAmount -
                            pendingReward;

                        pendingReward += financialPendingReward;

                        singleFinancialPendingReward += financialPendingReward;

                        updateCurrentFinancial(
                            financials[i],
                            1,
                            singleFinancialPendingReward,
                            j,
                            currentCycle
                        );

                        endCurrentFinancial(financials);
                        endCalculateReward = true;
                        break;
                    }

                    singleFinancialPendingReward += financialPendingReward;

                    updateCurrentFinancial(
                        financials[i],
                        1,
                        singleFinancialPendingReward,
                        j,
                        currentCycle
                    );

                    pendingReward += financialPendingReward;
                    break;
                }
                if (
                    parameter2.withdrawAmount +
                        parameter2.invitePendingAmount +
                        financialPendingReward +
                        singleFinancialPendingReward >=
                    parameter2.exitAmount
                ) {
                    financialPendingReward =
                        parameter2.exitAmount -
                        parameter2.withdrawAmount -
                        parameter2.invitePendingAmount -
                        singleFinancialPendingReward;

                    pendingReward += financialPendingReward;

                    singleFinancialPendingReward += financialPendingReward;

                    updateCurrentFinancial(
                        financials[i],
                        1,
                        singleFinancialPendingReward,
                        j,
                        currentCycle
                    );

                    endCurrentFinancial(financials);
                    endCalculateReward = true;
                    break;
                }
                pendingReward += financialPendingReward;
                singleFinancialPendingReward += financialPendingReward;

                if (
                    parameter2.withdrawAmount +
                        parameter2.invitePendingAmount +
                        pendingReward >=
                    parameter2.exitAmount
                ) {
                    pendingReward =
                        parameter2.exitAmount -
                        parameter2.withdrawAmount -
                        parameter2.invitePendingAmount;

                    updateCurrentFinancial(
                        financials[i],
                        1,
                        singleFinancialPendingReward,
                        j,
                        currentCycle
                    );

                    endCurrentFinancial(financials);
                    endCalculateReward = true;
                    break;
                }

                if (j == currentDays) {
                    updateCurrentFinancial(
                        financials[i],
                        0,
                        singleFinancialPendingReward,
                        j,
                        currentCycle
                    );
                }
            }
            if (endCalculateReward) {
                break;
            }
        }
        return (
            parameter2.invitePendingAmount + pendingReward,
            parameter2.invitePendingAmount,
            pendingReward
        );
    }

    function endCurrentFinancial(Financial[] storage financials) public {
        for (uint i = 0; i < financials.length; i++) {
            if (financials[i].status == 0) {
                financials[i].status = 1;
            }
        }
    }

    function updateCurrentFinancial(
        Financial storage financial,
        uint status,
        uint singleFinancialPendingReward,
        uint j,
        uint currentCycle
    ) public {
        financial.status = status;
        financial.withdrawAmount =
            financial.withdrawAmount +
            singleFinancialPendingReward;
        financial.startDays = financial.startDays + j;
        financial.lastWithdrawTime = block.timestamp;
        financial.cycle = currentCycle;
    }

    function getContractFinancialPendingReward(
        Financial[] memory financials,
        uint financialInterestRate,
        uint financialInterestRateBase,
        CalPendingAmountParmeter2 memory parameter2
    ) public view returns (uint, uint, uint) {
        if (parameter2.lastWithdrawTime + 86400 > block.timestamp) {
            return (
                parameter2.invitePendingAmount,
                parameter2.invitePendingAmount,
                0
            );
        }
        if (
            parameter2.withdrawAmount + parameter2.invitePendingAmount >=
            parameter2.exitAmount
        ) {
            return (
                parameter2.invitePendingAmount,
                parameter2.invitePendingAmount,
                0
            );
        }
        uint pendingReward;
        for (uint i = 0; i < financials.length; i++) {
            Financial memory financial = financials[i];
            if (financial.status != 0) {
                continue;
            }
            uint currentDays = (block.timestamp - financial.lastWithdrawTime) /
                86400;
            if (currentDays == 0) {
                continue;
            }
            uint financialPendingReward = (financial.financialAmount *
                currentDays *
                financialInterestRate) / financialInterestRateBase;
            if (
                financialPendingReward + financial.withdrawAmount >=
                financial.amountInterest
            ) {
                financialPendingReward =
                    financial.amountInterest -
                    financial.withdrawAmount;

                if (
                    parameter2.withdrawAmount +
                        parameter2.invitePendingAmount +
                        financialPendingReward +
                        pendingReward >=
                    parameter2.exitAmount
                ) {
                    financialPendingReward =
                        parameter2.exitAmount -
                        parameter2.withdrawAmount -
                        parameter2.invitePendingAmount -
                        pendingReward;
                    pendingReward += financialPendingReward;
                    break;
                }

                pendingReward += financialPendingReward;
                continue;
            }
            if (
                parameter2.withdrawAmount +
                    parameter2.invitePendingAmount +
                    financialPendingReward +
                    pendingReward >=
                parameter2.exitAmount
            ) {
                financialPendingReward =
                    parameter2.exitAmount -
                    parameter2.withdrawAmount -
                    parameter2.invitePendingAmount -
                    pendingReward;
                pendingReward += financialPendingReward;
                break;
            }
            pendingReward += financialPendingReward;
            if (
                parameter2.withdrawAmount +
                    parameter2.invitePendingAmount +
                    pendingReward >=
                parameter2.exitAmount
            ) {
                pendingReward =
                    parameter2.exitAmount -
                    parameter2.withdrawAmount -
                    parameter2.invitePendingAmount;

                break;
            }
        }
        return (
            parameter2.invitePendingAmount + pendingReward,
            parameter2.invitePendingAmount,
            pendingReward
        );
    }

    function withdrawContractFinancialPendingReward(
        Financial[] storage financials,
        uint financialInterestRate,
        uint financialInterestRateBase,
        CalPendingAmountParmeter2 memory parameter2
    ) public returns (uint, uint, uint) {
        if (parameter2.lastWithdrawTime + 86400 > block.timestamp) {
            return (
                parameter2.invitePendingAmount,
                parameter2.invitePendingAmount,
                0
            );
        }
        if (
            parameter2.withdrawAmount + parameter2.invitePendingAmount >=
            parameter2.exitAmount
        ) {
            return (
                parameter2.invitePendingAmount,
                parameter2.invitePendingAmount,
                0
            );
        }
        uint pendingReward;
        for (uint i = 0; i < financials.length; i++) {
            Financial memory financial = financials[i];
            if (financial.status != 0) {
                continue;
            }
            uint currentDays = (block.timestamp - financial.lastWithdrawTime) /
                86400;
            if (currentDays == 0) {
                continue;
            }
            uint financialPendingReward = (financial.financialAmount *
                currentDays *
                financialInterestRate) / financialInterestRateBase;
            if (
                financialPendingReward + financial.withdrawAmount >=
                financial.amountInterest
            ) {
                financialPendingReward =
                    financial.amountInterest -
                    financial.withdrawAmount;

                if (
                    parameter2.withdrawAmount +
                        parameter2.invitePendingAmount +
                        financialPendingReward +
                        pendingReward >=
                    parameter2.exitAmount
                ) {
                    financialPendingReward =
                        parameter2.exitAmount -
                        parameter2.withdrawAmount -
                        parameter2.invitePendingAmount -
                        pendingReward;

                    pendingReward += financialPendingReward;

                    currentDays =
                        (financialPendingReward * financialInterestRateBase) /
                        financialInterestRate /
                        financial.financialAmount;

                    updateCurrentFinancial(
                        financials[i],
                        1,
                        financialPendingReward,
                        currentDays,
                        0
                    );
                    endCurrentFinancial(financials);
                    break;
                }

                pendingReward += financialPendingReward;

                currentDays =
                    (financialPendingReward * financialInterestRateBase) /
                    financialInterestRate /
                    financial.financialAmount;

                updateCurrentFinancial(
                    financials[i],
                    1,
                    financialPendingReward,
                    currentDays,
                    0
                );

                continue;
            }
            if (
                parameter2.withdrawAmount +
                    parameter2.invitePendingAmount +
                    financialPendingReward +
                    pendingReward >=
                parameter2.exitAmount
            ) {
                financialPendingReward =
                    parameter2.exitAmount -
                    parameter2.withdrawAmount -
                    parameter2.invitePendingAmount -
                    pendingReward;

                pendingReward += financialPendingReward;

                currentDays =
                    (financialPendingReward * financialInterestRateBase) /
                    financialInterestRate /
                    financial.financialAmount;

                updateCurrentFinancial(
                    financials[i],
                    1,
                    financialPendingReward,
                    currentDays,
                    0
                );
                endCurrentFinancial(financials);
                break;
            }
            pendingReward += financialPendingReward;
            if (
                parameter2.withdrawAmount +
                    parameter2.invitePendingAmount +
                    pendingReward >=
                parameter2.exitAmount
            ) {
                pendingReward =
                    parameter2.exitAmount -
                    parameter2.withdrawAmount -
                    parameter2.invitePendingAmount;

                updateCurrentFinancial(
                    financials[i],
                    1,
                    financialPendingReward,
                    currentDays,
                    0
                );
                endCurrentFinancial(financials);

                break;
            }
            updateCurrentFinancial(
                financials[i],
                0,
                financialPendingReward,
                currentDays,
                0
            );
        }
        return (
            parameter2.invitePendingAmount + pendingReward,
            parameter2.invitePendingAmount,
            pendingReward
        );
    }
}
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "./interfaces/IUnionFactory.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";
import "./libraries/FinancialMath.sol";

struct Referrer {
    address owner;
    address[] oneNextGenerations;
    address[] twoNextGenerations;
    address[] threeNextGenerations;
}

struct FinancialInterest {
    // 1-financial management;2-contract financial management
    uint financialType;
    uint investAmount;
    uint exitAmount;
    uint withdrawAmount;
    uint lastWithdrawTime;
}

struct InviteInterest {
    uint withdrawAmount;
    uint pendingAmount;
}

struct FinancialInfo {
    uint financialType;
    uint investAmount;
    uint exitAmount;
    uint withdrawAmount;
    uint pendingAmount;
    uint lastWithdrawTime;
    uint nextWithdrawTime;
    uint financialPendingAmount;
    uint invitePendingAmount;
}

contract Union is Ownable, ReentrancyGuard {
    using SafeERC20 for IERC20;
    using FinancialMath for FinancialMath.Financial;

    string public name;
    string public symbol;
    string public url;
    address public unionFactory;
    address public unionAccount;

    uint public buyAmountBase = 100 * 1e18;

    bool public isInitialize;

    IERC20 public usdt;
    IUniswapV2Router02 public pancakeRouter;

    uint public financialNo = 1;

    address public defaultBoundAccount;
    mapping(address => bool) public bound;
    mapping(address => address) public referrer;
    mapping(address => Referrer) public referrers;
    mapping(address => mapping(uint => InviteInterest))
        public inviteInterestInfos;

    mapping(address => mapping(uint => FinancialMath.Financial[]))
        public financialInfos;
    mapping(address => mapping(uint => FinancialInterest))
        public financialInterestInfos;

    bool public buyBackSwitch = false;

    uint public unionRatio = 95;
    uint public buyBackAPiCoinRatio = 2;
    uint public foundationRatio = 1;
    uint public marketRatio = 1;
    uint public communityRatio = 1;
    uint public ratioBase = 100;

    address public foundationAccount;
    address public marketAccount;
    address public communityAccount;

    IERC20 public APi;
    IERC20 public unionCoin;

    uint public financialManagementCycle = 15;

    mapping(uint => uint) public financialInterestRate;
    uint public financialInterestRateBase = 1000;

    uint public withdrawFee = 5;
    address public withdrawFeeReceiver;

    uint public lastGenerationQuali = 1000 * 1e18;
    uint public oneLastGenerationRation = 30;
    uint public twoLastGenerationRation = 30;
    uint public threeLastGenerationRation = 30;

    mapping(uint => uint) public nextGenerationRatio;

    uint public generationRatioBase = 1000;

    uint public exitCycle = 2;
    uint public exitFee = 50;
    uint public exitFeeBase = 1000;

    uint public exitInterestTimes = 3;

    uint public contractfinancialInterestRate = 10;

    mapping(address => bool) public blockUsers;

    bool public funSwitch;

    MixInterface public iMixInterface;

    modifier onlyFactory() {
        require(msg.sender == unionFactory, "n f");
        _;
    }

    constructor() {
        (
            name,
            symbol,
            url,
            unionFactory,
            unionAccount,
            pancakeRouter,
            usdt,
            iMixInterface
        ) = IUnionFactory(msg.sender).parameters();
        _transferOwnership(unionAccount);

        financialInterestRate[1] = 6;
        financialInterestRate[2] = 7;
        financialInterestRate[3] = 8;
        financialInterestRate[4] = 9;
        financialInterestRate[5] = 10;
        financialInterestRate[6] = 11;
        financialInterestRate[7] = 12;
        financialInterestRate[8] = 13;
        financialInterestRate[9] = 14;
        financialInterestRate[10] = 15;

        nextGenerationRatio[1] = 200;
        nextGenerationRatio[2] = 100;
        nextGenerationRatio[3] = 50;
        nextGenerationRatio[4] = 30;
        nextGenerationRatio[5] = 30;
        nextGenerationRatio[6] = 30;
    }

    function initialize() external {
        require(tx.origin == unionFactory, "n f");
        require(!isInitialize, "a i");
        (
            foundationAccount,
            marketAccount,
            communityAccount,
            defaultBoundAccount,
            APi,
            unionCoin,
            withdrawFeeReceiver
        ) = IUnionFactory(msg.sender).initializeParameters();
        isInitialize = true;
    }

    function balance(address token) public view returns (uint256) {
        if (token == address(0)) {
            return address(this).balance;
        }
        return IERC20(token).balanceOf(address(this));
    }

    function withdrawErc20(
        address token,
        address to,
        uint256 amount
    ) public onlyOwner {
        uint256 tokenBalance = IERC20(token).balanceOf(address(this));
        require(tokenBalance >= amount, "e");
        IERC20(token).safeTransfer(to, amount);
    }

    function setFunSwithc(bool _funSwitch) public onlyOwner {
        funSwitch = _funSwitch;
    }

    function setExitTimes(uint _exitTimes) public onlyOwner {
        exitInterestTimes = _exitTimes;
    }

    function setFinancialInterestRate(
        uint _cycle,
        uint _rate
    ) public onlyOwner {
        financialInterestRate[_cycle] = _rate;
    }

    function setContractRate(uint _rate) public onlyOwner {
        contractfinancialInterestRate = _rate;
    }

    function setFinancialManagementCycle(
        uint _financialManagementCycle
    ) public onlyOwner {
        financialManagementCycle = _financialManagementCycle;
    }

    function setUnionCoin(IERC20 _uninoCoin) public onlyOwner {
        unionCoin = _uninoCoin;
    }

    function setLastGenRatio(
        uint _oneGenRatio,
        uint _twoGenRatio,
        uint _threeGenRatio
    ) public onlyOwner {
        oneLastGenerationRation = _oneGenRatio;
        twoLastGenerationRation = _twoGenRatio;
        threeLastGenerationRation = _threeGenRatio;
    }

    function setNextGenRatio(uint _nextGen, uint _ratio) public onlyOwner {
        nextGenerationRatio[_nextGen] = _ratio;
    }

    function setBlockUser(address account, bool state) public onlyOwner {
        blockUsers[account] = state;
    }

    function setFactoryAdds(
        address _add1,
        address _add2,
        address _add3
    ) public onlyFactory {
        foundationAccount = _add1;
        marketAccount = _add2;
        communityAccount = _add3;
    }

    function transferFactory(address _newFactory) public onlyFactory {
        unionFactory = _newFactory;
    }

    function setMix(MixInterface _mix) public onlyFactory {
        iMixInterface = _mix;
    }

    function setBuyBackSwitch(bool _buyBackSwitch) public onlyFactory {
        buyBackSwitch = _buyBackSwitch;
    }

    function getReferers(
        address account,
        uint financialType
    ) public view returns (address[] memory, uint[] memory) {
        address[] memory addresses = referrers[account].oneNextGenerations;
        uint[] memory investAmount = new uint[](addresses.length);
        for (uint i = 0; i < addresses.length; i++) {
            investAmount[i] = financialInterestInfos[addresses[i]][
                financialType
            ].investAmount;
        }
        return (addresses, investAmount);
    }

    function performance(
        address account,
        uint financialType
    ) public view returns (uint initailPerformance) {
        address[] memory addresses = referrers[account].oneNextGenerations;
        if (addresses.length > 0) {
            for (uint i = 0; i < addresses.length; i++) {
                initailPerformance +=
                    financialInterestInfos[addresses[i]][financialType]
                        .investAmount +
                    performance(addresses[i], financialType);
            }
        }
        return initailPerformance;
    }

    function getFinancialInfos(
        uint financialType
    ) public view returns (FinancialMath.Financial[] memory) {
        return financialInfos[msg.sender][financialType];
    }

    function boundReferrer(address _referrer) external {
        require(!bound[msg.sender], "a b");
        if (_referrer == address(0)) {
            _referrer = defaultBoundAccount;
        } else {
            require(bound[_referrer], "r b");
        }
        bound[msg.sender] = true;
        referrer[msg.sender] = _referrer;
        address[] memory addresses;
        referrers[msg.sender] = Referrer({
            owner: msg.sender,
            oneNextGenerations: addresses,
            twoNextGenerations: addresses,
            threeNextGenerations: addresses
        });
        _boundLastGeneration(msg.sender, _referrer);
    }

    function buyFinancialManagement(
        uint buyAmount,
        uint financialType
    ) public nonReentrant {
        require(bound[msg.sender], "a n b");
        require(
            buyAmount % buyAmountBase == 0 && buyAmount / buyAmountBase >= 1,
            "100U"
        );
        _transfer1(buyAmount);
        FinancialMath.Financial[] storage financials = financialInfos[
            msg.sender
        ][financialType];
        financials.push(
            FinancialMath.Financial({
                no: financialNo,
                owner: msg.sender,
                status: 0,
                financialType: financialType,
                financialAmount: buyAmount,
                amountInterest: buyAmount * exitInterestTimes,
                withdrawAmount: 0,
                startTime: block.timestamp,
                startDays: 0,
                lastWithdrawTime: block.timestamp,
                cycle: 1
            })
        );
        financialNo++;
        financialInfos[msg.sender][financialType] = financials;
        FinancialInterest storage financialInterest = financialInterestInfos[
            msg.sender
        ][financialType];
        financialInterest.financialType = financialType;
        financialInterest.investAmount =
            financialInterest.investAmount +
            buyAmount;
        financialInterest.exitAmount =
            financialInterest.exitAmount +
            buyAmount *
            exitInterestTimes;
        financialInterest.lastWithdrawTime = block.timestamp;
        financialInterestInfos[msg.sender][financialType] = financialInterest;
    }

    function getFinancialInfo(
        uint financialType
    ) public view returns (FinancialInfo memory financialInfo) {
        FinancialInterest memory financialInterest = financialInterestInfos[
            msg.sender
        ][financialType];
        InviteInterest memory inviteInterest = inviteInterestInfos[msg.sender][
            financialType
        ];
        uint allPending;
        uint invitePending;
        uint financialPending;
        if (financialType == 1) {
            (allPending, invitePending, financialPending) = FinancialMath
                .getCurrentFinancialPendingReward(
                    financialInfos[msg.sender][financialType],
                    financialInterestRate,
                    FinancialMath.CalPendingAmountParmeter1({
                        cycleTime: financialManagementCycle,
                        maxCycle: 10,
                        financialInterestRateBase: financialInterestRateBase
                    }),
                    FinancialMath.CalPendingAmountParmeter2({
                        lastWithdrawTime: financialInterest.lastWithdrawTime,
                        exitAmount: financialInterest.exitAmount,
                        withdrawAmount: financialInterest.withdrawAmount,
                        invitePendingAmount: inviteInterest.pendingAmount
                    })
                );
        } else {
            (allPending, invitePending, financialPending) = FinancialMath
                .getContractFinancialPendingReward(
                    financialInfos[msg.sender][financialType],
                    contractfinancialInterestRate,
                    financialInterestRateBase,
                    FinancialMath.CalPendingAmountParmeter2({
                        lastWithdrawTime: financialInterest.lastWithdrawTime,
                        exitAmount: financialInterest.exitAmount,
                        withdrawAmount: financialInterest.withdrawAmount,
                        invitePendingAmount: inviteInterest.pendingAmount
                    })
                );
        }

        financialInfo.financialType = financialType;
        financialInfo.investAmount = financialInterest.investAmount;
        financialInfo.exitAmount = financialInterest.exitAmount;
        financialInfo.withdrawAmount = financialInterest.withdrawAmount;
        financialInfo.pendingAmount = allPending;
        financialInfo.lastWithdrawTime = financialInterest.lastWithdrawTime;
        financialInfo.nextWithdrawTime = block.timestamp -
            financialInterest.lastWithdrawTime >=
            86400
            ? 0
            : 86400 - (block.timestamp - financialInterest.lastWithdrawTime);
        financialInfo.financialPendingAmount = financialPending;
        financialInfo.invitePendingAmount = invitePending;
    }

    function withdrawFinancialInterest(uint financialType) public nonReentrant {
        require(!funSwitch, "ERROR: NOT SERVICES");
        require(!blockUsers[msg.sender], "b u");
        FinancialInterest memory financialInterest = financialInterestInfos[
            msg.sender
        ][financialType];
        InviteInterest memory inviteInterest = inviteInterestInfos[msg.sender][
            financialType
        ];
        uint pendingReward;
        if (financialType == 1) {
            (, , pendingReward) = FinancialMath.withdrawCurrentFinancialReward(
                financialInfos[msg.sender][financialType],
                financialInterestRate,
                FinancialMath.CalPendingAmountParmeter1({
                    cycleTime: financialManagementCycle,
                    maxCycle: 10,
                    financialInterestRateBase: financialInterestRateBase
                }),
                FinancialMath.CalPendingAmountParmeter2({
                    lastWithdrawTime: financialInterest.lastWithdrawTime,
                    exitAmount: financialInterest.exitAmount,
                    withdrawAmount: financialInterest.withdrawAmount,
                    invitePendingAmount: inviteInterest.pendingAmount
                })
            );
        } else {
            (, , pendingReward) = FinancialMath
                .withdrawContractFinancialPendingReward(
                    financialInfos[msg.sender][financialType],
                    contractfinancialInterestRate,
                    financialInterestRateBase,
                    FinancialMath.CalPendingAmountParmeter2({
                        lastWithdrawTime: financialInterest.lastWithdrawTime,
                        exitAmount: financialInterest.exitAmount,
                        withdrawAmount: financialInterest.withdrawAmount,
                        invitePendingAmount: inviteInterest.pendingAmount
                    })
                );
        }
        require(pendingReward > 0, "lt 0");
        financialInterestInfos[msg.sender][financialType]
            .withdrawAmount += pendingReward;
        financialInterestInfos[msg.sender][financialType]
            .lastWithdrawTime = block.timestamp;

        _addInviteReward(pendingReward, financialType);

        uint unionCoinAmount = pendingReward;
        if (address(usdt) != address(unionCoin)) {
            unionCoinAmount = getUnionCoinAmount(pendingReward);
        }

        unionCoin.transfer(
            withdrawFeeReceiver,
            (unionCoinAmount * withdrawFee) / ratioBase
        );
        unionCoin.transfer(
            msg.sender,
            (unionCoinAmount * (ratioBase - withdrawFee)) / ratioBase
        );
    }

    function withdrawInviteReward(uint financialType) public nonReentrant {
        require(!funSwitch, "ERROR: NOT SERVICES");
        require(!blockUsers[msg.sender], "b u");
        InviteInterest memory inviteInterest = inviteInterestInfos[msg.sender][
            financialType
        ];
        require(inviteInterest.pendingAmount > 0, "lt 0");
        financialInterestInfos[msg.sender][financialType]
            .withdrawAmount += inviteInterest.pendingAmount;
        inviteInterestInfos[msg.sender][financialType].pendingAmount = 0;
        inviteInterestInfos[msg.sender][financialType]
            .withdrawAmount += inviteInterest.pendingAmount;

        uint unionCoinAmount = inviteInterest.pendingAmount;
        if (address(usdt) != address(unionCoin)) {
            unionCoinAmount = getUnionCoinAmount(inviteInterest.pendingAmount);
        }

        unionCoin.transfer(
            withdrawFeeReceiver,
            (unionCoinAmount * withdrawFee) / ratioBase
        );
        unionCoin.transfer(
            msg.sender,
            (unionCoinAmount * (ratioBase - withdrawFee)) / ratioBase
        );
    }

    function cancleFinancial(uint no) public nonReentrant {
        for (uint i = 0; i < financialInfos[msg.sender][1].length; i++) {
            FinancialMath.Financial memory financial = financialInfos[
                msg.sender
            ][1][i];
            if (financial.no == no) {
                require(financial.status == 0, "s e");
                FinancialInterest
                    memory financialInterest = financialInterestInfos[
                        msg.sender
                    ][1];
                require(
                    (financialInterest.exitAmount -
                        financialInterest.withdrawAmount) >=
                        (financial.amountInterest - financial.withdrawAmount),
                    "c n c"
                );
                uint returnAmount;
                if (financial.cycle <= exitCycle) {
                    returnAmount = financial.financialAmount >=
                        financial.withdrawAmount
                        ? ((financial.financialAmount -
                            financial.withdrawAmount) * (100 - withdrawFee)) /
                            ratioBase
                        : 0;
                } else {
                    returnAmount = financial.financialAmount;
                }
                require(returnAmount > 0, "le 0");
                usdt.safeTransfer(msg.sender, returnAmount);
                financialInfos[msg.sender][1][i].status = 2;
                financialInterestInfos[msg.sender][1].investAmount -= financial
                    .financialAmount;
                financialInterestInfos[msg.sender][1].exitAmount -= (financial
                    .amountInterest - financial.withdrawAmount);
            }
        }
    }

    function _boundLastGeneration(
        address _account,
        address _referrer
    ) internal {
        for (uint i = 1; i < 4; i++) {
            Referrer storage referer = referrers[_referrer];
            if (i == 1) {
                address[] storage oneNextGeneration = referer
                    .oneNextGenerations;
                oneNextGeneration.push(_account);
                referrers[_referrer].oneNextGenerations = oneNextGeneration;
            }
            if (i == 2) {
                address[] storage twoNextGeneration = referer
                    .twoNextGenerations;
                twoNextGeneration.push(_account);
                referrers[_referrer].twoNextGenerations = twoNextGeneration;
            }
            if (i == 3) {
                address[] storage threeNextGeneration = referer
                    .threeNextGenerations;
                threeNextGeneration.push(_account);
                referrers[_referrer].threeNextGenerations = threeNextGeneration;
            }
            _referrer = referrer[_referrer];
            if (_referrer == address(0)) {
                break;
            }
        }
    }

    function _transfer1(uint buyAmount) internal {
        usdt.safeTransferFrom(
            msg.sender,
            address(iMixInterface),
            (buyAmount * unionRatio) / ratioBase
        );
        iMixInterface.transferToTemVault((buyAmount * unionRatio) / ratioBase);
        usdt.safeTransferFrom(
            msg.sender,
            address(this),
            (buyAmount * buyBackAPiCoinRatio) / ratioBase
        );
        if (buyBackSwitch) {
            _buyBackAPi((buyAmount * buyBackAPiCoinRatio) / ratioBase);
        } else {
            usdt.safeTransfer(
                foundationAccount,
                (buyAmount * buyBackAPiCoinRatio) / ratioBase
            );
        }
        usdt.safeTransferFrom(
            msg.sender,
            foundationAccount,
            (buyAmount * foundationRatio) / ratioBase
        );
        usdt.safeTransferFrom(
            msg.sender,
            marketAccount,
            (buyAmount * marketRatio) / ratioBase
        );
        usdt.safeTransferFrom(
            msg.sender,
            communityAccount,
            (buyAmount * communityRatio) / ratioBase
        );
    }

    function _buyBackAPi(uint usdtAmount) internal {
        address[] memory path = new address[](2);
        path[0] = address(usdt);
        path[1] = address(APi);
        usdt.approve(address(pancakeRouter), usdtAmount);
        uint APiAmountBefore = balance(address(APi));
        pancakeRouter.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            usdtAmount,
            0,
            path,
            address(this),
            block.timestamp + 360
        );
        uint APiAmountAfter = balance(address(APi));

        (bool success, bytes memory returnData) = address(APi).call(
            abi.encodeWithSelector(
                bytes4(keccak256("burn(uint256)")),
                (APiAmountAfter - APiAmountBefore)
            )
        );
        require(
            success &&
                (returnData.length == 0 || abi.decode(returnData, (bool))),
            "B F"
        );
    }

    function _addInviteReward(uint pendingReward, uint financialType) internal {
        address lastferrer = msg.sender;
        for (uint i = 0; i < 6; i++) {
            address lastGeneration = referrer[lastferrer];
            if (lastGeneration == address(0)) {
                break;
            }
            uint inviteReward = (pendingReward * nextGenerationRatio[i + 1]) /
                generationRatioBase;
            _updateInviteReward(lastGeneration, financialType, inviteReward);
            lastferrer = lastGeneration;
        }
        _updateNextGeneration(
            referrers[msg.sender].oneNextGenerations,
            financialType,
            pendingReward,
            oneLastGenerationRation
        );
        _updateNextGeneration(
            referrers[msg.sender].twoNextGenerations,
            financialType,
            pendingReward,
            twoLastGenerationRation
        );
        _updateNextGeneration(
            referrers[msg.sender].threeNextGenerations,
            financialType,
            pendingReward,
            threeLastGenerationRation
        );
    }

    function _updateNextGeneration(
        address[] memory nextGenerations,
        uint financialType,
        uint pendingReward,
        uint ratio
    ) internal {
        for (uint i = 0; i < nextGenerations.length; i++) {
            address nextGeneration = nextGenerations[i];
            FinancialInterest memory financialInterest = financialInterestInfos[
                nextGeneration
            ][financialType];
            if (
                financialInterest.exitAmount -
                    financialInterest.withdrawAmount <
                lastGenerationQuali * exitInterestTimes
            ) {
                continue;
            }
            uint inviteReward = (pendingReward * ratio) / generationRatioBase;
            _updateInviteReward(nextGeneration, financialType, inviteReward);
        }
    }

    function _updateInviteReward(
        address user,
        uint financialType,
        uint inviteReward
    ) internal {
        FinancialInterest memory financialInterest = financialInterestInfos[
            user
        ][financialType];
        if (
            financialInterest.withdrawAmount + inviteReward >=
            financialInterest.exitAmount
        ) {
            inviteReward =
                financialInterest.exitAmount -
                financialInterest.withdrawAmount;
        }
        inviteInterestInfos[user][financialType].pendingAmount += inviteReward;
    }

    function getUnionCoinAmount(uint usdtAmount) public view returns (uint) {
        address[] memory path = new address[](2);
        path[0] = address(usdt);
        path[1] = address(unionCoin);
        uint[] memory amounts = pancakeRouter.getAmountsOut(usdtAmount, path);
        require(amounts.length > 1, "am");
        return amounts[1];
    }
}
