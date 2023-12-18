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
// OpenZeppelin Contracts (last updated v4.8.0) (security/ReentrancyGuard.sol)

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
// OpenZeppelin Contracts (last updated v4.8.0) (token/ERC20/utils/SafeERC20.sol)

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
        // we're implementing it ourselves. We use {Address-functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (utils/Address.sol)

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
// OpenZeppelin Contracts (last updated v4.6.0) (utils/math/SafeMath.sol)

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
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
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
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
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
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}
//SPDX-License-Identifier: MIT

pragma solidity 0.8.11;

interface IBURN {
    function mint(address to, uint256 amount) external;
    function burn(uint256 amount) external;
}
// SPDX-License-Identifier: MIT

pragma solidity 0.8.11;

interface IDexFactory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
    function getPair(address tokenA, address tokenB) external view returns (address pair);
}// SPDX-License-Identifier: MIT

pragma solidity 0.8.11;

interface IDexRouter {
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

    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
}
//SPDX-License-Identifier: MIT

pragma solidity 0.8.11;

interface IZKGapGainV1 {
    function pinUsers(uint) external view returns (address);
    function pinBurned(uint) external view returns (bool);
    function pinClaimed(uint) external view returns (bool);
    function hasPined(address) external view returns (bool);
    function refUsers(address) external view returns (address);
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/cryptography/MerkleProof.sol)

pragma solidity ^0.8.0;

/**
 * @dev These functions deal with verification of Merkle Trees proofs.
 *
 * The proofs can be generated using the JavaScript library
 * https://github.com/miguelmota/merkletreejs[merkletreejs].
 * Note: the hashing algorithm should be keccak256 and pair sorting should be enabled.
 *
 * See `test/utils/cryptography/MerkleProof.test.js` for some examples.
 */
library MerkleProof {
    /**
     * @dev Returns true if a `leaf` can be proved to be a part of a Merkle tree
     * defined by `root`. For this, a `proof` must be provided, containing
     * sibling hashes on the branch from the leaf to the root of the tree. Each
     * pair of leaves and each pair of pre-images are assumed to be sorted.
     */
    function verify(
        bytes32[] memory proof,
        bytes32 root,
        bytes32 leaf
    ) internal pure returns (bool) {
        return processProof(proof, leaf) == root;
    }

    /**
     * @dev Returns the rebuilt hash obtained by traversing a Merklee tree up
     * from `leaf` using `proof`. A `proof` is valid if and only if the rebuilt
     * hash matches the root of the tree. When processing the proof, the pairs
     * of leafs & pre-images are assumed to be sorted.
     *
     * _Available since v4.4._
     */
    function processProof(bytes32[] memory proof, bytes32 leaf) internal pure returns (bytes32) {
        bytes32 computedHash = leaf;
        for (uint256 i = 0; i < proof.length; i++) {
            bytes32 proofElement = proof[i];
            if (computedHash <= proofElement) {
                // Hash(current computed hash + current element of the proof)
                computedHash = keccak256(abi.encodePacked(computedHash, proofElement));
            } else {
                // Hash(current element of the proof + current computed hash)
                computedHash = keccak256(abi.encodePacked(proofElement, computedHash));
            }
        }
        return computedHash;
    }
}// SPDX-License-Identifier: MIT

pragma solidity 0.8.11;

import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "./libraries/MerkleProof.sol";
import "./interfaces/IBURN.sol";
import "./interfaces/IZKGapGainV1.sol";
import {IDexRouter} from "./interfaces/IDexRouter.sol";
import {IDexFactory} from "./interfaces/IDexFactory.sol";

