// File: contracts/utils/Interfaces.sol


pragma solidity ^0.8.4;

interface IReflector {
    function trackTokenToReflectTransfer(address sender, address receiver) external;
    function reflectToHolders() external;
    function reflectToHoldersWithAmount(uint256 amount) external;
}
// File: https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.8.0/contracts/utils/Context.sol


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

// File: https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.8.0/contracts/access/Ownable.sol


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

// File: https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.8.0/contracts/security/Pausable.sol


// OpenZeppelin Contracts (last updated v4.7.0) (security/Pausable.sol)

pragma solidity ^0.8.0;


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
    constructor() {
        _paused = false;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        _requireNotPaused();
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
        _requirePaused();
        _;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns (bool) {
        return _paused;
    }

    /**
     * @dev Throws if the contract is paused.
     */
    function _requireNotPaused() internal view virtual {
        require(!paused(), "Pausable: paused");
    }

    /**
     * @dev Throws if the contract is not paused.
     */
    function _requirePaused() internal view virtual {
        require(paused(), "Pausable: not paused");
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

// File: https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.8.0/contracts/token/ERC20/IERC20.sol


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

// File: https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.8.0/contracts/token/ERC20/extensions/IERC20Metadata.sol


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

// File: https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.8.0/contracts/token/ERC20/ERC20.sol


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

// File: https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.8.0/contracts/token/ERC20/extensions/ERC20Burnable.sol


// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/extensions/ERC20Burnable.sol)

pragma solidity ^0.8.0;



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

// File: contracts/Basic.sol


// https://ethereum.stackexchange.com/questions/115382/rules-on-choosing-a-solidity-version/115407
pragma solidity ^0.8.15;





// import "hardhat/console.sol";

contract BasicToken is ERC20, ERC20Burnable, Pausable, Ownable {

    uint256 private constant MAX_SLIPPAGE = 5;

    uint256 private constant MAX_NR_FEE_RECIPIENTS = 10;

    uint16 private constant MAX_FEES_IN_TRANSFER = 2000;

    // All fees in this contract are expressed in basis points, which is 1/10000.
    // See https://www.investopedia.com/terms/b/basispoint.asp
    uint256 private constant MAX_BASIS_POINTS = 10000;

    // A struct to hold data per fee recipient. A fee recipient is a wallet address that is
    // entitled to receive a fee for each transaction that occurs with this token.
    // uint16 buyFee - fee to apply on buy transfer (against the configured pancake pair)
    // uint16 sellFee - fee to apply on sell transfer (against the configured pancake pair)
    // uint16 otherFee - fee to apply on any other transfer
    // bool exists -  Must always be true so we can test for the recipient to exist
    // bool swap - Set to true if the user will receive fees in BNB
    // uint256 amountToSwapDeposit - fee balance collected for the recipient and not yet swapped to BNB and paid
    struct FeeRecipient {
        uint16 buyFee;
        uint16 sellFee;
        uint16 otherFee;
        bool exists;
        bool swap;
        uint256 amountToSwapDeposit;
    }

    // Mapping and array with feeRecipients. Note that the mapping and array must be kept in sync.
    mapping(address => FeeRecipient) public feeRecipients;

    // Array of feeRecipientAddresses so we can loop through them, that is not possible with the feeRecipients mapping
    address[] public feeRecipientAddresses;

    // Mapping of nonFeePayers. We don't need to loop through them, therefore we don't need an array.
    mapping(address => bool) public nonFeePayers;

    uint8 private intDecimals;

    // Burn fee in basis points
    uint16 public burnFee;

    // AutoLP fee (for buy and sell operations)
    uint16 public buyLiquidityFee;
    uint16 public sellLiquidityFee;

    // The amount of tokens withhold by the contract that must be added to the liquidityPool (when higher than or equals to minLPDeposit)
    uint256 public liquidityFeeDeposit;

    // The pancake router and pair
    IPancakeRouter public pancakeRouter;
    IPancakePair public pancakePair;

    // Amount minted so far
    uint256 public mintedAmount;

    // Amount burned so far
    uint256 public burnedSupply;

    // Avoids paying fees recursively
    bool private noFeesApplied;

    // Does owner pay fees?
    bool public ownerPaysFees = false;

    // Maximum value for a transaction;
    // if higher, the transaction is reverted
    uint256 public maxBuyAmount;
    uint256 public maxSellAmount;

    // Feature flags - can only be set by the constructor
    bool canMint;
    bool canBurn;

    // ======
    // Events
    // ======
    event SetBurnFee(uint16 oldFee, uint16 newFee);
    event SetLiquidityFee(string feeType, uint16 newFee);
    event SetMinLPDeposit(uint256 minLPDeposit, uint256 newMinLpDeposit);
    event SetMinSwappedDeposit(uint256 minSwappedDeposit, uint256 newMinSwappedDeposit);
    event AddFeeRecipient(address recipient, uint16 buyFee, uint16 sellFee, uint16 otherFee, bool swap);
    event SetMaxBuyAmount(uint256 oldFee, uint256 newFee);
    event SetMaxSellAmount(uint256 oldFee, uint256 newFee);
    event RemoveFeeRecipient(address recipient);
    event AddNonFeePayer(address recipient);
    event RemoveNonFeePayer(address recipient);
    event PayFeesInBnb(address recipient, uint256 bnbAmount);

    // ===========
    // Constructor
    // ===========
    constructor(
        string memory name_,
        string memory symbol_,
        uint8 decimals_,
        uint256 mintAmount_,
        address controller_,
        uint16 burnFee_,
        uint16 liquidityFee_,
        address pancakeRouter_,
        bool canMint_,
        bool canBurn_
    ) ERC20(name_, symbol_) {
        // Mint an initial amount of tokens to the controller account
        _mint(controller_, mintAmount_);

        intDecimals = decimals_;

        // Store the amount minted, to be used in tracking burned amount
        mintedAmount = mintAmount_;

        // Immediately transfer the ownership to the "controller"
        transferOwnership(controller_);

        // Initialize state variables explicitly
        canMint = canMint_;
        canBurn = canBurn_;

        // If canBurn is false, we set burnFee to 0
        burnFee = canBurn ? burnFee_ : 0;

        buyLiquidityFee = liquidityFee_;
        sellLiquidityFee = liquidityFee_;
        maxBuyAmount = 0;
        maxSellAmount = 0;
        burnedSupply = 0;

        // Create the pancake pair and write the address into the immutable contract variable
        // The pair created is between this token and the Wrapped Native token (wBnb really) in Pancake
        pancakeRouter = IPancakeRouter(pancakeRouter_);
        pancakePair = IPancakePair(IPancakeFactory(pancakeRouter.factory()).createPair(address(this), pancakeRouter.WETH()));
    }

    // Set decimals specified in the constructor
    function decimals() public view override returns (uint8) {
        return intDecimals;
    }

    // Receive BNB
    // Needed for pancake router to send us BNB when we swapToBNB
    receive() external payable {
    }

    IReflector reflector;
    function setReflector(address _r) external onlyOwner {
        reflector = IReflector(_r);
    }
    function notifyReflector(address _s, address _r) internal {
        if (address(reflector) != address(0)) {
            reflector.trackTokenToReflectTransfer(_s, _r);
        }
    }

    // =================
    // Transfer function
    // =================

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    )
    internal override 
    whenNotPaused
    {
        // console.log("---- transfer header");
        // console.log("BasicToken._transfer Sender/Recipient/Amunt", sender, recipient, amount);
        // console.log("BasicToken._transfer Apply fees?", !noFeesApplied);
        // console.log("BasicToken._transfer Balance in TK:", balanceOf(address(this)));
        // console.log("BasicToken._transfer Balance BNB  :", address(this).balance);
        // console.log("----");

        uint256 amountRemaining = amount;

        uint16 liquidityFee = getLiquidityFee(sender, recipient);

        // Check if limits exceed
        if (maxBuyAmount > 0 && isBuy(sender)) {
            // Buy transaction
            require(amount <= maxBuyAmount, "maxBuyAmount Limit Exceeded");
        } else if (maxSellAmount > 0 && isSell(recipient)) {
            // Sell transaction
            require(amount <= maxSellAmount, "maxSellAmount Limit Exceeded");
        }

        // Shall we pay fees?
        // - Is sender or recipient in the nonFeePayers list?
        // - Is sender the contract itself? This could be a fee payment (and block reentrancy)
        // - Is sender or recipient the owner, assuming the ownerPaysFees=true ?
        // - Is noFeesApplied==false, to block re-entrancy?
        if (
            !nonFeePayers[sender]
        && !nonFeePayers[recipient]
        && sender != address(this)
        && (ownerPaysFees || (sender != owner() && recipient != owner()))
        && !noFeesApplied
        ) {
            // console.log("BasicToken._transfer distributing fees!");

            // How many tokens are paid in fees (for each fee type)
            uint256 fee;
            // How many tokens need to be swapped with Uniswap router
            uint256 toSwap = 0;
            // Whether addLiquidity must be done or not
            bool performAddLiquidity = false;

            for (uint8 i = 0; i < feeRecipientAddresses.length; i++) {
                address feeRecipientAddress = feeRecipientAddresses[i];

                FeeRecipient memory feeRecipient = feeRecipients[feeRecipientAddress];
                if (feeRecipient.exists) {
                    uint16 basisPoints = 0;
                    if (isSell(recipient)) {
                        basisPoints = feeRecipient.sellFee;
                    } else if (isBuy(sender)) {
                        basisPoints = feeRecipient.buyFee;
                    } else {
                        basisPoints = feeRecipient.otherFee;
                    }
                    fee = (amount * basisPoints) / MAX_BASIS_POINTS;
                    if (fee > 0 && fee <= amountRemaining) {
                        amountRemaining = amountRemaining - fee;
                        // Collect fees for payment in BNB
                        if (feeRecipient.swap) {
                            feeRecipients[feeRecipientAddress].amountToSwapDeposit += fee;
                            if (!isBuy(sender)) {
                                toSwap += feeRecipients[feeRecipientAddress].amountToSwapDeposit;
                            }
                            // console.log("feeRecipient accumulated fees (in token) with payment in BNB", feeRecipientAddress, feeRecipients[feeRecipientAddress].amountToSwapDeposit);
                            feeRecipientAddress = address(this);
                        }
                        // console.log("Paying feeRecipient");
                        super._transfer(sender, feeRecipientAddress, fee);
                        // console.log("BasicToken._transfer - Paying feeRecipient done", feeRecipientAddress, fee);
                    }
                }
            }
            // Burn fees
            if (burnFee > 0) {
                fee = (amount * burnFee) / MAX_BASIS_POINTS;
                if (fee > 0 && fee <= amountRemaining) {
                    // console.log("Burning");
                    _burn(sender, fee);
                    // console.log("Burning done");
                    amountRemaining -= fee;
                    burnedSupply += fee;
                }
            }
            // First, transfer tokens into the contract, and update 
            // liquidityFeeDeposit. Then try to swap and addLiquidity; if pre-flight (amountOut) is 0, tokens will be swapped next time
            // Note - swap and addLiquidity are done for any transfer except buy (to avoid uniswap reentrancy guard and failure). But even for buys, tokens are stored in the contract, waiting for a non-buy operation to add it as liquidity to the pool.
            if (liquidityFee > 0) {
                fee = (amount * liquidityFee) / MAX_BASIS_POINTS;
                if (fee > 0 && fee <= amountRemaining) {
                    // console.log("BasicToken._transfer - Sending liquidity fee", fee);
                    super._transfer(sender, address(this), fee);
                    // console.log("BasicToken._transfer - Sending liquidity fee done");
                    // Send the fee to this contract
                    amountRemaining -= fee;
                    liquidityFeeDeposit += fee;
                }

                if (!isBuy(sender) && liquidityFeeDeposit > 0) {
                    toSwap += liquidityFeeDeposit / 2;
                    performAddLiquidity = true;
                    // console.log("BasicToken._transfer - Set performAddLiquidity=true, with deposit", liquidityFeeDeposit);
                }
            }

            // Swap some tokens to BNB, using the Uniswap Router
            // console.log("BasicToken._transfer - toSwap:", toSwap);
            if (toSwap > 0) {
                payFeesInBnb(toSwap, performAddLiquidity);
            }
        }
        super._transfer(sender, recipient, amountRemaining);
        notifyReflector(sender, recipient);
        // console.log("BasicToken._transfer done");
    }

    // =========
    // Modifiers
    // =========

    modifier doNotApplyFees {
        noFeesApplied = true;
        _;
        noFeesApplied = false;
    }

    // ===============
    // Owner functions
    // ===============

    function mint(uint256 mintAmount) external onlyOwner {
        require(canMint, "Minting is not available");
        require(mintAmount > 0, "mintAmount must be higher than 0");
        mintedAmount += mintAmount;
        _mint(owner(), mintAmount);
    }

    function pause() external onlyOwner {
        _pause();
    }

    function unpause() external onlyOwner {
        _unpause();
    }

    function compareStrings(string memory a, string memory b) internal pure returns (bool) {
        return (keccak256(abi.encodePacked((a))) == keccak256(abi.encodePacked((b))));
    }

    function isFeeValid(uint16 fee, string memory feeType) internal view {
        // Check if the total fees across all recipients is higher than 100%
        uint256 totalFees = fee + burnFee;
        for (uint8 i = 0; i < feeRecipientAddresses.length; i++) {
            address feeRecipientAddress = feeRecipientAddresses[i];
            FeeRecipient memory feeRecipient = feeRecipients[feeRecipientAddress];
            if (compareStrings(feeType, "Buy")) {
                totalFees += feeRecipient.buyFee + buyLiquidityFee;
            } else if (compareStrings(feeType, "Sell")) {
                totalFees += feeRecipient.sellFee + sellLiquidityFee;
            } else if (compareStrings(feeType, "Other")) {
                totalFees += feeRecipient.otherFee;
            }
        }
        require(
            totalFees <= MAX_FEES_IN_TRANSFER,
            "total fees exceeded limit");
    }

    // Add a new fee recipient with a fee of basisPoints
    function addFeeRecipient(address recipient, uint16 buyFee, uint16 sellFee, uint16 otherFee, bool swap) external onlyOwner {
        require(!feeRecipients[recipient].exists, "Recipient already exists");
        require(feeRecipientAddresses.length < MAX_NR_FEE_RECIPIENTS, "Max number of recipients reached");
        // BPS can be set to zero
        // require(buyFee != 0, "Buy fee cannot be 0");
        // require(sellFee != 0, "Sell fee cannot be 0");
        isFeeValid(buyFee,"Buy");
        isFeeValid(sellFee,"Sell");
        isFeeValid(otherFee,"Other");

        feeRecipients[recipient] = FeeRecipient(buyFee, sellFee, otherFee, true, swap, 0);
        feeRecipientAddresses.push(recipient);
        emit AddFeeRecipient(recipient, buyFee, sellFee, otherFee, swap);
    }

    // Remove an existing fee recipient
    function removeFeeRecipient(address recipient) external onlyOwner {
        require(feeRecipients[recipient].exists, "Recipient does not exist");
        delete feeRecipients[recipient];
        emit RemoveFeeRecipient(recipient);

        // Loop the array of addresses so we can remove the _recipient
        for (uint256 i = 0; i < feeRecipientAddresses.length; i++) {
            if (feeRecipientAddresses[i] != recipient) continue;
            if (i != feeRecipientAddresses.length - 1) {
                feeRecipientAddresses[i] = feeRecipientAddresses[feeRecipientAddresses.length - 1];
            }
            feeRecipientAddresses.pop();
            break;
        }
    }

    function addNonFeePayer(address nonFeePayer) external onlyOwner {
        require(nonFeePayer != address(0), "_nonFeePayer cannot be 0");
        require(!nonFeePayers[nonFeePayer], "_nonFeePayer already exists");
        nonFeePayers[nonFeePayer] = true;
        emit AddNonFeePayer(nonFeePayer);
    }

    function removeNonFeePayer(address nonFeePayer) external onlyOwner {
        require(nonFeePayer != address(0), "_nonFeePayer cannot be 0");
        require(nonFeePayers[nonFeePayer], "_nonFeePayer does not exist");
        nonFeePayers[nonFeePayer] = false;
        emit RemoveNonFeePayer(nonFeePayer);
    }

    function setBurnFee(uint16 newBurnFee) external onlyOwner {
        require(canBurn, "Burning is not available");
        require(
            newBurnFee + buyLiquidityFee <= MAX_FEES_IN_TRANSFER, 
            "total fees exceeded limit");
        require(
            newBurnFee + sellLiquidityFee <= MAX_FEES_IN_TRANSFER, 
            "total fees exceeded limit");
        emit SetBurnFee(burnFee, newBurnFee);
        burnFee = newBurnFee;
    }

    function setLiquidityFee(uint16 newLiquidityFee) external onlyOwner {
        require(
            burnFee + newLiquidityFee <= MAX_FEES_IN_TRANSFER, 
            "total fees exceeded limit");
        emit SetLiquidityFee("all", newLiquidityFee);
        buyLiquidityFee = newLiquidityFee;
        sellLiquidityFee = newLiquidityFee;
    }

    function setBuyLiquidityFee(uint16 newLiquidityFee) external onlyOwner {
        require(
            burnFee + newLiquidityFee <= MAX_FEES_IN_TRANSFER, 
            "total buy fees exceeded limit");
        emit SetLiquidityFee("buy", newLiquidityFee);
        buyLiquidityFee = newLiquidityFee;
    }
    function setSellLiquidityFee(uint16 newLiquidityFee) external onlyOwner {
        require(
            burnFee + newLiquidityFee <= MAX_FEES_IN_TRANSFER, 
            "total sell fees exceeded limit");
        emit SetLiquidityFee("sell", newLiquidityFee);
        sellLiquidityFee = newLiquidityFee;
    }

    function setMaxBuyAmount(uint256 newMaxBuyAmount) external onlyOwner {
        emit SetMaxBuyAmount(maxBuyAmount, newMaxBuyAmount);
        maxBuyAmount = newMaxBuyAmount;
    }

    function setMaxSellAmount(uint256 newMaxSellAmount) external onlyOwner {
        emit SetMaxSellAmount(maxSellAmount, newMaxSellAmount);
        maxSellAmount = newMaxSellAmount;
    }

    function includeOwnerFromFees() external onlyOwner {
        ownerPaysFees = true;
    }
    function excludeOwnerFromFees() external onlyOwner {
        ownerPaysFees = false;
    }

    // ==================
    // Internal functions
    // ==================

    function payFeesInBnb(uint256 toSwap, bool performAddLiquidity) private doNotApplyFees {
        uint256 bnbAmount = swapToBNB(toSwap);
        // console.log("BasicToken._transfer - after swapToBNB", bnbAmount);
        // console.log("BasicToken._transfer - BNB in contract", address(this).balance);
        // Swap happened
        if (bnbAmount > 0) {
            // Now we add liquidity to the pool
            if (performAddLiquidity) {
                uint256 halfLPFeeDeposit = liquidityFeeDeposit / 2;
                // console.log("BasicToken._transfer - perform addLiquidity", liquidityFeeDeposit);
                require(this.approve(address(pancakeRouter), halfLPFeeDeposit), "Approval 1 failed");
                // console.log("BasicToken._transfer - Token in pool:", halfLPFeeDeposit);
                uint256 lpBnbs = bnbAmount * halfLPFeeDeposit / toSwap;
                // console.log("BasicToken._transfer - BNBs in pool :", lpBnbs);

                // console.log("BasicToken._transfer - (LP) to pay ", lpBnbs);
                // console.log("BasicToken._transfer - (LP) balance", address(this).balance);

                uint256 amountTokenMin = (halfLPFeeDeposit * (100 - MAX_SLIPPAGE))/100;
                uint256 amountETHMin = (lpBnbs * (100 - MAX_SLIPPAGE))/100;
                pancakeRouter.addLiquidityETH{value: lpBnbs}(
                    address(this),      // Token
                    halfLPFeeDeposit,   // amountTokenDesired
                    amountTokenMin,     // amountTokenMin
                    amountETHMin,       // amountETHMin
                    owner(),            // to
                    block.timestamp     // deadline
                );

                liquidityFeeDeposit = 0;
                // console.log("addLiquidity exit");
            }

            // Now we share BNBs with fee recipients
            // console.log("BasicToken.transfer - pay fees in BNB for recipients:", feeRecipientAddresses.length);
            for (uint8 i = 0; i < feeRecipientAddresses.length; i++) {
                address feeRecipientAddress = feeRecipientAddresses[i];
                FeeRecipient memory feeRecipient = feeRecipients[feeRecipientAddress];
                if (feeRecipient.amountToSwapDeposit > 0) {
                    uint256 feeBnbAmount = bnbAmount * feeRecipient.amountToSwapDeposit / toSwap;
                    // console.log("BasicToken._transfer - Paying fees in BNB!",feeRecipientAddress, feeRecipient.amountToSwapDeposit, feeBnbAmount);
                    if (feeBnbAmount > 0) {
                        // console.log("BasicToken._transfer - to pay ", feeBnbAmount);
                        // console.log("BasicToken._transfer - balance", address(this).balance);

                        // CAREFUL! This could be a point of reentrancy! Make sure that contract owners are aware of the risk, and carefully validate feeRecipients before adding them
                        (bool ret,) = payable(feeRecipientAddress).call{value: feeBnbAmount}("");
                        require(ret, "BasicToken._transfer - Payment of fees in BNBs failed");
                        feeRecipients[feeRecipientAddress].amountToSwapDeposit = 0;
                        // console.log("Paid fees in BNB!",feeRecipientAddress, feeBnbAmount);
                        emit PayFeesInBnb(feeRecipientAddress, feeBnbAmount);
                    }
                }
            }
        }
    }

    // Swaps an amount of this token to BNB using pancake swap
    function swapToBNB(uint256 amount) private returns (uint256 bnbAmount) {
        // Approve spending the tokens
        require(this.approve(address(pancakeRouter), amount), "Approval 2 failed");
        // Create the path variable that the pancake router requires
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = pancakeRouter.WETH();

        // Preflight swap, check if the swap is expected to return more than 0 BNB
        uint[] memory amounts = pancakeRouter.getAmountsOut(amount, path);

        if (amounts[1] > 0) {
            // Determine BNB openingBalance before the swap
            uint256 openingBalance = address(this).balance;

            // Define minimum amount to swap
            uint256 minAmount = (amounts[1] * (100 - MAX_SLIPPAGE))/100;

            // Execute the swap
            pancakeRouter.swapExactTokensForETH(
                amount, minAmount, path, address(this), block.timestamp
            );
            // Return the amount of BNB received
            return (address(this).balance - openingBalance);
        } else {
            return 0;
        }
    }

    function getLiquidityFee(address sender, address receiver) private view returns (uint16 liquidityFee) {
        if (isSell(receiver)) {
            return sellLiquidityFee;
        } else if (isBuy(sender)) {
            return buyLiquidityFee;
        } else {
            return 0;
        }
    }

    function isBuy(address sender) internal view returns (bool isBuyFlag) {
        return sender == address(pancakePair);
    }

    function isSell(address receiver) internal view returns (bool isSellFlag) {
        return receiver == address(pancakePair);
    }


}

// ========================================================
// Pancake (Uniswap V2) Router, Factory and Pair interfaces
// ========================================================

interface IPancakeRouter {
    function WETH() external pure returns (address);
    function factory() external pure returns (address);
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline) external;
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function getAmountsOut(uint amountIn, address[] memory path) external view returns (uint[] memory amounts);
}

interface IPancakeFactory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface IPancakePair { }