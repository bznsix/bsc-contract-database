//SPDX-License-Identifier:NOLICENSE
pragma solidity 0.8.18;

interface IBEP20 {
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
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

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
    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

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

/**
 * @dev Interface of the BEP20 Permit extension allowing approvals to be made via signatures, as defined in
 * https://eips.ethereum.org/EIPS/eip-2612[EIP-2612].
 *
 * Adds the {permit} method, which can be used to change an account's BEP20 allowance (see {IBEP20-allowance}) by
 * presenting a message signed by the account. By not relying on {IBEP20-approve}, the token holder account doesn't
 * need to send a transaction, and thus is not required to hold Ether at all.
 */
interface IBEP20Permit {
    /**
     * @dev Sets `value` as the allowance of `spender` over ``owner``'s tokens,
     * given ``owner``'s signed approval.
     *
     * IMPORTANT: The same issues {IBEP20-approve} has related to transaction
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
        require(
            address(this).balance >= amount,
            "Address: insufficient balance"
        );

        (bool success, ) = recipient.call{value: amount}("");
        require(
            success,
            "Address: unable to send value, recipient may have reverted"
        );
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
    function functionCall(address target, bytes memory data)
        internal
        returns (bytes memory)
    {
        return
            functionCallWithValue(
                target,
                data,
                0,
                "Address: low-level call failed"
            );
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
        return
            functionCallWithValue(
                target,
                data,
                value,
                "Address: low-level call with value failed"
            );
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
        require(
            address(this).balance >= value,
            "Address: insufficient balance for call"
        );
        (bool success, bytes memory returndata) = target.call{value: value}(
            data
        );
        return
            verifyCallResultFromTarget(
                target,
                success,
                returndata,
                errorMessage
            );
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data)
        internal
        view
        returns (bytes memory)
    {
        return
            functionStaticCall(
                target,
                data,
                "Address: low-level static call failed"
            );
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
        return
            verifyCallResultFromTarget(
                target,
                success,
                returndata,
                errorMessage
            );
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data)
        internal
        returns (bytes memory)
    {
        return
            functionDelegateCall(
                target,
                data,
                "Address: low-level delegate call failed"
            );
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
        return
            verifyCallResultFromTarget(
                target,
                success,
                returndata,
                errorMessage
            );
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

    function _revert(bytes memory returndata, string memory errorMessage)
        private
        pure
    {
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

/**
 * @title SafeBEP20
 * @dev Wrappers around BEP20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeBEP20 for IBEP20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeBEP20 {
    using Address for address;

    function safeTransfer(
        IBEP20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.transfer.selector, to, value)
        );
    }

    function safeTransferFrom(
        IBEP20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.transferFrom.selector, from, to, value)
        );
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IBEP20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(
        IBEP20 token,
        address spender,
        uint256 value
    ) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeBEP20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.approve.selector, spender, value)
        );
    }

    function safeIncreaseAllowance(
        IBEP20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(
                token.approve.selector,
                spender,
                newAllowance
            )
        );
    }

    function safeDecreaseAllowance(
        IBEP20 token,
        address spender,
        uint256 value
    ) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(
                oldAllowance >= value,
                "SafeBEP20: decreased allowance below zero"
            );
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(
                token,
                abi.encodeWithSelector(
                    token.approve.selector,
                    spender,
                    newAllowance
                )
            );
        }
    }

    function safePermit(
        IBEP20Permit token,
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
        require(
            nonceAfter == nonceBefore + 1,
            "SafeBEP20: permit did not succeed"
        );
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IBEP20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(
            data,
            "SafeBEP20: low-level call failed"
        );
        if (returndata.length > 0) {
            // Return data is optional
            require(
                abi.decode(returndata, (bool)),
                "SafeBEP20: BEP20 operation did not succeed"
            );
        }
    }
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

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

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

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

abstract contract Pausable is Context {
    bool private _paused;

    /**
     * @dev Emitted when the pause is triggered by `account`.
     */
    event Paused(address account);

    /**
     * @dev Emitted when the pause is lifted by `account`.
     */
    event Unpaused(address account);

    /**
     * @dev The operation failed because the contract is paused.
     */
    error EnforcedPause();

    /**
     * @dev The operation failed because the contract is not paused.
     */
    error ExpectedPause();