contract ZKGapGainV3 is Ownable, ReentrancyGuard {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    using Address for address;

    bytes32 burnMerkleRoot;
    bytes32 claimMerkleRoot;

    bool public stopPin;
    bool public stopBurn;
    bool public stopClaim;
    bool public stopClaimPinCommission;

    // fee and burn/pin amount
    uint256 public feeBurnPercent = 250;    // 2.5% (250 / 10000)
    uint256 public burnAmount = 205 * 10 ** 18;
    uint256 public feeAmount = 5 * 10 ** 18;

    // claim fee
    uint256 public claimFee = 5 * 10 ** 18; // 5 USDT
    // Commission Percent
    uint256 public pinCommissionPercentage = 0;
    // Address Configs
    address public zkGapGainV1 = 0x7c3862A7D7Ef2eeBEC21EA521141A62722a1F0D5;
    address public zkGapGainV2 = 0xC9F8562d5161c5363D199Ad1741fAa2e502E6DE3;
    address public tokenFees = 0x55d398326f99059fF775485246999027B3197955; // USDT
    address public WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address public routerAddress = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address public tokenBurn;

    address public teamAddress = 0x6A1C9ecB8334F0e07480AF91E3E3b4Dc236eF4a8;
    address public cexListingAddress = 0xF9AeD6528E77d0b01a89c1ffdD94d2dDC6fd5514;
    uint256 public teamPercent = 500; // 5%
    uint256 public cexListingPercent = 600; // 6%
    uint256 public burnToEarnPercent = 6500; // 65%

    // Constant
    uint private constant PERCENT_UNIT = 10000;
    address public constant NATIVE_ADDRESS = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;
    address public constant DEAD_ADDRESS = 0x000000000000000000000000000000000000dEaD;

    // Pin Storage
    uint256 public pinNonce = 0;
    mapping(uint => address) public pinUsers;
    mapping(uint => bool) public pinBurned;
    mapping(uint => bool) public pinClaimed;
    mapping(address => bool) public hasPined;

    // Commission Storage
    mapping(address => uint256) public pinCommissionClaimed;
    mapping(address => uint256) public pinCommission;

    IDexRouter public router;

    // other storages
    mapping(address => address) public refUsers;
    mapping(address => bool) public isBotKeeper;

    // Structs
    struct ClaimRewardParams {
        bytes32[] merkleProof;
        uint pinId;
        uint amount;
    }

    struct BurnParams {
        bytes32[] merkleProof;
        uint pinId;
        uint amountOutMin;
    }

    struct UpdatePinV1Params {
        uint pinId;
        bool claimStatus;
    }

    // Events
    event FeeAmountUpdated(address token, uint256 fee);
    event BurnAmountUpdated(address token, uint256 amount);
    event RecoverToken(address token, uint256 amount);
    event RefUpdated(address indexed user, address indexed refAddress);
    event PinEvent(
        address indexed user,
        uint indexed pinId,
        uint256 amount,
        uint256 amountZKGAP,
        uint256 amountZKGAPCommission
    );
    event BurnEvent(address indexed user, uint indexed pinId, uint256 burnAmount, uint feeAmount);
    event ClaimEvent(address indexed user, uint indexed pinId, uint amount, uint tokenBurnAmountForUser, uint claimFeeAmount, uint teamAmount, uint cexListingAmount);
    event UpdateStatus(bool stopPin, bool stopBurn, bool stopClaim);
    event ZkgapClaimPinCommission(address indexed user, uint256 commissionAmount);

    constructor(address _tokenBurn, uint nonce) {
        router = IDexRouter(routerAddress);
        tokenBurn = _tokenBurn;
        pinNonce = nonce;
    }

    // ====================================== Modifiers ============================================

    modifier onlyBotKeeper() {
        require(isBotKeeper[msg.sender], "onlyBotKeeper: Is not keeper");
        _;
    }

    // ================================ Public View function ======================================

    function getRefUsers(address acc) public view returns (address) {
        return refUsers[acc] != address(0)
            ? refUsers[acc]
            : IZKGapGainV1(zkGapGainV2).refUsers(acc) != address(0)
                    ? IZKGapGainV1(zkGapGainV2).refUsers(acc)
                    : IZKGapGainV1(zkGapGainV1).refUsers(acc);
    }

    function checkPinIsClaimed(uint _pinId) public view returns (bool) {
        return pinClaimed[_pinId] || IZKGapGainV1(zkGapGainV1).pinClaimed(_pinId) || IZKGapGainV1(zkGapGainV2).pinClaimed(_pinId);
    }

    function checkPinIsBurned(uint _pinId) public view returns (bool){
        return pinBurned[_pinId] || IZKGapGainV1(zkGapGainV1).pinBurned(_pinId) || IZKGapGainV1(zkGapGainV2).pinBurned(_pinId);
    }

    function getPinUser(uint _pinId) public view returns (address){
        return pinUsers[_pinId] != address(0)
            ? pinUsers[_pinId]
            : IZKGapGainV1(zkGapGainV2).pinUsers(_pinId) != address(0)
                    ? IZKGapGainV1(zkGapGainV2).pinUsers(_pinId)
                    : IZKGapGainV1(zkGapGainV1).pinUsers(_pinId);
    }

    function isHasPined(address _acc) public view returns (bool) {
        return hasPined[_acc] || IZKGapGainV1(zkGapGainV1).hasPined(_acc) || IZKGapGainV1(zkGapGainV2).hasPined(_acc);
    }

    // ==================================== User function ==========================================

    function claimPinCommission() external nonReentrant {
        require(!stopClaimPinCommission,"ZKGapGain: Claim is not ready!");
        uint256 _commissionRemain = pinCommission[msg.sender] - pinCommissionClaimed[msg.sender];
        require(_commissionRemain > 0, "ZKGapGain: No Commission!");
        IERC20(tokenBurn).safeTransfer(address(msg.sender), _commissionRemain);
        pinCommissionClaimed[msg.sender] += _commissionRemain;
        emit ZkgapClaimPinCommission(msg.sender, _commissionRemain);
    }

    function pinBatchHandle(uint _time, uint _amountOutMin, address _refAddress) external nonReentrant {
        // set ref
        if (_checkRefExist(_refAddress)) {
            refUsers[msg.sender] = _refAddress;

            emit RefUpdated(msg.sender, _refAddress);
        }

        if (!hasPined[msg.sender]) {
            hasPined[msg.sender] = true;
        }

        for (uint i = 0; i < _time; i++) {
            _pinHandle(_amountOutMin);
        }
    }

    function _checkRefExist(address _refAddress) internal returns (bool) {
        if (
            getRefUsers(msg.sender) == address(0) &&
            _refAddress != address(msg.sender)
            && _refAddress != address(0) &&
            isHasPined(_refAddress)
        ) {
            return true;
        }
        return false;
    }

    // Burn token (batch) to receive reward
    function burnBatchHandle(BurnParams[] calldata _params) external nonReentrant {
        for (uint _i; _i < _params.length; _i++) {
            _burnHandle(_params[_i].merkleProof, _params[_i].pinId, _params[_i].amountOutMin);
        }
    }

    // Burn token to receive reward
    function burnHandle(BurnParams calldata _params) external nonReentrant {
        _burnHandle(_params.merkleProof, _params.pinId, _params.amountOutMin);
    }

    function claimRewardBatch(ClaimRewardParams[] calldata _params) external nonReentrant {
        for (uint _i; _i < _params.length; _i++) {
            _claimReward(_params[_i].merkleProof, _params[_i].pinId, _params[_i].amount);
        }
    }

    function claimReward(ClaimRewardParams calldata _params) external nonReentrant {
        _claimReward(_params.merkleProof, _params.pinId, _params.amount);
    }

    function getTokenBurnAmount(uint256 _tokenFeeAmount) public view returns (uint256) {
        address factory = router.factory();
        address pair = IDexFactory(factory).getPair(tokenFees, tokenBurn);
        return _tokenFeeAmount * IERC20(tokenBurn).balanceOf(pair) / IERC20(tokenFees).balanceOf(pair);
    }

    // ================================== Bot Keeper Functions =======================================

    function adminSetMerkleRoot(bytes32 _burnMerkleRoot, bytes32 _claimMerkleRoot) external onlyBotKeeper {
        burnMerkleRoot = _burnMerkleRoot;
        claimMerkleRoot = _claimMerkleRoot;
    }

    // ====================================== Admin Functions ========================================
    function updatePinV1(UpdatePinV1Params[] memory _params) external onlyOwner {
        for (uint _i; _i < _params.length; _i++) {
            pinClaimed[_params[_i].pinId] = _params[_i].claimStatus;
        }
    }

    function updatePinCommissionPercentage(uint256 _pinCommissionPercentage) external onlyOwner {
        pinCommissionPercentage = _pinCommissionPercentage;
    }

    function updateAddressConfigs(address _tokenFees, address _tokenBurn, address _WBNB, address _routerAddress) external onlyOwner {
        tokenFees = _tokenFees;
        tokenBurn = _tokenBurn;
        WBNB = _WBNB;
        routerAddress = _routerAddress;
        router = IDexRouter(_routerAddress);
    }

    function updateStatus(bool _stopPin, bool _stopBurn, bool _stopClaim,bool _stopClaimPinCommission) external onlyOwner {
        stopPin = _stopPin;
        stopBurn = _stopBurn;
        stopClaim = _stopClaim;
        stopClaimPinCommission = _stopClaimPinCommission;

        emit UpdateStatus(_stopPin, _stopBurn, _stopClaim);
    }

    function updateNonce(uint _nonce) external onlyOwner {
        pinNonce = _nonce;
    }

    function updateRef(address _user, address _refAddress) external onlyOwner {
        refUsers[_user] = _refAddress;
        emit RefUpdated(_user, _refAddress);
    }

    function setFeeBurnPercent(uint _percent) external onlyOwner {
        require(_percent < PERCENT_UNIT, 'INVALID PERCENT');
        feeBurnPercent = _percent;
    }

    function setTokenFee(address _token, uint256 _fee) external onlyOwner {
        tokenFees = _token;
        feeAmount = _fee;
        emit FeeAmountUpdated(_token, _fee);
    }

    function setTokenBurn(address _token, uint _amount) external onlyOwner {
        tokenBurn = _token;
        burnAmount = _amount;

        emit BurnAmountUpdated(_token, _amount);
    }

    function setBotKeeper(address _account, bool _status) external onlyOwner {
        isBotKeeper[_account] = _status;
    }

    function setClaimFee(uint256 _fee) external onlyOwner {
        claimFee = _fee;
    }

    function setTokenomics(address _teamAddress, uint256 _teamPercent, address _cexListingAddress, uint256 _cexListingPercent, uint256 _burnToEarnPercent) external onlyOwner {
        teamAddress = _teamAddress;
        teamPercent = _teamPercent;

        cexListingAddress = _cexListingAddress;
        cexListingPercent = _cexListingPercent;
        burnToEarnPercent = _burnToEarnPercent;
    }

    // Allows the owner to recover tokens sent to the contract by mistake
    function recoverToken(address _token, uint256 _amount) external onlyOwner {
        if (_token == NATIVE_ADDRESS) {
            require(_amount <= address(this).balance, "INSUFFICIENT BALANCE");
            payable(address(msg.sender)).transfer(_amount);
        } else {
            uint256 balance = IERC20(_token).balanceOf(address(this));
            require(_amount <= balance, "Operations: Cannot recover zero balance");

            IERC20(_token).safeTransfer(address(msg.sender), _amount);
        }
        emit RecoverToken(_token, _amount);
    }

    // ================================= Internal Functions ======================================

    function _claimReward(bytes32[] calldata _merkleProof, uint _pinId, uint _amount) internal {
        require(!stopClaim, "STOP CLAIM");
        require(_verifyClaim(_merkleProof, _pinId, _amount), 'INVALID MERKLE PROOF');

        uint256 amountForUser = getTokenBurnAmount(_amount);
        uint256 claimFeeAmount = getTokenBurnAmount(claimFee);

        uint256 amountForUserAfterFee = amountForUser - claimFeeAmount;

        uint256 amountForTeam = teamPercent * amountForUser / burnToEarnPercent;
        uint256 amountForCexListing = cexListingPercent * amountForUser / burnToEarnPercent;

        IBURN(tokenBurn).mint(msg.sender, amountForUserAfterFee);
        IBURN(tokenBurn).mint(address(this), claimFeeAmount);
        IBURN(tokenBurn).mint(teamAddress, amountForTeam);
        IBURN(tokenBurn).mint(cexListingAddress, amountForCexListing);

        delete (pinUsers[_pinId]);
        pinClaimed[_pinId] = true;

        emit ClaimEvent(msg.sender, _pinId, _amount, amountForUserAfterFee, claimFeeAmount, amountForTeam, amountForCexListing);
    }

    function _burnHandle(bytes32[] calldata _merkleProof, uint256 _pinId, uint _amountOutMin) internal {
        require(!stopBurn, "STOP BURN");
        require(_verifyBurn(_merkleProof, _pinId), 'INVALID MERKLE PROOF');

        // swap back token and burn
        uint _receiveAmount = _swapBackToken(burnAmount, _amountOutMin);
        uint _burnAmount = _receiveAmount * (PERCENT_UNIT - feeBurnPercent) / PERCENT_UNIT;
        IBURN(tokenBurn).burn(_burnAmount);

        pinBurned[_pinId] = true;

        emit BurnEvent(
            msg.sender,
            _pinId,
            _burnAmount,
            _receiveAmount - _burnAmount
        );
    }

    // check user can claim reward
    function _verifyClaim(bytes32[] calldata _merkleProof, uint _pinId, uint _amount) private view returns (bool) {
        require(!checkPinIsClaimed(_pinId), 'PIN CLAIMED BEFORE');
        require(getPinUser(_pinId) == msg.sender, 'NOT PIN OWNER');
        require(checkPinIsBurned(_pinId), 'PIN IS NOT BURNED');

        bytes32 leaf = keccak256(abi.encodePacked(msg.sender, _pinId, _amount));
        return MerkleProof.verify(_merkleProof, claimMerkleRoot, leaf);
    }

    // check _pinId and sender is valid
    function _verifyBurn(bytes32[] calldata _merkleProof, uint _pinId) private view returns (bool) {
        require(getPinUser(_pinId) == msg.sender, 'NOT PIN OWNER');
        require(!checkPinIsBurned(_pinId), 'PIN BURNED BEFORE');

        bytes32 leaf = keccak256(abi.encodePacked(msg.sender, _pinId));
        return MerkleProof.verify(_merkleProof, burnMerkleRoot, leaf);
    }

    function _pinHandle(uint _amountOutMin) internal {
        // buy back token to pin
        require(!stopPin, "STOP PIN");
        uint amountOut = _swapBackToken(feeAmount, _amountOutMin);
        pinUsers[pinNonce] = msg.sender;

        // Handle Pin Commission
        uint256 commissionAmount = _handlePinCommission(msg.sender, amountOut);
        emit PinEvent(msg.sender, pinNonce++, feeAmount, amountOut, commissionAmount);
    }

    function _handlePinCommission(address _userId, uint256 _amountZKGAP) internal returns (uint256) {
        address upline = getRefUsers(_userId);
        if(upline == address(0)) return 0;
        uint256 commissionAmount = (_amountZKGAP * pinCommissionPercentage) / PERCENT_UNIT;
        pinCommission[upline] += commissionAmount;
        return commissionAmount;
    }

    // swap tokenFees to tokenBurn and return amountOut
    function _swapBackToken(uint _amount, uint _amountOutMin) internal returns (uint) {
        IERC20(tokenFees).safeTransferFrom(address(msg.sender), address(this), _amount);
        IERC20(tokenFees).approve(routerAddress, _amount);

        address[] memory path = new address[](2);
        path[0] = tokenFees;
        path[1] = tokenBurn;

        uint balance = IERC20(tokenBurn).balanceOf(address(this));

        router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            _amount,
            _amountOutMin,
            path,
            address(this),
            block.timestamp + 3600
        );

        return IERC20(tokenBurn).balanceOf(address(this)) - balance;
    }
}
