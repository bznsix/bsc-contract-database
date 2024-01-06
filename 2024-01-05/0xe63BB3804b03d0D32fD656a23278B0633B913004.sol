// SPDX-License-Identifier: Unlicensed
// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.6;

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
        return msg.data;
    }

    function _contextSuffixLength() internal view virtual returns (uint256) {
        return 0;
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

    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a >= b ? a : b;
    }

    /**
     * @dev Returns the smallest of two numbers.
     */
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }
}

// File: contracts\interfaces\IPancakeRouter01.sol
interface IPancakeRouter01 {
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

// File: contracts\interfaces\IPancakeRouter02.sol
interface IPancakeRouter02 is IPancakeRouter01 {
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

interface IPancakeFactory {
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

// File: contracts\interfaces\IPancakePair.sol
// pragma solidity >=0.5.0;
interface IPancakePair {
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

contract KPCToken is Context, IERC20, IERC20Metadata, Ownable {
    using SafeMath for uint256;
    uint256 private constant MAX = type(uint256).max;

    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;
    string private _name;
    string private _symbol;
    uint8 private _decimals;
    
    IERC20 public USDT;
    IPancakeRouter02 public immutable pancakeRouter;
    IPancakePair public pancakePair;
    address pancakePairAddress;

    // 10%
    uint256 public sellFeeRate = 1000;
    
    uint256 deno = 10000;
    address _tokenManager;
    address _feeAddr; 
     
    mapping(address => bool) private _whiteList;
    mapping(address => uint256) private _sellFee;

    constructor(address _uniswapV2RouterAddress, address usdtAddress, address feeAddr) payable {
        _name = "KPC Token";
        _symbol = "KPC";
        _decimals = 18;
        _totalSupply = 100000000 * (10 ** uint256(_decimals));   // 100,000,000;      

        // mint totalSupply
        _balances[_msgSender()] = _totalSupply;
        emit Transfer(address(0), _msgSender(), _totalSupply);

        _tokenManager = _msgSender();
        _feeAddr = feeAddr;
        _whiteList[_msgSender()] = true;
        _whiteList[address(this)] = true;
        _whiteList[_feeAddr] = true;
        USDT = IERC20(usdtAddress);

        IPancakeRouter02 _uniswapV2Router = IPancakeRouter02(_uniswapV2RouterAddress);
        pancakePairAddress = IPancakeFactory(_uniswapV2Router.factory()).createPair(address(this), address(USDT));
        pancakePair = IPancakePair(pancakePairAddress);
        pancakeRouter = _uniswapV2Router;

        _approve(address(this), address(_uniswapV2Router), MAX);
        _approve(_msgSender(), address(this), MAX);
        USDT.approve(address(_uniswapV2Router), MAX); 
        USDT.approve(address(this), MAX); 
    }

    //  
    receive() external payable {}

    modifier onlyManager() {
        require(_tokenManager == _msgSender(), "Ownable: caller is not the manager");
        _;
    }
    //  
    function setTokenManager(address newManager) public onlyManager {
        _tokenManager = newManager;   
    }

    // 
    function setFeeAddr(address newAddr) public onlyManager {
        _feeAddr = newAddr;   
    }

    //  
    function setwlist(address _account, bool _value) public onlyManager {
        _whiteList[_account] = _value;
    }

    //  
    // 
    function usdtAmountToAdd(
        uint256 tokenAAmount, 
        uint256 
    ) public view returns (uint256) {
        uint112 reserve0;
        uint112 reserve1;
        uint32 blockTime;
        (reserve0, reserve1, blockTime) = pancakePair.getReserves();
        uint256 usdtAmount = pancakeRouter.getAmountIn(tokenAAmount, reserve0, reserve1);
      
        return usdtAmount;
    }

    
    function kpcAmountToAdd(
        uint256 tokenBAmount, 
        uint256  // slippageTolerance
    ) public view returns (uint256){
        uint112 reserve0;
        uint112 reserve1;
        uint32 blockTime;
        (reserve0, reserve1, blockTime) = pancakePair.getReserves();
        uint256 kpcAmount = pancakeRouter.getAmountIn(tokenBAmount, reserve1, reserve0);
        return kpcAmount;
    }
    
   
    event AddLiquidity(address indexed account, uint256 _usdtAmount);
    function addLiquidity(
        uint256 tokenAmount,    
        uint256 usdtAmount      
    ) public {
        address sender = _msgSender();
       
        uint256 amountOut;
        uint256 amountOutWithFee;
        uint256 sellFeeUSDT = 0;
        if(_balances[pancakePairAddress] == 0 && USDT.balanceOf(pancakePairAddress) == 0){
            sellFeeUSDT = 0;
        }else{
            (amountOut, amountOutWithFee) = getAmountUsdtOut(tokenAmount);           
            sellFeeUSDT = amountOut - amountOutWithFee;
        }        
        // USDT.transferFrom(sender, address(this), sellFeeUSDT);
        _sellFee[sender] = sellFeeUSDT;

        require(USDT.allowance(sender, address(this)) >= usdtAmount+sellFeeUSDT, "Liquidity: NOT enough allowance of USDT");
        USDT.transferFrom(_msgSender(), address(this), usdtAmount+sellFeeUSDT);    

        require(_balances[sender] >= tokenAmount,"Liquidity: NOT enough balance of KPC");
        _approve(_msgSender(), address(this), MAX);
        _balances[sender] = _balances[sender] - tokenAmount;
        _balances[address(this)] = _balances[address(this)] + tokenAmount; 
            
        _approve(address(this), address(pancakeRouter), MAX);
        USDT.approve(address(pancakeRouter), MAX);
       
        pancakeRouter.addLiquidity(
            address(this),
            address(USDT),
            tokenAmount,
            usdtAmount,
            0,
            0,
            sender,
            block.timestamp
        );
        emit AddLiquidity(sender,usdtAmount);

             
        uint256 feeAmount = sellFeeUSDT < _sellFee[sender]? sellFeeUSDT : _sellFee[sender];
        USDT.transferFrom(_feeAddr, sender, feeAmount);
        _sellFee[sender] = 0 ;
    }

    
    event RemoveLiquidity(address indexed account, uint256 _liquidity);
    function removeLiquidity(uint256 liquidity) public {
        address sender = _msgSender();
        
        require(pancakePair.allowance(sender, address(this)) >= liquidity, "Liquidity: NOT enough allowance of LP");
        pancakePair.transferFrom(sender, address(this), liquidity);

       
        pancakePair.approve(address(pancakeRouter), MAX);

        
        bool _tempWLState = _whiteList[sender];
        _whiteList[sender] = true; // 放行

        pancakeRouter.removeLiquidity(
            address(this),
            address(USDT),
            liquidity,
            0,
            0,
            sender,
            block.timestamp
        );
       
        _whiteList[sender] = _tempWLState;
        emit RemoveLiquidity(sender, liquidity);        
    }

    
    function calculateRemoveLiquidity(uint256 liquidity) public view returns (uint256 kpcAmount, uint256 usdtAmount) {
        uint256 reserveKpc;
        uint256 reserveUsdt;
        uint256 lpTotal;
        (reserveKpc,reserveUsdt,lpTotal) = getPoolReserve();
        uint256 lpPercent = liquidity * deno / lpTotal;
        kpcAmount = reserveKpc * lpPercent / deno;
        usdtAmount = reserveUsdt * lpPercent / deno;
        return(kpcAmount, usdtAmount);
    }
    
    
    event BuyKPC(address indexed account, uint256 _sellAmount);
    function buyKpc(uint256 _usdtAmount) public {
        address sender = _msgSender();
        require(_whiteList[sender] == true, "BUY KPC: address NOT int the white list!");

        
        require(USDT.allowance(sender, address(this)) >= _usdtAmount, "BUY: NOT enough allowance of USDT");
        USDT.transferFrom(sender, address(this), _usdtAmount);

        USDT.approve(address(pancakeRouter), MAX);
        address[] memory path = new address[](2);
        path[0] = address(USDT);
        path[1] = address(this);
        pancakeRouter.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            _usdtAmount,
            0, // accept any amount
            path,
            sender,
            block.timestamp
        );
        emit BuyKPC(sender, _usdtAmount);
    }

   
    event SellKPC(
        address indexed account,
        uint256 _sellAmount,
        uint256 _marketingAmount
    ); 
    event SellFee(address from, address to, uint256 feeOfUsdt); 
    function sellKpc(uint256 _kpcAmount) public {
        address sender = _msgSender();
        require(_balances[sender] >= _kpcAmount,"Liquidity: NOT enough balance of KPC");
        _approve(_msgSender(), address(this), MAX);
        _balances[sender] = _balances[sender] - _kpcAmount;
        _balances[address(this)] = _balances[address(this)] + _kpcAmount; 
        
        _approve(address(this), address(pancakeRouter), MAX);       
        // 
        uint256 amountOut;
        uint256 amountOutWithFee;
        uint256 sellFeeUSDT = 0;
        if(_balances[pancakePairAddress] == 0 && USDT.balanceOf(pancakePairAddress) == 0){
            sellFeeUSDT = 0;
        }else{
            (amountOut, amountOutWithFee) = getAmountUsdtOut(_kpcAmount);           
            sellFeeUSDT = amountOut - amountOutWithFee;
        }

        require(USDT.allowance(sender, address(this)) >= sellFeeUSDT, "Liquidity: NOT enough allowance of USDT");
        USDT.transferFrom(sender, address(this), sellFeeUSDT);  

        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = address(USDT);
        pancakeRouter.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            _kpcAmount,
            0, // accept any amount
            path,
            sender,
            block.timestamp
        );

        
        uint256 _marketingAmount = amountOutWithFee;
        
