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
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/draft-IERC20Permit.sol)

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
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

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
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";
import "../extensions/draft-IERC20Permit.sol";
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

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

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
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (utils/Address.sol)

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
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (utils/math/SafeCast.sol)

pragma solidity ^0.8.0;

/**
 * @dev Wrappers over Solidity's uintXX/intXX casting operators with added overflow
 * checks.
 *
 * Downcasting from uint256/int256 in Solidity does not revert on overflow. This can
 * easily result in undesired exploitation or bugs, since developers usually
 * assume that overflows raise errors. `SafeCast` restores this intuition by
 * reverting the transaction when such an operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 *
 * Can be combined with {SafeMath} and {SignedSafeMath} to extend it to smaller types, by performing
 * all math on `uint256` and `int256` and then downcasting.
 */
library SafeCast {
    /**
     * @dev Returns the downcasted uint248 from uint256, reverting on
     * overflow (when the input is greater than largest uint248).
     *
     * Counterpart to Solidity's `uint248` operator.
     *
     * Requirements:
     *
     * - input must fit into 248 bits
     *
     * _Available since v4.7._
     */
    function toUint248(uint256 value) internal pure returns (uint248) {
        require(value <= type(uint248).max, "SafeCast: value doesn't fit in 248 bits");
        return uint248(value);
    }

    /**
     * @dev Returns the downcasted uint240 from uint256, reverting on
     * overflow (when the input is greater than largest uint240).
     *
     * Counterpart to Solidity's `uint240` operator.
     *
     * Requirements:
     *
     * - input must fit into 240 bits
     *
     * _Available since v4.7._
     */
    function toUint240(uint256 value) internal pure returns (uint240) {
        require(value <= type(uint240).max, "SafeCast: value doesn't fit in 240 bits");
        return uint240(value);
    }

    /**
     * @dev Returns the downcasted uint232 from uint256, reverting on
     * overflow (when the input is greater than largest uint232).
     *
     * Counterpart to Solidity's `uint232` operator.
     *
     * Requirements:
     *
     * - input must fit into 232 bits
     *
     * _Available since v4.7._
     */
    function toUint232(uint256 value) internal pure returns (uint232) {
        require(value <= type(uint232).max, "SafeCast: value doesn't fit in 232 bits");
        return uint232(value);
    }

    /**
     * @dev Returns the downcasted uint224 from uint256, reverting on
     * overflow (when the input is greater than largest uint224).
     *
     * Counterpart to Solidity's `uint224` operator.
     *
     * Requirements:
     *
     * - input must fit into 224 bits
     *
     * _Available since v4.2._
     */
    function toUint224(uint256 value) internal pure returns (uint224) {
        require(value <= type(uint224).max, "SafeCast: value doesn't fit in 224 bits");
        return uint224(value);
    }

    /**
     * @dev Returns the downcasted uint216 from uint256, reverting on
     * overflow (when the input is greater than largest uint216).
     *
     * Counterpart to Solidity's `uint216` operator.
     *
     * Requirements:
     *
     * - input must fit into 216 bits
     *
     * _Available since v4.7._
     */
    function toUint216(uint256 value) internal pure returns (uint216) {
        require(value <= type(uint216).max, "SafeCast: value doesn't fit in 216 bits");
        return uint216(value);
    }

    /**
     * @dev Returns the downcasted uint208 from uint256, reverting on
     * overflow (when the input is greater than largest uint208).
     *
     * Counterpart to Solidity's `uint208` operator.
     *
     * Requirements:
     *
     * - input must fit into 208 bits
     *
     * _Available since v4.7._
     */
    function toUint208(uint256 value) internal pure returns (uint208) {
        require(value <= type(uint208).max, "SafeCast: value doesn't fit in 208 bits");
        return uint208(value);
    }

    /**
     * @dev Returns the downcasted uint200 from uint256, reverting on
     * overflow (when the input is greater than largest uint200).
     *
     * Counterpart to Solidity's `uint200` operator.
     *
     * Requirements:
     *
     * - input must fit into 200 bits
     *
     * _Available since v4.7._
     */
    function toUint200(uint256 value) internal pure returns (uint200) {
        require(value <= type(uint200).max, "SafeCast: value doesn't fit in 200 bits");
        return uint200(value);
    }

    /**
     * @dev Returns the downcasted uint192 from uint256, reverting on
     * overflow (when the input is greater than largest uint192).
     *
     * Counterpart to Solidity's `uint192` operator.
     *
     * Requirements:
     *
     * - input must fit into 192 bits
     *
     * _Available since v4.7._
     */
    function toUint192(uint256 value) internal pure returns (uint192) {
        require(value <= type(uint192).max, "SafeCast: value doesn't fit in 192 bits");
        return uint192(value);
    }

    /**
     * @dev Returns the downcasted uint184 from uint256, reverting on
     * overflow (when the input is greater than largest uint184).
     *
     * Counterpart to Solidity's `uint184` operator.
     *
     * Requirements:
     *
     * - input must fit into 184 bits
     *
     * _Available since v4.7._
     */
    function toUint184(uint256 value) internal pure returns (uint184) {
        require(value <= type(uint184).max, "SafeCast: value doesn't fit in 184 bits");
        return uint184(value);
    }

    /**
     * @dev Returns the downcasted uint176 from uint256, reverting on
     * overflow (when the input is greater than largest uint176).
     *
     * Counterpart to Solidity's `uint176` operator.
     *
     * Requirements:
     *
     * - input must fit into 176 bits
     *
     * _Available since v4.7._
     */
    function toUint176(uint256 value) internal pure returns (uint176) {
        require(value <= type(uint176).max, "SafeCast: value doesn't fit in 176 bits");
        return uint176(value);
    }

    /**
     * @dev Returns the downcasted uint168 from uint256, reverting on
     * overflow (when the input is greater than largest uint168).
     *
     * Counterpart to Solidity's `uint168` operator.
     *
     * Requirements:
     *
     * - input must fit into 168 bits
     *
     * _Available since v4.7._
     */
    function toUint168(uint256 value) internal pure returns (uint168) {
        require(value <= type(uint168).max, "SafeCast: value doesn't fit in 168 bits");
        return uint168(value);
    }

    /**
     * @dev Returns the downcasted uint160 from uint256, reverting on
     * overflow (when the input is greater than largest uint160).
     *
     * Counterpart to Solidity's `uint160` operator.
     *
     * Requirements:
     *
     * - input must fit into 160 bits
     *
     * _Available since v4.7._
     */
    function toUint160(uint256 value) internal pure returns (uint160) {
        require(value <= type(uint160).max, "SafeCast: value doesn't fit in 160 bits");
        return uint160(value);
    }

    /**
     * @dev Returns the downcasted uint152 from uint256, reverting on
     * overflow (when the input is greater than largest uint152).
     *
     * Counterpart to Solidity's `uint152` operator.
     *
     * Requirements:
     *
     * - input must fit into 152 bits
     *
     * _Available since v4.7._
     */
    function toUint152(uint256 value) internal pure returns (uint152) {
        require(value <= type(uint152).max, "SafeCast: value doesn't fit in 152 bits");
        return uint152(value);
    }

    /**
     * @dev Returns the downcasted uint144 from uint256, reverting on
     * overflow (when the input is greater than largest uint144).
     *
     * Counterpart to Solidity's `uint144` operator.
     *
     * Requirements:
     *
     * - input must fit into 144 bits
     *
     * _Available since v4.7._
     */
    function toUint144(uint256 value) internal pure returns (uint144) {
        require(value <= type(uint144).max, "SafeCast: value doesn't fit in 144 bits");
        return uint144(value);
    }

    /**
     * @dev Returns the downcasted uint136 from uint256, reverting on
     * overflow (when the input is greater than largest uint136).
     *
     * Counterpart to Solidity's `uint136` operator.
     *
     * Requirements:
     *
     * - input must fit into 136 bits
     *
     * _Available since v4.7._
     */
    function toUint136(uint256 value) internal pure returns (uint136) {
        require(value <= type(uint136).max, "SafeCast: value doesn't fit in 136 bits");
        return uint136(value);
    }

    /**
     * @dev Returns the downcasted uint128 from uint256, reverting on
     * overflow (when the input is greater than largest uint128).
     *
     * Counterpart to Solidity's `uint128` operator.
     *
     * Requirements:
     *
     * - input must fit into 128 bits
     *
     * _Available since v2.5._
     */
    function toUint128(uint256 value) internal pure returns (uint128) {
        require(value <= type(uint128).max, "SafeCast: value doesn't fit in 128 bits");
        return uint128(value);
    }

    /**
     * @dev Returns the downcasted uint120 from uint256, reverting on
     * overflow (when the input is greater than largest uint120).
     *
     * Counterpart to Solidity's `uint120` operator.
     *
     * Requirements:
     *
     * - input must fit into 120 bits
     *
     * _Available since v4.7._
     */
    function toUint120(uint256 value) internal pure returns (uint120) {
        require(value <= type(uint120).max, "SafeCast: value doesn't fit in 120 bits");
        return uint120(value);
    }

    /**
     * @dev Returns the downcasted uint112 from uint256, reverting on
     * overflow (when the input is greater than largest uint112).
     *
     * Counterpart to Solidity's `uint112` operator.
     *
     * Requirements:
     *
     * - input must fit into 112 bits
     *
     * _Available since v4.7._
     */
    function toUint112(uint256 value) internal pure returns (uint112) {
        require(value <= type(uint112).max, "SafeCast: value doesn't fit in 112 bits");
        return uint112(value);
    }

    /**
     * @dev Returns the downcasted uint104 from uint256, reverting on
     * overflow (when the input is greater than largest uint104).
     *
     * Counterpart to Solidity's `uint104` operator.
     *
     * Requirements:
     *
     * - input must fit into 104 bits
     *
     * _Available since v4.7._
     */
    function toUint104(uint256 value) internal pure returns (uint104) {
        require(value <= type(uint104).max, "SafeCast: value doesn't fit in 104 bits");
        return uint104(value);
    }

    /**
     * @dev Returns the downcasted uint96 from uint256, reverting on
     * overflow (when the input is greater than largest uint96).
     *
     * Counterpart to Solidity's `uint96` operator.
     *
     * Requirements:
     *
     * - input must fit into 96 bits
     *
     * _Available since v4.2._
     */
    function toUint96(uint256 value) internal pure returns (uint96) {
        require(value <= type(uint96).max, "SafeCast: value doesn't fit in 96 bits");
        return uint96(value);
    }

    /**
     * @dev Returns the downcasted uint88 from uint256, reverting on
     * overflow (when the input is greater than largest uint88).
     *
     * Counterpart to Solidity's `uint88` operator.
     *
     * Requirements:
     *
     * - input must fit into 88 bits
     *
     * _Available since v4.7._
     */
    function toUint88(uint256 value) internal pure returns (uint88) {
        require(value <= type(uint88).max, "SafeCast: value doesn't fit in 88 bits");
        return uint88(value);
    }

    /**
     * @dev Returns the downcasted uint80 from uint256, reverting on
     * overflow (when the input is greater than largest uint80).
     *
     * Counterpart to Solidity's `uint80` operator.
     *
     * Requirements:
     *
     * - input must fit into 80 bits
     *
     * _Available since v4.7._
     */
    function toUint80(uint256 value) internal pure returns (uint80) {
        require(value <= type(uint80).max, "SafeCast: value doesn't fit in 80 bits");
        return uint80(value);
    }

    /**
     * @dev Returns the downcasted uint72 from uint256, reverting on
     * overflow (when the input is greater than largest uint72).
     *
     * Counterpart to Solidity's `uint72` operator.
     *
     * Requirements:
     *
     * - input must fit into 72 bits
     *
     * _Available since v4.7._
     */
    function toUint72(uint256 value) internal pure returns (uint72) {
        require(value <= type(uint72).max, "SafeCast: value doesn't fit in 72 bits");
        return uint72(value);
    }

    /**
     * @dev Returns the downcasted uint64 from uint256, reverting on
     * overflow (when the input is greater than largest uint64).
     *
     * Counterpart to Solidity's `uint64` operator.
     *
     * Requirements:
     *
     * - input must fit into 64 bits
     *
     * _Available since v2.5._
     */
    function toUint64(uint256 value) internal pure returns (uint64) {
        require(value <= type(uint64).max, "SafeCast: value doesn't fit in 64 bits");
        return uint64(value);
    }

    /**
     * @dev Returns the downcasted uint56 from uint256, reverting on
     * overflow (when the input is greater than largest uint56).
     *
     * Counterpart to Solidity's `uint56` operator.
     *
     * Requirements:
     *
     * - input must fit into 56 bits
     *
     * _Available since v4.7._
     */
    function toUint56(uint256 value) internal pure returns (uint56) {
        require(value <= type(uint56).max, "SafeCast: value doesn't fit in 56 bits");
        return uint56(value);
    }

    /**
     * @dev Returns the downcasted uint48 from uint256, reverting on
     * overflow (when the input is greater than largest uint48).
     *
     * Counterpart to Solidity's `uint48` operator.
     *
     * Requirements:
     *
     * - input must fit into 48 bits
     *
     * _Available since v4.7._
     */
    function toUint48(uint256 value) internal pure returns (uint48) {
        require(value <= type(uint48).max, "SafeCast: value doesn't fit in 48 bits");
        return uint48(value);
    }

    /**
     * @dev Returns the downcasted uint40 from uint256, reverting on
     * overflow (when the input is greater than largest uint40).
     *
     * Counterpart to Solidity's `uint40` operator.
     *
     * Requirements:
     *
     * - input must fit into 40 bits
     *
     * _Available since v4.7._
     */
    function toUint40(uint256 value) internal pure returns (uint40) {
        require(value <= type(uint40).max, "SafeCast: value doesn't fit in 40 bits");
        return uint40(value);
    }

    /**
     * @dev Returns the downcasted uint32 from uint256, reverting on
     * overflow (when the input is greater than largest uint32).
     *
     * Counterpart to Solidity's `uint32` operator.
     *
     * Requirements:
     *
     * - input must fit into 32 bits
     *
     * _Available since v2.5._
     */
    function toUint32(uint256 value) internal pure returns (uint32) {
        require(value <= type(uint32).max, "SafeCast: value doesn't fit in 32 bits");
        return uint32(value);
    }

    /**
     * @dev Returns the downcasted uint24 from uint256, reverting on
     * overflow (when the input is greater than largest uint24).
     *
     * Counterpart to Solidity's `uint24` operator.
     *
     * Requirements:
     *
     * - input must fit into 24 bits
     *
     * _Available since v4.7._
     */
    function toUint24(uint256 value) internal pure returns (uint24) {
        require(value <= type(uint24).max, "SafeCast: value doesn't fit in 24 bits");
        return uint24(value);
    }

    /**
     * @dev Returns the downcasted uint16 from uint256, reverting on
     * overflow (when the input is greater than largest uint16).
     *
     * Counterpart to Solidity's `uint16` operator.
     *
     * Requirements:
     *
     * - input must fit into 16 bits
     *
     * _Available since v2.5._
     */
    function toUint16(uint256 value) internal pure returns (uint16) {
        require(value <= type(uint16).max, "SafeCast: value doesn't fit in 16 bits");
        return uint16(value);
    }

    /**
     * @dev Returns the downcasted uint8 from uint256, reverting on
     * overflow (when the input is greater than largest uint8).
     *
     * Counterpart to Solidity's `uint8` operator.
     *
     * Requirements:
     *
     * - input must fit into 8 bits
     *
     * _Available since v2.5._
     */
    function toUint8(uint256 value) internal pure returns (uint8) {
        require(value <= type(uint8).max, "SafeCast: value doesn't fit in 8 bits");
        return uint8(value);
    }

    /**
     * @dev Converts a signed int256 into an unsigned uint256.
     *
     * Requirements:
     *
     * - input must be greater than or equal to 0.
     *
     * _Available since v3.0._
     */
    function toUint256(int256 value) internal pure returns (uint256) {
        require(value >= 0, "SafeCast: value must be positive");
        return uint256(value);
    }

    /**
     * @dev Returns the downcasted int248 from int256, reverting on
     * overflow (when the input is less than smallest int248 or
     * greater than largest int248).
     *
     * Counterpart to Solidity's `int248` operator.
     *
     * Requirements:
     *
     * - input must fit into 248 bits
     *
     * _Available since v4.7._
     */
    function toInt248(int256 value) internal pure returns (int248) {
        require(value >= type(int248).min && value <= type(int248).max, "SafeCast: value doesn't fit in 248 bits");
        return int248(value);
    }

    /**
     * @dev Returns the downcasted int240 from int256, reverting on
     * overflow (when the input is less than smallest int240 or
     * greater than largest int240).
     *
     * Counterpart to Solidity's `int240` operator.
     *
     * Requirements:
     *
     * - input must fit into 240 bits
     *
     * _Available since v4.7._
     */
    function toInt240(int256 value) internal pure returns (int240) {
        require(value >= type(int240).min && value <= type(int240).max, "SafeCast: value doesn't fit in 240 bits");
        return int240(value);
    }

    /**
     * @dev Returns the downcasted int232 from int256, reverting on
     * overflow (when the input is less than smallest int232 or
     * greater than largest int232).
     *
     * Counterpart to Solidity's `int232` operator.
     *
     * Requirements:
     *
     * - input must fit into 232 bits
     *
     * _Available since v4.7._
     */
    function toInt232(int256 value) internal pure returns (int232) {
        require(value >= type(int232).min && value <= type(int232).max, "SafeCast: value doesn't fit in 232 bits");
        return int232(value);
    }

    /**
     * @dev Returns the downcasted int224 from int256, reverting on
     * overflow (when the input is less than smallest int224 or
     * greater than largest int224).
     *
     * Counterpart to Solidity's `int224` operator.
     *
     * Requirements:
     *
     * - input must fit into 224 bits
     *
     * _Available since v4.7._
     */
    function toInt224(int256 value) internal pure returns (int224) {
        require(value >= type(int224).min && value <= type(int224).max, "SafeCast: value doesn't fit in 224 bits");
        return int224(value);
    }

    /**
     * @dev Returns the downcasted int216 from int256, reverting on
     * overflow (when the input is less than smallest int216 or
     * greater than largest int216).
     *
     * Counterpart to Solidity's `int216` operator.
     *
     * Requirements:
     *
     * - input must fit into 216 bits
     *
     * _Available since v4.7._
     */
    function toInt216(int256 value) internal pure returns (int216) {
        require(value >= type(int216).min && value <= type(int216).max, "SafeCast: value doesn't fit in 216 bits");
        return int216(value);
    }

    /**
     * @dev Returns the downcasted int208 from int256, reverting on
     * overflow (when the input is less than smallest int208 or
     * greater than largest int208).
     *
     * Counterpart to Solidity's `int208` operator.
     *
     * Requirements:
     *
     * - input must fit into 208 bits
     *
     * _Available since v4.7._
     */
    function toInt208(int256 value) internal pure returns (int208) {
        require(value >= type(int208).min && value <= type(int208).max, "SafeCast: value doesn't fit in 208 bits");
        return int208(value);
    }

    /**
     * @dev Returns the downcasted int200 from int256, reverting on
     * overflow (when the input is less than smallest int200 or
     * greater than largest int200).
     *
     * Counterpart to Solidity's `int200` operator.
     *
     * Requirements:
     *
     * - input must fit into 200 bits
     *
     * _Available since v4.7._
     */
    function toInt200(int256 value) internal pure returns (int200) {
        require(value >= type(int200).min && value <= type(int200).max, "SafeCast: value doesn't fit in 200 bits");
        return int200(value);
    }

    /**
     * @dev Returns the downcasted int192 from int256, reverting on
     * overflow (when the input is less than smallest int192 or
     * greater than largest int192).
     *
     * Counterpart to Solidity's `int192` operator.
     *
     * Requirements:
     *
     * - input must fit into 192 bits
     *
     * _Available since v4.7._
     */
    function toInt192(int256 value) internal pure returns (int192) {
        require(value >= type(int192).min && value <= type(int192).max, "SafeCast: value doesn't fit in 192 bits");
        return int192(value);
    }

    /**
     * @dev Returns the downcasted int184 from int256, reverting on
     * overflow (when the input is less than smallest int184 or
     * greater than largest int184).
     *
     * Counterpart to Solidity's `int184` operator.
     *
     * Requirements:
     *
     * - input must fit into 184 bits
     *
     * _Available since v4.7._
     */
    function toInt184(int256 value) internal pure returns (int184) {
        require(value >= type(int184).min && value <= type(int184).max, "SafeCast: value doesn't fit in 184 bits");
        return int184(value);
    }

    /**
     * @dev Returns the downcasted int176 from int256, reverting on
     * overflow (when the input is less than smallest int176 or
     * greater than largest int176).
     *
     * Counterpart to Solidity's `int176` operator.
     *
     * Requirements:
     *
     * - input must fit into 176 bits
     *
     * _Available since v4.7._
     */
    function toInt176(int256 value) internal pure returns (int176) {
        require(value >= type(int176).min && value <= type(int176).max, "SafeCast: value doesn't fit in 176 bits");
        return int176(value);
    }

    /**
     * @dev Returns the downcasted int168 from int256, reverting on
     * overflow (when the input is less than smallest int168 or
     * greater than largest int168).
     *
     * Counterpart to Solidity's `int168` operator.
     *
     * Requirements:
     *
     * - input must fit into 168 bits
     *
     * _Available since v4.7._
     */
    function toInt168(int256 value) internal pure returns (int168) {
        require(value >= type(int168).min && value <= type(int168).max, "SafeCast: value doesn't fit in 168 bits");
        return int168(value);
    }

    /**
     * @dev Returns the downcasted int160 from int256, reverting on
     * overflow (when the input is less than smallest int160 or
     * greater than largest int160).
     *
     * Counterpart to Solidity's `int160` operator.
     *
     * Requirements:
     *
     * - input must fit into 160 bits
     *
     * _Available since v4.7._
     */
    function toInt160(int256 value) internal pure returns (int160) {
        require(value >= type(int160).min && value <= type(int160).max, "SafeCast: value doesn't fit in 160 bits");
        return int160(value);
    }

    /**
     * @dev Returns the downcasted int152 from int256, reverting on
     * overflow (when the input is less than smallest int152 or
     * greater than largest int152).
     *
     * Counterpart to Solidity's `int152` operator.
     *
     * Requirements:
     *
     * - input must fit into 152 bits
     *
     * _Available since v4.7._
     */
    function toInt152(int256 value) internal pure returns (int152) {
        require(value >= type(int152).min && value <= type(int152).max, "SafeCast: value doesn't fit in 152 bits");
        return int152(value);
    }

    /**
     * @dev Returns the downcasted int144 from int256, reverting on
     * overflow (when the input is less than smallest int144 or
     * greater than largest int144).
     *
     * Counterpart to Solidity's `int144` operator.
     *
     * Requirements:
     *
     * - input must fit into 144 bits
     *
     * _Available since v4.7._
     */
    function toInt144(int256 value) internal pure returns (int144) {
        require(value >= type(int144).min && value <= type(int144).max, "SafeCast: value doesn't fit in 144 bits");
        return int144(value);
    }

    /**
     * @dev Returns the downcasted int136 from int256, reverting on
     * overflow (when the input is less than smallest int136 or
     * greater than largest int136).
     *
     * Counterpart to Solidity's `int136` operator.
     *
     * Requirements:
     *
     * - input must fit into 136 bits
     *
     * _Available since v4.7._
     */
    function toInt136(int256 value) internal pure returns (int136) {
        require(value >= type(int136).min && value <= type(int136).max, "SafeCast: value doesn't fit in 136 bits");
        return int136(value);
    }

    /**
     * @dev Returns the downcasted int128 from int256, reverting on
     * overflow (when the input is less than smallest int128 or
     * greater than largest int128).
     *
     * Counterpart to Solidity's `int128` operator.
     *
     * Requirements:
     *
     * - input must fit into 128 bits
     *
     * _Available since v3.1._
     */
    function toInt128(int256 value) internal pure returns (int128) {
        require(value >= type(int128).min && value <= type(int128).max, "SafeCast: value doesn't fit in 128 bits");
        return int128(value);
    }

    /**
     * @dev Returns the downcasted int120 from int256, reverting on
     * overflow (when the input is less than smallest int120 or
     * greater than largest int120).
     *
     * Counterpart to Solidity's `int120` operator.
     *
     * Requirements:
     *
     * - input must fit into 120 bits
     *
     * _Available since v4.7._
     */
    function toInt120(int256 value) internal pure returns (int120) {
        require(value >= type(int120).min && value <= type(int120).max, "SafeCast: value doesn't fit in 120 bits");
        return int120(value);
    }

    /**
     * @dev Returns the downcasted int112 from int256, reverting on
     * overflow (when the input is less than smallest int112 or
     * greater than largest int112).
     *
     * Counterpart to Solidity's `int112` operator.
     *
     * Requirements:
     *
     * - input must fit into 112 bits
     *
     * _Available since v4.7._
     */
    function toInt112(int256 value) internal pure returns (int112) {
        require(value >= type(int112).min && value <= type(int112).max, "SafeCast: value doesn't fit in 112 bits");
        return int112(value);
    }

    /**
     * @dev Returns the downcasted int104 from int256, reverting on
     * overflow (when the input is less than smallest int104 or
     * greater than largest int104).
     *
     * Counterpart to Solidity's `int104` operator.
     *
     * Requirements:
     *
     * - input must fit into 104 bits
     *
     * _Available since v4.7._
     */
    function toInt104(int256 value) internal pure returns (int104) {
        require(value >= type(int104).min && value <= type(int104).max, "SafeCast: value doesn't fit in 104 bits");
        return int104(value);
    }

    /**
     * @dev Returns the downcasted int96 from int256, reverting on
     * overflow (when the input is less than smallest int96 or
     * greater than largest int96).
     *
     * Counterpart to Solidity's `int96` operator.
     *
     * Requirements:
     *
     * - input must fit into 96 bits
     *
     * _Available since v4.7._
     */
    function toInt96(int256 value) internal pure returns (int96) {
        require(value >= type(int96).min && value <= type(int96).max, "SafeCast: value doesn't fit in 96 bits");
        return int96(value);
    }

    /**
     * @dev Returns the downcasted int88 from int256, reverting on
     * overflow (when the input is less than smallest int88 or
     * greater than largest int88).
     *
     * Counterpart to Solidity's `int88` operator.
     *
     * Requirements:
     *
     * - input must fit into 88 bits
     *
     * _Available since v4.7._
     */
    function toInt88(int256 value) internal pure returns (int88) {
        require(value >= type(int88).min && value <= type(int88).max, "SafeCast: value doesn't fit in 88 bits");
        return int88(value);
    }

    /**
     * @dev Returns the downcasted int80 from int256, reverting on
     * overflow (when the input is less than smallest int80 or
     * greater than largest int80).
     *
     * Counterpart to Solidity's `int80` operator.
     *
     * Requirements:
     *
     * - input must fit into 80 bits
     *
     * _Available since v4.7._
     */
    function toInt80(int256 value) internal pure returns (int80) {
        require(value >= type(int80).min && value <= type(int80).max, "SafeCast: value doesn't fit in 80 bits");
        return int80(value);
    }

    /**
     * @dev Returns the downcasted int72 from int256, reverting on
     * overflow (when the input is less than smallest int72 or
     * greater than largest int72).
     *
     * Counterpart to Solidity's `int72` operator.
     *
     * Requirements:
     *
     * - input must fit into 72 bits
     *
     * _Available since v4.7._
     */
    function toInt72(int256 value) internal pure returns (int72) {
        require(value >= type(int72).min && value <= type(int72).max, "SafeCast: value doesn't fit in 72 bits");
        return int72(value);
    }

    /**
     * @dev Returns the downcasted int64 from int256, reverting on
     * overflow (when the input is less than smallest int64 or
     * greater than largest int64).
     *
     * Counterpart to Solidity's `int64` operator.
     *
     * Requirements:
     *
     * - input must fit into 64 bits
     *
     * _Available since v3.1._
     */
    function toInt64(int256 value) internal pure returns (int64) {
        require(value >= type(int64).min && value <= type(int64).max, "SafeCast: value doesn't fit in 64 bits");
        return int64(value);
    }

    /**
     * @dev Returns the downcasted int56 from int256, reverting on
     * overflow (when the input is less than smallest int56 or
     * greater than largest int56).
     *
     * Counterpart to Solidity's `int56` operator.
     *
     * Requirements:
     *
     * - input must fit into 56 bits
     *
     * _Available since v4.7._
     */
    function toInt56(int256 value) internal pure returns (int56) {
        require(value >= type(int56).min && value <= type(int56).max, "SafeCast: value doesn't fit in 56 bits");
        return int56(value);
    }

    /**
     * @dev Returns the downcasted int48 from int256, reverting on
     * overflow (when the input is less than smallest int48 or
     * greater than largest int48).
     *
     * Counterpart to Solidity's `int48` operator.
     *
     * Requirements:
     *
     * - input must fit into 48 bits
     *
     * _Available since v4.7._
     */
    function toInt48(int256 value) internal pure returns (int48) {
        require(value >= type(int48).min && value <= type(int48).max, "SafeCast: value doesn't fit in 48 bits");
        return int48(value);
    }

    /**
     * @dev Returns the downcasted int40 from int256, reverting on
     * overflow (when the input is less than smallest int40 or
     * greater than largest int40).
     *
     * Counterpart to Solidity's `int40` operator.
     *
     * Requirements:
     *
     * - input must fit into 40 bits
     *
     * _Available since v4.7._
     */
    function toInt40(int256 value) internal pure returns (int40) {
        require(value >= type(int40).min && value <= type(int40).max, "SafeCast: value doesn't fit in 40 bits");
        return int40(value);
    }

    /**
     * @dev Returns the downcasted int32 from int256, reverting on
     * overflow (when the input is less than smallest int32 or
     * greater than largest int32).
     *
     * Counterpart to Solidity's `int32` operator.
     *
     * Requirements:
     *
     * - input must fit into 32 bits
     *
     * _Available since v3.1._
     */
    function toInt32(int256 value) internal pure returns (int32) {
        require(value >= type(int32).min && value <= type(int32).max, "SafeCast: value doesn't fit in 32 bits");
        return int32(value);
    }

    /**
     * @dev Returns the downcasted int24 from int256, reverting on
     * overflow (when the input is less than smallest int24 or
     * greater than largest int24).
     *
     * Counterpart to Solidity's `int24` operator.
     *
     * Requirements:
     *
     * - input must fit into 24 bits
     *
     * _Available since v4.7._
     */
    function toInt24(int256 value) internal pure returns (int24) {
        require(value >= type(int24).min && value <= type(int24).max, "SafeCast: value doesn't fit in 24 bits");
        return int24(value);
    }

    /**
     * @dev Returns the downcasted int16 from int256, reverting on
     * overflow (when the input is less than smallest int16 or
     * greater than largest int16).
     *
     * Counterpart to Solidity's `int16` operator.
     *
     * Requirements:
     *
     * - input must fit into 16 bits
     *
     * _Available since v3.1._
     */
    function toInt16(int256 value) internal pure returns (int16) {
        require(value >= type(int16).min && value <= type(int16).max, "SafeCast: value doesn't fit in 16 bits");
        return int16(value);
    }

    /**
     * @dev Returns the downcasted int8 from int256, reverting on
     * overflow (when the input is less than smallest int8 or
     * greater than largest int8).
     *
     * Counterpart to Solidity's `int8` operator.
     *
     * Requirements:
     *
     * - input must fit into 8 bits
     *
     * _Available since v3.1._
     */
    function toInt8(int256 value) internal pure returns (int8) {
        require(value >= type(int8).min && value <= type(int8).max, "SafeCast: value doesn't fit in 8 bits");
        return int8(value);
    }

    /**
     * @dev Converts an unsigned uint256 into a signed int256.
     *
     * Requirements:
     *
     * - input must be less than or equal to maxInt256.
     *
     * _Available since v3.0._
     */
    function toInt256(uint256 value) internal pure returns (int256) {
        // Note: Unsafe cast below is okay because `type(int256).max` is guaranteed to be positive
        require(value <= uint256(type(int256).max), "SafeCast: value doesn't fit in an int256");
        return int256(value);
    }
}
// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.17;

