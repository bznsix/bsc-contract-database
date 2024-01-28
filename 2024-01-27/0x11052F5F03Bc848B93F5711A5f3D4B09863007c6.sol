// SPDX-License-Identifier: MIXED

// Sources flattened with hardhat v2.19.4 https://hardhat.org

// License-Identifier: GPL-3.0-or-later AND MIT AND UNLICENSED

// File @openzeppelin/contracts/token/ERC20/extensions/IERC20Permit.sol@v4.9.5

// Original license: SPDX_License_Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.4) (token/ERC20/extensions/IERC20Permit.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 Permit extension allowing approvals to be made via signatures, as defined in
 * https://eips.ethereum.org/EIPS/eip-2612[EIP-2612].
 *
 * Adds the {permit} method, which can be used to change an account's ERC20 allowance (see {IERC20-allowance}) by
 * presenting a message signed by the account. By not relying on {IERC20-approve}, the token holder account doesn't
 * need to send a transaction, and thus is not required to hold Ether at all.
 *
 * ==== Security Considerations
 *
 * There are two important considerations concerning the use of `permit`. The first is that a valid permit signature
 * expresses an allowance, and it should not be assumed to convey additional meaning. In particular, it should not be
 * considered as an intention to spend the allowance in any specific way. The second is that because permits have
 * built-in replay protection and can be submitted by anyone, they can be frontrun. A protocol that uses permits should
 * take this into consideration and allow a `permit` call to fail. Combining these two aspects, a pattern that may be
 * generally recommended is:
 *
 * ```solidity
 * function doThingWithPermit(..., uint256 value, uint256 deadline, uint8 v, bytes32 r, bytes32 s) public {
 *     try token.permit(msg.sender, address(this), value, deadline, v, r, s) {} catch {}
 *     doThing(..., value);
 * }
 *
 * function doThing(..., uint256 value) public {
 *     token.safeTransferFrom(msg.sender, address(this), value);
 *     ...
 * }
 * ```
 *
 * Observe that: 1) `msg.sender` is used as the owner, leaving no ambiguity as to the signer intent, and 2) the use of
 * `try/catch` allows the permit to fail and makes the code tolerant to frontrunning. (See also
 * {SafeERC20-safeTransferFrom}).
 *
 * Additionally, note that smart contract wallets (such as Argent or Safe) are not able to produce permit signatures, so
 * contracts should have entry points that don't rely on permit.
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
     *
     * CAUTION: See Security Considerations above.
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


// File @openzeppelin/contracts/token/ERC20/IERC20.sol@v4.9.5

// Original license: SPDX_License_Identifier: MIT
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


// File @openzeppelin/contracts/utils/Address.sol@v4.9.5

// Original license: SPDX_License_Identifier: MIT
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


// File @openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol@v4.9.5

// Original license: SPDX_License_Identifier: MIT
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


// File contracts/Lovelyswap/interfaces/ILovelyswapV2ERC20.sol

// Original license: SPDX_License_Identifier: GPL-3.0-or-later
pragma solidity =0.8.15;

interface ILovelyswapV2ERC20 is IERC20 {
    function DOMAIN_SEPARATOR() external view returns (bytes32);

    function PERMIT_TYPEHASH() external pure returns (bytes32);

    function nonces(address owner) external view returns (uint256);

    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;
}


// File contracts/Lovelyswap/interfaces/ILovelyswapV2Pair.sol

// Original license: SPDX_License_Identifier: GPL-3.0-or-later

pragma solidity =0.8.15;

interface ILovelyswapV2Pair is ILovelyswapV2ERC20 {
    event Mint(address indexed sender, uint256 amount0, uint256 amount1);
    event Burn(
        address indexed sender,
        uint256 amount0,
        uint256 amount1,
        address indexed to
    );
    event Swap(
        address indexed sender,
        uint256 amount0In,
        uint256 amount1In,
        uint256 amount0Out,
        uint256 amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint256);

    function factory() external view returns (address);

    function token0() external view returns (address);

    function token1() external view returns (address);

    function getReserves()
        external
        view
        returns (
            uint112 reserve0,
            uint112 reserve1,
            uint32 blockTimestampLast
        );

    function price0CumulativeLast() external view returns (uint256);

    function price1CumulativeLast() external view returns (uint256);

    function kLast() external view returns (uint256);

    function mint(address to) external returns (uint256 liquidity);

    function burn(address to)
        external
        returns (uint256 amount0, uint256 amount1);

    function swap(
        uint256 amount0Out,
        uint256 amount1Out,
        address to,
        bytes calldata data
    ) external;

    function skim(address to) external;

    function sync() external;

    function initialize(address, address) external;
}


// File contracts/interfaces/ILOVELYPairToken.sol

// Original license: SPDX_License_Identifier: UNLICENSED

pragma solidity =0.8.15;

/**
    An interface to represent the LOVELY DEX liquidity pool pair token.

    Used in:
    - LovelyswapV2Router02 (patched);
    - LOVELYAuditedRouter;
    - LOVELYFactory.
 */
interface ILOVELYPairToken is ILovelyswapV2Pair {

    /**
        Initializes a pair with the capability to validate the liquidity pool by paying the fee.
        When "_amount" is zero, the pair is automatically validated.

        @param _token The token, in which the validation amount can be paid.
        @param _amount The amount to be paid to validate the pair. Zero for no validation fee.
        @param _fee The commission for operations in this liquidity pool.
        @param __activationBlockNumber The block number, after which the pair becomes available.
     */
    function initializeValidated(
        address _token,
        uint256 _amount,
        uint256 _fee,
        uint256 __activationBlockNumber
    ) external;

    /**
        Returns the fee for this liquidity pool.

        @return The fee for this liquidity pool.
     */
    function getFee() external view returns (uint256);

    /**
        Returns, how many blocks remains till this liquidity pool becomes active.

        @return The requested amount of remaining blocks.
     */
    function getRemainingActivationBlocks() external view returns (uint256);
}


// File contracts/interfaces/ILOVELYAddressFilter.sol

// Original license: SPDX_License_Identifier: UNLICENSED

pragma solidity =0.8.15;

/**
    An interface for entities, capable to filter a list of matching
    addresses.
 */
interface ILOVELYAddressFilter {

    /**
        For a given address, returns, whether it should be included.

        @param _identifier The identifier for making a projection within the data source context.
        @param _address The address to be checked.
     */
    function included(uint256 _identifier, address _address) external view returns (bool);
}


// File contracts/interfaces/ILOVELYCompetitions.sol

// Original license: SPDX_License_Identifier: UNLICENSED

pragma solidity =0.8.15;

interface ILOVELYCompetitions {
    function eventBlockRange(uint256 _eventIdentifier) external view returns (uint[] memory);
}


