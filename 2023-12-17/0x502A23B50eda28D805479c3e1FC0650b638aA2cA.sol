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
// OpenZeppelin Contracts (last updated v4.7.0) (utils/math/Math.sol)

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
        return a >= b ? a : b;
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
    function mulDiv(
        uint256 x,
        uint256 y,
        uint256 denominator
    ) internal pure returns (uint256 result) {
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
                return prod0 / denominator;
            }

            // Make sure the result is less than 2^256. Also prevents denominator == 0.
            require(denominator > prod1);

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
    function mulDiv(
        uint256 x,
        uint256 y,
        uint256 denominator,
        Rounding rounding
    ) internal pure returns (uint256) {
        uint256 result = mulDiv(x, y, denominator);
        if (rounding == Rounding.Up && mulmod(x, y, denominator) > 0) {
            result += 1;
        }
        return result;
    }

    /**
     * @dev Returns the square root of a number. It the number is not a perfect square, the value is rounded down.
     *
     * Inspired by Henry S. Warren, Jr.'s "Hacker's Delight" (Chapter 11).
     */
    function sqrt(uint256 a) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        // For our first guess, we get the biggest power of 2 which is smaller than the square root of the target.
        // We know that the "msb" (most significant bit) of our target number `a` is a power of 2 such that we have
        // `msb(a) <= a < 2*msb(a)`.
        // We also know that `k`, the position of the most significant bit, is such that `msb(a) = 2**k`.
        // This gives `2**k < a <= 2**(k+1)` → `2**(k/2) <= sqrt(a) < 2 ** (k/2+1)`.
        // Using an algorithm similar to the msb conmputation, we are able to compute `result = 2**(k/2)` which is a
        // good first aproximation of `sqrt(a)` with at least 1 correct bit.
        uint256 result = 1;
        uint256 x = a;
        if (x >> 128 > 0) {
            x >>= 128;
            result <<= 64;
        }
        if (x >> 64 > 0) {
            x >>= 64;
            result <<= 32;
        }
        if (x >> 32 > 0) {
            x >>= 32;
            result <<= 16;
        }
        if (x >> 16 > 0) {
            x >>= 16;
            result <<= 8;
        }
        if (x >> 8 > 0) {
            x >>= 8;
            result <<= 4;
        }
        if (x >> 4 > 0) {
            x >>= 4;
            result <<= 2;
        }
        if (x >> 2 > 0) {
            result <<= 1;
        }

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
        uint256 result = sqrt(a);
        if (rounding == Rounding.Up && result * result < a) {
            result += 1;
        }
        return result;
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/math/Math.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

/*
Maturation Days – the number of days that must elapse after a deposit before an investor can unstake without penalty (e.g., 90 days) 
Starting Burn Rate – the initial burn rate, which will decrease over time until Maturation (defaults to 20%) 
Reward Rate – a multiplier applied to the staking amount, used to calculate the reward tokens due to an investor at Maturation 
*/

