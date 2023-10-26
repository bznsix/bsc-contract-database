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
// OpenZeppelin Contracts (last updated v4.9.0) (token/ERC20/ERC20.sol)

pragma solidity ^0.8.0;

import "./IERC20.sol";
import "./extensions/IERC20Metadata.sol";
import "../../utils/Context.sol";

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
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";

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
pragma solidity >=0.5.0;

interface IUniswapV2Factory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
}
pragma solidity >=0.5.0;

interface IUniswapV2Pair {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address owner) external view returns (uint);

    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;

    event Mint(address indexed sender, uint amount0, uint amount1);
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint);
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function price0CumulativeLast() external view returns (uint);
    function price1CumulativeLast() external view returns (uint);
    function kLast() external view returns (uint);

    function mint(address to) external returns (uint liquidity);
    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;

    function initialize(address, address) external;
}
pragma solidity >=0.6.2;

interface IUniswapV2Router01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

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
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}
pragma solidity >=0.6.2;

import './IUniswapV2Router01.sol';

interface IUniswapV2Router02 is IUniswapV2Router01 {
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
// SPDX-License-Identifier: UNLICENSED
pragma solidity = 0.8.19;

interface INftRewardsDistributor {
    function distributeNFTRewards(address tokenToDistribute, uint256 amountToDistribute) external;
}// SPDX-License-Identifier: Unlicense
pragma solidity =0.8.19;

import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./Interfaces/INftRewardsDistributor.sol";
import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Factory.sol";
import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Pair.sol";
import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";

/**
 * @author  <a href="http://https://github.com/R3D4NG3L">R3D4NG3L</a>  
 * @title   Praiza Token
 * @notice  Taxes: 
             - 1,8% Base Reflections shared among all token holders
             - 11,2% Total Taxes as distributed
                - 5% Buy back and burn
                - 4,2% Premium Reflections for NFT holders
                - 1% Marketing
                - 1% Team Salary
 */

contract Praiza is Context, ERC20, Ownable {
    using SafeMath for uint256;
    using Address for address;

    // ----------------------------------------------------------------
    // Reflection vars
    // ----------------------------------------------------------------
    mapping(address => uint256) private _rOwned;
    mapping(address => uint256) private _tOwned;
    mapping(address => bool) private _isExcludedFromBaseReflections;
    address[] private _excluded;

    bool private swapping;

    IUniswapV2Router02 public router;
    address public pair;

    uint8 private constant _decimals = 18;
    uint256 private constant MAX = ~uint256(0);

    uint256 private _tTotal = 100_000_000 * 10 ** _decimals;
    uint256 private _rTotal = (MAX - (MAX % _tTotal));

    uint256 public swapTokensAtAmount = _tTotal.div(5_000);

    // ----------------------------------------------------------------
    // ---- Taxes Wallets ----
    // ----------------------------------------------------------------
    address public deadWallet = address(0x000000000000000000000000000000000000dEaD);
    address public marketingWallet = address(0xd602F76088De29e88250C3B0385405b895612746);
    address public teamSalaryWallet = address(0x56DDBBDCB8ac77d1585FF65F171E5cB226e10e7f);
    address public receiveRewards = address(0xa8C0cAEA5d6E222C885cc5a08B269a95eA1022e4);

    // ----------------------------------------------------------------
    // --- Events ---
    // ----------------------------------------------------------------
    event _tradingEnabledEvent(bool value);
    event _buyBackAndBurnEvent(uint256 amount);
    event _swappedTaxesForWETHEvent(uint256 amount);

    bool public isTradingEnabled = false;

    struct Taxes {
        uint256 baseReflections;
        uint256 premiumRfi_Mkt_Salry_Bbb;
    }

    // Taxes are a total of 13%, which 1,8% are base reflections, 
    // 11,2% are premium reflections, marketing, team salary and buy back and burn
    Taxes private taxes = Taxes(18, 112);

    mapping(address => bool) private _isExcludedFromTaxes;

    // ----------------------------------------------------------------
    // ---- Taxes Allocation ---
    // ---- Taxes are a total of 11,2% (excluding 1,8% of base reflections)
    // ---- Premium reflections allocation are 4,8% of this 11,2%, this means that is the 42,86% of those fees
    // ----------------------------------------------------------------
    // Excluding the premium reflections that are paid in tokens, the rest of the taxes are divided as follows
    // ---- Buy Back & Burn allocation is 5% of this 6,4%, this means that is the 78,13% of those fees
    // ---- Marketing allocation is 1% of this 6,4%, this means that is the 15,63% of those fees
    // ---- Salary allocation is 1% of this 6,4%, this means that is the 15,63% of those fees
    // ----------------------------------------------------------------
    uint256 private constant premiumReflectionsAllocation = 4286;
    uint256 private constant buyBackAllocation = 6873;
    uint256 private constant marketingAllocation = 1563;
    uint256 private constant salaryAllocation = 1563;
    uint256 private constant allocation_denominator = 10000;

    struct TotFeesPaidStruct {
        uint256 baseReflections;
        uint256 premiumRfi_Mkt_Salry_Bbb;
    }

    TotFeesPaidStruct public totFeesPaid;

    struct valuesFromGetValues {
        uint256 rAmount;
        uint256 rTransferAmount;
        uint256 rBaseReflections;
        uint256 rTaxes;
        uint256 tTransferAmount;
        uint256 tBaseReflections;
        uint256 tTaxes;
    }
    
    constructor(address routerAddress) ERC20("Praiza", "PRZ") {
        IUniswapV2Router02 _router = IUniswapV2Router02(routerAddress);
        address _pair = IUniswapV2Factory(_router.factory()).createPair(
            address(this),
            _router.WETH()
        );

        router = _router;
        pair = _pair;

        excludeFromBaseReflections(pair);
        excludeFromBaseReflections(deadWallet);

        _rOwned[owner()] = _rTotal;
        includeExcludeFromTaxes(address(this), true);
        includeExcludeFromTaxes(owner(), true);
        includeExcludeFromTaxes(marketingWallet, true);
        includeExcludeFromTaxes(deadWallet, true);
        includeExcludeFromTaxes(teamSalaryWallet, true);
        emit Transfer(address(0), owner(), _tTotal);
    }

    /**
     * @notice  Given a token amount, returns the reflection amount
     * @param   tAmount  Token Amount
     * @param   deductTransferRfi  Deduct base reflection fees
     * @return  uint256  Reflection amount
     */
    function reflectionFromToken(
        uint256 tAmount,
        bool deductTransferRfi
    ) public view returns (uint256) {
        require(tAmount <= _tTotal, "Amount must be less than supply");
        if (!deductTransferRfi) {
            valuesFromGetValues memory s = _getValues(tAmount, true);
            return s.rAmount;
        } else {
            valuesFromGetValues memory s = _getValues(tAmount, true);
            return s.rTransferAmount;
        }
    }

    /**
     * @notice  Given a reflection amount, calculate the token amount from it according to current rate
     * @param   rAmount  Reflection Amount
     * @return  uint256  Token Amount
     */
    function tokenFromReflection(
        uint256 rAmount
    ) public view returns (uint256) {
        require(
            rAmount <= _rTotal,
            "Amount must be less than total reflections"
        );
        uint256 currentRate = _getRate();
        return rAmount.div(currentRate);
    }

    /**
     * @notice  Deduct reflections from total
     * @param   rBaseReflections  Reflection - Base Reflection
     * @param   tBaseReflections  Supply - Base Reflection
     */
    function _reflectRfi(uint256 rBaseReflections, uint256 tBaseReflections) private {
        _rTotal = _rTotal.sub(rBaseReflections);
        totFeesPaid.baseReflections = totFeesPaid.baseReflections.add(tBaseReflections);
    }

    /**
     * @notice  Transfer the 9,2% of taxes to current smart contract address
     * @dev     Taxes will be liquidated on next transfers when reaching a minimum amount defined in swapTokensAtAmount
     * @param   rTaxes  Reflection Taxes
     * @param   tTaxes  Transfer Taxes
     */
    function _takeTaxes(uint256 rTaxes, uint256 tTaxes) private {
        totFeesPaid.premiumRfi_Mkt_Salry_Bbb = totFeesPaid.premiumRfi_Mkt_Salry_Bbb.add(tTaxes);

        if (_isExcludedFromBaseReflections[address(this)]) {
            _tOwned[address(this)] = _tOwned[address(this)].add(tTaxes);
        }
        _rOwned[address(this)] = _rOwned[address(this)].add(rTaxes);
    }

    /**
     * @notice  Get transcation values
     * @param   tAmount  Token to transfer
     * @param   takeTaxes  Take taxes
     * @return  values  Transaction values
     */
    function _getValues(
        uint256 tAmount,
        bool takeTaxes
    ) private view returns (valuesFromGetValues memory values) {
        values = _getTValues(tAmount, takeTaxes);
        (
            values.rAmount,
            values.rTransferAmount,
            values.rBaseReflections,
            values.rTaxes
        ) = _getRValues(values, tAmount, takeTaxes, _getRate());

        return values;
    }

    /**
     * @notice  Get Token Transaction Values
     * @param   tAmount  Token amount to transfer
     * @param   takeTaxes  Take taxes
     * @return  s  Transaction Values
     */
    function _getTValues(
        uint256 tAmount,
        bool takeTaxes
    ) private view returns (valuesFromGetValues memory s) {
        if (!takeTaxes) {
            s.tTransferAmount = tAmount;
            return s;
        }

        s.tBaseReflections = tAmount.mul(taxes.baseReflections).div(1000);
        s.tTaxes = tAmount.mul(taxes.premiumRfi_Mkt_Salry_Bbb).div(1000);
        s.tTransferAmount = tAmount.sub(s.tBaseReflections).sub(s.tTaxes);
        return s;
    }

    /**
     * @notice  Get Reflection Values
     * @param   s  Reflecition and Supply Values
     * @param   tAmount  Token Amount to transfer
     * @param   takeTaxes  Take Fee
     * @param   currentRate  Current Reflection Rate
     * @return  rAmount  Reflection Amount
     * @return  rTransferAmount  Reflections Transfer Amount
     * @return  rBaseReflections  Base Reflections Ammount
     * @return  rTaxes  Reflection Taxes
     */
    function _getRValues(
        valuesFromGetValues memory s,
        uint256 tAmount,
        bool takeTaxes,
        uint256 currentRate
    )
        private
        pure
        returns (
            uint256 rAmount,
            uint256 rTransferAmount,
            uint256 rBaseReflections,
            uint256 rTaxes
        )
    {
        rAmount = tAmount.mul(currentRate);

        if (!takeTaxes) {
            return (rAmount, rAmount, 0, 0);
        }

        rBaseReflections = s.tBaseReflections.mul(currentRate);
        rTaxes = s.tTaxes.mul(currentRate);
        rTransferAmount = rAmount.sub(rBaseReflections).sub(rTaxes);
        return (rAmount, rTransferAmount, rBaseReflections, rTaxes);
    }

    /**
     * @notice  Get reflection rate
     * @return  uint256  Reflection supply divided per total supply
     */
    function _getRate() private view returns (uint256) {
        (uint256 rSupply, uint256 tSupply) = _getCurrentSupply();
        return rSupply.div(tSupply);
    }

    /**
     * @notice  Get currenct supply
     * @return  uint256  Reflection supply
     * @return  uint256  Total supply
     */
    function _getCurrentSupply() private view returns (uint256, uint256) {
        uint256 rSupply = _rTotal;
        uint256 tSupply = _tTotal;
        for (uint256 i = 0; i < _excluded.length; i++) {
            if (
                _rOwned[_excluded[i]] > rSupply ||
                _tOwned[_excluded[i]] > tSupply
            ) return (_rTotal, _tTotal);
            rSupply = rSupply.sub(_rOwned[_excluded[i]]);
            tSupply = tSupply.sub(_tOwned[_excluded[i]]);
        }
        if (rSupply < _rTotal.div(_tTotal)) return (_rTotal, _tTotal);
        return (rSupply, tSupply);
    }

    /**
     * @notice  Indicates if the interaction is happening between normal addresses
     * @dev     Used to check if the interaction is dealing with special addresses or not
     * @param   from  Transfer From Address
     * @param   to  Transfer To Address
     * @return  bool  true if is a standard interaction, else false if is a special interaction
     */
    function isStandardInteraction(
        address from,
        address to
    ) internal view returns (bool) {
        bool isLimited = from != owner() &&
            to != owner() &&
            msg.sender != owner() &&
            !_isExcludedFromTaxes[from] &&
            !_isExcludedFromTaxes[to] &&
            to != address(0xdead) &&
            to != address(0) &&
            to != address(this);
        return isLimited;
    }

    /**
     * @dev     Transfer function counting reflections and taxes
     * @param   from  From Address
     * @param   to  Receiving Address
     * @param   amount  Amount of tokens to transfer
     */
    function _transfer(address from, address to, uint256 amount) internal override {
        require(from != address(0), "BEP20: transfer from the zero address");
        require(to != address(0), "BEP20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        require(
            amount <= balanceOf(from),
            "You are trying to transfer more than your balance"
        );

        if (isStandardInteraction(from, to)) {
            require(isTradingEnabled, "Trading is not enabled");
        }

        bool canSwap = balanceOf(address(this)) >= swapTokensAtAmount;
        if (
            !swapping &&
            canSwap &&
            from != pair &&
            !_isExcludedFromTaxes[from] &&
            !_isExcludedFromTaxes[to]
        ) {
            swapAndLiquify();
        }
        bool takeTaxes = true;
        if (swapping || _isExcludedFromTaxes[from] || _isExcludedFromTaxes[to])
            takeTaxes = false;

        _tokenTransfer(from, to, amount, takeTaxes);
    }

    /**
     * @notice  Token transfer
     * @param   sender  Sender
     * @param   recipient  Receiving recipient
     * @param   tAmount  Token Amount to transfer
     * @param   takeTaxes  Take Taxes
     */
    function _tokenTransfer(
        address sender,
        address recipient,
        uint256 tAmount,
        bool takeTaxes
    ) private {
        valuesFromGetValues memory s = _getValues(tAmount, takeTaxes);

        if (_isExcludedFromBaseReflections[sender]) {
            _tOwned[sender] = _tOwned[sender].sub(tAmount);
        }
        if (_isExcludedFromBaseReflections[recipient]) {
            _tOwned[recipient] = _tOwned[recipient].add(s.tTransferAmount);
        }

        _rOwned[sender] = _rOwned[sender].sub(s.rAmount);
        _rOwned[recipient] = _rOwned[recipient].add(s.rTransferAmount);

        if (s.rBaseReflections > 0 || s.tBaseReflections > 0) _reflectRfi(s.rBaseReflections, s.tBaseReflections);
        if (s.rTaxes > 0 || s.tTaxes > 0)
            _takeTaxes(s.rTaxes, s.tTaxes);
        emit Transfer(sender, recipient, s.tTransferAmount);
    }

    /**
     * @notice  Takes current contract balance and distributes tokens for premium reflections, and swaps the remaining part in BNBs
     *          and sends them to marketing, team salary and buy back and burn wallets
     */
    function swapAndLiquify() private lockTheSwap {
        uint256 contractBalance = balanceOf(address(this));
        // Send premium reflections to receiveRewards wallet
        uint256 rewardsAmount = premiumReflectionsAllocation.mul(contractBalance).div(allocation_denominator);
        if (rewardsAmount > 0)
        {
            _transfer(address(this), receiveRewards, rewardsAmount);
            if (_isContract(receiveRewards))
            {
                INftRewardsDistributor distributor = INftRewardsDistributor(receiveRewards);
                try distributor.distributeNFTRewards(address(this), rewardsAmount) { } catch { }
            }
        }

        contractBalance = balanceOf(address(this));
        _swapTokensForWETH(contractBalance);

        bool success;

        uint256 buyBack = buyBackAllocation.mul(address(this).balance).div(allocation_denominator);
        uint256 mark = marketingAllocation.mul(address(this).balance).div(allocation_denominator);
        uint256 sal = salaryAllocation.mul(address(this).balance).div(allocation_denominator);

        if (mark > 0) {
            (success, ) = marketingWallet.call{value: mark, gas: 35000}("");
        }
        if (sal > 0) {
            (success, ) = teamSalaryWallet.call{value: sal, gas: 35000}("");
        }
        if (buyBack > 0) {
            _buyBackAndBurn(buyBack);
        }
    }

    /**
     * @notice  Update taxes receiver wallets
     * @param   _newMarketingWallet  New Marketing Wallet
     * @param   _teamSalaryWallet  New Team Salary Wallet
     */
    function updateWallets(
        address _newMarketingWallet,
        address _teamSalaryWallet
    ) external onlyOwner {
        require(_newMarketingWallet != address(0), "Zero address");
        require(_teamSalaryWallet != address(0), "Zero Address");
        marketingWallet = _newMarketingWallet;
        teamSalaryWallet = _teamSalaryWallet;
        includeExcludeFromTaxes(marketingWallet, true);
        includeExcludeFromTaxes(teamSalaryWallet, true);
    }

    /**
     * @dev     No checks, but not suggested to set values higher than 10_000 (1% of _tTotal supply)
     * @param   amount  Minimum amount of tokens to trigger the swapAndLiquify for taxes redistribution
     */
    function updateSwapTokensAtAmount(uint256 amount) external onlyOwner {        
        swapTokensAtAmount = amount;
    }

    /**
     * @dev isTradingEnabled can't be disabled otherwise might be flagged as honeypot
     */
    function enableTrading() external onlyOwner {
        require(isTradingEnabled != true, "Same Bool");
        isTradingEnabled = true;
        emit _tradingEnabledEvent(true);
    }

    /**
     * @dev     Change premium reflections distributor. Set 0 to stop distributing premium reflections.
     * @param   distributorAddress Distributor Address
     */
    function changePremiumReflectionsDistributor(address distributorAddress) external onlyOwner {
        receiveRewards = distributorAddress;
        if (!_isExcludedFromBaseReflections[distributorAddress]) {
            excludeFromBaseReflections(distributorAddress);
        }
        if (!isExcludedFromTaxes(distributorAddress)) {
            includeExcludeFromTaxes(distributorAddress, true);
        }
    }
    /**
     * @dev     Checks if an address is a smart contract
     * @param   addr  Address to check
     * @return  bool  true: is a smart contract, else false
     */
    function _isContract(address addr) internal view returns (bool) {
        uint size;
        assembly { size := extcodesize(addr) }
        return size > 0;
    }
    
    // ----------------------------------------------------------------
    // --- ERC20 Custom Implementations ----
    // ----------------------------------------------------------------
    /**
     * @notice  Token Decimals
     * @return  uint8  Token Decimals
     */
    function decimals() public pure override returns (uint8) {
        return _decimals;
    }

    /**
     * @notice  Total supply excluded dead wallet. This is a deflationatory token.
     * @return  uint256  Total supply
     */
    function totalSupply() public view override returns (uint256) {
        return _tTotal.sub(balanceOf(deadWallet));
    }

    /**
     * @notice  Balance of wallet
     * @dev     Special conditions for special wallets excluded from reflections
     * @param   account  Account to check the balance
     * @return  uint256  Account balance
     */
    function balanceOf(address account) public view override returns (uint256) {
        if (_isExcludedFromBaseReflections[account]) return _tOwned[account];
        return tokenFromReflection(_rOwned[account]);
    }

    // ----------------------------------------------------------------
    // Include/Exclude from base reflections
    // ----------------------------------------------------------------
    /**
     * @notice  Checks if an address is excluded from base reflections
     * @param   account  Account to check
     * @return  bool  true if the address is excluded from base reflections, else false
     */
    function isExcludedFromBaseReflections(
        address account
    ) public view returns (bool) {
        return _isExcludedFromBaseReflections[account];
    }

    /**
     * @notice  Exclude an address from base reflections
     * @dev     Usefull for LP pair and Dead Wallet
     * @param   account  Account to exclude from base reflections
     */
    function excludeFromBaseReflections(address account) public onlyOwner {
        require(
            !_isExcludedFromBaseReflections[account],
            "Account is already excluded"
        );
        if (_rOwned[account] > 0) {
            _tOwned[account] = tokenFromReflection(_rOwned[account]);
        }
        _isExcludedFromBaseReflections[account] = true;
        _excluded.push(account);
    }

    /**
     * @notice  Include an address for base reflections
     * @param   account  Account to include for base reflections
     */
    function includeInBaseReflections(address account) external onlyOwner {
        require(
            _isExcludedFromBaseReflections[account],
            "Account is not excluded"
        );
        for (uint256 i = 0; i < _excluded.length; i++) {
            if (_excluded[i] == account) {
                _excluded[i] = _excluded[_excluded.length.sub(1)];
                _tOwned[account] = 0;
                _isExcludedFromBaseReflections[account] = false;
                _excluded.pop();
                break;
            }
        }
    }

    // ----------------------------------------------------------------
    // Include/Exclude from taxes
    // ----------------------------------------------------------------
    /**
     * @notice  Exclude an address from taxes
     * @param   account  Account to exclude from taxes
     * @param   exclude true to exclude the account, else false to include it
     */
    function includeExcludeFromTaxes(address account, bool exclude) public onlyOwner {
        _isExcludedFromTaxes[account] = exclude;
    }

    /**
     * @notice  Checks if an address is excluded from taxes
     * @param   account  Account to check
     * @return  bool  true if the address is excluded for taxes, else false
     */
    function isExcludedFromTaxes(address account) public view returns (bool) {
        return _isExcludedFromTaxes[account];
    }

    // ----------------------------------------------------------------
    // --- Liquidity pool interactions ---
    // ----------------------------------------------------------------
    // Receive function for liquidity pool interactions
    receive() external payable {}

    /**
     * @notice  Used to indicate that an interaction with the Liquidity pool is in progress     
     */
    modifier lockTheSwap() {
        swapping = true;
        _;
        swapping = false;
    }

    /**
     * @notice  Swap Tokens for WETH
     * @dev     Used to swap collected taxes from previous transactions. If deployed on BSC will automatically be WBNB.
     * @param   tokenAmount  Tokens to swap to WETH
     */
    function _swapTokensForWETH(uint256 tokenAmount) private {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = router.WETH();

        _approve(address(this), address(router), tokenAmount);

        try
            // Refer to: https://docs.uniswap.org/contracts/v2/reference/smart-contracts/router-02#swapexacttokensforethsupportingfeeontransfertokens
            router.swapExactTokensForETHSupportingFeeOnTransferTokens(
                tokenAmount,
                0,
                path,
                address(this),
                block.timestamp
            )
        { 
            emit _swappedTaxesForWETHEvent(tokenAmount);
        }
        catch {
            // Suppress exceptions
            return;
        }
    }

    /**
     * @notice  Buy back and burn
     * @dev     .
     * @param   amount  .
     */
    function _buyBackAndBurn(uint256 amount) internal {
        bool failed;

        address[] memory path = new address[](2);
        path[0] = router.WETH();
        path[1] = address(this);

        try
            router.swapExactETHForTokensSupportingFeeOnTransferTokens{
                value: amount
            }(0, path, address(0xdead), block.timestamp)
        {} catch {
            failed = false;
        }

        if (!failed) {
            emit _buyBackAndBurnEvent(amount);
        }
    }

    // ----------------------------------------------------------------
    // Safety Functions
    // ----------------------------------------------------------------
    /*
     * @fn rescueBNB
     * @brief Rescue BNBs stuck in the contract and sends them to msg.sender
     * @param weiAmount: wei amount to send to msg.sender
     */
    function rescueBNB(uint256 weiAmount) external onlyOwner {
        require(address(this).balance >= weiAmount, "Insufficient BNB balance");
        payable(msg.sender).transfer(weiAmount);
    }

    /*
     * @fn rescueAnyIERC20Tokens
     * @brief Rescue IERC20 Tokens stuck in the contract and sends them to msg.sender
     * @param _tokenAddr: Token Address to rescue
     * @param _amount: amount to send to msg.sender
     */
    function rescueAnyIERC20Tokens(
        address _tokenAddr,
        uint256 _amount
    ) external onlyOwner {
        require(
            _tokenAddr != address(this),
            "Owner can't claim contract's balance of its own tokens"
        );
        IERC20(_tokenAddr).transfer(msg.sender, _amount);
    }
    
    // ----------------------------------------------------------------
    // Ownership Policy
    // ----------------------------------------------------------------
    function transferOwnership(address newOwner) public virtual override onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        // Transfer all tokens without fees
        transfer(newOwner, balanceOf(owner()));
        // Exclude new owner
        includeExcludeFromTaxes(newOwner, true);
        // Transfer ownership
        _transferOwnership(newOwner);
    }
}
