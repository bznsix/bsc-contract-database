// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

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
    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
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
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}
// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

/**
 * @dev Elliptic Curve Digital Signature Algorithm (ECDSA) operations.
 *
 * These functions can be used to verify that a message was signed by the holder
 * of the private keys of a given address.
 */
library ECDSA {
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
        // Check the signature length
        if (signature.length != 65) {
            revert("ECDSA: invalid signature length");
        }

        // Divide the signature in r, s and v variables
        bytes32 r;
        bytes32 s;
        uint8 v;

        // ecrecover takes the signature parameters, and the only way to get them
        // currently is to use assembly.
        // solhint-disable-next-line no-inline-assembly
        assembly {
            r := mload(add(signature, 0x20))
            s := mload(add(signature, 0x40))
            v := byte(0, mload(add(signature, 0x60)))
        }

        return recover(hash, v, r, s);
    }

    /**
     * @dev Overload of {ECDSA-recover-bytes32-bytes-} that receives the `v`,
     * `r` and `s` signature fields separately.
     */
    function recover(bytes32 hash, uint8 v, bytes32 r, bytes32 s) internal pure returns (address) {
        // EIP-2 still allows signature malleability for ecrecover(). Remove this possibility and make the signature
        // unique. Appendix F in the Ethereum Yellow paper (https://ethereum.github.io/yellowpaper/paper.pdf), defines
        // the valid range for s in (281): 0 < s < secp256k1n ÷ 2 + 1, and for v in (282): v ∈ {27, 28}. Most
        // signatures from current libraries generate a unique signature with an s-value in the lower half order.
        //
        // If your library generates malleable signatures, such as s-values in the upper range, calculate a new s-value
        // with 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141 - s1 and flip v from 27 to 28 or
        // vice versa. If your library also generates signatures with 0/1 for v instead 27/28, add 27 to v to accept
        // these malleable signatures as well.
        require(uint256(s) <= 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0, "ECDSA: invalid signature 's' value");
        require(v == 27 || v == 28, "ECDSA: invalid signature 'v' value");

        // If the signature is valid (and not malleable), return the signer address
        address signer = ecrecover(hash, v, r, s);
        require(signer != address(0), "ECDSA: invalid signature");

        return signer;
    }

    /**
     * @dev Returns an Ethereum Signed Message, created from a `hash`. This
     * replicates the behavior of the
     * https://github.com/ethereum/wiki/wiki/JSON-RPC#eth_sign[`eth_sign`]
     * JSON-RPC method.
     *
     * See {recover}.
     */
    function toEthSignedMessageHash(bytes32 hash) internal pure returns (bytes32) {
        // 32 is the length in bytes of hash,
        // enforced by the type signature above
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    }
}
// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

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
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        uint256 c = a + b;
        if (c < a) return (false, 0);
        return (true, c);
    }

    /**
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b > a) return (false, 0);
        return (true, a - b);
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) return (true, 0);
        uint256 c = a * b;
        if (c / a != b) return (false, 0);
        return (true, c);
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b == 0) return (false, 0);
        return (true, a / b);
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b == 0) return (false, 0);
        return (true, a % b);
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
        require(b <= a, "SafeMath: subtraction overflow");
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
        if (a == 0) return 0;
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
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
        require(b > 0, "SafeMath: division by zero");
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
        require(b > 0, "SafeMath: modulo by zero");
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
        require(b <= a, errorMessage);
        return a - b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryDiv}.
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
        require(b > 0, errorMessage);
        return a / b;
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
        require(b > 0, errorMessage);
        return a % b;
    }
}
// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

import "../../utils/Context.sol";
import "./IERC20.sol";
import "../../math/SafeMath.sol";

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
 * We have followed general OpenZeppelin guidelines: functions revert instead
 * of returning `false` on failure. This behavior is nonetheless conventional
 * and does not conflict with the expectations of ERC20 applications.
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
contract ERC20 is Context, IERC20 {
    using SafeMath for uint256;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    /**
     * @dev Sets the values for {name} and {symbol}, initializes {decimals} with
     * a default value of 18.
     *
     * To select a different value for {decimals}, use {_setupDecimals}.
     *
     * All three of these values are immutable: they can only be set once during
     * construction.
     */
    constructor (string memory name_, string memory symbol_) public {
        _name = name_;
        _symbol = symbol_;
        _decimals = 18;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5,05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the value {ERC20} uses, unless {_setupDecimals} is
     * called.
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view virtual returns (uint8) {
        return _decimals;
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
     * - `recipient` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
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
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * Requirements:
     *
     * - `sender` and `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     * - the caller must have allowance for ``sender``'s tokens of at least
     * `amount`.
     */
    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
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
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
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
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    /**
     * @dev Moves tokens `amount` from `sender` to `recipient`.
     *
     * This is internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `sender` cannot be the zero address.
     * - `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     */
    function _transfer(address sender, address recipient, uint256 amount) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
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

        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
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
     * @dev Sets {decimals} to a value other than the default one of 18.
     *
     * WARNING: This function should only be called from the constructor. Most
     * applications that interact with token contracts will not expect
     * {decimals} to ever change, and may work incorrectly if it does.
     */
    function _setupDecimals(uint8 decimals_) internal virtual {
        _decimals = decimals_;
    }

    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * will be to transferred to `to`.
     * - when `from` is zero, `amount` tokens will be minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }
}
// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

import "../../utils/Context.sol";
import "./ERC20.sol";

/**
 * @dev Extension of {ERC20} that allows token holders to destroy both their own
 * tokens and those that they have an allowance for, in a way that can be
 * recognized off-chain (via event analysis).
 */
