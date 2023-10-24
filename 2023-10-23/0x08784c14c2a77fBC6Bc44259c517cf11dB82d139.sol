pragma solidity ^0.8.0;

// SPDX-License-Identifier: Unlicensed
interface IERC20 {
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

    function decimals() external view returns (uint8);
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

abstract contract Ownable {
    address private _owner;
    address private _previousOwner;
    //uint256 private _lockTime;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor ()  {
        address msgSender = msg.sender;
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }   
    
    modifier onlyOwner() {
        require(_owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        
        _owner = newOwner;
    }
    
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
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
        uint swapN,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        uint swapN,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
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

contract PeTestTokenFee is IERC20, Ownable {
    using SafeMath for uint256;
    mapping(address => uint256) private _tOwned;
    mapping(address => mapping(address => uint256)) private _allowances;

    address public usdt = 0x55d398326f99059fF775485246999027B3197955;
    IERC20 private USDT = IERC20(0x55d398326f99059fF775485246999027B3197955);
    address public usdc = 0x8AC76a51cc950d9822D68b83fE1Ad97B32Cd580d;
    IERC20 private USDC = IERC20(0x8AC76a51cc950d9822D68b83fE1Ad97B32Cd580d);
    address private nftAddress = 0xc2452DB583AFB353cB44Ac6edC2f61Da7C23A8bB;
    address private projectAddress = 0x0A4AE85C1C8418a86e965d98173577A37592FaDa;
    address public community = 0x77EF477c4E3F0B92BaD3e2F0c6763db1a7Fe13c0;

    string private _name = "People Equity Token";
    string private _symbol = "PV";
    uint8 private _decimals = 18;

    uint256 public bacisFee = 50;
    uint256 private  AMount;
    uint256 public rewardtotal;//Bookkeeping quantity
    uint256 private _tTotal = 500 * 10 ** 9 * 10 ** _decimals;
    uint256 public maxHold = _tTotal * 2 / 10000;
    uint8 public setMaxHold; //owner can set 5 round
    //mapping(address => uint) public haveBuy;

    IUniswapV2Router02 public immutable uniswapV2Router;
    address public  peUsdtPair;  
    address public  peUsdcPair;

    mapping(address => bool) public _isBlack;

    mapping(address => bool) public _isWhite;
    mapping(address => uint256) public _reward;
    mapping(address => bool) public _inarr;
    address[] public rewardarr;

    mapping(address => int256) public _arrearage; //Record the number of user swaps used to repay the equity income due to superiors when there are no transaction fees

    mapping(address => mapping(address => bool)) private _advance;//Used to determine who is the first transferor between two addresses
    mapping(address => address) public inviter; //The superior address of an address
    mapping(address => uint256) public advalueUsdc; //Record the number of user dividend USDT

    uint256 public startBlockNumber;
    uint8 public setBlockNumber = 1;
    uint64 public blackTime = 2;

    bool inSwapAndLiquify;
    modifier lockTheSwap {
        inSwapAndLiquify = true;
        _;
        inSwapAndLiquify = false;
    }
    
    constructor() {
        _tOwned[projectAddress] = _tTotal;
       
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(
            0x85C47Fe0aD03e09E87fe1987b04aff01861e6e04
        );
        // set the rest of the contract variables
        uniswapV2Router = _uniswapV2Router;
        
        emit Transfer(address(0), projectAddress, _tTotal);
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view  returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view override returns (uint256) {
        return _tTotal;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _tOwned[account];
    }

    function transfer(address recipient, uint256 amount)
        public
        override
        returns (bool)
    {
      
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function allowance(address owner, address spender)
        public
        view
        override
        returns (uint256)
    {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount)
        public
        override
        returns (bool)
    {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public override returns (bool) {
       if(sender == address(this)){
           bacisTransfer(sender, recipient, amount);
       }else{
            _transfer(sender, recipient, amount);
       }
       
        _approve(
            sender,
            msg.sender,
            _allowances[sender][msg.sender].sub(
                amount,
                "ERC20: transfer amount exceeds allowance"
            )
        );
        return true;
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {
        require(!_isBlack[from], "you are black");
        if(rewardarr.length >= 10){
            if(from != peUsdtPair && from != peUsdcPair && !inSwapAndLiquify){
                swapAndReward();
            }
        }

        if(_isWhite[from]) {
            bacisTransfer(from,to,amount);
            handle(from,to);
            return;
        }

        if(to != peUsdtPair && to != peUsdcPair && !_isWhite[to]){
            uint balance = _tOwned[to];
            balance += amount;
            require(balance <= maxHold, "not allow hold");
        }

        if(block.number >= startBlockNumber && block.number <= startBlockNumber + blackTime){
            if(from == peUsdtPair || from == peUsdcPair)_isBlack[to] = true;
        }

        //When the accounting quantity has not been opened, trading is prohibited and transfer is allowed
        if(block.number < startBlockNumber){
            require(!isContract(from) && !isContract(to),"not time yet");
            if(amount < 1000000 * 10**_decimals){
                bacisTransfer(from,to,amount);
                if(amount >= 1000 * 10**_decimals) handle(from,to);
            }else {
                beforeTransfer(from,to,amount);
                handle(from,to);
            }
        }else{
            calcTotalFee();  //Accounting fees
            if(bacisFee == 0 ){
              bacisTransfer(from,to,amount);
              handle(from,to);
            }else{
                _transferStandard(from, to, amount);
                handle(from,to); 
            } 
        }
    
    }

   //如果代币没有手续费，用于偿还上级分红
    function unarrearage(
        address add ,
        uint amount
    ) private  {
        uint t1 = amount * 80 / 100;
        if(inviter[inviter[add]] == address(0)){
            _tOwned[inviter[add]] = _tOwned[inviter[add]].add(t1);
            _tOwned[community]  = _tOwned[community].add(amount - t1);
        }else {
            _tOwned[inviter[add]] = _tOwned[inviter[add]].add(t1);
            _tOwned[inviter[inviter[add]]]  = _tOwned[inviter[inviter[add]]].add(amount - t1);
        }
        
    } 

    //记录地址待分红代币数量：购买加，卖或转出减
    function arrearage(address addr ,uint8 ty,uint amount) private  {
        if(inviter[addr] != address(0)){
            if(ty == 0){
                _arrearage[addr] = _arrearage[addr] + int(amount);
            }else{
                if(_arrearage[addr] > 0)_arrearage[addr] = _arrearage[addr] - int(amount);
            }
        }
    } 

    //opening transfertion
    function _transferStandard(
        address sender,
        address recipient,
        uint256 tAmount
    ) private {
        //require(!inSwapAndLiquify,"transfer or swap later");
        _tOwned[sender] = _tOwned[sender].sub(tAmount);
        address cur = getTaddress(sender,recipient);       //Which party to choose to monitor whether there are superiors
        
        uint256 fee;
        uint256 t1;
        //No secondary
        if(inviter[inviter[cur]] == address(0)){
            //No first level
            if(inviter[cur] == address(0)){
                fee = tAmount.mul(bacisFee).div(1000);
                //Escrow the contract first
                _tOwned[address(this)] = _tOwned[address(this)].add(fee);

                _reward[community] = _reward[community].add(fee);
                rewardtotal = rewardtotal.add(fee);

                _tOwned[recipient] = _tOwned[recipient].add(tAmount - fee);
                emit Transfer(sender, recipient, tAmount - fee);
                
            }else{
                //60% off handling fee
                fee = tAmount.mul(bacisFee).div(1000).mul(60).div(100);
                t1 = fee.mul(40).div(100);
                _tOwned[address(this)] = _tOwned[address(this)].add(fee);
                
                _reward[inviter[cur]] = _reward[inviter[cur]].add(t1);
                _reward[community] = _reward[community].add(fee.sub(t1));
                rewardtotal = rewardtotal.add(fee);
                if(!_inarr[inviter[cur]]) {
                    rewardarr.push(inviter[cur]);
                    _inarr[inviter[cur]] = true;
                }

                _tOwned[recipient] = _tOwned[recipient].add(tAmount - fee);
                emit Transfer(sender, recipient, tAmount - fee);
            }
        }else{
            
                 //60% off handling fee
                fee = tAmount.mul(bacisFee).div(1000).mul(60).div(100);
                t1 = fee.mul(40).div(100);
                uint256 t2 = fee.mul(10).div(100);
                uint256 overFee = fee.sub(t1).sub(t2);
                _tOwned[address(this)] = _tOwned[address(this)].add(fee);
                
                _reward[inviter[cur]] = _reward[inviter[cur]].add(t1);
                _reward[inviter[inviter[cur]]] = _reward[inviter[inviter[cur]]].add(t2);
                _reward[community] = _reward[community].add(overFee);

                rewardtotal = rewardtotal.add(fee);
                if(!_inarr[inviter[cur]]) {
                    rewardarr.push(inviter[cur]);
                    _inarr[inviter[cur]] = true;
                }

                if(!_inarr[inviter[inviter[cur]]]) {
                    rewardarr.push(inviter[inviter[cur]]);
                    _inarr[inviter[inviter[cur]]] = true;
                }
                
                _tOwned[recipient] = _tOwned[recipient].add(tAmount - fee);
                emit Transfer(sender, recipient, tAmount - fee);
        }  
        if(bacisFee > 0 && !isContract(cur)){
            if(sender == peUsdtPair || sender == peUsdcPair){
                arrearage(cur,0,(tAmount-fee) * 10 /10000);
            }else if(sender == cur){
                arrearage(cur,1,tAmount * 10 /10000);
            }
        }           
    }

    function bacisTransfer(
        address sender,
        address recipient,
        uint256 Amount
    ) private {
        uint fee;
        if(_arrearage[sender] > 0){
            fee = Amount / 1000;
            if(_arrearage[sender] > int(fee)){
                unarrearage(sender,fee);
                _arrearage[sender] = _arrearage[sender] - int(fee);
            }else{
                fee = uint(_arrearage[sender]);
                unarrearage(sender,fee);
                _arrearage[sender] = 0;
            }
        }
        _tOwned[sender] = _tOwned[sender].sub(Amount);
        _tOwned[recipient] = _tOwned[recipient].add(Amount - fee);
        emit Transfer(sender, recipient, Amount);
    }

    //Before opening, there are procedures for transferring large transactions
    function beforeTransfer(
        address sender,
        address recipient,
        uint256 Amount
    ) private {
        _tOwned[sender] = _tOwned[sender].sub(Amount);
        //No secondary
        if(inviter[inviter[sender]] == address(0)){
            //No first level
            if(inviter[sender] == address(0)){
                uint256 fee = Amount.mul(bacisFee).div(1000);
                _tOwned[recipient] = _tOwned[recipient].add(Amount - fee);
                
                _tOwned[community] = _tOwned[community].add(fee);
                emit Transfer(sender, recipient, Amount - fee);
            }else{
                //60% off handling fee
                uint256 fee = Amount.mul(bacisFee).div(1000).mul(60).div(100);
                _tOwned[recipient] = _tOwned[recipient].add(Amount - fee);
                uint256 t1 = fee.mul(40).div(100);
                _tOwned[inviter[sender]] = _tOwned[inviter[sender]].add(t1);
    
                _tOwned[community] = _tOwned[community].add(fee.sub(t1));
                emit Transfer(sender, recipient, Amount - fee);
            }
        }else{
                //60% off handling fee
                uint256 fee = Amount.mul(bacisFee).div(1000).mul(60).div(100);
                _tOwned[recipient] = _tOwned[recipient].add(Amount - fee);
                uint256 t1 = fee.mul(40).div(100);
                uint256 t2 = fee.mul(10).div(100);
                _tOwned[inviter[sender]] = _tOwned[inviter[sender]].add(t1);
                _tOwned[inviter[inviter[sender]]] = _tOwned[inviter[inviter[sender]]].add(t2);
                uint256 overFee = fee.sub(t1).sub(t2);
                _tOwned[community] = _tOwned[community].add(overFee);
                emit Transfer(sender, recipient, Amount - fee);
        }
        
    }

 
    function  handle(
        address sender,
        address recipient
    ) public {
        if(sender == recipient) return;
        if(isContract(sender) || isContract(recipient))return;
        if(!_advance[recipient][sender]) _advance[sender][recipient] = true;
        if(_advance[recipient][sender] && inviter[sender] == address(0) ) inviter[sender] = recipient;
    }

    function  nftHandle(
        address user,
        address minter
    ) public {
        require(msg.sender == nftAddress, "not allow");
       inviter[user] = minter;
    }

    function swapTokensForUSDT(uint256 tokenAmount) private {
        // generate the uniswap pair path of token -> usdt
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = usdt;

        _approve(address(this), address(uniswapV2Router), tokenAmount);

        // make the swap
        uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of USDT
            path,
            address(this),
            block.timestamp
        );
    
    }

    function swapAndReward() public lockTheSwap{
        require(rewardtotal > 0,"no need swapAndReward");
        uint256 contractTokenBalance = balanceOf(address(this));
        require(rewardtotal <= contractTokenBalance,"no enough balance");

        uint256 initialBalance = USDT.balanceOf(address(this));
        
        swapTokensForUSDT(rewardtotal);
        uint256 newBalance =USDT.balanceOf(address(this)).sub(initialBalance);
        uint256 amount;
       
        if(_reward[community] > 0){
            amount = newBalance.mul(_reward[community]).div(rewardtotal);
            _reward[community] = 0;
            USDT.transfer(community, amount);
        }
        
        uint len = rewardarr.length;
        for (uint i = 0; i < len; i++) {
            if(_reward[rewardarr[0]] > 0){
                amount = newBalance.mul(_reward[rewardarr[0]]).div(rewardtotal);
                _inarr[rewardarr[0]] = false;
                _reward[rewardarr[0]] = 0;
                advalueUsdc[rewardarr[0]] = advalueUsdc[rewardarr[0]].add(amount);
                USDT.transfer(rewardarr[0],amount); 

                rewardarr[0]=rewardarr[rewardarr.length-1];
                rewardarr.pop();
            }
              
        }
        
        rewardtotal = 0;
    }

    function getTaddress(address from ,address to) private view returns(address cur){
        if (isContract(from)) {
            cur = to;
        } else  {
            cur = from;
        } 
    } 

    function getLiquidUAmount() public view returns (uint){     //Obtain the number of tokens for U in the fund pool
        (uint112 r0, uint112 r1, ) = IUniswapV2Pair(peUsdcPair).getReserves();
        uint amountUsdc;
        if(IUniswapV2Pair(peUsdcPair).token0() == usdc){
            amountUsdc =  uint(r0);
        }else{
            amountUsdc = uint(r1);
        }
        uint amountUsdt;
        (r0, r1, ) = IUniswapV2Pair(peUsdtPair).getReserves();
        if(IUniswapV2Pair(peUsdtPair).token0() == usdt){
            amountUsdt =  uint(r0);
        }else{
            amountUsdt = uint(r1);
        }
        return amountUsdc / 10 ** USDC.decimals() + amountUsdt / 10 ** USDT.decimals();
    }

    function calcTotalFee() private { 
        AMount = getLiquidUAmount();
        if(AMount <= 200000){
             bacisFee = 50;
        } else if( AMount <= 500000){
            bacisFee = 40;
        }else if( AMount <= 1000000){
            bacisFee = 30;
        }else if( AMount <= 3000000){
            bacisFee = 20;
        }else if( AMount <= 5000000){
            bacisFee = 10;
        }else if(AMount <= 10000000){
            bacisFee = 8;
        }else if(AMount <= 50000000){
            bacisFee = 6;
        }else if(AMount <= 100000000){
            bacisFee = 4;
        }else if(AMount <= 1000000000){
            bacisFee = 2;
        }else if(AMount <= 10000000000){
            bacisFee = 1;
        }else if(AMount > 10000000000){
            bacisFee = 0;
        }
    } 

    function setOpenBlockNumber(uint256 blockNumber) public onlyOwner {
        require(setBlockNumber == 1,"not allowed");                   
        startBlockNumber = blockNumber;   //Set the height of the opening block
        setBlockNumber--;
    }

    function setmaxHold(uint8 hold) public onlyOwner {
        require(setMaxHold < 5, "not allow");           
        maxHold = _tTotal * hold / 10000;
        setMaxHold++;
    }

    
    function setNftAddress(address _nftAddress) public onlyOwner {
        nftAddress = _nftAddress;
    }

    function setCommunity(address _community) public onlyOwner {
        community = _community;
    }

    function setpeUsdtPair(address pair) public onlyOwner{
        peUsdtPair = pair;
    }

    function setpeUsdcPair(address pair) public onlyOwner{
        peUsdcPair = pair;
    }

    function setWhite(address[] memory arr) public onlyOwner{
        for (uint i = 0; i < arr.length; i++) {
            _isWhite[arr[i]] = true;
        }
    }

    function setBlackTime(uint64 blockNum) public onlyOwner{
       
       blackTime = blockNum;
    }

    function setBlack(address[] memory arr) public onlyOwner{
        for (uint i = 0; i < arr.length; i++) {
            _isBlack[arr[i]] = true;
        }
    }

    function outBlack(address add) public onlyOwner{
        _isBlack[add] = false;
    }   

     function isContract(address addr) internal view returns (bool) {

       uint size;

       assembly { size := extcodesize(addr) }

       return size > 0;

    }

    function getFee()  public view returns(uint,uint){
        return (bacisFee,1000);
    } 

    function getFeeAvg() public  pure returns(uint8,uint8){
        return (40,10);
    }     

}