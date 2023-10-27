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
// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.7;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

// @title Wrapped token ERC20 interface
interface IWETH is IERC20 {
    function deposit() external payable;

    function withdraw(uint wad) external;
}
// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.7;

// @title Router token swapping functionality
// @notice Functions for swapping tokens via WOWMAX
interface IWowmaxRouter {
    struct Swap {
        // target token address
        address to;
        // part of owned tokens to be swapped
        uint256 part;
        // contract address that performs the swap
        address addr;
        // contract DEX family
        bytes32 family;
        // additional data that is required for a specific DEX protocol
        bytes data;
    }

    struct ExchangeRoute {
        // source token address
        address from;
        // total parts of owned token
        uint256 parts;
        // array of swaps for a specified token
        Swap[] swaps;
    }

    struct ExchangeRequest {
        // source token address
        address from;
        // source token amount to swap
        uint256 amountIn;
        // target token addresses
        address[] to;
        // exchange routes
        ExchangeRoute[] exchangeRoutes;
        // slippage tolerance for each target token
        uint256[] slippage;
        // expected amount for each target token
        uint256[] amountOutExpected;
    }

    event SwapExecuted(
        address indexed account,
        address indexed from,
        uint256 amountIn,
        address[] to,
        uint256[] amountOut
    );

    // @notice Executes a token swap
    // @param request - swap request
    // @return amountsOut - array of amounts that were received for each target token
    // @dev if from token is address(0) and amountIn is 0,
    // then chain native token is used as a source token, and value is used as amountIn
    function swap(ExchangeRequest calldata request) external payable returns (uint256[] memory amountsOut);
}
// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "../interfaces/IWowmaxRouter.sol";

// @title Curve pool interface
interface ICurvePool {
    function exchange(int128 i, int128 j, uint256 dx, uint256 min_dy) external;
}

// @title Curve library
// @notice Functions to swap tokens on Curve like protocols
library Curve {
    using SafeERC20 for IERC20;

    function swap(
        address from,
        uint256 amountIn,
        IWowmaxRouter.Swap memory swapData
    ) internal returns (uint256 amountOut) {
        (int128 i, int128 j) = abi.decode(swapData.data, (int128, int128));
        uint256 balanceBefore = IERC20(swapData.to).balanceOf(address(this));
        //slither-disable-next-line unused-return //it's safe to ignore
        IERC20(from).approve(swapData.addr, amountIn);
        ICurvePool(swapData.addr).exchange(i, j, amountIn, 0);
        amountOut = IERC20(swapData.to).balanceOf(address(this)) - balanceBefore;
    }
}
// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "../interfaces/IWowmaxRouter.sol";

// @title DODO v1 pool interface
interface IDODOV1Pool {
    function sellBaseToken(uint256 amount, uint256 minReceiveQuote, bytes calldata data) external returns (uint256);

    function buyBaseToken(uint256 amount, uint256 maxPayQuote, bytes calldata data) external returns (uint256);
}

// @title DODO v1 library
// @notice Functions to swap tokens on DODO v1 protocol
library DODOV1 {
    using SafeERC20 for IERC20;

    function swap(
        address from,
        uint256 amountIn,
        IWowmaxRouter.Swap memory swapData
    ) internal returns (uint256 amountOut) {
        //slither-disable-next-line unused-return //it's safe to ignore
        IERC20(from).approve(swapData.addr, amountIn);
        amountOut = IDODOV1Pool(swapData.addr).sellBaseToken(amountIn, 0, "");
    }
}
// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "../interfaces/IWowmaxRouter.sol";

// @title DODO v2 pool interface
interface IDODOV2Pool {
    function sellBase(address to) external returns (uint256);

    function sellQuote(address to) external returns (uint256);
}

// @title DODO v2 library
// @notice Functions to swap tokens on DODO v2 protocol
library DODOV2 {
    uint8 internal constant BASE_TO_QUOTE = 0;

    using SafeERC20 for IERC20;

    function swap(
        address from,
        uint256 amountIn,
        IWowmaxRouter.Swap memory swapData
    ) internal returns (uint256 amountOut) {
        IERC20(from).safeTransfer(swapData.addr, amountIn);
        uint8 direction = abi.decode(swapData.data, (uint8));

        if (direction == BASE_TO_QUOTE) {
            amountOut = IDODOV2Pool(swapData.addr).sellBase(address(this));
        } else {
            amountOut = IDODOV2Pool(swapData.addr).sellQuote(address(this));
        }
    }
}
// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "../interfaces/IWowmaxRouter.sol";

