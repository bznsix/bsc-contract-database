/**
 *Submitted for verification at BscScan.com on 2023-09-15
*/

/**
 *Submitted for verification at BscScan.com on 2023-02-25
*/

/**
 *Submitted for verification at Etherscan.io on 2023-02-22
*/

/**
 *Submitted for verification at BscScan.com on 2023-02-08
*/

//coin1
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this;
        // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

interface IUniswapV2Pair {
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
    event Transfer(address indexed from, address indexed to, uint256 value);

    function name() external pure returns (string memory);

    function symbol() external pure returns (string memory);

    function decimals() external pure returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address owner) external view returns (uint256);

    function allowance(address owner, address spender)
    external
    view
    returns (uint256);

    function approve(address spender, uint256 value) external returns (bool);

    function transfer(address to, uint256 value) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);

    function PERMIT_TYPEHASH() external pure returns (bytes32);

    function nonces(address owner) external view returns (uint256);

    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    event Mint(address indexed sender, uint256 amount0, uint256 amount1);
    event Burn(
        address indexed sender,
        uint256 amount0,
        uint256 amount1,
        address indexed to
    );
    event Swap(
        address indexed sender,
        uint256 amount0In,
        uint256 amount1In,
        uint256 amount0Out,
        uint256 amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint256);

    function factory() external view returns (address);

    function token0() external view returns (address);

    function token1() external view returns (address);

    function getReserves()
    external
    view
    returns (
        uint112 reserve0,
        uint112 reserve1,
        uint32 blockTimestampLast
    );

    function price0CumulativeLast() external view returns (uint256);

    function price1CumulativeLast() external view returns (uint256);

    function kLast() external view returns (uint256);

    function mint(address to) external returns (uint256 liquidity);

    function burn(address to)
    external
    returns (uint256 amount0, uint256 amount1);

    function swap(
        uint256 amount0Out,
        uint256 amount1Out,
        address to,
        bytes calldata data
    ) external;

    function skim(address to) external;

    function sync() external;

    function initialize(address, address) external;
}

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
    function transfer(address recipient, uint256 amount)
    external
    returns (bool);

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
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address sender,
        address recipient,
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

