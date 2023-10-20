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
// OpenZeppelin Contracts v4.4.1 (interfaces/IERC20Metadata.sol)

pragma solidity ^0.8.0;

import "../token/ERC20/extensions/IERC20Metadata.sol";
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
// OpenZeppelin Contracts (last updated v4.9.3) (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";
import "../extensions/IERC20Permit.sol";
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
// OpenZeppelin Contracts (last updated v4.9.0) (utils/cryptography/ECDSA.sol)

pragma solidity ^0.8.0;

import "../Strings.sol";

/**
 * @dev Elliptic Curve Digital Signature Algorithm (ECDSA) operations.
 *
 * These functions can be used to verify that a message was signed by the holder
 * of the private keys of a given address.
 */
library ECDSA {
    enum RecoverError {
        NoError,
        InvalidSignature,
        InvalidSignatureLength,
        InvalidSignatureS,
        InvalidSignatureV // Deprecated in v4.8
    }

    function _throwError(RecoverError error) private pure {
        if (error == RecoverError.NoError) {
            return; // no error: do nothing
        } else if (error == RecoverError.InvalidSignature) {
            revert("ECDSA: invalid signature");
        } else if (error == RecoverError.InvalidSignatureLength) {
            revert("ECDSA: invalid signature length");
        } else if (error == RecoverError.InvalidSignatureS) {
            revert("ECDSA: invalid signature 's' value");
        }
    }

    /**
     * @dev Returns the address that signed a hashed message (`hash`) with
     * `signature` or error string. This address can then be used for verification purposes.
     *
     * The `ecrecover` EVM opcode allows for malleable (non-unique) signatures:
     * this function rejects them by requiring the `s` value to be in the lower
     * half order, and the `v` value to be either 27 or 28.
     *
     * IMPORTANT: `hash` _must_ be the result of a hash operation for the
     * verification to be secure: it is possible to craft signatures that
     * recover to arbitrary addresses for non-hashed data. A safe way to ensure
     * this is by receiving a hash of the original message (which may otherwise
     * be too long), and then calling {toEthSignedMessageHash} on it.
     *
     * Documentation for signature generation:
     * - with https://web3js.readthedocs.io/en/v1.3.4/web3-eth-accounts.html#sign[Web3.js]
     * - with https://docs.ethers.io/v5/api/signer/#Signer-signMessage[ethers]
     *
     * _Available since v4.3._
     */
    function tryRecover(bytes32 hash, bytes memory signature) internal pure returns (address, RecoverError) {
        if (signature.length == 65) {
            bytes32 r;
            bytes32 s;
            uint8 v;
            // ecrecover takes the signature parameters, and the only way to get them
            // currently is to use assembly.
            /// @solidity memory-safe-assembly
            assembly {
                r := mload(add(signature, 0x20))
                s := mload(add(signature, 0x40))
                v := byte(0, mload(add(signature, 0x60)))
            }
            return tryRecover(hash, v, r, s);
        } else {
            return (address(0), RecoverError.InvalidSignatureLength);
        }
    }

    /**
     * @dev Returns the address that signed a hashed message (`hash`) with
     * `signature`. This address can then be used for verification purposes.
     *
     * The `ecrecover` EVM opcode allows for malleable (non-unique) signatures:
     * this function rejects them by requiring the `s` value to be in the lower
     * half order, and the `v` value to be either 27 or 28.
     *
     * IMPORTANT: `hash` _must_ be the result of a hash operation for the
     * verification to be secure: it is possible to craft signatures that
     * recover to arbitrary addresses for non-hashed data. A safe way to ensure
     * this is by receiving a hash of the original message (which may otherwise
     * be too long), and then calling {toEthSignedMessageHash} on it.
     */
    function recover(bytes32 hash, bytes memory signature) internal pure returns (address) {
        (address recovered, RecoverError error) = tryRecover(hash, signature);
        _throwError(error);
        return recovered;
    }

    /**
     * @dev Overload of {ECDSA-tryRecover} that receives the `r` and `vs` short-signature fields separately.
     *
     * See https://eips.ethereum.org/EIPS/eip-2098[EIP-2098 short signatures]
     *
     * _Available since v4.3._
     */
    function tryRecover(bytes32 hash, bytes32 r, bytes32 vs) internal pure returns (address, RecoverError) {
        bytes32 s = vs & bytes32(0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff);
        uint8 v = uint8((uint256(vs) >> 255) + 27);
        return tryRecover(hash, v, r, s);
    }

    /**
     * @dev Overload of {ECDSA-recover} that receives the `r and `vs` short-signature fields separately.
     *
     * _Available since v4.2._
     */
    function recover(bytes32 hash, bytes32 r, bytes32 vs) internal pure returns (address) {
        (address recovered, RecoverError error) = tryRecover(hash, r, vs);
        _throwError(error);
        return recovered;
    }

    /**
     * @dev Overload of {ECDSA-tryRecover} that receives the `v`,
     * `r` and `s` signature fields separately.
     *
     * _Available since v4.3._
     */
    function tryRecover(bytes32 hash, uint8 v, bytes32 r, bytes32 s) internal pure returns (address, RecoverError) {
        // EIP-2 still allows signature malleability for ecrecover(). Remove this possibility and make the signature
        // unique. Appendix F in the Ethereum Yellow paper (https://ethereum.github.io/yellowpaper/paper.pdf), defines
        // the valid range for s in (301): 0 < s < secp256k1n ÷ 2 + 1, and for v in (302): v ∈ {27, 28}. Most
        // signatures from current libraries generate a unique signature with an s-value in the lower half order.
        //
        // If your library generates malleable signatures, such as s-values in the upper range, calculate a new s-value
        // with 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141 - s1 and flip v from 27 to 28 or
        // vice versa. If your library also generates signatures with 0/1 for v instead 27/28, add 27 to v to accept
        // these malleable signatures as well.
        if (uint256(s) > 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0) {
            return (address(0), RecoverError.InvalidSignatureS);
        }

        // If the signature is valid (and not malleable), return the signer address
        address signer = ecrecover(hash, v, r, s);
        if (signer == address(0)) {
            return (address(0), RecoverError.InvalidSignature);
        }

        return (signer, RecoverError.NoError);
    }

    /**
     * @dev Overload of {ECDSA-recover} that receives the `v`,
     * `r` and `s` signature fields separately.
     */
    function recover(bytes32 hash, uint8 v, bytes32 r, bytes32 s) internal pure returns (address) {
        (address recovered, RecoverError error) = tryRecover(hash, v, r, s);
        _throwError(error);
        return recovered;
    }

    /**
     * @dev Returns an Ethereum Signed Message, created from a `hash`. This
     * produces hash corresponding to the one signed with the
     * https://eth.wiki/json-rpc/API#eth_sign[`eth_sign`]
     * JSON-RPC method as part of EIP-191.
     *
     * See {recover}.
     */
    function toEthSignedMessageHash(bytes32 hash) internal pure returns (bytes32 message) {
        // 32 is the length in bytes of hash,
        // enforced by the type signature above
        /// @solidity memory-safe-assembly
        assembly {
            mstore(0x00, "\x19Ethereum Signed Message:\n32")
            mstore(0x1c, hash)
            message := keccak256(0x00, 0x3c)
        }
    }

    /**
     * @dev Returns an Ethereum Signed Message, created from `s`. This
     * produces hash corresponding to the one signed with the
     * https://eth.wiki/json-rpc/API#eth_sign[`eth_sign`]
     * JSON-RPC method as part of EIP-191.
     *
     * See {recover}.
     */
    function toEthSignedMessageHash(bytes memory s) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n", Strings.toString(s.length), s));
    }

    /**
     * @dev Returns an Ethereum Signed Typed Data, created from a
     * `domainSeparator` and a `structHash`. This produces hash corresponding
     * to the one signed with the
     * https://eips.ethereum.org/EIPS/eip-712[`eth_signTypedData`]
     * JSON-RPC method as part of EIP-712.
     *
     * See {recover}.
     */
    function toTypedDataHash(bytes32 domainSeparator, bytes32 structHash) internal pure returns (bytes32 data) {
        /// @solidity memory-safe-assembly
        assembly {
            let ptr := mload(0x40)
            mstore(ptr, "\x19\x01")
            mstore(add(ptr, 0x02), domainSeparator)
            mstore(add(ptr, 0x22), structHash)
            data := keccak256(ptr, 0x42)
        }
    }

    /**
     * @dev Returns an Ethereum Signed Data with intended validator, created from a
     * `validator` and `data` according to the version 0 of EIP-191.
     *
     * See {recover}.
     */
    function toDataWithIntendedValidatorHash(address validator, bytes memory data) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19\x00", validator, data));
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.2) (utils/cryptography/MerkleProof.sol)

pragma solidity ^0.8.0;

/**
 * @dev These functions deal with verification of Merkle Tree proofs.
 *
 * The tree and the proofs can be generated using our
 * https://github.com/OpenZeppelin/merkle-tree[JavaScript library].
 * You will find a quickstart guide in the readme.
 *
 * WARNING: You should avoid using leaf values that are 64 bytes long prior to
 * hashing, or use a hash function other than keccak256 for hashing leaves.
 * This is because the concatenation of a sorted pair of internal nodes in
 * the merkle tree could be reinterpreted as a leaf value.
 * OpenZeppelin's JavaScript library generates merkle trees that are safe
 * against this attack out of the box.
 */
library MerkleProof {
    /**
     * @dev Returns true if a `leaf` can be proved to be a part of a Merkle tree
     * defined by `root`. For this, a `proof` must be provided, containing
     * sibling hashes on the branch from the leaf to the root of the tree. Each
     * pair of leaves and each pair of pre-images are assumed to be sorted.
     */
    function verify(bytes32[] memory proof, bytes32 root, bytes32 leaf) internal pure returns (bool) {
        return processProof(proof, leaf) == root;
    }

    /**
     * @dev Calldata version of {verify}
     *
     * _Available since v4.7._
     */
    function verifyCalldata(bytes32[] calldata proof, bytes32 root, bytes32 leaf) internal pure returns (bool) {
        return processProofCalldata(proof, leaf) == root;
    }

    /**
     * @dev Returns the rebuilt hash obtained by traversing a Merkle tree up
     * from `leaf` using `proof`. A `proof` is valid if and only if the rebuilt
     * hash matches the root of the tree. When processing the proof, the pairs
     * of leafs & pre-images are assumed to be sorted.
     *
     * _Available since v4.4._
     */
    function processProof(bytes32[] memory proof, bytes32 leaf) internal pure returns (bytes32) {
        bytes32 computedHash = leaf;
        for (uint256 i = 0; i < proof.length; i++) {
            computedHash = _hashPair(computedHash, proof[i]);
        }
        return computedHash;
    }

    /**
     * @dev Calldata version of {processProof}
     *
     * _Available since v4.7._
     */
    function processProofCalldata(bytes32[] calldata proof, bytes32 leaf) internal pure returns (bytes32) {
        bytes32 computedHash = leaf;
        for (uint256 i = 0; i < proof.length; i++) {
            computedHash = _hashPair(computedHash, proof[i]);
        }
        return computedHash;
    }

    /**
     * @dev Returns true if the `leaves` can be simultaneously proven to be a part of a merkle tree defined by
     * `root`, according to `proof` and `proofFlags` as described in {processMultiProof}.
     *
     * CAUTION: Not all merkle trees admit multiproofs. See {processMultiProof} for details.
     *
     * _Available since v4.7._
     */
    function multiProofVerify(
        bytes32[] memory proof,
        bool[] memory proofFlags,
        bytes32 root,
        bytes32[] memory leaves
    ) internal pure returns (bool) {
        return processMultiProof(proof, proofFlags, leaves) == root;
    }

    /**
     * @dev Calldata version of {multiProofVerify}
     *
     * CAUTION: Not all merkle trees admit multiproofs. See {processMultiProof} for details.
     *
     * _Available since v4.7._
     */
    function multiProofVerifyCalldata(
        bytes32[] calldata proof,
        bool[] calldata proofFlags,
        bytes32 root,
        bytes32[] memory leaves
    ) internal pure returns (bool) {
        return processMultiProofCalldata(proof, proofFlags, leaves) == root;
    }

    /**
     * @dev Returns the root of a tree reconstructed from `leaves` and sibling nodes in `proof`. The reconstruction
     * proceeds by incrementally reconstructing all inner nodes by combining a leaf/inner node with either another
     * leaf/inner node or a proof sibling node, depending on whether each `proofFlags` item is true or false
     * respectively.
     *
     * CAUTION: Not all merkle trees admit multiproofs. To use multiproofs, it is sufficient to ensure that: 1) the tree
     * is complete (but not necessarily perfect), 2) the leaves to be proven are in the opposite order they are in the
     * tree (i.e., as seen from right to left starting at the deepest layer and continuing at the next layer).
     *
     * _Available since v4.7._
     */
    function processMultiProof(
        bytes32[] memory proof,
        bool[] memory proofFlags,
        bytes32[] memory leaves
    ) internal pure returns (bytes32 merkleRoot) {
        // This function rebuilds the root hash by traversing the tree up from the leaves. The root is rebuilt by
        // consuming and producing values on a queue. The queue starts with the `leaves` array, then goes onto the
        // `hashes` array. At the end of the process, the last hash in the `hashes` array should contain the root of
        // the merkle tree.
        uint256 leavesLen = leaves.length;
        uint256 proofLen = proof.length;
        uint256 totalHashes = proofFlags.length;

        // Check proof validity.
        require(leavesLen + proofLen - 1 == totalHashes, "MerkleProof: invalid multiproof");

        // The xxxPos values are "pointers" to the next value to consume in each array. All accesses are done using
        // `xxx[xxxPos++]`, which return the current value and increment the pointer, thus mimicking a queue's "pop".
        bytes32[] memory hashes = new bytes32[](totalHashes);
        uint256 leafPos = 0;
        uint256 hashPos = 0;
        uint256 proofPos = 0;
        // At each step, we compute the next hash using two values:
        // - a value from the "main queue". If not all leaves have been consumed, we get the next leaf, otherwise we
        //   get the next hash.
        // - depending on the flag, either another value from the "main queue" (merging branches) or an element from the
        //   `proof` array.
        for (uint256 i = 0; i < totalHashes; i++) {
            bytes32 a = leafPos < leavesLen ? leaves[leafPos++] : hashes[hashPos++];
            bytes32 b = proofFlags[i]
                ? (leafPos < leavesLen ? leaves[leafPos++] : hashes[hashPos++])
                : proof[proofPos++];
            hashes[i] = _hashPair(a, b);
        }

        if (totalHashes > 0) {
            require(proofPos == proofLen, "MerkleProof: invalid multiproof");
            unchecked {
                return hashes[totalHashes - 1];
            }
        } else if (leavesLen > 0) {
            return leaves[0];
        } else {
            return proof[0];
        }
    }

    /**
     * @dev Calldata version of {processMultiProof}.
     *
     * CAUTION: Not all merkle trees admit multiproofs. See {processMultiProof} for details.
     *
     * _Available since v4.7._
     */
    function processMultiProofCalldata(
        bytes32[] calldata proof,
        bool[] calldata proofFlags,
        bytes32[] memory leaves
    ) internal pure returns (bytes32 merkleRoot) {
        // This function rebuilds the root hash by traversing the tree up from the leaves. The root is rebuilt by
        // consuming and producing values on a queue. The queue starts with the `leaves` array, then goes onto the
        // `hashes` array. At the end of the process, the last hash in the `hashes` array should contain the root of
        // the merkle tree.
        uint256 leavesLen = leaves.length;
        uint256 proofLen = proof.length;
        uint256 totalHashes = proofFlags.length;

        // Check proof validity.
        require(leavesLen + proofLen - 1 == totalHashes, "MerkleProof: invalid multiproof");

        // The xxxPos values are "pointers" to the next value to consume in each array. All accesses are done using
        // `xxx[xxxPos++]`, which return the current value and increment the pointer, thus mimicking a queue's "pop".
        bytes32[] memory hashes = new bytes32[](totalHashes);
        uint256 leafPos = 0;
        uint256 hashPos = 0;
        uint256 proofPos = 0;
        // At each step, we compute the next hash using two values:
        // - a value from the "main queue". If not all leaves have been consumed, we get the next leaf, otherwise we
        //   get the next hash.
        // - depending on the flag, either another value from the "main queue" (merging branches) or an element from the
        //   `proof` array.
        for (uint256 i = 0; i < totalHashes; i++) {
            bytes32 a = leafPos < leavesLen ? leaves[leafPos++] : hashes[hashPos++];
            bytes32 b = proofFlags[i]
                ? (leafPos < leavesLen ? leaves[leafPos++] : hashes[hashPos++])
                : proof[proofPos++];
            hashes[i] = _hashPair(a, b);
        }

        if (totalHashes > 0) {
            require(proofPos == proofLen, "MerkleProof: invalid multiproof");
            unchecked {
                return hashes[totalHashes - 1];
            }
        } else if (leavesLen > 0) {
            return leaves[0];
        } else {
            return proof[0];
        }
    }

    function _hashPair(bytes32 a, bytes32 b) private pure returns (bytes32) {
        return a < b ? _efficientHash(a, b) : _efficientHash(b, a);
    }

    function _efficientHash(bytes32 a, bytes32 b) private pure returns (bytes32 value) {
        /// @solidity memory-safe-assembly
        assembly {
            mstore(0x00, a)
            mstore(0x20, b)
            value := keccak256(0x00, 0x40)
        }
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (utils/math/Math.sol)

pragma solidity ^0.8.0;

/**
 * @dev Standard math utilities missing in the Solidity language.
 */
library Math {
    enum Rounding {
        Down, // Toward negative infinity
        Up, // Toward infinity
        Zero // Toward zero
    }

    /**
     * @dev Returns the largest of two numbers.
     */
    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a > b ? a : b;
    }

    /**
     * @dev Returns the smallest of two numbers.
     */
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    /**
     * @dev Returns the average of two numbers. The result is rounded towards
     * zero.
     */
    function average(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b) / 2 can overflow.
        return (a & b) + (a ^ b) / 2;
    }

    /**
     * @dev Returns the ceiling of the division of two numbers.
     *
     * This differs from standard division with `/` in that it rounds up instead
     * of rounding down.
     */
    function ceilDiv(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b - 1) / b can overflow on addition, so we distribute.
        return a == 0 ? 0 : (a - 1) / b + 1;
    }

    /**
     * @notice Calculates floor(x * y / denominator) with full precision. Throws if result overflows a uint256 or denominator == 0
     * @dev Original credit to Remco Bloemen under MIT license (https://xn--2-umb.com/21/muldiv)
     * with further edits by Uniswap Labs also under MIT license.
     */
    function mulDiv(uint256 x, uint256 y, uint256 denominator) internal pure returns (uint256 result) {
        unchecked {
            // 512-bit multiply [prod1 prod0] = x * y. Compute the product mod 2^256 and mod 2^256 - 1, then use
            // use the Chinese Remainder Theorem to reconstruct the 512 bit result. The result is stored in two 256
            // variables such that product = prod1 * 2^256 + prod0.
            uint256 prod0; // Least significant 256 bits of the product
            uint256 prod1; // Most significant 256 bits of the product
            assembly {
                let mm := mulmod(x, y, not(0))
                prod0 := mul(x, y)
                prod1 := sub(sub(mm, prod0), lt(mm, prod0))
            }

            // Handle non-overflow cases, 256 by 256 division.
            if (prod1 == 0) {
                // Solidity will revert if denominator == 0, unlike the div opcode on its own.
                // The surrounding unchecked block does not change this fact.
                // See https://docs.soliditylang.org/en/latest/control-structures.html#checked-or-unchecked-arithmetic.
                return prod0 / denominator;
            }

            // Make sure the result is less than 2^256. Also prevents denominator == 0.
            require(denominator > prod1, "Math: mulDiv overflow");

            ///////////////////////////////////////////////
            // 512 by 256 division.
            ///////////////////////////////////////////////

            // Make division exact by subtracting the remainder from [prod1 prod0].
            uint256 remainder;
            assembly {
                // Compute remainder using mulmod.
                remainder := mulmod(x, y, denominator)

                // Subtract 256 bit number from 512 bit number.
                prod1 := sub(prod1, gt(remainder, prod0))
                prod0 := sub(prod0, remainder)
            }

            // Factor powers of two out of denominator and compute largest power of two divisor of denominator. Always >= 1.
            // See https://cs.stackexchange.com/q/138556/92363.

            // Does not overflow because the denominator cannot be zero at this stage in the function.
            uint256 twos = denominator & (~denominator + 1);
            assembly {
                // Divide denominator by twos.
                denominator := div(denominator, twos)

                // Divide [prod1 prod0] by twos.
                prod0 := div(prod0, twos)

                // Flip twos such that it is 2^256 / twos. If twos is zero, then it becomes one.
                twos := add(div(sub(0, twos), twos), 1)
            }

            // Shift in bits from prod1 into prod0.
            prod0 |= prod1 * twos;

            // Invert denominator mod 2^256. Now that denominator is an odd number, it has an inverse modulo 2^256 such
            // that denominator * inv = 1 mod 2^256. Compute the inverse by starting with a seed that is correct for
            // four bits. That is, denominator * inv = 1 mod 2^4.
            uint256 inverse = (3 * denominator) ^ 2;

            // Use the Newton-Raphson iteration to improve the precision. Thanks to Hensel's lifting lemma, this also works
            // in modular arithmetic, doubling the correct bits in each step.
            inverse *= 2 - denominator * inverse; // inverse mod 2^8
            inverse *= 2 - denominator * inverse; // inverse mod 2^16
            inverse *= 2 - denominator * inverse; // inverse mod 2^32
            inverse *= 2 - denominator * inverse; // inverse mod 2^64
            inverse *= 2 - denominator * inverse; // inverse mod 2^128
            inverse *= 2 - denominator * inverse; // inverse mod 2^256

            // Because the division is now exact we can divide by multiplying with the modular inverse of denominator.
            // This will give us the correct result modulo 2^256. Since the preconditions guarantee that the outcome is
            // less than 2^256, this is the final result. We don't need to compute the high bits of the result and prod1
            // is no longer required.
            result = prod0 * inverse;
            return result;
        }
    }

    /**
     * @notice Calculates x * y / denominator with full precision, following the selected rounding direction.
     */
    function mulDiv(uint256 x, uint256 y, uint256 denominator, Rounding rounding) internal pure returns (uint256) {
        uint256 result = mulDiv(x, y, denominator);
        if (rounding == Rounding.Up && mulmod(x, y, denominator) > 0) {
            result += 1;
        }
        return result;
    }

    /**
     * @dev Returns the square root of a number. If the number is not a perfect square, the value is rounded down.
     *
     * Inspired by Henry S. Warren, Jr.'s "Hacker's Delight" (Chapter 11).
     */
    function sqrt(uint256 a) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        // For our first guess, we get the biggest power of 2 which is smaller than the square root of the target.
        //
        // We know that the "msb" (most significant bit) of our target number `a` is a power of 2 such that we have
        // `msb(a) <= a < 2*msb(a)`. This value can be written `msb(a)=2**k` with `k=log2(a)`.
        //
        // This can be rewritten `2**log2(a) <= a < 2**(log2(a) + 1)`
        // → `sqrt(2**k) <= sqrt(a) < sqrt(2**(k+1))`
        // → `2**(k/2) <= sqrt(a) < 2**((k+1)/2) <= 2**(k/2 + 1)`
        //
        // Consequently, `2**(log2(a) / 2)` is a good first approximation of `sqrt(a)` with at least 1 correct bit.
        uint256 result = 1 << (log2(a) >> 1);

        // At this point `result` is an estimation with one bit of precision. We know the true value is a uint128,
        // since it is the square root of a uint256. Newton's method converges quadratically (precision doubles at
        // every iteration). We thus need at most 7 iteration to turn our partial result with one bit of precision
        // into the expected uint128 result.
        unchecked {
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            return min(result, a / result);
        }
    }

    /**
     * @notice Calculates sqrt(a), following the selected rounding direction.
     */
    function sqrt(uint256 a, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = sqrt(a);
            return result + (rounding == Rounding.Up && result * result < a ? 1 : 0);
        }
    }

    /**
     * @dev Return the log in base 2, rounded down, of a positive value.
     * Returns 0 if given 0.
     */
    function log2(uint256 value) internal pure returns (uint256) {
        uint256 result = 0;
        unchecked {
            if (value >> 128 > 0) {
                value >>= 128;
                result += 128;
            }
            if (value >> 64 > 0) {
                value >>= 64;
                result += 64;
            }
            if (value >> 32 > 0) {
                value >>= 32;
                result += 32;
            }
            if (value >> 16 > 0) {
                value >>= 16;
                result += 16;
            }
            if (value >> 8 > 0) {
                value >>= 8;
                result += 8;
            }
            if (value >> 4 > 0) {
                value >>= 4;
                result += 4;
            }
            if (value >> 2 > 0) {
                value >>= 2;
                result += 2;
            }
            if (value >> 1 > 0) {
                result += 1;
            }
        }
        return result;
    }

    /**
     * @dev Return the log in base 2, following the selected rounding direction, of a positive value.
     * Returns 0 if given 0.
     */
    function log2(uint256 value, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = log2(value);
            return result + (rounding == Rounding.Up && 1 << result < value ? 1 : 0);
        }
    }

    /**
     * @dev Return the log in base 10, rounded down, of a positive value.
     * Returns 0 if given 0.
     */
    function log10(uint256 value) internal pure returns (uint256) {
        uint256 result = 0;
        unchecked {
            if (value >= 10 ** 64) {
                value /= 10 ** 64;
                result += 64;
            }
            if (value >= 10 ** 32) {
                value /= 10 ** 32;
                result += 32;
            }
            if (value >= 10 ** 16) {
                value /= 10 ** 16;
                result += 16;
            }
            if (value >= 10 ** 8) {
                value /= 10 ** 8;
                result += 8;
            }
            if (value >= 10 ** 4) {
                value /= 10 ** 4;
                result += 4;
            }
            if (value >= 10 ** 2) {
                value /= 10 ** 2;
                result += 2;
            }
            if (value >= 10 ** 1) {
                result += 1;
            }
        }
        return result;
    }

    /**
     * @dev Return the log in base 10, following the selected rounding direction, of a positive value.
     * Returns 0 if given 0.
     */
    function log10(uint256 value, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = log10(value);
            return result + (rounding == Rounding.Up && 10 ** result < value ? 1 : 0);
        }
    }

    /**
     * @dev Return the log in base 256, rounded down, of a positive value.
     * Returns 0 if given 0.
     *
     * Adding one to the result gives the number of pairs of hex symbols needed to represent `value` as a hex string.
     */
    function log256(uint256 value) internal pure returns (uint256) {
        uint256 result = 0;
        unchecked {
            if (value >> 128 > 0) {
                value >>= 128;
                result += 16;
            }
            if (value >> 64 > 0) {
                value >>= 64;
                result += 8;
            }
            if (value >> 32 > 0) {
                value >>= 32;
                result += 4;
            }
            if (value >> 16 > 0) {
                value >>= 16;
                result += 2;
            }
            if (value >> 8 > 0) {
                result += 1;
            }
        }
        return result;
    }

    /**
     * @dev Return the log in base 256, following the selected rounding direction, of a positive value.
     * Returns 0 if given 0.
     */
    function log256(uint256 value, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = log256(value);
            return result + (rounding == Rounding.Up && 1 << (result << 3) < value ? 1 : 0);
        }
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (utils/math/SignedMath.sol)

