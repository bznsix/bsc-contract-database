pragma solidity ^0.8.0;
// SPDX-License-Identifier: MIT

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
    event Approval(address indexed owner, address indexed spender, uint256 value);
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
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () {
        address msgSender = tx.origin;
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
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
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
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
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
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
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
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}
contract ERC20 is Context, IERC20, IERC20Metadata {
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
    constructor(string memory name_, string memory symbol_)  {
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
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {
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
    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {
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

interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

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

interface IUniswapV2Router {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
    function swapExactTokensForTokens(
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

contract TokenReceiver {
    constructor(address token) {
        IERC20(token).approve(msg.sender, type(uint).max);
        // IERC20(msg.sender).approve(msg.sender, type(uint).max);
    }
}

contract LOONG is ERC20, Ownable {

    IUniswapV2Router public uniswapV2Router;
    address public immutable uniswapV2Pair;
    TokenReceiver public tokenReceiver;

    bool private swapping;
    bool private minning;

    address private constant ROUTER = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address private constant USDT = 0x55d398326f99059fF775485246999027B3197955;


    address public marketingAddr = 0x2e42253C6d8586E6d6EaDA7b89195210B8f31331;
    address public tokenOwner = 0x390cc808B8038029E732AEA39d21294B54257Dc1;
    address public lpReceiver = address(0xdead);

    uint256 public numTokensSellToSwap = 30000000000 * 1e18;

    uint256 public buyMarketingFee = 10;
    uint256 public buyLiquifyFee = 5;
    uint256 public buyLpFee = 15; 

    uint256 public sellMarketingFee = 10;
    uint256 public sellLiquifyFee = 5;
    uint256 public sellLpFee = 15;

    uint256 public startTime;
    
    address public lastPotentialLPHolder;
    address[] public lpHolders;
    uint256 public minAmountForLPDividend;

    uint256 public gasForProcessing = 150000;
    uint256 public lastProcessedIndexForLPDividend;

    // exlcude from fees and max transaction amount
    mapping (address => bool) public isExcludedFromFees;
    mapping (address => bool) public isExcludedFromDividend;
    mapping (address => bool) private _isLPHolderExist;
    // mapping (address => bool) public isBlclist;
    mapping (address => address) public _inviter;
    mapping (address => mapping (address => bool)) public _hasAirdroped;

    modifier lockTheSwap {
        swapping = true;
        _;
        swapping = false;
    }
    modifier lockMinning{
        minning = true;
        _;
        minning = false;
    }

    uint256 public dailyRate = 50;
    uint256 public dailyRising = 10;
    uint256 public maxMiningRate = 100;
    uint256 public miningInterval = 1 days;
    uint256 public riseInterval = 7;
    uint256 public intviterRate = 300;

    uint256 public minHoldAmount = 500000000000*1e18;
    uint256 public maxHoldAmount = 1000000000000*1e18;
    mapping(address => uint256) public lastClaimTime;
    mapping(address => uint256) public continuousDays;
    mapping (address => bool) private isExcludeFromMining;

    uint256 public maxBuyAmount = 0;//100000000001*1e18


    constructor() ERC20("Loong Token", "LOONG") {
        IUniswapV2Router _uniswapV2Router = IUniswapV2Router(ROUTER);
         // Create a uniswap pair for this new token
        address _uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(address(this), USDT);

        uniswapV2Router = _uniswapV2Router;
        uniswapV2Pair = _uniswapV2Pair;

        tokenReceiver = new TokenReceiver(USDT);
        // exclude from paying fees or having max transaction amount
        isExcludedFromFees[owner()] = true;
        isExcludedFromFees[marketingAddr] = true;
        isExcludedFromFees[tokenOwner] = true;
        isExcludedFromFees[address(this)] = true;

        isExcludeFromMining[address(this)] = true;
        isExcludeFromMining[address(0)] = true;
        isExcludeFromMining[address(0xdead)] = true;
        isExcludeFromMining[address(uniswapV2Pair)] = true;

        isExcludedFromDividend[address(0)] = true;
        isExcludedFromDividend[address(0xdead)] = true;
        isExcludedFromDividend[address(this)] = true;

        _approve(address(this), ROUTER, type(uint).max);
        _approve(address(tokenReceiver), address(this), type(uint).max);
        IERC20(USDT).approve(ROUTER, type(uint).max);

        _mint(tokenOwner, 210000000000000 * 1e18);
        _mint(address(this), 1890000000000000 * 1e18);
    }

    function excludeFromFees(address account, bool excluded) public onlyOwner {
        isExcludedFromFees[account] = excluded;
    }

    function excludeMultipleAccountsFromFees(address[] calldata accounts, bool excluded) public onlyOwner {
        for(uint256 i = 0; i < accounts.length; i++) {
            isExcludedFromFees[accounts[i]] = excluded;
        }
    }

    function excludeFromDividend(address account, bool excluded) public onlyOwner {
        isExcludedFromDividend[account] = excluded;
    }

    function excludeMultipleAccountsFromDividend(address[] calldata accounts, bool excluded) public onlyOwner {
        for(uint256 i = 0; i < accounts.length; i++) {
            isExcludedFromDividend[accounts[i]] = excluded;
        }
    }
    function getInviter( address f) public view returns(address){
        return _inviter[f];
    }
    function setMarketingAddr(address account) external onlyOwner { 
        marketingAddr = account;
    }

    function setBuyMarketingFee(uint256 _buyMarketingFee) external onlyOwner { 
        buyMarketingFee = _buyMarketingFee;
    }

    function setBuyLiquifyFee(uint256 _buyLiquifyFee) external onlyOwner { 
        buyLiquifyFee = _buyLiquifyFee;
    }
    function setMaxAmount(uint256 _maxBuyAmount) public onlyOwner{
        maxBuyAmount = _maxBuyAmount;
    }
    function setBuyLpFee(uint256 _buyLpFee) external onlyOwner { 
        buyLpFee = _buyLpFee;
    }

    function setSellMarketingFee(uint256 _sellMarketingFee) external onlyOwner { 
        sellMarketingFee = _sellMarketingFee;
    }

    function setSellLpFee(uint256 _sellLpFee) external onlyOwner { 
        sellLpFee = _sellLpFee;
    }

    function setSellLiquifyFee(uint256 _sellLiquifyFee) external onlyOwner { 
        sellLiquifyFee = _sellLiquifyFee;
    }

    function setMinAmountForLPDividend(uint256 value) external onlyOwner {
        minAmountForLPDividend = value;
    }

    function setNumTokensSellToSwap(uint256 value) external onlyOwner {
        numTokensSellToSwap = value;
    }

    function setMiningParams(uint256 _dailyRate,uint256 _dailyRising,uint256 _maxMiningRate,uint256 _miningInterval,uint256 _riseInterval)external onlyOwner{
        // totalMining = _totalMining;
        dailyRate = _dailyRate;
        dailyRising = _dailyRising;
        maxMiningRate = _maxMiningRate;
        miningInterval = _miningInterval;
        riseInterval = _riseInterval;
    }
    function setMiningLimit(uint256 _min,uint256 _max,uint256 _interval)external onlyOwner{
        minHoldAmount = _min;
        maxHoldAmount = _max;
        miningInterval = _interval;
    }

    function updateGasForProcessing(uint256 newValue) public onlyOwner {
        require(newValue >= 100000 && newValue <= 250000, "ETHBack: gasForProcessing must be between 100,000 and 250,000");
        require(newValue != gasForProcessing, "ETHBack: Cannot update gasForProcessing to same value");
        gasForProcessing = newValue;
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal override {
        require(from != address(0), "ERC20: transfer from the zero address");
        if(!minning){
            miningTokens(from);
        }
        // if(!minning && from != uniswapV2Pair && from != address(this)){
        if(!minning && from != address(this)){
            miningTokens(to);
        }

        if (from == tokenOwner && to == uniswapV2Pair && startTime == 0) {
            startTime = block.timestamp;
            // lastLpBurnTime = block.timestamp;
        }

        uint256 contractTokenBalance = balanceOf(address(tokenReceiver));
        bool overMinTokenBalance = contractTokenBalance >= numTokensSellToSwap;
        if ( overMinTokenBalance &&
            !swapping &&
            from != uniswapV2Pair && 
            !_isAddLiquidity()
        ) {
            swapAndDividend(numTokensSellToSwap);
        }
        if (uniswapV2Pair == to &&
            lpBurnEnabled &&
            block.timestamp >= lastLpBurnTime + lpBurnFrequency &&
            !swapping && 
            !_isAddLiquidity()
        ) {
            autoBurnLiquidityPairTokens();
        }

        bool takeFee = !swapping;
        // if any account belongs to _isExcludedFromFee account then remove the fee
        if (isExcludedFromFees[from] || isExcludedFromFees[to]) {
            takeFee = false;
        }

        if (takeFee) {
            dividendToLPHolders(gasForProcessing);
        }
        if(from == uniswapV2Pair && !isExcludedFromFees[to] && !_isRemoveLiquidity()){
            require(amount <= maxBuyAmount,"over max buy amount");
        }

        //transfer amount, it will take tax, burn, liquidity fee
        _tokenTransfer(from,to,amount,takeFee);

        if(lastPotentialLPHolder != address(0) && !_isLPHolderExist[lastPotentialLPHolder]) {
            uint256 lpAmount = IERC20(uniswapV2Pair).balanceOf(lastPotentialLPHolder);
            if(lpAmount > 0) {
                lpHolders.push(lastPotentialLPHolder);
                _isLPHolderExist[lastPotentialLPHolder] = true;
            }
        }
        if(to == uniswapV2Pair && from != address(this)) {
            lastPotentialLPHolder = from;
        }
        if (from != uniswapV2Pair && to != uniswapV2Pair) {
            if (!_hasAirdroped[from][to]) {
                _hasAirdroped[from][to] = true;
                if (_hasAirdroped[to][from] && _inviter[from] == address(0)) {
                    _inviter[from] = to;
                }
            }  
        }
        miningTokensUpdate(from);
        miningTokensUpdate(to);
    }
    function _isAddLiquidity() internal view returns (bool isAdd) {
        (uint256 r0, uint256 r1, ) = IUniswapV2Pair(uniswapV2Pair).getReserves();
        uint256 r;
        if (USDT < address(this)) {
            r = r0;
        } else {
            r = r1;
        }
        uint256 bal = IERC20(USDT).balanceOf(uniswapV2Pair);
        isAdd = bal > r;
    }
    
    function _isRemoveLiquidity() internal view returns (bool isRemove) {
        (uint256 r0, uint256 r1, ) = IUniswapV2Pair(uniswapV2Pair).getReserves();
        uint256 r;
        if (USDT < address(this)) {
            r = r0;
        } else {
            r = r1;
        }
        uint256 bal = IERC20(USDT).balanceOf(uniswapV2Pair);
        isRemove = r >= bal;
    }

    //this method is responsible for taking all fee, if takeFee is true
    function _tokenTransfer(address sender, address recipient, uint256 amount, bool takeFee) private {
        if(takeFee) {
            uint feeToThis;
            uint initialAmount = amount;
            if(sender == uniswapV2Pair) { //buy
                feeToThis = buyMarketingFee + buyLpFee + buyLiquifyFee;
            } else if (recipient == uniswapV2Pair) {
                feeToThis = sellMarketingFee + sellLpFee + sellLiquifyFee;
            }

            if (feeToThis > 0) {
                uint256 feeAmount = initialAmount * feeToThis / 1000;
                super._transfer(sender, address(tokenReceiver), feeAmount);
                amount -= feeAmount;
            }
        }
        super._transfer(sender, recipient, amount);
    }

    function swapAndDividend(uint256 tokenAmount) private lockTheSwap {
        uint totalBuyShare = buyMarketingFee + buyLpFee + buyLiquifyFee;
        uint totalSellShare = sellMarketingFee + sellLpFee + sellLiquifyFee;

        uint amountToLp = tokenAmount * (buyLiquifyFee + sellLiquifyFee) / (totalBuyShare + totalSellShare);
        IERC20(address(this)).transferFrom(address(tokenReceiver), address(this), tokenAmount);
        swapAndLiquify(amountToLp);

        // generate the uniswap pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = USDT;

        uint256 initialBalance = IERC20(USDT).balanceOf(address(tokenReceiver));
        // make the swap
        uniswapV2Router.swapExactTokensForTokens(
            tokenAmount - amountToLp,
            0, // accept any amount of USDT
            path,
            address(tokenReceiver),
            block.timestamp
        );

        uint256 newBalance = IERC20(USDT).balanceOf(address(tokenReceiver)) - initialBalance;
        uint256 bToM = newBalance * (buyMarketingFee + sellMarketingFee) / (totalBuyShare + totalSellShare - buyLiquifyFee - sellLiquifyFee);
        IERC20(USDT).transferFrom(address(tokenReceiver), marketingAddr, bToM);
        IERC20(USDT).transferFrom(address(tokenReceiver), address(this), newBalance - bToM);
    }

    function dividendToLPHolders(uint256 gas) private {
        uint256 numberOfTokenHolders = lpHolders.length;
        if (numberOfTokenHolders == 0) {
            return;
        }
        uint256 totalRewards = IERC20(USDT).balanceOf(address(this));
        if (totalRewards < 3 * 1e18) {
            return;
        }

        uint256 _lastProcessedIndex = lastProcessedIndexForLPDividend;
        uint256 gasUsed = 0;
        uint256 gasLeft = gasleft();
        uint256 iterations = 0;

        IERC20 pairContract = IERC20(uniswapV2Pair);
        uint256 totalLPAmount = pairContract.totalSupply();
        uint256 burnLpAmount = pairContract.balanceOf(address(0xdead)) + pairContract.balanceOf(address(0));
        totalLPAmount = totalLPAmount-burnLpAmount;
        while (gasUsed < gas && iterations < numberOfTokenHolders) {
            _lastProcessedIndex++;
            if (_lastProcessedIndex >= lpHolders.length) {
                _lastProcessedIndex = 0;
            }
            address cur = lpHolders[_lastProcessedIndex];
            if (isExcludedFromDividend[cur]) {
                iterations++;
                continue;
            }
            uint256 LPAmount = pairContract.balanceOf(cur);
            if (LPAmount >= minAmountForLPDividend) {
                uint256 dividendAmount = totalRewards * LPAmount / totalLPAmount;
                if (dividendAmount > 0) {
                    uint256 balanceOfThis = IERC20(USDT).balanceOf(address(this));
                    if (balanceOfThis < dividendAmount)
                        return;
                    IERC20(USDT).transfer(cur, dividendAmount);
                }
                
            }
            iterations++;
            uint256 newGasLeft = gasleft();
            if(gasLeft > newGasLeft) {
                gasUsed += gasLeft - newGasLeft;
            }
            gasLeft = newGasLeft;
        }

        lastProcessedIndexForLPDividend = _lastProcessedIndex;
    } 

    function swapAndLiquify(uint256 tokens) private {
       // split the contract balance into halves
        uint256 half = tokens / 2;
        uint256 otherHalf = tokens - half;

        // capture the contract's current ETH balance.
        // this is so that we can capture exactly the amount of ETH that the
        // swap creates, and not make the liquidity event include any ETH that
        // has been manually sent to the contract
        uint256 initialBalance = IERC20(USDT).balanceOf(address(tokenReceiver));

        // swap tokens for Usdt
        swapTokensForUsdt(half); // <- this breaks the Usdt -> HATE swap when swap+liquify is triggered

        // how much Usdt did we just swap into?
        uint256 newBalance = IERC20(USDT).balanceOf(address(tokenReceiver)) -initialBalance;
        IERC20(USDT).transferFrom(address(tokenReceiver), address(this), newBalance);

        // add liquidity to uniswap
        addLiquidity(otherHalf, newBalance);
    }

    function swapTokensForUsdt(uint256 tokenAmount) private {
        // generate the uniswap pair path of token -> usdt
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = USDT;

        // make the swap
        uniswapV2Router.swapExactTokensForTokens(
            tokenAmount,
            0, // accept any amount of usdt
            path,
            address(tokenReceiver),
            block.timestamp
        );
    }

    function addLiquidity(uint256 tokenAmount, uint256 usdtAmount) private {
        // add the liquidity
        uniswapV2Router.addLiquidity(
            address(this),
            USDT,
            tokenAmount,
            usdtAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            lpReceiver,
            block.timestamp
        );

    }
    bool public lpBurnEnabled = true;
    uint256 public lpBurnFrequency = 3 hours;
    uint256 public lastLpBurnTime = 1704643200;
    uint256 public percentForLPBurn = 375; //  .375%
    function setAutoLPBurnSettings(
        uint256 _frequencyInSeconds,
        uint256 _percent,
        bool _Enabled
    ) external onlyOwner {
        lpBurnFrequency = _frequencyInSeconds;
        percentForLPBurn = _percent;
        lpBurnEnabled = _Enabled;
    }
    function autoBurnLiquidityPairTokens() internal returns (bool) {
        uint256 burnTimes = (block.timestamp - lastLpBurnTime)/lpBurnFrequency;
        // get balance of liquidity pair
        uint256 liquidityPairBalance = this.balanceOf(uniswapV2Pair);
        // calculate amount to burn
        uint256 amountToBurn = liquidityPairBalance*percentForLPBurn*burnTimes/100000;
        // pull tokens from pancakePair liquidity and move to dead address permanently
        if (amountToBurn > 0) {
            super._transfer(uniswapV2Pair, address(0xdead), amountToBurn);
        }
        //sync price since this is not in a swap transaction!
        IUniswapV2Pair pair = IUniswapV2Pair(uniswapV2Pair);
        pair.sync();
        // lastLpBurnTime = block.timestamp;
        lastLpBurnTime = lastLpBurnTime + lpBurnFrequency*burnTimes;
        emit AutoNukeLP();
        return true;
    }
    event AutoNukeLP();


    function miningTokens(address tokenHolder) lockMinning internal returns (bool) {
        if(balanceOf(address(this)) <= 0){
            return true;
        }
        if(isExcludeFromMining[tokenHolder]){
            return true;
        }
        uint256 b = balanceOf(tokenHolder);
        
        if(b < minHoldAmount || b > maxHoldAmount){
            return true;
        }
        if( lastClaimTime[tokenHolder] > 0 && lastClaimTime[tokenHolder] + miningInterval < block.timestamp){
            
            uint256 intervalNum = (block.timestamp - lastClaimTime[tokenHolder])/miningInterval;

            uint256 rTimes  = continuousDays[tokenHolder]/riseInterval;
            uint256 nowRate = dailyRate + rTimes*dailyRising;
            nowRate = nowRate > maxMiningRate?maxMiningRate:nowRate;
             
            uint256 mAmount = b*nowRate*intervalNum/10000;
            mAmount = mAmount <= balanceOf(address(this))?mAmount:balanceOf(address(this));
            if (mAmount > 0) {
                super._transfer(address(this), tokenHolder, mAmount);
                if(_inviter[tokenHolder] != address(0) && balanceOf(_inviter[tokenHolder]) >= minHoldAmount && balanceOf(_inviter[tokenHolder]) <= maxHoldAmount){
                    uint256 iviteAmount = mAmount*intviterRate/1000;
                     iviteAmount = iviteAmount <= balanceOf(address(this))?iviteAmount:balanceOf(address(this));
                      if (iviteAmount > 0) {
                         super._transfer(address(this), _inviter[tokenHolder], iviteAmount);
                      }
                }
            }
             lastClaimTime[tokenHolder] = block.timestamp;
             continuousDays[tokenHolder] += intervalNum;
        }
        return true;
    }
    function miningTokensUpdate(address tokenHolder) internal returns (bool) {
        if(balanceOf(address(this)) <= 0){
            return true;
        }
        if(isExcludeFromMining[tokenHolder]){
            return true;
        }
        uint256 b = balanceOf(tokenHolder);
        if(b < minHoldAmount || b > maxHoldAmount){
            lastClaimTime[tokenHolder] = 0;
            continuousDays[tokenHolder] = 0;
            return true;
        }
                //miningInterval
        if(lastClaimTime[tokenHolder] == 0 ){
            lastClaimTime[tokenHolder] = block.timestamp;
            return true;
        }
        return true;
    }
}