/**
 * @title Mosaic Alpha Governance contract
 * @author dlabs.hu
 * @dev This contract is for handling governance and configuration changes
 */

import "../Interfaces/IVault.sol";
import "../Interfaces/IAffiliate.sol";
import "../Interfaces/IGoverned.sol";

contract Governance {

mapping(address => uint256) public curator_proportions;                             // Proportions of the curators
address[] public governedContracts;                                                 // The governed addresses

/* ConfManager system mappings and vars */
mapping(string => config_struct) public Configuration;
mapping(string => config_struct) public invoteConfiguration;
mapping(uint256 => string) public ID_to_name;

mapping(address => uint256) public conf_curator_timer;                           // Last action time by curator for locking
mapping(uint256 => uint256) public conf_votes;                                   // ID to see if threshold is passed
mapping(uint256 => uint256) public conf_time_limit;                              // Actions needs to be triggered in time
uint256 public conf_counter = 6;                                                 // Starting from 6+1, 0-6 are reserved for global config

struct config_struct {
  string name;
  bool Running;
  address govaddr;
  address[] managers;
  bool[] boolslot;
  address[] address_slot;
  uint256[] uint256_slot;
  bytes32[] bytes32_slot;
}

mapping(uint256 => bool) public triggered;                                          // If true, it was triggered before and will be blocked
string constant Core = "Main";                                                               // Core string for consistency

/* Action manager system mappings */
mapping(address => uint256) public action_curator_timer;                            // Last action time by curator for locking
mapping(uint256 => uint256) public action_id_to_vote;                               // ID to see if threshold is passed
mapping(uint256 => uint256) public action_time_limit;                               // Actions needs to be triggered in time
mapping(uint256 => address) public action_can_be_triggered_by;                      // Address which can trigger the action after threshold is passed

/* This is used to store calldata and make it takeable from external contracts.
@dev be careful with this, low level calls can be tricky. */
mapping(uint256 => bytes) public action_id_to_calldata;                             // Mapping actions to relevant calldata.

// Action threshold and time limit, so the community can react to changes
uint256 public action_threshold;                                                    // This threshold needs to be passed for action to happen
uint256 public vote_time_threshold;                                                 // You can only vote once per timer - this is for security and gas optimization
uint256 public vote_conf_time_threshold;                                            // Config

event Transfer_Proportion(uint256 beneficiary_proportion);
event Action_Proposed(uint256 id);
event Action_Support(uint256 id);
event Action_Trigger(uint256 id);
event Config_Proposed(string name);
event Config_Supported(string name);

modifier onlyCurators(){
  require(curator_proportions[msg.sender] > 0, "Not a curator");
  _;
}

// The Governance contract needs to be deployed first, before all
// Max proportions are 100, shared among curators
 constructor(
    address[] memory _curators,
    uint256[] memory _curator_proportions,
    address[] memory _managers
) {
    action_threshold = 30;                                        // Threshold -> from this, configs and actions can be triggered
    vote_time_threshold = 600;                                    // Onc conf change per 10 mins, in v2 we can make it longer
    vote_conf_time_threshold = 0;

    require(_curators.length == _curator_proportions.length, "Curators and proportions length mismatch");

    uint totalProp;
    for (uint256 i = 0; i < _curators.length; i++) {
        curator_proportions[_curators[i]] = _curator_proportions[i];
        totalProp += _curator_proportions[i];
    }

    require(totalProp == 100, "Total proportions must be 100");

    ID_to_name[0] = Core;                                         // Core config init
    core_govAddr_conf(address(this));                             // Global governance address
    core_emergency_conf();                                        // Emergency stop value is enforced to be Running==true from start.
    core_managers_conf(_managers);
}

// Core functions, only used during init
function core_govAddr_conf(address _address) private {
    Configuration[Core].name = Core;
    Configuration[Core].govaddr = _address;}

function core_emergency_conf() private {
    Configuration[Core].Running = true;}

function core_managers_conf(address[] memory _addresses) private {
    Configuration[Core].managers = _addresses;
    address[] storage addGovAddr = Configuration[Core].managers; // Constructor memory -> Storage
    addGovAddr.push(address(this));
    Configuration[Core].managers = addGovAddr;
    }

// Only the addresses on the manager list are allowed to execute
function onlyManagers() internal view {
      bool ok;
          address [] memory tempman =  read_core_managers();
          for (uint i=0; i < tempman.length; i++) {
              if (tempman[i] == msg.sender) {ok = true;}
          }
          if (ok == true){} else {revert("0");} //Not manager*/
}

bool public deployed = false;
function setToDeployed() public returns (bool) {
  onlyManagers();
  deployed = true;
  return deployed;
}

function ActivateDeployedMosaic(
    address _userProfile,
    address _affiliate,
    address _fees,
    address _register,
    address _poolFactory,
    address _feeTo,
    address _swapsContract,
    address _oracle,
    address _deposit,
    address _burner,
    address _booster
) public {
    onlyManagers();
    require(deployed == false, "It is done.");

        Configuration[Core].address_slot.push(msg.sender); //0 owner
        Configuration[Core].address_slot.push(_userProfile); //1
        Configuration[Core].address_slot.push(_affiliate); //2
        Configuration[Core].address_slot.push(_fees); //3
        Configuration[Core].address_slot.push(_register); //4
        Configuration[Core].address_slot.push(_poolFactory); //5
        Configuration[Core].address_slot.push(_feeTo); //6 - duplicate? fees and feeToo are same?
        Configuration[Core].address_slot.push(_swapsContract); //7
        Configuration[Core].address_slot.push(_oracle); //8
        Configuration[Core].address_slot.push(_deposit); //9
        Configuration[Core].address_slot.push(_burner); //10
        Configuration[Core].address_slot.push(_booster); //11

        IAffiliate(_affiliate).selfManageMe();
}

/* Transfer proportion */
function transfer_proportion(address _address, uint256 _amount) external returns (uint256) {
    require(curator_proportions[msg.sender] >= _amount, "Not enough proportions");
    require(block.timestamp >= action_curator_timer[msg.sender] + vote_time_threshold, "Not yet, your votes need to conclude");
    action_curator_timer[msg.sender] = block.timestamp;
    curator_proportions[msg.sender] = curator_proportions[msg.sender] - _amount;
    curator_proportions[_address] = curator_proportions[_address] + _amount;
    emit Transfer_Proportion(curator_proportions[_address]);
    return curator_proportions[_address];
  }

/* Configuration manager */

// Add or update config.
function update_config(string memory _name,
  bool _Running,
  address _govaddr,
  address[] memory _managers,
  bool[] memory _boolslot,
  address[] memory _address_slot,
  uint256[] memory _uint256_slot,
  bytes32[] memory _bytes32_slot
  ) internal returns (string memory){
  Configuration[_name].name = _name;
  Configuration[_name].Running = _Running;
  Configuration[_name].govaddr = _govaddr;
  Configuration[_name].managers = _managers;
  Configuration[_name].boolslot = _boolslot;
  Configuration[_name].address_slot = _address_slot;
  Configuration[_name].uint256_slot = _uint256_slot;
  Configuration[_name].bytes32_slot = _bytes32_slot;
  return _name;
}

// Create temp configuration
function votein_config(string memory _name,
  bool _Running,
  address _govaddr,
  address[] memory _managers,
  bool[] memory _boolslot,
  address[] memory _address_slot,
  uint256[] memory _uint256_slot,
  bytes32[] memory _bytes32_slot
) internal returns (string memory){
  invoteConfiguration[_name].name = _name;
  invoteConfiguration[_name].Running = _Running;
  invoteConfiguration[_name].govaddr = _govaddr;
  invoteConfiguration[_name].managers = _managers;
  invoteConfiguration[_name].boolslot = _boolslot;
  invoteConfiguration[_name].address_slot = _address_slot;
  invoteConfiguration[_name].uint256_slot = _uint256_slot;
  invoteConfiguration[_name].bytes32_slot = _bytes32_slot;
  return _name;
}

// Propose config
function propose_config(
  string memory _name,
  bool _Running,
  address _govaddr,
  address[] memory _managers,
  bool[] memory _boolslot,
  address[] memory _address_slot,
  uint256[] memory _uint256_slot,
  bytes32[] memory _bytes32_slot
) external returns (uint256) {
    require(curator_proportions[msg.sender] > 0, "You are not a curator");
    require(block.timestamp >= conf_curator_timer[msg.sender] + vote_conf_time_threshold, "Curator timer not yet expired");
    conf_counter = conf_counter + 1;
    require(conf_time_limit[conf_counter] == 0, "In progress");
    conf_curator_timer[msg.sender] = block.timestamp;
    conf_time_limit[conf_counter] = block.timestamp + vote_time_threshold;
    conf_votes[conf_counter] = curator_proportions[msg.sender];
    ID_to_name[conf_counter] = _name;
    triggered[conf_counter] = false; // It keep rising, so can't be overwritten from true in past value
    votein_config(
        _name,
        _Running,
        _govaddr,
        _managers,
        _boolslot,
        _address_slot,
        _uint256_slot,
        _bytes32_slot
    );
    emit Config_Proposed(_name);
    return conf_counter;
  }

// Use this with caution!
function propose_core_change(address _govaddr, bool _Running, address[] memory _managers, address[] memory _owners) external returns (uint256) {
    require(curator_proportions[msg.sender] > 0, "You are not a curator");
    require(block.timestamp >= conf_curator_timer[msg.sender] + vote_conf_time_threshold, "Curator timer not yet expired");
    require(conf_time_limit[conf_counter] == 0, "In progress");
    conf_curator_timer[msg.sender] = block.timestamp;
    conf_time_limit[conf_counter] = block.timestamp + vote_time_threshold;
    conf_votes[conf_counter] = curator_proportions[msg.sender];
    ID_to_name[conf_counter] = Core;
    triggered[conf_counter] = false; // It keep rising, so can't be overwritten from true in past value

    invoteConfiguration[Core].name = Core;
    invoteConfiguration[Core].govaddr = _govaddr;
    invoteConfiguration[Core].Running = _Running;
    invoteConfiguration[Core].managers = _managers;
    invoteConfiguration[Core].address_slot = _owners;
    return conf_counter;
}

// ID and name are requested together for supporting a config because of awareness.
function support_config_proposal(uint256 _confCount, string memory _name) external returns (string memory) {
  require(curator_proportions[msg.sender] > 0, "You are not a curator");
  require(block.timestamp >= conf_curator_timer[msg.sender] + vote_conf_time_threshold, "Curator timer not yet expired");
  require(conf_time_limit[_confCount] > block.timestamp, "Timed out");
  require(conf_time_limit[_confCount] != 0, "Not started");
  require(keccak256(abi.encodePacked(ID_to_name[_confCount])) == keccak256(abi.encodePacked(_name)), "You are not aware, Neo.");
  conf_curator_timer[msg.sender] = block.timestamp;
  conf_votes[_confCount] = conf_votes[_confCount] + curator_proportions[msg.sender];
  if (conf_votes[_confCount] >= action_threshold && triggered[_confCount] == false) {
    triggered[_confCount] = true;
    string memory name = ID_to_name[_confCount];
    update_config(
    invoteConfiguration[name].name,
    invoteConfiguration[name].Running,
    invoteConfiguration[name].govaddr,
    invoteConfiguration[name].managers,
    invoteConfiguration[name].boolslot,
    invoteConfiguration[name].address_slot,
    invoteConfiguration[name].uint256_slot,
    invoteConfiguration[name].bytes32_slot
    );

    delete invoteConfiguration[name].name;
    delete invoteConfiguration[name].Running;
    delete invoteConfiguration[name].govaddr;
    delete invoteConfiguration[name].managers;
    delete invoteConfiguration[name].boolslot;
    delete invoteConfiguration[name].address_slot;
    delete invoteConfiguration[name].uint256_slot;
    delete invoteConfiguration[name].bytes32_slot;

    conf_votes[_confCount] = 0;
  }
  emit Config_Supported(_name);
  return Configuration[_name].name = _name;
}

/* Read configurations */

function read_core_Running() public view returns (bool) {return Configuration[Core].Running;}
function read_core_govAddr() public view returns (address) {return Configuration[Core].govaddr;}
function read_core_managers() public view returns (address[] memory) {return Configuration[Core].managers;}
function read_core_owners() public view returns (address[] memory) {return Configuration[Core].address_slot;}

function read_config_Main_addressN(uint256 _n) public view returns (address) {
  return Configuration["Main"].address_slot[_n];
}

// Can't read full because of stack too deep limit
function read_config_core(string memory _name) public view returns (
  string memory,
  bool,
  address,
  address[] memory){
  return (
  Configuration[_name].name,
  Configuration[_name].Running,
  Configuration[_name].govaddr,
  Configuration[_name].managers);}
function read_config_name(string memory _name) public view returns (string memory) {return Configuration[_name].name;}
function read_config_emergencyStatus(string memory _name) public view returns (bool) {return Configuration[_name].Running;}
function read_config_governAddress(string memory _name) public view returns (address) {return Configuration[_name].govaddr;}
function read_config_Managers(string memory _name) public view returns (address[] memory) {return Configuration[_name].managers;}

function read_config_bool_slot(string memory _name) public view returns (bool[] memory) {return Configuration[_name].boolslot;}
function read_config_address_slot(string memory _name) public view returns (address[] memory) {return Configuration[_name].address_slot;}
function read_config_uint256_slot(string memory _name) public view returns (uint256[] memory) {return Configuration[_name].uint256_slot;}
function read_config_bytes32_slot(string memory _name) public view returns (bytes32[] memory) {return Configuration[_name].bytes32_slot;}

function read_config_Managers_batched(string memory _name, uint256[] memory _ids) public view returns (address[] memory) {
    address[] memory result = new address[](_ids.length);
    for (uint256 i = 0; i < _ids.length; i++) {
        result[i] = Configuration[_name].managers[_ids[i]];
    }
    return result;
}

function read_config_bool_slot_batched(string memory _name, uint256[] memory _ids) public view returns (bool[] memory) {
    bool[] memory result = new bool[](_ids.length);
    for (uint256 i = 0; i < _ids.length; i++) {
        result[i] = Configuration[_name].boolslot[_ids[i]];
    }
    return result;
}

function read_config_address_slot_batched(string memory _name, uint256[] memory _ids) public view returns (address[] memory) {
    address[] memory result = new address[](_ids.length);
    for (uint256 i = 0; i < _ids.length; i++) {
        result[i] = Configuration[_name].address_slot[_ids[i]];
    }
    return result;
}

function read_config_uint256_slot_batched(string memory _name, uint256[] memory _ids) public view returns (uint256[] memory) {
    uint256[] memory result = new uint256[](_ids.length);
    for (uint256 i = 0; i < _ids.length; i++) {
        result[i] = Configuration[_name].uint256_slot[_ids[i]];
    }
    return result;
}

function read_config_bytes32_slot_batched(string memory _name, uint256[] memory _ids) public view returns (bytes32[] memory) {
    bytes32[] memory result = new bytes32[](_ids.length);
    for (uint256 i = 0; i < _ids.length; i++) {
        result[i] = Configuration[_name].bytes32_slot[_ids[i]];
    }
    return result;
}


// Read invote configuration
// Can't read full because of stack too deep limit
function read_invoteConfig_core(string calldata _name) public view returns (
  string memory,
  bool,
  address,
  address[] memory){
  return (
  invoteConfiguration[_name].name,
  invoteConfiguration[_name].Running,
  invoteConfiguration[_name].govaddr,
  invoteConfiguration[_name].managers);}
function read_invoteConfig_name(string memory _name) public view returns (string memory) {return invoteConfiguration[_name].name;}
function read_invoteConfig_emergencyStatus(string memory _name) public view returns (bool) {return invoteConfiguration[_name].Running;}
function read_invoteConfig_governAddress(string memory _name) public view returns (address) {return invoteConfiguration[_name].govaddr;}
function read_invoteConfig_Managers(string memory _name) public view returns (address[] memory) {return invoteConfiguration[_name].managers;}
function read_invoteConfig_boolslot(string memory _name) public view returns (bool[] memory) {return invoteConfiguration[_name].boolslot;}
function read_invoteConfig_address_slot(string memory _name) public view returns (address[] memory) {return invoteConfiguration[_name].address_slot;}
function read_invoteConfig_uint256_slot(string memory _name) public view returns (uint256[] memory) {return invoteConfiguration[_name].uint256_slot;}
function read_invoteConfig_bytes32_slot(string memory _name) public view returns (bytes32[] memory) {return invoteConfiguration[_name].bytes32_slot;}


/* Action manager system */

// Propose an action, regardless of which contract/address it resides in
function propose_action(uint256 _id, address _trigger_address, bytes memory _calldata) external returns (uint256) {
    require(curator_proportions[msg.sender] > 0, "You are not a curator");
    require(action_id_to_calldata[_id].length == 0, "Calldata already set");
    require(action_time_limit[_id] == 0, "Create a new one");
    require(block.timestamp >= action_curator_timer[msg.sender] + vote_time_threshold, "Not yet");
    action_curator_timer[msg.sender] = block.timestamp;
    action_time_limit[_id] = block.timestamp + vote_time_threshold;
    action_can_be_triggered_by[_id] = _trigger_address;
    action_id_to_vote[_id] = curator_proportions[msg.sender];
    action_id_to_calldata[_id] = _calldata;
    triggered[_id] = false;
    emit Action_Proposed(_id);
    return _id;
  }

// Support an already submitted action
function support_actions(uint256 _id) external returns (uint256) {
    require(curator_proportions[msg.sender] > 0, "You are not a curator");
    require(block.timestamp >= action_curator_timer[msg.sender] + vote_time_threshold, "Not yet");
    require(action_time_limit[_id] > block.timestamp, "Action timed out");
    action_curator_timer[msg.sender] = block.timestamp;
    action_id_to_vote[_id] = action_id_to_vote[_id] + curator_proportions[msg.sender];
    emit Action_Support(_id);
    return _id;
  }

// Trigger action by allowed smart contract address
// Only returns calldata, does not guarantee execution success! Triggerer is responsible, choose wisely.
function trigger_action(uint256 _id) external returns (bytes memory) {
    require(action_id_to_vote[_id] >= action_threshold, "Threshold not passed");
    require(action_time_limit[_id] > block.timestamp, "Action timed out");
    require(action_can_be_triggered_by[_id] == msg.sender, "You are not the triggerer");
    require(triggered[_id] == false, "Already triggered");
    triggered[_id] = true;
    action_id_to_vote[_id] = 0;
    emit Action_Trigger(_id);
    return action_id_to_calldata[_id];
}

/* Pure function for generating signatures */
function generator(string memory _func) public pure returns (bytes memory) {
        return abi.encodeWithSignature(_func);
    }

/* Execution and mass config updates */

/* Update contracts address list */
function update_All(address [] memory _addresses) external onlyCurators returns (address [] memory) {
  governedContracts = _addresses;
  return governedContracts;
}

/* Update all contracts from address list */
function selfManageMe_All() external onlyCurators {
  for (uint256 i = 0; i < governedContracts.length; i++) {
    _execute_Manage(governedContracts[i]);
  }
}

/* Execute external contract call: selfManageMe() */
function execute_Manage(address _contractA) external onlyCurators {
    _execute_Manage(_contractA);
}

function _execute_Manage(address _contractA) internal {
    require(_contractA != address(this),"You can't call Governance on itself");
    IGoverned(_contractA).selfManageMe();
}

/* Execute external contract call: selfManageMe() */
function execute_batch_Manage(address[] calldata _contracts) external onlyCurators {
  for (uint i; i < _contracts.length; i++) {
    _execute_Manage(_contracts[i]);
  }
}

/* Execute external contract calls with any string */
function execute_ManageBytes(address _contractA, string calldata _call, bytes calldata _data) external onlyCurators {
  _execute_ManageBytes(_contractA, _call, _data);
}

function execute_batch_ManageBytes(address[] calldata _contracts, string[] calldata _calls, bytes[] calldata _datas) external onlyCurators {
  require(_contracts.length == _calls.length, "Governance: _conracts and _calls length does not match");
  require(_calls.length == _datas.length, "Governance: _calls and _datas length does not match");
  for (uint i; i < _contracts.length; i++) {
    _execute_ManageBytes(_contracts[i], _calls[i], _datas[i]);
  }
}

function _execute_ManageBytes(address _contractA, string calldata _call, bytes calldata _data) internal {
  require(_contractA != address(this),"You can't call Governance on itself");
  require(bytes(_call).length == 0 || bytes(_call).length >=3, "provide a valid function specification");

  for (uint256 i = 0; i < bytes(_call).length; i++) {
    require(bytes(_call)[i] != 0x20, "No spaces in fun please");
  }

  bytes4 signature;
  if (bytes(_call).length != 0) {
      signature = (bytes4(keccak256(bytes(_call))));
  } else {
      signature = "";
  }

  (bool success, bytes memory retData) = _contractA.call(abi.encodePacked(signature, _data));
  _evaluateCallReturn(success, retData);
}

/* Execute external contract calls with address array */
function execute_ManageList(address _contractA, string calldata _funcName, address[] calldata address_array) external onlyCurators {
  require(_contractA != address(this),"You can't call Governance on itself");
  (bool success, bytes memory retData) = _contractA.call(abi.encodeWithSignature(_funcName, address_array));
  _evaluateCallReturn(success, retData);
}

/* Update Vault values */
function execute_Vault_update(address _vaultAddress) external onlyCurators {
  IVault(_vaultAddress).selfManageMe();
}

function _evaluateCallReturn(bool success, bytes memory retData) internal pure {
    if (!success) {
      if (retData.length >= 68) {
          bytes memory reason = new bytes(retData.length - 68);
          for (uint i = 0; i < reason.length; i++) {
              reason[i] = retData[i + 68];
          }
          revert(string(reason));
      } else revert("Governance: FAILX");
  }
}
}
// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.17;

