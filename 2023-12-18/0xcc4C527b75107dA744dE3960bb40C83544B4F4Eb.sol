// بسم الله الرحمن الرحيم
// SPDX-License-Identifier: MIT

/*
Yo fam, no Bullshit let's keep it real. Too many scammers in the space. We're launching this moonshot as a refuge for the community. 
There are risks in this game, so we'll do our part to keep it SAFU for all.
Crypto is a wild ride, stay strong, ape wisely.

Find our socials in the contract when you "read" the DYOR section. All updates will be placed there.

Best of luck to you.
*/

// File: @uniswap/v2-core/contracts/interfaces/IUniswapV2Factory.sol

pragma solidity >=0.5.0;

interface IUniswapV2Factory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
}

// File: @uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router01.sol


pragma solidity >=0.6.2;

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

// File: @uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol


pragma solidity >=0.6.2;


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


// OpenZeppelin Contracts (last updated v4.9.0) (access/Ownable.sol)

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

// File: @openzeppelin/contracts/token/ERC20/IERC20.sol


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


// OpenZeppelin Contracts (last updated v4.9.0) (token/ERC20/ERC20.sol)

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

// File: Clippy.sol

pragma solidity ^0.8.18;

/*
Here's a list of Libraries imported above:

* "@openzeppelin/contracts/token/ERC20/ERC20.sol";
* "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
* "@openzeppelin/contracts/token/ERC20/IERC20.sol";
* "@openzeppelin/contracts/access/Ownable.sol";
* "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";
* "@uniswap/v2-core/contracts/interfaces/IUniswapV2Factory.sol";


input addresses for testing: 

devWallet: 0x49FBC4AD54E592556510A6C5D3d113F1aD255256
deadWallet: 0x000000000000000000000000000000000000dEaD

partnershipTokenAddress BNB Testnet: 0x5e4467517AAc8F89DD3547e7B8FAfB723e270Fd0
V2Router on BNB Testnet: 0xD99D1c33F9fC3444f8101754aBC46c52416550D1

PartnershipTokenAddress on ETH Testnet: 0x96c0ca1a8E9d5903D9d748533A737079308C70A6
V2Router on ETH Testnet: 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D

Tips:
whitelisted wallets are excluded from tax fees
exchangeWhitelisted wallets are excluded from tax fees and maxWallet limits
This token should be deployed with 18 decimals because of how balances are calculated. 
    
*/

