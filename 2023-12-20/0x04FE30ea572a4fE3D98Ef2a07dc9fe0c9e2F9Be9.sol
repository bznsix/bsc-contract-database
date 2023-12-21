// SPDX-License-Identifier: Unlicense
pragma solidity 0.8.19;


//                ____        _             ____              _    
//               |  _ \      | |           |  _ \            | |   
//               | |_) | __ _| |__  _   _  | |_) | ___  _ __ | | __
//               |  _ < / _` | '_ \| | | | |  _ < / _ \| '_ \| |/ /
//               | |_) | (_| | |_) | |_| | | |_) | (_) | | | |   < 
//               |____/ \__,_|_.__/ \__, | |____/ \___/|_| |_|_|\_\
//                                   __/ |                         
//                                  |___/                                                                                          
//            _          _          _          _          _          _     
//          _| |___    _| |___    _| |___    _| |___    _| |___    _| |___ 
//         | . | . |  | . | . |  | . | . |  | . | . |  | . | . |  | . | . |
//         |___|___|  |___|___|  |___|___|  |___|___|  |___|___|  |___|___|



//--- Context ---//
abstract contract Context {
    constructor() {}

    function _msgSender() internal view returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view returns (bytes memory) {
        this;
        return msg.data;
    }
}

//--- Ownable ---//
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
        _setOwner(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _setOwner(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

interface IFactoryV2 {
    event PairCreated(
        address indexed token0,
        address indexed token1,
        address lpPair,
        uint256
    );

    function getPair(address tokenA, address tokenB)
        external
        view
        returns (address lpPair);

    function createPair(address tokenA, address tokenB)
        external
        returns (address lpPair);
}

interface IV2Pair {
    function factory() external view returns (address);

    function getReserves()
        external
        view
        returns (
            uint112 reserve0,
            uint112 reserve1,
            uint32 blockTimestampLast
        );

    function sync() external;
}

interface IRouter01 {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    )
        external
        payable
        returns (
            uint256 amountToken,
            uint256 amountETH,
            uint256 liquidity
        );

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    )
        external
        returns (
            uint256 amountA,
            uint256 amountB,
            uint256 liquidity
        );

    function swapExactETHForTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function getAmountsOut(uint256 amountIn, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);

    function getAmountsIn(uint256 amountOut, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);
}

interface IRouter02 is IRouter01 {
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable;

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);
}

//--- Interface for ERC20 ---//
interface IERC20 {
    function totalSupply() external view returns (uint256);

    function decimals() external view returns (uint8);

    function symbol() external view returns (string memory);

    function name() external view returns (string memory);

    function getOwner() external view returns (address);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function allowance(address _owner, address spender)
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

//--- Contract BabyBonk ---//
contract BabyBonk is Context, Ownable, IERC20 {
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) private _noFee;
    mapping(address => bool) private liquidityAdd;
    mapping(address => bool) private isLpPair;
    mapping(address => bool) private isPresaleAddress;
    mapping(address => bool) private isBlacklisted;
    mapping(address => uint256) private balance;

    uint256 public constant _totalSupply = 420_690_000_000 * 10**9;
    uint256 public maxWallet = (_totalSupply * 20) / 1000; // 2% of the supply
    uint256 public buyfee = 69;
    uint256 public sellfee = 69;
    uint256 public transferfee = 0;
    uint256 public constant fee_denominator = 1_000;
    uint256 public swapThreshold = 0.69 ether; // 1 bnb
    bool private canSwapFees = true;
    address payable private marketingAddress = payable(address(0xD953652986D52FfE68EBB5E9506af9EfC20DBdB6)); //  Marketing wallet
    address payable private treasuryAddress = payable(address(0x2F9B745e23094C18c95a9A5C7325C78a8296c38b)); //  treasury wallet

    uint256 private marketingAllocation = 40;
    uint256 private treasuryAllocation = 20;
    uint256 private liquidityAllocation = 40;

    IRouter02 public swapRouter;
    string private constant _name = "Baby Bonk";
    string private constant _symbol = "BabyBonk";
    uint8 private constant _decimals = 9;
    address public constant DEAD = 0x000000000000000000000000000000000000dEaD;
    address public lpPair;
    bool public isTradingEnabled = false;
    bool private inSwap;

    modifier inSwapFlag() {
        inSwap = true;
        _;
        inSwap = false;
    }

    event _enableTrading();
    event _setPresaleAddress(address account, bool enabled);
    event _isBlacklisted(address user, bool blacklisted);
    event _toggleCanSwapFees(bool enabled);
    event _changePair(address newLpPair);
    event _changeThreshold(uint256 newThreshold);
    event _changeWallets(address marketing, address newSell);
    event _changeFees(uint256 buy, uint256 sell);
    event SwapAndLiquify();

