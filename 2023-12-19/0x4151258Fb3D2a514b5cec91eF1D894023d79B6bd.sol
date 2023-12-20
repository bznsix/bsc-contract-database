// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (access/Ownable.sol)

pragma solidity ^0.8.20;

import {Context} from "../utils/Context.sol";

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * The initial owner is set to the address provided by the deployer. This can
 * later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    /**
     * @dev The caller account is not authorized to perform an operation.
     */
    error OwnableUnauthorizedAccount(address account);

    /**
     * @dev The owner is not a valid owner account. (eg. `address(0)`)
     */
    error OwnableInvalidOwner(address owner);

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the address provided by the deployer as the initial owner.
     */
    constructor(address initialOwner) {
        if (initialOwner == address(0)) {
            revert OwnableInvalidOwner(address(0));
        }
        _transferOwnership(initialOwner);
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
        if (owner() != _msgSender()) {
            revert OwnableUnauthorizedAccount(_msgSender());
        }
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
        if (newOwner == address(0)) {
            revert OwnableInvalidOwner(address(0));
        }
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
// OpenZeppelin Contracts (last updated v5.0.0) (access/Ownable2Step.sol)

pragma solidity ^0.8.20;

import {Ownable} from "./Ownable.sol";

/**
 * @dev Contract module which provides access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * The initial owner is specified at deployment time in the constructor for `Ownable`. This
 * can later be changed with {transferOwnership} and {acceptOwnership}.
 *
 * This module is used through inheritance. It will make available all functions
 * from parent (Ownable).
 */
abstract contract Ownable2Step is Ownable {
    address private _pendingOwner;

    event OwnershipTransferStarted(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Returns the address of the pending owner.
     */
    function pendingOwner() public view virtual returns (address) {
        return _pendingOwner;
    }

    /**
     * @dev Starts the ownership transfer of the contract to a new account. Replaces the pending transfer if there is one.
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual override onlyOwner {
        _pendingOwner = newOwner;
        emit OwnershipTransferStarted(owner(), newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`) and deletes any pending owner.
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual override {
        delete _pendingOwner;
        super._transferOwnership(newOwner);
    }

    /**
     * @dev The new owner accepts the ownership transfer.
     */
    function acceptOwnership() public virtual {
        address sender = _msgSender();
        if (pendingOwner() != sender) {
            revert OwnableUnauthorizedAccount(sender);
        }
        _transferOwnership(sender);
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.20;

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
     * @dev Returns the value of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the value of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves a `value` amount of tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 value) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets a `value` amount of tokens as the allowance of `spender` over the
     * caller's tokens.
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
    function approve(address spender, uint256 value) external returns (bool);

    /**
     * @dev Moves a `value` amount of tokens from `from` to `to` using the
     * allowance mechanism. `value` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address from, address to, uint256 value) external returns (bool);
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC20/extensions/IERC20Permit.sol)

pragma solidity ^0.8.20;

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
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.20;

import {IERC20} from "../IERC20.sol";
import {IERC20Permit} from "../extensions/IERC20Permit.sol";
import {Address} from "../../../utils/Address.sol";

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
     * @dev An operation with an ERC20 token failed.
     */
    error SafeERC20FailedOperation(address token);

    /**
     * @dev Indicates a failed `decreaseAllowance` request.
     */
    error SafeERC20FailedDecreaseAllowance(address spender, uint256 currentAllowance, uint256 requestedDecrease);

    /**
     * @dev Transfer `value` amount of `token` from the calling contract to `to`. If `token` returns no value,
     * non-reverting calls are assumed to be successful.
     */
    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeCall(token.transfer, (to, value)));
    }

    /**
     * @dev Transfer `value` amount of `token` from `from` to `to`, spending the approval given by `from` to the
     * calling contract. If `token` returns no value, non-reverting calls are assumed to be successful.
     */
    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeCall(token.transferFrom, (from, to, value)));
    }

    /**
     * @dev Increase the calling contract's allowance toward `spender` by `value`. If `token` returns no value,
     * non-reverting calls are assumed to be successful.
     */
    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 oldAllowance = token.allowance(address(this), spender);
        forceApprove(token, spender, oldAllowance + value);
    }

    /**
     * @dev Decrease the calling contract's allowance toward `spender` by `requestedDecrease`. If `token` returns no
     * value, non-reverting calls are assumed to be successful.
     */
    function safeDecreaseAllowance(IERC20 token, address spender, uint256 requestedDecrease) internal {
        unchecked {
            uint256 currentAllowance = token.allowance(address(this), spender);
            if (currentAllowance < requestedDecrease) {
                revert SafeERC20FailedDecreaseAllowance(spender, currentAllowance, requestedDecrease);
            }
            forceApprove(token, spender, currentAllowance - requestedDecrease);
        }
    }

    /**
     * @dev Set the calling contract's allowance toward `spender` to `value`. If `token` returns no value,
     * non-reverting calls are assumed to be successful. Meant to be used with tokens that require the approval
     * to be set to zero before setting it to a non-zero value, such as USDT.
     */
    function forceApprove(IERC20 token, address spender, uint256 value) internal {
        bytes memory approvalCall = abi.encodeCall(token.approve, (spender, value));

        if (!_callOptionalReturnBool(token, approvalCall)) {
            _callOptionalReturn(token, abi.encodeCall(token.approve, (spender, 0)));
            _callOptionalReturn(token, approvalCall);
        }
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

        bytes memory returndata = address(token).functionCall(data);
        if (returndata.length != 0 && !abi.decode(returndata, (bool))) {
            revert SafeERC20FailedOperation(address(token));
        }
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
        return success && (returndata.length == 0 || abi.decode(returndata, (bool))) && address(token).code.length > 0;
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (utils/Address.sol)

pragma solidity ^0.8.20;

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev The ETH balance of the account is not enough to perform the operation.
     */
    error AddressInsufficientBalance(address account);

    /**
     * @dev There's no code at `target` (it is not a contract).
     */
    error AddressEmptyCode(address target);

    /**
     * @dev A call to an address target failed. The target may have reverted.
     */
    error FailedInnerCall();

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
     * https://solidity.readthedocs.io/en/v0.8.20/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        if (address(this).balance < amount) {
            revert AddressInsufficientBalance(address(this));
        }

        (bool success, ) = recipient.call{value: amount}("");
        if (!success) {
            revert FailedInnerCall();
        }
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason or custom error, it is bubbled
     * up by this function (like regular Solidity function calls). However, if
     * the call reverted with no returned reason, this function reverts with a
     * {FailedInnerCall} error.
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     */
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        if (address(this).balance < value) {
            revert AddressInsufficientBalance(address(this));
        }
        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResultFromTarget(target, success, returndata);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResultFromTarget(target, success, returndata);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResultFromTarget(target, success, returndata);
    }

    /**
     * @dev Tool to verify that a low level call to smart-contract was successful, and reverts if the target
     * was not a contract or bubbling up the revert reason (falling back to {FailedInnerCall}) in case of an
     * unsuccessful call.
     */
    function verifyCallResultFromTarget(
        address target,
        bool success,
        bytes memory returndata
    ) internal view returns (bytes memory) {
        if (!success) {
            _revert(returndata);
        } else {
            // only check if target is a contract if the call was successful and the return data is empty
            // otherwise we already know that it was a contract
            if (returndata.length == 0 && target.code.length == 0) {
                revert AddressEmptyCode(target);
            }
            return returndata;
        }
    }

    /**
     * @dev Tool to verify that a low level call was successful, and reverts if it wasn't, either by bubbling the
     * revert reason or with a default {FailedInnerCall} error.
     */
    function verifyCallResult(bool success, bytes memory returndata) internal pure returns (bytes memory) {
        if (!success) {
            _revert(returndata);
        } else {
            return returndata;
        }
    }

    /**
     * @dev Reverts with returndata if present. Otherwise reverts with {FailedInnerCall}.
     */
    function _revert(bytes memory returndata) private pure {
        // Look for revert reason and bubble it up if present
        if (returndata.length > 0) {
            // The easiest way to bubble the revert reason is using memory via assembly
            /// @solidity memory-safe-assembly
            assembly {
                let returndata_size := mload(returndata)
                revert(add(32, returndata), returndata_size)
            }
        } else {
            revert FailedInnerCall();
        }
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (utils/Context.sol)

pragma solidity ^0.8.20;

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
// OpenZeppelin Contracts (last updated v5.0.0) (utils/cryptography/MerkleProof.sol)

pragma solidity ^0.8.20;

/**
 * @dev These functions deal with verification of Merkle Tree proofs.
 *
 * The tree and the proofs can be generated using our
 * https://github.com/OpenZeppelin/merkle-tree[JavaScript library].
 * You will find a quickstart guide in the readme.
 *
 * WARNING: You should avoid using leaf values that are 64 bytes long prior to
 * hashing, or use a hash function other than keccak256 for hashing leaves.
 * This is because the concatenation of a sorted pair of internal nodes in
 * the Merkle tree could be reinterpreted as a leaf value.
 * OpenZeppelin's JavaScript library generates Merkle trees that are safe
 * against this attack out of the box.
 */
library MerkleProof {
    /**
     *@dev The multiproof provided is not valid.
     */
    error MerkleProofInvalidMultiproof();

    /**
     * @dev Returns true if a `leaf` can be proved to be a part of a Merkle tree
     * defined by `root`. For this, a `proof` must be provided, containing
     * sibling hashes on the branch from the leaf to the root of the tree. Each
     * pair of leaves and each pair of pre-images are assumed to be sorted.
     */
    function verify(bytes32[] memory proof, bytes32 root, bytes32 leaf) internal pure returns (bool) {
        return processProof(proof, leaf) == root;
    }

    /**
     * @dev Calldata version of {verify}
     */
    function verifyCalldata(bytes32[] calldata proof, bytes32 root, bytes32 leaf) internal pure returns (bool) {
        return processProofCalldata(proof, leaf) == root;
    }

    /**
     * @dev Returns the rebuilt hash obtained by traversing a Merkle tree up
     * from `leaf` using `proof`. A `proof` is valid if and only if the rebuilt
     * hash matches the root of the tree. When processing the proof, the pairs
     * of leafs & pre-images are assumed to be sorted.
     */
    function processProof(bytes32[] memory proof, bytes32 leaf) internal pure returns (bytes32) {
        bytes32 computedHash = leaf;
        for (uint256 i = 0; i < proof.length; i++) {
            computedHash = _hashPair(computedHash, proof[i]);
        }
        return computedHash;
    }

    /**
     * @dev Calldata version of {processProof}
     */
    function processProofCalldata(bytes32[] calldata proof, bytes32 leaf) internal pure returns (bytes32) {
        bytes32 computedHash = leaf;
        for (uint256 i = 0; i < proof.length; i++) {
            computedHash = _hashPair(computedHash, proof[i]);
        }
        return computedHash;
    }

    /**
     * @dev Returns true if the `leaves` can be simultaneously proven to be a part of a Merkle tree defined by
     * `root`, according to `proof` and `proofFlags` as described in {processMultiProof}.
     *
     * CAUTION: Not all Merkle trees admit multiproofs. See {processMultiProof} for details.
     */
    function multiProofVerify(
        bytes32[] memory proof,
        bool[] memory proofFlags,
        bytes32 root,
        bytes32[] memory leaves
    ) internal pure returns (bool) {
        return processMultiProof(proof, proofFlags, leaves) == root;
    }

    /**
     * @dev Calldata version of {multiProofVerify}
     *
     * CAUTION: Not all Merkle trees admit multiproofs. See {processMultiProof} for details.
     */
    function multiProofVerifyCalldata(
        bytes32[] calldata proof,
        bool[] calldata proofFlags,
        bytes32 root,
        bytes32[] memory leaves
    ) internal pure returns (bool) {
        return processMultiProofCalldata(proof, proofFlags, leaves) == root;
    }

    /**
     * @dev Returns the root of a tree reconstructed from `leaves` and sibling nodes in `proof`. The reconstruction
     * proceeds by incrementally reconstructing all inner nodes by combining a leaf/inner node with either another
     * leaf/inner node or a proof sibling node, depending on whether each `proofFlags` item is true or false
     * respectively.
     *
     * CAUTION: Not all Merkle trees admit multiproofs. To use multiproofs, it is sufficient to ensure that: 1) the tree
     * is complete (but not necessarily perfect), 2) the leaves to be proven are in the opposite order they are in the
     * tree (i.e., as seen from right to left starting at the deepest layer and continuing at the next layer).
     */
    function processMultiProof(
        bytes32[] memory proof,
        bool[] memory proofFlags,
        bytes32[] memory leaves
    ) internal pure returns (bytes32 merkleRoot) {
        // This function rebuilds the root hash by traversing the tree up from the leaves. The root is rebuilt by
        // consuming and producing values on a queue. The queue starts with the `leaves` array, then goes onto the
        // `hashes` array. At the end of the process, the last hash in the `hashes` array should contain the root of
        // the Merkle tree.
        uint256 leavesLen = leaves.length;
        uint256 proofLen = proof.length;
        uint256 totalHashes = proofFlags.length;

        // Check proof validity.
        if (leavesLen + proofLen != totalHashes + 1) {
            revert MerkleProofInvalidMultiproof();
        }

        // The xxxPos values are "pointers" to the next value to consume in each array. All accesses are done using
        // `xxx[xxxPos++]`, which return the current value and increment the pointer, thus mimicking a queue's "pop".
        bytes32[] memory hashes = new bytes32[](totalHashes);
        uint256 leafPos = 0;
        uint256 hashPos = 0;
        uint256 proofPos = 0;
        // At each step, we compute the next hash using two values:
        // - a value from the "main queue". If not all leaves have been consumed, we get the next leaf, otherwise we
        //   get the next hash.
        // - depending on the flag, either another value from the "main queue" (merging branches) or an element from the
        //   `proof` array.
        for (uint256 i = 0; i < totalHashes; i++) {
            bytes32 a = leafPos < leavesLen ? leaves[leafPos++] : hashes[hashPos++];
            bytes32 b = proofFlags[i]
                ? (leafPos < leavesLen ? leaves[leafPos++] : hashes[hashPos++])
                : proof[proofPos++];
            hashes[i] = _hashPair(a, b);
        }

        if (totalHashes > 0) {
            if (proofPos != proofLen) {
                revert MerkleProofInvalidMultiproof();
            }
            unchecked {
                return hashes[totalHashes - 1];
            }
        } else if (leavesLen > 0) {
            return leaves[0];
        } else {
            return proof[0];
        }
    }

    /**
     * @dev Calldata version of {processMultiProof}.
     *
     * CAUTION: Not all Merkle trees admit multiproofs. See {processMultiProof} for details.
     */
    function processMultiProofCalldata(
        bytes32[] calldata proof,
        bool[] calldata proofFlags,
        bytes32[] memory leaves
    ) internal pure returns (bytes32 merkleRoot) {
        // This function rebuilds the root hash by traversing the tree up from the leaves. The root is rebuilt by
        // consuming and producing values on a queue. The queue starts with the `leaves` array, then goes onto the
        // `hashes` array. At the end of the process, the last hash in the `hashes` array should contain the root of
        // the Merkle tree.
        uint256 leavesLen = leaves.length;
        uint256 proofLen = proof.length;
        uint256 totalHashes = proofFlags.length;

        // Check proof validity.
        if (leavesLen + proofLen != totalHashes + 1) {
            revert MerkleProofInvalidMultiproof();
        }

        // The xxxPos values are "pointers" to the next value to consume in each array. All accesses are done using
        // `xxx[xxxPos++]`, which return the current value and increment the pointer, thus mimicking a queue's "pop".
        bytes32[] memory hashes = new bytes32[](totalHashes);
        uint256 leafPos = 0;
        uint256 hashPos = 0;
        uint256 proofPos = 0;
        // At each step, we compute the next hash using two values:
        // - a value from the "main queue". If not all leaves have been consumed, we get the next leaf, otherwise we
        //   get the next hash.
        // - depending on the flag, either another value from the "main queue" (merging branches) or an element from the
        //   `proof` array.
        for (uint256 i = 0; i < totalHashes; i++) {
            bytes32 a = leafPos < leavesLen ? leaves[leafPos++] : hashes[hashPos++];
            bytes32 b = proofFlags[i]
                ? (leafPos < leavesLen ? leaves[leafPos++] : hashes[hashPos++])
                : proof[proofPos++];
            hashes[i] = _hashPair(a, b);
        }

        if (totalHashes > 0) {
            if (proofPos != proofLen) {
                revert MerkleProofInvalidMultiproof();
            }
            unchecked {
                return hashes[totalHashes - 1];
            }
        } else if (leavesLen > 0) {
            return leaves[0];
        } else {
            return proof[0];
        }
    }

    /**
     * @dev Sorts the pair (a, b) and hashes the result.
     */
    function _hashPair(bytes32 a, bytes32 b) private pure returns (bytes32) {
        return a < b ? _efficientHash(a, b) : _efficientHash(b, a);
    }

    /**
     * @dev Implementation of keccak256(abi.encode(a, b)) that doesn't allocate or expand memory.
     */
    function _efficientHash(bytes32 a, bytes32 b) private pure returns (bytes32 value) {
        /// @solidity memory-safe-assembly
        assembly {
            mstore(0x00, a)
            mstore(0x20, b)
            value := keccak256(0x00, 0x40)
        }
    }
}
// SPDX-License-Identifier: MIT

pragma solidity 0.8.23;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { SafeERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import { Ownable, Ownable2Step } from "@openzeppelin/contracts/access/Ownable2Step.sol";

import { TokenVesting } from "./abstract/TokenVesting.sol";
import { MerkleDistributor } from "./abstract/MerkleDistributor.sol";

/**
 * @title MerkleTokenVesting
 * @notice Vesting contract that allows configuring periodic vesting with start tokens and cliff time.
 * @dev Vestings are initialized by the users from Merkle proofs. Users can initialize their vestings at any time.
 * Periods are based on the 30 days time frame as a equivalent of a month. The contract owner can add vesting
 * schedules and Merkle roots and deposit vested tokens.
 *
 * This contract is a combination of two existing contracts: TokenVesting and MerkleDistributor.
 * TokenVesting is a contract for vesting tokens over time with a start date, cliff period, and duration.
 * MerkleDistributor is a contract for validation of token distribution according to a Merkle tree.
 *
 * The contract uses the OpenZeppelin libraries for ERC20 tokens and access control.
 */
contract MerkleTokenVesting is TokenVesting, MerkleDistributor, Ownable2Step {
    // -----------------------------------------------------------------------
    // Library usage
    // -----------------------------------------------------------------------

    using SafeERC20 for IERC20;

    // -----------------------------------------------------------------------
    // Errors
    // -----------------------------------------------------------------------

    error Error_InvalidProof();
    error Error_NothingToVest();
    error Error_IdZero();
    error Error_RootZero();
    error Error_RootAdded();
    error Error_InvalidData();

    // -----------------------------------------------------------------------
    // Events
    // -----------------------------------------------------------------------

    /**
     * @dev Emitted when a user's tokens are vested.
     * @param id The id of the vesting schedule.
     * @param user The address of the user whose tokens have been vested.
     * @param index The index of the vesting in the merkle proofs.
     * @param amount The amount of tokens vested.
     */
    event Vested(
        uint256 indexed id,
        address indexed user,
        uint256 index,
        uint256 amount
    );

    // -----------------------------------------------------------------------
    // Constructor
    // -----------------------------------------------------------------------

    constructor(
        address _vestedToken
    ) TokenVesting(_vestedToken) Ownable(msg.sender) {}

    // -----------------------------------------------------------------------
    // User actions
    // -----------------------------------------------------------------------

    /**
     * @notice Allows initializing vesting by the user.
     *
     * @dev This function allows the user to add new vestings to their account.
     * It validates that all the data provided is valid against the Merkle root.
     * If the data is valid, it calculates the total vested amount and updates
     * the user's vested balance accordingly. If the user tries to perform a transaction
     * without adding any new vestings, the transaction will be reverted.
     *
     * @dev Validations:
     * - The length of the indexes, amounts, and proofs arrays must be the same.
     * - Each provided Merkle proof must be valid against the Merkle root.
     * - The user cannot perform a transaction without adding any new vesting.
     *
     * @param id The id of the vesting schedule for which vestings are added.
     * @param user The address of the user for which vestings are added.
     * @param indexes Array of merkle proof data indexes.
     * @param amounts Array of tokens to vest for each user vesting.
     * @param proofs Array of arrays of all user Merkle proofs.
     *
     * Emits a Vested event for each successfully claimed vesting.
     */
    function initVestings(
        uint256 id,
        address user,
        uint256[] calldata indexes,
        uint256[] calldata amounts,
        bytes32[][] calldata proofs
    ) external {
        uint256 _vested = 0;

        if (
            indexes.length != amounts.length || indexes.length != proofs.length
        ) {
            revert Error_InvalidData();
        }

        for (uint256 i = 0; i < indexes.length; i++) {
            if (!isClaimed(id, indexes[i])) {
                if (
                    !_verify(id, proofs[i], _leaf(indexes[i], user, amounts[i]))
                ) {
                    revert Error_InvalidProof();
                }

                _vested += amounts[i];

                _setClaimed(id, indexes[i]);
                emit Vested(id, user, indexes[i], amounts[i]);
            }
        }

        if (_vested == 0) {
            revert Error_NothingToVest();
        }

        vested[id][user] += _vested;
    }

    // -----------------------------------------------------------------------
    // Owner actions
    // -----------------------------------------------------------------------

    /**
     * @notice Allows the owner to add a vesting schedule with a Merkle root and
     * deposit the vested tokens
     *
     * @dev Validations:
     * - Only the owner of the contract can call this function
     * - The Merkle root has not been set before for the given id
     * - The allowance on the vested token has been properly set
     * - The id is not zero
     * - The Merkle root is not zero
     *
     * @param id Unique identifier for the vesting schedule
     * @param start Timestamp of the starting date of the vesting schedule
     * @param cliff Duration of the cliff of the vesting schedule (in seconds)
     * @param recurrences Number of vesting recurrences in the schedule (30 days each)
     * @param startBPS Percentage of tokens that will be vested initially
     * @param merkleRoot The Merkle root of the proof tree for the vesting schedule
     * @param totalAmount The total amount of tokens to be vested for the schedule
     */
    function addVestingSchedule(
        uint256 id,
        uint40 start,
        uint32 cliff,
        uint16 recurrences,
        uint16 startBPS,
        bytes32 merkleRoot,
        uint256 totalAmount
    ) external onlyOwner {
        if (id == 0) {
            revert Error_IdZero();
        }

        if (merkleRoot == bytes32(0)) {
            revert Error_RootZero();
        }

        if (merkleRoots[id] != bytes32(0)) {
            revert Error_RootAdded();
        }

        _addVestingSchedule(id, start, cliff, recurrences, startBPS);
        _addMerkleRoot(id, merkleRoot);

        vestedToken.safeTransferFrom(msg.sender, address(this), totalAmount);
    }

    // -----------------------------------------------------------------------
    // Internal functions
    // -----------------------------------------------------------------------

    /**
     * @dev Internal function for calculating the hash of Merkle tree leaf
     * from provided parameters. Uses double-hash Merkle tree leafs to prevent
     * second preimage attacks.
     *
     * @param index Index of vesting in Merkle tree data
     * @param account Address of user
     * @param amount Amount of tokens vested for user
     *
     * @return bytes32 Hashed Merkle tree leaf
     */
    function _leaf(
        uint256 index,
        address account,
        uint256 amount
    ) private pure returns (bytes32) {
        return
            keccak256(
                bytes.concat(keccak256(abi.encode(index, account, amount)))
            );
    }
}
// SPDX-License-Identifier: MIT

pragma solidity 0.8.23;

import { MerkleProof } from "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

/**
 * @title MerkleDistributor
 * @dev A contract for distributing tokens using a merkle tree.
 */
abstract contract MerkleDistributor {
    // -----------------------------------------------------------------------
    // Storage variables
    // -----------------------------------------------------------------------

    /// @notice Mapping of id's to their corresponding merkle roots.
    mapping(uint256 => bytes32) public merkleRoots;
    /// @dev packed array of booleans for claims per merkle root id's.
    mapping(uint256 => mapping(uint256 => uint256)) private claimedBitMap;

    // -----------------------------------------------------------------------
    // Getters
    // -----------------------------------------------------------------------

    /**
     * @dev Checks if a merkle claim has been claimed from the merkle tree.
     *
     * @param id The id of the merkle root.
     * @param index The index of the claim.
     *
     * @return A boolean indicating whether the claim has been claimed.
     */
    function isClaimed(uint256 id, uint256 index) public view returns (bool) {
        uint256 claimedWordIndex = index / 256;
        uint256 claimedBitIndex = index % 256;
        uint256 claimedWord = claimedBitMap[id][claimedWordIndex];
        uint256 mask = (1 << claimedBitIndex);
        return claimedWord & mask == mask;
    }

    // -----------------------------------------------------------------------
    // Internal functions
    // -----------------------------------------------------------------------

    /**
     * @dev Adds a merkle root for a specific id.
     *
     * @param id The id of the merkle root.
     * @param merkleRoot The merkle root to be added.
     *
     * Notes:
     * - All validations should be done in the parent contract.
     */
    function _addMerkleRoot(uint256 id, bytes32 merkleRoot) internal {
        merkleRoots[id] = merkleRoot;
    }

    /**
     * @dev Sets that a merkle claim has been claimed.
     *
     * @param id The id of the merkle root.
     * @param index The index of the claim.
     */
    function _setClaimed(uint256 id, uint256 index) internal {
        uint256 claimedWordIndex = index / 256;
        uint256 claimedBitIndex = index % 256;
        claimedBitMap[id][claimedWordIndex] =
            claimedBitMap[id][claimedWordIndex] |
            (1 << claimedBitIndex);
    }

    /**
     * @dev Verifies a merkle claim using a provided merkle proof and leaf.
     *
     * @param id The id of the merkle root.
     * @param merkleProof The merkle proofs to be used for verification.
     * @param leaf The leaf to be used for verification.
     *
     * @return A boolean indicating whether the merkle proof is valid.
     */
    function _verify(
        uint256 id,
        bytes32[] calldata merkleProof,
        bytes32 leaf
    ) internal view returns (bool) {
        return MerkleProof.verify(merkleProof, merkleRoots[id], leaf);
    }
}
// SPDX-License-Identifier: MIT

pragma solidity 0.8.23;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { SafeERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

/**
 * @title TokenVesting
 * @notice Vesting contract that allows configuring periodic vesting with start tokens and cliff time.
 */
abstract contract TokenVesting {
    // -----------------------------------------------------------------------
    // Library usage
    // -----------------------------------------------------------------------

    using SafeERC20 for IERC20;

    // -----------------------------------------------------------------------
    // Errors
    // -----------------------------------------------------------------------

    error Error_TokenZeroAddress();
    error Error_InvalidPercents();
    error Error_InvalidRecurrences();
    error Error_NothingToClaim();
    error Error_InvalidTimestamps();

    // -----------------------------------------------------------------------
    // Events
    // -----------------------------------------------------------------------

    /**
     * @notice This event is emitted when a user claims vested tokens.
     * @param id The ID of the vesting schedule.
     * @param user The address of the user who claimed the tokens.
     * @param amount The amount of tokens claimed.
     */
    event Claimed(uint256 indexed id, address indexed user, uint256 amount);

    // -----------------------------------------------------------------------
    // Storage variables
    // -----------------------------------------------------------------------

    /**
     * @notice A struct representing the parameters of a vesting schedule.
     * @dev This struct contains the following fields:
     *      - `start`: the timestamp at which the vesting begins
     *      - `cliff`: the duration of the cliff period in seconds
     *      - `end`: the timestamp at which the vesting ends
     *      - `recurrences`: the number of times tokens are released
     *      - `startBPS`: the basis points of tokens released at the start of vesting
     */
    struct VestingSchedule {
        uint40 start;
        uint32 cliff;
        uint40 end;
        uint16 recurrences;
        uint16 startBPS;
    }

    /// @notice Basis points represented in 1/100th of a percent
    uint256 public constant BPS = 10000;
    /// @notice Duration of one month in seconds
    uint256 public constant MONTH = 30 days;

    /// @notice Address of vested token
    IERC20 public immutable vestedToken;

    /// @notice Mapping of vesting schedule for each vesting ID
    mapping(uint256 => VestingSchedule) public vestings;
    /// @notice Mapping of user's total amount of vested tokens for each vesting ID
    mapping(uint256 => mapping(address => uint256)) public vested;
    /// @notice Mapping of user's total amount of claimed tokens for each vesting ID
    mapping(uint256 => mapping(address => uint256)) public claimed;

    // -----------------------------------------------------------------------
    // Constructor
    // -----------------------------------------------------------------------

    /**
     * @notice Creates a new Vesting contract instance for the specified token.
     * @dev The token address must not be the zero address.
     *
     * @param _vestedToken Address of the token to be vested.
     */
    constructor(address _vestedToken) {
        if (_vestedToken == address(0)) {
            revert Error_TokenZeroAddress();
        }

        vestedToken = IERC20(_vestedToken);
    }

    // -----------------------------------------------------------------------
    // User actions
    // -----------------------------------------------------------------------

    /**
     * @notice Claim vested tokens for a given vesting schedule
     * @dev Calculates the amount of claimable tokens for a given user
     *      and vesting schedule and transfers them to the user.
     *      Throws an error if there are no tokens to claim.
     *
     * @param id The ID of the vesting schedule to claim tokens from
     *
     * Requirements:
     * - The caller must have vested tokens from the given vesting schedule.
     * - There must be tokens available to claim.
     *
     * Notes:
     * - The _claimable function return 0 for not exited vesting schedule.
     */
    function claim(uint256 id) external {
        uint256 claimable = _claimable(
            id,
            vested[id][msg.sender],
            claimed[id][msg.sender]
        );

        if (claimable == 0) {
            revert Error_NothingToClaim();
        }

        claimed[id][msg.sender] += claimable;

        emit Claimed(id, msg.sender, claimable);

        vestedToken.safeTransfer(msg.sender, claimable);
    }

    // -----------------------------------------------------------------------
    // Getters
    // -----------------------------------------------------------------------

    /**
     * @notice Calculates the amount of vested tokens claimable by a user for a specific vesting schedule
     *
     * @param id The id of the vesting schedule
     * @param user The address of the user to check for claimable tokens
     *
     * @return The amount of vested tokens claimable by the user
     */
    function getClaimable(
        uint256 id,
        address user
    ) external view returns (uint256) {
        return _claimable(id, vested[id][user], claimed[id][user]);
    }

    // -----------------------------------------------------------------------
    // Internal functions
    // -----------------------------------------------------------------------

    /**
     * @notice Adds a new vesting schedule
     *
     * @param id The id of the vesting schedule
     * @param start The timestamp of the start of the vesting schedule
     * @param cliff The duration in seconds of the cliff in the vesting schedule
     * @param recurrences The number of times tokens will vest after the cliff
     * @param startBPS The percentage of tokens that will vest at the start of the schedule, in basis points
     *
     * Requirements:
     * - The `startBPS` must be less than or equal to BPS
     * - The number of `recurrences` must be greater than 0
     */
    function _addVestingSchedule(
        uint256 id,
        uint40 start,
        uint32 cliff,
        uint16 recurrences,
        uint16 startBPS
    ) internal {
        if (startBPS > BPS) {
            revert Error_InvalidPercents();
        }

        if (recurrences == 0) {
            revert Error_InvalidRecurrences();
        }

        vestings[id] = VestingSchedule(
            start,
            cliff,
            start + cliff + recurrences * uint40(MONTH),
            recurrences,
            startBPS
        );
    }

    /**
     * @dev Calculates the amount of tokens that are currently claimable for a given vesting schedule.
     *
     * @param id The id of the vesting schedule.
     * @param vested_ The total amount of tokens that have been vested for the vesting schedule.
     * @param claimed_ The total amount of tokens that have already been claimed for the vesting schedule.
     *
     * @return claimable The amount of tokens that are currently claimable for the vesting schedule.
     *
     * Notes:
     * - Uses timestamp for comparison, but can't be affected by its manipulation.
     * - Function performs a multiplication on the result of a division, this is expected and safe.
     */
    function _claimable(
        uint256 id,
        uint256 vested_,
        uint256 claimed_
    ) private view returns (uint256 claimable) {
        uint256 timestamp = block.timestamp;

        uint256 startTime = vestings[id].start;
        uint256 cliffTime = startTime + uint256(vestings[id].cliff);
        uint256 endTime = vestings[id].end;
        uint256 startTokens = (vested_ * uint256(vestings[id].startBPS)) / BPS;
        uint256 recurrences = vestings[id].recurrences;

        // not started
        if (startTime > timestamp) return 0;

        if (timestamp <= cliffTime) {
            // we are after start but before cliff time
            // start tokens should be released
            claimable = startTokens;
        } else if (timestamp > cliffTime && timestamp < endTime) {
            // we are somewhere in the middle
            uint256 vestedAmount = vested_ - startTokens;
            uint256 everyRecurrenceReleaseAmount = vestedAmount / recurrences;

            uint256 occurrences = (timestamp - cliffTime) / MONTH;

            uint256 vestingUnlockedAmount = occurrences *
                everyRecurrenceReleaseAmount;

            claimable = vestingUnlockedAmount + startTokens;
        } else {
            // time has passed, we can take all tokens
            claimable = vested_;
        }

        // but maybe we take something earlier?
        claimable -= claimed_;
    }
}