/**
 * @title Mosaic Alpha Governed base contract
 * @author dlabs.hu
 * @dev This contract is base for contracts governed by Governance
 */

import "./Governance.sol";
import "../Interfaces/IGovernance.sol";
import "../Interfaces/IGoverned.sol";

abstract contract Governed is IGoverned {
    GovernanceState internal governanceState;

    constructor() {
      governanceState.running = true;
      governanceState.governanceAddress = address(this);
    }

    function getGovernanceState() public view returns (GovernanceState memory govState) {
      return governanceState;
    }

    // Modifier responsible for checking if emergency stop was triggered, default is Running == true
    modifier Live {
        LiveFun();
        _;
    }

    modifier notLive {
        notLiveFun();
        _;
    }


    error Governed__EmergencyStopped();
    function LiveFun() internal virtual view {
        if (!governanceState.running) revert Governed__EmergencyStopped();
    }

    error Governed__NotStopped();
    function notLiveFun() internal virtual view {
        if (governanceState.running) revert Governed__NotStopped();
    }

    modifier onlyManagers() {
        onlyManagersFun();
        _;
    }

    error Governed__NotManager(address caller);
    function onlyManagersFun() internal virtual view {
        if (!isManagerFun(msg.sender)) revert Governed__NotManager(msg.sender);
    }


    function isManagerFun(address a) internal virtual view returns (bool) {
        if (a == governanceState.governanceAddress) {
            return true;
        }
        for (uint i=0; i < governanceState.managers.length; i++) {
            if (governanceState.managers[i] == a) {
                return true;
            }
        }
        return false;
    }

    function selfManageMe() external virtual {
        onlyManagersFun();
        LiveFun();
        _selfManageMeBefore();
        address governAddress = governanceState.governanceAddress;
        bool nextRunning = IGovernance(governAddress).read_core_Running();
        if (governanceState.running != nextRunning) _onBeforeEmergencyChange(nextRunning);
        governanceState.running = nextRunning;
        governanceState.managers = IGovernance(governAddress).read_core_managers();               // List of managers
        governanceState.governanceAddress = IGovernance(governAddress).read_core_govAddr();
        _selfManageMeAfter();
    }

    function _selfManageMeBefore() internal virtual;
    function _selfManageMeAfter() internal virtual;
    function _onBeforeEmergencyChange(bool nextRunning) internal virtual;
}
// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IERC20Burnable is IERC20 {
    function burn(uint256 _amount) external;
}// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.17;

