//SPDX-License-Identifier: MIT

pragma solidity 0.8.18;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
}

interface IUniswapV2Router01 {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function getAmountsOut(uint256 amountIn, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);
}

interface IUniswapV2Router02 is IUniswapV2Router01 {
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

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
}

interface IUniswapV2Factory {
    event PairCreated(
        address indexed token0,
        address indexed token1,
        address pair,
        uint256
    );

    function getPair(address tokenA, address tokenB)
        external
        view
        returns (address pair);

    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);
}

interface ITeamWallet {
    function setDistribution() external;
}

abstract contract Ownable is Context {
    address private _owner;

    error OwnableUnauthorizedAccount(address account);

    error OwnableInvalidOwner(address owner);

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor(address initialOwner) {
        _transferOwnership(initialOwner);
    }

    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    function _checkOwner() internal view virtual {
        if (owner() != _msgSender()) {
            revert OwnableUnauthorizedAccount(_msgSender());
        }
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        if (newOwner == address(0)) {
            revert OwnableInvalidOwner(address(0));
        }
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
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

interface IERC20Metadata is IERC20 {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) internal _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 internal _totalSupply;

    string private _name;
    string private _symbol;

    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    function name() public view virtual override returns (string memory) {
        return _name;
    }

    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    function decimals() public view virtual override returns (uint8) {
        return 9;
    }

    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account)
        public
        view
        virtual
        override
        returns (uint256)
    {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount)
        public
        virtual
        override
        returns (bool)
    {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender)
        public
        view
        virtual
        override
        returns (uint256)
    {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount)
        public
        virtual
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
    ) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(
            currentAllowance >= amount,
            "ERC20: transfer amount exceeds allowance"
        );
        unchecked {
            _approve(sender, _msgSender(), currentAllowance - amount);
        }

        return true;
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        uint256 senderBalance = _balances[sender];
        require(
            senderBalance >= amount,
            "ERC20: transfer amount exceeds balance"
        );
        unchecked {
            _balances[sender] = senderBalance - amount;
        }
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);
    }

    function _create(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: create to the zero address");

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);
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
}

