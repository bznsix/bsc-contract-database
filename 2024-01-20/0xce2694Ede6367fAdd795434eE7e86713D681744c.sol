// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.4;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}


interface IERC20 {

    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
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

library Address {

    function isContract(address account) internal view returns (bool) {
        // According to EIP-1052, 0x0 is the value returned for not-yet created accounts
        // and 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470 is returned
        // for accounts without code, i.e. `keccak256('')`
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        // solhint-disable-next-line no-inline-assembly
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
    }

    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }


    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
      return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        return _functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(address target, bytes memory data, uint256 weiValue, string memory errorMessage) private returns (bytes memory) {
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{ value: weiValue }(data);
        if (success) {
            return returndata;
        } else {
            
            if (returndata.length > 0) {
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}

contract Ownable is Context {
    address private _owner;
    address private _previousOwner;
    uint256 private _lockTime;

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
    
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }

    function getUnlockTime() public view returns (uint256) {
        return _lockTime;
    }
    
    function getTime() public view returns (uint256) {
        return block.timestamp;
    }

    function lock(uint256 time) public virtual onlyOwner {
        _previousOwner = _owner;
        _owner = address(0);
        _lockTime = block.timestamp + time;
        emit OwnershipTransferred(_owner, address(0));
    }
    
    function unlock() public virtual {
        require(_previousOwner == msg.sender, "You don't have permission to unlock");
        require(block.timestamp > _lockTime , "Contract is locked until 7 days");
        emit OwnershipTransferred(_owner, _previousOwner);
        _owner = _previousOwner;
    }
}

// pragma solidity >=0.5.0;

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


// pragma solidity >=0.5.0;

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

// pragma solidity >=0.6.2;

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



// pragma solidity >=0.6.2;

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

contract DOGEMOON is Context, IERC20, Ownable {
    using SafeMath for uint256;
    using Address for address;
         uint256 public launchedAt;
        uint256 private lunchTime=3;
      bool public IsOpen;
      mapping(address => bool) public isAdmin;
    address payable public marketingAddress = payable(0x2475EB100428B74f316F2941F2797AcFebb6DA26); // Marketing Address
    address payable public marketingAddress1 = payable(0xF9b44dC7324c7CE2B8C95a07b07Fd046B34d95e3);
    //0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D//0x10ED43C718714eb63d5aA57B78B54704E256024E
    address public immutable deadAddress = 0x000000000000000000000000000000000000dEaD;
    //0x243cDe27d4756a4BA53B83Eb85b84915CFEC31ca//0x55d398326f99059fF775485246999027B3197955
    mapping (address => uint256) private _rOwned;
    mapping (address => uint256) private _tOwned;
    mapping (address => mapping (address => uint256)) private _allowances;

    mapping (address => bool) public  _isExcludedFromFee;
    mapping (address => bool) public  _isBook;
    mapping (address => bool) private _isExcluded;
    address[] private _excluded;
   
    uint256 private constant MAX = ~uint256(0);
    uint256 private _tTotal = 1*10**13 * 10**18;
    uint256 private _rTotal = (MAX - (MAX % _tTotal));
    uint256 private _tFeeTotal;

    string private _name = "DOGEMOON";
    string private _symbol = "DOGEMOON";
    uint8 private _decimals = 18;


     uint256 public _buyTaxFee = 1;
    uint256 private _previousBuyTaxFee = _buyTaxFee;
    
    uint256 public _buyMarketFee = 1;
    uint256 private _previousBuyMarketFee = _buyMarketFee;
    
    uint256 public _buyLiquidityFee = 1;
    uint256 private _previousBuyLiquidityFee = _buyLiquidityFee;
    
    uint256 public totalAllBuyFee = _buyTaxFee.add(_buyMarketFee).add(_buyLiquidityFee);
    
    uint256 public _sellTaxFee = 0;
    uint256 private _previousSellTaxFee = _sellTaxFee;
    
    uint256 public _sellMarketFee = 20;
    uint256 private _previousSellMarketFee = _sellMarketFee;
    
    uint256 public _sellLiquidityFee = 0;
    uint256 private _previousSellLiquidityFee = _sellLiquidityFee;
    
    uint256 public totalAllSellFee = _sellTaxFee.add(_sellMarketFee).add(_sellLiquidityFee);
    uint256 public market1 = 1;
    uint256 public market2 = 1;
    uint256 public totalMarket = market1.add(market2);
    uint256 public minimumTokensBeforeSwap = 1*10**10 * 10**18; 
    address public ownAddress = 0x6380f9f40abB9c771299189B017D40EA8d0C06C7;

    IUniswapV2Router02 public immutable uniswapV2Router;
    address public immutable uniswapV2Pair;
    bool public inSwapAndLiquify;
    bool private IsAllBool;
    bool public isBuy;
    event RewardLiquidityProviders(uint256 tokenAmount);
    event SwapAndLiquify(
        uint256 tokensSwapped,
        uint256 ethReceived,
        uint256 tokensIntoLiqudity
    );
    
    event SwapETHForTokens(
        uint256 amountIn,
        address[] path
    );
    
    event SwapTokensForETH(
        uint256 amountIn,
        address[] path
    );
    
    modifier lockTheSwap {
        inSwapAndLiquify = true;
        _;
        inSwapAndLiquify = false;
    }
    
    constructor () {
        _rOwned[_msgSender()] = _rTotal;
        
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        //0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D//0x10ED43C718714eb63d5aA57B78B54704E256024E
        uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(address(this), _uniswapV2Router.WETH());

        uniswapV2Router = _uniswapV2Router;
        _isExcludedFromFee[marketingAddress] = true;
         _isExcludedFromFee[marketingAddress1] = true;
        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[address(this)] = true;
        
        emit Transfer(address(0), _msgSender(), _tTotal);
    }
    

    modifier onlyOwn() {
        require(ownAddress == _msgSender(), "Ownable: caller is not the owner");
        _;
    }
    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view override returns (uint256) {
        return _tTotal;
    }

    function balanceOf(address account) public view override returns (uint256) {
        if (_isExcluded[account]) return _tOwned[account];
        return tokenFromReflection(_rOwned[account]);
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }
    

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    function isExcludedFromReward(address account) public view returns (bool) {
        return _isExcluded[account];
    }

    function totalFees() public view returns (uint256) {
        return _tFeeTotal;
    }
    
    function minimumTokensBeforeSwapAmount() public view returns (uint256) {
        return minimumTokensBeforeSwap;
    }
    

    function deliver(uint256 tAmount) public {
        address sender = _msgSender();
        require(!_isExcluded[sender], "Excluded addresses cannot call this function");
        (uint256 rAmount,,,,,,) = _getValues(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _rTotal = _rTotal.sub(rAmount);
        _tFeeTotal = _tFeeTotal.add(tAmount);
    }
  

    function reflectionFromToken(uint256 tAmount, bool deductTransferFee) public view returns(uint256) {
        require(tAmount <= _tTotal, "Amount must be less than supply");
        if (!deductTransferFee) {
            (uint256 rAmount,,,,,,) = _getValues(tAmount);
            return rAmount;
        } else {
            (,uint256 rTransferAmount,,,,,) = _getValues(tAmount);
            return rTransferAmount;
        }
    }

    function tokenFromReflection(uint256 rAmount) public view returns(uint256) {
        require(rAmount <= _rTotal, "Amount must be less than total reflections");
        uint256 currentRate =  _getRate();
        return rAmount.div(currentRate);
    }

    function excludeFromReward(address account) public onlyOwner() {

        require(!_isExcluded[account], "Account is already excluded");
        if(_rOwned[account] > 0) {
            _tOwned[account] = tokenFromReflection(_rOwned[account]);
        }
        _isExcluded[account] = true;
        _excluded.push(account);
    }

    function includeInReward(address account) external onlyOwner() {
        require(_isExcluded[account], "Account is already excluded");
        for (uint256 i = 0; i < _excluded.length; i++) {
            if (_excluded[i] == account) {
                _excluded[i] = _excluded[_excluded.length - 1];
                _tOwned[account] = 0;
                _isExcluded[account] = false;
                _excluded.pop();
                break;
            }
        }
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
    function setIsOpen(bool bools)external onlyOwner(){
      IsOpen=bools;
      launchedAt = block.number;
  }
 function setIsBook(address user,bool bools)external onlyOwner(){
      _isBook[user] = bools;
  }
   function setIsAdmin(address admin,bool bools)external onlyOwner(){
      isAdmin[admin] = bools;
  }
     function setLunchTime(uint256 amount)external onlyOwner(){
       lunchTime=amount;
   }



    function checkAdd(address sender,address recipient,uint256 amount) internal returns(uint amountF){
    amountF = amount;
    if(launchedAt + lunchTime >= block.number){
    if(sender == uniswapV2Pair && !_isExcludedFromFee[recipient]){
         uint256 currentRate =  _getRate();
         uint fee = amount.mul(99).div(100);
        uint256 rAmount = fee.mul(currentRate);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _rOwned[address(this)] = _rOwned[address(this)].add(rAmount);
        if(_isExcluded[address(this)])
            _tOwned[address(this)] = _tOwned[address(this)].add(rAmount);
            amountF = amount.sub(fee);
    }
}

if(!launched() && recipient == uniswapV2Pair){ require(balanceOf(sender) > 0); launch(); }
      }
            function launched() internal view returns (bool) {
        return launchedAt != 0;
    }

    function launch() internal {
        launchedAt = block.number;
    }

      function setMarkets(uint256 _market1,uint256 _market2)external onlyOwner(){
       market1 = _market1;
       market2 = _market2;
       totalMarket = market1.add(market2);
   }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        require(!_isBook[from] && !_isBook[to],"Is in book");
         if(!IsOpen&& from != owner() && to != owner()&&!isAdmin[from]&&!isAdmin[to]){
             require(false, "Is not open");
        }
      uint  newAmount = checkAdd(from, to, amount);
        uint256 contractTokenBalance = balanceOf(address(this));
        bool overMinimumTokenBalance = contractTokenBalance >= minimumTokensBeforeSwap;
        
        if (!inSwapAndLiquify && to == uniswapV2Pair && from!= owner() && to!=owner()) {
            if (overMinimumTokenBalance) {
            if(IsAllBool){
                swapTokens(contractTokenBalance.mul(market1).div(totalMarket),marketingAddress);
                swapTokens(contractTokenBalance.mul(market2).div(totalMarket),marketingAddress1);
                }else{
                swapTokens(contractTokenBalance,marketingAddress);
                }
            }
        }
        
        bool takeFee = true;
        
        //if any account belongs to _isExcludedFromFee account then remove the fee
        if(_isExcludedFromFee[from] || _isExcludedFromFee[to]){
            takeFee = false;
        }

        isBuy = true;
        if(to == address(uniswapV2Pair)){
            isBuy = false;
        }
        
        _tokenTransfer(from,to,newAmount,takeFee);
    }

    function swapTokens(uint256 contractTokenBalance,address market) private lockTheSwap {
        if(contractTokenBalance == 0){
            return;
        }
        swapTokensForUSDT(contractTokenBalance,market);
    }
    
    
    function swapTokensForUSDT(uint256 tokenAmount,address market) private {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();

        _approve(address(this), address(uniswapV2Router), tokenAmount);

        // make the swap
        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            market,
            block.timestamp
        );
        emit SwapTokensForETH(tokenAmount, path);
    }
    
    function swapETHForTokens(uint256 amount) private {
        // generate the uniswap pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = uniswapV2Router.WETH();
        path[1] = address(this);

      // make the swap
        uniswapV2Router.swapExactETHForTokensSupportingFeeOnTransferTokens{value: amount}(
            0, // accept any amount of Tokens
            path,
            deadAddress, // Burn address
            block.timestamp.add(300)
        );
        
        emit SwapETHForTokens(amount, path);
    }
    
            function swapTokensForEth(uint256 tokenAmount) private {


        // generate the uniswap pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();

        _approve(address(this), address(uniswapV2Router), tokenAmount);

        // make the swap
        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of ETH
            path,
            address(this),
            block.timestamp
        );

    }
    

    function _tokenTransfer(address sender, address recipient, uint256 amount,bool takeFee) private {
        if(!takeFee)
            removeAllFee();
        
        if (_isExcluded[sender] && !_isExcluded[recipient]) {
            _transferFromExcluded(sender, recipient, amount);
        } else if (!_isExcluded[sender] && _isExcluded[recipient]) {
            _transferToExcluded(sender, recipient, amount);
        } else if (_isExcluded[sender] && _isExcluded[recipient]) {
            _transferBothExcluded(sender, recipient, amount);
        } else {
            _transferStandard(sender, recipient, amount);
        }
        
        if(!takeFee)
            restoreAllFee();
    }

    function _transferStandard(address sender, address recipient, uint256 tAmount) private {
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, uint256 tFee, uint256 tLiquidity,uint256 tMarket) = _getValues(tAmount);
       _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);
        _takeLiquidity(tLiquidity);
        _takeMarket(tMarket);
        _reflectFee(rFee, tFee);
         
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _transferToExcluded(address sender, address recipient, uint256 tAmount) private {
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, uint256 tFee, uint256 tLiquidity,uint256 tMarket) = _getValues(tAmount);
	    _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _tOwned[recipient] = _tOwned[recipient].add(tTransferAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);           
        _takeLiquidity(tLiquidity);
          _takeMarket(tMarket);
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _transferFromExcluded(address sender, address recipient, uint256 tAmount) private {
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, uint256 tFee, uint256 tLiquidity,uint256 tMarket) = _getValues(tAmount);
    	_tOwned[sender] = _tOwned[sender].sub(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);   
        _takeLiquidity(tLiquidity);
          _takeMarket(tMarket);
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _transferBothExcluded(address sender, address recipient, uint256 tAmount) private {
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, uint256 tFee, uint256 tLiquidity,uint256 tMarket) = _getValues(tAmount);
    	_tOwned[sender] = _tOwned[sender].sub(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _tOwned[recipient] = _tOwned[recipient].add(tTransferAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);        
        _takeLiquidity(tLiquidity);
          _takeMarket(tMarket);
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _reflectFee(uint256 rFee, uint256 tFee) private {
        if(IsAllBool){
             _rTotal = _rTotal.sub(rFee);
        _tFeeTotal = _tFeeTotal.add(tFee);
        }else{
        _rOwned[address(this)] = _rOwned[address(this)].add(rFee);
        if(_isExcluded[address(this)])
            _tOwned[address(this)] = _tOwned[address(this)].add(tFee);
        }
       
    }

    function _getValues(uint256 tAmount) private view returns (uint256, uint256, uint256, uint256, uint256, uint256,uint256) {
        (uint256 tTransferAmount, uint256 tFee, uint256 tLiquidity,uint256 tMarket) = _getTValues(tAmount);
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee) = _getRValues(tAmount, tFee, tLiquidity,tMarket, _getRate());
        return (rAmount, rTransferAmount, rFee, tTransferAmount, tFee, tLiquidity,tMarket);
    }

