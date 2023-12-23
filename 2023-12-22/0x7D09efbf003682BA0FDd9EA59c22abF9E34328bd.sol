// File: @openzeppelin/contracts/security/ReentrancyGuard.sol


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

// File: @openzeppelin/contracts/utils/Context.sol


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

// File: @openzeppelin/contracts/access/Ownable.sol


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

// File: @openzeppelin/contracts/token/ERC20/IERC20.sol


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

// File: @openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol


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

// File: @openzeppelin/contracts/token/ERC20/ERC20.sol


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

// File: SecureStash Token Contract.sol



/*
Website : https://securestash.in
Telegram: https://t.me/securestash
Twitter : https://twitter.com/SecureStash
Github  : https://github.com/SecureStash/
    
Token Sale Price Estimation:
 * The given prices may vary depending on the BNB price when the transaction occurs.
    EarlyBird   : 1 BNB = 8000 SST tokens
    Private Sale: 1 BNB = 400 SST tokens
    Public Sale : 1 BNB = 250 SST tokens

Tokenomics:-
    
    Max Supply  : 100,000,000 SST tokens
    
    Early Bird (2.5%)          :  2,500,000 SST tokens 
    Private Sale (17.5%)       : 17,500,000 SST tokens 
    Public Sale (10%)          : 10,000,000 SST tokens 
    Volatile Control (50%)     : 50,000,000 SST tokens. These tokens are allocated to the CLVT contract to ensure price stability, closely mirroring fiat currency.
    Exchange Listing (10%)     : 10,000,000 SST tokens 
    Ecosystem Development (5%) :  5,000,000 SST tokens 
    Team (4%)                  :  4,000,000 SST tokens 
    Reserves (1%)              :  1,000,000 SST tokens 

 * All tokens are unlocked 4% at Token Generation Event, followed by monthly vesting over 48 months.
 * 30M SST tokens set aside for sales will not be vested during the Token Generation Event.
 * Tokens once sold will adhere to the vesting schedule.
 * Unsold tokens will be available in contract and will be offered at a variable price in subsequent Private Sale (similar to OTC) and will follow the same vesting plan.
 * Tokens assigned for Volatile Control and sent to the CLVT protocol can only be accessed via governance.
 * Tokens for Ecosystem Development will be allocated to a multisig wallet.
 * Reserve tokens will be sold periodically and converted into other decentralized assets to serve as backup funds.

 Key Points:
 1) Trades on DEX will incur a maximum burn tax of 0.5%. Owner will whitelist the DEX address to activate this burn tax for the specific DEX.
 2) Owner can create new tokens, but the total cannot exceed 100M Total Supply. Any new tokens minted will be directly sent by the contract to the ecosystem development wallet.
 3) Owner can change the wallet addresses for token allocations (Volatile Control, Exchange Listing, Ecosystem Development, Team, Reserve).
 4) Owner can stop an inprogress sale and reactivate the sale later.
 5) Owner has the option to lock token allocated address set for internal distribution. This prevents anyone to modify the address once locked.

*/

pragma solidity ^0.8.19;




