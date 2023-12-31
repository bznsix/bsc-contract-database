//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

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

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _transferOwnership(_msgSender());
    }

    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

interface IUniswapV2Factory {
    event PairCreated(
        address indexed token0,
        address indexed token1,
        address pair,
        uint
    );

    function createPair(
        address tokenA,
        address tokenB
    ) external returns (address pair);
}

interface IUniswapV2Router02 {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);

    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}

interface ILottery {
    function updatePlayerData(address account, int256 tokenAmount) external;
    function isOpen() external view returns(bool);
}

contract Maneki is IERC20, Ownable {
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) private _isExcludedFromFee;
    mapping(address => bool) private _isExcludedFromLottery;

    uint256 public constant lotteryFee = 4;
    uint256 public constant burnFee = 1;
    uint256 public constant marketingFee = 1;
    uint256 public constant liquidityFee = 1;
    uint256 public constant totalFee = lotteryFee + burnFee + marketingFee + liquidityFee;
    bool public isTradingEnabled = false;

    ILottery private lottery;
    address private lotteryAddress;
    IUniswapV2Router02 public immutable router;
    address public immutable pair;

    string private constant _name = "Maneki Neko";
    string private constant _symbol = "MANEKI";
    uint8 private constant _decimals = 18;

    uint256 private constant _totalSupply = 1 * 1e9 * 1e18;
    uint256 private constant swapAtAmount = _totalSupply / 5000;

    bool private inSwap;
    modifier swapping {
        inSwap = true;
        _;
        inSwap = false;
    }

    address public constant deadAddress = 0x000000000000000000000000000000000000dEaD;
    address public constant marketingAddress = 0xB61F4F15185c1802952bFeAa1623071CA664fa8a;
    address private constant routerAddress = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    constructor(address _lotteryAddress) {
        lotteryAddress = _lotteryAddress;
        lottery = ILottery(lotteryAddress);
        router = IUniswapV2Router02(routerAddress);
        pair = IUniswapV2Factory(router.factory()).createPair(address(this), router.WETH());
        _allowances[address(this)][address(router)] = type(uint256).max;
        _allowances[address(this)][address(msg.sender)] = type(uint256).max;

        _isExcludedFromFee[msg.sender] = true;
        _isExcludedFromFee[address(this)] = true;
        _isExcludedFromLottery[msg.sender] = true;
        _isExcludedFromLottery[address(this)] = true;

        _balances[msg.sender] = _totalSupply;

        emit Transfer(address(0), msg.sender, _totalSupply);
    }

    receive() external payable {}

    function name() external pure returns (string memory) { return _name; }
    function symbol() external pure returns (string memory) {return _symbol; }
    function decimals() external pure returns (uint8) { return _decimals; }
    function totalSupply() external pure override returns (uint256) { return _totalSupply; }
    function balanceOf(address account) public view override returns (uint256) { return _balances[account]; }
    function allowance(address owner, address spender) external view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function isLotteryOpen() public view returns(bool) {
        return lottery.isOpen();
    }

    function getLotteryAddress() public view returns(address) {
        return lotteryAddress;
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        return _transfer(msg.sender, recipient, amount);
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount ) external override returns (bool) {
        if (_allowances[sender][msg.sender] != type(uint256).max) {
            _allowances[sender][msg.sender] -= amount;
        }

        return _transfer(sender, recipient, amount);
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function changeLotteryAddress(address newAddress) external onlyOwner {
        lotteryAddress = newAddress;
        lottery = ILottery(lotteryAddress);
    }

    function enableTrading() external onlyOwner {
        isTradingEnabled = true;
    }

    function excludeFromFee(address account) external onlyOwner {
        _isExcludedFromFee[account] = true;
    }

    function excludeFromLottery(address account) external onlyOwner {
        _isExcludedFromLottery[account] = true;
    }

    function includeInFee(address account) external onlyOwner {
        _isExcludedFromFee[account] = false;
    }

    function isExcludedFromFee(address account) public view returns (bool) {
        return _isExcludedFromFee[account];
    }

    function isExcludedFromLottery(address account) public view returns (bool) {
        return _isExcludedFromLottery[account];
    }

    function _transfer(address from, address to, uint256 amount) internal returns(bool) {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        if (!_isExcludedFromFee[from]) {
            require(isTradingEnabled, "Trading is not enabled");
        }

        uint256 contractBalance = balanceOf(address(this));
        if (from != pair && !inSwap && contractBalance >= swapAtAmount) {
            swapAndLiquify(contractBalance);
        }

        bool takeFee = !(_isExcludedFromFee[from] || _isExcludedFromFee[to]);
        bool isTrade = from == pair || to == pair;
        uint256 transferAmount = takeFee && isTrade ? getTransferAmountAndTakeFees(amount, from) : amount;

        _balances[from] -= amount;
        _balances[to] += transferAmount;
        emit Transfer(from, to, transferAmount);

        if (isLotteryOpen() && isTradingEnabled && (from == msg.sender || isTrade)) {
            address account = from == pair ? to : from;

            if(!_isExcludedFromLottery[account]) {
                int256 tokenAmount = from == pair ? int256(transferAmount) : -int256(amount);
                lottery.updatePlayerData(account, tokenAmount);
            }
        }

        return true;
    }

    function getTransferAmountAndTakeFees(uint256 amount, address from) internal returns (uint256) {
        uint256 feeAmount = (amount * (totalFee - burnFee)) / 100;
        uint256 burnAmount = (amount * burnFee) / 100;
        uint256 totalFeeAmount = feeAmount + burnAmount;

        if(feeAmount > 0) {
            _balances[address(this)] += feeAmount;
            emit Transfer(from, address(this), feeAmount);
        }

        if(burnAmount > 0) {
            _balances[address(deadAddress)] += burnAmount;
            emit Transfer(from, address(deadAddress), burnAmount);
        }

        return amount - totalFeeAmount;
    }

    function swapAndLiquify(uint256 amount) internal swapping {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = router.WETH();

        uint256 _totalFee = totalFee - burnFee;
        uint256 tokensToLiquify = amount * liquidityFee / _totalFee / 2;
        uint256 amountToSwap = amount - tokensToLiquify;

        uint256 initialBalance = address(this).balance;

        router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            amountToSwap,
            0,
            path,
            address(this),
            block.timestamp
        );

        uint256 newBalance = address(this).balance - initialBalance;
        uint256 liquidityAmount = newBalance * liquidityFee / _totalFee / 2;
        uint256 lotteryAmount = newBalance * lotteryFee / _totalFee;
        uint256 marketingAmount = newBalance * marketingFee / _totalFee;

        router.addLiquidityETH{value: liquidityAmount} (
            address(this),
            tokensToLiquify,
            0,
            0,
            deadAddress,
            block.timestamp
        );

        bool success;
        (success, ) = payable(lotteryAddress).call{value: lotteryAmount, gas: 30000}("");
        (success, ) = payable(marketingAddress).call{value: marketingAmount, gas: 30000}("");
    }
}