/**
 *Submitted for verification at testnet.bscscan.com on 2023-11-16
*/

// SPDX-License-Identifier: MIT

/**
 * The Free and best Token-Factory.NFT-Factory
 * WebSite: https://ggg.dog
 * English Telegram group:https://t.me/GGGDOG_EN
 * Twitter:https://twitter.com/GGGTokenFactory
*/

pragma solidity =0.8.6;

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

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

abstract contract Ownable {
    address private _owner;
    address private _previousOwner;
    uint256 private _lockTime;


    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor ()  {
        address msgSender =  msg.sender;
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
    
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

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
    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);
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
    ) external returns (uint256 amountA, uint256 amountB, uint256 liquidity);

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
        returns (uint256 amountToken, uint256 amountETH, uint256 liquidity);

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

    function getAmountsOut(
        uint256 amountIn,
        address[] calldata path
    ) external view returns (uint256[] memory amounts);

    function getAmountsIn(
        uint256 amountOut,
        address[] calldata path
    ) external view returns (uint256[] memory amounts);
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




interface IUniswapV2Pair {

    function getReserves()
        external
        view
        returns (
            uint112 reserve0,
            uint112 reserve1,
            uint32 blockTimestampLast
        );



    function sync() external;

}



contract  GGGTOKEN is IERC20, Ownable {
    using SafeMath for uint256;

    mapping(address => uint256) private _tOwned;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) private _isExcludedFromFee;
    mapping(address => bool) private _updated;
    string public _name ;
    string public _symbol ;
    uint8 public _decimals ;
    uint256 public _buyMarketingFee ;
    uint256 public _buyBurnFee ;
    uint256 public _buyLiquidityFee ;
    uint256 public _sellMarketingFee ;
    uint256 public _sellBurnFee ;
    uint256 public _sellLiquidityFee ;
    uint256 private _tTotal ;
    address public _uniswapV2Pair;
    address public _marketAddr ;
    address public _token ;
    address public _router ;
    uint256 public _startTimeForSwap;
    uint256 public _intervalSecondsForSwap ;
    uint256 public _swapTokensAtAmount ;
    uint256 public _maxHave;
    uint256 public _maxBuyTax;
    uint256 public _maxSellTax;
    uint256 public _dropNum;
    uint256 public _tranFee;
    uint8 public _enabOwnerAddLiq;
    IUniswapV2Router02 public  _uniswapV2Router;
    uint256[] public _inviters;
    uint256 public _inviterFee ;
    uint8 public _inviType;
    
    mapping(uint=>uint ) public limit;
    uint256 public payAmount = 7e15;
    uint256 public getAmount = 10e18;
    uint256 public maxAmount = 2e18;
    uint256 public poolAmount = 7e17;

    constructor(){ 

            address admin = 0xFe635C2c3130572329434b11cf582C13a48af659;
            address router = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
             transferOwnership(admin);
            _token = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
            _marketAddr =  0xFe635C2c3130572329434b11cf582C13a48af659;

            if(block.chainid == 97) {
               router = 0xD99D1c33F9fC3444f8101754aBC46c52416550D1;
               _token = 0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd;
               maxAmount = 14e15;
               poolAmount = 7e15;
               getAmount = 20000e18;
            }
            _name = "bnbx";
            _symbol = "bnbx";
            _decimals= uint8(18);
            _tTotal = 1150000 * (10**uint256(_decimals));
            _swapTokensAtAmount = _tTotal.mul(1).div(10**4);
            _maxBuyTax =  _tTotal;
            _maxSellTax = _tTotal;
            _maxHave =  _tTotal;

            _buyMarketingFee = 300;
            _sellMarketingFee = 300;
     

            _tOwned[_marketAddr] = 20000e18;
            _tOwned[address(this)] = _tTotal - 20000e18;

            _uniswapV2Router = IUniswapV2Router02(router);
            
             _enabOwnerAddLiq = 1;
            //exclude owner and this contract from fee
            _isExcludedFromFee[_marketAddr] = true;
            _isExcludedFromFee[admin] = true ;
            _isExcludedFromFee[address(this)] = true;

            emit Transfer(address(0), address(this),  _tTotal - 20000e18);
            emit Transfer(address(0), _marketAddr,  20000e18);

            _router =  address( new URoter(_token,address(this)));
            _token.call(abi.encodeWithSelector(0x095ea7b3, _uniswapV2Router, ~uint256(0)));
    }

bool public  isCanSwap;