// File @openzeppelin/contracts/security/ReentrancyGuard.sol@v4.9.5

// Original license: SPDX_License_Identifier: MIT
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


// File contracts/Lovelyswap/interfaces/IWETH.sol

// Original license: SPDX_License_Identifier: GPL-3.0-or-later
pragma solidity =0.8.15;

interface IWETH {
    function deposit() external payable;

    function transfer(address to, uint256 value) external returns (bool);

    function withdraw(uint256) external;
}


// File contracts/Lovelyswap/libraries/TransferHelper.sol

// Original license: SPDX_License_Identifier: GPL-3.0-or-later

pragma solidity =0.8.15;

// helper methods for interacting with ERC20 tokens and sending ETH that do not consistently return true/false
library TransferHelper {
    function safeApprove(
        address token,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('approve(address,uint256)')));
        (bool success, bytes memory data) = token.call(
            abi.encodeWithSelector(0x095ea7b3, to, value)
        );
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            "TransferHelper::safeApprove: approve failed"
        );
    }

    function safeTransfer(
        address token,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('transfer(address,uint256)')));
        (bool success, bytes memory data) = token.call(
            abi.encodeWithSelector(0xa9059cbb, to, value)
        );
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            "TransferHelper::safeTransfer: transfer failed"
        );
    }

    function safeTransferFrom(
        address token,
        address from,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
        (bool success, bytes memory data) = token.call(
            abi.encodeWithSelector(0x23b872dd, from, to, value)
        );
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            "TransferHelper::transferFrom: transferFrom failed"
        );
    }

    function safeTransferETH(address to, uint256 value) internal {
        (bool success, ) = to.call{value: value}(new bytes(0));
        require(
            success,
            "TransferHelper::safeTransferETH: ETH transfer failed"
        );
    }
}


// File contracts/Lovelyswap/v2-periphery-patched/ILovelyswapV2Router01.sol

// Original license: SPDX_License_Identifier: UNLICENSED
pragma solidity =0.8.15;

interface ILovelyswapV2Router01 {
    function factory() external returns (address);
    function WETH() external returns (address);

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
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut, uint fee) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut, uint fee) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path, uint fee) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path, uint fee) external view returns (uint[] memory amounts);
}


// File contracts/Lovelyswap/v2-periphery-patched/ILovelyswapV2Router02.sol

// Original license: SPDX_License_Identifier: UNLICENSED
pragma solidity =0.8.15;

interface ILovelyswapV2Router02 is ILovelyswapV2Router01 {
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


// File contracts/Lovelyswap/interfaces/ILovelyswapV2Factory.sol

// Original license: SPDX_License_Identifier: GPL-3.0-or-later

pragma solidity =0.8.15;

interface ILovelyswapV2Factory {
    event PairCreated(
        address indexed token0,
        address indexed token1,
        address pair,
        uint256
    );

    function feeTo() external view returns (address);

    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB)
        external
        view
        returns (address pair);

    function allPairs(uint256) external view returns (address pair);

    function allPairsLength() external view returns (uint256);

    function setFeeTo(address) external;

    function setFeeToSetter(address) external;
}


// File contracts/Lovelyswap/v2-periphery-patched/LovelyswapV2Library.sol

// Original license: SPDX_License_Identifier: UNLICENSED
pragma solidity =0.8.15;


library LovelyswapV2Library {

    // returns sorted token addresses, used to handle return values from pairs sorted in this order
    function sortTokens(address tokenA, address tokenB) internal pure returns (address token0, address token1) {
        require(tokenA != tokenB, 'LOVELYV4Library: IDENTICAL_ADDRESSES');
        (token0, token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
        require(token0 != address(0), 'LOVELYV4Library: ZERO_ADDRESS');
    }

    // calculates the CREATE2 address for a pair without making any external calls
    function pairFor(address factory, address tokenA, address tokenB) internal view returns (address pair) {
        pair = ILovelyswapV2Factory(factory).getPair(tokenA,tokenB);
    }

    // fetches and sorts the reserves for a pair
    function getReserves(address factory, address tokenA, address tokenB) internal view returns (uint reserveA, uint reserveB) {
        (address token0,) = sortTokens(tokenA, tokenB);
        (uint reserve0, uint reserve1,) = ILovelyswapV2Pair(pairFor(factory, tokenA, tokenB)).getReserves();
        (reserveA, reserveB) = tokenA == token0 ? (reserve0, reserve1) : (reserve1, reserve0);
    }

    // given some amount of an asset and pair reserves, returns an equivalent amount of the other asset
    function quote(uint amountA, uint reserveA, uint reserveB) internal pure returns (uint amountB) {
        require(amountA > 0, 'LOVELYV4Library: INSUFFICIENT_AMOUNT');
        require(reserveA > 0 && reserveB > 0, 'LOVELYV4Library: INSUFFICIENT_LIQUIDITY');
        amountB = amountA * reserveB / reserveA;
    }

    // given an input amount of an asset and pair reserves, returns the maximum output amount of the other asset
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut, uint fee) internal pure returns (uint amountOut) {
        require(amountIn > 0, 'LOVELYV4Library: INSUFFICIENT_INPUT_AMOUNT');
        require(reserveIn > 0 && reserveOut > 0, 'LOVELYV4Library: INSUFFICIENT_LIQUIDITY');
        uint amountInWithFee = amountIn * (1000 - fee);
        uint numerator = amountInWithFee * reserveOut;
        uint denominator = reserveIn * 1000 + amountInWithFee;
        amountOut = numerator / denominator;
    }

    // given an output amount of an asset and pair reserves, returns a required input amount of the other asset
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut, uint fee) internal pure returns (uint amountIn) {
        require(amountOut > 0, 'LOVELYV4Library: INSUFFICIENT_OUTPUT_AMOUNT');
        require(reserveIn > 0 && reserveOut > 0, 'LOVELYV4Library: INSUFFICIENT_LIQUIDITY');
        uint numerator = reserveIn * amountOut * 1000;
        uint denominator = (reserveOut - amountOut) * (1000 - fee);
        amountIn = (numerator / denominator) + 1;
    }

    // performs chained getAmountOut calculations on any number of pairs
    function getAmountsOut(address factory, uint amountIn, address[] memory path, uint fee) internal view returns (uint[] memory amounts) {
        require(path.length >= 2, 'LOVELYV4Library: INVALID_PATH');
        amounts = new uint[](path.length);
        amounts[0] = amountIn;
        for (uint i; i < path.length - 1; i++) {
            (uint reserveIn, uint reserveOut) = getReserves(factory, path[i], path[i + 1]);
            amounts[i + 1] = getAmountOut(amounts[i], reserveIn, reserveOut, fee);
        }
    }

    // performs chained getAmountIn calculations on any number of pairs
    function getAmountsIn(address factory, uint amountOut, address[] memory path, uint fee) internal view returns (uint[] memory amounts) {
        require(path.length >= 2, 'LOVELYV4Library: INVALID_PATH');
        amounts = new uint[](path.length);
        amounts[amounts.length - 1] = amountOut;
        for (uint i = path.length - 1; i > 0; i--) {
            (uint reserveIn, uint reserveOut) = getReserves(factory, path[i - 1], path[i]);
            amounts[i - 1] = getAmountIn(amounts[i], reserveIn, reserveOut, fee);
        }
    }
}


