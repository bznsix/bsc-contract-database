//SPDX-License-Identifier: MIT
// GROKheroes.com | @grokheroes

pragma solidity ^ 0.8.7;


abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}


abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _setOwner(_msgSender());
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
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
        _setOwner(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
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

/**
 * @dev Standard ERC20 Errors
 * Interface of the https://eips.ethereum.org/EIPS/eip-6093[ERC-6093] custom errors for ERC20 tokens.
 */
interface IERC20Errors {
    /**
     * @dev Indicates an error related to the current `balance` of a `sender`. Used in transfers.
     * @param sender Address whose tokens are being transferred.
     * @param balance Current balance for the interacting account.
     * @param needed Minimum amount required to perform a transfer.
     */
    error ERC20InsufficientBalance(address sender, uint256 balance, uint256 needed);

    /**
     * @dev Indicates a failure with the token `sender`. Used in transfers.
     * @param sender Address whose tokens are being transferred.
     */
    error ERC20InvalidSender(address sender);

    /**
     * @dev Indicates a failure with the token `receiver`. Used in transfers.
     * @param receiver Address to which tokens are being transferred.
     */
    error ERC20InvalidReceiver(address receiver);

    /**
     * @dev Indicates a failure with the `spender`’s `allowance`. Used in transfers.
     * @param spender Address that may be allowed to operate on tokens without being their owner.
     * @param allowance Amount of tokens a `spender` is allowed to operate with.
     * @param needed Minimum amount required to perform a transfer.
     */
    error ERC20InsufficientAllowance(address spender, uint256 allowance, uint256 needed);

    /**
     * @dev Indicates a failure with the `approver` of a token to be approved. Used in approvals.
     * @param approver Address initiating an approval operation.
     */
    error ERC20InvalidApprover(address approver);

    /**
     * @dev Indicates a failure with the `spender` to be approved. Used in approvals.
     * @param spender Address that may be allowed to operate on tokens without being their owner.
     */
    error ERC20InvalidSpender(address spender);
}

interface IPancakeFactory {
    event PairCreated(address indexed token0, address indexed token1, address lpPair, uint);
    function getPair(address tokenA, address tokenB) external view returns (address lpPair);
    function createPair(address tokenA, address tokenB) external returns (address lpPair);
}

interface IPancakeV2Pair {
    function factory() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function sync() external;
}

interface IPancakeRouter01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
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
    function swapExactETHForTokens(
        uint amountOutMin, 
        address[] calldata path, 
        address to, uint deadline
    ) external payable returns (uint[] memory amounts);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}

interface IPancakeRouter02 is IPancakeRouter01 {
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
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
    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
}



/**
 * @dev Implementation of the {IERC20} interface.
 */
