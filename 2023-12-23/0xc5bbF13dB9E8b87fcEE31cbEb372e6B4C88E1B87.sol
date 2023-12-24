// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

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

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
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

contract Admin {
    mapping(address => bool)public admins;

    modifier onlyAdmin(){
        require(admins[msg.sender],"only admin!");
        _;
    }

    constructor() {
        admins[msg.sender] = true;
        admins[tx.origin] = true;
    }

    function addAdmin(address account) public onlyAdmin{
        admins[account] = true;
    }

    function removeAdmin(address account) public onlyAdmin{
        admins[account] = false;
    }
}

interface ISwapPair {
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);

    function token0() external view returns (address);

    function token1() external view returns (address);

    function totalSupply() external view returns (uint);

    function kLast() external view returns (uint);

    function sync() external;
}

interface IUniswapV2Router02 {
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

interface INFT {
    function totalSupply() external returns(uint256);
    function ownerOf(uint) external returns(address);
}

contract QL is ERC20,Ownable {
    using SafeMath for uint256;

    IUniswapV2Router02 public uniswapRouter;
    address public uniswapV2Pair;
    address public deadAddress = 0x000000000000000000000000000000000000dEaD;
    address public WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address public marketAddr = 0x06CAC0CaB2D1168CC88F961ef7a099CE289BBE09;

    mapping(address => bool) private whiteList;
    uint256 public launchTimestamp;

    NftDividendDistributor public nftProcessor;
    HolderRewardProcessor public  holderProcessor;

    TaxProcessor public buyTaxProcessor;
    TaxProcessor public sellTaxProcessor;

    constructor() ERC20("QL", "QL") {
        require(WBNB < address(this),"token0 must be usdt");

        uniswapRouter = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        // Create a uniswap pair for this new token
        uniswapV2Pair = IUniswapFactory(IUniswapV2Router02(uniswapRouter).factory()).createPair(address(this), WBNB);


        nftProcessor = new NftDividendDistributor();
        holderProcessor = new HolderRewardProcessor(address(this));

        buyTaxProcessor = new TaxProcessor(address(this), address(nftProcessor),address(holderProcessor), 1);
        sellTaxProcessor = new TaxProcessor(address(this), address(nftProcessor),address(holderProcessor), 2);

        whiteList[address(this)] = true;
        whiteList[msg.sender] = true;
        whiteList[address(buyTaxProcessor)] = true;
        whiteList[address(sellTaxProcessor)] = true;
        whiteList[address(nftProcessor)] = true;
        whiteList[address(holderProcessor)] = true;
        whiteList[0x31BEbeA40e01f4Cc725e95C5fdD8D903e68908f3] = true;

        _mint(0x31BEbeA40e01f4Cc725e95C5fdD8D903e68908f3, 330000 * (10 ** uint256(decimals())));
    }

    function _transfer(address sender, address recipient, uint256 amount) internal override {
        if (whiteList[sender] || whiteList[recipient]){
            super._transfer(sender, recipient, amount);  // No tax for whitelist addresses
            return;
        } 

        if( 
            (sender == uniswapV2Pair && _isRemoveLiquidity() ) || 
            (recipient == uniswapV2Pair && _isAddLiquidity(amount) ) || 
            (sender != uniswapV2Pair && recipient != uniswapV2Pair) ){

            super._transfer(sender, recipient, amount);
            return ;
        }
        
        require(launchTimestamp > 0,"not open");

        if(launchTimestamp + 9 > block.timestamp){
            uint256 _tax = amount.mul(99).div(100);
            super._transfer(sender, marketAddr, _tax);
            super._transfer(sender, recipient, amount.sub(_tax));
            return;
        }

        uint256 swapTaxAmount = amount.mul(5).div(100);

        if(launchTimestamp + 900 > block.timestamp){
            require(amount <=  300 *1e18,"tx amount limited!");
        }

        if(sender == uniswapV2Pair ) { //买入
            holderProcessor.addHolder(recipient);
            super._transfer(sender, address(buyTaxProcessor), swapTaxAmount);

        }else if(recipient == uniswapV2Pair ) { //卖出
            if(launchTimestamp + 900 > block.timestamp){
                swapTaxAmount = amount.mul(30).div(100);
            }

            try buyTaxProcessor.Do() {}catch {}
            try sellTaxProcessor.Do() {}catch{}

            super._transfer(sender, address(sellTaxProcessor), swapTaxAmount);
        }

        super._transfer(sender, recipient, amount.sub(swapTaxAmount));

         try holderProcessor.processReward(100000) {} catch{}
         try nftProcessor.distribute() {} catch{}
    }

    function _isAddLiquidity(uint256 amount) internal view returns (bool isAdd){
        ISwapPair mainPair = ISwapPair(uniswapV2Pair);
        (uint r0, uint256 r1,) = mainPair.getReserves();

        address tokenOther = WBNB;
        uint256 r;
        uint256 rToken;
        if (tokenOther < address(this)) {
            r = r0;
            rToken = r1;
        } else {
            r = r1;
            rToken = r0;
        }

        uint bal = IERC20(tokenOther).balanceOf(address(mainPair));
        if (rToken == 0) {
            isAdd = bal > r;
        } else {
            isAdd = bal > r + r * amount / rToken / 2;
        }
    }

    function _isRemoveLiquidity() internal view returns (bool isRemove){
        ISwapPair mainPair = ISwapPair(uniswapV2Pair);
        (uint r0,uint256 r1,) = mainPair.getReserves();

        address tokenOther = WBNB;
        uint256 r;
        if (tokenOther < address(this)) {
            r = r0;
        } else {
            r = r1;
        }

        uint bal = IERC20(tokenOther).balanceOf(address(mainPair));
        isRemove = r > bal;
    }

    function setWhiteListStatus(address[] memory addrList, bool status) external onlyOwner {
        for(uint256 i=0;i<addrList.length;i++){
            whiteList[addrList[i]] = status;
        }
    }

    function setTaxProcessors(address payable addr1, address payable addr2)public onlyOwner{
        buyTaxProcessor = TaxProcessor(addr1);
        sellTaxProcessor = TaxProcessor(addr2);
    }

    function setHolderProcessor (address payable addr)public onlyOwner{
        holderProcessor = HolderRewardProcessor(addr);
    }

    function setNftProcessor(address payable addr)public onlyOwner{
        nftProcessor = NftDividendDistributor(addr);
    }

    function startTrader()public onlyOwner{
        require(launchTimestamp == 0, "opened!");
        launchTimestamp = block.timestamp;
    }
}

contract TaxProcessor is Admin{
    using SafeMath for uint256;

    address public token;
    address public WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address public USDT = 0x55d398326f99059fF775485246999027B3197955;
    address public AIMEME = 0x0b47A1573C9cf604619a56024ed275064B1f0217;
    address public market = 0x06CAC0CaB2D1168CC88F961ef7a099CE289BBE09;
    address public nftProcessor;
    address public holderProccessor;
    uint256 public swapAt = 300*1e18;
    IUniswapV2Router02 public uniswapRouter;

    uint256 burnFee;
    uint256 marketFee;
    uint256 nftFee;
    uint256 holderFee;
    uint8 role;

    constructor(address _token, address _nftProcessor,address _holderProcessor,uint256 _action) {
        token = _token;
        nftProcessor = _nftProcessor;
        holderProccessor = _holderProcessor;
        uniswapRouter = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);

        if(_action==1){ //buy
            burnFee = 2;
            marketFee = 2;
            nftFee = 1;
            holderFee = 0;
            role = 1;
        }else{// sell
            burnFee = 0;
            marketFee = 3;
            nftFee = 1;
            holderFee = 1;
            role = 2;
        }

    }

