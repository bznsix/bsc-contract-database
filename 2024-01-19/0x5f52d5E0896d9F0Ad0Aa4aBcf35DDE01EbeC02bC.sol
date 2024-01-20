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
// OpenZeppelin Contracts (last updated v4.9.0) (token/ERC721/IERC721.sol)

pragma solidity ^0.8.0;

import "../../utils/introspection/IERC165.sol";

/**
 * @dev Required interface of an ERC721 compliant contract.
 */
interface IERC721 is IERC165 {
    /**
     * @dev Emitted when `tokenId` token is transferred from `from` to `to`.
     */
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables `approved` to manage the `tokenId` token.
     */
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables or disables (`approved`) `operator` to manage all of its assets.
     */
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    /**
     * @dev Returns the number of tokens in ``owner``'s account.
     */
    function balanceOf(address owner) external view returns (uint256 balance);

    /**
     * @dev Returns the owner of the `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function ownerOf(uint256 tokenId) external view returns (address owner);

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external;

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must have been allowed to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(address from, address to, uint256 tokenId) external;

    /**
     * @dev Transfers `tokenId` token from `from` to `to`.
     *
     * WARNING: Note that the caller is responsible to confirm that the recipient is capable of receiving ERC721
     * or else they may be permanently lost. Usage of {safeTransferFrom} prevents loss, though the caller must
     * understand this adds an external call which potentially creates a reentrancy vulnerability.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address from, address to, uint256 tokenId) external;

    /**
     * @dev Gives permission to `to` to transfer `tokenId` token to another account.
     * The approval is cleared when the token is transferred.
     *
     * Only a single account can be approved at a time, so approving the zero address clears previous approvals.
     *
     * Requirements:
     *
     * - The caller must own the token or be an approved operator.
     * - `tokenId` must exist.
     *
     * Emits an {Approval} event.
     */
    function approve(address to, uint256 tokenId) external;

    /**
     * @dev Approve or remove `operator` as an operator for the caller.
     * Operators can call {transferFrom} or {safeTransferFrom} for any token owned by the caller.
     *
     * Requirements:
     *
     * - The `operator` cannot be the caller.
     *
     * Emits an {ApprovalForAll} event.
     */
    function setApprovalForAll(address operator, bool approved) external;

    /**
     * @dev Returns the account approved for `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function getApproved(uint256 tokenId) external view returns (address operator);

    /**
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     *
     * See {setApprovalForAll}
     */
    function isApprovedForAll(address owner, address operator) external view returns (bool);
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
/**
* @title DXLock - Empowering Trust through Token Locking
* @dev Secure, User-Friendly Smart Contract to Lock Liquidity and Regular Tokens.
*
* 🚀 Introduction:
* Welcome to DXLock, the pinnacle of token locking on the blockchain! Developed with passion and precision,
* DXLock stands out as a beacon of trust and commitment in the crypto world. This smart contract is meticulously
* crafted to lock both liquidity tokens and regular ERC20 tokens, ensuring a secure and transparent environment
* for your assets.
*
* 🌐 Visit DXLock:
* Dive deeper into the world of DXLock by visiting our platform at [dx.app](
https://dx.app).
Discover a treasure trove of features,
* tutorials, and support to elevate your token locking experience!
*
* 💡 Features:
* 1. **Liquidity Locking**: Cement your project's credibility by locking liquidity tokens. Show the world that you're here to stay!
* 2. **Token Locking**: Not just for liquidity! Lock any ERC20 tokens with ease and confidence.
* 3. **Time-locked Security**: Your tokens are safe and sound until the predetermined unlock time hits the clock.
* 4. **Transparent and Trustworthy**: Open-source and audited, DXLock is a fortress of reliability.
*
* 🛡️ Security:
* Your trust is our top priority. DXLock is fortified with industry-leading security practices to shield your assets
* and ensure a seamless experience. Though thorough audits have been conducted, we encourage users to do their own
* research and verify the contract's integrity before engaging.
*
* 📖 How to Use:
* Engaging with DXLock is a breeze! Simply deposit your tokens, set the lock duration, and rest easy knowing
* your assets are in good hands. Once the lock period concludes, withdrawing is just a click away.
*
* 👥 Community and Support:
* Join our vibrant community and connect with the DXLock team and fellow users! Your feedback and questions are invaluable
* to us, as we continually strive to enhance DXLock’s functionality and user experience.
*
* 📜 License:
* DXLock is proudly released under the MIT License. We believe in openness and the power of community-driven innovation.
*
* @author The DXLock Team
* @notice Utilize DXLock at your own discretion. We’ve done everything to ensure its security, but the final responsibility lies with the user.
*/
// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";

interface decentralizedStorage {
    function addNewLock(
        address _lpAddress,
        uint256 _locktime,
        address _lockContract,
        uint256 _tokenAmount,
        string memory _logo
    ) external;