contract Clippy is ERC20, Ownable {
    IUniswapV2Router02 public uniswapV2Router;
    address public uniswapV2Pair;
    uint256 public maxWalletAmount;
   
    // Whitelist excludes from fees exchangeWhitelist excludes from fees and maxWallet limitations
    // Blacklisted addresses can not buy sell or transfer tokens
    mapping(address => bool) private whitelist;
    mapping(address => bool) private exchangeWhitelist;
    mapping(address => bool) public blacklist;

    // Determines the percentages of the tax fees that will be used to update their balances
    // utilized in the distributeFee function
    uint256 private devFeePercentage = 95;
    uint256 private partnershipsPercentage = 95;
    uint256 private autoBurnPercentage = 95;
    uint256 private maintenancePercentage = 95;

    // balances for each tax category
    uint256 private devFeeBalance;
    uint256 private partnershipsBalance;
    uint256 private autoBurnBalance;
    uint256 private maintenanceBalance;

    // handles balances less than 1 token
    //ensure that token is using 18 decimals or the distributeFee function will need to be adjusted
    uint256 private devFeeFraction;
    uint256 private partnershipsFraction;
    uint256 private autoBurnFraction;
    uint256 private maintenanceFraction;

    bool private inSwapAndBurn;

    modifier lockSwapAndBurn {
        inSwapAndBurn = true;
        _;
        inSwapAndBurn = false;
    }

    enum Balance {
        Maintenance,
        Partnerships,
        DevFee,
        AutoBurn
    }

    uint256 private liquidityThreshold;

    struct Tax {
        uint256 devFee;
        uint256 partnerships;
        uint256 autoBurn;
        uint256 maintenance;
    }

    Tax public buyTax;
    Tax public sellTax;

    address private _devWallet = 0x49FBC4AD54E592556510A6C5D3d113F1aD255256;
    address private _partnershipTokenAddress = 0x54017FDa0ff8f380CCEF600147A66D2e262d6B17; //partnership tokens are bought and burned

    address public constant deadWallet = 0x000000000000000000000000000000000000dEaD;
    uint256 private constant DECIMALS = 1e18;

    uint256 private _totalBurnedTokens;
    uint256 private _burnedTokensLast24Hours;
    uint256 private _burnStartTime;

    bool public tradingEnabled = false;
    
    string private _website;
    string private _twitter;
    string private _telegram;
    string private _basedDevMessage;

    event Burn(address indexed burner, uint256 amount);
    event TokensRemoved(address indexed token, address indexed operator, uint256 amount);
    event InsufficientTokenBalance(uint256 tokenBalance);
    
    event InsufficientEthBalance(uint256 ethBalance);
    event SwapTokensForETHFailed(uint256 tokenAmount, address to);
    event SwapETHForPartnershipTokensFailed(uint256 ethAmount);
    event InsufficientPartnershipTokens(uint256 balance);
    event TokensSwapped(uint256 tokenAmount, uint256 ethReceived);


    constructor() ERC20("Revenge of Clippy", "Clippy") {

        uint256 totalSupply = 69000000000 * (10 ** uint256(decimals()));
        maxWalletAmount = (totalSupply * 2) / 100;
        
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory()).createPair(address(this), _uniswapV2Router.WETH());
        uniswapV2Router = _uniswapV2Router;

        exchangeWhitelist[deadWallet] = true;      
        exchangeWhitelist[owner()] = true;
        exchangeWhitelist[address(this)] = true;
        
        whitelist[_devWallet] = true;
        whitelist[deadWallet] = true;
        whitelist[owner()] = true;
        whitelist[address(this)] = true;

        liquidityThreshold = (totalSupply * 2) / 1000; // 0.002 of the total supply

        // After Launch taxes can be adjusted
        uint256 buyTaxTotal = 10; // devFee %, partnerships %, maintenance %, autoBurn % combined 
        uint256 sellTaxTotal = 15; // devFee %, partnerships %, autoBurn %, maintenance % combined

        require(buyTaxTotal <= 10, "Total buy tax can't exceed 10%");
        require(sellTaxTotal <= 15, "Total sell tax can't exceed 15%");

        buyTax = Tax({
            devFee: 10,       
            partnerships: 0, 
            maintenance: 0,  
            autoBurn: 0      
        });

        sellTax = Tax({
            devFee: 10,       
            partnerships: 0, 
            autoBurn: 2,     
            maintenance: 3   
        });

        _mint(msg.sender, totalSupply);

    }


        // Fallback function to receive Ether
    receive() external payable {}

    function withdrawETH(uint256 amount) external onlyOwner {
        require(amount <= address(this).balance, "Not enough ETH in contract");

        address payable ownerAddress = payable(msg.sender);
        ownerAddress.transfer(amount);
    }

    function withdrawTokens(IERC20 token, uint256 amount, uint8 decimalPlaces) external onlyOwner {
        require(token.balanceOf(address(this)) >= amount, "Not enough tokens in contract");

        uint256 amountWithDecimals = amount * (10**uint256(decimalPlaces));

        token.transfer(msg.sender, amountWithDecimals);
        emit TokensRemoved(address(token), msg.sender, amount);
    }
    
    function addLiquidity(uint256 tokenAmount, uint256 ethAmount) external onlyOwner {
        _approve(address(this), address(uniswapV2Router), tokenAmount);
        uniswapV2Router.addLiquidityETH{value: ethAmount}(
            address(this),
            tokenAmount,
            0,
            0,
            owner(),
            block.timestamp
        );
    }

    function removeLiquidity(uint256 amount) external onlyOwner {
        IERC20 liquidityToken = IERC20(uniswapV2Pair);
        uint256 balance = liquidityToken.balanceOf(msg.sender);

        require(balance >= amount, "Not enough liquidity to remove.");

        // Transfer LP tokens from owner to contract
        liquidityToken.transferFrom(msg.sender, address(this), amount);
        liquidityToken.approve(address(uniswapV2Router), amount);

        uniswapV2Router.removeLiquidityETHSupportingFeeOnTransferTokens(
            address(this),
            amount,
            0,
            0,
            msg.sender,
            block.timestamp
        );
    }

    function enableTrading() public onlyOwner {
        require(!tradingEnabled, "Trading is already enabled");
        tradingEnabled = true;
    }


    function setAddresses(address devWallet, address partnershipTokenAddress) public onlyOwner {
        _devWallet = devWallet;
        _partnershipTokenAddress = partnershipTokenAddress;
    }

    function getWalletAddresses() public view returns (address devWallet, address partnershipTokenAddress) {
        return (_devWallet, _partnershipTokenAddress);
    }


