// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

interface IERC20 {
    function decimals() external view returns (uint8);

    function symbol() external view returns (string memory);

    function name() external view returns (string memory);

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface ISwapRouter {
    function factory() external pure returns (address);
}

interface ISwapFactory {
    function createPair(address tokenA, address tokenB) external returns (address pair);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
}

interface IUniswapV2Pair {
    function factory() external view returns (address);

    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);

    function sync() external;
}


abstract contract Ownable {
    address internal _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        address msgSender = msg.sender;
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == msg.sender, "!owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "new is 0");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}


abstract contract BaseToken is IERC20, Ownable {
    uint8 private constant _decimals = 18;

    uint256 private _totalSupply;
    uint256 private constant MAX = ~uint256(0);
    uint256 private _addPriceTokenAmount;
    uint256 private _burnAmount;
    uint256 private _burnAmountUplimit;

    ISwapRouter private _swapRouter;
    address private _marketAddress;
    address private _communityAddress;
    address private _usdtAddress;
    address private _usdtPairAddress;

    string private _name;
    string private _symbol;
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) private _swapPairMap;
    mapping(address => bool) private _matrixMap;


    constructor (string memory Name, string memory Symbol, address RouterAddress, address UsdtAddress, address marketAddress, address communityAddress){
        _name = Name;
        _symbol = Symbol;
        ISwapRouter swapRouter = ISwapRouter(RouterAddress);
        _usdtAddress = UsdtAddress;
        _swapRouter = swapRouter;
        _allowances[address(this)][RouterAddress] = MAX;

        ISwapFactory swapFactory = ISwapFactory(swapRouter.factory());
        _usdtPairAddress = swapFactory.createPair(UsdtAddress, address(this));
        _swapPairMap[_usdtPairAddress] = true;

        uint256 total = 110000000 * 1e18;
        _totalSupply = total;

        _balances[msg.sender] = 100000000 * 1e18;
        emit Transfer(address(0), msg.sender, 100000000 * 1e18);

        _balances[marketAddress] = 5000000 * 1e18;
        emit Transfer(address(0), marketAddress, 5000000 * 1e18);

        _balances[communityAddress] = 5000000 * 1e18;
        emit Transfer(address(0), communityAddress, 5000000 * 1e18);

        _addPriceTokenAmount = 1e14;
        _burnAmountUplimit = 21000000 * 1e18;
    }

    function getAllParam() external view returns (address pairAddress, address routerAddress, address usdtAddress, address marketAddress, address communityAddress,
        uint addPriceTokenAmount, uint burnAmountUplimit, uint burnAmount){
        pairAddress = _usdtPairAddress;
        routerAddress = address(_swapRouter);
        usdtAddress = _usdtAddress;
        marketAddress = _marketAddress;
        communityAddress = _communityAddress;
        addPriceTokenAmount = _addPriceTokenAmount;
        burnAmountUplimit = _burnAmountUplimit;
        burnAmount = _burnAmount;
    }

    function userInfo(address account) external view returns (uint lpBalance, uint usdtBalance, uint tokenBalance) {
        lpBalance = IERC20(_usdtPairAddress).balanceOf(account);
        uint lpTotalSupply = IERC20(_usdtPairAddress).totalSupply();
        (uint r0,uint r1,) = IUniswapV2Pair(_usdtPairAddress).getReserves();
        if (address(this) < _usdtAddress) {usdtBalance = lpBalance * r1 / lpTotalSupply;
            tokenBalance = lpBalance * r0 / lpTotalSupply;
        } else {usdtBalance = lpBalance * r0 / lpTotalSupply;
            tokenBalance = lpBalance * r1 / lpTotalSupply;
        }
    }

    function poolInfo() external view returns (uint lpTotalSupply, uint tokenPrice, uint usdtAmount, uint tokenAmount) {
        lpTotalSupply = IERC20(_usdtPairAddress).totalSupply();
        (uint r0,uint r1,) = IUniswapV2Pair(_usdtPairAddress).getReserves();
        if (address(this) < _usdtAddress) {usdtAmount = r1;
            tokenAmount = r0;
            tokenPrice = r1 * 1e18 / r0;
        } else {usdtAmount = r0;
            tokenAmount = r1;
            tokenPrice = r0 * 1e18 / r1;
        }
    }

    function symbol() external view override returns (string memory) {
        return _symbol;
    }

    function name() external view override returns (string memory) {
        return _name;
    }

    function decimals() external pure override returns (uint8) {
        return _decimals;
    }

    function totalSupply() external view override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) external view override returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) external override returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) external view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) external override returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        _transfer(sender, recipient, amount);
        if (_allowances[sender][msg.sender] != MAX) {
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender] - amount;
        }
        return true;
    }

    function _approve(address owner, address spender, uint256 amount) private {
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _isLiquidity(address from, address to) internal view returns (bool isAdd, bool isDel){
        (uint r0,uint r1,) = IUniswapV2Pair(_usdtPairAddress).getReserves();
        uint rUsdt = r0;
        uint bUsdt = IERC20(_usdtAddress).balanceOf(_usdtPairAddress);
        if (address(this) < _usdtAddress) {rUsdt = r1;}
        if (_swapPairMap[to]) {if (bUsdt >= rUsdt) {
            isAdd = bUsdt - rUsdt >= _addPriceTokenAmount;}
        }
        if (_swapPairMap[from]) {isDel = bUsdt <= rUsdt;}
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {
        require(amount > 0, "transfer amount must be >0");
        bool isAddLiquidity;
        bool isDelLiquidity;
        (isAddLiquidity, isDelLiquidity) = _isLiquidity(from, to);

        if (isAddLiquidity || isDelLiquidity) {
            _tokenTransfer(from, to, amount);
        } else if (_swapPairMap[from] || _swapPairMap[to]) {
            if (_swapPairMap[from]) {if (_matrixMap[to]) {
                _tokenTransfer(from, to, amount);
            } else {
                _tokenTransfer(from, address(0), amount);}
            } else {uint feeAmount = amount / 10;
                uint remainBurnAmount;
                uint backpoolAmount;
                if (_burnAmountUplimit > _burnAmount) remainBurnAmount = _burnAmountUplimit - _burnAmount;

                if (remainBurnAmount > feeAmount) remainBurnAmount = feeAmount; else backpoolAmount = feeAmount - remainBurnAmount;

                if (remainBurnAmount > 0) {
                    _tokenTransfer(from, address(0), remainBurnAmount);
                    _burnAmount += remainBurnAmount;
                }
                if (backpoolAmount > 0) {
                    _tokenTransfer(from, address(this), backpoolAmount);}
                _tokenTransfer(from, to, amount - feeAmount);
            }
        } else {
            _tokenTransfer(from, to, amount);

            if (_balances[address(this)] > 0) {
                _tokenTransfer(address(this), _usdtPairAddress, _balances[address(this)]);
                IUniswapV2Pair(_usdtPairAddress).sync();
            }
        }
    }

    function _tokenTransfer(
        address sender,
        address recipient,
        uint256 tAmount
    ) private {
        _balances[sender] = _balances[sender] - tAmount;
        _balances[recipient] = _balances[recipient] + tAmount;
        emit Transfer(sender, recipient, tAmount);
    }

    function setSwapPairMap(address addr, bool enable) external onlyOwner {
        _swapPairMap[addr] = enable;
    }

    function setMatrixAddr(address addr, bool enable) external onlyOwner {
        _matrixMap[addr] = enable;
    }

    function setAddPriceTokenAmount(uint amount) external onlyOwner {
        _addPriceTokenAmount = amount;
    }

    function setBurnAmountUplimit(uint amount) external onlyOwner {
        _burnAmountUplimit = amount;
    }
}

contract VCC is BaseToken {
    constructor() BaseToken(
    "VeloCity Community",
    "VCC",
    address(0x10ED43C718714eb63d5aA57B78B54704E256024E),
    address(0x55d398326f99059fF775485246999027B3197955),
    address(0xFca29f6F9fe0D8fb3eC373Fe8B8B9DF6a0D046D0),
    address(0xDC3D7e07dE4a4220711fB34476Ea5dFB10538002)){

    }
}