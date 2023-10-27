/**
 *Submitted for verification at BscScan.com on 2023-10-12
*/

/**
 *Submitted for verification at BscScan.com on 2023-09-20
*/

/**
 *Submitted for verification at BscScan.com on 2023-08-29
 */

/**
 *Submitted for verification at BscScan.com on 2023-08-16
 */

// SPDX-License-Identifier: MIT

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

// File @openzeppelin/contracts/access/Ownable.sol@v4.8.2

// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

pragma solidity ^0.8.0;

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

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

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
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
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

// File @openzeppelin/contracts/token/ERC20/IERC20.sol@v4.8.2

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
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

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
    function allowance(
        address owner,
        address spender
    ) external view returns (uint256);

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

// File @openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol@v4.8.2

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

// File @openzeppelin/contracts/token/ERC20/ERC20.sol@v4.8.2

// OpenZeppelin Contracts (last updated v4.8.0) (token/ERC20/ERC20.sol)

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

    uint256 internal _totalSupply;

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
    function balanceOf(
        address account
    ) public view virtual override returns (uint256) {
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
    function transfer(
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(
        address owner,
        address spender
    ) public view virtual override returns (uint256) {
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
    function approve(
        address spender,
        uint256 amount
    ) public virtual override returns (bool) {
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
    function increaseAllowance(
        address spender,
        uint256 addedValue
    ) public virtual returns (bool) {
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
    function decreaseAllowance(
        address spender,
        uint256 subtractedValue
    ) public virtual returns (bool) {
        address owner = _msgSender();
        uint256 currentAllowance = allowance(owner, spender);
        require(
            currentAllowance >= subtractedValue,
            "ERC20: decreased allowance below zero"
        );
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
        require(
            fromBalance >= amount,
            "ERC20: transfer amount exceeds balance"
        );
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
            require(
                currentAllowance >= amount,
                "ERC20: insufficient allowance"
            );
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

// File @openzeppelin/contracts/security/ReentrancyGuard.sol@v4.8.2

// OpenZeppelin Contracts (last updated v4.8.0) (security/ReentrancyGuard.sol)

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
}

// File contracts/interface/IUniswapFactory.sol

pragma solidity >=0.5.0;

interface IUniswapFactory {
    function createPair(
        address tokenA,
        address tokenB
    ) external returns (address pair);
}

// File contracts/interface/IUniswapPair.sol

pragma solidity >=0.5.0;

interface IUniswapPair {
    function totalSupply() external view returns (uint256);

    function balanceOf(address owner) external view returns (uint256);

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);

    function factory() external view returns (address);

    function token0() external view returns (address);

    function token1() external view returns (address);

    function getReserves()
        external
        view
        returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
}

pragma solidity ^0.8.0;

interface IUniswapV2Router01 {
    function factory() external pure returns (address);
}

pragma solidity ^0.8.0;

interface IUniswapV2Router02 is IUniswapV2Router01 {
    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
}

// File contracts/math/SafeMath.sol

pragma solidity >=0.4.0;

/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */
library SafeMath {
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
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
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
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
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
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
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
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts on
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
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
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
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts when dividing by zero.
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
        return mod(a, b, "SafeMath: modulo by zero");
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts with custom message when dividing by zero.
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
        require(b != 0, errorMessage);
        return a % b;
    }

    function min(uint256 x, uint256 y) internal pure returns (uint256 z) {
        z = x < y ? x : y;
    }

    // babylonian method (https://en.wikipedia.org/wiki/Methods_of_computing_square_roots#Babylonian_method)
    function sqrt(uint256 y) internal pure returns (uint256 z) {
        if (y > 3) {
            z = y;
            uint256 x = y / 2 + 1;
            while (x < z) {
                z = x;
                x = (y / x + x) / 2;
            }
        } else if (y != 0) {
            z = 1;
        }
    }
}

pragma solidity 0.8.19;

contract AiBabyDoge is ERC20, ReentrancyGuard, Ownable {
    using SafeMath for uint256;
    uint256 public constant MAX_MINT = 10 ** 26;
    uint256 public constant DEL_TIME = 30 days ;
    uint256 public constant MINT_RATIO_THIRTY = 5000;
    uint256 public constant MINT_RATIO_SIXTY = 2500;
    uint256 public constant MINT_RATIO_NINETY = 1250;
    uint256 public constant MINT_RATIO_OTHER = 625;
    uint256 public constant BURN_RATIO = 3;
    uint256 public constant BLOCK_AMOUNT_OF_DAY = 28800;
    address private constant DESTROY = 0x000000000000000000000000000000000000dEaD;
    IUniswapV2Router02 public immutable uniswapV2Router;
    IUniswapPair public immutable uniswapV2PairUSDT;
    address public usdt = address(0x55d398326f99059fF775485246999027B3197955);
    uint256 public buyToUsdtFee = 20;
    uint256 public burnFee= 10;
    uint256 public sellToUsdtFee = 20;
    mapping(address => bool) public ammPairs;
    mapping(address => bool) public isParter;
    mapping(address => uint256) public userTimeOfBurn;
    bool private swapping;
    address public lastAddress = address(0);
    mapping(address => bool) public lpPush;
    mapping(address => uint256) private lpIndex;

    mapping(address => uint256) public userTimeOfMint;
    uint256 public totalMint;
    mapping(address => bool) public whiteList;
    mapping(address => address) public toFather;
    mapping(address => uint256) public sonToFather;
    mapping(address => address[]) public sonAddress;
    mapping(address => uint256) public haveLpAmount;
    mapping(address => bool) public isExcludedFromFeesVip;
    bool public flags;
    mapping(address => uint256) public addLiqudityInfo;
    address[] public lpUser;

    address[] public _exAddress;
    mapping(address => bool) private _bexAddress;
    mapping(address => uint256) private _exIndex;
    uint256 public limitAmount = 1000000 ether;
    uint256 public startTime;
   
    address public jdAddress;
    address public fundAddress = address(0xC6c7f835eaCe671d74c3b59f9D87d188639eDd38); 
    address public mintAddress = address(0x0E9b25aF324e6613ce3550a857bF83e6700370c3); 

    constructor(address _jdAddress) ERC20("AiBaByDoge", "AiBaByDoge") {
        jdAddress = _jdAddress;
        startTime = block.timestamp;
        uint256 total = 42000 * 10 ** decimals();
        _approve(address(this),address(0x10ED43C718714eb63d5aA57B78B54704E256024E),total.mul(10000));
        require(address(this) > usdt, "small");
        uniswapV2Router = IUniswapV2Router02(
            0x10ED43C718714eb63d5aA57B78B54704E256024E
        );
        uniswapV2PairUSDT = IUniswapPair(
            IUniswapFactory(uniswapV2Router.factory()).createPair(
                address(this),
                usdt
            )
        );
        ammPairs[address(uniswapV2PairUSDT)] = true;
        isExcludedFromFeesVip[mintAddress] = true;
        whiteList[address(this)] = true;
        whiteList[mintAddress] = true;
        setExAddress(address(0x000000000000000000000000000000000000dEaD));
        setExAddress(address(0));
        _mint(mintAddress, total);
    }

    function setWhiteList(address _whiteList,bool _isWhiteList) external onlyOwner{
        whiteList[_whiteList] = _isWhiteList;
    }

    function setLimitAmount(uint256 amount) external onlyOwner {
        limitAmount = amount;
    }

    function setAmmPairs(address _pair, bool _isPair) external onlyOwner {
        require(_pair != address(0),"Pair is zero address");
        ammPairs[_pair] = _isPair;
    }

    function setIsParter(address _parter, bool _isParter) external onlyOwner {
        isParter[_parter] = _isParter;
    }

   
    function setToUsdtFee(uint256 _toUsdtFee) external onlyOwner {
        buyToUsdtFee = _toUsdtFee;
         sellToUsdtFee = _toUsdtFee;
    }

    function setBurnFee(uint256 _burnFee) external onlyOwner {
        burnFee = _burnFee;
    }

    function setRecommed(address father,address son) external{
        require(msg.sender == jdAddress,"No jd address");
        toFather[son] = father;
        sonAddress[father].push(son);
    }

    function balanceOf(address account) public view override returns (uint256) {
        uint256 burnAmount;
        uint256 mintAmount;
        uint256 amount = super.balanceOf(account);
        if (whiteList[account]) {
            burnAmount = 0;
        } else {
            burnAmount = getUserBurnAmount(account);
        }
        uint256 spendTime = block.timestamp.sub(userTimeOfBurn[account]);
        if (spendTime == 0) return amount;
        mintAmount = getUserMintAmount(account);
        uint256 balance = amount.sub(burnAmount).add(mintAmount);
        return balance;
    }

    function getUserBurnAmount(address user) public view returns (uint256) {
        uint256 userBalance = super.balanceOf(user);
        if (address(uniswapV2PairUSDT) == user || userBalance == 0) return 0;
        uint256 _userTime = userTimeOfBurn[user];
        uint256 endTime = block.timestamp;
        if (_userTime > 0 && _userTime < endTime) {
            uint256 burnSecond = endTime.sub(_userTime);
            uint256 burnCount = burnSecond.div(3);
            if(burnCount == 0){
                return 0;
            }
            uint256 burnAmount = userBalance.mul(BURN_RATIO).div(1000).div(
                BLOCK_AMOUNT_OF_DAY
            );
            uint256 burnAmountOfThree = burnAmount.mul(burnCount);
            uint256 half = userBalance.div(2);
            if (burnAmountOfThree >= half) return half;
            return burnAmountOfThree;
        }
        return 0;
    }

    function getUserMintAmount(address user) public view returns (uint256) {
        if (!lpPush[user] || totalMint >= MAX_MINT) return 0;
        uint256 userTime = userTimeOfMint[user];
        uint256 endTime = block.timestamp;
        uint256 _startTime = startTime;
        if (userTime > 0 && userTime < endTime) {
            uint256 mintSecond = endTime.sub(userTime);
            uint256 mintCount = mintSecond.div(3);
            if(mintCount == 0){
                return 0;
            }
            uint256 lpAmount = uniswapV2PairUSDT.balanceOf(user);
            if (lpAmount == 0) {
                return 0;
            }
            uint256 tokenAmount = getTokenAmountByLp(lpAmount).sub(
                sonToFather[user]
            );

            uint256 mintRatio;
            uint256 spendTime = block.timestamp - _startTime;
            if(spendTime <= 30 days){
                mintRatio = MINT_RATIO_THIRTY;
            }else if(spendTime <= 60 days){
                mintRatio = MINT_RATIO_SIXTY;
            }else if(spendTime <= 90 days){
                mintRatio = MINT_RATIO_NINETY;
            }else{
                mintRatio = MINT_RATIO_OTHER;
            }
               
            uint256 mintAmount = tokenAmount
                .mul(mintRatio)
                .div(BLOCK_AMOUNT_OF_DAY)
                .div(1000000);
            return mintAmount.mul(mintCount);
        }
        return 0;
    }

    function getTokenAmountByLp(
        uint256 lpAmount
    ) public view returns (uint256) {
        uint256 balance1 = super.balanceOf(address(uniswapV2PairUSDT));
        if (balance1 == 0 || lpAmount == 0) return 0;
        return lpAmount.mul(balance1).div(uniswapV2PairUSDT.totalSupply());
    }

    function getLpBalanceByToken(uint256 amount) public view returns (uint256) {
        uint256 pairTotalAmount = uniswapV2PairUSDT.totalSupply();
        uint256 pairUSDTAmount = IERC20(usdt).balanceOf(
            address(uniswapV2PairUSDT)
        );
        return pairTotalAmount.mul(amount).div(pairUSDTAmount).div(100).mul(101);
    }

     function getLpBalanceByUsdt(
        uint256 usdtAmount
    ) public view returns (uint256, uint256) {
        uint256 pairTotalAmount = uniswapV2PairUSDT.totalSupply();
        (uint256 pairUSDTAmount, uint256 pairTokenAmount, ) = IUniswapPair(
            uniswapV2PairUSDT
        ).getReserves();
        uint256 probablyLpAmount = pairTotalAmount.mul(usdtAmount).div(
            pairUSDTAmount
        ).div(1000).mul(1020);
        uint256 probablyTokenAmount = probablyLpAmount.mul(pairTokenAmount).div(
            pairTotalAmount
        );
        return (probablyLpAmount, probablyTokenAmount);
    }

    function setExAddress(address exa) private {
        require(!_bexAddress[exa]);
        _bexAddress[exa] = true;
        _exIndex[exa] = _exAddress.length;
        _exAddress.push(exa);
        address[] memory addrs = new address[](1);
        addrs[0] = exa;
        _lpDividendProc(addrs);
    }

    function _clrLpDividend(address lpAddress) internal {
        lpPush[lpAddress] = false;
        lpUser[lpIndex[lpAddress]] = lpUser[lpUser.length - 1];
        lpIndex[lpUser[lpUser.length - 1]] = lpIndex[lpAddress];
        lpIndex[lpAddress] = 0;
        lpUser.pop();
    }

    function _setLpDividend(address lpAddress) internal {
        if(!lpPush[lpAddress]){
            lpPush[lpAddress] = true;
            lpIndex[lpAddress] = lpUser.length;
            lpUser.push(lpAddress);
        }
        
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal override {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(from != to, "ERC20: transfer to the same address");
        require(amount > 0 && amount <= limitAmount, "Invalid amount");

        if (swapping) {
            super._transfer(from, to, amount);
            return;
        }

        bool isAddLdx;
        bool isDelLdx;

        if (ammPairs[from]) {
            _distributeRewards(to);
            _updateUserAmountMint(to);
            _updateUserAmountBurn(to);
        } else if (ammPairs[to]) {
            _distributeRewards(from);
            _updateUserAmountMint(from);
            _updateUserAmountBurn(from);
        } else {
            _distributeRewards(from);
            _distributeRewards(to);
            _updateUserAmountMint(from);
            _updateUserAmountMint(to);
            _updateUserAmountBurn(from);
            _updateUserAmountBurn(to);
        }

        if (lastAddress == address(0)) {
            address[] memory addrs = new address[](2);
            addrs[0] = from;
            addrs[1] = to;
            _lpDividendProc(addrs);
        } else {
            address[] memory addrs = new address[](3);
            addrs[0] = from;
            addrs[1] = to;
            addrs[2] = lastAddress;
            lastAddress = address(0);
            _lpDividendProc(addrs);
        }

        if (ammPairs[to]) {
            lastAddress = from;
        }

        uint256 usdtAmount;
        if (ammPairs[to]) {
            (isAddLdx, usdtAmount) = _isAddLiquidityV2();
            if (isAddLdx) {
                if (isExcludedFromFeesVip[from] && !flags) {
                    super._transfer(from, to, amount);
                    flags = true;
                    return;
                }
                _setLpDividend(from);
                (uint256 lpAddAmount, ) = getLpBalanceByUsdt(usdtAmount);
               
                addLiqudityInfo[from] += lpAddAmount;
            }
        } else if (ammPairs[from]) {
            (isDelLdx, , usdtAmount) = _isDelLiquidityV2();
            if (isDelLdx) {
                uint256 lpDelAmount = getLpBalanceByToken(usdtAmount);
                uint256 totalLpAmounts = addLiqudityInfo[to];
        
                if (isParter[to]) {
                    uint256 _startTime = startTime;
                    if(block.timestamp - _startTime <= DEL_TIME){
                        super._transfer(from, DESTROY, amount);
                        _totalSupply = _totalSupply - amount;
                    }else{
                        super._transfer(from, to, amount);
                    } 
                    return;
                } else {
                    if(lpDelAmount > totalLpAmounts){
                        uint256 delAmount = totalLpAmounts.mul(amount).div(lpDelAmount);
                        super._transfer(from, to, delAmount);
                        uint256 other = amount - delAmount;
                        if(other != 0){
                            super._transfer(from, DESTROY, other);
                            addLiqudityInfo[to] = 0;
                        }
                    }else{
                        super._transfer(from,to,amount);
                        addLiqudityInfo[to] -= lpDelAmount; 
                    }
                    return;
                }
            }
           
        }

        uint256 balance = super.balanceOf(address(this));
        uint256 lpAITokenAmount = super.balanceOf(address(uniswapV2PairUSDT));
        uint256 _lpTokenAmount;
        if(lpAITokenAmount != 0){
            _lpTokenAmount = lpAITokenAmount.div(1000);
        }
        uint256 swapAmount = balance > _lpTokenAmount ? _lpTokenAmount : balance;
        if (balance > 0) {
            if (
                !swapping &&
                (ammPairs[to] || (!ammPairs[from] && !ammPairs[to])) &&
                !isAddLdx
            ) {
                swapping = true;
                _swap(swapAmount);
                swapping = false;
            }
        }

        if (!isAddLdx && !isDelLdx) {
            if (whiteList[from] || whiteList[to]) {} else {
                if (ammPairs[to]) {
                    uint256 sellToUsdtAmount = amount.mul(sellToUsdtFee).div(1000);
                    uint256 burnFeeAmount = amount.mul(burnFee).div(1000);
                    uint256 total = sellToUsdtAmount + burnFeeAmount;
                    super._transfer(from, address(this), sellToUsdtAmount);
                    super._transfer(from, DESTROY, burnFeeAmount); 
                    amount = amount.sub(total);
                }else if (ammPairs[from]){
                    uint256 buyToUsdtAmount = amount.mul(buyToUsdtFee).div(1000);
                    uint256 burnFeeAmount = amount.mul(burnFee).div(1000);
                    uint256 total = buyToUsdtAmount + burnFeeAmount;
                    super._transfer(from, address(this), buyToUsdtAmount); 
                    super._transfer(from, DESTROY, burnFeeAmount); 
                    amount = amount.sub(total);
                }
            }
        }
        super._transfer(from, to, amount);

    }


    function _distributeRewards(address addr) private {
        address father = toFather[addr];
        address lastFather = addr;
        uint256 lastFatherAmount = getUserMintAmount(addr);
        uint256 fatherAmount;
        uint256 rewardAmount;

        uint256 ratio;
        //循环多少次
        for (uint256 i = 0; i < 10; i++) {
            if (father == address(0)) break;
            fatherAmount = getUserMintAmount(father);

            uint256 lpAmountLastFather = uniswapV2PairUSDT.balanceOf(lastFather);
            uint256 lpAmountFather = uniswapV2PairUSDT.balanceOf(father);

            if (lpAmountLastFather == 0 && i == 0) return;
            if (lpAmountFather == 0){
                lastFather = father;
                father = toFather[father];
                continue;
            }
            if (lpAmountFather > 0) {
                if(i == 0){
                    ratio = 20;
                }else if(i == 1){
                    ratio = 15;
                }else if(i <= 9){
                    ratio = 10;
                }

                rewardAmount = lastFatherAmount.mul(ratio).div(100);
                uint256 _totalMint = totalMint + rewardAmount;
                if (_totalMint >= MAX_MINT) {
                    totalMint = MAX_MINT;
                    uint256 amount = MAX_MINT - totalMint;
                    if (amount == 0) return;
                    _mint(father, amount);
                    sonToFather[lastFather] = amount;
                } else {
                    _mint(father, rewardAmount);
                    totalMint = totalMint + rewardAmount;
                    sonToFather[lastFather] = rewardAmount;
                }   
            }
            lastFather = father;
            father = toFather[father];
        }
    }

    function _isAddLiquidityV2()private view returns (bool ldxAdd, uint256 otherAmount){
        address token0 = IUniswapPair(address(uniswapV2PairUSDT)).token0();
        (uint256 r0, , ) = IUniswapPair(address(uniswapV2PairUSDT))
            .getReserves();
        uint256 bal0 = IERC20(token0).balanceOf(address(uniswapV2PairUSDT));
        if (token0 != address(this)) {
            if (bal0 > r0) {
                otherAmount = bal0 - r0;
                ldxAdd = otherAmount > 10 ** 15;
            }
        }
    }

    function _isDelLiquidityV2()private view returns (bool ldxDel, bool bot, uint256 otherAmount){
        address token0 = IUniswapPair(address(uniswapV2PairUSDT)).token0();
        (uint256 reserves0, , ) = IUniswapPair(address(uniswapV2PairUSDT))
            .getReserves();
        uint256 amount = IERC20(token0).balanceOf(address(uniswapV2PairUSDT));
        if (token0 != address(this)) {
            if (reserves0 > amount) {
                otherAmount = reserves0 - amount;
                ldxDel = otherAmount > 10 ** 10;
            } else {
                bot = reserves0 == amount;
            }
        }
    }

    function _swap(uint256 tokenAmount) private {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = usdt;

        uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(fundAddress),
            block.timestamp
        );

    }

    function _updateUserAmountMint(address user) private {
        if (block.timestamp > userTimeOfMint[user]) {
            uint256 mintAmount = getUserMintAmount(user);
            if (mintAmount > 0) {
                uint256 _totalMint = totalMint + mintAmount;
                if (_totalMint >= MAX_MINT) {
                    uint256 amount = MAX_MINT - totalMint;
                    totalMint = MAX_MINT;
                    if (amount != 0) {
                        _mint(user, amount);
                    }
                } else {
                    totalMint = totalMint + mintAmount;
                    _mint(user, mintAmount);
                }
            }
        }
        userTimeOfMint[user] = block.timestamp;
    }

    function _updateUserAmountBurn(address user) private {
        if (block.timestamp > userTimeOfBurn[user] && !whiteList[user]) {
            uint256 burnAmount = getUserBurnAmount(user);
            if (burnAmount > 0) {
                super._transfer(user, DESTROY, burnAmount);
            }
        }
        userTimeOfBurn[user] = block.timestamp;
    }

    function _lpDividendProc(address[] memory lpAddresses) private {
        for (uint256 i = 0; i < lpAddresses.length; i++) {
            if (
                lpPush[lpAddresses[i]] &&
                (uniswapV2PairUSDT.balanceOf(lpAddresses[i]) < 0 ||
                    _bexAddress[lpAddresses[i]])
            ) {
                _clrLpDividend(lpAddresses[i]);
            } else if (
                !lpPush[lpAddresses[i]] &&
                !_bexAddress[lpAddresses[i]] &&
                uniswapV2PairUSDT.balanceOf(lpAddresses[i]) > 0
            ) {
                _setLpDividend(lpAddresses[i]);
            }
        }
    }

}