    constructor() {
        _noFee[msg.sender] = true;
        _noFee[address(this)] = true;

        if (block.chainid == 56) {
            swapRouter = IRouter02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        } else if (block.chainid == 97) {
            swapRouter = IRouter02(0xD99D1c33F9fC3444f8101754aBC46c52416550D1);
        } else {
            revert("BabyBonk: Chain not valid");
        }
        liquidityAdd[msg.sender] = true;
        balance[msg.sender] = _totalSupply;
        emit Transfer(address(0), msg.sender, _totalSupply);

        require(
            marketingAllocation + treasuryAllocation + liquidityAllocation == 100,
            "BabyBonk: Must equals to 100%"
        );

        lpPair = IFactoryV2(swapRouter.factory()).createPair(
            swapRouter.WETH(),
            address(this)
        );
        isLpPair[lpPair] = true;
        _approve(msg.sender, address(swapRouter), type(uint256).max);
        _approve(address(this), address(swapRouter), type(uint256).max);
    }

    
    receive() external payable {}

    function totalSupply() external pure override returns (uint256) {
        if (_totalSupply == 0) {
            revert();
        }
        return _totalSupply;
    }

    function decimals() external pure override returns (uint8) {
        if (_totalSupply == 0) {
            revert();
        }
        return _decimals;
    }

    function symbol() external pure override returns (string memory) {
        return _symbol;
    }

    function name() external pure override returns (string memory) {
        return _name;
    }

    function getOwner() external view override returns (address) {
        return owner();
    }

    function allowance(address holder, address spender)
        external
        view
        override
        returns (uint256)
    {
        return _allowances[holder][spender];
    }

    function balanceOf(address account) public view override returns (uint256) {
        return balance[account];
    }