    function extendLockerTime(
        uint256 _userLockerNumber,
        uint256 _newLockTime
    ) external;

    function transferLocker(
        address _newOwner,
        uint256 _userLockerNumber
    ) external;

    function unlockLocker(uint256 _userLockerNumber) external;

    function changeLogo(
        string memory _newLogo,
        uint256 _userLockerNumber
    ) external;

    function getPersonalLockerCount(address _owner) external returns (uint256);

    function getBurnContractAddress() external view returns (address);
}

interface ReferralContract {
    function getDiscountedPrice(string memory _code) external returns (uint256);

    function validateCode(string memory _code) external returns (bool);

    function fetchCodeOwner(string memory _code) external returns (address);

    function fetchCodeOwnerPercentage(
        string memory _code
    ) external returns (uint256);

    function updateReferrerAmounts(
        address _referrer,
        uint256 _updateAmount
    ) external returns (bool);

    function updateCodeUseNumber(
        string memory _code,
        address _presaleAddress
    ) external returns (bool);
}

interface INonfungiblePositionManager {
    function approve(address to, uint256 tokenId) external;

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    struct MintParams {
        address token0;
        address token1;
        uint24 fee;
        int24 tickLower;
        int24 tickUpper;
        uint256 amount0Desired;
        uint256 amount1Desired;
        uint256 amount0Min;
        uint256 amount1Min;
        address recipient;
        uint256 deadline;
    }

    function mint(
        MintParams calldata params
    )
        external
        payable
        returns (
            uint256 tokenId,
            uint128 liquidity,
            uint256 amount0,
            uint256 amount1
        );

    struct Position {
        uint96 nonce;
        address operator;
        address token0;
        address token1;
        uint24 fee;
        int24 tickLower;
        int24 tickUpper;
        uint128 liquidity;
        uint256 feeGrowthInside0LastX128;
        uint256 feeGrowthInside1LastX128;
        uint128 tokensOwed0;
        uint128 tokensOwed1;
    }

    function positions(
        uint256 tokenId
    )
        external
        view
        returns (
            uint96 nonce,
            address operator,
            address token0,
            address token1,
            uint24 fee,
            int24 tickLower,
            int24 tickUpper,
            uint128 liquidity,
            uint256 feeGrowthInside0LastX128,
            uint256 feeGrowthInside1LastX128,
            uint128 tokensOwed0,
            uint128 tokensOwed1
        );

    struct IncreaseLiquidityParams {
        uint256 tokenId;
        uint256 amount0Desired;
        uint256 amount1Desired;
        uint256 amount0Min;
        uint256 amount1Min;
        uint256 deadline;
    }

    /// @notice Increases the amount of liquidity in a position, with tokens paid by the `msg.sender`
    /// @param params tokenId The ID of the token for which liquidity is being increased,
    /// amount0Desired The desired amount of token0 to be spent,
    /// amount1Desired The desired amount of token1 to be spent,
    /// amount0Min The minimum amount of token0 to spend, which serves as a slippage check,
    /// amount1Min The minimum amount of token1 to spend, which serves as a slippage check,
    /// deadline The time by which the transaction must be included to effect the change
    /// @return liquidity The new liquidity amount as a result of the increase
    /// @return amount0 The amount of token0 to acheive resulting liquidity
    /// @return amount1 The amount of token1 to acheive resulting liquidity
    function increaseLiquidity(
        IncreaseLiquidityParams calldata params
    )
        external
        payable
        returns (uint128 liquidity, uint256 amount0, uint256 amount1);

    struct DecreaseLiquidityParams {
        uint256 tokenId;
        uint128 liquidity;
        uint256 amount0Min;
        uint256 amount1Min;
        uint256 deadline;
    }