// Whitelist management functions
    function addToWhitelist(address _address) external onlyOwner {
        whitelist[_address] = true;
    }

    function removeFromWhitelist(address _address) external onlyOwner {
        whitelist[_address] = false;
    }

    function isWhitelisted(address _address) external view returns(bool) {
        return whitelist[_address];
    }

    // Exchange whitelist management functions
    function addToExchangeWhitelist(address _address) external onlyOwner {
        exchangeWhitelist[_address] = true;
        whitelist[_address] = true;
    }

    function removeFromExchangeWhitelist(address _address) external onlyOwner {
        exchangeWhitelist[_address] = false;
        whitelist[_address] = false;
    }

    function isExchangeWhitelisted(address _address) external view returns(bool) {
        return exchangeWhitelist[_address];
    }

    function BlacklistAddTo(address _address) external onlyOwner {
        blacklist[_address] = true;
    }

    function BlacklistRemoveFrom(address _address) external onlyOwner {
        blacklist[_address] = false;
    }
    
    function setBuyTax(uint256 devFee, uint256 partnerships, uint256 maintenance, uint256 autoBurn) external onlyOwner {
        uint256 total = devFee + partnerships + maintenance + autoBurn;
        require(total <= 10, "Total buy tax can't exceed 10%");
        buyTax = Tax(devFee, partnerships, autoBurn, maintenance);
    }

    function setSellTax(uint256 devFee, uint256 partnerships, uint256 autoBurn, uint256 maintenance) external onlyOwner {
        uint256 total = devFee + partnerships + autoBurn + maintenance;
        require(total <= 15, "Total sell tax can't exceed 15%");
        sellTax = Tax(devFee, partnerships, autoBurn, maintenance);
    }

    function getTaxBalances() public view returns (uint256 _devFeeBalance, uint256 _partnershipsBalance, uint256 _autoBurnBalance, uint256 _maintenanceBalance, uint256 _totalTaxBalance) {
        _devFeeBalance = devFeeBalance / 1 ether;
        _partnershipsBalance = partnershipsBalance / 1 ether;
        _autoBurnBalance = autoBurnBalance / 1 ether;
        _maintenanceBalance = maintenanceBalance / 1 ether;
        _totalTaxBalance = _devFeeBalance + _partnershipsBalance + _autoBurnBalance + _maintenanceBalance;
    }


    function setBasedDev(string calldata message) external onlyOwner {
        _basedDevMessage = message;
    }

    function BasedDev() public view returns (string memory) {
        return _basedDevMessage;
    }

    function setDYOR(string calldata website, string calldata twitter, string calldata telegram) external onlyOwner {
        _website = website;
        _twitter = twitter;
        _telegram = telegram;
    }

    function DYOR() public view returns (string memory website, string memory twitter, string memory telegram) {
        return (_website, _twitter, _telegram);
    }
 

    function burnedTokensTracker() public view returns (uint256 totalBurned, uint256 burnedLast24Hours) {
        return (_totalBurnedTokens, _burnedTokensLast24Hours);
    }

    function burnTokens(uint256 amount) public {
        require(balanceOf(msg.sender) >= amount, "Burn amount exceeds balance");
        uint256 deadWalletBalanceBeforeBurn = balanceOf(deadWallet);
        _transfer(msg.sender, deadWallet, amount * 1e18);

        // Calculate the amount of tokens burned during this transaction
        uint256 deadWalletBalanceAfterBurn = balanceOf(deadWallet);
        uint256 tokensBurned = deadWalletBalanceAfterBurn - deadWalletBalanceBeforeBurn;

        // Update the total burned tokens
        _totalBurnedTokens += tokensBurned;

        // Check if the 24-hour period has elapsed since the last burn
        if (block.timestamp >= _burnStartTime + 1 days) {
            _burnedTokensLast24Hours = tokensBurned;
            _burnStartTime = block.timestamp;
        } else {
            _burnedTokensLast24Hours += tokensBurned;
        }

        emit Burn(msg.sender, tokensBurned);
    }