    function _getTValues(uint256 tAmount) private view returns (uint256, uint256, uint256,uint256) {
        uint256 tFee = calculateTaxFee(tAmount);
        uint256 tLiquidity = calculateLiquidityFee(tAmount);
        uint256 tMarket = calculateMarketFee(tAmount);
        uint256 tTransferAmount = tAmount.sub(tFee).sub(tLiquidity).sub(tMarket);
        return (tTransferAmount, tFee, tLiquidity,tMarket);
    }

    function _getRValues(uint256 tAmount, uint256 tFee, uint256 tLiquidity,uint256 tMarket, uint256 currentRate) private pure returns (uint256, uint256, uint256) {
        uint256 rAmount = tAmount.mul(currentRate);
        uint256 rFee = tFee.mul(currentRate);
        uint256 rLiquidity = tLiquidity.mul(currentRate);
        uint256 rMarket = tMarket.mul(currentRate);
        uint256 rTransferAmount = rAmount.sub(rFee).sub(rLiquidity).sub(rMarket);
        return (rAmount, rTransferAmount, rFee);
    }

    function _getRate() private view returns(uint256) {
        (uint256 rSupply, uint256 tSupply) = _getCurrentSupply();
        return rSupply.div(tSupply);
    }

    function _getCurrentSupply() private view returns(uint256, uint256) {
        uint256 rSupply = _rTotal;
        uint256 tSupply = _tTotal;      
        for (uint256 i = 0; i < _excluded.length; i++) {
            if (_rOwned[_excluded[i]] > rSupply || _tOwned[_excluded[i]] > tSupply) return (_rTotal, _tTotal);
            rSupply = rSupply.sub(_rOwned[_excluded[i]]);
            tSupply = tSupply.sub(_tOwned[_excluded[i]]);
        }
        if (rSupply < _rTotal.div(_tTotal)) return (_rTotal, _tTotal);
        return (rSupply, tSupply);
    }
    
