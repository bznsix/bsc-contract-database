// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.6;

interface IBEP20 {

  function totalSupply() external view returns (uint256);

  function decimals() external view returns (uint8);

  function symbol() external view returns (string memory);

  function name() external view returns (string memory);

  function getOwner() external view returns (address);

  function balanceOf(address account) external view returns (uint256);

  function transfer(address recipient, uint256 amount) external returns (bool);

  function allowance(address _owner, address spender) external view returns (uint256);

  function approve(address spender, uint256 amount) external returns (bool);

  function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

  event Transfer(address indexed from, address indexed to, uint256 value);

  event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract Context {
  constructor ()  { }

  function _msgSender() internal view returns (address) {
    return msg.sender;
  }

  function _msgData() internal view returns (bytes memory) {
    this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
    return msg.data;
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

  function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
    // Solidity only automatically asserts when dividing by 0
    require(b > 0, errorMessage);
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold

    return c;
  }

  function mod(uint256 a, uint256 b) internal pure returns (uint256) {
    return mod(a, b, "SafeMath: modulo by zero");
  }

  function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
    require(b != 0, errorMessage);
    return a % b;
  }
}

contract Ownable is Context {
  address private _owner;

  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

  constructor () {
    address msgSender = _msgSender();
    _owner = msgSender;
    emit OwnershipTransferred(address(0), msgSender);
  }

  function owner() public view returns (address) {
    return _owner;
  }

  modifier onlyOwner() {
    require(_owner == _msgSender(), "Ownable: caller is not the owner");
    _;
  }

  function renounceOwnership() public onlyOwner {
    emit OwnershipTransferred(_owner, address(0));
    _owner = address(0);
  }

  function transferOwnership(address newOwner) public onlyOwner {
    _transferOwnership(newOwner);
  }

  function _transferOwnership(address newOwner) internal {
    require(newOwner != address(0), "Ownable: new owner is the zero address");
    emit OwnershipTransferred(_owner, newOwner);
    _owner = newOwner;
  }
}
// pragma solidity >=0.5.0;
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

interface IUniswapV2Router02 is IUniswapV2Router01 {
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

interface IUniswapV2Factory {
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

    event Cast(address indexed sender, uint amount0, uint amount1);
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

    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;

    function initialize(address, address) external;
}

contract BTS is Context, IBEP20, Ownable {
    using SafeMath for uint256;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;
    uint8 private _decimals;
    string private _symbol;
    string private _name;
    address private _creator;

    address public uniswapV2Pair;

    mapping (address => address) private bindMap;

    address private fromAddress;
    address private toAddress;
    mapping (address => bool) isExempt;
    bool private swapping;
    uint256 public minPeriod = 86400;

    uint256 public taxFee = 20;//2%
    address public walletDead = 0x000000000000000000000000000000000000dEaD;
    address public walletMarket = 0xc85E8DCe93d2d8cf8ff9d94593e1C10961Ae3451;
    address public contractUSDT;
    uint256 public minimumDividen = 25000000000000000000;//25usdt
    uint256 public parentDividenRate = 10;

    uint256 public dailyMined;
    uint256 public mineStartTime = block.timestamp;
    uint256 public lastSwapTime ;
    mapping(uint256 => bool) public releaseDailyMap;
    address[] public shareholders;
    mapping(address => bool) private _updated;
    mapping (address => uint256) public shareholderIndexes;
    mapping (address => mapping (uint256 => bool)) public dailyMap;

    constructor(address _ROUTER, address USDT)  {
        _name = "BTS";
        _symbol = "BTS";
        _decimals = 18;
        _totalSupply = 210000000 * (10**_decimals);
        _creator = msg.sender;

        IUniswapV2Router02 uniswapV2Router = IUniswapV2Router02(_ROUTER);
        uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(USDT, address(this));
        contractUSDT = USDT;

        isExempt[address(this)] = true;
        isExempt[address(0)] = true;
        isExempt[address(walletDead)] = true;

        _balances[msg.sender] = 20000000 * (10**_decimals);
        emit Transfer(address(0), msg.sender, _balances[msg.sender] );
        _balances[address(this)] = _totalSupply.sub(_balances[msg.sender] );
        emit Transfer(address(0), address(this), _balances[address(this)]);
    }
    receive() external payable {}

    function bindParent(address son_add) internal {
        if(isExempt[son_add] || isExempt[msg.sender]){
            return;
        }

        if (bindMap[son_add] == address(0)){  
            bindMap[son_add] = msg.sender;
        }
    }
    function getParent1(address son) public view returns (address){
        return bindMap[son];
    }

    function setMinimumDividenUsdt(uint256 number) public {
        require(msg.sender == _creator, "BTS: creator only");
        minimumDividen = number;
    }
    function setMinPeriod(uint256 number) public onlyOwner {
        minPeriod = number;
    }

    function setTaxFee(uint256 number) public onlyOwner returns (uint256) {
        taxFee = number;
        return taxFee;
    }

    function getOwner() external override view returns (address) {
        return owner();
    }

    function decimals() external override view returns (uint8) {
        return _decimals;
    }

    function symbol() external override view returns (string memory) {
        return _symbol;
    }

    function name() external override view returns (string memory) {
        return _name;
    }

    function totalSupply() external override view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) external override view returns (uint256) {
        return _balances[account];
    }


