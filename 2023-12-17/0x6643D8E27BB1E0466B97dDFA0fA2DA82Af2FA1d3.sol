// File: https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v4.9/contracts/utils/Context.sol


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

// File: https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v4.9/contracts/utils/Address.sol


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

// File: https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v4.9/contracts/token/ERC20/extensions/IERC20Permit.sol


// OpenZeppelin Contracts (last updated v4.9.0) (token/ERC20/extensions/IERC20Permit.sol)

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

// File: https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v4.9/contracts/token/ERC20/IERC20.sol


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

// File: https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v4.9/contracts/token/ERC20/extensions/IERC20Metadata.sol


// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.0;


/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
 */
interface IERC20Metadata is IERC20 {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
}

// File: https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v4.9/contracts/token/ERC20/ERC20.sol


// OpenZeppelin Contracts (last updated v4.9.0) (token/ERC20/ERC20.sol)

pragma solidity ^0.8.0;




/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20PresetMinterPauser}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.openzeppelin.com/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * The default value of {decimals} is 18. To change this, you should override
 * this function so it returns a different value.
 *
 * We have followed general OpenZeppelin Contracts guidelines: functions revert
 * instead returning `false` on failure. This behavior is nonetheless
 * conventional and does not conflict with the expectations of ERC20
 * applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 *
 * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See {IERC20-approve}.
 */
contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * All two of these values are immutable: they can only be set once during
     * construction.
     */
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5.05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the default value returned by this function, unless
     * it's overridden.
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * NOTE: If `amount` is the maximum `uint256`, the allowance is not updated on
     * `transferFrom`. This is semantically equivalent to an infinite approval.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * NOTE: Does not update the allowance if the current allowance
     * is the maximum `uint256`.
     *
     * Requirements:
     *
     * - `from` and `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     * - the caller must have allowance for ``from``'s tokens of at least
     * `amount`.
     */
    function transferFrom(address from, address to, uint256 amount) public virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, allowance(owner, spender) + addedValue);
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        address owner = _msgSender();
        uint256 currentAllowance = allowance(owner, spender);
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    /**
     * @dev Moves `amount` of tokens from `from` to `to`.
     *
     * This internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     */
    function _transfer(address from, address to, uint256 amount) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
            // Overflow not possible: the sum of all balances is capped by totalSupply, and the sum is preserved by
            // decrementing then incrementing.
            _balances[to] += amount;
        }

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        unchecked {
            // Overflow not possible: balance + amount is at most totalSupply + amount, which is checked above.
            _balances[account] += amount;
        }
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
            // Overflow not possible: amount <= accountBalance <= totalSupply.
            _totalSupply -= amount;
        }

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner` s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Updates `owner` s allowance for `spender` based on spent `amount`.
     *
     * Does not update the allowance amount in case of infinite allowance.
     * Revert if not enough allowance is available.
     *
     * Might emit an {Approval} event.
     */
    function _spendAllowance(address owner, address spender, uint256 amount) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }

    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * will be transferred to `to`.
     * - when `from` is zero, `amount` tokens will be minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual {}

    /**
     * @dev Hook that is called after any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * has been transferred to `to`.
     * - when `from` is zero, `amount` tokens have been minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens have been burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(address from, address to, uint256 amount) internal virtual {}
}

// File: https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v4.9/contracts/token/ERC20/utils/SafeERC20.sol


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

// File: Scrooge.sol



/*
   SSSSSSSSSSSSSSS         CCCCCCCCCCCCCRRRRRRRRRRRRRRRRR        OOOOOOOOO          OOOOOOOOO             GGGGGGGGGGGGGEEEEEEEEEEEEEEEEEEEEEE
 SS:::::::::::::::S     CCC::::::::::::CR::::::::::::::::R     OO:::::::::OO      OO:::::::::OO        GGG::::::::::::GE::::::::::::::::::::E
S:::::SSSSSS::::::S   CC:::::::::::::::CR::::::RRRRRR:::::R  OO:::::::::::::OO  OO:::::::::::::OO    GG:::::::::::::::GE::::::::::::::::::::E
S:::::S     SSSSSSS  C:::::CCCCCCCC::::CRR:::::R     R:::::RO:::::::OOO:::::::OO:::::::OOO:::::::O  G:::::GGGGGGGG::::GEE::::::EEEEEEEEE::::E
S:::::S             C:::::C       CCCCCC  R::::R     R:::::RO::::::O   O::::::OO::::::O   O::::::O G:::::G       GGGGGG  E:::::E       EEEEEE
S:::::S            C:::::C                R::::R     R:::::RO:::::O     O:::::OO:::::O     O:::::OG:::::G                E:::::E             
 S::::SSSS         C:::::C                R::::RRRRRR:::::R O:::::O     O:::::OO:::::O     O:::::OG:::::G                E::::::EEEEEEEEEE   
  SS::::::SSSSS    C:::::C                R:::::::::::::RR  O:::::O     O:::::OO:::::O     O:::::OG:::::G    GGGGGGGGGG  E:::::::::::::::E   
    SSS::::::::SS  C:::::C                R::::RRRRRR:::::R O:::::O     O:::::OO:::::O     O:::::OG:::::G    G::::::::G  E:::::::::::::::E   
       SSSSSS::::S C:::::C                R::::R     R:::::RO:::::O     O:::::OO:::::O     O:::::OG:::::G    GGGGG::::G  E::::::EEEEEEEEEE   
            S:::::SC:::::C                R::::R     R:::::RO:::::O     O:::::OO:::::O     O:::::OG:::::G        G::::G  E:::::E             
            S:::::S C:::::C       CCCCCC  R::::R     R:::::RO::::::O   O::::::OO::::::O   O::::::O G:::::G       G::::G  E:::::E       EEEEEE
SSSSSSS     S:::::S  C:::::CCCCCCCC::::CRR:::::R     R:::::RO:::::::OOO:::::::OO:::::::OOO:::::::O  G:::::GGGGGGGG::::GEE::::::EEEEEEEE:::::E
S::::::SSSS:::::S   CC:::::::::::::::CR::::::R     R:::::R OO:::::::::::::OO  OO:::::::::::::OO    GG:::::::::::::::GE::::::::::::::::::::E
S:::::::::::::::SS      CCC::::::::::::CR::::::R     R:::::R   OO:::::::::OO      OO:::::::::OO        GGG::::::GGG:::GE::::::::::::::::::::E
 SSSSSSSSSSSSSSS           CCCCCCCCCCCCCRRRRRRRR     RRRRRRR     OOOOOOOOO          OOOOOOOOO             GGGGGG   GGGGEEEEEEEEEEEEEEEEEEEEEE

*/
pragma solidity ^0.8.19;