contract SecureStash is ERC20, Ownable, ReentrancyGuard {
    uint256 circulatingSupply;
    uint256 public totalMint;
    uint256 totalBurn;
    uint256 public totalVested;
    uint256 launchTime;
    uint256 public totalTokensAllocatedForSales;
    uint256 constant MAX_SUPPLY = 100000000 * 10 ** 18;             // 100M tokens with 18 decimals
    uint256 public TAX_RATE = 5;                                    // 0.5% tax applied only on DEX trades
    uint256 constant TOKENS_RELEASE = 30 days;
    uint256 constant MONTHS_IN_4_YEARS = 48;
    uint256 constant INITIAL_RELEASE_PERCENTAGE = 4;
    uint256 constant VESTING_PERCENTAGE = 96;
    
    uint256 internal constant combinedSalePercentage = 30;          // 30% of the total supply (Early Bird + Private + Public)
    uint256 internal constant volatileControlPercentage = 50;       // 50% of the total supply
    uint256 internal constant exchangeListingPercentage = 10;       // 10% of the total supply
    uint256 internal constant ecosystemDevelopmentPercentage = 5;   // 5% of the total supply
    uint256 internal constant teamPercentage = 4;                   // 4% of the total supply
    uint256 internal constant reservesPercentage = 1;               // 1% of the total supply
    address[5] fundAllocationAddressesArray;                        // Array to store fund allocation addresses

    enum SaleType { EarlyBird, Private, Public }
    enum AllocationType { VolatileControl, ExchangeListing, EcosystemDevelopment, Team, Reserve }

    // Struct to hold sale details
    struct Sale {
        uint256 tokensAvailable;
        uint256 tokensSold;
        uint256 rate;
        bool isActive;
    }
 
    struct SaleData {
        uint256 totalPurchased;
        uint256 initialBalance;
        uint256 vestedTokens;
        uint256 releasedTokens;
        uint256 monthlyRelease;
    }
    
    struct AllocationAddress {
        string allocationType;
        address addr;
    }

    mapping(SaleType => Sale) public sales;
    mapping(address => uint256) lastWithdrawal;                                 //Removed public mapping to reduce contract size
    mapping(address => uint256) private _balances;
    mapping(address => uint256) totalTokensReleased;                            //Removed public mapping to reduce contract size
    mapping(address => bool) public isDex;
    mapping(address => AllocationType) public addressToAllocationType;
    mapping(address => bool) public isWhitelisted;
    mapping(uint => mapping(address => uint256)) public totalVestedBalances;
    mapping(uint => mapping(address => SaleData)) public saleData;
    mapping(AllocationType => uint256) public tokensAllocated;
    mapping(AllocationType => bool) initialDistributionDone;                    //Removed public mapping to reduce contract size
    mapping(AllocationType => bool) public isAddressLocked;
    
    event TokensBought(address indexed buyer, uint256 amount);
    event TokensMinted(address indexed to, uint256 amount);
    event TokensBurned(address indexed from, uint256 amount, string reason);
    event TokensWithdrawn(address indexed from, uint256 amount);
    event TokenAllocated(address indexed sender, address indexed recipient, uint256 amount, AllocationType allocationType);
    event TokenVested(address indexed beneficiary, uint256 amount, AllocationType allocationType, uint256 timestamp);
    event SaleRateUpdated(SaleType saleType, uint256 newRate);
    event SaleActivated(SaleType saleType, uint256 timestamp);
    event SaleStopped(SaleType saleType);
    event TokensAllocatedForSale(address indexed allocator, uint256 amount);
    event FundAllocationAddressUpdated(AllocationType allocationType, address oldAddress, address newAddress);

    constructor() ERC20("Secure Stash", "SST") {
        _mint(address(this), MAX_SUPPLY);
        totalMint = totalSupply();
        launchTime =  block.timestamp;
        lastWithdrawal[address(this)] = launchTime;

        tokensAllocated[AllocationType.VolatileControl] = (totalSupply() * volatileControlPercentage / 100 * INITIAL_RELEASE_PERCENTAGE) / 100;
        tokensAllocated[AllocationType.ExchangeListing] = (totalSupply() * exchangeListingPercentage / 100 * INITIAL_RELEASE_PERCENTAGE) / 100;
        tokensAllocated[AllocationType.EcosystemDevelopment] = (totalSupply() * ecosystemDevelopmentPercentage / 100 * INITIAL_RELEASE_PERCENTAGE) / 100;
        tokensAllocated[AllocationType.Team] = (totalSupply() * teamPercentage / 100 * INITIAL_RELEASE_PERCENTAGE) / 100;
        tokensAllocated[AllocationType.Reserve] = (totalSupply() * reservesPercentage / 100 * INITIAL_RELEASE_PERCENTAGE) / 100;

        // 96% of the 70M (excluding 30M allocated for sales) are vested. Tokens sold are vested through buy function.
        totalVested = (totalSupply() * volatileControlPercentage / 100 * VESTING_PERCENTAGE) / 100
                    + (totalSupply() * exchangeListingPercentage / 100 * VESTING_PERCENTAGE) / 100
                    + (totalSupply() * ecosystemDevelopmentPercentage / 100 * VESTING_PERCENTAGE) / 100
                    + (totalSupply() * teamPercentage / 100 * VESTING_PERCENTAGE) / 100
                    + (totalSupply() * reservesPercentage / 100 * VESTING_PERCENTAGE) / 100;
        
        totalTokensAllocatedForSales =  (totalSupply() * combinedSalePercentage) / 100;
        circulatingSupply = totalMint - totalBurn - totalVested;
    }

    // Modifier to check if the sale is active
    modifier onlyWhenSaleActive(SaleType saleType) {
        require(sales[saleType].isActive, "Sale is not active");
        _;
    }

    //Modifier to check if users are eligible to participate in EarlyBird or private sale
    modifier onlyWhitelisted() {
        require(isWhitelisted[_msgSender()], "Address not whitelisted");
        _;
    }
    
    // Function to activate a sale
    function activateSale(SaleType saleType, uint256 rate, uint256 tokensForSale) public onlyOwner {
        require(tokensForSale > 0, "Tokens for sale should be greater than 0");
        require(!sales[saleType].isActive, "Sale is already active");
        require(tokensForSale <= totalTokensAllocatedForSales, "Not enough tokens allocated for sale"); // Check against totalTokensAllocatedForSales
        //require(rate > 0, "Invalid price");           //Not included due to contract size

        Sale storage sale = sales[saleType];
        sale.rate = rate;
        sale.tokensAvailable = tokensForSale;  // Update the tokens available for the sale
        sale.isActive = true;
        totalTokensAllocatedForSales -= tokensForSale; // Deduct the tokens allocated for this sale

        emit SaleActivated(saleType, block.timestamp);
    }

    function allocateTokensForSale(uint256 amount) public onlyOwner {
        // Ensure fund allocation addresses are set
        for (uint i = 0; i < 5; i++) {
            require(fundAllocationAddressesArray[i] != address(0), "Fund allocation address not set");
        }

        // Calculate the maximum tokens that can be added
        uint256 maxAddableTokens = balanceOf(address(this)) - (totalVested + totalTokensAllocatedForSales);
        require(maxAddableTokens > 0, "No tokens available");
        require(amount <= maxAddableTokens, "Cannot add more than available tokens");

        totalTokensAllocatedForSales += amount;
        emit TokensAllocatedForSale(_msgSender(), amount);
    }

    function stopSale(SaleType saleType) external onlyOwner {
        require(sales[saleType].isActive, "Sale is still active");
        totalTokensAllocatedForSales += sales[saleType].tokensAvailable;
        require(totalTokensAllocatedForSales > 0, "No unsold tokens available");
        sales[saleType].tokensAvailable = 0; // Reset tokens available for the sale
        sales[saleType].isActive = false;
        emit SaleStopped(saleType);
    }

    //Function to whitelist users to participate in EarlyBird or private sale
    function addToWhitelist(address _address) external onlyOwner {
        //require(_address != address(0), "Invalid address");           //Not included due to contract size
        isWhitelisted[_address] = true;
    }

    function removeFromWhitelist(address _address) external onlyOwner {
        //require(_address != address(0), "Invalid address");           //Not included due to contract size
        isWhitelisted[_address] = false;
    }
    
    function setTaxRates(uint256 _taxRate) external onlyOwner {
        require(_taxRate <= 5, "Tax cannot exceed 0.5%");
        TAX_RATE = _taxRate;
    }

    // Function to add a DEX address
    function addDex(address _dex) public onlyOwner {
        //require(_dex != address(0), "Invalid address");           //Not included due to contract size
        isDex[_dex] = true;
    }
    
    // Function to remove a DEX address
    function removeDex(address _dex) public onlyOwner {
        //require(_dex != address(0), "Invalid address");           //Not included due to contract size
        isDex[_dex] = false;
    }

    function _updateCirculatingSupply() private {
        circulatingSupply = totalMint - totalBurn - totalVested;
    }

    function transfer(address recipient, uint256 amount) public override nonReentrant returns (bool) {
        require(balanceOf(_msgSender()) >= amount, "Insufficient balance");
        uint256 tax = 0;
        if (isDex[recipient] || isDex[_msgSender()]) {
            tax = (amount * TAX_RATE) / 1000;                // Calculate tax
        }
        uint256 netValue = amount - tax;                    // Calculate net value to be transferred

        // Directly burn the tax amount
        if (tax > 0) {
            _burn(_msgSender(), tax);                         // Burn the tokens directly from the sender's balance
            totalBurn = totalBurn + tax;                    // Update total tokens burnt
            emit TokensBurned(_msgSender(), tax, "Tax Burn");
            _updateCirculatingSupply();                     // Update Circulating Supply
        }
        return super.transfer(recipient, netValue);         // Call the original transfer function
    }

    function lockAllocationAddress(AllocationType allocationType, address expectedAddress) public onlyOwner {
        require(!isAddressLocked[allocationType], "Address for this allocation type is already locked");
        require(fundAllocationAddressesArray[uint(allocationType)] == expectedAddress, "Provided address does not match the current address for this allocation type");
        isAddressLocked[allocationType] = true;
    }

    function updateFundAllocationAddress(AllocationType allocationType, address newAddress) public onlyOwner {
        //require(!isAddressLocked[allocationType], "Address for this allocation type is locked and cannot be changed");
        require(newAddress != address(0), "Invalid address");
        
        // Check if the address is already assigned to another AllocationType
        for (uint i = 0; i < 5; i++) {
            require(fundAllocationAddressesArray[i] != newAddress, "Address already allocated");
        }

        // If the address is already set for the given allocationType, remove it
        for (uint i = 0; i < 5; i++) {
            if (fundAllocationAddressesArray[i] == newAddress) {
                delete addressToAllocationType[fundAllocationAddressesArray[i]];
                fundAllocationAddressesArray[i] = address(0);
            }
        }

        // Update the address for the given allocationType
        address oldAddress = fundAllocationAddressesArray[uint(allocationType)];
        addressToAllocationType[newAddress] = allocationType;
        fundAllocationAddressesArray[uint(allocationType)] = newAddress;
        emit FundAllocationAddressUpdated(allocationType, oldAddress, newAddress);

        // If the initial distribution hasn't occurred for this allocationType, do it now
        if (!initialDistributionDone[allocationType]){

            // Transfer the tokens allocated for the AllocationType to the new address only if balance is greater than 0
            uint256 tokensToTransfer = tokensAllocated[allocationType];
            _transfer(address(this), newAddress, tokensToTransfer); // Transfer tokens from the contract to the new address

            // Mark the initial distribution as done for this allocationType
            initialDistributionDone[allocationType] = true;
        }
    }

    function mint(uint256 amount) public onlyOwner nonReentrant {
        require((totalSupply() + amount) <= MAX_SUPPLY, "Cannot exceed Maximum supply");
        address ecosystemWallet = fundAllocationAddressesArray[2];              // 2 represents Ecosystem Development
        require(ecosystemWallet != address(0), "Ecosystem wallet not set");
        _mint(ecosystemWallet, amount);
        totalMint += amount;
        _updateCirculatingSupply();
        emit TokensMinted(ecosystemWallet, amount);
    }
    
    function burn(uint256 amount) public nonReentrant {
        _burn(_msgSender(), amount);
        totalBurn += amount;
        _updateCirculatingSupply();
        emit TokensBurned(_msgSender(), amount, "Manual Burn");
    }

    function _updateUserSale(SaleData storage userSale, uint256 totalPurchased, uint256 initialAllocation, uint256 vestedTokens, uint256 monthlyRelease) internal {
        userSale.totalPurchased += totalPurchased;
        userSale.initialBalance += initialAllocation;
        userSale.vestedTokens += vestedTokens;
        userSale.monthlyRelease += monthlyRelease;
    }

    function buySale(SaleType saleType, uint256 amount) public payable onlyWhenSaleActive(saleType) nonReentrant {
        require(msg.value > 0, "Amount should be greater than 0");
        SaleType currentSaleType = saleType;    // Set currentSaleType as a local variable
        require(amount == msg.value * sales[currentSaleType].rate, "Incorrect amount sent");        

        if (currentSaleType == SaleType.EarlyBird || currentSaleType == SaleType.Private) {
            require(isWhitelisted[_msgSender()], "Only whitelisted addresses can participate in this sale");
        }

        Sale storage sale = sales[currentSaleType];                               // Access the sale from the mapping based on SaleType
        require(amount <= sale.tokensAvailable, "Not enough tokens available for sale");
        
        uint256 totalPurchased = amount;
        uint256 initialAllocation = (amount * INITIAL_RELEASE_PERCENTAGE) / 100;  // Initial sale tokens sent
        uint256 vestedTokens = amount - initialAllocation;                        // Sale Tokens sent for vesting
        uint256 monthlyRelease = ((totalPurchased - initialAllocation) / MONTHS_IN_4_YEARS);
        totalVestedBalances[uint(currentSaleType)][address(this)] += vestedTokens;// Update the tokens vested for each sale type for user
        totalVested += vestedTokens;                                              // Update the total tokens vested within contract
        sale.tokensAvailable -= amount;                                           // Update available sale total balances
        sale.tokensSold += amount;

        SaleData storage userSale = saleData[uint(currentSaleType)][_msgSender()];
        _updateUserSale(userSale, totalPurchased, initialAllocation, vestedTokens, monthlyRelease);

        _updateCirculatingSupply();
        _transfer(address(this), _msgSender(), initialAllocation);
        emit TokensBought(_msgSender(), amount);
        payable(owner()).transfer(msg.value);
    }

    function withdrawSaleVestedTokens() public nonReentrant {
        uint256 totalAmount = 0;
        uint256 currentTime = block.timestamp;
        uint256 periodsSinceLaunch = (currentTime - launchTime) / TOKENS_RELEASE;                                                           // No. of months since the contract launch time
        if (lastWithdrawal[_msgSender()] == 0) {
            lastWithdrawal[_msgSender()] = launchTime;
            }
        uint256 periodsSinceLastWithdrawal = (currentTime - lastWithdrawal[_msgSender()]) / TOKENS_RELEASE;                                   // No. of months since the last withdrawal
        uint256 maxPeriodsToDistribute = (periodsSinceLaunch < MONTHS_IN_4_YEARS) ? periodsSinceLaunch : MONTHS_IN_4_YEARS;
        require(periodsSinceLastWithdrawal > 0, "Time since last withdrawal is less than 30 days");   // Ensure the user waits for at least one period before the next withdrawal
        
        uint256 userSaleInitialBalances = 0;

        for (uint i = 0; i < 3; i++) {
            SaleType currentSaleType = SaleType(i);
            SaleData storage userSale = saleData[uint(currentSaleType)][_msgSender()];
            userSaleInitialBalances += userSale.initialBalance; // This value is considered to perform mimimum operation to identify users participated in sale
        
            // Check if the user has any vested tokens for the current sale type
            if(userSale.vestedTokens == 0) {
                continue; // Skip the current iteration and move to the next sale type
            }

            uint256 totalShouldHaveReleased = userSale.monthlyRelease * maxPeriodsToDistribute;
            uint256 pendingRelease = totalShouldHaveReleased - userSale.releasedTokens;
            // Ensure there are enough tokens available with user
            require(pendingRelease <= userSale.vestedTokens, "Not enough vested tokens available in user balances");

            totalAmount += pendingRelease;
            userSale.vestedTokens -= pendingRelease;                                     // Update the user's vested tokens post vesting release
            userSale.releasedTokens += pendingRelease;                                   // Update the user's released tokens
            totalVestedBalances[uint(currentSaleType)][address(this)] -= pendingRelease; // Update the remaining balances in contract for sale tokens post vesting release
        }

        require(userSaleInitialBalances > 0, "User did not participate in any sale");    
        require(balanceOf(address(this)) >= totalAmount, "Not enough tokens in the contract");  // Ensure there are enough tokens in the contract for the distribution
        require(totalAmount <= totalVested, "Not enough tokens available to withdraw");         // Ensure total amount to be withdrawn is within the total tokens vested
        totalTokensReleased[_msgSender()] += totalAmount;
        totalVested -= totalAmount;
        lastWithdrawal[_msgSender()] = currentTime;
        _updateCirculatingSupply();
        _transfer(address(this), _msgSender(), totalAmount); // Transfer the total tokens from the contract to the user
        emit TokensWithdrawn(_msgSender(), totalAmount);
    }

    function withdrawOtherVestedTokens() public onlyOwner nonReentrant {
        uint256 totalAmount = 0;
        uint256 currentTime = block.timestamp;
        uint256 periodsSinceLaunch = (currentTime - launchTime) / TOKENS_RELEASE;                                                           // No. of months since the contract launch time
        uint256 periodsSinceLastWithdrawal = (currentTime - lastWithdrawal[address(this)]) / TOKENS_RELEASE;                                // No. of months since the last withdrawal
        uint256 maxPeriodsToDistribute = (periodsSinceLaunch < MONTHS_IN_4_YEARS) ? periodsSinceLaunch : MONTHS_IN_4_YEARS;
        uint256 periodsWithdrawn = (lastWithdrawal[address(this)] - launchTime) / TOKENS_RELEASE;
        uint256 periodsPendingDistribution = maxPeriodsToDistribute - periodsWithdrawn;
        
        require(periodsSinceLastWithdrawal > 0, "Time since last withdrawal is less than 30 days");   // Ensure the user waits for at least one period before the next withdrawal
        require(periodsPendingDistribution > 0, "No tokens to withdraw");   // Ensure the user waits for at least one period before the next withdrawal

        uint256[] memory distributionAmounts = new uint256[](5);            // Array to store vesting distribution per month for Other Allocation
        distributionAmounts[0] = (VESTING_PERCENTAGE * ((MAX_SUPPLY * volatileControlPercentage) / 100) / 100) / MONTHS_IN_4_YEARS;
        distributionAmounts[1] = (VESTING_PERCENTAGE * ((MAX_SUPPLY * exchangeListingPercentage) / 100) / 100) / MONTHS_IN_4_YEARS;
        distributionAmounts[2] = (VESTING_PERCENTAGE * ((MAX_SUPPLY * ecosystemDevelopmentPercentage) / 100) / 100) / MONTHS_IN_4_YEARS;
        distributionAmounts[3] = (VESTING_PERCENTAGE * ((MAX_SUPPLY * teamPercentage) / 100) / 100) / MONTHS_IN_4_YEARS;
        distributionAmounts[4] = (VESTING_PERCENTAGE * ((MAX_SUPPLY * reservesPercentage) / 100) / 100) / MONTHS_IN_4_YEARS;        
        
        for (uint i = 0; i < 5; i++) {
            uint256 amount = distributionAmounts[i] * periodsPendingDistribution;
            totalAmount += amount;

            // Ensure there are enough tokens in the contract for the distribution
            require(balanceOf(address(this)) >= amount, "Not enough tokens in the contract");
            // Ensure there are enough vested tokens for the distribution    
            require(totalAmount <= totalVested, "Not enough vested tokens available");
            // Transfer the tokens directly to the respective address in fundAllocationAddressesArray
            _transfer(address(this), fundAllocationAddressesArray[i], amount);
        }
        
        // Update the total vested tokens and circulating supply
        totalVested -= totalAmount;
        lastWithdrawal[address(this)] = currentTime;
        _updateCirculatingSupply();
        emit TokensWithdrawn(address(this), totalAmount);
    }

    function getOtherAllocationTypeAddress() public view returns (address VolatileControl, address ExchangeListing, address EcosystemDevelopment, address Team, address Reserve) {
        return (
            fundAllocationAddressesArray[uint(AllocationType.VolatileControl)], 
            fundAllocationAddressesArray[uint(AllocationType.ExchangeListing)], 
            fundAllocationAddressesArray[uint(AllocationType.EcosystemDevelopment)], 
            fundAllocationAddressesArray[uint(AllocationType.Team)], 
            fundAllocationAddressesArray[uint(AllocationType.Reserve)]);
    }

    function getOtherAllocationTypeBalances() public view returns (uint256 VolatileControl, uint256 ExchangeListing, uint256 EcosystemDevelopment, uint256 Team, uint256 Reserve) {
        return (
            balanceOf(fundAllocationAddressesArray[uint(AllocationType.VolatileControl)]), 
            balanceOf(fundAllocationAddressesArray[uint(AllocationType.ExchangeListing)]), 
            balanceOf(fundAllocationAddressesArray[uint(AllocationType.EcosystemDevelopment)]), 
            balanceOf(fundAllocationAddressesArray[uint(AllocationType.Team)]), 
            balanceOf(fundAllocationAddressesArray[uint(AllocationType.Reserve)]));
    }
 
    function getTotalSupply() public view returns (uint256) {
        return totalSupply();
    }

    function getCirculatingSupply() public view returns (uint256) {
        return circulatingSupply;
    }
  
    function getTotalBurns() public view returns (uint256) {
        return totalBurn;
    }

}