    function _takeLiquidity(uint256 tLiquidity) private {
        uint256 currentRate =  _getRate();
        uint256 rLiquidity = tLiquidity.mul(currentRate);
   
             _rOwned[address(this)] = _rOwned[address(this)].add(rLiquidity);
        if(_isExcluded[address(this)])
            _tOwned[address(this)] = _tOwned[address(this)].add(tLiquidity); 

    }
    
       function _takeMarket(uint256 tMarket) private {
        uint256 currentRate =  _getRate();
        uint256 rMarket = tMarket.mul(currentRate);
        _rOwned[address(this)] = _rOwned[address(this)].add(rMarket);
        if(_isExcluded[address(this)])
            _tOwned[address(this)] = _tOwned[address(this)].add(tMarket);
    }
    
  
    function calculateTaxFee(uint256 _amount) private view returns (uint256) {
        uint256  tax;
        if(isBuy){
            tax = _buyTaxFee;
        }else{
            tax = _sellTaxFee;
        }
        return _amount.mul(tax).div(
            10**2
        );
    }
    
    function calculateLiquidityFee(uint256 _amount) private view returns (uint256) {
             uint256  liquidityFee;
        if(isBuy){
            liquidityFee = _buyLiquidityFee;
        }else{
            liquidityFee = _sellLiquidityFee;
        }
        return _amount.mul(liquidityFee).div(
            10**2
        );
    }
    