// File contracts/Lovelyswap/v2-periphery-patched/LovelyswapV2Router02.sol

// Original license: SPDX_License_Identifier: UNLICENSED
pragma solidity =0.8.15;






contract LovelyswapV2Router02 is ILovelyswapV2Router02, ReentrancyGuard {

    address public immutable override factory;
    address public immutable override WETH;

    modifier ensure(uint deadline) {
        require(deadline >= block.timestamp, 'LOVELYV4Router: EXPIRED');
        _;
    }

    constructor(address _factory, address _WETH) {
        factory = _factory;
        WETH = _WETH;
    }

    receive() external payable {
        assert(msg.sender == WETH);
        // only accept ETH via fallback from the WETH contract
    }

    // **** ADD LIQUIDITY ****
    function _addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin
    ) internal virtual returns (uint amountA, uint amountB) {
        (uint reserveA, uint reserveB) = LovelyswapV2Library.getReserves(factory, tokenA, tokenB);
        if (reserveA == 0 && reserveB == 0) {
            (amountA, amountB) = (amountADesired, amountBDesired);
        } else {
            uint amountBOptimal = LovelyswapV2Library.quote(amountADesired, reserveA, reserveB);
            if (amountBOptimal <= amountBDesired) {
                require(amountBOptimal >= amountBMin, 'LOVELYV4Router: INSUFFICIENT_B_AMOUNT');
                (amountA, amountB) = (amountADesired, amountBOptimal);
            } else {
                uint amountAOptimal = LovelyswapV2Library.quote(amountBDesired, reserveB, reserveA);
                assert(amountAOptimal <= amountADesired);
                require(amountAOptimal >= amountAMin, 'LOVELYV4Router: INSUFFICIENT_A_AMOUNT');
                (amountA, amountB) = (amountAOptimal, amountBDesired);
            }
        }
    }

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external virtual override ensure(deadline) nonReentrant returns (uint amountA, uint amountB, uint liquidity) {
        (amountA, amountB) = _addLiquidity(tokenA, tokenB, amountADesired, amountBDesired, amountAMin, amountBMin);
        address pair = LovelyswapV2Library.pairFor(factory, tokenA, tokenB);
        TransferHelper.safeTransferFrom(tokenA, msg.sender, pair, amountA);
        TransferHelper.safeTransferFrom(tokenB, msg.sender, pair, amountB);
        liquidity = ILovelyswapV2Pair(pair).mint(to);
    }

    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external virtual override payable ensure(deadline) nonReentrant returns (uint amountToken, uint amountETH, uint liquidity) {
        (amountToken, amountETH) = _addLiquidity(
            token,
            WETH,
            amountTokenDesired,
            msg.value,
            amountTokenMin,
            amountETHMin
        );
        address pair = LovelyswapV2Library.pairFor(factory, token, WETH);
        TransferHelper.safeTransferFrom(token, msg.sender, pair, amountToken);
        IWETH(WETH).deposit{value : amountETH}();
        assert(IWETH(WETH).transfer(pair, amountETH));
        liquidity = ILovelyswapV2Pair(pair).mint(to);
        // refund dust eth, if any
        if (msg.value > amountETH) TransferHelper.safeTransferETH(msg.sender, msg.value - amountETH);
    }

    // **** REMOVE LIQUIDITY ****
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) public virtual override ensure(deadline) returns (uint amountA, uint amountB) {
        address pair = LovelyswapV2Library.pairFor(factory, tokenA, tokenB);
        ILovelyswapV2Pair(pair).transferFrom(msg.sender, pair, liquidity);
        // send liquidity to pair
        (uint amount0, uint amount1) = ILovelyswapV2Pair(pair).burn(to);
        (address token0,) = LovelyswapV2Library.sortTokens(tokenA, tokenB);
        (amountA, amountB) = tokenA == token0 ? (amount0, amount1) : (amount1, amount0);
        require(amountA >= amountAMin, 'LOVELYV4Router: INSUFFICIENT_A_AMOUNT');
        require(amountB >= amountBMin, 'LOVELYV4Router: INSUFFICIENT_B_AMOUNT');
    }

    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) public virtual override ensure(deadline) returns (uint amountToken, uint amountETH) {
        (amountToken, amountETH) = removeLiquidity(
            token,
            WETH,
            liquidity,
            amountTokenMin,
            amountETHMin,
            address(this),
            deadline
        );
        TransferHelper.safeTransfer(token, to, amountToken);
        IWETH(WETH).withdraw(amountETH);
        TransferHelper.safeTransferETH(to, amountETH);
    }

    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external virtual override returns (uint amountA, uint amountB) {
        address pair = LovelyswapV2Library.pairFor(factory, tokenA, tokenB);
        uint value = approveMax ? type(uint).max : liquidity;
        ILovelyswapV2Pair(pair).permit(msg.sender, address(this), value, deadline, v, r, s);
        (amountA, amountB) = removeLiquidity(tokenA, tokenB, liquidity, amountAMin, amountBMin, to, deadline);
    }

    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external virtual override returns (uint amountToken, uint amountETH) {
        address pair = LovelyswapV2Library.pairFor(factory, token, WETH);
        uint value = approveMax ? type(uint).max : liquidity;
        ILovelyswapV2Pair(pair).permit(msg.sender, address(this), value, deadline, v, r, s);
        (amountToken, amountETH) = removeLiquidityETH(token, liquidity, amountTokenMin, amountETHMin, to, deadline);
    }

    // **** REMOVE LIQUIDITY (supporting fee-on-transfer tokens) ****
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) public virtual override ensure(deadline) returns (uint amountETH) {
        (, amountETH) = removeLiquidity(
            token,
            WETH,
            liquidity,
            amountTokenMin,
            amountETHMin,
            address(this),
            deadline
        );
        TransferHelper.safeTransfer(token, to, IERC20(token).balanceOf(address(this)));
        IWETH(WETH).withdraw(amountETH);
        TransferHelper.safeTransferETH(to, amountETH);
    }

    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external virtual override returns (uint amountETH) {
        address pair = LovelyswapV2Library.pairFor(factory, token, WETH);
        uint value = approveMax ? type(uint).max : liquidity;
        ILovelyswapV2Pair(pair).permit(msg.sender, address(this), value, deadline, v, r, s);
        amountETH = removeLiquidityETHSupportingFeeOnTransferTokens(
            token, liquidity, amountTokenMin, amountETHMin, to, deadline
        );
    }

    // **** SWAP ****
    // requires the initial amount to have already been sent to the first pair
    function _swap(uint[] memory amounts, address[] memory path, address _to) internal virtual {
        for (uint i; i < path.length - 1; i++) {
            (address input, address output) = (path[i], path[i + 1]);
            (address token0,) = LovelyswapV2Library.sortTokens(input, output);
            uint amountOut = amounts[i + 1];
            (uint amount0Out, uint amount1Out) = input == token0 ? (uint(0), amountOut) : (amountOut, uint(0));
            address to = i < path.length - 2 ? LovelyswapV2Library.pairFor(factory, output, path[i + 2]) : _to;
            ILovelyswapV2Pair(LovelyswapV2Library.pairFor(factory, input, output)).swap(
                amount0Out, amount1Out, to, new bytes(0)
            );
        }
    }

    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external virtual override ensure(deadline) returns (uint[] memory amounts) {
        address pair = LovelyswapV2Library.pairFor(factory, path[0], path[1]);
        uint fee = ILOVELYPairToken(pair).getFee();
        amounts = LovelyswapV2Library.getAmountsOut(factory, amountIn, path, fee);
        require(amounts[amounts.length - 1] >= amountOutMin, 'LOVELYV4Router: INSUFFICIENT_OUTPUT_AMOUNT');
        TransferHelper.safeTransferFrom(
            path[0], msg.sender, pair, amounts[0]
        );
        _swap(amounts, path, to);
    }

    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external virtual override ensure(deadline) returns (uint[] memory amounts) {
        address pair = LovelyswapV2Library.pairFor(factory, path[0], path[1]);
        uint fee = ILOVELYPairToken(pair).getFee();
        amounts = LovelyswapV2Library.getAmountsIn(factory, amountOut, path, fee);
        require(amounts[0] <= amountInMax, 'LOVELYV4Router: EXCESSIVE_INPUT_AMOUNT');
        TransferHelper.safeTransferFrom(
            path[0], msg.sender, pair, amounts[0]
        );
        _swap(amounts, path, to);
    }

    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
    external
    virtual
    override
    payable
    ensure(deadline)
    returns (uint[] memory amounts)
    {
        address pair = LovelyswapV2Library.pairFor(factory, path[0], path[1]);
        uint fee = ILOVELYPairToken(pair).getFee();
        require(path[0] == WETH, 'LOVELYV4Router: INVALID_PATH');
        amounts = LovelyswapV2Library.getAmountsOut(factory, msg.value, path, fee);
        require(amounts[amounts.length - 1] >= amountOutMin, 'LOVELYV4Router: INSUFFICIENT_OUTPUT_AMOUNT');
        IWETH(WETH).deposit{value : amounts[0]}();
        assert(IWETH(WETH).transfer(pair, amounts[0]));
        _swap(amounts, path, to);
    }

    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
    external
    virtual
    override
    ensure(deadline)
    nonReentrant
    returns (uint[] memory amounts)
    {
        address pair = LovelyswapV2Library.pairFor(factory, path[0], path[1]);
        uint fee = ILOVELYPairToken(pair).getFee();
        require(path[path.length - 1] == WETH, 'LOVELYV4Router: INVALID_PATH');
        amounts = LovelyswapV2Library.getAmountsIn(factory, amountOut, path, fee);
        require(amounts[0] <= amountInMax, 'LOVELYV4Router: EXCESSIVE_INPUT_AMOUNT');
        TransferHelper.safeTransferFrom(
            path[0], msg.sender, pair, amounts[0]
        );
        _swap(amounts, path, address(this));
        IWETH(WETH).withdraw(amounts[amounts.length - 1]);
        TransferHelper.safeTransferETH(to, amounts[amounts.length - 1]);
    }

    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
    external
    virtual
    override
    ensure(deadline)
    nonReentrant
    returns (uint[] memory amounts)
    {
        address pair = LovelyswapV2Library.pairFor(factory, path[0], path[1]);
        uint fee = ILOVELYPairToken(pair).getFee();
        require(path[path.length - 1] == WETH, 'LOVELYV4Router: INVALID_PATH');
        amounts = LovelyswapV2Library.getAmountsOut(factory, amountIn, path, fee);
        require(amounts[amounts.length - 1] >= amountOutMin, 'LOVELYV4Router: INSUFFICIENT_OUTPUT_AMOUNT');
        TransferHelper.safeTransferFrom(
            path[0], msg.sender, pair, amounts[0]
        );
        _swap(amounts, path, address(this));
        IWETH(WETH).withdraw(amounts[amounts.length - 1]);
        TransferHelper.safeTransferETH(to, amounts[amounts.length - 1]);
    }

    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
    external
    virtual
    override
    payable
    ensure(deadline)
    returns (uint[] memory amounts)
    {
        address pair = LovelyswapV2Library.pairFor(factory, path[0], path[1]);
        uint fee = ILOVELYPairToken(pair).getFee();
        require(path[0] == WETH, 'LOVELYV4Router: INVALID_PATH');
        amounts = LovelyswapV2Library.getAmountsIn(factory, amountOut, path, fee);
        require(amounts[0] <= msg.value, 'LOVELYV4Router: EXCESSIVE_INPUT_AMOUNT');
        IWETH(WETH).deposit{value : amounts[0]}();
        assert(IWETH(WETH).transfer(pair, amounts[0]));
        _swap(amounts, path, to);
        // refund dust eth, if any
        if (msg.value > amounts[0]) TransferHelper.safeTransferETH(msg.sender, msg.value - amounts[0]);
    }

    // **** SWAP (supporting fee-on-transfer tokens) ****
    // requires the initial amount to have already been sent to the first pair
    function _swapSupportingFeeOnTransferTokens(address[] memory path, address _to) internal virtual {
        for (uint i; i < path.length - 1; i++) {
            (address input, address output) = (path[i], path[i + 1]);
            (address token0,) = LovelyswapV2Library.sortTokens(input, output);
            ILOVELYPairToken pair = ILOVELYPairToken(LovelyswapV2Library.pairFor(factory, input, output));
            uint fee = pair.getFee();
            uint amountInput;
            uint amountOutput;
            {// scope to avoid stack too deep errors
                (uint reserve0, uint reserve1,) = pair.getReserves();
                (uint reserveInput, uint reserveOutput) = input == token0 ? (reserve0, reserve1) : (reserve1, reserve0);
                amountInput = IERC20(input).balanceOf(address(pair)) - reserveInput;
                amountOutput = LovelyswapV2Library.getAmountOut(amountInput, reserveInput, reserveOutput, fee);
            }
            (uint amount0Out, uint amount1Out) = input == token0 ? (uint(0), amountOutput) : (amountOutput, uint(0));
            address to = i < path.length - 2 ? LovelyswapV2Library.pairFor(factory, output, path[i + 2]) : _to;
            pair.swap(amount0Out, amount1Out, to, new bytes(0));
        }
    }

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external virtual override ensure(deadline) nonReentrant {
        TransferHelper.safeTransferFrom(
            path[0], msg.sender, LovelyswapV2Library.pairFor(factory, path[0], path[1]), amountIn
        );
        uint balanceBefore = IERC20(path[path.length - 1]).balanceOf(to);
        _swapSupportingFeeOnTransferTokens(path, to);
        require(
            IERC20(path[path.length - 1]).balanceOf(to) - balanceBefore >= amountOutMin,
            'LOVELYV4Router: INSUFFICIENT_OUTPUT_AMOUNT'
        );
    }

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    )
    external
    virtual
    override
    payable
    ensure(deadline)
    nonReentrant
    {
        require(path[0] == WETH, 'LOVELYV4Router: INVALID_PATH');
        uint amountIn = msg.value;
        IWETH(WETH).deposit{value : amountIn}();
        assert(IWETH(WETH).transfer(LovelyswapV2Library.pairFor(factory, path[0], path[1]), amountIn));
        uint balanceBefore = IERC20(path[path.length - 1]).balanceOf(to);
        _swapSupportingFeeOnTransferTokens(path, to);
        require(
            IERC20(path[path.length - 1]).balanceOf(to) - balanceBefore >= amountOutMin,
            'LOVELYV4Router: INSUFFICIENT_OUTPUT_AMOUNT'
        );
    }

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    )
    external
    virtual
    override
    ensure(deadline)
    nonReentrant
    {
        require(path[path.length - 1] == WETH, 'LOVELYV4Router: INVALID_PATH');
        TransferHelper.safeTransferFrom(
            path[0], msg.sender, LovelyswapV2Library.pairFor(factory, path[0], path[1]), amountIn
        );
        _swapSupportingFeeOnTransferTokens(path, address(this));
        uint amountOut = IERC20(WETH).balanceOf(address(this));
        require(amountOut >= amountOutMin, 'LOVELYV4Router: INSUFFICIENT_OUTPUT_AMOUNT');
        IWETH(WETH).withdraw(amountOut);
        TransferHelper.safeTransferETH(to, amountOut);
    }

    // **** LIBRARY FUNCTIONS ****
    function quote(uint amountA, uint reserveA, uint reserveB) public pure virtual override returns (uint amountB) {
        return LovelyswapV2Library.quote(amountA, reserveA, reserveB);
    }

    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut, uint fee)
    public
    pure
    virtual
    override
    returns (uint amountOut)
    {
        return LovelyswapV2Library.getAmountOut(amountIn, reserveIn, reserveOut, fee);
    }

    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut, uint fee)
    public
    pure
    virtual
    override
    returns (uint amountIn)
    {
        return LovelyswapV2Library.getAmountIn(amountOut, reserveIn, reserveOut, fee);
    }

    function getAmountsOut(uint amountIn, address[] memory path, uint fee)
    public
    view
    virtual
    override
    returns (uint[] memory amounts)
    {
        return LovelyswapV2Library.getAmountsOut(factory, amountIn, path, fee);
    }

    function getAmountsIn(uint amountOut, address[] memory path, uint fee)
    public
    view
    virtual
    override
    returns (uint[] memory amounts)
    {
        return LovelyswapV2Library.getAmountsIn(factory, amountOut, path, fee);
    }
}