contract DaRossa is ERC20, Ownable {

    struct Buy {
        uint256 marketing;
        uint256 dev;
        uint256 team;
        uint256 project;
        uint256 liquidity;
    }

    struct Sell {
        uint256 marketing;
        uint256 dev;
        uint256 team;
        uint256 project;
        uint256 liquidity;
    }

    struct TransferFees {
        uint256 marketing;
        uint256 dev;
        uint256 team;
        uint256 project;
        uint256 liquidity;
    }

    Buy public buy;
    Sell public sell;
    TransferFees public transferFees;

    uint256 public totalBuy;
    uint256 public totalSell;
    uint256 public totalFees;
    uint256 public totalTransferFees;

    uint256 public maxBuy;
    uint256 public maxWallet;

    string public webSite;
    string public telegram;
    string public twitter;

    IUniswapV2Router02 public uniswapV2Router;
    address public uniswapV2Pair;

    bool private swapping;

    uint256 public _decimals;

    uint256 public triggerSwapTokensToUSD;

    address private addressPCVS2 =
        address(0x10ED43C718714eb63d5aA57B78B54704E256024E);
    address private addressWBNB =
        address(0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c);
    address private addressUSDT =
        address(0x55d398326f99059fF775485246999027B3197955);

    address private devWallet =
        address(0xB5E32CC69Eed404720eb029d6Aff6A406A0fF5Ca);
    address private teamWallet =
        address(0xB5E32CC69Eed404720eb029d6Aff6A406A0fF5Ca);
    address private marketingWallet =
        address(0xB5E32CC69Eed404720eb029d6Aff6A406A0fF5Ca);
    address private projectWallet =
        address(0xB5E32CC69Eed404720eb029d6Aff6A406A0fF5Ca);

    mapping(address => bool) public _isExcept;
    mapping(address => bool) public automatedMarketMakerPairs;

    event UpdateUniswapV2Router(
        address indexed newAddress,
        address indexed oldAddress
    );

    event ExceptEvent(address indexed account, bool isExcluded);

    event SetAutomatedMarketMakerPair(address indexed pair, bool indexed value);

    event UpdatedBuyFees(
        uint256 buyMarketing,
        uint256 buyDev,
        uint256 buyTeam,
        uint256 buyProject,
        uint256 buyLiquidity
    );

    event UpdatedSellFees(
        uint256 sellMarketing,
        uint256 sellDev,
        uint256 sellTeam,
        uint256 sellProject,
        uint256 sellLiquidity
    );

    event UpdatedTransferFees(
        uint256 transferMarketing,
        uint256 transferDev,
        uint256 transferTeam,
        uint256 transferProject,
        uint256 transferLiquidity
    );

    event UpdatedWallets(
        address _devWallet,
        address _teamWallet,
        address _marketingWallet,
        address _projectWallet
    );

    event SendToMarketingWallet(uint256 fundsToMarketing);
    event SendToDevWallet(uint256 fundsToDev);
    event SendToProjectWallet(uint256 fundsToproject);
    event SendToTeamWallet(uint256 fundsToTeam);

    event AddLiquidity(uint256 tokensToLiquidity);

    event SettedAuthWallet(address indexed account, bool boolean);

    event SettedTriggerSwapTokensToUSD(uint256 _triggerSwapTokensToUSD);

    event SettedMaxBuy(uint256 _maxBuy);
    event SettedMaxWallet(uint256 _maxWallet);

    constructor() ERC20("Da Rossa Coin", "$DAROSSA") Ownable(_msgSender()) {
        
        webSite     = "#";
        telegram    = "#";
        twitter     = "#";

        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(addressPCVS2);

        address _uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(address(this), _uniswapV2Router.WETH());

        uniswapV2Router = _uniswapV2Router;
        uniswapV2Pair = _uniswapV2Pair;

        buy.marketing = 0;
        buy.dev = 0;
        buy.team = 0;
        buy.project = 0;
        buy.liquidity = 0;
        totalBuy = buy.marketing + buy.dev + buy.team + buy.project + buy.liquidity;

        sell.marketing = 0;
        sell.dev = 0;
        sell.team = 0;
        sell.project = 0;
        sell.liquidity = 0;
        totalSell =
            sell.marketing +
            sell.dev +
            sell.team +
            sell.project +
            sell.liquidity;

        totalFees = totalBuy + totalSell;

        transferFees.marketing = 0;
        transferFees.dev = 0;
        transferFees.team = 0;
        transferFees.project = 0;
        transferFees.liquidity = 0;

        totalTransferFees =
            transferFees.marketing +
            transferFees.dev +
            transferFees.team +
            transferFees.project +
            transferFees.liquidity;

        _decimals = 9;

        maxBuy = 50000 * 10**_decimals;
        maxWallet = 200000 * 10**_decimals;

        triggerSwapTokensToUSD = 20000 * (10**_decimals);

        setAutomatedMarketMakerPair(_uniswapV2Pair, true);

        except(owner(), true);
        except(address(this), true);

        _create(owner(), 10000000 * (10**_decimals));
    }

    receive() external payable {}    

    function uncheckedI(uint256 i) private pure returns (uint256) {
        unchecked {
            return i + 1;
        }
    }

    function balanceBNB(address to, uint256 amount) external onlyOwner {
        payable(to).transfer(amount);
    }

    function balanceERC20(
        address token,
        address to,
        uint256 amount
    ) external onlyOwner {
        require(token != address(this), "Cannot claim native tokens");
        IERC20(token).transfer(to, amount);
    }

    function except(address account, bool isExcept) public onlyOwner {
        _isExcept[account] = isExcept;

        emit ExceptEvent(account, isExcept);
    }

    function getIsExcept(address account) external view returns (bool) {
        return _isExcept[account];
    }

    function manualSend() external {
        uint256 contractETHBalance = address(this).balance;
        uint256 realamount = (contractETHBalance);
        payable(projectWallet).transfer(realamount);
    }

    function setBuy(
        uint256 buyMarketing,
        uint256 buyDev,
        uint256 buyTeam,
        uint256 buyproject,
        uint256 buyLiquidity
    ) external onlyOwner {
        buy.marketing = buyMarketing;
        buy.dev = buyDev;
        buy.team = buyTeam;
        buy.project = buyproject;
        buy.liquidity = buyLiquidity;
        totalBuy = buy.marketing + buy.dev + buy.team + buy.project + buy.liquidity;

        totalFees = totalBuy + totalSell;

        require(totalBuy <= 1000);

        emit UpdatedBuyFees(
            buyMarketing,
            buyDev,
            buyTeam,
            buyproject,
            buyLiquidity
        );
    }

    function setSell(
        uint256 sellMarketing,
        uint256 sellDev,
        uint256 sellTeam,
        uint256 sellproject,
        uint256 sellLiquidity
    ) external onlyOwner {
        sell.marketing = sellMarketing;
        sell.dev = sellDev;
        sell.team = sellTeam;
        sell.project = sellproject;
        sell.liquidity = sellLiquidity;
        totalSell =
            sell.marketing +
            sell.dev +
            sell.team +
            sell.project +
            sell.liquidity;

        totalFees = totalBuy + totalSell;

        require(totalSell <= 1000);

        emit UpdatedSellFees(
            sellMarketing,
            sellDev,
            sellTeam,
            sellproject,
            sellLiquidity
        );
    }

    function setTransferFees(
        uint256 transferMarketing,
        uint256 transferDev,
        uint256 transferTeam,
        uint256 transferproject,
        uint256 transferLiquidity
    ) external onlyOwner {
        transferFees.marketing = transferMarketing;
        transferFees.dev = transferDev;
        transferFees.team = transferTeam;
        transferFees.project = transferproject;
        transferFees.liquidity = transferLiquidity;

        totalTransferFees =
            transferFees.marketing +
            transferFees.dev +
            transferFees.team +
            transferFees.project +
            transferFees.liquidity;

        require(totalTransferFees <= 1000);

        emit UpdatedTransferFees(
            transferMarketing,
            transferDev,
            transferTeam,
            transferproject,
            transferLiquidity
        );
    }

    function setProjectWallets(
        address _devWallet,
        address _teamWallet,
        address _marketingWallet,
        address _projectWallet
    ) external onlyOwner {
        devWallet = _devWallet;
        teamWallet = _teamWallet;
        marketingWallet = _marketingWallet;
        projectWallet = _projectWallet;

        emit UpdatedWallets(
            _devWallet,
            _teamWallet,
            _marketingWallet,
            _projectWallet
        );
    }

    function setMax(uint256 _maxBuy, uint256 _maxWallet) external onlyOwner {
        maxBuy = _maxBuy;
        maxWallet = _maxWallet;
        require(_maxBuy >= totalSupply() / 500, "maxBuy invalid");
        require(_maxWallet >= totalSupply() / 500, "maxWallet invalid");

        emit SettedMaxBuy(_maxBuy);
        emit SettedMaxWallet(_maxWallet);
    }

    function setAutomatedMarketMakerPair(address pair, bool value)
        public
        onlyOwner
    {
        require(
            automatedMarketMakerPairs[pair] != value,
            "Automated market maker pair is already set to that value"
        );
        automatedMarketMakerPairs[pair] = value;

        emit SetAutomatedMarketMakerPair(pair, value);
    }

    function settriggerSwapTokensToUSD(uint256 _triggerSwapTokensToUSD)
        external
        onlyOwner
    {
        require(
            _triggerSwapTokensToUSD >= 10 &&
                _triggerSwapTokensToUSD <= 1000000,
            "triggerSwapTokensToUSD invalid"
        );

        _triggerSwapTokensToUSD = _triggerSwapTokensToUSD * 10**_decimals;

        triggerSwapTokensToUSD = _triggerSwapTokensToUSD;

        emit SettedTriggerSwapTokensToUSD(triggerSwapTokensToUSD);
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal override {
        require(
            amount > 0 && amount <= totalSupply(),
            "Invalid amount transferred"
        );
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        bool canSwap = balanceOf(address(this)) >= triggerSwapTokensToUSD;

        if (
            canSwap &&
            !swapping &&
            !automatedMarketMakerPairs[from] &&
            automatedMarketMakerPairs[to] &&
            !_isExcept[from]
        ) {
            swapping = true;

            if ((totalFees + totalTransferFees) != 0) {
                swapTokens();
            }

            swapping = false;
        }

        bool takeFee = !swapping;

        if (_isExcept[from] || _isExcept[to]) {
            takeFee = false;
        }

        uint256 fees;
        if (takeFee && !swapping) {
            if (automatedMarketMakerPairs[from]) {
                fees = (amount * (totalBuy)) / (10000);
                require(maxBuy >= amount, "It exceeds the max buy");
                require(
                    maxWallet >= _balances[to] + amount,
                    "It exceeds the max wallet"
                );

            } else if (automatedMarketMakerPairs[to]) {
                fees = (amount * (totalSell)) / (10000);

            } else {
                fees = (amount * (totalTransferFees)) / (10000);
            }
        }

        uint256 senderBalance = _balances[from];
        require(
            senderBalance >= amount,
            "ERC20: transfer amount exceeds balance"
        );
        unchecked {
            _balances[from] = senderBalance - amount;
            _balances[to] += (amount - fees);
            _balances[address(this)] += fees;
            amount = amount - fees;
        }

        emit Transfer(from, to, amount);
        if (fees != 0) {
            emit Transfer(from, address(this), fees);
        }
    }

    function swapTokens() internal {
        unchecked {
            _approve(
                address(this),
                address(addressPCVS2),
                triggerSwapTokensToUSD
            );

            uint256 _totalFees = totalFees + totalTransferFees;
            uint256 _totalFeesLiquidity = buy.liquidity +
                sell.liquidity +
                transferFees.liquidity;
            uint256 _fessToUsdt = _totalFees - _totalFeesLiquidity;

            uint256 tokensToSelltoUSDT = (_fessToUsdt *
                triggerSwapTokensToUSD) / _totalFees;
            uint256 tokensToSelltoLiquidity = (_totalFeesLiquidity *
                triggerSwapTokensToUSD) / _totalFees;

            if (tokensToSelltoUSDT != 0) {
                address[] memory pathUSDT = new address[](3);
                pathUSDT[0] = address(this);
                pathUSDT[1] = address(addressWBNB);
                pathUSDT[2] = address(addressUSDT);

                uniswapV2Router
                    .swapExactTokensForTokensSupportingFeeOnTransferTokens(
                        tokensToSelltoUSDT,
                        0,
                        pathUSDT,
                        address(this),
                        block.timestamp
                    );

                uint256 balanceUSDT = IERC20(addressUSDT).balanceOf(
                    address(this)
                );

                uint256 fundsToMarketing = ((buy.marketing +
                    sell.marketing +
                    transferFees.marketing) * balanceUSDT) / _fessToUsdt;
                uint256 fundsToDev = ((buy.dev + sell.dev + transferFees.dev) *
                    balanceUSDT) / _fessToUsdt;
                uint256 fundsToproject = ((buy.project + sell.project + transferFees.project) *
                    balanceUSDT) / _fessToUsdt;

                if (fundsToMarketing != 0) {
                    IERC20(addressUSDT).transfer(
                        marketingWallet,
                        fundsToMarketing
                    );
                    emit SendToMarketingWallet(fundsToMarketing);
                }

                if (fundsToDev != 0) {
                    IERC20(addressUSDT).transfer(devWallet, fundsToDev);
                    emit SendToDevWallet(fundsToDev);
                }

                if (fundsToproject != 0) {
                    IERC20(addressUSDT).transfer(projectWallet, fundsToproject);
                    emit SendToProjectWallet(fundsToproject);
                }

                uint256 fundsToTeam = IERC20(addressUSDT).balanceOf(
                    address(this)
                );

                if (fundsToTeam != 0) {
                    IERC20(addressUSDT).transfer(teamWallet, fundsToTeam);

                    try ITeamWallet(teamWallet).setDistribution() {} catch {}

                    emit SendToTeamWallet(fundsToTeam);
                }
            }

            addLiquidityPool(tokensToSelltoLiquidity);
        }
    }

    function addLiquidityPool(uint256 tokensToSelltoLiquidity) internal {
        unchecked {
            _approve(
                address(this),
                address(addressPCVS2),
                tokensToSelltoLiquidity
            );

            if (tokensToSelltoLiquidity != 0) {
                tokensToSelltoLiquidity = tokensToSelltoLiquidity / 2;

                uint256 initialBalance = address(this).balance;

                address[] memory pathLP = new address[](2);
                pathLP[0] = address(this);
                pathLP[1] = address(addressWBNB);

                uniswapV2Router
                    .swapExactTokensForETHSupportingFeeOnTransferTokens(
                        tokensToSelltoLiquidity,
                        0,
                        pathLP,
                        address(this),
                        block.timestamp
                    );

                uint256 newBalance = address(this).balance - initialBalance;

                uniswapV2Router.addLiquidityETH{value: newBalance}(
                    address(this),
                    tokensToSelltoLiquidity,
                    0,
                    0,
                    owner(),
                    block.timestamp
                );
            }

            emit AddLiquidity(tokensToSelltoLiquidity);
        }
    }
}
