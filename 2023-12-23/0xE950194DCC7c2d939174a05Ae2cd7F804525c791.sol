/**
 *Submitted for verification at Etherscan.io on 2022-08-23
*/
// SPDX-License-Identifier: MIT
pragma solidity ^0.6.12;
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
}
abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
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
interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB)
    external
    returns (address pair);
}

interface IUniswapV2Router02 {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;

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
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external
    returns (
        uint256 amountA,
        uint256 amountB,
        uint256 liquidity
    );
}
interface IUniswapV2Pair {
    function factory() external view returns (address);

    function token0() external view returns (address);

    function token1() external view returns (address);

    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);

    function sync() external;
}
contract XToken is Context, IERC20, Ownable {

    using SafeMath for uint256;
    using Address for address;
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) private _isExcludedFromFee;
    
    address  _holder;
    uint256 private _totalSupply;
    string private _name;
    string private _symbol;
    uint256 _decimals=18;

    address private lpaddress;
    IUniswapV2Router02 public uniswapV2Router;
    mapping(address => bool) public ammPairs;

    address private deadad=0x000000000000000000000000000000000000dEaD;

    address private uad;
    mapping(address=>uint256) private usersharelp;
    uint256[] private sharedetaillp;
    uint256 private lpaward;
    uint256 private maxfenhonglp=10000*10**18;
    address public uniswapV2Pair;


    constructor() public {

        _totalSupply = 900000000000*10**_decimals;
        _name = "FG";
        _symbol = "FG";
        _holder = 0x088e1213809DC4Fddd73E004247079C2541B5bDe;
        _owner = 0x088e1213809DC4Fddd73E004247079C2541B5bDe;
        
        _balances[_holder] = _totalSupply;
        emit Transfer(address(0), _holder, _totalSupply);

        sharedetaillp.push(0);

        // uad=0xc216c876f9b5373dE441A0504916141948afc711;//dev
        uad=0x55d398326f99059fF775485246999027B3197955;

        uniswapV2Router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        // uniswapV2Router = IUniswapV2Router02(0xD99D1c33F9fC3444f8101754aBC46c52416550D1);//dev
        uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(address(this), uad);
        lpaddress=address(uniswapV2Pair);

        ammPairs[uniswapV2Pair] = true;
    }
    
    
     function _isLiquidity(address from, address to) internal view returns (bool isAdd, bool isDel, bool isSell, bool isBuy){
        address token0 = IUniswapV2Pair(address(uniswapV2Pair)).token0();
        (uint r0,,) = IUniswapV2Pair(address(uniswapV2Pair)).getReserves();
        uint bal0 = IERC20(token0).balanceOf(address(uniswapV2Pair));

        
        if (ammPairs[to]) {
            if (token0 != address(this) && bal0 > r0) {
                isAdd = bal0 - r0 > 0;
            }
            if (!isAdd) {
                isSell = true;
            }
        }
        if (ammPairs[from]) {
            if (token0 != address(this) && bal0 < r0) {
                isDel = r0 - bal0 > 0;
            }
            if (!isDel) {
                isBuy = true;
            }
        }
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
        return _balances[account];
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
        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
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
        (bool isAdd,bool isDel, bool isSell, bool isBuy) = _isLiquidity(from, to);

         if(ammPairs[from]==false) {
            divshare();
            shareoutbonus(from);
            setshare(from);
         }

        if(ammPairs[to]==false) {
            divshare();
            shareoutbonus(to);
            setshare(to);
         }
    
        if(isAdd==true){

            _balances[from] = _balances[from].sub(amount);
            _balances[to] = _balances[to].add(amount);
            emit Transfer(from,to,amount);

            if(usersharelp[from]==0){
                usersharelp[from]=sharedetaillp.length-1;
            }
            

        }else if(isDel==true){

            _balances[from] = _balances[from].sub(amount);
            _balances[to] = _balances[to].add(amount);
            emit Transfer(from,to,amount);
             if(IERC20(lpaddress).balanceOf(to)<1000){
                usersharelp[to]=0;
            }
        }else if(isSell==true){

            _balances[from] = _balances[from].sub(amount);
            _balances[to] = _balances[to].add(amount.mul(95).div(100));
            emit Transfer(from,to,amount.mul(95).div(100));

            _balances[address(this)]=_balances[address(this)].add(amount.mul(5).div(100));
            lpaward=lpaward.add(amount.mul(5).div(100));
            emit Transfer(from,address(this),amount.mul(5).div(100));
            

        }else if(isBuy==true){

            _balances[from] = _balances[from].sub(amount);
            _balances[to] = _balances[to].add(amount.mul(95).div(100));
            emit Transfer(from,to,amount.mul(95).div(100));

            _balances[address(this)]=_balances[address(this)].add(amount.mul(5).div(100));
            lpaward=lpaward.add(amount.mul(5).div(100));
            emit Transfer(from,address(this),amount.mul(5).div(100));
                
        }else{

            _balances[from] = _balances[from].sub(amount);
            _balances[to] = _balances[to].add(amount);
            emit Transfer(from,to,amount);
    
        }
        
    }

    function divshare() private{
        if (lpaward >= maxfenhonglp ) {
            uint256 tmp = (lpaward.mul(1e18)).div(IERC20(lpaddress).totalSupply());
            if(tmp>0){
               sharedetaillp.push(tmp);
               lpaward = 0;
            }
        }
    }

    function shareoutbonus(address owner) private {

        uint256 lpvalue = IERC20(lpaddress).balanceOf(owner);
        if (lpvalue > 0) {
            uint256 tmp;

            if (usersharelp[owner] < sharedetaillp.length-1) {
                for (uint256 i = usersharelp[owner]+1; i < sharedetaillp.length; i++) {
                    tmp = tmp.add((sharedetaillp[i]).mul(lpvalue).div(1e18));
                }
                _balances[address(this)]=_balances[address(this)].sub(tmp);
                _balances[owner]=_balances[owner].add(tmp);
                emit Transfer(address(this),owner,tmp);
                usersharelp[owner] = sharedetaillp.length-1;
            }
            
        }

    }

    function setshare(address owner) private {
        uint lpAmount = IERC20(lpaddress).balanceOf(owner);
        if(lpAmount>0){
            usersharelp[owner]=sharedetaillp.length-1;
        }else if(lpAmount==0){
            usersharelp[owner]=0;
        }
    }

    function excludeFromFee(address[] memory accounts) public onlyOwner {
        for (uint i = 0; i < accounts.length; i++) {
            _isExcludedFromFee[accounts[i]] = true;
        }
    }
    function includeInFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = false;
    }
    function isExcludedFromFee(address account) public view returns (bool) {
        return _isExcludedFromFee[account];
    }

    function setlpaddress(address _lpaddress) public onlyOwner {
        lpaddress = _lpaddress;
    }

    function getlpamount() public view returns (uint256) {
        return IERC20(lpaddress).totalSupply();
    }
    function getusersharelp(address account) public view returns (uint256) {
        return usersharelp[account];
    }

    function getsharelpline(uint i) public view returns (uint256) {
        return sharedetaillp[i];
    }

    function gettoken01() public view returns (address, address, bool){
        return (IUniswapV2Pair(address(uniswapV2Pair)).token0(), address(this), IUniswapV2Pair(address(uniswapV2Pair)).token0() < address(this));
    }
}