// File contracts/LOVELYRouter.sol

// Original license: SPDX_License_Identifier: UNLICENSED

pragma solidity =0.8.15;

/**
    The default DEX router based on the Lovelyswap V2 router.
 */
contract LOVELYRouter is LovelyswapV2Router02 {

    /**
        Creates a new default routers instance.

        @param theFactory The DEX factory to be attached to the router.
        @param theWETH The WETH address to be used in the DEX.
     */
    constructor(address theFactory, address theWETH) LovelyswapV2Router02(theFactory, theWETH) {
    }
}


// File contracts/LOVELYAuditedRouter.sol

// Original license: SPDX_License_Identifier: UNLICENSED

pragma solidity =0.8.15;





/**
    @title The DEX's router, which can be enabled to collect data for the trades oracle.

    The trades oracle serves for tracking the trades history on-chain.
    Such tracking might be necessary for particular events, which can be researched or analytics
    for which may be used to build additional business processes.


    The overall process to use the trades oracle:
    1. An event is started.
    2. This event creates an instance of the audited router.
    3. The whole system or a part of the system is switched to using this router.
    4. Data is collected.
    5. The event is finished.
    6. The whole system or a part of the system switches back to the usual router.
    7. Collected data is analyzed on-chain.

    The outcome of such behavior is ability to proof the trades data on-chain.
 */
