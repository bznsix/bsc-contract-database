// SPDX-License-Identifier: MIT
pragma solidity =0.8.19;

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
     * @dev Returns the value of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the value of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves a `value` amount of tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 value) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets a `value` amount of tokens as the allowance of `spender` over the
     * caller's tokens.
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
    function approve(address spender, uint256 value) external returns (bool);

    /**
     * @dev Moves a `value` amount of tokens from `from` to `to` using the
     * allowance mechanism. `value` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address from, address to, uint256 value) external returns (bool);
}




/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
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




interface IUniswapV2Router01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);
    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH);
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}




interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}




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
    uint8  private _decimals;

    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * All two of these values are immutable: they can only be set once during
     * construction.
     */
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
        _decimals = 18;
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
     * @dev Updates `owner`s allowance for `spender` based on spent `amount`.
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

    /**
     * @dev Unauthorized reentrant call.
     */
    error ReentrancyGuardReentrantCall();

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
        if (_status == _ENTERED) {
            revert ReentrancyGuardReentrantCall();
        }

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




/**
 * Justus Token Contract
*/
contract Justus is ERC20, ERC20Burnable, Ownable, ReentrancyGuard {

    // Tax rate for buy and sell transactions (only swaps/DEXs)
    uint256 private immutable _taxRate = 300; // 3%
    bool private _taxEnabled = true;

    // Service wallets and their fee structure
    address private _serviceWallet; // Contract itself
    address private _serviceAccount; // Account that runs bot to perform buybacks and sells
    address private _treasuryWallet;

    uint256 private _wallet1Rate;
    uint256 private _wallet2Rate;

    // Threshold for Token Buyback and Sell
    uint256 private _buybackThreshold;
    uint256 private _sellThreshold;

    // Mappings for DEX/Swaps that will be taxed and addresses that are exempt
    mapping(address => bool) private _routerAddresses;
    mapping(address => bool) private _pairAddresses;
    mapping(address => bool) private _addressesExemptFromFees;

    // Events that get broadcasted after certain actions
    event AddRouterAddress(address indexed pairAddress, bool indexed value);
    event AddPairAddress(address indexed pairAddress, bool indexed value);
    event ExemptAddressFromFees(address indexed newAddress, bool indexed value);
    event BuybackThresholdChanged(uint256 indexed newBuybackThreshold);
    event SellThresholdChanged(uint256 indexed newSellThreshold);
    event TokensSold(address indexed serviceWallet, uint256 indexed tokensSold);
    event BuybackAndBurn(uint256 indexed bnbSpent, uint256 indexed tokensBurned);


    constructor(string memory tokenName, string memory tokenSymbol, address serviceAccount, address treasuryWallet) 
        ERC20(tokenName, tokenSymbol) {

        // Set initial supply and send to Owner
        uint256 initialSupply = 22700000 * (10 ** decimals());
        _mint(msg.sender, initialSupply);

        // Set service wallets
        _serviceWallet = address(this);
        _serviceAccount = serviceAccount;
        _treasuryWallet = treasuryWallet;
        alterExemptAddress(_serviceAccount, true);

        // Set Fee Rates per Service wallet
        _wallet1Rate = 150;
        _wallet2Rate = 150;

        // Sets the Buyback Threshold to 0.01 BNB and Sell Threshold to 100 Tokens        
        _buybackThreshold = 1000000000000000;

        _sellThreshold = 100 * (10 ** decimals());
    }

    
    // This function allows the contract to receives BNB 
    receive() external payable {}


    // Toggle Buy/Sell Tax
    function toggleTax(bool enabled) external onlyOwner() {
        _taxEnabled = enabled;
    }


    // Checks if entered DEX/Swap Address is listed in this contract
    function getRouterAddress(address routerAddress) public view returns (bool) {
        return _routerAddresses[routerAddress];
    }


    // Alters or adds DEX/Swap Address to the contract
    function alterRouterAddress(address routerAddress, bool value) public onlyOwner() {
        require(_routerAddresses[routerAddress] != value, "Address already in-use");
        require(routerAddress != address(0), "Can not use the zero address");

        _routerAddresses[routerAddress] = value;

        emit AddRouterAddress(routerAddress, value);
    }

    
    // Checks if entered Pair Address is listed in this contract
    function getPairAddress(address pairAddress) public view returns (bool) {
        return _pairAddresses[pairAddress];
    }


    // Alters or adds a Pair Address to the contract
    function alterPairAddress(address pairAddress, bool value) public onlyOwner() {
        require(_pairAddresses[pairAddress] != value, "Address already in-use");
        require(pairAddress != address(0), "Can not use the zero address");

        _pairAddresses[pairAddress] = value;

        emit AddPairAddress(pairAddress, value);
    }


    // Checks whether entered address is exempt from Fees
    function getAddressExemptFromFees(address excludedAddress) public view returns (bool) {
        return _addressesExemptFromFees[excludedAddress];
    }


    // Alters or adds an Address that can be exempt from Fees
    function alterExemptAddress(address excludedAddress, bool value) public onlyOwner() {
        require(_addressesExemptFromFees[excludedAddress] != value, "Already set to this value");

        _addressesExemptFromFees[excludedAddress] = value;

        emit ExemptAddressFromFees(excludedAddress, value);
    }


    // Change Service Account address, the address that calls this contract to handle buys and sells
    function setServiceAccount(address newServiceAccount) public onlyOwner() {
        require(newServiceAccount != address(0), "Can not use the zero address");
        
        alterExemptAddress(_serviceAccount, false);

        _serviceAccount = newServiceAccount;

        alterExemptAddress(_serviceAccount, true);
    }


    // Change Treasury Wallet address
    function setTreasuryWallet(address newTreasuryWallet) public onlyOwner() {
        require(newTreasuryWallet != address(0), "Can not use the zero address");

        _treasuryWallet = newTreasuryWallet;
    }


    // Adjusts the distribution rate of fees
    function adjustFeeDistribution(uint256 wallet1Percentage, uint256 wallet2Percentage) public onlyOwner() {
        require(wallet1Percentage <= 300 && wallet1Percentage >= 50, "Wallet 1 Percentage not valid");
        require(wallet2Percentage <= 300 && wallet2Percentage >= 50, "Wallet 2 Percentage not valid");
        require(wallet2Percentage + wallet2Percentage == 300, "Total Fee Amount must equal 3% or `300`");

        _wallet1Rate = wallet1Percentage;
        _wallet2Rate = wallet2Percentage;
    }


    // Checks if the BuyBack Threshold has been met
    function checkBuybackThreshold() public view returns (bool) {
        if (address(this).balance >= _buybackThreshold) {
            return true;
        }
        else {
            return false;
        }
    }


    // Checks if the Sell Threshold has been met
    function checkSellThreshold() public view returns (bool) {
        if (balanceOf(address(this)) >= _sellThreshold) {
            return true;
        }
        else {
            return false;
        }
    }


    // Adjusts the Buyback Threshold
    function adjustBuybackThreshold(uint256 buybackThreshold) public onlyOwner() {
        require(buybackThreshold != 0, "Threshold can not be set to zero");
        require(buybackThreshold >= 1000000000000000, "Threshold must be greater than 0.01 BNB");

        _buybackThreshold = buybackThreshold;

        emit BuybackThresholdChanged(buybackThreshold);
    }


    // Adjusts the Sell Threshold
    function adjustSellThreshold(uint256 sellThreshold) public onlyOwner() {
        require(sellThreshold != 0, "Threshold can not be set to zero");
        require(sellThreshold >= (100 * (10 ** decimals())), "Threshold must be greater than 100 Tokens");

        _sellThreshold = sellThreshold;

        emit SellThresholdChanged(sellThreshold);
    }


    // Override transfer function to include Buy & Sell Taxes when interacting with a DEX or Swap
    function _transfer(address sender, address recipient, uint256 amount) internal override {
        
        if (_addressesExemptFromFees[sender] == true || _addressesExemptFromFees[recipient] == true) {
            super._transfer(sender, recipient, amount);
        }

        else if ((_pairAddresses[sender] == true || _pairAddresses[recipient] == true) && _taxEnabled == true) {
            _transferWithFee(sender, recipient, amount);
        }

        else {
            super._transfer(sender, recipient, amount);
        }
    }


    // Internal function that handles taking Fees when the Token is bought or sold via a DEX/Swap
    function _transferWithFee(address sender, address recipient, uint amount) private {
        uint256 taxAmount = (amount * _taxRate) / 10000;
        uint256 postTaxAmount = (amount - taxAmount);
        
        uint256 serviceWalletShare = (amount * _wallet1Rate) / 10000;
        uint256 treasuryWalletShare = (amount * _wallet2Rate) / 10000;

        require(serviceWalletShare + treasuryWalletShare == taxAmount, "Error calculating tax distribution");
        require(serviceWalletShare + treasuryWalletShare == amount - postTaxAmount, "Error calculating post tax amount");

        super._transfer(sender, _serviceWallet, serviceWalletShare);
        super._transfer(sender, _treasuryWallet, treasuryWalletShare);
        super._transfer(sender, recipient, postTaxAmount);
    }


    // Sells tokens accumulated in the contract and stores the BNB returned
    function triggerSell(address dexAddress) external nonReentrant() {
        require(_msgSender() == _serviceAccount, "Wallet address not authorized");
        require(_routerAddresses[dexAddress] == true, "Router Address not enabled");
        require(checkSellThreshold() == true, "Sell Threshold not met");
        _sellTokens(dexAddress);
    }


    // Buys back Tokens using accumulated BNB and then Burns the tokens, deflating the supply
    function triggerBuyback(address dexAddress) external nonReentrant() {
        require(_msgSender() == _serviceAccount, "Wallet address not authorized");
        require(_routerAddresses[dexAddress] == true, "Router Address not enabled");
        require(checkBuybackThreshold() == true, "Buyback Threshold not met");
        _buybackTokens(dexAddress);
    }

    
    // Internal function that sells accumulated tokens in contract and stores the BNB returned
    function _sellTokens(address dexAddress) internal {
        
        IUniswapV2Router02 dexRouter = IUniswapV2Router02(dexAddress);
        uint256 tokenAmount = balanceOf(_serviceWallet);

        require(tokenAmount > 0, "Amount must be greater than 0");

        // Calculate the amount to actually swap after accounting for the fee
        uint256 amountToSwap = tokenAmount * 97 / 100; // 97% of the tokenAmount after deducting 3% fee

        // Approve the Router to spend tokens on behalf of this contract
        IERC20(address(this)).approve(dexAddress, tokenAmount);

        address[] memory path = new address[](2);
        path[0] = address(this); // The contract itself represents the token, so we use its address
        path[1] = dexRouter.WETH();

        // Perform the token swap using the standard Uniswap Router Interface
        dexRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(
            amountToSwap,
            0, // Accept any amount of BNB
            path,
            payable(address(this)), // This address will receive the BNB from the swap
            block.timestamp + 30 // Allows for a 30 second buffer to complete swap
        );

        emit TokensSold(_serviceWallet, tokenAmount);
    }

    
    // Internal function that triggers Buyback and Burn of tokens when Threshold is met
    function _buybackTokens(address dexAddress) internal {

        IUniswapV2Router02 dexRouter = IUniswapV2Router02(dexAddress);
        uint256 bnbAmount = address(this).balance;
        
        require(bnbAmount > 0, "Amount must be greater than 0");

        // Calculate the amount to keep in Service Account to cover future gas fees, 10% of balance
        uint256 amountToSave = (bnbAmount * 10) / 100;
        uint256 amountToSpend = bnbAmount - amountToSave;

        address[] memory path = new address[](2);
        path[0] = dexRouter.WETH();
        path[1] = address(this); // The contract itself represents the token, so we use its address

        // Perform the token buy back using the standard Uniswap Router Interface
        dexRouter.swapExactETHForTokensSupportingFeeOnTransferTokens{value: amountToSpend}(
            0, // Accept any amount of tokens
            path,
            _serviceAccount, // This address will receive the tokens from the swap
            block.timestamp + 30 // Allows for a 30 second buffer to complete swap
        );

        // Calculates the Tokens Recieved in the Buyback
        uint256 receivedTokens = balanceOf(_serviceAccount);

        // Burn all tokens bought back
        _burn(_serviceAccount, balanceOf(_serviceAccount));

        // Transfer remaining BNB to Service Account so that it has enough gas to continue running
        payable(_serviceAccount).transfer(address(this).balance);

        emit BuybackAndBurn(bnbAmount, receivedTokens);
    }


    // Withdrawl function to recover any BNB that may be sent to this contract
    function withdrawBNB(address recoveryWallet) external onlyOwner() {
        payable(recoveryWallet).transfer(address(this).balance);
    }


    /* Withdrawl any ERC20 Token that are accidentally sent to this contract
            WARNING:    Interacting with unsafe tokens or smart contracts can 
                        result in stolen private keys, loss of funds, and drained
                        wallets. Use this function with trusted Tokens/Contracts only
    */
    function withdrawERC20(address tokenAddress, address recoveryWallet) external onlyOwner {
        IERC20 token = IERC20(tokenAddress);
        uint256 balance = token.balanceOf(address(this));
        require(balance > 0, "No tokens to withdraw");
        
        token.transfer(recoveryWallet, balance);
    }
}