import "../Interfaces/IUserProfile.sol";
import "../Interfaces/IGoverned.sol";

interface IAffiliate is IGoverned {
    struct AffiliateLevel {
        uint8 rank;
        uint8 commissionLevels; // eligibility for how many levels affiliate comission
        uint16 referralBuyFeeDiscount; // buy fee disccount for the referrals refistering for the user - 10000 = 100%
        uint16 referralCountThreshold; // minimum amount of direct referrals needed for level
        uint16 stakingBonus;
        uint16 conversionRatio;
        uint32 claimLimit; // max comission per month claimable - in usd value, not xe18!
        uint256 kdxStakeThreshold; // minimum amount of kdx stake needed
        uint256 purchaseThreshold; // minimum amount of self basket purchase needed
        uint256 referralPurchaseThreshold; // minimum amount of referral basket purchase needed
        uint256 traderPurchaseThreshold; // minimum amount of user basket purchase (for traders) needed

        string rankName;
    }

    struct AffiliateUserData {
        uint32 affiliateRevision;
        uint32 activeReferralCount;
        uint256 userPurchase;
        uint256 referralPurchase;
        uint256 traderPurchase;
        uint256 kdxStake;
    }

    struct AffiliateConfig {
        uint16 level1RewardShare; // 0..10000. 6000 -> 60% of affiliate rewards go to level 1, 40% to level2
        uint240 activeReferralPurchaseThreshold; // the min amount of (usdt) purchase in wei to consider a referral active
    }

    function getCommissionLevelsForRanks(uint8 rank, uint8 rank2) external view returns (uint8 commissionLevels, uint8 commissionLevels2);

    function getLevelsAndConversionAndClaimLimitForRank(uint8 rank) external view returns (uint8 commissionLevels, uint16 conversionRatio, uint32 claimLimit);

    function getConfig() external view returns (AffiliateConfig memory config);

    // get the number of affiliate levels
    function getLevelCount() external view returns (uint256 count);

    function getLevelDetails(uint256 _idx) external view returns (AffiliateLevel memory level);

    function getAllLevelDetails() external view returns (AffiliateLevel[] memory levels);

    function getAffiliateUserData(address user) external view returns (AffiliateUserData memory data);

    function getUserPurchaseAmount(address user) external view returns (uint256 amount);

    function getReferralPurchaseAmount(address user) external view returns (uint256 amount);

    function userStakeChanged(address user, address referredBy, uint256 kdxAmount) external;

    function registerUserPurchase(address user, address referredBy, address trader, uint256 usdAmount) external;
    function registerUserPurchaseAsTokens(address user, address referredBy, address trader, address[] memory tokens, uint256[] memory tokenAmounts) external;

    event AffiliateConfigUpdated(AffiliateConfig _newConfig, AffiliateConfig config);

}// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.7.0 || ^0.8.0;


// https://eips.ethereum.org/EIPS/eip-3156
interface IERC3156FlashBorrower {

    /**
     * @dev Receive a flash loan.
     * @param initiator The initiator of the loan.
     * @param token The loan currency.
     * @param amount The amount of tokens lent.
     * @param fee The additional amount of tokens to repay.
     * @param data Arbitrary data structure, intended to contain user-defined parameters.
     * @return The keccak256 hash of "ERC3156FlashBorrower.onFlashLoan"
     */
    function onFlashLoan(
        address initiator,
        address token,
        uint256 amount,
        uint256 fee,
        bytes calldata data
    ) external returns (bytes32);
}// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.7.0 || ^0.8.0;
import "./IERC3156FlashBorrower.sol";


// https://eips.ethereum.org/EIPS/eip-3156
interface IERC3156FlashLender {

    /**
     * @dev The amount of currency available to be lent.
     * @param token The loan currency.
     * @return The amount of `token` that can be borrowed.
     */
    function maxFlashLoan(
        address token
    ) external view returns (uint256);

    /**
     * @dev The fee to be charged for a given loan.
     * @param token The loan currency.
     * @param amount The amount of tokens lent.
     * @return The amount of `token` to be charged for the loan, on top of the returned principal.
     */
    function flashFee(
        address token,
        uint256 amount
    ) external view returns (uint256);

    /**
     * @dev Initiate a flash loan.
     * @param receiver The receiver of the tokens in the loan, and the receiver of the callback.
     * @param token The loan currency.
     * @param amount The amount of tokens lent.
     * @param data Arbitrary data structure, intended to contain user-defined parameters.
     */
    function flashLoan(
        IERC3156FlashBorrower receiver,
        address token,
        uint256 amount,
        bytes calldata data
    ) external returns (bool);
}// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.17;


interface IFeeBurner {
    function feeToken() external view returns (address);

    function burn() external;

    function setFeeToken(address _token) external;
    function setFeeTokenBurnable(bool _burnable) external;
    function setFeeTo(address _receiver) external;
}
// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.17;

import "../Interfaces/IGoverned.sol";

interface IFees is IGoverned {
    struct MosaicFeeRanges {
        uint16 buyFeeMin;          // 10000 = 100%
        uint16 buyFeeMax;
        uint16 trailingFeeMin;
        uint16 trailingFeeMax;
        uint16 performanceFeeMin;
        uint16 performanceFeeMax;
    }

    struct MosaicFeeDistribution {
        uint16 userBuyFeeDiscountMax;
        uint16 userTrailingFeeDiscountMax;
        uint16 userPerformanceFeeDiscountMax;
        uint16 traderBuyFeeShareMin;          // 10000 = 100%
        uint16 traderBuyFeeShareMax;
        uint16 traderTrailingFeeShareMin;
        uint16 traderTrailingFeeShareMax;
        uint16 traderPerformanceFeeShareMin;
        uint16 traderPerformanceFeeShareMax;
        uint16 affiliateBuyFeeShare;
        uint16 affiliateTrailingFeeShare;
        uint16 affiliatePerformanceFeeShare;
        uint16 affiliateTraderFeeShare;
        uint16 affiliateLevel1RewardShare; // 0..10000. 6000 -> 60% of affiliate rewards go to level 1, 40% to level2
    }

    struct MosaicPlatformFeeShares {
        uint8 executorShare;
        uint8 traderExecutorShare;
        uint8 userExecutorShare;
    }

    struct MosaicUserFeeLevels {
        //slot1
        bool parentsCached;
        uint8 levels;
        uint16 conversionRatio;
        uint32 traderRevenueShareLevel; // 10 ** 9 = 100%
        uint32 userFeeDiscountLevel; // 10 ** 9 = 100%
        address parent;
        // slot2
        address parent2;
        uint32 lastTime;
        uint32 level1xTime;
        uint32 level2xTime;
        // slot3
        uint64 userFeeDiscountLevelxTime;
        uint32 claimLimit;
        uint64 claimLimitxTime;

        //uint48 conversionRatioxTime;
    }

    struct BuyFeeDistribution {
        uint userRebateAmount;
        uint traderAmount;
        uint affiliateAmount;
        // remaining is system fee
    }

    struct TraderFeeDistribution {
        uint traderAmount;
        uint affiliateAmount;
        // remaining is system fee
    }

    struct MosaicPoolFees {
        uint16 buyFee;
        uint16 trailingFee;
        uint16 performanceFee;
    }

    struct PoolFeeStatus {
        uint256 claimableUserFeePerLp;
        uint256 claimableAffiliateL1FeePerLp;
        uint256 claimableAffiliateL2FeePerLp;
        uint128 claimableTotalFixedTraderFee;
        uint128 claimableTotalVariableTraderFee;
        uint128 feesContractSelfBalance;
    }

    struct UserPoolFeeStatus {
        uint32 lastClaimTime;
        uint32 lastLevel1xTime;
        uint32 lastLevel2xTime;
        //uint48 lastConversionRatioxTime;
        uint64 lastUserFeeDiscountLevelxTime;
        uint128 userDirectlyClaimableFee;
       // uint128 userAffiliateClaimableFee;
        uint128 userClaimableFee;
        uint128 userClaimableL1Fee;
        uint128 userClaimableL2Fee;
        uint128 traderClaimableFee;
        // uint128 balance;
        uint128 l1Balance;
        uint128 l2Balance;
        uint256 lastClaimableUserFeePerLp;
        uint256 lastClaimableAffiliateL1FeePerLp;
        uint256 lastClaimableAffiliateL2FeePerLp;
    }

    struct OnBeforeTransferPayload {
        uint128 feesContractBalanceBefore;
        uint128 trailingLpToMint;
        uint128 performanceLpToMint;
    }

    /** HOOKS **/
    /** UserProfile **/
    function userRankChanged(address _user, uint8 _level) external;

    /** Staking **/
    function userStakeChanged(address _user, uint256 _amount) external;

    /** Pool **/
    function allocateBuyFee(address _pool, address _buyer, address _trader, uint _buyFeeAmount) external;
    function allocateTrailingFee(address _pool, address _trader, uint _feeAmount, uint _totalSupplyBefore, address _executor) external;
    function allocatePerformanceFee(address _pool, address _trader, uint _feeAmount, uint _totalSupplyBefore, address _executor) external;
    function onBeforeTransfer(address _pool, address _from, address _to, uint _fromBalanceBefore, uint _toBalanceBefore, uint256 _amount, uint256 _totalSupplyBefore, address _trader, OnBeforeTransferPayload memory payload) external;
    function getFeeRanges() external view returns (MosaicFeeRanges memory fees);
    function getFeeDistribution() external view returns (MosaicFeeDistribution memory fees);
    function getUserFeeLevels(address user) external view returns (MosaicUserFeeLevels memory userFeeLevels);
    function isValidFeeRanges(MosaicFeeRanges calldata ranges) external view returns (bool valid);
    function isValidFeeDistribution(MosaicFeeDistribution calldata distribution) external view returns (bool valid);
    function isValidPoolFees(MosaicPoolFees calldata poolFees) external view returns (bool valid);
    function isValidBuyFee(uint16 fee) external view returns (bool valid);
    function isValidTrailingFee(uint16 fee) external view returns (bool valid);
    function isValidPerformanceFee(uint16 fee) external view returns (bool valid);

    function calculateBuyFeeDistribution(address user, address trader, uint feeAmount, uint16 buyFeeDiscount) external view returns (BuyFeeDistribution memory distribution);
    function calculateTraderFeeDistribution(uint amount) external view returns (TraderFeeDistribution memory distribution);
    function calculateTrailingFeeTraderDistribution(address trader, uint feeAmount) external view returns (uint amount);
    /** GETTERS **/
    // get the fee reduction percentage the user has achieved. 100% = 10 ** 9
    function getUserFeeDiscountLevel(address user) external view returns (uint32 level);

    // get the fee reduction percentage the user has achieved. 100% = 10 ** 9
    function getTraderRevenueShareLevel(address user) external view returns (uint32 level);

    event FeeRangesUpdated(MosaicFeeRanges newRanges, MosaicFeeRanges oldRanges);
    event FeeDistributionUpdated(MosaicFeeDistribution newRanges, MosaicFeeDistribution oldRanges);
    event PlatformFeeSharesUpdated(MosaicPlatformFeeShares newShares, MosaicPlatformFeeShares oldShares);
    event UserFeeLevelsChanged(address indexed user, MosaicUserFeeLevels newLevels);
    event PerformanceFeeAllocated(address pool, uint256 performanceExp);
    event TrailingFeeAllocated(address pool, uint256 trailingExp);
}// SPDX-License-Identifier: MIT LICENSE
pragma solidity ^0.8.17;

interface IGovernance {
    function propose_action(uint256 _id, address _trigger_address, bytes memory _calldata) external returns (uint256) ;
    function support_actions(uint256 _id) external returns (uint256) ;
    function trigger_action(uint256 _id) external returns (bytes memory) ;
    function transfer_proportion(address _address, uint256 _amount) external returns (uint256) ;

    function read_core_Running() external view returns (bool);
    function read_core_govAddr() external view returns (address);
    function read_core_managers() external view returns (address[] memory);
    function read_core_owners() external view returns (address[] memory);

    function read_config_core(string memory _name) external view returns (string memory);
    function read_config_emergencyStatus(string memory _name) external view returns (bool);
    function read_config_governAddress(string memory _name) external view returns (address);
    function read_config_Managers(string memory _name) external view returns (address [] memory);

    function read_config_bool_slot(string memory _name) external view returns (bool[] memory);
    function read_config_address_slot(string memory _name) external view returns (address[] memory);
    function read_config_uint256_slot(string memory _name) external view returns (uint256[] memory);
    function read_config_bytes32_slot(string memory _name) external view returns (bytes32[] memory);

    function read_invoteConfig_core(string memory _name) external view returns (string memory);
    function read_invoteConfig_name(string memory _name) external view returns (string memory);
    function read_invoteConfig_emergencyStatus(string memory _name) external view returns (bool);
    function read_invoteConfig_governAddress(string memory _name) external view returns (address);
    function read_invoteConfig_Managers(string memory _name) external view returns (address[] memory);
    function read_invoteConfig_boolslot(string memory _name) external view returns (bool[] memory);
    function read_invoteConfig_address_slot(string memory _name) external view returns (address[] memory);
    function read_invoteConfig_uint256_slot(string memory _name) external view returns (uint256[] memory);
    function read_invoteConfig_bytes32_slot(string memory _name) external view returns (bytes32[] memory);

