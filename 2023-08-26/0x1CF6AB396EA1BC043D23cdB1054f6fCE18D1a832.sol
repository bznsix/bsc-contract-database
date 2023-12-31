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
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/extensions/draft-ERC20Permit.sol)

pragma solidity ^0.8.0;

import "./draft-IERC20Permit.sol";
import "../ERC20.sol";
import "../../../utils/cryptography/draft-EIP712.sol";
import "../../../utils/cryptography/ECDSA.sol";
import "../../../utils/Counters.sol";

/**
 * @dev Implementation of the ERC20 Permit extension allowing approvals to be made via signatures, as defined in
 * https://eips.ethereum.org/EIPS/eip-2612[EIP-2612].
 *
 * Adds the {permit} method, which can be used to change an account's ERC20 allowance (see {IERC20-allowance}) by
 * presenting a message signed by the account. By not relying on `{IERC20-approve}`, the token holder account doesn't
 * need to send a transaction, and thus is not required to hold Ether at all.
 *
 * _Available since v3.4._
 */
abstract contract ERC20Permit is ERC20, IERC20Permit, EIP712 {
    using Counters for Counters.Counter;

    mapping(address => Counters.Counter) private _nonces;

    // solhint-disable-next-line var-name-mixedcase
    bytes32 private constant _PERMIT_TYPEHASH =
        keccak256("Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)");
    /**
     * @dev In previous versions `_PERMIT_TYPEHASH` was declared as `immutable`.
     * However, to ensure consistency with the upgradeable transpiler, we will continue
     * to reserve a slot.
     * @custom:oz-renamed-from _PERMIT_TYPEHASH
     */
    // solhint-disable-next-line var-name-mixedcase
    bytes32 private _PERMIT_TYPEHASH_DEPRECATED_SLOT;

    /**
     * @dev Initializes the {EIP712} domain separator using the `name` parameter, and setting `version` to `"1"`.
     *
     * It's a good idea to use the same `name` that is defined as the ERC20 token name.
     */
    constructor(string memory name) EIP712(name, "1") {}

    /**
     * @dev See {IERC20Permit-permit}.
     */
    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public virtual override {
        require(block.timestamp <= deadline, "ERC20Permit: expired deadline");

        bytes32 structHash = keccak256(abi.encode(_PERMIT_TYPEHASH, owner, spender, value, _useNonce(owner), deadline));

        bytes32 hash = _hashTypedDataV4(structHash);

        address signer = ECDSA.recover(hash, v, r, s);
        require(signer == owner, "ERC20Permit: invalid signature");

        _approve(owner, spender, value);
    }

    /**
     * @dev See {IERC20Permit-nonces}.
     */
    function nonces(address owner) public view virtual override returns (uint256) {
        return _nonces[owner].current();
    }

    /**
     * @dev See {IERC20Permit-DOMAIN_SEPARATOR}.
     */
    // solhint-disable-next-line func-name-mixedcase
    function DOMAIN_SEPARATOR() external view override returns (bytes32) {
        return _domainSeparatorV4();
    }

    /**
     * @dev "Consume a nonce": return the current value and increment.
     *
     * _Available since v4.1._
     */
    function _useNonce(address owner) internal virtual returns (uint256 current) {
        Counters.Counter storage nonce = _nonces[owner];
        current = nonce.current();
        nonce.increment();
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
// OpenZeppelin Contracts v4.4.1 (utils/cryptography/draft-EIP712.sol)

pragma solidity ^0.8.0;

import "./ECDSA.sol";

/**
 * @dev https://eips.ethereum.org/EIPS/eip-712[EIP 712] is a standard for hashing and signing of typed structured data.
 *
 * The encoding specified in the EIP is very generic, and such a generic implementation in Solidity is not feasible,
 * thus this contract does not implement the encoding itself. Protocols need to implement the type-specific encoding
 * they need in their contracts using a combination of `abi.encode` and `keccak256`.
 *
 * This contract implements the EIP 712 domain separator ({_domainSeparatorV4}) that is used as part of the encoding
 * scheme, and the final step of the encoding to obtain the message digest that is then signed via ECDSA
 * ({_hashTypedDataV4}).
 *
 * The implementation of the domain separator was designed to be as efficient as possible while still properly updating
 * the chain id to protect against replay attacks on an eventual fork of the chain.
 *
 * NOTE: This contract implements the version of the encoding known as "v4", as implemented by the JSON RPC method
 * https://docs.metamask.io/guide/signing-data.html[`eth_signTypedDataV4` in MetaMask].
 *
 * _Available since v3.4._
 */
abstract contract EIP712 {
    /* solhint-disable var-name-mixedcase */
    // Cache the domain separator as an immutable value, but also store the chain id that it corresponds to, in order to
    // invalidate the cached domain separator if the chain id changes.
    bytes32 private immutable _CACHED_DOMAIN_SEPARATOR;
    uint256 private immutable _CACHED_CHAIN_ID;
    address private immutable _CACHED_THIS;

    bytes32 private immutable _HASHED_NAME;
    bytes32 private immutable _HASHED_VERSION;
    bytes32 private immutable _TYPE_HASH;

    /* solhint-enable var-name-mixedcase */

    /**
     * @dev Initializes the domain separator and parameter caches.
     *
     * The meaning of `name` and `version` is specified in
     * https://eips.ethereum.org/EIPS/eip-712#definition-of-domainseparator[EIP 712]:
     *
     * - `name`: the user readable name of the signing domain, i.e. the name of the DApp or the protocol.
     * - `version`: the current major version of the signing domain.
     *
     * NOTE: These parameters cannot be changed except through a xref:learn::upgrading-smart-contracts.adoc[smart
     * contract upgrade].
     */
    constructor(string memory name, string memory version) {
        bytes32 hashedName = keccak256(bytes(name));
        bytes32 hashedVersion = keccak256(bytes(version));
        bytes32 typeHash = keccak256(
            "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"
        );
        _HASHED_NAME = hashedName;
        _HASHED_VERSION = hashedVersion;
        _CACHED_CHAIN_ID = block.chainid;
        _CACHED_DOMAIN_SEPARATOR = _buildDomainSeparator(typeHash, hashedName, hashedVersion);
        _CACHED_THIS = address(this);
        _TYPE_HASH = typeHash;
    }

    /**
     * @dev Returns the domain separator for the current chain.
     */
    function _domainSeparatorV4() internal view returns (bytes32) {
        if (address(this) == _CACHED_THIS && block.chainid == _CACHED_CHAIN_ID) {
            return _CACHED_DOMAIN_SEPARATOR;
        } else {
            return _buildDomainSeparator(_TYPE_HASH, _HASHED_NAME, _HASHED_VERSION);
        }
    }

    function _buildDomainSeparator(
        bytes32 typeHash,
        bytes32 nameHash,
        bytes32 versionHash
    ) private view returns (bytes32) {
        return keccak256(abi.encode(typeHash, nameHash, versionHash, block.chainid, address(this)));
    }

    /**
     * @dev Given an already https://eips.ethereum.org/EIPS/eip-712#definition-of-hashstruct[hashed struct], this
     * function returns the hash of the fully encoded EIP712 message for this domain.
     *
     * This hash can be used together with {ECDSA-recover} to obtain the signer of a message. For example:
     *
     * ```solidity
     * bytes32 digest = _hashTypedDataV4(keccak256(abi.encode(
     *     keccak256("Mail(address to,string contents)"),
     *     mailTo,
     *     keccak256(bytes(mailContents))
     * )));
     * address signer = ECDSA.recover(digest, signature);
     * ```
     */
    function _hashTypedDataV4(bytes32 structHash) internal view virtual returns (bytes32) {
        return ECDSA.toTypedDataHash(_domainSeparatorV4(), structHash);
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.3) (utils/cryptography/ECDSA.sol)

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
        InvalidSignatureV
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
        } else if (error == RecoverError.InvalidSignatureV) {
            revert("ECDSA: invalid signature 'v' value");
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
    function tryRecover(
        bytes32 hash,
        bytes32 r,
        bytes32 vs
    ) internal pure returns (address, RecoverError) {
        bytes32 s = vs & bytes32(0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff);
        uint8 v = uint8((uint256(vs) >> 255) + 27);
        return tryRecover(hash, v, r, s);
    }

    /**
     * @dev Overload of {ECDSA-recover} that receives the `r and `vs` short-signature fields separately.
     *
     * _Available since v4.2._
     */
    function recover(
        bytes32 hash,
        bytes32 r,
        bytes32 vs
    ) internal pure returns (address) {
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
    function tryRecover(
        bytes32 hash,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal pure returns (address, RecoverError) {
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
        if (v != 27 && v != 28) {
            return (address(0), RecoverError.InvalidSignatureV);
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
    function recover(
        bytes32 hash,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal pure returns (address) {
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
    function toEthSignedMessageHash(bytes32 hash) internal pure returns (bytes32) {
        // 32 is the length in bytes of hash,
        // enforced by the type signature above
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
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
    function toTypedDataHash(bytes32 domainSeparator, bytes32 structHash) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19\x01", domainSeparator, structHash));
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
// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.18;

contract ContractRegistryHashes {

    error OnlyRouter();
    error OnlyTreasury();
    error OnlyRealmGuardian();
    error OnlyStakingManager();
    error OnlyStakingManagerOrTokenCollector();
    error OnlyRewardDistributor();
    error OnlyCoinMaster();
    error OnlyTokenCollector();

    error METFINotWithdrawable();

    error InvalidContractAddress();

    bytes32 constant internal MFI_HASH = 0xab12ee3d83a34822ca77656b4007d61405e0029c8476890a3303aabb7a0a3d26; // keccak256(abi.encodePacked('mfi'))
    bytes32 constant internal METFI_HASH = 0xc30505a9c296d74a341270378602ace8341352e684fc4f8fbf4bf9aa16ddffca; // keccak256(abi.encodePacked('metfi'))

    bytes32 constant internal ROUTER_HASH = 0x5f6d4e9bb70c9d2aa50e18560b4cdd1b23b30d62b60873d5f23b103e5d7d0185;// keccak256(abi.encodePacked('router'))
    bytes32 constant internal TREASURY_HASH = 0xcbd818ad4dd6f1ff9338c2bb62480241424dd9a65f9f3284101a01cd099ad8ac; // keccak256(abi.encodePacked('treasury'))
    bytes32 constant internal METFI_VAULT_HASH = 0xacb5ae4bf471c8110adaac4702c4177629bf32af63ad6f68f546ac2fcd039e77; // keccak256(abi.encodePacked('metfi_vault'))
    bytes32 constant internal USER_CONFIG_HASH = 0x5e1885a4b18649f87409858a77d00e281ce6dd4507e43dc706a2d703d71aeb71; // keccak256(abi.encodePacked('user_config'))
    bytes32 constant internal ACCOUNT_TOKEN_HASH = 0xc5d51c4d622df5dca71195c62129359a2e761a24b2789b5a40667736c682f30f; // keccak256(abi.encodePacked('account_token'))
    bytes32 constant internal PLATFORM_VIEW_HASH = 0xd58c1d29f4951cf40818a252966d0f0711896e43c86ba803ffa9841180d7bca1; // keccak256(abi.encodePacked('platform_view'))
    bytes32 constant internal UNSTAKED_NFTS_HASH = 0x2d006620d1c948b883dc3097193eb76c239d12828bb85beea39994af1ecefb65; // keccak256(abi.encodePacked('unstaked_nfts'))
    bytes32 constant internal STAKING_MANAGER_HASH = 0x9518d9bd94df3303f323b9a5b2289cf4e06524a698aef176fcc9590318226540; // keccak256(abi.encodePacked('staking_manager'))
    bytes32 constant internal TOKEN_COLLECTOR_HASH = 0x66c4b93ccf2bde8d7ba39826420a87af960e88acb070c754e53aba0b8e51c02c; // keccak256(abi.encodePacked('token_collector'))
    bytes32 constant internal BURN_CONTROLLER_HASH = 0xa4636fb16cea2aa5153c9be70618a6afb5cefe7a593eeee2cfab523b8c195a73;  // keccak256(abi.encodePacked('burn_controller'))
    bytes32 constant internal REWARD_CONVERTER_HASH = 0xb7e5e8f89e319d42882d379ecafd17e93606cf39a2079af36730958267667728; // keccak256(abi.encodePacked('reward_converter'))
    bytes32 constant internal METFI_STAKING_POOL_HASH = 0x3d9cfbe20d3d50006bd02e057e662d569da593b764b8b8f923d3d313f2422b10;// keccak256(abi.encodePacked('metfi_staking_pool'))
    bytes32 constant internal REWARD_DISTRIBUTOR_HASH = 0x8d3e9afdbbce76f0b889c4bff442796e82871c8eccf3c648a01e55e080d66a49; // keccak256(abi.encodePacked('reward_distributor'))
    bytes32 constant internal PRIMARY_STABLECOIN_HASH = 0x0876039741972003251072838c80c5b1e815c7b3ed2e3b01411c485fec477ecc; // keccak256(abi.encodePacked('primary_stablecoin'))
    bytes32 constant internal ACTION_FUNCTIONS_HASH = 0x0970951b7db2cc0a769d9e3cb477e212250909cab0d2468854bafd755326bb7b; // keccak256(abi.encodePacked('action_functions'))
    bytes32 constant internal NFT_TRANSFER_PROXY_HASH = 0xbd165d9953042246fb908ee4e3ee644fbe1e3fe22c7d6830d417bdcece5d273b; // keccak256(abi.encodePacked('nft_transfer_proxy'))
    bytes32 constant internal STAR_ACHIEVERS_HASH = 0x22a6d61b8441b8b48421128668229a04c572ac6018e721043359db05f33c151b; // keccak256(abi.encodePacked('star_achievers'))

    bytes32 constant internal LENDING_HASH = 0x16573015d5a4b6fc6913a13e8c047a772cc654c00c338536ccaa33e7fe263be9; // keccak256(abi.encodePacked('lending'))
    bytes32 constant internal LENDING_VIEW_HASH = 0xc74a7251498f700c757f7d9bedf70846e0808d0cfd266d18ff796d603e58ef42; // keccak256(abi.encodePacked('lending_view'))
    bytes32 constant internal LOAN_LIMITER_HASH = 0x840de5598c4c00225a8bc33abacc176aa8dc32e156f7069560dd186d8c08e83e; // keccak256(abi.encodePacked('loan_limiter'))
    bytes32 constant internal LENDING_AUCTION_HASH = 0x315a584ec231dc4ba7bfc5a8f8efed9f1d7f61fe4c54746decfc19ddd199a7c8; // keccak256(abi.encodePacked('lending_auction'))
    bytes32 constant internal LENDING_CHECKER_HASH = 0xd0beb74e409a61d00092877bb21f2e1b99afa0fb5b69fded573ce9d20f6426ee; // keccak256(abi.encodePacked('lending_checker'))
    bytes32 constant internal LENDING_CALCULATOR_HASH = 0xc8f991caa4a50f2a548f7cb4ae682c6276c4479baa4474b270262f1cf7ef0d13; // keccak256(abi.encodePacked('lending_calculator'))
    bytes32 constant internal LENDING_EXTENSION_CONTROLLER_HASH = 0x575b99354279563b4b104af43b2bd3663850df86e34a2a754269a4a55a0c1afd; // keccak256(abi.encodePacked('lending_extension_controller'))

    bytes32 constant internal PANCAKE_ROUTER_HASH = 0xd8ed703341074e5699af5f26d9f38498fb901a7519f08174cfb1baf7b5ecbff9; // keccak256(abi.encodePacked('pancake_router'))
    bytes32 constant internal COMMUNITY_MANAGER_PAYOUT_CONTROLLER_HASH = 0x8e4bf4954dca9b537539c95d84bafae4fccf02da2ae09493581b7e530f914a17; // keccak256(abi.encodePacked('community_manager_payout_controller'))

}
// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.18;

import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/draft-ERC20Permit.sol";

import "./interfaces/IContractRegistry.sol";
import "./ContractRegistryHashes.sol";

import "./interfaces/IMETFI.sol";
import "./interfaces/ILending.sol";
import "./interfaces/IRouterV3.sol";
import "./interfaces/ITreasuryV2.sol";
import "./interfaces/IUserConfig.sol";
import "./interfaces/IMETFIVault.sol";
import "./interfaces/ILendingView.sol";
import "./interfaces/ILoanLimiter.sol";
import "./interfaces/IAccountToken.sol";
import "./interfaces/IPlatformView.sol";
import "./interfaces/ISecurityProxy.sol";
import "./interfaces/ILendingAuction.sol";
import "./interfaces/ILendingChecker.sol";
import "./interfaces/IPlatformViewV2.sol";
import "./interfaces/IPriceCalculator.sol";
import "./interfaces/IRewardConverter.sol";
import "./interfaces/IPancakeRouter02.sol";
import "./interfaces/IValueCalculator.sol";
import "./interfaces/IStakingManagerV3.sol";
import "./interfaces/ITokenCollectorV2.sol";
import "./interfaces/IMETFIStakingPool.sol";
import "./interfaces/IBurnControllerV2.sol";
import "./interfaces/ILendingCalculator.sol";
import "./interfaces/IManageableTreasury.sol";
import "./interfaces/IDestroyableContract.sol";
import "./interfaces/ILendingPlatformView.sol";
import "./interfaces/ILiquidityController.sol";
import "./interfaces/ILendingLoanExtensionController.sol";


contract ContractRegistryUser is ContractRegistryHashes, ILostTokenProvider {

    using Address for address payable;
    using SafeERC20 for IERC20;

    IContractRegistry internal contractRegistry;

    constructor(IContractRegistry _contractRegistry) {
        if (address(_contractRegistry) == address(0)) {
            revert InvalidContractAddress();
        }
        contractRegistry = _contractRegistry;
    }

    //-------------------------------------------------------------------------

    function onlyRouter() internal view {
        if (msg.sender != contractRegistry.getContractAddress(ROUTER_HASH)) {
            revert OnlyRouter();
        }
    }

    function onlyTreasury() internal view {
        if (msg.sender != contractRegistry.getContractAddress(TREASURY_HASH)) {
            revert OnlyTreasury();
        }
    }

    function onlyRealmGuardian() internal view {
        if (!contractRegistry.isRealmGuardian(msg.sender)) {
            revert OnlyRealmGuardian();
        }
    }

    function onlyStakingManager() internal view {
        if (msg.sender != contractRegistry.getContractAddress(STAKING_MANAGER_HASH)) {
            revert OnlyStakingManager();
        }
    }

    function onlyStakingManagerOrTokenCollector() internal view {
        if (msg.sender != contractRegistry.getContractAddress(STAKING_MANAGER_HASH) && msg.sender != contractRegistry.getContractAddress(TOKEN_COLLECTOR_HASH)) {
            revert OnlyStakingManagerOrTokenCollector();
        }
    }

    function onlyRewardDistributor() internal view {
        if (msg.sender != contractRegistry.getContractAddress(REWARD_DISTRIBUTOR_HASH)) {
            revert OnlyRewardDistributor();
        }
    }

    function onlyCoinMaster() internal view {
        if (!contractRegistry.isCoinMaster(msg.sender)) {
            revert OnlyCoinMaster();
        }
    }

    function onlyTokenCollector() internal view {
        if (msg.sender != contractRegistry.getContractAddress(TOKEN_COLLECTOR_HASH)) {
            revert OnlyTokenCollector();
        }
    }

    //-------------------------------------------------------------------------

    function getLostTokens(address tokenAddress) public virtual override {
        onlyTreasury();

        IERC20 token = IERC20(tokenAddress);
        if (token.balanceOf(address(this)) > 0) {
            token.safeTransfer(msg.sender, token.balanceOf(address(this)));
        }
        if (address(this).balance > 0) {
            payable(msg.sender).sendValue(address(this).balance);
        }
    }

    //-------------------------------------------------------------------------

    function getMFI() internal view returns (IERC20) {
        return IERC20(contractRegistry.getContractAddress(MFI_HASH));
    }

    function getMETFI() internal view returns (IMETFI) {
        return IMETFI(contractRegistry.getContractAddress(METFI_HASH));
    }
    function getMETFIERC20() internal view returns (IERC20) {
        return IERC20(contractRegistry.getContractAddress(METFI_HASH));
    }

    function getRouter() internal view returns (IRouterV3) {
        return IRouterV3(contractRegistry.getContractAddress(ROUTER_HASH));
    }

    function getLending() internal view returns (ILending) {
        return ILending(contractRegistry.getContractAddress(LENDING_HASH));
    }

    function getTreasury() internal view returns (ITreasuryV2) {
        return ITreasuryV2(contractRegistry.getContractAddress(TREASURY_HASH));
    }

    function getMETFIVault() internal view returns (IMETFIVault) {
        return IMETFIVault(contractRegistry.getContractAddress(METFI_VAULT_HASH));
    }

    function getUserConfig() internal view returns (IUserConfig) {
        return IUserConfig(contractRegistry.getContractAddress(USER_CONFIG_HASH));
    }

    function getLendingView() internal view returns (ILendingView) {
        return ILendingView(contractRegistry.getContractAddress(LENDING_VIEW_HASH));
    }

    function getLoanLimiter() internal view returns (ILoanLimiter) {
        return ILoanLimiter(contractRegistry.getContractAddress(LOAN_LIMITER_HASH));
    }

    function getAccountToken() internal view returns (IAccountToken) {
        return IAccountToken(contractRegistry.getContractAddress(ACCOUNT_TOKEN_HASH));
    }

    function getAccountTokenIERC721() internal view returns (IERC721) {
        return IERC721(contractRegistry.getContractAddress(ACCOUNT_TOKEN_HASH));
    }

    function getBurnController() internal view returns (IBurnControllerV2) {
        return IBurnControllerV2(contractRegistry.getContractAddress(BURN_CONTROLLER_HASH));
    }

    function getStakingManager() internal view returns (IStakingManagerV3) {
        return IStakingManagerV3(contractRegistry.getContractAddress(STAKING_MANAGER_HASH));
    }

    function getTokenCollector() internal view returns (ITokenCollectorV2) {
        return ITokenCollectorV2(contractRegistry.getContractAddress(TOKEN_COLLECTOR_HASH));
    }

    function getLendingAuction() internal view returns (ILendingAuction) {
        return ILendingAuction(contractRegistry.getContractAddress(LENDING_AUCTION_HASH));
    }

    function getLendingChecker() internal view returns (ILendingChecker) {
        return ILendingChecker(contractRegistry.getContractAddress(LENDING_CHECKER_HASH));
    }


    function getMETFIStakingPool() internal view returns (IMETFIStakingPool) {
        return IMETFIStakingPool(contractRegistry.getContractAddress(METFI_STAKING_POOL_HASH));
    }


    function getRewardDistributor() internal view returns (IRewardDistributor) {
        return IRewardDistributor(contractRegistry.getContractAddress(REWARD_DISTRIBUTOR_HASH));
    }

    function getLendingCalculator() internal view returns (ILendingCalculator) {
        return ILendingCalculator(contractRegistry.getContractAddress(LENDING_CALCULATOR_HASH));
    }

    function getLendingExtensionController() internal view returns (ILendingLoanExtensionController) {
        return ILendingLoanExtensionController(contractRegistry.getContractAddress(LENDING_EXTENSION_CONTROLLER_HASH));
    }

    function getPlatformView() internal view returns (IPlatformView) {
        return IPlatformView(contractRegistry.getContractAddress(PLATFORM_VIEW_HASH));
    }

    function getPriceCalculator(address token) internal view returns (IPriceCalculator) {
        return IPriceCalculator(contractRegistry.getPriceCalculator(token));
    }

    function getRewardConverter() internal view returns (IRewardConverter) {
        return IRewardConverter(contractRegistry.getContractAddress(REWARD_CONVERTER_HASH));
    }

    function getPancakeRouter() internal view returns (IPancakeRouter02) {
        return IPancakeRouter02(contractRegistry.getContractAddress(PANCAKE_ROUTER_HASH));
    }

    function getPrimaryStableCoin() internal view returns (IERC20) {
        return IERC20(contractRegistry.getContractAddress(PRIMARY_STABLECOIN_HASH));
    }

    function getPrimaryStableCoinMetadata() internal view returns (IERC20Metadata) {
        return IERC20Metadata(contractRegistry.getContractAddress(PRIMARY_STABLECOIN_HASH));
    }

    function getLendingPlatformView() internal view returns (ILendingPlatformView) {
        return ILendingPlatformView(contractRegistry.getContractAddress(LENDING_HASH));
    }

    function getPlatformViewV2() internal view returns (IPlatformViewV2) {
        return IPlatformViewV2(contractRegistry.getContractAddress(PLATFORM_VIEW_HASH));
    }


}// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.18;

interface IAccountToken {

    enum LiquidationStatus {
        NOT_REQUESTED,
        IN_PROGRESS,
        AVAILABLE
    }

    struct LiquidationInfo {
        LiquidationStatus status;
        uint256 requestTime;
        uint256 availableTime;
        uint256 expirationTime;
    }

    event AccountCreated(address indexed to, uint256 indexed tokenId, uint256 indexed directUplink, uint256 apy, string referralLink);
    event ReferralLinkChanged(uint256 indexed tokenId, string oldLink, string newLink);
    event AccountLiquidated(uint256 indexed nftId);
    event AccountLiquidationStarted(uint256 indexed nftId);
    event AccountLiquidationCanceled(uint256 indexed nftId);
    event AccountUpgraded(uint256 indexed nftId, uint256 indexed level, uint256 apy);

    function createAccount(address to, uint256 directUplink, uint256 level, string calldata newReferralLink) external returns (uint256);

    function setReferralLink(uint256 tokenId, string calldata referralLink) external;

    function accountLiquidated(uint256 tokenId) external view returns (bool);

    function getAddressNFTs(address userAddress) external view returns (uint256[] memory NFTs, uint256 numberOfActive);

    function balanceOf(address owner) external view returns (uint256 balance);

    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256);

    function upgradeAccountToLevel(uint256 tokenId, uint256 level) external;

    function ownerOf(uint256 tokenId) external view returns (address owner);

    function getAccountLevel(uint256 tokenId) external view returns (uint256);

    function getAccountDirectlyEnrolledMembers(uint256 tokenId) external view returns (uint256);

    function getAccountReferralLink(uint256 tokenId) external view returns (string memory);

    function getAccountByReferral(string calldata referralLink) external view returns (uint256);

    function referralLinkExists(string calldata referralCode) external view returns (bool);

    function getLevelMatrixParent(uint256, uint256) external view returns (uint256 newParent, uint256[] memory overtakenUsers);

    function getDirectUplink(uint256) external view returns (uint256);

    function getAverageAPY() external view returns (uint256);

    function totalMembers() external view returns (uint256);

    function totalSupply() external view returns (uint256);

    function getLiquidationInfo(uint256 tokenId) external view returns (LiquidationInfo memory);

    function requestLiquidation(uint256 tokenId) external returns (bool);

    function liquidateAccount(uint256 tokenId) external;

    function cancelLiquidation(uint256 tokenId) external;

}// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.18;

interface IBurnControllerV2 {

    function burnExisting() external;
    function burnWithTransfer(uint256 amount) external;
}// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.18;

interface IBuybackController {

    event BoughtBackMFI(address indexed token, uint256 tokenAmount, uint256 mfiReceived);

    function buyBackMFI(address token, uint256 tokenAmount, uint256 minMFIOut) external;

}// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.18;

import "./IMatrix.sol";
import "./ILiquidityController.sol";
import "./IBuybackController.sol";

interface IContractRegistry {

    function contractAddressExists(bytes32 nameHash) external view returns (bool);
    function matrixExists(uint256 level) external view returns (bool);
    function liquidityControllerExists(string calldata name) external view returns (bool);
    function buybackControllerExists(string calldata name) external view returns (bool);
    function priceCalculatorExists(address currency) external view returns (bool);

    function getContractAddress(bytes32 nameHash) external view returns (address);
    function getMatrix(uint256 level) external view returns (IMatrix);
    function getLiquidityController(string calldata name) external view returns (ILiquidityController);
    function getBuybackController(string calldata name) external view returns (IBuybackController);
    function getPriceCalculator(address currency) external view returns (address);
    function isRealmGuardian(address guardianAddress) external view returns (bool);
    function isCoinMaster(address masterAddress) external view returns (bool);

}// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.18;

interface IDestroyableContract {
    function destroyContract(address payable to) external;
}// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.18;

import "./ILendingStructs.sol";

// @title MetFi Lending contract
// @author MetFi
// @notice This contract is responsible for managing loans
interface ILending is ILendingStructs {
    //----------------- Getters -------------------------------------------------

    function getLendingConfiguration()
        external
        view
        returns (LendingConfiguration memory);

    function getLoanById(
        uint256 loanId
    ) external view returns (LoanInfo memory);

    //----------------- User functions -------------------------------------------

    function createLoan(CreateLoanRequest calldata request) external;

    function cancelLoan(uint256 loanId) external;

    function fundLoan(FundLoanRequest calldata request) external;

    function repayLoan(RepayLoanRequest memory request) external;

    function requestLoanExtension(
        ExtendLoanRequest calldata request
    ) external payable;

    function removeFunding(uint256 loanId) external;

    function addCollateral(AddCollateralRequest memory request) external;

    function liquidateLoanByDeadline(uint256 loanId) external;

    //----------------- System functions ------------------------------------------

    function extendLoan(ExtendLoanRequest calldata request) external;

    function liquidateLoans(uint256[] calldata loanId) external;

    function invalidateLoans(uint256[] calldata loanId) external;

    function migrateToNewLendingContract(
        uint256 maxLoansToProcess,
        address recipient
    ) external returns (uint256[] memory);

    //----------------- Manager functions ------------------------------------------
    function setLendingConfiguration(
        LendingConfiguration calldata newConfiguration
    ) external;
}
// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.18;

import "./ILendingStructs.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

// @title MetFi Lending Calculator contract
// @author MetFi
// @notice This contract is responsible for auctioning liquidated loans
interface ILendingAuction is IERC721Receiver {
    //----------------- Events -------------------------------------------------

    event AuctionCreated(uint256 indexed auctionId, uint256 indexed tokenId);

    event AuctionBid(
        uint256 indexed auctionId,
        uint256 indexed tokenId,
        uint256 oldBid,
        address oldBidder,
        uint256 newBid,
        address newBidder
    );

    event AuctionClaimed(uint256 indexed auctionId, uint256 indexed tokenId);

    event AuctionLiquidated(uint256 indexed auctionId, uint256 indexed tokenId);

    event AuctionConfigurationChanged(
        AuctionConfiguration oldConfiguration,
        AuctionConfiguration newConfiguration
    );

    //----------------- Structs -------------------------------------------------

    struct AuctionInfo {
        uint256 auctionId;
        uint256 tokenId;
        uint256 currentBid;
        address currentBidder;
        uint256 liquidationDeadline;
        uint256 biddingDeadline;
        AuctionStage stage;
    }

    struct AuctionConfiguration {
        uint256 minBidIncrement;
        uint256 startingPricePercentageOfFullPrice; // 1_000_000 = 100%
    }

    enum AuctionStage {
        CREATED,
        CLAIMED,
        LIQUIDATED,
        MIGRATED
    }

    //----------------- Getters -------------------------------------------------

    function getAuctionInfo(
        uint256 auctionId
    ) external view returns (AuctionInfo memory);

    function getActiveAuctions() external view returns (AuctionInfo[] memory);

    function getAuctionsForLiquidation()
        external
        view
        returns (uint256[] memory);

    function getAuctionConfiguration()
        external
        view
        returns (AuctionConfiguration memory);

    //----------------- User functions -------------------------------------------

    function bidOnAuction(uint256 auctionId, uint256 amount) external;

    function claimAuction(uint256 auctionId) external;

    //----------------- System functions ------------------------------------------

    function liquidateAuctions(uint256[] calldata auctionId) external;

    function migrateToNewAuctionContract(
        uint256 maxAuctionsToProcess,
        address recipient
    ) external returns (uint256[] memory);

    //----------------- Errors ----------------------------------------------------

    error OnlyAuctionManager();
    error BidOnOwnBid();
    error OnlyTreasury();
    error OnlyLending();
    error AuctionDoesNotExist();
    error BlacklistedAddress();
    error InvalidAddress();
    error AuctionNotFinished();
    error AuctionFinished();
    error NoBids();
    error BidTooLow();
    error AuctionAlreadyClaimed();
    error FailsafeEnabled();
    error AuctionNotDisabledBeforeMigration();
    error OnlyRealmGuardian();
    error MigrationAlreadyFinished();
}
// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.18;

import "./ILendingStructs.sol";

// @title MetFi Lending Calculator contract
// @author MetFi
// @notice This contract is responsible for calculating loan values
interface ILendingCalculator is ILendingStructs {
    function calculateLoanPercentageOfCollateralValue(
        uint256 tokenId,
        uint256 outstandingAmountBUSD,
        address[] calldata additionalCollateralAddresses,
        uint256[] calldata additionalCollateralAmounts
    ) external view returns (uint256);

    function calculateLoanPercentageOfStakedMFIValue(
        uint256 outstandingLoanAmount,
        uint256 tokenId
    ) external view returns (uint256);

    function calculateInterest(
        uint256 amount,
        uint256 apy,
        uint256 duration
    ) external pure returns (uint256);

    function checkLoanForInvalidation(
        LoanInfo calldata loanInfo
    ) external view returns (bool);

    function checkLoanForLiquidationByCollateral(
        LoanInfo calldata loanInfo
    ) external view returns (bool);

    function checkLoanForLiquidationByDeadline(
        LoanInfo calldata loanInfo
    ) external view returns (bool);

    function calculateLiquidationData(
        LoanInfo calldata loanInfo
    ) external view returns (LiquidationData memory, bool);

    function calculateCurrentTotalNFTRewards(
        uint256 tokenId
    ) external view returns (uint256);

    function calculateMaxLoanAmountForMFI(
        uint256 mfiAmount
    ) external view returns (uint256);

    function calculateMaxLoanAmountForToken(
        uint256 tokenId
    ) external view returns (uint256);

    function calculateMaxLoanAmountForLoan(
        uint256 loanId
    ) external view returns (uint256);

    function calculateBUSDValueOf(
        address currency,
        uint256 amount
    ) external view returns (uint256);

    function calculateMFIValueOf(
        address currency,
        uint256 amount
    ) external view returns (uint256);

    function calculateNewLeverageIndexForLoanAndCollateral(
        LoanInfo calldata loan,
        address currency,
        uint256 amount
    ) external view returns (uint256);

    function calculateMaxLoanAmountForMFIAndCollateral(
        uint256 mfiAmount,
        address[] calldata additionalCollateralAddresses,
        uint256[] calldata additionalCollateralAmounts,
        address newCollateralAddress,
        uint256 newCollateralAmount
    ) external view returns (uint256);
}
// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.18;

import "./ILendingStructs.sol";

// @title MetFi Lending checker contract
// @author MetFi
// @notice This contract is responsible for checking loans and lending configuration values
interface ILendingChecker is ILendingStructs {
    function checkLendingConfig(
        LendingConfiguration calldata config
    ) external pure;

    function checkLoan(
        CreateLoanRequest calldata request,
        address msgSender
    ) external view;
}
// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.18;

import "./ILendingStructs.sol";

// @title MetFi Lending Extension contract
// @author MetFi
// @notice This contract is responsible for EIP712 signatures for loan extensions
interface ILendingLoanExtensionController is ILendingStructs {
    function checkLenderSignatures(
        ExtendLoanRequest calldata request,
        LenderInfo[] calldata lenders
    ) external view;
}
// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.18;

import "./ILendingStructs.sol";

// @title MetFi Lending contract
// @author MetFi
// @notice This contract is responsible for managing loans
interface ILendingPlatformView is ILendingStructs {

    function borrowersLoans(address borrower, uint256 index) external view returns (uint256);

    function getLoanById(
        uint256 loanId
    ) external view returns (LoanInfo memory);
}
// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.18;

// @title MetFi Lending Structs
// @author MetFi
// @notice This contract is a base for all lending contracts
interface ILendingStructs {
    event LoanCreated(uint256 indexed loanId);
    event LoanLiquidated(uint256 indexed loanId);
    event LoanInvalidated(uint256 indexed loanId);
    event LoanFunded(
        uint256 indexed loanId,
        address indexed lender,
        uint256 amount
    );
    event LoanFullyFunded(uint256 indexed loanId);
    event LoanFundingRemoved(
        uint256 indexed loanId,
        address indexed lender,
        uint256 amount
    );
    event LoanRepaymentMade(uint256 indexed loanId);
    event LoanFullyRepaid(uint256 indexed loanId);
    event LoanExtensionRequested(uint256 indexed loanId);
    event LoanExtended(uint256 indexed loanId);
    event CollateralAdded(
        uint256 indexed loanId,
        address indexed currency,
        uint256 amount
    );

    struct LendingConfiguration {
        uint256 maxLoanDuration; // in number of seconds
        uint256 minLoanDuration; // in number of seconds
        uint256 minLoanAmount; // in BUSD
        uint256 minFundAmount; // in BUSD
        uint256 treasuryInterestPercentage; // 10000 = 100%
        uint256 foreignCurrencyExchangeFeePercentage; // 1_000_000 = 100%
        uint256 fundGracePeriod; // number of seconds, after which lender can remove funds from loan
        uint256 liquidationLoanPercentageOfStakedValue; // 1_000_000 = 100%
        uint256 warningLoanPercentageOfStakedValue; // 1_000_000 = 100%
        uint256 creationLoanPercentageOfStakedValue; // 1_000_000 = 100%
        uint256 liquidationGracePeriod; // number of seconds before loan can be liquidated
        uint256 maxLiquidationGracePeriod; // number of seconds after which loan can no longer be liquidated
        uint256 maxFundingWaitTime; // number of seconds after which not fully funded loan will be invalidated
        uint256 repaymentGracePeriod; // number of seconds after loan deadline, when loan can still be repaid without liquidation
        uint256 loanExtensionFeeInBNB; // Sent to loanExtensionFeeReceiver
        address payable loanExtensionFeeReceiver; // Address that receives loan extension fees
        uint256 loanLiquidationFeeInBUSD; // Sent to loanLiquidationFeeReceiver as BNB
        address loanLiquidationFeeReceiver; // Address that receives loan liquidation fees
        uint256[] liquidationFeePayoutCurve; // in percentage points (1000 = 100%) example that follows curve (x*x)/100 : [0,0,0,0,1,2,3,4,6,8,10,12,14,16,19,22,25,28,32,36,40,44,48,52,57,62,67,72,78,84,90,96,102,108,115,122,129,136,144,152,160,168,176,184,193,202,211,220,230,240,250,260,270,280,291,302,313,324,336,348,360,372,384,396,409,422,435,448,462,476,490,504,518,532,547,562,577,592,608,624,640,656,672,688,705,722,739,756,774,792,810,828,846,864,883,902,921,940,960,980,1000]
    }

    struct CreateLoanRequest {
        uint256 duration; // in seconds
        uint256 apyPercentage; // 10000 = 100%
        uint256 tokenId;
        uint256 amount;
    }

    struct RepayLoanRequest {
        uint256 loanId;
        uint256 amount; // Max amount to repay
    }

    struct FundLoanRequest {
        uint256 loanId;
        uint256 amount; // Max amount to fund
    }

    struct ExtendLoanRequest {
        uint256 oldDeadline;
        uint256 newDeadline;
        uint256 newInterestRate;
        uint256 loanId;
        bytes[] lenderSignatures;
    }

    struct AddCollateralRequest {
        uint256 loanId;
        address currency;
        uint256 amount;
    }

    struct ExtendLoanLenderApproval {
        uint256 oldDeadline;
        uint256 newDeadline;
        uint256 newInterestRate;
        uint256 loanId;
    }

    struct EarlyLoanRepaymentClaimRequest {
        uint256 loanId;
        uint256 lenderIndex; // To avoid gas fees
    }

    struct LoanInfo {
        uint256 loanId;
        uint256 tokenId;
        uint256 apy;
        uint256 amount;
        address borrower;
        uint256 duration;
        uint256 deadline;
        uint256 amountFunded; // Amount funded by lenders
        uint256 repaidAmount; // Amount repaid by borrower
        uint256 totalInterest;
        uint256 creationTimestamp;
        uint256 liquidationTimestamp;
        uint256 fundedTimestamp;
        uint256 repaidTimestamp;
        uint256 totalRewardsAtLastRepaymentTime; // Or at funded time if no repayment has been made
        LoanStage stage;
        LenderInfo[] lenderInfo;
        address[] additionalCollateralAddresses; // additional collateral for loan
        uint256[] additionalCollateralAmounts; // additional collateral for loan
    }

    struct LenderInfo {
        address lender;
        uint256 shareOfLoan; // Percentage of loan funded by lender 100 % = 100_000_000
        uint256 lastFundingTimestamp;
    }

    struct LiquidationData {
        uint256 totalMFIInLiquidation;
        uint256 MFIIn;
        uint256 BUSDFromMFI;
        uint256[] collateralIn;
        uint256[] collateralForTreasury;
        uint256[] BUSDFromCollateralLiquidation;
        uint256[] lenderPayouts;
    }

    enum LoanStage {
        Created, // Create by borrower
        Funded, // Completely funded by lenders
        Repaid, // Repaid by borrower. All lenders have been repaid and received their interest
        Liquidated, // Liquidated by the protocol. All lenders have been repaid and received their interest in proportion to the start time of the loan
        Invalidated, // Invalidated by the lender
        Migrated // Migrated to a new contract
    }

    // Access Control
    error OnlyTreasury();
    error OnlyLendingManager();
    error BlacklistedAddress();
    error OnlyLender();
    error OnlyRealmGuardian();

    // Extend
    error NotBorrower();
    error InvalidLenderSignatureCount();
    error LoanExtensionNotRequested();
    error InvalidLoanExtensionRequest();

    // Create
    error NotTokenOwner();
    error LoanAmountTooLow();
    error LoanDurationTooLong();
    error NotEnoughCollateral();
    error LoanDurationTooShort();
    error LoanCreationNotAllowed();
    error NFTInLiquidation();
    error NFTInLiquidated();
    error OnlyOneActiveLoanPerNFT();

    // Common
    error NotApproved();
    error InsufficientBalance();
    error LoanNotInFundedStage();
    error InsufficientAllowance();
    error LoanDoesNotExist();
    error FailsafeEnabled();
    error NotInitialized();
    error AlreadyInitialized();
    error MoreThanNeededAlreadyRepaid();

    // Migration
    error LendingNotDisabledBeforeMigration();
    error MigrationAlreadyFinished();

    // Fund
    error AmountTooLow();
    error LenderNotFound();
    error FundAmountTooLow();
    error LoanNotInCreatedStage();
    error CannotFundOwnLoan();
    error FundingTimeExpired();
    error CannotRemoveFundingBeforeGracePeriod(uint256 timestamp);
    error LoanExtensionFeeTooLow();

    // Collateral
    error CollateralCurrencyNotApproved();

    // Lending Configuration
    error InvalidAddress();
    error InvalidLoanDurationConfig();
    error InvalidLiquidationGracePeriod();
    error InvalidLiquidationFeePayoutCurve();
    error InvalidLoanPercentageOfStakedValue();
}
// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.18;

import "./ILendingStructs.sol";

// @title MetFi Lending View contract
// @author MetFi
// @notice This contract is a central point for getting information about loans
interface ILendingView is ILendingStructs {
    function getLoanInfo(
        uint256 loanId
    ) external view returns (LoanInfo memory);

    function getLoansByBorrower(
        address borrower
    ) external view returns (LoanInfo[] memory);

    function getLoansByLender(
        address lender
    ) external view returns (LoanInfo[] memory);

    function getLoanCollateralization(
        uint256 loanId
    ) external view returns (uint256);

    function getActiveLoans() external view returns (LoanInfo[] memory);

    function getLoanExtensionRequest(
        uint256 loanId
    ) external view returns (ExtendLoanRequest memory);

    function getLoansForLiquidationByCollateralRatio()
        external
        view
        returns (uint256[] memory);

    function getLoansForInvalidation() external view returns (uint256[] memory);

    function canLoanBeLiquidatedByCollateralRatio(
        uint256 loanId
    ) external view returns (bool);

    function canLoanBeLiquidatedByDeadline(
        uint256 loanId
    ) external view returns (bool);

    function getMaxLoanValueForToken(
        uint256 tokenId
    ) external view returns (uint256);

    function getMaxLoanValueForLoan(
        uint256 loanId
    ) external view returns (uint256);

    function getMaxLoanValueForMFI(
        uint256 mfiAmount
    ) external view returns (uint256);

    function getNewLeverageIndexForLoanAndCollateral(
        uint256 loanId,
        address currency,
        uint256 amount
    ) external view returns (uint256);

    function getBUSDValueOf(
        address currency,
        uint256 amount
    ) external view returns (uint256);

    function getMFIValueOf(
        address currency,
        uint256 amount
    ) external view returns (uint256);

    function getRemainingMaxLoanAmount() external view returns (uint256);
}
// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.18;

interface ILiquidityController {

    event LiquidityProvided(address indexed tokenUsed, uint256 mfiProvided, uint256 liquidityTokensProvided, uint256 lpTokensReceived);
    event LiquidityRemoved(address indexed tokenUsed, uint256 lpTokensRedeemed, uint256 mfiReceived, uint256 liquidityTokensReceived);

    function getLPTokenAddress(address tokenToUse) external view returns (address);
    function claimableTokensFromTreasuryLPTokens(address tokenToUse) external view returns (uint256);
    function mfiRequiredForProvidingLiquidity(address tokenToUse, uint256 amount, uint256 MFIMin) external view returns (uint256);
    function provideLiquidity(address tokenToUse, uint256 amount, uint256 MFIMin) external;
    function removeLiquidity(address tokenToUse, uint256 lpTokenAmount, uint256 tokenMin) external;

}// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.18;

import "./ILendingStructs.sol";

// @title MetFi Lending Limiter contract
// @author MetFi
// @notice This contract is responsible for limiting loans
interface ILoanLimiter is ILendingStructs{
    function canLoanBeCreated(CreateLoanRequest memory loanRequest) external view returns (bool);

    function onLoanCreated(LoanInfo memory loanInfo, CreateLoanRequest memory loanRequest) external;

    function onLoanFunded(LoanInfo memory loanInfo, FundLoanRequest memory fundLoanRequest) external;

    function onLoanRepaid(LoanInfo memory loanInfo, RepayLoanRequest memory repayLoanRequest) external;

    function onLoanExtended(LoanInfo memory loanInfo, ExtendLoanRequest memory extendLoanRequest) external;

    function onLoanLiquidated(LoanInfo memory loanInfo) external;

    function onLoanInvalidated(LoanInfo memory loanInfo) external;


}// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.18;

interface ILostTokenProvider {
    function getLostTokens(address tokenAddress) external;
}
// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.18;

interface IManageableTreasury {

    function manage(address to, address token, uint256 amount) external;

}// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.18;

interface IMatrix {

    event NodeAdded(uint256 indexed nftId, uint256 indexed parentId, uint256 indexed parentLeg);
    event SubtreeNodeAdded(uint256 indexed nftId, uint256 indexed offset, uint256 indexed level);

    struct Node {
        uint256 ID;
        uint256 ParentID;
        uint256 L0;
        uint256 L1;
        uint256 L2;
        uint256 parentLeg;
    }

    function addNode(uint256 nodeId, uint256 parentId) external;
    function getDistributionNodes(uint256 nodeId) external view returns (uint256[] memory distributionNodes);
    function getUsersInLevels(uint256 nodeId, uint256 numberOfLevels) external view returns (uint256[] memory levels, uint256 totalUsers);
    function getSubNodesToLevel(uint256 nodeId, uint256 toDepthLevel) external view returns (Node memory parentNode, Node[] memory subNodes);
}// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.18;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/draft-ERC20Permit.sol";

import "./ILostTokenProvider.sol";

interface IMETFI is IERC20, ILostTokenProvider, IERC20Permit {

    function burn(uint256 amount) external;

}
// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.18;

interface IMETFIStakingPool {

    event METFIWithdrawn(address indexed user, uint256 amount);
    event METFIWithdrawnForNextStakingPeriod(address indexed user, uint256 amount);
    event METFIPercentageForPeriodChanged(uint256 percentage);
    event METFIBurnedFromPool(uint256 amount);
    event METFIStakingPoolMigrated(address indexed to, uint256 amount);

    function withdrawMETFI(address to, uint256 METFIAmount) external;
    function withdrawMETFIForNextStakingPeriod() external returns (uint256 amount);

}// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.18;

interface IMETFIVault {

    event METFIWithdrawn(address indexed to, uint256 amount);

    function withdrawMETFI(address to, uint256 amount) external;
}// SPDX-License-Identifier: MIT

pragma solidity >=0.6.2;

interface IPancakeRouter01 {
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
}// SPDX-License-Identifier: MIT

pragma solidity >=0.6.2;

import './IPancakeRouter01.sol';

interface IPancakeRouter02 is IPancakeRouter01 {
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
}// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.18;

import "./ITokenCollector.sol";
import "./IMatrix.sol";
import "./IRewardDistributor.sol";
import "./IUserConfig.sol";

interface IPlatformView {

    struct NFTData {
        uint256 ID;
        uint256 level;
        string referralLink;
        uint256 directUplink;
        uint256 stakedTokens;
        IRewardDistributor.RewardAccountInfo rewardingInfo;
        uint256[][] usersInLevel;
        uint256[] totalUsersInMatrix;
        uint256 directlyEnrolledMembers;
        uint256 liquidationRequestTime;
        uint256 liquidationAvailableTime;
        uint256 liquidationExpiredTime;
        bool liquidated;
        bool stakingPaused;
        bool readOnly;
        IUserConfig.UserConfigValues userConfigValues;
    }

    struct TreeNodeData {
        NFTData nftData;
        IMatrix.Node node;
    }

    struct PlatformData {
        uint256 MFIPrice;
        uint256 totalMembers;
        uint256 averageAPY;
        uint256 treasuryValue;
        uint256 treasuryRiskFreeValue;
        uint256 stakedTokens;
        uint256 valuePerToken;
        uint256 backingPerToken;
        uint256 nextRebaseAt;
        uint256 totalRewardsPaid;
        ITokenCollector.CollectionType tokenCollectionType;
        ITokenCollector.PriceCalculationType priceCalculationType;
        uint256 tokenCollectionPercentage;
        uint256 mfiLiquidityReserve;
        uint256 stableCoinLiquidityReserve;
    }

    function getWalletData(address wallet) external view returns (NFTData[] memory);
    function getNFTData(uint256 nftId) external view returns (NFTData memory NFT);
    function getReferralCodeData(string calldata referralCode) external view returns (NFTData memory);
    function referralLinkExists(string calldata referralCode) external view returns (bool);

    function getAddressActiveLoanNFTs(address borrower) external view returns (uint256[] memory);

    function getMFIPrice() external view returns (uint256);
    function getPlatformData() external view returns (PlatformData memory);

    function getTreeData(uint256 nftId, uint256 matrixLevel, uint256 toDepthLevel) external view returns (TreeNodeData memory selectedNFT, TreeNodeData[] memory subNFTs);

    function stakedTokens(uint256 nftId) external view returns (uint256);
    function stakingPaused(uint256 nftId) external view returns (bool);
    function stakedTokensForAddress(address wallet) external view returns (uint256);
    function getUsersInLevels(uint256 nodeId, uint256 level) external view returns (uint256[] memory levels, uint256 totalUsers);

}// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.18;

import "./ITokenCollectorV2.sol";
import "./IMatrix.sol";
import "./IRewardDistributor.sol";
import "./IUserConfig.sol";

interface IPlatformViewV2 {

    struct NFTData {
        uint256 ID;
        uint256 level;
        string referralLink;
        uint256 directUplink;
        uint256 stakedTokens;
        IRewardDistributor.RewardAccountInfo rewardingInfo;
        uint256[][] usersInLevel;
        uint256[] totalUsersInMatrix;
        uint256 directlyEnrolledMembers;
        uint256 liquidationRequestTime;
        uint256 liquidationAvailableTime;
        uint256 liquidationExpiredTime;
        bool liquidated;
        bool stakingPaused;
        bool readOnly;
        IUserConfig.UserConfigValues userConfigValues;
    }

    struct TreeNodeData {
        NFTData nftData;
        IMatrix.Node node;
    }

    struct PlatformData {
        uint256 METFIPrice;
        uint256 totalMembers;
        uint256 averageAPY;
        uint256 treasuryValue;
        uint256 treasuryRiskFreeValue;
        uint256 stakedTokens;
        uint256 valuePerToken;
        uint256 backingPerToken;
        uint256 nextRebaseAt;
        uint256 totalRewardsPaid;
        ITokenCollectorV2.CollectionType tokenCollectionType;
        ITokenCollectorV2.PriceCalculationType priceCalculationType;
        uint256 tokenCollectionPercentage;
        uint256 metfiLiquidityReserve;
        uint256 stableCoinLiquidityReserve;
        bool dynamicStaking;
        uint256[] currentStakingMultipliers;
        uint256 rebasesUntilNextHalvingOrDistribution;
    }

    function getWalletData(address wallet) external view returns (NFTData[] memory);
    function getNFTData(uint256 nftId) external view returns (NFTData memory NFT);
    function getReferralCodeData(string calldata referralCode) external view returns (NFTData memory);
    function referralLinkExists(string calldata referralCode) external view returns (bool);

    function getAddressActiveLoanNFTs(address borrower) external view returns (uint256[] memory);

    function getMETFIPrice() external view returns (uint256);
    function getPlatformData() external view returns (PlatformData memory);

    function getTreeData(uint256 nftId, uint256 matrixLevel, uint256 toDepthLevel) external view returns (TreeNodeData memory selectedNFT, TreeNodeData[] memory subNFTs);

    function stakedTokens(uint256 nftId) external view returns (uint256);
    function stakingPaused(uint256 nftId) external view returns (bool);
    function stakedTokensForAddress(address wallet) external view returns (uint256);
    function getUsersInLevels(uint256 nodeId, uint256 level) external view returns (uint256[] memory levels, uint256 totalUsers);

}// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.18;

interface IPriceCalculator {

    function exchangePairSet() external view returns (bool);
    function getReserves() external view returns (uint256 calculatedTokenReserve, uint256 reserveTokenReserve);
    function getPriceInUSD() external view returns (uint256);
    function tokensForPrice(uint256 reserveTokenAmount) external view returns (uint256);
    function priceForTokens(uint256 numberOfTokens) external view returns (uint256);

}// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.18;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IRewardConverter {

    function sendReward(uint256 nftId, IERC20 primaryStableCoin, uint256 amount) external;

}
// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.18;

import "./IMatrix.sol";

interface IRewardDistributor {

    event AccountCreated(uint256 indexed nftId, uint256 indexed parentId);
    event AccountUpgraded(uint256 indexed nftId, uint256 indexed level);
    event BonusActivated(uint256 indexed nftId);
    event AccountLiquidated(uint256 indexed nftId);

    event RewardSent(uint256 indexed nftId, uint256 indexed from, uint256 indexed rewardType, uint256 level, uint256 matrixLevel, uint256 amount);
    event MatchingBonusSent(uint256 indexed nftId, uint256 indexed from, uint256 amount);
    event FastStartBonusReceived(uint256 indexed nftId, uint256 indexed from, uint256 amount, bool autoClaimed);

    struct RewardAccountInfo {
        uint256 ID;
        uint256 directUplink;
        uint256 fastStartBonus;
        uint256 receivedMatchingBonus;
        uint256 receivedMatrixBonus;
        uint64 bonusDeadline;
        uint64 activeBonusUsers;
        bool bonusActive;
        bool accountLiquidated;
    }

    function getAccountInfo(uint256 nftId) external view returns (RewardAccountInfo memory);
    function createAccount(uint256 nftId, uint256 parentId) external;
    function accountUpgraded(uint256 nftId, uint256 level) external;
    function liquidateAccount(uint256 nftId) external;
    function distributeRewards(uint256 distributionValue, uint256 rewardType, uint256 nftId, uint256 level) external;
}// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.18;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./IRewardDistributor.sol";
import "./ITokenCollector.sol";
import "./IMatrix.sol";
import "./ILendingStructs.sol";

interface IRouterV3 {

    event AccountCreated(uint256 indexed nftId, uint256 indexed parentId, uint256 indexed level, uint256 additionalTokensPrice, string referralLink, uint256 freeMFITokensReceived);
    event AccountLiquidationStarted(uint256 indexed nftId);
    event AccountLiquidationCanceled(uint256 indexed nftId);
    event AccountLiquidated(uint256 indexed nftId);
    event AccountUpgraded(uint256 indexed nftId, uint256 indexed level, uint256 additionalTokensPrice, uint256 freeMFITokensReceived);
    event TokensStaked(uint256 indexed nftId, uint256 numberOfTokens);
    event TokensBought(uint256 indexed nftId, uint256 usdtPrice, uint256 numberOfTokens, uint256 accountLevel);
    event AccountOvertaken(uint256 indexed overtakenAccount, uint256 indexed overtakenBy, uint256 indexed level);
    event StakingResumed(uint256 indexed nftId);

    function resumeStaking(uint256 nftId) external;

    function createAccount(address newOwner, uint256 level, uint256 minTokensOut, uint256 minBonusTokens, string calldata newReferralLink, uint256 additionalTokensValue, bool isCrypto, address paymentCurrency,uint256 maxTokensIn) external payable returns (uint256);
    function createAccountWithReferral(address newOwner, string calldata referralId, uint256 level, uint256 minTokensOut, uint256 minBonusTokens, string calldata newReferralLink, uint256 additionalTokensValue, bool isCrypto, address paymentCurrency,uint256 maxTokensIn) external payable returns (uint256);
    function upgradeNFTToLevel(uint256 nftId, uint256 minTokensOut, uint256 minBonusTokens, uint256 finalLevel, uint256 additionalTokensValue, address paymentCurrency,uint256 maxTokensIn) external payable;


    function setReferralLink(uint256 nftId, string calldata newReferralLink) external;

    function liquidateAccount(uint256 nftId) external;
    function cancelLiquidation(uint256 nftId) external;

    function stakeTokens(uint256 nftId, uint256 numberOfTokens) external;

    function setUserConfigUintValue(uint256 nftId, string memory key, uint256 value) external;
    function setUserConfigStringValue(uint256 nftId, string memory key, string memory value) external;

    function buyTokens(uint256 nftId, uint256 primaryStableCoinPrice, uint256 minTokensOut, IERC20 paymentCurrency) payable external;

}// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.18;

interface ISecurityProxy {
    function validateTransfer(address from, address to, uint256 amount) external view returns (bool);
}// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.18;

interface IStakingManager {

    event StakingAccountCreated(uint256 indexed nftId, uint256 indexed level, uint256 numberOfTokens);
    event StakingAccountLiquidated(uint256 indexed nftId, uint256 unstakedTokens);
    event TokensAddedToStaking(uint256 indexed nftId, uint256 numberOfTokens);
    event StakingAccountUpgraded(uint256 indexed nftId, uint256 indexed level, uint256 numberOfTokens);
    event StakingLevelRebased(uint256 indexed level, uint256 lockedTokens);
    event StakingRebased(uint256 totalTokens);

    function getAccountTokens(uint256 tokenId) external view returns(uint256);
    function createStakingAccount(uint256 tokenId, uint256 tokenAmount, uint256 level) external;
    function liquidateAccount(uint256 tokenId, address owner) external;
    function addTokensToStaking(uint256 tokenId, uint256 numberOfTokens) external;
    function upgradeStakingAccountToLevel(uint256 tokenId, uint256 level) external;
    function timeToNextRebase() external view returns (uint256);
    function nextRebaseAt() external view returns (uint256);
    function rebase() external;

    function enterLiquidation() external returns (uint256 totalMFIStaked);

}// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.18;

import "./IStakingManager.sol";

interface IStakingManagerV2 is IStakingManager {

    event StakingPaused(uint256 indexed tokenId, uint256 MFIAmount);
    event StakingResumed(uint256 indexed tokenId, uint256 MFIAmount);
    event ClaimedTokensFromAccount(uint256 indexed tokenId, uint256 MFIAmount);

    function isAccountPaused(uint256 tokenId) external view returns (bool);
    function pauseStaking(uint256 tokenId) external;
    function resumeStaking(uint256 tokenId) external;
    function claimTokensFromAccount(uint256 tokenId, uint256 numberOfTokens, address destinationAddress) external;
}// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.18;

import "./IStakingManagerV2.sol";

interface IStakingManagerV3 is IStakingManagerV2 {

    event StakingPeriodLengthChanged(uint256 oldLength, uint256 newLength);
    event AddedAllowedMETFITakingContract(string indexed takingContract);
    event RemovedAllowedMETFITakingContract(string indexed takingContract);

    function isInDynamicStaking() external view returns (bool);
    function rebasesUntilNextHalvingOrDistribution() external view returns (uint256);
    function currentStakingMultipliersOrNewTokensPerLevelPerMETFI() external view returns (uint256[] memory);
}// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.18;

interface ITokenCollector {

    event CollectedBonusTokens(uint256 busdPrice, uint256 numberOfTokens);
    event CollectedTokens(uint256 busdPrice, uint256 numberOfTokens, uint256 collectionType, uint256 slippageCalculationType);
    event CollectionTypeChanged(uint256 collectionType);
    event PriceCalculationTypeChanged(uint256 priceCalculationType);

    enum CollectionType {
        MINTING,
        SWAP
    }

    enum PriceCalculationType {
        TOKEN_PRICE_BASED,
        POOL_BASED
    }

    function getBonusTokens(uint256 busdPrice) external returns (uint256);
    function getTokens(uint256 busdPrice, uint256 minTokensOut) external returns (uint256);
    function getCollectionType() external view returns (CollectionType);
    function getPriceCalculationType() external view returns (PriceCalculationType);
    function getAdditionalTokensPercentage() external view returns (uint256);
}// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.18;

import "./ITokenCollector.sol";

interface ITokenCollectorV2 {

    event CollectedBonusTokens(uint256 stableCoinPrice, uint256 numberOfTokens);
    event CollectedTokens(uint256 stableCoinPrice, uint256 numberOfTokens, uint256 collectionType, uint256 slippageCalculationType);
    event CollectionTypeChanged(uint256 collectionType);
    event PriceCalculationTypeChanged(uint256 priceCalculationType);
    event AdditionalTokensPercentageChanged(uint256 additionalTokensPercentage);
    event BonusTokenPercentageFromSwapChanged(uint256 bonusTokenPercentageFromSwap);
    event BoolValuesChanged(bool fullFromSwap, bool usePool);

    enum CollectionType {
        SWAP,
        POOL
    }

    enum PriceCalculationType {
        TOKEN_PRICE_BASED,
        POOL_BASED
    }

    function getBonusTokens(uint256 stableCoinPrice, uint256 minBonusTokens) external returns (uint256);
    function getTokens(uint256 stableCoinPrice, uint256 minTokensOut) external returns (uint256);
    function getCollectionType() external view returns (CollectionType);
    function getPriceCalculationType() external view returns (PriceCalculationType);
    function getAdditionalTokensPercentage() external view returns (uint256);

}// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.18;

interface ITreasuryV2 {

    enum TokenType {
        RESERVE_TOKEN,
        LP_TOKEN,
        LIQUIDITY_TOKEN
    }

    event StakingRewardsDistributed(uint256 indexed amount);
    event RewardsSent(uint256 nftId, uint256 amount);

    function sendReward(uint256 nftId, uint256 amount) external;

    function getTotalRewardsPaid() external view returns (uint256);

    function getValue() external view returns (uint256 totalValue, uint256 riskFreeValue);

    function getTokensForCollector(address token, uint256 amount, address to) external;
}// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.18;

interface IUserConfig {

    event UserConfigUintValueUpdated(address indexed user, string indexed key, uint256 old_value, uint256 new_value);
    event UserConfigStringValueUpdated(address indexed user, string indexed key, string old_value, string new_value);
    event AllowedStringKeyAdded(string key);
    event AllowedUintKeyAdded(string key);

    struct UserConfigUintValue {
        string key;
        uint256 value;
    }

    struct UserConfigStringValue {
        string key;
        string value;
    }

    struct UserConfigValues {
        UserConfigUintValue[] uintValues;
        UserConfigStringValue[] stringValues;
    }

    function getAllUserConfigValues(uint256 nftId) external view returns (UserConfigValues memory values);
    function getUserConfigUintValue(uint256 nftId, string memory key) external view returns (uint256 value);
    function getUserConfigStringValue(uint256 nftId, string memory key) external view returns (string memory value);

    function setUserConfigUintValue(uint256 nftId, string memory key, uint256 value) external;
    function setUserConfigStringValue(uint256 nftId, string memory key, string memory value) external;

}
// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.18;

interface IValueCalculator {
    function calculateValue() external view returns (uint256, uint256);
}// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.18;

import "./ContractRegistryUser.sol";

contract TreasuryV2 is ITreasuryV2, ContractRegistryUser {

    using SafeERC20 for IERC20;
    using SafeERC20 for IMETFI;
    using Address for address payable;

    struct LPTokenSettings {
        string liquidityController;
        address baseToken;
        bool reserveToken;
    }

    struct LiquidationTokenInfo {
        address token;
        uint256 totalAmount;
    }

    address[] public reserveTokens;
    LPTokenSettings[] public lpTokens;
    IValueCalculator[] public valueCalculators;
    address[] public liquidityTokens;

    uint256 public totalRewardsPaid;

    bool public inLiquidation = false;
    uint256 public totalMETFIInLiquidation;
    address payable public liquidationAddress;
    uint256 public liquidationBNBAmount;
    LiquidationTokenInfo[] public liquidationTokens;


    //----------------- Access control ------------------------------------------

    function notInLiquidation() internal view {
        require(!inLiquidation, "liquidation active");
    }
    //---------------------------------------------------------------------------

    constructor(IContractRegistry _contractRegistry, uint256 totalRewardsPaidPrevious) ContractRegistryUser(_contractRegistry) {
        reserveTokens.push(contractRegistry.getContractAddress(PRIMARY_STABLECOIN_HASH));
        totalRewardsPaid = totalRewardsPaidPrevious;
    }

    function sendReward(uint256 nftId, uint256 amount) external override {
        onlyRewardDistributor();
        notInLiquidation();

        totalRewardsPaid += amount;

        if (nftId == 1) return;

        getPrimaryStableCoin().approve(contractRegistry.getContractAddress(REWARD_CONVERTER_HASH), amount);

        getRewardConverter().sendReward(nftId, getPrimaryStableCoin(), amount);

        emit RewardsSent(nftId, amount);
    }

    function getTotalRewardsPaid() external view override returns (uint256) {
        return totalRewardsPaid;
    }

    function getTokensForCollector(address token, uint256 amount, address to) external override {
        notInLiquidation();
        onlyTokenCollector();
        IERC20(token).safeTransfer(to, amount);
    }

    function getValue() public view override returns (uint256 totalValue, uint256 riskFreeValue) {


        for (uint256 x = 0; x < reserveTokens.length; x++) {
            riskFreeValue += IERC20(reserveTokens[x]).balanceOf(address(this)) * (10 ** 18) / IERC20Metadata(reserveTokens[x]).decimals();
        }

        for (uint256 x = 0; x < lpTokens.length; x++) {

            ILiquidityController controller = contractRegistry.getLiquidityController(lpTokens[x].liquidityController);
            uint256 claimableTokens = controller.claimableTokensFromTreasuryLPTokens(lpTokens[x].baseToken);

            if (lpTokens[x].reserveToken) {
                riskFreeValue += claimableTokens * (10 ** 18) / IERC20Metadata(lpTokens[x].baseToken).decimals();
            } else {
                totalValue += getPriceCalculator(lpTokens[x].baseToken).priceForTokens(claimableTokens);
            }
        }

        for (uint256 x = 0; x < liquidityTokens.length; x++) {
            totalValue += getPriceCalculator(liquidityTokens[x]).priceForTokens(IERC20(liquidityTokens[x]).balanceOf(address(this)));
        }

        totalValue += riskFreeValue;

        for (uint256 x = 0; x < valueCalculators.length; x++) {
            (uint256 calculatorTotalValue, uint256 calculatorRiskFreeValue) = valueCalculators[x].calculateValue();
            totalValue += calculatorTotalValue;
            riskFreeValue += calculatorRiskFreeValue;
        }


        return (totalValue, riskFreeValue);
    }

    function isLPTokenTracked(address token, string calldata liquidityControllerName) public view returns (bool) {
        for (uint256 x = 0; x < lpTokens.length; x++) {
            if (lpTokens[x].baseToken == token && keccak256(abi.encodePacked(lpTokens[x].liquidityController)) == keccak256(abi.encodePacked(liquidityControllerName))) return true;
        }

        return false;
    }

    function getTokenType(address token) public view returns (TokenType tokenType, bool found) {

        for (uint256 x = 0; x < reserveTokens.length; x++) {
            if (reserveTokens[x] == token) return (TokenType.RESERVE_TOKEN, true);
        }

        for (uint256 x = 0; x < liquidityTokens.length; x++) {
            if (liquidityTokens[x] == token) return (TokenType.LIQUIDITY_TOKEN, true);
        }

        return (TokenType.LIQUIDITY_TOKEN, false);
    }

    function startTrackingToken(TokenType tokenType, address token, bool isReserveToken, string calldata liquidityControllerName) external {
        onlyRealmGuardian();
        notInLiquidation();

        _startTrackingToken(tokenType, token, isReserveToken, liquidityControllerName);
    }

    function _startTrackingToken(TokenType tokenType, address token, bool isReserveToken, string calldata liquidityControllerName) internal {

        if (tokenType == TokenType.RESERVE_TOKEN) {

            for (uint256 x = 0; x < reserveTokens.length; x++) {
                if (reserveTokens[x] == token) return;
            }

            reserveTokens.push(token);
        } else if (tokenType == TokenType.LIQUIDITY_TOKEN) {

            for (uint256 x = 0; x < liquidityTokens.length; x++) {
                if (liquidityTokens[x] == token) return;
            }

            liquidityTokens.push(token);
        } else if (tokenType == TokenType.LP_TOKEN) {

            for (uint256 x = 0; x < lpTokens.length; x++) {
                if (lpTokens[x].baseToken == token) return;
            }

            if (!isReserveToken) {
                require(contractRegistry.getPriceCalculator(token) != address(0), "no price calculator");
            }

            lpTokens.push(LPTokenSettings(liquidityControllerName, token, isReserveToken));
        }
    }

    function stopTrackingToken(TokenType tokenType, address token, string calldata liquidityControllerName) external {
        onlyRealmGuardian();
        notInLiquidation();
        _stopTrackingToken(tokenType, token, liquidityControllerName);
    }

    function _stopTrackingToken(TokenType tokenType, address token, string calldata liquidityControllerName) internal {

        if (tokenType == TokenType.RESERVE_TOKEN) {
            for (uint256 x = 0; x < reserveTokens.length; x++) {
                if (reserveTokens[x] == token) {
                    reserveTokens[x] = reserveTokens[reserveTokens.length - 1];
                    reserveTokens.pop();
                    break;
                }
            }
        } else if (tokenType == TokenType.LIQUIDITY_TOKEN) {
            for (uint256 x = 0; x < liquidityTokens.length; x++) {
                if (liquidityTokens[x] == token) {
                    liquidityTokens[x] = liquidityTokens[liquidityTokens.length - 1];
                    liquidityTokens.pop();
                    break;
                }
            }
        } else if (tokenType == TokenType.LP_TOKEN) {
            for (uint256 x = 0; x < lpTokens.length; x++) {
                if (lpTokens[x].baseToken == token && keccak256(abi.encodePacked(lpTokens[x].liquidityController)) == keccak256(abi.encodePacked(liquidityControllerName))) {
                    lpTokens[x] = lpTokens[lpTokens.length - 1];
                    lpTokens.pop();
                    break;
                }
            }
        }

    }

    function provideLiquidity(string calldata controllerName, address tokenToUse, uint256 amount, uint256 minMETFI) external {
        onlyRealmGuardian();
        notInLiquidation();

        ILiquidityController controller = contractRegistry.getLiquidityController(controllerName);

        uint256 neededMETFI = controller.mfiRequiredForProvidingLiquidity(tokenToUse, amount, minMETFI);
        // Take from METFIVault
        getMETFIVault().withdrawMETFI(address(controller), neededMETFI);

        IERC20(tokenToUse).safeTransfer(address(controller), amount);

        controller.provideLiquidity(tokenToUse, amount, minMETFI);

        IMETFI metfi = getMETFI();

        if (metfi.balanceOf(address(this)) > 0) {
            metfi.safeTransfer(address(getMETFIVault()), metfi.balanceOf(address(this)));
        }

        if (!isLPTokenTracked(tokenToUse, controllerName)) {

            (TokenType tokenType, bool found) = getTokenType(tokenToUse);
            if (found) {
                _startTrackingToken(TokenType.LP_TOKEN, tokenToUse, tokenType == TokenType.RESERVE_TOKEN, controllerName);
            }

        }
    }

    function removeLiquidity(string calldata controllerName, address tokenToUse, uint256 lpTokenAmount, uint256 tokenMin) external {
        onlyRealmGuardian();
        notInLiquidation();

        ILiquidityController controller = contractRegistry.getLiquidityController(controllerName);
        IMETFI metfi = getMETFI();

        IERC20 lpToken = IERC20(controller.getLPTokenAddress(tokenToUse));
        lpToken.safeTransfer(address(controller), lpTokenAmount);

        controller.removeLiquidity(tokenToUse, lpTokenAmount, tokenMin);

        metfi.safeTransfer(address(getMETFIVault()), metfi.balanceOf(address(this)));

        if (lpToken.balanceOf(address(this)) == 0 && isLPTokenTracked(tokenToUse, controllerName)) {
            _stopTrackingToken(TokenType.LP_TOKEN, tokenToUse, controllerName);
        }
    }

    function collectLostTokensFromContract(address token, address metFiContract) external {
        onlyRealmGuardian();
        notInLiquidation();
        ILostTokenProvider(metFiContract).getLostTokens(token);
    }

    function addValueCalculator(address valueCalculator) external {
        onlyRealmGuardian();

        valueCalculators.push(IValueCalculator(valueCalculator));
    }

    function removeValueCalculator(address valueCalculator) external {

        onlyRealmGuardian();

        for (uint256 x = 0; x < valueCalculators.length; x++) {
            if (address(valueCalculators[x]) == valueCalculator) {
                valueCalculators[x] = valueCalculators[valueCalculators.length - 1];
                valueCalculators.pop();
                break;
            }
        }
    }

    function manage(address to, address token, uint256 amount) external {
        onlyCoinMaster();
        notInLiquidation();
        IERC20(token).safeTransfer(to, amount);
    }

    //Deposit token and get back METFI for market price
    function deposit(address token, uint256 amount) external {
        onlyCoinMaster();
        notInLiquidation();

        IPriceCalculator tokenPriceCalculator = getPriceCalculator(token);
        IPriceCalculator metfiPriceCalculator = getPriceCalculator(address(getMETFI()));

        uint256 tokenValue = tokenPriceCalculator.priceForTokens(amount);
        uint256 metfiOut = metfiPriceCalculator.tokensForPrice(tokenValue);

        IERC20(token).safeTransferFrom(msg.sender, address(this), amount);

        getMETFIVault().withdrawMETFI(msg.sender, metfiOut);
    }

    //Buy back and send METFI to vault
    function buyBackMETFI(string memory buybackControllerName, address tokenAddress, uint256 tokenAmount, uint256 minMETFIOut) external {
        onlyCoinMaster();
        notInLiquidation();

        IMETFI metfi = getMETFI();
        IERC20 token = IERC20(tokenAddress);
        IBuybackController buybackController = contractRegistry.getBuybackController(buybackControllerName);

        uint256 initialMETFIBalance = metfi.balanceOf(address(this));

        token.safeTransfer(address(buybackController), tokenAmount);
        buybackController.buyBackMFI(tokenAddress, tokenAmount, minMETFIOut);

        require(metfi.balanceOf(address(this)) > (initialMETFIBalance + minMETFIOut), "Not enough METFI received");

        metfi.safeTransfer(address(getMETFIVault()), metfi.balanceOf(address(this)));

    }

    function startSystemLiquidation(address payable claimEthTo) external {
        onlyRealmGuardian();
        notInLiquidation();

        for (uint256 x = 0; x < lpTokens.length; x++) {

            ILiquidityController controller = contractRegistry.getLiquidityController(lpTokens[x].liquidityController);
            IERC20 lpToken = IERC20(controller.getLPTokenAddress(lpTokens[x].baseToken));

            uint256 lpTokenAmount = lpToken.balanceOf(address(this));
            uint256 tokensOut = controller.claimableTokensFromTreasuryLPTokens(lpTokens[x].baseToken);

            lpToken.safeTransfer(address(controller), lpTokenAmount);
            controller.removeLiquidity(lpTokens[x].baseToken, lpTokenAmount, tokensOut);
        }

        IMETFI metfi = getMETFI();

        getMETFIVault().withdrawMETFI(address(this), metfi.balanceOf(address(getMETFIVault())));
        getMETFIStakingPool().withdrawMETFI(address(this), metfi.balanceOf(address(getMETFIStakingPool())));

        if (metfi.balanceOf(address(this)) > 0) {
            metfi.burn(metfi.balanceOf(address(this)));
        }

        totalMETFIInLiquidation = getStakingManager().enterLiquidation();

        for (uint256 x = 0; x < reserveTokens.length; x++) {
            liquidationTokens.push(LiquidationTokenInfo(reserveTokens[x], IERC20(reserveTokens[x]).balanceOf(address(this))));
        }

        for (uint256 x = 0; x < liquidityTokens.length; x++) {
            liquidationTokens.push(LiquidationTokenInfo(liquidityTokens[x], IERC20(liquidityTokens[x]).balanceOf(address(this))));
        }

        liquidationBNBAmount = address(this).balance;

        inLiquidation = true;
        liquidationAddress = claimEthTo;
    }

    function claimLiquidationShare() external {

        require(inLiquidation, "not in liquidation");

        IAccountToken accountToken = getAccountToken();
        (uint256[] memory addressNFTs, uint256 numberOfActive) = accountToken.getAddressNFTs(msg.sender);

        for (uint256 x = 0; x < numberOfActive; x++) {
            _claimLiquidationShare(addressNFTs[x]);
        }

        if (accountToken.totalSupply() == 1) {

            //Only DAO token is left

            IDestroyableContract(contractRegistry.getContractAddress(ACCOUNT_TOKEN_HASH)).destroyContract(liquidationAddress);
            IDestroyableContract(contractRegistry.getContractAddress(STAKING_MANAGER_HASH)).destroyContract(liquidationAddress);

            if (address(this).balance > 0) {
                liquidationAddress.sendValue(address(this).balance);
            }
        }
    }

    function _claimLiquidationShare(uint256 nftId) internal {

        IAccountToken accountToken = getAccountToken();
        address payable owner = payable(accountToken.ownerOf(nftId));

        IStakingManagerV3 stakingManger = getStakingManager();
        uint256 userMETFI = stakingManger.getAccountTokens(nftId);

        for (uint256 x = 0; x < liquidationTokens.length; x++) {
            uint256 tokenAmount = liquidationTokens[x].totalAmount * userMETFI / totalMETFIInLiquidation;
            IERC20(liquidationTokens[x].token).safeTransfer(owner, tokenAmount);
        }

        if(liquidationBNBAmount > 0) {
            owner.sendValue(liquidationBNBAmount * userMETFI / totalMETFIInLiquidation);
        }

        getMETFI().safeTransfer(owner, userMETFI);

        accountToken.liquidateAccount(nftId);
    }

    function getLostTokens(address) public pure override {
        revert("disabled");
    }
}