abstract contract ERC20Burnable is Context, ERC20 {
    using SafeMath for uint256;

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
        uint256 decreasedAllowance = allowance(account, _msgSender()).sub(amount, "ERC20: burn amount exceeds allowance");

        _approve(account, _msgSender(), decreasedAllowance);
        _burn(account, amount);
    }
}
// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

import "./ERC20.sol";
import "../../utils/Pausable.sol";

/**
 * @dev ERC20 token with pausable token transfers, minting and burning.
 *
 * Useful for scenarios such as preventing trades until the end of an evaluation
 * period, or having an emergency switch for freezing all token transfers in the
 * event of a large bug.
 */
abstract contract ERC20Pausable is ERC20, Pausable {
    /**
     * @dev See {ERC20-_beforeTokenTransfer}.
     *
     * Requirements:
     *
     * - the contract must not be paused.
     */
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual override {
        super._beforeTokenTransfer(from, to, amount);

        require(!paused(), "ERC20Pausable: token transfer while paused");
    }
}
// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

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
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

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
}
// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

import "./IERC20.sol";
import "../../math/SafeMath.sol";
import "../../utils/Address.sol";

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
    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

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
        // solhint-disable-next-line max-line-length
        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
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
        if (returndata.length > 0) { // Return data is optional
            // solhint-disable-next-line max-line-length
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}
// SPDX-License-Identifier: MIT

pragma solidity >=0.6.2 <0.8.0;

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
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        uint256 size;
        // solhint-disable-next-line no-inline-assembly
        assembly { size := extcodesize(account) }
        return size > 0;
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

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain`call` is an unsafe replacement for a function call: use this
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
    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
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
    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{ value: value }(data);
        return _verifyCallResult(success, returndata, errorMessage);
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
    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
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
    function functionDelegateCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) private pure returns(bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                // solhint-disable-next-line no-inline-assembly
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

pragma solidity >=0.6.0 <0.8.0;

/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with GSN meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}
// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

import "./Context.sol";

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
    constructor () internal {
        _paused = false;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns (bool) {
        return _paused;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        require(!paused(), "Pausable: paused");
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
        require(paused(), "Pausable: not paused");
        _;
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

pragma solidity >=0.6.0 <0.8.0;

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

    constructor () internal {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and make it call a
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

pragma solidity >=0.6.0 <0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20Burnable.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20Pausable.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";


contract Emergency is Ownable {
    using SafeERC20 for IERC20;
    bool public emergency;

    event SetEmergency(bool indexed emergency);
    event EmergencyWithdraw(address token_, address user_, uint256 amount_);

    modifier noEmergency() {
        require(!emergency, "emergency.");
        _;
    }

    constructor() public {
        emergency = false;
    }

    function setEmergency(bool emergency_) external onlyOwner {
        emergency = emergency_;
        emit SetEmergency(emergency_);
    }

    function emergencyWithdraw(address token_, uint256 amount)
    external
    virtual
    onlyOwner
    {
        require(emergency, "no emergency.");
        IERC20(token_).safeTransfer(msg.sender, amount);
        emit EmergencyWithdraw(token_, msg.sender, amount);
    }

}
//SPDX-License-Identifier: MIT
pragma solidity >=0.6.5 <0.8.0;


interface IUniswapV2Factory {
    event PairCreated(
        address indexed token0,
        address indexed token1,
        address pair,
        uint256
    );

    function feeTo() external view returns (address);

    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB)
        external
        view
        returns (address pair);

    function allPairs(uint256) external view returns (address pair);

    function allPairsLength() external view returns (uint256);

    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);

    function setFeeTo(address) external;

    function setFeeToSetter(address) external;
}
//SPDX-License-Identifier: MIT
pragma solidity >=0.6.5 <0.8.0;

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

//SPDX-License-Identifier: MIT
pragma solidity >=0.6.0 <0.8.0;
interface IUniswapV2Router02 {
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;


    function factory() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    )
    external
    returns (
        uint256 amountA,
        uint256 amountB,
        uint256 liquidity
    );
}
// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";
import "../libraries/IUniswapV2Router02.sol";
import "../libraries/IUniswapV2Pair.sol";
import "../libraries/IUniswapV2Factory.sol";
import "./FireLpStake.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "../lib/Emergency.sol";
import "./FireConvert.sol";

