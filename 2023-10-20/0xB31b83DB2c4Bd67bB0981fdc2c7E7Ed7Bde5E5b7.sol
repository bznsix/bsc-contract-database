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
pragma solidity ^0.8.2;
// SPDX-License-Identifier: MIT

interface ICanSellAmount {

    function caller() external view returns (address);

    function changeCaller(address caller_) external;

    function getMatchingAddress() external view returns (address);

    function changeMatchingAddress(address matchingAddress_) external;

    function claimValues(address token_, address to_) external;

    function addAccountCanSellAmount(address[] memory accounts_, uint256[] memory amounts_) external;

    function getAccountCanSellAmount(address account_) external view returns (uint256);

    function subAccountCanSellAmount(address account_, uint256 amount_) external;
}
pragma solidity ^0.8.2;
// SPDX-License-Identifier: MIT
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./ICanSellAmount.sol";

interface IMatching {
    function baseToken() external view returns (IERC20);

    function quoteToken() external view returns (IERC20);

    function getHanger() external view returns (address);

    function getICanSellAmount() external view returns (ICanSellAmount);

    function changeHanger(address hanger_) external;

    function precision() external view returns (uint256);

    function buyDepth() external view returns (uint256);

    function changeSellDepth(uint256 newSellDepth_) external;

    function changeBuyDepth(uint256 newBuyDepth_) external;

    function sellDepth() external view returns (uint256);

    function claimValues(address token_, address to_) external;

    function latestOrderId() external view returns (uint256);

    function addBuyOrderBook(uint256 price_, uint256 amount_) external;

    function buyOrderBook(uint256 orderId_) external view returns (uint256);

    function buyOrderBookSize() external view returns (uint256);

    function getBuyOrderBook(uint256 depth_) external view returns (OrderBook[]memory);

    function getTopBuyOrderId() external view returns (uint256);

    function getBidRate() external view returns (uint256);

    function cancelBuyOrderBook(uint256 orderId_) external;

    function cancelAllBuyOrderBook() external;

    function marketPrice() external view returns (uint256);

    function addSellOrderBook(uint256 price_, uint256 amount_) external;

    function cancelSellOrderBook(uint256 orderId_) external;

    function cancelAllSellOrderBook() external;

    function sellOrderBook(uint256 orderId_) external view returns (uint256);

    function sellOrderBookSize() external view returns (uint256);

    function getTopSellOrderId() external view returns (uint256);

    function getAccountCanSellAmount(address account_) external view returns (uint256);

    function getAskRate() external view returns (uint256);

    function getSellOrderBook(uint256 depth_) external view returns (OrderBook[]memory);

    function orders(uint256 orderId_) external view returns (Order memory);

    function sell(uint256 amount_, uint256 receiveValue_) external;

    function buy(uint256 amount_, uint256 costValue_) external;


    event OrderEvent(uint256 indexed orderId, address user, bool orderType, uint256 price, uint256 amount, uint256 fillAmount, orderStateEnum orderState, uint256 orderTime);

    event OrderChangeEvent(uint256 indexed orderId, uint256 fillAmount, orderStateEnum orderState, uint256 changeTime);

    event TradeRecordEvent(address user, bool tradeType, uint256 amount, uint256 totalValue, uint256 averagePrice, uint256 limit);

    enum orderStateEnum{
        progress,
        success,
        canceled
    }

    struct Order {
        uint256 orderId;
        address user;
        // true:buy,false:sell
        bool orderType;
        uint256 price;
        uint256 amount;
        uint256 fillAmount;
        // 0 progress 1 success 2 canceled
        orderStateEnum orderState;
        uint256 orderTime;
    }

    struct OrderBook {
        uint256 orderId;
        uint256 price;
        uint256 amount;
    }
}
pragma solidity ^0.8.2;
// SPDX-License-Identifier: MIT

interface IStarPool {
    function switchStatus(uint8 type_) external view returns (bool);

    function nodeRegistered(address miner) external view returns (bool);