//internal burn 
    function _burnDead(uint256 amount) private returns (uint256) {
        require(balanceOf(address(this)) >= amount, "Burn amount exceeds balance");
        uint256 deadWalletBalanceBeforeBurn = balanceOf(deadWallet);
        _transfer(address(this), deadWallet, amount);

        // Calculate the amount of tokens burned during this transaction
        uint256 deadWalletBalanceAfterBurn = balanceOf(deadWallet);
        uint256 tokensBurned = deadWalletBalanceAfterBurn - deadWalletBalanceBeforeBurn;

        // Update the total burned tokens
        _totalBurnedTokens += tokensBurned;

        // Check if the 24-hour period has elapsed since the last burn
        if (block.timestamp >= _burnStartTime + 1 days) {
            _burnedTokensLast24Hours = tokensBurned;
            _burnStartTime = block.timestamp;
        } else {
            _burnedTokensLast24Hours += tokensBurned;
        }

        emit Burn(address(this), tokensBurned);

        return tokensBurned;
    }

    function buyBackAndBurn() external onlyOwner {
        uint256 reservedBalance = devFeeBalance + partnershipsBalance + autoBurnBalance + maintenanceBalance;

        // Calculate the available token balance by subtracting the reservedBalance from total token balance
        uint256 totalTokenBalance = balanceOf(address(this));
        require(totalTokenBalance >= reservedBalance, "Reserved balance exceeds total token balance");
        uint256 availableTokenBalance = totalTokenBalance - reservedBalance;

        // If there are any tokens in the contract, swap them for ETH
        if (availableTokenBalance > 0) {
            _swapTokensForETH(availableTokenBalance, address(this));

        }

        // Calculate amount of ETH for swapping
        uint256 amountETH = address(this).balance;

        // Save the current balance of the deadWallet
        uint256 deadWalletBalanceBeforeSwap = balanceOf(deadWallet);

        // Generate the uniswap pair path of ETH -> token
        address[] memory path = new address[](2);
        path[0] = uniswapV2Router.WETH();
        path[1] = address(this);

        // Make the swap from ETH to tokens
        uniswapV2Router.swapExactETHForTokensSupportingFeeOnTransferTokens{value: amountETH}(
            0,
            path,
            deadWallet, 
            block.timestamp + 300
        );

        // Calculate the amount of tokens burned during this transaction
        uint256 deadWalletBalanceAfterSwap = balanceOf(deadWallet);
        uint256 tokensBurned = deadWalletBalanceAfterSwap - deadWalletBalanceBeforeSwap;

        // Update the total burned tokens
        _totalBurnedTokens += tokensBurned;

        // Check if the 24-hour period has elapsed since the last burn
        if (block.timestamp >= _burnStartTime + 1 days) {
            _burnedTokensLast24Hours = tokensBurned;
            _burnStartTime = block.timestamp;
        } else {
            _burnedTokensLast24Hours += tokensBurned;
        }

        emit Burn(address(this), tokensBurned);
    }

    function _swapTokensForETH(uint256 tokenAmount, address to) private returns (uint256, uint256) {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();

        _approve(address(this), address(uniswapV2Router), tokenAmount);

        uint256 initialBalance = address(this).balance;

        try uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, 
            path,
            address(this),
            block.timestamp
        ) {} catch {
            emit SwapTokensForETHFailed(tokenAmount, to);
            return (0, 0);
        }

        uint256 newBalance = address(this).balance;
        uint256 balanceDifference = newBalance - initialBalance;

        // Emit an event indicating the amount of tokens swapped and the ETH received
        emit TokensSwapped(tokenAmount, balanceDifference);

        (bool success,) = to.call{value: balanceDifference}("");
        if (!success) {
            emit SwapTokensForETHFailed(tokenAmount, to);
            return (0, 0);
        }

        // Return the amount of tokens swapped instead of the ETH balance
        return (tokenAmount, balanceDifference);
    }

    function _swapETHForPartnershipTokens(uint256 ethAmount) private returns (bool) {
        address[] memory path = new address[](2);
        path[0] = uniswapV2Router.WETH();
        path[1] = _partnershipTokenAddress;

        try uniswapV2Router.swapExactETHForTokensSupportingFeeOnTransferTokens{value: ethAmount}(
            0, 
            path,
            address(this), 
            block.timestamp
        ) {
            return true;
        } catch {
            emit SwapETHForPartnershipTokensFailed(ethAmount);
            return false;
        }
    }

    function _checkBasicTransferRequirements(address sender, address recipient, uint256 amount) internal view {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        require(!blacklist[sender] && !blacklist[recipient], "This address is blacklisted");
    }


    function _transfer(address sender, address recipient, uint256 amount) internal override {
        // Basic requirements check
        _checkBasicTransferRequirements(sender, recipient, amount);

        bool isOwnerOrContractOperation = sender == owner() || sender == address(this) || recipient == owner() || recipient == address(this);

        // If it's a liquidity or owner operation, bypass all fees
        if (isOwnerOrContractOperation) {
            super._transfer(sender, recipient, amount);
        } else {
            // Store state variable lookups in memory
            bool senderWhitelisted = whitelist[sender];
            bool recipientWhitelisted = whitelist[recipient];
            bool senderExchangeWhitelisted = exchangeWhitelist[sender];
            bool recipientExchangeWhitelisted = exchangeWhitelist[recipient];

            // Check if operation is allowed
            bool isOperationAllowed = tradingEnabled || senderWhitelisted || recipientWhitelisted || senderExchangeWhitelisted || recipientExchangeWhitelisted;

            // Ensure the operation is allowed
            require(isOperationAllowed, "Trading is not enabled yet");

            // Apply max wallet limit if needed
            if (amount > maxWalletAmount && !senderExchangeWhitelisted && !recipientExchangeWhitelisted) {
                _applyMaxWalletLimit(recipient, amount);
            }

            // Calculate amount after fees
            uint256 amountAfterFees = _calculateAmountAfterFees(sender, recipient, amount);

            // Check and perform swap and dynamic burn if conditions are met and this is a sell operation
            if (recipient == uniswapV2Pair) {
                _checkAndPerformSwap();
            } 

            // Perform actual transfer
            super._transfer(sender, recipient, amountAfterFees);
        }
    }

    function _applyMaxWalletLimit(address recipient, uint256 amount) internal view {
        bool isOwnerOrContract = msg.sender == owner() || msg.sender == address(this) || recipient == owner() || recipient == address(this);

        require(
            amount <= maxWalletAmount || isOwnerOrContract,
            "Transfer amount exceeds the maxWalletAmount."
        );
    }

    function _calculateAmountAfterFees(address sender, address recipient, uint256 amount) internal returns (uint256) {
        bool isExcluded = whitelist[sender] || whitelist[recipient] || sender == uniswapV2Pair && recipient == address(this);

        if (isExcluded) {
            return amount;
        } else {
            Tax memory appliedTax;

            if (sender == uniswapV2Pair && recipient != address(this) && recipient != owner()) {
                // This is a buy operation
                appliedTax = buyTax;
            } else if (recipient == uniswapV2Pair) {
                // This is a sell operation
                appliedTax = sellTax;
            } else {
                // This is neither a buy nor a sell operation and should not be taxed
                return amount;
            }

            Tax memory fees;
            fees.devFee = (amount * appliedTax.devFee) / 100;
            fees.partnerships = (amount * appliedTax.partnerships) / 100;
            fees.autoBurn = (amount * appliedTax.autoBurn) / 100;
            fees.maintenance = (amount * appliedTax.maintenance) / 100;

            uint256 totalFees = fees.devFee + fees.partnerships + fees.autoBurn + fees.maintenance;
            distributeFee(fees, sender);

            return amount - totalFees;
        }
    }

    //sends tax fees to the contract and manages the balances used for distribution
    //designed to handle tax distribution of less than 1 token (for tokens with 18 decimals)
    function distributeFee(Tax memory fees, address sender) private {
        uint256 totalFees = fees.devFee + fees.partnerships + fees.autoBurn + fees.maintenance;
        super._transfer(sender, address(this), totalFees);

        uint256 fraction;
        uint256 whole;

        // devFee
        (whole, fraction) = splitFraction((fees.devFee * devFeePercentage) / 100);
        devFeeBalance += whole * 10**18;
        devFeeFraction += fraction;
        if (devFeeFraction >= 1 ether) {
            devFeeBalance++;
            devFeeFraction -= 1 ether;
        }

        // partnerships
        (whole, fraction) = splitFraction((fees.partnerships * partnershipsPercentage) / 100);
        partnershipsBalance += whole * 10**18;
        partnershipsFraction += fraction;
        if (partnershipsFraction >= 1 ether) {
            partnershipsBalance++;
            partnershipsFraction -= 1 ether;
        }

        // autoBurn
        (whole, fraction) = splitFraction((fees.autoBurn * autoBurnPercentage) / 100);
        autoBurnBalance += whole * 10**18;
        autoBurnFraction += fraction;
        if (autoBurnFraction >= 1 ether) {
            autoBurnBalance++;
            autoBurnFraction -= 1 ether;
        }

        // maintenance
        (whole, fraction) = splitFraction((fees.maintenance * maintenancePercentage) / 100);
        maintenanceBalance += whole * 10**18;
        maintenanceFraction += fraction;
        if (maintenanceFraction >= 1 ether) {
            maintenanceBalance++;
            maintenanceFraction -= 1 ether;
        }
    }
    
    // allows for updating the percentage of tax fees used to update balances
    function balanceFeePercentageUpdate(uint256 _devFeePercentage, uint256 _partnershipsPercentage, uint256 _autoBurnPercentage, uint256 _maintenancePercentage) external onlyOwner {
        require(_devFeePercentage >= 1 && _devFeePercentage <= 99, "devFeePercentage out of bounds");
        require(_partnershipsPercentage >= 1 && _partnershipsPercentage <= 99, "partnershipsPercentage out of bounds");
        require(_autoBurnPercentage >= 1 && _autoBurnPercentage <= 99, "autoBurnPercentage out of bounds");
        require(_maintenancePercentage >= 1 && _maintenancePercentage <= 99, "maintenancePercentage out of bounds");

        devFeePercentage = _devFeePercentage;
        partnershipsPercentage = _partnershipsPercentage;
        autoBurnPercentage = _autoBurnPercentage;
        maintenancePercentage = _maintenancePercentage;
    }

    function splitFraction(uint256 value) internal pure returns (uint256 whole, uint256 fraction) {
        whole = value / 1 ether;
        fraction = value % 1 ether;
    }

    function getFractionTaxBalances() public view returns (uint256 _devFeeFraction, uint256 _partnershipsFraction, uint256 _autoBurnFraction, uint256 _maintenanceFraction) {
        _devFeeFraction = devFeeFraction;
        _partnershipsFraction = partnershipsFraction;
        _autoBurnFraction = autoBurnFraction;
        _maintenanceFraction = maintenanceFraction;
    }

    function balanceTaxReset() external onlyOwner {
        devFeeBalance = 0;
        partnershipsBalance = 0;
        autoBurnBalance = 0;
        maintenanceBalance = 0;
    }

