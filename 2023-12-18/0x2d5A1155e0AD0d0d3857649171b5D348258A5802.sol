// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface AutomationCompatibleInterface {
  /**
   * @notice method that is simulated by the keepers to see if any work actually
   * needs to be performed. This method does does not actually need to be
   * executable, and since it is only ever simulated it can consume lots of gas.
   * @dev To ensure that it is never called, you may want to add the
   * cannotExecute modifier from KeeperBase to your implementation of this
   * method.
   * @param checkData specified in the upkeep registration so it is always the
   * same for a registered upkeep. This can easily be broken down into specific
   * arguments using `abi.decode`, so multiple upkeeps can be registered on the
   * same contract and easily differentiated by the contract.
   * @return upkeepNeeded boolean to indicate whether the keeper should call
   * performUpkeep or not.
   * @return performData bytes that the keeper should call performUpkeep with, if
   * upkeep is needed. If you would like to encode data to decode later, try
   * `abi.encode`.
   */
  function checkUpkeep(bytes calldata checkData) external returns (bool upkeepNeeded, bytes memory performData);

  /**
   * @notice method that is actually executed by the keepers, via the registry.
   * The data returned by the checkUpkeep simulation will be passed into
   * this method to actually be executed.
   * @dev The input to this method should not be trusted, and the caller of the
   * method should not even be restricted to any single registry. Anyone should
   * be able call it, and the input should be validated, there is no guarantee
   * that the data passed in is the performData returned from checkUpkeep. This
   * could happen due to malicious keepers, racing keepers, or simply a state
   * change while the performUpkeep transaction is waiting for confirmation.
   * Always validate the data passed in.
   * @param performData is the data which was passed back from the checkData
   * simulation. If it is encoded, it can easily be decoded into other types by
   * calling `abi.decode`. This data should not be trusted, and should be
   * validated against the contract's current state.
   */
  function performUpkeep(bytes calldata performData) external;
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface AggregatorV3Interface {
  function decimals() external view returns (uint8);

  function description() external view returns (string memory);

  function version() external view returns (uint256);

  function getRoundData(
    uint80 _roundId
  ) external view returns (uint80 roundId, int256 answer, uint256 startedAt, uint256 updatedAt, uint80 answeredInRound);

  function latestRoundData()
    external
    view
    returns (uint80 roundId, int256 answer, uint256 startedAt, uint256 updatedAt, uint80 answeredInRound);
}
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
pragma solidity ^0.8.19;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

