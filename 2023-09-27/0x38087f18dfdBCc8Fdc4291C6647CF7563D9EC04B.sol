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
// OpenZeppelin Contracts (last updated v4.7.0) (security/Pausable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
abstract contract Pausable is Context {
    /**
     * @dev Emitted when the pause is triggered by `account`.
     */
    event Paused(address account);

    /**
     * @dev Emitted when the pause is lifted by `account`.
     */
    event Unpaused(address account);

    bool private _paused;

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
        require(!paused(), "Pausable: paused");
    }

    /**
     * @dev Throws if the contract is not paused.
     */
    function _requirePaused() internal view virtual {
        require(paused(), "Pausable: not paused");
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
// OpenZeppelin Contracts v4.4.1 (utils/Counters.sol)

pragma solidity ^0.8.0;

/**
 * @title Counters
 * @author Matt Condon (@shrugs)
 * @dev Provides counters that can only be incremented, decremented or reset. This can be used e.g. to track the number
 * of elements in a mapping, issuing ERC721 ids, or counting request ids.
 *
 * Include with `using Counters for Counters.Counter;`
 */
library Counters {
    struct Counter {
        // This variable should never be directly accessed by users of the library: interactions must be restricted to
        // the library's function. As of Solidity v0.5.2, this cannot be enforced, though there is a proposal to add
        // this feature: see https://github.com/ethereum/solidity/issues/4637
        uint256 _value; // default: 0
    }

    function current(Counter storage counter) internal view returns (uint256) {
        return counter._value;
    }

    function increment(Counter storage counter) internal {
        unchecked {
            counter._value += 1;
        }
    }

    function decrement(Counter storage counter) internal {
        uint256 value = counter._value;
        require(value > 0, "Counter: decrement overflow");
        unchecked {
            counter._value = value - 1;
        }
    }

    function reset(Counter storage counter) internal {
        counter._value = 0;
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
//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "./MultiMetaLife.sol";
import "./PriceOracle.sol";

contract AtomicSwap is Ownable, Pausable, ReentrancyGuard {
  struct LockedBalance {
    uint64 start;
    uint256 amount;
    bool claimed;
  }
  struct Account {
    uint64 last;
    address ref;
    uint256 balance;
    uint256 lockedBalanceCount;
    mapping(uint256 => LockedBalance) lockedBalance;
  }
  struct Pair {
    uint256 min;
    uint256 max;
    bool active;
  }

  MultiMetaLife public token;
  PriceOracle public priceOracle;

  uint24[7] public levels = [12, 8, 6, 4, 3, 2, 1];
  uint64 public lockDuration;
  uint64 public activeDuration;

  mapping(address => Pair) public whitelist;
  mapping(address => Account) public balance;

  error NotAllowed();
  error AlreadyClaimed();
  error RefIsInvalid();
  error AccountRegistered();
  error AccountNotRegistered();

  modifier validateAccount() {
    if (balance[msg.sender].last == 0) {
      revert AccountNotRegistered();
    }
    _;
  }

  constructor(
    address head,
    address _token,
    address _priceOracle,
    uint64 _lockDuration,
    uint64 _activeDuration
  ) {
    token = MultiMetaLife(_token);
    priceOracle = PriceOracle(_priceOracle);
    lockDuration = _lockDuration;
    activeDuration = _activeDuration;
    balance[head].last = uint64(block.timestamp);
  }

  function isRegister(address _address) external view returns (bool) {
    return balance[_address].last > 0;
  }

  function isActive(address _address) external view returns (bool) {
    return balance[_address].last + activeDuration > block.timestamp;
  }

  function getLockedBalance(
    address _address,
    uint256 index
  ) external view returns (LockedBalance memory) {
    require(
      index < balance[_address].lockedBalanceCount,
      "contract address already exists"
    );
    return balance[_address].lockedBalance[index];
  }

  function calculateSwap(
    uint256 _amount,
    address _token
  ) external view returns (uint256) {
    require(whitelist[_token].active, "token is not active");
    require(_amount > 0, "No ETH sent");

    uint256 value = priceOracle.purchase(_token, _amount);

    return value;
  }

  function calculateSell(
    uint256 _amount,
    address _token
  ) external view returns (uint256) {
    require(whitelist[_token].active, "token is not active");
    require(_amount > 0, "No ETH sent");

    uint256 value = priceOracle.sell(_amount, _token);

    return value;
  }

  function swapAndRegister(address _ref) external payable {
    _register(_ref);
    _swap();
  }

  function swap() external payable validateAccount {
    _swap();
  }

  function sell(uint256 _amount) external payable {
    _sell(msg.sender, _amount);
  }

  function sellForToken(address _token, uint256 _amount) external {
    _sellToken(msg.sender, _amount, _token);
  }

  function swapTokenAndRegister(
    address _ref,
    uint256 _amount,
    address _token
  ) external {
    _register(_ref);
    _swapToken(_amount, _token);
  }

  function swapToken(uint256 _amount, address _token) external validateAccount {
    _swapToken(_amount, _token);
  }

  function clearBalance(uint64 index) external {
    _removeLockedBalance(msg.sender, index);
  }

  function clearBalances(uint64[] memory indexes) external {
    for (uint256 i = 0; i < indexes.length; i++) {
      _removeLockedBalance(msg.sender, indexes[i]);
    }
  }

  function isClear(
    address _address,
    uint256 index
  ) external view returns (bool) {
    require(
      index < balance[_address].lockedBalanceCount,
      "contract address already exists"
    );
    LockedBalance memory _lockedBalance = balance[_address].lockedBalance[
      index
    ];
    return _lockedBalance.start + lockDuration < block.timestamp;
  }

  function unpause() external onlyOwner {
    return super._unpause();
  }

  function pause() external onlyOwner {
    return super._pause();
  }

  function updateLockDuration(uint64 _lockDuration) external onlyOwner {
    emit LockDurationUpdated(lockDuration, _lockDuration);
    lockDuration = _lockDuration;
  }

  function updateActiveDuration(uint64 _activeDuration) external onlyOwner {
    emit ActiveDurationUpdated(activeDuration, _activeDuration);
    activeDuration = _activeDuration;
  }

  function addPair(
    address _token,
    uint256 _min,
    uint256 _max
  ) external onlyOwner {
    whitelist[_token] = Pair(_min, _max, true);
    emit PairAdded(_token, _min, _max);
  }

  function deactivePair(address _token) external onlyOwner {
    whitelist[_token].active = false;
    emit PairDeactivated(_token);
  }

  function _swap() internal {
    require(msg.value > 0, "Send some tokens");

    uint256 value = priceOracle.purchase(address(0), msg.value);
    _mmlTransfer(msg.sender, value);

    emit Swap(msg.sender, msg.value, value);
  }

  function _swapToken(uint256 _amount, address _token) internal {
    require(whitelist[_token].active, "token is not active");
    require(_amount > 0, "No ETH sent");

    uint256 value = priceOracle.purchase(_token, _amount);
    bool res = ERC20(_token).transferFrom(msg.sender, address(this), _amount);
    require(res, "Failed to transfer token");
    _mmlTransfer(msg.sender, value);

    emit SwapToken(msg.sender, _token, _amount, value);
  }

  function _sell(address _from, uint256 _amount) internal nonReentrant {
    require(_amount > 0, "Send some tokens");
    uint256 tokenBalance = token.balanceOf(_from);
    require(tokenBalance >= _amount, "Insufficient locked token");

    bool res = token.transferFrom(_from, address(this), _amount);
    require(res, "Failed to transfer token");
    uint256 value = priceOracle.sell(_amount, address(0));
    Address.sendValue(payable(_from), value);

    emit Sell(_from, _amount, value);
  }

  function _sellToken(address _from, uint256 _amount, address _token) internal {
    require(whitelist[_token].active, "token is not active");
    require(_amount > 0, "Send some tokens");

    bool res = token.transferFrom(_from, address(this), _amount);
    require(res, "Failed to transfer token");
    uint256 value = priceOracle.sell(_amount, _token);

    bool res2 = ERC20(_token).transfer(_from, value);
    require(res2, "Failed to transfer second token");

    emit SellToken(_from, _token, _amount, value);
  }

  function _mmlTransfer(
    address _reciever,
    uint256 value
  ) internal nonReentrant whenNotPaused {
    uint256 tokenBalance = token.balanceOf(address(this));
    require(tokenBalance >= value, "Insufficient locked token");

    uint256 refsShare = _payRefs(_reciever, value);
    uint buyShare = value - refsShare;
    _addLockedBalance(_reciever, buyShare);
    token.transfer(_reciever, buyShare);
    balance[_reciever].last = uint64(block.timestamp);
  }

  function _payRefs(
    address _address,
    uint256 _amount
  ) internal returns (uint256 totalShare) {
    address _ref = balance[_address].ref;
    for (uint256 i = 0; i < 7; i++) {
      if (_ref != address(0)) {
        if (balance[_ref].last + activeDuration > block.timestamp) {
          uint256 share = (levels[i] * _amount) / 100;
          totalShare += share;
          token.transfer(_ref, share);
        }
        _ref = balance[_ref].ref;
      } else {
        return totalShare;
      }
    }
  }

  function _addLockedBalance(address _address, uint256 _amount) internal {
    Account storage account = balance[_address];
    uint256 index = account.lockedBalanceCount;
    uint64 timestamp = uint64(block.timestamp);

    account.lockedBalance[index] = LockedBalance(timestamp, _amount, false);
    account.lockedBalanceCount = account.lockedBalanceCount + 1;
    account.balance += _amount;
    emit LockedBalanceAdded(_address, _amount, index);
  }

  function _removeLockedBalance(address _address, uint256 index) internal {
    LockedBalance storage _lockedBalance = balance[_address].lockedBalance[
      index
    ];
    if (_lockedBalance.start + lockDuration > block.timestamp) {
      revert NotAllowed();
    }
    if (_lockedBalance.claimed) {
      revert AlreadyClaimed();
    }

    _lockedBalance.claimed = true;
    balance[_address].balance -= _lockedBalance.amount;
    emit LockedBalanceCleared(_address, _lockedBalance.amount, index);
  }

  function _register(address _ref) internal {
    if (balance[_ref].last == 0) {
      revert RefIsInvalid();
    }

    Account storage account = balance[msg.sender];
    if (account.ref != address(0)) {
      revert AccountRegistered();
    }
    account.ref = _ref;
    emit Register(_ref, msg.sender);
  }

  event Register(address indexed ref, address account);
  event Swap(address indexed receiver, uint256 amount, uint256 value);
  event SwapToken(
    address indexed receiver,
    address indexed token,
    uint256 amount,
    uint256 value
  );

  event Sell(address indexed from, uint256 amount, uint256 value);
  event SellToken(
    address indexed from,
    address indexed token,
    uint256 amount,
    uint256 value
  );

  event PairAdded(address token, uint256 min, uint256 max);
  event PairDeactivated(address token);

  event LockedBalanceAdded(
    address indexed receiver,
    uint256 value,
    uint256 index
  );
  event LockedBalanceCleared(
    address indexed receiver,
    uint256 value,
    uint256 index
  );

  event LockDurationUpdated(uint64 prvValue, uint64 newValue);
  event ActiveDurationUpdated(uint64 prvValue, uint64 newValue);
}
//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.4;

interface IFeed {
    function balanceOf(address account) external view returns (uint256);

    function updator() external returns (address);

    function subscribeFee() external returns (uint256);

    function getCoinIndex(
        string calldata name,
        string calldata symbol
    ) external view returns (uint256);

    function coinsCount() external returns (uint256);

    function updatePrices(
        uint256[] calldata index,
        uint256[] calldata newPrice,
        uint256[] calldata newTimestamp
    ) external;

    function updatePrice(
        uint256 index,
        uint128 newPrice,
        uint128 timestamp
    ) external;

    function updateOracleUpdaterAddress(address newUpdator) external;

    function getCoinPrice(
        uint256 index
    ) external view returns (uint128, uint128);

    function getCoinInfo(
        uint256 index
    ) external view returns (string memory, string memory);

    function tokenAddress() external view returns (address);

    function addCoin(
        string calldata name,
        string calldata symbol,
        uint256 price
    ) external returns (uint256);

    function setSubscribeFee(uint256 newSubscribeFee) external;

    function subscribe(address account, uint256 blocks) external returns (bool);

    event CoinUpdated(string name, string symbol, uint256 index, uint256 price);
    event PriceUpdated(uint256 index, uint128 price, uint128 timestamp);
    event PricesUpdated(uint256[] index, uint256[] price, uint256[] timestamp);
    event SubscribeFeeUpdated(uint256 fee);
}
// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.4;

interface IPancakeRouter01 {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB, uint256 liquidity);

    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    )
        external
        payable
        returns (uint256 amountToken, uint256 amountETH, uint256 liquidity);

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETH(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountToken, uint256 amountETH);

    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETHWithPermit(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountToken, uint256 amountETH);

    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapTokensForExactTokens(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactETHForTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function swapTokensForExactETH(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactTokensForETH(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapETHForExactTokens(
        uint256 amountOut,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function quote(
        uint256 amountA,
        uint256 reserveA,
        uint256 reserveB
    ) external pure returns (uint256 amountB);

    function getAmountOut(
        uint256 amountIn,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountOut);

    function getAmountIn(
        uint256 amountOut,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountIn);

    function getAmountsOut(
        uint256 amountIn,
        address[] calldata path
    ) external view returns (uint256[] memory amounts);

    function getAmountsIn(
        uint256 amountOut,
        address[] calldata path
    ) external view returns (uint256[] memory amounts);
}
//SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

interface IPriceOracle {
    /**
     * @dev Returns the mml amount of sent tokens
     * @param token The address of target pair.
     * @param amount mml token amount.
     * @return price final price in mml
     */
    function purchase(
        address token,
        uint256 amount
    ) external view returns (uint);

    /**
     * @dev Returns the price of mml amount
     * @param amount mml token amount.
     * @param token The address of target pair.
     * @return price final price of mml amount
     */
    function sell(uint256 amount, address token) external view returns (uint);
}
//SPDX-License-Identifier: Unlicense

pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "./MultiMetaLife.sol";

contract MMLStaking is Ownable, Pausable, ReentrancyGuard {
  struct Stake {
    uint256 amount;
    uint32 plan;
    address owner;
    uint64 start;
    uint64 claim;
    bool active;
  }

  struct Plan {
    uint64 unstakeLockDuration;
    uint32 rewardPercentagePerPeriod;
    uint64 calculateRewardPeriod;
    uint256 minAmount;
    uint256 maxAmount;
  }

  bool public isStakingPaused;
  MultiMetaLife public token;
  uint public stakesCount;
  mapping(uint => Stake) public stakes;
  mapping(address => uint) public balanceOf;
  Plan[] public plans;

  modifier stakeIsValid(address _address, uint256 _stakeIndex) {
    Stake memory _stake = stakes[_stakeIndex];
    require(_stake.owner == _address, "Unauthorized stake");
    require(_stake.active == true, "Stake is not active");
    _;
  }

  modifier whenStakingNotDisalbed() {
    require(!isStakingPaused, "Staking is disabled");
    _;
  }

  constructor(MultiMetaLife _token) {
    token = _token;
  }

  function getAllPlans() public view returns (Plan[] memory) {
    return plans;
  }

  function calculateReward(
    uint256 _stakeIndex
  ) public view returns (uint256 _rewardAmount) {
    Stake storage _stake = stakes[_stakeIndex];
    if (!_stake.active) {
      return 0;
    }
    Plan memory _plan = plans[_stake.plan];

    _rewardAmount = _calculateReward(
      _stake.amount,
      _stake.claim,
      block.timestamp,
      _plan.rewardPercentagePerPeriod,
      _plan.calculateRewardPeriod
    );
  }

  function stake(
    uint256 _amount,
    uint32 _planIndex
  ) external whenNotPaused whenStakingNotDisalbed nonReentrant {
    require(_amount > 0, "Staking amount should be greater than 0");
    require(token.balanceOf(msg.sender) >= _amount, "Insufficient fund");
    Plan memory selectedPlan = plans[_planIndex];
    require(
      _amount >= selectedPlan.minAmount && _amount <= selectedPlan.maxAmount,
      "Invalid staking amount for the selected plan"
    );

    token.transferFrom(msg.sender, address(this), _amount);

    uint256 stakeIndex = stakesCount;
    stakes[stakeIndex] = Stake({
      amount: _amount,
      plan: _planIndex,
      owner: msg.sender,
      start: uint64(block.timestamp),
      claim: uint64(block.timestamp),
      active: true
    });

    unchecked {
      stakesCount++;
      balanceOf[msg.sender] += _amount;
    }
    emit Staked(msg.sender, _planIndex, _amount, stakeIndex);
  }

  function unstake(
    uint256 _stakeIndex
  ) external whenNotPaused nonReentrant stakeIsValid(msg.sender, _stakeIndex) {
    Stake storage _stake = stakes[_stakeIndex];
    Plan memory _plan = plans[_stake.plan];
    require(_stake.start + _plan.unstakeLockDuration < block.timestamp);

    uint256 _rewardAmount = _calculateReward(
      _stake.amount,
      _stake.claim,
      block.timestamp,
      _plan.rewardPercentagePerPeriod,
      _plan.calculateRewardPeriod
    );
    if (_rewardAmount > 0) {
      claimReward(_stakeIndex);
    }

    _stake.active = false;

    unchecked {
      balanceOf[msg.sender] -= _stake.amount;
    }
    emit Unstaked(_stakeIndex);
  }

  function claimReward(
    uint256 _stakeIndex
  ) public whenNotPaused stakeIsValid(msg.sender, _stakeIndex) {
    Stake storage _stake = stakes[_stakeIndex];
    Plan memory _plan = plans[_stake.plan];

    uint256 _rewardAmount = _calculateReward(
      _stake.amount,
      _stake.claim,
      block.timestamp,
      _plan.rewardPercentagePerPeriod,
      _plan.calculateRewardPeriod
    );

    require(_rewardAmount > 0, "No rewards to claim");

    uint256 balance = token.balanceOf(address(this));
    require(balance >= _rewardAmount, "Not enough balance in treasury");

    token.transfer(msg.sender, _rewardAmount);
    _stake.claim = uint64(block.timestamp);
    emit RewardClaimed(_stakeIndex, _rewardAmount);
  }

  function addPlan(
    uint64 _unstakeLockDuration,
    uint32 _rewardPercentagePerPeriod,
    uint64 _calculateRewardPeriod,
    uint256 _minAmount,
    uint256 _maxAmount
  ) external onlyOwner {
    uint index = plans.length;
    plans.push(
      Plan(
        _unstakeLockDuration,
        _rewardPercentagePerPeriod,
        _calculateRewardPeriod,
        _minAmount,
        _maxAmount
      )
    );
    emit PlanAdded(
      index,
      _unstakeLockDuration,
      _rewardPercentagePerPeriod,
      _calculateRewardPeriod,
      _minAmount,
      _maxAmount
    );
  }

  function unpause() external onlyOwner {
    return super._unpause();
  }

  function pause() external onlyOwner {
    return super._pause();
  }

  function changeStakeStatus(bool _active) external onlyOwner {
    isStakingPaused = _active;
  }

  function _calculateReward(
    uint256 amount,
    uint256 start,
    uint256 end,
    uint256 rewardPercentagePerPeriod,
    uint64 calculateRewardPeriod
  ) public pure returns (uint256) {
    return
      (amount *
        rewardPercentagePerPeriod *
        ((end - start) / calculateRewardPeriod)) / 10000;
  }

  event Staked(
    address indexed _address,
    uint32 _planIndex,
    uint256 _amount,
    uint256 _stakeIndex
  );
  event Unstaked(uint256 _stakeIndex);
  event RewardClaimed(uint256 _stakeIndex, uint256 _amount);

  event PlanAdded(
    uint256 index,
    uint64 unstakeLockDuration,
    uint32 rewardPercentagePerPeriod,
    uint64 calculateRewardPeriod,
    uint256 minAmount,
    uint256 maxAmount
  );
}
//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "./AtomicSwap.sol";
import "./MMLStaking.sol";

contract MultiMetaLife is ERC20, Ownable {
  uint public MAX_SUPPLY = 54_100_000 ether;
  uint public advisorShare = (MAX_SUPPLY * 1) / 20;
  uint public reserveShare = (MAX_SUPPLY * 3) / 20;
  uint public stakeShare = (MAX_SUPPLY * 3) / 10;
  uint public swapShare = (MAX_SUPPLY * 1) / 10;
  uint public liquidityShare = (MAX_SUPPLY * 2) / 10;
  uint public ownerShare =
    MAX_SUPPLY - swapShare - stakeShare - reserveShare - advisorShare - liquidityShare;
  AtomicSwap public swap;
  MMLStaking public stake;
  mapping(address => bool) public whitelist;
  bool public stakeMint;
  bool public swapMint;

  constructor(
    string memory _name,
    string memory _symbol,
    address _owner,
    address reserve,
    address advisor,
    address liqudiity
  ) ERC20(_name, _symbol) {
    whitelist[address(0)] = true;
    _mint(_owner, ownerShare);
    _mint(reserve, reserveShare);
    _mint(advisor, advisorShare);
    _mint(liqudiity, liquidityShare);
  }

  function setStakeContract(MMLStaking _stake) public onlyOwner {
    require(address(_stake) != address(0), "Stake contract not defined");
    require(!stakeMint, "One-time method");
    stakeMint = true;
    stake = _stake;
    _mint(address(_stake), stakeShare);
  }

  function setSwapContract(AtomicSwap _swap) public onlyOwner {
    require(address(_swap) != address(0), "Stake contract not defined");
    require(!swapMint, "One-time method");
    swapMint = true;
    swap = _swap;
    _mint(address(_swap), swapShare);
  }

  function getLockedBalance(address _address) public view returns (uint) {
    if (address(swap) == address(0)) {
      return 0;
    }
    (, , uint balance, ) = swap.balance(_address);

    return balance;
  }

  function getStakedBalance(address _address) public view returns (uint) {
    if (address(stake) == address(0)) {
      return 0;
    }
    return stake.balanceOf(_address);
  }

  // check the contract address exist in authorized list or not
  function isContractAuthorized(address _address) public view returns (bool) {
    return whitelist[_address];
  }

  //burn amount from msg.sender wallet
  function burn(uint256 amount) external {
    return _burn(msg.sender, amount);
  }

  //add contract address to authorized list
  function addContractToAuthorized(address _address) external onlyOwner {
    require(
      Address.isContract(_address),
      "should only add contract address to authorized list"
    );
    require(!whitelist[_address], "contract address already exists");
    whitelist[_address] = true;
  }

  //remote contract address From Authorized list
  function removeContractFromAuthorized(address _address) external onlyOwner {
    require(whitelist[_address], "contract address does not exist");
    whitelist[_address] = false;
  }

  function _beforeTokenTransfer(
    address from,
    address to,
    uint256 amount
  ) internal view override {
    if (
      from != address(swap) &&
      !isContractAuthorized(from) &&
      !isContractAuthorized(to)
    ) {
      require(
        balanceOf(from) + getStakedBalance(from) - getLockedBalance(from) >=
          amount,
        "cannot using locked balance"
      );
    }
  }
}
//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.4;

import "./IPriceOracle.sol";
import "./IFeed.sol";
import "./IPancakeRouter01.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/introspection/IERC165.sol";

interface AggregatorInterface {
    function latestAnswer() external view returns (int256);
}

// StablePriceOracle sets a price in USD, based on an oracle.
contract PriceOracle is IPriceOracle {
    IFeed public immutable usdOracle;
    uint256 public coinIndex;
    IPancakeRouter01 public router;
    address public wbnbToken;
    address public usdtToken;

    constructor(
        IFeed _usdOracle,
        uint256 _coinIndex,
        address _router,
        address _wbnbToken,
        address _usdtToken
    ) {
        usdOracle = _usdOracle;
        coinIndex = _coinIndex;
        router = IPancakeRouter01(_router);
        wbnbToken = _wbnbToken;
        usdtToken = _usdtToken;
    }

    function purchase(
        address token,
        uint256 amount
    ) external view override returns (uint basePrice) {
        (uint128 mmlPrice, ) = usdOracle.getCoinPrice(coinIndex);
        if (token == address(0)) {
            basePrice = (_purchase(amount) * 1e4) / mmlPrice;
        } else if (token == usdtToken) {
            basePrice = (amount * 1e4) / mmlPrice;
        } else {
            basePrice = (_purchaseToken(token, amount) * 1e4) / mmlPrice;
        }
    }

    function _purchaseToken(
        address token,
        uint256 amount
    ) internal view returns (uint256) {
        address[] memory path;
        path = new address[](3);
        path[0] = token;
        path[1] = wbnbToken;
        path[2] = usdtToken;
        uint[] memory amountsOut = router.getAmountsOut(amount, path);
        return amountsOut[2];
    }

    function _purchase(uint256 amount) internal view returns (uint256) {
        address[] memory path;
        path = new address[](2);
        path[0] = wbnbToken;
        path[1] = usdtToken;
        uint[] memory amountsOut = router.getAmountsOut(amount, path);
        return amountsOut[1];
    }

    function sell(
        uint256 amount,
        address token
    ) external view override returns (uint) {
        (uint128 mmlPrice, ) = usdOracle.getCoinPrice(coinIndex);
        uint value = (mmlPrice * amount) / 1e4;
        if (token == address(0)) {
            return _sell(value);
        } else if (token == usdtToken) {
            return value;
        } else {
            return _sellToken(token, value);
        }
    }

    function _sellToken(
        address token,
        uint256 amount
    ) internal view returns (uint256) {
        address[] memory path;
        path = new address[](3);
        path[0] = usdtToken;
        path[1] = wbnbToken;
        path[2] = token;
        uint[] memory amountsOut = router.getAmountsOut(amount, path);
        return amountsOut[2];
    }

    function _sell(uint256 amount) internal view returns (uint256) {
        address[] memory path;
        path = new address[](2);
        path[0] = usdtToken;
        path[1] = wbnbToken;
        uint[] memory amountsOut = router.getAmountsOut(amount, path);
        return amountsOut[1];
    }

    function supportsInterface(
        bytes4 interfaceID
    ) public view virtual returns (bool) {
        return
            interfaceID == type(IERC165).interfaceId ||
            interfaceID == type(IPriceOracle).interfaceId;
    }
}