    function propose_config(string memory _name, bool _bool_val, address _address_val, address[] memory _address_list, uint256 _uint256_val, bytes32 _bytes32_val) external returns (uint256);
    function support_config_proposal(uint256 _confCount, string memory _name) external returns (string memory);
    function generator() external pure returns (bytes memory);
}
// SPDX-License-Identifier: MIT LICENSE
pragma solidity ^0.8.17;

interface IGoverned {
    struct GovernanceState {
      bool running;
      address governanceAddress;
      address[] managers;
    }

    function selfManageMe() external;
}
// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.4.24 <0.9;

import "../Interfaces/IVault.sol";

interface IMosaicOracle {
    function getPrice(address _tokenIn, uint _amountIn, address _tokenOut) external view returns (uint amountOut);
    function getBatchPrice(address[] calldata _tokens, uint[] calldata _tokenBalances, address _returnedToken) external view returns(uint balance);
    function getBidPrice(address _tokenIn, uint _amountIn, address _tokenOut) external view returns (uint amountOut);
    function getPoolPrice(address[] calldata _tokens, uint[] calldata _tokenBalances, address _returnedToken) external view returns(uint balance);
    function getUsdPrice(address _tokenIn, uint _amountIn) external view returns (uint amountOut);
    function getUsdBatchPrice(address[] calldata _tokens, uint[] calldata _tokenBalances) external view returns(uint balance);
    function getUsdPoolPrice(address[] calldata _tokens, uint[] calldata _tokenBalances) external view returns(uint balance);
    function getUsdPoolPricePerLp(address _poolAddress, IVault.TotalSupplyBase calldata _supplyBase) external view returns(uint pricePerLp);

    function consultPrice(address _tokenIn, uint _amountIn, address _tokenOut) external returns (uint amountOut);
    function consultBatchPrice(address[] calldata _tokens, uint[] calldata _tokenBalances, address _returnedToken) external returns(uint balance);
    function consultBidPrice(address _tokenIn, uint _amountIn, address _tokenOut) external returns (uint amountOut);
    function consultPoolPrice(address[] calldata _tokens, uint[] calldata _tokenBalances, address _returnedToken) external returns(uint balance);
    function consultUsdPrice(address _tokenIn, uint _amountIn) external returns (uint amountOut);
    function consultUsdBatchPrice(address[] calldata _tokens, uint[] calldata _tokenBalances) external returns(uint balance);
    function consultUsdPoolPrice(address[] calldata _tokens, uint[] calldata _tokenBalances) external returns(uint balance);
    function consultUsdPoolPricePerLp(address _poolAddress, IVault.TotalSupplyBase calldata _supplyBase) external returns(uint pricePerLp);

}// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.17;

import "./IFees.sol";
import "./IVault.sol";

interface IPool {
    // Versioning
    function VERSION() external view returns (uint256 version);

    // Ownable
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    function owner() external view returns (address);
    function creator() external view returns (address);

    // Only Vault address should be allowed to call
    // hook for notifying the pool about the initial library being added
    function initialLiquidityProvided(address[] calldata _tokens, uint[] calldata _liquidity) external returns (uint lpTokens, uint dust);

    // function to set managers
    function setManagers(address[] calldata _managers) external;

    // ERC20 stuff
    // Pool name
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
    function totalSupply() external view returns (uint256);
    function getTrailingFeeAmount(IVault.TotalSupplyBase memory ts) external view returns (uint256);
    function updatePerfFeePricePerLp(IVault.TotalSupplyBase calldata ts, uint256 pricePerLp) external returns (uint128);
    function balanceOf(address _owner) external view returns (uint256 balance);
    function transfer(address _to, uint256 _value) external returns (bool success);
    function safeTransfer(address _to, uint256 _value) external returns (bool success);
    function transferFrom(address _from, address _to, uint256 _value) external returns (bool success);
    function safeTransferFrom(address _from, address _to, uint256 _value) external returns (bool success);
    function approve(address _spender, uint256 _value) external returns (bool success);
    function allowance(address _owner, address _spender) external view returns (uint256 remaining);

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

    event Minted(address indexed sender, uint liquidity, uint feeLiquidity);
    event Burned(address indexed sender, uint liquidity);

    event WeightsChanged(address[] affectedTokens, uint32[] weights, uint32[] newWeights, uint weightChangeStart, uint weightChangeEnd);

    event LockingChanged(bool locked);

    // Callback from vault to raise ERC20 event
    function emitTransfer(address _from, address _to, uint256 _value) external;

    // Custom stuff
    // Returns pool type:
    // 0: REBALANCING: (30% ETH, 30% BTC, 40% MKR). Weight changes gradually in time.
    // 1: NON_REBALANCING: (100 ETH, 5 BTC, 200 MKR). Weight changes gradually in time.
    // 2: DAYTRADE: Non rebalancing pool. Weight changes immediately.
    function poolType() external view returns (uint8 poolType);

    function vaultAddress() external view returns (address vaultAddress);

    function isUnlocked() external view returns (bool isUnlocked);

    // Pool Id registered in the Vault
    function poolId() external view returns (uint32 poolId);

    // Fees associated with the pool
    function getPoolFees() external view returns (IFees.MosaicPoolFees memory poolFees);

    // Get pool token list
    function getTokens() external view returns (address[] memory _tokens);

    // Add new token to the pool. Only pool admin can call
    function addToken(address _token) external returns (address[] memory _tokenList);

    // Remove token from the pool. Anyone can call. Reverts if token weight is greater than 0
    function removeToken(uint _index) external returns (address[] memory _tokenList);

    // Change buy fee. Only poo16 newBuyFee) external;

    // Start a Dutch auction. Only pool admin can call
    function dutchAuction(address tokenToSell, uint amountToSell, address tokenToBuy, uint32 duration, uint32 expiration, uint endingPrice) external returns (uint auctionId);

    // Mint function. Called by the Vault.
    function _mint(uint LPTokens, IVault.TotalSupplyBase calldata ts) external returns (uint[] memory requestedAmounts, uint FeeLPTokens, uint expansion);

    // Burn function. Called by the Vault.
    function _burn(uint LPTokens, IVault.TotalSupplyBase calldata ts) external returns (uint[] memory amountsToBeReturned, uint expansion);

    // Calculate the amount of each tokens to be sent in order to get LPTokensToMint amount of LP tokens
    function calcMintAmounts(uint LPTokensToMint) external view returns (uint[] memory amountsToSend, uint FeeLPTokens);

    // Calculates the number of tokens to be received upon burning LP tokens
    function calcBurnAmounts(uint LPTokensToBurn) external view returns (uint[] memory amountsToGet);

    // get amount out
    function getAmountOut(address tokenA, address tokenB, uint256 amountIn, uint16 swapFee) external view returns (uint256 amountOut);

    // get amount in
    function getAmountIn(address tokenA, address tokenB, uint256 amountOut, uint16 swapFee) external view returns (uint256 amountIn);

    // Calculates the maximum number of tokens that can be withdrawn from the pool by sending a specified amountIn, taking into account the current balances and weights.
    function queryExactTokensForTokens(address tokenIn, address tokenOut, uint balanceIn, uint balanceOut, uint amountIn, uint16 swapFee) external view returns (uint _amountOut, uint _fees);

    // Calculates the minimum number of tokens required to be sent to the pool to withdraw a specified amountOut, based on the current balances and weights.
    function queryTokensForExactTokens(address tokenIn, address tokenOut,  uint balanceIn, uint balanceOut, uint amountOut, uint16 swapFee) external view returns (uint _amountIn, uint _fees);

    // Returns the current weights
    function getWeights() external view returns (uint32[] memory _weights);

    // Gradually changes the weights. Only pool admin can call
    function updateWeights(uint32 duration, uint32[] memory _newWeights) external;

    // Update buy fee. Only pool admin can call
    function updateBuyFee(uint16 newFee) external;

    // Returns reserves of each token stored in the Vault
    function getReserves() external view returns (uint256[] memory reserves);
}
// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.17;


// trader and pool register + whitelisted user register
interface IRegister {
    function isApprovedPool(uint32 _poolId) external view returns (bool approved);
    function isApprovedPool(address _poolAddr) external view returns (bool approved);
    function isApprovedTrader(address _user) external view returns (bool approved);

    function approvePools(address[] memory _poolIds) external;
    function approvePoolsById(uint32[] memory _poolIds) external;
    function approveTraders(address[] memory _traders) external;

    function revokePools(address[] memory _poolAddrs) external;
    function revokePoolsById(uint32[] memory _poolIds) external;
    function revokeTraders(address[] memory _traders) external;

    function removeWhitelist(address _address) external;
    function removeBlacklist(address _address) external;
    function addWhitelist(address _address) external;
    function addBlacklist(address _address) external;
    function addWhitelistBulk(address[] calldata _address) external;

    function isWhitelisted(address _address) external view returns(bool);
    function isBlacklisted(address _address) external view returns(bool);

    event PoolApproved(uint32 indexed poolId, address indexed poolAddr);
    event PoolRevoked(uint32 indexed poolId, address indexed poolAddr);

    event TraderApproved(address indexed trader);
    event TraderRevoked(address indexed trader);

    event WhitelistAdded(address _address);
    event WhitelistRemoved(address _address);
    event BlacklistAdded(address _address);
    event BlacklistRemoved(address _address);
}
// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.17;

interface ISwaps {

    // Get price from Pancakeswap
    function getPrice(address tokenToSell, uint amountToSell, address tokenToBuy) external view returns (uint);

    // Returns the USDT amount to spend for a fix amount of LP tokens. Default routing: Token - USDT
    function quickQuoteMint(address _poolAddr, address usdAddr, uint LPTokensRequested) external view returns (uint usdtToSpend);

    function quickQuoteBurn(address _poolAddr, address usdAddr, uint LPTokensToBurn) external view returns (uint usdtToReceive);

    // Returns the USDT amount to spend for a fix amount of LP tokens. Requires routing.
    // If the pool has USDT token, simply provide an empty address[] for its routing
    // Example: KDX-USDT pool
    // _routing = [ [USDT_ADDRESS, KDX_ADDRESS], [] ]
    function quoteMint(address _poolAddr, address[][] memory _routing, uint LPTokensRequested) external view returns (uint usdtToSpend);

    function quoteBurn(address _poolAddr, address[][] memory _routing, uint LPTokensToBurn) external view returns (uint usdtToReceive);

    // Mint fixed amount of LP tokens from poolId pool. If usdtMaxSpend smaller than the requested amount, reverts
    function mint(address _poolAddr, address usdAddr, address[][] memory _routing, uint LPTokensRequested, uint usdMaxSpend, address referredBy, uint deadline) external returns (uint amountsSpent);

    // Burn fixed amount of LP tokens from poolId pool. If usdMinReceive smaller than the requested amount, reverts
    function burn(address _poolAddr, address usdAddr, address[][] memory _routing, uint LPTokens, uint usdMinReceive, uint deadline) external returns (uint amountsReceived);

    // Mint with default routing
    function quickMint(address _poolAddr, address usdAddr, uint LPTokensRequested, uint usdMaxSpend, address referredBy, uint deadline) external returns (uint amountsSpent);

    // Burn with default routing
    function quickBurn(address _poolAddr, address usdAddr, uint LPTokens, uint usdMinReceive, uint deadline) external returns (uint amountReceived);

    // Get a quote to swap on a given pool.
    // If givenInOrOut == 1 (i.e., the number of tokens to be sent to the Pool is specified),
    // it returns the amount of tokens taken from the Pool, and the fees to pay
    // If givenInOrOut == 0 parameter (i.e., the number of tokens to be taken from the Pool is specified),
    // it returns the amount of tokens sent to the Pool, and the fees to pay
    function swapQuote(address poolAddress, bool givenInOrOut, address tokenIn, address tokenOut, uint amount) external view returns (uint _amount, uint _fees);

    function addTokens(address[] calldata _tokens) external;
    function removeTokens(address[] calldata _tokens) external;

    event tokenAdded(address indexed token);
    event tokenRemoved(address indexed token);
}
// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.17;

interface IUserProfile {

    struct UserProfile {                           /// Storage - We map the affiliated person to the affiliated_by person
        bool exists;
        uint8 rank;
        uint8 referredByRank;                       /// Rank of referrer at transaction time
        uint16 buyFeeDiscount;                            /// buy discount - 10000 = 100%
        uint32 referralCount;                          /// Number of referred by referee
        uint32 activeReferralCount;                    /// Number of active users referred by referee
        address referredBy;                            /// Address is referred by this user
        address referredByBefore;                     /// We store the 2nd step here to save gas (no interation needed)
    }

    struct Parent {
        uint8 rank;
        address user;
    }

    // returns the parent of the address
    function getParent(address _user) external view returns (address parent);
    // returns the parent and the parent of the parent of the address
    function getParents(address _user) external view returns (address parent, address parentOfParent);


    // returns user's parents and ranks of parents in 1 call
    function getParentsAndParentRanks(address _user) external view returns (Parent memory parent, Parent memory parent2);
    // returns user's parents and ranks of parents and use rbuy fee discount in 1 call
    function getParentsAndBuyFeeDiscount(address _user) external view returns (Parent memory parent, Parent memory parent2, uint16 discount);
    // returns number of referrals of address
    function getReferralCount(address _user) external view returns (uint32 count);
    // returns number of active referrals of address
    function getActiveReferralCount(address _user) external view returns (uint32 count);

    // returns up to _count referrals of _user
    function getAllReferrals(address _user) external view returns (address[] memory referrals);

    // returns up to _count referrals of _user starting from _index
    function getReferrals(address _user, uint256 _index, uint256 _count) external view returns (address[] memory referrals);

    function getDefaultReferral() external view returns (address defaultReferral);

    // get user information of _user
    function getUser(address _user) external view returns (UserProfile memory user);

    function getUserRank(address _user) external view returns (uint8 rank);

    // returns the total number of registered users
    function getUserCount() external view returns (uint256 count);

    // return true if user exists
    function userExists(address _user) external view returns (bool exists);

    function registerUser(address _user) external;

    function increaseActiveReferralCount(address _user) external;

    function registerUser(address _user, address _referredBy) external;

    function registerUserWoBooster(address _user) external;

    function setUserRank(address _user, uint8 _rank) external;

    // function setDefaultReferral(address _referral) external;

    // events
    event UserRegistered(address user, address referredBy, uint8 referredByRank, uint16 buyFeeDiscount);
}// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "../Interfaces/IGoverned.sol";

interface IVault is IGoverned {

    struct VaultState {
        bool userPoolTrackingDisabled;
        // bool paused;
        bool emergencyMode;
        bool whitelistingEnabled;
        bool flashEnabled;
        uint8 maxPoolTokenCount;
        uint8 feeToProtocol;
        uint8 bidMultiplier;
        uint16 flashFee;
        uint16 swapFee;
        uint16 bidMinDuration;
        uint16 rebalancingMinDuration;
        uint32 emergencyModeTimestamp;
        address feeTo;
    }

    struct PoolState {
        bool poolInitialized;
        bool poolEmergencyMode;
        bool feeless;
        bool boosted;
        uint8 poolTokenCount;
        uint32 emergencyModeTime;
        uint48 lastTrailingTimestamp;
        uint48 lastPerformanceTimestamp;
        uint216 emergencyModeLPs;
        TotalSupplyBase totalSupplyBase;
    }

    function getVaultState() external view returns (VaultState memory _vaultState);


    /************************************************************************************/
    /* Admin functions                                                                  */
    /************************************************************************************/
    // Check if given address is admin or not
    function isAdmin(address _address) external view returns (bool _isAdmin);

    // Add or remove vault admin. Only admin can call this function
    function AddRemoveAdmin(address _address, bool _ShouldBeAdmin) external;// returns (address, bool);

    // Boost or unboost pool. Boosted pools get 100% of their swap fees.
    // For non boosted pools, a part of the swap fees go to the platform.
    // Only admin can call this function
    function AddRemoveBoostedPool(address _address, bool _ShouldBeBoosted) external;// returns (address, bool);


    /************************************************************************************/
    /* Token whitelist                                                                  */
    /************************************************************************************/

    // Only admin can call this function. Only the whitelisted tokens can be added to a Pool
    // If empty: No whitelist, all tokens are allowed
    function setWhitelistedTokens(address[] calldata _tokens, bool[] calldata _whitelisted) external;

    function isTokenWhitelisted(address token) external view returns (bool whitelisted);
    event TokenWhitelistChanged(address indexed token, bool isWhitelisted);

    /************************************************************************************/
    /* Internal Balances                                                                */
    /************************************************************************************/

    // Users can deposit tokens into the Vault to have an internal balance in the Mosaic platform.
    // This internal balance can be used to deposit tokens into a Pool (Mint), withdraw tokens from
    // a Pool (Burn), or perform a swap. The internal balance can also be transferred or withdrawn.

    // Get a specific user's internal balance for one given token
    function getInternalBalance(address user, address token) external view returns (uint balance);

    // Get a specific user's internal balances for the given token array
    function getInternalBalances(address user, address[] memory tokens) external view returns (uint[] memory balances);

