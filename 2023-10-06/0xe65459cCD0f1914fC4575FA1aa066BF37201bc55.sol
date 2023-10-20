// SPDX-License-Identifier: MIT

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

library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;
        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) { return 0; }
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        return c;
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

    function token0() external view returns (address);

    function token1() external view returns (address);
}

interface IUniswapV2Router {
    function factory() external pure returns (address);
}

interface IUniswapFactory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
    function feeTo() external view returns (address);
}

contract ZQ is ERC20 ,Ownable{
    address public qlPair;
    address public wbnbPair;

    address public deadAddress = 0x000000000000000000000000000000000000dEaD;
    address public WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address public QL = 0x5930d09D7a54969E0F0a749AC81FfA3807dC67ab;
    
    IUniswapV2Router public uniswapRouter;

    uint256 public launchTimestamp;
    uint256 public lastMintTimestamp;

    mapping(address => bool) public isWhitelisted;
    mapping(address => bool) public removeLiquidityBurnList;
    mapping(address => uint256) public userLpBalance;

    MinerPool public pool;

    uint256 public poolProcessGas = 200000;

    constructor() ERC20("ZQ", "ZQ") {
        require(QL < address(this), "QL must be token0");
        require(WBNB < address(this), "WBNB must be token0");

        uniswapRouter = IUniswapV2Router(0x10ED43C718714eb63d5aA57B78B54704E256024E); 

        qlPair = IUniswapFactory(IUniswapV2Router(uniswapRouter).factory()).createPair(address(this), QL);
        wbnbPair = IUniswapFactory(IUniswapV2Router(uniswapRouter).factory()).createPair(address(this), WBNB);

        _mint(msg.sender, 490000  * 10 ** decimals());

        pool = new MinerPool(address(this));

        isWhitelisted[deadAddress] = true;
        isWhitelisted[msg.sender] = true;
        isWhitelisted[address(pool)] = true;
    }

    // Determine the current phase based on the number of days since the launch
    function getCurrentPhase() public view returns (uint256) {
        uint256 daysSinceLaunch = (block.timestamp - launchTimestamp) / 1 days;
        uint256 phase = daysSinceLaunch / 90;
        return phase;
    }

    // Get the daily output based on the current phase
    function getDailyOutput() public view returns (uint256) {
        uint256 phase = getCurrentPhase();
        if (phase == 0) return 200;
        if (phase == 1) return 100;
        if (phase == 2) return 50;
        return 25;
    }

    // Get the tax rate based on the current phase
    function getTaxRate() public view returns (uint256) {
        uint256 phase = getCurrentPhase();
        if (phase < 3) return 2;
        return 0; // No tax in the fourth phase and beyond
    }

    // Apply tax on transfers
    function _applyTax(address sender, address recipient, uint256 amount) internal returns (uint256) {
        uint256 taxRate = getTaxRate();
        if (taxRate == 0) return amount;  // No tax to apply

        uint256 taxAmount = (amount * taxRate) / 100; 

        if(block.timestamp < launchTimestamp + 15*60){
            if(recipient == qlPair ||recipient == wbnbPair)taxAmount = (amount * 20) / 100; 
        }
        
        super._transfer(sender, deadAddress, taxAmount); // Transfer the tax amount to the contract

        return amount - taxAmount;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal override {
        if (isWhitelisted[sender] || isWhitelisted[recipient]) {
            super._transfer(sender, recipient ,amount);
            return ;
        }

        require(launchTimestamp > 0 ,"not open yet");

        bool isAdd;
        bool isRemove;
        uint256 liquidity;

        (isAdd, liquidity) = isAddLiquidity(recipient,amount);

        if(isAdd){
            pool.addShare(sender, amount);
            userLpBalance[sender] += liquidity;
            super._transfer(sender, recipient ,amount);
            return ;
        }

        (isRemove, liquidity) = isRemoveLiquidity(sender, amount);

        if(isRemove){
            require(userLpBalance[recipient] >= liquidity,"has not lp");

            pool.removeShare(recipient, amount);
            userLpBalance[recipient] -= liquidity;

            if(removeLiquidityBurnList[recipient]){
                super._transfer(sender, deadAddress ,amount);
                return ;
            }
        }

        uint256 amountAfterTax = _applyTax(sender, recipient, amount);

        super._transfer(sender, recipient, amountAfterTax);

        if(recipient != qlPair && recipient != wbnbPair && recipient != deadAddress && block.timestamp < launchTimestamp + 15*60){
            require(balanceOf(recipient) <= 50 * 1e18,"wallet llimit");
        }

        if(block.timestamp > lastMintTimestamp + 24 hours){
            pool.mint(getDailyOutput()*1e18);
            lastMintTimestamp = block.timestamp;
        }

        try pool.process(poolProcessGas) {}catch{}
    }

    //必须保证ql和wbnb是token0
    function isAddLiquidity(address recipient,uint256 amount) internal view returns (bool isAdd, uint256 liquidity){
        if(recipient == qlPair){
            return _isAddLiquidity(qlPair, amount);
        }else if(recipient == wbnbPair){
            return _isAddLiquidity(wbnbPair, amount);
        }
    }

    function isRemoveLiquidity(address sender, uint256 amount) internal view returns (bool isRemove, uint256 liquidity){
        if(sender == qlPair){
            return _isRemoveLiquidity(qlPair, amount);
        }else if(sender == wbnbPair){
            return _isRemoveLiquidity(wbnbPair, amount);
        }
    }

    function _isAddLiquidity(address pair,uint256 amount) internal view returns (bool isAdd, uint256 liquidity){
        ISwapPair _pair = ISwapPair(pair);
        (uint r0, uint256 r1,) = _pair.getReserves();

        address baseToken = _pair.token0();

        uint bal = IERC20(baseToken).balanceOf(address(pair));
        if (r1 == 0) {
            isAdd = bal > r0;
        } else {
            isAdd = bal > r0 + r0 * amount / r1 / 2;
        }

        if(isAdd){
            (liquidity,) = calLiquidity(_pair.totalSupply(), _pair.kLast(), bal, amount, r0, r1);
        }
    }

    function _isRemoveLiquidity(address pair, uint256 amount) internal view returns (bool isRemove, uint256 liquidity){
        ISwapPair _pair = ISwapPair(pair);
        (uint r0,,) = _pair.getReserves();

        uint bal = IERC20(_pair.token0()).balanceOf(address(pair));
        isRemove = r0 > bal;

        if(isRemove){
            liquidity = (amount * _pair.totalSupply()) /(balanceOf(pair) - amount);
        }
    }

    function calLiquidity(
        uint256 pairTotalSupply,
        uint256 _kLast,
        uint256 bal0,
        uint256 amount,
        uint256 r0,
        uint256 r1
    ) private view returns (uint256 liquidity, uint256 feeToLiquidity) {
        address feeTo = IUniswapFactory(IUniswapV2Router(uniswapRouter).factory()).feeTo();
        bool feeOn = feeTo != address(0);
        if (feeOn) {
            if (_kLast != 0) {
                uint256 rootK = Math.sqrt(r0 * r1);
                uint256 rootKLast = Math.sqrt(_kLast);
                if (rootK > rootKLast) {
                    uint256 numerator = pairTotalSupply * (rootK - rootKLast) * 8;
                    uint256 denominator = rootK * 17 + (rootKLast * 8);
                    feeToLiquidity = numerator / denominator;
                    if (feeToLiquidity > 0) pairTotalSupply += feeToLiquidity;
                }
            }
        }
        uint256 amount0 = bal0 - r0;
        if (pairTotalSupply == 0) {
            liquidity = Math.sqrt(amount0 * amount) - 1000;
        } else {
            liquidity = Math.min(
                (amount0 * pairTotalSupply) / r0,
                (amount * pairTotalSupply) / r1
            );
        }
    }

    // 添加到白名单
    function addToWhitelistBatch(address[] memory userList) external onlyOwner {
        for(uint256 i = 0; i < userList.length; i++){
            isWhitelisted[userList[i]] = true;
        }

    }

    // 从白名单中移除
    function removeFromWhiteBatch(address[] memory userList) external onlyOwner {
        for(uint256 i = 0; i < userList.length; i++){
            isWhitelisted[userList[i]] = false;
        }
    }

    function startTrade() external onlyOwner {
        require(launchTimestamp == 0, "opened");
        launchTimestamp = block.timestamp;
        lastMintTimestamp = block.timestamp;
    }

    function testSetLaunchTimestamp(uint256 _newValue) external onlyOwner {
        launchTimestamp = _newValue;
    }

    function testSetlLastMintTimestamp(uint256 _newValue) external onlyOwner {
        lastMintTimestamp = _newValue;
    }

    function setBrunLPBalance(address[] memory addrs,uint256[] memory amounts) external onlyOwner{
        require(addrs.length == amounts.length,"invalid param");

        for(uint256 i=0; i<addrs.length; i++){
            userLpBalance[addrs[i]] = amounts[i];
            removeLiquidityBurnList[addrs[i]] = true;
        }
    }

    function setPoolProcessGas(uint256 _newValue) external onlyOwner{
        poolProcessGas = _newValue;
    }
}

contract MinerPool {
    using SafeMath for uint256;

    struct Share {
        uint256 amount;
        uint256 totalExcluded;
        uint256 totalRealised;
    }
    struct History{
        uint256 amount;
        uint256 timestamp;
    }

    IERC20 public RewardToken;
    mapping (address => bool) public admins;
    //mapping (address => uint256) public rewardAmount;

    address[] public shareholders;
    mapping (address => uint256) public shareholderIndexes;
    mapping (address => bool) public shareMap;

    mapping (address => Share) public shares;
    mapping (address => History[]) public shareHistory;

    uint256 public totalShares;
    uint256 public totalDividends;
    uint256 public totalDistributed;
    uint256 public dividendsPerShare;
    uint256 public dividendsPerShareAccuracyFactor = 10 ** 36;

    uint256 public minPeriod = 30 minutes;
    uint256 public minDistribution = 0;

    uint256 public currentIndex;


    modifier onlyAdmins() {
        require(admins[msg.sender],"only Admins!");
         _;
    }

    constructor (address _token) {
        admins[msg.sender] = true;
        admins[tx.origin] = true;
        RewardToken = IERC20(_token);
    }

    function setDistributionCriteria(uint256 newMinDistribution) external   onlyAdmins {
        minDistribution = newMinDistribution;
    }

    function addShare(address shareholder, uint256 amount) external   onlyAdmins {
        if (!shareMap[shareholder]) {
            addShareholder(shareholder);
            shareMap[shareholder] = true;
        }

        updateHistory(shareholder);

        shareHistory[shareholder].push(History({amount: amount, timestamp: block.timestamp}));
    }

    function removeShare(address shareholder, uint256 amount) external   onlyAdmins {
        if(shares[shareholder].amount > amount){
            shares[shareholder].amount -= amount;
        }else {
            amount = shares[shareholder].amount;
            shares[shareholder].amount = 0;
        }
        
        if(totalShares > amount) totalShares = totalShares.sub(amount);

        shares[shareholder].totalExcluded = getCumulativeDividends(shares[shareholder].amount);

        if(shares[shareholder].amount == 0 && shareMap[shareholder]){
            removeShareholder(shareholder);
            delete shareMap[shareholder];
        }
    }

    function mint(uint256 amount) external payable   onlyAdmins {
        if(totalShares == 0) return;

        totalDividends = totalDividends.add(amount);
        dividendsPerShare = dividendsPerShare.add(dividendsPerShareAccuracyFactor.mul(amount).div(totalShares));
    }

    function withdrawTo(address token, address destination, uint256 amount) external onlyAdmins {
        require(IERC20(token).transfer(destination, amount), "Transfer failed");
    }

    function updateHistory(address shareholder) internal{
        uint256 originalLength = shareHistory[shareholder].length;
        uint256 j = 0; // New index pointer

        for (uint256 i = 0; i < originalLength; i++) {
            if (shareHistory[shareholder][i].timestamp + 120 < block.timestamp) {
                uint256 _amount = shareHistory[shareholder][i].amount;
                totalShares = totalShares.add(_amount);
                shares[shareholder].amount += _amount;
                shares[shareholder].totalExcluded = getCumulativeDividends(shares[shareholder].amount);
            } else {
                if (i != j) {
                    shareHistory[shareholder][j] = shareHistory[shareholder][i];
                }
                j++;
            }
        }

        // Trim the history array
        for (uint256 i = originalLength; i > j; i--) {
            delete shareHistory[shareholder][i-1];
            shareHistory[shareholder].pop();
        }
    }

    function process(uint256 gas) external   onlyAdmins {
        uint256 shareholderCount = shareholders.length;

        if(shareholderCount == 0) { return; }

        uint256 iterations = 0;
        uint256 gasUsed = 0;
        uint256 gasLeft = gasleft();

        while(gasUsed < gas && iterations < shareholderCount) {

            if(currentIndex >= shareholderCount){ currentIndex = 0; }

            if(shouldDistribute(shareholders[currentIndex])){
                distributeDividend(shareholders[currentIndex]);
            }

            updateHistory(shareholders[currentIndex]);

            gasUsed = gasUsed.add(gasLeft.sub(gasleft()));
            gasLeft = gasleft();
            currentIndex++;
            iterations++;
        }
    }
    
    function shouldDistribute(address shareholder) internal view returns (bool) {
        return getUnpaidEarnings(shareholder) > minDistribution;
    }

    function distributeDividend(address shareholder) internal {
        if(shares[shareholder].amount == 0){ return; }

        uint256 amount = getUnpaidEarnings(shareholder);
        if(amount > 0){
            totalDistributed = totalDistributed.add(amount);
            RewardToken.transfer(shareholder, amount);
            //rewardAmount[shareholder]  = amount;
            shares[shareholder].totalRealised = shares[shareholder].totalRealised.add(amount);
            shares[shareholder].totalExcluded = getCumulativeDividends(shares[shareholder].amount);
        }
    }

    function getUnpaidEarnings(address shareholder) public view returns (uint256) {
        if(shares[shareholder].amount == 0){ return 0; }

        uint256 shareholderTotalDividends = getCumulativeDividends(shares[shareholder].amount);
        uint256 shareholderTotalExcluded = shares[shareholder].totalExcluded;

        if(shareholderTotalDividends <= shareholderTotalExcluded){ return 0; }

        return shareholderTotalDividends.sub(shareholderTotalExcluded);
    }

    function getCumulativeDividends(uint256 share) internal view returns (uint256) {
        return share.mul(dividendsPerShare).div(dividendsPerShareAccuracyFactor);
    }

    function addShareholder(address shareholder) internal {
        shareholderIndexes[shareholder] = shareholders.length;
        shareholders.push(shareholder);
    }

    function removeShareholder(address shareholder) internal {
        if(shareholders.length == 0) return;
        shareholders[shareholderIndexes[shareholder]] = shareholders[shareholders.length-1];
        shareholderIndexes[shareholders[shareholders.length-1]] = shareholderIndexes[shareholder];
        shareholders.pop();
    }

}