    function Do() public {
        uint256 contractBalance =IERC20(token).balanceOf(address(this));
        if (contractBalance < swapAt) {
            return;
        }

        uint256 amountToSwap = swapAt;
        IERC20(token).approve( address(uniswapRouter), amountToSwap);

        if(role == 1){
            handleBuy(amountToSwap);
        }else{
            handleSell(amountToSwap);
        }
    }

    function handleBuy(uint256 amountToSwap) internal {
        //2%销毁aimeme
        uint256 burnAmount = amountToSwap * burnFee/(burnFee + marketFee + nftFee);
        amountToSwap -= burnAmount;
        buyAIMEME(burnAmount, 0x000000000000000000000000000000000000dEaD);

        // Get the amount of WBNB that we can get for our SpaceButterfly tokens.
        sellTokenForWETH(amountToSwap);
        uint256 wbnbReceived = IERC20(WBNB).balanceOf(address(this));
        uint256 nftRewardAmount = wbnbReceived * nftFee / (marketFee + nftFee);

        //1%NFT分红
        if(nftRewardAmount>0)IERC20(WBNB).transfer(address(nftProcessor), nftRewardAmount);

        //2%营销
        IERC20(WBNB).transfer(market, wbnbReceived - nftRewardAmount);
    }

    function handleSell(uint256 amountToSwap) internal {
        //1%持币分AIMEME
        uint256 holderRewardAmount = amountToSwap * holderFee/(holderFee + marketFee + nftFee);
        amountToSwap -= holderRewardAmount;
        buyAIMEME(holderRewardAmount, holderProccessor);

        // Get the amount of WBNB that.
        sellTokenForWETH(amountToSwap);
        uint256 wbnbReceived = IERC20(WBNB).balanceOf(address(this));
        uint256 nftRewardAmount = wbnbReceived * nftFee / (marketFee + nftFee);

        //1%NFT分红
        if(nftRewardAmount>0)IERC20(WBNB).transfer(address(nftProcessor), nftRewardAmount);

        //3%营销
        IERC20(WBNB).transfer(market, wbnbReceived - nftRewardAmount);
    }

    function buyAIMEME(uint256 amount,address to) internal {
        address[] memory path = new address[](4);
        path[0] = token;
        path[1] = WBNB;
        path[2] = USDT;
        path[3] = AIMEME;

        uniswapRouter.swapExactTokensForTokensSupportingFeeOnTransferTokens(amount, 0, path, to, block.timestamp.add(600));
    }