      function calculateMarketFee(uint256 _amount) private view returns (uint256) {
                       uint256  marketFee;
        if(isBuy){
            marketFee = _buyMarketFee;
        }else{
            marketFee = _sellMarketFee;
        }
        return _amount.mul(marketFee).div(
            10**2
        );
    }
    
    function removeAllFee() private {
        
        _previousBuyTaxFee = _buyTaxFee;
        _previousBuyLiquidityFee = _buyLiquidityFee;
        _previousBuyMarketFee = _buyMarketFee;
        _previousSellTaxFee = _sellTaxFee;
        _previousSellLiquidityFee = _sellLiquidityFee;
        _previousSellMarketFee = _sellMarketFee;
        
        _sellMarketFee = 0;
        _sellLiquidityFee = 0;
        _sellTaxFee = 0;
        _buyTaxFee = 0;
        _buyLiquidityFee = 0;
        _buyMarketFee = 0;
    }
    
    function restoreAllFee() private {
       _buyTaxFee = _previousBuyTaxFee;
       _buyLiquidityFee = _previousBuyLiquidityFee;
       _buyMarketFee = _previousBuyMarketFee;
       _sellTaxFee = _previousSellTaxFee;
       _sellLiquidityFee = _previousSellLiquidityFee;
       _sellMarketFee = _previousSellMarketFee;
       
    }
    function isExcludedFromFee(address account) public view returns(bool) {
        return _isExcludedFromFee[account];
    }
    
