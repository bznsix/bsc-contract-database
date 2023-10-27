// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

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

/**
 * @title Counters
 * @author Matt Condon (@shrugs)
 * @dev Provides counters that can only be incremented, decremented or reset. This can be used e.g. to track the number
 * of elements in a mapping, issuing BEP721 ids, or counting request ids.
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
contract Ownable is Context {
    address public _owner;

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

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );
}

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
}

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
        // According to EIP-1052, 0x0 is the value returned for not-yet created accounts
        // and 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470 is returned
        // for accounts without code, i.e. `keccak256('')`
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        // solhint-disable-next-line no-inline-assembly
        assembly {
            codehash := extcodehash(account)
        }
        return (codehash != accountHash && codehash != 0x0);
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
        require(
            address(this).balance >= amount,
            "Address: insufficient balance"
        );

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{value: amount}("");
        require(
            success,
            "Address: unable to send value, recipient may have reverted"
        );
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
    function functionCall(address target, bytes memory data)
        internal
        returns (bytes memory)
    {
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
        return _functionCallWithValue(target, data, 0, errorMessage);
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
        return
            functionCallWithValue(
                target,
                data,
                value,
                "Address: low-level call with value failed"
            );
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
        require(
            address(this).balance >= value,
            "Address: insufficient balance for call"
        );
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(
        address target,
        bytes memory data,
        uint256 weiValue,
        string memory errorMessage
    ) private returns (bytes memory) {
        require(isContract(target), "Address: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{value: weiValue}(
            data
        );
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

/**
 * @dev Interface of the BEP20 standard as defined in the EIP.
 */
interface IBEP20 {
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
    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

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
}

/**
 * @dev Implementation of the {IBEP20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {BEP20PresetMinterPauser}.
 *
 * instead returning `false` on failure. This behavior is nonetheless
 * conventional and does not conflict with the expectations of BEP20
 * applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 *
 * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See {IBEP20-approve}.
 */