pragma solidity ^0.8.0;

/**
 * @dev Standard signed math utilities missing in the Solidity language.
 */
library SignedMath {
    /**
     * @dev Returns the largest of two signed numbers.
     */
    function max(int256 a, int256 b) internal pure returns (int256) {
        return a > b ? a : b;
    }

    /**
     * @dev Returns the smallest of two signed numbers.
     */
    function min(int256 a, int256 b) internal pure returns (int256) {
        return a < b ? a : b;
    }

    /**
     * @dev Returns the average of two signed numbers without overflow.
     * The result is rounded towards zero.
     */
    function average(int256 a, int256 b) internal pure returns (int256) {
        // Formula from the book "Hacker's Delight"
        int256 x = (a & b) + ((a ^ b) >> 1);
        return x + (int256(uint256(x) >> 255) & (a ^ b));
    }

    /**
     * @dev Returns the absolute unsigned value of a signed value.
     */
    function abs(int256 n) internal pure returns (uint256) {
        unchecked {
            // must be unchecked in order to support `n = type(int256).min`
            return uint256(n >= 0 ? n : -n);
        }
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (utils/Strings.sol)

pragma solidity ^0.8.0;

import "./math/Math.sol";
import "./math/SignedMath.sol";

/**
 * @dev String operations.
 */
library Strings {
    bytes16 private constant _SYMBOLS = "0123456789abcdef";
    uint8 private constant _ADDRESS_LENGTH = 20;

    /**
     * @dev Converts a `uint256` to its ASCII `string` decimal representation.
     */
    function toString(uint256 value) internal pure returns (string memory) {
        unchecked {
            uint256 length = Math.log10(value) + 1;
            string memory buffer = new string(length);
            uint256 ptr;
            /// @solidity memory-safe-assembly
            assembly {
                ptr := add(buffer, add(32, length))
            }
            while (true) {
                ptr--;
                /// @solidity memory-safe-assembly
                assembly {
                    mstore8(ptr, byte(mod(value, 10), _SYMBOLS))
                }
                value /= 10;
                if (value == 0) break;
            }
            return buffer;
        }
    }

    /**
     * @dev Converts a `int256` to its ASCII `string` decimal representation.
     */
    function toString(int256 value) internal pure returns (string memory) {
        return string(abi.encodePacked(value < 0 ? "-" : "", toString(SignedMath.abs(value))));
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation.
     */
    function toHexString(uint256 value) internal pure returns (string memory) {
        unchecked {
            return toHexString(value, Math.log256(value) + 1);
        }
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation with fixed length.
     */
    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _SYMBOLS[value & 0xf];
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

    /**
     * @dev Returns true if the two strings are equal.
     */
    function equal(string memory a, string memory b) internal pure returns (bool) {
        return keccak256(bytes(a)) == keccak256(bytes(b));
    }
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

/**
 * @title IEpochsManager
 * @author pNetwork
 *
 * @notice
 */
interface IEpochsManager {
    /*
     * @notice Returns the current epoch number.
     *
     * @return uint16 representing the current epoch.
     */
    function currentEpoch() external view returns (uint16);

    /*
     * @notice Returns the epoch duration.
     *
     * @return uint256 representing the epoch duration.
     */
    function epochDuration() external view returns (uint256);

    /*
     * @notice Returns the timestamp at which the first epoch is started
     *
     * @return uint256 representing the timestamp at which the first epoch is started.
     */
    function startFirstEpochTimestamp() external view returns (uint256);
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

/**
 * @title IFeesManager
 * @author pNetwork
 *
 * @notice
 */
interface IFeesManager {
    /**
     * @dev Emitted when a fee claim is redirected to the challenger who succesfully slashed the sentinel.
     *
     * @param sentinel The slashed sentinel
     * @param challenger The challenger
     * @param epoch The epoch
     */
    event ClaimRedirectedToChallenger(address indexed sentinel, address indexed challenger, uint16 indexed epoch);

    /**
     * @dev Emitted when a fee is deposited.
     *
     * @param asset The asset address
     * @param epoch The epoch
     * @param amount The amount
     */
    event FeeDeposited(address indexed asset, uint16 indexed epoch, uint256 amount);

    /**
     * @dev Emitted when an user claims a fee for a given epoch.
     *
     * @param owner The owner addres
     * @param sentinel The sentinel addres
     * @param epoch The epoch
     * @param asset The asset addres
     * @param amount The amount
     */
    event FeeClaimed(
        address indexed owner,
        address indexed sentinel,
        uint16 indexed epoch,
        address asset,
        uint256 amount
    );

    /*
     * @notice Claim a fee for a given asset in a specific epoch.
     *
     * @param owner
     * @param asset
     * @param epoch
     *
     */
    function claimFeeByEpoch(address owner, address asset, uint16 epoch) external;

    /*
     * @notice Claim a fee for a given asset in an epochs range.
     *
     * @param owner
     * @param asset
     * @param startEpoch
     * @param endEpoch
     *
     */
    function claimFeeByEpochsRange(address owner, address asset, uint16 startEpoch, uint16 endEpoch) external;

    /*
     * @notice Indicates the claimable asset fee amount in a specific epoch.
     *
     * @paran sentinel
     * @param asset
     * @param epoch
     *
     * @return uint256 an integer representing the claimable asset fee amount in a specific epoch.
     */
    function claimableFeeByEpochOf(address sentinel, address asset, uint16 epoch) external view returns (uint256);

    /*
     * @notice Indicates the claimable asset fee amount in an epochs range.
     *
     * @paran sentinel
     * @param assets
     * @param startEpoch
     * @param endEpoch
     *
     * @return uint256 an integer representing the claimable asset fee amount in an epochs range.
     */
    function claimableFeesByEpochsRangeOf(
        address sentinel,
        address[] calldata assets,
        uint16 startEpoch,
        uint16 endEpoch
    ) external view returns (uint256[] memory);

    /*
     * @notice returns the addresses of the challengers who are entitled to claim the fees in the event of slashing.
     *
     * @param sentinel
     * @param startEpoch
     * @params endEpoch
     *
     * @return address[] representing the addresses of the challengers who are entitled to claim the fees in the event of slashing.
     */
    function challengerClaimRedirectByEpochsRangeOf(
        address sentinel,
        uint16 startEpoch,
        uint16 endEpoch
    ) external view returns (address[] memory);

    /*
     * @notice returns the address of the challenger who are entitled to claim the fees in the event of slashing.
     *
     * @param sentinel
     * @params epoch
     *
     * @return address[] representing the address of the challenger who are entitled to claim the fees in the event of slashing.
     */
    function challengerClaimRedirectByEpochOf(address sentinel, uint16 epoch) external returns (address);

    /*
     * @notice Deposit an asset fee amount in the current epoch.
     *
     * @param asset
     * @param amount
     *
     */
    function depositFee(address asset, uint256 amount) external;

    /*
     * @notice Indicates the K factor in a specific epoch. The K factor is calculated with the following formula: utilizationRatio^2 + minimumBorrowingFee
     *
     * @param epoch
     *
     * @return uint256 an integer representing the K factor in a specific epoch.
     */
    function kByEpoch(uint16 epoch) external view returns (uint256);

    /*
     * @notice Indicates the K factor in a specific epochs range.
     *
     * @param startEpoch
     * @params endEpoch
     *
     * @return uint256[] an integer representing the K factor in a specific epochs range.
     */
    function kByEpochsRange(uint16 startEpoch, uint16 endEpoch) external view returns (uint256[] memory);

    /*
     * @notice Redirect the fees claiming to the challenger who succesfully slashed the sentinel for a given epoch.
     *         This function potentially allows to be called also for staking sentinel so it is up to who call it (RegistrationManager)
     *         to call it only for the borrowing sentinels.
     *
     * @param sentinel
     * @params challenger
     * @params epoch
     *
     */
    function redirectClaimToChallengerByEpoch(address sentinel, address challenger, uint16 epoch) external;
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

/**
 * @title ILendingManager
 * @author pNetwork
 *
 * @notice
 */
interface ILendingManager {
    /**
     * @dev Emitted when an user increases his lend position by increasing his lock time within the Staking Manager.
     *
     * @param lender The lender
     * @param endEpoch The new end epoch
     */
    event DurationIncreased(address indexed lender, uint16 endEpoch);

    /**
     * @dev Emitted when the lended amount for a certain epoch increase.
     *
     * @param lender The lender
     * @param startEpoch The start epoch
     * @param endEpoch The end epoch
     * @param amount The amount
     */
    event Lended(address indexed lender, uint256 indexed startEpoch, uint256 indexed endEpoch, uint256 amount);

    /**
     * @dev Emitted when a borrower borrows a certain amount of tokens for a number of epochs.
     *
     * @param borrower The borrower address
     * @param epoch The epoch
     * @param amount The amount
     */
    event Borrowed(address indexed borrower, uint256 indexed epoch, uint256 amount);

    /**
     * @dev Emitted when an reward is claimed
     *
     * @param lender The lender address
     * @param asset The claimed asset address
     * @param epoch The epoch
     * @param amount The amount
     */
    event RewardClaimed(address indexed lender, address indexed asset, uint256 indexed epoch, uint256 amount);

    /**
     * @dev Emitted when an reward is lended
     *
     * @param asset The asset
     * @param epoch The current epoch
     * @param amount The amount
     */
    event RewardDeposited(address indexed asset, uint256 indexed epoch, uint256 amount);

    /**
     * @dev Emitted when a borrower borrow is released.
     *
     * @param borrower The borrower address
     * @param epoch The current epoch
     * @param amount The amount
     */
    event Released(address indexed borrower, uint256 indexed epoch, uint256 amount);

    /*
     * @notice Borrow a certain amount of tokens in a given epoch
     *
     * @param amount
     * @param epoch
     * @param borrower
     *
     */
    function borrow(uint256 amount, uint16 epoch, address borrower) external;

    /*
     * @notice Returns the borrowable amount for the given epoch
     *
     * @param epoch
     *
     * @return uint24 an integer representing the borrowable amount for the given epoch.
     */
    function borrowableAmountByEpoch(uint16 epoch) external view returns (uint24);

    /*
     * @notice Returns the borrowed amount of a given user in a given epoch
     *
     * @param borrower
     * @param epoch
     *
     * @return uint24 an integer representing the borrowed amount of a given user in a given epoch.
     */
    function borrowedAmountByEpochOf(address borrower, uint16 epoch) external view returns (uint24);

    /*
     * @notice Returns the lender's claimable amount for a given asset in a specifich epoch.
     *
     * @param lender
     * @param asset
     * @param epoch
     *
     * @return uint256 an integer representing the lender's claimable value for a given asset in a specifich epoch..
     */
    function claimableRewardsByEpochOf(address lender, address asset, uint16 epoch) external view returns (uint256);

    /*
     * @notice Returns the lender's claimable amount for a set of assets in an epochs range
     *
     * @param lender
     * @param assets
     * @param startEpoch
     * @param endEpoch
     *
     * @return uint256 an integer representing the lender's claimable amount for a set of assets in an epochs range.
     */
    function claimableAssetsAmountByEpochsRangeOf(
        address lender,
        address[] calldata assets,
        uint16 startEpoch,
        uint16 endEpoch
    ) external view returns (uint256[] memory);

    /*
     * @notice Claim the rewards earned by the lender for a given epoch for a given asset.
     *
     * @param asset
     * @param epoch
     *
     */
    function claimRewardByEpoch(address asset, uint16 epoch) external;

    /*
     * @notice Claim the reward earned by the lender in an epochs range for a given asset.
     *
     * @param asset
     * @param startEpoch
     * @param endEpoch
     *
     */
    function claimRewardByEpochsRange(address asset, uint16 startEpoch, uint16 endEpoch) external;

    /*
     * @notice Deposit an reward amount of an asset in a given epoch.
     *
     * @param amount
     * @param asset
     * @param epoch
     *
     */
    function depositReward(address asset, uint16 epoch, uint256 amount) external;

    /*
     * @notice Returns the number of votes and the number of voted votes by a lender. This function is needed
     *         in order to allow the lender to be able to claim the rewards only if he voted to all votes
     *         within an epoch
     *
     * @param lender
     * @param epoch
     *
     * @return (uint256,uint256) representing the total number of votes within an epoch an the number of voted votes by a lender.
     */
    function getLenderVotingStateByEpoch(address lender, uint16 epoch) external returns (uint256, uint256);

    /*
     * @notice Increase the duration of a lending position by increasing the lock time of the staked tokens.
     *
     * @param duration
     *
     */
    function increaseDuration(uint64 duration) external;

    /*
     * @notice Increase the duration of a lending position by increasing the lock time of the staked tokens.
     *         This function is used togheter with onlyForwarder in order to enable cross chain duration increasing
     *
     * @param duration
     *
     */
    function increaseDuration(address lender, uint64 duration) external;

    /*
     * @notice Lend in behalf of lender a certain amount of tokens locked for a given period of time. The lended
     * tokens are forwarded within the StakingManager. This fx is just a proxy fx to the StakingManager.stake that counts
     * how many tokens can be borrowed.
     *
     * @param lender
     * @param amount
     * @param duration
     *
     */
    function lend(address lender, uint256 amount, uint64 duration) external;

    /*
     * @notice Returns the borrowed amount for a given epoch.
     *
     * @param epoch
     *
     * @return uint24 representing an integer representing the borrowed amount for a given epoch.
     */
    function totalBorrowedAmountByEpoch(uint16 epoch) external view returns (uint24);

    /*
     * @notice Returns the borrowed amount in an epochs range.
     *
     * @param startEpoch
     * @param endEpoch
     *
     * @return uint24[] representing an integer representing the borrowed amount in an epochs range.
     */
    function totalBorrowedAmountByEpochsRange(
        uint16 startEpoch,
        uint16 endEpoch
    ) external view returns (uint24[] memory);

    /*
     * @notice Returns the lended amount for a given epoch.
     *
     * @param epoch
     *
     * @return uint256 an integer representing the lended amount for a given epoch.
     */
    function totalLendedAmountByEpoch(uint16 epoch) external view returns (uint24);

    /*
     * @notice Returns the maximum lended amount for the selected epochs.
     *
     * @param startEpoch
     * @param endEpoch
     *
     * @return uint24[] representing an array of integers representing the maximum lended amount for a given epoch.
     */
    function totalLendedAmountByEpochsRange(uint16 startEpoch, uint16 endEpoch) external view returns (uint24[] memory);

    /*
     * @notice Delete the borrower for a given epoch.
     * In order to call it the sender must have the RELEASE_ROLE role.
     *
     * @param borrower
     * @param epoch
     * @param amount
     *
     */
    function release(address borrower, uint16 epoch, uint256 amount) external;

    /*
     * @notice Returns the current total asset reward amount by epoch
     *
     * @param asset
     * @param epoch
     *
     * @return (uint256,uint256) representing the total asset reward amount by epoch.
     */
    function totalAssetRewardAmountByEpoch(address asset, uint16 epoch) external view returns (uint256);

    /*
     * @notice Returns the current total weight for a given epoch. The total weight is the sum of the user weights in a specific epoch.
     *
     * @param asset
     * @param epoch
     *
     * @return uint32 representing the current total weight for a given epoch.
     */
    function totalWeightByEpoch(uint16 epoch) external view returns (uint32);

    /*
     * @notice Returns the current total weight for a given epochs range. The total weight is the sum of the user weights in a specific epochs range.
     *
     * @param asset
     * @param epoch
     *
     * @return uint32 representing the current total weight for a given epochs range.
     */
    function totalWeightByEpochsRange(uint16 startEpoch, uint16 endEpoch) external view returns (uint32[] memory);

    /*
     * @notice Returns the utilization rate (percentage of borrowed tokens compared to the lended ones) in the given epoch
     *
     * @param epoch
     *
     * @return uint24 an integer representing the utilization rate in a given epoch.
     */
    function utilizationRatioByEpoch(uint16 epoch) external view returns (uint24);

    /*
     * @notice Returns the utilization rate (percentage of borrowed tokens compared to the lended ones) given the start end the end epoch
     *
     * @param startEpoch
     * @param endEpoch
     *
     * @return uint24 an integer representing the utilization rate in a given the start end the end epoch.
     */
    function utilizationRatioByEpochsRange(uint16 startEpoch, uint16 endEpoch) external view returns (uint24[] memory);

    /*
     * @notice Returns the user weight in a given epoch. The user weight is calculated with
     * the following formula: lendedAmount * numberOfEpochsLeft in a given epoch
     *
     * @param lender
     * @param epoch
     *
     * @return uint32 an integer representing the user weight in a given epoch.
     */
    function weightByEpochOf(address lender, uint16 epoch) external view returns (uint32);

    /*
     * @notice Returns the user weights in an epochs range. The user weight is calculated with
     * the following formula: lendedAmount * numberOfEpochsLeft in a given epoch
     *
     * @param lender
     * @param epoch
     *
     * @return uint32[] an integer representing the user weights in an epochs range.
     */
    function weightByEpochsRangeOf(
        address lender,
        uint16 startEpoch,
        uint16 endEpoch
    ) external view returns (uint32[] memory);
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

/**
 * @title IRegistrationManager
 * @author pNetwork
 *
 * @notice
 */
interface IRegistrationManager {
    struct Registration {
        address owner;
        uint16 startEpoch;
        uint16 endEpoch;
        bytes1 kind;
    }

    /**
     * @dev Emitted when a borrowing sentinel is slashed.
     *
     * @param sentinel The sentinel
     */
    event BorrowingSentinelSlashed(address indexed sentinel);

    /**
     * @dev Emitted when an user increases his staking sentinel registration position by increasing his lock time within the Staking Manager.
     *
     * @param sentinel The sentinel
     * @param endEpoch The new end epoch
     */
    event DurationIncreased(address indexed sentinel, uint16 endEpoch);

    /**
     * @dev Emitted when a guardian is slashed.
     *
     * @param guardian The guardian
     */
    event GuardianSlashed(address indexed guardian);

    /**
     * @dev Emitted when a guardian is registered.
     *
     * @param owner The sentinel owner
     * @param startEpoch The epoch in which the registration starts
     * @param endEpoch The epoch at which the registration ends
     * @param guardian The sentinel address
     * @param kind The type of registration
     */
    event GuardianRegistrationUpdated(
        address indexed owner,
        uint16 indexed startEpoch,
        uint16 indexed endEpoch,
        address guardian,
        bytes1 kind
    );

    /**
     * @dev Emitted when a guardian is light-resumed.
     *
     * @param guardian The guardian
     */
    event GuardianLightResumed(address indexed guardian);

    /**
     * @dev Emitted when a sentinel registration is completed.
     *
     * @param owner The sentinel owner
     * @param startEpoch The epoch in which the registration starts
     * @param endEpoch The epoch at which the registration ends
     * @param sentinel The sentinel address
     * @param kind The type of registration
     * @param amount The amount used to register a sentinel
     */
    event SentinelRegistrationUpdated(
        address indexed owner,
        uint16 indexed startEpoch,
        uint16 indexed endEpoch,
        address sentinel,
        bytes1 kind,
        uint256 amount
    );

    /**
     * @dev Emitted when a sentinel is hard-resumed.
     *
     * @param sentinel The sentinel
     */
    event SentinelHardResumed(address indexed sentinel);

    /**
     * @dev Emitted when a sentinel is light-resumed.
     *
     * @param sentinel The sentinel
     */
    event SentinelLightResumed(address indexed sentinel);

    /**
     * @dev Emitted when a staking sentinel increased its amount at stake.
     *
     * @param sentinel The sentinel
     */
    event StakedAmountIncreased(address indexed sentinel, uint256 amount);

    /**
     * @dev Emitted when a staking sentinel is slashed.
     *
     * @param sentinel The sentinel
     * @param amount The amount
     */
    event StakingSentinelSlashed(address indexed sentinel, uint256 amount);

    /*
     * @notice Returns the sentinel address given the owner and the signature.
     *
     * @param sentinel
     *
     * @return address representing the address of the sentinel.
     */
    function getSentinelAddressFromSignature(address owner, bytes calldata signature) external pure returns (address);

    /*
     * @notice Returns a guardian registration.
     *
     * @param guardian
     *
     * @return Registration representing the guardian registration.
     */
    function guardianRegistration(address guardian) external view returns (Registration memory);

    /*
     * @notice Returns a guardian by its owner.
     *
     * @param owner
     *
     * @return the guardian.
     */
    function guardianOf(address owner) external view returns (address);

    /*
     * @notice Resume a sentinel that was hard-slashed that means that its amount went below 200k PNT
     *         and its address was removed from the merkle tree. In order to be able to hard-resume a
     *         sentinel, when the function is called, StakingManager.increaseAmount is also called in
     *         order to increase the amount at stake.
     *
     * @param amount
     * @param owner
     * @param signature
     *
     */
    function hardResumeSentinel(uint256 amount, address owner, bytes calldata signature) external;

    /*
     * @notice Increase the duration of a staking sentinel registration.
     *
     * @param duration
     */
    function increaseSentinelRegistrationDuration(uint64 duration) external;

    /*
     * @notice Increase the duration  of a staking sentinel registration. This function is used togheter with
     *         onlyForwarder modifier in order to enable cross chain duration increasing
     *
     * @param owner
     * @param duration
     */
    function increaseSentinelRegistrationDuration(address owner, uint64 duration) external;

    /*
     * @notice Resume a guardian that was light-slashed
     *
     *
     */
    function lightResumeGuardian() external;

    /*
     * @notice Resume a sentinel that was light-slashed
     *
     * @param owner
     * @param signature
     *
     */
    function lightResumeSentinel(address owner, bytes calldata signature) external;

    /*
     * @notice Returns the sentinel of a given owner
     *
     * @param owner
     *
     * @return address representing the address of the sentinel.
     */
    function sentinelOf(address owner) external view returns (address);

    /*
     * @notice Returns the sentinel registration
     *
     * @param sentinel
     *
     * @return address representing the sentinel registration data.
     */
    function sentinelRegistration(address sentinel) external view returns (Registration memory);

    /*
     * @notice Return the staked amount by a sentinel in a given epoch.
     *
     * @param epoch
     *
     * @return uint256 representing staked amount by a sentinel in a given epoch.
     */
    function sentinelStakedAmountByEpochOf(address sentinel, uint16 epoch) external view returns (uint256);

    /*
     * @notice Return the number of times an actor (sentinel or guardian) has been slashed in an epoch.
     *
     * @param epoch
     * @param actor
     *
     * @return uint16 representing the number of times an actor has been slashed in an epoch.
     */
    function slashesByEpochOf(uint16 epoch, address actor) external view returns (uint16);

    /*
     * @notice Set FeesManager
     *
     * @param feesManager
     *
     */
    function setFeesManager(address feesManager) external;

    /*
     * @notice Set GovernanceMessageEmitter
     *
     * @param feesManager
     *
     */
    function setGovernanceMessageEmitter(address governanceMessageEmitter) external;

    /*
     * @notice Slash a sentinel or a guardian. This function is callable only by the PNetworkHub
     *
     * @param actor
     * @param amount
     * @param challenger
     *
     */
    function slash(address actor, uint256 amount, address challenger) external;

    /*
     * @notice Return the total number of guardians in a specific epoch.
     *
     * @param epoch
     *
     * @return uint256 the total number of guardians in a specific epoch.
     */
    function totalNumberOfGuardiansByEpoch(uint16 epoch) external view returns (uint16);

    /*
     * @notice Return the total staked amount by the sentinels in a given epoch.
     *
     * @param epoch
     *
     * @return uint256 representing  total staked amount by the sentinels in a given epoch.
     */
    function totalSentinelStakedAmountByEpoch(uint16 epoch) external view returns (uint256);

    /*
     * @notice Return the total staked amount by the sentinels in a given epochs range.
     *
     * @param epoch
     *
     * @return uint256[] representing  total staked amount by the sentinels in a given epochs range.
     */
    function totalSentinelStakedAmountByEpochsRange(
        uint16 startEpoch,
        uint16 endEpoch
    ) external view returns (uint256[] memory);

    /*
     * @notice Update guardians registrations. UPDATE_GUARDIAN_REGISTRATION_ROLE is needed to call this function
     *
     * @param owners
     * @param numbersOfEpochs
     * @param guardians
     *
     */
    function updateGuardiansRegistrations(
        address[] calldata owners,
        uint16[] calldata numbersOfEpochs,
        address[] calldata guardians
    ) external;

    /*
     * @notice Update a guardian registration. UPDATE_GUARDIAN_REGISTRATION_ROLE is needed to call this function
     *
     * @param owners
     * @param numbersOfEpochs
     * @param guardians
     *
     */
    function updateGuardianRegistration(address owner, uint16 numberOfEpochs, address guardian) external;

    /*
     * @notice Registers/Renew a sentinel by borrowing the specified amount of tokens for a given number of epochs.
     *         This function is used togheter with onlyForwarder.
     *
     * @params owner
     * @param numberOfEpochs
     * @param signature
     *
     */
    function updateSentinelRegistrationByBorrowing(
        address owner,
        uint16 numberOfEpochs,
        bytes calldata signature
    ) external;

    /*
     * @notice Registers/Renew a sentinel by borrowing the specified amount of tokens for a given number of epochs.
     *
     * @param numberOfEpochs
     * @param signature
     *
     */
    function updateSentinelRegistrationByBorrowing(uint16 numberOfEpochs, bytes calldata signature) external;

    /*
     * @notice Registers/Renew a sentinel for a given duration in behalf of owner
     *
     * @param amount
     * @param duration
     * @param signature
     * @param owner
     *
     */
    function updateSentinelRegistrationByStaking(
        address owner,
        uint256 amount,
        uint64 duration,
        bytes calldata signature
    ) external;
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

/**
 * @title IRegistrationManager
 * @author pNetwork
 *
 * @notice
 */
interface IRegistrationManager {
    struct Registration {
        address owner;
        uint16 startEpoch;
        uint16 endEpoch;
        bytes1 kind;
    }

    /**
     * @dev Emitted when a borrowing sentinel is slashed.
     *
     * @param sentinel The sentinel
     */
    event BorrowingSentinelSlashed(address indexed sentinel);

    /**
     * @dev Emitted when an user increases his staking sentinel registration position by increasing his lock time within the Staking Manager.
     *
     * @param sentinel The sentinel
     * @param endEpoch The new end epoch
     */
    event DurationIncreased(address indexed sentinel, uint16 endEpoch);

    /**
     * @dev Emitted when a guardian is slashed.
     *
     * @param guardian The guardian
     */
    event GuardianSlashed(address indexed guardian);

    /**
     * @dev Emitted when a guardian is registered.
     *
     * @param owner The sentinel owner
     * @param startEpoch The epoch in which the registration starts
     * @param endEpoch The epoch at which the registration ends
     * @param guardian The sentinel address
     * @param kind The type of registration
     */
    event GuardianRegistrationUpdated(
        address indexed owner,
        uint16 indexed startEpoch,
        uint16 indexed endEpoch,
        address guardian,
        bytes1 kind
    );

    /**
     * @dev Emitted when a guardian is light-resumed.
     *
     * @param guardian The guardian
     */
    event GuardianLightResumed(address indexed guardian);

    /**
     * @dev Emitted when a sentinel registration is completed.
     *
     * @param owner The sentinel owner
     * @param startEpoch The epoch in which the registration starts
     * @param endEpoch The epoch at which the registration ends
     * @param sentinel The sentinel address
     * @param kind The type of registration
     * @param amount The amount used to register a sentinel
     */
    event SentinelRegistrationUpdated(
        address indexed owner,
        uint16 indexed startEpoch,
        uint16 indexed endEpoch,
        address sentinel,
        bytes1 kind,
        uint256 amount
    );

    /**
     * @dev Emitted when a sentinel is hard-resumed.
     *
     * @param sentinel The sentinel
     */
    event SentinelHardResumed(address indexed sentinel);

    /**
     * @dev Emitted when a sentinel is light-resumed.
     *
     * @param sentinel The sentinel
     */
    event SentinelLightResumed(address indexed sentinel);

    /**
     * @dev Emitted when a staking sentinel increased its amount at stake.
     *
     * @param sentinel The sentinel
     */
    event StakedAmountIncreased(address indexed sentinel, uint256 amount);

    /**
     * @dev Emitted when a staking sentinel is slashed.
     *
     * @param sentinel The sentinel
     * @param amount The amount
     */
    event StakingSentinelSlashed(address indexed sentinel, uint256 amount);

    /*
     * @notice Returns the sentinel address given the owner and the signature.
     *
     * @param sentinel
     *
     * @return address representing the address of the sentinel.
     */
    function getSentinelAddressFromSignature(address owner, bytes calldata signature) external pure returns (address);

    /*
     * @notice Returns a guardian registration.
     *
     * @param guardian
     *
     * @return Registration representing the guardian registration.
     */
    function guardianRegistration(address guardian) external view returns (Registration memory);

    /*
     * @notice Returns a guardian by its owner.
     *
     * @param owner
     *
     * @return the guardian.
     */
    function guardianOf(address owner) external view returns (address);

    /*
     * @notice Resume a sentinel that was hard-slashed that means that its amount went below 200k PNT
     *         and its address was removed from the merkle tree. In order to be able to hard-resume a
     *         sentinel, when the function is called, StakingManager.increaseAmount is also called in
     *         order to increase the amount at stake.
     *
     * @param amount
     * @param owner
     * @param signature
     *
     */
    function hardResumeSentinel(uint256 amount, address owner, bytes calldata signature) external;

    /*
     * @notice Increase the duration of a staking sentinel registration.
     *
     * @param duration
     */
    function increaseSentinelRegistrationDuration(uint64 duration) external;

    /*
     * @notice Increase the duration  of a staking sentinel registration. This function is used togheter with
     *         onlyForwarder modifier in order to enable cross chain duration increasing
     *
     * @param owner
     * @param duration
     */
    function increaseSentinelRegistrationDuration(address owner, uint64 duration) external;

    /*
     * @notice Resume a guardian that was light-slashed
     *
     *
     */
    function lightResumeGuardian() external;

    /*
     * @notice Resume a sentinel that was light-slashed
     *
     * @param owner
     * @param signature
     *
     */
    function lightResumeSentinel(address owner, bytes calldata signature) external;

    /*
     * @notice Returns the sentinel of a given owner
     *
     * @param owner
     *
     * @return address representing the address of the sentinel.
     */
    function sentinelOf(address owner) external view returns (address);

    /*
     * @notice Returns the sentinel registration
     *
     * @param sentinel
     *
     * @return address representing the sentinel registration data.
     */
    function sentinelRegistration(address sentinel) external view returns (Registration memory);

    /*
     * @notice Return the staked amount by a sentinel in a given epoch.
     *
     * @param epoch
     *
     * @return uint256 representing staked amount by a sentinel in a given epoch.
     */
    function sentinelStakedAmountByEpochOf(address sentinel, uint16 epoch) external view returns (uint256);

    /*
     * @notice Return the number of times an actor (sentinel or guardian) has been slashed in an epoch.
     *
     * @param epoch
     * @param actor
     *
     * @return uint16 representing the number of times an actor has been slashed in an epoch.
     */
    function slashesByEpochOf(uint16 epoch, address actor) external view returns (uint16);

    /*
     * @notice Set FeesManager
     *
     * @param feesManager
     *
     */
    function setFeesManager(address feesManager) external;

    /*
     * @notice Set GovernanceMessageEmitter
     *
     * @param feesManager
     *
     */
    function setGovernanceMessageEmitter(address governanceMessageEmitter) external;

    /*
     * @notice Slash a sentinel or a guardian. This function is callable only by the PNetworkHub
     *
     * @param actor
     * @param amount
     * @param challenger
     *
     */
    function slash(address actor, uint256 amount, address challenger) external;

    /*
     * @notice Return the total number of guardians in a specific epoch.
     *
     * @param epoch
     *
     * @return uint256 the total number of guardians in a specific epoch.
     */
    function totalNumberOfGuardiansByEpoch(uint16 epoch) external view returns (uint16);

    /*
     * @notice Return the total staked amount by the sentinels in a given epoch.
     *
     * @param epoch
     *
     * @return uint256 representing  total staked amount by the sentinels in a given epoch.
     */
    function totalSentinelStakedAmountByEpoch(uint16 epoch) external view returns (uint256);

    /*
     * @notice Return the total staked amount by the sentinels in a given epochs range.
     *
     * @param epoch
     *
     * @return uint256[] representing  total staked amount by the sentinels in a given epochs range.
     */
    function totalSentinelStakedAmountByEpochsRange(
        uint16 startEpoch,
        uint16 endEpoch
    ) external view returns (uint256[] memory);

    /*
     * @notice Update guardians registrations. UPDATE_GUARDIAN_REGISTRATION_ROLE is needed to call this function
     *
     * @param owners
     * @param numbersOfEpochs
     * @param guardians
     *
     */
    function updateGuardiansRegistrations(
        address[] calldata owners,
        uint16[] calldata numbersOfEpochs,
        address[] calldata guardians
    ) external;

    /*
     * @notice Update a guardian registration. UPDATE_GUARDIAN_REGISTRATION_ROLE is needed to call this function
     *
     * @param owners
     * @param numbersOfEpochs
     * @param guardians
     *
     */
    function updateGuardianRegistration(address owner, uint16 numberOfEpochs, address guardian) external;

    /*
     * @notice Registers/Renew a sentinel by borrowing the specified amount of tokens for a given number of epochs.
     *         This function is used togheter with onlyForwarder.
     *
     * @params owner
     * @param numberOfEpochs
     * @param signature
     *
     */
    function updateSentinelRegistrationByBorrowing(
        address owner,
        uint16 numberOfEpochs,
        bytes calldata signature
    ) external;

    /*
     * @notice Registers/Renew a sentinel by borrowing the specified amount of tokens for a given number of epochs.
     *
     * @param numberOfEpochs
     * @param signature
     *
     */
    function updateSentinelRegistrationByBorrowing(uint16 numberOfEpochs, bytes calldata signature) external;

    /*
     * @notice Registers/Renew a sentinel for a given duration in behalf of owner
     *
     * @param amount
     * @param duration
     * @param signature
     * @param owner
     *
     */
    function updateSentinelRegistrationByStaking(
        address owner,
        uint256 amount,
        uint64 duration,
        bytes calldata signature
    ) external;
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {PToken} from "../core/PToken.sol";
import {IPFactory} from "../interfaces/IPFactory.sol";

contract PFactory is IPFactory, Ownable {
    address public hub;

    function deploy(
        string memory underlyingAssetName,
        string memory underlyingAssetSymbol,
        uint256 underlyingAssetDecimals,
        address underlyingAssetTokenAddress,
        bytes4 underlyingAssetNetworkId
    ) public payable returns (address) {
        address pTokenAddress = address(
            new PToken{salt: hex"0000000000000000000000000000000000000000000000000000000000000000"}(
                underlyingAssetName,
                underlyingAssetSymbol,
                underlyingAssetDecimals,
                underlyingAssetTokenAddress,
                underlyingAssetNetworkId,
                hub
            )
        );

        emit PTokenDeployed(pTokenAddress);
        return pTokenAddress;
    }

    function getBytecode(
        string memory underlyingAssetName,
        string memory underlyingAssetSymbol,
        uint256 underlyingAssetDecimals,
        address underlyingAssetTokenAddress,
        bytes4 underlyingAssetNetworkId
    ) public view returns (bytes memory) {
        bytes memory bytecode = type(PToken).creationCode;

        return
            abi.encodePacked(
                bytecode,
                abi.encode(
                    underlyingAssetName,
                    underlyingAssetSymbol,
                    underlyingAssetDecimals,
                    underlyingAssetTokenAddress,
                    underlyingAssetNetworkId,
                    hub
                )
            );
    }

    function getPTokenAddress(
        string memory underlyingAssetName,
        string memory underlyingAssetSymbol,
        uint256 underlyingAssetDecimals,
        address underlyingAssetTokenAddress,
        bytes4 underlyingAssetNetworkId
    ) public view returns (address) {
        bytes memory bytecode = getBytecode(
            underlyingAssetName,
            underlyingAssetSymbol,
            underlyingAssetDecimals,
            underlyingAssetTokenAddress,
            underlyingAssetNetworkId
        );

        return
            address(
                uint160(
                    uint256(
                        keccak256(
                            abi.encodePacked(
                                bytes1(0xff),
                                address(this),
                                hex"0000000000000000000000000000000000000000000000000000000000000000",
                                keccak256(bytecode)
                            )
                        )
                    )
                )
            );
    }

    function setHub(address hub_) external onlyOwner {
        hub = hub_;
    }
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {ReentrancyGuard} from "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import {IEpochsManager} from "@pnetwork-association/dao-v2-contracts/contracts/interfaces/IEpochsManager.sol";
import {IFeesManager} from "@pnetwork-association/dao-v2-contracts/contracts/interfaces/IFeesManager.sol";
import {MerkleProof} from "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import {ECDSA} from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import {GovernanceMessageHandler} from "../governance/GovernanceMessageHandler.sol";
import {IPToken} from "../interfaces/IPToken.sol";
import {IPFactory} from "../interfaces/IPFactory.sol";
import {IPNetworkHub} from "../interfaces/IPNetworkHub.sol";
import {IPReceiver} from "../interfaces/IPReceiver.sol";
import {Utils} from "../libraries/Utils.sol";
import {Network} from "../libraries/Network.sol";

error InvalidOperationStatus(IPNetworkHub.OperationStatus status, IPNetworkHub.OperationStatus expectedStatus);
error ActorAlreadyCancelledOperation(
    IPNetworkHub.Operation operation,
    address actor,
    IPNetworkHub.ActorTypes actorType
);
error ChallengePeriodNotTerminated(uint64 startTimestamp, uint64 endTimestamp);
error ChallengePeriodTerminated(uint64 startTimestamp, uint64 endTimestamp);
error InvalidAssetParameters(uint256 assetAmount, address assetTokenAddress);
error InvalidUserOperation();
error PTokenNotCreated(address pTokenAddress);
error InvalidNetwork(bytes4 networkId, bytes4 expectedNetworkId);
error NotContract(address addr);
error LockDown();
error InvalidGovernanceMessage(bytes message);
error InvalidLockedAmountChallengePeriod(
    uint256 lockedAmountChallengePeriod,
    uint256 expectedLockedAmountChallengePeriod
);
error QueueFull();
error InvalidNetworkFeeAssetAmount();
error InvalidActor(address actor, IPNetworkHub.ActorTypes actorType);
error InvalidLockedAmountStartChallenge(uint256 lockedAmountStartChallenge, uint256 expectedLockedAmountStartChallenge);
error InvalidActorStatus(IPNetworkHub.ActorStatus status, IPNetworkHub.ActorStatus expectedStatus);
error InvalidChallengeStatus(IPNetworkHub.ChallengeStatus status, IPNetworkHub.ChallengeStatus expectedStatus);
error NearToEpochEnd();
error ChallengeDurationPassed();
error MaxChallengeDurationNotPassed();
error ChallengeNotFound(IPNetworkHub.Challenge challenge);
error ChallengeDurationMustBeLessOrEqualThanMaxChallengePeriodDuration(
    uint64 challengeDuration,
    uint64 maxChallengePeriodDuration
);
error InvalidEpoch(uint16 epoch);
error Inactive();
error NotDandelionVoting(address dandelionVoting, address expectedDandelionVoting);

contract PNetworkHub is IPNetworkHub, GovernanceMessageHandler, ReentrancyGuard {
    bytes32 public constant GOVERNANCE_MESSAGE_ACTORS = keccak256("GOVERNANCE_MESSAGE_ACTORS");
    bytes32 public constant GOVERNANCE_MESSAGE_SLASH_ACTOR = keccak256("GOVERNANCE_MESSAGE_SLASH_ACTOR");
    bytes32 public constant GOVERNANCE_MESSAGE_RESUME_ACTOR = keccak256("GOVERNANCE_MESSAGE_RESUME_ACTOR");
    bytes32 public constant GOVERNANCE_MESSAGE_PROTOCOL_GOVERNANCE_CANCEL_OPERATION =
        keccak256("GOVERNANCE_MESSAGE_PROTOCOL_GOVERNANCE_CANCEL_OPERATION");
    uint256 public constant FEE_BASIS_POINTS_DIVISOR = 10000;

    address public constant UNDERLYING_ASSET_TOKEN_ADDRESS_USER_DATA_PROTOCOL_FEE =
        0x6B175474E89094C44Da98b954EedeAC495271d0F;
    bytes4 public constant UNDERLYING_ASSET_NETWORK_ID_USER_DATA_PROTOCOL_FEE = 0x005fe7f9;
    uint256 public constant UNDERLYING_ASSET_DECIMALS_USER_DATA_PROTOCOL_FEE = 18;
    string public constant UNDERLYING_ASSET_NAME_USER_DATA_PROTOCOL_FEE = "Dai Stablecoin";
    string public constant UNDERLYING_ASSET_SYMBOL_USER_DATA_PROTOCOL_FEE = "DAI";

    mapping(bytes32 => Action) private _operationsRelayerQueueAction;
    mapping(bytes32 => Action) private _operationsGovernanceCancelAction;
    mapping(bytes32 => Action) private _operationsGuardianCancelAction;
    mapping(bytes32 => Action) private _operationsSentinelCancelAction;
    mapping(bytes32 => uint8) private _operationsTotalCancelActions;
    mapping(bytes32 => OperationStatus) private _operationsStatus;
    mapping(uint16 => bytes32) private _epochsActorsMerkleRoot;
    mapping(uint16 => mapping(ActorTypes => uint16)) private _epochsTotalNumberOfActors;
    mapping(uint16 => mapping(bytes32 => Challenge)) private _epochsChallenges;
    mapping(uint16 => mapping(bytes32 => ChallengeStatus)) private _epochsChallengesStatus;
    mapping(uint16 => mapping(address => ActorStatus)) private _epochsActorsStatus;
    mapping(uint16 => mapping(ActorTypes => uint16)) private _epochsTotalNumberOfInactiveActors;
    mapping(uint16 => mapping(address => bytes32)) private _epochsActorsPendingChallengeId;

    address public immutable factory;
    address public immutable epochsManager;
    address public immutable feesManager;
    address public immutable slasher;
    address public immutable dandelionVoting;
    uint32 public immutable baseChallengePeriodDuration;
    uint32 public immutable maxChallengePeriodDuration;
    uint16 public immutable kChallengePeriod;
    uint16 public immutable maxOperationsInQueue;
    bytes4 public immutable interimChainNetworkId;
    uint256 public immutable lockedAmountChallengePeriod;
    uint256 public immutable lockedAmountStartChallenge;
    uint64 public immutable challengeDuration;

    uint256 public challengesNonce;
    uint16 public numberOfOperationsInQueue;

    constructor(
        address factory_,
        uint32 baseChallengePeriodDuration_,
        address epochsManager_,
        address feesManager_,
        address telepathyRouter,
        address governanceMessageVerifier,
        address slasher_,
        address dandelionVoting_,
        uint256 lockedAmountChallengePeriod_,
        uint16 kChallengePeriod_,
        uint16 maxOperationsInQueue_,
        bytes4 interimChainNetworkId_,
        uint256 lockedAmountOpenChallenge_,
        uint64 challengeDuration_,
        uint32 expectedSourceChainId
    ) GovernanceMessageHandler(telepathyRouter, governanceMessageVerifier, expectedSourceChainId) {
        // NOTE: see the comment within _checkNearEndOfEpochStartChallenge
        maxChallengePeriodDuration =
            baseChallengePeriodDuration_ +
            ((maxOperationsInQueue_ ** 2) * kChallengePeriod_) -
            kChallengePeriod_;
        if (challengeDuration_ > maxChallengePeriodDuration) {
            revert ChallengeDurationMustBeLessOrEqualThanMaxChallengePeriodDuration(
                challengeDuration_,
                maxChallengePeriodDuration
            );
        }

        factory = factory_;
        epochsManager = epochsManager_;
        feesManager = feesManager_;
        slasher = slasher_;
        dandelionVoting = dandelionVoting_;
        baseChallengePeriodDuration = baseChallengePeriodDuration_;
        lockedAmountChallengePeriod = lockedAmountChallengePeriod_;
        kChallengePeriod = kChallengePeriod_;
        maxOperationsInQueue = maxOperationsInQueue_;
        interimChainNetworkId = interimChainNetworkId_;
        lockedAmountStartChallenge = lockedAmountOpenChallenge_;
        challengeDuration = challengeDuration_;
    }

    /// @inheritdoc IPNetworkHub
    function challengeIdOf(Challenge memory challenge) public pure returns (bytes32) {
        return sha256(abi.encode(challenge));
    }

    /// @inheritdoc IPNetworkHub
    function challengePeriodOf(Operation calldata operation) public view returns (uint64, uint64) {
        bytes32 operationId = operationIdOf(operation);
        OperationStatus operationStatus = _operationsStatus[operationId];
        return _challengePeriodOf(operationId, operationStatus);
    }

    /// @inheritdoc IPNetworkHub
    function claimLockedAmountStartChallenge(Challenge calldata challenge) external {
        bytes32 challengeId = challengeIdOf(challenge);
        uint16 currentEpoch = IEpochsManager(epochsManager).currentEpoch();
        uint16 challengeEpoch = getChallengeEpoch(challenge);

        if (challengeEpoch >= currentEpoch) {
            revert InvalidEpoch(challengeEpoch);
        }

        ChallengeStatus challengeStatus = _epochsChallengesStatus[challengeEpoch][challengeId];
        if (challengeStatus == ChallengeStatus.Null) {
            revert ChallengeNotFound(challenge);
        }

        if (challengeStatus != ChallengeStatus.Pending) {
            revert InvalidChallengeStatus(challengeStatus, ChallengeStatus.Pending);
        }

        _epochsChallengesStatus[challengeEpoch][challengeId] = ChallengeStatus.PartiallyUnsolved;
        Utils.sendEther(challenge.challenger, lockedAmountStartChallenge);

        emit ChallengePartiallyUnsolved(challenge);
    }

    /// @inheritdoc IPNetworkHub
    function getChallengeEpoch(Challenge calldata challenge) public view returns (uint16) {
        uint256 epochDuration = IEpochsManager(epochsManager).epochDuration();
        uint256 startFirstEpochTimestamp = IEpochsManager(epochsManager).startFirstEpochTimestamp();
        return uint16((challenge.timestamp - startFirstEpochTimestamp) / epochDuration);
    }

    /// @inheritdoc IPNetworkHub
    function getChallengeStatus(Challenge calldata challenge) external view returns (ChallengeStatus) {
        return _epochsChallengesStatus[getChallengeEpoch(challenge)][challengeIdOf(challenge)];
    }

    /*function getCurrentActiveActorsAdjustmentDuration() public view returns (uint64) {
        uint16 currentEpoch = IEpochsManager(epochsManager).currentEpoch();
        uint16 activeActors = (_epochsTotalNumberOfActors[currentEpoch][ActorTypes.Guardian] +
            _epochsTotalNumberOfActors[currentEpoch][ActorTypes.Sentinel]) -
            (_epochsTotalNumberOfInactiveActors[currentEpoch][ActorTypes.Guardian] +
                _epochsTotalNumberOfInactiveActors[currentEpoch][ActorTypes.Sentinel]);
        return 30 days / ((activeActors ** 5) + 1);
    }*/

    /// @inheritdoc IPNetworkHub
    function getCurrentChallengePeriodDuration() public view returns (uint64) {
        return /*getCurrentActiveActorsAdjustmentDuration() +*/ getCurrentQueuedOperationsAdjustmentDuration();
    }

    /// @inheritdoc IPNetworkHub
    function getCurrentQueuedOperationsAdjustmentDuration() public view returns (uint64) {
        uint32 localNumberOfOperationsInQueue = numberOfOperationsInQueue;
        if (localNumberOfOperationsInQueue == 0) return baseChallengePeriodDuration;

        return
            baseChallengePeriodDuration + ((localNumberOfOperationsInQueue ** 2) * kChallengePeriod) - kChallengePeriod;
    }

    /// @inheritdoc IPNetworkHub
    function getPendingChallengeIdByEpochOf(uint16 epoch, address actor) external view returns (bytes32) {
        return _epochsActorsPendingChallengeId[epoch][actor];
    }

    /// @inheritdoc IPNetworkHub
    function getTotalNumberOfInactiveActorsByEpochAndType(
        uint16 epoch,
        ActorTypes actorType
    ) external view returns (uint16) {
        return _epochsTotalNumberOfInactiveActors[epoch][actorType];
    }

    /// @inheritdoc IPNetworkHub
    function operationIdOf(Operation memory operation) public pure returns (bytes32) {
        return sha256(abi.encode(operation));
    }

    /// @inheritdoc IPNetworkHub
    function operationStatusOf(Operation calldata operation) external view returns (OperationStatus) {
        return _operationsStatus[operationIdOf(operation)];
    }

    /// @inheritdoc IPNetworkHub
    function protocolGovernanceCancelOperation(Operation calldata operation) external {
        bytes4 networkId = Network.getCurrentNetworkId();
        if (networkId != interimChainNetworkId) {
            revert InvalidNetwork(networkId, interimChainNetworkId);
        }

        address msgSender = _msgSender();
        if (msgSender != dandelionVoting) {
            revert NotDandelionVoting(msgSender, dandelionVoting);
        }

        _protocolCancelOperation(operation, operationIdOf(operation), msgSender, ActorTypes.Governance);
    }

    /// @inheritdoc IPNetworkHub
    function protocolCancelOperation(
        Operation calldata operation,
        ActorTypes actorType,
        bytes32[] calldata proof,
        bytes calldata signature
    ) external {
        _checkActorsStatus();

        bytes32 operationId = operationIdOf(operation);
        address actor = ECDSA.recover(ECDSA.toEthSignedMessageHash(operationId), signature);
        if (!_isActor(actor, actorType, proof)) {
            revert InvalidActor(actor, actorType);
        }

        uint16 currentEpoch = IEpochsManager(epochsManager).currentEpoch();
        if (_epochsActorsStatus[currentEpoch][actor] == ActorStatus.Inactive) {
            revert Inactive();
        }

        _protocolCancelOperation(operation, operationId, actor, actorType);
    }

    /// @inheritdoc IPNetworkHub
    function protocolExecuteOperation(Operation calldata operation) external payable nonReentrant {
        _checkLockDownMode();
        bytes32 operationId = operationIdOf(operation);
        OperationStatus operationStatus = _operationsStatus[operationId];
        if (operationStatus != OperationStatus.Queued) {
            revert InvalidOperationStatus(operationStatus, OperationStatus.Queued);
        }

        (uint64 startTimestamp, uint64 endTimestamp) = _challengePeriodOf(operationId, operationStatus);
        if (uint64(block.timestamp) < endTimestamp) {
            revert ChallengePeriodNotTerminated(startTimestamp, endTimestamp);
        }

        address pTokenAddress = IPFactory(factory).getPTokenAddress(
            operation.underlyingAssetName,
            operation.underlyingAssetSymbol,
            operation.underlyingAssetDecimals,
            operation.underlyingAssetTokenAddress,
            operation.underlyingAssetNetworkId
        );

        uint256 effectiveOperationAssetAmount = operation.assetAmount;

        // NOTE: if we are on the interim chain we must take the fee
        if (interimChainNetworkId == Network.getCurrentNetworkId()) {
            effectiveOperationAssetAmount = _takeProtocolFee(operation, pTokenAddress);

            // NOTE: if we are on interim chain but the effective destination chain (forwardDestinationNetworkId) is another one
            // we have to emit an user Operation without protocol fee and with effectiveOperationAssetAmount and forwardDestinationNetworkId as
            // destinationNetworkId in order to proxy the Operation on the destination chain.
            if (
                interimChainNetworkId != operation.forwardDestinationNetworkId &&
                operation.forwardDestinationNetworkId != bytes4(0)
            ) {
                effectiveOperationAssetAmount = _takeNetworkFee(
                    effectiveOperationAssetAmount,
                    operation.networkFeeAssetAmount,
                    operationId,
                    pTokenAddress
                );

                _releaseOperationLockedAmountChallengePeriod(operationId);
                emit UserOperation(
                    gasleft(),
                    operation.originAccount,
                    operation.destinationAccount,
                    operation.forwardDestinationNetworkId,
                    operation.underlyingAssetName,
                    operation.underlyingAssetSymbol,
                    operation.underlyingAssetDecimals,
                    operation.underlyingAssetTokenAddress,
                    operation.underlyingAssetNetworkId,
                    pTokenAddress,
                    effectiveOperationAssetAmount,
                    0,
                    0,
                    operation.forwardNetworkFeeAssetAmount,
                    bytes4(0),
                    operation.userData,
                    operation.optionsMask,
                    operation.isForProtocol
                );

                emit OperationExecuted(operation);
                return;
            }
        }

        effectiveOperationAssetAmount = _takeNetworkFee(
            effectiveOperationAssetAmount,
            operation.networkFeeAssetAmount,
            operationId,
            pTokenAddress
        );

        // NOTE: Execute the operation on the target blockchain. If destinationNetworkId is equivalent to
        // interimChainNetworkId, then the effectiveOperationAssetAmount would be the result of operation.assetAmount minus
        // the associated fee. However, if destinationNetworkId is not the same as interimChainNetworkId, the effectiveOperationAssetAmount
        // is equivalent to operation.assetAmount. In this case, as the operation originates from the interim chain, the operation.assetAmount
        // doesn't include the fee. This is because when the UserOperation event is triggered, and the interimChainNetworkId
        // does not equal operation.destinationNetworkId, the event contains the effectiveOperationAssetAmount.
        address destinationAddress = Utils.hexStringToAddress(operation.destinationAccount);
        if (effectiveOperationAssetAmount > 0) {
            IPToken(pTokenAddress).protocolMint(destinationAddress, effectiveOperationAssetAmount);

            if (Utils.isBitSet(operation.optionsMask, 0)) {
                if (!Network.isCurrentNetwork(operation.underlyingAssetNetworkId)) {
                    revert InvalidNetwork(operation.underlyingAssetNetworkId, Network.getCurrentNetworkId());
                }
                IPToken(pTokenAddress).protocolBurn(destinationAddress, effectiveOperationAssetAmount);
            }
        }

        if (operation.userData.length > 0) {
            if (destinationAddress.code.length == 0) revert NotContract(destinationAddress);

            try
                IPReceiver(destinationAddress).receiveUserData(
                    operation.originNetworkId,
                    operation.originAccount,
                    operation.userData
                )
            {} catch {}
        }

        _releaseOperationLockedAmountChallengePeriod(operationId);
        emit OperationExecuted(operation);
    }

    /// @inheritdoc IPNetworkHub
    function protocolQueueOperation(Operation calldata operation) external payable {
        _checkLockDownMode();

        if (msg.value != lockedAmountChallengePeriod) {
            revert InvalidLockedAmountChallengePeriod(msg.value, lockedAmountChallengePeriod);
        }

        if (numberOfOperationsInQueue >= maxOperationsInQueue) {
            revert QueueFull();
        }

        bytes32 operationId = operationIdOf(operation);

        OperationStatus operationStatus = _operationsStatus[operationId];
        if (operationStatus != OperationStatus.NotQueued) {
            revert InvalidOperationStatus(operationStatus, OperationStatus.NotQueued);
        }

        _operationsRelayerQueueAction[operationId] = Action({actor: _msgSender(), timestamp: uint64(block.timestamp)});
        _operationsStatus[operationId] = OperationStatus.Queued;
        unchecked {
            ++numberOfOperationsInQueue;
        }

        emit OperationQueued(operation);
    }

    /// @inheritdoc IPNetworkHub
    function slashByChallenge(Challenge calldata challenge) external {
        bytes32 challengeId = challengeIdOf(challenge);
        uint16 currentEpoch = IEpochsManager(epochsManager).currentEpoch();
        ChallengeStatus challengeStatus = _epochsChallengesStatus[currentEpoch][challengeId];

        // NOTE: avoid to slash by challenges opened in previous epochs
        if (challengeStatus == ChallengeStatus.Null) {
            revert ChallengeNotFound(challenge);
        }

        if (challengeStatus != ChallengeStatus.Pending) {
            revert InvalidChallengeStatus(challengeStatus, ChallengeStatus.Pending);
        }

        if (block.timestamp <= challenge.timestamp + challengeDuration) {
            revert MaxChallengeDurationNotPassed();
        }

        _epochsChallengesStatus[currentEpoch][challengeId] = ChallengeStatus.Unsolved;
        _epochsActorsStatus[currentEpoch][challenge.actor] = ActorStatus.Inactive;
        delete _epochsActorsPendingChallengeId[currentEpoch][challenge.actor];

        Utils.sendEther(challenge.challenger, lockedAmountStartChallenge);

        unchecked {
            ++_epochsTotalNumberOfInactiveActors[currentEpoch][challenge.actorType];
        }

        bytes4 currentNetworkId = Network.getCurrentNetworkId();
        if (currentNetworkId == interimChainNetworkId) {
            // NOTE: If a slash happens on the interim chain we can avoid to emit the UserOperation
            //  in order to speed up the slashing process
            IPReceiver(slasher).receiveUserData(
                currentNetworkId,
                Utils.addressToHexString(address(this)),
                abi.encode(challenge.actor, challenge.challenger)
            );
        } else {
            emit UserOperation(
                gasleft(),
                Utils.addressToHexString(address(this)),
                Utils.addressToHexString(slasher),
                interimChainNetworkId,
                "",
                "",
                0,
                address(0),
                bytes4(0),
                address(0),
                0,
                0,
                0,
                0,
                0,
                abi.encode(challenge.actor, challenge.challenger),
                bytes32(0),
                true // isForProtocol
            );
        }

        emit ChallengeUnsolved(challenge);
    }

    /// @inheritdoc IPNetworkHub
    function solveChallenge(
        Challenge calldata challenge,
        ActorTypes actorType,
        bytes32[] calldata proof,
        bytes calldata signature
    ) external {
        bytes32 challengeId = challengeIdOf(challenge);
        address actor = ECDSA.recover(ECDSA.toEthSignedMessageHash(challengeId), signature);
        if (actor != challenge.actor || !_isActor(actor, actorType, proof)) {
            revert InvalidActor(actor, actorType);
        }

        _solveChallenge(challenge, challengeId);
    }

    /// @inheritdoc IPNetworkHub
    function startChallenge(address actor, ActorTypes actorType, bytes32[] calldata proof) external payable {
        _checkNearEndOfEpochStartChallenge();
        if (!_isActor(actor, actorType, proof)) {
            revert InvalidActor(actor, actorType);
        }

        _startChallenge(actor, actorType);
    }

    /// @inheritdoc IPNetworkHub
    function userSend(
        string calldata destinationAccount,
        bytes4 destinationNetworkId,
        string calldata underlyingAssetName,
        string calldata underlyingAssetSymbol,
        uint256 underlyingAssetDecimals,
        address underlyingAssetTokenAddress,
        bytes4 underlyingAssetNetworkId,
        address assetTokenAddress,
        uint256 assetAmount,
        uint256 networkFeeAssetAmount,
        uint256 forwardNetworkFeeAssetAmount,
        bytes calldata userData,
        bytes32 optionsMask
    ) external {
        address msgSender = _msgSender();

        if (
            (assetAmount > 0 && assetTokenAddress == address(0)) ||
            (assetAmount == 0 && assetTokenAddress != address(0))
        ) {
            revert InvalidAssetParameters(assetAmount, assetTokenAddress);
        }

        if (networkFeeAssetAmount > assetAmount) {
            revert InvalidNetworkFeeAssetAmount();
        }

        if (assetAmount == 0 && userData.length == 0) {
            revert InvalidUserOperation();
        }

        bool isSendingOnCurrentNetwork = Network.isCurrentNetwork(destinationNetworkId);

        if (assetAmount > 0) {
            address pTokenAddress = IPFactory(factory).getPTokenAddress(
                underlyingAssetName,
                underlyingAssetSymbol,
                underlyingAssetDecimals,
                underlyingAssetTokenAddress,
                underlyingAssetNetworkId
            );
            if (pTokenAddress.code.length == 0) {
                revert PTokenNotCreated(pTokenAddress);
            }

            if (underlyingAssetTokenAddress == assetTokenAddress && isSendingOnCurrentNetwork) {
                IPToken(pTokenAddress).userMint(msgSender, assetAmount);
            } else if (underlyingAssetTokenAddress == assetTokenAddress && !isSendingOnCurrentNetwork) {
                IPToken(pTokenAddress).userMintAndBurn(msgSender, assetAmount);
            } else if (pTokenAddress == assetTokenAddress && !isSendingOnCurrentNetwork) {
                IPToken(pTokenAddress).userBurn(msgSender, assetAmount);
            } else {
                revert InvalidUserOperation();
            }
        }

        uint256 userDataProtocolFeeAssetAmount = 0;
        if (userData.length > 0) {
            userDataProtocolFeeAssetAmount = 1; // TODO: calculate it based on user data length

            address pTokenAddressUserDataProtocolFee = IPFactory(factory).getPTokenAddress(
                UNDERLYING_ASSET_NAME_USER_DATA_PROTOCOL_FEE,
                UNDERLYING_ASSET_SYMBOL_USER_DATA_PROTOCOL_FEE,
                UNDERLYING_ASSET_DECIMALS_USER_DATA_PROTOCOL_FEE,
                UNDERLYING_ASSET_TOKEN_ADDRESS_USER_DATA_PROTOCOL_FEE,
                UNDERLYING_ASSET_NETWORK_ID_USER_DATA_PROTOCOL_FEE
            );
            if (pTokenAddressUserDataProtocolFee.code.length == 0) {
                revert PTokenNotCreated(pTokenAddressUserDataProtocolFee);
            }

            bytes4 currentNetworkId = Network.getCurrentNetworkId();
            if (UNDERLYING_ASSET_NETWORK_ID_USER_DATA_PROTOCOL_FEE == currentNetworkId && !isSendingOnCurrentNetwork) {
                IPToken(pTokenAddressUserDataProtocolFee).userMintAndBurn(msgSender, userDataProtocolFeeAssetAmount);
            } else if (
                UNDERLYING_ASSET_NETWORK_ID_USER_DATA_PROTOCOL_FEE != currentNetworkId && !isSendingOnCurrentNetwork
            ) {
                IPToken(pTokenAddressUserDataProtocolFee).userBurn(msgSender, userDataProtocolFeeAssetAmount);
            } else {
                revert InvalidUserOperation();
            }
        }

        emit UserOperation(
            gasleft(),
            Utils.addressToHexString(msgSender),
            destinationAccount,
            interimChainNetworkId,
            underlyingAssetName,
            underlyingAssetSymbol,
            underlyingAssetDecimals,
            underlyingAssetTokenAddress,
            underlyingAssetNetworkId,
            assetTokenAddress,
            // NOTE: pTokens on host chains have always 18 decimals.
            Utils.normalizeAmountToProtocolFormatOnCurrentNetwork(
                assetAmount,
                underlyingAssetDecimals,
                underlyingAssetNetworkId
            ),
            Utils.normalizeAmountToProtocolFormatOnCurrentNetwork(
                userDataProtocolFeeAssetAmount,
                UNDERLYING_ASSET_DECIMALS_USER_DATA_PROTOCOL_FEE,
                UNDERLYING_ASSET_NETWORK_ID_USER_DATA_PROTOCOL_FEE
            ),
            Utils.normalizeAmountToProtocolFormatOnCurrentNetwork(
                networkFeeAssetAmount,
                underlyingAssetDecimals,
                underlyingAssetNetworkId
            ),
            Utils.normalizeAmountToProtocolFormatOnCurrentNetwork(
                forwardNetworkFeeAssetAmount,
                underlyingAssetDecimals,
                underlyingAssetNetworkId
            ),
            destinationNetworkId,
            userData,
            optionsMask,
            false // isForProtocol
        );
    }

    function _challengePeriodOf(
        bytes32 operationId,
        OperationStatus operationStatus
    ) internal view returns (uint64, uint64) {
        if (operationStatus != OperationStatus.Queued) return (0, 0);

        Action storage queueAction = _operationsRelayerQueueAction[operationId];
        uint64 startTimestamp = queueAction.timestamp;
        uint64 endTimestamp = startTimestamp + getCurrentChallengePeriodDuration();
        if (_operationsTotalCancelActions[operationId] == 0) {
            return (startTimestamp, endTimestamp);
        }

        if (_operationsGuardianCancelAction[operationId].actor != address(0)) {
            endTimestamp += 5 days;
        }

        if (_operationsSentinelCancelAction[operationId].actor != address(0)) {
            endTimestamp += 5 days;
        }

        return (startTimestamp, endTimestamp);
    }

    function _checkActorsStatus() internal view {
        uint16 currentEpoch = IEpochsManager(epochsManager).currentEpoch();
        if (
            _epochsActorsMerkleRoot[currentEpoch] == bytes32(0) ||
            _epochsTotalNumberOfInactiveActors[currentEpoch][ActorTypes.Guardian] ==
            _epochsTotalNumberOfActors[currentEpoch][ActorTypes.Guardian] ||
            _epochsTotalNumberOfInactiveActors[currentEpoch][ActorTypes.Sentinel] ==
            _epochsTotalNumberOfActors[currentEpoch][ActorTypes.Sentinel]
        ) {
            revert LockDown();
        }
    }

    function _checkLockDownMode() internal view {
        _checkActorsStatus();

        uint16 currentEpoch = IEpochsManager(epochsManager).currentEpoch();
        uint256 epochDuration = IEpochsManager(epochsManager).epochDuration();
        uint256 startFirstEpochTimestamp = IEpochsManager(epochsManager).startFirstEpochTimestamp();
        uint256 currentEpochEndTimestamp = startFirstEpochTimestamp + ((currentEpoch + 1) * epochDuration);

        // If a relayer queues a malicious operation shortly before lockdown mode begins, what happens?
        // When lockdown mode is initiated, both sentinels and guardians lose their ability to cancel operations.
        // Consequently, the malicious operation may be executed immediately after the lockdown period ends,
        // especially if the operation's queue time is significantly shorter than the lockdown duration.
        // To mitigate this risk, operations should not be queued if the max challenge period makes
        // the operation challenge period finish after 1 hour before the end of an epoch.
        if (block.timestamp + maxChallengePeriodDuration >= currentEpochEndTimestamp - 1 hours) {
            revert LockDown();
        }
    }

    function _checkNearEndOfEpochStartChallenge() internal view {
        uint256 epochDuration = IEpochsManager(epochsManager).epochDuration();
        uint16 currentEpoch = IEpochsManager(epochsManager).currentEpoch();
        uint256 startFirstEpochTimestamp = IEpochsManager(epochsManager).startFirstEpochTimestamp();
        uint256 currentEpochEndTimestamp = startFirstEpochTimestamp + ((currentEpoch + 1) * epochDuration);

        // NOTE: 1 hours = threshold that a guardian/sentinel or challenger has time to resolve the challenge
        // before the epoch ends. Not setting this threshold would mean that it is possible
        // to open a challenge that can be solved an instant before the epoch change causing problems.
        // It is important that the system enters in lockdown mode before stopping to start challenges.
        // In this way we are sure that no malicious operations can be queued when keep alive mechanism is disabled.
        // currentEpochEndTimestamp - 1 hours - challengeDuration <= currentEpochEndTimestamp - 1 hours - maxChallengePeriodDuration
        // challengeDuration <=  maxChallengePeriodDuration
        // challengeDuration <= baseChallengePeriodDuration + (maxOperationsInQueue * maxOperationsInQueue * kChallengePeriod) - kChallengePeriod
        if (block.timestamp + challengeDuration > currentEpochEndTimestamp - 1 hours) {
            revert NearToEpochEnd();
        }
    }

    function _isActor(address actor, ActorTypes actorType, bytes32[] calldata proof) internal view returns (bool) {
        if (actorType == ActorTypes.Guardian)
        return
            MerkleProof.verify(
                proof,
                _epochsActorsMerkleRoot[IEpochsManager(epochsManager).currentEpoch()],
                keccak256(abi.encodePacked(actor, actorType))
            );
        return true;
    }

    function _maybeCancelPendingChallenge(uint16 epoch, address actor) internal {
        bytes32 pendingChallengeId = _epochsActorsPendingChallengeId[epoch][actor];
        if (pendingChallengeId != bytes32(0)) {
            Challenge storage challenge = _epochsChallenges[epoch][pendingChallengeId];
            delete _epochsActorsPendingChallengeId[epoch][actor];
            _epochsChallengesStatus[epoch][pendingChallengeId] = ChallengeStatus.Cancelled;
            _epochsActorsStatus[epoch][challenge.actor] = ActorStatus.Active; // NOTE: Change Slashed into Active in order to trigger the slash below
            Utils.sendEther(challenge.challenger, lockedAmountStartChallenge);

            emit ChallengeCancelled(challenge);
        }
    }

    function _onGovernanceMessage(bytes memory message) internal override {
        (bytes32 messageType, bytes memory messageData) = abi.decode(message, (bytes32, bytes));

        if (messageType == GOVERNANCE_MESSAGE_ACTORS) {
            (uint16 epoch, uint16 totalNumberOfGuardians, uint16 totalNumberOfSentinels, bytes32 actorsMerkleRoot) = abi
                .decode(messageData, (uint16, uint16, uint16, bytes32));

            _epochsActorsMerkleRoot[epoch] = actorsMerkleRoot;
            _epochsTotalNumberOfActors[epoch][ActorTypes.Guardian] = totalNumberOfGuardians;
            _epochsTotalNumberOfActors[epoch][ActorTypes.Sentinel] = totalNumberOfSentinels;
            return;
        }

        if (messageType == GOVERNANCE_MESSAGE_SLASH_ACTOR) {
            (uint16 epoch, address actor, ActorTypes actorType) = abi.decode(
                messageData,
                (uint16, address, ActorTypes)
            );
            // NOTE: Consider the scenario where a actor's status is 'Challenged', and a GOVERNANCE_MESSAGE_SLASH_ACTOR is received
            // for the same actor before the challenge is resolved or the actor is slashed.
            // If a actor is already 'Challenged', we should:
            // - cancel the current challenge
            // - set to active the state of the actor
            // - send to the challenger the bond
            // - slash it
            _maybeCancelPendingChallenge(epoch, actor);

            if (_epochsActorsStatus[epoch][actor] == ActorStatus.Active) {
                unchecked {
                    ++_epochsTotalNumberOfInactiveActors[epoch][actorType];
                }
                _epochsActorsStatus[epoch][actor] = ActorStatus.Inactive;
                emit ActorSlashed(epoch, actor);
            }
            return;
        }

        if (messageType == GOVERNANCE_MESSAGE_RESUME_ACTOR) {
            (uint16 epoch, address actor, ActorTypes actorType) = abi.decode(
                messageData,
                (uint16, address, ActorTypes)
            );
            if (_epochsActorsStatus[epoch][actor] == ActorStatus.Inactive) {
                unchecked {
                    --_epochsTotalNumberOfInactiveActors[epoch][actorType];
                }

                _epochsActorsStatus[epoch][actor] = ActorStatus.Active;
                emit ActorResumed(epoch, actor);
            }

            return;
        }

        if (messageType == GOVERNANCE_MESSAGE_PROTOCOL_GOVERNANCE_CANCEL_OPERATION) {
            Operation memory operation = abi.decode(messageData, (Operation));
            // TODO; What should i use ad actor address? address(this) ???
            _protocolCancelOperation(operation, operationIdOf(operation), address(this), ActorTypes.Governance);
            return;
        }

        revert InvalidGovernanceMessage(message);
    }

    function _protocolCancelOperation(
        Operation memory operation,
        bytes32 operationId,
        address actor,
        ActorTypes actorType
    ) internal {
        OperationStatus operationStatus = _operationsStatus[operationId];
        if (operationStatus != OperationStatus.Queued) {
            revert InvalidOperationStatus(operationStatus, OperationStatus.Queued);
        }

        (uint64 startTimestamp, uint64 endTimestamp) = _challengePeriodOf(operationId, operationStatus);
        if (uint64(block.timestamp) >= endTimestamp) {
            revert ChallengePeriodTerminated(startTimestamp, endTimestamp);
        }

        Action memory action = Action({actor: actor, timestamp: uint64(block.timestamp)});
        if (actorType == ActorTypes.Governance) {
            address governance = _operationsGovernanceCancelAction[operationId].actor;
            if (governance != address(0)) {
                revert ActorAlreadyCancelledOperation(operation, governance, actorType);
            }

            _operationsGovernanceCancelAction[operationId] = action;
        }
        if (actorType == ActorTypes.Guardian) {
            address guardian = _operationsGuardianCancelAction[operationId].actor;
            if (guardian != address(0)) {
                revert ActorAlreadyCancelledOperation(operation, guardian, actorType);
            }

            _operationsGuardianCancelAction[operationId] = action;
        }
        if (actorType == ActorTypes.Sentinel) {
            address sentinel = _operationsSentinelCancelAction[operationId].actor;
            if (sentinel != address(0)) {
                revert ActorAlreadyCancelledOperation(operation, sentinel, actorType);
            }

            _operationsSentinelCancelAction[operationId] = action;
        }
        emit OperationCancelled(operation, actor, actorType);

        unchecked {
            ++_operationsTotalCancelActions[operationId];
        }
        if (_operationsTotalCancelActions[operationId] == 2) {
            unchecked {
                --numberOfOperationsInQueue;
            }
            _operationsStatus[operationId] = OperationStatus.Cancelled;

            // TODO: send the lockedAmountChallengePeriod to the DAO
            Utils.sendEther(address(0), lockedAmountChallengePeriod);

            emit OperationCancelFinalized(operation);
        }
    }

    function _releaseOperationLockedAmountChallengePeriod(bytes32 operationId) internal {
        _operationsStatus[operationId] = OperationStatus.Executed;
        Action storage queuedAction = _operationsRelayerQueueAction[operationId];
        Utils.sendEther(queuedAction.actor, lockedAmountChallengePeriod);

        unchecked {
            --numberOfOperationsInQueue;
        }
    }

    function _solveChallenge(Challenge calldata challenge, bytes32 challengeId) internal {
        uint16 currentEpoch = IEpochsManager(epochsManager).currentEpoch();
        ChallengeStatus challengeStatus = _epochsChallengesStatus[currentEpoch][challengeId];

        if (challengeStatus == ChallengeStatus.Null) {
            revert ChallengeNotFound(challenge);
        }

        if (challengeStatus != ChallengeStatus.Pending) {
            revert InvalidChallengeStatus(challengeStatus, ChallengeStatus.Pending);
        }

        if (block.timestamp > challenge.timestamp + challengeDuration) {
            revert ChallengeDurationPassed();
        }

        // TODO: send the lockedAmountStartChallenge to the DAO
        Utils.sendEther(address(0), lockedAmountStartChallenge);

        _epochsChallengesStatus[currentEpoch][challengeId] = ChallengeStatus.Solved;
        _epochsActorsStatus[currentEpoch][challenge.actor] = ActorStatus.Active;
        delete _epochsActorsPendingChallengeId[currentEpoch][challenge.actor];
        emit ChallengeSolved(challenge);
    }

    function _startChallenge(address actor, ActorTypes actorType) internal {
        address challenger = _msgSender();
        uint16 currentEpoch = IEpochsManager(epochsManager).currentEpoch();

        if (msg.value != lockedAmountStartChallenge) {
            revert InvalidLockedAmountStartChallenge(msg.value, lockedAmountStartChallenge);
        }

        ActorStatus actorStatus = _epochsActorsStatus[currentEpoch][actor];
        if (actorStatus != ActorStatus.Active) {
            revert InvalidActorStatus(actorStatus, ActorStatus.Active);
        }

        Challenge memory challenge = Challenge({
            nonce: challengesNonce,
            actor: actor,
            challenger: challenger,
            actorType: actorType,
            timestamp: uint64(block.timestamp),
            networkId: Network.getCurrentNetworkId()
        });
        bytes32 challengeId = challengeIdOf(challenge);
        _epochsChallenges[currentEpoch][challengeId] = challenge;
        _epochsChallengesStatus[currentEpoch][challengeId] = ChallengeStatus.Pending;
        _epochsActorsStatus[currentEpoch][actor] = ActorStatus.Challenged;
        _epochsActorsPendingChallengeId[currentEpoch][actor] = challengeId;

        unchecked {
            ++challengesNonce;
        }

        emit ChallengePending(challenge);
    }

    function _takeNetworkFee(
        uint256 operationAmount,
        uint256 operationNetworkFeeAssetAmount,
        bytes32 operationId,
        address pTokenAddress
    ) internal returns (uint256) {
        if (operationNetworkFeeAssetAmount == 0) return operationAmount;

        Action storage queuedAction = _operationsRelayerQueueAction[operationId];

        address queuedActionActor = queuedAction.actor;
        address executedActionActor = _msgSender();
        if (queuedActionActor == executedActionActor) {
            IPToken(pTokenAddress).protocolMint(queuedActionActor, operationNetworkFeeAssetAmount);
            return operationAmount - operationNetworkFeeAssetAmount;
        }

        // NOTE: protocolQueueOperation consumes in avg 117988. protocolExecuteOperation consumes in avg 198928.
        // which results in 37% to networkFeeQueueActor and 63% to networkFeeExecuteActor
        uint256 networkFeeQueueActor = (operationNetworkFeeAssetAmount * 3700) / FEE_BASIS_POINTS_DIVISOR; // 37%
        uint256 networkFeeExecuteActor = (operationNetworkFeeAssetAmount * 6300) / FEE_BASIS_POINTS_DIVISOR; // 63%
        IPToken(pTokenAddress).protocolMint(queuedActionActor, networkFeeQueueActor);
        IPToken(pTokenAddress).protocolMint(executedActionActor, networkFeeExecuteActor);

        return operationAmount - operationNetworkFeeAssetAmount;
    }

    function _takeProtocolFee(Operation calldata operation, address pTokenAddress) internal returns (uint256) {
        if (operation.isForProtocol) {
            return 0;
        }

        uint256 fee = 0;
        if (operation.assetAmount > 0) {
            uint256 feeBps = 20; // 0.2%
            fee = (operation.assetAmount * feeBps) / FEE_BASIS_POINTS_DIVISOR;
            IPToken(pTokenAddress).protocolMint(address(this), fee);
            IPToken(pTokenAddress).approve(feesManager, fee);
            IFeesManager(feesManager).depositFee(pTokenAddress, fee);
        }

        if (operation.userData.length > 0) {
            address pTokenAddressUserDataProtocolFee = IPFactory(factory).getPTokenAddress(
                UNDERLYING_ASSET_NAME_USER_DATA_PROTOCOL_FEE,
                UNDERLYING_ASSET_SYMBOL_USER_DATA_PROTOCOL_FEE,
                UNDERLYING_ASSET_DECIMALS_USER_DATA_PROTOCOL_FEE,
                UNDERLYING_ASSET_TOKEN_ADDRESS_USER_DATA_PROTOCOL_FEE,
                UNDERLYING_ASSET_NETWORK_ID_USER_DATA_PROTOCOL_FEE
            );

            IPToken(pTokenAddressUserDataProtocolFee).protocolMint(
                address(this),
                operation.userDataProtocolFeeAssetAmount
            );
            IPToken(pTokenAddressUserDataProtocolFee).approve(feesManager, operation.userDataProtocolFeeAssetAmount);
            IFeesManager(feesManager).depositFee(
                pTokenAddressUserDataProtocolFee,
                operation.userDataProtocolFeeAssetAmount
            );
        }

        return operation.assetAmount - fee;
    }
}
pragma solidity ^0.8.19;

import {Network} from "../libraries/Network.sol";
import {IPRegistry} from "../interfaces/IPRegistry.sol";

error NotDandelionVoting(address dandelionVoting, address expectedDandelionVoting);
error NetworkAlreadyAdded(bytes4 networkId);

contract PRegistry is IPRegistry {
    address public immutable dandelionVoting;

    address[] private _supportedHubs;
    uint32[] private _supportedChainIds;
    mapping(bytes4 => address) _networkIdToHub;
    mapping(bytes4 => uint32) _networkIdToChainId;

    modifier onlyDandelionVoting() {
        if (msg.sender != dandelionVoting) {
            revert NotDandelionVoting(msg.sender, dandelionVoting);
        }

        _;
    }

    constructor(address dandelionVoting_) {
        dandelionVoting = dandelionVoting_;
    }

    // @inheritdoc IPRegistry
    function isNetworkIdSupported(bytes4 networkId) public view returns (bool) {
        address hub = _networkIdToHub[networkId];
        return (hub != address(0));
    }

    // @inheritdoc IPRegistry
    function isChainIdSupported(uint32 chainId) external view returns (bool) {
        bytes4 networkId = Network.getNetworkIdFromChainId(chainId);
        return isNetworkIdSupported(networkId);
    }

    // @inheritdoc IPRegistry
    function getChainIdByNetworkId(bytes4 networkId) external view returns (uint32) {
        return _networkIdToChainId[networkId];
    }

    // @inheritdoc IPRegistry
    function getHubByNetworkId(bytes4 networkId) external view returns (address) {
        return _networkIdToHub[networkId];
    }

    // @inheritdoc IPRegistry
    function getSupportedHubs() external view returns (address[] memory) {
        return _supportedHubs;
    }

    // @inheritdoc IPRegistry
    function getSupportedChainIds() external view returns (uint32[] memory) {
        return _supportedChainIds;
    }

    // @inheritdoc IPRegistry
    function protocolAddNetwork(uint32 chainId, address hub) external onlyDandelionVoting {
        bytes4 networkId = Network.getNetworkIdFromChainId(chainId);

        if (_networkIdToHub[networkId] != address(0)) {
            revert NetworkAlreadyAdded(networkId);
        }

        _supportedHubs.push(hub);
        _supportedChainIds.push(chainId);
        _networkIdToHub[networkId] = hub;
        _networkIdToChainId[networkId] = chainId;
        emit NetworkAdded(networkId, chainId, hub);
    }
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {IERC20Metadata} from "@openzeppelin/contracts/interfaces/IERC20Metadata.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {IPToken} from "../interfaces/IPToken.sol";
import {Utils} from "../libraries/Utils.sol";
import {Network} from "../libraries/Network.sol";

error InvalidUnderlyingAssetName(string underlyingAssetName, string expectedUnderlyingAssetName);
error InvalidUnderlyingAssetSymbol(string underlyingAssetSymbol, string expectedUnderlyingAssetSymbol);
error InvalidUnderlyingAssetDecimals(uint256 underlyingAssetDecimals, uint256 expectedUnderlyingAssetDecimals);
error InvalidAssetParameters(uint256 assetAmount, address assetTokenAddress);
error SenderIsNotHub();
error InvalidNetwork(bytes4 networkId);

contract PToken is IPToken, ERC20 {
    using SafeERC20 for IERC20Metadata;

    address public immutable hub;
    address public immutable underlyingAssetTokenAddress;
    bytes4 public immutable underlyingAssetNetworkId;
    uint256 public immutable underlyingAssetDecimals;
    string public underlyingAssetName;
    string public underlyingAssetSymbol;

    modifier onlyHub() {
        if (_msgSender() != hub) {
            revert SenderIsNotHub();
        }
        _;
    }

    constructor(
        string memory underlyingAssetName_,
        string memory underlyingAssetSymbol_,
        uint256 underlyingAssetDecimals_,
        address underlyingAssetTokenAddress_,
        bytes4 underlyingAssetNetworkId_,
        address hub_
    ) ERC20(string.concat("p", underlyingAssetName_), string.concat("p", underlyingAssetSymbol_)) {
        if (Network.isCurrentNetwork(underlyingAssetNetworkId_)) {
            string memory expectedUnderlyingAssetName = IERC20Metadata(underlyingAssetTokenAddress_).name();
            if (
                keccak256(abi.encodePacked(underlyingAssetName_)) !=
                keccak256(abi.encodePacked(expectedUnderlyingAssetName))
            ) {
                revert InvalidUnderlyingAssetName(underlyingAssetName_, expectedUnderlyingAssetName);
            }

            string memory expectedUnderlyingAssetSymbol = IERC20Metadata(underlyingAssetTokenAddress_).symbol();
            if (
                keccak256(abi.encodePacked(underlyingAssetSymbol_)) !=
                keccak256(abi.encodePacked(expectedUnderlyingAssetSymbol))
            ) {
                revert InvalidUnderlyingAssetSymbol(underlyingAssetName, expectedUnderlyingAssetName);
            }

            uint256 expectedUnderliyngAssetDecimals = IERC20Metadata(underlyingAssetTokenAddress_).decimals();
            if (underlyingAssetDecimals_ != expectedUnderliyngAssetDecimals || expectedUnderliyngAssetDecimals > 18) {
                revert InvalidUnderlyingAssetDecimals(underlyingAssetDecimals_, expectedUnderliyngAssetDecimals);
            }
        }

        underlyingAssetName = underlyingAssetName_;
        underlyingAssetSymbol = underlyingAssetSymbol_;
        underlyingAssetNetworkId = underlyingAssetNetworkId_;
        underlyingAssetTokenAddress = underlyingAssetTokenAddress_;
        underlyingAssetDecimals = underlyingAssetDecimals_;
        hub = hub_;
    }

    /// @inheritdoc IPToken
    function burn(uint256 amount) external {
        _burnAndReleaseCollateral(_msgSender(), amount);
    }

    /// @inheritdoc IPToken
    function mint(uint256 amount) external {
        _takeCollateralAndMint(_msgSender(), amount);
    }

    /// @inheritdoc IPToken
    function protocolMint(address account, uint256 amount) external onlyHub {
        _mint(account, amount);
    }

    /// @inheritdoc IPToken
    function protocolBurn(address account, uint256 amount) external onlyHub {
        _burnAndReleaseCollateral(account, amount);
    }

    /// @inheritdoc IPToken
    function userMint(address account, uint256 amount) external onlyHub {
        _takeCollateralAndMint(account, amount);
    }

    /// @inheritdoc IPToken
    function userMintAndBurn(address account, uint256 amount) external onlyHub {
        _takeCollateral(account, amount);
        uint256 normalizedAmount = Utils.normalizeAmountToProtocolFormat(amount, underlyingAssetDecimals);
        emit Transfer(address(0), account, normalizedAmount);
        emit Transfer(account, address(0), normalizedAmount);
    }

    /// @inheritdoc IPToken
    function userBurn(address account, uint256 amount) external onlyHub {
        _burn(account, amount);
    }

    function _burnAndReleaseCollateral(address account, uint256 amount) internal {
        if (!Network.isCurrentNetwork(underlyingAssetNetworkId)) revert InvalidNetwork(underlyingAssetNetworkId);
        _burn(account, amount);
        IERC20Metadata(underlyingAssetTokenAddress).safeTransfer(
            account,
            Utils.normalizeAmountToOriginalFormat(amount, underlyingAssetDecimals)
        );
    }

    function _takeCollateral(address account, uint256 amount) internal {
        if (!Network.isCurrentNetwork(underlyingAssetNetworkId)) revert InvalidNetwork(underlyingAssetNetworkId);
        IERC20Metadata(underlyingAssetTokenAddress).safeTransferFrom(account, address(this), amount);
    }

    function _takeCollateralAndMint(address account, uint256 amount) internal {
        _takeCollateral(account, amount);
        _mint(account, Utils.normalizeAmountToProtocolFormat(amount, underlyingAssetDecimals));
    }
}
// SPDX-License-Identifier: Unlicense

pragma solidity ^0.8.19;

import {Utils} from "../libraries/Utils.sol";
import {IPRegistry} from "../interfaces/IPRegistry.sol";
import {ISlasher} from "../interfaces/ISlasher.sol";
import {IRegistrationManager} from "./IRegistrationManager.sol";

error NotHub(address hub);
error NotSupportedNetworkId(bytes4 originNetworkId);

contract Slasher is ISlasher {
    address public immutable pRegistry;
    address public immutable registrationManager;

    // Quantity of PNT to slash
    uint256 public immutable stakingSentinelAmountToSlash;

    constructor(address pRegistry_, address registrationManager_, uint256 stakingSentinelAmountToSlash_) {
        pRegistry = pRegistry_;
        stakingSentinelAmountToSlash = stakingSentinelAmountToSlash_;
        registrationManager = registrationManager_;
    }

    function receiveUserData(
        bytes4 originNetworkId,
        string calldata originAccount,
        bytes calldata userData
    ) external override {
        address originAccountAddress = Utils.hexStringToAddress(originAccount);

        if (!IPRegistry(pRegistry).isNetworkIdSupported(originNetworkId)) revert NotSupportedNetworkId(originNetworkId);

        address registeredHub = IPRegistry(pRegistry).getHubByNetworkId(originNetworkId);
        if (originAccountAddress != registeredHub) revert NotHub(originAccountAddress);

        (address actor, address challenger) = abi.decode(userData, (address, address));
        IRegistrationManager.Registration memory registration = IRegistrationManager(registrationManager)
            .sentinelRegistration(actor);

        // See file `Constants.sol` in dao-v2-contracts:
        //
        // bytes1 public constant REGISTRATION_SENTINEL_STAKING = 0x01;
        //
        // Borrowing sentinels have nothing at stake, so the slashing
        // quantity will be zero
        uint256 amountToSlash = registration.kind == 0x01 ? stakingSentinelAmountToSlash : 0;
        IRegistrationManager(registrationManager).slash(actor, amountToSlash, challenger);
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {IGovernanceMessageEmitter} from "../interfaces/IGovernanceMessageEmitter.sol";
import {IRegistrationManager} from "@pnetwork-association/dao-v2-contracts/contracts/interfaces/IRegistrationManager.sol";
import {ILendingManager} from "@pnetwork-association/dao-v2-contracts/contracts/interfaces/ILendingManager.sol";
import {IEpochsManager} from "@pnetwork-association/dao-v2-contracts/contracts/interfaces/IEpochsManager.sol";
import {IPRegistry} from "../interfaces/IPRegistry.sol";
import {IPNetworkHub} from "../interfaces/IPNetworkHub.sol";
import {MerkleTree} from "../libraries/MerkleTree.sol";

error InvalidAmount(uint256 amount, uint256 expectedAmount);
error InvalidGovernanceMessageVerifier(address governanceMessagerVerifier, address expectedGovernanceMessageVerifier);
error InvalidSentinelRegistration(bytes1 kind);
error NotRegistrationManager(address registrationManager, address expectedRegistrationManager);
error NotDandelionVoting(address dandelionVoting, address expectedDandelionVoting);
error InvalidNumberOfGuardians(uint16 numberOfGuardians, uint16 expectedNumberOfGuardians);
error NetworkNotSupported(bytes4 networkId);
error InvalidRegistrationKind(bytes1 kind);

contract GovernanceMessageEmitter is IGovernanceMessageEmitter {
    bytes32 public constant GOVERNANCE_MESSAGE_ACTORS = keccak256("GOVERNANCE_MESSAGE_ACTORS");
    bytes32 public constant GOVERNANCE_MESSAGE_SLASH_ACTOR = keccak256("GOVERNANCE_MESSAGE_SLASH_ACTOR");
    bytes32 public constant GOVERNANCE_MESSAGE_RESUME_ACTOR = keccak256("GOVERNANCE_MESSAGE_RESUME_ACTOR");
    bytes32 public constant GOVERNANCE_MESSAGE_PROTOCOL_GOVERNANCE_CANCEL_OPERATION =
        keccak256("GOVERNANCE_MESSAGE_PROTOCOL_GOVERNANCE_CANCEL_OPERATION");

    address public immutable epochsManager;
    address public immutable lendingManager;
    address public immutable registrationManager;
    address public immutable dandelionVoting;
    address public immutable registry;

    uint256 public totalNumberOfMessages;

    modifier onlyRegistrationManager() {
        if (msg.sender != registrationManager) {
            revert NotRegistrationManager(msg.sender, dandelionVoting);
        }

        _;
    }

    modifier onlyDandelionVoting() {
        if (msg.sender != dandelionVoting) {
            revert NotDandelionVoting(msg.sender, dandelionVoting);
        }

        _;
    }

    constructor(
        address epochsManager_,
        address lendingManager_,
        address registrationManager_,
        address dandelionVoting_,
        address registry_
    ) {
        registry = registry_;
        epochsManager = epochsManager_;
        lendingManager = lendingManager_;
        dandelionVoting = dandelionVoting_;
        registrationManager = registrationManager_;
    }

    /// @inheritdoc IGovernanceMessageEmitter
    function propagateActors(address[] calldata guardians, address[] calldata sentinels) external {
        uint16 currentEpoch = IEpochsManager(epochsManager).currentEpoch();

        address[] memory effectiveGuardians = _filterGuardians(guardians);
        address[] memory effectiveSentinels = _filterSentinels(sentinels);

        uint256 length = effectiveGuardians.length + effectiveSentinels.length;
        address[] memory actors = new address[](length);
        IPNetworkHub.ActorTypes[] memory actorsType = new IPNetworkHub.ActorTypes[](length);

        for (uint256 i = 0; i < effectiveGuardians.length; ) {
            actors[i] = effectiveGuardians[i];
            actorsType[i] = IPNetworkHub.ActorTypes.Guardian;
            unchecked {
                ++i;
            }
        }

        for (uint256 i = effectiveGuardians.length; i < length; ) {
            actors[i] = effectiveSentinels[i - effectiveGuardians.length];
            actorsType[i] = IPNetworkHub.ActorTypes.Sentinel;
            unchecked {
                ++i;
            }
        }

        emit ActorsPropagated(currentEpoch, actors);

        _sendMessage(
            abi.encode(
                GOVERNANCE_MESSAGE_ACTORS,
                abi.encode(
                    currentEpoch,
                    effectiveGuardians.length,
                    effectiveSentinels.length,
                    MerkleTree.getRoot(_hashActorAddressesWithType(actors, actorsType))
                )
            )
        );
    }

    /// @inheritdoc IGovernanceMessageEmitter
    function protocolGovernanceCancelOperation(
        IPNetworkHub.Operation calldata operation,
        bytes4 networkId
    ) external onlyDandelionVoting {
        address[] memory hubs = new address[](1);
        uint32[] memory chainIds = new uint32[](1);

        address hub = IPRegistry(registry).getHubByNetworkId(networkId);
        if (hub == address(0)) {
            revert NetworkNotSupported(networkId);
        }

        uint32 chainId = IPRegistry(registry).getChainIdByNetworkId(networkId);
        hubs[0] = hub;
        chainIds[0] = chainId;

        emit GovernanceMessage(
            abi.encode(
                totalNumberOfMessages,
                chainIds,
                hubs,
                abi.encode(GOVERNANCE_MESSAGE_PROTOCOL_GOVERNANCE_CANCEL_OPERATION, abi.encode(operation))
            )
        );

        unchecked {
            ++totalNumberOfMessages;
        }
    }

    /// @inheritdoc IGovernanceMessageEmitter
    function resumeActor(address actor, bytes1 registrationKind) external onlyRegistrationManager {
        _sendMessage(
            abi.encode(
                GOVERNANCE_MESSAGE_RESUME_ACTOR,
                abi.encode(
                    IEpochsManager(epochsManager).currentEpoch(),
                    actor,
                    _getActorTypeByRegistrationKind(registrationKind)
                )
            )
        );
    }

    /// @inheritdoc IGovernanceMessageEmitter
    function slashActor(address actor, bytes1 registrationKind) external onlyRegistrationManager {
        _sendMessage(
            abi.encode(
                GOVERNANCE_MESSAGE_SLASH_ACTOR,
                abi.encode(
                    IEpochsManager(epochsManager).currentEpoch(),
                    actor,
                    _getActorTypeByRegistrationKind(registrationKind)
                )
            )
        );
    }

    function _filterGuardians(address[] calldata guardians) internal view returns (address[] memory) {
        uint16 currentEpoch = IEpochsManager(epochsManager).currentEpoch();
        // uint16 totalNumberOfGuardians = IRegistrationManager(registrationManager).totalNumberOfGuardiansByEpoch(
        //     currentEpoch
        // );

        // uint16 numberOfValidGuardians;
        // for (uint16 index = 0; index < guardians; ) {
        //     IRegistrationManager.Registration memory registration = IRegistrationManager(registrationManager)
        //         .guardianRegistration(guardians[index]);

        //     if (registration.kind == 0x03 && currentEpoch >= registration.startEpoch && currentEpoch <= registration.endEpoch) {
        //         unchecked {
        //             ++numberOfValidGuardians;
        //         }
        //     }
        //     unchecked {
        //         ++index;
        //     }
        // }

        // if (totalNumberOfGuardians != numberOfValidGuardians) {
        //     revert InvalidNumberOfGuardians(numberOfValidGuardians, totalNumberOfGuardians);
        // }

        return guardians;
    }

    function _filterSentinels(address[] memory sentinels) internal view returns (address[] memory) {
        uint16 currentEpoch = IEpochsManager(epochsManager).currentEpoch();
        uint32 totalBorrowedAmount = ILendingManager(lendingManager).totalBorrowedAmountByEpoch(currentEpoch);
        uint256 totalSentinelStakedAmount = IRegistrationManager(registrationManager).totalSentinelStakedAmountByEpoch(
            currentEpoch
        );
        uint256 totalAmount = totalBorrowedAmount + totalSentinelStakedAmount;

        int256[] memory validIndexes = new int256[](sentinels.length);
        uint256 totalValidSentinels = 0;
        uint256 cumulativeAmount = 0;

        // NOTE: be sure that totalSentinelStakedAmount + totalBorrowedAmount = cumulativeAmount.
        // There could be also sentinels that has less than 200k PNT because of slashing.
        // These sentinels will be filtered in the next step
        for (uint256 index; index < sentinels.length; ) {
            IRegistrationManager.Registration memory registration = IRegistrationManager(registrationManager)
                .sentinelRegistration(sentinels[index]);

            bytes1 registrationKind = registration.kind;
            if (registrationKind == 0x01) {
                // NOTE: no need to check startEpoch and endEpoch since we are using sentinelStakedAmountByEpochOf
                uint256 amount = IRegistrationManager(registrationManager).sentinelStakedAmountByEpochOf(
                    sentinels[index],
                    currentEpoch
                );
                cumulativeAmount += amount;
                if (amount >= 200000) {
                    validIndexes[index] = int256(index);
                    unchecked {
                        totalValidSentinels++;
                    }
                } else {
                    validIndexes[index] = -1;
                }
            } else if (
                registrationKind == 0x02 &&
                currentEpoch >= registration.startEpoch &&
                currentEpoch <= registration.endEpoch
            ) {
                cumulativeAmount += 200000;
                validIndexes[index] = int256(index);
                unchecked {
                    totalValidSentinels++;
                }
            } else {
                revert InvalidSentinelRegistration(registrationKind);
            }

            unchecked {
                ++index;
            }
        }

        if (totalAmount != cumulativeAmount) {
            revert InvalidAmount(totalAmount, cumulativeAmount);
        }

        address[] memory effectiveSentinels = new address[](totalValidSentinels);
        uint256 j = 0;
        for (uint256 i = 0; i < validIndexes.length; ) {
            int256 validIndex = validIndexes[i];
            if (validIndex != -1) {
                effectiveSentinels[j] = sentinels[uint256(validIndex)];
                unchecked {
                    j++;
                }
            }
            unchecked {
                i++;
            }
        }

        return effectiveSentinels;
    }

    function _getActorTypeByRegistrationKind(bytes1 registrationKind) internal pure returns (IPNetworkHub.ActorTypes) {
        if (registrationKind == 0x01) return IPNetworkHub.ActorTypes.Sentinel;
        if (registrationKind == 0x02) return IPNetworkHub.ActorTypes.Sentinel;
        if (registrationKind == 0x03) return IPNetworkHub.ActorTypes.Guardian;
        revert InvalidRegistrationKind(registrationKind);
    }

    function _hashActorAddressesWithType(
        address[] memory actors,
        IPNetworkHub.ActorTypes[] memory actorTypes
    ) internal pure returns (bytes32[] memory) {
        bytes32[] memory data = new bytes32[](actors.length);
        for (uint256 i = 0; i < actors.length; i++) {
            data[i] = keccak256(abi.encodePacked(actors[i], actorTypes[i]));
        }
        return data;
    }

    function _sendMessage(bytes memory message) internal {
        address[] memory hubs = IPRegistry(registry).getSupportedHubs();
        uint32[] memory chainIds = IPRegistry(registry).getSupportedChainIds();

        emit GovernanceMessage(abi.encode(totalNumberOfMessages, chainIds, hubs, message));

        unchecked {
            ++totalNumberOfMessages;
        }
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Context} from "@openzeppelin/contracts/utils/Context.sol";
import {IGovernanceMessageHandler} from "../interfaces/IGovernanceMessageHandler.sol";
import {ITelepathyHandler} from "../interfaces/external/ITelepathyHandler.sol";

error NotRouter(address sender, address router);
error UnsupportedChainId(uint32 sourceChainId, uint32 expectedSourceChainId);
error InvalidGovernanceMessageVerifier(address governanceMessagerVerifier, address expectedGovernanceMessageVerifier);

abstract contract GovernanceMessageHandler is IGovernanceMessageHandler, Context {
    address public immutable telepathyRouter;
    address public immutable governanceMessageVerifier;
    uint32 public immutable expectedSourceChainId;

    constructor(address telepathyRouter_, address governanceMessageVerifier_, uint32 expectedSourceChainId_) {
        telepathyRouter = telepathyRouter_;
        governanceMessageVerifier = governanceMessageVerifier_;
        expectedSourceChainId = expectedSourceChainId_;
    }

    function handleTelepathy(uint32 sourceChainId, address sourceSender, bytes memory data) external returns (bytes4) {
        // address msgSender = _msgSender();
        // if (msgSender != telepathyRouter) revert NotRouter(msgSender, telepathyRouter);
        // NOTE: we just need to check the address that called the telepathy router (GovernanceMessageVerifier)
        // and not who emitted the event on Polygon since it's the GovernanceMessageVerifier that verifies that
        // a certain event has been emitted by the GovernanceMessageEmitter

        // if (sourceChainId != expectedSourceChainId) {
        //     revert UnsupportedChainId(sourceChainId, expectedSourceChainId);
        // }

        // if (sourceSender != governanceMessageVerifier) {
        //     revert InvalidGovernanceMessageVerifier(sourceSender, governanceMessageVerifier);
        // }

        _onGovernanceMessage(data);

        return ITelepathyHandler.handleTelepathy.selector;
    }

    function _onGovernanceMessage(bytes memory message) internal virtual {}
}
pragma solidity ^0.8.19;

interface ITelepathyHandler {
    function handleTelepathy(uint32 sourceChainId, address sourceSender, bytes memory data) external returns (bytes4);
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {IPNetworkHub} from "./IPNetworkHub.sol";

/**
 * @title IGovernanceMessageEmitter
 * @author pNetwork
 *
 * @notice
 */

interface IGovernanceMessageEmitter {
    /**
     * @dev Emitted when a governance message must be propagated on the other chains
     *
     * @param data The data
     */
    event GovernanceMessage(bytes data);

    /**
     * @dev Emitted when actors are emitted.
     *
     * @param epoch The epoch
     * @param actors The actors
     */
    event ActorsPropagated(uint16 indexed epoch, address[] actors);

    /*
     * @notice Emit a GovernanceMessage event containing the total number of actors (sentinels and guardians) and
     *         the actors merkle root for the current epoch. This message will be verified by GovernanceMessageVerifier.
     *
     * @param sentinels
     * @param guardians
     */
    function propagateActors(address[] calldata sentinels, address[] calldata guardians) external;

    /*
     * @notice Emit a GovernanceMessage to cancel an operation on a given network
     *
     * @param operation
     * @param networkId
     */
    function protocolGovernanceCancelOperation(IPNetworkHub.Operation calldata operation, bytes4 networkId) external;

    /*
     * @notice Emit a GovernanceMessage event containing the address and the type of the resumed actor
     *
     * @param actor
     * @param registrationKind
     */
    function resumeActor(address actor, bytes1 registrationKind) external;

    /*
     * @notice Emit a GovernanceMessage event containing the address and the type of the slashed actor
     *
     * @param actor
     * @param registrationKind
     */
    function slashActor(address actor, bytes1 registrationKind) external;
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {ITelepathyHandler} from "../interfaces/external/ITelepathyHandler.sol";

/**
 * @title IGovernanceMessageHandler
 * @author pNetwork
 *
 * @notice
 */

interface IGovernanceMessageHandler is ITelepathyHandler {

}
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

/**
 * @title IPFactory
 * @author pNetwork
 *
 * @notice
 */
interface IPFactory {
    event PTokenDeployed(address pTokenAddress);

    function deploy(
        string memory underlyingAssetName,
        string memory underlyingAssetSymbol,
        uint256 underlyingAssetDecimals,
        address underlyingAssetTokenAddress,
        bytes4 underlyingAssetNetworkId
    ) external payable returns (address);

    function getBytecode(
        string memory underlyingAssetName,
        string memory underlyingAssetSymbol,
        uint256 underlyingAssetDecimals,
        address underlyingAssetTokenAddress,
        bytes4 underlyingAssetNetworkId
    ) external view returns (bytes memory);

    function getPTokenAddress(
        string memory underlyingAssetName,
        string memory underlyingAssetSymbol,
        uint256 underlyingAssetDecimals,
        address underlyingAssetTokenAddress,
        bytes4 underlyingAssetNetworkId
    ) external view returns (address);

    function setHub(address _hub) external;
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {IGovernanceMessageHandler} from "./IGovernanceMessageHandler.sol";

/**
 * @title IPNetworkHub
 * @author pNetwork
 *
 * @notice
 */
interface IPNetworkHub is IGovernanceMessageHandler {
    enum ActorTypes {
        Governance,
        Guardian,
        Sentinel
    }

    enum ActorStatus {
        Active,
        Challenged,
        Inactive
    }

    enum ChallengeStatus {
        Null,
        Pending,
        Solved,
        Unsolved,
        PartiallyUnsolved,
        Cancelled
    }

    enum OperationStatus {
        NotQueued,
        Queued,
        Executed,
        Cancelled
    }

    struct Action {
        address actor;
        uint64 timestamp;
    }

    struct Challenge {
        uint256 nonce;
        address actor;
        address challenger;
        ActorTypes actorType;
        uint64 timestamp;
        bytes4 networkId;
    }

    struct Operation {
        bytes32 originBlockHash;
        bytes32 originTransactionHash;
        bytes32 optionsMask;
        uint256 nonce;
        uint256 underlyingAssetDecimals;
        uint256 assetAmount;
        uint256 userDataProtocolFeeAssetAmount;
        uint256 networkFeeAssetAmount;
        uint256 forwardNetworkFeeAssetAmount;
        address underlyingAssetTokenAddress;
        bytes4 originNetworkId;
        bytes4 destinationNetworkId;
        bytes4 forwardDestinationNetworkId;
        bytes4 underlyingAssetNetworkId;
        string originAccount;
        string destinationAccount;
        string underlyingAssetName;
        string underlyingAssetSymbol;
        bytes userData;
        bool isForProtocol;
    }

    /**
     * @dev Emitted when an actor is resumed after having being slashed
     *
     * @param epoch The epoch in which the actor has been resumed
     * @param actor The resumed actor
     */
    event ActorResumed(uint16 indexed epoch, address indexed actor);

    /**
     * @dev Emitted when an actor has been slashed on the interim chain.
     *
     * @param epoch The epoch in which the actor has been slashed
     * @param actor The slashed actor
     */
    event ActorSlashed(uint16 indexed epoch, address indexed actor);

    /**
     * @dev Emitted when a challenge is cancelled.
     *
     * @param challenge The challenge
     */
    event ChallengeCancelled(Challenge challenge);

    /**
     * @dev Emitted when a challenger claims the lockedAmountStartChallenge by providing a challenge.
     *
     * @param challenge The challenge
     */
    event ChallengePartiallyUnsolved(Challenge challenge);

    /**
     * @dev Emitted when a challenge is started.
     *
     * @param challenge The challenge
     */
    event ChallengePending(Challenge challenge);

    /**
     * @dev Emitted when a challenge is solved.
     *
     * @param challenge The challenge
     */
    event ChallengeSolved(Challenge challenge);

    /**
     * @dev Emitted when a challenge is used to slash an actor.
     *
     * @param challenge The challenge
     */
    event ChallengeUnsolved(Challenge challenge);

    /**
     * @dev Emitted when an operation is queued.
     *
     * @param operation The queued operation
     */
    event OperationQueued(Operation operation);

    /**
     * @dev Emitted when an operation is executed.
     *
     * @param operation The executed operation
     */
    event OperationExecuted(Operation operation);

    /**
     * @dev Emitted when an operation is cancelled.
     *
     * @param operation The cancelled operation
     */
    event OperationCancelFinalized(Operation operation);

    /**
     * @dev Emitted when an actor instructs a cancel operation.
     *
     * @param operation The cancelled operation
     * @param actor the actor
     * @param actorType the actor type
     */
    event OperationCancelled(Operation operation, address indexed actor, ActorTypes indexed actorType);

    /**
     * @dev Emitted when an user operation is generated.
     *
     * @param nonce The nonce
     * @param originAccount The account that triggered the user operation
     * @param destinationAccount The account to which the funds will be delivered
     * @param destinationNetworkId The destination network id
     * @param underlyingAssetName The name of the underlying asset
     * @param underlyingAssetSymbol The symbol of the underlying asset
     * @param underlyingAssetDecimals The number of decimals of the underlying asset
     * @param underlyingAssetTokenAddress The address of the underlying asset
     * @param underlyingAssetNetworkId The network id of the underlying asset
     * @param assetTokenAddress The asset token address
     * @param assetAmount The asset mount
     * @param userDataProtocolFeeAssetAmount the protocol fee asset amount for the user data
     * @param networkFeeAssetAmount the network fee asset amount
     * @param forwardNetworkFeeAssetAmount the forward network fee asset amount
     * @param forwardDestinationNetworkId the forward destination network id
     * @param userData The user data
     * @param optionsMask The options
     */
    event UserOperation(
        uint256 nonce,
        string originAccount,
        string destinationAccount,
        bytes4 destinationNetworkId,
        string underlyingAssetName,
        string underlyingAssetSymbol,
        uint256 underlyingAssetDecimals,
        address underlyingAssetTokenAddress,
        bytes4 underlyingAssetNetworkId,
        address assetTokenAddress,
        uint256 assetAmount,
        uint256 userDataProtocolFeeAssetAmount,
        uint256 networkFeeAssetAmount,
        uint256 forwardNetworkFeeAssetAmount,
        bytes4 forwardDestinationNetworkId,
        bytes userData,
        bytes32 optionsMask,
        bool isForProtocol
    );

    /*
     * @notice Calculates the challenge id.
     *
     * @param challenge
     *
     * @return bytes32 representing the challenge id.
     */
    function challengeIdOf(Challenge memory challenge) external view returns (bytes32);

    /*
     * @notice Calculates the operation challenge period.
     *
     * @param operation
     *
     * @return (uint64, uin64) representing the start and end timestamp of an operation challenge period.
     */
    function challengePeriodOf(Operation calldata operation) external view returns (uint64, uint64);

    /*
     * @notice Offer the possibilty to claim the lockedAmountStartChallenge for a given challenge in a previous epoch in case it happens the following scenario:
     *          - A challenger initiates a challenge against a guardian/sentinel close to an epoch's end (within permissible limits).
     *          - The maxChallengeDuration elapses, disabling the sentinel from resolving the challenge within the currentEpoch.
     *          - The challenger fails to invoke slashByChallenge before the epoch terminates.
     *          - A new epoch initiates.
     *          - Result: lockedAmountStartChallenge STUCK.
     *
     * @param challenge
     *
     */
    function claimLockedAmountStartChallenge(Challenge calldata challenge) external;

    /*
     * @notice Return the epoch in which a challenge was started.
     *
     * @param challenge
     *
     * @return uint16 representing the epoch in which a challenge was started.
     */
    function getChallengeEpoch(Challenge calldata challenge) external view returns (uint16);

    /*
     * @notice Return the status of a challenge.
     *
     * @param challenge
     *
     * @return (ChallengeStatus) representing the challenge status
     */
    function getChallengeStatus(Challenge calldata challenge) external view returns (ChallengeStatus);

    /*
     * @notice Calculates the current active actors duration which is use to secure the system when few there are few active actors.
     *
     * @return uint64 representing the current active actors duration.
     */
    //function getCurrentActiveActorsAdjustmentDuration() external view returns (uint64);

    /*
     * @notice Calculates the current challenge period duration considering the number of operations in queue and the total number of active actors.
     *
     * @return uint64 representing the current challenge period duration.
     */
    function getCurrentChallengePeriodDuration() external view returns (uint64);

    /*
     * @notice Calculates the adjustment duration based on the total number of operations in queue.
     *
     * @return uint64 representing the adjustment duration based on the total number of operations in queue.
     */
    function getCurrentQueuedOperationsAdjustmentDuration() external view returns (uint64);

    /*
     * @notice Returns the pending challenge id for an actor in a given epoch.
     *
     * @param epoch
     * @param actor
     *
     * @return bytes32 representing the pending challenge id for an actor in a given epoch.
     */
    function getPendingChallengeIdByEpochOf(uint16 epoch, address actor) external view returns (bytes32);

    /*
     * @notice Returns the total number of inactive actors in an epoch.
     *
     * @param epoch
     * @param actorType
     *
     * @return uint16 representing the total number of inactive actors in an epoch.
     */
    function getTotalNumberOfInactiveActorsByEpochAndType(
        uint16 epoch,
        ActorTypes actorType
    ) external view returns (uint16);

    /*
     * @notice Return the status of an operation.
     *
     * @param operation
     *
     * @return (OperationStatus) the operation status.
     */
    function operationStatusOf(Operation calldata operation) external view returns (OperationStatus);

    /*
     * @notice Calculates the operation id.
     *
     * @param operation
     *
     * @return (bytes32) the operation id.
     */
    function operationIdOf(Operation memory operation) external pure returns (bytes32);

    /*
     * @notice The Governance instruct a cancel action. If 2 actors agree on it the operation is cancelled.
     *          This function can be invoked ONLY by the DandelionVoting contract ONLY on the interim chain
     *
     * @param operation
     *
     */
    function protocolGovernanceCancelOperation(Operation calldata operation) external;

    /*
     * @notice An actor instruct a cancel action. If 2 actors agree on it the operation is cancelled.
     *
     * @param operation
     * @param actorType
     * @param proof
     * @param signature
     *
     */
    function protocolCancelOperation(
        Operation calldata operation,
        ActorTypes actorType,
        bytes32[] calldata proof,
        bytes calldata signature
    ) external;

    /*
     * @notice Execute an operation that has been queued.
     *
     * @param operation
     *
     */
    function protocolExecuteOperation(Operation calldata operation) external payable;

    /*
     * @notice Queue an operation.
     *
     * @param operation
     *
     */
    function protocolQueueOperation(Operation calldata operation) external payable;

    /*
     * @notice Slash a sentinel of a guardians previously challenges if it was not able to solve the challenge in time.
     *
     * @param challenge
     *
     */
    function slashByChallenge(Challenge calldata challenge) external;

    /*
     * @notice Solve a challenge of an actor and sends the bond (lockedAmountStartChallenge) to the DAO.
     *
     * @param challenge
     * @param actorType
     * @param proof
     * @param signature
     *
     */
    function solveChallenge(
        Challenge calldata challenge,
        ActorTypes actorType,
        bytes32[] calldata proof,
        bytes calldata signature
    ) external;

    /*
     * @notice Start a challenge for an actor.
     *
     * @param actor
     * @param actorType
     * @param proof
     *
     */
    function startChallenge(address actor, ActorTypes actorType, bytes32[] memory proof) external payable;

    /*
     * @notice Generate an user operation which will be used by the relayers to be able
     *         to queue this operation on the destination network through the StateNetwork of that chain
     *
     * @param destinationAccount
     * @param destinationNetworkId
     * @param underlyingAssetName
     * @param underlyingAssetSymbol
     * @param underlyingAssetDecimals
     * @param underlyingAssetTokenAddress
     * @param underlyingAssetNetworkId
     * @param assetTokenAddress
     * @param assetAmount
     * @param networkFeeAssetAmount
     * @param forwardNetworkFeeAssetAmount
     * @param userData
     * @param optionsMask
     */
    function userSend(
        string calldata destinationAccount,
        bytes4 destinationNetworkId,
        string calldata underlyingAssetName,
        string calldata underlyingAssetSymbol,
        uint256 underlyingAssetDecimals,
        address underlyingAssetTokenAddress,
        bytes4 underlyingAssetNetworkId,
        address assetTokenAddress,
        uint256 assetAmount,
        uint256 networkFeeAssetAmount,
        uint256 forwardNetworkFeeAssetAmount,
        bytes calldata userData,
        bytes32 optionsMask
    ) external;
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

/**
 * @title IPReceiver
 * @author pNetwork
 *
 * @notice
 */
interface IPReceiver {
    /*
     * @notice Function called when userData.length > 0 within PNetworkHub.protocolExecuteOperation.
     *
     * @param originNetworkId
     * @param originAccount
     * @param userData
     */
    function receiveUserData(bytes4 originNetworkId, string calldata originAccount, bytes calldata userData) external;
}
// SPDX-License-Identifier: MIT

/**
 * Created on 2023-09-15 14:48
 * @summary:
 * @author: mauro
 */
pragma solidity ^0.8.19;

interface IPRegistry {
    /**
     * @dev Emitted when a challenge is started.
     *
     * @param networkId The network id
     * @param chainId The chain id
     * @param hub The hub
     */
    event NetworkAdded(bytes4 indexed networkId, uint32 indexed chainId, address hub);

    /*
     * @dev Return true if the given network id has been registered on pNetwork
     *
     * @param networkId the network ID
     *
     * @return bool true or false
     */
    function isNetworkIdSupported(bytes4 networkId) external view returns (bool);

    /**
     * @dev Return the supported chain ID
     * @param chainId the chain id
     */
    function isChainIdSupported(uint32 chainId) external view returns (bool);

    /**
     * @dev Returns the chain id for the given network ID
     *
     * @param networkId a network ID
     *
     * @return uint32 chain id for the given network ID
     */
    function getChainIdByNetworkId(bytes4 networkId) external view returns (uint32);

    /**
     * @dev Return the supported hubs
     */
    function getSupportedHubs() external view returns (address[] memory);

    /**
     * @dev Return the supported chain IDs
     * @return uint32[] the array of supported chain ids
     */
    function getSupportedChainIds() external view returns (uint32[] memory);

    /**
     * @dev Returns the pNetwork hub address for the given network ID
     *
     * @param networkId a network ID
     *
     * @return address pNetwork hub address on the given network ID
     */
    function getHubByNetworkId(bytes4 networkId) external view returns (address);

    /*
     * @dev Add a new entry for the map network ID => hub
     *
     * @param networkId the network ID
     * @param hub pNetwork hub contract address
     */
    function protocolAddNetwork(uint32 chainId, address hub) external;
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/**
 * @title IPToken
 * @author pNetwork
 *
 * @notice
 */
interface IPToken is IERC20 {
    /*
     * @notice Burn the corresponding `amount` of pToken and release the collateral.
     *
     * @param amount
     */
    function burn(uint256 amount) external;

    /*
     * @notice Take the collateral and mint the corresponding `amount` of pToken to `msg.sender`.
     *
     * @param amount
     */
    function mint(uint256 amount) external;

    /*
     * @notice Mint the corresponding `amount` of pToken through the PNetworkHub to `account`.
     *
     * @param account
     * @param amount
     */
    function protocolMint(address account, uint256 amount) external;

    /*
     * @notice Burn the corresponding `amount` of pToken through the PNetworkHub to `account` and release the collateral.
     *
     * @param account
     * @param amount
     */
    function protocolBurn(address account, uint256 amount) external;

    function underlyingAssetDecimals() external returns (uint256);

    function underlyingAssetName() external returns (string memory);

    function underlyingAssetNetworkId() external returns (bytes4);

    function underlyingAssetSymbol() external returns (string memory);

    function underlyingAssetTokenAddress() external returns (address);

    /*
     * @notice Take the collateral and mint the corresponding `amount` of pToken through the PRouter to `account`.
     *
     * @param account
     * @param amount
     */
    function userMint(address account, uint256 amount) external;

    /*
     * @notice Take the collateral, mint and burn the corresponding `amount` of pToken through the PRouter to `account`.
     *
     * @param account
     * @param amount
     */
    function userMintAndBurn(address account, uint256 amount) external;

    /*
     * @notice Burn the corresponding `amount` of pToken through the PRouter in behalf of `account` and release the.
     *
     * @param account
     * @param amount
     */
    function userBurn(address account, uint256 amount) external;
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {IPReceiver} from "./IPReceiver.sol";

interface ISlasher is IPReceiver {}
pragma solidity ^0.8.19;

import {Math} from "@openzeppelin/contracts/utils/math/Math.sol";

library MerkleTree {
    function getRoot(bytes32[] memory data) internal pure returns (bytes32) {
        uint256 n = data.length;

        if (n == 1) {
            return data[0];
        }

        uint256 j = 0;
        uint256 layer = 0;
        uint256 leaves = Math.log2(n) + 1;
        bytes32[][] memory nodes = new bytes32[][](leaves * (2 * n - 1));

        for (uint256 l = 0; l <= leaves; ) {
            nodes[l] = new bytes32[](2 * n - 1);
            unchecked {
                ++l;
            }
        }

        for (uint256 i = 0; i < data.length; ) {
            nodes[layer][j] = data[i];
            unchecked {
                ++j;
                ++i;
            }
        }

        while (n > 1) {
            uint256 layerNodes = 0;
            uint k = 0;

            for (uint256 i = 0; i < n; i += 2) {
                if (i + 1 == n) {
                    if (n % 2 == 1) {
                        nodes[layer + 1][k] = nodes[layer][n - 1];
                        unchecked {
                            ++j;
                            ++layerNodes;
                        }
                        continue;
                    }
                }

                nodes[layer + 1][k] = _hashPair(nodes[layer][i], nodes[layer][i + 1]);

                unchecked {
                    ++k;
                    layerNodes += 2;
                }
            }

            n = (n / 2) + (layerNodes % 2 == 0 ? 0 : 1);
            unchecked {
                ++layer;
            }
        }

        return nodes[layer][0];
    }

    function _hashPair(bytes32 a, bytes32 b) internal pure returns (bytes32) {
        return a < b ? _efficientHash(a, b) : _efficientHash(b, a);
    }

    function _efficientHash(bytes32 a, bytes32 b) internal pure returns (bytes32 value) {
        assembly {
            mstore(0x00, a)
            mstore(0x20, b)
            value := keccak256(0x00, 0x40)
        }
    }
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

library Network {
    function isCurrentNetwork(bytes4 networkId) internal view returns (bool) {
        return Network.getCurrentNetworkId() == networkId;
    }

    function getNetworkIdFromChainId(uint32 chainId) internal pure returns (bytes4) {
        bytes1 version = 0x01;
        bytes1 networkType = 0x01;
        bytes1 extraData = 0x00;
        return bytes4(sha256(abi.encode(version, networkType, chainId, extraData)));
    }

    function getCurrentNetworkId() internal view returns (bytes4) {
        return getNetworkIdFromChainId(uint32(block.chainid));
    }
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";
import {Network} from "./Network.sol";

error CallFailed();

library Utils {
    function isBitSet(bytes32 data, uint position) internal pure returns (bool) {
        return (uint256(data) & (uint256(1) << position)) != 0;
    }

    function normalizeAmountToProtocolFormat(uint256 amount, uint256 decimals) internal pure returns (uint256) {
        uint256 difference = (10 ** (18 - decimals));
        return amount * difference;
    }

    function normalizeAmountToOriginalFormat(uint256 amount, uint256 decimals) internal pure returns (uint256) {
        uint256 difference = (10 ** (18 - decimals));
        return amount / difference;
    }

    function normalizeAmountToProtocolFormatOnCurrentNetwork(
        uint256 amount,
        uint256 decimals,
        bytes4 networkId
    ) internal view returns (uint256) {
        return Network.isCurrentNetwork(networkId) ? normalizeAmountToProtocolFormat(amount, decimals) : amount;
    }

    function addressToHexString(address addr) internal pure returns (string memory) {
        return Strings.toHexString(uint256(uint160(addr)), 20);
    }

    function hexStringToAddress(string memory addr) internal pure returns (address) {
        bytes memory tmp = bytes(addr);
        uint160 iaddr = 0;
        uint160 b1;
        uint160 b2;
        for (uint i = 2; i < 2 + 2 * 20; i += 2) {
            iaddr *= 256;
            b1 = uint160(uint8(tmp[i]));
            b2 = uint160(uint8(tmp[i + 1]));
            if ((b1 >= 97) && (b1 <= 102)) {
                b1 -= 87;
            } else if ((b1 >= 65) && (b1 <= 70)) {
                b1 -= 55;
            } else if ((b1 >= 48) && (b1 <= 57)) {
                b1 -= 48;
            }
            if ((b2 >= 97) && (b2 <= 102)) {
                b2 -= 87;
            } else if ((b2 >= 65) && (b2 <= 70)) {
                b2 -= 55;
            } else if ((b2 >= 48) && (b2 <= 57)) {
                b2 -= 48;
            }
            iaddr += (b1 * 16 + b2);
        }
        return address(iaddr);
    }

    function sendEther(address to, uint256 amount) internal {
        (bool sent, ) = to.call{value: amount}("");
        if (!sent) {
            revert CallFailed();
        }
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {IEpochsManager} from "@pnetwork-association/dao-v2-contracts/contracts/interfaces/IEpochsManager.sol";
import {IPNetworkHub} from "../interfaces/IPNetworkHub.sol";
import {MerkleTree} from "../libraries/MerkleTree.sol";

error InvalidRegistrationKind(bytes1 kind);

contract MockGovernanceMessageEmitter {
    bytes32 public constant GOVERNANCE_MESSAGE_ACTORS = keccak256("GOVERNANCE_MESSAGE_ACTORS");
    bytes32 public constant GOVERNANCE_MESSAGE_SLASH_ACTOR = keccak256("GOVERNANCE_MESSAGE_SLASH_ACTOR");
    bytes32 public constant GOVERNANCE_MESSAGE_RESUME_ACTOR = keccak256("GOVERNANCE_MESSAGE_RESUME_ACTOR");
    bytes32 public constant GOVERNANCE_MESSAGE_PROTOCOL_GOVERNANCE_CANCEL_OPERATION =
        keccak256("GOVERNANCE_MESSAGE_PROTOCOL_GOVERNANCE_CANCEL_OPERATION");

    address public immutable epochsManager;

    event GovernanceMessage(bytes data);

    constructor(address epochsManager_) {
        epochsManager = epochsManager_;
    }

    function resumeActor(address actor, bytes1 registrationKind) external {
        emit GovernanceMessage(
            abi.encode(
                GOVERNANCE_MESSAGE_RESUME_ACTOR,
                abi.encode(
                    IEpochsManager(epochsManager).currentEpoch(),
                    actor,
                    _getActorTypeByRegistrationKind(registrationKind)
                )
            )
        );
    }

    function slashActor(address actor, bytes1 registrationKind) external {
        emit GovernanceMessage(
            abi.encode(
                GOVERNANCE_MESSAGE_SLASH_ACTOR,
                abi.encode(
                    IEpochsManager(epochsManager).currentEpoch(),
                    actor,
                    _getActorTypeByRegistrationKind(registrationKind)
                )
            )
        );
    }

    function propagateActors(uint16 epoch, address[] calldata guardians, address[] calldata sentinels) external {
        uint256 length = guardians.length + sentinels.length;
        address[] memory actors = new address[](length);
        IPNetworkHub.ActorTypes[] memory actorsType = new IPNetworkHub.ActorTypes[](length);

        for (uint256 i = 0; i < guardians.length; ) {
            actors[i] = guardians[i];
            actorsType[i] = IPNetworkHub.ActorTypes.Guardian;
            unchecked {
                ++i;
            }
        }

        for (uint256 i = guardians.length; i < length; ) {
            actors[i] = sentinels[i - guardians.length];
            actorsType[i] = IPNetworkHub.ActorTypes.Sentinel;
            unchecked {
                ++i;
            }
        }

        emit GovernanceMessage(
            abi.encode(
                GOVERNANCE_MESSAGE_ACTORS,
                abi.encode(
                    epoch,
                    guardians.length,
                    sentinels.length,
                    MerkleTree.getRoot(_hashActorAddressesWithType(actors, actorsType))
                )
            )
        );
    }

    function protocolGovernanceCancelOperation(IPNetworkHub.Operation calldata operation) external {
        emit GovernanceMessage(
            abi.encode(GOVERNANCE_MESSAGE_PROTOCOL_GOVERNANCE_CANCEL_OPERATION, abi.encode(operation))
        );
    }

    function _getActorTypeByRegistrationKind(bytes1 registrationKind) internal pure returns (IPNetworkHub.ActorTypes) {
        if (registrationKind == 0x01) return IPNetworkHub.ActorTypes.Sentinel;
        if (registrationKind == 0x02) return IPNetworkHub.ActorTypes.Sentinel;
        if (registrationKind == 0x03) return IPNetworkHub.ActorTypes.Guardian;
        revert InvalidRegistrationKind(registrationKind);
    }

    function _hashActorAddressesWithType(
        address[] memory actors,
        IPNetworkHub.ActorTypes[] memory actorTypes
    ) internal pure returns (bytes32[] memory) {
        bytes32[] memory data = new bytes32[](actors.length);
        for (uint256 i = 0; i < actors.length; i++) {
            data[i] = keccak256(abi.encodePacked(actors[i], actorTypes[i]));
        }
        return data;
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {MockPToken} from "./MockPToken.sol";
import {IPFactory} from "../interfaces/IPFactory.sol";

contract MockPFactory is IPFactory, Ownable {
    address public hub;

    function deploy(
        string memory underlyingAssetName,
        string memory underlyingAssetSymbol,
        uint256 underlyingAssetDecimals,
        address underlyingAssetTokenAddress,
        bytes4 underlyingAssetNetworkId
    ) public payable returns (address) {
        address pTokenAddress = address(
            new MockPToken{salt: hex"0000000000000000000000000000000000000000000000000000000000000000"}(
                underlyingAssetName,
                underlyingAssetSymbol,
                underlyingAssetDecimals,
                underlyingAssetTokenAddress,
                underlyingAssetNetworkId,
                hub
            )
        );

        emit PTokenDeployed(pTokenAddress);
        return pTokenAddress;
    }

    function getBytecode(
        string memory underlyingAssetName,
        string memory underlyingAssetSymbol,
        uint256 underlyingAssetDecimals,
        address underlyingAssetTokenAddress,
        bytes4 underlyingAssetNetworkId
    ) public view returns (bytes memory) {
        bytes memory bytecode = type(MockPToken).creationCode;

        return
            abi.encodePacked(
                bytecode,
                abi.encode(
                    underlyingAssetName,
                    underlyingAssetSymbol,
                    underlyingAssetDecimals,
                    underlyingAssetTokenAddress,
                    underlyingAssetNetworkId,
                    hub
                )
            );
    }

    function getPTokenAddress(
        string memory underlyingAssetName,
        string memory underlyingAssetSymbol,
        uint256 underlyingAssetDecimals,
        address underlyingAssetTokenAddress,
        bytes4 underlyingAssetNetworkId
    ) public view returns (address) {
        bytes memory bytecode = getBytecode(
            underlyingAssetName,
            underlyingAssetSymbol,
            underlyingAssetDecimals,
            underlyingAssetTokenAddress,
            underlyingAssetNetworkId
        );

        return
            address(
                uint160(
                    uint256(
                        keccak256(
                            abi.encodePacked(
                                bytes1(0xff),
                                address(this),
                                hex"0000000000000000000000000000000000000000000000000000000000000000",
                                keccak256(bytecode)
                            )
                        )
                    )
                )
            );
    }

    function setHub(address hub_) external onlyOwner {
        hub = hub_;
    }
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {PToken} from "../core/PToken.sol";

contract MockPToken is PToken {
    constructor(
        string memory underlyingAssetName,
        string memory underlyingAssetSymbol,
        uint256 underlyingAssetDecimals,
        address underlyingAssetTokenAddress,
        bytes4 underlyingAssetNetworkId,
        address hub
    )
        PToken(
            underlyingAssetName,
            underlyingAssetSymbol,
            underlyingAssetDecimals,
            underlyingAssetTokenAddress,
            underlyingAssetNetworkId,
            hub
        )
    {}

    function mockMint(address to, uint256 amount) external {
        _mint(to, amount);
    }
}
// SPDX-License-Identifier: Unlicense

pragma solidity ^0.8.19;

import {IGovernanceMessageEmitter} from "../interfaces/IGovernanceMessageEmitter.sol";

interface IMockLendingManager {
    function increaseTotalBorrowedAmountByEpoch(uint24 amount, uint16 epoch) external;
}

contract MockRegistrationManager {
    struct Registration {
        address owner;
        uint16 startEpoch;
        uint16 endEpoch;
        bytes1 kind;
    }

    event StakingSentinelSlashed(address indexed sentinel, uint256 amount);
    event BorrowingSentinelSlashed(address indexed sentinel);
    event GuardianSlashed(address indexed guardian);

    address public immutable lendingManager;
    address public governanceMessageEmitter;
    mapping(address => Registration) private _sentinelRegistrations;
    mapping(address => Registration) private _guardianRegistrations;
    mapping(uint16 => uint24) private _sentinelsEpochsTotalStakedAmount;
    mapping(address => mapping(uint16 => uint24)) private _sentinelsEpochsStakedAmount;

    constructor(address lendingManager_) {
        lendingManager = lendingManager_;
    }

    function sentinelRegistration(address sentinel) external view returns (Registration memory) {
        return _sentinelRegistrations[sentinel];
    }

    function sentinelStakedAmountByEpochOf(address sentinel, uint16 epoch) external view returns (uint24) {
        return _sentinelsEpochsStakedAmount[sentinel][epoch];
    }

    function totalSentinelStakedAmountByEpoch(uint16 epoch) external view returns (uint24) {
        return _sentinelsEpochsTotalStakedAmount[epoch];
    }

    function addGuardian(address guardian, address owner, uint16 startEpoch, uint16 endEpoch) external {
        _guardianRegistrations[guardian] = Registration({
            owner: owner,
            startEpoch: startEpoch,
            endEpoch: endEpoch,
            kind: 0x03
        });
    }

    function addStakingSentinel(
        address sentinel,
        address owner,
        uint16 startEpoch,
        uint16 endEpoch,
        uint24 amount
    ) external {
        _sentinelRegistrations[sentinel] = Registration({
            owner: owner,
            startEpoch: startEpoch,
            endEpoch: endEpoch,
            kind: 0x01
        });

        for (uint16 epoch = startEpoch; epoch <= endEpoch; epoch++) {
            _sentinelsEpochsTotalStakedAmount[epoch] += amount;
            _sentinelsEpochsStakedAmount[sentinel][epoch] += amount;
        }
    }

    function addBorrowingSentinel(address sentinel, address owner, uint16 startEpoch, uint16 endEpoch) external {
        _sentinelRegistrations[sentinel] = Registration({
            owner: owner,
            startEpoch: startEpoch,
            endEpoch: endEpoch,
            kind: 0x02
        });
        for (uint16 epoch = startEpoch; epoch <= endEpoch; epoch++) {
            IMockLendingManager(lendingManager).increaseTotalBorrowedAmountByEpoch(200000, epoch);
        }
    }

    function setGovernanceMessageEmitter(address governanceMessageEmitter_) external {
        governanceMessageEmitter = governanceMessageEmitter_;
    }

    function slash(address actor, uint256 amount, address challenger) external {
        Registration memory regitration = _sentinelRegistrations[actor];

        if (regitration.kind == 0x01) {
            IGovernanceMessageEmitter(governanceMessageEmitter).slashActor(actor, 0x01);
            emit StakingSentinelSlashed(actor, amount);
        }

        if (regitration.kind == 0x02) {
            IGovernanceMessageEmitter(governanceMessageEmitter).slashActor(actor, 0x02);
            emit BorrowingSentinelSlashed(actor);
        }

        if (regitration.kind == 0x03) {
            IGovernanceMessageEmitter(governanceMessageEmitter).slashActor(actor, 0x03);
            emit GuardianSlashed(actor);
        }
    }
}
