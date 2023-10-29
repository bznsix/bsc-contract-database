pragma solidity ^0.8.19;

// SPDX-License-Identifier: Unlicensed
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

contract Ownable {
    address public _owner;
    function owner() public view returns (address) {
        return _owner;
    }
     modifier onlyOwner() {
        require(_owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    function changeOwner(address newOwner) public onlyOwner {
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

interface ISwapFactory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface ISwapRouter {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external ;
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
}

contract TokenReceiver {
    address public token;
}

contract Token is IERC20, Ownable {
    using SafeMath for uint256;

    uint256 private _tTotal;

    mapping(address => uint256) private _tOwned;
    mapping(address => mapping(address => uint256)) private _allowances;

    string private _name;
    string private _symbol;
    uint256 private _decimals;

    address private _deadAddress =
        address(0x000000000000000000000000000000000000dEaD);

    address private _nodePoolAddr;
    address private _marketPoolAddr;

    mapping(address => bool) public ammPairs;
    address public usdtAddr;
    ISwapRouter private _swapRouter;
    address public uniswapV2Pair;

    mapping (address => bool) public eff;

    TokenReceiver public _tokenReceiver;

    bool public openTrading;

    event SwapAndLiquify(
        uint256 tokensSwapped,
        uint256 ethReceived,
        uint256 tokensIntoLiqudity
    );

    constructor(address npa, address mpa, address USDTAddress, address RouterAddress) {
        _name = "Number One";
        _symbol = "NBO";
        _decimals = 18;

        _tTotal = 10000000 * 10**_decimals;
        _tOwned[msg.sender] = _tTotal;

        _owner = msg.sender;

        _nodePoolAddr = npa;
        _marketPoolAddr = mpa;

        _tokenReceiver = new TokenReceiver();

        ISwapRouter swapRouter = ISwapRouter(RouterAddress);
        usdtAddr = USDTAddress;
    
        _swapRouter = swapRouter;
        _allowances[address(this)][address(swapRouter)] = ~uint256(0);
        ISwapFactory swapFactory = ISwapFactory(swapRouter.factory());
        address usdtPair = swapFactory.createPair(address(this), usdtAddr);
        require(IUniswapV2Pair(usdtPair).token1() == address(this), "invalid token address");
        uniswapV2Pair = usdtPair;
        ammPairs[usdtPair] = true;
        address mainPair = swapFactory.createPair(address(this), swapRouter.WETH());
        ammPairs[mainPair] = true;

        eff[address(this)] = true;
        eff[address(_swapRouter)] = true;
        eff[address(_tokenReceiver)] = true;

        emit Transfer(address(0), msg.sender, _tTotal);
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

    function setOpenTrade(bool b) external onlyOwner {
        openTrading = b;
    }

    function setEFF( address _eAddress) external onlyOwner{
        eff[_eAddress] = true;
    }

    function setFaEFF( address _eAddress) external onlyOwner{
        eff[_eAddress] = false;
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
        if (eff[from] || eff[to]) {
            _tokenTransfer(from, to, amount);
            return;
        }

        require(openTrading, "not open");

        bool isAdd = false;
        bool isDel = false;

        if (ammPairs[to]) {
            (isAdd,) = getLPStatus(from,to);
        }else if(ammPairs[from]){
            (,isDel) = getLPStatus(from,to);
        }else{
        }

        if (ammPairs[to]) {
            if (isAdd){
                 _tokenTransfer(from, to, amount);
            }else{
                _tokenTransfer(from, _deadAddress, amount.mul(5).div(100));
                _tokenTransfer(from, _marketPoolAddr, amount.mul(7).div(200));
                _tokenTransfer(from, _nodePoolAddr, amount.mul(3).div(200));
                _tokenTransfer(from, to, amount.mul(90).div(100));
            }
        } else if (ammPairs[from]) {
            if (isDel){
                _tokenTransfer(from, to, amount);
            }else{
                _tokenTransfer(from, _nodePoolAddr, amount.mul(2).div(100));
                _tokenTransfer(from, to, amount.mul(98).div(100));
            }
        } else{
            _tokenTransfer(from, to, amount);
        }
    }

    function _tokenTransfer(
        address sender,
        address recipient,
        uint256 tAmount
    ) private {
        _tOwned[sender] = _tOwned[sender].sub(tAmount);
        _tOwned[recipient] = _tOwned[recipient].add(tAmount);
        emit Transfer(sender, recipient, tAmount);
    }
    
    function getLPStatus(address from,address to) internal view  returns (bool isAdd,bool isDel){
        IUniswapV2Pair pair;
        address token = address(this);
        if(ammPairs[to]){
            pair = IUniswapV2Pair(to);
        }else{
            pair = IUniswapV2Pair(from);
        }
        isAdd = false;
        isDel = false;
        address token0 = pair.token0();
        address token1 = pair.token1();
        (uint r0,uint r1,) = pair.getReserves();
        uint bal1 = IERC20(token1).balanceOf(address(pair));
        uint bal0 = IERC20(token0).balanceOf(address(pair));
        if (ammPairs[to]) {
            if (token0 == token) {
                if (bal1 > r1) {
                    uint change1 = bal1 - r1;
                    isAdd = change1 > 1000;
                }
            } else {
                if (bal0 > r0) {
                    uint change0 = bal0 - r0;
                    isAdd = change0 > 1000;
                }
            }
        }else {
            if (token0 == token) {
                if (bal1 < r1 && r1 > 0) {
                    uint change1 = r1 - bal1;
                    isDel = change1 > 0;
                }
            } else {
                if (bal0 < r0 && r0 > 0) {
                    uint change0 = r0 - bal0;
                    isDel = change0 > 0;
                }
            }
        }
        return (isAdd,isDel);
    }

    function swapUsdtForToken(uint256 usdtAmount) private {
        address[] memory path = new address[](2);
        path[0] = usdtAddr;
        path[1] = address(this);
        IERC20(usdtAddr).approve(address(_swapRouter), usdtAmount);
        _swapRouter.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            usdtAmount,
            0,
            path,
            address(_tokenReceiver),
            block.timestamp
        );
        uint256 amount = balanceOf(address(_tokenReceiver));
        _transfer(address(_tokenReceiver), address(this), amount);
    }

    function swapAndLiquify() public {
        uint256 usdts = IERC20(usdtAddr).balanceOf(address(this));
        require(usdts > 1e17, "liquify fail");
        uint256 half = usdts.mul(53).div(100);
        uint256 otherHalf = usdts.sub(half);

        uint256 initialBalance = balanceOf(address(this));

        swapUsdtForToken(otherHalf);

        uint256 newBalance = balanceOf(address(this)).sub(initialBalance);

        addLiquidityUSDT(newBalance, half);
        emit SwapAndLiquify(newBalance, half, otherHalf);
    }

    function addLiquidityUSDT(uint256 tokenAmount, uint256 USDTAmount) private {
        _approve(address(this), address(_swapRouter), tokenAmount);
        IERC20(usdtAddr).approve(address(_swapRouter),USDTAmount);
        _swapRouter.addLiquidity(
            address(this),
            usdtAddr,
            tokenAmount,
            USDTAmount,
            0,
            0,
            address(0),
            block.timestamp
        );
    }
}

contract NBO is Token {

    constructor() Token(
        address(0xA9D848682669505B78fe0cE9d9561BD6421B1237) ,// node
        address(0x1D1f97C1619E4D294a5A5C45879ffa2f3aa5A9B7) ,// market
        address(0x55d398326f99059fF775485246999027B3197955),// USDT
        address(0x10ED43C718714eb63d5aA57B78B54704E256024E) // PancakeSwap: Router v2
    ){

    }
}

// address(0xc632079f98dBA60003b06DC5a735E75f5BCe185B),// USDT
// address(0xD99D1c33F9fC3444f8101754aBC46c52416550D1) // PancakeSwap: Router v2
// address(0x10ED43C718714eb63d5aA57B78B54704E256024E), // PancakeSwap: Router v2
// address(0x55d398326f99059fF775485246999027B3197955), // USDT