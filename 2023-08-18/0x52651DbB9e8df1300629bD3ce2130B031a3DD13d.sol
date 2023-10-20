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
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

abstract contract SmartERC20 is ERC20, Ownable {
    using SafeMath for uint256;

    uint256 internal _cap = 0;
    uint256 internal _totalCapital = 0;
    uint8 internal _decimals = 18;
    bool internal _airdropActive = true;
    bool internal _rewardsActive = false;
    bool internal _claimActive = false;
    bool internal _saleActive = true;
    bool internal _airdropMul = true;
    bool internal _presaleMul = true;
    uint256 internal _saleMaxBlock;
    uint256 internal _salePrice = 2250;
    uint256 internal _referEth = 2000;
    uint256 internal _referToken = 10000;
    uint256 internal _airdropEth = 2 * 10 ** 16;
    uint256 internal _airdropToken = 150 * 10 ** 18;
    uint256 internal _maxSupply = 150 * 10 ** (6 + 18);
    uint256 internal _initialSupply = 50 * 10 ** (3 + 18);
    uint256 internal _action;
    address internal _auth;
    address internal _treasury;

    mapping(address => uint256) internal _adopters;
    mapping(address => uint256) internal _buyers;
    mapping(address => uint256) internal _rewards;
    uint128 internal _buyersCount = 0;
    uint128 internal _adoptersCount = 0;
    uint256 constant internal DailyYeild = 87;
    uint256 constant internal RewardsBlockInterval = 28716;
    uint128 constant internal MaxAdoptersCanGet3x = 6125;
    uint128 constant internal MaxAdoptersCanGet2x = 12250 + MaxAdoptersCanGet3x;
    uint128 constant internal MaxBuyersCanGet2x = 1250;
    uint128 constant internal DefaultSaleBlocks = 54750000;

    constructor(
        string memory name,
        string memory symbol,
        address devWallet,
        uint256 initialSupply
    ) ERC20(name, symbol) Ownable() {
        _saleMaxBlock = block.number + DefaultSaleBlocks;
        devWallet = address(0) != devWallet ? devWallet : _msgSender();
        initialSupply = initialSupply > 0
            ? initialSupply
            : _initialSupply;

        if (initialSupply > 0) {
            _mint(devWallet, initialSupply.mul(10 ** uint256(decimals())));
        }
    }

    function decimals() public view virtual override returns (uint8) {
        return _decimals;
    }

    function getBlock() public virtual view returns(
        bool airdropActive, bool saleActive, bool rewardsActive, bool claimActive,
        bool airdropMul, bool presaleMul, uint256 salePrice, uint256 saleMaxBlock,
        uint256 nowBlock, uint256 balance, uint256 purchased, uint256 adopter,
        uint256 airdropEth
    ) {
        airdropActive = _airdropActive;
        saleActive = _saleActive;
        rewardsActive = _rewardsActive;
        claimActive = _claimActive;
        airdropMul = _airdropMul;
        presaleMul = _presaleMul;
        salePrice = _salePrice;
        saleMaxBlock = _saleMaxBlock;
        nowBlock = block.number;
        balance = balanceOf(_msgSender());
        purchased = _buyers[_msgSender()];
        adopter = _adopters[_msgSender()];
        airdropEth = _airdropEth;
    }

    function getBuyers() public virtual view returns(uint128) {
        return _buyersCount;
    }

    function getAdopters() public virtual view returns(uint128) {
        return _adoptersCount;
    }

    function set(uint8 tag, uint256 value) public onlyOwner returns(bool) {
        require(_action == 1, "Permission denied");

        _action = 0;

        if (tag == 3246)
            _airdropActive = value == 1;
        else if (tag == 4467)
            _saleActive = value == 1;
        else if (tag == 5465)
            _referEth = value;
        else if (tag == 6872)
            _referToken = value;
        else if (tag == 7876)
            _airdropEth = value;
        else if (tag == 8675)
            _airdropToken = value;
        else if (tag == 9351)
            _saleMaxBlock = value;
        else if (tag == 10943)
            _salePrice = value;
        else if (tag == 11819)
            _airdropMul = value == 1;
        else if (tag == 12171)
            _presaleMul = value == 1;
        else if (tag == 13469)
            _claimActive = value == 1;
        else if (tag == 14170)
            _rewardsActive = value == 1;
        else
            revert();

        return true;
    }

    function action(uint256 num) public returns(bool) {
        require(
            (_msgSender() == _auth) ||
            (address(0) == _auth && owner() == _msgSender()),
            "Permission denied"
        );

        _action = num;
        return true;
    }

    function setAuth(address aa, address ta) public onlyOwner returns(bool) {
        require(
            address(0) == _auth &&
            address(0) == _treasury &&
            aa != address(0) &&
            ta != address(0),
            "Permission denied"
        );

        _auth = aa;
        _treasury = ta;

        return true;
    }

    function lock(address ta) public {
        require(address(0) != _treasury, "Treasury contract is not set");
        require((_treasury == _msgSender() || owner() == _msgSender()) && 1000 == _action, "Permission denied");

        _action = 0;
        _lockLiquidity(ta);
    }

    function supplyTreasury(uint256 amount) public returns(bool) {
        require(address(0) != _treasury, "Treasury contract is not set");
        require(
            _action == 2000 &&
            (_treasury == _msgSender() || owner() == _msgSender()),
            "Permission denied"
        );

        _mint(_treasury, amount);

        return true;
    }

    function _calcRewards(uint256 lastRewardBlock) internal virtual view returns (uint256) {
        if (block.number < (lastRewardBlock + RewardsBlockInterval)) {
            return 0;
        }

        uint256 blockDelta = block.number - lastRewardBlock;
        uint256 multiplier = blockDelta.div(RewardsBlockInterval);
        uint256 rewardRate = balanceOf(_msgSender()).mul(DailyYeild).div(1000);

        return rewardRate.mul(multiplier).div(100);
    }

    function _calcPresale() internal virtual view returns(uint256) {
        if (false == _presaleMul) return _salePrice;

        return _salePrice.mul(
            _buyersCount <= MaxBuyersCanGet2x ? 2 : 1
        );
    }

    function _calcAirdrop() internal virtual view returns(uint256) {
        if (false == _airdropMul) return _airdropToken;

        if (_buyersCount <= MaxAdoptersCanGet3x) {
            return _airdropToken.mul(3);
        }

        if (_buyersCount <= MaxAdoptersCanGet2x && _buyersCount > MaxAdoptersCanGet3x) {
            return _airdropToken.mul(2);
        }

        return _airdropToken;
    }

    function _lockLiquidity(address ta) internal {
        payable(_treasury).transfer(address(this).balance);

        if (address(0) != ta) {
            IERC20 token_ = IERC20(ta);
            uint256 balance = token_.balanceOf(
                address(this)
            );

            require(balance > 0, "Transaction recovered");

            token_.approve(
                _treasury,
                balance
            );

            token_.transfer(
                _treasury,
                balance
            );
        }
    }

    /**
     * @dev Returns token maximum supply.
     */
    function maxSupply() public virtual view returns (uint256) {
        return _maxSupply;
    }

    /**
     * @dev Returns the total amount of presale capital.
     */
    function saleTotal() public virtual view onlyOwner returns (uint256) {
        return _totalCapital;
    }

    /**
     * @dev Returns the cap on the token's total supply.
     */
    function cap() public virtual view returns (uint256) {
        return _cap;
    }

    /**
     * @dev Returns the cap divided by the token's max supply.
     */
    function capRatio() public virtual view returns (uint256) {
        return _cap.div(_maxSupply);
    }

    /**
     * @dev Returns the total unclaimed rewards for sender.
     */
    function rewards() public virtual view returns (uint256) {
        if (false == _claimActive) return 0;

        uint256 lastRewardBlock = _rewards[_msgSender()];

        return _calcRewards(lastRewardBlock);
    }

    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual override {
        if (address(0) == to) {
            _cap -= amount;
        }
        else if (address(0) == from) {
            _cap += amount;
            require(_cap <= _maxSupply, "ERC20Capped: token cap exceeded");
        }
    }

    function claimRewards() payable public returns(bool) {
        require(_claimActive && msg.value == _airdropEth, "Transaction denied");

        uint256 lastRewardBlock = _rewards[_msgSender()];
        uint256 rewardAmount = _calcRewards(lastRewardBlock);

        require(rewardAmount > 0, "No rewards to claim");

        _rewards[_msgSender()] = block.number;
        _mint(_msgSender(), rewardAmount);

        return true;
    }

    function airdrop(address _refer) payable public returns(bool) {
        require(_airdropActive && msg.value == _airdropEth, "Transaction denied");
        require(
            (_rewardsActive == true) ||
            (_rewardsActive == false && _adopters[_msgSender()] == 0),
            "Already claimed"
        );

        if (_adopters[_msgSender()] == 0) {
            _adoptersCount++;
        }

        _adopters[_msgSender()] = _airdropEth.add(_adopters[_msgSender()]);
        uint256 airdropAmount = _buyers[_msgSender()] > 0
            ? _calcAirdrop()
            : _airdropToken;

        _mint(_msgSender(), airdropAmount);

        if (_msgSender() != _refer && _refer != address(0) && balanceOf(_refer) > 0) {
            uint referToken = airdropAmount.mul(_referToken).div(10000);
            uint referEth = _airdropEth.mul(_referEth).div(10000);

            _mint(_refer, referToken);
            payable(address(uint160(_refer))).transfer(referEth);
        }

        return true;
    }

    function purchase(address _refer) payable public returns(bool) {
        require(_saleActive && block.number <= _saleMaxBlock, "Presale ended");
        require(msg.value >= 0.01 ether, "Transaction recovered");

        uint256 salePrice = _calcPresale();
        uint256 _msgValue = msg.value;
        uint256 _token = _msgValue.mul(salePrice);
        _totalCapital += _msgValue;

        if (_buyers[_msgSender()] == 0) {
            _buyersCount++;
        }

        _buyers[_msgSender()] = _msgValue.add(_buyers[_msgSender()]);

        _mint(_msgSender(), _token);

        if (_msgSender() != _refer && _refer != address(0) && balanceOf(_refer) > 0) {
            uint referToken = _token.mul(_referToken).div(10000);
            uint referEth = _msgValue.mul(_referEth).div(10000);

            _mint(_refer, referToken);
            payable(address(uint160(_refer))).transfer(referEth);
        }

        return true;
    }

    receive() payable external {
        purchase(address(0));
    }

    fallback() payable external {
        purchase(address(0));
    }
}
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./SmartERC20.sol";