contract FireAddLiquidity is ReentrancyGuard, Emergency{

    address public router;
    FireLpStake public lpStake;
    uint256 public RATE_DENOMINATOR = 10000;
    uint256 public addMaxLimitRate = 2000;
    uint256 public MaxAddUsdt = 100000 * 10 ** 18;
    uint256 public UserMaxAddUsdt = 500 * 10 ** 18;
    uint256 public dayTime = 1 days;
    uint256 public dayTimePadding = 21 hours;
    address public usdtToken;
    address public ttm;
    address public ttmV2;
    address public convert;
    uint256 public startTime;

    mapping(uint256 =>uint256) public usdtMap;
    mapping(uint256 => mapping(address=> uint256)) public userMap;

    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    constructor(address router_,address ttm_,uint256 dayTime_,uint256 dayTimePadding_,address usdtToken_) public {
        router = router_;
        ttm = ttm_;
        dayTime = dayTime_;
        dayTimePadding = dayTimePadding_;
        usdtToken = usdtToken_;
        startTime = getTimeKey();
    }


    function setLpStake(address lpStake_) external onlyOwner{
        lpStake = FireLpStake(lpStake_);
    }

    function setMaxRate(uint256 addMaxLimitRate_,uint256 MaxAddUsdt_,uint256 UserMaxAddUsdt_,uint256 startTime_) external onlyOwner{
        addMaxLimitRate = addMaxLimitRate_;
        UserMaxAddUsdt = UserMaxAddUsdt_;
        MaxAddUsdt = MaxAddUsdt_;
        startTime = startTime_;
    }

    function setTtmV2(address ttmV2_) external onlyOwner{
        ttmV2 = ttmV2_;
    }

    function setConvert(address convert_) external onlyOwner{
        convert = convert_;
    }



    function preAddLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin
    ) public view returns (uint amountA, uint amountB) {
        (uint reserveA, uint reserveB) = getReserves(tokenA, tokenB);
        if (reserveA == 0 && reserveB == 0) {
            (amountA, amountB) = (amountADesired, amountBDesired);
        } else {
            uint amountBOptimal = quote(amountADesired, reserveA, reserveB);
            if (amountBOptimal <= amountBDesired) {
                require(amountBOptimal >= amountBMin, 'PancakeRouter: INSUFFICIENT_B_AMOUNT');
                (amountA, amountB) = (amountADesired, amountBOptimal);
            } else {
                uint amountAOptimal = quote(amountBDesired, reserveB, reserveA);
                assert(amountAOptimal <= amountADesired);
                require(amountAOptimal >= amountAMin, 'PancakeRouter: INSUFFICIENT_A_AMOUNT');
                (amountA, amountB) = (amountAOptimal, amountBDesired);
            }
        }
    }

    function getTimeKey() public view returns (uint256) {
        return block.timestamp.div(dayTime).mul(dayTime).add(dayTimePadding);
    }


    function getDayCount() public view returns (uint256) {
        uint256 currentTime = getTimeKey();
        if(currentTime < startTime){
            return 0;
        }
        return currentTime.sub(startTime).div(dayTime);
    }

    function getMaxAmount() public view returns (uint256) {
        uint256 deyCount = getDayCount();
        return MaxAddUsdt.add(deyCount.mul(MaxAddUsdt).mul(addMaxLimitRate).div(RATE_DENOMINATOR));
    }
    
    function getCurrentUseAmount() public view returns (uint256) {
        return usdtMap[getTimeKey()];
    }


    function getUserMaxAmount() public view returns (uint256) {
        uint256 deyCount = getDayCount();
        return UserMaxAddUsdt.add(deyCount.mul(UserMaxAddUsdt).mul(addMaxLimitRate).div(RATE_DENOMINATOR));
    }

    function getCurrentUserUseAmount(address user) public view returns (uint256) {
        return userMap[getTimeKey()][user];
    }

    function checkPoolLimit(uint256 usdtAmount) public view returns (bool) {
        uint256 useAmount = getCurrentUseAmount();
        uint256 maxAmount = getMaxAmount();
        return useAmount.add(usdtAmount) <= maxAmount;
    }

    function checkUserLimit(address user,uint256 usdtAmount) public view returns (bool) {
        uint256 useAmount = getCurrentUserUseAmount(user);
        uint256 maxAmount = getUserMaxAmount();
        return useAmount.add(usdtAmount) <= maxAmount;
    }

    function addLiquidity(
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin
    ) public returns (uint amountA, uint amountB, uint liquidity) {
        address tokenA = ttmV2;
        address tokenB = usdtToken;
        uint256 usdtAmount = amountBDesired;
        require(checkPoolLimit(usdtAmount),"Liquidity:Exceeding the limit");
        require(checkUserLimit(msg.sender,usdtAmount),"Liquidity:Exceeding the user limit");
        usdtMap[getTimeKey()] = usdtMap[getTimeKey()].add(usdtAmount);
        userMap[getTimeKey()][msg.sender] = userMap[getTimeKey()][msg.sender].add(usdtAmount);

        (amountA, amountB) = preAddLiquidity(tokenA, tokenB, amountADesired, amountBDesired, amountAMin, amountBMin);
        IERC20(ttm).safeTransferFrom(msg.sender, address(this), amountA);
        IERC20(ttm).safeApprove(address(convert),amountA);
        FireConvert(convert).mintConvert(amountA);
        IERC20(tokenB).safeTransferFrom(msg.sender, address(this), amountB);
        address pair = getPair(tokenA,tokenB);
        IERC20(tokenA).safeTransfer(pair, amountA);
        IERC20(tokenB).safeTransfer(pair, amountB);
        liquidity = IUniswapV2Pair(pair).mint(address(this));
        IERC20(pair).safeApprove(address(lpStake),liquidity);
        lpStake.stake(0,liquidity,msg.sender);
    }
    function addLiquidity2(
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin
    ) public returns (uint amountA, uint amountB, uint liquidity) {
        address tokenA = ttmV2;
        address tokenB = usdtToken;
        uint256 usdtAmount = amountBDesired;
        require(checkPoolLimit(usdtAmount),"Liquidity:Exceeding the limit");
        require(checkUserLimit(msg.sender,usdtAmount),"Liquidity:Exceeding the user limit");
        usdtMap[getTimeKey()] = usdtMap[getTimeKey()].add(usdtAmount);
        userMap[getTimeKey()][msg.sender] = userMap[getTimeKey()][msg.sender].add(usdtAmount);
        (amountA, amountB) = preAddLiquidity(tokenA, tokenB, amountADesired, amountBDesired, amountAMin, amountBMin);
        IERC20(tokenA).safeTransferFrom(msg.sender, address(this), amountA);
        IERC20(tokenB).safeTransferFrom(msg.sender, address(this), amountB);
        address pair = getPair(tokenA,tokenB);
        IERC20(tokenA).safeTransfer(pair, amountA);
        IERC20(tokenB).safeTransfer(pair, amountB);
        liquidity = IUniswapV2Pair(pair).mint(address(this));
        IERC20(pair).safeApprove(address(lpStake),liquidity);
        lpStake.stake(0,liquidity,msg.sender);
    }


    function removeLiquidity(
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to
    ) public {
        address tokenA = ttmV2;
        address tokenB = usdtToken;
        address pair = getPair(tokenA,tokenB);
        IUniswapV2Pair(pair).transferFrom(msg.sender, pair, liquidity);
        IUniswapV2Pair(pair).burn(address(this));
        uint256 addressA1= IERC20(tokenA).balanceOf(address (this));
        uint256 addressB1= IERC20(tokenB).balanceOf(address (this));
        require(addressA1 >= amountAMin, 'Liquidity: INSUFFICIENT_A_AMOUNT');
        require(addressB1 >= amountBMin, 'Liquidity: INSUFFICIENT_B_AMOUNT');
        IERC20(tokenA).safeTransfer(to, addressA1);
        IERC20(tokenB).safeTransfer(to, addressB1);
    }


    // returns sorted token addresses, used to handle return values from pairs sorted in this order
    function sortTokens(address tokenA, address tokenB) public pure returns (address token0, address token1) {
        require(tokenA != tokenB, 'PancakeLibrary: IDENTICAL_ADDRESSES');
        (token0, token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
        require(token0 != address(0), 'PancakeLibrary: ZERO_ADDRESS');
    }

    // given some amount of an asset and pair reserves, returns an equivalent amount of the other asset
    function quote(uint amountA, uint reserveA, uint reserveB) public pure returns (uint amountB) {
        require(amountA > 0, 'PancakeLibrary: INSUFFICIENT_AMOUNT');
        require(reserveA > 0 && reserveB > 0, 'PancakeLibrary: INSUFFICIENT_LIQUIDITY');
        amountB = amountA.mul(reserveB) / reserveA;
    }
    // fetches and sorts the reserves for a pair
    function getReserves(address tokenA, address tokenB) public view returns (uint reserveA, uint reserveB) {
        (address token0,) = sortTokens(tokenA, tokenB);
        address pair = getPair(tokenA,tokenB);
        (uint reserve0, uint reserve1,) = IUniswapV2Pair(pair).getReserves();
        (reserveA, reserveB) = tokenA == token0 ? (reserve0, reserve1) : (reserve1, reserve0);
    }

    function getPair(address tokenA, address tokenB) public view returns (address) {
        address factory = IUniswapV2Router02(router).factory();
        address pair = IUniswapV2Factory(factory).getPair(tokenA, tokenB);
        require(pair != address(0),"!Pair");
        return pair;
    }

}
// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";
import "../lib/Emergency.sol";
import "@openzeppelin/contracts/cryptography/ECDSA.sol";
import "./FireToken.sol";


