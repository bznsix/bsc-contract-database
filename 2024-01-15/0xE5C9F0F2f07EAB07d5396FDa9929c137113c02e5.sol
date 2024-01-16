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
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC1155/IERC1155Receiver.sol)

pragma solidity ^0.8.0;

import "../../utils/introspection/IERC165.sol";

/**
 * @dev _Available since v3.1._
 */
interface IERC1155Receiver is IERC165 {
    /**
     * @dev Handles the receipt of a single ERC1155 token type. This function is
     * called at the end of a `safeTransferFrom` after the balance has been updated.
     *
     * NOTE: To accept the transfer, this must return
     * `bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"))`
     * (i.e. 0xf23a6e61, or its own function selector).
     *
     * @param operator The address which initiated the transfer (i.e. msg.sender)
     * @param from The address which previously owned the token
     * @param id The ID of the token being transferred
     * @param value The amount of tokens being transferred
     * @param data Additional data with no specified format
     * @return `bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"))` if transfer is allowed
     */
    function onERC1155Received(
        address operator,
        address from,
        uint256 id,
        uint256 value,
        bytes calldata data
    ) external returns (bytes4);

    /**
     * @dev Handles the receipt of a multiple ERC1155 token types. This function
     * is called at the end of a `safeBatchTransferFrom` after the balances have
     * been updated.
     *
     * NOTE: To accept the transfer(s), this must return
     * `bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"))`
     * (i.e. 0xbc197c81, or its own function selector).
     *
     * @param operator The address which initiated the batch transfer (i.e. msg.sender)
     * @param from The address which previously owned the token
     * @param ids An array containing ids of each token being transferred (order and length must match values array)
     * @param values An array containing amounts of each token being transferred (order and length must match ids array)
     * @param data Additional data with no specified format
     * @return `bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"))` if transfer is allowed
     */
    function onERC1155BatchReceived(
        address operator,
        address from,
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata data
    ) external returns (bytes4);
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC1155/utils/ERC1155Holder.sol)

pragma solidity ^0.8.0;

import "./ERC1155Receiver.sol";

/**
 * Simple implementation of `ERC1155Receiver` that will allow a contract to hold ERC1155 tokens.
 *
 * IMPORTANT: When inheriting this contract, you must include a way to use the received tokens, otherwise they will be
 * stuck.
 *
 * @dev _Available since v3.1._
 */
contract ERC1155Holder is ERC1155Receiver {
    function onERC1155Received(
        address,
        address,
        uint256,
        uint256,
        bytes memory
    ) public virtual override returns (bytes4) {
        return this.onERC1155Received.selector;
    }

    function onERC1155BatchReceived(
        address,
        address,
        uint256[] memory,
        uint256[] memory,
        bytes memory
    ) public virtual override returns (bytes4) {
        return this.onERC1155BatchReceived.selector;
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC1155/utils/ERC1155Receiver.sol)

pragma solidity ^0.8.0;

import "../IERC1155Receiver.sol";
import "../../../utils/introspection/ERC165.sol";

/**
 * @dev _Available since v3.1._
 */
abstract contract ERC1155Receiver is ERC165, IERC1155Receiver {
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {
        return interfaceId == type(IERC1155Receiver).interfaceId || super.supportsInterface(interfaceId);
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
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC721/IERC721Receiver.sol)

pragma solidity ^0.8.0;

/**
 * @title ERC721 token receiver interface
 * @dev Interface for any contract that wants to support safeTransfers
 * from ERC721 asset contracts.
 */
interface IERC721Receiver {
    /**
     * @dev Whenever an {IERC721} `tokenId` token is transferred to this contract via {IERC721-safeTransferFrom}
     * by `operator` from `from`, this function is called.
     *
     * It must return its Solidity selector to confirm the token transfer.
     * If any other value is returned or the interface is not implemented by the recipient, the transfer will be reverted.
     *
     * The selector can be obtained in Solidity with `IERC721Receiver.onERC721Received.selector`.
     */
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (token/ERC721/utils/ERC721Holder.sol)

pragma solidity ^0.8.0;

import "../IERC721Receiver.sol";

/**
 * @dev Implementation of the {IERC721Receiver} interface.
 *
 * Accepts all token transfers.
 * Make sure the contract is able to use its token with {IERC721-safeTransferFrom}, {IERC721-approve} or {IERC721-setApprovalForAll}.
 */
contract ERC721Holder is IERC721Receiver {
    /**
     * @dev See {IERC721Receiver-onERC721Received}.
     *
     * Always returns `IERC721Receiver.onERC721Received.selector`.
     */
    function onERC721Received(address, address, uint256, bytes memory) public virtual override returns (bytes4) {
        return this.onERC721Received.selector;
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
// OpenZeppelin Contracts v4.4.1 (utils/introspection/ERC165.sol)

pragma solidity ^0.8.0;

import "./IERC165.sol";

/**
 * @dev Implementation of the {IERC165} interface.
 *
 * Contracts that want to implement ERC165 should inherit from this contract and override {supportsInterface} to check
 * for the additional interface id that will be supported. For example:
 *
 * ```solidity
 * function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
 *     return interfaceId == type(MyInterface).interfaceId || super.supportsInterface(interfaceId);
 * }
 * ```
 *
 * Alternatively, {ERC165Storage} provides an easier to use but more expensive implementation.
 */
abstract contract ERC165 is IERC165 {
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/introspection/IERC165.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
interface IERC165 {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (utils/math/SafeCast.sol)
// This file was procedurally generated from scripts/generate/templates/SafeCast.js.

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
    function toInt248(int256 value) internal pure returns (int248 downcasted) {
        downcasted = int248(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 248 bits");
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
    function toInt240(int256 value) internal pure returns (int240 downcasted) {
        downcasted = int240(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 240 bits");
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
    function toInt232(int256 value) internal pure returns (int232 downcasted) {
        downcasted = int232(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 232 bits");
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
    function toInt224(int256 value) internal pure returns (int224 downcasted) {
        downcasted = int224(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 224 bits");
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
    function toInt216(int256 value) internal pure returns (int216 downcasted) {
        downcasted = int216(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 216 bits");
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
    function toInt208(int256 value) internal pure returns (int208 downcasted) {
        downcasted = int208(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 208 bits");
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
    function toInt200(int256 value) internal pure returns (int200 downcasted) {
        downcasted = int200(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 200 bits");
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
    function toInt192(int256 value) internal pure returns (int192 downcasted) {
        downcasted = int192(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 192 bits");
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
    function toInt184(int256 value) internal pure returns (int184 downcasted) {
        downcasted = int184(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 184 bits");
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
    function toInt176(int256 value) internal pure returns (int176 downcasted) {
        downcasted = int176(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 176 bits");
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
    function toInt168(int256 value) internal pure returns (int168 downcasted) {
        downcasted = int168(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 168 bits");
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
    function toInt160(int256 value) internal pure returns (int160 downcasted) {
        downcasted = int160(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 160 bits");
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
    function toInt152(int256 value) internal pure returns (int152 downcasted) {
        downcasted = int152(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 152 bits");
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
    function toInt144(int256 value) internal pure returns (int144 downcasted) {
        downcasted = int144(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 144 bits");
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
    function toInt136(int256 value) internal pure returns (int136 downcasted) {
        downcasted = int136(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 136 bits");
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
    function toInt128(int256 value) internal pure returns (int128 downcasted) {
        downcasted = int128(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 128 bits");
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
    function toInt120(int256 value) internal pure returns (int120 downcasted) {
        downcasted = int120(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 120 bits");
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
    function toInt112(int256 value) internal pure returns (int112 downcasted) {
        downcasted = int112(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 112 bits");
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
    function toInt104(int256 value) internal pure returns (int104 downcasted) {
        downcasted = int104(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 104 bits");
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
    function toInt96(int256 value) internal pure returns (int96 downcasted) {
        downcasted = int96(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 96 bits");
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
    function toInt88(int256 value) internal pure returns (int88 downcasted) {
        downcasted = int88(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 88 bits");
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
    function toInt80(int256 value) internal pure returns (int80 downcasted) {
        downcasted = int80(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 80 bits");
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
    function toInt72(int256 value) internal pure returns (int72 downcasted) {
        downcasted = int72(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 72 bits");
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
    function toInt64(int256 value) internal pure returns (int64 downcasted) {
        downcasted = int64(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 64 bits");
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
    function toInt56(int256 value) internal pure returns (int56 downcasted) {
        downcasted = int56(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 56 bits");
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
    function toInt48(int256 value) internal pure returns (int48 downcasted) {
        downcasted = int48(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 48 bits");
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
    function toInt40(int256 value) internal pure returns (int40 downcasted) {
        downcasted = int40(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 40 bits");
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
    function toInt32(int256 value) internal pure returns (int32 downcasted) {
        downcasted = int32(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 32 bits");
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
    function toInt24(int256 value) internal pure returns (int24 downcasted) {
        downcasted = int24(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 24 bits");
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
    function toInt16(int256 value) internal pure returns (int16 downcasted) {
        downcasted = int16(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 16 bits");
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
    function toInt8(int256 value) internal pure returns (int8 downcasted) {
        downcasted = int8(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 8 bits");
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
// SPDX-License-Identifier: GPL-3.0-only

pragma solidity >=0.8.0;

interface IBridge {
    function send(
        address _receiver,
        address _token,
        uint256 _amount,
        uint64 _dstChainId,
        uint64 _nonce,
        uint32 _maxSlippage
    ) external;

    function sendNative(
        address _receiver,
        uint256 _amount,
        uint64 _dstChainId,
        uint64 _nonce,
        uint32 _maxSlippage
    ) external payable;

    function relay(
        bytes calldata _relayRequest,
        bytes[] calldata _sigs,
        address[] calldata _signers,
        uint256[] calldata _powers
    ) external;

    function transfers(bytes32 transferId) external view returns (bool);

    function withdraws(bytes32 withdrawId) external view returns (bool);

    function withdraw(
        bytes calldata _wdmsg,
        bytes[] calldata _sigs,
        address[] calldata _signers,
        uint256[] calldata _powers
    ) external;

    /**
     * @notice Verifies that a message is signed by a quorum among the signers.
     * @param _msg signed message
     * @param _sigs list of signatures sorted by signer addresses in ascending order
     * @param _signers sorted list of current signers
     * @param _powers powers of current signers
     */
    function verifySigs(
        bytes memory _msg,
        bytes[] calldata _sigs,
        address[] calldata _signers,
        uint256[] calldata _powers
    ) external view;
}
// SPDX-License-Identifier: GPL-3.0-only

pragma solidity >=0.8.0;

interface IOriginalTokenVault {
    /**
     * @notice Lock original tokens to trigger mint at a remote chain's PeggedTokenBridge
     * @param _token local token address
     * @param _amount locked token amount
     * @param _mintChainId destination chainId to mint tokens
     * @param _mintAccount destination account to receive minted tokens
     * @param _nonce user input to guarantee unique depositId
     */
    function deposit(
        address _token,
        uint256 _amount,
        uint64 _mintChainId,
        address _mintAccount,
        uint64 _nonce
    ) external;

    /**
     * @notice Lock native token as original token to trigger mint at a remote chain's PeggedTokenBridge
     * @param _amount locked token amount
     * @param _mintChainId destination chainId to mint tokens
     * @param _mintAccount destination account to receive minted tokens
     * @param _nonce user input to guarantee unique depositId
     */
    function depositNative(
        uint256 _amount,
        uint64 _mintChainId,
        address _mintAccount,
        uint64 _nonce
    ) external payable;

    /**
     * @notice Withdraw locked original tokens triggered by a burn at a remote chain's PeggedTokenBridge.
     * @param _request The serialized Withdraw protobuf.
     * @param _sigs The list of signatures sorted by signing addresses in ascending order. A relay must be signed-off by
     * +2/3 of the bridge's current signing power to be delivered.
     * @param _signers The sorted list of signers.
     * @param _powers The signing powers of the signers.
     */
    function withdraw(
        bytes calldata _request,
        bytes[] calldata _sigs,
        address[] calldata _signers,
        uint256[] calldata _powers
    ) external;

    function records(bytes32 recordId) external view returns (bool);
}
// SPDX-License-Identifier: GPL-3.0-only

pragma solidity >=0.8.0;

interface IOriginalTokenVaultV2 {
    /**
     * @notice Lock original tokens to trigger mint at a remote chain's PeggedTokenBridge
     * @param _token local token address
     * @param _amount locked token amount
     * @param _mintChainId destination chainId to mint tokens
     * @param _mintAccount destination account to receive minted tokens
     * @param _nonce user input to guarantee unique depositId
     */
    function deposit(
        address _token,
        uint256 _amount,
        uint64 _mintChainId,
        address _mintAccount,
        uint64 _nonce
    ) external returns (bytes32);

    /**
     * @notice Lock native token as original token to trigger mint at a remote chain's PeggedTokenBridge
     * @param _amount locked token amount
     * @param _mintChainId destination chainId to mint tokens
     * @param _mintAccount destination account to receive minted tokens
     * @param _nonce user input to guarantee unique depositId
     */
    function depositNative(
        uint256 _amount,
        uint64 _mintChainId,
        address _mintAccount,
        uint64 _nonce
    ) external payable returns (bytes32);

    /**
     * @notice Withdraw locked original tokens triggered by a burn at a remote chain's PeggedTokenBridge.
     * @param _request The serialized Withdraw protobuf.
     * @param _sigs The list of signatures sorted by signing addresses in ascending order. A relay must be signed-off by
     * +2/3 of the bridge's current signing power to be delivered.
     * @param _signers The sorted list of signers.
     * @param _powers The signing powers of the signers.
     */
    function withdraw(
        bytes calldata _request,
        bytes[] calldata _sigs,
        address[] calldata _signers,
        uint256[] calldata _powers
    ) external returns (bytes32);

    function records(bytes32 recordId) external view returns (bool);
}
// SPDX-License-Identifier: GPL-3.0-only

pragma solidity >=0.8.0;

interface IPeggedTokenBridge {
    /**
     * @notice Burn tokens to trigger withdrawal at a remote chain's OriginalTokenVault
     * @param _token local token address
     * @param _amount locked token amount
     * @param _withdrawAccount account who withdraw original tokens on the remote chain
     * @param _nonce user input to guarantee unique depositId
     */
    function burn(
        address _token,
        uint256 _amount,
        address _withdrawAccount,
        uint64 _nonce
    ) external;

    /**
     * @notice Mint tokens triggered by deposit at a remote chain's OriginalTokenVault.
     * @param _request The serialized Mint protobuf.
     * @param _sigs The list of signatures sorted by signing addresses in ascending order. A relay must be signed-off by
     * +2/3 of the sigsVerifier's current signing power to be delivered.
     * @param _signers The sorted list of signers.
     * @param _powers The signing powers of the signers.
     */
    function mint(
        bytes calldata _request,
        bytes[] calldata _sigs,
        address[] calldata _signers,
        uint256[] calldata _powers
    ) external;

    function records(bytes32 recordId) external view returns (bool);
}
// SPDX-License-Identifier: GPL-3.0-only

pragma solidity >=0.8.0;

interface IPeggedTokenBridgeV2 {
    /**
     * @notice Burn pegged tokens to trigger a cross-chain withdrawal of the original tokens at a remote chain's
     * OriginalTokenVault, or mint at another remote chain
     * @param _token The pegged token address.
     * @param _amount The amount to burn.
     * @param _toChainId If zero, withdraw from original vault; otherwise, the remote chain to mint tokens.
     * @param _toAccount The account to receive tokens on the remote chain
     * @param _nonce A number to guarantee unique depositId. Can be timestamp in practice.
     */
    function burn(
        address _token,
        uint256 _amount,
        uint64 _toChainId,
        address _toAccount,
        uint64 _nonce
    ) external returns (bytes32);

    // same with `burn` above, use openzeppelin ERC20Burnable interface
    function burnFrom(
        address _token,
        uint256 _amount,
        uint64 _toChainId,
        address _toAccount,
        uint64 _nonce
    ) external returns (bytes32);

    /**
     * @notice Mint tokens triggered by deposit at a remote chain's OriginalTokenVault.
     * @param _request The serialized Mint protobuf.
     * @param _sigs The list of signatures sorted by signing addresses in ascending order. A relay must be signed-off by
     * +2/3 of the sigsVerifier's current signing power to be delivered.
     * @param _signers The sorted list of signers.
     * @param _powers The signing powers of the signers.
     */
    function mint(
        bytes calldata _request,
        bytes[] calldata _sigs,
        address[] calldata _signers,
        uint256[] calldata _powers
    ) external returns (bytes32);

    function records(bytes32 recordId) external view returns (bool);
}
// SPDX-License-Identifier: GPL-3.0-only

pragma solidity >=0.8.0;

import "../libraries/MsgDataTypes.sol";

interface IMessageBus {
    /**
     * @notice Send a message to a contract on another chain.
     * Sender needs to make sure the uniqueness of the message Id, which is computed as
     * hash(type.MessageOnly, sender, receiver, srcChainId, srcTxHash, dstChainId, message).
     * If messages with the same Id are sent, only one of them will succeed at dst chain..
     * A fee is charged in the native gas token.
     * @param _receiver The address of the destination app contract.
     * @param _dstChainId The destination chain ID.
     * @param _message Arbitrary message bytes to be decoded by the destination app contract.
     */
    function sendMessage(
        address _receiver,
        uint256 _dstChainId,
        bytes calldata _message
    ) external payable;

    // same as above, except that receiver is an non-evm chain address,
    function sendMessage(
        bytes calldata _receiver,
        uint256 _dstChainId,
        bytes calldata _message
    ) external payable;

    /**
     * @notice Send a message associated with a token transfer to a contract on another chain.
     * If messages with the same srcTransferId are sent, only one of them will succeed at dst chain..
     * A fee is charged in the native token.
     * @param _receiver The address of the destination app contract.
     * @param _dstChainId The destination chain ID.
     * @param _srcBridge The bridge contract to send the transfer with.
     * @param _srcTransferId The transfer ID.
     * @param _dstChainId The destination chain ID.
     * @param _message Arbitrary message bytes to be decoded by the destination app contract.
     */
    function sendMessageWithTransfer(
        address _receiver,
        uint256 _dstChainId,
        address _srcBridge,
        bytes32 _srcTransferId,
        bytes calldata _message
    ) external payable;

    /**
     * @notice Execute a message not associated with a transfer.
     * @param _message Arbitrary message bytes originated from and encoded by the source app contract
     * @param _sigs The list of signatures sorted by signing addresses in ascending order. A relay must be signed-off by
     * +2/3 of the sigsVerifier's current signing power to be delivered.
     * @param _signers The sorted list of signers.
     * @param _powers The signing powers of the signers.
     */
    function executeMessage(
        bytes calldata _message,
        MsgDataTypes.RouteInfo calldata _route,
        bytes[] calldata _sigs,
        address[] calldata _signers,
        uint256[] calldata _powers
    ) external payable;

    /**
     * @notice Execute a message with a successful transfer.
     * @param _message Arbitrary message bytes originated from and encoded by the source app contract
     * @param _transfer The transfer info.
     * @param _sigs The list of signatures sorted by signing addresses in ascending order. A relay must be signed-off by
     * +2/3 of the sigsVerifier's current signing power to be delivered.
     * @param _signers The sorted list of signers.
     * @param _powers The signing powers of the signers.
     */
    function executeMessageWithTransfer(
        bytes calldata _message,
        MsgDataTypes.TransferInfo calldata _transfer,
        bytes[] calldata _sigs,
        address[] calldata _signers,
        uint256[] calldata _powers
    ) external payable;

    /**
     * @notice Execute a message with a refunded transfer.
     * @param _message Arbitrary message bytes originated from and encoded by the source app contract
     * @param _transfer The transfer info.
     * @param _sigs The list of signatures sorted by signing addresses in ascending order. A relay must be signed-off by
     * +2/3 of the sigsVerifier's current signing power to be delivered.
     * @param _signers The sorted list of signers.
     * @param _powers The signing powers of the signers.
     */
    function executeMessageWithTransferRefund(
        bytes calldata _message, // the same message associated with the original transfer
        MsgDataTypes.TransferInfo calldata _transfer,
        bytes[] calldata _sigs,
        address[] calldata _signers,
        uint256[] calldata _powers
    ) external payable;

    /**
     * @notice Withdraws message fee in the form of native gas token.
     * @param _account The address receiving the fee.
     * @param _cumulativeFee The cumulative fee credited to the account. Tracked by SGN.
     * @param _sigs The list of signatures sorted by signing addresses in ascending order. A withdrawal must be
     * signed-off by +2/3 of the sigsVerifier's current signing power to be delivered.
     * @param _signers The sorted list of signers.
     * @param _powers The signing powers of the signers.
     */
    function withdrawFee(
        address _account,
        uint256 _cumulativeFee,
        bytes[] calldata _sigs,
        address[] calldata _signers,
        uint256[] calldata _powers
    ) external;

    /**
     * @notice Calculates the required fee for the message.
     * @param _message Arbitrary message bytes to be decoded by the destination app contract.
     @ @return The required fee.
     */
    function calcFee(bytes calldata _message) external view returns (uint256);

    function liquidityBridge() external view returns (address);

    function pegBridge() external view returns (address);

    function pegBridgeV2() external view returns (address);

    function pegVault() external view returns (address);

    function pegVaultV2() external view returns (address);
}
// SPDX-License-Identifier: GPL-3.0-only

pragma solidity >=0.8.0;

interface IMessageReceiverApp {
    enum ExecutionStatus {
        Fail, // execution failed, finalized
        Success, // execution succeeded, finalized
        Retry // execution rejected, can retry later
    }

    /**
     * @notice Called by MessageBus to execute a message
     * @param _sender The address of the source app contract
     * @param _srcChainId The source chain ID where the transfer is originated from
     * @param _message Arbitrary message bytes originated from and encoded by the source app contract
     * @param _executor Address who called the MessageBus execution function
     */
    function executeMessage(
        address _sender,
        uint64 _srcChainId,
        bytes calldata _message,
        address _executor
    ) external payable returns (ExecutionStatus);

    // same as above, except that sender is an non-evm chain address,
    // otherwise same as above.
    function executeMessage(
        bytes calldata _sender,
        uint64 _srcChainId,
        bytes calldata _message,
        address _executor
    ) external payable returns (ExecutionStatus);

    /**
     * @notice Called by MessageBus to execute a message with an associated token transfer.
     * The contract is guaranteed to have received the right amount of tokens before this function is called.
     * @param _sender The address of the source app contract
     * @param _token The address of the token that comes out of the bridge
     * @param _amount The amount of tokens received at this contract through the cross-chain bridge.
     * @param _srcChainId The source chain ID where the transfer is originated from
     * @param _message Arbitrary message bytes originated from and encoded by the source app contract
     * @param _executor Address who called the MessageBus execution function
     */
    function executeMessageWithTransfer(
        address _sender,
        address _token,
        uint256 _amount,
        uint64 _srcChainId,
        bytes calldata _message,
        address _executor
    ) external payable returns (ExecutionStatus);

    /**
     * @notice Only called by MessageBus if
     *         1. executeMessageWithTransfer reverts, or
     *         2. executeMessageWithTransfer returns ExecutionStatus.Fail
     * The contract is guaranteed to have received the right amount of tokens before this function is called.
     * @param _sender The address of the source app contract
     * @param _token The address of the token that comes out of the bridge
     * @param _amount The amount of tokens received at this contract through the cross-chain bridge.
     * @param _srcChainId The source chain ID where the transfer is originated from
     * @param _message Arbitrary message bytes originated from and encoded by the source app contract
     * @param _executor Address who called the MessageBus execution function
     */
    function executeMessageWithTransferFallback(
        address _sender,
        address _token,
        uint256 _amount,
        uint64 _srcChainId,
        bytes calldata _message,
        address _executor
    ) external payable returns (ExecutionStatus);

    /**
     * @notice Called by MessageBus to process refund of the original transfer from this contract.
     * The contract is guaranteed to have received the refund before this function is called.
     * @param _token The token address of the original transfer
     * @param _amount The amount of the original transfer
     * @param _message The same message associated with the original transfer
     * @param _executor Address who called the MessageBus execution function
     */
    function executeMessageWithTransferRefund(
        address _token,
        uint256 _amount,
        bytes calldata _message,
        address _executor
    ) external payable returns (ExecutionStatus);
}
// SPDX-License-Identifier: GPL-3.0-only

pragma solidity >=0.8.0;

import "../../../../../lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import "../../../../../lib/openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol";
import "../../interfaces/IBridge.sol";
import "../../interfaces/IOriginalTokenVault.sol";
import "../../interfaces/IOriginalTokenVaultV2.sol";
import "../../interfaces/IPeggedTokenBridge.sol";
import "../../interfaces/IPeggedTokenBridgeV2.sol";
import "../interfaces/IMessageBus.sol";
import "./MsgDataTypes.sol";

library MessageSenderLib {
    using SafeERC20 for IERC20;

    // ============== Internal library functions called by apps ==============

    /**
     * @notice Sends a message to an app on another chain via MessageBus without an associated transfer.
     * @param _receiver The address of the destination app contract.
     * @param _dstChainId The destination chain ID.
     * @param _message Arbitrary message bytes to be decoded by the destination app contract.
     * @param _messageBus The address of the MessageBus on this chain.
     * @param _fee The fee amount to pay to MessageBus.
     */
    function sendMessage(
        address _receiver,
        uint64 _dstChainId,
        bytes memory _message,
        address _messageBus,
        uint256 _fee
    ) internal {
        IMessageBus(_messageBus).sendMessage{value: _fee}(_receiver, _dstChainId, _message);
    }

    // Send message to non-evm chain with bytes for receiver address,
    // otherwise same as above.
    function sendMessage(
        bytes calldata _receiver,
        uint64 _dstChainId,
        bytes memory _message,
        address _messageBus,
        uint256 _fee
    ) internal {
        IMessageBus(_messageBus).sendMessage{value: _fee}(_receiver, _dstChainId, _message);
    }

    /**
     * @notice Sends a message to an app on another chain via MessageBus with an associated transfer.
     * @param _receiver The address of the destination app contract.
     * @param _token The address of the token to be sent.
     * @param _amount The amount of tokens to be sent.
     * @param _dstChainId The destination chain ID.
     * @param _nonce A number input to guarantee uniqueness of transferId. Can be timestamp in practice.
     * @param _maxSlippage The max slippage accepted, given as percentage in point (pip). Eg. 5000 means 0.5%.
     * Must be greater than minimalMaxSlippage. Receiver is guaranteed to receive at least (100% - max slippage percentage) * amount or the
     * transfer can be refunded. Only applicable to the {MsgDataTypes.BridgeSendType.Liquidity}.
     * @param _message Arbitrary message bytes to be decoded by the destination app contract.
     * @param _bridgeSendType One of the {MsgDataTypes.BridgeSendType} enum.
     * @param _messageBus The address of the MessageBus on this chain.
     * @param _fee The fee amount to pay to MessageBus.
     * @return The transfer ID.
     */
    function sendMessageWithTransfer(
        address _receiver,
        address _token,
        uint256 _amount,
        uint64 _dstChainId,
        uint64 _nonce,
        uint32 _maxSlippage,
        bytes memory _message,
        MsgDataTypes.BridgeSendType _bridgeSendType,
        address _messageBus,
        uint256 _fee
    ) internal returns (bytes32) {
        (bytes32 transferId, address bridge) = sendTokenTransfer(
            _receiver,
            _token,
            _amount,
            _dstChainId,
            _nonce,
            _maxSlippage,
            _bridgeSendType,
            _messageBus
        );
        if (_message.length > 0) {
            IMessageBus(_messageBus).sendMessageWithTransfer{value: _fee}(
                _receiver,
                _dstChainId,
                bridge,
                transferId,
                _message
            );
        }
        return transferId;
    }

    /**
     * @notice Sends a token transfer via a bridge.
     * @param _receiver The address of the destination app contract.
     * @param _token The address of the token to be sent.
     * @param _amount The amount of tokens to be sent.
     * @param _dstChainId The destination chain ID.
     * @param _nonce A number input to guarantee uniqueness of transferId. Can be timestamp in practice.
     * @param _maxSlippage The max slippage accepted, given as percentage in point (pip). Eg. 5000 means 0.5%.
     * Must be greater than minimalMaxSlippage. Receiver is guaranteed to receive at least (100% - max slippage percentage) * amount or the
     * transfer can be refunded.
     * @param _bridgeSendType One of the {MsgDataTypes.BridgeSendType} enum.
     */
    function sendTokenTransfer(
        address _receiver,
        address _token,
        uint256 _amount,
        uint64 _dstChainId,
        uint64 _nonce,
        uint32 _maxSlippage,
        MsgDataTypes.BridgeSendType _bridgeSendType,
        address _messageBus
    ) internal returns (bytes32 transferId, address bridge) {
        if (_bridgeSendType == MsgDataTypes.BridgeSendType.Liquidity) {
            bridge = IMessageBus(_messageBus).liquidityBridge();
            IERC20(_token).safeIncreaseAllowance(bridge, _amount);
            IBridge(bridge).send(_receiver, _token, _amount, _dstChainId, _nonce, _maxSlippage);
            transferId = computeLiqBridgeTransferId(_receiver, _token, _amount, _dstChainId, _nonce);
        } else if (_bridgeSendType == MsgDataTypes.BridgeSendType.PegDeposit) {
            bridge = IMessageBus(_messageBus).pegVault();
            IERC20(_token).safeIncreaseAllowance(bridge, _amount);
            IOriginalTokenVault(bridge).deposit(_token, _amount, _dstChainId, _receiver, _nonce);
            transferId = computePegV1DepositId(_receiver, _token, _amount, _dstChainId, _nonce);
        } else if (_bridgeSendType == MsgDataTypes.BridgeSendType.PegBurn) {
            bridge = IMessageBus(_messageBus).pegBridge();
            IERC20(_token).safeIncreaseAllowance(bridge, _amount);
            IPeggedTokenBridge(bridge).burn(_token, _amount, _receiver, _nonce);
            // handle cases where certain tokens do not spend allowance for role-based burn
            IERC20(_token).safeApprove(bridge, 0);
            transferId = computePegV1BurnId(_receiver, _token, _amount, _nonce);
        } else if (_bridgeSendType == MsgDataTypes.BridgeSendType.PegV2Deposit) {
            bridge = IMessageBus(_messageBus).pegVaultV2();
            IERC20(_token).safeIncreaseAllowance(bridge, _amount);
            transferId = IOriginalTokenVaultV2(bridge).deposit(_token, _amount, _dstChainId, _receiver, _nonce);
        } else if (_bridgeSendType == MsgDataTypes.BridgeSendType.PegV2Burn) {
            bridge = IMessageBus(_messageBus).pegBridgeV2();
            IERC20(_token).safeIncreaseAllowance(bridge, _amount);
            transferId = IPeggedTokenBridgeV2(bridge).burn(_token, _amount, _dstChainId, _receiver, _nonce);
            // handle cases where certain tokens do not spend allowance for role-based burn
            IERC20(_token).safeApprove(bridge, 0);
        } else if (_bridgeSendType == MsgDataTypes.BridgeSendType.PegV2BurnFrom) {
            bridge = IMessageBus(_messageBus).pegBridgeV2();
            IERC20(_token).safeIncreaseAllowance(bridge, _amount);
            transferId = IPeggedTokenBridgeV2(bridge).burnFrom(_token, _amount, _dstChainId, _receiver, _nonce);
            // handle cases where certain tokens do not spend allowance for role-based burn
            IERC20(_token).safeApprove(bridge, 0);
        } else {
            revert("bridge type not supported");
        }
    }

    function computeLiqBridgeTransferId(
        address _receiver,
        address _token,
        uint256 _amount,
        uint64 _dstChainId,
        uint64 _nonce
    ) internal view returns (bytes32) {
        return
            keccak256(
                abi.encodePacked(address(this), _receiver, _token, _amount, _dstChainId, _nonce, uint64(block.chainid))
            );
    }

    function computePegV1DepositId(
        address _receiver,
        address _token,
        uint256 _amount,
        uint64 _dstChainId,
        uint64 _nonce
    ) internal view returns (bytes32) {
        return
            keccak256(
                abi.encodePacked(address(this), _token, _amount, _dstChainId, _receiver, _nonce, uint64(block.chainid))
            );
    }

    function computePegV1BurnId(
        address _receiver,
        address _token,
        uint256 _amount,
        uint64 _nonce
    ) internal view returns (bytes32) {
        return keccak256(abi.encodePacked(address(this), _token, _amount, _receiver, _nonce, uint64(block.chainid)));
    }
}
// SPDX-License-Identifier: GPL-3.0-only

pragma solidity >=0.8.0;

library MsgDataTypes {
    string constant ABORT_PREFIX = "MSG::ABORT:";

    // bridge operation type at the sender side (src chain)
    enum BridgeSendType {
        Null,
        Liquidity,
        PegDeposit,
        PegBurn,
        PegV2Deposit,
        PegV2Burn,
        PegV2BurnFrom
    }

    // bridge operation type at the receiver side (dst chain)
    enum TransferType {
        Null,
        LqRelay, // relay through liquidity bridge
        LqWithdraw, // withdraw from liquidity bridge
        PegMint, // mint through pegged token bridge
        PegWithdraw, // withdraw from original token vault
        PegV2Mint, // mint through pegged token bridge v2
        PegV2Withdraw // withdraw from original token vault v2
    }

    enum MsgType {
        MessageWithTransfer,
        MessageOnly
    }

    enum TxStatus {
        Null,
        Success,
        Fail,
        Fallback,
        Pending // transient state within a transaction
    }

    struct TransferInfo {
        TransferType t;
        address sender;
        address receiver;
        address token;
        uint256 amount;
        uint64 wdseq; // only needed for LqWithdraw (refund)
        uint64 srcChainId;
        bytes32 refId;
        bytes32 srcTxHash; // src chain msg tx hash
    }

    struct RouteInfo {
        address sender;
        address receiver;
        uint64 srcChainId;
        bytes32 srcTxHash; // src chain msg tx hash
    }

    // used for msg from non-evm chains with longer-bytes address
    struct RouteInfo2 {
        bytes sender;
        address receiver;
        uint64 srcChainId;
        bytes32 srcTxHash;
    }

    // combination of RouteInfo and RouteInfo2 for easier processing
    struct Route {
        address sender; // from RouteInfo
        bytes senderBytes; // from RouteInfo2
        address receiver;
        uint64 srcChainId;
        bytes32 srcTxHash;
    }

    struct MsgWithTransferExecutionParams {
        bytes message;
        TransferInfo transfer;
        bytes[] sigs;
        address[] signers;
        uint256[] powers;
    }

    struct BridgeTransferParams {
        bytes request;
        bytes[] sigs;
        address[] signers;
        uint256[] powers;
    }
}
// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.0;

/// @notice Modern and gas efficient ERC20 + EIP-2612 implementation.
/// @author Solmate (https://github.com/transmissions11/solmate/blob/main/src/tokens/ERC20.sol)
/// @author Modified from Uniswap (https://github.com/Uniswap/uniswap-v2-core/blob/master/contracts/UniswapV2ERC20.sol)
/// @dev Do not manually set balances without updating totalSupply, as the sum of all user balances must not exceed it.
abstract contract ERC20 {
    /*//////////////////////////////////////////////////////////////
                                 EVENTS
    //////////////////////////////////////////////////////////////*/

    event Transfer(address indexed from, address indexed to, uint256 amount);

    event Approval(address indexed owner, address indexed spender, uint256 amount);

    /*//////////////////////////////////////////////////////////////
                            METADATA STORAGE
    //////////////////////////////////////////////////////////////*/

    string public name;

    string public symbol;

    uint8 public immutable decimals;

    /*//////////////////////////////////////////////////////////////
                              ERC20 STORAGE
    //////////////////////////////////////////////////////////////*/

    uint256 public totalSupply;

    mapping(address => uint256) public balanceOf;

    mapping(address => mapping(address => uint256)) public allowance;

    /*//////////////////////////////////////////////////////////////
                            EIP-2612 STORAGE
    //////////////////////////////////////////////////////////////*/

    uint256 internal immutable INITIAL_CHAIN_ID;

    bytes32 internal immutable INITIAL_DOMAIN_SEPARATOR;

    mapping(address => uint256) public nonces;

    /*//////////////////////////////////////////////////////////////
                               CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/

    constructor(
        string memory _name,
        string memory _symbol,
        uint8 _decimals
    ) {
        name = _name;
        symbol = _symbol;
        decimals = _decimals;

        INITIAL_CHAIN_ID = block.chainid;
        INITIAL_DOMAIN_SEPARATOR = computeDomainSeparator();
    }

    /*//////////////////////////////////////////////////////////////
                               ERC20 LOGIC
    //////////////////////////////////////////////////////////////*/

    function approve(address spender, uint256 amount) public virtual returns (bool) {
        allowance[msg.sender][spender] = amount;

        emit Approval(msg.sender, spender, amount);

        return true;
    }

    function transfer(address to, uint256 amount) public virtual returns (bool) {
        balanceOf[msg.sender] -= amount;

        // Cannot overflow because the sum of all user
        // balances can't exceed the max uint256 value.
        unchecked {
            balanceOf[to] += amount;
        }

        emit Transfer(msg.sender, to, amount);

        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual returns (bool) {
        uint256 allowed = allowance[from][msg.sender]; // Saves gas for limited approvals.

        if (allowed != type(uint256).max) allowance[from][msg.sender] = allowed - amount;

        balanceOf[from] -= amount;

        // Cannot overflow because the sum of all user
        // balances can't exceed the max uint256 value.
        unchecked {
            balanceOf[to] += amount;
        }

        emit Transfer(from, to, amount);

        return true;
    }

    /*//////////////////////////////////////////////////////////////
                             EIP-2612 LOGIC
    //////////////////////////////////////////////////////////////*/

    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public virtual {
        require(deadline >= block.timestamp, "PERMIT_DEADLINE_EXPIRED");

        // Unchecked because the only math done is incrementing
        // the owner's nonce which cannot realistically overflow.
        unchecked {
            address recoveredAddress = ecrecover(
                keccak256(
                    abi.encodePacked(
                        "\x19\x01",
                        DOMAIN_SEPARATOR(),
                        keccak256(
                            abi.encode(
                                keccak256(
                                    "Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)"
                                ),
                                owner,
                                spender,
                                value,
                                nonces[owner]++,
                                deadline
                            )
                        )
                    )
                ),
                v,
                r,
                s
            );

            require(recoveredAddress != address(0) && recoveredAddress == owner, "INVALID_SIGNER");

            allowance[recoveredAddress][spender] = value;
        }

        emit Approval(owner, spender, value);
    }

    function DOMAIN_SEPARATOR() public view virtual returns (bytes32) {
        return block.chainid == INITIAL_CHAIN_ID ? INITIAL_DOMAIN_SEPARATOR : computeDomainSeparator();
    }

    function computeDomainSeparator() internal view virtual returns (bytes32) {
        return
            keccak256(
                abi.encode(
                    keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"),
                    keccak256(bytes(name)),
                    keccak256("1"),
                    block.chainid,
                    address(this)
                )
            );
    }

    /*//////////////////////////////////////////////////////////////
                        INTERNAL MINT/BURN LOGIC
    //////////////////////////////////////////////////////////////*/

    function _mint(address to, uint256 amount) internal virtual {
        totalSupply += amount;

        // Cannot overflow because the sum of all user
        // balances can't exceed the max uint256 value.
        unchecked {
            balanceOf[to] += amount;
        }

        emit Transfer(address(0), to, amount);
    }

    function _burn(address from, uint256 amount) internal virtual {
        balanceOf[from] -= amount;

        // Cannot underflow because a user's balance
        // will never be larger than the total supply.
        unchecked {
            totalSupply -= amount;
        }

        emit Transfer(from, address(0), amount);
    }
}
// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.0;

import {ERC20} from "./ERC20.sol";

import {SafeTransferLib} from "../utils/SafeTransferLib.sol";

/// @notice Minimalist and modern Wrapped Ether implementation.
/// @author Solmate (https://github.com/transmissions11/solmate/blob/main/src/tokens/WETH.sol)
/// @author Inspired by WETH9 (https://github.com/dapphub/ds-weth/blob/master/src/weth9.sol)
contract WETH is ERC20("Wrapped Ether", "WETH", 18) {
    using SafeTransferLib for address;

    event Deposit(address indexed from, uint256 amount);

    event Withdrawal(address indexed to, uint256 amount);

    function deposit() public payable virtual {
        _mint(msg.sender, msg.value);

        emit Deposit(msg.sender, msg.value);
    }

    function withdraw(uint256 amount) public virtual {
        _burn(msg.sender, amount);

        emit Withdrawal(msg.sender, amount);

        msg.sender.safeTransferETH(amount);
    }

    receive() external payable virtual {
        deposit();
    }
}
// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.0;

import {ERC20} from "../tokens/ERC20.sol";

/// @notice Safe ETH and ERC20 transfer library that gracefully handles missing return values.
/// @author Solmate (https://github.com/transmissions11/solmate/blob/main/src/utils/SafeTransferLib.sol)
/// @dev Use with caution! Some functions in this library knowingly create dirty bits at the destination of the free memory pointer.
/// @dev Note that none of the functions in this library check that a token has code at all! That responsibility is delegated to the caller.
library SafeTransferLib {
    /*//////////////////////////////////////////////////////////////
                             ETH OPERATIONS
    //////////////////////////////////////////////////////////////*/

    function safeTransferETH(address to, uint256 amount) internal {
        bool success;

        /// @solidity memory-safe-assembly
        assembly {
            // Transfer the ETH and store if it succeeded or not.
            success := call(gas(), to, amount, 0, 0, 0, 0)
        }

        require(success, "ETH_TRANSFER_FAILED");
    }

    /*//////////////////////////////////////////////////////////////
                            ERC20 OPERATIONS
    //////////////////////////////////////////////////////////////*/

    function safeTransferFrom(
        ERC20 token,
        address from,
        address to,
        uint256 amount
    ) internal {
        bool success;

        /// @solidity memory-safe-assembly
        assembly {
            // Get a pointer to some free memory.
            let freeMemoryPointer := mload(0x40)

            // Write the abi-encoded calldata into memory, beginning with the function selector.
            mstore(freeMemoryPointer, 0x23b872dd00000000000000000000000000000000000000000000000000000000)
            mstore(add(freeMemoryPointer, 4), from) // Append the "from" argument.
            mstore(add(freeMemoryPointer, 36), to) // Append the "to" argument.
            mstore(add(freeMemoryPointer, 68), amount) // Append the "amount" argument.

            success := and(
                // Set success to whether the call reverted, if not we check it either
                // returned exactly 1 (can't just be non-zero data), or had no return data.
                or(and(eq(mload(0), 1), gt(returndatasize(), 31)), iszero(returndatasize())),
                // We use 100 because the length of our calldata totals up like so: 4 + 32 * 3.
                // We use 0 and 32 to copy up to 32 bytes of return data into the scratch space.
                // Counterintuitively, this call must be positioned second to the or() call in the
                // surrounding and() call or else returndatasize() will be zero during the computation.
                call(gas(), token, 0, freeMemoryPointer, 100, 0, 32)
            )
        }

        require(success, "TRANSFER_FROM_FAILED");
    }

    function safeTransfer(
        ERC20 token,
        address to,
        uint256 amount
    ) internal {
        bool success;

        /// @solidity memory-safe-assembly
        assembly {
            // Get a pointer to some free memory.
            let freeMemoryPointer := mload(0x40)

            // Write the abi-encoded calldata into memory, beginning with the function selector.
            mstore(freeMemoryPointer, 0xa9059cbb00000000000000000000000000000000000000000000000000000000)
            mstore(add(freeMemoryPointer, 4), to) // Append the "to" argument.
            mstore(add(freeMemoryPointer, 36), amount) // Append the "amount" argument.

            success := and(
                // Set success to whether the call reverted, if not we check it either
                // returned exactly 1 (can't just be non-zero data), or had no return data.
                or(and(eq(mload(0), 1), gt(returndatasize(), 31)), iszero(returndatasize())),
                // We use 68 because the length of our calldata totals up like so: 4 + 32 * 2.
                // We use 0 and 32 to copy up to 32 bytes of return data into the scratch space.
                // Counterintuitively, this call must be positioned second to the or() call in the
                // surrounding and() call or else returndatasize() will be zero during the computation.
                call(gas(), token, 0, freeMemoryPointer, 68, 0, 32)
            )
        }

        require(success, "TRANSFER_FAILED");
    }

    function safeApprove(
        ERC20 token,
        address to,
        uint256 amount
    ) internal {
        bool success;

        /// @solidity memory-safe-assembly
        assembly {
            // Get a pointer to some free memory.
            let freeMemoryPointer := mload(0x40)

            // Write the abi-encoded calldata into memory, beginning with the function selector.
            mstore(freeMemoryPointer, 0x095ea7b300000000000000000000000000000000000000000000000000000000)
            mstore(add(freeMemoryPointer, 4), to) // Append the "to" argument.
            mstore(add(freeMemoryPointer, 36), amount) // Append the "amount" argument.

            success := and(
                // Set success to whether the call reverted, if not we check it either
                // returned exactly 1 (can't just be non-zero data), or had no return data.
                or(and(eq(mload(0), 1), gt(returndatasize(), 31)), iszero(returndatasize())),
                // We use 68 because the length of our calldata totals up like so: 4 + 32 * 2.
                // We use 0 and 32 to copy up to 32 bytes of return data into the scratch space.
                // Counterintuitively, this call must be positioned second to the or() call in the
                // surrounding and() call or else returndatasize() will be zero during the computation.
                call(gas(), token, 0, freeMemoryPointer, 68, 0, 32)
            )
        }

        require(success, "APPROVE_FAILED");
    }
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

error AlreadyInitialized();
error CannotAuthoriseSelf();
error CannotBridgeToSameNetwork();
error ContractCallNotAllowed();
error CumulativeSlippageTooHigh(uint256 minAmount, uint256 receivedAmount);
error ExternalCallFailed();
error InformationMismatch();
error InsufficientBalance(uint256 required, uint256 balance);
error InvalidAmount();
error InvalidCallData();
error InvalidConfig();
error InvalidContract();
error InvalidDestinationChain();
error InvalidFallbackAddress();
error InvalidReceiver();
error InvalidSendingToken();
error NativeAssetNotSupported();
error NativeAssetTransferFailed();
error NoSwapDataProvided();
error NoSwapFromZeroBalance();
error NotAContract();
error NotInitialized();
error NoTransferToNullAddress();
error NullAddrIsNotAnERC20Token();
error NullAddrIsNotAValidSpender();
error OnlyContractOwner();
error RecoveryAddressCannotBeZero();
error ReentrancyError();
error TokenNotSupported();
error UnAuthorized();
error UnsupportedChainId(uint256 chainId);
error WithdrawFailed();
error ZeroAmount();
// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import { LibDiamond } from "../Libraries/LibDiamond.sol";
import { LibAccess } from "../Libraries/LibAccess.sol";
import { CannotAuthoriseSelf } from "../Errors/GenericErrors.sol";

/// @title Access Manager Facet
/// @author LI.FI (https://li.fi)
/// @notice Provides functionality for managing method level access control
/// @custom:version 1.0.0
contract AccessManagerFacet {
    /// Events ///

    event ExecutionAllowed(address indexed account, bytes4 indexed method);
    event ExecutionDenied(address indexed account, bytes4 indexed method);

    /// External Methods ///

    /// @notice Sets whether a specific address can call a method
    /// @param _selector The method selector to set access for
    /// @param _executor The address to set method access for
    /// @param _canExecute Whether or not the address can execute the specified method
    function setCanExecute(
        bytes4 _selector,
        address _executor,
        bool _canExecute
    ) external {
        if (_executor == address(this)) {
            revert CannotAuthoriseSelf();
        }
        LibDiamond.enforceIsContractOwner();
        _canExecute
            ? LibAccess.addAccess(_selector, _executor)
            : LibAccess.removeAccess(_selector, _executor);
        if (_canExecute) {
            emit ExecutionAllowed(_executor, _selector);
        } else {
            emit ExecutionDenied(_executor, _selector);
        }
    }

    /// @notice Check if a method can be executed by a specific address
    /// @param _selector The method selector to check
    /// @param _executor The address to check
    function addressCanExecuteMethod(
        bytes4 _selector,
        address _executor
    ) external view returns (bool) {
        return LibAccess.accessStorage().execAccess[_selector][_executor];
    }
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "../../lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import { ILiFi } from "../Interfaces/ILiFi.sol";
import { IAcrossSpokePool } from "../Interfaces/IAcrossSpokePool.sol";
import { LibAsset } from "../Libraries/LibAsset.sol";
import { LibSwap } from "../Libraries/LibSwap.sol";
import { ReentrancyGuard } from "../Helpers/ReentrancyGuard.sol";
import { SwapperV2 } from "../Helpers/SwapperV2.sol";
import { Validatable } from "../Helpers/Validatable.sol";

/// @title Across Facet
/// @author LI.FI (https://li.fi)
/// @notice Provides functionality for bridging through Across Protocol
/// @custom:version 2.0.0
contract AcrossFacet is ILiFi, ReentrancyGuard, SwapperV2, Validatable {
    /// Storage ///

    /// @notice The contract address of the spoke pool on the source chain.
    IAcrossSpokePool private immutable spokePool;

    /// @notice The WETH address on the current chain.
    address private immutable wrappedNative;

    /// Types ///

    /// @param relayerFeePct The relayer fee in token percentage with 18 decimals.
    /// @param quoteTimestamp The timestamp associated with the suggested fee.
    /// @param message Arbitrary data that can be used to pass additional information to the recipient along with the tokens.
    /// @param maxCount Used to protect the depositor from frontrunning to guarantee their quote remains valid.
    struct AcrossData {
        int64 relayerFeePct;
        uint32 quoteTimestamp;
        bytes message;
        uint256 maxCount;
    }

    /// Constructor ///

    /// @notice Initialize the contract.
    /// @param _spokePool The contract address of the spoke pool on the source chain.
    /// @param _wrappedNative The address of the wrapped native token on the source chain.
    constructor(IAcrossSpokePool _spokePool, address _wrappedNative) {
        spokePool = _spokePool;
        wrappedNative = _wrappedNative;
    }

    /// External Methods ///

    /// @notice Bridges tokens via Across
    /// @param _bridgeData the core information needed for bridging
    /// @param _acrossData data specific to Across
    function startBridgeTokensViaAcross(
        ILiFi.BridgeData memory _bridgeData,
        AcrossData calldata _acrossData
    )
        external
        payable
        nonReentrant
        refundExcessNative(payable(msg.sender))
        validateBridgeData(_bridgeData)
        doesNotContainSourceSwaps(_bridgeData)
        doesNotContainDestinationCalls(_bridgeData)
    {
        LibAsset.depositAsset(
            _bridgeData.sendingAssetId,
            _bridgeData.minAmount
        );
        _startBridge(_bridgeData, _acrossData);
    }

    /// @notice Performs a swap before bridging via Across
    /// @param _bridgeData the core information needed for bridging
    /// @param _swapData an array of swap related data for performing swaps before bridging
    /// @param _acrossData data specific to Across
    function swapAndStartBridgeTokensViaAcross(
        ILiFi.BridgeData memory _bridgeData,
        LibSwap.SwapData[] calldata _swapData,
        AcrossData calldata _acrossData
    )
        external
        payable
        nonReentrant
        refundExcessNative(payable(msg.sender))
        containsSourceSwaps(_bridgeData)
        doesNotContainDestinationCalls(_bridgeData)
        validateBridgeData(_bridgeData)
    {
        _bridgeData.minAmount = _depositAndSwap(
            _bridgeData.transactionId,
            _bridgeData.minAmount,
            _swapData,
            payable(msg.sender)
        );
        _startBridge(_bridgeData, _acrossData);
    }

    /// Internal Methods ///

    /// @dev Contains the business logic for the bridge via Across
    /// @param _bridgeData the core information needed for bridging
    /// @param _acrossData data specific to Across
    function _startBridge(
        ILiFi.BridgeData memory _bridgeData,
        AcrossData calldata _acrossData
    ) internal {
        if (LibAsset.isNativeAsset(_bridgeData.sendingAssetId)) {
            spokePool.deposit{ value: _bridgeData.minAmount }(
                _bridgeData.receiver,
                wrappedNative,
                _bridgeData.minAmount,
                _bridgeData.destinationChainId,
                _acrossData.relayerFeePct,
                _acrossData.quoteTimestamp,
                _acrossData.message,
                _acrossData.maxCount
            );
        } else {
            LibAsset.maxApproveERC20(
                IERC20(_bridgeData.sendingAssetId),
                address(spokePool),
                _bridgeData.minAmount
            );
            spokePool.deposit(
                _bridgeData.receiver,
                _bridgeData.sendingAssetId,
                _bridgeData.minAmount,
                _bridgeData.destinationChainId,
                _acrossData.relayerFeePct,
                _acrossData.quoteTimestamp,
                _acrossData.message,
                _acrossData.maxCount
            );
        }

        emit LiFiTransferStarted(_bridgeData);
    }
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import { ILiFi } from "../Interfaces/ILiFi.sol";
import { IAllBridge } from "../Interfaces/IAllBridge.sol";
import { LibAsset, IERC20 } from "../Libraries/LibAsset.sol";
import { SwapperV2 } from "../Helpers/SwapperV2.sol";
import { ReentrancyGuard } from "../Helpers/ReentrancyGuard.sol";
import { Validatable } from "../Helpers/Validatable.sol";
import { LibSwap } from "../Libraries/LibSwap.sol";

/// @title Allbridge Facet
/// @author Li.Finance (https://li.finance)
/// @notice Provides functionality for bridging through AllBridge
/// @custom:version 2.0.0
contract AllBridgeFacet is ILiFi, ReentrancyGuard, SwapperV2, Validatable {
    /// @notice The contract address of the AllBridge router on the source chain.
    IAllBridge private immutable allBridge;

    /// @notice The struct for the AllBridge data.
    /// @param fees The amount of token to pay the messenger and the bridge
    /// @param recipient The address of the token receiver after bridging.
    /// @param destinationChainId The destination chain id.
    /// @param receiveToken The token to receive on the destination chain.
    /// @param nonce A random nonce to associate with the tx.
    /// @param messenger The messenger protocol enum
    /// @param payFeeWithSendingAsset Whether to pay the relayer fee with the sending asset or not
    struct AllBridgeData {
        uint256 fees;
        bytes32 recipient;
        uint256 destinationChainId;
        bytes32 receiveToken;
        uint256 nonce;
        IAllBridge.MessengerProtocol messenger;
        bool payFeeWithSendingAsset;
    }

    /// @notice Initializes the AllBridge contract
    /// @param _allBridge The address of the AllBridge contract
    constructor(IAllBridge _allBridge) {
        allBridge = _allBridge;
    }

    /// @notice Bridge tokens to another chain via AllBridge
    /// @param _bridgeData The bridge data struct
    function startBridgeTokensViaAllBridge(
        ILiFi.BridgeData memory _bridgeData,
        AllBridgeData calldata _allBridgeData
    )
        external
        payable
        nonReentrant
        refundExcessNative(payable(msg.sender))
        validateBridgeData(_bridgeData)
        doesNotContainSourceSwaps(_bridgeData)
        doesNotContainDestinationCalls(_bridgeData)
    {
        LibAsset.depositAsset(
            _bridgeData.sendingAssetId,
            _bridgeData.minAmount
        );
        _startBridge(_bridgeData, _allBridgeData);
    }

    /// @notice Bridge tokens to another chain via AllBridge
    /// @param _bridgeData The bridge data struct
    /// @param _swapData The swap data struct
    /// @param _allBridgeData The AllBridge data struct
    function swapAndStartBridgeTokensViaAllBridge(
        ILiFi.BridgeData memory _bridgeData,
        LibSwap.SwapData[] calldata _swapData,
        AllBridgeData calldata _allBridgeData
    )
        external
        payable
        nonReentrant
        refundExcessNative(payable(msg.sender))
        containsSourceSwaps(_bridgeData)
        doesNotContainDestinationCalls(_bridgeData)
        validateBridgeData(_bridgeData)
    {
        _bridgeData.minAmount = _depositAndSwap(
            _bridgeData.transactionId,
            _bridgeData.minAmount,
            _swapData,
            payable(msg.sender)
        );
        _startBridge(_bridgeData, _allBridgeData);
    }

    /// @notice Bridge tokens to another chain via AllBridge
    /// @param _bridgeData The bridge data struct
    /// @param _allBridgeData The allBridge data struct for AllBridge specicific data
    function _startBridge(
        ILiFi.BridgeData memory _bridgeData,
        AllBridgeData calldata _allBridgeData
    ) internal {
        LibAsset.maxApproveERC20(
            IERC20(_bridgeData.sendingAssetId),
            address(allBridge),
            _bridgeData.minAmount
        );

        if (_allBridgeData.payFeeWithSendingAsset) {
            allBridge.swapAndBridge(
                bytes32(uint256(uint160(_bridgeData.sendingAssetId))),
                _bridgeData.minAmount,
                _allBridgeData.recipient,
                _allBridgeData.destinationChainId,
                _allBridgeData.receiveToken,
                _allBridgeData.nonce,
                _allBridgeData.messenger,
                _allBridgeData.fees
            );
        } else {
            allBridge.swapAndBridge{ value: _allBridgeData.fees }(
                bytes32(uint256(uint160(_bridgeData.sendingAssetId))),
                _bridgeData.minAmount,
                _allBridgeData.recipient,
                _allBridgeData.destinationChainId,
                _allBridgeData.receiveToken,
                _allBridgeData.nonce,
                _allBridgeData.messenger,
                0
            );
        }

        emit LiFiTransferStarted(_bridgeData);
    }
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import { ILiFi } from "../Interfaces/ILiFi.sol";
import { IConnextHandler } from "../Interfaces/IConnextHandler.sol";
import { LibAsset, IERC20 } from "../Libraries/LibAsset.sol";
import { ReentrancyGuard } from "../Helpers/ReentrancyGuard.sol";
import { InformationMismatch } from "../Errors/GenericErrors.sol";
import { SwapperV2, LibSwap } from "../Helpers/SwapperV2.sol";
import { Validatable } from "../Helpers/Validatable.sol";

/// @title Amarok Facet
/// @author LI.FI (https://li.fi)
/// @notice Provides functionality for bridging through Connext Amarok
/// @custom:version 2.0.0
contract AmarokFacet is ILiFi, ReentrancyGuard, SwapperV2, Validatable {
    /// Storage ///

    /// @notice The contract address of the connext handler on the source chain.
    IConnextHandler private immutable connextHandler;

    /// @param callData The data to execute on the receiving chain. If no crosschain call is needed, then leave empty.
    /// @param callTo The address of the contract on dest chain that will receive bridged funds and execute data
    /// @param relayerFee The amount of relayer fee the tx called xcall with
    /// @param slippageTol Max bps of original due to slippage (i.e. would be 9995 to tolerate .05% slippage)
    /// @param delegate Destination delegate address
    /// @param destChainDomainId The Amarok-specific domainId of the destination chain
    /// @param payFeeWithSendingAsset Whether to pay the relayer fee with the sending asset or not
    struct AmarokData {
        bytes callData;
        address callTo;
        uint256 relayerFee;
        uint256 slippageTol;
        address delegate;
        uint32 destChainDomainId;
        bool payFeeWithSendingAsset;
    }

    /// Constructor ///

    /// @notice Initialize the contract.
    /// @param _connextHandler The contract address of the connext handler on the source chain.
    constructor(IConnextHandler _connextHandler) {
        connextHandler = _connextHandler;
    }

    /// External Methods ///

    /// @notice Bridges tokens via Amarok
    /// @param _bridgeData Data containing core information for bridging
    /// @param _amarokData Data specific to bridge
    function startBridgeTokensViaAmarok(
        BridgeData calldata _bridgeData,
        AmarokData calldata _amarokData
    )
        external
        payable
        nonReentrant
        refundExcessNative(payable(msg.sender))
        doesNotContainSourceSwaps(_bridgeData)
        validateBridgeData(_bridgeData)
        noNativeAsset(_bridgeData)
    {
        validateDestinationCallFlag(_bridgeData, _amarokData);

        LibAsset.depositAsset(
            _bridgeData.sendingAssetId,
            _bridgeData.minAmount
        );

        _startBridge(_bridgeData, _amarokData);
    }

    /// @notice Performs a swap before bridging via Amarok
    /// @param _bridgeData The core information needed for bridging
    /// @param _swapData An array of swap related data for performing swaps before bridging
    /// @param _amarokData Data specific to Amarok
    function swapAndStartBridgeTokensViaAmarok(
        BridgeData memory _bridgeData,
        LibSwap.SwapData[] calldata _swapData,
        AmarokData calldata _amarokData
    )
        external
        payable
        nonReentrant
        refundExcessNative(payable(msg.sender))
        containsSourceSwaps(_bridgeData)
        validateBridgeData(_bridgeData)
        noNativeAsset(_bridgeData)
    {
        validateDestinationCallFlag(_bridgeData, _amarokData);

        _bridgeData.minAmount = _depositAndSwap(
            _bridgeData.transactionId,
            _bridgeData.minAmount,
            _swapData,
            payable(msg.sender),
            _amarokData.relayerFee
        );

        _startBridge(_bridgeData, _amarokData);
    }

    /// Private Methods ///

    /// @dev Contains the business logic for the bridge via Amarok
    /// @param _bridgeData The core information needed for bridging
    /// @param _amarokData Data specific to Amarok
    function _startBridge(
        BridgeData memory _bridgeData,
        AmarokData calldata _amarokData
    ) private {
        // give max approval for token to Amarok bridge, if not already
        LibAsset.maxApproveERC20(
            IERC20(_bridgeData.sendingAssetId),
            address(connextHandler),
            _bridgeData.minAmount
        );

        // initiate bridge transaction
        if (_amarokData.payFeeWithSendingAsset) {
            connextHandler.xcall(
                _amarokData.destChainDomainId,
                _amarokData.callTo,
                _bridgeData.sendingAssetId,
                _amarokData.delegate,
                _bridgeData.minAmount - _amarokData.relayerFee,
                _amarokData.slippageTol,
                _amarokData.callData,
                _amarokData.relayerFee
            );
        } else {
            connextHandler.xcall{ value: _amarokData.relayerFee }(
                _amarokData.destChainDomainId,
                _amarokData.callTo,
                _bridgeData.sendingAssetId,
                _amarokData.delegate,
                _bridgeData.minAmount,
                _amarokData.slippageTol,
                _amarokData.callData
            );
        }

        emit LiFiTransferStarted(_bridgeData);
    }

    function validateDestinationCallFlag(
        ILiFi.BridgeData memory _bridgeData,
        AmarokData calldata _amarokData
    ) private pure {
        if (
            (_amarokData.callData.length > 0) != _bridgeData.hasDestinationCall
        ) {
            revert InformationMismatch();
        }
    }
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import { ILiFi } from "../Interfaces/ILiFi.sol";
import { IGatewayRouter } from "../Interfaces/IGatewayRouter.sol";
import { LibAsset, IERC20 } from "../Libraries/LibAsset.sol";
import { ReentrancyGuard } from "../Helpers/ReentrancyGuard.sol";
import { InvalidAmount } from "../Errors/GenericErrors.sol";
import { SwapperV2, LibSwap } from "../Helpers/SwapperV2.sol";
import { Validatable } from "../Helpers/Validatable.sol";

/// @title Arbitrum Bridge Facet
/// @author Li.Finance (https://li.finance)
/// @notice Provides functionality for bridging through Arbitrum Bridge
/// @custom:version 1.0.0
contract ArbitrumBridgeFacet is
    ILiFi,
    ReentrancyGuard,
    SwapperV2,
    Validatable
{
    /// Storage ///

    /// @notice The contract address of the gateway router on the source chain.
    IGatewayRouter private immutable gatewayRouter;

    /// @notice The contract address of the inbox on the source chain.
    IGatewayRouter private immutable inbox;

    /// Types ///

    /// @param maxSubmissionCost Max gas deducted from user's L2 balance to cover base submission fee.
    /// @param maxGas Max gas deducted from user's L2 balance to cover L2 execution.
    /// @param maxGasPrice price bid for L2 execution.
    struct ArbitrumData {
        uint256 maxSubmissionCost;
        uint256 maxGas;
        uint256 maxGasPrice;
    }

    /// Constructor ///

    /// @notice Initialize the contract.
    /// @param _gatewayRouter The contract address of the gateway router on the source chain.
    /// @param _inbox The contract address of the inbox on the source chain.
    constructor(IGatewayRouter _gatewayRouter, IGatewayRouter _inbox) {
        gatewayRouter = _gatewayRouter;
        inbox = _inbox;
    }

    /// External Methods ///

    /// @notice Bridges tokens via Arbitrum Bridge
    /// @param _bridgeData Data containing core information for bridging
    /// @param _arbitrumData Data for gateway router address, asset id and amount
    function startBridgeTokensViaArbitrumBridge(
        ILiFi.BridgeData memory _bridgeData,
        ArbitrumData calldata _arbitrumData
    )
        external
        payable
        nonReentrant
        refundExcessNative(payable(msg.sender))
        doesNotContainSourceSwaps(_bridgeData)
        doesNotContainDestinationCalls(_bridgeData)
        validateBridgeData(_bridgeData)
    {
        uint256 cost = _arbitrumData.maxSubmissionCost +
            _arbitrumData.maxGas *
            _arbitrumData.maxGasPrice;

        LibAsset.depositAsset(
            _bridgeData.sendingAssetId,
            _bridgeData.minAmount
        );

        _startBridge(_bridgeData, _arbitrumData, cost);
    }

    /// @notice Performs a swap before bridging via Arbitrum Bridge
    /// @param _bridgeData Data containing core information for bridging
    /// @param _swapData An array of swap related data for performing swaps before bridging
    /// @param _arbitrumData Data for gateway router address, asset id and amount
    function swapAndStartBridgeTokensViaArbitrumBridge(
        ILiFi.BridgeData memory _bridgeData,
        LibSwap.SwapData[] calldata _swapData,
        ArbitrumData calldata _arbitrumData
    )
        external
        payable
        nonReentrant
        refundExcessNative(payable(msg.sender))
        containsSourceSwaps(_bridgeData)
        doesNotContainDestinationCalls(_bridgeData)
        validateBridgeData(_bridgeData)
    {
        uint256 cost = _arbitrumData.maxSubmissionCost +
            _arbitrumData.maxGas *
            _arbitrumData.maxGasPrice;

        _bridgeData.minAmount = _depositAndSwap(
            _bridgeData.transactionId,
            _bridgeData.minAmount,
            _swapData,
            payable(msg.sender),
            cost
        );

        _startBridge(_bridgeData, _arbitrumData, cost);
    }

    /// Private Methods ///

    /// @dev Contains the business logic for the bridge via Arbitrum Bridge
    /// @param _bridgeData Data containing core information for bridging
    /// @param _arbitrumData Data for gateway router address, asset id and amount
    /// @param _cost Additional amount of native asset for the fee
    function _startBridge(
        ILiFi.BridgeData memory _bridgeData,
        ArbitrumData calldata _arbitrumData,
        uint256 _cost
    ) private {
        if (LibAsset.isNativeAsset(_bridgeData.sendingAssetId)) {
            inbox.unsafeCreateRetryableTicket{
                value: _bridgeData.minAmount + _cost
            }(
                _bridgeData.receiver,
                _bridgeData.minAmount, // l2CallValue
                _arbitrumData.maxSubmissionCost,
                _bridgeData.receiver, // excessFeeRefundAddress
                _bridgeData.receiver, // callValueRefundAddress
                _arbitrumData.maxGas,
                _arbitrumData.maxGasPrice,
                ""
            );
        } else {
            LibAsset.maxApproveERC20(
                IERC20(_bridgeData.sendingAssetId),
                gatewayRouter.getGateway(_bridgeData.sendingAssetId),
                _bridgeData.minAmount
            );
            gatewayRouter.outboundTransfer{ value: _cost }(
                _bridgeData.sendingAssetId,
                _bridgeData.receiver,
                _bridgeData.minAmount,
                _arbitrumData.maxGas,
                _arbitrumData.maxGasPrice,
                abi.encode(_arbitrumData.maxSubmissionCost, "")
            );
        }

        emit LiFiTransferStarted(_bridgeData);
    }
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import { ILiFi } from "../Interfaces/ILiFi.sol";
import { LibSwap } from "../Libraries/LibSwap.sol";
import { AmarokFacet } from "./AmarokFacet.sol";
import { StargateFacet } from "./StargateFacet.sol";
import { CelerIMFacetBase, CelerIM } from "../../src/Helpers/CelerIMFacetBase.sol";
import { StandardizedCallFacet } from "../../src/Facets/StandardizedCallFacet.sol";
import { LibBytes } from "../Libraries/LibBytes.sol";

/// @title Calldata Verification Facet
/// @author LI.FI (https://li.fi)
/// @notice Provides functionality for verifying calldata
/// @custom:version 1.1.1
contract CalldataVerificationFacet {
    using LibBytes for bytes;

    /// @notice Extracts the bridge data from the calldata
    /// @param data The calldata to extract the bridge data from
    /// @return bridgeData The bridge data extracted from the calldata
    function extractBridgeData(
        bytes calldata data
    ) external pure returns (ILiFi.BridgeData memory bridgeData) {
        bridgeData = _extractBridgeData(data);
    }

    /// @notice Extracts the swap data from the calldata
    /// @param data The calldata to extract the swap data from
    /// @return swapData The swap data extracted from the calldata
    function extractSwapData(
        bytes calldata data
    ) external pure returns (LibSwap.SwapData[] memory swapData) {
        swapData = _extractSwapData(data);
    }

    /// @notice Extracts the bridge data and swap data from the calldata
    /// @param data The calldata to extract the bridge data and swap data from
    /// @return bridgeData The bridge data extracted from the calldata
    /// @return swapData The swap data extracted from the calldata
    function extractData(
        bytes calldata data
    )
        external
        pure
        returns (
            ILiFi.BridgeData memory bridgeData,
            LibSwap.SwapData[] memory swapData
        )
    {
        bridgeData = _extractBridgeData(data);
        if (bridgeData.hasSourceSwaps) {
            swapData = _extractSwapData(data);
        }
    }

    /// @notice Extracts the main parameters from the calldata
    /// @param data The calldata to extract the main parameters from
    /// @return bridge The bridge extracted from the calldata
    /// @return sendingAssetId The sending asset id extracted from the calldata
    /// @return receiver The receiver extracted from the calldata
    /// @return amount The min amountfrom the calldata
    /// @return destinationChainId The destination chain id extracted from the calldata
    /// @return hasSourceSwaps Whether the calldata has source swaps
    /// @return hasDestinationCall Whether the calldata has a destination call
    function extractMainParameters(
        bytes calldata data
    )
        public
        pure
        returns (
            string memory bridge,
            address sendingAssetId,
            address receiver,
            uint256 amount,
            uint256 destinationChainId,
            bool hasSourceSwaps,
            bool hasDestinationCall
        )
    {
        ILiFi.BridgeData memory bridgeData = _extractBridgeData(data);

        if (bridgeData.hasSourceSwaps) {
            LibSwap.SwapData[] memory swapData = _extractSwapData(data);
            sendingAssetId = swapData[0].sendingAssetId;
            amount = swapData[0].fromAmount;
        } else {
            sendingAssetId = bridgeData.sendingAssetId;
            amount = bridgeData.minAmount;
        }

        return (
            bridgeData.bridge,
            sendingAssetId,
            bridgeData.receiver,
            amount,
            bridgeData.destinationChainId,
            bridgeData.hasSourceSwaps,
            bridgeData.hasDestinationCall
        );
    }

    /// @notice Extracts the generic swap parameters from the calldata
    /// @param data The calldata to extract the generic swap parameters from
    /// @return sendingAssetId The sending asset id extracted from the calldata
    /// @return amount The amount extracted from the calldata
    /// @return receiver The receiver extracted from the calldata
    /// @return receivingAssetId The receiving asset id extracted from the calldata
    /// @return receivingAmount The receiving amount extracted from the calldata
    function extractGenericSwapParameters(
        bytes calldata data
    )
        public
        pure
        returns (
            address sendingAssetId,
            uint256 amount,
            address receiver,
            address receivingAssetId,
            uint256 receivingAmount
        )
    {
        LibSwap.SwapData[] memory swapData;
        bytes memory callData = data;

        if (
            bytes4(data[:4]) == StandardizedCallFacet.standardizedCall.selector
        ) {
            // standardizedCall
            callData = abi.decode(data[4:], (bytes));
        }
        (, , , receiver, receivingAmount, swapData) = abi.decode(
            callData.slice(4, callData.length - 4),
            (bytes32, string, string, address, uint256, LibSwap.SwapData[])
        );

        sendingAssetId = swapData[0].sendingAssetId;
        amount = swapData[0].fromAmount;
        receivingAssetId = swapData[swapData.length - 1].receivingAssetId;
        return (
            sendingAssetId,
            amount,
            receiver,
            receivingAssetId,
            receivingAmount
        );
    }

    /// @notice Validates the calldata
    /// @param data The calldata to validate
    /// @param bridge The bridge to validate or empty string to ignore
    /// @param sendingAssetId The sending asset id to validate
    ///        or 0xFFfFfFffFFfffFFfFFfFFFFFffFFFffffFfFFFfF to ignore
    /// @param receiver The receiver to validate
    ///        or 0xFFfFfFffFFfffFFfFFfFFFFFffFFFffffFfFFFfF to ignore
    /// @param amount The amount to validate or type(uint256).max to ignore
    /// @param destinationChainId The destination chain id to validate
    ///        or type(uint256).max to ignore
    /// @param hasSourceSwaps Whether the calldata has source swaps
    /// @param hasDestinationCall Whether the calldata has a destination call
    /// @return isValid Whether the calldata is validate
    function validateCalldata(
        bytes calldata data,
        string calldata bridge,
        address sendingAssetId,
        address receiver,
        uint256 amount,
        uint256 destinationChainId,
        bool hasSourceSwaps,
        bool hasDestinationCall
    ) external pure returns (bool isValid) {
        ILiFi.BridgeData memory bridgeData;
        (
            bridgeData.bridge,
            bridgeData.sendingAssetId,
            bridgeData.receiver,
            bridgeData.minAmount,
            bridgeData.destinationChainId,
            bridgeData.hasSourceSwaps,
            bridgeData.hasDestinationCall
        ) = extractMainParameters(data);
        return
            // Check bridge
            (keccak256(abi.encodePacked(bridge)) ==
                keccak256(abi.encodePacked("")) ||
                keccak256(abi.encodePacked(bridgeData.bridge)) ==
                keccak256(abi.encodePacked(bridge))) &&
            // Check sendingAssetId
            (sendingAssetId == 0xFFfFfFffFFfffFFfFFfFFFFFffFFFffffFfFFFfF ||
                bridgeData.sendingAssetId == sendingAssetId) &&
            // Check receiver
            (receiver == 0xFFfFfFffFFfffFFfFFfFFFFFffFFFffffFfFFFfF ||
                bridgeData.receiver == receiver) &&
            // Check amount
            (amount == type(uint256).max || bridgeData.minAmount == amount) &&
            // Check destinationChainId
            (destinationChainId == type(uint256).max ||
                bridgeData.destinationChainId == destinationChainId) &&
            // Check hasSourceSwaps
            bridgeData.hasSourceSwaps == hasSourceSwaps &&
            // Check hasDestinationCall
            bridgeData.hasDestinationCall == hasDestinationCall;
    }

    /// @notice Validates the destination calldata
    /// @param data The calldata to validate
    /// @param callTo The call to address to validate
    /// @param dstCalldata The destination calldata to validate
    /// @return isValid Whether the destination calldata is validate
    function validateDestinationCalldata(
        bytes calldata data,
        bytes calldata callTo,
        bytes calldata dstCalldata
    ) external pure returns (bool isValid) {
        bytes memory callData = data;

        // Handle standardizedCall
        if (
            bytes4(data[:4]) == StandardizedCallFacet.standardizedCall.selector
        ) {
            callData = abi.decode(data[4:], (bytes));
        }

        bytes4 selector = abi.decode(callData, (bytes4));

        // Case: Amarok
        if (selector == AmarokFacet.startBridgeTokensViaAmarok.selector) {
            (, AmarokFacet.AmarokData memory amarokData) = abi.decode(
                callData.slice(4, callData.length - 4),
                (ILiFi.BridgeData, AmarokFacet.AmarokData)
            );

            return
                keccak256(dstCalldata) == keccak256(amarokData.callData) &&
                abi.decode(callTo, (address)) == amarokData.callTo;
        }
        if (
            selector == AmarokFacet.swapAndStartBridgeTokensViaAmarok.selector
        ) {
            (, , AmarokFacet.AmarokData memory amarokData) = abi.decode(
                callData.slice(4, callData.length - 4),
                (ILiFi.BridgeData, LibSwap.SwapData[], AmarokFacet.AmarokData)
            );
            return
                keccak256(dstCalldata) == keccak256(amarokData.callData) &&
                abi.decode(callTo, (address)) == amarokData.callTo;
        }

        // Case: Stargate
        if (selector == StargateFacet.startBridgeTokensViaStargate.selector) {
            (, StargateFacet.StargateData memory stargateData) = abi.decode(
                callData.slice(4, callData.length - 4),
                (ILiFi.BridgeData, StargateFacet.StargateData)
            );
            return
                keccak256(dstCalldata) == keccak256(stargateData.callData) &&
                keccak256(callTo) == keccak256(stargateData.callTo);
        }
        if (
            selector ==
            StargateFacet.swapAndStartBridgeTokensViaStargate.selector
        ) {
            (, , StargateFacet.StargateData memory stargateData) = abi.decode(
                callData.slice(4, callData.length - 4),
                (
                    ILiFi.BridgeData,
                    LibSwap.SwapData[],
                    StargateFacet.StargateData
                )
            );
            return
                keccak256(dstCalldata) == keccak256(stargateData.callData) &&
                keccak256(callTo) == keccak256(stargateData.callTo);
        }
        // Case: Celer
        if (
            selector == CelerIMFacetBase.startBridgeTokensViaCelerIM.selector
        ) {
            (, CelerIM.CelerIMData memory celerIMData) = abi.decode(
                callData.slice(4, callData.length - 4),
                (ILiFi.BridgeData, CelerIM.CelerIMData)
            );
            return
                keccak256(dstCalldata) == keccak256(celerIMData.callData) &&
                keccak256(callTo) == keccak256(celerIMData.callTo);
        }
        if (
            selector ==
            CelerIMFacetBase.swapAndStartBridgeTokensViaCelerIM.selector
        ) {
            (, , CelerIM.CelerIMData memory celerIMData) = abi.decode(
                callData.slice(4, callData.length - 4),
                (ILiFi.BridgeData, LibSwap.SwapData[], CelerIM.CelerIMData)
            );
            return
                keccak256(dstCalldata) == keccak256(celerIMData.callData) &&
                keccak256(callTo) == keccak256(celerIMData.callTo);
        }

        // All other cases
        return false;
    }

    /// Internal Methods ///

    /// @notice Extracts the bridge data from the calldata
    /// @param data The calldata to extract the bridge data from
    /// @return bridgeData The bridge data extracted from the calldata
    function _extractBridgeData(
        bytes calldata data
    ) internal pure returns (ILiFi.BridgeData memory bridgeData) {
        if (
            bytes4(data[:4]) == StandardizedCallFacet.standardizedCall.selector
        ) {
            // StandardizedCall
            bytes memory unwrappedData = abi.decode(data[4:], (bytes));
            bridgeData = abi.decode(
                unwrappedData.slice(4, unwrappedData.length - 4),
                (ILiFi.BridgeData)
            );
            return bridgeData;
        }
        // normal call
        bridgeData = abi.decode(data[4:], (ILiFi.BridgeData));
    }

    /// @notice Extracts the swap data from the calldata
    /// @param data The calldata to extract the swap data from
    /// @return swapData The swap data extracted from the calldata
    function _extractSwapData(
        bytes calldata data
    ) internal pure returns (LibSwap.SwapData[] memory swapData) {
        if (
            bytes4(data[:4]) == StandardizedCallFacet.standardizedCall.selector
        ) {
            // standardizedCall
            bytes memory unwrappedData = abi.decode(data[4:], (bytes));
            (, swapData) = abi.decode(
                unwrappedData.slice(4, unwrappedData.length - 4),
                (ILiFi.BridgeData, LibSwap.SwapData[])
            );
            return swapData;
        }
        // normal call
        (, swapData) = abi.decode(
            data[4:],
            (ILiFi.BridgeData, LibSwap.SwapData[])
        );
    }
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import { LibDiamond } from "../Libraries/LibDiamond.sol";
import { LibUtil } from "../Libraries/LibUtil.sol";
import { LibAsset, IERC20 } from "../Libraries/LibAsset.sol";
import { LibAccess } from "../Libraries/LibAccess.sol";
import { ILiFi } from "../Interfaces/ILiFi.sol";
import { ICBridge } from "../Interfaces/ICBridge.sol";
import { ReentrancyGuard } from "../Helpers/ReentrancyGuard.sol";
import { CannotBridgeToSameNetwork } from "../Errors/GenericErrors.sol";
import { SwapperV2, LibSwap } from "../Helpers/SwapperV2.sol";
import { Validatable } from "../Helpers/Validatable.sol";
import { ContractCallNotAllowed, ExternalCallFailed } from "../Errors/GenericErrors.sol";

/// @title CBridge Facet
/// @author LI.FI (https://li.fi)
/// @notice Provides functionality for bridging through CBridge
/// @custom:version 1.0.0
contract CBridgeFacet is ILiFi, ReentrancyGuard, SwapperV2, Validatable {
    /// Storage ///

    /// @notice The contract address of the cbridge on the source chain.
    ICBridge private immutable cBridge;

    /// Types ///

    /// @param maxSlippage The max slippage accepted, given as percentage in point (pip).
    /// @param nonce A number input to guarantee uniqueness of transferId.
    ///              Can be timestamp in practice.
    struct CBridgeData {
        uint32 maxSlippage;
        uint64 nonce;
    }

    /// Events ///
    event CBridgeRefund(
        address indexed _assetAddress,
        address indexed _to,
        uint256 amount
    );

    /// Constructor ///

    /// @notice Initialize the contract.
    /// @param _cBridge The contract address of the cbridge on the source chain.
    constructor(ICBridge _cBridge) {
        cBridge = _cBridge;
    }

    /// External Methods ///

    /// @notice Bridges tokens via CBridge
    /// @param _bridgeData the core information needed for bridging
    /// @param _cBridgeData data specific to CBridge
    function startBridgeTokensViaCBridge(
        ILiFi.BridgeData memory _bridgeData,
        CBridgeData calldata _cBridgeData
    )
        external
        payable
        nonReentrant
        refundExcessNative(payable(msg.sender))
        doesNotContainSourceSwaps(_bridgeData)
        doesNotContainDestinationCalls(_bridgeData)
        validateBridgeData(_bridgeData)
    {
        LibAsset.depositAsset(
            _bridgeData.sendingAssetId,
            _bridgeData.minAmount
        );
        _startBridge(_bridgeData, _cBridgeData);
    }

    /// @notice Performs a swap before bridging via CBridge
    /// @param _bridgeData the core information needed for bridging
    /// @param _swapData an array of swap related data for performing swaps before bridging
    /// @param _cBridgeData data specific to CBridge
    function swapAndStartBridgeTokensViaCBridge(
        ILiFi.BridgeData memory _bridgeData,
        LibSwap.SwapData[] calldata _swapData,
        CBridgeData calldata _cBridgeData
    )
        external
        payable
        nonReentrant
        refundExcessNative(payable(msg.sender))
        containsSourceSwaps(_bridgeData)
        doesNotContainDestinationCalls(_bridgeData)
        validateBridgeData(_bridgeData)
    {
        _bridgeData.minAmount = _depositAndSwap(
            _bridgeData.transactionId,
            _bridgeData.minAmount,
            _swapData,
            payable(msg.sender)
        );
        _startBridge(_bridgeData, _cBridgeData);
    }

    /// @notice Triggers a cBridge refund with calldata produced by cBridge API
    /// @param _callTo The address to execute the calldata on
    /// @param _callData The data to execute
    /// @param _assetAddress Asset to be withdrawn
    /// @param _to Address to withdraw to
    /// @param _amount Amount of asset to withdraw
    function triggerRefund(
        address payable _callTo,
        bytes calldata _callData,
        address _assetAddress,
        address _to,
        uint256 _amount
    ) external {
        if (msg.sender != LibDiamond.contractOwner()) {
            LibAccess.enforceAccessControl();
        }

        // make sure that callTo address is either of the cBridge addresses
        if (address(cBridge) != _callTo) {
            revert ContractCallNotAllowed();
        }

        // call contract
        bool success;
        (success, ) = _callTo.call(_callData);
        if (!success) {
            revert ExternalCallFailed();
        }

        // forward funds to _to address and emit event
        address sendTo = (LibUtil.isZeroAddress(_to)) ? msg.sender : _to;
        LibAsset.transferAsset(_assetAddress, payable(sendTo), _amount);
        emit CBridgeRefund(_assetAddress, sendTo, _amount);
    }

    /// Private Methods ///

    /// @dev Contains the business logic for the bridge via CBridge
    /// @param _bridgeData the core information needed for bridging
    /// @param _cBridgeData data specific to CBridge
    function _startBridge(
        ILiFi.BridgeData memory _bridgeData,
        CBridgeData calldata _cBridgeData
    ) private {
        if (LibAsset.isNativeAsset(_bridgeData.sendingAssetId)) {
            cBridge.sendNative{ value: _bridgeData.minAmount }(
                _bridgeData.receiver,
                _bridgeData.minAmount,
                uint64(_bridgeData.destinationChainId),
                _cBridgeData.nonce,
                _cBridgeData.maxSlippage
            );
        } else {
            // Give CBridge approval to bridge tokens
            LibAsset.maxApproveERC20(
                IERC20(_bridgeData.sendingAssetId),
                address(cBridge),
                _bridgeData.minAmount
            );
            // solhint-disable check-send-result
            cBridge.send(
                _bridgeData.receiver,
                _bridgeData.sendingAssetId,
                _bridgeData.minAmount,
                uint64(_bridgeData.destinationChainId),
                _cBridgeData.nonce,
                _cBridgeData.maxSlippage
            );
        }

        emit LiFiTransferStarted(_bridgeData);
    }
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import { ICBridge } from "../Interfaces/ICBridge.sol";
import { CBridgeFacet } from "./CBridgeFacet.sol";
import { ILiFi } from "../Interfaces/ILiFi.sol";
import { ERC20, SafeTransferLib } from "../../lib/solmate/src/utils/SafeTransferLib.sol";
import { LibAsset, IERC20 } from "../Libraries/LibAsset.sol";
import { LibDiamond } from "../Libraries/LibDiamond.sol";
import { ContractCallNotAllowed, ExternalCallFailed } from "../Errors/GenericErrors.sol";
import { LibUtil } from "../Libraries/LibUtil.sol";
import { TransferrableOwnership } from "../Helpers/TransferrableOwnership.sol";

/// @title CBridge Facet Packed
/// @author LI.FI (https://li.fi)
/// @notice Provides functionality for bridging through CBridge
/// @custom:version 1.0.3
contract CBridgeFacetPacked is ILiFi, TransferrableOwnership {
    using SafeTransferLib for ERC20;

    /// Storage ///

    /// @notice The contract address of the cbridge on the source chain.
    ICBridge private immutable cBridge;

    /// Events ///

    event LiFiCBridgeTransfer(bytes8 _transactionId);

    event CBridgeRefund(
        address indexed _assetAddress,
        address indexed _to,
        uint256 amount
    );

    /// Constructor ///

    /// @notice Initialize the contract.
    /// @param _cBridge The contract address of the cbridge on the source chain.
    constructor(
        ICBridge _cBridge,
        address _owner
    ) TransferrableOwnership(_owner) {
        cBridge = _cBridge;
    }

    /// External Methods ///

    /// @dev Only meant to be called outside of the context of the diamond
    /// @notice Sets approval for the CBridge Router to spend the specified token
    /// @param tokensToApprove The tokens to approve to the CBridge Router
    function setApprovalForBridge(
        address[] calldata tokensToApprove
    ) external onlyOwner {
        for (uint256 i; i < tokensToApprove.length; i++) {
            // Give CBridge approval to bridge tokens
            LibAsset.maxApproveERC20(
                IERC20(tokensToApprove[i]),
                address(cBridge),
                type(uint256).max
            );
        }
    }

    // This is needed to receive native asset if a refund asset is a native asset
    receive() external payable {}

    /// @notice Triggers a cBridge refund with calldata produced by cBridge API
    /// @param _callTo The address to execute the calldata on
    /// @param _callData The data to execute
    /// @param _assetAddress Asset to be withdrawn
    /// @param _to Address to withdraw to
    /// @param _amount Amount of asset to withdraw
    function triggerRefund(
        address payable _callTo,
        bytes calldata _callData,
        address _assetAddress,
        address _to,
        uint256 _amount
    ) external onlyOwner {
        // make sure that callTo address is either of the cBridge addresses
        if (address(cBridge) != _callTo) {
            revert ContractCallNotAllowed();
        }

        // call contract
        bool success;
        (success, ) = _callTo.call(_callData);
        if (!success) {
            revert ExternalCallFailed();
        }

        // forward funds to _to address and emit event
        address sendTo = (LibUtil.isZeroAddress(_to)) ? msg.sender : _to;
        LibAsset.transferAsset(_assetAddress, payable(sendTo), _amount);
        emit CBridgeRefund(_assetAddress, sendTo, _amount);
    }

    /// @notice Bridges Native tokens via cBridge (packed)
    /// No params, all data will be extracted from manually encoded callData
    function startBridgeTokensViaCBridgeNativePacked() external payable {
        cBridge.sendNative{ value: msg.value }(
            address(bytes20(msg.data[12:32])), // receiver
            msg.value, // amount
            uint64(uint32(bytes4(msg.data[32:36]))), // destinationChainId
            uint64(uint32(bytes4(msg.data[36:40]))), // nonce
            uint32(bytes4(msg.data[40:44])) // maxSlippage
        );

        emit LiFiCBridgeTransfer(bytes8(msg.data[4:12])); // transactionId
    }

    /// @notice Bridges native tokens via cBridge
    /// @param transactionId Custom transaction ID for tracking
    /// @param receiver Receiving wallet address
    /// @param destinationChainId Receiving chain
    /// @param nonce A number input to guarantee uniqueness of transferId.
    /// @param maxSlippage Destination swap minimal accepted amount
    function startBridgeTokensViaCBridgeNativeMin(
        bytes32 transactionId,
        address receiver,
        uint64 destinationChainId,
        uint64 nonce,
        uint32 maxSlippage
    ) external payable {
        cBridge.sendNative{ value: msg.value }(
            receiver,
            msg.value,
            destinationChainId,
            nonce,
            maxSlippage
        );

        emit LiFiCBridgeTransfer(bytes8(transactionId));
    }

    /// @notice Bridges ERC20 tokens via cBridge
    /// No params, all data will be extracted from manually encoded callData
    function startBridgeTokensViaCBridgeERC20Packed() external {
        address sendingAssetId = address(bytes20(msg.data[36:56]));
        uint256 amount = uint256(uint128(bytes16(msg.data[56:72])));

        // Deposit assets
        ERC20(sendingAssetId).safeTransferFrom(
            msg.sender,
            address(this),
            amount
        );

        // Bridge assets
        // solhint-disable-next-line check-send-result
        cBridge.send(
            address(bytes20(msg.data[12:32])), // receiver
            sendingAssetId, // sendingAssetId
            amount, // amount
            uint64(uint32(bytes4(msg.data[32:36]))), // destinationChainId
            uint64(uint32(bytes4(msg.data[72:76]))), // nonce
            uint32(bytes4(msg.data[76:80])) // maxSlippage
        );

        emit LiFiCBridgeTransfer(bytes8(msg.data[4:12]));
    }

    /// @notice Bridges ERC20 tokens via cBridge
    /// @param transactionId Custom transaction ID for tracking
    /// @param receiver Receiving wallet address
    /// @param destinationChainId Receiving chain
    /// @param sendingAssetId Address of the source asset to bridge
    /// @param amount Amount of the source asset to bridge
    /// @param nonce A number input to guarantee uniqueness of transferId
    /// @param maxSlippage Destination swap minimal accepted amount
    function startBridgeTokensViaCBridgeERC20Min(
        bytes32 transactionId,
        address receiver,
        uint64 destinationChainId,
        address sendingAssetId,
        uint256 amount,
        uint64 nonce,
        uint32 maxSlippage
    ) external {
        // Deposit assets
        ERC20(sendingAssetId).safeTransferFrom(
            msg.sender,
            address(this),
            amount
        );

        // Bridge assets
        // solhint-disable-next-line check-send-result
        cBridge.send(
            receiver,
            sendingAssetId,
            amount,
            destinationChainId,
            nonce,
            maxSlippage
        );

        emit LiFiCBridgeTransfer(bytes8(transactionId));
    }

    /// Encoder/Decoders ///

    /// @notice Encodes calldata for startBridgeTokensViaCBridgeNativePacked
    /// @param transactionId Custom transaction ID for tracking
    /// @param receiver Receiving wallet address
    /// @param destinationChainId Receiving chain
    /// @param nonce A number input to guarantee uniqueness of transferId.
    /// @param maxSlippage Destination swap minimal accepted amount
    function encode_startBridgeTokensViaCBridgeNativePacked(
        bytes32 transactionId,
        address receiver,
        uint64 destinationChainId,
        uint64 nonce,
        uint32 maxSlippage
    ) external pure returns (bytes memory) {
        require(
            destinationChainId <= type(uint32).max,
            "destinationChainId value passed too big to fit in uint32"
        );
        require(
            nonce <= type(uint32).max,
            "nonce value passed too big to fit in uint32"
        );

        return
            bytes.concat(
                CBridgeFacetPacked
                    .startBridgeTokensViaCBridgeNativePacked
                    .selector,
                bytes8(transactionId),
                bytes20(receiver),
                bytes4(uint32(destinationChainId)),
                bytes4(uint32(nonce)),
                bytes4(maxSlippage)
            );
    }

    /// @notice Decodes calldata for startBridgeTokensViaCBridgeNativePacked
    /// @param _data the calldata to decode
    function decode_startBridgeTokensViaCBridgeNativePacked(
        bytes calldata _data
    )
        external
        pure
        returns (BridgeData memory, CBridgeFacet.CBridgeData memory)
    {
        require(
            _data.length >= 44,
            "data passed in is not the correct length"
        );

        BridgeData memory bridgeData;
        CBridgeFacet.CBridgeData memory cBridgeData;

        bridgeData.transactionId = bytes32(bytes8(_data[4:12]));
        bridgeData.receiver = address(bytes20(_data[12:32]));
        bridgeData.destinationChainId = uint64(uint32(bytes4(_data[32:36])));
        cBridgeData.nonce = uint64(uint32(bytes4(_data[36:40])));
        cBridgeData.maxSlippage = uint32(bytes4(_data[40:44]));

        return (bridgeData, cBridgeData);
    }

    /// @notice Encodes calldata for startBridgeTokensViaCBridgeERC20Packed
    /// @param transactionId Custom transaction ID for tracking
    /// @param receiver Receiving wallet address
    /// @param destinationChainId Receiving chain
    /// @param sendingAssetId Address of the source asset to bridge
    /// @param minAmount Amount of the source asset to bridge
    /// @param nonce A number input to guarantee uniqueness of transferId
    /// @param maxSlippage Destination swap minimal accepted amount
    function encode_startBridgeTokensViaCBridgeERC20Packed(
        bytes32 transactionId,
        address receiver,
        uint64 destinationChainId,
        address sendingAssetId,
        uint256 minAmount,
        uint64 nonce,
        uint32 maxSlippage
    ) external pure returns (bytes memory) {
        require(
            destinationChainId <= type(uint32).max,
            "destinationChainId value passed too big to fit in uint32"
        );
        require(
            minAmount <= type(uint128).max,
            "amount value passed too big to fit in uint128"
        );
        require(
            nonce <= type(uint32).max,
            "nonce value passed too big to fit in uint32"
        );

        return
            bytes.concat(
                CBridgeFacetPacked
                    .startBridgeTokensViaCBridgeERC20Packed
                    .selector,
                bytes8(transactionId),
                bytes20(receiver),
                bytes4(uint32(destinationChainId)),
                bytes20(sendingAssetId),
                bytes16(uint128(minAmount)),
                bytes4(uint32(nonce)),
                bytes4(maxSlippage)
            );
    }

    function decode_startBridgeTokensViaCBridgeERC20Packed(
        bytes calldata _data
    )
        external
        pure
        returns (BridgeData memory, CBridgeFacet.CBridgeData memory)
    {
        require(_data.length >= 80, "data passed is not the correct length");

        BridgeData memory bridgeData;
        CBridgeFacet.CBridgeData memory cBridgeData;

        bridgeData.transactionId = bytes32(bytes8(_data[4:12]));
        bridgeData.receiver = address(bytes20(_data[12:32]));
        bridgeData.destinationChainId = uint64(uint32(bytes4(_data[32:36])));
        bridgeData.sendingAssetId = address(bytes20(_data[36:56]));
        bridgeData.minAmount = uint256(uint128(bytes16(_data[56:72])));
        cBridgeData.nonce = uint64(uint32(bytes4(_data[72:76])));
        cBridgeData.maxSlippage = uint32(bytes4(_data[76:80]));

        return (bridgeData, cBridgeData);
    }
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import { ILiFi } from "../Interfaces/ILiFi.sol";
import { ICircleBridgeProxy } from "../Interfaces/ICircleBridgeProxy.sol";
import { LibAsset, IERC20 } from "../Libraries/LibAsset.sol";
import { ReentrancyGuard } from "../Helpers/ReentrancyGuard.sol";
import { SwapperV2, LibSwap } from "../Helpers/SwapperV2.sol";
import { Validatable } from "../Helpers/Validatable.sol";

/// @title CelerCircleBridge Facet
/// @author LI.FI (https://li.fi)
/// @notice Provides functionality for bridging through CelerCircleBridge
/// @custom:version 1.0.1
contract CelerCircleBridgeFacet is
    ILiFi,
    ReentrancyGuard,
    SwapperV2,
    Validatable
{
    /// Storage ///

    /// @notice The address of the CircleBridgeProxy on the current chain.
    ICircleBridgeProxy private immutable circleBridgeProxy;

    /// @notice The USDC address on the current chain.
    address private immutable usdc;

    /// Constructor ///

    /// @notice Initialize the contract.
    /// @param _circleBridgeProxy The address of the CircleBridgeProxy on the current chain.
    /// @param _usdc The address of USDC on the current chain.
    constructor(ICircleBridgeProxy _circleBridgeProxy, address _usdc) {
        circleBridgeProxy = _circleBridgeProxy;
        usdc = _usdc;
    }

    /// External Methods ///

    /// @notice Bridges tokens via CelerCircleBridge
    /// @param _bridgeData Data containing core information for bridging
    function startBridgeTokensViaCelerCircleBridge(
        BridgeData calldata _bridgeData
    )
        external
        nonReentrant
        doesNotContainSourceSwaps(_bridgeData)
        doesNotContainDestinationCalls(_bridgeData)
        validateBridgeData(_bridgeData)
        onlyAllowSourceToken(_bridgeData, usdc)
    {
        LibAsset.depositAsset(usdc, _bridgeData.minAmount);
        _startBridge(_bridgeData);
    }

    /// @notice Performs a swap before bridging via CelerCircleBridge
    /// @param _bridgeData The core information needed for bridging
    /// @param _swapData An array of swap related data for performing swaps before bridging
    function swapAndStartBridgeTokensViaCelerCircleBridge(
        BridgeData memory _bridgeData,
        LibSwap.SwapData[] calldata _swapData
    )
        external
        payable
        nonReentrant
        refundExcessNative(payable(msg.sender))
        containsSourceSwaps(_bridgeData)
        doesNotContainDestinationCalls(_bridgeData)
        validateBridgeData(_bridgeData)
        onlyAllowSourceToken(_bridgeData, usdc)
    {
        _bridgeData.minAmount = _depositAndSwap(
            _bridgeData.transactionId,
            _bridgeData.minAmount,
            _swapData,
            payable(msg.sender)
        );
        _startBridge(_bridgeData);
    }

    /// Private Methods ///

    /// @dev Contains the business logic for the bridge via CelerCircleBridge
    /// @param _bridgeData The core information needed for bridging
    function _startBridge(BridgeData memory _bridgeData) private {
        require(
            _bridgeData.destinationChainId <= type(uint64).max,
            "_bridgeData.destinationChainId passed is too big to fit in uint64"
        );

        // give max approval for token to CelerCircleBridge bridge, if not already
        LibAsset.maxApproveERC20(
            IERC20(usdc),
            address(circleBridgeProxy),
            _bridgeData.minAmount
        );

        // initiate bridge transaction
        circleBridgeProxy.depositForBurn(
            _bridgeData.minAmount,
            uint64(_bridgeData.destinationChainId),
            bytes32(uint256(uint160(_bridgeData.receiver))),
            usdc
        );

        emit LiFiTransferStarted(_bridgeData);
    }
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import { CelerIMFacetBase, IMessageBus, MsgDataTypes, IERC20, CelerIM } from "../Helpers/CelerIMFacetBase.sol";

/// @title CelerIMFacetImmutable
/// @author LI.FI (https://li.fi)
/// @notice Provides functionality for bridging tokens and data through CBridge
/// @notice This contract is exclusively used for immutable diamond contracts
/// @custom:version 2.0.0
contract CelerIMFacetImmutable is CelerIMFacetBase {
    /// Constructor ///

    /// @notice Initialize the contract.
    /// @param _messageBus The contract address of the cBridge Message Bus
    /// @param _relayerOwner The address that will become the owner of the RelayerCelerIM contract
    /// @param _diamondAddress The address of the diamond contract that will be connected with the RelayerCelerIM
    /// @param _cfUSDC The contract address of the Celer Flow USDC
    constructor(
        IMessageBus _messageBus,
        address _relayerOwner,
        address _diamondAddress,
        address _cfUSDC
    ) CelerIMFacetBase(_messageBus, _relayerOwner, _diamondAddress, _cfUSDC) {}
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import { CelerIMFacetBase, IMessageBus, MsgDataTypes, IERC20, CelerIM } from "../Helpers/CelerIMFacetBase.sol";

/// @title CelerIMFacetMutable
/// @author LI.FI (https://li.fi)
/// @notice Provides functionality for bridging tokens and data through CBridge
/// @notice This contract is exclusively used for mutable diamond contracts
/// @custom:version 2.0.0
contract CelerIMFacetMutable is CelerIMFacetBase {
    /// Constructor ///

    /// @notice Initialize the contract.
    /// @param _messageBus The contract address of the cBridge Message Bus
    /// @param _relayerOwner The address that will become the owner of the RelayerCelerIM contract
    /// @param _diamondAddress The address of the diamond contract that will be connected with the RelayerCelerIM
    /// @param _cfUSDC The contract address of the Celer Flow USDC
    constructor(
        IMessageBus _messageBus,
        address _relayerOwner,
        address _diamondAddress,
        address _cfUSDC
    ) CelerIMFacetBase(_messageBus, _relayerOwner, _diamondAddress, _cfUSDC) {}
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import { ILiFi } from "../Interfaces/ILiFi.sol";
import { ITokenMessenger } from "../Interfaces/ITokenMessenger.sol";
import { LibAsset, IERC20 } from "../Libraries/LibAsset.sol";
import { ReentrancyGuard } from "../Helpers/ReentrancyGuard.sol";
import { SwapperV2, LibSwap } from "../Helpers/SwapperV2.sol";
import { Validatable } from "../Helpers/Validatable.sol";

/// @title CircleBridge Facet
/// @author LI.FI (https://li.fi)
/// @notice Provides functionality for bridging through CircleBridge
/// @custom:version 1.0.0
contract CircleBridgeFacet is ILiFi, ReentrancyGuard, SwapperV2, Validatable {
    /// Storage ///

    /// @notice The address of the TokenMessenger on the source chain.
    ITokenMessenger private immutable tokenMessenger;

    /// @notice The USDC address on the source chain.
    address private immutable usdc;

    /// @param dstDomain The CircleBridge-specific domainId of the destination chain
    struct CircleBridgeData {
        uint32 dstDomain;
    }

    /// Constructor ///

    /// @notice Initialize the contract.
    /// @param _tokenMessenger The address of the TokenMessenger on the source chain.
    /// @param _usdc The address of USDC on the source chain.
    constructor(ITokenMessenger _tokenMessenger, address _usdc) {
        tokenMessenger = _tokenMessenger;
        usdc = _usdc;
    }

    /// External Methods ///

    /// @notice Bridges tokens via CircleBridge
    /// @param _bridgeData Data containing core information for bridging
    /// @param _circleBridgeData Data specific to bridge
    function startBridgeTokensViaCircleBridge(
        BridgeData calldata _bridgeData,
        CircleBridgeData calldata _circleBridgeData
    )
        external
        nonReentrant
        doesNotContainSourceSwaps(_bridgeData)
        doesNotContainDestinationCalls(_bridgeData)
        validateBridgeData(_bridgeData)
        onlyAllowSourceToken(_bridgeData, usdc)
    {
        LibAsset.depositAsset(usdc, _bridgeData.minAmount);
        _startBridge(_bridgeData, _circleBridgeData);
    }

    /// @notice Performs a swap before bridging via CircleBridge
    /// @param _bridgeData The core information needed for bridging
    /// @param _swapData An array of swap related data for performing swaps before bridging
    /// @param _circleBridgeData Data specific to CircleBridge
    function swapAndStartBridgeTokensViaCircleBridge(
        BridgeData memory _bridgeData,
        LibSwap.SwapData[] calldata _swapData,
        CircleBridgeData calldata _circleBridgeData
    )
        external
        payable
        nonReentrant
        refundExcessNative(payable(msg.sender))
        containsSourceSwaps(_bridgeData)
        doesNotContainDestinationCalls(_bridgeData)
        validateBridgeData(_bridgeData)
        onlyAllowSourceToken(_bridgeData, usdc)
    {
        _bridgeData.minAmount = _depositAndSwap(
            _bridgeData.transactionId,
            _bridgeData.minAmount,
            _swapData,
            payable(msg.sender)
        );
        _startBridge(_bridgeData, _circleBridgeData);
    }

    /// Private Methods ///

    /// @dev Contains the business logic for the bridge via CircleBridge
    /// @param _bridgeData The core information needed for bridging
    /// @param _circleBridgeData Data specific to CircleBridge
    function _startBridge(
        BridgeData memory _bridgeData,
        CircleBridgeData calldata _circleBridgeData
    ) private {
        // give max approval for token to CircleBridge bridge, if not already
        LibAsset.maxApproveERC20(
            IERC20(usdc),
            address(tokenMessenger),
            _bridgeData.minAmount
        );

        // initiate bridge transaction
        tokenMessenger.depositForBurn(
            _bridgeData.minAmount,
            _circleBridgeData.dstDomain,
            bytes32(uint256(uint160(_bridgeData.receiver))),
            usdc
        );

        emit LiFiTransferStarted(_bridgeData);
    }
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import { ILiFi } from "../Interfaces/ILiFi.sol";
import { IDeBridgeGate } from "../Interfaces/IDeBridgeGate.sol";
import { LibAsset, IERC20 } from "../Libraries/LibAsset.sol";
import { ReentrancyGuard } from "../Helpers/ReentrancyGuard.sol";
import { SwapperV2, LibSwap } from "../Helpers/SwapperV2.sol";
import { InformationMismatch, InvalidAmount } from "../Errors/GenericErrors.sol";
import { Validatable } from "../Helpers/Validatable.sol";

/// @title DeBridge Facet
/// @author LI.FI (https://li.fi)
/// @notice Provides functionality for bridging through DeBridge Protocol
/// @custom:version 1.0.0
contract DeBridgeFacet is ILiFi, ReentrancyGuard, SwapperV2, Validatable {
    /// Storage ///

    /// @notice The contract address of the DeBridge Gate on the source chain.
    IDeBridgeGate private immutable deBridgeGate;

    /// Types ///

    /// @param executionFee Fee paid to the transaction executor.
    /// @param flags Flags set specific flows for call data execution.
    /// @param fallbackAddress Receiver of the tokens if the call fails.
    /// @param data Message/Call data to be passed to the receiver
    ///             on the destination chain during the external call execution.
    struct SubmissionAutoParamsTo {
        uint256 executionFee;
        uint256 flags;
        bytes fallbackAddress;
        bytes data;
    }

    /// @param nativeFee Native fee for the bridging when useAssetFee is false.
    /// @param useAssetFee Use assets fee for pay protocol fix (work only for specials token)
    /// @param referralCode Referral code.
    /// @param autoParams Structure that enables passing arbitrary messages and call data.
    struct DeBridgeData {
        uint256 nativeFee;
        bool useAssetFee;
        uint32 referralCode;
        SubmissionAutoParamsTo autoParams;
    }

    /// Constructor ///

    /// @notice Initialize the contract.
    /// @param _deBridgeGate The contract address of the DeBridgeGate on the source chain.
    constructor(IDeBridgeGate _deBridgeGate) {
        deBridgeGate = _deBridgeGate;
    }

    /// External Methods ///

    /// @notice Bridges tokens via DeBridge
    /// @param _bridgeData the core information needed for bridging
    /// @param _deBridgeData data specific to DeBridge
    function startBridgeTokensViaDeBridge(
        ILiFi.BridgeData calldata _bridgeData,
        DeBridgeData calldata _deBridgeData
    )
        external
        payable
        nonReentrant
        refundExcessNative(payable(msg.sender))
        validateBridgeData(_bridgeData)
        doesNotContainSourceSwaps(_bridgeData)
    {
        validateDestinationCallFlag(_bridgeData, _deBridgeData);

        LibAsset.depositAsset(
            _bridgeData.sendingAssetId,
            _bridgeData.minAmount
        );
        _startBridge(_bridgeData, _deBridgeData);
    }

    /// @notice Performs a swap before bridging via DeBridge
    /// @param _bridgeData the core information needed for bridging
    /// @param _swapData an array of swap related data for performing swaps before bridging
    /// @param _deBridgeData data specific to DeBridge
    function swapAndStartBridgeTokensViaDeBridge(
        ILiFi.BridgeData memory _bridgeData,
        LibSwap.SwapData[] calldata _swapData,
        DeBridgeData calldata _deBridgeData
    )
        external
        payable
        nonReentrant
        refundExcessNative(payable(msg.sender))
        containsSourceSwaps(_bridgeData)
        validateBridgeData(_bridgeData)
    {
        validateDestinationCallFlag(_bridgeData, _deBridgeData);

        _bridgeData.minAmount = _depositAndSwap(
            _bridgeData.transactionId,
            _bridgeData.minAmount,
            _swapData,
            payable(msg.sender),
            _deBridgeData.nativeFee
        );

        _startBridge(_bridgeData, _deBridgeData);
    }

    /// Internal Methods ///

    /// @dev Contains the business logic for the bridge via DeBridge
    /// @param _bridgeData the core information needed for bridging
    /// @param _deBridgeData data specific to DeBridge
    function _startBridge(
        ILiFi.BridgeData memory _bridgeData,
        DeBridgeData calldata _deBridgeData
    ) internal {
        IDeBridgeGate.ChainSupportInfo memory config = deBridgeGate
            .getChainToConfig(_bridgeData.destinationChainId);
        uint256 nativeFee = config.fixedNativeFee == 0
            ? deBridgeGate.globalFixedNativeFee()
            : config.fixedNativeFee;

        if (_deBridgeData.nativeFee != nativeFee) {
            revert InvalidAmount();
        }

        bool isNative = LibAsset.isNativeAsset(_bridgeData.sendingAssetId);
        uint256 nativeAssetAmount = _deBridgeData.nativeFee;

        if (isNative) {
            nativeAssetAmount += _bridgeData.minAmount;
        } else {
            LibAsset.maxApproveERC20(
                IERC20(_bridgeData.sendingAssetId),
                address(deBridgeGate),
                _bridgeData.minAmount
            );
        }

        // solhint-disable-next-line check-send-result
        deBridgeGate.send{ value: nativeAssetAmount }(
            _bridgeData.sendingAssetId,
            _bridgeData.minAmount,
            _bridgeData.destinationChainId,
            abi.encodePacked(_bridgeData.receiver),
            "",
            _deBridgeData.useAssetFee,
            _deBridgeData.referralCode,
            abi.encode(_deBridgeData.autoParams)
        );

        emit LiFiTransferStarted(_bridgeData);
    }

    function validateDestinationCallFlag(
        ILiFi.BridgeData memory _bridgeData,
        DeBridgeData calldata _deBridgeData
    ) private pure {
        if (
            (_deBridgeData.autoParams.data.length > 0) !=
            _bridgeData.hasDestinationCall
        ) {
            revert InformationMismatch();
        }
    }
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import { LibDiamond } from "../Libraries/LibDiamond.sol";
import { LibAccess } from "../Libraries/LibAccess.sol";
import { LibAllowList } from "../Libraries/LibAllowList.sol";
import { CannotAuthoriseSelf } from "../Errors/GenericErrors.sol";

/// @title Dex Manager Facet
/// @author LI.FI (https://li.fi)
/// @notice Facet contract for managing approved DEXs to be used in swaps.
/// @custom:version 1.0.0
contract DexManagerFacet {
    /// Events ///

    event DexAdded(address indexed dexAddress);
    event DexRemoved(address indexed dexAddress);
    event FunctionSignatureApprovalChanged(
        bytes4 indexed functionSignature,
        bool indexed approved
    );

    /// External Methods ///

    /// @notice Register the address of a DEX contract to be approved for swapping.
    /// @param _dex The address of the DEX contract to be approved.
    function addDex(address _dex) external {
        if (msg.sender != LibDiamond.contractOwner()) {
            LibAccess.enforceAccessControl();
        }

        if (_dex == address(this)) {
            revert CannotAuthoriseSelf();
        }

        LibAllowList.addAllowedContract(_dex);

        emit DexAdded(_dex);
    }

    /// @notice Batch register the address of DEX contracts to be approved for swapping.
    /// @param _dexs The addresses of the DEX contracts to be approved.
    function batchAddDex(address[] calldata _dexs) external {
        if (msg.sender != LibDiamond.contractOwner()) {
            LibAccess.enforceAccessControl();
        }
        uint256 length = _dexs.length;

        for (uint256 i = 0; i < length; ) {
            address dex = _dexs[i];
            if (dex == address(this)) {
                revert CannotAuthoriseSelf();
            }
            if (LibAllowList.contractIsAllowed(dex)) continue;
            LibAllowList.addAllowedContract(dex);
            emit DexAdded(dex);
            unchecked {
                ++i;
            }
        }
    }

    /// @notice Unregister the address of a DEX contract approved for swapping.
    /// @param _dex The address of the DEX contract to be unregistered.
    function removeDex(address _dex) external {
        if (msg.sender != LibDiamond.contractOwner()) {
            LibAccess.enforceAccessControl();
        }
        LibAllowList.removeAllowedContract(_dex);
        emit DexRemoved(_dex);
    }

    /// @notice Batch unregister the addresses of DEX contracts approved for swapping.
    /// @param _dexs The addresses of the DEX contracts to be unregistered.
    function batchRemoveDex(address[] calldata _dexs) external {
        if (msg.sender != LibDiamond.contractOwner()) {
            LibAccess.enforceAccessControl();
        }
        uint256 length = _dexs.length;
        for (uint256 i = 0; i < length; ) {
            LibAllowList.removeAllowedContract(_dexs[i]);
            emit DexRemoved(_dexs[i]);
            unchecked {
                ++i;
            }
        }
    }

    /// @notice Adds/removes a specific function signature to/from the allowlist
    /// @param _signature the function signature to allow/disallow
    /// @param _approval whether the function signature should be allowed
    function setFunctionApprovalBySignature(
        bytes4 _signature,
        bool _approval
    ) external {
        if (msg.sender != LibDiamond.contractOwner()) {
            LibAccess.enforceAccessControl();
        }

        if (_approval) {
            LibAllowList.addAllowedSelector(_signature);
        } else {
            LibAllowList.removeAllowedSelector(_signature);
        }

        emit FunctionSignatureApprovalChanged(_signature, _approval);
    }

    /// @notice Batch Adds/removes a specific function signature to/from the allowlist
    /// @param _signatures the function signatures to allow/disallow
    /// @param _approval whether the function signatures should be allowed
    function batchSetFunctionApprovalBySignature(
        bytes4[] calldata _signatures,
        bool _approval
    ) external {
        if (msg.sender != LibDiamond.contractOwner()) {
            LibAccess.enforceAccessControl();
        }
        uint256 length = _signatures.length;
        for (uint256 i = 0; i < length; ) {
            bytes4 _signature = _signatures[i];
            if (_approval) {
                LibAllowList.addAllowedSelector(_signature);
            } else {
                LibAllowList.removeAllowedSelector(_signature);
            }
            emit FunctionSignatureApprovalChanged(_signature, _approval);
            unchecked {
                ++i;
            }
        }
    }

    /// @notice Returns whether a function signature is approved
    /// @param _signature the function signature to query
    /// @return approved Approved or not
    function isFunctionApproved(
        bytes4 _signature
    ) public view returns (bool approved) {
        return LibAllowList.selectorIsAllowed(_signature);
    }

    /// @notice Returns a list of all approved DEX addresses.
    /// @return addresses List of approved DEX addresses
    function approvedDexs()
        external
        view
        returns (address[] memory addresses)
    {
        return LibAllowList.getAllowedContracts();
    }
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import { IDiamondCut } from "../Interfaces/IDiamondCut.sol";
import { LibDiamond } from "../Libraries/LibDiamond.sol";

/// @title Diamond Cut Facet
/// @author LI.FI (https://li.fi)
/// @notice Core EIP-2535 Facet for upgrading Diamond Proxies.
/// @custom:version 1.0.0
contract DiamondCutFacet is IDiamondCut {
    /// @notice Add/replace/remove any number of functions and optionally execute
    ///         a function with delegatecall
    /// @param _diamondCut Contains the facet addresses and function selectors
    /// @param _init The address of the contract or facet to execute _calldata
    /// @param _calldata A function call, including function selector and arguments
    ///                  _calldata is executed with delegatecall on _init
    function diamondCut(
        FacetCut[] calldata _diamondCut,
        address _init,
        bytes calldata _calldata
    ) external override {
        LibDiamond.enforceIsContractOwner();
        LibDiamond.diamondCut(_diamondCut, _init, _calldata);
    }
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import { LibDiamond } from "../Libraries/LibDiamond.sol";
import { IDiamondLoupe } from "../Interfaces/IDiamondLoupe.sol";
import { IERC165 } from "../Interfaces/IERC165.sol";

/// @title Diamond Loupe Facet
/// @author LI.FI (https://li.fi)
/// @notice Core EIP-2535 Facet for inspecting Diamond Proxies.
/// @custom:version 1.0.0
contract DiamondLoupeFacet is IDiamondLoupe, IERC165 {
    // Diamond Loupe Functions
    ////////////////////////////////////////////////////////////////////
    /// These functions are expected to be called frequently by tools.
    //
    // struct Facet {
    //     address facetAddress;
    //     bytes4[] functionSelectors;
    // }

    /// @notice Gets all facets and their selectors.
    /// @return facets_ Facet
    function facets() external view override returns (Facet[] memory facets_) {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        uint256 numFacets = ds.facetAddresses.length;
        facets_ = new Facet[](numFacets);
        for (uint256 i = 0; i < numFacets; ) {
            address facetAddress_ = ds.facetAddresses[i];
            facets_[i].facetAddress = facetAddress_;
            facets_[i].functionSelectors = ds
                .facetFunctionSelectors[facetAddress_]
                .functionSelectors;
            unchecked {
                ++i;
            }
        }
    }

    /// @notice Gets all the function selectors provided by a facet.
    /// @param _facet The facet address.
    /// @return facetFunctionSelectors_
    function facetFunctionSelectors(
        address _facet
    )
        external
        view
        override
        returns (bytes4[] memory facetFunctionSelectors_)
    {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        facetFunctionSelectors_ = ds
            .facetFunctionSelectors[_facet]
            .functionSelectors;
    }

    /// @notice Get all the facet addresses used by a diamond.
    /// @return facetAddresses_
    function facetAddresses()
        external
        view
        override
        returns (address[] memory facetAddresses_)
    {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        facetAddresses_ = ds.facetAddresses;
    }

    /// @notice Gets the facet that supports the given selector.
    /// @dev If facet is not found return address(0).
    /// @param _functionSelector The function selector.
    /// @return facetAddress_ The facet address.
    function facetAddress(
        bytes4 _functionSelector
    ) external view override returns (address facetAddress_) {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        facetAddress_ = ds
            .selectorToFacetAndPosition[_functionSelector]
            .facetAddress;
    }

    // This implements ERC-165.
    function supportsInterface(
        bytes4 _interfaceId
    ) external view override returns (bool) {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        return ds.supportedInterfaces[_interfaceId];
    }
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import { ILiFi } from "../Interfaces/ILiFi.sol";
import { LibAsset } from "../Libraries/LibAsset.sol";
import { ReentrancyGuard } from "../Helpers/ReentrancyGuard.sol";
import { SwapperV2, LibSwap } from "../Helpers/SwapperV2.sol";
import { Validatable } from "../Helpers/Validatable.sol";
import { LibUtil } from "../Libraries/LibUtil.sol";
import { InvalidReceiver } from "../Errors/GenericErrors.sol";

/// @title Generic Swap Facet
/// @author LI.FI (https://li.fi)
/// @notice Provides functionality for swapping through ANY APPROVED DEX
/// @dev Uses calldata to execute APPROVED arbitrary methods on DEXs
/// @custom:version 1.0.0
contract GenericSwapFacet is ILiFi, ReentrancyGuard, SwapperV2, Validatable {
    /// External Methods ///

    /// @notice Performs multiple swaps in one transaction
    /// @param _transactionId the transaction id associated with the operation
    /// @param _integrator the name of the integrator
    /// @param _referrer the address of the referrer
    /// @param _receiver the address to receive the swapped tokens into (also excess tokens)
    /// @param _minAmount the minimum amount of the final asset to receive
    /// @param _swapData an object containing swap related data to perform swaps before bridging
    function swapTokensGeneric(
        bytes32 _transactionId,
        string calldata _integrator,
        string calldata _referrer,
        address payable _receiver,
        uint256 _minAmount,
        LibSwap.SwapData[] calldata _swapData
    ) external payable nonReentrant refundExcessNative(_receiver) {
        if (LibUtil.isZeroAddress(_receiver)) {
            revert InvalidReceiver();
        }

        uint256 postSwapBalance = _depositAndSwap(
            _transactionId,
            _minAmount,
            _swapData,
            _receiver
        );
        address receivingAssetId = _swapData[_swapData.length - 1]
            .receivingAssetId;
        LibAsset.transferAsset(receivingAssetId, _receiver, postSwapBalance);

        emit LiFiGenericSwapCompleted(
            _transactionId,
            _integrator,
            _referrer,
            _receiver,
            _swapData[0].sendingAssetId,
            receivingAssetId,
            _swapData[0].fromAmount,
            postSwapBalance
        );
    }
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import { ILiFi } from "../Interfaces/ILiFi.sol";
import { IXDaiBridge } from "../Interfaces/IXDaiBridge.sol";
import { LibAsset, IERC20 } from "../Libraries/LibAsset.sol";
import { ReentrancyGuard } from "../Helpers/ReentrancyGuard.sol";
import { InvalidSendingToken, NoSwapDataProvided } from "../Errors/GenericErrors.sol";
import { SwapperV2, LibSwap } from "../Helpers/SwapperV2.sol";
import { Validatable } from "../Helpers/Validatable.sol";

/// @title Gnosis Bridge Facet
/// @author LI.FI (https://li.fi)
/// @notice Provides functionality for bridging through XDaiBridge
/// @custom:version 1.0.0
contract GnosisBridgeFacet is ILiFi, ReentrancyGuard, SwapperV2, Validatable {
    /// Storage ///

    /// @notice The DAI address on the source chain.
    address private constant DAI = 0x6B175474E89094C44Da98b954EedeAC495271d0F;

    /// @notice The chain id of Gnosis.
    uint64 private constant GNOSIS_CHAIN_ID = 100;

    /// @notice The contract address of the xdai bridge on the source chain.
    IXDaiBridge private immutable xDaiBridge;

    /// Constructor ///

    /// @notice Initialize the contract.
    /// @param _xDaiBridge The contract address of the xdai bridge on the source chain.
    constructor(IXDaiBridge _xDaiBridge) {
        xDaiBridge = _xDaiBridge;
    }

    /// External Methods ///

    /// @notice Bridges tokens via XDaiBridge
    /// @param _bridgeData the core information needed for bridging
    function startBridgeTokensViaXDaiBridge(
        ILiFi.BridgeData memory _bridgeData
    )
        external
        nonReentrant
        doesNotContainSourceSwaps(_bridgeData)
        doesNotContainDestinationCalls(_bridgeData)
        validateBridgeData(_bridgeData)
        onlyAllowDestinationChain(_bridgeData, GNOSIS_CHAIN_ID)
        onlyAllowSourceToken(_bridgeData, DAI)
    {
        LibAsset.depositAsset(DAI, _bridgeData.minAmount);
        _startBridge(_bridgeData);
    }

    /// @notice Performs a swap before bridging via XDaiBridge
    /// @param _bridgeData the core information needed for bridging
    /// @param _swapData an object containing swap related data to perform swaps before bridging
    function swapAndStartBridgeTokensViaXDaiBridge(
        ILiFi.BridgeData memory _bridgeData,
        LibSwap.SwapData[] calldata _swapData
    )
        external
        payable
        nonReentrant
        refundExcessNative(payable(msg.sender))
        containsSourceSwaps(_bridgeData)
        doesNotContainDestinationCalls(_bridgeData)
        validateBridgeData(_bridgeData)
        onlyAllowDestinationChain(_bridgeData, GNOSIS_CHAIN_ID)
        onlyAllowSourceToken(_bridgeData, DAI)
    {
        _bridgeData.minAmount = _depositAndSwap(
            _bridgeData.transactionId,
            _bridgeData.minAmount,
            _swapData,
            payable(msg.sender)
        );

        _startBridge(_bridgeData);
    }

    /// Private Methods ///

    /// @dev Contains the business logic for the bridge via XDaiBridge
    /// @param _bridgeData the core information needed for bridging
    function _startBridge(ILiFi.BridgeData memory _bridgeData) private {
        LibAsset.maxApproveERC20(
            IERC20(DAI),
            address(xDaiBridge),
            _bridgeData.minAmount
        );
        xDaiBridge.relayTokens(_bridgeData.receiver, _bridgeData.minAmount);
        emit LiFiTransferStarted(_bridgeData);
    }
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import { ILiFi } from "../Interfaces/ILiFi.sol";
import { IXDaiBridgeL2 } from "../Interfaces/IXDaiBridgeL2.sol";
import { LibAsset, IERC20 } from "../Libraries/LibAsset.sol";
import { ReentrancyGuard } from "../Helpers/ReentrancyGuard.sol";
import { InvalidSendingToken, NoSwapDataProvided } from "../Errors/GenericErrors.sol";
import { SwapperV2, LibSwap } from "../Helpers/SwapperV2.sol";
import { Validatable } from "../Helpers/Validatable.sol";

/// @title Gnosis Bridge Facet on Gnosis Chain
/// @author LI.FI (https://li.fi)
/// @notice Provides functionality for bridging through XDaiBridge
/// @custom:version 1.0.0
contract GnosisBridgeL2Facet is
    ILiFi,
    ReentrancyGuard,
    SwapperV2,
    Validatable
{
    /// Storage ///

    /// @notice The xDAI address on the source chain.
    address private constant XDAI = address(0);

    /// @notice The chain id of Ethereum Mainnet.
    uint64 private constant ETHEREUM_CHAIN_ID = 1;

    /// @notice The contract address of the xdai bridge on the source chain.
    IXDaiBridgeL2 private immutable xDaiBridge;

    /// Constructor ///

    /// @notice Initialize the contract.
    /// @param _xDaiBridge The contract address of the xdai bridge on the source chain.
    constructor(IXDaiBridgeL2 _xDaiBridge) {
        xDaiBridge = _xDaiBridge;
    }

    /// External Methods ///

    /// @notice Bridges tokens via XDaiBridge
    /// @param _bridgeData the core information needed for bridging
    function startBridgeTokensViaXDaiBridge(
        ILiFi.BridgeData memory _bridgeData
    )
        external
        payable
        nonReentrant
        refundExcessNative(payable(msg.sender))
        doesNotContainSourceSwaps(_bridgeData)
        doesNotContainDestinationCalls(_bridgeData)
        validateBridgeData(_bridgeData)
        onlyAllowDestinationChain(_bridgeData, ETHEREUM_CHAIN_ID)
        onlyAllowSourceToken(_bridgeData, XDAI)
    {
        _startBridge(_bridgeData);
    }

    /// @notice Performs a swap before bridging via XDaiBridge
    /// @param _bridgeData the core information needed for bridging
    /// @param _swapData an object containing swap related data to perform swaps before bridging
    function swapAndStartBridgeTokensViaXDaiBridge(
        ILiFi.BridgeData memory _bridgeData,
        LibSwap.SwapData[] calldata _swapData
    )
        external
        payable
        nonReentrant
        refundExcessNative(payable(msg.sender))
        containsSourceSwaps(_bridgeData)
        doesNotContainDestinationCalls(_bridgeData)
        validateBridgeData(_bridgeData)
        onlyAllowDestinationChain(_bridgeData, ETHEREUM_CHAIN_ID)
        onlyAllowSourceToken(_bridgeData, XDAI)
    {
        _bridgeData.minAmount = _depositAndSwap(
            _bridgeData.transactionId,
            _bridgeData.minAmount,
            _swapData,
            payable(msg.sender)
        );

        _startBridge(_bridgeData);
    }

    /// Private Methods ///

    /// @dev Contains the business logic for the bridge via XDaiBridge
    /// @param _bridgeData the core information needed for bridging
    function _startBridge(ILiFi.BridgeData memory _bridgeData) private {
        xDaiBridge.relayTokens{ value: _bridgeData.minAmount }(
            _bridgeData.receiver
        );
        emit LiFiTransferStarted(_bridgeData);
    }
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import { ILiFi } from "../Interfaces/ILiFi.sol";
import { IHopBridge } from "../Interfaces/IHopBridge.sol";
import { LibAsset, IERC20 } from "../Libraries/LibAsset.sol";
import { LibDiamond } from "../Libraries/LibDiamond.sol";
import { ReentrancyGuard } from "../Helpers/ReentrancyGuard.sol";
import { InvalidConfig, AlreadyInitialized, NotInitialized } from "../Errors/GenericErrors.sol";
import { SwapperV2, LibSwap } from "../Helpers/SwapperV2.sol";
import { Validatable } from "../Helpers/Validatable.sol";

/// @title Hop Facet
/// @author LI.FI (https://li.fi)
/// @notice Provides functionality for bridging through Hop
/// @custom:version 2.0.0
contract HopFacet is ILiFi, ReentrancyGuard, SwapperV2, Validatable {
    /// Storage ///

    bytes32 internal constant NAMESPACE = keccak256("com.lifi.facets.hop");

    /// Types ///

    struct Storage {
        mapping(address => IHopBridge) bridges;
        bool initialized; // no longer used but kept here to maintain the same storage layout
    }

    struct Config {
        address assetId;
        address bridge;
    }

    struct HopData {
        uint256 bonderFee;
        uint256 amountOutMin;
        uint256 deadline;
        uint256 destinationAmountOutMin;
        uint256 destinationDeadline;
        address relayer;
        uint256 relayerFee;
        uint256 nativeFee;
    }

    /// Events ///

    event HopInitialized(Config[] configs);
    event HopBridgeRegistered(address indexed assetId, address bridge);

    /// Init ///

    /// @notice Initialize local variables for the Hop Facet
    /// @param configs Bridge configuration data
    function initHop(Config[] calldata configs) external {
        LibDiamond.enforceIsContractOwner();

        Storage storage s = getStorage();

        for (uint256 i = 0; i < configs.length; i++) {
            if (configs[i].bridge == address(0)) {
                revert InvalidConfig();
            }
            s.bridges[configs[i].assetId] = IHopBridge(configs[i].bridge);
        }

        emit HopInitialized(configs);
    }

    /// External Methods ///

    /// @notice Register token and bridge
    /// @param assetId Address of token
    /// @param bridge Address of bridge for asset
    function registerBridge(address assetId, address bridge) external {
        LibDiamond.enforceIsContractOwner();

        Storage storage s = getStorage();

        if (bridge == address(0)) {
            revert InvalidConfig();
        }

        s.bridges[assetId] = IHopBridge(bridge);

        emit HopBridgeRegistered(assetId, bridge);
    }

    /// @notice Bridges tokens via Hop Protocol
    /// @param _bridgeData the core information needed for bridging
    /// @param _hopData data specific to Hop Protocol
    function startBridgeTokensViaHop(
        ILiFi.BridgeData memory _bridgeData,
        HopData calldata _hopData
    )
        external
        payable
        nonReentrant
        refundExcessNative(payable(msg.sender))
        doesNotContainSourceSwaps(_bridgeData)
        doesNotContainDestinationCalls(_bridgeData)
        validateBridgeData(_bridgeData)
    {
        LibAsset.depositAsset(
            _bridgeData.sendingAssetId,
            _bridgeData.minAmount
        );
        _startBridge(_bridgeData, _hopData);
    }

    /// @notice Performs a swap before bridging via Hop Protocol
    /// @param _bridgeData the core information needed for bridging
    /// @param _swapData an array of swap related data for performing swaps before bridging
    /// @param _hopData data specific to Hop Protocol
    function swapAndStartBridgeTokensViaHop(
        ILiFi.BridgeData memory _bridgeData,
        LibSwap.SwapData[] calldata _swapData,
        HopData calldata _hopData
    )
        external
        payable
        nonReentrant
        refundExcessNative(payable(msg.sender))
        containsSourceSwaps(_bridgeData)
        doesNotContainDestinationCalls(_bridgeData)
        validateBridgeData(_bridgeData)
    {
        _bridgeData.minAmount = _depositAndSwap(
            _bridgeData.transactionId,
            _bridgeData.minAmount,
            _swapData,
            payable(msg.sender),
            _hopData.nativeFee
        );
        _startBridge(_bridgeData, _hopData);
    }

    /// private Methods ///

    /// @dev Contains the business logic for the bridge via Hop Protocol
    /// @param _bridgeData the core information needed for bridging
    /// @param _hopData data specific to Hop Protocol
    function _startBridge(
        ILiFi.BridgeData memory _bridgeData,
        HopData calldata _hopData
    ) private {
        address sendingAssetId = _bridgeData.sendingAssetId;
        Storage storage s = getStorage();
        IHopBridge bridge = s.bridges[sendingAssetId];

        // Give Hop approval to bridge tokens
        LibAsset.maxApproveERC20(
            IERC20(sendingAssetId),
            address(bridge),
            _bridgeData.minAmount
        );

        uint256 value = LibAsset.isNativeAsset(address(sendingAssetId))
            ? _hopData.nativeFee + _bridgeData.minAmount
            : _hopData.nativeFee;

        if (block.chainid == 1 || block.chainid == 5) {
            // Ethereum L1
            bridge.sendToL2{ value: value }(
                _bridgeData.destinationChainId,
                _bridgeData.receiver,
                _bridgeData.minAmount,
                _hopData.destinationAmountOutMin,
                _hopData.destinationDeadline,
                _hopData.relayer,
                _hopData.relayerFee
            );
        } else {
            // L2
            // solhint-disable-next-line check-send-result
            bridge.swapAndSend{ value: value }(
                _bridgeData.destinationChainId,
                _bridgeData.receiver,
                _bridgeData.minAmount,
                _hopData.bonderFee,
                _hopData.amountOutMin,
                _hopData.deadline,
                _hopData.destinationAmountOutMin,
                _hopData.destinationDeadline
            );
        }
        emit LiFiTransferStarted(_bridgeData);
    }

    /// @dev fetch local storage
    function getStorage() private pure returns (Storage storage s) {
        bytes32 namespace = NAMESPACE;
        // solhint-disable-next-line no-inline-assembly
        assembly {
            s.slot := namespace
        }
    }
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import { ILiFi } from "../Interfaces/ILiFi.sol";
import { IHopBridge } from "../Interfaces/IHopBridge.sol";
import { LibAsset, IERC20 } from "../Libraries/LibAsset.sol";
import { SwapperV2, LibSwap } from "../Helpers/SwapperV2.sol";
import { LibDiamond } from "../Libraries/LibDiamond.sol";

/// @title Hop Facet (Optimized)
/// @author LI.FI (https://li.fi)
/// @notice Provides functionality for bridging through Hop
/// @custom:version 2.0.0
contract HopFacetOptimized is ILiFi, SwapperV2 {
    /// Types ///

    struct HopData {
        uint256 bonderFee;
        uint256 amountOutMin;
        uint256 deadline;
        uint256 destinationAmountOutMin;
        uint256 destinationDeadline;
        IHopBridge hopBridge;
        address relayer;
        uint256 relayerFee;
        uint256 nativeFee;
    }

    /// External Methods ///

    /// @notice Sets approval for the Hop Bridge to spend the specified token
    /// @param bridges The Hop Bridges to approve
    /// @param tokensToApprove The tokens to approve to approve to the Hop Bridges
    function setApprovalForBridges(
        address[] calldata bridges,
        address[] calldata tokensToApprove
    ) external {
        LibDiamond.enforceIsContractOwner();
        for (uint256 i; i < bridges.length; i++) {
            // Give Hop approval to bridge tokens
            LibAsset.maxApproveERC20(
                IERC20(tokensToApprove[i]),
                address(bridges[i]),
                type(uint256).max
            );
        }
    }

    /// @notice Bridges ERC20 tokens via Hop Protocol from L1
    /// @param _bridgeData the core information needed for bridging
    /// @param _hopData data specific to Hop Protocol
    function startBridgeTokensViaHopL1ERC20(
        ILiFi.BridgeData calldata _bridgeData,
        HopData calldata _hopData
    ) external payable {
        // Deposit assets
        LibAsset.transferFromERC20(
            _bridgeData.sendingAssetId,
            msg.sender,
            address(this),
            _bridgeData.minAmount
        );
        // Bridge assets
        _hopData.hopBridge.sendToL2{ value: _hopData.nativeFee }(
            _bridgeData.destinationChainId,
            _bridgeData.receiver,
            _bridgeData.minAmount,
            _hopData.destinationAmountOutMin,
            _hopData.destinationDeadline,
            _hopData.relayer,
            _hopData.relayerFee
        );
        emit LiFiTransferStarted(_bridgeData);
    }

    /// @notice Bridges Native tokens via Hop Protocol from L1
    /// @param _bridgeData the core information needed for bridging
    /// @param _hopData data specific to Hop Protocol
    function startBridgeTokensViaHopL1Native(
        ILiFi.BridgeData calldata _bridgeData,
        HopData calldata _hopData
    ) external payable {
        // Bridge assets
        _hopData.hopBridge.sendToL2{
            value: _bridgeData.minAmount + _hopData.nativeFee
        }(
            _bridgeData.destinationChainId,
            _bridgeData.receiver,
            _bridgeData.minAmount,
            _hopData.destinationAmountOutMin,
            _hopData.destinationDeadline,
            _hopData.relayer,
            _hopData.relayerFee
        );
        emit LiFiTransferStarted(_bridgeData);
    }

    /// @notice Performs a swap before bridging ERC20 tokens via Hop Protocol from L1
    /// @param _bridgeData the core information needed for bridging
    /// @param _swapData an array of swap related data for performing swaps before bridging
    /// @param _hopData data specific to Hop Protocol
    function swapAndStartBridgeTokensViaHopL1ERC20(
        ILiFi.BridgeData memory _bridgeData,
        LibSwap.SwapData[] calldata _swapData,
        HopData calldata _hopData
    ) external payable {
        // Deposit and swap assets
        _bridgeData.minAmount = _depositAndSwap(
            _bridgeData.transactionId,
            _bridgeData.minAmount,
            _swapData,
            payable(msg.sender),
            _hopData.nativeFee
        );

        // Bridge assets
        _hopData.hopBridge.sendToL2{ value: _hopData.nativeFee }(
            _bridgeData.destinationChainId,
            _bridgeData.receiver,
            _bridgeData.minAmount,
            _hopData.destinationAmountOutMin,
            _hopData.destinationDeadline,
            _hopData.relayer,
            _hopData.relayerFee
        );
        emit LiFiTransferStarted(_bridgeData);
    }

    /// @notice Performs a swap before bridging Native tokens via Hop Protocol from L1
    /// @param _bridgeData the core information needed for bridging
    /// @param _swapData an array of swap related data for performing swaps before bridging
    /// @param _hopData data specific to Hop Protocol
    function swapAndStartBridgeTokensViaHopL1Native(
        ILiFi.BridgeData memory _bridgeData,
        LibSwap.SwapData[] calldata _swapData,
        HopData calldata _hopData
    ) external payable {
        // Deposit and swap assets
        _bridgeData.minAmount = _depositAndSwap(
            _bridgeData.transactionId,
            _bridgeData.minAmount,
            _swapData,
            payable(msg.sender),
            _hopData.nativeFee
        );

        // Bridge assets
        _hopData.hopBridge.sendToL2{
            value: _bridgeData.minAmount + _hopData.nativeFee
        }(
            _bridgeData.destinationChainId,
            _bridgeData.receiver,
            _bridgeData.minAmount,
            _hopData.destinationAmountOutMin,
            _hopData.destinationDeadline,
            _hopData.relayer,
            _hopData.relayerFee
        );

        emit LiFiTransferStarted(_bridgeData);
    }

    /// @notice Bridges ERC20 tokens via Hop Protocol from L2
    /// @param _bridgeData the core information needed for bridging
    /// @param _hopData data specific to Hop Protocol
    function startBridgeTokensViaHopL2ERC20(
        ILiFi.BridgeData calldata _bridgeData,
        HopData calldata _hopData
    ) external {
        // Deposit assets
        LibAsset.transferFromERC20(
            _bridgeData.sendingAssetId,
            msg.sender,
            address(this),
            _bridgeData.minAmount
        );
        // Bridge assets
        _hopData.hopBridge.swapAndSend(
            _bridgeData.destinationChainId,
            _bridgeData.receiver,
            _bridgeData.minAmount,
            _hopData.bonderFee,
            _hopData.amountOutMin,
            _hopData.deadline,
            _hopData.destinationAmountOutMin,
            _hopData.destinationDeadline
        );
        emit LiFiTransferStarted(_bridgeData);
    }

    /// @notice Bridges Native tokens via Hop Protocol from L2
    /// @param _bridgeData the core information needed for bridging
    /// @param _hopData data specific to Hop Protocol
    function startBridgeTokensViaHopL2Native(
        ILiFi.BridgeData calldata _bridgeData,
        HopData calldata _hopData
    ) external payable {
        // Bridge assets
        _hopData.hopBridge.swapAndSend{ value: _bridgeData.minAmount }(
            _bridgeData.destinationChainId,
            _bridgeData.receiver,
            _bridgeData.minAmount,
            _hopData.bonderFee,
            _hopData.amountOutMin,
            _hopData.deadline,
            _hopData.destinationAmountOutMin,
            _hopData.destinationDeadline
        );
        emit LiFiTransferStarted(_bridgeData);
    }

    /// @notice Performs a swap before bridging ERC20 tokens via Hop Protocol from L2
    /// @param _bridgeData the core information needed for bridging
    /// @param _swapData an array of swap related data for performing swaps before bridging
    /// @param _hopData data specific to Hop Protocol
    function swapAndStartBridgeTokensViaHopL2ERC20(
        ILiFi.BridgeData memory _bridgeData,
        LibSwap.SwapData[] calldata _swapData,
        HopData calldata _hopData
    ) external payable {
        // Deposit and swap assets
        _bridgeData.minAmount = _depositAndSwap(
            _bridgeData.transactionId,
            _bridgeData.minAmount,
            _swapData,
            payable(msg.sender)
        );
        // Bridge assets
        _hopData.hopBridge.swapAndSend(
            _bridgeData.destinationChainId,
            _bridgeData.receiver,
            _bridgeData.minAmount,
            _hopData.bonderFee,
            _hopData.amountOutMin,
            _hopData.deadline,
            _hopData.destinationAmountOutMin,
            _hopData.destinationDeadline
        );
        emit LiFiTransferStarted(_bridgeData);
    }

    /// @notice Performs a swap before bridging Native tokens via Hop Protocol from L2
    /// @param _bridgeData the core information needed for bridging
    /// @param _swapData an array of swap related data for performing swaps before bridging
    /// @param _hopData data specific to Hop Protocol
    function swapAndStartBridgeTokensViaHopL2Native(
        ILiFi.BridgeData memory _bridgeData,
        LibSwap.SwapData[] calldata _swapData,
        HopData calldata _hopData
    ) external payable {
        // Deposit and swap assets
        _bridgeData.minAmount = _depositAndSwap(
            _bridgeData.transactionId,
            _bridgeData.minAmount,
            _swapData,
            payable(msg.sender)
        );
        // Bridge assets
        _hopData.hopBridge.swapAndSend{ value: _bridgeData.minAmount }(
            _bridgeData.destinationChainId,
            _bridgeData.receiver,
            _bridgeData.minAmount,
            _hopData.bonderFee,
            _hopData.amountOutMin,
            _hopData.deadline,
            _hopData.destinationAmountOutMin,
            _hopData.destinationDeadline
        );
        emit LiFiTransferStarted(_bridgeData);
    }
}
// // SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import { IHopBridge, IL2AmmWrapper, ISwap } from "../Interfaces/IHopBridge.sol";
import { ILiFi } from "../Interfaces/ILiFi.sol";
import { ERC20, SafeTransferLib } from "../../lib/solmate/src/utils/SafeTransferLib.sol";
import { LibAsset, IERC20 } from "../Libraries/LibAsset.sol";
import { TransferrableOwnership } from "../Helpers/TransferrableOwnership.sol";
import { HopFacetOptimized } from "../../src/Facets/HopFacetOptimized.sol";
import { WETH } from "../../lib/solmate/src/tokens/WETH.sol";

/// @title Hop Facet (Optimized for Rollups)
/// @author LI.FI (https://li.fi)
/// @notice Provides functionality for bridging through Hop
/// @custom:version 1.0.6
contract HopFacetPacked is ILiFi, TransferrableOwnership {
    using SafeTransferLib for ERC20;

    /// Storage ///

    address public immutable nativeBridge;
    address public immutable nativeL2CanonicalToken;
    address public immutable nativeHToken;
    address public immutable nativeExchangeAddress;

    /// Errors ///

    error Invalid();

    /// Events ///

    event LiFiHopTransfer(bytes8 _transactionId);

    /// Constructor ///

    /// @notice Initialize the contract.
    /// @param _owner The contract owner to approve tokens.
    /// @param _wrapper The address of Hop L2_AmmWrapper for native asset.
    constructor(
        address _owner,
        address _wrapper
    ) TransferrableOwnership(_owner) {
        bool wrapperIsSet = _wrapper != address(0);

        if (block.chainid == 1 && wrapperIsSet) {
            revert Invalid();
        }

        nativeL2CanonicalToken = wrapperIsSet
            ? IL2AmmWrapper(_wrapper).l2CanonicalToken()
            : address(0);
        nativeHToken = wrapperIsSet
            ? IL2AmmWrapper(_wrapper).hToken()
            : address(0);
        nativeExchangeAddress = wrapperIsSet
            ? IL2AmmWrapper(_wrapper).exchangeAddress()
            : address(0);
        nativeBridge = wrapperIsSet
            ? IL2AmmWrapper(_wrapper).bridge()
            : address(0);
    }

    /// External Methods ///

    /// @dev Only meant to be called outside of the context of the diamond
    /// @notice Sets approval for the Hop Bridge to spend the specified token
    /// @param bridges The Hop Bridges to approve
    /// @param tokensToApprove The tokens to approve to approve to the Hop Bridges
    function setApprovalForHopBridges(
        address[] calldata bridges,
        address[] calldata tokensToApprove
    ) external onlyOwner {
        uint256 numBridges = bridges.length;

        for (uint256 i; i < numBridges; i++) {
            // Give Hop approval to bridge tokens
            LibAsset.maxApproveERC20(
                IERC20(tokensToApprove[i]),
                address(bridges[i]),
                type(uint256).max
            );
        }
    }

    /// @notice Bridges Native tokens via Hop Protocol from L2
    /// No params, all data will be extracted from manually encoded callData
    function startBridgeTokensViaHopL2NativePacked() external payable {
        // first 4 bytes are function signature
        // transactionId: bytes8(msg.data[4:12]),
        // receiver: address(bytes20(msg.data[12:32])),
        // destinationChainId: uint256(uint32(bytes4(msg.data[32:36]))),
        // bonderFee: uint256(uint128(bytes16(msg.data[36:52]))),
        // amountOutMin: uint256(uint128(bytes16(msg.data[52:68])))
        // => total calldata length required: 68

        uint256 destinationChainId = uint256(uint32(bytes4(msg.data[32:36])));
        uint256 amountOutMin = uint256(uint128(bytes16(msg.data[52:68])));
        bool toL1 = destinationChainId == 1;

        // Wrap ETH
        WETH(payable(nativeL2CanonicalToken)).deposit{ value: msg.value }();

        // Exchange WETH for hToken
        uint256 swapAmount = ISwap(nativeExchangeAddress).swap(
            0,
            1,
            msg.value,
            amountOutMin,
            block.timestamp
        );

        // Bridge assets
        // solhint-disable-next-line check-send-result
        IHopBridge(nativeBridge).send(
            destinationChainId,
            address(bytes20(msg.data[12:32])), // receiver
            swapAmount,
            uint256(uint128(bytes16(msg.data[36:52]))), // bonderFee
            toL1 ? 0 : amountOutMin,
            toL1 ? 0 : block.timestamp + 7 * 24 * 60 * 60
        );

        emit LiFiHopTransfer(
            bytes8(msg.data[4:12]) // transactionId
        );
    }

    /// @notice Bridges Native tokens via Hop Protocol from L2
    /// @param transactionId Custom transaction ID for tracking
    /// @param receiver Receiving wallet address
    /// @param destinationChainId Receiving chain
    /// @param bonderFee Fees payed to hop bonder
    /// @param amountOutMin Source swap minimal accepted amount
    /// @param destinationAmountOutMin Destination swap minimal accepted amount
    /// @param destinationDeadline Destination swap maximal time
    /// @param hopBridge Address of the Hop L2_AmmWrapper
    function startBridgeTokensViaHopL2NativeMin(
        bytes8 transactionId,
        address receiver,
        uint256 destinationChainId,
        uint256 bonderFee,
        uint256 amountOutMin,
        uint256 destinationAmountOutMin,
        uint256 destinationDeadline,
        address hopBridge
    ) external payable {
        // Bridge assets
        IHopBridge(hopBridge).swapAndSend{ value: msg.value }(
            destinationChainId,
            receiver,
            msg.value,
            bonderFee,
            amountOutMin,
            block.timestamp,
            destinationAmountOutMin,
            destinationDeadline
        );

        emit LiFiHopTransfer(transactionId);
    }

    /// @notice Bridges Native tokens via Hop Protocol from L2
    /// @param transactionId Custom transaction ID for tracking
    /// @param receiver Receiving wallet address
    /// @param destinationChainId Receiving chain
    /// @param bonderFee Fees payed to hop bonder
    /// @param amountOutMin Source swap minimal accepted amount
    function encode_startBridgeTokensViaHopL2NativePacked(
        bytes8 transactionId,
        address receiver,
        uint256 destinationChainId,
        uint256 bonderFee,
        uint256 amountOutMin
    ) external pure returns (bytes memory) {
        require(
            destinationChainId <= type(uint32).max,
            "destinationChainId value passed too big to fit in uint32"
        );
        require(
            bonderFee <= type(uint128).max,
            "bonderFee value passed too big to fit in uint128"
        );
        require(
            amountOutMin <= type(uint128).max,
            "amountOutMin value passed too big to fit in uint128"
        );

        return
            bytes.concat(
                HopFacetPacked.startBridgeTokensViaHopL2NativePacked.selector,
                bytes8(transactionId),
                bytes20(receiver),
                bytes4(uint32(destinationChainId)),
                bytes16(uint128(bonderFee)),
                bytes16(uint128(amountOutMin))
            );
    }

    /// @notice Decodes calldata for startBridgeTokensViaHopL2NativePacked
    /// @param _data the calldata to decode
    function decode_startBridgeTokensViaHopL2NativePacked(
        bytes calldata _data
    )
        external
        pure
        returns (BridgeData memory, HopFacetOptimized.HopData memory)
    {
        require(
            _data.length >= 68,
            "data passed in is not the correct length"
        );

        BridgeData memory bridgeData;
        HopFacetOptimized.HopData memory hopData;

        bridgeData.transactionId = bytes32(bytes8(_data[4:12]));
        bridgeData.receiver = address(bytes20(_data[12:32]));
        bridgeData.destinationChainId = uint256(uint32(bytes4(_data[32:36])));
        hopData.bonderFee = uint256(uint128(bytes16(_data[36:52])));
        hopData.amountOutMin = uint256(uint128(bytes16(_data[52:68])));

        return (bridgeData, hopData);
    }

    /// @notice Bridges ERC20 tokens via Hop Protocol from L2
    /// No params, all data will be extracted from manually encoded callData
    function startBridgeTokensViaHopL2ERC20Packed() external {
        // first 4 bytes are function signature
        // transactionId: bytes8(msg.data[4:12]),
        // receiver: address(bytes20(msg.data[12:32])),
        // destinationChainId: uint256(uint32(bytes4(msg.data[32:36]))),
        // sendingAssetId: address(bytes20(msg.data[36:56])),
        // amount: uint256(uint128(bytes16(msg.data[56:72]))),
        // bonderFee: uint256(uint128(bytes16(msg.data[72:88]))),
        // amountOutMin: uint256(uint128(bytes16(msg.data[88:104]))),
        // destinationAmountOutMin: uint256(uint128(bytes16(msg.data[104:120]))),
        // destinationDeadline: uint256(uint32(bytes4(msg.data[120:124]))),
        // wrapper: address(bytes20(msg.data[124:144]))
        // => total calldata length required: 144

        uint256 destinationChainId = uint256(uint32(bytes4(msg.data[32:36])));
        uint256 amount = uint256(uint128(bytes16(msg.data[56:72])));
        uint256 amountOutMin = uint256(uint128(bytes16(msg.data[88:104])));
        bool toL1 = destinationChainId == 1;

        IL2AmmWrapper wrapper = IL2AmmWrapper(
            address(bytes20(msg.data[124:144]))
        );

        // Deposit assets
        ERC20(address(bytes20(msg.data[36:56]))).safeTransferFrom(
            msg.sender,
            address(this),
            amount
        );

        // Exchange sending asset to hToken
        uint256 swapAmount = ISwap(wrapper.exchangeAddress()).swap(
            0,
            1,
            amount,
            amountOutMin,
            block.timestamp
        );

        // Bridge assets
        // solhint-disable-next-line check-send-result
        IHopBridge(wrapper.bridge()).send(
            destinationChainId,
            address(bytes20(msg.data[12:32])),
            swapAmount,
            uint256(uint128(bytes16(msg.data[72:88]))),
            toL1 ? 0 : uint256(uint128(bytes16(msg.data[104:120]))),
            toL1 ? 0 : uint256(uint32(bytes4(msg.data[120:124])))
        );

        emit LiFiHopTransfer(bytes8(msg.data[4:12]));
    }

    /// @notice Bridges ERC20 tokens via Hop Protocol from L2
    /// @param transactionId Custom transaction ID for tracking
    /// @param receiver Receiving wallet address
    /// @param destinationChainId Receiving chain
    /// @param sendingAssetId Address of the source asset to bridge
    /// @param minAmount Amount of the source asset to bridge
    /// @param bonderFee Fees payed to hop bonder
    /// @param amountOutMin Source swap minimal accepted amount
    /// @param destinationAmountOutMin Destination swap minimal accepted amount
    /// @param destinationDeadline Destination swap maximal time
    /// @param hopBridge Address of the Hop L2_AmmWrapper
    function startBridgeTokensViaHopL2ERC20Min(
        bytes8 transactionId,
        address receiver,
        uint256 destinationChainId,
        address sendingAssetId,
        uint256 minAmount,
        uint256 bonderFee,
        uint256 amountOutMin,
        uint256 destinationAmountOutMin,
        uint256 destinationDeadline,
        address hopBridge
    ) external {
        // Deposit assets
        ERC20(sendingAssetId).safeTransferFrom(
            msg.sender,
            address(this),
            minAmount
        );

        // Bridge assets
        IHopBridge(hopBridge).swapAndSend(
            destinationChainId,
            receiver,
            minAmount,
            bonderFee,
            amountOutMin,
            block.timestamp,
            destinationAmountOutMin,
            destinationDeadline
        );

        emit LiFiHopTransfer(transactionId);
    }

    /// @notice Bridges ERC20 tokens via Hop Protocol from L2
    /// @param transactionId Custom transaction ID for tracking
    /// @param receiver Receiving wallet address
    /// @param destinationChainId Receiving chain
    /// @param sendingAssetId Address of the source asset to bridge
    /// @param minAmount Amount of the source asset to bridge
    /// @param bonderFee Fees payed to hop bonder
    /// @param amountOutMin Source swap minimal accepted amount
    /// @param destinationAmountOutMin Destination swap minimal accepted amount
    /// @param destinationDeadline Destination swap maximal time
    /// @param wrapper Address of the Hop L2_AmmWrapper
    function encode_startBridgeTokensViaHopL2ERC20Packed(
        bytes32 transactionId,
        address receiver,
        uint256 destinationChainId,
        address sendingAssetId,
        uint256 minAmount,
        uint256 bonderFee,
        uint256 amountOutMin,
        uint256 destinationAmountOutMin,
        uint256 destinationDeadline,
        address wrapper
    ) external pure returns (bytes memory) {
        require(
            destinationChainId <= type(uint32).max,
            "destinationChainId value passed too big to fit in uint32"
        );
        require(
            minAmount <= type(uint128).max,
            "amount value passed too big to fit in uint128"
        );
        require(
            bonderFee <= type(uint128).max,
            "bonderFee value passed too big to fit in uint128"
        );
        require(
            amountOutMin <= type(uint128).max,
            "amountOutMin value passed too big to fit in uint128"
        );
        require(
            destinationAmountOutMin <= type(uint128).max,
            "destinationAmountOutMin value passed too big to fit in uint128"
        );
        require(
            destinationDeadline <= type(uint32).max,
            "destinationDeadline value passed too big to fit in uint32"
        );

        return
            bytes.concat(
                HopFacetPacked.startBridgeTokensViaHopL2ERC20Packed.selector,
                bytes8(transactionId),
                bytes20(receiver),
                bytes4(uint32(destinationChainId)),
                bytes20(sendingAssetId),
                bytes16(uint128(minAmount)),
                bytes16(uint128(bonderFee)),
                bytes16(uint128(amountOutMin)),
                bytes16(uint128(destinationAmountOutMin)),
                bytes4(uint32(destinationDeadline)),
                bytes20(wrapper)
            );
    }

    /// @notice Decodes calldata for startBridgeTokensViaHopL2ERC20Packed
    /// @param _data the calldata to decode
    function decode_startBridgeTokensViaHopL2ERC20Packed(
        bytes calldata _data
    )
        external
        pure
        returns (BridgeData memory, HopFacetOptimized.HopData memory)
    {
        require(
            _data.length >= 144,
            "data passed in is not the correct length"
        );

        BridgeData memory bridgeData;
        HopFacetOptimized.HopData memory hopData;

        bridgeData.transactionId = bytes32(bytes8(_data[4:12]));
        bridgeData.receiver = address(bytes20(_data[12:32]));
        bridgeData.destinationChainId = uint256(uint32(bytes4(_data[32:36])));
        bridgeData.sendingAssetId = address(bytes20(_data[36:56]));
        bridgeData.minAmount = uint256(uint128(bytes16(_data[56:72])));
        hopData.bonderFee = uint256(uint128(bytes16(_data[72:88])));
        hopData.amountOutMin = uint256(uint128(bytes16(_data[88:104])));
        hopData.destinationAmountOutMin = uint256(
            uint128(bytes16(_data[104:120]))
        );
        hopData.destinationDeadline = uint256(uint32(bytes4(_data[120:124])));
        hopData.hopBridge = IHopBridge(address(bytes20(_data[124:144])));

        return (bridgeData, hopData);
    }

    /// @notice Bridges Native tokens via Hop Protocol from L1
    /// No params, all data will be extracted from manually encoded callData
    function startBridgeTokensViaHopL1NativePacked() external payable {
        // first 4 bytes are function signature
        // transactionId: bytes8(msg.data[4:12]),
        // receiver: address(bytes20(msg.data[12:32])),
        // destinationChainId: uint256(uint32(bytes4(msg.data[32:36]))),
        // destinationAmountOutMin: uint256(uint128(bytes16(msg.data[36:52]))),
        // relayer: address(bytes20(msg.data[52:72])),
        // relayerFee: uint256(uint128(bytes16(msg.data[72:88]))),
        // hopBridge: address(bytes20(msg.data[88:108]))
        // => total calldata length required: 108

        // Bridge assets
        IHopBridge(address(bytes20(msg.data[88:108]))).sendToL2{
            value: msg.value
        }(
            uint256(uint32(bytes4(msg.data[32:36]))),
            address(bytes20(msg.data[12:32])),
            msg.value,
            uint256(uint128(bytes16(msg.data[36:52]))),
            block.timestamp + 7 * 24 * 60 * 60,
            address(bytes20(msg.data[52:72])),
            uint256(uint128(bytes16(msg.data[72:88])))
        );

        emit LiFiHopTransfer(bytes8(msg.data[4:12]));
    }

    /// @notice Bridges Native tokens via Hop Protocol from L1
    /// @param transactionId Custom transaction ID for tracking
    /// @param receiver Receiving wallet address
    /// @param destinationChainId Receiving chain
    /// @param destinationAmountOutMin Destination swap minimal accepted amount
    /// @param relayer needed for gas spikes
    /// @param relayerFee needed for gas spikes
    /// @param hopBridge Address of the Hop Bridge
    function startBridgeTokensViaHopL1NativeMin(
        bytes8 transactionId,
        address receiver,
        uint256 destinationChainId,
        uint256 destinationAmountOutMin,
        address relayer,
        uint256 relayerFee,
        address hopBridge
    ) external payable {
        // Bridge assets
        IHopBridge(hopBridge).sendToL2{ value: msg.value }(
            destinationChainId,
            receiver,
            msg.value,
            destinationAmountOutMin,
            block.timestamp + 7 * 24 * 60 * 60,
            relayer,
            relayerFee
        );

        emit LiFiHopTransfer(transactionId);
    }

    /// @notice Bridges Native tokens via Hop Protocol from L1
    /// @param transactionId Custom transaction ID for tracking
    /// @param receiver Receiving wallet address
    /// @param destinationChainId Receiving chain
    /// @param destinationAmountOutMin Destination swap minimal accepted amount
    /// @param relayer needed for gas spikes
    /// @param relayerFee needed for gas spikes
    /// @param hopBridge Address of the Hop Bridge
    function encode_startBridgeTokensViaHopL1NativePacked(
        bytes8 transactionId,
        address receiver,
        uint256 destinationChainId,
        uint256 destinationAmountOutMin,
        address relayer,
        uint256 relayerFee,
        address hopBridge
    ) external pure returns (bytes memory) {
        require(
            destinationChainId <= type(uint32).max,
            "destinationChainId value passed too big to fit in uint32"
        );
        require(
            destinationAmountOutMin <= type(uint128).max,
            "destinationAmountOutMin value passed too big to fit in uint128"
        );
        require(
            relayerFee <= type(uint128).max,
            "relayerFee value passed too big to fit in uint128"
        );

        return
            bytes.concat(
                HopFacetPacked.startBridgeTokensViaHopL1NativePacked.selector,
                bytes8(transactionId),
                bytes20(receiver),
                bytes4(uint32(destinationChainId)),
                bytes16(uint128(destinationAmountOutMin)),
                bytes20(relayer),
                bytes16(uint128(relayerFee)),
                bytes20(hopBridge)
            );
    }

    /// @notice Decodes calldata for startBridgeTokensViaHopL1NativePacked
    /// @param _data the calldata to decode
    function decode_startBridgeTokensViaHopL1NativePacked(
        bytes calldata _data
    )
        external
        pure
        returns (BridgeData memory, HopFacetOptimized.HopData memory)
    {
        require(
            _data.length >= 108,
            "data passed in is not the correct length"
        );

        BridgeData memory bridgeData;
        HopFacetOptimized.HopData memory hopData;

        bridgeData.transactionId = bytes32(bytes8(_data[4:12]));
        bridgeData.receiver = address(bytes20(_data[12:32]));
        bridgeData.destinationChainId = uint256(uint32(bytes4(_data[32:36])));
        hopData.destinationAmountOutMin = uint256(
            uint128(bytes16(_data[36:52]))
        );
        // relayer = address(bytes20(_data[52:72]));
        // relayerFee = uint256(uint128(bytes16(_data[72:88])));
        hopData.hopBridge = IHopBridge(address(bytes20(_data[88:108])));

        return (bridgeData, hopData);
    }

    /// @notice Bridges Native tokens via Hop Protocol from L1
    /// No params, all data will be extracted from manually encoded callData
    function startBridgeTokensViaHopL1ERC20Packed() external payable {
        // first 4 bytes are function signature
        // transactionId: bytes8(msg.data[4:12]),
        // receiver: address(bytes20(msg.data[12:32])),
        // destinationChainId: uint256(uint32(bytes4(msg.data[32:36]))),
        // sendingAssetId: address(bytes20(msg.data[36:56])),
        // amount: uint256(uint128(bytes16(msg.data[56:72]))),
        // destinationAmountOutMin: uint256(uint128(bytes16(msg.data[72:88]))),
        // relayer: address(bytes20(msg.data[88:108])),
        // relayerFee: uint256(uint128(bytes16(msg.data[108:124]))),
        // hopBridge: address(bytes20(msg.data[124:144]))
        // => total calldata length required: 144

        uint256 amount = uint256(uint128(bytes16(msg.data[56:72])));

        // Deposit assets
        ERC20(address(bytes20(msg.data[36:56]))).safeTransferFrom(
            msg.sender,
            address(this),
            amount
        );

        // Bridge assets
        IHopBridge(address(bytes20(msg.data[124:144]))).sendToL2(
            uint256(uint32(bytes4(msg.data[32:36]))),
            address(bytes20(msg.data[12:32])),
            amount,
            uint256(uint128(bytes16(msg.data[72:88]))),
            block.timestamp + 7 * 24 * 60 * 60,
            address(bytes20(msg.data[88:108])),
            uint256(uint128(bytes16(msg.data[108:124])))
        );

        emit LiFiHopTransfer(bytes8(msg.data[4:12]));
    }

    /// @notice Bridges ERC20 tokens via Hop Protocol from L1
    /// @param transactionId Custom transaction ID for tracking
    /// @param receiver Receiving wallet address
    /// @param destinationChainId Receiving chain
    /// @param sendingAssetId Address of the source asset to bridge
    /// @param minAmount Amount of the source asset to bridge
    /// @param destinationAmountOutMin Destination swap minimal accepted amount
    /// @param relayer needed for gas spikes
    /// @param relayerFee needed for gas spikes
    /// @param hopBridge Address of the Hop Bridge
    function startBridgeTokensViaHopL1ERC20Min(
        bytes8 transactionId,
        address receiver,
        uint256 destinationChainId,
        address sendingAssetId,
        uint256 minAmount,
        uint256 destinationAmountOutMin,
        address relayer,
        uint256 relayerFee,
        address hopBridge
    ) external {
        // Deposit assets
        ERC20(sendingAssetId).safeTransferFrom(
            msg.sender,
            address(this),
            minAmount
        );

        // Bridge assets
        IHopBridge(hopBridge).sendToL2(
            destinationChainId,
            receiver,
            minAmount,
            destinationAmountOutMin,
            block.timestamp + 7 * 24 * 60 * 60,
            relayer,
            relayerFee
        );

        emit LiFiHopTransfer(transactionId);
    }

    /// @notice Bridges ERC20 tokens via Hop Protocol from L1
    /// @param transactionId Custom transaction ID for tracking
    /// @param receiver Receiving wallet address
    /// @param destinationChainId Receiving chain
    /// @param sendingAssetId Address of the source asset to bridge
    /// @param minAmount Amount of the source asset to bridge
    /// @param destinationAmountOutMin Destination swap minimal accepted amount
    /// @param relayer needed for gas spikes
    /// @param relayerFee needed for gas spikes
    /// @param hopBridge Address of the Hop Bridge
    function encode_startBridgeTokensViaHopL1ERC20Packed(
        bytes8 transactionId,
        address receiver,
        uint256 destinationChainId,
        address sendingAssetId,
        uint256 minAmount,
        uint256 destinationAmountOutMin,
        address relayer,
        uint256 relayerFee,
        address hopBridge
    ) external pure returns (bytes memory) {
        require(
            destinationChainId <= type(uint32).max,
            "destinationChainId value passed too big to fit in uint32"
        );
        require(
            minAmount <= type(uint128).max,
            "amount value passed too big to fit in uint128"
        );
        require(
            destinationAmountOutMin <= type(uint128).max,
            "destinationAmountOutMin value passed too big to fit in uint128"
        );
        require(
            relayerFee <= type(uint128).max,
            "relayerFee value passed too big to fit in uint128"
        );

        return
            bytes.concat(
                HopFacetPacked.startBridgeTokensViaHopL1ERC20Packed.selector,
                bytes8(transactionId),
                bytes20(receiver),
                bytes4(uint32(destinationChainId)),
                bytes20(sendingAssetId),
                bytes16(uint128(minAmount)),
                bytes16(uint128(destinationAmountOutMin)),
                bytes20(relayer),
                bytes16(uint128(relayerFee)),
                bytes20(hopBridge)
            );
    }

    /// @notice Decodes calldata for startBridgeTokensViaHopL1ERC20Packed
    /// @param _data the calldata to decode
    function decode_startBridgeTokensViaHopL1ERC20Packed(
        bytes calldata _data
    )
        external
        pure
        returns (BridgeData memory, HopFacetOptimized.HopData memory)
    {
        require(
            _data.length >= 144,
            "data passed in is not the correct length"
        );

        BridgeData memory bridgeData;
        HopFacetOptimized.HopData memory hopData;

        bridgeData.transactionId = bytes32(bytes8(_data[4:12]));
        bridgeData.receiver = address(bytes20(_data[12:32]));
        bridgeData.destinationChainId = uint256(uint32(bytes4(_data[32:36])));
        bridgeData.sendingAssetId = address(bytes20(_data[36:56]));
        bridgeData.minAmount = uint256(uint128(bytes16(_data[56:72])));
        hopData.destinationAmountOutMin = uint256(
            uint128(bytes16(_data[72:88]))
        );
        // relayer = address(bytes20(_data[88:108]));
        // relayerFee = uint256(uint128(bytes16(_data[108:124])));
        hopData.hopBridge = IHopBridge(address(bytes20(_data[124:144])));

        return (bridgeData, hopData);
    }
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import { ILiFi } from "../Interfaces/ILiFi.sol";
import { IHyphenRouter } from "../Interfaces/IHyphenRouter.sol";
import { LibAsset, IERC20 } from "../Libraries/LibAsset.sol";
import { ReentrancyGuard } from "../Helpers/ReentrancyGuard.sol";
import { SwapperV2, LibSwap } from "../Helpers/SwapperV2.sol";
import { Validatable } from "../Helpers/Validatable.sol";

/// @title Hyphen Facet
/// @author LI.FI (https://li.fi)
/// @notice Provides functionality for bridging through Hyphen
/// @custom:version 1.0.0
contract HyphenFacet is ILiFi, ReentrancyGuard, SwapperV2, Validatable {
    /// Storage ///

    /// @notice The contract address of the router on the source chain.
    IHyphenRouter private immutable router;

    /// Constructor ///

    /// @notice Initialize the contract.
    /// @param _router The contract address of the router on the source chain.
    constructor(IHyphenRouter _router) {
        router = _router;
    }

    /// External Methods ///

    /// @notice Bridges tokens via Hyphen
    /// @param _bridgeData the core information needed for bridging
    function startBridgeTokensViaHyphen(
        ILiFi.BridgeData memory _bridgeData
    )
        external
        payable
        nonReentrant
        refundExcessNative(payable(msg.sender))
        doesNotContainSourceSwaps(_bridgeData)
        doesNotContainDestinationCalls(_bridgeData)
        validateBridgeData(_bridgeData)
    {
        LibAsset.depositAsset(
            _bridgeData.sendingAssetId,
            _bridgeData.minAmount
        );
        _startBridge(_bridgeData);
    }

    /// @notice Performs a swap before bridging via Hyphen
    /// @param _bridgeData the core information needed for bridging
    /// @param _swapData an array of swap related data for performing swaps before bridging
    function swapAndStartBridgeTokensViaHyphen(
        ILiFi.BridgeData memory _bridgeData,
        LibSwap.SwapData[] calldata _swapData
    )
        external
        payable
        nonReentrant
        refundExcessNative(payable(msg.sender))
        containsSourceSwaps(_bridgeData)
        doesNotContainDestinationCalls(_bridgeData)
        validateBridgeData(_bridgeData)
    {
        _bridgeData.minAmount = _depositAndSwap(
            _bridgeData.transactionId,
            _bridgeData.minAmount,
            _swapData,
            payable(msg.sender)
        );
        _startBridge(_bridgeData);
    }

    /// Private Methods ///

    /// @dev Contains the business logic for the bridge via Hyphen
    /// @param _bridgeData the core information needed for bridging
    function _startBridge(ILiFi.BridgeData memory _bridgeData) private {
        if (!LibAsset.isNativeAsset(_bridgeData.sendingAssetId)) {
            // Give the Hyphen router approval to bridge tokens
            LibAsset.maxApproveERC20(
                IERC20(_bridgeData.sendingAssetId),
                address(router),
                _bridgeData.minAmount
            );

            router.depositErc20(
                _bridgeData.destinationChainId,
                _bridgeData.sendingAssetId,
                _bridgeData.receiver,
                _bridgeData.minAmount,
                "LIFI"
            );
        } else {
            router.depositNative{ value: _bridgeData.minAmount }(
                _bridgeData.receiver,
                _bridgeData.destinationChainId,
                "LIFI"
            );
        }

        emit LiFiTransferStarted(_bridgeData);
    }
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import { ILiFi } from "../Interfaces/ILiFi.sol";
import { ServiceFeeCollector } from "../Periphery/ServiceFeeCollector.sol";
import { LibAsset, IERC20 } from "../Libraries/LibAsset.sol";
import { ReentrancyGuard } from "../Helpers/ReentrancyGuard.sol";
import { SwapperV2, LibSwap } from "../Helpers/SwapperV2.sol";
import { Validatable } from "../Helpers/Validatable.sol";

/// @title LIFuel Facet
/// @author Li.Finance (https://li.finance)
/// @notice Provides functionality for bridging gas through LIFuel
/// @custom:version 1.0.0
contract LIFuelFacet is ILiFi, ReentrancyGuard, SwapperV2, Validatable {
    /// Storage ///

    bytes32 internal constant NAMESPACE =
        keccak256("com.lifi.facets.periphery_registry");
    string internal constant FEE_COLLECTOR_NAME = "ServiceFeeCollector";

    /// Types ///

    struct Storage {
        mapping(string => address) contracts;
    }

    /// External Methods ///

    /// @notice Bridges tokens via LIFuel Bridge
    /// @param _bridgeData Data used purely for tracking and analytics
    function startBridgeTokensViaLIFuel(
        ILiFi.BridgeData memory _bridgeData
    )
        external
        payable
        nonReentrant
        refundExcessNative(payable(msg.sender))
        doesNotContainSourceSwaps(_bridgeData)
        doesNotContainDestinationCalls(_bridgeData)
        validateBridgeData(_bridgeData)
    {
        LibAsset.depositAsset(
            _bridgeData.sendingAssetId,
            _bridgeData.minAmount
        );
        _startBridge(_bridgeData);
    }

    /// @notice Performs a swap before bridging via LIFuel Bridge
    /// @param _bridgeData Data used purely for tracking and analytics
    /// @param _swapData An array of swap related data for performing swaps before bridging
    function swapAndStartBridgeTokensViaLIFuel(
        ILiFi.BridgeData memory _bridgeData,
        LibSwap.SwapData[] calldata _swapData
    )
        external
        payable
        nonReentrant
        refundExcessNative(payable(msg.sender))
        containsSourceSwaps(_bridgeData)
        doesNotContainDestinationCalls(_bridgeData)
        validateBridgeData(_bridgeData)
    {
        _bridgeData.minAmount = _depositAndSwap(
            _bridgeData.transactionId,
            _bridgeData.minAmount,
            _swapData,
            payable(msg.sender)
        );

        _startBridge(_bridgeData);
    }

    /// Private Methods ///

    /// @dev Contains the business logic for the bridge via LIFuel Bridge
    /// @param _bridgeData Data used purely for tracking and analytics
    function _startBridge(ILiFi.BridgeData memory _bridgeData) private {
        ServiceFeeCollector serviceFeeCollector = ServiceFeeCollector(
            getStorage().contracts[FEE_COLLECTOR_NAME]
        );

        if (LibAsset.isNativeAsset(_bridgeData.sendingAssetId)) {
            serviceFeeCollector.collectNativeGasFees{
                value: _bridgeData.minAmount
            }(_bridgeData.destinationChainId, _bridgeData.receiver);
        } else {
            LibAsset.maxApproveERC20(
                IERC20(_bridgeData.sendingAssetId),
                address(serviceFeeCollector),
                _bridgeData.minAmount
            );

            serviceFeeCollector.collectTokenGasFees(
                _bridgeData.sendingAssetId,
                _bridgeData.minAmount,
                _bridgeData.destinationChainId,
                _bridgeData.receiver
            );
        }

        emit LiFiTransferStarted(_bridgeData);
    }

    /// @dev fetch local storage
    function getStorage() private pure returns (Storage storage s) {
        bytes32 namespace = NAMESPACE;
        // solhint-disable-next-line no-inline-assembly
        assembly {
            s.slot := namespace
        }
    }
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "../../lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import "../../lib/openzeppelin-contracts/contracts/utils/math/SafeCast.sol";
import { ILiFi } from "../Interfaces/ILiFi.sol";
import { ITeleportGateway } from "../Interfaces/ITeleportGateway.sol";
import { LibAsset } from "../Libraries/LibAsset.sol";
import { LibSwap } from "../Libraries/LibSwap.sol";
import { ReentrancyGuard } from "../Helpers/ReentrancyGuard.sol";
import { SwapperV2 } from "../Helpers/SwapperV2.sol";
import { Validatable } from "../Helpers/Validatable.sol";
import { InvalidSendingToken, NoSwapDataProvided } from "../Errors/GenericErrors.sol";

/// @title MakerTeleport Facet
/// @author LI.FI (https://li.fi)
/// @notice Provides functionality for bridging through Maker Teleport
/// @custom:version 1.0.0
contract MakerTeleportFacet is ILiFi, ReentrancyGuard, SwapperV2, Validatable {
    using SafeCast for uint256;

    /// Storage ///

    /// @notice The address of Teleport Gateway.
    ITeleportGateway private immutable teleportGateway;

    /// @notice The address of DAI on the source chain.
    address private immutable dai;

    /// @notice The chain id of destination chain.
    uint256 private immutable dstChainId;

    /// @notice The domain of l1 network.
    bytes32 private immutable l1Domain;

    /// Constructor ///

    /// @notice Initialize the contract.
    /// @param _teleportGateway The address of Teleport Gateway.
    /// @param _dai The address of DAI on the source chain.
    /// @param _dstChainId The chain id of destination chain.
    /// @param _l1Domain The domain of l1 network.
    constructor(
        ITeleportGateway _teleportGateway,
        address _dai,
        uint256 _dstChainId,
        bytes32 _l1Domain
    ) {
        dstChainId = _dstChainId;
        teleportGateway = _teleportGateway;
        dai = _dai;
        l1Domain = _l1Domain;
    }

    /// External Methods ///

    /// @notice Bridges tokens via Maker Teleport
    /// @param _bridgeData The core information needed for bridging
    function startBridgeTokensViaMakerTeleport(
        ILiFi.BridgeData memory _bridgeData
    )
        external
        nonReentrant
        validateBridgeData(_bridgeData)
        doesNotContainSourceSwaps(_bridgeData)
        doesNotContainDestinationCalls(_bridgeData)
        onlyAllowDestinationChain(_bridgeData, dstChainId)
        onlyAllowSourceToken(_bridgeData, dai)
    {
        LibAsset.depositAsset(dai, _bridgeData.minAmount);
        _startBridge(_bridgeData);
    }

    /// @notice Performs a swap before bridging via Maker Teleport
    /// @param _bridgeData The core information needed for bridging
    /// @param _swapData An array of swap related data for performing swaps before bridging
    function swapAndStartBridgeTokensViaMakerTeleport(
        ILiFi.BridgeData memory _bridgeData,
        LibSwap.SwapData[] calldata _swapData
    )
        external
        payable
        nonReentrant
        refundExcessNative(payable(msg.sender))
        validateBridgeData(_bridgeData)
        containsSourceSwaps(_bridgeData)
        doesNotContainDestinationCalls(_bridgeData)
        onlyAllowDestinationChain(_bridgeData, dstChainId)
        onlyAllowSourceToken(_bridgeData, dai)
    {
        _bridgeData.minAmount = _depositAndSwap(
            _bridgeData.transactionId,
            _bridgeData.minAmount,
            _swapData,
            payable(msg.sender)
        );

        _startBridge(_bridgeData);
    }

    /// Internal Methods ///

    /// @dev Contains the business logic for the bridge via Maker Teleport
    /// @param _bridgeData The core information needed for bridging
    function _startBridge(ILiFi.BridgeData memory _bridgeData) internal {
        LibAsset.maxApproveERC20(
            IERC20(dai),
            address(teleportGateway),
            _bridgeData.minAmount
        );

        teleportGateway.initiateTeleport(
            l1Domain,
            _bridgeData.receiver,
            _bridgeData.minAmount.toUint128()
        );

        emit LiFiTransferStarted(_bridgeData);
    }
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import { ILiFi } from "../Interfaces/ILiFi.sol";
import { LibAsset, IERC20 } from "../Libraries/LibAsset.sol";
import { LibDiamond } from "../Libraries/LibDiamond.sol";
import { IMultichainRouter } from "../Interfaces/IMultichainRouter.sol";
import { ReentrancyGuard } from "../Helpers/ReentrancyGuard.sol";
import { InvalidConfig, AlreadyInitialized, NotInitialized } from "../Errors/GenericErrors.sol";
import { SwapperV2, LibSwap } from "../Helpers/SwapperV2.sol";
import { Validatable } from "../Helpers/Validatable.sol";

interface IMultichainERC20 {
    function Swapout(uint256 amount, address bindaddr) external returns (bool);
}

/// @title Multichain Facet
/// @author LI.FI (https://li.fi)
/// @notice Provides functionality for bridging through Multichain (Prev. AnySwap)
/// @custom:version 1.0.1
contract MultichainFacet is ILiFi, SwapperV2, ReentrancyGuard, Validatable {
    /// Storage ///

    bytes32 internal constant NAMESPACE =
        keccak256("com.lifi.facets.multichain");

    /// Types ///

    struct Storage {
        mapping(address => bool) allowedRouters;
        bool initialized; // no longer used but kept here to maintain the same storage layout
        address anyNative;
        mapping(address => address) anyTokenAddresses;
    }

    struct MultichainData {
        address router;
    }

    struct AnyMapping {
        address tokenAddress;
        address anyTokenAddress;
    }

    /// Errors ///

    error InvalidRouter();

    /// Events ///

    event MultichainInitialized();
    event MultichainRoutersUpdated(address[] routers, bool[] allowed);
    event AnyMappingUpdated(AnyMapping[] mappings);

    /// Init ///

    /// @notice Initialize local variables for the Multichain Facet
    /// @param anyNative The address of the anyNative (e.g. anyETH) token
    /// @param routers Allowed Multichain Routers
    function initMultichain(
        address anyNative,
        address[] calldata routers
    ) external {
        LibDiamond.enforceIsContractOwner();

        Storage storage s = getStorage();

        s.anyNative = anyNative;

        uint256 len = routers.length;
        for (uint256 i = 0; i < len; ) {
            if (routers[i] == address(0)) {
                revert InvalidConfig();
            }
            s.allowedRouters[routers[i]] = true;
            unchecked {
                ++i;
            }
        }

        emit MultichainInitialized();
    }

    /// External Methods ///

    /// @notice Updates the tokenAddress > anyTokenAddress storage
    /// @param mappings A mapping of tokenAddress(es) to anyTokenAddress(es)
    function updateAddressMappings(AnyMapping[] calldata mappings) external {
        LibDiamond.enforceIsContractOwner();

        Storage storage s = getStorage();

        for (uint64 i; i < mappings.length; ) {
            s.anyTokenAddresses[mappings[i].tokenAddress] = mappings[i]
                .anyTokenAddress;
            unchecked {
                ++i;
            }
        }

        emit AnyMappingUpdated(mappings);
    }

    /// @notice (Batch) register routers
    /// @param routers Router addresses
    /// @param allowed Array of whether the addresses are allowed or not
    function registerRouters(
        address[] calldata routers,
        bool[] calldata allowed
    ) external {
        LibDiamond.enforceIsContractOwner();

        Storage storage s = getStorage();

        uint256 len = routers.length;
        for (uint256 i = 0; i < len; ) {
            if (routers[i] == address(0)) {
                revert InvalidConfig();
            }
            s.allowedRouters[routers[i]] = allowed[i];

            unchecked {
                ++i;
            }
        }
        emit MultichainRoutersUpdated(routers, allowed);
    }

    /// @notice Bridges tokens via Multichain
    /// @param _bridgeData the core information needed for bridging
    /// @param _multichainData data specific to Multichain
    function startBridgeTokensViaMultichain(
        ILiFi.BridgeData memory _bridgeData,
        MultichainData calldata _multichainData
    )
        external
        payable
        nonReentrant
        refundExcessNative(payable(msg.sender))
        doesNotContainSourceSwaps(_bridgeData)
        doesNotContainDestinationCalls(_bridgeData)
        validateBridgeData(_bridgeData)
    {
        Storage storage s = getStorage();
        if (!s.allowedRouters[_multichainData.router]) {
            revert InvalidRouter();
        }
        if (!LibAsset.isNativeAsset(_bridgeData.sendingAssetId))
            LibAsset.depositAsset(
                _bridgeData.sendingAssetId,
                _bridgeData.minAmount
            );

        _startBridge(_bridgeData, _multichainData);
    }

    /// @notice Performs a swap before bridging via Multichain
    /// @param _bridgeData the core information needed for bridging
    /// @param _swapData an array of swap related data for performing swaps before bridging
    /// @param _multichainData data specific to Multichain
    function swapAndStartBridgeTokensViaMultichain(
        ILiFi.BridgeData memory _bridgeData,
        LibSwap.SwapData[] calldata _swapData,
        MultichainData calldata _multichainData
    )
        external
        payable
        nonReentrant
        refundExcessNative(payable(msg.sender))
        containsSourceSwaps(_bridgeData)
        doesNotContainDestinationCalls(_bridgeData)
        validateBridgeData(_bridgeData)
    {
        Storage storage s = getStorage();

        if (!s.allowedRouters[_multichainData.router]) {
            revert InvalidRouter();
        }

        _bridgeData.minAmount = _depositAndSwap(
            _bridgeData.transactionId,
            _bridgeData.minAmount,
            _swapData,
            payable(msg.sender)
        );
        _startBridge(_bridgeData, _multichainData);
    }

    /// Private Methods ///

    /// @dev Contains the business logic for the bridge via Multichain
    /// @param _bridgeData the core information needed for bridging
    /// @param _multichainData data specific to Multichain
    function _startBridge(
        ILiFi.BridgeData memory _bridgeData,
        MultichainData calldata _multichainData
    ) private {
        // check if sendingAsset is a Multichain token that needs to be called directly in order to bridge it
        if (_multichainData.router == _bridgeData.sendingAssetId) {
            IMultichainERC20(_bridgeData.sendingAssetId).Swapout(
                _bridgeData.minAmount,
                _bridgeData.receiver
            );
        } else {
            Storage storage s = getStorage();
            if (LibAsset.isNativeAsset(_bridgeData.sendingAssetId)) {
                // call native asset bridge function
                IMultichainRouter(_multichainData.router).anySwapOutNative{
                    value: _bridgeData.minAmount
                }(
                    s.anyNative,
                    _bridgeData.receiver,
                    _bridgeData.destinationChainId
                );
            } else {
                // Give Multichain router approval to pull tokens
                LibAsset.maxApproveERC20(
                    IERC20(_bridgeData.sendingAssetId),
                    _multichainData.router,
                    _bridgeData.minAmount
                );

                address anyToken = s.anyTokenAddresses[
                    _bridgeData.sendingAssetId
                ];

                // replace tokenAddress with anyTokenAddress (if mapping found) and call ERC20 asset bridge function
                IMultichainRouter(_multichainData.router).anySwapOutUnderlying(
                    anyToken != address(0)
                        ? anyToken
                        : _bridgeData.sendingAssetId,
                    _bridgeData.receiver,
                    _bridgeData.minAmount,
                    _bridgeData.destinationChainId
                );
            }
        }

        emit LiFiTransferStarted(_bridgeData);
    }

    /// @dev fetch local storage
    function getStorage() private pure returns (Storage storage s) {
        bytes32 namespace = NAMESPACE;
        // solhint-disable-next-line no-inline-assembly
        assembly {
            s.slot := namespace
        }
    }
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import { ILiFi } from "../Interfaces/ILiFi.sol";
import { IOmniBridge } from "../Interfaces/IOmniBridge.sol";
import { LibAsset, IERC20 } from "../Libraries/LibAsset.sol";
import { ReentrancyGuard } from "../Helpers/ReentrancyGuard.sol";
import { SwapperV2, LibSwap } from "../Helpers/SwapperV2.sol";
import { Validatable } from "../Helpers/Validatable.sol";

/// @title OmniBridge Facet
/// @author LI.FI (https://li.fi)
/// @notice Provides functionality for bridging through OmniBridge
/// @custom:version 1.0.0
contract OmniBridgeFacet is ILiFi, ReentrancyGuard, SwapperV2, Validatable {
    /// Storage ///

    /// @notice The contract address of the foreign omni bridge on the source chain.
    IOmniBridge private immutable foreignOmniBridge;

    /// @notice The contract address of the weth omni bridge on the source chain.
    IOmniBridge private immutable wethOmniBridge;

    /// Constructor ///

    /// @notice Initialize the contract.
    /// @param _foreignOmniBridge The contract address of the foreign omni bridge on the source chain.
    /// @param _wethOmniBridge The contract address of the weth omni bridge on the source chain.
    constructor(IOmniBridge _foreignOmniBridge, IOmniBridge _wethOmniBridge) {
        foreignOmniBridge = _foreignOmniBridge;
        wethOmniBridge = _wethOmniBridge;
    }

    /// External Methods ///

    /// @notice Bridges tokens via OmniBridge
    /// @param _bridgeData Data contaning core information for bridging
    function startBridgeTokensViaOmniBridge(
        ILiFi.BridgeData memory _bridgeData
    )
        external
        payable
        nonReentrant
        refundExcessNative(payable(msg.sender))
        doesNotContainSourceSwaps(_bridgeData)
        doesNotContainDestinationCalls(_bridgeData)
        validateBridgeData(_bridgeData)
    {
        LibAsset.depositAsset(
            _bridgeData.sendingAssetId,
            _bridgeData.minAmount
        );
        _startBridge(_bridgeData);
    }

    /// @notice Performs a swap before bridging via OmniBridge
    /// @param _bridgeData Data contaning core information for bridging
    /// @param _swapData An array of swap related data for performing swaps before bridging
    function swapAndStartBridgeTokensViaOmniBridge(
        ILiFi.BridgeData memory _bridgeData,
        LibSwap.SwapData[] calldata _swapData
    )
        external
        payable
        nonReentrant
        refundExcessNative(payable(msg.sender))
        containsSourceSwaps(_bridgeData)
        doesNotContainDestinationCalls(_bridgeData)
        validateBridgeData(_bridgeData)
    {
        _bridgeData.minAmount = _depositAndSwap(
            _bridgeData.transactionId,
            _bridgeData.minAmount,
            _swapData,
            payable(msg.sender)
        );
        _startBridge(_bridgeData);
    }

    /// Private Methods ///

    /// @dev Contains the business logic for the bridge via OmniBridge
    /// @param _bridgeData Data contaning core information for bridging
    function _startBridge(ILiFi.BridgeData memory _bridgeData) private {
        if (LibAsset.isNativeAsset(_bridgeData.sendingAssetId)) {
            wethOmniBridge.wrapAndRelayTokens{ value: _bridgeData.minAmount }(
                _bridgeData.receiver
            );
        } else {
            LibAsset.maxApproveERC20(
                IERC20(_bridgeData.sendingAssetId),
                address(foreignOmniBridge),
                _bridgeData.minAmount
            );
            foreignOmniBridge.relayTokens(
                _bridgeData.sendingAssetId,
                _bridgeData.receiver,
                _bridgeData.minAmount
            );
        }

        emit LiFiTransferStarted(_bridgeData);
    }
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import { ILiFi } from "../Interfaces/ILiFi.sol";
import { IL1StandardBridge } from "../Interfaces/IL1StandardBridge.sol";
import { LibAsset, IERC20 } from "../Libraries/LibAsset.sol";
import { LibDiamond } from "../Libraries/LibDiamond.sol";
import { ReentrancyGuard } from "../Helpers/ReentrancyGuard.sol";
import { InvalidConfig, AlreadyInitialized, NotInitialized } from "../Errors/GenericErrors.sol";
import { SwapperV2, LibSwap } from "../Helpers/SwapperV2.sol";
import { Validatable } from "../Helpers/Validatable.sol";
import { LibUtil } from "../Libraries/LibUtil.sol";

/// @title Optimism Bridge Facet
/// @author Li.Finance (https://li.finance)
/// @notice Provides functionality for bridging through Optimism Bridge
/// @custom:version 1.0.0
contract OptimismBridgeFacet is
    ILiFi,
    ReentrancyGuard,
    SwapperV2,
    Validatable
{
    /// Storage ///

    bytes32 internal constant NAMESPACE =
        keccak256("com.lifi.facets.optimism");

    /// Types ///

    struct Storage {
        mapping(address => IL1StandardBridge) bridges;
        IL1StandardBridge standardBridge;
        bool initialized;
    }

    struct Config {
        address assetId;
        address bridge;
    }

    struct OptimismData {
        address assetIdOnL2;
        uint32 l2Gas;
        bool isSynthetix;
    }

    /// Events ///

    event OptimismInitialized(Config[] configs);
    event OptimismBridgeRegistered(address indexed assetId, address bridge);

    /// Init ///

    /// @notice Initialize local variables for the Optimism Bridge Facet
    /// @param configs Bridge configuration data
    function initOptimism(
        Config[] calldata configs,
        IL1StandardBridge standardBridge
    ) external {
        LibDiamond.enforceIsContractOwner();

        Storage storage s = getStorage();

        if (s.initialized) {
            revert AlreadyInitialized();
        }

        for (uint256 i = 0; i < configs.length; i++) {
            if (configs[i].bridge == address(0)) {
                revert InvalidConfig();
            }
            s.bridges[configs[i].assetId] = IL1StandardBridge(
                configs[i].bridge
            );
        }

        s.standardBridge = standardBridge;
        s.initialized = true;

        emit OptimismInitialized(configs);
    }

    /// External Methods ///

    /// @notice Register token and bridge
    /// @param assetId Address of token
    /// @param bridge Address of bridge for asset
    function registerOptimismBridge(address assetId, address bridge) external {
        LibDiamond.enforceIsContractOwner();

        Storage storage s = getStorage();

        if (!s.initialized) revert NotInitialized();

        if (bridge == address(0)) {
            revert InvalidConfig();
        }

        s.bridges[assetId] = IL1StandardBridge(bridge);

        emit OptimismBridgeRegistered(assetId, bridge);
    }

    /// @notice Bridges tokens via Optimism Bridge
    /// @param _bridgeData Data contaning core information for bridging
    /// @param _bridgeData Data specific to Optimism Bridge
    function startBridgeTokensViaOptimismBridge(
        ILiFi.BridgeData memory _bridgeData,
        OptimismData calldata _optimismData
    )
        external
        payable
        nonReentrant
        refundExcessNative(payable(msg.sender))
        doesNotContainSourceSwaps(_bridgeData)
        doesNotContainDestinationCalls(_bridgeData)
        validateBridgeData(_bridgeData)
    {
        LibAsset.depositAsset(
            _bridgeData.sendingAssetId,
            _bridgeData.minAmount
        );
        _startBridge(_bridgeData, _optimismData);
    }

    /// @notice Performs a swap before bridging via Optimism Bridge
    /// @param _bridgeData Data contaning core information for bridging
    /// @param _swapData An array of swap related data for performing swaps before bridging
    /// @param _bridgeData Data specific to Optimism Bridge
    function swapAndStartBridgeTokensViaOptimismBridge(
        ILiFi.BridgeData memory _bridgeData,
        LibSwap.SwapData[] calldata _swapData,
        OptimismData calldata _optimismData
    )
        external
        payable
        nonReentrant
        refundExcessNative(payable(msg.sender))
        containsSourceSwaps(_bridgeData)
        doesNotContainDestinationCalls(_bridgeData)
        validateBridgeData(_bridgeData)
    {
        _bridgeData.minAmount = _depositAndSwap(
            _bridgeData.transactionId,
            _bridgeData.minAmount,
            _swapData,
            payable(msg.sender)
        );
        _startBridge(_bridgeData, _optimismData);
    }

    /// Private Methods ///

    /// @dev Contains the business logic for the bridge via Optimism Bridge
    /// @param _bridgeData Data contaning core information for bridging
    /// @param _bridgeData Data specific to Optimism Bridge
    function _startBridge(
        ILiFi.BridgeData memory _bridgeData,
        OptimismData calldata _optimismData
    ) private {
        Storage storage s = getStorage();
        IL1StandardBridge nonStandardBridge = s.bridges[
            _bridgeData.sendingAssetId
        ];
        IL1StandardBridge bridge = LibUtil.isZeroAddress(
            address(nonStandardBridge)
        )
            ? s.standardBridge
            : nonStandardBridge;

        if (LibAsset.isNativeAsset(_bridgeData.sendingAssetId)) {
            bridge.depositETHTo{ value: _bridgeData.minAmount }(
                _bridgeData.receiver,
                _optimismData.l2Gas,
                ""
            );
        } else {
            LibAsset.maxApproveERC20(
                IERC20(_bridgeData.sendingAssetId),
                address(bridge),
                _bridgeData.minAmount
            );

            if (_optimismData.isSynthetix) {
                bridge.depositTo(_bridgeData.receiver, _bridgeData.minAmount);
            } else {
                bridge.depositERC20To(
                    _bridgeData.sendingAssetId,
                    _optimismData.assetIdOnL2,
                    _bridgeData.receiver,
                    _bridgeData.minAmount,
                    _optimismData.l2Gas,
                    ""
                );
            }
        }

        emit LiFiTransferStarted(_bridgeData);
    }

    /// @dev fetch local storage
    function getStorage() private pure returns (Storage storage s) {
        bytes32 namespace = NAMESPACE;
        // solhint-disable-next-line no-inline-assembly
        assembly {
            s.slot := namespace
        }
    }
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import { LibDiamond } from "../Libraries/LibDiamond.sol";
import { IERC173 } from "../Interfaces/IERC173.sol";
import { LibUtil } from "../Libraries/LibUtil.sol";
import { LibAsset } from "../Libraries/LibAsset.sol";

/// @title Ownership Facet
/// @author LI.FI (https://li.fi)
/// @notice Manages ownership of the LiFi Diamond contract for admin purposes
/// @custom:version 1.0.0
contract OwnershipFacet is IERC173 {
    /// Storage ///

    bytes32 internal constant NAMESPACE =
        keccak256("com.lifi.facets.ownership");

    /// Types ///

    struct Storage {
        address newOwner;
    }

    /// Errors ///

    error NoNullOwner();
    error NewOwnerMustNotBeSelf();
    error NoPendingOwnershipTransfer();
    error NotPendingOwner();

    /// Events ///

    event OwnershipTransferRequested(
        address indexed _from,
        address indexed _to
    );

    /// External Methods ///

    /// @notice Initiates transfer of ownership to a new address
    /// @param _newOwner the address to transfer ownership to
    function transferOwnership(address _newOwner) external override {
        LibDiamond.enforceIsContractOwner();
        Storage storage s = getStorage();

        if (LibUtil.isZeroAddress(_newOwner)) revert NoNullOwner();

        if (_newOwner == LibDiamond.contractOwner())
            revert NewOwnerMustNotBeSelf();

        s.newOwner = _newOwner;
        emit OwnershipTransferRequested(msg.sender, s.newOwner);
    }

    /// @notice Cancel transfer of ownership
    function cancelOwnershipTransfer() external {
        LibDiamond.enforceIsContractOwner();
        Storage storage s = getStorage();

        if (LibUtil.isZeroAddress(s.newOwner))
            revert NoPendingOwnershipTransfer();
        s.newOwner = address(0);
    }

    /// @notice Confirms transfer of ownership to the calling address (msg.sender)
    function confirmOwnershipTransfer() external {
        Storage storage s = getStorage();
        address _pendingOwner = s.newOwner;
        if (msg.sender != _pendingOwner) revert NotPendingOwner();
        emit OwnershipTransferred(LibDiamond.contractOwner(), _pendingOwner);
        LibDiamond.setContractOwner(_pendingOwner);
        s.newOwner = LibAsset.NULL_ADDRESS;
    }

    /// @notice Return the current owner address
    /// @return owner_ The current owner address
    function owner() external view override returns (address owner_) {
        owner_ = LibDiamond.contractOwner();
    }

    /// Private Methods ///

    /// @dev fetch local storage
    function getStorage() private pure returns (Storage storage s) {
        bytes32 namespace = NAMESPACE;
        // solhint-disable-next-line no-inline-assembly
        assembly {
            s.slot := namespace
        }
    }
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import { LibDiamond } from "../Libraries/LibDiamond.sol";

/// @title Periphery Registry Facet
/// @author LI.FI (https://li.fi)
/// @notice A simple registry to track LIFI periphery contracts
/// @custom:version 1.0.0
contract PeripheryRegistryFacet {
    /// Storage ///

    bytes32 internal constant NAMESPACE =
        keccak256("com.lifi.facets.periphery_registry");

    /// Types ///

    struct Storage {
        mapping(string => address) contracts;
    }

    /// Events ///

    event PeripheryContractRegistered(string name, address contractAddress);

    /// External Methods ///

    /// @notice Registers a periphery contract address with a specified name
    /// @param _name the name to register the contract address under
    /// @param _contractAddress the address of the contract to register
    function registerPeripheryContract(
        string calldata _name,
        address _contractAddress
    ) external {
        LibDiamond.enforceIsContractOwner();
        Storage storage s = getStorage();
        s.contracts[_name] = _contractAddress;
        emit PeripheryContractRegistered(_name, _contractAddress);
    }

    /// @notice Returns the registered contract address by its name
    /// @param _name the registered name of the contract
    function getPeripheryContract(
        string calldata _name
    ) external view returns (address) {
        return getStorage().contracts[_name];
    }

    /// @dev fetch local storage
    function getStorage() private pure returns (Storage storage s) {
        bytes32 namespace = NAMESPACE;
        // solhint-disable-next-line no-inline-assembly
        assembly {
            s.slot := namespace
        }
    }
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import { ILiFi } from "../Interfaces/ILiFi.sol";
import { IRootChainManager } from "../Interfaces/IRootChainManager.sol";
import { LibAsset, IERC20 } from "../Libraries/LibAsset.sol";
import { ReentrancyGuard } from "../Helpers/ReentrancyGuard.sol";
import { SwapperV2, LibSwap } from "../Helpers/SwapperV2.sol";
import { Validatable } from "../Helpers/Validatable.sol";

/// @title Polygon Bridge Facet
/// @author Li.Finance (https://li.finance)
/// @notice Provides functionality for bridging through Polygon Bridge
/// @custom:version 1.0.0
contract PolygonBridgeFacet is ILiFi, ReentrancyGuard, SwapperV2, Validatable {
    /// Storage ///

    /// @notice The contract address of the RootChainManager on the source chain.
    IRootChainManager private immutable rootChainManager;

    /// @notice The contract address of the ERC20Predicate on the source chain.
    address private immutable erc20Predicate;

    /// Constructor ///

    /// @notice Initialize the contract.
    /// @param _rootChainManager The contract address of the RootChainManager on the source chain.
    /// @param _erc20Predicate The contract address of the ERC20Predicate on the source chain.
    constructor(IRootChainManager _rootChainManager, address _erc20Predicate) {
        rootChainManager = _rootChainManager;
        erc20Predicate = _erc20Predicate;
    }

    /// External Methods ///

    /// @notice Bridges tokens via Polygon Bridge
    /// @param _bridgeData Data containing core information for bridging
    function startBridgeTokensViaPolygonBridge(
        ILiFi.BridgeData memory _bridgeData
    )
        external
        payable
        nonReentrant
        refundExcessNative(payable(msg.sender))
        doesNotContainSourceSwaps(_bridgeData)
        doesNotContainDestinationCalls(_bridgeData)
        validateBridgeData(_bridgeData)
    {
        LibAsset.depositAsset(
            _bridgeData.sendingAssetId,
            _bridgeData.minAmount
        );
        _startBridge(_bridgeData);
    }

    /// @notice Performs a swap before bridging via Polygon Bridge
    /// @param _bridgeData Data containing core information for bridging
    /// @param _swapData An array of swap related data for performing swaps before bridging
    function swapAndStartBridgeTokensViaPolygonBridge(
        ILiFi.BridgeData memory _bridgeData,
        LibSwap.SwapData[] calldata _swapData
    )
        external
        payable
        nonReentrant
        refundExcessNative(payable(msg.sender))
        containsSourceSwaps(_bridgeData)
        doesNotContainDestinationCalls(_bridgeData)
        validateBridgeData(_bridgeData)
    {
        _bridgeData.minAmount = _depositAndSwap(
            _bridgeData.transactionId,
            _bridgeData.minAmount,
            _swapData,
            payable(msg.sender)
        );
        _startBridge(_bridgeData);
    }

    /// Private Methods ///

    /// @dev Contains the business logic for the bridge via Polygon Bridge
    /// @param _bridgeData Data containing core information for bridging
    function _startBridge(ILiFi.BridgeData memory _bridgeData) private {
        address childToken;

        if (LibAsset.isNativeAsset(_bridgeData.sendingAssetId)) {
            rootChainManager.depositEtherFor{ value: _bridgeData.minAmount }(
                _bridgeData.receiver
            );
        } else {
            childToken = rootChainManager.rootToChildToken(
                _bridgeData.sendingAssetId
            );

            LibAsset.maxApproveERC20(
                IERC20(_bridgeData.sendingAssetId),
                erc20Predicate,
                _bridgeData.minAmount
            );

            bytes memory depositData = abi.encode(_bridgeData.minAmount);
            rootChainManager.depositFor(
                _bridgeData.receiver,
                _bridgeData.sendingAssetId,
                depositData
            );
        }

        emit LiFiTransferStarted(_bridgeData);
    }
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import { LibDiamond } from "../Libraries/LibDiamond.sol";

/// @title Standardized Call Facet
/// @author LIFI https://li.finance ed@li.finance
/// @notice Allows calling different facet methods through a single standardized entrypoint
/// @custom:version 1.0.0
contract StandardizedCallFacet {
    /// External Methods ///

    /// @notice Make a standardized call to a facet
    /// @param callData The calldata to forward to the facet
    function standardizedCall(bytes memory callData) external payable {
        // Fetch the facetAddress from the dimaond's internal storage
        // Cheaper than calling the external facetAddress(selector) method directly
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        address facetAddress = ds
            .selectorToFacetAndPosition[bytes4(callData)]
            .facetAddress;

        if (facetAddress == address(0)) {
            revert LibDiamond.FunctionDoesNotExist();
        }

        // Execute external function from facet using delegatecall and return any value.
        // solhint-disable-next-line no-inline-assembly
        assembly {
            // execute function call using the facet
            let result := delegatecall(
                gas(),
                facetAddress,
                add(callData, 0x20),
                mload(callData),
                0,
                0
            )
            // get any return value
            returndatacopy(0, 0, returndatasize())
            // return any return value or error back to the caller
            switch result
            case 0 {
                revert(0, returndatasize())
            }
            default {
                return(0, returndatasize())
            }
        }
    }
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import { ILiFi } from "../Interfaces/ILiFi.sol";
import { IStargateRouter } from "../Interfaces/IStargateRouter.sol";
import { LibAsset, IERC20 } from "../Libraries/LibAsset.sol";
import { LibDiamond } from "../Libraries/LibDiamond.sol";
import { ReentrancyGuard } from "../Helpers/ReentrancyGuard.sol";
import { InformationMismatch, AlreadyInitialized, NotInitialized } from "../Errors/GenericErrors.sol";
import { SwapperV2, LibSwap } from "../Helpers/SwapperV2.sol";
import { Validatable } from "../Helpers/Validatable.sol";

/// @title Stargate Facet
/// @author Li.Finance (https://li.finance)
/// @notice Provides functionality for bridging through Stargate
/// @custom:version 2.2.0
contract StargateFacet is ILiFi, ReentrancyGuard, SwapperV2, Validatable {
    /// CONSTANTS ///

    /// @notice The contract address of the stargate composer on the source chain.
    IStargateRouter private immutable composer;

    /// Storage ///

    bytes32 internal constant NAMESPACE =
        keccak256("com.lifi.facets.stargate");

    /// Types ///

    struct Storage {
        mapping(uint256 => uint16) layerZeroChainId;
        bool initialized;
    }

    struct ChainIdConfig {
        uint256 chainId;
        uint16 layerZeroChainId;
    }

    /// @param srcPoolId Source pool id.
    /// @param dstPoolId Dest pool id.
    /// @param minAmountLD The min qty you would accept on the destination.
    /// @param dstGasForCall Additional gas fee for extral call on the destination.
    /// @param lzFee Estimated message fee.
    /// @param refundAddress Refund adddress. Extra gas (if any) is returned to this address
    /// @param callTo The address to send the tokens to on the destination.
    /// @param callData Additional payload.
    struct StargateData {
        uint256 srcPoolId;
        uint256 dstPoolId;
        uint256 minAmountLD;
        uint256 dstGasForCall;
        uint256 lzFee;
        address payable refundAddress;
        bytes callTo;
        bytes callData;
    }

    /// Errors ///

    error UnknownLayerZeroChain();

    /// Events ///

    event StargateInitialized(ChainIdConfig[] chainIdConfigs);

    event LayerZeroChainIdSet(
        uint256 indexed chainId,
        uint16 layerZeroChainId
    );

    /// @notice Emit to get credited for referral
    /// @dev Our partner id is 0x0006
    event PartnerSwap(bytes2 partnerId);

    /// Constructor ///

    /// @notice Initialize the contract.
    /// @param _composer The contract address of the stargate composer router on the source chain.
    constructor(IStargateRouter _composer) {
        composer = _composer;
    }

    /// Init ///

    /// @notice Initialize local variables for the Stargate Facet
    /// @param chainIdConfigs Chain Id configuration data
    function initStargate(ChainIdConfig[] calldata chainIdConfigs) external {
        LibDiamond.enforceIsContractOwner();

        Storage storage sm = getStorage();

        for (uint256 i = 0; i < chainIdConfigs.length; i++) {
            sm.layerZeroChainId[chainIdConfigs[i].chainId] = chainIdConfigs[i]
                .layerZeroChainId;
        }

        sm.initialized = true;

        emit StargateInitialized(chainIdConfigs);
    }

    /// External Methods ///

    /// @notice Bridges tokens via Stargate Bridge
    /// @param _bridgeData Data used purely for tracking and analytics
    /// @param _stargateData Data specific to Stargate Bridge
    function startBridgeTokensViaStargate(
        ILiFi.BridgeData calldata _bridgeData,
        StargateData calldata _stargateData
    )
        external
        payable
        nonReentrant
        refundExcessNative(payable(msg.sender))
        doesNotContainSourceSwaps(_bridgeData)
        validateBridgeData(_bridgeData)
    {
        validateDestinationCallFlag(_bridgeData, _stargateData);
        LibAsset.depositAsset(
            _bridgeData.sendingAssetId,
            _bridgeData.minAmount
        );
        _startBridge(_bridgeData, _stargateData);
    }

    /// @notice Performs a swap before bridging via Stargate Bridge
    /// @param _bridgeData Data used purely for tracking and analytics
    /// @param _swapData An array of swap related data for performing swaps before bridging
    /// @param _stargateData Data specific to Stargate Bridge
    function swapAndStartBridgeTokensViaStargate(
        ILiFi.BridgeData memory _bridgeData,
        LibSwap.SwapData[] calldata _swapData,
        StargateData calldata _stargateData
    )
        external
        payable
        nonReentrant
        refundExcessNative(payable(msg.sender))
        containsSourceSwaps(_bridgeData)
        validateBridgeData(_bridgeData)
    {
        validateDestinationCallFlag(_bridgeData, _stargateData);
        _bridgeData.minAmount = _depositAndSwap(
            _bridgeData.transactionId,
            _bridgeData.minAmount,
            _swapData,
            payable(msg.sender),
            LibAsset.isNativeAsset(_bridgeData.sendingAssetId)
                ? 0
                : _stargateData.lzFee
        );

        _startBridge(_bridgeData, _stargateData);
    }

    function quoteLayerZeroFee(
        uint256 _destinationChainId,
        StargateData calldata _stargateData
    ) external view returns (uint256, uint256) {
        return
            composer.quoteLayerZeroFee(
                getLayerZeroChainId(_destinationChainId),
                1, // TYPE_SWAP_REMOTE on Bridge
                _stargateData.callTo,
                _stargateData.callData,
                IStargateRouter.lzTxObj(
                    _stargateData.dstGasForCall,
                    0,
                    toBytes(address(0))
                )
            );
    }

    /// Private Methods ///

    /// @dev Contains the business logic for the bridge via Stargate Bridge
    /// @param _bridgeData Data used purely for tracking and analytics
    /// @param _stargateData Data specific to Stargate Bridge
    function _startBridge(
        ILiFi.BridgeData memory _bridgeData,
        StargateData calldata _stargateData
    ) private {
        if (LibAsset.isNativeAsset(_bridgeData.sendingAssetId)) {
            composer.swapETHAndCall{ value: _bridgeData.minAmount }(
                getLayerZeroChainId(_bridgeData.destinationChainId),
                _stargateData.refundAddress,
                _stargateData.callTo,
                IStargateRouter.SwapAmount(
                    _bridgeData.minAmount - _stargateData.lzFee,
                    _stargateData.minAmountLD
                ),
                IStargateRouter.lzTxObj(
                    _stargateData.dstGasForCall,
                    0,
                    toBytes(address(0))
                ),
                _stargateData.callData
            );
        } else {
            LibAsset.maxApproveERC20(
                IERC20(_bridgeData.sendingAssetId),
                address(composer),
                _bridgeData.minAmount
            );

            composer.swap{ value: _stargateData.lzFee }(
                getLayerZeroChainId(_bridgeData.destinationChainId),
                _stargateData.srcPoolId,
                _stargateData.dstPoolId,
                _stargateData.refundAddress,
                _bridgeData.minAmount,
                _stargateData.minAmountLD,
                IStargateRouter.lzTxObj(
                    _stargateData.dstGasForCall,
                    0,
                    toBytes(address(0))
                ),
                _stargateData.callTo,
                _stargateData.callData
            );
        }

        emit PartnerSwap(0x0006);

        emit LiFiTransferStarted(_bridgeData);
    }

    function validateDestinationCallFlag(
        ILiFi.BridgeData memory _bridgeData,
        StargateData calldata _stargateData
    ) private pure {
        if (
            (_stargateData.callData.length > 0) !=
            _bridgeData.hasDestinationCall
        ) {
            revert InformationMismatch();
        }
    }

    /// Mappings management ///

    /// @notice Sets the Layer 0 chain ID for a given chain ID
    /// @param _chainId uint16 of the chain ID
    /// @param _layerZeroChainId uint16 of the Layer 0 chain ID
    /// @dev This is used to map a chain ID to its Layer 0 chain ID
    function setLayerZeroChainId(
        uint256 _chainId,
        uint16 _layerZeroChainId
    ) external {
        LibDiamond.enforceIsContractOwner();
        Storage storage sm = getStorage();

        if (!sm.initialized) {
            revert NotInitialized();
        }

        sm.layerZeroChainId[_chainId] = _layerZeroChainId;
        emit LayerZeroChainIdSet(_chainId, _layerZeroChainId);
    }

    /// @notice Gets the Layer 0 chain ID for a given chain ID
    /// @param _chainId uint256 of the chain ID
    /// @return uint16 of the Layer 0 chain ID
    function getLayerZeroChainId(
        uint256 _chainId
    ) private view returns (uint16) {
        Storage storage sm = getStorage();
        uint16 chainId = sm.layerZeroChainId[_chainId];
        if (chainId == 0) revert UnknownLayerZeroChain();
        return chainId;
    }

    function toBytes(address _address) private pure returns (bytes memory) {
        return abi.encodePacked(_address);
    }

    /// @dev fetch local storage
    function getStorage() private pure returns (Storage storage s) {
        bytes32 namespace = NAMESPACE;
        // solhint-disable-next-line no-inline-assembly
        assembly {
            s.slot := namespace
        }
    }
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import { ILiFi } from "../Interfaces/ILiFi.sol";
import { ISynapseRouter } from "../Interfaces/ISynapseRouter.sol";
import { LibAsset, IERC20 } from "../Libraries/LibAsset.sol";
import { ReentrancyGuard } from "../Helpers/ReentrancyGuard.sol";
import { SwapperV2, LibSwap } from "../Helpers/SwapperV2.sol";
import { Validatable } from "../Helpers/Validatable.sol";

/// @title SynapseBridge Facet
/// @author LI.FI (https://li.fi)
/// @notice Provides functionality for bridging through SynapseBridge
/// @custom:version 1.0.0
contract SynapseBridgeFacet is ILiFi, ReentrancyGuard, SwapperV2, Validatable {
    /// Storage ///

    address internal constant NETH_ADDRESS =
        0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;

    /// @notice The contract address of the SynapseRouter on the source chain.
    ISynapseRouter private immutable synapseRouter;

    /// Types ///

    /// @param originQuery Origin swap query. Empty struct indicates no swap is required.
    /// @param destQuery Destination swap query. Empty struct indicates no swap is required.
    struct SynapseData {
        ISynapseRouter.SwapQuery originQuery;
        ISynapseRouter.SwapQuery destQuery;
    }

    /// Constructor ///

    /// @notice Initialize the contract.
    /// @param _synapseRouter The contract address of the SynapseRouter on the source chain.
    constructor(ISynapseRouter _synapseRouter) {
        synapseRouter = _synapseRouter;
    }

    /// External Methods ///

    /// @notice Bridges tokens via Synapse Bridge
    /// @param _bridgeData the core information needed for bridging
    /// @param _synapseData data specific to Synapse Bridge
    function startBridgeTokensViaSynapseBridge(
        ILiFi.BridgeData calldata _bridgeData,
        SynapseData calldata _synapseData
    )
        external
        payable
        nonReentrant
        refundExcessNative(payable(msg.sender))
        validateBridgeData(_bridgeData)
        doesNotContainSourceSwaps(_bridgeData)
        doesNotContainDestinationCalls(_bridgeData)
    {
        LibAsset.depositAsset(
            _bridgeData.sendingAssetId,
            _bridgeData.minAmount
        );

        _startBridge(_bridgeData, _synapseData);
    }

    /// @notice Performs a swap before bridging via Synapse Bridge
    /// @param _bridgeData the core information needed for bridging
    /// @param _swapData an array of swap related data for performing swaps before bridging
    /// @param _synapseData data specific to Synapse Bridge
    function swapAndStartBridgeTokensViaSynapseBridge(
        ILiFi.BridgeData memory _bridgeData,
        LibSwap.SwapData[] calldata _swapData,
        SynapseData calldata _synapseData
    )
        external
        payable
        nonReentrant
        refundExcessNative(payable(msg.sender))
        containsSourceSwaps(_bridgeData)
        doesNotContainDestinationCalls(_bridgeData)
        validateBridgeData(_bridgeData)
    {
        _bridgeData.minAmount = _depositAndSwap(
            _bridgeData.transactionId,
            _bridgeData.minAmount,
            _swapData,
            payable(msg.sender)
        );

        _startBridge(_bridgeData, _synapseData);
    }

    /// Internal Methods ///

    /// @dev Contains the business logic for the bridge via Synapse Bridge
    /// @param _bridgeData the core information needed for bridging
    /// @param _synapseData data specific to Synapse Bridge
    function _startBridge(
        ILiFi.BridgeData memory _bridgeData,
        SynapseData calldata _synapseData
    ) internal {
        uint256 nativeAssetAmount;
        address sendingAssetId = _bridgeData.sendingAssetId;

        if (LibAsset.isNativeAsset(_bridgeData.sendingAssetId)) {
            nativeAssetAmount = _bridgeData.minAmount;
            sendingAssetId = NETH_ADDRESS;
        } else {
            LibAsset.maxApproveERC20(
                IERC20(_bridgeData.sendingAssetId),
                address(synapseRouter),
                _bridgeData.minAmount
            );
        }

        synapseRouter.bridge{ value: nativeAssetAmount }(
            _bridgeData.receiver,
            _bridgeData.destinationChainId,
            sendingAssetId,
            _bridgeData.minAmount,
            _synapseData.originQuery,
            _synapseData.destQuery
        );

        emit LiFiTransferStarted(_bridgeData);
    }
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import { LibDiamond } from "../Libraries/LibDiamond.sol";
import { LibUtil } from "../Libraries/LibUtil.sol";
import { LibAsset } from "../Libraries/LibAsset.sol";
import { LibAccess } from "../Libraries/LibAccess.sol";
import { NotAContract } from "../Errors/GenericErrors.sol";

/// @title Withdraw Facet
/// @author LI.FI (https://li.fi)
/// @notice Allows admin to withdraw funds that are kept in the contract by accident
/// @custom:version 1.0.0
contract WithdrawFacet {
    /// Errors ///

    error WithdrawFailed();

    /// Events ///

    event LogWithdraw(
        address indexed _assetAddress,
        address _to,
        uint256 amount
    );

    /// External Methods ///

    /// @notice Execute call data and withdraw asset.
    /// @param _callTo The address to execute the calldata on.
    /// @param _callData The data to execute.
    /// @param _assetAddress Asset to be withdrawn.
    /// @param _to address to withdraw to.
    /// @param _amount amount of asset to withdraw.
    function executeCallAndWithdraw(
        address payable _callTo,
        bytes calldata _callData,
        address _assetAddress,
        address _to,
        uint256 _amount
    ) external {
        if (msg.sender != LibDiamond.contractOwner()) {
            LibAccess.enforceAccessControl();
        }

        // Check if the _callTo is a contract
        bool success;
        bool isContract = LibAsset.isContract(_callTo);
        if (!isContract) revert NotAContract();

        // solhint-disable-next-line avoid-low-level-calls
        (success, ) = _callTo.call(_callData);

        if (success) {
            _withdrawAsset(_assetAddress, _to, _amount);
        } else {
            revert WithdrawFailed();
        }
    }

    /// @notice Withdraw asset.
    /// @param _assetAddress Asset to be withdrawn.
    /// @param _to address to withdraw to.
    /// @param _amount amount of asset to withdraw.
    function withdraw(
        address _assetAddress,
        address _to,
        uint256 _amount
    ) external {
        if (msg.sender != LibDiamond.contractOwner()) {
            LibAccess.enforceAccessControl();
        }
        _withdrawAsset(_assetAddress, _to, _amount);
    }

    /// Internal Methods ///

    /// @notice Withdraw asset.
    /// @param _assetAddress Asset to be withdrawn.
    /// @param _to address to withdraw to.
    /// @param _amount amount of asset to withdraw.
    function _withdrawAsset(
        address _assetAddress,
        address _to,
        uint256 _amount
    ) internal {
        address sendTo = (LibUtil.isZeroAddress(_to)) ? msg.sender : _to;
        LibAsset.transferAsset(_assetAddress, payable(sendTo), _amount);
        emit LogWithdraw(_assetAddress, sendTo, _amount);
    }
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "../../lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import { ILiFi } from "../Interfaces/ILiFi.sol";
import { IWormholeRouter } from "../Interfaces/IWormholeRouter.sol";
import { LibDiamond } from "../Libraries/LibDiamond.sol";
import { LibAsset } from "../Libraries/LibAsset.sol";
import { LibSwap } from "../Libraries/LibSwap.sol";
import { ReentrancyGuard } from "../Helpers/ReentrancyGuard.sol";
import { UnsupportedChainId, AlreadyInitialized, NotInitialized } from "../Errors/GenericErrors.sol";
import { SwapperV2 } from "../Helpers/SwapperV2.sol";
import { Validatable } from "../Helpers/Validatable.sol";

/// @title Wormhole Facet
/// @author LI.FI (https://li.fi)
/// @notice Provides functionality for bridging through Wormhole
/// @custom:version 1.0.0
contract WormholeFacet is ILiFi, ReentrancyGuard, SwapperV2, Validatable {
    /// Storage ///

    bytes32 internal constant NAMESPACE =
        keccak256("com.lifi.facets.wormhole");
    address internal constant NON_EVM_ADDRESS =
        0x11f111f111f111F111f111f111F111f111f111F1;

    /// @notice The contract address of the wormhole router on the source chain.
    IWormholeRouter private immutable router;

    /// Types ///

    struct Storage {
        mapping(uint256 => uint16) wormholeChainId;
        bool initialized;
    }

    struct Config {
        uint256 chainId;
        uint16 wormholeChainId;
    }

    /// @param receiver The address of the token receiver after bridging.
    /// @param arbiterFee The amount of token to pay a relayer (can be zero if no relayer is used).
    /// @param nonce A random nonce to associate with the tx.
    struct WormholeData {
        bytes32 receiver;
        uint256 arbiterFee;
        uint32 nonce;
    }

    /// Events ///

    event WormholeInitialized(Config[] configs);
    event WormholeChainIdMapped(
        uint256 indexed lifiChainId,
        uint256 indexed wormholeChainId
    );
    event WormholeChainIdsMapped(Config[] configs);
    event BridgeToNonEVMChain(
        bytes32 indexed transactionId,
        uint256 indexed wormholeChainId,
        bytes32 receiver
    );

    /// Constructor ///

    /// @notice Initialize the contract.
    /// @param _router The contract address of the wormhole router on the source chain.
    constructor(IWormholeRouter _router) {
        router = _router;
    }

    /// Init ///

    /// @notice Initialize local variables for the Wormhole Facet
    /// @param configs Bridge configuration data
    function initWormhole(Config[] calldata configs) external {
        LibDiamond.enforceIsContractOwner();

        Storage storage sm = getStorage();

        if (sm.initialized) {
            revert AlreadyInitialized();
        }

        uint256 numConfigs = configs.length;
        for (uint256 i = 0; i < numConfigs; i++) {
            sm.wormholeChainId[configs[i].chainId] = configs[i]
                .wormholeChainId;
        }

        sm.initialized = true;

        emit WormholeInitialized(configs);
    }

    /// External Methods ///

    /// @notice Bridges tokens via Wormhole
    /// @param _bridgeData the core information needed for bridging
    /// @param _wormholeData data specific to Wormhole
    function startBridgeTokensViaWormhole(
        ILiFi.BridgeData memory _bridgeData,
        WormholeData calldata _wormholeData
    )
        external
        payable
        nonReentrant
        refundExcessNative(payable(msg.sender))
        doesNotContainSourceSwaps(_bridgeData)
        doesNotContainDestinationCalls(_bridgeData)
        validateBridgeData(_bridgeData)
    {
        LibAsset.depositAsset(
            _bridgeData.sendingAssetId,
            _bridgeData.minAmount
        );
        _startBridge(_bridgeData, _wormholeData);
    }

    /// @notice Performs a swap before bridging via Wormhole
    /// @param _bridgeData the core information needed for bridging
    /// @param _swapData an array of swap related data for performing swaps before bridging
    /// @param _wormholeData data specific to Wormhole
    function swapAndStartBridgeTokensViaWormhole(
        ILiFi.BridgeData memory _bridgeData,
        LibSwap.SwapData[] calldata _swapData,
        WormholeData calldata _wormholeData
    )
        external
        payable
        nonReentrant
        refundExcessNative(payable(msg.sender))
        containsSourceSwaps(_bridgeData)
        doesNotContainDestinationCalls(_bridgeData)
        validateBridgeData(_bridgeData)
    {
        _bridgeData.minAmount = _depositAndSwap(
            _bridgeData.transactionId,
            _bridgeData.minAmount,
            _swapData,
            payable(msg.sender)
        );
        _startBridge(_bridgeData, _wormholeData);
    }

    /// @notice Creates a mapping between a lifi chain id and a wormhole chain id
    /// @param _lifiChainId lifi chain id
    /// @param _wormholeChainId wormhole chain id
    function setWormholeChainId(
        uint256 _lifiChainId,
        uint16 _wormholeChainId
    ) external {
        LibDiamond.enforceIsContractOwner();
        Storage storage sm = getStorage();
        sm.wormholeChainId[_lifiChainId] = _wormholeChainId;
        emit WormholeChainIdMapped(_lifiChainId, _wormholeChainId);
    }

    /// @notice Creates mappings between chain ids and wormhole chain ids
    /// @param configs Bridge configuration data
    function setWormholeChainIds(Config[] calldata configs) external {
        LibDiamond.enforceIsContractOwner();

        Storage storage sm = getStorage();

        if (!sm.initialized) {
            revert NotInitialized();
        }

        uint256 numConfigs = configs.length;
        for (uint256 i = 0; i < numConfigs; i++) {
            sm.wormholeChainId[configs[i].chainId] = configs[i]
                .wormholeChainId;
        }

        emit WormholeChainIdsMapped(configs);
    }

    /// Private Methods ///

    /// @dev Contains the business logic for the bridge via Wormhole
    /// @param _bridgeData the core information needed for bridging
    /// @param _wormholeData data specific to Wormhole
    function _startBridge(
        ILiFi.BridgeData memory _bridgeData,
        WormholeData calldata _wormholeData
    ) private {
        uint16 toWormholeChainId = getWormholeChainId(
            _bridgeData.destinationChainId
        );
        uint16 fromWormholeChainId = getWormholeChainId(block.chainid);

        {
            if (toWormholeChainId == 0)
                revert UnsupportedChainId(_bridgeData.destinationChainId);
            if (fromWormholeChainId == 0)
                revert UnsupportedChainId(block.chainid);
        }

        LibAsset.maxApproveERC20(
            IERC20(_bridgeData.sendingAssetId),
            address(router),
            _bridgeData.minAmount
        );

        if (LibAsset.isNativeAsset(_bridgeData.sendingAssetId)) {
            router.wrapAndTransferETH{ value: _bridgeData.minAmount }(
                toWormholeChainId,
                _wormholeData.receiver,
                _wormholeData.arbiterFee,
                _wormholeData.nonce
            );
        } else {
            router.transferTokens(
                _bridgeData.sendingAssetId,
                _bridgeData.minAmount,
                toWormholeChainId,
                _wormholeData.receiver,
                _wormholeData.arbiterFee,
                _wormholeData.nonce
            );
        }

        if (_bridgeData.receiver == NON_EVM_ADDRESS) {
            emit BridgeToNonEVMChain(
                _bridgeData.transactionId,
                toWormholeChainId,
                _wormholeData.receiver
            );
        }

        emit LiFiTransferStarted(_bridgeData);
    }

    /// @notice Gets the wormhole chain id for a given lifi chain id
    /// @param _lifiChainId uint256 of the lifi chain ID
    /// @return uint16 of the wormhole chain id
    function getWormholeChainId(
        uint256 _lifiChainId
    ) private view returns (uint16) {
        Storage storage sm = getStorage();
        uint16 wormholeChainId = sm.wormholeChainId[_lifiChainId];
        if (wormholeChainId == 0) revert UnsupportedChainId(_lifiChainId);
        return wormholeChainId;
    }

    /// @dev fetch local storage
    function getStorage() private pure returns (Storage storage s) {
        bytes32 namespace = NAMESPACE;
        // solhint-disable-next-line no-inline-assembly
        assembly {
            s.slot := namespace
        }
    }
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "../../lib/openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol";
import { LibAsset, IERC20 } from "../Libraries/LibAsset.sol";
import { ERC20 } from "../../lib/solmate/src/tokens/ERC20.sol";
import { ILiFi } from "../Interfaces/ILiFi.sol";
import { ReentrancyGuard } from "../Helpers/ReentrancyGuard.sol";
import { SwapperV2, LibSwap } from "../Helpers/SwapperV2.sol";
import { InvalidAmount, InformationMismatch } from "../Errors/GenericErrors.sol";
import { Validatable } from "../Helpers/Validatable.sol";
import { MessageSenderLib, MsgDataTypes, IMessageBus } from "../../lib/sgn-v2-contracts/contracts/message/libraries/MessageSenderLib.sol";
import { RelayerCelerIM } from "../../src/Periphery/RelayerCelerIM.sol";

interface CelerToken {
    function canonical() external returns (address);
}

interface CelerIM {
    /// @param maxSlippage The max slippage accepted, given as percentage in point (pip).
    /// @param nonce A number input to guarantee uniqueness of transferId. Can be timestamp in practice.
    /// @param callTo The address of the contract to be called at destination.
    /// @param callData The encoded calldata with below data
    ///                 bytes32 transactionId,
    ///                 LibSwap.SwapData[] memory swapData,
    ///                 address receiver,
    ///                 address refundAddress
    /// @param messageBusFee The fee to be paid to CBridge message bus for relaying the message
    /// @param bridgeType Defines the bridge operation type (must be one of the values of CBridge library MsgDataTypes.BridgeSendType)
    struct CelerIMData {
        uint32 maxSlippage;
        uint64 nonce;
        bytes callTo;
        bytes callData;
        uint256 messageBusFee;
        MsgDataTypes.BridgeSendType bridgeType;
    }
}

/// @title CelerIM Facet Base
/// @author LI.FI (https://li.fi)
/// @notice Provides functionality for bridging tokens and data through CBridge
/// @notice Used to differentiate between contract instances for mutable and immutable diamond as these cannot be shared
/// @custom:version 2.0.0
abstract contract CelerIMFacetBase is
    ILiFi,
    ReentrancyGuard,
    SwapperV2,
    Validatable
{
    /// Storage ///

    /// @dev The contract address of the cBridge Message Bus
    IMessageBus private immutable cBridgeMessageBus;

    /// @dev The contract address of the RelayerCelerIM
    RelayerCelerIM public immutable relayer;

    /// @dev The contract address of the Celer Flow USDC
    address private immutable cfUSDC;

    /// Constructor ///

    /// @notice Initialize the contract.
    /// @param _messageBus The contract address of the cBridge Message Bus
    /// @param _relayerOwner The address that will become the owner of the RelayerCelerIM contract
    /// @param _diamondAddress The address of the diamond contract that will be connected with the RelayerCelerIM
    /// @param _cfUSDC The contract address of the Celer Flow USDC
    constructor(
        IMessageBus _messageBus,
        address _relayerOwner,
        address _diamondAddress,
        address _cfUSDC
    ) {
        // deploy RelayerCelerIM
        relayer = new RelayerCelerIM(
            address(_messageBus),
            _relayerOwner,
            _diamondAddress
        );

        // store arguments in variables
        cBridgeMessageBus = _messageBus;
        cfUSDC = _cfUSDC;
    }

    /// External Methods ///

    /// @notice Bridges tokens via CBridge
    /// @param _bridgeData The core information needed for bridging
    /// @param _celerIMData Data specific to CelerIM
    function startBridgeTokensViaCelerIM(
        ILiFi.BridgeData memory _bridgeData,
        CelerIM.CelerIMData calldata _celerIMData
    )
        external
        payable
        nonReentrant
        refundExcessNative(payable(msg.sender))
        doesNotContainSourceSwaps(_bridgeData)
        validateBridgeData(_bridgeData)
    {
        validateDestinationCallFlag(_bridgeData, _celerIMData);
        if (!LibAsset.isNativeAsset(_bridgeData.sendingAssetId)) {
            // Transfer ERC20 tokens directly to relayer
            IERC20 asset = _getRightAsset(_bridgeData.sendingAssetId);

            // Deposit ERC20 token
            uint256 prevBalance = asset.balanceOf(address(relayer));
            SafeERC20.safeTransferFrom(
                asset,
                msg.sender,
                address(relayer),
                _bridgeData.minAmount
            );

            if (
                asset.balanceOf(address(relayer)) - prevBalance !=
                _bridgeData.minAmount
            ) {
                revert InvalidAmount();
            }
        }

        _startBridge(_bridgeData, _celerIMData);
    }

    /// @notice Performs a swap before bridging via CBridge
    /// @param _bridgeData The core information needed for bridging
    /// @param _swapData An array of swap related data for performing swaps before bridging
    /// @param _celerIMData Data specific to CelerIM
    function swapAndStartBridgeTokensViaCelerIM(
        ILiFi.BridgeData memory _bridgeData,
        LibSwap.SwapData[] calldata _swapData,
        CelerIM.CelerIMData calldata _celerIMData
    )
        external
        payable
        nonReentrant
        refundExcessNative(payable(msg.sender))
        containsSourceSwaps(_bridgeData)
        validateBridgeData(_bridgeData)
    {
        validateDestinationCallFlag(_bridgeData, _celerIMData);

        _bridgeData.minAmount = _depositAndSwap(
            _bridgeData.transactionId,
            _bridgeData.minAmount,
            _swapData,
            payable(msg.sender),
            _celerIMData.messageBusFee
        );

        if (!LibAsset.isNativeAsset(_bridgeData.sendingAssetId)) {
            // Transfer ERC20 tokens directly to relayer
            IERC20 asset = _getRightAsset(_bridgeData.sendingAssetId);

            // Deposit ERC20 token
            uint256 prevBalance = asset.balanceOf(address(relayer));
            SafeERC20.safeTransfer(
                asset,
                address(relayer),
                _bridgeData.minAmount
            );

            if (
                asset.balanceOf(address(relayer)) - prevBalance !=
                _bridgeData.minAmount
            ) {
                revert InvalidAmount();
            }
        }

        _startBridge(_bridgeData, _celerIMData);
    }

    /// Private Methods ///

    /// @dev Contains the business logic for the bridge via CBridge
    /// @param _bridgeData The core information needed for bridging
    /// @param _celerIMData Data specific to CBridge
    function _startBridge(
        ILiFi.BridgeData memory _bridgeData,
        CelerIM.CelerIMData calldata _celerIMData
    ) private {
        // Assuming messageBusFee is pre-calculated off-chain and available in _celerIMData
        // Determine correct native asset amount to be forwarded (if so) and send funds to relayer
        uint256 msgValue = LibAsset.isNativeAsset(_bridgeData.sendingAssetId)
            ? _bridgeData.minAmount
            : 0;

        // Check if transaction contains a destination call
        if (!_bridgeData.hasDestinationCall) {
            // Case 'no': Simple bridge transfer - Send to receiver
            relayer.sendTokenTransfer{ value: msgValue }(
                _bridgeData,
                _celerIMData
            );
        } else {
            // Case 'yes': Bridge + Destination call - Send to relayer

            // save address of original recipient
            address receiver = _bridgeData.receiver;

            // Set relayer as a receiver
            _bridgeData.receiver = address(relayer);

            // send token transfer
            (bytes32 transferId, address bridgeAddress) = relayer
                .sendTokenTransfer{ value: msgValue }(
                _bridgeData,
                _celerIMData
            );

            // Call message bus via relayer incl messageBusFee
            relayer.forwardSendMessageWithTransfer{
                value: _celerIMData.messageBusFee
            }(
                _bridgeData.receiver,
                uint64(_bridgeData.destinationChainId),
                bridgeAddress,
                transferId,
                _celerIMData.callData
            );

            // Reset receiver of bridge data for event emission
            _bridgeData.receiver = receiver;
        }

        // emit LiFi event
        emit LiFiTransferStarted(_bridgeData);
    }

    /// @dev Get right asset to transfer to relayer.
    /// @param _sendingAssetId The address of asset to bridge.
    /// @return _asset The address of asset to transfer to relayer.
    function _getRightAsset(
        address _sendingAssetId
    ) private returns (IERC20 _asset) {
        if (_sendingAssetId == cfUSDC) {
            // special case for cfUSDC token
            _asset = IERC20(CelerToken(_sendingAssetId).canonical());
        } else {
            // any other ERC20 token
            _asset = IERC20(_sendingAssetId);
        }
    }

    function validateDestinationCallFlag(
        ILiFi.BridgeData memory _bridgeData,
        CelerIM.CelerIMData calldata _celerIMData
    ) private pure {
        if (
            (_celerIMData.callData.length > 0) !=
            _bridgeData.hasDestinationCall
        ) {
            revert InformationMismatch();
        }
    }
}
// SPDX-License-Identifier: MIT OR Apache-2.0
// This contract has been taken from: https://github.com/nomad-xyz/ExcessivelySafeCall
pragma solidity 0.8.17;

import { InvalidCallData } from "../Errors/GenericErrors.sol";

// solhint-disable no-inline-assembly
library ExcessivelySafeCall {
    uint256 private constant LOW_28_MASK =
        0x00000000ffffffffffffffffffffffffffffffffffffffffffffffffffffffff;

    /// @notice Use when you _really_ really _really_ don't trust the called
    /// contract. This prevents the called contract from causing reversion of
    /// the caller in as many ways as we can.
    /// @dev The main difference between this and a solidity low-level call is
    /// that we limit the number of bytes that the callee can cause to be
    /// copied to caller memory. This prevents stupid things like malicious
    /// contracts returning 10,000,000 bytes causing a local OOG when copying
    /// to memory.
    /// @param _target The address to call
    /// @param _gas The amount of gas to forward to the remote contract
    /// @param _value The value in wei to send to the remote contract
    /// @param _maxCopy The maximum number of bytes of returndata to copy
    /// to memory.
    /// @param _calldata The data to send to the remote contract
    /// @return success and returndata, as `.call()`. Returndata is capped to
    /// `_maxCopy` bytes.
    function excessivelySafeCall(
        address _target,
        uint256 _gas,
        uint256 _value,
        uint16 _maxCopy,
        bytes memory _calldata
    ) internal returns (bool, bytes memory) {
        // set up for assembly call
        uint256 _toCopy;
        bool _success;
        bytes memory _returnData = new bytes(_maxCopy);
        // dispatch message to recipient
        // by assembly calling "handle" function
        // we call via assembly to avoid memcopying a very large returndata
        // returned by a malicious contract
        assembly {
            _success := call(
                _gas, // gas
                _target, // recipient
                _value, // ether value
                add(_calldata, 0x20), // inloc
                mload(_calldata), // inlen
                0, // outloc
                0 // outlen
            )
            // limit our copy to 256 bytes
            _toCopy := returndatasize()
            if gt(_toCopy, _maxCopy) {
                _toCopy := _maxCopy
            }
            // Store the length of the copied bytes
            mstore(_returnData, _toCopy)
            // copy the bytes from returndata[0:_toCopy]
            returndatacopy(add(_returnData, 0x20), 0, _toCopy)
        }
        return (_success, _returnData);
    }

    /// @notice Use when you _really_ really _really_ don't trust the called
    /// contract. This prevents the called contract from causing reversion of
    /// the caller in as many ways as we can.
    /// @dev The main difference between this and a solidity low-level call is
    /// that we limit the number of bytes that the callee can cause to be
    /// copied to caller memory. This prevents stupid things like malicious
    /// contracts returning 10,000,000 bytes causing a local OOG when copying
    /// to memory.
    /// @param _target The address to call
    /// @param _gas The amount of gas to forward to the remote contract
    /// @param _maxCopy The maximum number of bytes of returndata to copy
    /// to memory.
    /// @param _calldata The data to send to the remote contract
    /// @return success and returndata, as `.call()`. Returndata is capped to
    /// `_maxCopy` bytes.
    function excessivelySafeStaticCall(
        address _target,
        uint256 _gas,
        uint16 _maxCopy,
        bytes memory _calldata
    ) internal view returns (bool, bytes memory) {
        // set up for assembly call
        uint256 _toCopy;
        bool _success;
        bytes memory _returnData = new bytes(_maxCopy);
        // dispatch message to recipient
        // by assembly calling "handle" function
        // we call via assembly to avoid memcopying a very large returndata
        // returned by a malicious contract
        assembly {
            _success := staticcall(
                _gas, // gas
                _target, // recipient
                add(_calldata, 0x20), // inloc
                mload(_calldata), // inlen
                0, // outloc
                0 // outlen
            )
            // limit our copy to 256 bytes
            _toCopy := returndatasize()
            if gt(_toCopy, _maxCopy) {
                _toCopy := _maxCopy
            }
            // Store the length of the copied bytes
            mstore(_returnData, _toCopy)
            // copy the bytes from returndata[0:_toCopy]
            returndatacopy(add(_returnData, 0x20), 0, _toCopy)
        }
        return (_success, _returnData);
    }

    /**
     * @notice Swaps function selectors in encoded contract calls
     * @dev Allows reuse of encoded calldata for functions with identical
     * argument types but different names. It simply swaps out the first 4 bytes
     * for the new selector. This function modifies memory in place, and should
     * only be used with caution.
     * @param _newSelector The new 4-byte selector
     * @param _buf The encoded contract args
     */
    function swapSelector(
        bytes4 _newSelector,
        bytes memory _buf
    ) internal pure {
        if (_buf.length < 4) {
            revert InvalidCallData();
        }
        uint256 _mask = LOW_28_MASK;
        assembly {
            // load the first word of
            let _word := mload(add(_buf, 0x20))
            // mask out the top 4 bytes
            // /x
            _word := and(_word, _mask)
            _word := or(_newSelector, _word)
            mstore(add(_buf, 0x20), _word)
        }
    }
}
// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

/// @title Reentrancy Guard
/// @author LI.FI (https://li.fi)
/// @notice Abstract contract to provide protection against reentrancy
abstract contract ReentrancyGuard {
    /// Storage ///

    bytes32 private constant NAMESPACE = keccak256("com.lifi.reentrancyguard");

    /// Types ///

    struct ReentrancyStorage {
        uint256 status;
    }

    /// Errors ///

    error ReentrancyError();

    /// Constants ///

    uint256 private constant _NOT_ENTERED = 0;
    uint256 private constant _ENTERED = 1;

    /// Modifiers ///

    modifier nonReentrant() {
        ReentrancyStorage storage s = reentrancyStorage();
        if (s.status == _ENTERED) revert ReentrancyError();
        s.status = _ENTERED;
        _;
        s.status = _NOT_ENTERED;
    }

    /// Private Methods ///

    /// @dev fetch local storage
    function reentrancyStorage()
        private
        pure
        returns (ReentrancyStorage storage data)
    {
        bytes32 position = NAMESPACE;
        // solhint-disable-next-line no-inline-assembly
        assembly {
            data.slot := position
        }
    }
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import { ILiFi } from "../Interfaces/ILiFi.sol";
import { LibSwap } from "../Libraries/LibSwap.sol";
import { LibAsset } from "../Libraries/LibAsset.sol";
import { LibAllowList } from "../Libraries/LibAllowList.sol";
import { ContractCallNotAllowed, NoSwapDataProvided, CumulativeSlippageTooHigh } from "../Errors/GenericErrors.sol";

/// @title Swapper
/// @author LI.FI (https://li.fi)
/// @notice Abstract contract to provide swap functionality
contract SwapperV2 is ILiFi {
    /// Types ///

    /// @dev only used to get around "Stack Too Deep" errors
    struct ReserveData {
        bytes32 transactionId;
        address payable leftoverReceiver;
        uint256 nativeReserve;
    }

    /// Modifiers ///

    /// @dev Sends any leftover balances back to the user
    /// @notice Sends any leftover balances to the user
    /// @param _swaps Swap data array
    /// @param _leftoverReceiver Address to send leftover tokens to
    /// @param _initialBalances Array of initial token balances
    modifier noLeftovers(
        LibSwap.SwapData[] calldata _swaps,
        address payable _leftoverReceiver,
        uint256[] memory _initialBalances
    ) {
        uint256 numSwaps = _swaps.length;
        if (numSwaps != 1) {
            address finalAsset = _swaps[numSwaps - 1].receivingAssetId;
            uint256 curBalance;

            _;

            for (uint256 i = 0; i < numSwaps - 1; ) {
                address curAsset = _swaps[i].receivingAssetId;
                // Handle multi-to-one swaps
                if (curAsset != finalAsset) {
                    curBalance =
                        LibAsset.getOwnBalance(curAsset) -
                        _initialBalances[i];
                    if (curBalance > 0) {
                        LibAsset.transferAsset(
                            curAsset,
                            _leftoverReceiver,
                            curBalance
                        );
                    }
                }
                unchecked {
                    ++i;
                }
            }
        } else {
            _;
        }
    }

    /// @dev Sends any leftover balances back to the user reserving native tokens
    /// @notice Sends any leftover balances to the user
    /// @param _swaps Swap data array
    /// @param _leftoverReceiver Address to send leftover tokens to
    /// @param _initialBalances Array of initial token balances
    modifier noLeftoversReserve(
        LibSwap.SwapData[] calldata _swaps,
        address payable _leftoverReceiver,
        uint256[] memory _initialBalances,
        uint256 _nativeReserve
    ) {
        uint256 numSwaps = _swaps.length;
        if (numSwaps != 1) {
            address finalAsset = _swaps[numSwaps - 1].receivingAssetId;
            uint256 curBalance;

            _;

            for (uint256 i = 0; i < numSwaps - 1; ) {
                address curAsset = _swaps[i].receivingAssetId;
                // Handle multi-to-one swaps
                if (curAsset != finalAsset) {
                    curBalance =
                        LibAsset.getOwnBalance(curAsset) -
                        _initialBalances[i];
                    uint256 reserve = LibAsset.isNativeAsset(curAsset)
                        ? _nativeReserve
                        : 0;
                    if (curBalance > 0) {
                        LibAsset.transferAsset(
                            curAsset,
                            _leftoverReceiver,
                            curBalance - reserve
                        );
                    }
                }
                unchecked {
                    ++i;
                }
            }
        } else {
            _;
        }
    }

    /// @dev Refunds any excess native asset sent to the contract after the main function
    /// @notice Refunds any excess native asset sent to the contract after the main function
    /// @param _refundReceiver Address to send refunds to
    modifier refundExcessNative(address payable _refundReceiver) {
        uint256 initialBalance = address(this).balance - msg.value;
        _;
        uint256 finalBalance = address(this).balance;

        if (finalBalance > initialBalance) {
            LibAsset.transferAsset(
                LibAsset.NATIVE_ASSETID,
                _refundReceiver,
                finalBalance - initialBalance
            );
        }
    }

    /// Internal Methods ///

    /// @dev Deposits value, executes swaps, and performs minimum amount check
    /// @param _transactionId the transaction id associated with the operation
    /// @param _minAmount the minimum amount of the final asset to receive
    /// @param _swaps Array of data used to execute swaps
    /// @param _leftoverReceiver The address to send leftover funds to
    /// @return uint256 result of the swap
    function _depositAndSwap(
        bytes32 _transactionId,
        uint256 _minAmount,
        LibSwap.SwapData[] calldata _swaps,
        address payable _leftoverReceiver
    ) internal returns (uint256) {
        uint256 numSwaps = _swaps.length;

        if (numSwaps == 0) {
            revert NoSwapDataProvided();
        }

        address finalTokenId = _swaps[numSwaps - 1].receivingAssetId;
        uint256 initialBalance = LibAsset.getOwnBalance(finalTokenId);

        if (LibAsset.isNativeAsset(finalTokenId)) {
            initialBalance -= msg.value;
        }

        uint256[] memory initialBalances = _fetchBalances(_swaps);

        LibAsset.depositAssets(_swaps);
        _executeSwaps(
            _transactionId,
            _swaps,
            _leftoverReceiver,
            initialBalances
        );

        uint256 newBalance = LibAsset.getOwnBalance(finalTokenId) -
            initialBalance;

        if (newBalance < _minAmount) {
            revert CumulativeSlippageTooHigh(_minAmount, newBalance);
        }

        return newBalance;
    }

    /// @dev Deposits value, executes swaps, and performs minimum amount check and reserves native token for fees
    /// @param _transactionId the transaction id associated with the operation
    /// @param _minAmount the minimum amount of the final asset to receive
    /// @param _swaps Array of data used to execute swaps
    /// @param _leftoverReceiver The address to send leftover funds to
    /// @param _nativeReserve Amount of native token to prevent from being swept back to the caller
    function _depositAndSwap(
        bytes32 _transactionId,
        uint256 _minAmount,
        LibSwap.SwapData[] calldata _swaps,
        address payable _leftoverReceiver,
        uint256 _nativeReserve
    ) internal returns (uint256) {
        uint256 numSwaps = _swaps.length;

        if (numSwaps == 0) {
            revert NoSwapDataProvided();
        }

        address finalTokenId = _swaps[numSwaps - 1].receivingAssetId;
        uint256 initialBalance = LibAsset.getOwnBalance(finalTokenId);

        if (LibAsset.isNativeAsset(finalTokenId)) {
            initialBalance -= msg.value;
        }

        uint256[] memory initialBalances = _fetchBalances(_swaps);

        LibAsset.depositAssets(_swaps);
        ReserveData memory rd = ReserveData(
            _transactionId,
            _leftoverReceiver,
            _nativeReserve
        );
        _executeSwaps(rd, _swaps, initialBalances);

        uint256 newBalance = LibAsset.getOwnBalance(finalTokenId) -
            initialBalance;

        if (LibAsset.isNativeAsset(finalTokenId)) {
            newBalance -= _nativeReserve;
        }

        if (newBalance < _minAmount) {
            revert CumulativeSlippageTooHigh(_minAmount, newBalance);
        }

        return newBalance;
    }

    /// Private Methods ///

    /// @dev Executes swaps and checks that DEXs used are in the allowList
    /// @param _transactionId the transaction id associated with the operation
    /// @param _swaps Array of data used to execute swaps
    /// @param _leftoverReceiver Address to send leftover tokens to
    /// @param _initialBalances Array of initial balances
    function _executeSwaps(
        bytes32 _transactionId,
        LibSwap.SwapData[] calldata _swaps,
        address payable _leftoverReceiver,
        uint256[] memory _initialBalances
    ) internal noLeftovers(_swaps, _leftoverReceiver, _initialBalances) {
        uint256 numSwaps = _swaps.length;
        for (uint256 i = 0; i < numSwaps; ) {
            LibSwap.SwapData calldata currentSwap = _swaps[i];

            if (
                !((LibAsset.isNativeAsset(currentSwap.sendingAssetId) ||
                    LibAllowList.contractIsAllowed(currentSwap.approveTo)) &&
                    LibAllowList.contractIsAllowed(currentSwap.callTo) &&
                    LibAllowList.selectorIsAllowed(
                        bytes4(currentSwap.callData[:4])
                    ))
            ) revert ContractCallNotAllowed();

            LibSwap.swap(_transactionId, currentSwap);

            unchecked {
                ++i;
            }
        }
    }

    /// @dev Executes swaps and checks that DEXs used are in the allowList
    /// @param _reserveData Data passed used to reserve native tokens
    /// @param _swaps Array of data used to execute swaps
    function _executeSwaps(
        ReserveData memory _reserveData,
        LibSwap.SwapData[] calldata _swaps,
        uint256[] memory _initialBalances
    )
        internal
        noLeftoversReserve(
            _swaps,
            _reserveData.leftoverReceiver,
            _initialBalances,
            _reserveData.nativeReserve
        )
    {
        uint256 numSwaps = _swaps.length;
        for (uint256 i = 0; i < numSwaps; ) {
            LibSwap.SwapData calldata currentSwap = _swaps[i];

            if (
                !((LibAsset.isNativeAsset(currentSwap.sendingAssetId) ||
                    LibAllowList.contractIsAllowed(currentSwap.approveTo)) &&
                    LibAllowList.contractIsAllowed(currentSwap.callTo) &&
                    LibAllowList.selectorIsAllowed(
                        bytes4(currentSwap.callData[:4])
                    ))
            ) revert ContractCallNotAllowed();

            LibSwap.swap(_reserveData.transactionId, currentSwap);

            unchecked {
                ++i;
            }
        }
    }

    /// @dev Fetches balances of tokens to be swapped before swapping.
    /// @param _swaps Array of data used to execute swaps
    /// @return uint256[] Array of token balances.
    function _fetchBalances(
        LibSwap.SwapData[] calldata _swaps
    ) private view returns (uint256[] memory) {
        uint256 numSwaps = _swaps.length;
        uint256[] memory balances = new uint256[](numSwaps);
        address asset;
        for (uint256 i = 0; i < numSwaps; ) {
            asset = _swaps[i].receivingAssetId;
            balances[i] = LibAsset.getOwnBalance(asset);

            if (LibAsset.isNativeAsset(asset)) {
                balances[i] -= msg.value;
            }

            unchecked {
                ++i;
            }
        }

        return balances;
    }
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import { IERC173 } from "../Interfaces/IERC173.sol";
import { LibAsset } from "../Libraries/LibAsset.sol";

contract TransferrableOwnership is IERC173 {
    address public owner;
    address public pendingOwner;

    /// Errors ///
    error UnAuthorized();
    error NoNullOwner();
    error NewOwnerMustNotBeSelf();
    error NoPendingOwnershipTransfer();
    error NotPendingOwner();

    /// Events ///
    event OwnershipTransferRequested(
        address indexed _from,
        address indexed _to
    );

    constructor(address initialOwner) {
        owner = initialOwner;
    }

    modifier onlyOwner() {
        if (msg.sender != owner) revert UnAuthorized();
        _;
    }

    /// @notice Initiates transfer of ownership to a new address
    /// @param _newOwner the address to transfer ownership to
    function transferOwnership(address _newOwner) external onlyOwner {
        if (_newOwner == LibAsset.NULL_ADDRESS) revert NoNullOwner();
        if (_newOwner == msg.sender) revert NewOwnerMustNotBeSelf();
        pendingOwner = _newOwner;
        emit OwnershipTransferRequested(msg.sender, pendingOwner);
    }

    /// @notice Cancel transfer of ownership
    function cancelOwnershipTransfer() external onlyOwner {
        if (pendingOwner == LibAsset.NULL_ADDRESS)
            revert NoPendingOwnershipTransfer();
        pendingOwner = LibAsset.NULL_ADDRESS;
    }

    /// @notice Confirms transfer of ownership to the calling address (msg.sender)
    function confirmOwnershipTransfer() external {
        address _pendingOwner = pendingOwner;
        if (msg.sender != _pendingOwner) revert NotPendingOwner();
        emit OwnershipTransferred(owner, _pendingOwner);
        owner = _pendingOwner;
        pendingOwner = LibAsset.NULL_ADDRESS;
    }
}
// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import { LibAsset } from "../Libraries/LibAsset.sol";
import { LibUtil } from "../Libraries/LibUtil.sol";
import { InvalidReceiver, InformationMismatch, InvalidSendingToken, InvalidAmount, NativeAssetNotSupported, InvalidDestinationChain, CannotBridgeToSameNetwork } from "../Errors/GenericErrors.sol";
import { ILiFi } from "../Interfaces/ILiFi.sol";
import { LibSwap } from "../Libraries/LibSwap.sol";

contract Validatable {
    modifier validateBridgeData(ILiFi.BridgeData memory _bridgeData) {
        if (LibUtil.isZeroAddress(_bridgeData.receiver)) {
            revert InvalidReceiver();
        }
        if (_bridgeData.minAmount == 0) {
            revert InvalidAmount();
        }
        if (_bridgeData.destinationChainId == block.chainid) {
            revert CannotBridgeToSameNetwork();
        }
        _;
    }

    modifier noNativeAsset(ILiFi.BridgeData memory _bridgeData) {
        if (LibAsset.isNativeAsset(_bridgeData.sendingAssetId)) {
            revert NativeAssetNotSupported();
        }
        _;
    }

    modifier onlyAllowSourceToken(
        ILiFi.BridgeData memory _bridgeData,
        address _token
    ) {
        if (_bridgeData.sendingAssetId != _token) {
            revert InvalidSendingToken();
        }
        _;
    }

    modifier onlyAllowDestinationChain(
        ILiFi.BridgeData memory _bridgeData,
        uint256 _chainId
    ) {
        if (_bridgeData.destinationChainId != _chainId) {
            revert InvalidDestinationChain();
        }
        _;
    }

    modifier containsSourceSwaps(ILiFi.BridgeData memory _bridgeData) {
        if (!_bridgeData.hasSourceSwaps) {
            revert InformationMismatch();
        }
        _;
    }

    modifier doesNotContainSourceSwaps(ILiFi.BridgeData memory _bridgeData) {
        if (_bridgeData.hasSourceSwaps) {
            revert InformationMismatch();
        }
        _;
    }

    modifier doesNotContainDestinationCalls(
        ILiFi.BridgeData memory _bridgeData
    ) {
        if (_bridgeData.hasDestinationCall) {
            revert InformationMismatch();
        }
        _;
    }
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

interface IAcrossSpokePool {
    function deposit(
        address recipient, // Recipient address
        address originToken, // Address of the token
        uint256 amount, // Token amount
        uint256 destinationChainId, // ⛓ id
        int64 relayerFeePct, // see #Fees Calculation
        uint32 quoteTimestamp, // Timestamp for the quote creation
        bytes memory message, // Arbitrary data that can be used to pass additional information to the recipient along with the tokens.
        uint256 maxCount // Used to protect the depositor from frontrunning to guarantee their quote remains valid.
    ) external payable;
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

/// @title AllBridge Interface
interface IAllBridge {
    /// @dev AllBridge Messenger Protocol Enum
    enum MessengerProtocol {
        None,
        Allbridge,
        Wormhole,
        LayerZero
    }

    function pools(bytes32 addr) external returns (address);

    function swapAndBridge(
        bytes32 token,
        uint256 amount,
        bytes32 recipient,
        uint256 destinationChainId,
        bytes32 receiveToken,
        uint256 nonce,
        MessengerProtocol messenger,
        uint256 feeTokenAmount
    ) external payable;

    function getTransactionCost(
        uint256 chainId
    ) external view returns (uint256);

    function getMessageCost(
        uint256 chainId,
        MessengerProtocol protocol
    ) external view returns (uint256);

    function getBridgingCostInTokens(
        uint256 destinationChainId,
        MessengerProtocol messenger,
        address tokenAddress
    ) external view returns (uint256);
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

interface ICBridge {
    /// @notice Send a cross-chain transfer via the liquidity pool-based bridge.
    /// @dev This function DOES NOT SUPPORT fee-on-transfer / rebasing tokens.
    /// @param _receiver The address of the receiver.
    /// @param _token The address of the token.
    /// @param _amount The amount of the transfer.
    /// @param _dstChainId The destination chain ID.
    /// @param _nonce A number input to guarantee uniqueness of transferId. Can be timestamp in practice.
    /// @param _maxSlippage The max slippage accepted, given as percentage in point (pip).
    ///                     Eg. 5000 means 0.5%. Must be greater than minimalMaxSlippage.
    ///                     Receiver is guaranteed to receive at least (100% - max slippage percentage) * amount
    ///                     or the transfer can be refunded.
    function send(
        address _receiver,
        address _token,
        uint256 _amount,
        uint64 _dstChainId,
        uint64 _nonce,
        uint32 _maxSlippage
    ) external;

    /// @notice Send a cross-chain transfer via the liquidity pool-based bridge using the native token.
    /// @param _receiver The address of the receiver.
    /// @param _amount The amount of the transfer.
    /// @param _dstChainId The destination chain ID.
    /// @param _nonce A unique number. Can be timestamp in practice.
    /// @param _maxSlippage The max slippage accepted, given as percentage in point (pip).
    ///                     Eg. 5000 means 0.5%. Must be greater than minimalMaxSlippage.
    ///                     Receiver is guaranteed to receive at least (100% - max slippage percentage) * amount
    ///                     or the transfer can be refunded.
    function sendNative(
        address _receiver,
        uint256 _amount,
        uint64 _dstChainId,
        uint64 _nonce,
        uint32 _maxSlippage
    ) external payable;
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

interface ICircleBridgeProxy {
    /// @notice Deposits and burns tokens from sender to be minted on destination domain.
    /// @dev reverts if:
    ///      - given burnToken is not supported.
    ///      - given destinationDomain has no TokenMessenger registered.
    ///      - transferFrom() reverts. For example, if sender's burnToken balance
    ///        or approved allowance to this contract is less than `amount`.
    ///      - burn() reverts. For example, if `amount` is 0.
    ///      - MessageTransmitter returns false or reverts.
    /// @param _amount Amount of tokens to burn.
    /// @param _dstChid Destination domain.
    /// @param _mintRecipient Address of mint recipient on destination domain.
    /// @param _burnToken Address of contract to burn deposited tokens, on local domain.
    /// @return nonce Unique nonce reserved by message.
    function depositForBurn(
        uint256 _amount,
        uint64 _dstChid,
        bytes32 _mintRecipient,
        address _burnToken
    ) external returns (uint64 nonce);
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

interface IConnextHandler {
    /// @notice These are the call parameters that will remain constant between the
    /// two chains. They are supplied on `xcall` and should be asserted on `execute`
    /// @property to - The account that receives funds, in the event of a crosschain call,
    /// will receive funds if the call fails.
    /// @param to - The address you are sending funds (and potentially data) to
    /// @param callData - The data to execute on the receiving chain. If no crosschain call is needed, then leave empty.
    /// @param originDomain - The originating domain (i.e. where `xcall` is called). Must match nomad domain schema
    /// @param destinationDomain - The final domain (i.e. where `execute` / `reconcile` are called). Must match nomad domain schema
    /// @param agent - An address who can execute txs on behalf of `to`, in addition to allowing relayers
    /// @param recovery - The address to send funds to if your `Executor.execute call` fails
    /// @param forceSlow - If true, will take slow liquidity path even if it is not a permissioned call
    /// @param receiveLocal - If true, will use the local nomad asset on the destination instead of adopted.
    /// @param callback - The address on the origin domain of the callback contract
    /// @param callbackFee - The relayer fee to execute the callback
    /// @param relayerFee - The amount of relayer fee the tx called xcall with
    /// @param slippageTol - Max bps of original due to slippage (i.e. would be 9995 to tolerate .05% slippage)
    struct CallParams {
        address to;
        bytes callData;
        uint32 originDomain;
        uint32 destinationDomain;
        address agent;
        address recovery;
        bool forceSlow;
        bool receiveLocal;
        address callback;
        uint256 callbackFee;
        uint256 relayerFee;
        uint256 slippageTol;
    }

    /// @notice The arguments you supply to the `xcall` function called by user on origin domain
    /// @param params - The CallParams. These are consistent across sending and receiving chains
    /// @param transactingAsset - The asset the caller sent with the transfer. Can be the adopted, canonical,
    /// or the representational asset
    /// @param transactingAmount - The amount of transferring asset supplied by the user in the `xcall`
    /// @param originMinOut - Minimum amount received on swaps for adopted <> local on origin chain
    struct XCallArgs {
        CallParams params;
        address transactingAsset; // Could be adopted, local, or wrapped
        uint256 transactingAmount;
        uint256 originMinOut;
    }

    function xcall(
        uint32 destination,
        address recipient,
        address tokenAddress,
        address delegate,
        uint256 amount,
        uint256 slippage,
        bytes memory callData
    ) external payable returns (bytes32);

    function xcall(
        uint32 destination,
        address recipient,
        address tokenAddress,
        address delegate,
        uint256 amount,
        uint256 slippage,
        bytes memory callData,
        uint256 _relayerFee
    ) external returns (bytes32);
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

interface IDeBridgeGate {
    /// @param fixedNativeFee Transfer fixed fee.
    /// @param isSupported Whether the chain for the asset is supported.
    /// @param transferFeeBps Transfer fee rate nominated in basis points (1/10000)
    ///                       of transferred amount.
    struct ChainSupportInfo {
        uint256 fixedNativeFee;
        bool isSupported;
        uint16 transferFeeBps;
    }

    /// @dev Fallback fixed fee in native asset, used if a chain fixed fee is set to 0
    function globalFixedNativeFee() external view returns (uint256);

    /// @dev Whether the chain for the asset is supported to send
    function getChainToConfig(
        uint256
    ) external view returns (ChainSupportInfo memory);

    /// @dev This method is used for the transfer of assets.
    ///      It locks an asset in the smart contract in the native chain
    ///      and enables minting of deAsset on the secondary chain.
    /// @param _tokenAddress Asset identifier.
    /// @param _amount Amount to be transferred (note: the fee can be applied).
    /// @param _chainIdTo Chain id of the target chain.
    /// @param _receiver Receiver address.
    /// @param _permit deadline + signature for approving the spender by signature.
    /// @param _useAssetFee use assets fee for pay protocol fix (work only for specials token)
    /// @param _referralCode Referral code
    /// @param _autoParams Auto params for external call in target network
    function send(
        address _tokenAddress,
        uint256 _amount,
        uint256 _chainIdTo,
        bytes memory _receiver,
        bytes memory _permit,
        bool _useAssetFee,
        uint32 _referralCode,
        bytes calldata _autoParams
    ) external payable;
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

interface IDiamondCut {
    enum FacetCutAction {
        Add,
        Replace,
        Remove
    }
    // Add=0, Replace=1, Remove=2

    struct FacetCut {
        address facetAddress;
        FacetCutAction action;
        bytes4[] functionSelectors;
    }

    /// @notice Add/replace/remove any number of functions and optionally execute
    ///         a function with delegatecall
    /// @param _diamondCut Contains the facet addresses and function selectors
    /// @param _init The address of the contract or facet to execute _calldata
    /// @param _calldata A function call, including function selector and arguments
    ///                  _calldata is executed with delegatecall on _init
    function diamondCut(
        FacetCut[] calldata _diamondCut,
        address _init,
        bytes calldata _calldata
    ) external;

    event DiamondCut(FacetCut[] _diamondCut, address _init, bytes _calldata);
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

// A loupe is a small magnifying glass used to look at diamonds.
// These functions look at diamonds
interface IDiamondLoupe {
    /// These functions are expected to be called frequently
    /// by tools.

    struct Facet {
        address facetAddress;
        bytes4[] functionSelectors;
    }

    /// @notice Gets all facet addresses and their four byte function selectors.
    /// @return facets_ Facet
    function facets() external view returns (Facet[] memory facets_);

    /// @notice Gets all the function selectors supported by a specific facet.
    /// @param _facet The facet address.
    /// @return facetFunctionSelectors_
    function facetFunctionSelectors(
        address _facet
    ) external view returns (bytes4[] memory facetFunctionSelectors_);

    /// @notice Get all the facet addresses used by a diamond.
    /// @return facetAddresses_
    function facetAddresses()
        external
        view
        returns (address[] memory facetAddresses_);

    /// @notice Gets the facet that supports the given selector.
    /// @dev If facet is not found return address(0).
    /// @param _functionSelector The function selector.
    /// @return facetAddress_ The facet address.
    function facetAddress(
        bytes4 _functionSelector
    ) external view returns (address facetAddress_);
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

interface IERC165 {
    /// @notice Query if a contract implements an interface
    /// @param interfaceId The interface identifier, as specified in ERC-165
    /// @dev Interface identification is specified in ERC-165. This function
    ///  uses less than 30,000 gas.
    /// @return `true` if the contract implements `interfaceID` and
    ///  `interfaceID` is not 0xffffffff, `false` otherwise
    function supportsInterface(
        bytes4 interfaceId
    ) external view returns (bool);
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

/// @title ERC-173 Contract Ownership Standard
///  Note: the ERC-165 identifier for this interface is 0x7f5828d0
/* is ERC165 */
interface IERC173 {
    /// @dev This emits when ownership of a contract changes.
    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /// @notice Get the address of the owner
    /// @return owner_ The address of the owner.
    function owner() external view returns (address owner_);

    /// @notice Set the address of the new owner of the contract
    /// @dev Set _newOwner to address(0) to renounce any ownership.
    /// @param _newOwner The address of the new owner of the contract
    function transferOwnership(address _newOwner) external;
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

interface IERC20Proxy {
    function transferFrom(
        address tokenAddress,
        address from,
        address to,
        uint256 amount
    ) external;
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import { LibSwap } from "../Libraries/LibSwap.sol";

/// @title Interface for Executor
/// @author LI.FI (https://li.fi)
interface IExecutor {
    /// @notice Performs a swap before completing a cross-chain transaction
    /// @param _transactionId the transaction id associated with the operation
    /// @param _swapData array of data needed for swaps
    /// @param transferredAssetId token received from the other chain
    /// @param receiver address that will receive tokens in the end
    function swapAndCompleteBridgeTokens(
        bytes32 _transactionId,
        LibSwap.SwapData[] calldata _swapData,
        address transferredAssetId,
        address payable receiver
    ) external payable;
}
// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.17;

interface IGatewayRouter {
    /// @notice Transfer non-native assets
    /// @param _token L1 address of ERC20
    /// @param _to Account to be credited with the tokens in the L2 (can be the user's L2 account or a contract)
    /// @param _amount Token Amount
    /// @param _maxGas Max gas deducted from user's L2 balance to cover L2 execution
    /// @param _gasPriceBid Gas price for L2 execution
    /// @param _data Encoded data from router and user
    function outboundTransfer(
        address _token,
        address _to,
        uint256 _amount,
        uint256 _maxGas,
        uint256 _gasPriceBid,
        bytes calldata _data
    ) external payable returns (bytes memory);

    /// @dev Advanced usage only (does not rewrite aliases for excessFeeRefundAddress and callValueRefundAddress). createRetryableTicket method is the recommended standard.
    /// @param _destAddr destination L2 contract address
    /// @param _l2CallValue call value for retryable L2 message
    /// @param _maxSubmissionCost Max gas deducted from user's L2 balance to cover base submission fee
    /// @param _excessFeeRefundAddress maxgas x gasprice - execution cost gets credited here on L2 balance
    /// @param _callValueRefundAddress l2Callvalue gets credited here on L2 if retryable txn times out or gets cancelled
    /// @param _maxGas Max gas deducted from user's L2 balance to cover L2 execution
    /// @param _gasPriceBid price bid for L2 execution
    /// @param _data ABI encoded data of L2 message
    /// @return unique id for retryable transaction (keccak256(requestID, uint(0) )
    function unsafeCreateRetryableTicket(
        address _destAddr,
        uint256 _l2CallValue,
        uint256 _maxSubmissionCost,
        address _excessFeeRefundAddress,
        address _callValueRefundAddress,
        uint256 _maxGas,
        uint256 _gasPriceBid,
        bytes calldata _data
    ) external payable returns (uint256);

    /// @notice Returns receiving token address on L2
    /// @param _token Sending token address on L1
    /// @return Receiving token address on L2
    function calculateL2TokenAddress(
        address _token
    ) external view returns (address);

    /// @notice Returns exact gateway router address for token
    /// @param _token Sending token address on L1
    /// @return Gateway router address for sending token
    function getGateway(address _token) external view returns (address);
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

interface IHopBridge {
    function sendToL2(
        uint256 chainId,
        address recipient,
        uint256 amount,
        uint256 amountOutMin,
        uint256 deadline,
        address relayer,
        uint256 relayerFee
    ) external payable;

    function swapAndSend(
        uint256 chainId,
        address recipient,
        uint256 amount,
        uint256 bonderFee,
        uint256 amountOutMin,
        uint256 deadline,
        uint256 destinationAmountOutMin,
        uint256 destinationDeadline
    ) external payable;

    function send(
        uint256 chainId,
        address recipient,
        uint256 amount,
        uint256 bonderFee,
        uint256 amountOutMin,
        uint256 deadline
    ) external;
}

interface IL2AmmWrapper {
    function bridge() external view returns (address);

    function l2CanonicalToken() external view returns (address);

    function hToken() external view returns (address);

    function exchangeAddress() external view returns (address);
}

interface ISwap {
    function swap(
        uint8 tokenIndexFrom,
        uint8 tokenIndexTo,
        uint256 dx,
        uint256 minDy,
        uint256 deadline
    ) external returns (uint256);
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

// https://github.com/bcnmy/hyphen-contract/blob/master/contracts/hyphen/LiquidityPool.sol
interface IHyphenRouter {
    function depositErc20(
        uint256 toChainId,
        address tokenAddress,
        address receiver,
        uint256 amount,
        string calldata tag
    ) external;

    function depositNative(
        address receiver,
        uint256 toChainId,
        string calldata tag
    ) external payable;
}
// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.17;

interface IL1StandardBridge {
    /// @notice Deposit an amount of ETH to a recipient's balance on L2.
    /// @param _to L2 address to credit the withdrawal to.
    /// @param _l2Gas Gas limit required to complete the deposit on L2.
    /// @param _data Optional data to forward to L2. This data is provided
    ///        solely as a convenience for external contracts. Aside from enforcing a maximum
    ///        length, these contracts provide no guarantees about its content.
    function depositETHTo(
        address _to,
        uint32 _l2Gas,
        bytes calldata _data
    ) external payable;

    /// @notice Deposit an amount of the ERC20 to the caller's balance on L2.
    /// @param _l1Token Address of the L1 ERC20 we are depositing
    /// @param _l2Token Address of the L1 respective L2 ERC20
    /// @param _to L2 address to credit the withdrawal to.
    /// @param _amount Amount of the ERC20 to deposit
    /// @param _l2Gas Gas limit required to complete the deposit on L2.
    /// @param _data Optional data to forward to L2. This data is provided
    ///        solely as a convenience for external contracts. Aside from enforcing a maximum
    ///        length, these contracts provide no guarantees about its content.
    function depositERC20To(
        address _l1Token,
        address _l2Token,
        address _to,
        uint256 _amount,
        uint32 _l2Gas,
        bytes calldata _data
    ) external;

    /// @notice Deposit an amount of the ERC20 to the caller's balance on L2.
    /// @dev This function is implemented on SynthetixBridgeToOptimism contract.
    /// @param _to L2 address to credit the withdrawal to.
    /// @param _amount Amount of the ERC20 to deposit
    function depositTo(address _to, uint256 _amount) external;
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

interface ILiFi {
    /// Structs ///

    struct BridgeData {
        bytes32 transactionId;
        string bridge;
        string integrator;
        address referrer;
        address sendingAssetId;
        address receiver;
        uint256 minAmount;
        uint256 destinationChainId;
        bool hasSourceSwaps;
        bool hasDestinationCall;
    }

    /// Events ///

    event LiFiTransferStarted(ILiFi.BridgeData bridgeData);

    event LiFiTransferCompleted(
        bytes32 indexed transactionId,
        address receivingAssetId,
        address receiver,
        uint256 amount,
        uint256 timestamp
    );

    event LiFiTransferRecovered(
        bytes32 indexed transactionId,
        address receivingAssetId,
        address receiver,
        uint256 amount,
        uint256 timestamp
    );

    event LiFiGenericSwapCompleted(
        bytes32 indexed transactionId,
        string integrator,
        string referrer,
        address receiver,
        address fromAssetId,
        address toAssetId,
        uint256 fromAmount,
        uint256 toAmount
    );

    // Deprecated but kept here to include in ABI to parse historic events
    event LiFiSwappedGeneric(
        bytes32 indexed transactionId,
        string integrator,
        string referrer,
        address fromAssetId,
        address toAssetId,
        uint256 fromAmount,
        uint256 toAmount
    );
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

interface IMultichainRouter {
    function anySwapOutUnderlying(
        address token,
        address to,
        uint256 amount,
        uint256 toChainID
    ) external;

    function anySwapOut(
        address token,
        address to,
        uint256 amount,
        uint256 toChainID
    ) external;

    function anySwapOutNative(
        address token,
        address to,
        uint256 toChainID
    ) external payable;

    function wNATIVE() external returns (address);
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

interface IMultichainToken {
    function underlying() external returns (address);
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

interface IOmniBridge {
    /// @dev Initiate the bridge operation for some amount of tokens from msg.sender.
    /// @param token bridged token contract address.
    /// @param receiver Receiver address
    /// @param amount Dai amount
    function relayTokens(
        address token,
        address receiver,
        uint256 amount
    ) external;

    /// @dev Wraps native assets and relays wrapped ERC20 tokens to the other chain.
    /// @param receiver Bridged assets receiver on the other side of the bridge.
    function wrapAndRelayTokens(address receiver) external payable;
}
// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.17;

interface IRootChainManager {
    /// @notice Move ether from root to child chain, accepts ether transfer
    /// @dev Keep in mind this ether cannot be used to pay gas on child chain
    ///      Use Matic tokens deposited using plasma mechanism for that
    /// @param user address of account that should receive WETH on child chain
    function depositEtherFor(address user) external payable;

    /// @notice Move tokens from root to child chain
    /// @dev This mechanism supports arbitrary tokens as long as
    ///      its predicate has been registered and the token is mapped
    /// @param user address of account that should receive this deposit on child chain
    /// @param rootToken address of token that is being deposited
    /// @param depositData bytes data that is sent to predicate and
    ///        child token contracts to handle deposit
    function depositFor(
        address user,
        address rootToken,
        bytes calldata depositData
    ) external;

    /// @notice Returns child token address for root token
    /// @param rootToken Root token address
    /// @return childToken Child token address
    function rootToChildToken(
        address rootToken
    ) external view returns (address childToken);
}
// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.17;

// solhint-disable contract-name-camelcase
interface IStargateRouter {
    struct lzTxObj {
        uint256 dstGasForCall;
        uint256 dstNativeAmount;
        bytes dstNativeAddr;
    }

    /// @notice SwapAmount struct
    /// @param amountLD The amount, in Local Decimals, to be swapped
    /// @param minAmountLD The minimum amount accepted out on destination
    struct SwapAmount {
        uint256 amountLD;
        uint256 minAmountLD;
    }

    /// @notice Returns factory address used for creating pools.
    function factory() external view returns (address);

    /// @notice Swap assets cross-chain.
    /// @dev Pass (0, 0, "0x") to lzTxParams
    ///      for 0 additional gasLimit increase, 0 airdrop, at 0x address.
    /// @param dstChainId Destination chainId
    /// @param srcPoolId Source pool id
    /// @param dstPoolId Dest pool id
    /// @param refundAddress Refund adddress. extra gas (if any) is returned to this address
    /// @param amountLD Quantity to swap
    /// @param minAmountLD The min qty you would accept on the destination
    /// @param lzTxParams Additional gas, airdrop data
    /// @param to The address to send the tokens to on the destination
    /// @param payload Additional payload. You can abi.encode() them here
    function swap(
        uint16 dstChainId,
        uint256 srcPoolId,
        uint256 dstPoolId,
        address payable refundAddress,
        uint256 amountLD,
        uint256 minAmountLD,
        lzTxObj memory lzTxParams,
        bytes calldata to,
        bytes calldata payload
    ) external payable;

    /// @notice Swap native assets cross-chain.
    /// @param _dstChainId Destination Stargate chainId
    /// @param _refundAddress Refunds additional messageFee to this address
    /// @param _toAddress The receiver of the destination ETH
    /// @param _swapAmount The amount and the minimum swap amount
    /// @param _lzTxParams The LZ tx params
    /// @param _payload The payload to send to the destination
    function swapETHAndCall(
        uint16 _dstChainId,
        address payable _refundAddress,
        bytes calldata _toAddress,
        SwapAmount memory _swapAmount,
        IStargateRouter.lzTxObj memory _lzTxParams,
        bytes calldata _payload
    ) external payable;

    /// @notice Returns the native gas fee required for swap.
    function quoteLayerZeroFee(
        uint16 dstChainId,
        uint8 functionType,
        bytes calldata toAddress,
        bytes calldata transferAndCallPayload,
        lzTxObj memory lzTxParams
    ) external view returns (uint256 nativeFee, uint256 zroFee);
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

interface ISynapseRouter {
    /// @notice Struct representing a request for SynapseRouter.
    /// @dev tokenIn is supplied separately.
    /// @param swapAdapter Adapter address that will perform the swap.
    ///                    Address(0) specifies a "no swap" query.
    /// @param tokenOut Token address to swap to.
    /// @param minAmountOut Minimum amount of tokens to receive after the swap,
    ///                     or tx will be reverted.
    /// @param deadline Latest timestamp for when the transaction needs to be executed,
    ///                 or tx will be reverted.
    /// @param rawParams ABI-encoded params for the swap that will be passed to `swapAdapter`.
    ///                  Should be SynapseParams for swaps via SynapseAdapter.
    struct SwapQuery {
        address swapAdapter;
        address tokenOut;
        uint256 minAmountOut;
        uint256 deadline;
        bytes rawParams;
    }

    /// @notice Struct representing a request for a swap quote from a bridge token.
    /// @dev tokenOut is passed externally.
    /// @param symbol Bridge token symbol: unique token ID consistent among all chains.
    /// @param amountIn Amount of bridge token to start with, before the bridge fee is applied.
    struct DestRequest {
        string symbol;
        uint256 amountIn;
    }

    /// @notice Struct representing a bridge token.
    ///         Used as the return value in view functions.
    /// @param symbol Bridge token symbol: unique token ID consistent among all chains.
    /// @param token Bridge token address.
    struct BridgeToken {
        string symbol;
        address token;
    }

    /// @notice Initiate a bridge transaction with an optional swap on both origin
    ///         and destination chains.
    /// @dev Note This method is payable.
    ///      If token is ETH_ADDRESS, this method should be invoked with `msg.value = amountIn`.
    ///      If token is ERC20, the tokens will be pulled from msg.sender (use `msg.value = 0`).
    ///      Make sure to approve this contract for spending `token` beforehand.
    ///      originQuery.tokenOut should never be ETH_ADDRESS, bridge only works with ERC20 tokens.
    ///
    ///      `token` is always a token user is sending.
    ///      In case token requires a wrapper token to be bridge,
    ///      use underlying address for `token` instead of the wrapper one.
    ///
    ///      `originQuery` contains instructions for the swap on origin chain.
    ///      As above, originQuery.tokenOut should always use the underlying address.
    ///      In other words, the concept of wrapper token is fully abstracted away from the end user.
    ///
    ///      `originQuery` is supposed to be fetched using SynapseRouter.getOriginAmountOut().
    ///      Alternatively one could use an external adapter for more complex swaps on the origin chain.
    ///
    ///      `destQuery` is supposed to be fetched using SynapseRouter.getDestinationAmountOut().
    ///      Complex swaps on destination chain are not supported for the time being.
    ///      Check contract description above for more details.
    /// @param to Address to receive tokens on destination chain.
    /// @param chainId Destination chain id.
    /// @param token Initial token for the bridge transaction to be pulled from the user.
    /// @param amount Amount of the initial tokens for the bridge transaction.
    /// @param originQuery Origin swap query. Empty struct indicates no swap is required.
    /// @param destQuery Destination swap query. Empty struct indicates no swap is required.
    function bridge(
        address to,
        uint256 chainId,
        address token,
        uint256 amount,
        SwapQuery memory originQuery,
        SwapQuery memory destQuery
    ) external payable;

    /// @notice Finds the best path between `tokenIn` and every supported bridge token
    ///         from the given list, treating the swap as "origin swap",
    ///         without putting any restrictions on the swap.
    /// @dev Will NOT revert if any of the tokens are not supported,
    ///      instead will return an empty query for that symbol.
    ///      Check (query.minAmountOut != 0): this is true only if the swap is possible
    ///      and bridge token is supported.
    ///      The returned queries with minAmountOut != 0 could be used as `originQuery`
    ///      with SynapseRouter.
    /// Note: It is possible to form a SwapQuery off-chain using alternative SwapAdapter
    ///       for the origin swap.
    /// @param tokenIn Initial token that user wants to bridge/swap.
    /// @param tokenSymbols List of symbols representing bridge tokens.
    /// @param amountIn Amount of tokens user wants to bridge/swap.
    /// @return originQueries List of structs that could be used as `originQuery` in SynapseRouter.
    ///                       minAmountOut and deadline fields will need to be adjusted
    ///                       based on the user settings.
    function getOriginAmountOut(
        address tokenIn,
        string[] memory tokenSymbols,
        uint256 amountIn
    ) external view returns (SwapQuery[] memory originQueries);

    /// @notice Finds the best path between every supported bridge token from
    ///         the given list and `tokenOut`, treating the swap as "destination swap",
    ///         limiting possible actions to those available for every bridge token.
    /// @dev Will NOT revert if any of the tokens are not supported,
    ///      instead will return an empty query for that symbol.
    /// Note: It is NOT possible to form a SwapQuery off-chain using alternative SwapAdapter
    ///       for the destination swap.
    ///       For the time being, only swaps through the Synapse-supported pools
    ///       are available on destination chain.
    /// @param requests List of structs with following information:
    ///                 - symbol: unique token ID consistent among all chains.
    ///                 - amountIn: amount of bridge token to start with,
    ///                              before the bridge fee is applied.
    /// @param tokenOut Token user wants to receive on destination chain.
    /// @return destQueries List of structs that could be used as `destQuery` in SynapseRouter.
    ///                     minAmountOut and deadline fields will need to be adjusted based
    ///                     on the user settings.
    function getDestinationAmountOut(
        DestRequest[] memory requests,
        address tokenOut
    ) external view returns (SwapQuery[] memory destQueries);

    /// @notice Gets the list of all bridge tokens (and their symbols),
    ///         such that destination swap from a bridge token to `tokenOut` is possible.
    /// @param tokenOut Token address to swap to on destination chain
    /// @return tokens List of structs with following information:
    ///                - symbol: unique token ID consistent among all chains
    ///                - token: bridge token address
    function getConnectedBridgeTokens(
        address tokenOut
    ) external view returns (BridgeToken[] memory tokens);
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

interface ITeleportGateway {
    /// @notice Initiate DAI transfer.
    /// @param targetDomain Domain of destination chain.
    /// @param receiver Receiver address.
    /// @param amount The amount of DAI to transfer.
    function initiateTeleport(
        bytes32 targetDomain,
        address receiver,
        uint128 amount
    ) external;
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

interface ITokenMessenger {
    /// @notice Deposits and burns tokens from sender to be minted on destination domain.
    /// @dev reverts if:
    ///      - given burnToken is not supported.
    ///      - given destinationDomain has no TokenMessenger registered.
    ///      - transferFrom() reverts. For example, if sender's burnToken balance
    ///        or approved allowance to this contract is less than `amount`.
    ///      - burn() reverts. For example, if `amount` is 0.
    ///      - MessageTransmitter returns false or reverts.
    /// @param amount Amount of tokens to burn.
    /// @param destinationDomain Destination domain.
    /// @param mintRecipient Address of mint recipient on destination domain.
    /// @param burnToken Address of contract to burn deposited tokens, on local domain.
    /// @return nonce Unique nonce reserved by message.
    function depositForBurn(
        uint256 amount,
        uint32 destinationDomain,
        bytes32 mintRecipient,
        address burnToken
    ) external returns (uint64 nonce);
}
// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

interface ITransactionManager {
    // Structs

    // Holds all data that is constant between sending and
    // receiving chains. The hash of this is what gets signed
    // to ensure the signature can be used on both chains.
    struct InvariantTransactionData {
        address receivingChainTxManagerAddress;
        address user;
        address router;
        address initiator; // msg.sender of sending side
        address sendingAssetId;
        address receivingAssetId;
        address sendingChainFallback; // funds sent here on cancel
        address receivingAddress;
        address callTo;
        uint256 sendingChainId;
        uint256 receivingChainId;
        bytes32 callDataHash; // hashed to prevent free option
        bytes32 transactionId;
    }

    // All Transaction data, constant and variable
    struct TransactionData {
        address receivingChainTxManagerAddress;
        address user;
        address router;
        address initiator; // msg.sender of sending side
        address sendingAssetId;
        address receivingAssetId;
        address sendingChainFallback;
        address receivingAddress;
        address callTo;
        bytes32 callDataHash;
        bytes32 transactionId;
        uint256 sendingChainId;
        uint256 receivingChainId;
        uint256 amount;
        uint256 expiry;
        uint256 preparedBlockNumber; // Needed for removal of active blocks on fulfill/cancel
    }

    /**
     * Arguments for calling prepare()
     * @param invariantData The data for a crosschain transaction that will
     *                      not change between sending and receiving chains.
     *                      The hash of this data is used as the key to store
     *                      the inforamtion that does change between chains
     *                      (amount,expiry,preparedBlock) for verification
     * @param amount The amount of the transaction on this chain
     * @param expiry The block.timestamp when the transaction will no longer be
     *               fulfillable and is freely cancellable on this chain
     * @param encryptedCallData The calldata to be executed when the tx is
     *                          fulfilled. Used in the function to allow the user
     *                          to reconstruct the tx from events. Hash is stored
     *                          onchain to prevent shenanigans.
     * @param encodedBid The encoded bid that was accepted by the user for this
     *                   crosschain transfer. It is supplied as a param to the
     *                   function but is only used in event emission
     * @param bidSignature The signature of the bidder on the encoded bid for
     *                     this transaction. Only used within the function for
     *                     event emission. The validity of the bid and
     *                     bidSignature are enforced offchain
     * @param encodedMeta The meta for the function
     */
    struct PrepareArgs {
        InvariantTransactionData invariantData;
        uint256 amount;
        uint256 expiry;
        bytes encryptedCallData;
        bytes encodedBid;
        bytes bidSignature;
        bytes encodedMeta;
    }

    // called in the following order (in happy case)
    // 1. prepare by user on sending chain
    function prepare(
        PrepareArgs calldata args
    ) external payable returns (TransactionData memory);
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

interface IWormholeRouter {
    function transferTokens(
        address token,
        uint256 amount,
        uint16 recipientChain,
        bytes32 recipient,
        uint256 arbiterFee,
        uint32 nonce
    ) external;

    function wrapAndTransferETH(
        uint16 recipientChain,
        bytes32 recipient,
        uint256 arbiterFee,
        uint32 nonce
    ) external payable returns (uint64 sequence);
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

interface IXDaiBridge {
    /// @notice Bridge Dai to xDai and sends to receiver
    /// @dev It's implemented in xDaiBridge on only Ethereum
    /// @param receiver Receiver address
    /// @param amount Dai amount
    function relayTokens(address receiver, uint256 amount) external;
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

interface IXDaiBridgeL2 {
    /// @notice Bridge xDai to DAI and sends to receiver
    /// @dev It's implemented in xDaiBridge on only Gnosis
    /// @param receiver Receiver address
    function relayTokens(address receiver) external payable;
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import { CannotAuthoriseSelf, UnAuthorized } from "../Errors/GenericErrors.sol";

/// @title Access Library
/// @author LI.FI (https://li.fi)
/// @notice Provides functionality for managing method level access control
library LibAccess {
    /// Types ///
    bytes32 internal constant NAMESPACE =
        keccak256("com.lifi.library.access.management");

    /// Storage ///
    struct AccessStorage {
        mapping(bytes4 => mapping(address => bool)) execAccess;
    }

    /// Events ///
    event AccessGranted(address indexed account, bytes4 indexed method);
    event AccessRevoked(address indexed account, bytes4 indexed method);

    /// @dev Fetch local storage
    function accessStorage()
        internal
        pure
        returns (AccessStorage storage accStor)
    {
        bytes32 position = NAMESPACE;
        // solhint-disable-next-line no-inline-assembly
        assembly {
            accStor.slot := position
        }
    }

    /// @notice Gives an address permission to execute a method
    /// @param selector The method selector to execute
    /// @param executor The address to grant permission to
    function addAccess(bytes4 selector, address executor) internal {
        if (executor == address(this)) {
            revert CannotAuthoriseSelf();
        }
        AccessStorage storage accStor = accessStorage();
        accStor.execAccess[selector][executor] = true;
        emit AccessGranted(executor, selector);
    }

    /// @notice Revokes permission to execute a method
    /// @param selector The method selector to execute
    /// @param executor The address to revoke permission from
    function removeAccess(bytes4 selector, address executor) internal {
        AccessStorage storage accStor = accessStorage();
        accStor.execAccess[selector][executor] = false;
        emit AccessRevoked(executor, selector);
    }

    /// @notice Enforces access control by reverting if `msg.sender`
    ///     has not been given permission to execute `msg.sig`
    function enforceAccessControl() internal view {
        AccessStorage storage accStor = accessStorage();
        if (accStor.execAccess[msg.sig][msg.sender] != true)
            revert UnAuthorized();
    }
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import { InvalidContract } from "../Errors/GenericErrors.sol";

/// @title Lib Allow List
/// @author LI.FI (https://li.fi)
/// @notice Library for managing and accessing the conract address allow list
library LibAllowList {
    /// Storage ///
    bytes32 internal constant NAMESPACE =
        keccak256("com.lifi.library.allow.list");

    struct AllowListStorage {
        mapping(address => bool) allowlist;
        mapping(bytes4 => bool) selectorAllowList;
        address[] contracts;
    }

    /// @dev Adds a contract address to the allow list
    /// @param _contract the contract address to add
    function addAllowedContract(address _contract) internal {
        _checkAddress(_contract);

        AllowListStorage storage als = _getStorage();

        if (als.allowlist[_contract]) return;

        als.allowlist[_contract] = true;
        als.contracts.push(_contract);
    }

    /// @dev Checks whether a contract address has been added to the allow list
    /// @param _contract the contract address to check
    function contractIsAllowed(
        address _contract
    ) internal view returns (bool) {
        return _getStorage().allowlist[_contract];
    }

    /// @dev Remove a contract address from the allow list
    /// @param _contract the contract address to remove
    function removeAllowedContract(address _contract) internal {
        AllowListStorage storage als = _getStorage();

        if (!als.allowlist[_contract]) {
            return;
        }

        als.allowlist[_contract] = false;

        uint256 length = als.contracts.length;
        // Find the contract in the list
        for (uint256 i = 0; i < length; i++) {
            if (als.contracts[i] == _contract) {
                // Move the last element into the place to delete
                als.contracts[i] = als.contracts[length - 1];
                // Remove the last element
                als.contracts.pop();
                break;
            }
        }
    }

    /// @dev Fetch contract addresses from the allow list
    function getAllowedContracts() internal view returns (address[] memory) {
        return _getStorage().contracts;
    }

    /// @dev Add a selector to the allow list
    /// @param _selector the selector to add
    function addAllowedSelector(bytes4 _selector) internal {
        _getStorage().selectorAllowList[_selector] = true;
    }

    /// @dev Removes a selector from the allow list
    /// @param _selector the selector to remove
    function removeAllowedSelector(bytes4 _selector) internal {
        _getStorage().selectorAllowList[_selector] = false;
    }

    /// @dev Returns if selector has been added to the allow list
    /// @param _selector the selector to check
    function selectorIsAllowed(bytes4 _selector) internal view returns (bool) {
        return _getStorage().selectorAllowList[_selector];
    }

    /// @dev Fetch local storage struct
    function _getStorage()
        internal
        pure
        returns (AllowListStorage storage als)
    {
        bytes32 position = NAMESPACE;
        // solhint-disable-next-line no-inline-assembly
        assembly {
            als.slot := position
        }
    }

    /// @dev Contains business logic for validating a contract address.
    /// @param _contract address of the dex to check
    function _checkAddress(address _contract) private view {
        if (_contract == address(0)) revert InvalidContract();

        if (_contract.code.length == 0) revert InvalidContract();
    }
}
// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;
import { InsufficientBalance, NullAddrIsNotAnERC20Token, NullAddrIsNotAValidSpender, NoTransferToNullAddress, InvalidAmount, NativeAssetTransferFailed } from "../Errors/GenericErrors.sol";
import "../../lib/openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol";
import "../../lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import { LibSwap } from "./LibSwap.sol";

/// @title LibAsset
/// @notice This library contains helpers for dealing with onchain transfers
///         of assets, including accounting for the native asset `assetId`
///         conventions and any noncompliant ERC20 transfers
library LibAsset {
    uint256 private constant MAX_UINT = type(uint256).max;

    address internal constant NULL_ADDRESS = address(0);

    /// @dev All native assets use the empty address for their asset id
    ///      by convention

    address internal constant NATIVE_ASSETID = NULL_ADDRESS; //address(0)

    /// @notice Gets the balance of the inheriting contract for the given asset
    /// @param assetId The asset identifier to get the balance of
    /// @return Balance held by contracts using this library
    function getOwnBalance(address assetId) internal view returns (uint256) {
        return
            isNativeAsset(assetId)
                ? address(this).balance
                : IERC20(assetId).balanceOf(address(this));
    }

    /// @notice Transfers ether from the inheriting contract to a given
    ///         recipient
    /// @param recipient Address to send ether to
    /// @param amount Amount to send to given recipient
    function transferNativeAsset(
        address payable recipient,
        uint256 amount
    ) private {
        if (recipient == NULL_ADDRESS) revert NoTransferToNullAddress();
        if (amount > address(this).balance)
            revert InsufficientBalance(amount, address(this).balance);
        // solhint-disable-next-line avoid-low-level-calls
        (bool success, ) = recipient.call{ value: amount }("");
        if (!success) revert NativeAssetTransferFailed();
    }

    /// @notice If the current allowance is insufficient, the allowance for a given spender
    /// is set to MAX_UINT.
    /// @param assetId Token address to transfer
    /// @param spender Address to give spend approval to
    /// @param amount Amount to approve for spending
    function maxApproveERC20(
        IERC20 assetId,
        address spender,
        uint256 amount
    ) internal {
        if (isNativeAsset(address(assetId))) {
            return;
        }
        if (spender == NULL_ADDRESS) {
            revert NullAddrIsNotAValidSpender();
        }

        if (assetId.allowance(address(this), spender) < amount) {
            SafeERC20.safeApprove(IERC20(assetId), spender, 0);
            SafeERC20.safeApprove(IERC20(assetId), spender, MAX_UINT);
        }
    }

    /// @notice Transfers tokens from the inheriting contract to a given
    ///         recipient
    /// @param assetId Token address to transfer
    /// @param recipient Address to send token to
    /// @param amount Amount to send to given recipient
    function transferERC20(
        address assetId,
        address recipient,
        uint256 amount
    ) private {
        if (isNativeAsset(assetId)) {
            revert NullAddrIsNotAnERC20Token();
        }
        if (recipient == NULL_ADDRESS) {
            revert NoTransferToNullAddress();
        }

        uint256 assetBalance = IERC20(assetId).balanceOf(address(this));
        if (amount > assetBalance) {
            revert InsufficientBalance(amount, assetBalance);
        }
        SafeERC20.safeTransfer(IERC20(assetId), recipient, amount);
    }

    /// @notice Transfers tokens from a sender to a given recipient
    /// @param assetId Token address to transfer
    /// @param from Address of sender/owner
    /// @param to Address of recipient/spender
    /// @param amount Amount to transfer from owner to spender
    function transferFromERC20(
        address assetId,
        address from,
        address to,
        uint256 amount
    ) internal {
        if (isNativeAsset(assetId)) {
            revert NullAddrIsNotAnERC20Token();
        }
        if (to == NULL_ADDRESS) {
            revert NoTransferToNullAddress();
        }

        IERC20 asset = IERC20(assetId);
        uint256 prevBalance = asset.balanceOf(to);
        SafeERC20.safeTransferFrom(asset, from, to, amount);
        if (asset.balanceOf(to) - prevBalance != amount) {
            revert InvalidAmount();
        }
    }

    function depositAsset(address assetId, uint256 amount) internal {
        if (amount == 0) revert InvalidAmount();
        if (isNativeAsset(assetId)) {
            if (msg.value < amount) revert InvalidAmount();
        } else {
            uint256 balance = IERC20(assetId).balanceOf(msg.sender);
            if (balance < amount) revert InsufficientBalance(amount, balance);
            transferFromERC20(assetId, msg.sender, address(this), amount);
        }
    }

    function depositAssets(LibSwap.SwapData[] calldata swaps) internal {
        for (uint256 i = 0; i < swaps.length; ) {
            LibSwap.SwapData calldata swap = swaps[i];
            if (swap.requiresDeposit) {
                depositAsset(swap.sendingAssetId, swap.fromAmount);
            }
            unchecked {
                i++;
            }
        }
    }

    /// @notice Determines whether the given assetId is the native asset
    /// @param assetId The asset identifier to evaluate
    /// @return Boolean indicating if the asset is the native asset
    function isNativeAsset(address assetId) internal pure returns (bool) {
        return assetId == NATIVE_ASSETID;
    }

    /// @notice Wrapper function to transfer a given asset (native or erc20) to
    ///         some recipient. Should handle all non-compliant return value
    ///         tokens as well by using the SafeERC20 contract by open zeppelin.
    /// @param assetId Asset id for transfer (address(0) for native asset,
    ///                token address for erc20s)
    /// @param recipient Address to send asset to
    /// @param amount Amount to send to given recipient
    function transferAsset(
        address assetId,
        address payable recipient,
        uint256 amount
    ) internal {
        isNativeAsset(assetId)
            ? transferNativeAsset(recipient, amount)
            : transferERC20(assetId, recipient, amount);
    }

    /// @dev Checks whether the given address is a contract and contains code
    function isContract(address _contractAddr) internal view returns (bool) {
        uint256 size;
        // solhint-disable-next-line no-inline-assembly
        assembly {
            size := extcodesize(_contractAddr)
        }
        return size > 0;
    }
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

library LibBytes {
    // solhint-disable no-inline-assembly

    // LibBytes specific errors
    error SliceOverflow();
    error SliceOutOfBounds();
    error AddressOutOfBounds();

    bytes16 private constant _SYMBOLS = "0123456789abcdef";

    // -------------------------

    function slice(
        bytes memory _bytes,
        uint256 _start,
        uint256 _length
    ) internal pure returns (bytes memory) {
        if (_length + 31 < _length) revert SliceOverflow();
        if (_bytes.length < _start + _length) revert SliceOutOfBounds();

        bytes memory tempBytes;

        assembly {
            switch iszero(_length)
            case 0 {
                // Get a location of some free memory and store it in tempBytes as
                // Solidity does for memory variables.
                tempBytes := mload(0x40)

                // The first word of the slice result is potentially a partial
                // word read from the original array. To read it, we calculate
                // the length of that partial word and start copying that many
                // bytes into the array. The first word we copy will start with
                // data we don't care about, but the last `lengthmod` bytes will
                // land at the beginning of the contents of the new array. When
                // we're done copying, we overwrite the full first word with
                // the actual length of the slice.
                let lengthmod := and(_length, 31)

                // The multiplication in the next line is necessary
                // because when slicing multiples of 32 bytes (lengthmod == 0)
                // the following copy loop was copying the origin's length
                // and then ending prematurely not copying everything it should.
                let mc := add(
                    add(tempBytes, lengthmod),
                    mul(0x20, iszero(lengthmod))
                )
                let end := add(mc, _length)

                for {
                    // The multiplication in the next line has the same exact purpose
                    // as the one above.
                    let cc := add(
                        add(
                            add(_bytes, lengthmod),
                            mul(0x20, iszero(lengthmod))
                        ),
                        _start
                    )
                } lt(mc, end) {
                    mc := add(mc, 0x20)
                    cc := add(cc, 0x20)
                } {
                    mstore(mc, mload(cc))
                }

                mstore(tempBytes, _length)

                //update free-memory pointer
                //allocating the array padded to 32 bytes like the compiler does now
                mstore(0x40, and(add(mc, 31), not(31)))
            }
            //if we want a zero-length slice let's just return a zero-length array
            default {
                tempBytes := mload(0x40)
                //zero out the 32 bytes slice we are about to return
                //we need to do it because Solidity does not garbage collect
                mstore(tempBytes, 0)

                mstore(0x40, add(tempBytes, 0x20))
            }
        }

        return tempBytes;
    }

    function toAddress(
        bytes memory _bytes,
        uint256 _start
    ) internal pure returns (address) {
        if (_bytes.length < _start + 20) {
            revert AddressOutOfBounds();
        }
        address tempAddress;

        assembly {
            tempAddress := div(
                mload(add(add(_bytes, 0x20), _start)),
                0x1000000000000000000000000
            )
        }

        return tempAddress;
    }

    /// Copied from OpenZeppelin's `Strings.sol` utility library.
    /// https://github.com/OpenZeppelin/openzeppelin-contracts/blob/8335676b0e99944eef6a742e16dcd9ff6e68e609/contracts/utils/Strings.sol
    function toHexString(
        uint256 value,
        uint256 length
    ) internal pure returns (string memory) {
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import { IDiamondCut } from "../Interfaces/IDiamondCut.sol";
import { LibUtil } from "../Libraries/LibUtil.sol";
import { OnlyContractOwner } from "../Errors/GenericErrors.sol";

/// Implementation of EIP-2535 Diamond Standard
/// https://eips.ethereum.org/EIPS/eip-2535
library LibDiamond {
    bytes32 internal constant DIAMOND_STORAGE_POSITION =
        keccak256("diamond.standard.diamond.storage");

    // Diamond specific errors
    error IncorrectFacetCutAction();
    error NoSelectorsInFace();
    error FunctionAlreadyExists();
    error FacetAddressIsZero();
    error FacetAddressIsNotZero();
    error FacetContainsNoCode();
    error FunctionDoesNotExist();
    error FunctionIsImmutable();
    error InitZeroButCalldataNotEmpty();
    error CalldataEmptyButInitNotZero();
    error InitReverted();
    // ----------------

    struct FacetAddressAndPosition {
        address facetAddress;
        uint96 functionSelectorPosition; // position in facetFunctionSelectors.functionSelectors array
    }

    struct FacetFunctionSelectors {
        bytes4[] functionSelectors;
        uint256 facetAddressPosition; // position of facetAddress in facetAddresses array
    }

    struct DiamondStorage {
        // maps function selector to the facet address and
        // the position of the selector in the facetFunctionSelectors.selectors array
        mapping(bytes4 => FacetAddressAndPosition) selectorToFacetAndPosition;
        // maps facet addresses to function selectors
        mapping(address => FacetFunctionSelectors) facetFunctionSelectors;
        // facet addresses
        address[] facetAddresses;
        // Used to query if a contract implements an interface.
        // Used to implement ERC-165.
        mapping(bytes4 => bool) supportedInterfaces;
        // owner of the contract
        address contractOwner;
    }

    function diamondStorage()
        internal
        pure
        returns (DiamondStorage storage ds)
    {
        bytes32 position = DIAMOND_STORAGE_POSITION;
        // solhint-disable-next-line no-inline-assembly
        assembly {
            ds.slot := position
        }
    }

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    function setContractOwner(address _newOwner) internal {
        DiamondStorage storage ds = diamondStorage();
        address previousOwner = ds.contractOwner;
        ds.contractOwner = _newOwner;
        emit OwnershipTransferred(previousOwner, _newOwner);
    }

    function contractOwner() internal view returns (address contractOwner_) {
        contractOwner_ = diamondStorage().contractOwner;
    }

    function enforceIsContractOwner() internal view {
        if (msg.sender != diamondStorage().contractOwner)
            revert OnlyContractOwner();
    }

    event DiamondCut(
        IDiamondCut.FacetCut[] _diamondCut,
        address _init,
        bytes _calldata
    );

    // Internal function version of diamondCut
    function diamondCut(
        IDiamondCut.FacetCut[] memory _diamondCut,
        address _init,
        bytes memory _calldata
    ) internal {
        for (uint256 facetIndex; facetIndex < _diamondCut.length; ) {
            IDiamondCut.FacetCutAction action = _diamondCut[facetIndex].action;
            if (action == IDiamondCut.FacetCutAction.Add) {
                addFunctions(
                    _diamondCut[facetIndex].facetAddress,
                    _diamondCut[facetIndex].functionSelectors
                );
            } else if (action == IDiamondCut.FacetCutAction.Replace) {
                replaceFunctions(
                    _diamondCut[facetIndex].facetAddress,
                    _diamondCut[facetIndex].functionSelectors
                );
            } else if (action == IDiamondCut.FacetCutAction.Remove) {
                removeFunctions(
                    _diamondCut[facetIndex].facetAddress,
                    _diamondCut[facetIndex].functionSelectors
                );
            } else {
                revert IncorrectFacetCutAction();
            }
            unchecked {
                ++facetIndex;
            }
        }
        emit DiamondCut(_diamondCut, _init, _calldata);
        initializeDiamondCut(_init, _calldata);
    }

    function addFunctions(
        address _facetAddress,
        bytes4[] memory _functionSelectors
    ) internal {
        if (_functionSelectors.length == 0) {
            revert NoSelectorsInFace();
        }
        DiamondStorage storage ds = diamondStorage();
        if (LibUtil.isZeroAddress(_facetAddress)) {
            revert FacetAddressIsZero();
        }
        uint96 selectorPosition = uint96(
            ds.facetFunctionSelectors[_facetAddress].functionSelectors.length
        );
        // add new facet address if it does not exist
        if (selectorPosition == 0) {
            addFacet(ds, _facetAddress);
        }
        for (
            uint256 selectorIndex;
            selectorIndex < _functionSelectors.length;

        ) {
            bytes4 selector = _functionSelectors[selectorIndex];
            address oldFacetAddress = ds
                .selectorToFacetAndPosition[selector]
                .facetAddress;
            if (!LibUtil.isZeroAddress(oldFacetAddress)) {
                revert FunctionAlreadyExists();
            }
            addFunction(ds, selector, selectorPosition, _facetAddress);
            unchecked {
                ++selectorPosition;
                ++selectorIndex;
            }
        }
    }

    function replaceFunctions(
        address _facetAddress,
        bytes4[] memory _functionSelectors
    ) internal {
        if (_functionSelectors.length == 0) {
            revert NoSelectorsInFace();
        }
        DiamondStorage storage ds = diamondStorage();
        if (LibUtil.isZeroAddress(_facetAddress)) {
            revert FacetAddressIsZero();
        }
        uint96 selectorPosition = uint96(
            ds.facetFunctionSelectors[_facetAddress].functionSelectors.length
        );
        // add new facet address if it does not exist
        if (selectorPosition == 0) {
            addFacet(ds, _facetAddress);
        }
        for (
            uint256 selectorIndex;
            selectorIndex < _functionSelectors.length;

        ) {
            bytes4 selector = _functionSelectors[selectorIndex];
            address oldFacetAddress = ds
                .selectorToFacetAndPosition[selector]
                .facetAddress;
            if (oldFacetAddress == _facetAddress) {
                revert FunctionAlreadyExists();
            }
            removeFunction(ds, oldFacetAddress, selector);
            addFunction(ds, selector, selectorPosition, _facetAddress);
            unchecked {
                ++selectorPosition;
                ++selectorIndex;
            }
        }
    }

    function removeFunctions(
        address _facetAddress,
        bytes4[] memory _functionSelectors
    ) internal {
        if (_functionSelectors.length == 0) {
            revert NoSelectorsInFace();
        }
        DiamondStorage storage ds = diamondStorage();
        // if function does not exist then do nothing and return
        if (!LibUtil.isZeroAddress(_facetAddress)) {
            revert FacetAddressIsNotZero();
        }
        for (
            uint256 selectorIndex;
            selectorIndex < _functionSelectors.length;

        ) {
            bytes4 selector = _functionSelectors[selectorIndex];
            address oldFacetAddress = ds
                .selectorToFacetAndPosition[selector]
                .facetAddress;
            removeFunction(ds, oldFacetAddress, selector);
            unchecked {
                ++selectorIndex;
            }
        }
    }

    function addFacet(
        DiamondStorage storage ds,
        address _facetAddress
    ) internal {
        enforceHasContractCode(_facetAddress);
        ds.facetFunctionSelectors[_facetAddress].facetAddressPosition = ds
            .facetAddresses
            .length;
        ds.facetAddresses.push(_facetAddress);
    }

    function addFunction(
        DiamondStorage storage ds,
        bytes4 _selector,
        uint96 _selectorPosition,
        address _facetAddress
    ) internal {
        ds
            .selectorToFacetAndPosition[_selector]
            .functionSelectorPosition = _selectorPosition;
        ds.facetFunctionSelectors[_facetAddress].functionSelectors.push(
            _selector
        );
        ds.selectorToFacetAndPosition[_selector].facetAddress = _facetAddress;
    }

    function removeFunction(
        DiamondStorage storage ds,
        address _facetAddress,
        bytes4 _selector
    ) internal {
        if (LibUtil.isZeroAddress(_facetAddress)) {
            revert FunctionDoesNotExist();
        }
        // an immutable function is a function defined directly in a diamond
        if (_facetAddress == address(this)) {
            revert FunctionIsImmutable();
        }
        // replace selector with last selector, then delete last selector
        uint256 selectorPosition = ds
            .selectorToFacetAndPosition[_selector]
            .functionSelectorPosition;
        uint256 lastSelectorPosition = ds
            .facetFunctionSelectors[_facetAddress]
            .functionSelectors
            .length - 1;
        // if not the same then replace _selector with lastSelector
        if (selectorPosition != lastSelectorPosition) {
            bytes4 lastSelector = ds
                .facetFunctionSelectors[_facetAddress]
                .functionSelectors[lastSelectorPosition];
            ds.facetFunctionSelectors[_facetAddress].functionSelectors[
                selectorPosition
            ] = lastSelector;
            ds
                .selectorToFacetAndPosition[lastSelector]
                .functionSelectorPosition = uint96(selectorPosition);
        }
        // delete the last selector
        ds.facetFunctionSelectors[_facetAddress].functionSelectors.pop();
        delete ds.selectorToFacetAndPosition[_selector];

        // if no more selectors for facet address then delete the facet address
        if (lastSelectorPosition == 0) {
            // replace facet address with last facet address and delete last facet address
            uint256 lastFacetAddressPosition = ds.facetAddresses.length - 1;
            uint256 facetAddressPosition = ds
                .facetFunctionSelectors[_facetAddress]
                .facetAddressPosition;
            if (facetAddressPosition != lastFacetAddressPosition) {
                address lastFacetAddress = ds.facetAddresses[
                    lastFacetAddressPosition
                ];
                ds.facetAddresses[facetAddressPosition] = lastFacetAddress;
                ds
                    .facetFunctionSelectors[lastFacetAddress]
                    .facetAddressPosition = facetAddressPosition;
            }
            ds.facetAddresses.pop();
            delete ds
                .facetFunctionSelectors[_facetAddress]
                .facetAddressPosition;
        }
    }

    function initializeDiamondCut(
        address _init,
        bytes memory _calldata
    ) internal {
        if (LibUtil.isZeroAddress(_init)) {
            if (_calldata.length != 0) {
                revert InitZeroButCalldataNotEmpty();
            }
        } else {
            if (_calldata.length == 0) {
                revert CalldataEmptyButInitNotZero();
            }
            if (_init != address(this)) {
                enforceHasContractCode(_init);
            }
            // solhint-disable-next-line avoid-low-level-calls
            (bool success, bytes memory error) = _init.delegatecall(_calldata);
            if (!success) {
                if (error.length > 0) {
                    // bubble up the error
                    revert(string(error));
                } else {
                    revert InitReverted();
                }
            }
        }
    }

    function enforceHasContractCode(address _contract) internal view {
        uint256 contractSize;
        // solhint-disable-next-line no-inline-assembly
        assembly {
            contractSize := extcodesize(_contract)
        }
        if (contractSize == 0) {
            revert FacetContainsNoCode();
        }
    }
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import { LibAsset } from "./LibAsset.sol";
import { LibUtil } from "./LibUtil.sol";
import { InvalidContract, NoSwapFromZeroBalance, InsufficientBalance } from "../Errors/GenericErrors.sol";
import { IERC20 } from "../../lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";

library LibSwap {
    struct SwapData {
        address callTo;
        address approveTo;
        address sendingAssetId;
        address receivingAssetId;
        uint256 fromAmount;
        bytes callData;
        bool requiresDeposit;
    }

    event AssetSwapped(
        bytes32 transactionId,
        address dex,
        address fromAssetId,
        address toAssetId,
        uint256 fromAmount,
        uint256 toAmount,
        uint256 timestamp
    );

    function swap(bytes32 transactionId, SwapData calldata _swap) internal {
        if (!LibAsset.isContract(_swap.callTo)) revert InvalidContract();
        uint256 fromAmount = _swap.fromAmount;
        if (fromAmount == 0) revert NoSwapFromZeroBalance();
        uint256 nativeValue = LibAsset.isNativeAsset(_swap.sendingAssetId)
            ? _swap.fromAmount
            : 0;
        uint256 initialSendingAssetBalance = LibAsset.getOwnBalance(
            _swap.sendingAssetId
        );
        uint256 initialReceivingAssetBalance = LibAsset.getOwnBalance(
            _swap.receivingAssetId
        );

        if (nativeValue == 0) {
            LibAsset.maxApproveERC20(
                IERC20(_swap.sendingAssetId),
                _swap.approveTo,
                _swap.fromAmount
            );
        }

        if (initialSendingAssetBalance < _swap.fromAmount) {
            revert InsufficientBalance(
                _swap.fromAmount,
                initialSendingAssetBalance
            );
        }

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory res) = _swap.callTo.call{
            value: nativeValue
        }(_swap.callData);
        if (!success) {
            string memory reason = LibUtil.getRevertMsg(res);
            revert(reason);
        }

        uint256 newBalance = LibAsset.getOwnBalance(_swap.receivingAssetId);

        emit AssetSwapped(
            transactionId,
            _swap.callTo,
            _swap.sendingAssetId,
            _swap.receivingAssetId,
            _swap.fromAmount,
            newBalance > initialReceivingAssetBalance
                ? newBalance - initialReceivingAssetBalance
                : newBalance,
            block.timestamp
        );
    }
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "./LibBytes.sol";

library LibUtil {
    using LibBytes for bytes;

    function getRevertMsg(
        bytes memory _res
    ) internal pure returns (string memory) {
        // If the _res length is less than 68, then the transaction failed silently (without a revert message)
        if (_res.length < 68) return "Transaction reverted silently";
        bytes memory revertData = _res.slice(4, _res.length - 4); // Remove the selector which is the first 4 bytes
        return abi.decode(revertData, (string)); // All that remains is the revert string
    }

    /// @notice Determines whether the given address is the zero address
    /// @param addr The address to verify
    /// @return Boolean indicating if the address is the zero address
    function isZeroAddress(address addr) internal pure returns (bool) {
        return addr == address(0);
    }
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import { Ownable } from "../../lib/openzeppelin-contracts/contracts/access/Ownable.sol";
import { LibAsset } from "../Libraries/LibAsset.sol";

/// @title ERC20 Proxy
/// @author LI.FI (https://li.fi)
/// @notice Proxy contract for safely transferring ERC20 tokens for swaps/executions
/// @custom:version 1.0.0
contract ERC20Proxy is Ownable {
    /// Storage ///
    mapping(address => bool) public authorizedCallers;

    /// Errors ///
    error UnAuthorized();

    /// Events ///
    event AuthorizationChanged(address indexed caller, bool authorized);

    /// Constructor
    constructor(address _owner) {
        transferOwnership(_owner);
    }

    /// @notice Sets whether or not a specified caller is authorized to call this contract
    /// @param caller the caller to change authorization for
    /// @param authorized specifies whether the caller is authorized (true/false)
    function setAuthorizedCaller(
        address caller,
        bool authorized
    ) external onlyOwner {
        authorizedCallers[caller] = authorized;
        emit AuthorizationChanged(caller, authorized);
    }

    /// @notice Transfers tokens from one address to another specified address
    /// @param tokenAddress the ERC20 contract address of the token to send
    /// @param from the address to transfer from
    /// @param to the address to transfer to
    /// @param amount the amount of tokens to send
    function transferFrom(
        address tokenAddress,
        address from,
        address to,
        uint256 amount
    ) external {
        if (!authorizedCallers[msg.sender]) revert UnAuthorized();

        LibAsset.transferFromERC20(tokenAddress, from, to, amount);
    }
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import { ReentrancyGuard } from "../Helpers/ReentrancyGuard.sol";
import { LibSwap } from "../Libraries/LibSwap.sol";
import { LibAsset } from "../Libraries/LibAsset.sol";
import { UnAuthorized } from "../../src/Errors/GenericErrors.sol";
import { ILiFi } from "../Interfaces/ILiFi.sol";
import { IERC20Proxy } from "../Interfaces/IERC20Proxy.sol";
import { ERC1155Holder } from "../../lib/openzeppelin-contracts/contracts/token/ERC1155/utils/ERC1155Holder.sol";
import { ERC721Holder } from "../../lib/openzeppelin-contracts/contracts/token/ERC721/utils/ERC721Holder.sol";
import { IERC20 } from "../../lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";

/// @title Executor
/// @author LI.FI (https://li.fi)
/// @notice Arbitrary execution contract used for cross-chain swaps and message passing
/// @custom:version 2.0.0
contract Executor is ILiFi, ReentrancyGuard, ERC1155Holder, ERC721Holder {
    /// Storage ///

    /// @notice The address of the ERC20Proxy contract
    IERC20Proxy public erc20Proxy;

    /// Events ///
    event ERC20ProxySet(address indexed proxy);

    /// Modifiers ///

    /// @dev Sends any leftover balances back to the user
    modifier noLeftovers(
        LibSwap.SwapData[] calldata _swaps,
        address payable _leftoverReceiver
    ) {
        uint256 numSwaps = _swaps.length;
        if (numSwaps != 1) {
            uint256[] memory initialBalances = _fetchBalances(_swaps);
            address finalAsset = _swaps[numSwaps - 1].receivingAssetId;
            uint256 curBalance = 0;

            _;

            for (uint256 i = 0; i < numSwaps - 1; ) {
                address curAsset = _swaps[i].receivingAssetId;
                // Handle multi-to-one swaps
                if (curAsset != finalAsset) {
                    curBalance = LibAsset.getOwnBalance(curAsset);
                    if (curBalance > initialBalances[i]) {
                        LibAsset.transferAsset(
                            curAsset,
                            _leftoverReceiver,
                            curBalance - initialBalances[i]
                        );
                    }
                }
                unchecked {
                    ++i;
                }
            }
        } else {
            _;
        }
    }

    /// Constructor
    /// @notice Initialize local variables for the Executor
    /// @param _erc20Proxy The address of the ERC20Proxy contract
    constructor(address _erc20Proxy) {
        erc20Proxy = IERC20Proxy(_erc20Proxy);
        emit ERC20ProxySet(_erc20Proxy);
    }

    /// External Methods ///

    /// @notice Performs a swap before completing a cross-chain transaction
    /// @param _transactionId the transaction id for the swap
    /// @param _swapData array of data needed for swaps
    /// @param _transferredAssetId token received from the other chain
    /// @param _receiver address that will receive tokens in the end
    function swapAndCompleteBridgeTokens(
        bytes32 _transactionId,
        LibSwap.SwapData[] calldata _swapData,
        address _transferredAssetId,
        address payable _receiver
    ) external payable nonReentrant {
        _processSwaps(
            _transactionId,
            _swapData,
            _transferredAssetId,
            _receiver,
            0,
            true
        );
    }

    /// @notice Performs a series of swaps or arbitrary executions
    /// @param _transactionId the transaction id for the swap
    /// @param _swapData array of data needed for swaps
    /// @param _transferredAssetId token received from the other chain
    /// @param _receiver address that will receive tokens in the end
    /// @param _amount amount of token for swaps or arbitrary executions
    function swapAndExecute(
        bytes32 _transactionId,
        LibSwap.SwapData[] calldata _swapData,
        address _transferredAssetId,
        address payable _receiver,
        uint256 _amount
    ) external payable nonReentrant {
        _processSwaps(
            _transactionId,
            _swapData,
            _transferredAssetId,
            _receiver,
            _amount,
            false
        );
    }

    /// Private Methods ///

    /// @notice Performs a series of swaps or arbitrary executions
    /// @param _transactionId the transaction id for the swap
    /// @param _swapData array of data needed for swaps
    /// @param _transferredAssetId token received from the other chain
    /// @param _receiver address that will receive tokens in the end
    /// @param _amount amount of token for swaps or arbitrary executions
    /// @param _depositAllowance If deposit approved amount of token
    function _processSwaps(
        bytes32 _transactionId,
        LibSwap.SwapData[] calldata _swapData,
        address _transferredAssetId,
        address payable _receiver,
        uint256 _amount,
        bool _depositAllowance
    ) private {
        uint256 startingBalance;
        uint256 finalAssetStartingBalance;
        address finalAssetId = _swapData[_swapData.length - 1]
            .receivingAssetId;
        if (!LibAsset.isNativeAsset(finalAssetId)) {
            finalAssetStartingBalance = LibAsset.getOwnBalance(finalAssetId);
        } else {
            finalAssetStartingBalance =
                LibAsset.getOwnBalance(finalAssetId) -
                msg.value;
        }

        if (!LibAsset.isNativeAsset(_transferredAssetId)) {
            startingBalance = LibAsset.getOwnBalance(_transferredAssetId);
            if (_depositAllowance) {
                uint256 allowance = IERC20(_transferredAssetId).allowance(
                    msg.sender,
                    address(this)
                );
                LibAsset.depositAsset(_transferredAssetId, allowance);
            } else {
                erc20Proxy.transferFrom(
                    _transferredAssetId,
                    msg.sender,
                    address(this),
                    _amount
                );
            }
        } else {
            startingBalance =
                LibAsset.getOwnBalance(_transferredAssetId) -
                msg.value;
        }

        _executeSwaps(_transactionId, _swapData, _receiver);

        uint256 postSwapBalance = LibAsset.getOwnBalance(_transferredAssetId);
        if (postSwapBalance > startingBalance) {
            LibAsset.transferAsset(
                _transferredAssetId,
                _receiver,
                postSwapBalance - startingBalance
            );
        }

        uint256 finalAssetPostSwapBalance = LibAsset.getOwnBalance(
            finalAssetId
        );

        if (finalAssetPostSwapBalance > finalAssetStartingBalance) {
            LibAsset.transferAsset(
                finalAssetId,
                _receiver,
                finalAssetPostSwapBalance - finalAssetStartingBalance
            );
        }

        emit LiFiTransferCompleted(
            _transactionId,
            _transferredAssetId,
            _receiver,
            finalAssetPostSwapBalance,
            block.timestamp
        );
    }

    /// @dev Executes swaps one after the other
    /// @param _transactionId the transaction id for the swap
    /// @param _swapData Array of data used to execute swaps
    /// @param _leftoverReceiver Address to receive lefover tokens
    function _executeSwaps(
        bytes32 _transactionId,
        LibSwap.SwapData[] calldata _swapData,
        address payable _leftoverReceiver
    ) private noLeftovers(_swapData, _leftoverReceiver) {
        uint256 numSwaps = _swapData.length;
        for (uint256 i = 0; i < numSwaps; ) {
            if (_swapData[i].callTo == address(erc20Proxy)) {
                revert UnAuthorized(); // Prevent calling ERC20 Proxy directly
            }

            LibSwap.SwapData calldata currentSwapData = _swapData[i];
            LibSwap.swap(_transactionId, currentSwapData);
            unchecked {
                ++i;
            }
        }
    }

    /// @dev Fetches balances of tokens to be swapped before swapping.
    /// @param _swapData Array of data used to execute swaps
    /// @return uint256[] Array of token balances.
    function _fetchBalances(
        LibSwap.SwapData[] calldata _swapData
    ) private view returns (uint256[] memory) {
        uint256 numSwaps = _swapData.length;
        uint256[] memory balances = new uint256[](numSwaps);
        address asset;
        for (uint256 i = 0; i < numSwaps; ) {
            asset = _swapData[i].receivingAssetId;
            balances[i] = LibAsset.getOwnBalance(asset);

            if (LibAsset.isNativeAsset(asset)) {
                balances[i] -= msg.value;
            }

            unchecked {
                ++i;
            }
        }

        return balances;
    }

    /// @dev required for receiving native assets from destination swaps
    // solhint-disable-next-line no-empty-blocks
    receive() external payable {}
}
// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import { LibAsset } from "../Libraries/LibAsset.sol";
import { TransferrableOwnership } from "../Helpers/TransferrableOwnership.sol";

/// @title Fee Collector
/// @author LI.FI (https://li.fi)
/// @notice Provides functionality for collecting integrator fees
/// @custom:version 1.0.0
contract FeeCollector is TransferrableOwnership {
    /// State ///

    // Integrator -> TokenAddress -> Balance
    mapping(address => mapping(address => uint256)) private _balances;
    // TokenAddress -> Balance
    mapping(address => uint256) private _lifiBalances;

    /// Errors ///
    error TransferFailure();
    error NotEnoughNativeForFees();

    /// Events ///
    event FeesCollected(
        address indexed _token,
        address indexed _integrator,
        uint256 _integratorFee,
        uint256 _lifiFee
    );
    event FeesWithdrawn(
        address indexed _token,
        address indexed _to,
        uint256 _amount
    );
    event LiFiFeesWithdrawn(
        address indexed _token,
        address indexed _to,
        uint256 _amount
    );

    /// Constructor ///

    // solhint-disable-next-line no-empty-blocks
    constructor(address _owner) TransferrableOwnership(_owner) {}

    /// External Methods ///

    /// @notice Collects fees for the integrator
    /// @param tokenAddress address of the token to collect fees for
    /// @param integratorFee amount of fees to collect going to the integrator
    /// @param lifiFee amount of fees to collect going to lifi
    /// @param integratorAddress address of the integrator
    function collectTokenFees(
        address tokenAddress,
        uint256 integratorFee,
        uint256 lifiFee,
        address integratorAddress
    ) external {
        LibAsset.depositAsset(tokenAddress, integratorFee + lifiFee);
        _balances[integratorAddress][tokenAddress] += integratorFee;
        _lifiBalances[tokenAddress] += lifiFee;
        emit FeesCollected(
            tokenAddress,
            integratorAddress,
            integratorFee,
            lifiFee
        );
    }

    /// @notice Collects fees for the integrator in native token
    /// @param integratorFee amount of fees to collect going to the integrator
    /// @param lifiFee amount of fees to collect going to lifi
    /// @param integratorAddress address of the integrator
    function collectNativeFees(
        uint256 integratorFee,
        uint256 lifiFee,
        address integratorAddress
    ) external payable {
        if (msg.value < integratorFee + lifiFee)
            revert NotEnoughNativeForFees();
        _balances[integratorAddress][LibAsset.NULL_ADDRESS] += integratorFee;
        _lifiBalances[LibAsset.NULL_ADDRESS] += lifiFee;
        uint256 remaining = msg.value - (integratorFee + lifiFee);
        // Prevent extra native token from being locked in the contract
        if (remaining > 0) {
            // solhint-disable-next-line avoid-low-level-calls
            (bool success, ) = payable(msg.sender).call{ value: remaining }(
                ""
            );
            if (!success) {
                revert TransferFailure();
            }
        }
        emit FeesCollected(
            LibAsset.NULL_ADDRESS,
            integratorAddress,
            integratorFee,
            lifiFee
        );
    }

    /// @notice Withdraw fees and sends to the integrator
    /// @param tokenAddress address of the token to withdraw fees for
    function withdrawIntegratorFees(address tokenAddress) external {
        uint256 balance = _balances[msg.sender][tokenAddress];
        if (balance == 0) {
            return;
        }
        _balances[msg.sender][tokenAddress] = 0;
        LibAsset.transferAsset(tokenAddress, payable(msg.sender), balance);
        emit FeesWithdrawn(tokenAddress, msg.sender, balance);
    }

    /// @notice Batch withdraw fees and sends to the integrator
    /// @param tokenAddresses addresses of the tokens to withdraw fees for
    function batchWithdrawIntegratorFees(
        address[] memory tokenAddresses
    ) external {
        uint256 length = tokenAddresses.length;
        uint256 balance;
        for (uint256 i = 0; i < length; ) {
            balance = _balances[msg.sender][tokenAddresses[i]];
            if (balance != 0) {
                _balances[msg.sender][tokenAddresses[i]] = 0;
                LibAsset.transferAsset(
                    tokenAddresses[i],
                    payable(msg.sender),
                    balance
                );
                emit FeesWithdrawn(tokenAddresses[i], msg.sender, balance);
            }
            unchecked {
                ++i;
            }
        }
    }

    /// @notice Withdraws fees and sends to lifi
    /// @param tokenAddress address of the token to withdraw fees for
    function withdrawLifiFees(address tokenAddress) external onlyOwner {
        uint256 balance = _lifiBalances[tokenAddress];
        if (balance == 0) {
            return;
        }
        _lifiBalances[tokenAddress] = 0;
        LibAsset.transferAsset(tokenAddress, payable(msg.sender), balance);
        emit LiFiFeesWithdrawn(tokenAddress, msg.sender, balance);
    }

    /// @notice Batch withdraws fees and sends to lifi
    /// @param tokenAddresses addresses of the tokens to withdraw fees for
    function batchWithdrawLifiFees(
        address[] memory tokenAddresses
    ) external onlyOwner {
        uint256 length = tokenAddresses.length;
        uint256 balance;
        for (uint256 i = 0; i < length; ) {
            balance = _lifiBalances[tokenAddresses[i]];
            _lifiBalances[tokenAddresses[i]] = 0;
            LibAsset.transferAsset(
                tokenAddresses[i],
                payable(msg.sender),
                balance
            );
            emit LiFiFeesWithdrawn(tokenAddresses[i], msg.sender, balance);
            unchecked {
                ++i;
            }
        }
    }

    /// @notice Returns the balance of the integrator
    /// @param integratorAddress address of the integrator
    /// @param tokenAddress address of the token to get the balance of
    function getTokenBalance(
        address integratorAddress,
        address tokenAddress
    ) external view returns (uint256) {
        return _balances[integratorAddress][tokenAddress];
    }

    /// @notice Returns the balance of lifi
    /// @param tokenAddress address of the token to get the balance of
    function getLifiTokenBalance(
        address tokenAddress
    ) external view returns (uint256) {
        return _lifiBalances[tokenAddress];
    }
}
// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import { LibAsset } from "../Libraries/LibAsset.sol";
import { TransferrableOwnership } from "../Helpers/TransferrableOwnership.sol";

/// @title LiFuelFeeCollector
/// @author LI.FI (https://li.fi)
/// @notice Provides functionality for collecting fees for LiFuel
/// @custom:version 1.0.0
contract LiFuelFeeCollector is TransferrableOwnership {
    /// Errors ///
    error TransferFailure();
    error NotEnoughNativeForFees();

    /// Events ///
    event GasFeesCollected(
        address indexed token,
        uint256 indexed chainId,
        address indexed receiver,
        uint256 feeAmount
    );

    event FeesWithdrawn(
        address indexed token,
        address indexed to,
        uint256 amount
    );

    /// Constructor ///

    // solhint-disable-next-line no-empty-blocks
    constructor(address _owner) TransferrableOwnership(_owner) {}

    /// External Methods ///

    /// @notice Collects gas fees
    /// @param tokenAddress The address of the token to collect
    /// @param feeAmount The amount of fees to collect
    /// @param chainId The chain id of the destination chain
    /// @param receiver The address to send gas to on the destination chain
    function collectTokenGasFees(
        address tokenAddress,
        uint256 feeAmount,
        uint256 chainId,
        address receiver
    ) external {
        LibAsset.depositAsset(tokenAddress, feeAmount);
        emit GasFeesCollected(tokenAddress, chainId, receiver, feeAmount);
    }

    /// @notice Collects gas fees in native token
    /// @param chainId The chain id of the destination chain
    /// @param receiver The address to send gas to on destination chain
    function collectNativeGasFees(
        uint256 chainId,
        address receiver
    ) external payable {
        emit GasFeesCollected(
            LibAsset.NULL_ADDRESS,
            chainId,
            receiver,
            msg.value
        );
    }

    /// @notice Withdraws fees
    /// @param tokenAddress The address of the token to withdraw fees for
    function withdrawFees(address tokenAddress) external onlyOwner {
        uint256 balance = LibAsset.getOwnBalance(tokenAddress);
        LibAsset.transferAsset(tokenAddress, payable(msg.sender), balance);
        emit FeesWithdrawn(tokenAddress, msg.sender, balance);
    }

    /// @notice Batch withdraws fees
    /// @param tokenAddresses The addresses of the tokens to withdraw fees for
    function batchWithdrawFees(
        address[] calldata tokenAddresses
    ) external onlyOwner {
        uint256 length = tokenAddresses.length;
        uint256 balance;
        for (uint256 i = 0; i < length; ) {
            balance = LibAsset.getOwnBalance(tokenAddresses[i]);
            LibAsset.transferAsset(
                tokenAddresses[i],
                payable(msg.sender),
                balance
            );
            emit FeesWithdrawn(tokenAddresses[i], msg.sender, balance);
            unchecked {
                ++i;
            }
        }
    }
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import { IERC20, SafeERC20 } from "../../lib/openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol";
import { ReentrancyGuard } from "../Helpers/ReentrancyGuard.sol";
import { LibSwap } from "../Libraries/LibSwap.sol";
import { LibAsset } from "../Libraries/LibAsset.sol";
import { ILiFi } from "../Interfaces/ILiFi.sol";
import { IExecutor } from "../Interfaces/IExecutor.sol";
import { TransferrableOwnership } from "../Helpers/TransferrableOwnership.sol";
import { ExternalCallFailed, UnAuthorized } from "../Errors/GenericErrors.sol";

/// @title Receiver
/// @author LI.FI (https://li.fi)
/// @notice Arbitrary execution contract used for cross-chain swaps and message passing
/// @custom:version 2.0.2
contract Receiver is ILiFi, ReentrancyGuard, TransferrableOwnership {
    using SafeERC20 for IERC20;

    /// Storage ///
    address public sgRouter;
    IExecutor public executor;
    uint256 public recoverGas;
    address public amarokRouter;

    /// Events ///
    event StargateRouterSet(address indexed router);
    event AmarokRouterSet(address indexed router);
    event ExecutorSet(address indexed executor);
    event RecoverGasSet(uint256 indexed recoverGas);

    /// Modifiers ///
    modifier onlySGRouter() {
        if (msg.sender != sgRouter) {
            revert UnAuthorized();
        }
        _;
    }
    modifier onlyAmarokRouter() {
        if (msg.sender != amarokRouter) {
            revert UnAuthorized();
        }
        _;
    }

    /// Constructor
    constructor(
        address _owner,
        address _sgRouter,
        address _amarokRouter,
        address _executor,
        uint256 _recoverGas
    ) TransferrableOwnership(_owner) {
        owner = _owner;
        sgRouter = _sgRouter;
        amarokRouter = _amarokRouter;
        executor = IExecutor(_executor);
        recoverGas = _recoverGas;
        emit StargateRouterSet(_sgRouter);
        emit AmarokRouterSet(_amarokRouter);
        emit RecoverGasSet(_recoverGas);
    }

    /// External Methods ///

    /// @notice Completes a cross-chain transaction with calldata via Amarok facet on the receiving chain.
    /// @dev This function is called from Amarok Router.
    /// @param _transferId The unique ID of this transaction (assigned by Amarok)
    /// @param _amount the amount of bridged tokens
    /// @param _asset the address of the bridged token
    /// @param * (unused) the sender of the transaction
    /// @param * (unused) the domain ID of the src chain
    /// @param _callData The data to execute
    function xReceive(
        bytes32 _transferId,
        uint256 _amount,
        address _asset,
        address,
        uint32,
        bytes memory _callData
    ) external nonReentrant onlyAmarokRouter {
        (LibSwap.SwapData[] memory swapData, address receiver) = abi.decode(
            _callData,
            (LibSwap.SwapData[], address)
        );

        _swapAndCompleteBridgeTokens(
            _transferId,
            swapData,
            _asset,
            payable(receiver),
            _amount,
            false
        );
    }

    /// @notice Completes a cross-chain transaction on the receiving chain.
    /// @dev This function is called from Stargate Router.
    /// @param * (unused) The remote chainId sending the tokens
    /// @param * (unused) The remote Bridge address
    /// @param * (unused) Nonce
    /// @param _token The token contract on the local chain
    /// @param _amountLD The amount of tokens received through bridging
    /// @param _payload The data to execute
    function sgReceive(
        uint16, // _srcChainId unused
        bytes memory, // _srcAddress unused
        uint256, // _nonce unused
        address _token,
        uint256 _amountLD,
        bytes memory _payload
    ) external nonReentrant onlySGRouter {
        (
            bytes32 transactionId,
            LibSwap.SwapData[] memory swapData,
            ,
            address receiver
        ) = abi.decode(
                _payload,
                (bytes32, LibSwap.SwapData[], address, address)
            );

        _swapAndCompleteBridgeTokens(
            transactionId,
            swapData,
            swapData.length > 0 ? swapData[0].sendingAssetId : _token, // If swapping assume sent token is the first token in swapData
            payable(receiver),
            _amountLD,
            true
        );
    }

    /// @notice Performs a swap before completing a cross-chain transaction
    /// @param _transactionId the transaction id associated with the operation
    /// @param _swapData array of data needed for swaps
    /// @param assetId token received from the other chain
    /// @param receiver address that will receive tokens in the end
    function swapAndCompleteBridgeTokens(
        bytes32 _transactionId,
        LibSwap.SwapData[] memory _swapData,
        address assetId,
        address payable receiver
    ) external payable nonReentrant {
        if (LibAsset.isNativeAsset(assetId)) {
            _swapAndCompleteBridgeTokens(
                _transactionId,
                _swapData,
                assetId,
                receiver,
                msg.value,
                false
            );
        } else {
            uint256 allowance = IERC20(assetId).allowance(
                msg.sender,
                address(this)
            );
            LibAsset.depositAsset(assetId, allowance);
            _swapAndCompleteBridgeTokens(
                _transactionId,
                _swapData,
                assetId,
                receiver,
                allowance,
                false
            );
        }
    }

    /// @notice Send remaining token to receiver
    /// @param assetId token received from the other chain
    /// @param receiver address that will receive tokens in the end
    /// @param amount amount of token
    function pullToken(
        address assetId,
        address payable receiver,
        uint256 amount
    ) external onlyOwner {
        if (LibAsset.isNativeAsset(assetId)) {
            // solhint-disable-next-line avoid-low-level-calls
            (bool success, ) = receiver.call{ value: amount }("");
            if (!success) revert ExternalCallFailed();
        } else {
            IERC20(assetId).safeTransfer(receiver, amount);
        }
    }

    /// Private Methods ///

    /// @notice Performs a swap before completing a cross-chain transaction
    /// @param _transactionId the transaction id associated with the operation
    /// @param _swapData array of data needed for swaps
    /// @param assetId token received from the other chain
    /// @param receiver address that will receive tokens in the end
    /// @param amount amount of token
    /// @param reserveRecoverGas whether we need a gas buffer to recover
    function _swapAndCompleteBridgeTokens(
        bytes32 _transactionId,
        LibSwap.SwapData[] memory _swapData,
        address assetId,
        address payable receiver,
        uint256 amount,
        bool reserveRecoverGas
    ) private {
        uint256 _recoverGas = reserveRecoverGas ? recoverGas : 0;

        if (LibAsset.isNativeAsset(assetId)) {
            // case 1: native asset
            uint256 cacheGasLeft = gasleft();
            if (reserveRecoverGas && cacheGasLeft < _recoverGas) {
                // case 1a: not enough gas left to execute calls
                // solhint-disable-next-line avoid-low-level-calls
                (bool success, ) = receiver.call{ value: amount }("");
                if (!success) revert ExternalCallFailed();

                emit LiFiTransferRecovered(
                    _transactionId,
                    assetId,
                    receiver,
                    amount,
                    block.timestamp
                );
                return;
            }

            // case 1b: enough gas left to execute calls
            // solhint-disable no-empty-blocks
            try
                executor.swapAndCompleteBridgeTokens{
                    value: amount,
                    gas: cacheGasLeft - _recoverGas
                }(_transactionId, _swapData, assetId, receiver)
            {} catch {
                // solhint-disable-next-line avoid-low-level-calls
                (bool success, ) = receiver.call{ value: amount }("");
                if (!success) revert ExternalCallFailed();

                emit LiFiTransferRecovered(
                    _transactionId,
                    assetId,
                    receiver,
                    amount,
                    block.timestamp
                );
            }
        } else {
            // case 2: ERC20 asset
            uint256 cacheGasLeft = gasleft();
            IERC20 token = IERC20(assetId);
            token.safeApprove(address(executor), 0);

            if (reserveRecoverGas && cacheGasLeft < _recoverGas) {
                // case 2a: not enough gas left to execute calls
                token.safeTransfer(receiver, amount);

                emit LiFiTransferRecovered(
                    _transactionId,
                    assetId,
                    receiver,
                    amount,
                    block.timestamp
                );
                return;
            }

            // case 2b: enough gas left to execute calls
            token.safeIncreaseAllowance(address(executor), amount);
            try
                executor.swapAndCompleteBridgeTokens{
                    gas: cacheGasLeft - _recoverGas
                }(_transactionId, _swapData, assetId, receiver)
            {} catch {
                token.safeTransfer(receiver, amount);
                emit LiFiTransferRecovered(
                    _transactionId,
                    assetId,
                    receiver,
                    amount,
                    block.timestamp
                );
            }

            token.safeApprove(address(executor), 0);
        }
    }

    /// @notice Receive native asset directly.
    /// @dev Some bridges may send native asset before execute external calls.
    // solhint-disable-next-line no-empty-blocks
    receive() external payable {}
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import { IERC20, SafeERC20 } from "../../lib/openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol";
import { LibSwap } from "../Libraries/LibSwap.sol";
import { ContractCallNotAllowed, ExternalCallFailed, InvalidConfig, UnAuthorized, WithdrawFailed } from "../Errors/GenericErrors.sol";
import { LibAsset } from "../Libraries/LibAsset.sol";
import { LibUtil } from "../Libraries/LibUtil.sol";
import { ILiFi } from "../Interfaces/ILiFi.sol";
import { PeripheryRegistryFacet } from "../Facets/PeripheryRegistryFacet.sol";
import { IExecutor } from "../Interfaces/IExecutor.sol";
import { TransferrableOwnership } from "../Helpers/TransferrableOwnership.sol";
import { IMessageReceiverApp } from "../../lib/sgn-v2-contracts/contracts/message/interfaces/IMessageReceiverApp.sol";
import { CelerIM } from "../../src/Helpers/CelerIMFacetBase.sol";
import { MessageSenderLib, MsgDataTypes, IMessageBus, IOriginalTokenVault, IPeggedTokenBridge, IOriginalTokenVaultV2, IPeggedTokenBridgeV2 } from "../../lib/sgn-v2-contracts/contracts/message/libraries/MessageSenderLib.sol";
import { IBridge as ICBridge } from "../../lib/sgn-v2-contracts/contracts/interfaces/IBridge.sol";

/// @title RelayerCelerIM
/// @author LI.FI (https://li.fi)
/// @notice Relayer contract for CelerIM that forwards calls and handles refunds on src side and acts receiver on dest
/// @custom:version 2.0.0
contract RelayerCelerIM is ILiFi, TransferrableOwnership {
    using SafeERC20 for IERC20;

    /// Storage ///

    IMessageBus public cBridgeMessageBus;
    address public diamondAddress;

    /// Events ///

    event LogWithdraw(
        address indexed _assetAddress,
        address indexed _to,
        uint256 amount
    );

    /// Modifiers ///

    modifier onlyCBridgeMessageBus() {
        if (msg.sender != address(cBridgeMessageBus)) revert UnAuthorized();
        _;
    }
    modifier onlyDiamond() {
        if (msg.sender != diamondAddress) revert UnAuthorized();
        _;
    }

    /// Constructor

    constructor(
        address _cBridgeMessageBusAddress,
        address _owner,
        address _diamondAddress
    ) TransferrableOwnership(_owner) {
        owner = _owner;
        cBridgeMessageBus = IMessageBus(_cBridgeMessageBusAddress);
        diamondAddress = _diamondAddress;
    }

    /// External Methods ///

    /**
     * @notice Called by MessageBus to execute a message with an associated token transfer.
     * The Receiver is guaranteed to have received the right amount of tokens before this function is called.
     * @param * (unused) The address of the source app contract
     * @param _token The address of the token that comes out of the bridge
     * @param _amount The amount of tokens received at this contract through the cross-chain bridge.
     * @param * (unused)  The source chain ID where the transfer is originated from
     * @param _message Arbitrary message bytes originated from and encoded by the source app contract
     * @param * (unused)  Address who called the MessageBus execution function
     */
    function executeMessageWithTransfer(
        address,
        address _token,
        uint256 _amount,
        uint64,
        bytes calldata _message,
        address
    )
        external
        payable
        onlyCBridgeMessageBus
        returns (IMessageReceiverApp.ExecutionStatus)
    {
        // decode message
        (
            bytes32 transactionId,
            LibSwap.SwapData[] memory swapData,
            address receiver,
            address refundAddress
        ) = abi.decode(
                _message,
                (bytes32, LibSwap.SwapData[], address, address)
            );

        _swapAndCompleteBridgeTokens(
            transactionId,
            swapData,
            _token,
            payable(receiver),
            _amount,
            refundAddress
        );

        return IMessageReceiverApp.ExecutionStatus.Success;
    }

    /**
     * @notice Called by MessageBus to process refund of the original transfer from this contract.
     * The contract is guaranteed to have received the refund before this function is called.
     * @param _token The token address of the original transfer
     * @param _amount The amount of the original transfer
     * @param _message The same message associated with the original transfer
     * @param * (unused) Address who called the MessageBus execution function
     */
    function executeMessageWithTransferRefund(
        address _token,
        uint256 _amount,
        bytes calldata _message,
        address
    )
        external
        payable
        onlyCBridgeMessageBus
        returns (IMessageReceiverApp.ExecutionStatus)
    {
        (bytes32 transactionId, , , address refundAddress) = abi.decode(
            _message,
            (bytes32, LibSwap.SwapData[], address, address)
        );

        // return funds to cBridgeData.refundAddress
        LibAsset.transferAsset(_token, payable(refundAddress), _amount);

        emit LiFiTransferRecovered(
            transactionId,
            _token,
            refundAddress,
            _amount,
            block.timestamp
        );

        return IMessageReceiverApp.ExecutionStatus.Success;
    }

    /**
     * @notice Forwards a call to transfer tokens to cBridge (sent via this contract to ensure that potential refunds are sent here)
     * @param _bridgeData the core information needed for bridging
     * @param _celerIMData data specific to CelerIM
     */
    // solhint-disable-next-line code-complexity
    function sendTokenTransfer(
        ILiFi.BridgeData memory _bridgeData,
        CelerIM.CelerIMData calldata _celerIMData
    )
        external
        payable
        onlyDiamond
        returns (bytes32 transferId, address bridgeAddress)
    {
        // approve to and call correct bridge depending on BridgeSendType
        // @dev copied and slightly adapted from Celer MessageSenderLib
        if (_celerIMData.bridgeType == MsgDataTypes.BridgeSendType.Liquidity) {
            bridgeAddress = cBridgeMessageBus.liquidityBridge();
            if (LibAsset.isNativeAsset(_bridgeData.sendingAssetId)) {
                // case: native asset bridging
                ICBridge(bridgeAddress).sendNative{
                    value: _bridgeData.minAmount
                }(
                    _bridgeData.receiver,
                    _bridgeData.minAmount,
                    uint64(_bridgeData.destinationChainId),
                    _celerIMData.nonce,
                    _celerIMData.maxSlippage
                );
            } else {
                // case: ERC20 asset bridging
                LibAsset.maxApproveERC20(
                    IERC20(_bridgeData.sendingAssetId),
                    bridgeAddress,
                    _bridgeData.minAmount
                );
                // solhint-disable-next-line check-send-result
                ICBridge(bridgeAddress).send(
                    _bridgeData.receiver,
                    _bridgeData.sendingAssetId,
                    _bridgeData.minAmount,
                    uint64(_bridgeData.destinationChainId),
                    _celerIMData.nonce,
                    _celerIMData.maxSlippage
                );
            }
            transferId = MessageSenderLib.computeLiqBridgeTransferId(
                _bridgeData.receiver,
                _bridgeData.sendingAssetId,
                _bridgeData.minAmount,
                uint64(_bridgeData.destinationChainId),
                _celerIMData.nonce
            );
        } else if (
            _celerIMData.bridgeType == MsgDataTypes.BridgeSendType.PegDeposit
        ) {
            bridgeAddress = cBridgeMessageBus.pegVault();
            LibAsset.maxApproveERC20(
                IERC20(_bridgeData.sendingAssetId),
                bridgeAddress,
                _bridgeData.minAmount
            );
            IOriginalTokenVault(bridgeAddress).deposit(
                _bridgeData.sendingAssetId,
                _bridgeData.minAmount,
                uint64(_bridgeData.destinationChainId),
                _bridgeData.receiver,
                _celerIMData.nonce
            );
            transferId = MessageSenderLib.computePegV1DepositId(
                _bridgeData.receiver,
                _bridgeData.sendingAssetId,
                _bridgeData.minAmount,
                uint64(_bridgeData.destinationChainId),
                _celerIMData.nonce
            );
        } else if (
            _celerIMData.bridgeType == MsgDataTypes.BridgeSendType.PegBurn
        ) {
            bridgeAddress = cBridgeMessageBus.pegBridge();
            LibAsset.maxApproveERC20(
                IERC20(_bridgeData.sendingAssetId),
                bridgeAddress,
                _bridgeData.minAmount
            );
            IPeggedTokenBridge(bridgeAddress).burn(
                _bridgeData.sendingAssetId,
                _bridgeData.minAmount,
                _bridgeData.receiver,
                _celerIMData.nonce
            );
            transferId = MessageSenderLib.computePegV1BurnId(
                _bridgeData.receiver,
                _bridgeData.sendingAssetId,
                _bridgeData.minAmount,
                _celerIMData.nonce
            );
        } else if (
            _celerIMData.bridgeType == MsgDataTypes.BridgeSendType.PegV2Deposit
        ) {
            bridgeAddress = cBridgeMessageBus.pegVaultV2();
            if (LibAsset.isNativeAsset(_bridgeData.sendingAssetId)) {
                // case: native asset bridging
                transferId = IOriginalTokenVaultV2(bridgeAddress)
                    .depositNative{ value: _bridgeData.minAmount }(
                    _bridgeData.minAmount,
                    uint64(_bridgeData.destinationChainId),
                    _bridgeData.receiver,
                    _celerIMData.nonce
                );
            } else {
                // case: ERC20 bridging
                LibAsset.maxApproveERC20(
                    IERC20(_bridgeData.sendingAssetId),
                    bridgeAddress,
                    _bridgeData.minAmount
                );
                transferId = IOriginalTokenVaultV2(bridgeAddress).deposit(
                    _bridgeData.sendingAssetId,
                    _bridgeData.minAmount,
                    uint64(_bridgeData.destinationChainId),
                    _bridgeData.receiver,
                    _celerIMData.nonce
                );
            }
        } else if (
            _celerIMData.bridgeType == MsgDataTypes.BridgeSendType.PegV2Burn
        ) {
            bridgeAddress = cBridgeMessageBus.pegBridgeV2();
            LibAsset.maxApproveERC20(
                IERC20(_bridgeData.sendingAssetId),
                bridgeAddress,
                _bridgeData.minAmount
            );
            transferId = IPeggedTokenBridgeV2(bridgeAddress).burn(
                _bridgeData.sendingAssetId,
                _bridgeData.minAmount,
                uint64(_bridgeData.destinationChainId),
                _bridgeData.receiver,
                _celerIMData.nonce
            );
        } else if (
            _celerIMData.bridgeType ==
            MsgDataTypes.BridgeSendType.PegV2BurnFrom
        ) {
            bridgeAddress = cBridgeMessageBus.pegBridgeV2();
            LibAsset.maxApproveERC20(
                IERC20(_bridgeData.sendingAssetId),
                bridgeAddress,
                _bridgeData.minAmount
            );
            transferId = IPeggedTokenBridgeV2(bridgeAddress).burnFrom(
                _bridgeData.sendingAssetId,
                _bridgeData.minAmount,
                uint64(_bridgeData.destinationChainId),
                _bridgeData.receiver,
                _celerIMData.nonce
            );
        } else {
            revert InvalidConfig();
        }
    }

    /**
     * @notice Forwards a call to the CBridge Messagebus
     * @param _receiver The address of the destination app contract.
     * @param _dstChainId The destination chain ID.
     * @param _srcBridge The bridge contract to send the transfer with.
     * @param _srcTransferId The transfer ID.
     * @param _dstChainId The destination chain ID.
     * @param _message Arbitrary message bytes to be decoded by the destination app contract.
     */
    function forwardSendMessageWithTransfer(
        address _receiver,
        uint256 _dstChainId,
        address _srcBridge,
        bytes32 _srcTransferId,
        bytes calldata _message
    ) external payable onlyDiamond {
        cBridgeMessageBus.sendMessageWithTransfer{ value: msg.value }(
            _receiver,
            _dstChainId,
            _srcBridge,
            _srcTransferId,
            _message
        );
    }

    // ------------------------------------------------------------------------------------------------

    /// Private Methods ///

    /// @notice Performs a swap before completing a cross-chain transaction
    /// @param _transactionId the transaction id associated with the operation
    /// @param _swapData array of data needed for swaps
    /// @param assetId token received from the other chain
    /// @param receiver address that will receive tokens in the end
    /// @param amount amount of token
    function _swapAndCompleteBridgeTokens(
        bytes32 _transactionId,
        LibSwap.SwapData[] memory _swapData,
        address assetId,
        address payable receiver,
        uint256 amount,
        address refundAddress
    ) private {
        bool success;
        IExecutor executor = IExecutor(
            PeripheryRegistryFacet(diamondAddress).getPeripheryContract(
                "Executor"
            )
        );
        if (LibAsset.isNativeAsset(assetId)) {
            try
                executor.swapAndCompleteBridgeTokens{ value: amount }(
                    _transactionId,
                    _swapData,
                    assetId,
                    receiver
                )
            {
                success = true;
            } catch {
                // solhint-disable-next-line avoid-low-level-calls
                (bool fundsSent, ) = refundAddress.call{ value: amount }("");
                if (!fundsSent) {
                    revert ExternalCallFailed();
                }
            }
        } else {
            IERC20 token = IERC20(assetId);
            token.safeApprove(address(executor), 0);
            token.safeIncreaseAllowance(address(executor), amount);

            try
                executor.swapAndCompleteBridgeTokens(
                    _transactionId,
                    _swapData,
                    assetId,
                    receiver
                )
            {
                success = true;
            } catch {
                token.safeTransfer(refundAddress, amount);
            }
            token.safeApprove(address(executor), 0);
        }

        if (!success) {
            emit LiFiTransferRecovered(
                _transactionId,
                assetId,
                refundAddress,
                amount,
                block.timestamp
            );
        }
    }

    /// @notice Sends remaining token to given receiver address (for refund cases)
    /// @param assetId Address of the token to be withdrawn
    /// @param receiver Address that will receive tokens
    /// @param amount Amount of tokens to be withdrawn
    function withdraw(
        address assetId,
        address payable receiver,
        uint256 amount
    ) external onlyOwner {
        if (LibAsset.isNativeAsset(assetId)) {
            // solhint-disable-next-line avoid-low-level-calls
            (bool success, ) = receiver.call{ value: amount }("");
            if (!success) {
                revert WithdrawFailed();
            }
        } else {
            IERC20(assetId).safeTransfer(receiver, amount);
        }
        emit LogWithdraw(assetId, receiver, amount);
    }

    /// @notice Triggers a cBridge refund with calldata produced by cBridge API
    /// @param _callTo The address to execute the calldata on
    /// @param _callData The data to execute
    /// @param _assetAddress Asset to be withdrawn
    /// @param _to Address to withdraw to
    /// @param _amount Amount of asset to withdraw
    function triggerRefund(
        address payable _callTo,
        bytes calldata _callData,
        address _assetAddress,
        address _to,
        uint256 _amount
    ) external onlyOwner {
        bool success;

        // make sure that callTo address is either of the cBridge addresses
        if (
            cBridgeMessageBus.liquidityBridge() != _callTo &&
            cBridgeMessageBus.pegBridge() != _callTo &&
            cBridgeMessageBus.pegBridgeV2() != _callTo &&
            cBridgeMessageBus.pegVault() != _callTo &&
            cBridgeMessageBus.pegVaultV2() != _callTo
        ) {
            revert ContractCallNotAllowed();
        }

        // call contract
        // solhint-disable-next-line avoid-low-level-calls
        (success, ) = _callTo.call(_callData);

        // forward funds to _to address and emit event, if cBridge refund successful
        if (success) {
            address sendTo = (LibUtil.isZeroAddress(_to)) ? msg.sender : _to;
            LibAsset.transferAsset(_assetAddress, payable(sendTo), _amount);
            emit LogWithdraw(_assetAddress, sendTo, _amount);
        } else {
            revert WithdrawFailed();
        }
    }

    // required in order to receive native tokens from cBridge facet
    // solhint-disable-next-line no-empty-blocks
    receive() external payable {}
}
// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import { LibAsset } from "../Libraries/LibAsset.sol";
import { TransferrableOwnership } from "../Helpers/TransferrableOwnership.sol";

/// @title Service Fee Collector
/// @author LI.FI (https://li.fi)
/// @notice Provides functionality for collecting service fees (gas/insurance)
/// @custom:version 1.0.0
contract ServiceFeeCollector is TransferrableOwnership {
    /// Errors ///
    error TransferFailure();
    error NotEnoughNativeForFees();

    /// Events ///
    event GasFeesCollected(
        address indexed token,
        uint256 indexed chainId,
        address indexed receiver,
        uint256 feeAmount
    );

    event InsuranceFeesCollected(
        address indexed token,
        address indexed receiver,
        uint256 feeAmount
    );

    event FeesWithdrawn(
        address indexed token,
        address indexed to,
        uint256 amount
    );

    /// Constructor ///

    // solhint-disable-next-line no-empty-blocks
    constructor(address _owner) TransferrableOwnership(_owner) {}

    /// External Methods ///

    /// @notice Collects gas fees
    /// @param tokenAddress The address of the token to collect
    /// @param feeAmount The amount of fees to collect
    /// @param chainId The chain id of the destination chain
    /// @param receiver The address to send gas to on the destination chain
    function collectTokenGasFees(
        address tokenAddress,
        uint256 feeAmount,
        uint256 chainId,
        address receiver
    ) external {
        LibAsset.depositAsset(tokenAddress, feeAmount);
        emit GasFeesCollected(tokenAddress, chainId, receiver, feeAmount);
    }

    /// @notice Collects gas fees in native token
    /// @param chainId The chain id of the destination chain
    /// @param receiver The address to send gas to on destination chain
    function collectNativeGasFees(
        uint256 chainId,
        address receiver
    ) external payable {
        emit GasFeesCollected(
            LibAsset.NULL_ADDRESS,
            chainId,
            receiver,
            msg.value
        );
    }

    /// @notice Collects insurance fees
    /// @param tokenAddress The address of the token to collect
    /// @param feeAmount The amount of fees to collect
    /// @param receiver The address to insure
    function collectTokenInsuranceFees(
        address tokenAddress,
        uint256 feeAmount,
        address receiver
    ) external {
        LibAsset.depositAsset(tokenAddress, feeAmount);
        emit InsuranceFeesCollected(tokenAddress, receiver, feeAmount);
    }

    /// @notice Collects insurance fees in native token
    /// @param receiver The address to insure
    function collectNativeInsuranceFees(address receiver) external payable {
        emit InsuranceFeesCollected(
            LibAsset.NULL_ADDRESS,
            receiver,
            msg.value
        );
    }

    /// @notice Withdraws fees
    /// @param tokenAddress The address of the token to withdraw fees for
    function withdrawFees(address tokenAddress) external onlyOwner {
        uint256 balance = LibAsset.getOwnBalance(tokenAddress);
        LibAsset.transferAsset(tokenAddress, payable(msg.sender), balance);
        emit FeesWithdrawn(tokenAddress, msg.sender, balance);
    }

    /// @notice Batch withdraws fees
    /// @param tokenAddresses The addresses of the tokens to withdraw fees for
    function batchWithdrawFees(
        address[] calldata tokenAddresses
    ) external onlyOwner {
        uint256 length = tokenAddresses.length;
        uint256 balance;
        for (uint256 i = 0; i < length; ) {
            balance = LibAsset.getOwnBalance(tokenAddresses[i]);
            LibAsset.transferAsset(
                tokenAddresses[i],
                payable(msg.sender),
                balance
            );
            emit FeesWithdrawn(tokenAddresses[i], msg.sender, balance);
            unchecked {
                ++i;
            }
        }
    }
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import { LibDiamond } from "./Libraries/LibDiamond.sol";
import { IDiamondCut } from "./Interfaces/IDiamondCut.sol";
import { LibUtil } from "./Libraries/LibUtil.sol";

/// @title Ponder Diamond Immutable
/// @author Ponder.one (https://ponder.one)
/// @notice (Immutable) Base EIP-2535 Diamond Proxy Contract.
/// @custom:version 1.0.0
contract PonderDiamond {
    constructor(address _contractOwner, address _diamondCutFacet) payable {
        LibDiamond.setContractOwner(_contractOwner);

        // Add the diamondCut external function from the diamondCutFacet
        IDiamondCut.FacetCut[] memory cut = new IDiamondCut.FacetCut[](1);
        bytes4[] memory functionSelectors = new bytes4[](1);
        functionSelectors[0] = IDiamondCut.diamondCut.selector;
        cut[0] = IDiamondCut.FacetCut({
            facetAddress: _diamondCutFacet,
            action: IDiamondCut.FacetCutAction.Add,
            functionSelectors: functionSelectors
        });
        LibDiamond.diamondCut(cut, address(0), "");
    }

    // Find facet for function that is called and execute the
    // function if a facet is found and return any value.
    // solhint-disable-next-line no-complex-fallback
    fallback() external payable {
        LibDiamond.DiamondStorage storage ds;
        bytes32 position = LibDiamond.DIAMOND_STORAGE_POSITION;

        // get diamond storage
        // solhint-disable-next-line no-inline-assembly
        assembly {
            ds.slot := position
        }

        // get facet from function selector
        address facet = ds.selectorToFacetAndPosition[msg.sig].facetAddress;

        if (facet == address(0)) {
            revert LibDiamond.FunctionDoesNotExist();
        }

        // Execute external function from facet using delegatecall and return any value.
        // solhint-disable-next-line no-inline-assembly
        assembly {
            // copy function selector and any arguments
            calldatacopy(0, 0, calldatasize())
            // execute function call using the facet
            let result := delegatecall(gas(), facet, 0, calldatasize(), 0, 0)
            // get any return value
            returndatacopy(0, 0, returndatasize())
            // return any return value or error back to the caller
            switch result
            case 0 {
                revert(0, returndatasize())
            }
            default {
                return(0, returndatasize())
            }
        }
    }

    // Able to receive ether
    // solhint-disable-next-line no-empty-blocks
    receive() external payable {}
}
