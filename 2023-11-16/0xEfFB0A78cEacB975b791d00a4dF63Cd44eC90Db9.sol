/**
 *Submitted for verification at BscScan.com on 2023-11-15
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

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

library Math {
    function min(uint x, uint y) internal pure returns (uint z) {
        z = x < y ? x : y;
    }

    function sqrt(uint y) internal pure returns (uint z) {
        if (y > 3) {
            z = y;
            uint x = y / 2 + 1;
            while (x < z) {
                z = x;
                x = (y / x + x) / 2;
            }
        } else if (y != 0) {
            z = 1;
        }
    }
}

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

interface ISwapPair {
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);

    function totalSupply() external view returns (uint);

    function kLast() external view returns (uint);

    function sync() external;
}

interface IUniswapV2Router {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
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
}

interface IUniswapFactory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
    function feeTo() external view returns (address);
}

contract SH is ERC20 ,Ownable{
    struct TaxRates {
        uint256 marketing;
        uint256 nftReward;
        uint256 addLiquidity;
        uint256 burn;
    }

    address public mainPair;
    address public deadAddress = 0x000000000000000000000000000000000000dEaD;
    address public usdt = address(0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c); // example USDT address
    address public marketingWallet;

    bool public enableNFTBuy;

    IUniswapV2Router public uniswapRouter;
    USDTCollector public usdtCollector;
    NftDividendDistributor public nftDividendDistributor;

    uint256 public launchBlock;
    uint256 public swapAt =200 * 1e18;

    TaxRates public buyTax = TaxRates(150, 100, 150, 100);
    TaxRates public sellTax = TaxRates(150, 100, 150, 100);

    mapping(address => bool) public isExcludeFee;
    mapping(address => bool) public _blockList;

    constructor() ERC20("SH", "SH") {
        marketingWallet = 0x9F7669360E333e9359fB94Fb644dC540584cF9D4;
        nftDividendDistributor = new NftDividendDistributor(address(this),0x5161E69A3225264Efc203172f64664E06B3beAF7,1);

        IUniswapV2Router _uniswapRouter = IUniswapV2Router(0x10ED43C718714eb63d5aA57B78B54704E256024E); 
        uniswapRouter = _uniswapRouter;
        mainPair = IUniswapFactory(IUniswapV2Router(_uniswapRouter).factory()).createPair(address(this), usdt);

        usdtCollector = new USDTCollector(usdt);

        _mint(msg.sender, 21000000 * 10 ** decimals());

        IERC20(usdt).approve(address(_uniswapRouter), ~uint256(0));
        _approve(address(this), address(_uniswapRouter), ~uint256(0));

        isExcludeFee[address(this)] = true;
        isExcludeFee[address(nftDividendDistributor)] = true;
        isExcludeFee[msg.sender] = true;
    }

    function _applyTax(address sender, address recipient, uint256 amount) internal returns (uint256) {
        TaxRates memory rates;

        if (sender == mainPair) {
            rates = buyTax;
        } else if (recipient == mainPair) {
            rates = sellTax;
            swapAndAddLiquidity(rates);
        }

        uint256 swapFee =  rates.marketing + rates.nftReward + rates.addLiquidity;

        uint256 nftAmount = (amount * rates.nftReward) / 10000;
        if(nftAmount>0)super._transfer(sender, address(nftDividendDistributor), nftAmount);

        uint256 burnAmount = (amount * rates.burn) / 10000;
        if(burnAmount>0)_burn(sender, burnAmount);

        super._transfer(sender, address(this), amount * swapFee / 10000);
        uint256 totalTax = amount * swapFee/10000 + burnAmount + nftAmount;

        return amount - totalTax;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal override {
        require(!_blockList[sender] && !_blockList[recipient], "block address");

        if (isExcludeFee[sender] || isExcludeFee[recipient] || (sender != mainPair && recipient != mainPair)) {
            super._transfer(sender, recipient ,amount);
            return ;
        }

        require(canNFTBuy(recipient) || launchBlock > 0 ,"not open yet");

        if(launchBlock > 0 && launchBlock + 3 > block.number){
            uint256 _tax = amount * 99 /100;
            super._transfer(sender, marketingWallet ,_tax);
            super._transfer(sender, recipient ,amount - _tax);

            return;
        }

        uint256 amountAfterTax = _applyTax(sender, recipient, amount);
        super._transfer(sender, recipient, amountAfterTax);

        try nftDividendDistributor.distribute() {} catch {}
    }

    function swapAndAddLiquidity(TaxRates memory rates) public {
        uint256 contractBalance = balanceOf(address(this));
        if (contractBalance >= swapAt) {
            uint256 totalFee = rates.marketing + rates.addLiquidity;
            uint256 swapFee =  rates.marketing + rates.addLiquidity/2;
            uint256 halfLiquidityAmount = swapAt * rates.addLiquidity / totalFee / 2;
            uint256 amountToSwap = swapAt  - halfLiquidityAmount;

            // Get the amount of USDT that we can get for our SpaceButterfly tokens.
            address[] memory path = new address[](2);
            path[0] = address(this);
            path[1] = usdt;
            uniswapRouter.swapExactTokensForTokensSupportingFeeOnTransferTokens(amountToSwap, 0, path, address(usdtCollector), block.timestamp);

            uint256 usdtReceived = IERC20(usdt).balanceOf(address(usdtCollector));
            uint256 marketAmount = usdtReceived * rates.marketing /swapFee;
            uint256 usdtToLiquidity = usdtReceived - marketAmount ;

            if(marketAmount>0)usdtCollector.withdrawTo(marketingWallet,marketAmount);

            if(usdtToLiquidity>0 && halfLiquidityAmount>0){
                usdtCollector.withdrawTo(address(this), usdtToLiquidity);
                uniswapRouter.addLiquidity(address(this),usdt,halfLiquidityAmount,usdtToLiquidity,0,0,marketingWallet,block.timestamp);
            }
        }
    }

    function swapUSDTForToken(uint256 usdtAmount, address addr) private {
        // generate the uniswap pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = address(usdt);
        path[1] = address(this);
        uint256 balance = IERC20(usdt).balanceOf(address(this));
        if(usdtAmount==0)usdtAmount = balance;
        // make the swap
        if(usdtAmount <= balance)
        uniswapRouter.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            usdtAmount,
            0, // accept any amount of CA
            path,
            addr,
            block.timestamp
        );
    }

    function canNFTBuy(address addr)public view returns(bool){
        return enableNFTBuy && nftDividendDistributor.hasNFT(addr);
    }

    function setWhitelistBatch(address[] memory userList, bool status) external onlyOwner {
        for(uint256 i = 0; i < userList.length; i++){
            isExcludeFee[userList[i]] = status;
        }
    }

    function init(uint256 amount, address[] calldata adrs) external onlyOwner {
        require(launchBlock == 0);
        for(uint i=0;i<adrs.length;i++)
            swapUSDTForToken(amount,adrs[i]);

        enableNFTBuy = true;
    }

    function startTrade()external onlyOwner {
        require(launchBlock == 0);
        launchBlock = block.number;
    }

    function setSwapAt(uint256 _newValue) external onlyOwner{
        swapAt = _newValue;
    }

    function setMarketAddress(address _addr) external onlyOwner{
        marketingWallet = _addr;
    }

    function setNFTRewardAddress(address payable  _addr) external onlyOwner{
        nftDividendDistributor = NftDividendDistributor(_addr);
    }

    function setBuyTax(uint256 _marketing,uint256 _nftReward,uint256 _addLiquidity,uint256 _burn) external onlyOwner{
        buyTax = TaxRates(_marketing, _nftReward, _addLiquidity, _burn);
    }

    function setSellTax(uint256 _marketing,uint256 _nftReward,uint256 _addLiquidity,uint256 _burn) external onlyOwner{
        sellTax = TaxRates(_marketing, _nftReward, _addLiquidity, _burn);
    }

    function setBlockList(address[] calldata addList, bool enable) public onlyOwner {
        for(uint256 i = 0; i < addList.length; i++) {
            _blockList[addList[i]] = enable;
        }
    }
}

contract USDTCollector is Ownable {
    IERC20 public usdt;

    constructor(address _usdtAddress) {
        usdt = IERC20(_usdtAddress);
    }

    function withdrawTo(address destination, uint256 amount) external onlyOwner {
        require(usdt.transfer(destination, amount), "Transfer failed");
    }
}

interface INFT {
    function getUserList(uint256 _type) external returns(address []  calldata);
    function balanceOf(address _addr)  external view returns(uint256);
}

contract NftDividendDistributor {
    using SafeMath for uint256;
    mapping(address => bool)public admins;

    IERC20 public rewardsToken; // USDT in this case

    address public nftAddress;
    uint256 public nftType;
    uint256 public rewardThreshold = 200*1e18;

    uint256 public lastProcessedTokenIndex = 0;
    uint256 public rewardsPerHolder;
    uint256 public numberOfNFT = 30;

    address[] public eligibleHolders;

    modifier onlyAdmin(){
        require(admins[msg.sender],"only admin!");
        _;
    }

    constructor(address _rewardToken, address _nftAddress, uint256 _nftType) {
        rewardsToken = IERC20(_rewardToken);
        nftAddress = _nftAddress;
        nftType = _nftType;

        admins[msg.sender] = true;
        admins[tx.origin] = true;
    }

    function withdrawTo(address destination, uint256 amount) external onlyAdmin {
        require(IERC20(rewardsToken).transfer(destination, amount), "Transfer failed");
    }

    function distribute() public {
        uint256 totalEligibleHolders = eligibleHolders.length;

        if(totalEligibleHolders == 0) {
            return;
        }

        uint256 balance = rewardsToken.balanceOf(address(this));

        if (rewardsPerHolder == 0) {

            if(balance < rewardThreshold){
                return;
            }

            rewardsPerHolder = balance.div(totalEligibleHolders);
            lastProcessedTokenIndex = 0;
        }

        for (uint256 i = 0; i < numberOfNFT && lastProcessedTokenIndex < totalEligibleHolders; i++) {
            rewardsToken.transfer(eligibleHolders[lastProcessedTokenIndex], rewardsPerHolder);
            lastProcessedTokenIndex++;
        }

        // Reset if finished
        if (lastProcessedTokenIndex >= totalEligibleHolders) {
            rewardsPerHolder = 0;
        }
    }

    function hasNFT(address addr)public view returns(bool){
        return INFT(nftAddress).balanceOf(addr) > 0;
    }

    function sync() external  onlyAdmin{
        eligibleHolders = INFT(nftAddress).getUserList(nftType);
    }

    function setRewardThreshold(uint256 newValue) external onlyAdmin {
        rewardThreshold = newValue;
    }

    function setNFTAddress(address addr) external onlyAdmin {
        nftAddress = addr;
    }

    function setNumberOfNFT(uint256 _val) external onlyAdmin {
        numberOfNFT = _val;
    }

    function addAdmin(address account) public onlyAdmin{
        admins[account] = true;
    }

    function removeAdmin(address account) public onlyAdmin{
        admins[account] = false;
    }

}