contract LOVELYAuditedRouter is LOVELYRouter {

    // The tracked token.
    address private target;

    /**
        The list of tracked  addresses.
     */
    address[] public addresses;

    uint private eventIdentifier;

    address father;

    /**
        Contains volumes for each tracked address.
     */
    mapping(address => uint256) public volumes;

    /**
        Creates the audited router with the trades oracle.

        @param theFactory The DEX factory, to be able to interact with the DEX.
        @param theWETH The WETH token address, to be able to create a router.
        @param theTarget A token, for which the audition will be performed.
     */
    constructor(address theFactory, address theWETH, address competitions, address theTarget, uint _eventIdentifier) LOVELYRouter(theFactory, theWETH) {
        assert(address(0) != theFactory && address(0) != theWETH && address(0) != theTarget);
        father = competitions;
        target = theTarget;
        eventIdentifier = _eventIdentifier;
    }

    /**
        Returns the given amount of top-volume tracked addresses.

        @param count The amount of addresses to be returned.
     */
    function topAddresses(uint256 count) external view returns (address[] memory) {
        assert(0 < addresses.length);

        // Sort addresses based on volumes in descending order
        address[] memory sortedAddresses = new address[](addresses.length);
        for (uint256 i = 0; i < addresses.length; i++) {
            sortedAddresses[i] = addresses[i];
        }

        for (uint256 i = 0; i < sortedAddresses.length; i++) {
            for (uint256 j = i + 1; j < sortedAddresses.length; j++) {
                if (volumes[sortedAddresses[i]] < volumes[sortedAddresses[j]]) {
                    address temp = sortedAddresses[i];
                    sortedAddresses[i] = sortedAddresses[j];
                    sortedAddresses[j] = temp;
                }
            }
        }

        // Return the top 50 addresses or all addresses if there are fewer than 50
        count = addresses.length < count ? addresses.length : count;
        address[] memory top = new address[](count);
        for (uint256 i = 0; i < count; i++) {
            top[i] = sortedAddresses[i];
        }

        return top;

        // While requesting more top addresses, than ones, who were using this router, reduce the requested amount to
        // the factually available count.
        // if (count > addresses.length) {
        //     count = addresses.length;
        // }

        // address[] memory top = new address[](count);
        // address[] memory processed = addresses;

        // for (uint256 i = 0; i < count; i++) {

        //     uint256 biggest = i;
        //     uint256 biggestValue = 0;
        //     for (uint256 k = i; k < addresses.length; k++) {
        //         address targetAddress = addresses[k];
        //         if (
        //             biggestValue < volumes[targetAddress] &&
        //             (address(0x0) == address(theFilter) || theFilter.included(theContextIdentifier, targetAddress))) {
        //             biggest = k;
        //             biggestValue = volumes[targetAddress];
        //         }
        //     }

        //     // 3-glass exchange :)
        //     address glass = processed[i];
        //     processed[i] = processed[biggest];
        //     processed[biggest] = glass;

        //     top[i] = processed[i];
        // }

        // return top;
    }

    /**
        Returns the length of the tracked addresses list.
     */
    function addressesLength() external view returns (uint256) {
        return addresses.length;
    }

    /**
        An empty implementation to reduce the contract size.
     */
    function addLiquidity(
        address,
        address,
        uint,
        uint,
        uint,
        uint,
        address,
        uint
    ) external virtual override returns (uint amountA, uint amountB, uint liquidity) {
        return (0, 0, 0);
    }

    /**
        An empty implementation to reduce the contract size.
     */
    function addLiquidityETH(
        address,
        uint,
        uint,
        uint,
        address,
        uint
    ) external virtual override payable returns (uint amountToken, uint amountETH, uint liquidity) {
        return (0, 0, 0);
    }

    /**
        An empty implementation to reduce the contract size.
     */
    function removeLiquidity(
        address,
        address,
        uint,
        uint,
        uint,
        address,
        uint
    ) public virtual override returns (uint amountA, uint amountB) {
        return (0, 0);
    }

    /**
        Internally hooks into the "_swap" router's call to record necessary data.

        The volume is accumulated for the given target token.
     */
    function _swap(uint[] memory amounts, address[] memory path, address _to) internal override {
        for (uint i; i < path.length - 1; i++) {
            (address input, address output) = (path[i], path[i + 1]);
            (address token0,) = LovelyswapV2Library.sortTokens(input, output);
            uint amountOut = amounts[i + 1];
            (uint amount0Out, uint amount1Out) = input == token0 ? (uint(0), amountOut) : (amountOut, uint(0));
            address to = i < path.length - 2 ? LovelyswapV2Library.pairFor(factory, output, path[i + 2]) : _to;
            ILovelyswapV2Pair(LovelyswapV2Library.pairFor(factory, input, output)).swap(
                amount0Out, amount1Out, to, new bytes(0)
            );

            // Track into the audition log
            // (if no volume before, but new volume is more than zero)
            // (and if either input or output tokens match the target for this audition)
            uint[] memory blocks = ILOVELYCompetitions(father).eventBlockRange(eventIdentifier);
            if (blocks[0] <= block.number && block.number <= blocks[1]) {
                if ((target == input || target == output) && 0 == volumes[to] && (0 < amount0Out + amount1Out)) {
                    addresses.push(to);
                }
                
                if (target == input) {
                    volumes[to] += amounts[i];
                }
                if (target == output) {
                    volumes[to] += amounts[i + 1];
                }
                
            }
        }
    }

    /**
        Internally hooks into the "_swapSupportingFeeOnTransferTokens" router's call to record necessary data.

        The volume is accumulated for the given target token.
     */
    function _swapSupportingFeeOnTransferTokens(address[] memory path, address _to) internal override {
        for (uint i; i < path.length - 1; i++) {
            (address input, address output) = (path[i], path[i + 1]);
            (address token0,) = LovelyswapV2Library.sortTokens(input, output);
            ILOVELYPairToken pair = ILOVELYPairToken(LovelyswapV2Library.pairFor(factory, input, output));
            uint fee = pair.getFee();
            uint amountInput;
            uint amountOutput;
            {// scope to avoid stack too deep errors
                (uint reserve0, uint reserve1,) = pair.getReserves();
                (uint reserveInput, uint reserveOutput) = input == token0 ? (reserve0, reserve1) : (reserve1, reserve0);
                uint256 balance = IERC20(input).balanceOf(address(pair));
                amountInput = balance - reserveInput;
                amountOutput = LovelyswapV2Library.getAmountOut(amountInput, reserveInput, reserveOutput, fee);
            }
            (uint amount0Out, uint amount1Out) = input == token0 ? (uint(0), amountOutput) : (amountOutput, uint(0));
            address to = i < path.length - 2 ? LovelyswapV2Library.pairFor(factory, output, path[i + 2]) : _to;
            pair.swap(amount0Out, amount1Out, to, new bytes(0));

            // Track into the audition log
            // (if no volume before, but new volume is more than zero)
            // (and if either input or output tokens match the target for this audition)
            uint[] memory blocks = ILOVELYCompetitions(father).eventBlockRange(eventIdentifier);
            if (blocks[0] <= block.number && block.number <= blocks[1]) {
                if ((target == input || target == output) && 0 == volumes[to] && (0 < amount0Out + amount1Out)) {
                    addresses.push(to);
                }

                if (target == input) {
                    volumes[to] += amountInput;
                }
                if (target == output) {
                    volumes[to] += amountOutput;
                }
            }
        }
    }
}


