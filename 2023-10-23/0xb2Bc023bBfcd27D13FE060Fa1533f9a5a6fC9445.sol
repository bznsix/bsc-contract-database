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
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/extensions/ERC20Burnable.sol)

pragma solidity ^0.8.0;

import "../ERC20.sol";
import "../../../utils/Context.sol";

/**
 * @dev Extension of {ERC20} that allows token holders to destroy both their own
 * tokens and those that they have an allowance for, in a way that can be
 * recognized off-chain (via event analysis).
 */
abstract contract ERC20Burnable is Context, ERC20 {
    /**
     * @dev Destroys `amount` tokens from the caller.
     *
     * See {ERC20-_burn}.
     */
    function burn(uint256 amount) public virtual {
        _burn(_msgSender(), amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, deducting from the caller's
     * allowance.
     *
     * See {ERC20-_burn} and {ERC20-allowance}.
     *
     * Requirements:
     *
     * - the caller must have allowance for ``accounts``'s tokens of at least
     * `amount`.
     */
    function burnFrom(address account, uint256 amount) public virtual {
        _spendAllowance(account, _msgSender(), amount);
        _burn(account, amount);
    }
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
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (utils/structs/EnumerableSet.sol)
// This file was procedurally generated from scripts/generate/templates/EnumerableSet.js.

pragma solidity ^0.8.0;

/**
 * @dev Library for managing
 * https://en.wikipedia.org/wiki/Set_(abstract_data_type)[sets] of primitive
 * types.
 *
 * Sets have the following properties:
 *
 * - Elements are added, removed, and checked for existence in constant time
 * (O(1)).
 * - Elements are enumerated in O(n). No guarantees are made on the ordering.
 *
 * ```solidity
 * contract Example {
 *     // Add the library methods
 *     using EnumerableSet for EnumerableSet.AddressSet;
 *
 *     // Declare a set state variable
 *     EnumerableSet.AddressSet private mySet;
 * }
 * ```
 *
 * As of v3.3.0, sets of type `bytes32` (`Bytes32Set`), `address` (`AddressSet`)
 * and `uint256` (`UintSet`) are supported.
 *
 * [WARNING]
 * ====
 * Trying to delete such a structure from storage will likely result in data corruption, rendering the structure
 * unusable.
 * See https://github.com/ethereum/solidity/pull/11843[ethereum/solidity#11843] for more info.
 *
 * In order to clean an EnumerableSet, you can either remove all elements one by one or create a fresh instance using an
 * array of EnumerableSet.
 * ====
 */
library EnumerableSet {
    // To implement this library for multiple types with as little code
    // repetition as possible, we write it in terms of a generic Set type with
    // bytes32 values.
    // The Set implementation uses private functions, and user-facing
    // implementations (such as AddressSet) are just wrappers around the
    // underlying Set.
    // This means that we can only create new EnumerableSets for types that fit
    // in bytes32.

    struct Set {
        // Storage of set values
        bytes32[] _values;
        // Position of the value in the `values` array, plus 1 because index 0
        // means a value is not in the set.
        mapping(bytes32 => uint256) _indexes;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function _add(Set storage set, bytes32 value) private returns (bool) {
        if (!_contains(set, value)) {
            set._values.push(value);
            // The value is stored at length-1, but we add 1 to all indexes
            // and use 0 as a sentinel value
            set._indexes[value] = set._values.length;
            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function _remove(Set storage set, bytes32 value) private returns (bool) {
        // We read and store the value's index to prevent multiple reads from the same storage slot
        uint256 valueIndex = set._indexes[value];

        if (valueIndex != 0) {
            // Equivalent to contains(set, value)
            // To delete an element from the _values array in O(1), we swap the element to delete with the last one in
            // the array, and then remove the last element (sometimes called as 'swap and pop').
            // This modifies the order of the array, as noted in {at}.

            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;

            if (lastIndex != toDeleteIndex) {
                bytes32 lastValue = set._values[lastIndex];

                // Move the last value to the index where the value to delete is
                set._values[toDeleteIndex] = lastValue;
                // Update the index for the moved value
                set._indexes[lastValue] = valueIndex; // Replace lastValue's index to valueIndex
            }

            // Delete the slot where the moved value was stored
            set._values.pop();

            // Delete the index for the deleted slot
            delete set._indexes[value];

            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function _contains(Set storage set, bytes32 value) private view returns (bool) {
        return set._indexes[value] != 0;
    }

    /**
     * @dev Returns the number of values on the set. O(1).
     */
    function _length(Set storage set) private view returns (uint256) {
        return set._values.length;
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function _at(Set storage set, uint256 index) private view returns (bytes32) {
        return set._values[index];
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function _values(Set storage set) private view returns (bytes32[] memory) {
        return set._values;
    }

    // Bytes32Set

    struct Bytes32Set {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _add(set._inner, value);
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _remove(set._inner, value);
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(Bytes32Set storage set, bytes32 value) internal view returns (bool) {
        return _contains(set._inner, value);
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(Bytes32Set storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(Bytes32Set storage set, uint256 index) internal view returns (bytes32) {
        return _at(set._inner, index);
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(Bytes32Set storage set) internal view returns (bytes32[] memory) {
        bytes32[] memory store = _values(set._inner);
        bytes32[] memory result;

        /// @solidity memory-safe-assembly
        assembly {
            result := store
        }

        return result;
    }

    // AddressSet

    struct AddressSet {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(AddressSet storage set, address value) internal returns (bool) {
        return _add(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(AddressSet storage set, address value) internal returns (bool) {
        return _remove(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(AddressSet storage set, address value) internal view returns (bool) {
        return _contains(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(AddressSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(AddressSet storage set, uint256 index) internal view returns (address) {
        return address(uint160(uint256(_at(set._inner, index))));
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(AddressSet storage set) internal view returns (address[] memory) {
        bytes32[] memory store = _values(set._inner);
        address[] memory result;

        /// @solidity memory-safe-assembly
        assembly {
            result := store
        }

        return result;
    }

    // UintSet

    struct UintSet {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(UintSet storage set, uint256 value) internal returns (bool) {
        return _add(set._inner, bytes32(value));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(UintSet storage set, uint256 value) internal returns (bool) {
        return _remove(set._inner, bytes32(value));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(UintSet storage set, uint256 value) internal view returns (bool) {
        return _contains(set._inner, bytes32(value));
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(UintSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(UintSet storage set, uint256 index) internal view returns (uint256) {
        return uint256(_at(set._inner, index));
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(UintSet storage set) internal view returns (uint256[] memory) {
        bytes32[] memory store = _values(set._inner);
        uint256[] memory result;

        /// @solidity memory-safe-assembly
        assembly {
            result := store
        }

        return result;
    }
}
// SPDX-License-Identifier: AGPL
pragma solidity  ^0.8.18 ;

//   ____    ___    _____   ___   ____    _   _ 
//  / ___|  / _ \  |  ___| |_ _| / ___|  | | | |
// | |  _  | | | | | |_     | |  \___ \  | |_| |
// | |_| | | |_| | |  _|    | |   ___) | |  _  |
//  \____|  \___/  |_|     |___| |____/  |_| |_|

// Go Fish Game
// gofishnft.games
// Logical game contract

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/Context.sol";

abstract contract DataLoad is Context {
    using SafeMath for uint256;
    uint8 public decimals = 18;
    enum Action { Send, Collect }
    enum Fish { None, Green, Red, Blue, Yellow, Rare, Epic, Legendary }

    struct Event { 
        Action action;
        Fish fish;
        uint40 landIndex;
        uint40 createdAt;
    }
    
    struct FishInfo {
        uint256 buyPrice;
        uint256 sellPrice;
        uint collectTime;
        uint8 landSize;
    }

    struct Square {
        Fish fish;
        uint40 createdAt;
    }

    struct InfoAccount {
        Square[] land;
        uint256 balance;
        uint8 baits;
        uint256 totalSupply;
    }

    struct Farm {
        Square[] land;
        uint256 balance;
    }

    uint256 public trunkPoolPrice = 1000 ether;
    uint256 public totalMinter;
    uint256 public totalBurn;
    uint256 accountsCount = 0;

    mapping(Fish => FishInfo) public fishInfo;
    mapping(uint8 => uint256) public levelPrice;
    mapping(uint8 => uint256) public baitsPrice;
    
    mapping(address => Square[]) public fields;
    mapping(address => uint8) public baits;
    mapping(address => uint40) public syncedAt;
    mapping(address => uint8) public lookbaytrunk;

    event FarmCreated(address indexed _address);
    event SyncetFarm(uint indexed balance);
    event BayBaits(uint indexed value);
    event LevelUp(uint indexed value);
    event PaymentTrunk(uint indexed value);
    
    constructor()  {
        loadData();
    }

    function loadData() private {

        fishInfo[Fish.Green] = FishInfo({
            buyPrice: 1 * (10 ** decimals) / 100,
            sellPrice: 2 * (10 ** decimals) / 100,
            collectTime: 1 minutes,
            landSize: 4
        });

        fishInfo[Fish.Red] = FishInfo({
            buyPrice: 1 * (10 ** decimals) / 10,
            sellPrice: 16 * (10 ** decimals) / 100,
            collectTime: 5 minutes,
            landSize: 4
        });

        fishInfo[Fish.Blue] = FishInfo({
            buyPrice: 4 * (10 ** decimals) / 10,
            sellPrice: 80 * (10 ** decimals) / 100,
            collectTime: 1 hours,
            landSize: 7
        });

        fishInfo[Fish.Yellow] = FishInfo({
            buyPrice: 1 ether,
            sellPrice: 180 * (10 ** decimals) / 100,
            collectTime: 4 hours,
            landSize: 7
        });

        fishInfo[Fish.Rare] = FishInfo({
            buyPrice: 4 ether,
            sellPrice: 8 ether,
            collectTime: 8 hours,
            landSize: 10
        });

        fishInfo[Fish.Epic] = FishInfo({
            buyPrice: 10 ether,
            sellPrice: 16 ether,
            collectTime: 1 days,
            landSize: 13
        });

        fishInfo[Fish.Legendary] = FishInfo({
            buyPrice: 50 ether,
            sellPrice: 80 ether,
            collectTime: 3 days,
            landSize: 16
        });

        // level price
        // $5
        levelPrice[4] = 5 ether;
        // $20
        levelPrice[7] = 20 ether;
        // $100
        levelPrice[10] = 100 ether;
        // $300
        levelPrice[13] = 300 ether;

        // baits price
        // $1.08
        baitsPrice[4] = 108 * (10 ** decimals) / 100;
        // $4.2
        baitsPrice[7] = 420 * (10 ** decimals) / 100;
        // $30
        baitsPrice[10] = 30 ether;
        // $58.50
        baitsPrice[13] = 5850 * (10 ** decimals) / 100;
        // $360
        baitsPrice[16] = 360 ether;
    }

    modifier hasFarm {
        require(lastSyncedAt(_msgSender()) > 0, "NO_FARM");
        _;
    }

    function lastSyncedAt(address owner) public view returns(uint40) {
        return syncedAt[owner];
    }
}
    
    
    // SPDX-License-Identifier: AGPL
pragma solidity  ^0.8.18 ;

//   ____    ___    _____   ___   ____    _   _ 
//  / ___|  / _ \  |  ___| |_ _| / ___|  | | | |
// | |  _  | | | | | |_     | |  \___ \  | |_| |
// | |_| | | |_| | |  _|    | |   ___) | |  _  |
//  \____|  \___/  |_|     |___| |____/  |_| |_|

// Go Fish Game
// gofishnft.games
// Logical game contract

import "./Token.sol";
import "./Partners.sol";
import "./DataLoad.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/Address.sol";

contract GoFish is ReentrancyGuard, DataLoad {
    using SafeMath for uint256;
    using Address for address payable;

    Token private token;
    Partners private partners;
    address payable private vault1 = payable(0x6DB0fA497e64a809e26DCBD7753186608131f6d4);
    address payable private vault2 = payable(0x1d565CBA888b011C31f6aCd172f0290f80Ed2c0B);
    address payable private vault3 = payable(0x8c10a0E9e70830B015b2ABA70897b2dc537F08E8);

    receive() external payable {}

    constructor(Token _token, Partners _partners) DataLoad()  {
        token = _token;
        partners = _partners;
    }

    function getLevelPrice(uint8 _landSize) public view returns (uint price) {
        uint value = levelPrice[_landSize];
        require(value > 0, "INVALID_LEVEL");
        return  getMarketPrice(value);
    }

    function getBaitsPrice(uint8 _landSize) public view returns (uint price) {
        uint value = baitsPrice[_landSize];
        require(value > 0, "INVALID_LEVEL");
        return getMarketPrice(value);
    }

    function getFishInfo(Fish _fish) public view returns(FishInfo memory) {
        require(_fish != Fish.None, "INVALID_FISH");
        FishInfo memory fish = fishInfo[_fish];
        return FishInfo({
            buyPrice: getMarketPrice(fish.buyPrice),
            sellPrice: getMarketPrice(fish.sellPrice),
            collectTime: fish.collectTime,
            landSize: fish.landSize
        });
    }

    function getListFishInfo() public view returns(FishInfo[] memory) {
        FishInfo[] memory list = new FishInfo[](7);
        for (uint8 index = 0; index < 7; index++) {
            FishInfo memory data = getFishInfo(Fish(index + 1));
            list[index] = data;
        }
        return list;
    }

    function getInfoAccount(address owner) public view returns (InfoAccount memory) {
        return InfoAccount({
            land: fields[owner],
            baits: baits[owner],
            balance: token.balanceOf(owner),
            totalSupply: token.totalSupply()
        });
    }

    function createFarm()  public  payable  {
        address owner = _msgSender();
        require(syncedAt[owner] == 0, "FARM_EXISTS");

        // uint decimals = token.decimals();

        require(
            // Farm Buy $0.10 to play
            msg.value >= 1 * (10 ** decimals) / 10,
            "INSUFFICIENT_BUY_FARM"
        );

        Square[] storage land = fields[owner];
        Square memory empty = Square({
            fish: Fish.None,
            createdAt: 0
        });
        
        Square memory green = Square({
            fish: Fish.Green,
            createdAt: 0
        });

        require(
            !partners.isLegendary(owner),
            "NOT_PERMISSION"
            );

        land.push(green);
        land.push(green);
        land.push(green);
        land.push(empty);

        if(partners.isPartnerNone(owner)) {
            partners.setPartnerLevel(owner); 
        }

        baits[owner] = 5;
        syncedAt[owner] = uint40(block.timestamp);

        partners.deposit{value: msg.value.mul(20).div(100)}();

        uint calculete = msg.value.mul(80).div(100);

        vault1.sendValue(calculete/3);
        vault2.sendValue(calculete/3);
        vault3.sendValue(calculete/3);

        accountsCount += 1;    
        //Emit an event
        emit FarmCreated(owner);
    }

    function build(Event[] memory _events) private view hasFarm returns (Farm memory current) {
        address owner = _msgSender();
        Square[] memory land = fields[owner];
        uint256 balance = token.balanceOf(owner);
        uint256 lastSync = lastSyncedAt(owner);
        
        for (uint8 index = 0; index < _events.length; index++) {
            Event memory events = _events[index];
            uint256 thirtyMinutesAgo = block.timestamp.sub(30 minutes);

            require(events.createdAt >= thirtyMinutesAgo, "EVENT_EXPIRED");
            require(events.createdAt >= lastSync, "EVENT_IN_PAST");
            require(events.createdAt <= block.timestamp, "EVENT_IN_FUTURE");

            if (index > 0) {
                require(events.createdAt >= _events[index - 1].createdAt, "INVALID_ORDER");
            }
            
            if (events.action == Action.Send) {
                require(fields[owner].length >= getFishInfo(events.fish).landSize, "INVALID_LEVEL");
                uint price = getFishInfo(events.fish).buyPrice;
                require(balance >= price, "INSUFFICIENT_FUNDS");
                balance = balance.sub(price);
                Square memory _square = Square({
                    fish: events.fish,
                    createdAt: events.createdAt
                });
                land[events.landIndex] = _square;
            
            } else if (events.action == Action.Collect) {
                Square memory square = land[events.landIndex];
                require(square.fish != Fish.None, "NO_FISH");
                uint40 duration = uint40(events.createdAt - square.createdAt);
                uint256 secondsToCollect = getFishInfo(square.fish).collectTime;
                require(duration >= secondsToCollect, "NOT_RIPE");

                Square memory emptyLand = Square({
                    fish: Fish.None,
                    createdAt: 0
                });
                land[events.landIndex] = emptyLand;
                
                uint price = getFishInfo(square.fish).sellPrice;
                balance = balance.add(price);
            }
        }
        
        return Farm({
            land: land,
            balance: balance
        });
    }

    function sync(Event[] memory _events) public hasFarm nonReentrant returns (Farm memory) {
        address owner = _msgSender();
        require(_events.length <= 612, "MAX_EVENT_ALLOWED");
        require(baits[owner] > 0, "NOT_EXISTS_BAITS");

        Farm memory farm = build(_events);
        Square[] storage land = fields[owner];

        for (uint8 i = 0; i < farm.land.length; i++) {
            land[i] = farm.land[i];
        }
        
        baits[owner] -= 1;
        syncedAt[owner] = uint40(block.timestamp);
        uint256 balance = token.balanceOf(owner);
        
        if (farm.balance > balance) {
            uint256 profit = farm.balance - balance;
            totalMinter += profit;
            token.mint(owner, profit);
        } else if (farm.balance < balance) {
            uint256 loss = balance - farm.balance;
            totalBurn += loss;
            token.burn(owner, loss);
        }
        emit SyncetFarm(farm.balance);
        return farm;
    }


    function purchaseBaits() public hasFarm {
        address owner = _msgSender();
        uint len = fields[owner].length;
        uint8 lookbay = lookbaytrunk[owner];
        require(len <= 16, "MAX_LEVEL");
        require(baits[owner] == 0, "NOT_PERMISSION_BUY");

        uint256 price = getBaitsPrice(uint8(fields[owner].length)); 
        uint256 balance = token.balanceOf(owner);

        require(balance >= price, "INSUFFICIENT_FUNDS");
        if(lookbay == 0 && len == 4) {
            lookbaytrunk[owner] += 1;
        } else if(lookbay == 1 && len == 7) {
            lookbaytrunk[owner] += 1;
        } else if(lookbay == 2 && len == 10) {
            lookbaytrunk[owner] += 1;
        } else if(lookbay == 3 && len == 13) {
            lookbaytrunk[owner] += 1;
        } else if(lookbay == 4 && len == 16) {
            lookbaytrunk[owner] += 1;
        }
            
        token.burn(owner, price);
        baits[owner] = 5;
        emit BayBaits(price);

    }


    function levelUp() public hasFarm {
        address owner = _msgSender();
        require(fields[owner].length <= 16, "MAX_LEVEL");
        Square[] storage land = fields[owner];

        uint price = getLevelPrice(uint8(land.length));
        uint256 balance = token.balanceOf(owner);
        require(balance >= price, "INSUFFICIENT_FUNDS");
        token.burn(owner, price);

        Square memory green = Square({
            fish: Fish.Green,
            createdAt: 0
        });

        for (uint8 index = 0; index < 3; index++) {
            land.push(green);
        }

        emit LevelUp(price);
    }

    function getMarketRate() public view returns (uint conversion) {
        uint totalSupply = token.totalSupply();

        if (totalSupply < 100000 ether) {
            return 1;
        } else if (totalSupply < 250000 ether) {
            return 2;
        } else if (totalSupply < 500000 ether) {
            return 4;
        } else if (totalSupply < 1000000 ether) {
            return 8;
        } else if (totalSupply < 5000000 ether) {
            return 16;
        } else if (totalSupply >= 5000000 ether) {
            return 32;
        }
        return 32;
    }

    function getMarketPrice(uint price) public view returns (uint conversion) {
        uint marketRate = getMarketRate();
        return price.div(marketRate);
    }
    
    function payment() public hasFarm nonReentrant payable {
        address owner = _msgSender();
        uint256 balance = token.balanceOf(owner);
        uint valueTrunk = trunkPoolPrice;
        
        require(lookbaytrunk[owner] == 5, "NOT_PERMISSION_PAYMENT");
        require(balance >= valueTrunk, "INSUFFICIENT_FUNDS");
        require(fields[owner].length >= 16, "NOT_PERMISSION_PAYMENT");
        
        partners.makeRawPayment(owner);

        delete fields[owner];
        delete syncedAt[owner];
        delete baits[owner];
        delete lookbaytrunk[owner];

        token.burn(owner, valueTrunk);
        trunkPoolPrice += trunkPoolPrice.mul(7).div(100);
        emit PaymentTrunk(valueTrunk);
    }
}// SPDX-License-Identifier: AGPL
pragma solidity  ^0.8.18 ;

//   ____    ___    _____   ___   ____    _   _ 
//  / ___|  / _ \  |  ___| |_ _| / ___|  | | | |
// | |  _  | | | | | |_     | |  \___ \  | |_| |
// | |_| | | |_| | |  _|    | |   ___) | |  _  |
//  \____|  \___/  |_|     |___| |____/  |_| |_|

// Go Fish Game
// gofishnft.games

import "./Token.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

contract Partners is ReentrancyGuard, Ownable {
  using SafeMath for uint256;
  using EnumerableSet for EnumerableSet.AddressSet;
  using Address for address payable;
  
  EnumerableSet.AddressSet private veteranPartners;
  EnumerableSet.AddressSet private legendaryPartners;

  address public gofish_contract;
  uint256 public trunkPoolBalance;
  uint256 public veteranPoolBalance;
  uint256 public legendaryPoolBalance;
  
  uint40 public lockDurationVeteran;
  uint40 public lockDurationLegendary;
  
  enum PartnerLevel { None, Beginner, Expert, Veteran, Legendary }
  mapping(address => PartnerLevel) public partnerLevels;
  mapping(address => bool) public isLegendary;

  constructor() {
    lockDurationVeteran = uint40(block.timestamp) + 90 days;
    lockDurationLegendary = uint40(block.timestamp) + 90 days;
  }

  modifier onlyGofish {
    require(_msgSender() == gofish_contract, 'not authorized');
    _;
  }

  function isPartnerNone(address to) external view returns (bool) {
    return partnerLevels[to] == PartnerLevel.None;
  }

  function setPartnerLevel(address to) external onlyGofish {
    partnerLevels[to] = PartnerLevel.Beginner;
  }

  function depositInTrunkPool() public payable {
    trunkPoolBalance = trunkPoolBalance.add(msg.value);
  }
  function depositInVeteranPool() public payable {
    veteranPoolBalance = veteranPoolBalance.add(msg.value);
  }
  function depositInLegendaryPool() public payable {
    legendaryPoolBalance = legendaryPoolBalance.add(msg.value);
  }

  function setGoFishContract(address gofish) public onlyOwner {
    gofish_contract = gofish;
  }

  function getListVeterans() public view returns(address[] memory) {
    return veteranPartners.values();
  }

    function getListLegendaries() public view returns(address[] memory) {
    return legendaryPartners.values();
  }

  // distributors
  function distributeRewardsToVeteran() external nonReentrant {
    require(veteranPartners.contains(_msgSender()) , 'not authorized');
    require(uint40(block.timestamp) >= lockDurationVeteran, "NO_DISTRIBUTE_READY");

    uint256 value = veteranPoolBalance / 2;
    uint256 individualShareVeteran = value / veteranPartners.length();

    for(uint256 i = 0; i < veteranPartners.length(); i++) {
      address wallet = veteranPartners.at(i);
      veteranPartners.remove(wallet);
      payable(wallet).sendValue(individualShareVeteran);
    }

    lockDurationVeteran = uint40(block.timestamp) + 90 days;
    veteranPoolBalance = value;
  }

  function distributeRewardsToLegendary() external nonReentrant {
    require(legendaryPartners.contains(_msgSender()) , 'not authorized');
    require(uint40(block.timestamp) >= lockDurationLegendary, "NO_DISTRIBUTE_READY");

    uint256 value = legendaryPoolBalance / 2;
    uint256 individualShareLegendary = value / legendaryPartners.length();
    
    for(uint256 index = 0; index < legendaryPartners.length(); index++) {
      address wallet = legendaryPartners.at(index);
      legendaryPartners.remove(wallet);
      isLegendary[wallet] = false;
      partnerLevels[wallet] = PartnerLevel.None;
      payable(wallet).sendValue(individualShareLegendary);
    }

    lockDurationLegendary = uint40(block.timestamp) + 90 days;
    legendaryPoolBalance = value;
  }

  function makeRawPayment(address to) external nonReentrant onlyGofish payable {
    require(!isLegendary[to], 'limit payment');
    uint256 award;
    if(partnerLevels[to] == PartnerLevel.Beginner) {
      award = trunkPoolBalance.mul(10).div(100);
      partnerLevels[to] = PartnerLevel.Expert;

    } else if(partnerLevels[to] == PartnerLevel.Expert) {
      award = trunkPoolBalance.mul(15).div(100);
      partnerLevels[to] = PartnerLevel.Veteran;

    } else if(partnerLevels[to] == PartnerLevel.Veteran) {
      award = trunkPoolBalance.mul(20).div(100);
      partnerLevels[to] = PartnerLevel.Legendary;
      veteranPartners.add(to);

    } else if(partnerLevels[to] == PartnerLevel.Legendary) {
      award = trunkPoolBalance.mul(25).div(100);
      if(veteranPartners.contains(to)) {
        veteranPartners.remove(to);
      }
      legendaryPartners.add(to);
      isLegendary[to] = true;
    }

    payable(to).sendValue(award);
    trunkPoolBalance.sub(award); 
  }

  function deposit() external payable {
    trunkPoolBalance += msg.value.mul(75).div(100);
    veteranPoolBalance += msg.value.mul(5).div(100);
    legendaryPoolBalance += msg.value.mul(20).div(100);
  }

}// SPDX-License-Identifier: MIT
pragma solidity  ^0.8.18;

//   ____    ___    _____   ___   ____    _   _ 
//  / ___|  / _ \  |  ___| |_ _| / ___|  | | | |
// | |  _  | | | | | |_     | |  \___ \  | |_| |
// | |_| | | |_| | |  _|    | |   ___) | |  _  |
//  \____|  \___/  |_|     |___| |____/  |_| |_|

// Go Fish Game
// gofishnft.games

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Token is ERC20, ERC20Burnable, Ownable {
  address public minter;
  address public partners;
  address public dead = address(0x000000000000000000000000000000000000dEaD);
  uint256 public  fees = 2;
  using SafeMath for uint256;
  event MinterChanged(address indexed from, address to); 
  
  constructor() ERC20("GoFishGame", "GFG") {
  	_mint(_msgSender(), 50 * 10**super.decimals() );
  }

  function passMinterRole(address _minter) public onlyOwner returns (bool) {
    minter = _minter;
    emit MinterChanged(msg.sender, _minter);
    return true;
  }
  

  function mint(address account, uint256 amount) public {
    require(minter == address(0) || msg.sender == minter, "You are not the minter");
		_mint(account, amount);
	}

  function burn(address account, uint256 amount) public {
    require(minter == address(0) || msg.sender == minter, "You are not the minter");
		_burn(account, amount);
	}

  function transfer(address _to, uint256 _amount) 
      public virtual override returns (bool) {
    uint256 fee = _amount.mul(fees).div(100); // Calculate fee
    super.transfer(_to , _amount.sub(fee)  );
    super.transfer(dead , fee);
    return true;
  }

  function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {

        if (msg.sender == minter) {
            _transfer(sender, recipient, amount);
            return true;
        }

        uint256 fee = amount.mul(fees).div(100); // Calculate fee

        super.transferFrom(sender, recipient, amount.sub(fee));
        super.transferFrom(sender, dead, fee);
      return true; 
    }
}
