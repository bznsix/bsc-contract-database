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
pragma solidity ^0.8.0;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import {SafeERC20, IERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import {IBrewlabsSwapFeeManager} from "../libs/IBrewlabsSwapFeeManager.sol";

contract BrewlabsDualFarmImpl is Ownable, ReentrancyGuard {
    using SafeERC20 for IERC20;

    // Whether it is initialized
    bool private isInitialized;
    uint256 private BLOCKS_PER_DAY;
    uint256 private PERCENT_PRECISION;
    uint256 public PRECISION_FACTOR;
    uint256 public MAX_FEE;

    // The staked token
    IERC20 public lpToken;
    IERC20[2] public rewardTokens;

    uint256 public duration;
    // The block number when staking starts.
    uint256 public startBlock;
    // The block number when staking ends.
    uint256 public bonusEndBlock;
    // tokens created per block.
    uint256[2] public rewardsPerBlock;
    // The block number of the last pool update
    uint256 public lastRewardBlock;
    // Accrued token per share
    uint256[2] public accTokensPerShare;
    // The deposit & withdraw fee
    uint256 public depositFee;
    uint256 public withdrawFee;

    // service fees
    address public feeAddress;
    address public treasury;
    uint256 public performanceFee;
    uint256 public rewardFee;

    address feeManager;
    address public deployer;
    address public operator;

    struct UserInfo {
        uint256 amount; // How many staked lp the user has provided
        uint256 rewardDebt; // Reward debt
        uint256 rewardDebt1; // Reflection debt
    }

    // Info of each user that stakes lpToken
    mapping(address => UserInfo) public userInfo;

    uint256 public totalStaked;
    uint256[2] private totalEarned;
    uint256[2] private totalRewardStaked;

    uint256[2] public paidRewards;
    uint256[2] private shouldTotalPaid;

    event Deposit(address indexed user, uint256 amount);
    event Withdraw(address indexed user, uint256 amount);
    event Claim(address indexed user, uint256[2] amount);
    event EmergencyWithdraw(address indexed user, uint256 amount);
    event AdminTokenRecovered(address tokenRecovered, uint256 amount);

    event NewRewardsPerBlock(uint256[2] rewardsPerBlock);
    event RewardsStart(uint256 startBlock, uint256 endBlock);
    event RewardsStop(uint256 blockNumber);
    event EndBlockChanged(uint256 blockNumber);

    event DurationChanged(uint256 duration);
    event FeeManagerChanged(address newMgr);
    event ServiceInfoChanged(address addr, uint256 fee);
    event SetAutoAdjustableForRewardRate(bool status);
    event SetRewardFee(uint256 fee);
    event OperatorTransferred(address oldOperator, address newOperator);

    event SetSettings(uint256 depositFee, uint256 withdrawFee, address feeAddr);

    modifier onlyAdmin() {
        require(
            msg.sender == owner() || msg.sender == operator,
            "Caller is not owner or operator"
        );
        _;
    }

    constructor() {}

    /**
     * @notice Initialize the contract
     * @param _lpToken: LP address
     * @param _rewardTokens: reward token addresses
     * @param _rewardsPerBlock: rewards per block (in rewardToken)
     * @param _depositFee: deposit fee
     * @param _withdrawFee: withdraw fee
     * @param _feeManager: withdraw fee
     * @param _owner: owner address
     * @param _deployer: owner address
     */
    function initialize(
        IERC20 _lpToken,
        IERC20[2] memory _rewardTokens,
        uint256[2] memory _rewardsPerBlock,
        uint256 _depositFee,
        uint256 _withdrawFee,
        uint256 _duration,
        address _owner,
        address _feeManager,
        address _deployer
    ) external {
        require(!isInitialized, "Already initialized");
        require(
            owner() == address(0x0) || msg.sender == owner(),
            "Not allowed"
        );

        // Make this contract initialized
        isInitialized = true;

        PERCENT_PRECISION = 10000;
        BLOCKS_PER_DAY = 28800;
        MAX_FEE = 2000;
        PRECISION_FACTOR = 10 ** 18;

        duration = _duration;
        treasury = 0x5Ac58191F3BBDF6D037C6C6201aDC9F99c93C53A;
        performanceFee = 0.0035 ether;

        lpToken = _lpToken;
        rewardTokens = _rewardTokens;
        rewardsPerBlock = _rewardsPerBlock;

        feeManager = _feeManager;
        deployer = _deployer;
        operator = _deployer;

        feeAddress = _deployer;

        require(_depositFee <= MAX_FEE, "Invalid deposit fee");
        require(_withdrawFee <= MAX_FEE, "Invalid withdraw fee");
        depositFee = _depositFee;
        withdrawFee = _withdrawFee;

        _transferOwnership(_owner);
    }

    /**
     * @notice Deposit LP tokens and collect reward tokens (if any)
     * @param _amount: amount to stake (in lp token)
     */
    function deposit(uint256 _amount) external payable nonReentrant {
        require(
            startBlock > 0 && startBlock < block.number,
            "Farming hasn't started yet"
        );
        require(_amount > 0, "Amount should be greator than 0");

        _transferPerformanceFee();
        _claimReward();

        UserInfo storage user = userInfo[msg.sender];

        uint256 beforeAmt = lpToken.balanceOf(address(this));
        lpToken.safeTransferFrom(address(msg.sender), address(this), _amount);
        uint256 afterAmt = lpToken.balanceOf(address(this));
        uint256 realAmount = afterAmt - beforeAmt;

        if (depositFee > 0) {
            uint256 fee = (realAmount * depositFee) / PERCENT_PRECISION;
            lpToken.safeTransfer(feeAddress, fee);
            realAmount -= fee;
        }
        totalStaked += realAmount;

        user.amount = user.amount + realAmount;
        user.rewardDebt =
            (user.amount * accTokensPerShare[0]) /
            PRECISION_FACTOR;
        user.rewardDebt1 =
            (user.amount * accTokensPerShare[1]) /
            PRECISION_FACTOR;

        emit Deposit(msg.sender, realAmount);

        if (rewardFee > 0) _updateRewardRate();
    }

    /**
     * @notice Withdraw staked lp token and collect reward tokens
     * @param _amount: amount to withdraw (in lp token)
     */
    function withdraw(uint256 _amount) external payable nonReentrant {
        require(_amount > 0, "Amount should be greator than 0");

        UserInfo storage user = userInfo[msg.sender];
        require(user.amount >= _amount, "Amount to withdraw too high");

        _transferPerformanceFee();
        _claimReward();

        if (withdrawFee > 0) {
            uint256 fee = (_amount * withdrawFee) / PERCENT_PRECISION;
            lpToken.safeTransfer(feeAddress, fee);
            lpToken.safeTransfer(msg.sender, _amount - fee);
        } else {
            lpToken.safeTransfer(msg.sender, _amount);
        }
        totalStaked -= _amount;

        user.amount = user.amount - _amount;
        user.rewardDebt =
            (user.amount * accTokensPerShare[0]) /
            PRECISION_FACTOR;
        user.rewardDebt1 =
            (user.amount * accTokensPerShare[1]) /
            PRECISION_FACTOR;
        emit Withdraw(msg.sender, _amount);

        if (rewardFee > 0) _updateRewardRate();
    }

    function claimReward() external payable nonReentrant {
        _transferPerformanceFee();
        _claimReward();

        UserInfo storage user = userInfo[msg.sender];
        user.rewardDebt =
            (user.amount * accTokensPerShare[0]) /
            PRECISION_FACTOR;
        user.rewardDebt1 =
            (user.amount * accTokensPerShare[1]) /
            PRECISION_FACTOR;
    }

    function _claimReward() internal {
        _claimLpFees();
        _updatePool();
        _updateRewardRate();

        UserInfo storage user = userInfo[msg.sender];
        if (user.amount == 0) return;

        uint256[2] memory pending;
        pending[0] =
            (user.amount * accTokensPerShare[0]) /
            PRECISION_FACTOR -
            user.rewardDebt;
        pending[1] =
            (user.amount * accTokensPerShare[1]) /
            PRECISION_FACTOR -
            user.rewardDebt1;
        if (pending[0] > 0 || pending[1] > 0) {
            require(
                availableRewardTokens(0) >= pending[0],
                "Insufficient reward0 tokens"
            );
            require(
                availableRewardTokens(1) >= pending[1],
                "Insufficient reward1 tokens"
            );
            paidRewards[0] = paidRewards[0] + pending[0];
            paidRewards[1] = paidRewards[1] + pending[1];

            pending[0] =
                (pending[0] * (PERCENT_PRECISION - rewardFee)) /
                PERCENT_PRECISION;
            pending[1] =
                (pending[1] * (PERCENT_PRECISION - rewardFee)) /
                PERCENT_PRECISION;
            totalEarned[0] = (totalEarned[0] > pending[0])
                ? totalEarned[0] - pending[0]
                : 0;
            totalEarned[1] = (totalEarned[1] > pending[1])
                ? totalEarned[1] - pending[1]
                : 0;

            rewardTokens[0].safeTransfer(address(msg.sender), pending[0]);
            rewardTokens[1].safeTransfer(address(msg.sender), pending[1]);
            emit Claim(msg.sender, pending);
        }
    }

    function _transferPerformanceFee() internal {
        require(
            msg.value >= performanceFee,
            "should pay small gas to compound or harvest"
        );

        payable(treasury).transfer(performanceFee);
        if (msg.value > performanceFee) {
            payable(msg.sender).transfer(msg.value - performanceFee);
        }
    }

    /**
     * @notice Withdraw staked tokens without caring about rewards
     * @dev Needs to be for emergency.
     */
    function emergencyWithdraw() external nonReentrant {
        UserInfo storage user = userInfo[msg.sender];
        if (user.amount == 0) return;

        uint256 amountToTransfer = user.amount;
        lpToken.safeTransfer(address(msg.sender), amountToTransfer);
        totalStaked -= amountToTransfer;

        user.amount = 0;
        user.rewardDebt = 0;
        user.rewardDebt1 = 0;
        emit EmergencyWithdraw(msg.sender, amountToTransfer);
    }

    /**
     * @notice Available amount of reward token
     */
    function availableRewardTokens(uint8 idx) public view returns (uint256) {
        return rewardTokens[idx].balanceOf(address(this));
    }

    function insufficientRewards(uint8 idx) public view returns (uint256) {
        uint256 adjustedShouldTotalPaid = shouldTotalPaid[idx];
        uint256 remainRewards = availableRewardTokens(idx) + paidRewards[idx];

        if (startBlock == 0) {
            adjustedShouldTotalPaid =
                adjustedShouldTotalPaid +
                rewardsPerBlock[idx] *
                duration *
                BLOCKS_PER_DAY;
        } else {
            uint256 remainBlocks = _getMultiplier(
                lastRewardBlock,
                bonusEndBlock
            );
            adjustedShouldTotalPaid =
                adjustedShouldTotalPaid +
                rewardsPerBlock[idx] *
                remainBlocks;
        }

        if (remainRewards >= adjustedShouldTotalPaid) return 0;

        return adjustedShouldTotalPaid - remainRewards;
    }

    /**
     * @notice View function to see pending reward on frontend.
     * @param _user: user address
     * @return Pending reward for a given user
     */
    function pendingRewards(
        address _user
    ) external view returns (uint256[2] memory) {
        UserInfo memory user = userInfo[_user];

        uint256[2] memory adjustedTokenPerShare = accTokensPerShare;
        if (
            block.number > lastRewardBlock &&
            totalStaked != 0 &&
            lastRewardBlock > 0
        ) {
            uint256 multiplier = _getMultiplier(lastRewardBlock, block.number);

            adjustedTokenPerShare[0] =
                accTokensPerShare[0] +
                ((multiplier * rewardsPerBlock[0] * PRECISION_FACTOR) /
                    totalStaked);
            adjustedTokenPerShare[1] =
                accTokensPerShare[1] +
                ((multiplier * rewardsPerBlock[0] * PRECISION_FACTOR) /
                    totalStaked);
        }

        uint256[2] memory pending;
        pending[0] =
            (user.amount * adjustedTokenPerShare[0]) /
            PRECISION_FACTOR -
            user.rewardDebt;
        pending[1] =
            (user.amount * adjustedTokenPerShare[1]) /
            PRECISION_FACTOR -
            user.rewardDebt1;
        return pending;
    }

    /**
     * Admin Methods
     */

    /**
     * @notice Deposit reward token
     * @dev Only call by owner. Needs to be for deposit of reward token when reflection token is same with reward token.
     */
    function depositRewards(
        uint8 idx,
        uint256 _amount
    ) external onlyAdmin nonReentrant {
        require(_amount > 0, "invalid amount");

        rewardTokens[idx].safeTransferFrom(msg.sender, address(this), _amount);
    }

    function increaseEmissionRate(
        uint8 idx,
        uint256 _amount
    ) external onlyOwner {
        require(_amount > 0, "invalid amount");
        require(startBlock > 0, "pool is not started");
        require(bonusEndBlock > block.number, "pool was already finished");

        _updatePool();

        rewardTokens[idx].safeTransferFrom(msg.sender, address(this), _amount);
        _updateRewardRate();
    }

    function _updateRewardRate() internal {
        if (bonusEndBlock <= block.number) return;

        uint256 remainBlocks = bonusEndBlock - block.number;
        bool bUpdated = false;
        uint256 remainRewards = availableRewardTokens(0) + paidRewards[0];
        if (remainRewards > shouldTotalPaid[0]) {
            remainRewards = remainRewards - shouldTotalPaid[0];
            rewardsPerBlock[0] = remainRewards / remainBlocks;
            bUpdated = true;
        }

        remainRewards = availableRewardTokens(1) + paidRewards[1];
        if (remainRewards > shouldTotalPaid[1]) {
            remainRewards = remainRewards - shouldTotalPaid[1];
            rewardsPerBlock[1] = remainRewards / remainBlocks;
            bUpdated = true;
        }

        if (bUpdated) emit NewRewardsPerBlock(rewardsPerBlock);
    }

    /**
     * @notice Withdraw reward token
     * @dev Only callable by owner. Needs to be for emergency.
     */
    function emergencyRewardWithdraw(
        uint8 idx,
        uint256 _amount
    ) external onlyOwner {
        require(block.number > bonusEndBlock, "Pool is running");
        require(
            availableRewardTokens(idx) >= _amount,
            "Insufficient reward tokens"
        );

        if (_amount == 0) _amount = availableRewardTokens(idx);
        rewardTokens[idx].safeTransfer(address(msg.sender), _amount);
    }

    /**
     * @notice It allows the admin to recover wrong tokens sent to the contract
     * @param _token: the address of the token to withdraw
     * @dev This function is only callable by admin.
     */
    function rescueTokens(address _token) external onlyOwner {
        require(
            _token != address(rewardTokens[0]) &&
                _token != address(rewardTokens[1]),
            "cannot recover reward tokens"
        );
        require(_token != address(lpToken), "token is using on pool");

        uint256 amount;
        if (_token == address(0x0)) {
            amount = address(this).balance;
            payable(address(msg.sender)).transfer(amount);
        } else {
            amount = IERC20(_token).balanceOf(address(this));
            if (amount > 0) {
                IERC20(_token).transfer(msg.sender, amount);
            }
        }

        emit AdminTokenRecovered(_token, amount);
    }

    function startReward() external onlyAdmin {
        require(startBlock == 0, "Pool was already started");
        require(
            insufficientRewards(0) == 0 && insufficientRewards(1) == 0,
            "All reward tokens have not been deposited"
        );

        startBlock = block.number + 100;
        bonusEndBlock = startBlock + duration * BLOCKS_PER_DAY;
        lastRewardBlock = startBlock;

        emit RewardsStart(startBlock, bonusEndBlock);
    }

    function stopReward() external onlyAdmin {
        _updatePool();

        uint256 remainRewards = availableRewardTokens(0) + paidRewards[0];
        if (remainRewards > shouldTotalPaid[0]) {
            remainRewards = remainRewards - shouldTotalPaid[0];
            rewardTokens[0].transfer(msg.sender, remainRewards);
        }

        remainRewards = availableRewardTokens(1) + paidRewards[1];
        if (remainRewards > shouldTotalPaid[1]) {
            remainRewards = remainRewards - shouldTotalPaid[1];
            rewardTokens[1].transfer(msg.sender, remainRewards);
        }

        bonusEndBlock = block.number;
        emit RewardsStop(bonusEndBlock);
    }

    function updateEndBlock(uint256 _endBlock) external onlyAdmin {
        require(startBlock > 0, "Pool is not started");
        require(bonusEndBlock > block.number, "Pool was already finished");
        require(
            _endBlock > block.number && _endBlock > startBlock,
            "Invalid end block"
        );
        bonusEndBlock = _endBlock;
        emit EndBlockChanged(_endBlock);
    }

    /**
     * @notice Update reward per block
     * @dev Only callable by owner.
     * @param _rewardsPerBlock: the reward per block
     */
    function updateEmissionRate(
        uint256[2] memory _rewardsPerBlock
    ) external onlyOwner {
        _updatePool();

        rewardsPerBlock = _rewardsPerBlock;
        emit NewRewardsPerBlock(_rewardsPerBlock);
    }

    function setServiceInfo(address _treasury, uint256 _fee) external {
        require(msg.sender == treasury, "setServiceInfo: FORBIDDEN");
        require(_treasury != address(0x0), "Invalid address");

        treasury = _treasury;
        performanceFee = _fee;

        emit ServiceInfoChanged(_treasury, _fee);
    }

    function setDuration(uint256 _duration) external onlyOwner {
        require(_duration >= 30, "lower limit reached");

        duration = _duration;
        emit DurationChanged(_duration);

        if (startBlock > 0) {
            bonusEndBlock = startBlock + duration * BLOCKS_PER_DAY;
            require(bonusEndBlock > block.number, "invalid duration");
            emit EndBlockChanged(bonusEndBlock);
        }
    }

    function setRewardFee(uint256 _fee) external onlyOwner {
        require(_fee < PERCENT_PRECISION, "setRewardFee: invalid percentage");

        rewardFee = _fee;
        emit SetRewardFee(_fee);
    }

    function setFeeManager(address _feeManager) external onlyOwner {
        feeManager = _feeManager;
    }

    function transferOperator(address _operator) external onlyAdmin {
        require(_operator != address(0x0), "invalid address");
        emit OperatorTransferred(operator, _operator);
        operator = _operator;
    }

    function setSettings(
        uint256 _depositFee,
        uint256 _withdrawFee,
        address _feeAddr
    ) external onlyOwner {
        require(
            _feeAddr != address(0x0) || _feeAddr != feeAddress,
            "Invalid address"
        );
        require(_depositFee <= MAX_FEE, "Invalid deposit fee");
        require(_withdrawFee <= MAX_FEE, "Invalid withdraw fee");

        depositFee = _depositFee;
        withdrawFee = _withdrawFee;

        feeAddress = _feeAddr;
        emit SetSettings(_depositFee, _withdrawFee, _feeAddr);
    }

    /**
     * @notice Update reward variables of the given pool to be up-to-date.
     */
    function _updatePool() internal {
        if (block.number <= lastRewardBlock || lastRewardBlock == 0) return;
        if (totalStaked == 0) {
            lastRewardBlock = block.number;
            return;
        }

        uint256 multiplier = _getMultiplier(lastRewardBlock, block.number);
        lastRewardBlock = block.number;

        uint256 _reward = multiplier * rewardsPerBlock[0];
        accTokensPerShare[0] += (_reward * PRECISION_FACTOR) / totalStaked;
        shouldTotalPaid[0] = shouldTotalPaid[0] + _reward;

        _reward = multiplier * rewardsPerBlock[1];
        accTokensPerShare[1] += (_reward * PRECISION_FACTOR) / totalStaked;
        shouldTotalPaid[1] = shouldTotalPaid[1] + _reward;
    }

    function _claimLpFees() internal {
        if (feeManager == address(0x0)) return;

        try
            IBrewlabsSwapFeeManager(feeManager).claim(address(lpToken))
        {} catch {}
    }

    /**
     * @notice Return reward multiplier over the given _from to _to block.
     * @param _from: block to start
     * @param _to: block to finish
     */
    function _getMultiplier(
        uint256 _from,
        uint256 _to
    ) internal view returns (uint256) {
        if (_to <= bonusEndBlock) {
            return _to - _from;
        } else if (_from >= bonusEndBlock) {
            return 0;
        } else {
            return bonusEndBlock - _from;
        }
    }

    /**
     * @notice Retrun reward per block for first reward token
     * @dev so it supports interface same as original farm
     */
    function rewardPerBlock() public view returns (uint256) {
        return rewardsPerBlock[0];
    }

    receive() external payable {}
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IBrewlabsSwapFeeManager {
    function claim(address pair) external;
}