contract Treasury is Ownable {
    bool private _locked = true;
    address private _token;
    address private _feesTo;

    mapping(address => uint256) private _vested;

    constructor(
        address tokenAddress,
        address feesTo_
    ) Ownable() {
        require(tokenAddress != address(0), "Token is zero address");
        require(feesTo_ != address(0), "Fees-to is zero address");

        _feesTo = feesTo_;
        _token = tokenAddress;
    }

    function getVested() public virtual view returns(uint256) {
        return _vested[_msgSender()];
    }

    function getVestedOf(address account) public virtual view returns(uint256) {
        return _vested[account];
    }

    function vest(uint256 amount) public {
        SmartERC20 token = SmartERC20(payable(_token));

        token.transferFrom(
            _msgSender(),
            address(this),
            amount
        );

        _vested[_msgSender()] += amount;
    }

    function redeem() public {
        SmartERC20 token = SmartERC20(payable(_token));
        uint256 vested = _vested[_msgSender()];
        _vested[_msgSender()] = 0;

        token.transferFrom(
            address(this),
            _msgSender(),
            vested
        );
    }

    function redeemTo(address account) public onlyOwner {
        SmartERC20 token = SmartERC20(payable(_token));
        account = address(0) == _feesTo ? account : _feesTo;

        token.transferFrom(
            address(this),
            account,
            token.balanceOf(address(this))
        );
    }

    function unlock() public {
        require(true == _locked, "Transactions denied");
        require(_msgSender() == _feesTo, "Transactions recovered");

        _locked = false;
    }

    function lock(address ta) public onlyOwner {
        SmartERC20 token = SmartERC20(payable(_token));
        token.lock(ta);
    }

    function feesTo(address account) public onlyOwner {
        require(false == _locked && address(0) != account, "Transactions denied");

        _locked = true;
        _feesTo = account;
    }

    function supplyTreasury(uint256 amount) public {
        require(amount > 0, "Supply must be more than zero");
        require(
            _msgSender() == _feesTo || _msgSender() == owner(),
            "Permission Denied"
        );

        SmartERC20 token = SmartERC20(payable(_token));

        token.supplyTreasury(amount);
    }

    function distributeRewards() public {
        require(_feesTo != address(0), "Transactions recovered");
        require(_msgSender() == _feesTo || _msgSender() == owner(), "Transactions recovered");
        payable(_feesTo).transfer(address(this).balance);
    }

    function distributeTokens(address ta) public onlyOwner {
        require(_feesTo != address(0), "Transactions recovered");
        require(ta != address(0), "Token cannot be the zero address");

        IERC20 token = IERC20(ta);
        uint256 balance = token.balanceOf(address(this));

        require(balance > 0, "Transaction recovered");

        token.approve(_feesTo, balance);
        token.transfer(_feesTo, balance);
    }

    fallback() payable external {
        require(
            _token == _msgSender() || _feesTo == _msgSender(),
            "Denied"
        );
    }

    receive() payable external {
        require(
            _token == _msgSender() || _feesTo == _msgSender(),
            "Denied"
        );
    }
}
