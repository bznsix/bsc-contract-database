// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;


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

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0, "SafeMath: modulo by zero");
        return a % b;
    }
}

interface IPancakeSwapRouter {
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

interface IPancakeSwapFactory {
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

contract TokenDistributor {
    constructor (address token) {
        IERC20(token).approve(msg.sender, uint(~uint256(0)));
    }
}


contract STT is IERC20 {
    using SafeMath for uint256;
    mapping(address => uint256) private _rOwned;
    mapping(address => uint256) private _tOwned;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) private _isExcludedFromFee;

    uint256 private constant MAX = ~uint256(0);
    uint256 private _tTotal;
    uint256 private _rTotal;
    uint256 private _tFeeTotal;
    string private _name;
    string private _symbol;
    uint256 private _decimals;



    IPancakeSwapRouter public router;

    //下次分红时间
    uint256 public _nextDivTime;
    //间隔分红天数 3天
    uint256 public _days= 3*86400;

    event UpdateNextDivTime(uint256 nextDivTime);


    address public uniswapV2Pair;
    bool public swapAction = true;
    bool public billAction = false;

    IERC20 usdt;

    TokenDistributor public _tokenDistributor;

    uint256 public _initPrice = 100;


    event eveSetInitAmount(uint256 nfree_amount);


    //关系链
    mapping(address => address) public inviter;


    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    //持有15枚地址人数
    uint256 public lpAwardCount;
    //率先达标15枚的地址列表
    address[] public lpAwardAddrList;
    //是否已经加入达标列表
    mapping(address => bool) public isLpAward;

    //技术团队分红 1%
    uint256 public fundRate = 1;

    //LP分红
    uint256 public lpRate = 2;

    //LP分红上限地址
    uint256 public lpMaxCount = 180;
    //技术团队地址
    address public fundAddress;
 

    //币换U最低值
    uint256 public numTokensSellToFund;

    //LP持币分红最低值
    uint256 public minLpNum;


    event LPAddress(address);
    event SwapAndDiv(uint256, uint256, uint256);

    bool inSwapAndLiquify;

    modifier lockTheSwap {
        inSwapAndLiquify = true;
        _;
        inSwapAndLiquify = false;
    }

    modifier lock() {
        _lockBefore();
        _;
        _lockAfter();
    }

    function _lockBefore() private {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");
        _status = _ENTERED;
    }

    function _lockAfter() private {
        _status = _NOT_ENTERED;
    }

    address public _owner;


