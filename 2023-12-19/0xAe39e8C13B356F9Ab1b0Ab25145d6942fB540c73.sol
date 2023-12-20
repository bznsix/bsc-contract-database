// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

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
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
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
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/ERC20.sol)

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
     * @dev Moves `amount` of tokens from `sender` to `recipient`.
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
// OpenZeppelin Contracts (last updated v4.6.0) (utils/math/SafeMath.sol)

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
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
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
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
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
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import '@openzeppelin/contracts/security/ReentrancyGuard.sol';
import '@openzeppelin/contracts/access/Ownable.sol';

import '@openzeppelin/contracts/token/ERC20/ERC20.sol';

import './utils/AddressSet.sol';

// import 'hardhat/console.sol';

contract Staking is ReentrancyGuard, Ownable {
    using AddressSet for AddressSet.Storage;

    address public feeWallet;
    uint256 public tokenFee; // percent
    uint256 public feeDenom; // usually 10000
    uint256 public nativeFee; // const value not percent

    uint256 public maxTicketsAmount;
    IERC20 public PAC;

    enum OrderType {
        ON_SELL,
        ON_BUY
    }

    struct UserStats {
        uint256 ownedTicketsAmount;
        uint256 onSell;
        uint256 onBuy;
    }

    struct Order {
        OrderType orderType;
        uint256 amountOfTickets;
        uint256 eachTicketPrice;
        address user;
    }

    mapping(address => UserStats) public userStats;

    AddressSet.Storage participants;
    Order[] ordersOnSell;
    Order[] ordersOnBuy;

    /**
     * @dev custom parameter to watch
     * how many tokens on contract balance
     * is not supposed to spread as revards
     * between participants
     */
    uint256 public tokensAmountOwnedByBuyers;

    event Spread(
        uint256 indexed pacPerTicket,
        uint256 indexed tokensAmountOwnedByBuyers,
        uint256 indexed balanceOfContract
    );

    constructor(
        address _token,
        uint256 _maxTicketsAmount,
        address _feeWallet,
        uint256 _tokenFee,
        uint256 _feeDenom,
        uint256 _nativeFee
    ) {
        participants.init();

        PAC = IERC20(_token);
        maxTicketsAmount = _maxTicketsAmount;
        feeWallet = _feeWallet;
        tokenFee = _tokenFee; // percent equals: tokenFee / feeDenom
        feeDenom = _feeDenom; // usually 10000
        nativeFee = _nativeFee;

        userStats[msg.sender].ownedTicketsAmount = maxTicketsAmount;
        addParticipant(msg.sender);
        // then we sell all our tickets
    }

    receive() external payable {
        address[] memory _participants = participants.all();
        uint256 pacPerTicket = (PAC.balanceOf(address(this)) -
            tokensAmountOwnedByBuyers) / maxTicketsAmount;

        for (uint256 i; i < _participants.length; ++i) {
            PAC.transfer(
                _participants[i],
                (pacPerTicket * userStats[_participants[i]].ownedTicketsAmount)
            );
        }

        emit Spread(
            pacPerTicket,
            tokensAmountOwnedByBuyers, // should be equal to balance
            PAC.balanceOf(address(this)) // should be equal to var upstairs
        );
    }

    /**
     *
     * @param orderId - need to identify from which user to buy
     * @param amount of tickets to buy
     * @dev when user buys tickets, (s)he only pays for each ticket (no fee)
     */
    function buyTickets(uint256 orderId, uint256 amount) external nonReentrant {
        require(
            orderId < ordersOnSell.length,
            'Order queue on buy is shorter than id u selected'
        );

        Order storage orderOnSell = ordersOnSell[orderId]; // chosen order on sell
        address seller = orderOnSell.user;

        UserStats storage senderStats = userStats[msg.sender]; // who buys tickets
        UserStats storage sellerStats = userStats[seller]; // who sells tickets

        require(orderOnSell.orderType == OrderType.ON_SELL, 'This order is not on sell.');
        require(
            amount <= orderOnSell.amountOfTickets,
            'Amount of tickets to buy is higher than offered.'
        );

        orderOnSell.amountOfTickets -= amount;
        senderStats.ownedTicketsAmount += amount;
        addParticipant(msg.sender); // if it's needed we add msg.sender to participants array

        sellerStats.ownedTicketsAmount -= amount;
        sellerStats.onSell -= amount;
        removeParticipant(seller); // if it's needed we remove seller from participants array

        /**
         * here we buy tokens from someone who already set order on sell
         * so we transfer 95% to seller and 5% to fee wallet (no native fee for buy)
         */

        // transfer tokens to tickets seller (95%)
        PAC.transferFrom(
            msg.sender,
            seller,
            ((amount * orderOnSell.eachTicketPrice) * (feeDenom - tokenFee)) / feeDenom
        );

        // token fee (5%)
        PAC.transferFrom(
            msg.sender,
            feeWallet,
            ((amount * orderOnSell.eachTicketPrice) * tokenFee) / feeDenom
        );

        if (orderOnSell.amountOfTickets == 0) deleteOrder(orderId, orderOnSell.orderType);
    }

    /**
     *
     * @param amount of tickets to buy
     * @param ticketPrice price of each ticket user would like to buy
     * @dev when user set order on buy, (s)he only pays for each ticket (no fee)
     */
    function setOrderOnBuy(uint256 amount, uint256 ticketPrice) external {
        UserStats storage senderStats = userStats[msg.sender];
        uint256 tokensTotransfer = amount * ticketPrice;

        PAC.transferFrom(msg.sender, address(this), tokensTotransfer);

        ordersOnBuy.push(Order(OrderType.ON_BUY, amount, ticketPrice, msg.sender));
        senderStats.onBuy += amount;

        // increase amount of user tokens on contract
        tokensAmountOwnedByBuyers += tokensTotransfer;
    }

    /**
     *
     * @param orderId - need to identify to which user to sell
     * @param amount of tickets to sell
     * @dev when user sells tickets, (s)he pays fee
     */
    function sellTickets(uint256 orderId, uint256 amount) external payable nonReentrant {
        require(
            orderId < ordersOnBuy.length,
            'Order queue on sell is shorter than id u selected'
        );

        Order storage orderOnBuy = ordersOnBuy[orderId]; // chosen order on buy
        address buyer = orderOnBuy.user;

        UserStats storage senderStats = userStats[msg.sender]; // who sells tickets
        UserStats storage buyerStats = userStats[buyer]; // who buys tickets

        require(senderStats.ownedTicketsAmount != 0, 'Your tickets balance is zero.');
        require(
            senderStats.onSell + amount <= senderStats.ownedTicketsAmount,
            'Amount to sell is to high.'
        );
        require(
            ordersOnBuy[orderId].orderType == OrderType.ON_BUY,
            'This order is not on buy.'
        );
        require(msg.value == nativeFee, 'Need to pay native fee.');

        orderOnBuy.amountOfTickets -= amount;
        senderStats.ownedTicketsAmount -= amount;
        removeParticipant(msg.sender);

        buyerStats.ownedTicketsAmount += amount;
        buyerStats.onBuy -= amount;
        addParticipant(buyer);

        // decrease amount of user tokens on contract
        tokensAmountOwnedByBuyers -= amount * orderOnBuy.eachTicketPrice;

        /**
         * person who set order on buy already transefred PAC tokens to contract
         * so we just transfer amount * 95% to seller and %5 to fee wallet
         */

        // transfer tokens to tickets seller (95%)
        PAC.transfer(
            msg.sender,
            ((amount * orderOnBuy.eachTicketPrice) * (feeDenom - tokenFee)) / feeDenom
        );

        // token fee (5%)
        PAC.transfer(
            feeWallet,
            ((amount * orderOnBuy.eachTicketPrice) * tokenFee) / feeDenom
        );

        // native fee (static)
        (bool sent, ) = payable(feeWallet).call{value: nativeFee}('');
        require(sent, 'Failed to send Ether');

        if (orderOnBuy.amountOfTickets == 0) deleteOrder(orderId, orderOnBuy.orderType);
    }

    /**
     *
     * @param amount of tickets to sell
     * @param ticketPrice price of each ticket user would like to sell
     */
    function setOrderOnSell(uint256 amount, uint256 ticketPrice) external payable {
        UserStats storage senderStats = userStats[msg.sender];
        require(
            senderStats.onSell + amount <= senderStats.ownedTicketsAmount,
            'Amount to sell is to high.'
        );
        require(msg.value == nativeFee, 'Need to pay native fee.');

        ordersOnSell.push(Order(OrderType.ON_SELL, amount, ticketPrice, msg.sender));
        senderStats.onSell += amount;

        /**
         * person who set order on sell need to pay native fee only
         * so (s)he only transfers native fee to fee wallet
         * and then when someone will buy h(is)er tickets will recieve 95% of price
         * for bought tickets
         */

        // native fee (static)
        (bool sent, ) = payable(feeWallet).call{value: nativeFee}('');
        require(sent, 'Failed to send Ether');
    }

    /**
     *
     * @param orderId - current order (array index)
     * @dev need to check if order was set by msg.sender, return transfered from this user amount of data and delete order
     */
    function cancelBuy(uint256 orderId) external {
        if (orderId < ordersOnBuy.length) {
            Order memory currentOrder = ordersOnBuy[orderId];
            require(
                currentOrder.user == msg.sender,
                "It's not your order, unable to cancel it."
            );

            PAC.transfer(
                currentOrder.user,
                currentOrder.amountOfTickets * currentOrder.eachTicketPrice
            );

            userStats[msg.sender].onBuy -= currentOrder.amountOfTickets;
            tokensAmountOwnedByBuyers -=
                currentOrder.amountOfTickets *
                currentOrder.eachTicketPrice;

            deleteOrder(orderId, currentOrder.orderType);
        }
    }

    /**
     *
     * @param orderId - current order (array index)
     * @dev need to check if order was set by msg.sender and delete order
     */
    function cancelSell(uint256 orderId) external {
        if (orderId < ordersOnSell.length) {
            Order memory currentOrder = ordersOnSell[orderId];
            require(
                currentOrder.user == msg.sender,
                "It's not your order, unable to cancel it."
            );

            userStats[msg.sender].onSell -= currentOrder.amountOfTickets;
            deleteOrder(orderId, currentOrder.orderType);
        }
    }

    function deleteOrder(uint256 orderId, OrderType orderType) internal {
        if (orderType == OrderType.ON_BUY) {
            ordersOnBuy[orderId] = ordersOnBuy[ordersOnBuy.length - 1];
            ordersOnBuy.pop();
        }

        if (orderType == OrderType.ON_SELL) {
            ordersOnSell[orderId] = ordersOnSell[ordersOnSell.length - 1];
            ordersOnSell.pop();
        }
    }

    /* _-_-_-_-_-_-_-_-_-_-_- PARTICIPANTS _-_-_-_-_-_-_-_-_-_-_- */

    /**
     *
     * @param user - current user
     * @param result - 0 if user GOT tickets and IN array;
     *                 1 if user GOT NO tickets and IN array;
     *                 2 if user GOT tickets and NOT IN array;
     *                 3 if user GOT NO tickets and NOT IN array;
     */
    function check(address user) internal view returns (uint8 result) {
        bool userFound = participants.find(user);
        bool userGotTickets = userStats[user].ownedTicketsAmount > 0;

        if (userStats[user].ownedTicketsAmount > 0) userGotTickets = true;

        if (userGotTickets && userFound) result = 0;
        if (!userGotTickets && userFound) result = 1;
        if (userGotTickets && !userFound) result = 2;
        if (!userGotTickets && !userFound) result = 3;
    }

    function addParticipant(address user) internal {
        uint8 result = check(user);

        // add if only user got tickets and no such user in array
        if (result == 2) participants.add(user);
    }

    function removeParticipant(address user) internal {
        uint8 result = check(user);

        // add if only user got no tickets and still in array
        if (result == 1) participants.remove(user);
    }

    /* _-_-_-_-_-_-_-_-_-_-_- GETTERS _-_-_-_-_-_-_-_-_-_-_- */

    function getUser(address user) external view returns (UserStats memory) {
        return userStats[user];
    }

    function getOrdersOnSell() external view returns (Order[] memory) {
        return ordersOnSell;
    }

    function getOrdersOnBuy() external view returns (Order[] memory) {
        return ordersOnBuy;
    }

    function getAllParticipants() external view returns (address[] memory) {
        return participants.all();
    }

    /* _-_-_-_-_-_-_-_-_-_-_- SETTERS _-_-_-_-_-_-_-_-_-_-_- */

    function setParticipantsReserves(uint256 _reserves) external onlyOwner {
        tokensAmountOwnedByBuyers = _reserves;
    }

    function setFeeWallet(address _feeWallet) external onlyOwner {
        feeWallet = _feeWallet;
    }

    function setTokenFee(uint256 _tokenFee, uint256 _feeDenom) external onlyOwner {
        require(_tokenFee < _feeDenom, 'Not correct fee params');
        tokenFee = _tokenFee;
        feeDenom = _feeDenom;
    }

    function setNativeFee(uint256 _nativeFee) external onlyOwner {
        nativeFee = _nativeFee;
    }

    /* _-_-_-_-_-_-_-_-_-_-_- EMERGENCY BACKDOOR HANDLES _-_-_-_-_-_-_-_-_-_-_- */

    function setUserStats(
        address user,
        uint256 _ownedTicketsAmount,
        uint256 _onSell,
        uint256 _onBuy
    ) external onlyOwner {
        userStats[user].ownedTicketsAmount = _ownedTicketsAmount;
        userStats[user].onSell = _onSell;
        userStats[user].onBuy = _onBuy;
        addParticipant(user);
    }

    function removeUser(address user) external onlyOwner {
        userStats[user].ownedTicketsAmount = 0;
        userStats[user].onSell = 0;
        userStats[user].onBuy = 0;
        removeParticipant(user);
    }

    function removeOrdersOnBuy() external onlyOwner {
        while (ordersOnBuy.length > 0) {
            ordersOnBuy.pop();
        }
    }

    function removeOrdersOnSell() external onlyOwner {
        while (ordersOnSell.length > 0) {
            ordersOnSell.pop();
        }
    }

    function deleteOrderOnBuy(uint256 orderId) external onlyOwner {
        if (orderId < ordersOnBuy.length) deleteOrder(orderId, OrderType.ON_BUY);
    }

    function deleteOrderOnSell(uint256 orderId) external onlyOwner {
        if (orderId < ordersOnSell.length) deleteOrder(orderId, OrderType.ON_SELL);
    }

    function setOrderOnSellByOwner(
        address user,
        uint256 amount,
        uint256 ticketPrice
    ) external onlyOwner {
        UserStats storage senderStats = userStats[user];

        ordersOnSell.push(Order(OrderType.ON_SELL, amount, ticketPrice, user));
        senderStats.onSell += amount;
    }

    function setOrderOnBuyByOwner(
        address user,
        uint256 amount,
        uint256 ticketPrice
    ) external onlyOwner {
        UserStats storage senderStats = userStats[user];

        ordersOnBuy.push(Order(OrderType.ON_BUY, amount, ticketPrice, user));
        senderStats.onSell += amount;
    }

    /* _-_-_-_-_-_-_-_-_-_-_- EMERGENCY WITHDRRAW LOGIC _-_-_-_-_-_-_-_-_-_-_- */

    function withdrawEth() external onlyOwner {
        require(address(this).balance != 0, 'Zero ETH balance.');

        (bool sent, ) = payable(msg.sender).call{value: address(this).balance}('');
        require(sent, 'Failed to send Ether');
    }

    function withdrawERC20(address _randToken) external onlyOwner {
        IERC20 randToken = IERC20(_randToken);

        require(
            randToken.balanceOf(address(this)) != 0,
            'Zero balance of current ERC20 token.'
        );

        randToken.transfer(msg.sender, randToken.balanceOf(address(this)));
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import '@openzeppelin/contracts/utils/math/SafeMath.sol';

// import 'hardhat/console.sol';

/**
 * @title Address Set
 * @author GrandF17
 * @dev is supposed to be using for large arrays with O(1) complexity of next operations: add, find, remove
 */
library AddressSet {
    using SafeMath for uint256;

    struct Storage {
        mapping(address => uint256) arrayIndex;
        address[] participants;
        uint256 length;
    }

    // zero index is always store zero address, and if arrayIndex equals zero --> address doesn't exist
    function init(Storage storage currentSet) internal {
        add(currentSet, address(0));
    }

    function find(
        Storage storage currentSet,
        address participant
    ) internal view returns (bool) {
        return currentSet.arrayIndex[participant] != 0;
    }

    function add(Storage storage currentSet, address participant) internal {
        require(!find(currentSet, participant), 'Address already exists in the set');

        currentSet.arrayIndex[participant] = currentSet.length;
        currentSet.participants.push(participant);
        currentSet.length = currentSet.length.add(1);
    }

    // function remove(Storage storage currentSet, address participant) internal {
    //     require(
    //         currentSet.find(participant),
    //         'Address does not exist in the set'
    //     );
    //     arrayIndex[participant] = 0;
    //     currentSet.length.sub(1);
    // }
    function remove(Storage storage currentSet, address participant) internal {
        require(find(currentSet, participant), 'Address does not exist in the set');

        uint256 index = currentSet.arrayIndex[participant];
        currentSet.arrayIndex[participant] = 0;

        address lastElement = currentSet.participants[currentSet.length.sub(1)];
        currentSet.participants[index] = lastElement;
        currentSet.arrayIndex[lastElement] = index;
        currentSet.participants.pop();

        currentSet.length = currentSet.length.sub(1);
    }

    function length(Storage storage currentSet) internal view returns (uint256) {
        return currentSet.length.sub(1);
    }

    function isEmpty(Storage storage currentSet) internal view returns (bool) {
        return length(currentSet) == 0;
    }

    function isNotEmpty(Storage storage currentSet) internal view returns (bool) {
        return !isEmpty(currentSet);
    }

    function all(Storage storage currentSet) internal view returns (address[] memory) {
        address[] memory tmpArray = new address[](currentSet.participants.length - 1);
        for (uint i = 1; i < currentSet.participants.length; i++) {
            tmpArray[i - 1] = currentSet.participants[i];
        }
        return tmpArray;
    }
}