/* the balanceTransfer function allows the owner to transfer tax balances from one tax category to another.
        Here's how to enter the balances based on their corresponding numbers:
                0 corresponds to MaintenanceBalance
                1 corresponds to PartnershipsBalance
                2 corresponds to DevFeeBalance
                3 corresponds to AutoBurnBalance
*/
    function balanceTransfer(Balance from, Balance to) external onlyOwner {
        uint256 amount;
        // Determine the source balance and set to zero
        if (from == Balance.Maintenance) {
            amount = maintenanceBalance;
            maintenanceBalance = 0;
        } else if (from == Balance.Partnerships) {
            amount = partnershipsBalance;
            partnershipsBalance = 0;
        } else if (from == Balance.DevFee) {
            amount = devFeeBalance;
            devFeeBalance = 0;
        } else if (from == Balance.AutoBurn) {
            amount = autoBurnBalance;
            autoBurnBalance = 0;
        }
        // Transfer the amount to the destination balance
        if (to == Balance.Maintenance) {
            maintenanceBalance += amount;
        } else if (to == Balance.Partnerships) {
            partnershipsBalance += amount;
        } else if (to == Balance.DevFee) {
            devFeeBalance += amount;
        } else if (to == Balance.AutoBurn) {
            autoBurnBalance += amount;
        }

    }
    
    function addToTaxBalance(uint256 amount) external onlyOwner {
        uint256 amountWithDecimals = amount * 10**18;
        require(balanceOf(msg.sender) >= amountWithDecimals, "Insufficient balance");
        _transfer(msg.sender, address(this), amountWithDecimals);
        uint256 distribution = amountWithDecimals / 4;

        devFeeBalance += distribution;
        partnershipsBalance += distribution;
        // Add remainder to autoBurnBalance
        autoBurnBalance += distribution + (amountWithDecimals % 4);
        maintenanceBalance += distribution;
    }

    // Allows the owner to set the liquidity threshold directly in number of tokens
    function setLiquidityThreshold(uint256 newThreshold) external onlyOwner {
        liquidityThreshold = newThreshold * 10**decimals(); // Assuming the token has 18 decimal places
    }

    // Returns the current liquidity threshold without decimal places
    function getLiqThreshold() public view returns (uint256) {
        return liquidityThreshold / 10**18;
    }

    function _checkAndPerformSwap() private {
        uint256 totalBalance = devFeeBalance + partnershipsBalance + autoBurnBalance + maintenanceBalance;
        if (totalBalance >= liquidityThreshold) {
            swapNow();
        }
    }

    function swapNow() private {
        uint256 initialBalance;
        uint256 tokensSwapped;
        uint256 ethReceived;

        if (autoBurnBalance > 0) {
            uint256 burnedAmount = _burnDead(autoBurnBalance);
            autoBurnBalance -= burnedAmount;
        }
        if (devFeeBalance > 0) {
            initialBalance = devFeeBalance;
            (tokensSwapped, ethReceived) = _swapTokensForETH(initialBalance, _devWallet);
            devFeeBalance -= tokensSwapped;
        }
        if (maintenanceBalance > 0) {
            initialBalance = maintenanceBalance;
            (tokensSwapped, ethReceived) = _swapTokensForETH(initialBalance, address(this));
            maintenanceBalance -= tokensSwapped;
        }
        if (partnershipsBalance > 0) {
            initialBalance = partnershipsBalance;
            (tokensSwapped, ethReceived) = _swapTokensForETH(initialBalance, address(this));
            partnershipsBalance -= tokensSwapped;

            // Check the balance of ETH on the contract before calling the _swapETHForPartnershipTokens function
            uint256 contractETHBalance = address(this).balance; 

            if(contractETHBalance > 0){
                _swapETHForPartnershipTokens(ethReceived);
            }
        }

        _distributeSwapped();
    }

    function manualConvert() external onlyOwner {
        uint256 initialBalance;
        uint256 tokensSwapped;
        uint256 ethReceived;

        if (autoBurnBalance > 0) {
            uint256 burnedAmount = _burnDead(autoBurnBalance);
            autoBurnBalance -= burnedAmount;
        }
        if (devFeeBalance > 0) {
            initialBalance = devFeeBalance;
            (tokensSwapped, ethReceived) = _swapTokensForETH(initialBalance, _devWallet);
            devFeeBalance -= tokensSwapped;
        }
        if (maintenanceBalance > 0) {
            initialBalance = maintenanceBalance;
            (tokensSwapped, ethReceived) = _swapTokensForETH(initialBalance, address(this));
            maintenanceBalance -= tokensSwapped;
        }
        if (partnershipsBalance > 0) {
            initialBalance = partnershipsBalance;
            (tokensSwapped, ethReceived) = _swapTokensForETH(initialBalance, address(this));
            partnershipsBalance -= tokensSwapped;

            // Check the balance of ETH on the contract before calling the _swapETHForPartnershipTokens function
            uint256 contractETHBalance = address(this).balance; 

            if(contractETHBalance > 0){
                _swapETHForPartnershipTokens(ethReceived);
            }
        }

        _distributeSwapped();
    }

    function _distributeSwapped() private {
        // Calculate the amount of partnership tokens the contract holds
        uint256 partnershipTokens = IERC20(_partnershipTokenAddress).balanceOf(address(this));

        if (partnershipTokens > 0) {
            IERC20(_partnershipTokenAddress).transfer(deadWallet, partnershipTokens);
        }

    }



}