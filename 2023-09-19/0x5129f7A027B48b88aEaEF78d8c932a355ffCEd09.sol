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
// OpenZeppelin Contracts v4.4.1 (token/ERC721/utils/ERC721Holder.sol)

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
    function onERC721Received(
        address,
        address,
        uint256,
        bytes memory
    ) public virtual override returns (bytes4) {
        return this.onERC721Received.selector;
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

pragma solidity ^0.8.0;

interface IERC721NFT {
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    function ownerOf(uint256 tokenId) external view returns (address);

    function creatorOf(uint256 _tokenId) external view returns (address);

    function royalties(uint256 _tokenId) external view returns (uint256);

    function addItem(
        address creator,
        string memory _tokenURI,
        uint256 royalty
    ) external returns (uint256);
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IMemberPass {
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    function ownerOf(uint256 tokenId) external view returns (address);

    function creatorOf(uint256 _tokenId) external view returns (address);

    function memberPassLevel(uint256 tokenId) external view returns (uint256);

    function mintedTimestamp(uint256 tokenId) external view returns (uint256);

    function memberPassBalanceOf(
        address holder,
        uint256 memberLevel
    ) external view returns (uint256);

    function tokenURI(uint256 tokenId) external view returns (string memory);
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IRoyaltyRegistry {
    function getRoyalty(
        address _collectionAddr,
        uint256 _tokenId
    ) external view returns (uint256);

    function getCreator(
        address _collectionAddr,
        uint256 _tokenId
    ) external view returns (address);
}
//
// NFT Market contract
// SPDX-License-Identifier: MIT
//

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";

import "./interfaces/IERC721NFT.sol";
import "./interfaces/IRoyaltyRegistry.sol";
import "./interfaces/IMemberPass.sol";

contract NFTMarket is Ownable, ERC721Holder {
    address public constant NATIVE_ADDRESS =
        address(0x00eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee);

    uint256 public constant PERCENTS_DIVIDER = 10000;

    uint256 public feePercent = 500;
    address public feeAddress;

    address public royaltyRegistry;

    address public memberpassAddress;
    uint256[] public memberDiscount = new uint256[](5); // discount rate [0%:0, 10%: 1000, 20%:2000, 30%:3000, 40%:4000]

    mapping(address => bool) public _managers;

    bool public _bLocked;

    struct Splits {
        address receiver;
        uint256 commission;
    }

    /* Pairs to swap NFT _id => price */
    struct Pair {
        uint256 pair_id;
        address collectionAddr;
        uint256 token_id;
        address creator;
        address owner;
        address buyTokenAddr;
        uint256 price;
        uint256 creatorFee;
        Splits[] splits;
        bool isSell;
        bool bValid;
    }

    // token id => Pair mapping
    mapping(uint256 => Pair) public pairs;
    uint256 public currentPairId;

    mapping(address => uint256) public totalEarnings;
    uint256 public totalSwapped; /* Total swap count */

    /** Events */
    event ManagerAdded(address manager);
    event ManagerRemoved(address manager);

    event ItemListed(Pair pair);
    event ItemDelisted(uint256 id);
    event Swapped(address buyer, Pair pair);

    constructor(address _owner, address _royaltyRegistry) {
        _transferOwnership(_owner);
        feeAddress = _owner;
        royaltyRegistry = _royaltyRegistry;
    }

    function addManager(address managerAddress) public onlyOwner {
        require(managerAddress != address(0), "manager: address is zero");
        require(
            _managers[managerAddress] != true,
            "manager: address is already manager"
        );
        _managers[managerAddress] = true;
        emit ManagerAdded(managerAddress);
    }

    function removeManager(address managerAddress) public onlyOwner {
        require(managerAddress != address(0), "manager: address is zero");
        require(
            _managers[managerAddress] != false,
            "manager: address is already not manager"
        );
        _managers[managerAddress] = false;
        emit ManagerRemoved(managerAddress);
    }

    function setMemberPassAddress(address _memberpassAddress) public onlyOwner {
        memberpassAddress = _memberpassAddress;
    }

    function setMemberDiscount(
        uint256[] memory _memberDiscount
    ) external onlyOwner {
        delete memberDiscount;
        uint256 len = _memberDiscount.length;
        for (uint256 i = 0; i < len; i++) {
            memberDiscount.push(_memberDiscount[i]);
        }
    }

    function setFee(
        address _feeAddress,
        uint256 _feePercent
    ) external onlyOwner {
        feePercent = _feePercent;
        feeAddress = _feeAddress;
    }

    function setRoyaltyRegistry(address _royaltyRegistry) external onlyOwner {
        require(_royaltyRegistry != address(0), "Invalid address");
        royaltyRegistry = _royaltyRegistry;
    }

    function list(
        address _collectionAddr,
        uint256 _token_id,
        uint256 _price,
        address _buyTokenAddr,
        Splits[] memory splits
    ) public OnlyItemOwner(_collectionAddr, _token_id) ReentrancyGuard {
        require(_price > 0, "Invalid price");
        IERC721NFT(_collectionAddr).safeTransferFrom(
            msg.sender,
            address(this),
            _token_id
        );

        currentPairId = currentPairId + 1;

        Pair storage pair = pairs[currentPairId];
        pair.pair_id = currentPairId;
        pair.collectionAddr = _collectionAddr;
        pair.token_id = _token_id;
        pair.creator = IRoyaltyRegistry(royaltyRegistry).getCreator(
            _collectionAddr,
            _token_id
        );
        pair.creatorFee = IRoyaltyRegistry(royaltyRegistry).getRoyalty(
            _collectionAddr,
            _token_id
        );
        pair.owner = msg.sender;
        pair.price = _price;
        pair.buyTokenAddr = _buyTokenAddr;
        pair.splits = splits;
        pair.isSell = true;
        pair.bValid = true;

        emit ItemListed(pair);
    }

    function delist(uint256 _id) external ItemExists(_id) ReentrancyGuard {
        Pair storage pair = pairs[_id];
        require(pair.bValid, "Invalid pair");
        require(
            msg.sender == pair.owner || msg.sender == owner(),
            "Error, you are not the owner"
        );
        require(pair.isSell, "Wrong function call");
        IERC721NFT(pair.collectionAddr).safeTransferFrom(
            address(this),
            pair.owner,
            pair.token_id
        );
        pair.bValid = false;
        emit ItemDelisted(_id);
    }

    function buy(uint256 _id) external payable ItemExists(_id) ReentrancyGuard {
        Pair memory pair = pairs[_id];
        require(pair.bValid, "Invalid pair");
        require(pair.owner != msg.sender, "Owner can not buy");
        require(pair.isSell, "Wrong function call");

        uint256 nftPrice = pair.price;
        address buyTokenAddr = pair.buyTokenAddr;
        bool isNativeCoin = buyTokenAddr == NATIVE_ADDRESS;
        Splits[] memory splits = pair.splits;

        uint256 total_balance = isNativeCoin
            ? msg.value
            : IERC20(buyTokenAddr).balanceOf(msg.sender);

        require(total_balance >= nftPrice, "Insufficient balance");

        uint256 _memberFee = 0;
        if (_managers[pair.owner] == true) {
            uint256 _memberLevel = getMemberLevel(msg.sender);
            _memberFee =
                (nftPrice * memberDiscount[_memberLevel]) /
                PERCENTS_DIVIDER;
        }

        uint256 _adminFee = (nftPrice * feePercent) / PERCENTS_DIVIDER;
        uint256 _creatorFee = (nftPrice * pair.creatorFee) / PERCENTS_DIVIDER;
        uint256 _sellerFee = nftPrice - _adminFee - _creatorFee - _memberFee;

        if (isNativeCoin) {
            // transfer eth to admin
            if (_adminFee > 0) {
                (bool result, ) = payable(feeAddress).call{value: _adminFee}(
                    ""
                );
                require(result, "Failed to transfer Admin fee");
            }

            // transfer eth to creator
            if (_creatorFee > 0) {
                (bool result1, ) = payable(pair.creator).call{
                    value: _creatorFee
                }("");
                require(result1, "Failed to transfer creator fee");
            }
            if (_memberFee > 0) {
                (bool result0, ) = payable(msg.sender).call{value: _memberFee}(
                    ""
                );
                require(result0, "Failed to send coin to member buyer");
            }

            // transfer eth to sellers
            if (_sellerFee > 0) {
                uint256 splitsLen = splits.length;
                uint256 lastSplit = _sellerFee;
                for (uint256 i = 0; i < splitsLen; i++) {
                    uint256 _splitSend = (_sellerFee * splits[i].commission) /
                        PERCENTS_DIVIDER;
                    if (i == splitsLen - 1) _splitSend = lastSplit;
                    else lastSplit = lastSplit - _splitSend;
                    (bool result, ) = payable(splits[i].receiver).call{
                        value: _splitSend
                    }("");
                    require(result, "Failed to send coin to seller");
                }
            }
        } else {
            require(msg.value == 0, "Invalid payable amount");
            IERC20 buyToken = IERC20(buyTokenAddr);
            // transfer erc20 token to adminAddress
            if (_adminFee > 0) {
                SafeERC20.safeTransferFrom(
                    buyToken,
                    msg.sender,
                    feeAddress,
                    _adminFee
                );
            }

            // transfer erc20 token to creator
            if (_creatorFee > 0) {
                SafeERC20.safeTransferFrom(
                    buyToken,
                    msg.sender,
                    pair.creator,
                    _creatorFee
                );
            }

            // transfer erc20 token to seller
            if (_sellerFee > 0) {
                uint256 splitsLen = splits.length;
                uint256 lastSplit = _sellerFee;
                for (uint256 i = 0; i < splitsLen; i++) {
                    uint256 _splitSend = (_sellerFee * splits[i].commission) /
                        PERCENTS_DIVIDER;
                    if (i == splitsLen - 1) _splitSend = lastSplit;
                    else lastSplit = lastSplit - _splitSend;

                    SafeERC20.safeTransferFrom(
                        buyToken,
                        msg.sender,
                        splits[i].receiver,
                        _splitSend
                    );
                }
            }
        }

        // transfer NFT token to buyer
        IERC721NFT(pair.collectionAddr).safeTransferFrom(
            address(this),
            msg.sender,
            pair.token_id
        );

        pairs[_id].bValid = false;

        totalEarnings[buyTokenAddr] = totalEarnings[buyTokenAddr] + nftPrice;
        totalSwapped = totalSwapped + 1;

        emit Swapped(msg.sender, pair);
    }

    function offer(
        address _collectionAddr,
        uint256 _token_id,
        uint256 _price,
        address _buyTokenAddr
    ) public payable ReentrancyGuard {
        require(_price > 0, "Invalid price");

        bool isNativeCoin = _buyTokenAddr == NATIVE_ADDRESS;
        if (isNativeCoin) {
            require(msg.value >= _price, "Insufficient amount");
        } else {
            require(msg.value == 0, "Invalid payable amount");
            SafeERC20.safeTransferFrom(
                IERC20(_buyTokenAddr),
                msg.sender,
                address(this),
                _price
            );
        }

        currentPairId = currentPairId + 1;

        Pair storage pair = pairs[currentPairId];
        pair.pair_id = currentPairId;
        pair.collectionAddr = _collectionAddr;
        pair.token_id = _token_id;
        pair.creator = IRoyaltyRegistry(royaltyRegistry).getCreator(
            _collectionAddr,
            _token_id
        );
        pair.creatorFee = IRoyaltyRegistry(royaltyRegistry).getRoyalty(
            _collectionAddr,
            _token_id
        );
        pair.owner = msg.sender;
        pair.price = _price;
        pair.buyTokenAddr = _buyTokenAddr;
        pair.isSell = false;
        pair.bValid = true;

        emit ItemListed(pair);
    }

    function cancelOffer(uint256 _id) external ItemExists(_id) ReentrancyGuard {
        Pair memory pair = pairs[_id];
        require(pair.bValid, "Invalid pair");
        require(!pair.isSell, "Wrong function call");
        require(
            msg.sender == pair.owner || msg.sender == owner(),
            "Error, you are not the owner"
        );
        bool isNativeCoin = pair.buyTokenAddr == NATIVE_ADDRESS;
        if (isNativeCoin) {
            (bool result, ) = payable(pair.owner).call{value: pair.price}("");
            require(result, "Failed to transfer amount");
        } else {
            SafeERC20.safeTransfer(
                IERC20(pair.buyTokenAddr),
                pair.owner,
                pair.price
            );
        }
        pairs[_id].bValid = false;
        emit ItemDelisted(_id);
    }

    function sell(
        uint256 _id,
        Splits[] memory splits
    )
        external
        payable
        ItemExists(_id)
        OnlyItemOwner(pairs[_id].collectionAddr, pairs[_id].token_id)
        ReentrancyGuard
    {
        Pair memory pair = pairs[_id];
        require(pair.bValid, "Invalid Pair");
        require(!pair.isSell, "Wrong function call");
        require(pair.owner != msg.sender, "Owner can not sell");

        uint256 nftPrice = pair.price;
        address buyTokenAddr = pair.buyTokenAddr;
        bool isNativeCoin = buyTokenAddr == NATIVE_ADDRESS;

        uint256 _memberFee = 0;
        if (_managers[msg.sender] == true) {
            uint256 _memberLevel = getMemberLevel(pair.owner);
            _memberFee =
                (nftPrice * memberDiscount[_memberLevel]) /
                PERCENTS_DIVIDER;
        }
        uint256 _adminFee = (nftPrice * feePercent) / PERCENTS_DIVIDER;
        uint256 _creatorFee = (nftPrice * pair.creatorFee) / PERCENTS_DIVIDER;
        uint256 _sellerFee = nftPrice - _adminFee - _creatorFee - _memberFee;

        if (isNativeCoin) {
            // transfer eth to admin
            if (_adminFee > 0) {
                (bool result, ) = payable(feeAddress).call{value: _adminFee}(
                    ""
                );
                require(result, "Failed to transfer Admin fee");
            }

            // transfer eth to creator
            if (_creatorFee > 0) {
                (bool result1, ) = payable(pair.creator).call{
                    value: _creatorFee
                }("");
                require(result1, "Failed to transfer creator fee");
            }
            if (_memberFee > 0) {
                (bool result0, ) = payable(pair.owner).call{value: _memberFee}(
                    ""
                );
                require(result0, "Failed to send coin to member buyer");
            }

            // transfer eth to owner
            if (_sellerFee > 0) {
                uint256 splitsLen = splits.length;
                uint256 lastSplit = _sellerFee;
                for (uint256 i = 0; i < splitsLen; i++) {
                    uint256 _splitSend = (_sellerFee * splits[i].commission) /
                        PERCENTS_DIVIDER;
                    if (i == splitsLen - 1) _splitSend = lastSplit;
                    else lastSplit = lastSplit - _splitSend;
                    (bool result, ) = payable(splits[i].receiver).call{
                        value: _splitSend
                    }("");
                    require(result, "Failed to send coin to user");
                }
            }
        } else {
            require(msg.value == 0, "Invalid payable amount");
            IERC20 buyToken = IERC20(buyTokenAddr);
            // transfer erc20 token to adminAddress
            if (_adminFee > 0) {
                SafeERC20.safeTransfer(buyToken, feeAddress, _adminFee);
            }

            // transfer erc20 token to creator
            if (_creatorFee > 0) {
                SafeERC20.safeTransfer(buyToken, pair.creator, _creatorFee);
            }

            if (_memberFee > 0) {
                SafeERC20.safeTransfer(buyToken, pair.owner, _memberFee);
            }

            // transfer erc20 token to seller
            if (_sellerFee > 0) {
                uint256 splitsLen = splits.length;
                uint256 lastSplit = _sellerFee;
                for (uint256 i = 0; i < splitsLen; i++) {
                    uint256 _splitSend = (_sellerFee * splits[i].commission) /
                        PERCENTS_DIVIDER;
                    if (i == splitsLen - 1) _splitSend = lastSplit;
                    else lastSplit = lastSplit - _splitSend;

                    SafeERC20.safeTransfer(
                        buyToken,
                        splits[i].receiver,
                        _splitSend
                    );
                }
            }
        }

        // transfer NFT token to buyer
        IERC721NFT(pair.collectionAddr).safeTransferFrom(
            msg.sender,
            pair.owner,
            pair.token_id
        );

        pairs[_id].splits = splits;
        pairs[_id].bValid = false;

        totalEarnings[buyTokenAddr] = totalEarnings[buyTokenAddr] + nftPrice;
        totalSwapped = totalSwapped + 1;

        emit Swapped(msg.sender, pair);
    }

    function getMemberLevel(address user) public view returns (uint256) {
        if (memberpassAddress == address(0)) return 0;
        uint256 memberLevel = 0;
        for (uint256 i = 4; i > 0; i--) {
            if (
                IMemberPass(memberpassAddress).memberPassBalanceOf(user, i) > 0
            ) {
                memberLevel = i;
                break;
            }
        }
        return memberLevel;
    }

    modifier OnlyItemOwner(address collectionAddr, uint256 tokenId) {
        require(IERC721NFT(collectionAddr).ownerOf(tokenId) == msg.sender);
        _;
    }

    modifier ItemExists(uint256 id) {
        require(
            id <= currentPairId && pairs[id].pair_id == id,
            "Could not find item"
        );
        _;
    }

    modifier ReentrancyGuard() {
        require(!_bLocked, "Execution locked");
        _bLocked = true;
        _;
        _bLocked = false;
    }
}
