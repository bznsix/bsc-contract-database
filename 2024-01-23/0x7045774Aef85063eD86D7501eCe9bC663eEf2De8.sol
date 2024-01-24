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
// OpenZeppelin Contracts (last updated v4.8.0) (token/ERC20/ERC20.sol)

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
// OpenZeppelin Contracts v4.4.1 (token/ERC721/utils/ERC721Holder.sol)

pragma solidity ^0.8.0;

import "../IERC721Receiver.sol";

/**
 * @dev Implementation of the {IERC721Receiver} interface.
 *
 * Accepts all token transfers.
 * Make sure the contract is able to use its token with {IERC721-safeTransferFrom}, {IERC721-approve} or {IERC721-setApprovalForAll}.
 */
contract ERC721Holder is IERC721Receiver {
    /**
     * @dev See {IERC721Receiver-onERC721Received}.
     *
     * Always returns `IERC721Receiver.onERC721Received.selector`.
     */
    function onERC721Received(
        address,
        address,
        uint256,
        bytes memory
    ) public virtual override returns (bytes4) {
        return this.onERC721Received.selector;
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
pragma solidity ^0.8.8;

library StructData {
    // struct to store staked NFT information
    struct StakedNFT {
        address stakerAddress;
        uint256 lastClaimedTime;
        uint256 unlockTime;
        uint256 totalValueStakeUsdWithDecimal;
        uint256 totalClaimedAmountTokenWithDecimal;
        bool isUnstaked;
    }

    struct ChildListData {
        address[] childList;
        uint256 memberCounter;
    }

    struct ListBuyData {
        StructData.InfoBuyData[] childList;
    }

    struct InfoBuyData {
        uint256 timeBuy;
        uint256 valueUsd;
    }

    struct ListSwapData {
        StructData.InfoSwapData[] childList;
    }

    struct InfoSwapData {
        uint256 timeSwap;
        uint256 valueSwap;
    }

    struct ListMaintenance {
        StructData.InfoMaintenanceNft[] childList;
    }

    struct InfoMaintenanceNft {
        uint256 startTimeRepair;
        uint256 endTimeRepair;
    }

    struct StakeTokenPools {
        uint256 poolId;
        uint256 maxStakePerWallet;
        uint256 duration;
        bool isPayProfit;
        uint256 totalStake;
        uint256 totalEarn;
        address stakeToken;
        address earnToken;
    }

    struct StakedToken {
        uint256 stakeId;
        address userAddress;
        uint256 poolId;
        uint256 unlockTime;
        uint256 startTime;
        uint256 totalValueStake;
        uint256 totalValueClaimed;
        bool isWithdraw;
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

interface IMarketplace {
    event Buy(address seller, address buyer, uint256 nftId, address refAddress);

    event Sell(address seller, address buyer, uint256 nftId);

    event PayCommission(address buyer, address refAccount, uint256 commissionAmount);

    event ErrorLog(bytes message);

    function buyByCurrency(uint256[] memory _nftIds, address _refAddress) external;

    function buyByToken(uint256[] memory _nftIds, address _refAddress) external;

    function buyByTokenAndCurrency(uint256[] memory _nftIds, address _refAddress) external;

    function setSaleWalletAddress(address _saleAddress) external;

    function setStakingContractAddress(address _stakingAddress) external;

    function setNetworkWalletAddress(address _networkWallet) external;

    function setDiscountPercent(uint8 _discount) external;

    function setMaxNumberStakeValue(uint8 _percent) external;

    function setDefaultMaxCommission(uint256 _value) external;

    function setSaleStrategyOnlyCurrencyStart(uint256 _newSaleStart) external;

    function setSaleStrategyOnlyCurrencyEnd(uint256 _newSaleEnd) external;

    function setSalePercent(uint256 _newSalePercent) external;

    function setOracleAddress(address _oracleAddress) external;

    function setNftAddress(address _nftAddress) external;

    function allowBuyNftByCurrency(bool _activePayByCurrency) external;

    function allowBuyNftPass(bool _useNftPass) external;

    function allowBuyNftByToken(bool _activePayByToken) external;

    function allowBuyNftByCurrencyAndToken(bool _activePayByCurrencyAndToken) external;

    function setTierPriceUsdPercent(uint16 _tier, uint256 _percent) external;

    function setToken(address _address) external;

    function setTypePayCommission(uint256 _typePayCommission) external;

    function getActiveMemberForAccount(address _wallet) external returns (uint256);

    function getTotalCommission(address _wallet) external view returns (uint256);

    function getReferredNftValueForAccount(address _wallet) external returns (uint256);

    function getNftCommissionEarnedForAccount(address _wallet) external view returns (uint256);

    function getNftSaleValueForAccountInUsdDecimal(address _wallet) external view returns (uint256);

    function getTotalCommissionStakeByAddressInUsd(address _wallet) external view returns (uint256);

    function getMaxCommissionByAddressInUsd(address _wallet) external view returns (uint256);

    function updateCommissionStakeValueData(address _user, uint256 _valueInUsdWithDecimal) external;

    function updateReferralData(address _user, address _refAddress) external;

    function getReferralAccountForAccount(address _user) external view returns (address);

    function getReferralAccountForAccountExternal(address _user) external view returns (address);

    function getF1ListForAccount(address _wallet) external view returns (address[] memory);

    function getTeamNftSaleValueForAccountInUsdDecimal(address _wallet) external returns (uint256);

    function possibleChangeReferralData(address _wallet) external returns (bool);

    function lockedReferralDataForAccount(address _user) external;

    function setSystemWallet(address _newSystemWallet) external;

    function isBuyByToken(uint256 _nftId) external view returns (bool);

    function setCurrencyAddress(address _currency) external;

    function withdrawTokenEmergency(address _token, uint256 _amount) external;

    function withdrawTokenEmergencyFrom(address _from, address _to, address _currency, uint256 _amount) external;

    function transferNftEmergency(
        address _receiver,
        uint256 _nftId,
        bool _isEquip,
        bool _isToken,
        bool _isPay
    ) external;

    function transferMultiNftsEmergency(
        address[] memory _receivers,
        uint256[] memory _nftIds,
        bool _isEquip,
        bool _isToken,
        bool _isPay
    ) external;

    function checkValidRefCodeAdvance(address _user, address _refAddress) external returns (bool);

    function getCommissionPercent(uint8 _level) external returns (uint16);

    function getTierUsdPercent(uint16 _tier)external view returns (uint256);

    function setCommissionPercent(uint8 _level, uint16 _percent) external;

    function setNftBuyByToken(uint256 _nftId, bool _isBuyByToken) external;

    function getConditionTotalCommission(uint8 _level) external returns (uint256);

    function setConditionTotalCommission(uint8 _level, uint256 _value) external;

    function setIsEnableBurnToken(bool _isEnableBurnToken) external;

    function setBurnAddress(address _burnAddress) external;

    function setPayToken(bool _payInCurrency, bool _payInToken, bool _payInFlex) external;
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "../swap/InternalSwap.sol";

interface IPancakePair {
    function getReserves() external view returns (uint112 _reserve0, uint112 _reserve1, uint32 _blockTimestampLast);
}

contract Oracle is Ownable {
    uint256 private minTokenAmount = 0;
    uint256 private maxTokenAmount = 0;

    address public pairAddress;
    address public stableToken;
    address public tokenAddress;
    address public swapAddress;
    uint8 private typeConvert = 1; // 0:average 1: only swap 2: only pancake

    constructor(address _swapAddress, address _stableToken, address _tokenAddress) {
        swapAddress = _swapAddress;
        stableToken = _stableToken;
        tokenAddress = _tokenAddress;
    }

    function convertInternalSwap(uint256 _value, bool toToken) public view returns (uint256) {
        uint256 usdtAmount = InternalSwap(swapAddress).getUsdtAmount();
        uint256 tokenAmount = InternalSwap(swapAddress).getTokenAmount();
        if (tokenAmount > 0 && usdtAmount > 0) {
            uint256 amountTokenDecimal;
            if (toToken) {
                amountTokenDecimal = (_value * tokenAmount) / usdtAmount;
            } else {
                amountTokenDecimal = (_value * usdtAmount) / tokenAmount;
            }

            return amountTokenDecimal;
        }
        return 0;
    }

    function convertUsdBalanceDecimalToTokenDecimal(uint256 _balanceUsdDecimal) public view returns (uint256) {
        uint256 tokenInternalSwap = convertInternalSwap(_balanceUsdDecimal, true);
        uint256 tokenPairConvert;
        if (pairAddress != address(0)) {
            (uint256 _reserve0, uint256 _reserve1, ) = IPancakePair(pairAddress).getReserves();
            (uint256 _tokenBalance, uint256 _stableBalance) = address(tokenAddress) < address(stableToken)
                ? (_reserve0, _reserve1)
                : (_reserve1, _reserve0);

            uint256 _minTokenAmount = (_balanceUsdDecimal * minTokenAmount) / 1000000;
            uint256 _maxTokenAmount = (_balanceUsdDecimal * maxTokenAmount) / 1000000;
            uint256 _tokenAmount = (_balanceUsdDecimal * _tokenBalance) / _stableBalance;

            if (_tokenAmount < _minTokenAmount) {
                tokenPairConvert = _minTokenAmount;
            }

            if (_tokenAmount > _maxTokenAmount) {
                tokenPairConvert = _maxTokenAmount;
            }

            tokenPairConvert = _tokenAmount;
        }
        if (typeConvert == 1) {
            return tokenInternalSwap;
        } else if (typeConvert == 2) {
            return tokenPairConvert;
        } else {
            if (tokenPairConvert == 0 || tokenInternalSwap == 0) {
                return tokenPairConvert + tokenInternalSwap;
            } else {
                return (tokenPairConvert + tokenInternalSwap) / 2;
            }
        }
    }

    function setPairAddress(address _address) external onlyOwner {
        require(_address != address(0), "ORACLE: INVALID PAIR ADDRESS");
        pairAddress = _address;
    }

    function setSwapAddress(address _address) external onlyOwner {
        require(_address != address(0), "ORACLE: INVALID SWAP ADDRESS");
        swapAddress = _address;
    }

    function setTypeConvertPrice(uint8 _type) external onlyOwner {
        require(_type <= 2, "ORACLE: INVALID TYPE CONVERT");
        typeConvert = _type;
    }

    function getTypeConvert() external view returns (uint8) {
        return typeConvert;
    }

    function setMinTokenAmount(uint256 _tokenAmount) external onlyOwner {
        minTokenAmount = _tokenAmount;
    }

    function setMaxTokenAmount(uint256 _tokenAmount) external onlyOwner {
        maxTokenAmount = _tokenAmount;
    }

    /**
     * @dev Recover lost bnb and send it to the contract owner
     */
    function recoverLostBNB() public onlyOwner {
        address payable recipient = payable(msg.sender);
        recipient.transfer(address(this).balance);
    }

    /**
     * @dev withdraw some token balance from contract to owner account
     */
    function withdrawTokenEmergency(address _token, uint256 _amount) public onlyOwner {
        require(_amount > 0, "INVALID AMOUNT");
        require(IERC20(_token).transfer(msg.sender, _amount), "CANNOT WITHDRAW TOKEN");
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

import "../data/StructData.sol";

interface IStaking {
    event Staked(uint256 id, address indexed staker, uint256 indexed nftID, uint256 unlockTime);
    event Unstaked(uint256 id, address indexed staker, uint256 indexed nftID);

    event Claimed(uint256 id, address indexed staker, uint256 claimAmount);

    event ErrorLog(bytes message);

    function setTimeOpenStaking(uint256 _timeOpening) external;

    function getCommissionCondition(uint8 _level) external view returns (uint32);

    function setCommissionCondition(uint8 _level, uint32 _conditionInUsd) external;

    function getCommissionPercent(uint8 _level) external view returns (uint16);

    function setCommissionPercent(uint8 _level, uint16 _percent) external;

    function getTotalTeamInvestment(address _wallet) external view returns (uint256);

    function getRefStakingValue(address _wallet) external view returns (uint256);

    function setTokenDecimal(uint256 _decimal) external;

    function setStakingPeriod(uint16 _stakingPeriod) external;

    function getTeamStakingValue(address _wallet) external view returns (uint256);

    function getStakingCommissionEarned(address _wallet) external view returns (uint256);

    function forceUpdateTotalCrewInvestment(address _user, uint256 _value) external;

    function setMarketContract(address _marketContract) external;

    function forceUpdateTeamStakingValue(address _user, uint256 _value) external;

    function forceUpdateStakingCommissionEarned(address _user, uint256 _value) external;

    function getTimeClaimEarn() external view returns (uint256);

    function setTimeClaimEarn(uint256 _timeClaimEarn) external;

    function stake(uint256 _nftId, bytes memory _data) external;

    function unstake(uint256 _stakeId, bytes memory data) external;

    function claim(uint256 _stakeId) external;

    function claimAll(uint256[] memory _stakeIds) external;

    function getDetailOfStake(uint256 _stakeId) external view returns (StructData.StakedNFT memory);

    function possibleUnstake(uint256 _stakeId) external view returns (bool);

    function claimableForStakeInTokenWithDecimal(uint256 _nftId) external view returns (uint256);

    function earnableForStakeWithDecimal(uint256 _nftId) external view returns (uint256);

    function getTotalStakeAmountUSD(address _staker) external view returns (uint256);

    function possibleForCommission(address _staker, uint8 _level) external view returns (bool);

    function getMaxFloorProfit(address _user) external view returns (uint8);

    function withdrawTokenEmergency(address _token, uint256 _amount) external;

    function withdrawTokenEmergencyFrom(address _from, address _to, address _currency, uint256 _amount) external;

    function getUserCommissionCanEarnUsdWithDecimal(
        address _user,
        uint256 _totalCommissionInUsdDecimal
    ) external view returns (uint256);

    function transferNftEmergency(address _receiver, uint256 _nftId) external;

    function transferMultiNftsEmergency(address[] memory _receivers, uint256[] memory _nftIds) external;

    function setOracleAddress(address _oracleAddress) external;

    function setEarnContract(address _earnContract) external;

    function setStakeTokenContract(address _stakeTokenContract) external;

    function setMaintenanceContract(address _maintenanceContract) external;

    function removeStakeEmergency(address _user, uint256[] memory _stakeIds) external;

    function setMarketCommission(address _currentRef, uint256 _commissionUsdWithDecimal) external;

    function getCommissionProfitUnclaim(address _user) external view returns (uint256);

    function getSaleAddresses() external view returns (address[] memory);

    function setSaleAddress(address[] memory _saleAddress) external;

    function checkUserIsSaleAddress(address _user) external view returns (bool);

    function setStakingLimit(uint256 _monthLimit) external;
}
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

interface IMarketplaceSmall {
    function getNftSaleValueForAccountInUsdDecimal(address _wallet) external view returns (uint256);
}

contract InternalSwap is Ownable {
    uint256 public constant SECONDS_PER_DAY = 86400;

    uint256 private usdtAmount = 1000000;
    uint256 private tokenAmount = 223914;
    address public currency;
    address public tokenAddress;
    address public marketContract = 0x19087bA21Fa8489ff1bEbe6188498a502436fd80;
    uint8 private typeSwap = 2; //0: all, 1: usdt -> token only, 2: token -> usdt only
    bool public onlyBuyerCanSwap = true;

    uint256 private limitDay = 1;
    uint256 private limitValue = 150;
    uint256 private _taxSellFee = 500;
    uint256 private _taxBuyFee = 500;
    address private _taxAddress = 0x490aAab021A3354AfcBA4A8DfB8cC3ffC24Beb32;

    mapping(address => bool) private _addressBuyExcludeTaxFee;
    mapping(address => bool) private _addressSellExcludeHasTaxFee;
    mapping(address => bool) public swapWhiteList;

    // wallet -> date buy -> total amount
    mapping(address => mapping(uint256 => uint256)) private _sellAmounts;

    address private contractOwner;
    uint256 private unlocked = 1;

    event ChangeRate(uint256 _usdtAmount, uint256 _tokenAmount, uint256 _time);

    constructor(address _stableToken, address _tokenAddress) {
        currency = _stableToken;
        tokenAddress = _tokenAddress;
        contractOwner = _msgSender();
    }

    modifier checkOwner() {
        require(owner() == _msgSender() || contractOwner == _msgSender(), "SWAP: CALLER IS NOT THE OWNER");
        _;
    }

    modifier canSwap() {
        require(!onlyBuyerCanSwap || swapWhiteList[msg.sender] || isBuyer(msg.sender), "SWAP: CALLER CAN NOT SWAP");
        _;
    }

    modifier lock() {
        require(unlocked == 1, "SWAP: LOCKED");
        unlocked = 0;
        _;
        unlocked = 1;
    }

    function isBuyer(address _wallet) public view returns (bool) {
        require(marketContract != address(0), "SWAP: MARKETPLACE CONTRACT IS ZERO ADDRESS");
        return IMarketplaceSmall(marketContract).getNftSaleValueForAccountInUsdDecimal(_wallet) > 0;
    }

    function getLimitDay() external view returns (uint256) {
        return limitDay;
    }

    function getUsdtAmount() external view returns (uint256) {
        return usdtAmount;
    }

    function getTokenAmount() external view returns (uint256) {
        return tokenAmount;
    }

    function getLimitValue() external view returns (uint256) {
        return limitValue;
    }

    function getTaxSellFee() external view returns (uint256) {
        return _taxSellFee;
    }

    function getTaxBuyFee() external view returns (uint256) {
        return _taxBuyFee;
    }

    function getTaxAddress() external view returns (address) {
        return _taxAddress;
    }

    function getTypeSwap() external view returns (uint8) {
        return typeSwap;
    }

    function setCurrency(address _currency) external checkOwner {
        currency = _currency;
    }

    function setTokenAddress(address _tokenAddress) external checkOwner {
        tokenAddress = _tokenAddress;
    }

    function setMarketContract(address _marketContract) external checkOwner {
        marketContract = _marketContract;
    }

    function setLimitDay(uint256 _limitDay) external checkOwner {
        limitDay = _limitDay;
    }

    function setLimitValue(uint256 _limitValue) external checkOwner {
        limitValue = _limitValue;
    }

    function setOnlyBuyerCanSwap(bool _onlyBuyerCanSwap) external checkOwner {
        onlyBuyerCanSwap = _onlyBuyerCanSwap;
    }

    function setSwapWhiteList(address _walletAddress, bool _isSwapWhiteList) external checkOwner {
        swapWhiteList[_walletAddress] = _isSwapWhiteList;
    }

    function setTaxSellFeePercent(uint256 taxFeeBps) external checkOwner {
        _taxSellFee = taxFeeBps;
    }

    function setTaxBuyFeePercent(uint256 taxFeeBps) external checkOwner {
        _taxBuyFee = taxFeeBps;
    }

    function setTaxAddress(address taxAddress) external checkOwner {
        _taxAddress = taxAddress;
    }

    function setAddressBuyExcludeTaxFee(address account, bool excludeFee) external checkOwner {
        _addressBuyExcludeTaxFee[account] = excludeFee;
    }

    function setAddressSellExcludeTaxFee(address account, bool excludeFee) external checkOwner {
        _addressSellExcludeHasTaxFee[account] = excludeFee;
    }

    function setPriceData(uint256 _usdtAmount, uint256 _tokenAmount) external checkOwner {
        require(_usdtAmount > 0 && _tokenAmount > 0, "SWAP: INVALID DATA");
        usdtAmount = _usdtAmount;
        tokenAmount = _tokenAmount;
        emit ChangeRate(_usdtAmount, _tokenAmount, block.timestamp);
    }

    function setPriceType(uint8 _type) external checkOwner {
        require(_type <= 2, "SWAP: INVALID TYPE SWAP (0, 1, 2)");
        typeSwap = _type;
    }

    function checkCanSellToken(address _wallet, uint256 _tokenValue) internal view returns (bool) {
        if (limitValue == 0 || limitDay == 0) {
            return true;
        }

        uint256 currentDate = block.timestamp / (limitDay * SECONDS_PER_DAY);
        uint256 valueAfterSell = _sellAmounts[_wallet][currentDate] + _tokenValue;
        uint256 maxValue = (limitValue * (10 ** ERC20(tokenAddress).decimals()) * tokenAmount) / usdtAmount;

        if (valueAfterSell > maxValue) {
            return false;
        }

        return true;
    }

    function buyToken(uint256 _usdtValue) external lock canSwap {
        require(typeSwap == 1 || typeSwap == 0, "SWAP: CANNOT BUY TOKEN NOW");
        require(_usdtValue > 0, "SWAP: INVALID VALUE");

        uint256 buyFee = 0;
        uint256 amountTokenDecimal = (_usdtValue * tokenAmount) / usdtAmount;
        if (_taxBuyFee != 0 && !_addressBuyExcludeTaxFee[msg.sender]) {
            buyFee = (amountTokenDecimal * _taxBuyFee) / 10000;
            amountTokenDecimal = amountTokenDecimal - buyFee;
        }

        if (amountTokenDecimal != 0) {
            require(ERC20(currency).balanceOf(msg.sender) >= _usdtValue, "SWAP: NOT ENOUGH BALANCE CURRENCY TO BUY");
            require(ERC20(currency).allowance(msg.sender, address(this)) >= _usdtValue, "SWAP: MUST APPROVE FIRST");
            require(ERC20(currency).transferFrom(msg.sender, address(this), _usdtValue), "SWAP: FAIL TO SWAP");

            require(ERC20(tokenAddress).transfer(msg.sender, amountTokenDecimal), "SWAP: FAIL TO SWAP");
            if (buyFee != 0) {
                require(ERC20(tokenAddress).transfer(_taxAddress, buyFee), "SWAP: FAIL TO SWAP");
            }
        }
    }

    function sellToken(uint256 _tokenValue) external lock canSwap {
        require(typeSwap == 2 || typeSwap == 0, "SWAP: CANNOT SELL TOKEN NOW");
        require(_tokenValue > 0, "SWAP: INVALID VALUE");
        require(checkCanSellToken(msg.sender, _tokenValue), "SWAP: MAXIMUM SWAP TODAY");

        uint256 sellFee = 0;
        if (_taxSellFee != 0 && !_addressSellExcludeHasTaxFee[msg.sender]) {
            sellFee = (_tokenValue * _taxSellFee) / 10000;
        }
        uint256 amountUsdtDecimal = ((_tokenValue - sellFee) * usdtAmount) / tokenAmount;

        if (amountUsdtDecimal != 0) {
            require(ERC20(tokenAddress).balanceOf(msg.sender) >= _tokenValue, "SWAP: NOT ENOUGH BALANCE TOKEN TO SELL");
            require(ERC20(tokenAddress).allowance(msg.sender, address(this)) >= _tokenValue, "SWAP: MUST APPROVE FIRST");
            require(ERC20(tokenAddress).transferFrom(msg.sender, address(this), _tokenValue), "SWAP: FAIL TO SWAP");
            require(ERC20(currency).transfer(msg.sender, amountUsdtDecimal), "SWAP: FAIL TO SWAP");

            if (sellFee != 0) {
                require(ERC20(tokenAddress).transfer(_taxAddress, sellFee), "SWAP: FAIL TO SWAP");
            }

            if (limitDay > 0) {
                uint256 currentDate = block.timestamp / (limitDay * SECONDS_PER_DAY);
                _sellAmounts[msg.sender][currentDate] = _sellAmounts[msg.sender][currentDate] + _tokenValue;
            }
        }
    }

    function setContractOwner(address _newContractOwner) external checkOwner {
        contractOwner = _newContractOwner;
    }

    function recoverBNB(uint256 _amount) public checkOwner {
        require(_amount > 0, "INVALID AMOUNT");
        address payable recipient = payable(msg.sender);
        recipient.transfer(_amount);
    }

    function withdrawTokenEmergency(address _token, uint256 _amount) public checkOwner {
        require(_amount > 0, "INVALID AMOUNT");
        require(IERC20(_token).transfer(msg.sender, _amount), "CANNOT WITHDRAW TOKEN");
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

interface ITokenStakeApy {
    function setNftApy(uint256 _poolId, uint256 _poolIdEarnPerDay) external;
    
    function setNftApyExactly(uint256 _poolId, uint256[] calldata _startTime, uint256[] calldata _endTime, uint256[] calldata _tokenEarn) external;

    function getStartTime(uint256 _poolId) external view returns (uint256[] memory);

    function getEndTime(uint256 _poolId) external view returns (uint256[] memory);

    function getPoolApy(uint256 _poolId) external view returns (uint256[] memory);

    function getMaxIndex(uint256 _poolId) external view returns (uint256);
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

import "../data/StructData.sol";

interface ITokenStake {
    event Staked(uint256 indexed id, uint256 poolId, address indexed staker, uint256 stakeValue, uint256 startTime, uint256 unlockTime);

    event Claimed(uint256 indexed id, address indexed staker, uint256 claimAmount);

    event Harvested(uint256 indexed id);

    function getCommissionPercent(uint8 _level) external view returns (uint16);

    function setCommissionPercent(uint8 _level, uint16 _percent) external;

    function getCommissionCondition(uint8 _level) external view returns (uint32);

    function setCommissionCondition(uint8 _level, uint32 _conditionInUsd) external;

    function setTimeOpenStaking(uint256 _timeOpening) external;

    function setMarketContract(address _marketContract) external;

    function setApyContract(address _tokenStakeApy) external;

    function setOracleContract(address _oracleContract) external;

    function setStakingContract(address _stakingContract) external;

    function setStakeTokenPool(uint256 _poolId, uint256 _maxStakePerWallet, uint256 _duration, bool _isPayProfit, address _stakeToken, address _earnToken) external;

    function getStakeTokenPool(uint256 _poolId) external view returns (StructData.StakeTokenPools memory);

    function setTotalStakedToken(uint256 _totalStakedToken) external;

    function setTotalWithdrawToken(uint256 _totalWithdrawToken) external;

    function setTotalClaimedToken(uint256 _totalClaimedToken) external;

    function setTotalUserStakedToken(uint256 _totalStakedToken, address _userId) external;

    function setTotalUserWithdrawToken(uint256 _totalUserWithdrawToken, address _userId) external;

    function setTotalUserClaimedToken(uint256 _totalClaimedToken, address _userId) external;

    function getTotalUserStakedToken(address _userId) external returns (uint256);

    function getTotalUserWithdrawToken(address _userId) external returns (uint256);

    function getTotalUserClaimedToken(address _userId) external returns (uint256);

    function setUserStakedPoolToken(address _user, uint256 _poolId, uint256 _totalUserStakedPoolToken) external;

    function getUserStakedPoolToken(address _user, uint256 _poolId) external view returns (uint256);

    function stake(uint256 _poolId, uint256 _stakeValue) external;

    function claimAll(uint256[] memory _poolIds) external;

    function claim(uint256 _poolId) external;

    function possibleForCommission(address _staker, uint8 _level) external view returns (bool);

    function calculateTokenEarnedStake(uint256 _stakeId) external view returns (uint256);

    function calculateTokenEarnedMulti(uint256[] memory _stakeIds) external view returns (uint256);

    function withdraw(uint256 _stakeId) external;

    function withdrawPool(uint256[] memory _stakeIds) external;

    function claimPool(uint256[] memory _stakeIds) external;

    function getStakedToken(uint256 _stakeId) external view returns (StructData.StakedToken memory);

    function setStakedToken(uint256 _stakeId, uint256 _poolId, address _userAddress, uint256 _startTime, uint256 _unlockTime, uint256 _totalValueStake, uint256 _totalValueClaimed, bool _isWithdraw) external;

    function addStakedToken(uint256 _poolId, address _userAddress, uint256 _totalValueStake) external;

    function getTeamStakingValue(address _wallet) external view returns (uint256);

    function getRefClaimed(address _wallet) external view returns (uint256);

    function withdrawTokenEmergency(address _token, uint256 _amount) external;

    function recoverLostBNB() external;
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";
import "./ITokenStake.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "../token_stake_apy/ITokenStakeApy.sol";
import "../market/IMarketplace.sol";
import "../oracle/Oracle.sol";
import "../stake/IStaking.sol";
import "../data/StructData.sol";
import "../token/NovaXERC20.sol";

contract TokenStake is ITokenStake, Ownable, ERC721Holder {
    uint256 public timeOpenStaking = 1689786000;
    uint private unlocked = 1;
    uint256 public tokenDecimal = 1000000000000000000;

    address public novaxToken;
    address public tokenStakeApy;
    address public marketplaceContract;
    address public oracleContract;
    address public stakingContract;

    // mapping to store amount staked to get reward
    mapping(uint8 => uint32) public amountConditions;

    // mapping to store commission percent when ref claim staking token
    mapping(uint32 => uint16) public commissionPercents;

    // mapping to store staked NFT information
    uint256 public totalStakedToken;
    uint256 public totalWithdrawToken;
    uint256 public totalClaimedToken;
    uint256 public stakeTokenPoolLength = 6;
    uint256 private stakeIndex = 0;

    mapping(uint256 => StructData.StakeTokenPools) private stakeTokenPools;
    mapping(uint256 => StructData.StakedToken) private stakedToken;
    mapping(address => uint256) private totalUserStakedToken;
    mapping(address => uint256) private teamStakingValue;
    mapping(address => uint256) private refClaimed;
    mapping(address => uint256) private totalUserWithdrawToken;
    mapping(address => mapping (uint256 => uint256)) private totalUserStakedPoolToken;
    mapping(address => uint256) private totalUserClaimedToken;


    constructor(address _novaxToken, address _tokenStakeApy, address _marketplaceContract, address _oracleContract, address _stakingContract) {
        novaxToken = _novaxToken;
        tokenStakeApy = _tokenStakeApy;
        marketplaceContract = _marketplaceContract;
        oracleContract = _oracleContract;
        stakingContract = _stakingContract;
        initStakePool();
        initCommissionConditionUsd();
        initCommissionPercents();
    }

    modifier isTimeForStaking() {
        require(block.timestamp >= timeOpenStaking, "TOKEN STAKING: THE STAKING PROGRAM HAS NOT YET STARTED.");
        _;
    }

    modifier lock() {
        require(unlocked == 1, "TOKEN STAKING: LOCKED");
        unlocked = 0;
        _;
        unlocked = 1;
    }

    /**
     * @dev init stake pool default
     */
    function initStakePool() internal {
        stakeTokenPools[0].poolId = 0;
        stakeTokenPools[0].maxStakePerWallet = 0;
        stakeTokenPools[0].duration = 0;
        stakeTokenPools[0].isPayProfit = false;
        stakeTokenPools[0].stakeToken = novaxToken;
        stakeTokenPools[0].earnToken = novaxToken;

        stakeTokenPools[1].poolId = 1;
        stakeTokenPools[1].maxStakePerWallet = 1000000000000000000000;
        stakeTokenPools[1].duration = 1;
        stakeTokenPools[1].isPayProfit = true;
        stakeTokenPools[1].stakeToken = novaxToken;
        stakeTokenPools[1].earnToken = novaxToken;

        stakeTokenPools[2].poolId = 2;
        stakeTokenPools[2].maxStakePerWallet = 3000000000000000000000;
        stakeTokenPools[2].duration = 3;
        stakeTokenPools[2].isPayProfit = true;
        stakeTokenPools[2].stakeToken = novaxToken;
        stakeTokenPools[2].earnToken = novaxToken;

        stakeTokenPools[3].poolId = 3;
        stakeTokenPools[3].maxStakePerWallet = 0;
        stakeTokenPools[3].duration = 6;
        stakeTokenPools[3].isPayProfit = true;
        stakeTokenPools[3].stakeToken = novaxToken;
        stakeTokenPools[3].earnToken = novaxToken;

        stakeTokenPools[4].poolId = 4;
        stakeTokenPools[4].maxStakePerWallet = 0;
        stakeTokenPools[4].duration = 12;
        stakeTokenPools[4].isPayProfit = true;
        stakeTokenPools[4].stakeToken = novaxToken;
        stakeTokenPools[4].earnToken = novaxToken;

        stakeTokenPools[5].poolId = 5;
        stakeTokenPools[5].maxStakePerWallet = 0;
        stakeTokenPools[5].duration = 24;
        stakeTokenPools[5].isPayProfit = true;
        stakeTokenPools[5].stakeToken = novaxToken;
        stakeTokenPools[5].earnToken = novaxToken;
    }

    /**
     * @dev init condition(staked amount) to get commission for each level
     */
    function initCommissionConditionUsd() internal {
        amountConditions[0] = 0;
        amountConditions[1] = 500;
        amountConditions[2] = 1000;
        amountConditions[3] = 2000;
        amountConditions[4] = 3000;
        amountConditions[5] = 4000;
        amountConditions[6] = 5000;
        amountConditions[7] = 6000;
    }

    /**
     * @dev init commission percent when ref claim staking token
     */
    function initCommissionPercents() internal {
        commissionPercents[0] = 1500;
        commissionPercents[1] = 1000;
        commissionPercents[2] = 500;
        commissionPercents[3] = 500;
        commissionPercents[4] = 400;
        commissionPercents[5] = 300;
        commissionPercents[6] = 200;
        commissionPercents[7] = 100;
    }

    function setTotalStakedToken(uint256 _totalStakedToken) external override onlyOwner {
        totalStakedToken = _totalStakedToken;
    }

    function setTotalWithdrawToken(uint256 _totalWithdrawToken) external override onlyOwner {
        totalWithdrawToken = _totalWithdrawToken;
    }

    function setTotalClaimedToken(uint256 _totalClaimedToken) external override onlyOwner {
        totalClaimedToken = _totalClaimedToken;
    }

    function setTotalUserStakedToken(uint256 _totalStakedToken, address _userId) external override onlyOwner {
        totalUserStakedToken[_userId] = _totalStakedToken;
    }

    function setTotalUserWithdrawToken(uint256 _totalUserWithdrawToken, address _userId) external override onlyOwner {
        totalUserWithdrawToken[_userId] = _totalUserWithdrawToken;
    }

    function setTotalUserClaimedToken(uint256 _totalClaimedToken, address _userId) external override onlyOwner {
        totalUserClaimedToken[_userId] = _totalClaimedToken;
    }

    function getTotalUserStakedToken(address _userId) public view override returns (uint256) {
        return totalUserStakedToken[_userId];
    }

    function getTotalUserWithdrawToken(address _userId) public view override returns (uint256) {
        return totalUserWithdrawToken[_userId];
    }

    function getTotalUserClaimedToken(address _userId) public view override returns (uint256) {
        return totalUserClaimedToken[_userId];
    }

    function setUserStakedPoolToken(address _user, uint256 _poolId, uint256 _totalUserStakedPoolToken) external override onlyOwner {
        totalUserStakedPoolToken[_user][_poolId] = _totalUserStakedPoolToken;
    }

    function getUserStakedPoolToken(address _user, uint256 _poolId) public view override returns (uint256) {
        return totalUserStakedPoolToken[_user][_poolId];
    }

    /**
     * @dev function to get commission condition
     * @param _level commission level
     */
    function getCommissionPercent(uint8 _level) public view override returns (uint16) {
        return commissionPercents[_level];
    }

    /**
     * @dev function to set commission percent
     * @param _level commission level
     * @param _percent commission percent value want to set (0-100)
     */
    function setCommissionPercent(uint8 _level, uint16 _percent) external override onlyOwner {
        commissionPercents[_level] = _percent;
    }

    /**
     * @dev function to get commission condition
     * @param _level commission level
     */
    function getCommissionCondition(uint8 _level) external view override returns (uint32) {
        return amountConditions[_level];
    }

    /**
     * @dev function to set commission condition
     * @param _level commission level
     * @param _conditionInUsd threshold in USD that the commissioner must achieve
     */
    function setCommissionCondition(uint8 _level, uint32 _conditionInUsd) external override onlyOwner {
        amountConditions[_level] = _conditionInUsd;
    }

    /**
     * @dev set time open staking program
     */
    function setTimeOpenStaking(uint256 _timeOpening) external override onlyOwner {
        require(block.timestamp < _timeOpening, "TOKEN STAKING: INVALID TIME OPENING.");
        timeOpenStaking = _timeOpening;
    }

    function setMarketContract(address _marketContract) external override onlyOwner {
        marketplaceContract = _marketContract;
    }


    function setApyContract(address _tokenStakeApy) external override onlyOwner {
        tokenStakeApy = _tokenStakeApy;
    }

    function setOracleContract(address _oracleContract) external override onlyOwner {
        oracleContract = _oracleContract;
    }

    function setStakingContract(address _stakingContract) external override onlyOwner {
        stakingContract = _stakingContract;
    }

    /**
     * @dev set stake token pool
     */
    function setStakeTokenPool(uint256 _poolId, uint256 _maxStakePerWallet, uint256 _duration, bool _isPayProfit, address _stakeToken, address _earnToken) external override onlyOwner {
        stakeTokenPools[_poolId].poolId = _poolId;
        stakeTokenPools[_poolId].maxStakePerWallet = _maxStakePerWallet;
        stakeTokenPools[_poolId].duration = _duration;
        stakeTokenPools[_poolId].isPayProfit = _isPayProfit;
        stakeTokenPools[_poolId].stakeToken = _stakeToken;
        stakeTokenPools[_poolId].earnToken = _earnToken;
        uint256 _index = _poolId + 1;
        if (_index > stakeTokenPoolLength) {
            stakeTokenPoolLength = _index;
        }
    }

    /**
     * @dev get stake token pool
     */
    function getStakeTokenPool(uint256 _poolId) public view override returns (StructData.StakeTokenPools memory) {
        StructData.StakeTokenPools memory _stakeTokenPool = stakeTokenPools[_poolId];

        return _stakeTokenPool;
    }

    function getStakedToken(uint256 _stakeId) public view override returns (StructData.StakedToken memory) {
        return stakedToken[_stakeId];
    }

    /**
     * @dev set stake token information
     */
    function setStakedToken(uint256 _stakeId, uint256 _poolId, address _userAddress, uint256 _startTime, uint256 _unlockTime, uint256 _totalValueStake, uint256 _totalValueClaimed, bool _isWithdraw) external override onlyOwner {
        stakedToken[_stakeId].stakeId = _stakeId;
        stakedToken[_stakeId].poolId = _poolId;
        stakedToken[_stakeId].userAddress = _userAddress;
        stakedToken[_stakeId].startTime = _startTime;
        stakedToken[_stakeId].unlockTime = _unlockTime;
        stakedToken[_stakeId].totalValueStake = _totalValueStake;
        stakedToken[_stakeId].totalValueClaimed = _totalValueClaimed;
        stakedToken[_stakeId].isWithdraw = _isWithdraw;
    }

    function addStakedToken(uint256 _poolId, address _userAddress, uint256 _totalValueStake) external override onlyOwner {
        uint256 totalUserStakePool = totalUserStakedPoolToken[_userAddress][_poolId] + _totalValueStake;
        require(
            stakeTokenPools[_poolId].maxStakePerWallet == 0 || stakeTokenPools[_poolId].maxStakePerWallet >= totalUserStakePool,
            "TOKEN STAKE: User stake max value of token"
        );
        uint256 unlockTimeEstimate = stakeTokenPools[_poolId].duration == 0 ? 0 : (block.timestamp + (2592000 * stakeTokenPools[_poolId].duration));
        stakeIndex = stakeIndex + 1;
        stakedToken[stakeIndex].stakeId = stakeIndex;
        stakedToken[stakeIndex].poolId = _poolId;
        stakedToken[stakeIndex].userAddress = _userAddress;
        stakedToken[stakeIndex].startTime = block.timestamp;
        stakedToken[stakeIndex].unlockTime = unlockTimeEstimate;
        stakedToken[stakeIndex].totalValueStake = _totalValueStake;
        stakedToken[stakeIndex].totalValueClaimed = 0;
        stakedToken[stakeIndex].isWithdraw = false;
        totalUserStakedPoolToken[_userAddress][_poolId] = totalUserStakePool;
        stakeTokenPools[_poolId].totalStake += _totalValueStake;
        totalStakedToken += _totalValueStake;
        totalUserStakedToken[_userAddress] += _totalValueStake;
        address currentRef = IMarketplace(marketplaceContract).getReferralAccountForAccount(_userAddress);
        updateCrewInvestmentData(currentRef, _totalValueStake);
        emit Staked(stakeIndex, _poolId, _userAddress, _totalValueStake, block.timestamp, unlockTimeEstimate);
    }

    function stake(uint256 _poolId, uint256 _stakeValue) external override lock() {
        require(
            NovaXERC20(stakeTokenPools[_poolId].stakeToken).balanceOf(msg.sender) >= _stakeValue,
            "TOKEN STAKE: Not enough balance to stake"
        );
        require(
            NovaXERC20(stakeTokenPools[_poolId].stakeToken).allowance(msg.sender, address(this)) >= _stakeValue,
            "TOKEN STAKE: Must approve first"
        );
        require(
            NovaXERC20(stakeTokenPools[_poolId].stakeToken).transferFrom(msg.sender, address(this), _stakeValue),
            "TOKEN STAKE: Transfer token to TOKEN STAKE failed"
        );

        uint256 totalUserStakePool = totalUserStakedPoolToken[msg.sender][_poolId] + _stakeValue;
        require(
            stakeTokenPools[_poolId].maxStakePerWallet == 0 || stakeTokenPools[_poolId].maxStakePerWallet >= totalUserStakePool,
            "TOKEN STAKE: User stake max value of token"
        );

        // insert data staking
        stakeIndex = stakeIndex + 1;

        // if pool duration = 0 => no limit for stake time, can claim every time
        uint256 unlockTimeEstimate = stakeTokenPools[_poolId].duration == 0 ? 0 : (block.timestamp + (2592000 * stakeTokenPools[_poolId].duration));
        stakedToken[stakeIndex].stakeId = stakeIndex;
        stakedToken[stakeIndex].userAddress = msg.sender;
        stakedToken[stakeIndex].poolId = _poolId;
        stakedToken[stakeIndex].unlockTime = unlockTimeEstimate;
        stakedToken[stakeIndex].startTime = block.timestamp;
        stakedToken[stakeIndex].totalValueStake = _stakeValue;
        stakedToken[stakeIndex].totalValueClaimed = 0;
        stakedToken[stakeIndex].isWithdraw = false;

        // update fixed data
        totalUserStakedPoolToken[msg.sender][_poolId] = totalUserStakePool;
        stakeTokenPools[_poolId].totalStake += _stakeValue;
        totalStakedToken += _stakeValue;
        totalUserStakedToken[msg.sender] += _stakeValue;
        address currentRef = IMarketplace(marketplaceContract).getReferralAccountForAccount(msg.sender);
        updateCrewInvestmentData(currentRef, _stakeValue);
        emit Staked(stakeIndex, _poolId, msg.sender, _stakeValue, block.timestamp, unlockTimeEstimate);
    }

    function claimAll(uint256[] memory _stakeIds) external override  {
        require(_stakeIds.length > 0, "TOKEN STAKE: INVALID STAKE LIST");
        for (uint i = 0; i < _stakeIds.length; i++) {
            claim(_stakeIds[i]);
        }
    }

    function claimPool(uint256[] memory _stakeIds) external override {
        require(_stakeIds.length > 0, "TOKEN STAKE: INVALID STAKE LIST");
        for (uint i = 0; i < _stakeIds.length; i++) {
            claim(_stakeIds[i]);
        }
    }

    function claim(uint256 _stakeId) public override lock() {
        uint256 _totalTokenClaimDecimal = calculateTokenEarnedStake(_stakeId);
        StructData.StakedToken memory _stakedUserToken = stakedToken[_stakeId];
        require(
            _stakedUserToken.userAddress == msg.sender, "TOKEN STAKE: ONLY OWNER OF STAKE CAN CLAIM"
        );
        if (_totalTokenClaimDecimal > 0) {
            // transfer token to user and close stake pool
            require(
                IERC20(stakeTokenPools[stakedToken[_stakeId].poolId].earnToken).balanceOf(address(this)) >= _totalTokenClaimDecimal,
                "TOKEN STAKE: NOT ENOUGH TOKEN BALANCE TO PAY UNSTAKE REWARD"
            );
            require(
                IERC20(stakeTokenPools[stakedToken[_stakeId].poolId].earnToken).transfer(msg.sender, _totalTokenClaimDecimal),
                "TOKEN STAKE: UNABLE TO TRANSFER COMMISSION PAYMENT TO RECIPIENT"
            );

            // pay commission multi levels
            if (stakeTokenPools[stakedToken[_stakeId].poolId].isPayProfit) {
                address currentRef = IMarketplace(marketplaceContract).getReferralAccountForAccount(msg.sender);
                bool paidDirectSuccess = payCommissionMultiLevels(currentRef, _totalTokenClaimDecimal, stakeTokenPools[stakedToken[_stakeId].poolId].earnToken);
                require(paidDirectSuccess == true, "TOKEN STAKE: FAIL IN PAY COMMISSION FOR DIRECT REF");
            }
            stakeTokenPools[stakedToken[_stakeId].poolId].totalEarn += _totalTokenClaimDecimal;
            totalClaimedToken += _totalTokenClaimDecimal;
            stakedToken[_stakeId].totalValueClaimed += _totalTokenClaimDecimal;
            totalUserClaimedToken[msg.sender] += _totalTokenClaimDecimal;

            emit Claimed(_stakeId, msg.sender, _totalTokenClaimDecimal);
        }
    }

    function claimInternal(uint256 _stakeId) internal {
        uint256 _totalTokenClaimDecimal = calculateTokenEarnedStake(_stakeId);
        StructData.StakedToken memory _stakedUserToken = stakedToken[_stakeId];
        require(
            _stakedUserToken.userAddress == msg.sender, "TOKEN STAKE: ONLY OWNER OF STAKE CAN CLAIM"
        );
        if (_totalTokenClaimDecimal > 0) {
            // transfer token to user and close stake pool
            require(
                IERC20(stakeTokenPools[stakedToken[_stakeId].poolId].earnToken).balanceOf(address(this)) >= _totalTokenClaimDecimal,
                "TOKEN STAKE: NOT ENOUGH TOKEN BALANCE TO PAY UNSTAKE REWARD"
            );
            require(
                IERC20(stakeTokenPools[stakedToken[_stakeId].poolId].earnToken).transfer(msg.sender, _totalTokenClaimDecimal),
                "TOKEN STAKE: UNABLE TO TRANSFER COMMISSION PAYMENT TO RECIPIENT"
            );

            // pay commission multi levels
            if (stakeTokenPools[stakedToken[_stakeId].poolId].isPayProfit) {
                address currentRef = IMarketplace(marketplaceContract).getReferralAccountForAccount(msg.sender);
                bool paidDirectSuccess = payCommissionMultiLevels(currentRef, _totalTokenClaimDecimal, stakeTokenPools[stakedToken[_stakeId].poolId].earnToken);
                require(paidDirectSuccess == true, "TOKEN STAKE: FAIL IN PAY COMMISSION FOR DIRECT REF");
            }

            stakeTokenPools[stakedToken[_stakeId].poolId].totalEarn += _totalTokenClaimDecimal;
            totalClaimedToken += _totalTokenClaimDecimal;
            stakedToken[_stakeId].totalValueClaimed += _totalTokenClaimDecimal;
            totalUserClaimedToken[msg.sender] += _totalTokenClaimDecimal;

            emit Claimed(_stakeId, msg.sender, _totalTokenClaimDecimal);
        }
    }

    /**
     * @dev function to pay commissions in 10 level
     * @param _firstRef direct referral account wallet address
     * @param _totalAmountStakeTokenWithDecimal total amount stake in token with decimal for this stake
     */
    function payCommissionMultiLevels(
        address _firstRef,
        uint256 _totalAmountStakeTokenWithDecimal,
        address earnToken
    ) internal returns (bool) {
        address currentRef = _firstRef;
        uint8 index = 0;
        while (currentRef != address(0) && index < 8) {
            // Check if ref account is eligible to staked amount enough for commission
            bool totalStakeAmount = possibleForCommission(currentRef, index);
            if (totalStakeAmount) {
                // Transfer commission in token amount
                uint256 commissionPercent = getCommissionPercent(index);
                uint256 totalCommissionInTokenDecimal = (_totalAmountStakeTokenWithDecimal * commissionPercent) / 10000;
                uint256 _commissionInUsdWithDecimal = (totalCommissionInTokenDecimal * tokenDecimal) /
                    Oracle(oracleContract).convertUsdBalanceDecimalToTokenDecimal(tokenDecimal);
                // calculate max commission can earn
                uint256 _commissionCanEarnUsdWithDecimal = IStaking(stakingContract).getUserCommissionCanEarnUsdWithDecimal(currentRef, _commissionInUsdWithDecimal);
                if (_commissionCanEarnUsdWithDecimal > 0) {
                    totalCommissionInTokenDecimal = Oracle(oracleContract).convertUsdBalanceDecimalToTokenDecimal(
                        _commissionCanEarnUsdWithDecimal
                    );
                    require(totalCommissionInTokenDecimal > 0, "STAKING: INVALID TOKEN BALANCE COMMISSION");
                    require(
                        IERC20(earnToken).balanceOf(address(this)) >= totalCommissionInTokenDecimal,
                        "STAKING: NOT ENOUGH TOKEN BALANCE TO PAY COMMISSION"
                    );
                    require(
                        IERC20(earnToken).transfer(currentRef, totalCommissionInTokenDecimal),
                        "STAKING: UNABLE TO TRANSFER COMMISSION PAYMENT TO RECIPIENT"
                    );
                    uint256 currentRefValue = refClaimed[currentRef];
                    refClaimed[currentRef] = currentRefValue + totalCommissionInTokenDecimal;
                    // update market contract
                    IStaking(stakingContract).setMarketCommission(currentRef, _commissionCanEarnUsdWithDecimal);
                }
            }
            index++;
            currentRef = IMarketplace(marketplaceContract).getReferralAccountForAccount(currentRef);
        }
        return true;
    }

    /**
     * @dev function to check the staked amount enough to get commission
     * @param _staker staker wallet address
     * @param _level commission level need to check condition
     */
    function possibleForCommission(address _staker, uint8 _level) public view returns (bool) {
        uint256 totalStakeAmount = IMarketplace(marketplaceContract).getNftSaleValueForAccountInUsdDecimal(_staker);
        totalStakeAmount = totalStakeAmount / tokenDecimal;
        uint32 conditionAmount = amountConditions[_level];
        if (totalStakeAmount >= conditionAmount) {
            return true;
        }
        return false;
    }

    function calculateTokenEarnedStake(uint256 _stakeId) public view override returns (uint256) {
        StructData.StakedToken memory _stakedUserToken = stakedToken[_stakeId];
        if (_stakedUserToken.isWithdraw) {
            return 0;
        }
        uint256 totalTokenClaimDecimal = 0;
        uint256 index = ITokenStakeApy(tokenStakeApy).getMaxIndex(_stakedUserToken.poolId);
        uint256 apy = 0;
        for (uint i = 0; i < index; i++) {
            uint256 startTime = ITokenStakeApy(tokenStakeApy).getStartTime(_stakedUserToken.poolId)[i];
            uint256 endTime = ITokenStakeApy(tokenStakeApy).getEndTime(_stakedUserToken.poolId)[i];
            apy = ITokenStakeApy(tokenStakeApy).getPoolApy(_stakedUserToken.poolId)[i];
            // calculate token claim for each stake pool
            startTime = startTime >= _stakedUserToken.startTime ? startTime : _stakedUserToken.startTime;
            // _stakedUserToken.unlockTime == 0 mean no limit for this pool
            uint256 timeDuration = _stakedUserToken.unlockTime == 0 ? block.timestamp :  (_stakedUserToken.unlockTime < block.timestamp ? _stakedUserToken.unlockTime : block.timestamp);
            endTime = endTime == 0 ? timeDuration : (endTime <= timeDuration ? endTime : timeDuration);

            if (startTime <= endTime) {
                totalTokenClaimDecimal += ((endTime - startTime) * apy * _stakedUserToken.totalValueStake) / 31104000 / 100000;
            }
        }

        totalTokenClaimDecimal = totalTokenClaimDecimal - _stakedUserToken.totalValueClaimed;

        return totalTokenClaimDecimal;
    }

    function calculateTokenEarnedMulti(uint256[] memory _stakeIds) public view override returns (uint256) {
        uint256 _totalTokenClaimDecimal = 0;
        for (uint i = 0; i < _stakeIds.length; i++) {
            _totalTokenClaimDecimal += calculateTokenEarnedStake(_stakeIds[i]);
        }

        return _totalTokenClaimDecimal;
    }

    function withdraw(uint256 _stakeId) public override lock() {
        StructData.StakedToken memory _stakedUserToken = stakedToken[_stakeId];
        require(
            _stakedUserToken.userAddress == msg.sender, "TOKEN STAKE: ONLY OWNER OF STAKE CAN WITHDRAW"
        );
        require(
            !_stakedUserToken.isWithdraw, "TOKEN STAKE: WITHDRAW FALSE"
        );
        // check stake can be harvested now
        if (_stakedUserToken.unlockTime <= block.timestamp) {
            claimInternal(_stakeId);
            require(
                IERC20(stakeTokenPools[_stakedUserToken.poolId].stakeToken).balanceOf(address(this)) >= _stakedUserToken.totalValueStake,
                "TOKEN STAKING: NOT ENOUGH TOKEN BALANCE TO PAY USER STAKE VALUE"
            );
            require(
                IERC20(stakeTokenPools[_stakedUserToken.poolId].stakeToken).transfer(_stakedUserToken.userAddress, _stakedUserToken.totalValueStake),
                "STAKING: UNABLE TO TRANSFER COMMISSION PAYMENT TO STAKE USER"
            );
            //update withdraw
            uint256 _poolId = _stakedUserToken.poolId;
            uint256 _value = _stakedUserToken.totalValueStake;
            uint256 totalUserStakePool = totalUserStakedPoolToken[msg.sender][_poolId] - _value;
            uint256 poolStakeValue = stakeTokenPools[_poolId].totalStake - _value;
            totalUserStakedPoolToken[msg.sender][_poolId] = totalUserStakePool;
            stakeTokenPools[_poolId].totalStake = poolStakeValue;
            totalWithdrawToken += _value;
            totalUserWithdrawToken[msg.sender] += _value;
            stakedToken[_stakeId].isWithdraw = true;
            address currentRef = IMarketplace(marketplaceContract).getReferralAccountForAccount(msg.sender);
            updateCrewInvestmentDataSub(currentRef, _value);
            emit Harvested(_stakeId);
        }
    }

    function withdrawPool(uint256[] memory _stakeIds) external override {
        require(_stakeIds.length > 0, "TOKEN STAKE: INVALID STAKE LIST");
        for (uint i = 0; i < _stakeIds.length; i++) {
            withdraw(_stakeIds[i]);
        }
    }

    function updateCrewInvestmentData(address nextRef, uint256 _totalAmountStakeUsdWithDecimal) internal {
        address currentRef;
        uint8 index = 1;
        while (currentRef != nextRef && nextRef != address(0) && index <= 8) {
            // Update Team Staking Value ( 100 level)
            currentRef = nextRef;
            uint256 currentStakingValue = teamStakingValue[currentRef];
            teamStakingValue[currentRef] = currentStakingValue + _totalAmountStakeUsdWithDecimal;
            index++;
            nextRef = payable(IMarketplace(marketplaceContract).getReferralAccountForAccount(currentRef));
        }
    }

    function updateCrewInvestmentDataSub(address nextRef, uint256 _totalAmountStakeUsdWithDecimal) internal {
        address currentRef;
        uint8 index = 1;
        while (currentRef != nextRef && nextRef != address(0) && index <= 8) {
            // Update Team Staking Value ( 100 level)
            currentRef = nextRef;
            uint256 currentStakingValue = teamStakingValue[currentRef];
            teamStakingValue[currentRef] = currentStakingValue - _totalAmountStakeUsdWithDecimal;
            index++;
            nextRef = payable(IMarketplace(marketplaceContract).getReferralAccountForAccount(currentRef));
        }
    }

    function getTeamStakingValue(address _wallet) external view override returns (uint256) {
        return teamStakingValue[_wallet];
    }

    function getRefClaimed(address _wallet) external view override returns (uint256) {
        return refClaimed[_wallet];
    }

    /**
 *   @dev Recover lost bnb and send it to the contract owner
     */
    function recoverLostBNB() public override onlyOwner {
        address payable recipient = payable(msg.sender);
        recipient.transfer(address(this).balance);
    }

    /**
     * @dev withdraw some token balance from contract to owner account
     */
    function withdrawTokenEmergency(address _token, uint256 _amount) public override onlyOwner {
        require(_amount > 0, "INVALID AMOUNT");
        require(NovaXERC20(_token).transfer(msg.sender, _amount), "CANNOT WITHDRAW TOKEN");
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (token/NovaXERC20.sol.sol.sol/NovaXERC20.sol.sol.sol)

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

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
 * conventional and does not conflict with the expectations of NovaXERC20.sol.sol
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
contract NovaXERC20 is Context, IERC20, IERC20Metadata, Ownable {
    using SafeMath for uint256;
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    address private _taxAddress;
    uint256 private _taxSellFee;
    uint256 private _taxBuyFee;
    mapping(address => bool) private _addressSellHasTaxFee;
    mapping(address => bool) private _addressBuyHasTaxFee;
    mapping(address => bool) private _addressBuyExcludeTaxFee;
    mapping(address => bool) private _addressSellExcludeHasTaxFee;

    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * All two of these values are immutable: they can only be set once during
     * construction.
     */
    constructor(string memory name_, string memory symbol_, address taxAddress_, uint16 taxFeeBps_) {
        _name = name_;
        _symbol = symbol_;
        _taxSellFee = taxFeeBps_;
        _taxAddress = taxAddress_;
        _taxBuyFee = 0;
    }

    function getTaxSellFee() public view returns (uint256) {
        return _taxSellFee;
    }

    function getTaxBuyFee() public view returns (uint256) {
        return _taxBuyFee;
    }

    function getTaxAddress() public view returns (address) {
        return _taxAddress;
    }

    function setTaxSellFeePercent(uint256 taxFeeBps) public onlyOwner {
        _taxSellFee = taxFeeBps;
    }

    function setTaxBuyFeePercent(uint256 taxFeeBps) public onlyOwner {
        _taxBuyFee = taxFeeBps;
    }

    function setTaxAddress(address taxAddress_) public onlyOwner {
        _taxAddress = taxAddress_;
    }

    function setAddressSellHasTaxFee(address account, bool hasFee) public onlyOwner {
        _addressSellHasTaxFee[account] = hasFee;
    }

    function isAddressSellHasTaxFee(address account) public view returns (bool) {
        return _addressSellHasTaxFee[account];
    }

    function setAddressBuyHasTaxFee(address account, bool hasFee) public onlyOwner {
        _addressBuyHasTaxFee[account] = hasFee;
    }

    function isAddressBuyHasTaxFee(address account) public view returns (bool) {
        return _addressBuyHasTaxFee[account];
    }

    function setAddressBuyExcludeTaxFee(address account, bool hasFee) public onlyOwner {
        _addressBuyExcludeTaxFee[account] = hasFee;
    }

    function setAddressSellExcludeTaxFee(address account, bool hasFee) public onlyOwner {
        _addressSellExcludeHasTaxFee[account] = hasFee;
    }

    function calculateSellTaxFee(uint256 _amount) private view returns (uint256) {
        return _amount.mul(_taxSellFee).div(10000);
    }

    function calculateBuyTaxFee(uint256 _amount) private view returns (uint256) {
        return _amount.mul(_taxBuyFee).div(10000);
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
     * required by the EIP. See the note at the beginning of {NovaXERC20.sol.sol}.
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
        uint256 amountToReceive = amount;
        uint256 amountToTax = 0;
        bool _isHasTaxSellFeeTransfer = _addressSellHasTaxFee[to];
        bool _isExcludeUserSell = _addressSellExcludeHasTaxFee[from];
        bool _isHasTaxBuyFeeTransfer = _addressBuyHasTaxFee[from];
        bool _isExcludeUserBuy = _addressBuyExcludeTaxFee[to];
        if (_taxAddress != address(0) && _isHasTaxSellFeeTransfer && _taxSellFee != 0 && !_isExcludeUserSell) {
            uint256 amountSellFee = calculateSellTaxFee(amount);
            amountToReceive = amount - amountSellFee;
            amountToTax = amountToTax + amountSellFee;
        }
        if (_taxAddress != address(0) && _isHasTaxBuyFeeTransfer && _taxBuyFee != 0 && !_isExcludeUserBuy) {
            uint256 amountBuyFee = calculateBuyTaxFee(amount);
            amountToReceive = amount - amountBuyFee;
            amountToTax = amountToTax + amountBuyFee;
        }
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
            _balances[_taxAddress] += amountToTax; //increase tax Address tax Fee
            _balances[to] += amountToReceive;
        }
        emit Transfer(from, to, amountToReceive);
        if (amountToTax != 0) {
            emit Transfer(from, _taxAddress, amountToTax);
        }
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