    function flashBuy(address miner, uint256 amount) external returns (uint256);
}
pragma solidity ^0.8.2;
// SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract Claimable {
    using SafeERC20 for IERC20;

    modifier validAddress(address _to) {
        require(_to != address(0));
        _;
    }
    function _claimValues(address token_, address to_) internal validAddress(to_) {
        if (token_ == address(0)) {
            _claimNativeCoins(to_);
        } else {
            _claimErc20Tokens(token_, to_);
        }
    }

    function _claimNativeCoins(address to_) internal {
        uint256 value = address(this).balance;
        _sendValue(payable(to_), value);
    }

    function _claimErc20Tokens(address token_, address to_) internal {
        IERC20 _ERC20 = IERC20(token_);
        uint256 balance = _ERC20.balanceOf(address(this));
        _ERC20.transfer(to_, balance);
    }

    function _sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");
        (bool success,) = recipient.call{value : amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
}
pragma solidity ^0.8.2;
// SPDX-License-Identifier: MIT
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "./lib/Claimable.sol";
import "./interfaces/IMatching.sol";
import "./interfaces/IStarPool.sol";

contract Matching is Ownable, Claimable, IMatching {
    using SafeERC20 for IERC20;
    using SafeMath for uint256;
    //s
    address private _baseToken;
    //u
    address private _quoteToken;
    address private _hanger;
    uint256 private _latestOrderId;
    uint256 private _buyOrderBookSize;
    uint256 private _sellOrderBookSize;
    uint256 private _buyDepth;
    uint256 private _sellDepth;
    uint256 private _precision;
    uint256 private _marketPrice;
    uint256 private _amountPre = 10000000000000000;
    address private _canSellAmountAddress;
    //orderId==>order
    mapping(uint256 => Order) private _orders;
    //orderId==>orderId
    mapping(uint256 => uint256) private _buyOrderBook;
    //orderId==>orderId
    mapping(uint256 => uint256) private _sellOrderBook;
    IStarPool private _starPool;

    fallback() external payable virtual {
    }

    receive() external payable virtual {
    }

    constructor (
        address baseToken_,
        address quoteToken_,
        address canSellAmountAddress_,
        address starPool_,
        address hanger_,
        uint256 buyDepth_,
        uint256 sellDepth_,
        uint256 precision_
    ) {
        _baseToken = baseToken_;
        _quoteToken = quoteToken_;
        _canSellAmountAddress = canSellAmountAddress_;
        _starPool = IStarPool(starPool_);
        _hanger = hanger_;
        _latestOrderId = block.timestamp;
        _buyDepth = buyDepth_;
        _sellDepth = sellDepth_;
        _precision = precision_;
    }

    modifier onlyHanger() {
        require(msg.sender == _hanger, "You don't have permission to call");
        _;
    }

    // get token
    function baseToken() public override view returns (IERC20) {
        return IERC20(_baseToken);
    }

    function quoteToken() public override view returns (IERC20) {
        return IERC20(_quoteToken);
    }

    function getHanger() public override view returns (address) {
        return _hanger;
    }

    function getICanSellAmount() public override view returns (ICanSellAmount) {
        return ICanSellAmount(_canSellAmountAddress);
    }

    // change the hanger
    function changeHanger(address hanger_) public override onlyOwner {
        require(hanger_ != address(0) && _buyOrderBook[0] == 0 && _sellOrderBook[0] == 0,
            "buyOrderBook is not empty and sellOrderBook is not empty");
        _hanger = hanger_;
    }

    function precision() public override view returns (uint256){
        return _precision;
    }

    function buyDepth() public override view returns (uint256){
        return _buyDepth;
    }

    function changeBuyDepth(uint256 newBuyDepth_) public override onlyHanger {
        _buyDepth = newBuyDepth_;
    }

    function changeSellDepth(uint256 newSellDepth_) public override onlyHanger {
        _sellDepth = newSellDepth_;
    }

    function sellDepth() public override view returns (uint256){
        return _sellDepth;
    }

    function claimValues(address token_, address to_) public override onlyOwner {
        require(token_ != _baseToken && token_ != _quoteToken, "error token");
        _claimValues(token_, to_);
    }

    function orders(uint256 orderId_) public override view returns (Order memory){
        return _orders[orderId_];
    }

    function getTopBuyOrderId() public override view returns (uint256) {
        return _buyOrderBook[0];
    }

    function getBidRate() public override view returns (uint256) {
        return _buyOrderBook[0] > 0 ? _orders[_buyOrderBook[0]].price : 0;
    }

    function marketPrice() public override view returns (uint256){
        return _marketPrice;
    }

    function sellOrderBook(uint256 orderId_) public override view returns (uint256){
        return _sellOrderBook[orderId_];
    }


    function sellOrderBookSize() public override view returns (uint256){
        return _sellOrderBookSize;
    }

    function getAskRate() public override view returns (uint256) {
        return _sellOrderBook[0] > 0 ? _orders[_sellOrderBook[0]].price : 0;
    }

    function getTopSellOrderId() public override view returns (uint256) {
        return _sellOrderBook[0];
    }

    function getAccountCanSellAmount(address account_) public override view returns (uint256) {
        return getICanSellAmount().getAccountCanSellAmount(account_);
    }

    function latestOrderId() public override view returns (uint256){
        return _latestOrderId;
    }

    function cancelBuyOrderBook(uint256 orderId_) public override onlyHanger {
        require(_orders[orderId_].orderState == orderStateEnum.progress, "order status error");
        uint256 preId = 0;
        uint256 nextId = _buyOrderBook[preId];
        while (nextId > 0) {
            if (nextId == orderId_) {
                _buyOrderBook[preId] = _buyOrderBook[nextId];
                Order memory order = _orders[orderId_];
                order.orderState = orderStateEnum.canceled;
                _updateOrder(order);
                _buyOrderBookSize--;
                uint256 refundValue = order.price * (order.amount - order.fillAmount) / _precision;
                require(quoteToken().transfer(getHanger(), refundValue), "refund value fail");
                break;
            }
            preId = nextId;
            nextId = _buyOrderBook[nextId];
        }
    }

    function cancelAllBuyOrderBook() public override onlyHanger {
        uint256 nextId = _buyOrderBook[0];
        uint256 refundTotalValue = 0;
        while (nextId > 0) {
            Order memory order = _orders[nextId];
            order.orderState = orderStateEnum.canceled;
            _updateOrder(order);
            nextId = _buyOrderBook[nextId];
            refundTotalValue += order.price * (order.amount - order.fillAmount) / _precision;
            _buyOrderBookSize--;
        }
        _buyOrderBook[0] = 0;
        if (refundTotalValue > 0) {
            require(quoteToken().transfer(getHanger(), refundTotalValue), "refund value fail");
        }
    }

    function getBuyOrderBook(uint256 depth_) public override view returns (OrderBook[] memory){
        uint256 size = depth_ >= _buyOrderBookSize ? _buyOrderBookSize : depth_;
        OrderBook[] memory orderBooks = new OrderBook[](size);
        uint256 nextId = _buyOrderBook[0];
        uint256 indexDepth = 0;
        while (nextId > 0 && indexDepth <= depth_) {
            Order memory order = _orders[nextId];
            OrderBook memory orderBook;
            orderBook.orderId = order.orderId;
            orderBook.price = order.price;
            orderBook.amount = order.amount - order.fillAmount;
            orderBooks[indexDepth] = orderBook;
            indexDepth++;
            nextId = _buyOrderBook[nextId];
        }
        return orderBooks;
    }

    function addBuyOrderBook(uint256 price_, uint256 amount_) public override onlyHanger {
        require(price_ > 0, "price error");
        require(amount_ > 0 && amount_ % _amountPre == 0, "amount precision error");
        if (_sellOrderBookSize > 0) {
            require(price_ < getAskRate(), "price too large");
        }
        uint256 costValue = amount_ * price_ / _precision;
        require(costValue > 0, "costValue error");
        require(quoteToken().transferFrom(msg.sender, address(this), costValue), "quote token transfer error");
        uint256 orderId = _createOrderId();
        _addOrder(orderId, msg.sender, true, price_, amount_);
        uint256 preId = 0;
        uint256 nextId = _buyOrderBook[preId];
        while (nextId > 0) {
            uint256 nextPrice = _orders[nextId].price;
            require(price_ != nextPrice, "price error");
            if (nextPrice < price_) {
                break;
            }
            preId = nextId;
            nextId = _buyOrderBook[nextId];
        }
        _buyOrderBook[preId] = orderId;
        _buyOrderBook[orderId] = nextId;
        _buyOrderBookSize++;
    }


    function buyOrderBook(uint256 orderId_) public override view returns (uint256){
        return _buyOrderBook[orderId_];
    }

    function buyOrderBookSize() public override view returns (uint256){
        return _buyOrderBookSize;
    }

    function cancelSellOrderBook(uint256 orderId_) public override onlyHanger {
        require(_orders[orderId_].orderState == orderStateEnum.progress, "order status error");
        uint256 preId = 0;
        uint256 nextId = _sellOrderBook[preId];
        while (nextId > 0) {
            if (nextId == orderId_) {
                _sellOrderBook[preId] = _sellOrderBook[nextId];
                Order memory order = _orders[orderId_];
                order.orderState = orderStateEnum.canceled;
                _updateOrder(order);
                _sellOrderBookSize--;
                uint256 refundAmount = order.amount - order.fillAmount;
                require(baseToken().transfer(getHanger(), refundAmount), "refund amount fail");
                break;
            }
            preId = nextId;
            nextId = _sellOrderBook[nextId];
        }
    }

    function cancelAllSellOrderBook() public override onlyHanger {
        uint256 nextId = _sellOrderBook[0];
        uint256 refundTotalAmount = 0;
        while (nextId > 0) {
            Order memory order = _orders[nextId];
            order.orderState = orderStateEnum.canceled;
            _updateOrder(order);
            nextId = _sellOrderBook[nextId];
            _sellOrderBookSize--;
            refundTotalAmount += order.amount - order.fillAmount;
        }
        _sellOrderBook[0] = 0;
        if (refundTotalAmount > 0) {
            require(baseToken().transfer(getHanger(), refundTotalAmount), "refund amount fail");
        }
    }


    function getSellOrderBook(uint256 depth_) public override view returns (OrderBook[]memory){
        uint256 size = depth_ >= _sellOrderBookSize ? _sellOrderBookSize : depth_;
        OrderBook[] memory orderBooks = new OrderBook[](size);
        uint256 nextId = _sellOrderBook[0];
        uint indexDepth = 0;
        while (nextId > 0 && indexDepth <= depth_) {
            Order memory order = _orders[nextId];
            OrderBook memory orderBook;
            orderBook.orderId = order.orderId;
            orderBook.price = order.price;
            orderBook.amount = order.amount - order.fillAmount;
            orderBooks[indexDepth] = orderBook;
            indexDepth++;
            nextId = _sellOrderBook[nextId];
        }
        return orderBooks;
    }

    function addSellOrderBook(uint256 price_, uint256 amount_) public override onlyHanger {
        require(price_ > 0, "price error");
        if (_buyOrderBookSize > 0) {
            require(price_ > getBidRate(), "price too small");
        }
        require(amount_ > 0 && amount_ % _amountPre == 0, "amount  error");
        uint256 orderId = _createOrderId();
        require(baseToken().transferFrom(msg.sender, address(this), amount_), "base token transfer error");
        _addOrder(orderId, msg.sender, false, price_, amount_);
        uint256 preId = 0;
        uint256 nextId = _sellOrderBook[preId];
        while (nextId > 0) {
            uint256 nextPrice = _orders[nextId].price;
            require(price_ != nextPrice, "price error");
            if (nextPrice > price_) {
                break;
            }
            preId = nextId;
            nextId = _sellOrderBook[nextId];
        }
        _sellOrderBook[preId] = orderId;
        _sellOrderBook[orderId] = nextId;
        _sellOrderBookSize++;
    }

    function buy(uint256 amount_, uint256 costValue_) public override {
        require(amount_ > 0 && amount_ % _amountPre == 0, "amount error");
        require(costValue_ > 0, "costValue error");
        require(quoteToken().transferFrom(msg.sender, address(this), costValue_), "quote token transfer error");
        uint256 indexDepth = 0;
        uint256 waitAmount = amount_;
        uint256 totalValue = 0;
        while (indexDepth <= _buyDepth && waitAmount > 0) {
            uint256 topOrderId = getTopSellOrderId();
            if (topOrderId == 0) {
                break;
            }
            Order memory order = _orders[topOrderId];
            uint256 currentAmount = order.amount - order.fillAmount;
            if (waitAmount >= currentAmount) {
                order.fillAmount += currentAmount;
                order.orderState = orderStateEnum.success;
                waitAmount -= currentAmount;
                totalValue += order.price * currentAmount / _precision;
                _deleteTopSellOrderId();
            } else {
                order.fillAmount += waitAmount;
                totalValue += order.price * waitAmount / _precision;
                waitAmount = 0;
            }
            _marketPrice = order.price;
            _updateOrder(order);
            indexDepth++;
        }
        require(waitAmount == 0, "trade amount error");
        require(totalValue == costValue_, "trade costValue error");
        uint256 averagePrice = totalValue * _precision / amount_;
        require(quoteToken().transfer(getHanger(), costValue_), "quote token transfer error");
        uint256 limit = 0;
        if (_starPool.switchStatus(0)) {
            bool registered = _starPool.nodeRegistered(msg.sender);
            if (registered) {
                require(baseToken().approve(address(_starPool), amount_), "approve failed");
            } else {
                require(baseToken().transfer(msg.sender, amount_), "base token transfer error");
            }
            limit = _starPool.flashBuy(msg.sender, amount_);
        } else {
            require(baseToken().transfer(msg.sender, amount_), "base token transfer error");
        }
        emit TradeRecordEvent(msg.sender, true, amount_, totalValue, averagePrice, limit);
    }

    function sell(uint256 amount_, uint256 receiveValue_) public override {
        require(getAccountCanSellAmount(msg.sender) - amount_ >= 0 && amount_ > 0 && amount_ % _amountPre == 0,
            "amount error");
        require(baseToken().transferFrom(msg.sender, address(this), amount_), "base token transfer error");
        uint256 indexDepth = 0;
        uint256 waitAmount = amount_;
        uint256 totalValue = 0;
        while (indexDepth <= _sellDepth && waitAmount > 0) {
            uint256 topOrderId = getTopBuyOrderId();
            if (topOrderId == 0) {
                break;
            }
            Order memory order = _orders[topOrderId];
            uint256 currentAmount = order.amount - order.fillAmount;
            if (waitAmount >= currentAmount) {
                order.fillAmount += currentAmount;
                order.orderState = orderStateEnum.success;
                waitAmount -= currentAmount;
                totalValue += order.price * currentAmount / _precision;
                _deleteTopBuyOrderId();
            } else {
                order.fillAmount += waitAmount;
                totalValue += order.price * waitAmount / _precision;
                waitAmount = 0;
            }
            _marketPrice = order.price;
            _updateOrder(order);
            indexDepth++;
        }
        require(waitAmount == 0, "trade amount error");
        require(totalValue == receiveValue_, "receiveValue error");
        uint256 averagePrice = totalValue * _precision / amount_;
        require(quoteToken().transfer(msg.sender, totalValue), "quote token transfer error");
        require(baseToken().transfer(getHanger(), amount_), "base token transfer error");
        getICanSellAmount().subAccountCanSellAmount(msg.sender, amount_);
        emit TradeRecordEvent(msg.sender, false, amount_, totalValue, averagePrice, 0);
    }

    function _addOrder(uint256 orderId_, address user_, bool orderType_, uint256 price_, uint256 amount_) internal {
        _orders[orderId_] = Order(orderId_, user_, orderType_, price_, amount_, 0, orderStateEnum.progress, block.timestamp);
        emit OrderEvent(orderId_, user_, orderType_, price_, amount_, 0, orderStateEnum.progress, block.timestamp);
    }

    function _createOrderId() internal returns (uint256){
        _latestOrderId++;
        return _latestOrderId;
    }

    function _updateOrder(Order memory order_) internal {
        _orders[order_.orderId] = order_;
        emit OrderChangeEvent(order_.orderId, order_.fillAmount, order_.orderState, block.timestamp);
    }

    function _deleteTopSellOrderId() internal {
        _sellOrderBook[0] = _sellOrderBook[_sellOrderBook[0]];
        _sellOrderBookSize--;
    }

    function _deleteTopBuyOrderId() internal {
        _buyOrderBook[0] = _buyOrderBook[_buyOrderBook[0]];
        _buyOrderBookSize--;
    }
}