    /**
     * @dev Initializes the contract in unpaused state.
     */
    constructor() {
        _paused = false;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        _requireNotPaused();
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    modifier whenPaused() {
        _requirePaused();
        _;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns (bool) {
        return _paused;
    }

    /**
     * @dev Throws if the contract is paused.
     */
    function _requireNotPaused() internal view virtual {
        if (paused()) {
            revert EnforcedPause();
        }
    }

    /**
     * @dev Throws if the contract is not paused.
     */
    function _requirePaused() internal view virtual {
        if (!paused()) {
            revert ExpectedPause();
        }
    }

    /**
     * @dev Triggers stopped state.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    /**
     * @dev Returns to normal state.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
}

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
    uint256 private constant NOT_ENTERED = 1;
    uint256 private constant ENTERED = 2;

    uint256 private _status;

    /**
     * @dev Unauthorized reentrant call.
     */
    error ReentrancyGuardReentrantCall();

    constructor() {
        _status = NOT_ENTERED;
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
        // On the first call to nonReentrant, _status will be NOT_ENTERED
        if (_status == ENTERED) {
            revert ReentrancyGuardReentrantCall();
        }

        // Any calls to nonReentrant after this point will fail
        _status = ENTERED;
    }

    function _nonReentrantAfter() private {
        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = NOT_ENTERED;
    }

    /**
     * @dev Returns true if the reentrancy guard is currently set to "entered", which indicates there is a
     * `nonReentrant` function in the call stack.
     */
    function _reentrancyGuardEntered() internal view returns (bool) {
        return _status == ENTERED;
    }
}

contract StakeIt is Ownable, Pausable, ReentrancyGuard {
    using SafeBEP20 for IBEP20;
    using Address for address;

    enum Toggle {
        ACTIVE,
        INACTIVE
    }

    enum Pack {
        PACKA,
        PACKB,
        PACKC,
        PACKD,
        PACKE,
        PACKF
    }

    bytes32 public constant PACK_TYPE =
        keccak256(
            "buyLevel(Pack pack,address referrer,uint poolId,uint256 deadline,uint8 v,bytes32 r,bytes32 s)"
        );
    bytes32 public constant STAKE_TYPE =
        keccak256(
            "stake(Pack pack,uint256 poolId,uint256 packId,uint256 amount,uint256 deadline,uint8 v,bytes32 r,bytes32 s)"
        );
    bytes32 public constant AFFILIATE_TYPE =
        keccak256(
            "claimAffiliate(Pack pack,uint256 poolId,uint256 packId,uint256 level,uint256 amount,uint256 deadline,uint8 v,bytes32 r,bytes32 s)"
        );
    bytes32 public constant CLAIM_TYPE =
        keccak256(
            "claimCapital(Pack pack,uint256 poolId,uint256 packId,uint256 deadline,uint8 v,bytes32 r,bytes32 s)"
        );
    bytes32 public constant REWARD_TYPE =
        keccak256(
            "claimReward(Pack pack,uint256 poolId,uint256 userPackId,uint256 amount,uint256 deadline,uint8 v,bytes32 r,bytes32 s)"
        );
    bytes32 public constant SWAP_TYPE =
        keccak256(
            "swapBusdToStc(uint256 busdAmount,uint256 busdPrice,uint256 expiry,uint8 v,bytes32 r,bytes32 s"
        );
    bytes32 public immutable Owner_Hash;

    address public stc;
    address public busd;
    address public operator;
    address public treasury;
    uint256 public poolID;

    struct Packs {
        uint256 price;
        uint256 lifeSpan;
        Toggle isEnabled;
    }

    struct Pools {
        address token;
        uint256 totalAffClaimed;
        Toggle isEnabled;
        Toggle isAffRewardEnabled;
    }

    struct Levels {
        uint256 affiliates;
        uint256 commission;
        uint256 volume;
    }

    struct Users {
        bytes32 referrerHash;
        mapping(uint256 => mapping(Pack => uint256)) packId;
    }

    struct UserData {
        uint256 totalAffClaimed;
        mapping(uint256 => mapping(uint256 => UserPool)) pool;
        mapping(uint256 => mapping(uint256 => UserPack)) pack;
    }

    struct UserPool {
        uint256 lifeSpan;
    }

    struct UserPack {
        uint256 amount;
        uint256 rewardClaimed;
        uint256 timestamp;
    }

    mapping(uint256 => Packs) public packs;
    mapping(uint256 => Levels) public levels;
    mapping(uint256 => Pools) public pool;
    mapping(bytes32 => Users) private users;
    mapping(bytes32 => bool) public signed;
    mapping(uint256 => mapping(uint256 => uint256)) public poolPackTotalAmount;
    mapping(bytes32 => mapping(uint256 => UserData)) private userData;
    mapping(bytes32 => mapping(address => uint256)) public nonce;

    event BuyPack(
        bytes32 indexed referrerHash,
        bytes32 indexed referrelHash,
        Pack indexed pack,
        uint256 amount,
        uint256 userPackId,
        uint256 poolID,
        uint256 timestamp
    );

    event Staked(
        uint256 indexed pack,
        bytes32 indexed userHash,
        uint256 indexed poolID,
        uint256 userPackId,
        uint256 amount,
        uint256 timestamp
    );

    event ClaimedCapital(
        bytes32 indexed hash,
        Pack indexed pack,
        uint256 indexed poolID,
        uint256 userPackId,
        uint256 amount,
        uint256 timestamp
    );

    event ClaimedReward(
        bytes32 indexed userHash,
        Pack indexed pack,
        uint256 indexed poolID,
        uint256 userPackId,
        uint256 amount,
        uint256 timestamp
    );

    event ClaimedAffiliate(
        bytes32 indexed userHash,
        uint256 indexed poolId,
        uint256 indexed pack,
        uint256 level,
        uint256 amount,
        uint256 timestamp
    );

    event AddPool(
        uint256 indexed poolId,
        address indexed token,
        uint256 isAffRewardEnabled
    );

    event SwapBusdToStc(address addr, uint256 busdAmount, uint256 busdPrice);

    modifier ensure(uint256 deadline) {
        require(deadline >= block.timestamp, "ensure::deadline is expired");
        _;
    }

    modifier isValidAccount(address account) {
        _requireAddress(account);
        _;
    }

    modifier isValidHash(bytes32 _hash) {
        require(_hash != bytes32(0), "invalid hash");
        _;
    }

    constructor(
        address initOwner,
        address initBusd,
        address initStc,
        address initOperator,
        address _treasury
    )
        Ownable(initOwner)
        isValidAccount(initOperator)
        isValidAccount(_treasury)
    {
        require(!_treasury.isContract(), "EOA!");
        require(!initOperator.isContract(), "EOA!");
        stc = initStc;
        busd = initBusd;
        operator = initOperator;
        treasury = _treasury;
        Owner_Hash = sha256(abi.encodePacked(_msgSender(), address(this)));
        users[Owner_Hash].referrerHash = Owner_Hash;

        // initialize
        _initPack();
        _initLevels();
        _initPool(initBusd);
    }

    function addPool(address token, Toggle isAffRewardEnabled)
        external
        onlyOwner
    {
        _requireAddress(token);
        uint256 currPoolId = poolID++;
        pool[currPoolId].token = token;
        pool[currPoolId].isEnabled = Toggle.ACTIVE;
        pool[currPoolId].isAffRewardEnabled = isAffRewardEnabled;
        emit AddPool(
            currPoolId,
            token,
            // price,
            uint256(isAffRewardEnabled)
        );
    }

    function updatePool(
        uint256 poolId,
        uint8 switchFlag,
        uint256 valueToStore
    ) external onlyOwner {
        Pools storage pools = pool[poolId];
        require(poolId < poolID, "updatePool::invalid pool id");
        if (switchFlag == 0) {
            _requireAddress(address(uint160(valueToStore)));
            pools.token = address(uint160(valueToStore));
        } else if (switchFlag == 1) {
            require(
                valueToStore == uint256(Toggle.ACTIVE) ||
                    valueToStore == uint256(Toggle.INACTIVE),
                "updatePool::Invalid toggle"
            );
            pools.isAffRewardEnabled = Toggle(valueToStore);
        } else if (switchFlag == 2) {
            require(
                valueToStore == uint256(Toggle.ACTIVE) ||
                    valueToStore == uint256(Toggle.INACTIVE),
                "updatePool::Invalid toggle"
            );
            pools.isEnabled = Toggle(valueToStore);
        } else {
            revert("updatePool::switchFlag invalid");
        }
    }

    function updateTreasury(address _treasury)
        public
        isValidAccount(_treasury)
        onlyOwner
    {
        require(!_treasury.isContract(), "EOA!");
        treasury = _treasury;
    }

    function updatePack(
        Pack pack,
        uint8 switchFlag,
        uint256 valueToStore
    ) external onlyOwner {
        Packs storage packStg = packs[uint256(pack)];
        if (switchFlag == 0) {
            _requireValue(valueToStore);
            packStg.price = valueToStore;
        } else if (switchFlag == 1) {
            _requireValue(valueToStore);
            packStg.lifeSpan = valueToStore;
        } else if (switchFlag == 2) {
            require(
                valueToStore == uint256(Toggle.ACTIVE) ||
                    valueToStore == uint256(Toggle.INACTIVE),
                "updatePack::Invalid toggle"
            );
            packStg.isEnabled = Toggle(valueToStore);
        } else {
            revert("updatePack::switchFlag invalid");
        }
    }

    function updateLevel(
        uint256 levelId,
        uint8 switchFlag,
        uint256 valueToStore
    ) external onlyOwner {
        require(levelId < 12, "updateLevel::levelId exceeds limit");
        _requireValue(valueToStore);
        Levels storage level = levels[levelId];
        if (switchFlag == 0) {
            level.affiliates = valueToStore;
        } else if (switchFlag == 1) {
            level.commission = valueToStore;
        } else if (switchFlag == 2) {
            level.volume = valueToStore;
        } else {
            revert("updateLevel::switchFlag invalid");
        }
    }

    function updateStc(address newStc) external onlyOwner {
        _requireAddress(newStc);
        stc = newStc;
    }

    function updateOperator(address newOperator) external onlyOwner {
        require(!newOperator.isContract(), "EOA!");
        _requireAddress(newOperator);
        operator = newOperator;
    }

    function updateLifeSpan(Pack pack, uint256 duration) external onlyOwner {
        _requireValue(duration);
        packs[uint256(pack)].lifeSpan = duration;
    }

    function updatePackEnabled(Pack pack, Toggle isActive) external onlyOwner {
        packs[uint256(pack)].isEnabled = isActive;
    }

    function pause() external onlyOwner {
        _pause();
    }

    function unpause() external onlyOwner {
        _unpause();
    }

    function withdraw(
        address tokenAddress,
        address to,
        uint256 tokenAmount
    ) external onlyOwner {
        require(tokenAddress != address(0), "withdraw: Cannot be zero token");
        require(
            IBEP20(tokenAddress).balanceOf(address(this)) >= tokenAmount &&
                tokenAmount > 0,
            "withdraw: Invalid amount"
        );
        IBEP20(tokenAddress).safeTransfer(to, tokenAmount);
    }

    function withdrawBNB(address to, uint256 tokenAmount) external onlyOwner {
        require(to != address(0), "withdrawBNB: Invalid to");
        require(tokenAmount > 0, "withdrawBNB: Invalid Amount");
        Address.sendValue(payable(to), tokenAmount);
    }

    function buyLevel(
        Pack pack,
        bytes32 referrelHash,
        bytes32 referrerHash,
        uint256 poolId,
        uint256 amount,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public whenNotPaused nonReentrant isValidHash(referrelHash) isValidHash(referrerHash) ensure(deadline) {
        require(poolId < poolID, "buyLevel::invalid pool id");
        _requireValue(amount);
        require(pool[poolId].token != address(0), "buyLevel::pool not exist");
        require(
            pool[poolId].isEnabled == Toggle.ACTIVE,
            "buyLevel::pool is not active"
        );
        require(
            packs[uint256(pack)].isEnabled == Toggle.ACTIVE,
            "buyLevel::pack is not active"
        );
        require(
            users[referrelHash].referrerHash == bytes32(0),
            "buyLevel::user already reffered"
        );
        require(
            _validateBuySig(
                pack,
                referrelHash,
                referrerHash,
                poolId,
                amount,
                deadline,
                v,
                r,
                s
            ) == operator,
            "buyLevel::invalid signature"
        );

        IBEP20(pool[poolId].token).safeTransferFrom(
            _msgSender(),
            address(this),
            amount
        );

        uint256 packId = _storeUser(
            pack,
            poolId,
            referrelHash,
            referrerHash
        );

        emit BuyPack(
            referrerHash,
            referrelHash,
            pack,
            amount,
            packId,
            poolId,
            block.timestamp
        );
    }

    function buyPack(
        Pack pack,
        bytes32 referrelHash,
        uint256 poolId,
        uint256 amount,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public whenNotPaused nonReentrant isValidHash(referrelHash) ensure(deadline) {
        require(poolId < poolID, "buyPack::invalid pool id");
        _requireValue(amount);
        require(pool[poolId].token != address(0), "buyPack::pool not exist");
        require(
            pool[poolId].isEnabled == Toggle.ACTIVE,
            "buyPack::pool is not active"
        );
        require(
            packs[uint256(pack)].isEnabled == Toggle.ACTIVE,
            "buyPack::pack is not active"
        );
        require(
            users[referrelHash].referrerHash != bytes32(0) || _msgSender() == owner(),
            "buyPack::referrer address is zero"
        );
        bytes32 referrerHash = users[referrelHash].referrerHash;
        require(
            _validateBuySig(
                pack,
                referrelHash,
                referrerHash,
                poolId,
                amount,
                deadline,
                v,
                r,
                s
            ) == operator,
            "buyPack::invalid signature"
        );

        IBEP20(pool[poolId].token).safeTransferFrom(
            _msgSender(),
            address(this),
            amount
        );
        uint256 packId = _storeUser(
            pack,
            poolId,
            referrelHash,
            referrerHash
        );

        emit BuyPack(
            referrerHash,
            referrelHash,
            pack,
            amount,
            packId,
            poolId,
            block.timestamp
        );
    }

    function stake( 
        Pack pack,
        bytes32 userHash,
        uint256 poolId,
        uint256 userPackId,
        uint256 amount,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public whenNotPaused nonReentrant isValidHash(userHash) ensure(deadline) {
        _requireValue(amount);
        require(poolId < poolID, "stake::invalid pool id");
        UserData storage userDataStg = userData[userHash][poolId];
        require(
            userPackId < users[userHash].packId[poolId][pack],
            "stake::Invalid pack id"
        );
        require(
            userDataStg.pool[uint256(pack)][userPackId].lifeSpan > block.timestamp,
            "stake:: user not active in the packid"
        );
        require(
            _validateStakeSig(
                pack,
                poolId,
                userPackId,
                userHash,
                amount,
                deadline,
                v,
                r,
                s
            ) == operator,
            "stake::invalid signature"
        );

        IBEP20(stc).safeTransferFrom(_msgSender(), address(this), amount);

        UserPack storage userPackStg = userDataStg.pack[uint256(pack)][
            userPackId
        ];
        userPackStg.amount += amount;
        userPackStg.timestamp = block.timestamp;
        poolPackTotalAmount[uint256(pack)][poolId] += amount;

        emit Staked(
            uint256(pack),
            userHash,
            poolId,
            userPackId,
            amount,
            block.timestamp
        );
    }

    function claimCapital(
        Pack pack,
        bytes32 userHash,
        uint256 poolId,
        uint256 userPackId,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public whenNotPaused nonReentrant isValidHash(userHash) ensure(deadline) {
        require(poolId < poolID, "claimCapital::invalid pool id");
        require(
            userPackId < users[userHash].packId[poolId][pack],
            "claimCapital::packId exceeds user pack limit"
        );
        UserPack storage userPackStg = userData[userHash][poolId].pack[uint256(pack)][
            userPackId
        ];
        uint256 amount = userPackStg.amount;
        require(amount > 0, "claimCapital::staked amount is zero");
        require(
            IBEP20(stc).balanceOf(address(this)) >= amount,
            "claimCapital::insufficient balance"
        );
        require(
            _validateClaimSig(
                userHash,
                pack,
                poolId,
                userPackId,
                deadline,
                v,
                r,
                s
            ) == operator,
            "stake::invalid signature"
        );

        userPackStg.amount = 0;
        userPackStg.timestamp = 0;
        poolPackTotalAmount[uint256(pack)][poolId] -= amount;
        IBEP20(stc).safeTransfer(_msgSender(), amount);

        emit ClaimedCapital(
            userHash,
            pack,
            poolId,
            userPackId,
            amount,
            block.timestamp
        );
    }

    function claimReward(
        Pack pack,
        bytes32 userHash,
        uint256 poolId,
        uint256 userPackId,
        uint256 amount,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public whenNotPaused nonReentrant isValidHash(userHash) ensure(deadline) {
        require(poolId < poolID, "claimReward::invalid pool id");
        require(
            userPackId < users[userHash].packId[poolId][pack],
            "claimReward::packId exceeds user pack limit"
        );
        _requireValue(amount);
        UserPack storage userPackStg = userData[userHash][poolId].pack[uint256(pack)][
            userPackId
        ];
        require(userPackStg.amount != 0, "claimReward::amount is zero");
        require(
            IBEP20(stc).balanceOf(address(this)) >= amount,
            "claimReward::insufficient balance"
        );
        require(
            _validateRewardSig(
                userHash,
                pack,
                poolId,
                userPackId,
                amount,
                deadline,
                v,
                r,
                s
            ) == operator,
            "claimReward::invalid signature"
        );

        IBEP20(stc).safeTransfer(_msgSender(), amount);
        userPackStg.rewardClaimed += amount;

        emit ClaimedReward(
            userHash,
            pack,
            poolId,
            userPackId,
            amount,
            block.timestamp
        );
    }

    function swapBusdToStc(
        uint256 busdAmount,
        uint256 busdPrice,
        uint256 expiry,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public whenNotPaused ensure(expiry) {
        require(busdAmount > 0 && busdPrice > 0, "0 busd");
        require(
            validateSwapHash(
                msg.sender,
                busdAmount,
                busdPrice,
                expiry,
                v,
                r,
                s
            ),
            "Invalid sig"
        );
        uint256 stcAmount = (busdAmount * busdPrice) / 1e18;
        require(stcAmount <= IBEP20(stc).balanceOf(address(this)), "insufficient balance");

        IBEP20(busd).safeTransferFrom(msg.sender, treasury, busdAmount);
        IBEP20(stc).safeTransfer(msg.sender, stcAmount);
        emit SwapBusdToStc(msg.sender, busdAmount, busdPrice);
    }

    function validateSwapHash(
        address to,
        uint256 busdAmount,
        uint256 busdPrice,
        uint256 expiry,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal returns (bool result) {
        bytes32 hash = prepareSwapHash(to, busdAmount, busdPrice, expiry);
        require(!signed[hash], "validateSwapHash::hash already exist");
        nonce[SWAP_TYPE][to]++;
        signed[hash] = true;
        result = ecrecover(toEthSignedMessageHash(hash), v, r, s) == operator;
    }

    function prepareSwapHash(
        address to,
        uint256 busdAmount,
        uint256 busdPrice,
        uint256 blockExpiry
    ) public view returns (bytes32) {
        return
            keccak256(
                abi.encodePacked(
                    SWAP_TYPE,
                    nonce[SWAP_TYPE][to],
                    to,
                    busdAmount,
                    busdPrice,
                    blockExpiry
                )
            );
    }

    function claimAffiliate(
        Pack pack,
        bytes32 userHash,
        uint256 poolId,
        uint256 level,
        uint256 amount,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public whenNotPaused nonReentrant ensure(deadline) isValidHash(userHash) {
        require(poolId < poolID, "claimAffiliate::invalid pool id");
        require(pool[poolId].isAffRewardEnabled == Toggle.ACTIVE);
        require(level < 12, "claimAffiliate::levelId exceeds limit");
        _requireValue(amount);
        // require(
        //     users[userHash].referrerHash != bytes32(0),
        //     "claimAffiliate::user not reffered"
        // );
        IBEP20 token = IBEP20(pool[poolId].token);
        require(
            token.balanceOf(address(this)) >= amount,
            "claimAffiliate::insufficient balance"
        );
        require(
            _validateAffiliateSig(
                pack,
                poolId,
                userHash,
                level,
                amount,
                deadline,
                v,
                r,
                s
            ) == operator,
            "claimAffiliate::invalid signature"
        );

        token.safeTransfer(_msgSender(), amount);
        userData[userHash][poolId].totalAffClaimed += amount;
        pool[poolId].totalAffClaimed += amount;

        emit ClaimedAffiliate(
            userHash,
            poolId,
            uint256(pack),
            level,
            amount,
            block.timestamp
        );
    }

    function _initPool(address _busd) private {
        uint256 currPoolId = poolID++;
        pool[currPoolId].token = _busd;
        pool[currPoolId].isEnabled = Toggle.ACTIVE;
        pool[currPoolId].isAffRewardEnabled = Toggle.ACTIVE;
    }

    function _initPack() private {
        packs[uint256(Pack.PACKA)] = Packs(25 ether, 300, Toggle.ACTIVE);
        packs[uint256(Pack.PACKB)] = Packs(100 ether, 300, Toggle.ACTIVE);
        packs[uint256(Pack.PACKC)] = Packs(500 ether, 300, Toggle.ACTIVE);
        packs[uint256(Pack.PACKD)] = Packs(2500 ether, 300, Toggle.ACTIVE);
        packs[uint256(Pack.PACKE)] = Packs(10000 ether, 300, Toggle.ACTIVE);
        packs[uint256(Pack.PACKF)] = Packs(25000 ether, 300, Toggle.ACTIVE);
    }

    function _initLevels() private {
        levels[0] = Levels(1, 200, 0);
        levels[1] = Levels(4, 100, 100);
        levels[2] = Levels(6, 50, 100);
        levels[3] = Levels(8, 40, 100);
        levels[4] = Levels(10, 40, 100);
        levels[5] = Levels(12, 40, 100);
        levels[6] = Levels(14, 40, 100);
        levels[7] = Levels(16, 40, 100);
        levels[8] = Levels(18, 25, 100);
        levels[9] = Levels(20, 25, 100);
        levels[10] = Levels(22, 25, 100);
        levels[11] = Levels(24, 75, 100);
    }

    function _storeUser(
        Pack pack,
        uint256 poolId,
        bytes32 _referrelHash,
        bytes32 _referrerHash
    ) private returns (uint256 userPackId) {
        Users storage userStg = users[_referrelHash];
        userPackId = userStg.packId[poolId][pack]++;
        UserPool storage userPoolStg = userData[_referrelHash][poolId].pool[uint256(pack)][
            userPackId
        ];
        if (userStg.referrerHash == bytes32(0)) {
            userStg.referrerHash = _referrerHash;
        }
        userPoolStg.lifeSpan = block.timestamp + packs[uint256(pack)].lifeSpan;
    }

    function _validateBuySig(
        Pack pack,
        bytes32 _referrelHash,
        bytes32 _referrerHash,
        uint256 poolId,
        uint256 amount,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    )
        private
        returns (address signer)
    {
        bytes32[2] memory hashArray;
        hashArray[0] = _referrelHash;
        hashArray[1] = _referrerHash;

        bytes32 hash = keccak256(
            abi.encodePacked(
                PACK_TYPE,
                nonce[PACK_TYPE][_msgSender()],
                _msgSender(),
                uint256(pack),
                poolId,
                amount,
                hashArray[0],
                hashArray[1],
                deadline
            )
        );

        nonce[PACK_TYPE][_msgSender()]++;

        return _validateSignature(hash, v, r, s);
    }

    function _validateStakeSig(
        Pack pack,
        uint256 poolId,
        uint256 packId,
        bytes32 userHash,
        uint256 amount,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) private returns (address signer) {
        bytes32 hash = keccak256(
            abi.encodePacked(
                STAKE_TYPE,
                nonce[STAKE_TYPE][_msgSender()],
                uint256(pack),
                poolId,
                packId,
                userHash,
                amount,
                deadline
            )
        );

        nonce[STAKE_TYPE][_msgSender()]++;

        return _validateSignature(hash, v, r, s);
    }

    function _validateAffiliateSig(
        Pack pack,
        uint256 poolId,
        bytes32 userHash,
        uint256 level,
        uint256 amount,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) private returns (address signer) {
        bytes32 hash = keccak256(
            abi.encodePacked(
                AFFILIATE_TYPE,
                nonce[AFFILIATE_TYPE][_msgSender()],
                uint256(pack),
                poolId,
                userHash,
                level,
                amount,
                deadline
            )
        );

        nonce[AFFILIATE_TYPE][_msgSender()]++;

        return _validateSignature(hash, v, r, s);
    }

    function _validateClaimSig(
        bytes32 userHash,
        Pack pack,
        uint256 poolId,
        uint256 packId,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) private returns (address signer) {
        bytes32 hash = keccak256(
            abi.encodePacked(
                CLAIM_TYPE,
                nonce[CLAIM_TYPE][_msgSender()],
                _msgSender(),
                userHash,
                uint256(pack),
                poolId,
                packId,
                deadline
            )
        );

        nonce[CLAIM_TYPE][_msgSender()]++;

        return _validateSignature(hash, v, r, s);
    }

    function _validateRewardSig(    
        bytes32 userHash,
        Pack pack,
        uint256 poolId,
        uint256 packId,
        uint256 amount,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) private returns (address signer) {
        bytes32 hash = keccak256(
            abi.encodePacked(
                REWARD_TYPE,
                nonce[REWARD_TYPE][_msgSender()],
                _msgSender(),
                userHash,
                uint256(pack),
                poolId,
                packId,
                amount,
                deadline
            )
        );

        nonce[REWARD_TYPE][_msgSender()]++;

        return _validateSignature(hash, v, r, s);
    }

    function _validateSignature(
        bytes32 hash,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) private returns (address signer) {
        bytes32 digest = toEthSignedMessageHash(hash);
        require(!signed[digest], "validateSignature::hash already exist");
        signed[digest] = true;
        signer = ecrecover(digest, v, r, s);
    }

    function getPoolStatus(
        bytes32 userHash,
        uint256 poolId,
        Pack pack,
        uint256 userPackId
    ) public view returns (Toggle) {
        UserPool storage userPoolStg = userData[userHash][poolId].pool[uint256(pack)][
            userPackId
        ];
        return
            userPoolStg.lifeSpan > block.timestamp
                ? Toggle.ACTIVE
                : Toggle.INACTIVE;
    }
    
    function poolDetails(uint256 poolId)
        public
        view
        returns (
            address token,
            uint256 totalAffClaimed,
            Toggle isEnabled,
            Toggle isAffRewardEnabled
        )
    {
        token = pool[poolId].token;
        totalAffClaimed = pool[poolId].totalAffClaimed;
        isEnabled = pool[poolId].isEnabled;
        isAffRewardEnabled = pool[poolId].isAffRewardEnabled;
    }

    function packDetails(uint256 poolId, uint256 pack)
        public
        view
        returns (
            address token,
            uint256 price,
            uint256 lifeSpan,
            uint256 totalPackAmount
        )
    {
        token = pool[poolId].token;
        price = packs[pack].price;
        lifeSpan = packs[pack].lifeSpan;
        totalPackAmount = poolPackTotalAmount[uint256(pack)][poolId];
    }

    function userDetails(bytes32 userHash)
        public
        view
        returns (bytes32 reffererHash)
    {
        reffererHash = users[userHash].referrerHash;
    }

    function userCurrentPackId(
        bytes32 userHash,
        uint256 poolId,
        Pack pack
    ) public view returns (uint256 currPackId) {
        return users[userHash].packId[poolId][pack];
    }

    function userInfo(
        bytes32 userHash,
        uint256 poolId,
        Pack pack,
        uint256 userPackId
    ) public view returns (UserPool memory userPool, UserPack memory userPack) {
        userPool = userData[userHash][poolId].pool[uint256(pack)][userPackId];
        userPack = userData[userHash][poolId].pack[uint256(pack)][userPackId];
    }

    function userPoolInfo(bytes32 userHash, uint256 poolId)
        public
        view
        returns (address token, uint256 totalAffClaimed)
    {
        token = pool[poolId].token;
        totalAffClaimed = userData[userHash][poolId].totalAffClaimed;
    }

    function userStakeInfo(
        bytes32 userHash,
        uint256 poolId,
        Pack pack,
        uint256 userPackId
    )
        public
        view
        returns (
            uint256 amount,
            uint256 rewardClaimed,
            uint256 stakedTime,
            uint256 lifeSpan
        )
    {
        UserData storage userDataStg = userData[userHash][poolId];
        UserPack storage userPackStg = userDataStg.pack[uint256(pack)][
            userPackId
        ];
        amount = userPackStg.amount;
        stakedTime = userPackStg.timestamp;
        lifeSpan = userDataStg.pool[uint256(pack)][userPackId].lifeSpan;
        rewardClaimed = userPackStg.rewardClaimed;
    }

    function _requireAddress(address account) private pure {
        require(account != address(0), "_requireAddress::account is zero");
    }

    function _requireValue(uint256 value) private pure {
        require(value != 0, "_requireValue::value is zero");
    }

    function toEthSignedMessageHash(bytes32 messageHash)
        private
        pure
        returns (bytes32 digest)
    {
        assembly {
            mstore(0x00, "\x19Ethereum Signed Message:\n32") // 32 is the bytes-length of messageHash
            mstore(0x1c, messageHash) // 0x1c (28) is the length of the prefix
            digest := keccak256(0x00, 0x3c) // 0x3c is the length of the prefix (0x1c) + messageHash (0x20)
        }
    }
}