abstract contract BEP20 is Context, IBEP20 {
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    uint256 internal _totalSupply;

    /**
     * @dev See {IBEP20-totalSupply}.
     */
    function totalSupply() public view virtual returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IBEP20-balanceOf}.
     */
    function balanceOf(address account)
        public
        view
        virtual
        override
        returns (uint256)
    {
        return _balances[account];
    }

    /**
     * @dev See {IBEP20-transfer}.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address to, uint256 amount)
        public
        virtual
        override
        returns (bool)
    {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    /**
     * @dev See {IBEP20-allowance}.
     */
    function allowance(address owner, address spender)
        public
        view
        virtual
        override
        returns (uint256)
    {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IBEP20-approve}.
     *
     * NOTE: If `amount` is the maximum `uint256`, the allowance is not updated on
     * `transferFrom`. This is semantically equivalent to an infinite approval.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount)
        public
        virtual
        override
        returns (bool)
    {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    /**
     * @dev See {IBEP20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {BEP20}.
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
     * problems described in {IBEP20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue)
        public
        virtual
        returns (bool)
    {
        address owner = _msgSender();
        _approve(owner, spender, _allowances[owner][spender] + addedValue);
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IBEP20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue)
        public
        virtual
        returns (bool)
    {
        address owner = _msgSender();
        uint256 currentAllowance = _allowances[owner][spender];
        require(
            currentAllowance >= subtractedValue,
            "BEP20: decreased allowance below zero"
        );
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
        require(from != address(0), "BEP20: transfer from the zero address");
        require(to != address(0), "BEP20: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        require(
            fromBalance >= amount,
            "BEP20: transfer amount exceeds balance"
        );
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
        require(account != address(0), "BEP20: mint to the zero address");

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
        require(account != address(0), "BEP20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "BEP20: burn amount exceeds balance");
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
        require(owner != address(0), "BEP20: approve from the zero address");
        require(spender != address(0), "BEP20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Spend `amount` form the allowance of `owner` toward `spender`.
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
                "BEP20: insufficient allowance"
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

contract MultiSaleSHG is BEP20, Ownable {
    using SafeMath for uint256;
    using Address for address;

    bool private inTransfer;
    uint256 private _prevent_rug_pull;
    uint256 private _referBonusPercent;
    uint256 private _transactionFee;
    address private token_Address;
    address private _bnb_Address;
    address private _companyAdress;
    uint256 private _maxWithdrawPercent;

    //System of Referal
    struct User_Config {
        uint256 refersTotal;
        uint256 referRewardTotal;
        bool exist;
    }
    mapping(address => User_Config) public referSystem;

    bool _MaxLimit = false;
    struct widthLimit {
        uint256 maxAmount;
        uint256 maxLimitAmount;
        uint256 timestamp;
    }
    mapping(address => widthLimit) private maxLimitWidth;
    mapping(address => uint256) private pendingBalance;

    bool _pause = false;
    modifier isPausable() {
        require(!_pause, "The Contract is paused. Presale is paused");
        _;
    }

    constructor(
        uint256 prevent_rug_percent,
        uint256 transactionFee,
        uint256 referBonusPercent,
        uint256 maxWithdrawPercent,
        address companyAddress,
        address _token_Address,
        address bnb_address
    ) {
        _owner = msg.sender;
        _prevent_rug_pull = prevent_rug_percent;
        _transactionFee = transactionFee;
        // Percentage of Bonus Referral System
        _referBonusPercent = referBonusPercent;
        _maxWithdrawPercent = maxWithdrawPercent;
        _companyAdress = companyAddress;
        token_Address = _token_Address;
        _bnb_Address = bnb_address;
    }

    function totalBalance() external view returns (uint256) {
        return payable(address(this)).balance;
    }

    function totalTokens() public view returns (uint256) {
        IBEP20 ContractAdd = IBEP20(token_Address);
        return ContractAdd.balanceOf(address(this));
    }

    function balanceOf(address account) public view override returns (uint256) {
        return pendingBalance[account];
    }

    function ContractStatusPause() public view returns (bool) {
        return _pause;
    }

    function getTransactionFee() public view returns (uint256) {
        return _transactionFee;
    }

    function gatIsMaxLimit() public view returns (bool) {
        return _MaxLimit;
    }

    function getMaxWidthdrawFee() public view returns (uint256) {
        return _maxWithdrawPercent;
    }

    function getMaxLimitUser(address account)
        public view
        returns (
            uint256,
            uint256,
            uint256
        )
    {
        widthLimit storage items = maxLimitWidth[account];
        uint256 resetDaily = items.timestamp == 0
            ? 0
            : (block.timestamp - items.timestamp) / 1 days;
        uint256 maxLimitAmount = items.maxLimitAmount;
        uint256 maxAmount = items.maxAmount;
        if (resetDaily >= 1) {
            maxAmount = 0;
            maxLimitAmount = 0;
        }
        if (maxLimitAmount <= 0) {
            maxLimitAmount = balanceOf(account).mul(_maxWithdrawPercent).div(
                100
            );
        }
        return (maxLimitAmount, maxAmount, items.timestamp);
    }

    function getReferralPercent() public view returns (uint256) {
        return _referBonusPercent;
    }

    function getBnbAddress() public view returns (address) {
        return _bnb_Address;
    }

    /**
     * @dev Enables the contract to receive BNB.
     */
    receive() external payable {}
    fallback() external payable {}

    function transferFromUser(address recipient, uint256 amount, address refer)
        public payable
        isPausable
    {
        address sender = _msgSender();
        uint256 value = msg.value;
        require(
            value > 0 && amount > 0 && amount <= value,
            "You do not have enough balance for this Transaction"
        );

        if (!inTransfer) {
            inTransfer = true;
            uint256 fee = value.mul(_transactionFee).div(100);

            // Check Referral system
            if (!referSystem[refer].exist) {
                referSystem[refer].refersTotal += 1;
                referSystem[refer].exist = true;
            }
            
            // Calculate Fee to Company and Referral
            uint256 referReward = value.mul(_referBonusPercent).div(100);
            uint256 sednRecipient = value.sub(referReward).sub(fee);
            referSystem[refer].referRewardTotal += referReward;

            //Send Transactions
            payable(_companyAdress).transfer(fee);
            payable(refer).transfer(referReward);
            payable(recipient).transfer(sednRecipient);

            emit TransferUser(sender, recipient, amount);
            inTransfer = false;
        }
    }

    function transferSwapUser(uint256 amount) public isPausable {
        address sender = _msgSender();
        require(
            amount > 0 && balanceOf(sender) > 0 && amount <= balanceOf(sender),
            "You do not have enough balance for this Transaction"
        );
        if (!inTransfer) {
            inTransfer = true;
            pendingBalance[sender] -= amount;
            emit Transfer_Swap_User(sender, address(this), amount);
            inTransfer = false;
        }
    }

    function buyWithToken(uint256 tokenAmount, address refer)
        public isPausable
    {
        IBEP20 ContractToken = IBEP20(token_Address);
        uint256 dexBalance = ContractToken.balanceOf(msg.sender);
        require(
            tokenAmount > 0 && tokenAmount <= dexBalance,
            "Insufficient amount for this transaction"
        );
        require(
            ContractToken.transferFrom(msg.sender, address(this), tokenAmount),
            "A transaction error has occurred. Check for approval."
        );

        if (!referSystem[refer].exist) {
            referSystem[refer].refersTotal += 1;
            referSystem[refer].exist = true;
        }

        uint256 referReward = tokenAmount.mul(_referBonusPercent).div(100);
        referSystem[refer].referRewardTotal += referReward;
        pendingBalance[refer] += referReward;

        emit Received(msg.sender, tokenAmount);
    }

    function buyWithBnb(uint256 tokenAmount, address refer)
        public payable isPausable
    {
        uint256 value = msg.value;
        require(
            tokenAmount > 0 && tokenAmount <= value,
            "Insufficient amount for this transaction"
        );
        
        if (!referSystem[refer].exist) {
            referSystem[refer].refersTotal += 1;
            referSystem[refer].exist = true;
        }

        uint256 referReward = value.mul(_referBonusPercent).div(100);
        uint256 sendCompany = referReward.sub(referReward);
        referSystem[refer].referRewardTotal += referReward;

        payable(refer).transfer(referReward);
        payable(_companyAdress).transfer(sendCompany);

        emit Received(msg.sender, tokenAmount);
    }

    function DepositUser(uint256 amount) public isPausable {
        address wallet = msg.sender;
        require(
            wallet != address(0),
            "To make the withdrawal, you need to register a valid address."
        );

        IBEP20 ContractToken = IBEP20(token_Address);
        uint256 dexBalance = ContractToken.balanceOf(msg.sender);
        require(
            amount > 0 && amount <= dexBalance,
            "Insufficient amount for this transaction"
        );
        require(
            ContractToken.transferFrom(wallet, address(this), amount),
            "A transaction error has occurred. Check for approval."
        );
        pendingBalance[wallet] += amount;

        emit DepositeUser(wallet, amount);
    }

    function SendToUser(address wallet, uint256 amount) public onlyOwner {
        pendingBalance[wallet] += amount;
        emit DepositeUser(wallet, amount);
    }

    function WithdOwner(address wallet, uint256 amount) public onlyOwner {
        require(
            balanceOf(wallet) > 0 && amount > 0 && amount <= balanceOf(wallet),
            "You do not have enough balance for this withdrawal"
        );
        if (amount >= balanceOf(wallet)) amount = balanceOf(wallet);
        pendingBalance[wallet] -= amount;

        emit WithdrawnUser(wallet, amount);
    }

    function WithdUser(uint256 amount) public isPausable {
        address wallet = msg.sender;
        uint256 MaxValue = (totalTokens()).mul(_prevent_rug_pull).div(100);
        require(
            amount <= MaxValue, 
            "The withdrawal amount exceeds the limit for this transaction"
        );
        require(
            wallet != address(0),
            "To make the withdrawal, you need to register a valid address."
        );
        if (_MaxLimit) {
            uint256 resetDaily = maxLimitWidth[wallet].timestamp == 0
                ? 0
                : (block.timestamp - maxLimitWidth[wallet].timestamp) / 1 days;
            if (resetDaily >= 1) {
                maxLimitWidth[wallet].maxAmount = 0;
                maxLimitWidth[wallet].maxLimitAmount = 0;
            }

            uint256 maxLimitAmount = maxLimitWidth[wallet].maxLimitAmount;
            if (maxLimitAmount <= 0) {
                maxLimitAmount = balanceOf(wallet).mul(_maxWithdrawPercent).div(
                    100
                );
                maxLimitWidth[wallet].maxLimitAmount = maxLimitAmount;
            }

            uint256 sumMaxLimit = maxLimitWidth[wallet].maxAmount + amount;
            require(
                sumMaxLimit <= maxLimitAmount,
                "It is not possible to make this withdrawal. You have reached your daily maximum limit."
            );
            require(
                amount > 0 && amount <= balanceOf(wallet),
                "You do not have enough balance for this withdrawal"
            );
            maxLimitWidth[wallet].maxAmount += amount;
            maxLimitWidth[wallet].timestamp = block.timestamp;
        }

        if (amount >= balanceOf(wallet)) amount = balanceOf(wallet);
        IBEP20 ContractAdd = IBEP20(token_Address);
        ContractAdd.transfer(wallet, amount);
        pendingBalance[wallet] -= amount;

        emit WithdrawnUser(wallet, amount);
    }

    function WithdToUser(address wallet, uint256 amount) public onlyOwner isPausable {
        require(
            amount > 0 && amount <= balanceOf(wallet),
            "You do not have enough balance for this withdrawal"
        );
        if (amount >= balanceOf(wallet)) amount = balanceOf(wallet);
        pendingBalance[wallet] -= amount;
        IBEP20 ContractAdd = IBEP20(token_Address);
        ContractAdd.transfer(wallet, amount);

        emit WithdrawnUser(wallet, amount);
    }

    function withdTokens(address contractAddress) public onlyOwner {
        require(
            _companyAdress != address(0),
            "To make the withdrawal, you need to register a valid address."
        );
        IBEP20 ContractAdd = IBEP20(contractAddress);
        uint256 dexBalance = ContractAdd.balanceOf(address(this));
        ContractAdd.transfer(_companyAdress, dexBalance);
    }

    function withdBalance() public onlyOwner {
        require(
            _companyAdress != address(0),
            "To make the withdrawal, you need to register a valid address."
        );
        require(
            this.totalBalance() > 0,
            "You do not have enough balance for this withdrawal"
        );
        payable(_companyAdress).transfer(this.totalBalance());
    }

    function setIsMaxLimit() public onlyOwner {
        if (_MaxLimit) {
            _MaxLimit = false;
        } else {
            _MaxLimit = true;
        }
    }

    /*
     * @dev Update the Max Withdraw fee for Withdraw
     * @param addr of the Wallet address
     */
    function setMaxWithdrawFeePercent(uint256 percentage) public onlyOwner {
        require(percentage <= 100, "The percentage cannot exceed 100%.");
        _maxWithdrawPercent = percentage;
    }

    /*
     * @dev Update the addres token
     * @param addr of the token address
     */
    function setTokendress(address tokenAddr) public onlyOwner {
        require(tokenAddr.isContract(), "The address entered is not valid");
        token_Address = tokenAddr;
    }

    /*
     * @dev Update the BnbAdress for Bnbraw
     * @param addr of the Wallet address
     */
    function setBnbAdress(address BnbAdress) public onlyOwner {
        _bnb_Address = BnbAdress;
    }

    function setPreventPercent(uint256 prevent_percent) public onlyOwner {
        _prevent_rug_pull = prevent_percent;
    }

    /*
     * @dev Update the Company Address
     * @param addr of the Wallet address
     */
    function setCompanyAdress(address companyAddress) public onlyOwner {
        _companyAdress = companyAddress;
    }

    /**
     * @dev Change fee amounts. Reviewed! Enter only the entire fee amount.
     */
    function updateFee(uint256 transactionFee) public onlyOwner {
        require(transactionFee <= 100, "The percentage cannot exceed 100%.");
        _transactionFee = transactionFee;
    }

    function setReferralPercent(uint256 referralPercent) public onlyOwner {
        require(referralPercent <= 100, "The percentage cannot exceed 100%.");
        _referBonusPercent = referralPercent;
    }

    function setPause() public onlyOwner {
        if (_pause) {
            _pause = false;
        } else {
            _pause = true;
        }
    }

    event DepositeUser(address indexed from, uint256 amount);
    event WithdrawnUser(address indexed from, uint256 amount);
    event TransferUser(address indexed from, address indexed to, uint256 value);
    event Transfer_Swap_User(
        address indexed from,
        address indexed to,
        uint256 value
    );
    event Received(address indexed from, uint256 amount);
}