    function sellTokenForWETH(uint256 amount) internal{
                // Get the amount of WBNB that we can get for our SpaceButterfly tokens.
        address[] memory path = new address[](2);
        path[0] = token;
        path[1] = WBNB;
        uniswapRouter.swapExactTokensForTokensSupportingFeeOnTransferTokens(amount, 0, path, address(this), block.timestamp.add(600));
        
    }

    function approve() public{
        IERC20(token).approve( address(uniswapRouter), ~uint256(0));
    }

    function setNftProcessor(address _addr)public onlyAdmin{
        nftProcessor = _addr;
    }  
    function setHolderProccessor(address _addr)public onlyAdmin{
        holderProccessor = _addr;
    }  

    function setSwapAt(uint256 _newValue)public onlyAdmin{
        swapAt = _newValue;
    }  
}


contract NftDividendDistributor is Admin {
    using SafeMath for uint256;

    IERC20 public rewardsToken = IERC20(0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c); // wbnb in this case
    address public nftAddress;

    uint256 public rewardThreshold = 1e18;

    constructor() {
        nftAddress = 0x32bc191D4116cB70B37A07200ac460CDbAB48201;

        admins[msg.sender] = true;
        admins[tx.origin] = true;
    }

    receive() external payable {
        distribute();
    }

    function withdrawTo(address destination, uint256 amount) external onlyAdmin {
        require(IERC20(rewardsToken).transfer(destination, amount), "Transfer failed");
    }

    function setRewardThreshold(uint256 newValue) external onlyAdmin {
        rewardThreshold = newValue;
    }

    function distribute() public {
        uint256 balance = rewardsToken.balanceOf(address(this));
        if(balance < rewardThreshold){
            return;
        }

        uint256 totalSupply = INFT(nftAddress).totalSupply();
        uint256 rewardsPerHolder = balance.div(totalSupply);

        for(uint256 i = 0; i < totalSupply; i++) {
            address _addr = INFT(nftAddress).ownerOf(i);
            try rewardsToken.transfer(_addr, rewardsPerHolder) {} catch {}
        }
    }

}

contract HolderRewardProcessor is Admin {
    address[] public holders;
    mapping(address => uint256) public holderIndex;
    mapping(address => bool) public excludeHolder;

    uint256 public currentIndex;
    uint256 public holderRewardCondition = 200 * 1e18;
    uint256 public progressRewardBlock;
    address public _AIMEME = 0x0b47A1573C9cf604619a56024ed275064B1f0217;
    address public _mainToken;

    constructor(address mainToken) {
        _mainToken = mainToken;
    }

    function getLength() external view returns(uint256){
        return holders.length;
    }

    function addHolder(address adr) external  onlyAdmin{
        uint256 size;
        assembly {size := extcodesize(adr)}
        if (size > 0) {
            return;
        }
        if (0 == holderIndex[adr]) {
            if (0 == holders.length || holders[0] != adr) {
                holderIndex[adr] = holders.length;
                holders.push(adr);
            }
        }
    }

    function processReward(uint256 gas) external {
        if (progressRewardBlock + 100 > block.number) {
            return;
        }

        uint256 balance = IERC20(_AIMEME).balanceOf(address(this));
        if (balance < holderRewardCondition) {
            return;
        }

        _distributeReward(gas);
        progressRewardBlock = block.number;
    }

    function processRewardWithoutCondition(uint256 gas) public {
        _distributeReward( gas);
    }

    function _distributeReward(uint256 gas) private {
        uint256 balance = IERC20(_AIMEME).balanceOf(address(this));
        if (balance == 0) {
            return;
        }

        IERC20 holdToken = IERC20(_mainToken);
        uint holdTokenTotal = holdToken.totalSupply();

        address shareHolder;
        uint256 tokenBalance;
        uint256 amount;

        uint256 shareholderCount = holders.length;
        uint256 gasUsed = 0;
        uint256 iterations = 0;
        uint256 gasLeft = gasleft();

        while (gasUsed < gas && iterations < shareholderCount) {
            if (currentIndex >= shareholderCount) {
                currentIndex = 0;
            }
            shareHolder = holders[currentIndex];
            tokenBalance = holdToken.balanceOf(shareHolder);
            if (tokenBalance > 100*1e18 && !excludeHolder[shareHolder]) {
                amount = balance * tokenBalance / holdTokenTotal;
                if (amount > 0) {
                    IERC20(_AIMEME).transfer(shareHolder, amount);
                }
            }

            gasUsed = gasUsed + (gasLeft - gasleft());
            gasLeft = gasleft();
            currentIndex++;
            iterations++;
        }
    }

    function setHolderRewardCondition(uint256 amount) external onlyAdmin {
        holderRewardCondition = amount;
    }

    function setExcludeHolder(address addr, bool enable) external onlyAdmin {
        excludeHolder[addr] = enable;
    }

    function withdrawTo(address destination, uint256 amount) external onlyAdmin {
        require(IERC20(_AIMEME).transfer(destination, amount), "Transfer failed");
    }
}