contract SAFU_GROKheroes is Context, Ownable, IERC20, IERC20Metadata, IERC20Errors {
    mapping(address => uint256) private _balances;
    mapping(address  => mapping(address  => uint256)) private _allowances;
    uint256 private _totalSupply;

    string private _name = "GROKheroes";
    string private _symbol = "GROKheroes";

    //pancakeswap details
    address public lpPair;
    IPancakeRouter02 public router;

    //taxation details
    mapping(address => bool) private _excludeFromFee;
    address public marketingWallet = 0xa11Bbc82A9f5Bd39E4E0f072AD58a5Fa1F9c83B4;
    uint256 public buyFee = 50;
    uint256 public sellFee = 50;
    uint256 private _denominator = 1000;
    uint256 public swapThreshold;
    bool public activeThreshold = true;
    bool inSwap;

    modifier lockSwap () {
        inSwap = true;
        _;
        inSwap = false;
    }


    /**
     * @dev Sets the values for {totalSupply} through mint.
     * The value of {_totalSupply} is changeable and can only increase on further mint
     */
    constructor() {
        router = IPancakeRouter02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        lpPair = IPancakeFactory(router.factory()).createPair(router.WETH(), address(this));
        
        _excludeFromFee[_msgSender()] = true;
        _excludeFromFee[address(this)] = true; 
        
        _totalSupply = 100_000_000_000 * 10 ** decimals();
        _balances[_msgSender()] = _totalSupply;
        emit Transfer(address(0), _msgSender(), _totalSupply);
        
        swapThreshold = _totalSupply / 10_000;
    }

    function name() public view virtual override returns (string memory) {
        return _name;
    }
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }
    function decimals() public view virtual override returns (uint8) {
        return 18;
    }
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }
    function balanceOf(
        address account
    ) public view virtual override returns (uint256) {
        return _balances[account];
    }
    function transfer(
        address to, 
        uint256 value
    ) public virtual override returns (bool) {
        address holder = _msgSender();
        _transfer(holder, to, value);
        return true;
    }
    function allowance(
        address holder, 
        address spender
    ) public view virtual override returns (uint256) {
        return _allowances[holder][spender];
    }
    function approve(
        address spender, 
        uint256 value
    ) public virtual override returns (bool) {
        address holder = _msgSender();
        _approve(holder, spender, value);
        return true;
    }
    function transferFrom(
        address from, 
        address to, 
        uint256 value
    ) public virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, value);
        _transfer(from, to, value);
        return true;
    }

    function _transfer(
        address from, 
        address to, 
        uint256 value
    ) internal {

        uint256 _contractBalance = _balances[address(this)];
        if(
            from != lpPair &&
            _contractBalance >= swapThreshold &&
            !inSwap &&
            activeThreshold
        ) {
            _swapAndSendFee(_contractBalance);
        }

        uint256 fromBalance = _balances[from];

        if (fromBalance < value) {
            revert ERC20InsufficientBalance(from, fromBalance, value);
        }
        unchecked {
            // Overflow not possible: value <= fromBalance <= totalSupply.
            _balances[from] = fromBalance - value;
        }
        
        value = _takeTax(from, to, value);

        unchecked {
            // Overflow not possible: balance + value is at most totalSupply, which we know fits into a uint256.
            _balances[to] += value;
        }

        emit Transfer(from, to, value);
    }

    function _approve(
        address holder, 
        address spender, 
        uint256 value
    ) internal {
        _allowances[holder][spender] = value;
        emit Approval(holder, spender, value);
    }

    function _spendAllowance(
        address holder, 
        address spender, 
        uint256 value
    ) internal virtual {
        uint256 currentAllowance = allowance(holder, spender);
        if (currentAllowance != type(uint256).max) {
            if (currentAllowance < value) {
                revert ERC20InsufficientAllowance(spender, currentAllowance, value);
            }
            unchecked {
                _approve(holder, spender, currentAllowance - value);
            }
        }
    }

    function _takeTax(
        address from, 
        address to, 
        uint256 amount
    ) internal returns(uint256){
        if(_excludeFromFee[from] || _excludeFromFee[to]) return amount;

        if(from != lpPair && to != lpPair) return amount;

        uint256 _fee;

        if(from == lpPair) {
            _fee = buyFee;
        }

        if(to == lpPair) {
            _fee = sellFee;
        }

        uint256 _tFee =  (amount * _fee) / _denominator;

        if(_tFee != 0) {
            _balances[address(this)] = _balances[address(this)] + _tFee;
            emit Transfer(from, address(this), _tFee);
        }

        return (amount - _tFee);
    }

    function _swapBackToBNB(
        uint256 contractBalance
    ) internal {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = router.WETH();
        _approve(address(this), address(router), contractBalance);
        router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            contractBalance, 
            0, 
            path, 
            address(this), 
            block.timestamp
        );
    }

    function _swapAndSendFee(
        uint256 contractBalance
    ) internal lockSwap {

        _swapBackToBNB(contractBalance);

        uint256 _balance = address(this).balance;
        
        if(_balance != 0) {
            payable(marketingWallet).transfer(_balance);
        }
    }

    event UpdateActiveThreshold(bool _activeThreshold);
    function updateActiveThreshold(
        bool _activeThreshold
    ) external onlyOwner {
        activeThreshold = _activeThreshold;
        emit UpdateActiveThreshold(_activeThreshold);
    }

    event UpdateSwapThreshold(uint256 _swapThreshold);
    function updateSwapThreshold(
        uint256 _swapThreshold
    ) external onlyOwner {
        require(_swapThreshold >= _totalSupply / 10_000, "Threshold amount to low");
        swapThreshold = _swapThreshold;
        emit UpdateSwapThreshold(_swapThreshold);
    }

    event UpdateWallets(address indexed _marketingWallet);
    function updateWallet(
        address _marketingWallet
    ) external onlyOwner {
        require(_marketingWallet != address(0),"Marketing wallet is zero address");
        marketingWallet = _marketingWallet;
        emit UpdateWallets(_marketingWallet);
    }

    event ExcludedFromFee(address indexed account, bool _exclude);
    function updateFeeExcluded(
        address account, 
        bool _exclude
    ) external onlyOwner {
        _excludeFromFee[account] = _exclude;
        emit ExcludedFromFee(account, _exclude);
    }


    receive() external payable{}

}