    // Deposit tokens to the msg.sender's  internal balance
    function depositToInternalBalance(address token, uint amount) external;

    // Deposit tokens to the recipient internal balance
    function depositToInternalBalanceToAddress(address token, address to, uint amount) external;

    // ERC20 token transfer from the message sender's internal balance to their address
    function withdrawFromInternalBalance(address token, uint amount) external;

    // ERC20 token transfer from the message sender's internal balance to the given address
    function withdrawFromInternalBalanceToAddress(address token, address to, uint amount) external;

    // Transfer tokens from the message sender's internal balance to another user's internal balance
    function transferInternalBalance(address token, address to, uint amount) external;

    // Event emitted when user's internal balance changes by delta amount. Positive delta means internal balance increase
    event InternalBalanceChanged(address indexed user, address indexed token, int256 delta);

    /************************************************************************************/
    /* Pool ERC20 helper                                                                */
    /************************************************************************************/

    function transferFromAsTokenContract(address from, address to, uint amount) external returns (bool success);
    function mintAsTokenContract(address to, uint amount) external returns (bool success);
    function burnAsTokenContract(address from, uint amount) external returns (bool success);

    /************************************************************************************/
    /* Pool                                                                             */
    /************************************************************************************/

    struct TotalSupplyBase {
        uint32 timestamp;
        uint224 amount;
    }

    event TotalSupplyBaseChanged(address indexed poolAddr, TotalSupplyBase supplyBase);
    // Each pool should be one of the following based on poolType:
    // 0: REBALANCING: (30% ETH, 30% BTC, 40% MKR). Weight changes gradually in time.
    // 1: NON_REBALANCING: (100 ETH, 5 BTC, 200 MKR). Weight changes gradually in time.
    // 2: DAYTRADE: Non rebalancing pool. Weight changes immediately.

    function tokenInPool(address pool, address token) external view returns (bool inPool);

    function poolIdToAddress(uint32 poolId) external view returns (address poolAddr);

    function poolAddressToId(address poolAddr) external view returns (uint32 poolId);

    // pool calls this to move the pool to zerofee status
    function disableFees() external;

    // Returns the total pool count
    function poolCount() external view returns (uint32 count);

    // Returns a list of pool IDs where the user has assets
    function userJoinedPools(address user) external view returns (uint32[] memory poolIDs);

    // Returns a list of pool the user owns
    function userOwnedPools(address user) external view returns (uint32[] memory poolIDs);

    //Get pool tokens and their balances
    function getPoolTokens(uint32 poolId) external view returns (address[] memory tokens, uint[] memory balances);

    function getPoolTokensByAddr(address poolAddr) external view returns (address[] memory tokens, uint[] memory balances);

    function getPoolTotalSupplyBase(uint32 poolId) external view returns (TotalSupplyBase memory totalSupplyBase);

    function getPoolTotalSupplyBaseByAddr(address poolAddr) external view returns (TotalSupplyBase memory totalSupplyBase);

    // Register a new pool. Pool type can not be changed after the creation. Emits a PoolRegistered event.
    function registerPool(address _poolAddr, address _user, address _referredBy) external returns (uint32 poolId);
    event PoolRegistered(uint32 indexed poolId, address indexed poolAddress);

    // Registers tokens for the Pool. Must be called by the Pool's contract. Emits a TokensRegistered event.
    function registerTokens(address[] memory _tokenList, bool onlyWhitelisted) external;
    event TokensRegistered(uint32 indexed poolId, address[] newTokens);

    // Adds initial liquidity to the pool
    function addInitialLiquidity(uint32 _poolId, address[] memory _tokens, uint[] memory _liquidity, address tokensTo, bool fromInternalBalance) external;
    event InitialLiquidityAdded(uint32 indexed poolId, address user, uint lpTokens, address[] tokens, uint[] amounts);

    // Deegisters tokens for the poolId Pool. Must be called by the Pool's contract.
    // Tokens to be deregistered should have 0 balance. Emits a TokensDeregistered event.
    function deregisterToken(address _tokenAddress, uint _remainingAmount) external;
    event TokensDeregistered(uint32 indexed poolId, address tokenAddress);

    // This function is called when a liquidity provider adds liquidity to the pool.
    // It mints additional liquidity tokens as a reward.
    // If fromInternalBalance is true, the amounts will be deducted from user's internal balance
    function Mint(uint32 poolId, uint LPTokensRequested, uint[] memory amountsMax, address to, address referredBy, bool fromInternalBalance, uint deadline, uint usdValue) external returns (uint[] memory amountsSpent);
    event Minted(uint32 indexed poolId, address txFrom, address user, uint lpTokens, address[] tokens, uint[] amounts, bool fromInternalBalance);

    // This function is called when a liquidity provider removes liquidity from the pool.
    // It burns the liquidity tokens and sends back the tokens as ERC20 transfer.
    // If toInternalBalance is true, the tokens will be deposited to user's internal balance
    function Burn(uint32 poolId, uint LPTokensToBurn, uint[] memory amountsMin, bool toInternalBalance, uint deadline, address from) external returns (uint[] memory amountsReceived);
    event Burned(uint32 indexed poolId, address txFrom, address user, uint lpTokens, address[] tokens, uint[] amounts, bool fromInternalBalance);

    /************************************************************************************/
    /* Swap                                                                             */
    /************************************************************************************/

    // Executes a swap operation on a single Pool. Called by the user
    // If the swap is initiated with givenInOrOut == 1 (i.e., the number of tokens to be sent to the Pool is specified),
    // it returns the amount of tokens taken from the Pool, which should not be less than limit.
    // If the swap is initiated with givenInOrOut == 0 parameter (i.e., the number of tokens to be taken from the Pool is specified),
    // it returns the amount of tokens sent to the Pool, which should not exceed limit.
    // Emits a Swap event
    function swap(address poolAddress, bool givenInOrOut, address tokenIn, address tokenOut, uint amount, bool fromInternalBalance, uint limit, uint64 deadline) external returns (uint calculatedAmount);
    event Swap(uint32 indexed poolId, address indexed tokenIn, address indexed tokenOut, uint amountIn, uint amountOut, address user);

    // Execute a multi-hop token swap between multiple pairs of tokens on their corresponding pools
    // Example: 100 tokenA -> tokenB -> tokenC
    // pools = [pool1, pool2], tokens = [tokenA, tokenB, tokenC], amountIn = 100
    // The returned amount of tokenC should not be less than limit
    function multiSwap(address[] memory pools, address[] memory tokens, uint amountIn, bool fromInternalBalance, uint limit, uint64 deadline) external returns (uint calculatedAmount);

    /************************************************************************************/
    /* Dutch Auction                                                                    */
    /************************************************************************************/
    // Non rebalancing pools (where poolId is not 0) can use Dutch auction to change their
    // balance sheet. A Dutch auction (also called a descending price auction) refers to a
    // type of auction in which an auctioneer starts with a very high price, incrementally
    // lowering the price. User can bid for the entire amount, or just a fraction of that.

    struct AuctionInfo {
        address poolAddress;
        uint32 startsAt;
        uint32 duration;
        uint32 expiration;
        address tokenToSell;
        address tokenToBuy;
        uint startingAmount;
        uint remainingAmount;
        uint startingPrice;
        uint endingPrice;
    }

    // Get total (lifetime) auction count
    function getAuctionCount() external view returns (uint256 auctionCount);

    // Get all information of the given auction
    function getAuctionInfo(uint auctionId) external view returns (AuctionInfo memory);

    // Returns 'true' if the auction is still running and there are tokens available for purchase
    // Returns 'false' if the auction has expired or if all tokens have been sold.
    function isRunning(uint auctionId) external view returns (bool);

    // Called by pool owner. Emits an auctionStarted event
    function startAuction(address tokenToSell, uint amountToSell, address tokenToBuy, uint32 duration, uint32 expiration, uint endingPrice) external returns (uint auctionId);
    event AuctionStarted(uint32 poolId, uint auctionId, AuctionInfo _info);

    // Called by pool owner. Emits an auctionStopped event
    function stopAuction(uint auctionId) external;
    event AuctionStopped(uint auctionId);

    // Get the current price for 'remainingAmount' number of tokens
    function getBidPrice(uint auctionId) external view returns (uint currentPrice, uint remainingAmount);

    // Place a bid for the specified 'auctionId'. Fractional bids are supported, with the 'amount'
    // representing the number of tokens to purchase. The amounts are deducted from and credited to the
    // user's internal balance. If there are insufficient tokens in the user's internal balance, the function reverts.
    // If there are fewer tokens available for the auction than the specified 'amount' and enableLessAmount == 1,
    // the function purchases all remaining tokens (which may be less than the specified amount).
    // If enableLessAmount is set to 0, the function reverts. Emits a 'newBid' event
    function bid(uint auctionId, uint amount, bool enableLessAmount, bool fromInternalBalance, uint deadline) external returns (uint spent);
    event NewBid(uint auctionId, address buyer, uint tokensBought, uint paid, address tokenToBuy, address tokenToSell, uint remainingAmount);

    /************************************************************************************/
    /* Emergency                                                                        */
    /************************************************************************************/
    // Activate emergency mode. Once the contract enters emergency mode, it cannot be reverted or cancelled.
    // Only an admin can call this function.
    function setEmergencyMode() external;

    // Activate emergency mode. Once the contract enters emergency mode, it cannot be reverted or cancelled.
    function setPoolEmergencyMode(address poolAddress) external;
}
// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.17;

interface IVaultDelegated {
function DselfManageMe() external;
}// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.17;

/**
 * @title Mosaic Alpha Vault contract
 * @author dlabs.hu
 * @dev This contract is for storing tokens and keeping the book
 */

import "../Interfaces/IVault.sol";
import "../Interfaces/IPool.sol";
import "../Interfaces/ISwaps.sol";
import "../Interfaces/IUserProfile.sol";
import "../Interfaces/IAffiliate.sol";
import "../Interfaces/IFees.sol";
import "../Interfaces/IRegister.sol";
import "../Interfaces/IMosaicOracle.sol";
import "../helpers/IERC20Burnable.sol";
import "../Interfaces/IFeeBurner.sol";
import "../Interfaces/IGovernance.sol";
import "../Governance/Governed.sol";
import "../Interfaces/IVaultDelegated.sol";

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/math/SafeCast.sol";
import "../Interfaces/IERC3156FlashLender.sol";