contract FireConvert is ReentrancyGuard, Emergency {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    using ECDSA for bytes32;
    address public ttm;
    address public ttmv2;

    constructor(address ttm_, address ttmv2_) public {
        ttm = ttm_;
        ttmv2 = ttmv2_;
    }

    mapping(address =>uint256) public userMintMap;
    mapping(address => bool) public recoverList;
    mapping(address => bool) public whiteList;


    event SetRecover(address indexed user, bool state);
    event Mint(address indexed user, uint256 amount);

    function setWhiteList(address addr_, bool state_) external onlyOwner {
        whiteList[addr_] = state_;
    }

    function setRecover(address addr_, bool state_)
    external
    onlyOwner
    {
        recoverList[addr_] = state_;
        emit SetRecover(addr_, state_);
    }

    modifier ensure(uint256 deadline)  {
        require(deadline >= block.timestamp, "V2Convert: EXPIRED");
        _;
    }


    function mintConvert(uint256 amount) public noEmergency nonReentrant {
        require(amount > 0, "V2Convert: amount <= 0");
        require(whiteList[msg.sender], "V2Convert: invalid caller");
        IERC20(ttm).safeTransferFrom(msg.sender, 0x000000000000000000000000000000000000dEaD, amount);
        FireToken(ttmv2).mint(msg.sender, amount);
        emit Mint(msg.sender, amount);
    }


    function verifyMintSign(
        uint256 deadline,
        address userAddr,
        uint256 userMaxMint,
        uint256 mintTimeKey,
        bytes memory signature
    ) public view returns (bool) {
        address recoverAddr = keccak256(
            abi.encode(deadline, userAddr, userMaxMint, mintTimeKey, address(this))
        ).toEthSignedMessageHash()
            .recover(signature);
        return recoverList[recoverAddr];
    }


    function mint(
        uint256 amount,
        uint256 deadline,
        address userAddr,
        uint256 userMaxMint,
        uint256 mintTimeKey,
        bytes calldata signature
    ) external noEmergency ensure(deadline) nonReentrant {
        require(amount > 0, "V2Convert: amount <= 0");
        require(msg.sender == userAddr, "V2Convert: invalid caller");
        require(verifyMintSign(deadline, userAddr, userMaxMint, mintTimeKey, signature), "V2Convert: please check the signature");
        require(userMintMap[userAddr].add(amount) <= userMaxMint, "V2Convert: Mint volume is too large");
        userMintMap[userAddr] = userMintMap[userAddr].add(amount);
        IERC20(ttm).safeTransferFrom(msg.sender, 0x000000000000000000000000000000000000dEaD, amount);
        FireToken(ttmv2).mint(msg.sender, amount);
        emit Mint(msg.sender, amount);
    }

}// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";
import "../lib/Emergency.sol";

contract FireFeeTreasury is Emergency {

    using SafeERC20 for IERC20;

    IERC20 public ttmTokenV2;
    IERC20 public usdtToken;

    constructor() public{
    }


    mapping(address => bool) public whiteList;

    modifier isWhiteList() {
        require(whiteList[msg.sender] == true || owner() == msg.sender, "LpFeeTreasury: no permission.");
        _;
    }

    function setTTMToken(address ttmTokenV2_ ) external onlyOwner{
        ttmTokenV2 = IERC20(ttmTokenV2_);
    }

    function setUSDTToken(address usdtToken_ ) external onlyOwner{
        usdtToken = IERC20(usdtToken_);
    }


    function setWhiteList(address user, bool state) external onlyOwner {
        whiteList[user] = state;
    }

    function withdraw(uint256 amount) external noEmergency isWhiteList {
        ttmTokenV2.safeTransfer(msg.sender,amount);
    }

    function withdrawUSDT(uint256 amount) external noEmergency isWhiteList {
        usdtToken.safeTransfer(msg.sender,amount);
    }
}// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20Burnable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20Pausable.sol";
import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";
import "./FireFeeTreasury.sol";


