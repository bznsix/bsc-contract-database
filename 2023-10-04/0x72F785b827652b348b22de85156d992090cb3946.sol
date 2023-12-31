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
pragma solidity ^0.8.13;

library QuickSort {

    /*  order array low to high */
    function quickSort(uint256[] memory arr) internal pure returns (uint256[] memory ) {
        if (arr.length <= 1) {
            return arr;
        }
        _quickSort(arr,0, arr.length - 1);
        return (arr);
    }
    function _quickSort(uint256[] memory arr, uint256 low, uint256 high) private pure {
        if (low < high) {
            uint256 pivotIndex = _partition(arr, low, high);
            if(pivotIndex == 0) return;
            _quickSort(arr, low, pivotIndex - 1);
            _quickSort(arr, pivotIndex + 1, high);
        }
    }
    function _partition(uint256[] memory arr, uint256 low, uint256 high) private pure returns (uint256) {
        uint256 pivot = arr[high];
        uint256 i = low;
        for (uint256 j = low; j <= high - 1; j++) {
            if (arr[j] < pivot) {
                (arr[i], arr[j]) = (arr[j], arr[i]);
                i++;
            }
        }
        (arr[i], arr[high]) = (arr[high], arr[i]);
        return i;
    }
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./IOpenOceanCaller.sol";
interface IOpenOcean {


    struct SwapDescription {
        IERC20 srcToken;
        IERC20 dstToken;
        address srcReceiver;
        address dstReceiver;
        uint256 amount;
        uint256 minReturnAmount;
        uint256 guaranteedAmount;
        uint256 flags;
        address referrer;
        bytes permit;
    }

    function swap(IOpenOceanCaller caller, SwapDescription calldata desc, IOpenOceanCaller.CallDescription[] calldata calls) external payable returns (uint256 returnAmount);

}// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

interface IOpenOceanCaller {
    struct CallDescription {
        uint256 target;
        uint256 gasLimit;
        uint256 value;
        bytes data;
    }

    function makeCall(CallDescription memory desc) external;

    function makeCalls(CallDescription[] memory desc) external payable;
}// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

interface ITradingCompetitionManager {
       
    
    /// @notice Trading competition timestamp info
    struct TimestampInfo {
        uint startTimestamp;        // when it starts
        uint endTimestamp;          // when it ends

        uint registrationStart;     // when regisitration starts
        uint registrationEnd;       // when registration ends
    }

    /// @notice Competition rules structure
    struct CompetitionRules {
        uint starting_balance;      // if != 0, anyone MUST have this starting_balance. Eg.: starting_balance = 100 * 1e18 --> 100 USDT as start
        address winning_token;      // User with more winning_token wins. must be in TradingTokens. Eg.: usdt
        address[] tradingTokens;    // tokens allowed for trading, at least 2! must contain winning_token. Eg.: usdt - wbnb
    }

    
    /// @notice Trading competition prize structure
    struct Prize {
        bool win_type;              // False == Higher PNL in n° of tokens wins | True == Higher % PNL wins
        uint[] weights;             // weights for each placement. Eg.: weights = [10,70,20] --> sorted then [1st = 70, 2nd = 20, 3rd = 10] 
        uint totalPrize;          // total prize to win (counting owner_fee). 
        uint owner_fee;            // the creator fee on the prize. owner_fee <= 250 (25%).
        address token;            // prize tokens
        uint host_contribution; // the amount of tokens that the host must give to the prize pool
    }

    /// @notice Trading competition info structure
    struct TC {
        uint entryFee;              // EntryFee to pay to enter the trading competition. Amount in prize.token
        uint MAX_PARTICIPANTS;       // Max number of participants

        address owner;              // Creator of the trading competition
        address tradingCompetition; // Trading Competition Contract. This field is filled on deployment, must be init to address(0)
        
        string name;                // Name of the trading competition (can be address(0) on create() )
        string description;         // Description of the trading competition
        
        TimestampInfo timestamp;    // See struct TimestampInfo
        MarketType market;          // See enum MarketType
        Prize prize;                // See struct Prize
        CompetitionRules competitionRules; // See struct CompetitionsRules
    }

    /// @notice Define market types
    enum MarketType {SPOT, PERPETUALS}


    /// @dev functions
    function create(TC calldata _tradingCompetition) external returns(address competition, uint idCounter);
    function idToTradingCompetition(uint _id) external view returns (TC memory);
    function router() external view returns(address);
    function idCounter() external view returns(uint);
    
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "./ITradingCompetitionManager.sol";
import "./IOpenOceanCaller.sol";
import "./IOpenOcean.sol";
//import "hardhat/console.sol";

abstract contract TradingCompetitionRouter {

    using SafeERC20 for IERC20;
    uint256 MAX_INT = 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff;
    
    /// @notice OpenOcean router
    address public manager;

    function _swap(IOpenOceanCaller caller,IOpenOcean.SwapDescription memory desc,IOpenOceanCaller.CallDescription[] calldata calls) internal returns(uint256 returnAmount) {
        IERC20 token = desc.srcToken;
        address target = _router();
        //if(desc.srcReceiver != address(this)) desc.srcReceiver = address(this);
        if(desc.dstReceiver != address(this)) desc.dstReceiver = address(this); //force dstReceiver to be this address

        token.safeApprove(address(target), 0);
        token.safeApprove(address(target), MAX_INT);

        returnAmount = IOpenOcean(target).swap(caller,desc,calls);
    }
 
    
    function _router() internal view returns(address) {
        return ITradingCompetitionManager(manager).router();
    }


}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "../libraries/QuickSort.sol";
import "./TradingCompetitionRouter.sol";
import "./ITradingCompetitionManager.sol";



/// @title Trading Competition SPOT
/// @author Prometheus - Thena Finance
/// @notice This contract is where users register, trades and ev. claim the trading competition prize
contract TradingCompetitionSpot is ReentrancyGuard, TradingCompetitionRouter {

    using SafeERC20 for IERC20;
    
    /*****************************************/
    /*              STRUCT                */
    /*****************************************/
    

    /**
     * @notice Trading competition user info
     * @member startBalance track main token start balance
     * @member tokenBalance[] balance of tokens
     */
    struct User {
        uint startBalance;      // track main token start balance
        uint[] tokenBalance;    // balance of tokens
    }   

    /*****************************************/
    /*              CONSTANTS                */
    /*****************************************/

    /// @notice Precision for % pnl
    uint constant PRECISION = 1e12;
        
    /*****************************************/
    /*              IMMUTABLES               */
    /*****************************************/

    /// @notice ID of the trading competition
    uint public immutable ID;

    /// @notice owner(creator) of the trading competition
    address public immutable owner;
    
    
    /*****************************************/
    /*              VARIABLES                */
    /*****************************************/


    /// @notice init flag (set after manager saved)
    bool public init;

    /// @notice flag if owner has claimed fee if any
    bool private _ownerHasClaimed;

    /// @notice array of users addresses
    address[] private _users;

    /// @notice pnl array for users given the type of competition (flat or %)
    int[] private _pnl;

    /// @notice mapping with user position
    mapping(address => uint) private _userPosition;
    
    /// @notice Map user address with User strcuture
    mapping(address => User) private _user;

    /// @notice Control if user is registered in the competition
    mapping(address => bool) private _isRegistered;
  
    /// @notice Control if a token is allowed to be traded  (valid only for tokenIn and tokenOut, "mid" paths are not checked)
    mapping(address => bool) private _isTradingToken;

    /// @dev mapping trading token position
    mapping(address => uint) private _tokenPosition;

    /// @dev mapping winner address to whether he claimed
    mapping(address => bool) private winnersClaimed;

    /// @dev list of the winners. Only populated after the winner claimed his rewards
    address[] public winnersList;

    /// @notice Trading competition data structure
    ITradingCompetitionManager.TC private tc_data;

    /*****************************************/
    /*              EVENTS                   */
    /*****************************************/

    event Trade(address indexed user, address indexed tokenIn, address tokenOut, uint amountIn, uint amountOut, IOpenOceanCaller.CallDescription[] calls, uint timestamp);
    event DepositFund(address indexed user, address indexed token, uint amountIn, uint timestamp);
    event WithdrawFund(address indexed user, address indexed token, uint amountOut, uint timestamp);
    event ClaimPrize(address indexed winner, address to, address indexed token, uint amount);
    event ClaimOwnerFee(address indexed owner, address to, address indexed token, uint amount);
    
    /*****************************************/
    /*              CONSTRUCTOR              */
    /*****************************************/

    constructor(address _owner, address _manager, uint _id) {
        manager = _manager;
        owner = _owner;
        ID = _id;
        init = false;
    }

    /// @notice Initialize the trading competition.
    /// @dev    _init() is called by the manager after _getPrize(). Saving some data locally to save on external calls
    function _init(ITradingCompetitionManager.TC calldata _tc) external returns(bool){
        require(msg.sender == manager, "TCF: not manager");
        tc_data = _tc;

        // add address
        tc_data.tradingCompetition = address(this);

        // tokens
        uint i = 0;
        for(i; i < _tc.competitionRules.tradingTokens.length; i++){
            _isTradingToken[_tc.competitionRules.tradingTokens[i]] = true;
            _tokenPosition[_tc.competitionRules.tradingTokens[i]] = i;
        }

        require(IERC20(_tc.prize.token).balanceOf(address(this)) >= _tc.prize.totalPrize, "TC: missing prize");
        
        init = true;
        return init;
    }

    
    /*****************************************/
    /*      USER INTERACTION - MANAGEMENT    */
    /*****************************************/

    /// @notice register a user to this trading competition 
    function register() public {
        _register();
    }

    /// @notice register a user to this trading competition and deposit amount starting balance
    /// @param amount the amount to deposit. If the competition startBalance is > 0, then amount MUST be = startBalance
    function registerAndDeposit(uint amount) public {
        _register();
        _deposit(amount);
    }
    
    function _register() internal {
        address caller = msg.sender;
        (,,uint registrationStart,uint registrationEnd) = _timestamp();
        
        require(block.timestamp >= registrationStart && block.timestamp <= registrationEnd, "TC: soon/late");
        require(!_isRegistered[caller], "TC: registered");
        require(_users.length <= tc_data.MAX_PARTICIPANTS, "TC: max user limit reached");
        
        _users.push(caller);
        _userPosition[caller] = _users.length - 1 ;
        _pnl.push(0);
        _user[caller].tokenBalance = new uint[](tc_data.competitionRules.tradingTokens.length);
        _isRegistered[caller] = true; 
    }

    /// @notice deposit main token. Users with more mainTokens at the end of the trading comp wins. main token is equal to CompetitionRules.winning_token
    /// @dev    User must be registered. Can top-up anytime from registration start to end of registration.
    /// @dev    If starting_balance != 0 then everyone must start with the same balance.
    /// @param amount the amount to deposit. If the competition startBalance is > 0, then amount MUST be = startBalance
    function deposit(uint256 amount) external nonReentrant {
        _deposit(amount);
    }

    function _deposit(uint256 amount) internal {
        require(_isRegistered[msg.sender], "TC: not registered");

        uint _starting_balance = tc_data.competitionRules.starting_balance;
        if(_starting_balance == 0){
            require(amount > 0, "TC: amount 0");
        } else { 
            require(amount == _starting_balance, "TC: amount != startBal");
            require(_user[msg.sender].startBalance == 0, "TC: startBalance ok");
        }
        
        (,,uint registrationStart,uint registrationEnd) = _timestamp();
        require(block.timestamp >= registrationStart && block.timestamp <= registrationEnd, "TC: soon/late");
        
        address mainToken = tc_data.competitionRules.winning_token;
        uint entryFee = tc_data.entryFee;
        _user[msg.sender].startBalance += amount;
        _user[msg.sender].tokenBalance[_tokenPosition[mainToken]] += amount;
        
        IERC20(mainToken).safeTransferFrom(msg.sender, address(this), amount);      
        if( entryFee > 0 ) _increasePrize(msg.sender, tc_data.prize.token, entryFee);

        emit DepositFund(msg.sender, mainToken, amount, block.timestamp);
    }


    /// @notice Withdraw all funds of a user (all the different tokens). Can only be called after the competition ends
    function withdrawAllFunds() external nonReentrant {
        (,uint endTimestamp,,) = _timestamp();
        require(block.timestamp > endTimestamp, "TC: too soon");
        uint i = 0;
        uint len = tc_data.competitionRules.tradingTokens.length;
        for(i ; i < len; i++){
            address _token = tc_data.competitionRules.tradingTokens[i];
            uint balance = _user[msg.sender].tokenBalance[_tokenPosition[_token]];
           _withdrawFunds(msg.sender, _token, balance);
        }
    }
    
    /// @notice Withdraw a given amount of funds of a user
    /// @notice If registration is active user can remove its deposited funds. _token must be mainToken
    /// @param _token the token to withdraw. If we are still in the registration phase, then only mainToken can be withdrawn
    /// @param _amount the amount to withdraw. 
    function withdrawFunds(address _token, uint _amount) external nonReentrant {
        (,uint endTimestamp,uint registrationStart, uint registrationEnd) = _timestamp();
        if(block.timestamp > registrationStart && block.timestamp <= registrationEnd){
            _withdrawFundsRegActive(msg.sender, _token, _amount);
            return;
        }
        require(block.timestamp > endTimestamp, "TC: too soon");
        require(_user[msg.sender].tokenBalance[_tokenPosition[_token]] >= _amount, "TC: Not enough funds");
        _withdrawFunds(msg.sender, _token, _amount);
    }

    function _withdrawFunds(address who, address _token, uint _amount) internal {
        _user[who].tokenBalance[_tokenPosition[_token]] -= _amount;
        IERC20(_token).safeTransfer(who, _amount);
        emit WithdrawFund(who, _token, _amount, block.timestamp);
    }

    function _withdrawFundsRegActive(address who, address _token, uint _amount) internal {
        require(_user[msg.sender].tokenBalance[_tokenPosition[_token]] >= _amount && _user[who].startBalance >= _amount, "TC: Not enough funds");
        require(_token == tc_data.competitionRules.winning_token, "TC: Not mainToken");

        uint _starting_balance = tc_data.competitionRules.starting_balance;
        if(_starting_balance == 0){
            _user[who].tokenBalance[_tokenPosition[_token]] -= _amount;
            _user[who].startBalance -= _amount;
            IERC20(_token).safeTransfer(who, _amount);
        } else {
            _user[who].tokenBalance[_tokenPosition[_token]] = 0;
            _user[who].startBalance = 0;
            IERC20(_token).safeTransfer(who, _starting_balance);
        }

        _isRegistered[who] = false; 
        _updateUsers(who);
        emit WithdrawFund(who, _token, _amount, block.timestamp);
    }

    
    
    /*****************************************/
    /*      USER INTERACTION - OPERATIONS    */
    /*****************************************/

    /// @notice swap between tokens in the CompetitionRules::tradingTokens[]
    /// @param caller the open ocean caller contract
    /// @param desc description of the swap to execute
    /// @param calls the calls to execute
    /// @return amountOut the amount of desc.dstToken that you got with this swap
    function swap(IOpenOceanCaller caller,IOpenOcean.SwapDescription calldata desc,IOpenOceanCaller.CallDescription[] calldata calls) public nonReentrant returns(uint256 amountOut) {
        
        address tokenIn = address(desc.srcToken);
        address tokenOut = address(desc.dstToken);
        uint amountIn = desc.amount;

        // checks
        _beforeSwap(msg.sender, tokenIn, tokenOut, amountIn);
        
        // save old bal
        uint _old_tokenIn = IERC20(tokenIn).balanceOf(address(this));
        uint _old_tokenOut = IERC20(tokenOut).balanceOf(address(this));

        // perform swap
        amountOut = _swap(caller, desc, calls);    

        // read new bal
        uint _new_tokenIn = IERC20(tokenIn).balanceOf(address(this));
        uint _new_tokenOut = IERC20(tokenOut).balanceOf(address(this));

        require(amountIn == _old_tokenIn - _new_tokenIn, "TC: swap wrong In");
        require(amountOut == _new_tokenOut - _old_tokenOut, "TC: swap wrong Out");
        
        // save user data
        _afterSwap(tokenIn, tokenOut, amountIn, amountOut);
        
        // emit event
        emit Trade(msg.sender, tokenIn, tokenOut, amountIn, amountOut, calls, block.timestamp);
        
    }

    
    /*****************************************/
    /*      USER INTERACTION - REWARDS       */
    /*****************************************/
    
    /// @notice calculates and sends the prize of the msg.sender to the `to` address. Usually we will call this function with `to` = msg.sender 
    /// @param to the address to claim the tokens
    function claimPrize(address to) external nonReentrant {
        (, uint endTimestamp,,) = _timestamp();
        require(block.timestamp > endTimestamp, "TC: Wait end");
        require(_isRegistered[msg.sender], "TC: not registered");

        // TODO edge case: what if there are not enough users registered in the competition? Chance of locking tokens forever in the smart contract 

        (uint winningPosition, uint equalCounter) = _findUserWinningPosition(msg.sender);
        if(winningPosition > tc_data.prize.weights.length -1) return; // msg.sender is not a winner

        require(!winnersClaimed[msg.sender], "TC: prize already claimed");
        
        winnersClaimed[msg.sender] = true;

        _claimAmount(to, winningPosition, equalCounter);
        winnersList.push(msg.sender);
    }

    /// @notice calculates and sends the owner fee to the `to` address. Only the owner of the tc can call this function
    /// @param to the address to claim the tokens
    function claimOwnerFee(address to) external nonReentrant {
        require(msg.sender == owner, 'TC: not owner');
        require(!_ownerHasClaimed, 'TC: owner fee claimed');
        if(tc_data.prize.owner_fee == 0) _ownerHasClaimed = true;
        _claimOwnerFee(to);
    }

    /// @notice function used to manually increase the total prize. Anyone can 'donate' to the prize pool
    /// @param amount the amount of prize.token that will go in the prize pot
    function increasePrize(uint amount) external nonReentrant {
        _increasePrize(msg.sender, tc_data.prize.token, amount);
    }
    
    
    /*****************************************/
    /*              INTERNAL FUNCTIONS       */
    /*****************************************/

    function _increasePrize(address from, address token, uint amount) internal {
        (,,uint registrationStart,uint registrationEnd) = _timestamp();
        require(block.timestamp >= registrationStart && block.timestamp <= registrationEnd, "TC: soon/late");
        require(token == tc_data.prize.token, "TC: should be prize token");
        if(token == tc_data.prize.token){
            tc_data.prize.totalPrize += amount;
            IERC20(token).safeTransferFrom(from, address(this), amount);
        }
    }

    function _claimAmount(address to, uint winningPosition, uint equalCounter) internal {
        (uint amount, address token) = _claimable(winningPosition, equalCounter);
        if(amount > 0) {
            IERC20(token).safeTransfer(to, amount);
            emit ClaimPrize(msg.sender, to, token, amount);
        }
        
    }

    /// @notice     Find the user winning position. 
    /// @param who  we are looking for
    /// @dev        If there is the same PNL between user, save the total number of equal pnls divide the prize accordingly  
    ///        
    /// @return pos             User position the winning list. pos = 0 --> 1st place, pos = 1 --> 2nd place, ... , pos = N --> Nth+1 Place
    /// @return equalCounter    Number of draw position
    function _findUserWinningPosition(address who) private view returns(uint pos, uint equalCounter) {
        
        uint userCounter = _users.length;
        uint upos = _userPosition[who];
        
        equalCounter = 0;                           //equal counter
        pos = 0;                                   //max counter

        for(uint i = 0; i < userCounter; i++){
            if(_pnl[i] > _pnl[upos]){
                pos++;
            }
            if(_pnl[i] == _pnl[upos]){
                equalCounter++;
            }
        }
        
        
    }
    

    
    function _claimable(uint winningPosition, uint equalCounter) internal view returns(uint256 amount, address token){
        uint winnersLength = tc_data.prize.weights.length;

        
        if(winningPosition >= winnersLength) {
            return (0, address(0)); // not a winner
        }

        uint256[] memory sortedWinningWeights = QuickSort.quickSort(tc_data.prize.weights);    // lowest first
        
        uint totalRealPrize = tc_data.prize.totalPrize * (PRECISION - PRECISION * tc_data.prize.owner_fee / 1000); // _totPrize, scaled by precision

        uint256 totalAmount = 0;

        for(uint i = 0; i < equalCounter; i++) {
            totalAmount += totalRealPrize * sortedWinningWeights[winnersLength - 1 - winningPosition - i] / 1000 / equalCounter;  
        }
        amount = totalAmount / PRECISION;
        token = tc_data.prize.token;
                        
    }


    function _claimOwnerFee(address to) internal {
        uint _owner_fee = (tc_data.prize.totalPrize * tc_data.prize.owner_fee / 1000);
        address token = tc_data.prize.token;
        IERC20(token).safeTransfer(to, _owner_fee);
        emit ClaimOwnerFee(msg.sender, to, token, _owner_fee);
        _ownerHasClaimed = true;
    }

    
    function _beforeSwap(address _swapper, address tokenIn, address tokenOut, uint amountIn) internal view {
        require(_isRegistered[_swapper], "TC: not registered");
        (uint startTimestamp, uint endTimestamp,,) = _timestamp();
        require(block.timestamp >= startTimestamp && block.timestamp <= endTimestamp, "TC: soon/late");
        require(_isTradingToken[tokenIn], "TC: tokenIn not allowed");
        require(_isTradingToken[tokenOut], "TC: tokenOut not allowed");
        require(_user[_swapper].tokenBalance[_tokenPosition[tokenIn]] >= amountIn, "TC: not enough funds");
    }
   
    function _afterSwap(address tokenIn, address tokenOut, uint amountIn, uint amountOut) internal {

        User storage __user = _user[msg.sender];
        uint oldBalIn = __user.tokenBalance[_tokenPosition[tokenIn]];
        uint oldBalOut = __user.tokenBalance[_tokenPosition[tokenOut]];
        uint position = _userPosition[msg.sender];
        uint startBalance = __user.startBalance;

        __user.tokenBalance[_tokenPosition[tokenIn]] = oldBalIn - amountIn;
        __user.tokenBalance[_tokenPosition[tokenOut]] = oldBalOut + amountOut;

        // if tokenIn is main token, then sub amount given for swap
        if(tokenIn == tc_data.competitionRules.winning_token){
            if(tc_data.prize.win_type){
                // PNL %
                _pnl[position] = int( (oldBalIn - amountIn - startBalance) * PRECISION / startBalance );
            } else {
                // PNL FLAT
                _pnl[position] -= int(amountIn);
            }
            return;
        }
        // if tokenOut is main token, then add amount receive after swap
        if(tokenOut == tc_data.competitionRules.winning_token){
            if(tc_data.prize.win_type){
                // PNL %
                _pnl[position] = int( (oldBalIn + amountOut - startBalance) * PRECISION / startBalance );
            } else {
                // PNL FLAT
                _pnl[position] += int(amountOut);
            }
            return;
        }
        
    }

    function _updateUsers(address who) private returns(bool status) {
        uint position = _userPosition[who];
        uint last = _users.length -1;
        address lastUser = _users[last];

        if(position == 0){
            _users[0] = lastUser;
            _userPosition[lastUser] = 0;
            _users.pop();
            _pnl.pop();
            delete _userPosition[who];
            return true; 
        }
        if(position == last){
            _users.pop();
            _pnl.pop();
            delete _userPosition[who];
            return true;
        }
    
        _users[position] = lastUser;
        _userPosition[lastUser] = position;
        _users.pop();
        _pnl.pop();
        delete _userPosition[who];
        return true;        
    }



    /*****************************************/
    /*              VIEW FUNCTIONS           */
    /*****************************************/
    
    /// @notice get the timestamp of the trading competition (see ITradingCompetitionManager.sol).
    function timestamp() public view returns(uint startTimestamp, uint endTimestamp,uint registrationStart,uint registrationEnd) {
        return _timestamp();
    }

    function _timestamp() internal view returns(uint startTimestamp, uint endTimestamp,uint registrationStart,uint registrationEnd) {
        startTimestamp = tc_data.timestamp.startTimestamp;
        endTimestamp = tc_data.timestamp.endTimestamp;
        registrationStart = tc_data.timestamp.registrationStart;
        registrationEnd = tc_data.timestamp.registrationEnd;
    }

    /// @notice get trading tokens (see ITradingCompetitionManager.sol)
    function tradingTokens() external view returns(address[] memory){
        return tc_data.competitionRules.tradingTokens;
    }

    /// @notice get TradingCompetition struct (see ITradingCompetitionManager.sol)
    function tradingCompetition() external view returns(ITradingCompetitionManager.TC memory){
        return tc_data;
    }

    /// @notice check if a user is registered for the competition
    function isRegistered(address _who) external view returns(bool){
        return _isRegistered[_who];
    }

    function users() external view returns(address[] memory){
        return _users;
    }
    
    function user(address _who) external view returns(User memory userinfo){
        return _user[_who];
    }


    /// @notice check if a user won the trading competition or not
    function isWinner(address who) external view returns(bool answer, uint placement) {
        (placement,) = _findUserWinningPosition(who);
        answer = placement < tc_data.prize.weights.length  ? true : false;
    }

    /// @notice get the PNL of an account.
    function getPNLOf(address who) external view returns(int) {
        require(_isRegistered[who]);
        return _pnl[_userPosition[who]];
    }

    /// @notice returns the amount of prize.token that the user won
    function claimable(address who) external view returns(uint256 amount, address token) {
        (uint winningPosition, uint equalCounter) = _findUserWinningPosition(who);
        return _claimable(winningPosition, equalCounter);
    }

    /// @notice returns the balances of all the tokens of a particular users
    function userBalance(address who) external view returns(uint256[] memory amounts, address[] memory tokens) {
        tokens = tc_data.competitionRules.tradingTokens;
        amounts = _user[who].tokenBalance;
    }

}