/**
 * @title SCROOGE token
  * @dev Dapp contract to earn USDT
  */

contract Scrooge {

  /// @title Deposit structure
  /// @notice A contract to store deposit information
  struct Deposit {
      address owner;  // Address of the deposit owner
      uint256 amountUSDT;  // Amount of USDT deposited
      uint256 amountSCROOGE;  // Amount of SCROOGE earned
      uint256 soldAmountSCROOGE;  // Sold amount of SCROOGE
      uint40 date;  // Date of the deposit
      uint8 multiplier;  // Multiplier for earnings
      uint8 limit;  // Limit for the deposit
      uint256 soldAmount;  // soldAmount of USDT
      bool closed;  // Flag indicating if the deposit is closed after beign sold
  }

  /// @title User structure
  /// @notice A contract to store user information
  struct User {
      address referrer;  // Address of the user's referrer
      uint256[5] referrals;  // Number of referrals the user has made
      uint256[5] referralBonus;  // Bonus amount earned from referrals
      uint256 balanceUSDT;  // Balance of USDT
      uint256[] deposits;  // Array of deposit IDs made by the user
      uint40 lastWithdraw; // used for withdraw limits
      uint256 lastWithdrawAmount; // used for withdraw limits
  }

  //Deposit[] private _deposits;  // Array to store deposit information
  mapping(uint256 =>Deposit) _deposits;
  mapping(address => User) private _users;  // Mapping to store user information
  uint256 private _totalDeposits;
  uint256 private _totalUsers;
  uint256 private constant _startPrice = 1 ether;  // Starting price constant
//  uint256 private constant ONE_DAY = 15 minutes; // for test purposes
//  uint256 private constant ONE_DAY = 2 hours; // for test purposes
  uint256 private constant ONE_DAY = 1 days; // for production
  uint256 private _turnover;  // Total turnover
  uint256 private _withdrawn;  // Total withdrawn amount
  mapping(uint256 =>uint256) private _priceHistory;
  mapping(uint256 =>uint256) private _usersHistory;
  uint256 private _priceHistoryLength;
  uint256 private _usersHistoryLength;
  uint256 private _updatePriceDate;
  uint256 private _createdDate;

  IERC20 private _usdt;  // USDT token contract 0x17e7354759cddbbb1d40e9fc1a4ff198151fa906
  address private _owner;  // Address of the contract owner
  address private _defaultReferrer;  // Default referrer address

  uint256[5] private _referralLevelBonuses = [
      5, 2, 1, 1, 3
  ];  // Array of referral level bonuses  

  /**
    * @dev Event emitted when a deposit is made
    * @param sender Address of the sender
    * @param amount Amount of the deposit
    */
  event Charged(address indexed sender, uint256 amount);

  /**
    * @dev Event emitted when a withdrawal is made
    * @param sender Address of the sender
    * @param amount Amount of the withdrawal
    */
  event Withdrawn(address indexed sender, uint256 amount);

  /**
    * @dev Event emitted when SCROOGE tokens are bought
    * @param sender Address of the sender
    * @param amountUSDT Amount of USDT used for the purchase
    * @param amountSCROOGE Amount of SCROOGE tokens bought
    */
  event Deposited(address indexed sender, uint256 amountUSDT, uint256 amountSCROOGE);

  /**
    * @dev Event emitted when SCROOGE tokens are sold
    * @param sender Address of the sender
    * @param amountSCROOGE Amount of SCROOGE tokens sold
    * @param amountUSDT Amount of USDT received from the sale
    */
  event Sold(address indexed sender, uint256 amountSCROOGE, uint256 amountUSDT);

  /**
    * @dev Event emitted when a referral payment is made
    * @param user Address of the user receiving the referral payment
    * @param referrer Address of the referrer who referred the user
    * @param value Referral payment value
    */
  event ReferralPayment(address indexed user, address indexed referrer, uint256 value);

  /**
  * @dev Initializes the DepositManager contract
  * @param usdt Address of the USDT token contract
  */
  constructor(address usdt) {
      require(usdt != address(0), "Incorrect address");
      _usdt = IERC20(usdt);  // Initiablize USDT token contract
      _owner = msg.sender;  // Set the contract owner
      _defaultReferrer = msg.sender;  // Set the default referrer
      _createdDate=block.timestamp;
      uint256 hoursAndMinutes = block.timestamp - block.timestamp / ONE_DAY * ONE_DAY;
      _updatePriceDate=block.timestamp - hoursAndMinutes;
      _priceHistory[0]=_startPrice;
      _priceHistoryLength=1;
      _usersHistory[0]=1;
      _totalUsers = 1;
     _usersHistoryLength=1;  
}


  /**
  * @dev Charge USDT function
  * @param amount Amount of USDT to charge
  * @param referrer Address of the referrer
  */
  function charge(uint256 amount, address referrer) external {
    require(amount > 0, "Illegal amount");
    require(_usdt.allowance(msg.sender, address(this)) >= amount, "Not enough USDT");
    //require(msg.sender != _defaultReferrer, "Owner not allowed to buy");

    // Increase the user's USDT balance
    _users[msg.sender].balanceUSDT += amount;

    // Set the referrer if it is not already set
    if (_users[msg.sender].referrer == address(0) && msg.sender!=_defaultReferrer) {
	      _totalUsers += 1;
        if (referrer == address(0) || referrer == msg.sender) {
            referrer = _defaultReferrer;
        } 
        if (_users[msg.sender].referrer != referrer) {
            _users[msg.sender].referrer = referrer;
            for (uint256 i; i < 5;) {
                _users[referrer].referrals[i] += 1;
                referrer = _users[referrer].referrer;
                if (referrer == address(0)) {
                    break;
                }
                unchecked {
                    i++;
                }
            }
        }
    }
    _updatePriceHistory();

    // Transfer USDT from the sender to the contract
    SafeERC20.safeTransferFrom(_usdt, msg.sender, address(this), amount);

    // Take a fee (5% of the charged amount)
    _takeFee(amount / 20);

    // Emit the Charget event
    emit Charged(msg.sender, amount);
  }

  /**
  * @dev Buy function
  * @param amount Amount of USDT to be used for the purchase
  */
  function newdeposit(uint256 amount) external {
    require(amount > 0, "Illegal amount");
    require(_users[msg.sender].balanceUSDT >= amount, "Not enough balance");

    // Deduct the purchased amount from the user's USDT balance
    unchecked {
        _users[msg.sender].balanceUSDT -= amount;
    }

    // Create a new deposit instance
    Deposit memory deposit;
    deposit.owner = msg.sender;
    deposit.amountUSDT = amount;
    (uint8 multiplier,uint8 limit) = _getMultiplierAndLimit(amount);
    deposit.multiplier=multiplier;
    deposit.limit=limit;
    deposit.date = uint40( block.timestamp );
    
    _turnover += amount;

    _updatePriceHistory();

    // Distribute referral bonuses to referrers
    _distributeBonusesForReferrers(_users[msg.sender].referrer, amount);

    // Add the deposit to the array of deposits
    _deposits[_totalDeposits]=deposit;

    // Update turnover and user's deposit list
    _users[msg.sender].deposits.push(_totalDeposits);

    _totalDeposits+=1;

    // Take a fee for the exchange (1.5%)
    _takeFee(amount * 15/ 1000);

    // Emit the Deposited event
    emit Deposited(msg.sender, amount, deposit.amountSCROOGE);
  }

  /**
  * @dev Internal function to distribute referral bonuses to referrers
  * @param referrer Address of the referrer
  * @param amount Amount of USDT charged by the user
  */
  function _distributeBonusesForReferrers(address referrer, uint256 amount) internal {
    for (uint256 i; i < 5;) {
        if (referrer == address(0)) {
            break;
        }
        uint256 bonus = amount * _referralLevelBonuses[i] / 100;

        // Increase referrer's referral bonus and user's USDT balance
        _users[referrer].referralBonus[i] += bonus;
        _users[referrer].balanceUSDT += bonus;

        // Emit the ReferralPayment event
        emit ReferralPayment(msg.sender, referrer, bonus);

        unchecked {
            i++;
        }

        referrer = _users[referrer].referrer;
    }
  }

  /**
  * @dev Sell function
  * @param amount Amount of SCROOGE tokens to sell
  */
  function sell(uint256 amount) external {
    require(amount > 0, "Illegal amount");
    uint256 totalEarnedSCROOGE;
    uint256 totalEarnedUSDT;
    
    for (uint256 i; i < _users[msg.sender].deposits.length;) {
        uint256 deposit_id = _users[msg.sender].deposits[i];
        Deposit storage deposit=_deposits[deposit_id];
        if (!deposit.closed) {
            uint256 earnedSCROOGE;
            uint256 earnedUSDT;
            
            ( earnedSCROOGE ) = earnedScrooge(msg.sender, i, uint40(block.timestamp));
            
            uint256 limit=deposit.limit * deposit.amountUSDT/10;
            if (amount >= earnedSCROOGE) {
                amount -= earnedSCROOGE;
                totalEarnedSCROOGE+=earnedSCROOGE;
                earnedUSDT=_calculateUSDTFromSCROOGE(earnedSCROOGE);
                
                deposit.soldAmountSCROOGE += earnedSCROOGE;
                
                if (deposit.soldAmount + earnedUSDT >= limit){
                  earnedUSDT = limit - deposit.soldAmount;
                  deposit.closed=true;
                }

                totalEarnedUSDT+=earnedUSDT;
                deposit.soldAmount += earnedUSDT;
            } else {
                totalEarnedSCROOGE+=amount;
                deposit.soldAmountSCROOGE += amount;
                earnedUSDT=_calculateUSDTFromSCROOGE(amount);


                if (deposit.soldAmount + earnedUSDT >= limit){
                  earnedUSDT = limit - deposit.soldAmount;
                  deposit.closed=true;
                }

                totalEarnedUSDT+=earnedUSDT;
                deposit.soldAmount += earnedUSDT;
                break;
            }
        }
        unchecked {
            i++;
        }
    }
    require(totalEarnedSCROOGE >= amount, "No earnings");
    _updatePriceHistory();

    // Increase the user's USDT balance
    _users[msg.sender].balanceUSDT += totalEarnedUSDT;

    // Take a fee for the exchange (1.5%)
    _takeFee(totalEarnedUSDT * 15/ 1000);

    // Emit the Sold event
    emit Sold(msg.sender, totalEarnedSCROOGE, totalEarnedUSDT);
  }

  /**
  * @dev Get the earned SCROOGE balance of a user at a specific timestamp
  * @param user Address of the user
  * @param timestamp Timestamp to calculate the balances
  * @return earned Earned SCROOGE balance
  */
  function balanceOf(address user, uint40 timestamp) internal view 
    returns (
        uint256 earned
      ) {
    for (uint256 i; i < _users[user].deposits.length;) {
        uint256 deposit_id = _users[user].deposits[i];

        if (!_deposits[deposit_id].closed) {
            (uint256 earnedPart) = earnedScrooge(user, i, timestamp);
                earned+=earnedPart;
        }
        unchecked {
            i++;
        }
    }
  }

  /**
  * @dev Withdraw function
  * @param amount Amount of USDT to withdraw
  */
  function withdraw(uint256 amount) external {
    require(amount > 0, "Illegal amount");
    require(_users[msg.sender].balanceUSDT >= amount, "Not enough balance");
    uint256 passedDays=(block.timestamp  - _users[msg.sender].lastWithdraw) / ONE_DAY;
    _users[msg.sender].lastWithdraw=uint40(block.timestamp);
    if (passedDays == 0){
        _users[msg.sender].lastWithdrawAmount+=amount;
    }else{
        _users[msg.sender].lastWithdrawAmount=amount;
    }
    
    uint256 totalDepositsAmount=0;
    for(uint256 i;i<_users[msg.sender].deposits.length;){
        uint256 depositId=_users[msg.sender].deposits[i];
        if (!_deposits[ depositId ].closed){
            totalDepositsAmount+=_deposits[ depositId ].amountUSDT;
        }
        unchecked{
            i++;
        }
    }
        
    require( _users[msg.sender].lastWithdrawAmount  < totalDepositsAmount * 3/10, "Daily limit of deposits withdraw reached" );
    require( _users[msg.sender].lastWithdrawAmount  < _usdt.balanceOf(address(this)) / 100, "Daily limit of liquidity withdraw reached" );

    unchecked {
        _users[msg.sender].balanceUSDT -= amount;
        _withdrawn+=amount;
    }
    
    _updatePriceHistory();

    // Transfer the withdrawn amount to the user's address
    SafeERC20.safeTransfer(_usdt, msg.sender, amount);

    // Take a fee (5% of the withdrawn amount)
    _takeFee(amount / 20);

    // Emit the Withdrawn event
    emit Withdrawn(msg.sender, amount);
  }

  function getAvailWithdraw(address user, uint256 timestamp) external view returns(uint256){
    uint256 lastWithdrawAmount=_users[user].lastWithdrawAmount;
    if ((timestamp  - _users[user].lastWithdraw)/ (ONE_DAY) > 1){
      lastWithdrawAmount=0;
    }
    
    uint256 totalDepositsAmount=0;
    for(uint256 i;i<_users[user].deposits.length;){
        uint256 depositId=_users[user].deposits[i];
        if (!_deposits[ depositId ].closed){
            totalDepositsAmount+=_deposits[ depositId ].amountUSDT;
        }
        unchecked{
            i++;
        }
    }
    uint256 depLimit=totalDepositsAmount * 3/10;
    uint256 liqLimit=_usdt.balanceOf(address(this)) / 100;
    uint256 withdrawLimit=0;

    if (depLimit > liqLimit){
      withdrawLimit = liqLimit;
    }else{
      withdrawLimit = depLimit;
    }

    if (withdrawLimit > lastWithdrawAmount){
      withdrawLimit=withdrawLimit - lastWithdrawAmount;
    }else{
      withdrawLimit= 0;
    }
    return withdrawLimit;
  }

  /**
  * @dev Calculate the earned SCROOGE tokens for a user's deposit at a specific timestamp
  * @param user Address of the user
  * @param id Index of the deposit in the user's deposit list
  * @param timestamp Timestamp to calculate the earned amount
  * @return amountSCROOGE Earned SCROOGE tokens
  */
  function earnedScrooge(address user, uint256 id, uint40 timestamp) internal view 
    returns (uint256 amountSCROOGE ) {
    Deposit memory deposit = _deposits[_users[user].deposits[id]];
    if (deposit.closed) return (0);
    uint256 limit=deposit.limit * deposit.amountUSDT / 10;
    
    if (timestamp <= deposit.date || deposit.date <= _createdDate) return (0);
    uint256 daysPassed=(timestamp - deposit.date) / ONE_DAY;
    uint256 daysOffset=(deposit.date - _createdDate) / ONE_DAY;
    
    for(uint256 i;i<daysPassed;){
      uint256 earnedUSDT = deposit.amountUSDT * deposit.multiplier / 10000;
      uint256 earnedSCROOGE=_calculateSCROOGEFromUSDTOnDate(earnedUSDT, daysOffset + i + 1);
      amountSCROOGE += earnedSCROOGE;

      if (_calculateUSDTFromSCROOGEOnDate(amountSCROOGE, daysOffset + i + 1) > limit){
        //finished=true;
        break;
      }
      unchecked{
        i++;
      }
    }

    if (amountSCROOGE >deposit.soldAmountSCROOGE){
          amountSCROOGE -= deposit.soldAmountSCROOGE;
    }else{
      amountSCROOGE=0;
    }
  }

  /**
  * @dev Internal function to calculate the multiplier and limit based on the amount
  * @param amount Amount of USDT being used for the purchase
  * @return multiplier Multiplier value based on the deposit count
  * @return limit Limit value based on the deposit count
  */
  function _getMultiplierAndLimit(uint256 amount) internal view 
    returns (
      uint8 multiplier, 
      uint8 limit
    ) {
    if (_totalDeposits < 60) {
        multiplier = 200;
        limit = 25;
    } else if (_totalDeposits < 150) {
        multiplier = 150;
        limit = 20;
    } else if (amount < 500 ether) {
        multiplier = 100;
        limit = 20;
    } else {
        multiplier = 125;
        limit = 20;
    }
  }

  /**
  * @dev Internal function to calculate the current price of SCROOGE tokens
  * @return price Current price of SCROOGE tokens
  */
  function calculatePrice() public view returns (uint256 price) {
    price =  _startPrice  + 2 * _turnover/ 100000;
    if (_turnover > 100000 ether) {
        price += 4 * (_turnover - (100000 ether))/ 100000;
    }
    if (_turnover > 200000 ether) {
        price += 3 * (_turnover - (200000 ether))/ 100000;
    }
    if (_turnover > 1000000 ether) {
        price += (_turnover - (1000000 ether))/ 100000;
    }
    price += _withdrawn / 100000;

  }

  function getInfo() external view returns(uint256 deposits, uint256 users){
    deposits=_totalDeposits;
    users=_totalUsers;
  }

  function getUserDeposits(address user, uint40 timestamp) external view returns(Deposit[] memory deposits)
  {
    deposits=new Deposit[](_users[user].deposits.length);
    for(uint256 i;i<_users[user].deposits.length;i++){
      deposits[i] = _deposits[ _users[user].deposits[i] ];
      if (!deposits[i].closed) {
            (uint256 earnedPart) = earnedScrooge(user, i, timestamp);
                deposits[i].amountSCROOGE=earnedPart;
        }
    }
  }

  /**
  * @dev Get the user's informaхtion
  * @param user Address of the user
  * @param timestamp Timestamp to calculate the balances
  * @return referrer Address of the referrer
  * @return referrals Number of referrals
  * @return balanceUSDT Total USDT balance
  * @return balanceSCROOGE Total SCROOGE balance
  * @return referralBonus Referral bonus balance
  */
  function getUserInfo(address user, uint40 timestamp) external view 
    returns (
      address referrer, 
      uint256[5] memory referrals, 
      uint256 balanceUSDT, 
      uint256 balanceSCROOGE, 
      uint256[5] memory referralBonus
    ) {
    referrer = _users[user].referrer;
    referrals = _users[user].referrals;
    balanceUSDT = _users[user].balanceUSDT;
    balanceSCROOGE = balanceOf(user, timestamp);
    referralBonus = _users[user].referralBonus;
  }

  function getPriceHistory() external view returns(uint256[] memory history, uint256 timestamp){
    history=new uint256[](30);
    timestamp = _updatePriceDate;
    uint256 _index=_priceHistoryLength-1;
    for(uint256 i;i<30;i++){
      history[29 - i] = _priceHistory[ _index ];
      if (_index ==0) {
        break;
      }else{
        _index--;
      }
    }
  }


  function getUsersHistory() external view returns(uint256[] memory history, uint256 timestamp){
    history=new uint256[](30);
    timestamp = _updatePriceDate;
    if (_usersHistoryLength ==0) return (history, timestamp);
    uint256 _index=_usersHistoryLength-1;

    for(uint256 i;i<30;i++){
      history[29 - i] = _usersHistory[ _index ];
      if (_index ==0) {
        break;
      }else{
        _index--;
      }
    }
  }

  /**
  * @dev Internal function to take a fee from the specified amount
  * @param amount Amount to take as a fee
  */
  function _takeFee(uint256 amount) internal {
    SafeERC20.safeTransfer(_usdt, _owner, amount);
  }

  /**
  * @dev Internal function to calculate the amount of SCROOGE tokens based on the specified 
  * USDT amount
  * @param usdt Amount of USDT
  * @return amount Amount of SCROOGE tokens
  */
  function _calculateSCROOGEFromUSDTOnDate(uint256 usdt,uint256 day) internal view returns (uint256 amount) {
    if (day >= _priceHistoryLength) day=_priceHistoryLength-1;
    amount = usdt * (1 ether) / _priceHistory[day];
  }

  /**
  * @dev Internal function to calculate the amount of USDT based on the specified SCROOGE amount
  * @param amount Amount of SCROOGE tokens
  * @return usdt Amount of USDT
  */
  function _calculateUSDTFromSCROOGE(uint256 amount) internal view returns (uint256 usdt) {
    usdt = amount * calculatePrice() / (1 ether);
  }


  function _calculateUSDTFromSCROOGEOnDate(uint256 amount, uint256 day) internal view returns (uint256 usdt) {
    if (day >= _priceHistoryLength) day=_priceHistoryLength-1;
    usdt = amount * _priceHistory[day] / (1 ether);
  }

  function _updatePriceHistory() internal{
    if (block.timestamp <= _updatePriceDate) return;
    uint256 _days=(block.timestamp - _updatePriceDate) / ONE_DAY;
    uint256 new_price=calculatePrice();
    if (_days > 0 ){
      uint256 old_price=_priceHistory[_priceHistoryLength - 1];
      uint256 old_users=0;
      if (_usersHistoryLength >0) {
        old_users=_usersHistory[_usersHistoryLength - 1];
      }
      for(uint256 i;i<_days - 1;){
        _priceHistory[_priceHistoryLength]=old_price;
        _priceHistoryLength+=1;
        _usersHistory[_usersHistoryLength]=old_users;
        _usersHistoryLength+=1;
        unchecked{
          i++;
        }
      }
      _priceHistory[_priceHistoryLength]=new_price;
      _priceHistoryLength+=1;
      _usersHistory[_usersHistoryLength]=_totalUsers;
      _usersHistoryLength+=1;
      //_updatePriceDate=block.timestamp;
      uint256 hoursAndMinutes = block.timestamp - block.timestamp / ONE_DAY * ONE_DAY;
      _updatePriceDate=block.timestamp - hoursAndMinutes;

    }else{
      _priceHistory[_priceHistoryLength -1]=new_price;
      _usersHistory[_usersHistoryLength -1]=_totalUsers;
    }
  }
}