// File contracts/interfaces/ILOVELYTokenList.sol

// Original license: SPDX_License_Identifier: UNLICENSED

pragma solidity =0.8.15;

/**
    An interface to represent the LOVELY DEX token listing.

    Used in:
    - LOVELYFactory;
    - LOVELYCompetition.
 */
interface ILOVELYTokenList {

    /**
        Returns, whether the given token is validated in the DEX.
        The token is validated when the validation amount in the given token is paid.

        @param _token The token to be checked.

		@return Whether the given token is validated in the DEX.
	 */
    function validated(address _token) external view returns (bool);

    function defaultValidationToken() external view returns (address);
}


// File contracts/LOVELYCompetition.sol

// Original license: SPDX_License_Identifier: UNLICENSED

pragma solidity =0.8.15;



//competitionEvent.router.topAddresses(50, _eventIdentifier, this);

/**
    @title The trading competitions factory.

    @dev The competition's lifecycle works according to the following state machine:
        1. Initially, the competition is created using the "Registration" status.
        2. Then, the competition can be moved to the "Open" status meaning that the competition has started
        and the competition router should be used for processing transactions.
        3. Then, the competition moves to the "Close" state meaning that it has ended.
        4. After that, the competition can be announced as "Claiming". While moving to this status, the leaders are calculated and stored.
        5. Finally, the competition moves to the "Over" state which is the final state in which nothing more will happen to the competition.

    The competition's winners are determined on-chain to provide the most fair judgement.
    To accomplish this, the LOVELYAuditedRouted is used to track all transaction amounts during the competition.
 */