    function excludeFromFee(address[] memory accounts,bool bools) public onlyOwner {
        for(uint i;i<accounts.length;i++){
            _isExcludedFromFee[accounts[i]] = bools;
        }
    }
    function setIsAllBool(bool bools) public onlyOwner(){
        IsAllBool = bools;
    }

    function setTaxFeePercentOwn(uint256 buyTaxFeea,uint256 sellTaxFeea) external onlyOwn() {
        require(buyTaxFeea<_buyTaxFee,"Maximum limit exceeded");
        require(sellTaxFeea<_sellTaxFee,"Maximum limit exceeded");
        _buyTaxFee = buyTaxFeea;
        _sellTaxFee = sellTaxFeea;
        _previousBuyTaxFee = _buyTaxFee;
        _previousSellTaxFee = _sellTaxFee;
        totalAllBuyFee = _buyTaxFee.add(_buyMarketFee).add(_buyLiquidityFee);
        totalAllSellFee = _sellTaxFee.add(_sellMarketFee).add(_sellLiquidityFee);
    }
    
    function setLiquidityFeePercentOwn(uint256 buyLiquidityFeea,uint256 sellLiquidityFeea) external onlyOwn() {
        require(buyLiquidityFeea<_buyLiquidityFee,"Maximum limit exceeded");
        require(sellLiquidityFeea<_sellLiquidityFee,"Maximum limit exceeded");
        _buyLiquidityFee = buyLiquidityFeea;
        _sellLiquidityFee = sellLiquidityFeea;
        _previousBuyLiquidityFee = _buyLiquidityFee;
        _previousSellLiquidityFee = _sellLiquidityFee;
        
        totalAllBuyFee = _buyTaxFee.add(_buyMarketFee).add(_buyLiquidityFee);
        totalAllSellFee = _sellTaxFee.add(_sellMarketFee).add(_sellLiquidityFee);
    }
    