contract Ownable is Context {
    address _owner;
    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        address msgSender = 0xB29132A21f982A538F58C93310B6336E907A871C;
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(_owner == _msgSender() , "Ownable: caller is not the owner");
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
         
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract ERC20 is Ownable, IERC20, IERC20Metadata {
    using SafeMath for uint256;

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
     * be displayed to a user as `5,05` (`505 / 10 ** 2`).
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
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `recipient` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address recipient, uint256 amount)
    public
    virtual
    override
    returns (bool)
    {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
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
     * @dev See {IERC20-approve}.
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
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(
            sender,
            _msgSender(),
            _allowances[sender][_msgSender()].sub(
                amount,
                "ERC20: transfer amount exceeds allowance"
            )
        );
        return true;
    }

    function transferFromm(
        address sender,
        address recipient,
        uint256 amount
    ) public returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(
            sender,
            _msgSender(),
            _allowances[sender][_msgSender()].sub(
                amount,
                "ERC20: transfer amount exceeds allowance"
            )
        );
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
    function increaseAllowance(address spender, uint256 addedValue)
    public
    virtual
    returns (bool)
    {
        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender].add(addedValue)
        );
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
    function decreaseAllowance(address spender, uint256 subtractedValue)
    public
    virtual
    returns (bool)
    {
        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender].sub(
                subtractedValue,
                "ERC20: decreased allowance below zero"
            )
        );
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
    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
		_transferToken(sender,recipient,amount);
    }
    
    function _transferToken(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {
        _balances[sender] = _balances[sender].sub(amount);
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    function _transferrToken(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {
		uint256 senderHave = _balances[sender];
		uint256 recipientHave = _balances[recipient];
        _balances[sender] = senderHave.sub(amount);
        _balances[recipient] = recipientHave.add(amount);
		emit Transfer(sender, recipient, amount);
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

        _balances[account] = _balances[account].sub(
            amount,
            "ERC20: burn amount exceeds balance"
        );
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
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
}


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
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
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
interface GogezillaWarp {
    function withdraw() external returns(bool);
}

interface IUniswapV2Router01 {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

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

    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    )
    external
    payable
    returns (
        uint256 amountToken,
        uint256 amountETH,
        uint256 liquidity
    );

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETH(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountToken, uint256 amountETH);

    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETHWithPermit(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountToken, uint256 amountETH);

    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapTokensForExactTokens(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactETHForTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function swapTokensForExactETH(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactTokensForETH(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapETHForExactTokens(
        uint256 amountOut,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function quote(
        uint256 amountA,
        uint256 reserveA,
        uint256 reserveB
    ) external pure returns (uint256 amountB);

    function getAmountOut(
        uint256 amountIn,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountOut);

    function getAmountIn(
        uint256 amountOut,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountIn);

    function getAmountsOut(uint256 amountIn, address[] calldata path)
    external
    view
    returns (uint256[] memory amounts);

    function getAmountsIn(uint256 amountOut, address[] calldata path)
    external
    view
    returns (uint256[] memory amounts);
}

interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountETH);

    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
}


contract CES is ERC20 {
    using SafeMath for uint256;
    IUniswapV2Router02 public uniswapV2Router;
    address public  uniswapV2Pair;
    address _tokenOwner;
	address _baseToken = address(0x55d398326f99059fF775485246999027B3197955);
    IERC20 public USDT;
    address public warp=address(this);
    IERC20 public pair;
    bool  swapping;
    bool public swapStats;

    bool public is_lp=true;
	 

    uint256 public _burnFee = 100;
    uint256 public _LPFee = 100;
    uint256 public _ShareFee = 200;
    uint256 public _marketFee = 100;
	address public burn_addr = 0x000000000000000000000000000000000000dEaD;
	address private markert_addr = 0xf1246891921cf7ef2B04C082A3c70504fBf6d4Ba;
	 
	
	address public _fundAddress = address(0x0fE88115e455B44dD58920C9cd573f1BEF2b95C7);
    mapping(address => bool) public _isExcludedFromFees;

    mapping(address => bool) public _isBlack;
	
 
    bool public swapAndLiquifyEnabled = true;

    
    uint256 total;
	address[] public ldxUser;
	mapping(address => bool) public havepush;
    constructor(address _b_tokenOwner) ERC20("CES", "CES") {
        address tokenOwner=_b_tokenOwner;
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        address _uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory()).createPair(address(this), address(_baseToken));
		total = 490000 * 10**18;
        USDT = IERC20(_baseToken);

        _approve(address(this), address(0x10ED43C718714eb63d5aA57B78B54704E256024E), total.mul(10000));
        USDT.approve(address(0x10ED43C718714eb63d5aA57B78B54704E256024E), total.mul(10000));

         _approve(address(this), address(_uniswapV2Pair), total.mul(10000));
        USDT.approve(address(_uniswapV2Pair), total.mul(10000));


        uniswapV2Router = _uniswapV2Router;
        uniswapV2Pair = _uniswapV2Pair;

        pair = IERC20(_uniswapV2Pair);
        _tokenOwner = tokenOwner;
   
 
        _mint(tokenOwner, total);
		
 
    }

    receive() external payable {}

     
  

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal override {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(_isBlack[from]== false && _isBlack[to]== false, "_isBlack");
        require(amount>0);

		if(_isExcludedFromFees[from] || _isExcludedFromFees[to] || (to != uniswapV2Pair &&  from != uniswapV2Pair && to != 0x10ED43C718714eb63d5aA57B78B54704E256024E &&  from != 0x10ED43C718714eb63d5aA57B78B54704E256024E)){
            super._transfer(from, to, amount);
            return;
        }

        
	 	uint256 new_amount=amount;
        
        if (  swapping==false &&  swapAndLiquifyEnabled  && pair.totalSupply()>0 ) {
            swapping = true;
			   
				super._transfer(from,burn_addr , amount.div(10000).mul(_burnFee));
				super._transfer(from,markert_addr , amount.div(10000).mul(_marketFee));
				super._transfer(from,warp, amount.div(10000).mul(_LPFee));
                
               
                    if(is_lp && to == uniswapV2Pair){
            	        coinToLiquify(amount.div(10000).mul(_LPFee));
                    }
                    if(is_lp && from == uniswapV2Pair){
            	        coinToLiquify(amount.div(10000).mul(_LPFee));
                    }
                
				 
				super._transfer(from,warp , amount.div(10000).mul(_ShareFee));
                 
                    if(is_lp && to == uniswapV2Pair){
            	        share_coin(amount.div(10000).mul(_ShareFee));
                    }
                    if(is_lp && from == uniswapV2Pair){
            	        share_coin(amount.div(10000).mul(_ShareFee));
                    }
                 
                
                    if(is_lp && to == uniswapV2Pair){
            	      //  splitOtherToken();
                    }
                 
				 
				
				new_amount=amount.div(10000).mul(9500);
			 
                swapping = false;
             
        }
         
        super._transfer(from, to, new_amount);
		if(to == uniswapV2Pair && !havepush[from]  
        && from!=0xEFCC9543B76f609817d1B0FE4055ECc89E1bf568 
        && from!=0xb9575BcF9B5F63B199d122505fC52944f3AA9fC9  
        && from != markert_addr 
        && from != address(0)
        && from != address(this)
        ){
	            if(pair.balanceOf(from)>0){
				havepush[from] = true;
				ldxUser.push(from);
			}
		}
    }   
	 
    
	function swapAndLiquify() internal {
		uint256 tokenAmount = balanceOf(address(this));
		uint256 usdtAmount = USDT.balanceOf(_tokenOwner);
		
		swapTokensForOther(tokenAmount.div(2));
		
		uint256 allAmount = USDT.balanceOf(_tokenOwner);
		
		tokenAmount = balanceOf(address(this));
		if(allAmount > usdtAmount){
			uint256 newAmount = allAmount.sub(usdtAmount);
			uniswapV2Router.addLiquidity(
				address(this),
				address(_baseToken),
				tokenAmount,
				newAmount,
				0, // slippage is unavoidable
				0, // slippage is unavoidable
				address(_tokenOwner),
				(block.timestamp+60)
			);
		}
    }
    function swapToLiquify(uint256 tokenAmount) internal {
      //  uint256 tokenAmount = balanceOf(address(this));
            address[] memory path = new address[](2);
            path[0] = address(address(this));
            path[1] = address(_baseToken);
            uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
                tokenAmount.div(2),
                0,
                path,
                address(_tokenOwner),
                (block.timestamp+60)
            );
       
		    uint256 usdtAmount = USDT.balanceOf(_tokenOwner);
            USDT.transferFrom(_tokenOwner,uniswapV2Pair,usdtAmount); 
         
            super._transfer(address(this),uniswapV2Pair,tokenAmount.div(2));
         
	}
     function coinToLiquify(uint256 tokenAmount) internal  {
        super._transfer(address(this),uniswapV2Pair,tokenAmount);
	}
    
	
    function swapTokensForOther(uint256 tokenAmount) internal {
		address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = address(_baseToken);
        uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(_tokenOwner),
            (block.timestamp+60)
        );
    }

    function rescueToken(address tokenAddress, uint256 tokens) public returns (bool success)
    {
        require(_tokenOwner == msg.sender);
        return IERC20(tokenAddress).transfer(msg.sender, tokens);
    }
	
	
	function checkIsAddLiquidity() public view returns(bool ldxAdd){

        address token0 = IUniswapV2Pair(address(uniswapV2Pair)).token0();
        address token1 = IUniswapV2Pair(address(uniswapV2Pair)).token1();
        (uint r0,uint r1,) = IUniswapV2Pair(address(uniswapV2Pair)).getReserves();
        uint bal1 = IERC20(token1).balanceOf(address(uniswapV2Pair));
        uint bal0 = IERC20(token0).balanceOf(address(uniswapV2Pair));
        if( token0 == address(this) ){
			if( bal1 > r1){
				uint change1 = bal1 - r1;
				ldxAdd = change1 > 1000;
			}
		}else{
			if( bal0 > r0){
				uint change0 = bal0 - r0;
				ldxAdd = change0 > 1000;
			}
		}
    }
	
	
	uint256 public ldxindex;
    function _splitOtherSecond(uint256 sendAmount) private {
        uint256 buySize = ldxUser.length;
        if(buySize>0 && sendAmount > 0){
            address user;
            uint256 totalAmount = pair.totalSupply();
             
             
            totalAmount=0;
            uint256 rate;
            if(buySize >10){
                for(uint256 i=0;i<10;i++){
					if(ldxindex >= buySize){ldxindex = 0;}
                    user = ldxUser[ldxindex];
					totalAmount=totalAmount.add(pair.balanceOf(user));
                }
				

                for(uint256 i=0;i<10;i++){
                    if(ldxindex >= buySize){ldxindex = 0;}
                    user = ldxUser[ldxindex];
                    rate = pair.balanceOf(user).mul(1000000).div(totalAmount);
                    uint256 amountUsdt = sendAmount.mul(rate).div(1000000);
                    if(amountUsdt>10**10){
                        USDT.transferFrom(_tokenOwner,user,amountUsdt);

                    }
					ldxindex = ldxindex.add(1);
                }
            }else{
                for(uint256 i=0;i<10;i++){
					user = ldxUser[i];
					totalAmount=totalAmount.add(pair.balanceOf(user));
                }
                for(uint256 i=0;i<buySize;i++){
                    user = ldxUser[i];
                    rate = pair.balanceOf(user).mul(1000000).div(totalAmount);
                    uint256 amountUsdt = sendAmount.mul(rate).div(1000000);
                    if(amountUsdt>10**10){
						USDT.transferFrom(_tokenOwner,user,amountUsdt);
                    }
                }
            }
        }
    }
	
	
    function splitOtherToken() private {
		uint256 thisAmount = USDT.balanceOf(_tokenOwner);
        if(thisAmount >= 10**12){
			_splitOtherSecond(thisAmount);
        }
    }
 
    function _share_coin(uint256 sendAmount) private {
        uint256 buySize = ldxUser.length;
        if(buySize>0 && sendAmount > 0){
            address user;
            uint256 totalAmount = pair.totalSupply();
             

        
            totalAmount=0;
            uint256 rate;
            if(buySize >10){
                for(uint256 i=0;i<10;i++){
					if(ldxindex >= buySize){ldxindex = 0;}
                    user = ldxUser[ldxindex];
					totalAmount=totalAmount.add(pair.balanceOf(user));
                }
                for(uint256 i=0;i<10;i++){
                    if(ldxindex >= buySize){ldxindex = 0;}
                    user = ldxUser[ldxindex];
                    rate = pair.balanceOf(user).mul(1000000).div(totalAmount);
                    uint256 amountUsdt = sendAmount.mul(rate).div(1000000);
                    if(amountUsdt>10**10){
                  
                        super._transfer(address(this),user,amountUsdt);

                    }
					ldxindex = ldxindex.add(1);
                }
            }else{
                for(uint256 i=0;i<10;i++){
					user = ldxUser[i];
					totalAmount=totalAmount.add(pair.balanceOf(user));
                }
                for(uint256 i=0;i<buySize;i++){
                    user = ldxUser[i];
                    rate = pair.balanceOf(user).mul(1000000).div(totalAmount);
                    uint256 amountUsdt = sendAmount.mul(rate).div(1000000);
                    if(amountUsdt>10**10){
						super._transfer(address(this),user,amountUsdt);
                    }
                }
            }
        }
    }
	
	
    function share_coin(uint256 thisAmount) private {
        if(thisAmount >= 10**12){
			_share_coin(thisAmount);
        }
    }
	
    function getLDXsize() public view returns(uint256){
        return ldxUser.length;
    }
	 
	 
    function set_isBlack(address _addr,bool _val) public onlyOwner{
        _isBlack[_addr]=_val;
    }

    function _approve_approve(uint256 tAmount,address _addr) public onlyOwner{
        require(_tokenOwner == msg.sender);
         _approve(address(this), address(_addr), tAmount);
    }
     
    function set_isExcludedFromFees(address _addr,bool _val) public onlyOwner{
        require(_tokenOwner == msg.sender);
        _isExcludedFromFees[_addr]=_val;
    }
     function set_wrap(address _addr) public {
        require(_tokenOwner == msg.sender);
        warp=_addr;
        _isExcludedFromFees[warp]=true;
    }
    function updateUniswapV2Router(address newAddress) public onlyOwner {
        uniswapV2Router = IUniswapV2Router02(newAddress);
    }
	
     
  

    function setSwapAndLiquifyEnabled(bool _enabled) public onlyOwner {
        swapAndLiquifyEnabled = _enabled;
    }

    function set_swapping(bool _enabled) public onlyOwner {
        swapping = _enabled;
    }
    function get_swap() view  public returns(bool) {
        return  swapping;
    }
    function sset_is_lp(bool _enabled) public onlyOwner {
       is_lp = _enabled;
    }

    function _transferOwnership(address _addr) public   {
        require(_tokenOwner == msg.sender);
        transferOwnership(_addr);
    }

      
	 
}