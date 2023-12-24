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
pragma solidity 0.8.23;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/Math.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";

import "./interfaces/IUniswapV2Factory.sol";
import "./interfaces/IUniswapV2Pair.sol";
import "./interfaces/IUniswapV2Router.sol";
import "./interfaces/IWETH.sol";

/// @dev It saves in an ordered array the holders and the current
/// tickets count.
/// For calculating the winners, from the huge random number generated
/// a normalized random is generated by using the module method, adding 1 to have
/// a random from 1 to tickets.
/// So next step is to perform a binary search on the ordered array to get the
/// player O(log n)
/// Example:
// / 0 -> { 1, player1} as player1 has 1 ticket
// / 1 -> {51, player2} as player2 buys 50 ticket
// / 2 -> {52, player3} as player3 buys 1 ticket
// / 3 -> {53, player4} as player4 buys 1 ticket
// / 4 -> {153, player5} as player5 buys 100 ticket
/// So the setWinner method performs a binary search on that sorted array to get the upper bound.
/// If the random number generated is 150, the winner is player5. If the random number is 20, winner is player2

contract WINMOON is ERC20, ERC20Burnable, Ownable {
	struct EpochData {
		uint256 epoch;
		uint256 totalPlayers;
		uint256 totalWinners;
		uint256 totalEntries;
	}

	mapping(uint256 => EpochData) public epochs;
	// EpochData[] epochs;

	address[] private _allOwners;
	mapping(address owner => uint256) private _allOwnersIndex;

	address[] private _allSuperBoosts;
	mapping(address booster => uint256 index) private _allSuperBoostsIndex;

	// In order to calculate the winner, in this struct is saved for each bought the data
	struct EntriesData {
		uint256 currentEntriesLength; // current amount of entries bought
		address player; // wallet address of the player
	}
	// every epoch has a sorted array of EntriesData.

	struct PlayersData {
		address player; // wallet address of the player
		uint256 totalWins; // how many times has won
	}

	mapping(uint256 => EntriesData[]) public entriesList;

	// mapping epoch to entries
	mapping(uint256 => uint256) public totalEntries;

	mapping(uint256 => mapping(address => uint256)) public playerEntryIndex;

	// Percentage boost for each wallet.  100 = 100% = no boost
	mapping(address => uint256) public walletBoosts;

	// Mapping of epoch -> player -> boost
	mapping(uint256 _epoch => mapping(address _player => uint256 _boost))
		public epochBoosts; // 100 = 100% = no boost

	/// @dev Mapping of epochs to winners
	mapping(uint256 => address[]) public winners;

	/// @dev Mapping of epochs to winners
	mapping(uint256 => mapping(address => uint256)) public winnersIndex;

	// store addresses that a automatic market maker pairs. Any transfer from these addresses
	// should always be allowed
	mapping(address => bool) public automatedMarketMakerPairs;

	// uint256 public totalHolders = 0;
	uint256 public epoch = 0;
	uint256 public lastRollover;
	uint256 public immutable epochDuration = 86400;

	IUniswapV2Router02 public uniswapV2Router;
	address public uniswapV2Pair;
	address public WETH;

	address payable public feeReceiver;

	uint256 private constant BUY_DAILY_BOOST = 300;
	uint256 private constant BUY_BOOST_MIN_BUY = 0.1 ether;
	uint256 private constant LOGIN_DAILY_BOOST = 200;
	uint256 private constant SUPER_BOOST = 300;
	uint256 private constant SUPER_BOOST_COST = 1 ether;

	function totalHolders() public view virtual returns (uint256) {
		return _allOwners.length;
	}

	// exclude from all restrictions
	mapping(address => bool) private _excludeFromRestrictions;

	event SetAutomatedMarketMakerPair(address indexed pair, bool indexed value);
	event ExcludeFromRestrictions(address indexed account, bool isExcluded);

	event BoughtSuperBoost(address indexed player, uint epoch);
	event BoughtWinMoon(
		address indexed player,
		uint epoch,
		uint bnbAmount,
		uint winmoonAmount
	);
	event NewWinner(uint indexed epoch, address winner);
	event PairInitialized(address router, address pair);
	event EthWithdraw(uint256 amount);
	event NewFeeReceiver(address payable account);

	constructor(
		address initialOwner,
		IUniswapV2Router02 _router,
		address payable _feeReceiver
	) ERC20("WINMOON.XYZ", "WINMOON") Ownable() {
		feeReceiver = _feeReceiver;
		_mint(initialOwner, 777777777 * 10 ** decimals());
		_transferOwnership(initialOwner);
		if (address(_router) != address(0)) {
			initializePair(_router, true);
		}
		_excludeFromRestrictions[address(this)] = true;
		_excludeFromRestrictions[initialOwner] = true;
	}

	function holder(uint256 index) external view returns (address) {
		return _allOwners[index];
	}

	// TODO test this
	function initializePair(
		IUniswapV2Router02 _uniswapV2Router,
		bool createPair
	) public onlyOwner {
		uniswapV2Router = _uniswapV2Router;

		if (createPair) {
			uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory())
				.createPair(address(this), uniswapV2Router.WETH());
		} else {
			uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory())
				.getPair(address(this), uniswapV2Router.WETH());
		}

		require(
			address(uniswapV2Router) != address(0) &&
				uniswapV2Pair != address(0),
			"Router and pair not set correctly"
		);
		_setAutomatedMarketMakerPair(uniswapV2Pair, true);
		WETH = uniswapV2Router.WETH();

		_approveTokenIfNeeded(WETH, address(uniswapV2Router));

		emit PairInitialized(address(uniswapV2Router), address(uniswapV2Pair));
	}

	function start(uint256 _startTime) external onlyOwner {
		require(epoch == 0);
		require(
			uniswapV2Pair != address(0) &&
				address(uniswapV2Router) != address(0),
			"Router and pair must be initialized"
		);

		lastRollover = _startTime;
		_calculateEntries();
	}

	function rollover() public {
		require(lastRollover > 0, "Cannot rollover before start");
		require(
			block.timestamp >= lastRollover + epochDuration,
			"Too soon, too soon"
		);
		epoch++;

		_calculateEntries();

		for (uint i = 0; i < numberOfWinners(); i++) {
			address thisWinner = getWinnerAddressFromRandom(
				epoch + epochDuration + numberOfWinners() + i //some nonsense numbers to feed the generator
			);
			winners[epoch].push(thisWinner);
			winnersIndex[epoch][thisWinner] = winners[epoch].length;
			emit NewWinner(epoch, thisWinner);
		}

		epochs[epoch] = EpochData({
			epoch: epoch,
			totalPlayers: totalPlayersFromEpoch(epoch),
			totalEntries: totalEntries[epoch],
			totalWinners: numberOfWinnersFromEpoch(epoch)
		});

		lastRollover += epochDuration;
	}

	/*  VIEWS  */

	function numberOfWinners() public view returns (uint256) {
		if (currentTotalPlayers() <= 100) {
			return 1;
		}

		return (currentTotalPlayers() / 100) + 1;
	}

	function oddsOfGettingDrawn(
		address account
	) external view returns (uint256) {
		uint256 playerEntriesPercent = currentPlayersEntries(account) * 100000;
		return playerEntriesPercent / currentTotalEntries();
	}

	function currentTotalEntries() internal view returns (uint256) {
		return totalEntries[epoch];
	}

	function currentTotalPlayers() internal view returns (uint256) {
		return entriesList[epoch].length;
	}

	function totalPlayersFromEpoch(
		uint256 _epoch
	) internal view returns (uint256) {
		return entriesList[_epoch].length;
	}

	function currentWinners() public view returns (address[] memory _winners) {
		uint i = 0;
		_winners = new address[](winners[epoch].length);
		while (winners[epoch].length > i) {
			_winners[i] = winners[epoch][i];
			i++;
		}
	}

	function numberOfWinnersFromEpoch(
		uint256 _epoch
	) internal view returns (uint256 _totalWinners) {
		_totalWinners = winners[_epoch].length;
	}

	function checkWinner(address player) public view returns (bool) {
		address[] memory currentWinningPlayers = currentWinners();
		uint i = 0;
		while (currentWinningPlayers.length > i) {
			if (player == currentWinningPlayers[i]) {
				return true;
			}
			i++;
		}
		return false;
	}

	function playerEntriesByEpoch(
		address account,
		uint256 _epoch
	) external view returns (uint256) {
		uint256 playerIndex = playerEntryIndex[_epoch][account];
		if (playerIndex > 0) {
			return
				entriesList[_epoch][playerIndex].currentEntriesLength -
				entriesList[_epoch][playerIndex - 1].currentEntriesLength;
		} else {
			return entriesList[_epoch][playerIndex].currentEntriesLength;
		}
	}

	function currentPlayersEntries(
		address account
	) public view returns (uint256) {
		uint256 numEntries = (walletBoosts[account] * 100) / 100;
		if (epochBoosts[epoch + 1][account] > 100) {
			numEntries = (numEntries * epochBoosts[epoch + 1][account]) / 100;
		}
		return numEntries;
	}

	function shouldRollover() internal view returns (bool) {
		if (lastRollover == 0 || epoch == 0) {
			return false;
		}
		return block.timestamp >= (lastRollover + epochDuration);
	}

	// Calculate the entries for the current epoch

	function _calculateEntries() internal {
		totalEntries[epoch] = 0;
		for (uint256 i = 0; i < _allOwners.length; i++) {
			address player = _allOwners[i];
			if (automatedMarketMakerPairs[player]) {
				continue;
			}

			uint256 numEntries = (walletBoosts[player] * 100) / 100;
			if (epochBoosts[epoch][player] > 100) {
				numEntries = (numEntries * epochBoosts[epoch][player]) / 100;
			}
			EntriesData memory entryBought = EntriesData({
				player: player,
				currentEntriesLength: uint256(totalEntries[epoch] + numEntries)
			});

			entriesList[epoch].push(entryBought);
			playerEntryIndex[epoch][player] = entriesList[epoch].length - 1;
			// update raffle variables
			totalEntries[epoch] = totalEntries[epoch] + numEntries;
		}
	}

	// helper method to get the winner address of a raffle
	/// @return the wallet that won the raffle
	/// @dev Uses a binary search on the sorted array to retreive the winner
	function getWinnerAddressFromRandom(
		uint nonce
	) public view returns (address) {
		if (epoch == 0 || entriesList[epoch].length == 0) {
			return address(0);
		}

		uint256 normalizedRandomNumber = (generateRandomNumber(nonce) %
			currentTotalEntries());
		uint256 position = findUpperBound(
			entriesList[epoch],
			normalizedRandomNumber
		);

		address candidate = entriesList[epoch][position].player;
		// general case
		if (candidate != address(0)) return candidate;
		else {
			bool ended = false;
			uint256 i = position;
			while (
				ended == false && entriesList[epoch][i].player == address(0)
			) {
				if (i == 0) i = entriesList[epoch].length - 1;
				else i = i - 1;
				if (i == position) ended == true;
			}
			return entriesList[epoch][i].player;
		}
	}

	function generateRandomNumber(
		uint randNonce
	) internal view returns (uint256) {
		uint256 blockNumber = block.number - 1; // Use the previous block's hash
		bytes32 lastBlockHash = blockhash(blockNumber);
		return
			uint256(
				keccak256(
					abi.encodePacked(
						_msgSender(),
						lastBlockHash,
						block.timestamp + randNonce
					)
				)
			);
	}

	/// @param array sorted array of EntriesBought. CurrentEntriesLength is the numeric field used to sort
	/// @param element uint256 to find. Goes from 1 to entriesLength
	/// @dev based on openzeppelin code (v4.0), modified to use an array of EntriesBought
	/// Searches a sorted array and returns the first index that contains a value greater or equal to element.
	/// If no such index exists (i.e. all values in the array are strictly less than element), the array length is returned. Time complexity O(log n).
	/// array is expected to be sorted in ascending order, and to contain no repeated elements.
	/// https://docs.openzeppelin.com/contracts/3.x/api/utils#Arrays-findUpperBound-uint256---uint256-
	function findUpperBound(
		EntriesData[] storage array,
		uint256 element
	) internal view returns (uint256) {
		if (array.length == 0) {
			return 0;
		}

		uint256 low = 0;
		uint256 high = array.length;

		while (low < high) {
			uint256 mid = Math.average(low, high);

			// Note that mid will always be strictly less than high (i.e. it will be a valid array index)
			// because Math.average rounds down (it does integer division with truncation).
			if (array[mid].currentEntriesLength > element) {
				high = mid;
			} else {
				low = mid + 1;
			}
		}

		// At this point `low` is the exclusive upper bound. We will return the inclusive upper bound.
		if (low > 0 && array[low - 1].currentEntriesLength == element) {
			return low - 1;
		} else {
			return low;
		}
	}

	// function _afterTokenTransfer(
	// 	address from,
	// 	address to,
	// 	uint256 amount
	// ) internal virtual override {
	// 	super._afterTokenTransfer(from, to, amount);

	// 	// Check after transfer if rollover should occur
	// }

	function _beforeTokenTransfer(
		address from,
		address to,
		uint256 amount
	) internal virtual override {
		super._beforeTokenTransfer(from, to, amount);

		if (shouldRollover()) {
			rollover();
		}

		// Transfer is disabled by default.  Following functions will potentially enable it
		bool transferAllowed = false;

		// Allow initial mint and future burns
		if (from == address(0) || to == address(0)) {
			transferAllowed = true;
		}

		// Epoch 0, transfers are allowed
		if (epoch == 0) {
			transferAllowed = true;
		}

		// if any account belongs to _isExcludedFromRestictions account then allow
		if (_excludeFromRestrictions[from] || _excludeFromRestrictions[to]) {
			transferAllowed = true;
		}

		// This is a buy
		if (automatedMarketMakerPairs[from]) {
			transferAllowed = true;
		}

		// IF is a winner!
		// All transfers are allowed from a winner, including sells
		if (checkWinner(from)) {
			transferAllowed = true;
		}

		require(
			transferAllowed,
			"This transfer is not allowed. Only winners can transfer"
		);

		// Remove owner from list of owners
		if (from != address(0) && balanceOf(from) == amount) {
			_removeOwnerFromAllOwnersEnumeration(from);
		}

		// Add owner to list of owners and adjust wallet boost
		if (to != address(0) && balanceOf(to) == 0) {
			_addOwnerToAllTokensEnumeration(to);
			if (walletBoosts[to] == 0) {
				walletBoosts[to] = 100;
			}
		}
	}

	/* **************
	BUY BOOSTS
	************** */

	function addLoginDailyBoost(address player) internal {
		if (epochBoosts[epoch + 1][player] == BUY_DAILY_BOOST) {
			epochBoosts[epoch + 1][player] =
				BUY_DAILY_BOOST +
				LOGIN_DAILY_BOOST;
		} else {
			epochBoosts[epoch + 1][player] = LOGIN_DAILY_BOOST;
		}
	}

	function addBuyDailyBoost(address player) internal {
		if (epochBoosts[epoch + 1][player] == LOGIN_DAILY_BOOST) {
			epochBoosts[epoch + 1][player] =
				BUY_DAILY_BOOST +
				LOGIN_DAILY_BOOST;
		} else {
			epochBoosts[epoch + 1][player] = BUY_DAILY_BOOST;
		}
	}

	function addBothDailyBoost(address player) internal {
		epochBoosts[epoch + 1][player] = BUY_DAILY_BOOST + LOGIN_DAILY_BOOST;
	}

	function addSuperBoost(address player) internal {
		walletBoosts[player] = SUPER_BOOST;
	}

	function buySuperBoost() external payable {
		require(msg.value >= SUPER_BOOST_COST, "Not enough Ether/BNB Sent");
		addSuperBoost(_msgSender());
		(bool sent, ) = feeReceiver.call{ value: msg.value }("");
		require(sent, "Failed to send ETH");
		emit BoughtSuperBoost(_msgSender(), epoch);
	}

	function dailyLoginBoost() external {
		addLoginDailyBoost(_msgSender());
	}

	/* **************
	SWAP and Estimates
	************** */

	function buyWithETH(uint256 amountMinimum) external payable returns (bool) {
		require(msg.value >= 1000, "Insignificant input amount");

		IWETH(WETH).deposit{ value: msg.value }();
		uint256 _wethBalance = IERC20(WETH).balanceOf(address(this));
		uint256 _beforeBalance = IERC20(address(this)).balanceOf(_msgSender());
		_swap(
			address(this),
			amountMinimum == 0
				? (estimateSwap(_wethBalance) * 97) / 100
				: amountMinimum,
			WETH,
			_wethBalance,
			_msgSender()
		);
		uint256 boughtAmount = IERC20(address(this)).balanceOf(_msgSender()) -
			_beforeBalance;
		if (msg.value >= BUY_BOOST_MIN_BUY) {
			addBothDailyBoost(_msgSender());
		} else {
			addLoginDailyBoost(_msgSender());
		}

		emit BoughtWinMoon(_msgSender(), epoch, msg.value, boughtAmount);
		return true;
	}

	function estimateSwap(
		uint256 fullInvestmentIn
	) public view returns (uint256 swapAmountOut) {
		IUniswapV2Pair pair = IUniswapV2Pair(uniswapV2Pair);
		bool isInputA = pair.token0() == WETH;
		require(
			isInputA || pair.token1() == WETH,
			"Input token not present in liqudity pair"
		);

		(uint256 reserveA, uint256 reserveB, ) = pair.getReserves();
		(reserveA, reserveB) = isInputA
			? (reserveA, reserveB)
			: (reserveB, reserveA);

		swapAmountOut = uniswapV2Router.getAmountOut(
			fullInvestmentIn,
			reserveA,
			reserveB
		);
	}

	function _swap(
		address tokenOut,
		uint256 tokenAmountOutMin,
		address tokenIn,
		uint256 tokenInAmount,
		address _to
	) internal {
		uint256 wethAmount;

		if (tokenIn == WETH) {
			wethAmount = tokenInAmount;
		} else {
			IUniswapV2Pair pair = IUniswapV2Pair(uniswapV2Pair);
			bool isInputA = pair.token0() == tokenIn;
			require(
				isInputA || pair.token1() == tokenIn,
				"Input token not present in input pair"
			);
			address[] memory path;

			path = new address[](2);
			path[0] = tokenIn;
			path[1] = WETH;
			uniswapV2Router
				.swapExactTokensForTokensSupportingFeeOnTransferTokens(
					tokenInAmount,
					tokenAmountOutMin,
					path,
					_to,
					block.timestamp
				);
			wethAmount = IERC20(WETH).balanceOf(address(this));
		}

		if (tokenOut != WETH) {
			address[] memory basePath;

			basePath = new address[](2);
			basePath[0] = WETH;
			basePath[1] = tokenOut;

			uniswapV2Router
				.swapExactTokensForTokensSupportingFeeOnTransferTokens(
					wethAmount,
					tokenAmountOutMin,
					basePath,
					_to,
					block.timestamp
				);
		}
	}

	function withdraw() external onlyOwner {
		uint256 amount = address(this).balance;
		require(amount > 0, "Nothing to withdraw; contract balance empty");

		address _owner = owner();
		(bool sent, ) = _owner.call{ value: amount }("");
		require(sent, "Failed to send Ether");
		emit EthWithdraw(amount);
	}

	/* ******************
	Admin / internal functions
	****************** */

	function isExcludeFromRestrictions(
		address account
	) external view returns (bool) {
		return _excludeFromRestrictions[account];
	}

	function excludeFromRestrictions(
		address account,
		bool excluded
	) external onlyOwner {
		require(
			_excludeFromRestrictions[account] != excluded,
			"Account is already the value of 'excluded'"
		);
		_excludeFromRestrictions[account] = excluded;

		emit ExcludeFromRestrictions(account, excluded);
	}

	function setFeeReceiver(address payable account) external onlyOwner {
		require(
			account != address(0),
			"Cannot set fee receiver to zero address"
		);
		feeReceiver = account;
		emit NewFeeReceiver(account);
	}

	function setAutomatedMarketMakerPair(
		address pair,
		bool value
	) external onlyOwner {
		_setAutomatedMarketMakerPair(pair, value);
	}

	function _setAutomatedMarketMakerPair(address pair, bool value) private {
		require(
			automatedMarketMakerPairs[pair] != value,
			"Automated market maker pair is already set to that value"
		);
		automatedMarketMakerPairs[pair] = value;

		emit SetAutomatedMarketMakerPair(pair, value);
	}

	function _addOwnerToAllTokensEnumeration(address account) private {
		_allOwnersIndex[account] = _allOwners.length;
		_allOwners.push(account);
	}

	function _removeOwnerFromAllOwnersEnumeration(address account) private {
		// To prevent a gap in the tokens array, we store the last token in the index of the token to delete, and
		// then delete the last slot (swap and pop).

		uint256 lastOwnerIndex = _allOwners.length - 1;
		uint256 ownerIndex = _allOwnersIndex[account];

		// When the token to delete is the last token, the swap operation is unnecessary. However, since this occurs so
		// rarely (when the last minted token is burnt) that we still do the swap here to avoid the gas cost of adding
		// an 'if' statement (like in _removeTokenFromOwnerEnumeration)
		address lastOwner = _allOwners[lastOwnerIndex];

		_allOwners[ownerIndex] = lastOwner; // Move the last token to the slot of the to-delete token
		_allOwnersIndex[lastOwner] = ownerIndex; // Update the moved token's index

		// This also deletes the contents at the last position of the array
		delete _allOwnersIndex[account];
		_allOwners.pop();
	}

	function _approveTokenIfNeeded(address token, address spender) private {
		if (IERC20(token).allowance(address(this), spender) == 0) {
			IERC20(token).approve(spender, type(uint256).max);
		}
	}

	receive() external payable {}
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IUniswapV2Factory {
	event PairCreated(
		address indexed token0,
		address indexed token1,
		address pair,
		uint256
	);

	function feeTo() external view returns (address);

	function feeToSetter() external view returns (address);

	function getPair(
		address tokenA,
		address tokenB
	) external view returns (address pair);

	function allPairs(uint256) external view returns (address pair);

	function allPairsLength() external view returns (uint256);

	function createPair(
		address tokenA,
		address tokenB
	) external returns (address pair);

	function setFeeTo(address) external;

	function setFeeToSetter(address) external;
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IUniswapV2Pair {
	event Approval(address indexed owner, address indexed spender, uint value);
	event Transfer(address indexed from, address indexed to, uint value);

	function name() external pure returns (string memory);

	function symbol() external pure returns (string memory);

	function decimals() external pure returns (uint8);

	function totalSupply() external view returns (uint);

	function balanceOf(address owner) external view returns (uint);

	function allowance(
		address owner,
		address spender
	) external view returns (uint);

	function approve(address spender, uint value) external returns (bool);

	function transfer(address to, uint value) external returns (bool);

	function transferFrom(
		address from,
		address to,
		uint value
	) external returns (bool);

	function DOMAIN_SEPARATOR() external view returns (bytes32);

	function PERMIT_TYPEHASH() external pure returns (bytes32);

	function nonces(address owner) external view returns (uint);

	function permit(
		address owner,
		address spender,
		uint value,
		uint deadline,
		uint8 v,
		bytes32 r,
		bytes32 s
	) external;

	event Mint(address indexed sender, uint amount0, uint amount1);
	event Burn(
		address indexed sender,
		uint amount0,
		uint amount1,
		address indexed to
	);
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

	function getReserves()
		external
		view
		returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);

	function price0CumulativeLast() external view returns (uint);

	function price1CumulativeLast() external view returns (uint);

	function kLast() external view returns (uint);

	function mint(address to) external returns (uint liquidity);

	function burn(address to) external returns (uint amount0, uint amount1);

	function swap(
		uint amount0Out,
		uint amount1Out,
		address to,
		bytes calldata data
	) external;

	function skim(address to) external;

	function sync() external;

	function initialize(address, address) external;
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IUniswapV2Router01 {
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

// pragma solidity >=0.6.2;

interface IUniswapV2Router02 is IUniswapV2Router01 {
	function removeLiquidityETHSupportingFeeOnTransferTokens(
		address token,
		uint256 liquidity,
		uint256 amountTokenMin,
		uint256 amountETHMin,
		address to,
		uint256 deadline
	) external returns (uint256 amountETH);

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

	function swapExactTokensForTokensSupportingFeeOnTransferTokens(
		uint256 amountIn,
		uint256 amountOutMin,
		address[] calldata path,
		address to,
		uint256 deadline
	) external;

	function swapExactETHForTokensSupportingFeeOnTransferTokens(
		uint256 amountOutMin,
		address[] calldata path,
		address to,
		uint256 deadline
	) external payable;

	function swapExactTokensForETHSupportingFeeOnTransferTokens(
		uint256 amountIn,
		uint256 amountOutMin,
		address[] calldata path,
		address to,
		uint256 deadline
	) external;
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IWETH is IERC20 {
	function deposit() external payable;

	function withdraw(uint256 wad) external;
}