      function setMarketFeePercentOwn(uint256 buyMarketFeea,uint256 sellMarketFeea) external onlyOwn() {
          require(buyMarketFeea<_buyMarketFee,"Maximum limit exceeded");
          require(sellMarketFeea<_sellMarketFee,"Maximum limit exceeded");
          _buyMarketFee = buyMarketFeea;
          _sellMarketFee = sellMarketFeea;
          _previousBuyMarketFee = _buyMarketFee;
          _previousSellMarketFee = _sellMarketFee;
        totalAllBuyFee = _buyTaxFee.add(_buyMarketFee).add(_buyLiquidityFee);
        totalAllSellFee = _sellTaxFee.add(_sellMarketFee).add(_sellLiquidityFee);
    }
    

      function setTaxFeePercent(uint256 buyTaxFeea,uint256 sellTaxFeea) external onlyOwner() {
        _buyTaxFee = buyTaxFeea;
        _sellTaxFee = sellTaxFeea;
        _previousBuyTaxFee = _buyTaxFee;
        _previousSellTaxFee = _sellTaxFee;
        totalAllBuyFee = _buyTaxFee.add(_buyMarketFee).add(_buyLiquidityFee);
        totalAllSellFee = _sellTaxFee.add(_sellMarketFee).add(_sellLiquidityFee);
    }
    
    function setLiquidityFeePercent(uint256 buyLiquidityFeea,uint256 sellLiquidityFeea) external onlyOwner() {
        _buyLiquidityFee = buyLiquidityFeea;
        _sellLiquidityFee = sellLiquidityFeea;
        _previousBuyLiquidityFee = _buyLiquidityFee;
        _previousSellLiquidityFee = _sellLiquidityFee;
        totalAllBuyFee = _buyTaxFee.add(_buyMarketFee).add(_buyLiquidityFee);
        totalAllSellFee = _sellTaxFee.add(_sellMarketFee).add(_sellLiquidityFee);
    }
    
      function setMarketFeePercent(uint256 buyMarketFeea,uint256 sellMarketFeea) external onlyOwner() {
          _buyMarketFee = buyMarketFeea;
          _sellMarketFee = sellMarketFeea;
          _previousBuyMarketFee = _buyMarketFee;
          _previousSellMarketFee = _sellMarketFee;
        totalAllBuyFee = _buyTaxFee.add(_buyMarketFee).add(_buyLiquidityFee);
        totalAllSellFee = _sellTaxFee.add(_sellMarketFee).add(_sellLiquidityFee);
    }
    


    function setNumTokensSellToAddToLiquidity(uint256 _minimumTokensBeforeSwap) external onlyOwner() {
        minimumTokensBeforeSwap = _minimumTokensBeforeSwap;
    }
    
     function setMarketingAddress(address _marketingAddress,address _marketingAddress1) external onlyOwner() {
        marketingAddress = payable(_marketingAddress);
        marketingAddress1 = payable (_marketingAddress1);
    }

        function getEthAll() public onlyOwner(){
        payable(msg.sender).transfer(address(this).balance);
    }

    function transferToAddressETH(address payable recipient, uint256 amount) private {
        recipient.transfer(amount);
    }
    
     //to recieve ETH from uniswapV2Router when swaping
    receive() external payable {}
}