//FLORK METAVERSE

// TELEGRAM: https://t.me/FlorkMetaGroup
// WebSite: https://www.florkmetaverse.net/
// TWITTER: https://twitter.com/CoinFlork
// FACEBOOK: https://www.facebook.com/FlorkCoin

// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.18;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
}

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

contract Ownable is Context {
    address private _owner;
    address private _previousOwner;
    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
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

    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }
}

interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);
}

interface IUniswapV2Router02 {
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

contract FlorkMetaverseToken is Context, IERC20, Ownable {
    uint256 private _totalSupply = 6_222_222_222_222 * 10**18;
    uint256 private constant onePercent = 6_222_222_222_222 * 10**18;
    uint256 private constant minSwap = 1_000_000_000e18;
    uint8 private constant _decimals = 18;

    IUniswapV2Router02 immutable uniswapV2Router;
    address immutable uniswapV2Pair;
    address immutable WETH;
    address payable immutable marketingWallet;

    uint256 public buyTax;
    uint256 public sellTax;

    uint8 private launch;
    uint8 private inSwapAndLiquify;

    uint256 private launchBlock;
    uint256 public maxTxAmount = onePercent;

    string private constant _name = "Flork Metaverse Token";
    string private constant _symbol = "FLORK";

    mapping(address => uint256) private _balance;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) private _isWhiteLists;
    mapping(address => bool) private controllers;

    uint256 private MAXSUP;
    uint256 public MAXIMUMSUPPLY = 77_777_777_777_777 * 10**18;
    uint256 private currentSupply;
    bool private maxSupplyReached;

    event TaxRateChanged(uint256 newBuyTax, uint256 newSellTax);
    event IncreaseHolders(address indexed wallet, uint256 amount);

    constructor() {
        currentSupply = _totalSupply;
        maxSupplyReached = false;
        uniswapV2Router = IUniswapV2Router02(
            0x10ED43C718714eb63d5aA57B78B54704E256024E
        );
        WETH = uniswapV2Router.WETH();
        buyTax = 3;
        sellTax = 10;

        uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(
                address(this),
                WETH
            );
        marketingWallet = payable(0xc89092AF9b03cDB661934A8FCeb15d8Cae542243);
        _balance[msg.sender] = _totalSupply;
        _isWhiteLists[marketingWallet] = true;
        _isWhiteLists[msg.sender] = true;
        _isWhiteLists[address(this)] = true;
        _allowances[address(this)][address(uniswapV2Router)] = type(uint256)
            .max;
        _allowances[msg.sender][address(uniswapV2Router)] = type(uint256).max;
        _allowances[marketingWallet][address(uniswapV2Router)] = type(uint256)
            .max;

        emit Transfer(address(0), _msgSender(), _totalSupply);
    }

    function name() public pure returns (string memory) {
        return _name;
    }

    function symbol() public pure returns (string memory) {
        return _symbol;
    }

    function decimals() public pure returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balance[account];
    }

    function transfer(address recipient, uint256 amount)
        public
        override
        returns (bool)
    {
        _transfer(_msgSender(), recipient, amount);
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
        _approve(_msgSender(), spender, amount);
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
            _msgSender(),
            _allowances[sender][_msgSender()] - amount
        );
        return true;
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) private {
        require(owner != address(0), " ");
        require(spender != address(0), " ");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function mint(address to, uint256 amount) external onlyController {
        require(!maxSupplyReached, "Maximum supply has been reached");
        require(
            currentSupply + amount <= MAXIMUMSUPPLY,
            "Exceeds maximum supply"
        );

        _balance[to] += amount;
        currentSupply += amount;
        _totalSupply += amount;
        emit Transfer(address(0), to, amount);

        if (currentSupply >= MAXIMUMSUPPLY) {
            maxSupplyReached = true;
        }
    }

    function maxSupply() public view returns (uint256) {
        return MAXIMUMSUPPLY;
    }

    function openTrading() external onlyController {
        launch = 1;
        launchBlock = block.number;
    }

    function addToWhiteList(address wallet) external onlyController {
        _isWhiteLists[wallet] = true;
    }

    function removeFromWhiteList(address wallet) external onlyController {
        _isWhiteLists[wallet] = false;
    }

    function removeLimits() external onlyController {
        maxTxAmount = _totalSupply;
    }

    function changeTax(uint256 newBuyTax, uint256 newSellTax)
        external
        onlyController
    {
        buyTax = newBuyTax;
        sellTax = newSellTax;
    }

    modifier onlyController() {
        require(controllers[msg.sender], "Only controllers can call this");
        _;
    }

    function addController(address controller) external onlyOwner {
        controllers[controller] = true;
    }

    function removeController(address controller) external onlyOwner {
        controllers[controller] = false;
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {
        require(from != address(0), " ");
        require(amount > 1e9, " ");

        uint256 _tax;
        if (_isWhiteLists[from] || _isWhiteLists[to]) {
            _tax = 0;
        } else {
            require(launch != 0 && amount <= maxTxAmount, " ");

            if (inSwapAndLiquify == 1) {
                _balance[from] -= amount;
                _balance[to] += amount;

                emit Transfer(from, to, amount);
                return;
            }

            if (from == uniswapV2Pair) {
                _tax = buyTax;
            } else if (to == uniswapV2Pair) {
                uint256 tokensToSwap = _balance[address(this)];
                if (tokensToSwap > minSwap && inSwapAndLiquify == 0) {
                    if (tokensToSwap > onePercent) {
                        tokensToSwap = onePercent;
                    }
                    inSwapAndLiquify = 1;
                    address[] memory path = new address[](2);
                    path[0] = address(this);
                    path[1] = WETH;
                    uniswapV2Router
                        .swapExactTokensForETHSupportingFeeOnTransferTokens(
                            tokensToSwap,
                            0,
                            path,
                            marketingWallet,
                            block.timestamp
                        );
                    inSwapAndLiquify = 0;
                }
                _tax = sellTax;
            } else {
                _tax = 0;
            }
        }
        if (_tax != 0) {
            uint256 taxTokens = (amount * _tax) / 100;
            uint256 transferAmount = amount - taxTokens;

            _balance[from] -= amount;
            _balance[to] += transferAmount;
            _balance[address(this)] += taxTokens;
            emit Transfer(from, address(this), taxTokens);
            emit Transfer(from, to, transferAmount);
        } else {
            _balance[from] -= amount;
            _balance[to] += amount;

            emit Transfer(from, to, amount);
        }
    }
}