// @title Fulcrom pool interface
interface IFulcromPool {
    function swap(address _tokenIn, address _tokenOut, address _receiver) external returns (uint256);
}

// @title Fulcrom library
// @notice Functions to swap tokens on Fulcrom protocol
library Fulcrom {
    using SafeERC20 for IERC20;

    function swap(
        address from,
        uint256 amountIn,
        IWowmaxRouter.Swap memory swapData
    ) internal returns (uint256 amountOut) {
        IERC20(from).safeTransfer(swapData.addr, amountIn);
        amountOut = IFulcromPool(swapData.addr).swap(from, swapData.to, address(this));
    }
}
// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "../interfaces/IWowmaxRouter.sol";

// @title Hashflow router interface
interface IHashflowRouter {
    struct RFQTQuote {
        address pool;
        address externalAccount;
        address trader;
        address effectiveTrader;
        address baseToken;
        address quoteToken;
        uint256 effectiveBaseTokenAmount;
        uint256 maxBaseTokenAmount;
        uint256 maxQuoteTokenAmount;
        uint256 quoteExpiry;
        uint256 nonce;
        bytes32 txid;
        bytes signature;
    }

    function tradeSingleHop(RFQTQuote calldata quote) external payable;
}

// @title Hashflow library
// @notice Functions to swap tokens on Hashflow protocol
library Hashflow {
    using SafeERC20 for IERC20;

    function swap(
        address from,
        uint256 amountIn,
        IWowmaxRouter.Swap memory swapData
    ) internal returns (uint256 amountOut) {
        IHashflowRouter.RFQTQuote memory quote = abi.decode(swapData.data, (IHashflowRouter.RFQTQuote));
        //slither-disable-next-line unused-return //it's safe to ignore
        IERC20(from).approve(swapData.addr, amountIn);
        if (amountIn < quote.maxBaseTokenAmount) {
            quote.effectiveBaseTokenAmount = amountIn;
        }
        uint256 balanceBefore = IERC20(swapData.to).balanceOf(address(this));
        IHashflowRouter(swapData.addr).tradeSingleHop(quote);
        amountOut = IERC20(swapData.to).balanceOf(address(this)) - balanceBefore;
    }
}
// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "../interfaces/IWowmaxRouter.sol";

// @title Level pool interface
interface ILevelPool {
    function swap(address _tokenIn, address _tokenOut, uint256 _minOut, address _to, bytes calldata extradata) external;
}

// @title Level library
// @notice Functions to swap tokens on Level protocol
library Level {
    using SafeERC20 for IERC20;

    function swap(
        address from,
        uint256 amountIn,
        IWowmaxRouter.Swap memory swapData
    ) internal returns (uint256 amountOut) {
        IERC20(from).safeTransfer(swapData.addr, amountIn);
        uint256 balanceBefore = IERC20(swapData.to).balanceOf(address(this));
        ILevelPool(swapData.addr).swap(from, swapData.to, 0, address(this), new bytes(0));
        amountOut = IERC20(swapData.to).balanceOf(address(this)) - balanceBefore;
    }
}
// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "../interfaces/IWowmaxRouter.sol";

// @title PancakeSwap pool interface
interface IPancakeStablePool {
    // @dev Same as Curve but uses uint256 instead of int128
    function exchange(uint256 i, uint256 j, uint256 dx, uint256 min_dy) external;
}

// @title PancakeSwap library
// @notice Functions to swap tokens on PancakeSwap like protocols
library PancakeSwapStable {
    using SafeERC20 for IERC20;

    function swap(
        address from,
        uint256 amountIn,
        IWowmaxRouter.Swap memory swapData
    ) internal returns (uint256 amountOut) {
        (int128 i, int128 j) = abi.decode(swapData.data, (int128, int128));
        uint256 balanceBefore = IERC20(swapData.to).balanceOf(address(this));
        //slither-disable-next-line unused-return //it's safe to ignore
        IERC20(from).approve(swapData.addr, amountIn);
        IPancakeStablePool(swapData.addr).exchange(uint256(uint128(i)), uint256(uint128(j)), amountIn, 0);
        amountOut = IERC20(swapData.to).balanceOf(address(this)) - balanceBefore;
    }
}
// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "../interfaces/IWowmaxRouter.sol";