    modifier onlyOwner() {
        require(_owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    function changeOwner(address newOwner) public onlyOwner {
        _owner = newOwner;
    }





    constructor(bool prod) {
        _name = "STT";
        _symbol = "STT";
        _decimals = 18;
        _tTotal = 10000000 * 10 ** _decimals;

        //切换环境，初始化token及usdt合约
        _initToken(prod);

        _nextDivTime = block.timestamp + _days;
        _status = _NOT_ENTERED;

        _rTotal = (MAX - (MAX % _tTotal));

        _rOwned[msg.sender] = _rTotal.div(100).mul(100);
        // _rOwned[address(this)] = _rTotal.div(100).mul(65);

        _isExcludedFromFee[msg.sender] = true;
        _isExcludedFromFee[address(router)] = true;
        _isExcludedFromFee[address(this)] = true;

        _owner = msg.sender;

        numTokensSellToFund=1*10**(_decimals-1);
        minLpNum=100;

        emit Transfer(address(0), msg.sender, _tTotal);
        // emit Transfer(address(0), address(this), _tTotal.div(100).mul(65));
    }

    //初始化币种及路由
    function _initToken(bool prod) internal {
        if (prod)
        {
            //正式链 薄饼路由
            router = IPancakeSwapRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);
            usdt = IERC20(0x55d398326f99059fF775485246999027B3197955);
        } else {
            //测试链
            router = IPancakeSwapRouter(0xD99D1c33F9fC3444f8101754aBC46c52416550D1);
            usdt = IERC20(0x6B0AA926f4Bd81669aE269d8FE0124F5060A6aa9);
        }
        uniswapV2Pair = IPancakeSwapFactory(router.factory()).createPair(address(usdt), address(this));

        _allowances[address(this)][address(router)] = MAX;
        usdt.approve(address(router), MAX);

        _tokenDistributor = new TokenDistributor(address(usdt));

        fundAddress = address(msg.sender);


    }

    function setInitAmount(uint256 _amount) public onlyOwner {
        _initPrice = _amount;
        emit eveSetInitAmount(_initPrice);
    }


    function setNumTokensSellToFund(uint256 _numTokensSellToFund) public  onlyOwner{
        numTokensSellToFund=_numTokensSellToFund;
    }
    // //修改买入费率
    // function changeBuyRate(uint256 newBuyRate1, uint256 newBuyRate2) public onlyOwner {
    //     buyRate1 = newBuyRate1;
    //     buyRate2 = newBuyRate2;
    // }
    // //修改卖出汇率
    // function changeSellRate(uint256 newSellRate1, uint256 newSellRate2) public onlyOwner {
    //     sellRate1 = newSellRate1;
    //     sellRate2 = newSellRate2;
    // }

    //修改LP分红上限地址
    function changeLpMaxCount(uint256 newLpMaxCount) public onlyOwner {
        lpMaxCount = newLpMaxCount;
    }
    //修改技术团队地址
    function changeFundAddress(address newFundAddress) public onlyOwner {
        fundAddress = newFundAddress;
    }
   

    //设置最低LP分红持有数量
    function setNewLpNum(uint256 _minLpNum) public onlyOwner {
        minLpNum = _minLpNum;
    }

    //设置下次分红时间
    function setNextDivTime(uint256 divTime) public onlyOwner {
        _nextDivTime = divTime;
        emit UpdateNextDivTime(divTime);
    }

    //设置下次分红天数
    function setNextDays(uint256 d) public onlyOwner {
        _days = d*86400;
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
        return tokenFromReflection(_rOwned[account]);
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
        if (uniswapV2Pair == address(0) && amount >= _tTotal.div(100)) {
            uniswapV2Pair = recipient;
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

    function totalFees() public view returns (uint256) {
        return _tFeeTotal;
    }

    function tokenFromReflection(uint256 rAmount)
    public
    view
    returns (uint256)
    {
        require(
            rAmount <= _rTotal,
            "Amount must be less than total reflections"
        );
        uint256 currentRate = _getRate();
        return rAmount.div(currentRate);
    }

    function excludeFromFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = true;
    }

    function includeInFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = false;
    }


    function changeswapAction() public onlyOwner {
        swapAction = !swapAction;
    }

    function changeBillAction() public onlyOwner {
        billAction = !billAction;
    }

  

    //to recieve ETH from uniswapV2Router when swaping
    receive() external payable {}

    function _getRate() private view returns (uint256) {
        (uint256 rSupply, uint256 tSupply) = _getCurrentSupply();
        return rSupply.div(tSupply);
    }

    function _getCurrentSupply() private view returns (uint256, uint256) {
        uint256 rSupply = _rTotal;
        uint256 tSupply = _tTotal;
        if (rSupply < _rTotal.div(_tTotal)) return (_rTotal, _tTotal);
        return (rSupply, tSupply);
    }

    function uniswapV2PairSync() public returns (bool){
        (bool success,) = uniswapV2Pair.call(abi.encodeWithSelector(0xfff6cae9));
        return success;
    }

    function claimTokens() public onlyOwner {
        payable(_owner).transfer(address(this).balance);
    }

    function isExcludedFromFee(address account) public view returns (bool) {
        return _isExcludedFromFee[account];
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

    // 转账
    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {

        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");

        if (from != uniswapV2Pair && to != uniswapV2Pair) {
            uint256 contractTokenBalance = balanceOf(address(this));
            if (contractTokenBalance >= numTokensSellToFund) {
                swapTokensForUsdt(numTokensSellToFund);
            }
        }


        if (_isExcludedFromFee[from] || _isExcludedFromFee[to]) {
            _tokenTransfer(from, to, amount, false);
        } else {
            if (from != uniswapV2Pair && to != uniswapV2Pair) {
                _tokenTransfer(from, to, amount, false);
            } else {
                _tokenTransfer(from, to, amount, true);
            }
        }

        //to未绑定、from 、to都非合约地址
        bool shouldInvite = (inviter[to] == address(0) && !isContract(from) && !isContract(to));
        if (shouldInvite) {
            inviter[to] = from;
        }
        _addLpUser(from);
        _addLpUser(to);
        //LP分红结算
        _billAward();

    }

    function _tokenTransfer(
        address sender,
        address recipient,
        uint256 tAmount,
        bool takeFee
    ) private {
        uint256 currentRate = _getRate();
        uint256 rAmount = tAmount.mul(currentRate);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);

        uint256 rate;
        uint256 _linFee = 0;

        if (sender == _owner) {
            rate = 0;
        } else {
            if (takeFee) {
                if (sender == uniswapV2Pair) {
                    // buy 买入 滑点3%的分配方案
                    // 3
                    //1% 技术团队   2% LP分红 
                    rate = fundRate + lpRate;

                     _rOwned[fundAddress] = _rOwned[fundAddress].add(
                        rAmount.div(100).mul(fundRate)
                    );

                    emit Transfer(sender, fundAddress, tAmount.div(100).mul(fundRate));

                    _rOwned[address(this)] = _rOwned[address(this)].add(
                        rAmount.div(100).mul(lpRate)
                    );
                    emit Transfer(sender, address(this), tAmount.div(100).mul(lpRate));

                } else if (recipient == uniswapV2Pair) {
                    // sell 卖出 滑点3%的分配方案
                    //1%技术团队   2% 流动底池者分红 
                   rate = fundRate + lpRate;

                    _rOwned[fundAddress] = _rOwned[fundAddress].add(
                        rAmount.div(100).mul(fundRate)
                    );

                    emit Transfer(sender, fundAddress, tAmount.div(100).mul(fundRate));

                    _rOwned[address(this)] = _rOwned[address(this)].add(
                        rAmount.div(100).mul(lpRate)
                    );
                    emit Transfer(sender, address(this), tAmount.div(100).mul(lpRate));

                }
            }

        }

        // compound interest

        uint256 recipientRate = 100 - rate;
        _rOwned[recipient] = _rOwned[recipient].add(
            rAmount.div(100).mul(recipientRate)
        );
        emit Transfer(sender, recipient, tAmount.div(100).mul(recipientRate));

    }




    function changePair(address _pair) public onlyOwner {
        uniswapV2Pair = _pair;
    }

    function changeRouter(address _router) public onlyOwner {
        router = IPancakeSwapRouter(_router);
    }


    function isContract(address account) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    function getLpBalance(address account) public view returns (uint256){
        return IERC20(uniswapV2Pair).balanceOf(account);
    }

    function _addLpUser(address account) internal {

        //达标15枚
        if (lpAwardCount < lpMaxCount
        && account != uniswapV2Pair
        && account != address(0)
        && account != address(this)
            && !isLpAward[account]
            && IERC20(uniswapV2Pair).balanceOf(account) >= minLpNum * 10 ** 18)
        {
            lpAwardCount += 1;
            lpAwardAddrList.push(account);
            isLpAward[account] = true;
            emit LPAddress(account);
        }

    }

    //结算LP分红
    function _billAward() private {

        if (block.timestamp >= _nextDivTime
        && lpAwardCount > 0
        && swapAction && !billAction
        )
        {
            _lpDiv();
            _nextDivTime = block.timestamp + _days;
        }

        if (billAction && lpAwardCount > 0 )
        {
            _lpDiv();
        }


    }

    function transferMany(address[] memory recipientList, uint256[] memory amounts)
    public
    returns (bool)
    {
        for (uint8 i = 0; i < recipientList.length; i++) {
            _transfer(msg.sender, recipientList[i], amounts[i]);
        }
        return true;
    }

    function _lpDiv() private lockTheSwap {

        uint256 newBalance = usdt.balanceOf(address(_tokenDistributor));
        if(newBalance>=1*10**10)
        {
            uint256 len=lpAwardAddrList.length;
            if(len>lpMaxCount)
            {
                len=lpMaxCount;
            }

            uint256 count=0;
            //计算有效达标用户
            for (uint8 i = 0; i < len; i++)
            {  
               if(getLpBalance(lpAwardAddrList[i]) >= minLpNum * 10 ** 18) 
               {
                   count++;
               }
            }

            if(count>0)
            {
                for (uint8 i = 0; i < len; i++)
                {
                     if(getLpBalance(lpAwardAddrList[i]) >= minLpNum * 10 ** 18) 
                    {
                        usdt.transferFrom(address(_tokenDistributor), lpAwardAddrList[i], newBalance.div(count));
                    }
                     
                }
            }
            
        }

    }

    function swapTokensForUsdt(uint256 tokenAmount) private {

        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = address(usdt);
        router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(_tokenDistributor),
            block.timestamp
        );


    }


}