contract LOVELYCompetition is ILOVELYAddressFilter {
    // Competition event winners tier.
    enum Tier {
        Zero,
        First,
        Second,
        Third
    }

    // Competition even memory slot.
    struct Event {
        // Event start block.
        uint[] blockRange;

        // Total reward amount for event winners.
        uint256 rewardAmount;

        // Event reward token.
        address rewardToken;

        // Event creator
        address creator;

        // A reference to the audited router.
        LOVELYAuditedRouter router;

        // Event tier reward percentages.
        mapping(Tier => uint256) tiers;

        // Event participants.
        mapping(address => User) users;

        // Event winners.
        address[] winners;
    }

    // Competition participant user memory slot.
    struct User {

        // Whether the user is registered to an event.
        bool registered;

        // Whether the user has claimed his reward.
        bool claimed;
    }

    /**
        Count of events, created by this factory.
     */
    uint256 public eventCount;

    /**
        Minimum reward amount for an event.
     */
    uint256 public minimumRewardAmount;

    /**
        A reference to the DEX factory to be able to access DEX.
     */
    address public immutable factory;

    /**
        A reference to the WETH contract to be able to create a router.
     */
    address public immutable WETH;

    /**
        The winners tier count being 4.
     */
    uint256 private constant TIER_COUNT = 4;

    /**
        The index of a last zero-tier user.
     */
    uint256 private constant ZERO_TIER_LAST_USER_INDEX = 5;

    /**
        The index of a last first-tier user.
     */
    uint256 private constant FIRST_TIER_LAST_USER_INDEX = 10;

    /**
        The index of a last second-tier user.
     */
    uint256 private constant SECOND_TIER_LAST_USER_INDEX = 20;

    /**
        Just 100% (the total single).
     */
    uint256 private constant PERCENTAGE_TOTAL = 100;

    /**
        Zero-tier user count.
     */
    uint256 private constant ZERO_TIER_USER_COUNT = 5;

    /**
        First-tier user count.
     */
    uint256 private constant FIRST_TIER_USER_COUNT = 5;

    /**
        Second-tier user count.
     */
    uint256 private constant SECOND_TIER_USER_COUNT = 10;

    /**
        Third-tier user count.
     */
    uint256 private constant THIRD_TIER_USER_COUNT = 30;

    /**
        Competition factory owner address.
     */
    address private owner;

    mapping(address => bool) bans;

    /**
        DEX factory token list address.
     */
    address private tokenList;

    /**
        Events, created by this factory.
     */
    mapping(uint256 => Event) private events;

    /**
        Triggered, when a user claims a competition reward.
     */
    event Claim(uint256 _eventIdentifier);

    /**
        Triggered, when a user registers to a competition event.

        @param _eventIdentifier The given competition event identifier.
     */
    event Register(uint256 _eventIdentifier);

    /**
        Triggered, when a competition event is created.

        @param _blockRange A block, when the competition registration, opens, ends.
        @param _rewardAmount An total reward amount assigned to all the competition winners.
        @param _rewardToken A reward token.
        @param _tiers Reward percentage assigned to each tier.
     */
    event Create(
        uint[] _blockRange,
        uint256 _rewardAmount,
        address _rewardToken,
        uint256[TIER_COUNT] _tiers
    );

    /**
        Apply SafeERC20 to all IERC20 tokens in this contract.
     */
    using SafeERC20 for IERC20;

    /**
        Creates the trading competitions factory.

        @param _factory The DEX factory, to be able to interact with the DEX.
        @param _WETH The WETH token address, to be able to create a router.
        @param _tokenList The token list, to be able to check, whether the participated token is validated on the DEX.
    */
    constructor(address _factory, address _WETH, address _tokenList) {

        require(address(0) != _factory, "LOVELY DEX: ZERO_ADDRESS");
        require(address(0) != _WETH, "LOVELY DEX: ZERO_ADDRESS");
        require(address(0) != _tokenList, "LOVELY DEX: ZERO_ADDRESS");

        owner = msg.sender;
        factory = _factory;
        WETH = _WETH;
        tokenList = _tokenList;
    }

    
    function ban(address token) public {
        assert(msg.sender == owner);
        bans[token] = true;
    }

    function unban(address token) public {
        assert(msg.sender == owner);
        bans[token] = false;
    }

    /**
        Creates a competition event.

        Event has given start and end dates defined in the block time.

        Event reward is distributed by tiers according to the following rule:
        _tiers[0] * 5 + _tiers[1] * 5 + _tiers[2] * 10 + _tiers[3] * 30 == 100.
        Tier value contains the percentage of the total reward bank,
        which can be claimed by the winner, who gets into this tier.
        There are:
        - 5 users in the zero tier;
        - 5 users in the 1st tier;
        - 10 users in the 2nd tier;
        - 30 users in the 3d tier.
        The sum of percentages for each rewarded users should, logically, be equal to 100%,
        which is the whole reward bank.
        Tiers can be balanced according to the wish of the one, who creates the competition,
        until these values fall into the above-listed rule.
        For example, only one tier may be defined by setting other tiers to zero percentage.
        Or, tiers can be balanced uniformly or by any other distribution which falls within the given rule.

        @param blocks A block, when the competition starts registration, opens and ends.
                      [registration, open, close]
        @param _rewardAmount An total reward amount assigned to all the competition winners.
        @param _rewardToken A reward token.
        @param _tiers Reward percentage assigned to each tier.
    */
    function create(
        uint[] calldata blocks,
        uint256 _rewardAmount,
        address _rewardToken,
        uint256[TIER_COUNT] calldata _tiers
    ) external {
        assert(!bans[_rewardToken]);
        // Check that the block range is in the future
        assert(block.number < blocks[0] && blocks[0] < blocks[1]);

        // Check that the reward token is listed and validated
        assert(ILOVELYTokenList(tokenList).validated(_rewardToken));

        // Validate that tiers are balanced
        require(
            _tiers[0] * ZERO_TIER_USER_COUNT +
            _tiers[1] * FIRST_TIER_USER_COUNT +
            _tiers[2] * SECOND_TIER_USER_COUNT +
            _tiers[3] * THIRD_TIER_USER_COUNT == PERCENTAGE_TOTAL
        , "LOVELY DEX: COMPETITION_TIERS_UNBALANCED");

        // Accept the reward amount in the given token
        IERC20(_rewardToken).transferFrom(msg.sender, address(this), _rewardAmount);

        uint256 id = eventCount++;
        Event storage competitionEvent = events[id];
        competitionEvent.blockRange = blocks;
        competitionEvent.rewardAmount = _rewardAmount;
        competitionEvent.rewardToken = _rewardToken;
        competitionEvent.creator = msg.sender;

        competitionEvent.router = new LOVELYAuditedRouter(factory, WETH, address(this), _rewardToken, id);
        competitionEvent.tiers[Tier.Zero] = _tiers[0];
        competitionEvent.tiers[Tier.First] = _tiers[1];
        competitionEvent.tiers[Tier.Second] = _tiers[2];
        competitionEvent.tiers[Tier.Third] = _tiers[3];

        emit Create(blocks, _rewardAmount, _rewardToken, _tiers);
    }

    /**
        Returns an audited router corresponding to the given competition event.

        @param _eventIdentifier The given competition event identifier.
     */
    function eventRouter(uint256 _eventIdentifier) external view returns (address) {
        return address(events[_eventIdentifier].router);
    }

    /**
        Returns the given competition event block range (event start and end blocks).

        @param _eventIdentifier The given competition event identifier.
     */
    function eventBlockRange(uint256 _eventIdentifier) external view returns (uint[] memory) {
        return events[_eventIdentifier].blockRange;
    }

    /**
        Returns the given competition event total reward.

        @param _eventIdentifier The given competition event identifier.
     */
    function eventReward(uint256 _eventIdentifier) external view returns (uint256) {
        return events[_eventIdentifier].rewardAmount;
    }

    /**
        Returns the given competition event reward token.

        @param _eventIdentifier The given competition event identifier.
     */
    function eventRewardToken(uint256 _eventIdentifier) external view returns (address) {
        return events[_eventIdentifier].rewardToken;
    }

    /**
        Returns the given competition event creator.

        @param _eventIdentifier The given competition event identifier.
     */
    function eventCreator(uint256 _eventIdentifier) external view returns (address) {
        return events[_eventIdentifier].creator;
    }

    /**
        Returns the given competition event tiers.

        @param _eventIdentifier The given competition event identifier.
     */
    function eventTiers(uint256 _eventIdentifier) external view returns (uint256[TIER_COUNT] memory) {
        Event storage competitionEvent = events[_eventIdentifier];
        return [
            competitionEvent.tiers[Tier.Zero],
            competitionEvent.tiers[Tier.First],
            competitionEvent.tiers[Tier.Second],
            competitionEvent.tiers[Tier.Third]
        ];
    }

    /**
        Returns the given competition event tier reward.

        @param _eventIdentifier The given competition event identifier.
        @param _tier The given competition event tier.
     */
    function eventTierReward(uint256 _eventIdentifier, Tier _tier) external view returns (uint256) {
        Event storage competitionEvent = events[_eventIdentifier];
        return competitionEvent.rewardAmount * competitionEvent.tiers[_tier] / PERCENTAGE_TOTAL;
    }

    /**
        Returns the list of winners for a given competition event.

        @param _eventIdentifier The given competition event identifier.
     */
    function eventWinners(uint256 _eventIdentifier) external view returns (address[] memory) {
        return events[_eventIdentifier].router.topAddresses(50);
    }

    /**
        For a given address, returns, whether it should be included.

        @param _eventIdentifier The identifier for making a projection within the data source context.
        @param _address The address to be checked.
     */
    function included(uint256 _eventIdentifier, address _address) external view returns (bool) {
        return events[_eventIdentifier].users[_address].registered;
    }

    /**
        Claims trader's reward.

        @param _eventIdentifier The given competition event identifier.

        @dev Claiming the reward IMPLICITLY can be done only for competition events in the "Claiming" state.
        Only the winner can claim.
     */
    function claim(uint256 _eventIdentifier) external {
        Event storage competitionEvent = events[_eventIdentifier];
        User storage user = competitionEvent.users[msg.sender];

        uint[] memory blocks = competitionEvent.blockRange;

        assert(user.registered && !user.claimed && block.number >= blocks[1]);

        // Find the trader in the winners array
        address[] memory winners = competitionEvent.router.topAddresses(50);
        bool found = false;
        uint256 length = winners.length;
        uint256 i = 0;
        for (; i < length; i++) {
            if (msg.sender == winners[i]) {
                found = true;
                break;
            }
        }

        assert(found);

        // Calculate the tier
        Tier tier = determineUserTier(i);

        // Calculate the reward
        uint256 reward = competitionEvent.rewardAmount * competitionEvent.tiers[tier] / PERCENTAGE_TOTAL;

        // Mark the trader as one who claimed his reward
        user.claimed = true;

        // Send the prize
        IERC20(competitionEvent.rewardToken).transfer(msg.sender, reward);

        emit Claim(_eventIdentifier);
    }

    function claimRest(uint256 _eventIdentifier) public {
        Event storage competitionEvent = events[_eventIdentifier];
        address[] memory winnersAmount = competitionEvent.router.topAddresses(50);
        uint[] memory blocks = competitionEvent.blockRange;
        
        assert(winnersAmount.length < 50 && competitionEvent.creator == msg.sender && blocks[1] <= block.number);

        uint toSend;
        for (uint i = winnersAmount.length; i < 50; i++) {
            toSend += competitionEvent.rewardAmount * competitionEvent.tiers[determineUserTier(i)] / PERCENTAGE_TOTAL;
        }

        // Send the prize
        IERC20(competitionEvent.rewardToken).transfer(msg.sender, toSend);
    }

    /**
        Registers a user in the given competition event.

        @param _eventIdentifier The given competition event identifier.
     */
    function register(uint256 _eventIdentifier) external {
        Event storage competitionEvent = events[_eventIdentifier];
        uint[] memory blocks = competitionEvent.blockRange;
        
        assert(!competitionEvent.users[msg.sender].registered && blocks[1] > block.number);
        
        competitionEvent.users[msg.sender].registered = true;

        emit Register(_eventIdentifier);
    }

    function determineUserTier(uint256 _userIndex) private pure returns (Tier) {
        if (_userIndex < ZERO_TIER_LAST_USER_INDEX) {
            return Tier.Zero;
        } else if (_userIndex < FIRST_TIER_LAST_USER_INDEX) {
            return Tier.First;
        } else if (_userIndex < SECOND_TIER_LAST_USER_INDEX) {
            return Tier.Second;
        } else {
            return Tier.Third;
        }
    }
}