// @title Saddle pool interface
interface ISaddlePool {
    function swap(uint8 tokenIndexFrom, uint8 tokenIndexTo, uint256 dx, uint256 minDy, uint256 deadline) external;
}

// @title Saddle library
// @notice Functions to swap tokens on Saddle protocol
library Saddle {
    using SafeERC20 for IERC20;

    function swap(
        address from,
        uint256 amountIn,
        IWowmaxRouter.Swap memory swapData
    ) internal returns (uint256 amountOut) {
        (uint8 tokenIndexFrom, uint8 tokenIndexTo) = abi.decode(swapData.data, (uint8, uint8));
        uint256 balanceBefore = IERC20(swapData.to).balanceOf(address(this));
        //slither-disable-next-line unused-return //it's safe to ignore
        IERC20(from).approve(swapData.addr, amountIn);
        ISaddlePool(swapData.addr).swap(tokenIndexFrom, tokenIndexTo, amountIn, 0, type(uint256).max);
        amountOut = IERC20(swapData.to).balanceOf(address(this)) - balanceBefore;
    }
}
// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "../interfaces/IWowmaxRouter.sol";

// @title Uniswap v2 pair interface
interface IUniswapV2Pair {
    function token0() external view returns (address);

    function token1() external view returns (address);

    function getReserves() external view returns (uint112 _reserve0, uint112 _reserve1, uint32 _blockTimestampLast);

    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;

    function router() external returns (address);
}

// @title Uniswap v2 router interface
interface IUniswapV2Router {
    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);
}

// @title Uniswap v2 library
// @notice Functions to swap tokens on Uniswap v2 and compatible protocols
library UniswapV2 {
    uint256 private constant feeDenominator = 10000;

    using SafeERC20 for IERC20;

    function swap(
        address from,
        uint256 amountIn,
        IWowmaxRouter.Swap memory swapData
    ) internal returns (uint256 amountOut) {
        IERC20(from).safeTransfer(swapData.addr, amountIn);
        uint256 fee = abi.decode(swapData.data, (uint256));
        bool directSwap = IUniswapV2Pair(swapData.addr).token0() == from;
        (uint112 reserveIn, uint112 reserveOut) = getReserves(swapData.addr, directSwap);
        amountOut = getAmountOut(amountIn, reserveIn, reserveOut, fee);
        if (amountOut > 0) {
            IUniswapV2Pair(swapData.addr).swap(
                directSwap ? 0 : amountOut,
                directSwap ? amountOut : 0,
                address(this),
                new bytes(0)
            );
        }
    }

    function routerSwap(
        address from,
        uint256 amountIn,
        IWowmaxRouter.Swap memory swapData
    ) internal returns (uint256 amountOut) {
        IUniswapV2Router router = IUniswapV2Router(IUniswapV2Pair(swapData.addr).router());
        IERC20(from).safeApprove(address(router), amountIn);
        address[] memory path = new address[](2);
        path[0] = from;
        path[1] = swapData.to;
        return router.swapExactTokensForTokens(amountIn, 0, path, address(this), type(uint256).max)[1];
    }

    function getReserves(address pair, bool directSwap) private view returns (uint112 reserveIn, uint112 reserveOut) {
        (uint112 reserve0, uint112 reserve1, ) = IUniswapV2Pair(pair).getReserves();
        return directSwap ? (reserve0, reserve1) : (reserve1, reserve0);
    }

    function getAmountOut(
        uint256 amountIn,
        uint112 reserveIn,
        uint112 reserveOut,
        uint256 fee
    ) private pure returns (uint256 amountOut) {
        uint256 amountInWithFee = amountIn * (feeDenominator - fee);
        uint256 numerator = amountInWithFee * reserveOut;
        uint256 denominator = reserveIn * feeDenominator + amountInWithFee;
        amountOut = numerator / denominator;
    }
}
// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "../interfaces/IWowmaxRouter.sol";

// @title Uniswap v3 pool interface
interface IUniswapV3Pool {
    function swap(
        address recipient,
        bool zeroForOne,
        int256 amountSpecified,
        uint160 sqrtPriceLimitX96,
        bytes calldata data
    ) external returns (int256 amount0, int256 amount1);