contract FireLpStake is ReentrancyGuard, Ownable
{
    using SafeMath for uint256;
    using Address for address;
    using SafeERC20 for IERC20;

    event Stake(
        address indexed user,
        uint256 indexed pool,
        uint256 amount,
        uint256 power
    );
    event StakeLock(address indexed user, UserStake userStake);
    event Withdraw(address indexed user, uint256 amount);
    event WithdrawLock(address indexed user, UserStake userStake);
    event Claimed(address indexed user,address token, uint256 amount);
    event SetUnlockTimeWindow(uint256 indexed unlockTimeWindow);
    event SetEmergency(bool indexed emergency);
    event UpdatePool(uint256 indexed pool, uint256 weight, uint256 lockTime);

    struct PoolInfo {
        uint256 pid;
        uint256 totalPower;
        uint256 totalLock;
        uint256 weight; // 1e18
        uint256 lockTime;
    }

    struct UserInfo {
        uint256 amount;
        uint256 lockAmount;
        uint256 totalPower;

        uint256 ttmTotalIncome;
        uint256 usdtTotalIncome;
        uint256 ttmDebt;
        uint256 usdtDebt;
        uint256 ttmReward;
        uint256 usdtReward;
    }

    struct UserStake {
        uint256 id;
        uint256 amount;
        uint256 power;
        uint256 poolId;
        uint256 lockTime;
        uint256 startTime;
        bool over;
    }

    struct RewardInfo {
        uint256 rewardPerShare;
        uint256 remainingRewards;
        uint256 totalReward;
        uint256 endTime;
    }


    IERC20 public ttmv2Token;
    IERC20 public usdtToken;
    IERC20 public stakeToken;


    PoolInfo[] public poolInfos;


    uint256 public lastBlockTimeStamp;
    uint256 public totalPower;


    address public lpFeeTreasury;


    RewardInfo public ttmv2RewardInfo;
    RewardInfo public usdtRewardInfo;


    uint256 public rewardLockTime = 7 days;


    uint256 public unlockTimeWindow;

    bool public emergency;

    mapping(address => UserInfo) public userInfos;
    mapping(address => UserStake[]) public userInfoDeposits;
    mapping(address => bool) public whiteList;

    constructor(
        address ttmv2Token_,
        address usdtToken_,
        address stakeToken_,
        address lpFeeTreasury_,
        uint256 rewardLockTime_,
        uint256 lockTime_
    ) public {
        ttmv2Token = IERC20(ttmv2Token_);
        usdtToken = IERC20(usdtToken_);
        stakeToken = IERC20(stakeToken_);
        lpFeeTreasury = lpFeeTreasury_;
        PoolInfo memory pool = PoolInfo(0, 0, 0, 1e18, lockTime_);
        poolInfos.push(pool);
        rewardLockTime = rewardLockTime_;
    }

    function setEmergency(bool emergency_) external onlyOwner {
        emergency = emergency_;
        emit SetEmergency(emergency_);
    }

    function setWhiteList(address user, bool state) external onlyOwner {
        whiteList[user] = state;
    }

    function emergencyWithdraw(address token_, uint256 amount)
    external
    onlyOwner
    {
        require(emergency, "no emergency.");
        IERC20(token_).safeTransfer(msg.sender, amount);
    }


    function setUnlockTimeWindow(uint256 unlockTimeWindow_) external onlyOwner {
        unlockTimeWindow = unlockTimeWindow_;
        emit SetUnlockTimeWindow(unlockTimeWindow_);
    }

    modifier noEmergency() {
        require(!emergency, "emergency.");
        _;
    }

    modifier verifyPid(uint256 pid) {
        require(pid >= 0 && pid <= 4, "!POOL");
        _;
    }

    modifier onlyWhiteList() {
        require(whiteList[msg.sender] == true || owner() == msg.sender, "no permission.");
        _;
    }

    modifier updateRewardPerShare() {
        if (totalPower > 0 && block.timestamp > lastBlockTimeStamp) {
            {
                (uint256 _reward, uint256 _perShare, uint256 _remainingRewardsUpdate, uint256 _endTimeUpdate, uint256 _withdrawReward) = currentRewardShare(
                    address(ttmv2Token)
                );
                ttmv2RewardInfo.rewardPerShare = _perShare;
                lastBlockTimeStamp = block.timestamp;
                if (_withdrawReward > 0) {
                    FireFeeTreasury(lpFeeTreasury).withdraw(_withdrawReward);
                }
                ttmv2RewardInfo.endTime = _endTimeUpdate;
                ttmv2RewardInfo.remainingRewards = _remainingRewardsUpdate;
                ttmv2RewardInfo.totalReward = ttmv2RewardInfo.totalReward.add(_reward);
            }
            {
                (uint256 _reward, uint256 _perShare, uint256 _remainingRewardsUpdate, uint256 _endTimeUpdate, uint256 _withdrawReward) = currentRewardShare(
                    address (usdtToken)
                );
                usdtRewardInfo.rewardPerShare = _perShare;

                if (_withdrawReward > 0) {
                    FireFeeTreasury(lpFeeTreasury).withdrawUSDT(_withdrawReward);
                }
                usdtRewardInfo.endTime = _endTimeUpdate;
                usdtRewardInfo.remainingRewards = _remainingRewardsUpdate;
                usdtRewardInfo.totalReward = usdtRewardInfo.totalReward.add(_reward);
            }
            lastBlockTimeStamp = block.timestamp;
        }
        _;
    }

    modifier updateUserReward(address user) {
        UserInfo storage userInfo = userInfos[user];
        if (userInfo.totalPower > 0) {
            {
                uint256 debt = userInfo.totalPower.mul(ttmv2RewardInfo.rewardPerShare).div(1e18);
                uint256 userReward = debt.sub(userInfo.ttmDebt);
                userInfo.ttmReward = userInfo.ttmReward.add(userReward);
                userInfo.ttmDebt = debt;
            }
            {
                uint256 debt = userInfo.totalPower.mul(usdtRewardInfo.rewardPerShare).div(1e18);
                uint256 userReward = debt.sub(userInfo.usdtDebt);
                userInfo.usdtReward = userInfo.usdtReward.add(userReward);
                userInfo.usdtDebt = debt;
            }
        }
        _;
    }


    function currentRewardShare(address token)
    public
    view
    virtual
    returns (uint256 _reward, uint256 _perShare, uint256 _remainingRewardsUpdate, uint256 _endTimeUpdate, uint256 _withdrawReward)
    {
        uint256 lastTimeStamp = lastBlockTimeStamp;
        if (lastTimeStamp == 0) {
            lastTimeStamp = block.timestamp;
        }

        RewardInfo memory rewardInfo = token == address(ttmv2Token) ? ttmv2RewardInfo : usdtRewardInfo;
        uint256 lpFeeTreasuryBalance = IERC20(token).balanceOf(lpFeeTreasury);

        uint256 time = block.timestamp.sub(lastTimeStamp);

        uint256 remainingTotalReward = lpFeeTreasuryBalance.add(rewardInfo.remainingRewards);

        uint256 _endTime = rewardInfo.endTime == 0 ? block.timestamp : rewardInfo.endTime;

        if (lpFeeTreasuryBalance > 0) {
            if (_endTime < block.timestamp) {
                _endTime = _endTime.add(rewardLockTime);
            } else {
                _endTime = block.timestamp.add(rewardLockTime);
            }
        }

        uint256 preAmount = 0;
        if (_endTime < block.timestamp) {
            preAmount = remainingTotalReward;
            _remainingRewardsUpdate = 0;
            _endTime = block.timestamp;
        } else {
            uint256 totalTime = _endTime.sub(lastTimeStamp);
            if (totalTime > 0) {
                preAmount = remainingTotalReward.mul(time).div(totalTime);
                _remainingRewardsUpdate = remainingTotalReward.sub(preAmount);
            }
        }
       uint256 reward_ = preAmount;
        uint256 perShare_ = rewardInfo.rewardPerShare;
        if (totalPower > 0) {
            perShare_ = perShare_.add(reward_.mul(1e18).div(totalPower));
        }
        return (reward_, perShare_, _remainingRewardsUpdate, _endTime, lpFeeTreasuryBalance);
    }

    function getPoolInfo(uint256 pid)
    external
    view
    virtual
    verifyPid(pid)
    returns (PoolInfo memory)
    {
        return poolInfos[pid];
    }

    function getPoolInfos() external view virtual returns (PoolInfo[] memory) {
        return poolInfos;
    }

    function getUserInfo(address user)
    external
    view
    virtual
    returns (UserInfo memory)
    {
        return userInfos[user];
    }

    function calculateIncome(address user)
    external
    view
    virtual
    returns (uint256 ttmV2Income,uint256 usdtIncome)
    {
        UserInfo memory userInfo = userInfos[user];
        {
            uint256 _rewardPerShare = ttmv2RewardInfo.rewardPerShare;
            if (block.timestamp > lastBlockTimeStamp && totalPower > 0) {
                (, _rewardPerShare,,,) = currentRewardShare(address (ttmv2Token));
            }
            uint256 ttmV2Reward = userInfo
                .totalPower
                .mul(_rewardPerShare).div(1e18).sub(userInfo.ttmDebt);
            ttmV2Income = userInfo.ttmReward.add(ttmV2Reward);
        }

        {
            uint256 _rewardPerShare = usdtRewardInfo.rewardPerShare;
            if (block.timestamp > lastBlockTimeStamp && totalPower > 0) {
                (, _rewardPerShare,,,) = currentRewardShare(address (usdtToken));
            }
            uint256 usdtReward = userInfo
                .totalPower
                .mul(_rewardPerShare).div(1e18).sub(userInfo.usdtDebt);
            usdtIncome = userInfo.usdtReward.add(usdtReward);
        }
    }


    function stake(uint256 pid, uint256 amount, address user)
    external
    virtual
    onlyWhiteList
    noEmergency
    verifyPid(pid)
    nonReentrant
    updateRewardPerShare
    updateUserReward(user)
    {
        require(user != address(0), "!user");

        stakeToken.safeTransferFrom(
            msg.sender,
            address(this),
            amount
        );

        if (amount > 0) {
            PoolInfo storage pool = poolInfos[pid];
            uint256 power = amount.mul(pool.weight).div(1e18);

            UserInfo storage userInfo = userInfos[user];
            userInfo.totalPower = userInfo.totalPower.add(power);
            userInfo.ttmDebt = userInfo.totalPower.mul(ttmv2RewardInfo.rewardPerShare).div(1e18);
            userInfo.usdtDebt = userInfo.totalPower.mul(usdtRewardInfo.rewardPerShare).div(1e18);
            totalPower = totalPower.add(power);
            pool.totalPower = pool.totalPower.add(power);
            pool.totalLock = pool.totalLock.add(amount);

            if (pool.lockTime > 0) {
                UserStake memory userStake = UserStake(
                    userInfoDeposits[user].length,
                    amount,
                    power,
                    pool.pid,
                    pool.lockTime,
                    block.timestamp,
                    false
                );
                userInfo.lockAmount = userInfo.lockAmount.add(amount);
                userInfoDeposits[user].push(userStake);
                emit StakeLock(user, userStake);
            } else {
                userInfo.amount = userInfo.amount.add(amount);
                emit Stake(user, pool.pid, amount, power);
            }
        }
    }

    function withdraw(uint256 amount)
    external
    virtual
    nonReentrant
    updateRewardPerShare
    updateUserReward(msg.sender)
    {
        if (amount > 0) {
            UserInfo storage userInfo = userInfos[msg.sender];
            require(userInfo.amount >= amount, "Insufficient balance");

            uint256 power = amount;
            userInfo.amount = userInfo.amount.sub(amount);
            userInfo.totalPower = userInfo.totalPower.sub(power);
            userInfo.ttmDebt = userInfo.totalPower.mul(ttmv2RewardInfo.rewardPerShare).div(1e18);
            userInfo.usdtDebt = userInfo.totalPower.mul(usdtRewardInfo.rewardPerShare).div(1e18);

            PoolInfo storage pool = poolInfos[0];
            pool.totalPower = pool.totalPower.sub(power);
            pool.totalLock = pool.totalLock.sub(power);

            totalPower = totalPower.sub(amount);

            stakeToken.safeTransfer(msg.sender, amount);
            emit Withdraw(msg.sender, amount);
        }
    }

    function withdrawStake(uint256[] calldata depositIds)
    external
    virtual
    nonReentrant
    updateRewardPerShare
    updateUserReward(msg.sender)
    {
        address user = msg.sender;
        if (depositIds.length == 0) {
            return;
        }
        UserInfo storage userInfo = userInfos[user];
        uint256 unLockAmount = 0;
        uint256 unLockPower = 0;

        for (uint256 i = 0; i < depositIds.length; i++) {
            uint256 id = depositIds[i];
            UserStake storage userStake = userInfoDeposits[user][id];

            uint256 timeWindowDiv = block
                .timestamp
                .sub(userStake.startTime)
                .div(userStake.lockTime);

            uint256 windowsStart = userStake.startTime.add(
                timeWindowDiv.mul(userStake.lockTime)
            );
            uint256 windowsEnd = windowsStart.add(unlockTimeWindow);

            if (
                timeWindowDiv > 0 &&
                block.timestamp >= windowsStart &&
                block.timestamp <= windowsEnd &&
                userStake.over == false
            ) {
                userStake.over = true;

                PoolInfo storage pool = poolInfos[userStake.poolId];
                pool.totalPower = pool.totalPower.sub(userStake.power);
                pool.totalLock = pool.totalLock.sub(userStake.amount);

                unLockAmount = unLockAmount.add(userStake.amount);
                unLockPower = unLockPower.add(userStake.power);
                emit WithdrawLock(user, userStake);
            }
        }
        if (unLockPower > 0) {
            userInfo.lockAmount = userInfo.lockAmount.sub(unLockAmount);
            userInfo.totalPower = userInfo.totalPower.sub(unLockPower);
            userInfo.ttmDebt = userInfo.totalPower.mul(ttmv2RewardInfo.rewardPerShare).div(1e18);
            userInfo.usdtDebt = userInfo.totalPower.mul(usdtRewardInfo.rewardPerShare).div(1e18);
            totalPower = totalPower.sub(unLockPower);
            stakeToken.safeTransfer(user, unLockAmount);
        }
    }

    function userDepositsTotal(address user) external view returns (uint256) {
        return userInfoDeposits[user].length;
    }

    function userDepositByIndex(address user, uint256 index)
    external
    view
    returns (UserStake memory)
    {
        return userInfoDeposits[user][index];
    }

    function userDeposits(
        address user,
        uint256 offset,
        uint256 size
    ) external view returns (UserStake[] memory) {
        UserStake[] memory stakeList = userInfoDeposits[user];
        if (offset >= stakeList.length) {
            return new UserStake[](0);
        }
        // length = 2
        // offset = 0 size = 3
        // max size = 2 - 0 = 2
        if (size >= stakeList.length - offset) {
            size = stakeList.length - offset;
        }

        UserStake[] memory result = new UserStake[](size);
        for (uint256 i = 0; i < size; i++) {
            result[i] = stakeList[offset + i];
        }
        return result;
    }

    function claim()
    external
    virtual
    noEmergency
    nonReentrant
    updateRewardPerShare
    updateUserReward(msg.sender)
    {
        UserInfo storage userInfo = userInfos[msg.sender];
        if (userInfo.ttmReward > 0) {
            uint256 reward = userInfo.ttmReward;
            userInfo.ttmReward = 0;
            userInfo.ttmTotalIncome = userInfo.ttmTotalIncome.add(reward);
            ttmv2Token.safeTransfer(msg.sender, reward);
            emit Claimed(msg.sender, address(ttmv2Token), reward);
        }
        if (userInfo.usdtReward > 0) {
            uint256 reward = userInfo.usdtReward;
            userInfo.usdtReward = 0;
            userInfo.usdtTotalIncome = userInfo.usdtTotalIncome.add(reward);
            usdtToken.safeTransfer(msg.sender, reward);
            emit Claimed(msg.sender, address (usdtToken),reward);
        }
    }

    function updatePoolInfo(
        uint256 pid,
        uint256 weight,
        uint256 lockTime
    ) external virtual onlyOwner verifyPid(pid) updateRewardPerShare {
        require(pid >= 0 && weight >= 1e18 && lockTime >= 0, "!params");
        PoolInfo storage pool = poolInfos[pid];
        pool.weight = weight;
        pool.lockTime = lockTime;
        emit UpdatePool(pool.pid, pool.weight, pool.lockTime);
    }
}// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";
import "../libraries/IUniswapV2Router02.sol";
import "../libraries/IUniswapV2Factory.sol";
import "../libraries/IUniswapV2Pair.sol";
import "../lib/Emergency.sol";