contract PerpetualStaking is Ownable {
    using SafeERC20 for IERC20;

    address public immutable token; // Address of the token to be used for the stake
    uint256 public maturationPeriod; // The period of time (in seconds) that must elapse before an investor can unstake without penalty
    uint32 public immutable stakingFeeRate; // A percentage of the staking amount that is charged as a fee
    uint32 public immutable startingBurnRate; // The initial burn rate percentage, which will decrease over time until maturation
    uint32 public immutable rewardRate; // The percentage of the staking amount due to an investor if they stake for the entire maturation period    uint32 public immutable stakingFeeRate; // A percentage of the staking amount that is charged as a fee
    bool public paused;

    uint32 constant PRECISION = 1000; // Precision for percentage calculations
    uint32 constant DAY = 86_400; // Seconds in a day

    event StakeDeposited(
        address indexed staker, // Address of the investor who deposited the stake
        uint256 indexed stakeIndex, // Index of the stake that was deposited
        uint256 amount, // Net amount of stake tokens deposited after fees
        uint256 feesCharged // Fees charged
    );

    event StakeWithdrawn(
        address indexed staker, // Address of the investor who withdrew the stake
        uint256 indexed stakeIndex, // Index of the stake that was withdrawn
        uint256 stakeWithdrawn, // Amount of stake tokens withdrawn
        uint256 stakeBurnt // Amount of stake tokens burnt
    );

    event StakeRefunded(
        address indexed staker, // Address of the investor who withdrew the stake
        uint256 indexed stakeIndex, // Index of the stake that was withdrawn
        uint256 stakeRefunded // Amount of stake tokens refunded
    );

    event RewardClaimed(
        address indexed staker, // Address of the investor who claimed the reward
        uint256 indexed stakeIndex, // Index of the stake for which rewards were claimed
        uint256 amount // Amount of reward tokens claimed
    );

    /*
     * @notice Emitted when the paused state is changed
     */
    event PausedSet(
        bool value // New value of paused
    );

    struct Stake {
        uint256 amount; // Amount staked
        uint256 reward; // Total reward due at maturation
        address staker; // Address that made the stake
        uint256 startDate; // Date the stake was made
        uint256 maturationDate; // Date the stake matures
        uint256 dateWithdrawn; // Date the stake was withdrawn (0 if not withdrawn)
        uint256 totalRewardClaimed; // Total reward claimed so far
        uint256 stakeBurnt; // Total amount burnt on premature withdrawal
        uint256 stakingFee; // Amount of staking fee paid
    }

    // Mapping of investor address to array of stakes. Each investor can have multiple stakes.
    mapping(address => Stake[]) internal stakes;

    // Array of all investor addresses
    address[] investors;

    /*
     * @notice Constructor
     * @param token Address of the token to be used for the stake
     * @param maturationDays Number of days that must elapse after a deposit before an investor can unstake without penalty
     * @param startingBurnRate The initial burn rate, which will decrease over time until maturation. Precision 1000 (e.g., 2% = 2_000, 100% = 100_000)
     * @param rewardRate A multiplier applied to the staking amount, used to calculate the reward tokens due to an investor at maturation. Precision 1000 (e.g., 2% = 2_000, 100% = 100_000)
     */
    constructor(
        address token_,
        uint32 maturationDays_,
        uint32 startingBurnRate_,
        uint32 rewardRate_,
        uint32 stakingFeeRate_
    ) {
        require(token_ != address(0), "Token address cannot be 0");
        require(
            startingBurnRate_ <= PRECISION * 100,
            "Starting burn rate cannot be more than 100%"
        );
        require(
            stakingFeeRate_ <= PRECISION * 100,
            "Staking fee rate cannot be more than 100%"
        );
        require(maturationDays_ > 0, "Maturation days must be greater than 0");

        token = token_;
        maturationPeriod = maturationDays_ * DAY;
        startingBurnRate = startingBurnRate_;
        rewardRate = rewardRate_;
        stakingFeeRate = stakingFeeRate_;
    }

    function _getInvestorStake(
        address investor,
        uint256 index
    ) internal view stakeExists(investor, index) returns (Stake storage) {
        Stake storage stake = stakes[investor][index];
        return stake;
    }

    /*
     * @notice Get the caller's stake by index
     * @param index Index of the stake
     * @return Stake struct
     */
    function getStake(uint256 index) external view returns (Stake memory) {
        return _getInvestorStake(address(msg.sender), index);
    }

    /*
     * @notice Get the stake of an investor by index
     * @param investor Address of the investor
     * @param index Index of the stake
     * @return Stake struct
     */
    function getInvestorStake(
        address investor,
        uint256 index
    ) external view returns (Stake memory) {
        return _getInvestorStake(investor, index);
    }

    /*
     * @notice Get the number of stakes deposited by the caller
     * @return Number of stakes
     */
    function getStakeCount() public view returns (uint256) {
        return getInvestorStakeCount(address(msg.sender));
    }

    /*
     * @notice Get the number of stakes deposited by an investor
     * @param investor Address of the investor
     * @return Number of stakes
     */
    function getInvestorStakeCount(
        address investor
    ) public view returns (uint256) {
        return stakes[investor].length;
    }

    /*
     * @notice Get the number of investors
     * @return Number of investors
     */
    function getInvestorCount() public view returns (uint256) {
        return investors.length;
    }

    /*
     * @notice Get an investor's address by index
     * @param index Index of the investor
     * @return Address of the investor
     */
    function getInvestor(uint256 index) public view returns (address) {
        return investors[index];
    }

    /*
     * @notice Deposit a stake. The stake will be added to the caller's stakes array. It will include a maturation date which is the current date + maturationDays. Can only be called if the contract is not paused.
     * @param amount Amount to stake
     */
    function depositStake(uint256 amount) public notPaused {
        // Check that amount is not zero
        require(amount > 0, "Amount must be greater than zero");

        // Deduct the staking fee
        uint256 fee = Math.mulDiv(
            amount,
            stakingFeeRate,
            PRECISION * 100,
            Math.Rounding.Zero
        );
        uint256 netStakeAmount = amount - fee;

        // Calculate reward
        uint256 maturationDate = block.timestamp + maturationPeriod;

        // Calculate the maximum reward that could be earned if the stake is held until maturation
        uint256 reward = Math.mulDiv(
            netStakeAmount,
            rewardRate,
            PRECISION * 100,
            Math.Rounding.Zero
        );

        // Create a new stake record
        Stake memory stake = Stake(
            netStakeAmount, // Net amount staked
            reward, // Maximum reward due at maturation
            address(msg.sender), // Address that made the stake
            block.timestamp, // Date the stake was made
            maturationDate, // Date the stake matures
            0, // Date the stake was withdrawn (0 if not withdrawn)
            0, // Total reward claimed so far
            0, // Total amount burnt on premature withdrawal
            fee // Amount of staking fee paid
        );

        // Add the investor to the investors array if they are not already in it
        if (stakes[address(msg.sender)].length == 0) {
            investors.push(address(msg.sender));
        }
        // Add the new Stake to the stakes array
        stakes[address(msg.sender)].push(stake);

        // Transfer the amount from the staker to the contract
        IERC20(token).safeTransferFrom(
            address(msg.sender),
            address(this),
            netStakeAmount
        );

        // Transfer the fee to the owner address
        IERC20(token).safeTransferFrom(address(msg.sender), owner(), fee);

        emit StakeDeposited(
            address(msg.sender),
            stakes[address(msg.sender)].length - 1,
            netStakeAmount,
            fee
        );
    }

    /*
     * @notice Calculate the amount of tokens that could be returned on a stake. This function does not change the state of the contract.
     * @param investor Address of the investor
     * @param index Index of the stake
     * @return Amount of reward that would be claimed if the investor called claimReward(index)
     */
    function previewInvestorClaimReward(
        address investor,
        uint256 index
    ) public view returns (uint256) {
        // Get the stake
        Stake memory stake = _getInvestorStake(investor, index);

        uint256 rewardDueNow; // 0
        uint256 rewardablePeriod;

        // If the stake has been withdrawn, the rewardable period is:
        // Time of stake deposit to time of withdrawal or maturation date, whichever is earlier
        if (stake.dateWithdrawn > 0) {
            rewardablePeriod =
                Math.min(stake.dateWithdrawn, stake.maturationDate) -
                stake.startDate;
        }
        // If the stake has not been withdrawn, the rewardable period is:
        // Time of stake deposit to current time or maturation date, whichever is earlier
        else {
            rewardablePeriod =
                Math.min(block.timestamp, stake.maturationDate) -
                stake.startDate;
        }

        // Protect against division by 0 if the stake was withdrawn immediately
        if (rewardablePeriod == 0) {
            return 0;
        }

        // Calculate the reward due now, assuming no previous rewards have been claimed
        // Starts at 0 and increases linearly to the total reward amount over the maturation period
        rewardDueNow = Math.mulDiv(
            stake.reward,
            rewardablePeriod,
            maturationPeriod,
            Math.Rounding.Zero
        );

        // Return the reward due now minus the reward already claimed
        return rewardDueNow - stake.totalRewardClaimed;
    }

    /*
     * @notice Withdraw all rewards due on a stake. This function will calculate the amount of reward tokens due to the caller and transfer them to the caller's address.
     * @param index Index of the stake
     */
    function claimReward(uint256 index) public {
        // Get the stake
        uint256 rewardAmount = previewInvestorClaimReward(
            address(msg.sender),
            index
        );
        require(rewardAmount > 0, "No reward to claim");

        Stake storage stake = stakes[address(msg.sender)][index];
        stake.totalRewardClaimed += rewardAmount;
        _sendTokensTo(stake.staker, rewardAmount);

        emit RewardClaimed(stake.staker, index, rewardAmount);
    }

    /*
     * @notice Calculate the amount of tokens that would be withdrawn and burned on a stake. This function does not change the state of the contract.
     * @param investor Address of the investor
     * @param index Index of the stake
     * @return Amounts of tokens that would be withdrawn and would be burned if the investor called withdrawStake(index)
     */
    function previewInvestorWithdrawStake(
        address investor,
        uint256 index
    ) public view returns (uint256, uint256) {
        // Get the stake
        Stake memory stake = _getInvestorStake(investor, index);

        // Check that the stake has not already been withdrawn
        require(stake.dateWithdrawn == 0, "Stake has already been withdrawn");

        // Calculate the burn amount. Starting burn rate is 20% and decreases linearly to 0% at maturation
        uint256 burnAmount; // 0
        if (stake.maturationDate > block.timestamp) {
            uint256 maxBurn = Math.mulDiv(
                stake.amount,
                startingBurnRate,
                PRECISION * 100,
                Math.Rounding.Zero
            );
            uint256 timeRemaining = stake.maturationDate - block.timestamp;
            burnAmount = Math.mulDiv(
                maxBurn,
                timeRemaining,
                maturationPeriod,
                Math.Rounding.Zero
            );
        }
        // Calculate the amount to be withdrawn
        uint256 withdrawAmount = stake.amount - burnAmount;

        return (withdrawAmount, burnAmount);
    }

    /*
     * @notice Withdraw all tokens from a stake. Calculate the amount of tokens due to the caller and transfer them to the caller's address. It may also burn a percentage of the tokens, depending on how early the stake was withdrawn.
     * @param index Index of the stake
     */
    function withdrawStake(uint256 index) public {
        // Preview
        (
            uint256 withdrawAmount,
            uint256 burnAmount
        ) = previewInvestorWithdrawStake(address(msg.sender), index);
        Stake storage stake = stakes[address(msg.sender)][index];

        // Burn the burn amount by sending it to address 1
        if (burnAmount > 0) {
            _burnTokens(burnAmount);
            stake.stakeBurnt = burnAmount;
        }
        stake.dateWithdrawn = block.timestamp;

        // Send the remaining amount to the staker
        _sendTokensTo(stake.staker, withdrawAmount);

        emit StakeWithdrawn(stake.staker, index, withdrawAmount, burnAmount);
    }

    function _sendTokensTo(address recipient, uint256 amount) private {
        // If balance is less than the required amount, transfer some from the owner wallet
        uint256 balance = IERC20(token).balanceOf(address(this));
        if (balance < amount) {
            IERC20(token).safeTransferFrom(
                owner(),
                address(this),
                amount - balance
            );
        }
        IERC20(token).safeTransfer(recipient, amount);
    }
    
    function _burnTokens(uint256 amount) private {
        _sendTokensTo(address(1), amount);
    }

    function refundInvestorStake(
        address investor,
        uint256 index
    ) public onlyOwner stakeExists(investor, index) {
        // Get the stake record as storage
        Stake storage stake = stakes[investor][index];

        // Check that the stake has not already been withdrawn
        require(stake.dateWithdrawn == 0, "Stake has already been withdrawn");

        // Mark the stake as withdrawn
        stake.dateWithdrawn = block.timestamp;

        // Refund the stake
        _sendTokensTo(stake.staker, stake.amount);

        emit StakeRefunded(stake.staker, index, stake.amount);
    }

    /*
     * @notice returns the number of seconds remaining until the maturation date. Returns 0 if the stake has already been withdrawn or if the maturation date has passed.
     * @return Number of seconds remaining until the maturation date
     */
    function getTimeRemaining(uint256 index) public view returns (uint256) {
        Stake memory stake = _getInvestorStake(address(msg.sender), index);
        if (stake.dateWithdrawn > 0 || stake.maturationDate < block.timestamp) {
            return 0;
        }
        return stake.maturationDate - block.timestamp;
    }

    /*
     * @notice prevent any new stakes from being deposited
     */
    function setPaused(bool value) external onlyOwner {
        require(paused != value, "No change required");
        paused = value;
        emit PausedSet(value);
    }

    /*
     * @notice modifier to prevent functions from being called when the contract is paused
     */
    modifier notPaused() {
        require(!paused, "Contract is paused");
        _;
    }

    modifier stakeExists(address investor, uint256 index) {
        require(investor != address(0), "Investor address cannot be 0");
        require(stakes[investor].length > index, "Stake does not exist");
        _;
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;
import "./PerpetualStaking.sol";

contract PerpetualStaking180Days is PerpetualStaking {
    uint32 constant MATURATION_DAYS = 180;
    uint32 constant STARTING_BURN_RATE = 80_000; // 80%
    uint32 constant REWARD_RATE = 10_000; // 20% return over 12 months. For 6 months, that's 20% / 2 = 10%
    uint32 constant STAKING_FEE_RATE = 2500; // 2.5% staking fee
    constructor(address _tokenAddress) PerpetualStaking(_tokenAddress, MATURATION_DAYS, STARTING_BURN_RATE, REWARD_RATE, STAKING_FEE_RATE) {}
}