    function token0() external view returns (address);

    function token1() external view returns (address);
}

// @title Uniswap v3 library
// @notice Functions to swap tokens on Uniswap v3 and compatible protocol
library UniswapV3 {
    using SafeERC20 for IERC20;

    function swap(uint256 amountIn, IWowmaxRouter.Swap memory swapData) internal returns (uint256 amountOut) {
        bool zeroForOne = abi.decode(swapData.data, (bool));
        uint160 sqrtPriceLimitX96 = zeroForOne ? 4295128740 : 1461446703485210103287273052203988822378723970341;
        (int256 amount0, int256 amount1) = IUniswapV3Pool(swapData.addr).swap(
            address(this),
            zeroForOne,
            int256(amountIn),
            sqrtPriceLimitX96,
            new bytes(0)
        );
        amountOut = uint(zeroForOne ? -amount1 : -amount0);
    }

    function invokeCallback(int256 amount0Delta, int256 amount1Delta, bytes calldata /*_data*/) internal {
        if (amount0Delta > 0 && amount1Delta < 0) {
            IERC20(IUniswapV3Pool(msg.sender).token0()).safeTransfer(msg.sender, uint256(amount0Delta));
        } else if (amount0Delta < 0 && amount1Delta > 0) {
            IERC20(IUniswapV3Pool(msg.sender).token1()).safeTransfer(msg.sender, uint256(amount1Delta));
        } else {
            revert("WOWMAX: Uniswap v3 invariant violation");
        }
    }
}
// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "../interfaces/IWowmaxRouter.sol";

// @title Wombat pool interface
interface IWombatPool {
    function swap(
        address fromToken,
        address toToken,
        uint256 fromAmount,
        uint256 minimumToAmount,
        address to,
        uint256 deadline
    ) external returns (uint256 actualToAmount, uint256 haircut);
}

// @title Wombat library
// @notice Functions to swap tokens on Wombat protocol
library Wombat {
    using SafeERC20 for IERC20;

    function swap(
        address from,
        uint256 amountIn,
        IWowmaxRouter.Swap memory swapData
    ) internal returns (uint256 amountOut) {
        IERC20(from).safeApprove(swapData.addr, amountIn);
        (amountOut, ) = IWombatPool(swapData.addr).swap(
            from,
            swapData.to,
            amountIn,
            0,
            address(this),
            type(uint256).max
        );
    }
}
// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "../interfaces/IWowmaxRouter.sol";

// @title WooFi pool interface
interface IWooFiPool {
    function swap(
        address fromToken,
        address toToken,
        uint256 fromAmount,
        uint256 minToAmount,
        address to,
        address rebateTo
    ) external returns (uint256 realToAmount);
}

// @title WooFi library
// @notice Functions to swap tokens on WooFi protocol
library WooFi {
    using SafeERC20 for IERC20;

    function swap(
        address from,
        uint256 amountIn,
        IWowmaxRouter.Swap memory swapData
    ) internal returns (uint256 amountOut) {
        IERC20(from).safeTransfer(swapData.addr, amountIn);
        amountOut = IWooFiPool(swapData.addr).swap(from, swapData.to, amountIn, 0, address(this), address(0x0));
    }
}
// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.7;

import "./interfaces/IWETH.sol";
import "./interfaces/IWowmaxRouter.sol";

import "./libraries/UniswapV2.sol";
import "./libraries/UniswapV3.sol";
import "./libraries/Curve.sol";
import "./libraries/PancakeSwapStable.sol";
import "./libraries/DODOV2.sol";
import "./libraries/DODOV1.sol";
import "./libraries/Hashflow.sol";
import "./libraries/Saddle.sol";
import "./libraries/Wombat.sol";
import "./libraries/Level.sol";
import "./libraries/Fulcrom.sol";
import "./libraries/WooFi.sol";

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "./WowmaxSwapReentrancyGuard.sol";

