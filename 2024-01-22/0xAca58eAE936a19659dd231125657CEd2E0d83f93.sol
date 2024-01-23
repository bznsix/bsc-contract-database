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


// OpenZeppelin Contracts (last updated v4.9.0) (token/ERC20/utils/SafeERC20.sol)

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

// File: acgPoolLeadClaim.sol


pragma solidity =0.8.17;


// WBNB Price in (USDT)
interface IPriceFeed {
    function latestAnswer() external view returns (int256);
}

// ACG Pair
interface IACGPair {
    function getReserves()
        external
        view
        returns (
            uint112 _reserve0,
            uint112 _reserve1,
            uint32 _blockTimestampLast
        );
}

// ACG Token
interface IACGToken {
    function balanceOf(address account) external view returns (uint256);
}

// @ACG - Pools And Leaderboards
contract ClaimablePools {
    // Import the SafeERC20 library for safe ERC20 token operations.
    using SafeERC20 for IERC20;

    // Address of the contract owner.
    address private _owner;

    // Address of the sub-owner of the contract.
    address private _subOwner;

    // Addresses of external contracts used in this contract.
    address private _wbnbPriceFeedAddress;
    address private _acgPairAddress;
    address private _acgTokenAddress;

    // Interface instances for interacting with external contracts.
    IPriceFeed private _wbnbPriceFeed;
    IACGPair private _acgPair;
    IACGToken private _acgToken;

    // Address of the ERC20 token being claimed.
    address private _tokenAddress;

    // The number to multiply the player ACG Balance in USDT to e.g: (playerAcgBalanceInUsdt * number)
    uint256 private _multiplierValue;

    // Mapping of user addresses to their claimable token balances.
    mapping(address => uint256) private _userBalances;

    // Mapping of user addresses to their claimed token balances.
    mapping(address => uint256) private _claimedUserBalances;

    // Array to keep track of indices of all addresses in the userBalances mapping.
    address[] private _addressIndices;

    // Mapping to track the lock status of each user's balance.
    mapping(address => bool) private _userLocks;

    // Flag to indicate if claiming is enabled or not.
    bool private _isClaimEnabled;

    // Modifier to allow only the contract owner (admin) to access the function.
    modifier onlyOwner() {
        require(msg.sender == _owner, "caller is not the Owner");
        _;
    }

    // Modifier to allow only the contract owner or sub-owner to access the function.
    modifier onlyOwnerOrSub() {
        require(
            msg.sender == _owner || msg.sender == _subOwner,
            "caller is not the Owner or subOwner"
        );
        _;
    }

    // Modifier to check if claiming is currently enabled.
    modifier checkIsClaimEnabled() {
        require(_isClaimEnabled == true, "Claim is not running now");
        _;
    }

    // Modifier to check if the contract holds enough tokens to fulfill a user's request.
    modifier hasSufficientContractTokensForUser() {
        require(
            IERC20(_tokenAddress).balanceOf(address(this)) >=
                _userBalances[msg.sender],
            "Contract does not have enough tokens"
        );
        _;
    }

    // Modifier to check if the contract holds tokens in an amount greater than or equal to the requested amount.
    modifier hasSufficientContractTokens(uint256 _amount) {
        require(
            IERC20(_tokenAddress).balanceOf(address(this)) >= _amount,
            "Contract does not have enough tokens"
        );
        _;
    }

    // Modifier to check if a user's balance is locked.
    modifier isUserBalanceLocked() {
        require(!_userLocks[msg.sender], "Your balance is locked");
        _;
    }

    // Modifier to check a user's balance and ensure it meets the required balance.
    modifier checkBalanceAndRequiredB() {
        // Check that the user has a balance greater than 0
        require(
            _userBalances[msg.sender] > 0,
            "Cannot claim tokens with a balance of 0"
        );
        _;
    }

    // Event emitted when a user claims all their rewards.
    event ClaimedAllRewards(
        uint256 userAcgHoldingsInUsdt, // The user's ACG holdings in USDT equivalent
        uint256 claimedAmount // The amount of rewards claimed
    );

    // Event emitted when a user claims specific amount of rewards.
    event ClaimedAmountOfRewards(
        uint256 userAcgHoldingsInUsdt, // The user's ACG holdings in USDT equivalent
        uint256 claimedAmount // The amount of rewards claimed
    );

    // Event to log the setting of claim amounts for multiple users.
    event SetClaimAmounts(address[] users, uint256[] amounts);

    // Constructor to initialize the contract with the ERC20 token address, owner, and sub-owner.
    constructor(
        address tokenAddress,
        address wbnbPriceFeedAddress,
        address acgPairAddress,
        address acgTokenAddress,
        uint256 multiplierValue
    ) {
        // Set the contract owner as the sender of the constructor transaction.
        _owner = msg.sender;

        // Enable claiming by default.
        _isClaimEnabled = true;

        // Set the address of the ERC20 token being claimed.
        _tokenAddress = tokenAddress;

        // Set the multiplier value
        _multiplierValue = multiplierValue;

        // Set the external contract addresses
        _wbnbPriceFeedAddress = wbnbPriceFeedAddress;
        _acgPairAddress = acgPairAddress;
        _acgTokenAddress = acgTokenAddress;

        // Initialize interface instances for external contracts.
        _wbnbPriceFeed = IPriceFeed(wbnbPriceFeedAddress);
        _acgPair = IACGPair(acgPairAddress);
        _acgToken = IACGToken(acgTokenAddress);
    }

    // Fallback function to receive ETH
    receive() external payable {}

    // Get the address of the WBNB price feed contract.
    function getWbnbPriceFeedAddress() public view returns (address) {
        return _wbnbPriceFeedAddress;
    }

    // Get the address of the ACG pair contract.
    function getAcgPairAddress() public view returns (address) {
        return _acgPairAddress;
    }

    // Get the address of the ACG token contract.
    function getAcgTokenAddress() public view returns (address) {
        return _acgTokenAddress;
    }

    // Get the address of rewards token.
    function getRewardsTokenAddress() public view returns (address) {
        return _tokenAddress;
    }

    // Get the multiplier value.
    function getMultiplierValue() public view returns (uint256) {
        return _multiplierValue;
    }

    // Check a user's balance.
    function checkBalance(address user) public view returns (uint256) {
        // Return the user's balance.
        return _userBalances[user];
    }

    // Check a user's claimed balance.
    function checkClaimedBalance(address user) public view returns (uint256) {
        // Return the user's claimed balance.
        return _claimedUserBalances[user];
    }

    // Get the address of the contract owner.
    function getOwner() public view returns (address) {
        // Return the owner's address.
        return _owner;
    }

    // Get the address of the sub-owner.
    function getSubOwner() public view returns (address) {
        // Return the sub-owner's address.
        return _subOwner;
    }

    // Get the contract's BNB balance.
    function getBNBBalance() public view returns (uint256) {
        return address(this).balance;
    }

    // Get the contract's ERC20 token balance.
    function getErc20TokenBalance() public view returns (uint256) {
        return IERC20(_tokenAddress).balanceOf(address(this));
    }

    // Set the multiplier value
    function setMultiplierValue(uint256 _newValue) external onlyOwnerOrSub {
        require(
            _newValue != _multiplierValue,
            "ACG: Already set to the same value."
        );
        require(
            _newValue >= 0 && _newValue < 100,
            "ACG: Please choose a value between 0 and 100."
        );

        _multiplierValue = _newValue;
    }

    // Set a new ERC20 token address for claiming.
    function setERC20ClaimableToken(address _newToken) external onlyOwnerOrSub {
        require(
            _newToken != address(0),
            "New token address cannot be address 0"
        );
        require(
            _newToken != _tokenAddress,
            "New token address cannot be the same as the old token address"
        );

        _tokenAddress = _newToken;
    }

    // Set the address of the WBNB price feed contract.
    function setWbnbPriceFeedAddress(address _newAddress)
        external
        onlyOwnerOrSub
    {
        require(
            _newAddress != address(0),
            "New token address cannot be address 0"
        );
        require(
            _newAddress != _tokenAddress,
            "New address cannot be the same as the old wbnb feed address"
        );

        _wbnbPriceFeedAddress = _newAddress;
        // Update the interface instance
        _wbnbPriceFeed = IPriceFeed(_newAddress);
    }

    // Set the address of the ACG pair contract.
    function setAcgPairAddress(address _newAddress) external onlyOwnerOrSub {
        require(
            _newAddress != address(0),
            "New token address cannot be address 0"
        );
        require(
            _newAddress != _tokenAddress,
            "New address cannot be the same as the old acg pair address"
        );

        _acgPairAddress = _newAddress;
        // Update the interface instance
        _acgPair = IACGPair(_newAddress);
    }

    // Set the address of the ACG token contract.
    function setAcgTokenAddress(address _newAddress) external onlyOwnerOrSub {
        require(
            _newAddress != address(0),
            "New token address cannot be address 0"
        );
        require(
            _newAddress != _tokenAddress,
            "New address cannot be the same as the old acg token address"
        );

        _acgTokenAddress = _newAddress;
        // Update the interface instance
        _acgToken = IACGToken(_newAddress);
    }

    // Transfer the contract's BNB balance to a specific wallet.
    function recoverBNBToWallet(address _to, uint256 _amount)
        external
        onlyOwnerOrSub
    {
        require(_to != address(0), "Transfer to the zero address");
        uint256 balance = address(this).balance;
        require(
            balance >= _amount,
            "Cannot recover more than the available balance"
        );
        payable(_to).transfer(_amount);
    }

    // Transfer the contract's specific ERC20 token balance to a specific wallet.
    function recoverERC20TokensToWallet(
        address _token,
        address _to,
        uint256 _amount
    ) external onlyOwnerOrSub {
        require(_to != address(0), "Transfer to the zero address");
        uint256 balance = IERC20(_token).balanceOf(address(this));
        require(
            balance >= _amount,
            "Cannot recover more than available balance"
        );
        IERC20(_token).transfer(_to, _amount);
    }

    // Transfer ownership of the contract to a new owner.
    function transferOwner(address newOwner) external onlyOwner {
        // Set the new owner of the contract.
        _owner = newOwner;
    }

    // Add a new sub-owner to the contract.
    function addSubOwner(address newSubOwner) external onlyOwner {
        require(
            newSubOwner != _owner,
            "Sub-owner address cannot be the same as the owner's address"
        );
        _subOwner = newSubOwner;
    }

    // Remove the sub-owner by setting the address to address(0).
    function removeSubOwner() external onlyOwner {
        _subOwner = address(0);
    }

    // Toggle the claim status to enable or disable claiming.
    function setClaimStatus(bool _enabled) external onlyOwnerOrSub {
        _isClaimEnabled = _enabled;
    }

    // Set a user's balance status as locked or unlocked.
    function setUserStatus(address _user, bool _status)
        external
        onlyOwnerOrSub
    {
        _userLocks[_user] = _status;
    }

    // set the claim amounts for multiple users in a single transaction
    function setClaimAmount(address[] memory users, uint256[] memory amounts)
        external
        onlyOwnerOrSub
    {
        // check that the number of users and amounts match
        require(
            users.length == amounts.length,
            "Incorrect number of users and amounts"
        );
        // set the claim amount for each user
        for (uint256 i = 0; i < users.length; i++) {
            // add the specified amount to the user's existing claim amount
            _userBalances[users[i]] += amounts[i];
            // add the address to the array of indices
            _addressIndices.push(users[i]);
        }

        // Emit an event to log the action
        emit SetClaimAmounts(users, amounts);
    }

    // Internal function to calculate the ACG token price in USDT.
    function getAcgPriceInUsdtInternal() internal view returns (uint256) {
        // Get the BNB price in USDT from the external contract
        int256 getBnbPriceInUsdt = _wbnbPriceFeed.latestAnswer();
        uint256 bnbPriceInUsdt = uint256(getBnbPriceInUsdt) * 10**10;

        // Get the ACG reserves from the external contract
        (uint112 _reserve0, uint112 _reserve1, ) = _acgPair.getReserves();
        uint256 _tokenReserve = uint256(_reserve0);
        uint256 _wbnbReserve = uint256(_reserve1) * 10**18; // Adjust for decimals

        // Calculate ACG price in WBNB
        uint256 acgPriceInWbnb = _wbnbReserve / _tokenReserve;

        // Calculate ACG price in USDT
        uint256 acgPriceInUsdt = (bnbPriceInUsdt * acgPriceInWbnb) / 10**18; // Adjust for decimals

        return acgPriceInUsdt;
    }

    // Internal function to calculate the user's ACG token holdings in USDT.
    function claculateUserAcgHoldingsInUsdt(address player) internal view returns (uint256) {
        // Calculate ACG price in USDT
        uint256 acgPriceInUsdt = getAcgPriceInUsdtInternal();

        // Get the user's ACG balance from the external contract
        uint256 userAcgBalance = _acgToken.balanceOf(player);

        // Calculate the user's ACG holdings in USDT
        uint256 userAcgHoldingsInUsdt = (userAcgBalance * acgPriceInUsdt) /
            10**18; // Adjust for decimals

        return userAcgHoldingsInUsdt;
    }

    // Claim all the tokens won by a specific user. This function calculates the user's ACG token holdings in USDT,
    // verifies that the user's ACG holdings meet the required balance, transfers the tokens, updates balances, and emits an event.
    function claim()
        external
        checkIsClaimEnabled
        isUserBalanceLocked
        hasSufficientContractTokensForUser
        checkBalanceAndRequiredB
    {
        // Lock the user's balance to prevent reentrancy attacks
        _userLocks[msg.sender] = true;

        // Get the balance of the caller inside the contract
        uint256 playerBalance = _userBalances[msg.sender];

        // Calculate the user's ACG holdings in USDT
        uint256 userAcgHoldingsInUsdt = claculateUserAcgHoldingsInUsdt(msg.sender);

        // Check if the user's ACG holdings in USDT are greater than or equal to the specified amount
        require(
            userAcgHoldingsInUsdt >= (playerBalance * _multiplierValue),
            "Insufficient ACG holdings"
        );

        // Get the ERC20 token contract
        IERC20 token = IERC20(_tokenAddress);

        // Transfer the balance of the caller inside the contract to the caller
        token.safeTransfer(msg.sender, playerBalance);

        // Update the user's balance
        _userBalances[msg.sender] = 0;

        // Update the user's claimed balance
        _claimedUserBalances[msg.sender] += playerBalance;

        // Unlock the user's balance
        _userLocks[msg.sender] = false;

        // Emit an event to indicate the successful claim
        emit ClaimedAllRewards(userAcgHoldingsInUsdt, playerBalance);
    }

    // claim a specific amount of tokens by the caller of this function
    function claimAmount(uint256 amount)
        external
        checkIsClaimEnabled
        isUserBalanceLocked
        checkBalanceAndRequiredB
        hasSufficientContractTokens(amount)
    {
        // Check that the specified amount is valid (greater than 0)
        require(amount > 0, "Invalid amount");

        // Get the balance of the caller inside the contract
        uint256 playerBalance = _userBalances[msg.sender];

        // Check that the player is greater or equal to the amount requested
        require(playerBalance >= amount, "Not enough rewards");

        // Calculate the user's ACG holdings in USDT
        uint256 userAcgHoldingsInUsdt = claculateUserAcgHoldingsInUsdt(msg.sender);

        // Check if the user's ACG holdings in USDT are greater than or equal to the specified amount
        require(
            userAcgHoldingsInUsdt >= (playerBalance * _multiplierValue),
            "Insufficient ACG holdings"
        );

        // Lock the user's balance to prevent reentrancy attacks
        _userLocks[msg.sender] = true;

        // get the ERC20 token contract
        IERC20 token = IERC20(_tokenAddress);

        // Transfer the specified amount of tokens to the user
        token.safeTransfer(msg.sender, amount);
        // Update the user's balance
        _userBalances[msg.sender] -= amount;
        // Update the user's claimed balance
        _claimedUserBalances[msg.sender] += amount;
        // Unlock the user's balance
        _userLocks[msg.sender] = false;

        emit ClaimedAmountOfRewards(userAcgHoldingsInUsdt, amount);
    }

    // Admin function to claim all remaining tokens held by the contract. This function disables claiming temporarily,
    // transfers the remaining tokens to the owner or sub-owner, and clears user balances and locks.
    // It then re-enables claiming.
    function adminClaim() external onlyOwnerOrSub returns (bool) {
        _isClaimEnabled = false;

        // Get the ERC20 token contract
        IERC20 token = IERC20(_tokenAddress);

        // Get the contract balance
        uint256 contractTokenBalance = IERC20(_tokenAddress).balanceOf(
            address(this)
        );

        // Determine the recipient address (owner or sub-owner)
        address recipient = msg.sender == _subOwner ? _subOwner : _owner;

        // Transfer the remaining tokens to the recipient
        token.safeTransfer(recipient, contractTokenBalance);

        // Clear user balances and locks
        for (uint256 i = 0; i < _addressIndices.length; i++) {
            delete _userBalances[_addressIndices[i]];
            delete _userLocks[_addressIndices[i]];
        }
        delete _addressIndices;

        // Re-enable claiming
        _isClaimEnabled = true;

        return true;
    }

    // Public function to get the ACG price in USDT. It retrieves the ACG price by calling the internal function.
    function getAcgPriceInUSDT() external view returns (uint256) {
        return getAcgPriceInUsdtInternal();
    }

        // Public function to get the platyer ACG holdings in USDT
    function getPlayerAcgHoldingInUsdt(address player) external view returns (uint256) {
        return claculateUserAcgHoldingsInUsdt(player);
    }
}