contract FireToken is ERC20, Ownable {
    using SafeMath for uint256;

    uint256 public RATE_DENOMINATOR = 10000;
    uint256 public buyFeeRate = 500;
    uint256 public minSellFeeRate = 500;
    uint256 public maxSellFeeRate = 3200;

    uint256 public lpFeeRate = 6000;
    uint256 public burnFeeRate = 2000;
    uint256 public projectPartyFeeRate = 2000;

    address public lpPoolFeeTo;
    address public projectFeeTo;
    address public burnFeeTo = 0x000000000000000000000000000000000000dEaD;


    address public tokenUsdt;
    address public uniswapV2Pair;
    address public addLpTool;
    Emergency public emergencyContract;
    IUniswapV2Router02 public uniswapV2Router;

    uint256 public dayTime = 1 days;
    uint256 public dayTimePadding = 21 hours;

    struct Price {
        uint256 reserveA;
        uint256 reserveB;
        uint256 current;
    }

    mapping(uint256 => Price) public dayOpenPriceMapping;
    mapping(address => bool) public whiteList;


    constructor(address router_, address tokenUsdt_, address addLpTool_, address projectFeeTo_, address lpPoolFeeTo_, uint256 dayTime_, uint256 dayTimePadding_) public ERC20('Fire', 'Fire')  {
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(router_);
        address _uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory()).createPair(address(this), tokenUsdt_);
        uniswapV2Router = _uniswapV2Router;
        uniswapV2Pair = _uniswapV2Pair;
        tokenUsdt = tokenUsdt_;
        projectFeeTo = projectFeeTo_;
        addLpTool = addLpTool_;
        lpPoolFeeTo = lpPoolFeeTo_;
        dayTime = dayTime_;
        dayTimePadding = dayTimePadding_;
        emergencyContract = new Emergency();
        emergencyContract.setEmergency(true);
    }

    function setWhiteList(address addr_, bool state_) external onlyOwner {
        whiteList[addr_] = state_;
    }

    function mint(address to, uint256 amount) external {
        require(whiteList[msg.sender], "Token: invalid caller");
        _mint(to, amount);
    }


    function getReserves() public view returns (uint reserveA, uint reserveB) {
        (uint reserve0, uint reserve1,) = IUniswapV2Pair(uniswapV2Pair).getReserves();
        (reserveA, reserveB) = address(this) == IUniswapV2Pair(uniswapV2Pair).token0() ? (reserve0, reserve1) : (reserve1, reserve0);
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal override {
        updatePrice();
        if (amount == 0) {
            super._transfer(from, to, amount);
            return;
        }
        bool isBuy = uniswapV2Pair == from;
        bool isSell = uniswapV2Pair == to;
        uint feeRate = 0;
        if (isBuy) {
            feeRate = buyFeeRate; // remove 5% & buy 5%
        } else if (isSell) {
            feeRate = (from == addLpTool) ? 0 : getSellFeeRate(); // add lp 0% & sell
        }
        if (feeRate > 0) {
            uint256 fees = amount.mul(feeRate).div(RATE_DENOMINATOR);
            if (fees > 0) {
                amount = amount.sub(fees);
                super._transfer(from, address(this), fees);
                if (fees > 0) {
                    sendTokenFee(fees);
                }
            }
        }
        super._transfer(from, to, amount);
    }


    function sendTokenFee(uint256 fees) private {
        uint256 lpFee = fees.mul(lpFeeRate).div(RATE_DENOMINATOR);
        super._transfer(address(this), lpPoolFeeTo, lpFee);

        uint256 burnFee = fees.mul(burnFeeRate).div(RATE_DENOMINATOR);
        super._transfer(address(this), burnFeeTo, burnFee);

        uint256 projectPartyFee = fees.mul(projectPartyFeeRate).div(RATE_DENOMINATOR);
        super._transfer(address(this), projectFeeTo, projectPartyFee);
    }


    function getDailyChange() public view returns (int256) {
        (uint reserveA, uint reserveB) = getReserves();
        if (reserveA <= 0 || reserveB <= 0) {
            return 0;
        }
        uint256 currentPrice = reserveB.mul(1e18).div(reserveA);
        uint256 dayUnixTime = getTimeKey();
        Price storage price = dayOpenPriceMapping[dayUnixTime];
        if (price.current == 0) {
            return 0;
        }
        uint256 lastPrice = price.current;
        return ((int256(currentPrice) - int256(lastPrice)) * int256(RATE_DENOMINATOR)) / int256(lastPrice);
    }


    function getSellFeeRate() public view returns (uint256){
        int256 change = getDailyChange();
        // up 0.5%
        if (change >= - 50) {
            return minSellFeeRate;
        }
        // -0.5% 5%
        // -0.1% 10%
        // -1.1% 11%
        // -9.0%  90%
        if (change < - 50 && change >= - 320) {
            return uint256(change * - 1) * 10;
        }
        return maxSellFeeRate;
    }


    function getTimeKey() public view returns (uint256) {
        return block.timestamp.div(dayTime).mul(dayTime).add(dayTimePadding);
    }

    function updatePrice() private {
        uint256 dayUnixTime = getTimeKey();
        Price storage price = dayOpenPriceMapping[dayUnixTime];
        if (price.current == 0) {
            (uint reserveA, uint reserveB) = getReserves();
            if (reserveA > 0 && reserveB > 0) {
                uint256 currentPrice = uint256(reserveB).mul(1e18).div(uint256(reserveA));
                dayOpenPriceMapping[dayUnixTime] = Price(uint256(reserveA), uint256(reserveB), currentPrice);
            }
        }
    }


}