/// @title WOWMAX Router
/// @notice Router for stateless execution of swaps against multiple DEX protocols
contract WowmaxRouter is IWowmaxRouter, Ownable, WowmaxSwapReentrancyGuard {
    IWETH public WETH;
    address public treasury;

    bytes32 internal constant UNISWAP_V2 = "UNISWAP_V2";
    bytes32 internal constant UNISWAP_V3 = "UNISWAP_V3";
    bytes32 internal constant UNISWAP_V2_ROUTER = "UNISWAP_V2_ROUTER";
    bytes32 internal constant CURVE = "CURVE";
    bytes32 internal constant DODO_V1 = "DODO_V1";
    bytes32 internal constant DODO_V2 = "DODO_V2";
    bytes32 internal constant HASHFLOW = "HASHFLOW";
    bytes32 internal constant PANCAKESWAP_STABLE = "PANCAKESWAP_STABLE";
    bytes32 internal constant SADDLE = "SADDLE";
    bytes32 internal constant WOMBAT = "WOMBAT";
    bytes32 internal constant LEVEL = "LEVEL";
    bytes32 internal constant FULCROM = "FULCROM";
    bytes32 internal constant WOOFI = "WOOFI";

    using SafeERC20 for IERC20;

    constructor(address _weth, address _treasury) {
        require(_weth != address(0), "WOWMAX: Wrong WETH address");
        require(_treasury != address(0), "WOWMAX: Wrong treasury address");

        WETH = IWETH(_weth);
        treasury = _treasury;
    }

    receive() external payable {
        require(_msgSender() == payable(address(WETH)), "WOWMAX: Forbidden token transfer");
        // only accept native chain tokens via fallback from the wrapper contract
    }

    // @inheritdoc IWowmaxRouter
    function swap(
        ExchangeRequest calldata request
    ) external payable override reentrancyProtectedSwap returns (uint256[] memory amountsOut) {
        uint256 amountIn = receiveTokens(request);
        for (uint256 i = 0; i < request.exchangeRoutes.length; i++) {
            exchange(request.exchangeRoutes[i]);
        }
        amountsOut = sendTokens(request);

        emit SwapExecuted(
            msg.sender,
            request.from == address(0) ? address(WETH) : request.from,
            amountIn,
            request.to,
            amountsOut
        );
    }

    // @dev receives source tokens from account or wraps received value
    function receiveTokens(ExchangeRequest calldata request) private returns (uint256) {
        uint256 amountIn;
        if (msg.value > 0 && request.from == address(0) && request.amountIn == 0) {
            amountIn = msg.value;
            WETH.deposit{ value: amountIn }();
        } else {
            if (request.amountIn > 0) {
                amountIn = request.amountIn;
                IERC20(request.from).safeTransferFrom(msg.sender, address(this), amountIn);
            }
        }
        return amountIn;
    }

    // @dev transfers received tokens back to the caller
    function sendTokens(ExchangeRequest calldata request) private returns (uint256[] memory amountsOut) {
        amountsOut = new uint256[](request.to.length);
        uint256 amountOut;
        IERC20 token;
        for (uint256 i = 0; i < request.to.length; i++) {
            token = IERC20(request.to[i]);
            amountOut = token.balanceOf(address(this));

            uint256 amountExtra;
            if (amountOut > request.amountOutExpected[i]) {
                amountExtra = amountOut - request.amountOutExpected[i];
                amountsOut[i] = request.amountOutExpected[i];
            } else {
                require(
                    amountOut >= (request.amountOutExpected[i] * (10000 - request.slippage[i])) / 10000,
                    "WOWMAX: Insufficient output amount"
                );
                amountsOut[i] = amountOut;
            }

            if (address(token) == address(WETH)) {
                WETH.withdraw(amountOut);
            }

            transfer(token, treasury, amountExtra);
            transfer(token, msg.sender, amountsOut[i]);
        }
    }

    // @dev transfer token to a recipient, unwrapping native token if necessary
    function transfer(IERC20 token, address to, uint256 amount) private {
        //slither-disable-next-line incorrect-equality
        if (amount == 0) {
            return;
        }
        if (address(token) == address(WETH)) {
            //slither-disable-next-line arbitrary-send-eth //recipient is either a msg.sender or a treasury
            payable(to).transfer(amount);
        } else {
            token.safeTransfer(to, amount);
        }
    }

    // @dev executes a single exchange route
    function exchange(ExchangeRoute calldata exchangeRoute) private returns (uint256) {
        uint256 amountIn = IERC20(exchangeRoute.from).balanceOf(address(this));
        uint256 amountOut;
        for (uint256 i = 0; i < exchangeRoute.swaps.length; i++) {
            amountOut += executeSwap(
                exchangeRoute.from,
                (amountIn * exchangeRoute.swaps[i].part) / exchangeRoute.parts,
                exchangeRoute.swaps[i]
            );
        }
        return amountOut;
    }

    // @dev executes a single swap
    function executeSwap(address from, uint256 amountIn, Swap calldata swapData) private returns (uint256) {
        if (swapData.family == UNISWAP_V3) {
            return UniswapV3.swap(amountIn, swapData);
        } else if (swapData.family == HASHFLOW) {
            return Hashflow.swap(from, amountIn, swapData);
        } else if (swapData.family == WOMBAT) {
            return Wombat.swap(from, amountIn, swapData);
        } else if (swapData.family == LEVEL) {
            return Level.swap(from, amountIn, swapData);
        } else if (swapData.family == DODO_V2) {
            return DODOV2.swap(from, amountIn, swapData);
        } else if (swapData.family == WOOFI) {
            return WooFi.swap(from, amountIn, swapData);
        } else if (swapData.family == UNISWAP_V2) {
            return UniswapV2.swap(from, amountIn, swapData);
        } else if (swapData.family == CURVE) {
            return Curve.swap(from, amountIn, swapData);
        } else if (swapData.family == PANCAKESWAP_STABLE) {
            return PancakeSwapStable.swap(from, amountIn, swapData);
        } else if (swapData.family == DODO_V1) {
            return DODOV1.swap(from, amountIn, swapData);
        } else if (swapData.family == SADDLE) {
            return Saddle.swap(from, amountIn, swapData);
        } else if (swapData.family == FULCROM) {
            return Fulcrom.swap(from, amountIn, swapData);
        } else if (swapData.family == UNISWAP_V2_ROUTER) {
            return UniswapV2.routerSwap(from, amountIn, swapData);
        } else {
            revert("WOWMAX: Unknown DEX family");
        }
    }

    // Callbacks

    // @dev callback for UniswapV3, is not allowed to be executed outside of a swap operation
    function uniswapV3SwapCallback(
        int256 amount0Delta,
        int256 amount1Delta,
        bytes calldata _data
    ) external onlyDuringSwap {
        UniswapV3.invokeCallback(amount0Delta, amount1Delta, _data);
    }

    // @dev callback for PancakeSwapV3, is not allowed to be executed outside of a swap operation
    function pancakeV3SwapCallback(
        int256 amount0Delta,
        int256 amount1Delta,
        bytes calldata _data
    ) external onlyDuringSwap {
        UniswapV3.invokeCallback(amount0Delta, amount1Delta, _data);
    }

    // Admin functions

    // @dev withdraws tokens from the contract, in case of leftovers after a swap, or invalid swap requests
    function withdraw(address token, uint256 amount) external onlyOwner {
        IERC20(token).safeTransfer(treasury, amount);
    }

    // @dev withdraws chain native tokens from the contract, in case of leftovers after a swap, or invalid swap requests
    function withdrawETH(uint256 amount) external onlyOwner {
        payable(treasury).transfer(amount);
    }
}
// SPDX-License-Identifier: MIT
// Based on OpenZeppelin Contracts (last updated v4.8.0) (security/ReentrancyGuard.sol)
pragma solidity ^0.8.7;

/**
 * @dev Contract module that helps prevent reentrant swaps
 */
abstract contract WowmaxSwapReentrancyGuard {
    uint256 private constant _SWAP_IN_PROGRESS = 1;
    uint256 private constant _SWAP_NOT_IN_PROGRESS = 2;

    uint256 private _swapStatus;

    constructor() {
        _swapStatus = _SWAP_NOT_IN_PROGRESS;
    }

    /**
     * @dev Prevents a contract from calling swap, directly or indirectly
     */
    modifier reentrancyProtectedSwap() {
        _beforeSwap();
        _;
        _afterSwap();
    }

    /**
     * @dev Prevents operation from being called outside of swap
     */
    modifier onlyDuringSwap() {
        require(_swapStatus == _SWAP_IN_PROGRESS, "WOWMAX: not allowed outside of swap");
        _;
    }

    function _beforeSwap() private {
        require(_swapStatus != _SWAP_IN_PROGRESS, "WOWMAX: reentrant swap not allowed");
        _swapStatus = _SWAP_IN_PROGRESS;
    }

    function _afterSwap() private {
        _swapStatus = _SWAP_NOT_IN_PROGRESS;
    }
}
