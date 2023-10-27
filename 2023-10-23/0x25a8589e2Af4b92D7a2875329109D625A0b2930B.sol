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
// OpenZeppelin Contracts v4.4.1 (interfaces/IERC20.sol)

pragma solidity ^0.8.0;

import "../token/ERC20/IERC20.sol";
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (interfaces/IERC721.sol)

pragma solidity ^0.8.0;

import "../token/ERC721/IERC721.sol";
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
// OpenZeppelin Contracts v4.4.1 (security/ReentrancyGuard.sol)

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
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC20/ERC20.sol)

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
 * https://forum.zeppelin.solutions/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
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
     * The default value of {decimals} is 18. To select a different value for
     * {decimals} you should overload it.
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
     * Ether and Wei. This is the value {ERC20} uses, unless this function is
     * overridden;
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
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
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
    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
        }
        _balances[to] += amount;

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
        _balances[account] += amount;
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
        }
        _totalSupply -= amount;

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
    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
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
    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
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
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

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
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
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
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC20/utils/SafeERC20.sol)

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
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC721/ERC721.sol)

pragma solidity ^0.8.0;

import "./IERC721.sol";
import "./IERC721Receiver.sol";
import "./extensions/IERC721Metadata.sol";
import "../../utils/Address.sol";
import "../../utils/Context.sol";
import "../../utils/Strings.sol";
import "../../utils/introspection/ERC165.sol";

/**
 * @dev Implementation of https://eips.ethereum.org/EIPS/eip-721[ERC721] Non-Fungible Token Standard, including
 * the Metadata extension, but not including the Enumerable extension, which is available separately as
 * {ERC721Enumerable}.
 */
contract ERC721 is Context, ERC165, IERC721, IERC721Metadata {
    using Address for address;
    using Strings for uint256;

    // Token name
    string private _name;

    // Token symbol
    string private _symbol;

    // Mapping from token ID to owner address
    mapping(uint256 => address) private _owners;

    // Mapping owner address to token count
    mapping(address => uint256) private _balances;

    // Mapping from token ID to approved address
    mapping(uint256 => address) private _tokenApprovals;

    // Mapping from owner to operator approvals
    mapping(address => mapping(address => bool)) private _operatorApprovals;

    /**
     * @dev Initializes the contract by setting a `name` and a `symbol` to the token collection.
     */
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {
        return
            interfaceId == type(IERC721).interfaceId ||
            interfaceId == type(IERC721Metadata).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    /**
     * @dev See {IERC721-balanceOf}.
     */
    function balanceOf(address owner) public view virtual override returns (uint256) {
        require(owner != address(0), "ERC721: address zero is not a valid owner");
        return _balances[owner];
    }

    /**
     * @dev See {IERC721-ownerOf}.
     */
    function ownerOf(uint256 tokenId) public view virtual override returns (address) {
        address owner = _owners[tokenId];
        require(owner != address(0), "ERC721: invalid token ID");
        return owner;
    }

    /**
     * @dev See {IERC721Metadata-name}.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev See {IERC721Metadata-symbol}.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev See {IERC721Metadata-tokenURI}.
     */
    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        _requireMinted(tokenId);

        string memory baseURI = _baseURI();
        return bytes(baseURI).length > 0 ? string(abi.encodePacked(baseURI, tokenId.toString())) : "";
    }

    /**
     * @dev Base URI for computing {tokenURI}. If set, the resulting URI for each
     * token will be the concatenation of the `baseURI` and the `tokenId`. Empty
     * by default, can be overridden in child contracts.
     */
    function _baseURI() internal view virtual returns (string memory) {
        return "";
    }

    /**
     * @dev See {IERC721-approve}.
     */
    function approve(address to, uint256 tokenId) public virtual override {
        address owner = ERC721.ownerOf(tokenId);
        require(to != owner, "ERC721: approval to current owner");

        require(
            _msgSender() == owner || isApprovedForAll(owner, _msgSender()),
            "ERC721: approve caller is not token owner nor approved for all"
        );

        _approve(to, tokenId);
    }

    /**
     * @dev See {IERC721-getApproved}.
     */
    function getApproved(uint256 tokenId) public view virtual override returns (address) {
        _requireMinted(tokenId);

        return _tokenApprovals[tokenId];
    }

    /**
     * @dev See {IERC721-setApprovalForAll}.
     */
    function setApprovalForAll(address operator, bool approved) public virtual override {
        _setApprovalForAll(_msgSender(), operator, approved);
    }

    /**
     * @dev See {IERC721-isApprovedForAll}.
     */
    function isApprovedForAll(address owner, address operator) public view virtual override returns (bool) {
        return _operatorApprovals[owner][operator];
    }

    /**
     * @dev See {IERC721-transferFrom}.
     */
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {
        //solhint-disable-next-line max-line-length
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: caller is not token owner nor approved");

        _transfer(from, to, tokenId);
    }

    /**
     * @dev See {IERC721-safeTransferFrom}.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {
        safeTransferFrom(from, to, tokenId, "");
    }

    /**
     * @dev See {IERC721-safeTransferFrom}.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory data
    ) public virtual override {
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: caller is not token owner nor approved");
        _safeTransfer(from, to, tokenId, data);
    }

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * `data` is additional data, it has no specified format and it is sent in call to `to`.
     *
     * This internal function is equivalent to {safeTransferFrom}, and can be used to e.g.
     * implement alternative mechanisms to perform token transfer, such as signature-based.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function _safeTransfer(
        address from,
        address to,
        uint256 tokenId,
        bytes memory data
    ) internal virtual {
        _transfer(from, to, tokenId);
        require(_checkOnERC721Received(from, to, tokenId, data), "ERC721: transfer to non ERC721Receiver implementer");
    }

    /**
     * @dev Returns whether `tokenId` exists.
     *
     * Tokens can be managed by their owner or approved accounts via {approve} or {setApprovalForAll}.
     *
     * Tokens start existing when they are minted (`_mint`),
     * and stop existing when they are burned (`_burn`).
     */
    function _exists(uint256 tokenId) internal view virtual returns (bool) {
        return _owners[tokenId] != address(0);
    }

    /**
     * @dev Returns whether `spender` is allowed to manage `tokenId`.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view virtual returns (bool) {
        address owner = ERC721.ownerOf(tokenId);
        return (spender == owner || isApprovedForAll(owner, spender) || getApproved(tokenId) == spender);
    }

    /**
     * @dev Safely mints `tokenId` and transfers it to `to`.
     *
     * Requirements:
     *
     * - `tokenId` must not exist.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function _safeMint(address to, uint256 tokenId) internal virtual {
        _safeMint(to, tokenId, "");
    }

    /**
     * @dev Same as {xref-ERC721-_safeMint-address-uint256-}[`_safeMint`], with an additional `data` parameter which is
     * forwarded in {IERC721Receiver-onERC721Received} to contract recipients.
     */
    function _safeMint(
        address to,
        uint256 tokenId,
        bytes memory data
    ) internal virtual {
        _mint(to, tokenId);
        require(
            _checkOnERC721Received(address(0), to, tokenId, data),
            "ERC721: transfer to non ERC721Receiver implementer"
        );
    }

    /**
     * @dev Mints `tokenId` and transfers it to `to`.
     *
     * WARNING: Usage of this method is discouraged, use {_safeMint} whenever possible
     *
     * Requirements:
     *
     * - `tokenId` must not exist.
     * - `to` cannot be the zero address.
     *
     * Emits a {Transfer} event.
     */
    function _mint(address to, uint256 tokenId) internal virtual {
        require(to != address(0), "ERC721: mint to the zero address");
        require(!_exists(tokenId), "ERC721: token already minted");

        _beforeTokenTransfer(address(0), to, tokenId);

        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(address(0), to, tokenId);

        _afterTokenTransfer(address(0), to, tokenId);
    }

    /**
     * @dev Destroys `tokenId`.
     * The approval is cleared when the token is burned.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     *
     * Emits a {Transfer} event.
     */
    function _burn(uint256 tokenId) internal virtual {
        address owner = ERC721.ownerOf(tokenId);

        _beforeTokenTransfer(owner, address(0), tokenId);

        // Clear approvals
        _approve(address(0), tokenId);

        _balances[owner] -= 1;
        delete _owners[tokenId];

        emit Transfer(owner, address(0), tokenId);

        _afterTokenTransfer(owner, address(0), tokenId);
    }

    /**
     * @dev Transfers `tokenId` from `from` to `to`.
     *  As opposed to {transferFrom}, this imposes no restrictions on msg.sender.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     *
     * Emits a {Transfer} event.
     */
    function _transfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {
        require(ERC721.ownerOf(tokenId) == from, "ERC721: transfer from incorrect owner");
        require(to != address(0), "ERC721: transfer to the zero address");

        _beforeTokenTransfer(from, to, tokenId);

        // Clear approvals from the previous owner
        _approve(address(0), tokenId);

        _balances[from] -= 1;
        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(from, to, tokenId);

        _afterTokenTransfer(from, to, tokenId);
    }

    /**
     * @dev Approve `to` to operate on `tokenId`
     *
     * Emits an {Approval} event.
     */
    function _approve(address to, uint256 tokenId) internal virtual {
        _tokenApprovals[tokenId] = to;
        emit Approval(ERC721.ownerOf(tokenId), to, tokenId);
    }

    /**
     * @dev Approve `operator` to operate on all of `owner` tokens
     *
     * Emits an {ApprovalForAll} event.
     */
    function _setApprovalForAll(
        address owner,
        address operator,
        bool approved
    ) internal virtual {
        require(owner != operator, "ERC721: approve to caller");
        _operatorApprovals[owner][operator] = approved;
        emit ApprovalForAll(owner, operator, approved);
    }

    /**
     * @dev Reverts if the `tokenId` has not been minted yet.
     */
    function _requireMinted(uint256 tokenId) internal view virtual {
        require(_exists(tokenId), "ERC721: invalid token ID");
    }

    /**
     * @dev Internal function to invoke {IERC721Receiver-onERC721Received} on a target address.
     * The call is not executed if the target address is not a contract.
     *
     * @param from address representing the previous owner of the given token ID
     * @param to target address that will receive the tokens
     * @param tokenId uint256 ID of the token to be transferred
     * @param data bytes optional data to send along with the call
     * @return bool whether the call correctly returned the expected magic value
     */
    function _checkOnERC721Received(
        address from,
        address to,
        uint256 tokenId,
        bytes memory data
    ) private returns (bool) {
        if (to.isContract()) {
            try IERC721Receiver(to).onERC721Received(_msgSender(), from, tokenId, data) returns (bytes4 retval) {
                return retval == IERC721Receiver.onERC721Received.selector;
            } catch (bytes memory reason) {
                if (reason.length == 0) {
                    revert("ERC721: transfer to non ERC721Receiver implementer");
                } else {
                    /// @solidity memory-safe-assembly
                    assembly {
                        revert(add(32, reason), mload(reason))
                    }
                }
            }
        } else {
            return true;
        }
    }

    /**
     * @dev Hook that is called before any token transfer. This includes minting
     * and burning.
     *
     * Calling conditions:
     *
     * - When `from` and `to` are both non-zero, ``from``'s `tokenId` will be
     * transferred to `to`.
     * - When `from` is zero, `tokenId` will be minted for `to`.
     * - When `to` is zero, ``from``'s `tokenId` will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {}

    /**
     * @dev Hook that is called after any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {}
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC721/extensions/ERC721Enumerable.sol)

pragma solidity ^0.8.0;

import "../ERC721.sol";
import "./IERC721Enumerable.sol";

/**
 * @dev This implements an optional extension of {ERC721} defined in the EIP that adds
 * enumerability of all the token ids in the contract as well as all token ids owned by each
 * account.
 */
abstract contract ERC721Enumerable is ERC721, IERC721Enumerable {
    // Mapping from owner to list of owned token IDs
    mapping(address => mapping(uint256 => uint256)) private _ownedTokens;

    // Mapping from token ID to index of the owner tokens list
    mapping(uint256 => uint256) private _ownedTokensIndex;

    // Array with all token ids, used for enumeration
    uint256[] private _allTokens;

    // Mapping from token id to position in the allTokens array
    mapping(uint256 => uint256) private _allTokensIndex;

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(IERC165, ERC721) returns (bool) {
        return interfaceId == type(IERC721Enumerable).interfaceId || super.supportsInterface(interfaceId);
    }

    /**
     * @dev See {IERC721Enumerable-tokenOfOwnerByIndex}.
     */
    function tokenOfOwnerByIndex(address owner, uint256 index) public view virtual override returns (uint256) {
        require(index < ERC721.balanceOf(owner), "ERC721Enumerable: owner index out of bounds");
        return _ownedTokens[owner][index];
    }

    /**
     * @dev See {IERC721Enumerable-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _allTokens.length;
    }

    /**
     * @dev See {IERC721Enumerable-tokenByIndex}.
     */
    function tokenByIndex(uint256 index) public view virtual override returns (uint256) {
        require(index < ERC721Enumerable.totalSupply(), "ERC721Enumerable: global index out of bounds");
        return _allTokens[index];
    }

    /**
     * @dev Hook that is called before any token transfer. This includes minting
     * and burning.
     *
     * Calling conditions:
     *
     * - When `from` and `to` are both non-zero, ``from``'s `tokenId` will be
     * transferred to `to`.
     * - When `from` is zero, `tokenId` will be minted for `to`.
     * - When `to` is zero, ``from``'s `tokenId` will be burned.
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual override {
        super._beforeTokenTransfer(from, to, tokenId);

        if (from == address(0)) {
            _addTokenToAllTokensEnumeration(tokenId);
        } else if (from != to) {
            _removeTokenFromOwnerEnumeration(from, tokenId);
        }
        if (to == address(0)) {
            _removeTokenFromAllTokensEnumeration(tokenId);
        } else if (to != from) {
            _addTokenToOwnerEnumeration(to, tokenId);
        }
    }

    /**
     * @dev Private function to add a token to this extension's ownership-tracking data structures.
     * @param to address representing the new owner of the given token ID
     * @param tokenId uint256 ID of the token to be added to the tokens list of the given address
     */
    function _addTokenToOwnerEnumeration(address to, uint256 tokenId) private {
        uint256 length = ERC721.balanceOf(to);
        _ownedTokens[to][length] = tokenId;
        _ownedTokensIndex[tokenId] = length;
    }

    /**
     * @dev Private function to add a token to this extension's token tracking data structures.
     * @param tokenId uint256 ID of the token to be added to the tokens list
     */
    function _addTokenToAllTokensEnumeration(uint256 tokenId) private {
        _allTokensIndex[tokenId] = _allTokens.length;
        _allTokens.push(tokenId);
    }

    /**
     * @dev Private function to remove a token from this extension's ownership-tracking data structures. Note that
     * while the token is not assigned a new owner, the `_ownedTokensIndex` mapping is _not_ updated: this allows for
     * gas optimizations e.g. when performing a transfer operation (avoiding double writes).
     * This has O(1) time complexity, but alters the order of the _ownedTokens array.
     * @param from address representing the previous owner of the given token ID
     * @param tokenId uint256 ID of the token to be removed from the tokens list of the given address
     */
    function _removeTokenFromOwnerEnumeration(address from, uint256 tokenId) private {
        // To prevent a gap in from's tokens array, we store the last token in the index of the token to delete, and
        // then delete the last slot (swap and pop).

        uint256 lastTokenIndex = ERC721.balanceOf(from) - 1;
        uint256 tokenIndex = _ownedTokensIndex[tokenId];

        // When the token to delete is the last token, the swap operation is unnecessary
        if (tokenIndex != lastTokenIndex) {
            uint256 lastTokenId = _ownedTokens[from][lastTokenIndex];

            _ownedTokens[from][tokenIndex] = lastTokenId; // Move the last token to the slot of the to-delete token
            _ownedTokensIndex[lastTokenId] = tokenIndex; // Update the moved token's index
        }

        // This also deletes the contents at the last position of the array
        delete _ownedTokensIndex[tokenId];
        delete _ownedTokens[from][lastTokenIndex];
    }

    /**
     * @dev Private function to remove a token from this extension's token tracking data structures.
     * This has O(1) time complexity, but alters the order of the _allTokens array.
     * @param tokenId uint256 ID of the token to be removed from the tokens list
     */
    function _removeTokenFromAllTokensEnumeration(uint256 tokenId) private {
        // To prevent a gap in the tokens array, we store the last token in the index of the token to delete, and
        // then delete the last slot (swap and pop).

        uint256 lastTokenIndex = _allTokens.length - 1;
        uint256 tokenIndex = _allTokensIndex[tokenId];

        // When the token to delete is the last token, the swap operation is unnecessary. However, since this occurs so
        // rarely (when the last minted token is burnt) that we still do the swap here to avoid the gas cost of adding
        // an 'if' statement (like in _removeTokenFromOwnerEnumeration)
        uint256 lastTokenId = _allTokens[lastTokenIndex];

        _allTokens[tokenIndex] = lastTokenId; // Move the last token to the slot of the to-delete token
        _allTokensIndex[lastTokenId] = tokenIndex; // Update the moved token's index

        // This also deletes the contents at the last position of the array
        delete _allTokensIndex[tokenId];
        _allTokens.pop();
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC721/extensions/IERC721Enumerable.sol)

pragma solidity ^0.8.0;

import "../IERC721.sol";

/**
 * @title ERC-721 Non-Fungible Token Standard, optional enumeration extension
 * @dev See https://eips.ethereum.org/EIPS/eip-721
 */
interface IERC721Enumerable is IERC721 {
    /**
     * @dev Returns the total amount of tokens stored by the contract.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns a token ID owned by `owner` at a given `index` of its token list.
     * Use along with {balanceOf} to enumerate all of ``owner``'s tokens.
     */
    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256);

    /**
     * @dev Returns a token ID at a given `index` of all the tokens stored by the contract.
     * Use along with {totalSupply} to enumerate all tokens.
     */
    function tokenByIndex(uint256 index) external view returns (uint256);
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC721/extensions/IERC721Metadata.sol)

pragma solidity ^0.8.0;

import "../IERC721.sol";

/**
 * @title ERC-721 Non-Fungible Token Standard, optional metadata extension
 * @dev See https://eips.ethereum.org/EIPS/eip-721
 */
interface IERC721Metadata is IERC721 {
    /**
     * @dev Returns the token collection name.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the token collection symbol.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the Uniform Resource Identifier (URI) for `tokenId` token.
     */
    function tokenURI(uint256 tokenId) external view returns (string memory);
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC721/IERC721.sol)

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
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;

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
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Transfers `tokenId` token from `from` to `to`.
     *
     * WARNING: Usage of this method is discouraged, use {safeTransferFrom} whenever possible.
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
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

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
    function setApprovalForAll(address operator, bool _approved) external;

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
// OpenZeppelin Contracts (last updated v4.7.0) (utils/Address.sol)

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
        return functionCall(target, data, "Address: low-level call failed");
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
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
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
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
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
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verifies that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason using the provided one.
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
// OpenZeppelin Contracts v4.4.1 (utils/introspection/ERC165.sol)

pragma solidity ^0.8.0;

import "./IERC165.sol";

/**
 * @dev Implementation of the {IERC165} interface.
 *
 * Contracts that want to implement ERC165 should inherit from this contract and override {supportsInterface} to check
 * for the additional interface id that will be supported. For example:
 *
 * ```solidity
 * function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
 *     return interfaceId == type(MyInterface).interfaceId || super.supportsInterface(interfaceId);
 * }
 * ```
 *
 * Alternatively, {ERC165Storage} provides an easier to use but more expensive implementation.
 */
abstract contract ERC165 is IERC165 {
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
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
// OpenZeppelin Contracts (last updated v4.7.0) (utils/Strings.sol)

pragma solidity ^0.8.0;

/**
 * @dev String operations.
 */
library Strings {
    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";
    uint8 private constant _ADDRESS_LENGTH = 20;

    /**
     * @dev Converts a `uint256` to its ASCII `string` decimal representation.
     */
    function toString(uint256 value) internal pure returns (string memory) {
        // Inspired by OraclizeAPI's implementation - MIT licence
        // https://github.com/oraclize/ethereum-api/blob/b42146b063c7d6ee1358846c198246239e9360e8/oraclizeAPI_0.4.25.sol

        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation.
     */
    function toHexString(uint256 value) internal pure returns (string memory) {
        if (value == 0) {
            return "0x00";
        }
        uint256 temp = value;
        uint256 length = 0;
        while (temp != 0) {
            length++;
            temp >>= 8;
        }
        return toHexString(value, length);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation with fixed length.
     */
    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _HEX_SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }

    /**
     * @dev Converts an `address` with fixed length of 20 bytes to its not checksummed ASCII `string` hexadecimal representation.
     */
    function toHexString(address addr) internal pure returns (string memory) {
        return toHexString(uint256(uint160(addr)), _ADDRESS_LENGTH);
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
pragma solidity >=0.5.0;

interface IWETH {
    function deposit() external payable;
    function transfer(address to, uint value) external returns (bool);
    function withdraw(uint) external;
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/interfaces/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

// DYNAMIC DECENTRALIZED SUPPLY CONTROL ALGORITHM
contract DDSCADOGS is Ownable {

    bool public isInitialized;

    IERC20 public token;

    uint256 public tokenPerBlock;
    uint256 public maxEmissionRate;
    uint256 public emissionStartBlock;
    uint256 public emissionEndBlock = type(uint256).max;
    address public masterchef;

    // Dynamic emissions
    uint256 public topPriceInCents    = 800;  // 8$
    uint256 public bottomPriceInCents = 100;  // 1$

    enum EmissionRate {SLOW, MEDIUM, FAST, FASTEST}
    EmissionRate public ActiveEmissionIndex = EmissionRate.MEDIUM;

    event UpdateDDSCAPriceRange(uint256 topPrice, uint256 bottomPrice);
    event updatedDDSCAMaxEmissionRate(uint256 maxEmissionRate);
    event SetFarmStartBlock(uint256 startBlock);
    event SetFarmEndBlock(uint256 endBlock);

    constructor(IERC20 _tokenAddress, uint256 _tokenPerBlock, uint256 _maxTokenPerBlock, uint256 _startBlock) {
        token = _tokenAddress;
        tokenPerBlock = _tokenPerBlock;
        maxEmissionRate = _maxTokenPerBlock;
        emissionStartBlock = _startBlock;
        isInitialized = true;
    }

    // Called externally by bot
    function checkIfUpdateIsNeeded(uint256 priceInCents) public view returns(bool, EmissionRate) {

        EmissionRate _emissionRate;

        if (!isInitialized){
            return(false, _emissionRate);
        }

        bool isOverATH = priceInCents > topPriceInCents;
        // if price is over ATH, set to fastest
        if (isOverATH){
            _emissionRate = EmissionRate.FASTEST;
        } else {
            _emissionRate = getEmissionStage(priceInCents);
        }

        // No changes, no need to update
        if (_emissionRate == ActiveEmissionIndex){
            return(false, _emissionRate);
        }

        // Means its a downward movement, and it changed a stage
        if (_emissionRate < ActiveEmissionIndex){
            return(true, _emissionRate);
        }

        // Check if its a upward movement
        if (_emissionRate > ActiveEmissionIndex){

            uint256 athExtra = 0;
            if (isOverATH){
                athExtra = 1;
            }

            // Check if it moved up by two stages
            if ((uint256(_emissionRate) + athExtra) - uint256(ActiveEmissionIndex) >= 2){
                // price has moved 2 ranges from current, so update
                _emissionRate = EmissionRate(uint256(_emissionRate) + athExtra - 1 );
                return(true, _emissionRate);
            }
        }
        return(false, _emissionRate);

    }

    function updateEmissions(EmissionRate _newEmission) public {
        require(msg.sender ==  masterchef); 
        ActiveEmissionIndex = _newEmission;
        tokenPerBlock = (maxEmissionRate / 4) * (uint256(_newEmission) + 1);
    }

    function getEmissionStage(uint256 currentPriceCents) public view returns (EmissionRate){

        if (currentPriceCents > topPriceInCents){
            return EmissionRate.FASTEST;
        }

        // Prevent function from underflowing when subtracting currentPriceCents - bottomPriceInCents
        if (currentPriceCents < bottomPriceInCents){
            currentPriceCents = bottomPriceInCents;
        }
        uint256 percentageChange = ((currentPriceCents - bottomPriceInCents ) * 1000) / (topPriceInCents - bottomPriceInCents);
        percentageChange = 1000 - percentageChange;

        if (percentageChange <= 250){
            return EmissionRate.FASTEST;
        }
        if (percentageChange <= 500 && percentageChange > 250){
            return EmissionRate.FAST;
        }
        if (percentageChange <= 750 && percentageChange > 500){
            return EmissionRate.MEDIUM;
        }

        return EmissionRate.SLOW;
    }

    function updateDDSCAPriceRange(uint256 _topPrice, uint256 _bottomPrice) external onlyOwner {
        require(_topPrice > _bottomPrice, "top < bottom price");
        topPriceInCents = _topPrice;
        bottomPriceInCents = _bottomPrice;
        emit UpdateDDSCAPriceRange(topPriceInCents, bottomPriceInCents);
    }

    function updateDDSCAMaxEmissionRate(uint256 _maxEmissionRate) external onlyOwner {
        require(_maxEmissionRate > 0, "_maxEmissionRate !> 0");
        require(_maxEmissionRate <= 10 ether, "_maxEmissionRate !");
        maxEmissionRate = _maxEmissionRate;
        emit updatedDDSCAMaxEmissionRate(_maxEmissionRate);
    }

    function _setFarmStartBlock(uint256 _newStartBlock) external {
        require(msg.sender ==  masterchef); 
        require(_newStartBlock > block.number, "must be in the future");
        require(block.number < emissionStartBlock, "farm has already started");
        emissionStartBlock = _newStartBlock;
        emit SetFarmStartBlock(_newStartBlock);
    }

    function setFarmEndBlock(uint256 _newEndBlock) external onlyOwner {
        require(_newEndBlock > block.number, "must be in the future");
        emissionEndBlock = _newEndBlock;
        emit SetFarmEndBlock(_newEndBlock);
    }
    
    function updateMcAddress(address _mcAddress) external onlyOwner {
        masterchef = _mcAddress;
    }
}// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/interfaces/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

// DYNAMIC DECENTRALIZED SUPPLY CONTROL ALGORITHM
contract DDSCAPIGS is Ownable {

    bool public isInitialized;

    IERC20 public token;

    uint256 public tokenPerBlock;
    uint256 public maxEmissionRate;
    uint256 public emissionStartBlock;
    uint256 public emissionEndBlock = type(uint256).max;
    address public masterchef;

    // Dynamic emissions
    uint256 public topPriceInCents    = 800;  // 8$
    uint256 public bottomPriceInCents = 100;  // 1$

    enum EmissionRate {SLOW, MEDIUM, FAST, FASTEST}
    EmissionRate public ActiveEmissionIndex = EmissionRate.MEDIUM;

    event UpdateDDSCAPriceRange(uint256 topPrice, uint256 bottomPrice);
    event updatedDDSCAMaxEmissionRate(uint256 maxEmissionRate);
    event SetFarmStartBlock(uint256 startBlock);
    event SetFarmEndBlock(uint256 endBlock);

    constructor(IERC20 _tokenAddress, uint256 _tokenPerBlock, uint256 _maxTokenPerBlock, uint256 _startBlock) {
        token = _tokenAddress;
        tokenPerBlock = _tokenPerBlock;
        maxEmissionRate = _maxTokenPerBlock;
        emissionStartBlock = _startBlock;
        isInitialized = true;
    }

    // Called externally by bot
    function checkIfUpdateIsNeeded(uint256 priceInCents) public view returns(bool, EmissionRate) {

        EmissionRate _emissionRate;

        if (!isInitialized){
            return(false, _emissionRate);
        }

        bool isOverATH = priceInCents > topPriceInCents;
        // if price is over ATH, set to fastest
        if (isOverATH){
            _emissionRate = EmissionRate.FASTEST;
        } else {
            _emissionRate = getEmissionStage(priceInCents);
        }

        // No changes, no need to update
        if (_emissionRate == ActiveEmissionIndex){
            return(false, _emissionRate);
        }

        // Means its a downward movement, and it changed a stage
        if (_emissionRate < ActiveEmissionIndex){
            return(true, _emissionRate);
        }

        // Check if its a upward movement
        if (_emissionRate > ActiveEmissionIndex){

            uint256 athExtra = 0;
            if (isOverATH){
                athExtra = 1;
            }

            // Check if it moved up by two stages
            if ((uint256(_emissionRate) + athExtra) - uint256(ActiveEmissionIndex) >= 2){
                // price has moved 2 ranges from current, so update
                _emissionRate = EmissionRate(uint256(_emissionRate) + athExtra - 1 );
                return(true, _emissionRate);
            }
        }
        return(false, _emissionRate);

    }

    function updateEmissions(EmissionRate _newEmission) public {
        require(msg.sender ==  masterchef); 
        ActiveEmissionIndex = _newEmission;
        tokenPerBlock = (maxEmissionRate / 4) * (uint256(_newEmission) + 1);
    }

    function getEmissionStage(uint256 currentPriceCents) public view returns (EmissionRate){

        if (currentPriceCents > topPriceInCents){
            return EmissionRate.FASTEST;
        }

        // Prevent function from underflowing when subtracting currentPriceCents - bottomPriceInCents
        if (currentPriceCents < bottomPriceInCents){
            currentPriceCents = bottomPriceInCents;
        }
        uint256 percentageChange = ((currentPriceCents - bottomPriceInCents ) * 1000) / (topPriceInCents - bottomPriceInCents);
        percentageChange = 1000 - percentageChange;

        if (percentageChange <= 250){
            return EmissionRate.FASTEST;
        }
        if (percentageChange <= 500 && percentageChange > 250){
            return EmissionRate.FAST;
        }
        if (percentageChange <= 750 && percentageChange > 500){
            return EmissionRate.MEDIUM;
        }

        return EmissionRate.SLOW;
    }

    function updateDDSCAPriceRange(uint256 _topPrice, uint256 _bottomPrice) external onlyOwner {
        require(_topPrice > _bottomPrice, "top < bottom price");
        topPriceInCents = _topPrice;
        bottomPriceInCents = _bottomPrice;
        emit UpdateDDSCAPriceRange(topPriceInCents, bottomPriceInCents);
    }

    function updateDDSCAMaxEmissionRate(uint256 _maxEmissionRate) external onlyOwner {
        require(_maxEmissionRate > 0, "_maxEmissionRate !> 0");
        require(_maxEmissionRate <= 10 ether, "_maxEmissionRate !");
        maxEmissionRate = _maxEmissionRate;
        emit updatedDDSCAMaxEmissionRate(_maxEmissionRate);
    }

    function _setFarmStartBlock(uint256 _newStartBlock) external {
        require(msg.sender ==  masterchef); 
        require(_newStartBlock > block.number, "must be in the future");
        require(block.number < emissionStartBlock, "farm has already started");
        emissionStartBlock = _newStartBlock;
        emit SetFarmStartBlock(_newStartBlock);
    }

    function setFarmEndBlock(uint256 _newEndBlock) external onlyOwner {
        require(_newEndBlock > block.number, "must be in the future");
        emissionEndBlock = _newEndBlock;
        emit SetFarmEndBlock(_newEndBlock);
    }
    
    function updateMcAddress(address _mcAddress) external onlyOwner {
        masterchef = _mcAddress;
    }
}pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/interfaces/IERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract DevFeeManager is Ownable {
    
    struct TokenInfo {
        IERC20 lpToken;
        uint256 oldBalance;
        uint256 runningTotal;
    }
    
    TokenInfo[] public tokenInfo;
    address[] public users;
    address[] public usersTemp;
    uint256 stageBlock;
    mapping(address => uint256) allocation; //number between 0 and 10000 (0.00% and 100.00%)
    mapping(address => uint256) allocationTemp; //number between 0 and 10000 (0.00% and 100.00%)
    mapping(address => bool) addedTokens;
    mapping(uint256 => mapping(address => uint256)) tokensClaimed;

    address multiSigOne;
    address multiSigTwo;
    mapping(address => bool) signed;

    constructor(address[] memory _address, uint256[] memory _allocations, address _multiSigOne, address _multiSigTwo){
        require(verifyAllocations(_address,_allocations));
        for(uint i = 0; i <_allocations.length; i++){
            allocation[_address[i]] = _allocations[i];
            users.push(_address[i]);
        }
        multiSigOne = _multiSigOne;
        multiSigTwo = _multiSigTwo;
    }

    function verifyAllocations(address[] memory _address, uint256[] memory _allocations) public pure returns(bool) {
        if (_address.length != _allocations.length) {
            return false;
        }
        uint256 sum = 0;
        for(uint i = 0; i <_allocations.length; i++){
            sum += _allocations[i];
        }
        return sum == 10000;
    }

    function Sign() public {
        require (msg.sender == multiSigOne || msg.sender == multiSigTwo);
        require (!signed[msg.sender]);
        require(block.number - stageBlock > 50);
        signed[msg.sender] = true;
    }

    function Unsign() public {
        require (msg.sender == multiSigOne || msg.sender == multiSigTwo);
        require (signed[msg.sender]);
        signed[msg.sender] = false;
    }

    function updateEarned() public {
        for (uint256 i = 0; i < tokenInfo.length; i++) {
            uint256 tokenBalance = tokenInfo[i].lpToken.balanceOf(address(this));
            uint256 tokenEarned = tokenBalance - tokenInfo[i].oldBalance;
            tokenInfo[i].oldBalance = tokenBalance;
            tokenInfo[i].runningTotal += tokenEarned;
        }
    }

    function claimForUser(address user) private {
        for (uint256 i = 0; i < tokenInfo.length; i++) {
            uint256 allocatedTokens = (allocation[user]*tokenInfo[i].runningTotal)/10000 - tokensClaimed[i][user];
            tokenInfo[i].lpToken.transfer(user, allocatedTokens);
            tokensClaimed[i][user] += allocatedTokens;
        }
    }

    function widthdraw() public {
        updateEarned();
        claimForUser(msg.sender);
    }

    function widthdrawAll() public {
        updateEarned();
        for (uint256 j = 0; j < users.length; j++) {
            claimForUser(users[j]);
        }
    }

    function stageUserAllocationChanges(address[] memory _address, uint256[] memory _allocations) public onlyOwner {
        require(verifyAllocations(_address,_allocations));
        usersTemp =  _address;
        for(uint i = 0; i <_allocations.length; i++){
            allocationTemp[_address[i]] = _allocations[i];
        }
        signed[multiSigOne] = false;
        signed[multiSigTwo] = false;
        stageBlock = block.number;
    }

    function setUserAllocationChanges() public{
        require (signed[multiSigOne] && signed[multiSigTwo]);
        users = usersTemp;
        for(uint i = 0; i < usersTemp.length; i++){
            allocation[users[i]] = allocationTemp[users[i]];
        }
        signed[multiSigOne] = false;
        signed[multiSigTwo] = false;
    }

    function addTokens(address[] memory _address) public onlyOwner {
        for(uint i = 0; i <_address.length; i++){
            require(!addedTokens[_address[i]],"cant add dupe Token");
            tokenInfo.push(TokenInfo({lpToken:IERC20(_address[i]), runningTotal: IERC20(_address[i]).balanceOf(address(this)), oldBalance: 0}));
            addedTokens[_address[i]] = true;
        }
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/interfaces/IERC20.sol";
import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Factory.sol";
import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";
import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Pair.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

interface IToolbox {

    function getTokenBUSDValue(uint256 tokenBalance, address token, bool isLPToken) external view returns (uint256);

}

interface DevFeeM {

  function tokenInfo ( uint256 ) external view returns ( address lpToken, uint256 oldBalance, uint256 runningTotal );

}


contract DevFeeSellerManager is Ownable {
    using SafeERC20 for IERC20;

    IUniswapV2Factory public constant PancakeFactory = IUniswapV2Factory(0xcA143Ce32Fe78f1f7019d7d551a6402fC5350c73);
    IUniswapV2Router02 public constant PancakeRouter = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
    IToolbox public Toolbox = IToolbox(0x78F316775ace6CBF33F14b52903900fb9Be02fb4);

    uint256 public busdSwapThreshold = 10 ether;

    address public constant busdCurrencyAddress = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;
    address public constant wbnbCurrencyAddress = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address public dontSellAddress;
    DevFeeM public devFeeM = DevFeeM(0xFe44479A11Cf491DA91BE1f3d7b2727Dd2df7424);

    mapping (address => bool) public viaWBNBTokens;
    mapping (address => bool) public dontSellTokens;
    mapping (address => bool) public isLpToken;

    constructor(){

        _approveTokenIfNeeded(busdCurrencyAddress, address(PancakeRouter));
        _setRouteViaBNBToken(0xF8A0BF9cF54Bb92F17374d9e9A321E6a111a51bD, true); // LINK
        _setRouteViaBNBToken(0xE0e514c71282b6f4e823703a39374Cf58dc3eA4f, true); // BELT
        _setRouteViaBNBToken(0x2170Ed0880ac9A755fd29B2688956BD959F933F8, true); // ETH
        _setRouteViaBNBToken(0x7083609fCE4d1d8Dc0C979AAb8c869Ea2C873402, true); // DOT
        isLpToken[0x58F876857a02D6762E0101bb5C46A8c1ED44Dc16] = true;
        isLpToken[0x7EFaEf62fDdCCa950418312c6C91Aef321375A00] = true;
        isLpToken[0x2354ef4DF11afacb85a5C7f98B624072ECcddbB1] = true;
        isLpToken[0x2E28b9B74D6d99D4697e913b82B41ef1CAC51c6C] = true;
        isLpToken[0x66FDB2eCCfB58cF098eaa419e5EfDe841368e489] = true;
        isLpToken[0xD171B26E4484402de70e3Ea256bE5A2630d7e88D] = true;
        isLpToken[0x74E4716E431f45807DCF19f284c7aA99F18a4fbc] = true;
        isLpToken[0x61EB789d75A95CAa3fF50ed7E47b96c132fEc082] = true;
        isLpToken[0xEa26B78255Df2bBC31C1eBf60010D78670185bD0] = true;
        isLpToken[0xF45cd219aEF8618A92BAa7aD848364a158a24F33] = true;
        isLpToken[0x16b9a82891338f9bA80E2D6970FddA79D1eb0daE] = true;
        isLpToken[0x804678fa97d91B974ec2af3c843270886528a9E6] = true;
        isLpToken[0xA39Af17CE4a8eb807E076805Da1e2B8EA7D0755b] = true;
        isLpToken[0x0eD7e52944161450477ee417DE9Cd3a859b14fD0] = true;
        isLpToken[0xDd5bAd8f8b360d76d12FdA230F8BAF42fe0022CF] = true;
        isLpToken[0x824eb9faDFb377394430d2744fa7C42916DE3eCe] = true;
        dontSellTokens[0xa0feB3c81A36E885B6608DF7f0ff69dB97491b58] = true;
    }

    // EXTERNAL FUNCTIONS
    function swapAll(uint256 len) external {
        dontSellAddress =  msg.sender;
        for(uint256 i = 0; i < len ; i++){
            (address lpToken, uint256 oldBalance, uint256 runningTotal) = devFeeM.tokenInfo(i);
            IERC20(lpToken).transferFrom(msg.sender, address(this), IERC20(lpToken).balanceOf(msg.sender));
            swapDepositFeeForBUSD(lpToken,isLpToken[lpToken]);
        }
        _distributeDepositFeeBusd(msg.sender);
    }


    function swapDepositFeeForBUSD(address token, bool isLPToken) internal {
        uint256 totalTokenBalance;
        if(dontSellTokens[token]){
            totalTokenBalance = IERC20(token).balanceOf(address(this));
            IERC20(token).transfer(dontSellAddress, totalTokenBalance);
            return;
        }

        totalTokenBalance = IERC20(token).balanceOf(address(this));

        if (totalTokenBalance == 0 || token == busdCurrencyAddress){
            return;
        }

        uint256 busdValue = Toolbox.getTokenBUSDValue(totalTokenBalance, token, isLPToken);

        // only swap if a certain busd value
        if (busdValue < busdSwapThreshold)
            return;

        swapDepositFeeForTokensInternal(token, isLPToken);

    }

    /**
     * @dev un-enchant the lp token into its original components.
     */
    function unpairLPToken(address token, uint256 amount) internal returns(address token0, address token1, uint256 amountA, uint256 amountB){
        _approveTokenIfNeeded(token, address(PancakeRouter));

        IUniswapV2Pair lpToken = IUniswapV2Pair(token);
        address token0 = lpToken.token0();
        address token1 = lpToken.token1();

        // make the swap
        (uint256 amount0, uint256 amount1) = PancakeRouter.removeLiquidity(
            address(token0),
            address(token1),
            amount,
            0,
            0,
            address(this),
            block.timestamp
        );

        return (token0, token1, amount0, amount1);

    }

    function swapDepositFeeForTokensInternal(address token, bool isLPToken) internal{

        uint256 totalTokenBalance = IERC20(token).balanceOf(address(this));

        if (isLPToken) {
            address token0;
            address token1;
            uint256 amount0;
            uint256 amount1;

            (token0, token1, amount0, amount1) = unpairLPToken(token, totalTokenBalance);
            // now I have 2 tokens...
            convertTokenToBUSD(token0, amount0);
            convertTokenToBUSD(token1, amount1);
        } else {
            convertTokenToBUSD(token, totalTokenBalance);
        }

    }

    function convertTokenToBUSD(address token, uint256 amount) internal {

        if (token == busdCurrencyAddress){
            return;
        }

        _approveTokenIfNeeded(token, address(PancakeRouter));

        address[] memory path;
        if (shouldRouteViaBNB(token)){
            path = new address[](3);
            path[0] = token;
            path[1] = wbnbCurrencyAddress;
            path[2] = busdCurrencyAddress;
        } else {
            path = new address[](2);
            path[0] = token;
            path[1] = busdCurrencyAddress;
        }
        uint256[] memory amountOut = PancakeRouter.getAmountsOut(amount, path);
        // make the swap
        uint256 slipAmount =  amountOut[amountOut.length - 1] - (amountOut[amountOut.length - 1]/20);
        PancakeRouter.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            amount,
            slipAmount, // accept any amount of tokens
            path,
            address(this),
            block.timestamp
        );

    }

    function _distributeDepositFeeBusd(address _distrib) internal {

        uint256 totalBusdBalance = IERC20(busdCurrencyAddress).balanceOf(address(this));

        IERC20(busdCurrencyAddress).transfer(_distrib, totalBusdBalance);
    }


    function _createRoute(address _from, address _to) internal pure returns(address[] memory){
        address[] memory path = new address[](2);
        path[0] = _from;
        path[1] = _to;
        return path;
    }

    function _createRoute3(address _from, address _mid, address _to) internal pure returns(address[] memory){
        address[] memory path = new address[](3);
        path[0] = _from;
        path[1] = _mid;
        path[2] = _to;
        return path;
    }

    function _approveTokenIfNeeded(address token, address _contract) private {
        if (IERC20(token).allowance(address(this), address(_contract)) == 0) {
            IERC20(token).safeApprove(address(_contract), type(uint256).max);
        }
    }

    function setRouteViaBNBToken(address _token, bool _viaWbnb) external onlyOwner {
        _setRouteViaBNBToken(_token, _viaWbnb);
    }

    function _setRouteViaBNBToken(address _token, bool _viaWbnb) private {
        viaWBNBTokens[_token] = _viaWbnb;
    }

    function setdontSellTokens(address _token, bool _bool) external onlyOwner {
        dontSellTokens[_token] = _bool;
    }
    
    function shouldRouteViaBNB(address _token) public view returns (bool){
        return viaWBNBTokens[_token];
    }

    function updatedontSellAddress(address _address) external onlyOwner {
        dontSellAddress = _address;
    }

    function setisLPTokens(address _token, bool _bool) external onlyOwner {
        isLpToken[_token] = _bool;
    }

    function updateToolbox(IToolbox _toolbox) external onlyOwner {
        Toolbox = _toolbox;
    }


    function inCaseTokensGetStuck(address _token, uint256 _amount, address _to) external onlyOwner {
        IERC20(_token).safeTransfer(_to, _amount);
    }
}// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/interfaces/IERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract DogCrediting is Ownable, ReentrancyGuard {

    uint256 public payoutRate = 2;
    uint256 public APY = 35;
    uint256 public rewardRatio;

    IERC20 public RewardToken = IERC20(0xa0feB3c81A36E885B6608DF7f0ff69dB97491b58); //todo set to dog
    IERC20 public StakedToken = IERC20(0xa0feB3c81A36E885B6608DF7f0ff69dB97491b58); //set to busd/lp token

    uint256 public TESTING_STAKED_COUNT = 0;
    uint256 public TESTING_REWARD_COUNT = 0;
    uint256 public TESTING_DOGS_PAYED_ON_CREDIT = 0;
    bool public isCreditingActive = false;

    uint256 public rewardStartTime;

    // Info of each user.
    struct UserCreditingInfo {
        uint256 amount;
    }

    struct UserStakedInfo {
        uint256 claimed;
        uint256 staked;
        uint256 deposit_time;
        uint256 last_claim_time;
        uint256 last_reward_claim_time;
        uint256 reward_time_counter;
    }

    mapping(address => UserCreditingInfo) public userCreditInfo;
    mapping(address => UserStakedInfo) public userStakeInfo;

    constructor(uint256 _rewardRatio, uint256 _rewardStartTime){
        rewardRatio = _rewardRatio;
        require(_rewardStartTime > block.timestamp, 'must be in future');
        rewardStartTime = _rewardStartTime;
    }

    function creditLPToStaking(uint256 _percentageVested) external nonReentrant {
        require(isCreditingActive, 'not active yet');
        require(_percentageVested <= 100, 'invalid percentage');

        UserCreditingInfo storage user = userCreditInfo[msg.sender];
        require(user.amount > 0, 'nothing to credit');

        uint256 amountToVest = user.amount * _percentageVested / 100;
        userStakeInfo[msg.sender].staked = amountToVest;

        if(block.timestamp <= rewardStartTime){
            userStakeInfo[msg.sender].deposit_time = rewardStartTime;
            userStakeInfo[msg.sender].last_claim_time = rewardStartTime;
            userStakeInfo[msg.sender].last_reward_claim_time = rewardStartTime;
        }else{
            userStakeInfo[msg.sender].deposit_time = block.timestamp;
            userStakeInfo[msg.sender].last_claim_time = block.timestamp;
            userStakeInfo[msg.sender].last_reward_claim_time = block.timestamp;
        }

        if (user.amount - amountToVest > 0){
            payoutRewards(user.amount - amountToVest);
        }

        user.amount = 0;
    }

    function creditLpToStakingUser(address _user, uint256 _staked, uint256 rewardTime) external onlyOwner nonReentrant {
        require(isCreditingActive, 'not active yet');
        userStakeInfo[_user].staked = _staked;

        if(block.timestamp <= rewardStartTime){
            userStakeInfo[_user].deposit_time = rewardStartTime;
            userStakeInfo[_user].last_claim_time = rewardStartTime;
            userStakeInfo[_user].last_reward_claim_time = rewardStartTime;
        }else{
            userStakeInfo[_user].deposit_time = rewardTime;
            userStakeInfo[_user].last_claim_time = rewardTime;
            userStakeInfo[_user].last_reward_claim_time = rewardTime;
        }

    }

    function payoutRewards(uint256 _amountStakeToken) internal {
        RewardToken.transfer(msg.sender, ((_amountStakeToken * rewardRatio * 2) / 1e4));
    }

    function claim() external nonReentrant {
        require(isCreditingActive, 'not active yet');
        require(block.timestamp > rewardStartTime, 'rewards not active yet');

        UserStakedInfo storage user = userStakeInfo[msg.sender];
        require(user.staked > 0, 'nothing staked');

        uint256 payout = availableToClaim(msg.sender);
        user.claimed += payout;
        user.last_claim_time = block.timestamp;
        TESTING_STAKED_COUNT += payout;
        StakedToken.transfer(msg.sender, payout);
    }

    function claimDogs() external nonReentrant {
        require(block.timestamp > rewardStartTime, 'rewards not active yet');
        
        UserStakedInfo storage user = userStakeInfo[msg.sender];
        require(user.staked > 0, 'nothing staked');

        uint256 rewardPayout = pendingRewards(msg.sender);

        uint256 timePassed = block.timestamp - userStakeInfo[msg.sender].last_reward_claim_time;

        user.reward_time_counter += timePassed;
        if (user.reward_time_counter > 50 days){
            user.reward_time_counter = 50 days;
        }

        user.last_reward_claim_time = block.timestamp;
        RewardToken.transfer(msg.sender, rewardPayout);
    }

    function pendingRewards(address _user) public view returns(uint256){
        if (block.timestamp < rewardStartTime){
            return 0;
        }

        uint256 stakedRewards = (userStakeInfo[_user].staked - userStakeInfo[_user].claimed) * rewardRatio;
        uint256 rewardsPerYear = stakedRewards * APY / 100;
        uint256 rewardsPerSecond = rewardsPerYear / 365 days;
        uint256 timePassed = block.timestamp - userStakeInfo[_user].last_reward_claim_time;

        if (timePassed + userStakeInfo[_user].reward_time_counter > 50 days){
            timePassed = 50 days - userStakeInfo[_user].reward_time_counter;
        }

        uint256 earnedTotal = (rewardsPerSecond * timePassed) / 1e4;


        return earnedTotal;
    }

    function dogsInLp(address _user) public view returns(uint256){
        return userStakeInfo[_user].staked * rewardRatio;
    }

    function setUserCreditInfo(address[] memory _users, uint256[] memory _usersCreditingData) external onlyOwner {
        require(_users.length == _usersCreditingData.length);
        for (uint256 i = 0; i < _users.length; i++) {
            userCreditInfo[_users[i]].amount = _usersCreditingData[i];
        }
    }

    function availableToClaim(address _addr) public view returns(uint256 payout) {
        if (block.timestamp < rewardStartTime){
            return 0;
        }

        uint256 share = userStakeInfo[_addr].staked * (payoutRate * 1e18) / (100e18) / (24 hours); //divide the profit by payout rate and seconds in the day
        payout = share * (block.timestamp - userStakeInfo[_addr].last_claim_time);

        if (userStakeInfo[_addr].claimed + payout > userStakeInfo[_addr].staked) {
            payout = userStakeInfo[_addr].staked - userStakeInfo[_addr].claimed;
        }

        return payout;

    }


    // Admin Functions
    function toggleCreditingActive(bool _isActive) external onlyOwner {
        isCreditingActive = _isActive;
    }

    function updatePayoutRate(uint256 _payoutRate) external onlyOwner {
        payoutRate = _payoutRate;
    }

    function updateRewardStartTime(uint256 _rewardStartTime) external onlyOwner {
        rewardStartTime = _rewardStartTime;
    }

    function updateApy(uint256 _APY) external onlyOwner {
        APY = _APY;
    }

    function updateRewardRatio(uint256 _rewardRatio) external onlyOwner {
        rewardRatio = _rewardRatio;
    }

    function updateRewardToken(IERC20 _rewardToken) external onlyOwner {
        RewardToken = _rewardToken;
    }

    function updateStakedToken(IERC20 _stakedToken) external onlyOwner {
        StakedToken = _stakedToken;
    }

    function inCaseTokensGetStuck(address _token, uint256 _amount, address _to) external onlyOwner {
        IERC20(_token).transfer(_to, _amount);
    }
}import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/interfaces/IERC20.sol";
import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";

import "./interfaces/IDogsExchangeHelper.sol";
import "./interfaces/IMasterchefPigs.sol";

pragma solidity ^0.8.0;


contract DogPoundAutoPool is Ownable {

    uint256 public lastPigsBalance = 0;

    uint256 public lpRoundMasktemp = 0;
    uint256 public lpRoundMask = 0;

    uint256 public totalDogsStaked = 0;
    uint256 public totalLPCollected = 0;
    uint256 public totalLpStaked = 0;
    uint256 public timeSinceLastCall = 0; 
    uint256 public updateInterval = 24 hours; 
    bool public initializeUnpaused = true;
    bool public managerNotLocked = true;
    bool public MClocked = false;

    uint256 public DOGS_BNB_MC_PID = 1;
    uint256 public BnbLiquidateThreshold = 1e18;
    uint256 public totalLPstakedTemp = 0;
    IERC20 public PigsToken = IERC20(0x9a3321E1aCD3B9F6debEE5e042dD2411A1742002);
    IERC20 public DogsToken = IERC20(0x198271b868daE875bFea6e6E4045cDdA5d6B9829);
    IERC20 public Dogs_BNB_LpToken = IERC20(0x2139C481d4f31dD03F924B6e87191E15A33Bf8B4);

    address public DogPoundManger = 0x6dA8227Bc7B576781ffCac69437e17b8D4F4aE41;
    IDogsExchangeHelper public DogsExchangeHelper = IDogsExchangeHelper(0xB59686fe494D1Dd6d3529Ed9df384cD208F182e8);
    IMasterchefPigs public MasterchefPigs = IMasterchefPigs(0x8536178222fC6Ec5fac49BbfeBd74CA3051c638f);
    IUniswapV2Router02 public constant PancakeRouter = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
    address public constant busdCurrencyAddress = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;
    address public constant wbnbCurrencyAddress = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address[] public dogsBnbPath = [wbnbCurrencyAddress, address(DogsToken)];


    struct HistoryInfo {
        uint256 pps;
        uint256 rms;
    }

    struct UserInfo {
        uint256 amount;
        uint256 lpMask;
        uint256 pigsClaimedTotal;
        uint256 lastRmsClaimed;
        uint256 lpDebt;
        uint256 totalLPCollected;
        uint256 totalPigsCollected;
    }
    

    HistoryInfo[] public historyInfo;
    mapping(address => UserInfo) public userInfo;
    mapping(address => bool) private initAllowed; 
    receive() external payable {}

    // Modifiers
    modifier onlyDogPoundManager() {
        require(DogPoundManger == msg.sender, "manager only");
        _;
    }

    constructor(){
        timeSinceLastCall = block.timestamp;
        initAllowed[msg.sender] = true;
        initAllowed[0x47B9501674a0B01c7F3EdF91593bDfe379D73c28] = true;
    }

    function initializeVariables(DogPoundAutoPool _pool, uint256 histlen) onlyOwner public {
        require(initializeUnpaused);
        DogPoundAutoPool pool = DogPoundAutoPool(_pool);
        lpRoundMask = pool.lpRoundMask();
        lpRoundMasktemp =  pool.lpRoundMasktemp();
        totalDogsStaked =  pool.totalDogsStaked();
        timeSinceLastCall = pool.timeSinceLastCall() + 2 hours;
        for(uint i = 0; i < histlen; i++){
            if(i >= historyInfo.length){
                historyInfo.push(HistoryInfo({rms: 0, pps: 0}));
            }
            if(i > 8){
                (historyInfo[i].pps, historyInfo[i].rms) = pool.historyInfo(i+7);
            }else{
                (historyInfo[i].pps, historyInfo[i].rms) = pool.historyInfo(i);
            }

        }
    }

    function initializeU(DogPoundAutoPool _pool, address [] memory _users) public {
        require(initAllowed[msg.sender]);
        require(initializeUnpaused);
        DogPoundAutoPool pool = DogPoundAutoPool(_pool);
        for(uint i = 0; i < _users.length; i++){
            (uint256 amount, uint256 lpMask, uint256 pigsClaimedTotal,  uint256 lastRmsClaimed, uint256 lpDebt, uint256 totalLPCollectedu, uint256 totalPigsCollected ) =  pool.userInfo(_users[i]);
            userInfo[_users[i]].amount =  amount;
            userInfo[_users[i]].lpMask =  lpMask;
            userInfo[_users[i]].pigsClaimedTotal =  pigsClaimedTotal;
            userInfo[_users[i]].lastRmsClaimed =  lastRmsClaimed;
            userInfo[_users[i]].lpDebt =  lpDebt;
            userInfo[_users[i]].totalLPCollected =  totalLPCollectedu;
            userInfo[_users[i]].totalPigsCollected =totalPigsCollected;
        }
    }

    function initializeMd(address [] memory _users, UserInfo [] memory _info) onlyOwner public {
        require(initializeUnpaused);
        for(uint i = 0; i <= _users.length; i++){
            userInfo[_users[i]] = _info[i];
        }
    }

    function initCompounders(address [] memory _users) onlyOwner public {
        require(initializeUnpaused);
        for(uint i = 0; i <= _users.length; i++){
            userInfo[_users[i]].lastRmsClaimed = userInfo[_users[i]].lpMask;
        }    
    }

    function deposit(address _user, uint256 _amount) external onlyDogPoundManager {
        UserInfo storage user = userInfo[_user];
        if(historyInfo.length != 0 && user.amount != 0){
            claimPigsInternal(_user);
        }
        totalDogsStaked += _amount;
        if(user.amount != 0){
            user.lpDebt += pendingLpRewardsInternal(_user); 
        }
        updateUserMask(_user);
        compound();
        user.amount += _amount;
    }

    function withdraw(address _user, uint256 _amount) external onlyDogPoundManager {
        compound();
        claimLpTokensAndPigsInternal(_user);
        UserInfo storage user = userInfo[_user];
        updateUserMask(_user);
        DogsToken.transfer(address(DogPoundManger), _amount);
        user.amount -= _amount;
        totalDogsStaked -= _amount;
    }

    function updateUserMask(address _user) internal {
        userInfo[_user].lpMask = lpRoundMask;
        userInfo[_user].lastRmsClaimed = historyInfo[historyInfo.length - 1].rms;
    }

    function getPigsEarned() internal returns (uint256){
        uint256 pigsBalance = PigsToken.balanceOf(address(this));
        uint256 pigsEarned = pigsBalance - lastPigsBalance;
        lastPigsBalance = pigsBalance;
        return pigsEarned;
    }
    
    function pendingLpRewardsInternal(address _userAddress) public view returns (uint256 pendingLp){
       UserInfo storage user = userInfo[_userAddress];
        pendingLp = (user.amount * (lpRoundMask - user.lpMask))/10e18;
        return pendingLp;
    }

    function pendingLpRewards(address _userAddress) public view returns (uint256 pendingLp){
        UserInfo storage user = userInfo[_userAddress];
        pendingLp = (user.amount * (lpRoundMask - user.lpMask))/10e18;
        return pendingLp  + user.lpDebt;
    }

    function claimLpTokensAndPigsInternal(address _user) internal {
        if(historyInfo.length > 0){
            claimPigsInternal(_user);
        }
        UserInfo storage user = userInfo[_user];
        uint256 lpPending = pendingLpRewards(_user);

        if (lpPending > 0){
            MasterchefPigs.withdraw(DOGS_BNB_MC_PID, lpPending);
            handlePigsIncrease();
            Dogs_BNB_LpToken.transfer(_user, lpPending);
            user.totalLPCollected += lpPending;
            totalLPCollected += lpPending;
            user.lpDebt = 0;
            user.lpMask = lpRoundMask;
            totalLpStaked -= lpPending;
        }

    }

    function claimLpTokensAndPigs() public {
        if(historyInfo.length > 0){
            claimPigs();
        }
        UserInfo storage user = userInfo[msg.sender];
        uint256 lpPending = pendingLpRewards(msg.sender);

        if (lpPending > 0){
            MasterchefPigs.withdraw(DOGS_BNB_MC_PID, lpPending);
            user.totalLPCollected += lpPending;
            totalLPCollected += lpPending;
            handlePigsIncrease();
            Dogs_BNB_LpToken.transfer(msg.sender, lpPending);
            user.lpDebt = 0;
            user.lpMask = lpRoundMask;
            totalLpStaked -= lpPending;
        }

    }

    function claimPigsHelper(uint256 startIndex) public {
        require(historyInfo.length > 0, "No History");
        require(startIndex <= historyInfo.length - 1);
        UserInfo storage user = userInfo[msg.sender];
        uint256 pigsPending;
        uint256 newPigsClaimedTotal;
        for(uint256 i = startIndex + 1; i > 0; i--){
            if(user.lastRmsClaimed > historyInfo[i - 1].rms){
                break;
            }
            if(user.lpMask > historyInfo[i - 1].rms ){
                break;
            }
            uint256 tempAmount =  (((user.amount * (historyInfo[i - 1].rms - user.lpMask))/ 10e18 + user.lpDebt) * historyInfo[i - 1].pps)/10e12;
            pigsPending += tempAmount;
            if(i - 1 == startIndex){
                newPigsClaimedTotal = tempAmount;
            }
        }
        user.lastRmsClaimed = historyInfo[startIndex].rms;
        uint256 pigsTransfered = 0;
        if(user.pigsClaimedTotal < pigsPending){
            pigsTransfered = pigsPending - user.pigsClaimedTotal;
            user.totalPigsCollected += pigsTransfered;
            lastPigsBalance -= pigsTransfered;
            PigsToken.transfer(msg.sender, pigsTransfered);
        }
        user.pigsClaimedTotal = newPigsClaimedTotal;
    }
    
    function claimPigsInternal(address _user) internal {
        require(historyInfo.length > 0, "No History");
        uint256 startIndex = historyInfo.length - 1;
        UserInfo storage user = userInfo[_user];
        uint256 pigsPending;
        uint256 newPigsClaimedTotal;
        for(uint256 i = startIndex + 1; i > 0; i--){
            if(user.lastRmsClaimed > historyInfo[i - 1].rms){
                break;
            }
            if(user.lpMask > historyInfo[i - 1].rms ){
                break;
            }
            uint256 tempAmount =  (((user.amount * (historyInfo[i - 1].rms - user.lpMask))/ 10e18 + user.lpDebt) * historyInfo[i - 1].pps)/10e12;
            pigsPending += tempAmount;
            if(i - 1 == startIndex){
                newPigsClaimedTotal = tempAmount;
            }
        }
        user.lastRmsClaimed = historyInfo[startIndex].rms;
        uint256 pigsTransfered = 0;
        if(user.pigsClaimedTotal < pigsPending){
            pigsTransfered = pigsPending - user.pigsClaimedTotal;
            user.totalPigsCollected += pigsTransfered;
            lastPigsBalance -= pigsTransfered;
            PigsToken.transfer(_user, pigsTransfered);
        }
        user.pigsClaimedTotal = newPigsClaimedTotal;

    }
    
    function pendingPigsRewardsHelper(address _user, uint256 startIndex) view public returns(uint256) {
        require(historyInfo.length > 0, "No History");
        require(startIndex <= historyInfo.length - 1);
        UserInfo storage user = userInfo[_user];
        uint256 pigsPending;
        for(uint256 i = startIndex + 1; i > 0; i--){
            if(user.lastRmsClaimed > historyInfo[i - 1].rms){
                break;
            }
            if(user.lpMask > historyInfo[i - 1].rms ){
                break;
            }
            uint256 tempAmount =  (((user.amount * (historyInfo[i - 1].rms - user.lpMask))/ 10e18 + user.lpDebt) * historyInfo[i - 1].pps)/10e12;
            pigsPending += tempAmount;
        }
        if(pigsPending <= user.pigsClaimedTotal){
            return 0;
        }
        return(pigsPending - user.pigsClaimedTotal);
    }

    function pendingPigsRewards(address _user) view public returns(uint256) {
        if(historyInfo.length == 0){
            return 0;
        }
        return pendingPigsRewardsHelper(_user, historyInfo.length - 1);
    }


    function claimPigs() public {
        require(historyInfo.length > 0, "No History");
        claimPigsHelper(historyInfo.length - 1);        
    }

    function pendingRewards(address _userAddress) public view returns (uint256 _pendingPigs, uint256 _pendingLp){
        require(historyInfo.length > 0, "No History");
        uint256 pendingLp = pendingLpRewardsInternal(_userAddress);
        uint256 pendingPigs = pendingPigsRewardsHelper(_userAddress, historyInfo.length - 1);
        return (pendingPigs, pendingLp + userInfo[_userAddress].lpDebt);
    }

    function compound() public {
        
        uint256 BnbBalance = address(this).balance;
        if (BnbBalance < BnbLiquidateThreshold){
            return;
        }

        uint256 BnbBalanceHalf = BnbBalance / 2;
        uint256 BnbBalanceRemaining = BnbBalance - BnbBalanceHalf;

        // Buy Dogs with half of the BNB
        uint256 amountDogsBought = DogsExchangeHelper.buyDogsBNB{value: BnbBalanceHalf}(0, _getBestBNBDogsSwapPath(BnbBalanceHalf));


        allowanceCheckAndSet(DogsToken, address(DogsExchangeHelper), amountDogsBought);
        (
        uint256 amountLiquidity,
        uint256 unusedTokenA,
        uint256 unusedTokenB
        ) = DogsExchangeHelper.addDogsBNBLiquidity{value: BnbBalanceRemaining}(amountDogsBought);
        lpRoundMasktemp = lpRoundMasktemp + amountLiquidity;
        if(block.timestamp - timeSinceLastCall >= updateInterval){
            lpRoundMask += (lpRoundMasktemp * 10e18)/totalDogsStaked;
            timeSinceLastCall = block.timestamp;
            lpRoundMasktemp = 0;
        }
        _stakeIntoMCPigs(amountLiquidity);
    }


    function _getBestBNBDogsSwapPath(uint256 _amountBNB) internal view returns (address[] memory){

        address[] memory pathBNB_BUSD_Dogs = _createRoute3(wbnbCurrencyAddress, busdCurrencyAddress , address(DogsToken));

        uint256[] memory amountOutBNB = PancakeRouter.getAmountsOut(_amountBNB, dogsBnbPath);
        uint256[] memory amountOutBNBviaBUSD = PancakeRouter.getAmountsOut(_amountBNB, pathBNB_BUSD_Dogs);

        if (amountOutBNB[amountOutBNB.length -1] > amountOutBNBviaBUSD[amountOutBNBviaBUSD.length - 1]){ 
            return dogsBnbPath;
        }
        return pathBNB_BUSD_Dogs;

    }

    function _createRoute3(address _from, address _mid, address _to) internal pure returns(address[] memory){
        address[] memory path = new address[](3);
        path[0] = _from;
        path[1] = _mid;
        path[2] = _to;
        return path;
    }

    function handlePigsIncrease() internal {
        uint256 pigsEarned = getPigsEarned();
        if(historyInfo.length > 0 && historyInfo[historyInfo.length - 1].rms == lpRoundMask){
            historyInfo[historyInfo.length - 1].pps += (pigsEarned * 10e12)/totalLPstakedTemp;
        }else{
            historyInfo.push(HistoryInfo({rms: lpRoundMask, pps: (pigsEarned * 10e12)/totalLpStaked}));
            totalLPstakedTemp = totalLpStaked;
        }
    }

    function increasePigsBuffer(uint256 quant) public onlyOwner{
        PigsToken.transferFrom(msg.sender, address(this), quant);
        lastPigsBalance += quant;
    }

    function _stakeIntoMCPigs(uint256 _amountLP) internal {
        allowanceCheckAndSet(IERC20(Dogs_BNB_LpToken), address(MasterchefPigs), _amountLP);
        MasterchefPigs.deposit(DOGS_BNB_MC_PID, _amountLP);
        totalLpStaked += _amountLP;
        handlePigsIncrease();
    }

    function allowanceCheckAndSet(IERC20 _token, address _spender, uint256 _amount) internal {
        uint256 allowance = _token.allowance(address(this), _spender);
        if (allowance < _amount) {
            require(_token.approve(_spender, _amount), "allowance err");
        }
    }

    function initMCStake() public onlyOwner{
        require(initializeUnpaused);
        lastPigsBalance = PigsToken.balanceOf(address(this));
        uint256 balance = IERC20(Dogs_BNB_LpToken).balanceOf(address(this));
        allowanceCheckAndSet(IERC20(Dogs_BNB_LpToken), address(MasterchefPigs), balance);
        totalLPstakedTemp = ( balance - lpRoundMasktemp ) * 998 / 1000;
        allowanceCheckAndSet(IERC20(Dogs_BNB_LpToken), address(MasterchefPigs), balance);
        MasterchefPigs.deposit(DOGS_BNB_MC_PID, balance);
        totalLpStaked += (balance * 998) / 1000;
        handlePigsIncrease();    
    }
    
    function initStakeMult(uint256 temp1, uint256 temp2) public onlyOwner{
        require(initializeUnpaused);
        totalLPstakedTemp = temp1;
        totalLpStaked = temp2;
    }

    function addInitAllowed(address _ad, bool _bool) public onlyOwner{
        initAllowed[_ad] = _bool;
    }

    function updateBnbLiqThreshhold(uint256 newThrehshold) public onlyOwner {
        BnbLiquidateThreshold = newThrehshold;
    }

    function updateDogsBnBPID(uint256 newPid) public onlyOwner {
        DOGS_BNB_MC_PID = newPid;
    }

    function pauseInitialize() external onlyOwner {
        initializeUnpaused = false;
    }

    function updateDogsAndLPAddress(address _addressDogs, address _addressLpBNB) public onlyOwner {
        Dogs_BNB_LpToken = IERC20(_addressLpBNB);
        updateDogsAddress(_addressDogs);
    }

   function updateDogsAddress(address _address) public onlyOwner {
        DogsToken = IERC20(_address);
        dogsBnbPath = [wbnbCurrencyAddress,address(DogsToken)];
    }

    function updatePigsAddress(address _address) public onlyOwner {
        PigsToken = IERC20(_address);
    }
    
    function allowCompound(uint256 _time) public onlyOwner{
        require(_time <= timeSinceLastCall, "time in future");
        timeSinceLastCall = _time;
    }

    function updateDogsExchanceHelperAddress(address _address) public onlyOwner {
        DogsExchangeHelper = IDogsExchangeHelper(_address);
    }

    function updateMasterchefPigsAddress(address _address) public onlyOwner {
        require(!MClocked);
        MasterchefPigs = IMasterchefPigs(_address);
    }

    function changeUpdateInterval(uint256 _time) public onlyOwner{
        updateInterval = _time;
    }

    function MClockedAddress() external onlyOwner{
        MClocked = true;
    }

    function lockDogPoundManager() external onlyOwner{
        managerNotLocked = false;
    }

    function setDogPoundManager(address _address) public onlyOwner {
        require(managerNotLocked);
        DogPoundManger = _address;
    }

}import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/interfaces/IERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "./interfaces/IRewardsVault.sol";

interface Pool {
    
    struct UserInfo {
        uint256 totalStaked;
        uint256 bnbRewardDebt;
        uint256 totalBNBCollected;
    } 

    function userInfo(address key) view external returns (UserInfo memory);

    function accDepositBNBRewardPerShare (  ) external view returns ( uint256 );
    
    function bnbRewardBalance (  ) external view returns ( uint256 );

    function totalDeposited (  ) external view returns ( uint256 );

    function totalBNBCollected (  ) external view returns ( uint256 );

}

contract DogPoundLinearPool is Ownable, ReentrancyGuard {
    uint256 public accDepositBNBRewardPerShare = 0;
    uint256 public totalDeposited = 0;
    uint256 public bnbRewardBalance = 0;
    uint256 public totalBNBCollected = 0;
    bool public vaultPay = false;
    bool public initializeUnpaused = true;
    bool public managerNotLocked = true;
    IERC20 public DogsToken;
    IRewardsVault public rewardsVault;

    address public DogPoundManger;

    struct UserInfo {
        uint256 totalStaked;
        uint256 bnbRewardDebt;
        uint256 totalBNBCollected;
    }

    mapping(address => UserInfo) public userInfo;

    receive() external payable {}

    // Modifiers
    modifier onlyDogPoundManager() {
        require(DogPoundManger == msg.sender, "manager only");
        _;
    }

    constructor(address _DogPoundManger, address _rewardsVaultAddress) {
        rewardsVault = IRewardsVault(_rewardsVaultAddress);
        DogPoundManger = _DogPoundManger;
    }

    function initializeVars(DogPoundLinearPool _pool) onlyOwner public {
        require(initializeUnpaused);
        DogPoundLinearPool pool = DogPoundLinearPool(_pool);
        accDepositBNBRewardPerShare = pool.accDepositBNBRewardPerShare();
        totalDeposited =  pool.totalDeposited();
        bnbRewardBalance = pool.bnbRewardBalance();
        totalBNBCollected = pool.totalBNBCollected();
    }

    function initialize(DogPoundLinearPool _pool, address [] memory _users) onlyOwner public {
        require(initializeUnpaused);
        DogPoundLinearPool pool = DogPoundLinearPool(_pool);
        for(uint i = 0; i < _users.length; i++){
            (uint256 totalStaked, uint256 bnbRewardDebt, uint256 _totalBNBCollected ) =  pool.userInfo(_users[i]);
            userInfo[_users[i]].totalStaked =  totalStaked;
            userInfo[_users[i]].bnbRewardDebt =  bnbRewardDebt;
            userInfo[_users[i]].totalBNBCollected =  _totalBNBCollected;
        }
    }


    function initializeM(DogPoundLinearPool _pool, address [] memory _users, UserInfo [] memory _info) onlyOwner public {
        require(initializeUnpaused);
        DogPoundLinearPool pool = DogPoundLinearPool(_pool);
        accDepositBNBRewardPerShare = pool.accDepositBNBRewardPerShare();
        for(uint i = 0; i <= _users.length; i++){
            userInfo[_users[i]] = _info[i];
        }
    }


    function deposit(address _user, uint256 _amount)
        external
        onlyDogPoundManager
        nonReentrant
    {
        if (vaultPay) {
            rewardsVault.payoutDivs();
        }
        UserInfo storage user = userInfo[_user];
        updatePool();
        uint256 bnbPending = payPendingBNBReward(_user);
        totalDeposited += _amount;
        user.totalBNBCollected += bnbPending;
        user.totalStaked += _amount;
        user.bnbRewardDebt = ((user.totalStaked * accDepositBNBRewardPerShare) /
            1e24);
        if (bnbPending > 0) {
            payable(_user).transfer(bnbPending);
        }
    }

    function withdraw(address _user, uint256 _amount)
        external
        onlyDogPoundManager
        nonReentrant
    {
        if (vaultPay) {
            rewardsVault.payoutDivs();
        }
        UserInfo storage user = userInfo[_user];
        updatePool();
        uint256 bnbPending = payPendingBNBReward(_user);
        DogsToken.transfer(address(DogPoundManger), _amount); // must handle receiving in DogPoundManger
        user.totalBNBCollected += bnbPending;
        user.totalStaked -= _amount;
        totalDeposited -= _amount;
        user.bnbRewardDebt = ((user.totalStaked * accDepositBNBRewardPerShare) /
            1e24);
        if (bnbPending > 0) {
            payable(_user).transfer(bnbPending);
        }
    }

    function updatePool() public {
        if (totalDeposited > 0) {
            uint256 bnbReceived = checkBNBRewardsReceived();
            if (bnbReceived > 0) {
                accDepositBNBRewardPerShare =
                    accDepositBNBRewardPerShare +
                    ((bnbReceived * 1e24) / totalDeposited);
                totalBNBCollected += bnbReceived;
            }
        }
    }

    // Pay pending BNB from the DOGS staking reward scheme.
    function payPendingBNBReward(address _user) internal returns (uint256) {
        UserInfo storage user = userInfo[_user];

        uint256 bnbPending = ((user.totalStaked * accDepositBNBRewardPerShare) / 1e24) - user.bnbRewardDebt;
        
        if (bnbRewardBalance < bnbPending) {
            bnbPending = bnbRewardBalance;
            bnbRewardBalance = 0;
        } else if (bnbPending > 0) {
            bnbRewardBalance = bnbRewardBalance - bnbPending;
        }
        return bnbPending;
    }

    function pendingBNBReward(address _user) external view returns (uint256) {
        UserInfo storage user = userInfo[_user];
        uint256 bnbPending = ((user.totalStaked * accDepositBNBRewardPerShare) /
            1e24) - user.bnbRewardDebt;
        return bnbPending;
    }

    function claim() public nonReentrant {
        if (vaultPay) {
            rewardsVault.payoutDivs();
        }
        updatePool();
        uint256 bnbPending = payPendingBNBReward(msg.sender);
        UserInfo storage user = userInfo[msg.sender];
        user.totalBNBCollected += bnbPending;
        user.bnbRewardDebt = ((user.totalStaked * accDepositBNBRewardPerShare) /
            1e24);
        if (bnbPending > 0) {
            payable(msg.sender).transfer(bnbPending);
        }
    }

    function checkBNBRewardsReceived() internal returns (uint256) {
        uint256 totalBNBBalance = address(this).balance;
        if (totalBNBBalance == 0) {
            return 0;
        }

        uint256 bnbReceived = totalBNBBalance - bnbRewardBalance;
        bnbRewardBalance = totalBNBBalance;

        return bnbReceived;
    }

    function setVaultPay(bool _bool) external onlyOwner {
        vaultPay = _bool;
    }

    function switchRewardVault(address _newvault) external onlyOwner {
        rewardsVault = IRewardsVault(_newvault);
    }

    function pauseInitialize() external onlyOwner {
        initializeUnpaused = false;
    }

    function setDogsToken(address _address) public onlyOwner {
        DogsToken = IERC20(_address);
    }
    
    function lockDogPoundManager() external onlyOwner{
        managerNotLocked = false;
    }

    function setDogPoundManager(address _address) public onlyOwner {
        require(managerNotLocked);
        DogPoundManger = _address;
    }
}pragma solidity ^0.8.0;

import "@openzeppelin/contracts/interfaces/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import "./interfaces/IRewardsVault.sol";
import "./interfaces/IPancakePair.sol";
import "./interfaces/IMasterchefPigs.sol";
import "./interfaces/IPancakeFactory.sol";
import "./interfaces/IDogsToken.sol";
import "./interfaces/IDogPoundActions.sol";
import "./interfaces/IStakeManager.sol";
import "./interfaces/IRewardsVault.sol";


interface IDogPoundPool {
    function deposit(address _user, uint256 _amount) external;
    function withdraw(address _user, uint256 _amount) external;
    function getStake(address _user, uint256 _stakeID) external view returns(uint256 stakedAmount);
}

contract DogPoundManager is Ownable {
    using SafeERC20 for IERC20;

    IStakeManager public StakeManager = IStakeManager(0x25A959dDaEcEb50c1B724C603A57fe7b32eCbEeA);
    IDogPoundPool public DogPoundLinearPool = IDogPoundPool(0x935B36a774f2c04b8fA92acf3528d7DF681C0297);
    IDogPoundPool public DogPoundAutoPool = IDogPoundPool(0xf911D1d7118278f86eedfD94bC7Cd141D299E28D);
    IDogPoundActions public DogPoundActions;
    IRewardsVault public rewardsVault = IRewardsVault(0x4c004C4fB925Be396F902DE262F2817dEeBC22Ec);

    bool public isPaused;
    uint256 public walletReductionPerMonth = 200;
    uint256 public burnPercent = 30;
    uint256 public minHoldThreshold = 10e18;

    uint256 public loyaltyScoreMaxReduction = 3000;
    uint256 public dogsDefaultTax = 9000;
    uint256 public minDogVarTax = 300;
    uint256 public withdrawlRestrictionTime = 24 hours;
    DogPoundManager public oldDp = DogPoundManager(0x6dA8227Bc7B576781ffCac69437e17b8D4F4aE41);
    address public dogsToken = 0x198271b868daE875bFea6e6E4045cDdA5d6B9829;
    IDogsToken public DogsToken = IDogsToken(dogsToken);
    IUniswapV2Router02 public constant PancakeRouter = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
    uint256 public linearPoolSize = oldDp.linearPoolSize();
    uint256 public autoPoolSize = oldDp.autoPoolSize();

    struct UserInfo {
        uint256 walletStartTime;
        uint256 overThresholdTimeCounter;
        uint256 lastDepositTime;
        uint256 totalStaked;
    }

    struct StakeInfo {
        uint256 amount;
        uint256 startTime;
        bool isAutoPool;
    } 

    mapping(address => UserInfo) public userInfo;

    modifier notPaused() {
        require(!isPaused, "notPaused: DogPound paused !");
        _;
    }

    constructor(){
        _approveTokenIfNeeded(0x198271b868daE875bFea6e6E4045cDdA5d6B9829);
    }
    

    function deposit(uint256 _amount, bool _isAutoCompound) external notPaused {
        require(_amount > 0, 'deposit !> 0');
        initUser(msg.sender);
        StakeManager.saveStake(msg.sender, _amount, _isAutoCompound);
        DogsToken.transferFrom(msg.sender, address(this), _amount);
        if (StakeManager.totalStaked(msg.sender) >= minHoldThreshold && userInfo[msg.sender].walletStartTime == 0){
                userInfo[msg.sender].walletStartTime = block.timestamp;
        }
        if (_isAutoCompound){
            DogsToken.transfer(address(DogPoundAutoPool), _amount);
            DogPoundAutoPool.deposit(msg.sender, _amount);
            autoPoolSize += _amount;
        } else {
            DogsToken.transfer(address(DogPoundLinearPool), _amount);
            DogPoundLinearPool.deposit(msg.sender, _amount);
            linearPoolSize += _amount;
        }
        userInfo[msg.sender].totalStaked += _amount;
        userInfo[msg.sender].lastDepositTime = block.timestamp;

    }

    function withdrawToWallet(uint256 _amount, uint256 _stakeID) external notPaused {
        initUser(msg.sender);
        require(block.timestamp - userInfo[msg.sender].lastDepositTime > withdrawlRestrictionTime,"withdrawl locked");
        _withdraw(_amount, _stakeID);
        if (StakeManager.totalStaked(msg.sender) < minHoldThreshold && userInfo[msg.sender].walletStartTime > 0){
            userInfo[msg.sender].overThresholdTimeCounter += block.timestamp - userInfo[msg.sender].walletStartTime;
            userInfo[msg.sender].walletStartTime = 0;
        }
        DogsToken.updateTransferTaxRate(0);
        DogsToken.transfer(msg.sender, _amount);
        DogsToken.updateTransferTaxRate(dogsDefaultTax);
    }

    function swapFromWithdrawnStake(uint256 _amount, uint256 _stakeID, address[] memory path) public {
        initUser(msg.sender);
        StakeManager.utilizeWithdrawnStake(msg.sender, _amount, _stakeID);
        uint256 taxReduction = totalTaxReductionWithdrawnStake(msg.sender, _stakeID);
        DogsToken.transferFrom(msg.sender, address(this), _amount);
        doSwap(address(this), _amount, taxReduction, path);
        IERC20 transfertoken = IERC20(path[path.length - 1]);
        uint256 balance = transfertoken.balanceOf(address(this));
        uint256 balance2 = DogsToken.balanceOf(address(this));
        DogsToken.updateTransferTaxRate(0);
        DogsToken.transfer(msg.sender, balance2);
        DogsToken.updateTransferTaxRate(dogsDefaultTax);
        transfertoken.transfer(msg.sender, balance);
    }

    function transferFromWithdrawnStake(uint256 _amount, address _to, uint256 _stakeID) public {
        initUser(msg.sender);
        StakeManager.utilizeWithdrawnStake(msg.sender, _amount, _stakeID);
        uint256 taxReduction = totalTaxReductionWithdrawnStake(msg.sender, _stakeID);
        DogsToken.transferFrom(msg.sender, address(this), _amount);
        doTransfer(_to , _amount, taxReduction);
    }
    //loyalty methods can stay unchanged
    function swapDogsWithLoyalty(uint256 _amount, address[] memory path) public {
        initUser(msg.sender);
        uint256 taxReduction = totalTaxReductionLoyaltyOnly(msg.sender);
        DogsToken.transferFrom(msg.sender, address(this), _amount);
        doSwap(address(this), _amount, taxReduction, path);
        IERC20 transfertoken = IERC20(path[path.length - 1]);
        uint256 balance = transfertoken.balanceOf(address(this));
        uint256 balance2 = DogsToken.balanceOf(address(this));
        DogsToken.updateTransferTaxRate(0);
        DogsToken.transfer(msg.sender, balance2);
        DogsToken.updateTransferTaxRate(dogsDefaultTax);
        transfertoken.transfer(msg.sender, balance);
    }
    //loyalty methods can stay unchanged
    function transferDogsWithLoyalty(uint256 _amount, address _to) public {
        initUser(msg.sender);
        uint256 taxReduction = totalTaxReductionLoyaltyOnly(msg.sender);
        DogsToken.transferFrom(msg.sender, address(this), _amount);
        doTransfer(_to ,_amount, taxReduction);
    }

    function _approveTokenIfNeeded(address token) private {
        if (IERC20(token).allowance(address(this), address(PancakeRouter)) == 0) {
            IERC20(token).safeApprove(address(PancakeRouter), type(uint256).max);
        }
    }

    // Internal functions
    function _withdraw(uint256 _amount, uint256 _stakeID) internal {
        bool isAutoPool = StakeManager.isStakeAutoPool(msg.sender, _stakeID);
        StakeManager.withdrawFromStake(msg.sender ,_amount, _stakeID); //require amount makes sense for stake
        if (isAutoPool){
            DogPoundAutoPool.withdraw(msg.sender, _amount);
            autoPoolSize -= _amount;
        } else {
            DogPoundLinearPool.withdraw(msg.sender, _amount);
            linearPoolSize -= _amount;
        }
        userInfo[msg.sender].totalStaked -= _amount;
    }

    // View functions
    function walletTaxReduction(address _user) public view returns (uint256){
        UserInfo storage user = userInfo[_user];
        (uint256 e1, uint256 e2,uint256 _deptime, uint256 e3 )= readOldStruct(_user);
        if(user.lastDepositTime == 0 && _deptime != 0){
            uint256 currentReduction = 0;
            if (StakeManager.totalStaked(_user) < minHoldThreshold){
                currentReduction = (e2 / 30 days) * walletReductionPerMonth;
                if(currentReduction > loyaltyScoreMaxReduction){
                    return loyaltyScoreMaxReduction;
                }
                return currentReduction;
            }
            currentReduction = (((block.timestamp - e1) + e2) / 30 days) * walletReductionPerMonth;
            if(currentReduction > loyaltyScoreMaxReduction){
                return loyaltyScoreMaxReduction;
            }
            return currentReduction;  

        }
        uint256 currentReduction = 0;
        if (StakeManager.totalStaked(_user) < minHoldThreshold){
            currentReduction = (user.overThresholdTimeCounter / 30 days) * walletReductionPerMonth;
            if(currentReduction > loyaltyScoreMaxReduction){
                return loyaltyScoreMaxReduction;
            }
            return currentReduction;
        }
        currentReduction = (((block.timestamp - user.walletStartTime) + user.overThresholdTimeCounter) / 30 days) * walletReductionPerMonth;
        if(currentReduction > loyaltyScoreMaxReduction){
            return loyaltyScoreMaxReduction;
        }
        return currentReduction;    
    }

    function totalTaxReductionLoyaltyOnly(address _user)public view returns (uint256){
        uint256 walletReduction = walletTaxReduction(_user);
        if(walletReduction > (dogsDefaultTax - minDogVarTax)){
            walletReduction = (dogsDefaultTax - minDogVarTax);
        }else{
            walletReduction = dogsDefaultTax - walletReduction - minDogVarTax;
        }
        return walletReduction;
    }
    

    function totalTaxReductionWithdrawnStake(address _user, uint256 _stakeID) public view returns (uint256){
        uint256 stakeReduction = StakeManager.getWithdrawnStakeTaxReduction(_user, _stakeID);
        uint256 walletReduction = walletTaxReduction(_user);
        uint256 _totalTaxReduction = stakeReduction + walletReduction;
        if(_totalTaxReduction >= (dogsDefaultTax - (2 * minDogVarTax))){
            _totalTaxReduction = 300;
        }else{
            _totalTaxReduction = dogsDefaultTax - _totalTaxReduction - minDogVarTax;
        }
        return _totalTaxReduction;
    }

    function readOldStruct2(address _user) public view returns (uint256, uint256, uint256, uint256){
        if(userInfo[_user].lastDepositTime == 0){
                return oldDp.userInfo(_user);
            }
        return (userInfo[_user].walletStartTime,userInfo[_user].overThresholdTimeCounter,userInfo[_user].lastDepositTime,userInfo[_user].totalStaked );
    }

    function setminHoldThreshold(uint256 _minHoldThreshold) external onlyOwner{
        minHoldThreshold = _minHoldThreshold;
    }

    function setPoolSizes(uint256 s1, uint256 s2) external onlyOwner {
        linearPoolSize = s1;
        autoPoolSize = s2;
    }

    function setAutoPool(address _autoPool) external onlyOwner {
        DogPoundAutoPool = IDogPoundPool(_autoPool);
    }

    function setLinearPool(address _linearPool) external onlyOwner {
        DogPoundLinearPool = IDogPoundPool(_linearPool);
    }

    function setStakeManager(IStakeManager _stakeManager) external onlyOwner {
        StakeManager = _stakeManager;
    }

    function changeWalletReductionRate(uint256 walletReduction) external onlyOwner{
        require(walletReduction < 1000);
        walletReductionPerMonth = walletReduction;
    }

    function changeWalletCapReduction(uint256 walletReductionCap) external onlyOwner{
        require(walletReductionCap < 6000);
        loyaltyScoreMaxReduction = walletReductionCap;
    }

    function getAutoPoolSize() external view returns (uint256){
        if(linearPoolSize == 0 ){
            return 0;
        }
        return (autoPoolSize*10000/(linearPoolSize+autoPoolSize));
    }

    function totalStaked(address _user) external view returns (uint256){
        return userInfo[_user].totalStaked;
    }

    function changeBurnPercent(uint256 newBurn) external onlyOwner{
        require(burnPercent < 200);
        burnPercent = newBurn;
    }

    function initUser(address _user) internal {
        if(userInfo[_user].lastDepositTime == 0){
            (uint256 e, uint256 e2,uint256 _deptime, uint256 e3 )= readOldStruct(_user);
            if(_deptime != 0){
                userInfo[_user].walletStartTime = e; 
                userInfo[_user].overThresholdTimeCounter = e2;
                userInfo[_user].lastDepositTime = _deptime;
                userInfo[_user].totalStaked = e3;
            }
        }
    }

    function readOldStruct(address _user) public view returns (uint256, uint256, uint256, uint256){
        return oldDp.userInfo(_user);
    }

    function doSwap(address _to, uint256 _amount, uint256 _taxReduction, address[] memory path) internal  {
        uint256 burnAmount = (_amount * burnPercent)/1000;
        uint256 leftAmount =  _amount - burnAmount;
        uint256 tempTaxval = 1e14/(1e3 - burnPercent);
        uint256 taxreductionNew = (_taxReduction * tempTaxval) / 1e11;

        DogsToken.updateTransferTaxRate(taxreductionNew);
        // make the swap
        PancakeRouter.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            leftAmount,
            0, // accept any amount of tokens
            path,
            _to,
            block.timestamp
        );

        DogsToken.updateTransferTaxRate(dogsDefaultTax);

        DogsToken.burn(burnAmount);

    }

    function doTransfer(address _to, uint256 _amount, uint256 _taxReduction) internal {
        uint256 burnAmount = (_amount * burnPercent)/1000;
        uint256 leftAmount =  _amount - burnAmount;
        uint256 tempTaxval = 1e14/(1e3 - burnPercent);
        uint256 taxreductionNew = (_taxReduction * tempTaxval) / 1e11;

        DogsToken.updateTransferTaxRate(taxreductionNew);

        DogsToken.transfer(_to, leftAmount);

        DogsToken.updateTransferTaxRate(dogsDefaultTax);

        DogsToken.burn(burnAmount);

    }

    function setDogsTokenAndDefaultTax(address _address, uint256 _defaultTax) external onlyOwner {
        DogsToken = IDogsToken(_address);
        dogsDefaultTax = _defaultTax;
    }

    function setRewardsVault(address _rewardsVaultAddress) public onlyOwner{
        rewardsVault = IRewardsVault(_rewardsVaultAddress);
    }

}pragma solidity ^0.8.0;

import "@openzeppelin/contracts/interfaces/IERC20.sol";
import "@openzeppelin/contracts/interfaces/IERC721.sol";

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import "./interfaces/IRewardsVault.sol";
import "./interfaces/IPancakePair.sol";
import "./interfaces/IMasterchefPigs.sol";
import "./interfaces/IPancakeFactory.sol";
import "./interfaces/IDogsToken.sol";
import "./interfaces/IDogPoundActions.sol";
import "./interfaces/IStakeManager.sol";
import "./interfaces/IRewardsVault.sol";
import ".//DogsNftManager.sol";
import "./DogPoundManager.sol";
import "./StakeManager.sol";
import "./StakeManagerV2.sol";
import "./NftPigMcStakingBusd.sol";

interface IDPMOLD {
    function linearPoolSize() external view returns (uint256);

    function autoPoolSize() external view returns (uint256);

    function userInfo(
        address
    ) external view returns (uint256, uint256, uint256, uint256);
}

contract DogPoundManagerV3 is Ownable {
    using SafeERC20 for IERC20;

    DogsNftManager public nftManager;
    StakeManager public stakeManagerV1 =
        StakeManager(0x25A959dDaEcEb50c1B724C603A57fe7b32eCbEeA);
    StakeManagerV2 public stakeManager;
    IDogPoundPool public DogPoundLinearPool =
        IDogPoundPool(0x935B36a774f2c04b8fA92acf3528d7DF681C0297);
    IDogPoundPool public DogPoundAutoPool =
        IDogPoundPool(0xf911D1d7118278f86eedfD94bC7Cd141D299E28D);
    IDogPoundActions public DogPoundActions;
    IRewardsVault public rewardsVault =
        IRewardsVault(0x4c004C4fB925Be396F902DE262F2817dEeBC22Ec);

    uint256 public walletReductionPerMonth = 200;
    uint256 public burnPercent = 30;
    uint256 public minHoldThreshold = 10e18;
    uint256 public dustAmount = 100000;
    uint256 public loyaltyScoreMaxReduction = 1000;
    uint256 public dogsDefaultTax = 9000;
    uint256 public minDogVarTax = 300;
    uint256 public withdrawlRestrictionTime = 24 hours;
    DogPoundManager public oldDp =
        DogPoundManager(0x1Bc00F2076A97A68511109883B0671721ff51955);
    IDPMOLD public oldOldDp =
        IDPMOLD(0x6dA8227Bc7B576781ffCac69437e17b8D4F4aE41);
    address public dogsToken = 0x198271b868daE875bFea6e6E4045cDdA5d6B9829;
    NftPigMcStakingBusd public nftStakeBusd;
    NftPigMcStakingBusd public nftStakeBnb;
    IDogsToken public DogsToken = IDogsToken(dogsToken);
    IUniswapV2Router02 public constant PancakeRouter =
        IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
    uint256 public linearPoolSize;
    uint256 public autoPoolSize;

    struct UserInfo {
        uint256 walletStartTime;
        uint256 overThresholdTimeCounter;
        uint256 lastDepositTime;
        uint256 totalStaked;
    }

    struct StakeInfo {
        uint256 amount;
        uint256 startTime;
        bool isAutoPool;
    }

    mapping(address => UserInfo) public userInfo;

    constructor(
        address _nftManager,
        address _nftStakeBusd,
        address _nftStakeBnb
    ) {
        nftStakeBusd = NftPigMcStakingBusd(payable(_nftStakeBusd));
        nftStakeBnb = NftPigMcStakingBusd(payable(_nftStakeBnb));
        nftManager = DogsNftManager(_nftManager);

        autoPoolSize = oldDp.autoPoolSize();
        linearPoolSize = oldDp.linearPoolSize();
        _approveTokenIfNeeded(
            0x198271b868daE875bFea6e6E4045cDdA5d6B9829,
            address(PancakeRouter)
        );
        _approveTokenIfNeeded(
            0x198271b868daE875bFea6e6E4045cDdA5d6B9829,
            address(_nftManager)
        );
    }

    function deposit(uint256 _amount, bool _isAutoCompound) external {
        require(_amount > 0, "deposit !> 0");
        initUser(msg.sender);
        stakeManager.saveStake(msg.sender, _amount, _isAutoCompound);
        DogsToken.transferFrom(msg.sender, address(this), _amount);
        if (
            userInfo[msg.sender].totalStaked + _amount >= minHoldThreshold &&
            userInfo[msg.sender].walletStartTime == 0
        ) {
            userInfo[msg.sender].walletStartTime = block.timestamp;
        }
        if (_isAutoCompound) {
            DogsToken.transfer(address(DogPoundAutoPool), _amount);
            DogPoundAutoPool.deposit(msg.sender, _amount);
            autoPoolSize += _amount;
        } else {
            DogsToken.transfer(address(DogPoundLinearPool), _amount);
            DogPoundLinearPool.deposit(msg.sender, _amount);
            linearPoolSize += _amount;
        }
        userInfo[msg.sender].totalStaked += _amount;
        userInfo[msg.sender].lastDepositTime = block.timestamp;
    }

    function depositOldUserInit(
        uint256 _amount,
        bool _isAutoCompound,
        uint256 _lastActiveStake
    ) external {
        require(_amount > 0, "deposit !> 0");
        initUser(msg.sender);
        stakeManager.saveStakeOldUserInit(
            msg.sender,
            _amount,
            _isAutoCompound,
            _lastActiveStake
        );
        DogsToken.transferFrom(msg.sender, address(this), _amount);
        if (
            userInfo[msg.sender].totalStaked >= minHoldThreshold &&
            userInfo[msg.sender].walletStartTime == 0
        ) {
            userInfo[msg.sender].walletStartTime = block.timestamp;
        }
        if (_isAutoCompound) {
            DogsToken.transfer(address(DogPoundAutoPool), _amount);
            DogPoundAutoPool.deposit(msg.sender, _amount);
            autoPoolSize += _amount;
        } else {
            DogsToken.transfer(address(DogPoundLinearPool), _amount);
            DogPoundLinearPool.deposit(msg.sender, _amount);
            linearPoolSize += _amount;
        }
        userInfo[msg.sender].totalStaked += _amount;
        userInfo[msg.sender].lastDepositTime = block.timestamp;
    }

    function withdrawToWallet(uint256 _amount, uint256 _stakeID) external {
        initUser(msg.sender);
        require(
            block.timestamp - userInfo[msg.sender].lastDepositTime >
                withdrawlRestrictionTime,
            "withdrawl locked"
        );
        _withdraw(_amount, _stakeID);
        if (
            userInfo[msg.sender].totalStaked < minHoldThreshold &&
            userInfo[msg.sender].walletStartTime > 0
        ) {
            userInfo[msg.sender].overThresholdTimeCounter +=
                block.timestamp -
                userInfo[msg.sender].walletStartTime;
            userInfo[msg.sender].walletStartTime = 0;
        }
    }

    function swapFromWithdrawnStake(
        uint256 _amount,
        uint256 _tokenID,
        address[] memory path
    ) public {
        initUser(msg.sender);
        uint256 taxReduction = totalTaxReductionWithdrawnStake(
            msg.sender,
            _tokenID
        );
        nftManager.transferFrom(msg.sender, address(this), _tokenID);
        nftManager.useNFTbalance(_tokenID, _amount, address(this));
        doSwap(address(this), _amount, taxReduction, path);
        IERC20 transfertoken = IERC20(path[path.length - 1]);
        uint256 balance = transfertoken.balanceOf(address(this));
        uint256 balance2 = DogsToken.balanceOf(address(this));
        nftManager.returnNFTbalance(_tokenID, balance2, address(this));
        nftManager.utilizeNFTbalance(_tokenID, _amount - balance2);
        transfertoken.transfer(msg.sender, balance);
        if (
            nftManager.nftPotentialBalance(_tokenID) +
                nftStakeBnb.lpAmount(_tokenID) +
                nftStakeBusd.lpAmount(_tokenID) >
            dustAmount
        ) {
            nftManager.transferFrom(address(this), msg.sender, _tokenID);
        } else {
            nftManager.transferFrom(
                address(this),
                0x000000000000000000000000000000000000dEaD,
                _tokenID
            );
        }
    }

    function transferFromWithdrawnStake(
        uint256 _amount,
        address _to,
        uint256 _tokenID
    ) public {
        initUser(msg.sender);
        uint256 taxReduction = totalTaxReductionWithdrawnStake(
            msg.sender,
            _tokenID
        );
        nftManager.transferFrom(msg.sender, address(this), _tokenID);
        nftManager.useNFTbalance(_tokenID, _amount, address(this));
        nftManager.utilizeNFTbalance(_tokenID, _amount);
        doTransfer(_to, _amount, taxReduction);
        if (
            nftManager.nftPotentialBalance(_tokenID) +
                nftStakeBnb.lpAmount(_tokenID) +
                nftStakeBusd.lpAmount(_tokenID) >
            dustAmount
        ) {
            nftManager.transferFrom(address(this), msg.sender, _tokenID);
        } else {
            nftManager.transferFrom(
                address(this),
                0x000000000000000000000000000000000000dEaD,
                _tokenID
            );
        }
    }

    function returnNftBalanceThroughManager(
        uint256 _tokenID,
        uint256 _amount
    ) public {
        nftManager.transferFrom(msg.sender, address(this), _tokenID);
        DogsToken.transferFrom(msg.sender, address(this), _amount);
        nftManager.returnNFTbalance(_tokenID, _amount, address(this));
        nftManager.transferFrom(address(this), msg.sender, _tokenID);
    }

    function _approveTokenIfNeeded(address token, address _address) private {
        if (IERC20(token).allowance(address(this), address(_address)) == 0) {
            IERC20(token).safeApprove(address(_address), type(uint256).max);
        }
    }

    // Internal functions
    function _withdraw(uint256 _amount, uint256 _stakeID) internal {
        bool isAutoPool = stakeManager.isStakeAutoPool(msg.sender, _stakeID);
        if (isAutoPool) {
            DogPoundAutoPool.withdraw(msg.sender, _amount);
            autoPoolSize -= _amount;
        } else {
            DogPoundLinearPool.withdraw(msg.sender, _amount);
            linearPoolSize -= _amount;
        }
        stakeManager.withdrawFromStake(
            msg.sender,
            _amount,
            _stakeID,
            address(this)
        );
        userInfo[msg.sender].totalStaked -= _amount;
    }

    // View functions
    function walletTaxReduction(address _user) public view returns (uint256) {
        UserInfo storage user = userInfo[_user];
        uint256 walletStartTime = user.walletStartTime;
        uint256 overThresholdTimeCounter = user.overThresholdTimeCounter;
        uint256 totalStaked = user.totalStaked;
        if (user.lastDepositTime == 0) {
            (walletStartTime, overThresholdTimeCounter, , ) = oldDp
                .readOldStruct2(_user);
            totalStaked = stakeManagerV1.totalStaked(_user);
        }
        uint256 currentReduction = 0;
        if (totalStaked < minHoldThreshold) {
            currentReduction =
                (overThresholdTimeCounter / 30 days) *
                walletReductionPerMonth;
            if (currentReduction > loyaltyScoreMaxReduction) {
                return loyaltyScoreMaxReduction;
            }
            return currentReduction;
        }
        currentReduction =
            (((block.timestamp - walletStartTime) + overThresholdTimeCounter) /
                30 days) *
            walletReductionPerMonth;
        if (currentReduction > loyaltyScoreMaxReduction) {
            return loyaltyScoreMaxReduction;
        }
        return currentReduction;
    }

    function totalTaxReductionWithdrawnStake(
        address _user,
        uint256 _tokenID
    ) public view returns (uint256) {
        uint256 stakeReduction = stakeManager.getWithdrawnStakeTaxReduction(
            _tokenID
        );
        uint256 walletReduction = walletTaxReduction(_user);
        uint256 _totalTaxReduction = stakeReduction + walletReduction;
        if (_totalTaxReduction >= (dogsDefaultTax - (2 * minDogVarTax))) {
            _totalTaxReduction = 300;
        } else {
            _totalTaxReduction =
                dogsDefaultTax -
                _totalTaxReduction -
                minDogVarTax;
        }
        return _totalTaxReduction;
    }

    function transitionOldWithdrawnStake(
        address _user,
        uint256 _stakeID
    ) external {
        uint256 _amount = stakeManager
            .withdrawnStakeMove(_user, _stakeID)
            .amount;
        DogsToken.transferFrom(msg.sender, address(this), _amount);
        stakeManager.transitionOldWithdrawnStake(
            _user,
            _stakeID,
            address(this)
        );
    }

    function readOldStruct2(
        address _user
    ) public view returns (uint256, uint256, uint256, uint256) {
        if (userInfo[_user].lastDepositTime == 0) {
            return oldDp.readOldStruct2(_user);
        }
        return (
            userInfo[_user].walletStartTime,
            userInfo[_user].overThresholdTimeCounter,
            userInfo[_user].lastDepositTime,
            userInfo[_user].totalStaked
        );
    }

    function setminHoldThreshold(uint256 _minHoldThreshold) external onlyOwner {
        minHoldThreshold = _minHoldThreshold;
    }

    function setPoolSizes(uint256 s1, uint256 s2) external onlyOwner {
        linearPoolSize = s1;
        autoPoolSize = s2;
    }

    function setAutoPool(address _autoPool) external onlyOwner {
        DogPoundAutoPool = IDogPoundPool(_autoPool);
    }

    function setLinearPool(address _linearPool) external onlyOwner {
        DogPoundLinearPool = IDogPoundPool(_linearPool);
    }

    function setNftManager(address _nftManager) external onlyOwner {
        nftManager = DogsNftManager(_nftManager);
        _approveTokenIfNeeded(
            0x198271b868daE875bFea6e6E4045cDdA5d6B9829,
            address(nftManager)
        );
    }

    function setStakeManager(address _stakeManager) external onlyOwner {
        stakeManager = StakeManagerV2(_stakeManager);
    }

    function changeWalletReductionRate(
        uint256 walletReduction
    ) external onlyOwner {
        require(walletReduction < 1000);
        walletReductionPerMonth = walletReduction;
    }

    function changeWalletCapReduction(
        uint256 walletReductionCap
    ) external onlyOwner {
        require(walletReductionCap < 6000);
        loyaltyScoreMaxReduction = walletReductionCap;
    }

    function getAutoPoolSize() external view returns (uint256) {
        if (linearPoolSize == 0) {
            return 0;
        }
        return ((autoPoolSize * 10000) / (linearPoolSize + autoPoolSize));
    }

    function totalStaked(address _user) external view returns (uint256) {
        return userInfo[_user].totalStaked;
    }

    function changeBurnPercent(uint256 newBurn) external onlyOwner {
        require(burnPercent < 200);
        burnPercent = newBurn;
    }

    function initUser(address _user) internal {
        if (userInfo[_user].lastDepositTime == 0) {
            (uint256 e, uint256 e2, uint256 _deptime, uint256 e3) = oldDp
                .readOldStruct2(_user);
            if (_deptime != 0) {
                userInfo[_user].walletStartTime = e;
                userInfo[_user].overThresholdTimeCounter = e2;
                userInfo[_user].lastDepositTime = _deptime;
                userInfo[_user].totalStaked = stakeManagerV1.totalStaked(_user);
            }
        }
    }

    function readOldStruct(
        address _user
    ) public view returns (uint256, uint256, uint256, uint256) {
        return oldDp.userInfo(_user);
    }

    function readOldOldStruct(
        address _user
    ) public view returns (uint256, uint256, uint256, uint256) {
        return oldOldDp.userInfo(_user);
    }

    function doSwap(
        address _to,
        uint256 _amount,
        uint256 _taxReduction,
        address[] memory path
    ) internal {
        uint256 burnAmount = (_amount * burnPercent) / 1000;
        uint256 leftAmount = _amount - burnAmount;
        uint256 tempTaxval = 1e14 / (1e3 - burnPercent);
        uint256 taxreductionNew = (_taxReduction * tempTaxval) / 1e11;

        DogsToken.updateTransferTaxRate(taxreductionNew);
        // make the swap
        PancakeRouter.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            leftAmount,
            0, // accept any amount of tokens
            path,
            _to,
            block.timestamp
        );

        DogsToken.updateTransferTaxRate(dogsDefaultTax);

        DogsToken.burn(burnAmount);
    }

    function doTransfer(
        address _to,
        uint256 _amount,
        uint256 _taxReduction
    ) internal {
        uint256 burnAmount = (_amount * burnPercent) / 1000;
        uint256 leftAmount = _amount - burnAmount;
        uint256 tempTaxval = 1e14 / (1e3 - burnPercent);
        uint256 taxreductionNew = (_taxReduction * tempTaxval) / 1e11;

        DogsToken.updateTransferTaxRate(taxreductionNew);

        DogsToken.transfer(_to, leftAmount);

        DogsToken.updateTransferTaxRate(dogsDefaultTax);

        DogsToken.burn(burnAmount);
    }

    function setDogsTokenAndDefaultTax(
        address _address,
        uint256 _defaultTax
    ) external onlyOwner {
        DogsToken = IDogsToken(_address);
        dogsDefaultTax = _defaultTax;
    }

    function setRewardsVault(address _rewardsVaultAddress) public onlyOwner {
        rewardsVault = IRewardsVault(_rewardsVaultAddress);
    }
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/interfaces/IERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";


contract DogClaim is Ownable, ReentrancyGuard {

    bool public isCreditingActive = false;
    mapping(address => uint256) public userClaimInfo;
    IERC20 public DogsToken;

    constructor(IERC20 _dogsToken){
        DogsToken = _dogsToken;
    }

    function claimDogs() external nonReentrant {
        require(isCreditingActive, 'not active yet');

        uint256 amountClaimable = userClaimInfo[msg.sender];
        require(amountClaimable > 0, 'nothing to claim');

        DogsToken.transfer(msg.sender, amountClaimable);

        userClaimInfo[msg.sender] = 0;
    }

    function setUserClaimInfo(address[] memory _users, uint256[] memory _usersClaimData) external onlyOwner {
        require(_users.length == _usersClaimData.length);
        for (uint256 i = 0; i < _users.length; i++) {
            userClaimInfo[_users[i]] = _usersClaimData[i];
        }
    }

    // Admin Functions
    function toggleCreditingActive(bool _isActive) external onlyOwner {
        isCreditingActive = _isActive;
    }

    function recoverDogs(address _token, uint256 _amount, address _to) external onlyOwner {
        IERC20(_token).transfer(_to, _amount);
    }
}pragma solidity ^0.8.0;

import "@openzeppelin/contracts/interfaces/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";

import "./interfaces/IDogsToken.sol";
import "./interfaces/IStakeManager.sol";

contract DogsNftManager is Ownable, ERC721, ERC721Enumerable {
    using SafeERC20 for IERC20;
    using Strings for uint256;
    mapping(address => bool) public allowedAddress;
    mapping(uint256 => uint256) public nftHoldingBalance;
    mapping(uint256 => uint256) public nftPotentialBalance;
    mapping(uint256 => uint256) public nftLastTime;
    string public baseURI;
    string public baseExtension = ".json";
    address public dogsToken = 0x198271b868daE875bFea6e6E4045cDdA5d6B9829;
    IDogsToken public DogsToken = IDogsToken(dogsToken);
    uint256 currentTokenID = 0;
    uint256 limitTime = 300;
    modifier onlyAllowedAddress() {
        require(allowedAddress[msg.sender], "allowed only");
        _;
    }

    constructor() ERC721("testnft", "TEST") {}

    function mintForWithdrawnStake(
        address _to,
        uint256 _amount,
        address _from
    ) external onlyAllowedAddress returns (uint256) {
        uint256 tokenID = currentTokenID;
        DogsToken.transferFrom(_from, address(this), _amount);
        _safeMint(_to, tokenID);
        nftHoldingBalance[tokenID] = _amount;
        nftPotentialBalance[tokenID] = _amount;
        currentTokenID += 1;
        return tokenID;
    }

    function useNFTbalance(
        uint256 _tokenID,
        uint256 _amount,
        address _to
    ) external onlyAllowedAddress {
        require(
            _amount <= nftHoldingBalance[_tokenID],
            "not enough tokens inside nft"
        );
        require(ownerOf(_tokenID) == msg.sender, "caller doesnt own nft");
        nftHoldingBalance[_tokenID] -= _amount;
        DogsToken.transfer(_to, _amount);
        nftLastTime[_tokenID] = block.timestamp;
    }

    function utilizeNFTbalance(
        uint256 _tokenID,
        uint256 _amount
    ) external onlyAllowedAddress {
        require(
            nftPotentialBalance[_tokenID] >= _amount &&
                (nftPotentialBalance[_tokenID] - _amount) >=
                nftHoldingBalance[_tokenID],
            "attempt to over utilize"
        );
        require(ownerOf(_tokenID) == msg.sender, "caller doesnt own nft");
        nftPotentialBalance[_tokenID] -= _amount;
        nftLastTime[_tokenID] = block.timestamp;
    }

    function returnNFTbalance(
        uint256 _tokenID,
        uint256 _amount,
        address _from
    ) external onlyAllowedAddress {
        require(
            (nftHoldingBalance[_tokenID] + _amount) <=
                nftPotentialBalance[_tokenID],
            "attempt to over deposit"
        );
        nftHoldingBalance[_tokenID] += _amount;
        DogsToken.transferFrom(_from, address(this), _amount);
        nftLastTime[_tokenID] = block.timestamp;
    }

    function returnNFTbalancePublic(
        uint256 _tokenID,
        uint256 _amount
    ) external {
        require(
            (nftHoldingBalance[_tokenID] + _amount) <=
                nftPotentialBalance[_tokenID],
            "attempt to over deposit"
        );
        require(
            ownerOf(_tokenID) == msg.sender,
            "you must own the nft you want to fill"
        );
        nftHoldingBalance[_tokenID] += _amount;
        DogsToken.transferFrom(msg.sender, address(this), _amount);
        nftLastTime[_tokenID] = block.timestamp;
    }

    function setAllowedAddress(address _address, bool _state) public onlyOwner {
        allowedAddress[_address] = _state;
    }

    function _transfer(
        address from,
        address to,
        uint256 tokenId
    ) internal override {
        require(
            (block.timestamp - nftLastTime[tokenId]) >= limitTime ||
                allowedAddress[from] ||
                allowedAddress[to],
            "transfer cooldown"
        );
        super._transfer(from, to, tokenId);
    }

    function setCooldown(uint256 _cooldown) external onlyOwner {
        limitTime = _cooldown;
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal override(ERC721, ERC721Enumerable) {
        super._beforeTokenTransfer(from, to, tokenId);
    }

    function supportsInterface(
        bytes4 interfaceId
    ) public view override(ERC721, ERC721Enumerable) returns (bool) {
        return super.supportsInterface(interfaceId);
    }

    function tokenURI(
        uint256 tokenId
    ) public view virtual override returns (string memory) {
        require(
            _exists(tokenId),
            "ERC721Metadata: URI query for nonexistent token"
        );
        string memory currentBaseURI = _baseURI();
        return
            bytes(currentBaseURI).length > 0
                ? string(
                    abi.encodePacked(
                        currentBaseURI,
                        tokenId.toString(),
                        baseExtension
                    )
                )
                : "";
    }

    function setBaseURI(string memory _newBaseURI) public onlyOwner {
        baseURI = _newBaseURI;
    }

    function setBaseExtension(
        string memory _newBaseExtension
    ) public onlyOwner {
        baseExtension = _newBaseExtension;
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return baseURI;
    }
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/interfaces/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import "./interfaces/IFeeManagerDogs.sol";
import "./interfaces/IDogPound.sol";

import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";
import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Pair.sol";
import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Factory.sol";

contract DogsTokenV2 is ERC20("Animal Farm Dogs", "AFD"), Ownable {
    using SafeERC20 for IERC20;

    uint256 public TxBaseTax = 9000; // 90%
    uint256 public TxBurnRate = 333; // 3.33%
    uint256 public TxVaultRewardRate = 9666; // 96.66%

    uint256 public constant MAXIMUM_TX_BASE_TAX = 9001; // Max transfer tax rate: 90.01%.
    uint256 public constant ZERO_TAX_INT = 10001; // Special 0 tax int

    address public constant BUSD_ADDRESS = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;
    IERC20 public constant busdRewardCurrency = IERC20(BUSD_ADDRESS);

    address public constant BURN_ADDRESS = 0x000000000000000000000000000000000000dEaD;

    address public constant PANCAKESWAP_ROUTER_ADDRESS = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    IUniswapV2Router02 public pancakeswapRouter = IUniswapV2Router02(PANCAKESWAP_ROUTER_ADDRESS);

    address public dogsBusdSwapPair;
    address public dogsWbnbSwapPair;

    bool public swapAndLiquifyEnabled = false; // Automatic swap and liquify enabled
    bool private _inSwapAndLiquify;  // In swap and liquify

    IFeeManagerDogs public FeeManagerDogs;

    mapping(address => bool) public txTaxOperators;

    mapping(address => bool) public liquifyExemptFrom;
    mapping(address => bool) public liquifyExemptTo;

    mapping(address => uint256) public customTaxRateFrom;
    mapping(address => uint256) public customTaxRateTo;

    // Events
    event Burn(address indexed sender, uint256 amount);
    event SetSwapAndLiquifyEnabled(bool swapAndLiquifyEnabled);
    event TransferTaxChanged(uint256 txBaseTax);
    event TransferTaxDistributionChanged(uint256 baseBurnRate, uint256 vaultRewardRate);
    event UpdateCustomTaxRateFrom(address _account, uint256 _taxRate);
    event UpdateCustomTaxRateTo(address _account, uint256 _taxRate);
    event SetOperator(address operator);
    event SetFeeManagerDogs(address feeManagerDogs);
    event SetTxTaxOperator(address taxOperator, bool isOperator);

    // The operator can use admin functions
    address public _operator;

    // AB measures
    mapping(address => bool) private blacklistFrom;
    mapping(address => bool) private blacklistTo;
    mapping (address => bool) private _isExcludedFromLimiter;
    bool private blacklistFeatureAllowed = true;

    bool private transfersPaused = true;
    bool private transfersPausedFeatureAllowed = true;

    bool private sellingEnabled = false;
    bool private sellingToggleAllowed = true;

    bool private buySellLimiterEnabled = true;
    bool private buySellLimiterAllowed = true;
    uint256 private buySellLimitThreshold = 500e18;

    // AB events
    event LimiterUserUpdated(address account, bool isLimited);
    event BlacklistUpdated(address account, bool blacklisted);
    event TransferStatusUpdate(bool isPaused);
    event TransferPauseFeatureBurn();
    event SellingToggleFeatureBurn();
    event BuySellLimiterUpdate(bool isEnabled, uint256 amount);
    event SellingEnabledToggle(bool enabled);
    event LimiterFeatureBurn();
    event BlacklistingFeatureBurn();

    modifier onlyOperator() {
        require(_operator == msg.sender, "!operator");
        _;
    }

    modifier onlyTxTaxOperator() {
        require(txTaxOperators[msg.sender], "!txTaxOperator");
        _;
    }

    modifier lockTheSwap {
        _inSwapAndLiquify = true;
        _;
        _inSwapAndLiquify = false;
    }

    modifier transferTaxFree {
        uint256 _TxBaseTaxPrevious = TxBaseTax;
        TxBaseTax = 0;
        _;
        TxBaseTax = _TxBaseTaxPrevious;

    }

    /**
     * @notice Constructs the Dogs Token contract.
     */
    constructor(address _addLiquidityHelper) {

        _operator = msg.sender;
        txTaxOperators[msg.sender] = true;

        // Create BUSD and WBNB pairs
        dogsBusdSwapPair = IUniswapV2Factory(pancakeswapRouter.factory()).createPair(address(this), BUSD_ADDRESS);
        dogsWbnbSwapPair = IUniswapV2Factory(pancakeswapRouter.factory()).createPair(address(this), pancakeswapRouter.WETH());

        // Exclude from AB limiter
        _isExcludedFromLimiter[msg.sender] = true;
        _isExcludedFromLimiter[_addLiquidityHelper] = true; // needs to be false for initial launch

        // Apply custom Taxes
        // Buying / Remove Liq directly on PCS incurs 6% tax.
        customTaxRateFrom[dogsBusdSwapPair] = 600;
        customTaxRateFrom[dogsWbnbSwapPair] = 600;

        // Adding liquidity via helper is tax free
        customTaxRateFrom[_addLiquidityHelper] = ZERO_TAX_INT;
        customTaxRateTo[_addLiquidityHelper] = ZERO_TAX_INT;

        // Operator is untaxed
        customTaxRateFrom[msg.sender] = ZERO_TAX_INT;

        // Sending to Burn address is tax free
        customTaxRateTo[BURN_ADDRESS] = ZERO_TAX_INT;

        // Exclude add liquidityHelper from triggering liquification
        liquifyExemptFrom[_addLiquidityHelper] = true;
        liquifyExemptTo[_addLiquidityHelper] = true;

        liquifyExemptFrom[dogsBusdSwapPair] = true;
        liquifyExemptTo[dogsBusdSwapPair] = true;

        liquifyExemptFrom[dogsWbnbSwapPair] = true;
        liquifyExemptTo[dogsWbnbSwapPair] = true;
    }

    /// @notice Creates `_amount` token to `_to`. Must only be called by the owner (MasterChef).
    function mint(address _to, uint256 _amount) external onlyOwner {
        _mint(_to, _amount);
    }

    /// @dev overrides transfer function to meet tokenomics of Dogs Token
    function _transfer(address sender, address recipient, uint256 amount) internal virtual override {

        require(!isBlacklistedFrom(sender), "ERROR: Address Blacklisted!");
        require(!isBlacklistedTo(recipient), "ERROR: Address Blacklisted!");

        bool isExcluded = _isExcludedFromLimiter[sender] || _isExcludedFromLimiter[recipient];

        if (transfersPaused) {
            require(isExcluded, "ERROR: Transfer Paused!");
        }

        if (recipient == address(dogsBusdSwapPair) && !isExcluded) {
            require(sellingEnabled, "ERROR: Selling disabled!");
        }
        if (recipient == address(dogsWbnbSwapPair) && !isExcluded) {
            require(sellingEnabled, "ERROR: Selling disabled!");
        }

        //if any account belongs to _isExcludedFromLimiter account then don't do buy/sell limiting, used for initial liquidty adding
        if (buySellLimiterEnabled && !isExcluded) {
            if (recipient == address(dogsBusdSwapPair) || sender == address(dogsBusdSwapPair)) {
                require(amount <= buySellLimitThreshold, "ERROR: buy / sell exceeded!");
            }
            if (recipient == address(dogsWbnbSwapPair) || sender == address(dogsWbnbSwapPair)) {
                require(amount <= buySellLimitThreshold, "ERROR: buy / sell exceeded!");
            }
        }
        // End of AB measures

        if (swapAndLiquifyEnabled == true && _inSwapAndLiquify == false){
            if (!liquifyExemptFrom[sender] || !liquifyExemptTo[recipient]){
                swapAndLiquefy();
            }
        }

        uint256 taxToApply = TxBaseTax;
        if (customTaxRateFrom[sender] > 0 ){
            taxToApply = customTaxRateFrom[sender];
        }
        if (customTaxRateTo[recipient] > 0 ){
            taxToApply = customTaxRateTo[recipient];
        }

        if (taxToApply == ZERO_TAX_INT || taxToApply == 0) {
            super._transfer(sender, recipient, amount);
        } else {
            uint256 baseTax = amount * taxToApply / 10000;
            uint256 baseBurn = baseTax * TxBurnRate / 10000;
            uint256 vaultReward = baseTax * TxVaultRewardRate / 10000;
            uint256 sendAmount = amount - baseBurn - vaultReward;

            _burnTokens(sender, baseBurn);
            super._transfer(sender, address(FeeManagerDogs), vaultReward);
            super._transfer(sender, recipient, sendAmount);

        }
    }

    function swapAndLiquefy() private lockTheSwap transferTaxFree {
        FeeManagerDogs.liquefyDogs();
    }

    /**
     * @notice Destroys `amount` tokens from the sender, reducing the total supply.
	 */
    function burn(uint256 _amount) external {
        _burnTokens(msg.sender, _amount);
    }

    /**
     * @dev Destroys `amount` tokens from the sender, reducing the total supply.
	 */
    function _burnTokens(address sender, uint256 _amount) private {
        _burn(sender, _amount);
        emit Burn(sender, _amount);
    }

    /**
     * @dev Update the transfer base tax rate.
     * Can only be called by the current operator.
     */
    function updateTransferTaxRate(uint256 _txBaseTax) external onlyTxTaxOperator {
        require(_txBaseTax <= MAXIMUM_TX_BASE_TAX, "invalid tax");
        TxBaseTax = _txBaseTax;
        emit TransferTaxChanged(TxBaseTax);
    }

    function updateCustomTaxRateFrom(address _account, uint256 _taxRate) external onlyTxTaxOperator {
        require(_taxRate <= MAXIMUM_TX_BASE_TAX || _taxRate == ZERO_TAX_INT, "invalid tax");
        customTaxRateFrom[_account] = _taxRate;
        emit UpdateCustomTaxRateFrom(_account, _taxRate);
    }

    function updateCustomTaxRateTo(address _account, uint256 _taxRate) external onlyTxTaxOperator {
        require(_taxRate <= MAXIMUM_TX_BASE_TAX || _taxRate == ZERO_TAX_INT, "invalid tax");
        customTaxRateTo[_account] = _taxRate;
        emit UpdateCustomTaxRateTo(_account, _taxRate);
    }

    /**
     * @dev Update the transfer tax distribution ratio's.
     * Can only be called by the current operator.
     */
    function updateTaxDistribution(uint256 _txBurnRate, uint256 _txVaultRewardRate) external onlyOperator {
        require(_txBurnRate + _txVaultRewardRate <= 10000, "!valid");
        TxBurnRate = _txBurnRate;
        TxVaultRewardRate = _txVaultRewardRate;
        emit TransferTaxDistributionChanged(TxBurnRate, TxVaultRewardRate);
    }

    /**
     * @dev Returns the address of the current operator.
     */
    function operator() external view returns (address) {
        return _operator;
    }

    /**
     * @dev Transfers operator of the contract to a new account (`newOperator`).
     * Can only be called by the current operator.
     */
    function transferOperator(address newOperator) external onlyOperator {
        require(newOperator != address(0), "!!0");
        _operator = newOperator;

        emit SetOperator(_operator);
    }

    /**
     * @dev Update list of Transaction Tax Operators
     * Can only be called by the current operator.
     */
    function updateTxTaxOperator(address _txTaxOperator, bool _isTxTaxOperator) external onlyOperator {
        require(_txTaxOperator != address(0), "!!0");
        txTaxOperators[_txTaxOperator] = _isTxTaxOperator;

        emit SetTxTaxOperator(_txTaxOperator, _isTxTaxOperator);
    }


    /**
     * @dev Update Fee Manager Dogs, sets tax to 0, exclude from triggering liquification
     * Can only be called by the current operator.
     */
    function updateFeeManagerDogs(address _feeManagerDogs) public onlyOperator {
        FeeManagerDogs = IFeeManagerDogs(_feeManagerDogs);
        customTaxRateFrom[_feeManagerDogs] = ZERO_TAX_INT;
        liquifyExemptFrom[_feeManagerDogs] = true;
        emit SetFeeManagerDogs(_feeManagerDogs);
    }

    /**
     * @dev Update the swapAndLiquifyEnabled.
     * Can only be called by the current operator.
     */
    function updateSwapAndLiquifyEnabled(bool _enabled) external onlyOperator {
        swapAndLiquifyEnabled = _enabled;

        emit SetSwapAndLiquifyEnabled(swapAndLiquifyEnabled);
    }


    // AB measures
    function toggleExcludedFromLimiterUser(address account, bool isExcluded) external onlyOperator {
        require(buySellLimiterAllowed, 'feature destroyed');
        _isExcludedFromLimiter[account] = isExcluded;
        emit LimiterUserUpdated(account, isExcluded);
    }

    function toggleBuySellLimiter(bool isEnabled, uint256 amount) external onlyOperator {
        require(buySellLimiterAllowed, 'feature destroyed');
        buySellLimiterEnabled = isEnabled;
        buySellLimitThreshold = amount;
        emit BuySellLimiterUpdate(isEnabled, amount);
    }

    function burnLimiterFeature() external onlyOperator {
        buySellLimiterAllowed = false;
        emit LimiterFeatureBurn();
    }

    function isBlacklistedFrom(address account) public view returns (bool) {
        return blacklistFrom[account];
    }

    function isBlacklistedTo(address account) public view returns (bool) {
        return blacklistTo[account];
    }

    function toggleBlacklistUserFrom(address[] memory accounts, bool blacklisted) external onlyOperator {
        require(blacklistFeatureAllowed, "ERROR: Function burned!");
        for (uint256 i = 0; i < accounts.length; i++) {
            blacklistFrom[accounts[i]] = blacklisted;
            emit BlacklistUpdated(accounts[i], blacklisted);
        }
    }

    function toggleBlacklistUserTo(address[] memory accounts, bool blacklisted) external onlyOperator {
        require(blacklistFeatureAllowed, "ERROR: Function burned!");
        for (uint256 i = 0; i < accounts.length; i++) {
            blacklistTo[accounts[i]] = blacklisted;
            emit BlacklistUpdated(accounts[i], blacklisted);
        }
    }

    function burnBlacklistingFeature() external onlyOperator {
        blacklistFeatureAllowed = false;
        emit BlacklistingFeatureBurn();
    }

    function toggleSellingEnabled(bool enabled) external onlyOperator {
        require(sellingToggleAllowed, 'feature destroyed');
        sellingEnabled = enabled;
        emit SellingEnabledToggle(enabled);
    }

    function burnToggleSellFeature() external onlyOperator {
        sellingToggleAllowed = false;
        emit SellingToggleFeatureBurn();
    }

    function toggleTransfersPaused(bool isPaused) external onlyOperator {
        require(transfersPausedFeatureAllowed, 'feature destroyed');
        transfersPaused = isPaused;
        emit TransferStatusUpdate(isPaused);
    }

    function burnTogglePauseFeature() external onlyOperator {
        transfersPausedFeatureAllowed = false;
        emit TransferPauseFeatureBurn();
    }

}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract DummyToken is ERC20("DummyToken", "DummyToken") {

    constructor() {
        _mint(msg.sender, 1000e18);
    }

}// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract EmptyChef {
    // Maximises yields in pancakeswap
    uint256 public wantLockedTotal = 0;

    // Receives new deposits from user
    function deposit(uint256 _wantAmt) external returns (uint256) {
        return _wantAmt;
    }

    function withdraw(uint256 _wantAmt) external returns (uint256) {
        return _wantAmt;
    }
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/interfaces/IERC20.sol";
import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Factory.sol";
import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";
import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Pair.sol";
import "./interfaces/IToolbox.sol";
import "./interfaces/IDogsExchangeHelper.sol";

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract FeeManager is Ownable {
    using SafeERC20 for IERC20;

    IUniswapV2Factory public constant PancakeFactory = IUniswapV2Factory(0xcA143Ce32Fe78f1f7019d7d551a6402fC5350c73);
    IUniswapV2Router02 public constant PancakeRouter = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
    IToolbox public Toolbox;

    uint256 public busdSwapThreshold = 50 ether;

    address public constant busdCurrencyAddress = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;
    address public constant wbnbCurrencyAddress = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address public pigPenAddress = 0x1f8a98bE5C102D145aC672ded99C5bE0330d7e4F;
    address public vaultAddress = 0x68Bdc7b480d5b4df3bB086Cc3f33b0AEf52F7d55;
    address public dogsLpReceiver = 0x000000000000000000000000000000000000dEaD;
    address public dogsV2Address;
    address public masterchefDogs;
    IDogsExchangeHelper public DogsExchangeHelper;

    uint256 public distributionPigPen = 2300; //23%
    uint256 public distributionVault  = 5000; //50%
    uint256 public distributionDogsLP = 2700; //27%

    address[] pathBusdDogs;

    mapping (address => bool) public viaWBNBTokens;

    constructor(address _dogsV2Token, IToolbox _toolbox, address _masterchefDogs, IDogsExchangeHelper _dogsExchangeHelper){
        dogsV2Address = _dogsV2Token;
        Toolbox = _toolbox;
        masterchefDogs = _masterchefDogs;

        DogsExchangeHelper = _dogsExchangeHelper;

        pathBusdDogs = _createRoute(busdCurrencyAddress, _dogsV2Token);

        _approveTokenIfNeeded(busdCurrencyAddress, address(PancakeRouter));
        _approveTokenIfNeeded(_dogsV2Token, address(PancakeRouter));

        _approveTokenIfNeeded(busdCurrencyAddress, address(_dogsExchangeHelper));
        _approveTokenIfNeeded(_dogsV2Token, address(_dogsExchangeHelper));

        _setRouteViaBNBToken(0xF8A0BF9cF54Bb92F17374d9e9A321E6a111a51bD, true); // LINK
        _setRouteViaBNBToken(0xE0e514c71282b6f4e823703a39374Cf58dc3eA4f, true); // BELT
        _setRouteViaBNBToken(0x2170Ed0880ac9A755fd29B2688956BD959F933F8, true); // ETH
        _setRouteViaBNBToken(0x7083609fCE4d1d8Dc0C979AAb8c869Ea2C873402, true); // DOT

    }

    // MODIFIERS
    modifier onlyMasterchefDogs() {
        require(masterchefDogs == msg.sender, "masterchefDogs only");
        _;
    }

    // Events
    event DepositFeeConvertedToBUSD(address indexed inputToken, uint256 inputAmount, uint256 busdInstant, uint256 busdVault);
    event UpdateVault(address indexed vaultAddress);
    event UpdatePigPen(address indexed pigpenAddress);
    event UpdateLpReceiver(address indexed lpReceiverAddress);
    event UpdateDogsToken(address indexed dogsTokenAddress);
    event UpdateToolbox(address indexed toolBoxAddress);
    event SetRouteTokenViaBNB(address tokenAddress, bool shouldRoute);

    // EXTERNAL FUNCTIONS
    function swapDepositFeeForBUSD(address token, bool isLPToken) external onlyMasterchefDogs {


        uint256 totalTokenBalance = IERC20(token).balanceOf(address(this));

        if (totalTokenBalance == 0 || token == busdCurrencyAddress){
            return;
        }

        uint256 busdValue = Toolbox.getTokenBUSDValue(totalTokenBalance, token, isLPToken);

        // only swap if a certain busd value
        if (busdValue < busdSwapThreshold)
            return;

        swapDepositFeeForTokensInternal(token, isLPToken);

        _distributeDepositFeeBusd();

    }

    /**
     * @dev un-enchant the lp token into its original components.
     */
    function unpairLPToken(address token, uint256 amount) internal returns(address token0, address token1, uint256 amountA, uint256 amountB){
        _approveTokenIfNeeded(token, address(PancakeRouter));

        IUniswapV2Pair lpToken = IUniswapV2Pair(token);
        address token0 = lpToken.token0();
        address token1 = lpToken.token1();

        // make the swap
        (uint256 amount0, uint256 amount1) = PancakeRouter.removeLiquidity(
            address(token0),
            address(token1),
            amount,
            0,
            0,
            address(this),
            block.timestamp
        );

        return (token0, token1, amount0, amount1);

    }

    function swapDepositFeeForTokensInternal(address token, bool isLPToken) internal{

        uint256 totalTokenBalance = IERC20(token).balanceOf(address(this));

        if (isLPToken) {
            address token0;
            address token1;
            uint256 amount0;
            uint256 amount1;

            (token0, token1, amount0, amount1) = unpairLPToken(token, totalTokenBalance);
            // now I have 2 tokens...
            convertTokenToBUSD(token0, amount0);
            convertTokenToBUSD(token1, amount1);
        } else {
            convertTokenToBUSD(token, totalTokenBalance);
        }

    }

    function convertTokenToBUSD(address token, uint256 amount) internal {

        if (token == busdCurrencyAddress){
            return;
        }

        _approveTokenIfNeeded(token, address(PancakeRouter));

        address[] memory path;
        if (shouldRouteViaBNB(token)){
            path = new address[](3);
            path[0] = token;
            path[1] = wbnbCurrencyAddress;
            path[2] = busdCurrencyAddress;
        } else {
            path = new address[](2);
            path[0] = token;
            path[1] = busdCurrencyAddress;
        }

        // make the swap
        PancakeRouter.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            amount,
            0, // accept any amount of tokens
            path,
            address(this),
            block.timestamp
        );

    }

    function _distributeDepositFeeBusd() internal {

        uint256 totalBusdBalance = IERC20(busdCurrencyAddress).balanceOf(address(this));

        uint256 amountPigPen        = totalBusdBalance * distributionPigPen / 10000;
        uint256 amountBusdVault     = totalBusdBalance * distributionVault / 10000;
        uint256 amountDogsLiquidity = totalBusdBalance - amountPigPen - amountBusdVault;

        IERC20(busdCurrencyAddress).transfer(pigPenAddress, amountPigPen);
        IERC20(busdCurrencyAddress).transfer(vaultAddress, amountBusdVault);
        _buybackDogsAddLiquidity(amountDogsLiquidity);
    }

    function _buybackDogsAddLiquidity(uint256 _amountBUSD) internal {
        // approved busd / dogs in constructor

        address[] memory path;
        path = _getBestBUSDDogsSwapPath(_amountBUSD / 2);

        DogsExchangeHelper.buyDogs(_amountBUSD / 2, 0, path);


        // add Dogs/Busd liquidity
        uint256 dogsTokenBalance = IERC20(dogsV2Address).balanceOf(address(this));
        uint256 busdTokenBalance = IERC20(busdCurrencyAddress).balanceOf(address(this));

        IUniswapV2Pair pair = IUniswapV2Pair(PancakeFactory.getPair(dogsV2Address, busdCurrencyAddress));

        DogsExchangeHelper.addDogsLiquidity(busdCurrencyAddress, busdTokenBalance, dogsTokenBalance);
        uint256 dogsBusdLpReceived = IERC20(address(pair)).balanceOf(address(this));
        IERC20(address(pair)).transfer(dogsLpReceiver, dogsBusdLpReceived);

    }

    function _getBestBUSDDogsSwapPath(uint256 _amountBUSD) internal view returns (address[] memory){

        address[] memory pathBUSD_BNB_Dogs = _createRoute3(busdCurrencyAddress, wbnbCurrencyAddress , dogsV2Address);

        uint256[] memory amountOutBUSD = PancakeRouter.getAmountsOut(_amountBUSD, pathBusdDogs);
        uint256[] memory amountOutBUSDviaBNB = PancakeRouter.getAmountsOut(_amountBUSD, pathBUSD_BNB_Dogs);

        if (amountOutBUSD[0] > amountOutBUSDviaBNB[0]){ 
            return pathBusdDogs;
        }
        return pathBUSD_BNB_Dogs;

    }

    function _createRoute(address _from, address _to) internal pure returns(address[] memory){
        address[] memory path = new address[](2);
        path[0] = _from;
        path[1] = _to;
        return path;
    }

    function _createRoute3(address _from, address _mid, address _to) internal pure returns(address[] memory){
        address[] memory path = new address[](3);
        path[0] = _from;
        path[1] = _mid;
        path[2] = _to;
        return path;
    }

    function _approveTokenIfNeeded(address token, address _contract) private {
        if (IERC20(token).allowance(address(this), address(_contract)) == 0) {
            IERC20(token).safeApprove(address(_contract), type(uint256).max);
        }
    }

    function setRouteViaBNBToken(address _token, bool _viaWbnb) external onlyOwner {
        _setRouteViaBNBToken(_token, _viaWbnb);
    }

    function _setRouteViaBNBToken(address _token, bool _viaWbnb) private {
        viaWBNBTokens[_token] = _viaWbnb;
        emit SetRouteTokenViaBNB(_token, _viaWbnb);
    }

    function shouldRouteViaBNB(address _token) public view returns (bool){
        return viaWBNBTokens[_token];
    }

    // ADMIN FUNCTIONS
    function updateVaultAddress(address _vault) external onlyOwner {
        vaultAddress = _vault;
        emit UpdateVault(_vault);
    }

    function updatePigPenAddress(address _pigPen) external onlyOwner {
        pigPenAddress = _pigPen;
        emit UpdatePigPen(_pigPen);
    }

    function updateDogsLpReceiver(address _lpReceiver) external onlyOwner {
        dogsLpReceiver = _lpReceiver;
        emit UpdateLpReceiver(_lpReceiver);
    }

    function updateDogsTokenAddress(address _dogsToken) external onlyOwner {
        dogsV2Address = _dogsToken;
        _approveTokenIfNeeded(_dogsToken, address(PancakeRouter));
        _approveTokenIfNeeded(_dogsToken, address(DogsExchangeHelper));
        pathBusdDogs = _createRoute(busdCurrencyAddress, _dogsToken);
        emit UpdateDogsToken(_dogsToken);
    }

    function updateToolbox(IToolbox _toolbox) external onlyOwner {
        Toolbox = _toolbox;

        emit UpdateToolbox(address(_toolbox));
    }

    function updateDistribution(uint256 _distributionPigPen , uint256 _distributionVault , uint256 _distributionDogsLP) external onlyOwner {
        require(_distributionPigPen <= 10000 && _distributionVault <= 10000 && _distributionDogsLP <= 10000);
        distributionPigPen = _distributionPigPen;
        distributionVault = _distributionVault;
        distributionDogsLP = _distributionDogsLP;
    }

    function updateAddDogsLiquidityHelper(IDogsExchangeHelper _dogsExchangeHelper) external onlyOwner {
        DogsExchangeHelper = _dogsExchangeHelper;
        _approveTokenIfNeeded(dogsV2Address, address(_dogsExchangeHelper));
        _approveTokenIfNeeded(busdCurrencyAddress, address(_dogsExchangeHelper));
    }

    function inCaseTokensGetStuck(address _token, uint256 _amount, address _to) external onlyOwner {
        IERC20(_token).safeTransfer(_to, _amount);
    }
}// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/interfaces/IERC20.sol";
import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Pair.sol";
import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";


interface WethLike {

    function deposit() external payable;

    function withdraw(uint256) external;

}

contract FeeManagerDogs is Ownable {
    using SafeERC20 for IERC20;

    uint256 public dogsSwapThreshold = 50 ether;
    address public constant busdCurrencyAddress = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;
    address public constant bnbCurrencyAddress = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address public dogsV2Address;

    address public vaultBUSDaddress = 0x68Bdc7b480d5b4df3bB086Cc3f33b0AEf52F7d55;
    address public vaultBNBaddress;
    
    uint256 feeDistribution = 33;
    IUniswapV2Router02 public constant PancakeRouter = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);

    address[] pathDogsBusd;
    address[] pathDogsBNB;

    receive() external payable {}

    constructor(address _dogsV2Address, address _vaultBNBaddress){
        dogsV2Address = _dogsV2Address;
        vaultBNBaddress = _vaultBNBaddress;
        _approveTokenIfNeeded(_dogsV2Address);

        pathDogsBusd = _createRoute(dogsV2Address, busdCurrencyAddress);
        pathDogsBNB = _createRoute(dogsV2Address, bnbCurrencyAddress);
    }

    // Modifiers
    modifier onlyDogsToken() {
        require(dogsV2Address == msg.sender, "dogsToken only");
        _;
    }

    // Events
    event DepositFeeConvertedToBUSD(address indexed inputToken, uint256 inputAmount, uint256 busdInstant, uint256 busdVault);
    event UpdateVault(address indexed vaultAddress);
    event UpdatePigPen(address indexed pigpenAddress);
    event UpdateDogsToken(address indexed dogsTokenAddress);
    event UpdateLiquidationThreshold(uint256 indexed threshold);

    // EXTERNAL FUNCTIONS
    function liquefyDogs() external onlyDogsToken {

        uint256 totalTokenBalance = IERC20(dogsV2Address).balanceOf(address(this));

        if (totalTokenBalance < dogsSwapThreshold){
            return;
        }
        
        uint256 busdVaultAllocation = (((totalTokenBalance * 1e4) * feeDistribution)/100) / 1e4; // 33% of dogs go to BUSD Vault
        uint256 bnbVaultAllocation  = totalTokenBalance - busdVaultAllocation; // 67% of dogs go to  BNB Vault

        convertTokenToBUSD(busdVaultAllocation);
        convertTokenToBNB(bnbVaultAllocation);

        _distributeDepositFeeBusd();
        _distributeDepositFeeBNB();

    }

    function _distributeDepositFeeBusd() internal {
        uint256 totalBusdBalance = IERC20(busdCurrencyAddress).balanceOf(address(this));
        IERC20(busdCurrencyAddress).transfer(vaultBUSDaddress, totalBusdBalance);

    }

    function _distributeDepositFeeBNB() internal {
        uint256 totalwBnbBalance = IERC20(bnbCurrencyAddress).balanceOf(address(this));
        WethLike(bnbCurrencyAddress).withdraw(totalwBnbBalance);
        uint256 totalBNBBalance = address(this).balance;
        payable (vaultBNBaddress).transfer(totalBNBBalance);

    }

   
    function _getBestDogsBUSDSwapPath(uint256 _amountDogs) internal returns (address[] memory){

        address[] memory pathDogs_BNB_BUSD = _createRoute3(dogsV2Address, bnbCurrencyAddress, busdCurrencyAddress);

        uint256[] memory amountOutBUSD = PancakeRouter.getAmountsOut(_amountDogs, pathDogsBusd);
        uint256[] memory amountOutBUSDviaBNB = PancakeRouter.getAmountsOut(_amountDogs, pathDogs_BNB_BUSD);

        if (amountOutBUSD[0] > amountOutBUSDviaBNB[0]){ 
            return pathDogsBusd;
        }
        return pathDogs_BNB_BUSD;

    }

    function _getBestDogsBNBSwapPath(uint256 _amountDogs) internal returns (address[] memory){

        address[] memory pathDogs_BUSD_BNB = _createRoute3(dogsV2Address, busdCurrencyAddress, bnbCurrencyAddress);

        uint256[] memory amountOutBNB = PancakeRouter.getAmountsOut(_amountDogs, pathDogsBNB);
        uint256[] memory amountOutBNBviaBUSD = PancakeRouter.getAmountsOut(_amountDogs, pathDogs_BUSD_BNB);

        if (amountOutBNB[0] > amountOutBNBviaBUSD[0]){ 
            return pathDogsBNB;
        }
        return pathDogs_BUSD_BNB;

    }

    function convertTokenToBUSD(uint256 amount) internal {

        address[] memory bestPath = _getBestDogsBUSDSwapPath(amount);

        // make the swap
        PancakeRouter.swapExactTokensForTokens(
            amount,
            0, // accept any amount  of tokens
            bestPath,
            address(this),
            block.timestamp
        );
    }

    function convertTokenToBNB(uint256 amount) internal {

        address[] memory bestPath = _getBestDogsBNBSwapPath(amount);

        // make the swap
        PancakeRouter.swapExactTokensForTokens(
            amount,
            0, // accept any amount of tokens
            bestPath,
            address(this),
            block.timestamp
        );
    }


    function _approveTokenIfNeeded(address token) private {
        if (IERC20(token).allowance(address(this), address(PancakeRouter)) == 0) {
            IERC20(token).safeApprove(address(PancakeRouter), type(uint256).max);
        }
    }

    function _createRoute(address _from, address _to) internal returns(address[] memory){
        address[] memory path = new address[](2);
        path[0] = _from;
        path[1] = _to;
        return path;
    }

    function _createRoute3(address _from, address _mid, address _to) internal returns(address[] memory){
        address[] memory path = new address[](3);
        path[0] = _from;
        path[1] = _mid;
        path[2] = _to;
        return path;
    }

    // ADMIN FUNCTIONS
    function updateVaultAddress(address _vaultBUSDaddress, address _vaultBNBaddress) external onlyOwner {
        vaultBUSDaddress = _vaultBUSDaddress;
        vaultBNBaddress = _vaultBNBaddress;

        //        emit UpdateVault(_newVault);
    }

    function updateDogsTokenAddress(address _dogsToken) external onlyOwner {
        dogsV2Address = _dogsToken;
        _approveTokenIfNeeded(_dogsToken);
        pathDogsBusd = _createRoute(_dogsToken, busdCurrencyAddress);
        pathDogsBNB = _createRoute(_dogsToken, bnbCurrencyAddress);

        emit UpdateDogsToken(_dogsToken);
    }

    function updateFeeDistrib(uint256 distrib) external onlyOwner {
        feeDistribution = distrib;
    }


    function inCaseTokensGetStuck(address _token, uint256 _amount, address _to) external onlyOwner {
        IERC20(_token).safeTransfer(_to, _amount);
    }

    function updateLiquidationThreshold(uint256 _threshold) external onlyOwner {
        dogsSwapThreshold = _threshold;

        emit UpdateLiquidationThreshold(_threshold);
    }


}pragma solidity ^0.8.0;
// SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/interfaces/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import "./interfaces/IPigPen.sol";

contract FounderStakerV2 is Ownable {
    using SafeERC20 for IERC20;

    IERC20  public pigsV2Token = IERC20(0x9a3321E1aCD3B9F6debEE5e042dD2411A1742002);
    IPigPen public PigPen = IPigPen(0x1f8a98bE5C102D145aC672ded99C5bE0330d7e4F);
    bool public shouldAutoCompound = true;
    uint256 public depositThreshold = 1e18;

    event FounderDeposit(address indexed user, uint256 amount);
    event FounderHarvest();
    event FounderWithdraw(address indexed user);
    event FounderEmergencyWithdraw(address indexed user);

    constructor(){
        pigsV2Token.approve(address(PigPen), type(uint256).max);
    }

    function depositFounderPigs() external  {
        uint256 balance = pigsV2Token.balanceOf(address(this));
        if (balance > depositThreshold){
        PigPen.claimRewards(shouldAutoCompound);
        PigPen.deposit(balance);
            emit FounderDeposit(address(this), balance);    
        }
    }

    function claimRewards(bool _shouldCompound) external onlyOwner {
        PigPen.claimRewards(_shouldCompound);
        emit FounderHarvest();
    }

    function withdrawTokens(address _token, uint256 _amount, address _to) external onlyOwner {
        require(_token != address(pigsV2Token), "cant withdraw pigs");
        IERC20(_token).safeTransfer(_to, _amount);
    }

    function burnTokens(uint256 _amount) external onlyOwner {
        IERC20(pigsV2Token).safeTransfer(0x000000000000000000000000000000000000dEaD, _amount);
    }

    // ADMIN FUNCTIONS
    function setPigPenAddress(IPigPen _pigpen) external onlyOwner {
        require(address(_pigpen) != address(0), 'zero address');
        PigPen = _pigpen;
        pigsV2Token.approve(address(_pigpen), type(uint256).max);
    }

    function setPigsToken(IERC20 _pigsToken) external onlyOwner {
        require(address(_pigsToken) != address(0), 'zero address');
        pigsV2Token = _pigsToken;
        pigsV2Token.approve(address(PigPen), type(uint256).max);
    }

    function updateDepositThreshold(uint256 _depositThreshold) external onlyOwner {
        depositThreshold = _depositThreshold;
    }

    function updateShouldCompound(bool _shouldAutoCompound) external onlyOwner {
        shouldAutoCompound = _shouldAutoCompound;
    }

}// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface ICakePool {
    function poolLength() external view returns (uint256);

    function userInfo() external view returns (uint256);

    // Return reward multiplier over the given _from to _to block.
    function getMultiplier(uint256 _from, uint256 _to)
    external
    view
    returns (uint256);

    // View function to see pending CAKEs on frontend.
    function pendingCake(uint256 _pid, address _user)
    external
    view
    returns (uint256);

    // Deposit LP tokens to MasterChef for CAKE allocation.
    function deposit(uint256 _amount, uint256 _lockDuration) external;

    // Withdraw LP tokens from MasterChef.
    function withdrawByAmount(uint256 _amount) external;

    function withdrawAll() external;

}// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IDDSCA {
  enum EmissionRate {SLOW, MEDIUM, FAST, FASTEST}
  function ActiveEmissionIndex (  ) external view returns ( uint8 );
  function bottomPriceInCents (  ) external view returns ( uint256 );
  function checkIfUpdateIsNeeded ( uint256 priceInCents ) external view returns ( bool, EmissionRate );
  function emissionEndBlock (  ) external view returns ( uint256 );
  function emissionStartBlock (  ) external view returns ( uint256 );
  function getEmissionStage ( uint256 currentPriceCents ) external view returns ( uint8 );
  function isInitialized (  ) external view returns ( bool );
  function masterchef (  ) external view returns ( address );
  function maxEmissionRate (  ) external view returns ( uint256 );
  function owner (  ) external view returns ( address );
  function renounceOwnership (  ) external;
  function setFarmEndBlock ( uint256 _newEndBlock ) external;
  function _setFarmStartBlock(uint256 _newStartBlock) external;
  function token (  ) external view returns ( address );
  function tokenPerBlock (  ) external view returns ( uint256 );
  function topPriceInCents (  ) external view returns ( uint256 );
  function transferOwnership ( address newOwner ) external;
  function updateDDSCAMaxEmissionRate ( uint256 _maxEmissionRate ) external;
  function updateDDSCAPriceRange ( uint256 _topPrice, uint256 _bottomPrice ) external;
  function updateEmissions ( EmissionRate _newEmission ) external;
  function updateMcAddress ( address _mcAddress ) external;
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface ILoyalityPool {
    function totalTaxReduction(address _user, uint256 _stakeID) external view returns (uint256);
}// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IDogPoundActions{
    function doSwap(address _from, uint256 _amount, uint256 _taxReduction, address[] memory path) external;
    function doTransfer(address _from, address _to, uint256 _amount, uint256 _taxReduction) external;
}// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IDogPoundManager{
    function getAutoPoolSize() external view returns (uint256);
   
}// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IDogsExchangeHelper {
    function addDogsBNBLiquidity(uint256 nativeAmount) external payable returns (uint256 lpAmount, uint256 unusedEth, uint256 unusedToken);
    function addDogsLiquidity(address baseTokenAddress, uint256 baseAmount, uint256 dogsAmount) external returns (uint256 lpAmount, uint256 unusedEth, uint256 unusedToken);
    function buyDogsBNB(uint256 _minAmountOut, address[] memory _path) external payable returns(uint256 amountDogsBought);
    function buyDogs(uint256 _tokenAmount, uint256 _minAmountOut, address[] memory _path) external returns(uint256 amountDogsBought);
}// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/interfaces/IERC20.sol";

interface IDogsToken is IERC20{
    function updateTransferTaxRate(uint256 _txBaseTax) external;
    function updateTransferTaxRateToDefault() external;
    function burn(uint256 _amount) external;
}// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IDogsTokenV2 {

    function mint(address _to, uint256 _amount) external;

}// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IFeeManager {

    function swapDepositFeeForBUSD(address token, bool isLPToken) external;
    function convertDepositFeesToBUSD(address token, bool isLPToken, bool isLiquidation) external;
}// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IFeeManagerDogs {

    function liquefyDogs() external;
}// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IFounderStakerV2{
    function depositFounderPigs() external;
}// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IMasterchefDogs {

    function depositMigrator(address _userAddress, uint256 _pid, uint256 _amount, address _referrer) external;
}// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IMasterchefPigs {
    function deposit(uint256 _pid, uint256 _amount) external;
    function pendingPigs(uint256 _pid, address _user) external view returns (uint256);
    function depositMigrator(address _userAddress, uint256 _pid, uint256 _amount) external;
    function withdraw(uint256 _pid, uint256 _amount) external;
}// !! THIS FILE WAS AUTOGENERATED BY abi-to-sol v0.8.0. SEE SOURCE BELOW. !!
pragma abicoder v2;

interface IMasterChefV3 {
    event AddPool(
        uint256 indexed pid,
        uint256 allocPoint,
        address indexed v3Pool,
        address indexed lmPool
    );
    event Deposit(
        address indexed from,
        uint256 indexed pid,
        uint256 indexed tokenId,
        uint256 liquidity,
        int24 tickLower,
        int24 tickUpper
    );
    event Harvest(
        address indexed sender,
        address to,
        uint256 indexed pid,
        uint256 indexed tokenId,
        uint256 reward
    );
    event NewLMPoolDeployerAddress(address deployer);
    event NewOperatorAddress(address operator);
    event NewPeriodDuration(uint256 periodDuration);
    event NewReceiver(address receiver);
    event NewUpkeepPeriod(
        uint256 indexed periodNumber,
        uint256 startTime,
        uint256 endTime,
        uint256 cakePerSecond,
        uint256 cakeAmount
    );
    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );
    event SetEmergency(bool emergency);
    event SetPool(uint256 indexed pid, uint256 allocPoint);
    event UpdateFarmBoostContract(address indexed farmBoostContract);
    event UpdateLiquidity(
        address indexed from,
        uint256 indexed pid,
        uint256 indexed tokenId,
        int128 liquidity,
        int24 tickLower,
        int24 tickUpper
    );
    event UpdateUpkeepPeriod(
        uint256 indexed periodNumber,
        uint256 oldEndTime,
        uint256 newEndTime,
        uint256 remainingCake
    );
    event Withdraw(
        address indexed from,
        address to,
        uint256 indexed pid,
        uint256 indexed tokenId
    );

    function BOOST_PRECISION() external view returns (uint256);

    function CAKE() external view returns (address);

    function FARM_BOOSTER() external view returns (address);

    function LMPoolDeployer() external view returns (address);

    function MAX_BOOST_PRECISION() external view returns (uint256);

    function MAX_DURATION() external view returns (uint256);

    function MIN_DURATION() external view returns (uint256);

    function PERIOD_DURATION() external view returns (uint256);

    function PRECISION() external view returns (uint256);

    function WETH() external view returns (address);

    function add(
        uint256 _allocPoint,
        address _v3Pool,
        bool _withUpdate
    ) external;

    function balanceOf(address owner) external view returns (uint256);

    function burn(uint256 _tokenId) external;

    function cakeAmountBelongToMC() external view returns (uint256);

    function collect(
        INonfungiblePositionManagerStruct.CollectParams memory params
    ) external returns (uint256 amount0, uint256 amount1);

    function collectTo(
        INonfungiblePositionManagerStruct.CollectParams memory params,
        address to
    ) external returns (uint256 amount0, uint256 amount1);

    function decreaseLiquidity(
        INonfungiblePositionManagerStruct.DecreaseLiquidityParams memory params
    ) external returns (uint256 amount0, uint256 amount1);

    function emergency() external view returns (bool);

    function getLatestPeriodInfo(
        address _v3Pool
    ) external view returns (uint256 cakePerSecond, uint256 endTime);

    function getLatestPeriodInfoByPid(
        uint256 _pid
    ) external view returns (uint256 cakePerSecond, uint256 endTime);

    function harvest(
        uint256 _tokenId,
        address _to
    ) external returns (uint256 reward);

    function increaseLiquidity(
        INonfungiblePositionManagerStruct.IncreaseLiquidityParams memory params
    )
        external
        payable
        returns (uint128 liquidity, uint256 amount0, uint256 amount1);

    function latestPeriodCakePerSecond() external view returns (uint256);

    function latestPeriodEndTime() external view returns (uint256);

    function latestPeriodNumber() external view returns (uint256);

    function latestPeriodStartTime() external view returns (uint256);

    function multicall(
        bytes[] memory data
    ) external payable returns (bytes[] memory results);

    function nonfungiblePositionManager() external view returns (address);

    function onERC721Received(
        address,
        address _from,
        uint256 _tokenId,
        bytes memory
    ) external returns (bytes4);

    function operatorAddress() external view returns (address);

    function owner() external view returns (address);

    function pendingCake(
        uint256 _tokenId
    ) external view returns (uint256 reward);

    function poolInfo(
        uint256
    )
        external
        view
        returns (
            uint256 allocPoint,
            address v3Pool,
            address token0,
            address token1,
            uint24 fee,
            uint256 totalLiquidity,
            uint256 totalBoostLiquidity
        );

    function poolLength() external view returns (uint256);

    function receiver() external view returns (address);

    function renounceOwnership() external;

    function set(uint256 _pid, uint256 _allocPoint, bool _withUpdate) external;

    function setEmergency(bool _emergency) external;

    function setLMPoolDeployer(address _LMPoolDeployer) external;

    function setOperator(address _operatorAddress) external;

    function setPeriodDuration(uint256 _periodDuration) external;

    function setReceiver(address _receiver) external;

    function sweepToken(
        address token,
        uint256 amountMinimum,
        address recipient
    ) external;

    function tokenOfOwnerByIndex(
        address owner,
        uint256 index
    ) external view returns (uint256);

    function totalAllocPoint() external view returns (uint256);

    function transferOwnership(address newOwner) external;

    function unwrapWETH9(uint256 amountMinimum, address recipient) external;

    function updateBoostMultiplier(
        uint256 _tokenId,
        uint256 _newMultiplier
    ) external;

    function updateFarmBoostContract(address _newFarmBoostContract) external;

    function updateLiquidity(uint256 _tokenId) external;

    function updatePools(uint256[] memory pids) external;

    function upkeep(
        uint256 _amount,
        uint256 _duration,
        bool _withUpdate
    ) external;

    function userPositionInfos(
        uint256
    )
        external
        view
        returns (
            uint128 liquidity,
            uint128 boostLiquidity,
            int24 tickLower,
            int24 tickUpper,
            uint256 rewardGrowthInside,
            uint256 reward,
            address user,
            uint256 pid,
            uint256 boostMultiplier
        );

    function v3PoolAddressPid(address) external view returns (uint256);

    function withdraw(
        uint256 _tokenId,
        address _to
    ) external returns (uint256 reward);

    receive() external payable;
}

interface INonfungiblePositionManagerStruct {
    struct CollectParams {
        uint256 tokenId;
        address recipient;
        uint128 amount0Max;
        uint128 amount1Max;
    }

    struct DecreaseLiquidityParams {
        uint256 tokenId;
        uint128 liquidity;
        uint256 amount0Min;
        uint256 amount1Min;
        uint256 deadline;
    }

    struct IncreaseLiquidityParams {
        uint256 tokenId;
        uint256 amount0Desired;
        uint256 amount1Desired;
        uint256 amount0Min;
        uint256 amount1Min;
        uint256 deadline;
    }
}

// THIS FILE WAS AUTOGENERATED FROM THE FOLLOWING ABI JSON:
/*
[{"inputs":[{"internalType":"contract IERC20","name":"_CAKE","type":"address"},{"internalType":"contract INonfungiblePositionManager","name":"_nonfungiblePositionManager","type":"address"},{"internalType":"address","name":"_WETH","type":"address"}],"stateMutability":"nonpayable","type":"constructor"},{"inputs":[{"internalType":"uint256","name":"pid","type":"uint256"}],"name":"DuplicatedPool","type":"error"},{"inputs":[],"name":"InconsistentAmount","type":"error"},{"inputs":[],"name":"InsufficientAmount","type":"error"},{"inputs":[],"name":"InvalidNFT","type":"error"},{"inputs":[],"name":"InvalidPeriodDuration","type":"error"},{"inputs":[],"name":"InvalidPid","type":"error"},{"inputs":[],"name":"NoBalance","type":"error"},{"inputs":[],"name":"NoLMPool","type":"error"},{"inputs":[],"name":"NoLiquidity","type":"error"},{"inputs":[],"name":"NotEmpty","type":"error"},{"inputs":[],"name":"NotOwner","type":"error"},{"inputs":[],"name":"NotOwnerOrOperator","type":"error"},{"inputs":[],"name":"NotPancakeNFT","type":"error"},{"inputs":[],"name":"WrongReceiver","type":"error"},{"inputs":[],"name":"ZeroAddress","type":"error"},{"anonymous":false,"inputs":[{"indexed":true,"internalType":"uint256","name":"pid","type":"uint256"},{"indexed":false,"internalType":"uint256","name":"allocPoint","type":"uint256"},{"indexed":true,"internalType":"contract IPancakeV3Pool","name":"v3Pool","type":"address"},{"indexed":true,"internalType":"contract ILMPool","name":"lmPool","type":"address"}],"name":"AddPool","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"internalType":"address","name":"from","type":"address"},{"indexed":true,"internalType":"uint256","name":"pid","type":"uint256"},{"indexed":true,"internalType":"uint256","name":"tokenId","type":"uint256"},{"indexed":false,"internalType":"uint256","name":"liquidity","type":"uint256"},{"indexed":false,"internalType":"int24","name":"tickLower","type":"int24"},{"indexed":false,"internalType":"int24","name":"tickUpper","type":"int24"}],"name":"Deposit","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"internalType":"address","name":"sender","type":"address"},{"indexed":false,"internalType":"address","name":"to","type":"address"},{"indexed":true,"internalType":"uint256","name":"pid","type":"uint256"},{"indexed":true,"internalType":"uint256","name":"tokenId","type":"uint256"},{"indexed":false,"internalType":"uint256","name":"reward","type":"uint256"}],"name":"Harvest","type":"event"},{"anonymous":false,"inputs":[{"indexed":false,"internalType":"address","name":"deployer","type":"address"}],"name":"NewLMPoolDeployerAddress","type":"event"},{"anonymous":false,"inputs":[{"indexed":false,"internalType":"address","name":"operator","type":"address"}],"name":"NewOperatorAddress","type":"event"},{"anonymous":false,"inputs":[{"indexed":false,"internalType":"uint256","name":"periodDuration","type":"uint256"}],"name":"NewPeriodDuration","type":"event"},{"anonymous":false,"inputs":[{"indexed":false,"internalType":"address","name":"receiver","type":"address"}],"name":"NewReceiver","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"internalType":"uint256","name":"periodNumber","type":"uint256"},{"indexed":false,"internalType":"uint256","name":"startTime","type":"uint256"},{"indexed":false,"internalType":"uint256","name":"endTime","type":"uint256"},{"indexed":false,"internalType":"uint256","name":"cakePerSecond","type":"uint256"},{"indexed":false,"internalType":"uint256","name":"cakeAmount","type":"uint256"}],"name":"NewUpkeepPeriod","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"internalType":"address","name":"previousOwner","type":"address"},{"indexed":true,"internalType":"address","name":"newOwner","type":"address"}],"name":"OwnershipTransferred","type":"event"},{"anonymous":false,"inputs":[{"indexed":false,"internalType":"bool","name":"emergency","type":"bool"}],"name":"SetEmergency","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"internalType":"uint256","name":"pid","type":"uint256"},{"indexed":false,"internalType":"uint256","name":"allocPoint","type":"uint256"}],"name":"SetPool","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"internalType":"address","name":"farmBoostContract","type":"address"}],"name":"UpdateFarmBoostContract","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"internalType":"address","name":"from","type":"address"},{"indexed":true,"internalType":"uint256","name":"pid","type":"uint256"},{"indexed":true,"internalType":"uint256","name":"tokenId","type":"uint256"},{"indexed":false,"internalType":"int128","name":"liquidity","type":"int128"},{"indexed":false,"internalType":"int24","name":"tickLower","type":"int24"},{"indexed":false,"internalType":"int24","name":"tickUpper","type":"int24"}],"name":"UpdateLiquidity","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"internalType":"uint256","name":"periodNumber","type":"uint256"},{"indexed":false,"internalType":"uint256","name":"oldEndTime","type":"uint256"},{"indexed":false,"internalType":"uint256","name":"newEndTime","type":"uint256"},{"indexed":false,"internalType":"uint256","name":"remainingCake","type":"uint256"}],"name":"UpdateUpkeepPeriod","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"internalType":"address","name":"from","type":"address"},{"indexed":false,"internalType":"address","name":"to","type":"address"},{"indexed":true,"internalType":"uint256","name":"pid","type":"uint256"},{"indexed":true,"internalType":"uint256","name":"tokenId","type":"uint256"}],"name":"Withdraw","type":"event"},{"inputs":[],"name":"BOOST_PRECISION","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"CAKE","outputs":[{"internalType":"contract IERC20","name":"","type":"address"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"FARM_BOOSTER","outputs":[{"internalType":"contract IFarmBooster","name":"","type":"address"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"LMPoolDeployer","outputs":[{"internalType":"contract ILMPoolDeployer","name":"","type":"address"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"MAX_BOOST_PRECISION","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"MAX_DURATION","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"MIN_DURATION","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"PERIOD_DURATION","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"PRECISION","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"WETH","outputs":[{"internalType":"address","name":"","type":"address"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"uint256","name":"_allocPoint","type":"uint256"},{"internalType":"contract IPancakeV3Pool","name":"_v3Pool","type":"address"},{"internalType":"bool","name":"_withUpdate","type":"bool"}],"name":"add","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"address","name":"owner","type":"address"}],"name":"balanceOf","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"uint256","name":"_tokenId","type":"uint256"}],"name":"burn","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[],"name":"cakeAmountBelongToMC","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"},{"inputs":[{"components":[{"internalType":"uint256","name":"tokenId","type":"uint256"},{"internalType":"address","name":"recipient","type":"address"},{"internalType":"uint128","name":"amount0Max","type":"uint128"},{"internalType":"uint128","name":"amount1Max","type":"uint128"}],"internalType":"struct INonfungiblePositionManagerStruct.CollectParams","name":"params","type":"tuple"}],"name":"collect","outputs":[{"internalType":"uint256","name":"amount0","type":"uint256"},{"internalType":"uint256","name":"amount1","type":"uint256"}],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"components":[{"internalType":"uint256","name":"tokenId","type":"uint256"},{"internalType":"address","name":"recipient","type":"address"},{"internalType":"uint128","name":"amount0Max","type":"uint128"},{"internalType":"uint128","name":"amount1Max","type":"uint128"}],"internalType":"struct INonfungiblePositionManagerStruct.CollectParams","name":"params","type":"tuple"},{"internalType":"address","name":"to","type":"address"}],"name":"collectTo","outputs":[{"internalType":"uint256","name":"amount0","type":"uint256"},{"internalType":"uint256","name":"amount1","type":"uint256"}],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"components":[{"internalType":"uint256","name":"tokenId","type":"uint256"},{"internalType":"uint128","name":"liquidity","type":"uint128"},{"internalType":"uint256","name":"amount0Min","type":"uint256"},{"internalType":"uint256","name":"amount1Min","type":"uint256"},{"internalType":"uint256","name":"deadline","type":"uint256"}],"internalType":"struct INonfungiblePositionManagerStruct.DecreaseLiquidityParams","name":"params","type":"tuple"}],"name":"decreaseLiquidity","outputs":[{"internalType":"uint256","name":"amount0","type":"uint256"},{"internalType":"uint256","name":"amount1","type":"uint256"}],"stateMutability":"nonpayable","type":"function"},{"inputs":[],"name":"emergency","outputs":[{"internalType":"bool","name":"","type":"bool"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"address","name":"_v3Pool","type":"address"}],"name":"getLatestPeriodInfo","outputs":[{"internalType":"uint256","name":"cakePerSecond","type":"uint256"},{"internalType":"uint256","name":"endTime","type":"uint256"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"uint256","name":"_pid","type":"uint256"}],"name":"getLatestPeriodInfoByPid","outputs":[{"internalType":"uint256","name":"cakePerSecond","type":"uint256"},{"internalType":"uint256","name":"endTime","type":"uint256"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"uint256","name":"_tokenId","type":"uint256"},{"internalType":"address","name":"_to","type":"address"}],"name":"harvest","outputs":[{"internalType":"uint256","name":"reward","type":"uint256"}],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"components":[{"internalType":"uint256","name":"tokenId","type":"uint256"},{"internalType":"uint256","name":"amount0Desired","type":"uint256"},{"internalType":"uint256","name":"amount1Desired","type":"uint256"},{"internalType":"uint256","name":"amount0Min","type":"uint256"},{"internalType":"uint256","name":"amount1Min","type":"uint256"},{"internalType":"uint256","name":"deadline","type":"uint256"}],"internalType":"struct INonfungiblePositionManagerStruct.IncreaseLiquidityParams","name":"params","type":"tuple"}],"name":"increaseLiquidity","outputs":[{"internalType":"uint128","name":"liquidity","type":"uint128"},{"internalType":"uint256","name":"amount0","type":"uint256"},{"internalType":"uint256","name":"amount1","type":"uint256"}],"stateMutability":"payable","type":"function"},{"inputs":[],"name":"latestPeriodCakePerSecond","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"latestPeriodEndTime","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"latestPeriodNumber","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"latestPeriodStartTime","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"bytes[]","name":"data","type":"bytes[]"}],"name":"multicall","outputs":[{"internalType":"bytes[]","name":"results","type":"bytes[]"}],"stateMutability":"payable","type":"function"},{"inputs":[],"name":"nonfungiblePositionManager","outputs":[{"internalType":"contract INonfungiblePositionManager","name":"","type":"address"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"address","name":"","type":"address"},{"internalType":"address","name":"_from","type":"address"},{"internalType":"uint256","name":"_tokenId","type":"uint256"},{"internalType":"bytes","name":"","type":"bytes"}],"name":"onERC721Received","outputs":[{"internalType":"bytes4","name":"","type":"bytes4"}],"stateMutability":"nonpayable","type":"function"},{"inputs":[],"name":"operatorAddress","outputs":[{"internalType":"address","name":"","type":"address"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"owner","outputs":[{"internalType":"address","name":"","type":"address"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"uint256","name":"_tokenId","type":"uint256"}],"name":"pendingCake","outputs":[{"internalType":"uint256","name":"reward","type":"uint256"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"uint256","name":"","type":"uint256"}],"name":"poolInfo","outputs":[{"internalType":"uint256","name":"allocPoint","type":"uint256"},{"internalType":"contract IPancakeV3Pool","name":"v3Pool","type":"address"},{"internalType":"address","name":"token0","type":"address"},{"internalType":"address","name":"token1","type":"address"},{"internalType":"uint24","name":"fee","type":"uint24"},{"internalType":"uint256","name":"totalLiquidity","type":"uint256"},{"internalType":"uint256","name":"totalBoostLiquidity","type":"uint256"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"poolLength","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"receiver","outputs":[{"internalType":"address","name":"","type":"address"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"renounceOwnership","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"uint256","name":"_pid","type":"uint256"},{"internalType":"uint256","name":"_allocPoint","type":"uint256"},{"internalType":"bool","name":"_withUpdate","type":"bool"}],"name":"set","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"bool","name":"_emergency","type":"bool"}],"name":"setEmergency","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"contract ILMPoolDeployer","name":"_LMPoolDeployer","type":"address"}],"name":"setLMPoolDeployer","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"address","name":"_operatorAddress","type":"address"}],"name":"setOperator","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"uint256","name":"_periodDuration","type":"uint256"}],"name":"setPeriodDuration","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"address","name":"_receiver","type":"address"}],"name":"setReceiver","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"address","name":"token","type":"address"},{"internalType":"uint256","name":"amountMinimum","type":"uint256"},{"internalType":"address","name":"recipient","type":"address"}],"name":"sweepToken","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"address","name":"owner","type":"address"},{"internalType":"uint256","name":"index","type":"uint256"}],"name":"tokenOfOwnerByIndex","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"totalAllocPoint","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"address","name":"newOwner","type":"address"}],"name":"transferOwnership","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"uint256","name":"amountMinimum","type":"uint256"},{"internalType":"address","name":"recipient","type":"address"}],"name":"unwrapWETH9","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"uint256","name":"_tokenId","type":"uint256"},{"internalType":"uint256","name":"_newMultiplier","type":"uint256"}],"name":"updateBoostMultiplier","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"address","name":"_newFarmBoostContract","type":"address"}],"name":"updateFarmBoostContract","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"uint256","name":"_tokenId","type":"uint256"}],"name":"updateLiquidity","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"uint256[]","name":"pids","type":"uint256[]"}],"name":"updatePools","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"uint256","name":"_amount","type":"uint256"},{"internalType":"uint256","name":"_duration","type":"uint256"},{"internalType":"bool","name":"_withUpdate","type":"bool"}],"name":"upkeep","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"uint256","name":"","type":"uint256"}],"name":"userPositionInfos","outputs":[{"internalType":"uint128","name":"liquidity","type":"uint128"},{"internalType":"uint128","name":"boostLiquidity","type":"uint128"},{"internalType":"int24","name":"tickLower","type":"int24"},{"internalType":"int24","name":"tickUpper","type":"int24"},{"internalType":"uint256","name":"rewardGrowthInside","type":"uint256"},{"internalType":"uint256","name":"reward","type":"uint256"},{"internalType":"address","name":"user","type":"address"},{"internalType":"uint256","name":"pid","type":"uint256"},{"internalType":"uint256","name":"boostMultiplier","type":"uint256"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"address","name":"","type":"address"}],"name":"v3PoolAddressPid","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"uint256","name":"_tokenId","type":"uint256"},{"internalType":"address","name":"_to","type":"address"}],"name":"withdraw","outputs":[{"internalType":"uint256","name":"reward","type":"uint256"}],"stateMutability":"nonpayable","type":"function"},{"stateMutability":"payable","type":"receive"}]
*/
// !! THIS FILE WAS AUTOGENERATED BY abi-to-sol v0.8.0. SEE SOURCE BELOW. !!
pragma solidity >=0.7.0 <0.9.0;
pragma experimental ABIEncoderV2;

interface INonfungiblePositionManager {
    struct CollectParams {
        uint256 tokenId;
        address recipient;
        uint128 amount0Max;
        uint128 amount1Max;
    }

    struct DecreaseLiquidityParams {
        uint256 tokenId;
        uint128 liquidity;
        uint256 amount0Min;
        uint256 amount1Min;
        uint256 deadline;
    }

    struct IncreaseLiquidityParams {
        uint256 tokenId;
        uint256 amount0Desired;
        uint256 amount1Desired;
        uint256 amount0Min;
        uint256 amount1Min;
        uint256 deadline;
    }

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

    event Approval(
        address indexed owner,
        address indexed approved,
        uint256 indexed tokenId
    );
    event ApprovalForAll(
        address indexed owner,
        address indexed operator,
        bool approved
    );
    event Collect(
        uint256 indexed tokenId,
        address recipient,
        uint256 amount0,
        uint256 amount1
    );
    event DecreaseLiquidity(
        uint256 indexed tokenId,
        uint128 liquidity,
        uint256 amount0,
        uint256 amount1
    );
    event IncreaseLiquidity(
        uint256 indexed tokenId,
        uint128 liquidity,
        uint256 amount0,
        uint256 amount1
    );
    event Transfer(
        address indexed from,
        address indexed to,
        uint256 indexed tokenId
    );

    function DOMAIN_SEPARATOR() external view returns (bytes32);

    function PERMIT_TYPEHASH() external view returns (bytes32);

    function WETH9() external view returns (address);

    function approve(address to, uint256 tokenId) external;

    function balanceOf(address owner) external view returns (uint256);

    function baseURI() external pure returns (string memory);

    function burn(uint256 tokenId) external payable;

    function collect(CollectParams memory params)
        external
        payable
        returns (uint256 amount0, uint256 amount1);

    function createAndInitializePoolIfNecessary(
        address token0,
        address token1,
        uint24 fee,
        uint160 sqrtPriceX96
    ) external payable returns (address pool);

    function decreaseLiquidity(DecreaseLiquidityParams memory params)
        external
        payable
        returns (uint256 amount0, uint256 amount1);

    function deployer() external view returns (address);

    function factory() external view returns (address);

    function getApproved(uint256 tokenId) external view returns (address);

    function increaseLiquidity(IncreaseLiquidityParams memory params)
        external
        payable
        returns (
            uint128 liquidity,
            uint256 amount0,
            uint256 amount1
        );

    function isApprovedForAll(address owner, address operator)
        external
        view
        returns (bool);

    function mint(MintParams memory params)
        external
        payable
        returns (
            uint256 tokenId,
            uint128 liquidity,
            uint256 amount0,
            uint256 amount1
        );

    function multicall(bytes[] memory data)
        external
        payable
        returns (bytes[] memory results);

    function name() external view returns (string memory);

    function ownerOf(uint256 tokenId) external view returns (address);

    function pancakeV3MintCallback(
        uint256 amount0Owed,
        uint256 amount1Owed,
        bytes memory data
    ) external;

    function permit(
        address spender,
        uint256 tokenId,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external payable;

    function positions(uint256 tokenId)
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

    function refundETH() external payable;

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) external;

    function selfPermit(
        address token,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external payable;

    function selfPermitAllowed(
        address token,
        uint256 nonce,
        uint256 expiry,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external payable;

    function selfPermitAllowedIfNecessary(
        address token,
        uint256 nonce,
        uint256 expiry,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external payable;

    function selfPermitIfNecessary(
        address token,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external payable;

    function setApprovalForAll(address operator, bool approved) external;

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

    function sweepToken(
        address token,
        uint256 amountMinimum,
        address recipient
    ) external payable;

    function symbol() external view returns (string memory);

    function tokenByIndex(uint256 index) external view returns (uint256);

    function tokenOfOwnerByIndex(address owner, uint256 index)
        external
        view
        returns (uint256);

    function tokenURI(uint256 tokenId) external view returns (string memory);

    function totalSupply() external view returns (uint256);

    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    function unwrapWETH9(uint256 amountMinimum, address recipient)
        external
        payable;

    receive() external payable;
}

// THIS FILE WAS AUTOGENERATED FROM THE FOLLOWING ABI JSON:
/*
[{"inputs":[{"internalType":"address","name":"_deployer","type":"address"},{"internalType":"address","name":"_factory","type":"address"},{"internalType":"address","name":"_WETH9","type":"address"},{"internalType":"address","name":"_tokenDescriptor_","type":"address"}],"stateMutability":"nonpayable","type":"constructor"},{"anonymous":false,"inputs":[{"indexed":true,"internalType":"address","name":"owner","type":"address"},{"indexed":true,"internalType":"address","name":"approved","type":"address"},{"indexed":true,"internalType":"uint256","name":"tokenId","type":"uint256"}],"name":"Approval","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"internalType":"address","name":"owner","type":"address"},{"indexed":true,"internalType":"address","name":"operator","type":"address"},{"indexed":false,"internalType":"bool","name":"approved","type":"bool"}],"name":"ApprovalForAll","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"internalType":"uint256","name":"tokenId","type":"uint256"},{"indexed":false,"internalType":"address","name":"recipient","type":"address"},{"indexed":false,"internalType":"uint256","name":"amount0","type":"uint256"},{"indexed":false,"internalType":"uint256","name":"amount1","type":"uint256"}],"name":"Collect","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"internalType":"uint256","name":"tokenId","type":"uint256"},{"indexed":false,"internalType":"uint128","name":"liquidity","type":"uint128"},{"indexed":false,"internalType":"uint256","name":"amount0","type":"uint256"},{"indexed":false,"internalType":"uint256","name":"amount1","type":"uint256"}],"name":"DecreaseLiquidity","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"internalType":"uint256","name":"tokenId","type":"uint256"},{"indexed":false,"internalType":"uint128","name":"liquidity","type":"uint128"},{"indexed":false,"internalType":"uint256","name":"amount0","type":"uint256"},{"indexed":false,"internalType":"uint256","name":"amount1","type":"uint256"}],"name":"IncreaseLiquidity","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"internalType":"address","name":"from","type":"address"},{"indexed":true,"internalType":"address","name":"to","type":"address"},{"indexed":true,"internalType":"uint256","name":"tokenId","type":"uint256"}],"name":"Transfer","type":"event"},{"inputs":[],"name":"DOMAIN_SEPARATOR","outputs":[{"internalType":"bytes32","name":"","type":"bytes32"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"PERMIT_TYPEHASH","outputs":[{"internalType":"bytes32","name":"","type":"bytes32"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"WETH9","outputs":[{"internalType":"address","name":"","type":"address"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"address","name":"to","type":"address"},{"internalType":"uint256","name":"tokenId","type":"uint256"}],"name":"approve","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"address","name":"owner","type":"address"}],"name":"balanceOf","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"baseURI","outputs":[{"internalType":"string","name":"","type":"string"}],"stateMutability":"pure","type":"function"},{"inputs":[{"internalType":"uint256","name":"tokenId","type":"uint256"}],"name":"burn","outputs":[],"stateMutability":"payable","type":"function"},{"inputs":[{"components":[{"internalType":"uint256","name":"tokenId","type":"uint256"},{"internalType":"address","name":"recipient","type":"address"},{"internalType":"uint128","name":"amount0Max","type":"uint128"},{"internalType":"uint128","name":"amount1Max","type":"uint128"}],"internalType":"struct INonfungiblePositionManager.CollectParams","name":"params","type":"tuple"}],"name":"collect","outputs":[{"internalType":"uint256","name":"amount0","type":"uint256"},{"internalType":"uint256","name":"amount1","type":"uint256"}],"stateMutability":"payable","type":"function"},{"inputs":[{"internalType":"address","name":"token0","type":"address"},{"internalType":"address","name":"token1","type":"address"},{"internalType":"uint24","name":"fee","type":"uint24"},{"internalType":"uint160","name":"sqrtPriceX96","type":"uint160"}],"name":"createAndInitializePoolIfNecessary","outputs":[{"internalType":"address","name":"pool","type":"address"}],"stateMutability":"payable","type":"function"},{"inputs":[{"components":[{"internalType":"uint256","name":"tokenId","type":"uint256"},{"internalType":"uint128","name":"liquidity","type":"uint128"},{"internalType":"uint256","name":"amount0Min","type":"uint256"},{"internalType":"uint256","name":"amount1Min","type":"uint256"},{"internalType":"uint256","name":"deadline","type":"uint256"}],"internalType":"struct INonfungiblePositionManager.DecreaseLiquidityParams","name":"params","type":"tuple"}],"name":"decreaseLiquidity","outputs":[{"internalType":"uint256","name":"amount0","type":"uint256"},{"internalType":"uint256","name":"amount1","type":"uint256"}],"stateMutability":"payable","type":"function"},{"inputs":[],"name":"deployer","outputs":[{"internalType":"address","name":"","type":"address"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"factory","outputs":[{"internalType":"address","name":"","type":"address"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"uint256","name":"tokenId","type":"uint256"}],"name":"getApproved","outputs":[{"internalType":"address","name":"","type":"address"}],"stateMutability":"view","type":"function"},{"inputs":[{"components":[{"internalType":"uint256","name":"tokenId","type":"uint256"},{"internalType":"uint256","name":"amount0Desired","type":"uint256"},{"internalType":"uint256","name":"amount1Desired","type":"uint256"},{"internalType":"uint256","name":"amount0Min","type":"uint256"},{"internalType":"uint256","name":"amount1Min","type":"uint256"},{"internalType":"uint256","name":"deadline","type":"uint256"}],"internalType":"struct INonfungiblePositionManager.IncreaseLiquidityParams","name":"params","type":"tuple"}],"name":"increaseLiquidity","outputs":[{"internalType":"uint128","name":"liquidity","type":"uint128"},{"internalType":"uint256","name":"amount0","type":"uint256"},{"internalType":"uint256","name":"amount1","type":"uint256"}],"stateMutability":"payable","type":"function"},{"inputs":[{"internalType":"address","name":"owner","type":"address"},{"internalType":"address","name":"operator","type":"address"}],"name":"isApprovedForAll","outputs":[{"internalType":"bool","name":"","type":"bool"}],"stateMutability":"view","type":"function"},{"inputs":[{"components":[{"internalType":"address","name":"token0","type":"address"},{"internalType":"address","name":"token1","type":"address"},{"internalType":"uint24","name":"fee","type":"uint24"},{"internalType":"int24","name":"tickLower","type":"int24"},{"internalType":"int24","name":"tickUpper","type":"int24"},{"internalType":"uint256","name":"amount0Desired","type":"uint256"},{"internalType":"uint256","name":"amount1Desired","type":"uint256"},{"internalType":"uint256","name":"amount0Min","type":"uint256"},{"internalType":"uint256","name":"amount1Min","type":"uint256"},{"internalType":"address","name":"recipient","type":"address"},{"internalType":"uint256","name":"deadline","type":"uint256"}],"internalType":"struct INonfungiblePositionManager.MintParams","name":"params","type":"tuple"}],"name":"mint","outputs":[{"internalType":"uint256","name":"tokenId","type":"uint256"},{"internalType":"uint128","name":"liquidity","type":"uint128"},{"internalType":"uint256","name":"amount0","type":"uint256"},{"internalType":"uint256","name":"amount1","type":"uint256"}],"stateMutability":"payable","type":"function"},{"inputs":[{"internalType":"bytes[]","name":"data","type":"bytes[]"}],"name":"multicall","outputs":[{"internalType":"bytes[]","name":"results","type":"bytes[]"}],"stateMutability":"payable","type":"function"},{"inputs":[],"name":"name","outputs":[{"internalType":"string","name":"","type":"string"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"uint256","name":"tokenId","type":"uint256"}],"name":"ownerOf","outputs":[{"internalType":"address","name":"","type":"address"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"uint256","name":"amount0Owed","type":"uint256"},{"internalType":"uint256","name":"amount1Owed","type":"uint256"},{"internalType":"bytes","name":"data","type":"bytes"}],"name":"pancakeV3MintCallback","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"address","name":"spender","type":"address"},{"internalType":"uint256","name":"tokenId","type":"uint256"},{"internalType":"uint256","name":"deadline","type":"uint256"},{"internalType":"uint8","name":"v","type":"uint8"},{"internalType":"bytes32","name":"r","type":"bytes32"},{"internalType":"bytes32","name":"s","type":"bytes32"}],"name":"permit","outputs":[],"stateMutability":"payable","type":"function"},{"inputs":[{"internalType":"uint256","name":"tokenId","type":"uint256"}],"name":"positions","outputs":[{"internalType":"uint96","name":"nonce","type":"uint96"},{"internalType":"address","name":"operator","type":"address"},{"internalType":"address","name":"token0","type":"address"},{"internalType":"address","name":"token1","type":"address"},{"internalType":"uint24","name":"fee","type":"uint24"},{"internalType":"int24","name":"tickLower","type":"int24"},{"internalType":"int24","name":"tickUpper","type":"int24"},{"internalType":"uint128","name":"liquidity","type":"uint128"},{"internalType":"uint256","name":"feeGrowthInside0LastX128","type":"uint256"},{"internalType":"uint256","name":"feeGrowthInside1LastX128","type":"uint256"},{"internalType":"uint128","name":"tokensOwed0","type":"uint128"},{"internalType":"uint128","name":"tokensOwed1","type":"uint128"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"refundETH","outputs":[],"stateMutability":"payable","type":"function"},{"inputs":[{"internalType":"address","name":"from","type":"address"},{"internalType":"address","name":"to","type":"address"},{"internalType":"uint256","name":"tokenId","type":"uint256"}],"name":"safeTransferFrom","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"address","name":"from","type":"address"},{"internalType":"address","name":"to","type":"address"},{"internalType":"uint256","name":"tokenId","type":"uint256"},{"internalType":"bytes","name":"_data","type":"bytes"}],"name":"safeTransferFrom","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"address","name":"token","type":"address"},{"internalType":"uint256","name":"value","type":"uint256"},{"internalType":"uint256","name":"deadline","type":"uint256"},{"internalType":"uint8","name":"v","type":"uint8"},{"internalType":"bytes32","name":"r","type":"bytes32"},{"internalType":"bytes32","name":"s","type":"bytes32"}],"name":"selfPermit","outputs":[],"stateMutability":"payable","type":"function"},{"inputs":[{"internalType":"address","name":"token","type":"address"},{"internalType":"uint256","name":"nonce","type":"uint256"},{"internalType":"uint256","name":"expiry","type":"uint256"},{"internalType":"uint8","name":"v","type":"uint8"},{"internalType":"bytes32","name":"r","type":"bytes32"},{"internalType":"bytes32","name":"s","type":"bytes32"}],"name":"selfPermitAllowed","outputs":[],"stateMutability":"payable","type":"function"},{"inputs":[{"internalType":"address","name":"token","type":"address"},{"internalType":"uint256","name":"nonce","type":"uint256"},{"internalType":"uint256","name":"expiry","type":"uint256"},{"internalType":"uint8","name":"v","type":"uint8"},{"internalType":"bytes32","name":"r","type":"bytes32"},{"internalType":"bytes32","name":"s","type":"bytes32"}],"name":"selfPermitAllowedIfNecessary","outputs":[],"stateMutability":"payable","type":"function"},{"inputs":[{"internalType":"address","name":"token","type":"address"},{"internalType":"uint256","name":"value","type":"uint256"},{"internalType":"uint256","name":"deadline","type":"uint256"},{"internalType":"uint8","name":"v","type":"uint8"},{"internalType":"bytes32","name":"r","type":"bytes32"},{"internalType":"bytes32","name":"s","type":"bytes32"}],"name":"selfPermitIfNecessary","outputs":[],"stateMutability":"payable","type":"function"},{"inputs":[{"internalType":"address","name":"operator","type":"address"},{"internalType":"bool","name":"approved","type":"bool"}],"name":"setApprovalForAll","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"bytes4","name":"interfaceId","type":"bytes4"}],"name":"supportsInterface","outputs":[{"internalType":"bool","name":"","type":"bool"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"address","name":"token","type":"address"},{"internalType":"uint256","name":"amountMinimum","type":"uint256"},{"internalType":"address","name":"recipient","type":"address"}],"name":"sweepToken","outputs":[],"stateMutability":"payable","type":"function"},{"inputs":[],"name":"symbol","outputs":[{"internalType":"string","name":"","type":"string"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"uint256","name":"index","type":"uint256"}],"name":"tokenByIndex","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"address","name":"owner","type":"address"},{"internalType":"uint256","name":"index","type":"uint256"}],"name":"tokenOfOwnerByIndex","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"uint256","name":"tokenId","type":"uint256"}],"name":"tokenURI","outputs":[{"internalType":"string","name":"","type":"string"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"totalSupply","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"address","name":"from","type":"address"},{"internalType":"address","name":"to","type":"address"},{"internalType":"uint256","name":"tokenId","type":"uint256"}],"name":"transferFrom","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"uint256","name":"amountMinimum","type":"uint256"},{"internalType":"address","name":"recipient","type":"address"}],"name":"unwrapWETH9","outputs":[],"stateMutability":"payable","type":"function"},{"stateMutability":"payable","type":"receive"}]
*/pragma solidity ^0.8.0;

interface IPancakeFactory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
}// SPDX-License-Identifier: MIT
pragma solidity >=0.6.2;

interface IPancakePair {
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
}// SPDX-License-Identifier: UNLICENSED
// !! THIS FILE WAS AUTOGENERATED BY abi-to-sol v0.8.0. SEE SOURCE BELOW. !!
pragma solidity >=0.7.0 <0.9.0;

interface IPancakeRouterV2 {
    function WETH() external view returns (address);

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

    function factory() external view returns (address);

    function getAmountIn(
        uint256 amountOut,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountIn);

    function getAmountOut(
        uint256 amountIn,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountOut);

    function getAmountsIn(
        uint256 amountOut,
        address[] memory path
    ) external view returns (uint256[] memory amounts);

    function getAmountsOut(
        uint256 amountIn,
        address[] memory path
    ) external view returns (uint256[] memory amounts);

    function quote(
        uint256 amountA,
        uint256 reserveA,
        uint256 reserveB
    ) external pure returns (uint256 amountB);

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

    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountETH);

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

    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
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
    ) external returns (uint256 amountETH);

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

    function swapETHForExactTokens(
        uint256 amountOut,
        address[] memory path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function swapExactETHForTokens(
        uint256 amountOutMin,
        address[] memory path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint256 amountOutMin,
        address[] memory path,
        address to,
        uint256 deadline
    ) external payable;

    function swapExactTokensForETH(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] memory path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] memory path,
        address to,
        uint256 deadline
    ) external;

    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] memory path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] memory path,
        address to,
        uint256 deadline
    ) external;

    function swapTokensForExactETH(
        uint256 amountOut,
        uint256 amountInMax,
        address[] memory path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapTokensForExactTokens(
        uint256 amountOut,
        uint256 amountInMax,
        address[] memory path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    receive() external payable;
}

// THIS FILE WAS AUTOGENERATED FROM THE FOLLOWING ABI JSON:
/*
[{"inputs":[{"internalType":"address","name":"_factory","type":"address"},{"internalType":"address","name":"_WETH","type":"address"}],"stateMutability":"nonpayable","type":"constructor"},{"inputs":[],"name":"WETH","outputs":[{"internalType":"address","name":"","type":"address"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"address","name":"tokenA","type":"address"},{"internalType":"address","name":"tokenB","type":"address"},{"internalType":"uint256","name":"amountADesired","type":"uint256"},{"internalType":"uint256","name":"amountBDesired","type":"uint256"},{"internalType":"uint256","name":"amountAMin","type":"uint256"},{"internalType":"uint256","name":"amountBMin","type":"uint256"},{"internalType":"address","name":"to","type":"address"},{"internalType":"uint256","name":"deadline","type":"uint256"}],"name":"addLiquidity","outputs":[{"internalType":"uint256","name":"amountA","type":"uint256"},{"internalType":"uint256","name":"amountB","type":"uint256"},{"internalType":"uint256","name":"liquidity","type":"uint256"}],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"address","name":"token","type":"address"},{"internalType":"uint256","name":"amountTokenDesired","type":"uint256"},{"internalType":"uint256","name":"amountTokenMin","type":"uint256"},{"internalType":"uint256","name":"amountETHMin","type":"uint256"},{"internalType":"address","name":"to","type":"address"},{"internalType":"uint256","name":"deadline","type":"uint256"}],"name":"addLiquidityETH","outputs":[{"internalType":"uint256","name":"amountToken","type":"uint256"},{"internalType":"uint256","name":"amountETH","type":"uint256"},{"internalType":"uint256","name":"liquidity","type":"uint256"}],"stateMutability":"payable","type":"function"},{"inputs":[],"name":"factory","outputs":[{"internalType":"address","name":"","type":"address"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"uint256","name":"amountOut","type":"uint256"},{"internalType":"uint256","name":"reserveIn","type":"uint256"},{"internalType":"uint256","name":"reserveOut","type":"uint256"}],"name":"getAmountIn","outputs":[{"internalType":"uint256","name":"amountIn","type":"uint256"}],"stateMutability":"pure","type":"function"},{"inputs":[{"internalType":"uint256","name":"amountIn","type":"uint256"},{"internalType":"uint256","name":"reserveIn","type":"uint256"},{"internalType":"uint256","name":"reserveOut","type":"uint256"}],"name":"getAmountOut","outputs":[{"internalType":"uint256","name":"amountOut","type":"uint256"}],"stateMutability":"pure","type":"function"},{"inputs":[{"internalType":"uint256","name":"amountOut","type":"uint256"},{"internalType":"address[]","name":"path","type":"address[]"}],"name":"getAmountsIn","outputs":[{"internalType":"uint256[]","name":"amounts","type":"uint256[]"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"uint256","name":"amountIn","type":"uint256"},{"internalType":"address[]","name":"path","type":"address[]"}],"name":"getAmountsOut","outputs":[{"internalType":"uint256[]","name":"amounts","type":"uint256[]"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"uint256","name":"amountA","type":"uint256"},{"internalType":"uint256","name":"reserveA","type":"uint256"},{"internalType":"uint256","name":"reserveB","type":"uint256"}],"name":"quote","outputs":[{"internalType":"uint256","name":"amountB","type":"uint256"}],"stateMutability":"pure","type":"function"},{"inputs":[{"internalType":"address","name":"tokenA","type":"address"},{"internalType":"address","name":"tokenB","type":"address"},{"internalType":"uint256","name":"liquidity","type":"uint256"},{"internalType":"uint256","name":"amountAMin","type":"uint256"},{"internalType":"uint256","name":"amountBMin","type":"uint256"},{"internalType":"address","name":"to","type":"address"},{"internalType":"uint256","name":"deadline","type":"uint256"}],"name":"removeLiquidity","outputs":[{"internalType":"uint256","name":"amountA","type":"uint256"},{"internalType":"uint256","name":"amountB","type":"uint256"}],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"address","name":"token","type":"address"},{"internalType":"uint256","name":"liquidity","type":"uint256"},{"internalType":"uint256","name":"amountTokenMin","type":"uint256"},{"internalType":"uint256","name":"amountETHMin","type":"uint256"},{"internalType":"address","name":"to","type":"address"},{"internalType":"uint256","name":"deadline","type":"uint256"}],"name":"removeLiquidityETH","outputs":[{"internalType":"uint256","name":"amountToken","type":"uint256"},{"internalType":"uint256","name":"amountETH","type":"uint256"}],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"address","name":"token","type":"address"},{"internalType":"uint256","name":"liquidity","type":"uint256"},{"internalType":"uint256","name":"amountTokenMin","type":"uint256"},{"internalType":"uint256","name":"amountETHMin","type":"uint256"},{"internalType":"address","name":"to","type":"address"},{"internalType":"uint256","name":"deadline","type":"uint256"}],"name":"removeLiquidityETHSupportingFeeOnTransferTokens","outputs":[{"internalType":"uint256","name":"amountETH","type":"uint256"}],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"address","name":"token","type":"address"},{"internalType":"uint256","name":"liquidity","type":"uint256"},{"internalType":"uint256","name":"amountTokenMin","type":"uint256"},{"internalType":"uint256","name":"amountETHMin","type":"uint256"},{"internalType":"address","name":"to","type":"address"},{"internalType":"uint256","name":"deadline","type":"uint256"},{"internalType":"bool","name":"approveMax","type":"bool"},{"internalType":"uint8","name":"v","type":"uint8"},{"internalType":"bytes32","name":"r","type":"bytes32"},{"internalType":"bytes32","name":"s","type":"bytes32"}],"name":"removeLiquidityETHWithPermit","outputs":[{"internalType":"uint256","name":"amountToken","type":"uint256"},{"internalType":"uint256","name":"amountETH","type":"uint256"}],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"address","name":"token","type":"address"},{"internalType":"uint256","name":"liquidity","type":"uint256"},{"internalType":"uint256","name":"amountTokenMin","type":"uint256"},{"internalType":"uint256","name":"amountETHMin","type":"uint256"},{"internalType":"address","name":"to","type":"address"},{"internalType":"uint256","name":"deadline","type":"uint256"},{"internalType":"bool","name":"approveMax","type":"bool"},{"internalType":"uint8","name":"v","type":"uint8"},{"internalType":"bytes32","name":"r","type":"bytes32"},{"internalType":"bytes32","name":"s","type":"bytes32"}],"name":"removeLiquidityETHWithPermitSupportingFeeOnTransferTokens","outputs":[{"internalType":"uint256","name":"amountETH","type":"uint256"}],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"address","name":"tokenA","type":"address"},{"internalType":"address","name":"tokenB","type":"address"},{"internalType":"uint256","name":"liquidity","type":"uint256"},{"internalType":"uint256","name":"amountAMin","type":"uint256"},{"internalType":"uint256","name":"amountBMin","type":"uint256"},{"internalType":"address","name":"to","type":"address"},{"internalType":"uint256","name":"deadline","type":"uint256"},{"internalType":"bool","name":"approveMax","type":"bool"},{"internalType":"uint8","name":"v","type":"uint8"},{"internalType":"bytes32","name":"r","type":"bytes32"},{"internalType":"bytes32","name":"s","type":"bytes32"}],"name":"removeLiquidityWithPermit","outputs":[{"internalType":"uint256","name":"amountA","type":"uint256"},{"internalType":"uint256","name":"amountB","type":"uint256"}],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"uint256","name":"amountOut","type":"uint256"},{"internalType":"address[]","name":"path","type":"address[]"},{"internalType":"address","name":"to","type":"address"},{"internalType":"uint256","name":"deadline","type":"uint256"}],"name":"swapETHForExactTokens","outputs":[{"internalType":"uint256[]","name":"amounts","type":"uint256[]"}],"stateMutability":"payable","type":"function"},{"inputs":[{"internalType":"uint256","name":"amountOutMin","type":"uint256"},{"internalType":"address[]","name":"path","type":"address[]"},{"internalType":"address","name":"to","type":"address"},{"internalType":"uint256","name":"deadline","type":"uint256"}],"name":"swapExactETHForTokens","outputs":[{"internalType":"uint256[]","name":"amounts","type":"uint256[]"}],"stateMutability":"payable","type":"function"},{"inputs":[{"internalType":"uint256","name":"amountOutMin","type":"uint256"},{"internalType":"address[]","name":"path","type":"address[]"},{"internalType":"address","name":"to","type":"address"},{"internalType":"uint256","name":"deadline","type":"uint256"}],"name":"swapExactETHForTokensSupportingFeeOnTransferTokens","outputs":[],"stateMutability":"payable","type":"function"},{"inputs":[{"internalType":"uint256","name":"amountIn","type":"uint256"},{"internalType":"uint256","name":"amountOutMin","type":"uint256"},{"internalType":"address[]","name":"path","type":"address[]"},{"internalType":"address","name":"to","type":"address"},{"internalType":"uint256","name":"deadline","type":"uint256"}],"name":"swapExactTokensForETH","outputs":[{"internalType":"uint256[]","name":"amounts","type":"uint256[]"}],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"uint256","name":"amountIn","type":"uint256"},{"internalType":"uint256","name":"amountOutMin","type":"uint256"},{"internalType":"address[]","name":"path","type":"address[]"},{"internalType":"address","name":"to","type":"address"},{"internalType":"uint256","name":"deadline","type":"uint256"}],"name":"swapExactTokensForETHSupportingFeeOnTransferTokens","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"uint256","name":"amountIn","type":"uint256"},{"internalType":"uint256","name":"amountOutMin","type":"uint256"},{"internalType":"address[]","name":"path","type":"address[]"},{"internalType":"address","name":"to","type":"address"},{"internalType":"uint256","name":"deadline","type":"uint256"}],"name":"swapExactTokensForTokens","outputs":[{"internalType":"uint256[]","name":"amounts","type":"uint256[]"}],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"uint256","name":"amountIn","type":"uint256"},{"internalType":"uint256","name":"amountOutMin","type":"uint256"},{"internalType":"address[]","name":"path","type":"address[]"},{"internalType":"address","name":"to","type":"address"},{"internalType":"uint256","name":"deadline","type":"uint256"}],"name":"swapExactTokensForTokensSupportingFeeOnTransferTokens","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"uint256","name":"amountOut","type":"uint256"},{"internalType":"uint256","name":"amountInMax","type":"uint256"},{"internalType":"address[]","name":"path","type":"address[]"},{"internalType":"address","name":"to","type":"address"},{"internalType":"uint256","name":"deadline","type":"uint256"}],"name":"swapTokensForExactETH","outputs":[{"internalType":"uint256[]","name":"amounts","type":"uint256[]"}],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"uint256","name":"amountOut","type":"uint256"},{"internalType":"uint256","name":"amountInMax","type":"uint256"},{"internalType":"address[]","name":"path","type":"address[]"},{"internalType":"address","name":"to","type":"address"},{"internalType":"uint256","name":"deadline","type":"uint256"}],"name":"swapTokensForExactTokens","outputs":[{"internalType":"uint256[]","name":"amounts","type":"uint256[]"}],"stateMutability":"nonpayable","type":"function"},{"stateMutability":"payable","type":"receive"}]
*/
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IPancakeswapFarm {
    function poolLength() external view returns (uint256);

    function userInfo() external view returns (uint256);

    // Return reward multiplier over the given _from to _to block.
    function getMultiplier(uint256 _from, uint256 _to)
    external
    view
    returns (uint256);

    // View function to see pending CAKEs on frontend.
    function pendingCake(uint256 _pid, address _user)
    external
    view
    returns (uint256);

    // Deposit LP tokens to MasterChef for CAKE allocation.
    function deposit(uint256 _pid, uint256 _amount) external;

    // Withdraw LP tokens from MasterChef.
    function withdraw(uint256 _pid, uint256 _amount) external;

    // Stake CAKE tokens to MasterChef
    function enterStaking(uint256 _amount) external;

    // Withdraw CAKE tokens from STAKING.
    function leaveStaking(uint256 _amount) external;

    // Withdraw without caring about rewards. EMERGENCY ONLY.
    function emergencyWithdraw(uint256 _pid) external;
}interface IPancakeV3Optimizer {
    function totalSupply() external view returns (uint256);

    function shareCount(address) external view returns (uint256);
}
interface IPancakeV3OptimizerDistribution {
    function claimDogsRewards(address _user) external;
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IPigPen {

    struct UserInfo {
        uint256 amount;
        uint256 busdRewardDebt;
        uint256 pigsRewardDebt;
        uint256 startLockTimestamp;
    }

    function deposit(uint256 _amount) external;
    function claimRewards(bool _shouldCompound) external;
    function withdraw() external;
    function emergencyWithdraw() external;

}// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IPigsToken {

    function mint(address _to, uint256 _amount) external;

}// SPDX-License-Identifier: UNLICENSED
// !! THIS FILE WAS AUTOGENERATED BY abi-to-sol v0.8.0. SEE SOURCE BELOW. !!
pragma experimental ABIEncoderV2;

interface IQuoterV2 {
    struct QuoteExactInputSingleParams {
        address tokenIn;
        address tokenOut;
        uint256 amountIn;
        uint24 fee;
        uint160 sqrtPriceLimitX96;
    }


    function quoteExactInputSingle(QuoteExactInputSingleParams memory params)
        external
        returns (
            uint256 amountOut,
            uint160 sqrtPriceX96After,
            uint32 initializedTicksCrossed,
            uint256 gasEstimate
        );
}

// THIS FILE WAS AUTOGENERATED FROM THE FOLLOWING ABI JSON:
/*
[{"inputs":[{"internalType":"address","name":"_deployer","type":"address"},{"internalType":"address","name":"_factory","type":"address"},{"internalType":"address","name":"_WETH9","type":"address"}],"stateMutability":"nonpayable","type":"constructor"},{"inputs":[],"name":"WETH9","outputs":[{"internalType":"address","name":"","type":"address"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"deployer","outputs":[{"internalType":"address","name":"","type":"address"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"factory","outputs":[{"internalType":"address","name":"","type":"address"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"int256","name":"amount0Delta","type":"int256"},{"internalType":"int256","name":"amount1Delta","type":"int256"},{"internalType":"bytes","name":"path","type":"bytes"}],"name":"pancakeV3SwapCallback","outputs":[],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"bytes","name":"path","type":"bytes"},{"internalType":"uint256","name":"amountIn","type":"uint256"}],"name":"quoteExactInput","outputs":[{"internalType":"uint256","name":"amountOut","type":"uint256"},{"internalType":"uint160[]","name":"sqrtPriceX96AfterList","type":"uint160[]"},{"internalType":"uint32[]","name":"initializedTicksCrossedList","type":"uint32[]"},{"internalType":"uint256","name":"gasEstimate","type":"uint256"}],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"components":[{"internalType":"address","name":"tokenIn","type":"address"},{"internalType":"address","name":"tokenOut","type":"address"},{"internalType":"uint256","name":"amountIn","type":"uint256"},{"internalType":"uint24","name":"fee","type":"uint24"},{"internalType":"uint160","name":"sqrtPriceLimitX96","type":"uint160"}],"internalType":"struct IQuoterV2.QuoteExactInputSingleParams","name":"params","type":"tuple"}],"name":"quoteExactInputSingle","outputs":[{"internalType":"uint256","name":"amountOut","type":"uint256"},{"internalType":"uint160","name":"sqrtPriceX96After","type":"uint160"},{"internalType":"uint32","name":"initializedTicksCrossed","type":"uint32"},{"internalType":"uint256","name":"gasEstimate","type":"uint256"}],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"bytes","name":"path","type":"bytes"},{"internalType":"uint256","name":"amountOut","type":"uint256"}],"name":"quoteExactOutput","outputs":[{"internalType":"uint256","name":"amountIn","type":"uint256"},{"internalType":"uint160[]","name":"sqrtPriceX96AfterList","type":"uint160[]"},{"internalType":"uint32[]","name":"initializedTicksCrossedList","type":"uint32[]"},{"internalType":"uint256","name":"gasEstimate","type":"uint256"}],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"components":[{"internalType":"address","name":"tokenIn","type":"address"},{"internalType":"address","name":"tokenOut","type":"address"},{"internalType":"uint256","name":"amount","type":"uint256"},{"internalType":"uint24","name":"fee","type":"uint24"},{"internalType":"uint160","name":"sqrtPriceLimitX96","type":"uint160"}],"internalType":"struct IQuoterV2.QuoteExactOutputSingleParams","name":"params","type":"tuple"}],"name":"quoteExactOutputSingle","outputs":[{"internalType":"uint256","name":"amountIn","type":"uint256"},{"internalType":"uint160","name":"sqrtPriceX96After","type":"uint160"},{"internalType":"uint32","name":"initializedTicksCrossed","type":"uint32"},{"internalType":"uint256","name":"gasEstimate","type":"uint256"}],"stateMutability":"nonpayable","type":"function"}]
*/// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IReferralSystem {
    /**
     * @dev Record referral.
     */
    function recordReferral(address user, address referrer) external;

    /**
     * @dev Record referral commission.
     */
    function recordReferralCommission(address referrer, uint256 commission) external;

    /**
     * @dev Get the referrer address that referred the user.
     */
    function getReferrer(address user) external view returns (address);
}// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IRewardsVault {

    function payoutDivs()
    external;

}// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IStakeManager {
    
    struct UserInfo {

        uint256 totalStakedDefault; //linear
        uint256 totalStakedAutoCompound;

        uint256 walletStartTime;
        uint256 overThresholdTimeCounter;

        uint256 activeStakesCount;
        uint256 withdrawStakesCount;

        mapping(uint256 => StakeInfo) activeStakes;
        mapping(uint256 => WithdrawnStakeInfo) withdrawnStakes;

    }

    struct WithdrawnStakeInfo {
        uint256 amount;
        uint256 taxReduction;
    }


    struct StakeInfo {
        uint256 amount;
        uint256 startTime;
        bool isAutoPool;
    } // todo find a way to refactor

    function saveStake(address _user, uint256 _amount, bool isAutoCompound) external;
    function withdrawFromStake(address _user,uint256 _amount, uint256 _stakeID) external;
    function getUserStake(address _user, uint256 _stakeID) external view returns (StakeInfo memory);
    function getActiveStakeTaxReduction(address _user, uint256 _stakeID) external view returns (uint256);
    function getWithdrawnStakeTaxReduction(address _user, uint256 _stakeID) external view returns (uint256);
    function isStakeAutoPool(address _user, uint256 _stakeID) external view returns (bool);
    function totalStaked(address _user) external view returns (uint256);
    function utilizeWithdrawnStake(address _user, uint256 _amount, uint256 _stakeID) external;
}// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IStrategy {
    // Total want tokens managed by strategy
    function wantLockedTotal() external view returns (uint256);

    // Main want token compounding function
    function earn() external;

    // Transfer want tokens MasterChefV2 -> strategy
    function deposit(uint256 _wantAmt)
    external
    returns (uint256);

    // Transfer want tokens strategy -> MasterChefV2
    function withdraw(uint256 _wantAmt)
    external
    returns (uint256);

    function inCaseTokensGetStuck(
        address _token,
        uint256 _amount,
        address _to
    ) external;
}// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface ITestingDummyMC {

    function updateMassUsers(address[] memory _users, uint256[] memory _amounts) external;
}// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IToolbox {

    function getTokenBUSDValue(uint256 tokenBalance, address token, bool isLPToken) external view returns (uint256);

}// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";
import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Pair.sol";
import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Factory.sol";

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

// AddLiquidityHelper, allows anyone to add
contract AddLiquidityDogsHelper is ReentrancyGuard, Ownable {
    using SafeERC20 for ERC20;
    using SafeERC20 for IERC20;

    address public dogsTokenAddress;

    IUniswapV2Router02 public constant PancakeRouter = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);

    address public constant busdCurrencyAddress = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;
    address public constant wbnbCurrencyAddress = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;

    receive() external payable {}

    event SetDogsAddresses(address dogsTokenAddress);

    function addDogsBNBLiquidity(uint256 nativeAmount) external payable nonReentrant {
        require(msg.value > 0, "!sufficient funds");

        ERC20(dogsTokenAddress).safeTransferFrom(msg.sender, address(this), nativeAmount);

        // Approval done when Dogs token is set...

        // add the liquidity
        PancakeRouter.addLiquidityETH{value: msg.value}(
            dogsTokenAddress,
            nativeAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            msg.sender,
            block.timestamp
        );

        if (address(this).balance > 0) {
            payable(msg.sender).call{value: address(this).balance}("");
        }

        if (ERC20(dogsTokenAddress).balanceOf(address(this)) > 0)
            ERC20(dogsTokenAddress).transfer(msg.sender, ERC20(dogsTokenAddress).balanceOf(address(this)));
    }

    function addDogsLiquidity(address baseTokenAddress, uint256 baseAmount, uint256 dogsAmount) external nonReentrant {
        ERC20(baseTokenAddress).safeTransferFrom(msg.sender, address(this), baseAmount);
        ERC20(dogsTokenAddress).safeTransferFrom(msg.sender, address(this), dogsAmount);

        // approve baseToken, Dogs token handled when set
        _approveTokenIfNeeded(baseTokenAddress);

        // add the liquidity
        PancakeRouter.addLiquidity(
            baseTokenAddress,
            dogsTokenAddress,
            baseAmount,
            dogsAmount ,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            msg.sender,
            block.timestamp
        );

        uint256 baseTokenBalance = ERC20(baseTokenAddress).balanceOf(address(this));
        uint256 dogsTokenBalance = ERC20(dogsTokenAddress).balanceOf(address(this));

        if (baseTokenBalance > 0)
            ERC20(baseTokenAddress).safeTransfer(msg.sender, baseTokenBalance);

        if (dogsTokenBalance > 0)
            ERC20(dogsTokenAddress).transfer(msg.sender, dogsTokenBalance);
    }

    function buyDogsBNB(uint256 _minAmountOut, address[] memory _path) external nonReentrant payable {
        require(_path[0] == PancakeRouter.WETH(), 'invalid path');
        require(_path[_path.length-1] == dogsTokenAddress, 'invalid path');
        require(msg.value > 0, 'zero amount');

        PancakeRouter.swapExactETHForTokens{value: msg.value}(
            _minAmountOut,
            _path,
            address(this),
            block.timestamp
        );

        uint256 amountDogsBought = IERC20(dogsTokenAddress).balanceOf(address(this));
        IERC20(dogsTokenAddress).transfer(msg.sender, amountDogsBought);

    }

    // expect path to be busd/dogs & bnb/dogs
    function buyDogs(uint256 _tokenAmount, uint256 _minAmountOut, address[] memory _path) external nonReentrant {
        require(_path[_path.length - 1] == dogsTokenAddress);
        require(_tokenAmount > 0, 'zero amount');

        ERC20(_path[0]).safeTransferFrom(msg.sender, address(this), _tokenAmount);

        _approveTokenIfNeeded(_path[0]);

        PancakeRouter.swapExactTokensForTokens(
            _tokenAmount,
            _minAmountOut,
            _path,
            address(this),
            block.timestamp
        );

        uint256 amountDogsBought = IERC20(dogsTokenAddress).balanceOf(address(this));
        IERC20(dogsTokenAddress).transfer(msg.sender, amountDogsBought);

    }

    /**
     * @dev set the Dogs address.
     * Can only be called by the current owner.
     */
    function setDogsAddress(address _dogsTokenAddress) external onlyOwner {
        require(_dogsTokenAddress != address(0), "_dogsTokenAddress is the zero address");
        require(dogsTokenAddress == address(0), "dogsTokenAddress already set!");

        dogsTokenAddress = _dogsTokenAddress;

        _approveTokenIfNeeded(_dogsTokenAddress);

        emit SetDogsAddresses(dogsTokenAddress);
    }

      function _approveTokenIfNeeded(address token) private {
        if (IERC20(token).allowance(address(this), address(PancakeRouter)) == 0) {
            IERC20(token).safeApprove(address(PancakeRouter), type(uint256).max);
        }
    }

}// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";
import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Pair.sol";
import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Factory.sol";

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

// AddLiquidityHelper, allows anyone to add or remove Dogs liquidity tax free
// Also allows the Dogs Token to do buy backs tax free via an external contract.
contract AddLiquidityHelperV2 is ReentrancyGuard, Ownable {
    using SafeERC20 for ERC20;

    address public dogsTokenAddress = 0x198271b868daE875bFea6e6E4045cDdA5d6B9829;
    address public pigsTokenAddress;

    IUniswapV2Router02 public constant pancakeswapRouter = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
    address public constant busdCurrencyAddress = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;
    address public constant wbnbCurrencyAddress = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address public dogsBusdPair;

    mapping (address => bool) public LiquidityAllowanceMap;

    receive() external payable {}

    event SetDogsAddresses(address dogsTokenAddress, address dogsBusdPair);
    event SetPigsAddresses(address pigsTokenAddress);
    event SetRouteTokenViaBNB(address tokenAddress, bool shouldRoute);


    /**
     * @notice Constructs the AddLiquidityHelper contract.
     */
    constructor() {
        LiquidityAllowanceMap[busdCurrencyAddress] = true;
        LiquidityAllowanceMap[wbnbCurrencyAddress] = true;
        dogsBusdPair = IUniswapV2Factory(pancakeswapRouter.factory()).getPair(dogsTokenAddress, busdCurrencyAddress);

    }


    function changeLiquidityAllowanceMap(address _liquidityTokenAdress, bool _allowance) external onlyOwner{
        LiquidityAllowanceMap[_liquidityTokenAdress] = _allowance;
    }

    function addDogsETHLiquidity(uint256 nativeAmount) external payable nonReentrant {
        require(msg.value > 0, "!sufficient funds");

        ERC20(dogsTokenAddress).safeTransferFrom(msg.sender, address(this), nativeAmount);

        // approve token transfer to cover all possible scenarios
        ERC20(dogsTokenAddress).approve(address(pancakeswapRouter), nativeAmount);

        // add the liquidity
        pancakeswapRouter.addLiquidityETH{value: msg.value}(
            dogsTokenAddress,
            nativeAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
                msg.sender,
            block.timestamp
        );

        if (address(this).balance > 0) {
            // not going to require/check return value of this transfer as reverting behaviour is undesirable.
            payable(msg.sender).call{value: address(this).balance}("");
        }

        if (ERC20(dogsTokenAddress).balanceOf(address(this)) > 0)
            ERC20(dogsTokenAddress).transfer(msg.sender, ERC20(dogsTokenAddress).balanceOf(address(this)));
    }

    function addDogsLiquidity(address baseTokenAddress, uint256 baseAmount, uint256 nativeAmount) external nonReentrant {
        require(LiquidityAllowanceMap[baseTokenAddress]);
        ERC20(baseTokenAddress).safeTransferFrom(msg.sender, address(this), baseAmount);
        ERC20(dogsTokenAddress).safeTransferFrom(msg.sender, address(this), nativeAmount);

        // approve token transfer to cover all possible scenarios
        ERC20(baseTokenAddress).approve(address(pancakeswapRouter), baseAmount);
        ERC20(dogsTokenAddress).approve(address(pancakeswapRouter), nativeAmount);

        // add the liquidity
        pancakeswapRouter.addLiquidity(
            baseTokenAddress,
            dogsTokenAddress,
            baseAmount,
            nativeAmount ,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            msg.sender,
            block.timestamp
        );

        uint256 baseTokenBalance = ERC20(baseTokenAddress).balanceOf(address(this));
        uint256 dogsTokenBalance = ERC20(dogsTokenAddress).balanceOf(address(this));

        if (baseTokenBalance > 0)
            ERC20(baseTokenAddress).safeTransfer(msg.sender, baseTokenBalance);

        if (dogsTokenBalance > 0)
            ERC20(dogsTokenAddress).transfer(msg.sender, dogsTokenBalance);
    }

    function removeDogsLiquidity(address baseTokenAddress, uint256 liquidity) external nonReentrant {
        require(LiquidityAllowanceMap[baseTokenAddress]);
        address lpTokenAddress = IUniswapV2Factory(pancakeswapRouter.factory()).getPair(baseTokenAddress, dogsTokenAddress);
        require(lpTokenAddress != address(0), "pair hasn't been created yet, so can't remove liquidity!");

        ERC20(lpTokenAddress).safeTransferFrom(msg.sender, address(this), liquidity);
        // approve token transfer to cover all possible scenarios
        ERC20(lpTokenAddress).approve(address(pancakeswapRouter), liquidity);

        // add the liquidity
        pancakeswapRouter.removeLiquidity(
            baseTokenAddress,
            dogsTokenAddress,
            liquidity,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            msg.sender,
            block.timestamp
        );
    }

    function addPigsETHLiquidity(uint256 nativeAmount) external payable nonReentrant {
        require(msg.value > 0, "!sufficient funds");

        ERC20(pigsTokenAddress).safeTransferFrom(msg.sender, address(this), nativeAmount);

        // approve token transfer to cover all possible scenarios
        ERC20(pigsTokenAddress).approve(address(pancakeswapRouter), nativeAmount);

        // add the liquidity
        pancakeswapRouter.addLiquidityETH{value: msg.value}(
            pigsTokenAddress,
            nativeAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            msg.sender,
            block.timestamp
        );

        if (address(this).balance > 0) {
            // not going to require/check return value of this transfer as reverting behaviour is undesirable.
            payable(msg.sender).call{value: address(this).balance}("");
        }

        if (ERC20(pigsTokenAddress).balanceOf(address(this)) > 0)
            ERC20(pigsTokenAddress).transfer(msg.sender, ERC20(pigsTokenAddress).balanceOf(address(this)));
    }

    function addPigsLiquidity(address baseTokenAddress, uint256 baseAmount, uint256 nativeAmount) external nonReentrant {
        require(LiquidityAllowanceMap[baseTokenAddress]);
        ERC20(baseTokenAddress).safeTransferFrom(msg.sender, address(this), baseAmount);
        ERC20(pigsTokenAddress).safeTransferFrom(msg.sender, address(this), nativeAmount);

        // approve token transfer to cover all possible scenarios
        ERC20(baseTokenAddress).approve(address(pancakeswapRouter), baseAmount);
        ERC20(pigsTokenAddress).approve(address(pancakeswapRouter), nativeAmount);

        // add the liquidity
        pancakeswapRouter.addLiquidity(
            baseTokenAddress,
                pigsTokenAddress,
            baseAmount,
            nativeAmount ,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            msg.sender,
            block.timestamp
        );

        uint256 baseTokenBalance = ERC20(baseTokenAddress).balanceOf(address(this));
        uint256 dogsTokenBalance = ERC20(dogsTokenAddress).balanceOf(address(this));

        if (baseTokenBalance > 0)
            ERC20(baseTokenAddress).safeTransfer(msg.sender, baseTokenBalance);

        if (dogsTokenBalance > 0)
            ERC20(pigsTokenAddress).transfer(msg.sender, dogsTokenBalance);
    }

    function transferSlipBalance(address payable _transferAddress) external onlyOwner{
        _transferAddress.call{value: address(this).balance}("");
    }

    /**
     * @dev set the Dogs address.
     * Can only be called by the current owner.
     */
    function setDogsAddress(address _dogsTokenAddress) external onlyOwner {
        require(_dogsTokenAddress != address(0), "_dogsTokenAddress is the zero address");
        require(dogsTokenAddress == address(0), "dogsTokenAddress already set!");

        dogsTokenAddress = _dogsTokenAddress;

        dogsBusdPair = IUniswapV2Factory(pancakeswapRouter.factory()).getPair(dogsTokenAddress, busdCurrencyAddress);

        require(address(dogsBusdPair) != address(0), "busd/dogs pair !exist");

        emit SetDogsAddresses(dogsTokenAddress, dogsBusdPair);
    }

    /**
     * @dev set the Pigs address.
     * Can only be called by the current owner.
     */
    function setPigsAddress(address _pigsTokenAddress) external onlyOwner {
        require(_pigsTokenAddress != address(0), "_pigsTokenAddress is the zero address");
        require(pigsTokenAddress == address(0), "pigsTokenAddress already set!");

        pigsTokenAddress = _pigsTokenAddress;

        emit SetPigsAddresses(pigsTokenAddress);
    }


}// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";
import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Pair.sol";
import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Factory.sol";

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

  import "hardhat/console.sol"; //todo remove

contract DogsExchangeHelper is ReentrancyGuard, Ownable {
    using SafeERC20 for ERC20;
    using SafeERC20 for IERC20;

    address public dogsTokenAddress;

    IUniswapV2Router02 public constant PancakeRouter = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
    address public constant busdCurrencyAddress = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;
    address public constant wbnbCurrencyAddress = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;

    receive() external payable {}

    event SetDogsAddresses(address dogsTokenAddress);

    constructor(address _address) {
        dogsTokenAddress = _address;
        _approveTokenIfNeeded(dogsTokenAddress);
    }

    function addDogsBNBLiquidity(uint256 nativeAmount) external payable nonReentrant returns (
        uint256 lpAmount,
        uint256 unusedEth,
        uint256 unusedToken
    ){
        require(msg.value > 0, "!sufficient funds");

        ERC20(dogsTokenAddress).safeTransferFrom(msg.sender, address(this), nativeAmount);

        // Approval done when Dogs token is set...

        address lpTokenAddress = IUniswapV2Factory(PancakeRouter.factory()).getPair(PancakeRouter.WETH(), dogsTokenAddress);


        console.log("DogsExchangeHelper::addDogsBNBLiquidity::PancakeRouter.WETH()", PancakeRouter.WETH());
        console.log("DogsExchangeHelper::addDogsBNBLiquidity::lpTokenAddress", lpTokenAddress);
        console.log("DogsExchangeHelper::addDogsBNBLiquidity::nativeAmount", nativeAmount);
        console.log("DogsExchangeHelper::addDogsBNBLiquidity::msg.value", msg.value);
        console.log("DogsExchangeHelper::addDogsBNBLiquidity::msg.sender", msg.sender);

        // add the liquidity
        (uint256 usedToken, uint256 usedEth, uint256 lpValue) = PancakeRouter.addLiquidityETH{value: msg.value}(
            dogsTokenAddress,
            nativeAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            msg.sender,
            block.timestamp
        );

        lpAmount = lpValue;
        unusedToken = nativeAmount - usedToken;
        unusedEth = msg.value - usedEth;

        uint256 lp_balance = IERC20(lpTokenAddress).balanceOf(address(this));
        console.log("DogsExchangeHelper::addDogsBNBLiquidity::lp_balance", lp_balance);

        console.log("DogsExchangeHelper::addDogsBNBLiquidity::lpAmount", lpAmount);
        console.log("DogsExchangeHelper::addDogsBNBLiquidity::unusedToken", unusedToken);
        console.log("DogsExchangeHelper::addDogsBNBLiquidity::unusedEth", unusedEth);

        // send back unused tokens / BNB
        ERC20(dogsTokenAddress).safeTransfer(msg.sender, unusedToken);
        (bool transferSuccess, ) = payable(msg.sender).call{ value: unusedEth } (
            ""
        );
        require(transferSuccess, "TF");

    }

    function addDogsLiquidity(address baseTokenAddress, uint256 baseAmount, uint256 dogsAmount) external nonReentrant returns(
        uint256 lpAmount,
        uint256 unusedDogs,
        uint256 unusedBaseToken
    ) {
        ERC20(baseTokenAddress).safeTransferFrom(msg.sender, address(this), baseAmount);
        ERC20(dogsTokenAddress).safeTransferFrom(msg.sender, address(this), dogsAmount);

        // approve baseToken, Dogs token handled when set
        _approveTokenIfNeeded(baseTokenAddress);



        // add the liquidity
        (uint256 usedBaseToken, uint256 usedDogs, uint256 lpValue) = PancakeRouter.addLiquidity(
            baseTokenAddress,
            dogsTokenAddress,
            baseAmount,
            dogsAmount ,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            msg.sender,
            block.timestamp
        );

        lpAmount = lpValue;
        unusedBaseToken = baseAmount - usedBaseToken;
        unusedDogs = dogsAmount - usedDogs;

        // send back unused tokens
        ERC20(baseTokenAddress).safeTransfer(msg.sender, unusedBaseToken);
        ERC20(dogsTokenAddress).safeTransfer(msg.sender, unusedDogs);
    }

    function buyDogsBNB(uint256 _minAmountOut, address[] memory _path) external nonReentrant payable returns (uint256 amountDogsBought){
        require(_path[0] == PancakeRouter.WETH(), 'invalid path');
        require(_path[_path.length-1] == dogsTokenAddress, 'invalid path');
        require(msg.value > 0, 'zero amount');

        console.log("DogsExchangeHelper::_path[0]", _path[0]);
        console.log("DogsExchangeHelper::_path[_path.length-1]", _path[_path.length-1]);
        console.log("DogsExchangeHelper::buyDogsBNB", msg.value);
        console.log("DogsExchangeHelper::_minAmountOut", _minAmountOut);

        PancakeRouter.swapExactETHForTokensSupportingFeeOnTransferTokens{value: msg.value}(
            _minAmountOut,
            _path,
            address(this),
            block.timestamp
        );

        uint256 amountDogsBought = IERC20(dogsTokenAddress).balanceOf(address(this));
        console.log("DogsExchangeHelper::amountDogsBought", amountDogsBought);
        IERC20(dogsTokenAddress).transfer(msg.sender, amountDogsBought);

        return amountDogsBought;

    }

    // expect path to be busd/dogs & bnb/dogs
    function buyDogs(uint256 _tokenAmount, uint256 _minAmountOut, address[] memory _path) external nonReentrant returns(uint256 amountDogsBought){
        require(_path[_path.length-1] == dogsTokenAddress);
        require(_tokenAmount > 0, 'zero amount');

        ERC20(_path[0]).safeTransferFrom(msg.sender, address(this), _tokenAmount);

        _approveTokenIfNeeded(_path[0]);

        uint256 amountDogsBought = PancakeRouter.swapExactTokensForTokens(
            _tokenAmount,
            _minAmountOut,
            _path,
            address(this),
            block.timestamp
        )[_path.length - 1];

//        uint256 amountDogsBought = IERC20(dogsTokenAddress).balanceOf(address(this));
        IERC20(dogsTokenAddress).transfer(msg.sender, amountDogsBought);
        return amountDogsBought;
    }

    /**
     * @dev set the Dogs address.
     * Can only be called by the current owner.
     */
    function setDogsAddress(address _dogsTokenAddress) external onlyOwner {
        require(_dogsTokenAddress != address(0), "_dogsTokenAddress is the zero address");

        dogsTokenAddress = _dogsTokenAddress;

        _approveTokenIfNeeded(_dogsTokenAddress);

        emit SetDogsAddresses(dogsTokenAddress);
    }

    function _approveTokenIfNeeded(address token) private {
        if (IERC20(token).allowance(address(this), address(PancakeRouter)) == 0) {
            IERC20(token).safeApprove(address(PancakeRouter), type(uint256).max);
        }
    }

}// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";
import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Pair.sol";
import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Factory.sol";

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract LiquidityHelperPigsV2 is ReentrancyGuard, Ownable {
    using SafeERC20 for ERC20;

    address public pigsV2TokenAddress;

    IUniswapV2Router02 public constant pancakeswapRouter = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
    address public constant busdCurrencyAddress = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;
    address public constant wbnbCurrencyAddress = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;

    receive() external payable {}

    event SetPigsAddresses(address pigsTokenAddress);

    function addPigsETHLiquidity(uint256 nativeAmount) external payable nonReentrant {
        require(msg.value > 0, "!sufficient funds");

        ERC20(pigsV2TokenAddress).safeTransferFrom(msg.sender, address(this), nativeAmount);

        // approve token transfer to cover all possible scenarios
        ERC20(pigsV2TokenAddress).approve(address(pancakeswapRouter), nativeAmount);

        // add the liquidity
        pancakeswapRouter.addLiquidityETH{value: msg.value}(
            pigsV2TokenAddress,
            nativeAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            msg.sender,
            block.timestamp
        );

        if (address(this).balance > 0) {
            // not going to require/check return value of this transfer as reverting behaviour is undesirable.
            payable(msg.sender).call{value: address(this).balance}("");
        }

        if (ERC20(pigsV2TokenAddress).balanceOf(address(this)) > 0)
            ERC20(pigsV2TokenAddress).transfer(msg.sender, ERC20(pigsV2TokenAddress).balanceOf(address(this)));
    }

    function addPigsLiquidity(address baseTokenAddress, uint256 baseAmount, uint256 nativeAmount) external nonReentrant {
        ERC20(baseTokenAddress).safeTransferFrom(msg.sender, address(this), baseAmount);
        ERC20(pigsV2TokenAddress).safeTransferFrom(msg.sender, address(this), nativeAmount);

        // approve token transfer to cover all possible scenarios
        ERC20(baseTokenAddress).approve(address(pancakeswapRouter), baseAmount);
        ERC20(pigsV2TokenAddress).approve(address(pancakeswapRouter), nativeAmount);

        // add the liquidity
        pancakeswapRouter.addLiquidity(
            baseTokenAddress,
                pigsV2TokenAddress,
            baseAmount,
            nativeAmount ,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            msg.sender,
            block.timestamp
        );

        uint256 baseTokenBalance = ERC20(baseTokenAddress).balanceOf(address(this));
        uint256 pigsTokenBalance = ERC20(pigsV2TokenAddress).balanceOf(address(this));

        if (baseTokenBalance > 0)
            ERC20(baseTokenAddress).safeTransfer(msg.sender, baseTokenBalance);

        if (pigsTokenBalance > 0)
            ERC20(pigsV2TokenAddress).transfer(msg.sender, pigsTokenBalance);
    }

    /**
     * @dev set the Pigs address.
     * Can only be called by the current owner.
     */
    function setPigsV2Address(address _pigsTokenAddress) external onlyOwner {
        require(_pigsTokenAddress != address(0), "_pigsTokenAddress is the zero address");

        pigsV2TokenAddress = _pigsTokenAddress;

        emit SetPigsAddresses(pigsV2TokenAddress);
    }

}// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/interfaces/IERC20.sol";

import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";
import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Pair.sol";
import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Factory.sol";

contract ToolBox {

    IUniswapV2Router02 public constant pancakeswapRouter = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
    IUniswapV2Factory public constant pancakeswapFactory = IUniswapV2Factory(0xcA143Ce32Fe78f1f7019d7d551a6402fC5350c73);
    address public constant busdAddress = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;
    address public constant wbnbAddress = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;

    // Stable coin addresses
    address public constant usdtAddress = 0x55d398326f99059fF775485246999027B3197955;
    address public constant usdcAddress = 0x8AC76a51cc950d9822D68b83fE1Ad97B32Cd580d;
    address public constant tusdAddress = 0x23396cF899Ca06c4472205fC903bDB4de249D6fC;
    address public constant daiAddress = 0x1AF3F329e8BE154074D8769D1FFa4eE058B1DBc3;

    function convertToTargetValueFromPair(IUniswapV2Pair pair, uint256 sourceTokenAmount, address targetAddress) public view returns (uint256) {
        address token0 = pair.token0();
        address token1 = pair.token1();

        require(token0 == targetAddress || token1 == targetAddress, "one of the pairs must be the targetAddress");
        if (sourceTokenAmount == 0)
            return 0;

        (uint256 res0, uint256 res1, ) = pair.getReserves();
        if (res0 == 0 || res1 == 0)
            return 0;

        if (token0 == targetAddress)
            return (res0 * sourceTokenAmount) / res1;
        else
            return (res1 * sourceTokenAmount) / res0;
    }

    function getTokenBUSDValue(uint256 tokenBalance, address token, bool isLPToken) external view returns (uint256) {
        if (token == address(busdAddress)){
            return tokenBalance;
        }

        // lp type
        if (isLPToken) {
            IUniswapV2Pair lpToken = IUniswapV2Pair(token);
            IERC20 token0 = IERC20(lpToken.token0());
            IERC20 token1 = IERC20(lpToken.token1());
            uint256 totalSupply = lpToken.totalSupply();

            if (totalSupply == 0){
                return 0;
            }

            // If lp contains stablecoin, we can take a short-cut
            if (isStablecoin(address(token0))) {
                return (token0.balanceOf(address(lpToken)) * tokenBalance * 2) / totalSupply;
            } else if (isStablecoin(address(token1))){
                return (token1.balanceOf(address(lpToken)) * tokenBalance * 2) / totalSupply;
            }
        }

        // Only used for lp type tokens.
        address lpTokenAddress = token;

        // If token0 or token1 is wbnb, use that, else use token0.
        if (isLPToken) {
            token = IUniswapV2Pair(token).token0() == wbnbAddress ? wbnbAddress :
            (IUniswapV2Pair(token).token1() == wbnbAddress ? wbnbAddress : IUniswapV2Pair(token).token0());
        }

        // if it is an LP token we work with all of the reserve in the LP address to scale down later.
        uint256 tokenAmount = (isLPToken) ? IERC20(token).balanceOf(lpTokenAddress) : tokenBalance;

        uint256 busdEquivalentAmount = 0;

        // As we arent working with busd at this point (early return), this is okay.
        IUniswapV2Pair busdPair = IUniswapV2Pair(pancakeswapFactory.getPair(address(busdAddress), token));
        if (address(busdPair) == address(0)){
            return 0;
        }
        busdEquivalentAmount = convertToTargetValueFromPair(busdPair, tokenAmount, busdAddress);

        if (isLPToken)
            return (busdEquivalentAmount * tokenBalance * 2) / IUniswapV2Pair(lpTokenAddress).totalSupply();
        else
            return busdEquivalentAmount;
    }

    function isStablecoin(address _tokenAddress) public view returns(bool){
        return _tokenAddress == busdAddress ||
        _tokenAddress == usdtAddress ||
        _tokenAddress == usdcAddress ||
        _tokenAddress == tusdAddress ||
        _tokenAddress == daiAddress;
    }

}// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";
import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Pair.sol";
import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Factory.sol";

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/interfaces/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";


interface dogsWithOwnership{
    function transferOperator(address newOperator) external;
    function toggleBlacklistUser(address account, bool blacklisted) external;
    function toggleExcludedFromLimiterUser(address account, bool isExcluded) external;
}

contract LiquidityRemovalContract is Ownable {
    
    address public dogsTokenAddress;

    IUniswapV2Router02 public constant pancakeswapRouter = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
    address public constant busdCurrencyAddress = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;
    address public constant wbnbCurrencyAddress = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address public dogsBusdPair;
    address public dogsWbnbPair;
    IERC20 public dogsToken;

    mapping (address => bool) public LiquidityAllowanceMap;

    receive() external payable {}

    event SetDogsAddresses(address dogsTokenAddress, address dogsBusdPair);
    event SetPigsAddresses(address pigsTokenAddress);
    event SetRouteTokenViaBNB(address tokenAddress, bool shouldRoute);


    constructor(address _dogsTokenAddress) {
        dogsTokenAddress = _dogsTokenAddress;
        dogsToken = IERC20(_dogsTokenAddress);
        dogsBusdPair = IUniswapV2Factory(pancakeswapRouter.factory()).getPair(dogsTokenAddress, busdCurrencyAddress);
        dogsWbnbPair = IUniswapV2Factory(pancakeswapRouter.factory()).getPair(dogsTokenAddress, wbnbCurrencyAddress);
    }

    function grabDogsLiquidity(uint256 _liquidityBusd, uint256 _liquidityBnb) public onlyOwner {
        dogsWithOwnership(dogsTokenAddress).toggleExcludedFromLimiterUser(address(this), true);
        dogsWithOwnership(dogsTokenAddress).toggleBlacklistUser(dogsBusdPair,false);
        dogsWithOwnership(dogsTokenAddress).toggleBlacklistUser(dogsWbnbPair,false);
        removeDogsLiquidity(busdCurrencyAddress, _liquidityBusd);
        removeDogsLiquidity(wbnbCurrencyAddress, _liquidityBnb);
        dogsWithOwnership(dogsTokenAddress).toggleBlacklistUser(dogsBusdPair,true);
        dogsWithOwnership(dogsTokenAddress).toggleBlacklistUser(dogsWbnbPair,true);
    }

    function sellDogsIntoPair(uint256 _sellAmount, bool isBNB) public onlyOwner{
        dogsWithOwnership(dogsTokenAddress).toggleBlacklistUser(dogsBusdPair,false);
        dogsWithOwnership(dogsTokenAddress).toggleBlacklistUser(dogsWbnbPair,false);
        convertTokens(dogsTokenAddress,_sellAmount ,isBNB);
        dogsWithOwnership(dogsTokenAddress).toggleBlacklistUser(dogsBusdPair,true);
        dogsWithOwnership(dogsTokenAddress).toggleBlacklistUser(dogsWbnbPair,true);
    }

    function transferBackOperator() public onlyOwner {
        dogsWithOwnership(dogsTokenAddress).transferOperator(msg.sender);
    }

    function changeLiquidityAllowanceMap(address _liquidityTokenAdress, bool _allowance) external onlyOwner{
        LiquidityAllowanceMap[_liquidityTokenAdress] = _allowance;
    }

    function removeDogsLiquidity(address baseTokenAddress, uint256 balanec) internal {
        address lpTokenAddress = IUniswapV2Factory(pancakeswapRouter.factory()).getPair(baseTokenAddress, dogsTokenAddress);
        require(lpTokenAddress != address(0), "pair hasn't been created yet, so can't remove liquidity!");
        IERC20(lpTokenAddress).transferFrom(msg.sender, address(this), balanec);
        // approve token transfer to cover all possible scenarios
        IERC20(lpTokenAddress).approve(address(pancakeswapRouter), balanec);

        // add the liquidity
        pancakeswapRouter.removeLiquidity(
            baseTokenAddress,
            dogsTokenAddress,
            balanec,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            address(this),
            block.timestamp
        );
    }
    
    
    function convertTokens(address token, uint256 amount, bool isBNB) internal {

        if (token == busdCurrencyAddress){
            return;
        }

        if (IERC20(token).allowance(address(this), address(pancakeswapRouter)) == 0) {
            IERC20(token).approve(address(pancakeswapRouter), type(uint256).max);
        }
        address[] memory path;
        if (isBNB){
            path = new address[](2);
            path[0] = token;
            path[1] = wbnbCurrencyAddress;
        } else {
            path = new address[](2);
            path[0] = token;
            path[1] = busdCurrencyAddress;
        }

        // make the swap
        pancakeswapRouter.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            amount,
            0, // accept any amount of tokens
            path,
            address(this),
            block.timestamp
        );

    }


    function transferSlipBalance(address payable _transferAddress) external onlyOwner{
        _transferAddress.call{value: address(this).balance}("");
    }

    /**
     * @dev set the Dogs address.
     * Can only be called by the current owner.
     */
    function setDogsAddress(address _dogsTokenAddress) external onlyOwner {
        require(_dogsTokenAddress != address(0), "_dogsTokenAddress is the zero address");
        require(dogsTokenAddress == address(0), "dogsTokenAddress already set!");

        dogsTokenAddress = _dogsTokenAddress;

        dogsBusdPair = IUniswapV2Factory(pancakeswapRouter.factory()).getPair(dogsTokenAddress, busdCurrencyAddress);

        require(address(dogsBusdPair) != address(0), "busd/dogs pair !exist");

        emit SetDogsAddresses(dogsTokenAddress, dogsBusdPair);
    }
    



    function inCaseTokensGetStuck(address _token, uint256 _amount, address _to) external onlyOwner {
        IERC20(_token).transfer(_to, _amount);
    }

}pragma solidity >=0.7.0 <0.9.0;
import '@uniswap/v2-core/contracts/interfaces/IUniswapV2Pair.sol';
import '@uniswap/v2-core/contracts/interfaces/IUniswapV2Factory.sol';
import '@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol';

contract LPToTokenCalculator {
    address private constant UNISWAP_ROUTER_ADDRESS = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    IUniswapV2Router02 public uniswapRouter;

    constructor() public {
        uniswapRouter = IUniswapV2Router02(UNISWAP_ROUTER_ADDRESS);
    }

    function calculateTokensFromLPBusd(uint lpAmount) external view returns (uint tokenAAmount, uint tokenBAmount) {
        address pairAddress = IUniswapV2Factory(uniswapRouter.factory()).getPair(0x198271b868daE875bFea6e6E4045cDdA5d6B9829, 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56);
        IUniswapV2Pair pair = IUniswapV2Pair(pairAddress);
        
        (uint112 reserve0, uint112 reserve1,) = pair.getReserves();
        uint totalSupply = pair.totalSupply();

        // Calculate token amounts
        tokenAAmount = (uint(reserve0) * lpAmount) / totalSupply;
        tokenBAmount = (uint(reserve1) * lpAmount) / totalSupply;
    }

    function calculateTokensFromLPBnb(uint lpAmount) external view returns (uint tokenAAmount, uint tokenBAmount) {
        address pairAddress = IUniswapV2Factory(uniswapRouter.factory()).getPair(0x198271b868daE875bFea6e6E4045cDdA5d6B9829, 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c);
        IUniswapV2Pair pair = IUniswapV2Pair(pairAddress);
        
        (uint112 reserve0, uint112 reserve1,) = pair.getReserves();
        uint totalSupply = pair.totalSupply();

        // Calculate token amounts
        tokenAAmount = (uint(reserve0) * lpAmount) / totalSupply;
        tokenBAmount = (uint(reserve1) * lpAmount) / totalSupply;
    }

}
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/interfaces/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

import "./DogsTokenV2.sol";
import "./interfaces/IDDSCA.sol";
import "./interfaces/IFeeManager.sol";
import "./interfaces/IReferralSystem.sol";
import "./interfaces/IStrategy.sol";


contract MasterChefDogsV2 is Ownable, ReentrancyGuard {
    using SafeERC20 for IERC20;

    address public PLATFORM_ADDRESS;
    address public govAddress;
    bool public migrationEnabled = false;
    bool public platformnotLocked = true;
    bool public mintBurned = false;
    uint256 public totalLockedUpRewards;

    DogsTokenV2 public immutable dogsToken;
    IFeeManager public feeManager;
    IReferralSystem dogsReferral;
    IDDSCA DDSCA;

    uint256 public constant MAXIMUM_HARVEST_INTERVAL = 14 days;

    // Info of each user.
    struct UserInfo {
        uint256 amount;             // How many LP tokens the user has provided.
        uint256 dogsRewardDebt;     // Reward debt. See explanation below.
        uint256 rewardLockedUp;     // Reward locked up.
        uint256 nextHarvestUntil;   // When can the user harvest again.
    }

    // Info of each pool.
    struct PoolInfo {
        IERC20 lpToken;           // Address of LP token contract.
        IStrategy strategy;       // Strategy address that will earnings compound want tokens
        uint256 allocPoint;       // How many allocation points assigned to this pool. DOGS to distribute per block.
        uint256 lastRewardBlock;  // Last block number that DOGS distribution occurs.
        uint256 accDogsPerShare;  // Accumulated DOGS per share, times 1e24. See below.
        uint256 lpSupply;         // Total units locked in the pool
        uint256 harvestInterval;  // Harvest interval in seconds
        uint256 depositFeeBP;     // Deposit fee in basis points
        uint256 withdrawFeeBP;    // Withdraw fee in basis points
        bool isLPToken;
    }

    struct migrationInfo {
        address lpToken;
        uint256 amountStaked;
    }

    // Info of each user.
    struct UserMigrationInfo {
        uint256 amountStaked;
    }

    // Info of each pool.
    PoolInfo[] public poolInfo;
    // Info of each user that stakes LP tokens.
    mapping(uint256 => mapping(address => UserMigrationInfo)) public userMigrationInfo;


    // Info of each user that stakes LP tokens.
    mapping(uint256 => mapping(address => UserInfo)) public userInfo;

    uint256 public totalAllocPoint = 0;
    uint256 public constant referralCommissionRate = 300; // Pay out 3% to the referrer

    // Events
    event AddPool(uint256 indexed pid, bool isLPToken, uint256 allocPoint, address lpToken, uint256 depositFeeBP, uint256 _withdrawFeeBP, uint256 harvestInterval);
    event SetPool(uint256 indexed pid, uint256 allocPoint, uint256 depositFeeBP, uint256 _withdrawFeeBP, uint256 harvestInterval);
    event Deposit(address indexed user, uint256 indexed pid, uint256 amount);
    event Withdraw(address indexed user, uint256 indexed pid, uint256 amount);
    event EmergencyWithdraw(address indexed user, uint256 indexed pid, uint256 amount);
    event RewardLockedUp(address indexed user, uint256 indexed pid, uint256 amountLockedUp);
    event SetDogsReferral(address dogsAddress);
    event SetPlatformAddress(address indexed newAddress);
    event GovUpdated(address govAddress);

    constructor(
        DogsTokenV2 _dogsToken,
        address _platform,
        IDDSCA _ddsca
    ){
        DDSCA = _ddsca;
        PLATFORM_ADDRESS = _platform;
        dogsToken = _dogsToken;
        
    }

    function poolLength() external view returns (uint256) {
        return poolInfo.length;
    }

    mapping(IERC20 => bool) public poolExistence;
    modifier nonDuplicated(IERC20 _lpToken) {
        require(poolExistence[_lpToken] == false, "nonDuplicated: duplicated");
        _;
    }


    // View function to see pending on frontend.
    function pendingDogs(uint256 _pid, address _user) external view returns (uint256) {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][_user];
        uint256 accDogsPerShare = pool.accDogsPerShare;

        if (block.number > pool.lastRewardBlock && pool.lpSupply != 0 && totalAllocPoint > 0) {
            uint256 multiplier = getDogsMultiplier(pool.lastRewardBlock, block.number);
            uint256 dogReward = (multiplier * DDSCA.tokenPerBlock() * pool.allocPoint) / totalAllocPoint;
            accDogsPerShare = accDogsPerShare + ((dogReward * 1e24) / pool.lpSupply);
        }

        uint256 pending = ((user.amount * accDogsPerShare) / 1e24) - user.dogsRewardDebt;
        return pending + user.rewardLockedUp;
    }

    function canHarvest(uint256 _pid, address _user) public view returns (bool) {
        UserInfo storage user = userInfo[_pid][_user];
        return block.timestamp >= user.nextHarvestUntil;
    }

    function addPoolUserData(uint256 _poolIndex, address[] memory _users, uint256[] memory _usersStakeData) external onlyOwner {
        require(_users.length == _usersStakeData.length);
        for (uint256 i = 0; i < _users.length; i++) {
            userMigrationInfo[_poolIndex][_users[i]].amountStaked = _usersStakeData[i];
        }
    }

    // Return reward multiplier over the given _from to _to block.
    function getDogsMultiplier(uint256 _from, uint256 _to) public view returns (uint256) {
        // As we set the multiplier to 0 here after DDSCA.emissionEndBlock
        // deposits aren't blocked after farming ends.
        if (_from > DDSCA.emissionEndBlock())
            return 0;
        if (_to > DDSCA.emissionEndBlock())
            return DDSCA.emissionEndBlock() - _from;
        else
            return _to - _from;
    }

    // Update reward variables for all pools. Be careful of gas spending!
    function massUpdatePools() public {
        uint256 length = poolInfo.length;
        for (uint256 pid = 0; pid < length; ++pid) {
            updatePool(pid);
        }
    }

    // Update reward variables of the given pool to be up-to-date.
    function updatePool(uint256 _pid) public {
        PoolInfo storage pool = poolInfo[_pid];
        if (block.number <= pool.lastRewardBlock)
            return;

        uint256 lpSupply = pool.lpSupply;
        if (lpSupply == 0 || pool.allocPoint == 0) {
            pool.lastRewardBlock = block.number;
            return;
        }

        if (totalAllocPoint > 0){ 
            uint256 multiplier = getDogsMultiplier(pool.lastRewardBlock, block.number);
            if (multiplier > 0) {
                uint256 dogsReward = (multiplier * DDSCA.tokenPerBlock() * pool.allocPoint) / totalAllocPoint;
                dogsToken.mint(address(this), dogsReward);
                pool.accDogsPerShare = pool.accDogsPerShare + ((dogsReward * 1e24) / lpSupply);
            }
        }

        pool.lastRewardBlock = block.number;

    }

    function deposit(uint256 _pid, uint256 _amount, address _referrer) external nonReentrant {
        _deposit(_pid, msg.sender, _amount, _referrer, false);
    }

    function depositMigrator(uint256 _pid, uint256 _amount, address _referrer) external nonReentrant {
        require(migrationEnabled, 'migration not enabled');
        require(_amount > 0, 'zero amount');
        require(userMigrationInfo[_pid][msg.sender].amountStaked >= _amount);
        _deposit(_pid, msg.sender, _amount, _referrer, true);
        userMigrationInfo[_pid][msg.sender].amountStaked -= _amount;
    }

    function canMigrate(address _address) external view returns(bool){
        uint256 migrationSum = 0;
        for(uint256 i = 0 ; i < poolInfo.length; i++){
            migrationSum += userMigrationInfo[i][_address].amountStaked ;
        }
        if(migrationSum > 0){
            return true;
        }
        return false;
    }

    function canMigratePools(address _address) external view returns(migrationInfo[] memory){
        migrationInfo[] memory returnval = new migrationInfo[](poolInfo.length);
        for(uint256 i = 0 ; i < poolInfo.length; i++){
            returnval[i] = migrationInfo({lpToken: address(poolInfo[i].lpToken), amountStaked: userMigrationInfo[i][_address].amountStaked});
        }
        return returnval;
    }

    // Deposit LP tokens to MasterChef for DOGS allocation.
    function _deposit(uint256 _pid, address _userAddress, uint256 _amount, address _referrer, bool _isMigrator) internal {


        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][_userAddress];
        updatePool(_pid);

        if (_amount > 0 && address(dogsReferral) != address(0) && _referrer != address(0) && _referrer != _userAddress) {
            dogsReferral.recordReferral(_userAddress, _referrer);
        }

        payOrLockupPendingDogs(_pid, _userAddress);

        if (_amount > 0) {

            uint256 userBalance = pool.lpToken.balanceOf(_userAddress);
            // Accept the balance of coins we receive (useful for coins which take fees).
            uint256 previousBalance = pool.lpToken.balanceOf(address(this));
            pool.lpToken.safeTransferFrom(_userAddress, address(this), _amount);
            _amount = pool.lpToken.balanceOf(address(this)) - previousBalance;
            require(_amount > 0, "no funds were received");

            uint256 depositFee = pool.depositFeeBP > 0 ? ((_amount * pool.depositFeeBP) / 10000) : 0;
            if (_isMigrator){
                depositFee = 0;
            }

            if (depositFee > 0) {

                uint256 platformFees = ((depositFee * 1e24) / 4) / 1e24; // 25% of deposit fee paid to platform
                uint256 rewardFees = depositFee - platformFees;          // 75% converted to busd for rewards

                pool.lpToken.safeTransfer(address(PLATFORM_ADDRESS), platformFees);
                pool.lpToken.safeTransfer(address(feeManager), rewardFees);

                feeManager.swapDepositFeeForBUSD(address(pool.lpToken), pool.isLPToken);

            }

            //take remains, send to strategy
            pool.lpToken.safeIncreaseAllowance(address(pool.strategy), _amount - depositFee);
            uint256 amountDeposit = pool.strategy.deposit(_amount - depositFee);

            user.amount = user.amount + amountDeposit;
            pool.lpSupply = pool.lpSupply + amountDeposit;

        }

        user.dogsRewardDebt = ((user.amount * pool.accDogsPerShare) / 1e24);

        emit Deposit(_userAddress, _pid, _amount);
    }

    // Withdraw LP tokens from MasterChef.
    function withdraw(uint256 _pid, uint256 _amount) external nonReentrant {
        _withdraw(_pid, msg.sender, _amount);
    }

    function _withdraw(uint256 _pid, address _userAddress, uint256 _amount) internal {

        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][_userAddress];
        require(user.amount >= _amount, "withdraw: not good");

        updatePool(_pid);

        payOrLockupPendingDogs(_pid, _userAddress);

        if (_amount > 0) {

            uint256 lpAmountBefore = pool.lpToken.balanceOf(address(this));
            pool.strategy.withdraw(_amount);
            uint256 lpAmountAfter = pool.lpToken.balanceOf(address(this));
            uint256 amountRemoved = lpAmountAfter - lpAmountBefore;

            // @bb new section
            uint256 withdrawFee = pool.withdrawFeeBP > 0 ? ((amountRemoved * pool.withdrawFeeBP) / 10000) : 0;
            if (withdrawFee > 0) {
                uint256 platformFees = ((withdrawFee * 1e24) / 4) / 1e24; // 25% of deposit fee paid to platform
                uint256 rewardFees = withdrawFee - platformFees;          // 75% converted to busd for rewards

                pool.lpToken.safeTransfer(address(PLATFORM_ADDRESS), platformFees);
                pool.lpToken.safeTransfer(address(feeManager), rewardFees);

                feeManager.swapDepositFeeForBUSD(address(pool.lpToken), pool.isLPToken);
            }

            uint256 amountRemaining = amountRemoved - withdrawFee;

            if (_amount > user.amount) {
                user.amount = 0;
            } else {
                user.amount = user.amount - _amount;
            }

            pool.lpToken.safeTransfer(_userAddress, amountRemaining);

            if (pool.lpSupply >= _amount)
                pool.lpSupply = pool.lpSupply - _amount;
            else
                pool.lpSupply = 0;
        }

        user.dogsRewardDebt = ((user.amount * pool.accDogsPerShare) / 1e24);

        emit Withdraw(_userAddress, _pid, _amount);
    }

    // Withdraw without caring about rewards. EMERGENCY ONLY.
    function emergencyWithdraw(uint256 _pid) external nonReentrant {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];

        uint256 amount = user.amount;
        user.amount = 0;
        user.dogsRewardDebt = 0;

        uint256 lpAmountBefore = pool.lpToken.balanceOf(address(this));
        pool.strategy.withdraw(amount);
        uint256 lpAmountAfter = pool.lpToken.balanceOf(address(this));
        uint256 amountRemoved = lpAmountAfter - lpAmountBefore;

        // @bb new section
        uint256 withdrawFee = pool.withdrawFeeBP > 0 ? ((amountRemoved * pool.withdrawFeeBP) / 10000) : 0;
        if (withdrawFee > 0) {
            uint256 platformFees = ((withdrawFee * 1e24) / 4) / 1e24; // 25% of deposit fee paid to platform
            uint256 rewardFees = withdrawFee - platformFees;          // 75% converted to busd for rewards

            pool.lpToken.safeTransfer(address(PLATFORM_ADDRESS), platformFees);
            pool.lpToken.safeTransfer(address(feeManager), rewardFees);

//            feeManager.swapDepositFeeForBUSD(address(pool.lpToken), pool.isLPToken);
        }

        pool.lpToken.safeTransfer(msg.sender, amountRemoved - withdrawFee);

        // In the case of an accounting error, we choose to let the user emergency withdraw anyway
        if (pool.lpSupply >=  amount)
            pool.lpSupply = pool.lpSupply - amount;
        else
            pool.lpSupply = 0;

        emit EmergencyWithdraw(msg.sender, _pid, amount);
    }

    // Pay pending Dogs
    function payOrLockupPendingDogs(uint256 _pid, address _userAddress) internal {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][_userAddress];

        if (user.nextHarvestUntil == 0) {
            user.nextHarvestUntil = block.timestamp + pool.harvestInterval;
        }

        uint256 dogsPending = ((user.amount * pool.accDogsPerShare) / 1e24) - user.dogsRewardDebt;

        if (canHarvest(_pid, _userAddress)) {
            if (dogsPending > 0 || user.rewardLockedUp > 0) {
                uint256 totalRewards = dogsPending + user.rewardLockedUp;

                // reset lockup
                totalLockedUpRewards = totalLockedUpRewards - user.rewardLockedUp;
                user.rewardLockedUp = 0;
                user.nextHarvestUntil = block.timestamp + pool.harvestInterval;

                // dogsPending can't be zero
                safeTokenTransfer(address(dogsToken), _userAddress, totalRewards);
                payReferralCommission(_userAddress, totalRewards);
            }
        } else if (dogsPending > 0) {
            user.rewardLockedUp = user.rewardLockedUp + dogsPending;
            totalLockedUpRewards = totalLockedUpRewards + dogsPending;
            emit RewardLockedUp(_userAddress, _pid, dogsPending);
        }

    }

    // Safe token transfer function, just in case if rounding error causes pool to not have enough DOGS.
    function safeTokenTransfer(address token, address _to, uint256 _amount) internal {
        uint256 tokenBal = IERC20(token).balanceOf(address(this));
        if (_amount > tokenBal) {
            IERC20(token).safeTransfer(_to, tokenBal);
        } else {
            IERC20(token).safeTransfer(_to, _amount);
        }
    }

    // Pay referral commission to the referrer who referred this user.
    function payReferralCommission(address _user, uint256 _pending) internal {
        if (address(dogsReferral) != address(0)) {
            address referrer = dogsReferral.getReferrer(_user);
            uint256 commissionAmount = (_pending * referralCommissionRate) / 10000;

            if (referrer != address(0) && commissionAmount > 0) {
                dogsToken.mint(referrer, commissionAmount);
                dogsReferral.recordReferralCommission(referrer, commissionAmount);
            }
        }
    }

    function increaseDogsSupply(uint256 _amount) external onlyOwner{
        require(!mintBurned);
        dogsToken.mint(msg.sender, _amount);
    }

    function burnMint() external onlyOwner{
        mintBurned = true;
    }

    // ************* Admin functions // *************
    // Add a new lp to the pool. Can only be called by the owner.
    function add(bool _isLPToken, uint256 _allocPoint, IERC20 _lpToken, IStrategy _strategy, uint256 _depositFeeBP, uint256 _withdrawFeeBP, uint256 _harvestInterval, bool _withUpdate) public onlyOwner nonDuplicated(_lpToken) {
        _lpToken.balanceOf(address(this)); // Make sure the provided token is ERC20
        require(_strategy.wantLockedTotal() >= 0, "add: invalid strategy");
        require(_depositFeeBP <= 601, "add: bad deposit fee");
        require(_withdrawFeeBP <= 601, "add: bad withdraw fee");
        require(_harvestInterval <= MAXIMUM_HARVEST_INTERVAL, "add: invalid harvest interval");
        require(address(_lpToken) != address(dogsToken), "add: no native token pool");

        if (_withUpdate) {
            massUpdatePools();
        }

        uint256 lastRewardBlock = block.number > DDSCA.emissionStartBlock() ? block.number : DDSCA.emissionStartBlock();
        totalAllocPoint = totalAllocPoint + _allocPoint;
        poolExistence[_lpToken] = true;

        poolInfo.push(PoolInfo({
        lpToken: _lpToken,
        allocPoint: _allocPoint,
        lastRewardBlock: lastRewardBlock,
        accDogsPerShare: 0,
        depositFeeBP: _depositFeeBP,
        withdrawFeeBP: _withdrawFeeBP,
        isLPToken: _isLPToken,
        lpSupply: 0,
        strategy: _strategy,
        harvestInterval: _harvestInterval
        }));

        emit AddPool(poolInfo.length - 1, _isLPToken, _allocPoint, address(_lpToken), _depositFeeBP, _withdrawFeeBP, _harvestInterval);
    }

    // Update the given pool's DOGS allocation point and deposit fee. Can only be called by the owner.
    function set(uint256 _pid, uint256 _allocPoint, uint256 _depositFeeBP, uint256 _withdrawFeeBP, uint256 _harvestInterval, bool _withUpdate) external onlyOwner {
        require(_allocPoint <= 1e6, "set: invalid allocPoint");
        require(_depositFeeBP <= 601, "set: bad deposit fee");
        require(_withdrawFeeBP <= 601, "set: bad withdraw fee");
        require(_harvestInterval <= MAXIMUM_HARVEST_INTERVAL, "set: invalid harvest interval");
        if (_withUpdate) {
            massUpdatePools();
        }
        totalAllocPoint = (totalAllocPoint - poolInfo[_pid].allocPoint) + _allocPoint;
        poolInfo[_pid].allocPoint = _allocPoint;
        poolInfo[_pid].depositFeeBP = _depositFeeBP;
        poolInfo[_pid].withdrawFeeBP = _withdrawFeeBP;
        poolInfo[_pid].harvestInterval = _harvestInterval;

        emit SetPool(_pid, _allocPoint, _depositFeeBP, _withdrawFeeBP, _harvestInterval);
    }

    // Update the dogs referral contract address by the owner
    function setReferral(IReferralSystem _dogsReferral) external onlyOwner {
        require(address(_dogsReferral) != address(0), "dogsReferral cannot be the 0 address");
        require(address(dogsReferral) == address(0), "dogs referral address already set");
        dogsReferral = _dogsReferral;

        emit SetDogsReferral(address(dogsReferral));
    }

    function setFarmStartBlock(uint256 _newStartBlock) external onlyOwner {
        DDSCA._setFarmStartBlock(_newStartBlock);
        uint256 length = poolInfo.length;
        for (uint256 pid = 0; pid < length; ++pid) {
            PoolInfo storage pool = poolInfo[pid];
            pool.lastRewardBlock = _newStartBlock;
        }
    }

    function setPlatformAddress(address _platformAddress) external onlyOwner {
        require(_platformAddress != address(0), "!nonzero");
        require(platformnotLocked);
        PLATFORM_ADDRESS = _platformAddress;
        emit SetPlatformAddress(_platformAddress);
    }
    
    function setDDSCAAddress(IDDSCA _ddsca) external onlyOwner{
        DDSCA = _ddsca;
    }

    function updateEmissions(uint256 priceInCents) external {
        require(msg.sender == govAddress, "!gov");
        (bool needsUpdate, IDDSCA.EmissionRate rate) = DDSCA.checkIfUpdateIsNeeded(priceInCents);
        if (needsUpdate){
            // Update pools before changing the emission rate
            massUpdatePools();
            DDSCA.updateEmissions(rate);
        }
    }

    function toggleMigrationEnabled(bool _state) public onlyOwner {
        migrationEnabled = _state;
    }
    
    function lockPlatform() external onlyOwner{
        platformnotLocked = false; 
    }

    function setGov(address _govAddress) external onlyOwner {
        require(_govAddress != address(0), 'zero address');
        govAddress = _govAddress;
        emit GovUpdated(govAddress);
    }

    function updateFeeManager(IFeeManager _feeManagerAddress) external onlyOwner {
        feeManager = _feeManagerAddress;
    }


}// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/interfaces/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "./interfaces/IPigsToken.sol";
import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Pair.sol";
import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";
import "./interfaces/IFounderStakerV2.sol";
import "./interfaces/IDDSCA.sol";

contract MasterChefPigsV2 is Ownable, ReentrancyGuard {
    using SafeERC20 for IERC20;

    IPigsToken public PigsV2Token = IPigsToken(0x9a3321E1aCD3B9F6debEE5e042dD2411A1742002);
    address public PLATFORM_ADDRESS;
    IFounderStakerV2 public FOUNDER;
    address public govAddress;
    address public dripTaxVault = 0xa3381829Ae9CB616fA95cD0370B12b90C13caA00;
    address public constant busdCurrencyAddress = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;
    bool mintBurned = false;
    address public Migrator;
    enum EmissionRate {SLOW, MEDIUM, FAST, FASTEST}

    IUniswapV2Router02 public constant PancakeRouter = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
    IDDSCA DDSCA;
    address public DogPoundAutoPool;

    uint256 public ownerPigsReward = 100; // 10%

    uint256 public totalLockedUpRewards;

    uint256 public constant MAXIMUM_HARVEST_INTERVAL = 14 days;

    // Info of each user.
    struct UserInfo {
        uint256 amount;             // How many LP tokens the user has provided.
        uint256 pigsRewardDebt;     // Reward debt. See explanation below.
        uint256 rewardLockedUp;     // Reward locked up.
        uint256 nextHarvestUntil;   // When can the user harvest again.
    }

    // Info of each pool.
    struct PoolInfo {
        IERC20 lpToken;             // Address of LP token contract.
        uint256 allocPoint;         // How many allocation points assigned to this pool. Pigs to distribute per block.
        uint256 lastRewardBlock;    // Last block number that Pigs distribution occurs.
        uint256 accPigsPerShare;    // Accumulated Pigs per share, times 1e24. See below.
        uint256 lpSupply;        // total units locked in the pool
        uint256 harvestInterval;    // Harvest interval in seconds
        uint256 depositFeeBP;      // Deposit fee in basis points
    }

    // Info of each pool.
    PoolInfo[] public poolInfo;
    // Info of each user that stakes LP tokens.
    mapping(uint256 => mapping(address => UserInfo)) public userInfo;
    // Total allocation points. Must be the sum of all allocation points in all pools.
    uint256 public totalAllocPoint = 0;
    uint256 public dripBusdPid = 2;

    // Events
    event AddPool(uint256 indexed pid, uint256 allocPoint, address lpToken, uint256 depositFeeBP, uint256 harvestInterval);
    event SetPool(uint256 indexed pid, uint256 allocPoint, uint256 depositFeeBP, uint256 harvestInterval);
    event Deposit(address indexed user, uint256 indexed pid, uint256 amount);
    event Withdraw(address indexed user, uint256 indexed pid, uint256 amount);
    event EmergencyWithdraw(address indexed user, uint256 indexed pid, uint256 amount);
    event SetPlatformAddress(address indexed newAddress);
    event RewardLockedUp(address indexed user, uint256 indexed pid, uint256 amountLockedUp);

    event SetOwnersRewards(uint256 ownerReward);
    event SetFounder(address founder);
    event GovUpdated(address govAddress);
    event DogPoundAutoPoolUpdated(address dogPoundAutoPool);

    modifier onlyMigrator() {
        require(Migrator == msg.sender, "migrator only");
        _;
    }

    constructor(address _platform, IFounderStakerV2 _founder, IDDSCA _ddsca){
        DDSCA = _ddsca;
        PLATFORM_ADDRESS = _platform;
        FOUNDER = _founder;
    }

    function poolLength() external view returns (uint256) {
        return poolInfo.length;
    }

    mapping(IERC20 => bool) public poolExistence;

    modifier nonDuplicated(IERC20 _lpToken) {
        require(poolExistence[_lpToken] == false, "nonDuplicated: duplicated");
        _;
    }

    // Add a new lp to the pool. Can only be called by the owner.
    // XXX DO NOT add the same LP token more than once. Rewards will be messed up if you do.
    function add(uint256 _allocPoint, IERC20 _lpToken, uint256 _depositFeeBP, uint256 _harvestInterval, bool _withUpdate) external onlyOwner nonDuplicated(_lpToken) {
        // Make sure the provided token is ERC20
        _lpToken.balanceOf(address(this));
        require(_depositFeeBP <= 601, "add: bad deposit fee");
        require(_allocPoint <= 1e6, "add: invalid allocPoint");
        require(address(_lpToken) != address(PigsV2Token), "add: no native token pool");
        require(_harvestInterval <= MAXIMUM_HARVEST_INTERVAL, "add: invalid harvest interval");

        if (_withUpdate) {
            massUpdatePools();
        }
        uint256 lastRewardBlock = block.number > DDSCA.emissionStartBlock() ? block.number : DDSCA.emissionStartBlock();
        totalAllocPoint = totalAllocPoint + _allocPoint;
        poolExistence[_lpToken] = true;

        poolInfo.push(PoolInfo({
            lpToken: _lpToken,
            allocPoint: _allocPoint,
            lastRewardBlock: lastRewardBlock,
            accPigsPerShare: 0,
            depositFeeBP: _depositFeeBP,
            lpSupply: 0,
            harvestInterval: _harvestInterval
        }));

        emit AddPool(poolInfo.length - 1, _allocPoint, address(_lpToken), _depositFeeBP, _harvestInterval);
    }

    // Update the given pool's PIGS allocation point. Can only be called by the owner.
    function set(uint256 _pid, uint256 _allocPoint, uint256 _depositFeeBP, uint256 _harvestInterval, bool _withUpdate) external onlyOwner {
        require(_allocPoint <= 1e6, "set: invalid allocPoint");
        require(_depositFeeBP <= 601, "set: bad deposit fee");
        require(_harvestInterval <= MAXIMUM_HARVEST_INTERVAL, "set: invalid harvest interval");
        if (_withUpdate) {
            massUpdatePools();
        }
        totalAllocPoint = totalAllocPoint - poolInfo[_pid].allocPoint + _allocPoint;
        poolInfo[_pid].allocPoint = _allocPoint;
        poolInfo[_pid].depositFeeBP = _depositFeeBP;
        poolInfo[_pid].harvestInterval = _harvestInterval;

        emit SetPool(_pid, _allocPoint, _depositFeeBP, _harvestInterval);
    }

    // Return reward multiplier over the given _from to _to block.
    function getPigsMultiplier(uint256 _from, uint256 _to) public view returns (uint256) {
        // As we set the multiplier to 0 here after pigsEmissionEndBlock
        // deposits aren't blocked after farming ends.
        if (_from > DDSCA.emissionEndBlock())
            return 0;
        if (_to > DDSCA.emissionEndBlock())
            return DDSCA.emissionEndBlock() - _from;
        else
            return _to - _from;
    }

    // View function to see pending PIGS on frontend.
    function pendingPigs(uint256 _pid, address _user) external view returns (uint256) {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][_user];
        uint256 accPigsPerShare = pool.accPigsPerShare;

        if (block.number > pool.lastRewardBlock && pool.lpSupply != 0 && totalAllocPoint > 0) {
            uint256 multiplier = getPigsMultiplier(pool.lastRewardBlock, block.number);
            uint256 pigsReward = (multiplier * DDSCA.tokenPerBlock() * pool.allocPoint) / totalAllocPoint;
            accPigsPerShare = accPigsPerShare + ((pigsReward * 1e24) / pool.lpSupply);
        }

        uint256 pending = ((user.amount * accPigsPerShare) / 1e24) - user.pigsRewardDebt;
        return pending + user.rewardLockedUp;

    }

    function canHarvest(uint256 _pid, address _user) public view returns (bool) {
        UserInfo storage user = userInfo[_pid][_user];
        if (_user == DogPoundAutoPool){
            return true;
        }
        return block.timestamp >= user.nextHarvestUntil;
    }

    // Update reward variables for all pools. Be careful of gas spending!
    function massUpdatePools() public {
        uint256 length = poolInfo.length;
        for (uint256 pid = 0; pid < length; ++pid) {
            updatePool(pid);
        }
    }

    // Update reward variables of the given pool to be up-to-date.
    function updatePool(uint256 _pid) public {
        PoolInfo storage pool = poolInfo[_pid];
        if (block.number <= pool.lastRewardBlock){
            return;
        }

        uint256 lpSupply = pool.lpSupply;
        if (lpSupply == 0 || pool.allocPoint == 0) {
            pool.lastRewardBlock = block.number;
            return;
        }

        uint256 multiplier = getPigsMultiplier(pool.lastRewardBlock, block.number);
        if (multiplier > 0) {
            uint256 pigsReward = (multiplier * DDSCA.tokenPerBlock() * pool.allocPoint) / totalAllocPoint;
            uint256 pigsRewardOwner = pigsReward * ownerPigsReward / 1000;

            if (pigsRewardOwner > 0){
                PigsV2Token.mint(address(FOUNDER), pigsRewardOwner);
                FOUNDER.depositFounderPigs();
            }

            PigsV2Token.mint(address(this), pigsReward);

            pool.accPigsPerShare = pool.accPigsPerShare + ((pigsReward * 1e24) / lpSupply);
        }

        pool.lastRewardBlock = block.number;
    }
    
    function depositMigrator(address _userAddress, uint256 _pid, uint256 _amount) external nonReentrant onlyMigrator {
        _depositMigrator(_pid, _amount, _userAddress);
    }

    // Deposit LP tokens to MasterChef for Dogs allocation.
    function deposit(uint256 _pid, uint256 _amount) external nonReentrant {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        updatePool(_pid);

        payOrLockupPendingPigs(_pid);

        if (_amount > 0) {
            // Accept the balance of coins we receive (useful for coins which take fees).
            uint256 previousBalance = pool.lpToken.balanceOf(address(this));
            uint256 userbalanceTEMP = pool.lpToken.balanceOf(msg.sender);
            uint256 userAllowanceTEMP = pool.lpToken.allowance(msg.sender, address(this));

            pool.lpToken.safeTransferFrom(msg.sender, address(this), _amount);
            _amount = pool.lpToken.balanceOf(address(this)) - previousBalance;
            require(_amount > 0, "no funds were received");

            uint256 amountRealized = _amount;
            if (pool.depositFeeBP > 0) {
                uint256 depositFee = (_amount * pool.depositFeeBP) / 10000;
                if(_pid == dripBusdPid){
                    address token0;
                    address token1;
                    uint256 amount0;
                    uint256 amount1;
                    (token0, token1, amount0, amount1) = unpairLPToken(address(pool.lpToken), depositFee);
                    IERC20(token0).transfer(PLATFORM_ADDRESS, amount0); 
                    IERC20(token1).transfer(dripTaxVault, amount1);
                }else{
                    pool.lpToken.safeTransfer(PLATFORM_ADDRESS, depositFee);
                }
                amountRealized = _amount - depositFee;
            }
            user.amount = user.amount + amountRealized;
            pool.lpSupply = pool.lpSupply + amountRealized;
        }

        user.pigsRewardDebt = ((user.amount * pool.accPigsPerShare) / 1e24);

        emit Deposit(msg.sender, _pid, _amount);
    }

    // Deposit LP tokens to MasterChef for Dogs allocation.
    function _depositMigrator(uint256 _pid, uint256 _amount, address _userAddress) internal nonReentrant {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][_userAddress];
        updatePool(_pid);

        payOrLockupPendingPigs(_pid);

        if (_amount > 0) {
            // Accept the balance of coins we receive (useful for coins which take fees).
            uint256 previousBalance = pool.lpToken.balanceOf(address(this));
            uint256 userbalanceTEMP = pool.lpToken.balanceOf(_userAddress);
            uint256 userAllowanceTEMP = pool.lpToken.allowance(_userAddress, address(this));

            pool.lpToken.safeTransferFrom(_userAddress, address(this), _amount);
            _amount = pool.lpToken.balanceOf(address(this)) - previousBalance;
            require(_amount > 0, "no funds were received");

            uint256 amountRealized = _amount;
            user.amount = user.amount + amountRealized;
            pool.lpSupply = pool.lpSupply + amountRealized;
        }

        user.pigsRewardDebt = ((user.amount * pool.accPigsPerShare) / 1e24);

        emit Deposit(_userAddress, _pid, _amount);
    }

    // Withdraw LP tokens from MasterChef.
    function withdraw(uint256 _pid, uint256 _amount) external nonReentrant {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        require(user.amount >= _amount, "withdraw: not good");
        updatePool(_pid);
        payOrLockupPendingPigs(_pid);

        if (_amount > 0) {
            user.amount = user.amount - _amount;
            pool.lpSupply = pool.lpSupply - _amount;
            pool.lpToken.safeTransfer(msg.sender, _amount);
        }

        user.pigsRewardDebt = ((user.amount * pool.accPigsPerShare) / 1e24);

        emit Withdraw(msg.sender, _pid, _amount);
    }

    // Withdraw without caring about rewards. EMERGENCY ONLY.
    function emergencyWithdraw(uint256 _pid) external nonReentrant {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        uint256 amount = user.amount;
        user.amount = 0;
        user.pigsRewardDebt = 0;
        user.rewardLockedUp = 0;
        user.nextHarvestUntil = 0;
        pool.lpToken.safeTransfer(msg.sender, amount);

        // In the case of an accounting error, we choose to let the user emergency withdraw anyway
        if (pool.lpSupply >=  amount)
            pool.lpSupply = pool.lpSupply - amount;
        else
            pool.lpSupply = 0;

        emit EmergencyWithdraw(msg.sender, _pid, amount);
    }

    // Pay pending PIGS
    function payOrLockupPendingPigs(uint256 _pid) internal {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];

        if (user.nextHarvestUntil == 0) {
            user.nextHarvestUntil = block.timestamp + pool.harvestInterval;
        }

        uint256 pigsPending = ((user.amount * pool.accPigsPerShare) / 1e24) - user.pigsRewardDebt;

        if (canHarvest(_pid, msg.sender)) {
            if (pigsPending > 0 || user.rewardLockedUp > 0) {
                uint256 totalRewards = pigsPending + user.rewardLockedUp;

                // reset lockup
                totalLockedUpRewards = totalLockedUpRewards - user.rewardLockedUp;
                user.rewardLockedUp = 0;
                user.nextHarvestUntil = block.timestamp + pool.harvestInterval;

                safeTokenTransfer(address(PigsV2Token), msg.sender, totalRewards);
            }
        } else if (pigsPending > 0) {
            user.rewardLockedUp = user.rewardLockedUp + pigsPending;
            totalLockedUpRewards = totalLockedUpRewards + pigsPending;
            emit RewardLockedUp(msg.sender, _pid, pigsPending);
        }

    }

    /**
     * @dev un-enchant the lp token into its original components.
     */
    function unpairLPToken(address token, uint256 amount) internal returns(address token0, address token1, uint256 amountA, uint256 amountB){
        _approveTokenIfNeeded(token, address(PancakeRouter));

        IUniswapV2Pair lpToken = IUniswapV2Pair(token);
        address token0 = lpToken.token0();
        address token1 = lpToken.token1();

        // make the swap
        (uint256 amount0, uint256 amount1) = PancakeRouter.removeLiquidity(
            address(token0),
            address(token1),
            amount,
            0,
            0,
            address(this),
            block.timestamp
        );
        if(token0 == busdCurrencyAddress){
            return (token0, token1, amount0, amount1);
        }else{
            return (token1, token0, amount1, amount0);
        }

    }
    
    function _approveTokenIfNeeded(address token, address _contract) private {
        if (IERC20(token).allowance(address(this), address(_contract)) == 0) {
            IERC20(token).safeApprove(address(_contract), type(uint256).max);
        }
    }

    // Safe token transfer function, just in case if rounding error causes pool to not have enough DOGS.
    function safeTokenTransfer(address token, address _to, uint256 _amount) internal {
        uint256 tokenBal = IERC20(token).balanceOf(address(this));
        if (_amount > tokenBal) {
            IERC20(token).safeTransfer(_to, tokenBal);
        } else {
            IERC20(token).safeTransfer(_to, _amount);
        }
    }
    
    function increasePigsSupply(uint256 _amount) external onlyOwner{
        require(!mintBurned);
        PigsV2Token.mint(msg.sender, _amount);
    }

    function burnMint() external onlyOwner{
        mintBurned = true;
    }

    function setFoundersAddresses(IFounderStakerV2 _founder) external onlyOwner {
        require(address(_founder) != address(0), "!nonzero");
        FOUNDER = _founder;
        emit SetFounder(address(_founder));
    }

    function setFoundersRewards(uint256 _newRewardsAmount) external onlyOwner {
        require(_newRewardsAmount <= 100, "too high reward");
        ownerPigsReward = _newRewardsAmount;
        emit SetOwnersRewards(_newRewardsAmount);
    }

    function setFarmStartBlock(uint256 _newStartBlock) external onlyOwner {
        DDSCA._setFarmStartBlock(_newStartBlock);
        uint256 length = poolInfo.length;
        for (uint256 pid = 0; pid < length; ++pid) {
            PoolInfo storage pool = poolInfo[pid];
            pool.lastRewardBlock = _newStartBlock;
        }
    }

    function setPlatformAddress(address _platformAddress) external onlyOwner {
        require(_platformAddress != address(0), "!nonzero");
        PLATFORM_ADDRESS = _platformAddress;
        emit SetPlatformAddress(_platformAddress);
    }

    function updateEmissions(uint256 priceInCents) external {
        require(msg.sender == govAddress, "!gov");
        (bool needsUpdate, IDDSCA.EmissionRate rate) = DDSCA.checkIfUpdateIsNeeded(priceInCents);
        if (needsUpdate){
            // Update pools before changing the emission rate
            massUpdatePools();
            DDSCA.updateEmissions(rate);
        }
    }

    function setDDSCAAddress(IDDSCA _ddsca) external onlyOwner{
        DDSCA = _ddsca;
    }

    function setGov(address _govAddress) external onlyOwner {
        require(_govAddress != address(0), 'zero address');
        govAddress = _govAddress;
        emit GovUpdated(govAddress);
    }

    function setDogPoundAutoPool(address _dogPoundAutoPool) external onlyOwner {
        require(_dogPoundAutoPool != address(0), 'zero address');
        DogPoundAutoPool = _dogPoundAutoPool;
        emit DogPoundAutoPoolUpdated(DogPoundAutoPool);
    }

    function updateMigrator(address _migrator) external onlyOwner {
        Migrator = _migrator;
    }

}// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./interfaces/IMasterchefDogs.sol";

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/interfaces/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract Migrator is Ownable {
    using SafeERC20 for IERC20;

    IMasterchefDogs public MasterChefDogs;
    bool public migrationEnabled = false;

    // Info of each pool.
    struct PoolInfo {
        IERC20 token; // Address of LP token contract.
    }

    // Info of each pool.
    PoolInfo[] public poolInfo;
    // Info of each user that stakes LP tokens.
    mapping(uint256 => mapping(address => UserInfo)) public userInfo;

    // Info of each user.
    struct UserInfo {
        uint256 amountStaked;
    }

    constructor(IMasterchefDogs _masterchefDogs){
        MasterChefDogs = _masterchefDogs;
    }


    // ADMIN FUNCTIONS
    function toggleMigrationEnabled(bool _state) public onlyOwner {
        migrationEnabled = _state;
    }

    function updateMasterchefDogs(IMasterchefDogs _masterchefDogs) public onlyOwner {
        MasterChefDogs = _masterchefDogs;
    }

    function addPool(IERC20 _token) external onlyOwner {
        poolInfo.push(PoolInfo({token: _token}));
    }

    function addPoolUserData(uint256 _poolIndex, address[] memory _users, uint256[] memory _usersStakeData) external onlyOwner {
        require(_users.length == _usersStakeData.length);
        for (uint256 i = 0; i < _users.length; i++) {
            userInfo[_poolIndex][_users[i]] .amountStaked = _usersStakeData[i];
        }
    }

    function inCaseTokensGetStuck(address _token, uint256 _amount, address _to) external onlyOwner {
        IERC20(_token).safeTransfer(_to, _amount);
    }

    // EXTERNAL FUNCTIONS
    function migrate(uint256 _pid, uint256 _amount, address _referrer) external {
        UserInfo storage user = userInfo[_pid][msg.sender];

        require(migrationEnabled, 'migration not enabled');
        require(_amount > 0, 'zero amount');
        require(_amount <= user.amountStaked, 'exceed allowed deposit');
        user.amountStaked -= _amount;

        MasterChefDogs.depositMigrator(msg.sender, _pid, _amount, _referrer);

    }

    // VIEW FUNCTIONS
    function availableToMigrate(uint256 _pid, address _user) external view returns (uint256){
        return userInfo[_pid][_user].amountStaked;
    }


}// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./interfaces/IMasterchefPigs.sol";

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/interfaces/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import "hardhat/console.sol";

contract MigratorPigs is Ownable {
    using SafeERC20 for IERC20;

    IMasterchefPigs public MasterChefPigs;
    bool public migrationEnabled = false;

    // Info of each pool.
    struct PoolInfo {
        IERC20 token; // Address of LP token contract.
    }

    // Info of each pool.
    PoolInfo[] public poolInfo;
    // Info of each user that stakes LP tokens.
    mapping(uint256 => mapping(address => UserInfo)) public userInfo;

    // Info of each user.
    struct UserInfo {
        uint256 amountStaked;
    }

    constructor(IMasterchefPigs _masterchefPigs){
        MasterChefPigs = _masterchefPigs;
    }

    // ADMIN FUNCTIONS
    function toggleMigrationEnabled(bool _state) public onlyOwner {
        migrationEnabled = _state;
    }

    function updateMasterchefDogs(IMasterchefPigs _masterchefPigs) public onlyOwner {
        MasterChefPigs = _masterchefPigs;
    }

    function addPool(IERC20 _token) external onlyOwner {
        poolInfo.push(PoolInfo({token: _token}));
    }

    function addPoolUserData(uint256 _poolIndex, address[] memory _users, uint256[] memory _usersStakeData) external onlyOwner {
        require(_users.length == _usersStakeData.length);
        for (uint256 i = 0; i < _users.length; i++) {
            UserInfo storage user = userInfo[_poolIndex][_users[i]];
            user.amountStaked = _usersStakeData[i];
        }
    }

    function inCaseTokensGetStuck(address _token, uint256 _amount, address _to) external onlyOwner {
        IERC20(_token).safeTransfer(_to, _amount);
    }

    // EXTERNAL FUNCTIONS
    function migrate(uint256 _pid, uint256 _amount) external {
        UserInfo storage user = userInfo[_pid][msg.sender];

        console.log("_amount: ", _amount);
        console.log("user.amountStaked: ", user.amountStaked);

        require(migrationEnabled, 'migration not enabled');
        require(_amount > 0, 'zero amount');
        require(_amount <= user.amountStaked, 'exceed allowed deposit');
        user.amountStaked -= _amount;

        MasterChefPigs.depositMigrator(msg.sender, _pid, _amount);

    }

    // VIEW FUNCTIONS
    function availableToMigrate(uint256 _pid, address _user) external view returns (uint256){
        return userInfo[_pid][_user].amountStaked;
    }


}import "@openzeppelin/contracts/interfaces/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";

import ".//DogsNftManager.sol";
import "./StakeManagerV2.sol";
import "./interfaces/IDogsExchangeHelper.sol";
import "./interfaces/IDogsToken.sol";
import "./interfaces/IMasterchefPigs.sol";

contract NftPigMcStakingBnb is
    Ownable //consider doing structure where deposit withdraw etc are done through the dpm to avoid extra approvals
{
    using SafeERC20 for IERC20;

    IERC20 public PigsToken =
        IERC20(0x9a3321E1aCD3B9F6debEE5e042dD2411A1742002);
    IERC20 public BnbToken = IERC20(0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c);
    IERC20 public Dogs_BNB_LpToken =
        IERC20(0x2139C481d4f31dD03F924B6e87191E15A33Bf8B4);
    address public dogsToken = 0x198271b868daE875bFea6e6E4045cDdA5d6B9829;
    uint256 public lastPigsBalance = 0;
    uint256 public pigsRoundMask = 0;
    uint256 public lpStakedTotal;
    IDogsToken public DogsToken = IDogsToken(dogsToken);
    DogsNftManager public nftManager;
    IMasterchefPigs public MasterchefPigs =
        IMasterchefPigs(0x8536178222fC6Ec5fac49BbfeBd74CA3051c638f);
    IDogsExchangeHelper public DogsExchangeHelper =
        IDogsExchangeHelper(0xB59686fe494D1Dd6d3529Ed9df384cD208F182e8);

    IUniswapV2Router02 public constant PancakeRouter =
        IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
    mapping(uint256 => NftInfo) public nftInfo;

    receive() external payable {}

    struct NftInfo {
        uint256 lpAmount;
        uint256 pigsMask;
    }

    constructor(address _nftManager) {
        nftManager = DogsNftManager(_nftManager);
        _approveTokenIfNeeded(dogsToken, address(_nftManager));
        _approveTokenIfNeeded(dogsToken, address(DogsExchangeHelper));
        _approveTokenIfNeeded(address(BnbToken), address(DogsExchangeHelper));
    }

    function deposit(
        uint256 _tokenID,
        uint256 _dogsAmount,
        uint256 _bnbAmount
    ) external {
        nftManager.transferFrom(msg.sender, address(this), _tokenID);
        claimPigsRewardsInternal(_tokenID);
        nftManager.useNFTbalance(_tokenID, _dogsAmount, address(this));
        BnbToken.transferFrom(msg.sender, address(this), _bnbAmount);
        (
            uint256 dogsBnbLpReceived,
            uint256 balance2,
            uint256 balance
        ) = DogsExchangeHelper.addDogsLiquidity(
                address(BnbToken),
                _bnbAmount,
                _dogsAmount
            );
        nftManager.returnNFTbalance(_tokenID, balance2, address(this));
        BnbToken.transfer(msg.sender, balance);
        // nftInfo[_tokenID].dogAmount += _dogsAmount - balance2;
        nftInfo[_tokenID].lpAmount += dogsBnbLpReceived;
        _stakeIntoMCPigs(dogsBnbLpReceived);
        nftManager.transferFrom(address(this), msg.sender, _tokenID);
    }

    function withdraw(uint256 _tokenID, uint256 _lpPercent) external {
        require(_lpPercent <= 10000, "invalid percent");
        nftManager.transferFrom(msg.sender, address(this), _tokenID);
        uint256 lpToWithdraw = (nftInfo[_tokenID].lpAmount * _lpPercent) /
            10000;
        MasterchefPigs.withdraw(1, lpToWithdraw);
        handlePigsIncrease();
        claimPigsRewardsInternal(_tokenID);
        lpStakedTotal -= lpToWithdraw;
        (uint256 bnbRemoved, uint256 dogsRemoved) = removeLiquidityFromPair(
            lpToWithdraw
        );
        nftInfo[_tokenID].lpAmount -= lpToWithdraw;
        BnbToken.transfer(msg.sender, bnbRemoved);
        uint256 nftMaxBal = nftManager.nftPotentialBalance(_tokenID);
        uint256 nftCurBal = nftManager.nftHoldingBalance(_tokenID);
        if (dogsRemoved > nftMaxBal - nftCurBal) {
            uint256 fillAmount = nftMaxBal - nftCurBal;
            nftManager.returnNFTbalance(_tokenID, fillAmount, address(this));
            DogsToken.transfer(msg.sender, dogsRemoved - fillAmount);
        } else {
            nftManager.returnNFTbalance(_tokenID, dogsRemoved, address(this));
        }
        nftManager.transferFrom(address(this), msg.sender, _tokenID);
    }

    function claimPigsRewardsInternal(uint256 _tokenID) internal {
        uint256 pigsAmount = (nftInfo[_tokenID].lpAmount *
            (pigsRoundMask - nftInfo[_tokenID].pigsMask)) / 1e18;
        if (pigsAmount > lastPigsBalance) {
            pigsAmount = lastPigsBalance;
        }
        PigsToken.transfer(msg.sender, pigsAmount);
        lastPigsBalance -= pigsAmount;
        updateNftMask(_tokenID);
    }

    function claimPigsRewardsPublic(uint256[] memory _tokenIDs) public {
        for (uint256 i = 0; i < _tokenIDs.length; i++) {
            uint256 _tokenID = _tokenIDs[i];
            require(nftManager.ownerOf(_tokenID) == msg.sender, "not owner");
            uint256 pigsAmount = (nftInfo[_tokenID].lpAmount *
                (pigsRoundMask - nftInfo[_tokenID].pigsMask)) / 1e18;
            if (pigsAmount > lastPigsBalance) {
                pigsAmount = lastPigsBalance;
            }
            PigsToken.transfer(msg.sender, pigsAmount);
            lastPigsBalance -= pigsAmount;
            updateNftMask(_tokenID);
        }
    }

    function removeLiquidityFromPair(
        uint256 _amount
    ) internal returns (uint256 bnbRemoved, uint256 dogsRemoved) {
        Dogs_BNB_LpToken.approve(address(PancakeRouter), _amount);
        // add the liquidity
        (bnbRemoved, dogsRemoved) = PancakeRouter.removeLiquidity(
            address(BnbToken),
            dogsToken,
            _amount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            address(this),
            block.timestamp
        );
    }

    function pendingRewards(
        uint256 _tokenID
    ) external view returns (uint256 pigsAmount) {
        pigsAmount =
            (nftInfo[_tokenID].lpAmount *
                (pigsRoundMask - nftInfo[_tokenID].pigsMask)) /
            1e18;
    }

    function lpAmount(
        uint256 _tokenID
    ) external view returns (uint256 _lpAmount) {
        _lpAmount = nftInfo[_tokenID].lpAmount;
    }

    function _approveTokenIfNeeded(address token, address _address) private {
        if (IERC20(token).allowance(address(this), address(_address)) == 0) {
            IERC20(token).safeApprove(address(_address), type(uint256).max);
        }
    }

    function handlePigsIncrease() internal {
        uint256 pigsEarned = getPigsEarned();
        pigsRoundMask += (pigsEarned * 1e18) / lpStakedTotal;
    }

    function _stakeIntoMCPigs(uint256 _amountLP) internal {
        allowanceCheckAndSet(
            IERC20(Dogs_BNB_LpToken),
            address(MasterchefPigs),
            _amountLP
        );
        MasterchefPigs.deposit(1, _amountLP);
        lpStakedTotal += _amountLP;
        handlePigsIncrease();
    }

    function allowanceCheckAndSet(
        IERC20 _token,
        address _spender,
        uint256 _amount
    ) internal {
        uint256 allowance = _token.allowance(address(this), _spender);
        if (allowance < _amount) {
            require(_token.approve(_spender, _amount), "allowance err");
        }
    }

    function setNftManager(address _nftManager) external onlyOwner {
        nftManager = DogsNftManager(_nftManager);
        _approveTokenIfNeeded(dogsToken, address(nftManager));
    }

    function getPigsEarned() internal returns (uint256) {
        uint256 pigsBalance = PigsToken.balanceOf(address(this));
        uint256 pigsEarned = pigsBalance - lastPigsBalance;
        lastPigsBalance = pigsBalance;
        return pigsEarned;
    }

    function updateNftMask(uint256 _tokenID) internal {
        nftInfo[_tokenID].pigsMask = pigsRoundMask;
    }
}
import "@openzeppelin/contracts/interfaces/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

import ".//DogsNftManager.sol";
import "./StakeManagerV2.sol";
import "./interfaces/IDogsExchangeHelper.sol";
import "./interfaces/IDogsToken.sol";
import "./interfaces/IMasterchefPigs.sol";
import "@uniswap/v2-periphery/contracts/interfaces/IWETH.sol";

contract NftPigMcStakingBnbWWrap is
    Ownable,
    ReentrancyGuard //consider doing structure where deposit withdraw etc are done through the dpm to avoid extra approvals
{
    using SafeERC20 for IERC20;

    IERC20 public PigsToken =
        IERC20(0x9a3321E1aCD3B9F6debEE5e042dD2411A1742002);
    IERC20 public BnbToken = IERC20(0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c);
    IERC20 public Dogs_BNB_LpToken =
        IERC20(0x2139C481d4f31dD03F924B6e87191E15A33Bf8B4);
    IWETH wBnb = IWETH(0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c);
    address public dogsToken = 0x198271b868daE875bFea6e6E4045cDdA5d6B9829;
    uint256 public lastPigsBalance = 0;
    uint256 public pigsRoundMask = 0;
    uint256 public lpStakedTotal;
    IDogsToken public DogsToken = IDogsToken(dogsToken);
    DogsNftManager public nftManager;
    IMasterchefPigs public MasterchefPigs =
        IMasterchefPigs(0x8536178222fC6Ec5fac49BbfeBd74CA3051c638f);
    IDogsExchangeHelper public DogsExchangeHelper =
        IDogsExchangeHelper(0xB59686fe494D1Dd6d3529Ed9df384cD208F182e8);

    IUniswapV2Router02 public constant PancakeRouter =
        IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
    mapping(uint256 => NftInfo) public nftInfo;

    receive() external payable {}

    struct NftInfo {
        uint256 lpAmount;
        uint256 pigsMask;
    }

    constructor(address _nftManager) {
        nftManager = DogsNftManager(_nftManager);
        _approveTokenIfNeeded(dogsToken, address(_nftManager));
        _approveTokenIfNeeded(dogsToken, address(DogsExchangeHelper));
        _approveTokenIfNeeded(address(BnbToken), address(DogsExchangeHelper));
    }

    function deposit(
        uint256 _tokenID,
        uint256 _dogsAmount
    ) external payable nonReentrant {
        nftManager.transferFrom(msg.sender, address(this), _tokenID);
        claimPigsRewardsInternal(_tokenID);
        nftManager.useNFTbalance(_tokenID, _dogsAmount, address(this));
        uint256 bnbAmount = msg.value;
        wBnb.deposit{value: bnbAmount}();
        (
            uint256 dogsBnbLpReceived,
            uint256 balance2,
            uint256 balance
        ) = DogsExchangeHelper.addDogsLiquidity(
                address(BnbToken),
                bnbAmount,
                _dogsAmount
            );
        nftManager.returnNFTbalance(_tokenID, balance2, address(this));
        BnbToken.transfer(msg.sender, balance);
        // nftInfo[_tokenID].dogAmount += _dogsAmount - balance2;
        nftInfo[_tokenID].lpAmount += dogsBnbLpReceived;
        _stakeIntoMCPigs(dogsBnbLpReceived);
        nftManager.transferFrom(address(this), msg.sender, _tokenID);
    }

    function withdraw(
        uint256 _tokenID,
        uint256 _lpPercent
    ) external nonReentrant {
        require(_lpPercent <= 10000, "invalid percent");
        nftManager.transferFrom(msg.sender, address(this), _tokenID);
        uint256 lpToWithdraw = (nftInfo[_tokenID].lpAmount * _lpPercent) /
            10000;
        MasterchefPigs.withdraw(1, lpToWithdraw);
        handlePigsIncrease();
        claimPigsRewardsInternal(_tokenID);
        lpStakedTotal -= lpToWithdraw;
        (uint256 bnbRemoved, uint256 dogsRemoved) = removeLiquidityFromPair(
            lpToWithdraw
        );
        nftInfo[_tokenID].lpAmount -= lpToWithdraw;
        wBnb.withdraw(bnbRemoved);
        (bool success, ) = (msg.sender).call{value: bnbRemoved}("");
        require(success, "Transfer failed.");
        uint256 nftMaxBal = nftManager.nftPotentialBalance(_tokenID);
        uint256 nftCurBal = nftManager.nftHoldingBalance(_tokenID);
        if (dogsRemoved > nftMaxBal - nftCurBal) {
            uint256 fillAmount = nftMaxBal - nftCurBal;
            nftManager.returnNFTbalance(_tokenID, fillAmount, address(this));
            DogsToken.transfer(msg.sender, dogsRemoved - fillAmount);
        } else {
            nftManager.returnNFTbalance(_tokenID, dogsRemoved, address(this));
        }
        nftManager.transferFrom(address(this), msg.sender, _tokenID);
    }

    function claimPigsRewardsInternal(uint256 _tokenID) internal {
        uint256 pigsAmount = (nftInfo[_tokenID].lpAmount *
            (pigsRoundMask - nftInfo[_tokenID].pigsMask)) / 1e18;
        if (pigsAmount > lastPigsBalance) {
            pigsAmount = lastPigsBalance;
        }
        PigsToken.transfer(msg.sender, pigsAmount);
        lastPigsBalance -= pigsAmount;
        updateNftMask(_tokenID);
    }

    function claimPigsRewardsPublic(uint256[] memory _tokenIDs) public {
        for (uint256 i = 0; i < _tokenIDs.length; i++) {
            uint256 _tokenID = _tokenIDs[i];
            require(nftManager.ownerOf(_tokenID) == msg.sender, "not owner");
            uint256 pigsAmount = (nftInfo[_tokenID].lpAmount *
                (pigsRoundMask - nftInfo[_tokenID].pigsMask)) / 1e18;
            if (pigsAmount > lastPigsBalance) {
                pigsAmount = lastPigsBalance;
            }
            PigsToken.transfer(msg.sender, pigsAmount);
            lastPigsBalance -= pigsAmount;
            updateNftMask(_tokenID);
        }
    }

    function removeLiquidityFromPair(
        uint256 _amount
    ) internal returns (uint256 bnbRemoved, uint256 dogsRemoved) {
        Dogs_BNB_LpToken.approve(address(PancakeRouter), _amount);
        // add the liquidity
        (bnbRemoved, dogsRemoved) = PancakeRouter.removeLiquidity(
            address(BnbToken),
            dogsToken,
            _amount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            address(this),
            block.timestamp
        );
    }

    function _approveTokenIfNeeded(address token, address _address) private {
        if (IERC20(token).allowance(address(this), address(_address)) == 0) {
            IERC20(token).safeApprove(address(_address), type(uint256).max);
        }
    }

    function handlePigsIncrease() internal {
        uint256 pigsEarned = getPigsEarned();
        pigsRoundMask += (pigsEarned * 1e18) / lpStakedTotal;
    }

    function _stakeIntoMCPigs(uint256 _amountLP) internal {
        allowanceCheckAndSet(
            IERC20(Dogs_BNB_LpToken),
            address(MasterchefPigs),
            _amountLP
        );
        MasterchefPigs.deposit(1, _amountLP);
        lpStakedTotal += _amountLP;
        handlePigsIncrease();
    }

    function pendingRewards(
        uint256 _tokenID
    ) external view returns (uint256 pigsAmount) {
        pigsAmount =
            (nftInfo[_tokenID].lpAmount *
                (pigsRoundMask - nftInfo[_tokenID].pigsMask)) /
            1e18;
    }

    function lpAmount(
        uint256 _tokenID
    ) external view returns (uint256 _lpAmount) {
        _lpAmount = nftInfo[_tokenID].lpAmount;
    }

    function allowanceCheckAndSet(
        IERC20 _token,
        address _spender,
        uint256 _amount
    ) internal {
        uint256 allowance = _token.allowance(address(this), _spender);
        if (allowance < _amount) {
            require(_token.approve(_spender, _amount), "allowance err");
        }
    }

    function setNftManager(address _nftManager) external onlyOwner {
        nftManager = DogsNftManager(_nftManager);
        _approveTokenIfNeeded(dogsToken, address(nftManager));
    }

    function getPigsEarned() internal returns (uint256) {
        uint256 pigsBalance = PigsToken.balanceOf(address(this));
        uint256 pigsEarned = pigsBalance - lastPigsBalance;
        lastPigsBalance = pigsBalance;
        return pigsEarned;
    }

    function updateNftMask(uint256 _tokenID) internal {
        nftInfo[_tokenID].pigsMask = pigsRoundMask;
    }
}
import "@openzeppelin/contracts/interfaces/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";

import ".//DogsNftManager.sol";
import "./StakeManagerV2.sol";
import "./interfaces/IDogsExchangeHelper.sol";
import "./interfaces/IDogsToken.sol";
import "./interfaces/IMasterchefPigs.sol";

contract NftPigMcStakingBusd is
    Ownable //consider doing structure where deposit withdraw etc are done through the dpm to avoid extra approvals
{
    using SafeERC20 for IERC20;

    IERC20 public PigsToken =
        IERC20(0x9a3321E1aCD3B9F6debEE5e042dD2411A1742002);
    IERC20 public BusdToken =
        IERC20(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56);
    IERC20 public Dogs_BUSD_LpToken =
        IERC20(0xb5151965b13872B183EBa08e33D0d06743AC8132);
    address public dogsToken = 0x198271b868daE875bFea6e6E4045cDdA5d6B9829;
    uint256 public lastPigsBalance = 0;
    uint256 public pigsRoundMask = 0;
    uint256 public lpStakedTotal;
    IDogsToken public DogsToken = IDogsToken(dogsToken);
    DogsNftManager public nftManager;
    IMasterchefPigs public MasterchefPigs =
        IMasterchefPigs(0x8536178222fC6Ec5fac49BbfeBd74CA3051c638f);
    IDogsExchangeHelper public DogsExchangeHelper =
        IDogsExchangeHelper(0xB59686fe494D1Dd6d3529Ed9df384cD208F182e8);

    IUniswapV2Router02 public constant PancakeRouter =
        IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
    mapping(uint256 => NftInfo) public nftInfo;

    receive() external payable {}

    struct NftInfo {
        uint256 lpAmount;
        uint256 pigsMask;
    }

    constructor(address _nftManager) {
        nftManager = DogsNftManager(_nftManager);
        _approveTokenIfNeeded(dogsToken, address(_nftManager));
        _approveTokenIfNeeded(dogsToken, address(DogsExchangeHelper));
        _approveTokenIfNeeded(address(BusdToken), address(DogsExchangeHelper));
    }

    function deposit(
        uint256 _tokenID,
        uint256 _dogsAmount,
        uint256 _busdAmount
    ) external {
        nftManager.transferFrom(msg.sender, address(this), _tokenID);
        claimPigsRewardsInternal(_tokenID);
        nftManager.useNFTbalance(_tokenID, _dogsAmount, address(this));
        BusdToken.transferFrom(msg.sender, address(this), _busdAmount);
        (
            uint256 dogsBusdLpReceived,
            uint256 balance2,
            uint256 balance
        ) = DogsExchangeHelper.addDogsLiquidity(
                address(BusdToken),
                _busdAmount,
                _dogsAmount
            );
        nftManager.returnNFTbalance(_tokenID, balance2, address(this));
        BusdToken.transfer(msg.sender, balance);
        // nftInfo[_tokenID].dogAmount += _dogsAmount - balance2;
        nftInfo[_tokenID].lpAmount += dogsBusdLpReceived;
        _stakeIntoMCPigs(dogsBusdLpReceived);
        nftManager.transferFrom(address(this), msg.sender, _tokenID);
    }

    function withdraw(uint256 _tokenID, uint256 _lpPercent) external {
        require(_lpPercent <= 10000, "invalid percent");
        nftManager.transferFrom(msg.sender, address(this), _tokenID);
        uint256 lpToWithdraw = (nftInfo[_tokenID].lpAmount * _lpPercent) /
            10000;
        MasterchefPigs.withdraw(0, lpToWithdraw);
        handlePigsIncrease();
        claimPigsRewardsInternal(_tokenID);
        lpStakedTotal -= lpToWithdraw;
        (uint256 busdRemoved, uint256 dogsRemoved) = removeLiquidityFromPair(
            lpToWithdraw
        );
        nftInfo[_tokenID].lpAmount -= lpToWithdraw;
        BusdToken.transfer(msg.sender, busdRemoved);
        uint256 nftMaxBal = nftManager.nftPotentialBalance(_tokenID);
        uint256 nftCurBal = nftManager.nftHoldingBalance(_tokenID);
        if (dogsRemoved > nftMaxBal - nftCurBal) {
            uint256 fillAmount = nftMaxBal - nftCurBal;
            nftManager.returnNFTbalance(_tokenID, fillAmount, address(this));
            DogsToken.transfer(msg.sender, dogsRemoved - fillAmount);
        } else {
            nftManager.returnNFTbalance(_tokenID, dogsRemoved, address(this));
        }
        nftManager.transferFrom(address(this), msg.sender, _tokenID);
    }

    function claimPigsRewardsInternal(uint256 _tokenID) internal {
        uint256 pigsAmount = (nftInfo[_tokenID].lpAmount *
            (pigsRoundMask - nftInfo[_tokenID].pigsMask)) / 1e18;
        if (pigsAmount > lastPigsBalance) {
            pigsAmount = lastPigsBalance;
        }
        PigsToken.transfer(msg.sender, pigsAmount);
        lastPigsBalance -= pigsAmount;
        updateNftMask(_tokenID);
    }

    function claimPigsRewardsPublic(uint256[] memory _tokenIDs) public {
        for (uint256 i = 0; i < _tokenIDs.length; i++) {
            uint256 _tokenID = _tokenIDs[i];
            require(nftManager.ownerOf(_tokenID) == msg.sender, "not owner");
            uint256 pigsAmount = (nftInfo[_tokenID].lpAmount *
                (pigsRoundMask - nftInfo[_tokenID].pigsMask)) / 1e18;
            if (pigsAmount > lastPigsBalance) {
                pigsAmount = lastPigsBalance;
            }
            PigsToken.transfer(msg.sender, pigsAmount);
            lastPigsBalance -= pigsAmount;
            updateNftMask(_tokenID);
        }
    }

    function removeLiquidityFromPair(
        uint256 _amount
    ) internal returns (uint256 busdRemoved, uint256 dogsRemoved) {
        Dogs_BUSD_LpToken.approve(address(PancakeRouter), _amount);
        // add the liquidity
        (busdRemoved, dogsRemoved) = PancakeRouter.removeLiquidity(
            address(BusdToken),
            dogsToken,
            _amount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            address(this),
            block.timestamp
        );
    }

    function _approveTokenIfNeeded(address token, address _address) private {
        if (IERC20(token).allowance(address(this), address(_address)) == 0) {
            IERC20(token).safeApprove(address(_address), type(uint256).max);
        }
    }

    function handlePigsIncrease() internal {
        uint256 pigsEarned = getPigsEarned();
        pigsRoundMask += (pigsEarned * 1e18) / lpStakedTotal;
    }

    function _stakeIntoMCPigs(uint256 _amountLP) internal {
        allowanceCheckAndSet(
            IERC20(Dogs_BUSD_LpToken),
            address(MasterchefPigs),
            _amountLP
        );
        MasterchefPigs.deposit(0, _amountLP);
        lpStakedTotal += _amountLP;
        handlePigsIncrease();
    }

    function allowanceCheckAndSet(
        IERC20 _token,
        address _spender,
        uint256 _amount
    ) internal {
        uint256 allowance = _token.allowance(address(this), _spender);
        if (allowance < _amount) {
            require(_token.approve(_spender, _amount), "allowance err");
        }
    }

    function pendingRewards(
        uint256 _tokenID
    ) external view returns (uint256 pigsAmount) {
        pigsAmount =
            (nftInfo[_tokenID].lpAmount *
                (pigsRoundMask - nftInfo[_tokenID].pigsMask)) /
            1e18;
    }

    function lpAmount(
        uint256 _tokenID
    ) external view returns (uint256 _lpAmount) {
        _lpAmount = nftInfo[_tokenID].lpAmount;
    }

    function setNftManager(address _nftManager) external onlyOwner {
        nftManager = DogsNftManager(_nftManager);
        _approveTokenIfNeeded(dogsToken, address(nftManager));
    }

    function getPigsEarned() internal returns (uint256) {
        uint256 pigsBalance = PigsToken.balanceOf(address(this));
        uint256 pigsEarned = pigsBalance - lastPigsBalance;
        lastPigsBalance = pigsBalance;
        return pigsEarned;
    }

    function updateNftMask(uint256 _tokenID) internal {
        nftInfo[_tokenID].pigsMask = pigsRoundMask;
    }
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./DogsNftManager.sol";
import "./LPToTokenCalculator.sol";
import "./StakeManagerV2.sol";
import "./NftPigMcStakingBusd.sol";
import "./NftPigMcStakingBnb.sol";

contract NftReadContract {
 
  LPToTokenCalculator public lpCalc =  LPToTokenCalculator(0x1e55514a1bA84cC4144841111A5BAdA6D1416D08);
  StakeManagerV2 public stakeManager;
  NftPigMcStakingBnb public nftPigMcStakingBnb;
  NftPigMcStakingBusd public nftPigMcStakingBusd; 
  

  
  struct WithdrawnStakeInfoView2 {
        uint256 nftID;
        uint256 currentAmount;
        uint256 potentialAmount;
        uint256 dogsInLP;
        uint256 busdLP;
        uint256 bnbLP;
        uint256 pigsPendingBusd;
        uint256 pigsPendingBnb;
        uint256 taxReduction;
        uint256 endTime;
        bool isAutoPool;

  }

  constructor (address _stakeManager, address _stakebusd, address _stakebnb) {
    stakeManager = StakeManagerV2(_stakeManager);
    nftPigMcStakingBusd = NftPigMcStakingBusd(payable(_stakebusd));
    nftPigMcStakingBnb = NftPigMcStakingBnb(payable(_stakebnb));
  }



  function getUserWithdrawnStakes(address _user) external view returns(WithdrawnStakeInfoView2 [] memory ) {
    StakeManagerV2.WithdrawnStakeInfoView[] memory stakesinit = stakeManager.getUserWithdrawnStakes(_user);
    uint256 len = stakesinit.length;
    WithdrawnStakeInfoView2[] memory stakes = new WithdrawnStakeInfoView2[](len);
    for(uint256 i = 0; i < len ; i++){
      uint256 nftId = stakesinit[i].nftID;
      (uint256 lpAmountBusd , )  = (nftPigMcStakingBusd.nftInfo(nftId));
      (uint256 lpAmountBnb , ) = (nftPigMcStakingBnb.nftInfo(nftId));
      (uint256 lpTotalBusd, ) = lpCalc.calculateTokensFromLPBusd(lpAmountBusd);
      (uint256 lpTotalBnb, ) = lpCalc.calculateTokensFromLPBnb(lpAmountBnb);
      uint256 lpTotal = lpTotalBusd + lpTotalBnb;
      stakes[i].nftID = stakesinit[i].nftID;
      stakes[i].currentAmount = stakesinit[i].currentAmount;
      stakes[i].potentialAmount = stakesinit[i].potentialAmount;
      stakes[i].dogsInLP = lpTotal;
      stakes[i].busdLP = lpAmountBusd;
      stakes[i].bnbLP = lpAmountBnb;
      stakes[i].pigsPendingBusd = nftPigMcStakingBusd.pendingRewards(stakesinit[i].nftID);
      stakes[i].pigsPendingBnb = nftPigMcStakingBnb.pendingRewards(stakesinit[i].nftID);
      stakes[i].taxReduction = stakesinit[i].taxReduction;
      stakes[i].endTime = stakesinit[i].endTime;
      stakes[i].isAutoPool = stakesinit[i].isAutoPool;
    }

    return stakes;
    
  }


  function getWithdrawnStakeInfo(uint256 _tokenId) external view returns (WithdrawnStakeInfoView2 memory){
    StakeManagerV2.WithdrawnStakeInfoView memory stakeinit = stakeManager.getUserWithdrawnStake(_tokenId);
    WithdrawnStakeInfoView2 memory returnStake;
    (uint256 lpAmountBusd , )  = (nftPigMcStakingBusd.nftInfo(_tokenId));
    (uint256 lpAmountBnb , ) = (nftPigMcStakingBnb.nftInfo(_tokenId));
    (uint256 lpTotalBusd, ) = lpCalc.calculateTokensFromLPBusd(lpAmountBusd);
    (uint256 lpTotalBnb, ) = lpCalc.calculateTokensFromLPBnb(lpAmountBnb);
    uint256 lpTotal = lpTotalBusd + lpTotalBnb;
    returnStake.nftID = stakeinit.nftID;
    returnStake.currentAmount = stakeinit.currentAmount;
    returnStake.potentialAmount = stakeinit.potentialAmount;
    returnStake.dogsInLP = lpTotal;
    returnStake.taxReduction = stakeinit.taxReduction;
    returnStake.endTime = stakeinit.endTime;
    returnStake.isAutoPool = stakeinit.isAutoPool;
    returnStake.busdLP = lpAmountBusd;
    returnStake.bnbLP = lpAmountBnb;
    returnStake.pigsPendingBusd = nftPigMcStakingBusd.pendingRewards(stakeinit.nftID);
    returnStake.pigsPendingBnb = nftPigMcStakingBnb.pendingRewards(stakeinit.nftID);
    return returnStake;
  }



}/**
 *Submitted for verification at Etherscan.io on 2022-05-05
 */

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IOptimizerStrategy {
    /// @return Maximul PLP value that could be minted
    function maxTotalSupply() external view returns (uint256);

    /// @notice Period of time that we observe for price slippage
    /// @return time in seconds
    function twapDuration() external view returns (uint32);

    /// @notice Maximum deviation of time waited avarage price in ticks
    function maxTwapDeviation() external view returns (int24);

    /// @notice Tick multuplier for base range calculation
    function tickRangeMultiplier() external view returns (int24);

    /// @notice The price impact percentage during swap denominated in hundredths of a bip, i.e. 1e-6
    /// @return The max price impact percentage
    function priceImpactPercentage() external view returns (uint24);
}

/// @title Permissioned Optimizer variables
/// @notice Contains Optimizer variables that may only be called by the governance
contract OptimizerStrategy is IOptimizerStrategy {
    /// @inheritdoc IOptimizerStrategy
    uint256 public override maxTotalSupply;
    // Address of the Optimizer's strategy owner
    address public governance;
    // Pending to claim ownership address
    address public pendingGovernance;

    /// @inheritdoc IOptimizerStrategy
    uint32 public override twapDuration;
    /// @inheritdoc IOptimizerStrategy
    int24 public override maxTwapDeviation;
    /// @inheritdoc IOptimizerStrategy
    int24 public override tickRangeMultiplier;
    /// @inheritdoc IOptimizerStrategy
    uint24 public override priceImpactPercentage;

    event TransferGovernance(
        address indexed previousGovernance,
        address indexed newGovernance
    );

    /**
     * @param _twapDuration TWAP duration in seconds for rebalance check
     * @param _maxTwapDeviation Max deviation from TWAP during rebalance
     * @param _tickRangeMultiplier Used to determine base order range
     * @param _priceImpactPercentage The price impact percentage during swap in hundredths of a bip, i.e. 1e-6
     * @param _maxTotalSupply Maximul PLP value that could be minted
     */
    constructor(
        uint32 _twapDuration,
        int24 _maxTwapDeviation,
        int24 _tickRangeMultiplier,
        uint24 _priceImpactPercentage,
        uint256 _maxTotalSupply
    ) {
        twapDuration = _twapDuration;
        maxTwapDeviation = _maxTwapDeviation;
        tickRangeMultiplier = _tickRangeMultiplier;
        priceImpactPercentage = _priceImpactPercentage;
        maxTotalSupply = _maxTotalSupply;
        governance = msg.sender;
        require(_maxTwapDeviation >= 20, "maxTwapDeviation");
        require(
            _priceImpactPercentage < 1e6 && _priceImpactPercentage > 0,
            "PIP"
        );
        require(maxTotalSupply > 0, "maxTotalSupply");
    }

    modifier onlyGovernance() {
        require(msg.sender == governance, "NOT ALLOWED");
        _;
    }

    function setMaxTotalSupply(
        uint256 _maxTotalSupply
    ) external onlyGovernance {
        require(_maxTotalSupply > 0, "maxTotalSupply");
        maxTotalSupply = _maxTotalSupply;
    }

    function setTwapDuration(uint32 _twapDuration) external onlyGovernance {
        twapDuration = _twapDuration;
    }

    function setMaxTwapDeviation(
        int24 _maxTwapDeviation
    ) external onlyGovernance {
        require(_maxTwapDeviation >= 20, "PF");
        maxTwapDeviation = _maxTwapDeviation;
    }

    function setTickRange(int24 _tickRangeMultiplier) external onlyGovernance {
        tickRangeMultiplier = _tickRangeMultiplier;
    }

    function setPriceImpact(
        uint16 _priceImpactPercentage
    ) external onlyGovernance {
        require(
            _priceImpactPercentage < 1e6 && _priceImpactPercentage > 0,
            "PIP"
        );
        priceImpactPercentage = _priceImpactPercentage;
    }

    /**
     * @notice `setGovernance()` should be called by the existing governance
     * address prior to calling this function.
     */
    function setGovernance(address _governance) external onlyGovernance {
        pendingGovernance = _governance;
    }

    /**
     * @notice Governance address is not updated until the new governance
     * address has called `acceptGovernance()` to accept this responsibility.
     */
    function acceptGovernance() external {
        require(msg.sender == pendingGovernance, "PG");
        emit TransferGovernance(governance, pendingGovernance);
        pendingGovernance = address(0);
        governance = msg.sender;
    }
}
/**
 *Submitted for verification at Etherscan.io on 2023-03-22
 */

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    // This is the strict ERC20 interface. Don't use this, certainly not if you don't control the ERC20 token you're calling.
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address _owner) external view returns (uint256 balance);

    function transfer(
        address _to,
        uint256 _value
    ) external returns (bool success);

    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    ) external returns (bool success);

    function approve(
        address _spender,
        uint256 _value
    ) external returns (bool success);

    function allowance(
        address _owner,
        address _spender
    ) external view returns (uint256 remaining);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    /// @notice EIP 2612
    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;
}

interface IWETH9 is IERC20 {
    /// @notice Deposit ether to get wrapped ether
    function deposit() external payable;
}

library BoringERC20 {
    bytes4 private constant SIG_SYMBOL = 0x95d89b41; // symbol()
    bytes4 private constant SIG_NAME = 0x06fdde03; // name()
    bytes4 private constant SIG_DECIMALS = 0x313ce567; // decimals()
    bytes4 private constant SIG_BALANCE_OF = 0x70a08231; // balanceOf(address)
    bytes4 private constant SIG_TOTALSUPPLY = 0x18160ddd; // balanceOf(address)

    function returnDataToString(
        bytes memory data
    ) internal pure returns (string memory) {
        if (data.length >= 64) {
            return abi.decode(data, (string));
        } else if (data.length == 32) {
            uint8 i = 0;
            while (i < 32 && data[i] != 0) {
                i++;
            }
            bytes memory bytesArray = new bytes(i);
            for (i = 0; i < 32 && data[i] != 0; i++) {
                bytesArray[i] = data[i];
            }
            return string(bytesArray);
        } else {
            return "???";
        }
    }

    /// @notice Provides a safe ERC20.symbol version which returns '???' as fallback string.
    /// @param token The address of the ERC-20 token contract.
    /// @return (string) Token symbol.
    function safeSymbol(IERC20 token) internal view returns (string memory) {
        (bool success, bytes memory data) = address(token).staticcall(
            abi.encodeWithSelector(SIG_SYMBOL)
        );
        return success ? returnDataToString(data) : "???";
    }

    /// @notice Provides a safe ERC20.name version which returns '???' as fallback string.
    /// @param token The address of the ERC-20 token contract.
    /// @return (string) Token name.
    function safeName(IERC20 token) internal view returns (string memory) {
        (bool success, bytes memory data) = address(token).staticcall(
            abi.encodeWithSelector(SIG_NAME)
        );
        return success ? returnDataToString(data) : "???";
    }

    /// @notice Provides a safe ERC20.decimals version which returns '18' as fallback value.
    /// @param token The address of the ERC-20 token contract.
    /// @return (uint8) Token decimals.
    function safeDecimals(IERC20 token) internal view returns (uint8) {
        (bool success, bytes memory data) = address(token).staticcall(
            abi.encodeWithSelector(SIG_DECIMALS)
        );
        return success && data.length == 32 ? abi.decode(data, (uint8)) : 18;
    }

    /// @notice Provides a gas-optimized balance check to avoid a redundant extcodesize check in addition to the returndatasize check.
    /// @param token The address of the ERC-20 token.
    /// @param to The address of the user to check.
    /// @return amount The token amount.
    function safeBalanceOf(
        IERC20 token,
        address to
    ) internal view returns (uint256 amount) {
        (bool success, bytes memory data) = address(token).staticcall(
            abi.encodeWithSelector(SIG_BALANCE_OF, to)
        );
        require(success && data.length >= 32, "BoringERC20: BalanceOf failed");
        amount = abi.decode(data, (uint256));
    }

    /// @notice Provides a gas-optimized totalSupply to avoid a redundant extcodesize check in addition to the returndatasize check.
    /// @param token The address of the ERC-20 token.
    /// @return totalSupply The token totalSupply.
    function safeTotalSupply(
        IERC20 token
    ) internal view returns (uint256 totalSupply) {
        (bool success, bytes memory data) = address(token).staticcall(
            abi.encodeWithSelector(SIG_TOTALSUPPLY)
        );
        require(
            success && data.length >= 32,
            "BoringERC20: totalSupply failed"
        );
        totalSupply = abi.decode(data, (uint256));
    }

    function safeTransferETH(address to, uint256 amount) internal {
        bool success;

        assembly {
            // Transfer the ETH and store if it succeeded or not.
            success := call(gas(), to, amount, 0, 0, 0, 0)
        }

        require(success, "ETH_TRANSFER_FAILED");
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 amount
    ) internal {
        bool success;

        assembly {
            // We'll write our calldata to this slot below, but restore it later.
            let memPointer := mload(0x40)

            // Write the abi-encoded calldata into memory, beginning with the function selector.
            mstore(
                0,
                0x23b872dd00000000000000000000000000000000000000000000000000000000
            )
            mstore(4, from) // Append the "from" argument.
            mstore(36, to) // Append the "to" argument.
            mstore(68, amount) // Append the "amount" argument.

            success := and(
                // Set success to whether the call reverted, if not we check it either
                // returned exactly 1 (can't just be non-zero data), or had no return data.
                or(
                    and(eq(mload(0), 1), gt(returndatasize(), 31)),
                    iszero(returndatasize())
                ),
                // We use 100 because that's the total length of our calldata (4 + 32 * 3)
                // Counterintuitively, this call() must be positioned after the or() in the
                // surrounding and() because and() evaluates its arguments from right to left.
                call(gas(), token, 0, 0, 100, 0, 32)
            )

            mstore(0x60, 0) // Restore the zero slot to zero.
            mstore(0x40, memPointer) // Restore the memPointer.
        }

        require(success, "TRANSFER_FROM_FAILED");
    }

    function safeTransfer(IERC20 token, address to, uint256 amount) internal {
        bool success;

        assembly {
            // We'll write our calldata to this slot below, but restore it later.
            let memPointer := mload(0x40)

            // Write the abi-encoded calldata into memory, beginning with the function selector.
            mstore(
                0,
                0xa9059cbb00000000000000000000000000000000000000000000000000000000
            )
            mstore(4, to) // Append the "to" argument.
            mstore(36, amount) // Append the "amount" argument.

            success := and(
                // Set success to whether the call reverted, if not we check it either
                // returned exactly 1 (can't just be non-zero data), or had no return data.
                or(
                    and(eq(mload(0), 1), gt(returndatasize(), 31)),
                    iszero(returndatasize())
                ),
                // We use 68 because that's the total length of our calldata (4 + 32 * 2)
                // Counterintuitively, this call() must be positioned after the or() in the
                // surrounding and() because and() evaluates its arguments from right to left.
                call(gas(), token, 0, 0, 68, 0, 32)
            )

            mstore(0x60, 0) // Restore the zero slot to zero.
            mstore(0x40, memPointer) // Restore the memPointer.
        }

        require(success, "TRANSFER_FAILED");
    }

    function safeApprove(IERC20 token, address to, uint256 amount) internal {
        bool success;

        assembly {
            // We'll write our calldata to this slot below, but restore it later.
            let memPointer := mload(0x40)

            // Write the abi-encoded calldata into memory, beginning with the function selector.
            mstore(
                0,
                0x095ea7b300000000000000000000000000000000000000000000000000000000
            )
            mstore(4, to) // Append the "to" argument.
            mstore(36, amount) // Append the "amount" argument.

            success := and(
                // Set success to whether the call reverted, if not we check it either
                // returned exactly 1 (can't just be non-zero data), or had no return data.
                or(
                    and(eq(mload(0), 1), gt(returndatasize(), 31)),
                    iszero(returndatasize())
                ),
                // We use 68 because that's the total length of our calldata (4 + 32 * 2)
                // Counterintuitively, this call() must be positioned after the or() in the
                // surrounding and() because and() evaluates its arguments from right to left.
                call(gas(), token, 0, 0, 68, 0, 32)
            )

            mstore(0x60, 0) // Restore the zero slot to zero.
            mstore(0x40, memPointer) // Restore the memPointer.
        }

        require(success, "APPROVE_FAILED");
    }
}

// Simplified by BoringCrypto

contract OwnableData {
    address public owner;
    address public pendingOwner;
}

contract Ownable is OwnableData {
    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /// @notice `owner` defaults to msg.sender on construction.
    constructor() {
        owner = msg.sender;
        emit OwnershipTransferred(address(0), msg.sender);
    }

    /// @notice Transfers ownership to `newOwner`. Either directly or claimable by the new pending owner.
    /// Can only be invoked by the current `owner`.
    /// @param newOwner Address of the new owner.
    /// @param direct True if `newOwner` should be set immediately. False if `newOwner` needs to use `claimOwnership`.
    /// @param renounce Allows the `newOwner` to be `address(0)` if `direct` and `renounce` is True. Has no effect otherwise.
    function transferOwnership(
        address newOwner,
        bool direct,
        bool renounce
    ) public onlyOwner {
        if (direct) {
            // Checks
            require(
                newOwner != address(0) || renounce,
                "Ownable: zero address"
            );

            // Effects
            emit OwnershipTransferred(owner, newOwner);
            owner = newOwner;
            pendingOwner = address(0);
        } else {
            // Effects
            pendingOwner = newOwner;
        }
    }

    /// @notice Needs to be called by `pendingOwner` to claim ownership.
    function claimOwnership() public {
        address _pendingOwner = pendingOwner;

        // Checks
        require(
            msg.sender == _pendingOwner,
            "Ownable: caller != pending owner"
        );

        // Effects
        emit OwnershipTransferred(owner, _pendingOwner);
        owner = _pendingOwner;
        pendingOwner = address(0);
    }

    /// @notice Only allows the `owner` to execute the function.
    modifier onlyOwner() {
        require(msg.sender == owner, "Ownable: caller is not the owner");
        _;
    }
}

interface IPancakeV3Optimizer {
    function token0() external view returns (address);

    function token1() external view returns (address);

    function deposit(
        uint256 amount0Desired,
        uint256 amount1Desired,
        uint256 slippage,
        uint256 compSlippage,
        address to
    ) external returns (uint256 shares, uint256 amount0, uint256 amount1);
}

import "./interfaces/INonfungiblePositionManager.sol";

contract OptimizerZapV3 is Ownable {
    using BoringERC20 for IERC20;

    error ErrSwapFailed0();
    error ErrSwapFailed1();

    mapping(address => bool) public approvedTargets;
    address public immutable weth;
    address public immutable eth;
    INonfungiblePositionManager public nonFungiblePositionManager =
        INonfungiblePositionManager(
            payable(0x46A15B0b27311cedF172AB29E4f4766fbE7F4364)
        );

    struct ZapData {
        address tokenIn0;
        address tokenIn1;
        address to;
        address swapTarget0;
        address swapTarget1;
        IPancakeV3Optimizer optimizer;
        uint amountIn0;
        uint amountIn1;
        bytes swapData0;
        bytes swapData1;
    }

    struct Cache {
        address token0;
        address token1;
        uint256 balance0;
        uint256 balance1;
        uint256 balanceIn;
    }

    constructor(address _weth, address _eth) {
        weth = _weth;
        eth = _eth;
        approvedTargets[address(0)] = true; // for non-swaps
        approvedTargets[0x13f4EA83D0bd40E75C8222255bc855a974568Dd4] = true;
        approvedTargets[0x1b81D678ffb9C0263b24A97847620C99d213eB14] = true;
        approvedTargets[0x10ED43C718714eb63d5aA57B78B54704E256024E] = true;
    }

    function DepositInEth(
        IPancakeV3Optimizer optimizer,
        address to,
        uint _otherAmount,
        uint256 slippage,
        uint256 compSlip
    ) external payable {
        require(address(optimizer) != address(0), "ONA");
        require(to != address(0), "RNA");

        Cache memory cache;

        cache.balanceIn = msg.value;
        cache.token0 = optimizer.token0();
        cache.token1 = optimizer.token1();
        require(cache.token0 == weth || cache.token1 == weth, "BO");

        IWETH9(weth).deposit{value: cache.balanceIn}();
        _approveToken(weth, address(optimizer), cache.balanceIn);
        if (cache.token0 == weth) {
            IERC20(cache.token1).safeTransferFrom(
                msg.sender,
                address(this),
                _otherAmount
            );
            _approveToken(cache.token1, address(optimizer), _otherAmount);
            (, uint256 amount0, uint256 amount1) = optimizer.deposit(
                cache.balanceIn,
                _otherAmount,
                slippage,
                compSlip,
                to
            );
            cache.balance0 = cache.balanceIn - amount0;
            cache.balance1 = _otherAmount - amount1;
        } else {
            IERC20(cache.token0).safeTransferFrom(
                msg.sender,
                address(this),
                _otherAmount
            );
            _approveToken(cache.token0, address(optimizer), _otherAmount);
            (, uint256 amount0, uint256 amount1) = optimizer.deposit(
                _otherAmount,
                cache.balanceIn,
                slippage,
                compSlip,
                to
            );
            cache.balance0 = _otherAmount - amount0;
            cache.balance1 = cache.balanceIn - amount1;
        }
        if (cache.balance0 > 0)
            IERC20(cache.token0).safeTransfer(to, cache.balance0);
        if (cache.balance1 > 0)
            IERC20(cache.token1).safeTransfer(to, cache.balance1);
    }

    function ZapIn(
        ZapData memory data,
        uint256 slippage,
        uint256 compSlip
    ) external payable {
        require(approvedTargets[data.swapTarget0], "STNA0");
        require(approvedTargets[data.swapTarget1], "STNA1");
        Cache memory cache;
        uint value = msg.value;
        cache.token0 = data.optimizer.token0();
        cache.token1 = data.optimizer.token1();
        cache.balance0 = IERC20(cache.token0).safeBalanceOf(address(this));
        cache.balance1 = IERC20(cache.token1).safeBalanceOf(address(this));
        if (data.amountIn1 > 0) {
            IERC20(data.tokenIn1).safeTransferFrom(
                msg.sender,
                address(this),
                data.amountIn1
            );
        }
        if (data.tokenIn0 == eth || data.tokenIn0 == address(0)) {
            cache.balanceIn = IERC20(weth).safeBalanceOf(address(this));
            IWETH9(weth).deposit{value: value}();
            data.amountIn0 = value;
            data.tokenIn0 = weth;
        } else {
            cache.balanceIn = IERC20(data.tokenIn0).safeBalanceOf(
                address(this)
            );
            IERC20(data.tokenIn0).safeTransferFrom(
                msg.sender,
                address(this),
                data.amountIn0
            );
        }
        if (data.swapData0.length > 0) {
            _approveToken(data.tokenIn0, data.swapTarget0, data.amountIn0);
            (bool success, ) = data.swapTarget0.call(data.swapData0);
            if (!success) {
                revert ErrSwapFailed0();
            }
        }
        if (data.swapData1.length > 0) {
            _approveToken(data.tokenIn0, data.swapTarget1, data.amountIn0);
            (bool success, ) = data.swapTarget1.call(data.swapData1);
            if (!success) {
                revert ErrSwapFailed1();
            }
        }
        cache.balance0 =
            IERC20(cache.token0).safeBalanceOf(address(this)) -
            cache.balance0;
        cache.balance1 =
            IERC20(cache.token1).safeBalanceOf(address(this)) -
            cache.balance1;
        _approveToken(cache.token0, address(data.optimizer), cache.balance0);
        _approveToken(cache.token1, address(data.optimizer), cache.balance1);
        (, uint amount0, uint amount1) = data.optimizer.deposit(
            cache.balance0,
            cache.balance1,
            slippage,
            compSlip,
            data.to
        );
        cache.balance0 = cache.balance0 - amount0;
        cache.balance1 = cache.balance1 - amount1;
        if (cache.balance0 > 0)
            IERC20(cache.token0).safeTransfer(data.to, cache.balance0);
        if (cache.balance1 > 0)
            IERC20(cache.token1).safeTransfer(data.to, cache.balance1);
        cache.balanceIn =
            IERC20(data.tokenIn0).safeBalanceOf(address(this)) -
            cache.balanceIn;
        if (cache.balanceIn > 0)
            IERC20(data.tokenIn0).safeTransfer(data.to, cache.balanceIn);
    }

    function ZapInNFT(
        ZapData memory data,
        uint256 slippage,
        uint256 nftId,
        uint256 amount0MinNft,
        uint256 amount1MinNft,
        uint256 compSlip
    ) external payable {
        require(approvedTargets[data.swapTarget0], "STNA0");
        require(approvedTargets[data.swapTarget1], "STNA1");
        Cache memory cache;
        cache.token0 = data.optimizer.token0();
        cache.token1 = data.optimizer.token1();
        cache.balance0 = IERC20(cache.token0).safeBalanceOf(address(this));
        cache.balance1 = IERC20(cache.token1).safeBalanceOf(address(this));
        cache.balanceIn = IERC20(data.tokenIn0).safeBalanceOf(address(this));

        nonFungiblePositionManager.transferFrom(
            msg.sender,
            address(this),
            nftId
        );
        (, , , , , , , uint128 liquidity, , , , ) = nonFungiblePositionManager
            .positions(nftId);
        nonFungiblePositionManager.decreaseLiquidity(
            INonfungiblePositionManager.DecreaseLiquidityParams(
                nftId,
                liquidity,
                amount0MinNft,
                amount1MinNft,
                block.timestamp
            )
        );
        nonFungiblePositionManager.collect(
            INonfungiblePositionManager.CollectParams(
                nftId,
                address(this),
                type(uint128).max,
                type(uint128).max
            )
        );
        //         struct DecreaseLiquidityParams {
        //     uint256 tokenId;
        //     uint128 liquidity;
        //     uint256 amount0Min;
        //     uint256 amount1Min;
        //     uint256 deadline;
        // }

        // IERC20(data.tokenIn).safeTransferFrom(
        //     msg.sender,
        //     address(this),
        //     data.amountIn
        // );

        if (data.swapData0.length > 0) {
            _approveToken(data.tokenIn0, data.swapTarget0, data.amountIn0);
            (bool success, ) = data.swapTarget0.call(data.swapData0);
            if (!success) {
                revert ErrSwapFailed0();
            }
        }
        cache.balance0 =
            IERC20(cache.token0).safeBalanceOf(address(this)) -
            cache.balance0;
        cache.balance1 =
            IERC20(cache.token1).safeBalanceOf(address(this)) -
            cache.balance1;
        _approveToken(cache.token0, address(data.optimizer), cache.balance0);
        _approveToken(cache.token1, address(data.optimizer), cache.balance1);
        (, uint amount0, uint amount1) = data.optimizer.deposit(
            cache.balance0,
            cache.balance1,
            slippage,
            compSlip,
            data.to
        );
        cache.balance0 = cache.balance0 - amount0;
        cache.balance1 = cache.balance1 - amount1;
        if (cache.balance0 > 0)
            IERC20(cache.token0).safeTransfer(data.to, cache.balance0);
        if (cache.balance1 > 0)
            IERC20(cache.token1).safeTransfer(data.to, cache.balance1);
        cache.balanceIn =
            IERC20(data.tokenIn0).safeBalanceOf(address(this)) -
            cache.balanceIn;
        if (cache.balanceIn > 0)
            IERC20(data.tokenIn0).safeTransfer(data.to, cache.balanceIn);
    }

    function _approveToken(
        address token,
        address spender,
        uint256 amount
    ) internal {
        if (IERC20(token).allowance(address(this), spender) > 0)
            IERC20(token).safeApprove(spender, 0);
        IERC20(token).safeApprove(spender, amount);
    }

    //Only Owner

    function approveTarget(address _target) external onlyOwner {
        approvedTargets[_target] = true;
    }

    function rejectTarget(address _target) external onlyOwner {
        require(approvedTargets[_target], "TNA");
        approvedTargets[_target] = false;
    }

    function recoverLostToken(IERC20 _token) external onlyOwner {
        _token.safeTransfer(owner, _token.safeBalanceOf(address(this)));
    }

    // function deposit(
    // uint256 amount0Desired,
    // uint256 amount1Desired,
    // uint256 slippage,
    // uint256 compSlippage,
    //     address to
    // )

    function depositEndpoint(
        uint256 amount0Desired,
        uint256 amount1Desired,
        uint256 slippage,
        uint256 compSlippage,
        address optimizer
    ) external {
        IPancakeV3Optimizer _optimizer = IPancakeV3Optimizer(optimizer);
        Cache memory cache;
        cache.token0 = _optimizer.token0();
        cache.token1 = _optimizer.token1();
        cache.balance0 = IERC20(cache.token0).safeBalanceOf(address(this));
        cache.balance1 = IERC20(cache.token1).safeBalanceOf(address(this));
        IERC20(cache.token0).safeTransferFrom(
            msg.sender,
            address(this),
            amount0Desired
        );
        IERC20(cache.token1).safeTransferFrom(
            msg.sender,
            address(this),
            amount1Desired
        );
        cache.balance0 =
            IERC20(cache.token0).safeBalanceOf(address(this)) -
            cache.balance0;
        cache.balance1 =
            IERC20(cache.token1).safeBalanceOf(address(this)) -
            cache.balance1;
        _approveToken(cache.token0, address(_optimizer), cache.balance0);
        _approveToken(cache.token1, address(_optimizer), cache.balance1);
        (, uint amount0, uint amount1) = _optimizer.deposit(
            amount0Desired,
            amount1Desired,
            slippage,
            compSlippage,
            msg.sender
        );
        cache.balance0 = cache.balance0 - amount0;
        cache.balance1 = cache.balance1 - amount1;
        if (cache.balance0 > 0)
            IERC20(cache.token0).safeTransfer(msg.sender, cache.balance0);
        if (cache.balance1 > 0)
            IERC20(cache.token1).safeTransfer(msg.sender, cache.balance1);
    }

    function refundETH() external onlyOwner {
        if (address(this).balance > 0)
            BoringERC20.safeTransferETH(owner, address(this).balance);
    }
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/interfaces/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract ReferralSystem is Ownable {

    address public operator;

    mapping(address => address) public referrers; // user address => referrer address
    mapping(address => uint256) public referralsCount; // referrer address => referrals count
    mapping(address => uint256) public totalReferralCommissions; // referrer address => total referral commissions

    event ReferralRecorded(address indexed user, address indexed referrer);
    event ReferralCommissionRecorded(address indexed referrer, uint256 commission);
    event OperatorUpdated(address indexed operator);

    modifier onlyOperator {
        require(operator == msg.sender, "Operator: caller is not the operator");
        _;
    }

    function recordReferral(address _user, address _referrer) external onlyOperator {
        if (_user != address(0)
        && _referrer != address(0)
        && _user != _referrer
            && referrers[_user] == address(0)
        ) {
            referrers[_user] = _referrer;
            referralsCount[_referrer] += 1;
            emit ReferralRecorded(_user, _referrer);
        }
    }

    function recordReferralCommission(address _referrer, uint256 _commission) external onlyOperator {
        if (_referrer != address(0)) {
            totalReferralCommissions[_referrer] += _commission;
            emit ReferralCommissionRecorded(_referrer, _commission);
        }
    }

    // Get the referrer address that referred the user
    function getReferrer(address _user) external view returns (address) {
        return referrers[_user];
    }


    function updateOperator(address _operator) external onlyOwner {
        require(_operator != address(0), "operator cannot be the 0 address");
        require(operator == address(0), "operator is already set!");

        operator = _operator;

        emit OperatorUpdated(_operator);
    }
}pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/interfaces/IERC20.sol";
import "./interfaces/IDogPoundActions.sol";
import "./interfaces/IDogPoundManager.sol";

import "hardhat/console.sol";

contract RewardsVaultBNB is Ownable {

    address public loyalityPoolAddress1;
    address public loyalityPoolAddress2;

    uint256 public lastPayout;
    uint256 public payoutRate = 3; //3% a day
    uint256 public distributionInterval = 3600;
    IDogPoundManager public DogPoundManager;

    // Events
    event RewardsDistributed(uint256 rewardAmount);
    event UpdatePayoutRate(uint256 payout);
    event UpdateDistributionInterval(uint256 interval);

    constructor(address _dogPoundManager){
        lastPayout = block.timestamp;
        DogPoundManager = IDogPoundManager(_dogPoundManager);
    }

    receive() external payable {}

    function payoutDivs() public {

        uint256 dividendBalance = address(this).balance;

        if (block.timestamp - lastPayout > distributionInterval && dividendBalance > 0) {

            //A portion of the dividend is paid out according to the rate
            uint256 share = dividendBalance * payoutRate / 100 / 24 hours;
            //divide the profit by seconds in the day
            uint256 profit = share * (block.timestamp - lastPayout);

            if (profit > dividendBalance){
                profit = dividendBalance;
            }

            lastPayout = block.timestamp;
            uint256 poolSize;
            poolSize = DogPoundManager.getAutoPoolSize();
            uint256 transfer1Size = (profit * poolSize)/10000;
            uint256 transfer2Size = profit - transfer1Size;
            payable (loyalityPoolAddress1).transfer(transfer1Size);
            payable (loyalityPoolAddress2).transfer(transfer2Size);


            emit RewardsDistributed(profit);

        }
    }

    function updateLoyalityPoolAddress(address _loyalityPoolAddress1, address _loyalityPoolAddress2) external onlyOwner {
        loyalityPoolAddress1 = _loyalityPoolAddress1;
        loyalityPoolAddress2 = _loyalityPoolAddress2;
    }

    function updatePayoutRate(uint256 _newPayout) external onlyOwner {
        require(_newPayout <= 100, 'invalid payout rate');
        payoutRate = _newPayout;
        emit UpdatePayoutRate(payoutRate);
    }

    function setDogPoundManager(IDogPoundManager _dogPoundManager) external onlyOwner {
        DogPoundManager = _dogPoundManager;
    }   

    function payOutAllRewards() external onlyOwner {
        uint256 rewardBalance = address(this).balance;
        uint256 poolSize;
        poolSize = DogPoundManager.getAutoPoolSize();
        uint256 transfer1Size = (rewardBalance * poolSize)/10000;
        uint256 transfer2Size = rewardBalance - transfer1Size;
        payable (loyalityPoolAddress1).transfer(transfer1Size);
        payable (loyalityPoolAddress2).transfer(transfer2Size);
    }

    function updateDistributionInterval(uint256 _newInterval) external onlyOwner {
        require(_newInterval > 0 && _newInterval < 24 hours, 'invalid interval');
        distributionInterval = _newInterval;
        emit UpdateDistributionInterval(distributionInterval);
    }

}// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";


contract StakeManager is Ownable{

    struct UserInfo {

        uint256 totalStakedDefault; //linear
        uint256 totalStakedAutoCompound;

        uint256 walletStartTime;
        uint256 overThresholdTimeCounter;

        uint256 activeStakesCount;
        uint256 withdrawStakesCount;

        mapping(uint256 => StakeInfo) activeStakes;
        mapping(uint256 => WithdrawnStakeInfo) withdrawnStakes;

    }

    struct StakeInfo {
        uint256 amount;
        uint256 startTime;
        bool isAutoPool;
    } 

    struct StakeInfoView {
        uint256 stakeID;
        uint256 taxReduction;
        uint256 amount;
        uint256 startTime;
        bool isAutoPool;
    } 

    struct WithdrawnStakeInfo {
        uint256 amount;
        uint256 taxReduction;
        uint256 endTime;
        bool isAutoPool;
    }

    struct WithdrawnStakeInfoView {
        uint256 stakeID;
        uint256 amount;
        uint256 taxReduction;
        uint256 endTime;
        bool isAutoPool;

    }


    address public DogPoundManger;
    mapping(address => UserInfo) userInfo;


    uint256 public reliefPerDay = 75;      // 0.75% default
    uint256 public reliefPerDayExtra = 25; // 0.25%

    constructor(address _DogPoundManger){
        DogPoundManger = _DogPoundManger;
    }

    modifier onlyDogPoundManager() {
        require(DogPoundManger == msg.sender, "manager only");
        _;
    }

    function saveStake(address _user, uint256 _amount, bool _isAutoCompound) onlyDogPoundManager external{
        UserInfo storage user = userInfo[_user];
        user.activeStakes[user.activeStakesCount].amount = _amount;
        user.activeStakes[user.activeStakesCount].startTime = block.timestamp;
        user.activeStakes[user.activeStakesCount].isAutoPool = _isAutoCompound;
        user.activeStakesCount++;
        if(_isAutoCompound){
            user.totalStakedAutoCompound += _amount;
        }else{
            user.totalStakedDefault += _amount;
        }
    }

    function withdrawFromStake(address _user,uint256 _amount, uint256 _stakeID) onlyDogPoundManager  external{
        UserInfo storage user = userInfo[_user];
        StakeInfo storage activeStake = user.activeStakes[_stakeID];
        require(_amount > 0, "withdraw: zero amount");
        require(activeStake.amount >= _amount, "withdraw: not good");
        uint256 withdrawCount = user.withdrawStakesCount;
        uint256 taxReduction = getActiveStakeTaxReduction(_user, _stakeID);
        bool isAutoCompound = isStakeAutoPool(_user,_stakeID);
        user.withdrawnStakes[withdrawCount].amount = _amount;
        user.withdrawnStakes[withdrawCount].taxReduction = taxReduction;
        user.withdrawnStakes[withdrawCount].endTime = block.timestamp;
        user.withdrawnStakes[withdrawCount].isAutoPool = isAutoCompound;
        user.withdrawStakesCount++;
        activeStake.amount -= _amount;
        if(isAutoCompound){
            user.totalStakedAutoCompound -= _amount;
        }else{
            user.totalStakedDefault -= _amount;
        }

    }

    function utilizeWithdrawnStake(address _user, uint256 _amount, uint256 _stakeID) onlyDogPoundManager external {
        UserInfo storage user = userInfo[_user];
        WithdrawnStakeInfo storage withdrawnStake = user.withdrawnStakes[_stakeID];
        require(withdrawnStake.amount >= _amount);
        user.withdrawnStakes[_stakeID].amount -= _amount;
    }

    function getUserActiveStakes(address _user) public view returns (StakeInfoView[] memory){
        UserInfo storage user = userInfo[_user];
        StakeInfoView[] memory stakes = new StakeInfoView[](user.activeStakesCount);
        for (uint256 i=0; i < user.activeStakesCount; i++){
            stakes[i] = StakeInfoView({
                stakeID : i,
                taxReduction:getActiveStakeTaxReduction(_user,i),
                amount : user.activeStakes[i].amount,
                startTime : user.activeStakes[i].startTime,
                isAutoPool : user.activeStakes[i].isAutoPool
            });
        }
        return stakes;
    }


    function getUserWithdrawnStakes(address _user) public view returns (WithdrawnStakeInfoView[] memory){
        UserInfo storage user = userInfo[_user];
        WithdrawnStakeInfoView[] memory stakes = new WithdrawnStakeInfoView[](user.withdrawStakesCount);
        for (uint256 i=0; i < user.withdrawStakesCount; i++){
            stakes[i] = WithdrawnStakeInfoView({
                stakeID : i,
                amount : user.withdrawnStakes[i].amount,
                taxReduction : user.withdrawnStakes[i].taxReduction,
                endTime : user.withdrawnStakes[i].endTime,
                isAutoPool : user.withdrawnStakes[i].isAutoPool
            });
        }
        return stakes;
    }

    function getActiveStakeTaxReduction(address _user, uint256 _stakeID) public view returns (uint256){
        StakeInfo storage activeStake = userInfo[_user].activeStakes[_stakeID];
        uint256 relief = reliefPerDay;
        if (activeStake.isAutoPool){
            relief = reliefPerDay + reliefPerDayExtra;
        }
        uint256 taxReduction = ((block.timestamp - activeStake.startTime) / 24 hours) * relief;
        return taxReduction;

    }

    function getWithdrawnStakeTaxReduction(address _user, uint256 _stakeID) public view returns (uint256){
        UserInfo storage user = userInfo[_user];
        return user.withdrawnStakes[_stakeID].taxReduction;
    }

    function getUserActiveStake(address _user, uint256 _stakeID) external view returns (StakeInfo memory){
        return userInfo[_user].activeStakes[_stakeID];

    }
    
    function changeReliefValues(uint256 relief1,uint256 relief2) external onlyOwner{
        require(relief1+relief2 < 1000);
        reliefPerDay = relief1;
        reliefPerDayExtra = relief2;
    }

    function getUserWithdrawnStake(address _user, uint256 _stakeID) external view returns (WithdrawnStakeInfo memory){
        return userInfo[_user].withdrawnStakes[_stakeID];
    }

    function isStakeAutoPool(address _user, uint256 _stakeID) public view returns (bool){
        return userInfo[_user].activeStakes[_stakeID].isAutoPool;
    }

    function totalStaked(address _user) public view returns (uint256){
        return userInfo[_user].totalStakedDefault + userInfo[_user].totalStakedAutoCompound;
    }
    
    function setDogPoundManager(address _address) public onlyOwner {
        DogPoundManger = _address;
    }

}// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./StakeManager.sol";
import "./DogsNftManager.sol";

contract StakeManagerV2 is Ownable {
    struct UserInfoV2 {
        uint256 activeStakesCount;
        mapping(uint256 => StakeInfo) activeStakes;
    }

    struct StakeInfo {
        uint256 amount;
        uint256 startTime;
        bool isAutoPool;
    }

    struct StakeInfoView {
        uint256 stakeID;
        uint256 taxReduction;
        uint256 amount;
        uint256 startTime;
        bool isAutoPool;
    }

    struct WithdrawnStakeInfoOld {
        uint256 amount;
        uint256 taxReduction;
        uint256 endTime;
        bool isAutoPool;
    }

    struct WithdrawnStakeInfo {
        uint256 taxReduction;
        uint256 endTime;
        bool isAutoPool;
    }

    struct WithdrawnStakeInfoView {
        uint256 nftID;
        uint256 currentAmount;
        uint256 potentialAmount;
        uint256 taxReduction;
        uint256 endTime;
        bool isAutoPool;
    }

    mapping(address => UserInfoV2) public userInfo;
    mapping(uint256 => WithdrawnStakeInfo) public nftWithdrawnStakes;
    mapping(address => bool) public allowedAddress;
    mapping(address => bool) public initAddress;

    StakeManager public stakeManagerV1 =
        StakeManager(0x25A959dDaEcEb50c1B724C603A57fe7b32eCbEeA);
    DogsNftManager public nftManager;
    uint256 public reliefPerDay = 75; // 0.75% default
    uint256 public reliefPerDayExtra = 25; // 0.25%

    constructor(address _DogPoundManger, address _DogsNftManager) {
        allowedAddress[_DogPoundManger] = true;
        nftManager = DogsNftManager(_DogsNftManager);
    }

    modifier onlyAllowedAddress() {
        require(allowedAddress[msg.sender], "allowed only");
        _;
    }

    function saveStake(
        address _user,
        uint256 _amount,
        bool _isAutoCompound
    ) external onlyAllowedAddress {
        if (!initAddress[_user]) {
            userInfo[_user].activeStakesCount = getOldActiveStakeCount(_user);
            initAddress[_user] = true;
        }
        UserInfoV2 storage user = userInfo[_user];
        user.activeStakes[user.activeStakesCount].amount = _amount;
        user.activeStakes[user.activeStakesCount].startTime = block.timestamp;
        user.activeStakes[user.activeStakesCount].isAutoPool = _isAutoCompound;
        user.activeStakesCount++;
    }

    function saveStakeOldUserInit(
        address _user,
        uint256 _amount,
        bool _isAutoCompound,
        uint256 _lastActiveStake
    ) external onlyAllowedAddress {
        require(
            !initAddress[_user] &&
                stakeManagerV1
                    .getUserActiveStake(_user, _lastActiveStake)
                    .startTime !=
                0 &&
                stakeManagerV1
                    .getUserActiveStake(_user, _lastActiveStake + 1)
                    .startTime ==
                0,
            "Passed stake isnt last stake"
        );
        userInfo[_user].activeStakesCount == _lastActiveStake + 1;
        initAddress[_user] = true;
        UserInfoV2 storage user = userInfo[_user];
        user.activeStakes[user.activeStakesCount].amount = _amount;
        user.activeStakes[user.activeStakesCount].startTime = block.timestamp;
        user.activeStakes[user.activeStakesCount].isAutoPool = _isAutoCompound;
        user.activeStakesCount++;
    }

    function withdrawFromStake(
        address _user,
        uint256 _amount,
        uint256 _stakeID,
        address _from
    ) external onlyAllowedAddress {
        UserInfoV2 storage user = userInfo[_user];
        StakeInfo storage activeStake = user.activeStakes[_stakeID];
        if (activeStake.startTime == 0) {
            user.activeStakes[_stakeID] = activeStakeMove(_user, _stakeID);
            activeStake = user.activeStakes[_stakeID];
        }
        require(_amount > 0, "withdraw: zero amount");
        require(activeStake.amount >= _amount, "withdraw: not good");
        uint256 taxReduction = getActiveStakeTaxReduction(_user, _stakeID);
        bool isAutoCompound = activeStake.isAutoPool;
        uint256 nftTokenID = nftManager.mintForWithdrawnStake(
            _user,
            _amount,
            _from
        );
        nftWithdrawnStakes[nftTokenID].taxReduction = taxReduction;
        nftWithdrawnStakes[nftTokenID].endTime = block.timestamp;
        nftWithdrawnStakes[nftTokenID].isAutoPool = isAutoCompound;
        activeStake.amount -= _amount;
    }

    function mergeNFTs(
        //burning usage and aggregation permissions has to be handled outside
        address _from,
        address _to,
        uint256 _amount,
        uint256 _mergeFrom
    ) external onlyAllowedAddress {
        uint256 _nftTokenID = nftManager.mintForWithdrawnStake(
            _to,
            _amount,
            _from
        );
        uint256 _taxReduction = nftWithdrawnStakes[_mergeFrom].taxReduction;
        bool _isAutoCompound = nftWithdrawnStakes[_mergeFrom].isAutoPool;
        uint256 _endTime = nftWithdrawnStakes[_mergeFrom].endTime;
        nftWithdrawnStakes[_nftTokenID].taxReduction = _taxReduction;
        nftWithdrawnStakes[_nftTokenID].endTime = _endTime;
        nftWithdrawnStakes[_nftTokenID].isAutoPool = _isAutoCompound;
    }

    function transitionOldWithdrawnStake(
        address _user,
        uint256 _stakeID,
        address _from
    ) external onlyAllowedAddress {
        WithdrawnStakeInfoOld memory oldStake = withdrawnStakeMoveInternal(
            _user,
            _stakeID
        );
        stakeManagerV1.utilizeWithdrawnStake(_user, oldStake.amount, _stakeID);
        uint256 nftTokenID = nftManager.mintForWithdrawnStake(
            _user,
            oldStake.amount,
            _from
        );
        nftWithdrawnStakes[nftTokenID].taxReduction = oldStake.taxReduction;
        nftWithdrawnStakes[nftTokenID].endTime = oldStake.endTime;
        nftWithdrawnStakes[nftTokenID].isAutoPool = oldStake.isAutoPool;
    }

    function activeStakeMove(
        address _user,
        uint256 _stakeID
    ) public view returns (StakeInfo memory) {
        StakeManager.StakeInfo memory oldActiveStake = stakeManagerV1
            .getUserActiveStake(_user, _stakeID);
        return
            StakeInfo(
                oldActiveStake.amount,
                oldActiveStake.startTime,
                oldActiveStake.isAutoPool
            );
    }

    function withdrawnStakeMove(
        address _user,
        uint256 _stakeID
    ) public view returns (WithdrawnStakeInfoOld memory) {
        StakeManager.WithdrawnStakeInfo
            memory oldWithdrawnStake = stakeManagerV1.getUserWithdrawnStake(
                _user,
                _stakeID
            );
        return
            WithdrawnStakeInfoOld(
                oldWithdrawnStake.amount,
                oldWithdrawnStake.taxReduction,
                oldWithdrawnStake.endTime,
                oldWithdrawnStake.isAutoPool
            );
    }

    function withdrawnStakeMoveInternal(
        address _user,
        uint256 _stakeID
    ) internal view returns (WithdrawnStakeInfoOld memory) {
        StakeManager.WithdrawnStakeInfo
            memory oldWithdrawnStake = stakeManagerV1.getUserWithdrawnStake(
                _user,
                _stakeID
            );
        return
            WithdrawnStakeInfoOld(
                oldWithdrawnStake.amount,
                oldWithdrawnStake.taxReduction,
                oldWithdrawnStake.endTime,
                oldWithdrawnStake.isAutoPool
            );
    }

    function getUserActiveStakes(
        address _user
    ) public view returns (StakeInfoView[] memory) {
        UserInfoV2 storage user = userInfo[_user];
        uint256 listInit = user.activeStakesCount;
        if (listInit == 0) {
            listInit = getOldActiveStakeCount(_user);
        }
        StakeInfoView[] memory stakes = new StakeInfoView[](listInit);
        for (uint256 i = 0; i < listInit; i++) {
            if (user.activeStakes[i].startTime == 0) {
                StakeInfo memory tempInf = activeStakeMove(_user, i);
                stakes[i] = StakeInfoView({
                    stakeID: i,
                    taxReduction: stakeManagerV1.getActiveStakeTaxReduction(
                        _user,
                        i
                    ),
                    amount: tempInf.amount,
                    startTime: tempInf.startTime,
                    isAutoPool: tempInf.isAutoPool
                });
            } else {
                stakes[i] = StakeInfoView({
                    stakeID: i,
                    taxReduction: getActiveStakeTaxReduction(_user, i),
                    amount: user.activeStakes[i].amount,
                    startTime: user.activeStakes[i].startTime,
                    isAutoPool: user.activeStakes[i].isAutoPool
                });
            }
        }
        return stakes;
    }

    function getUserWithdrawnStakes(
        address _user
    ) public view returns (WithdrawnStakeInfoView[] memory) {
        uint256 balance = nftManager.balanceOf(_user);
        WithdrawnStakeInfoView[] memory stakes = new WithdrawnStakeInfoView[](
            balance
        );
        uint256[] memory nftList = new uint256[](balance);
        for (uint256 i = 0; i < balance; i++) {
            nftList[i] = nftManager.tokenOfOwnerByIndex(_user, i);
        }

        for (uint256 i = 0; i < balance; i++) {
            stakes[i] = WithdrawnStakeInfoView({
                nftID: nftList[i],
                currentAmount: nftManager.nftHoldingBalance(nftList[i]),
                potentialAmount: nftManager.nftPotentialBalance(nftList[i]),
                taxReduction: nftWithdrawnStakes[nftList[i]].taxReduction,
                endTime: nftWithdrawnStakes[nftList[i]].endTime,
                isAutoPool: nftWithdrawnStakes[nftList[i]].isAutoPool
            });
        }
        return stakes;
    }

    function getOldActiveStakeCount(
        address _user
    ) internal view returns (uint256) {
        uint256 finalI = 0;
        while (true) {
            if (
                stakeManagerV1.getUserActiveStake(_user, finalI).startTime == 0
            ) {
                break;
            }
            finalI += 100;
        }
        if (finalI != 0) {
            finalI -= 90;
            while (true) {
                if (
                    stakeManagerV1
                        .getUserActiveStake(_user, finalI)
                        .startTime == 0
                ) {
                    break;
                }
                finalI += 10;
            }
            for (uint256 i = finalI - 9; i < finalI; i++) {
                if (
                    stakeManagerV1.getUserActiveStake(_user, i).startTime == 0
                ) {
                    return i;
                }
            }
            return finalI;
        }
        return 0;
    }

    function getActiveStakeTaxReduction(
        address _user,
        uint256 _stakeID
    ) public view returns (uint256) {
        StakeInfo storage activeStake = userInfo[_user].activeStakes[_stakeID];
        uint256 relief = reliefPerDay;
        if (activeStake.isAutoPool) {
            relief = reliefPerDay + reliefPerDayExtra;
        }
        uint256 taxReduction = ((block.timestamp - activeStake.startTime) /
            24 hours) * relief;
        return taxReduction;
    }

    function getWithdrawnStakeTaxReduction(
        uint256 _tokenID
    ) public view returns (uint256) {
        return nftWithdrawnStakes[_tokenID].taxReduction;
    }

    function getUserActiveStake(
        address _user,
        uint256 _stakeID
    ) external view returns (StakeInfo memory) {
        return userInfo[_user].activeStakes[_stakeID];
    }

    function getUserWithdrawnStake(
        uint256 _tokenID
    ) external view returns (WithdrawnStakeInfoView memory) {
        return
            WithdrawnStakeInfoView(
                _tokenID,
                nftManager.nftHoldingBalance(_tokenID),
                nftManager.nftPotentialBalance(_tokenID),
                nftWithdrawnStakes[_tokenID].taxReduction,
                nftWithdrawnStakes[_tokenID].endTime,
                nftWithdrawnStakes[_tokenID].isAutoPool
            );
    }

    function isStakeAutoPool(
        address _user,
        uint256 _stakeID
    ) public view returns (bool) {
        if (userInfo[_user].activeStakes[_stakeID].startTime == 0) {
            return activeStakeMove(_user, _stakeID).isAutoPool;
        } else {
            return userInfo[_user].activeStakes[_stakeID].isAutoPool;
        }
    }

    function changeReliefValues(
        uint256 relief1,
        uint256 relief2
    ) external onlyOwner {
        require(relief1 + relief2 < 1000);
        reliefPerDay = relief1;
        reliefPerDayExtra = relief2;
    }

    function setNftManager(address _nftManager) external onlyOwner {
        nftManager = DogsNftManager(_nftManager);
    }

    function setAllowedAddress(address _address, bool _state) public onlyOwner {
        allowedAddress[_address] = _state;
    }
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/interfaces/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/security/Pausable.sol";

import "./interfaces/IPancakeswapFarm.sol";
import "./interfaces/ICakePool.sol";

contract StrategyChefV2 is ReentrancyGuard, Pausable {

    // Maximises yields in pancakeswap
    using SafeERC20 for IERC20;

    bool public isCAKEStaking; 
    bool public immutable isStaking; 
    ICakePool public cakePoolContract = ICakePool(0x45c54210128a065de780C4B0Df3d16664f7f859e);
    address public constant cakeTokenAddress = 0x0E09FaBB73Bd3Ade0a17ECC321fD13a19e81cE82;

    address public farmContractAddress; 
    uint256 public pid; 
    address public wantAddress;
    address public earnedAddress;

    address public immutable MasterChefAddress;
    address public govAddress;
    address public feeAddress;

    uint256 public earnDistributeThreshold = 10e18;
    uint256 public wantLockedTotal = 0;

    // Events
    event FeeAddressUpdated(address feeAddress);
    event EarnedAddressUpdated(address earnedAddress);
    event GovUpdated(address govAddress);
    event StuckTokenRemoval(address token, uint256 amount, address to);
    event EarnDistributeThresholdUpdated(uint256 earnDistributeThreshold);

    modifier onlyMasterChef() {
        require(msg.sender == MasterChefAddress, "Only Masterchef!");
        _;
    }

    constructor(
        bool _isStaking,
        address _farmContractAddress,
        uint256 _pid,
        address _wantAddress,
        address _earnedAddress
    ) {
        govAddress = 0x27B788282B3120a254d16bc8d52f16e526F59645;
        MasterChefAddress = 0x78205CE1a7e714CAE95a32e65B6dA7b2dA8D8A10;
        isCAKEStaking = false;
        isStaking = _isStaking;
        wantAddress = _wantAddress;
        feeAddress = 0xA76216D578BdA59d50B520AaF717B187D21F5121;

        if (_isStaking) {
            farmContractAddress = _farmContractAddress;
            pid = _pid;
            earnedAddress = _earnedAddress;
        }

        if (isCAKEStaking){
            IERC20(cakeTokenAddress).approve(address(cakePoolContract), type(uint256).max);
        }
    }

    // Receives new deposits from user
    function deposit(uint256 _wantAmt)
    external
    onlyMasterChef
    whenNotPaused
    nonReentrant
    returns (uint256)
    {
        uint256 wantBalBefore = IERC20(wantAddress).balanceOf(address(this));

        IERC20(wantAddress).safeTransferFrom(
            msg.sender,
            address(this),
            _wantAmt
        );
        uint256 wantBalAfter = IERC20(wantAddress).balanceOf(address(this));

        _wantAmt = wantBalAfter - wantBalBefore;
        if (isStaking) {
            _farm(_wantAmt);
        } else {
            wantLockedTotal = wantLockedTotal + _wantAmt;
        }

        return _wantAmt;
    }

    function _farm(uint256 _wantAmt) internal {
        wantLockedTotal = wantLockedTotal + _wantAmt;
        IERC20(wantAddress).safeIncreaseAllowance(farmContractAddress, _wantAmt);

        if (isCAKEStaking) {
            // _amount, _lockDuration
            cakePoolContract.deposit(_wantAmt, 0); // Just for CAKE staking, we dont use deposit()
        } else {
            IPancakeswapFarm(farmContractAddress).deposit(pid, _wantAmt);
        }
    }

    function withdraw(uint256 _wantAmt)
    external
    onlyMasterChef
    nonReentrant
    returns (uint256)
    {
        require(_wantAmt > 0, "_wantAmt <= 0");
        if (isStaking) {
            if (isCAKEStaking) {
                cakePoolContract.withdrawByAmount(_wantAmt); // Just for CAKE staking, we dont use withdraw()
            } else {
                IPancakeswapFarm(farmContractAddress).withdraw(pid, _wantAmt);
            }
        }

        uint256 wantAmt = IERC20(wantAddress).balanceOf(address(this));
        if (_wantAmt > wantAmt) {
            _wantAmt = wantAmt;
        }

        if (wantLockedTotal < _wantAmt) {
            _wantAmt = wantLockedTotal;
        }

        wantLockedTotal = wantLockedTotal - _wantAmt;

        IERC20(wantAddress).safeTransfer(MasterChefAddress, _wantAmt);

        if (isStaking) {
            distributeFee();
        }

        return _wantAmt;
    }

    // 1. Harvest farm tokens
    // 2. Converts farm tokens into want tokens
    // 3. Deposits want tokens

    function earn() external whenNotPaused nonReentrant {
        require(isStaking, "!isStaking");

        // Harvest farm tokens
        if (!isCAKEStaking) {
            IPancakeswapFarm(farmContractAddress).withdraw(pid, 0);
        }

        distributeFee();
    }

    function distributeFee() internal {

        // Converts farm tokens into want tokens
        uint256 earnedAmt = IERC20(earnedAddress).balanceOf(address(this));
        if (earnedAmt > earnDistributeThreshold){
            IERC20(earnedAddress).safeTransfer(feeAddress, earnedAmt);
        }
    }

    function pause() external {
        require(msg.sender == govAddress, "Not authorised");
        _pause();
    }

    function unpause() external {
        require(msg.sender == govAddress, "Not authorised");
        _unpause();
    }

    function setGov(address _govAddress) external {
        require(msg.sender == govAddress, "!gov");
        govAddress = _govAddress;
        emit GovUpdated(govAddress);
    }

    function setFeeAddress(address _feeAddress) external {
        require(msg.sender == govAddress, "!gov");
        require(_feeAddress != address(0), "!nonzero");
        feeAddress = _feeAddress;
        emit FeeAddressUpdated(feeAddress);
    }

    function setEarnedAddress(address _earnedAddress) external {
        require(msg.sender == govAddress, "!gov");
        require(_earnedAddress != address(0), "!nonzero");
        earnedAddress = _earnedAddress;
        emit EarnedAddressUpdated(earnedAddress);
    }

    function setEarnDistributeThreshold(uint256 _earnDistributeThreshold) external {
        require(msg.sender == govAddress, "!gov");
        earnDistributeThreshold = _earnDistributeThreshold;
        emit EarnDistributeThresholdUpdated(_earnDistributeThreshold);
    }


    function inCaseTokensGetStuck(
        address _token,
        uint256 _amount,
        address _to
    ) public {
        require(msg.sender == govAddress, "!gov");
        require(_token != wantAddress, "!safe");
        IERC20(_token).safeTransfer(_to, _amount);
        emit StuckTokenRemoval(_to, _amount, _to);
    }


}// SPDX-License-Identifier: MIT
pragma solidity >= 0.4.22 <0.9.0;

library console {
	address constant CONSOLE_ADDRESS = address(0x000000000000000000636F6e736F6c652e6c6f67);

	function _sendLogPayload(bytes memory payload) private view {
		uint256 payloadLength = payload.length;
		address consoleAddress = CONSOLE_ADDRESS;
		assembly {
			let payloadStart := add(payload, 32)
			let r := staticcall(gas(), consoleAddress, payloadStart, payloadLength, 0, 0)
		}
	}

	function log() internal view {
		_sendLogPayload(abi.encodeWithSignature("log()"));
	}

	function logInt(int256 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(int256)", p0));
	}

	function logUint(uint256 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256)", p0));
	}

	function logString(string memory p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string)", p0));
	}

	function logBool(bool p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool)", p0));
	}

	function logAddress(address p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address)", p0));
	}

	function logBytes(bytes memory p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes)", p0));
	}

	function logBytes1(bytes1 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes1)", p0));
	}

	function logBytes2(bytes2 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes2)", p0));
	}

	function logBytes3(bytes3 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes3)", p0));
	}

	function logBytes4(bytes4 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes4)", p0));
	}

	function logBytes5(bytes5 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes5)", p0));
	}

	function logBytes6(bytes6 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes6)", p0));
	}

	function logBytes7(bytes7 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes7)", p0));
	}

	function logBytes8(bytes8 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes8)", p0));
	}

	function logBytes9(bytes9 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes9)", p0));
	}

	function logBytes10(bytes10 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes10)", p0));
	}

	function logBytes11(bytes11 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes11)", p0));
	}

	function logBytes12(bytes12 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes12)", p0));
	}

	function logBytes13(bytes13 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes13)", p0));
	}

	function logBytes14(bytes14 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes14)", p0));
	}

	function logBytes15(bytes15 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes15)", p0));
	}

	function logBytes16(bytes16 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes16)", p0));
	}

	function logBytes17(bytes17 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes17)", p0));
	}

	function logBytes18(bytes18 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes18)", p0));
	}

	function logBytes19(bytes19 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes19)", p0));
	}

	function logBytes20(bytes20 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes20)", p0));
	}

	function logBytes21(bytes21 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes21)", p0));
	}

	function logBytes22(bytes22 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes22)", p0));
	}

	function logBytes23(bytes23 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes23)", p0));
	}

	function logBytes24(bytes24 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes24)", p0));
	}

	function logBytes25(bytes25 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes25)", p0));
	}

	function logBytes26(bytes26 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes26)", p0));
	}

	function logBytes27(bytes27 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes27)", p0));
	}

	function logBytes28(bytes28 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes28)", p0));
	}

	function logBytes29(bytes29 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes29)", p0));
	}

	function logBytes30(bytes30 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes30)", p0));
	}

	function logBytes31(bytes31 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes31)", p0));
	}

	function logBytes32(bytes32 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes32)", p0));
	}

	function log(uint256 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256)", p0));
	}

	function log(string memory p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string)", p0));
	}

	function log(bool p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool)", p0));
	}

	function log(address p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address)", p0));
	}

	function log(uint256 p0, uint256 p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,uint256)", p0, p1));
	}

	function log(uint256 p0, string memory p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,string)", p0, p1));
	}

	function log(uint256 p0, bool p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,bool)", p0, p1));
	}

	function log(uint256 p0, address p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,address)", p0, p1));
	}

	function log(string memory p0, uint256 p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint256)", p0, p1));
	}

	function log(string memory p0, string memory p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string)", p0, p1));
	}

	function log(string memory p0, bool p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool)", p0, p1));
	}

	function log(string memory p0, address p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address)", p0, p1));
	}

	function log(bool p0, uint256 p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint256)", p0, p1));
	}

	function log(bool p0, string memory p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string)", p0, p1));
	}

	function log(bool p0, bool p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool)", p0, p1));
	}

	function log(bool p0, address p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address)", p0, p1));
	}

	function log(address p0, uint256 p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint256)", p0, p1));
	}

	function log(address p0, string memory p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string)", p0, p1));
	}

	function log(address p0, bool p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool)", p0, p1));
	}

	function log(address p0, address p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address)", p0, p1));
	}

	function log(uint256 p0, uint256 p1, uint256 p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,uint256,uint256)", p0, p1, p2));
	}

	function log(uint256 p0, uint256 p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,uint256,string)", p0, p1, p2));
	}

	function log(uint256 p0, uint256 p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,uint256,bool)", p0, p1, p2));
	}

	function log(uint256 p0, uint256 p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,uint256,address)", p0, p1, p2));
	}

	function log(uint256 p0, string memory p1, uint256 p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,string,uint256)", p0, p1, p2));
	}

	function log(uint256 p0, string memory p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,string,string)", p0, p1, p2));
	}

	function log(uint256 p0, string memory p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,string,bool)", p0, p1, p2));
	}

	function log(uint256 p0, string memory p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,string,address)", p0, p1, p2));
	}

	function log(uint256 p0, bool p1, uint256 p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,bool,uint256)", p0, p1, p2));
	}

	function log(uint256 p0, bool p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,bool,string)", p0, p1, p2));
	}

	function log(uint256 p0, bool p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,bool,bool)", p0, p1, p2));
	}

	function log(uint256 p0, bool p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,bool,address)", p0, p1, p2));
	}

	function log(uint256 p0, address p1, uint256 p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,address,uint256)", p0, p1, p2));
	}

	function log(uint256 p0, address p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,address,string)", p0, p1, p2));
	}

	function log(uint256 p0, address p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,address,bool)", p0, p1, p2));
	}

	function log(uint256 p0, address p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,address,address)", p0, p1, p2));
	}

	function log(string memory p0, uint256 p1, uint256 p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint256,uint256)", p0, p1, p2));
	}

	function log(string memory p0, uint256 p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint256,string)", p0, p1, p2));
	}

	function log(string memory p0, uint256 p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint256,bool)", p0, p1, p2));
	}

	function log(string memory p0, uint256 p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint256,address)", p0, p1, p2));
	}

	function log(string memory p0, string memory p1, uint256 p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,uint256)", p0, p1, p2));
	}

	function log(string memory p0, string memory p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,string)", p0, p1, p2));
	}

	function log(string memory p0, string memory p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,bool)", p0, p1, p2));
	}

	function log(string memory p0, string memory p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,address)", p0, p1, p2));
	}

	function log(string memory p0, bool p1, uint256 p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,uint256)", p0, p1, p2));
	}

	function log(string memory p0, bool p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,string)", p0, p1, p2));
	}

	function log(string memory p0, bool p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,bool)", p0, p1, p2));
	}

	function log(string memory p0, bool p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,address)", p0, p1, p2));
	}

	function log(string memory p0, address p1, uint256 p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,uint256)", p0, p1, p2));
	}

	function log(string memory p0, address p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,string)", p0, p1, p2));
	}

	function log(string memory p0, address p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,bool)", p0, p1, p2));
	}

	function log(string memory p0, address p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,address)", p0, p1, p2));
	}

	function log(bool p0, uint256 p1, uint256 p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint256,uint256)", p0, p1, p2));
	}

	function log(bool p0, uint256 p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint256,string)", p0, p1, p2));
	}

	function log(bool p0, uint256 p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint256,bool)", p0, p1, p2));
	}

	function log(bool p0, uint256 p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint256,address)", p0, p1, p2));
	}

	function log(bool p0, string memory p1, uint256 p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,uint256)", p0, p1, p2));
	}

	function log(bool p0, string memory p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,string)", p0, p1, p2));
	}

	function log(bool p0, string memory p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,bool)", p0, p1, p2));
	}

	function log(bool p0, string memory p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,address)", p0, p1, p2));
	}

	function log(bool p0, bool p1, uint256 p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,uint256)", p0, p1, p2));
	}

	function log(bool p0, bool p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,string)", p0, p1, p2));
	}

	function log(bool p0, bool p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,bool)", p0, p1, p2));
	}

	function log(bool p0, bool p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,address)", p0, p1, p2));
	}

	function log(bool p0, address p1, uint256 p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,uint256)", p0, p1, p2));
	}

	function log(bool p0, address p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,string)", p0, p1, p2));
	}

	function log(bool p0, address p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,bool)", p0, p1, p2));
	}

	function log(bool p0, address p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,address)", p0, p1, p2));
	}

	function log(address p0, uint256 p1, uint256 p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint256,uint256)", p0, p1, p2));
	}

	function log(address p0, uint256 p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint256,string)", p0, p1, p2));
	}

	function log(address p0, uint256 p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint256,bool)", p0, p1, p2));
	}

	function log(address p0, uint256 p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint256,address)", p0, p1, p2));
	}

	function log(address p0, string memory p1, uint256 p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,uint256)", p0, p1, p2));
	}

	function log(address p0, string memory p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,string)", p0, p1, p2));
	}

	function log(address p0, string memory p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,bool)", p0, p1, p2));
	}

	function log(address p0, string memory p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,address)", p0, p1, p2));
	}

	function log(address p0, bool p1, uint256 p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,uint256)", p0, p1, p2));
	}

	function log(address p0, bool p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,string)", p0, p1, p2));
	}

	function log(address p0, bool p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,bool)", p0, p1, p2));
	}

	function log(address p0, bool p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,address)", p0, p1, p2));
	}

	function log(address p0, address p1, uint256 p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,uint256)", p0, p1, p2));
	}

	function log(address p0, address p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,string)", p0, p1, p2));
	}

	function log(address p0, address p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,bool)", p0, p1, p2));
	}

	function log(address p0, address p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,address)", p0, p1, p2));
	}

	function log(uint256 p0, uint256 p1, uint256 p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,uint256,uint256,uint256)", p0, p1, p2, p3));
	}

	function log(uint256 p0, uint256 p1, uint256 p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,uint256,uint256,string)", p0, p1, p2, p3));
	}

	function log(uint256 p0, uint256 p1, uint256 p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,uint256,uint256,bool)", p0, p1, p2, p3));
	}

	function log(uint256 p0, uint256 p1, uint256 p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,uint256,uint256,address)", p0, p1, p2, p3));
	}

	function log(uint256 p0, uint256 p1, string memory p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,uint256,string,uint256)", p0, p1, p2, p3));
	}

	function log(uint256 p0, uint256 p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,uint256,string,string)", p0, p1, p2, p3));
	}

	function log(uint256 p0, uint256 p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,uint256,string,bool)", p0, p1, p2, p3));
	}

	function log(uint256 p0, uint256 p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,uint256,string,address)", p0, p1, p2, p3));
	}

	function log(uint256 p0, uint256 p1, bool p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,uint256,bool,uint256)", p0, p1, p2, p3));
	}

	function log(uint256 p0, uint256 p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,uint256,bool,string)", p0, p1, p2, p3));
	}

	function log(uint256 p0, uint256 p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,uint256,bool,bool)", p0, p1, p2, p3));
	}

	function log(uint256 p0, uint256 p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,uint256,bool,address)", p0, p1, p2, p3));
	}

	function log(uint256 p0, uint256 p1, address p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,uint256,address,uint256)", p0, p1, p2, p3));
	}

	function log(uint256 p0, uint256 p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,uint256,address,string)", p0, p1, p2, p3));
	}

	function log(uint256 p0, uint256 p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,uint256,address,bool)", p0, p1, p2, p3));
	}

	function log(uint256 p0, uint256 p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,uint256,address,address)", p0, p1, p2, p3));
	}

	function log(uint256 p0, string memory p1, uint256 p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,string,uint256,uint256)", p0, p1, p2, p3));
	}

	function log(uint256 p0, string memory p1, uint256 p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,string,uint256,string)", p0, p1, p2, p3));
	}

	function log(uint256 p0, string memory p1, uint256 p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,string,uint256,bool)", p0, p1, p2, p3));
	}

	function log(uint256 p0, string memory p1, uint256 p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,string,uint256,address)", p0, p1, p2, p3));
	}

	function log(uint256 p0, string memory p1, string memory p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,string,string,uint256)", p0, p1, p2, p3));
	}

	function log(uint256 p0, string memory p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,string,string,string)", p0, p1, p2, p3));
	}

	function log(uint256 p0, string memory p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,string,string,bool)", p0, p1, p2, p3));
	}

	function log(uint256 p0, string memory p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,string,string,address)", p0, p1, p2, p3));
	}

	function log(uint256 p0, string memory p1, bool p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,string,bool,uint256)", p0, p1, p2, p3));
	}

	function log(uint256 p0, string memory p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,string,bool,string)", p0, p1, p2, p3));
	}

	function log(uint256 p0, string memory p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,string,bool,bool)", p0, p1, p2, p3));
	}

	function log(uint256 p0, string memory p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,string,bool,address)", p0, p1, p2, p3));
	}

	function log(uint256 p0, string memory p1, address p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,string,address,uint256)", p0, p1, p2, p3));
	}

	function log(uint256 p0, string memory p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,string,address,string)", p0, p1, p2, p3));
	}

	function log(uint256 p0, string memory p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,string,address,bool)", p0, p1, p2, p3));
	}

	function log(uint256 p0, string memory p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,string,address,address)", p0, p1, p2, p3));
	}

	function log(uint256 p0, bool p1, uint256 p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,bool,uint256,uint256)", p0, p1, p2, p3));
	}

	function log(uint256 p0, bool p1, uint256 p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,bool,uint256,string)", p0, p1, p2, p3));
	}

	function log(uint256 p0, bool p1, uint256 p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,bool,uint256,bool)", p0, p1, p2, p3));
	}

	function log(uint256 p0, bool p1, uint256 p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,bool,uint256,address)", p0, p1, p2, p3));
	}

	function log(uint256 p0, bool p1, string memory p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,bool,string,uint256)", p0, p1, p2, p3));
	}

	function log(uint256 p0, bool p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,bool,string,string)", p0, p1, p2, p3));
	}

	function log(uint256 p0, bool p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,bool,string,bool)", p0, p1, p2, p3));
	}

	function log(uint256 p0, bool p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,bool,string,address)", p0, p1, p2, p3));
	}

	function log(uint256 p0, bool p1, bool p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,bool,bool,uint256)", p0, p1, p2, p3));
	}

	function log(uint256 p0, bool p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,bool,bool,string)", p0, p1, p2, p3));
	}

	function log(uint256 p0, bool p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,bool,bool,bool)", p0, p1, p2, p3));
	}

	function log(uint256 p0, bool p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,bool,bool,address)", p0, p1, p2, p3));
	}

	function log(uint256 p0, bool p1, address p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,bool,address,uint256)", p0, p1, p2, p3));
	}

	function log(uint256 p0, bool p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,bool,address,string)", p0, p1, p2, p3));
	}

	function log(uint256 p0, bool p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,bool,address,bool)", p0, p1, p2, p3));
	}

	function log(uint256 p0, bool p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,bool,address,address)", p0, p1, p2, p3));
	}

	function log(uint256 p0, address p1, uint256 p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,address,uint256,uint256)", p0, p1, p2, p3));
	}

	function log(uint256 p0, address p1, uint256 p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,address,uint256,string)", p0, p1, p2, p3));
	}

	function log(uint256 p0, address p1, uint256 p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,address,uint256,bool)", p0, p1, p2, p3));
	}

	function log(uint256 p0, address p1, uint256 p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,address,uint256,address)", p0, p1, p2, p3));
	}

	function log(uint256 p0, address p1, string memory p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,address,string,uint256)", p0, p1, p2, p3));
	}

	function log(uint256 p0, address p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,address,string,string)", p0, p1, p2, p3));
	}

	function log(uint256 p0, address p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,address,string,bool)", p0, p1, p2, p3));
	}

	function log(uint256 p0, address p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,address,string,address)", p0, p1, p2, p3));
	}

	function log(uint256 p0, address p1, bool p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,address,bool,uint256)", p0, p1, p2, p3));
	}

	function log(uint256 p0, address p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,address,bool,string)", p0, p1, p2, p3));
	}

	function log(uint256 p0, address p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,address,bool,bool)", p0, p1, p2, p3));
	}

	function log(uint256 p0, address p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,address,bool,address)", p0, p1, p2, p3));
	}

	function log(uint256 p0, address p1, address p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,address,address,uint256)", p0, p1, p2, p3));
	}

	function log(uint256 p0, address p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,address,address,string)", p0, p1, p2, p3));
	}

	function log(uint256 p0, address p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,address,address,bool)", p0, p1, p2, p3));
	}

	function log(uint256 p0, address p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,address,address,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint256 p1, uint256 p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint256,uint256,uint256)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint256 p1, uint256 p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint256,uint256,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint256 p1, uint256 p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint256,uint256,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint256 p1, uint256 p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint256,uint256,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint256 p1, string memory p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint256,string,uint256)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint256 p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint256,string,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint256 p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint256,string,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint256 p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint256,string,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint256 p1, bool p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint256,bool,uint256)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint256 p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint256,bool,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint256 p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint256,bool,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint256 p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint256,bool,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint256 p1, address p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint256,address,uint256)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint256 p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint256,address,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint256 p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint256,address,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint256 p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint256,address,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, uint256 p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,uint256,uint256)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, uint256 p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,uint256,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, uint256 p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,uint256,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, uint256 p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,uint256,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, string memory p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,string,uint256)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,string,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,string,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,string,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, bool p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,bool,uint256)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,bool,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,bool,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,bool,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, address p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,address,uint256)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,address,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,address,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,address,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, uint256 p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,uint256,uint256)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, uint256 p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,uint256,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, uint256 p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,uint256,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, uint256 p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,uint256,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, string memory p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,string,uint256)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,string,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,string,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,string,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, bool p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,bool,uint256)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,bool,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,bool,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,bool,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, address p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,address,uint256)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,address,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,address,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,address,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, uint256 p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,uint256,uint256)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, uint256 p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,uint256,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, uint256 p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,uint256,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, uint256 p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,uint256,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, string memory p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,string,uint256)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,string,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,string,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,string,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, bool p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,bool,uint256)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,bool,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,bool,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,bool,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, address p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,address,uint256)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,address,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,address,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,address,address)", p0, p1, p2, p3));
	}

	function log(bool p0, uint256 p1, uint256 p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint256,uint256,uint256)", p0, p1, p2, p3));
	}

	function log(bool p0, uint256 p1, uint256 p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint256,uint256,string)", p0, p1, p2, p3));
	}

	function log(bool p0, uint256 p1, uint256 p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint256,uint256,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, uint256 p1, uint256 p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint256,uint256,address)", p0, p1, p2, p3));
	}

	function log(bool p0, uint256 p1, string memory p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint256,string,uint256)", p0, p1, p2, p3));
	}

	function log(bool p0, uint256 p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint256,string,string)", p0, p1, p2, p3));
	}

	function log(bool p0, uint256 p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint256,string,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, uint256 p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint256,string,address)", p0, p1, p2, p3));
	}

	function log(bool p0, uint256 p1, bool p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint256,bool,uint256)", p0, p1, p2, p3));
	}

	function log(bool p0, uint256 p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint256,bool,string)", p0, p1, p2, p3));
	}

	function log(bool p0, uint256 p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint256,bool,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, uint256 p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint256,bool,address)", p0, p1, p2, p3));
	}

	function log(bool p0, uint256 p1, address p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint256,address,uint256)", p0, p1, p2, p3));
	}

	function log(bool p0, uint256 p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint256,address,string)", p0, p1, p2, p3));
	}

	function log(bool p0, uint256 p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint256,address,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, uint256 p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint256,address,address)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, uint256 p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,uint256,uint256)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, uint256 p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,uint256,string)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, uint256 p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,uint256,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, uint256 p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,uint256,address)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, string memory p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,string,uint256)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,string,string)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,string,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,string,address)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, bool p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,bool,uint256)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,bool,string)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,bool,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,bool,address)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, address p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,address,uint256)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,address,string)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,address,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,address,address)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, uint256 p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,uint256,uint256)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, uint256 p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,uint256,string)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, uint256 p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,uint256,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, uint256 p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,uint256,address)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, string memory p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,string,uint256)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,string,string)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,string,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,string,address)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, bool p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,bool,uint256)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,bool,string)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,bool,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,bool,address)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, address p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,address,uint256)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,address,string)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,address,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,address,address)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, uint256 p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,uint256,uint256)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, uint256 p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,uint256,string)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, uint256 p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,uint256,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, uint256 p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,uint256,address)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, string memory p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,string,uint256)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,string,string)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,string,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,string,address)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, bool p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,bool,uint256)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,bool,string)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,bool,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,bool,address)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, address p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,address,uint256)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,address,string)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,address,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,address,address)", p0, p1, p2, p3));
	}

	function log(address p0, uint256 p1, uint256 p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint256,uint256,uint256)", p0, p1, p2, p3));
	}

	function log(address p0, uint256 p1, uint256 p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint256,uint256,string)", p0, p1, p2, p3));
	}

	function log(address p0, uint256 p1, uint256 p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint256,uint256,bool)", p0, p1, p2, p3));
	}

	function log(address p0, uint256 p1, uint256 p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint256,uint256,address)", p0, p1, p2, p3));
	}

	function log(address p0, uint256 p1, string memory p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint256,string,uint256)", p0, p1, p2, p3));
	}

	function log(address p0, uint256 p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint256,string,string)", p0, p1, p2, p3));
	}

	function log(address p0, uint256 p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint256,string,bool)", p0, p1, p2, p3));
	}

	function log(address p0, uint256 p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint256,string,address)", p0, p1, p2, p3));
	}

	function log(address p0, uint256 p1, bool p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint256,bool,uint256)", p0, p1, p2, p3));
	}

	function log(address p0, uint256 p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint256,bool,string)", p0, p1, p2, p3));
	}

	function log(address p0, uint256 p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint256,bool,bool)", p0, p1, p2, p3));
	}

	function log(address p0, uint256 p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint256,bool,address)", p0, p1, p2, p3));
	}

	function log(address p0, uint256 p1, address p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint256,address,uint256)", p0, p1, p2, p3));
	}

	function log(address p0, uint256 p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint256,address,string)", p0, p1, p2, p3));
	}

	function log(address p0, uint256 p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint256,address,bool)", p0, p1, p2, p3));
	}

	function log(address p0, uint256 p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint256,address,address)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, uint256 p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,uint256,uint256)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, uint256 p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,uint256,string)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, uint256 p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,uint256,bool)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, uint256 p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,uint256,address)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, string memory p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,string,uint256)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,string,string)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,string,bool)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,string,address)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, bool p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,bool,uint256)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,bool,string)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,bool,bool)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,bool,address)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, address p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,address,uint256)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,address,string)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,address,bool)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,address,address)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, uint256 p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,uint256,uint256)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, uint256 p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,uint256,string)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, uint256 p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,uint256,bool)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, uint256 p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,uint256,address)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, string memory p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,string,uint256)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,string,string)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,string,bool)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,string,address)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, bool p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,bool,uint256)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,bool,string)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,bool,bool)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,bool,address)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, address p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,address,uint256)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,address,string)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,address,bool)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,address,address)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, uint256 p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,uint256,uint256)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, uint256 p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,uint256,string)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, uint256 p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,uint256,bool)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, uint256 p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,uint256,address)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, string memory p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,string,uint256)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,string,string)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,string,bool)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,string,address)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, bool p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,bool,uint256)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,bool,string)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,bool,bool)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,bool,address)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, address p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,address,uint256)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,address,string)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,address,bool)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,address,address)", p0, p1, p2, p3));
	}

}