    function transfer(address recipient, uint256 amount)
        public
        override
        returns (bool)
    {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function approve(address spender, uint256 amount)
        external
        override
        returns (bool)
    {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function _approve(
        address sender,
        address spender,
        uint256 amount
    ) internal {
        require(sender != address(0), "ERC20: Zero Address");
        require(spender != address(0), "ERC20: Zero Address");

        _allowances[sender][spender] = amount;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external override returns (bool) {
        if (_allowances[sender][msg.sender] != type(uint256).max) {
            _allowances[sender][msg.sender] -= amount;
        }

        return _transfer(sender, recipient, amount);
    }

    function isNoFeeWallet(address account) external view returns (bool) {
        return _noFee[account];
    }

    function setNoFeeWallet(address account, bool enabled) public onlyOwner {
        _noFee[account] = enabled;
    }

    function isLimitedAddress(address ins, address out)
        internal
        view
        returns (bool)
    {
        bool isLimited = ins != owner() &&
            out != owner() &&
            msg.sender != owner() &&
            !liquidityAdd[ins] &&
            !liquidityAdd[out] &&
            out != address(0) &&
            out != address(this);
        return isLimited;
    }

    function is_buy(address ins, address out) internal view returns (bool) {
        bool _is_buy = !isLpPair[out] && isLpPair[ins];
        return _is_buy;
    }

    function is_sell(address ins, address out) internal view returns (bool) {
        bool _is_sell = isLpPair[out] && !isLpPair[ins];
        return _is_sell;
    }

    function isUserBlacklisted(address user) external view returns (bool) {
        return isBlacklisted[user];
    }

    function canSwap(address ins, address out) internal view returns (bool) {
        uint256 bnbAmount;
        uint256 contractTokenBalance = balanceOf(address(this));
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = swapRouter.WETH();
        if (contractTokenBalance > 1000e9) {
            bnbAmount = swapRouter.getAmountsOut(contractTokenBalance, path)[1];
        }
        bool canswap = canSwapFees &&
            !isPresaleAddress[ins] &&
            !isPresaleAddress[out] &&
            bnbAmount >= swapThreshold;

        return canswap;
    }

    function addOrRemoveLpPair(address newPair) external onlyOwner {
        require(newPair != lpPair, "can't modify main pair");
        isLpPair[newPair] = true;
        emit _changePair(newPair);
    }

    function setSwapThreshold(uint256 amountInWei) external onlyOwner {
        swapThreshold = amountInWei;
    }

    function setFees(uint256 buy, uint256 sell) external onlyOwner {
        require(
            buy <= 100 && sell <= 100,
            "max buy and sell fees is 10 percent"
        );
        buyfee = buy;
        sellfee = sell;
    }

    function setAllocation(
        uint256 marketing,
        uint256 treasury,
        uint256 autoLP
    ) external onlyOwner {
        require(marketing + treasury + autoLP == 100, "sum of allocation must be 100");
        marketingAllocation = marketing;
        treasuryAllocation = treasury;
        liquidityAllocation = autoLP;
    }

    function setPresaleAddress(address _presale, bool truefalse)
        external
        onlyOwner
    {
        require(isPresaleAddress[_presale] != truefalse, "Same bool");
        isPresaleAddress[_presale] = truefalse;
        _noFee[_presale] = truefalse;
    }

    function setMaxWalletPercent (uint256 percent) external onlyOwner {
        require(percent >=1, "Max wallet must be 1 or more percent of the total supply");
        maxWallet = (_totalSupply * percent) / 100;
    }

    function toggleCanSwapFees(bool truefalse) external onlyOwner {
        require(canSwapFees != truefalse, "Bool is the same");
        canSwapFees = truefalse;
        emit _toggleCanSwapFees(truefalse);
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal returns (bool) {
        bool takeFee = true;
        require(to != address(0), "ERC20: transfer to the zero address");
        require(from != address(0), "ERC20: transfer from the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");

        if (isLimitedAddress(from, to)) {
            require(isTradingEnabled, "Trading is not enabled");
            require(!isBlacklisted[from], "Sender is blacklisted");
            require(!isBlacklisted[to], "Receiver is blacklisted");
        }

        if (is_sell(from, to) && !inSwap && canSwap(from, to)) {
            uint256 contractTokenBalance = balanceOf(address(this));
            uint256 walletAllocation = marketingAllocation +
                treasuryAllocation +
                (liquidityAllocation / 2);
            if (walletAllocation > 0) {
                internalSwap((contractTokenBalance * walletAllocation) / 100);
            }
            if (liquidityAllocation > 0) {
                swapAndLiquify(
                    (contractTokenBalance * (liquidityAllocation / 2)) / 100
                );
            }
        }

        if (_noFee[from] || _noFee[to]) {
            takeFee = false;
        }
        if(takeFee && !isLpPair[to] ){
          require (balanceOf(to) + amount <= maxWallet, "max wallet limit exceeds");                     
        }
        balance[from] -= amount;
        uint256 amountAfterFee = (takeFee)
            ? takeTaxes(from, is_buy(from, to), is_sell(from, to), amount)
            : amount;

        balance[to] += amountAfterFee;
        emit Transfer(from, to, amountAfterFee);

        return true;
    }

    function changeWallets(address marketing, address treasury) external onlyOwner {
        require(marketing != address(0), "BabyBonk: Address Zero");
        require(treasury != address(0), "BabyBonk: Address Zero");
        marketingAddress = payable(marketing);
        treasuryAddress = payable(treasury);
        emit _changeWallets(marketing, treasury);
    }

    function setBlacklist(address user, bool truefalse) external onlyOwner {
        require (isBlacklisted[user] != truefalse, "Same bool");
        isBlacklisted[user] = truefalse;
        emit _isBlacklisted(user, truefalse);
    }

    function enableTrading() external onlyOwner {
        require(!isTradingEnabled, "Trading already enabled");
        isTradingEnabled = true;
        emit _enableTrading();
    }

    function claimStuckedTokens(address token, uint256 amount) external {
        require(
            msg.sender == treasuryAddress || msg.sender == marketingAddress,
            "only treasury or marketing wallet"
        );
        IERC20(token).transfer(msg.sender, amount);
    }

    function takeTaxes(
        address from,
        bool isbuy,
        bool issell,
        uint256 amount
    ) internal returns (uint256) {
        uint256 fee;
        if (isbuy) fee = buyfee;
        else if (issell) fee = sellfee;
        else fee = transferfee;
        if (fee == 0) return amount;
        uint256 feeAmount = (amount * fee) / fee_denominator;
        if (feeAmount > 0) {
            balance[address(this)] += feeAmount;
            emit Transfer(from, address(this), feeAmount);
        }
        return amount - feeAmount;
    }

    function swapAndLiquify(uint256 contractTokenBalance) internal inSwapFlag {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = swapRouter.WETH();

        uint256 newBalance = address(this).balance;

        try
            swapRouter.addLiquidityETH{value: newBalance}(
                address(this),
                contractTokenBalance,
                0,
                0,
                DEAD,
                block.timestamp
            )
        {} catch {
            return;
        }

        emit SwapAndLiquify();
    }

    function internalSwap(uint256 contractTokenBalance) internal inSwapFlag {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = swapRouter.WETH();

        if (
            _allowances[address(this)][address(swapRouter)] != type(uint256).max
        ) {
            _allowances[address(this)][address(swapRouter)] = type(uint256).max;
        }
        uint256 out = swapRouter.getAmountsOut(contractTokenBalance, path)[1];
        try
            swapRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(
                contractTokenBalance,
                (out * 80) / 100, // max 20% slippage
                path,
                address(this),
                block.timestamp
            )
        {} catch {
            return;
        }
        bool success;
        uint256 totalAllocation = marketingAllocation +
            treasuryAllocation +
            (liquidityAllocation / 2);
        uint256 mktAmount = (address(this).balance * marketingAllocation) /
            totalAllocation;
        uint256 treasuryAmount = (address(this).balance * treasuryAllocation) /
            totalAllocation;

        if (mktAmount > 0)
            (success, ) = marketingAddress.call{value: mktAmount}("");
        if (treasuryAmount > 0) (success, ) = treasuryAddress.call{value: treasuryAmount}("");
    }
}