contract Vault is IVault, IERC3156FlashLender, ReentrancyGuard, Governed {
    using SafeERC20 for IERC20;
    using SafeCast for uint;
    using SafeCast for uint256;
    using SafeCast for uint224;

    uint constant MIN_INITIAL_LIQUIDITY = 1e4;

    mapping (address => mapping (address => bool)) public tokenInPool;
 
    VaultState internal vaultState;
    function getVaultState() external view returns (VaultState memory _vaultState) {
        return vaultState;
    }
    address private vaultLib;
    address public swapsContract;                       // Swaps smart contract address
    uint32 public poolCount;                            // Number of Pools

    uint internal auctionCount;                           // Number of Dutch Auctions

    function getAuctionCount() external view returns (uint256){ return auctionCount;}

    mapping (address => bool) internal admins;
    mapping (uint32 => address) internal _poolIdToAddress;
    mapping (address => uint32) internal _poolAddressToId; // If returns 0: Pool not registered. Lowest pool Id is 1
    mapping (uint => AuctionInfo) internal auctions;

    function getAuction(uint _id) external view returns (AuctionInfo memory auctionInfo) {
        auctionInfo = auctions[_id];
    }


    mapping (address => PoolState) internal poolStates;
    function getPoolState(address _pool) external view returns (PoolState memory _poolState) {
        return poolStates[_pool];
    }

    address public poolFactory;
    address public userProfile;
    address public mosaicOracle;
    address public affiliate;
    address public fees;
    address public register;

    // Flash loan
    bytes32 public constant CALLBACK_SUCCESS = keccak256("ERC3156FlashBorrower.onFlashLoan");

    mapping (address => bool) public zeroFee;          // Addresses that have 0 fee flash loans and swaps

    constructor(address _governAddress, address _vaultLib) {
        admins[msg.sender] = true;
        governanceState.governanceAddress = _governAddress;
        vaultLib = _vaultLib;
    }


    /* EMERGENCY */
    // Activate emergency mode. Once the contract enters emergency mode, it cannot be reverted or cancelled.
    function setEmergencyMode() external {
        onlyManagersFun();
        _setEmergencyMode();
    }

    function _setEmergencyMode() internal {
        LiveFun();
        vaultState.emergencyMode = true;
        vaultState.emergencyModeTimestamp = uint32(block.timestamp);
    }

    // Activate emergency mode. Once the contract enters emergency mode, it cannot be reverted or cancelled.
    error Vault__GenericError(string s);
    error Vault__EmergencyAlreadyActive();
    error Vault__OnlyAdminOrPool();
    function setPoolEmergencyMode(address poolAddress) external {
        if (!isManagerFun(msg.sender) && msg.sender != poolAddress) revert Vault__OnlyAdminOrPool();
        if (poolStates[poolAddress].poolEmergencyMode != false) revert Vault__EmergencyAlreadyActive(); // EMERGENCY MODE ALREADY ACTIVE
        poolStates[poolAddress].poolEmergencyMode = true;
        poolStates[poolAddress].emergencyModeTime = uint32(block.timestamp);
    }


    /* Governance */
    error Vault__EmergencyStopped();
    function LiveFun(address _a) internal view {
        if (vaultState.emergencyMode || poolStates[_a].poolEmergencyMode) revert Vault__EmergencyStopped(); // Emergency stopped.
    }

    // Call this from governance or by manually by manager to activate the configuration update
    function selfManageMe() external virtual override(Governed, IGoverned) {
        _delegateCall(vaultLib);
    }

    function _selfManageMeBefore() internal virtual override {}
    function _selfManageMeAfter() internal virtual override {}
    function _onBeforeEmergencyChange(bool nexRunning) internal virtual override {}

    /************************************************************************************/
    /* Internal helper stuff                                                           */
    /************************************************************************************/
    function _registerUser(address to, address referredBy) internal virtual {
        IUserProfile(userProfile).registerUser(to, referredBy);
    }

    function _registerUserPurchase(address to, address referredBy, address trader, address[] memory tokens, uint[] memory tokenAmounts, uint256 usdAmount) internal virtual {
        if (usdAmount > 0) {
            IAffiliate(affiliate).registerUserPurchase(to, referredBy, trader, usdAmount);
        } else {
            IAffiliate(affiliate).registerUserPurchaseAsTokens(to, referredBy, trader, tokens, tokenAmounts);
        }
    }


    /************************************************************************************/
    /* Admin                                                                            */
    /************************************************************************************/
    mapping (address => bool) internal whitelistedTokens;

    error Vault__OnlyAdmin();
    function onlyAdmin() internal view {
        if (!isAdmin(msg.sender)) revert Vault__OnlyAdmin(); // NOT AUTHORIZED
    }

    error Vault__OnlyFactory();
    modifier onlyFactory() {
        if (poolFactory != msg.sender) revert Vault__OnlyFactory(); // NOT AUTHORIZED
        _;
    }

    // Check if given address is admin or not
    function isAdmin(address _address) public virtual view returns (bool _isAdmin) {
        _isAdmin = admins[_address];
    }

    // Add or remove vault admin. Only admin can call this function
    function AddRemoveAdmin(address _address, bool _ShouldBeAdmin) external virtual {
        _delegateCall(vaultLib);
    }

    // Boost or unboost pool. Boosted pools get 100% of their swap fees.
    // For non boosted pools, a part of the swap fees go to the platform.
    // Only admin can call this function
    function AddRemoveBoostedPool(address _address, bool _ShouldBeBoosted) external virtual { // returns (address, bool) {
        _delegateCall(vaultLib);
    }

    function AddRemoveZeroFeeAddress(address _address, bool _ShouldBeZeroFee) external virtual {
        LiveFun();
        onlyAdmin();
        zeroFee[_address] = _ShouldBeZeroFee;
    }


    function _delegateCall(address _target) private {
        assembly {
            calldatacopy(0, 0, calldatasize())
            let result := delegatecall(gas(), _target, 0, calldatasize(), 0, 0)
            let size := returndatasize()
            switch result
            case 0 {
                 returndatacopy(0, 0, size)
                 revert(0, size)
            }
            default { 
                let retSize := returndatasize()
                returndatacopy(0, 0, retSize)
                return(0, retSize) 
            }
        }
    }

    // Only admin can call this function. Only the whitelisted tokens can be added to a Pool
    function setWhitelistedTokens(address[] calldata _tokens, bool[] calldata _whitelisted) external virtual {
        _delegateCall(vaultLib);
    }

    function isTokenWhitelisted(address _token) public virtual view returns (bool whitelisted) {
        return whitelistedTokens[_token];
    }

    /************************************************************************************/
    /* Internal Balances                                                                */
    /************************************************************************************/

    // Internal Balance: _internalBalance[_user][_token];
    mapping(address => mapping(address => uint)) internal _internalBalance;

    // Get a specific user's internal balance for one given token
    function getInternalBalance(address _user, address _token) public virtual view returns (uint balance) {
        return _internalBalance[_user][_token];
    }

    // Get a specific user's internal balances for the given token array
    function getInternalBalances(address user, address[] memory tokens) public virtual view returns (uint[] memory balances) {
        balances = new uint[](tokens.length);
        for (uint i = 0; i < tokens.length; i++) {
            balances[i] = getInternalBalance(user, tokens[i]);
        }
    }

    // Deposit tokens to the recipient internal balance
    function depositToInternalBalance(address token, uint amount) external virtual {
        LiveFun();
        _depositToInternalBalance(token, msg.sender, msg.sender, amount, false);
    }

    // Deposit tokens to the recipient internal balance
    function depositToInternalBalanceToAddress(address token, address to, uint amount) external virtual {
        LiveFun();
        _depositToInternalBalance(token, msg.sender, to, amount, false);
    }

    // ERC20 token transfer from the message sender's internal balance to their address
    function withdrawFromInternalBalance(address token, uint amount) external virtual {
        _withdrawFromInternalBalance(token, msg.sender, msg.sender, amount);
    }

    function withdrawFromInternalBalanceToAddress(address token, address to, uint amount) external virtual {
        _withdrawFromInternalBalance(token, msg.sender, to, amount);
    }

    // Transfer tokens from the message sender's internal balance to another user's internal balance
    function transferInternalBalance(address token, address to, uint amount) external virtual {
        _transferInternalBalance(token, msg.sender, to, amount);
    }

    error Vault__CantDepositPoolToken();
    error Vault__OnlyWhitelistedTokensCanBeDeposited();
    function _depositToInternalBalance(address token, address from, address to, uint amount, bool ignoreWhitelisting) internal {
        if (_poolAddressToId[token] != 0) revert Vault__CantDepositPoolToken(); // Vault: Can't deposit a Pool token to internal deposit
        // only future pools that are effectively created for handling nonwhitelisted tokens can deposit such tokens
        if (!ignoreWhitelisting && !isTokenWhitelisted(token)) revert Vault__OnlyWhitelistedTokensCanBeDeposited(); // Vault: Can't deposit a non-whitelisted token
        IERC20(token).safeTransferFrom(from, address(this), amount);
        _internalBalance[to][token] += amount;
        emit InternalBalanceChanged(to, token, int256(amount));
    }

    error Vault__CantWithdrawPoolToken();
    error Vault__InsufficientBalance();
    function _withdrawFromInternalBalance(address token, address from, address to, uint amount) internal {
        if (_poolAddressToId[token] != 0) revert Vault__CantWithdrawPoolToken(); // Vault: Can't withdraw a Pool token from internal deposit
        uint _balance = getInternalBalance(from, token);
        if (_balance < amount) revert Vault__InsufficientBalance(); // WFIB: INSUFFICIENT BALANCE

        _internalBalance[from][token] -= amount;
        IERC20(token).safeTransfer(to, amount);

        emit InternalBalanceChanged(from, token, -int256(amount));
    }

    function _transferInternalBalance(address token, address from, address to, uint amount) internal {
        _transferInternalBalance(token, from, to, amount, true);
    }

    function _transferInternalBalance(address token, address from, address to, uint amount, bool callPoolTransferHook) internal {
        uint _balance = getInternalBalance(from, token);
        if (_balance < amount) revert Vault__InsufficientBalance(); // WFIB: INSUFFICIENT BALANCE

        emit InternalBalanceChanged(from, token, -int256(amount));
        emit InternalBalanceChanged(to, token, int256(amount));
        if (_poolAddressToId[token] > 0 && !vaultState.emergencyMode && !poolStates[token].poolEmergencyMode) {
            _onBeforeBalanceTransfer(token, from, to, amount, false, false, false);
            if (amount > 0) {
                _internalBalance[from][token] -= amount;
                _internalBalance[to][token] += amount;
                _handlerForPoolOfUser(from, token, false);
                _handlerForPoolOfUser(to, token, true);
            }
            if (callPoolTransferHook) IPool(token).emitTransfer(from, to, amount);
        } else {
            if (amount > 0) {
                _internalBalance[from][token] -= amount;
                _internalBalance[to][token] += amount;
            }
        }
    }

    // DONT FORGET TO ALSO MINT TRAILING FEE IF THIS IS USED
    error Vault__OnlyPoolCanBeMinted();
    function _mintToInternalBalance(address token, address to, uint amount, bool callPoolTransferHook, bool feesAlreadyAllocated) internal {
        LiveFun(token);
        if (_poolAddressToId[token] == 0) revert Vault__OnlyPoolCanBeMinted(); // Vault: only a registered Pool token can mint to its users' internal deposit
        _onBeforeBalanceTransfer(token, address(0), to, amount, feesAlreadyAllocated, true, false);
        poolStates[token].totalSupplyBase.amount += (amount).toUint224();
        poolStates[token].totalSupplyBase.timestamp = uint32(block.timestamp);
        emit TotalSupplyBaseChanged(token, poolStates[token].totalSupplyBase);
        _internalBalance[to][token] += amount;
        _handlerForPoolOfUser(to, token, true);
        // TODO casting!!!
        emit InternalBalanceChanged(to, token, int256(amount));
        if (callPoolTransferHook) IPool(token).emitTransfer(address(0), to, amount);
    }

    // DONT FORGET TO ALSO MINT TRAILING FEE IF THIS IS USED
    error Vault__OnlyPoolCanBeBurned();
    function _burnFromInternalBalance(address token, address from, uint amount, bool callPoolTransferHook, bool feesAlreadyAllocated) internal {
        LiveFun(token);
        if (_poolAddressToId[token] == 0) revert Vault__OnlyPoolCanBeBurned(); // Vault: only a registered Pool token can burn from its users internal deposit
        _onBeforeBalanceTransfer(token, from, address(0), amount, feesAlreadyAllocated, true, false);
        _internalBalance[from][token] -= amount;
        poolStates[token].totalSupplyBase.amount -= (amount).toUint224();
        poolStates[token].totalSupplyBase.timestamp = uint32(block.timestamp);
        emit TotalSupplyBaseChanged(token, poolStates[token].totalSupplyBase);
        _handlerForPoolOfUser(from, token, false);
        emit InternalBalanceChanged(from, token, -int256(amount));
        if (callPoolTransferHook) IPool(token).emitTransfer(from, address(0), amount);
    }


    /************************************************************************************/
    /* Fees handler                                                                     */
    /************************************************************************************/

    function _calculateTrailingAndPerformanceFee(address _pool, bool forceTrailing, bool forcePerformance) internal virtual returns (uint128 trailingFeesToMint, uint128 performanceFeesToMint) {
        bool mintTrailing;
        bool mintPerformance;
        // run if forced unless already allocated in this second and also if time passed
        if ((forcePerformance && (poolStates[_pool].lastPerformanceTimestamp < block.timestamp)) || poolStates[_pool].lastPerformanceTimestamp < block.timestamp - 7 days) {
            // trailing must be run, too if performance runs
            mintPerformance = true;
            forceTrailing = true;
        }
        // run if forced unless already allocated in this second and also if time passed
        if ((forceTrailing && (poolStates[_pool].lastTrailingTimestamp < block.timestamp)) || poolStates[_pool].lastTrailingTimestamp < block.timestamp - 3 days) {
            mintTrailing = true;
        }
        if (mintTrailing) {
            // calculate and allocate trailing fee just as in Mint (ask pool contract the TF amount then )
            trailingFeesToMint = (IPool(_pool).getTrailingFeeAmount(poolStates[_pool].totalSupplyBase)).toUint128();
            poolStates[_pool].lastTrailingTimestamp = uint48(block.timestamp);
        }

        if (mintPerformance) {
            // calculate and allocate perf fee just as in Mint (ask pool contract the TF amount then )
            TotalSupplyBase memory tsTmp = poolStates[_pool].totalSupplyBase;
            uint256 valuePerLp = _consultPoolPricePerLpByAddr(_pool, tsTmp);

            performanceFeesToMint = (IPool(_pool).updatePerfFeePricePerLp(tsTmp, valuePerLp));

            poolStates[_pool].lastPerformanceTimestamp = uint48(block.timestamp);
        }
    }

    // anyone can call to take a proceeding form the generated fees
    error Vault__NotAPool(uint idx);
    function allocateTrailingAndPerformanceFee(address _pool) external {
        LiveFun(_pool);
        if (_poolAddressToId[_pool] == 0) revert Vault__NotAPool(0);
        _onBeforeBalanceTransfer(_pool, address(0), address(0), 0, false, true, true);
    }

    // notifies Fees contract about balance change and fee allocations
    function _onBeforeBalanceTransfer(address _pool, address _from, address _to, uint amount, bool feesAlreadyAllocated, bool forceTrailingFeeAllocation, bool forcePerformanceFeeAllocation) internal virtual {
        if (poolStates[_pool].feeless) return;
        IFees.OnBeforeTransferPayload memory payload;
        if (!feesAlreadyAllocated) {
            uint128 originalTotalsupplyBase = (poolStates[_pool].totalSupplyBase.amount).toUint128();

            if (msg.sender == tx.origin) {
                // only real users may participate
                (payload.trailingLpToMint, payload.performanceLpToMint) = _calculateTrailingAndPerformanceFee(_pool, forceTrailingFeeAllocation, forcePerformanceFeeAllocation);
            }

            uint128 expAmount = payload.trailingLpToMint + payload.performanceLpToMint;
            if (expAmount > 0) {
                address trader = IPool(_pool).creator();
                payload.feesContractBalanceBefore = getInternalBalance(fees, _pool).toUint128();
                IFees(fees).onBeforeTransfer(_pool, _from, _to, _internalBalance[_from][_pool], _internalBalance[_to][_pool]
                                                , amount, originalTotalsupplyBase, trader
                                                , payload
                                                );
                // do the mint for the Trader
                poolStates[_pool].totalSupplyBase.amount += uint224(expAmount);
                poolStates[_pool].totalSupplyBase.timestamp = (block.timestamp).toUint32();
                emit TotalSupplyBaseChanged(_pool, poolStates[_pool].totalSupplyBase);
                _internalBalance[fees][_pool] += expAmount;
                _handlerForPoolOfUser(fees, _pool, true);
                // TODO casting!!!
                emit InternalBalanceChanged(fees, _pool, int256(uint256(expAmount)));
                if (true) IPool(_pool).emitTransfer(address(0), fees, amount);
                return;
            }
        }
        IFees(fees).onBeforeTransfer(_pool, _from, _to, _internalBalance[_from][_pool], _internalBalance[_to][_pool], amount, 0, address(0), payload);
    }


    /************************************************************************************/
    /* Pool ERC20 helper                                                                */
    /************************************************************************************/
    function transferFromAsTokenContract(address from, address to, uint amount) external virtual returns (bool success) {
        LiveFun(msg.sender);
        if (_poolAddressToId[msg.sender] == 0) revert Vault__NotAPool(1); // NOT A POOL
        _transferInternalBalance(msg.sender, from, to, amount, false);
        return true;
    }

    function mintAsTokenContract(address to, uint amount) external virtual returns (bool success) {
        LiveFun(msg.sender);
        if (_poolAddressToId[msg.sender] == 0) revert Vault__NotAPool(2); // NOT A POOL
        _mintToInternalBalance(msg.sender, to, amount, false, false);
        return true;
    }

    function burnAsTokenContract(address to, uint amount) external virtual returns (bool success) {
        LiveFun(msg.sender);
        if (_poolAddressToId[msg.sender] == 0) revert Vault__NotAPool(3); // NOT A POOL
        _burnFromInternalBalance(msg.sender, to, amount, false, false);
        return true;
    }

    /************************************************************************************/
    /* Pool                                                                             */
    /************************************************************************************/

    mapping (address => uint32[]) internal poolOfUser;  // [user] = [list of pool ids
    mapping (address => mapping (uint32 => uint32)) internal poolOfUserIndexes; // [user][poolid] = index + 1 of pool id in poolOfUser[user] (so indexing starts from 1! 0 means: nonexistent in the list)
    mapping (address => uint32[]) internal usrOwnedPools;   // [user] = [list of pool ids]

    function disableFees() external {
        LiveFun();
        poolStates[msg.sender].feeless = true;
    }

    function poolIdToAddress(uint32 poolId) external virtual view returns (address poolAddr) {
        return _poolIdToAddress[poolId];
    }

    function poolAddressToId(address poolAddr) external virtual view returns (uint32 poolId) {
        return _poolAddressToId[poolAddr];
    }

    // Returns a list of pool IDs where the user has assets
    function userJoinedPools(address user) external virtual view returns (uint32[] memory poolIDs) {
        return poolOfUser[user];
    }

    // Returns a list of pool the user owns
    function userOwnedPools(address user) external virtual view returns (uint32[] memory poolIDs) {
        return usrOwnedPools[user];
    }


    //Get pool tokens and their balances
    function getPoolTokens(uint32 poolId) external virtual view returns (address[] memory tokens, uint[] memory balances) {
        return _getPoolTokensByAddr(_poolIdToAddress[poolId]);
    }
    
    //Get pool tokens and their balances
    function getPoolTokensByAddr(address poolAddr) external virtual view returns (address[] memory tokens, uint[] memory balances) {
        return _getPoolTokensByAddr(poolAddr);
    }

    function _getPoolTokensByAddr(address poolAddr) internal virtual view returns (address[] memory tokens, uint[] memory balances) {   
        tokens = IPool(poolAddr).getTokens();
        balances = getInternalBalances(poolAddr, tokens);
    }

    function getPoolTotalSupplyBaseByAddr(address poolAddr) external virtual view returns (TotalSupplyBase memory base) {
        return poolStates[poolAddr].totalSupplyBase;
    }


    function _consultPoolPricePerLpByAddr(address poolAddr, TotalSupplyBase memory ts) internal virtual returns (uint256 value) {
        return IMosaicOracle(mosaicOracle).consultUsdPoolPricePerLp(poolAddr, ts);
    }

    function getPoolValueByAddr(address poolAddr) external virtual view returns (uint256 value) {
        address[] memory tokens = IPool(poolAddr).getTokens();
        uint256[] memory balances = getInternalBalances(poolAddr, tokens);
        return IMosaicOracle(mosaicOracle).getUsdPoolPrice(tokens, balances);
    }

    function getPoolTotalSupplyBase(uint32 poolId) external virtual view returns (TotalSupplyBase memory ts) {
        address poolAddr = _poolIdToAddress[poolId];
        return poolStates[poolAddr].totalSupplyBase;
    }

    // Called by newly created pool
    error Vault__PoolAlreadyRegistered();
    error Vault__PoolCantBeWhitelistedToken();
    error Vault__TxNotSignedByUser();
    function registerPool(address _pool, address _user, address _referredBy) external virtual onlyFactory returns (uint32 poolId) {
        //_delegateCall(vaultLib);
        LiveFun();
        if (_poolAddressToId[_pool] != 0) revert Vault__PoolAlreadyRegistered(); // POOL ALREADY REGISTERED
        if (isTokenWhitelisted(_pool)) revert Vault__PoolCantBeWhitelistedToken(); // POOL CANNOT BE WHITELISTED TOKEN
        if (_user != tx.origin) revert Vault__TxNotSignedByUser(); //MUST BE SIGNED BY CREATOR
        _registerUser(_user, _referredBy);

        poolCount += 1 ;
        uint32 _poolId = poolCount;

        _poolAddressToId[_pool] = _poolId;
        _poolIdToAddress[_poolId] = _pool;

        usrOwnedPools[_user].push(_poolId);

        emit PoolRegistered(_poolId, _pool);
        return _poolId;
    }

    // Add tokens to an existing pool. Called by the pool contract
    function registerTokens(address[] memory _newTokens, bool onlyWhitelisted) external virtual {
        _delegateCall(vaultLib);
    }

    // Adds initial liquidity to the pool - called by pool
    error Vault__PoolNotFound();
    error Vault__AlreadyInitialized();
    error Vault__NotAuthorized();
    error Vault__ArrayMismatch();
    error Vault__TokenMismatch();
    error Vault__MinInitialLiquidityNotReached();
    error Vault__TokenNotInPool(address token);
    error Vault__InitialLiquidityAlreadyProvided();
    error Vault__InitialLiquidityAlreadyProvided2();
    error Vault__MinInitialLpLiquidityNotReached();
    error Vault__MinLpDustAmountNotReached();

    function addInitialLiquidity(uint32 _poolId, address[] memory _tokens, uint[] memory _liquidity, address _lpTo, bool fromInternalBalance) external virtual nonReentrant {
        address _poolAddress = _poolIdToAddress[_poolId];
        if (_poolId == 0 || _poolAddress == address(0)) revert Vault__PoolNotFound(); // POOL NOT FOUND
        if (poolStates[_poolAddress].poolInitialized) revert Vault__AlreadyInitialized(); // ALREADY INITIALIZED
        if (msg.sender != poolFactory && msg.sender != _poolAddress && msg.sender != IPool(_poolAddress).owner()) revert Vault__NotAuthorized(); // NOT AUTHORIZED
        poolStates[_poolAddress].poolInitialized = true;
        address[] memory tokens = IPool(_poolAddress).getTokens();
        address _sender = msg.sender;

        if (_liquidity.length != tokens.length) revert Vault__ArrayMismatch(); // ARRAY MISMATCH

        for (uint i = 0; i < _liquidity.length; i++) {
            if (tokens[i] != _tokens[i]) revert Vault__TokenMismatch(); // TOKEN MISMATCH
            if (_liquidity[i] < MIN_INITIAL_LIQUIDITY) revert Vault__MinInitialLiquidityNotReached(); // MIN INITIAL LIQUIDITY NOT REACHED
            if (!tokenInPool[_poolAddress][tokens[i]]) revert Vault__TokenNotInPool(tokens[i]); // TOKEN NOT REGISTERED IN POOL
            if (fromInternalBalance) {
                if (getInternalBalance(_poolAddress, tokens[i]) != _liquidity[i]) revert Vault__InitialLiquidityAlreadyProvided(); // INITIAL LIQUIDITY ALREADY PROVIDED
            } else {
                if (getInternalBalance(_poolAddress, tokens[i]) != 0) revert Vault__InitialLiquidityAlreadyProvided2(); // INITIAL LIQUIDITY ALREADY PROVIDED
                _depositToInternalBalance(tokens[i], _sender, _poolAddress, _liquidity[i], false);
            }
            // Transfer token from User's wallet to Pool's internal balance
        }

        (uint lpTokens, uint dust) = IPool(_poolAddress).initialLiquidityProvided(_tokens, _liquidity);
        if (lpTokens < 1e4) revert Vault__MinInitialLpLiquidityNotReached(); // MIN INITIAL LIQ VALUE NOT REACHED
        if (dust < 1e3) revert Vault__MinLpDustAmountNotReached(); // MIN DUST AMOUNT NOT REACHED
        // LP tokens credited to liquidity provider
        // 1e3 LP token gets "burned" to ensure having at least 1e3 LP token

        _mintToInternalBalance(_poolAddress, _lpTo, lpTokens, true, true);

        _mintToInternalBalance(_poolAddress, address(0), dust, true, true);
    }

    // Remove token from an existing pool. Called by the pool contract
    function deregisterToken(address _tokenAddress, uint _remainingAmount) external virtual {
        _delegateCall(vaultLib); 
    }

    // This function is called by the user when adding liquidity to the pool.
    // It mints additional liquidity tokens as a reward.
    // If fromInternalBalance is true, the amounts will be deducted from user's internal balance
    error Vault__MintTxExpired();
    error Vault__CantMintZero();
    error Vault__UserNotWhiteListed();
    error Vault__MaxMintSlippageExceeded();
    error Vault__OnlySwapsCanSendUsd();
    function Mint(uint32 poolId, uint LPTokensRequested, uint[] memory amountsMaxSpend, address to, address referredBy, bool fromInternalBalance, uint deadline, uint usdValue) external virtual nonReentrant returns (uint[] memory amountsToSpend) {
        if (block.timestamp > deadline) revert Vault__MintTxExpired(); // Transaction expired // validate the deadline
        if (LPTokensRequested == 0) revert Vault__CantMintZero(); // LPTokensRequested CANNOT BE 0 // and that we mint a valid amount of LPTs
        if (poolId == 0 || poolId > poolCount) revert Vault__PoolNotFound(); // POOL DOES NOT EXIST // check if pool id is valid

        // if whitelisting is enable only allow users who are WL'd to buy
        if (vaultState.whitelistingEnabled == true) {
            // we use the register contract which contains the WL
            if (!IRegister(register).isWhitelisted(msg.sender)) revert Vault__UserNotWhiteListed();
        }

        address _poolAddr = _poolIdToAddress[poolId];
        LiveFun(_poolAddr);
        uint buyFeeLpTokens;

        // get owner of the pool - we  need this address to credit the trade with the userpurchase value and
        // to allocat his fee share to this address
        // quesry the pool the mint amounts - we provide the totalsupplybase, too and the number of tokens to mint
        // we get the token amounts ecesary for the buy, the number of lp tokens issued as buy fee and the number of LPs added by the trailing fee
        // we will need to mint all the fee tokens for them to be claimable
        (amountsToSpend, buyFeeLpTokens, /*trailingFeeLpTokens*/) = IPool(_poolAddr)._mint(LPTokensRequested, poolStates[_poolAddr].totalSupplyBase);

        address[] memory tokens = IPool(_poolAddr).getTokens();
        if (tokens.length != amountsMaxSpend.length) revert Vault__ArrayMismatch();
        // we loop through the tokens in the pool and try to deposit the necessary balances
        // to the pool or move from user internal balance to pool internal balance
        for (uint i = 0; i < tokens.length; i++) {
            if (amountsToSpend[i] > amountsMaxSpend[i]) revert Vault__MaxMintSlippageExceeded(); // MAX SLIPPAGE EXCEEDED
            if (!tokenInPool[_poolAddr][tokens[i]]) revert Vault__TokenNotInPool(tokens[i]);
            if (fromInternalBalance) {
                // Transfer token from User's internal balance to Pool's internal balance
                _transferInternalBalance(tokens[i], msg.sender, _poolAddr, amountsToSpend[i]);
            }
            else {
                // Transfer token from User's wallet to Pool's internal balance
                _depositToInternalBalance(tokens[i], msg.sender, _poolAddr, amountsToSpend[i], true);
            }
        }

        // dont allow users to get referrals this way, only the swaps contract can buy LP tokens to an address different from his
        // with the referredBy field set, so users can only set their own referrals
        if (msg.sender != swapsContract && to != msg.sender) referredBy = address(0);

        // we register the purchase in the affiliate system
        if (poolStates[_poolAddr].feeless) {
            _registerUser(to, referredBy);
            _mintToInternalBalance(_poolAddr, to, LPTokensRequested, true, true);
        } else {
            address trader = IPool(_poolAddr).owner();
            if (usdValue > 0 && msg.sender != swapsContract) revert Vault__OnlySwapsCanSendUsd();
            _registerUserPurchase(to, referredBy, trader, tokens, amountsToSpend, usdValue);

            (uint trailing, uint performance) = _calculateTrailingAndPerformanceFee(_poolAddr, true, false);
            if (trailing > 0) IFees(fees).allocateTrailingFee(_poolAddr, trader, trailing, poolStates[_poolAddr].totalSupplyBase.amount, tx.origin);
            if (performance > 0) IFees(fees).allocatePerformanceFee(_poolAddr, trader, performance, poolStates[_poolAddr].totalSupplyBase.amount, tx.origin);
            _mintToInternalBalance(_poolAddr, fees, trailing + performance + buyFeeLpTokens, true, true);

            IFees(fees).allocateBuyFee(_poolAddr, to, trader, buyFeeLpTokens);
            _mintToInternalBalance(_poolAddr, to, LPTokensRequested, true, true);
        }

        emit Minted(poolId, msg.sender, to, LPTokensRequested, tokens, amountsToSpend, fromInternalBalance);
        return amountsToSpend;
    }

    // This function is called when a liquidity provider removes liquidity from the pool.
    // It burns the liquidity tokens and sends back the tokens as ERC20 transfer.
    // If toInternalBalance is true, the tokens will be deposited to user's internal balance
    error Vault__BurnTxExpired();
    error Vault__CantBurnZero();
    error Vault__OnlySwaptMaySetFrom();
    error Vault__MaxBurnSlippageExceeded();
    function Burn(uint32 poolId, uint LPTokensToBurn, uint[] memory amountsMinReceive, bool toInternalBalance, uint deadline, address from) external virtual nonReentrant returns (uint[] memory amountsReceived){
        if (block.timestamp > deadline) revert Vault__BurnTxExpired(); // Transaction expired
        if (LPTokensToBurn == 0) revert Vault__CantBurnZero(); // LPTokensToBurn CANNOT BE 0
        if (from != msg.sender && msg.sender != swapsContract) revert Vault__OnlySwaptMaySetFrom(); // ONLY SWAPS

        address _poolAddr = _poolIdToAddress[poolId];
        LiveFun(_poolAddr);
        address[] memory tokens = IPool(_poolAddr).getTokens();
        (uint[] memory amountsToReceive, uint trailingFeeLpTokens) = IPool(_poolAddr)._burn(LPTokensToBurn, poolStates[_poolAddr].totalSupplyBase);

        for (uint i = 0; i < tokens.length; i++) {
            if (amountsToReceive[i] < amountsMinReceive[i]) revert Vault__MaxBurnSlippageExceeded(); // MAX SLIPPAGE EXCEEDED
            if (toInternalBalance) {
                // Transfer token from Pool's internal balance to User's internal balance
                _transferInternalBalance(tokens[i], _poolAddr, msg.sender, amountsToReceive[i]);
            }

            else {
                // Transfer token from Pool's internal balance to User's wallet
                _withdrawFromInternalBalance(tokens[i], _poolAddr, msg.sender, amountsToReceive[i]);
            }
        }
        //Allow from parameter when the caller is the swap contract, other case ignore it and use the msg.sender

        if (poolStates[_poolAddr].feeless) {
            _burnFromInternalBalance(_poolAddr, msg.sender, LPTokensToBurn, true, true);
        } else {
            address trader = IPool(_poolAddr).owner();
            (uint trailing, uint performance) = _calculateTrailingAndPerformanceFee(_poolAddr, true, false);
            IFees(fees).allocateTrailingFee(_poolAddr, trader, trailing, poolStates[_poolAddr].totalSupplyBase.amount, tx.origin);
            IFees(fees).allocatePerformanceFee(_poolAddr, trader, performance, poolStates[_poolAddr].totalSupplyBase.amount, tx.origin);
            _mintToInternalBalance(_poolAddr, fees, trailing + performance, true, true);
            _burnFromInternalBalance(_poolAddr, msg.sender, LPTokensToBurn, true, true);
        }

        emit Burned(poolId, msg.sender, from, LPTokensToBurn, tokens, amountsToReceive, toInternalBalance);
        return amountsToReceive;
    }


    /************************************************************************************/
    /* Swap                                                                             */
    /************************************************************************************/

    // Executes a swap operation on a single Pool. Called by the user
    // If the swap is initiated with givenInOrOut == 1 (i.e., the number of tokens to be sent to the Pool is specified),
    // it returns the amount of tokens taken from the Pool, which should not be less than limit.
    // If the swap is initiated with givenInOrOut == 0 parameter (i.e., the number of tokens to be taken from the Pool is specified),
    // it returns the amount of tokens sent to the Pool, which should not exceed limit.
    // Emits a Swap event
    error Vault__SwapTxExpired();
    error Vault__CantSwapTheSameToken();
    error Vault__CantSwapPoolToken();
    error Vault__CantSwapZero();
    error Vault__CantSellNonWhitelistedToken();
    function swap(address poolAddress, bool givenInOrOut, address tokenIn, address tokenOut, uint amount, bool fromInternalBalance, uint limit, uint64 deadline) public virtual returns (uint calculatedAmount) { // nonReentrant returns (uint calculatedAmount) {
        _delegateCall(vaultLib);
    }

    // Execute a multi-hop token swap between multiple pairs of tokens on their corresponding pools
    // Example: 100 tokenA -> tokenB -> tokenC
    // pools = [pool1, pool2], tokens = [tokenA, tokenB, tokenC], amountIn = 100
    // The returned amount of tokenC should not be less than limit
    function multiSwap(address[] memory pools, address[] memory tokens, uint amountIn, bool fromInternalBalance, uint limit, uint64 deadline) external virtual returns (uint calculatedAmount) {
        _delegateCall(vaultLib);
    }

    /************************************************************************************/
    /* Dutch Auction                                                                    */
    /************************************************************************************/

    function getAuctionInfo(uint auctionId) external virtual view returns (AuctionInfo memory) {
        return auctions[auctionId];
    }

    function isRunning(uint auctionId) external virtual view returns (bool) {
        uint _expiryTime = auctions[auctionId].startsAt + auctions[auctionId].duration;
       if (auctions[auctionId].remainingAmount == 0 || _expiryTime < block.timestamp) {
            return false;
        }
        return true;
    }

    function startAuction(address tokenToSell, uint amountToSell, address tokenToBuy, uint32 duration, uint32 expiration, uint endingPrice) external virtual returns (uint auctionId) {
        _delegateCall(vaultLib);
    }

    // pool address can call this
    function stopAuction(uint auctionId) external virtual {
        _delegateCall(vaultLib);
    }

    function getBidPriceAt(uint auctionId, uint32 _now) public virtual view returns (uint currentPrice, uint remainingAmount) {
        return _getBidPrice(auctionId, _now);
    }

    function getBidPrice(uint auctionId) public virtual view returns (uint currentPrice, uint remainingAmount) {
        return _getBidPrice(auctionId, uint32(block.timestamp));
    }

    function _getBidPrice(uint auctionId, uint32 _now) internal view returns (uint currentPrice, uint remainingAmount) {
        uint32 _start = auctions[auctionId].startsAt;
        uint32 _duration = auctions[auctionId].duration;
        uint32 _expiration = auctions[auctionId].expiration;
        remainingAmount = auctions[auctionId].remainingAmount;
        uint64 _end = _start + _duration + _expiration;
        uint32 _elapsed = _now - _start;             // Reverts if _now < _start

        if (_elapsed > _duration) {
            _elapsed = _duration;
        }
        if (_now >= _end || remainingAmount == 0) {
             return (0, 0);
        }

        uint _startingPrice = auctions[auctionId].startingPrice;
        uint _endingPrice = auctions[auctionId].endingPrice;
        uint _startingAmount = auctions[auctionId].startingAmount;

        uint _delta = (_startingPrice - _endingPrice) * _elapsed / _duration;
        currentPrice = (_startingPrice - _delta) * remainingAmount / _startingAmount;
    }

    // Place a bid for the specified 'auctionId'. Fractional bids are supported, with the 'amount'
    // representing the number of tokens to purchase. The amounts are deducted from and credited to the
    // user's internal balance. If there are insufficient tokens in the user's internal balance, the function reverts.
    // If there are fewer tokens available for the auction than the specified 'amount' and enableLessAmount == 1,
    // the function purchases all remaining tokens (which may be less than the specified amount).
    // If enableLessAmount is set to 0, the function reverts.
    function bid(uint auctionId, uint amount, bool enableLessAmount, bool fromInternalBalance, uint deadline) external virtual returns (uint spent) {
        _delegateCall(vaultLib);
    }

    //Handling the mint/burn/transfers on poolOfUsers array to track the owned baskets
    function _handlerForPoolOfUser(address user, address poolAddr, bool up) internal {
        if (vaultState.userPoolTrackingDisabled) return;
        uint32 poolId = _poolAddressToId[poolAddr];
        if (poolId == 0) return;
        if (up && _internalBalance[user][poolAddr] > 0)
        {
            uint index = poolOfUserIndexes[user][poolId];
            if(index == 0)
            {
                // First deposit for the user. Add pool address to user's joined pool list
                poolOfUser[user].push(poolId);
                //save the index for the new array item
                poolOfUserIndexes[user][poolId] = (poolOfUser[user].length).toUint32();
            }
        } else if (!up && _internalBalance[user][poolAddr] == 0) {
            // direction is down and we hit the bottom, so we remove the address
            uint index = poolOfUserIndexes[user][poolId];
            // User exited completely. Remove poolId from user's joined pool list
            if(index > 0){
                // pop would revert if length = 0 so no need for math checking here, save some gas
                unchecked {
                    index--;
                    uint32 replacementPoolId = poolOfUser[user][poolOfUser[user].length - 1];
                    poolOfUserIndexes[user][replacementPoolId] = uint32(index);
                    poolOfUser[user][index] = replacementPoolId;
                    poolOfUser[user].pop();
                    poolOfUserIndexes[user][poolId] = 0;
                }
            }
        }
    }

    // /************************************************************************************/
    // /* Flash Loan                                                                       */
    // /************************************************************************************/
    // // https://eips.ethereum.org/EIPS/eip-3156

    error Vault__FlashAmountTooHigh();
    error Vault__FlashTransferFailed();
    error Vault__FlashTransferIrregular();
    error Vault__FlashCallbackFailed();
    error Vault__FlashRepayFailed();
    error Vault__FlashRepayIrregular();

    function flashLoan(
        IERC3156FlashBorrower receiver,
        address token,
        uint256 amount,
        bytes calldata data
    ) external virtual override returns(bool) {
        _delegateCall(vaultLib);
    }

    /**
     * @dev The fee to be charged for a given loan.
     * @param token The loan currency.
     * @param amount The amount of tokens lent.
     * @return The amount of `token` to be charged for the loan, on top of the returned principal.
     */
    function flashFee(
        address token,
        uint256 amount
    ) external view virtual override returns (uint256) {
        return _flashFee(amount);
    }

    /**
     * @dev The fee to be charged for a given loan. Internal function with no checks.
     * @param amount The amount of tokens lent.
     * @return The amount of `token` to be charged for the loan, on top of the returned principal.
     */
    function _flashFee(
        uint256 amount
    ) internal virtual view returns (uint256) {
        return zeroFee[msg.sender] ? 0 : (amount * vaultState.flashFee) / 10000;
    }

    /**
     * @dev The amount of currency available to be lent.
     * @param token The loan currency.
     * @return The amount of `token` that can be borrowed.
     */
    function maxFlashLoan(
        address token
    ) external virtual view override returns (uint256) {
        return IERC20(token).balanceOf(address(this)) * 49 / 100;
    }


    // Emergency withdraw. Functions in both pool-specific and global recovery modes.
    function emergencyWithdraw(address poolAddress, address _user, bool internalBalance) external virtual {
        _delegateCall(vaultLib);
    }

    // Once a year has passed since the emergency shutdown was triggered, the admin can recover lost funds.
    function emergencyWithdrawAll(address _token, address _to, uint _amount) external virtual {
        _delegateCall(vaultLib);
    }

    // Once a year has passed since the emergency shutdown was triggered, the admin can recover lost funds from a specific pool.
    function emergencyWithdrawPool(address _pool, address _token, address _to, uint _amount) external virtual {
        _delegateCall(vaultLib);
    }
}