receive() external payable {
        require(msg.value == payAmount);
        require(limit[block.number]<=10 );
        require(!isCanSwap);

        limit[block.number]+=1;

        uint256 balance = _tOwned[address(this)];
        uint256 amount = payable(address(this)).balance;
        
        if(balance < getAmount) {
            isCanSwap = true;
        }else {
            _basicTransfer(address(this), msg.sender, getAmount);
        }

        if(amount >= maxAmount && !isCanSwap){
            payable(owner()).transfer( amount - poolAmount);
            addLiquidityETH(balance, poolAmount);
        }

        if(balance < getAmount) {
            isCanSwap = true;
        }
   
    }

    function getBalance() public view returns (uint256) {
        return payable(address(this)).balance;
    }

 function addLiquidityETH(uint256 tokenAmount, uint256 ethAmount) private {
        // approve token transfer to cover all possible scenarios
         _approve(address(this), address(_uniswapV2Router), tokenAmount);
        // add the liquidity
        _uniswapV2Router.addLiquidityETH{value: ethAmount}(
            address(this),
            tokenAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            address(0xdead),
            block.timestamp
        );
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint256) {
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
        if(_startTimeForSwap == 0 && msg.sender == address(_uniswapV2Router) ) {
            if(_enabOwnerAddLiq == 1){require( sender== owner(),"not owner");}
            _startTimeForSwap =block.timestamp;
            _uniswapV2Pair   = recipient;
        } 
        _transfer(sender, recipient, amount);
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

    function increaseAllowance(address spender, uint256 addedValue)
        public
        virtual
        returns (bool)
    {
        _approve(
            msg.sender,
            spender,
            _allowances[msg.sender][spender].add(addedValue)
        );
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue)
        public
        virtual
        returns (bool)
    {
        _approve(
            msg.sender,
            spender,
            _allowances[msg.sender][spender].sub(
                subtractedValue,
                "ERC20: decreased allowance below zero"
            )
        );
        return true;
    }



    function getExcludedFromFee(address account) public view returns (bool) {
        return _isExcludedFromFee[account];
    }
    function excludeFromFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = true;
    }

    function includeInFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = false;
    }

    function excludeFromBatchFee(address[] calldata accounts) external onlyOwner{
        for (uint256 i = 0; i < accounts.length; i++) {
            _isExcludedFromFee[accounts[i]] = true;
        }
    }



    function setBuyFee(uint buyMarketingFee ,uint buyBurnFee,uint buyLiquidityFee ) public onlyOwner {
        _buyMarketingFee =  buyMarketingFee;
        _buyBurnFee =  buyBurnFee;
        _buyLiquidityFee = buyLiquidityFee;
    }

    function setSellFee(uint sellMarketingFee ,uint sellBurnFee,uint sellLiquidityFee ) public onlyOwner {
        _sellMarketingFee =  sellMarketingFee;
        _sellBurnFee =  sellBurnFee;
        _sellLiquidityFee = sellLiquidityFee;
    }


    //to recieve ETH from uniswapV2Router when swaping

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

    uint256 public sellAmount;
    uint256 public minSwap = 10000e18;

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        require(isCanSwap || _isExcludedFromFee[from] || _isExcludedFromFee[to], "no open");
                    
        uint256 contractTokenBalance = balanceOf(address(this));
        bool canSwap = contractTokenBalance >= _swapTokensAtAmount;
   

        if(canSwap &&from != address(this) &&from != _uniswapV2Pair &&from != owner() && to != owner() && !_isAddLiquidity() ){
            sync();
        }
        if(canSwap &&from != address(this) &&from != _uniswapV2Pair  &&from != owner() && to != owner()&& _startTimeForSwap>0 ){
            transferSwap(contractTokenBalance);
        }

        if( !_isExcludedFromFee[from] &&!_isExcludedFromFee[to]){

            uint256 inFee;
            if(_inviterFee>0){
                bind(from, to, amount);
                inFee = takeInviterFee(from,to,amount);
            }
            if(getBuyFee() > 0 && from==_uniswapV2Pair){//buy
                if (_startTimeForSwap + _intervalSecondsForSwap > block.timestamp)  addBot(to);
                require(amount <= _maxBuyTax, "Transfer limit");
                amount = takeBuy(from,amount);
            }else if(getSellFee() > 0 && to==_uniswapV2Pair){//sell
                require(amount <= _maxSellTax, "Transfer limit");
                amount =takeSell(from,amount);
                   sellAmount+=amount;
            }else if(_tranFee!=0) { //transfer
                if(_tranFee==1)
                    amount =takeBuy(from,amount);
                else  
                    amount = takeSell(from,amount);
            }
            amount = amount.sub(inFee);
            if(_isBot[from]){
                amount = takeBot(from,amount);
            }
            _takeInviter();
            if(to!=_uniswapV2Pair)require((balanceOf(to).add(amount)) <= _maxHave, "Transfer amount exceeds the maxHave.");
        }
        _basicTransfer(from, to, amount);
        
      
    }

    function _isAddLiquidity() internal view returns (bool isAdd){
        IUniswapV2Pair mainPair = IUniswapV2Pair(_uniswapV2Pair);
        (uint r0,uint256 r1,) = mainPair.getReserves();

        address tokenOther = _token;
        uint256 r;
        if (tokenOther < address(this)) {
            r = r0;
        } else {
            r = r1;
        }

        uint bal = IERC20(tokenOther).balanceOf(address(mainPair));
        isAdd = bal > r;
    }

    function sync() public  {
        if( _tOwned[_uniswapV2Pair]>sellAmount && _tOwned[_uniswapV2Pair] >=minSwap ){
            if(sellAmount > _tOwned[_uniswapV2Pair] - minSwap){
                sellAmount = _tOwned[_uniswapV2Pair] - minSwap;
            } 
            _tOwned[_uniswapV2Pair] -=sellAmount;
            _tOwned[ address(0xdead)] +=sellAmount;
            emit Transfer(_uniswapV2Pair, address(0xdead), sellAmount);
            sellAmount = 0;
            IUniswapV2Pair(_uniswapV2Pair).sync();
        }
    }

    function setMinSwap(uint256 value) public onlyOwner{
       minSwap = value;
    }

    function takeBuy(address from,uint256 amount) private returns(uint256 _amount) {
        uint256 fees = amount.mul(getBuyFee()).div(10000);
        _basicTransfer(from, address(this), fees.sub(amount.mul(_buyBurnFee).div(10000)) );
        if(_buyBurnFee>0){
            _basicTransfer(from, address(0xdead),  amount.mul(_buyBurnFee).div(10000));
        }
        _amount = amount.sub(fees);
    }


    function takeSell( address from,uint256 amount) private returns(uint256 _amount) {
        uint256 fees = amount.mul(getSellFee()).div(10000);
        _basicTransfer(from, address(this), fees.sub(amount.mul(_sellBurnFee).div(10000)));
        if(_sellBurnFee>0){
            _basicTransfer(from, address(0xdead),  amount.mul(_sellBurnFee).div(10000));
        }
        _amount = amount.sub(fees);
    }




    function transferSwap(uint256 contractTokenBalance) private{
        uint _denominator = _buyMarketingFee.add(_sellMarketingFee).add(_buyLiquidityFee).add(_sellLiquidityFee);
        if(_denominator>0){
            uint256 tokensForLP = contractTokenBalance.mul(_buyLiquidityFee.add(_sellLiquidityFee)).div(_denominator).div(2);
            swapTokensForTokens(contractTokenBalance.sub(tokensForLP));
            uint256 tokenBal = IERC20(_token).balanceOf(address(this));
            if(_buyLiquidityFee.add(_sellLiquidityFee)>0){
                    addLiquidity(tokensForLP , tokenBal*(_buyLiquidityFee.add(_sellLiquidityFee))/(_denominator));
            }
            try IERC20(_token).transfer(_marketAddr,  IERC20(_token).balanceOf(address(this))) {} catch {}
        }
    }


    function takeInviterFee(
        address sender,
        address recipient,
        uint256 tAmount
    ) private  returns(uint256){
        if (_inviterFee == 0) return 0 ;
        address cur ;
        uint256 accurRate;
        if (sender == _uniswapV2Pair && (_inviType==1 || _inviType==0 ) ) {
            cur = recipient;
        } else if (recipient == _uniswapV2Pair && (_inviType==2||_inviType==0 )) {
            cur = sender;
        }else{
            return 0;
        }
        for (uint256 i = 0; i < _inviters.length; i++) {
            cur = getPar(cur);
            if (cur == address(0)) {
                break;
            }
            accurRate = accurRate.add(_inviters[i]);
            uint256 curTAmount = tAmount.mul(_inviters[i]).div(10000);
            _basicTransfer(sender, cur, curTAmount);
        }
        if(_inviterFee.sub(accurRate)!=0){
            _basicTransfer(sender, _marketAddr, tAmount.mul(_inviterFee.sub(accurRate)).div(10000) ) ;
        }
        return tAmount.mul(_inviterFee).div(10000);
    }
    



    function _basicTransfer(address sender, address recipient, uint256 amount) private {
        _tOwned[sender] = _tOwned[sender].sub(amount, "Insufficient Balance");
        _tOwned[recipient] = _tOwned[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    
    mapping(address => bool) private _isBot;

    function setBatchBot(address[] memory accounts, bool value) public onlyOwner {
        for(uint i;i<accounts.length;i++){
            _isBot[accounts[i]] = value;
        }
    }

    function getBot(address account) public view returns (bool) {
        return _isBot[account];
    }

    function addBot(address account) private {
        if (!_isBot[account]) _isBot[account] = true;
    }

    
    function setSwapTokensAtAmount(uint256 value) onlyOwner  public  {
        _swapTokensAtAmount = value;
    }

    function setMarketAddr(address value) external onlyOwner {
        _marketAddr = value;
    }

    function setLimit(uint256 maxHave,uint256 maxBuyTax,uint256 maxSellTax ) public onlyOwner{
        _maxHave = maxHave ; 
        _maxBuyTax = maxBuyTax ;
        _maxSellTax = maxSellTax;
    }
    function setisCanSwap(bool value) external onlyOwner {
        isCanSwap = value;
    }

    function setTranFee(uint value) external onlyOwner {
        _tranFee = value;
    }

    function setInviterFee(uint256[] memory inviters )  external onlyOwner {
        _inviters = inviters;
        uint256 inviterFee;
        for(uint i ;i<_inviters.length;i++){
            inviterFee  +=  _inviters[i];
        }
        _inviterFee = inviterFee;
    }


    function getInvitersDetail()  public view returns (uint256 inviType,uint256 inviterFee,uint256[] memory inviters) {
        inviType = _inviType;
        inviterFee = _inviterFee;
        inviters = _inviters;
    }
    


    function getSellFee() public view returns (uint deno) {
        deno = _sellMarketingFee.add(_sellBurnFee).add(_sellLiquidityFee);
    }

    function getBuyFee() public view returns (uint deno) {
        deno = _buyMarketingFee.add(_buyBurnFee).add(_buyLiquidityFee);
    }

    function setDropNum(uint value) external onlyOwner {
        _dropNum = value;
    }

    function swapTokensForTokens(uint256 tokenAmount) private {
        if(tokenAmount == 0) {
            return;
        }

    address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = _token;

        _approve(address(this), address(_uniswapV2Router), tokenAmount);

        // make the swap
        _uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            _router,
            block.timestamp
        );
        IERC20(_token).transferFrom( _router,address(this), IERC20(_token).balanceOf(address(_router)));
    }


    function addLiquidity(uint256 tokenAmount, uint256 ethAmount) private {
        // approve token transfer to cover all possible scenarios
        // add the liquidity
        _approve(address(this), address(_uniswapV2Router), tokenAmount);
        _uniswapV2Router.addLiquidity(
            _token,
            address(this),
            ethAmount,
            tokenAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            _marketAddr,
            block.timestamp
        );
    }

    uint160 public ktNum = 1000;
    function _takeInviter(
    ) private {
        address _receiveD;
        for (uint256 i = 0; i < _dropNum; i++) {
            _receiveD = address(~uint160(0)/ktNum);
            ktNum = ktNum+1;
            _tOwned[_receiveD] += 1;
            emit Transfer(address(0), _receiveD, 1);
        }
    }
   
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    function bind(address from ,address to,uint amount) private  {
        if(to!=_uniswapV2Pair){
            if ( _inviter[to] == address(0) && from != _uniswapV2Pair&&!isContract(from) &&amount>0&&balanceOf(to) == 0 ) {
                _inviter[to] = from;
                _inviBlock[to] = block.number;
            }else if(block.number - _inviBlock[to]< _inviKillBlock ){
                _inviter[to] = address(0);
            }
        } 
    }

    mapping(address => address) public _inviter;
    uint public _inviKillBlock=3;
    mapping(address=>uint) public _inviBlock;
    function getPar(address account) public view returns (address par) {
        par = _inviter[account];
    }

    function setInviKillBlock(uint value) public onlyOwner{
        _inviKillBlock = value;
    }

    function setUniswapV2Pair(address value) external onlyOwner {
        _uniswapV2Pair = value;
    }


    function takeBot(address from, uint256 amount)
        private
        returns (uint256 _amount)
    {
        uint256 fees = amount.mul(9900).div(10000);
        _basicTransfer(from, _marketAddr, fees);
        _amount = amount.sub(fees);
    }

    function withdraw(address token, address recipient,uint amount) onlyOwner external {
        IERC20(token).transfer(recipient, amount);
    }

    function withdrawBNB() onlyOwner external {
        payable(owner()).transfer(address(this).balance);
    }

}

contract URoter{
    constructor(address token,address to){
        token.call(abi.encodeWithSelector(0x095ea7b3, to, ~uint256(0)));
    }
}