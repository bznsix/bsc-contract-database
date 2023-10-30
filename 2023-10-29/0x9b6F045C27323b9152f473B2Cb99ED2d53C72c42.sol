// SPDX-License-Identifier: MIT
// File: @openzeppelin/contracts/utils/math/SafeMath.sol


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

// File: @openzeppelin/contracts/utils/Context.sol


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

// File: @openzeppelin/contracts/access/Ownable.sol


// OpenZeppelin Contracts (last updated v4.9.0) (access/Ownable.sol)

pragma solidity ^0.8.0;


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

// File: @openzeppelin/contracts/token/ERC20/extensions/IERC20Permit.sol


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

// File: @openzeppelin/contracts/utils/Address.sol


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

// File: @openzeppelin/contracts/token/ERC20/IERC20.sol


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

// File: @openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol


// OpenZeppelin Contracts (last updated v4.9.3) (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.0;




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

// File: HPCStakingv1.sol


pragma solidity ^0.8.0;






contract HPC_Stakingv1 {
    using SafeERC20 for IERC20;
    using SafeMath for uint256;
    using Address for address;

    IERC20 private stakingContract; 
    IERC20 private rewardToken;  
    address public owner;
    mapping(address => uint256) public stakedAmount;
    mapping(address => uint256) public rewardAmount;
    mapping(address => uint256) public lastClaimTime; 
    mapping(address => uint256) public totalRewardsReceived;
    mapping(address => uint256) private previousStakedAmount;
    uint256 private previousContractBalance;
    uint256 private totalRewards;
    uint256 private totalStakes;
    uint256 private managementVaultBalance;
    uint256 private claimInterval; 
    uint256 private lastRewardsUpdateBlock;
    uint256 private Man_Percentage;
    uint256 private Stakers_Percentage;
    uint256 private currentAPY;
    uint256 private currentRewardPerStaker;
    address[] public stakerAddresses;
    address private manAddress; 

    // Events
    event UnstakingError(string message);
    event StakingError(string message);
    event ClaimRewardsError(string message);
    event CompoundRewardsError(string message);
    event ClaimManError(string message);
    event DistributeRewardsError(string message);
    event AmountStaked(address indexed user, uint256 amount);
    event AmountUnstaked(address indexed user, uint256 amount);
    event RewardClaimed(address indexed user, uint256 amount);
    event RewardCompounded(address indexed user, uint256 amount);
    event ManRewardClaimed(address indexed user, uint256 amount);
    event RewardDistributed(address indexed user, uint256 amount);
    

    constructor(address _stakingContractAddress, address  _rewardTokenAddress, address _manAddress) {
        stakingContract = IERC20(_stakingContractAddress);
        rewardToken = IERC20(_rewardTokenAddress);
        manAddress = _manAddress;
        owner = msg.sender;
        claimInterval = 300;
        Man_Percentage = 90;
        Stakers_Percentage = 10;
    }

    // Modifier to onlyOwner
    modifier onlyOwner() {
        require(
            msg.sender == owner,
            "Only the contract owner can call this function."
        );
        _;
    }

    // Function to allow users to stake tokens
    function stake(uint256 _amount) external {
        require(_amount > 0, "Amount must be greater than zero");

        // re-implement HPC rewardToken transfer fee mechanism.
        uint256 deductions = _amount.mul(18).div(1000); // fixed 1.8% transfer fee.

        // Determine the net amount to stake (deduct the fee)
        uint256 netAmount = _amount.sub(deductions);

        stakingContract.safeTransferFrom(msg.sender, address(this), _amount);

        // Update stakedAmount for the user.
        stakedAmount[msg.sender] = stakedAmount[msg.sender].add(netAmount);

        // Update StakedTokens stats.
        totalStakes = totalStakes.add(netAmount);
        
         // If the user is not in the stakerAddresses array, add them.
        if (stakedAmount[msg.sender] > 0 && !isStaker(msg.sender)) {
            stakerAddresses.push(msg.sender);
        }
        
        // Call autodistribute.
        autoDistributeRewards();

        emit AmountStaked(msg.sender, _amount);
    }


    // Function to allow users to claim their staked tokens
    function unstake(uint256 amountToUnstake) external {
        uint256 stakes = stakedAmount[msg.sender];
        require(stakes > 0, "No staked tokens to claim");
        require(amountToUnstake > 0 && amountToUnstake <= stakes, "Invalid unstake amount");

        // Update stakedAmount.
        stakedAmount[msg.sender] = stakedAmount[msg.sender].sub(amountToUnstake);

        // Transfer staked tokens to the user
        stakingContract.safeTransfer(msg.sender, amountToUnstake);

        // Update totalStakes
        totalStakes = totalStakes.sub(amountToUnstake);

        // Update endtime session of staker.
        if (stakedAmount[msg.sender] == 0 && isStaker(msg.sender)) {
        removeStakerAddress(msg.sender);
        }

        // Update totalStakes.
        if (getStakedAmount() == 0 && getTotalStakes() == 0) {
        totalStakes = 0;
        }
        
        // Update previousContractBalance
        if (getRewardAmount() == 0 && getStakedAmount() ==0 ){
            previousContractBalance = 0;
            currentRewardPerStaker = 0;
            currentAPY = 0;
        }

        // Call autodistribute.
        autoDistributeRewards();

        emit AmountUnstaked(msg.sender, amountToUnstake);
    }

    // Function to allow users to claim their accrued rewards
    function claimRewards() external {
        uint256 reward  = rewardAmount[msg.sender];
        require(reward > 0,"No available rewards to claim");

        // Ensure enough time has passed since the last claim
        require(block.timestamp > lastClaimTime[msg.sender] + claimInterval,"Claim interval not yet reached");

        // Update user's reward.
        rewardAmount[msg.sender] = 0;

        // Transfer rewards to the user
        rewardToken.safeTransfer(msg.sender, reward);

        // Update the total rewards claimed from the contract
        totalRewards = totalRewards.sub(reward);

        // Update total rewards received by the staker
        totalRewardsReceived[msg.sender] = totalRewardsReceived[msg.sender].add(reward); 

        // Update the last claim time for the user
        lastClaimTime[msg.sender] = block.timestamp;

        
        // Update previousContractBalance
        if (getRewardAmount() == 0 && getStakedAmount() == 0 ){
            previousContractBalance = 0;
            currentRewardPerStaker = 0;
            currentAPY = 0;
        }

        // Call autodistribute.
        autoDistributeRewards();

        emit RewardClaimed(msg.sender, reward);
    }

    // Function to allow users to claim their accrued rewards
    function compoundRewards() external {
        uint256 _reward = rewardAmount[msg.sender];
        require(_reward > 0,"No available rewards to claim");

        // Ensure enough time has passed since the last claim
        require(block.timestamp > lastClaimTime[msg.sender] + claimInterval,"Claim interval not yet reached");

        // Update user's reward.
        rewardAmount[msg.sender] = 0;

        // Update the user's stakes directly.
        stakedAmount[msg.sender] = stakedAmount[msg.sender].add(_reward);

        // Update the last claim time for the user
        lastClaimTime[msg.sender] = block.timestamp;

        // Update totalStakes.
        totalStakes = totalStakes.add(_reward);
        
        // Update the total rewards claimed from the contract
        totalRewards = totalRewards.sub(_reward);

        // Update total rewards received by the staker
        totalRewardsReceived[msg.sender] = totalRewardsReceived[msg.sender].add(_reward); 

        // Call autodistribute.
        autoDistributeRewards();

        emit RewardCompounded(msg.sender, _reward);
    }

    // Function to allow the owner to claim management rewards and send them to the manAddress
    function claimManReward() external onlyOwner {
        uint256 _amount = managementVaultBalance;
        require(_amount > 0, "Insufficient vault balance");

        // Ensure that the user cannot re-claim the rewards again.
        managementVaultBalance = 0;

        // Transfer rewards to the manAddress
        rewardToken.safeTransfer(manAddress, _amount);

        // Update totalRewards stats.
        totalRewards = totalRewards.sub(_amount);

        emit ManRewardClaimed(manAddress, _amount);
    }

     // Function to calculate potential rewards for a specific staker
    function calculateRewardByAddress(address _staker) external view returns (uint256) {
        // Retrieve the staked amount for the specific staker
        uint256 userStake = stakedAmount[_staker];

        if (userStake == 0) {
            return 0; // The staker has no staked amount, so the reward is 0.
        } else {
            // Calculate the potential rewards based on staked amount and current reward per staked token
            uint256 rewardPerTokenStakedLocal = rewardAmount[_staker].mul(1e8).div(userStake);
            return userStake.mul(rewardPerTokenStakedLocal).div(1e8);
        }
    }

    // Function to calculate potential rewards for the current epoch time.
    function calculateMyReward() external view returns (uint256) {
        // Retrieve the staked amount of msg.sender.
        uint256 userStake = stakedAmount[msg.sender];

        if (userStake == 0) {
            return 0; // The staker has no staked amount, so the reward is 0.
        } else {
            // Calculate the potential rewards based on staked amount and current reward per staked token
            uint256 rewardPerTokenStakedLocal = rewardAmount[msg.sender].mul(1e8).div(userStake);
            return userStake.mul(rewardPerTokenStakedLocal).div(1e8);
        }
    }

    // Function to calculate potential rewards based on a specified staked amount
    function rewardCalculator(uint256 _stakedAmount) external view returns (uint256) {
        uint256 totalS = getStakedAmount();
        uint256 totalR = getRewardAmount();

        if (totalS == 0 || totalR == 0) {
            return 0;
        } else {
            // Calculate potential rewards based on the total staked amount and current reward per staked token
            uint256 rewardPerTokenStakedLocal = totalR.mul(1e8).div(totalS);
            return _stakedAmount.mul(rewardPerTokenStakedLocal).div(1e8);
        }
    }

    // View total rewards received by the staker
    function getMyTotalRewardsReceived() external view returns (uint256) {
        return totalRewardsReceived[msg.sender];
    }

    // View totaRewards stats
    function getTotalRewards() public view returns (uint256) {
        return totalRewards;
    }

    // Function to calculate the reward for a staker based on staking duration and reward per staked token
    function getMyRewards() external view returns (uint256) {
        uint256 myrewards  = rewardAmount[msg.sender];
        return myrewards;
    }

    // View my StakedTokens
    function getMyStakes() external view returns(uint256){
        uint256 mystaked = stakedAmount[msg.sender];
        return mystaked;
    }

    // Function to get the number of stakers
    function getNumberOfStakers() external view returns (uint256) {
        return stakerAddresses.length;
    }

    // Function to view the reward per staked token
    function getCurrentRewardPerStaker() public view returns (uint256) {
        return currentRewardPerStaker;
    }

    // Function to distribute rewards proportionally to staked tokens
    function autoDistributeRewards() internal {
        uint256 newBalance = rewardToken.balanceOf(address(this));
        uint256 totalBalance = combinedBalances();
        uint256 stakedToken = getTotalStakes();

        if (stakedToken == 0 || newBalance <= totalBalance) {
            emit DistributeRewardsError("No new reward or no staked tokens yet.");
            return; // Do nothing.
        }

        uint256 availableBalance = newBalance.sub(totalBalance);

        // If the block number is greater than the last rewards update block
        if (block.number > lastRewardsUpdateBlock) {
            // Update the last rewards update block
            lastRewardsUpdateBlock = block.number;

            // Calculate management and holders shares based on new rewards only
            uint256 newRewards = availableBalance;
            uint256 managementShare = newRewards.mul(Man_Percentage).div(100);
            uint256 holdersShare = newRewards.mul(Stakers_Percentage).div(100);

            // Add the management share to the management balance
            managementVaultBalance = managementVaultBalance.add(managementShare);

            uint256 rewardPerTokenStakedLocal = holdersShare.mul(1e8).div(stakedToken);

            // Distribute rewards proportionally to staked tokens
            for (uint256 i = 0; i < stakerAddresses.length; i++) {
                address stakerAddress = stakerAddresses[i];
                uint256 userStake = stakedAmount[stakerAddress];
                if (userStake > 0) {
                    uint256 stakerReward = userStake.mul(rewardPerTokenStakedLocal).div(1e8);
                    rewardAmount[stakerAddress] = rewardAmount[stakerAddress].add(stakerReward);

                      // Update currentRewardPerStaker
                    currentRewardPerStaker = stakerReward;
                }
            }
        }

        // Update totalRewards stats.
        totalRewards = totalRewards.add(availableBalance);

        // Update newRewards
        previousContractBalance = newBalance;

        // Update APY
        updateCurrentAPY();

        emit RewardDistributed(msg.sender, availableBalance);
    }

    // Function to distribute rewards proportionally to staked tokens
    function manualDistributeRewards() external {
        uint256 newBalance = rewardToken.balanceOf(address(this));
        uint256 totalBalance = combinedBalances();
        uint256 stakedToken = getTotalStakes();

        if (stakedToken == 0 || newBalance <= totalBalance) {
            emit DistributeRewardsError("No new reward or no staked tokens yet.");
            return; // Do nothing.
        }

        uint256 availableBalance = newBalance.sub(totalBalance);

        // If the block number is greater than the last rewards update block
        if (block.number > lastRewardsUpdateBlock) {
            // Update the last rewards update block
            lastRewardsUpdateBlock = block.number;

            // Calculate management and holders shares based on new rewards only
            uint256 newRewards = availableBalance;
            uint256 managementShare = newRewards.mul(Man_Percentage).div(100);
            uint256 holdersShare = newRewards.mul(Stakers_Percentage).div(100);

            // Add the management share to the management balance
            managementVaultBalance = managementVaultBalance.add(managementShare);

            uint256 rewardPerTokenStakedLocal = holdersShare.mul(1e8).div(stakedToken);

            // Distribute rewards proportionally to staked tokens
            for (uint256 i = 0; i < stakerAddresses.length; i++) {
                address stakerAddress = stakerAddresses[i];
                uint256 userStake = stakedAmount[stakerAddress];
                if (userStake > 0) {
                    uint256 stakerReward = userStake.mul(rewardPerTokenStakedLocal).div(1e8);
                    rewardAmount[stakerAddress] = rewardAmount[stakerAddress].add(stakerReward);

                      // Update currentRewardPerStaker
                    currentRewardPerStaker = stakerReward;
                }
            }
        }

        // Update totalRewards stats.
        totalRewards = totalRewards.add(availableBalance);

        // Update newRewards
        previousContractBalance = newBalance;

        // Update APY
        updateCurrentAPY();

        emit RewardDistributed(msg.sender, availableBalance);
    }

    receive() external payable {
        uint256 contractTokenBalance = rewardToken.balanceOf(address(this));
        if (contractTokenBalance > 0){
            // Call autodistribute.
            autoDistributeRewards();
        }
    }

    // Function to update the management address
    function updateManAddress(address _newManAddress) external onlyOwner {
        manAddress = _newManAddress;
    }

    // Function to update the claim interval (only callable by the owner)
    function setClaimInterval(uint256 _newInterval) external onlyOwner {
        require(_newInterval > 0, "Interval must be greater than zero");
        claimInterval = _newInterval;
    }

    // Function to view the claim interval. 
    function getClaimInterval() external view returns(uint256){
        return claimInterval;
    }

     // Update Man_percentage and Stakers Percentages.
    function updatePercentages(uint256 _newManPercentage, uint256 _newStakersPercentage) external onlyOwner {
    require(_newManPercentage + _newStakersPercentage == 100, "Both percentages must equal to 100%");
    Man_Percentage = _newManPercentage;
    Stakers_Percentage = _newStakersPercentage;
    }

    // Update rewardToken address.
    function updateStakingContractAddress(address _newStakingContract) external onlyOwner{
        stakingContract = IERC20(_newStakingContract);
    }

     // Update rewardToken address.
    function updateRewardTokenAddress(address _newRewardToken) external onlyOwner{
        rewardToken = IERC20(_newRewardToken);
    }

    // Calculate combined balances on struct.
    function calculateAllBalances() internal view returns (uint256) {
        uint256 totalBalances = getStakedAmount() + getRewardAmount();
        return totalBalances;
    }

    // Calculate combined balances on struct.
    function combinedBalances() internal view returns (uint256) {
        uint256 totalBalances = totalStakes + totalRewards;
        return totalBalances;
    }

    // Calculate the sum of contract balance.
    function getAllBalances() external view returns (uint256) {
        return calculateAllBalances();
    }

    // Total rewardtoken balances
    function totalContractBalance() external view returns (uint256){
        return rewardToken.balanceOf(address(this));
    }

    // View totalStakes stats
    function getTotalStakes() public view returns(uint256){
        return totalStakes;
    }

    // Function to calculate the total sum of staked amounts across all stakers
    function getStakedAmount() public view returns (uint256) {
        uint256 stakes = 0;
        for (uint256 i = 0; i < stakerAddresses.length; i++) {
            stakes += stakedAmount[stakerAddresses[i]];
        }
        return stakes;
    }

    // Function to calculate the total sum of reward amounts across all stakers
    function getRewardAmount() public view returns (uint256) {
        uint256 rewards = 0;
        for (uint256 i = 0; i < stakerAddresses.length; i++) {
            rewards += rewardAmount[stakerAddresses[i]];
        }
        return rewards;
    }

    // View ManPercentages.
    function getManPercentage() external view returns(uint256){
        return Man_Percentage;
    }

    // View StakersPercentages.
    function getStakersPercentage() external view returns(uint256){
        return Stakers_Percentage;
    }


    // View Man_vault balance.
    function manVaultBalance() public view returns(uint256) {
        return managementVaultBalance;
    }

    // View staking address 
    function stakingContractAddress() external view returns(address){
        return address(stakingContract);
    }

    // View manAddress.
    function getManAddress() external view returns(address){
        return manAddress;
    }

    // View snapshot of the previous balance.
    function getPreviousBalance() external view returns(uint256){
        return previousContractBalance;
    }

    // View reward address 
    function rewardTokenAddress() external view returns(address){
        return address(rewardToken);
    }

    // View currentAPY
    function getCurrentAPY() external view returns(uint256){
        return currentAPY;
    }

    // View eth contract eth balance.
    function getEthBalance() external view returns(uint256){
        return address(this).balance;
    }

    // Function to withdraw ETH balance by the owner
    function rescueEth() external onlyOwner {
        uint256 balance = address(this).balance;
        (bool sent, ) = msg.sender.call{value: balance}("");
        require(sent, "Failed to send Ether");
    }

    // Function to withdraw ERC20 tokens by the owner, except for rewardToken
    function rescueERC20Tokens(address tokenAddress) external onlyOwner {
        require(tokenAddress != address(rewardToken),"RewardToken is not withdrawable");
        
        uint256 tokenBalance = IERC20(tokenAddress).balanceOf(address(this));
        require(tokenBalance > 0, "No tokens to withdraw");
        
        IERC20(tokenAddress).safeTransfer(msg.sender, tokenBalance);
    }

    // Function to calculate and update the current APY
    function updateCurrentAPY() internal {
        uint256 rewards = totalRewards;
        uint256 stakes = totalStakes;
        uint256 dailyRate;
        uint256 currentRate;

        // Check if there are stakers and total staked tokens are not zero
        if (stakes > 0 && rewards > 0) {
            dailyRate = rewards.mul(1e8).div(365); // Divide rewards by 1e8 and 365 days to get the daily reward.
            currentRate = dailyRate.mul(1e8).div(stakes);  // Daily rewards divided by the total staked.

            // Set the APY directly as the annual interest rate
            currentAPY = currentRate.mul(10000); // result with 2 decimal places.
        } else {
            // If there are no stakers or total staked tokens are zero, set APY to 0
            currentAPY = 0;
        }
    }

    // remove stakers from staker array
    function removeStakerAddress(address staker) internal {
        for (uint256 i = 0; i < stakerAddresses.length; i++) {
            if (stakerAddresses[i] == staker) {
                // Move the last element to the position to be removed
                stakerAddresses[i] = stakerAddresses[stakerAddresses.length - 1];
                // Shorten the array by one
                stakerAddresses.pop();
                break; // Exit the loop once removed
                }
            }
    }

    // Function to check if an address is a staker
    function isStaker(address _address) internal view returns (bool) {
        for (uint256 i = 0; i < stakerAddresses.length; i++) {
            if (stakerAddresses[i] == _address) {
                return true;
            }
        }
        return false;
    }
}