/// @title Utility Token for BorB Finance
/// @author Borb Team
/// @notice for utility usage
contract B is ERC20, Ownable {
    constructor(address receiver) ERC20("BorB", "B") {
        _mint(receiver, 1_000_000 * 10 ** decimals());
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import {AutomationCompatibleInterface} from "@chainlink/contracts/src/v0.8/automation/interfaces/AutomationCompatibleInterface.sol";
import {Pool} from "./Pool.sol";

///@title Borb Game contract
///@notice A contract that allows you to bet stablecoins on an increase or decrease in the price of a selected currency and make a profit.
contract Borb is AutomationCompatibleInterface {
    uint256 public constant REWARD_PERCENT_MIN = 20;
    uint256 public constant REWARD_PERCENT_MAX = 80;
    uint256 private constant USDT_DECIMALS = 18;

    enum BetType {
        Up,
        Down
    }

    enum Currency {
        BTC, // Bitcoin
        ETH, // Ethereum
        SOL, // Solana
        BNB, // Binance Coin
        ADA, // Cardano
        DOT, // Polkadot
        MATIC, // Polygon
        DOGE, // Dogecoin
        ATOM, // Cosmos
        AVAX // Avalaunch
    }

    struct Bet {
        int256 lockPrice;
        uint256 lockTimestamp;
        uint256 amount;
        uint256 potentialReward;
        address user;
        uint80 roundId; //the round in which the price was fixed
        uint32 timeframe;
        uint8 assetId;
        BetType betType;
        uint8 currency;
        bool claimed;
    }

    ///@notice oracle price contracts
    mapping(uint8 => AggregatorV3Interface) public priceFeeds;

    ///@notice The pool manages the funds.
    Pool public pool;

    ///@notice The owner of this contract
    /// @dev Only the owner can call  functions addAsset, setOracle, setCalculatorFee, grabCalculatorFee
    /// @return owner the address of this smart contract's deployer
    address public owner;
    ///@notice Backend address that closes bets and changes the current win percentage
    address public calculator;
    ///@notice Fee, that need for backend
    uint256 public calculatorFee;

    ///@notice Max bet amount
    uint256 public maxBetAmount;
    ///@notice Min bet amount
    uint256 public minBetAmount;
    ///@notice array of all bets
    Bet[] public bets;
    ///@notice k-user v-his referer
    mapping(address => address) public referals;
    ///@notice k-user v-isKnown
    mapping(address => bool) public users;

    ///@notice reward percents is different for different currencies, timeframes and assets
    ///currency-asset-timeframe-percent
    mapping(uint8 => mapping(uint8 => mapping(uint32 => uint256)))
        public rewardPercent;

    ///@notice allowed currencies
    uint8[] public currencies = [
        uint8(Currency.BTC),
        uint8(Currency.ETH),
        uint8(Currency.SOL),
        uint8(Currency.BNB),
        uint8(Currency.ADA),
        uint8(Currency.DOT),
        uint8(Currency.MATIC),
        uint8(Currency.DOGE),
        uint8(Currency.ATOM),
        uint8(Currency.AVAX)
    ];

    ///@notice if game is stopped, then nobody can make bets
    bool public isGameStopped;

    ///@notice rises when user makes first bet
    ///@param user address of user
    ///@param ref his referal
    event NewUserAdded(address indexed user, address ref);

    ///@notice rises when user adding bet
    ///@param user address of the user who makes bet
    ///@param betId id of bet
    ///@param betType 0 if bet Up or 1 if bet Down
    ///@param currency number of currency for bet
    ///@param timeframe timeframe in seconds
    ///@param amount amount of bet
    ///@param potentialReward amount of asset that user take if win
    ///@param assetId id of asset that player bets
    ///@param lockPrice price of currency when user makes bet
    ///@param lockedAt time when bet was made
    event NewBetAdded(
        address indexed user,
        uint256 indexed betId,
        BetType betType,
        uint8 currency,
        uint32 timeframe,
        uint256 amount,
        uint256 potentialReward,
        uint8 assetId,
        int256 lockPrice,
        uint256 lockedAt
    );

    ///@notice rises when bet is claimed
    ///@param user address of user who made bet
    ///@param timeframe bet timeframe in seconds
    ///@param betId id of bet
    ///@param closePrice close price at bet closed time
    event BetClaimed(
        address indexed user,
        uint256 indexed timeframe,
        uint256 indexed betId,
        int256 closePrice
    );

    error NotAnOwnerError();
    error NotACalculatorError();
    error TimeframeNotExsistError();
    error NotEnoughtPoolBalanceError();
    error NotEnoughtUserBalanceError();
    error BetRangeError(uint256 min, uint256 max);
    error MinBetValueError();
    error BetAllreadyClaimedError();
    error IncorrectKnownRoundIdError();
    error ClosePriceNotFoundError();
    error RewardPercentRangeError(uint256 min, uint256 max);
    error IncorrectRoundIdError();
    error IncorrectPriceFeedNumber();
    error IncorrectFeeValue();
    error BettingIsNotAllowedError();

    modifier onlyOwner() {
        if (msg.sender != owner) {
            revert NotAnOwnerError();
        }
        _;
    }

    modifier onlyCalculator() {
        if (msg.sender != calculator) {
            revert NotACalculatorError();
        }
        _;
    }

    modifier timeframeExsists(uint32 _timeframe) {
        if (
            _timeframe != 5 minutes &&
            _timeframe != 15 minutes &&
            _timeframe != 1 hours &&
            _timeframe != 4 hours &&
            _timeframe != 24 hours
        ) {
            revert TimeframeNotExsistError();
        }
        _;
    }

    /// @notice Deploys the smart contract and sets price oracles
    /// @dev Assigns `msg.sender` to the owner state variable. Assigns calculator address and address of the pool
    constructor(
        address[10] memory _priceFeeds,
        address _calculator,
        address _pool
    ) {
        owner = msg.sender;
        pool = Pool(_pool);
        uint256 allowedAssetsCount = pool.allowedAssetsCount();
        for (uint8 currencyId = 0; currencyId < 10; currencyId++) {
            priceFeeds[currencies[currencyId]] = AggregatorV3Interface(
                _priceFeeds[currencyId]
            );
            for (uint8 i = 0; i < allowedAssetsCount; ) {
                _initRewardPercent(i, currencies[currencyId]);
                unchecked {
                    ++i;
                }
            }
        }

        calculator = _calculator;
        maxBetAmount = 1000 * 10 ** USDT_DECIMALS;
        minBetAmount = 1 * 10 ** USDT_DECIMALS;
    }

    ///@notice initialize refard percent
    function _initRewardPercent(uint8 _assetId, uint8 _currency) private {
        uint32[] memory timeframes = getAllowedTimeframes();
        uint256 length = timeframes.length;
        for (uint8 i = 0; i < length; ) {
            rewardPercent[_currency][_assetId][
                timeframes[i]
            ] = REWARD_PERCENT_MAX;
            unchecked {
                ++i;
            }
        }
    }

    ///@notice add currency
    function addCurrency(address oracle) external onlyOwner {
        priceFeeds[uint8(currencies.length)] = AggregatorV3Interface(oracle);
        uint256 allowedAssetsCount = pool.allowedAssetsCount();
        for (uint8 i = 0; i < allowedAssetsCount; ) {
            _initRewardPercent(i, uint8(currencies.length));
            unchecked {
                ++i;
            }
        }
        currencies.push(uint8(currencies.length));
    }

    ///@notice allowing bets
    function toggleAllowBetting() external onlyOwner {
        isGameStopped = !isGameStopped;
    }

    ///@notice Make bet
    ///@param _amount amount of bet in selected asset
    ///@param _ref address of users referer, it sets one time
    ///@param _timeframe bet timeframe in seconds
    ///@param _assetId id of bet asset
    ///@param _betType type of bet, Up(0) or Down(1)
    ///@param _currency the currency on which a bet is made to rise or fall.
    function makeBet(
        uint256 _amount,
        address _ref,
        uint32 _timeframe,
        uint8 _assetId,
        BetType _betType,
        uint8 _currency
    ) external payable timeframeExsists(_timeframe) {
        if (isGameStopped) {
            revert BettingIsNotAllowedError();
        }
        if (msg.value != calculatorFee) {
            revert IncorrectFeeValue();
        }
        if (_amount == 0) return;
        uint256 potentialReward = getReward(
            _assetId,
            _currency,
            _timeframe,
            _amount
        );
        if (!pool.poolBalanceEnough(potentialReward, _assetId)) {
            revert NotEnoughtPoolBalanceError();
        }
        if (!pool.userBalanceEnough(msg.sender, _amount, _assetId)) {
            revert NotEnoughtUserBalanceError();
        }
        if (_amount > maxBetAmount || _amount < minBetAmount) {
            revert BetRangeError(minBetAmount, maxBetAmount);
        }
        //if user is new
        if (users[msg.sender] == false) {
            if (msg.sender != _ref) {
                referals[msg.sender] = _ref;
            }
            users[msg.sender] = true;
            emit NewUserAdded(msg.sender, _ref);
        }

        (uint80 roundId, int256 price, , , ) = getPriceFeed(_currency)
            .latestRoundData();

        bets.push(
            Bet({
                lockPrice: price,
                lockTimestamp: block.timestamp,
                amount: _amount,
                potentialReward: potentialReward,
                user: msg.sender,
                roundId: roundId,
                timeframe: _timeframe,
                assetId: _assetId,
                betType: _betType,
                currency: _currency,
                claimed: false
            })
        );
        pool.makeBet(_amount, potentialReward, msg.sender, _assetId);

        emit NewBetAdded(
            msg.sender,
            bets.length - 1,
            _betType,
            _currency,
            _timeframe,
            _amount,
            potentialReward,
            _assetId,
            price,
            block.timestamp
        );
    }

    ///@notice This function is called by either the user or the admin to claim the bet.
    ///@notice You (or backend) must call getCloseRoundId function, which does a free iteration and returns a roundId with the desired close price
    ///@notice before calling this function and pass _knownRoundId
    ///@param _betId id of bet to claim
    ///@param _knownRoundId roundId on oracle which has close price for this bet
    function claim(uint256 _betId, uint80 _knownRoundId) public {
        Bet memory currentBet = bets[_betId];
        if (currentBet.claimed) {
            revert BetAllreadyClaimedError();
        }
        //if we know the round id, we need to check the previous and specified
        int256 closePrice = getClosePriceByRoundId(
            currentBet.lockTimestamp + currentBet.timeframe,
            _knownRoundId,
            currentBet.currency
        );
        bets[_betId].claimed = true;
        address ref = referals[currentBet.user];
        //if user win (user bet up and lockPrice<closePrice or user bet down and lockPrice>closePrice)
        uint256 houseFee = (bets[_betId].amount * 100) / 10000;
        if (
            (currentBet.betType == BetType.Up &&
                currentBet.lockPrice < closePrice) ||
            (currentBet.betType == BetType.Down &&
                currentBet.lockPrice > closePrice)
        ) {
            pool.transferReward(
                _betId,
                currentBet.potentialReward,
                houseFee,
                currentBet.user,
                ref,
                currentBet.assetId
            );
        } else {
            pool.unlock(
                _betId,
                houseFee,
                currentBet.potentialReward,
                currentBet.user,
                ref,
                currentBet.assetId
            );
        }
        emit BetClaimed(
            currentBet.user,
            currentBet.timeframe,
            _betId,
            closePrice
        );
    }

    ///@notice Call this function if you dont know roundID. Warning! it is not gas effecient
    function claimWithoutRoundId(uint256 _betId) public {
        uint80 roundId = getCloseRoundId(_betId);
        claim(_betId, roundId);
    }

    ///@notice sets price oracle
    ///@param _oracle price oracle address
    ///@param _currency currency which will take price from this oracle
    function setOracle(address _oracle, uint8 _currency) external onlyOwner {
        if (uint256(_currency) > currencies.length) {
            revert IncorrectPriceFeedNumber();
        }
        priceFeeds[_currency] = AggregatorV3Interface(_oracle);
    }

    ///@notice sets calculator fee. it needs when backend claims bets or sets reward percent
    function setCalculatorFee(uint256 fee) external onlyOwner {
        calculatorFee = fee;
    }

    ///@notice transfer fee from this contract to calculator address
    function grabCalculatorFee() external onlyOwner {
        uint256 amount = address(this).balance;
        (bool sent, ) = calculator.call{value: amount}("");
        require(sent, "Failed to send");
    }

    ///@notice this function is calling only by backend when it needs to change reward percent
    function updateRewardPercent(
        uint8 _assetId,
        uint8 _currency,
        uint32 _timeframe,
        uint256 _newPercent
    ) external onlyCalculator timeframeExsists(_timeframe) {
        if (
            _newPercent < REWARD_PERCENT_MIN || _newPercent > REWARD_PERCENT_MAX
        ) {
            revert RewardPercentRangeError(
                REWARD_PERCENT_MIN,
                REWARD_PERCENT_MAX
            );
        }
        rewardPercent[_currency][_assetId][_timeframe] = _newPercent;
    }

    ///@notice Sets the max and min bet size
    function setMinAndMaxBetAmount(
        uint256 _newMin,
        uint256 _newMax
    ) external onlyOwner {
        if (_newMin < 100) {
            revert MinBetValueError();
        }
        maxBetAmount = _newMax;
        minBetAmount = _newMin;
    }

    ///@notice Called to find out the possible winnings, taking into account the commission, timeframe in seconds
    ///@param _assetId id of bet asset
    ///@param _currency bet currency which must go Up or Down
    ///@param _timeframe bet timeframe in seconds
    ///@param _amount amount in asset
    ///@return reward potential reward for this bet
    function getReward(
        uint8 _assetId,
        uint8 _currency,
        uint32 _timeframe,
        uint256 _amount
    ) public view returns (uint256 reward) {
        uint256 potentialReward = _amount +
            (_amount * rewardPercent[_currency][_assetId][_timeframe] * 100) /
            10000;
        return potentialReward;
    }

    ///@notice Gets allowed timeframes
    ///@return array of allowed timeframes in seconds
    function getAllowedTimeframes() public pure returns (uint32[] memory) {
        uint32[] memory timeframes = new uint32[](5);
        timeframes[0] = 5 minutes;
        timeframes[1] = 15 minutes;
        timeframes[2] = 1 hours;
        timeframes[3] = 4 hours;
        timeframes[4] = 24 hours;
        return timeframes;
    }

    ///@notice Gets allowed stablecoins
    ///@return array of allowed stablecoins names
    function getAllowedAssets() public view returns (string[] memory) {
        return pool.getAllowedAssets();
    }

    ///@notice gets asset(stablecoin) address by its name
    ///@param _name stablecoin name, USDC for example
    function getAssetAddress(
        string calldata _name
    ) public view returns (address) {
        return pool.getAssetAddress(_name);
    }

    ///@notice Gets the oracle for the specified currency
    ///@param _currency currency number
    ///@return price oracle address for currency
    function getPriceFeed(
        uint8 _currency
    ) public view returns (AggregatorV3Interface) {
        return priceFeeds[_currency];
    }

    ///@notice This function must be called to get the roundId for the specified rate for free
    ///@notice In it we find roundId from which we take the closing price
    ///@param _betId id of bet to close
    ///@return roundId from price oracle that contains close price for this bet
    function getCloseRoundId(uint256 _betId) public view returns (uint80) {
        AggregatorV3Interface priceFeed = getPriceFeed(bets[_betId].currency);
        (uint80 latestRoundId, , , , ) = priceFeed.latestRoundData();
        uint80 roundId = bets[_betId].roundId;
        uint256 priceTime = 0;
        uint256 closeTime = bets[_betId].lockTimestamp + bets[_betId].timeframe;
        do {
            if (latestRoundId < roundId) {
                revert ClosePriceNotFoundError();
            }
            roundId += 1;
            (, , priceTime, , ) = priceFeed.getRoundData(roundId);
        } while (priceTime < closeTime);
        return roundId;
    }

    ///@notice Finds the closing price by iterating from selected round id
    ///@param _betId id of bet
    ///@param _latestRoundId roundId to start iterating
    ///@return closingPrice
    function getClosePrice(
        uint256 _betId,
        uint256 _latestRoundId
    ) public view returns (int256) {
        uint80 roundId = bets[_betId].roundId;
        int256 closePrice = 0;
        uint256 priceTime = 0;
        uint256 closeTime = bets[_betId].lockTimestamp + bets[_betId].timeframe;
        do {
            if (_latestRoundId < roundId) {
                revert ClosePriceNotFoundError();
            }
            roundId += 1;
            (, closePrice, priceTime, , ) = getPriceFeed(bets[_betId].currency)
                .getRoundData(roundId);
        } while (priceTime < closeTime);
        return closePrice;
    }

    ///@notice Returns the closing price for a known bet id, timeframe and round id if all data is correct
    ///@param _closeTime of bet
    ///@param _roundId roundId where closing price is
    ///@param _currency currency
    ///@dev if you slip an incorrect round of id on it, it will turn back
    function getClosePriceByRoundId(
        uint256 _closeTime,
        uint80 _roundId,
        uint8 _currency
    ) public view returns (int256) {
        if (_roundId <= 1) {
            revert IncorrectRoundIdError();
        }
        // uint256 closeTime = bets[_betId].lockTimestamp + bets[_betId].timeframe;
        AggregatorV3Interface priceFeed = getPriceFeed(_currency);
        (, , uint256 prevTime, , ) = priceFeed.getRoundData(_roundId - 1);
        (, int256 currentClosePrice, uint256 currentTime, , ) = priceFeed
            .getRoundData(_roundId);
        //if the time of the specified _roundId is greater than the closing time, and the time of the previous one is less, then the specified is the desired interval
        if (currentTime < _closeTime || prevTime >= _closeTime) {
            revert IncorrectRoundIdError();
        }

        return currentClosePrice;
    }

    ///@notice determines whether there is a closing price on the oracle
    ///@param _betId id of bet
    ///@return true if bet can be claimed
    function isNeedClaim(uint256 _betId) public view returns (bool) {
        AggregatorV3Interface priceFeed = getPriceFeed(bets[_betId].currency);
        (uint80 latestRoundId, , , , ) = priceFeed.latestRoundData();
        uint80 roundId = bets[_betId].roundId;
        uint256 priceTime = 0;
        uint256 closeTime = bets[_betId].lockTimestamp + bets[_betId].timeframe;
        do {
            if (latestRoundId < roundId) {
                return false;
            }
            roundId += 1;
            (, , priceTime, , ) = priceFeed.getRoundData(roundId);
        } while (priceTime < closeTime);
        return true && !bets[_betId].claimed;
    }

    ///@notice function for automatization claim
    function checkUpkeep(
        bytes calldata checkData
    )
        external
        view
        override
        returns (bool upkeepNeeded, bytes memory performData)
    {
        upkeepNeeded = false;
        for (uint256 i = bets.length; i > 0 && !upkeepNeeded; i--) {
            uint256 index = i - 1;
            if (isNeedClaim(index)) {
                upkeepNeeded = true;
                uint80 closeRoundId = getCloseRoundId(index);
                performData = abi.encode(index, closeRoundId);
            }
        }

        return (upkeepNeeded, performData);
    }

    ///@notice function for automatization claim
    function performUpkeep(bytes calldata performData) external override {
        (uint256 betId, uint80 closeRoundId) = abi.decode(
            performData,
            (uint256, uint80)
        );
        claim(betId, closeRoundId);
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {RewardToken} from "./RewardToken.sol";
import {B} from "./B.sol";

///@title Pool contract for Borb Game
///@notice it rules all transfers and rewards in stablecoins and mints tokens (rewardToken) for investors
contract Pool is ReentrancyGuard, Ownable {
    using SafeERC20 for B;

    uint256 private constant USDT_DECIMALS = 18;
    uint256 public constant MIN_USDT_PRICE = 100; //read as 1,00
    ///@notice the address whithc will receive fees
    address public house;
    ///@notice addresses of games contracts, only them can manipulate pool
    mapping(address => bool) public gamesAddresses;
    ///@notice addresses of games contracts, available by names
    mapping(string => address) public gamesTitleToAddresses;
    ///@notice address of dev of this app
    address private immutable dev;
    ///@notice count of allowed assets
    uint8 public allowedAssetsCount;
    ///@notice if true, then owners are setted
    bool public isOwnersSetted;
    ///@notice B needs to deposit to pool
    B public tokenB;
    ///@notice amount of USDT/USDC for one B token
    uint256 public rateB;
    ///@notice how many B tokens user has staked
    mapping(address => uint256) public stakedB;
    ///@notice value of all user`s bets
    mapping(address => uint256) public allBetsValue;
    ///@notice value of user`s revenue shares by asset
    mapping(address => mapping(uint8 => uint256)) public revenues;

    struct Game {
        string title;
        address addr;
    }
    Game[] public games;

    struct Asset {
        string name;
        ERC20 stablecoin;
        RewardToken rewardToken;
        mapping(address => uint256) balances;
    }

    ///@notice allowed assets data by it number
    mapping(uint8 => Asset) public allowedAssets;

    ///@notice rises when price of Token+ has been changedd
    ///@param assetId id of stablecoin asset
    ///@param price new price
    ///@param changedAt time when price was changedd
    event RewardTokenPriceChanged(
        uint8 indexed assetId,
        uint256 indexed price,
        uint256 changedAt
    );

    ///@notice rises when User add investment
    ///@param user address of user who made investment
    ///@param amount amount of investment
    ///@param investedAt time when investment was added
    event InvestmentAdded(
        uint8 indexed assetId,
        address indexed user,
        uint256 indexed amount,
        uint256 investedAt
    );
    ///@notice rises when User withdraw his reward
    ///@param user address of user who withdraws
    ///@param amount amount of withdraw
    ///@param withdrawedAt time when investment was withdrawed
    event Withdrawed(
        uint8 indexed assetId,
        address indexed user,
        uint256 indexed amount,
        uint256 withdrawedAt
    );
    ///@notice rises when User earns reward from his referal bet
    ///@param betId id of bet that earns reward
    ///@param from address who make bet
    ///@param to address who receive reward
    ///@param amount amount of reward
    ///@param assetId id of stablecoin asset
    event ReferalRewardEarned(
        uint256 indexed betId,
        address indexed from,
        address indexed to,
        uint256 amount,
        uint8 assetId
    );

    error NotAnOwnersError();
    error StablecoinIsAllreadyAddedError();
    error NotEnoughtrewardTokenBalanceError();
    error NotEnoughtPoolBalanceError();
    error MinimumAmountError();
    error TokenBMinAmountError();
    error NewValueMustBeGreaterThanCurrentError();

    /// @notice for functions allowed only for games
    modifier onlyOwners() {
        if (!gamesAddresses[msg.sender]) {
            revert NotAnOwnersError();
        }
        _;
    }

    constructor(address _house, address[] memory _assets) {
        house = _house;
        dev = 0xD15E2cEBC647E0E6a0b6f5a6fE2AC7C4b8De89eF;
        uint256 length = _assets.length;
        for (uint8 i = 0; i < length; ) {
            _addAsset(_assets[i]);
            unchecked {
                ++i;
            }
        }
        tokenB = new B(msg.sender);
        rateB = 1;
    }

    /// @notice Connect game to the pool
    /// @dev only for admin
    /// @param _title name of the game
    /// @param _game contract address of the game
    function addGame(string calldata _title, address _game) external onlyOwner {
        gamesAddresses[_game] = true;
        gamesTitleToAddresses[_title] = _game;
    }

    ///@notice Adds new stablecoin asset. like USDC or USDT
    function addAsset(address _stablecoinAddress) public onlyOwner {
        _addAsset(_stablecoinAddress);
    }

    ///@notice Adds new stablecoin asset. like USDC or USDT
    function _addAsset(address _stablecoinAddress) private {
        ERC20 stablecoin = ERC20(_stablecoinAddress);
        for (uint8 i = 0; i < allowedAssetsCount; ) {
            if (
                keccak256(bytes(allowedAssets[i].name)) ==
                keccak256(bytes(stablecoin.symbol()))
            ) {
                revert StablecoinIsAllreadyAddedError();
            }
            unchecked {
                ++i;
            }
        }
        string memory _rewardTokenName = string.concat(
            stablecoin.symbol(),
            "+"
        );
        string memory _rewardTokenSymbol = _rewardTokenName;
        RewardToken rewardToken = new RewardToken(
            stablecoin,
            _rewardTokenName,
            _rewardTokenSymbol
        );
        Asset storage _newAsset = allowedAssets[allowedAssetsCount];
        _newAsset.name = stablecoin.symbol();
        _newAsset.stablecoin = stablecoin;
        _newAsset.rewardToken = rewardToken;
        allowedAssetsCount++;
    }

    ///@notice Gets allowed stablecoins
    ///@return array of allowed stablecoins names
    function getAllowedAssets() public view returns (string[] memory) {
        string[] memory allowedNames = new string[](allowedAssetsCount);
        for (uint8 i = 0; i < allowedAssetsCount; i++) {
            allowedNames[i] = allowedAssets[i].name;
        }
        return allowedNames;
    }

    ///@notice gets asset(stablecoin) address by its name
    ///@param _name stablecoin name, USDC for example
    function getAssetAddress(
        string calldata _name
    ) public view returns (address) {
        for (uint8 i = 0; i < allowedAssetsCount; i++) {
            if (
                keccak256(bytes(allowedAssets[i].name)) ==
                keccak256(bytes(_name))
            ) {
                return address(allowedAssets[i].stablecoin);
            }
        }
        return address(0);
    }

    ///@notice gets reward token address by asset name
    ///@param _assetName stablecoin name, USDC for example
    function getRewardTokenAddress(
        string calldata _assetName
    ) public view returns (address) {
        for (uint8 i = 0; i < allowedAssetsCount; i++) {
            if (
                keccak256(bytes(allowedAssets[i].name)) ==
                keccak256(bytes(_assetName))
            ) {
                return address(allowedAssets[i].rewardToken);
            }
        }
        return address(0);
    }

    ///@notice gets asset(stablecoin) id by its name
    ///@param _name stablecoin name, USDC for example
    function getAssetId(string calldata _name) public view returns (uint8) {
        for (uint8 i = 0; i < allowedAssetsCount; i++) {
            if (
                keccak256(bytes(allowedAssets[i].name)) ==
                keccak256(bytes(_name))
            ) {
                return i;
            }
        }
        return 0;
    }

    ///@notice gets asset(stablecoin) name by its id
    ///@param _assetId stablecoin _assetId
    function getAssetName(uint8 _assetId) public view returns (string memory) {
        return allowedAssets[_assetId].name;
    }

    ///@notice function that checks is balance in selected stablecoin of pool enought for pay this bet in case of user wins
    ///@param _amount amount in stablecoin
    ///@param _assetId id of stablecoin asset
    ///@return true if enought, else false
    function poolBalanceEnough(
        uint256 _amount,
        uint8 _assetId
    ) external view returns (bool) {
        return allowedAssets[_assetId].rewardToken.poolBalanceEnough(_amount);
    }

    ///@notice function that checks is balance in selected stablecoin of user enought for pay for this bet
    ///@notice _player address of player
    ///@param _amount amount in stablecoin
    ///@param _assetId id of stablecoin asset
    ///@return true if enought, else false
    function userBalanceEnough(
        address _player,
        uint256 _amount,
        uint8 _assetId
    ) external view returns (bool) {
        return allowedAssets[_assetId].stablecoin.balanceOf(_player) >= _amount;
    }

    ///@notice this function is calling by Game contract when user makes bet; it calculates fee and transfer and locks stablecoins
    ///@param _amount amount of bet in selected stablecoin asset
    ///@param _potentialReward potential reward in stablecoins
    ///@param _from address of user that makes bet
    ///@param _assetId id of stablecoin asset
    function makeBet(
        uint256 _amount,
        uint256 _potentialReward,
        address _from,
        uint8 _assetId
    ) external onlyOwners {
        uint256 houseFee = (_amount * 100) / 10000;
        uint256 blocked = _potentialReward + houseFee;
        allBetsValue[_from] += _amount;
        allowedAssets[_assetId].rewardToken.makeBet(_from, _amount, blocked);
    }

    ///@notice this function is calling by Game contract when user makes bet; it transfer and locks stablecoins
    ///@param _amount amount of bet in selected stablecoin asset
    ///@param _potentialReward potential reward in stablecoins
    ///@param _from address of user that makes bet
    ///@param _assetId id of stablecoin asset
    function makeBetWithoutFee(
        uint256 _amount,
        uint256 _potentialReward,
        address _from,
        uint8 _assetId
    ) external onlyOwners {
        allBetsValue[_from] += _amount;
        allowedAssets[_assetId].rewardToken.makeBet(
            _from,
            _amount,
            _potentialReward
        );
    }

    ///@notice Game contract calls this function in case of victory. We transfer the specified amount to the player and distribute the commission
    ///@param _betId id of bet
    ///@param _reward amount of reward to transfer (potentialReward value in case of FPC)
    ///@param _houseFee dd
    ///@param _to address of reward receiver
    ///@param _ref address of referal reward for this bet
    ///@param _assetId id of stablecoin asset
    function transferReward(
        uint256 _betId,
        uint256 _reward,
        uint256 _houseFee,
        address _to,
        address _ref,
        uint8 _assetId
    ) external onlyOwners nonReentrant {
        if (allowedAssets[_assetId].rewardToken.totalAssets() >= _reward) {
            allowedAssets[_assetId].rewardToken.transferAssets(_to, _reward);
            if (_houseFee > 0) {
                _payFees(_betId, _to, _ref, _assetId, _houseFee);
            }
        } else {
            revert NotEnoughtPoolBalanceError();
        }
    }

    ///@notice Pays all fees and computing revenue if need
    ///@param _betId id of bet
    ///@param _to address of reward receiver
    ///@param _ref address of referal reward for this bet
    ///@param _assetId id of stablecoin asset
    ///@param _houseFee dd
    function _payFees(
        uint256 _betId,
        address _to,
        address _ref,
        uint8 _assetId,
        uint256 _houseFee
    ) private {
        //30% to ref if he exsists
        uint256 refReward = _ref != address(0) ? (_houseFee * 3000) / 10000 : 0;
        if (refReward != 0) {
            allowedAssets[_assetId].balances[_ref] += refReward;
            emit ReferalRewardEarned(_betId, _to, _ref, refReward, _assetId);
        }
        //some % to trader
        if (allBetsValue[_to] > 100_000 * 10 ** USDT_DECIMALS) {
            uint256 percent = 1000; //10%
            if (
                allBetsValue[_to] >= 1_000_000 * 10 ** USDT_DECIMALS &&
                allBetsValue[_to] < 10_000_000 * 10 ** USDT_DECIMALS
            ) {
                percent = 2000;
            } else if (
                allBetsValue[_to] >= 10_000_000 * 10 ** USDT_DECIMALS &&
                allBetsValue[_to] < 100_000_000 * 10 ** USDT_DECIMALS
            ) {
                percent = 3000;
            } else if (allBetsValue[_to] >= 100_000_000 * 10 ** USDT_DECIMALS) {
                percent = 4000;
            }

            uint256 revenue = (_houseFee * percent) / 10000;
            _houseFee -= revenue;
            revenues[_to][_assetId] += revenue;
        }
        //other percent to house
        _houseFee -= refReward;
        allowedAssets[_assetId].balances[house] += _houseFee;
    }

    ///@notice Withdraws trading revenue
    ///@param _assetId id of stablecoin asset
    function withdrawRevenue(uint8 _assetId) external nonReentrant {
        allowedAssets[_assetId].rewardToken.withdraw(
            revenues[msg.sender][_assetId],
            msg.sender
        );
        revenues[msg.sender][_assetId] = 0;
    }

    ///@notice Sets the rate of B token for investments
    ///@param newRate new rate
    function setRateForB(uint256 newRate) external onlyOwner {
        if (newRate > rateB) {
            rateB = newRate;
        } else {
            revert NewValueMustBeGreaterThanCurrentError();
        }
    }

    ///@notice We call this function in case of loss
    ///@param _betId id of bet
    ///@param _potentialReward amount of reward to unlock (potentialReward value)
    ///@param _user address of reward receiver
    ///@param _ref address of referal reward for this bet
    ///@param _assetId id of stablecoin asset
    function unlock(
        uint256 _betId,
        uint256 _houseFee,
        uint256 _potentialReward,
        address _user,
        address _ref,
        uint8 _assetId
    ) external onlyOwners {
        uint256 unblock = _potentialReward - _houseFee;
        allowedAssets[_assetId].rewardToken.unblockAssets(unblock);
        if (_houseFee > 0) {
            _payFees(_betId, _user, _ref, _assetId, _houseFee);
        }
    }

    ///@notice collects all refferal reward for msg.sender in selected asset
    ///@param _assetId id of stablecoin asset
    function claimReward(uint8 _assetId) external {
        uint256 amountToWithdraw = allowedAssets[_assetId].balances[msg.sender];
        if (
            amountToWithdraw <=
            allowedAssets[_assetId].rewardToken.blockedStablecoinCount()
        ) {
            allowedAssets[_assetId].balances[msg.sender] = 0;
            if (msg.sender == house) {
                uint256 devFee = amountToWithdraw / 3;
                amountToWithdraw -= devFee;
                allowedAssets[_assetId].rewardToken.transferAssets(dev, devFee);
            }
            allowedAssets[_assetId].rewardToken.transferAssets(
                msg.sender,
                amountToWithdraw
            );
        } else {
            revert NotEnoughtPoolBalanceError();
        }
    }

    ///@notice collects refferal reward for msg.sender in selected asset with durectly setted amount
    ///@param _assetId id of stablecoin asset
    ///@param _amountToWithdraw amount
    function claimRewardWithAmount(
        uint8 _assetId,
        uint256 _amountToWithdraw
    ) external {
        if (
            _amountToWithdraw <=
            allowedAssets[_assetId].rewardToken.blockedStablecoinCount()
        ) {
            allowedAssets[_assetId].balances[msg.sender] -= _amountToWithdraw;
            if (msg.sender == house) {
                uint256 devFee = _amountToWithdraw / 3;
                _amountToWithdraw -= devFee;
                allowedAssets[_assetId].rewardToken.transferAssets(dev, devFee);
            }
            allowedAssets[_assetId].rewardToken.transferAssets(
                msg.sender,
                _amountToWithdraw
            );
        } else {
            revert NotEnoughtPoolBalanceError();
        }
    }

    ///@notice Gets referal balances
    ///@param _assetId id of stablecoin asset
    ///@param _addr ref address
    ///@return balance of referal
    function referalBalanceOf(
        uint8 _assetId,
        address _addr
    ) public view returns (uint256) {
        return allowedAssets[_assetId].balances[_addr];
    }

    ///@notice Deposit funds to the pool account, you can deposit from one usdt or 1*10**USDT_DECIMALS
    ///@param _assetId id of stablecoin asset
    ///@param _amount to deposit in stablecoins
    function makeDeposit(uint8 _assetId, uint256 _amount) external {
        if (_amount < 1 * 10 ** USDT_DECIMALS) {
            revert MinimumAmountError();
        }
        if (tokenB.balanceOf(msg.sender) < _amount / rateB) {
            revert TokenBMinAmountError();
        }
        tokenB.safeTransferFrom(msg.sender, address(this), _amount / rateB);
        stakedB[msg.sender] += _amount / rateB;
        allowedAssets[_assetId].rewardToken.deposit(_amount, msg.sender);
        emit InvestmentAdded(_assetId, msg.sender, _amount, block.timestamp);
    }

    ///@notice Withdraw the specified amount of USD
    ///@param _assetId id of stablecoin asset
    ///@param _rewardTokenAmount amount of Token+ that will be exchange to stablecoins
    function withdraw(
        uint8 _assetId,
        uint256 _rewardTokenAmount
    ) external nonReentrant {
        uint256 usdToWithdraw = allowedAssets[_assetId]
            .rewardToken
            .previewWithdraw(_rewardTokenAmount);
        if (
            !allowedAssets[_assetId].rewardToken.poolBalanceEnough(
                usdToWithdraw
            )
        ) {
            revert NotEnoughtPoolBalanceError();
        }
        uint256 bAmount = usdToWithdraw / rateB;
        if (stakedB[msg.sender] < bAmount) {
            bAmount = stakedB[msg.sender];
        }
        if (bAmount > 0) {
            stakedB[msg.sender] -= bAmount;
            tokenB.safeTransfer(msg.sender, bAmount);
        }
        allowedAssets[_assetId].rewardToken.withdraw(
            _rewardTokenAmount,
            msg.sender
        );
        emit Withdrawed(_assetId, msg.sender, usdToWithdraw, block.timestamp);
    }

    ///@notice Withdraw all assets and B
    function poolRun() external nonReentrant {
        for (uint8 i = 0; i < allowedAssetsCount; i++) {
            uint256 usdToWithdraw = allowedAssets[i]
                .rewardToken
                .previewWithdraw(
                    allowedAssets[i].rewardToken.balanceOf(msg.sender)
                );
            if (
                !allowedAssets[i].rewardToken.poolBalanceEnough(usdToWithdraw)
            ) {
                revert NotEnoughtPoolBalanceError();
            }
            allowedAssets[i].rewardToken.withdraw(
                allowedAssets[i].rewardToken.balanceOf(msg.sender),
                msg.sender
            );
            emit Withdrawed(i, msg.sender, usdToWithdraw, block.timestamp);
        }
        tokenB.safeTransfer(msg.sender, stakedB[msg.sender]);
        stakedB[msg.sender] = 0;
    }

    ///@notice return false if poolrun is not possible
    function isPoolRunPossible() external view returns (bool) {
        for (uint8 i = 0; i < allowedAssetsCount; i++) {
            uint256 usdToWithdraw = allowedAssets[i]
                .rewardToken
                .previewWithdraw(
                    allowedAssets[i].rewardToken.balanceOf(msg.sender)
                );
            if (
                !allowedAssets[i].rewardToken.poolBalanceEnough(usdToWithdraw)
            ) {
                return false;
            }
        }
        return true;
    }

    ///@notice Gets the price to buy or sell the Token+. If the price is too low, then sets the minimum
    ///@param _assetId id of stablecoin asset
    ///@return token+ price
    function getRewardTokenPrice(uint8 _assetId) public view returns (uint256) {
        return allowedAssets[_assetId].rewardToken.currentPrice();
    }

    ///@notice Gets amount of active bets
    ///@param _assetId id of stablecoin asset
    function getActiveBetsAmount(uint8 _assetId) public view returns (uint256) {
        return allowedAssets[_assetId].rewardToken.blockedStablecoinCount();
    }

    ///@notice Gets amount of stablecoins on pool
    ///@param _assetId id of stablecoin asset
    function getPoolTotalBalanceAmount(
        uint8 _assetId
    ) public view returns (uint256) {
        return
            allowedAssets[_assetId].stablecoin.balanceOf(
                address(allowedAssets[_assetId].rewardToken)
            );
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/security/ReentrancyGuard.sol";

///@title LP Token
contract RewardToken is ERC20, Ownable, ReentrancyGuard {
    using SafeERC20 for ERC20;

    uint256 private constant USDT_DECIMALS = 18;
    uint256 public constant PRICE_1_TO_1 = 1 * 10 ** USDT_DECIMALS;

    ///@notice base asset
    ERC20 public immutable asset;
    uint256 public blockedStablecoinCount;
    ///@notice price of asset, initialize start price 1 USDT
    uint256 public currentPrice = PRICE_1_TO_1;
    ///@notice total amount of assets in pool
    uint256 public totalAssets;

    ///@notice LP Tokens are soulbound, you can`t transfer them to anybody else
    error TokensCantBeTransferedError();

    constructor(
        ERC20 _asset,
        string memory _name,
        string memory _symbol
    ) ERC20(_name, _symbol) {
        asset = _asset;
    }

    ///@notice function that checks is balance in selected stablecoin of pool enought for pay this bet in case of user wins
    ///@param _amount amount in stablecoin
    ///@return true if enought, else false
    function poolBalanceEnough(uint256 _amount) external view returns (bool) {
        return totalAssets >= _amount + blockedStablecoinCount;
    }

    ///@notice makes bet
    ///@param _player address of player who makes bet
    ///@param _amount amount of assets
    ///@param _blocked amount that will be blocked on pool when user makes bet
    function makeBet(
        address _player,
        uint256 _amount,
        uint256 _blocked
    ) external onlyOwner {
        totalAssets += _amount;
        blockedStablecoinCount += _blocked;
        asset.safeTransferFrom(_player, address(this), _amount);
    }

    ///@notice unlock assets and update price
    ///@param _amount amount of assets
    function unblockAssets(uint256 _amount) external onlyOwner {
        blockedStablecoinCount -= _amount;
        updatePrice();
    }

    ///@notice transfers assets, update price
    ///@param _to who will receive asset
    ///@param _amount amount of assets
    function transferAssets(address _to, uint256 _amount) external onlyOwner {
        totalAssets -= _amount;
        blockedStablecoinCount -= _amount;
        asset.safeTransfer(_to, _amount);
        updatePrice();
    }

    ///@notice updates price based on current asset quantity
    function updatePrice() internal {
        uint256 newPrice = totalSupply() == 0
            ? PRICE_1_TO_1
            : ((totalAssets - blockedStablecoinCount) * PRICE_1_TO_1) /
                totalSupply();
        if (newPrice > currentPrice) {
            currentPrice = newPrice;
        }
    }

    ///@notice make deposit of assets to pool
    ///@param assets number of assets that user wants to deposit
    ///@param sender address of user who make deposit
    function deposit(uint256 assets, address sender) public returns (uint256) {
        totalAssets += assets;
        asset.safeTransferFrom(sender, address(this), assets);
        uint256 shares = (assets * PRICE_1_TO_1) / currentPrice; // Calculation of the number of shares based on the current price
        _mint(sender, shares);
        updatePrice();
        return shares;
    }

    ///@notice withdraw assets from pool
    ///@param shares number of shares that user wants to withdraw
    ///@param sender address of user who make withdraw
    function withdraw(uint256 shares, address sender) public returns (uint256) {
        uint256 assets = (shares * currentPrice) / PRICE_1_TO_1; // Calculation of the number of assets based on the current price
        totalAssets -= assets;
        asset.safeTransfer(sender, assets);
        _burn(sender, shares);
        updatePrice();
        return assets;
    }

    ///@notice viewing the number of assets that will be withdrawn
    ///@param shares number of shares
    ///@return calculated value of assets
    function previewWithdraw(uint256 shares) public view returns (uint256) {
        return (shares * currentPrice) / PRICE_1_TO_1;
    }

    ///@notice viewing the number of shares that will be withdrawn
    ///@param assets number of assets
    ///@return calculated value of shares
    function previewDeposit(uint256 assets) public view returns (uint256) {
        return (assets * PRICE_1_TO_1) / currentPrice;
    }

    ///@notice Hook that is called before any transfer of tokens.
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual override {
        if (from != address(0) && to != address(0)) {
            revert TokensCantBeTransferedError();
        }
        super._beforeTokenTransfer(from, to, amount);
    }
}