    function transfer(address recipient, uint256 amount) external override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) external override view returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) external override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "BEP20: decreased allowance below zero"));
        return true;
    }

    function _burn(address account, uint256 amount) internal {
        require(account != address(0), "BEP20: burn from the zero address");

        _balances[account] = _balances[account].sub(amount, "BEP20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal {
        require(owner != address(0), "BEP20: approve from the zero address");
        require(spender != address(0), "BEP20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _burnFrom(address account, uint256 amount) internal {
        _burn(account, amount);
        _approve(account, _msgSender(), _allowances[account][_msgSender()].sub(amount, "BEP20: burn amount exceeds allowance"));
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {

        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "BEP20: transfer amount exceeds allowance"));
        return true;
    }
    function doTransfer(address sender, address recipient, uint256 amount) internal {
        _balances[sender] = _balances[sender].sub(amount, "BEP20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }
    function getTaxFee() public view returns(uint256){
        uint256 dayss = (block.timestamp.sub(mineStartTime)).div(minPeriod).add(1);
        uint256 tax = taxFee;//2%
        if(dayss>180) tax=10;
        if(dayss>270) tax=5;
        return tax;
    }
    function getTodayAmount() public view returns (uint256){
        uint256 dayss = (block.timestamp.sub(mineStartTime)).div(minPeriod).add(1);
        uint256 dividenRate = 16;//1.6%
        if(dayss>90) dividenRate=8;
        if(dayss>180) dividenRate=4;
        if(dayss>270) dividenRate=2;
        if(dayss>360) dividenRate=1;

        uint256 cakesupplytotal =IBEP20(uniswapV2Pair).totalSupply();
        if(cakesupplytotal <= 0) return 0;
        uint256 bthInPool = _balances[uniswapV2Pair];
        if(bthInPool <= 0) return 0;

        return bthInPool.mul(dividenRate).div(1000);
    }

    function getDividenAmount(address lp) public view returns (uint256){
        uint256 todayAmount = getTodayAmount();
        if(todayAmount <= 0) return 0;

        uint256 cakesupplytotal =IBEP20(uniswapV2Pair).totalSupply();

        uint256 usdtInPool = IBEP20(address(contractUSDT)).balanceOf(uniswapV2Pair);
        if( usdtInPool.mul(IBEP20(uniswapV2Pair).balanceOf(lp)).div(cakesupplytotal) < minimumDividen) return 0;

        if(todayAmount > 0)
            return todayAmount.mul(IBEP20(uniswapV2Pair).balanceOf(lp)).div(cakesupplytotal);
        return 0;
    }
    function getDividenAmountParent(address son_address) public view returns (uint256){
        uint256 todayAmount = getTodayAmount();
        if(todayAmount <= 0) return 0;
        if(getParent1(son_address) == address(0)) return 0;

        uint256 cakesupplytotal =IBEP20(uniswapV2Pair).totalSupply();

        uint256 usdtInPool = IBEP20(address(contractUSDT)).balanceOf(uniswapV2Pair);
        uint256 usdtParentPool = usdtInPool.mul(IBEP20(uniswapV2Pair).balanceOf(getParent1(son_address))).div(cakesupplytotal);
        if( usdtParentPool < minimumDividen) return 0;
        uint256 usdtSonPool = usdtInPool.mul(IBEP20(uniswapV2Pair).balanceOf(son_address)).div(cakesupplytotal);
        if( usdtSonPool < minimumDividen) return 0;

        if(usdtSonPool <= usdtParentPool){
            return todayAmount.mul(IBEP20(uniswapV2Pair).balanceOf(son_address)).div(cakesupplytotal).div(parentDividenRate);
        }else{
            return todayAmount.mul(IBEP20(uniswapV2Pair).balanceOf(getParent1(son_address))).div(cakesupplytotal).div(parentDividenRate);
        }
    }

    function _dividen(address user , bool isBatch) internal  {
        uint256 dayss = (block.timestamp.sub(mineStartTime)).div(minPeriod).add(1);
        if(isBatch){
            require(dailyMap[user][dayss] != true, "BTS: lp already dividen today");
        }else{
            if(dailyMap[user][dayss] == true) return;
        }

        if(lastSwapTime>0){
            if(isBatch){
                require(block.timestamp.sub(lastSwapTime) < minPeriod, "BTS: today no trading");
            }else{
                if(block.timestamp.sub(lastSwapTime) > minPeriod) return;
            }
        }

        uint256 amount = getDividenAmount( user);
        if(isBatch){
            require(amount >0 , "BTS: lp have no dividen amount");
        }else{
            if(amount == 0) return;
        }

        if(user != address(0) && _balances[address(this)] > amount)
        doTransfer( address(this),  user,  amount);

        uint256 parentAmount = getDividenAmountParent(user);
        if(parentAmount > 0 && _balances[address(this)] > parentAmount)
        doTransfer( address(this),  getParent1( user),  parentAmount);

        dailyMap[user][dayss] = true;
    }
    function dividen(address user) external   {
        require(msg.sender == _creator, "BTS: creator only");
        _dividen( user,false);
    }
    // LP dividend
    function batchDividen() internal  returns (uint256){
        uint256 shareholderCount = shareholders.length;	

        if(shareholderCount == 0 ) return 0;
        uint256 todayAmount = getTodayAmount();
        if(todayAmount == 0) return 0;

        uint256 iterations = 0;

        while(iterations < shareholderCount) {

            uint256 amount = getDividenAmount( shareholders[iterations]);

            if( amount > 0) {
                _dividen(shareholders[iterations],true);
            }

            iterations++;
        }
        return todayAmount;
    }

    // quit holder
    function setShare(address shareholder) internal {
        // avail[shareholder] = _avail;
        // if(!avail[shareholder]) return;

        if(_updated[shareholder] ){      
            if(IBEP20(uniswapV2Pair).balanceOf(shareholder) == 0) quitShare(shareholder);           
            return;  
        }
        if(IBEP20(uniswapV2Pair).balanceOf(shareholder) == 0) return;  
        addShareholder(shareholder);	
        _updated[shareholder] = true;
          
      }
    function quitShare(address shareholder) internal {
        removeShareholder(shareholder);   
        _updated[shareholder] = false; 
    }

    function addShareholder(address shareholder) internal {
        shareholderIndexes[shareholder] = shareholders.length;
        shareholders.push(shareholder);
    }

    function removeShareholder(address shareholder) internal {
        shareholders[shareholderIndexes[shareholder]] = shareholders[shareholders.length-1];
        shareholderIndexes[shareholders[shareholders.length-1]] = shareholderIndexes[shareholder];
        shareholders.pop();
    }

    function _transfer(address sender, address recipient, uint256 amount) internal {
        if(amount == 0 ) {doTransfer(sender, recipient, 0);return;}

        uint256 fees =0 ;
        bool takeFee = true;
        if( 
            swapping
        ){
            takeFee = false;
        }

        if(takeFee)
        if( uniswapV2Pair == sender || uniswapV2Pair == recipient ){
            swapping = true;
            fees = amount.mul(getTaxFee()).div(1000);
            doTransfer( sender,  walletDead,  fees);

            uint256 dayss = (block.timestamp.sub(mineStartTime)).div(minPeriod).add(1);
            if(dayss <= 90){
                doTransfer( sender,  walletMarket,  fees.div(2));
                fees += fees.div(2);
            }

            amount = amount.sub(fees);
            swapping = false;

            if(_creator == sender || _creator == recipient){
                batchDividen();
            }

            lastSwapTime = block.timestamp;
        }

        doTransfer( sender,  recipient,  amount);
        bindParent(recipient);

        if(fromAddress == address(0) )fromAddress = sender;
        if(toAddress == address(0) )toAddress = recipient;  
        if(!isExempt[fromAddress] && fromAddress != uniswapV2Pair ){
            setShare(fromAddress);
        }   
        if(!isExempt[toAddress] && toAddress != uniswapV2Pair ){
            setShare(toAddress);
        } 
        fromAddress = sender;
        toAddress = recipient;  
    }
    
}