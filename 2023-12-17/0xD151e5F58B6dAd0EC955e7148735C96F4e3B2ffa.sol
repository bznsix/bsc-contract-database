// SPDX-License-Identifier: Unlicensed

pragma solidity ^0.8.6;

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount)
    external
    returns (bool);

    function allowance(address owner, address spender)
    external
    view
    returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

abstract contract Ownable {
    address private _owner;
    address private _previousOwner;
    uint256 private _lockTime;

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
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
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

interface IWETH {
    function deposit() external payable;
    function transfer(address to, uint value) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
    function transferFrom(address sender,address recipient,uint256 amount) external returns (bool);
    function withdraw(uint) external;
}

interface Operate{
    function getProhibit(address ) external view returns (bool);
    function getOpen(address ) external view returns (bool);
    function getOpeningSwap() external view returns (uint256,uint256);
    function getSwapBackflow(uint256 ) external view returns (uint256);
    function getSwapSubBackflow(uint256 ) external view returns (uint256);
    function operateAddress() external view returns (address);
    function getSwapBurn(uint256 ) external view returns (uint256);
    function getSwapLpDividend(uint256) external view returns (uint256);
    function getLpIncomeTime() external view returns (uint256);
}

contract EGA is IERC20,Ownable {
    using SafeMath for uint256;
    Operate public _operate;
    mapping(address => uint256) private _tOwned;
    mapping(address => uint256) public _dayBuy;
    mapping(address => uint256) public _preSale;

    mapping(address => mapping(address => uint256)) private _allowances;

    string private _name = "EGA";
    string private _symbol = "EGA";
    uint8 private _decimals = 18;
    uint256 private _tTotal = 10000000000 * 10 ** 18;
    uint256 private _destroy=0;
    
    uint256 private constant MAX = ~uint256(0);
    IUniswapV2Router02 private _uniswapV2Router;
    IUniswapV2Pair private _uniswapV2Pair;
    IWETH public WETH ;

    IUniswapV2Router02 public immutable uniswapV2Router;
    address public immutable uniswapV2Pair;

    constructor(address _operateAddress) {
        _operate=Operate(_operateAddress);
        _tOwned[msg.sender] = _tTotal;
        emit Transfer(address(0), msg.sender, _tTotal);

        _uniswapV2Router = IUniswapV2Router02(
            0x10ED43C718714eb63d5aA57B78B54704E256024E
        );
        _allowances[address(this)][address(_uniswapV2Router)] = MAX;

        WETH=IWETH(_uniswapV2Router.WETH());

        uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
        .createPair(address(this), address(WETH));

        _uniswapV2Pair=IUniswapV2Pair(uniswapV2Pair);

        uniswapV2Router = _uniswapV2Router;
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

    function destroy() public view returns (uint256) {
        return _destroy;
    }

    function totalSupply() public view override returns (uint256) {
        return _tTotal;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _tOwned[account];
    }

    function surplusBurn() public view  returns (uint256) {
        return 9900000000 * 10 ** 18-_destroy;
    }

    function _burnLimit(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");
        _tOwned[account] = _tOwned[account].sub(amount);
        _burn(account,amount);
    }

    function _burn(address account, uint256 amount) internal virtual {
        _destroy=_destroy.add(amount);
        _tOwned[address(0)] = _tOwned[address(0)].add(amount);
        emit Transfer(account, address(0), amount);
    }

    function burn(uint256 amount) public virtual {
        _burn(msg.sender, amount);
    }

    function burnFrom(address account, uint256 amount) public virtual {
        uint256 currentAllowance = allowance(account, msg.sender);
        require(currentAllowance >= amount, "ERC20: burn amount exceeds allowance");
    unchecked {
        _approve(account, msg.sender, currentAllowance.sub(amount));
    }
        _burn(account, amount);
    }

    function PreSale(address addr) public onlyOwner{
        _preSale[addr]=_tOwned[addr];
    }

    function transfer(address recipient, uint256 amount)
    external
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

    //to recieve ETH from uniswapV2Router when swaping
    receive() external payable {}

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
        require(from != address(0), "ERC20: transfer from the zero address");
        require(_tOwned[from] >= amount, "ERC20: Insufficient balance");
        require(_tOwned[from]-amount >= 10000 || from==address(_uniswapV2Router), "ERC20: Unable to transfer out all");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        require(_operate.getProhibit(from)==false, "Blacklist address");
        bool openFrom = _operate.getOpen(from);
        if (openFrom==true || from==address(this)){
            _tOwned[from] = _tOwned[from].sub(amount);
            _tOwned[to] = _tOwned[to].add(amount);
            emit Transfer(from, to, amount);
            if (from!=address(this)){
                processLp(100000);
            }
            if(to==uniswapV2Pair && _isAddLiquidity() && from!=address(this)){
                addHolder(from);
            }
            return;
        }
        
        _tOwned[from] = _tOwned[from].sub(amount);
        
        if ((to == uniswapV2Pair || from == uniswapV2Pair) && _operate.getOpen(to)==false) {
            (uint256 swapOpen,uint256 swapLimit)=_operate.getOpeningSwap();
            require( swapOpen<= block.timestamp, "Transaction not opened");
           
            if (to==uniswapV2Pair){
                require(_preSale[from]==0, "The pre-sale amount cannot be sold or added to the pool");
                if(_isAddLiquidity()){
                    addHolder(from);
                    _tOwned[to] = _tOwned[to].add(amount);
                    emit Transfer(from, to, amount);
                    return;
                }else{
                    processLp(500000);
                }
            }
            uint256 swapBackflow=_operate.getSwapBackflow(amount);
            uint256 swapLpAmount=_operate.getSwapLpDividend(amount);
            uint256 swapBurnAmount=_operate.getSwapBurn(amount);

            if (from==uniswapV2Pair){
                if(_isRemoveLiquidity()){
                    swapLpAmount=0;
                    swapBurnAmount=0;
                    swapBackflow=_operate.getSwapSubBackflow(amount);
                }else{
                    if (block.timestamp<swapLimit){
                        _dayBuy[to]=_dayBuy[to].add(amount.mul(getPrice()));
                        require(_dayBuy[to]<1000000000000*10**18,"Exceeding limit");
                    }
                }
            }

            if (swapLpAmount>0){
                _tOwned[address(this)] = _tOwned[address(this)].add(swapLpAmount);
                amount=amount.sub(swapLpAmount);
                emit Transfer(from, address(this), swapLpAmount);
            }
            
            if (swapBackflow>0){
                address operateAddress=_operate.operateAddress();
                _tOwned[operateAddress] = _tOwned[operateAddress].add(swapBackflow);
                amount=amount.sub(swapBackflow);
                emit Transfer(from, operateAddress, swapBackflow);
            }
            
            if(surplusBurn()<swapBurnAmount){
                swapBurnAmount=surplusBurn();
            }

            if (swapBurnAmount>0){
                _burn(from,swapBurnAmount);
                amount=amount.sub(swapBurnAmount);
            }
            
            _tOwned[to] = _tOwned[to].add(amount);
            emit Transfer(from, to, amount);
        }else {
            if (_preSale[from]>0){
                if (_preSale[from]>=amount){
                    _preSale[from]=_preSale[from].sub(amount);
                    if (_operate.getOpen(to)==false){
                        _preSale[to]=_preSale[to].add(amount);
                    }
                }else{
                    if (_operate.getOpen(to)==false){
                        _preSale[to]=_preSale[to].add(_preSale[from]);
                    }
                    _preSale[from]=0;
                }
            }
            _tOwned[to] = _tOwned[to].add(amount);
            emit Transfer(from, to, amount);
            processLp(100000);
        }
    }

    uint256 public lastLpIncomeTime;
    uint256 public lastLpIncomeIndex;

    function _isAddLiquidity() internal view returns (bool isAdd){
        uint256 _ethBalance=address(_uniswapV2Router).balance;
        isAdd=_ethBalance>0;
    }

    function _isRemoveLiquidity() internal view returns (bool isRemove){
        (uint256 r0,uint256 r1,) = _uniswapV2Pair.getReserves();
        address tokenOther = address(WETH);
        uint256 r;
        if (tokenOther < address(this)) {
            r = r0;
        } else {
            r = r1;
        }

        uint bal = IERC20(tokenOther).balanceOf(address(uniswapV2Pair));
        isRemove = r >= bal;
    }

    function getPrice() public view returns (uint256 price){
        (uint256 r0,uint256 r1,) = _uniswapV2Pair.getReserves();
        if (r0==0 ||r1==0){return 0;}
        address tokenOther = address(WETH);
        if (tokenOther < address(this)) {
            return r0.mul(1000000000000).div(r1);
        }else{
            return r1.mul(1000000000000).div(r0);
        }
    }

    address[] public holders;
    mapping(address => uint256) holderIndex;
    mapping(address => uint256) holderIndexTime;
    function addHolder(address adr) private  {
        uint256 size;
        assembly {
            size := extcodesize(adr)
        }
        if (size > 0) {
            return;
        }
        if (0 == holderIndex[adr]) {
            if (0 == holders.length || holders[0] != adr) {
                holderIndex[adr] = holders.length;
                holderIndexTime[adr]=block.timestamp;
                holders.push(adr);
            }
        }
    }


    bool private inSwap;
    modifier lockTheSwap() {
        inSwap = true;
        _;
        inSwap = false;
    }
    event Failed_swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 value,
        string error
    );
    event Success_swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 value
    );

    function swapTokenForFund(uint256 tokenAmount)
        private
        lockTheSwap
    {
        address[] memory path = new address[](2);
        path[0]=address(this);
        path[1]=address(WETH);
        try 
            _uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
                tokenAmount,
                0,
                path,
                address(_operate),
                block.timestamp+30
            )
        {
            emit Success_swapExactTokensForTokensSupportingFeeOnTransferTokens(
                tokenAmount
            );
        }
        catch{
            emit Failed_swapExactTokensForTokensSupportingFeeOnTransferTokens(
                tokenAmount,
                "Unknow error occurred!"
            );
        }
    } 

    uint256 public _lastLpIncomeWETH;

    function processLp(uint256 gas) private {
        if(lastLpIncomeTime==0){
            lastLpIncomeTime=block.timestamp;
            return ;
        }
        if(lastLpIncomeTime+_operate.getLpIncomeTime()>block.timestamp && lastLpIncomeIndex==0){
            return ;
        }
        
        uint256 contractTokenBalance = _tOwned[address(this)];
        if ( !inSwap && contractTokenBalance>10000 && lastLpIncomeIndex==0){
            swapTokenForFund(contractTokenBalance-10000);
            lastLpIncomeTime=block.timestamp;
        }

        IERC20 lp = IERC20(uniswapV2Pair);
        uint lpTokenTotal=lp.totalSupply();
        if (lpTokenTotal==0){
            return;
        }

        uint256 balance;
        address shareHolder;
        uint256 tokenBalance;
        uint256 amount;

        uint256 shareholderCount = holders.length;
        
        uint256 gasUsed = 0;
        uint256 iterations = 0;
        uint256 gasLeft = gasleft();
        balance = WETH.balanceOf(address(_operate));
        if (balance>0){
            WETH.transferFrom(
                address(_operate),
                address(this),
                balance
            );
        }
        
        balance = WETH.balanceOf(address(this));
        if (balance>0){
            WETH.withdraw(balance);
        }
        balance = address(this).balance;
        if (balance==0){
            return;
        }
        if (_lastLpIncomeWETH==0){
            _lastLpIncomeWETH=balance;
        }
        
        while (gasUsed < gas && iterations < shareholderCount) {
            shareHolder = holders[lastLpIncomeIndex];
            tokenBalance = lp.balanceOf(shareHolder);
            if (tokenBalance > 0 && !_operate.getProhibit(shareHolder)) {
                amount = (_lastLpIncomeWETH * tokenBalance) / lpTokenTotal;
                if (amount > 0 && address(this).balance > amount) {
                    // usdt.transfer(shareHolder, amount);
                    payable(shareHolder).transfer(amount);
                }
            }
            gasUsed = gasUsed + (gasLeft - gasleft());
            gasLeft = gasleft();
            lastLpIncomeIndex++;
            iterations++;
            if (lastLpIncomeIndex >= shareholderCount) {
                lastLpIncomeIndex = 0;
                _lastLpIncomeWETH=0;
                iterations=shareholderCount;
            }
        }
    }
}