        emit SellKPC(_msgSender(), _kpcAmount, _marketingAmount);
        emit SellFee(sender, _feeAddr, sellFeeUSDT);
    }

   
    function getAmountUsdtOut(uint256 amountIn) public view returns (uint256, uint256) {
        uint112 reserve0;
        uint112 reserve1;
        uint32 blockTime;
        (reserve0, reserve1, blockTime) = pancakePair.getReserves();
      
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = address(USDT);
        uint256 amountOut = pancakeRouter.getAmountsOut(amountIn,path)[1];
     
        uint256 sellFee = amountOut * sellFeeRate / deno;
        return (amountOut, amountOut - sellFee);
    }

  
    function getAmountKpcOut(uint256 amountIn) public view returns (uint256) {
        uint112 reserve0;
        uint112 reserve1;
        uint32 blockTime;
        (reserve0, reserve1, blockTime) = pancakePair.getReserves();
        
        address[] memory path = new address[](2);
        path[0] = address(USDT);
        path[1] = address(this);
        uint256 amountOut = pancakeRouter.getAmountsOut(amountIn,path)[1];
        return amountOut;
    }

   
    function getPoolReserve() public view returns(uint256,uint256,uint256) {
        uint256 reserveKpc = _balances[pancakePairAddress];
        uint256 reserveUsdt = USDT.balanceOf(pancakePairAddress);        
        uint256 totalLp = pancakePair.totalSupply();
        return (reserveKpc, reserveUsdt, totalLp);
    }

    
    function kpcPriceOfUsdt() public view returns(uint256) {
        uint256 currentPrice;
        if (_balances[pancakePairAddress] == 0) {
            currentPrice = 0;
        } else {
           
            currentPrice = USDT.balanceOf(pancakePairAddress).mul(10 ** 18).div(_balances[pancakePairAddress]);
        }
        return currentPrice;
    }

    
    function getLiquidityBalance(address account)public view returns (uint256){
        uint256 lpBalance = pancakePair.balanceOf(account);
        return lpBalance;
    }

    
    function getMultipleLiquidityBalances(
        address[] memory accounts
    ) public view returns (uint256[] memory) {
        uint256[] memory lpBalances;
        for(uint256 i = 0; i<= accounts.length; i++){
            lpBalances[i] = pancakePair.balanceOf(accounts[i]);
        } 
        return lpBalances;
    }

    
    function getOneLiquidityPercentage(address _user) public view returns (uint256) {
       
        uint256 lpBalance = pancakePair.balanceOf(_user);
        uint256 lpTotal = pancakePair.totalSupply();
        uint256 lpPercent = lpBalance * (10 ** 18) / lpTotal;
        
        return lpPercent;
    }

   
    function getMultLiquidityPercentages(
        address[] memory _users
    ) public view returns (uint256[] memory) {
        uint256[] memory lpPercentages;
        uint256 lpBalance = 0;
        uint256 lpTotal = pancakePair.totalSupply();
         for(uint256 i = 0; i<= _users.length; i++){
            lpBalance = pancakePair.balanceOf(_users[i]);
            lpPercentages[i] = lpBalance * (10 ** 18) / lpTotal;
        } 
        return lpPercentages;
    }

   
   function withdrawToken(
        address _tokenAddress, 
        address _to,
        uint256 amount
    ) public onlyManager {
        IERC20 token = IERC20(_tokenAddress);
        token.transfer(_to, amount);
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view override returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view override returns (string memory) {
        return _symbol;
    }

    function decimals() public view override returns (uint8) {
        return _decimals;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - the caller must have a balance of at least `value`.
     */
    function transfer(address to, uint256 value) public override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, value);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * NOTE: If `value` is the maximum `uint256`, the allowance is not updated on
     * `transferFrom`. This is semantically equivalent to an infinite approval.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 value) public override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, value);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the ERC. See the note at the beginning of {ERC20}.
     *
     * NOTE: Does not update the allowance if the current allowance
     * is the maximum `uint256`.
     *
     * Requirements:
     *
     * - `from` and `to` cannot be the zero address.
     * - `from` must have a balance of at least `value`.
     * - the caller must have allowance for ``from``'s tokens of at least
     * `value`.
     */
    function transferFrom(address from, address to, uint256 value) public override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, value);
        _transfer(from, to, value);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, allowance(owner, spender) + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        address owner = _msgSender();
        uint256 currentAllowance = allowance(owner, spender);
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }


    function _transfer(address from, address to, uint256 amount) internal {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        require(_balances[from] >= amount, "ERC20: transfer amount exceeds balance");            

       
        if (from == pancakePairAddress) {
            // 
            require(_whiteList[to] == true,"BUY: address NOT in the White list.");
        } else if (to == pancakePairAddress) {
            // 
            
            uint256 amountOut;
            uint256 amountOutWithFee;
            uint256 sellFeeUSDT = 0;
            if(_balances[pancakePairAddress] == 0 && USDT.balanceOf(pancakePairAddress) == 0){
                sellFeeUSDT = 0;
            } else {
                (amountOut, amountOutWithFee) = getAmountUsdtOut(amount);           
                sellFeeUSDT = amountOut - amountOutWithFee;
            }  

            uint256 _fee = sellFeeUSDT;
            if (_sellFee[from] > 0){
                _fee = _sellFee[from];
            }
           
            require(USDT.balanceOf(from) >= _fee, "INSUFFICICENT balance for fee.");
            require(USDT.allowance(from, address(this)) >= _fee, "INSUFFICICENT allowance for fee."); 
            
            require(USDT.transferFrom(from, _feeAddr, _fee),"transferFrom(from,_feeAddr,_fee) error");
        } else {
            // transfer
        }

        // sub
        _balances[from] = _balances[from].sub(amount);       
        // add
        _balances[to] = _balances[to].add(amount); 
        emit Transfer(from, to, amount);
    }
    
    function _approve(address owner,address spender,uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _spendAllowance(address owner,address spender,uint256 amount) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }
}