    /// @notice Decreases the amount of liquidity in a position and accounts it to the position
    /// @param params tokenId The ID of the token for which liquidity is being decreased,
    /// amount The amount by which liquidity will be decreased,
    /// amount0Min The minimum amount of token0 that should be accounted for the burned liquidity,
    /// amount1Min The minimum amount of token1 that should be accounted for the burned liquidity,
    /// deadline The time by which the transaction must be included to effect the change
    /// @return amount0 The amount of token0 accounted to the position's tokens owed
    /// @return amount1 The amount of token1 accounted to the position's tokens owed
    function decreaseLiquidity(
        DecreaseLiquidityParams calldata params
    ) external payable returns (uint256 amount0, uint256 amount1);

    struct CollectParams {
        uint256 tokenId;
        address recipient;
        uint128 amount0Max;
        uint128 amount1Max;
    }

    function collect(
        CollectParams calldata params
    ) external payable returns (uint256 amount0, uint256 amount1);

    function factory() external view returns (address);

    function burn(uint256 tokenId) external payable;
}

contract PersonalLPv3LockerLPFee is IERC721Receiver, Ownable, ReentrancyGuard {
    uint256 public LockerType = 4;

    uint256 public personalLockerCount;
    address public storagePersonal;

    uint256 public LockExpireTimestamp;
    uint256 public LockerCreationTimestamp;

    uint256 public tokenId;
    bool public tokenWithdrawn;

    address internal feeDeposit;
    uint256 public relockFee;
    uint256 public collectFee;

    bool public relockAfterExpire = true;

    INonfungiblePositionManager public immutable nftPositionManager;

    uint256 public constant FEE_DENOMINATOR = 10000; // denominator for lp fees

    constructor(
        address _lockTokenAddress,
        uint256 _tokenId,
        uint256 _lockTimeEnd,
        uint256 _personalLockerCount,
        address _lockerStorage,
        uint256 _collectFee,
        uint256 _relockFee,
        address _feeDeposit
    ) {
        require(
            _lockTimeEnd > (block.timestamp + 600),
            "Please lock longer than now"
        );

        nftPositionManager = INonfungiblePositionManager(_lockTokenAddress);
        tokenId = _tokenId;

        LockExpireTimestamp = _lockTimeEnd;
        personalLockerCount = _personalLockerCount;
        storagePersonal = _lockerStorage;

        LockerCreationTimestamp = block.timestamp;

        collectFee = _collectFee;
        relockFee = _relockFee;
        feeDeposit = _feeDeposit;

        _transferOwnership(tx.origin);
    }

    receive() external payable {}

    function changeLogo(string memory _logo) external onlyOwner {
        decentralizedStorage(storagePersonal).changeLogo(
            _logo,
            personalLockerCount
        );
    }

    function CheckLockedTokenId() public view returns (uint256) {
        return tokenId;
    }

    function ExtendPersonalLocker(
        uint256 _newLockTime
    ) external payable nonReentrant onlyOwner {
        require(
            LockExpireTimestamp < _newLockTime,
            "You cant reduce locktime..."
        );
        require(
            block.timestamp < _newLockTime,
            "You cant extend locktime in the past"
        );
        require(!tokenWithdrawn, "Tokens were already withdrawn");

        (, , uint128 liquidity) = _getLPTokensAndLiquidity();

        _takeRelockLPFee(liquidity);

        LockExpireTimestamp = _newLockTime;
        decentralizedStorage(storagePersonal).extendLockerTime(
            LockExpireTimestamp,
            personalLockerCount
        );
    }

    function _takeRelockLPFee(uint128 liquidity) internal {
        nftPositionManager.decreaseLiquidity(
            INonfungiblePositionManager.DecreaseLiquidityParams(
                tokenId,
                uint128((liquidity * relockFee) / FEE_DENOMINATOR),
                0,
                0,
                block.timestamp
            )
        );
        nftPositionManager.collect(
            INonfungiblePositionManager.CollectParams(
                tokenId,
                feeDeposit,
                type(uint128).max,
                type(uint128).max
            )
        );
    }

    function _getLPTokensAndLiquidity()
        internal
        view
        returns (address token0, address token1, uint128 liquidity)
    {
        (, , token0, token1, , , , liquidity, , , , ) = nftPositionManager
            .positions(tokenId);
    }

    function transferOwnership(address _newOwner) public override onlyOwner {
        _transferOwnership(_newOwner);
        decentralizedStorage(storagePersonal).transferLocker(
            _newOwner,
            personalLockerCount
        );
    }

    function unlockTokenAfterTimestamp() external onlyOwner nonReentrant {
        require(
            block.timestamp >= LockExpireTimestamp,
            "Token is still Locked"
        );
        IERC721(address(nftPositionManager)).safeTransferFrom(
            address(this),
            owner(),
            tokenId
        );

        if (!tokenWithdrawn) {
            decentralizedStorage(storagePersonal).unlockLocker(
                personalLockerCount
            );
            tokenWithdrawn = true;
        }
    }

    /**
     * @dev Collect fees to _recipient if msg.sender is the owner of tokenId
     */
    function collect()
        external
        nonReentrant
        onlyOwner
        returns (uint256 amount0, uint256 amount1, uint256 fee0, uint256 fee1)
    {
        (amount0, amount1, fee0, fee1) = _collect();
    }

    function _collect()
        private
        returns (uint256 amount0, uint256 amount1, uint256 fee0, uint256 fee1)
    {
        if (collectFee == 0) {
            (amount0, amount1) = nftPositionManager.collect(
                INonfungiblePositionManager.CollectParams(
                    tokenId,
                    owner(),
                    type(uint128).max,
                    type(uint128).max
                )
            );
        } else {
            (address token0, address token1, ) = _getLPTokensAndLiquidity();
            nftPositionManager.collect(
                INonfungiblePositionManager.CollectParams(
                    tokenId,
                    address(this),
                    type(uint128).max,
                    type(uint128).max
                )
            );

            uint256 balance0 = IERC20(token0).balanceOf(address(this));
            uint256 balance1 = IERC20(token1).balanceOf(address(this));
            address feeTo = feeDeposit;
            address remainderTo = owner();

            if (balance0 > 0) {
                fee0 = (balance0 * collectFee) / FEE_DENOMINATOR;
                require(
                    IERC20(token0).transfer(feeTo, fee0),
                    "erc20 transfer failed"
                );
                amount0 = balance0 - fee0;
                require(
                    IERC20(token0).transfer(remainderTo, amount0),
                    "erc20 transfer failed"
                );
            }

            if (balance1 > 0) {
                fee1 = (balance1 * collectFee) / FEE_DENOMINATOR;
                require(
                    IERC20(token1).transfer(feeTo, fee1),
                    "erc20 transfer failed"
                );
                amount1 = balance1 - fee1;
                require(
                    IERC20(token1).transfer(remainderTo, amount1),
                    "erc20 transfer failed"
                );
            }
        }
    }

    function withdrawNativeToken(
        address payable user
    ) public onlyOwner nonReentrant {
        require(user != address(0), "zero address");
        Address.sendValue(user, address(this).balance);
    }

    function withdrawStuckCurrency(
        address payable user,
        address _token
    ) external onlyOwner nonReentrant {
        uint256 amount = IERC20(_token).balanceOf(address(this));
        IERC20(_token).transfer(user, amount);
    }

    function onERC721Received(
        address,
        address,
        uint256,
        bytes calldata
    ) external override returns (bytes4) {
        return this.onERC721Received.selector;
    }
}

contract DxLockLPV3DepLPFee is Ownable, ReentrancyGuard, IERC721Receiver {
    uint256 public constant FEE_DENOMINATOR = 10000; // denominator for lp fees
    uint256 public constant HUNDRED = 100;
    address public PersonalLockerStorage;
    address public referralDappAddr;
    bool public referralDisabled;
    string public dappFeeName = "dxlockFeesTokenLPv3v2";
    uint256 public lpFee = 1;
    uint256 public collectFee = 1;
    uint256 public relockFee = 1;
    address public tokenFeeAddress = 0xb44ea272f317E379567Ce54Acd94a2891597024E;
    address[] public LockerContractStorage;
    mapping(address => bool) public whitelistedNFTPositionManagers;

    constructor(address _lockerStorage, address _referralContract) {
        PersonalLockerStorage = _lockerStorage;
        referralDappAddr = _referralContract;
    }

    function whitelistNFTPositionManager(
        address _nftPositionManager
    ) external onlyOwner {
        require(_nftPositionManager != address(0), "address(0)");
        require(
            !whitelistedNFTPositionManagers[_nftPositionManager],
            "already whitelisted"
        );
        whitelistedNFTPositionManagers[_nftPositionManager] = true;
    }

    function blacklistNFTPositionManager(
        address _nftPositionManager
    ) external onlyOwner {
        require(_nftPositionManager != address(0), "address(0)");
        require(
            whitelistedNFTPositionManagers[_nftPositionManager],
            "not whitelisted"
        );
        whitelistedNFTPositionManagers[_nftPositionManager] = false;
    }

    function createLPLocker(
        INonfungiblePositionManager _nftPositionManager,
        uint256 _tokenId,
        uint256 _lockerEndTimeStamp,
        string memory _logo,
        string memory _referralCode
    ) public nonReentrant returns (address newLock) {
        require(address(_nftPositionManager) != address(0), "address(0)");
        require(address(referralDappAddr) != address(0), "address(0)");
        require(address(PersonalLockerStorage) != address(0), "address(0)");
        require(
            whitelistedNFTPositionManagers[address(_nftPositionManager)],
            "not whitelisted NFTPositionManager"
        );
        require(_tokenId != 0, "invalid tokenId");

        (
            address token0,
            address token1,
            uint128 liquidity
        ) = _getLPTokensAndLiquidity(_nftPositionManager, _tokenId);

        if (lpFee > 0) {
            uint256 balance0 = IERC20(token0).balanceOf(address(this));
            uint256 balance1 = IERC20(token1).balanceOf(address(this));

            _takeLPFee((_nftPositionManager), _tokenId, liquidity);

            uint256 balance0After = IERC20(token0).balanceOf(address(this));
            uint256 balance1After = IERC20(token1).balanceOf(address(this));

            _distributeReferralFee(
                _referralCode,
                token0,
                token1,
                balance0After - balance0,
                balance1After - balance1
            );

            _sendLPFeeToFeeAddress(token0, token1);
        }

        address lock = _createLockerAndLockNFT(
            address(_nftPositionManager),
            _tokenId,
            _lockerEndTimeStamp,
            _logo
        );

        if (!referralDisabled) {
            require(
                ReferralContract(referralDappAddr).updateCodeUseNumber(
                    _referralCode,
                    address(lock)
                ),
                "code use update failed"
            );
        }

        return address(lock);
    }

    function _takeLPFee(
        INonfungiblePositionManager nftPositionManager,
        uint256 tokenId,
        uint128 liquidity
    ) internal {
        IERC721(address(nftPositionManager)).safeTransferFrom(
            msg.sender,
            address(this),
            tokenId,
            ""
        );

        nftPositionManager.decreaseLiquidity(
            INonfungiblePositionManager.DecreaseLiquidityParams(
                tokenId,
                uint128((liquidity * lpFee) / FEE_DENOMINATOR),
                0,
                0,
                block.timestamp
            )
        );
        nftPositionManager.collect(
            INonfungiblePositionManager.CollectParams(
                tokenId,
                address(this),
                type(uint128).max,
                type(uint128).max
            )
        );
    }

    function _distributeReferralFee(
        string memory _referralCode,
        address token0,
        address token1,
        uint256 amount0,
        uint256 amount1
    ) internal {
        bytes32 referralCode = keccak256(abi.encodePacked(_referralCode));
        bytes32 defaultReferralCode = keccak256(abi.encodePacked("default"));

        if (referralDisabled) {
            require(
                referralCode == defaultReferralCode,
                "only default code allowed"
            );
        }
        if (referralCode != defaultReferralCode) {
            require(
                ReferralContract(referralDappAddr).validateCode(_referralCode),
                "invalid discount code"
            );

            uint256 referrerPerc = ReferralContract(referralDappAddr)
                .fetchCodeOwnerPercentage(_referralCode);

            address referrerAddress = ReferralContract(referralDappAddr)
                .fetchCodeOwner(_referralCode);

            uint256 referrerToken0Amount = ((amount0) * (referrerPerc)) /
                HUNDRED;

            uint256 referrerToken1Amount = ((amount1) * (referrerPerc)) /
                HUNDRED;

            if (referrerToken0Amount > 0) {
                require(
                    IERC20(token0).transfer(
                        referrerAddress,
                        referrerToken0Amount
                    ),
                    "erc20 transfer failed"
                );
            }

            if (referrerToken1Amount > 0) {
                require(
                    IERC20(token1).transfer(
                        referrerAddress,
                        referrerToken1Amount
                    ),
                    "erc20 transfer failed"
                );
            }
        }
    }

    function _sendLPFeeToFeeAddress(address token0, address token1) internal {
        require(
            IERC20(token0).transfer(
                tokenFeeAddress,
                IERC20(token0).balanceOf(address(this))
            ),
            "erc20 transfer failed"
        );
        require(
            IERC20(token1).transfer(
                tokenFeeAddress,
                IERC20(token1).balanceOf(address(this))
            ),
            "erc20 transfer failed"
        );
    }

    function _createLockerAndLockNFT(
        address _lockingToken,
        uint256 _tokenId,
        uint256 _lockerEndTimeStamp,
        string memory _logo
    ) internal returns (address lock) {
        uint256 _counter = decentralizedStorage(PersonalLockerStorage)
            .getPersonalLockerCount(msg.sender);

        PersonalLPv3LockerLPFee createNewLock;
        createNewLock = new PersonalLPv3LockerLPFee(
            _lockingToken,
            _tokenId,
            _lockerEndTimeStamp,
            _counter,
            PersonalLockerStorage,
            collectFee,
            relockFee,
            tokenFeeAddress
        );

        IERC721(_lockingToken).safeTransferFrom(
            address(this),
            address(createNewLock),
            _tokenId,
            ""
        );

        decentralizedStorage(PersonalLockerStorage).addNewLock(
            _lockingToken,
            _lockerEndTimeStamp,
            address(createNewLock),
            _tokenId,
            _logo
        );
        LockerContractStorage.push(address(createNewLock));

        return address(createNewLock);
    }

    function changeStorageContract(address _lockerStorage) external onlyOwner {
        PersonalLockerStorage = _lockerStorage;
    }

    function changeReferralContract(
        address _newRefContract
    ) external onlyOwner {
        referralDappAddr = _newRefContract;
    }

    function disableReferral() external onlyOwner {
        require(!referralDisabled, "referral already disabled");
        referralDisabled = true;
    }

    function enableReferral() external onlyOwner {
        require(referralDisabled, "referral already enabled");
        referralDisabled = false;
    }

    function changeLPFee(uint256 _lpFee) external onlyOwner {
        require(_lpFee <= 10, "LP fee out of bounds");
        lpFee = _lpFee;
    }

    function changeRelockFee(uint256 _relockFee) external onlyOwner {
        require(_relockFee <= 10, "Relock fee out of bounds");
        relockFee = _relockFee;
    }

    function changeCollectFee(uint256 _collectFee) external onlyOwner {
        require(_collectFee <= 10, "Collect fee out of bounds");
        collectFee = _collectFee;
    }

    function changeTokenFeeAddress(address _feeAddress) external onlyOwner {
        require(
            _feeAddress != address(0),
            "token fee address cannot be zero address"
        );
        tokenFeeAddress = _feeAddress;
    }

    function updateFeesName(string memory _newFeesName) external onlyOwner {
        dappFeeName = _newFeesName;
    }

    function _getLPTokensAndLiquidity(
        INonfungiblePositionManager nftPositionManager,
        uint256 tokenId
    )
        internal
        view
        returns (address token0, address token1, uint128 liquidity)
    {
        (, , token0, token1, , , , liquidity, , , , ) = nftPositionManager
            .positions(tokenId);
    }

    function getLockerCount() public view returns (uint256 isSize) {
        return LockerContractStorage.length;
    }

    function getAllLockers() public view returns (address[] memory) {
        address[] memory allTokens = new address[](
            LockerContractStorage.length
        );
        for (uint256 i = 0; i < LockerContractStorage.length; i++) {
            allTokens[i] = LockerContractStorage[i];
        }
        return allTokens;
    }

    function withdrawNativeToken(
        address payable user
    ) public onlyOwner nonReentrant {
        require(user != address(0), "zero address");
        Address.sendValue(user, address(this).balance);
    }

    function withdrawStuckCurrency(
        address user,
        address _token
    ) external onlyOwner nonReentrant {
        require(user != address(0), "zero address");
        IERC20 token = IERC20(_token);
        require(
            token.transfer(user, token.balanceOf(address(this))),
            "token transfer failed"
        );
    }

    function onERC721Received(
        address,
        address,
        uint256,
        bytes calldata
    ) external override returns (bytes4) {
        return this.onERC721Received.selector;
    }

    receive() external payable {}
}
