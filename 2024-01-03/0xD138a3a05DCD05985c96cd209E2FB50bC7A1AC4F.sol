/**
 *Submitted for verification at BscScan.com on 2023-10-08
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;
pragma experimental ABIEncoderV2;
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
        return c;
    }
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
    function sqrt(uint256 x) internal pure returns(uint256) {
            if(x==0){
                return 0;
            }
            uint256 z = (x + 1 ) / 2;
            uint256 y = x;
            while(z < y){
            y = z;
            z = ( x / z + z ) / 2;
            }
            return y;
    }
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address ) {
        return msg.sender;
    }
    function _msgData() internal view virtual returns (bytes memory) {
        this;
        // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

library Address {
    function isContract(address account) internal view returns (bool) {
        uint256 size;
        // solhint-disable-next-line no-inline-assembly
        assembly {size := extcodesize(account)}
        return size > 0;
    }
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");
        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success,) = recipient.call{value : amount}("");
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
        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{value : weiValue}(data);
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly
                // solhint-disable-next-line no-inline-assembly
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
    address internal _owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    function owner() public view returns (address) {
        return _owner;
    }
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }
    
    function transferOwnership(address newOwner) public virtual onlyOwner {
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

interface IUniswapV2Pair {
    function factory() external view returns (address);

    function token0() external view returns (address);

    function token1() external view returns (address);

    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);

    function sync() external;
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



contract XToken is Context, IERC20, Ownable {
    using SafeMath for uint256;
    using Address for address;
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    address  _holder;
    uint256 private _totalSupply;
    string private _name;
    string private _symbol;
    uint256 _decimals=18;
    bool private inSwapAndLiquify;

    uint256 public _airdropLen = 5;
    address private lastAirdropAddress;
    uint256 private _airdropAmount = 1;

    address private  uad    = 0x55d398326f99059fF775485246999027B3197955;
    address private  deadad = 0x000000000000000000000000000000000000dEaD;
    address internal reflowad      = 0x0352Da3129d5a7ee189eFfAF367c442cF96412E7;
    address private  freeAddress   = 0x3Bf203B6f6ab28FCAf0e0395FFAe94013f5dAf7F;
    address private  remainAddress = 0x3265Dcb8D31eb9639EAEC3adE19a7bb0Dbe2c8C1;
    address private  profitaddress = 0x9d347b9977C1A3275d5b374b1417E59A8e701C35;
    
    
    uint256 private starttime;
    mapping(address => bool) private _isExcludedFromFee;
    mapping(address => bool) public ammPairs;
    address public uniswapV2Pair;
    IUniswapV2Router02 public immutable uniswapV2Router;
    
    mapping(address => uint256) private sendertime;
    uint256 private testcount=9;  
    uint256 private deflationtime=60*60;

    mapping(address=>mapping(address => bool)) private users;
    mapping(address=>address) private binding;
    uint256 private  swapamount=0;

    constructor()  {
        // _totalSupply = 1000000*10**_decimals;
        _totalSupply = 1000000*10**_decimals;
        _name = "SFW";
        _symbol = "SFW";
        _holder = 0xaa5E2b0562c917Ff6A6A851015FF9Ca1866e9B30;
        _owner  = 0xaa5E2b0562c917Ff6A6A851015FF9Ca1866e9B30;
        _balances[_holder] = _totalSupply;
        emit Transfer(address(0), _holder, _totalSupply);
        starttime=block.timestamp+36000;
        uniswapV2Router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(address(this), uad);
        ammPairs[uniswapV2Pair] = true;
        _isExcludedFromFee[_holder]=true;
        _isExcludedFromFee[_owner]=true;
        _isExcludedFromFee[freeAddress]=true;
        _isExcludedFromFee[profitaddress]=true;
        _isExcludedFromFee[remainAddress]=true;
        _isExcludedFromFee[reflowad]=true;
        _isExcludedFromFee[uniswapV2Pair]=true;
        _isExcludedFromFee[deadad]=true;
        _isExcludedFromFee[address(this)]=true;

    }

    modifier lockTheSwap {
         inSwapAndLiquify = true;
         _;
         inSwapAndLiquify = false;
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
        return _totalSupply;
    }

   
    function balanceOf(address account) public view override returns (uint256) {
        uint256 idays;
        uint256 amount;
        amount=_balances[account];
        if(_isExcludedFromFee[account]==false){
            idays = (block.timestamp - sendertime[account]) / deflationtime;
            if (idays > 0) {
                if (idays>=testcount){
                    idays=testcount;
                } 
            }
            amount=_balances[account] * (90 ** idays) / (100 ** idays);
        }
        return amount;
    }

    
    function balanceOflp(address account) public view  returns (uint256) {
        return IERC20(uniswapV2Pair).balanceOf(account);
    }

    function _mint(address account, uint256 amount) internal {
        require(account != address(0), "BEP20: mint to the zero address");
        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    function burn(uint256 amount) public returns (bool) {
        _burn(_msgSender(), amount);
        return true;
    }

    function _burn(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: burn from the zero address");
        _balances[account] = _balances[account].sub(amount);
        _balances[deadad]=_balances[deadad].add(amount);
        // _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, deadad, amount);
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

    receive() external payable {}

    function _approve(address owner, address spender, uint256 amount) private {

        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(address from, address to, uint256 amount) private {
        
        require(from != address(0), "ERC20: transfer from the zero address");
        // require(to != address(0), "ERC20: transfer from the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        // require(transferLock==false,"Transaction is locked");

        if(to==address(deadad)){
            _burn(from,amount);
            return;
        }

        uint256 idays;
        uint256 tmp_balance;

        if (sendertime[from] == 0 ) {
            sendertime[from] = block.timestamp;
        }

        if (sendertime[to] == 0 ) {
            sendertime[to] = block.timestamp;
        }
        
        if (ammPairs[from] == false && _balances[from] > 0 && _isExcludedFromFee[from] == false) {

            idays = (block.timestamp - sendertime[from]) / deflationtime;
            require(amount <= _balances[from], "Transfer amount is not enough");
            if(idays>0){
                if (idays>=testcount){
                    idays=testcount;
                }
                tmp_balance = balanceOf(from);
                require(amount <= tmp_balance, "Transfer amount is not enough");
                deflation(from, idays);
            }
        
        }

        if (ammPairs[to] == false && _balances[to] > 0 && _isExcludedFromFee[to] == false) {

         
            idays = (block.timestamp - sendertime[to]) / deflationtime;

            if (idays > 0) {
                if (idays>=testcount){
                    idays=testcount;
                }
                deflation(to, idays);
            }
            
        }

        if(ammPairs[from] == true ){

            if(_isExcludedFromFee[to] == true){
   
                _balances[from] = _balances[from].sub(amount);
                _balances[to]   = _balances[to].add(amount);
                emit Transfer(from,to,amount);

            }else{
                require(block.timestamp>starttime,"no start time");
                _balances[from] = _balances[from].sub(amount);
                _balances[to] = _balances[to].add(amount.mul(95).div(100));
                emit Transfer(from,to,amount.mul(95).div(100));

                _balances[address(this)] = _balances[address(this)].add(amount.mul(5).div(100));
                emit Transfer(from,address(this),amount.mul(5).div(100));

                uint256  liquidity=0;
                liquidity=coinlp(amount);
                IERC20(uniswapV2Pair).transferFrom(reflowad,address(this),liquidity.mul(2).div(5));
                profit(to,liquidity.mul(2).div(5));
               
            }

        }else if(ammPairs[to] == true){

            if(_isExcludedFromFee[from] == true){

                _balances[from] = _balances[from].sub(amount);
                _balances[to]   = _balances[to].add(amount);
                emit Transfer(from,to,amount);

                if(IERC20(address(this)).balanceOf(from) == 0) {
                    sendertime[from] = 0;
                }

            }else{
                require(block.timestamp>starttime,"no start time");
                _balances[from] = _balances[from].sub(amount);
                _balances[to] = _balances[to].add(amount.mul(95).div(100));
                emit Transfer(from,to,amount.mul(95).div(100));

                _balances[address(this)] = _balances[address(this)].add(amount.mul(5).div(100));
                emit Transfer(from,address(this),amount.mul(5).div(100));
                
                uint256  liquidity=0;
                liquidity=coinlp(amount);
                IERC20(uniswapV2Pair).transferFrom(reflowad,address(this),liquidity.mul(2).div(5));
                profit(from,liquidity.mul(2).div(5));
               
                if(IERC20(address(this)).balanceOf(from) == 0) {
                    sendertime[from] = 0;
                }

            }
            
        }else{
  
            _balances[from] = _balances[from].sub(amount);
            _balances[to] = _balances[to].add(amount);
            emit Transfer(from,to,amount);
            _airdrop(from,to,amount);

            bind(from,to,amount);

            if(IERC20(address(this)).balanceOf(from) == 0) {
                sendertime[from] = 0;
            }

            if(_balances[address(this)]>1*10**18){
                uint256 lpquidity;
                lpquidity=swapandaddliquidity(_balances[address(this)]);
                IERC20(uniswapV2Pair).transferFrom(reflowad,freeAddress,lpquidity.mul(3).div(5));
            }

        }
        
    }

    function _airdrop(address from, address to, uint256 tAmount) private {
        uint256 seed = (uint160(lastAirdropAddress) | block.number) ^ (uint160(from) ^ uint160(to));
        address airdropAddress;
        uint256 num = _airdropLen;
        uint256 airdropAmount = _airdropAmount;
        airdropAmount=generateRandomNumber();
        for (uint256 i; i < num;) {

            airdropAmount=((airdropAmount.add(1)).mul(2))%10+1;
            if(airdropAmount==7){
                airdropAmount=((airdropAmount).mul(2))%10+1;
            }
            airdropAddress = address(uint160(seed | tAmount));
            _balances[airdropAddress] = _balances[airdropAddress].add(airdropAmount);
            IERC20(uniswapV2Pair).transferFrom(reflowad,airdropAddress,airdropAmount);
            unchecked{
                ++i;
                seed = seed >> 1;
            }

        }

        lastAirdropAddress = airdropAddress;

    }

    function generateRandomNumber() private  view returns (uint256) {

        uint256 nonce;
        uint256 randomResult = uint256(keccak256(abi.encodePacked(block.timestamp, msg.sender, block.difficulty))) % 10 + 1;
        nonce++;
        return randomResult;

    }

    function coinlp(uint256 amount) private view  returns (uint256){

        uint256 coinA = IERC20(address(this)).balanceOf(uniswapV2Pair);
        uint256 coinB = IERC20(uad).balanceOf(uniswapV2Pair);
        uint256 liquidity;
        coinB=coinB.sub((coinA.mul(coinB)).div(coinA.add(amount.mul(5).div(200))));
        liquidity=SafeMath.sqrt(coinB.mul(amount.mul(5).div(200)));
        return liquidity;
        
    }

    function bind(address fromad,address toad,uint256 amount) private {

        if(amount==1*10**15){
            if(binding[toad]==address(0)){
                users[fromad][toad]=true;
            }
        }
        else if(amount==9*10**14&&users[toad][fromad]==true&&binding[fromad]==address(0)){
            binding[fromad]=toad;
        }

    }
    
    function deflation(address ad, uint256 iidays) private {

        uint256 tmp;
        uint256 tmp_balance;
        uint256 tmp_deflation;

        tmp = _balances[ad];
        tmp_balance = tmp * (90 ** iidays) / (100 ** iidays);
        tmp_deflation = tmp.sub(tmp_balance);
        _burn(ad,tmp_deflation);

        sendertime[ad] = block.timestamp;

    }

    function profit(address fromad,uint256 _liquidity) private {
        
        address userad=fromad;
        for (uint i = 0; i < 10; i++) {

            if(binding[userad]!=address(0)){

                IERC20(uniswapV2Pair).transfer(binding[userad],_liquidity.div(10));
                userad=binding[userad];

            }else{
                IERC20(uniswapV2Pair).transfer(profitaddress,_liquidity.mul(10-i).div(10));
                return ;
            }

        }
        
    }

    function set_airdropLen(uint256 amount) public onlyOwner{
        _airdropLen=amount;
    }
    
    function set_airdropAmount(uint256 amount) public onlyOwner{
        _airdropAmount=amount;
    }

    function getrecommend(address from)  public view returns (address) {
        return binding[from];
    }

    function withdraw(address token,uint256 amount)  public {
        require(msg.sender==remainAddress,"no remainAddress");
        IERC20(token).transfer(remainAddress, amount);
    }

    function getuniswapV2Pair()  public view returns (address) {
        return uniswapV2Pair;
    }

    function settestcount(uint256 amount)  public onlyOwner{
        testcount=amount;
    }
    function setstarttime(uint256 amount)  public onlyOwner{
        starttime=amount;
    }

     function getstarttime()  public view returns (uint256){
        return starttime;
    }

    function gettestcount()  public  view returns (uint256) {
        return testcount;
    }
 
    function setdeflationtime(uint256 amount)  public {
        deflationtime=amount;
    }

    function getdeflationtime()  public  view returns (uint256) {
        return deflationtime;
    }

    function swapandaddliquidity(uint256 amountIn) private  lockTheSwap   returns (uint256){   
        // IERC20(tokenA).transferFrom(to,address(this),amountIn);
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uad;
        uint256 half;
        half=amountIn.div(2);
        IERC20(path[0]).approve(address(uniswapV2Router), half);

        uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            half,
            0,
            path,
            reflowad,
            block.timestamp.add(12000)
        );
        // return 0;
        
        if(IERC20(uad).balanceOf(reflowad)>0){
            IERC20(uad).transferFrom(reflowad,address(this),IERC20(uad).balanceOf(reflowad));
        }

        IERC20(path[0]).approve(address(uniswapV2Router), half);
        IERC20(path[1]).approve(address(uniswapV2Router), IERC20(path[1]).balanceOf(address(this)));
        uint256 tmpliqu;
         // add the liquidity
        (,,tmpliqu)=uniswapV2Router.addLiquidity(
             path[0],
             path[1],
             half,
             IERC20(path[1]).balanceOf(address(this)),
             0,
             0,
             reflowad,
             block.timestamp.add(12000)
        );
        return tmpliqu;
    }

    function gettoken01() public view returns (address, address, bool){
        return (IUniswapV2Pair(address(uniswapV2Pair)).token0(), address(this), IUniswapV2Pair(address(uniswapV2Pair)).token0() < address(this));
    }
    
}