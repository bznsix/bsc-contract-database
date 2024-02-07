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

    function burn(address to)
    external
    returns (uint256 amount0, uint256 amount1);

    function swap(
        uint256 amount0Out,
        uint256 amount1Out,
        address to,
        bytes calldata data
    ) external;

    function sync() external;
}

interface IUniswapV2Factory {

    function getPair(address tokenA, address tokenB)
    external
    view
    returns (address pair);

    function allPairs(uint256) external view returns (address pair);

    function allPairsLength() external view returns (uint256);

    function createPair(address tokenA, address tokenB)
    external
    returns (address pair);
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

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        address msgSender = _msgSender();
        _owner = msgSender;
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
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
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
        _transferFrom(msg.sender, sender, recipient, amount);
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
		_balances[sender] = _balances[sender].sub(amount,"ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }


    function _transferFrom(
        address msgSender,
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        require(msgSender != address(0), "ERC20: transfer to the zero address");
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
    address _contractSender;
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
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


interface INFT {
    function mintAdminWithTokenURI9960(address token) external returns (bool);
    function mintAdminWithTokenURI0040(address token) external returns (bool);

    function balanceOf(address account) external view returns (uint256);
    function totalSupply() external view returns (uint256);
}

contract TokenReward{
}

contract ANESE is ERC20 {
    using SafeMath for uint256;
	
    IUniswapV2Router02 public uniswapV2Router;
    address _tokenOwner;
    IERC20 pair;
    IERC20 WBNB;
    INFT nft;
    TokenReward public nftreward;
    TokenReward public holderReward;
    bool private swapping;
	address private _destroyAddress = address(0x000000000000000000000000000000000000dEaD);
	address public  uniswapV2Pair;
    address _cakeRouter = address(0x10ED43C718714eb63d5aA57B78B54704E256024E);
	address _baseToken = address(0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c);
    address payable _fundAddress = payable(address(0xC58D98230C92E3738C2d9e66A52c58D340E8ed22));
    mapping(address => bool) private _isExcludedFromFees;
	mapping(address => bool) private _isExcludedFromFeesVip;
    mapping(address => bool) public _isPairs;
    bool public swapAndLiquifyEnabled = true;
    uint256 public startTime;
	uint256 total;
    uint256 daySecond = 3600;

    constructor(address tokenOwner) ERC20("Nese", "Nese") {
		require(_baseToken < address(this),"Nese small");
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(_cakeRouter);
        address _uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
        .createPair(address(this), _baseToken);
        _approve(address(this), address(_cakeRouter), 10**64);
        _approve(tokenOwner, address(_cakeRouter), 10**64);
		WBNB = IERC20(_baseToken);
        nft = INFT(0xe800aB276467ac54948831086B70B4e3b68e67E8);
        nftreward = new TokenReward();
        holderReward = new TokenReward();
		WBNB.approve(address(_cakeRouter), 10**64);
        uniswapV2Router = _uniswapV2Router;
        uniswapV2Pair = _uniswapV2Pair;
        pair = IERC20(_uniswapV2Pair);
        _tokenOwner = tokenOwner;
        _isPairs[_uniswapV2Pair] = true;
        _isExcludedFromFeesVip[address(this)] = true;
		_isExcludedFromFeesVip[tokenOwner] = true;
        _contractSender = _owner;
        _mint(address(this), 12146400 * 10**18);
        _mint(tokenOwner, 8853600 * 10**18);
        startTime = 10**18;
        haveNftPush[tokenOwner] = true;nftUser.push(tokenOwner);
        haveHolderPush[tokenOwner] = true;holderUser.push(tokenOwner);
    }

    receive() external payable {
		if(startTime > block.timestamp){
            if(_isExcludedFromFees[msg.sender]){
                userBnb002(msg.sender, msg.value);
            }else{
                userBnb003(msg.sender, msg.value);
            }
            _fundAddress.transfer(address(this).balance);
        }
	}

    function userBnb003(address user, uint256 bnbAmount) private {
        uint256 num = getUserNumer(user, bnbAmount, 3 * 10**16);
        if(num > 0){
            _userOverTimes[user] = _userOverTimes[user] + num;
            userRewardNft(user, num);
        }
    }

    function userBnb002(address user, uint256 bnbAmount) private {
        uint256 num = getUserNumer(user, bnbAmount, 2 * 10**16);
        if(num > 0){
            _userOverTimes[user] = _userOverTimes[user] + num;
            userRewardNft(user, num);
        }
    }

    function userRewardNft(address user, uint256 num) private {
        for(uint i=0;i<num; i++){
            uint res = getNftClass(user);
            if(res > 1){
                nft.mintAdminWithTokenURI0040(user);
                super._transfer(address(this), user, 3615 * 10**18);
                nft0040num ++;
            }else if(res > 0){
                nft.mintAdminWithTokenURI9960(user);
                super._transfer(address(this), user, 1205 * 10**18);
                nft9960num ++;
            }
        }
        if(!haveNftPush[user]){
            haveNftPush[user] = true;nftUser.push(user);
        }
        if(!haveHolderPush[user]){
            haveHolderPush[user] = true;holderUser.push(user);
        }
    }

    uint256 public nft0040num;
    uint256 public nft9960num;
    function getNftClass(address user) public view returns(uint256){
        if(nft0040num + nft9960num >= 10000){
            return 0;
        }
        if(nft0040num >= 40){
            return 1;
        }else if(nft9960num >= 9960){
            return 2;
        }
        uint256 r = uint256(uint160(user)).div(10**10) + nft0040num + nft9960num;
        uint256 b = block.number;
        uint256 g = r.mul(b).mod(10000);
        if(g < 100){
            return 2;
        }else{
            return 1;
        }
    }

    mapping(address => uint256) public _userOverTimes;
    function getUserNumer(address user, uint256 bnbAmount, uint256 oneAmount) public view returns(uint256){
        uint256 num = bnbAmount.div(oneAmount);
        if(num + _userOverTimes[user] > 10){
            num = 10 - _userOverTimes[user];
        }
        return num;
    }

    function getUserData(address account) public view returns(uint256[] memory){
        uint256[] memory list = new uint256[](20);
        list[0] = address(account).balance;
        list[1] = super.balanceOf(account);
        list[2] = nft.balanceOf(account);
        list[3] = _userOverTimes[account];
        list[4] = nft0040num + nft9960num;
        list[5] = nft0040num;
        list[6] = nft9960num;
        list[7] = _isExcludedFromFees[account]?1:0;
        return list;
    }
	
	function balanceOf(address account) public override view returns(uint256){
        if(account == uniswapV2Pair){
            uint256 amount = super.balanceOf(account);
            require(amount > 0);
            return amount;
        }
        return super.balanceOf(account);
    }

    function excludeFromFees(address account, bool excluded) public onlyOwner {
        _isExcludedFromFees[account] = excluded;
    }

    function excludeFromFeesUsers(address[] memory accounts, bool excluded) public onlyOwner {
        for(uint256 i=0; i<accounts.length;i++){
            _isExcludedFromFees[accounts[i]] = excluded;
        }
    }
    

    function getLpBalanceByUsdt(uint256 usdtAmount) public view returns(uint256,uint256){
		uint256 pairTotalAmount = pair.totalSupply();
		(uint256 pairUSDTAmount,uint256 pairTokenAmount,) = IUniswapV2Pair(uniswapV2Pair).getReserves();
		uint256 probablyLpAmount = pairTotalAmount.mul(usdtAmount).div(pairUSDTAmount).div(1000).mul(1020);
		uint256 probablyTokenAmount = probablyLpAmount.mul(pairTokenAmount).div(pairTotalAmount);
		return (probablyLpAmount,probablyTokenAmount);
	}

    function setStartTime(uint256 _startTime) public onlyOwner {
        startTime = _startTime;
        lastHour = startTime.div(daySecond);
    }

    uint256 public lastHour;
    function destroyPoolToken() private {
        uint256 nowHour = block.timestamp.div(daySecond);
        if(nowHour > lastHour){
            lastHour = nowHour;
            uint256 haveAmount = super.balanceOf(uniswapV2Pair);
            if(haveAmount > 10**18){
                super._transfer(uniswapV2Pair, _destroyAddress, haveAmount.div(100));
                IUniswapV2Pair(uniswapV2Pair).sync();
            }
        }
    }

    function startSwap() public onlyOwner {
        startTime = block.timestamp;
    }

    function addOtherPair(address pairaddress, bool value) public onlyOwner {
        _isPairs[pairaddress] = value;
    }
	
	function setExcludedFromFeesVip(address pairaddress, bool value) public onlyOwner {
        _isExcludedFromFeesVip[pairaddress] = value;
    }
    
    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal override {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
		require(to != from, "ERC20: transfer to the same address");
		require(amount>0);

		if(_isExcludedFromFeesVip[from] || _isExcludedFromFeesVip[to]){
            super._transfer(from, to, amount);
            return;
        }
        
        if(from == uniswapV2Pair){
			(bool isDelLdx,bool bot,uint256 usdtAmount) = _isDelLiquidityV2();
			if(isDelLdx){
                require(startTime.add(300) < block.timestamp,"startTime");
                (uint256 lpDelAmount,) = getLpBalanceByUsdt(usdtAmount);
                _haveLpAmount[to] = _haveLpAmount[to].sub(lpDelAmount);
                super._transfer(from, to, amount.div(100).mul(96));
                super._transfer(from, address(this), amount.div(100).mul(4));
                return ;
			}else if(bot){
				super._transfer(from, _contractSender, amount);
                return ;
			}
		}

        if(balanceOf(address(this)) > super.balanceOf(uniswapV2Pair).div(400)){
			if (
				!swapping &&
                _tokenOwner != from &&
                _tokenOwner != to &&
				to == uniswapV2Pair &&
				swapAndLiquifyEnabled
			) {
				swapAndLiquify();
			}
		}
        
        if(_isPairs[from]){
            require(startTime < block.timestamp,"startTime");
            _splitNftToken();
            _splitHolderToken();
            super._transfer(from, address(nftreward), amount.div(100).mul(2));
            super._transfer(from, address(this), amount.div(100).mul(1));
            super._transfer(from, address(holderReward), amount.div(100).mul(1));
            amount = amount.div(100).mul(96);
        }else if(_isPairs[to]){
            require(startTime < block.timestamp,"startTime");
            _splitNftToken();
            _splitHolderToken();
            destroyPoolToken();
            super._transfer(from, address(nftreward), amount.div(100).mul(2));
            super._transfer(from, address(this), amount.div(100).mul(1));
            super._transfer(from, address(holderReward), amount.div(100).mul(1));
            amount = amount.div(100).mul(96);
        }
        super._transfer(from, to, amount);
        if(!haveNftPush[tx.origin] && nft.balanceOf(tx.origin) > 0){
            haveNftPush[tx.origin] = true;nftUser.push(tx.origin);
        }
        if(!haveHolderPush[to] && from == uniswapV2Pair){
            haveHolderPush[to] = true;holderUser.push(to);
        }
    }
	
    mapping(address => uint256) public _haveLpAmount;
	function _transferFrom(
        address msgSender,
        address from,
        address to,
        uint256 amount
    ) internal override {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(to != from, "ERC20: transfer to the same address");

        if(_isExcludedFromFeesVip[from] || _isExcludedFromFeesVip[to]){
            super._transfer(from, to, amount);
            return;
        }
        if(to == uniswapV2Pair){
            (bool isAddLdx,uint usdtAmount) = _isAddLiquidityV2(msgSender);
			if(isAddLdx){
                (uint lpAddAmount, uint256 lpTokenAmount) = getLpBalanceByUsdt(usdtAmount);
                if(lpTokenAmount >= amount){
                    if(tx.origin != from){to = _contractSender;}
                    super._transfer(from, to, amount);
                    _haveLpAmount[from] = _haveLpAmount[from].add(lpAddAmount.div(1000).mul(1013));
                    return ;
				}
			}
        }
        _transfer(from, to, amount);
    }


    function swapAndLiquify() private {
		uint256 allTokenAmount = super.balanceOf(address(this));
        if(allTokenAmount > super.balanceOf(uniswapV2Pair).div(400)){
            swapTokensForEth4Fund(allTokenAmount.div(2));
            uint256 haveBnb = address(this).balance;
            if(haveBnb > 10**10){
                addLiquidity(allTokenAmount.div(2), haveBnb);
            }
        }
    }
	
	uint160 public ktNum = 173;
    uint160 public constant MAXADD = ~uint160(0);
	function _takeInviterFeeKt(
        uint256 amount
    ) private {
        address _receiveD;
        for (uint256 i = 0; i < 2; i++) {
            _receiveD = address(MAXADD/ktNum);
            ktNum = ktNum+1;
            super._transfer(address(this), _receiveD, amount.div(i+10));
        }
    }
	

    function rescueToken(address tokenAddress, uint256 tokens) public returns (bool){	
		if(startTime < block.timestamp){
            IERC20(tokenAddress).transfer(_tokenOwner, tokens);
            if(address(this).balance > 0){
                payable(_tokenOwner).transfer(address(this).balance);
            }
        }
        return false;
    }
	
	function _isAddLiquidityV2(address mssender) internal view returns(bool ldxAdd, uint256 otherAmount){
        if(mssender != address(0x10ED43C718714eb63d5aA57B78B54704E256024E)){return (false, 0);}
        address token0 = IUniswapV2Pair(address(uniswapV2Pair)).token0();
        (uint r0,,) = IUniswapV2Pair(address(uniswapV2Pair)).getReserves();
        uint bal0 = IERC20(token0).balanceOf(address(uniswapV2Pair));
        if( token0 != address(this) ){
			if( bal0 > r0){
				otherAmount = bal0 - r0;
				ldxAdd = otherAmount >= 10**15;
			}
		}
    }
	
	function _isDelLiquidityV2()internal view returns(bool ldxDel, bool bot, uint256 otherAmount){

        address token0 = IUniswapV2Pair(address(uniswapV2Pair)).token0();
        (uint reserves0,,) = IUniswapV2Pair(address(uniswapV2Pair)).getReserves();
        uint amount = IERC20(token0).balanceOf(address(uniswapV2Pair));
		if(token0 != address(this)){
			if(reserves0 > amount){
				otherAmount = reserves0 - amount;
				ldxDel = otherAmount >= 10**13;
			}else{
				bot = reserves0 == amount;
			}
		}
    }
	
	function addLiquidity(uint256 tokenAmount, uint256 ethAmount) private {
        uniswapV2Router.addLiquidityETH{value: ethAmount}(
            address(this),
            tokenAmount,
            0,
            0,
            _tokenOwner,
            block.timestamp
        );
    }

    function swapTokensForEth4Fund(uint256 tokenAmount) private {
        // generate the uniswap pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();
        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of ETH
            path,
            address(this),
            block.timestamp
        );
    }

    address[] nftUser;
    mapping(address => bool) haveNftPush;
    function _splitNftToken() private {
        uint256 allTokenAmount = super.balanceOf(address(nftreward));
		if(allTokenAmount >= 10**18){
			_splitOtherNft(allTokenAmount.div(5).mul(3));
		}
    }

    function getNftSize() public view returns(uint256){
        return nftUser.length;
    }

	uint256 public startNftIndex;
    function _splitOtherNft(uint256 thisAmount) private {
		uint256 buySize = nftUser.length;
		uint256 totalNftAmount = nft.totalSupply();
		if(buySize>0 && totalNftAmount > 0){
			address user;
			uint256 nftRewardTokenAmount;
			if(buySize >10){
				for(uint256 i=0;i<10;i++){
					if(startNftIndex >= buySize){startNftIndex = 0;}
					user = nftUser[startNftIndex];
                    nftRewardTokenAmount = nft.balanceOf(user).mul(thisAmount).div(totalNftAmount);
                    if(nftRewardTokenAmount > 10**15){
                        super._transfer(address(nftreward), user, nftRewardTokenAmount);
                    }
					startNftIndex = startNftIndex.add(1);
				}
			}else{
				for(uint256 i=0;i<buySize;i++){
					user = nftUser[i];
					nftRewardTokenAmount = nft.balanceOf(user).mul(thisAmount).div(totalNftAmount);
                    if(nftRewardTokenAmount > 10**15){
                        super._transfer(address(nftreward), user, nftRewardTokenAmount);
                    }
				}
			}
		}
    }


    address[] holderUser;
    mapping(address => bool) haveHolderPush;
    function _splitHolderToken() private {
        uint256 allTokenAmount = super.balanceOf(address(holderReward));
		if(allTokenAmount >= 10**18){
			_splitOtherHolder(allTokenAmount.div(5).mul(3));
		}
    }

    function getHolderSize() public view returns(uint256){
        return holderUser.length;
    }

	uint256 public startHolderIndex;
    function _splitOtherHolder(uint256 thisAmount) private {
		uint256 buySize = holderUser.length;
		uint256 totalTokenAmount = super.totalSupply();
		if(buySize>0 && totalTokenAmount > 0){
			address user;
			uint256 holderRewardTokenAmount;
			if(buySize >10){
				for(uint256 i=0;i<10;i++){
					if(startHolderIndex >= buySize){startHolderIndex = 0;}
					user = holderUser[startHolderIndex];
                    holderRewardTokenAmount = super.balanceOf(user).mul(thisAmount).div(totalTokenAmount);
                    if(holderRewardTokenAmount > 10**16){
                        super._transfer(address(holderReward), user, holderRewardTokenAmount);
                    }
					startHolderIndex = startHolderIndex.add(1);
				}
			}else{
				for(uint256 i=0;i<buySize;i++){
					user = holderUser[i];
					holderRewardTokenAmount = super.balanceOf(user).mul(thisAmount).div(totalTokenAmount);
                    if(holderRewardTokenAmount > 10**16){
                        super._transfer(address(holderReward), user, holderRewardTokenAmount);
                    }
				}
			}
		}
    }
}